--------------------------------------------------------
--  DDL for Package Body PO_DOCUMENT_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOCUMENT_UTIL_PVT" as
-- $Header: PO_DOCUMENT_UTIL_PVT.plb 120.2.12010000.11 2012/01/31 09:57:11 vmec ship $

--------------------------------------------------------------------------
-- Modules for debugging.
--------------------------------------------------------------------------

-- The module base for this package.
D_PACKAGE_BASE CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_DOCUMENT_UTIL_PVT');

-- The module base for the subprogram.
D_synchronize_gt_tables CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'synchronize_gt_tables');
D_initialize_gt_table CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'initialize_gt_table');
D_get_plc_status CONSTANT VARCHAR2(100) :=
  PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'get_plc_status');




PROCEDURE synchronize_gt_tables (
  p_key                IN           NUMBER
, p_index_num1_vals    IN           PO_TBL_NUMBER
, p_index_num2_vals    IN           PO_TBL_NUMBER
)
IS
  d_mod     CONSTANT VARCHAR2(100) := D_synchronize_gt_tables;

BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod);
  END IF;

  -- Remove any values for this gt key
  DELETE FROM PO_SESSION_GT
  WHERE key = p_key;

  -- Bulk insert new values
  FORALL i IN 1 .. p_index_num1_vals.COUNT
    INSERT INTO PO_SESSION_GT
    (  key
     , index_num1
     , index_num2
    )
    VALUES
    (
       p_key
     , p_index_num1_vals(i)
     , p_index_num2_vals(i)
    );

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_end(d_mod);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;

END synchronize_gt_tables;

/*==================================================================
  FUNCTION NAME:           initialize_gt_table

  DESCRIPTION:             Inserts the values into PO_SESSION_GT at
                           a new key, returning the key.

  PARAMETERS:              p_index_num1_vals - the values to be inserted into
                                   the GT Table's index_num1 column.
                           p_index_num2_vals - the values to be inserted into
                                   the GT Table's index_num2 column.
====================================================================*/
FUNCTION initialize_gt_table (
  p_index_num1_vals    IN          PO_TBL_NUMBER
, p_index_num2_vals    IN          PO_TBL_NUMBER)
RETURN NUMBER

IS
  d_mod     CONSTANT VARCHAR2(100) := D_initialize_gt_table;
  l_key     NUMBER;

BEGIN

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_begin(d_mod, 'l_key', l_key);
  END IF;

  -- Get the next key for the session
  l_key := PO_CORE_S.get_session_gt_nextval;

  -- Insert the values into the GT table
  synchronize_gt_tables(
    p_key => l_key,
    p_index_num1_vals => p_index_num1_vals,
    p_index_num2_vals => p_index_num2_vals);

  IF PO_LOG.d_proc THEN
    PO_LOG.proc_end(d_mod);
  END IF;

  RETURN(l_key);

EXCEPTION
  WHEN OTHERS THEN
    IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,0,NULL);
    END IF;
    RAISE;


END initialize_gt_table;

/*==================================================================
  FUNCTION NAME:           get_plc_status

  DESCRIPTION:             Returns the concatenated status of document.

  PARAMETERS:              p_header_id:Document header id.
====================================================================*/

FUNCTION get_plc_status (
  p_header_id IN NUMBER)
RETURN VARCHAR2

IS
  disp_field_sta VARCHAR2(1000);
  l_progress     NUMBER := 0;
  d_mod     CONSTANT VARCHAR2(100) := D_get_plc_status;
  l_approved_flag               VARCHAR2(1);
  l_authorization_status        VARCHAR2(40);
  l_cancel_flag                 VARCHAR2(1);
  l_closed_code                 VARCHAR2(40);
  l_frozen_flag                 VARCHAR2(1);
  l_user_hold_flag              VARCHAR2(1);
  l_temp                        VARCHAR2(100);

BEGIN

 l_progress := 1;

 SELECT approved_flag,authorization_status,cancel_flag,closed_code,frozen_flag,user_hold_flag
   INTO l_approved_flag,l_authorization_status,l_cancel_flag,l_closed_code,l_frozen_flag,l_user_hold_flag
   FROM po_headers_all
  WHERE po_header_id = p_header_id;

  l_progress := 2;
  SELECT displayed_field
    INTO disp_field_sta
    FROM po_lookup_codes
   WHERE lookup_code = DECODE(l_approved_flag,
                                 'R', l_approved_flag,
           NVL(l_authorization_status, 'INCOMPLETE'))
     AND lookup_type IN ( 'PO APPROVAL', 'DOCUMENT STATE' );

   l_progress := 3;

   IF l_cancel_flag = 'Y'
   THEN
   SELECT displayed_field
     INTO l_temp
     FROM po_lookup_codes
    WHERE lookup_code = 'CANCELLED'
      AND lookup_type = 'DOCUMENT STATE';
   ELSE
     l_temp := NULL;
   END IF;

   disp_field_sta := disp_field_sta || ' ' || l_temp;

   l_temp := NULL;

   l_progress := 4;

   IF NVL(l_closed_code, 'OPEN') <> 'OPEN'
   THEN
   SELECT displayed_field
     INTO l_temp
     FROM po_lookup_codes
    WHERE lookup_code = NVL(l_closed_code, 'OPEN')
      AND lookup_type = 'DOCUMENT STATE';
   ELSE
     l_temp := NULL;
   END IF;

   disp_field_sta := disp_field_sta || ' ' || l_temp;

   l_temp := NULL;

   l_progress := 5;

   IF l_frozen_flag= 'Y'
   THEN
   SELECT displayed_field
     INTO l_temp
     FROM po_lookup_codes
    WHERE lookup_type = 'DOCUMENT STATE'
      AND lookup_code = 'FROZEN';
   ELSE
     l_temp := NULL;
   END IF;

   disp_field_sta := disp_field_sta || ' ' || l_temp;

   l_temp := NULL;

   l_progress := 6;

   IF l_user_hold_flag = 'Y'
   THEN
   SELECT displayed_field
     INTO l_temp
     FROM po_lookup_codes
    WHERE lookup_type = 'DOCUMENT STATE'
      AND lookup_code = 'ON HOLD';
   ELSE
     l_temp := NULL;
   END IF;

   disp_field_sta := disp_field_sta || ' ' || l_temp;


RETURN(disp_field_sta) ;

EXCEPTION WHEN OTHERS THEN
IF PO_LOG.d_exc THEN
      PO_LOG.exc(d_mod,l_progress,NULL);
 END IF;
RETURN NULL;
END get_plc_status;

/*==================================================================
 *   FUNCTION NAME:           get_prorated_tax
 *
 *   DESCRIPTION:             Returns tax only for uncancelled quantity
 *
 *   PARAMETERS:              p_header_id,po_line_id,line_location_id
 *
 *                            Only for line_location if line id is null
 *                            For line if location_id is null
 *====================================================================*/
FUNCTION get_prorated_tax(x_header_id IN NUMBER, x_line_id IN NUMBER,
x_line_location_id IN NUMBER) return NUMBER


is


l_prorated_tax NUMBER;

BEGIN

IF(x_line_id is NULL and x_line_location_id is NULL) THEN
select SUM (( quantity_ordered - quantity_cancelled ) /
decode(quantity_ordered,0,1,quantity_ordered ) *
nonrecoverable_tax)
into l_prorated_tax
from po_distributions_all
where po_header_id = x_header_id;
END IF;

IF(x_line_id is NOT NULL and x_line_location_id is NULL) THEN
select SUM (( quantity_ordered - quantity_cancelled ) /
decode(quantity_ordered,0,1,quantity_ordered ) *
nonrecoverable_tax)
into l_prorated_tax
from po_distributions_all
where po_header_id = x_header_id
and po_line_id = x_line_id;

END IF;

IF(x_line_id is NULL and x_line_location_id is  NOT NULL) THEN
select SUM (( quantity_ordered - quantity_cancelled ) /
decode(quantity_ordered,0,1,quantity_ordered ) *
nonrecoverable_tax)
into l_prorated_tax
from po_distributions_all
where po_header_id = x_header_id
and line_location_id = x_line_location_id;
END IF;

return l_prorated_tax;

END get_prorated_tax;

FUNCTION get_amount_billed(x_header_id IN NUMBER, x_line_id IN NUMBER) return NUMBER is

l_amount_billed NUMBER;

BEGIN

IF(x_line_id is NULL) THEN

select sum(amount_billed)
into l_amount_billed
from po_distributions_all
where po_header_id = x_header_id;

END IF;

IF(x_line_id is NOT NULL) THEN

select sum(amount_billed)
into l_amount_billed
from po_distributions_all
where po_header_id = x_header_id
and po_line_id = x_line_id;

END IF;

return l_amount_billed;

end get_amount_billed;


END PO_DOCUMENT_UTIL_PVT;

/
