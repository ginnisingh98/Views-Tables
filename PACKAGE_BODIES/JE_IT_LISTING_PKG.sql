--------------------------------------------------------
--  DDL for Package Body JE_IT_LISTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JE_IT_LISTING_PKG" AS
/* $Header: jeitlstb.pls 120.6.12010000.3 2009/02/23 07:36:29 rahulkum ship $ */

-------------------------------------------------------------------------------
--Global Variables
-------------------------------------------------------------------------------
gv_ledger_id               NUMBER(15);
gv_balancing_segment_value VARCHAR2(25);
gv_chart_of_accounts_id    NUMBER(15);
gn_legal_entity_id	varchar2(240);
gv_repent_trn	varchar2(50);
gd_period_start_date	date;
gd_period_end_date	date;
gv_currency_code	varchar2(60);
gv_vat_country_code	varchar2(15);

g_lines_per_commit	NUMBER;

gn_legal_vat_rep_entity_id NUMBER;
gn_ar_app_id		NUMBER;
gn_ap_app_id		NUMBER;
g_rec_per_eft		NUMBER;



gt_party_id             JE_IT_LISTING_PKG.tab_party_id;
gt_trx_type_code        JE_IT_LISTING_PKG.tab_trx_type_code;
gt_trx_type_id          JE_IT_LISTING_PKG.tab_trx_type_id;
gt_doc_seq_num          JE_IT_LISTING_PKG.tab_doc_seq_num;
gt_doc_seq_val          JE_IT_LISTING_PKG.tab_doc_seq_val;
gt_trx_date             JE_IT_LISTING_PKG.tab_trx_date;
gt_trx_id               JE_IT_LISTING_PKG.tab_trx_id;
gt_trx_num              JE_IT_LISTING_PKG.tab_trx_num;
gt_trx_line_dist_id     JE_IT_LISTING_PKG.tab_trx_dist_id;
gt_trx_tax_dist_id      JE_IT_LISTING_PKG.tab_trx_dist_id;
gt_trx_line_type_code   JE_IT_LISTING_PKG.tab_trx_line_type_code;
gt_trx_tax_line_type_code   JE_IT_LISTING_PKG.tab_trx_line_type_code;
gt_trx_line_tax_rate_id JE_IT_LISTING_PKG.tab_trx_line_tax_rate_id;
gt_inv_tax_line_amount  JE_IT_LISTING_PKG.tab_inv_line_amount;
gt_inv_line_amount      JE_IT_LISTING_PKG.tab_inv_line_amount;
gt_inv_tax_line_amount_cm  JE_IT_LISTING_PKG.tab_inv_line_amount;
gt_inv_line_amount_cm      JE_IT_LISTING_PKG.tab_inv_line_amount;
gt_trx_type              JE_IT_LISTING_PKG.tab_inv_type;
gt_party_vat_reg_num     JE_IT_LISTING_PKG.tab_party_vat_reg_num;
gt_party_fiscal_id_num   JE_IT_LISTING_PKG.tab_party_fiscal_id_num;

g_created_by            NUMBER(15);
g_creation_date         DATE;
g_last_updated_by       NUMBER(15);
g_last_update_date      DATE;
g_last_update_login     NUMBER(15);

g_debug_flag 		VARCHAR2(1);
g_error_buffer         	VARCHAR2(200);
g_errbuf		VARCHAR2(200);
g_retcode		NUMBER;
g_current_runtime_level CONSTANT NUMBER := fnd_log.g_current_runtime_level;
g_level_statement     	CONSTANT NUMBER := fnd_log.level_statement;
g_level_procedure    	CONSTANT NUMBER := fnd_log.level_procedure;
g_level_event        	CONSTANT NUMBER := fnd_log.level_event;
g_level_exception     	CONSTANT NUMBER := fnd_log.level_exception;
g_level_error         	CONSTANT NUMBER := fnd_log.level_error;
g_level_unexpected    	CONSTANT NUMBER := fnd_log.level_unexpected;

--------------------------------------------------------------------------------
--Private Methods Declaration
--------------------------------------------------------------------------------

PROCEDURE Fetch_trx_data_ap(
                p_vat_reporting_entity_id IN NUMBER,
		p_year_of_declaration IN NUMBER,
		p_vat_reg IN VARCHAR2);

PROCEDURE Fetch_trx_data_ar(
                p_vat_reporting_entity_id IN NUMBER,
		p_year_of_declaration IN NUMBER,
		p_vat_reg IN VARCHAR2);

PROCEDURE Insert_tax_data(
                p_vat_reporting_entity_id IN NUMBER,
		p_year_of_declaration IN NUMBER,
		p_app_id 	      IN NUMBER);

PROCEDURE Init_gt_variables;

PROCEDURE Generate_trx_headers(
                p_vat_reporting_entity_id IN NUMBER,
		p_year_of_declaration IN NUMBER,
		p_cust_sort_col	 IN 	    VARCHAR2,
		p_vend_sort_col	 IN 	    VARCHAR2,
                p_group_parties_flag IN     VARCHAR2);

PROCEDURE Initialize_proc_var(
                p_vat_reporting_entity_id IN NUMBER,
		p_year_of_declaration IN NUMBER);




--------------------------------------------------------------------------------
--Public Methods
--------------------------------------------------------------------------------
/*===========================================================================+
 | PROCEDURE                                                                 |
 |   Extract_Data()                                                          |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure                         	 						     |
 |     (1) Checks the if the setup information is freezed or not	         |
 |     (2) Purges the existing data using Purge_trx_data() if the procedure  |
 |           is called for the same period again in preliminary mode.        |
 |     (3)  Fetches the AP and AR lines information and populates the        |
 |		parties table using Fetch_trx_data_ap and                            |
 |		Fetch_trx_data_ar.                                                   |
 |     (4)  Runs the report and generates EFT(optionally).                   |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |  Date           Author          Description                               |
 |  ============  ==============  =================================          |
 |   11-Dec-2007   spasupun	     Initial  Version.                       |
 |   20-Feb-2009   rahulkum          Bug:8274173 Added NVL for MAX(TRANSMISSION_NUM)|
 +===========================================================================*/
PROCEDURE Extract_Data(
        errbuf   	 OUT NOCOPY VARCHAR2,
  	    retcode  	 OUT NOCOPY VARCHAR2,
		P_VAT_REPORTING_ENTITY_ID IN NUMBER,
		P_YEAR_OF_DECLARATION 	  IN NUMBER,
		P_REPORT_TYPE          IN VARCHAR2,
		P_DUMMY                   IN NUMBER,
		P_VAT   	              IN VARCHAR2,
		P_REPORT_MODE 	          IN VARCHAR2,
		P_EFT	 	              IN VARCHAR2,
		P_PARTY_LIMIT	          IN NUMBER,
		P_CUST_SORT_COL	          IN VARCHAR2,
		P_VEND_SORT_COL	          IN VARCHAR2,
                P_GROUP_PARTIES_FLAG      IN VARCHAR2
       	) IS

        l_setup_not_available    EXCEPTION;
		l_setup_not_frozen 	     EXCEPTION;
		l_final_already_run      EXCEPTION;
		l_prelim_not_run         EXCEPTION;
		l_final_not_run          EXCEPTION;
		e_request_submit_error 	 EXCEPTION;

		l_vat_registration_flag  BOOLEAN;
		l_gen_efile 	         BOOLEAN;
		l_request_id		     NUMBER;
		l_appln_name 		 VARCHAR2(10);
		l_con_cp_list    	 VARCHAR2(15);
		l_con_cp_list_desc 	 VARCHAR2(200);
		l_con_cp_elec    	 VARCHAR2(15);
		l_con_cp_elec_desc   VARCHAR2(200);
		l_xml_layout		 BOOLEAN;
		l_eft_count		     NUMBER;
		p_status_code 		 VARCHAR2(30) := NULL;
		l_entity_identifier jg_zz_vat_rep_entities.entity_identifier%type;


		CURSOR cur_status(P_VAT_REPORTING_ENTITY_ID NUMBER,P_YEAR_OF_DECLARATION NUMBER) IS
			SELECT status_code
			FROM je_it_list_hdr_all
			WHERE vat_reporting_entity_id= P_VAT_REPORTING_ENTITY_ID
			AND year_of_declaration = P_YEAR_OF_DECLARATION;

		CURSOR cur_frozen(P_VAT_REPORTING_ENTITY_ID NUMBER,P_YEAR_OF_DECLARATION NUMBER) IS
			SELECT freeze_indicator_flag
			FROM je_it_setup_hdr_all
			WHERE vat_reporting_entity_id= P_VAT_REPORTING_ENTITY_ID
			AND year_of_declaration = P_YEAR_OF_DECLARATION;

        CURSOR entity_identifier(P_VAT_REPORTING_ENTITY_ID NUMBER) IS
        	SELECT LEGAL.ENTITY_IDENTIFIER,LEGAL.VAT_REPORTING_ENTITY_ID
        	FROM jg_zz_vat_rep_entities LEGAL,
        	     jg_zz_vat_rep_entities ACC
            WHERE ACC.VAT_REPORTING_ENTITY_ID = P_VAT_REPORTING_ENTITY_ID
            AND  ((ACC.ENTITY_TYPE_CODE = 'ACCOUNTING'
                   AND ACC.MAPPING_VAT_REP_ENTITY_ID = LEGAL.VAT_REPORTING_ENTITY_ID)
                   OR
                  (ACC.ENTITY_TYPE_CODE = 'LEGAL'
                   AND ACC.VAT_REPORTING_ENTITY_ID = LEGAL.VAT_REPORTING_ENTITY_ID)
                  );

BEGIN

	IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JE.plsql.JE_IT_LISTING_PKG.Extract_Data','Start PROCEDURE Extract_Data');
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Extract_Data','Parameters are :');
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Extract_Data','	P_VAT_REPORTING_ENTITY_ID ='||P_VAT_REPORTING_ENTITY_ID);
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Extract_Data','	P_YEAR_OF_DECLARATION ='||P_YEAR_OF_DECLARATION);
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Extract_Data','    P_REPORT_TYPE ='||P_REPORT_TYPE);
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Extract_Data','	P_VAT ='||P_VAT);
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Extract_Data','	P_REPORT_MODEL = '||P_REPORT_MODE);
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Extract_Data','	P_EFT = '||P_EFT);
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Extract_Data','	P_CUST_SORT_COL = '||P_CUST_SORT_COL);
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Extract_Data','	P_VEND_SORT_COL = '||P_VEND_SORT_COL);
           FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Extract_Data','	P_GROUP_PARTIES_FLAG = '||P_GROUP_PARTIES_FLAG);
	 END IF;
	g_retcode :=0;
	l_appln_name       := 'JE';
	l_con_cp_list      := 'JEITLSTR_XMLP';
	l_con_cp_elec      := 'JEITLSTE_XMLP';
  	l_con_cp_list_desc := 'Italian Annual Customer and Supplier Listing Report';
	l_con_cp_elec_desc := 'Italian Annual Customer and Supplier Electronic Format Report';

	l_eft_count        := 0;
	l_gen_efile	                   :=TRUE;
	g_rec_per_eft                  :=P_PARTY_LIMIT;


	IF P_EFT = 'N' THEN
		l_gen_efile :=FALSE;
	END IF;

	BEGIN
		OPEN entity_identifier(P_VAT_REPORTING_ENTITY_ID);
		FETCH entity_identifier INTO l_entity_identifier,gn_legal_vat_rep_entity_id;
		CLOSE entity_identifier;

	EXCEPTION
		WHEN OTHERS THEN
			g_errbuf :='Exception in fetching legal vat reporting entity id';
			g_retcode := 2;
			IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
				FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Extract_Data','Exception in fetching legal vat reporting entity id');
			END IF;
			errbuf := g_errbuf;
  		    retcode:= g_retcode;
	  	  RETURN;
	END;

	BEGIN
		OPEN cur_frozen(gn_legal_vat_rep_entity_id,P_YEAR_OF_DECLARATION);
		FETCH cur_frozen INTO p_status_code;
		CLOSE cur_frozen;

		IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
			IF p_status_code IS NULL THEN
            FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Extract_Data','Not Setup vailable for the reporting entity and year:');
            END IF;
		END IF;

	EXCEPTION
		WHEN OTHERS THEN
			g_errbuf :='Exception in fetching Freeze Status';
			g_retcode := 2;
			IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
				FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Extract_Data','Exception in fetching cur_frozen - p_status_code');
			END IF;
			errbuf := g_errbuf;
  		    retcode:= g_retcode;
	  	  RETURN;
	END;

        IF p_status_code IS NULL THEN
                RAISE l_setup_not_available;
        ELSIF p_status_code <> 'Y' THEN
		        RAISE l_setup_not_frozen;
	    END IF;

    p_status_code := NULL;

   	BEGIN
		OPEN cur_status(P_VAT_REPORTING_ENTITY_ID,P_YEAR_OF_DECLARATION);
		FETCH cur_status INTO p_status_code;
		CLOSE cur_status;
	EXCEPTION
		WHEN OTHERS THEN
			g_errbuf :='Exception in fetching Status Code';
			g_retcode := 2;
			IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
				FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Extract_Data','Exception in fetching cur_status - p_status_code');
			END IF;
			errbuf := g_errbuf;
		    retcode:= g_retcode;
   		 RETURN;
	END;

       IF P_REPORT_TYPE = 'P'  THEN
            IF p_status_code IS NULL THEN
		      	p_status_code := 'P';
		    ELSIF p_status_code='F' THEN
    	         RAISE l_final_already_run;
    		END IF;
 	   ELSIF P_REPORT_TYPE = 'F' THEN
             IF p_status_code IS NULL  THEN
               RAISE l_prelim_not_run;
             ELSIF p_status_code='F' THEN
    	         RAISE l_final_already_run;
             END IF;
       ELSIF P_REPORT_TYPE = 'R' THEN
            IF p_status_code IS NULL OR p_status_code = 'P'  THEN
              RAISE l_final_not_run;
            END IF;
       END IF;

	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(G_LEVEL_STATEMENT, 'JE.plsql.JE_IT_LISTING_PKG.Extract_Data','p_status_code = '||p_status_code);
	END IF;

	IF P_REPORT_TYPE = 'P' THEN

		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
			FND_LOG.STRING(G_LEVEL_STATEMENT, 'JE.plsql.JE_IT_LISTING_PKG.Extract_Data','Calling PROCEDURE Purge_trx_data');
		END IF;

		Purge_trx_data(P_VAT_REPORTING_ENTITY_ID,P_YEAR_OF_DECLARATION);

		IF g_retcode = 2 THEN
			errbuf := g_errbuf;
			retcode:= g_retcode;
			RETURN;
		END IF;

		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
			FND_LOG.STRING(G_LEVEL_STATEMENT, 'JE.plsql.JE_IT_LISTING_PKG.Extract_Data','Calling PROCEDURE Initialize_proc_var');
		END IF;

		Initialize_proc_var(P_VAT_REPORTING_ENTITY_ID,P_YEAR_OF_DECLARATION);

		IF g_retcode = 2 THEN
			errbuf := g_errbuf;
			retcode:= g_retcode;
			RETURN;
		END IF;

		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
			FND_LOG.STRING(G_LEVEL_STATEMENT, 'JE.plsql.JE_IT_LISTING_PKG.Extract_Data','Calling PROCEDURE Fetch_trx_data_ap');
		END IF;

		Fetch_trx_data_ap(P_VAT_REPORTING_ENTITY_ID,P_YEAR_OF_DECLARATION,P_VAT);

		IF g_retcode = 2 THEN
			errbuf := g_errbuf;
			retcode:= g_retcode;
			RETURN;
		END IF;

		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
			FND_LOG.STRING(G_LEVEL_STATEMENT, 'JE.plsql.JE_IT_LISTING_PKG.Extract_Data','Calling PROCEDURE Fetch_trx_data_ar');
		END IF;

		Fetch_trx_data_ar(P_VAT_REPORTING_ENTITY_ID,P_YEAR_OF_DECLARATION,P_VAT);

		IF g_retcode = 2 THEN
			errbuf := g_errbuf;
			retcode:= g_retcode;
			RETURN;
		END IF;

		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
			FND_LOG.STRING(G_LEVEL_STATEMENT, 'JE.plsql.JE_IT_LISTING_PKG.Extract_Data','Calling PROCEDURE Generate_trx_headers');
		END IF;

		Generate_trx_headers(P_VAT_REPORTING_ENTITY_ID,P_YEAR_OF_DECLARATION,P_CUST_SORT_COL,P_VEND_SORT_COL,P_GROUP_PARTIES_FLAG);

		IF g_retcode = 2 THEN
			errbuf := g_errbuf;
			retcode:= g_retcode;
			RETURN;
		END IF;

	ELSIF P_REPORT_TYPE = 'F' OR  P_REPORT_TYPE = 'R'  THEN
        l_gen_efile :=TRUE;
    END IF;

    -- Code for Running the Concurrent Programs.

	l_xml_layout := FND_REQUEST.ADD_LAYOUT(l_appln_name,'JEITLSTR','en','US','PDF');

	l_request_id := fnd_request.submit_request(application => l_appln_name,
					                           program     => l_con_cp_list,
                    						   description => l_con_cp_list_desc,
                    						   start_time  => NULL,
                    						   sub_request => FALSE,
                    						   argument1   => P_VAT_REPORTING_ENTITY_ID,
                    						   argument2   => P_YEAR_OF_DECLARATION,
					                       	   argument3   => P_REPORT_MODE,
					                       	   argument4   => P_REPORT_TYPE,
					                       	   argument5   => CHR(0));

	IF l_request_id = 0 THEN
		g_errbuf :='Exception in running the Report';
		RAISE e_request_submit_error;
	END IF;

	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(G_LEVEL_STATEMENT, 'JE.plsql.JE_IT_LISTING_PKG.Extract_Data','l_request_id = '||l_request_id);
	END IF;
	  retcode := 0; -- CP completed successfully

	IF l_gen_efile THEN
		BEGIN
			SELECT NVL(MAX(TRANSMISSION_NUM),0) --Bug:8274173
			INTO l_eft_count
			FROM JE_IT_LIST_PARTIES_ALL
			WHERE vat_reporting_entity_id = P_VAT_REPORTING_ENTITY_ID
			AND year_of_declaration = P_YEAR_OF_DECLARATION;
		EXCEPTION
			WHEN OTHERS THEN
				g_retcode :=1;
				IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
					FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Extract_Date','Exception in fetching l_eft_count');
				END IF;
		END;

		IF g_retcode = 1 THEN
			g_errbuf :='Exception in fetching l_eft_count';
			RAISE e_request_submit_error;
		END IF;

		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
			FND_LOG.STRING(G_LEVEL_STATEMENT, 'JE.plsql.JE_IT_LISTING_PKG.Extract_Data','l_eft_count = '||l_eft_count);
		END IF;

		FOR i IN 1..l_eft_count LOOP
			l_xml_layout := FND_REQUEST.ADD_LAYOUT(l_appln_name,'JEITLSTE','en','US','ETEXT');
			l_request_id := fnd_request.submit_request(application => l_appln_name,
								                       program     => l_con_cp_elec,
                    								   description => l_con_cp_elec_desc,
                    								   start_time  => NULL,
					                       			   sub_request => FALSE,
					                       			   argument1   => P_VAT_REPORTING_ENTITY_ID,
                    								   argument2   => P_YEAR_OF_DECLARATION, --Fiscal year
					                       			   argument3   => i,  --elec prog number
										   argument4   => P_REPORT_TYPE,
                    								   argument5   => CHR(0));

			  IF l_request_id = 0 THEN
			  	    g_errbuf :='Exception in generating the EFT';
				    RAISE e_request_submit_error;
			  END IF;

			  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
			  	FND_LOG.STRING(G_LEVEL_STATEMENT, 'JE.plsql.JE_IT_LISTING_PKG.Extract_Data','l_request_id,'||i||' = '||l_request_id);
			  END IF;
		END LOOP;
   END IF;

       IF P_REPORT_TYPE = 'F'  THEN
          Final_data(errbuf
                    ,retcode
                    ,p_vat_reporting_entity_id
                    ,p_year_of_declaration);
       END IF;

        IF g_retcode = 1 THEN
			g_errbuf :='Exception in Finalizing Data';
			RAISE e_request_submit_error;
		END IF;


	IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JE.plsql.JE_IT_LISTING_PKG.Extract_Data','End PROCEDURE Extract_Data');
	END IF;

EXCEPTION
	WHEN l_setup_not_frozen THEN
		IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
			FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Extract_Data','Exception in PROCEDURE Extract_Data - l_setup_not_frozen');
		END IF;
		FND_MESSAGE.SET_NAME('JE','JE_IT_SETUP_NOT_FROZEN');
    	        FND_MESSAGE.SET_TOKEN('VAT_REP',l_entity_identifier);
                FND_MESSAGE.SET_TOKEN('VAT_YEAR',P_YEAR_OF_DECLARATION);
		errbuf :=FND_MESSAGE.get;
		retcode := 2; -- Error
		g_error_buffer  := SQLCODE || ': ' || SUBSTR(SQLERRM, 1, 80);
		FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
	WHEN l_setup_not_available THEN
		IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
			FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Extract_Data','Exception in PROCEDURE Extract_Data - Not setup_available');
		END IF;
		FND_MESSAGE.SET_NAME('JE','JE_IT_SETUP_NOT_AVAILABLE');
    	        FND_MESSAGE.SET_TOKEN('VAT_REP',l_entity_identifier);
                FND_MESSAGE.SET_TOKEN('VAT_YEAR',P_YEAR_OF_DECLARATION);
		errbuf :=FND_MESSAGE.get;
		retcode := 2; -- Error
			FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
	WHEN l_final_already_run THEN
		IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
			FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Extract_Data','Exception in PROCEDURE Extract_Data - l_final_already_run');
		END IF;
		FND_MESSAGE.SET_NAME('JE','JE_IT_FINAL_LISTING');
   	        FND_MESSAGE.SET_TOKEN('VAT_REP',l_entity_identifier);
                FND_MESSAGE.SET_TOKEN('VAT_YEAR',P_YEAR_OF_DECLARATION);
		errbuf :=FND_MESSAGE.get;
		retcode := 2; -- Error
		g_error_buffer  := SQLCODE || ': ' || SUBSTR(SQLERRM, 1, 80);
		FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
	WHEN l_prelim_not_run THEN
		IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
			FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Final_data','Exception in PROCEDURE Extract_Data - l_prelim_not_run ');
		END IF;
		FND_MESSAGE.SET_NAME('JE','JE_IT_PRELIMINARY_LISTING');
    	        FND_MESSAGE.SET_TOKEN('VAT_REP',l_entity_identifier);
                FND_MESSAGE.SET_TOKEN('VAT_YEAR',P_YEAR_OF_DECLARATION);
		errbuf :=FND_MESSAGE.get;
		retcode := 2; --Error
		g_error_buffer  := SQLCODE || ': ' || SUBSTR(SQLERRM, 1, 80);
		FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
	WHEN l_final_not_run THEN
		IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
			FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Final_data','Exception in PROCEDURE Extract_Data - l_final_not_run ');
		END IF;
		FND_MESSAGE.SET_NAME('JE','JE_IT_FINAL_NOT_RUN');
    	        FND_MESSAGE.SET_TOKEN('VAT_REP',l_entity_identifier);
                FND_MESSAGE.SET_TOKEN('VAT_YEAR',P_YEAR_OF_DECLARATION);
		errbuf :=FND_MESSAGE.get;
		retcode := 2; --Error
		g_error_buffer  := SQLCODE || ': ' || SUBSTR(SQLERRM, 1, 80);
		FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
	WHEN e_request_submit_error THEN
		IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
			FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Extract_Data','Exception in PROCEDURE Extract_Data - e_request_submit_error');
		END IF;
		errbuf := g_errbuf;
		retcode := 1; -- Warning
		g_error_buffer  := SQLCODE || ': ' || SUBSTR(SQLERRM, 1, 80);
		IF g_debug_flag = 'Y' THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
		END IF;
	WHEN OTHERS THEN
		IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
			FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Extract_Data','Exception in PROCEDURE Extract_Data ');
		END IF;
		errbuf :='Unknown exception occured in JE_IT_LISTING_PKG.Extract_Data';
		retcode := 2; -- Error
		g_error_buffer  := SQLCODE || ': ' || SUBSTR(SQLERRM, 1, 80);
		IF g_debug_flag = 'Y' THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
		END IF;
END Extract_Data;
--------------------------------------------------------------------------------
/*===========================================================================+
 | PROCEDURE                                                                 |
 |   Final_data()                                                            |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure 	 						     |
 |     (1) Checks the if the setup information is freezed or not.	     |
 |     (2) Sets the  STATUS_CODE to F in JE_IT_LIST_HDR if the  preliminary  |
 |		data is already extracted. 		                     |
 |     (3)  Runs the report and generates EFT.                               |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |  Date           Author          Description                               |
 |  ============  ==============  =================================          |
 |   13-Dec-2007   spasupun               Initial  Version.                  |
 |                                                                           |
 +===========================================================================*/
PROCEDURE Final_data(
		errbuf   	OUT 	NOCOPY VARCHAR2 ,
  		retcode   	OUT 	NOCOPY VARCHAR2,
		P_VAT_REPORTING_ENTITY_ID    IN NUMBER,
		P_YEAR_OF_DECLARATION	IN NUMBER) IS

		l_prelim_not_run               EXCEPTION;
		l_setup_not_frozen  	       EXCEPTION;
		l_final_already_run 	       EXCEPTION;
		e_request_submit_error 	       EXCEPTION;

		p_status_code 		       VARCHAR2(30);
		l_gen_efile 	               BOOLEAN;
		l_request_id		       NUMBER;
		l_appln_name 		       VARCHAR2(10);
		l_con_cp_list    	       VARCHAR2(15);
		l_con_cp_list_desc 	       VARCHAR2(200);
		l_con_cp_elec    	       VARCHAR2(15);
		l_con_cp_elec_desc  	       VARCHAR2(200);
		l_xml_layout		       BOOLEAN;
		l_eft_count		       NUMBER;

		CURSOR cur_status(p_vat_reporting_entity_id number,p_year_of_declaration number) IS
			SELECT status_code
			FROM je_it_list_hdr_all
			WHERE vat_reporting_entity_id = p_vat_reporting_entity_id
			ANd year_of_declaration = p_year_of_declaration;

BEGIN
	IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JE.plsql.JE_IT_LISTING_PKG.Final_data','Start PROCEDURE Final_data');
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Final_data','Parameters are :');
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Final_data','	P_VAT_REPORTING_ENTITY_ID ='||P_VAT_REPORTING_ENTITY_ID);
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Final_data','	P_YEAR_OF_DECLARATION ='||P_YEAR_OF_DECLARATION);

	END IF;


	BEGIN
		OPEN cur_status(p_vat_reporting_entity_id,p_year_of_declaration);
		FETCH cur_status INTO p_status_code;
		CLOSE cur_status;

	EXCEPTION
		WHEN OTHERS THEN
			g_retcode:=2;
			g_errbuf:='Exception in fetching Status Code';
			IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
				FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Final_data','Exception in fetching p_status_code for cur_status');
			END IF;
			g_error_buffer  := SQLCODE || ': ' || SUBSTR(SQLERRM, 1, 80);
			IF g_debug_flag = 'Y' THEN
				FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
			END IF;
	END;

	IF g_retcode = 2 THEN
		retcode:=g_retcode;
		errbuf:=g_errbuf;
		RETURN;
	END IF;

	IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(G_LEVEL_STATEMENT, 'JE.plsql.JE_IT_LISTING_PKG.Final_data','cur_status - p_status_code = '||p_status_code);
	END IF;

	IF p_status_code = 'P' THEN

		UPDATE JE_IT_LIST_HDR_ALL
		SET STATUS_CODE = 'F'
		WHERE vat_reporting_entity_id = p_vat_reporting_entity_id
		AND year_of_declaration = p_year_of_declaration;

		COMMIT;

	ELSIF p_status_code = 'F' THEN

		RAISE l_final_already_run;
	ELSE
		RAISE l_prelim_not_run;
	END IF;

EXCEPTION
	WHEN l_setup_not_frozen THEN
		IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
			FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Final_data','Exception in PROCEDURE Final_data - l_setup_not_frozen ');
		END IF;
		FND_MESSAGE.SET_NAME('JE','JE_IT_SETUP_NOT_FROZEN');
		errbuf :=FND_MESSAGE.get;
		retcode := 2; --Error
		g_error_buffer  := SQLCODE || ': ' || SUBSTR(SQLERRM, 1, 80);
		IF g_debug_flag = 'Y' THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
		END IF;
	WHEN l_prelim_not_run THEN
		IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
			FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Final_data','Exception in PROCEDURE Final_data - l_prelim_not_run ');
		END IF;
		FND_MESSAGE.SET_NAME('JE','JE_IT_PRELIMINARY_LISTING');
		errbuf :=FND_MESSAGE.get;
		FND_FILE.PUT_LINE(FND_FILE.LOG, errbuf);
		retcode := 2; --Error
		g_error_buffer  := SQLCODE || ': ' || SUBSTR(SQLERRM, 1, 80);
			FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
	WHEN l_final_already_run THEN
		IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
			FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Final_data','Exception in PROCEDURE Final_data - l_final_already_run ');
		END IF;
		errbuf :='Final mode is already run for this Fiscal Period.';
		retcode := 2; --Error
		g_error_buffer  := SQLCODE || ': ' || SUBSTR(SQLERRM, 1, 80);
			FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
	WHEN OTHERS THEN
		IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
			FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Final_data','Exception in PROCEDURE Final_data');
		END IF;
		errbuf :='Unknown Exception Occured in the package JE_IT_LISTING_PKG in PROCEDURE Final_data';
		retcode := 2; --Error
		g_error_buffer  := SQLCODE || ': ' || SUBSTR(SQLERRM, 1, 80);
		IF g_debug_flag = 'Y' THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
		END IF;
END Final_data;

--------------------------------------------------------------------------------
/*===========================================================================+
 | PROCEDURE                                                                 |
 |   Purge_trx_data()                                                        |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure deletes all the rows from  JE_IT_LIST_LINES_ALL,            |
 |	JE_IT_LIST_PARTIES_ALL , JE_IT_LIST_HDR_ALL for a given period.              |
 |                                                                           |
 | SCOPE - Public                                                            |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |  Date           Author          Description                               |
 |  ============  ==============  =================================          |
 |   03-Oct-2007   HBALIJEP               Initial  Version.                  |
 |                                                                           |
 +===========================================================================*/
PROCEDURE Purge_trx_data(p_vat_reporting_entity_id IN NUMBER,P_YEAR_OF_DECLARATION IN NUMBER) IS
BEGIN
	IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JE.plsql.JE_IT_LISTING_PKG.Insert_tax_data','Start PROCEDURE Purge_trx_data');
	END IF;
	g_retcode :=0;

	DELETE JE_IT_LIST_LINES_ALL
	WHERE vat_reporting_entity_id = p_vat_reporting_entity_id
	AND year_of_declaration = p_year_of_declaration;

	DELETE JE_IT_LIST_PARTIES_ALL
	WHERE vat_reporting_entity_id = p_vat_reporting_entity_id
	AND year_of_declaration = p_year_of_declaration;

	DELETE JE_IT_LIST_HDR_ALL
	WHERE vat_reporting_entity_id = p_vat_reporting_entity_id
	AND year_of_declaration = p_year_of_declaration;

	COMMIT;
	IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JE.plsql.JE_IT_LISTING_PKG.Insert_tax_data','End PROCEDURE Purge_trx_data');
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		g_retcode :=2;
		g_errbuf :='Exception in JE_IT_LISTING_PKG.Purge_trx_data';
		IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
			FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Insert_tax_data','Exception in PROCEDURE Purge_trx_data');
		END IF;
		g_error_buffer  := SQLCODE || ': ' || SUBSTR(SQLERRM, 1, 80);
		IF g_debug_flag = 'Y' THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
		END IF;
END Purge_trx_data;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--    PRIVATE METHODS
--------------------------------------------------------------------------------
/*===========================================================================+
 | PROCEDURE                                                                 |
 |   Fetch_trx_data_ap                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure fetches the distribution lines from the AP              |
 |	using bulk fetch and calls the procedure insert_tax_data             |
 |	to insert data into the JE_IT_LIST_LINES table                       |
 |    Called from JE_IT_LISTING_PKG.Extract_Data()                       |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |  Date           Author          Description                               |
 |  ============  ==============  =================================          |
 |  03-Oct-2007   HBALIJEP               Initial  Version.                   |
 |                                                                           |
 +===========================================================================*/
PROCEDURE Fetch_trx_data_ap( P_VAT_REPORTING_ENTITY_ID IN NUMBER,
                          	 P_YEAR_OF_DECLARATION     IN NUMBER,
                          	 P_VAT_REG IN VARCHAR2) IS

		CURSOR trl_tax_data_csr
		IS
		SELECT  ih.vendor_id       ,       --  Supplier ID
	        ih.invoice_type_lookup_code,   --  Invoice Type
	       	NULL                       ,   --  Transaction Type ID - AR
	        ih.doc_sequence_id         ,   --  Document sequence ID
	        ih.doc_sequence_value      ,   --  Dcoument sequence value
	        ih.invoice_date            ,   --  Invoice Date
	        ih.invoice_id              ,   --  Invoice ID
	        ih.invoice_num             ,   --  Invoice_Number
	        id.invoice_distribution_id ,   --  Invoive Tax Line Distribution ID
 		iditem.invoice_distribution_id ,  --  Invoive Item Line Distribution ID
	        il.line_type_lookup_code   ,   --  Invoice Tax Line Type (allways TAX)
		ilitem.line_type_lookup_code   , -- Iteam Line - Line Type Lookup Code (always ITEM
	        il.tax_rate_id             ,   --  Tax Rate ID
	        -- Tax Amount for other than Credit Memo Invoices
	        DECODE(ih.invoice_type_lookup_code,'CREDIT',0,
		       DECODE(ih.invoice_currency_code,gv_currency_code, id.amount, id.base_amount)) amount_tax,
    		-- Tax Amount for Credit Memo Invoices
	        DECODE(ih.invoice_type_lookup_code,'CREDIT',DECODE(ih.invoice_currency_code,gv_currency_code, id.amount, id.base_amount)
	                                             ,0) cm_amount_tax,
	        -- Item Line Amount for other than Credit Memo Invoices
	        DECODE(ih.invoice_type_lookup_code,'CREDIT',0,
			      DECODE(ih.invoice_currency_code,gv_currency_code, iditem.amount, iditem.base_amount)) amount_item,
           -- Item Line Amount for Credit Memo Invoices
	        DECODE(ih.invoice_type_lookup_code,'CREDIT',DECODE(ih.invoice_currency_code,gv_currency_code, iditem.amount, iditem.base_amount)
		                                          ,0) cm_amount_item
		FROM    ap_invoices_all ih                   ,
    			ap_invoice_lines_all il              ,
		        ap_invoice_distributions_all id      ,
			ap_invoice_lines_all ilitem              ,
			ap_invoice_distributions_all iditem      ,
		      	ap_suppliers pv                      ,
		        ap_supplier_sites_all pvs           ,
		        jg_zz_vat_rep_entities repent        ,
		        zx_rates_b zxrates                   ,
		        zx_taxes_b zxtaxes                   ,
		        zx_report_codes_assoc zxass          ,
    			(SELECT distinct person_id
			        ,national_identifier
		                  FROM per_all_people_f
	        	  WHERE nvl(effective_end_date,sysdate) >= sysdate ) papf
		WHERE   repent.vat_reporting_entity_id                          = P_VAT_REPORTING_ENTITY_ID
		    AND ( ( repent.entity_type_code           = 'LEGAL'
    	             AND ih.legal_entity_id           = gn_legal_entity_id )
		          OR(repent.entity_type_code          = 'ACCOUNTING'
 	                 AND repent.entity_level_code     = 'LEDGER'
 	                 AND ih.set_of_books_id           = gv_ledger_id)
			  OR(repent.entity_type_code          = 'ACCOUNTING'
	                 AND repent.entity_level_code     = 'BSV'
	                 AND ih.set_of_books_id           = gv_ledger_id
	                 AND get_bsv(id.dist_code_combination_id) = gv_balancing_segment_value )
			     )
		    AND ih.invoice_id           = il.invoice_id
		    AND ih.invoice_id           = id.invoice_id
		    AND il.line_number          = id.invoice_line_number
		    AND id.posted_flag          IN ('P', 'Y')
		    AND il.line_type_lookup_code = 'TAX'
    		    AND ilitem.line_type_lookup_code = 'ITEM'
		    AND ih.invoice_id           = ilitem.invoice_id
		    AND ih.invoice_id           = iditem.invoice_id
		    AND ilitem.line_number      = iditem.invoice_line_number
                    AND id.charge_applicable_to_dist_id = iditem.invoice_distribution_id
		    --In Case of Credit Memo Transaction, The following logic check credit memos lines issued
			-- during the year but applied to invoices issued in the previous years.
			AND (   ( ih.invoice_type_lookup_code <> 'CREDIT')
		          or( ih.invoice_type_lookup_code = 'CREDIT'
				  		and EXISTS (SELECT 1
						   			FROM ap_invoices_all tih
									WHERe tih.invoice_id = id.parent_invoice_id
			    						AND   TO_CHAR(tih.invoice_date, 'YYYY') 	=TO_CHAR(add_months(gd_period_end_date,-12), 'YYYY')   --bug 7031451
									))
                )

		    AND TO_CHAR(ih.invoice_date, 'YYYY')  = TO_CHAR(gd_period_end_date, 'YYYY')
		    AND ih.vendor_id                      = pv.vendor_id
		    AND pvs.vendor_id                     = pv.vendor_id
		    AND pvs.tax_reporting_site_flag       = 'Y'
		    AND pv.federal_reportable_flag        = 'Y'
		    AND pvs.country                       = gv_vat_country_code
		    AND pv.employee_id = papf.person_id (+)
		    AND NVL(NVL(pvs.vat_registration_num, pv.vat_registration_num),'-99') <> gv_repent_trn  --bug 7018923
		    AND ((P_VAT_REG = 'N') OR
		         (P_VAT_REG = 'Y' AND NVL(pvs.vat_registration_num, pv.vat_registration_num) IS NOT NULL))
		    AND il.tax_rate_id                     = zxrates.tax_rate_id
		    AND zxrates.content_owner_id           = zxtaxes.content_owner_id
		    AND zxrates.tax_regime_code            = zxtaxes.tax_regime_code
		    AND zxrates.tax                        = zxtaxes.tax
		    AND zxrates.tax_rate_id                = zxass.entity_id(+)
		    AND zxass.entity_code(+)               = 'ZX_RATES'
		    AND DECODE(zxtaxes.offset_tax_flag , 'Y', 'OFFSET',
		        DECODE(zxrates.def_rec_settlement_option_code, 'DEFERRED','DEFERRED',
  				    zxass.REPORTING_CODE_CHAR_VALUE))<> 'CUSTOM BILL'

		    AND il.tax_rate_id IN (SELECT tax_rate_id
				                   FROM   je_it_setup_lines_all
						           WHERE  year_of_declaration    = P_YEAR_OF_DECLARATION
		                           AND    application_id         = gn_ap_app_id
		                           AND vat_reporting_entity_id   = gn_legal_vat_rep_entity_id);

    l_record_count NUMBER :=0;

BEGIN
	IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JE.plsql.JE_IT_LISTING_PKG.Fetch_trx_data_ap','Start PROCEDURE Fetch_trx_data_ap');
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Fetch_trx_data_ap','Parameters are :');
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Fetch_trx_data_ap','P_VAT_REPORTING_ENTITY_ID'||P_VAT_REPORTING_ENTITY_ID);
  	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Fetch_trx_data_ap','P_YEAR_OF_DECLARATION'||P_YEAR_OF_DECLARATION);

	       IF P_VAT_REG= 'Y' THEN
	       		FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Fetch_trx_data_ap','P_VAT_REG is TRUE' );
	       ELSE
	       		FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Fetch_trx_data_ap','P_VAT_REG is FALSE' );
	       END IF;
	END IF;

	g_retcode :=0;

		OPEN trl_tax_data_csr;
		LOOP
			FETCH trl_tax_data_csr BULK COLLECT INTO
				gt_party_id,
				gt_trx_type_code,
				gt_trx_type_id,
				gt_doc_seq_num,
				gt_doc_seq_val,
				gt_trx_date,
				gt_trx_id,
				gt_trx_num,
				gt_trx_tax_dist_id,
				gt_trx_line_dist_id,
				gt_trx_tax_line_type_code,
				gt_trx_line_type_code,
				gt_trx_line_tax_rate_id,
				gt_inv_tax_line_amount,
				gt_inv_tax_line_amount_cm,
				gt_inv_line_amount,
				gt_inv_line_amount_cm
			LIMIT g_lines_per_commit;

			l_record_count := l_record_count+ gt_trx_id.count;

			IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
				FND_LOG.STRING(G_LEVEL_STATEMENT, 'JE.plsql.JE_IT_LISTING_PKG.Fetch_trx_data_ap','Calling insert_tax_data');
			END IF;

			SAVEPOINT before_insert_lines;
			insert_tax_data(P_VAT_REPORTING_ENTITY_ID,P_YEAR_OF_DECLARATION,gn_ap_app_id);
			COMMIT;
			IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
				FND_LOG.STRING(G_LEVEL_STATEMENT, 'JE.plsql.JE_IT_LISTING_PKG.Fetch_trx_data_ap','Calling init_gt_variables');
			END IF;
			init_gt_variables;
			EXIT WHEN trl_tax_data_csr%NOTFOUND;
		END LOOP;


       	IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JE.plsql.JE_IT_LISTING_PKG.Fetch_trx_data_ap','Number of AP records inserted into JE_IT_LIST_LINES  :'||l_record_count);
        END IF;

	IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JE.plsql.JE_IT_LISTING_PKG.Fetch_trx_data_ap','End PROCEDURE Fetch_trx_data_ap');
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		g_retcode :=2;
		g_errbuf :='Exception in JE_IT_LISTING_PKG.Fetch_trx_data_ap';
		IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
			FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Fetch_trx_data_ap','Exception in PROCEDURE Fetch_trx_data_ap');
		END IF;
		g_error_buffer  := SQLCODE || ': ' || SUBSTR(SQLERRM, 1, 80);
		IF g_debug_flag = 'Y' THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
		END IF;
		ROLLBACK TO before_insert_lines;
END Fetch_trx_data_ap;

--------------------------------------------------------------------------------
/*===========================================================================+
 | PROCEDURE                                                                 |
 |   Fetch_trx_data_ar                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure fetches the distribution lines from the AR              |
 |	using bulk fetch and calls the procedure insert_tax_data                 |
 |	to insert data into the JE_IT_LIST_LINES table                           |
 |    Called from JE_IT_LISTING_PKG.Extract_Data()                           |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |  Date           Author          Description                               |
 |  ============  ==============  =================================          |
 |  14-Dec-2007   spasupun               Initial  Version.                   |
 |                                                                           |
 +===========================================================================*/
 PROCEDURE Fetch_trx_data_ar( P_VAT_REPORTING_ENTITY_ID IN NUMBER,
        		              P_YEAR_OF_DECLARATION     IN NUMBER,
		                      P_VAT_REG IN VARCHAR2) IS

        CURSOR trl_tax_data_csr IS
           SELECT
			 NVL(rth.sold_to_customer_id, rth.bill_to_customer_id),   --PARTY_ID -  Third party ID
			 rtp.type,                  --TRX_TYPE_CODE -Transaction_Type - AP      --bug 7031451
			 rth.cust_trx_type_id,      --TRX_TYPE_ID - Transaction Type ID - AR
			 rth.doc_sequence_id,       --DOC_SEQ_NUM - Sequence_Number
			 rth.doc_sequence_value,    --DOC_SEQ_VAL
			 rth.trx_date,              --TRX_DATE - Invoice_Date
			 rth.customer_trx_id,       --TRX_ID
			 rth.trx_number,            --TRX_NUM - Invoice_Number             --TRX_NUM - Invoice_Number
			 rcgl.cust_trx_line_gl_dist_id,  --TAX_DIST_ID
			 rcglitem.cust_trx_line_gl_dist_id,  --LINE_DIST_ID
			 rtl.line_type,             --TRX_LINE_TYPE_CODE - Inv_Line_Type
             rtlitem.line_type,             --TRX_LINE_TYPE_CODE - Inv_Line_Type
			 rtl.vat_tax_id,            --TRX_LINE_TAX_CODE_ID - Inv_Line_Tax_Code
			 DECODE(rtp.type,'CM',0,ROUND(rcgl.amount*NVL(rth.exchange_rate, 1),2)) amount_tax,               --Inv_Line_Amt
			 DECODE(rtp.type,'CM',ROUND(rcgl.amount*NVL(rth.exchange_rate, 1),2),0) cm_amount_tax,               --Inv_Line_Amt
			 DECODE(rtp.type,'CM',0,ROUND(rcglitem.amount*NVL(rth.exchange_rate, 1),2)) amount_item,               --Inv_Line_Amt
			 decode(rtp.type,'CM',ROUND(rcglitem.amount*NVL(rth.exchange_rate, 1),2),0) cm_amount_item

		 FROM ra_customer_trx_all rth,
   		      ra_customer_trx_lines_all rtl,
		      ra_cust_trx_line_gl_dist_all rcgl,
		      ra_customer_trx_lines_all rtlitem,
		      ra_cust_trx_line_gl_dist_all rcglitem,
		      hz_cust_site_uses_all  hzcsu,
              hz_cust_acct_sites_all hzcas,
		      hz_cust_accounts   hzca,
              hz_parties         hzp,
              jg_zz_vat_rep_entities repent,
              zx_rates_b zxrates,
    	      zx_taxes_b zxtaxes,
	          zx_report_codes_assoc zxass,
	          ra_cust_trx_types_all rtp
          WHERE repent.vat_reporting_entity_id         = p_vat_reporting_entity_id
              AND ( ( repent.entity_type_code          = 'LEGAL'
          			   AND rth.legal_entity_id         = gn_legal_entity_id )
		            OR( repent.entity_type_code        = 'ACCOUNTING'
		                AND repent.entity_level_code   = 'LEDGER'
		                AND rth.set_of_books_id        = gv_ledger_id)
		            OR( repent.entity_type_code        = 'ACCOUNTING'
		                AND repent.entity_level_code   = 'BSV'
		                AND rth.set_of_books_id        = gv_ledger_id
		                AND get_bsv(rcgl.code_combination_id) = gv_balancing_segment_value)
				  )
		  AND rtl.customer_trx_id = rth.customer_trx_id
		  AND TO_CHAR(rth.trx_date, 'YYYY') = TO_CHAR(gd_period_end_date, 'YYYY')
		  AND rcgl.customer_trx_id = rtl.customer_trx_id
		  AND rcgl.customer_trx_line_id = rtl.customer_trx_line_id
		  AND rtl.line_type = 'TAX'
		  AND rtlitem.customer_trx_id =  rtl.customer_trx_id
		  AND rtlitem.line_type = 'LINE'
		  AND rtl.link_to_cust_trx_line_id = rtlitem.customer_trx_line_id (+)
		  AND rcglitem.customer_trx_line_id = rtlitem.customer_trx_line_id
		  AND rcglitem.customer_trx_id = rtlitem.customer_trx_id
		  AND rcgl.posting_control_id <> -3
          AND NVL(rth.sold_to_customer_id, rth.bill_to_customer_id) = hzca.cust_account_id
	  	  AND hzcsu.cust_acct_site_id    = hzcas.cust_acct_site_id
 		  AND hzcas.cust_account_id      = hzca.cust_account_id
		  AND hzca.party_id              = hzp.party_id
		  AND upper(hzcsu.site_use_code) = 'LEGAL'
		  AND hzcsu.primary_flag         = 'Y'
		  AND hzcsu.status               = 'A'
		  AND hzp.country                = gv_vat_country_code
		  AND NVL(decode(hzcsu.tax_reference, null,hzp.tax_reference,hzcsu.tax_reference),'-99')  <>  TO_CHAR(gv_repent_trn)
          AND ((P_VAT_REG = 'N') OR
               (P_VAT_REG = 'Y' AND decode(hzcsu.tax_reference, null,hzp.tax_reference,hzcsu.tax_reference) IS NOT NULL))
          AND rtl.vat_tax_id              = zxrates.tax_rate_id
          AND zxrates.content_owner_id        = zxtaxes.content_owner_id
          AND zxrates.tax_regime_code         = zxtaxes.tax_regime_code
          AND zxrates.tax                     = zxtaxes.tax
          AND zxrates.tax_rate_id             = zxass.entity_id(+)
          AND zxass.entity_code(+)            = 'ZX_RATES'
          AND DECODE(zxtaxes.offset_tax_flag , 'Y', 'OFFSET', DECODE(zxrates.def_rec_settlement_option_code, 'DEFERRED','DEFERRED',zxass.REPORTING_CODE_CHAR_VALUE))<> 'CUSTOM BILL'
          AND rtp.cust_trx_type_id = rth.cust_trx_type_id
          AND rtp.org_id = rth.org_id     		--bug 7031451
    	  AND ( (rtp.type <> 'CM') or
    	        (rtp.type = 'CM'
                 and EXISTS(SELECT  arct.customer_trx_id
	       					FROM ar_receivable_applications_all arap,
						         ra_customer_trx_all arct
						    WHERE   arap.customer_trx_id = rth.customer_trx_id
							AND  application_type ='CM'
							AND  arap.applied_customer_trx_id = arct.customer_trx_id
							AND  TO_CHAR(arct.trx_date, 'YYYY') = TO_CHAR(add_months(gd_period_end_date,-12), 'YYYY')
						    ))
	          )
		   AND rtl.vat_tax_id IN (SELECT tax_rate_id FROM JE_IT_SETUP_LINES_ALL
		                           WHERE vat_reporting_entity_id = gn_legal_vat_rep_entity_id
		                           AND  year_of_declaration = P_YEAR_OF_DECLARATION
		                           AND  application_id= gn_ar_app_id);

        l_record_count NUMBER := 0;

BEGIN
	IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JE.plsql.JE_IT_LISTING_PKG.Fetch_trx_data_ar','Start PROCEDURE Fetch_trx_data_ar');
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Fetch_trx_data_ar','Parameters are :');
   	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Fetch_trx_data_ar','P_VATRE_REPORTING_ENTITY_ID='||P_VAT_REPORTING_ENTITY_ID);
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Fetch_trx_data_ar','P_YEAR_OF_DECLARATION='||P_YEAR_OF_DECLARATION);

	       IF P_VAT_REG = 'Y' THEN
	       		FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Fetch_trx_data_ar','P_VAT_REG is TRUE');
	       ELSE
	       		FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Fetch_trx_data_ar','P_VAT_REG is FALSE');
	       END IF;

	 END IF;
	 g_retcode :=0;

	 init_gt_variables;

	 OPEN trl_tax_data_csr;
	   LOOP
	 FETCH trl_tax_data_csr BULK COLLECT INTO
			gt_party_id,
			gt_trx_type_code,
			gt_trx_type_id,
			gt_doc_seq_num,
			gt_doc_seq_val,
			gt_trx_date,
			gt_trx_id,
			gt_trx_num,
			gt_trx_tax_dist_id,
			gt_trx_line_dist_id,
			gt_trx_tax_line_type_code,
			gt_trx_line_type_code,
			gt_trx_line_tax_rate_id,
			gt_inv_tax_line_amount,
			gt_inv_tax_line_amount_cm,
			gt_inv_line_amount,
			gt_inv_line_amount_cm
		LIMIT g_lines_per_commit;

        l_record_count := l_record_count + gt_trx_id.count;

		IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
				FND_LOG.STRING(G_LEVEL_STATEMENT, 'JE.plsql.JE_IT_LISTING_PKG.Fetch_trx_data_ap','Calling insert_tax_data');
			END IF;

		SAVEPOINT before_insert_lines;
		insert_tax_data(P_VAT_REPORTING_ENTITY_ID,P_YEAR_OF_DECLARATION,gn_ar_app_id);
		COMMIT;
		init_gt_variables;
		EXIT WHEN trl_tax_data_csr%NOTFOUND;
	END LOOP;

		IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
			FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Fetch_trx_data_ar','Number of AR records inserted into JE_IT_LIST_LINES :'||l_record_count);
		END IF;


EXCEPTION
	WHEN OTHERS THEN
		g_retcode :=2;
		g_errbuf :='Exception in JE_IT_LISTING_PKG.Fetch_trx_data_ar';
		IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
			FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Fetch_trx_data_ar','Exception in PROCEDURE Fetch_trx_data_ar');
		END IF;
		g_error_buffer  := SQLCODE || ': ' || SUBSTR(SQLERRM, 1, 80);
		IF g_debug_flag = 'Y' THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
		END IF;
		ROLLBACK TO before_insert_lines;
END Fetch_trx_data_ar;

--------------------------------------------------------------------------------
/*===========================================================================+
 | PROCEDURE                                                                 |
 |   Fetch_trx_data_ap                                                       |
 |                                                                           |
 | DESCRIPTION                                                               |
 |    This procedure inserts data into the JE_IT_LIST_LINES table            |
 |    Called from JE_IT_LISTING_PKG.Fetch_trx_data_ap() and                  |
 |                JE_IT_LISTING_PKG.Fetch_trx_data_ar()                      |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |  Date           Author          Description                               |
 |  ============  ==============  =================================          |
 |  14-Dec-2007   spasupun               Initial  Version.                   |
 |                                                                           |
 +===========================================================================*/

PROCEDURE Insert_tax_data( P_VAT_REPORTING_ENTITY_ID IN NUMBER,
	  		               P_YEAR_OF_DECLARATION     IN NUMBER,
		                   P_APP_ID 		         IN NUMBER) IS

		--Variable for Tax Line

		v_taxable_t		NUMBER;
		v_non_taxable_t	NUMBER;
		v_vat_t			NUMBER;
		v_exempt_t		NUMBER;
		v_tax_vat_t		NUMBER;
		v_tax_vat_inv_t	NUMBER;

		v_taxable_cm_t		NUMBER;
		v_non_taxable_cm_t	NUMBER;
		v_vat_cm_t	  	    NUMBER;
		v_exempt_cm_t		NUMBER;
		v_tax_vat_cm_t		NUMBER;
		v_tax_vat_inv_cm_t	NUMBER;

		--Variable for ITEM/LINE Line

		v_taxable_l		NUMBER;
		v_non_taxable_l	NUMBER;
		v_vat_l			NUMBER;
		v_exempt_l		NUMBER;
		v_tax_vat_l		NUMBER;
		v_tax_vat_inv_l	NUMBER;

		v_taxable_cm_l		NUMBER;
		v_non_taxable_cm_l	NUMBER;
		v_vat_cm_l		    NUMBER;
		v_exempt_cm_l		NUMBER;
		v_tax_vat_cm_l		NUMBER;
		v_tax_vat_inv_cm_l	NUMBER;

		available_flag      varchar2(10) := 'N';

		CURSOR vat_ui(P_VAT_REPORTING_ENTITY_ID NUMBER,P_YEAR_OF_DECLARATION NUMBER
		             ,P_APP_ID NUMBER,P_TAX_RATE_ID NUMBER) IS
			SELECT listing_column_code
			FROM je_it_setup_lines_all
			WHERE vat_reporting_entity_id=P_VAT_REPORTING_ENTITY_ID
			AND  year_of_declaration = P_YEAR_OF_DECLARATION
			AND  application_id = P_APP_ID
			AND  tax_rate_id = P_TAX_RATE_ID;
BEGIN
	IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JE.plsql.JE_IT_LISTING_PKG.Insert_tax_data','Start PROCEDURE Insert_tax_data');
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Insert_tax_data','Parameters are :');
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Insert_tax_data','p_vat_reporting_entity_id	='||p_vat_reporting_entity_id);
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Insert_tax_data','p_year_of_declaration	='||p_year_of_declaration);
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Insert_tax_data','p_app_id	='||p_app_id);
	END IF;
	g_retcode :=0;

	FOR i IN 1 .. g_lines_per_commit

        LOOP
		--Variables for Tax Line

		v_taxable_t		:= NULL;
		v_non_taxable_t	        := NULL;
		v_vat_t			:= NULL;
		v_exempt_t		:= NULL;
		v_tax_vat_t		:= NULL;
		v_tax_vat_inv_t	        := NULL;

		v_taxable_cm_t		:= NULL;
		v_non_taxable_cm_t	:= NULL;
		v_vat_cm_t		:= NULL;
		v_exempt_cm_t		:= NULL;
		v_tax_vat_cm_t		:= NULL;
		v_tax_vat_inv_cm_t	:= NULL;

		--Variables for ITEM Line

		v_taxable_l		:= NULL;
		v_non_taxable_l	        := NULL;
		v_vat_l			:= NULL;
		v_exempt_l		:= NULL;
		v_tax_vat_l		:= NULL;
		v_tax_vat_inv_l 	:= NULL;

		v_taxable_cm_l		:= NULL;
		v_non_taxable_cm_l	:= NULL;
		v_vat_cm_l		:= NULL;
		v_exempt_cm_l		:= NULL;
		v_tax_vat_cm_l		:= NULL;
		v_tax_vat_inv_cm_l	:= NULL;

		FOR rec_vat_ui IN vat_ui(gn_legal_vat_rep_entity_id,P_YEAR_OF_DECLARATION,P_APP_ID,gt_trx_line_tax_rate_id(i))

        LOOP

		-- Tax Line Information


			IF gt_trx_tax_line_type_code(i) = 'TAX' THEN

			     IF ((P_APP_ID = 222 AND gt_trx_type_code(i) <> 'CM' )
                  or(P_APP_ID = 200 AND gt_trx_type_code(i) <> 'CREDIT')) THEN

        		 IF rec_vat_ui.listing_column_code = 'TAXABLE' THEN
					v_vat_t := gt_inv_tax_line_amount(i);

				 END IF;
				 IF rec_vat_ui.listing_column_code = 'TAX_VAT' THEN
					v_tax_vat_t := gt_inv_tax_line_amount(i);

				 END IF;
				 IF rec_vat_ui.listing_column_code = 'TAX_VAT_INV' THEN
					v_tax_vat_inv_t := gt_inv_tax_line_amount(i);

				 END IF;

               ELSIF ((P_APP_ID = 222 AND gt_trx_type_code(i) = 'CM' )
                  or(P_APP_ID = 200 AND gt_trx_type_code(i) = 'CREDIT')) THEN

				IF rec_vat_ui.listing_column_code = 'TAXABLE' THEN
					v_vat_cm_t := gt_inv_tax_line_amount_cm(i);


				END IF;
				IF rec_vat_ui.listing_column_code = 'TAX_VAT' THEN
					v_tax_vat_cm_t := gt_inv_tax_line_amount_cm(i);

				END IF;
				IF rec_vat_ui.listing_column_code = 'TAX_VAT_INV' THEN
					v_tax_vat_inv_cm_t := gt_inv_tax_line_amount_cm(i);
				END IF;
              END IF;
			END IF;

		 -- Tax Line corresponding Item Line information.

			IF gt_trx_line_type_code(i) = 'LINE' or gt_trx_line_type_code(i) = 'ITEM' THEN

			   IF ((P_APP_ID = 222 AND gt_trx_type_code(i) <> 'CM' )
                  or(P_APP_ID = 200 AND gt_trx_type_code(i) <> 'CREDIT')) THEN

				IF rec_vat_ui.listing_column_code = 'TAXABLE' THEN
					v_taxable_l := gt_inv_line_amount(i);

				END IF;
				IF rec_vat_ui.listing_column_code = 'NONTAXABLE' THEN
					v_non_taxable_l := gt_inv_line_amount(i);

				END IF;
				IF rec_vat_ui.listing_column_code = 'EXEMPT' THEN
					v_exempt_l := gt_inv_line_amount(i);

				END IF;
				IF rec_vat_ui.listing_column_code = 'TAX_VAT' THEN
					v_tax_vat_l := gt_inv_line_amount(i);

				END IF;
				IF rec_vat_ui.listing_column_code = 'TAX_VAT_INV' THEN
					v_tax_vat_inv_l := gt_inv_line_amount(i);


				END IF;
			   ELSIF ((P_APP_ID = 222 AND gt_trx_type_code(i) = 'CM' )
                  or(P_APP_ID = 200 AND gt_trx_type_code(i) = 'CREDIT')) THEN

				IF rec_vat_ui.listing_column_code = 'TAXABLE' THEN
					v_taxable_cm_l := gt_inv_line_amount_cm(i);

				END IF;
				IF rec_vat_ui.listing_column_code = 'NONTAXABLE' THEN
					v_non_taxable_cm_l := gt_inv_line_amount_cm(i);

				END IF;
				IF rec_vat_ui.listing_column_code = 'EXEMPT' THEN
					v_exempt_cm_l := gt_inv_line_amount_cm(i);

				END IF;
				IF rec_vat_ui.listing_column_code = 'TAX_VAT' THEN
					v_tax_vat_cm_l := gt_inv_line_amount_cm(i);

				END IF;
				IF rec_vat_ui.listing_column_code = 'TAX_VAT_INV' THEN
					v_tax_vat_inv_cm_l := gt_inv_line_amount_cm(i);

				END IF;

	       	   END IF;
			END IF;
		END LOOP;

		IF P_APP_ID = 222 THEN
			v_tax_vat_t    :=NULL;
			v_tax_vat_cm_t :=NULL;
			v_tax_vat_l    :=NULL;
			v_tax_vat_cm_l :=NULL;
		END IF;

 --- Bug 7018923



  BEGIN
		SELECT 'Y' INTO available_flag FROM JE_IT_LIST_LINES_ALL
		WHERE
		    VAT_REPORTING_ENTITY_ID = P_VAT_REPORTING_ENTITY_ID
		AND YEAR_OF_DECLARATION = P_YEAR_OF_DECLARATION
		AND APPLICATION_ID = p_app_id
		AND PARTY_ID = gt_party_id(i)
		AND TRX_DIST_ID = gt_trx_line_dist_id(i);

 EXCEPTION
 WHEN NO_DATA_FOUND THEN
           available_flag := 'N';
  END;



		IF available_flag is NULL or available_flag = 'N' THEN

     			        -- ITEM line insertion
					INSERT INTO JE_IT_LIST_LINES_ALL(
					VAT_REPORTING_ENTITY_ID,
					YEAR_OF_DECLARATION,
					APPLICATION_ID,
					PARTY_ID,
					TRX_TYPE_CODE,
					TRX_TYPE_ID,
					DOC_SEQ_ID,
					DOC_SEQ_NUM,
					TRX_DATE,
					TRX_ID,
					TRX_NUM,
					TRX_DIST_ID,
					TRX_LINE_TYPE_CODE,
					TAX_RATE_ID,
					TAXABLE_AMT,
					VAT_AMT,
					NON_TAXABLE_AMT,
					EXEMPT_AMT,
					TAXABLE_VAT_AMT,
					TAXABLE_VAT_INV_AMT,
					CM_TAXABLE_AMT,
					CM_VAT_AMT,
					CM_NON_TAXABLE_AMT,
					CM_EXEMPT_AMT,
					CM_TAXABLE_VAT_AMT,
					CM_TAXABLE_VAT_INV_AMT,
					LAST_UPDATE_DATE,
					LAST_UPDATED_BY,
					LAST_UPDATE_LOGIN,
					CREATION_DATE,
					CREATED_BY)
					VALUES (P_VAT_REPORTING_ENTITY_ID,
						P_YEAR_OF_DECLARATION,
						p_app_id,                       --APPLICATION_ID
						gt_party_id(i),                 --PARTY_ID
						gt_trx_type_code(i),            --TRX_TYPE_CODE
						gt_trx_type_id(i),              --TRX_TYPE_ID
						gt_doc_seq_num(i),              --DOC_SEQ_ID
						gt_doc_seq_val(i),              --DOC_SEQ_NUM
						gt_trx_date(i),                 --TRX_DATE
						gt_trx_id(i),                   --TRX_ID
						gt_trx_num(i),                  --TRX_NUM
						gt_trx_line_dist_id(i),         --TRX_DIST_ID
						gt_trx_line_type_code(i),       --TRX_LINE_TYPE_CODE
						gt_trx_line_tax_rate_id(i),     --TRX_LINE_TAX_CODE_ID
						v_taxable_l,                    --TAXABLE_AMT
			            v_vat_l,                        --VAT_AMT
						v_non_taxable_l,                --NON_TAXABLE_AMT
				        v_exempt_l,                     --EXEMPT_AMT
			            v_tax_vat_l,                    --TAXABLE_VAT_AMT
			            v_tax_vat_inv_l,                --TAXABLE_VAT_INV_AMT
						v_taxable_cm_l,                 --TAXABLE_AMT
			            v_vat_cm_l,                     --VAT_AMT
			        	v_non_taxable_cm_l,             --NON_TAXABLE_AMT
				 	    v_exempt_cm_l,                  --EXEMPT_AMT
				        v_tax_vat_cm_l,                 --TAXABLE_VAT_AMT
			            v_tax_vat_inv_cm_l,             --TAXABLE_VAT_INV_AMT
			            g_last_update_date,             --LAST_UPDATE_DATE
			            g_last_updated_by,              --LAST_UPDATED_BY
			            g_last_update_login,            --LAST_UPDATE_LOGIN
			            g_creation_date,                --CREATION_DATE
			            g_created_by);                  --CREATED_BY
	    END IF;

 --- Bug 7018923

		-- tax line insertion

		INSERT INTO JE_IT_LIST_LINES_ALL(
		VAT_REPORTING_ENTITY_ID,
		YEAR_OF_DECLARATION,
		APPLICATION_ID,
		PARTY_ID,
		TRX_TYPE_CODE,
		TRX_TYPE_ID,
		DOC_SEQ_ID,
		DOC_SEQ_NUM,
		TRX_DATE,
		TRX_ID,
		TRX_NUM,
		TRX_DIST_ID,
		TRX_LINE_TYPE_CODE,
		TAX_RATE_ID,
		TAXABLE_AMT,
		VAT_AMT,
		NON_TAXABLE_AMT,
		EXEMPT_AMT,
		TAXABLE_VAT_AMT,
		TAXABLE_VAT_INV_AMT,
		CM_TAXABLE_AMT,
		CM_VAT_AMT,
		CM_NON_TAXABLE_AMT,
		CM_EXEMPT_AMT,
		CM_TAXABLE_VAT_AMT,
		CM_TAXABLE_VAT_INV_AMT,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_LOGIN,
		CREATION_DATE,
		CREATED_BY)
		VALUES (P_VAT_REPORTING_ENTITY_ID,
			P_YEAR_OF_DECLARATION,
			p_app_id,                         --APPLICATION_ID
			gt_party_id(i),                 --PARTY_ID
			gt_trx_type_code(i),            --TRX_TYPE_CODE
			gt_trx_type_id(i),              --TRX_TYPE_ID
			gt_doc_seq_num(i),              --DOC_SEQ_ID
			gt_doc_seq_val(i),              --DOC_SEQ_NUM
			gt_trx_date(i),                 --TRX_DATE
			gt_trx_id(i),                   --TRX_ID
			gt_trx_num(i),                  --TRX_NUM
			gt_trx_tax_dist_id(i),     --TRX_DIST_ID
			gt_trx_tax_line_type_code(i),   --TRX_LINE_TYPE_CODE
			gt_trx_line_tax_rate_id(i),     --TRX_LINE_TAX_CODE_ID
			v_taxable_t,                      --TAXABLE_AMT
            v_vat_t,                          --VAT_AMT
			v_non_taxable_t,                  --NON_TAXABLE_AMT
	        v_exempt_t,                       --EXEMPT_AMT
            v_tax_vat_t,                      --TAXABLE_VAT_AMT
            v_tax_vat_inv_t,                  --TAXABLE_VAT_INV_AMT
			v_taxable_cm_t,                   --TAXABLE_AMT
            v_vat_cm_t,                       --VAT_AMT
			v_non_taxable_cm_t,               --NON_TAXABLE_AMT
	        v_exempt_cm_t,                    --EXEMPT_AMT
            v_tax_vat_cm_t,                   --TAXABLE_VAT_AMT
            v_tax_vat_inv_cm_t,               --TAXABLE_VAT_INV_AMT
            g_last_update_date,             --LAST_UPDATE_DATE
            g_last_updated_by,              --LAST_UPDATED_BY
            g_last_update_login,            --LAST_UPDATE_LOGIN
            g_creation_date,                --CREATION_DATE
            g_created_by);                  --CREATED_BY
	END LOOP;


   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JE.plsql.JE_IT_LISTING_PKG.Insert_tax_data','End PROCEDURE Insert_tax_data');
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		g_retcode :=2;
		g_errbuf :='Exception in JE_IT_LISTING_PKG.Insert_tax_data';
		IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
		    FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Insert_tax_data','Exception in PROCEDURE Insert_tax_data');
		END IF;
		g_error_buffer  := SQLCODE || ': ' || SUBSTR(SQLERRM, 1, 80);
		IF g_debug_flag = 'Y' THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
		END IF;
END Insert_tax_data;

--------------------------------------------------------------------------------
/*===========================================================================+
 | PROCEDURE                                                                 |
 |   INIT_GT_VARIABLES                                                       |
 | DESCRIPTION                                                               |
 |    This procedure initializes all global variables                        |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |  Date           Author          Description                               |
 |  ============  ==============  =================================          |
 |  14-Dec-2007   spasupun               Initial  Version.                   |
 |                                                                           |
 +===========================================================================*/
PROCEDURE Init_gt_variables IS
BEGIN
	IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JE.plsql.JE_IT_LISTING_PKG.Init_gt_variables','Start PROCEDURE Init_gt_variables');
	END IF;
	g_retcode :=0;
	gt_party_id.DELETE;
	gt_trx_type_code.DELETE;
	gt_trx_type_id.DELETE;
	gt_doc_seq_num.DELETE;
	gt_doc_seq_val.DELETE;
	gt_trx_date.DELETE;
	gt_trx_id.DELETE;
	gt_trx_num.DELETE;
	gt_trx_line_dist_id.DELETE;
	gt_trx_tax_dist_id.DELETE;
	gt_trx_line_type_code.DELETE;
	gt_trx_tax_line_type_code.DELETE;
	gt_trx_line_tax_rate_id.DELETE;
	gt_inv_line_amount.DELETE;
	gt_inv_tax_line_amount.DELETE;
	gt_inv_line_amount_cm.DELETE;
	gt_inv_tax_line_amount_cm.DELETE;
	gt_trx_type.DELETE;
	gt_party_vat_reg_num.DELETE;
	gt_party_fiscal_id_num.DELETE;

	IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JE.plsql.JE_IT_LISTING_PKG.Init_gt_variables','End PROCEDURE Init_gt_variables');
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		g_retcode :=2;
		g_errbuf :='Exception in JE_IT_LISTING_PKG.Init_gt_variables';
		IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
			FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Init_gt_variables','Exception in PROCEDURE Insert_tax_data');
		END IF;
		g_error_buffer  := SQLCODE || ': ' || SUBSTR(SQLERRM, 1, 80);
		IF g_debug_flag = 'Y' THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
		END IF;
END;
-----------------------------------------------------------------------------
/*===========================================================================+
 | PROCEDURE                                                                 |
 |   GENERATE_TRX_HEADERS                                                    |
 | DESCRIPTION                                                               |
 |    This procedure populates the tables  JE_IT_LIST_PARTIES_ALL            |
 |         and JE_IT_LIST_HDR_ALL                                            |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |  Date           Author          Description                               |
 |  ============  ==============  =================================          |
 |  14-Dec-2007   spasupun               Initial  Version.                   |
 |                                                                           |
 +===========================================================================*/
---------------------------------------------------------------------------------
PROCEDURE Generate_trx_headers(
		P_VAT_REPORTING_ENTITY_ID  IN NUMBER,
		P_YEAR_OF_DECLARATION   IN NUMBER,
		P_CUST_SORT_COL	        IN VARCHAR2,
		P_VEND_SORT_COL	        IN VARCHAR2,
                P_GROUP_PARTIES_FLAG    IN VARCHAR2) IS

		l_transnum 	NUMBER;
		l_count		NUMBER;
		l_seq_num	NUMBER;

	CURSOR  cur_trx_lines(P_VAT_REPORTING_ENTITY NUMBER
		                     ,P_YEAR_OF_DECLARATION  NUMBER
        				     ,P_CUST_SORT_COL        VARCHAR2
		          		     ,P_VEND_SORT_COL        VARCHAR2) IS
		SELECT 	jit.application_id application_id,
    			jit.PARTY_ID party_id,					    --PARTY_ID
	       		DECODE(P_CUST_SORT_COL,'C',hzp.party_name,'T',hzp.jgzz_fiscal_code
                       ,'R',DECODE(hzcsu.tax_reference, null,hzp.tax_reference,hzcsu.tax_reference)) sort_column,
		      	SUM(jit.TAXABLE_AMT) tot_taxable_amt,  		    --TAXABLE_AMT
        		SUM(jit.VAT_AMT) tot_vat_amt,			    --VAT_AMT
    			SUM(jit.NON_TAXABLE_AMT) tot_non_taxable_amt, 	    --NON_TAXABLE_AMT
	       		SUM(jit.EXEMPT_AMT) tot_exempt_amt,			    --EXEMPT_AMT
		      	SUM(jit.TAXABLE_VAT_AMT) tot_taxable_vat_amt,      	    --TAXABLE_VAT_AMT
        		SUM(jit.TAXABLE_VAT_INV_AMT) tot_taxable_vat_inv_amt,    --TAXABLE_VAT_INV_AMT
		      	SUM(jit.CM_TAXABLE_AMT) tot_taxable_amt_cm,  		    --TAXABLE_AMT
        		SUM(jit.CM_VAT_AMT) tot_vat_amt_cm,			    --VAT_AMT
		      	SUM(jit.CM_NON_TAXABLE_AMT) tot_non_taxable_amt_cm, 	    --NON_TAXABLE_AMT
    			SUM(jit.CM_EXEMPT_AMT) tot_exempt_amt_cm,			    --EXEMPT_AMT
	      		SUM(jit.CM_TAXABLE_VAT_AMT) tot_taxable_vat_amt_cm,      	    --TAXABLE_VAT_AMT
	       		SUM(jit.CM_TAXABLE_VAT_INV_AMT) tot_taxable_vat_inv_amt_cm,    --TAXABLE_VAT_INV_AMT
			    hzp.jgzz_fiscal_code tax_payer_id,   -- Customer Tax Payer ID
			    DECODE(hzcsu.tax_reference, null,hzp.tax_reference,hzcsu.tax_reference) vat_reg_num-- Customer Tax Registration Number
		FROM  JE_IT_LIST_LINES_ALL jit,
 	  	      hz_cust_site_uses_all  hzcsu,
                      hz_cust_acct_sites_all hzcas,
		      hz_cust_accounts   hzca,
                      hz_parties         hzp
		WHERE jit.vat_reporting_entity_id = P_VAT_REPORTING_ENTITY_ID
		AND  jit.year_of_declaration = P_YEAR_OF_DECLARATION
		AND  jit.APPLICATION_ID = 222
		AND  jit.party_id = hzca.cust_account_id
      	AND hzcsu.cust_acct_site_id    = hzcas.cust_acct_site_id
 		AND hzcas.cust_account_id      = hzca.cust_account_id
		AND hzca.party_id              = hzp.party_id
		AND upper(hzcsu.site_use_code) = 'LEGAL'
		AND hzcsu.primary_flag         = 'Y'
		AND hzcsu.status               = 'A'
		AND hzp.country                = gv_vat_country_code
		AND NVL(decode(hzcsu.tax_reference, null,hzp.tax_reference,hzcsu.tax_reference),'-99')  <>  TO_CHAR(gv_repent_trn)
		GROUP BY jit.PARTY_ID,
		      jit.APPLICATION_ID,
		      hzp.jgzz_fiscal_code,
		      DECODE(hzcsu.tax_reference, null,hzp.tax_reference,hzcsu.tax_reference),
        	  DECODE(P_CUST_SORT_COL,'C',hzp.party_name,'T',hzp.jgzz_fiscal_code
                   ,'R',DECODE(hzcsu.tax_reference, null,hzp.tax_reference,hzcsu.tax_reference))
		UNION ALL
		SELECT 	jit.APPLICATION_ID application_id,
			jit.PARTY_ID party_id,					    --PARTY_ID
			DECODE(P_VEND_SORT_COL,'V',pv.vendor_name,'T',NVL(papf.national_identifier,NVL(pv.individual_1099,pv.num_1099)),
                       'R',NVL(pvs.vat_registration_num, pv.vat_registration_num)) sort_column,
			SUM(jit.TAXABLE_AMT) tot_taxable_amt,  		    --TAXABLE_AMT
			SUM(jit.VAT_AMT) tot_vat_amt,			    --VAT_AMT
			SUM(jit.NON_TAXABLE_AMT) tot_non_taxable_amt, 	    --NON_TAXABLE_AMT
			SUM(jit.EXEMPT_AMT) tot_exempt_amt,			    --EXEMPT_AMT
			SUM(jit.TAXABLE_VAT_AMT) tot_taxable_vat_amt,      	    --TAXABLE_VAT_AMT
			SUM(jit.TAXABLE_VAT_INV_AMT) tot_taxable_vat_inv_amt,    --TAXABLE_VAT_INV_AMT
			SUM(jit.CM_TAXABLE_AMT) tot_taxable_amt_cm,  		    --TAXABLE_AMT
			SUM(jit.CM_VAT_AMT) tot_vat_amt_cm,			    --VAT_AMT
			SUM(jit.CM_NON_TAXABLE_AMT) tot_non_taxable_amt_cm, 	    --NON_TAXABLE_AMT
			SUM(jit.CM_EXEMPT_AMT) tot_exempt_amt_cm,			    --EXEMPT_AMT
			SUM(jit.CM_TAXABLE_VAT_AMT) tot_taxable_vat_amt_cm,      	    --TAXABLE_VAT_AMT
			SUM(jit.CM_TAXABLE_VAT_INV_AMT) tot_taxable_vat_inv_amt_cm,    --TAXABLE_VAT_INV_AMT
  	            NVL(papf.national_identifier,NVL(pv.individual_1099,pv.num_1099)), --Supplier Tax Payer ID
		    NVL(pvs.vat_registration_num, pv.vat_registration_num)	   --Supplier Tax Registration Number
 			FROM je_it_list_lines_all jit,
			     ap_suppliers     pv,
		         ap_supplier_sites_all pvs,
		         (SELECT distinct person_id
			        ,national_identifier
		                  FROM per_all_people_f
	        	  WHERE nvl(effective_end_date,sysdate) >= sysdate ) papf
			WHERE jit.year_of_declaration = P_YEAR_OF_DECLARATION
			AND  jit.vat_reporting_entity_id = P_VAT_REPORTING_ENTITY_ID
			AND jit.APPLICATION_ID = 200
			AND jit.party_id = pv.vendor_id
			AND pvs.vendor_id                     = pv.vendor_id
		    AND pvs.tax_reporting_site_flag       = 'Y'
		    AND pv.federal_reportable_flag        = 'Y'
		    AND pvs.country                       = gv_vat_country_code
		    AND NVL(NVL(pvs.vat_registration_num, pv.vat_registration_num),'-99') <> gv_repent_trn
		    AND pv.employee_id = papf.person_id (+)
			GROUP BY jit.PARTY_ID,
			      jit.APPLICATION_ID,
      		      NVL(papf.national_identifier,NVL(pv.individual_1099,pv.num_1099)), --Supplier Tax Payer ID
		          NVL(pvs.vat_registration_num, pv.vat_registration_num),
			      DECODE(P_VEND_SORT_COL,'V',pv.vendor_name,'T',NVL(papf.national_identifier,NVL(pv.individual_1099,pv.num_1099)),
                 'R',NVL(pvs.vat_registration_num, pv.vat_registration_num))
		ORDER BY application_id DESC,sort_column;


              CURSOR  cur_trx_lines_group(P_VAT_REPORTING_ENTITY NUMBER
		                     ,P_YEAR_OF_DECLARATION  NUMBER
        				     ,P_CUST_SORT_COL        VARCHAR2
		          		     ,P_VEND_SORT_COL        VARCHAR2) IS
              SELECT *
		FROM
		(
                        SELECT COLLECTION.*,
                                   hzp.party_name party_name
                        FROM
                            (SELECT 	jit.application_id application_id,
                                    MAX(jit.PARTY_ID) party_id,					    --MAX PARTY_ID
                                    SUM(jit.TAXABLE_AMT) tot_taxable_amt,  		    --TAXABLE_AMT
                                    SUM(jit.VAT_AMT) tot_vat_amt,			    --VAT_AMT
                                    SUM(jit.NON_TAXABLE_AMT) tot_non_taxable_amt, 	    --NON_TAXABLE_AMT
                                    SUM(jit.EXEMPT_AMT) tot_exempt_amt,			    --EXEMPT_AMT
                                    SUM(jit.TAXABLE_VAT_AMT) tot_taxable_vat_amt,      	    --TAXABLE_VAT_AMT
                                    SUM(jit.TAXABLE_VAT_INV_AMT) tot_taxable_vat_inv_amt,    --TAXABLE_VAT_INV_AMT
                                    SUM(jit.CM_TAXABLE_AMT) tot_taxable_amt_cm,  		    --TAXABLE_AMT
                                    SUM(jit.CM_VAT_AMT) tot_vat_amt_cm,			    --VAT_AMT
                                    SUM(jit.CM_NON_TAXABLE_AMT) tot_non_taxable_amt_cm, 	    --NON_TAXABLE_AMT
                                    SUM(jit.CM_EXEMPT_AMT) tot_exempt_amt_cm,			    --EXEMPT_AMT
                                    SUM(jit.CM_TAXABLE_VAT_AMT) tot_taxable_vat_amt_cm,      	    --TAXABLE_VAT_AMT
                                    SUM(jit.CM_TAXABLE_VAT_INV_AMT) tot_taxable_vat_inv_amt_cm,    --TAXABLE_VAT_INV_AMT
                                        hzp.jgzz_fiscal_code tax_payer_id,   -- Customer Tax Payer ID
                                        DECODE(hzcsu.tax_reference, null,hzp.tax_reference,hzcsu.tax_reference) vat_reg_num-- Customer Tax Registration Number
                            FROM  JE_IT_LIST_LINES_ALL jit,
                                  hz_cust_site_uses_all  hzcsu,
                                  hz_cust_acct_sites_all hzcas,
                                  hz_cust_accounts   hzca,
                                  hz_parties         hzp
                            WHERE jit.vat_reporting_entity_id = P_VAT_REPORTING_ENTITY_ID
                            AND  jit.year_of_declaration = P_YEAR_OF_DECLARATION
                            AND  jit.APPLICATION_ID = 222
                            AND  jit.party_id = hzca.cust_account_id
                            AND hzcsu.cust_acct_site_id    = hzcas.cust_acct_site_id
                            AND hzcas.cust_account_id      = hzca.cust_account_id
                            AND hzca.party_id              = hzp.party_id
                            AND upper(hzcsu.site_use_code) = 'LEGAL'
                            AND hzcsu.primary_flag         = 'Y'
                            AND hzcsu.status               = 'A'
                            AND hzp.country                = gv_vat_country_code
                            AND NVL(decode(hzcsu.tax_reference, null,hzp.tax_reference,hzcsu.tax_reference),'-99')  <>  TO_CHAR(gv_repent_trn)
                            GROUP BY jit.APPLICATION_ID, hzp.jgzz_fiscal_code, DECODE(hzcsu.tax_reference, null,hzp.tax_reference,hzcsu.tax_reference)
                           ) COLLECTION,
                           hz_cust_accounts         hzca,
                           hz_parties         hzp
                          WHERE
                          COLLECTION.party_id = hzca.cust_account_id
                          AND hzca.party_id              = hzp.party_id

                      UNION ALL

                      SELECT COLLECTION.*,
                                   pv.vendor_name party_name
                      FROM

                              (SELECT 	jit.APPLICATION_ID application_id,
                                      MAX(jit.PARTY_ID) party_id,					    --MAX PARTY_ID
                                      SUM(jit.TAXABLE_AMT) tot_taxable_amt,  		    --TAXABLE_AMT
                                      SUM(jit.VAT_AMT) tot_vat_amt,			    --VAT_AMT
                                      SUM(jit.NON_TAXABLE_AMT) tot_non_taxable_amt, 	    --NON_TAXABLE_AMT
                                      SUM(jit.EXEMPT_AMT) tot_exempt_amt,			    --EXEMPT_AMT
                                      SUM(jit.TAXABLE_VAT_AMT) tot_taxable_vat_amt,      	    --TAXABLE_VAT_AMT
                                      SUM(jit.TAXABLE_VAT_INV_AMT) tot_taxable_vat_inv_amt,    --TAXABLE_VAT_INV_AMT
                                      SUM(jit.CM_TAXABLE_AMT) tot_taxable_amt_cm,  		    --TAXABLE_AMT
                                      SUM(jit.CM_VAT_AMT) tot_vat_amt_cm,			    --VAT_AMT
                                      SUM(jit.CM_NON_TAXABLE_AMT) tot_non_taxable_amt_cm, 	    --NON_TAXABLE_AMT
                                      SUM(jit.CM_EXEMPT_AMT) tot_exempt_amt_cm,			    --EXEMPT_AMT
                                      SUM(jit.CM_TAXABLE_VAT_AMT) tot_taxable_vat_amt_cm,      	    --TAXABLE_VAT_AMT
                                      SUM(jit.CM_TAXABLE_VAT_INV_AMT) tot_taxable_vat_inv_amt_cm,    --TAXABLE_VAT_INV_AMT
                                      NVL(papf.national_identifier,NVL(pv.individual_1099,pv.num_1099)) tax_payer_id, --Supplier Tax Payer ID
                                      NVL(pvs.vat_registration_num, pv.vat_registration_num) vat_reg_num   --Supplier Tax Registration Number
                                      FROM je_it_list_lines_all jit,
                                           ap_suppliers     pv,
                                       ap_supplier_sites_all pvs,
                                       (SELECT distinct person_id
                                              ,national_identifier
                                                FROM per_all_people_f
                                        WHERE nvl(effective_end_date,sysdate) >= sysdate ) papf
                                      WHERE jit.year_of_declaration = P_YEAR_OF_DECLARATION
                                      AND  jit.vat_reporting_entity_id = P_VAT_REPORTING_ENTITY_ID
                                      AND jit.APPLICATION_ID = 200
                                      AND jit.party_id = pv.vendor_id
                                      AND pvs.vendor_id                     = pv.vendor_id
                                  AND pvs.tax_reporting_site_flag       = 'Y'
                                  AND pv.federal_reportable_flag        = 'Y'
                                  AND pvs.country                       = gv_vat_country_code
                                  AND NVL(NVL(pvs.vat_registration_num, pv.vat_registration_num),'-99') <> gv_repent_trn
                                  AND pv.employee_id = papf.person_id (+)
                                  GROUP BY  jit.APPLICATION_ID,
                                    NVL(papf.national_identifier,NVL(pv.individual_1099,pv.num_1099)),
                                        NVL(pvs.vat_registration_num, pv.vat_registration_num)
                                  ) COLLECTION,
                          ap_suppliers     pv
                          WHERE
                          COLLECTION.party_id = pv.vendor_id
                )   OUTERQ
		ORDER BY OUTERQ.application_id DESC,
		DECODE (OUTERQ.application_id,
		222,
		DECODE(P_CUST_SORT_COL,'C',OUTERQ.party_name,'T',OUTERQ.tax_payer_id,'R',OUTERQ.vat_reg_num),
		200,
		DECODE(P_VEND_SORT_COL,'V',OUTERQ.party_name,'T',OUTERQ.tax_payer_id,'R',OUTERQ.vat_reg_num));


BEGIN
	IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JE.plsql.JE_IT_LISTING_PKG.Generate_trx_headers','Start PROCEDURE Generate_trx_headers');
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Generate_trx_headers','Parameters are :');
   	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Generate_trx_headers','P_VAT_REPORTING_ENTITY_ID	='||P_VAT_REPORTING_ENTITY_ID);
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Generate_trx_headers','P_YEAR_OF_DECLARATION	='||P_YEAR_OF_DECLARATION);
   	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Generate_trx_headers','P_VEND_SORT_COL	='||P_VEND_SORT_COL);
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JL.plsql.JE_IT_LISTING_PKG.Generate_trx_headers','P_CUST_SORT_COL	='||P_CUST_SORT_COL);
	END IF;

	g_retcode :=0;
	l_transnum :=1;
	l_count :=1;
	l_seq_num :=1;

	SAVEPOINT before_insert_parties;

        IF P_GROUP_PARTIES_FLAG IS NULL or P_GROUP_PARTIES_FLAG = 'N' THEN  -- If 'group by' paramater is set to No or Null

        	FOR rec_lines IN cur_trx_lines(P_VAT_REPORTING_ENTITY_ID,P_YEAR_OF_DECLARATION,P_CUST_SORT_COL ,P_VEND_SORT_COL ) LOOP

                    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                            FND_LOG.STRING(G_LEVEL_STATEMENT, 'JE.plsql.JE_IT_LISTING_PKG.Generate_trx_headers','Inside FOR rec_lines IN cur_trx_lines');
                            FND_LOG.STRING(G_LEVEL_STATEMENT, 'JE.plsql.JE_IT_LISTING_PKG.Generate_trx_headers','l_transnum = '||l_transnum);
                            FND_LOG.STRING(G_LEVEL_STATEMENT, 'JE.plsql.JE_IT_LISTING_PKG.Generate_trx_headers','l_count = '||l_count);
                    END IF;

                    IF l_count > nvl(g_rec_per_eft,l_count) THEN
                        l_transnum := l_transnum  + 1;
                            l_count :=1;
                    END IF;

                    INSERT INTO JE_IT_LIST_PARTIES_ALL
                    (VAT_REPORTING_ENTITY_ID,
                    YEAR_OF_DECLARATION,
                    TRANSMISSION_NUM,
                    APPLICATION_ID,
                    PARTY_ID,
                    TAXABLE_AMT,
                    VAT_AMT,
                    NON_TAXABLE_AMT,
                    EXEMPT_AMT,
                    TAXABLE_VAT_AMT,
                    TAXABLE_VAT_INV_AMT,
                    CM_TAXABLE_AMT,
                    CM_VAT_AMT,
                    CM_NON_TAXABLE_AMT,
                    CM_EXEMPT_AMT,
                    CM_TAXABLE_VAT_AMT,
                    CM_TAXABLE_VAT_INV_AMT,
                    FISCAL_ID_NUM,
                    VAT_REGISTRATION_NUM,
                    PARTY_SEQUENCE_NUM,
                    LAST_UPDATE_DATE,
                    LAST_UPDATED_BY,
                    LAST_UPDATE_LOGIN,
                    CREATION_DATE,
                    CREATED_BY
                    )
                    VALUES
                    (P_VAT_REPORTING_ENTITY_ID,
                    P_YEAR_OF_DECLARATION,
                    l_transnum,			             --TRANSMISSION_NUM
                    rec_lines.APPLICATION_ID,		 --APPLICATION_ID
                    rec_lines.PARTY_ID,		         --PARTY_ID
                    rec_lines.tot_taxable_amt,	     --TAXABLE_AMT
                    rec_lines.tot_vat_amt,         	 --VAT_AMT
                    rec_lines.tot_non_taxable_amt,   --NON_TAXABLE_AMT
                    rec_lines.tot_exempt_amt,    	 --EXEMPT_AMT
                    rec_lines.tot_taxable_vat_amt, 	  --TAXABLE_VAT_AMT
                    rec_lines.tot_taxable_vat_inv_amt,  --TAXABLE_VAT_INV_AMT
                    rec_lines.tot_taxable_amt_cm,	    --TAXABLE_AMT
                    rec_lines.tot_vat_amt_cm,         	--VAT_AMT
                    rec_lines.tot_non_taxable_amt_cm,    --NON_TAXABLE_AMT
                    rec_lines.tot_exempt_amt_cm,         --EXEMPT_AMT
                    rec_lines.tot_taxable_vat_amt_cm,    --TAXABLE_VAT_AMT
                    rec_lines.tot_taxable_vat_inv_amt_cm, --TAXABLE_VAT_INV_AMT
                    rec_lines.tax_payer_id,
                    rec_lines.vat_reg_num,
                    l_seq_num,
                    g_last_update_date,                     --LAST_UPDATE_DATE
                    g_last_updated_by,                      --LAST_UPDATED_BY
                    g_last_update_login,                    --LAST_UPDATE_LOGIN
                    g_creation_date,                        --CREATION_DATE
                    g_created_by                           --CREATED_BY
                    );

                    l_count := l_count + 1;
                    l_seq_num:= l_seq_num + 1;
               END LOOP;

        ELSE -- If 'group by' paramater is set to Yes

              FOR rec_lines IN cur_trx_lines_group(P_VAT_REPORTING_ENTITY_ID,P_YEAR_OF_DECLARATION,P_CUST_SORT_COL ,P_VEND_SORT_COL ) LOOP

                      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL ) THEN
                              FND_LOG.STRING(G_LEVEL_STATEMENT, 'JE.plsql.JE_IT_LISTING_PKG.Generate_trx_headers','Inside FOR rec_lines IN cur_trx_lines');
                              FND_LOG.STRING(G_LEVEL_STATEMENT, 'JE.plsql.JE_IT_LISTING_PKG.Generate_trx_headers','l_transnum = '||l_transnum);
                              FND_LOG.STRING(G_LEVEL_STATEMENT, 'JE.plsql.JE_IT_LISTING_PKG.Generate_trx_headers','l_count = '||l_count);
                      END IF;

                      IF l_count > nvl(g_rec_per_eft,l_count) THEN
                          l_transnum := l_transnum  + 1;
                              l_count :=1;
                      END IF;

                      INSERT INTO JE_IT_LIST_PARTIES_ALL
                      (VAT_REPORTING_ENTITY_ID,
                      YEAR_OF_DECLARATION,
                      TRANSMISSION_NUM,
                      APPLICATION_ID,
                      PARTY_ID,
                      TAXABLE_AMT,
                      VAT_AMT,
                      NON_TAXABLE_AMT,
                      EXEMPT_AMT,
                      TAXABLE_VAT_AMT,
                      TAXABLE_VAT_INV_AMT,
                      CM_TAXABLE_AMT,
                      CM_VAT_AMT,
                      CM_NON_TAXABLE_AMT,
                      CM_EXEMPT_AMT,
                      CM_TAXABLE_VAT_AMT,
                      CM_TAXABLE_VAT_INV_AMT,
                      FISCAL_ID_NUM,
                      VAT_REGISTRATION_NUM,
                      PARTY_SEQUENCE_NUM,
                      LAST_UPDATE_DATE,
                      LAST_UPDATED_BY,
                      LAST_UPDATE_LOGIN,
                      CREATION_DATE,
                      CREATED_BY
                      )
                      VALUES
                      (P_VAT_REPORTING_ENTITY_ID,
                      P_YEAR_OF_DECLARATION,
                      l_transnum,			             --TRANSMISSION_NUM
                      rec_lines.APPLICATION_ID,		 --APPLICATION_ID
                      rec_lines.PARTY_ID,		         --PARTY_ID
                      rec_lines.tot_taxable_amt,	     --TAXABLE_AMT
                      rec_lines.tot_vat_amt,         	 --VAT_AMT
                      rec_lines.tot_non_taxable_amt,   --NON_TAXABLE_AMT
                      rec_lines.tot_exempt_amt,    	 --EXEMPT_AMT
                      rec_lines.tot_taxable_vat_amt, 	  --TAXABLE_VAT_AMT
                      rec_lines.tot_taxable_vat_inv_amt,  --TAXABLE_VAT_INV_AMT
                      rec_lines.tot_taxable_amt_cm,	    --TAXABLE_AMT
                      rec_lines.tot_vat_amt_cm,         	--VAT_AMT
                      rec_lines.tot_non_taxable_amt_cm,    --NON_TAXABLE_AMT
                      rec_lines.tot_exempt_amt_cm,         --EXEMPT_AMT
                      rec_lines.tot_taxable_vat_amt_cm,    --TAXABLE_VAT_AMT
                      rec_lines.tot_taxable_vat_inv_amt_cm, --TAXABLE_VAT_INV_AMT
                      rec_lines.tax_payer_id,
                      rec_lines.vat_reg_num,
                      l_seq_num,
                      g_last_update_date,                     --LAST_UPDATE_DATE
                      g_last_updated_by,                      --LAST_UPDATED_BY
                      g_last_update_login,                    --LAST_UPDATE_LOGIN
                      g_creation_date,                        --CREATION_DATE
                      g_created_by                           --CREATED_BY
                      );

                      l_count := l_count + 1;
                      l_seq_num:= l_seq_num + 1;
              END LOOP;
        END IF;

	INSERT INTO JE_IT_LIST_HDR_ALL(
	VAT_REPORTING_ENTITY_ID,
	YEAR_OF_DECLARATION,
	STATUS_CODE,
	LAST_UPDATE_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN,
	CREATION_DATE,
	CREATED_BY)
	VALUES
	(P_VAT_REPORTING_ENTITY_ID,
	 P_YEAR_OF_DECLARATION,
 	 'P',
  	 g_last_update_date,
	 g_last_updated_by,
	 g_last_update_login,
	 g_creation_date,
	 g_created_by);

	COMMIT;

	IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
	       FND_LOG.STRING(G_LEVEL_PROCEDURE, 'JE.plsql.JE_IT_LISTING_PKG.Generate_trx_headers','End PROCEDURE Generate_trx_headers');
	END IF;
EXCEPTION
	WHEN OTHERS THEN
		g_retcode :=2;
		g_errbuf :='Exception in JE_IT_LISTING_PKG.Generate_trx_headers';
		IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
			FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Generate_trx_headers','Exception in PROCEDURE Generate_trx_headers');
		END IF;
		g_error_buffer  := SQLCODE || ': ' || SUBSTR(SQLERRM, 1, 80);
		IF g_debug_flag = 'Y' THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
		END IF;
		ROLLBACK TO before_insert_parties;
END Generate_trx_headers;
--------------------------------------------------------------------------------
/*===========================================================================+
 | PROCEDURE                                                                 |
 |   INITIALIZE_PROC_VAR                                                     |
 | DESCRIPTION                                                               |
 |    This procedure initializes all the Package variables                   |
 |                                                                           |
 | SCOPE - Private                                                           |
 |                                                                           |
 | NOTES                                                                     |
 |                                                                           |
 | MODIFICATION HISTORY                                                      |
 |  Date           Author          Description                               |
 |  ============  ==============  =================================          |
 |  14-Dec-2007   SPASUPUN               Initial  Version.                   |
 |                                                                           |
 +===========================================================================*/
 --------------------------------------------------------------------------------
PROCEDURE Initialize_proc_var( P_VAT_REPORTING_ENTITY_ID IN NUMBER,
                               P_YEAR_OF_DECLARATION     IN NUMBER) IS

		t_chart_of_accounts_id  NUMBER;
		t_set_of_books_name     VARCHAR2(30);
		t_func_curr             VARCHAR2(15);
		t_errorbuffer           VARCHAR2(132);
		t_date                  DATE;

   CURSOR entity_details IS
   SELECT repent.ledger_id,
          repent.balancing_segment_value,
          gl.chart_of_accounts_id
   FROM   jg_zz_vat_rep_entities repent
         ,gl_ledgers gl
   WHERE vat_reporting_entity_id = P_VAT_REPORTING_ENTITY_ID
   AND   gl.ledger_id = repent.ledger_id;

   CURSOR c_get_le_and_period_dates
    is
    SELECT  nvl(cfg.legal_entity_id,cfgd.legal_entity_id)
           ,nvl(cfg.tax_registration_number,cfgd.tax_registration_number) repent_trn
           ,min(glp.start_date)
           ,max(glp.end_date)
    FROM   jg_zz_vat_rep_entities cfg
           ,jg_zz_vat_rep_entities cfgd
           ,gl_periods glp
    WHERE  cfg.vat_reporting_entity_id = P_VAT_REPORTING_ENTITY_ID
    and   (
             ( cfg.entity_type_code  = 'ACCOUNTING'
               and cfg.mapping_vat_rep_entity_id = cfgd.vat_reporting_entity_id
             )
             or
            ( cfg.entity_type_code  = 'LEGAL'
               and cfg.vat_reporting_entity_id = cfgd.vat_reporting_entity_id
            )
         )
    AND    glp.period_set_name = nvl(cfg.tax_calendar_name,cfgd.tax_calendar_name)
    AND    glp.period_year = P_YEAR_OF_DECLARATION
    GROUP BY nvl(cfg.legal_entity_id,cfgd.legal_entity_id)
            ,nvl(cfg.tax_registration_number,cfgd.tax_registration_number)
            ,nvl(cfg.entity_identifier,cfgd.entity_identifier);

    CURSOR c_currency_vat_reg_num
    IS
    SELECT gllev.currency_code
           ,hl.country
    FROM   gl_ledger_le_v gllev
          ,gl_ledgers     gl
          ,xle_registrations       xr
          ,xle_entity_profiles     xep
          ,hr_locations_all        hl
    WHERE  gllev.ledger_category_code='PRIMARY'
    AND    gllev.legal_entity_id = gn_legal_entity_id
    AND    gl.ledger_id = gllev.ledger_id
    AND    xep.legal_entity_id   =  gllev.legal_entity_id
    AND    xr.source_id          =  xep.legal_entity_id
    AND    xr.source_table       = 'XLE_ENTITY_PROFILES'
    AND    xr.location_id        =  hl.location_id
    AND    xr.identifying_flag   = 'Y';

BEGIN

 	--Setting the application id for AP and AR

	gn_ap_app_id:=200;  --AP
	gn_ar_app_id:=222;  --AR

	g_lines_per_commit :=1000;
	g_retcode :=0;

 	g_debug_flag    := NVL(fnd_profile.value('aflog_enabled'), 'n');

	BEGIN

		OPEN entity_details;
		FETCH  entity_details
        INTO   gv_ledger_id,
	           gv_balancing_segment_value,
		       gv_chart_of_accounts_id;
        CLOSE entity_details;

	IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Initialize_proc_var','gv_ledger_id = '||gv_ledger_id);
		FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Initialize_proc_var','gv_balancing_segment_value = '||gv_balancing_segment_value);
		FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Initialize_proc_var','gv_chart_of_accounts_id = '||gv_chart_of_accounts_id);
	END IF;

	EXCEPTION
	 WHEN OTHERS THEN
		IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
			FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Initialize_proc_var','Exception in Fetching ledger id,balancing segment value and chart of account id');
		END IF;
		g_retcode :=2;
		g_errbuf :='Exception in Fetching ledger id,balancing segment value and chart of account id';
		g_error_buffer  := SQLCODE || ': ' || SUBSTR(SQLERRM, 1, 80);
		IF g_debug_flag = 'Y' THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
		END IF;
	END;

        BEGIN
		OPEN  c_get_le_and_period_dates;
    	FETCH c_get_le_and_period_dates
        INTO  gn_legal_entity_id
             ,gv_repent_trn
             ,gd_period_start_date
             ,gd_period_end_date;
        CLOSE c_get_le_and_period_dates;

	IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Initialize_proc_var','gn_legal_entity_id = '||gn_legal_entity_id);
		FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Initialize_proc_var','gv_repent_trn = '||gv_repent_trn);
		FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Initialize_proc_var','gd_period_start_date = '||gd_period_start_date);
		FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Initialize_proc_var','gd_period_end_date = '||gd_period_end_date);
	END IF;

       EXCEPTION
	 WHEN OTHERS THEN
		IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
			FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Initialize_proc_var','Exception in Fetching start and end date of the declaration year');
		END IF;
		g_retcode :=2;
		g_errbuf :='Exception in Fetching start and end date of the declaration year';
		g_error_buffer  := SQLCODE || ': ' || SUBSTR(SQLERRM, 1, 80);
		IF g_debug_flag = 'Y' THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
		END IF;
	END;



        BEGIN
		OPEN  c_currency_vat_reg_num ;
		FETCH c_currency_vat_reg_num
        INTO  gv_currency_code
        	 ,gv_vat_country_code ;
		CLOSE c_currency_vat_reg_num;

	IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
		FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Initialize_proc_var','gv_currency_code = '||gv_currency_code);
		FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Initialize_proc_var','gv_vat_country_code = '||gv_vat_country_code);
	END IF;


       EXCEPTION
	 WHEN OTHERS THEN
		IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
			FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Initialize_proc_var','Exception in Fetching start and end date of the declaration year');
		END IF;
		g_retcode :=2;
		g_errbuf :='Exception in Fetching start and end date of the declaration year';
		g_error_buffer  := SQLCODE || ': ' || SUBSTR(SQLERRM, 1, 80);
		IF g_debug_flag = 'Y' THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
		END IF;
	END;


   	----------------------------
	--initalize who variables
	---------------------------
        g_created_by        := NVL(fnd_profile.value('USER_ID'),1);
        g_creation_date     := SYSDATE;
        g_last_updated_by   := NVL(fnd_profile.value('USER_ID'),1);
        g_last_update_date  := SYSDATE;
        g_last_update_login := 1;

EXCEPTION
	WHEN OTHERS THEN
		g_retcode :=2;
		g_errbuf :='Exception in JE_IT_LISTING_PKG.Initialize_proc_var';
		IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
			FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.Initialize_proc_var','Exception in PROCEDURE Initialize_proc_var');
		END IF;
		g_error_buffer  := SQLCODE || ': ' || SUBSTR(SQLERRM, 1, 80);
		IF g_debug_flag = 'Y' THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
		END IF;
END Initialize_proc_var;
-----------------------------------------------------------------------------------

/*
REM +======================================================================+
REM Name: get_bsv
REM
REM Description: This function is called in the generic cursor for getting the
REM              BSV for each invoice distribution.
REM
REM
REM Parameters:  ccid  (code combination id)
REM
REM +======================================================================+
*/

FUNCTION get_bsv(ccid number) RETURN VARCHAR2 IS

l_segment VARCHAR2(30);
bal_segment_value VARCHAR2(25);

BEGIN

  SELECT application_column_name
  INTO   l_segment
  FROM   fnd_segment_attribute_values ,
         gl_ledgers gl
  WHERE    id_flex_code               = 'GL#'
    AND    attribute_value            = 'Y'
    AND    segment_attribute_type     = 'GL_BALANCING'
    AND    application_id             = 101
    AND    gl.chart_of_accounts_id    = gv_chart_of_accounts_id
    AND    gl.ledger_id               = gv_ledger_id;

  EXECUTE IMMEDIATE 'SELECT '||l_segment ||
                   ' FROM gl_code_combinations '||
                   ' WHERE code_combination_id = '||ccid
  INTO bal_segment_value;

  RETURN (bal_segment_value);

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		g_retcode :=2;
		g_errbuf :='Exception in JE_IT_LISTING_PKG.get_bsv';
		IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL ) THEN
			FND_LOG.STRING(G_LEVEL_EXCEPTION, 'JE.plsql.JE_IT_LISTING_PKG.get_bsv','Exception in FUNCTIONI get_bsv');
		END IF;
		g_error_buffer  := SQLCODE || ': ' || SUBSTR(SQLERRM, 1, 80);
		IF g_debug_flag = 'Y' THEN
			FND_FILE.PUT_LINE(FND_FILE.LOG, g_error_buffer);
		END IF;
      RETURN NULL;
END get_bsv;

END JE_IT_LISTING_PKG;


/
