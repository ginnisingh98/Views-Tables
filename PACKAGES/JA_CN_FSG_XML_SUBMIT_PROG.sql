--------------------------------------------------------
--  DDL for Package JA_CN_FSG_XML_SUBMIT_PROG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_CN_FSG_XML_SUBMIT_PROG" AUTHID CURRENT_USER AS
--$Header: JACNFXRS.pls 120.0.12000000.1 2007/08/13 14:09:35 qzhao noship $
  --+=======================================================================+
  --|               Copyright (c) 2006 Oracle Corporation                   |
  --|                       Redwood Shores, CA, USA                         |
  --|                         All rights reserved.                          |
  --+=======================================================================+
  --| FILENAME                                                              |
  --|       JACNFXRS.pls                                                    |
  --|                                                                       |
  --| DESCRIPTION                                                           |
  --|                                                                       |
  --| PROCEDURE LIST                                                        |
  --|   PROCEDURE Submit_FSG_XML_Report                                     |
  --|   PROCEDURE Get_Lookup_Code                                           |
  --|   FUNCTION  Submit_FSG_Request                                        |
  --|   PROCEDURE Submit_xml_Publisher                                      |
  --|                                                                       |
  --| HISTORY                                                               |
  --|      06/02/2006     ShuJuan Yan         Created
  --|      17/04/2006     Joy liu             Updated                   |
  --+========================================================================
  --Declare global variable for package name
  g_module_name VARCHAR2(30) := 'JA_CN_FSG_XML_SUBMIT_PROG';
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

    FUNCTION  Submit_FSG_Request
	       (X_APPL_SHORT_NAME		IN 	VARCHAR2,
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
	     RETURN	BOOLEAN;


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
                                     x_result_flag     OUT NOCOPY VARCHAR2);
  --=========================================================================
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
    PROCEDURE Submit_FSG_XML_Report(errbuf            OUT NOCOPY VARCHAR2,
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
                                  );
end ja_cn_fsg_xml_submit_prog;

 

/
