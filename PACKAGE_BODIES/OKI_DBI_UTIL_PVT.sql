--------------------------------------------------------
--  DDL for Package Body OKI_DBI_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKI_DBI_UTIL_PVT" AS
/* $Header: OKIRDBIB.pls 120.2 2006/02/06 00:50:15 pubalasu noship $ */

  PROCEDURE populate_mv_bmap (
    p_mv_bmap_tbl		OUT NOCOPY oki_dbi_mv_bmap_tbl
  , p_mv_set			IN	 VARCHAR2);

--  FUNCTION get_where_clauses (
--    p_dim_map		OUT poa_dbi_util_pkg.poa_dbi_dim_map
--  , p_trend			IN	 VARCHAR2)
--    RETURN VARCHAR2;

  PROCEDURE split_pseudo_rs_group (
    p_param			IN	 bis_pmv_page_parameter_tbl);

  FUNCTION current_period_start_date (
    as_of_date			IN	 DATE
  , period_type 		IN	 VARCHAR2)
    RETURN DATE
  IS
    l_date   DATE;
  BEGIN
    IF (period_type = 'YTD')
    THEN
      l_date	:= fii_time_api.ent_cyr_start (as_of_date);
    ELSIF (period_type = 'QTD')
    THEN
      l_date	:= fii_time_api.ent_cqtr_start (as_of_date);
    ELSIF (period_type = 'MTD')
    THEN
      l_date	:= fii_time_api.ent_cper_start (as_of_date);
    ELSIF (period_type = 'WTD')
    THEN
      l_date	:= fii_time_api.cwk_start (as_of_date);
    END IF;

    RETURN l_date;
  EXCEPTION
    WHEN OTHERS
    THEN
      bis_collection_utilities.put_line (SQLERRM || '' || SQLCODE);
      fnd_message.set_name (application    => 'FND'
			  , NAME	   => 'CRM-DEBUG ERROR');
      fnd_message.set_token (token    => 'ROUTINE'
			   , VALUE    => 'OKI_DBI_UTIL_PVT.current_period_start_date ');
      bis_collection_utilities.put_line (fnd_message.get);
      raise_application_error (-20000
			     , 'Stack Dump Follows =>'
			     , TRUE);
  END current_period_start_date;

/******************************************************************************
  Description: Retrieves the current period end date.
******************************************************************************/
  FUNCTION current_period_end_date (
    as_of_date			IN	 DATE
  , period_type 		IN	 VARCHAR2)
    RETURN DATE
  IS
    l_date   DATE;
  BEGIN
    IF (period_type = 'YTD')
    THEN
      l_date	:= fii_time_api.ent_cyr_end (as_of_date);
    ELSIF (period_type = 'QTD')
    THEN
      l_date	:= fii_time_api.ent_cqtr_end (as_of_date);
    ELSIF (period_type = 'MTD')
    THEN
      l_date	:= fii_time_api.ent_cper_end (as_of_date);
    ELSIF (period_type = 'WTD')
    THEN
      l_date	:= fii_time_api.cwk_end (as_of_date);
    END IF;

    RETURN l_date;
  EXCEPTION
    WHEN OTHERS
    THEN
      bis_collection_utilities.put_line (SQLERRM || '' || SQLCODE);
      fnd_message.set_name (application    => 'FND'
			  , NAME	   => 'CRM-DEBUG ERROR');
      fnd_message.set_token (token    => 'ROUTINE'
			   , VALUE    => 'OKI_DBI_UTIL_PVT.current_period_end_date ');
      bis_collection_utilities.put_line (fnd_message.get);
      raise_application_error (-20000
			     , 'Stack Dump Follows =>'
			     , TRUE);
  END current_period_end_date;

  FUNCTION previous_period_start_date (
    as_of_date			IN	 DATE
  , period_type 		IN	 VARCHAR2
  , comparison_type		IN	 VARCHAR2)
    RETURN DATE
  IS
    l_prev_date   DATE;
    l_date	  DATE;
  BEGIN
/* Temporary fix until fii fixes the problem */
    IF (comparison_type = 'S')
    THEN
      IF (period_type = 'YTD')
      THEN
	SELECT fii.start_date
	  INTO l_date
	  FROM fii_time_ent_year fii
	 WHERE (SELECT fii.start_date - 1
		  FROM fii_time_ent_year fii
		 WHERE as_of_date BETWEEN fii.start_date AND fii.end_date) BETWEEN fii.start_date AND fii.end_date;
      ELSE
	IF (period_type = 'QTD')
	THEN
	  SELECT fii.start_date
	    INTO l_date
	    FROM fii_time_ent_qtr fii
	   WHERE (SELECT fii.start_date - 1
		    FROM fii_time_ent_qtr fii
		   WHERE as_of_date BETWEEN fii.start_date AND fii.end_date) BETWEEN fii.start_date AND fii.end_date;
	ELSE
	  SELECT fii.start_date
	    INTO l_date
	    FROM fii_time_ent_period fii
	   WHERE (SELECT fii.start_date - 1
		    FROM fii_time_ent_period fii
		   WHERE as_of_date BETWEEN fii.start_date AND fii.end_date) BETWEEN fii.start_date AND fii.end_date;
	END IF;
      END IF;
    ELSE
      l_prev_date    := previous_period_asof_date (as_of_date
						 , period_type
						 , comparison_type);
      l_date	     := current_period_start_date (l_prev_date
						 , period_type);
    END IF;

    RETURN l_date;
  EXCEPTION
    WHEN OTHERS
    THEN
      RETURN bis_common_parameters.get_global_start_date;
  END previous_period_start_date;

  FUNCTION current_report_start_date (
    as_of_date			IN	 DATE
  , period_type 		IN	 VARCHAR2)
    RETURN DATE
  IS
    l_date		DATE;
    l_curr_year 	NUMBER;
    l_curr_qtr		NUMBER;
    l_curr_period	NUMBER;
    l_week_start_date	DATE;
  BEGIN
    IF (period_type = 'YTD')
    THEN
      SELECT SEQUENCE
	INTO l_curr_year
	FROM fii_time_ent_year
       WHERE as_of_date BETWEEN start_date AND end_date;

      SELECT start_date
	INTO l_date
	FROM fii_time_ent_year
       WHERE SEQUENCE = l_curr_year - 3;
    END IF;

    IF (period_type = 'QTD')
    THEN
      SELECT SEQUENCE
	   , ent_year_id
	INTO l_curr_qtr
	   , l_curr_year
	FROM fii_time_ent_qtr
       WHERE as_of_date BETWEEN start_date AND end_date;

      IF (l_curr_qtr = 4)
      THEN
	l_date	  := fii_time_api.ent_cyr_start (as_of_date);
      ELSE
	SELECT start_date
	  INTO l_date
	  FROM fii_time_ent_qtr
	 WHERE SEQUENCE = l_curr_qtr + 1
	   AND ent_year_id = l_curr_year - 1;
      END IF;
    END IF;

    IF (period_type = 'MTD')
    THEN
      SELECT p.SEQUENCE
	   , q.ent_year_id
	INTO l_curr_period
	   , l_curr_year
	FROM fii_time_ent_period p
	   , fii_time_ent_qtr q
       WHERE p.ent_qtr_id = q.ent_qtr_id
	 AND as_of_date BETWEEN p.start_date AND p.end_date;

      SELECT start_date
	INTO l_date
	FROM (SELECT   p.start_date
		  FROM fii_time_ent_period p
		     , fii_time_ent_qtr q
		 WHERE p.ent_qtr_id = q.ent_qtr_id
		   AND (   (	p.SEQUENCE = l_curr_period + 1
			    AND q.ent_year_id = l_curr_year - 1)
			OR (	p.SEQUENCE = 1
			    AND q.ent_year_id = l_curr_year))
	      ORDER BY p.start_date)
       WHERE ROWNUM <= 1;
/* select p.start_date
   into l_date
   from fii_time_ent_period p, fii_time_ent_qtr q
   where p.ent_qtr_id=q.ent_qtr_id
   and p.sequence=l_curr_period+1  -- temp fix for 12 points on graph else 13 points  brrao modified
   and q.ent_year_id=l_curr_year-1;
*/
    END IF;

    IF (period_type = 'WTD')
    THEN
      SELECT start_date
	INTO l_week_start_date
	FROM fii_time_week
       WHERE as_of_date BETWEEN start_date AND end_date;

      SELECT start_date
	INTO l_date
	FROM fii_time_week
       WHERE start_date = l_week_start_date - 7 * 12;
    END IF;

    RETURN l_date;
  EXCEPTION
    WHEN OTHERS
    THEN
      RETURN bis_common_parameters.get_global_start_date;
  END current_report_start_date;

  FUNCTION previous_report_start_date (
    as_of_date			IN	 DATE
  , period_type 		IN	 VARCHAR2
  , comparison_type		IN	 VARCHAR2)
    RETURN DATE
  IS
    l_prev_date   DATE;
    l_date	  DATE;
  BEGIN
    l_prev_date    := previous_period_asof_date (as_of_date
					       , period_type
					       , comparison_type);
    l_date	   := current_report_start_date (l_prev_date
					       , period_type);
    RETURN l_date;
  EXCEPTION
    WHEN OTHERS
    THEN
      bis_collection_utilities.put_line ('Error in function previous_report_start_date	: ' || SQLERRM || '' || SQLCODE);
      raise_application_error (-20000
			     , 'Stack Dump Follows =>'
			     , TRUE);
  END previous_report_start_date;

  FUNCTION previous_period_asof_date (
    as_of_date			IN	 DATE
  , period_type 		IN	 VARCHAR2
  , comparison_type		IN	 VARCHAR2)
    RETURN DATE
  IS
    l_date   DATE;
  BEGIN
    IF (period_type = 'YTD')
    THEN
      l_date	:= fii_time_api.ent_sd_lyr_end (as_of_date);
    ELSIF (period_type = 'QTD')
    THEN
      IF (comparison_type = 'Y')
      THEN
	l_date	  := fii_time_api.ent_sd_lysqtr_end (as_of_date);
      ELSE
	l_date	  := fii_time_api.ent_sd_pqtr_end (as_of_date);
      END IF;
    ELSIF (period_type = 'MTD')
    THEN
      IF (comparison_type = 'Y')
      THEN
	l_date	  := fii_time_api.ent_sd_lysper_end (as_of_date);
      ELSE
	l_date	  := fii_time_api.ent_sd_pper_end (as_of_date);
      END IF;
    ELSIF (period_type = 'WTD')
    THEN
      IF (comparison_type = 'Y')
      THEN
	l_date	  := fii_time_api.sd_lyswk (as_of_date);
      ELSE
	l_date	  := fii_time_api.sd_pwk (as_of_date);
      END IF;
    END IF;

    RETURN l_date;
  EXCEPTION
    WHEN OTHERS
    THEN
      RETURN bis_common_parameters.get_global_start_date - 1;
		/* making sure it's < current_report_date */

  END previous_period_asof_date;

-- -----------------------------------------------------------------------------
-- get_sec_profile: Get the security profile.
-- -----------------------------------------------------------------------------
  FUNCTION get_sec_profile
    RETURN NUMBER
  IS
    l_sec_profile   NUMBER;
  BEGIN
    l_sec_profile    := NVL (fnd_profile.VALUE ('XLA_MO_SECURITY_PROFILE_LEVEL'), -1);
    RETURN l_sec_profile;
  EXCEPTION
    WHEN OTHERS
    THEN
      bis_collection_utilities.put_line (SQLERRM || '' || SQLCODE);
      fnd_message.set_name (application    => 'FND'
			  , NAME	   => 'CRM-DEBUG ERROR');
      fnd_message.set_token (token    => 'ROUTINE'
			   , VALUE    => 'OKI_DBI_UTIL_PVT.get_sec_profile ');
      bis_collection_utilities.put_line (fnd_message.get);
      raise_application_error (-20000
			     , 'Stack Dump Follows =>'
			     , TRUE);
  END get_sec_profile;

-- ---------------------------------------------
-- get_org_where clause funtion for OU security
-- --------------------------------------------

  FUNCTION get_org_where (
    p_name			IN	 VARCHAR2
  , p_org			IN	 VARCHAR2)
    RETURN VARCHAR2
  IS
    l_org_where   VARCHAR2 (500);
  BEGIN
    IF (p_name = 'ORGANIZATION')
    THEN
      IF (   p_org IS NULL
	  OR p_org = ''
	  OR p_org = 'All')
      THEN
	l_org_where    :=
	  ' AND authoring_org_id IN (
				 SELECT pol.organization_id
			    FROM per_organization_list pol
				 WHERE pol.security_profile_id
	    = &SEC_ID ) ';
      ELSE
	l_org_where    := ' AND authoring_org_id = &ORGANIZATION+FII_OPERATING_UNITS';
      END IF;
    ELSE
      l_org_where    := '';
    END IF;

    RETURN l_org_where;
  EXCEPTION
    WHEN OTHERS
    THEN
      bis_collection_utilities.put_line (SQLERRM || '' || SQLCODE);
      fnd_message.set_name (application    => 'FND'
			  , NAME	   => 'CRM-DEBUG ERROR');
      fnd_message.set_token (token    => 'ROUTINE'
			   , VALUE    => 'OKI_DBI_UTIL_PVT.get_org_where ');
      bis_collection_utilities.put_line (fnd_message.get);
      raise_application_error (-20000
			     , 'Stack Dump Follows =>'
			     , TRUE);
  END get_org_where;

-- -----------------------------------------------------
-- get_nested_cols () clause to get upper sql conditions
-- brrao added
-- -----------------------------------------------------
FUNCTION get_nested_cols (
    p_col_name			IN	 poa_dbi_util_pkg.poa_dbi_col_tbl
    ,period_type		 IN VARCHAR2
    ,P_TREND			 in varchar2 )
    RETURN VARCHAR2 IS

     l_str   VARCHAR2 (10000);
     C_DATE varchar2(100);
     p_date varchar2(100);
  BEGIN

      IF P_TREND = 'Y'  THEN
       p_date := '&BIS_PREVIOUS_REPORT_START_DATE -1';
       c_date := '&BIS_CURRENT_REPORT_START_DATE -1';

       IF period_type in ('ITD','YTD') THEN
         p_date := '&BIS_PREVIOUS_ASOF_DATE';
         c_date := '&BIS_CURRENT_ASOF_DATE ';
       END IF;
/*       IF period_type = 'YTD' THEN
         p_date := '&BIS_PREVIOUS_ASOF_DATE';
         c_date := '&BIS_CURRENT_ASOF_DATE ';
       END IF;
  */
----
     ELSE
       p_date := '&BIS_PREVIOUS_ASOF_DATE';
       c_date := '&BIS_CURRENT_ASOF_DATE ';
     END IF;

    if period_type in ('ITD','YTD')  then
      FOR i IN 1 .. p_col_name.COUNT
      LOOP
	IF (p_col_name(i).to_date_type IN ('ITD','YTD'))
	THEN
	   L_str := l_str ||',SUM(decode(cal.report_date,'|| c_date ||','|| p_col_name(i).column_name||')) c_'|| p_col_name(i).column_alias;

	   IF (p_col_name(i).prior_code <> poa_dbi_util_pkg.no_priors)
	   THEN
	     L_str :=l_str||',SUM(decode(cal.report_date,'|| p_date ||','|| p_col_name(i).column_name||')) p_'|| p_col_name(i).column_alias;

	   END IF;
	ELSE
	  IF(p_trend <> 'Y')
	  THEN
	      L_str := l_str ||',TO_NUMBER(null) c_' || p_col_name(i).column_alias;
	      -- Prev column (based on prior_code)
	      IF (p_col_name(i).prior_code <> poa_dbi_util_pkg.no_priors)
	      THEN
		 L_str := l_str ||',TO_NUMBER(null) P_' || p_col_name(i).column_alias;
	      END IF;
	  END IF;
	END IF;
      END LOOP;
    ELSE    -- if type = XTD for all nested cases
      FOR i IN 1 ..  p_col_name.COUNT
      LOOP
      -- use this only if its not a YTD measure ie only for all xtd measures
      IF ( p_col_name(i).to_date_type <> 'YTD' ) THEN
	  L_str := l_str ||',SUM(decode(cal.report_date,'|| c_date ||','|| p_col_name(i).column_name||',null)) c_'|| p_col_name(i).column_alias

	   || '
	   ';
	  IF (p_col_name(i).grand_total = 'Y')
	   THEN
	     L_str := l_str ||',sum(sum(decode(cal.report_date,'|| c_date ||','|| p_col_name(i).column_name||',null))) over() c_'|| p_col_name(i).column_alias || '_total

	    ';
	  END IF;
	   IF (p_col_name(i).prior_code <> poa_dbi_util_pkg.no_priors)
	   THEN
	      L_str := l_str ||',SUM(decode(cal.report_date,'|| p_date ||','|| p_col_name(i).column_name||',null)) p_'|| p_col_name(i).column_alias

	   || '
	   ';
	      IF (p_col_name(i).grand_total = 'Y')
	      THEN
		 L_str := l_str ||',sum(sum(decode(cal.report_date,'|| p_date ||','|| p_col_name(i).column_name||',null))) over() p_'|| p_col_name(i).column_alias || '_total

		 ';
	      END IF;
	   END IF;
       END IF;
     END LOOP;
  end IF;   -- end if ITD

    return l_str;

END get_nested_cols;

-- ------------------------------------------------
-- get_itd_where clause to get itd where conditions
-- brrao added
-- ------------------------------------------------
  FUNCTION get_itd_where (
    p_mv_name			   IN	    VARCHAR2
  , p_trend		      IN   VARCHAR2 )
    RETURN VARCHAR2 IS
     l_str   VARCHAR2 (500);
     C_DATE varchar2(100);
     p_date varchar2(100);
  BEGIN

/*       IF P_TREND = 'Y'  THEN
--      p_date := '&BIS_PREVIOUS_REPORT_START_DATE -1';
--      c_date := '&BIS_CURRENT_REPORT_START_DATE -1';
--         p_date := '&BIS_PREVIOUS_ASOF_DATE -1';
         c_date := '&BIS_CURRENT_ASOF_DATE -1';

     ELSE
       p_date := '&BIS_PREVIOUS_ASOF_DATE';
       c_date := '&BIS_CURRENT_ASOF_DATE ';
     END IF;
*/
       p_date := '&BIS_PREVIOUS_ASOF_DATE';
       c_date := '&BIS_CURRENT_ASOF_DATE ';

     L_str := ' FROM  '|| P_MV_NAME || ' fact, fii_time_day cal ' ||
	' WHERE 1 = 1 '||
	' AND fact.ent_year_id = cal.ent_year_id '||
	' AND	cal.report_date IN ( '|| c_date ||','||p_date ||')';

 RETURN L_str;
END get_itd_where;

-- ---------------------------------------------------
-- get_xtd_where () clause to get itd where conditions
-- brrao added
-- ---------------------------------------------------
  FUNCTION get_xtd_where (
    p_mv_name			   IN VARCHAR2
  , p_trend		      IN   VARCHAR2
   , p_type		      IN VARCHAR2
   ,p_pattern	  in VARCHAR2 := NULL)
    RETURN VARCHAR2 IS
     l_str   VARCHAR2 (500);
     C_DATE varchar2(100);
     l_patt varchar2(50);
     p_date varchar2(100);
  BEGIN

     IF P_TREND = 'Y'  THEN
       p_date := '&BIS_PREVIOUS_REPORT_START_DATE';
       c_date := '&BIS_CURRENT_REPORT_START_DATE ';
       IF ( p_type = 'YTD'  ) then
          p_date := '&BIS_PREVIOUS_REPORT_START_DATE - 1';
          c_date := '&BIS_CURRENT_REPORT_START_DATE - 1';
       END IF;
     ELSE
       p_date := '&BIS_PREVIOUS_ASOF_DATE';
       c_date := '&BIS_CURRENT_ASOF_DATE ';
     END IF;

     IF (p_pattern is null ) then
       l_patt := '&BIS_NESTED_PATTERN';
     ELSE
       l_patt := p_pattern;
     END IF;
     L_str :=  ' FROM  '|| P_MV_NAME || ' fact, fii_time_rpt_struct_v cal ' ||
	' WHERE 1 = 1 '||
	' AND fact.time_id = cal.time_id  '||
	' AND	cal.report_date IN ( '|| c_date ||','||p_date ||')
	and bitand(cal.record_type_id, '||l_patt || ') = cal.record_type_id';

 RETURN L_str;
END get_xtd_where;

-- --------------------------------------
-- get_dbi_params for as_of_date format
-- ----------------------------------------

  FUNCTION get_dbi_params (
    region_id			IN	 VARCHAR2)
    RETURN VARCHAR2
  IS
    currency   fii_currencies_v.VALUE%TYPE;
  BEGIN
    currency	:= 'FII_GLOBAL1';

    /* '&'||'ORGANIZATION=All';-- ||
      '&'||'SEC_ID=230';
       '&'||'BIS_TIME_COMPARISON_TYPE=SEQUENTIAL'||
       '&'||'&BIS_PERIOD_TYPE = FII_TIME_ENT_PERIOD'
		  ||
       '&'||'VIEW_BY= ALL';

 */

    /* Modified by brrao test for initiailization params */
    IF (region_id = 'OKI_DBI_SCM_OU_PARAM')
    THEN
      RETURN '&' || 'AS_OF_DATE=' || fnd_date.date_to_chardate (TRUNC (SYSDATE)) || '&' || 'CURRENCY=' || currency;
    ELSIF (region_id = 'OKI_DBI_K_BALANCE_G')
    THEN
      RETURN '&' || 'AS_OF_DATE=' || fnd_date.date_to_chardate (TRUNC (SYSDATE)) || '&' || 'CURRENCY=' || currency;
    ELSE
      RETURN NULL;
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      bis_collection_utilities.put_line (SQLERRM || '' || SQLCODE);
      fnd_message.set_name (application    => 'FND'
			  , NAME	   => 'CRM-DEBUG ERROR');
      fnd_message.set_token (token    => 'ROUTINE'
			   , VALUE    => 'OKI_DBI_UTIL_PVT.get_dbi_params ');
      bis_collection_utilities.put_line (fnd_message.get);
      raise_application_error (-20000
			     , 'Stack Dump Follows =>'
			     , TRUE);
  END get_dbi_params;

-- -------------------------------
-- get_global_currency
-- -------------------------------
  FUNCTION get_global_currency
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN bis_common_parameters.get_currency_code;
  EXCEPTION
    WHEN OTHERS
    THEN
      bis_collection_utilities.put_line (SQLERRM || '' || SQLCODE);
      fnd_message.set_name (application    => 'FND'
			  , NAME	   => 'CRM-DEBUG ERROR');
      fnd_message.set_token (token    => 'ROUTINE'
			   , VALUE    => 'OKI_DBI_UTIL_PVT.get_global_currency ');
      bis_collection_utilities.put_line (fnd_message.get);
      raise_application_error (-20000
			     , 'Stack Dump Follows =>'
			     , TRUE);
  END get_global_currency;

-- -------------------------------
-- get_display_currency
-- -------------------------------
  FUNCTION get_display_currency (
    p_currency_code		IN	 VARCHAR2
  , p_selected_operating_unit	IN	 VARCHAR2)
    RETURN VARCHAR2
  IS
    l_global_currency_code	   VARCHAR2 (3);
    l_operating_unit		   VARCHAR2 (10);
    l_functional_currency_code	   VARCHAR2 (3);
    l_common_functional_currency   VARCHAR2 (3);
    l_sec_profile_id		   VARCHAR2 (10);
    l_sec_profile		   NUMBER;
    l_return_value                 VARCHAR2 (1);
  BEGIN
    l_sec_profile    := get_sec_profile;
    l_return_value  := '0';
    -- selected currency is the same as the global currency

    IF (l_global_currency_code IS NULL)
    THEN
      l_global_currency_code	:= get_global_currency;
    END IF;

    IF (p_currency_code = 'FII_GLOBAL1')
    THEN
      RETURN '1'; -- always show the global currency
    ELSE
      -- Currency is not the global currency
      IF (p_selected_operating_unit <> 'ALL')
      THEN
	IF (   p_selected_operating_unit <> l_operating_unit
	    OR l_operating_unit IS NULL)
	THEN
	  SELECT currency_code
	    INTO l_functional_currency_code
	    FROM financials_system_params_all fsp
	       , gl_sets_of_books gsob
	   WHERE fsp.org_id = p_selected_operating_unit
	     AND fsp.set_of_books_id = gsob.set_of_books_id;

	  l_operating_unit    := p_selected_operating_unit;
	END IF;

	IF (	(p_currency_code = l_functional_currency_code)
	    AND (l_global_currency_code <> l_functional_currency_code))
	THEN
	  RETURN '1';
	ELSE
	  RETURN '0';
	END IF;
      ELSE -- operating unit is 'All'
	IF (   l_common_functional_currency IS NULL
	    OR NVL (l_sec_profile_id
		  , -1) <> l_sec_profile)
	THEN
	  l_sec_profile_id    := l_sec_profile;

	  SELECT DISTINCT currency_code
		     INTO l_common_functional_currency
		     FROM financials_system_params_all fsp
			, gl_sets_of_books gsob
		    WHERE fsp.set_of_books_id = gsob.set_of_books_id
		      AND fsp.org_id IN (SELECT organization_id
					   FROM per_organization_list
					  WHERE security_profile_id = l_sec_profile);
	END IF;

	IF (	(p_currency_code = l_common_functional_currency)
	    AND (l_global_currency_code <> l_common_functional_currency))
	THEN
	  RETURN '1';
	ELSE
	  RETURN '0';
	END IF;
      END IF;
    END IF;
  EXCEPTION
    WHEN TOO_MANY_ROWS
    THEN
      l_common_functional_currency    := 'N/A';
      RETURN '0';
    WHEN OTHERS
    THEN
      RETURN '0';
  END get_display_currency;

-- -----------------------------------------------------
-- get_parameter_values :  Gets all the BIS parameters
-- -----------------------------------------------------
  PROCEDURE get_parameter_values (
    p_param			IN	 bis_pmv_page_parameter_tbl
  , p_view_by			OUT NOCOPY VARCHAR2
  , p_period_type		OUT NOCOPY VARCHAR2
  , p_org			OUT NOCOPY VARCHAR2
  , p_comparison_type		OUT NOCOPY VARCHAR2
  , p_xtd			OUT NOCOPY VARCHAR2
  , p_as_of_date		OUT NOCOPY DATE
  , p_cur_suffix		OUT NOCOPY VARCHAR2
  , p_pattern			OUT NOCOPY NUMBER
  , p_period_type_id		OUT NOCOPY NUMBER
  , p_period_type_code		OUT NOCOPY VARCHAR2)
  IS
    l_currency	 VARCHAR2 (30);
  BEGIN
    FOR i IN 1 .. p_param.COUNT
    LOOP
      IF (p_param (i).parameter_name = 'VIEW_BY')
      THEN
	p_view_by    := p_param (i).parameter_value;
      END IF;

      IF (p_param (i).parameter_name = 'PERIOD_TYPE')
      THEN
	p_period_type	 := p_param (i).parameter_value;
      END IF;

      IF (p_param (i).parameter_name = 'ORGANIZATION+FII_OPERATING_UNITS')
      THEN
	p_org	 := p_param (i).parameter_value;
      END IF;

      IF (p_param (i).parameter_name = 'TIME_COMPARISON_TYPE')
      THEN
	IF (p_param (i).parameter_value = 'YEARLY')
	THEN
	  p_comparison_type    := 'Y';
	ELSE
	  p_comparison_type    := 'S';
	END IF;
      END IF;

      IF (p_param (i).parameter_name = 'AS_OF_DATE')
      THEN
	p_as_of_date	:= TO_DATE (p_param (i).parameter_value
				  , 'DD-MM-YYYY');
      END IF;

      IF (p_param (i).parameter_name = 'CURRENCY+FII_CURRENCIES')
      THEN
	l_currency    := p_param (i).parameter_id;
      END IF;
    END LOOP;

    IF (p_period_type = 'FII_TIME_ENT_YEAR')
    THEN
      p_xtd		    := 'YTD';
      p_period_type_id	    := 64;
      p_period_type_code    := 'y';
      p_pattern 	    := 119;
    ELSIF (p_period_type = 'FII_TIME_ENT_QTR')
    THEN
      p_xtd		    := 'QTD';
      p_period_type_id	    := 32;
      p_period_type_code    := 'q';
      p_pattern 	    := 55;
    ELSE
      -- Default values
      p_period_type	    := 'FII_TIME_ENT_PERIOD';
      p_xtd		    := 'MTD';
      p_period_type_id	    := 16;
      p_period_type_code    := 'p';
      p_pattern 	    := 23;
/*
  -- Not currently used
  else	p_xtd := 'WTD';
   p_period_type_id := 1;
	p_period_type_code := 'w' ;
   p_pattern := 11;
*/
    END IF;

    IF (p_as_of_date IS NULL)
    THEN
      p_as_of_date    := SYSDATE;
    END IF;

    IF (p_comparison_type IS NULL)
    THEN
      p_comparison_type    := 'S';
    END IF;

    IF (l_currency = '''FII_GLOBAL1''')
    THEN
      p_cur_suffix    := 'g';
    --Added by Arun.R for secondary global currency changes for OKI on Nov-05-03
    ELSIF(l_currency = '''FII_GLOBAL2''') then
      p_cur_suffix := 'sg';
    ELSE
      p_cur_suffix    := 'f';
    END IF;

    IF (p_cur_suffix IS NULL)
    THEN
      p_cur_suffix    := 'g';
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      bis_collection_utilities.put_line (SQLERRM || '' || SQLCODE);
      fnd_message.set_name (application    => 'FND'
			  , NAME	   => 'CRM-DEBUG ERROR');
      fnd_message.set_token (token    => 'ROUTINE'
			   , VALUE    => 'OKI_DBI_UTIL_PVT.get_parameter_values ');
      bis_collection_utilities.put_line (fnd_message.get);
      raise_application_error (-20000
			     , 'Stack Dump Follows =>'
			     , TRUE);
  END get_parameter_values;

  PROCEDURE get_drill_across_param_val (
    p_param			IN	 bis_pmv_page_parameter_tbl
  , p_attribute_code_num1	OUT NOCOPY NUMBER
  , p_attribute_code_num2	OUT NOCOPY NUMBER
  , p_attribute_code_num3	OUT NOCOPY NUMBER
  , p_attribute_code_num4	OUT NOCOPY NUMBER
  , p_attribute_code_num5	OUT NOCOPY NUMBER
  , p_attribute_code_char1	OUT NOCOPY VARCHAR2
  , p_attribute_code_char2	OUT NOCOPY VARCHAR2
  , p_attribute_code_char3	OUT NOCOPY VARCHAR2
  , p_attribute_code_char4	OUT NOCOPY VARCHAR2
  , p_attribute_code_char5	OUT NOCOPY VARCHAR2)
  IS
  BEGIN
    FOR i IN 1 .. p_param.COUNT
    LOOP
      IF (p_param (i).parameter_name = 'pAttributeCodeNum1')
      THEN
	p_attribute_code_num1	 := p_param (i).parameter_value;
      ELSIF (p_param (i).parameter_name = 'pAttributeCodeNum2')
      THEN
	p_attribute_code_num2	 := p_param (i).parameter_value;
      ELSIF (p_param (i).parameter_name = 'pAttributeCodeNum3')
      THEN
	p_attribute_code_num3	 := p_param (i).parameter_value;
      ELSIF (p_param (i).parameter_name = 'pAttributeCodeNum4')
      THEN
	p_attribute_code_num4	 := p_param (i).parameter_value;
      ELSIF (p_param (i).parameter_name = 'pAttributeCodeNum5')
      THEN
	p_attribute_code_num5	 := p_param (i).parameter_value;
      ELSIF (p_param (i).parameter_name = 'pAttributeCodeChar1')
      THEN
	p_attribute_code_char1	  := p_param (i).parameter_value;
      ELSIF (p_param (i).parameter_name = 'pAttributeCodeChar2')
      THEN
	p_attribute_code_char2	  := p_param (i).parameter_value;
      ELSIF (p_param (i).parameter_name = 'pAttributeCodeChar3')
      THEN
	p_attribute_code_char3	  := p_param (i).parameter_value;
      ELSIF (p_param (i).parameter_name = 'pAttributeCodeChar4')
      THEN
	p_attribute_code_char4	  := p_param (i).parameter_value;
      ELSIF (p_param (i).parameter_name = 'pAttributeCodeChar5')
      THEN
	p_attribute_code_char5	  := p_param (i).parameter_value;
      ELSIF (p_param (i).parameter_name = 'OKI_STATUS+OKI_STATUS')
      THEN
	p_attribute_code_char5	  := p_param (i).parameter_id;
      ELSIF (p_param (i).parameter_name = 'OKI_STATUS+TERM_REASON')
      THEN
	p_attribute_code_char5	  := p_param (i).parameter_id;
      ELSIF (p_param (i).parameter_name = 'OKI_STATUS+EXP_STATUS')
      THEN
	p_attribute_code_num5	  := TO_NUMBER (REPLACE (p_param (i).parameter_id
						       , ''''));
	p_attribute_code_char5	  := p_param (i).parameter_value;
      ELSIF (p_param (i).parameter_name = 'OKI_STATUS+BKD_STATUS')
      THEN
	p_attribute_code_num5	  := TO_NUMBER (REPLACE (p_param (i).parameter_id
						       , ''''));
	--p_attribute_code_char5 := p_param(i).parameter_id ;
	p_attribute_code_char4	  := p_param (i).parameter_value;
      END IF;
    END LOOP;
  EXCEPTION
    WHEN OTHERS
    THEN
      bis_collection_utilities.put_line (SQLERRM || '' || SQLCODE);
      fnd_message.set_name (application    => 'FND'
			  , NAME	   => 'CRM-DEBUG ERROR');
      fnd_message.set_token (token    => 'ROUTINE'
			   , VALUE    => 'OKI_DBI_UTIL_PVT.get_drill_across_param_val ');
      bis_collection_utilities.put_line (fnd_message.get);
      raise_application_error (-20000
			     , 'Stack Dump Follows =>'
			     , TRUE);
  END get_drill_across_param_val;

  PROCEDURE process_parameters (
    p_param			IN	 bis_pmv_page_parameter_tbl
  , p_view_by			OUT NOCOPY VARCHAR2
  , p_view_by_col_name		OUT NOCOPY VARCHAR2
  , p_comparison_type		OUT NOCOPY VARCHAR2
  , p_xtd			OUT NOCOPY VARCHAR2
  , p_as_of_date		OUT NOCOPY DATE
  , p_prev_as_of_date		OUT NOCOPY DATE
  , p_cur_suffix		OUT NOCOPY VARCHAR2
  , p_nested_pattern		OUT NOCOPY NUMBER
  , p_where_clause		OUT NOCOPY VARCHAR2
  , p_mv			OUT NOCOPY VARCHAR2
  , p_join_tbl			OUT NOCOPY poa_dbi_util_pkg.poa_dbi_join_tbl
  , p_period_type		OUT NOCOPY VARCHAR2
  , p_trend			IN	 VARCHAR2
  , p_func_area 		IN	 VARCHAR2 -- Renewals?
  , p_version			IN	 VARCHAR2
  , p_role			IN	 VARCHAR2 --
  , p_mv_set			IN	 VARCHAR2
  , p_rg_where			IN	 VARCHAR2) -- SRM
  IS
    l_dim_map	 poa_dbi_util_pkg.poa_dbi_dim_map;
    l_dim_bmap	 NUMBER;
    l_rpt_where  VARCHAR2(3000);
    l_class  VARCHAR2(3000);
    l_eni_schema VARCHAR2(20);
  BEGIN

    g_param   := p_param;
    g_trend   := p_trend;
    g_mv_set  := p_mv_set;
    l_dim_bmap	      := 0;
    l_eni_schema := 'ENI';

    split_pseudo_rs_group (p_param);

    init_dim_map (l_dim_map
		, p_func_area
		, p_version
		, p_mv_set);
    poa_dbi_util_pkg.get_parameter_values (p_param
					 , l_dim_map
					 , p_view_by
					 , p_comparison_type
					 , p_xtd
					 , p_as_of_date
					 , p_prev_as_of_date
					 , p_cur_suffix
					 , p_nested_pattern
					 , l_dim_bmap);
    g_view_by	:=  p_view_by;
/* add in the security dimensions that must always be present in bmap */
  --Ravi commented
    --	l_dim_bmap	  := poa_dbi_util_pkg.bitor (l_dim_bmap
      --					 , g_oper_unit_bmap);
/* Change the Suffix */
    p_cur_suffix      := get_cur_suffix (p_cur_suffix);
/* Set period type */
    p_period_type     := get_period_type_code (p_xtd);


    --DBMS_OUTPUT.put_line ('40: ');

    IF (l_dim_map.EXISTS (p_view_by))
    THEN
      p_view_by_col_name    := l_dim_map (p_view_by).col_name;
    END IF;

    p_mv	      := get_mv (l_dim_bmap
			       , p_func_area
			       , p_version
			       , p_mv_set);

  IF (p_mv_set IN ('SRM_DTL_RPT','SRM_CDTL_RPT'))   then
    p_where_clause := get_dtl_param_where(p_param);
  ELSE   -- summary reports and trends
    p_where_clause    :=
			oki_dbi_util_pvt.get_where_clauses(l_dim_map, p_trend, p_view_by,p_mv_set)
		     || get_security_where_clauses (l_dim_map
						  , p_func_area
						  , p_version
						  , p_role
						  , p_view_by
						  , p_rg_where
						  , p_param);
    get_join_info (p_view_by
		 , l_dim_map
		 , p_join_tbl
		 , p_func_area
		 , p_version);
  END IF;

  END process_parameters;

-----------------------------------------
FUNCTION get_dtl_param_where(  p_param			IN	 bis_pmv_page_parameter_tbl)
  RETURN VARCHAR2
  IS
  l_sg			VARCHAR2(3200);
  l_org 		VARCHAR2(3200);
  l_prod		VARCHAR2(3200);
  l_prod_cat		VARCHAR2(3200);
  l_cust		VARCHAR2(3200);
  l_reason              VARCHAR2(3200);
  l_resource VARCHAR2(500);
  l_rgroup VARCHAR2(500);
  l_param_where VARCHAR2(5000);
  l_sep               NUMBER;
  l_class VARCHAR2(3000);
 BEGIN

   FOR i IN 1..p_param.COUNT
  LOOP

  IF(p_param(i).parameter_name = 'ORGANIZATION+FII_OPERATING_UNITS')
    THEN l_org := p_param(i).parameter_value;
         IF (  l_org IS NULL OR l_org = '' OR l_org = 'All') then
            l_org :=' ';
         else
           l_org := ' AND fact.authoring_org_id in (&ORGANIZATION+FII_OPERATING_UNITS)';
         end if;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_PROD_LEAF_CAT')
    THEN l_prod_cat := p_param(i).parameter_value;
          IF (  l_prod_cat IS NULL OR l_prod_cat = '' OR l_prod_cat = 'All') then
            l_prod_cat :=' ';
          else
            l_prod_cat :=' AND fact.service_item_category_id  in (&ITEM+ENI_ITEM_PROD_LEAF_CAT)';
         end if;
    END IF;

    IF(p_param(i).parameter_name = 'OKI_STATUS+TERM_REASON')
    THEN l_reason := p_param(i).parameter_value;
         IF (  l_reason IS NULL OR l_reason = '' OR l_reason = 'All') then
            l_reason :=' ';
         else
           l_reason := ' AND fact.trn_code in (&OKI_STATUS+TERM_REASON)';
         end if;
    END IF;

    IF(p_param(i).parameter_name = 'OKI_STATUS+CNCL_REASON')
    THEN l_reason := p_param(i).parameter_value;
         IF (  l_reason IS NULL OR l_reason = '' OR l_reason = 'All') then
            l_reason :=' ';
         else
           l_reason := ' AND fact.sts_code in (&OKI_STATUS+CNCL_REASON)';
         end if;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM')
    THEN l_prod := p_param(i).parameter_id;
         IF (  l_prod IS NULL OR l_prod = '' OR l_prod = 'All') then
           l_prod :=' ';
         else
           l_prod := '  AND fact.service_item_org_id in (&ITEM+ENI_ITEM) ';
         end if;
    END IF;


    IF(p_param(i).parameter_name = 'ORGANIZATION+JTF_ORG_SALES_GROUP')
    THEN l_sg := p_param(i).parameter_id;
    END IF;

    IF(p_param(i).parameter_name = 'FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS')
    THEN l_class := p_param(i).parameter_value;
         IF (  l_class IS NULL OR l_class = '' OR l_class = 'All') then
            l_class :=' ';
         else
           l_class := 'AND fact.class_code in (&FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS)';
         end if;
    END IF;


    IF(p_param(i).parameter_name = 'CUSTOMER+FII_CUSTOMERS')
    THEN l_cust := p_param(i).parameter_value;
         IF (  l_cust IS NULL OR l_cust = '' OR l_cust = 'All') then
            l_cust :=' ';
         else
            l_cust :=' and fact.customer_party_id in (&CUSTOMER+FII_CUSTOMERS)';
         end if;
    END IF;

  END LOOP;

      IF (oki_dbi_util_pvt.g_resource_id IS NULL)   THEN
         l_resource :=  ' ';
         l_rgroup := ' AND fact.resource_group_id = rs_grp.rg_id
                    AND rs_grp.prg_id  = &OKI_RG ';
      ELSE
          l_resource := 'AND fact.resource_id = &OKI_RS ' ;
          l_rgroup := ' AND fact.resource_group_id       = &OKI_RG ';
      END IF;


  l_param_where := l_org || l_prod_cat || l_prod || l_rgroup || l_resource || l_class || l_cust || l_reason;

  return l_param_where;

 END get_dtl_param_where;


/* -----------------------------------------------------------------------------
get_prodcat_where: Get where clause for product category
----------------------------------------------------------------------------- */

  FUNCTION get_prodcat_where
    RETURN VARCHAR2
  IS
  BEGIN
/*
    IF( (g_trend = 'N') AND
	      (  g_view_by = g_time_mth_dim
	      OR g_view_by = g_time_qtr_dim
	      OR g_view_by = g_time_year_dim) )
    THEN
     -- This is a report which goes to oki_20_J_mv
	IF (get_param_id (g_param
			, g_prod_ctgy_dim) IS NOT NULL)
	THEN

	  RETURN
	  ' AND fact.service_item_category_id IN (
					       SELECT d.child_id
					       FROM eni_denorm_hierarchies d
					       WHERE d.parent_id = &ITEM+ENI_ITEM_VBH_CAT
					       AND  item_assgn_flag = ''Y''
					       AND  dbi_flag = ''Y''
					    ) ';
	END IF;
    END IF;
*/

    IF (get_param_id (g_param
		    , g_prod_ctgy_dim) IS NOT NULL)
    THEN
       -- RETURN ' and fact.parent_id = &ITEM+ENI_ITEM_VBH_CAT ';
--RAVI FOR DBI 70
	 RETURN ' and fact.service_item_category_id = &ITEM+ENI_ITEM_VBH_CAT ';
/*    ELSIF(g_view_by = g_prod_ctgy_dim) THEN
    -- prod_cat = All so need to get all top nodes
       RETURN ' and fact.parent_id IN (
					SELECT d.parent_id
					FROM eni_denorm_hierarchies d
					WHERE d.top_node_flag = ''Y''
				       )'; */
    END IF;

    RETURN '';

  END get_prodcat_where;
/* -----------------------------------------------------------------------------
get_rg_sec_where: Get where clause for resource group
----------------------------------------------------------------------------- */
  FUNCTION get_rg_sec_where (
    p_rg_value			IN	 VARCHAR2
  , p_rg_col			IN	 VARCHAR2
  , p_view_by			IN	 VARCHAR2)
    RETURN VARCHAR2
  IS
    l_sec_where_clause	 VARCHAR2 (1000) := NULL;
  BEGIN
  -- brrao modified
  -- for semi-detail VIEW_BY REPORTS
  -- used for Past Due percent, Booking to renewal ratios, Period renewal rates reports
  IF (g_mv_set = 'SRM_DET')
  THEN
     IF (g_resource_id IS NULL)
     THEN
	RETURN '  fact.rg_id = &OKI_RG and fact.umarker <> ''TOP GROUP'' ';
     ELSE
	RETURN ' fact.rg_id = &OKI_RG AND  fact.resource_id = &OKI_RS ';
     END IF;
  -- for detail contract reports - (non-view-by)
  -- Used for Late renewals Aging and Cancellation Detail reports aswell.
  ELSIF (g_mv_set IN ( 'SRM_RPT','SRM_CUST_RPT', 'SRM_TBK_RPT','SRM_LATE_BKING') )  --Added by  Arun SRM_CUST_RPT for YTD customer reports
  THEN
     IF (g_resource_id IS NULL)
     THEN
		  IF g_mv_set='SRM_TBK_RPT' THEN
        	RETURN ' fact.resource_group_id IN ( SELECT sgr2.rg_id FROM oki_rs_group_mv sgr2  WHERE sgr2.prg_id = &OKI_RG ) ';
         ELSE
        	RETURN ' fact.rg_id IN ( SELECT sgr2.rg_id FROM oki_rs_group_mv sgr2  WHERE sgr2.prg_id = &OKI_RG ) ';
         END IF;
     ELSE
   	    IF g_mv_set='SRM_TBK_RPT' THEN
 			RETURN '  fact.resource_group_id = &OKI_RG AND fact.resource_id = &OKI_RS ';
        ELSE
 			RETURN '  fact.rg_id = &OKI_RG AND fact.resource_id = &OKI_RS ';
		END IF;
     END IF;
     -- for trends and table portlets
     -- Also used for Late renewal and Cancellation Summary reports
ELSIF( g_mv_set IN ('SRM','SRM_BLG','SRM_OPN','SRM_BLG_CUST','SRM_BAL') ) --Added BY Arun SRM_BLG_CUST for ITD customer reports

  THEN
      IF(g_trend = 'Y')
      THEN
	  IF (g_resource_id IS NULL)
	  THEN
	    RETURN '  fact.rg_id = &OKI_RG AND fact.resource_id = -999 ';
	  ELSE
	    RETURN ' fact.rg_id = &OKI_RG AND  fact.resource_id = &OKI_RS ';
	  END IF;
      ELSIF p_view_by = g_sales_grp_dim
      THEN
	  IF (g_resource_id IS NULL)
	  THEN
	  /*
	    RETURN ' ((fact.rg_id in (select rg_id from oki_rs_group_mv where prg_id = &OKI_RG
		      and denorm_level = 1) and fact.resource_id = -999)
		      or (fact.rg_id = &OKI_RG and fact.resource_id <> -999)) ';
	  */
	    RETURN ' ( fact.prg_id =  &OKI_RG
		       and fact.umarker <> ''TOP GROUP'' ) ';
	  ELSE
	    RETURN ' fact.rg_id = &OKI_RG AND  fact.resource_id = &OKI_RS ';
	  END IF;
      ELSE
	  IF (g_resource_id IS NULL)
	  THEN
	    RETURN ' fact.rg_id = &OKI_RG AND fact.resource_id = -999 ';
	  ELSE
	    RETURN ' fact.rg_id = &OKI_RG AND  fact.resource_id = &OKI_RS ';
	  END IF;
      END IF;
  END IF;


  IF (g_mv_set IN ( 'SRM_CR_71','SRM_EC_71','SRM_CN_71','SRM_SG_71','SRM_ST_71','SRM_TM_71','SRM_EN_71' ))  --Added by blindaue for 71 reports
  THEN
    IF (g_resource_id IS NULL)
      THEN RETURN ' ( fact.prg_id = &OKI_RG and fact.umarker <> ''TOP GROUP'' ) ';
      ELSE RETURN ' fact.rg_id = &OKI_RG AND fact.resource_id = &OKI_RS ';
    END IF;
  END IF;


  RETURN l_sec_where_clause;
  END get_rg_sec_where;

/* -----------------------------------------------------------------------------
get_security_where_clauses: Where clauses for
(1) Operating Unit
(2) Resource Group
----------------------------------------------------------------------------- */
  FUNCTION get_security_where_clauses (
    p_dim_map				 poa_dbi_util_pkg.poa_dbi_dim_map
  , p_func_area 		IN	 VARCHAR2
  , p_version			IN	 VARCHAR2
  , p_role			IN	 VARCHAR2
  , p_view_by			IN	 VARCHAR2
  , p_rg_where			IN	 VARCHAR2
  , p_param			IN	 bis_pmv_page_parameter_tbl)
    RETURN VARCHAR2
  IS
    l_sec_where_clause     VARCHAR2 (1000);

    l_rg_where		   VARCHAR2 (1000);
    l_prodcat_where	   VARCHAR2 (1000);

    l_ou_where		   VARCHAR2 (1000);
    l_org_col		   VARCHAR2 (30);
    l_service_cat_where    VARCHAR2 (1000);
  BEGIN
    l_sec_where_clause := '';
/*    l_org_col     := 'authoring_org_id';
    l_ou_where	  := poa_dbi_util_pkg.get_ou_sec_where (p_dim_map ('ORGANIZATION+FII_OPERATING_UNITS').VALUE
						      , p_dim_map ('ORGANIZATION+FII_OPERATING_UNITS').col_name);

    IF (l_ou_where IS NOT NULL)
    THEN
      l_sec_where_clause    := l_sec_where_clause || ' and ' || l_ou_where;
    END IF;
*/

    IF p_rg_where = 'Y'
    THEN
      l_rg_where    := get_rg_sec_where (p_dim_map (g_sales_grp_dim).VALUE
				       , p_dim_map (g_sales_grp_dim).col_name
				       , p_view_by);
      IF (l_rg_where IS NOT NULL)
      THEN
	l_sec_where_clause    := l_sec_where_clause || ' and ' || l_rg_where;
      END IF;
    END IF;

 /*
    l_prodcat_where := get_prodcat_where();
      IF (l_prodcat_where IS NOT NULL)
      THEN
	l_sec_where_clause    := l_sec_where_clause || l_prodcat_where;
      END IF;
 */
    RETURN l_sec_where_clause;
  END get_security_where_clauses;

/* -----------------------------------------------------------------------------
get_mv:
----------------------------------------------------------------------------- */
  FUNCTION get_mv (
    p_dim_bmap			IN	 NUMBER
  , p_func_area 		IN	 VARCHAR2
  , p_version			IN	 VARCHAR2
  , p_mv_set			IN	 VARCHAR2)
    RETURN VARCHAR2
  IS
    l_index	    NUMBER		:= 1;
    l_cost	    NUMBER;
    l_mv_bmap_tbl   oki_dbi_mv_bmap_tbl;
  BEGIN
    populate_mv_bmap (l_mv_bmap_tbl
		    , p_mv_set);
    l_cost    := l_mv_bmap_tbl (1).mv_bmap;

    FOR i IN l_mv_bmap_tbl.FIRST .. l_mv_bmap_tbl.LAST
    LOOP
      IF (BITAND (l_mv_bmap_tbl (i).mv_bmap
		, p_dim_bmap) = p_dim_bmap)
      THEN
	IF (l_mv_bmap_tbl (i).mv_bmap < l_cost)
	THEN
	  l_cost     := l_mv_bmap_tbl (i).mv_bmap;
	  l_index    := i;
	END IF;
      END IF;
    END LOOP;

    RETURN l_mv_bmap_tbl (l_index).mv_name;
  END get_mv;

/* -----------------------------------------------------------------------------
init_dim_map: Initialize the dimension mapping
----------------------------------------------------------------------------- */
  PROCEDURE init_dim_map (
    p_dim_map			OUT NOCOPY poa_dbi_util_pkg.poa_dbi_dim_map
  , p_func_area 		IN	 VARCHAR2
  , p_version			IN	 VARCHAR2
  , p_mv_set			IN	 VARCHAR2)
  IS
    l_dim_rec	poa_dbi_util_pkg.poa_dbi_dim_rec;
  BEGIN
    -- Operating Unit
    l_dim_rec.generate_where_clause    := 'Y';
    l_dim_rec.col_name		       := get_col_name (dim_name       => g_oper_unit_dim
						      , p_func_area    => p_func_area
						      , p_version      => p_version);
    l_dim_rec.view_by_table	       := get_table (dim_name	    => g_oper_unit_dim
						   , p_func_area    => p_func_area
						   , p_version	    => p_version);
    l_dim_rec.bmap		       := g_oper_unit_bmap;
    p_dim_map (g_oper_unit_dim)        := l_dim_rec;
    -- Sales Group
    l_dim_rec.generate_where_clause    := 'N';
    l_dim_rec.col_name		       := get_col_name (dim_name       => g_sales_grp_dim
						      , p_func_area    => p_func_area
						      , p_version      => p_version);
    l_dim_rec.view_by_table	       := get_table (dim_name	    => g_sales_grp_dim
						   , p_func_area    => p_func_area
						   , p_version	    => p_version);
    l_dim_rec.bmap		       := g_sales_grp_bmap;
    p_dim_map (g_sales_grp_dim)        := l_dim_rec;

    -- Service Item
    l_dim_rec.generate_where_clause    := 'Y';
    l_dim_rec.col_name		       := get_col_name (dim_name       => g_sitem_dim
						      , p_func_area    => p_func_area
						      , p_version      => p_version);
    l_dim_rec.view_by_table	       := get_table (dim_name	    => g_sitem_dim
						   , p_func_area    => p_func_area
						   , p_version	    => p_version);
    l_dim_rec.bmap		       := g_sitem_bmap;
    p_dim_map (g_sitem_dim)	       := l_dim_rec;

    -- Cust classification
    l_dim_rec.generate_where_clause    := 'Y';
    l_dim_rec.col_name		       := get_col_name (dim_name       => g_cust_class_dim
						      , p_func_area    => p_func_area
						      , p_version      => p_version);
    l_dim_rec.view_by_table	       := get_table (dim_name	    => g_cust_class_dim
						   , p_func_area    => p_func_area
						   , p_version	    => p_version);
    l_dim_rec.bmap		       := g_cust_class_bmap;
    p_dim_map (g_cust_class_dim)	    := l_dim_rec;

    -- Product Category
    l_dim_rec.generate_where_clause    := 'Y';
    l_dim_rec.col_name		       := get_col_name (dim_name       => g_prod_ctgy_dim
						      , p_func_area    => p_func_area
						      , p_version      => p_version);
    l_dim_rec.view_by_table	       := get_table (dim_name	    => g_prod_ctgy_dim
						   , p_func_area    => p_func_area
						   , p_version	    => p_version);
    l_dim_rec.bmap		       := g_prd_ctgy_bmap;
    p_dim_map (g_prod_ctgy_dim)        := l_dim_rec;
    -- Cancellation Reason
    l_dim_rec.generate_where_clause    := 'Y';
    l_dim_rec.col_name		       := get_col_name (dim_name       => g_cncl_reason_dim
						      , p_func_area    => p_func_area
						      , p_version      => p_version);
    l_dim_rec.view_by_table	       := get_table (dim_name	    => g_cncl_reason_dim
						   , p_func_area    => p_func_area
						   , p_version	    => p_version);
    l_dim_rec.bmap		       := g_cncl_reason_bmap;
    p_dim_map (g_cncl_reason_dim)      := l_dim_rec;

      --Customer Added by Arun for 7.0
    l_dim_rec.generate_where_clause    := 'Y';
    l_dim_rec.col_name		       := get_col_name (dim_name       => g_customer_dim
						      , p_func_area    => p_func_area
						      , p_version      => p_version);
    l_dim_rec.view_by_table	       :='FII_CUSTOMERS_V'; -- as  there is no view by customer
    l_dim_rec.bmap		       := g_customer_bmap;
    p_dim_map (g_customer_dim)	    := l_dim_rec;

    -- Terminations Reason
    l_dim_rec.generate_where_clause    := 'Y';
    l_dim_rec.col_name		       := get_col_name (dim_name       => g_trm_reason_dim
						      , p_func_area    => p_func_area
						      , p_version      => p_version);
    l_dim_rec.view_by_table	       := get_table (dim_name	    => g_trm_reason_dim
						   , p_func_area    => p_func_area
						   , p_version	    => p_version);
    l_dim_rec.bmap		       := g_trm_reason_bmap;
    p_dim_map (g_trm_reason_dim)      := l_dim_rec;


  END init_dim_map;

/* -----------------------------------------------------------------------------
get_col_name: Returns the column name in the MV that is associated with the
dimension.
----------------------------------------------------------------------------- */
  FUNCTION get_col_name (
    dim_name				 VARCHAR2
  , p_func_area 		IN	 VARCHAR2
  , p_version			IN	 VARCHAR2)
    RETURN VARCHAR2
  IS
    l_col_name	 VARCHAR2 (100);
  BEGIN
    l_col_name	  :=
      (CASE dim_name
	 WHEN g_sales_grp_dim
	   THEN 'rg_id, resource_id '
	 WHEN g_oper_unit_dim
	   THEN 'authoring_org_id'
	 WHEN g_sitem_dim
--	Commented by Pushkala  THEN 'service_itemorg_id'
       THEN 'service_item_org_id'
	 WHEN g_prod_ctgy_dim
	   THEN 'service_item_category_id '
	 WHEN g_sales_rep_dim
	   THEN 'resource_id'
	 WHEN g_cncl_reason_dim
	   THEN 'sts_code'
	 WHEN g_customer_dim
	   THEN 'customer_party_id'
	 WHEN g_trm_reason_dim
	   THEN 'trn_code'
	 WHEN g_cust_class_dim
	   THEN 'class_code'
     ELSE ''
       END);
/*  Commented By RAVI
     IF ( (dim_name = g_prod_ctgy_dim)
	  AND
	  (get_param_id(g_param,g_prod_ctgy_dim) IS NULL ) )
     THEN
	  l_col_name := 'service_item_category_id';

     END IF;
*/

    RETURN l_col_name;
  END;

/* -----------------------------------------------------------------------------
get_security_where_clauses: Returns the name of the object to join to to which
the MV is joined to ???????????????????????
----------------------------------------------------------------------------- */
  FUNCTION get_table (
    dim_name				 VARCHAR2
  , p_func_area 		IN	 VARCHAR2
  , p_version			IN	 VARCHAR2)
    RETURN VARCHAR2
  IS
    l_table   VARCHAR2 (4000);
  BEGIN
    l_table    :=
      (CASE dim_name
	 WHEN g_oper_unit_dim
	   THEN '(select organization_id id, name value from hr_all_organization_units_tl where language = userenv(''LANG''))'

	 WHEN g_sales_grp_dim
--	   THEN '(SELECT rg.group_id as id , rg.group_name value from JTF_RS_GROUPS_VL rg)'
--	 THEN '(SELECT rg.group_id as id , rg.group_name value from JTF_RS_GROUPS_TL rg where language = userenv(''LANG''))'

       THEN 'OKI_DBI_SRM_GRP_RES_V'
	 WHEN g_sitem_dim
	   THEN 'ENI_ITEM_V'
	 WHEN g_prod_ctgy_dim
	   THEN 'OKI_ENI_ITEM_VBH_NODES_V'
	 WHEN g_sales_rep_dim
	   THEN 'OKI_DIM_SALESFORCE'
	 WHEN g_cncl_reason_dim
	   THEN 'OKI_CANCEL_STATUSES_V'
	 WHEN g_trm_reason_dim
	   THEN 'OKI_TERM_REASONS_V'
	 WHEN g_cust_class_dim
	   THEN 'FII_PARTNER_MKT_CLASS_V'
   	 ELSE ''
       END);
    RETURN l_table;
  END get_table;

  PROCEDURE get_join_info (
    p_view_by			IN	 VARCHAR2
  , p_dim_map			IN	 poa_dbi_util_pkg.poa_dbi_dim_map
  , x_join_tbl			OUT NOCOPY poa_dbi_util_pkg.poa_dbi_join_tbl
  , p_func_area 		IN	 VARCHAR2
  , p_version			IN	 VARCHAR2)
  IS
    l_join_rec	 poa_dbi_util_pkg.poa_dbi_join_rec;
  BEGIN
    x_join_tbl			     := poa_dbi_util_pkg.poa_dbi_join_tbl ();

    IF (NOT p_dim_map.EXISTS (p_view_by))
    THEN
      RETURN;
    END IF;

    --DBMS_OUTPUT.put_line ('Inside join table');
    l_join_rec.table_name	     := p_dim_map (p_view_by).view_by_table;
    l_join_rec.table_alias	     := 'v';
    l_join_rec.fact_column	     := p_dim_map (p_view_by).col_name;

    IF (p_view_by = 'OKI_RESOURCE+SALESREP')
    THEN
      l_join_rec.column_name	:= 'id(+)';
    ELSIF (p_view_by = g_sales_grp_dim)
    THEN
--	l_join_rec.column_name	  := 'id(+)';
      l_join_rec.table_name	       := 'jtf_rs_groups_vl';
      l_join_rec.table_alias	       := 'g';
      l_join_rec.fact_column	       := 'rg_id';
      l_join_rec.column_name	       := 'group_id';
      x_join_tbl.EXTEND;
      x_join_tbl (x_join_tbl.COUNT)    := l_join_rec;
      l_join_rec.table_name	       := 'jtf_rs_resource_extns_vl';
      l_join_rec.table_alias	       := 'r';
      l_join_rec.fact_column	       := 'resource_id';
      l_join_rec.column_name	       := 'resource_id(+)';
    ELSE
      l_join_rec.column_name	:= 'id';
    END IF;

    x_join_tbl.EXTEND;
    x_join_tbl (x_join_tbl.COUNT)    := l_join_rec;
/*
    IF (p_view_by = 'ITEM+POA_ITEMS')
    THEN
      l_join_rec.table_name	       := 'mtl_units_of_measure_vl';
      l_join_rec.table_alias	       := 'v2';
      l_join_rec.fact_column	       := 'base_uom';
      l_join_rec.column_name	       := 'unit_of_measure';
      x_join_tbl.EXTEND;
      x_join_tbl (x_join_tbl.COUNT)    := l_join_rec;
    END IF;
*/
  END get_join_info;

/* Not currently used by OKI */
/* -----------------------------------------------------------------------------
get_join_info:
----------------------------------------------------------------------------- */
/*  PROCEDURE get_join_info (
    p_view_by			IN	 VARCHAR2
  , p_dim_map			IN	 poa_dbi_util_pkg.poa_dbi_dim_map
  , x_join_tbl			OUT NOCOPY poa_dbi_util_pkg.poa_dbi_join_tbl
  , p_func_area 		IN	 VARCHAR2
  , p_version			IN	 VARCHAR2
  , p_rpt_type			IN	 VARCHAR2 := 'SUMMARY')
  IS
    l_join_rec	 poa_dbi_util_pkg.poa_dbi_join_rec;
  BEGIN
    x_join_tbl	  := poa_dbi_util_pkg.poa_dbi_join_tbl ();

    --DBMS_OUTPUT.put_line ('p_rpt_type: [' || p_rpt_type || ']');

    IF (NOT p_dim_map.EXISTS (p_view_by))
    THEN
      IF     (p_rpt_type = 'K_DTL')
	 AND (p_version = '6.0')
      THEN
	l_join_rec.table_name		 := 'oki_scm_000_mv';
	l_join_rec.column_name		 := 'chr_id';
	l_join_rec.table_alias		 := 'k';
	l_join_rec.fact_column		 := 'chr_id';
	x_join_tbl.EXTEND;
	x_join_tbl (x_join_tbl.COUNT)	 := l_join_rec;
	l_join_rec.table_name		 := 'fii_customers_v';
	l_join_rec.column_name		 := 'id';
	l_join_rec.table_alias		 := 'cust';
	l_join_rec.fact_column		 := 'customer_party_id';
	x_join_tbl.EXTEND;
	x_join_tbl (x_join_tbl.COUNT)	 := l_join_rec;
	l_join_rec.table_name		 := 'jtf_rs_resource_extns_tl';
	l_join_rec.column_name		 := 'resource_id';
	l_join_rec.table_alias		 := 'rsex';
	l_join_rec.dim_outer_join	 := 'Y';
	l_join_rec.fact_column		 := 'resource_id';
	x_join_tbl.EXTEND;
	x_join_tbl (x_join_tbl.COUNT)	 := l_join_rec;
	--DBMS_OUTPUT.put_line ('Join:');
      END IF;
    ELSE
      --DBMS_OUTPUT.put_line ('Else:');
      l_join_rec.table_name	       := p_dim_map (p_view_by).view_by_table;
      l_join_rec.table_alias	       := 'v';
      l_join_rec.fact_column	       := p_dim_map (p_view_by).col_name;

      IF (p_view_by = 'ITEM+POA_COMMODITIES')
      THEN
	l_join_rec.additional_where_clause    := 'language=USERENV(''LANG'')';
	l_join_rec.column_name		      := 'commodity_id';
      ELSE
	l_join_rec.column_name	  := 'id';
      END IF;

      x_join_tbl.EXTEND;
      x_join_tbl (x_join_tbl.COUNT)    := l_join_rec;

      IF (p_view_by = 'ITEM+POA_ITEMS')
      THEN
	l_join_rec.table_name		 := 'mtl_units_of_measure_vl';
	l_join_rec.table_alias		 := 'v2';
	l_join_rec.fact_column		 := 'base_uom';
	l_join_rec.column_name		 := 'unit_of_measure';
	x_join_tbl.EXTEND;
	x_join_tbl (x_join_tbl.COUNT)	 := l_join_rec;
      END IF;
    END IF;
  END get_join_info;
*/
  PROCEDURE populate_mv_bmap (
    p_mv_bmap_tbl		OUT NOCOPY oki_dbi_mv_bmap_tbl
  , p_mv_set			IN	 VARCHAR2  )
  IS
    l_rec   oki_dbi_mv_bmap_rec;
  BEGIN
    p_mv_bmap_tbl    := oki_dbi_mv_bmap_tbl ();

--Added by Arun for DBI7.0 SRM Customer reports
/* Renewals by Customer,Period Renewals by Customers,Expected Bookings by Customer
   and Renewal Cancellation s by customer reports should use this MV-Set
   Also commented out all the ENI views which were used for the product category hierarchy and instead added
   the product category dimension to the respective MV's
*/

    IF (p_mv_set = 'SRM_BAL')
    THEN
      -- Pushkala : 71 MVs for Balance
      p_mv_bmap_tbl.EXTEND (2);
      l_rec.mv_name	   := 'OKI_SRM_028_V';
      l_rec.mv_bmap	   := g_sales_grp_bmap+g_prd_ctgy_bmap+g_oper_unit_bmap+g_sitem_bmap+g_cust_class_bmap;
      p_mv_bmap_tbl (1)    := l_rec;
      l_rec.mv_name	   := 'OKI_SRM_038_MV';
      l_rec.mv_bmap	   := g_sales_grp_bmap+g_prd_ctgy_bmap+g_cust_class_bmap+g_oper_unit_bmap;
      p_mv_bmap_tbl (2)    := l_rec;
    ELSIF (p_mv_set = 'SRM_BLG')
    THEN
      -- Pushkala : 71 MVs for Backlog
      p_mv_bmap_tbl.EXTEND (2);
      l_rec.mv_name	   := 'OKI_SRM_029_V';
      l_rec.mv_bmap	   := g_oper_unit_bmap + g_sales_grp_bmap + g_sitem_bmap+g_prd_ctgy_bmap;
      p_mv_bmap_tbl (1)    := l_rec;
      l_rec.mv_name	   := 'OKI_SRM_039_MV';
      l_rec.mv_bmap	   := g_sales_grp_bmap+g_prd_ctgy_bmap+g_oper_unit_bmap;
      p_mv_bmap_tbl (2)    := l_rec;

  ELSIF (p_mv_set = 'SRM_OPN')
    THEN
     -- Pushkala : 71 MVs - Open - Used in Backlog report
     p_mv_bmap_tbl.EXTEND (2);
      l_rec.mv_name	   := 'OKI_SRM_030_V';
      l_rec.mv_bmap	   := g_oper_unit_bmap + g_sales_grp_bmap + g_sitem_bmap+g_prd_ctgy_bmap;
      p_mv_bmap_tbl (1)    := l_rec;
      l_rec.mv_name	   := 'OKI_SRM_040_MV';
      l_rec.mv_bmap	   := g_sales_grp_bmap+g_prd_ctgy_bmap+g_oper_unit_bmap;
      p_mv_bmap_tbl (2)    := l_rec;
    ELSIF (p_mv_set = 'SRM_LATE_BKING')
    THEN
     --Pushkala : 71 MV for Late Bookings
      p_mv_bmap_tbl.EXTEND (1);
      l_rec.mv_name	   := 'OKI_SRM_003_MV';
      l_rec.mv_bmap	   := g_oper_unit_bmap + g_sales_grp_bmap + g_sitem_bmap+g_prd_ctgy_bmap;
      p_mv_bmap_tbl (1)    := l_rec;
    ELSIF (p_mv_set IN ('SRM_DTL_RPT','SRM_CDTL_RPT'))
    THEN
       --Pushkala : 71 MVs for Detail reports
      p_mv_bmap_tbl.EXTEND (1);
      l_rec.mv_bmap	   := g_oper_unit_bmap + g_sales_grp_bmap + g_sitem_bmap+g_prd_ctgy_bmap;
      IF (oki_dbi_util_pvt.g_resource_id IS NULL) then
          l_rec.mv_name := ' OKI_RS_GROUP_MV rs_grp, OKI_SRM_004_MV ';
      ELSE
          l_rec.mv_name := ' OKI_SRM_004_MV ';
      END IF;
      p_mv_bmap_tbl (1)    := l_rec;
    ELSIF (p_mv_set = 'SRM_TBK_RPT')
    THEN
    -- Pushkala : 71 MV for Top Bookings
      p_mv_bmap_tbl.EXTEND (1);
      l_rec.mv_name        := 'OKI_SRM_004_MV';
      l_rec.mv_bmap        := g_oper_unit_bmap+g_sales_grp_bmap+g_customer_bmap;
      p_mv_bmap_tbl (1)    := l_rec;
    ELSIF (p_mv_set = 'SRM_SG_71')
    THEN
      -- Pushkala : 71 Signed Date mvs
      p_mv_bmap_tbl.EXTEND (2);
      l_rec.mv_name	   := 'OKI_SRM_024_V';
      l_rec.mv_bmap	   := g_sales_grp_bmap+g_prd_ctgy_bmap+g_oper_unit_bmap+g_sitem_bmap+g_cust_class_bmap;
      p_mv_bmap_tbl (1)    := l_rec;
      l_rec.mv_name	   := 'OKI_SRM_034_MV';
      l_rec.mv_bmap	   := g_sales_grp_bmap+g_prd_ctgy_bmap+g_cust_class_bmap+g_oper_unit_bmap;
      p_mv_bmap_tbl (2)    := l_rec;
    ELSIF (p_mv_set = 'SRM_ST_71')
    THEN
       -- Pushkala : 71 Start Date mvs
      p_mv_bmap_tbl.EXTEND (2);
      l_rec.mv_name	   := 'OKI_SRM_021_V';
      l_rec.mv_bmap	   := g_sales_grp_bmap+g_prd_ctgy_bmap+g_oper_unit_bmap+g_sitem_bmap+g_cust_class_bmap;
      p_mv_bmap_tbl (1)    := l_rec;
        l_rec.mv_name	   := 'OKI_SRM_031_MV';
      l_rec.mv_bmap	   := g_sales_grp_bmap+g_prd_ctgy_bmap+g_cust_class_bmap+g_oper_unit_bmap;
      p_mv_bmap_tbl (2)    := l_rec;
    ELSIF (p_mv_set = 'SRM_CN_71')
    THEN
       -- Pushkala : 71 Cancelled Date mvs
      p_mv_bmap_tbl.EXTEND (2);
      l_rec.mv_name	   := 'OKI_SRM_027_V';
      l_rec.mv_bmap	   := g_sales_grp_bmap+g_prd_ctgy_bmap+g_oper_unit_bmap+g_cncl_reason_bmap+g_sitem_bmap;
      p_mv_bmap_tbl (1)    := l_rec;
      l_rec.mv_name	   := 'OKI_SRM_037_MV';
      l_rec.mv_bmap	   := g_sales_grp_bmap+g_prd_ctgy_bmap+g_oper_unit_bmap+g_cncl_reason_bmap;
      p_mv_bmap_tbl (2)    := l_rec;
    ELSIF (p_mv_set = 'SRM_EC_71')
    THEN
      -- Pushkala : 71 Expected Close Date mvs
      p_mv_bmap_tbl.EXTEND (2);
      l_rec.mv_name	   := 'OKI_SRM_026_V';
      l_rec.mv_bmap	   := g_sales_grp_bmap+g_prd_ctgy_bmap+g_oper_unit_bmap+g_sitem_bmap;
      p_mv_bmap_tbl (1)    := l_rec;
      l_rec.mv_name	   := 'OKI_SRM_036_MV';
      l_rec.mv_bmap	   := g_sales_grp_bmap+g_prd_ctgy_bmap+g_oper_unit_bmap;
      p_mv_bmap_tbl (2)    := l_rec;
    ELSIF (p_mv_set = 'SRM_TM_71')
    THEN
      -- Pushkala : 71 Termination Date mvs
      p_mv_bmap_tbl.EXTEND (2);
      l_rec.mv_name	   := 'OKI_SRM_025_V';
      l_rec.mv_bmap	   := g_sales_grp_bmap+g_prd_ctgy_bmap+g_oper_unit_bmap+g_trm_reason_bmap+g_sitem_bmap+g_cust_class_bmap;
      p_mv_bmap_tbl (1)    := l_rec;
      l_rec.mv_name	   := 'OKI_SRM_035_MV';
      l_rec.mv_bmap	   := g_sales_grp_bmap+g_prd_ctgy_bmap+g_cust_class_bmap+g_oper_unit_bmap+g_trm_reason_bmap;
      p_mv_bmap_tbl (2)    := l_rec;
    ELSIF (p_mv_set = 'SRM_CR_71')
    THEN
      -- Pushkala : 71 Creation Date mvs
      p_mv_bmap_tbl.EXTEND (2);
      l_rec.mv_name	   := 'OKI_SRM_022_V';
      l_rec.mv_bmap	   := g_sales_grp_bmap+g_prd_ctgy_bmap+g_oper_unit_bmap+g_sitem_bmap;
      p_mv_bmap_tbl (1)    := l_rec;
      l_rec.mv_name	   := 'OKI_SRM_032_MV';
      l_rec.mv_bmap	   := g_sales_grp_bmap+g_prd_ctgy_bmap+g_oper_unit_bmap;
      p_mv_bmap_tbl (2)    := l_rec;
    ELSIF (p_mv_set = 'SRM_EN_71')
    THEN
       -- Pushkala : 71 End Date mvs
      p_mv_bmap_tbl.EXTEND (2);
      l_rec.mv_name	   := 'OKI_SRM_023_V';
      l_rec.mv_bmap	   := g_sales_grp_bmap+g_prd_ctgy_bmap+g_oper_unit_bmap+g_sitem_bmap+g_cust_class_bmap;
      p_mv_bmap_tbl (1)    := l_rec;
      l_rec.mv_name	   := 'OKI_SRM_033_MV';
      l_rec.mv_bmap	   := g_sales_grp_bmap+g_prd_ctgy_bmap+g_cust_class_bmap+g_oper_unit_bmap;
      p_mv_bmap_tbl (2)    := l_rec;
    ELSIF (p_mv_set = 'SRM_RPT')
    THEN
      --Pushkala : Not used by 71 reports
      p_mv_bmap_tbl.EXTEND (1);
      l_rec.mv_name	   := 'oki_20_j_mv';
      l_rec.mv_bmap	   := g_oper_unit_bmap + g_sales_grp_bmap + g_sitem_bmap+g_prd_ctgy_bmap;
      p_mv_bmap_tbl (1)    := l_rec;
    ELSIF (p_mv_set = 'SRM_CUST_RPT')
    THEN
      -- Pushkala : Not used by 71 reports
      p_mv_bmap_tbl.EXTEND (1);
      l_rec.mv_name	   := 'oki_srm_30_mv';
      l_rec.mv_bmap	   := g_oper_unit_bmap+g_sales_grp_bmap+g_sitem_bmap+g_prd_ctgy_bmap+g_cncl_reason_bmap+g_trm_reason_bmap+g_customer_bmap;

      p_mv_bmap_tbl (1)    := l_rec;
    ELSIF (p_mv_set = 'SRM_BLG_CUST') --Past Due Renewals by customer should use this MV-set
    THEN
      --Pushkala : Not used by 71 reports
      p_mv_bmap_tbl.EXTEND (1);
      l_rec.mv_name	   := 'oki_itd_blg_45_mv';
      l_rec.mv_bmap	   := g_oper_unit_bmap + g_sales_grp_bmap + g_prd_ctgy_bmap+g_sitem_bmap+g_customer_bmap;
      p_mv_bmap_tbl (1)    := l_rec;
    ELSIF (p_mv_set = 'SRM')
    THEN
      --Pushkala : Not used by 71 reports
      p_mv_bmap_tbl.EXTEND (5);
      l_rec.mv_name	   := 'oki_srm_45_mv';
      l_rec.mv_bmap	   := g_sales_grp_bmap+g_prd_ctgy_bmap+g_oper_unit_bmap+g_sitem_bmap+g_cncl_reason_bmap+g_trm_reason_bmap;
      p_mv_bmap_tbl (1)    := l_rec;
      l_rec.mv_name	   := '(SELECT * FROM oki_srm_or_50_mv where ogrp_id=1 and  lmarker= 1)';
      l_rec.mv_bmap	   := g_sales_grp_bmap+g_prd_ctgy_bmap;
      p_mv_bmap_tbl (2)    := l_rec;
      l_rec.mv_name	   := '(SELECT * FROM oki_srm_or_50_mv where ogrp_id=0 and  lmarker= 1)';
      l_rec.mv_bmap	   := g_sales_grp_bmap+g_prd_ctgy_bmap+g_sitem_bmap;
      p_mv_bmap_tbl (3)    := l_rec;
      l_rec.mv_name	   := '(SELECT * FROM oki_srm_or_50_mv where ogrp_id=0 and  lmarker= 2)';
      l_rec.mv_bmap	   := g_sales_grp_bmap+g_oper_unit_bmap;
      p_mv_bmap_tbl (4)    := l_rec;
      l_rec.mv_name	   := '(SELECT * FROM oki_srm_or_50_mv where ogrp_id=3 and  lmarker= 1)';
      l_rec.mv_bmap	   := g_sales_grp_bmap;
      p_mv_bmap_tbl (5)    := l_rec;
    END IF;
  EXCEPTION
    WHEN OTHERS
    THEN
      poa_log.debug_line ('refresh_manual_dist mvs ' || SQLERRM || SQLCODE || SYSDATE);
      RAISE;
  END populate_mv_bmap;

  FUNCTION get_viewby_select_clause (
    p_viewby			IN	 VARCHAR2
  , p_func_area 		IN	 VARCHAR2
  , p_version			IN	 VARCHAR2)
    RETURN VARCHAR2
  IS
    l_directs	VARCHAR2 (100);
  BEGIN
    IF (p_viewby = g_sales_grp_dim)
    THEN
      RETURN 'SELECT decode(oset.resource_id,-999,to_char(oset.rg_id),oset.resource_id||''.''||oset.rg_id) VIEWBYID ,decode(oset.resource_id,-999,g.group_name, decode(oset.resource_id, -1, &UNASSIGNED,r.resource_name)) VIEWBY ';
    ELSE
      RETURN 'select v.value VIEWBY
		 ,v.id VIEWBYID ';
    END IF;
  END;

/* -----------------------------------------------------------------------------
get_cur_suffix: OKI does not suffix the functional currency with "b".
OKI uses "f" for the functional currency suffix.
----------------------------------------------------------------------------- */
  FUNCTION get_cur_suffix (
    p_cur_suffix		IN	 VARCHAR2)
    RETURN VARCHAR2
  IS
  BEGIN
    IF p_cur_suffix = 'b'
    THEN
      RETURN 'f';
    ELSE
      RETURN p_cur_suffix;
    END IF;
  END get_cur_suffix;

/* -----------------------------------------------------------------------------
get_period_type_code:
----------------------------------------------------------------------------- */
  FUNCTION get_period_type_code (
    p_xtd			IN	 VARCHAR2)
    RETURN VARCHAR2
  IS
    l_period_type_code	 VARCHAR2 (1);
  BEGIN
    IF (p_xtd = 'MTD')
    THEN
      l_period_type_code    := 'p';
    ELSIF (p_xtd = 'QTD')
    THEN
      l_period_type_code    := 'q';
    ELSE
      l_period_type_code    := 'y';
    END IF;

    RETURN l_period_type_code;
  END get_period_type_code;

FUNCTION get_where_clauses (
    p_dim_map				 poa_dbi_util_pkg.poa_dbi_dim_map
  , p_trend			IN	 VARCHAR2
  , p_view_by       IN   VARCHAR2
  , p_mv_set        IN VARCHAR2)
    RETURN VARCHAR2
  IS
    l_where_clause   VARCHAR2 (4000);
    i		     VARCHAR2 (100);
    l_ou_flag   NUMBER;
    l_cc_flag   NUMBER;
    l_pc_flag   NUMBER;
    l_45        BOOLEAN;
    cc_flag     VARCHAR2(200);
  BEGIN
    l_45        := FALSE;
    l_ou_flag   := 1;
    l_cc_flag   := 0;
    l_pc_flag   := 1;

    i	        := p_dim_map.FIRST;			   -- get subscript of first element
--    DBMS_OUTPUT.put_line ('i : [' || i || ']');

    WHILE i IS NOT NULL
    LOOP
--insert into debug values ('test 0 - '||i,sysdate);commit;
--      IF (   p_dim_map (i).VALUE IS NULL
--	  OR p_dim_map (i).VALUE = ''
--	  OR p_dim_map (i).VALUE = 'All')
      IF (p_dim_map (i).VALUE = 'All')
      THEN NULL;
/* Added by OKI */
--------------------------------------------------------------------------------
      ELSIF i = g_sales_grp_dim
      THEN NULL;
--------------------------------------------------------------------------------
      ELSIF (p_trend = 'Y')
      THEN
	l_where_clause	  := l_where_clause || ' and (fact.' || p_dim_map (i).col_name || ' is null or fact.' || p_dim_map (i).col_name || ' in (&' || i || ')) ';
      ELSE
	l_where_clause	  := l_where_clause || ' and fact.' || p_dim_map (i).col_name || ' in (&' || i || ') ';
      END IF;
-- start addition by blindaue
--insert into debug values ('p_dim_map(i).view_by_table: '|| p_dim_map(i).view_by_table,sysdate);commit;

      IF (  p_view_by = 'ORGANIZATION+FII_OPERATING_UNITS'
          OR (p_dim_map(i).view_by_table = '(select organization_id id, name value from hr_all_organization_units_tl where language = userenv(''LANG''))' AND p_dim_map(i).value <> 'All'))
      THEN l_ou_flag := 0;
      ELSE NULL;
      END IF;

      IF ( p_view_by  = 'FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS'
          OR (p_dim_map(i).view_by_table = 'FII_PARTNER_MKT_CLASS_V' AND p_dim_map(i).value <> 'All'))
      THEN l_cc_flag := 1;
      ELSE NULL;
      END IF;

--      IF (p_view_by = 'ITEM+ENI_ITEM'
--        OR p_dim_map(i).value = 'All')
--      THEN NULL;
--      ELSE

      IF (p_view_by = 'ITEM+ENI_ITEM_PROD_LEAF_CAT'
          OR (p_dim_map(i).view_by_table = 'OKI_ENI_ITEM_VBH_NODES_V' AND p_dim_map(i).value <> 'All'))
      THEN l_pc_flag := 0;
      ELSE NULL;
      END IF;
-- end addition by blindaue

      IF (p_view_by = 'ITEM+ENI_ITEM'
          OR (p_dim_map(i).view_by_table = 'ENI_ITEM_V' AND p_dim_map(i).value <> 'All'))
      THEN l_45 := true;
      END IF;

   /*
      Commented by Pushkala - Term reason and cncl reason is available in 03*_mvs.
      IF (p_view_by = 'OKI_STATUS+CNCL_REASON'
          OR (p_dim_map(i).view_by_table = 'OKI_CANCEL_STATUSES_V' AND p_dim_map(i).value <> 'All'))
      THEN l_45 := true;
      END IF;
      IF (p_view_by = 'OKI_STATUS+TERM_REASON'
          OR (p_dim_map(i).view_by_table = 'OKI_TERM_REASONS_V' AND p_dim_map(i).value <> 'All'))
      THEN l_45 := true;
      END IF;
      */
      i := p_dim_map.NEXT (i);
    END LOOP;


   IF (p_mv_set in ('SRM_ST_71','SRM_TM_71','SRM_EN_71','SRM_BAL','SRM_SG_71'))  then
       cc_flag := ' and fact.cc_flag <> '|| l_cc_flag;
     ELSE
       cc_flag := ' ';
     END IF;



IF p_mv_set NOT IN ('SRM_TBK_RPT','SRM_LATE_BKING') THEN
  /* Pushkala :  Changed the section - for reports using the new views */
    IF not l_45
    THEN l_where_clause := l_where_clause
                    || ' and fact.pc_flag = '|| l_pc_flag;
    ELSE
     l_where_clause := l_where_clause|| cc_flag;
    END IF;
END IF;

    RETURN l_where_clause;
  END get_where_clauses;

  PROCEDURE add_join_table (
    p_join_tbl			IN OUT NOCOPY  poa_dbi_util_pkg.poa_dbi_join_tbl
  , p_column_name		IN	 VARCHAR2
  , p_table_name		IN	 VARCHAR2
  , p_table_alias		IN	 VARCHAR2
  , p_fact_column		IN	 VARCHAR2
  , p_dim_outer_join		IN	 VARCHAR2 := 'N'
  , p_additional_where_clause	IN	 VARCHAR2)
  IS
    l_join_tbl_rec   poa_dbi_util_pkg.poa_dbi_join_rec;
  BEGIN
    l_join_tbl_rec.column_name		      := p_column_name;
    l_join_tbl_rec.table_name		      := p_table_name;
    l_join_tbl_rec.table_alias		      := p_table_alias;
    l_join_tbl_rec.fact_column		      := p_fact_column;
    l_join_tbl_rec.dim_outer_join	      := p_dim_outer_join;
    l_join_tbl_rec.additional_where_clause    := p_additional_where_clause;
    p_join_tbl.EXTEND;
    p_join_tbl (p_join_tbl.COUNT)	      := l_join_tbl_rec;
  END;

  PROCEDURE join_rpt_where (
    p_join_tbl			IN OUT NOCOPY  poa_dbi_util_pkg.poa_dbi_join_tbl
  , p_func_area 		IN	 VARCHAR2
  , p_version			IN	 VARCHAR2
  , p_role			IN	 VARCHAR2
  , p_mv_set			IN	 VARCHAR2)
  IS
    l_join_tbl	 poa_dbi_util_pkg.poa_dbi_join_tbl;
  BEGIN
    l_join_tbl	  := p_join_tbl;

    IF (    p_func_area = 'SRM_CUST' )
    THEN
      add_join_table (p_join_tbl		   => p_join_tbl
		    , p_column_name		   => 'id'
		    , p_table_name		   => 'fii_customers_v'
		    , p_table_alias		   => 'cust'
		    , p_fact_column		   => 'customer_party_id'
		    , p_additional_where_clause    => NULL);
    ELSIF ( p_mv_set IN('SRM_DTL_RPT'))
    THEN

      add_join_table (p_join_tbl		   => p_join_tbl
		    , p_column_name		   => 'chr_id'
		    , p_table_name		   => 'OKI_SCM_OCR_MV'
		    , p_table_alias		   => 'k'
		    , p_fact_column		   => 'chr_id'
		    , p_additional_where_clause    => NULL);
      add_join_table (p_join_tbl		   => p_join_tbl
		    , p_column_name		   => 'id'
		    , p_table_name		   => 'fii_customers_v'
		    , p_table_alias		   => 'cust'
		    , p_fact_column		   => 'customer_party_id'
		    , p_additional_where_clause    => NULL);
      add_join_table (p_join_tbl		   => p_join_tbl
		    , p_column_name		   => 'resource_id'
		    , p_table_name		   => 'jtf_rs_resource_extns_vl'
		    , p_table_alias		   => 'rsex'
		    , p_fact_column		   => 'resource_id'
		    , p_dim_outer_join		   => 'Y'
		    , p_additional_where_clause    => NULL);
    ELSIF (p_mv_set in ('SRM_TBK_RPT','SRM_CDTL_RPT')) THEN
    --Pushkala : 71 changes
      add_join_table (p_join_tbl		   => p_join_tbl
		    , p_column_name		   => 'id'
		    , p_table_name		   => 'fii_customers_v'
		    , p_table_alias		   => 'cust'
		    , p_fact_column		   => 'customer_party_id'
		    , p_additional_where_clause    => NULL);
      add_join_table (p_join_tbl		   => p_join_tbl
		    , p_column_name		   => 'resource_id'
		    , p_table_name		   => 'jtf_rs_resource_extns_vl'
		    , p_table_alias		   => 'rsex'
		    , p_fact_column		   => 'resource_id'
		    , p_dim_outer_join		   => 'Y'
		    , p_additional_where_clause    => NULL);

    ELSIF (    p_func_area = 'SRM'
     AND p_version = ('6.0'))
    THEN
      add_join_table (p_join_tbl		   => p_join_tbl
		    , p_column_name		   => 'chr_id'
		    , p_table_name		   => 'oki_scm_000_mv'
		    , p_table_alias		   => 'k'
		    , p_fact_column		   => 'chr_id'
		    , p_additional_where_clause    => NULL);
      add_join_table (p_join_tbl		   => p_join_tbl
		    , p_column_name		   => 'id'
		    , p_table_name		   => 'fii_customers_v'
		    , p_table_alias		   => 'cust'
		    , p_fact_column		   => 'customer_party_id'
		    , p_additional_where_clause    => NULL);
      add_join_table (p_join_tbl		   => p_join_tbl
		    , p_column_name		   => 'resource_id'
		    , p_table_name		   => 'jtf_rs_resource_extns_vl'
		    , p_table_alias		   => 'rsex'
		    , p_fact_column		   => 'resource_id'
		    , p_dim_outer_join		   => 'Y'
		    , p_additional_where_clause    => NULL);
    END IF;
  END join_rpt_where;

  FUNCTION add_measures (
    measure1			IN	 VARCHAR2
  , measure2			IN	 VARCHAR2)
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN ' NVL2( COALESCE(' || measure1 || ',' || measure2 || ') ,(NVL(' || measure1 || ',0)+NVL(' || measure2 || ',0)),NULL )';

  END add_measures;

  FUNCTION subtract_measures (
    measure1			IN	 VARCHAR2
  , measure2			IN	 VARCHAR2)
    RETURN VARCHAR2
  IS
  BEGIN
    RETURN ' NVL2( COALESCE(' || measure1 || ',' || measure2 || ') ,(NVL(' || measure1 || ',0)-NVL(' || measure2 || ',0)),NULL )';

  END subtract_measures;

  PROCEDURE get_bind_vars (
    x_custom_output		IN OUT NOCOPY bis_query_attributes_tbl)
  IS
    l_custom_rec   bis_query_attributes;
  BEGIN
    l_custom_rec			       := bis_pmv_parameters_pub.initialize_query_type;
    -- Unassigned bind variable
    fnd_message.set_name (application	 => 'BIS'
			, NAME		 => 'EDW_UNASSIGNED');
    l_custom_rec.attribute_name 	       := '&UNASSIGNED';
    l_custom_rec.attribute_value	       := fnd_message.get;
    l_custom_rec.attribute_type 	       := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type	       := bis_pmv_parameters_pub.varchar2_bind;
    x_custom_output.EXTEND;
    x_custom_output (x_custom_output.COUNT)    := l_custom_rec;
    -- Direct Report bind variable
    fnd_message.set_name (application	 => 'BIS'
			, NAME		 => 'BIS_PMF_DIRECT_REP');
    l_custom_rec.attribute_name 	       := '&DIRECT_REPORT';
    l_custom_rec.attribute_value	       := fnd_message.get;
    l_custom_rec.attribute_type 	       := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type	       := bis_pmv_parameters_pub.varchar2_bind;
    x_custom_output.EXTEND;
    x_custom_output (x_custom_output.COUNT)    := l_custom_rec;

    l_custom_rec.attribute_name 	       := '&YTD_NESTED_PATTERN';
    l_custom_rec.attribute_value	       := 119;
    l_custom_rec.attribute_type 	       := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type	       := bis_pmv_parameters_pub.integer_bind;
    x_custom_output.EXTEND;
    x_custom_output (x_custom_output.COUNT)    := l_custom_rec;

    l_custom_rec.attribute_name 	       := '&OKI_RG';
    l_custom_rec.attribute_value	       := g_rs_group_id;
    l_custom_rec.attribute_type 	       := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type	       := bis_pmv_parameters_pub.integer_bind;
    x_custom_output.EXTEND;
    x_custom_output (x_custom_output.COUNT)    := l_custom_rec;
    l_custom_rec.attribute_name 	       := '&OKI_RS';
    l_custom_rec.attribute_value	       := g_resource_id;
    l_custom_rec.attribute_type 	       := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type	       := bis_pmv_parameters_pub.integer_bind;
    x_custom_output.EXTEND;
    x_custom_output (x_custom_output.COUNT)    := l_custom_rec;

    l_custom_rec.attribute_name                := '&SITEM_ID';
    l_custom_rec.attribute_value               := g_itemid;
    l_custom_rec.attribute_type                := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type           := bis_pmv_parameters_pub.integer_bind;
    x_custom_output.EXTEND;
    x_custom_output (x_custom_output.COUNT)    := l_custom_rec;
    l_custom_rec.attribute_name                := '&INV_ORGID';
    l_custom_rec.attribute_value               := g_invorgid ;
    l_custom_rec.attribute_type                := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type           := bis_pmv_parameters_pub.integer_bind;
    x_custom_output.EXTEND;
    x_custom_output (x_custom_output.COUNT)    := l_custom_rec;

  END get_bind_vars;

  PROCEDURE get_custom_trend_binds (
    p_xtd			IN	 VARCHAR2
  , p_comparison_type		IN	 VARCHAR2
  , x_custom_output		OUT NOCOPY bis_query_attributes_tbl)
  IS
    l_custom_rec   bis_query_attributes;
  BEGIN
    -- get binds that are common across applications
    poa_dbi_util_pkg.get_custom_trend_binds (p_xtd		  => p_xtd
					   , p_comparison_type	  => p_comparison_type
					   , x_custom_output	  => x_custom_output);
    -- get binds that are specific to OKI
    get_bind_vars (x_custom_output    => x_custom_output);
  END get_custom_trend_binds;

  PROCEDURE get_custom_status_binds (
    x_custom_output		OUT NOCOPY bis_query_attributes_tbl)
  IS
    l_custom_rec   bis_query_attributes;
  BEGIN
    -- get binds that are common across applications
    poa_dbi_util_pkg.get_custom_status_binds (x_custom_output	 => x_custom_output);
    -- get binds that are specific to OKI
    get_bind_vars (x_custom_output    => x_custom_output);
  END get_custom_status_binds;


  PROCEDURE get_bis_bucket_binds (
    x_custom_output		IN OUT NOCOPY bis_query_attributes_tbl,
    x_bis_bucket		IN bis_bucket_pub.BIS_BUCKET_REC_TYPE)
  IS
      l_custom_rec   bis_query_attributes;
  BEGIN
    l_custom_rec			       := bis_pmv_parameters_pub.initialize_query_type;

    l_custom_rec.attribute_name 	       := '&RANGE1_NAME';
    l_custom_rec.attribute_value	       := x_bis_bucket.range1_name;
    l_custom_rec.attribute_type 	       := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type	       := bis_pmv_parameters_pub.varchar2_bind;
    x_custom_output.EXTEND;
    x_custom_output (x_custom_output.COUNT)    := l_custom_rec;

    l_custom_rec.attribute_name 	       := '&RANGE2_NAME';
    l_custom_rec.attribute_value	       := x_bis_bucket.range2_name;
    l_custom_rec.attribute_type 	       := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type	       := bis_pmv_parameters_pub.varchar2_bind;
    x_custom_output.EXTEND;
    x_custom_output (x_custom_output.COUNT)    := l_custom_rec;

    l_custom_rec.attribute_name 	       := '&RANGE3_NAME';
    l_custom_rec.attribute_value	       := x_bis_bucket.range3_name;
    l_custom_rec.attribute_type 	       := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type	       := bis_pmv_parameters_pub.varchar2_bind;
    x_custom_output.EXTEND;
    x_custom_output (x_custom_output.COUNT)    := l_custom_rec;

    l_custom_rec.attribute_name 	       := '&RANGE4_NAME';
    l_custom_rec.attribute_value	       := x_bis_bucket.range4_name;
    l_custom_rec.attribute_type 	       := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type	       := bis_pmv_parameters_pub.varchar2_bind;
    x_custom_output.EXTEND;
    x_custom_output (x_custom_output.COUNT)    := l_custom_rec;

    l_custom_rec.attribute_name 	       := '&RANGE5_NAME';
    l_custom_rec.attribute_value	       := x_bis_bucket.range5_name;
    l_custom_rec.attribute_type 	       := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type	       := bis_pmv_parameters_pub.varchar2_bind;
    x_custom_output.EXTEND;
    x_custom_output (x_custom_output.COUNT)    := l_custom_rec;

    l_custom_rec.attribute_name 	       := '&RANGE6_NAME';
    l_custom_rec.attribute_value	       := x_bis_bucket.range6_name;
    l_custom_rec.attribute_type 	       := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type	       := bis_pmv_parameters_pub.varchar2_bind;
    x_custom_output.EXTEND;
    x_custom_output (x_custom_output.COUNT)    := l_custom_rec;

    l_custom_rec.attribute_name 	       := '&RANGE7_NAME';
    l_custom_rec.attribute_value	       := x_bis_bucket.range7_name;
    l_custom_rec.attribute_type 	       := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type	       := bis_pmv_parameters_pub.varchar2_bind;
    x_custom_output.EXTEND;
    x_custom_output (x_custom_output.COUNT)    := l_custom_rec;

    l_custom_rec.attribute_name 	       := '&RANGE8_NAME';
    l_custom_rec.attribute_value	       := x_bis_bucket.range8_name;
    l_custom_rec.attribute_type 	       := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type	       := bis_pmv_parameters_pub.varchar2_bind;
    x_custom_output.EXTEND;
    x_custom_output (x_custom_output.COUNT)    := l_custom_rec;

    l_custom_rec.attribute_name 	       := '&RANGE9_NAME';
    l_custom_rec.attribute_value	       := x_bis_bucket.range9_name;
    l_custom_rec.attribute_type 	       := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type	       := bis_pmv_parameters_pub.varchar2_bind;
    x_custom_output.EXTEND;
    x_custom_output (x_custom_output.COUNT)    := l_custom_rec;

    l_custom_rec.attribute_name 	       := '&RANGE10_NAME';
    l_custom_rec.attribute_value	       := x_bis_bucket.range10_name;
    l_custom_rec.attribute_type 	       := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type	       := bis_pmv_parameters_pub.varchar2_bind;
    x_custom_output.EXTEND;
    x_custom_output (x_custom_output.COUNT)    := l_custom_rec;

  END get_bis_bucket_binds;


  FUNCTION get_default_portlet_param (
    p_region_code		IN	 VARCHAR2)
    RETURN VARCHAR2
  IS
    l_params   VARCHAR2 (500);
  --  l_sg_id	VARCHAR(30);
  BEGIN

   -- l_sg_id := get_sg_id;

    IF (p_region_code = 'OKI_DBI_SRG_PARAM')
    THEN
      l_params	  := '&SEQUENTIAL=TIME_COMPARISON_TYPE+SEQUENTIAL&FII_TIME_ENT_PERIOD_FROM=All&FII_TIME_ENT_PERIOD_TO=All&FII_CURRENCIES=FII_GLOBAL1&JTF_ORG_SALES_GROUP='||get_sg_id;

    END IF;

    RETURN l_params;
  END get_default_portlet_param;

  FUNCTION get_view_by (
    p_param			IN	 bis_pmv_page_parameter_tbl)
    RETURN VARCHAR2
  IS
    p_view_by	VARCHAR2 (100);
  BEGIN
    FOR i IN 1 .. p_param.COUNT
    LOOP
      IF (p_param (i).parameter_name = 'VIEW_BY')
      THEN
	p_view_by    := p_param (i).parameter_value;
      END IF;
    END LOOP;

    RETURN p_view_by;
  END get_view_by;

  FUNCTION get_param_id (
    p_param			IN	 bis_pmv_page_parameter_tbl
  , p_param_name		IN	 VARCHAR2)
    RETURN VARCHAR2
  IS
    p_param_id	 VARCHAR2 (100);
  BEGIN
    FOR i IN 1 .. p_param.COUNT
    LOOP
      IF (p_param (i).parameter_name = p_param_name)
      THEN
	p_param_id    := p_param (i).parameter_id;
      END IF;
    END LOOP;

    RETURN p_param_id;
  END get_param_id;


  PROCEDURE split_pseudo_rs_group (
    p_param			IN	 bis_pmv_page_parameter_tbl)
  IS
    l_pseudo_rs_group	VARCHAR2 (200);
    l_sep		NUMBER;
  BEGIN
      g_rs_group_id    := NULL;
      g_resource_id    := NULL;

    l_pseudo_rs_group	 := get_param_id (p_param
					, 'ORGANIZATION+JTF_ORG_SALES_GROUP');
    l_pseudo_rs_group	 := REPLACE (l_pseudo_rs_group
				   , '''');
    COMMIT;

    IF (l_pseudo_rs_group = '-1111')
    THEN
      g_rs_group_id    := -1111;
      g_resource_id    := NULL;
    ELSE
      l_sep    := INSTR (l_pseudo_rs_group
		       , '.');
      IF (l_sep > 0)
      THEN
	g_resource_id	 := TO_NUMBER (SUBSTR (l_pseudo_rs_group
					     , 0
					     , l_sep-1 ));
	g_rs_group_id	 := TO_NUMBER (SUBSTR (l_pseudo_rs_group
					     , l_sep + 1));
      ELSE
	g_rs_group_id	 := TO_NUMBER (l_pseudo_rs_group);
	g_resource_id	 := NULL;
      END IF;
    END IF;

    COMMIT;
  END split_pseudo_rs_group;

  FUNCTION  two_way_join ( sel_clause  VARCHAR2,
			    query1 VARCHAR2,
			    query2 varchar2,
			    join_column1 varchar2,
			    join_column2 varchar2)
   return varchar2 IS
   BEGIN
      return
	'select '||join_column1||
	' , '||sel_clause ||
	' from ( ( '|| query1 ||' )  UNION ALL ('|| query2 ||' )  )'||
	' GROUP BY '||join_column1;
   END two_way_join;

  FUNCTION get_sg_id RETURN VARCHAR2 IS
     l_sg_id  VARCHAR2(100);
  BEGIN

   SELECT id
   INTO   l_sg_id
   FROM
   (
     SELECT id, rank() over (order by value nulls last) rnk
     FROM   jtf_rs_dbi_res_grp_vl
     WHERE  usage = 'SALES'
     AND    current_id = -1111
     AND    denorm_level = 0
   )
   where rnk = 1;

   RETURN l_sg_id;

   EXCEPTION
      WHEN OTHERS THEN
	 RETURN -1111;
  END get_sg_id;

FUNCTION change_clause(cur_col IN VARCHAR2, prior_col IN VARCHAR2, change_type IN VARCHAR2 := 'NP', prod in VARCHAR2 := 'OKI')
RETURN VARCHAR2
IS

BEGIN

  if (prod = 'OKI') then
    if(change_type = 'NP') then  -- measure is AMT
       return '(((' || cur_col || ' - ' || prior_col ||
	      ')/abs(decode(' || prior_col ||  ',0,null,'|| prior_col
	      || '))) * 100)';
      else
	 return '(' || cur_col || ' - ' || prior_col || ')';	 -- rate or ratio
    end if;

  else
   -- old POA change code
   return '(((nvl(' || cur_col || ',0) - ' || prior_col ||
	      ')/abs(decode(' || prior_col ||  ',0,null,'
	      || prior_col
	      || '))) * 100)';

   end if;

-- if CHANGE IS A RATE OR RATIO  then check if prior and current exists..
  /* return 'NVL2(coalesce(' || cur_col || ', ' || prior_col || ')' ||
	  ',(nvl(' || cur_col || ',0) - nvl(' || prior_col || ',0) )' ||
	  ', NULL)';	 -- NEW CODE
  */
END change_clause;

END oki_dbi_util_pvt;

/
