class lhc_BookingSupplement definition inheriting from cl_abap_behavior_handler.
  private section.

    methods calculateTotalPrice for determine on modify
      importing keys for BookingSupplement~calculateTotalPrice.

    methods setBookSupplNumber for determine on save
      importing keys for BookingSupplement~setBookSupplNumber.

    methods validateCurrencyCode for validate on save
      importing keys for BookingSupplement~validateCurrencyCode.

    methods validateSupplement for validate on save
      importing keys for BookingSupplement~validateSupplement.

endclass.

class lhc_BookingSupplement implementation.

  method calculateTotalPrice.
  endmethod.

  method setBookSupplNumber.
  endmethod.

  method validateCurrencyCode.
  endmethod.

  method validateSupplement.
  endmethod.

endclass.
