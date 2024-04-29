--------------------------------------------------------
--  DDL for Package Body FFDBITEM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FFDBITEM" as
/* $Header: ffdbitem.pkb 115.0 99/07/16 02:02:17 porting ship $ */
--
--
--   Copyright (c) Oracle Corporation (UK) Ltd 1994.
--   All Rights Reserved.
--
--   PRODUCT
--     Oracle*FastFormula
--
--   NAME
--     ffdbitem
--
--   NOTES
--     Contains utility functions and procedures for accessing database
--     item SQL and values
--
--   MODIFIED
--   pgowers         09-FEB-94    Created
--   rneale	     19-MAY-94	  Added exit(G699)
--   jthuring        11-OCT-95    Removed spurious start of comment marker
--   mfender	     11-JUN-97	  Create package statement to standard for
--                                release 11.
--
-- PRIVATE CODE
--
-------------------------------- execute_error --------------------------------
--
-- NAME
--  execute_error
--
-- DESCRIPTION
--   Set error message and raise exception when called with error details
--
procedure execute_error (p_error_name in varchar2,
                         p_token1 in varchar2,
                         p_token2 in varchar2,
                         p_token3 in varchar2) is
begin
  hr_utility.set_location('ffdbitem.execute_error',1);
  hr_utility.set_message (802, p_error_name);
  hr_utility.set_message_token ('1', p_token1);
  hr_utility.set_message_token ('2', p_token2);
  hr_utility.set_message_token ('3', p_token3);
  hr_utility.raise_error;
end execute_error;

-------------------------- process_route_parameters --------------------------
--
-- NAME
--  process_route_parameters
--
-- DESCRIPTION
--   Replace route parameters where their equivalent values for the user
--   entity being processed
--
procedure process_route_parameters (p_item_name in varchar2,
                                    p_route_text in out varchar2,
                                    p_user_entity_id in number,
                                    p_route_id in number) is
  cursor route_parms is
  SELECT RP.SEQUENCE_NO,
         RP.PARAMETER_NAME,
         UPPER(RP.DATA_TYPE),
         RPV.VALUE
  FROM   FF_ROUTE_PARAMETERS RP,
         FF_ROUTE_PARAMETER_VALUES RPV
  WHERE  RP.ROUTE_ID = p_route_id
  AND    RP.ROUTE_PARAMETER_ID = RPV.ROUTE_PARAMETER_ID
  AND    RPV.USER_ENTITY_ID = p_user_entity_id
  ORDER  BY RP.SEQUENCE_NO;
--
  l_sequence_no FF_ROUTE_PARAMETERS.SEQUENCE_NO%TYPE;
  l_parameter_name FF_ROUTE_PARAMETERS.PARAMETER_NAME%TYPE;
  l_data_type FF_ROUTE_PARAMETERS.DATA_TYPE%TYPE;
  l_value FF_ROUTE_PARAMETER_VALUES.VALUE%TYPE;
--
begin
  hr_utility.set_location('ffdbitem.process_route_parameters',1);
  open route_parms;
  hr_utility.set_location('ffdbitem.process_route_parameters',2);
  loop
    fetch route_parms into l_sequence_no, l_parameter_name, l_data_type,
                           l_value;
    hr_utility.set_location('ffdbitem.process_route_parameters',3);
    if route_parms%notfound then
      close route_parms;
      exit;
    end if;
    -- Check that a placeholder exists, error if it doesn't
    if (instr(p_route_text, '&U'||to_char(l_sequence_no)) = 0) then
      hr_utility.set_message (802, 'FFT76_NO_MATCHING_U');
      hr_utility.set_message_token ('1',p_item_name);
      hr_utility.set_message_token ('2',l_parameter_name);
      hr_utility.raise_error;
    end if;
    hr_utility.set_location('ffdbitem.process_route_parameters',4);
    -- replace all instances of placeholder with route parameter value
    p_route_text := replace (p_route_text,
                             '&U'||to_char(l_sequence_no),
                             l_value);
    hr_utility.set_location('ffdbitem.process_route_parameters',5);

  end loop;
  hr_utility.set_location('ffdbitem.process_route_parameters',6);
  -- Check if there are any remaining &U placeholders remaining
  -- there should be none left
  if (instr(p_route_text, '&U') > 0) then
    hr_utility.set_message (802, 'FFT78_PLACEHOLDERS_REMAIN');
    hr_utility.set_message_token ('1',p_item_name);
    hr_utility.raise_error;
  end if;
  hr_utility.set_location('ffdbitem.process_route_parameters',7);
exception
when others then
  if route_parms%isopen then
    close route_parms;
  end if;
  raise;
end process_route_parameters;
--
------------------------------ process_contexts ------------------------------
--
-- NAME
--  process_contexts
--
-- DESCRIPTION
--   Replace context placeholders in route with bind variable references
--   and add context details into output context information structure
--
procedure process_contexts (p_item_name in varchar2,
                            p_route_text in out varchar2,
                            p_route_id in number,
                            p_contexts out FFCONTEXTS_T) is
  cursor route_contexts is
  SELECT RCU.SEQUENCE_NO,
         FC.CONTEXT_NAME,
         UPPER(FC.DATA_TYPE)
  FROM   FF_CONTEXTS FC,
         FF_ROUTE_CONTEXT_USAGES RCU
  WHERE  FC.CONTEXT_ID = RCU.CONTEXT_ID
  AND    RCU.ROUTE_ID = p_route_id
  ORDER BY RCU.SEQUENCE_NO;
--
  l_sequence_no FF_ROUTE_CONTEXT_USAGES.SEQUENCE_NO%TYPE;
  l_context_name FF_CONTEXTS.CONTEXT_NAME%TYPE;
  l_data_type FF_CONTEXTS.DATA_TYPE%TYPE;
--
begin
  hr_utility.set_location('ffdbitem.process_contexts',1);
  open route_contexts;
  hr_utility.set_location('ffdbitem.process_contexts',2);
  loop
    fetch route_contexts into l_sequence_no, l_context_name, l_data_type;
    hr_utility.set_location('ffdbitem.process_contexts',3);
    if route_contexts%notfound then
      close route_contexts;
      exit;
    end if;
    -- Check that a placeholder exists, error if it doesn't
    if (instr(p_route_text, '&B'||to_char(l_sequence_no)) = 0) then
      hr_utility.set_message (802, 'FFT77_NO_MATCHING_B');
      hr_utility.set_message_token ('1',p_item_name);
      hr_utility.set_message_token ('2','B'||to_char(l_sequence_no));
      hr_utility.raise_error;
    end if;
    hr_utility.set_location('ffdbitem.process_contexts',4);
    -- replace all instances of placeholder with context bind name
    p_route_text := replace (p_route_text,
                             '&B'||to_char(l_sequence_no),
                             ':B'||to_char(l_sequence_no));
    hr_utility.set_location('ffdbitem.process_contexts',5);
    p_contexts.context_count := l_sequence_no;
    p_contexts.context_names(l_sequence_no) := l_context_name;
    p_contexts.bind_names(l_sequence_no) := 'B'||to_char(l_sequence_no);
    p_contexts.context_types(l_sequence_no) := l_data_type;
  end loop;
  -- Check if there are any remaining &B placeholders remaining
  -- there should be none left
  hr_utility.set_location('ffdbitem.process_contexts',6);
  if (instr(p_route_text, '&B') > 0) then
    hr_utility.set_message (802, 'FFT78_PLACEHOLDERS_REMAIN');
    hr_utility.set_message_token ('1',p_item_name);
    hr_utility.raise_error;
  end if;
  hr_utility.set_location('ffdbitem.process_contexts',7);
exception
when others then
  if route_contexts%isopen then
    close route_contexts;
  end if;
  raise;
end process_contexts;
--
------------------------------- get_dbitem_info -------------------------------
--
-- NAME
--  get_dbitem_info
--
-- DESCRIPTION
--   Returns all information for a database item required to fetch it's value
--   including SQL, context requirements, data type in FFITEM_INFO_T
--   given the database item name, formula type id, business group id
--   and legislation code
--
procedure get_dbitem_info (p_item_name in varchar2,
                           p_formula_type_id in number,
                           p_bg_id in number,
                           p_leg_code in varchar2,
                           p_item_info out FFITEM_INFO_T) is
--
l_data_type FF_DATABASE_ITEMS.DATA_TYPE%type;
l_user_entity_id FF_USER_ENTITIES.USER_ENTITY_ID%type;
l_null_allowed FF_DATABASE_ITEMS.NULL_ALLOWED_FLAG%type;
l_notfound_allowed FF_USER_ENTITIES.NOTFOUND_ALLOWED_FLAG%type;
l_route_id FF_ROUTES.ROUTE_ID%type;
l_definition_text FF_DATABASE_ITEMS.DEFINITION_TEXT%type;
l_route_text varchar2(8000);
cursor c1 is
SELECT DI.DATA_TYPE,
       UE.USER_ENTITY_ID,
       UPPER(DI.NULL_ALLOWED_FLAG),
       UPPER(UE.NOTFOUND_ALLOWED_FLAG),
       FR.ROUTE_ID,
       DI.DEFINITION_TEXT,
       FR.TEXT
FROM   FF_DATABASE_ITEMS DI,
       FF_USER_ENTITIES UE,
       FF_ROUTES FR
WHERE  DI.USER_ENTITY_ID = UE.USER_ENTITY_ID
AND    UE.ROUTE_ID = FR.ROUTE_ID
AND    DI.USER_NAME = p_item_name
AND (   (UE.LEGISLATION_CODE IS NULL AND UE.BUSINESS_GROUP_ID IS NULL)
     OR (UE.BUSINESS_GROUP_ID IS NULL AND p_leg_code = UE.LEGISLATION_CODE )
     OR (p_bg_id = UE.BUSINESS_GROUP_ID)
    )
AND NOT EXISTS (
               SELECT CONTEXT_ID FROM FF_ROUTE_CONTEXT_USAGES IFRCU
               WHERE IFRCU.ROUTE_ID = FR.ROUTE_ID
               MINUS
               SELECT CONTEXT_ID FROM FF_FTYPE_CONTEXT_USAGES
               WHERE FORMULA_TYPE_ID = p_formula_type_id
               );
begin
  hr_utility.set_location('ffdbitem.get_dbitem_info',1);
  open c1;
  hr_utility.set_location('ffdbitem.get_dbitem_info',2);
  fetch c1 into l_data_type, l_user_entity_id, l_null_allowed,
                l_notfound_allowed, l_route_id, l_definition_text,
                l_route_text;
  hr_utility.set_location('ffdbitem.get_dbitem_info',3);
  if c1%notfound then
    raise_application_error(-20001,
                             'Item '||p_item_name||' could not be found');
  end if;
  hr_utility.set_location('ffdbitem.get_dbitem_info',4);
  -- Check that route text is present
  if (l_route_text is null) then
    hr_utility.set_message (802, 'FFTBFC785_BAD_ROUTE_LENGTH');
    hr_utility.set_message_token ('1',p_item_name);
    hr_utility.set_message_token ('2','0');
    hr_utility.raise_error;
  end if;
  hr_utility.set_location('ffdbitem.get_dbitem_info',5);

-- Process route parameters
  process_route_parameters (p_item_name, l_route_text,
                            l_user_entity_id, l_route_id);

  hr_utility.set_location('ffdbitem.get_dbitem_info',6);
-- Process contexts
  process_contexts (p_item_name, l_route_text, l_route_id,
                    p_item_info.contexts);
  hr_utility.set_location('ffdbitem.get_dbitem_info',7);
--
  l_route_text := 'select '||l_definition_text||' from '||l_route_text;
  hr_utility.set_location('ffdbitem.get_dbitem_info',8);
--
  -- copy the results into the output structure
  p_item_info.item_name := p_item_name;
  p_item_info.item_sql  := l_route_text;
  p_item_info.data_type := l_data_type;
--
  if l_null_allowed = 'Y' then
    hr_utility.set_location('ffdbitem.get_dbitem_info',8);
    p_item_info.null_ok := TRUE;
  else
    p_item_info.null_ok := FALSE;
    hr_utility.set_location('ffdbitem.get_dbitem_info',9);
  end if;
--
  if l_notfound_allowed = 'Y' then
    p_item_info.notfound_ok := TRUE;
    hr_utility.set_location('ffdbitem.get_dbitem_info',10);
  else
    p_item_info.notfound_ok := FALSE;
    hr_utility.set_location('ffdbitem.get_dbitem_info',11);
  end if;
exception
when others then
  if c1%isopen then
    close c1;
  end if;
  -- re raise original exception
  raise;
end get_dbitem_info;
--
------------------------------ get_dbitem_value ------------------------------
--
-- NAME
--  get_dbitem_value
--
-- DESCRIPTION
--   Returns the value of a database item given the item details
--   currently returns the varchar2 version of the value, so for dates
--   this will be in the format DD-MON-YYYY
--
function get_dbitem_value (p_item_info in FFITEM_INFO_T) return varchar2 is
dbitem_cursor integer;
dbitem_text_value varchar2(255);
dbitem_date_value date;
dbitem_number_value number;
execute_status integer;
rows_fetched integer;
begin
  hr_utility.set_location('ffdbitem.get_dbitem_value',1);
  -- open a new cursor for the DB item select statement
  dbitem_cursor := dbms_sql.open_cursor;
  hr_utility.set_location('ffdbitem.get_dbitem_value',2);
  hr_utility.trace(p_item_info.item_sql);
  -- parse the SQL passed in
  dbms_sql.parse(dbitem_cursor, p_item_info.item_sql, dbms_sql.v7);
  --
  hr_utility.set_location('ffdbitem.get_dbitem_value',3);
  for i in 1..p_item_info.contexts.context_count loop
    hr_utility.set_location('ffdbitem.get_dbitem_value',4);
    hr_utility.trace(p_item_info.contexts.bind_names(i));
    dbms_sql.bind_variable(dbitem_cursor,
                           p_item_info.contexts.bind_names(i),
                           p_item_info.contexts.bind_values(i));
  end loop;
  hr_utility.set_location('ffdbitem.get_dbitem_value',5);
  -- Define an appropriately typed variable
  if (p_item_info.data_type = 'T') then
    hr_utility.set_location('ffdbitem.get_dbitem_value',6);
    -- Define the (single) select list item as a varchar2
    dbms_sql.define_column(dbitem_cursor, 1, dbitem_text_value, 255);
  elsif (p_item_info.data_type = 'N') then
    hr_utility.set_location('ffdbitem.get_dbitem_value',7);
    -- Define the (single) select list item as a number
    dbms_sql.define_column(dbitem_cursor, 1, dbitem_number_value);
  elsif (p_item_info.data_type = 'D') then
    hr_utility.set_location('ffdbitem.get_dbitem_value',8);
    -- Define the (single) select list item as a date
    dbms_sql.define_column(dbitem_cursor, 1, dbitem_date_value);
  else
    hr_utility.set_message (802, 'BAD_DATA_TYPE');
    hr_utility.set_message_token ('1',p_item_info.item_name);
    hr_utility.raise_error;
  end if;
  hr_utility.set_location('ffdbitem.get_dbitem_value',9);
  --
  -- Execute the cursor
  execute_status := dbms_sql.execute(dbitem_cursor);
  --
  hr_utility.set_location('ffdbitem.get_dbitem_value',10);
  -- Fetch the rows (only 1 row should be fetched for database items)
  rows_fetched := dbms_sql.fetch_rows(dbitem_cursor);
  hr_utility.set_location('ffdbitem.get_dbitem_value',11);
  if (rows_fetched = 1) then
    hr_utility.set_location('ffdbitem.get_dbitem_value',12);
    -- get column value according to data type of item
    if (p_item_info.data_type = 'T') then
      hr_utility.set_location('ffdbitem.get_dbitem_value',13);
      -- Define the (single) select list item as a varchar2
      dbms_sql.column_value(dbitem_cursor, 1, dbitem_text_value);
      hr_utility.set_location('ffdbitem.get_dbitem_value',14);
      if (dbitem_text_value is null and not p_item_info.null_ok) then
        execute_error('FFX00_NULL_VALUE', p_item_info.item_name, '1', '');
      end if;
    elsif (p_item_info.data_type = 'N') then
      hr_utility.set_location('ffdbitem.get_dbitem_value',15);
      -- Define the (single) select list item as a number
      dbms_sql.column_value(dbitem_cursor, 1, dbitem_number_value);
      hr_utility.set_location('ffdbitem.get_dbitem_value',16);
      if (dbitem_number_value is null and not p_item_info.null_ok) then
        execute_error('FFX00_NULL_VALUE', p_item_info.item_name, '1', '');
      end if;
      dbitem_text_value := to_char(dbitem_number_value);
    else
      hr_utility.set_location('ffdbitem.get_dbitem_value',17);
      -- Define the (single) select list item as a date
      dbms_sql.column_value(dbitem_cursor, 1, dbitem_date_value);
      hr_utility.set_location('ffdbitem.get_dbitem_value',18);
      if (dbitem_date_value is null and not p_item_info.null_ok ) then
        execute_error('FFX00_NULL_VALUE', p_item_info.item_name, '1', '');
      end if;
      dbitem_text_value := to_char(dbitem_date_value,'DD-MON-YYYY');
    end if;
  elsif (rows_fetched = 0) then
    hr_utility.set_location('ffdbitem.get_dbitem_value',19);
    -- No rows found, so if 'notfound' is not OK, then raise no_data_found
    if not p_item_info.notfound_ok then
      execute_error('FFX00_DATA_NOT_FOUND', p_item_info.item_name, '1', '');
    end if;
  else
    -- >1 row, so this is an error
    execute_error('FFX00_TOO_MANY_ROWS', p_item_info.item_name, '1', '');
  end if;
  -- Close cursor
  hr_utility.set_location('ffdbitem.get_dbitem_value',20);
  dbms_sql.close_cursor(dbitem_cursor);
  hr_utility.set_location('ffdbitem.get_dbitem_value',21);
  -- return value
  return dbitem_text_value;
exception
when others then
  -- Close cursor if it is open
  if dbms_sql.is_open(dbitem_cursor) then
    dbms_sql.close_cursor(dbitem_cursor);
  end if;
  -- re-raise the exception
  raise;
end get_dbitem_value;

end ffdbitem;

/
