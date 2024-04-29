--------------------------------------------------------
--  DDL for Package Body JG_ZZ_VAT_YEARLY_EXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JG_ZZ_VAT_YEARLY_EXT_PKG" 
-- $Header: jgzzyexrb.pls 120.0.12010000.2 2009/04/29 05:41:00 rapulla noship $
  --*************************************************************************
  -- Copyright (c)  2000    Oracle                 Product Development
  -- All rights reserved
  --*************************************************************************

  -- HEADER
  -- Source control header

  -- PROGRAM NAME
  -- jgzzyexrb.pls

  -- DESCRIPTION
  -- This script creates the package specification of JG_ZZ_VAT_YEARLY_EXT_PKG
  -- This package body is used to report on EMEA VAT: Yearly Extract Report.

  -- USAGE
  -- To install       sqlplus <apps_user>/<apps_pwd> @jgzzyexrb.pls
  -- To execute       sqlplus <apps_user>/<apps_pwd> JG_ZZ_VAT_YEARLY_EXT_PKG

  -- PROGRAM LIST                              DESCRIPTION
  -- beforeReport                              This Function is used to dynamically get the values for the Lexical References used in the Query of the Data template.

  -- DEPENDENCIES
  -- None

  -- CALLED BY
  -- EMEA VAT: Yearly Extract Report.

  -- LAST UPDATE DATE   20-Oct-2008
  -- Date the program has been modified for the last time

  -- HISTORY
  -- =======

  -- VERSION DATE        AUTHOR(S)       DESCRIPTION
  -- ------- ----------- --------------- ------------------------------------
  -- Draft1A 20-Oct-2008 Rakesh Pulla     Initial Creation
  --************************************************************************
  AS
  FUNCTION beforeReport RETURN BOOLEAN IS

   CURSOR c_vat_period(ln_reporting_entity_id IN NUMBER, ln_tax_cal_year IN NUMBER) IS
  SELECT DISTINCT jgvrs.source source
  FROM jg_zz_vat_rep_entities jgvre
       ,jg_zz_vat_rep_status jgvrs
  WHERE jgvrs.vat_reporting_entity_id = jgvre.vat_reporting_entity_id
   AND jgvre.vat_reporting_entity_id = ln_reporting_entity_id
   AND jgvrs.final_reporting_status_flag = 'S'
  AND jgvrs.tax_calendar_year = ln_tax_cal_year
  ORDER BY jgvrs.source;

  CURSOR c_vat_act_period(lc_tax_cal_name IN VARCHAR2,lc_source IN VARCHAR2, ln_reporting_entity_id IN NUMBER,
                          ln_tax_cal_year IN NUMBER ) IS
  SELECT glp.period_name period_name
  FROM gl_periods glp
  WHERE glp.period_year = ln_tax_cal_year
   AND glp.period_set_name = lc_tax_cal_name
   AND glp.period_name NOT IN
    (SELECT jgvrs.tax_calendar_period period_name
     FROM jg_zz_vat_rep_entities jgvre,
          jg_zz_vat_rep_status jgvrs
     WHERE jgvrs.vat_reporting_entity_id = jgvre.vat_reporting_entity_id
     AND jgvre.vat_reporting_entity_id = ln_reporting_entity_id
     AND jgvrs.final_reporting_status_flag = 'S'
     AND jgvrs.source = lc_source
     AND jgvrs.tax_calendar_year = ln_tax_cal_year)
ORDER BY glp.period_name;

  CURSOR c_tax_calendar_name IS
  SELECT DISTINCT jgvrs.tax_calendar_name
    FROM jg_zz_vat_rep_status jgvrs
    WHERE jgvrs.vat_reporting_entity_id = p_reporting_entity_id
     AND jgvrs.tax_calendar_year = p_tax_calendar_year;

  lc_final_not_run     VARCHAR2(150);
  lc_final_run         VARCHAR2(300);
  lc_tax_calendar_name VARCHAR2(30);
  ln_count             NUMBER;

  BEGIN
    -- Begining of the Function  beforereport
    OPEN c_tax_calendar_name;
	LOOP
	   FETCH c_tax_calendar_name INTO lc_tax_calendar_name;
	   EXIT WHEN c_tax_calendar_name%NOTFOUND;
	END LOOP;
	CLOSE c_tax_calendar_name;

    FOR i IN c_vat_period(p_reporting_entity_id, p_tax_calendar_year) LOOP
	        ln_count := 1;
      FOR j IN c_vat_act_period(lc_tax_calendar_name, i.source, p_reporting_entity_id
	                            ,p_tax_calendar_year ) LOOP
			IF ln_count = 1 THEN
			  lc_final_not_run:= FND_MESSAGE.get_string('JG','JG_ZZ_FINAL_REPORTING_NOTRUN');
              FND_FILE.put_line(FND_FILE.log,lc_final_not_run || i.source);
			END IF;
              FND_FILE.put_line(FND_FILE.log, j.period_name);
		      GN_RETURN_CODE := 1;
              ln_count:= ln_count + 1;
      END LOOP;

	  lc_final_run := FND_MESSAGE.get_string('JG','JG_ZZ_FINAL_REPORTING_RUN');
      FND_FILE.PUT_LINE(FND_FILE.log, lc_final_run);

    END LOOP;

    RETURN(TRUE);
  END beforeReport;
  -- End of the beforereport

   FUNCTION afterReport RETURN BOOLEAN IS
   ln_request_id NUMBER;
   l_temp        BOOLEAN;

   BEGIN

    MO_GLOBAL.init('JG');
    ln_request_id := FND_GLOBAL.conc_request_id ;

	 IF GN_RETURN_CODE = 1 THEN
        l_temp := FND_CONCURRENT.set_completion_status
                     (status    => 'WARNING'
                     ,message   => NULL);

     END IF;
      RETURN(TRUE);
  END afterReport;
  -- End of the afterReport

END JG_ZZ_VAT_YEARLY_EXT_PKG;

/
