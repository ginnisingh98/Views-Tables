--------------------------------------------------------
--  DDL for Package Body JA_CN_FSG_XML_SUBMIT_PROG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_CN_FSG_XML_SUBMIT_PROG" AS
--$Header: JACNFXRB.pls 120.4 2007/12/03 04:20:25 qzhao noship $
--+=======================================================================+
--|               Copyright (c) 2006 Oracle Corporation
--|                       Redwood Shores, CA, USA
--|                         All rights reserved.
--+=======================================================================
--| FILENAME
--|     JACNFXRB.pls
--|
--| DESCRIPTION
--|
--|     This package is used to submit FSG report and XML Report publisher.
--|
--| TYPE LIEST
--|     None
--| PROCEDURE LIST
--|   PROCEDURE Submit_FSG_XML_Report
--|   FUNCTION  Submit_FSG_Request
--|   PROCEDURE Submit_xml_Publisher
--|
--| HISTORY
--|   06/02/2006     ShuJuan Yan         Created
--|   27/04/2007     Joy liu             Updated
--|   the order and number of parameter is changed
--+======================================================================*/


  --==========================================================================
  --  FUNCTION NAME:
  --      Submit_FSG_Request                   Private
  --
  --  DESCRIPTION:
  --      This function is used to submit FSG report,
  --  PARAMETERS:
  --      In:
  --      X_APPL_SHORT_NAME		              Application short name
  --     	X_DATA_ACCESS_SET_ID    	        Data Acess ID
  --    	X_CONCURRENT_REQUEST_ID 	        CONCURRENT REQUEST ID
  --      X_PROGRAM               	        PROGRAM
  --  		X_COA_ID		                      char of accounts id
  --   		X_ADHOC_PREFIX			              ADHOC PREFIX
  --  		X_INDUSTRY		                    Industry
  --   		X_FLEX_CODE		                    Flex Code
  --      X_DEFAULT_LEDGER_SHORT_NAME	      Default Ledger short Name
  --  		X_REPORT_ID			                  Report ID
  -- 		  X_ROW_SET_ID			                Row Set ID
  --  		X_COLUMN_SET_ID			              Column Set ID
  -- 		  X_PERIOD_NAME           	        Period Name
  --  		X_UNIT_OF_MEASURE_ID    	        Unit of Measure ID/currency
  --  		X_ROUNDING_OPTION                 Rounding Option
  -- 	  	X_SEGMENT_OVERRIDE      	        Segment Override
  --  		X_CONTENT_SET_ID                  Content Set ID
  --   		X_ROW_ORDER_ID          	        Row Order ID
  --  		X_REPORT_DISPLAY_SET_ID 	        Report Display Set ID
  --		  X_OUTPUT_OPTION			              Out Option
  --  		X_EXCEPTIONS_FLAG       	        Exception
  --  		X_MINIMUM_DISPLAY_LEVEL 	        Minimum Display Level
  --  		X_ACCOUNTING_DATE                 Accounting Date
  --   		X_PARAMETER_SET_ID      	        Parameter set ID
  --  		X_PAGE_LENGTH			                Page Lenth
  --  		X_SUBREQUEST_ID                   SubRequest ID
  --  		X_APPL_DEFLT_NAME                 Application Default Name
  --      Out:
  --          X_CONCURRENT_REQUEST_ID       Concrrent Request ID
  --          X_PROGRAM                     Program
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --       06/14/2006     Shujuan Yan          Created
  --       27/04/2007     Joy liu             Updated
  --       the order and number of parameter is changed
  --==========================================================================

    FUNCTION  Submit_FSG_Request(
    X_APPL_SHORT_NAME		IN 	VARCHAR2,
 		X_DATA_ACCESS_SET_ID    	IN      NUMBER,
		X_CONCURRENT_REQUEST_ID 	OUT NOCOPY NUMBER,
    X_PROGRAM               	OUT NOCOPY VARCHAR2,
		X_COA_ID			IN      NUMBER,
		X_ADHOC_PREFIX			IN	VARCHAR2,
		X_INDUSTRY			IN	VARCHAR2,
		X_FLEX_CODE			IN	VARCHAR2,
    X_DEFAULT_LEDGER_SHORT_NAME	IN      VARCHAR2,
		X_REPORT_ID			IN      NUMBER,
		X_ROW_SET_ID			IN      NUMBER,
		X_COLUMN_SET_ID			IN	NUMBER,
		X_PERIOD_NAME           	IN      VARCHAR2,
 		X_UNIT_OF_MEASURE_ID    	IN      VARCHAR2,
 		X_ROUNDING_OPTION       	IN      VARCHAR2,
 		X_SEGMENT_OVERRIDE      	IN      VARCHAR2,
 		X_CONTENT_SET_ID        	IN      NUMBER,
 		X_ROW_ORDER_ID          	IN	NUMBER,
 		X_REPORT_DISPLAY_SET_ID 	IN      NUMBER,
		X_OUTPUT_OPTION			IN	VARCHAR2,
 		X_EXCEPTIONS_FLAG       	IN      VARCHAR2,
		X_MINIMUM_DISPLAY_LEVEL 	IN	NUMBER,
		X_ACCOUNTING_DATE       	IN      DATE,
 		X_PARAMETER_SET_ID      	IN      NUMBER,
		X_PAGE_LENGTH			IN	NUMBER,
		X_SUBREQUEST_ID                 IN      NUMBER,
		X_APPL_DEFLT_NAME               IN      VARCHAR2)
	     RETURN	BOOLEAN
   IS
     TYPE RepTyp IS RECORD
	       (row_set_id		NUMBER(15),
		column_set_id		NUMBER(15),
		unit_of_measure_id	VARCHAR2(30),
		content_set_id		NUMBER(15),
		row_order_id		NUMBER(15),
		rounding_option         VARCHAR2(1),
		parameter_set_id        NUMBER(15),
		minimum_display_level   NUMBER(15),
		report_display_set_id   NUMBER(15),
		output_option		VARCHAR2(1),
		report_title            VARCHAR2(240),
		segment_override        VARCHAR2(800));

     report_rec		RepTyp;

     req_id		NUMBER;
     rep_run_type	rg_report_content_sets.report_run_type%TYPE;
     L_COMPANY_NAME VARCHAR2(100);--show the company name
     L_LEGAL_ENTITY NUMBER(15);
   BEGIN
   --get legal_entity id
   L_LEGAL_ENTITY:=Fnd_Profile.VALUE(NAME => 'JA_CN_LEGAL_ENTITY');
   --get company name
   SELECT COMPANY_NAME
   INTO L_COMPANY_NAME
   FROM JA_CN_SYSTEM_PARAMETERS_ALL
   WHERE LEGAL_ENTITY_ID=L_LEGAL_ENTITY;

    SELECT 	row_set_id,
		column_set_id,
		unit_of_measure_id,
		content_set_id,
		row_order_id,
		rounding_option,
		parameter_set_id,
		minimum_display_level,
		report_display_set_id,
		output_option,
		name,
		segment_override
      INTO    report_rec
      FROM    RG_REPORTS
      WHERE   REPORT_ID = X_REPORT_ID;

      --
      -- If content set is used by this report then
      -- check the report run method.
      --
      IF (X_content_set_id IS NOT NULL) THEN
         SELECT report_run_type
         INTO   rep_run_type
         FROM   rg_report_content_sets
         WHERE  content_set_id = X_content_set_id;
      ELSE
         rep_run_type := 'S';
      END IF;

      IF (rep_run_type = 'P') THEN
         X_PROGRAM := 'RGSSRQ';
	 req_id := FND_REQUEST.SUBMIT_REQUEST('SQLGL',
				'RGSSRQ',
			   	report_rec.report_title,
				'',
				FALSE,
                                TO_CHAR(X_data_access_set_id),
                                TO_CHAR(X_COA_ID),
                                X_ADHOC_PREFIX,
                                X_INDUSTRY,
                                X_FLEX_CODE,
			        X_default_ledger_short_name,
		         	TO_CHAR(X_report_id),
		         	TO_CHAR(X_row_set_id),
			        TO_CHAR(X_column_set_id),
			        X_period_name,
			        X_unit_of_measure_id,
			        X_rounding_option,
			        X_segment_override,
			        TO_CHAR(X_content_set_id),
				TO_CHAR(X_row_order_id),
			        TO_CHAR(X_report_display_set_id),
				X_output_option,
			        X_exceptions_flag,
			        TO_CHAR(X_minimum_display_level),
			        TO_CHAR(X_accounting_date, 'YYYY/MM/DD'),
 			        TO_CHAR(X_parameter_set_id),
			        TO_CHAR(X_page_length),
			        X_appl_deflt_name,
                                L_COMPANY_NAME,
                                 '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', ''
                                 );
         IF (X_output_option = 'Y') THEN
            UPDATE 	FND_CONCURRENT_REQUESTS
            SET
              OUTPUT_FILE_TYPE = 'XML'
            WHERE
              REQUEST_ID = req_id;
         END IF;
      ELSE
          X_PROGRAM := 'JACNFSGC';
  	  req_id := FND_REQUEST.SUBMIT_REQUEST('JA',
				    'JACNFSGC',
				   report_rec.report_title,
				   '',
				   FALSE,
                                   TO_CHAR(X_data_access_set_id),
                                   TO_CHAR(X_COA_ID),
                                   X_ADHOC_PREFIX,
                                   X_INDUSTRY,
                                   X_FLEX_CODE,
			           X_default_ledger_short_name,
		         	   TO_CHAR(X_report_id),
		         	   TO_CHAR(X_row_set_id),
			           TO_CHAR(X_column_set_id),
			           X_period_name,
			           X_unit_of_measure_id,
			           X_rounding_option,
			           X_segment_override,
			           TO_CHAR(X_content_set_id),
				   TO_CHAR(X_row_order_id),
			           TO_CHAR(X_report_display_set_id),
				   X_output_option,
			           X_exceptions_flag,
			           TO_CHAR(X_minimum_display_level),
			           TO_CHAR(X_accounting_date, 'YYYY/MM/DD'),
 			           TO_CHAR(X_parameter_set_id),
			           TO_CHAR(X_page_length),
			           TO_CHAR(X_SUBREQUEST_ID),
			           X_appl_deflt_name,
                                   L_COMPANY_NAME,
                                   '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', ''
                                   );
         IF (X_output_option = 'Y') THEN
            UPDATE 	FND_CONCURRENT_REQUESTS
            SET
              OUTPUT_FILE_TYPE = 'XML'
            WHERE
              REQUEST_ID = req_id;
         END IF;
      END IF;

      IF (req_id = 0) THEN
         RETURN FALSE;
      ELSE
	 X_concurrent_request_id:= req_id;
	 return TRUE;
      END IF;
   END Submit_FSG_Request;




  --==========================================================================
  --  PROCEDURE NAME:
  --      Submit_xml_publiser                   Private
  --
  --  DESCRIPTION:
  --      This procedure is used to submit xml publisher concurrent,
  --  PARAMETERS:
  --      In: p_template_appl      template application
  --          p_ltemplate          template name
  --          p_template_locale    template locale
  --          p_output_format      output format
  --     Out: x_xml_request_id     xml request id
  --          x_result_flag        result flag
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --       06/03/2006     Shujuan Yan          Created
  --==========================================================================
   PROCEDURE    Submit_xml_Publisher(p_fsg_request_id IN NUMBER,
                                     p_template_appl   IN VARCHAR2,
                                     p_template        IN VARCHAR2,
                                     p_template_locale IN VARCHAR2,

                                     p_output_format   IN VARCHAR2,
                                     x_xml_request_id  OUT NOCOPY NUMBER,
                                     x_result_flag     OUT NOCOPY VARCHAR2) IS

    l_procedure_name     VARCHAR2(30) := 'Submit_xml_Publisher';
    l_runtime_level      NUMBER := fnd_log.g_current_runtime_level;
    l_procedure_level    NUMBER := fnd_log.level_procedure;
    --l_statement_level    NUMBER := fnd_log.level_statement;
    --l_exception_level    NUMBER := fnd_log.level_exception;
    l_complete_flag      BOOLEAN;
    l_phase              VARCHAR2(100);
    l_status             VARCHAR2(100);
    l_del_phase          VARCHAR2(100);
    l_del_status         VARCHAR2(100);
    l_message            VARCHAR2(1000);

  BEGIN
    --log for debug
    IF (l_procedure_level >= l_runtime_level) THEN
      fnd_log.STRING(l_procedure_level,
                     g_module_name || '.' || l_procedure_name || '.begin',
                     'begin procedure');
    END IF; --l_procedure_level >= l_runtime_level
    -- submit xml publisher concurrent program
    x_xml_request_id := fnd_request.submit_request('XDO',
                                                   'XDOREPPB',
                                                    NULL,
                                                    SYSDATE,
                                                    FALSE,
                                                    'Y',   --added by lyb, for bug 6642516
                                                    p_fsg_request_id,
                                                    p_template_appl,
                                                    p_template,
                                                    p_template_locale,
                                                    NULL,
                                                    NULL,
                                                    p_output_format);

      IF (x_xml_request_id <= 0 OR x_xml_request_id IS NULL)
      THEN
          x_result_flag := 'Error';
      ELSE
        COMMIT;
        --Wait for concurrent complete
        l_complete_flag := fnd_concurrent.wait_for_request(x_xml_request_id,
                                                           1,
                                                           0,
                                                           l_phase,
                                                           l_status,
                                                           l_del_phase,
                                                           l_del_status,
                                                           l_message);
        IF l_complete_flag = FALSE OR
           JA_CN_UTILITY.get_lookup_code(p_lookup_meaning => l_status,
                           p_lookup_type    => 'CP_STATUS_CODE') <> 'C'
        THEN
             x_result_flag := 'Error';
        ELSE x_result_flag := 'Sucess';
        END IF; -- l_complete_flag = false
     END IF; -- (x_xml_request_id <= 0 OR x_xml_request_id IS NULL)

    --log for debug
    IF (l_procedure_level >= l_runtime_level)
    THEN
      fnd_log.STRING(l_procedure_level,
                     g_module_name || '.' || l_procedure_name || '.end',
                     'end procedure');
    END IF; --l_procedure_level >= l_runtime_level
   EXCEPTION
   WHEN OTHERS THEN
      --log for debug
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
      THEN
        fnd_log.STRING(fnd_log.level_unexpected,
                       g_module_name || l_procedure_name ||
                       '. OTHER_EXCEPTION ',
                       SQLCODE || SQLERRM);
      END IF; -- fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
      RAISE;
  END Submit_xml_Publisher;
  --==========================================================================
  --  PROCEDURE NAME:
  --    Submit_FSG_XML_Report                  Private
  --
  --  DESCRIPTION:
  --     This procedure is used to submit FSG report and XML Report publisher .
  --  PARAMETERS:
  --      In:
  --      P_APPL_SHORT_NAME		              Application short name
  --     	P_DATA_ACCESS_SET_ID    	        Data Acess ID
  --    	P_CONCURRENT_REQUEST_ID 	        CONCURRENT REQUEST ID
  --      P_PROGRAM               	        PROGRAM
  --  		P_COA_ID		                      char of accounts id
  --   		P_ADHOC_PREFIX			              ADHOC PREFIX
  --  		P_INDUSTRY		                    Industry
  --   		P_FLEX_CODE		                    Flex Code
  --      P_DEFAULT_LEDGER_SHORT_NAME	      Default Ledger short Name
  --  		P_REPORT_ID			                  Report ID
  -- 		  P_ROW_SET_ID			                Row Set ID
  --  		P_COLUMN_SET_ID			              Column Set ID
  -- 		  P_PERIOD_NAME           	        Period Name
  --  		P_UNIT_OF_MEASURE_ID    	        Unit of Measure ID/currency
  --  		P_ROUNDING_OPTION                 Rounding Option
  -- 	  	P_SEGMENT_OVERRIDE      	        Segment Override
  --  		P_CONTENT_SET_ID                  Content Set ID
  --   		P_ROW_ORDER_ID          	        Row Order ID
  --  		P_REPORT_DISPLAY_SET_ID 	        Report Display Set ID
  --		  P_OUTPUT_OPTION			              Out Option
  --  		P_EXCEPTIONS_FLAG       	        Exception
  --  		P_MINIMUM_DISPLAY_LEVEL 	        Minimum Display Level
  --  		P_ACCOUNTING_DATE                 Accounting Date
  --   		P_PARAMETER_SET_ID      	        Parameter set ID
  --  		P_PAGE_LENGTH			                Page Lenth
  --  		P_SUBREQUEST_ID                   SubRequest ID
  --  		P_APPL_DEFLT_NAME                 Application Default Name

  --      p_template          Template name
  --      p_template_locale   Template locale
  --      p_output_format     Output format
  --      p_source_charset    source charset
  --      p_destination_charset  destination charset
  --      p_destination_filename destination filename
  --      p_source_separator     source separator
  --      Out:
  --          X_CONCURRENT_REQUEST_ID       Concrrent Request ID
  --          X_PROGRAM                     Program

  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      06/02/2006     Shujuan Yan          Created
  --       27/04/2007     Joy liu             Updated
  --       the order and number of parameter is changed
  --===========================================================================
  PROCEDURE Submit_FSG_XML_Report(errbuf              OUT NOCOPY VARCHAR2,
                                  retcode             OUT NOCOPY VARCHAR2,

                               		P_DATA_ACCESS_SET_ID    IN      NUMBER,
                                  P_COA_ID		          	IN      NUMBER,
                                  P_ADHOC_PREFIX          IN      VARCHAR2,
                                  P_INDUSTRY              IN      VARCHAR2,
                                  P_FLEX_CODE             IN      VARCHAR2,
                                  P_DEFAULT_LEDGER_SHORT_NAME   IN  VARCHAR2,
                              		P_REPORT_ID		          IN      NUMBER,
                              		P_ROW_SET_ID		        IN      NUMBER,
                              		P_COLUMN_SET_ID		      IN	    NUMBER,
                                  p_PERIOD_NAME           IN      VARCHAR2,
                                  p_UNIT_OF_MEASURE_ID    IN      VARCHAR2,
                                  P_ROUNDING_OPTION       IN      VARCHAR2,
                                  P_SEGMENT_OVERRIDE      IN      VARCHAR2,
                               		P_CONTENT_SET_ID        IN      NUMBER,
                               		P_ROW_ORDER_ID          IN	    NUMBER,
                               		P_REPORT_DISPLAY_SET_ID IN      NUMBER,
                              		P_OUTPUT_OPTION		      IN	    VARCHAR2,
                                  P_EXCEPTIONS_FLAG       IN      VARCHAR2,
                                  p_MINIMUM_DISPLAY_LEVEL IN	    NUMBER,
                                  p_ACCOUNTING_DATE       IN      VARCHAR2,
                               		P_PARAMETER_SET_ID      IN      NUMBER,
                               		p_PAGE_LENGTH		        IN	    NUMBER,

                                  p_subrequest_id         IN      NUMBER,
                                  P_APPL_DEFLT_NAME       IN      VARCHAR2,

                                  p_template          IN VARCHAR2,
                                  p_template_locale   IN VARCHAR2,



                                  p_output_format     IN VARCHAR2,
                                  p_source_charset    IN VARCHAR2,
                                  p_destination_charset     IN VARCHAR2,
                                  p_destination_filename    IN VARCHAR2,
                                  p_source_separator        IN VARCHAR2
                                  ) IS

    l_procedure_name     VARCHAR2(30) := 'Submit_FSG_XML_Report';
    l_dbg_level          NUMBER := FND_LOG.G_Current_Runtime_Level;
    l_proc_level         NUMBER := FND_LOG.Level_Procedure;
    --l_stmt_level         NUMBER := FND_LOG.Level_Statement;
    l_fsg_request_id     NUMBER;
    l_xml_request_id     NUMBER;
    l_program            VARCHAR2(10);
    l_submit_request_exp EXCEPTION;
    l_conc_succ          BOOLEAN;
    l_template_appl      NUMBER ;--VARCHAR2(50);
    --result flag
    l_xml_result_flag     VARCHAR2(15);
    l_charset_result_flag VARCHAR2(15);
    l_filename_result_flag VARCHAR2(15);

    l_charset_request_id  NUMBER;
    l_filename_request_id NUMBER;
  BEGIN

    --log for debug
    IF (l_proc_level >= l_dbg_level) THEN
      FND_LOG.STRING(l_proc_level,
                     g_module_name || '.' || l_procedure_name || '.begin',
                     'begin procedure');
    END IF; --( g_proc_level >= g_dbg_level)
        --call JA_CN_UTILITY.Check_Profile, if it doesn't return true, exit
    IF JA_CN_UTILITY.Check_Profile() <> TRUE THEN
      IF (l_proc_level >= l_dbg_level) THEN
        FND_LOG.STRING(l_proc_level,
                       l_procedure_name,
                       'Check profile failed!');
      END IF; --l_exception_level >= l_runtime_level
      retcode := 1;
      errbuf  := '';
      RETURN;
    END IF; --JA_CN_UTILITY.Check_Profile() != TRUE

    -- Submit FSG report
    IF
    Submit_FSG_Request('JA',
                   P_data_access_set_id,
                   l_fsg_request_id,
                   l_program,

                    P_COA_ID,
                    P_ADHOC_PREFIX,
                    P_INDUSTRY,
                    P_FLEX_CODE,
                    P_DEFAULT_LEDGER_SHORT_NAME,
                    P_REPORT_ID,
                    P_ROW_SET_ID,
                    P_COLUMN_SET_ID,
                    p_PERIOD_NAME,
                    p_UNIT_OF_MEASURE_ID,
                    P_ROUNDING_OPTION,
                    P_SEGMENT_OVERRIDE,
                 		P_CONTENT_SET_ID ,
                 		P_ROW_ORDER_ID,
                 		P_REPORT_DISPLAY_SET_ID,
                		P_OUTPUT_OPTION,
                    P_EXCEPTIONS_FLAG,
                    p_MINIMUM_DISPLAY_LEVEL,
                    to_date(p_ACCOUNTING_DATE, 'YYYY/MM/DD HH24:MI:SS'),

                 		P_PARAMETER_SET_ID,
                 		p_PAGE_LENGTH,

                    p_subrequest_id,
                    P_APPL_DEFLT_NAME

                 )
   THEN
       -- Get template application id
      SELECT APP.APPLICATION_ID
        INTO l_template_appl
        FROM FND_APPLICATION_VL      APP,
             FND_CONCURRENT_PROGRAMS FCP,
             FND_CONCURRENT_REQUESTS R
       WHERE FCP.CONCURRENT_PROGRAM_ID = R.CONCURRENT_PROGRAM_ID
         AND R.REQUEST_ID = l_fsg_request_id
         AND APP.APPLICATION_ID = FCP.APPLICATION_ID;
      --submit XML publisher concurrent program

      submit_xml_publisher(l_fsg_request_id,
                           l_template_appl,
                           p_template,
                           p_template_locale,
                           p_output_format,

                           l_xml_request_id,
                           l_xml_result_flag);
       IF l_xml_result_flag = 'Error'
       THEN
          errbuf  := fnd_message.get;
          retcode := 2;
          RAISE l_submit_request_exp;
       ELSE
          -- submit charset conversion concurrent program
          JA_CN_UTILITY.submit_charset_conversion(l_xml_request_id,
                                                  p_source_charset,
                                                  p_destination_charset,
                                                  p_source_separator,
                                                  l_charset_request_id,
                                                  l_charset_result_flag);

            IF l_charset_result_flag = 'Error'
            THEN
               errbuf  := fnd_message.get;
               retcode := 2;
               RAISE l_submit_request_exp;
            ELSE
               --submit change output filename concurrent program
               JA_CN_UTILITY.change_output_filename(l_xml_request_id,
                                                    p_destination_charset,
                                                    p_destination_filename,
                                                    l_filename_request_id,
                                                    l_filename_result_flag);
                IF l_filename_result_flag = 'Error'
                THEN
                   errbuf  := fnd_message.get;
                   retcode := 2;
                   RAISE l_submit_request_exp;
                END IF; --l_filename_result_flag = 'Error'
             END IF; --l_charset_result_flag = 'Error'
          END IF; --l_xml_error_flag = 'Error'
      END IF;


    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.STRING(l_proc_level,
                     g_module_name || '.' || l_procedure_name || '.end',
                     'end procedure');
    END IF; --( g_proc_level >= g_dbg_level)
  EXCEPTION
    WHEN l_submit_request_exp
    THEN
      fnd_file.put_line(fnd_file.output, SQLCODE || ':' || SQLERRM);
      l_conc_succ := fnd_concurrent.set_completion_status(status  => 'ERROR',
                                                          message => SQLCODE || ':' ||
                                                                     SQLERRM);
      --log for debug
      IF (l_proc_level >= l_dbg_level)
      THEN
        fnd_log.STRING(l_proc_level,
                       g_module_name || '.' || l_procedure_name ||
                       '. Submit_Request_Exception ',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)
    WHEN OTHERS THEN
      fnd_file.put_line(fnd_file.output, SQLCODE || ':' || SQLERRM);
      l_conc_succ := fnd_concurrent.set_completion_status(status  => 'ERROR',
                                                          message => SQLCODE || ':' ||
                                                                     SQLERRM);
      --log for debug
      IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
      THEN
        fnd_log.STRING(fnd_log.level_unexpected,
                       g_module_name || l_procedure_name ||
                       '. OTHER_EXCEPTION ',
                       SQLCODE || SQLERRM);
      END IF;
      RAISE;
 END Submit_FSG_XML_Report;
end ja_cn_fsg_xml_submit_prog;


/
