class lhc_Travel definition inheriting from cl_abap_behavior_handler.
  private section.

    constants:
      begin of travel_status,
        open     type c length 1 value 'O', "Open
        accepted type c length 1 value 'A', "Accepted
        rejected type c length 1 value 'X', "Rejected
      end of travel_status.

    methods get_instance_features for instance features
      importing keys request requested_features for Travel result result.

    methods get_instance_authorizations for instance authorization
      importing keys request requested_authorizations for Travel result result.

    methods get_global_authorizations for global authorization
      importing request requested_authorizations for Travel result result.

    methods acceptTravel for modify
      importing keys for action Travel~acceptTravel result result.

    methods deductDiscount for modify
      importing keys for action Travel~deductDiscount result result.

    methods reCalcTotalPrice for modify
      importing keys for action Travel~reCalcTotalPrice.

    methods rejectTravel for modify
      importing keys for action Travel~rejectTravel result result.

    methods Resume for modify
      importing keys for action Travel~Resume.

    methods calculateTotalPrice for determine on modify
      importing keys for Travel~calculateTotalPrice.

    methods setStatusToOpen for determine on modify
      importing keys for Travel~setStatusToOpen.

    methods setTravelNumber for determine on save
      importing keys for Travel~setTravelNumber.

    methods validateAgency for validate on save
      importing keys for Travel~validateAgency.

    methods validateCurrencyCode for validate on save
      importing keys for Travel~validateCurrencyCode.

    methods validateCustomer for validate on save
      importing keys for Travel~validateCustomer.

    methods validateDates for validate on save
      importing keys for Travel~validateDates.

endclass.

class lhc_Travel implementation.

  method get_instance_features.

    read entities of zr_travel_268 in local mode
    entity Travel
      fields ( OverallStatus )
      with corresponding #( keys )
    result data(travels)
    failed failed.


    result = value #( for ls_travel in travels
                          ( %tky                   = ls_travel-%tky

                            %field-BookingFee      = cond #( when ls_travel-OverallStatus = travel_status-accepted
                                                             then if_abap_behv=>fc-f-read_only
                                                             else if_abap_behv=>fc-f-unrestricted )
                            %action-acceptTravel   = cond #( when ls_travel-OverallStatus = travel_status-accepted
                                                             then if_abap_behv=>fc-o-disabled
                                                             else if_abap_behv=>fc-o-enabled )
                            %action-rejectTravel   = cond #( when ls_travel-OverallStatus = travel_status-rejected
                                                             then if_abap_behv=>fc-o-disabled
                                                             else if_abap_behv=>fc-o-enabled )
                            %action-deductDiscount = cond #( when ls_travel-OverallStatus = travel_status-accepted
                                                             then if_abap_behv=>fc-o-disabled
                                                             else if_abap_behv=>fc-o-enabled )
                            %assoc-_Booking        = cond #( when ls_travel-OverallStatus = travel_status-rejected
                                                            then if_abap_behv=>fc-o-disabled
                                                            else if_abap_behv=>fc-o-enabled )
                          ) ).


  endmethod.

  method get_instance_authorizations.

    data: update_requested type abap_bool,
          delete_requested type abap_bool,
          update_granted   type abap_bool,
          delete_granted   type abap_bool.

    read entities of zr_travel_268 in local mode
      entity Travel
        fields ( AgencyID )
        with corresponding #( keys )
        result data(travels)
        failed failed.

    check travels is not initial.

    "Decide business check
    data(lv_technical_user) = cl_abap_context_info=>get_user_technical_name(  ).

    update_requested = cond #( when requested_authorizations-%update      = if_abap_behv=>mk-on
                                 or requested_authorizations-%action-Edit = if_abap_behv=>mk-on
                               then abap_true else abap_false ).

    delete_requested = cond #( when requested_authorizations-%delete      = if_abap_behv=>mk-on
                               then abap_true else abap_false ).


    loop at travels into data(travel).

      if travel-AgencyID is not initial.

        "Business check
        if lv_technical_user eq 'CB9980007990' and travel-AgencyID ne '70025'. "WHAT EVER.
          update_granted = abap_true.
          delete_granted = abap_true.
        else.
          update_granted = delete_granted = abap_false.
*           = abap_false.
        endif.


        "check for update
        if update_requested = abap_true.

          if update_granted = abap_false.
            append value #( %tky = travel-%tky
                            %msg = new /dmo/cm_flight_messages(
                                                     textid    = /dmo/cm_flight_messages=>not_authorized_for_agencyid
                                                     agency_id = travel-AgencyID
                                                     severity  = if_abap_behv_message=>severity-error )
                            %element-AgencyID = if_abap_behv=>mk-on
                           ) to reported-travel.
          endif.
        endif.

        "check for delete
        if delete_requested = abap_true.

          if delete_granted = abap_false.
            append value #( %tky = travel-%tky
                            %msg = new /dmo/cm_flight_messages(
                                     textid   = /dmo/cm_flight_messages=>not_authorized_for_agencyid
                                     agency_id = travel-AgencyID
                                     severity = if_abap_behv_message=>severity-error )
                            %element-AgencyID = if_abap_behv=>mk-on
                           ) to reported-travel.
          endif.
        endif.

        " operations on draft instances and on active instances
        " new created instances
      else.
        update_granted = delete_granted = abap_true. "REPLACE ME WITH BUSINESS CHECK
        if update_granted = abap_false.
          append value #( %tky = travel-%tky
                          %msg = new /dmo/cm_flight_messages(
                                   textid   = /dmo/cm_flight_messages=>not_authorized
                                   severity = if_abap_behv_message=>severity-error )
                          %element-AgencyID = if_abap_behv=>mk-on
                        ) to reported-travel.
        endif.
      endif.

      append value #( let upd_auth = cond #( when update_granted = abap_true
                                             then if_abap_behv=>auth-allowed
                                             else if_abap_behv=>auth-unauthorized )
                          del_auth = cond #( when delete_granted = abap_true
                                             then if_abap_behv=>auth-allowed
                                             else if_abap_behv=>auth-unauthorized )
                      in
                       %tky = travel-%tky
                       %update                = upd_auth
                       %action-Edit           = upd_auth

                       %delete                = del_auth
                    ) to result.
    endloop.

  endmethod.

  method get_global_authorizations.

*    check 1 = 2.
*
*    data(lv_technical_user) = cl_abap_context_info=>get_user_technical_name(  ).
*
*    if requested_authorizations-%create eq if_abap_behv=>mk-on.
*
*      if lv_technical_user eq 'CB9980007990'.
*        result-%create = if_abap_behv=>auth-allowed.
*      else.
*        result-%create = if_abap_behv=>auth-unauthorized.
*
*        append value #( %msg = new /dmo/cm_flight_messages(
*                                      textid = /dmo/cm_flight_messages=>not_authorized
*                                      severity = if_abap_behv_message=>severity-error )
*                         %global = if_abap_behv=>mk-on ) to reported-travel.
*      endif.
*
*    endif.
*
*    if requested_authorizations-%update      eq if_abap_behv=>mk-on or
*       requested_authorizations-%action-Edit eq if_abap_behv=>mk-on.
*
*      if lv_technical_user eq 'CB9980007990'.
*        result-%update = if_abap_behv=>auth-allowed.
*        result-%action-Edit = if_abap_behv=>auth-allowed.
*      else.
*        result-%update = if_abap_behv=>auth-unauthorized.
*        result-%action-Edit = if_abap_behv=>auth-unauthorized.
*
*        append value #( %msg = new /dmo/cm_flight_messages(
*                                      textid = /dmo/cm_flight_messages=>not_authorized
*                                      severity = if_abap_behv_message=>severity-error )
*                         %global = if_abap_behv=>mk-on ) to reported-travel.
*      endif.
*
*
*    endif.
*
*    if requested_authorizations-%delete eq if_abap_behv=>mk-on.
*
*      if lv_technical_user eq 'CB9980007990'.
*        result-%delete = if_abap_behv=>auth-allowed.
*      else.
*        result-%delete = if_abap_behv=>auth-unauthorized.
*
*        append value #( %msg = new /dmo/cm_flight_messages(
*                                      textid = /dmo/cm_flight_messages=>not_authorized
*                                      severity = if_abap_behv_message=>severity-error )
*                         %global = if_abap_behv=>mk-on ) to reported-travel.
*      endif.
*
*    endif.

  endmethod.

  method acceptTravel.

    "Modify travel instance
    modify entities of zr_travel_268 in local mode
      entity Travel
        update fields (  OverallStatus )
        with value #( for key in keys ( %tky          = key-%tky
                                        OverallStatus = travel_status-accepted ) ).

    "Read changed data for action result
    read entities of zr_travel_268 in local mode
      entity Travel
        all fields with
        corresponding #( keys )
      result data(travels).

    result = value #( for travel in travels ( %tky   = travel-%tky
                                              %param = travel ) ).

  endmethod.

  method deductDiscount.
  endmethod.

  method reCalcTotalPrice.
  endmethod.

  method rejectTravel.

    "Modify travel instance
    modify entities of zr_travel_268 in local mode
      entity Travel
        update fields (  OverallStatus )
        with value #( for key in keys ( %tky          = key-%tky
                                        OverallStatus = travel_status-rejected ) ).

    "Read changed data for action result
    read entities of zr_travel_268 in local mode
      entity Travel
        all fields with
        corresponding #( keys )
      result data(travels).

    result = value #( for travel in travels ( %tky   = travel-%tky
                                              %param = travel ) ).

  endmethod.

  method Resume.
  endmethod.

  method calculateTotalPrice.
  endmethod.

  method setStatusToOpen.
  endmethod.

  method setTravelNumber.
  endmethod.

  method validateAgency.
  endmethod.

  method validateCurrencyCode.
  endmethod.

  method validateCustomer.
  endmethod.

  method validateDates.
  endmethod.

endclass.
