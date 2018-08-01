/* global bootstrap_dialog modal_options */
var planningsShow = function(params) {
  'use strict';

  var templateVehicle = function(vehicle) {
    if (vehicle.id)
      return $("<span><span class='color_small' style='background: " + params.vehicles[parseInt(vehicle.id)].color + "'></span>&nbsp;</span>").append($("<span/>").text(vehicle.text));
  };

  var getSelectedVisits = function() {
    return $('#visits').find('input:checkbox:visible:checked');
  };

  var getSelectedPlannings = function(objName) {
    var visits = getSelectedVisits();
    var list = [];
    for (var index = 0; index < visits.length; index++) {
      if (!list[$(visits[index]).data('planning')]) list[$(visits[index]).data('planning')] = [];
      list[$(visits[index]).data('planning')].push($(visits[index]).data(objName));
    }
    return list;
  };

  var movedDestinations;
  var countMovedDestinations = function(max) {
    movedDestinations++;
    console.log('movedDestinations : ' + movedDestinations + ', max : ' + max)
    if (movedDestinations == max) location.href = '';
  };

  $('#vehicle_id').select2({
    templateSelection: templateVehicle,
    templateResult: templateVehicle
  }).change(function() {
    var vehicleId = parseInt($(this).val());
    bootstrap_dialog($.extend(modal_options(), {
      title: I18n.t('plannings.edit.dialog.move_destinations.title'),
      message: SMT['modals/default_with_progress']({
        msg: I18n.t('plannings.edit.dialog.move_destinations.in_progress')
      })
    })).modal({ keyboard: false, show: true });

    movedDestinations = 0;
    var selectedPlannings = getSelectedPlannings('visit');
    console.log(selectedPlannings)
    selectedPlannings.forEach(function(stopIds, planningId) {
      var routeId = params.routesByVehicles[planningId][vehicleId];
      $.ajax({
        type: 'PATCH',
        dataType: 'json',
        url: '/api/0.1/plannings/' + planningId + '/routes/' + routeId + '/visits/moves',
        data: { 'visit_ids': stopIds },
        beforeSend: beforeSendWaiting,
        error: ajaxError,
        success: function() { countMovedDestinations(Object.keys(selectedPlannings).length); }
      });
    });
  });

  $('#automatic-insert').click(function() {
    bootstrap_dialog($.extend(modal_options(), {
      title: I18n.t('plannings.edit.dialog.automatic_insert.title'),
      message: SMT['modals/default_with_progress']({
        msg: I18n.t('plannings.edit.dialog.automatic_insert.in_progress')
      })
    })).modal({ keyboard: false, show: true });

    movedDestinations = 0;
    var selectedPlannings = getSelectedPlannings('stop');
    selectedPlannings.forEach(function(stopIds, planningId) {
      $.ajax({
        type: 'PATCH',
        dataType: 'json',
        url: '/api/0.1/plannings/' + planningId + '/automatic_insert',
        data: { 'stop_ids': stopIds },
        beforeSend: beforeSendWaiting,
        error: ajaxError,
        success: function() { countMovedDestinations(Object.keys(selectedPlannings).length); }
      });
    });
  });
};

Paloma.controller('PlanningsByDestination', {
  show: function() {
    planningsShow(this.params);
  }
});
