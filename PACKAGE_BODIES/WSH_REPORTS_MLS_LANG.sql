--------------------------------------------------------
--  DDL for Package Body WSH_REPORTS_MLS_LANG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_REPORTS_MLS_LANG" AS
/* $Header: WSHLANGB.pls 115.6 99/07/16 08:19:11 porting sh $ */

   FUNCTION GET_LANG RETURN VARCHAR2 IS
      l_CursorID		INTEGER;
      v_SelectStmt 		VARCHAR2(800);
      v_departure_id		NUMBER;
      v_departure_date_lo	DATE;
      v_departure_date_hi	DATE;
      v_freight_carrier		VARCHAR2(25);
      v_delivery_id   		NUMBER;
      v_warehouse_id		NUMBER;
      l_lang			VARCHAR2(30);
      l_base_lang		VARCHAR2(30);
      l_dummy			INTEGER;
      l_lang_str		VARCHAR2(500);
   BEGIN
      -- The external docs have parameters which are in the same positions
      -- Therefore, fnd_request_info.get_parameter is used to get the parameter
      -- values based on positions without using IF statements to check for
      -- the program short name first
      v_departure_id := to_number(FND_REQUEST_INFO.GET_PARAMETER(1));
      v_departure_date_lo := FND_DATE.CANONICAL_TO_DATE(FND_REQUEST_INFO.GET_PARAMETER(2));
      v_departure_date_hi := FND_DATE.CANONICAL_TO_DATE(FND_REQUEST_INFO.GET_PARAMETER(3));
      v_freight_carrier := FND_REQUEST_INFO.GET_PARAMETER(4);
      v_delivery_id := to_number(FND_REQUEST_INFO.GET_PARAMETER(5));
      v_warehouse_id := to_number(FND_REQUEST_INFO.GET_PARAMETER(8));

      -- Get base language
      SELECT language_code INTO l_base_lang FROM fnd_languages
      WHERE installed_flag = 'B';

      -- Create a query string to get languages based on the parameters
      v_SelectStmt := 'SELECT DISTINCT a.language
         FROM ra_addresses a,
            wsh_departures dp,
            wsh_deliveries dl,
            ra_site_uses_all su
         WHERE a.address_id = su.address_id
            AND su.site_use_id = dl.ultimate_ship_to_id
            AND dl.actual_departure_id = dp.departure_id
            AND dp.status_code = ''CL''
            AND dp.organization_id = :v_warehouse_id';

      -- add to where clause if other parameters are specified
      IF v_departure_id IS NOT NULL THEN
         v_SelectStmt := v_SelectStmt||' AND dp.departure_id = :v_departure_id';
      END IF;

      IF v_delivery_id IS NOT NULL THEN
         v_SelectStmt := v_SelectStmt||' AND dl.delivery_id = :v_delivery_id';
      END IF;

      IF v_freight_carrier IS NOT NULL THEN
         v_SelectStmt := v_SelectStmt||' AND dp.freight_carrier_code = :v_freight_carrier';
      END IF;

      IF v_departure_date_lo IS NOT NULL OR v_departure_date_hi IS NOT NULL
      THEN
         IF v_departure_date_lo IS NULL THEN
            v_SelectStmt := v_SelectStmt||' AND trunc(dp.actual_departure_date) <= :v_departure_date_hi';
         ELSIF v_departure_date_hi IS NULL THEN
            v_SelectStmt := v_SelectStmt||' AND trunc(dp.actual_departure_date) >= :v_departure_date_lo';
         ELSE
            v_SelectStmt := v_SelectStmt||' AND trunc(dp.actual_departure_date) BETWEEN :v_departure_date_lo AND :v_departure_date_hi';
         END IF;
      END IF;

      -- Open the cursor for processing
      l_CursorID := DBMS_SQL.OPEN_CURSOR;

      -- Parse the query
      DBMS_SQL.PARSE(l_CursorID, v_SelectStmt, DBMS_SQL.V7);

      -- Bind input variables
      DBMS_SQL.BIND_VARIABLE(l_CursorID,':v_warehouse_id',v_warehouse_id);
      IF v_departure_id IS NOT NULL THEN
         DBMS_SQL.BIND_VARIABLE(l_CursorID,':v_departure_id',v_departure_id);
      END IF;
      IF v_departure_date_lo IS NOT NULL THEN
         DBMS_SQL.BIND_VARIABLE(l_CursorID,':v_departure_date_lo',v_departure_date_lo);
      END IF;
      IF v_departure_date_hi IS NOT NULL THEN
         DBMS_SQL.BIND_VARIABLE(l_CursorID,':v_departure_date_hi',v_departure_date_hi);
      END IF;
      IF v_freight_carrier IS NOT NULL THEN
         DBMS_SQL.BIND_VARIABLE(l_CursorID,':v_freight_carrier',v_freight_carrier);
      END IF;
      IF v_delivery_id IS NOT NULL THEN
         DBMS_SQL.BIND_VARIABLE(l_CursorID,':v_delivery_id',v_delivery_id);
      END IF;

      -- Define the output variable
      DBMS_SQL.DEFINE_COLUMN(l_CursorID,1,l_lang,30);

      -- Execute the query
      l_dummy := DBMS_SQL.EXECUTE(l_CursorID);

      -- Create string of languages to be returned
      LOOP
         IF DBMS_SQL.FETCH_ROWS(l_CursorID) = 0 THEN
            EXIT;
         END IF;

         -- Fetch language into variable
         DBMS_SQL.COLUMN_VALUE(l_CursorID,1,l_lang);

         IF (l_lang IS NOT NULL) THEN
            IF (l_lang_str IS NULL) THEN
               l_lang_str := l_lang;
            ELSE
               l_lang_str := l_lang_str||','||l_lang;
            END IF;
         ELSE
            IF (l_lang_str IS NULL) THEN
               -- Use base language if none is specified
               l_lang_str := l_base_lang;
            ELSE
               -- Make sure base language is not already in string
               IF instr(l_lang_str,l_base_lang) = 0 THEN
                  l_lang_str := l_lang_str||','||l_base_lang;
               END IF;
            END IF;
         END IF;
      END LOOP;

      DBMS_SQL.CLOSE_CURSOR(l_CursorID);

      IF (l_lang_str IS NULL) THEN
         -- Function must not return an empty string
         l_lang_str := l_base_lang;
      END IF;

      RETURN (l_lang_str);

   EXCEPTION
      WHEN OTHERS THEN
         DBMS_SQL.CLOSE_CURSOR(l_CursorID);
         RAISE;
   END GET_LANG;
END WSH_REPORTS_MLS_LANG;

/
