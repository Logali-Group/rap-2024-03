@EndUserText.label: 'Interfaces Booking Supplement'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZI_BKSUPPL_268

  as projection on ZR_BKSUPPL_268
  
{
  key BooksupplUUID,
      TravelUUID,
      BookingUUID,
      BookingSupplementID,
      SupplementID,
      BookSupplPrice,
      CurrencyCode,
      LocalLastChangedAt,
      /* Associations */
      _Booking : redirected to parent ZI_BOOKING_268,
      _Product,
      _SupplementText,
      _Travel  : redirected to ZI_TRAVEL_268
}
