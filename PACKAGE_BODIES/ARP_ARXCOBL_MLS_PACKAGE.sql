--------------------------------------------------------
--  DDL for Package Body ARP_ARXCOBL_MLS_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_ARXCOBL_MLS_PACKAGE" AS
/* $Header: ARCBLMLB.pls 120.4 2006/06/20 22:35:02 alawang ship $ */

function ARP_ARXCOBL_MLS_FUNCTION return varchar2 is

-- variables used by build_where_clause
p_customer_name_from    hz_parties.party_name%TYPE;
p_customer_name_to      hz_parties.party_name%TYPE;
l_customer_id           number 		 := NULL;
p_where1 		varchar2(8096);
p_where2 		varchar2(8096);
p_table1  		varchar2(8096);

-- variables used by ARP_ARXCOBL_MLS_FUNCTION
p_userenv_lang 		varchar2(4);
retval 			number;
parm_number 		number;
parm_name		varchar2(80);
cr    			CONSTANT char(1) := '';
select_sql1_c 		number;
select_sql1 		varchar2(10000);
select_sql2_c           number;
select_sql2             varchar2(10000);
lang_str 		varchar2(240);
--Cursor to return the customer_id for the given range of customers
/* modified for tca uptake */
/* bug1946875: This cursor is not needed.
Cursor cusinfo(p_customer_name_from varchar2,
               p_customer_name_to varchar2) is
SELECT cust_acct.cust_account_id customer_id
  from hz_cust_accounts cust_acct,
       hz_parties party
  where cust_acct.party_id = party.party_id
    and upper(party.party_name) between
                 nvl(upper(p_customer_name_from),'A')
             and nvl(upper(p_customer_name_to),'Z');
*/
TYPE select_rec_type IS RECORD
(language VARCHAR2(4));

select_rec1		select_rec_type;
null_rec       		CONSTANT select_rec_type := select_rec1;
l_ignore                INTEGER;

BEGIN

   select  substr(userenv('LANG'),1,4)
   into    p_userenv_lang
   from    dual;

   arp_standard.debug('ARP_ARXCOBL_MLS_FUNCTION');

   arp_standard.debug('P_USERENV_LANG = ' || p_userenv_lang);

   /* Read in Parameter Values supplied by user */

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Customer Name From',parm_number);
   if retval = -1 then
      P_CUSTOMER_NAME_FROM := NULL;
   else
     P_CUSTOMER_NAME_FROM := FND_REQUEST_INFO.GET_PARAMETER(parm_number);

   end if;
   arp_standard.debug('P_CUSTOMER_NAME_FROM ='||P_CUSTOMER_NAME_FROM);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Customer Name To',parm_number);
   if retval = -1 then
      P_CUSTOMER_NAME_TO := NULL;
   else
      P_CUSTOMER_NAME_TO := FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   end if;
   arp_standard.debug('P_CUSTOMER_NAME_TO ='|| P_CUSTOMER_NAME_TO);

    arp_standard.debug('Will call BUILD_WHERE_CLAUSE');
        p_table1:='hz_cust_accounts cust_acct,';
        p_table1:=p_table1||'hz_cust_acct_sites acct_site,';
        p_table1:=p_table1||'hz_cust_site_uses site_uses,';
        p_table1:=p_table1||'hz_locations loc,';
        p_table1:=p_table1||'hz_party_sites party_site';
        p_where1:='cust_acct.cust_account_id=acct_site.cust_account_id';
        p_where1:=p_where1||' and acct_site.cust_acct_site_id=site_uses.cust_acct_site_id';
        p_where1:=p_where1||' and site_uses.site_use_code=''BILL_TO''';
        p_where1:=p_where1||' and acct_site.party_site_id = party_site.party_site_id';
        p_where1:=p_where1||' and loc.location_id = party_site.location_id';
/* bug1946875: cursor is not used. so this is not used , neither. */
--        p_where2:=p_where1||' and acct_site.cust_account_id=:l_customer_id';
        p_where2:=p_where1||' and  nvl(site_uses.status,''A'')=''A''';

/* bug1946875: add given customer parameters condition to where clause */
   if (p_customer_name_to is not null
       or p_customer_name_from is not null )then
        p_table1:=p_table1||',hz_parties party';
        p_where2:=p_where2||' and cust_acct.party_id = party.party_id' ;

       if p_customer_name_from is not null then
          /* bug1994326: add equal sign */
/*Bug2541377 Added replace function to check if their is any apostrophe and replace it with two single quotes*/
          p_where2:=p_where2||' and party.party_name >= :p_customer_name_from ' ;
       end if;

       if p_customer_name_to is not null then
          /* bug1994326: add equal sign */
/*Bug2541377 Added replace function to check if their is any apostrophe and replace it with two single quotes*/
          p_where2:=p_where2||' and party.party_name <= :p_customer_name_to ' ;
       end if;

    end if;

   arp_standard.debug('done with BUILD_WHERE_CLAUSE');

/* bug1946875: This cursor is not used. customer condition has already been included in select_sql1. */
   ---Customer Loop . For every customer the loop finds out the languages for corresponding Bill To addresses.


--  For Customer IN cusinfo(P_CUSTOMER_NAME_FROM,P_CUSTOMER_NAME_TO)
-- LOOP
select_sql1 :=
'select distinct(nvl(rtrim(substr(loc.language,1,4)), ''' || p_userenv_lang || ''')) language ' || cr ||
'from ' || p_table1 || cr ||
'where ' || cr || p_where2;
--dbms_output.put_line('select is'||select_sql1);

   arp_standard.debug('raxinv.select_sql1 =  ' || cr ||
                       select_sql1 || cr );


    ------------------------------------------------
    -- Parse sql stmts
    ------------------------------------------------

   BEGIN
        arp_standard.debug( '  Parsing select_sql1 stmt');
        select_sql1_c := dbms_sql.open_cursor;
        dbms_sql.parse( select_sql1_c, select_sql1, dbms_sql.v7 );
--        DBMS_SQL.BIND_VARIABLE(select_sql1_c,':l_customer_id',Customer.customer_id);
    EXCEPTION
      WHEN OTHERS THEN
          arp_standard.debug( 'EXCEPTION: Error parsing select_sql1 stmt' );
          RAISE;
    END;


    arp_standard.debug( 'Completed parsing select stmts' );

    arp_standard.debug( 'define_columns for select_sql1_c');
    dbms_sql.define_column( select_sql1_c, 1, select_rec1.language, 4);
    -- Bug 5173488: use bind variable instead of hard code literal in where clause.
    if p_customer_name_from is not null then
      dbms_sql.bind_variable(select_sql1_c, ':p_customer_name_from', p_customer_name_from);
    end if;
    if p_customer_name_to is not null then
      dbms_sql.bind_variable(select_sql1_c, ':p_customer_name_to', p_customer_name_to);
    end if;


        arp_standard.debug( '  Executing select_sql1' );
    BEGIN
       l_ignore := dbms_sql.execute( select_sql1_c );

    EXCEPTION
      WHEN OTHERS THEN
            arp_standard.debug( 'EXCEPTION: Error executing select_sql1' );
            RAISE;
    END;


   --------------------------------------------------------------
   -- Fetch rows
   --------------------------------------------------------------
   arp_standard.debug( '  Fetching select_sql1 stmt');

   begin
      loop
         if (dbms_sql.fetch_rows( select_sql1_c ) > 0)
         then

            arp_standard.debug('  fetched a row' );
            select_rec1 := null_rec;
            ------------------------------------------------------
            -- Get column values
            ------------------------------------------------------
            dbms_sql.column_value( select_sql1_c, 1, select_rec1.language );
            arp_standard.debug( 'Language code: ' || select_rec1.language );

            if (lang_str is null) then
               lang_str := select_rec1.language;
            else
               lang_str := lang_str || ',' ||  select_rec1.language;
            end if;

         else
            arp_standard.debug('Done fetching select_sql1');
            EXIT;
         end if;
      end loop;
  end;


  return lang_str;
  -- return('US');
--  end loop;

   end ARP_ARXCOBL_MLS_FUNCTION;

end ARP_ARXCOBL_MLS_PACKAGE;

/
