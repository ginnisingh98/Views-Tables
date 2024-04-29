--------------------------------------------------------
--  DDL for Package Body POS_GET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_GET" as
/* $Header: POSGETUB.pls 120.0.12010000.3 2014/05/15 11:13:16 puppulur ship $*/

g_old_person_name VARCHAR2(240) := NULL;
g_old_person_id   NUMBER        := NULL;

/*===========================================================================

  FUNCTION NAME:	get_person_name()

===========================================================================*/
FUNCTION  get_person_name (x_person_id 	IN  NUMBER) RETURN VARCHAR2 is

x_person_name  VARCHAR2(240);

BEGIN

  -- Bug 8901874. Modified query to fetch data from table per_all_people_f.
  SELECT full_name
  INTO   x_person_name
  FROM   PER_ALL_PEOPLE_F
  WHERE  x_person_id = person_id
  AND EFFECTIVE_END_DATE >= ALL(SELECT EFFECTIVE_END_DATE
				FROM PER_ALL_PEOPLE_F
				WHERE PERSON_ID=x_person_id);

  return(x_person_name);

EXCEPTION
  WHEN OTHERS THEN
    return('');

END get_person_name;

/*===========================================================================

  FUNCTION NAME:	get_person_name_cache()

===========================================================================*/
FUNCTION  get_person_name_cache (x_person_id 	IN  NUMBER) RETURN VARCHAR2 is

x_person_name  VARCHAR2(240);

BEGIN

     /* Check to see if the values are already cached */
     if (((g_old_person_id = x_person_id)
        OR ((g_old_person_id is NULL)
           AND (x_person_id IS NULL)))
        AND (g_old_person_name is not NULL)) then
        return g_old_person_name;
     end if;

  x_person_name     := NULL;
  x_person_name     :=  get_person_name (x_person_id);
  g_old_person_id   :=  x_person_id;
  g_old_person_name :=  x_person_name;

  return(x_person_name);

EXCEPTION
  WHEN OTHERS THEN
    return('');

END get_person_name_cache;

/*===========================================================================
  FUNCTION NAME:  item_flex_seg
===========================================================================*/
function  item_flex_seg (
	ri		in 	rowid)
return varchar2 is
    ret_val varchar2(2000) := NULL;
begin
    if (ri is null) then
	return (null);
    else

	select msi.concatenated_segments
	into ret_val
	from mtl_system_items_kfv msi
	where rowid = ri;

        return(ret_val);
    end if;
end item_flex_seg;

/*===========================================================================
  FUNCTION NAME:  get_gl_account
===========================================================================*/

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

/*===========================================================================
  FUNCTION NAME:  get_gl_value
===========================================================================*/
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

/*===========================================================================
  FUNCTION NAME:  get_item_config
===========================================================================*/
function  get_item_config (
	   x_item_id in NUMBER,
           x_org_id  in NUMBER
          )
return varchar2 is
    ret_val varchar2(1) := NULL;
begin
    if (x_item_id is null) then
	return('F');
    else
    begin
	select 'T'
	into ret_val
	from mtl_system_items_kfv msi
	where msi.inventory_item_id = x_item_id
        and   msi.organization_id   = x_org_id
        and   msi.bom_item_type     = 4
        and   msi.base_item_id is not null
        and   nvl(msi.auto_created_config_flag, 'N') = 'Y';
        return(ret_val);
     exception
        when others then
         return('F');
     end;
    end if;
end get_item_config;

/*===========================================================================
  FUNCTION NAME:  get_item_number
===========================================================================*/
function  get_item_number ( x_item_id	in 	number,
			    x_org_id	in 	number)
return varchar2 is
    ret_val varchar2(2000) := NULL;
begin
    if (x_item_id is null) then
	return ('');
    else

	select msi.concatenated_segments
	into ret_val
	from mtl_system_items_kfv msi
	where inventory_item_id = x_item_id and
              organization_id = x_org_id;

        return(ret_val);
    end if;
end get_item_number;

FUNCTION pos_getstatus(p_closed_code VARCHAR2)
RETURN VARCHAR2
IS
l_display_code po_lookup_codes.displayed_field%TYPE;
BEGIN

  SELECT polc.displayed_field
  INTO l_display_code
  FROM po_lookup_codes polc
  WHERE
    POLC.LOOKUP_TYPE     = 'DOCUMENT STATE'
    AND lookup_code = Nvl(p_closed_code,'OPEN');

  RETURN l_display_code;

EXCEPTION
   WHEN OTHERS THEN
        RETURN NULL;

END pos_getstatus;

end POS_GET;

/
