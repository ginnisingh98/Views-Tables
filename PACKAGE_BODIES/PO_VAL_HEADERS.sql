--------------------------------------------------------
--  DDL for Package Body PO_VAL_HEADERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_VAL_HEADERS" AS
-- $Header: PO_VAL_HEADERS.plb 120.5.12010000.11 2012/02/29 01:14:35 yuewliu ship $

c_entity_type_HEADER CONSTANT VARCHAR2(30) := PO_VALIDATIONS.c_entity_type_HEADER;

c_AGENT_ID CONSTANT VARCHAR2(30) := 'AGENT_ID';
c_AMOUNT_LIMIT CONSTANT VARCHAR2(30) := 'AMOUNT_LIMIT';
c_BLANKET_TOTAL_AMOUNT CONSTANT VARCHAR2(30) := 'BLANKET_TOTAL_AMOUNT';
c_END_DATE CONSTANT VARCHAR2(30) := 'END_DATE';
c_PRICE_UPDATE_TOLERANCE CONSTANT VARCHAR2(30) := 'PRICE_UPDATE_TOLERANCE';
c_RATE CONSTANT VARCHAR2(30) := 'RATE';
c_SEGMENT1 CONSTANT VARCHAR2(30) := 'SEGMENT1';
c_START_DATE CONSTANT VARCHAR2(30) := 'START_DATE';
c_VENDOR_ID CONSTANT VARCHAR2(30) := 'VENDOR_ID';
c_SHIP_TO_LOCATION_ID CONSTANT VARCHAR2(30) := 'SHIP_TO_LOCATION_ID';
c_VENDOR_SITE_ID CONSTANT VARCHAR2(30) := 'VENDOR_SITE_ID';
c_RATE_TYPE CONSTANT VARCHAR2(30) := 'RATE_TYPE';
c_RATE_DATE CONSTANT VARCHAR2(30) := 'RATE_DATE';
c_EMAIL_ADDRESS CONSTANT VARCHAR2(30) := 'EMAIL_ADDRESS';
c_FAX CONSTANT VARCHAR2(30) := 'FAX';

c_BLANKET CONSTANT VARCHAR2(30) := 'BLANKET';
c_CONTRACT CONSTANT VARCHAR2(30) := 'CONTRACT';
c_FINALLY_CLOSED CONSTANT VARCHAR2(30) := 'FINALLY CLOSED';
c_MANUAL CONSTANT VARCHAR2(30) := 'MANUAL';
c_NUMERIC CONSTANT VARCHAR2(30) := 'NUMERIC';
c_PLANNED CONSTANT VARCHAR2(30) := 'PLANNED';
c_PO CONSTANT VARCHAR2(30) := 'PO';
c_STANDARD CONSTANT VARCHAR2(30) := 'STANDARD';
c_SUCCESS CONSTANT VARCHAR2(30) := 'SUCCESS';
c_User CONSTANT VARCHAR2(30) := 'User';
c_EMAIL CONSTANT VARCHAR2(30) := 'EMAIL';

-- The module base for this package.
D_PACKAGE_BASE CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_VAL_HEADERS');

-- The module base for the subprogram.
D_price_update_tol_ge_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'price_update_tol_ge_zero');

D_amount_limit_ge_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'amount_limit_ge_zero');

D_amt_limit_ge_amt_agreed CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'amt_limit_ge_amt_agreed');

D_amount_agreed_ge_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'amount_agreed_ge_zero');

D_amount_agreed_not_null CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'amount_agreed_not_null');

D_warn_supplier_on_hold CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'warn_supplier_on_hold');

D_rate_gt_zero CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'rate_gt_zero');

D_fax_email_address_valid CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'fax_email_address_valid');

D_rate_combination_valid CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'rate_combination_valid');

D_effective_le_expiration CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'effective_le_expiration');

D_effective_from_le_order_date CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'effective_from_le_order_date');

D_effective_to_ge_order_date CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'effective_to_ge_order_date');

D_contract_start_le_order_date CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'contract_start_le_order_date');

D_contract_end_ge_order_date CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'contract_end_ge_order_date');

D_doc_num_chars_valid CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'doc_num_chars_valid');

D_doc_num_unique CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'doc_num_unique');

D_check_agreement_dates CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'check_agreement_dates');

D_agent_id_not_null CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'agent_id_not_null');
D_ship_to_loc_not_null CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'ship_to_loc_not_null');
D_vendor_id_not_null CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'vendor_id_not_null');
D_vendor_site_id_not_null CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'vendor_site_id_not_null');
D_segment1_not_null CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'segment1_not_null');
D_ship_via_lookup_code_valid CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'ship_via_lookup_code_valid');

---------------------------------------------------------------------------
-- Checks that the Price Update Tolerance is greater than or equal to zero.
-- Agreements only.
---------------------------------------------------------------------------
PROCEDURE price_update_tol_ge_zero(
  p_header_id_tbl         IN  PO_TBL_NUMBER
, p_price_update_tol_tbl  IN  PO_TBL_NUMBER
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.greater_or_equal_zero(
  p_calling_module => D_price_update_tol_ge_zero
, p_null_allowed_flag => PO_CORE_S.g_parameter_YES
, p_value_tbl => p_price_update_tol_tbl
, p_entity_id_tbl => p_header_id_tbl
, p_entity_type => c_entity_type_HEADER
, p_column_name => c_PRICE_UPDATE_TOLERANCE
, p_message_name => PO_MESSAGE_S.PO_ALL_ENTER_VALUE_GE_ZERO
, x_results => x_results
, x_result_type => x_result_type
);

END price_update_tol_ge_zero;


---------------------------------------------------------------------------
-- Checks that the Amount Limit is greater than or equal to zero.
-- Agreements only.
---------------------------------------------------------------------------
PROCEDURE amount_limit_ge_zero(
  p_header_id_tbl     IN  PO_TBL_NUMBER
, p_amount_limit_tbl  IN  PO_TBL_NUMBER
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.greater_or_equal_zero(
  p_calling_module => D_amount_limit_ge_zero
, p_null_allowed_flag => PO_CORE_S.g_parameter_YES
, p_value_tbl => p_amount_limit_tbl
, p_entity_id_tbl => p_header_id_tbl
, p_entity_type => c_entity_type_HEADER
, p_column_name => c_AMOUNT_LIMIT
, p_message_name => PO_MESSAGE_S.PO_ALL_ENTER_VALUE_GE_ZERO
, x_results => x_results
, x_result_type => x_result_type
);

END amount_limit_ge_zero;


---------------------------------------------------------------------------
-- Checks that the Amount Limit is greater than or equal to the Amount Agreed.
-- Agreements only.
---------------------------------------------------------------------------
PROCEDURE amt_limit_ge_amt_agreed(
  p_header_id_tbl     IN  PO_TBL_NUMBER
, p_blanket_total_amount_tbl  IN  PO_TBL_NUMBER
, p_amount_limit_tbl  IN  PO_TBL_NUMBER
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.num1_less_or_equal_num2(
  p_calling_module => D_amt_limit_ge_amt_agreed
, p_num1_tbl => p_blanket_total_amount_tbl
, p_num2_tbl => p_amount_limit_tbl
, p_entity_id_tbl => p_header_id_tbl
, p_entity_type => c_entity_type_HEADER
, p_column_name => c_AMOUNT_LIMIT
, p_message_name => PO_MESSAGE_S.PO_PO_AMT_LIMIT_CK_FAILED
, x_results => x_results
, x_result_type => x_result_type
);

END amt_limit_ge_amt_agreed;


---------------------------------------------------------------------------
-- Checks that the Amount Agreed is greater than or equal to zero.
-- Agreements only.
---------------------------------------------------------------------------
PROCEDURE amount_agreed_ge_zero(
  p_header_id_tbl     IN  PO_TBL_NUMBER
, p_blanket_total_amount_tbl  IN  PO_TBL_NUMBER
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.greater_or_equal_zero(
  p_calling_module => D_amount_agreed_ge_zero
, p_null_allowed_flag => PO_CORE_S.g_parameter_YES
, p_value_tbl => p_blanket_total_amount_tbl
, p_entity_id_tbl => p_header_id_tbl
, p_entity_type => c_entity_type_HEADER
, p_column_name => c_BLANKET_TOTAL_AMOUNT
, p_message_name => PO_MESSAGE_S.PO_ALL_ENTER_VALUE_GE_ZERO
, x_results => x_results
, x_result_type => x_result_type
);

END amount_agreed_ge_zero;


---------------------------------------------------------------------------
-- Checks that the Amount Agreed is not null if Amount Limit is not null.
-- Agreements only.
---------------------------------------------------------------------------
PROCEDURE amount_agreed_not_null(
  p_header_id_tbl     IN  PO_TBL_NUMBER
, p_blanket_total_amount_tbl  IN  PO_TBL_NUMBER
, p_amount_limit_tbl  IN  PO_TBL_NUMBER
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_amount_agreed_not_null;
l_results_count NUMBER;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_header_id_tbl',p_header_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_blanket_total_amount_tbl',p_blanket_total_amount_tbl);
  PO_LOG.proc_begin(d_mod,'p_amount_limit_tbl',p_amount_limit_tbl);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

l_results_count := x_results.result_type.COUNT;

FOR i IN 1 .. p_header_id_tbl.COUNT LOOP
  IF (  p_amount_limit_tbl(i) IS NOT NULL
    AND p_blanket_total_amount_tbl(i) IS NULL
    )
  THEN
    x_results.add_result(
      p_entity_type => c_entity_type_HEADER
    , p_entity_id => p_header_id_tbl(i)
    , p_column_name => c_BLANKET_TOTAL_AMOUNT
    , p_message_name => PO_MESSAGE_S.PO_AMT_LMT_NOT_NULL
    );
  END IF;
END LOOP;

IF (l_results_count < x_results.result_type.COUNT) THEN
  x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
ELSE
  x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
END IF;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
  PO_LOG.log(PO_LOG.c_PROC_END,d_mod,NULL,'x_results',x_results);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
  END IF;
  RAISE;

END amount_agreed_not_null;


---------------------------------------------------------------------------
-- Display a warning message if the supplier is on hold.
---------------------------------------------------------------------------
PROCEDURE warn_supplier_on_hold(
  p_header_id_tbl     IN  PO_TBL_NUMBER
, p_vendor_id_tbl     IN  PO_TBL_NUMBER
, x_result_set_id     IN OUT NOCOPY NUMBER
, x_result_type       OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_warn_supplier_on_hold;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_header_id_tbl',p_header_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_vendor_id_tbl',p_vendor_id_tbl);
  PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
END IF;

IF (x_result_set_id IS NULL) THEN
  x_result_set_id := PO_VALIDATIONS.next_result_set_id();
END IF;

FORALL i IN 1 .. p_header_id_tbl.COUNT
INSERT INTO PO_VALIDATION_RESULTS_GT
( result_set_id
, result_type
, entity_type
, entity_id
, column_name
, column_val
, message_name
)
SELECT
  x_result_set_id
, PO_VALIDATIONS.c_result_type_WARNING
, c_entity_type_HEADER
, p_header_id_tbl(i)
, c_VENDOR_ID
, TO_CHAR(p_vendor_id_tbl(i))
, PO_MESSAGE_S.PO_PO_VENDOR_ON_HOLD
FROM
  PO_VENDORS SUPPLIER
WHERE
    SUPPLIER.vendor_id = p_vendor_id_tbl(i)
AND SUPPLIER.hold_flag = 'Y'
;

IF(SQL%ROWCOUNT > 0) THEN
  x_result_type := PO_VALIDATIONS.c_result_type_WARNING;
ELSE
  x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
END IF;

IF PO_LOG.d_proc THEN
  PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
  PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
  PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
  END IF;
  RAISE;

END warn_supplier_on_hold;


---------------------------------------------------------------------------
-- Checks that the Rate is greater than zero.
-- For Rate Type of User, the Rate is also required (not null),
-- but that is handled elsewhere (in the UI).
---------------------------------------------------------------------------
PROCEDURE rate_gt_zero(
  p_header_id_tbl     IN  PO_TBL_NUMBER
, p_rate_tbl          IN  PO_TBL_NUMBER
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.greater_than_zero(
  p_calling_module => D_rate_gt_zero
, p_null_allowed_flag => PO_CORE_S.g_parameter_YES
, p_value_tbl => p_rate_tbl
, p_entity_id_tbl => p_header_id_tbl
, p_entity_type => c_entity_type_HEADER
, p_column_name => c_RATE
, p_message_name => PO_MESSAGE_S.PO_ALL_ENTER_VALUE_GT_ZERO
, x_results => x_results
, x_result_type => x_result_type
);

END rate_gt_zero;


---------------------------------------------------------------------------
-- Checks the following are not null, if the currency is different from the
-- functional currency:
-- 1. Rate Type
-- 2. Rate Date
-- 3. Rate
---------------------------------------------------------------------------
PROCEDURE rate_combination_valid(
  p_header_id_tbl     IN  PO_TBL_NUMBER
, p_org_id_tbl        IN  PO_TBL_NUMBER
, p_currency_code_tbl IN  PO_TBL_VARCHAR30
, p_rate_type_tbl     IN  PO_TBL_VARCHAR30
, p_rate_date_tbl     IN  PO_TBL_DATE
, p_rate_tbl          IN  PO_TBL_NUMBER
, x_results           IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type       OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_rate_combination_valid;
l_results_count NUMBER;
l_func_currency_code GL_SETS_OF_BOOKS.currency_code%TYPE;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_header_id_tbl',p_header_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_org_id_tbl',p_org_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_currency_code_tbl',p_currency_code_tbl);
  PO_LOG.proc_begin(d_mod,'p_rate_type_tbl',p_rate_type_tbl);
  PO_LOG.proc_begin(d_mod,'p_rate_date_tbl',p_rate_date_tbl);
  PO_LOG.proc_begin(d_mod,'p_rate_tbl',p_rate_tbl);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

l_results_count := x_results.result_type.COUNT;

FOR i IN 1 .. p_header_id_tbl.COUNT LOOP

  SELECT
    BOOKS.currency_code
  INTO
    l_func_currency_code
  FROM
    FINANCIALS_SYSTEM_PARAMS_ALL FIN_PARAMS
  , GL_SETS_OF_BOOKS BOOKS
  WHERE
      FIN_PARAMS.org_id = p_org_id_tbl(i)
  AND BOOKS.set_of_books_id = FIN_PARAMS.set_of_books_id
  ;

  IF (p_currency_code_tbl(i) <> l_func_currency_code OR p_currency_code_tbl(i) IS NULL) THEN

    IF (p_rate_type_tbl(i) IS NULL) THEN
      x_results.add_result(
        p_entity_type => c_entity_type_HEADER
      , p_entity_id => p_header_id_tbl(i)
      , p_column_name => c_RATE_TYPE
      , p_message_name => PO_MESSAGE_S.PO_ALL_NOT_NULL
      );
    END IF;

    IF (p_rate_date_tbl(i) IS NULL) THEN
      x_results.add_result(
        p_entity_type => c_entity_type_HEADER
      , p_entity_id => p_header_id_tbl(i)
      , p_column_name => c_RATE_DATE
      , p_message_name => PO_MESSAGE_S.PO_ALL_NOT_NULL
      );
    END IF;

    IF (p_rate_type_tbl(i) <> c_User AND p_rate_tbl(i) IS NULL) THEN
      x_results.add_result(
        p_entity_type => c_entity_type_HEADER
      , p_entity_id => p_header_id_tbl(i)
      , p_column_name => NULL
      , p_message_name => PO_MESSAGE_S.PO_HTML_NO_RATE_DEFINED
      );
    ELSIF (p_rate_tbl(i) IS NULL) THEN
      x_results.add_result(
        p_entity_type => c_entity_type_HEADER
      , p_entity_id => p_header_id_tbl(i)
      , p_column_name => c_RATE
      , p_message_name => PO_MESSAGE_S.PO_ALL_NOT_NULL
      );
    END IF;

  END IF;

END LOOP;

IF (l_results_count < x_results.result_type.COUNT) THEN
  x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
ELSE
  x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
END IF;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
  PO_LOG.log(PO_LOG.c_PROC_END,d_mod,NULL,'x_results',x_results);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
  END IF;
  RAISE;

END rate_combination_valid;


---------------------------------------------------------------------------
-- Checks that email address is not null if supplier notification method
-- is email and that fax number is not null if supplier notification method
-- is fax.
---------------------------------------------------------------------------
PROCEDURE fax_email_address_valid(
  p_header_id_tbl                    IN     PO_TBL_NUMBER
, p_supplier_notif_method_tbl        IN     PO_TBL_VARCHAR30
, p_fax_tbl                          IN     PO_TBL_VARCHAR30
, p_email_address_tbl                IN     PO_TBL_VARCHAR2000
, x_results                          IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type                      OUT    NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_fax_email_address_valid;
l_results_count NUMBER;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_header_id_tbl',p_header_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_supplier_notif_method_tbl',p_supplier_notif_method_tbl);
  PO_LOG.proc_begin(d_mod,'p_email_address_tbl',p_email_address_tbl);
  PO_LOG.proc_begin(d_mod,'p_fax_tbl',p_fax_tbl);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

l_results_count := x_results.result_type.COUNT;

FOR i IN 1 .. p_header_id_tbl.COUNT LOOP

  IF ((p_supplier_notif_method_tbl(i) = c_EMAIL) AND
      (p_email_address_tbl(i) IS NULL)) THEN
    x_results.add_result(
      p_entity_type => c_entity_type_HEADER
    , p_entity_id => p_header_id_tbl(i)
    , p_column_name => c_EMAIL_ADDRESS
    , p_message_name => PO_MESSAGE_S.PO_ALL_NOT_NULL
    );
  ELSIF ((p_supplier_notif_method_tbl(i) = c_FAX) AND
         (p_fax_tbl(i) IS NULL)) THEN
    x_results.add_result(
      p_entity_type => c_entity_type_HEADER
    , p_entity_id => p_header_id_tbl(i)
    , p_column_name => c_FAX
    , p_message_name => PO_MESSAGE_S.PO_ALL_NOT_NULL
    );
  END IF;

END LOOP;

IF (l_results_count < x_results.result_type.COUNT) THEN
  x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
ELSE
  x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
END IF;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
  PO_LOG.log(PO_LOG.c_PROC_END,d_mod,NULL,'x_results',x_results);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
  END IF;
  RAISE;

END fax_email_address_valid;


---------------------------------------------------------------------------
-- Checks that the Expiration Date is greater than or equal to
-- the Effective Date.
-- Agreements only.
---------------------------------------------------------------------------
PROCEDURE effective_le_expiration(
  p_header_id_tbl   IN  PO_TBL_NUMBER
, p_start_date_tbl  IN  PO_TBL_DATE
, p_end_date_tbl    IN  PO_TBL_DATE
, x_results         IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.start_date_le_end_date(
  p_calling_module => D_effective_le_expiration
, p_start_date_tbl => p_start_date_tbl
, p_end_date_tbl => p_end_date_tbl
, p_entity_id_tbl => p_header_id_tbl
, p_entity_type => c_entity_type_HEADER
, p_column_name => c_END_DATE
, p_column_val_selector => PO_VALIDATION_HELPER.c_END_DATE
, p_message_name => PO_MESSAGE_S.PO_ALL_DATE_BETWEEN_START_END
, x_results => x_results
, x_result_type => x_result_type
);

END effective_le_expiration;


---------------------------------------------------------------------------
-- Checks that the Effective From Date is less than or equal to
-- the Creation Date of any Orders referencing the Agreement.
-- Agreements only.
---------------------------------------------------------------------------
PROCEDURE effective_from_le_order_date(
  p_header_id_tbl   IN  PO_TBL_NUMBER
, p_type_lookup_code_tbl  IN  PO_TBL_VARCHAR30
, p_start_date_tbl  IN  PO_TBL_DATE
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_effective_from_le_order_date;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_header_id_tbl',p_header_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_type_lookup_code_tbl',p_type_lookup_code_tbl);
  PO_LOG.proc_begin(d_mod,'p_start_date_tbl',p_start_date_tbl);
  PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
END IF;

IF (x_result_set_id IS NULL) THEN
  x_result_set_id := PO_VALIDATIONS.next_result_set_id();
END IF;

FORALL i IN 1 .. p_header_id_tbl.COUNT
INSERT INTO PO_VALIDATION_RESULTS_GT
( result_set_id
, entity_type
, entity_id
, column_name
, column_val
, message_name
)
SELECT
  x_result_set_id
, c_entity_type_HEADER
, p_header_id_tbl(i)
, c_START_DATE
, TO_CHAR(p_start_date_tbl(i))
, PO_MESSAGE_S.PO_CONTRACT_ST_LT_REF_CR   --- Bug 5548899
FROM DUAL
WHERE
    p_type_lookup_code_tbl(i) = c_BLANKET
AND EXISTS
( SELECT NULL
  FROM
    PO_LINES_ALL ORDER_LINE
  WHERE
      ORDER_LINE.from_header_id = p_header_id_tbl(i)
  AND p_start_date_tbl(i) > ORDER_LINE.creation_date
)
;

IF (SQL%ROWCOUNT > 0) THEN
  x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
ELSE
  x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
END IF;

IF PO_LOG.d_proc THEN
  PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
  PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
  PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
  END IF;
  RAISE;

END effective_from_le_order_date;


---------------------------------------------------------------------------
-- Checks that the Effective To Date is greater than or equal to
-- the Creation Date of any Orders referencing the Agreement.
-- Agreements only.
---------------------------------------------------------------------------
PROCEDURE effective_to_ge_order_date(
  p_header_id_tbl   IN  PO_TBL_NUMBER
, p_type_lookup_code_tbl  IN  PO_TBL_VARCHAR30
, p_end_date_tbl    IN  PO_TBL_DATE
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_effective_to_ge_order_date;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_header_id_tbl',p_header_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_type_lookup_code_tbl',p_type_lookup_code_tbl);
  PO_LOG.proc_begin(d_mod,'p_end_date_tbl',p_end_date_tbl);
  PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
END IF;

IF (x_result_set_id IS NULL) THEN
  x_result_set_id := PO_VALIDATIONS.next_result_set_id();
END IF;

FORALL i IN 1 .. p_header_id_tbl.COUNT
INSERT INTO PO_VALIDATION_RESULTS_GT
( result_set_id
, entity_type
, entity_id
, column_name
, column_val
, message_name
)
SELECT
  x_result_set_id
, c_entity_type_HEADER
, p_header_id_tbl(i)
, c_END_DATE
, TO_CHAR(p_end_date_tbl(i))
, PO_MESSAGE_S.PO_CONTRACT_ST_GT_REF_CR   --- Bug 5548899
FROM DUAL
WHERE
    p_type_lookup_code_tbl(i) = c_BLANKET
AND EXISTS
( SELECT NULL
  FROM
    PO_LINES_ALL ORDER_LINE
  , PO_HEADERS_ALL ORDER_HEADER
  WHERE
      ORDER_LINE.from_header_id = p_header_id_tbl(i)
  -- Bug # 13037340 Changed logic based on approved_date
  --AND p_end_date_tbl(i) < TRUNC(ORDER_LINE.creation_date)
  AND ORDER_HEADER.po_header_id = ORDER_LINE.po_header_id
  AND ORDER_HEADER.approved_date IS NOT NULL
  AND TRUNC(p_end_date_tbl(i)+ nvl(FND_PROFILE.VALUE('PO_REL_CREATE_TOLERANCE'),0)) < TRUNC(ORDER_HEADER.approved_date)
  AND NVL(ORDER_HEADER.closed_code,'X') <> c_FINALLY_CLOSED
  AND NVL(ORDER_HEADER.cancel_flag,'N') <> 'Y'
)
;

IF (SQL%ROWCOUNT > 0) THEN
  x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
ELSE
  x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
END IF;

IF PO_LOG.d_proc THEN
  PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
  PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
  PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
  END IF;
  RAISE;

END effective_to_ge_order_date;


---------------------------------------------------------------------------
-- Checks that the Effective From Date is less than or equal to
-- the Creation Date of any Orders referencing the Contract.
---------------------------------------------------------------------------
PROCEDURE contract_start_le_order_date(
  p_header_id_tbl   IN  PO_TBL_NUMBER
, p_type_lookup_code_tbl  IN  PO_TBL_VARCHAR30
, p_start_date_tbl  IN  PO_TBL_DATE
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_contract_start_le_order_date;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_header_id_tbl',p_header_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_type_lookup_code_tbl',p_type_lookup_code_tbl);
  PO_LOG.proc_begin(d_mod,'p_start_date_tbl',p_start_date_tbl);
  PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
END IF;

IF (x_result_set_id IS NULL) THEN
  x_result_set_id := PO_VALIDATIONS.next_result_set_id();
END IF;

FORALL i IN 1 .. p_header_id_tbl.COUNT
INSERT INTO PO_VALIDATION_RESULTS_GT
( result_set_id
, entity_type
, entity_id
, column_name
, column_val
, message_name
)
SELECT
  x_result_set_id
, c_entity_type_HEADER
, p_header_id_tbl(i)
, c_START_DATE
, TO_CHAR(p_start_date_tbl(i))
, PO_MESSAGE_S.PO_CONTRACT_ST_LT_REF_CR
FROM DUAL
WHERE
    p_type_lookup_code_tbl(i) = c_CONTRACT
AND EXISTS
( SELECT NULL
  FROM
    PO_LINES_ALL ORDER_LINE
  , PO_HEADERS_ALL ORDER_HEADER
  WHERE
      ORDER_LINE.contract_id = p_header_id_tbl(i)
  AND TRUNC(p_start_date_tbl(i)) > ORDER_LINE.creation_date
  AND ORDER_HEADER.po_header_id = ORDER_LINE.po_header_id
  AND ORDER_HEADER.approved_date IS NOT NULL
  AND NVL(ORDER_HEADER.closed_code,'X') <> c_FINALLY_CLOSED
  AND NVL(ORDER_HEADER.cancel_flag,'N') <> 'Y'
)
;

-- TODO: check with PM about differences in Agreements / Contracts checks.

IF (SQL%ROWCOUNT > 0) THEN
  x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
ELSE
  x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
END IF;

IF PO_LOG.d_proc THEN
  PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
  PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
  PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
  END IF;
  RAISE;

END contract_start_le_order_date;


---------------------------------------------------------------------------
-- Checks that the Effective To Date is greater than or equal to
-- the Creation Date of any Orders referencing the Contract.
---------------------------------------------------------------------------
PROCEDURE contract_end_ge_order_date(
  p_header_id_tbl   IN  PO_TBL_NUMBER
, p_type_lookup_code_tbl  IN  PO_TBL_VARCHAR30
, p_end_date_tbl    IN  PO_TBL_DATE
, x_result_set_id   IN OUT NOCOPY NUMBER
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_contract_end_ge_order_date;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_header_id_tbl',p_header_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_type_lookup_code_tbl',p_type_lookup_code_tbl);
  PO_LOG.proc_begin(d_mod,'p_end_date_tbl',p_end_date_tbl);
  PO_LOG.proc_begin(d_mod,'x_result_set_id',x_result_set_id);
END IF;

IF (x_result_set_id IS NULL) THEN
  x_result_set_id := PO_VALIDATIONS.next_result_set_id();
END IF;

FORALL i IN 1 .. p_header_id_tbl.COUNT
INSERT INTO PO_VALIDATION_RESULTS_GT
( result_set_id
, entity_type
, entity_id
, column_name
, column_val
, message_name
)
SELECT
  x_result_set_id
, c_entity_type_HEADER
, p_header_id_tbl(i)
, c_END_DATE
, TO_CHAR(p_end_date_tbl(i))
, PO_MESSAGE_S.PO_CONTRACT_ST_GT_REF_CR
FROM DUAL
WHERE
    p_type_lookup_code_tbl(i) = c_CONTRACT
AND EXISTS
( SELECT NULL
  FROM
    PO_LINES_ALL ORDER_LINE
  , PO_HEADERS_ALL ORDER_HEADER
  WHERE
      ORDER_LINE.contract_id = p_header_id_tbl(i)
  -- Bug # 13037340 Changed logic based on approved_date
  -- AND p_end_date_tbl(i) < TRUNC(ORDER_LINE.creation_date)
  AND ORDER_HEADER.po_header_id = ORDER_LINE.po_header_id
  AND ORDER_HEADER.approved_date IS NOT NULL
  AND TRUNC(p_end_date_tbl(i)+ nvl(FND_PROFILE.VALUE('PO_REL_CREATE_TOLERANCE'),0)) < TRUNC(ORDER_HEADER.approved_date)
  AND NVL(ORDER_HEADER.closed_code,'X') <> c_FINALLY_CLOSED
  AND NVL(ORDER_HEADER.cancel_flag,'N') <> 'Y'
)
;

IF (SQL%ROWCOUNT > 0) THEN
  x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
ELSE
  x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
END IF;

IF PO_LOG.d_proc THEN
  PO_VALIDATIONS.log_validation_results_gt(d_mod,9,x_result_set_id);
  PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
  PO_LOG.proc_end(d_mod,'x_result_set_id',x_result_set_id);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
  END IF;
  RAISE;

END contract_end_ge_order_date;


---------------------------------------------------------------------------
-- Checks that the Document Number is numeric, if required.
---------------------------------------------------------------------------
PROCEDURE doc_num_chars_valid(
  p_header_id_tbl   IN  PO_TBL_NUMBER
, p_org_id_tbl      IN  PO_TBL_NUMBER
, p_segment1_tbl    IN  PO_TBL_VARCHAR30
, x_results         IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_doc_num_chars_valid;

l_results_count NUMBER;
l_data_key NUMBER;
l_header_id_tbl PO_TBL_NUMBER;
l_segment1_tbl PO_TBL_VARCHAR30;
l_num_test NUMBER;

L_TEMP_SEGMENT PO_HEADERS_ALL.SEGMENT1%TYPE;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_header_id_tbl',p_header_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_org_id_tbl',p_org_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_segment1_tbl',p_segment1_tbl);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

l_results_count := x_results.result_type.COUNT;

l_data_key := PO_CORE_S.get_session_gt_nextval();

FORALL i IN 1 .. p_header_id_tbl.COUNT
INSERT INTO PO_SESSION_GT
( key
, num1
, num2
, char1
)
VALUES
( l_data_key
, p_header_id_tbl(i)
, p_org_id_tbl(i)
, p_segment1_tbl(i)
)
;


SELECT
  num1
, char1
BULK COLLECT INTO
  l_header_id_tbl
, l_segment1_tbl
FROM
  PO_SESSION_GT SES
, PO_SYSTEM_PARAMETERS_ALL PARAMS
WHERE
    SES.key = l_data_key
AND SES.num2 = PARAMS.org_id
AND PARAMS.manual_po_num_type = c_NUMERIC
;


FOR i IN 1 .. l_header_id_tbl.COUNT LOOP
  BEGIN

  /* Bug 8976636 Start

  Added below logic to ensure that the document numbering validation will
  be fired in case of new purchase orders only.

  We are selecting the segment1 from po_headers_all from po_headers_all
  using po_header_i and segment1. If it finds any record then we need not do
  the document numbering validation as it is already created and we are updating now.

  If there is no such record in po_headers_all then l_tem_segment value will be null
  and validation will be fired.

  */

  BEGIN
  SELECT SEGMENT1 INTO L_TEMP_SEGMENT
  FROM PO_HEADERS_ALL
  WHERE
  SEGMENT1=l_segment1_tbl(i)
  AND
  PO_HEADER_ID=l_header_id_tbl(i);
  EXCEPTION
  WHEN NO_DATA_FOUND THEN
  L_TEMP_SEGMENT:=NULL;
  END;

  /* Bug 8976636 End   */
  IF L_TEMP_SEGMENT IS NULL THEN
    l_num_test := TO_NUMBER(l_segment1_tbl(i));
  END IF;
  EXCEPTION
  WHEN VALUE_ERROR THEN
    x_results.add_result(
      p_entity_type => c_entity_type_HEADER
    , p_entity_id => l_header_id_tbl(i)
    , p_column_name => c_SEGMENT1
    , p_column_val => l_segment1_tbl(i)
    , p_message_name => PO_MESSAGE_S.PO_ALL_ENTER_NUMERIC
    );
  END;
END LOOP;

IF (l_results_count < x_results.result_type.COUNT) THEN
  x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
ELSE
  x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
END IF;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
  PO_LOG.log(PO_LOG.c_PROC_END,d_mod,NULL,'x_results',x_results);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
  END IF;
  RAISE;

END doc_num_chars_valid;


---------------------------------------------------------------------------
-- Checks that the Document Number is unique within the Org.
---------------------------------------------------------------------------
PROCEDURE doc_num_unique(
  p_header_id_tbl   IN  PO_TBL_NUMBER
, p_org_id_tbl      IN  PO_TBL_NUMBER
, p_segment1_tbl    IN  PO_TBL_VARCHAR30
, p_type_lookup_code_tbl  IN  PO_TBL_VARCHAR30
, x_results         IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type     OUT NOCOPY    VARCHAR2
)
IS
d_mod CONSTANT VARCHAR2(100) := D_doc_num_unique;
d_position NUMBER := 0;

l_results_count NUMBER;

l_data_key NUMBER;
l_header_id_tbl PO_TBL_NUMBER;
l_org_id_tbl PO_TBL_NUMBER;
l_segment1_tbl PO_TBL_VARCHAR30;
l_nonunique_tbl PO_TBL_VARCHAR2000;

l_check_sourcing_flag VARCHAR2(2000);
l_pon_unique_status VARCHAR2(2000);

BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_header_id_tbl',p_header_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_org_id_tbl',p_org_id_tbl);
  PO_LOG.proc_begin(d_mod,'p_segment1_tbl',p_segment1_tbl);
  PO_LOG.proc_begin(d_mod,'p_type_lookup_code_tbl',p_type_lookup_code_tbl);
  PO_LOG.log(PO_LOG.c_PROC_BEGIN,d_mod,NULL,'x_results',x_results);
END IF;

d_position := 1;

IF (x_results IS NULL) THEN
  x_results := PO_VALIDATION_RESULTS_TYPE.new_instance();
END IF;

l_results_count := x_results.result_type.COUNT;

----------------------------------------------------------
--
-- The following mapping is used for PO_SESSION_GT in this
-- procedure:
--
--  num1        - po_header_id
--  num2        - org_id
--  index_char1 - segment1
--  char2       - type_lookup_code
--
--  index_char2 - used to identify failure rows
--
----------------------------------------------------------

l_data_key := PO_CORE_S.get_session_gt_nextval();

-- Only check unsaved headers with manually entered document numbers.

FORALL i IN 1 .. p_header_id_tbl.COUNT
INSERT INTO PO_SESSION_GT
( key
, num1
, num2
, index_char1
, char2
)
SELECT
  l_data_key
, p_header_id_tbl(i)
, p_org_id_tbl(i)
, p_segment1_tbl(i)
, p_type_lookup_code_tbl(i)
FROM
  PO_SYSTEM_PARAMETERS_ALL PARAMS
WHERE
    PARAMS.org_id = p_org_id_tbl(i)
AND PARAMS.user_defined_po_num_code = c_MANUAL
AND p_segment1_tbl(i) IS NOT NULL
AND NOT EXISTS
( SELECT NULL
  FROM PO_HEADERS_ALL SAVED_HEADER
  WHERE SAVED_HEADER.po_header_id = p_header_id_tbl(i)
)
;

d_position := 100;

IF (SQL%ROWCOUNT > 0) THEN

  d_position := 110;

  UPDATE PO_SESSION_GT SES
  SET index_char2 = 'X'
  WHERE
      SES.key = l_data_key
  AND
  (
    -- Check for currently existing documents.
    EXISTS
    ( SELECT NULL
      FROM PO_HEADERS_ALL HEADER
      WHERE
          HEADER.org_id = SES.num2
      AND HEADER.segment1 = SES.index_char1
      AND HEADER.type_lookup_code IN (c_STANDARD,c_PLANNED,c_CONTRACT,c_BLANKET)
      AND HEADER.po_header_id <> SES.num1
    )
    OR
    -- Check for previously purged documents.
    EXISTS
    ( SELECT NULL
      FROM PO_HISTORY_POS_ALL DELETED_HEADER
      WHERE
          DELETED_HEADER.org_id = SES.num2
      AND DELETED_HEADER.segment1 = SES.index_char1
      AND DELETED_HEADER.type_lookup_code IN (c_STANDARD,c_PLANNED,c_CONTRACT,c_BLANKET)
    )
    OR
    -- Check for other in-memory documents.
    EXISTS
    ( SELECT NULL
      FROM PO_SESSION_GT UNSAVED_DATA
      WHERE
          UNSAVED_DATA.key = l_data_key
      AND UNSAVED_DATA.num2 = SES.num2    -- org_id
      AND UNSAVED_DATA.index_char1 = SES.index_char1  -- segment1
      AND UNSAVED_DATA.num1 <> SES.num1   -- po_header_id
    )
  )
  ;

  d_position := 200;

  -- If Sourcing is enabled, we need to check for
  -- document number uniqueness across auctions as well.
  PO_SETUP_S1.get_sourcing_startup(l_check_sourcing_flag);

  d_position := 210;

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'l_check_sourcing_flag',l_check_sourcing_flag);
  END IF;

  SELECT
    SES.num1
  , SES.num2
  , SES.index_char1
  , SES.index_char2
  BULK COLLECT INTO
    l_header_id_tbl
  , l_org_id_tbl
  , l_segment1_tbl
  , l_nonunique_tbl
  FROM
    PO_SESSION_GT SES
  WHERE
      SES.key = l_data_key
  AND
    (   SES.index_char2 = 'X'
    OR
      (
          l_check_sourcing_flag = 'I'
      AND SES.char2 IN (c_STANDARD,c_BLANKET)
      )
    )
  ;

  d_position := 300;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'l_header_id_tbl',l_header_id_tbl);
    PO_LOG.stmt(d_mod,d_position,'l_org_id_tbl',l_org_id_tbl);
    PO_LOG.stmt(d_mod,d_position,'l_segment1_tbl',l_segment1_tbl);
    PO_LOG.stmt(d_mod,d_position,'l_nonunique_tbl',l_nonunique_tbl);
  END IF;

  IF (l_check_sourcing_flag = 'I') THEN
    FOR i IN 1 .. l_header_id_tbl.COUNT LOOP
      IF (l_nonunique_tbl(i) IS NULL) THEN
        PON_AUCTION_PO_PKG.check_unique(
          org_id => l_org_id_tbl(i)
        , po_number => l_segment1_tbl(i)
        , status => l_pon_unique_status
        );
        IF (NVL(l_pon_unique_status,'N') <> c_SUCCESS) THEN
          l_nonunique_tbl(i) := 'X';
        END IF;
      END IF;
    END LOOP;
  END IF;

  d_position := 400;

  FOR i IN 1 .. l_header_id_tbl.COUNT LOOP
    IF (l_nonunique_tbl(i) = 'X') THEN
      x_results.add_result(
        p_entity_type => c_entity_type_HEADER
      , p_entity_id => l_header_id_tbl(i)
      , p_column_name => c_SEGMENT1
      , p_column_val => l_segment1_tbl(i)
      , p_message_name => PO_MESSAGE_S.PO_ALL_ENTER_UNIQUE_VAL
      );
    END IF;
  END LOOP;

END IF; -- any records need to be checked

d_position := 500;

IF (l_results_count < x_results.result_type.COUNT) THEN
  x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
ELSE
  x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
END IF;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod,'x_result_type',x_result_type);
  PO_LOG.log(PO_LOG.c_PROC_END,d_mod,NULL,'x_results',x_results);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;

END doc_num_unique;


-- TODO: move to PO_DOC_CHECK_HEADERS

----------------------------------------------------------------------
-- Validates the dates of an Agreement's lines and price breaks
-- with respect to the dates on the header.
--
--Pre-reqs:
--  The agreement data must be populated in the Submission Check
--  temp tables before this procedure is called.
--  Only the agreement data should be in the tables.
----------------------------------------------------------------------
PROCEDURE check_agreement_dates(
  p_online_report_id  IN  NUMBER
, p_login_id          IN  NUMBER
, p_user_id           IN  NUMBER
, x_sequence          IN OUT NOCOPY NUMBER
)
IS
d_mod CONSTANT VARCHAR2(100) := D_check_agreement_dates;

c_delim CONSTANT VARCHAR2(1) := ' ';
l_linemsg VARCHAR2(75) := substr(FND_MESSAGE.GET_STRING('PO', 'PO_ZMVOR_LINE'), 1,25);

l_message_name VARCHAR2(30);
l_text VARCHAR2(4000);
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_online_report_id',p_online_report_id);
  PO_LOG.proc_begin(d_mod,'p_login_id',p_login_id);
  PO_LOG.proc_begin(d_mod,'p_user_id',p_user_id);
  PO_LOG.proc_begin(d_mod,'x_sequence',x_sequence);
END IF;


-- Check that the line's Expiration date is within the
-- Effective From and To dates of the agreement.

l_message_name := PO_MESSAGE_S.POX_EXPIRATION_DATES;

l_text := FND_MESSAGE.get_string(c_PO,l_message_name);

INSERT INTO PO_ONLINE_REPORT_TEXT_GT
( online_report_id
, last_update_login
, last_updated_by
, last_update_date
, created_by
, creation_date
, line_num
, shipment_num
, distribution_num
, sequence
, message_name
, text_line
)
SELECT
  p_online_report_id
, p_login_id
, p_user_id
, SYSDATE
, p_user_id
, SYSDATE
, LINE.line_num
, 0
, 0
, x_sequence + rownum
, l_message_name
, SUBSTR(l_linemsg || c_delim || TO_CHAR(LINE.line_num) || c_delim
    || l_text,1,240)
FROM
  PO_LINES_GT LINE
, PO_HEADERS_GT HEADER
WHERE
    LINE.expiration_date < HEADER.start_date
OR  LINE.expiration_date > HEADER.end_date
;

x_sequence := x_sequence + SQL%ROWCOUNT;


-- Check that the price break's Effective From date
-- is before the Effective To date of the agreement.

l_message_name := PO_MESSAGE_S.POX_EFFECTIVE_DATES4;

l_text := FND_MESSAGE.get_string(c_PO,l_message_name);

INSERT INTO PO_ONLINE_REPORT_TEXT_GT
( online_report_id
, last_update_login
, last_updated_by
, last_update_date
, created_by
, creation_date
, line_num
, shipment_num
, distribution_num
, sequence
, message_name
, text_line
)
SELECT
  p_online_report_id
, p_login_id
, p_user_id
, SYSDATE
, p_user_id
, SYSDATE
, LINE.line_num
, PRICE_BREAK.shipment_num
, 0
, x_sequence + rownum
, l_message_name
, SUBSTR(l_linemsg || c_delim || TO_CHAR(LINE.line_num) || c_delim
    || TO_CHAR(PRICE_BREAK.shipment_num) -- TODO: Need token from PM
    || l_text,1,240)
FROM
  PO_LINE_LOCATIONS_ALL PRICE_BREAK
, PO_LINES_GT LINE
, PO_HEADERS_GT HEADER
WHERE
    PRICE_BREAK.po_line_id = LINE.po_line_id
AND PRICE_BREAK.start_date > HEADER.end_date
;

x_sequence := x_sequence + SQL%ROWCOUNT;


-- Check that the price break's Effective From date
-- is after the Effective From date of the agreement.

l_message_name := PO_MESSAGE_S.POX_EFFECTIVE_DATES1;

l_text := FND_MESSAGE.get_string(c_PO,l_message_name);

INSERT INTO PO_ONLINE_REPORT_TEXT_GT
( online_report_id
, last_update_login
, last_updated_by
, last_update_date
, created_by
, creation_date
, line_num
, shipment_num
, distribution_num
, sequence
, message_name
, text_line
)
SELECT
  p_online_report_id
, p_login_id
, p_user_id
, SYSDATE
, p_user_id
, SYSDATE
, LINE.line_num
, PRICE_BREAK.shipment_num
, 0
, x_sequence + rownum
, l_message_name
, SUBSTR(l_linemsg || c_delim || TO_CHAR(LINE.line_num) || c_delim
    || TO_CHAR(PRICE_BREAK.shipment_num) -- TODO: Need token from PM
    || l_text,1,240)
FROM
  PO_LINE_LOCATIONS_ALL PRICE_BREAK
, PO_LINES_GT LINE
, PO_HEADERS_GT HEADER
WHERE
    PRICE_BREAK.po_line_id = LINE.po_line_id
AND PRICE_BREAK.start_date < HEADER.start_date
;

x_sequence := x_sequence + SQL%ROWCOUNT;


-- Check that the price break's Effective To date
-- is before the Effective To date of the agreement.

l_message_name := PO_MESSAGE_S.POX_EFFECTIVE_DATES;

l_text := FND_MESSAGE.get_string(c_PO,l_message_name);

INSERT INTO PO_ONLINE_REPORT_TEXT_GT
( online_report_id
, last_update_login
, last_updated_by
, last_update_date
, created_by
, creation_date
, line_num
, shipment_num
, distribution_num
, sequence
, message_name
, text_line
)
SELECT
  p_online_report_id
, p_login_id
, p_user_id
, SYSDATE
, p_user_id
, SYSDATE
, LINE.line_num
, PRICE_BREAK.shipment_num
, 0
, x_sequence + rownum
, l_message_name
, SUBSTR(l_linemsg || c_delim || TO_CHAR(LINE.line_num) || c_delim
    || TO_CHAR(PRICE_BREAK.shipment_num) -- TODO: Need token from PM
    || l_text,1,240)
FROM
  PO_LINE_LOCATIONS_ALL PRICE_BREAK
, PO_LINES_GT LINE
, PO_HEADERS_GT HEADER
WHERE
    PRICE_BREAK.po_line_id = LINE.po_line_id
AND PRICE_BREAK.end_date > HEADER.end_date
;

x_sequence := x_sequence + SQL%ROWCOUNT;


-- Check that the price break's Effective To date
-- is after the Effective From date of the agreement.

l_message_name := PO_MESSAGE_S.POX_EFFECTIVE_DATES5;

l_text := FND_MESSAGE.get_string(c_PO,l_message_name);

INSERT INTO PO_ONLINE_REPORT_TEXT_GT
( online_report_id
, last_update_login
, last_updated_by
, last_update_date
, created_by
, creation_date
, line_num
, shipment_num
, distribution_num
, sequence
, message_name
, text_line
)
SELECT
  p_online_report_id
, p_login_id
, p_user_id
, SYSDATE
, p_user_id
, SYSDATE
, LINE.line_num
, PRICE_BREAK.shipment_num
, 0
, x_sequence + rownum
, l_message_name
, SUBSTR(l_linemsg || c_delim || TO_CHAR(LINE.line_num) || c_delim
    || TO_CHAR(PRICE_BREAK.shipment_num) -- TODO: Need token from PM
    || l_text,1,240)
FROM
  PO_LINE_LOCATIONS_ALL PRICE_BREAK
, PO_LINES_GT LINE
, PO_HEADERS_GT HEADER
WHERE
    PRICE_BREAK.po_line_id = LINE.po_line_id
AND PRICE_BREAK.end_date < HEADER.start_date
;

x_sequence := x_sequence + SQL%ROWCOUNT;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod,'x_sequence',x_sequence);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,0,NULL);
  END IF;
  RAISE;

END check_agreement_dates;


-------------------------------------------------------------------------------
--  Ensures that the Buyer is not null.
-------------------------------------------------------------------------------
PROCEDURE agent_id_not_null(
  p_header_id_tbl IN  PO_TBL_NUMBER
, p_agent_id_tbl  IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.not_null(
  p_calling_module => D_agent_id_not_null
, p_value_tbl => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_agent_id_tbl)
, p_entity_id_tbl => p_header_id_tbl
, p_entity_type => c_entity_type_HEADER
, p_column_name => c_AGENT_ID
, p_message_name => PO_MESSAGE_S.PO_ALL_NOT_NULL
, x_results => x_results
, x_result_type => x_result_type
);

END agent_id_not_null;


-------------------------------------------------------------------------------
--  Ensures that the Default Ship-To / Work Location is not null.
-------------------------------------------------------------------------------
PROCEDURE ship_to_loc_not_null(
  p_header_id_tbl       IN  PO_TBL_NUMBER
, p_ship_to_loc_id_tbl  IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.not_null(
  p_calling_module => D_ship_to_loc_not_null
, p_value_tbl => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_ship_to_loc_id_tbl)
, p_entity_id_tbl => p_header_id_tbl
, p_entity_type => c_entity_type_HEADER
, p_column_name => c_SHIP_TO_LOCATION_ID
, p_message_name => PO_MESSAGE_S.PO_ALL_NOT_NULL
, x_results => x_results
, x_result_type => x_result_type
);

END ship_to_loc_not_null;


-------------------------------------------------------------------------------
--  Ensures that the Supplier is not null.
-------------------------------------------------------------------------------
PROCEDURE vendor_id_not_null(
  p_header_id_tbl IN  PO_TBL_NUMBER
, p_vendor_id_tbl IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.not_null(
  p_calling_module => D_vendor_id_not_null
, p_value_tbl => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_vendor_id_tbl)
, p_entity_id_tbl => p_header_id_tbl
, p_entity_type => c_entity_type_HEADER
, p_column_name => c_VENDOR_ID
, p_message_name => PO_MESSAGE_S.PO_ALL_NOT_NULL
, x_results => x_results
, x_result_type => x_result_type
);

END vendor_id_not_null;


-------------------------------------------------------------------------------
--  Ensures that the Supplier Site is not null.
-------------------------------------------------------------------------------
PROCEDURE vendor_site_id_not_null(
  p_header_id_tbl IN  PO_TBL_NUMBER
, p_vendor_site_id_tbl IN  PO_TBL_NUMBER
, x_results       IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

PO_VALIDATION_HELPER.not_null(
  p_calling_module => D_vendor_site_id_not_null
, p_value_tbl => PO_TYPE_CONVERTER.to_po_tbl_varchar4000(p_vendor_site_id_tbl)
, p_entity_id_tbl => p_header_id_tbl
, p_entity_type => c_entity_type_HEADER
, p_column_name => c_VENDOR_SITE_ID
, p_message_name => PO_MESSAGE_S.PO_ALL_NOT_NULL
, x_results => x_results
, x_result_type => x_result_type
);

END vendor_site_id_not_null;

--<Begin Bug# 5372769> EXCEPTION WHEN SAVE PO WO/ NUMBER IF DOCUMENT NUMBERING IS SET TO MANUAL
-------------------------------------------------------------------------------
--  Ensures that the Segment1 is not null.
-------------------------------------------------------------------------------
PROCEDURE segment1_not_null(
  p_header_id_tbl IN  PO_TBL_NUMBER
, p_segment1_tbl IN  PO_TBL_VARCHAR30
, p_org_id_tbl IN PO_TBL_NUMBER
, x_result_set_id IN OUT NOCOPY NUMBER
, x_result_type   OUT NOCOPY    VARCHAR2
)
IS
BEGIN

IF (x_result_set_id IS NULL) THEN
  x_result_set_id := PO_VALIDATIONS.next_result_set_id();
END IF;

FORALL i IN 1 .. p_header_id_tbl.COUNT
  INSERT INTO PO_VALIDATION_RESULTS_GT
  ( result_set_id
  , entity_type
  , entity_id
  , message_name
  , column_name
  )
  SELECT
    x_result_set_id
  , c_entity_type_HEADER
  , p_header_id_tbl(i)
  , PO_MESSAGE_S.PO_ALL_NOT_NULL
  , c_SEGMENT1
  FROM
    PO_SYSTEM_PARAMETERS_ALL
  WHERE
      org_id = p_org_id_tbl(i)
  AND USER_DEFINED_PO_NUM_CODE = c_MANUAL
  AND p_segment1_tbl(i) IS NULL;

IF (SQL%ROWCOUNT > 0) THEN
  x_result_type := PO_VALIDATIONS.c_result_type_FAILURE;
ELSE
  x_result_type := PO_VALIDATIONS.c_result_type_SUCCESS;
END IF;

END segment1_not_null;
--<End 5372769>

--<Start Bug 9213424> Error when the ship_via field has an invalid value.
PROCEDURE ship_via_lookup_code_valid(
      p_header_id_tbl                     IN              po_tbl_number,
      p_ship_via_lookup_code_tbl   IN              po_tbl_varchar30,
	  --Bug 12409257 start.Bug 13771850-Revert 12409257 changes
      p_org_id_tbl IN PO_TBL_NUMBER,
	  --p_ship_to_location_id_tbl  IN PO_TBL_NUMBER,
	  --Bug 12409257 end.Bug 13771850 end
      x_result_set_id              IN OUT NOCOPY   NUMBER,
      x_result_type                OUT NOCOPY      VARCHAR2)
   IS
      d_mod CONSTANT VARCHAR2(100) := D_ship_via_lookup_code_valid;
      x_temp VARCHAR2(100);
   BEGIN
      IF x_result_set_id IS NULL THEN
         x_result_set_id := po_validations.next_result_set_id();
      END IF;

      IF po_log.d_proc THEN
         po_log.proc_begin(d_mod, 'p_header_id_tbl', p_header_id_tbl);
         po_log.proc_begin(d_mod, 'p_ship_via_lookup_code_tbl', p_ship_via_lookup_code_tbl);
		 --po_log.proc_begin(d_mod, 'p_ship_to_location_id_tbl', p_ship_to_location_id_tbl);--Bug 12409257
         po_log.proc_begin(d_mod, 'x_result_set_id', x_result_set_id);


      END IF;

       x_result_type := po_validations.c_result_type_success;

      FOR  i IN 1 .. p_header_id_tbl.Count
       LOOP
      IF  p_ship_via_lookup_code_tbl(i) IS NOT NULL THEN


                INSERT INTO po_validation_results_gt
                     (result_set_id,
                      result_type,
                      entity_type,
                      message_name,
                      column_name,
                      column_val,
                      token1_name,
                      token1_value,
            validation_id)
             SELECT x_result_set_id,
                   po_validations.c_result_type_failure,
                   c_entity_type_header,
                   'PO_PDOI_INVALID_FREIGHT_CARR',
                   'SHIP_VIA_LOOKUP_CODE',
                   p_ship_via_lookup_code_tbl(i),
                   'VALUE',
                   p_ship_via_lookup_code_tbl(i),
                   PO_VAL_CONSTANTS.c_ship_via_lookup_code
              FROM dual
              WHERE NOT EXISTS (SELECT 1 FROM org_freight ofr
                       WHERE p_ship_via_lookup_code_tbl(i) = ofr.freight_code
                       AND SYSDATE < NVL(ofr.disable_date, SYSDATE + 1)
                       --Bug 12409257 start
					   --AND  p_org_id_tbl(i)=ofr.organization_id);
                       --AND  ofr.organization_id in (SELECT inventory_organization_id
                       --                              FROM hr_locations_v
                       --                              WHERE ship_to_location_id = --p_ship_to_location_id_tbl(i)
                       --                              AND ship_to_site_flag = 'Y'));
						--Bug 12409257 end
					  --Bug 13771850  start
                        AND  ofr.organization_id in (SELECT inventory_organization_id
                                                     FROM financials_system_params_all
                                                     WHERE org_id = p_org_id_tbl(i) ));
                      --Bug 13771850  end
         END IF ;
       END LOOP ;


       IF (SQL%ROWCOUNT > 0  ) THEN
         x_result_type := po_validations.c_result_type_FAILURE;
      END IF;

      IF po_log.d_proc THEN
         po_validations.log_validation_results_gt(d_mod, 9, x_result_set_id);
         po_log.proc_end(d_mod, 'x_result_type', x_result_type);
         po_log.proc_end(d_mod, 'x_result_set_id', x_result_set_id);
      END IF;


   EXCEPTION
      WHEN OTHERS THEN
         IF po_log.d_exc THEN
            po_log.exc(d_mod, 0, NULL);
         END IF;
     RAISE;
   END ship_via_lookup_code_valid;
--<End Bug 9213424>

END PO_VAL_HEADERS;

/
