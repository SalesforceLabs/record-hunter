({
    onInit : function(c, e, h){

        // Format API Name Attributes
        const objectName = c.get('v.objectName');
        c.set("v.objectName", objectName.trim().toLowerCase());

        const geolocationFieldName = c.get("v.geolocationFieldName");
        c.set("v.geolocationFieldName", geolocationFieldName.trim().toLowerCase());

        const titleFieldName = c.get("v.titleFieldName");
        c.set("v.titleFieldName", titleFieldName.trim().toLowerCase());

        const descriptionFieldName = c.get("v.descriptionFieldName");
        c.set("v.descriptionFieldName", descriptionFieldName ? descriptionFieldName.trim().toLowerCase() : '');

        const imageURLFieldName = c.get("v.imageURLFieldName");
        c.set("v.imageURLFieldName", imageURLFieldName ? imageURLFieldName.trim().toLowerCase() : '');

        const fieldNamesOrDefaultValues = c.get('v.fieldNamesOrDefaultValues');
        if (fieldNamesOrDefaultValues){
            c.set('v.fieldNamesOrDefaultValues', fieldNamesOrDefaultValues.split(',').reduce(function(prev, value) {
                return prev + (prev ? ',' + value.trim() : value.trim());
            }, ''));
        } else {
            c.set('v.fieldNamesOrDefaultValues', '');
        }


        // Initialize Fields Attributes
        const fieldNames = [c.get("v.geolocationFieldName"), c.get("v.titleFieldName")];
        if (c.get("v.descriptionFieldName")) fieldNames.push(c.get("v.descriptionFieldName"));
        if (c.get("v.imageURLFieldName")) fieldNames.push(c.get("v.imageURLFieldName"));
        h.getFields(c, h, c.get("v.objectName"), fieldNames.join(","))
        .then($A.getCallback(function(fields) {
            if (fields[0].type !== "LOCATION") h.showError(c, h, `'${fields[0].name}' of '${fields[0].objectName}' must be a location type.`);
            if (fields.length >= 4 && fields[3].type !== "URL") h.showError(c, h, `'${fields[3].name}' of '${fields[3].objectName}' must be a URL type.`);

            fields.forEach(function(field, index) {
                field.index = index + 1;
            });

            c.set('v.fields', fields);
        }))
        .catch(function(reason) {
            h.showError(c, h, "controller.onInit: " + reason);
        });


        // Initialize DefaultValues
        // Load the default values through server if recordId exists.
        // Set the values otherwise.
        const recordId = c.get("v.recordId");
        const p_getDefaultValues = recordId ? h.getDefaultValues(c, h, recordId, c.get('v.fieldNamesOrDefaultValues')) : Promise.resolve(c.get('v.fieldNamesOrDefaultValues').split(','));
        p_getDefaultValues
        .then($A.getCallback(function(defaultValues) {
            c.set('v.defaultValues', defaultValues);
        }))
        .catch($A.getCallback(function(reason) {
            h.showError(c, h, 'controller.onInit: ' + reason);
        }));

    },
    onLoad : function(c, e, h){
        // Create a Message Ports
        const channel = new MessageChannel();
        const port = channel.port1;
        c.set('v.port', port);

        // Set Listener for Message Ports
        port.onmessage = function(event) {
            const data = JSON.parse(event.data);
            if (data.type === 'PORT') {
                h.onPort(c, h);
            } else if (data.type === 'NAVIGATE') {
                h.navigateToSObject(c, h, data.id);
            } else if (data.type === 'GEOCODE_RESULT') {
                h.onGeocodeResult(c, h, data.latlng);
            } else if (data.type === 'GOOGLEMAP') {
                h.onGoogleMap(c, h);
            }
        }

        const contentWindow = c.find('iframe').getElement().contentWindow;
        contentWindow.postMessage('', '*', [channel.port2]);

    },
    onSearchResultEvent: function(c, e, h) {
        const order = parseInt(c.get('v.order'));
        const origin = e.getParam('origin');
        const recordIds = e.getParam('recordIds');
        if (origin + 1 === order) {
            const circles = c.get('v.circles');
            if (circles.length) {
                const fields = c.get('v.fields');
                fields[0].latitude = circles[0].center.lat;
                fields[0].longitude =  circles[0].center.lng;
                fields[0].distance =  circles[0].radius / 1000;
                h.filterRecords(c, h, c.get('v.objectName'), JSON.stringify(c.get('v.fields')), JSON.stringify(recordIds), '0 AND 1')
                .then($A.getCallback(function(recordIds) {
                    c.set('v.recordIds', recordIds);
                    h.loadRecords(c, h);
                    h.fireAppEvent(c, h, 'e.c:SearchResult', {
                        recordIds : recordIds,
                        origin: order
                    });
                }))
                .catch($A.getCallback(function(reason) {
                    h.showError(c, h, 'controller.onRecordHunterEvent: ' + reason);
                }));
            } else {
                c.set('v.recordIds', recordIds);
                h.loadRecords(c, h);
                h.fireAppEvent(c, h, 'e.c:SearchResult', {
                    recordIds : recordIds,
                    origin: order
                });
            }
        }
    },


    onLocationChanged : function(c, e, h) {
        // When location is changed, we will;
        // - set the location as the center of the map if the location and radius of the circle is set correctly.
        // - remove the circle from the map if location is not set.
        const location = c.get('v.location');
        if (location) {
            c.get('v.port').postMessage(JSON.stringify({type: 'GEOCODE', location: location}));
        } else {
            h.updateCircles(c, h);
        }
    },
    onDistanceChanged : function(c, e, h) {
        h.updateCircles(c, h);
    },
    onCenterChanged: function(c, e, h) {
        c.get('v.port').postMessage(JSON.stringify({
            type: 'UPDATE',
            center: c.get('v.center'),
        }));
    },
    onMarkersChanged: function(c, e, h) {
        c.get('v.port').postMessage(JSON.stringify({
            type: 'UPDATE',
            markers: c.get('v.markers'),
        }));
    },
    onCirclesChanged: function(c, e, h) {
        c.get('v.port').postMessage(JSON.stringify({
            type: 'UPDATE',
            circles: c.get('v.circles')
        }));
    },
})