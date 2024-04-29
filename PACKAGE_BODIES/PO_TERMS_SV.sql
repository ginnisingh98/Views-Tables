--------------------------------------------------------
--  DDL for Package Body PO_TERMS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_TERMS_SV" AS
/* $Header: POXPOTEB.pls 115.7 2003/12/03 20:17:17 bao ship $*/

-- Read the profile option that enables/disables the debug log
g_asn_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('PO_RVCTP_ENABLE_TRACE'),'N');


-- bug3225062

PROCEDURE set_terms_token
( p_prompt           IN            VARCHAR2,
  p_po_terms_val     IN            VARCHAR2,
  p_ref_terms_val    IN            VARCHAR2,
  x_po_terms_list     IN OUT NOCOPY VARCHAR2,
  x_ref_terms_list    IN OUT NOCOPY VARCHAR2
) ;

/*===========================================================================

  FUNCTION NAME:	val_fob_code()

===========================================================================*/
FUNCTION val_fob_code(X_fob_lookup_code IN VARCHAR2) return BOOLEAN IS

  X_progress 	   varchar2(25) := NULL;
  X_fob_lookup_val varchar2(25) := NULL;

BEGIN

  X_progress := '010';

  po_vendors_sv.val_fob(X_fob_lookup_code, X_fob_lookup_val);

  if (X_fob_lookup_val is not null) then
    return (TRUE);
  else
    return (FALSE);
  end if;

EXCEPTION

  when others then
    po_message_s.sql_error('val_fob_code', X_progress, sqlcode);
    raise;

END val_fob_code;

/*===========================================================================

  FUNCTION NAME:	val_freight_code()

===========================================================================*/
FUNCTION val_freight_code(X_freight_terms_code IN VARCHAR2) return BOOLEAN IS

  X_progress	      varchar2(3)  := NULL;
  X_freight_terms_val varchar2(25) := NULL;

BEGIN

  X_progress := '010';

  po_vendors_sv.val_freight_terms(X_freight_terms_code, X_freight_terms_val);

  if (X_freight_terms_val is not null) then
    return (TRUE);
  else
    return (FALSE);
  end if;

EXCEPTION

  when others then
    po_message_s.sql_error('val_freight_code', X_progress, sqlcode);
    raise;

END val_freight_code;

/*===========================================================================

  FUNCTION NAME:	val_ship_via()

===========================================================================*/
FUNCTION val_ship_via(X_ship_via_code IN VARCHAR2,
		      X_org_id 	      IN NUMBER) return BOOLEAN IS

  X_progress	 varchar2(3)  := NULL;
  X_ship_via_val varchar2(25) := NULL;

BEGIN

  X_progress := '010';

  po_vendors_sv.val_freight_carrier(X_ship_via_code, X_org_id, X_ship_via_val);

  if (X_ship_via_val is not null) then
    return (TRUE);
  else
    return (FALSE);
  end if;

EXCEPTION

  when others then
    po_message_s.sql_error('val_ship_via', X_progress, sqlcode);
    raise;

END val_ship_via;

/*===========================================================================

  FUNCTION NAME:	val_payment_terms()

===========================================================================*/

FUNCTION val_payment_terms(X_ap_terms_id IN NUMBER) return BOOLEAN IS

  X_progress     varchar2(3) := NULL;
  X_ap_terms_val number      := NULL;

BEGIN

  X_progress := '010';

  po_terms_sv.val_ap_terms(X_ap_terms_id, X_ap_terms_val);

  if (X_ap_terms_val is not null) then
    return (TRUE);
  else
    return (FALSE);
  end if;

EXCEPTION

  when others then
    po_message_s.sql_error('val_payment_terms', X_progress, sqlcode);
    raise;

END val_payment_terms;

/*===========================================================================

  PROCEDURE NAME:	val_ap_terms()

===========================================================================*/


 procedure val_ap_terms (X_temp_terms_id IN number, X_res_terms_id IN OUT NOCOPY number) is
            X_progress varchar2(3) := '';
 begin
             X_progress := '010';

             /* Check if the given Terms Id is active */

             SELECT term_id
             INTO   X_res_terms_id
             FROM   ap_terms
             WHERE  sysdate BETWEEN nvl(start_date_active, sysdate - 1)
             AND    nvl(end_date_active, sysdate + 1)
             AND    term_id = X_temp_terms_id;

exception

             when no_data_found then
                  X_res_terms_id := '';
             when too_many_rows then
                  X_res_terms_id := '';
             when others then
                  po_message_s.sql_error('val_ap_terms',X_progress,sqlcode);
                  raise;

 end val_ap_terms;

/*===========================================================================

  PROCEDURE NAME:	get_terms_name()

===========================================================================*/


 procedure get_terms_name (X_terms_id   IN     NUMBER,
			   X_terms_name IN OUT NOCOPY VARCHAR2) IS

 X_progress varchar2(3) := '';

 begin
	X_progress := '010';

        /* Get the Terms Name for a certain terms_id */

	IF (X_terms_id is not NULL) THEN

            SELECT name
            INTO   X_terms_name
            FROM   ap_terms
            WHERE  term_id = X_terms_id;

	END IF;

 exception

	when others then
           po_message_s.sql_error('get_terms_name',X_progress,sqlcode);
           raise;

 end get_terms_name;

/*===========================================================================

  PROCEDURE NAME:	derive_payment_terms_info()

===========================================================================*/

 PROCEDURE derive_payment_terms_info(
               p_pay_record IN OUT NOCOPY RCV_SHIPMENT_HEADER_SV.PayRecType) IS

 cid            INTEGER;
 rows_processed INTEGER;
 sql_str        VARCHAR2(2000);

 Pay_name_null  BOOLEAN := TRUE;
 Pay_id_null    BOOLEAN := TRUE;

 BEGIN

    sql_str := 'SELECT name, term_id FROM ap_terms WHERE ';

    IF p_pay_record.payment_term_name IS NULL   and
       p_pay_record.payment_term_id   IS NULL   THEN

          p_pay_record.error_record.error_status := 'W';
          RETURN;

    END IF;

    IF p_pay_record.payment_term_name IS NOT NULL and
       p_pay_record.payment_term_id   IS NOT NULL   THEN

          p_pay_record.error_record.error_status := 'S';
          RETURN;

    END IF;

    IF p_pay_record.payment_term_name IS NOT NULL THEN

      sql_str := sql_str || ' name  = :v_pay_name and';
      pay_name_null := FALSE;

    END IF;

    IF p_pay_record.payment_term_id IS NOT NULL THEN

      sql_str := sql_str || ' term_id = :v_pay_id and';
      pay_id_null := FALSE;

    END IF;

    sql_str := substr(sql_str,1,length(sql_str)-3);

    -- dbms_output.put_line(substr(sql_str,1,255));
    -- dbms_output.put_line(substr(sql_str,256,255));
    -- dbms_output.put_line(substr(sql_str,513,255));

    cid := dbms_sql.open_cursor;

    dbms_sql.parse(cid, sql_str , dbms_sql.native);

    dbms_sql.define_column(cid,1,p_pay_record.payment_term_name,55);
    dbms_sql.define_column(cid,2,p_pay_record.payment_term_id);

    IF NOT pay_name_null THEN

      dbms_sql.bind_variable(cid,'v_pay_name',p_pay_record.payment_term_name);

    END IF;

    IF NOT pay_id_null THEN

      dbms_sql.bind_variable(cid,'v_pay_id',p_pay_record.payment_term_id);

    END IF;

    rows_processed := dbms_sql.execute_and_fetch(cid);

    IF rows_processed = 1 THEN

       IF pay_name_null THEN
          dbms_sql.column_value(cid,1,p_pay_record.payment_term_name);
       END IF;

       IF pay_id_null THEN
          dbms_sql.column_value(cid,2,p_pay_record.payment_term_id);
       END IF;

       p_pay_record.error_record.error_status := 'S';

    ELSIF rows_processed = 0 THEN

       p_pay_record.error_record.error_status := 'W';

    ELSE

       p_pay_record.error_record.error_status := 'W';

    END IF;

    IF dbms_sql.is_open(cid) THEN
       dbms_sql.close_cursor(cid);
    END IF;

 EXCEPTION
    WHEN others THEN

       IF dbms_sql.is_open(cid) THEN
           dbms_sql.close_cursor(cid);
       END IF;

       p_pay_record.error_record.error_status := 'U';
       p_pay_record.error_record.error_message := sqlerrm;
       IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line(p_pay_record.error_record.error_message);
       END IF;

 END derive_payment_terms_info;

/*===========================================================================

  PROCEDURE NAME:	validate_payment_terms_info()

===========================================================================*/

 PROCEDURE validate_payment_terms_info (
               p_pay_record IN OUT NOCOPY RCV_SHIPMENT_HEADER_SV.PayRecType) IS

 X_cid            INTEGER;
 X_rows_processed INTEGER;
 X_sql_str        VARCHAR2(2000);

 X_pay_name_null  BOOLEAN := TRUE;
 X_pay_id_null    BOOLEAN := TRUE;

 X_start_date_active DATE;
 X_end_date_active   DATE;
 X_enabled_flag      VARCHAR2(1);
 X_sysdate           DATE := sysdate;

 BEGIN

    X_sql_str := 'SELECT start_date_active, end_date_active, enabled_flag FROM ap_terms WHERE ';

    IF p_pay_record.payment_term_name IS NULL   and
       p_pay_record.payment_term_id   IS NULL   THEN

          -- dbms_output.put_line('All Blanks');
          p_pay_record.error_record.error_status := 'E';
          p_pay_record.error_record.error_message := 'All Blanks';
          RETURN;

    END IF;

    IF p_pay_record.payment_term_name IS NOT NULL THEN

      X_sql_str := X_sql_str || ' name  = :v_pay_name and';
      X_pay_name_null := FALSE;

    END IF;

    IF p_pay_record.payment_term_id IS NOT NULL THEN

      X_sql_str := X_sql_str || ' term_id = :v_pay_id and';
      X_pay_id_null := FALSE;

    END IF;

    X_sql_str := substr(X_sql_str,1,length(X_sql_str)-3);

    -- dbms_output.put_line(substr(X_sql_str,1,255));
    -- dbms_output.put_line(substr(X_sql_str,256,255));
    -- dbms_output.put_line(substr(X_sql_str,513,255));

    X_cid := dbms_sql.open_cursor;

    dbms_sql.parse(X_cid, X_sql_str , dbms_sql.native);

    dbms_sql.define_column(X_cid,1,X_start_date_active);
    dbms_sql.define_column(X_cid,2,X_end_date_active);
    dbms_sql.define_column(X_cid,3,X_enabled_flag,1);

    IF NOT X_pay_name_null THEN

      dbms_sql.bind_variable(X_cid,'v_pay_name',p_pay_record.payment_term_name);

    END IF;

    IF NOT X_pay_id_null THEN

      dbms_sql.bind_variable(X_cid,'v_pay_id',p_pay_record.payment_term_id);

    END IF;

    X_rows_processed := dbms_sql.execute_and_fetch(X_cid);

    IF X_rows_processed = 1 THEN

       dbms_sql.column_value(X_cid,1,X_start_date_active);
       dbms_sql.column_value(X_cid,2,X_end_date_active);
       dbms_sql.column_value(X_cid,3,X_enabled_flag);

       IF NOT (X_sysdate between nvl(X_start_date_active, X_sysdate -1) and
                          nvl(X_end_date_active, X_sysdate + 1) and
           nvl(X_enabled_flag,'Y') = 'Y') THEN

          IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('Disabled');
          END IF;
          p_pay_record.error_record.error_status := 'E';
          p_pay_record.error_record.error_message := 'RCV_PAY_TERMS_DISABLED';

          IF dbms_sql.is_open(X_cid) THEN
            dbms_sql.close_cursor(X_cid);
          END IF;

          RETURN;

       END IF;

       p_pay_record.error_record.error_status := 'S';
       p_pay_record.error_record.error_message := NULL;

    ELSIF X_rows_processed = 0 THEN

       p_pay_record.error_record.error_status := 'E';
       p_pay_record.error_record.error_message := 'RCV_PAY_TERMS_ID';

       IF dbms_sql.is_open(X_cid) THEN
           dbms_sql.close_cursor(X_cid);
       END IF;

       RETURN;

    ELSE

       p_pay_record.error_record.error_status := 'E';
       p_pay_record.error_record.error_message := 'Too many rows';

       IF dbms_sql.is_open(X_cid) THEN
           dbms_sql.close_cursor(X_cid);
       END IF;

       RETURN;

    END IF;

    IF dbms_sql.is_open(X_cid) THEN
      dbms_sql.close_cursor(X_cid);
    END IF;

 EXCEPTION
    WHEN others THEN
       IF dbms_sql.is_open(X_cid) THEN
           dbms_sql.close_cursor(X_cid);
       END IF;

       p_pay_record.error_record.error_status := 'U';
       p_pay_record.error_record.error_message := sqlerrm;
       IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line(p_pay_record.error_record.error_message);
       END IF;

 END validate_payment_terms_info;

/*===========================================================================

  PROCEDURE NAME:	validate_freight_carrier_info()

===========================================================================*/

 PROCEDURE validate_freight_carrier_info (
               p_carrier_rec IN OUT NOCOPY RCV_SHIPMENT_HEADER_SV.FreightRecType) IS

 cursor C IS SELECT ofg.disable_date disable_date
             FROM org_freight ofg
             WHERE
                  ofg.freight_code = p_carrier_rec.freight_carrier_code and
                  ofg.organization_id = p_carrier_rec.organization_id ;

 X_sysdate      DATE := sysdate;
 freight_record C%ROWTYPE;

 BEGIN

   OPEN C;
   FETCH C INTO freight_record;
   IF C%NOTFOUND THEN

       -- dbms_output.put_line('Invalid Carrier');
       p_carrier_rec.error_record.error_status := 'E';
       p_carrier_rec.error_record.error_message := 'CARRIER_INVALID';
       CLOSE C;
       RETURN;

   ELSE

     IF nvl(freight_record.disable_date, X_sysdate + 1)  < X_sysdate  THEN

       -- dbms_output.put_line('Disabled Carrier');
       p_carrier_rec.error_record.error_status := 'E';
       p_carrier_rec.error_record.error_message := 'CARRIER_DISABLED';
       CLOSE C;
       RETURN;

     END IF;

     LOOP

        FETCH C INTO freight_record;
        IF C%NOTFOUND THEN

           p_carrier_rec.error_record.error_status := 'S';
           p_carrier_rec.error_record.error_message := NULL;
           exit;

        ELSE

           p_carrier_rec.error_record.error_status := 'E';
           p_carrier_rec.error_record.error_message := 'Too many rows';
           EXIT;

        END IF;

     END LOOP;

   END IF;

 EXCEPTION

   WHEN others THEN

       p_carrier_rec.error_record.error_status := 'U';
       p_carrier_rec.error_record.error_message := sqlerrm;
       RETURN;

 END validate_freight_carrier_info;


--=============================================================================
-- PROCEDURE   : get_global_terms_conditions                    <2699404>
-- TYPE        : Private
--
-- PRE-REQS    : -
-- MODIFIES    : -
--
-- DESCRIPTION : Gets global Terms and Conditions for a particular document.
--               If document does not exist, returns NULLs for OUT parameters.
--
-- PARAMETERS  : p_po_header_id - document ID
--
-- RETURNS     : x_terms_id        - Payment Terms ID
--               x_fob_lookup_code - FOB Lookup Code
--               x_freight_terms   - Freight Terms Lookup Code
--               x_supplier_note   - Supplier Note
--               x_receiver_note   - Receiver Note
--
-- EXCEPTIONS  : -
--=============================================================================
PROCEDURE get_global_terms_conditions
(
    p_po_header_id    IN         PO_HEADERS_ALL.po_header_id%TYPE
,   x_terms_id        OUT NOCOPY PO_HEADERS_ALL.terms_id%TYPE
,   x_fob_lookup_code OUT NOCOPY PO_HEADERS_ALL.fob_lookup_code%TYPE
,   x_freight_terms   OUT NOCOPY PO_HEADERS_ALL.freight_terms_lookup_code%TYPE
,   x_supplier_note   OUT NOCOPY PO_HEADERS_ALL.note_to_vendor%TYPE
,   x_receiver_note   OUT NOCOPY PO_HEADERS_ALL.note_to_receiver%TYPE
,   x_shipping_control OUT NOCOPY PO_HEADERS_ALL.shipping_control%TYPE  -- <INBOUND LOGISTICS FPJ>
)
IS
BEGIN

    SELECT     terms_id
    ,          fob_lookup_code
    ,          freight_terms_lookup_code
    ,          note_to_vendor
    ,          note_to_receiver
    ,          shipping_control    -- <INBOUND LOGISTICS FPJ>
    INTO       x_terms_id
    ,          x_fob_lookup_code
    ,          x_freight_terms
    ,          x_supplier_note
    ,          x_receiver_note
    ,          x_shipping_control    -- <INBOUND LOGISTICS FPJ>
    FROM       po_headers_all
    WHERE      po_header_id = p_po_header_id;

EXCEPTION

    WHEN OTHERS THEN
        x_terms_id := NULL;
        x_fob_lookup_code := NULL;
        x_freight_terms := NULL;
        x_supplier_note := NULL;
        x_receiver_note := NULL;
        x_shipping_control := NULL;    -- <INBOUND LOGISTICS FPJ>

END get_global_terms_conditions;


--=============================================================================
-- PROCEDURE   : get_local_terms_conditions                     <2699404>
-- TYPE        : Private
--
-- PRE-REQS    : -
-- MODIFIES    : -
--
-- DESCRIPTION : Gets the local Terms and Conditions for a particular document.
--               If document does not exist, returns NULLs for OUT parameters.
--
-- PARAMETERS  : p_po_header_id - document ID
--
-- RETURNS     : x_pay_on_code   - Pay On Lookup Code
--               x_bill_to_id    - Bill-To Location ID
--               x_ship_to_id    - Ship-To Location ID
--               x_ship_via_code - Carrier (Ship Via) Lookup Code
---
-- EXCEPTIONS  : -
--=============================================================================
PROCEDURE get_local_terms_conditions
(
    p_po_header_id    IN         PO_HEADERS_ALL.po_header_id%TYPE
,   x_pay_on_code     OUT NOCOPY PO_HEADERS_ALL.pay_on_code%TYPE
,   x_bill_to_id      OUT NOCOPY PO_HEADERS_ALL.bill_to_location_id%TYPE
,   x_ship_to_id      OUT NOCOPY PO_HEADERS_ALL.ship_to_location_id%TYPE
,   x_ship_via_code   OUT NOCOPY PO_HEADERS_ALL.ship_via_lookup_code%TYPE
)
IS
BEGIN

    SELECT    pay_on_code
    ,         bill_to_location_id
    ,         ship_to_location_id
    ,         ship_via_lookup_code
    INTO      x_pay_on_code
    ,         x_bill_to_id
    ,         x_ship_to_id
    ,         x_ship_via_code
    FROM      po_headers_all
    WHERE     po_header_id = p_po_header_id;

EXCEPTION

    WHEN OTHERS THEN
        x_pay_on_code := NULL;
        x_bill_to_id  := NULL;
        x_ship_to_id  := NULL;
        x_ship_via_code := NULL;

END get_local_terms_conditions;

-- <GC FPJ START>

-- bug3225062 START

-----------------------------------------------------------------------
--Start of Comments
--Name: compare_terms_conditions
--Pre-reqs:
--Modifies:
--Locks:
--Function: Compare the values in p_terms_rec1 and p_terms_rec2. If
--          they are different, the result will be reflected in
--          x_comparison_result
--Parameters:
--IN:
--p_comparison_scrop
--  GLOBAL: only compare global terms
--  LOCAL:  only compare local terms
--  ALL:    compare global and local terms
--p_terms_rec1
--  Record containing first set of terms and conditions
--p_terms_rec2
--  Record containing second set of terms and conditions
--IN OUT:
--OUT:
--x_same_terms
--  FND_API.G_TRUE if p_terms_rec1 and p_terms_rec2 have the same terms
--                 and conditions within the scope
--  FND_API.G_FALSE if any of the terms and conditions between two records
--                 differs within the scope
--x_comparison_result
--  For each term in p_terms_rec1 and p_terms_rec2, if the value is the
--  same, 'Y' will be put into the corresponding entry in
--  x_comparison_result. Otherwise, a 'N' will be put in
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------

PROCEDURE compare_terms_conditions
(  p_comparison_scope     IN         VARCHAR2,
   p_terms_rec1           IN         terms_and_cond_rec_type,
   p_terms_rec2           IN         terms_and_cond_rec_type,
   x_same_terms           OUT NOCOPY VARCHAR2,
   x_comparison_result    OUT NOCOPY terms_cond_comp_rec_type
) IS

l_api_name  CONSTANT VARCHAR2(50) := 'compare_terms_conditions';

BEGIN
    x_same_terms := FND_API.G_TRUE;

    IF (p_comparison_scope IN (G_COMPARISON_SCOPE_GLOBAL,
                               G_COMPARISON_SCOPE_ALL)) THEN

        SELECT DECODE (p_terms_rec1.terms_id,
                       p_terms_rec2.terms_id, 'Y', 'N'),
               DECODE (p_terms_rec1.fob_lookup_code,
                       p_terms_rec2.fob_lookup_code, 'Y', 'N'),
               DECODE (p_terms_rec1.freight_terms_lookup_code,
                       p_terms_rec2.freight_terms_lookup_code, 'Y', 'N'),
               DECODE (p_terms_rec1.note_to_vendor,
                       p_terms_rec2.note_to_vendor, 'Y', 'N'),
               DECODE (p_terms_rec1.note_to_receiver,
                       p_terms_rec2.note_to_receiver, 'Y', 'N'),
               DECODE (p_terms_rec1.shipping_control,
                       p_terms_rec2.shipping_control, 'Y', 'N')
        INTO   x_comparison_result.terms_id_eq,
               x_comparison_result.fob_lookup_code_eq,
               x_comparison_result.freight_terms_lookup_code_eq,
               x_comparison_result.note_to_vendor_eq,
               x_comparison_result.note_to_receiver_eq,
               x_comparison_result.shipping_control_eq
        FROM dual;

        IF (x_comparison_result.terms_id_eq = 'N' OR
            x_comparison_result.fob_lookup_code_eq = 'N' OR
            x_comparison_result.freight_terms_lookup_code_eq = 'N' OR
            x_comparison_result.note_to_vendor_eq = 'N' OR
            x_comparison_result.note_to_receiver_eq = 'N' OR
            x_comparison_result.shipping_control_eq = 'N') THEN

            x_same_terms := FND_API.G_FALSE;
        END IF;

    END IF;  -- scope IN ('GLOBAL', 'ALL')

    IF (p_comparison_scope IN (G_COMPARISON_SCOPE_LOCAL,
                               G_COMPARISON_SCOPE_ALL)) THEN

        SELECT DECODE (p_terms_rec1.pay_on_code,
                       p_terms_rec2.pay_on_code, 'Y', 'N'),
               DECODE (p_terms_rec1.bill_to_location_id,
                       p_terms_rec2.bill_to_location_id, 'Y', 'N'),
               DECODE (p_terms_rec1.ship_to_location_id,
                       p_terms_rec2.ship_to_location_id, 'Y', 'N'),
               DECODE (p_terms_rec1.ship_via_lookup_code,
                       p_terms_rec2.ship_via_lookup_code, 'Y', 'N')
        INTO   x_comparison_result.pay_on_code_eq,
               x_comparison_result.bill_to_location_id_eq,
               x_comparison_result.ship_to_location_id_eq,
               x_comparison_result.ship_via_lookup_code_eq
        FROM   dual;

        IF (x_comparison_result.pay_on_code_eq = 'N' OR
            x_comparison_result.bill_to_location_id_eq = 'N' OR
            x_comparison_result.ship_to_location_id_eq = 'N' OR
            x_comparison_result.ship_via_lookup_code_eq = 'N') THEN

            x_same_terms := FND_API.G_FALSE;
        END IF;

    END IF;  -- scope IN ('LOCAL', 'ALL')

EXCEPTION
    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error(l_api_name, '000', sqlcode);
        RAISE;
END compare_terms_conditions;

-----------------------------------------------------------------------
--Start of Comments
--Name: set_terms_comparison_msg
--Pre-reqs:
--Modifies:
--Locks:
--Function: Construct the message for displaying the difference between
--          p_terms_rec1 and p_terms_rec2
--Parameters:
--IN:
--p_ref_doc_type
--  Type of reference documents
--p_comparison_scope
--  GLOBAL: only compare global terms
--  LOCAL:  only compare local terms
--  ALL:    compare global and local terms
--p_terms_rec1
--  Record containing first set of terms and conditions
--p_terms_rec2
--  Record containing second set of terms and conditions
--p_comparison_result
--  Indicate whether the terms are different for each entry in
--  p_terms_rec1 and p_terms_rec2
--IN OUT:
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE set_terms_comparison_msg
(  p_ref_doc_type         IN         VARCHAR2,
   p_comparison_scope     IN         VARCHAR2,
   p_terms_rec1           IN         terms_and_cond_rec_type,
   p_terms_rec2           IN         terms_and_cond_rec_type,
   p_comparison_result    IN         terms_cond_comp_rec_type
) IS

l_api_name      CONSTANT VARCHAR2(50) := 'set_terms_comparison_msg';

l_doc_type_token FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;
l_po_terms_val  VARCHAR2(2000);
l_ref_terms_val VARCHAR2(2000);
l_po_terms_list  VARCHAR2(2000);
l_ref_terms_list VARCHAR2(2000);
l_prompt             VARCHAR2(200);

l_num_terms_to_compare CONSTANT NUMBER := 10;

BEGIN
    IF (p_ref_doc_type = 'CONTRACT') THEN
        FND_MESSAGE.set_name('PO', 'PO_CONTRACT_AGREEMENT');
        l_doc_type_token := FND_MESSAGE.get;
    ELSIF (p_ref_doc_type IN ('QUOTATION', 'GA')) THEN
        PO_CORE_S.get_displayed_value
        ( x_lookup_type => 'PO SOURCE DOCUMENT TYPE',
          x_lookup_code => p_ref_doc_type,
          x_disp_value  => l_doc_type_token
        );
    END IF;

    FND_MESSAGE.set_name('PO', 'PO_PO_AND_REF_TERMS_MISMATCH');

    FND_MESSAGE.set_token('DOC_TYPE', l_doc_type_token);

    IF (p_comparison_scope IN (G_COMPARISON_SCOPE_GLOBAL,
                               G_COMPARISON_SCOPE_ALL)) THEN

        IF (p_comparison_result.terms_id_eq = 'N') THEN
             l_prompt := FND_MESSAGE.get_string('PO', 'POS_PAYMENT_TERMS');

             l_po_terms_val :=
                           PO_VENDORS_SV.get_terms_dsp(p_terms_rec1.terms_id);
             l_ref_terms_val :=
                           PO_VENDORS_SV.get_terms_dsp(p_terms_rec2.terms_id);

             set_terms_token (p_prompt           => l_prompt,
                              p_po_terms_val     => l_po_terms_val,
                              p_ref_terms_val    => l_ref_terms_val,
                              x_po_terms_list    => l_po_terms_list,
                              x_ref_terms_list   => l_ref_terms_list);
        END IF;

        IF (p_comparison_result.fob_lookup_code_eq = 'N') THEN
             l_prompt := FND_MESSAGE.get_string('PO', 'POS_FOB');

             PO_CORE_S.get_displayed_value
             (  x_lookup_type => 'FOB',
                x_lookup_code => p_terms_rec1.fob_lookup_code,
                x_disp_value  => l_po_terms_val
             );

             PO_CORE_S.get_displayed_value
             (  x_lookup_type => 'FOB',
                x_lookup_code => p_terms_rec2.fob_lookup_code,
                x_disp_value  => l_ref_terms_val
             );

             set_terms_token (p_prompt           => l_prompt,
                              p_po_terms_val     => l_po_terms_val,
                              p_ref_terms_val    => l_ref_terms_val,
                              x_po_terms_list    => l_po_terms_list,
                              x_ref_terms_list   => l_ref_terms_list);
        END IF;

        IF (p_comparison_result.freight_terms_lookup_code_eq = 'N') THEN
             l_prompt := FND_MESSAGE.get_string('PO', 'POS_FREIGHT_TERMS');

             PO_CORE_S.get_displayed_value
             (  x_lookup_type => 'FREIGHT TERMS',
                x_lookup_code => p_terms_rec1.freight_terms_lookup_code,
                x_disp_value  => l_po_terms_val
             );

             PO_CORE_S.get_displayed_value
             (  x_lookup_type => 'FREIGHT TERMS',
                x_lookup_code => p_terms_rec2.freight_terms_lookup_code,
                x_disp_value  => l_ref_terms_val
             );

             set_terms_token (p_prompt           => l_prompt,
                              p_po_terms_val     => l_po_terms_val,
                              p_ref_terms_val    => l_ref_terms_val,
                              x_po_terms_list    => l_po_terms_list,
                              x_ref_terms_list   => l_ref_terms_list);
        END IF;

        IF (p_comparison_result.note_to_vendor_eq = 'N') THEN
             l_prompt := FND_MESSAGE.get_string('PO', 'POS_NOTE_TO_VENDOR');

             l_po_terms_val := SUBSTRB(p_terms_rec1.note_to_vendor, 1, 200);
             l_ref_terms_val := SUBSTRB(p_terms_rec2.note_to_vendor, 1, 200);

             set_terms_token (p_prompt           => l_prompt,
                              p_po_terms_val     => l_po_terms_val,
                              p_ref_terms_val    => l_ref_terms_val,
                              x_po_terms_list    => l_po_terms_list,
                              x_ref_terms_list   => l_ref_terms_list);
        END IF;

        IF (p_comparison_result.note_to_receiver_eq = 'N') THEN
             l_prompt := FND_MESSAGE.get_string('PO', 'POS_NOTE_TO_RECEIVER');

             l_po_terms_val := SUBSTRB(p_terms_rec1.note_to_receiver, 1, 200);
             l_ref_terms_val := SUBSTRB(p_terms_rec2.note_to_receiver, 1, 200);

             set_terms_token (p_prompt           => l_prompt,
                              p_po_terms_val     => l_po_terms_val,
                              p_ref_terms_val    => l_ref_terms_val,
                              x_po_terms_list    => l_po_terms_list,
                              x_ref_terms_list   => l_ref_terms_list);
        END IF;

        IF (p_comparison_result.shipping_control_eq = 'N') THEN
             l_prompt := FND_MESSAGE.get_string('PO', 'POS_SHIPPING_CONTROL');

             PO_CORE_S.get_displayed_value
             (  x_lookup_type => 'SHIPPING CONTROL',
                x_lookup_code => p_terms_rec1.shipping_control,
                x_disp_value  => l_po_terms_val
             );

             PO_CORE_S.get_displayed_value
             (  x_lookup_type => 'SHIPPING CONTROL',
                x_lookup_code => p_terms_rec2.shipping_control,
                x_disp_value  => l_ref_terms_val
             );

             set_terms_token (p_prompt           => l_prompt,
                              p_po_terms_val     => l_po_terms_val,
                              p_ref_terms_val    => l_ref_terms_val,
                              x_po_terms_list    => l_po_terms_list,
                              x_ref_terms_list   => l_ref_terms_list);
        END IF;
    END IF;  -- scope IN ('GLOBAL', 'ALL')

    IF (p_comparison_scope IN (G_COMPARISON_SCOPE_LOCAL,
                               G_COMPARISON_SCOPE_ALL)) THEN

        IF (p_comparison_result.pay_on_code_eq = 'N') THEN
             l_prompt := FND_MESSAGE.get_string('PO', 'POS_PAY_ON');

             PO_CORE_S.get_displayed_value
             (  x_lookup_type => 'PAY ON CODE',
                x_lookup_code => p_terms_rec1.pay_on_code,
                x_disp_value  => l_po_terms_val
             );

             PO_CORE_S.get_displayed_value
             (  x_lookup_type => 'PAY ON CODE',
                x_lookup_code => p_terms_rec2.pay_on_code,
                x_disp_value  => l_ref_terms_val
             );

             set_terms_token (p_prompt           => l_prompt,
                              p_po_terms_val     => l_po_terms_val,
                              p_ref_terms_val    => l_ref_terms_val,
                              x_po_terms_list    => l_po_terms_list,
                              x_ref_terms_list   => l_ref_terms_list);
        END IF;

        IF (p_comparison_result.bill_to_location_id_eq = 'N') THEN
             l_prompt := FND_MESSAGE.get_string('PO', 'POS_BILL_TO');

             l_po_terms_val :=
                 PO_LOCATIONS_S.get_location_code
                 ( p_location_id => p_terms_rec1.bill_to_location_id
                 );

             l_ref_terms_val :=
                 PO_LOCATIONS_S.get_location_code
                 ( p_location_id => p_terms_rec2.bill_to_location_id
                 );

             set_terms_token (p_prompt           => l_prompt,
                              p_po_terms_val     => l_po_terms_val,
                              p_ref_terms_val    => l_ref_terms_val,
                              x_po_terms_list    => l_po_terms_list,
                              x_ref_terms_list   => l_ref_terms_list);
        END IF;

        IF (p_comparison_result.ship_to_location_id_eq = 'N') THEN
             l_prompt := FND_MESSAGE.get_string('PO', 'POS_SHIP_TO');

             l_po_terms_val :=
                 PO_LOCATIONS_S.get_location_code
                 ( p_location_id => p_terms_rec1.ship_to_location_id
                 );

             l_ref_terms_val :=
                 PO_LOCATIONS_S.get_location_code
                 ( p_location_id => p_terms_rec2.ship_to_location_id
                 );

             set_terms_token (p_prompt           => l_prompt,
                              p_po_terms_val     => l_po_terms_val,
                              p_ref_terms_val    => l_ref_terms_val,
                              x_po_terms_list    => l_po_terms_list,
                              x_ref_terms_list   => l_ref_terms_list);
        END IF;

        IF (p_comparison_result.ship_via_lookup_code_eq = 'N') THEN
             l_prompt := FND_MESSAGE.get_string('PO', 'POS_SHIP_VIA');

             l_po_terms_val := p_terms_rec1.ship_via_lookup_code;
             l_ref_terms_val := p_terms_rec2.ship_via_lookup_code;

             set_terms_token (p_prompt           => l_prompt,
                              p_po_terms_val     => l_po_terms_val,
                              p_ref_terms_val    => l_ref_terms_val,
                              x_po_terms_list    => l_po_terms_list,
                              x_ref_terms_list   => l_ref_terms_list);
        END IF;

    END IF;  -- scope IN ('LOCAL', 'ALL')

    FND_MESSAGE.set_name('PO', 'PO_PO_AND_REF_TERMS_MISMATCH');

    FND_MESSAGE.set_token('DOC_TYPE', l_doc_type_token);
    FND_MESSAGE.set_token('PO_TERMS', l_po_terms_list);
    FND_MESSAGE.set_token('REF_DOC_TERMS', l_ref_terms_list);

EXCEPTION
    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error(l_api_name, '000', sqlcode);
        RAISE;
END set_terms_comparison_msg;

-----------------------------------------------------------------------
--Start of Comments
--Name: set_terms_token
--Pre-reqs:
--Modifies:
--Locks:
--Function: Construct x_po_terms_list and x_ref_terms_list that
--          list the terms and conditions for the PO and Referencing
--          document
--Parameters:
--IN:
--p_prompt
--  Name of the terms
--p_po_terms_val
--  Value of the terms in PO
--p_ref_terms_val
--  Value of the terms in Referencing Document
--IN OUT:
--x_po_terms_list
--  a String holding the terms information in PO
--x_ref_terms_list
--  a string holding the terms information in Referencing Document
--OUT:
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE set_terms_token
( p_prompt           IN            VARCHAR2,
  p_po_terms_val     IN            VARCHAR2,
  p_ref_terms_val    IN            VARCHAR2,
  x_po_terms_list     IN OUT NOCOPY VARCHAR2,
  x_ref_terms_list    IN OUT NOCOPY VARCHAR2
) IS

l_api_name   CONSTANT VARCHAR2(50) := 'set_terms_token';
l_token_num VARCHAR2(2);
l_colon     VARCHAR2(3);
l_line_break VARCHAR2(1);
BEGIN

    FND_MESSAGE.set_name ('PO', 'PO_ATTR_PROMPT_AND_VALUE');
    FND_MESSAGE.set_token ('ATTRIBUTE', p_prompt);
    FND_MESSAGE.set_token ('VALUE', p_po_terms_val);
    x_po_terms_list := x_po_terms_list || FND_MESSAGE.get;

    FND_MESSAGE.set_name ('PO', 'PO_ATTR_PROMPT_AND_VALUE');
    FND_MESSAGE.set_token ('ATTRIBUTE', p_prompt);
    FND_MESSAGE.set_token ('VALUE', p_ref_terms_val);
    x_ref_terms_list := x_ref_terms_list || FND_MESSAGE.get;

EXCEPTION
    WHEN OTHERS THEN
        PO_MESSAGE_S.sql_error(l_api_name, '000', sqlcode);
        RAISE;
END set_terms_token;

-- bug3225062 END

-- <GC FPJ END>

end PO_TERMS_SV;

/
