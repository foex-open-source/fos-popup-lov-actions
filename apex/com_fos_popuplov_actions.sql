prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_190200 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2019.10.04'
,p_release=>'19.2.0.00.18'
,p_default_workspace_id=>1620873114056663
,p_default_application_id=>102
,p_default_id_offset=>0
,p_default_owner=>'FOS_MASTER_WS'
);
end;
/

prompt APPLICATION 102 - FOS Dev - Plugin Master
--
-- Application Export:
--   Application:     102
--   Name:            FOS Dev - Plugin Master
--   Exported By:     FOS_MASTER_WS
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 61118001090994374
--     PLUGIN: 134108205512926532
--     PLUGIN: 1039471776506160903
--     PLUGIN: 547902228942303344
--     PLUGIN: 217651153971039957
--     PLUGIN: 412155278231616931
--     PLUGIN: 1389837954374630576
--     PLUGIN: 461352325906078083
--     PLUGIN: 13235263798301758
--     PLUGIN: 216426771609128043
--     PLUGIN: 37441962356114799
--     PLUGIN: 1846579882179407086
--     PLUGIN: 8354320589762683
--     PLUGIN: 50031193176975232
--     PLUGIN: 106296184223956059
--     PLUGIN: 35822631205839510
--     PLUGIN: 2674568769566617
--     PLUGIN: 183507938916453268
--     PLUGIN: 14934236679644451
--     PLUGIN: 2600618193722136
--     PLUGIN: 2657630155025963
--     PLUGIN: 284978227819945411
--     PLUGIN: 56714461465893111
--     PLUGIN: 98648032013264649
--     PLUGIN: 455014954654760331
--     PLUGIN: 98504124924145200
--     PLUGIN: 212503470416800524
--   Manifest End
--   Version:         19.2.0.00.18
--   Instance ID:     250144500186934
--

begin
  -- replace components
  wwv_flow_api.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/dynamic_action/com_fos_popuplov_actions
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(412155278231616931)
,p_plugin_type=>'DYNAMIC ACTION'
,p_name=>'COM.FOS.POPUPLOV_ACTIONS'
,p_display_name=>'FOS - Popup LOV Actions'
,p_category=>'EXECUTE'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_javascript_file_urls=>wwv_flow_string.join(wwv_flow_t_varchar2(
'#PLUGIN_FILES#js/script.js',
''))
,p_css_file_urls=>'#PLUGIN_FILES#/css/style.css'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'-- =============================================================================',
'--',
'--  FOS = FOEX Open Source (fos.world), by FOEX GmbH, Austria (www.foex.at)',
'--',
'--  This plugin offers a set of actions to enhace the native PopupLOV. ',
'--',
'--  License: MIT',
'--',
'--  GitHub: https://github.com/foex-open-source/fos-popuplov-actions',
'--',
'-- =============================================================================---------------------------------------------------------------------------',
'',
'procedure get_popup_lovs_details',
'  ( p_application_id number',
'  , p_page_id        number',
'  , p_only_items     varchar2',
'  )',
'as',
'',
'    l_additional_outputs_pairs apex_t_varchar2;',
'    l_additional_output_pair   apex_t_varchar2;',
'    l_additional_output_item   varchar2(100);',
'    ',
'begin',
'    ',
'    apex_json.open_array(''items'');',
'    ',
'    for item in ',
'      ( select * ',
'          from apex_application_page_items',
'         where application_id  = p_application_id',
'           and page_id in (p_page_id,0)',
'           and display_as_code = ''NATIVE_POPUP_LOV''',
'           and ( p_only_items is null',
'              or item_name    in ( select column_value',
'                                     from apex_string.split(p_only_items, '','')',
'                                 )',
'               )',
'      )',
'    loop',
'        apex_json.open_object;',
'        ',
'        apex_json.write(''itemName'', item.item_name);',
'        apex_json.open_array(''additionalOutputsItems'');',
'        ',
'        l_additional_outputs_pairs := apex_string.split(item.attribute_10, '','');',
'        ',
'        for idx in 1 .. l_additional_outputs_pairs.count',
'        loop',
'            apex_json.write(apex_string.split(l_additional_outputs_pairs(idx), '':'')(2));',
'        end loop;',
'',
'        apex_json.close_array;',
'',
'        apex_json.close_object;',
'    end loop;',
'    ',
'    apex_json.close_array;',
'  ',
'end get_popup_lovs_details;',
'',
'function render',
'  ( p_dynamic_action in apex_plugin.t_dynamic_action',
'  , p_plugin         in apex_plugin.t_plugin',
'  )',
'return apex_plugin.t_dynamic_action_render_result',
'as',
'    -- plugin attributes',
'    l_result  apex_plugin.t_dynamic_action_render_result;',
'    l_action  p_dynamic_action.attribute_01%type := p_dynamic_action.attribute_01;',
'    l_items   p_dynamic_action.attribute_02%type := p_dynamic_action.attribute_02;',
'    l_icon    p_dynamic_action.attribute_03%type := apex_escape.html_attribute(p_dynamic_action.attribute_03);',
'    ',
'    l_ajax_id varchar2(1000) := apex_plugin.get_ajax_identifier;',
'    ',
'    l_items_arr apex_t_varchar2;',
'    l_item      varchar2(100);',
'',
'begin',
'    -- debug',
'    if apex_application.g_debug and substr(:DEBUG,6) >= 6',
'    then',
'        apex_plugin_util.debug_dynamic_action',
'          ( p_plugin         => p_plugin',
'          , p_dynamic_action => p_dynamic_action',
'          );',
'    end if;',
'    ',
'    l_items_arr := apex_string.split(l_items, '','');',
'',
'    case l_action',
'        when ''add-clear-item-button'' then',
'            apex_json.initialize_clob_output;',
'',
'            apex_json.open_object;',
'',
'            -- writes an array of objects containing the affected popupLOV instances with the additional ouput items',
'            get_popup_lovs_details',
'              ( p_application_id => V(''APP_ID'')',
'              , p_page_id        => V(''APP_PAGE_ID'')',
'              , p_only_items     => l_items',
'              );',
'',
'            -- clear button icon',
'            apex_json.write(''icon'', l_icon);',
'',
'            apex_json.close_object;',
'',
'            l_result.javascript_function := ''function(){return FOS.utils.popupLOV.addClearItemButton('' || apex_json.get_clob_output || '');}'';',
'            ',
'            apex_json.free_output;',
'',
'        when ''initialize-api'' then',
'            if l_items_arr.count = 0',
'            then',
'                raise_application_error(-20000, ''Page Item(s) must be provided for FOS - Popup LOV - Actions - Initialize API'');',
'            end if;',
'        ',
'            for idx in 1 .. l_items_arr.count ',
'            loop',
'                l_item := l_items_arr(idx);',
'',
'                apex_json.initialize_clob_output;',
'                apex_json.open_object;',
'                apex_json.write(''itemName'', l_item   );',
'                apex_json.write(''ajaxId''  , l_ajax_id);',
'                apex_json.close_object;',
'                apex_javascript.add_onload_code(''FOS.utils.popupLOV.item.create('' || apex_json.get_clob_output || '');'');',
'                apex_json.free_output;',
'            end loop;',
'',
'            l_result.javascript_function := ''function(){return true;}'';',
'        else',
'            raise_application_error(-20000, ''An action must be selected for FOS - Popup LOV - Actions'');',
'    end case;',
'',
'    return l_result;',
'end render;',
'',
'',
'function get_values_by_return',
'  ( p_application_id number',
'  , p_page_id        number',
'  , p_item_name      varchar2',
'  , p_return_value   varchar2',
'  )',
'return clob',
'as',
'    l_return clob;',
'',
'    l_item                           apex_application_page_items%rowtype;',
'    l_lov                            apex_application_lovs%rowtype;',
'    l_display_column                 varchar2(100);',
'    l_return_column                  varchar2(100);',
'    l_display_value                  varchar2(4000);',
'    l_context                        apex_exec.t_context;',
'    l_filters                        apex_exec.t_filters;',
'',
'    l_additional_column_item_pairs   apex_t_varchar2;',
'    l_additional_column_item         apex_t_varchar2;',
'    l_additional_column              varchar2(100);',
'    l_additional_item                varchar2(100);',
'',
'begin',
'    select *',
'      into l_item',
'      from apex_application_page_items',
'     where application_id  = p_application_id',
'       and page_id         in (p_page_id,0)',
'       and item_name       = p_item_name',
'       and display_as_code = ''NATIVE_POPUP_LOV''',
'    ;',
'    ',
'    if l_item.lov_named_lov is null',
'    then',
'        raise_application_error(-20000, ''Popup LOV must be based on a List Of Values.'');',
'    end if;',
'    ',
'    select *',
'      into l_lov',
'      from apex_application_lovs',
'     where application_id      = p_application_id',
'       and list_of_values_name = l_item.lov_named_lov',
'    ;',
'    ',
'    if l_lov.list_of_values_query is null',
'    then',
'        raise_application_error(-20000, ''List of Value must be based on a query.'');',
'    end if;',
'    ',
'    apex_exec.add_filter',
'      ( p_filters     => l_filters',
'      , p_filter_type => apex_exec.c_filter_eq',
'      , p_column_name => l_lov.return_column_name',
'      , p_value       => p_return_value',
'      );',
'',
'    l_context := apex_exec.open_query_context',
'                   ( p_location    => apex_exec.c_location_local_db',
'                   , p_sql_query   => l_lov.list_of_values_query',
'                   , p_filters     => l_filters',
'                   , p_max_rows    => 1',
'                   );',
'    ',
'    if not apex_exec.next_row(l_context)',
'    then',
'        raise no_data_found;',
'    end if;',
'    ',
'    l_display_value := apex_exec.get_varchar2',
'                         ( p_context     => l_context',
'                         , p_column_idx  => apex_exec.get_column_position(l_context, l_lov.display_column_name)',
'                         );',
'',
'    apex_json.initialize_clob_output;',
'    apex_json.open_object;',
'    ',
'    apex_json.write(''displayValue'', l_display_value);',
'    ',
'    l_additional_column_item_pairs := apex_string.split(l_item.attribute_10, '','');',
'    ',
'    apex_json.open_array(''additionalOutputs'');',
'',
'    for idx in 1 .. l_additional_column_item_pairs.count',
'    loop',
'        l_additional_column_item := apex_string.split(l_additional_column_item_pairs(idx), '':'');',
'        l_additional_column      := l_additional_column_item(1);',
'        l_additional_item        := l_additional_column_item(2);',
'        ',
'        apex_json.open_object;',
'        apex_json.write(''item'', l_additional_item);',
'        apex_json.write',
'          ( p_name  => ''value''',
'          , p_value => apex_exec.get_varchar2',
'                         ( p_context     => l_context',
'                         , p_column_idx  => apex_exec.get_column_position(l_context, l_additional_column)',
'                         )',
'          );',
'        apex_json.close_object;',
'        ',
'    end loop;',
'    apex_json.close_array;',
'',
'    apex_exec.close(l_context);',
'    ',
'    apex_json.close_object;',
'    l_return := apex_json.get_clob_output;',
'    ',
'    apex_json.free_output;',
'',
'    return l_return;',
'exception',
'    when others then',
'        apex_exec.close(l_context);',
'        apex_json.free_output;',
'        raise;',
'end get_values_by_return;',
'',
'function ajax',
'  ( p_dynamic_action apex_plugin.t_dynamic_action',
'  , p_plugin         apex_plugin.t_plugin',
'  )',
'return apex_plugin.t_dynamic_action_ajax_result',
'as',
'    l_return apex_plugin.t_dynamic_action_ajax_result;',
'    ',
'    l_items      varchar2(4000)     := p_dynamic_action.attribute_02;',
'    l_items_arr  apex_t_varchar2    := apex_string.split(l_items, '','');',
'    ',
'    l_action     varchar2(100)      := apex_application.g_x01;',
'    l_item       varchar2(100)      := apex_application.g_x02;',
'    l_value      varchar2(100)      := apex_application.g_x03;',
'    ',
'    l_response clob;',
'begin',
'',
'    -- debug',
'    if apex_application.g_debug and substr(:DEBUG,6) >= 6',
'    then',
'        apex_plugin_util.debug_dynamic_action',
'            ( p_plugin         => p_plugin',
'            , p_dynamic_action => p_dynamic_action',
'            );',
'    end if;',
'',
'    -- security checks',
'    if l_action != ''GET_VALUES_BY_RETURN''',
'    then',
'        raise_application_error(-20000, ''This action is not allowed'');',
'    end if;',
'    ',
'    if not l_item member of l_items_arr',
'    then',
'        raise_application_error(-20000, ''No permission to fetch values for this item'');',
'    end if;',
'    ',
'    --could throw no_data_found',
'    l_response := get_values_by_return',
'                    ( p_application_id => V(''APP_ID'')',
'                    , p_page_id        => V(''APP_PAGE_ID'')',
'                    , p_item_name      => l_item',
'                    , p_return_value   => l_value',
'                    );',
'    ',
'    htp.p(l_response);',
'',
'    return l_return;',
'exception',
'    when no_data_found then',
'        htp.p(''{"error": "No data found"}'');',
'        return l_return;',
'end ajax;'))
,p_api_version=>2
,p_render_function=>'render'
,p_ajax_function=>'ajax'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>The <strong>FOS - Popup LOV Actions </strong> plug-in adds the ability to dynamically set the value of a native Popup LOV item(s), <strong>including</strong> the items listed in the <i>"Additional Outputs"</i> attribute.</p>',
'<p>Additionally it can also provide a <i>"Clear"</i> button, so you''re able to clear/reset the Popup LOV value (and all the associated items) with just one click.</p>'))
,p_version_identifier=>'22.1.0'
,p_about_url=>'https://fos.world'
,p_plugin_comment=>wwv_flow_string.join(wwv_flow_t_varchar2(
'@fos-auto-return-to-page',
'@fos-auto-open-files:js/script.js'))
,p_files_version=>465
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(412156455577640501)
,p_plugin_id=>wwv_flow_api.id(412155278231616931)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Action'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>false
,p_default_value=>'add-clear-item-button'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'<p>The action to be performed.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(412156702353653540)
,p_plugin_attribute_id=>wwv_flow_api.id(412156455577640501)
,p_display_sequence=>10
,p_display_value=>'Add Clear Item Button(s)'
,p_return_value=>'add-clear-item-button'
,p_help_text=>'<p>This action dynamically appends a "Clear Item" button with an "X" symbol to the items provided in the Page Item(s) attribute, or all Popup LOV instances if no items are provided. It is recommended to only use this plug-in once, on page load, on th'
||'e global page, and leave the Page Item(s) attribute empty. This way, all Popup LOV-s, in the entire application will be affected, having only instantiated this plug-in once.</p>'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(282968557731737649)
,p_plugin_attribute_id=>wwv_flow_api.id(412156455577640501)
,p_display_sequence=>20
,p_display_value=>'Initialize API'
,p_return_value=>'initialize-api'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>This action initialized an API which can be used in JavaScript to have greater control over the Popup LOV. Run this action on page load and provide the affected Popup LOVs in the Page Item(s) attribute.</p>',
'<p>You will then have access to the following function:</p>',
'<pre>FOS.utils.popupLOV.item(itemName).setValueByReturn(newValue)</pre>',
'<p>This function sets the value provided, but displays the associated display value. If the Popup LOV includes additional outputs, these will be set as well. You can use this function anywhere in a JavaScript context.</p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(282977875346149342)
,p_plugin_id=>wwv_flow_api.id(412155278231616931)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Page Item(s)'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>false
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(412156455577640501)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'IN_LIST'
,p_depending_on_expression=>'add-clear-item-button,initialize-api'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<p>List of the affected Popup LOV items.<br>',
'If the <strong>Action</strong> is set to <strong>Initialize API</strong>, then it <strong>must contain a value</strong>.',
'</p>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(151107480655580761)
,p_plugin_id=>wwv_flow_api.id(412155278231616931)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Delete Icon'
,p_attribute_type=>'ICON'
,p_is_required=>true
,p_default_value=>'fa-times'
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(412156455577640501)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'add-clear-item-button'
,p_help_text=>'The icon to be displayed in the <i>Clear Button</i>.'
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '77696E646F772E464F53203D2077696E646F772E464F53207C7C207B7D3B0A464F532E7574696C73203D20464F532E7574696C73207C7C207B7D3B0A464F532E7574696C732E706F7075704C4F56203D20464F532E7574696C732E706F7075704C4F5620';
wwv_flow_api.g_varchar2_table(2) := '7C7C207B7D3B0A0A464F532E7574696C732E706F7075704C4F562E616464436C6561724974656D427574746F6E203D2066756E6374696F6E28636F6E666967297B0A202020200A20202020636F6E7374206974656D73203D20636F6E6669672E6974656D';
wwv_flow_api.g_varchar2_table(3) := '733B0A20202020636F6E73742069636F6E203D20636F6E6669672E69636F6E3B0A0A20202020696628216974656D73297B0A202020202020202072657475726E3B0A202020207D0A202020200A20202020666F72286C65742069203D20303B20693C6974';
wwv_flow_api.g_varchar2_table(4) := '656D732E6C656E6774683B20692B2B297B0A2020202020202020636F6E7374206974656D20203D206974656D735B695D3B0A2020202020202020636F6E7374206974656D24203D2024282723272B6974656D2E6974656D4E616D65293B0A0A2020202020';
wwv_flow_api.g_varchar2_table(5) := '2020202F2F736B697020726561646F6E6C79206F72206E6F742072656E6465726564206974656D730A2020202020202020696620286974656D242E7369626C696E677328272E646973706C61795F6F6E6C7927292E6C656E677468207C7C20216974656D';
wwv_flow_api.g_varchar2_table(6) := '242E6C656E677468297B0A202020202020202020202020636F6E74696E75653B0A20202020202020207D0A0A2020202020202020636F6E737420627574746F6E2420203D202428273C627574746F6E207469746C653D22436C6561722056616C75652220';
wwv_flow_api.g_varchar2_table(7) := '747970653D22627574746F6E2220636C6173733D22612D427574746F6E20612D427574746F6E2D2D706F7075704C4F5620666F732D706F7075704C4F562220746162696E6465783D222D31223E3C7370616E20636C6173733D22666120272B69636F6E2B';
wwv_flow_api.g_varchar2_table(8) := '27223E3C2F7370616E3E3C2F627574746F6E3E27293B0A0A2020202020202020627574746F6E242E6F6E2827636C69636B272C2066756E6374696F6E28297B0A202020202020202020202020617065782E6974656D286974656D2E6974656D4E616D6529';
wwv_flow_api.g_varchar2_table(9) := '2E73657456616C7565286E756C6C2C206E756C6C293B0A2020202020202020202020206966286974656D2E6164646974696F6E616C4F7574707574734974656D73297B0A20202020202020202020202020202020666F72286C6574206A203D20303B206A';
wwv_flow_api.g_varchar2_table(10) := '3C6974656D2E6164646974696F6E616C4F7574707574734974656D732E6C656E6774683B206A2B2B297B0A2020202020202020202020202020202020202020617065782E6974656D286974656D2E6164646974696F6E616C4F7574707574734974656D73';
wwv_flow_api.g_varchar2_table(11) := '5B6A5D292E73657456616C7565286E756C6C2C206E756C6C293B0A202020202020202020202020202020207D0A2020202020202020202020207D0A20202020202020207D293B0A20202020202020206974656D242E706172656E7428292E706172656E74';
wwv_flow_api.g_varchar2_table(12) := '28292E617070656E6428627574746F6E24293B0A202020207D0A7D3B0A0A464F532E7574696C732E706F7075704C4F562E6974656D203D2066756E6374696F6E286974656D4E616D65297B0A2020202076617220636F6E666967203D20464F532E757469';
wwv_flow_api.g_varchar2_table(13) := '6C732E706F7075704C4F562E6974656D2E696E7374616E6365735B6974656D4E616D655D3B0A202020207661722073657456616C7565427952657475726E203D2066756E6374696F6E2876616C75652C2063616C6C6261636B297B0A2020202020202020';
wwv_flow_api.g_varchar2_table(14) := '617065782E7365727665722E706C7567696E2028636F6E6669672E616A617849642C207B0A2020202020202020202020207830313A20274745545F56414C5545535F42595F52455455524E272C0A2020202020202020202020207830323A206974656D4E';
wwv_flow_api.g_varchar2_table(15) := '616D652C0A2020202020202020202020207830333A2076616C75650A20202020202020207D2C207B0A202020202020202020202020737563636573733A2066756E6374696F6E2864617461297B0A20202020202020202020202020202020617065782E69';
wwv_flow_api.g_varchar2_table(16) := '74656D286974656D4E616D65292E73657456616C75652876616C75652C20646174612E646973706C617956616C7565293B0A202020202020202020202020202020200A20202020202020202020202020202020696628646174612E6164646974696F6E61';
wwv_flow_api.g_varchar2_table(17) := '6C4F7574707574732E6C656E677468297B0A2020202020202020202020202020202020202020666F72287661722069203D20303B20693C646174612E6164646974696F6E616C4F7574707574732E6C656E6774683B20692B2B297B0A2020202020202020';
wwv_flow_api.g_varchar2_table(18) := '20202020202020202020202020202020766172206164646974696F6E616C4F7574707574203D20646174612E6164646974696F6E616C4F7574707574735B695D3B0A202020202020202020202020202020202020202020202020617065782E6974656D28';
wwv_flow_api.g_varchar2_table(19) := '6164646974696F6E616C4F75747075742E6974656D292E73657456616C7565286164646974696F6E616C4F75747075742E76616C7565293B0A20202020202020202020202020202020202020207D0A202020202020202020202020202020207D0A202020';
wwv_flow_api.g_varchar2_table(20) := '2020202020202020202020202069662863616C6C6261636B297B0A202020202020202020202020202020202020202063616C6C6261636B28293B0A202020202020202020202020202020207D0A0A2020202020202020202020202020202072657475726E';
wwv_flow_api.g_varchar2_table(21) := '20747275653B0A2020202020202020202020207D0A20202020202020207D293B0A202020207D3B0A2020202072657475726E207B0A202020202020202073657456616C7565427952657475726E3A2073657456616C7565427952657475726E0A20202020';
wwv_flow_api.g_varchar2_table(22) := '7D3B0A7D3B0A0A464F532E7574696C732E706F7075704C4F562E6974656D2E637265617465203D2066756E6374696F6E28636F6E666967297B0A20202020464F532E7574696C732E706F7075704C4F562E6974656D2E696E7374616E636573203D20464F';
wwv_flow_api.g_varchar2_table(23) := '532E7574696C732E706F7075704C4F562E6974656D2E696E7374616E636573207C7C207B7D3B0A20202020464F532E7574696C732E706F7075704C4F562E6974656D2E696E7374616E6365735B636F6E6669672E6974656D4E616D655D203D207B0A2020';
wwv_flow_api.g_varchar2_table(24) := '202020202020616A617849643A20636F6E6669672E616A617849640A202020207D3B0A7D3B';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(99009777452673653)
,p_plugin_id=>wwv_flow_api.id(412155278231616931)
,p_file_name=>'js/script.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '77696E646F772E464F533D77696E646F772E464F537C7C7B7D2C464F532E7574696C733D464F532E7574696C737C7C7B7D2C464F532E7574696C732E706F7075704C4F563D464F532E7574696C732E706F7075704C4F567C7C7B7D2C464F532E7574696C';
wwv_flow_api.g_varchar2_table(2) := '732E706F7075704C4F562E616464436C6561724974656D427574746F6E3D66756E6374696F6E2874297B636F6E737420653D742E6974656D732C693D742E69636F6E3B6966286529666F72286C657420743D303B743C652E6C656E6774683B742B2B297B';
wwv_flow_api.g_varchar2_table(3) := '636F6E737420753D655B745D2C6E3D24282223222B752E6974656D4E616D65293B6966286E2E7369626C696E677328222E646973706C61795F6F6E6C7922292E6C656E6774687C7C216E2E6C656E67746829636F6E74696E75653B636F6E737420613D24';
wwv_flow_api.g_varchar2_table(4) := '28273C627574746F6E207469746C653D22436C6561722056616C75652220747970653D22627574746F6E2220636C6173733D22612D427574746F6E20612D427574746F6E2D2D706F7075704C4F5620666F732D706F7075704C4F562220746162696E6465';
wwv_flow_api.g_varchar2_table(5) := '783D222D31223E3C7370616E20636C6173733D22666120272B692B27223E3C2F7370616E3E3C2F627574746F6E3E27293B612E6F6E2822636C69636B222C2866756E6374696F6E28297B696628617065782E6974656D28752E6974656D4E616D65292E73';
wwv_flow_api.g_varchar2_table(6) := '657456616C7565286E756C6C2C6E756C6C292C752E6164646974696F6E616C4F7574707574734974656D7329666F72286C657420743D303B743C752E6164646974696F6E616C4F7574707574734974656D732E6C656E6774683B742B2B29617065782E69';
wwv_flow_api.g_varchar2_table(7) := '74656D28752E6164646974696F6E616C4F7574707574734974656D735B745D292E73657456616C7565286E756C6C2C6E756C6C297D29292C6E2E706172656E7428292E706172656E7428292E617070656E642861297D7D2C464F532E7574696C732E706F';
wwv_flow_api.g_varchar2_table(8) := '7075704C4F562E6974656D3D66756E6374696F6E2874297B76617220653D464F532E7574696C732E706F7075704C4F562E6974656D2E696E7374616E6365735B745D3B72657475726E7B73657456616C7565427952657475726E3A66756E6374696F6E28';
wwv_flow_api.g_varchar2_table(9) := '692C75297B617065782E7365727665722E706C7567696E28652E616A617849642C7B7830313A224745545F56414C5545535F42595F52455455524E222C7830323A742C7830333A697D2C7B737563636573733A66756E6374696F6E2865297B6966286170';
wwv_flow_api.g_varchar2_table(10) := '65782E6974656D2874292E73657456616C756528692C652E646973706C617956616C7565292C652E6164646974696F6E616C4F7574707574732E6C656E67746829666F7228766172206E3D303B6E3C652E6164646974696F6E616C4F7574707574732E6C';
wwv_flow_api.g_varchar2_table(11) := '656E6774683B6E2B2B297B76617220613D652E6164646974696F6E616C4F7574707574735B6E5D3B617065782E6974656D28612E6974656D292E73657456616C756528612E76616C7565297D72657475726E207526267528292C21307D7D297D7D7D2C46';
wwv_flow_api.g_varchar2_table(12) := '4F532E7574696C732E706F7075704C4F562E6974656D2E6372656174653D66756E6374696F6E2874297B464F532E7574696C732E706F7075704C4F562E6974656D2E696E7374616E6365733D464F532E7574696C732E706F7075704C4F562E6974656D2E';
wwv_flow_api.g_varchar2_table(13) := '696E7374616E6365737C7C7B7D2C464F532E7574696C732E706F7075704C4F562E6974656D2E696E7374616E6365735B742E6974656D4E616D655D3D7B616A617849643A742E616A617849647D7D3B0A2F2F2320736F757263654D617070696E6755524C';
wwv_flow_api.g_varchar2_table(14) := '3D7363726970742E6A732E6D6170';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(99010551794685519)
,p_plugin_id=>wwv_flow_api.id(412155278231616931)
,p_file_name=>'js/script.min.js'
,p_mime_type=>'application/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '7B2276657273696F6E223A332C22736F7572636573223A5B227363726970742E6A73225D2C226E616D6573223A5B2277696E646F77222C22464F53222C227574696C73222C22706F7075704C4F56222C22616464436C6561724974656D427574746F6E22';
wwv_flow_api.g_varchar2_table(2) := '2C22636F6E666967222C226974656D73222C2269636F6E222C2269222C226C656E677468222C226974656D222C226974656D24222C2224222C226974656D4E616D65222C227369626C696E6773222C22627574746F6E24222C226F6E222C226170657822';
wwv_flow_api.g_varchar2_table(3) := '2C2273657456616C7565222C226164646974696F6E616C4F7574707574734974656D73222C226A222C22706172656E74222C22617070656E64222C22696E7374616E636573222C2273657456616C7565427952657475726E222C2276616C7565222C2263';
wwv_flow_api.g_varchar2_table(4) := '616C6C6261636B222C22736572766572222C22706C7567696E222C22616A61784964222C22783031222C22783032222C22783033222C2273756363657373222C2264617461222C22646973706C617956616C7565222C226164646974696F6E616C4F7574';
wwv_flow_api.g_varchar2_table(5) := '70757473222C226164646974696F6E616C4F7574707574222C22637265617465225D2C226D617070696E6773223A2241414141412C4F41414F432C4941414D442C4F41414F432C4B41414F2C4741433342412C49414149432C4D414151442C4941414943';
wwv_flow_api.g_varchar2_table(6) := '2C4F4141532C4741437A42442C49414149432C4D41414D432C53414157462C49414149432C4D41414D432C554141592C4741453343462C49414149432C4D41414D432C53414153432C6D42414171422C53414153432C47414537432C4D41414D432C4541';
wwv_flow_api.g_varchar2_table(7) := '4151442C4541414F432C4D414366432C4541414F462C4541414F452C4B414570422C47414149442C4541494A2C494141492C49414149452C454141492C45414147412C45414145462C4541414D472C4F414151442C494141492C4341432F422C4D41414D';
wwv_flow_api.g_varchar2_table(8) := '452C454141514A2C4541414D452C47414364472C45414151432C454141452C49414149462C4541414B472C5541477A422C47414149462C4541414D472C534141532C6942414169424C2C53414157452C4541414D462C4F41436A442C5341474A2C4D4141';
wwv_flow_api.g_varchar2_table(9) := '4D4D2C45414157482C454141452C3448414134484C2C4541414B2C73424145704A512C45414151432C474141472C534141532C57414568422C47414441432C4B41414B502C4B41414B412C4541414B472C554141554B2C534141532C4B41414D2C4D4143';

wwv_flow_api.g_varchar2_table(10) := '7243522C4541414B532C754241434A2C494141492C49414149432C454141492C45414147412C45414145562C4541414B532C754241417542562C4F414151572C4941436A44482C4B41414B502C4B41414B412C4541414B532C754241417542432C494141';
wwv_flow_api.g_varchar2_table(11) := '49462C534141532C4B41414D2C5341497245502C4541414D552C53414153412C53414153432C4F41414F502C4B41497643642C49414149432C4D41414D432C534141534F2C4B41414F2C53414153472C4741432F422C49414149522C454141534A2C4941';
wwv_flow_api.g_varchar2_table(12) := '4149432C4D41414D432C534141534F2C4B41414B612C55414155562C474177422F432C4D41414F2C43414348572C69424178426D422C53414153432C4541414F432C4741436E43542C4B41414B552C4F41414F432C4F41415176422C4541414F77422C4F';
wwv_flow_api.g_varchar2_table(13) := '4141512C4341432F42432C4941414B2C754241434C432C4941414B6C422C4541434C6D422C4941414B502C4741434E2C43414343512C514141532C53414153432C474147642C474146416A422C4B41414B502C4B41414B472C474141554B2C534141534F';
wwv_flow_api.g_varchar2_table(14) := '2C4541414F532C4541414B432C6341457443442C4541414B452C6B4241416B4233422C4F414374422C494141492C49414149442C454141492C45414147412C4541414530422C4541414B452C6B4241416B4233422C4F414151442C494141492C43414368';
wwv_flow_api.g_varchar2_table(15) := '442C4941414936422C4541416D42482C4541414B452C6B4241416B4235422C4741433943532C4B41414B502C4B41414B32422C454141694233422C4D41414D512C534141536D422C45414169425A2C4F414F6E452C4F414A47432C47414343412C4B4147';
wwv_flow_api.g_varchar2_table(16) := '472C51415376427A422C49414149432C4D41414D432C534141534F2C4B41414B34422C4F4141532C534141536A432C47414374434A2C49414149432C4D41414D432C534141534F2C4B41414B612C5541415974422C49414149432C4D41414D432C534141';
wwv_flow_api.g_varchar2_table(17) := '534F2C4B41414B612C574141612C4741437A4574422C49414149432C4D41414D432C534141534F2C4B41414B612C554141556C422C4541414F512C554141592C4341436A4467422C4F41415178422C4541414F7742222C2266696C65223A227363726970';
wwv_flow_api.g_varchar2_table(18) := '742E6A73227D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(99010977899685520)
,p_plugin_id=>wwv_flow_api.id(412155278231616931)
,p_file_name=>'js/script.js.map'
,p_mime_type=>'application/json'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2E666F732D706F7075704C4F56207B0A20206D617267696E2D6C6566743A203021696D706F7274616E743B0A7D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(128614601972566464)
,p_plugin_id=>wwv_flow_api.id(412155278231616931)
,p_file_name=>'css/style.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2E666F732D706F7075704C4F567B6D617267696E2D6C6566743A3021696D706F7274616E747D0A2F2A2320736F757263654D617070696E6755524C3D7374796C652E6373732E6D61702A2F';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(128809178070863709)
,p_plugin_id=>wwv_flow_api.id(412155278231616931)
,p_file_name=>'css/style.min.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '7B2276657273696F6E223A332C22736F7572636573223A5B227374796C652E637373225D2C226E616D6573223A5B5D2C226D617070696E6773223A22414141412C612C434143452C7542222C2266696C65223A227374796C652E637373222C22736F7572';
wwv_flow_api.g_varchar2_table(2) := '636573436F6E74656E74223A5B222E666F732D706F7075704C4F56207B5C6E20206D617267696E2D6C6566743A203021696D706F7274616E743B5C6E7D225D7D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(128809436220863711)
,p_plugin_id=>wwv_flow_api.id(412155278231616931)
,p_file_name=>'css/style.css.map'
,p_mime_type=>'application/json'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
prompt --application/end_environment
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done


