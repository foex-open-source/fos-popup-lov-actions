window.FOS = window.FOS || {};
FOS.utils = FOS.utils || {};
FOS.utils.popupLOV = FOS.utils.popupLOV || {};

FOS.utils.popupLOV.addClearItemButton = function(config){

    const items = config.items;
    const icon = config.icon;

    if(!items){
        return;
    }

    for(let i = 0; i<items.length; i++){
        const item  = items[i];
        const item$ = $('#'+item.itemName);

        //skip readonly or not rendered items
        if (item$.siblings('.display_only').length || !item$.length){
            continue;
        }

        const button$  = $('<button title="Clear Value" type="button" class="a-Button a-Button--popupLOV fos-popupLOV" tabindex="-1"><span class="fa '+icon+'"></span></button>');

        button$.on('click', function(){
            apex.item(item.itemName).setValue(null, null);
            if(item.additionalOutputsItems){
                for(let j = 0; j<item.additionalOutputsItems.length; j++){
                    apex.item(item.additionalOutputsItems[j]).setValue(null, null);
                }
            }
        });
        item$.parent().parent().append(button$);
    }
};

FOS.utils.popupLOV.item = function(itemName){
    var config = FOS.utils.popupLOV.item.instances[itemName];
    var setValueByReturn = function(value, callback){
        apex.server.plugin (config.ajaxId, {
            x01: 'GET_VALUES_BY_RETURN',
            x02: itemName,
            x03: value
        }, {
            success: function(data){
                apex.item(itemName).setValue(value, data.displayValue);

                if(data.additionalOutputs.length){
                    for(var i = 0; i<data.additionalOutputs.length; i++){
                        var additionalOutput = data.additionalOutputs[i];
                        apex.item(additionalOutput.item).setValue(additionalOutput.value);
                    }
                }
                if(callback){
                    callback();
                }

                return true;
            }
        });
    };
    return {
        setValueByReturn: setValueByReturn
    };
};

FOS.utils.popupLOV.item.create = function(config){
    FOS.utils.popupLOV.item.instances = FOS.utils.popupLOV.item.instances || {};
    FOS.utils.popupLOV.item.instances[config.itemName] = {
        ajaxId: config.ajaxId
    };
};

