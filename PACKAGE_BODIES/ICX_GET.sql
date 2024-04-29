--------------------------------------------------------
--  DDL for Package Body ICX_GET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_GET" as
/* $Header: ICXGETB.pls 115.6 2001/12/05 15:54:00 pkm ship     $ */

-- ***** GET_ACTION_HISTORY_DATE function *****

-- Function used to return the action dates from the PO_ACTION_HISTORY
-- table for different action codes (approved, closed, etc.)
-- and object types (requisitions, purchase, etc.)

FUNCTION get_action_history_date (x_object_id        	IN NUMBER,
				          x_object_type_code 	IN VARCHAR2,
				          x_subtype_code	IN VARCHAR2,
				          x_action_code		IN VARCHAR2)
					    RETURN DATE IS
x_action_date DATE;
BEGIN
  /* Get the action date  */
  SELECT action_date
  INTO   x_action_date
  FROM   PO_ACTION_HISTORY
  WHERE  object_id = x_object_id
  AND    object_type_code like x_object_type_code
  AND    object_sub_type_code like x_subtype_code
  AND	 action_code like x_action_code
  AND    not exists
           ( SELECT action_date
             FROM   PO_ACTION_HISTORY
             WHERE  object_id = x_object_id
             AND    object_type_code =   x_object_type_code
             AND    object_sub_type_code = x_subtype_code
             AND    action_code is null);
  RETURN (x_action_date);
 EXCEPTION
  WHEN OTHERS THEN
    return null;
END;


-- ***** GET_AVAIL_TIME_COUNT function *****

-- Function used to retrieve the available item count for all quotations
-- and blankets

FUNCTION get_avail_item_count (x_vendor_id IN NUMBER,
			             x_category_id IN NUMBER)
					 RETURN NUMBER IS
x_item_count NUMBER := 0;
BEGIN
 select	count(distinct pol.item_id)
 into	x_item_count
 from 	po_headers poh
	, po_lines pol
 where 	poh.po_header_id = pol.po_header_id
 and 	((poh.type_lookup_code = 'QUOTATION' and poh.status_lookup_code = 'A')
	 or (poh.type_lookup_code = 'BLANKET' and poh.approved_flag = 'Y'))
 and	pol.category_id = x_category_id
 and 	pol.item_id is not null
 and 	poh.vendor_id = x_vendor_id;
  RETURN (nvl(x_item_count,0));
EXCEPTION
  WHEN OTHERS THEN
  RETURN (0);
END;


-- ***** GET_ORD_ITEM_COUNT function *****

-- Function to retrieve the item count, total quantity, and total
-- extended amount for ordered items

FUNCTION get_ord_item_count (x_vendor_id IN NUMBER,
				     x_type IN VARCHAR2,
				     x_category_id IN NUMBER)
				     RETURN NUMBER IS
x_count_or_sum NUMBER := 0;
BEGIN
select	decode(x_type, 'ITEM_COUNT', count(prl.item_id)
		     , 'QUANTITY_SUM', sum(prl.quantity)
		     , 'TOTAL_AMOUNT', sum(prl.unit_price*prl.quantity))
into	x_count_or_sum
from 	po_requisition_headers prh
	, po_requisition_lines prl
where 	prh.requisition_header_id = prl.requisition_header_id
and 	nvl(prh.authorization_status, 'APPROVE') <> 'INCOMPLETE'
and 	nvl(prh.cancel_flag,'N') <> 'Y'
and 	prl.vendor_id = x_vendor_id
and	prl.category_id = x_category_id
and 	prl.item_id is not null;
  RETURN (nvl(x_count_or_sum,0));
EXCEPTION
  WHEN OTHERS THEN
  RETURN (0);
END;


-- ***** GET_GL_ACCOUNT function *****

-- Function to get gl concatenated account number

FUNCTION get_gl_account (x_cc_id IN NUMBER)
				 RETURN VARCHAR2 IS
x_concat_segments VARCHAR2(155);
BEGIN
  /* Get the account number concatentated segments  */
  SELECT concatenated_segments
  INTO   x_concat_segments
  FROM   GL_CODE_COMBINATIONS_KFV
  WHERE  code_combination_id = x_cc_id;
  RETURN (x_concat_segments);
EXCEPTION
  WHEN OTHERS THEN
    return null;
END;


-- ***** GET_GL_VALUE function *****

-- Function to get the correct gl value for the cost center, company, or
-- account number regardless of which flex field segment column the value
-- is contained in

FUNCTION get_gl_value (appl_id in number,
			     id_flex_code in varchar2,
			     id_flex_num in number,
			     cc_id in number,
			     gl_qualifier in varchar2)
		           return varchar2 is
v_seg_value varchar2(40) := '';
v_seg_name varchar2(40) := '';
v_seg_number varchar2(40);
begin
select decode(upper(gl_qualifier)
		,'COST CENTER', 'FA_COST_CTR'
		,'COMPANY','GL_BALANCING'
		,'ACCOUNT','GL_ACCOUNT'
		, null)
into v_seg_name
from sys.dual;
if v_seg_name is null then
return null;
end if;
if FND_FLEX_APIS.get_segment_column(appl_id
				   , id_flex_code
				   , id_flex_num
				   , v_seg_name
				   , v_seg_number) = TRUE
  then
	begin
	select decode(v_seg_number
		,'SEGMENT1',SEGMENT1
		,'SEGMENT2', SEGMENT2
		,'SEGMENT3', SEGMENT3
		,'SEGMENT4', SEGMENT4
		,'SEGMENT5', SEGMENT5
		,'SEGMENT6', SEGMENT6
		,'SEGMENT7', SEGMENT7
		,'SEGMENT8', SEGMENT8
		,'SEGMENT9', SEGMENT9
		,'SEGMENT10', SEGMENT10
		,'SEGMENT11', SEGMENT11
		,'SEGMENT12', SEGMENT12
		,'SEGMENT13', SEGMENT13
		,'SEGMENT14', SEGMENT14
		,'SEGMENT15', SEGMENT15
		,'SEGMENT16', SEGMENT16
		,'SEGMENT17', SEGMENT17
		,'SEGMENT18', SEGMENT18
		,'SEGMENT19', SEGMENT19
		,'SEGMENT20', SEGMENT20
		,'SEGMENT21', SEGMENT21
		,'SEGMENT22', SEGMENT22
		,'SEGMENT23', SEGMENT23
		,'SEGMENT24', SEGMENT24
		,'SEGMENT25', SEGMENT25
		,'SEGMENT26', SEGMENT26
		,'SEGMENT27', SEGMENT27
		,'SEGMENT28', SEGMENT28
		,'SEGMENT29', SEGMENT29
		,'SEGMENT30', SEGMENT30)
	into v_seg_value
	from gl_code_combinations_kfv
	where code_combination_id = cc_id
	and rownum = 1;
	return(v_seg_value);
	exception
	  when others then
	return null;
	end;
  else
	return null;
end if;
end;

FUNCTION  get_person_name (x_person_id  IN  NUMBER) RETURN VARCHAR2 is

x_person_name  VARCHAR2(240);

BEGIN

  SELECT distinct full_name
  INTO   x_person_name
  FROM   PER_ALL_PEOPLE_F
  WHERE  x_person_id = person_id;

  return(x_person_name);

EXCEPTION
  WHEN OTHERS THEN
    return('');

END get_person_name;

end icx_get;

/
