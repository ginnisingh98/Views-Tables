--------------------------------------------------------
--  DDL for Package Body AP_REPORTS_MLS_LANG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_REPORTS_MLS_LANG" AS
/* $Header: apxlangb.pls 120.4 2004/12/02 02:31:38 pjena noship $ */



   ---------------------------------------------------------------
   --  MLS function for "Invalid PO Supplier Notice" report
   ---------------------------------------------------------------
   FUNCTION APXVDLET RETURN VARCHAR2 IS

      lang_str VARCHAR2(500) := NULL;
      -- Bug 2633773 , to remove cartesian join in cursor languages_cursor
      l_base   FND_LANGUAGES.LANGUAGE_CODE%TYPE;

      CURSOR languages_cursor is
         SELECT DISTINCT(NVL(lang.language_code, l_base)) language_code
         FROM po_vendor_sites pvs,
              ap_invoices inv,
              po_vendors pv,
              ap_holds h,
              fnd_languages lang
         WHERE inv.vendor_site_id = pvs.vendor_site_id
         AND   inv.payment_status_flag in ('N', 'P')
         AND   pv.vendor_id = pvs.vendor_id
         AND   h.invoice_id = inv.invoice_id
         AND   h.hold_lookup_code = 'INVALID PO'
         AND   h.release_lookup_code is null
         AND   lang.nls_language (+) = pvs.language;

   BEGIN

     -- Bug 2633773 , select base language code into local variable
     select language_code
        INTO l_base
        from fnd_languages
        where installed_flag = 'B';


      FOR languages IN languages_cursor LOOP

         IF (lang_str IS NULL) THEN
            lang_str := languages.language_code;
         ELSE
            lang_str := lang_str || ',' || languages.language_code;
         END IF;

      END LOOP;

      RETURN (lang_str);

   END APXVDLET;

    -------------------------------------------------------------
   --  MLS function for "Prepayment Remittance Report" report
   -------------------------------------------------------------
   FUNCTION APXPPREM RETURN VARCHAR2 IS

      p_vendor_id 	NUMBER := NULL;
      p_invoice_id	NUMBER := NULL;
      p_prepay_id 	NUMBER := NULL;
      p_start_date 	DATE := NULL;
      p_end_date 	DATE := NULL;

      cursor_id		INTEGER;
      selectstmt 	VARCHAR2(1500);
      lang_str 		VARCHAR2(500) := NULL;
      l_language	VARCHAR2(4);
      dummy		INTEGER;

   BEGIN

      p_vendor_id  := to_number(fnd_request_info.get_parameter(1));
      p_invoice_id := to_number(fnd_request_info.get_parameter(2));
      p_prepay_id  := to_number(fnd_request_info.get_parameter(3));
      p_start_date := fnd_date.canonical_to_date(fnd_request_info.get_parameter(4));
      p_end_date   := fnd_date.canonical_to_date(fnd_request_info.get_parameter(5));

      -- Create a query string to get languages based on the parameters
      selectstmt := 'SELECT DISTINCT(NVL(lang.language_code, base.language_code))'||
                    ' FROM   po_vendors pvd,'||
                    '        po_vendor_sites pvs,'||
                    '        ap_invoices ai,'||
                    '        ap_invoices pp,'||
                    '        ap_invoice_prepays  aipp,'||
                    '        fnd_languages base,'||
                    '        fnd_languages lang'||
                    ' WHERE  aipp.invoice_id = ai.invoice_id'||
                    ' AND    aipp.prepay_id  = pp.invoice_id'||
                    ' AND    ai.vendor_id = pp.vendor_id'||
                    ' AND    ai.vendor_id = pvd.vendor_id'||
                    ' AND    pvd.vendor_id  = pvs.vendor_id'||
                    ' AND    pvs.vendor_site_id = ai.vendor_site_id'||
                    ' AND    base.installed_flag = ''B'' '||
                    ' AND    lang.nls_language (+) = pvs.language';

      -- add to where clause if other parameters are specified
      IF p_vendor_id IS NOT NULL THEN
         selectstmt := selectstmt||' AND ai.vendor_id = :p_vendor_id';
      END IF;

      IF p_invoice_id IS NOT NULL THEN
         selectstmt := selectstmt||' AND ai.invoice_id = :p_invoice_id';
      END IF;

      IF p_prepay_id IS NOT NULL THEN
         selectstmt := selectstmt||' AND pp.invoice_id = :p_prepay_id';
      END IF;

      IF p_start_date IS NOT NULL THEN
        selectstmt := selectstmt||' AND aipp.last_update_date >=  :p_start_date';
      END IF;

      IF p_end_date IS NOT NULL THEN
        selectstmt := selectstmt||' AND aipp.last_update_date <= :p_end_date';
      END IF;

      -- Added the following as part of the fix for 890934. Since the ap_invoice_prepays is obsolete
      -- in Release 11i, we need to use ap_invoice_distributions to get the 'PREPAY' information.

      selectstmt := selectstmt||' UNION SELECT DISTINCT(NVL(lang.language_code, base.language_code))'||
                    ' FROM   po_vendors pvd,'||
                    '        po_vendor_sites pvs,'||
                    '        ap_invoices ai,'||
                    '        ap_invoice_distributions aid,'||
	            '        ap_invoice_distributions aid2,'|| --3984580
                    '        fnd_languages base,'||
                    '        fnd_languages lang'||
                    ' WHERE  aid.invoice_id = ai.invoice_id'||
                    ' AND    aid.line_type_lookup_code  = ''PREPAY'' '||
                    ' AND    ai.vendor_id = pvd.vendor_id'||
                    ' AND    pvd.vendor_id  = pvs.vendor_id'||
                    ' AND    pvs.vendor_site_id = ai.vendor_site_id'||
                    ' AND    base.installed_flag = ''B'' '||
                    ' AND    nvl(aid.reversal_flag,''N'') != ''Y'' '||
                    ' AND    lang.nls_language (+) = pvs.language'||
                    ' AND    aid2.invoice_distribution_id = aid.prepay_distribution_id'||--3984580
                    ' AND    aid2.line_type_lookup_code = ''ITEM'' '; --3984580

      -- add to where clause if other parameters are specified
      IF p_vendor_id IS NOT NULL THEN
         selectstmt := selectstmt||' AND ai.vendor_id = :p_vendor_id';
      END IF;

      IF p_invoice_id IS NOT NULL THEN
         selectstmt := selectstmt||' AND ai.invoice_id = :p_invoice_id';
      END IF;

      IF p_prepay_id IS NOT NULL THEN
         selectstmt := selectstmt||' AND aid2.invoice_id = :p_prepay_id';  --3984580
      END IF;

--1901963, changed it to inv.invoice_date in the 2 statements below
--previously it was aipp.last_update_date, which doesn't make any sense
--for the second query in the union
      IF p_start_date IS NOT NULL THEN
        selectstmt := selectstmt||' AND ai.invoice_date >=  :p_start_date';
      END IF;

      IF p_end_date IS NOT NULL THEN
        selectstmt := selectstmt||' AND ai.last_update_date <= :p_end_date';
      END IF;

      -- Open the cursor for processing
      cursor_id := dbms_sql.open_cursor;

      -- Parse the query
      dbms_sql.parse(cursor_id, selectstmt, dbms_sql.v7);

      -- Bind input variables
      IF p_vendor_id IS NOT NULL THEN
         dbms_sql.bind_variable(cursor_id,':p_vendor_id',p_vendor_id);
      END IF;

      IF p_invoice_id IS NOT NULL THEN
         dbms_sql.bind_variable(cursor_id,':p_invoice_id',p_invoice_id);
      END IF;

      IF p_prepay_id IS NOT NULL THEN
         dbms_sql.bind_variable(cursor_id,':p_prepay_id',p_prepay_id);
      END IF;

      IF p_start_date IS NOT NULL THEN
         dbms_sql.bind_variable(cursor_id,':p_start_date',p_start_date);
      END IF;

      IF p_end_date IS NOT NULL THEN
         dbms_sql.bind_variable(cursor_id,':p_end_date',p_end_date);
      END IF;

      -- Define the output variable
      dbms_sql.define_column(cursor_id,1,l_language,4);

      -- Execute the query
      dummy := dbms_sql.execute(cursor_id);

      -- Create string of languages to be returned
      LOOP

         IF dbms_sql.fetch_rows(cursor_id) = 0 THEN
            EXIT;
         END IF;
         dbms_sql.column_value( cursor_id, 1, l_language );

         IF (lang_str IS NULL) THEN
             lang_str := l_language;
         ELSE
             lang_str := lang_str||','||l_language;
         END IF;
      END LOOP;

      dbms_sql.close_cursor(cursor_id);

      RETURN(lang_str);

   END APXPPREM;


   -------------------------------------------------------------
   --  MLS function for "Print Invoice Report" report
   -------------------------------------------------------------
   FUNCTION APXINPRT RETURN VARCHAR2 IS

      p_vendor_type 	VARCHAR2(25) := NULL;
      p_pay_group 	VARCHAR2(25) := NULL;
      p_invoice_type 	VARCHAR2(25) := NULL;
      p_vendor_id 	NUMBER := NULL;
      p_invoice_id	NUMBER := NULL;
      p_start_date 	DATE := NULL;
      p_end_date 	DATE := NULL;

      cursor_id		INTEGER;
      selectstmt 	VARCHAR2(1500);
      lang_str 		VARCHAR2(500) := NULL;
      l_language	VARCHAR2(4);
      dummy		INTEGER;

   BEGIN

      p_vendor_type  := fnd_request_info.get_parameter(1);
      p_vendor_id    := to_number(fnd_request_info.get_parameter(2));
      p_pay_group    := fnd_request_info.get_parameter(3);
      p_invoice_type := fnd_request_info.get_parameter(4);
      p_invoice_id   := to_number(fnd_request_info.get_parameter(5));
      p_start_date   := fnd_date.canonical_to_date(fnd_request_info.get_parameter(6));
      p_end_date     := fnd_date.canonical_to_date(fnd_request_info.get_parameter(7));

      -- Create a query string to get languages based on the parameters
      selectstmt := 'SELECT DISTINCT(NVL(lang.language_code, base.language_code))'||
                    ' FROM   po_vendors pvd,'					  ||
                    '        po_vendor_sites pvs,'				  ||
                    '        ap_invoices ai,'					  ||
                    '        fnd_languages base,'                                 ||
                    '        fnd_languages lang'                                  ||
                    ' WHERE  ai.vendor_id = pvd.vendor_id'			  ||
                    ' AND    pvd.vendor_id = pvs.vendor_id'			  ||
                    ' AND    ai.vendor_site_id  = pvs.vendor_site_id'		  ||
                    ' AND    base.installed_flag = ''B'' '			  ||
                    ' AND    lang.nls_language (+) = pvs.language';

      -- add to where clause if other parameters are specified
      IF p_vendor_type IS NOT NULL THEN
         selectstmt := selectstmt||' AND pvd.vendor_type_lookup_code = :p_vendor_type';
      END IF;
      IF p_pay_group IS NOT NULL THEN
         selectstmt := selectstmt||' AND ai.pay_group_lookup_code = :p_pay_group';
      END IF;

      IF p_vendor_id IS NOT NULL THEN
         selectstmt := selectstmt||' AND ai.vendor_id = :p_vendor_id';
      END IF;

      IF p_invoice_type IS NOT NULL THEN
         selectstmt := selectstmt||' AND ai.invoice_type_lookup_code = :p_invoice_type';
      END IF;

      IF p_invoice_id IS NOT NULL THEN
         selectstmt := selectstmt||' AND ai.invoice_id = :p_invoice_id';
      END IF;

      IF p_start_date IS NOT NULL THEN
        selectstmt := selectstmt||' AND ai.invoice_date >=  :p_start_date';
      END IF;

      IF p_end_date IS NOT NULL THEN
        selectstmt := selectstmt||' AND ai.invoice_date <= :p_end_date';
      END IF;

      -- Open the cursor for processing
      cursor_id := dbms_sql.open_cursor;

      -- Parse the query
      dbms_sql.parse(cursor_id, selectstmt, dbms_sql.v7);

      -- Bind input variables
      IF p_vendor_type IS NOT NULL THEN
         dbms_sql.bind_variable(cursor_id,':p_vendor_type',p_vendor_type);
      END IF;

      IF p_pay_group IS NOT NULL THEN
         dbms_sql.bind_variable(cursor_id,':p_pay_group',p_pay_group);
      END IF;

      IF p_vendor_id IS NOT NULL THEN
         dbms_sql.bind_variable(cursor_id,':p_vendor_id',p_vendor_id);
      END IF;

      IF p_invoice_type IS NOT NULL THEN
         dbms_sql.bind_variable(cursor_id,':p_invoice_type',p_invoice_type);
      END IF;

      IF p_invoice_id IS NOT NULL THEN
         dbms_sql.bind_variable(cursor_id,':p_invoice_id',p_invoice_id);
      END IF;

      IF p_start_date IS NOT NULL THEN
         dbms_sql.bind_variable(cursor_id,':p_start_date',p_start_date);
      END IF;

      IF p_end_date IS NOT NULL THEN
         dbms_sql.bind_variable(cursor_id,':p_end_date',p_end_date);
      END IF;

      -- Define the output variable
      dbms_sql.define_column(cursor_id,1,l_language,4);

      -- Execute the query
      dummy := dbms_sql.execute(cursor_id);

      -- Create string of languages to be returned
      LOOP

         IF dbms_sql.fetch_rows(cursor_id) = 0 THEN
            EXIT;
         END IF;
         dbms_sql.column_value( cursor_id, 1, l_language );

         IF (lang_str IS NULL) THEN
             lang_str := l_language;
         ELSE
             lang_str := lang_str||','||l_language;
         END IF;
      END LOOP;

      dbms_sql.close_cursor(cursor_id);

      RETURN(lang_str);

   END APXINPRT;
---------------------------------------------------------------
 --MLS function for "Supplier Open Balance Report"
-------------------------------------------------------------
   FUNCTION APXSOBLX RETURN VARCHAR2 IS

     P_vendor_name_from po_vendors.vendor_name%TYPE;
     p_vendor_name_to po_vendors.vendor_name%TYPE;
     cursor_id		INTEGER;
     selectstmt 	VARCHAR2(1500);
     lang_str 		VARCHAR2(500) := NULL;
     l_language	VARCHAR2(4);
     dummy		INTEGER;
     retval             INTEGER;
     parm_number        NUMBER;
   BEGIN
   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Supplier Name From',parm_number);
   if retval = -1 then
      P_VENDOR_NAME_FROM := NULL;
   else
     P_VENDOR_NAME_FROM := FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   end if;
   retval := FND_REQUEST_INFO.GET_PARAM_NUMBER('Supplier Name To',parm_number);
   if retval = -1 then
      P_VENDOR_NAME_TO := NULL;
   else
     P_VENDOR_NAME_TO := FND_REQUEST_INFO.GET_PARAMETER(parm_number);
   end if;

   -- Create a query string to get languages based on the parameters
      selectstmt := 'SELECT DISTINCT(NVL(lang.language_code, base.language_code))'||
                    ' FROM   po_vendors pvd,'					  ||
                    '        po_vendor_sites pvs,'				  ||
                    '        ap_invoices ai,'					  ||
                    '        fnd_languages base,'                                 ||
                    '        fnd_languages lang'                                  ||
                    ' WHERE  ai.vendor_id = pvd.vendor_id'			  ||
                    ' AND    pvd.vendor_id = pvs.vendor_id'			  ||
                    ' AND    ai.vendor_site_id  = pvs.vendor_site_id'		  ||
                    ' AND    base.installed_flag = ''B'' '			  ||
                    ' AND    lang.nls_language (+) = pvs.language'                ||
                    ' AND    pvd.vendor_name between nvl(:p_vendor_name_from,''A'') and nvl(:p_vendor_name_to,''Z'')';

     -- add to where clause if other parameters are specified
     -- Open the cursor for processing
      cursor_id := dbms_sql.open_cursor;

      -- Parse the query
         dbms_sql.parse(cursor_id, selectstmt, dbms_sql.v7);
         DBMS_SQL.BIND_VARIABLE(cursor_id,':p_vendor_name_from',P_VENDOR_NAME_FROM);
         DBMS_SQL.BIND_VARIABLE(cursor_id,':p_vendor_name_to',P_VENDOR_NAME_TO);
      -- Bind input variables

      -- Define the output variable
      dbms_sql.define_column(cursor_id,1,l_language,4);

      -- Execute the query
      dummy := dbms_sql.execute(cursor_id);

      -- Create string of languages to be returned
      LOOP

         IF dbms_sql.fetch_rows(cursor_id) = 0 THEN
            EXIT;
         END IF;
         dbms_sql.column_value( cursor_id, 1, l_language );

         IF (lang_str IS NULL) THEN
             lang_str := l_language;
         ELSE
             lang_str := lang_str||','||l_language;
         END IF;
      END LOOP;

      dbms_sql.close_cursor(cursor_id);

      RETURN(lang_str);

   END APXSOBLX;
END AP_REPORTS_MLS_LANG;

/
