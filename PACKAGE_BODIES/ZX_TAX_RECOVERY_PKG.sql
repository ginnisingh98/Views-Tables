--------------------------------------------------------
--  DDL for Package Body ZX_TAX_RECOVERY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TAX_RECOVERY_PKG" AS
/* $Header: zxpotrxrecb.pls 120.2 2005/09/21 23:44:57 hongliu ship $ */
-- PUBLIC FUNCTION
-- Get_Po_Distribution_Rate
--
-- DESCRIPTION
--REM------------------------------------------------------------------------+
-- This function is called when the invoice is matched with the purchase order
-- and the tax_from_po_flag in the ap_system_parameters is 'Y'.
--REM------------------------------------------------------------------------+

debug_info varchar2(100);
debug_loc varchar2(30);

PG_DEBUG varchar2(1);

-- These variables added for bulk collect.

type num_tab is table of number        		index by binary_integer;
type var2000_tab is table of varchar2(2000)	index by binary_integer;
type var255_tab is table of varchar2(255) 	index by binary_integer;
g_delimiter                    			varchar2(1);
g_chart_of_accts                                gl_sets_of_books.chart_of_accounts_id%TYPE;



l_rec_rate_tab 					num_tab;
l_concatenate_segment_low_tab			var2000_tab;
l_concatenate_segment_high_tab			var2000_tab;
l_procedure_tab 				var255_tab;


-- PROCEDURE initialize;

FUNCTION Get_Po_Distribution_Rate (p_distribution_id IN
                                     po_distributions_all.po_distribution_id%TYPE
                                     ) RETURN NUMBER IS

  l_rec_rate po_distributions_all.recovery_rate%TYPE;
  --l_curr_calling_sequence VARCHAR2(2000);

  CURSOR c_recovery_rate IS
                SELECT pod.recovery_rate
                FROM po_distributions_all pod
                WHERE pod.po_distribution_id = p_distribution_id;
  BEGIN
--REM-------------------DEBUG INFORMATION------------------------------------+



                debug_loc := 'Get_Po_Distribution_Rate';
                --AP_LOGGING_PKG.AP_Begin_Block(debug_loc);
                debug_info:='Getting PO Distribution Rate';
                --AP_LOGGING_PKG.AP_Log(debug_info,debug_loc);

                OPEN c_recovery_rate;
                FETCH c_recovery_rate INTO l_rec_rate;
                CLOSE c_recovery_rate;
                --AP_LOGGING_PKG.AP_End_Block(debug_loc);
                --AP_LOGGING_PKG.AP_End_Log;

                  return(l_rec_rate);
  EXCEPTION
    WHEN OTHERS THEN

     IF (c_recovery_rate%ISOPEN) THEN
          CLOSE c_recovery_rate;
     END IF;
     RAISE;
  END Get_Po_Distribution_Rate;



------------------------------------------------------------------------
--
-- PUBLIC FUNCTION
--     account_in_range
--
-- PURPOSE
-- This is a new function added to the ap_tax_recovery_pkg in order
-- to fix bugs in the ap_tax_recovery_pkg introduced by bug#897398
-- in form Define Tax Recovery Rules (APXTADRR.fmb).
-- Since fixing bug #897398 will affect the way defaulting recovery
-- rate in funciton get_rule_rate in the ap_tax_recovery_pkg
-- (aptxrecs.pls, aptxrecb.pls), changes should be made accordingly.
--
-- This function is called by get_rule_rate in ap_tax_recovery_pkg.
--
-- ASSUMPTION
-- This solution assumes that the requirements for get_rule_rate are
-- same as the requirements in GBV (U.K localization)
-- The logic of this function is based on JEUKVVLG.get_reclaim_percent.
-- Confirmed with Fiona Purves on June 28, 1999.
--
-- DESCRIPTION
--     This function takes three IN parameters which are concatenated
--     segments string, break up those string into segments, check from
--     right most segment and return 1 if ALL segments in p_passed_concat_segs
--     are between ALL segments in p_db_concat_segs_low and each segment
--     in  p_db_concat_segs_high, return 0 if one segment is not in the range.
--
-- PARAMETERS
--     p_passed_concat_segs             IN VARCHAR2
--     p_db_concat_segs_low             IN VARCHAR2
--     p_db_concat_segs_high            IN VARCHAR2
--
-- RETURN
--     in_range                         NUMBER
--
-- HISTORY
--     Wei Feng                     30-JUNE-99  Created
--
--     Wei Feng                     30-Sept-99  Fixed bug 961973
--
--     Null segements in the account low will be replaced by an enterable
--     character with lowest ASCII value ('!'), null segements in the
--     account  high will be  replaced by an enterable character with
--     highest  ASCII  value ('~').
--
--------------------------------------------------------------------------

FUNCTION account_in_range
  (p_passed_concat_segs   IN VARCHAR2,
   p_db_concat_segs_low   IN VARCHAR2,
   p_db_concat_segs_high  IN VARCHAR2,
   p_chart_of_accts	  IN VARCHAR2) return NUMBER IS


l_nsegs                        number;
l_passed_segs_array            fnd_flex_ext.SegmentArray;
l_db_segs_array_low            fnd_flex_ext.SegmentArray;
l_db_segs_array_high           fnd_flex_ext.SegmentArray;
i                              number;
-- 1 stands for account in the range, 0 stands for account NOT in range.
in_range                       number := 1;

BEGIN



   --------------------DEBUG INFORMATION------------------------------------
   debug_loc := 'account_in_range';
   --AP_LOGGING_PKG.AP_Begin_Block(debug_loc);
   debug_info:='Check if the passing account is in the range.';
   --AP_LOGGING_PKG.AP_Log(debug_info,debug_loc);

   -- Bugfix 1798261
   --AP_LOGGING_PKG.AP_End_Block(debug_loc);
   --AP_LOGGING_PKG.AP_End_Log;


   -- Call fnd_flex_ext.breakup_segments to break up segments
   l_nsegs := fnd_flex_ext.breakup_segments
                  (concatenated_segs      => p_passed_concat_segs,
                   delimiter              => g_delimiter,
                   segments               => l_passed_segs_array);



   -- Check if l_nsegs = 0 or p_passed_concat_segs is null.
   -- Then we assume that the passed account IS NOT in range, and do not
   -- need to check any furthure.
   IF l_nsegs = 0 or p_passed_concat_segs is null THEN
        in_range := 0;


        END IF;
        RETURN in_range;


   l_nsegs := fnd_flex_ext.breakup_segments
                  (concatenated_segs      => p_db_concat_segs_low,
                   delimiter              => g_delimiter,
                   segments               => l_db_segs_array_low);

   l_nsegs := fnd_flex_ext.breakup_segments
                  (concatenated_segs      => p_db_concat_segs_high,
                   delimiter              => g_delimiter,
                   segments               => l_db_segs_array_high);



   -- Check if every segment in the passed in account is in the range of every segment in
   -- db account low and high,
   -- Return 1 if all segements are in the range, return 0 if any one segment
   -- is not in the range.

   FOR i in REVERSE 1 .. l_nsegs LOOP

      --IF all l_passed_segs_array(i)  BETWEEN NVL(l_db_segs_array_low(i), '!') AND
      --NVL(l_db_segs_array_high(i), '~')  is not true
      -- in another words is that IF any one segement in the passed account is NOT in the range
      --
      -- THEN this passed account IS NOT in the range
      -- in_range := 0;
      --
      -- Please refer to the logic in JEUKVVLG.get_reclaim_percent.

      IF l_passed_segs_array(i)  NOT BETWEEN NVL(l_db_segs_array_low(i), '!') AND
                                                 NVL(l_db_segs_array_high(i), '~') THEN
         --This segment IS NOT in the range and this account IS NOT in range
         in_range := 0;
      END IF;

   END LOOP;


   RETURN in_range;

EXCEPTION
   WHEN OTHERS THEN

       RAISE;
END account_in_range;



------------------------------------------------------------------------
--
-- PUBLIC FUNCTION
--     account_overlap
--
-- PURPOSE
-- This is a new function added to fix bug#897398
--
-- This function is called by procedure rec_rates.check_overlapping
-- in APXTADRR.fmb.
--
-- ASSUMPTION
-- This solution assumes that the requirements for this form are
-- same as the requirements in GBV (U.K localization)
-- The logic of this function is based on GBV solution.
-- Confirmed with Fiona Purves on June 28, 1999.
--
-- DESCRIPTION
--     This function takes four IN parameters
--    (p_form_concat_segs_low           (FRML)
--     p_form_concat_segs_high          (FRMH)
--     p_db_concat_segs_low             (DBL)
--     p_db_concat_segs_high            (DBH)
--    )
--     which are concatenated segments string, break up those string into segments,
--     check from right most segment, (assume the accounts have 4 segments)
--
--     IF DBL(4) <= FRMH(4) AND
--        DBH(4) >= FRML(4) AND
--        DBL(3) <= FRMH(3) AND
--        DBH(3) >= FRML(3) AND
--        DBL(2) <= FRMH(2) AND
--        DBH(2) >= FRML(2) AND
--        DBL(1) <= FRMH(1) AND
--        DBH(1) >= FRML(1)
--        (ALL the above conditions are true) THEN
--        account IS overlapping, return 1;
--
--     ELSE
--        for ANY of the above condition IS NOT true
--        account IS NOT overlapping, return 0;
--     END IF;
--
--
-- PARAMETERS
--     p_form_concat_segs_low           IN VARCHAR2
--     p_form_concat_segs_high          IN VARCHAR2
--     p_db_concat_segs_low             IN VARCHAR2
--     p_db_concat_segs_high            IN VARCHAR2
--
-- RETURN
--     account_overlap                  NUMBER
--
-- EXAMPLES
--
--1. Example for account NOT overlapping:
--
--                       FROM (LOW)                 TO (HIGH)
--Account Range #1: 01-110-7740-0000-000      01-840-7740-0000-000 (saved in database)
--Account Range #2: 01-110-7710-0000-000      01-840-7710-0000-000 (just entered in form not commit yet)
--
--
--2. Example for account overlapping:
--
--                       FROM (LOW)                 TO (HIGH)
--Account Range #1: 01-000-1000-0000-000       01-000-1500-0000-000 (saved in database)
--Account Range #2: 01-000-1200-0000-000       01-000-1900-0000-200 (just entered in form not commit yet)
--
--
--
-- HISTORY
--     Wei Feng                     30-JUNE-99  Created
--
--     Wei Feng                     30-Sept-99  Fixed bug 961973
--
--     Null segements in the account low will be replaced by an enterable
--     character with lowest ASCII value ('!'), null segements in the
--     account  high will be  replaced by an enterable character with
--     highest  ASCII  value ('~').
--
--
--
--
--------------------------------------------------------------------------

FUNCTION account_overlap
  (p_form_concat_segs_low   IN VARCHAR2,
   p_form_concat_segs_high  IN VARCHAR2,
   p_db_concat_segs_low     IN VARCHAR2,
   p_db_concat_segs_high    IN VARCHAR2) return NUMBER IS

l_chart_of_accts               gl_sets_of_books.chart_of_accounts_id%TYPE;
l_delimiter                    varchar2(1);
l_nsegs                        number;
l_form_segs_array_low          fnd_flex_ext.SegmentArray;
l_form_segs_array_high         fnd_flex_ext.SegmentArray;
l_db_segs_array_low            fnd_flex_ext.SegmentArray;
l_db_segs_array_high           fnd_flex_ext.SegmentArray;
i                              number;
-- 1 stands for overlapping, 0 stands for NOT overlapping
account_overlap                number :=1;

BEGIN


   --------------------DEBUG INFORMATION------------------------------------
   debug_loc := 'account_overlap';
   --AP_LOGGING_PKG.AP_Begin_Block(debug_loc);
   debug_info:='Check if the account is overlapping.';
   --AP_LOGGING_PKG.AP_Log(debug_info,debug_loc);

   -- Get chart_of_account_id

   SELECT chart_of_accounts_id
   INTO l_chart_of_accts
   FROM gl_sets_of_books,ap_system_parameters_all
   WHERE gl_sets_of_books.set_of_books_id = ap_system_parameters_all.set_of_books_id;


   -- Call fnd_flex_ext.get_delimiter to get delimiter


   l_delimiter := fnd_flex_ext.get_delimiter
                  (application_short_name => 'SQLGL',
                   key_flex_code          => 'GL#',
                   structure_number       => l_chart_of_accts);


   -- Call fnd_flex_ext.breakup_segments to break up segments


   l_nsegs := fnd_flex_ext.breakup_segments
                  (concatenated_segs      => p_form_concat_segs_low,
                   delimiter              => l_delimiter,
                   segments               => l_form_segs_array_low);


   l_nsegs := fnd_flex_ext.breakup_segments
                  (concatenated_segs      => p_form_concat_segs_high,
                   delimiter              => l_delimiter,
                   segments               => l_form_segs_array_high);




   l_nsegs := fnd_flex_ext.breakup_segments
                  (concatenated_segs      => p_db_concat_segs_low,
                   delimiter              => l_delimiter,
                   segments               => l_db_segs_array_low);


   l_nsegs := fnd_flex_ext.breakup_segments
                  (concatenated_segs      => p_db_concat_segs_high,
                   delimiter              => l_delimiter,
                   segments               => l_db_segs_array_high);



   -- Check if account is overlapping,
   -- Return 1 if yes, return 0 if no.
   -- The logic is based on the GBV solution.

   FOR i in REVERSE 1 .. l_nsegs LOOP

      --IF any NVL(l_db_segs_array_low(i), '!') <= NVL(l_form_segs_array_high(i), '~') AND
         --NVL(l_db_segs_array_high(i), '~') >= NVL(l_form_segs_array_low(i), '!')
         --when looping IS NOT TRUE (which is the following case) THEN
         --This IS NOT overlapping

      IF  NVL(l_db_segs_array_low(i), '!') > NVL(l_form_segs_array_high(i), '~') OR
          NVL(l_db_segs_array_high(i), '~') < NVL(l_form_segs_array_low(i), '!') THEN

         --This IS NOT overlapping (Please refer to GBV solution for rational)
         account_overlap := 0;
      END IF;

   END LOOP;



   --AP_LOGGING_PKG.AP_End_Block(debug_loc);
   --AP_LOGGING_PKG.AP_End_Log;

   RETURN account_overlap;

EXCEPTION
   WHEN OTHERS THEN


      RAISE;
END account_overlap;



--REM    ----------------------------------------------------------------------+
--REM    This function is called when the tax code has a rule
--REM    associated with it.
--REM    It can be called by Payables or Purchasing.The function returns the
--REM    recovery rate based on the following parameters : p_code_combination_id
--REM    p_tax_date(document date) and p_vendor_id.
--REM    Bug Fix 1137973 : Changed by Debasis on 06-Jan-2000 .
--REM    For uniform naming convention l_rule parameter IN changed to " p_rule"
--REM   ----------------------------------------------------------------------+
  FUNCTION Get_Rule_Rate (p_rule IN NUMBER,
                          p_tax_date IN DATE default SYSDATE,
			  p_vendorclass in po_vendors.vendor_type_lookup_code%TYPE,
			  p_concatenate in VARCHAR2) RETURN NUMBER IS

  l_rec_rate ap_tax_recvry_rates_all.recovery_rate%TYPE;
  l_procedure ap_tax_recvry_rates_all.function%TYPE;
  p_rate NUMBER;
  return_val NUMBER;
  cid NUMBER;
  sql_string varchar2(255);
 -- l_curr_calling_sequence varchar2(2000);
 l_concatenated_segment_low	ap_tax_recvry_rates_all.concatenated_segment_low%type;
 l_concatenated_segment_high	ap_tax_recvry_rates_all.concatenated_segment_high%type;


--REM--To get the Recovery Rate if the start and end dates are specified
-- BUG 2576240 Replace Sysdate with p_tax_date to allow comparison to succeed

  CURSOR c_recovery_rate_cond_null IS
                SELECT tr.recovery_rate,tr.function,
		tr.concatenated_segment_low,tr.concatenated_segment_high
                FROM ap_tax_recvry_rates_all tr
	        WHERE tr.rule_id = p_rule
                AND p_tax_date BETWEEN tr.start_date AND nvl(tr.end_date,p_tax_date+ 1)
                AND tr.enabled_flag = 'Y'
		AND tr.condition_value IS NULL;


  CURSOR c_recovery_rate_cond_notnull IS
                SELECT tr.recovery_rate,tr.function,
		tr.concatenated_segment_low,tr.concatenated_segment_high
                FROM ap_tax_recvry_rates_all tr
	        WHERE tr.rule_id = p_rule
                AND p_tax_date BETWEEN tr.start_date AND nvl(tr.end_date,p_tax_date+ 1)
                AND tr.enabled_flag = 'Y'
		AND tr.condition_value = p_vendorclass;


  BEGIN
--REM -----------------------DEBUG INFORMATION--------------------------------+


                debug_loc := 'Get_Rule_Rate';
                --AP_LOGGING_PKG.AP_Begin_Block(debug_loc);
                debug_info:='Getting Tax Rule Rate';
                --AP_LOGGING_PKG.AP_Log(debug_info,debug_loc);

   IF p_concatenate IS NULL THEN
	l_rec_rate := 0;

        return(l_rec_rate);
   END IF;


		OPEN c_recovery_rate_cond_notnull;

                <<outer>>
                LOOP
		  FETCH c_recovery_rate_cond_notnull Bulk collect into
			l_rec_rate_tab,
			l_procedure_tab,
			l_concatenate_segment_low_tab,
			l_concatenate_segment_high_tab
  		  LIMIT	1000;

		  FOR	i in 1..l_rec_rate_tab.count LOOP

		    If account_in_range(p_concatenate,l_concatenate_segment_low_tab(i),l_concatenate_segment_high_tab(i),g_chart_of_accts) <> 0  then
					l_rec_rate := l_rec_rate_tab(i);
					l_procedure := l_procedure_tab(i);
					exit outer;
		    End If;

		    l_rec_rate := Null;
		    l_procedure := NUll;

		  END LOOP;
                  EXIT WHEN c_recovery_rate_cond_notnull%NOTFOUND;
		END LOOP;

		CLOSE c_recovery_rate_cond_notnull;

		if l_rec_rate is null then
		  OPEN c_recovery_rate_cond_null;

                  <<outer1>>
                  LOOP
		    FETCH c_recovery_rate_cond_null Bulk collect into
			  l_rec_rate_tab,
			  l_procedure_tab,
			  l_concatenate_segment_low_tab,
			  l_concatenate_segment_high_tab
		    LIMIT	1000;

		    FOR i in 1..l_rec_rate_tab.count LOOP
		      If  account_in_range(p_concatenate,l_concatenate_segment_low_TAB(I),l_concatenate_segment_high_TAB(I),g_chart_of_accts) <> 0 then
				l_rec_rate := l_rec_rate_tab(i);
				l_procedure := l_procedure_tab(i);
				exit outer1;
		      End If;
		      l_rec_rate := Null;
		      l_procedure := NUll;
		    END LOOP;

                    EXIT WHEN c_recovery_rate_cond_null%NOTFOUND;

                  END LOOP;

		  CLOSE c_recovery_rate_cond_null;

		end if;

--REM -----------------------------------------------------------------------+
--REM If function column in the table ap_tax_recvry_rates is not null then call
--REM the User Defined Procedure that takes no parameters and writes all the
--REM calculated values to the Global area G_tax_info_rec in AP_TAX_ENGINE_PKG
--REM ------------------------------------------------------------------------+
                if l_procedure IS NOT NULL then
--REM -----------------------------------------------------------------------+
--        Prepare for the Dynamic SQL
--REM ------------------------------------------------------------------------+


                begin
  --Used Native Dynamic SQL 1064036

                sql_string := 'begin '||l_procedure||'; end;';

                EXECUTE IMMEDIATE sql_string ;



                exception
                when others then


                raise;
                end ;
--REM -----------------------------------------------------------------------+
--REM  Get the tax_recovery_rate from the G_tax_info_rec that was populated
--REM  by the user Defined Procedure
--REM------------------------------------------------------------------------+
                p_rate := AP_TAX_ENGINE_PKG.G_tax_info_rec.tax_recovery_rate;
                --AP_LOGGING_PKG.AP_End_Block(debug_loc);
                --AP_LOGGING_PKG.AP_End_Log;

                return (p_rate);
                else
--REM ----------------------------------------------------------------------+
-- Return the recovery_rate if the function was not available in the
-- ap_tax_recvry_rates table
--REM ----------------------------------------------------------------------+

                return(l_rec_rate);
                end if;
EXCEPTION
  WHEN OTHERS THEN

   IF (c_recovery_rate_cond_null%ISOPEN) THEN
         CLOSE c_recovery_rate_cond_null;
   ELSIF (c_recovery_rate_cond_notnull%ISOPEN) THEN
         CLOSE c_recovery_rate_cond_notnull;
   END IF;
    RAISE;
  END Get_Rule_Rate;


-- PUBLIC PROCEDURE
-- Get_Default_Rate
-- DESCRIPTION
--
-- The procedure is passed a variety of parameters to get
-- the default rate that is to be used by Payables and Purchasing.
--
-- PARAMETERS
-- p_tax_code                  IN
-- p_tax_id                    IN
-- p_tax_date                  IN
-- p_code_combination_id       IN
-- p_vendor_id                 IN
-- p_distribution_id           IN
-- p_tax_user_override_flag    IN
-- If the override_flag is 'Y' the user_defined recovery rate is returned.
-- p_user_tax_recovery_rate    IN
-- p_concatenated_segments     IN
-- p_vendor_site_id            IN
-- p_inventory_item_id         IN
-- p_item_org_id               IN
-- APPL_SHORT_NAME             IN
-- FUNC_SHORT_NAME             IN
-- p_calling_sequence          IN
-- p_tax_recovery_rate         IN OUT NOCOPY

/* Get_Default_Rate */
PROCEDURE Get_Default_Rate (p_tax_code IN ap_tax_codes_all.name%TYPE,
p_tax_id                    IN        ap_tax_codes_all.tax_id%TYPE,
p_tax_date                  IN        DATE default SYSDATE,
p_code_combination_id       IN        gl_code_combinations.code_combination_id%TYPE,
p_vendor_id                 IN        po_vendors.vendor_id%TYPE,
p_distribution_id           IN        po_distributions_all.po_distribution_id%TYPE,
p_tax_user_override_flag    IN        VARCHAR2,
p_user_tax_recovery_rate    IN        ap_tax_codes_all.tax_rate%TYPE,
p_concatenated_segments     IN        VARCHAR2,
p_vendor_site_id            IN        po_vendor_sites_all.vendor_site_id%TYPE,
p_inventory_item_id         IN        mtl_system_items.inventory_item_id%TYPE,
p_item_org_id               IN        mtl_system_items.organization_id%TYPE,
APPL_SHORT_NAME             IN        fnd_application.application_short_name%TYPE,
FUNC_SHORT_NAME             IN        VARCHAR2 default 'NONE',
p_calling_sequence          IN        VARCHAR2,
p_chart_of_accounts_id      IN        gl_ledgers.chart_of_accounts_id%TYPE,
p_tc_tax_recovery_rule_id   IN        ap_tax_codes_all.tax_recovery_rule_id%TYPE,
p_tc_tax_recovery_rate      IN        ap_tax_codes_all.tax_recovery_rate%TYPE,
p_vendor_type_lookup_code   IN        po_vendors.vendor_type_lookup_code%TYPE,
p_tax_recovery_rate         IN OUT NOCOPY    number) AS


l_curr_calling_sequence VARCHAR2(2000);
l_rule_id ap_tax_codes_all.tax_recovery_rule_id%TYPE;
 l_tax_rate ap_tax_codes_all.tax_recovery_rate%TYPE;
-- TYPE get_rec_rate_tbl1 IS TABLE OF PO_DISTRIBUTIONS_ALL.RECOVERY_RATE%TYPE INDEX BY BINARY_INTEGER;
-- l_tax_rate         get_rec_rate_tbl1;
-- l_tax_rate get_rec_rate_tbl;
i number;
l_rec_rate  NUMBER;
l_tax_code_id NUMBER ;
-- == l_non_rec_tax_flag financials_system_params_all.non_recoverable_tax_flag%TYPE;
-- == l_tax_from_po_flag ap_system_parameters_all.tax_from_po_flag%TYPE;
l_tax_rule_rate ap_tax_recvry_rates_all.recovery_rate%TYPE;
lp_concatenate  varchar2(2000);
l_cond_val  po_vendors.vendor_type_lookup_code%TYPE;
l_tax_type  ap_tax_codes_all.tax_type%type;
l_get_rule_rate NUMBER;
-- == l_match_on_tax_flag ap_system_parameters_all.match_on_tax_flag%type;--added for bug 3960162.

--REM
--REM-----------------------------------------------------------------------+
--REM To get the Tax code from PO
--REM-----------------------------------------------------------------------+
--REM
/* ==
  CURSOR c_tax_code_id IS
                 SELECT pll.tax_code_id
                 from   po_line_locations_all pll,
                        po_distributions_all po
                 where pll.line_location_id = po.line_location_id and
                       po.po_distribution_id = p_distribution_id;

== */

--REM-----------------------------------------------------------------------+
--REM  To get the rule_id and rate based on the tax name and document date
--REM ----------------------------------------------------------------------+
/* ==
  --Fixed bug 1036684, removed nvl from cursor.
  CURSOR c_rule_rate_cd IS
                SELECT tc.tax_recovery_rule_id, tc.tax_recovery_rate
                FROM ap_tax_codes_all tc
                WHERE tc.name = p_tax_code
                   AND p_tax_date BETWEEN tc.start_date
                AND nvl(tc.inactive_date,p_tax_date)
                AND tc.enabled_flag='Y' ;
== */

--Fixed bug 1811026 changed sysdate +1 to p_tax_date
--REM ----------------------------------------------------------------------+
--REM  To get the rule_id and rate based on the tax_id
--REM ----------------------------------------------------------------------+
/* ==
  --Fixed bug 1036684, removed nvl from cursor.
  CURSOR c_rule_rate_id IS
                SELECT tc.tax_recovery_rule_id,tc.tax_recovery_rate
                FROM ap_tax_codes_all tc
                WHERE tc.tax_id = p_tax_id
                         AND tc.enabled_flag='Y';
-- Bug1094321 fix , added Condition value for the vendor
 CURSOR c_cond_val IS
                SELECT vendor_type_lookup_code
                FROM po_vendors
                WHERE po_vendors.vendor_id = p_vendor_id;

 == */

/*created the cursor for bug 3960162 to fetch the match_on_tax_flag to default
  the recovery rate when PO matched with invoice.*/
/* ==
 CURSOR c_get_match_on_tax_flag IS
                SELECT match_on_tax_flag
                FROM ap_system_parameters_all;
--end for 3960162
== */

-- Bug Fix for 1003548 and Bug fix 1094321
-- To get the recovery rate for a rule within an account range for Bug 1003548
-- Added the conditon_value to the query for Bug 1094321
/* ==
  CURSOR c_get_fin_param IS
                SELECT non_recoverable_tax_flag
                FROM FINANCIALS_SYSTEM_PARAMS_ALL;
== */

/* ==
  CURSOR c_get_ap_system_parameter IS
                SELECT tax_from_po_flag
                FROM ap_system_parameters_all;
== */

  /* Bugfix 1161905 */

/* ==
  CURSOR c_tax_type is
               SELECT tax_type
               FROM ap_tax_codes_all
               WHERE tax_id = p_tax_id;

  CURSOR c_tax_type_csr is
               SELECT tax_type
               FROM ap_tax_codes_all
               WHERE tax_id in (SELECT
                     tax_id
                     FROM ap_tax_codes_all
                     WHERE
                     name = p_tax_code and
                     p_tax_date between start_date and
                     inactive_date and enabled_flag = 'Y');
== */

 BEGIN

  -- initialize;
   g_chart_of_accts := p_chart_of_accounts_id;

   -- Call fnd_flex_ext.get_delimiter to get delimiter

   g_delimiter := fnd_flex_ext.get_delimiter
                  (application_short_name => 'SQLGL',
                   key_flex_code          => 'GL#',
                   structure_number       => g_chart_of_accts);

                --AP_LOGGING_PKG.AP_Begin_Log('AP_TAX_RECOVERY_PKG',2000);
--REM -------------------DEBUG INFORMATION------------------------------------+
                debug_loc:= 'Get_Default_Rate';
                --AP_LOGGING_PKG.AP_Begin_Block(debug_loc);
                l_curr_calling_sequence := 'AP_TAX_RECOVERY_PKG.'||debug_loc||'<-'||p_calling_sequence;
                debug_info := 'Getting default tax rate';
/* ==
                --AP_LOGGING_PKG.AP_Log(debug_info,debug_loc);
                OPEN c_get_fin_param;
                FETCH c_get_fin_param INTO l_non_rec_tax_flag;
                CLOSE c_get_fin_param;
== */
/* ==
                OPEN c_get_ap_system_parameter;
                FETCH c_get_ap_system_parameter INTO l_tax_from_po_flag;
                CLOSE c_get_ap_system_parameter;
== */
/* ==
                OPEN c_cond_val;
                FETCH c_cond_val into l_cond_val;
                CLOSE c_cond_val;
==*/
                l_cond_val := p_vendor_type_lookup_code;

/* ==
 	          OPEN c_get_match_on_tax_flag;
                FETCH c_get_match_on_tax_flag into l_match_on_tax_flag;
                CLOSE c_get_match_on_tax_flag;
== */

   lp_concatenate := fnd_flex_ext.get_segs
       ('SQLGL','GL#', g_chart_of_accts, p_code_combination_id);

   IF lp_concatenate is null then
	lp_concatenate := p_concatenated_segments;
   END IF;

  IF p_tax_id IS NOT NULL THEN

/* ==                   OPEN c_rule_rate_id;
                   FETCH c_rule_rate_id into l_rule_id,l_tax_rate;
                   CLOSE c_rule_rate_id;
== */
                   l_rule_id := p_tc_tax_recovery_rule_id;
                   l_tax_rate := p_tc_tax_recovery_rate;

                   IF l_rule_id IS NULL THEN
                      p_tax_recovery_rate := l_tax_rate;

                   ELSE
                      l_tax_rule_rate := Get_Rule_Rate(l_rule_id,
                                                         p_tax_date,
                                                         l_cond_val,
						         lp_concatenate);

			p_tax_recovery_rate := l_tax_rule_rate;

                    END IF;

   END IF;

  EXCEPTION
          WHEN NO_DATA_FOUND THEN
             NULL;

  END Get_Default_Rate;

/* ==

PROCEDURE initialize IS
--REM -----------------------------------------------------------------------+
--REM To get the chart_of accounts which is used to get the concatenated segment
--REM -----------------------------------------------------------------------+


  CURSOR c_chart_of_accts IS
                SELECT chart_of_accounts_id
                FROM gl_sets_of_books,ap_system_parameters_all
                WHERE gl_sets_of_books.set_of_books_id = ap_system_parameters_all.set_of_books_id;

BEGIN

--  PG_DEBUG := NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
   PG_DEBUG := 'Y';

   OPEN c_chart_of_accts;
   FETCH c_chart_of_accts INTO g_chart_of_accts;
   CLOSE c_chart_of_accts;

   -- Call fnd_flex_ext.get_delimiter to get delimiter

   g_delimiter := fnd_flex_ext.get_delimiter
                  (application_short_name => 'SQLGL',
                   key_flex_code          => 'GL#',
                   structure_number       => g_chart_of_accts);

END initialize;
== */
-------------------------------------------------------------------------------
--
--   get_system_tax_defaults
--
-------------------------------------------------------------------------------
BEGIN

--   initialize;
  NULL;

END ZX_TAX_RECOVERY_PKG;

/
