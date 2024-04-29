--------------------------------------------------------
--  DDL for Package Body ARP_RAXINV_MLS_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_RAXINV_MLS_PACKAGE" AS
/* $Header: ARINVMLB.pls 120.2.12010000.2 2009/05/12 07:13:41 pbapna ship $ */

function ARP_RAXINV_MLS_FUNCTION return varchar2 is

-- variables used by build_where_clause
P_choice                varchar2(40)     := NULL;
P_open_invoice          varchar2(1)      := NULL;
P_cust_trx_type_id      number           := NULL;
p_cust_trx_class        varchar2(40)     := NULL;
P_installment_number    number		 := NULL;
P_dates_low             date  		 := NULL;
P_dates_high            date		 := NULL;
P_customer_id           number 		 := NULL;
P_customer_class_code   varchar2(40)	 := NULL;
P_trx_number_low        varchar2(40)	 := NULL;
P_trx_number_high       varchar2(40)	 := NULL;
P_batch_id              number		 := NULL;
P_customer_trx_id       number		 := NULL;
p_adj_number_low        varchar2(20)	 := NULL;
p_adj_number_high       varchar2(20)	 := NULL;
p_adj_dates_low         date		 := NULL;
p_adj_dates_high        date		 := NULL;

p_where1 		varchar2(8096);
p_where2 		varchar2(8096);
p_table1  		varchar2(8096);
p_table2  		varchar2(8096);

-- variables used by ARP_RAXINV_MLS_FUNCTION
p_userenv_lang 		varchar2(4);
p_base_lang 		varchar2(4);
retval 			number;
parm_number 		number;
parm_name		varchar2(80);
cr    			CONSTANT char(1) := '
';
select_sql1_c 		number;
select_sql1 		varchar2(10000);
select_sql2_c           number;
select_sql2             varchar2(10000);
lang_str 		varchar2(240);

TYPE select_rec_type IS RECORD
(language VARCHAR2(4));

select_rec1		select_rec_type;
select_rec2             select_rec_type;
null_rec       		CONSTANT select_rec_type := select_rec1;
l_ignore                INTEGER;

BEGIN

   select  substr(userenv('LANG'),1,4)
   into    p_userenv_lang
   from    dual;

   select  language_code
   into    p_base_lang
   from    fnd_languages
   where   installed_flag = 'B';


   arp_standard.debug('ARP_RAXINV_MLS_FUNCTION');

   arp_standard.debug('P_USERENV_LANG = ' || p_userenv_lang);

   /* Read in Parameter Values supplied by user */

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Transaction Class',parm_number);
   if retval = -1 then
      P_CUST_TRX_CLASS := NULL;
   else
      P_CUST_TRX_CLASS := FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   end if;
   arp_standard.debug('P_CUST_TRX_CLASS ='|| P_CUST_TRX_CLASS);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Transaction Type',parm_number);
   if retval = -1 then
      P_CUST_TRX_TYPE_ID := NULL;
   else
      P_CUST_TRX_TYPE_ID := FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   end if;
   arp_standard.debug('P_CUST_TRX_TYPE_ID ='|| to_char(P_CUST_TRX_TYPE_ID));

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Transaction Number Low',parm_number);
   if retval = -1 then
      P_TRX_NUMBER_LOW := NULL;
   else
      P_TRX_NUMBER_LOW := FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   end if;
   arp_standard.debug('P_TRX_NUMBER_LOW ='|| P_TRX_NUMBER_LOW);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Transaction Number High',parm_number);
   if retval = -1 then
      P_TRX_NUMBER_HIGH := NULL;
   else
      P_TRX_NUMBER_HIGH := FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   end if;
   arp_standard.debug('P_TRX_NUMBER_HIGH ='|| P_TRX_NUMBER_HIGH);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Print Date Low',parm_number);
   if retval = -1 then
      P_DATES_LOW := NULL;
   else
      P_DATES_LOW := fnd_date.canonical_to_date(FND_REQUEST_INFO.GET_PARAMETER(parm_number));
   end if;
   arp_standard.debug('P_DATES_LOW ='|| to_char(P_DATES_LOW));

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Print Date High',parm_number);
   if retval = -1 then
      P_DATES_HIGH := NULL;
   else
      P_DATES_HIGH := fnd_date.canonical_to_date(FND_REQUEST_INFO.GET_PARAMETER(parm_number));
   end if;
   arp_standard.debug('P_DATES_HIGH ='|| to_char(P_DATES_HIGH));

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Customer Class',parm_number);
   if retval = -1 then
      P_CUSTOMER_CLASS_CODE := NULL;
   else
      P_CUSTOMER_CLASS_CODE := FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   end if;
   arp_standard.debug('P_CUSTOMER_CLASS_CODE ='|| P_CUSTOMER_CLASS_CODE);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Customer',parm_number);
   if retval = -1 then
      P_CUSTOMER_ID := NULL;
   else
      P_CUSTOMER_ID := FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   end if;
   arp_standard.debug('P_CUSTOMER_ID ='|| to_char(P_CUSTOMER_ID));

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Installment Number',parm_number);
   if retval = -1 then
      P_INSTALLMENT_NUMBER := NULL;
   else
      P_INSTALLMENT_NUMBER := FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   end if;
   arp_standard.debug('P_INSTALLMENT_NUMBER ='|| to_char(P_INSTALLMENT_NUMBER));

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Open Invoices Only',parm_number);
   if retval = -1 then
      P_OPEN_INVOICE := NULL;
   else
      P_OPEN_INVOICE := FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   end if;
   arp_standard.debug('P_OPEN_INVOICE ='|| P_OPEN_INVOICE);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Print Choice',parm_number);
   if retval = -1 then
      P_CHOICE := NULL;
   else
      P_CHOICE := FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   end if;
   arp_standard.debug('P_CHOICE ='|| P_CHOICE);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Adjustment Number Low',parm_number);
   if retval = -1 then
      P_ADJ_NUMBER_LOW := NULL;
   else
      P_ADJ_NUMBER_LOW := FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   end if;
   arp_standard.debug('P_ADJ_NUMBER_LOW ='|| P_ADJ_NUMBER_LOW);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Adjustment Number High',parm_number);
   if retval = -1 then
      P_ADJ_NUMBER_HIGH := NULL;
   else
      P_ADJ_NUMBER_HIGH := FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   end if;
   arp_standard.debug('P_ADJ_NUMBER_HIGH ='|| P_ADJ_NUMBER_HIGH);

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Adjustment Date Low',parm_number);
   if retval = -1 then
      P_ADJ_DATES_LOW := NULL;
   else
      P_ADJ_DATES_LOW := fnd_date.canonical_to_date(FND_REQUEST_INFO.GET_PARAMETER(parm_number));
   end if;
   arp_standard.debug('P_ADJ_DATES_LOW ='|| to_char(P_ADJ_DATES_LOW));

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Adjustment Date High',parm_number);
   if retval = -1 then
      P_ADJ_DATES_HIGH := NULL;
   else
      P_ADJ_DATES_HIGH := fnd_date.canonical_to_date(FND_REQUEST_INFO.GET_PARAMETER(parm_number));
   end if;
   arp_standard.debug('P_ADJ_DATES_HIGH ='|| to_char(P_ADJ_DATES_HIGH));

   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Batch',parm_number);
   if retval = -1 then
      P_BATCH_ID := NULL;
   else
      P_BATCH_ID := FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   end if;
   arp_standard.debug('P_BATCH_ID ='|| to_char(P_BATCH_ID));

   arp_standard.debug('P_CUSTOMER_TRX_ID = ' || to_char(P_CUSTOMER_TRX_ID));

   arp_standard.debug('Will call BUILD_WHERE_CLAUSE');

        ARP_TRX_SELECT_CONTROL.build_where_clause (
                P_CHOICE,                -- IN      varchar2,
                P_OPEN_INVOICE,          -- IN      varchar2,
                P_CUST_TRX_TYPE_ID,      -- IN      number,
                P_CUST_TRX_CLASS,        -- IN      varchar2,
                P_INSTALLMENT_NUMBER,    -- IN      number,
                P_DATES_LOW,             -- IN      date,
                P_DATES_HIGH,            -- IN      date,
                P_CUSTOMER_ID,           -- IN      number,
                P_CUSTOMER_CLASS_CODE,   -- IN      varchar2,
                P_TRX_NUMBER_LOW,        -- IN      varchar2,
                P_TRX_NUMBER_HIGH,       -- IN      varchar2,
                P_BATCH_ID,              -- IN      number,
                P_CUSTOMER_TRX_ID,       -- IN      number,
                P_ADJ_NUMBER_LOW,        -- in      varchar2,
                P_ADJ_NUMBER_HIGH,       -- in      varchar2,
                P_ADJ_DATES_LOW,         -- in      date,
                P_ADJ_DATES_HIGH,        -- in      date,
                P_WHERE1, --                OUT     varchar2,
                P_WHERE2, --                OUT     varchar2,
                P_TABLE1, --                OUT     varchar2,
                P_TABLE2, --                OUT     varchar2,
                'MLS'                    -- in      varchar2
      );


   arp_standard.debug('done with BUILD_WHERE_CLAUSE');

    ------------------------------------------------
    -- To fix bug number 1170600 and 1158411.Changed the default
    -- langauge from userenv lang to base lang, in case the language
    -- of the customer is null
    ------------------------------------------------

/*Bug 8448291,changing base_lang to p_userenv_lang*/

select_sql1 :=
'select distinct(nvl(rtrim(substr(loc.language,1,4)), ''' || p_userenv_lang || ''')) language ' || cr ||
'from ' || p_table1 || cr ||
'where ' || cr || p_where1;

select_sql2 :=
'select distinct(nvl(rtrim(substr(loc.language,1,4)), ''' || p_userenv_lang || ''')) language ' || cr ||
'from ' || p_table2 || cr ||
'where ' || cr || p_where2;

   arp_standard.debug('raxinv.select_sql1 =  ' || cr ||
                       select_sql1 || cr );

   arp_standard.debug('raxinv.select_sql2 =  ' || cr ||
                       select_sql2 || cr );


    ------------------------------------------------
    -- Parse sql stmts
    ------------------------------------------------

   BEGIN
        arp_standard.debug( '  Parsing select_sql1 stmt');
        select_sql1_c := dbms_sql.open_cursor;
        dbms_sql.parse( select_sql1_c, select_sql1, dbms_sql.v7 );

    EXCEPTION
      WHEN OTHERS THEN
          arp_standard.debug( 'EXCEPTION: Error parsing select_sql1 stmt' );
          RAISE;
    END;

   BEGIN
        arp_standard.debug( '  Parsing select_sql2 stmt');
        select_sql2_c := dbms_sql.open_cursor;
        dbms_sql.parse( select_sql2_c, select_sql2, dbms_sql.v7 );

    EXCEPTION
      WHEN OTHERS THEN
          arp_standard.debug( 'EXCEPTION: Error parsing select_sql2 stmt' );
          RAISE;
    END;

    arp_standard.debug( 'Completed parsing select stmts' );

    arp_standard.debug( 'define_columns for select_sql1_c');
    dbms_sql.define_column( select_sql1_c, 1, select_rec1.language, 4);

    arp_standard.debug( 'define_columns for select_sql2_c');
    dbms_sql.define_column( select_sql2_c, 1, select_rec2.language, 4);

    arp_standard.debug( '  Executing select_sql1' );
    BEGIN
       l_ignore := dbms_sql.execute( select_sql1_c );

    EXCEPTION
      WHEN OTHERS THEN
            arp_standard.debug( 'EXCEPTION: Error executing select_sql1' );
            RAISE;
    END;

    arp_standard.debug( '  Executing select_sql2' );
    BEGIN
       l_ignore := dbms_sql.execute( select_sql2_c );

    EXCEPTION
      WHEN OTHERS THEN
            arp_standard.debug( 'EXCEPTION: Error executing select_sql2' );
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

   arp_standard.debug( '  Fetching select_sql2 stmt');

   -- concatenate languages from select_sql2_c if it has languages not yet in lang_str
   begin
     loop
         if (dbms_sql.fetch_rows( select_sql2_c ) > 0)
         then

            arp_standard.debug('  fetched a row' );
            select_rec2 := null_rec;
            ------------------------------------------------------
            -- Get column values
            ------------------------------------------------------
            dbms_sql.column_value( select_sql2_c, 1, select_rec2.language );
            arp_standard.debug( 'Language code: ' || select_rec2.language );

            if (lang_str is null) then

               lang_str := select_rec2.language;
            else
               if instr(lang_str,select_rec2.language) = 0 then
                  lang_str := lang_str || ',' ||  select_rec2.language;
               end if;
            end if;

         else
            arp_standard.debug('Done fetching select_sql2');
            EXIT;
         end if;
      end loop;
   end;

   return lang_str;

   end ARP_RAXINV_MLS_FUNCTION;

end ARP_RAXINV_MLS_PACKAGE;

/
