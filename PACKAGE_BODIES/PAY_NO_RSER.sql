--------------------------------------------------------
--  DDL for Package Body PAY_NO_RSER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NO_RSER" AS
/* $Header: pynorser.pkb 120.0.12000000.1 2007/05/20 09:45:37 rlingama noship $ */
	PROCEDURE GET_DATA (
			      p_business_group_id		IN NUMBER,
			      p_payroll_action_id       	IN  VARCHAR2 ,
			      p_template_name			IN VARCHAR2,
			      p_xml 				OUT NOCOPY CLOB
			    )

           	    IS

           	    					/*  Start of declaration*/

           	    -- Variables needed for the report
			l_xfdf_string clob;
			l_str1 varchar2(2000);
			l_term			VARCHAR2(1000);
			l_year			VARCHAR2(1000);
			l_Tax_Mun_No	VARCHAR2(1000);
			l_mun_name	VARCHAR2(1000);
			l_org_number	VARCHAR2(1000);
			l_emp_name	VARCHAR2(1000);
			l_address		VARCHAR2(1000);
			l_postal_code	VARCHAR2(1000);
			l_post_office		VARCHAR2(1000);
			l_industry_exception VARCHAR2(1000);
			l_exemption_limit NUMBER;
			l_spr_emp_contri_base NUMBER;
			l_spr_calc_contribution NUMBER;
			l_no_months	NUMBER;
			l_fma_calc_contribution NUMBER;
			l_tot_u_contribution_basis NUMBER;
			l_tot_o_contribution_basis NUMBER;
			l_remain_exemp_limit NUMBER;
			l_tot_emp_contribution NUMBER;
			l_k_emp_contribution NUMBER;
			l_tot_withholding_tax NUMBER;
			l_k_withholding_tax NUMBER;
			l_municipal_number VARCHAR2(1000);
			l_municipal_name VARCHAR2(1000);
			l_zone			NUMBER;
			l_emp_contri_base_u NUMBER;
			l_emp_contri_base_o NUMBER;
			l_withholding_tax NUMBER;
			l_u_zone1		NUMBER;
			l_o_zone1		 NUMBER;
			l_u_zone2		NUMBER;
			l_o_zone2		NUMBER;
			l_u_zone3		NUMBER;
			l_o_zone3		NUMBER;
			l_u_zone4		NUMBER;
			l_o_zone4		NUMBER;
			l_u_zone5		NUMBER;
			l_o_zone5		NUMBER;
			l_payroll_action_id   PAY_ACTION_INFORMATION. ACTION_INFORMATION1%TYPE;
			l_IANA_charset VARCHAR2 (50);
			l_el				NUMBER;

          	              	    			/* End of declaration*/

           	     					/* Cursors */
		Cursor csr_rser_header_rpt(csr_v_pa_id PAY_ACTION_INFORMATION.ACTION_INFORMATION1%TYPE)
			IS
				SELECT	  *
				FROM	PAY_ACTION_INFORMATION
			  	WHERE	 ACTION_CONTEXT_TYPE = 'PA'
			  	AND	ACTION_CONTEXT_ID =  csr_v_pa_id
				AND ACTION_INFORMATION_CATEGORY='EMEA REPORT INFORMATION'
				AND  ACTION_INFORMATION1='PYNORSEA';

				rg_rser_header_rpt  csr_rser_header_rpt%rowtype;

			Cursor csr_rser_body_rpt(csr_v_pa_id PAY_ACTION_INFORMATION. ACTION_INFORMATION1%TYPE)
			IS
				SELECT	  *
				FROM	PAY_ACTION_INFORMATION
			  	WHERE	 ACTION_CONTEXT_TYPE = 'PA'
			  	AND	ACTION_CONTEXT_ID =  csr_v_pa_id
				AND ACTION_INFORMATION_CATEGORY= 'EMEA REPORT INFORMATION'
				AND  ACTION_INFORMATION1='PYNORSEA'
				AND  ACTION_INFORMATION2='M';

				rg_rser_body_rpt  csr_rser_body_rpt%rowtype;

			Cursor csr_rser_sum_rpt(csr_v_pa_id PAY_ACTION_INFORMATION. ACTION_INFORMATION1%TYPE)
			IS
				SELECT	  SUM(action_information6)  Witholding_Tax,  SUM(action_information7)  u_contribution_basis, SUM(action_information8)  o_contribution_basis
				, SUM(action_information20)  fe_spr_contribution_basis,  SUM(action_information21) fe_spr_calc_contribution
				,  SUM(action_information25)   fe_fma_calc_contribution ,  SUM(action_information11)  u_calc_contribution, SUM(action_information12)  o_calc_contribution
				, SUM(action_information26)  lu_el_used , SUM(action_information27)  lu_el_used_bimonth  , SUM(action_information23)  no_month
				FROM	PAY_ACTION_INFORMATION
			  	WHERE	 ACTION_CONTEXT_TYPE = 'PA'
			  	AND	ACTION_CONTEXT_ID =  csr_v_pa_id
				AND ACTION_INFORMATION_CATEGORY= 'EMEA REPORT INFORMATION'
				AND  ACTION_INFORMATION1='PYNORSEA'
				AND  ACTION_INFORMATION2='M';

				rg_rser_sum_rpt  csr_rser_sum_rpt%rowtype;

				           	     /* End of Cursors */

           	    BEGIN


				hr_utility.set_location('Entering GETDATA ',10);

				/*Fetching the payroll action id of the archived data*/
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


				/* Pick up the details belonging to Header */

				OPEN  csr_rser_header_rpt( l_payroll_action_id);
					FETCH csr_rser_header_rpt INTO rg_rser_header_rpt;
				CLOSE csr_rser_header_rpt;


				/* Sum data in the records related to the body */
				OPEN  csr_rser_sum_rpt( l_payroll_action_id);
					FETCH csr_rser_sum_rpt INTO rg_rser_sum_rpt;
				CLOSE csr_rser_sum_rpt;


				/*Assign values to the relevant variables*/

				--OppgaveTermin-datadef-11819
				l_term:=to_number(substr(rg_rser_header_rpt.action_information3,1,2));

				--OppgaveAr-datadef-11236
				l_year :=  substr(rg_rser_header_rpt.action_information3,3,4);

				--SkatteoppkreverKommuneNummer-datadef-16513
				l_Tax_Mun_No := rg_rser_header_rpt.action_information5;

				--SkatteoppkreverKommuneNavn-datadef-8486
				l_mun_name := rg_rser_header_rpt.action_information6;

				--RapporteringsenhetOrganisasjonsnummer-datadef-21772
				l_org_number := rg_rser_header_rpt.action_information4;

				--RapporteringsenhetNavn-datadef-21771
				l_emp_name := rg_rser_header_rpt.action_information6;

				--RapporteringsenhetAdresse-datadef-21773
				l_address :=  rg_rser_header_rpt.action_information7||' '||rg_rser_header_rpt.action_information7;

				--RapporteringsenhetPostnummer-datadef-21774
				l_postal_code :=rg_rser_header_rpt.action_information9;

				--RapporteringsenhetPoststed-datadef-21775
				l_post_office :=  rg_rser_header_rpt.action_information10;

				--ArbeidsgiveravgiftBeregningType-datadef-16522
				l_industry_exception := rg_rser_header_rpt.action_information17;

				--ArbeidsgiveravgiftBunnfradrag-datadef-16517
				l_exemption_limit := FND_NUMBER.CANONICAL_TO_NUMBER(rg_rser_header_rpt.action_information18)
								     - FND_NUMBER.CANONICAL_TO_NUMBER( rg_rser_sum_rpt.lu_el_used)
								     + FND_NUMBER.CANONICAL_TO_NUMBER( rg_rser_sum_rpt.lu_el_used_bimonth ) ;
				--ArbeidsgiveravgiftUtenlandskGrunnlag-datadef-16518
				l_spr_emp_contri_base := FND_NUMBER.CANONICAL_TO_NUMBER(rg_rser_sum_rpt.fe_spr_contribution_basis);

				--ArbeidsgiveravgiftUtenlandskArbeidstakerBergenet-datadef-6049
				l_spr_calc_contribution := FND_NUMBER.CANONICAL_TO_NUMBER(rg_rser_sum_rpt.fe_spr_calc_contribution);

				--'AnsattUtenlandskManeder-datadef-16519'
				l_no_months := FND_NUMBER.CANONICAL_TO_NUMBER(rg_rser_sum_rpt.no_month);

				 --'ArbeidsgiveravgiftUtenlandskManedBeregnet-datadef-16520'
				l_fma_calc_contribution :=  FND_NUMBER.CANONICAL_TO_NUMBER(rg_rser_sum_rpt.fe_fma_calc_contribution);

				--'ArbeidsgiveravgiftUnder62ArGrunnlag-datadef-6051'
				l_tot_u_contribution_basis :=FND_NUMBER.CANONICAL_TO_NUMBER(rg_rser_sum_rpt.u_contribution_basis);


				--'ArbeidsgiveravgiftOver62ArGrunnlag-datadef-16510'
				l_tot_o_contribution_basis :=  FND_NUMBER.CANONICAL_TO_NUMBER(rg_rser_sum_rpt.o_contribution_basis);

				 --'ArbeidsgiveravgiftRestFribelop-datadef-21169'
				l_remain_exemp_limit := FND_NUMBER.CANONICAL_TO_NUMBER(rg_rser_header_rpt.action_information18)
									      - FND_NUMBER.CANONICAL_TO_NUMBER( rg_rser_sum_rpt.lu_el_used) ;
				-- 'ArbeidsgiveravgiftSkyldig-datadef-223'
				l_tot_emp_contribution :=   FND_NUMBER.CANONICAL_TO_NUMBER(rg_rser_sum_rpt. fe_spr_calc_contribution)
												+  FND_NUMBER.CANONICAL_TO_NUMBER(rg_rser_sum_rpt.fe_fma_calc_contribution)
												+ FND_NUMBER.CANONICAL_TO_NUMBER(rg_rser_sum_rpt.o_calc_contribution)
												+ FND_NUMBER.CANONICAL_TO_NUMBER(rg_rser_sum_rpt.u_calc_contribution) ;

				--'KIDnummerArbeidsgiveravgift-datadef-16512'
				l_k_emp_contribution := NULL;

				--'Forskuddstrekk-datadef-2903'
				l_tot_withholding_tax := FND_NUMBER.CANONICAL_TO_NUMBER(rg_rser_sum_rpt.Witholding_Tax);

				-- 'KIDnummerForskuddstrekk-datadef-16511'
				l_k_withholding_tax :=  NULL;


				--RefusjonRTVGrunnlagSone1Under62Ar-datadef-25054
				l_u_zone1 := NULL;

				--RefusjonRTVGrunnlagSone1Over62Ar-datadef-25055
				l_o_zone1 :=  NULL;

				--RefusjonRTVGrunnlagSone2Under62Ar-datadef-25056
				l_u_zone2 := NULL;

				--RefusjonRTVGrunnlagSone2Over62Ar-datadef-25057
				l_o_zone2 :=  NULL;

				--RefusjonRTVGrunnlagSone3Under62Ar-datadef-25058
				l_u_zone3 := NULL;

				--RefusjonRTVGrunnlagSone3Over62Ar-datadef-25059
				l_o_zone3 :=  NULL;

				--RefusjonRTVGrunnlagSone4Under62Ar-datadef-25060
				l_u_zone4 := NULL;

				--RefusjonRTVGrunnlagSone4Over62Ar-datadef-25061
				l_o_zone4 :=  NULL;

				--RefusjonRTVGrunnlagSone5Under62Ar-datadef-25062
				l_u_zone5 := NULL;

				--RefusjonRTVGrunnlagSone5Over62Ar-datadef-25063
				l_o_zone5 :=  NULL;

				hr_utility.set_location('inside GETDATA ',20);


				/*Fetching the characterset of the Database*/
				l_IANA_charset :=HR_NO_UTILITY.get_IANA_charset ;

				/*Generate an xml string*/
				dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
				dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);

				 l_str1 := '<?xml version="1.0" encoding="'||l_IANA_charset||'"?>
				<Skjema xmlns:brreg="http://www.brreg.no/or" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				tittel="Terminoppgave for  arbeidsgiveravgift og forskuddstrekk." gruppeid="52" spesifikasjonsnummer="4578"
				skjemanummer="669" etatid="974761076" blankettnummer="RF-1037">';
				dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );

				 l_str1 :='<GenerellInformasjon-grp-986 gruppeid="986">
						<Periode-grp-57 gruppeid="57">
							<OppgaveTermin-datadef-11819 orid="11819">'||l_term||'</OppgaveTermin-datadef-11819>
							<OppgaveAr-datadef-11236 orid="11236">'||l_year||'</OppgaveAr-datadef-11236>
						</Periode-grp-57>
						<Skatteoppkrever-grp-989 gruppeid="989">
							<SkatteoppkreverKommuneNummer-datadef-16513 orid="16513">'||l_Tax_Mun_No||'</SkatteoppkreverKommuneNummer-datadef-16513>
							<SkatteoppkreverKommuneNavn-datadef-8486 orid="8486">'||l_mun_name||'</SkatteoppkreverKommuneNavn-datadef-8486>
						</Skatteoppkrever-grp-989>
						<Innsender-grp-56 gruppeid="56">
							<RapporteringsenhetOrganisasjonsnummer-datadef-21772 orid="21772">'||l_org_number||'</RapporteringsenhetOrganisasjonsnummer-datadef-21772>
							<RapporteringsenhetNavn-datadef-21771 orid="21771">'||l_emp_name||'</RapporteringsenhetNavn-datadef-21771>
							<RapporteringsenhetAdresse-datadef-21773 orid="21773">'||l_address||'</RapporteringsenhetAdresse-datadef-21773>
							<RapporteringsenhetPostnummer-datadef-21774 orid="21774">'||l_postal_code ||'</RapporteringsenhetPostnummer-datadef-21774>
							<RapporteringsenhetPoststed-datadef-21775 orid="21775">'||l_post_office||'</RapporteringsenhetPoststed-datadef-21775>
						</Innsender-grp-56>
					</GenerellInformasjon-grp-986>';
				dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );

				 l_str1 :='<BransjeFribelopOgSpesielleGrupper-grp-5698 gruppeid="5698">
						<Bransje-grp-169 gruppeid="169">
							<ArbeidsgiveravgiftBeregningType-datadef-16522 orid="16522">'||l_industry_exception ||'</ArbeidsgiveravgiftBeregningType-datadef-16522>
							<ArbeidsgiveravgiftBunnfradrag-datadef-16517 orid="16517">'||l_exemption_limit||'</ArbeidsgiveravgiftBunnfradrag-datadef-16517>
						</Bransje-grp-169>
						<UTL1-grp-69 gruppeid="69">
							<ArbeidsgiveravgiftUtenlandskGrunnlag-datadef-16518 orid="16518">'||l_spr_emp_contri_base||'</ArbeidsgiveravgiftUtenlandskGrunnlag-datadef-16518>
							<ArbeidsgiveravgiftUtenlandskArbeidstakerBergenet-datadef-6049 orid="6049">'||l_spr_calc_contribution||'</ArbeidsgiveravgiftUtenlandskArbeidstakerBergenet-datadef-6049>
						</UTL1-grp-69>
						<UTL2-grp-71 gruppeid="71">
							<AnsattUtenlandskManeder-datadef-16519 orid="16519">'||l_no_months||'</AnsattUtenlandskManeder-datadef-16519>
							<ArbeidsgiveravgiftUtenlandskManedBeregnet-datadef-16520 orid="16520">'||l_fma_calc_contribution||'</ArbeidsgiveravgiftUtenlandskManedBeregnet-datadef-16520>
						</UTL2-grp-71>
					</BransjeFribelopOgSpesielleGrupper-grp-5698>';
				dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );


				 l_str1 :='<ArbeidsgiveravgiftsgrunnlagForskuddstrekkOgRefusjon-grp-4953 gruppeid="4953">';
				dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );

				/*Loop through records in the body*/

				FOR rg_rser_body_rpt IN csr_rser_body_rpt( l_payroll_action_id)
				LOOP
					--KommuneNummer-datadef-5950
					l_municipal_number :=rg_rser_body_rpt.action_information3;

					--KommuneNavn-datadef-5932
					l_municipal_name :=  rg_rser_body_rpt.action_information4;

					--ArbeidsgiveravgiftSone-datadef-3545
					l_zone := rg_rser_body_rpt.action_information5;

					--ArbeidsgiveravgiftUnder62ArGrunnlagKommune-datadef-6047
					l_emp_contri_base_u :=FND_NUMBER.CANONICAL_TO_NUMBER(rg_rser_body_rpt.action_information7);

					--ArbeidsgiveravgiftOver62ArGrunnlagKommune-datadef-16509
					l_emp_contri_base_o := FND_NUMBER.CANONICAL_TO_NUMBER(rg_rser_body_rpt.action_information8);

					--ForskuddstrekkKommune-datadef-6046
					l_withholding_tax :=  FND_NUMBER.CANONICAL_TO_NUMBER(rg_rser_body_rpt.action_information6);

					l_str1 :=	'<ForskuddstrekkOgGrunnlagArbeidsgiveravgift-grp-67 gruppeid="67">
								<KommuneNummer-datadef-5950 orid="5950">'||l_municipal_number ||'</KommuneNummer-datadef-5950>
								<KommuneNavn-datadef-5932 orid="5932">'||l_municipal_name||'</KommuneNavn-datadef-5932>
								<ArbeidsgiveravgiftSone-datadef-3545 orid="3545">'||l_zone||'</ArbeidsgiveravgiftSone-datadef-3545>
								<ArbeidsgiveravgiftUnder62ArGrunnlagKommune-datadef-6047 orid="6047">'||l_emp_contri_base_u||'</ArbeidsgiveravgiftUnder62ArGrunnlagKommune-datadef-6047>
								<ArbeidsgiveravgiftOver62ArGrunnlagKommune-datadef-16509 orid="16509">'||l_emp_contri_base_o||'</ArbeidsgiveravgiftOver62ArGrunnlagKommune-datadef-16509>
								<ForskuddstrekkKommune-datadef-6046 orid="6046">'||l_withholding_tax||'</ForskuddstrekkKommune-datadef-6046>
							</ForskuddstrekkOgGrunnlagArbeidsgiveravgift-grp-67>';
					dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );
				END LOOP;

				l_str1 :='<Refusjonsgrunnlag-grp-5699 gruppeid="5699">
							<RefusjonSone1-grp-5700 gruppeid="5700">
								<RefusjonRTVGrunnlagSone1Under62Ar-datadef-25054 orid="25054">'||l_u_zone1||'</RefusjonRTVGrunnlagSone1Under62Ar-datadef-25054>
								<RefusjonRTVGrunnlagSone1Over62Ar-datadef-25055 orid="25055">'||l_o_zone1||'</RefusjonRTVGrunnlagSone1Over62Ar-datadef-25055>
							</RefusjonSone1-grp-5700>
							<RefusjonSone2-grp-5701 gruppeid="5701">
								<RefusjonRTVGrunnlagSone2Under62Ar-datadef-25056 orid="25056">'||l_u_zone2||'</RefusjonRTVGrunnlagSone2Under62Ar-datadef-25056>
								<RefusjonRTVGrunnlagSone2Over62Ar-datadef-25057 orid="25057">'||l_o_zone2||'</RefusjonRTVGrunnlagSone2Over62Ar-datadef-25057>
							</RefusjonSone2-grp-5701>
							<RefusjonSone3-grp-5702 gruppeid="5702">
								<RefusjonRTVGrunnlagSone3Under62Ar-datadef-25058 orid="25058">'||l_u_zone3||'</RefusjonRTVGrunnlagSone3Under62Ar-datadef-25058>
								<RefusjonRTVGrunnlagSone3Over62Ar-datadef-25059 orid="25059">'||l_o_zone3||'</RefusjonRTVGrunnlagSone3Over62Ar-datadef-25059>
							</RefusjonSone3-grp-5702>
							<RefusjonSone4-grp-5703 gruppeid="5703">
								<RefusjonRTVGrunnlagSone4Under62Ar-datadef-25060 orid="25060">'||l_u_zone4||'</RefusjonRTVGrunnlagSone4Under62Ar-datadef-25060>
								<RefusjonRTVGrunnlagSone4Over62Ar-datadef-25061 orid="25061">'||l_o_zone4||'</RefusjonRTVGrunnlagSone4Over62Ar-datadef-25061>
							</RefusjonSone4-grp-5703>
							<RefusjonSone5-grp-5704 gruppeid="5704">
								<RefusjonRTVGrunnlagSone5Under62Ar-datadef-25062 orid="25062">'||l_u_zone5||'</RefusjonRTVGrunnlagSone5Under62Ar-datadef-25062>
								<RefusjonRTVGrunnlagSone5Over62Ar-datadef-25063 orid="25063">'||l_o_zone5||'</RefusjonRTVGrunnlagSone5Over62Ar-datadef-25063>
							</RefusjonSone5-grp-5704>
						</Refusjonsgrunnlag-grp-5699>';
				dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );

				 l_str1 :='</ArbeidsgiveravgiftsgrunnlagForskuddstrekkOgRefusjon-grp-4953>';
				dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );

				 l_str1 :='<Resultater-grp-74 gruppeid="74">
							<Kontrollsummer-grp-4909 gruppeid="4909">
								<ArbeidsgiveravgiftUnder62ArGrunnlag-datadef-6051 orid="6051">'||l_tot_u_contribution_basis||'</ArbeidsgiveravgiftUnder62ArGrunnlag-datadef-6051>
								<ArbeidsgiveravgiftOver62ArGrunnlag-datadef-16510 orid="16510">'||l_tot_o_contribution_basis||'</ArbeidsgiveravgiftOver62ArGrunnlag-datadef-16510>
								<ArbeidsgiveravgiftRestFribelop-datadef-21169 orid="21169">'||l_remain_exemp_limit||'</ArbeidsgiveravgiftRestFribelop-datadef-21169>
							</Kontrollsummer-grp-4909>
							<Arbeidsgiveravgift-grp-4910 gruppeid="4910">
								<ArbeidsgiveravgiftSkyldig-datadef-223 orid="223">'||l_tot_emp_contribution||'</ArbeidsgiveravgiftSkyldig-datadef-223>
								<KIDnummerArbeidsgiveravgift-datadef-16512 orid="16512">'||l_k_emp_contribution||'</KIDnummerArbeidsgiveravgift-datadef-16512>
							</Arbeidsgiveravgift-grp-4910>
							<Forskuddstrekk-grp-4911 gruppeid="4911">
								<Forskuddstrekk-datadef-2903 orid="2903">'||l_tot_withholding_tax||'</Forskuddstrekk-datadef-2903>
								<KIDnummerForskuddstrekk-datadef-16511 orid="16511">'||l_k_withholding_tax||'</KIDnummerForskuddstrekk-datadef-16511>
							</Forskuddstrekk-grp-4911>
						</Resultater-grp-74>
					</Skjema>';
				dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );

				hr_utility.set_location('Inside GETDATA',30);

				p_xml := l_xfdf_string;

				hr_utility.set_location('Leaving GETDATA',40);

	           	    END GET_DATA;

END PAY_NO_RSER;

/
