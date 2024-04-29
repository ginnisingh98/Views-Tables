--------------------------------------------------------
--  DDL for Package JA_CN_CFS_GENERATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_CN_CFS_GENERATE_PKG" AUTHID CURRENT_USER AS
--$Header: JACNCGES.pls 120.0.12000000.1 2007/08/13 14:09:22 qzhao noship $
--+=======================================================================+
--|               Copyright (c) 2006 Oracle Corporation
--|                       Redwood Shores, CA, USA
--|                         All rights reserved.
--+=======================================================================
--| FILENAME
--|     JACNCGES.pls
--|
--| DESCRIPTION
--|
--|   This package is the main program for 'Cash Flow Statement - Generation'
--|
--|
--| PROCEDURE LIST
--|   Submit Requests
--|
--|
--| HISTORY
--|   24-Mar-2006     Donghai Wang Created
--|
--+======================================================================*/

--==========================================================================
--  PROCEDURE NAME:
--
--    Submit_Requests               Public
--
--  DESCRIPTION:
--
--   	The 'Submit_Requests' procedure is responsible for submit the following
--    four concurrent programs in turn to generate the final output file in 'TXT'
--    format for CNAO.
--       1. Cash Flow Statement - FSG
--       2. Cash Flow Statement - Calculation
--       3. Cash Flow Statement - Combination
--       4. XML Report Publisher
--
--  PARAMETERS:
--      In: p_legal_entity_id           Identifier of legal entity
--          p_ledger_id            Identifier of GL set of book, a required
--                                      parameter for FSG report
--          p_coa_id                    Chart of Accounts Id, a required parameter
--                                      for FSG report
--          p_adhoc_prefix              Ad hoc prefix for FSG report, a required
--                                      parameter for FSG report
--          p_industry                  Industry with constant value 'C' for
--                                      now, a required parameter for FSG report
--          p_id_flex_code              ID flex code, a required parameter for
--                                      FSG report
--          p_report_id                 Identifier of FSG report
--          p_period_name               GL period Name
--          p_axis_set_id               Identifier of FSG Row Set
--          p_colset_id                 Identifier of FSG Column Set, a required
--                                      parameter for FSG
--          p_rounding_option           Rounding option for amount in Cash Flow
--                                      statement
--          p_segment_override          Segment override for FSG report
--                                      flow statement calculation
--          p_accounting_date           Accounting date
--          p_parameter_set_id          Parameter set id, a required parameter
--                                      for FSG report
--          p_max_page_length           Maximum page length
--          p_balance_type              Type of balance, available value is
--                                      'YTD/QTD/PTD'. a required parameter for
--                                       FSG report
--          p_internal_trx_flag         To indicate if intercompany transactions
--                                      should be involved in amount calculation
--                                      of cash flow statement.
--          p_xml_template_language     Template language of Cash Flow Statement
--          p_xml_template_territory    Template territory of Cash Flow Statement
--          p_xml_output_format         Output format of Cash Flow Statement
--          p_source_charset            Characterset of input file for characterset
--                                      conversion
--          p_destination_charset       Characterset of output file for characterset
--                                      conversion
--          p_source_separator          Separater between fields in input file
--                                      for conversion
--          p_destination_filename      file name after change
--
--  DESIGN REFERENCES:
--     CNAO_Cashflow_Statement_Generation_TD.doc
--
--  CHANGE HISTORY:
--
--      24-Mar-2006     Donghai Wang Created
--
--===========================================================================

PROCEDURE Submit_Requests
(p_legal_entity_id         IN         NUMBER
 ,p_ledger_id              IN         NUMBER
 ,P_DATA_ACCESS_SET_ID     IN         NUMBER--added by lyb
 ,p_coa_id                 IN         NUMBER
 ,p_adhoc_prefix           IN         VARCHAR2
 ,p_industry               IN         VARCHAR2
 ,p_id_flex_code           IN         VARCHAR2
 ,p_ledger_name            IN         VARCHAR2
 ,p_report_id              IN         NUMBER
 ,p_axis_set_id            IN         NUMBER
 ,p_colset_id              IN         NUMBER
 ,p_period_name            IN         VARCHAR2
 ,p_currency_code          IN         VARCHAR2
 ,p_rounding_option        IN         VARCHAR2
 ,p_segment_override       IN         VARCHAR2
 ,p_content_set_id         IN      NUMBER
 ,P_ROW_ORDER_ID           IN      NUMBER
 ,P_REPORT_DISPLAY_SET_ID  IN      NUMBER
 ,p_OUTPUT_OPTION          IN         VARCHAR2
 ,p_EXCEPTIONS_FLAG        IN         VARCHAR2
 ,p_MINIMUM_DISPLAY_LEVEL  IN      NUMBER
 ,p_accounting_date        IN      varchar2
 ,p_parameter_set_id       IN      NUMBER
 ,P_PAGE_LENGTH            IN      NUMBER
 ,p_SUBREQUEST_ID          IN      NUMBER
 ,P_APPL_NAME              IN         VARCHAR2

,p_balance_type            IN         VARCHAR2
--,p_internal_trx_flag       IN         VARCHAR2
,p_xml_template_language   IN         VARCHAR2
,p_xml_template_territory  IN         VARCHAR2
,p_xml_output_format       IN         VARCHAR2
,p_source_charset          IN         VARCHAR2
,p_destination_charset     IN         VARCHAR2
,p_destination_filename    IN         VARCHAR2
,p_source_separator        IN         VARCHAR2
);

END JA_CN_CFS_GENERATE_PKG;

 

/
