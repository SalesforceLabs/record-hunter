({
    startFlow: function(c, h, flowName, inputVariables) {
        $A.createComponent(
            "lightning:flow", {
                'aura:id': 'flow',
                'onstatuschange': c.getReference('c.onFlowStatusChanged')
            }, function(flow, status, errorMessage){
                if (status === "SUCCESS") {
                    c.set('v.flowComponents', [flow]);
                    flow.startFlow(flowName, inputVariables);
                } else if (status === "INCOMPLETE") {
                    h.showError(c, h, 'controller.startFlow : No response from server or client is offline.');
                } else if (status === "ERROR") {
                    h.showError(c, h, 'controller.startFlow : ' + errorMessage);
                }
            }
        );
    },
    initFlowComponent: function(c, h) {
        const name = 'lightning:flow';
        const attributes = {
            'aura:id': 'flow',
            'onstatuschange': c.getReference('c.onFlowStatusChanged')
        };
        return new Promise(function (resolve, reject) {
            $A.createComponent(name, attributes, function(cmp, status, error) {
                if (status === "SUCCESS") resolve(cmp);
                else if (status === "INCOMPLETE") reject('No response from server or client is offline.');
                    else if (status === "ERROR") reject(error);
            });
        });
    },
    getRecord : function(c, h, recordId) {
        const action = c.get('c.getRecord');
        action.setParams({
            recordId : recordId,
        });
        return new Promise(function (resolve, reject) {
            action.setCallback(this, function(response) {
                const ret = response.getReturnValue();
                if (response.getState() === 'SUCCESS') ret.hasError ? reject(ret.message) : resolve(ret);
                else if (response.getState() === 'ERROR') reject(response.getError());
            });
            $A.enqueueAction(action);
        });
    },
    getRecords : function(c, h, recordIds) {
        const action = c.get('c.getRecords');
        action.setParams({
            recordIds : recordIds,
        });
        return new Promise(function (resolve, reject) {
            action.setCallback(this, function(response) {
                const ret = response.getReturnValue();
                if (response.getState() === 'SUCCESS') ret.hasError ? reject(ret.message) : resolve(ret);
                else if (response.getState() === 'ERROR') reject(response.getError());
            });
            $A.enqueueAction(action);
        });
    },
    showSuccessToast: function(c, h, message) {
        $A.get('e.force:showToast').setParams({
            type: 'success',
            mode : 'pester',
            message: message,
            duration: 3000
        }).fire();
    },
    showError: function(c, h, message) {
        const isOnAppBuilder = document.location.href.toLowerCase().indexOf('flexipageeditor') >= 0;
        if (isOnAppBuilder) {
            console.error(message);
            c.set('v.errorMessage', message);
        } else {
            const toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                type: 'error',
                mode : 'sticky',
                message: message,
            });
            toastEvent.fire();
        }
    }
})