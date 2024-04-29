--------------------------------------------------------
--  DDL for Package Body PAY_MX_ISR_FORMAT37_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MX_ISR_FORMAT37_INFO" as
/* $Header: paymxformat37dt.pkb 120.19.12010000.6 2010/01/15 12:26:22 sjawid ship $ */

   g_package            CONSTANT VARCHAR2(33) := 'pay_mx_isr_format37_info.';

   -- flag to write the debug messages in the concurrent program log file
   g_concurrent_flag      VARCHAR2(1)  ;
   -- flag to write the debug messages in the trace file
   g_debug_flag           VARCHAR2(1)  ;


  /******************************************************************************
   Name      : msg
   Purpose   : Log a message, either using fnd_file, or hr_utility.trace
  ******************************************************************************/

  PROCEDURE msg(p_text  VARCHAR2)
  IS
  --
  BEGIN
    -- Write to the concurrent request log
    fnd_file.put_line(fnd_file.log, p_text);

  END msg;

  /******************************************************************************
   Name      : dbg
   Purpose   : Log a message, either using fnd_file, or hr_utility.trace
               if debuggging is enabled
  ******************************************************************************/
  PROCEDURE dbg(p_text  VARCHAR2) IS

  BEGIN

   IF (g_debug_flag = 'Y') THEN
     IF (g_concurrent_flag = 'Y') THEN
        -- Write to the concurrent request log
        fnd_file.put_line(fnd_file.log, p_text);
     ELSE
         -- Use HR trace
         hr_utility.trace(p_text);
     END IF;
   END IF;

  END dbg;

  /****************************************************************************
    Name        : write_to_magtape_lob
    Description : This procedure appends passed BLOB parameter to
                  pay_mag_tape.g_blob_value
  *****************************************************************************/

  PROCEDURE write_to_magtape_lob(p_blob BLOB) IS
  BEGIN
      IF  dbms_lob.getLength (p_blob) IS NOT NULL THEN
          pay_core_files.write_to_magtape_lob (p_blob);
      END IF;
  END write_to_magtape_lob;


  /****************************************************************************
    Name        : write_to_magtape_lob
    Description : This procedure appends passed varchar2 parameter to
                  pay_mag_tape.g_blob_value
  *****************************************************************************/

  PROCEDURE write_to_magtape_lob(p_data varchar2) IS
  BEGIN
        pay_core_files.write_to_magtape_lob (p_data);
  END write_to_magtape_lob;


  /******************************************************************
  Name      : create_xml_string
  Purpose   : creates a xmlstring from the plsql table values
              and returns as a BLOB
  ******************************************************************/
  FUNCTION create_xml_string (p_arch_payroll_action_id NUMBER,
                                 p_arch_person_id        NUMBER,
                                 p_legal_employer_id     NUMBER,
                                 p_year                  NUMBER,
                                 p_pai_eff_date          DATE  )
    RETURN CLOB IS

      l_xml_query  VARCHAR2(32000);
      l_xml_ctx    dbms_xmlquery.ctxType;

      l_xml_clob   CLOB;

      is_temp varchar2(10);

   BEGIN


    dbg('*********************' );
    dbg('In create_xml_string ' );
    dbg('*********************' );

    l_xml_query := 'select
         to_char(fnd_date.canonical_to_date(start_month),''mm'') START_MONTH,
         to_char(fnd_date.canonical_to_date(end_month),''mm'')   END_MONTH,
         FISCAL_YEAR_REPORTING             ,
         replace(RFC_ID,''-'','''')  RFC_ID,
         CURP                              ,
         UPPER(PATERNAL_LAST_NAME)   PATERNAL_LAST_NAME ,
         UPPER(MATERNAL_LAST_NAME)   MATERNAL_LAST_NAME ,
         UPPER(NAMES)                NAMES,
         upper(ltrim(rtrim(PATERNAL_LAST_NAME)) ||'' ''||
               ltrim(rtrim(MATERNAL_LAST_NAME)) ||'' ''||
               ltrim(rtrim(NAMES)))   FULL_NAME,
         NVl(ANNUAL_TAX_CALC_FLAG,''N'') ANNUAL_TAX_CALC_FLAG,
         NVL(ANNUAL_TAX_CALC_FLAG,''N'') ANNUAL_TAX_CALC_FLAG_Y,
         NVL(ANNUAL_TAX_CALC_FLAG,''N'') ANNUAL_TAX_CALC_FLAG_N,
         RATE_1991_IND,
         RATE_FISCAL_YEAR_IND REPORT_FOR_FY_OR_1991,
         UNION_WORKER_FLAG                 ,
         ECONOMIC_ZONE                     ,
         STATE_ID                          ,
         TAX_SUBSIDY_PCT                   ,
         decode(nvl(RATE_FISCAL_YEAR_IND,0),0,null, 2, null,
                trunc(to_number(tax_subsidy_pct),0)) TAX_SUBSIDY_PCT_I,
         decode(nvl(RATE_FISCAL_YEAR_IND,0),0,null, 2, null,
                rpad(replace(to_number(tax_subsidy_pct) -
                trunc(to_number(tax_subsidy_pct),0),''.'',''''),4,0))
                                                          TAX_SUBSIDY_PCT_D,
         SUBSIDY_PORTION_APPLIED,
	 decode(nvl(RATE_1991_IND,0),0,null,2,null,
                   trunc(to_number(tax_subsidy_pct),0)) TAX_SUBSIDY_PCT_1991_I,
	 decode(nvl(RATE_1991_IND,0),0,null,2,null,
                    rpad(replace(to_number(tax_subsidy_pct) -
                    trunc(to_number(tax_subsidy_pct),0),''.'',''''),
                                             4,0)) TAX_SUBSIDY_PCT_1991_D,
	 decode(nvl(replace(OTHER_ER_RFC1,''-'',''''),''0''),''0'',null,
	        trunc(to_number(subsidy_portion_applied),''0''))
                                                   SUBSIDY_PORTION_APPLIED_I,
         decode(nvl(replace(OTHER_ER_RFC1,''-'',''''),''0''),''0'',null,
	            rpad(replace(to_number(subsidy_portion_applied) -
                    trunc(to_number(subsidy_portion_applied),''0''),
                    ''.'',''''),4,''0'')) SUBSIDY_PORTION_APPLIED_D,
         replace(OTHER_ER_RFC1,''-'','''')       OTHER_ER_RFC1 ,
         replace(OTHER_ER_RFC2,''-'','''')       OTHER_ER_RFC2 ,
         replace(OTHER_ER_RFC3,''-'','''')       OTHER_ER_RFC3 ,
         replace(OTHER_ER_RFC4,''-'','''')       OTHER_ER_RFC4 ,
         replace(OTHER_ER_RFC5,''-'','''')       OTHER_ER_RFC5 ,
         replace(OTHER_ER_RFC6,''-'','''')       OTHER_ER_RFC6 ,
         replace(OTHER_ER_RFC7,''-'','''')       OTHER_ER_RFC7 ,
         replace(OTHER_ER_RFC8,''-'','''')       OTHER_ER_RFC8 ,
         replace(OTHER_ER_RFC9,''-'','''')       OTHER_ER_RFC9 ,
         replace(OTHER_ER_RFC10,''-'','''')      OTHER_ER_RFC10,
         /*Bug#:9171641: New balances. */
         decode(VOLUNTARY_CONTRIBUTIONS_ER,0,VOLUNTARY_CONTRIBUTIONS_EE,0) VOLUNTARY_CONTRIBUTIONS_EE,
         VOLUNTARY_CONTRIBUTIONS_ER,
         VOLUNTARY_CONTRIBUTIONS_TOTAL,
         TOT_DED_VOL_CONTRIBUTION,
         Decode(VOLUNTARY_CONTRIBUTIONS_ER,0,decode(VOLUNTARY_CONTRIBUTIONS_EE,0,0,2),1) ER_VOL_CONTR_FLAG,
         /*Bug#:9171641: */
         TOT_EARNING_ASSI_CONCEPTS               TOT_EARNING_ASSI_CONCEPTS,
         EMPLOYEE_STATE_TAX_WITHHELD             EMPLOYEE_STATE_TAX_WITHHELD,
         TOT_EXEMPT_EARNINGS                     TOT_EXEMPT_EARNINGS,
         TOT_NON_CUMULATIVE_EARNINGS             TOT_NON_CUMULATIVE_EARNINGS,
         TOT_CUMULATIVE_EARNINGS                 TOT_CUMULATIVE_EARNINGS,
         decode(ANNUAL_TAX_CALC_FLAG, ''Y'', ISR_CALCULATED, 0) ISR_CALCULATED,
         ISR_CREDITABLE_SUBSIDY                  ISR_CREDITABLE_SUBSIDY,
         ISR_NON_CREDITABLE_SUBSIDY              ISR_NON_CREDITABLE_SUBSIDY,
	 nvl(ISR_SUBSIDY_FOR_EMP,0)              ISR_SUBSIDY_FOR_EMPLOYMENT,
         nvl(ISR_SUBSIDY_FOR_EMP_PAID,0)         ISR_SUBSIDY_FOR_EMP_PAID,
         CREDITABLE_SUBSIDY_FRACTIONIII          CREDITABLE_SUBSIDY_FRACTIONIII,
         CREDITABLE_SUBSIDY_FRACTIONIV           CREDITABLE_SUBSIDY_FRACTIONIV,
         decode( ANNUAL_TAX_CALC_FLAG , ''Y'',
                ISR_ON_CUMULATIVE_EARNINGS, 0)   ISR_ON_CUMULATIVE_EARNINGS,
         ISR_ON_NON_CUMULATIVE_EARNINGS          ISR_ON_NON_CUMULATIVE_EARNINGS,
         decode( ANNUAL_TAX_CALC_FLAG , ''Y'',
                 TAX_ON_INCOME_FISCAL_YEAR, 0 )  TAX_ON_INCOME_FISCAL_YEAR,
         ISR_TAX_WITHHELD                        ISR_TAX_WITHHELD,
         RET_EARNINGS_IN_ONE_PYMNT               RET_EARNINGS_IN_ONE_PYMNT,
         RET_EARNINGS_IN_PART_PYMNT              RET_EARNINGS_IN_PART_PYMNT,
         RET_DAILY_EARNINGS_IN_PYMNT             RET_DAILY_EARNINGS_IN_PYMNT,
         RET_PERIOD_EARNINGS                     RET_PERIOD_EARNINGS,
         RET_EARNINGS_DAYS                       RET_EARNINGS_DAYS,
         RET_EXEMPT_EARNINGS                     RET_EXEMPT_EARNINGS,
         RET_TAXABLE_EARNINGS                    RET_TAXABLE_EARNINGS ,
         RET_CUMULATIVE_EARNINGS                 RET_CUMULATIVE_EARNINGS,
         RET_NON_CUMULATIVE_EARNINGS             RET_NON_CUMULATIVE_EARNINGS,
         ISR_WITHHELD_FOR_RET_EARNINGS           ISR_WITHHELD_FOR_RET_EARNINGS,
         AMENDS                                  AMENDS,
         SENIORITY ,
         ISR_EXEMPT_FOR_AMENDS                   ISR_EXEMPT_FOR_AMENDS,
         ISR_SUBJECT_FOR_AMENDS                  ISR_SUBJECT_FOR_AMENDS,
         LAST_MTH_ORD_SAL                        LAST_MTH_ORD_SAL,
         LAST_MTH_ORD_SAL_WITHHELD               LAST_MTH_ORD_SAL_WITHHELD,
         NON_CUMULATIVE_AMENDS                   NON_CUMULATIVE_AMENDS,
         ISR_WITHHELD_FOR_AMENDS                 ISR_WITHHELD_FOR_AMENDS,
         ASSIMILATED_EARNINGS                    ASSIMILATED_EARNINGS,
         ISR_WITHHELD_FOR_ASSI_EARNINGS          ISR_WITHHELD_FOR_ASSI_EARNINGS,
         STK_OPTIONS_VESTING_VALUE               STK_OPTIONS_VESTING_VALUE,
         STK_OPTIONS_GRANT_PRICE                 STK_OPTIONS_GRANT_PRICE,
	 decode ( sign(STK_OPTIONS_VESTING_VALUE - STK_OPTIONS_GRANT_PRICE),
                1,(STK_OPTIONS_VESTING_VALUE - STK_OPTIONS_GRANT_PRICE),0)
		                                 STK_OPTIONS_CUML_INCOME,
         STK_OPTIONS_TAX_WITHHELD                STK_OPTIONS_TAX_WITHHELD,
         ISR_EXEMPT_FOR_FIXED_EARNINGS   ISR_EXEMPT_FOR_FIXED_EARNINGS,
         ISR_SUBJECT_FOR_FIXED_EARNINGS  ISR_SUBJECT_FOR_FIXED_EARNINGS,
         ISR_EXEMPT_FOR_XMAS_BONUS       ISR_EXEMPT_FOR_XMAS_BONUS,
         ISR_SUBJECT_FOR_XMAS_BONUS      ISR_SUBJECT_FOR_XMAS_BONUS,
         ISR_EXEMPT_FOR_TRAVEL_EXP       ISR_EXEMPT_FOR_TRAVEL_EXP,
         ISR_SUBJECT_FOR_TRAVEL_EXP      ISR_SUBJECT_FOR_TRAVEL_EXP,
         ISR_EXEMPT_FOR_OVERTIME         ISR_EXEMPT_FOR_OVERTIME,
         ISR_SUBJECT_FOR_OVERTIME        ISR_SUBJECT_FOR_OVERTIME,
         ISR_EXEMPT_FOR_VAC_PREMIUM      ISR_EXEMPT_FOR_VAC_PREMIUM,
         ISR_SUBJECT_FOR_VAC_PREMIUM     ISR_SUBJECT_FOR_VAC_PREMIUM,
         ISR_EXEMPT_FOR_DOM_PREMIUM      ISR_EXEMPT_FOR_DOM_PREMIUM,
         ISR_SUBJECT_FOR_DOM_PREMIUM     ISR_SUBJECT_FOR_DOM_PREMIUM,
         ISR_EXEMPT_FOR_PROFIT_SHARING   ISR_EXEMPT_FOR_PROFIT_SHARING,
         ISR_SUBJECT_FOR_PROFIT_SHARING  ISR_SUBJECT_FOR_PROFIT_SHARING,
         ISR_EXEMPT_FOR_HEALTHCARE_REI   ISR_EXEMPT_FOR_HEALTHCARE_REI,
         ISR_SUBJECT_FOR_HEALTHCARE_REI  ISR_SUBJECT_FOR_HEALTHCARE_REI,
         ISR_EXEMPT_FOR_SAVINGS_FUND     ISR_EXEMPT_FOR_SAVINGS_FUND,
         ISR_SUBJECT_FOR_SAVINGS_FUND    ISR_SUBJECT_FOR_SAVINGS_FUND,
         ISR_EXEMPT_FOR_SAVINGS_BOX      ISR_EXEMPT_FOR_SAVINGS_BOX,
         ISR_SUBJECT_FOR_SAVINGS_BOX     ISR_SUBJECT_FOR_SAVINGS_BOX,
         ISR_EXEMPT_FOR_PANTRY_COUPONS   ISR_EXEMPT_FOR_PANTRY_COUPONS,
         ISR_SUBJECT_FOR_PANTRY_COUPONS  ISR_SUBJECT_FOR_PANTRY_COUPONS,
         ISR_EXEMPT_FOR_FUNERAL_AID      ISR_EXEMPT_FOR_FUNERAL_AID,
         ISR_SUBJECT_FOR_FUNERAL_AID     ISR_SUBJECT_FOR_FUNERAL_AID,
         ISR_EXEMPT_FOR_WR_PD_BY_ER      ISR_EXEMPT_FOR_WR_PD_BY_ER,
         ISR_SUBJECT_FOR_WR_PD_BY_ER     ISR_SUBJECT_FOR_WR_PD_BY_ER,
         ISR_EXEMPT_FOR_PUN_INCENTIVE    ISR_EXEMPT_FOR_PUN_INCENTIVE,
         ISR_SUBJECT_FOR_PUN_INCENTIVE   ISR_SUBJECT_FOR_PUN_INCENTIVE,
         ISR_EXEMPT_FOR_LIFE_INS_PRE     ISR_EXEMPT_FOR_LIFE_INS_PRE,
         ISR_SUBJECT_FOR_LIFE_INS_PRE    ISR_SUBJECT_FOR_LIFE_INS_PRE,
         ISR_EXEMPT_FOR_MAJOR_MED_INS    ISR_EXEMPT_FOR_MAJOR_MED_INS,
         ISR_SUBJECT_FOR_MAJOR_MED_INS   ISR_SUBJECT_FOR_MAJOR_MED_INS,
         ISR_EXEMPT_FOR_REST_COUPONS     ISR_EXEMPT_FOR_REST_COUPONS,
         ISR_SUBJECT_FOR_REST_COUPONS    ISR_SUBJECT_FOR_REST_COUPONS,
         ISR_EXEMPT_FOR_GAS_COUPONS      ISR_EXEMPT_FOR_GAS_COUPONS,
         ISR_SUBJECT_FOR_GAS_COUPONS     ISR_SUBJECT_FOR_GAS_COUPONS,
         ISR_EXEMPT_FOR_UNI_COUPONS      ISR_EXEMPT_FOR_UNI_COUPONS,
         ISR_SUBJECT_FOR_UNI_COUPONS     ISR_SUBJECT_FOR_UNI_COUPONS,
         ISR_EXEMPT_FOR_RENTAL_AID       ISR_EXEMPT_FOR_RENTAL_AID,
         ISR_SUBJECT_FOR_RENTAL_AID      ISR_SUBJECT_FOR_RENTAL_AID,
         ISR_EXEMPT_FOR_EDU_AID          ISR_EXEMPT_FOR_EDU_AID,
         ISR_SUBJECT_FOR_EDU_AID         ISR_SUBJECT_FOR_EDU_AID,
         ISR_SUBJECT_FOR_GLASSES_AID     ISR_SUBJECT_FOR_GLASSES_AID,
         ISR_EXEMPT_FOR_GLASSES_AID      ISR_EXEMPT_FOR_GLASSES_AID,
         ISR_EXEMPT_FOR_TRANS_AID        ISR_EXEMPT_FOR_TRANS_AID,
         ISR_SUBJECT_FOR_TRANS_AID       ISR_SUBJECT_FOR_TRANS_AID,
         ISR_EXEMPT_FOR_UNION_PD_BY_ER   ISR_EXEMPT_FOR_UNION_PD_BY_ER,
         ISR_SUBJECT_FOR_UNION_PD_BY_ER  ISR_SUBJECT_FOR_UNION_PD_BY_ER,
         ISR_EXEMPT_FOR_DISAB_SUBSIDY    ISR_EXEMPT_FOR_DISAB_SUBSIDY,
         ISR_SUBJECT_FOR_DISAB_SUBSIDY   ISR_SUBJECT_FOR_DISAB_SUBSIDY,
         ISR_EXEMPT_FOR_CHILD_SCHOLAR    ISR_EXEMPT_FOR_CHILD_SCHOLAR,
         ISR_SUBJECT_FOR_CHILD_SCHOLAR   ISR_SUBJECT_FOR_CHILD_SCHOLAR,
         decode( ANNUAL_TAX_CALC_FLAG , ''Y'',
                  NVL(PREV_ER_EARNINGS,0), 0) PREV_ER_EARNINGS,
         decode( ANNUAL_TAX_CALC_FLAG , ''Y'',
                  NVL(PREV_ER_EXEMPT_EARNINGS,0), 0) PREV_ER_EXEMPT_EARNINGS,
         ISR_SUBJECT_OTHER_INCOME        ISR_SUBJECT_OTHER_INCOME,
         ISR_EXEMPT_OTHER_INCOME         ISR_EXEMPT_OTHER_INCOME,
         TOTAL_SUBJECT_EARNINGS          TOTAL_SUBJECT_EARNINGS,
         TOTAL_EXEMPT_EARNINGS           TOTAL_EXEMPT_EARNINGS,
         (TOTAL_SUBJECT_EARNINGS + TOTAL_EXEMPT_EARNINGS) TOTAL_EARNINGS,
         TAX_WITHHELD_IN_FISCAL_YEAR     TAX_WITHHELD_IN_FISCAL_YEAR,
         decode( ANNUAL_TAX_CALC_FLAG , ''Y'',
                   NVL(PREV_ER_ISR_WITHHELD,0) , 0) PREV_ER_ISR_WITHHELD,
         --,CURRENT_FY_ARREARS
	 decode( sign (decode( ANNUAL_TAX_CALC_FLAG , ''Y'', NVL(CURRENT_FY_ARREARS,0), 0))
	         ,-1,(decode( ANNUAL_TAX_CALC_FLAG , ''Y'',NVL(CURRENT_FY_ARREARS,0), 0))* -1,0)
		 CURRENT_FY_ARREARS,
         PREV_FY_ARREARS                 PREV_FY_ARREARS,
         CREDIT_TO_SALARY                CREDIT_TO_SALARY,
         CREDIT_TO_SALARY_PAID	         CREDIT_TO_SALARY_PAID,
         SOCIAL_FORESIGHT_EARNINGS       SOCIAL_FORESIGHT_EARNINGS,
         ISR_EXEMPT_FOR_SOC_FORESIGHT    ISR_EXEMPT_FOR_SOC_FORESIGHT,
         replace(ER_RFC_ID,''-'','''')   ER_RFC_ID,
         UPPER(ER_LEGAL_NAME)            ER_LEGAL_NAME,
         UPPER(ER_LEGAL_REP_NAMES)       ER_LEGAL_REP_NAMES,
         replace(ER_LEGAL_REP_RFC_ID,''-'','''')   ER_LEGAL_REP_RFC_ID,
         ER_LEGAL_REP_CURP               ER_LEGAL_REP_CURP,
         ER_TAX_SUBSIDY_PCT              ER_TAX_SUBSIDY_PCT,
         TAX_SUBSIDY_PCT                 TAX_SUBSIDY_PCT,
         substr(pay_mx_isr_format37.get_parameter(''FOLIO_NUMBER'',
                               ppa.legislative_parameters),1,9) FOLIO_NUMBER,
         To_char(fnd_date.canonical_to_date(ltrim(rtrim(
                 pay_mx_isr_format37.get_parameter(''FOLIO_DATE'',
                               ppa.legislative_parameters)))),
		 ''DD/MM/YYYY'') FOLIO_DATE
           from pay_mx_isr_tax_format37_v pfv,
                pay_payroll_actions   ppa
          where ppa.payroll_action_id =
        pay_magtape_generic.get_parameter_value(''TRANSFER_PAYROLL_ACTION_ID'')
            and pfv.payroll_action_id = ' || p_arch_payroll_action_id || '
            and pfv.person_id         = ' || p_arch_person_id  || '
            and pfv.legal_employer_id = ' || p_legal_employer_id || '
            and pfv.effective_date    = ''' || p_pai_eff_date || '''
            and to_number(to_char(pfv.effective_date,''YYYY'')) = '
                                                              || p_year || '' ;

          dbg( l_xml_query) ;
          dbg('check for clob istemporary') ;

          is_temp := dbms_lob.istemporary(l_xml_clob);
          dbg('Istemporary(l_xml_clob) ' ||is_temp );

          IF is_temp = 1 THEN
            DBMS_LOB.FREETEMPORARY(l_xml_clob);
          END IF;

          dbg('clob createtemporary') ;

          dbms_lob.createtemporary(l_xml_clob,false,DBMS_LOB.CALL);
          dbms_lob.open(l_xml_clob,dbms_lob.lob_readwrite);

          dbg('set the context') ;

          l_xml_ctx := DBMS_XMLQuery.newcontext(l_xml_query);

          DBMS_XMLQuery.setRowsetTag(l_XML_ctx,'Format37') ;

          dbg('dbms_xmlquery  getxml') ;

          l_xml_clob:= dbms_xmlquery.getxml(l_xml_ctx);

          dbg('after dbms_xmlquery get_xml') ;
          DBMS_XMLQuery.closeContext(l_xml_ctx);
          dbg('Context closed') ;
        return l_xml_clob ;

    exception
          when OTHERS then
            dbms_lob.close(l_xml_clob);
            dbg('sqleerm ' || sqlerrm);
            HR_UTILITY.RAISE_ERROR;

    end create_xml_string;


/******************************************************************
Name      : fetch_format37_xml
Purpose   : This procedure called from PYUGEN for each
            assignment action id. Calls the get_format37_data to get
            and store in the plsql table and then calls
            create_xml_string to get the xml string from the plsql
            table.
******************************************************************/
    PROCEDURE fetch_format37_xml IS

        lc_emp_clob                    CLOB;
        l_error_msg                    VARCHAR2(200);

        l_legal_employer_id            NUMBER;
        l_year                         NUMBER;
        l_final_xml                    BLOB;
        l_final_xml_string             VARCHAR2(32000);
        l_is_temp_emp                  VARCHAR2(2);
        l_is_temp_final_xml            VARCHAR2(2);

        l_arch_payroll_action_id       NUMBER ;
        l_arch_person_id               NUMBER ;
        l_pai_eff_date                 DATE ;

        l_amount                       BINARY_INTEGER ;
        l_position                     BINARY_INTEGER ;
        l_buffer                       varchar2(32767) ;

        CURSOR c_get_params IS
         SELECT paa1.serial_number, -- archiver person id
                paa1.payroll_action_id, -- archiver payroll_action_id
               pay_mx_isr_format37.get_parameter('LEGAL_EMPLOYER_ID',ppa.legislative_parameters),
               pay_mx_isr_format37.get_parameter('Year',ppa.legislative_parameters),
               pai.effective_date
         FROM pay_assignment_actions paa,
              pay_payroll_actions ppa,
              pay_assignment_actions paa1,
              pay_payroll_actions ppa1,
              pay_action_information pai
         where ppa.payroll_action_id = paa.payroll_action_id
         and ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID')
         and paa.assignment_action_id = pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID')
         and paa.serial_number = paa1.assignment_action_id
         and paa1.payroll_action_id = ppa1.payroll_action_id
         and ppa1.report_type = 'MX_YREND_ARCHIVE'
         and ppa1.action_type = 'X'
         and ppa1.action_status = 'C'
         and pai.action_context_id = paa1.assignment_action_id ;

    BEGIN

         g_debug_flag          := 'Y' ;
--         g_concurrent_flag     := 'Y' ;

         dbg('*********************');
         dbg('In fetch_format37_xml');
         dbg('*********************');

      --   dbg(to_char(pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID'))) ;
      --   dbg(to_char(pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID'))) ;

        l_position           := 1 ;
        l_amount             := 32767 ;

         OPEN c_get_params;
         FETCH c_get_params INTO
         l_arch_person_id, l_arch_payroll_action_id,
         l_legal_employer_id, l_year, l_pai_eff_date ;
         CLOSE c_get_params;

         dbg('l_arch_payroll_action_id ' ||l_arch_payroll_action_id);
         dbg('l_arch_person_id ' ||l_arch_person_id);
         dbg('l_legal_employer_id ' ||l_legal_employer_id);
         dbg('l_year ' ||l_year);

         l_is_temp_emp    := dbms_lob.istemporary(lc_emp_clob);
         dbg('Istemporary(lc_emp_clob) ' ||l_is_temp_emp );

         IF l_is_temp_emp = 1 THEN
            DBMS_LOB.FREETEMPORARY(lc_emp_clob);
         END IF;

         dbms_lob.createtemporary(lc_emp_clob,false,DBMS_LOB.CALL);
         dbms_lob.open(lc_emp_clob,dbms_lob.lob_readwrite);

         lc_emp_clob := create_xml_string(l_arch_payroll_action_id,l_arch_person_id,l_legal_employer_id,
                         l_year,l_pai_eff_date);

         dbg('After create xml string ');

         dbg('XML String is ');
         dbg(dbms_lob.substr(lc_emp_clob,dbms_lob.getlength(lc_emp_clob),1));

         begin

           dbms_lob.open(lc_emp_clob,DBMS_LOB.LOB_READONLY);
           LOOP
             dbms_lob.read(lc_emp_clob,l_amount,l_position,l_buffer);
             dbg('inside the loop');
             dbg(l_buffer);
             pay_core_files.write_to_magtape_lob(l_buffer);
             l_position := l_position+l_amount;
           end loop;
           exception  WHEN NO_DATA_FOUND THEN
              null ;
         end ;

          dbg('Length of  pay_mag_tape.g_blob_value ' ||dbms_lob.getlength(pay_mag_tape.g_blob_value));

          IF dbms_lob.ISOPEN(lc_emp_clob)=1  THEN
             dbg('Closing lc_emp_clob' );
             dbms_lob.close(lc_emp_clob);
          END IF;


    EXCEPTION
          WHEN OTHERS then
             IF dbms_lob.ISOPEN(lc_emp_clob)=1 THEN
                dbg('Raising exception and Closing lc_emp_clob' );
                dbms_lob.close(lc_emp_clob);
             END IF;

             dbg('sqleerm ' || SQLERRM);
             raise;
    END fetch_format37_xml;

/******************************************************************
Name      : get_footers
Purpose   : This procedure is called from PYUGEN.
******************************************************************/

    PROCEDURE get_footers IS

         l_footer_xml_string VARCHAR2(32000);
    BEGIN

           g_debug_flag          := 'Y' ;
--           g_concurrent_flag     := 'Y' ;

           dbg('*********************');
           dbg('In get_footers       ');
           dbg('*********************');

           l_footer_xml_string :=  '</EMPLOYEES>'||fnd_global.local_chr(13)||fnd_global.local_chr(10);

           write_to_magtape_lob (l_footer_xml_string);

           dbg('Length of  pay_mag_tape.g_blob_value ' ||dbms_lob.getlength(pay_mag_tape.g_blob_value));

    END get_footers;


/******************************************************************
Name      : get_headers
Purpose   : This procedure is called from PYUGEN.
******************************************************************/
    PROCEDURE get_headers IS

         l_header_xml_string VARCHAR2(32000);
    BEGIN

           g_debug_flag          := 'Y' ;
--           g_concurrent_flag     := 'Y' ;

           dbg('*********************');
           dbg('In get_headers       ');
           dbg('*********************');

           l_header_xml_string :=
               ' <EMPLOYEES>'||fnd_global.local_chr(13)||fnd_global.local_chr(10);

           write_to_magtape_lob (l_header_xml_string);

           dbg('Length of  pay_mag_tape.g_blob_value ' ||dbms_lob.getlength(pay_mag_tape.g_blob_value));


    END get_headers ;


END PAY_MX_ISR_FORMAT37_INFO ;

/
