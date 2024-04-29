--------------------------------------------------------
--  DDL for Package JA_CN_CFSSE_GENERATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_CN_CFSSE_GENERATE_PKG" AUTHID CURRENT_USER AS
  --$Header: JACNCSES.pls 120.0.12010000.2 2008/10/28 06:34:45 shyan ship $
  --+=======================================================================+
  --|               Copyright (c) 2006 Oracle Corporation                   |
  --|                       Redwood Shores, CA, USA                         |
  --|                         All rights reserved.                          |
  --+=======================================================================+
  --| FILENAME                                                              |
  --|     JACNCSES.pls                                                      |
  --|                                                                       |
  --| DESCRIPTION                                                           |
  --|     This package is the main program for 'Cash Flow Statement         |
  --|             for small enterprise - Generation'                        |
  --|                                                                       |
  --| Public PROCEDURE LIST                                                 |
  --|      PROCEDURE  Submit_Requests                                       |
  --|                                                                       |
  --| HISTORY                                                               |
  --|      03/22/2006  Jackey Li   Created                                  |
  --|      2006-06-26  Jackey Li   Updated                                  |
  --|                              add seven parameters for the procedure   |
  --|                               'Submit_Requests'                       |
  --|      09/22/2008  Chaoqun Wu  Updated for CNAO Enhancement             |
  --+======================================================================*/

  --==========================================================================
  --  PROCEDURE NAME:
  --    Submit_Requests                     Public
  --
  --  DESCRIPTION:
  --      It is responsible for submit four concurrent programs
  --        in turn to generate the final output file in 'TXT' format for CNAO.
  --
  --  PARAMETERS:
  --      In: p_legal_entity_id                legal entity ID
  --          p_set_of_bks_id                  set of books ID
  --          p_coa_id                         Chart of Accounts ID
  --          p_adhoc_prefix                   Ad hoc prefix for FSG report
  --          p_industry                       Industry with constant value 'C'
  --          p_id_flex_code                   ID flex code
  --          p_report_id                      FSG report id
  --          p_perid_name                     GL period Name
  --          p_rowset_id                      FSG report row Set ID
  --          p_colset_id                      FSG report column Set ID
  --          p_rounding_option                Rounding option
  --          p_segment_override               Segment override
  --          p_accounting_date                Accounting date
  --          p_parameter_set_id               Parameter set id
  --          p_max_page_length                Maximum page length
  --          p_balance_type                   Type of balance
  --          p_internal_trx_flag              intercompany transactions flag
  --
  --  DESIGN REFERENCES:
  --      CNAO_Cashflow_Statement_Generation(SE)_TD.doc
  --
  --  CHANGE HISTORY:
  --      03/22/2006  Jackey Li   Created
  --      2006-06-26  Jackey Li   add seven parameters
  --==========================================================================

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



END JA_CN_CFSSE_GENERATE_PKG;

/
