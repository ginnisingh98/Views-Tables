--------------------------------------------------------
--  DDL for Package Body XTR_MISC_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_MISC_P" AS
/* $Header: xtrprc3b.pls 120.9 2006/02/03 10:28:10 eaggarwa ship $ */


PROCEDURE FPS_AUDIT(p_audit_requested_by IN VARCHAR2,
                    p_event_name         IN VARCHAR2,
                    p_date_from          IN VARCHAR2,
                    p_date_to            IN VARCHAR2) is
  --
  -- Purpose: Populate AUDIT_SUMMARY table with audit
  -- information according to parameters.
  -- This Procedure is called from form PRO1006 (Audit Summary)
  -- The user specifies in this form the tables they want to see audit history on (1 or more)
  -- This Procedure is then called for each event name they want to look at
  -- any output(ie changed values) are inserted int the table AUDIT SUMMARY for the user requested by
  -- and the date/time - the form then retireves all records for that user and date/time


  -- KEY PROCESS POINTS
  -- The process below will
  --  1.  Build a cursor (using dbms_sql.parse,dbms_sql.define_column packages etc) comprising the following
  --       - table name for the event passed in (refer cursor c_get_table_name below)
  --       - all columns for the event passed in (refer cursor c_get_columns below)
  --      Therefore we end up building a cursor for the required table and columns as setup in PRO0095
  --
  --  2. The records from that table and columns will be fetched by the constructed cursor
  --       - firstly from the AUDIT table for the above table in date asc order
  --       - lastly from the actual table (ie fetch the current record)

  --       - the fetch order is important as we need to fetch the records in date order as they were changed
  --       - so as to see changes in data as they occurred from one record to the next

  --  3. For each record fetched we compare the old with the new values and if they are different
  --     for that column we insert the old and new values into the table AUDIT_SUMMARY


  v6 constant            integer := 0;
  native constant        integer := 1;
  v7 constant            integer := 2;
  V_MAX_COL constant     integer := 50;  -- Maximum number of columns which can be audited.
  v_counter              binary_integer;
  v_table_column         xtr_audit_columns_v.table_column%TYPE;
  v_select               varchar2(1000);
  v_num_col              integer;        -- The number of columns for this audit.
  v_sql                  varchar2(2000);
  v_rec_num              binary_integer := 1;
  v_key_the_same         varchar2(1);
  v_reference_code       varchar2(50);
  v_table_name           varchar2(50);
  v_audit_table_name     varchar2(50);
  ex_error               exception;
  v_cursor               binary_integer;
  v_rows_processed       binary_integer;
  v_old_letter           varchar2(1);
  v_old_updated_on       date;
  v_old_updated_by       varchar2(30);
  v_new_letter           varchar2(1);
  v_new_updated_on       date;
  v_new_updated_by       varchar2(30);
  v_var1                 varchar2(100); -- This holds the audited columns (one by one).
  --
  TYPE t_col_title IS TABLE OF VARCHAR2(50)
    INDEX BY BINARY_INTEGER;
  TYPE t_col_type IS TABLE OF VARCHAR2(15)
    INDEX BY BINARY_INTEGER;
  TYPE t_col_pkey IS TABLE OF VARCHAR2(1)
    INDEX BY BINARY_INTEGER;
  --
  TYPE t_old IS TABLE OF VARCHAR2(100)
    INDEX BY BINARY_INTEGER;
  --
  TYPE t_new IS TABLE OF VARCHAR2(100)
    INDEX BY BINARY_INTEGER;
  --
  v_col_title        t_col_title;
  v_col_type         t_col_type;
  v_col_pkey         t_col_pkey;
  v_old              t_old;             -- Holds old fetched columns
  v_new              t_new;             -- Holds newly fetched records columns
  --
  cursor c_get_table_name (pc_event varchar2) is
    select table_name,'XTR_A_'||substr(table_name,5)
    from XTR_SETUP_AUDIT_REQMTS
    where event = pc_event;
  --
  cursor c_get_columns ( pc_event varchar2 )is
    select table_column, column_title, upper(nvl(p_key_yn,'N')), upper(column_type)
    from XTR_AUDIT_COLUMNS
    where event = pc_event
    and ( nvl(audit_yn, 'N') = 'Y' or
	  nvl(P_KEY_YN, 'N') = 'Y') ;
--
begin
  --
  -- Get the table name for audit
  open c_get_table_name(p_event_name);
   fetch c_get_table_name into v_table_name,v_audit_table_name;
  IF c_get_table_name%NOTFOUND THEN
   close c_get_table_name;
   raise ex_error;
  ELSE
   close c_get_table_name;
  END IF;
  --
  -- Make select string ...
  --
  open c_get_columns ( p_event_name );
  --
  v_select := 'nvl(UPDATED_ON,to_date(''01/01/1900'',''DD/MM/YYYY'')),UPDATED_BY';
  v_counter := 1;
  --
  LOOP
    EXIT WHEN v_counter > V_MAX_COL;
    fetch c_get_columns into v_table_column, v_col_title( v_counter),
                             v_col_pkey( v_counter), v_col_type( v_counter);
    EXIT WHEN c_get_columns%NOTFOUND;
    IF substr(v_col_type(v_counter),1,4) = 'DATE' THEN
      v_select := v_select || ', to_char('||v_table_column||',''DD/MM/YYYY HH24:MI:SS'')';
    ELSIF substr(v_col_type(v_counter),1,4) in ('CHAR','VARC') THEN
      v_select := v_select || ',' || v_table_column;
    ELSE
      v_select := v_select || ',to_char(' || v_table_column || ')';
    END IF;
    --
    v_counter := v_counter + 1;
  END LOOP;
  close c_get_columns;
  v_num_col := v_counter -1; -- The number of AUDITED columns. *****
  --
  -- Put all of SQL statement together (ie select + where clause)
  --
  v_sql := 'select ''B'',' || v_select || ' FROM '||v_table_name||' '||
           'WHERE (updated_on between to_date('''|| p_date_from ||''',''DD/MM/YYYY HH24:MI:SS'') '||
           'and to_date('''|| p_date_to ||''',''DD/MM/YYYY HH24:MI:SS''))';
  v_sql := v_sql || ' union ' || 'select ''A'',' || v_select ||' from '||v_audit_table_name||' '||
           'WHERE (updated_on between to_date('''|| p_date_from ||''',''DD/MM/YYYY HH24:MI:SS'') '||
           'and to_date('''|| p_date_to ||''',''DD/MM/YYYY HH24:MI:SS'')) OR '||
           '(audit_date_stored between to_date('''|| p_date_from ||''',''DD/MM/YYYY HH24:MI:SS'') '||
           'and to_date('''|| p_date_to ||''',''DD/MM/YYYY HH24:MI:SS'')) '||'order by ';
  -- Add the primary key column/s to the SORT BY clause
  FOR v_counter IN 1..v_num_col LOOP
   IF v_col_pkey(v_counter) = 'Y' THEN
    v_sql := v_sql || to_char(v_counter+3)||',';
   END IF;
  END LOOP;
  v_sql := v_sql||'1,2,3'; -- Add B/A, "updated_on, updated_by" to SORT BY clause
  --
  -- Now set up dbms_sql cursor
  --
  v_cursor := dbms_sql.open_cursor;
  dbms_sql.parse(v_cursor,v_sql,native);
  --
  dbms_sql.define_column(v_cursor,1,v_new_letter, 1);
  dbms_sql.define_column(v_cursor,2,v_new_updated_on);
  dbms_sql.define_column(v_cursor,3,v_new_updated_by,30);
  -- Its weird how come this next bit works !!??
  FOR v_counter IN 1..v_num_col LOOP
   dbms_sql.define_column( v_cursor,  v_counter+3, v_var1, 100);
  END LOOP;
  --
  v_rows_processed := dbms_sql.execute( v_cursor );
  --
  -- Now loop through records in cursor. This is the **** MAIN LOOP ******
  --
  v_rec_num := 1;
  LOOP
    EXIT WHEN dbms_sql.fetch_rows(v_cursor) < 1; -- Exit when no more rows
    dbms_sql.column_value(v_cursor,1,v_new_letter);
    dbms_sql.column_value(v_cursor,2,v_new_updated_on);
    dbms_sql.column_value(v_cursor,3,v_new_updated_by);
    FOR v_counter IN 1..v_num_col LOOP
     -- Place fetched column into v_new array
     dbms_sql.column_value(v_cursor,v_counter + 3,v_var1);
     v_new(v_counter) := v_var1;
    END LOOP;
    --
    -- Analyse differences (if this is not the first record fetched) ...
    --
    IF v_rec_num > 1 THEN
      --
      -- See if primary keys MATCH
      --
      v_key_the_same := 'Y';
      v_reference_code := null;
      FOR v_counter IN 1..v_num_col LOOP
       IF v_col_pkey(v_counter) = 'Y' THEN
        IF nvl(v_old(v_counter),'JJ') = nvl(v_new(v_counter),'JJ') THEN
         IF v_reference_code is not null THEN
           v_reference_code := v_reference_code||'|';
         END IF;
         v_reference_code := v_reference_code||rtrim(v_new( v_counter ));
        ELSE
         v_key_the_same := 'N';
        END IF;
       END IF;
      END LOOP;
      --
      if v_key_the_same = 'Y' then
        --
        -- Insert any differences between individual columns
        --
        FOR v_counter IN 1..v_num_col LOOP
          IF nvl(v_old(v_counter),'JJ') <> nvl(v_new(v_counter),'JJ') THEN
            insert into XTR_AUDIT_SUMMARY
                (AUDIT_REQUESTED_BY,AUDIT_REQUESTED_ON,
                 AUDIT_RECORDS_FROM,AUDIT_RECORDS_TO,
                 NAME_OF_COLUMN_CHANGED,TABLE_NAME,
                 REFERENCE_CODE,UPDATED_ON_DATE,
                 UPDATED_BY_USER,OLD_VALUE,NEW_VALUE,TRANSACTION_REF,
                 NON_TRANSACTION_REF)
            values
                (p_audit_requested_by,sysdate,
                 to_date(p_date_from,'DD/MM/YYYY HH24:MI:SS'),
                 to_date(p_date_to,'DD/MM/YYYY HH24:MI:SS'),
                 rtrim(v_col_title(v_counter)),upper(v_table_name),
                 rtrim(substr(v_reference_code,1,20)),
                 to_char(v_new_updated_on,'DD/MM/YYYY HH24:MI:SS'),
                 substr(v_new_updated_by,1,10),rtrim(substr(v_old(v_counter),1,255)),
                 rtrim(substr(v_new(v_counter),1,255)),null,v_new_letter);
          END IF;
        END LOOP;
      end if;
    END IF;
    --
    -- Store all "new" column values into "old"
    --
    v_old_letter     := v_new_letter;
    v_old_updated_on := v_new_updated_on;
    v_old_updated_by := v_new_updated_by;
    --
    FOR v_counter in 1..v_num_col LOOP
      v_old(v_counter) := v_new(v_counter);
    END LOOP;
    v_rec_num := v_rec_num + 1;
  END LOOP;
  dbms_sql.close_cursor(v_cursor);
  --
exception
 when ex_error then
   null;
end FPS_AUDIT;



-- Procedure to Maintain Language (Called from each form)
PROCEDURE MAINTAIN_LANGUAGE(l_form     IN VARCHAR2,
                            l_item     IN VARCHAR2,
                            l_old_val  IN VARCHAR2,
                            l_new_val  IN VARCHAR2,
                            l_option   IN VARCHAR2,
                            l_language IN VARCHAR2,
                            l_original_text IN VARCHAR2) is      -- 3424625 Added new parameter
--
 l_module VARCHAR2(20);
 v_rowid VARCHAR2(100);
 v_module_name XTR_SYS_LANGUAGES.MODULE_NAME%type;
 v_canvas_type XTR_SYS_LANGUAGES.CANVAS_TYPE%type :='TEXT';
 v_item_name XTR_SYS_LANGUAGES.ITEM_NAME%type;

 --
 -- Create cursor to fetch all the rows that satisfies the given criteria
 --  bug 3424625 modified cursor lang_cursor

 cursor lang_cursor
   (v_module_name	VARCHAR2,
    v_canvas_type	VARCHAR2,
    v_language		VARCHAR2,
    v_text		VARCHAR2,
    v_original_text VARCHAR2) IS
   select tl.MODULE_NAME, tl.CANVAS_TYPE, tl.ITEM_NAME
   from XTR_SYS_LANGUAGES_TL tl , xtr_sys_languages sl
   where tl.MODULE_NAME like v_module_name
   and tl.CANVAS_TYPE = v_canvas_type
   and tl.LANGUAGE = v_language
   and tl.TEXT = v_text
   and tl.canvas_type = sl.canvas_type
   and tl.module_name = sl.module_name
   and sl.ORIGINAL_TEXT = v_original_text
   and tl.item_name =sl.item_name;


   /* select tl.MODULE_NAME, tl.CANVAS_TYPE, tl.ITEM_NAME
   from XTR_SYS_LANGUAGES_TL tl
   where tl.MODULE_NAME like v_module_name
   and tl.CANVAS_TYPE = v_canvas_type
   and tl.LANGUAGE = v_language
   and tl.TEXT = v_text;  */

--
 l_cnt number :=0;
 l_rowid varchar2(30);
 l_orginal_text varchar2(100);
begin
 if l_option = 'O' then
  l_module := l_form;
 else
  l_module := '%';
 end if;

 --
 -- Only rows of canvas_type = 'TEXT' are ever updated
 --
 open lang_cursor(l_module, 'TEXT', l_language, l_old_val, l_original_text);
 loop
   fetch lang_cursor into v_module_name, v_canvas_type, v_item_name;
   exit when lang_cursor%notfound or lang_cursor%notfound is null;
   --
   -- Update row based on rowid
   --
   XTR_SYS_LANGUAGES_PKG.Update_Row
     (X_MODULE_NAME => v_module_name,
      X_CANVAS_TYPE => v_canvas_type,
      X_ITEM_NAME => v_item_name,
      X_ORIGINAL_TEXT => null,
      X_TEXT => l_new_val,
      X_LAST_UPDATE_DATE => sysdate,
      X_LAST_UPDATED_BY => FND_GLOBAL.USER_ID,
      X_LAST_UPDATE_LOGIN => FND_GLOBAL.LOGIN_ID);
   l_cnt :=1;

 end loop; -- lang_cursor
 if l_cnt =0 then
   l_orginal_text :=initcap(replace(l_item,'_',' '));
   XTR_SYS_LANGUAGES_PKG.Insert_Row
     (X_ROWID       => l_rowid,
      X_MODULE_NAME => l_form,
      X_CANVAS_TYPE => 'TEXT',
      X_ITEM_NAME => l_item,
      X_ORIGINAL_TEXT => l_orginal_text,
      X_TEXT => l_new_val,
      X_CREATION_DATE => sysdate,
      X_CREATED_BY => FND_GLOBAL.USER_ID,
      X_LAST_UPDATE_DATE => sysdate,
      X_LAST_UPDATED_BY => FND_GLOBAL.USER_ID,
      X_LAST_UPDATE_LOGIN => FND_GLOBAL.LOGIN_ID);
 end if;


 --
 -- Commit work
 --
 commit;

end MAINTAIN_LANGUAGE;



/* deleted Treasury_Archive to fix bug # 1855372
*/


PROCEDURE DEAL_ACTIONS(p_deal_type          IN VARCHAR2,
                       p_deal_number        IN NUMBER,
                       p_transaction_number IN NUMBER,
                       p_action_type        IN VARCHAR2,
                       p_cparty_code        IN VARCHAR2,
                       p_client_code        IN VARCHAR2,
                       p_date_created       IN DATE,
                       p_company_code       IN VARCHAR2,
                       p_status_code        IN VARCHAR2,
                       p_file_name          IN VARCHAR2,
                       p_deal_subtype       IN VARCHAR2,
                       p_currency           IN VARCHAR2,
                       p_cparty_advice      IN VARCHAR2,
                       p_client_advice      IN VARCHAR2,
                       p_amount             IN NUMBER,
                       p_org_flag           IN VARCHAR2) is
--
-- Purpose: Populate CONFIRMATION_DETAILS table with action codes
--         (used in Forms PRO1011 - Confirmations and PRO1012 - Dual Validation).
--
cursor CHK_CONFO_REQD(l_party_code varchar2) is
 select 1
  from XTR_PARTIES_V a,
       XTR_CONFIRMATION_ACTIONS b
  where a.party_code= l_party_code
  and a.confo_group_code = b. confo_action_group
  and b.action_type = p_action_type
  and b.confo_reqd = 'Y';
--
cursor VALIDATE_ABOVE_AMT is
 select nvl(to_number(PARAM_VALUE),0)
  from XTR_PRO_PARAM
  where upper(PARAM_NAME) = 'VALIDATE ABOVE AMNT';
--
cursor HCE is
 select p_amount / hce_rate
  from XTR_MASTER_CURRENCIES
  where CURRENCY = p_currency;

--  bug 3800146  IAC -Redesign Project Added lines
 cursor iac_validated is
 select dual_authorisation_by, dual_authorisation_on
 from   xtr_deal_date_amounts
 where  transaction_number=p_transaction_number
 and    deal_number = 0                      -- bug  4957910
 and    dual_authorisation_by is not null
 and deal_type='IAC';
--  bug 3800146  IAC -Redesign Project Added lines



--
 l_hce_amount NUMBER;
 l_above_amt  NUMBER := 0;
 l_dumy_num   NUMBER;
 confirmed_by VARCHAR2(10);
 confirmed_on DATE;
--
begin
/* List of Confirmation Types that will be passed to this Procedure
 if p_deal_type = 'FX' then
     FX_CONTRACT_SWAP
     PREDELIVERY_OF_FX_CONTRACT
     ROLLOVER_OF_FX_CONTRACT
     NEW_FX_CONTRACT
 elsif p_deal_type = 'FXO' then
     NEW_FXO_CONTRACT
     EXERCISE_OF_FX_OPTION_CONTRACT
 elsif p_deal_type = 'FRA' then
     NEW_FRA_CONTRACT
     SETTLEMENT_OF_FRA_CONTRACT
 elsif p_deal_type = 'FUT' then
     New Futures Contract
     Closeout of Futures Contract
 elsif p_deal_type = 'IRO' then
     NEW_IRO_CONTRACT
     EXERCISE_OF_IRO_CONTRACT
     NEW_BOND_OPTION_CONTRACT
     EXERCISE_OF_BOND_OPTION_CONTRACT
 elsif p_deal_type = 'NI' then
     NEW_NI_CONTRACT
 elsif p_deal_type = 'BOND' then
     NEW_BOND_CONTRACT
 elsif p_deal_type = 'SWPTN' then
     NEW_SWAPTION_CONTRACT
     EXERCISE_OF_SWAPTION_CONTRACT
 elsif p_deal_type = 'DEB' then
     New Debenture Contract
 elsif p_deal_type = 'IRS' then
    NEW_INT_RATE_SWAP_CONTRACT
 elsif p_deal_type = 'TMM' then
   -- Retail
     NEW_RETAIL_TERM_CONTRACT
     Change Schedule Type for Retail Term
     PRINCIPAL_ADJUSTMENT_OF_RETAIL_TERM_CONTRA
     RETAIL_TERM_INTEREST_RESET
   -- Wholesale
     NEW_WHOLESALE_TERM_CONTRACT
 end if;
*/
--
-- Fetch the break above level for validation purposes
-- ie only validate transactions above this amount
open VALIDATE_ABOVE_AMT;
 fetch VALIDATE_ABOVE_AMT INTO l_above_amt;
if VALIDATE_ABOVE_AMT%NOTFOUND then
 l_above_amt := 0;
end if;
close VALIDATE_ABOVE_AMT;
--
-- Convert amount to hce amount for comparison to above break limit
open HCE;
 fetch HCE into l_hce_amount;
close HCE;
--
if ABS(l_hce_amount) < l_above_amt then  -- bug 4135644
 -- Auto confirm inserted row
 confirmed_by := fnd_global.user_id;
 confirmed_on := sysdate;
else
 confirmed_by := NULL;
 confirmed_on := NULL;
end if;
--


-- bug 3800146  IAC -Redesign Project Added lines

if p_deal_type = 'IAC' and confirmed_by is null then
   open  iac_validated;
   fetch iac_validated into confirmed_by, confirmed_on;
   close iac_validated;
end if;

-- bug 3800146  IAC -Redesign Project Ended lines

/************************

if (nvl(p_cparty_advice,'N') = 'N' and nvl(p_client_advice,'N')= 'N') or (nvl(p_org_flag,'~') = 'U') then
  insert into xtr_confirmation_details(
   ACTION_TYPE,COMPANY_CODE,CONFO_PARTY_CODE,CONFO_VALIDATION_BOTH,
   CPARTY_CODE,DATE_ACTION_INITIATED,DEAL_NO,STATUS_CODE,TRANSACTION_NO,AMOUNT,AMOUNT_TYPE,CLIENT_CODE,
   CURRENCY,DEAL_SUBTYPE,DEAL_TYPE,CONFIRMATION_VALIDATED_BY,CONFIRMATION_VALIDATED_ON)
  values(p_action_type,p_company_code,NULL,'V',p_cparty_code,trunc(p_date_created),
   p_deal_number,p_status_code,p_transaction_number,p_amount,NULL,p_client_code,
   p_currency,p_deal_subtype,p_deal_type,confirmed_by,confirmed_on);
elsif nvl(p_cparty_advice,'N') = 'Y' and nvl(p_client_advice,'N') = 'N' then
 --
 open chk_confo_reqd(p_cparty_code );
  fetch chk_confo_reqd into l_dumy_num;
 if chk_confo_reqd%NOTFOUND then
   insert into xtr_confirmation_details(
    ACTION_TYPE,COMPANY_CODE,CONFO_PARTY_CODE,CONFO_VALIDATION_BOTH,
    CPARTY_CODE,DATE_ACTION_INITIATED,DEAL_NO,STATUS_CODE,TRANSACTION_NO,
    AMOUNT,AMOUNT_TYPE,CLIENT_CODE,CURRENCY,DEAL_SUBTYPE,DEAL_TYPE,
    CONFIRMATION_VALIDATED_BY,CONFIRMATION_VALIDATED_ON)
   values( p_action_type,p_company_code, NULL,'V',p_cparty_code,trunc(p_date_created),
    p_deal_number,p_status_code, p_transaction_number, p_amount,NULL,p_client_code,
    p_currency,p_deal_subtype,p_deal_type,confirmed_by,confirmed_on);
 else
  insert into xtr_confirmation_details(
   ACTION_TYPE,COMPANY_CODE,CONFO_PARTY_CODE,CONFO_VALIDATION_BOTH,
   CPARTY_CODE,DATE_ACTION_INITIATED,DEAL_NO,STATUS_CODE,TRANSACTION_NO,AMOUNT,
   AMOUNT_TYPE,CLIENT_CODE,CURRENCY,DEAL_SUBTYPE,DEAL_TYPE,
   CONFIRMATION_VALIDATED_BY,CONFIRMATION_VALIDATED_ON)
  values(p_action_type,p_company_code,p_cparty_code,'B',p_cparty_code,trunc(p_date_created),
   p_deal_number,p_status_code,p_transaction_number,p_amount,NULL,p_client_code,
   p_currency,p_deal_subtype,p_deal_type,confirmed_by,confirmed_on);
 end if;
 close chk_confo_reqd;
 --
elsif nvl(p_cparty_advice,'N') = 'N' and nvl(p_client_advice ,'N') = 'Y' then
 --
 open chk_confo_reqd(p_client_code);
  fetch chk_confo_reqd into l_dumy_num;
 if chk_confo_reqd%NOTFOUND then
   insert into xtr_confirmation_details(
    ACTION_TYPE,COMPANY_CODE,CONFO_PARTY_CODE,CONFO_VALIDATION_BOTH,
    CPARTY_CODE,DATE_ACTION_INITIATED,DEAL_NO,STATUS_CODE,TRANSACTION_NO,AMOUNT,
    AMOUNT_TYPE,CLIENT_CODE,CURRENCY,DEAL_SUBTYPE,DEAL_TYPE,
    CONFIRMATION_VALIDATED_BY,CONFIRMATION_VALIDATED_ON)
   values(p_action_type,p_company_code, NULL,'V',p_cparty_code,trunc(p_date_created),
    p_deal_number,p_status_code,p_transaction_number,p_amount,NULL,p_client_code,
    p_currency,p_deal_subtype,p_deal_type,confirmed_by,confirmed_on);
 else
  insert into xtr_confirmation_details(
   ACTION_TYPE,COMPANY_CODE,CONFO_PARTY_CODE,CONFO_VALIDATION_BOTH,
   CPARTY_CODE,DATE_ACTION_INITIATED,DEAL_NO,STATUS_CODE,TRANSACTION_NO,AMOUNT,
   AMOUNT_TYPE,CLIENT_CODE,CURRENCY,DEAL_SUBTYPE,DEAL_TYPE,
   CONFIRMATION_VALIDATED_BY,CONFIRMATION_VALIDATED_ON)
  values(p_action_type,p_company_code,p_client_code,'B',p_cparty_code,trunc(p_date_created),
   p_deal_number,p_status_code,p_transaction_number,p_amount,NULL,p_client_code,
   p_currency,p_deal_subtype,p_deal_type,confirmed_by,confirmed_on);
 end if;
 close chk_confo_reqd;
 --
elsif nvl(p_cparty_advice,'N')='Y' and nvl(p_client_advice ,'N')='Y'  then
 --
*****************************/

 open chk_confo_reqd(p_cparty_code);
  fetch chk_confo_reqd into l_dumy_num;
 if chk_confo_reqd%NOTFOUND then
   insert into xtr_confirmation_details(
    ACTION_TYPE,COMPANY_CODE,CONFO_PARTY_CODE,CONFO_VALIDATION_BOTH,
    CPARTY_CODE,DATE_ACTION_INITIATED,DEAL_NO,STATUS_CODE,TRANSACTION_NO,AMOUNT,
    AMOUNT_TYPE,CLIENT_CODE,CURRENCY,DEAL_SUBTYPE,DEAL_TYPE,
    CONFIRMATION_VALIDATED_BY,CONFIRMATION_VALIDATED_ON)
   values(p_action_type,p_company_code,NULL,'V',p_cparty_code,trunc(p_date_created),
    p_deal_number,p_status_code,p_transaction_number,p_amount,NULL,p_client_code,
    p_currency,p_deal_subtype,p_deal_type,confirmed_by,confirmed_on);
 else
  insert into xtr_confirmation_details(
   ACTION_TYPE,COMPANY_CODE,CONFO_PARTY_CODE,CONFO_VALIDATION_BOTH,
   CPARTY_CODE,DATE_ACTION_INITIATED,DEAL_NO,STATUS_CODE,TRANSACTION_NO,AMOUNT,
   AMOUNT_TYPE,CLIENT_CODE,CURRENCY,DEAL_SUBTYPE,DEAL_TYPE,
   CONFIRMATION_VALIDATED_BY,CONFIRMATION_VALIDATED_ON)
  values(p_action_type,p_company_code,p_cparty_code,'B',p_cparty_code,trunc(p_date_created),
   p_deal_number,p_status_code,p_transaction_number,p_amount,NULL,p_client_code,
   p_currency,p_deal_subtype,p_deal_type,confirmed_by,confirmed_on);
 end if;
 close chk_confo_reqd;
 --
 open chk_confo_reqd(p_client_code );
  fetch chk_confo_reqd into l_dumy_num;
 if chk_confo_reqd%FOUND then
  insert into xtr_confirmation_details(
   ACTION_TYPE,COMPANY_CODE,CONFO_PARTY_CODE,CONFO_VALIDATION_BOTH,
   CPARTY_CODE,DATE_ACTION_INITIATED,DEAL_NO,STATUS_CODE,TRANSACTION_NO,AMOUNT,
   AMOUNT_TYPE,CLIENT_CODE,CURRENCY,DEAL_SUBTYPE,DEAL_TYPE)
  values(p_action_type,p_company_code,p_client_code,'C',p_cparty_code,trunc(p_date_created),
   p_deal_number,p_status_code,p_transaction_number,p_amount,NULL,p_client_code,
   p_currency,p_deal_subtype,p_deal_type);
 end if;
 close chk_confo_reqd;
 --
-- end if;
end DEAL_ACTIONS;



-- Procedure to Calculate Fixed V's Floating Details (PRO1108) + Int Rate Bands
procedure INS_ACTUALS(
     	p_company_code	  	IN varchar2,
	p_currency	  	IN varchar2,
	p_portfolio_code  	IN varchar2,
	p_from_date	  	IN date,
	p_to_date	  	IN date,
	p_fund_invest	  	IN varchar2,
        p_amount_unit	  	IN number,
	p_inc_ig		IN varchar2,
        p_unique_ref_number     IN number,
	p_company_name	        IN varchar2,
	p_port_name		IN varchar2,
	p_floating_less	        IN varchar2) is
--
cursor get_ca is
 select a.company_code,a.portfolio_code,a.deal_number,a.transaction_number,a.deal_type,a.deal_subtype,a.currency,a.transaction_rate,a.amount_date start_date,a.amount_date maturity_date,p_to_date to_date,p_from_date from_date,
 'FLOAT' FIXED_OR_FLOAT,nvl(a.amount,0) gross_amount,1 no_of_days
     from XTR_DEAL_DATE_AMOUNTS_V a
    where a.amount_date >=p_from_date
      and a.company_code like p_company_code and a.currency like p_currency
      and a.portfolio_code like p_portfolio_code
      and a.status_code='CURRENT'
      and ((a.DEAL_TYPE ='CA' and a.AMOUNT_TYPE='BAL')
         or (a.DEAL_TYPE ='IG' and a.AMOUNT_TYPE='BAL' and p_inc_ig='Y'))
      and ( (a.DEAL_SUBTYPE='INVEST'  and p_fund_invest='INVEST')
            or (a.DEAL_SUBTYPE='FUND' and p_fund_invest='FUND')
            or (p_fund_invest='NONE'));
--
cursor get_data1 is
 select a.company_code,a.portfolio_code,a.deal_number,a.transaction_number,a.deal_type,
        a.deal_subtype,a.currency,a.transaction_rate,
        decode(a.deal_type,'IRO',nvl(b.start_date,b.expiry_date),b.start_date) start_date,
        b.maturity_date,p_to_date to_date,p_from_date from_date,
        decode(a.deal_type||a.deal_subtype,
        'IROBCAP','FIXED',
        'IROBFLOOR','FIXED',
        'IROSFLOOR','FLOAT',
        'IROSCAP','FLOAT',
        'BDOBCAP','FIXED',
        'BDOBFLOOR','FIXED',
        'BDOSFLOOR','FLOAT',
        'BDOSCAP','FLOAT',
        'SWPTNSELL','FLOAT',
        'SWPTNBUY','FIXED',
        'FRAFUND','FIXED',
        'FRAINVEST','FIXED',
        decode(sign(p_to_date-b.maturity_date+1),1,'FLOAT','FIXED')) FIXED_OR_FLOAT,
        decode(a.deal_type,
         'IRO',nvl(b.maturity_date-nvl(b.start_date,b.expiry_date)+decode(sign(nvl(b.start_date,b.expiry_date)-p_from_date),-1,nvl(b.start_date,b.expiry_date)-p_from_date,0),0),
         'BDO',nvl(b.maturity_date-nvl(b.start_date,b.expiry_date)+decode(sign(nvl(b.start_date,b.expiry_date)-p_from_date),-1,nvl(b.start_date,b.expiry_date)-p_from_date,0),0),
               nvl(b.maturity_date-b.start_date+decode(sign(b.start_date-p_from_date),-1,b.start_date-p_from_date,0),0)) no_of_days,
        nvl(sum(decode(a.deal_type||a.amount_type,
        'NIBAL_FV',a.amount,
        'BONDINTL_FV',a.amount,
        'IROFACEVAL',a.amount,
        'BDOFACEVAL',a.amount,
        'SWPTNFACEVAL',a.amount,
        'FRAFACEVAL',a.amount,0)),0) gross_amount
   from XTR_DEAL_DATE_AMOUNTS_V a,
        XTR_DEALS_V b
   where a.amount_date >= p_from_date
   and a.currency like p_currency
   and a.company_code like p_company_code
   and a.portfolio_code like p_portfolio_code
   and a.status_code='CURRENT'
   and a.deal_number = b.deal_no
   and a.DEAL_TYPE in('NI','SWPTN','FRA','IRO','BOND','BDO')
   and ((a.DEAL_TYPE in('FRA') AND a.DEAL_SUBTYPE = 'INVEST' and p_fund_invest='INVEST')
     or (a.DEAL_TYPE in('FRA') AND a.DEAL_SUBTYPE = 'FUND'   and p_fund_invest='FUND')
     or (p_fund_invest = 'NONE')
     or (a.DEAL_TYPE = 'NI' AND a.DEAL_SUBTYPE in('BUY','COVER') and p_fund_invest='INVEST')
     or (a.DEAL_TYPE = 'NI' AND a.DEAL_SUBTYPE in('SELL','SHORT','ISSUE') and p_fund_invest = 'FUND')
     or (a.DEAL_TYPE in('BOND') AND a.DEAL_SUBTYPE='BUY' and p_fund_invest  = 'INVEST')
     or (a.DEAL_TYPE in('BOND') AND a.DEAL_SUBTYPE='SHORT' and p_fund_invest = 'FUND')
     or (a.DEAL_TYPE in('BOND') AND a.DEAL_SUBTYPE='ISSUE' and p_fund_invest = 'FUND')
     or (a.DEAL_TYPE in('IRO') AND a.DEAL_SUBTYPE in('BFLOOR','SFLOOR') and p_fund_invest = 'INVEST')
     or (a.DEAL_TYPE in('IRO') AND a.DEAL_SUBTYPE in('SCAP','BCAP') and p_fund_invest = 'FUND')
     or (a.DEAL_TYPE in('BDO') AND a.DEAL_SUBTYPE in('BFLOOR','SFLOOR') and p_fund_invest = 'INVEST')
     or (a.DEAL_TYPE in('BDO') AND a.DEAL_SUBTYPE in('SCAP','BCAP') and p_fund_invest = 'FUND')
     or (a.DEAL_TYPE in('SWPTN') and b.COUPON_ACTION='PAY' and p_fund_invest='FUND')
     or (a.DEAL_TYPE in('SWPTN') and b.COUPON_ACTION='REC' and p_fund_invest='INVEST'))
  having nvl(sum(decode(a.deal_type||a.amount_type,
        'NIBAL_FV',a.amount,
        'BONDINTL_FV',a.amount,
        'IROFACEVAL',a.amount,
        'BDOFACEVAL',a.amount,
        'SWPTNFACEVAL',a.amount,
        'FRAFACEVAL',a.amount,0)),0) >0
  group by a.company_code,a.portfolio_code,a.deal_number,a.transaction_number,a.deal_type,
        a.deal_subtype,a.currency,a.transaction_rate,
        decode(a.deal_type,'IRO',nvl(b.start_date,b.expiry_date),b.start_date),b.maturity_date,p_to_date,p_from_date,
        decode(a.deal_type,'BDO',nvl(b.start_date,b.expiry_date),b.start_date),b.maturity_date,p_to_date,p_from_date,
        decode(a.deal_type||a.deal_subtype,
        'IROBCAP','FIXED',
        'IROBFLOOR','FIXED',
        'IROSFLOOR','FLOAT',
        'IROSCAP','FLOAT',
        'BDOBCAP','FIXED',
        'BDOBFLOOR','FIXED',
        'BDOSFLOOR','FLOAT',
        'BDOSCAP','FLOAT',
        'SWPTNSELL','FLOAT',
        'SWPTNBUY','FIXED',
        'FRAFUND','FIXED',
        'FRAINVEST','FIXED',
        decode(sign(p_to_date-b.maturity_date+1),1,'FLOAT','FIXED')),
        decode(a.deal_type,
         'IRO',nvl(b.maturity_date-nvl(b.start_date,b.expiry_date)+decode(sign(nvl(b.start_date,b.expiry_date)-p_from_date),-1,nvl(b.start_date,b.expiry_date)-p_from_date,0),0),
         'BDO',nvl(b.maturity_date-nvl(b.start_date,b.expiry_date)+decode(sign(nvl(b.start_date,b.expiry_date)-p_from_date),-1,nvl(b.start_date,b.expiry_date)-p_from_date,0),0),
               nvl(b.maturity_date-b.start_date+decode(sign(b.start_date-p_from_date),-1,b.start_date-p_from_date,0),0));
--
cursor get_fut is
 select a.company_code,a.portfolio_code,a.deal_number,a.transaction_number,a.deal_type,
    a.deal_subtype,a.currency,a.transaction_rate,a.amount_date start_date,a.amount_date maturity_date,p_to_date to_date,p_from_date from_date,
   'FIXED' FIXED_OR_FLOAT,nvl(a.amount,0) gross_amount,1 no_of_days
  from XTR_DEAL_DATE_AMOUNTS_V a,
       XTR_FUTURES b
  where a.amount_date >=p_from_date
  and a.company_code like p_company_code
  and a.currency like p_currency
  and a.portfolio_code like p_portfolio_code
  and a.amount_type='FACEVAL'
  and a.status_code='CURRENT'
  and a.deal_type='FUT' and ((a.deal_subtype='BUY' and p_fund_invest='INVEST') or
     (a.deal_subtype = 'SELL' and p_fund_invest = 'FUND') or p_fund_invest='NONE')
  and a.contract_code = b.contract_code
  and b.financial_contract = 'F';
--

cursor get_data2 is
select a.company_code,a.portfolio_code,a.deal_number,a.transaction_number,
	a.deal_type,a.deal_subtype,a.currency,a.INTEREST_RATE transaction_rate,
	a.start_date,a.maturity_date,p_to_date to_date,p_from_date from_date,
        decode(a.deal_type,
         'TMM',decode(sign(p_to_date-greatest(nvl(a.maturity_date,p_from_date),
	nvl(b.settle_date,b.start_date))+1),1,'FLOAT',
					decode(sign(nvl(b.settle_date,b.start_date)-a.maturity_date+1),1,'FIXED','FLOAT')),
         'RTMM',decode(sign(p_to_date-greatest(nvl(a.maturity_date,p_from_date),
	nvl(b.settle_date,b.start_date))+1),1,'FLOAT',
					decode(sign(nvl(b.settle_date,b.start_date)-a.maturity_date+1),1,'FIXED','FLOAT')),
         'IRS',decode(sign(p_to_date-nvl(a.maturity_date,p_from_date)+1),1,b.fixed_or_floating_rate,'FLOAT'),
        decode(sign(p_to_date-nvl(a.maturity_date,p_from_date)+1),1,'FLOAT','FIXED')) FIXED_OR_FLOAT,
        nvl(decode(a.deal_type,
         'TMM',decode(decode(sign(p_to_date-greatest(nvl(a.maturity_date,p_from_date),nvl(b.settle_date,b.start_date))+1),1,'FLOAT',decode(sign(nvl(b.settle_date,b.start_date)-a.maturity_date+1),1,'FIXED','FLOAT')),
                 'FLOAT',
                   decode(sign(p_to_date-nvl(b.settle_date,b.start_date)+1),1,
                     nvl(b.maturity_date,p_from_date+1)-a.start_date+decode(sign(a.start_date-p_from_date),-1,a.start_date-p_from_date,0),
                     nvl(b.maturity_date,p_from_date+1)-a.start_date+decode(sign(a.start_date-p_from_date),-1,a.start_date-p_from_date,0)-
			(nvl(b.settle_date,b.start_date)-p_to_date)),
                 'FIXED',
                   nvl(b.settle_date,b.start_date)-p_to_date),
         'RTMM',decode(decode(sign(p_to_date-greatest(nvl(a.maturity_date,p_from_date),nvl(b.settle_date,b.start_date))+1),1,'FLOAT',decode(sign(nvl(b.settle_date,b.start_date)-a.maturity_date+1),1,'FIXED','FLOAT')),
                 'FLOAT',
                   decode(sign(p_to_date-nvl(b.settle_date,b.start_date)+1),1,
                     nvl(b.maturity_date,p_from_date+1)-a.start_date+decode(sign(a.start_date-p_from_date),-1,a.start_date-p_from_date,0),
                     nvl(b.maturity_date,p_from_date+1)-a.start_date+decode(sign(a.start_date-p_from_date),-1,a.start_date-p_from_date,0)-
			(nvl(b.settle_date,b.start_date)-p_to_date)),
                 'FIXED',
                   nvl(b.settle_date,b.start_date)-p_to_date),
        'IRS',nvl(b.maturity_date,p_from_date+1)-a.start_date+decode(sign(a.start_date-p_from_date),-1,a.start_date-p_from_date,0),
        'DEB',nvl(b.maturity_date,p_from_date+1)-a.start_date+decode(sign(a.start_date-p_from_date),-1,a.start_date-p_from_date,0),
         nvl(a.maturity_date,p_from_date+1)-a.start_date+decode(sign(a.start_date-p_from_date),-1,a.start_date-p_from_date,0)),0) no_of_days,
         nvl(sum(decode(a.deal_type,
        'TMM',decode(nvl(a.balance_out,0),0,a.balance_out_bf,a.balance_out),
        'RTMM',decode(nvl(a.balance_out,0),0,a.balance_out_bf,a.balance_out),
        'DEB',decode(nvl(a.balance_out,0),0,a.balance_out_bf,a.balance_out),
        a.balance_out)),0) gross_amount
 from XTR_ROLLOVER_TRANSACTIONS_V a,
      XTR_DEALS_V b
   where a.company_code like p_company_code and a.currency like p_currency
      and a.status_code='CURRENT'
      and a.portfolio_code like p_portfolio_code
      and nvl(a.maturity_date,p_from_date+1) >p_from_date
      and a.start_date <=p_from_date
      and a.deal_type in('ONC','CMF','IRS','DEB','FX','TMM','RTMM')
      and ((a.deal_type in('ONC','RTMM','TMM','IRS','CMF','FX') and (a.deal_subtype='INVEST' and p_fund_invest='INVEST'))
         or (a.deal_type in('ONC','TMM','RTMM','IRS','CMF','FX') and (a.deal_subtype='FUND' and p_fund_invest='FUND'))
        or (p_fund_invest='NONE')
        or (a.DEAL_TYPE in('DEB') AND a.DEAL_SUBTYPE='BUY' and p_fund_invest='INVEST')
        or (a.DEAL_TYPE in('DEB') AND a.DEAL_SUBTYPE='ISSUE' and p_fund_invest='FUND')
        )
      and a.deal_number=b.deal_no
 having  nvl(sum(decode(a.deal_type,
        'TMM',decode(nvl(a.balance_out,0),0,a.balance_out_bf,a.balance_out),
        'RTMM',decode(nvl(a.balance_out,0),0,a.balance_out_bf,a.balance_out),
        'DEB',decode(nvl(a.balance_out,0),0,a.balance_out_bf,a.balance_out),
        a.balance_out)),0) >0
group by a.company_code,a.portfolio_code,a.deal_number,a.transaction_number,a.deal_type,a.deal_subtype,a.currency,a.INTEREST_RATE,a.start_date,a.maturity_date,p_to_date,p_from_date,
        decode(a.deal_type,
         'TMM',decode(sign(p_to_date-greatest(nvl(a.maturity_date,p_from_date),nvl(b.settle_date,b.start_date))+1),1,'FLOAT',
				decode(sign(nvl(b.settle_date,b.start_date)-a.maturity_date+1),1,'FIXED','FLOAT')),
         'RTMM',decode(sign(p_to_date-greatest(nvl(a.maturity_date,p_from_date),nvl(b.settle_date,b.start_date))+1),1,'FLOAT',
				decode(sign(nvl(b.settle_date,b.start_date)-a.maturity_date+1),1,'FIXED','FLOAT')),
         'IRS',decode(sign(p_to_date-nvl(a.maturity_date,p_from_date)+1),1,b.fixed_or_floating_rate,'FLOAT'),
         decode(sign(p_to_date-nvl(a.maturity_date,p_from_date)+1),1,'FLOAT','FIXED')),
         nvl(decode(a.deal_type,
         'TMM',decode(decode(sign(p_to_date-greatest(nvl(a.maturity_date,p_from_date),nvl(b.settle_date,b.start_date))+1),1,'FLOAT',decode(sign(nvl(b.settle_date,b.start_date)-a.maturity_date+1),1,'FIXED','FLOAT')),
                 'FLOAT',
                   decode(sign(p_to_date-nvl(b.settle_date,b.start_date)+1),1,
                     nvl(b.maturity_date,p_from_date+1)-a.start_date+decode(sign(a.start_date-p_from_date),-1,a.start_date-p_from_date,0),
                     nvl(b.maturity_date,p_from_date+1)-a.start_date+decode(sign(a.start_date-p_from_date),-1,a.start_date-p_from_date,0)- (nvl(b.settle_date,b.start_date)-p_to_date)),
                 'FIXED',
                   nvl(b.settle_date,b.start_date)-p_to_date),
         'RTMM',decode(decode(sign(p_to_date-greatest(nvl(a.maturity_date,p_from_date),nvl(b.settle_date,b.start_date))+1),1,'FLOAT',decode(sign(nvl(b.settle_date,b.start_date)-a.maturity_date+1),1,'FIXED','FLOAT')),
                 'FLOAT',
                   decode(sign(p_to_date-nvl(b.settle_date,b.start_date)+1),1,
                     nvl(b.maturity_date,p_from_date+1)-a.start_date+decode(sign(a.start_date-p_from_date),-1,a.start_date-p_from_date,0),
                     nvl(b.maturity_date,p_from_date+1)-a.start_date+decode(sign(a.start_date-p_from_date),-1,a.start_date-p_from_date,0)- (nvl(b.settle_date,b.start_date)-p_to_date)),
                 'FIXED',
                   nvl(b.settle_date,b.start_date)-p_to_date),
         'IRS',nvl(b.maturity_date,p_from_date+1)-a.start_date+decode(sign(a.start_date-p_from_date),-1,a.start_date-p_from_date,0),
         'DEB',nvl(b.maturity_date,p_from_date+1)-a.start_date+decode(sign(a.start_date-p_from_date),-1,a.start_date-p_from_date,0),
          nvl(a.maturity_date,p_from_date+1)-a.start_date+decode(sign(a.start_date-p_from_date),-1,a.start_date-p_from_date,0)),0);

l_sysdate date :=sysdate;
l_fixed_or_float varchar2(5);
l_syn_phy        varchar2(1);
begin
delete from XTR_INTEREST_RATE_EXPOSURE where created_on <sysdate-1;
commit;
for c in get_ca loop
insert into XTR_INTEREST_RATE_EXPOSURE(FUND_INVEST,CREATED_BY,
 COMPANY_CODE,CREATED_ON,CURRENCY,DEAL_NUMBER,DEAL_SUBTYPE,DEAL_TYPE,
 FIXED_OR_FLOAT,FROM_DATE,GROSS_AMOUNT,MATURITY_DATE,NO_OF_DAYS,
 PORTFOLIO_CODE,REF_NUMBER,START_DATE,TO_DATE,TRANSACTION_NUMBER,TRANSACTION_RATE,SYN_FLAG,SYN_PHY)
 values(p_fund_invest,fnd_global.user_id,c.COMPANY_CODE,l_sysdate,c.CURRENCY,c.DEAL_NUMBER,c.DEAL_SUBTYPE,c.DEAL_TYPE,
 c.FIXED_OR_FLOAT,c.FROM_DATE,c.GROSS_AMOUNT,c.MATURITY_DATE,c.NO_OF_DAYS,
 c.PORTFOLIO_CODE,p_unique_ref_number,c.START_DATE,c.TO_DATE,c.TRANSACTION_NUMBER,c.TRANSACTION_RATE,'N','P');
end loop;
for c in get_data1 loop
 if c.deal_type in('ONC','CA','IG','NI','TMM','BOND','DEB','CMF','RTMM') then
   l_syn_phy :='P';
 else
   l_syn_phy :='S';
 end if;
insert into XTR_INTEREST_RATE_EXPOSURE(FUND_INVEST,CREATED_BY,
 COMPANY_CODE,CREATED_ON,CURRENCY,DEAL_NUMBER,DEAL_SUBTYPE,DEAL_TYPE,
 FIXED_OR_FLOAT,FROM_DATE,GROSS_AMOUNT,MATURITY_DATE,NO_OF_DAYS,
 PORTFOLIO_CODE,REF_NUMBER,START_DATE,TO_DATE,TRANSACTION_NUMBER,TRANSACTION_RATE,SYN_FLAG,SYN_PHY)
 values(p_fund_invest,fnd_global.user_id,c.COMPANY_CODE,l_sysdate,c.CURRENCY,c.DEAL_NUMBER,c.DEAL_SUBTYPE,c.DEAL_TYPE,
 c.FIXED_OR_FLOAT,c.FROM_DATE,c.GROSS_AMOUNT,c.MATURITY_DATE,c.NO_OF_DAYS,
 c.PORTFOLIO_CODE,p_unique_ref_number,c.START_DATE,c.TO_DATE,c.TRANSACTION_NUMBER,c.TRANSACTION_RATE,'N',l_syn_phy);
 if c.deal_type in('IRS','FRA','SWPTN','IRO','BDO') and nvl(c.gross_amount,0) <>0 then
   if c.fixed_or_float='FIXED' then
    l_fixed_or_float :='FLOAT';
   else
    l_fixed_or_float :='FIXED';
   end if;
 insert into XTR_INTEREST_RATE_EXPOSURE(FUND_INVEST,CREATED_BY,
  COMPANY_CODE,CREATED_ON,CURRENCY,DEAL_NUMBER,DEAL_SUBTYPE,DEAL_TYPE,
  FIXED_OR_FLOAT,FROM_DATE,GROSS_AMOUNT,MATURITY_DATE,NO_OF_DAYS,
  PORTFOLIO_CODE,REF_NUMBER,START_DATE,TO_DATE,TRANSACTION_NUMBER,TRANSACTION_RATE,SYN_FLAG,SYN_PHY)
  values(p_fund_invest,fnd_global.user_id,c.COMPANY_CODE,l_sysdate,c.CURRENCY,c.DEAL_NUMBER,c.DEAL_SUBTYPE,c.DEAL_TYPE,
  l_fixed_or_float,c.FROM_DATE,-c.GROSS_AMOUNT,c.MATURITY_DATE,c.NO_OF_DAYS,
  c.PORTFOLIO_CODE,p_unique_ref_number,c.START_DATE,c.TO_DATE,c.TRANSACTION_NUMBER,c.TRANSACTION_RATE,'Y',l_syn_phy);
 end if;
end loop;
for c in get_fut loop
insert into XTR_INTEREST_RATE_EXPOSURE(FUND_INVEST,CREATED_BY,
 COMPANY_CODE,CREATED_ON,CURRENCY,DEAL_NUMBER,DEAL_SUBTYPE,DEAL_TYPE,
 FIXED_OR_FLOAT,FROM_DATE,GROSS_AMOUNT,MATURITY_DATE,NO_OF_DAYS,
 PORTFOLIO_CODE,REF_NUMBER,START_DATE,TO_DATE,TRANSACTION_NUMBER,TRANSACTION_RATE,SYN_FLAG,SYN_PHY)
 values(p_fund_invest,fnd_global.user_id,c.COMPANY_CODE,l_sysdate,c.CURRENCY,c.DEAL_NUMBER,c.DEAL_SUBTYPE,c.DEAL_TYPE,
 c.FIXED_OR_FLOAT,c.FROM_DATE,c.GROSS_AMOUNT,c.MATURITY_DATE,c.NO_OF_DAYS,
 c.PORTFOLIO_CODE,p_unique_ref_number,c.START_DATE,c.TO_DATE,c.TRANSACTION_NUMBER,c.TRANSACTION_RATE,'N','S');
 if nvl(c.gross_amount,0) <>0 then
   if c.fixed_or_float='FIXED' then
    l_fixed_or_float :='FLOAT';
   else
    l_fixed_or_float :='FIXED';
   end if;
 insert into XTR_INTEREST_RATE_EXPOSURE(FUND_INVEST,CREATED_BY,
  COMPANY_CODE,CREATED_ON,CURRENCY,DEAL_NUMBER,DEAL_SUBTYPE,DEAL_TYPE,
  FIXED_OR_FLOAT,FROM_DATE,GROSS_AMOUNT,MATURITY_DATE,NO_OF_DAYS,
  PORTFOLIO_CODE,REF_NUMBER,START_DATE,TO_DATE,TRANSACTION_NUMBER,TRANSACTION_RATE,SYN_FLAG,SYN_PHY)
  values(p_fund_invest,fnd_global.user_id,c.COMPANY_CODE,l_sysdate,c.CURRENCY,c.DEAL_NUMBER,c.DEAL_SUBTYPE,c.DEAL_TYPE,
  l_fixed_or_float,c.FROM_DATE,-c.GROSS_AMOUNT,c.MATURITY_DATE,c.NO_OF_DAYS,
  c.PORTFOLIO_CODE,p_unique_ref_number,c.START_DATE,c.TO_DATE,c.TRANSACTION_NUMBER,c.TRANSACTION_RATE,'Y','S');
 end if;
end loop;

for c in get_data2  loop
 if c.deal_type in('ONC','CA','IG','NI','TMM','BOND','DEB','CMF','RTMM') then
   l_syn_phy :='P';
 else
   l_syn_phy :='S';
 end if;
insert into XTR_INTEREST_RATE_EXPOSURE(FUND_INVEST,CREATED_BY,
 COMPANY_CODE,CREATED_ON,CURRENCY,DEAL_NUMBER,DEAL_SUBTYPE,DEAL_TYPE,
 FIXED_OR_FLOAT,FROM_DATE,GROSS_AMOUNT,MATURITY_DATE,NO_OF_DAYS,
 PORTFOLIO_CODE,REF_NUMBER,START_DATE,TO_DATE,TRANSACTION_NUMBER,TRANSACTION_RATE,SYN_FLAG,SYN_PHY)
 values(p_fund_invest,fnd_global.user_id,c.COMPANY_CODE,l_sysdate,c.CURRENCY,c.DEAL_NUMBER,c.DEAL_SUBTYPE,c.DEAL_TYPE,
 c.FIXED_OR_FLOAT,c.FROM_DATE,c.GROSS_AMOUNT,c.MATURITY_DATE,c.NO_OF_DAYS,
 c.PORTFOLIO_CODE,p_unique_ref_number,c.START_DATE,c.TO_DATE,c.TRANSACTION_NUMBER,c.TRANSACTION_RATE,'N',l_syn_phy);
 if c.deal_type in('IRS','FRA','SWPTN','IRO') and nvl(c.gross_amount,0) <>0 then
   if c.fixed_or_float='FIXED' then
    l_fixed_or_float :='FLOAT';
   else
    l_fixed_or_float :='FIXED';
   end if;
 insert into XTR_INTEREST_RATE_EXPOSURE(FUND_INVEST,CREATED_BY,
  COMPANY_CODE,CREATED_ON,CURRENCY,DEAL_NUMBER,DEAL_SUBTYPE,DEAL_TYPE,
  FIXED_OR_FLOAT,FROM_DATE,GROSS_AMOUNT,MATURITY_DATE,NO_OF_DAYS,
  PORTFOLIO_CODE,REF_NUMBER,START_DATE,TO_DATE,TRANSACTION_NUMBER,TRANSACTION_RATE,SYN_FLAG,SYN_PHY)
  values(p_fund_invest,fnd_global.user_id,c.COMPANY_CODE,l_sysdate,c.CURRENCY,c.DEAL_NUMBER,c.DEAL_SUBTYPE,c.DEAL_TYPE,
  l_fixed_or_float,c.FROM_DATE,-c.GROSS_AMOUNT,c.MATURITY_DATE,c.NO_OF_DAYS,
  c.PORTFOLIO_CODE,p_unique_ref_number,c.START_DATE,c.TO_DATE,c.TRANSACTION_NUMBER,c.TRANSACTION_RATE,'Y',l_syn_phy);
 end if;
end loop;
commit;
END INS_ACTUALS;



PROCEDURE VALIDATE_DEALS (p_deal_no      IN NUMBER,
                          p_trans_no	 IN NUMBER,
                          p_deal_type    IN VARCHAR2,
                          p_action_type  IN VARCHAR2,
                          p_validated_by IN VARCHAR2) is
--
 cursor GET_DATE is
  select INCREASE_EFFECTIVE_FROM_DATE,FROM_START_DATE,EFFECTIVE_FROM_DATE
  from XTR_TERM_ACTIONS
  where DEAL_NO = p_deal_no;

 -- bug #1295341   jhung
 cursor IRS_OTHER_DEAL is
  select b.deal_no
  from xtr_deals_v a, xtr_deals_v b
  where a.int_swap_ref = b.int_swap_ref
    and a.deal_type = b.deal_type
    and a.deal_type = 'IRS'
    and a.deal_subtype <> b.deal_subtype
    and a.deal_no = p_deal_no;
--
 c get_date%ROWTYPE;
 v_cnt  NUMBER := 0;
 u_cnt  NUMBER := 0;
 l_date DATE;
 receive_deal_no NUMBER;
--
begin
  if p_deal_type IN ('FX','FXO') then
   -- Actions are as follows (and the form they originated from)
   -- PRO0170 - NEW_FX_CONTRACT
   -- PRO0190 - FX_CONTRACT_SWAP (FX Contract re Exercise of FX Option)
   -- PRO0200 - ROLLOVER_OF_FX_CONTRACT
   -- PRO0200 - PREDELIVERY_OF_FX_CONTRACT
   -- PRO0190 - NEW_FXO_CONTRACT
   -- PRO0190 - EXERCISE_OF_FX_OPTION_CONTRACT
   if p_action_type in('NEW_FX_CONTRACT',
                        'NEW_FXO_CONTRACT',
                        'FX_CONTRACT_SWAP',
                        'ROLLOVER_OF_FX_CONTRACT',
                        'PREDELIVERY_OF_FX_CONTRACT') then
    update XTR_DEALS
     set DUAL_AUTHORISATION_BY = p_validated_by,
         DUAL_AUTHORISATION_ON = decode(nvl(p_validated_by,'@@'),'@@',NULL,sysdate)
     where DEAL_NO = p_deal_no
       and DEAL_TYPE = p_deal_type;
   elsif p_action_type='EXERCISE_OF_FX_OPTION_CONTRACT' then
    update XTR_DEALS
     set SETTLE_DUAL_AUTHORISATION_BY = p_validated_by,
         SETTLE_DUAL_AUTHORISATION_ON = decode(nvl(p_validated_by,'@@'),'@@',NULL,sysdate)
     where DEAL_NO = p_deal_no
       and DEAL_TYPE = p_deal_type;
   end if;
  elsif p_deal_type ='FRA' then
  -- Actions are as follows (and the form they originated from)
    -- PRO0770 - NEW_FRA_CONTRACT
    -- PRO0770 - SETTLEMENT_OF_FRA_CONTRACT
   if p_action_type ='NEW_FRA_CONTRACT' then
    update XTR_DEALS
     set DUAL_AUTHORISATION_BY = p_validated_by,
         DUAL_AUTHORISATION_ON = decode(nvl(p_validated_by,'@@'),'@@',NULL,sysdate)
     where DEAL_NO = p_deal_no
       and DEAL_TYPE = p_deal_type;
   elsif p_action_type='SETTLEMENT_OF_FRA_CONTRACT' then
    update XTR_DEALS
     set SETTLE_DUAL_AUTHORISATION_BY = p_validated_by,
         SETTLE_DUAL_AUTHORISATION_ON = decode(nvl(p_validated_by,'@@'),'@@',NULL,sysdate)
     where DEAL_NO = p_deal_no
       and DEAL_TYPE = p_deal_type;
   end if;
  elsif p_deal_type ='IRO' then
  -- Actions are as follows (and the form they originated from)
     -- PRO0270 - NEW_IRO_CONTRACT
     -- PRO0270 - Settlement of IRO Contract
   if p_action_type = 'NEW_IRO_CONTRACT' then
    update XTR_DEALS
     set DUAL_AUTHORISATION_BY = p_validated_by,
         DUAL_AUTHORISATION_ON = decode(nvl(p_validated_by,'@@'),'@@',NULL,sysdate)
     where DEAL_NO = p_deal_no
       and DEAL_TYPE = p_deal_type;
   elsif p_action_type = 'EXERCISE_OF_IRO_CONTRACT' then
    update XTR_DEALS
     set SETTLE_DUAL_AUTHORISATION_BY = p_validated_by,
         SETTLE_DUAL_AUTHORISATION_ON = decode(nvl(p_validated_by,'@@'),'@@',NULL,sysdate)
     where DEAL_NO = p_deal_no
       and DEAL_TYPE = p_deal_type;
   end if;
  elsif p_deal_type ='BDO' then
  -- Actions are as follows (and the form they originated from)
   if p_action_type = 'NEW_BOND_OPTION_CONTRACT' then
    update XTR_DEALS
     set DUAL_AUTHORISATION_BY = p_validated_by,
         DUAL_AUTHORISATION_ON = decode(nvl(p_validated_by,'@@'),'@@',NULL,sysdate)
     where DEAL_NO = p_deal_no
       and DEAL_TYPE = p_deal_type;
   elsif p_action_type = 'EXERCISE_OF_BOND_OPTION_CONTRACT' then
    update XTR_DEALS
     set SETTLE_DUAL_AUTHORISATION_BY = p_validated_by,
         SETTLE_DUAL_AUTHORISATION_ON = decode(nvl(p_validated_by,'@@'),'@@',NULL,sysdate)
     where DEAL_NO = p_deal_no
       and DEAL_TYPE = p_deal_type;
   end if;
  elsif p_deal_type ='NI' then
  -- Actions are as follows (and the form they originated from)
     -- PRO0240 - NEW_NI_CONTRACT
   if p_action_type ='NEW_NI_CONTRACT' then
    update XTR_DEALS
     set DUAL_AUTHORISATION_BY = p_validated_by,
         DUAL_AUTHORISATION_ON = decode(nvl(p_validated_by,'@@'),'@@',NULL,sysdate)
     where DEAL_NO = p_deal_no
       and DEAL_TYPE = p_deal_type;
   end if;
  elsif p_deal_type ='BOND' then
  -- Actions are as follows (and the form they originated from)
     -- PRO0280 - NEW_BOND_CONTRACT
   if p_action_type ='NEW_BOND_CONTRACT' then
    update XTR_DEALS
     set DUAL_AUTHORISATION_BY = p_validated_by,
         DUAL_AUTHORISATION_ON = decode(nvl(p_validated_by,'@@'),'@@',NULL,sysdate)
     where DEAL_NO = p_deal_no
       and DEAL_TYPE = p_deal_type;
   end if;
  elsif p_deal_type ='SWPTN' then
  -- Actions are as follows (and the form they originated from)
     -- PRO0290 - New SWPTN Contract
   if p_action_type ='NEW_SWAPTION_CONTRACT' then
    update XTR_DEALS
     set DUAL_AUTHORISATION_BY = p_validated_by,
         DUAL_AUTHORISATION_ON = decode(nvl(p_validated_by,'@@'),'@@',NULL,sysdate)
     where DEAL_NO = p_deal_no
       and DEAL_TYPE = p_deal_type;
    elsif p_action_type = 'EXERCISE_OF_SWAPTION_CONTRACT' then
      update XTR_DEALS
      set SETTLE_DUAL_AUTHORISATION_BY = p_validated_by,
          SETTLE_DUAL_AUTHORISATION_ON = decode(nvl(p_validated_by,'@@'),'@@',NULL,sysdate)
      where DEAL_NO = p_deal_no
       and DEAL_TYPE = p_deal_type;
   end if;
  elsif p_deal_type ='IRS' then
  -- Actions are as follows (and the form they originated from)
  -- bug #1295341   jhung
   if p_action_type ='NEW_INT_RATE_SWAP_CONTRACT' then
     open IRS_OTHER_DEAL;
     fetch IRS_OTHER_DEAL into receive_deal_no;
     close IRS_OTHER_DEAL;

    update XTR_DEALS        -- Update paying side deal
     set DUAL_AUTHORISATION_BY = p_validated_by,
         DUAL_AUTHORISATION_ON = decode(nvl(p_validated_by,'@@'),'@@',NULL,sysdate)
     where DEAL_NO = p_deal_no
       and DEAL_TYPE = p_deal_type;
    update XTR_DEALS         -- Update receiving side deal
     set DUAL_AUTHORISATION_BY = p_validated_by,
         DUAL_AUTHORISATION_ON = decode(nvl(p_validated_by,'@@'),'@@',NULL,sysdate)
     where DEAL_NO = receive_deal_no
       and DEAL_TYPE = p_deal_type;
   end if;
  elsif p_deal_type ='TMM' then
    ---- Only for NEW_WHOLESALE_TERM_CONTRACT at this stage. Should use TERM_ACTIONS like Retail Term
    update XTR_DEALS
     set DUAL_AUTHORISATION_BY = p_validated_by,
         DUAL_AUTHORISATION_ON = decode(nvl(p_validated_by,'@@'),'@@',NULL,sysdate)
     where DEAL_NO = p_deal_no
       and DEAL_TYPE = p_deal_type;

    update XTR_ROLLOVER_TRANSACTIONS
      set DUAL_AUTHORISATION_BY = p_validated_by,
          DUAL_AUTHORISATION_ON = decode(nvl(p_validated_by,'@@'),'@@',NULL,sysdate)
     where DEAL_NUMBER = p_deal_no
       and DEAL_TYPE = p_deal_type
       and settle_date is null;

  elsif p_deal_type = 'STOCK' then
     if p_action_type = 'NEW_STOCK_BUY_CONTRACT' then  -- BUY stock deal
        update XTR_DEALS
        set DUAL_AUTHORISATION_BY = p_validated_by,
            DUAL_AUTHORISATION_ON = decode(nvl(p_validated_by,'@@'),'@@',NULL,sysdate)
        where DEAL_NO = p_deal_no
        and DEAL_TYPE = p_deal_type;

	update XTR_DEAL_DATE_AMOUNTS
        set DUAL_AUTHORISATION_BY = p_validated_by,
            DUAL_AUTHORISATION_ON = decode(nvl(p_validated_by,'@@'),'@@',NULL,sysdate)
        where DEAL_NUMBER = p_deal_no
	and TRANSACTION_NUMBER = p_trans_no
        and DEAL_TYPE = p_deal_type;

     elsif p_action_type = 'NEW_STOCK_CASH_DIVIDEND' then  -- stock cash dividend
        update XTR_ROLLOVER_TRANSACTIONS
        set DUAL_AUTHORISATION_BY = p_validated_by,
            DUAL_AUTHORISATION_ON = decode(nvl(p_validated_by,'@@'),'@@',NULL,sysdate)
        where DEAL_NUMBER = p_deal_no
        and TRANSACTION_NUMBER = p_trans_no
        and DEAL_TYPE = p_deal_type;

        update XTR_DEAL_DATE_AMOUNTS
        set DUAL_AUTHORISATION_BY = p_validated_by,
            DUAL_AUTHORISATION_ON = decode(nvl(p_validated_by,'@@'),'@@',NULL,sysdate)
        where DEAL_NUMBER = p_deal_no
        and TRANSACTION_NUMBER = p_trans_no
        and DEAL_TYPE = p_deal_type;

     elsif p_action_type = 'NEW_STOCK_SELL_CONTRACT' then -- SELL stock deal
        update XTR_DEALS
        set DUAL_AUTHORISATION_BY = p_validated_by,
            DUAL_AUTHORISATION_ON = decode(nvl(p_validated_by,'@@'),'@@',NULL,sysdate)
        where DEAL_NO = p_deal_no
        and DEAL_TYPE = p_deal_type;
        update XTR_DEAL_DATE_AMOUNTS
        set DUAL_AUTHORISATION_BY = p_validated_by,
            DUAL_AUTHORISATION_ON = decode(nvl(p_validated_by,'@@'),'@@',NULL,sysdate)
        where DEAL_NUMBER = p_deal_no
        and DEAL_TYPE = p_deal_type;
     end if;

  elsif p_deal_type ='RTMM' then
  -- Actions are as follows (and the form they originated from)
     -- PRO0235 - NEW_RETAIL_TERM_CONTRACT
     --- PRINCIPAL_ADJUSTMENT_OF_RETAIL_TERM_CONTRA
     --- RETAIL_TERM_INTEREST_RESET
     --- Ammend Schedule Type for Retail Term
    if p_action_type ='NEW_RETAIL_TERM_CONTRACT' then
      update XTR_DEALS
      set DUAL_AUTHORISATION_BY = p_validated_by,
          DUAL_AUTHORISATION_ON = decode(nvl(p_validated_by,'@@'),'@@',NULL,sysdate)
      where DEAL_NO = p_deal_no
       and DEAL_TYPE = p_deal_type;

      update XTR_ROLLOVER_TRANSACTIONS
      set DUAL_AUTHORISATION_BY = p_validated_by,
          DUAL_AUTHORISATION_ON = decode(nvl(p_validated_by,'@@'),'@@',NULL,sysdate)
      where DEAL_NUMBER = p_deal_no
       and DEAL_TYPE = p_deal_type;

    else
      update XTR_TERM_ACTIONS
      set DUAL_AUTHORISATION_BY = p_validated_by,
          DUAL_AUTHORISATION_ON = decode(nvl(p_validated_by,'@@'),'@@',NULL,sysdate)
      where DEAL_NO = p_deal_no;
       open get_date;
        fetch get_date into c;
       close get_date;
       if c.INCREASE_EFFECTIVE_FROM_DATE is not null then
        l_date :=c.INCREASE_EFFECTIVE_FROM_DATE;
       elsif c.FROM_START_DATE is not null then
        l_date :=c.FROM_START_DATE;
       elsif c.EFFECTIVE_FROM_DATE is not null then
        l_date :=c.EFFECTIVE_FROM_DATE;
       end if;

       update XTR_ROLLOVER_TRANSACTIONS
        set DUAL_AUTHORISATION_ON = decode(nvl(p_validated_by,'@@'),'@@',NULL,sysdate),
     	    DUAL_AUTHORISATION_BY = p_validated_by
        where DEAL_NUMBER = p_deal_no
          and START_DATE >= l_date
          and DEAL_TYPE = p_deal_type;

     end if;
-- add on 01 July 98
  elsif p_deal_type ='ONC' then
      update XTR_ROLLOVER_TRANSACTIONS
      set DUAL_AUTHORISATION_BY = p_validated_by,
          DUAL_AUTHORISATION_ON = decode(nvl(p_validated_by,'@@'),'@@',NULL,sysdate)
      where DEAL_NUMBER = p_deal_no
        and TRANSACTION_NUMBER = p_trans_no
        and DEAL_TYPE = p_deal_type;

-- bug 2254835
  elsif p_deal_type = 'EXP' then
     if p_action_type = 'NEW_EXPOSURE_TRANSACTION' then
        update XTR_EXPOSURE_TRANSACTIONS
	set DUAL_AUTHORISATION_BY = p_validated_by,
	    DUAL_AUTHORISATION_ON = decode(nvl(p_validated_by,'@@'),'@@',NULL,sysdate)
	where TRANSACTION_NUMBER = p_trans_no;
     end if;


--  IAC Redesign Project bug 3800146
    elsif p_deal_type IN ('IAC') then
       if p_action_type in('INTERACCOUNT_TRANSFER') then
          update XTR_INTERACCT_TRANSFERS
          set DUAL_AUTHORISATION_BY = p_validated_by,
          DUAL_AUTHORISATION_ON= decode(nvl(p_validated_by,'@@'),'@@',NULL,sysdate)
          where TRANSACTION_NUMBER = p_trans_no;
       end if;

  end if;

end VALIDATE_DEALS;



PROCEDURE MAINT_PROJECTED_BALANCES IS
--
-- This stored procedure will maintain the balances
-- to reflect the actual bals + cflows from the actual bal date
-- until prior to today. We can then use this balance in instances
-- where the actual balance is fo an old date.
--
l_ccy         VARCHAR2(15);
l_acct_ccy    VARCHAR2(15);
l_acct        VARCHAR2(20);
l_acct_party  VARCHAR2(20);
l_state_date  DATE;
l_op_balance  NUMBER;
l_cflow       NUMBER;
l_settle_acct VARCHAR2(20);
--
cursor GET_OLD_ACCT_BALS is
 select a.ACCOUNT_NUMBER,a.OPENING_BALANCE,a.STATEMENT_DATE,a.CURRENCY,a.PARTY_CODE
  from XTR_BANK_ACCOUNTS a,
       XTR_PARTIES_V b
  where nvl(a.PROJECTED_BALANCE_UPDATED_ON,to_date('01/01/1980','DD/MM/YYYY')) < trunc(SYSDATE)
  and nvl(a.SETOFF_ACCOUNT_YN,'N') <> 'Y'
  and b.PARTY_CODE = a.PARTY_CODE
  and (b.PARTY_TYPE = 'C' or b.INTERNAL_PTY = 'Y');
--
cursor CFLOWS is
 select sum(CASHFLOW_AMOUNT),COMPANY_ACCOUNT,CURRENCY
  from XTR_SETTLEMENTS_V
  where AMOUNT_DATE > nvl(l_state_date,to_date('01/01/1980','DD/MM/YYYY'))
  and AMOUNT_DATE < trunc(SYSDATE)
  and COMPANY = l_acct_party
  and COMPANY_ACCOUNT = l_acct
  and CURRENCY = l_ccy
  group by COMPANY_ACCOUNT,CURRENCY;
--
begin
open GET_OLD_ACCT_BALS;
LOOP
 fetch GET_OLD_ACCT_BALS INTO l_acct,l_op_balance,l_state_date,l_ccy,l_acct_party;
 EXIT WHEN GET_OLD_ACCT_BALS%NOTFOUND;
 if l_state_date = (trunc(sysdate) - 1) then
  -- Balances are up to date therefore set projected balance = actual balance
  update XTR_BANK_ACCOUNTS
   set PROJECTED_BALANCE = OPENING_BALANCE,
       PROJECTED_BALANCE_UPDATED_ON = trunc(SYSDATE),
       PROJECTED_BALANCE_DATE = STATEMENT_DATE
   where ACCOUNT_NUMBER = l_acct
   and PARTY_CODE = l_acct_party
   and CURRENCY = l_ccy;
 else
  open CFLOWS;
   fetch CFLOWS INTO l_cflow,l_settle_acct,l_acct_ccy;
  if CFLOWS%FOUND then
   update XTR_BANK_ACCOUNTS
    set PROJECTED_BALANCE = nvl(l_op_balance,0) + nvl(l_cflow,0),
        PROJECTED_BALANCE_UPDATED_ON = trunc(SYSDATE),
        PROJECTED_BALANCE_DATE = (trunc(SYSDATE) -1)
    where ACCOUNT_NUMBER = l_settle_acct
    and PARTY_CODE = l_acct_party
    and CURRENCY = l_acct_ccy;
  else
   update XTR_BANK_ACCOUNTS
    set PROJECTED_BALANCE = nvl(l_op_balance,0),
        PROJECTED_BALANCE_UPDATED_ON = trunc(SYSDATE),
        PROJECTED_BALANCE_DATE = (trunc(SYSDATE) -1)
    where ACCOUNT_NUMBER = l_acct
    and PARTY_CODE = l_acct_party
    and CURRENCY = l_ccy;
  end if;
  close CFLOWS;
 end if;
END LOOP;
close GET_OLD_ACCT_BALS;
commit;
--
end MAINT_PROJECTED_BALANCES;



PROCEDURE CHK_PRO_AUTH
  (p_event  	  IN VARCHAR2,
   p_company_code IN VARCHAR2,
   p_user	  IN VARCHAR2,
   p_deal_type	  IN VARCHAR2,
   p_action	  IN VARCHAR2) is

 l_form_nos	VARCHAR2(10);

 ex_error_auth                 exception;
 ex_error_insert               exception;
 ex_error_delete               exception;
 ex_error_update               exception;
 ex_error_expiry               exception;
 ex_error_company			 exception;

/*
 cursor get_user_auth is
  SELECT AUTHORISED,AUTH_TO_CREATE,AUTH_TO_DELETE,
     AUTH_TO_UPDATE,PASSWORD_EXPIRY
   FROM XTR_USER_AUTHORITIES
    where USER_NAME=p_user
    and FORM_NOS=l_form_nos;
 l_auth varchar2(1);
 l_insert varchar2(1);
 l_delete varchar2(1);
 l_update varchar2(1);
 l_expiry_date date;
*/

 cursor get_user_company_auth is
  SELECT 'Y'
  FROM XTR_COMPANY_AUTHORITIES
   where DEALER_CODE=p_user
     and COMPANY_AUTHORISED_FOR_INPUT='Y'
     and PARTY_CODE =p_company_code;
  l_company_auth varchar2(1);

 cursor get_dealtype is
  select name
   from xtr_deal_types
   where deal_type=p_deal_type;

l_mesg varchar2(200);

begin
if p_company_code is not null then
  l_company_auth :='N';
  open get_user_company_auth;
  fetch get_user_company_auth into l_company_auth;
  close get_user_company_auth;
  if l_company_auth <>'Y' then
   raise ex_error_company;
  end if;
end if;

if p_event='DEALS' then
 if p_deal_type='ONC' then
  l_form_nos :='PRO0210';
 elsif p_deal_type='CA' then
  l_form_nos :='PRO1080';
 elsif p_deal_type='IG' then
  l_form_nos :='PRO1075';
 elsif p_deal_type='NI' then
  l_form_nos :='PRO0240';
 elsif p_deal_type='TMM' then
  l_form_nos :='PRO0239';
 elsif p_deal_type='BOND' then
  l_form_nos :='PRO0280';
 elsif p_deal_type='DEB' then
  l_form_nos :='PRO0310';
 elsif p_deal_type='IRS' then
  l_form_nos :='PRO0290';
 elsif p_deal_type='IRO' then
  l_form_nos :='PRO0230';
 elsif p_deal_type='FRA' then
  l_form_nos :='PRO0770';
 elsif p_deal_type='SWPTN' then
  l_form_nos :='PRO0320';
 elsif p_deal_type='FUT' then
  l_form_nos :='PRO0330';
 elsif p_deal_type='FX' then
  l_form_nos :='PRO0170';
 elsif p_deal_type='FXO' then
  l_form_nos :='PRO0190';
 end if;
end if;
 if l_form_nos is not null then
  l_mesg :=null;
  open get_dealtype;
  fetch get_dealtype into l_mesg;
  close get_dealtype;
/*
  l_auth :='N';
  open get_user_auth;
  fetch get_user_auth into l_auth,l_insert,l_delete,l_update,l_expiry_date;
  close get_user_auth;
  if l_auth <>'Y' then
   raise ex_error_auth;
  elsif nvl(l_expiry_date,sysdate+1)<trunc(sysdate) then
   raise ex_error_expiry;
  elsif p_action='INSERT' and l_insert <>'Y' then
   raise ex_error_insert;
  elsif p_action='DELETE' and l_delete <>'Y' then
   raise ex_error_delete;
  elsif p_action='UPDATE' and l_update <>'Y' then
   raise ex_error_update;
  end if;
*/
 end if;

exception
 when ex_error_company then
   FND_MESSAGE.Set_Name('XTR', 'XTR_2036');
   FND_MESSAGE.Set_Token('P_COMPANY_CODE', p_company_code);
   APP_EXCEPTION.Raise_exception;
/*
 when ex_error_auth then
   FND_MESSAGE.Set_Name('XTR', 'XTR_2037');
   FND_MESSAGE.Set_Token('L_MESG', l_mesg);
   APP_EXCEPTION.Raise_exception;
 when ex_error_expiry then
   FND_MESSAGE.Set_Name('XTR', 'XTR_2038');
   FND_MESSAGE.Set_Token('L_FORM_NOS', l_form_nos);
   APP_EXCEPTION.Raise_exception;
 when ex_error_insert then
   FND_MESSAGE.Set_Name('XTR', 'XTR_1003');
   FND_MESSAGE.Set_Token('L_MESG', l_mesg);
   APP_EXCEPTION.Raise_exception;
 when ex_error_delete then
   FND_MESSAGE.Set_Name('XTR', 'XTR_1004');
   FND_MESSAGE.Set_Token('L_MESG', l_mesg);
   APP_EXCEPTION.Raise_exception;
 when ex_error_update then
   FND_MESSAGE.Set_Name('XTR', 'XTR_1005');
   FND_MESSAGE.Set_Token('L_MESG', l_mesg);
   APP_EXCEPTION.Raise_exception;
*/
END CHK_PRO_AUTH;


PROCEDURE SETOFF is
-- Called form 1080 - banak a/c maintenance
 l_calc_date      DATE;
 roundfac         NUMBER;
 yr_basis         NUMBER;
 l_ccy            VARCHAR(15);
 l_setoff         VARCHAR(5);
 l_setoff_company VARCHAR(7);
 l_bank_code      VARCHAR(7);
 l_no_days        NUMBER;
 l_prv_date       DATE;
 l_this_rate      NUMBER;
 l_prv_rate       NUMBER;
 l_rate           NUMBER;
 l_prv_bal        NUMBER;
 l_int_bf         NUMBER;
 l_int_cf         NUMBER;
 l_int_set        NUMBER;
 l_interest       NUMBER;
 l_this_bal       NUMBER;
--
 cursor SEL_SETOFF_ACCT is
  select distinct rtrim(SETOFF),rtrim(BANK_CODE),
                  SETOFF_COMPANY,CURRENCY
   from XTR_BANK_ACCOUNTS;

 cursor FIND_SETOFF_RATE is
  select INTEREST_RATE
   from  XTR_INTEREST_RATE_RANGES
   where REF_CODE = l_setoff||'-'||l_bank_code
   and   MIN_AMT <= l_this_bal
   and   MAX_AMT >= l_this_bal;
--
 cursor RNDING is
  select ROUNDING_FACTOR,YEAR_BASIS
   from  XTR_MASTER_CURRENCIES_V
   where CURRENCY = l_ccy;
--
 cursor SETOFF_CAL_DATE is
  select distinct BALANCE_DATE
   from XTR_BANK_BALANCES
   where BALANCE_DATE >= (select max(BALANCE_DATE)
                           from XTR_BANK_BAL_INTERFACE)
   and   SETOFF = l_setoff
   order by BALANCE_DATE asc;
--
 cursor SETOFF_PRV_RATE is
  select INTEREST_RATE
   from XTR_BANK_BALANCES
   where ACCOUNT_NUMBER = l_setoff||'-'||l_bank_code
   and BALANCE_DATE = l_prv_date;
--
 cursor SETOFF_PREV_DETAILS is
  select a.BALANCE_DATE,nvl(sum(a.BALANCE_CFLOW),0),
    nvl(sum(a.ACCUM_INT_CFWD),0)
   from  XTR_BANK_BALANCES a
   where ACCOUNT_NUMBER = l_setoff||'-'||l_bank_code
   and   a.BALANCE_DATE = (select max(b.BALANCE_DATE)
                            from  XTR_BANK_BALANCES b
                            where ACCOUNT_NUMBER = l_setoff||'-'||l_bank_code
                            and   b.BALANCE_DATE < l_calc_date)
   group by a.BALANCE_DATE,a.ACCOUNT_NUMBER;
--
 cursor SETOFF_THIS_DETAILS is
  select nvl(sum(a.BALANCE_CFLOW),0)
   from  XTR_BANK_BALANCES a
   where SETOFF = l_setoff
   and   a.BALANCE_DATE = l_calc_date;
--
begin
 -- Calculate Setoff details
  open SEL_SETOFF_ACCT;
    LOOP
     fetch SEL_SETOFF_ACCT INTO l_setoff,l_bank_code,
                                l_setoff_company,l_ccy;
       EXIT WHEN SEL_SETOFF_ACCT%NOTFOUND;
        delete XTR_BANK_BALANCES
         where ACCOUNT_NUMBER = l_setoff||'-'||l_bank_code
         and BALANCE_DATE >= (select max(BALANCE_DATE)
                               from XTR_BANK_BAL_INTERFACE);
       open SETOFF_CAL_DATE;
       LOOP
       fetch SETOFF_CAL_DATE INTO l_calc_date;
       EXIT WHEN SETOFF_CAL_DATE%NOTFOUND;
        open SETOFF_PREV_DETAILS;
         fetch SETOFF_PREV_DETAILS INTO l_prv_date,l_prv_bal,l_int_bf;
        if SETOFF_PREV_DETAILS%NOTFOUND then
         l_prv_date := l_calc_date;
         l_prv_bal  := 0;
         l_int_bf   := 0;
         l_no_days  := 0;
        end if;
        open SETOFF_THIS_DETAILS;
         fetch SETOFF_THIS_DETAILS INTO l_this_bal;
        close SETOFF_THIS_DETAILS;
        open FIND_SETOFF_RATE;
         fetch FIND_SETOFF_RATE INTO l_rate;
        if  FIND_SETOFF_RATE%NOTFOUND then
         l_rate := 0;
        end if;
        close FIND_SETOFF_RATE;
        close SETOFF_PREV_DETAILS;
        open RNDING;
         fetch RNDING INTO roundfac,yr_basis;
        close RNDING;
        open SETOFF_PRV_RATE;
         fetch SETOFF_PRV_RATE INTO l_prv_rate;
        if SETOFF_PRV_RATE%NOTFOUND then
         l_prv_rate := 0;
        end if;
        close SETOFF_PRV_RATE;
        l_no_days  := (trunc(l_calc_date) - trunc(l_prv_date));
        l_interest := round(l_prv_bal * l_prv_rate / 100 * l_no_days
                           / yr_basis,roundfac);
        l_int_cf := l_int_bf + l_interest;
        l_rate := nvl(l_rate,0);
        insert into XTR_BANK_BALANCES
           (COMPANY_CODE,ACCOUNT_NUMBER,BALANCE_DATE,NO_OF_DAYS,
            STATEMENT_BALANCE,BALANCE_ADJUSTMENT,BALANCE_CFLOW,
            ACCUM_INT_BFWD,INTEREST,INTEREST_RATE,INTEREST_SETTLED,
            INTEREST_SETTLED_HCE,ACCUM_INT_CFWD,
	    created_on, created_by)
        values
           (l_setoff_company,l_setoff||'-'||l_bank_code,
            l_calc_date,l_no_days,l_this_bal,0,l_this_bal,l_int_bf,
            l_interest,l_rate,0,0,l_int_cf,
	    sysdate, fnd_global.user_id);
       END LOOP;
       close SETOFF_CAL_DATE;
   END LOOP;
   close SEL_SETOFF_ACCT;
 commit;
end SETOFF;


END XTR_MISC_P;

/
