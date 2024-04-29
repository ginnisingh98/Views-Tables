--------------------------------------------------------
--  DDL for Package Body OM_REPORTS_COMMON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OM_REPORTS_COMMON_PKG" AS
/* $Header: OEXCMPKB.pls 115.9 2003/10/20 06:51:03 appldev ship $ */

FUNCTION OEXOEORS_GET_WORKFLOW_DATE (n_line_id number) RETURN DATE IS
  ans_date DATE;

BEGIN

 SELECT nvl(wfas.end_date,sysdate)
 INTO ans_date
 FROM wf_item_activity_statuses wfas, wf_process_activities wpa
 WHERE wfas.item_key = TO_CHAR(n_line_id) and
 wfas.item_type = 'OEOL' and
 wfas.process_activity = wpa.instance_id and
 wpa.activity_item_type = 'OEOL' and
 wpa.activity_name = 'RMA_WAIT_FOR_INSPECTION';

 RETURN ans_date;

EXCEPTION
 WHEN NO_DATA_FOUND THEN
   ans_date := sysdate;
   RETURN ans_date;
 WHEN OTHERS THEN
   ans_date := sysdate;
   RETURN ans_date;

END OEXOEORS_GET_WORKFLOW_DATE;


FUNCTION OEXOESOS_LINE_AMOUNT_TOTAL (p_header number) RETURN NUMBER IS
   ans number;
BEGIN

--  SELECT sum(nvl(l.ordered_quantity,0)*nvl(unit_selling_price,0)) Changed for the bug 3087563
  SELECT sum(decode(l.line_category_code,'RETURN',(nvl(l.ordered_quantity,0)*nvl(l.unit_selling_price,0) * (-1)),nvl(l.ordered_quantity,0)*nvl(l.unit_selling_price,0)))
  INTO ans
  FROM oe_order_lines_all l
  WHERE l.header_id=p_header  and
         l.line_id not in (
                select s.line_id from oe_sales_credits s
                 where s.header_id=p_header
                   and s.line_id is not null);
   RETURN ans;

END OEXOESOS_LINE_AMOUNT_TOTAL;

FUNCTION OEXCRDIS_GET_LOT_SERIAL_CTL (n_inv_item_id number, n_org_id number) RETURN NUMBER IS
 lot_serial_control NUMBER;

BEGIN

 SELECT
decode(
(  decode( lot_control_code, NULL, 'N', 1, 'N', 'Y') ||
   decode(serial_number_control_code, NULL, 'N', 1, 'N', 'Y')   ),
'YY', 3,
'NY', 1,
'YN', 2,
0 )
 INTO lot_serial_control
 FROM mtl_system_items
 WHERE inventory_item_id = n_inv_item_id
 AND   organization_id = n_org_id;
 RETURN lot_serial_control;

EXCEPTION
 WHEN NO_DATA_FOUND THEN
 lot_serial_control := 0;

 RETURN lot_serial_control;

END OEXCRDIS_GET_LOT_SERIAL_CTL;

FUNCTION DF_VALIDATE_FLEX(dff_name VARCHAR2,values_or_ids VARCHAR2) RETURN BOOLEAN IS
BEGIN
	RETURN FND_FLEX_DESCVAL.validate_desccols('ONT',dff_name,values_or_ids);
END DF_VALIDATE_FLEX;

Procedure DF_SET_COLUMN_VALUE(column_name VARCHAR2,column_value VARCHAR2) IS
BEGIN
	FND_FLEX_DESCVAL.set_column_value(column_name,column_value);
END DF_SET_COLUMN_VALUE;

Procedure DF_SET_CONTEXT(context VARCHAR2) IS
BEGIN
	FND_FLEX_DESCVAL.set_context_value(context);
END DF_SET_CONTEXT;

FUNCTION  DF_CONCATENATED_VALUES RETURN VARCHAR2 IS
BEGIN
	RETURN FND_FLEX_DESCVAL.concatenated_values;
END DF_CONCATENATED_VALUES;

FUNCTION  DF_CONCATENATED_DESCRIPTIONS RETURN VARCHAR2 IS
BEGIN
	RETURN FND_FLEX_DESCVAL.concatenated_descriptions;
END DF_CONCATENATED_DESCRIPTIONS;

END OM_REPORTS_COMMON_PKG;

/
