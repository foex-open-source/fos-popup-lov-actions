create or replace package body com_fos_popuplov_actions
as

-- =============================================================================
--
--  FOS = FOEX Open Source (fos.world), by FOEX GmbH, Austria (www.foex.at)
--
--  This plugin offers a set of actions to enhace the native PopupLOV.
--
--  License: MIT
--
--  GitHub: https://github.com/foex-open-source/fos-popuplov-actions
--
-- =============================================================================---------------------------------------------------------------------------

procedure get_popup_lovs_details
  ( p_application_id number
  , p_page_id        number
  , p_only_items     varchar2
  )
as

    l_additional_outputs_pairs apex_t_varchar2;
    l_additional_output_pair   apex_t_varchar2;
    l_additional_output_item   varchar2(100);

begin

    apex_json.open_array('items');

    for item in
      ( select *
          from apex_application_page_items
         where application_id  = p_application_id
           and page_id in (p_page_id,0)
           and display_as_code = 'NATIVE_POPUP_LOV'
           and ( p_only_items is null
              or item_name    in ( select column_value
                                     from apex_string.split(p_only_items, ',')
                                 )
               )
      )
    loop
        apex_json.open_object;

        apex_json.write('itemName', item.item_name);
        apex_json.open_array('additionalOutputsItems');

        l_additional_outputs_pairs := apex_string.split(item.attribute_10, ',');

        for idx in 1 .. l_additional_outputs_pairs.count
        loop
            apex_json.write(apex_string.split(l_additional_outputs_pairs(idx), ':')(2));
        end loop;

        apex_json.close_array;

        apex_json.close_object;
    end loop;

    apex_json.close_array;

end get_popup_lovs_details;

function render
  ( p_dynamic_action in apex_plugin.t_dynamic_action
  , p_plugin         in apex_plugin.t_plugin
  )
return apex_plugin.t_dynamic_action_render_result
as
    -- plugin attributes
    l_result  apex_plugin.t_dynamic_action_render_result;
    l_action  p_dynamic_action.attribute_01%type := p_dynamic_action.attribute_01;
    l_items   p_dynamic_action.attribute_02%type := p_dynamic_action.attribute_02;
    l_icon    p_dynamic_action.attribute_03%type := apex_escape.html_attribute(p_dynamic_action.attribute_03);

    l_ajax_id varchar2(1000) := apex_plugin.get_ajax_identifier;

    l_items_arr apex_t_varchar2;
    l_item      varchar2(100);

begin
    -- debug
    apex_plugin_util.debug_dynamic_action
      ( p_plugin         => p_plugin
      , p_dynamic_action => p_dynamic_action
      );

    l_items_arr := apex_string.split(l_items, ',');

    case l_action
        when 'add-clear-item-button' then
            apex_json.initialize_clob_output;

            apex_json.open_object;

            -- writes an array of objects containing the affected popupLOV instances with the additional ouput items
            get_popup_lovs_details
              ( p_application_id => V('APP_ID')
              , p_page_id        => V('APP_PAGE_ID')
              , p_only_items     => l_items
              );

            -- clear button icon
            apex_json.write('icon', l_icon);

            apex_json.close_object;

            l_result.javascript_function := 'function(){return FOS.utils.popupLOV.addClearItemButton(' || apex_json.get_clob_output || ');}';

            apex_json.free_output;

        when 'initialize-api' then
            if l_items_arr.count = 0
            then
                raise_application_error(-20000, 'Page Item(s) must be provided for FOS - Popup LOV - Actions - Initialize API');
            end if;

            for idx in 1 .. l_items_arr.count
            loop
                l_item := l_items_arr(idx);

                apex_json.initialize_clob_output;
                apex_json.open_object;
                apex_json.write('itemName', l_item   );
                apex_json.write('ajaxId'  , l_ajax_id);
                apex_json.close_object;
                apex_javascript.add_onload_code('FOS.utils.popupLOV.item.create(' || apex_json.get_clob_output || ');');
                apex_json.free_output;
            end loop;

            l_result.javascript_function := 'function(){return true;}';
        else
            raise_application_error(-20000, 'An action must be selected for FOS - Popup LOV - Actions');
    end case;

    return l_result;
end render;


function get_values_by_return
  ( p_application_id number
  , p_page_id        number
  , p_item_name      varchar2
  , p_return_value   varchar2
  )
return clob
as
    l_return clob;

    l_item                           apex_application_page_items%rowtype;
    l_lov                            apex_application_lovs%rowtype;
    l_display_column                 varchar2(100);
    l_return_column                  varchar2(100);
    l_display_value                  varchar2(4000);
    l_context                        apex_exec.t_context;
    l_filters                        apex_exec.t_filters;

    l_additional_column_item_pairs   apex_t_varchar2;
    l_additional_column_item         apex_t_varchar2;
    l_additional_column              varchar2(100);
    l_additional_item                varchar2(100);

begin
    select *
      into l_item
      from apex_application_page_items
     where application_id  = p_application_id
       and page_id         in (p_page_id,0)
       and item_name       = p_item_name
       and display_as_code = 'NATIVE_POPUP_LOV'
    ;

    if l_item.lov_named_lov is null
    then
        raise_application_error(-20000, 'Popup LOV must be based on a List Of Values.');
    end if;

    select *
      into l_lov
      from apex_application_lovs
     where application_id      = p_application_id
       and list_of_values_name = l_item.lov_named_lov
    ;

    if l_lov.list_of_values_query is null
    then
        raise_application_error(-20000, 'List of Value must be based on a query.');
    end if;

    apex_exec.add_filter
      ( p_filters     => l_filters
      , p_filter_type => apex_exec.c_filter_eq
      , p_column_name => l_lov.return_column_name
      , p_value       => p_return_value
      );

    l_context := apex_exec.open_query_context
                   ( p_location    => apex_exec.c_location_local_db
                   , p_sql_query   => l_lov.list_of_values_query
                   , p_filters     => l_filters
                   , p_max_rows    => 1
                   );

    if not apex_exec.next_row(l_context)
    then
        raise no_data_found;
    end if;

    l_display_value := apex_exec.get_varchar2
                         ( p_context     => l_context
                         , p_column_idx  => apex_exec.get_column_position(l_context, l_lov.display_column_name)
                         );

    apex_json.initialize_clob_output;
    apex_json.open_object;

    apex_json.write('displayValue', l_display_value);

    l_additional_column_item_pairs := apex_string.split(l_item.attribute_10, ',');

    apex_json.open_array('additionalOutputs');

    for idx in 1 .. l_additional_column_item_pairs.count
    loop
        l_additional_column_item := apex_string.split(l_additional_column_item_pairs(idx), ':');
        l_additional_column      := l_additional_column_item(1);
        l_additional_item        := l_additional_column_item(2);

        apex_json.open_object;
        apex_json.write('item', l_additional_item);
        apex_json.write
          ( p_name  => 'value'
          , p_value => apex_exec.get_varchar2
                         ( p_context     => l_context
                         , p_column_idx  => apex_exec.get_column_position(l_context, l_additional_column)
                         )
          );
        apex_json.close_object;

    end loop;
    apex_json.close_array;

    apex_exec.close(l_context);

    apex_json.close_object;
    l_return := apex_json.get_clob_output;

    apex_json.free_output;

    return l_return;
exception
    when others then
        apex_exec.close(l_context);
        apex_json.free_output;
        raise;
end get_values_by_return;

function ajax
  ( p_dynamic_action apex_plugin.t_dynamic_action
  , p_plugin         apex_plugin.t_plugin
  )
return apex_plugin.t_dynamic_action_ajax_result
as
    l_return apex_plugin.t_dynamic_action_ajax_result;

    l_items      varchar2(4000)     := p_dynamic_action.attribute_02;
    l_items_arr  apex_t_varchar2    := apex_string.split(l_items, ',');

    l_action     varchar2(100)      := apex_application.g_x01;
    l_item       varchar2(100)      := apex_application.g_x02;
    l_value      varchar2(100)      := apex_application.g_x03;

    l_response clob;
begin

    -- debug
    apex_plugin_util.debug_dynamic_action
        ( p_plugin         => p_plugin
        , p_dynamic_action => p_dynamic_action
        );

    -- security checks
    if l_action != 'GET_VALUES_BY_RETURN'
    then
        raise_application_error(-20000, 'This action is not allowed');
    end if;

    if not l_item member of l_items_arr
    then
        raise_application_error(-20000, 'No permission to fetch values for this item');
    end if;

    --could throw no_data_found
    l_response := get_values_by_return
                    ( p_application_id => V('APP_ID')
                    , p_page_id        => V('APP_PAGE_ID')
                    , p_item_name      => l_item
                    , p_return_value   => l_value
                    );

    htp.p(l_response);

    return l_return;
exception
    when no_data_found then
        htp.p('{"error": "No data found"}');
        return l_return;
end ajax;

end;
/


