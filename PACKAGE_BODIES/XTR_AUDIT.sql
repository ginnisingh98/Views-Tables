--------------------------------------------------------
--  DDL for Package Body XTR_AUDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_AUDIT" AS
/* $Header: xtraudtb.pls 120.5.12010000.2 2009/12/02 09:52:36 nipant ship $ */



PROCEDURE XTR_AUDIT_REPORT(
	errbuf		      	OUT NOCOPY    	VARCHAR2,
	retcode		      	OUT NOCOPY   	VARCHAR2,
	p_event_group			VARCHAR2,
	p_audit_from_date		VARCHAR2,
	p_audit_to_date			VARCHAR2)
IS

cursor AUDIT_EVENTS is
	select EVENT
	from XTR_AUDIT_GROUPS
	where GROUP_CODE = p_event_group
	and EVENT <> 'AUDIT_GROUP_CODE_ROW';

cursor NEW_REQUEST is
	select XTR_AUDIT_SUMMARY_S.nextval
	from dual;


audit_requestion_id 	NUMBER	:= 999;

l_from_date		DATE 	:= to_date(p_audit_from_date, 'YYYY/MM/DD HH24:MI:SS');
l_to_date		DATE	:= to_date(p_audit_to_date,   'YYYY/MM/DD HH24:MI:SS');
l_date_from	 	VARCHAR2(25) := to_char(l_from_date,  'DD/MM/YYYY HH24:MI:SS');
l_date_to   		VARCHAR2(25) := to_char(l_to_date,    'DD/MM/YYYY HH24:MI:SS');

BEGIN

  open NEW_REQUEST;
  fetch NEW_REQUEST into audit_requestion_id;
  close NEW_REQUEST;

  FOR event_cur in AUDIT_EVENTS LOOP
    --dbms_output.put_line('event = '|| event_cur.EVENT);
    if event_cur.EVENT <> 'TERM DEPOSIT/ADVANCE ADJUSTMENTS' then
      XTR_AUDIT_RETRIEVE( 	to_char(fnd_global.user_id),
				audit_requestion_id,
				event_cur.EVENT,
				l_date_from,
				l_date_to );
    else
      XTR_TERM_ACTIONS_RETRIEVE(to_char(audit_requestion_id),
				audit_requestion_id,
				event_cur.EVENT,
				l_date_from,
				l_date_to );
    end if;
  END LOOP;

  SUBMIT_AUDIT_REPORT(to_char(audit_requestion_id),p_event_group, p_audit_from_date, p_audit_to_date );

END XTR_AUDIT_REPORT;

PROCEDURE XTR_AUDIT_RETRIEVE(p_audit_requested_by IN VARCHAR2,
		    p_audit_request_id	 IN NUMBER,
                    p_event_name         IN VARCHAR2,
                    p_date_from          IN VARCHAR2,
                    p_date_to            IN VARCHAR2) is

  native constant        integer := 1;
  V_MAX_COL constant     integer := 60;
  v_counter              binary_integer;
  v_table_column         xtr_audit_columns_v.table_column%TYPE;
  v_select               varchar2(4000);
  v_num_col              integer;
  v_sql                  varchar2(4000);
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
  v_new_created_on       date;
  v_new_created_by       varchar2(30);

  v_var1                 varchar2(255);

  TYPE t_col_title IS TABLE OF VARCHAR2(50)
    INDEX BY BINARY_INTEGER;

  TYPE t_col_type IS TABLE OF VARCHAR2(15)
    INDEX BY BINARY_INTEGER;

  TYPE t_col_pkey IS TABLE OF VARCHAR2(1)
    INDEX BY BINARY_INTEGER;

  TYPE t_old IS TABLE OF VARCHAR2(255)
    INDEX BY BINARY_INTEGER;

  TYPE t_new IS TABLE OF VARCHAR2(255)
    INDEX BY BINARY_INTEGER;

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
    select table_column,
	   column_title,
	   upper(nvl(p_key_yn,'N')),
	   upper(column_type)
	   --* Bug#3121210, rravunny
	   --*decode(event,'INTERGROUP TRANSFERS',decode(nvl(P_KEY_YN, 'N'),'Y',decode(table_column,'DEAL_NUMBER',1,'TRANSACTION_NUMBER',1,0),0),0)
    from XTR_AUDIT_COLUMNS
    where event = pc_event
    and ( nvl(audit_yn, 'N') = 'Y' or
	  nvl(P_KEY_YN, 'N') = 'Y' )
    --* Bug#3121210, rravunny
    order by decode(event,'INTERGROUP TRANSFERS',decode(nvl(P_KEY_YN, 'N'),'Y',decode(table_column,'DEAL_NUMBER',1,'TRANSACTION_NUMBER',1,0),0),0) desc
    ;

begin
  --
  -- Get the table name for audit
  --
  open c_get_table_name(p_event_name);
  fetch c_get_table_name into v_table_name,v_audit_table_name;
  IF c_get_table_name%NOTFOUND THEN
    close c_get_table_name;
    raise ex_error;
  ELSE
    close c_get_table_name;
  END IF;

  --
  -- Build select clause
  --
  open c_get_columns ( p_event_name );
/*
code below modified by Ilavenil to support audit feature for both new and existing table sin patchset F

Existing tables have PRORATE WHO columns like created_by, created_on, updated_by, updated_on.
Newly created tables have AOL wHO columns like created_by, creation_date, last_updated_by, last_update_date.
Due to this inconsistency, we are to go for the following IF, ELSIF, ELSE condition which handled this difference
in WHO column in a different manner.

IF condition covers all the existing table with PRORATE WHO columns.
ELSIF condition covers Xtr_Deals, which is to be handled specially, though it is an existing table.
ELSE condition covers all the newly created table.
*/
  If p_event_name in ('BANK A/C SETUP', 'BANK BALANCES', 'BOND ISSUES SETUP', 'BUY / SELL CURRENCIES',
                      'COMPANY LIMITS', 'COUNTERPARTY LIMITS', 'CURRENCIES SETUP', 'DEAL ORDERS',
                      'DEALER LIMITS', 'EXPOSURE TRANSACTIONS', 'EXPOSURE TYPES', 'GL REFERENCES',
                      'INTERGROUP TRANSFERS', 'JOURNAL STRUCTURE', 'JOURNALS', 'PARTIES',
                      'PARTY DEFAULTS', 'PORTFOLIOS SETUP', 'PRODUCT TYPES', 'RATE SETS', 'REVALUATION DETAIL',
                      'REVALUATION RATES', 'SETTLEMENTS', 'STANDING INSTRUCTIONS',
                      'TAX/BROKERAGE RATES', 'TAX/BROKERAGE SETUP', 'TERM DEPOSIT/ADVANCE ADJUSTMENTS',
                      'USER CODES SETUP') then
     v_select := 'nvl(UPDATED_ON,to_date(''01/01/1900'',''DD/MM/YYYY'')),UPDATED_BY, '||
	      'nvl(CREATED_ON,to_date(''01/01/1900'',''DD/MM/YYYY'')),CREATED_BY';

  --BUG 9049453 starts
  Elsif p_event_name = 'SYSTEM PARAMETERS' then
     v_select := 'nvl(UPDATED_ON,to_date(''01/01/1900'',''DD/MM/YYYY'')),UPDATED_BY, '||
	      'nvl(to_date(CREATED_ON) ,to_date(''01/01/1900'',''DD/MM/YYYY'')),CREATED_BY';
  --BUG 9049453 ends

  Elsif p_event_name = 'TRANSACTIONS' then
     v_select := 'nvl(UPDATED_ON_DATE,to_date(''01/01/1900'',''DD/MM/YYYY'')),UPDATED_BY_USER, '||
	      'nvl(CREATED_ON_DATE,to_date(''01/01/1900'',''DD/MM/YYYY'')),CREATED_BY_USER';
  Else
     v_select := 'nvl(LAST_UPDATE_DATE,to_date(''01/01/1900'',''DD/MM/YYYY'')),LAST_UPDATED_BY, '||
	      'nvl(CREATION_DATE,to_date(''01/01/1900'',''DD/MM/YYYY'')),CREATED_BY';
  End if;


  v_counter := 1;
  LOOP
    EXIT WHEN v_counter > V_MAX_COL;
    fetch c_get_columns into 	v_table_column,
				v_col_title( v_counter),
                             	v_col_pkey( v_counter),
				v_col_type( v_counter);
    EXIT WHEN c_get_columns%NOTFOUND;

    IF substr(v_col_type(v_counter),1,4) = 'DATE' THEN
      v_select := v_select || ', to_char('||v_table_column||',''DD/MM/YYYY HH24:MI:SS'')';
    ELSIF substr(v_col_type(v_counter),1,4) in ('CHAR','VARC') THEN
      v_select := v_select || ',' || v_table_column;
    ELSE
      v_select := v_select || ',to_char(' || v_table_column || ')';
    END IF;

    v_counter := v_counter + 1;
  END LOOP;
  close c_get_columns;
  v_num_col := v_counter -1;

  --
  -- Put all of SQL statement together (ie select + where clause)
  --
/*
code below modified by Ilavenil to support audit feature for both new and existing table sin patchset F

Existing tables have PRORATE WHO columns like created_by, created_on, updated_by, updated_on.
Newly created tables have AOL wHO columns like created_by, creation_date, last_updated_by, last_update_date.
Due to this inconsistency, we are to go for the following IF, ELSIF, ELSE condition which handled this difference
in WHO column in a different manner.

IF condition covers all the existing table with PRORATE WHO columns.
ELSIF condition covers Xtr_Deals, which is to be handled specially, though it is an existing table.
ELSE condition covers all the newly created table.
*/

 If p_event_name in ('BANK A/C SETUP', 'BANK BALANCES', 'BOND ISSUES SETUP', 'BUY / SELL CURRENCIES',
                      'COMPANY LIMITS', 'COUNTERPARTY LIMITS', 'CURRENCIES SETUP', 'DEAL ORDERS',
                      'DEALER LIMITS', 'EXPOSURE TRANSACTIONS', 'EXPOSURE TYPES', 'GL REFERENCES',
                      'INTERGROUP TRANSFERS', 'JOURNAL STRUCTURE', 'JOURNALS', 'PARTIES',
                      'PARTY DEFAULTS', 'PORTFOLIOS SETUP', 'PRODUCT TYPES', 'RATE SETS', 'REVALUATION DETAIL',
                      'REVALUATION RATES', 'SETTLEMENTS', 'STANDING INSTRUCTIONS', 'SYSTEM PARAMETERS',
                      'TAX/BROKERAGE RATES', 'TAX/BROKERAGE SETUP', 'TERM DEPOSIT/ADVANCE ADJUSTMENTS',
                      'USER CODES SETUP') then
    v_sql := 'select ''B'',' || v_select || ' FROM '||v_table_name||' '||
           'WHERE (updated_on between to_date('''|| p_date_from ||''',''DD/MM/YYYY HH24:MI:SS'') '||
           'and to_date('''|| p_date_to ||''',''DD/MM/YYYY HH24:MI:SS'')) OR '||
           '(created_on between to_date('''|| p_date_from ||''',''DD/MM/YYYY HH24:MI:SS'') '||
           'and to_date('''|| p_date_to ||''',''DD/MM/YYYY HH24:MI:SS''))  UNION ';

    v_sql := v_sql ||
 	   'select ''A'',' || v_select ||' from '||v_audit_table_name||' '||
           'WHERE (updated_on between to_date('''|| p_date_from ||''',''DD/MM/YYYY HH24:MI:SS'') '||
           'and to_date('''|| p_date_to ||''',''DD/MM/YYYY HH24:MI:SS'')) OR '||
           '(audit_date_stored between to_date('''|| p_date_from ||''',''DD/MM/YYYY HH24:MI:SS'') '||
           'and to_date('''|| p_date_to ||''',''DD/MM/YYYY HH24:MI:SS'')) '||'order by ';
  Elsif p_event_name = 'TRANSACTIONS' then
    v_sql := 'select ''A'',' || v_select ||' from '||'XTR_A_ALL_CONTRACTS_V'||' '||
           'WHERE (updated_on_date between to_date('''|| p_date_from ||''',''DD/MM/YYYY HH24:MI:SS'') '||
           'and to_date('''|| p_date_to ||''',''DD/MM/YYYY HH24:MI:SS'')) OR '||
           '(created_on_date between to_date('''|| p_date_from ||''',''DD/MM/YYYY HH24:MI:SS'') '||
           'and to_date('''|| p_date_to ||''',''DD/MM/YYYY HH24:MI:SS'')) '||'order by ';
  Else
    v_sql := 'select ''B'',' || v_select || ' FROM '||v_table_name||' '||
           'WHERE (LAST_UPDATE_DATE between to_date('''|| p_date_from ||''',''DD/MM/YYYY HH24:MI:SS'') '||
           'and to_date('''|| p_date_to ||''',''DD/MM/YYYY HH24:MI:SS'')) OR '||
           '(CREATION_DATE between to_date('''|| p_date_from ||''',''DD/MM/YYYY HH24:MI:SS'') '||
           'and to_date('''|| p_date_to ||''',''DD/MM/YYYY HH24:MI:SS''))  UNION ';

    v_sql := v_sql ||
 	   'select ''A'',' || v_select ||' from '||v_audit_table_name||' '||
           'WHERE (LAST_UPDATE_DATE between to_date('''|| p_date_from ||''',''DD/MM/YYYY HH24:MI:SS'') '||
           'and to_date('''|| p_date_to ||''',''DD/MM/YYYY HH24:MI:SS'')) OR '||
           '(audit_date_stored between to_date('''|| p_date_from ||''',''DD/MM/YYYY HH24:MI:SS'') '||
           'and to_date('''|| p_date_to ||''',''DD/MM/YYYY HH24:MI:SS'')) '||'order by ';
  End if;

  -- Add the primary key column/s to the SORT BY clause
  FOR v_counter IN 1..v_num_col LOOP
    IF v_col_pkey(v_counter) = 'Y' THEN
       v_sql := v_sql || to_char(v_counter+5)||',';
    END IF;
  END LOOP;
  v_sql := v_sql||'1,2,3'; -- Add B/A, "updated_on, updated_by" to SORT BY clause

  --
  -- Now set up dbms_sql cursor
  --
  v_cursor := dbms_sql.open_cursor;
  dbms_sql.parse(v_cursor,v_sql,native);
  dbms_sql.define_column(v_cursor,1,v_new_letter, 1);
  dbms_sql.define_column(v_cursor,2,v_new_updated_on);
  dbms_sql.define_column(v_cursor,3,v_new_updated_by,30);
  dbms_sql.define_column(v_cursor,4,v_new_created_on);
  dbms_sql.define_column(v_cursor,5,v_new_created_by,30);

  -- Its weird how come this next bit works !!??
  FOR v_counter IN 1..v_num_col LOOP
    dbms_sql.define_column( v_cursor,  v_counter+5, v_var1, 100);
  END LOOP;

  v_rows_processed := dbms_sql.execute( v_cursor );

  --
  -- Now loop through records in cursor.
  --
  v_rec_num := 1;
  FOR v_counter in 1..v_num_col LOOP
      v_old(v_counter) := 'XX';
  END LOOP;

  LOOP

    EXIT WHEN dbms_sql.fetch_rows(v_cursor) < 1;
    dbms_sql.column_value(v_cursor,1,v_new_letter);
    dbms_sql.column_value(v_cursor,2,v_new_updated_on);
    dbms_sql.column_value(v_cursor,3,v_new_updated_by);
    dbms_sql.column_value(v_cursor,4,v_new_created_on);
    dbms_sql.column_value(v_cursor,5,v_new_created_by);
    FOR v_counter IN 1..v_num_col LOOP
      dbms_sql.column_value(v_cursor,v_counter + 5,v_var1);
      v_new(v_counter) := v_var1;
    END LOOP;

    --
    -- See if primary keys MATCH
    --
    v_key_the_same := 'Y';
    v_reference_code := null;
    FOR v_counter IN 1..v_num_col LOOP
      IF v_col_pkey(v_counter) = 'Y' THEN
        IF v_reference_code is not null and v_new( v_counter ) is not null THEN
          v_reference_code := v_reference_code||'|';
        END IF;
        v_reference_code := v_reference_code||rtrim(v_new( v_counter ));
        IF nvl(v_old(v_counter),'JJ') <> nvl(v_new(v_counter),'JJ') THEN
          v_key_the_same := 'N';
        END IF;
      END IF;
    END LOOP;

    --fnd_message.debug('v_reference_code = ' ||v_reference_code || ' v_key_the_same = ' || v_key_the_same);

    IF v_key_the_same = 'Y' then

        --
        -- Insert any differences between individual columns
        --
        FOR v_counter IN 1..v_num_col LOOP
          IF nvl(v_old(v_counter),'JJ') <> nvl(v_new(v_counter),'JJ') THEN
            	insert into XTR_AUDIT_SUMMARY(
			AUDIT_REQUESTED_BY,
			AUDIT_REQUEST_ID,
			AUDIT_REQUESTED_ON,
                 	AUDIT_RECORDS_FROM,
			AUDIT_RECORDS_TO,
                 	NAME_OF_COLUMN_CHANGED,
			TABLE_NAME,
                 	REFERENCE_CODE,
			ACTION_CODE,
			UPDATED_ON_DATE,
                 	UPDATED_BY_USER,
			OLD_VALUE,
			NEW_VALUE,
			TRANSACTION_REF,
                 	NON_TRANSACTION_REF)
            	values
                	(p_audit_requested_by,
			p_audit_request_id,
			sysdate,
                 	to_date(p_date_from,'DD/MM/YYYY HH24:MI:SS'),
                 	to_date(p_date_to,'DD/MM/YYYY HH24:MI:SS'),
                 	rtrim(v_col_title(v_counter)),
			upper(v_table_name),
                 	rtrim(substr(v_reference_code,1,20)),
			'UPDATE',
                 	to_char(v_new_updated_on,'DD/MM/YYYY HH24:MI:SS'),
                 	substr(v_new_updated_by,1,10),
			rtrim(substr(v_old(v_counter),1,255)),
                 	rtrim(substr(v_new(v_counter),1,255)),
			null,
			v_new_letter);
          END IF;
        END LOOP;

    ELSE -- Insert row for auditing new creation

	IF v_new_created_on between
	    to_date(p_date_from, 'DD/MM/YYYY HH24:MI:SS') and
	    to_date(p_date_to  , 'DD/MM/YYYY HH24:MI:SS')  THEN
            	insert into XTR_AUDIT_SUMMARY(
			AUDIT_REQUESTED_BY,
			AUDIT_REQUEST_ID,
			AUDIT_REQUESTED_ON,
                 	AUDIT_RECORDS_FROM,
			AUDIT_RECORDS_TO,
                 	NAME_OF_COLUMN_CHANGED,
			TABLE_NAME,
                 	REFERENCE_CODE,
			ACTION_CODE,
			UPDATED_ON_DATE,
                 	UPDATED_BY_USER,
			OLD_VALUE,
			NEW_VALUE,
			TRANSACTION_REF,
                 	NON_TRANSACTION_REF)
            	values
                	(p_audit_requested_by,
			p_audit_request_id,
			sysdate,
                 	to_date(p_date_from,'DD/MM/YYYY HH24:MI:SS'),
                 	to_date(p_date_to,'DD/MM/YYYY HH24:MI:SS'),
                 	null,  	--rtrim(v_col_title(v_counter)),
			upper(v_table_name),
                 	rtrim(substr(v_reference_code,1,20)),
			'INSERT',
                 	to_char(v_new_created_on,'DD/MM/YYYY HH24:MI:SS'),
                 	substr(v_new_created_by,1,10),
			null,   	--rtrim(substr(v_old(v_counter),1,255)),
                 	null,		--rtrim(substr(v_new(v_counter),1,255)),
			null,
			v_new_letter);
        END IF;
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
END XTR_AUDIT_RETRIEVE;

PROCEDURE XTR_TERM_ACTIONS_RETRIEVE(p_audit_requested_by IN VARCHAR2,
		    p_audit_request_id 	 IN NUMBER,
                    p_event_name         IN VARCHAR2,
                    p_date_from          IN VARCHAR2,
                    p_date_to            IN VARCHAR2)
IS
BEGIN

       		insert into XTR_AUDIT_SUMMARY(
			AUDIT_REQUESTED_BY,
			AUDIT_REQUEST_ID,
			AUDIT_REQUESTED_ON,
                 	AUDIT_RECORDS_FROM,
			AUDIT_RECORDS_TO,
                 	NAME_OF_COLUMN_CHANGED,
			TABLE_NAME,
                 	REFERENCE_CODE,
			ACTION_CODE,
			UPDATED_ON_DATE,
                 	UPDATED_BY_USER,
			OLD_VALUE,
			NEW_VALUE,
			TRANSACTION_REF,
                 	NON_TRANSACTION_REF)
		select  p_audit_requested_by,
			p_audit_request_id,
			sysdate,
                 	to_date(p_date_from,'DD/MM/YYYY HH24:MI:SS'),
                 	to_date(p_date_to,'DD/MM/YYYY HH24:MI:SS'),
			null,
			'XTR_TERM_ACTIONS',
			to_char(DEAL_NO) ||'|'||INCREASE_EFFECTIVE_FROM_DATE,
			'PRINCIPAL',
			CREATED_ON,
			CREATED_BY,
			null,
			to_char(PRINCIPAL_ADJUST),
			null,
			null
		from 	XTR_TERM_ACTIONS
		where   (CREATED_ON between to_date(p_date_from,'DD/MM/YYYY HH24:MI:SS') and
					to_date(p_date_to,'DD/MM/YYYY HH24:MI:SS'))
		and     INCREASE_EFFECTIVE_FROM_DATE is not null
		and     PRINCIPAL_ADJUST is not null
	UNION
		select 	p_audit_requested_by,
			p_audit_request_id,
			sysdate,
			to_date(p_date_from,'DD/MM/YYYY HH24:MI:SS'),
			to_date(p_date_to,'DD/MM/YYYY HH24:MI:SS'),
			null,
			'XTR_TERM_ACTIONS',
			to_char(DEAL_NO) ||'|'||EFFECTIVE_FROM_DATE,
			'INTEREST',
			CREATED_ON,
			CREATED_BY,
			null,
			to_char(NEW_INTEREST_RATE),
			null,
			null
		from 	XTR_TERM_ACTIONS
		where   (CREATED_ON between to_date(p_date_from,'DD/MM/YYYY HH24:MI:SS') and
					to_date(p_date_to,'DD/MM/YYYY HH24:MI:SS'))
		and     EFFECTIVE_FROM_DATE is not null
		and 	NEW_INTEREST_RATE is not null
	UNION
		select 	p_audit_requested_by,
			p_audit_request_id,
			sysdate,
			to_date(p_date_from,'DD/MM/YYYY HH24:MI:SS'),
			to_date(p_date_to,'DD/MM/YYYY HH24:MI:SS'),
			null,
			'XTR_TERM_ACTIONS',
			to_char(DEAL_NO) ||'|'||FROM_START_DATE ,
			'SCHEDULE',
			CREATED_ON,
			CREATED_BY,
			null,
			PAYMENT_SCHEDULE_CODE ,
			null,
			null
		from 	XTR_TERM_ACTIONS
		where   (CREATED_ON between to_date(p_date_from,'DD/MM/YYYY HH24:MI:SS') and
					to_date(p_date_to,'DD/MM/YYYY HH24:MI:SS'))
		and 	FROM_START_DATE is not null
		and 	PAYMENT_SCHEDULE_CODE is not null;


END XTR_TERM_ACTIONS_RETRIEVE;


PROCEDURE SUBMIT_AUDIT_REPORT(	p_audit_request_id	NUMBER,
				p_event_group   VARCHAR2,
                       p_from_date		VARCHAR2,
				p_to_date		VARCHAR2)
IS
req_id                	NUMBER;
request_id            	NUMBER;
orig_req_id           	VARCHAR2(30);
number_of_copies      	number;
printer               	VARCHAR2(30);
print_style           	VARCHAR2(30);
save_output_flag      	VARCHAR2(30);
save_output_bool      	BOOLEAN;

BEGIN

/*
  --
  -- Get original request id
  --
  fnd_profile.get('CONC_REQUEST_ID', orig_req_id);
  request_id := to_number(orig_req_id);
  --
  -- Get print options
  --
  IF( NOT FND_CONCURRENT.GET_REQUEST_PRINT_OPTIONS(request_id,
						number_of_copies,
						print_style,
						printer,
						save_output_flag))THEN
    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
       xtr_debug_pkg.debug('SUBMIT_AUDIT_REPORT: ' || 'Message: get print options failed');
    END IF;
  ELSE
    IF (save_output_flag = 'Y') THEN
      save_output_bool := TRUE;
    ELSE
      save_output_bool := FALSE;
    END IF;
    --
    -- Set print options
    --
    IF (NOT FND_REQUEST.set_print_options( printer,
                                           print_style,
                                           number_of_copies,
                                           save_output_bool)) THEN
      IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
         xtr_debug_pkg.debug('SUBMIT_AUDIT_REPORT: ' || 'Set print options failed');
      END IF;
    END IF;
  END IF;

*/

  req_id := FND_REQUEST.SUBMIT_REQUEST('XTR',
			          'XTRAUSRM',
				  NULL,
				  trunc(sysdate),
			          FALSE,
				  p_audit_request_id,
                          null,
                          p_event_group,
				  null,
				  null,
				  null,
				  p_from_date,
				  p_to_date,
				  'N',
				  'N');
  COMMIT;
  IF (req_id = 0) THEN
    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
       xtr_debug_pkg.debug('SUBMIT_AUDIT_REPORT: ' || 'ERROR submitting concurrent request');
    END IF;
  ELSE
    IF xtr_debug_pkg.pg_sqlplus_enable_flag = 1 THEN
       xtr_debug_pkg.debug('SUBMIT_AUDIT_REPORT: ' || 'EXECUTION REPORT SUBMITTED');
    END IF;
  END IF;

END SUBMIT_AUDIT_REPORT;

END XTR_AUDIT;

/
