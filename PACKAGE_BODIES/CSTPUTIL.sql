--------------------------------------------------------
--  DDL for Package Body CSTPUTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPUTIL" AS
/* $Header: CSTPUTIB.pls 120.2 2006/02/11 16:26:26 rthng noship $ */

-- PROCEDURE
--  CSTPUGCI		Return Currency Information
--
-- INPUT PARAMETERS
--  I_ORG_ID		Organization id
--
-- RETURN VALUES
--  O_ROUND_UNIT	Rounding Unit - extension of min acct unit, e.g.
--			ROUND(number/O_ROUND_UNIT)*O_ROUND_UNIT
--  O_PRECISION	Regular precision
--  O_EXT_PREC		Extended precision
--

PROCEDURE CSTPUGCI (
	 I_ORG_ID		IN	NUMBER,
	 O_ROUND_UNIT		OUT NOCOPY	NUMBER,
	 O_PRECISION		OUT NOCOPY	NUMBER,
	 O_EXT_PREC		OUT NOCOPY	NUMBER) IS

BEGIN

/* The following query will be changed to join to the base tables instead of the
    OOD  bug 2618959 */

	SELECT	NVL(FC.minimum_accountable_unit,
			POWER(10,NVL(-precision,0))),
		precision,
		extended_precision
	INTO	O_ROUND_UNIT, O_PRECISION, O_EXT_PREC
	FROM	fnd_currencies FC,
		gl_sets_of_books SOB,
		/*org_organization_definitions O */
                hr_organization_information O
        WHERE	O.organization_id = I_ORG_ID
	/*AND	O.set_of_books_id = SOB.set_of_books_id */
        AND     O.org_information1 = to_char(SOB.set_of_books_id)
        AND     O.org_information_context = 'Accounting Information'
	AND	SOB.currency_code = FC.currency_code
	AND	FC.enabled_flag = 'Y';

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		O_ROUND_UNIT := 1;
		O_PRECISION := 0;
		O_EXT_PREC := 0;
	WHEN OTHERS THEN
		raise_application_error(-20001, SQLERRM);

END CSTPUGCI;

--
-- PROCEDURE
--  Do_SQL		Executes a dynamic SQL statement
--
procedure do_sql(p_sql_stmt in varchar2) is
    cursor_id  integer;
    return_val integer;
    sql_stmt   varchar2(8192);
  begin
    -- set sql statement
    sql_stmt := p_sql_stmt;

    -- open a cursor
    cursor_id  := dbms_sql.open_cursor;

    -- parse sql statement
    dbms_sql.parse(cursor_id, sql_stmt, DBMS_SQL.V7);

    -- execute statement
    return_val := dbms_sql.execute(cursor_id);

    -- close cursor
    dbms_sql.close_cursor(cursor_id);
  end do_sql;


--
-- FUNCTION
--  get_item_desc               Get item description
--
-- INPUT PARAMETERS
--  Inv_item_id_in              Item id
--  Org_id_in                   Organization id
--
-- RETURN VALUES
--  l_item_description          Item description
--
--
  function get_item_desc (Inv_item_id_in IN number,
                          Org_id_in IN number)
           return varchar is
    l_item_description  varchar(240);
  Begin
    select description
    into   l_item_description
    from   mtl_system_items
    where  inventory_item_id = Inv_item_id_in
    and    organization_id = Org_id_in;

    return (l_item_description);
  Exception
    when TOO_MANY_ROWS then
      return(null);
    when NO_DATA_FOUND then
      return(null);
    when OTHERS then
      return(null);
  End get_item_desc;


--
-- FUNCTION
--  get_item_puom               Get primary UOM for the Item
--
-- INPUT PARAMETERS
--  Inv_item_id_in              Item id
--  Org_id_in                   Organization id
--
-- RETURN VALUES
--  l_item_puom                 Primary UOM of the item
--
--
  function get_item_puom (Inv_item_id_in IN number,
                          Org_id_in IN number)
           return varchar is
    l_item_puom  varchar(25);
  Begin
    select primary_uom_code
    into   l_item_puom
    from   mtl_system_items
    where  inventory_item_id = Inv_item_id_in
    and    organization_id = Org_id_in;

    return (l_item_puom);
  Exception
    when TOO_MANY_ROWS then
      return(null);
    when NO_DATA_FOUND then
      return(null);
    when OTHERS then
      return(null);
  End get_item_puom;


Procedure execute_insert_CIT(
                             p_view_name IN varchar2,
                             p_cost_org_id IN NUMBER,
                             p_ct_id       IN NUMBER,
                             p_item_id     IN NUMBER,
                             p_app_col_name IN VARCHAR2,
                             p_flex        IN NUMBER) IS

fptr    utl_file.file_type;
l_tmpbuf  VARCHAR2(9000);

BEGIN

IF (p_flex = 1) THEN
      l_tmpbuf :=
   	'BEGIN Insert into CST_INQUIRY_TEMP '||
	' ( SESSION_ID, INVENTORY_ITEM_ID, '||
	' ORGANIZATION_ID, '||
	' COST_TYPE_ID, '||
	' ITEM_COST, '||
	' THIS_LEVEL_COSTS, '||
	' PREVIOUS_LEVEL_COSTS, '||
 	' GUI_DESCRIPTION) '||
	' SELECT '||
	'SESSION_ID, INVENTORY_ITEM_ID '||
	', ORGANIZATION_ID '||
	', COST_TYPE_ID '||
	', SUM(ITEM_COST) '||
	', SUM(THIS_LEVEL_COSTS) '||
	', SUM(PREVIOUS_LEVEL_COSTS) '||
	','||
	p_app_col_name||
   	' FROM '||
	p_view_name||
    	' WHERE ORGANIZATION_ID =' ||
        ':cost_org_id' ||
	' AND COST_TYPE_ID='||
	':ct_id' ||
	' AND INVENTORY_ITEM_ID='||
	':item_id' ||
	' GROUP BY SESSION_ID, INVENTORY_ITEM_ID, '||
	' ORGANIZATION_ID, COST_TYPE_ID, '||
	p_app_col_name || '; END;';

  else

        l_tmpbuf :=
	  'BEGIN Insert into CST_INQUIRY_TEMP '||
	  '( SESSION_ID, INVENTORY_ITEM_ID, '||
	  'ORGANIZATION_ID, '||
	  'COST_TYPE_ID, OPERATION_SEQ_NUM, '||
	  'OPERATION_SEQUENCE_ID, DEPARTMENT_ID, '||
	  'ACTIVITY_ID, RESOURCE_ID, '||
	  'ITEM_COST, '||
	  'COST_ELEMENT_ID, '||
	  'THIS_LEVEL_COSTS, '||
	  'PREVIOUS_LEVEL_COSTS, '||
	  'VALUE_ADDED_ACTIVITY_FLAG, '||
	  'GUI_COLUMN1, GUI_COLUMN2, '||
	  'GUI_DESCRIPTION ) '||
	  'SELECT '||
	  'SESSION_ID, INVENTORY_ITEM_ID, '||
	  'ORGANIZATION_ID, '||
	  'COST_TYPE_ID, OPERATION_SEQ_NUM, '||
	  'OPERATION_SEQUENCE_ID, DEPARTMENT_ID, '||
	  'ACTIVITY_ID, RESOURCE_ID, '||
	  'NVL(ITEM_COST,0), '||
	  'COST_ELEMENT_ID, '||
	  'NVL(THIS_LEVEL_COSTS,0), '||
	  'NVL(PREVIOUS_LEVEL_COSTS,0), '||
	  'NULL, '||
	  'GUI_COLUMN1, GUI_COLUMN2, '||
	  'GUI_DESCRIPTION '||
	  'FROM '||
	  p_view_name ||
	  ' WHERE ORGANIZATION_ID =' ||
          ':cost_org_id' ||
	  ' AND COST_TYPE_ID='||
	  ':ct_id' ||
	  ' AND INVENTORY_ITEM_ID='||
          ':item_id; END;';

 end If;


   EXECUTE IMMEDIATE l_tmpbuf USING  p_cost_org_id,
                                     p_ct_id,
                                     p_item_id ;

END execute_insert_CIT;

END CSTPUTIL;

/
