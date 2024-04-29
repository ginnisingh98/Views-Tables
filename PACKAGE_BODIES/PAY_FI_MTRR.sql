--------------------------------------------------------
--  DDL for Package Body PAY_FI_MTRR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FI_MTRR" AS
/* $Header: pyfimtrr.pkb 120.3.12000000.2 2007/02/28 12:16:21 psingla noship $ */
	PROCEDURE GET_DATA (
			      p_business_group_id		IN NUMBER,
			      p_payroll_action_id       	IN  VARCHAR2 ,
			      p_template_name			IN VARCHAR2,
			      p_xml 				OUT NOCOPY CLOB
			    )

           	    IS

           	    					/*  Start of declaration*/


           	    -- Variables needed for the report
           	    l_Wage_payment_month	VARCHAR2(30);
		    l_none_payment_month	VARCHAR2(30);
    		    l_no_vat_month		VARCHAR2(30);
		    l_due_date			VARCHAR2(30);
		    l_sum			VARCHAR2(30);
		    l_counter	number := 0;
		    l_payroll_action_id   PAY_ACTION_INFORMATION. ACTION_INFORMATION1%TYPE;
		    l_x80_code  	VARCHAR2(30);
    		    l_x81_code  	VARCHAR2(30);
    		    l_x82_code  	VARCHAR2(30);
		    l_sal_subject_wt		VARCHAR2(30);
		l_sal_subject_ts		VARCHAR2(30);
		l_pay_subject_ts		VARCHAR2(30);
		l_pay_subject_wt		VARCHAR2(30);
		l_wt_deduction		VARCHAR2(30);
		l_adjustment_wt		VARCHAR2(30);
		l_employer_ss_fee	VARCHAR2(30);
		l_adjustment_ss		VARCHAR2(30);
		l_ts_deduction		VARCHAR2(30);
		l_adjustment_ts		VARCHAR2(30);
		l_vat			VARCHAR2(30);
		l_subsidy_tax_source	VARCHAR2(30);
		l_subsidy_withhold_tax	VARCHAR2(30);
		l_sal_subject_wt_c	VARCHAR2(30);
		l_sal_subject_ts_c	VARCHAR2(30);
		l_pay_subject_ts_c	VARCHAR2(30);
		l_pay_subject_wt_c	VARCHAR2(30);
		l_wt_deduction_c	VARCHAR2(30);
		l_adjustment_wt_c	VARCHAR2(30);
		l_employer_ss_fee_c		VARCHAR2(30);
		l_adjustment_ss_c	VARCHAR2(30);
		l_ts_deduction_c		VARCHAR2(30);
		l_adjustment_ts_c	VARCHAR2(30);
		l_vat_c				VARCHAR2(30);
		l_subsidy_tax_source_c	VARCHAR2(30);
		l_subsidy_withhold_tax_c VARCHAR2(30);
		l_ref_number		VARCHAR2(20);
		l_data_source_code       xdo_ds_definitions_b.data_source_code%type;




          	              	    			/* End of declaration*/

           	     					/* Cursors */
		Cursor csr_mtrr_rpt(csr_v_pa_id PAY_ACTION_INFORMATION. ACTION_INFORMATION1%TYPE)
			IS
				SELECT	  *
				FROM	PAY_ACTION_INFORMATION
			  	WHERE	 ACTION_CONTEXT_TYPE = 'PA'
			  	AND	ACTION_CONTEXT_ID =  csr_v_pa_id
				AND ACTION_INFORMATION_CATEGORY='EMEA REPORT INFORMATION' ;

				rg_mtrr_rpt  csr_mtrr_rpt%rowtype;

	     Cursor csr_get_data_source_name
	            is
		      select data_source_code
		      from   xdo_templates_b
                      where  template_code = p_template_name
		      and    application_short_name = 'PAY';

				           	     /* End of Cursors */

           	    BEGIN

				IF p_payroll_action_id  IS NULL THEN

				BEGIN



					SELECT payroll_action_id
					INTO  l_payroll_action_id
					FROM pay_payroll_actions ppa,
					fnd_conc_req_summary_v fcrs,
					fnd_conc_req_summary_v fcrs1
					WHERE  fcrs.request_id = FND_GLOBAL.CONC_REQUEST_ID
					AND fcrs.priority_request_id = fcrs1.priority_request_id
					AND ppa.request_id between fcrs1.request_id  and fcrs.request_id
					AND ppa.request_id = fcrs1.request_id;

				EXCEPTION
				WHEN others THEN
				NULL;
				END ;

				ELSE

					l_payroll_action_id  :=p_payroll_action_id;

				END IF;

				OPEN csr_get_data_source_name;
				FETCH csr_get_data_source_name INTO l_data_source_code;
				close csr_get_data_source_name;


			hr_utility.set_location('Entered Procedure GETDATA',10);

				/* Pick up the details belonging to Local Unit */

				OPEN  csr_mtrr_rpt( l_payroll_action_id);
					FETCH csr_mtrr_rpt INTO rg_mtrr_rpt;
				CLOSE csr_mtrr_rpt;

				 /* For Audit Report */
				 if  l_data_source_code = 'PYFIMTRR' then
					 SELECT  trim(rg_mtrr_rpt.action_information4)||'  '||trim(rg_mtrr_rpt.action_information4)
					 INTO l_Wage_payment_month
					 FROM dual;

					IF rg_mtrr_rpt.action_information28 IS NULL THEN
						l_due_date:=to_char(to_date('15'||trim(rg_mtrr_rpt.action_information4),'DDMMYYYY') ) ;
					ELSE
						l_due_date := to_char(fnd_date.canonical_to_date(rg_mtrr_rpt.action_information28)) ;
					END IF;

					l_ref_number:= rg_mtrr_rpt.action_information29 ;

					l_sum := TRIM((TO_CHAR(NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information15),0) +
							NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information17),0) +
							NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information19),0)
							-   (   NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information16),0)
							+  NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information18),0)
							+  NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information20),0) ) ,'999G999G990D99')));

					IF  NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information21),0) = 0 THEN
						 l_no_vat_month:= rg_mtrr_rpt.action_information4||'  '||rg_mtrr_rpt.action_information4;


					END IF;

					IF  (NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information11),0)  + NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information12),0)
					+  NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information13),0)  + NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information14),0)
					+  NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information15),0)  + NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information16),0)
					+   NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information17),0)  + NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information18),0)
					+     NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information19),0)  + NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information20),0)  )
					= 0 	THEN

						l_none_payment_month := rg_mtrr_rpt.action_information4||'  '||rg_mtrr_rpt.action_information4;

					END IF;

					l_x80_code := LPAD(TRIM((TO_CHAR(NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information15),0) - NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information16),0),'999999999D99'))) ,11,'0');
					l_x81_code := LPAD(TRIM((TO_CHAR(NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information17),0) - NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information18),0),'999999999D99'))) ,11,'0');
					l_x82_code := LPAD(TRIM((TO_CHAR(NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information19),0) - NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information20),0),'999999999D99'))) ,11,'0');

					l_sal_subject_wt :=  TRIM((TO_CHAR(FLOOR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information11))))) ;
					l_sal_subject_ts :=  TRIM((TO_CHAR(FLOOR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information12))))) ;
					l_pay_subject_wt :=  TRIM((TO_CHAR(FLOOR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information13))))) ;
					l_pay_subject_ts :=  TRIM((TO_CHAR(FLOOR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information14))))) ;
					l_wt_deduction :=  TRIM((TO_CHAR(FLOOR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information15))))) ;
					l_adjustment_wt :=  TRIM((TO_CHAR(FLOOR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information16))))) ;
					l_employer_ss_fee :=  TRIM((TO_CHAR(FLOOR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information17))))) ;
					l_adjustment_ss :=  TRIM((TO_CHAR(FLOOR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information18))))) ;
					l_ts_deduction :=  TRIM((TO_CHAR(FLOOR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information19))))) ;
					l_adjustment_ts :=  TRIM((TO_CHAR(FLOOR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information20))))) ;
					l_vat :=  TRIM((TO_CHAR(FLOOR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information21))))) ;
					l_subsidy_tax_source := TRIM((TO_CHAR(FLOOR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information3))))) ;
					l_subsidy_withhold_tax := TRIM((TO_CHAR(FLOOR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information30))))) ;

					l_sal_subject_wt_c :=  SUBSTR(TRIM((TO_CHAR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information11) -  FLOOR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information11)),'D99'))),2,2);
					l_sal_subject_ts_c :=  SUBSTR(TRIM((TO_CHAR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information12) -  FLOOR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information12)),'D99'))),2,2);
					l_pay_subject_wt_c :=  SUBSTR(TRIM((TO_CHAR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information13) -  FLOOR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information13)),'D99'))),2,2);
					l_pay_subject_ts_c :=  SUBSTR(TRIM((TO_CHAR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information14) -  FLOOR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information14)),'D99'))),2,2);
					l_wt_deduction_c :=  SUBSTR(TRIM((TO_CHAR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information15) -  FLOOR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information15)),'D99'))),2,2);
					l_adjustment_wt_c :=  SUBSTR(TRIM((TO_CHAR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information16) -  FLOOR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information16)),'D99'))),2,2);
					l_employer_ss_fee_c :=  SUBSTR(TRIM((TO_CHAR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information17) -  FLOOR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information17)),'D99'))),2,2);
					l_adjustment_ss_c :=  SUBSTR(TRIM((TO_CHAR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information18) -  FLOOR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information18)),'D99'))),2,2);
					l_ts_deduction_c :=  SUBSTR(TRIM((TO_CHAR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information19) -  FLOOR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information19)),'D99'))),2,2);
					l_adjustment_ts_c :=  SUBSTR(TRIM((TO_CHAR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information20) -  FLOOR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information20)),'D99'))),2,2);
					l_vat_c :=  SUBSTR(TRIM((TO_CHAR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information21) -  FLOOR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information21)),'D99'))),2,2);
					l_subsidy_tax_source_c :=  SUBSTR(TRIM((TO_CHAR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information3) -  FLOOR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information3)),'D99'))),2,2);
					l_subsidy_withhold_tax_c :=  SUBSTR(TRIM((TO_CHAR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information30) -  FLOOR(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information30)),'D99'))),2,2);



					hr_utility.set_location('Before populating pl/sql table',20);

					gtagdata(l_counter).TagName := 'TAX_PAYER_NAME';
					gtagdata(l_counter).TagValue :=pay_fi_general.xml_parser(rg_mtrr_rpt.action_information5);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'ADDRESS_LINE1';
					gtagdata(l_counter).TagValue :=  pay_fi_general.xml_parser(rg_mtrr_rpt.action_information6);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'ADDRESS_LINE2';
					gtagdata(l_counter).TagValue := pay_fi_general.xml_parser(rg_mtrr_rpt.action_information7);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'ADDRESS_LINE3';
					gtagdata(l_counter).TagValue := pay_fi_general.xml_parser(rg_mtrr_rpt.action_information8);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'ADDRESS_LINE4';
					gtagdata(l_counter).TagValue := pay_fi_general.xml_parser(rg_mtrr_rpt.action_information9);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'BUSINESS_ID';
					gtagdata(l_counter).TagValue := pay_fi_general.xml_parser(rg_mtrr_rpt.action_information10);
						l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'CURRENCY';
					gtagdata(l_counter).TagValue := 'euro';
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'WAGE_PAYMENT_MONTH';
					gtagdata(l_counter).TagValue :=  l_Wage_payment_month ;
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'VAT_PAYMENT_MONTH';
					gtagdata(l_counter).TagValue := rg_mtrr_rpt.action_information4;
						l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'SAL_SUBJECT_WT';
					gtagdata(l_counter).TagValue :=  l_sal_subject_wt;
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'S_SUB_WT_C';
					gtagdata(l_counter).TagValue :=  l_sal_subject_wt_c;
						l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'SAL_SUBJECT_TS';
					gtagdata(l_counter).TagValue :=  l_sal_subject_ts;
						l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'S_SUB_TS_C';
					gtagdata(l_counter).TagValue :=  l_sal_subject_ts_c;
						l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'PAY_SUBJECT_WT';
					gtagdata(l_counter).TagValue :=  l_pay_subject_wt ;
						l_counter := l_counter + 1;

				gtagdata(l_counter).TagName := 'P_SUB_WT_C';
					gtagdata(l_counter).TagValue :=  l_pay_subject_wt_c ;
						l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'PAY_SUBJECT_TS';
					gtagdata(l_counter).TagValue :=  l_pay_subject_ts;
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'P_SUB_TS_C';
					gtagdata(l_counter).TagValue :=  l_pay_subject_ts_c;
						l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'WT_DEDUCTION';
					gtagdata(l_counter).TagValue :=  l_wt_deduction;
						l_counter := l_counter + 1;

						gtagdata(l_counter).TagName := 'W_DED_C';
					gtagdata(l_counter).TagValue :=  l_wt_deduction_c;
						l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'ADJUSTMENT_WT';
					gtagdata(l_counter).TagValue :=  l_adjustment_wt;
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'ADJ_WT_C';
					gtagdata(l_counter).TagValue :=  l_adjustment_wt_c;
						l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'EMPLOYER_SS_FEE';
					gtagdata(l_counter).TagValue :=  l_employer_ss_fee;
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'E_SS_FEE_C';
					gtagdata(l_counter).TagValue :=  l_employer_ss_fee_c;
						l_counter := l_counter + 1;

						gtagdata(l_counter).TagName := 'ADJUSTMENT_SS';
					gtagdata(l_counter).TagValue :=  l_adjustment_ss;
						l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'ADJ_SS_C';
					gtagdata(l_counter).TagValue :=  l_adjustment_ss_c;
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'TS_DEDUCTION';
					gtagdata(l_counter).TagValue :=  l_ts_deduction;
						l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'T_DED_C';
					gtagdata(l_counter).TagValue :=  l_ts_deduction_c;
						l_counter := l_counter + 1;


						gtagdata(l_counter).TagName := 'ADJUSTMENT_TS';
					gtagdata(l_counter).TagValue :=  l_adjustment_ts;
						l_counter := l_counter + 1;

						gtagdata(l_counter).TagName := 'ADJ_TS_C';
					gtagdata(l_counter).TagValue :=  l_adjustment_ts_c;
						l_counter := l_counter + 1;


						IF  l_none_payment_month IS NOT NULL THEN

							gtagdata(l_counter).TagName := 'N1';
						gtagdata(l_counter).TagValue := substr(l_none_payment_month,1,1);
							l_counter := l_counter + 1;

							gtagdata(l_counter).TagName := 'N2';
						gtagdata(l_counter).TagValue := substr(l_none_payment_month,2,1);
							l_counter := l_counter + 1;
							gtagdata(l_counter).TagName := 'N3';
						gtagdata(l_counter).TagValue := substr(l_none_payment_month,3,1);
							l_counter := l_counter + 1;
							gtagdata(l_counter).TagName := 'N4';
						gtagdata(l_counter).TagValue := substr(l_none_payment_month,4,1);
							l_counter := l_counter + 1;
							gtagdata(l_counter).TagName := 'N5';
						gtagdata(l_counter).TagValue := substr(l_none_payment_month,5,1);
							l_counter := l_counter + 1;

							gtagdata(l_counter).TagName := 'N6';
						gtagdata(l_counter).TagValue := substr(l_none_payment_month,6,1);
							l_counter := l_counter + 1;


						END IF;

						gtagdata(l_counter).TagName := 'VAT';
					gtagdata(l_counter).TagValue :=  l_vat;
						l_counter := l_counter + 1;

						gtagdata(l_counter).TagName := 'VAT_C';
					gtagdata(l_counter).TagValue :=  l_vat_c;
						l_counter := l_counter + 1;

						gtagdata(l_counter).TagName := 'SUB_TAX_SOURCE';
					gtagdata(l_counter).TagValue :=  l_subsidy_tax_source;
						l_counter := l_counter + 1;

						gtagdata(l_counter).TagName := 'SUB_TAX_SOURCE_C';
					gtagdata(l_counter).TagValue :=  l_subsidy_tax_source_c;
						l_counter := l_counter + 1;

						gtagdata(l_counter).TagName := 'SUB_WITHHOLD';
					gtagdata(l_counter).TagValue :=  l_subsidy_withhold_tax;
						l_counter := l_counter + 1;

						gtagdata(l_counter).TagName := 'SUB_WITH_C';
					gtagdata(l_counter).TagValue :=  l_subsidy_withhold_tax_c;
						l_counter := l_counter + 1;




						IF  l_no_vat_month  IS NOT NULL THEN

							gtagdata(l_counter).TagName := 'N7';
						gtagdata(l_counter).TagValue := substr(l_no_vat_month,1,1);
							l_counter := l_counter + 1;

							gtagdata(l_counter).TagName := 'N8';
						gtagdata(l_counter).TagValue := substr(l_no_vat_month,2,1);
							l_counter := l_counter + 1;
							gtagdata(l_counter).TagName := 'N9';
						gtagdata(l_counter).TagValue := substr(l_no_vat_month,3,1);
							l_counter := l_counter + 1;
							gtagdata(l_counter).TagName := 'Na';
						gtagdata(l_counter).TagValue := substr(l_no_vat_month,4,1);
							l_counter := l_counter + 1;
							gtagdata(l_counter).TagName := 'Nb';
						gtagdata(l_counter).TagValue := substr(l_no_vat_month,5,1);
							l_counter := l_counter + 1;

							gtagdata(l_counter).TagName := 'Nc';
						gtagdata(l_counter).TagValue := substr(l_no_vat_month,6,1);
							l_counter := l_counter + 1;


						END IF;

						gtagdata(l_counter).TagName := 'CONTACT_PERSON';
					gtagdata(l_counter).TagValue :=  pay_fi_general.xml_parser(rg_mtrr_rpt.action_information22);
						l_counter := l_counter + 1;

						gtagdata(l_counter).TagName := 'PHONE';
					gtagdata(l_counter).TagValue :=  pay_fi_general.xml_parser(rg_mtrr_rpt.action_information23);
						l_counter := l_counter + 1;

						gtagdata(l_counter).TagName := 'FAX';
					gtagdata(l_counter).TagValue :=  pay_fi_general.xml_parser(rg_mtrr_rpt.action_information24);
						l_counter := l_counter + 1;


						gtagdata(l_counter).TagName := 'I1';
					gtagdata(l_counter).TagValue :=  SUBSTR(rg_mtrr_rpt.action_information10,1,1) ;
						l_counter := l_counter + 1;

						gtagdata(l_counter).TagName := 'I2';
						gtagdata(l_counter).TagValue :=  SUBSTR(rg_mtrr_rpt.action_information10,2,1) ;
						l_counter := l_counter + 1;

						gtagdata(l_counter).TagName := 'I3';
						gtagdata(l_counter).TagValue :=  SUBSTR(rg_mtrr_rpt.action_information10,3,1) ;
						l_counter := l_counter + 1;

						gtagdata(l_counter).TagName := 'I4';
						gtagdata(l_counter).TagValue :=  SUBSTR(rg_mtrr_rpt.action_information10,4,1) ;
						l_counter := l_counter + 1;

						gtagdata(l_counter).TagName := 'I5';
						gtagdata(l_counter).TagValue :=  SUBSTR(rg_mtrr_rpt.action_information10,5,1) ;
						l_counter := l_counter + 1;
						gtagdata(l_counter).TagName := 'I6';
						gtagdata(l_counter).TagValue :=  SUBSTR(rg_mtrr_rpt.action_information10,6,1) ;
						l_counter := l_counter + 1;
						gtagdata(l_counter).TagName := 'I7';
						gtagdata(l_counter).TagValue :=  SUBSTR(rg_mtrr_rpt.action_information10,7,1) ;
						l_counter := l_counter + 1;
						gtagdata(l_counter).TagName := 'I8';
						gtagdata(l_counter).TagValue :=  SUBSTR(rg_mtrr_rpt.action_information10,8,1) ;
						l_counter := l_counter + 1;
						gtagdata(l_counter).TagName := 'I9';
						gtagdata(l_counter).TagValue :=  SUBSTR(rg_mtrr_rpt.action_information10,9,1) ;
						l_counter := l_counter + 1;
						gtagdata(l_counter).TagName := 'Ia';
						gtagdata(l_counter).TagValue :=  NULL;
						l_counter := l_counter + 1;
						gtagdata(l_counter).TagName := 'Ib';
						gtagdata(l_counter).TagValue :=  NULL ;
						l_counter := l_counter + 1;

						gtagdata(l_counter).TagName := 'Ic';
						gtagdata(l_counter).TagValue :=  NULL ;
						l_counter := l_counter + 1;

						gtagdata(l_counter).TagName := 'B1';
						gtagdata(l_counter).TagValue :=  SUBSTR(rg_mtrr_rpt.action_information27,1,1) ;
						l_counter := l_counter + 1;

						gtagdata(l_counter).TagName := 'B2';
						gtagdata(l_counter).TagValue :=  SUBSTR(rg_mtrr_rpt.action_information27,2,1) ;
						l_counter := l_counter + 1;

						gtagdata(l_counter).TagName := 'B3';
						gtagdata(l_counter).TagValue :=  SUBSTR(rg_mtrr_rpt.action_information27,3,1) ;
						l_counter := l_counter + 1;

						gtagdata(l_counter).TagName := 'B4';
						gtagdata(l_counter).TagValue :=  SUBSTR(rg_mtrr_rpt.action_information27,4,1) ;
						l_counter := l_counter + 1;

						gtagdata(l_counter).TagName := 'B5';
						gtagdata(l_counter).TagValue :=  SUBSTR(rg_mtrr_rpt.action_information27,5,1) ;
						l_counter := l_counter + 1;
						gtagdata(l_counter).TagName := 'B6';
						gtagdata(l_counter).TagValue :=  SUBSTR(rg_mtrr_rpt.action_information27,6,1) ;
						l_counter := l_counter + 1;
						gtagdata(l_counter).TagName := 'B7';
						gtagdata(l_counter).TagValue :=  SUBSTR(rg_mtrr_rpt.action_information27,8,1) ;
						l_counter := l_counter + 1;
						gtagdata(l_counter).TagName := 'B8';
						gtagdata(l_counter).TagValue :=  SUBSTR(rg_mtrr_rpt.action_information27,9,1) ;
						l_counter := l_counter + 1;
						gtagdata(l_counter).TagName := 'B9';
						gtagdata(l_counter).TagValue :=  SUBSTR(rg_mtrr_rpt.action_information27,10,1) ;
						l_counter := l_counter + 1;
						gtagdata(l_counter).TagName := 'Ba';
						gtagdata(l_counter).TagValue :=  SUBSTR(rg_mtrr_rpt.action_information27,11,1) ;
						l_counter := l_counter + 1;
						gtagdata(l_counter).TagName := 'Bb';
						gtagdata(l_counter).TagValue :=  SUBSTR(rg_mtrr_rpt.action_information27,12,1) ;
						l_counter := l_counter + 1;
						gtagdata(l_counter).TagName := 'Bc';
						gtagdata(l_counter).TagValue :=  SUBSTR(rg_mtrr_rpt.action_information27,13,1) ;
						l_counter := l_counter + 1;
						gtagdata(l_counter).TagName := 'Bd';
						gtagdata(l_counter).TagValue :=  SUBSTR(rg_mtrr_rpt.action_information27,14,1) ;
						l_counter := l_counter + 1;

						gtagdata(l_counter).TagName := 'Be';
						gtagdata(l_counter).TagValue :=  SUBSTR(rg_mtrr_rpt.action_information27,15,1) ;
						l_counter := l_counter + 1;

						gtagdata(l_counter).TagName := 'TAX_OFFICE_NAME';
					gtagdata(l_counter).TagValue :=  pay_fi_general.xml_parser(rg_mtrr_rpt.action_information26);
						l_counter := l_counter + 1;

						gtagdata(l_counter).TagName := 'TAX_PAYER_NAME';
					gtagdata(l_counter).TagValue :=  pay_fi_general.xml_parser(rg_mtrr_rpt.action_information5);
						l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'TAX_OFFICE_BA';
					gtagdata(l_counter).TagValue :=  pay_fi_general.xml_parser(rg_mtrr_rpt.action_information25);
						l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'M1';
					gtagdata(l_counter).TagValue :=  SUBSTR(rg_mtrr_rpt.action_information4,1,1);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'M2';
					gtagdata(l_counter).TagValue :=  SUBSTR(rg_mtrr_rpt.action_information4,2,1);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'M3';
					gtagdata(l_counter).TagValue :=  SUBSTR(rg_mtrr_rpt.action_information4,5,1);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'M4';
					gtagdata(l_counter).TagValue :=  SUBSTR(rg_mtrr_rpt.action_information4,6,1);
						l_counter := l_counter + 1;


						gtagdata(l_counter).TagName := 'C1';
					gtagdata(l_counter).TagValue := '8';
						l_counter := l_counter + 1;

						gtagdata(l_counter).TagName := 'W1';
					gtagdata(l_counter).TagValue := '0';
						l_counter := l_counter + 1;

						gtagdata(l_counter).TagName := 'S1';
					gtagdata(l_counter).TagValue := '1';
						l_counter := l_counter + 1;

						gtagdata(l_counter).TagName := 'T1';
					gtagdata(l_counter).TagValue := '2';
						l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'W2';
					gtagdata(l_counter).TagValue := SUBSTR(l_x80_code,1,1);
						l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'W3';
					gtagdata(l_counter).TagValue := SUBSTR(l_x80_code,2,1);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'W4';
					gtagdata(l_counter).TagValue := SUBSTR(l_x80_code,3,1);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'W5';
					gtagdata(l_counter).TagValue := SUBSTR(l_x80_code,4,1);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'W6';
					gtagdata(l_counter).TagValue := SUBSTR(l_x80_code,5,1);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'W7';
					gtagdata(l_counter).TagValue := SUBSTR(l_x80_code,6,1);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'W8';
					gtagdata(l_counter).TagValue := SUBSTR(l_x80_code,7,1);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'W9';
					gtagdata(l_counter).TagValue := SUBSTR(l_x80_code,8,1);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'Wa';
					gtagdata(l_counter).TagValue := SUBSTR(l_x80_code,9,1);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'Wb';
					gtagdata(l_counter).TagValue := SUBSTR(l_x80_code,10,1);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'Wc';
					gtagdata(l_counter).TagValue := SUBSTR(l_x80_code,11,1);
						l_counter := l_counter + 1;


						gtagdata(l_counter).TagName := 'S2';
					gtagdata(l_counter).TagValue := SUBSTR(l_x81_code,1,1);
						l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'S3';
					gtagdata(l_counter).TagValue := SUBSTR(l_x81_code,2,1);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'S4';
					gtagdata(l_counter).TagValue := SUBSTR(l_x81_code,3,1);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'S5';
					gtagdata(l_counter).TagValue := SUBSTR(l_x81_code,4,1);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'S6';
					gtagdata(l_counter).TagValue := SUBSTR(l_x81_code,5,1);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'S7';
					gtagdata(l_counter).TagValue := SUBSTR(l_x81_code,6,1);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'S8';
					gtagdata(l_counter).TagValue := SUBSTR(l_x81_code,7,1);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'S9';
					gtagdata(l_counter).TagValue := SUBSTR(l_x81_code,8,1);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'Sa';
					gtagdata(l_counter).TagValue := SUBSTR(l_x81_code,9,1);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'Sb';
					gtagdata(l_counter).TagValue := SUBSTR(l_x81_code,10,1);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'Sc';
					gtagdata(l_counter).TagValue := SUBSTR(l_x81_code,11,1);
						l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'T2';
					gtagdata(l_counter).TagValue := SUBSTR(l_x82_code,1,1);
						l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'T3';
					gtagdata(l_counter).TagValue := SUBSTR(l_x82_code,2,1);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'T4';
					gtagdata(l_counter).TagValue := SUBSTR(l_x82_code,3,1);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'T5';
					gtagdata(l_counter).TagValue := SUBSTR(l_x82_code,4,1);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'T6';
					gtagdata(l_counter).TagValue := SUBSTR(l_x82_code,5,1);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'T7';
					gtagdata(l_counter).TagValue := SUBSTR(l_x82_code,6,1);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'T8';
					gtagdata(l_counter).TagValue := SUBSTR(l_x82_code,7,1);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'T9';
					gtagdata(l_counter).TagValue := SUBSTR(l_x82_code,8,1);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'Ta';
					gtagdata(l_counter).TagValue := SUBSTR(l_x82_code,9,1);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'Tb';
					gtagdata(l_counter).TagValue := SUBSTR(l_x82_code,10,1);
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'Tc';
					gtagdata(l_counter).TagValue := SUBSTR(l_x82_code,11,1);
						l_counter := l_counter + 1;


						gtagdata(l_counter).TagName := 'REF_NUM';
					gtagdata(l_counter).TagValue := l_ref_number;
						l_counter := l_counter + 1;

						gtagdata(l_counter).TagName := 'DUE_DATE';
					gtagdata(l_counter).TagValue := to_char(l_due_date);
						l_counter := l_counter + 1;

						gtagdata(l_counter).TagName := 'SUM';
					gtagdata(l_counter).TagValue := l_sum;
						l_counter := l_counter + 1;

					hr_utility.set_location('After populating pl/sql table',30);
				ELSIF l_data_source_code = 'PYFIMTRREFT' then

				   SELECT  trim(rg_mtrr_rpt.action_information4)||'  '||trim(rg_mtrr_rpt.action_information4)
					 INTO l_Wage_payment_month
					 FROM dual;
			           IF  (NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information11),0)  + NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information12),0)
					+  NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information13),0)  + NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information14),0)
					+  NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information15),0)  + NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information16),0)
					+   NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information17),0)  + NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information18),0)
					+     NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information19),0)  + NVL(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information20),0)  )
					= 0 	THEN

						l_none_payment_month := rg_mtrr_rpt.action_information4||'  '||rg_mtrr_rpt.action_information4;
				   END IF;

				  --l_none_payment_month := rg_mtrr_rpt.action_information4||'  '||rg_mtrr_rpt.action_information4;

				   gtagdata(l_counter).TagName := 'BUSINESS_ID';
				   gtagdata(l_counter).TagValue := pay_fi_general.xml_parser(rg_mtrr_rpt.action_information10);
					l_counter := l_counter + 1;

				   gtagdata(l_counter).TagName := 'CURRENCY';
				   gtagdata(l_counter).TagValue := '1';
					l_counter := l_counter + 1;

				   gtagdata(l_counter).TagName := 'WAGE_PAYMENT_MONTH';
				   gtagdata(l_counter).TagValue :=  l_Wage_payment_month ;
					l_counter := l_counter + 1;

				   gtagdata(l_counter).TagName := 'VAT_PAYMENT_MONTH';
				   gtagdata(l_counter).TagValue := rg_mtrr_rpt.action_information4;
					l_counter := l_counter + 1;

				   gtagdata(l_counter).TagName := 'SAL_SUBJECT_WT';
				   gtagdata(l_counter).TagValue :=  ROUND(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information11),2) * 100;
						l_counter := l_counter + 1;

				   gtagdata(l_counter).TagName := 'SAL_SUBJECT_TS';
				   gtagdata(l_counter).TagValue :=  ROUND(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information12),2) * 100;
						l_counter := l_counter + 1;

				   gtagdata(l_counter).TagName := 'PAY_SUBJECT_WT';
				   gtagdata(l_counter).TagValue :=  ROUND(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information13),2) * 100;
						l_counter := l_counter + 1;

                                   gtagdata(l_counter).TagName := 'PAY_SUBJECT_TS';
				   gtagdata(l_counter).TagValue :=  ROUND(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information14),2) * 100;
						l_counter := l_counter + 1;

                                   gtagdata(l_counter).TagName := 'WT_DEDUCTION';
				   gtagdata(l_counter).TagValue :=  ROUND(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information15),2) * 100;
						l_counter := l_counter + 1;

                                   gtagdata(l_counter).TagName := 'ADJUSTMENT_WT';
				   gtagdata(l_counter).TagValue :=  ROUND(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information16),2) * 100;
						l_counter := l_counter + 1;

                                   gtagdata(l_counter).TagName := 'SUB_WITHHOLD';
				   gtagdata(l_counter).TagValue :=  ROUND(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information30),2) * 100;
						l_counter := l_counter + 1;

                                   gtagdata(l_counter).TagName := 'EMPLOYER_SS_FEE';
				   gtagdata(l_counter).TagValue :=  ROUND(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information17),2) * 100;
						l_counter := l_counter + 1;

                  	           gtagdata(l_counter).TagName := 'ADJUSTMENT_SS';
				   gtagdata(l_counter).TagValue :=  ROUND(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information18),2) * 100;
						l_counter := l_counter + 1;

				   gtagdata(l_counter).TagName := 'TS_DEDUCTION';
				   gtagdata(l_counter).TagValue :=  ROUND(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information19),2) * 100;
						l_counter := l_counter + 1;

				   gtagdata(l_counter).TagName := 'ADJUSTMENT_TS';
				   gtagdata(l_counter).TagValue :=  ROUND(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information20),2) * 100;
						l_counter := l_counter + 1;


				   gtagdata(l_counter).TagName := 'SUB_TAX_SOURCE';
				   gtagdata(l_counter).TagValue :=  ROUND(FND_NUMBER.CANONICAL_TO_NUMBER(rg_mtrr_rpt.action_information3),2) * 100;
						l_counter := l_counter + 1;

				   if l_none_payment_month is not null then
					   gtagdata(l_counter).TagName := 'NO_PAY_MNTH';
					   gtagdata(l_counter).TagValue :=  substr(l_none_payment_month,1,6)||'-'||substr(l_none_payment_month,1,6);
							l_counter := l_counter + 1;
				   end if;
				END IF; -- End If for data source checking



					WritetoCLOB (p_xml );
	           	    END GET_DATA;

-----------------------------------------------------------------------------------------------------------------
PROCEDURE WritetoCLOB(p_xfdf_clob out nocopy CLOB) is
l_xfdf_string clob;
l_str1 varchar2(1000);
l_str2 varchar2(20);
l_str3 varchar2(20);
l_str4 varchar2(20);
l_str5 varchar2(20);
l_str6 varchar2(30);
l_str7 varchar2(1000);
l_str8 varchar2(240);
l_str9 varchar2(240);
l_str10 varchar2(20);
l_str11 varchar2(20);

current_index pls_integer;
l_IANA_charset VARCHAR2 (50);

   BEGIN
      l_IANA_charset :=hr_fi_utility.get_IANA_charset ;

hr_utility.set_location('Entering WritetoCLOB ',70);

	l_str1 := '<?xml version="1.0" encoding="'||l_IANA_charset||'"?> <ROOT><MTRR>' ;
	l_str2 := '<';
        l_str3 := '>';
        l_str4 := '</';
        l_str5 := '>';
        l_str6 := '</MTRR></ROOT>';
	l_str7 := '<?xml version="1.0" encoding="'||l_IANA_charset||'"?> <ROOT></ROOT>';
	l_str10 := '<MTRR>';
	l_str11 := '</MTRR>';


	dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
	dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);

	current_index := 0;

              IF gtagdata.count > 0 THEN

			dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );

        		FOR table_counter IN gtagdata.FIRST .. gtagdata.LAST LOOP

        			l_str8 := gtagdata(table_counter).TagName;
	        		l_str9 := gtagdata(table_counter).TagValue;

                                 if l_str9 is not null then

	                           dbms_lob.writeAppend(l_xfdf_string, length(l_str2), l_str2);
                  		   dbms_lob.writeAppend(l_xfdf_string, length(l_str8), l_str8);
				   dbms_lob.writeAppend(l_xfdf_string, length(l_str3), l_str3);
                                   dbms_lob.writeAppend(l_xfdf_string, length(l_str9), l_str9);
				   dbms_lob.writeAppend(l_xfdf_string, length(l_str4), l_str4);
				   dbms_lob.writeAppend(l_xfdf_string, length(l_str8), l_str8);
				   dbms_lob.writeAppend(l_xfdf_string, length(l_str5), l_str5);
                                 else

                                   dbms_lob.writeAppend(l_xfdf_string, length(l_str2), l_str2);
                  		   dbms_lob.writeAppend(l_xfdf_string, length(l_str8), l_str8);
				   dbms_lob.writeAppend(l_xfdf_string, length(l_str3), l_str3);
				   dbms_lob.writeAppend(l_xfdf_string, length(l_str4), l_str4);
				   dbms_lob.writeAppend(l_xfdf_string, length(l_str8), l_str8);
				   dbms_lob.writeAppend(l_xfdf_string, length(l_str5), l_str5);

                                 end if;

			END LOOP;

			dbms_lob.writeAppend(l_xfdf_string, length(l_str6), l_str6 );
		ELSE
			dbms_lob.writeAppend(l_xfdf_string, length(l_str7), l_str7 );
		END IF;

		p_xfdf_clob := l_xfdf_string;

		hr_utility.set_location('Leaving WritetoCLOB ',40);

	EXCEPTION
		WHEN OTHERS then
	        HR_UTILITY.TRACE('sqlerrm ' || SQLERRM);
	        HR_UTILITY.RAISE_ERROR;
END WritetoCLOB;
-------------------------------------------------------------------------------------------------------------------------

END PAY_FI_MTRR;

/
