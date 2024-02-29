class zcl_gen_data_rap_268 definition
  public
  final
  create public .

  public section.
    interfaces if_oo_adt_classrun.

    "! Method documentation
    "! with multiple lines
    "! @parameter iv_param1 | Pass value for the first parameter
    "! @parameter iv_param2 | Pass value for the second parameter
    methods document_method importing iv_param1 type string
                                      iv_param2 type string.

  protected section.
  private section.
endclass.



class zcl_gen_data_rap_268 implementation.

  method document_method.
  endmethod.

  method if_oo_adt_classrun~main.

    delete from ztravel_268_a.
    "delete from ztravel_268_d.

    insert ztravel_268_a from (
      select from /dmo/travel fields
        uuid( ) as travel_uuid,
        travel_id,
        agency_id,
        customer_id,
        begin_date,
        end_date,
        booking_fee,
        total_price,
        currency_code,
        description,
        case status when 'B' then 'A'
                    when 'P' then 'O'
                    when 'N' then 'O'
                    else 'X' end as overall_status,
        createdby as local_created_by,
        createdat as local_created_at,
        lastchangedby as local_last_changed_by,
        lastchangedat as local_last_changed_at,
        lastchangedat as last_changed_at ).

    out->write( |Travel table.....{ sy-dbcnt } rows inserted| ).


    delete from zbooking_268_a.
    "delete from zbooking_268_d.

    insert zbooking_268_a from (
        select
          from /dmo/booking
            join ztravel_268_a on /dmo/booking~travel_id = ztravel_268_a~travel_id
            join /dmo/travel on /dmo/travel~travel_id = /dmo/booking~travel_id
          fields  "client,
                  uuid( ) as booking_uuid,
                  ztravel_268_a~travel_uuid as parent_uuid,
                  /dmo/booking~booking_id,
                  /dmo/booking~booking_date,
                  /dmo/booking~customer_id,
                  /dmo/booking~carrier_id,
                  /dmo/booking~connection_id,
                  /dmo/booking~flight_date,
                  /dmo/booking~flight_price,
                  /dmo/booking~currency_code,
                  case /dmo/travel~status when 'P' then 'N'
                                                   else /dmo/travel~status end as booking_status,
                  ztravel_268_a~last_changed_at as local_last_changed_at ).

    out->write( |Booking table.....{ sy-dbcnt } rows inserted| ).

    delete from zbksuppl_268_a.
    "delete from zbksuppl_268_d.

    insert zbksuppl_268_a from (
      select from /dmo/book_suppl    as supp
               join ztravel_268_a  as trvl on trvl~travel_id = supp~travel_id
               join zbooking_268_a as book on book~parent_uuid = trvl~travel_uuid
                                            and book~booking_id = supp~booking_id

        fields
          " client
          uuid( )                 as booksuppl_uuid,
          trvl~travel_uuid        as root_uuid,
          book~booking_uuid       as parent_uuid,
          supp~booking_supplement_id,
          supp~supplement_id,
          supp~price,
          supp~currency_code,
          trvl~last_changed_at    as local_last_changed_at ).

    out->write( |Booking Supplements table.....{ sy-dbcnt } rows inserted| ).
  endmethod.
endclass.
