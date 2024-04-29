--------------------------------------------------------
--  DDL for Package JA_CN_CFS_CONC_PROG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JA_CN_CFS_CONC_PROG" AUTHID CURRENT_USER AS
  --$Header: JACNCFSS.pls 120.2.12010000.2 2008/10/28 06:22:45 shyan ship $
  --+=======================================================================+
  --|               Copyright (c) 2006 Oracle Corporation
  --|                       Redwood Shores, CA, USA
  --|                         All rights reserved.
  --+=======================================================================
  --| FILENAME
  --|     JACNCFSS.pls
  --|
  --| DESCRIPTION
  --|
  --|   This is a wrapper package for submission of cash flow
  --|   statement related concurrent programs
  --|
  --|
  --| PROCEDURE LIST
  --|   Cfs_Generate
  --|   Cfs_Calculate
  --|   Cfsse_Generate
  --|   Cfsse_Calculate
  --|   Collect_Cfs_Data
  --|
  --| HISTORY
  --|   27-Mar-2006     Donghai Wang Created
  --|   28-Mar-2006     Jackey Li    Add Cfsse_Generate and  Cfsse_Calculate
  --|   28-Mar-2006     Andrew Liu   Add Collect_Cfs_Data
  --|   30-Mar-2006     Andrew Liu   Add GL_Validation/Intercompany_Validation
  --|   26-Jun-2006     Jackey Li    Update Cfsse_Generate
  --|   02/09/2008     Chaoqun Wu    Updated
  --|                                CNAO Enhancement: add company segment
  --|   22-Sep-2008     Chaoqun Wu   CNAO Enhancement for small enterprise
  --+======================================================================*/

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    Cfs_Generate               Public
  --
  --  DESCRIPTION:
  --
  --      The 'Cfs_Generate' procedure accepts parameters from concurrent program
  --      'Cash Flow Statement - Generation' and calls another procedure
  --      'JA_CN_CFS_GENERATE_PKG.Submit_Requests' with parameters after processing.
  --
  --  PARAMETERS:
  --      In: p_legal_entity_id           Identifier of legal entity
  --                                      for FSG report
  --          p_set_of_bks_id             Identifier of gl set of book
  --          p_coa_id                    Identifier of gl chart of account
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
  --     Out: errbuf
  --          retcode
  --
  --  DESIGN REFERENCES:
  --     CNAO_Cashflow_Statement_Generation_TD.doc
  --
  --  CHANGE HISTORY:
  --
  --      27-Mar-2006     Donghai Wang Created
  --
  --=========================================================================
  PROCEDURE Cfs_Generate(errbuf                  OUT NOCOPY VARCHAR2,
                         retcode                 OUT NOCOPY VARCHAR2,
                         p_legal_entity_id       IN NUMBER,
                         p_ledger_id             IN NUMBER,
                         P_DATA_ACCESS_SET_ID    IN NUMBER,
                         p_coa_id                IN NUMBER,
                         p_adhoc_prefix          IN VARCHAR2,
                         p_industry              IN VARCHAR2,
                         p_id_flex_code          IN VARCHAR2,
                         p_ledger_name           IN VARCHAR2,
                         p_report_id             IN NUMBER,
                         p_axis_set_id           IN NUMBER,
                         p_colset_id             IN NUMBER,
                         p_period_name           IN VARCHAR2,
                         p_currency_code         IN VARCHAR2,
                         p_rounding_option       IN VARCHAR2,
                         p_segment_override      IN VARCHAR2,
                         p_content_set_id        IN NUMBER,
                         P_ROW_ORDER_ID          IN NUMBER,
                         P_REPORT_DISPLAY_SET_ID IN NUMBER,
                         p_OUTPUT_OPTION         IN VARCHAR2,
                         p_EXCEPTIONS_FLAG       IN VARCHAR2,
                         p_MINIMUM_DISPLAY_LEVEL IN NUMBER,
                         p_accounting_date       IN VARCHAR2,
                         p_parameter_set_id      IN NUMBER,
                         P_PAGE_LENGTH           IN NUMBER,
                         p_SUBREQUEST_ID         IN NUMBER,
                         P_APPL_NAME             IN VARCHAR2

                        ,
                         p_balance_type IN VARCHAR2
                         --,p_internal_trx_flag       IN         VARCHAR2
                        ,
                         p_xml_template_language  IN VARCHAR2,
                         p_xml_template_territory IN VARCHAR2,
                         p_xml_output_format      IN VARCHAR2,
                         p_source_charset         IN VARCHAR2,
                         p_destination_charset    IN VARCHAR2,
                         p_source_separator       IN VARCHAR2,
                         p_destination_filename   IN VARCHAR2);

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --    Cfs_Calculate                  Public
  --
  --  DESCRIPTION:
  --
  --      The 'Cfs_Calculate' procedure accepts parameters from concurrent program
  --      'Cash Flow Statement -Calcluation' and calls another procedure
  --      'JA_CN_CFS_CALCULATE_PKG.Generate_Cfs_Xml' with parameters after processing.
  --
  --  PARAMETERS:
  --      In: p_legal_entity_id           Identifier of legal entity
  --          p_set_of_bks_id             Identifier of GL set of book, a required
  --                                      parameter for FSG report
  --          p_period_name               GL period Name
  --          p_axis_set_id               Identifier of FSG Row Set
  --          p_rounding_option           Rounding option for amount in Cash Flow statement
  --          p_balance_type              Type of balance, available value is
  --                                      'YTD/QTD/PTD'. a required parameter for FSG
  --                                      report
  --          p_internal_trx_flag         To indicate if intercompany transactions
  --                                      should be involved in amount calculation
  --                                      of cash flow statement.
  --
  --     Out: errbuf
  --          retcode
  --
  --
  --  DESIGN REFERENCES:
  --     CNAO_Cashflow_Statement_Generation_TD.doc
  --
  --  CHANGE HISTORY:
  --
  --      27-Mar-2006     Donghai Wang Created
  --
  --===========================================================================
  PROCEDURE Cfs_Calculate(errbuf            OUT NOCOPY VARCHAR2,
                          retcode           OUT NOCOPY VARCHAR2,
                          p_legal_entity_id IN NUMBER,
                          p_ledger_id       IN NUMBER,
                          p_period_name     IN VARCHAR2,
                          p_axis_set_id     IN NUMBER,
                          p_rounding_option IN VARCHAR2,
                          p_balance_type    IN VARCHAR2
                          --,p_internal_trx_flag       IN         VARCHAR2
                         ,p_coa IN NUMBER
                         ,p_segment_override IN VARCHAR2 -- Added for CNAO Enhancement
                         );

  --==========================================================================
  --  PROCEDURE NAME:
  --    Cfsse_Generate                     Public
  --
  --  DESCRIPTION:
  --      This procedure accepts parameters from concurrent program
  --      'Cash Flow Statement for small enterprise- Generation' and
  --      calls another procedure 'JA_CN_CFSSE_GENERATE_PKG.Submit_Requests'
  --      with parameters after processing.
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
  --          p_template_application_id        Application id for xml publisher template
  --          p_template                       XML publisher template
  --          p_template_locale                Template locale
  --          p_output_format                  Output format for xml publisher report
  --          p_parameter_set_id               Parameter set id
  --          p_max_page_length                Maximum page length
  --          p_balance_type                   Type of balance
  --          p_internal_trx_flag              intercompany transactions flag

  --     Out: errbuf
  --          retcode
  --
  --  DESIGN REFERENCES:
  --      CNAO_Cashflow_Statement_Generation(SE)_TD.doc
  --
  --  CHANGE HISTORY:
  --      03/29/2006      Jackey Li      Created
  --      06/26/2006      Jackey Li      Add seven parameters
  --===========================================================================
  PROCEDURE Cfsse_Generate(errbuf                  OUT NOCOPY VARCHAR2,
                           retcode                 OUT NOCOPY VARCHAR2,
                           p_legal_entity_id       IN NUMBER,
                           p_ledger_id             IN NUMBER,
                           P_DATA_ACCESS_SET_ID    IN NUMBER,
                           p_coa_id                IN NUMBER,
                           p_adhoc_prefix          IN VARCHAR2,
                           p_industry              IN VARCHAR2,
                           p_id_flex_code          IN VARCHAR2,
                           p_ledger_name           IN VARCHAR2,
                           p_report_id             IN NUMBER,
                           p_axis_set_id           IN NUMBER,
                           p_colset_id             IN NUMBER,
                           p_period_name           IN VARCHAR2,
                           p_currency_code         IN VARCHAR2,
                           p_rounding_option       IN VARCHAR2,
                           p_segment_override      IN VARCHAR2,
                           p_content_set_id        IN NUMBER,
                           P_ROW_ORDER_ID          IN NUMBER,
                           P_REPORT_DISPLAY_SET_ID IN NUMBER,
                           p_OUTPUT_OPTION         IN VARCHAR2,
                           p_EXCEPTIONS_FLAG       IN VARCHAR2,
                           p_MINIMUM_DISPLAY_LEVEL IN NUMBER,
                           p_accounting_date       IN VARCHAR2,
                           p_parameter_set_id      IN NUMBER,
                           P_PAGE_LENGTH           IN NUMBER,
                           p_SUBREQUEST_ID         IN NUMBER,
                           P_APPL_NAME             IN VARCHAR2

                          ,
                           p_balance_type IN VARCHAR2
                           --,p_internal_trx_flag       IN         VARCHAR2
                          ,
                           p_xml_template_language  IN VARCHAR2,
                           p_xml_template_territory IN VARCHAR2,
                           p_xml_output_format      IN VARCHAR2,
                           p_source_charset         IN VARCHAR2,
                           p_destination_charset    IN VARCHAR2,
                           p_source_separator       IN VARCHAR2,
                           p_destination_filename   IN VARCHAR2);

  --==========================================================================
  --  PROCEDURE NAME:
  --    Cfsse_Calculate                  Public
  --
  --  DESCRIPTION:
  --      This procedure accepts parameters from concurrent program
  --      'Cash Flow Statement for small enterprise -Calcluation'
  --      and calls another procedure 'JA_CN_CFS_CALCULATE_PKG.Generate_Cfs_Xml'
  --       with parameters after processing.
  --
  --  PARAMETERS:
  --      In: p_legal_entity_id           legal entity ID
  --          p_period_name               period name
  --          p_axis_set_id               axis set id
  --          p_rounding_option           rounding option
  --          p_balance_type              balance type
  --          p_internal_trx_flag         is intercompany transactions
  --
  --     Out: errbuf
  --          retcode
  --
  --  DESIGN REFERENCES:
  --      CNAO_Cashflow_Statement_Generation(SE)_TD.doc
  --
  --  CHANGE HISTORY:
  --      03/29/2006      Jackey Li          Created
  --===========================================================================
    PROCEDURE Cfsse_Calculate(ERRBUF              OUT NOCOPY VARCHAR2
                             ,RETCODE             OUT NOCOPY VARCHAR2
                             ,p_legal_entity_id   IN NUMBER
                             ,p_ledger_id     IN NUMBER
                             ,p_period_name       IN VARCHAR2
                             ,p_axis_set_id       IN NUMBER
                             ,p_rounding_option   IN VARCHAR2
                             ,p_balance_type      IN VARCHAR2
                             --,p_internal_trx_flag IN VARCHAR2 --updated by lyb
                             ,p_coa               IN number
                             ,p_segment_override  IN VARCHAR2); -- Added for CNAO Enhancement

  --==========================================================================
  --  PROCEDURE NAME:
  --    Collect_Cfs_Data              public
  --
  --  DESCRIPTION:
  --      This procedure checks year of FROM/TO periods and then collects
  --      CFS Data from GL/Intercompany/AR/AP.
  --
  --  PARAMETERS:
  --      Out: errbuf                 NOCOPY VARCHAR2
  --      Out: retcode                NOCOPY VARCHAR2
  --      In: P_LE_ID                 NUMBER              ID of Legal Entity
  --      In: P_SOB_ID                NUMBER              ID of Set Of Book
  --      In: P_GL_PERIOD_FROM        VARCHAR2            Start period
  --      In: P_GL_PERIOD_TO          VARCHAR2            End period
  --      In: P_SOURCE                VARCHAR2            Source of the collection
  --      In: P_DFT_ITEM              VARCHAR2            default CFS item
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      03/01/2006     Andrew Liu          Created
  --      03/30/2007     Yucheng Sun         Altered
  --===========================================================================
  PROCEDURE Collect_Cfs_Data(errbuf           OUT NOCOPY VARCHAR2,
                             retcode          OUT NOCOPY VARCHAR2,
                             P_COA_ID         IN NUMBER,
                             P_LE_ID          IN NUMBER,
                             p_LEDGER_ID      IN NUMBER,
                             P_GL_PERIOD_FROM IN VARCHAR2,
                             P_GL_PERIOD_TO   IN VARCHAR2,
                             P_SOURCE         IN VARCHAR2);

  --==========================================================================
  --  PROCEDURE NAME:
  --    GL_Validation                 Public
  --
  --  DESCRIPTION:
  --      This procedure calls Intercompany transactions validation program to
  --      check the Intercompany transactions.
  --
  --  PARAMETERS:
  --      Out: errbuf                 NOCOPY VARCHAR2
  --      Out: retcode                NOCOPY VARCHAR2
  --      In: P_COA_ID                NMBER               Chart of accounts ID
  --      In: P_LE_ID                 NUMBER              ID of Legal Entity
  --      In: P_LEDGER_ID             NUMBER              ID of ledger
  --      In: P_START_PERIOD          VARCHAR2            Start period
  --      In: P_END_PERIOD            VARCHAR2            End period
  --      In: P_SOURCE                VARCHAR2            Specified journal source
  --      In: P_JOURNAL_CTG           VARCHAR2            Specified journal category
  --      In: P_STATUS                VARCHAR2            Specified journal status
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      02/24/2006     Andrew Liu          Created
  --      04/21/2007     Yucheng Sun         Updated
  --                                         delete parameter: P_COM_SEGMENT
  --      03/09/2008     Chaoqun Wu          Updated
  --                                         CNAO Enhancement: add company segment
  --===========================================================================
  PROCEDURE GL_Validation(errbuf         OUT NOCOPY VARCHAR2,
                          retcode        OUT NOCOPY VARCHAR2,
                          P_COA_ID       IN NUMBER,
                          P_LE_ID        IN NUMBER,
                          P_LEDGER_ID    IN NUMBER,
                          P_START_PERIOD IN VARCHAR2,
                          P_END_PERIOD   IN VARCHAR2,
                          P_SOURCE       IN VARCHAR2,
                          P_JOURNAL_CTG  IN VARCHAR2,
                          P_STATUS       IN VARCHAR2,
                          P_COM_SEG      IN VARCHAR2       --Added for CNAO Enhancement
                          );

  --==========================================================================
  --  PROCEDURE NAME:
  --    Intercompany_Validation       Public
  --
  --  DESCRIPTION:
  --      This procedure calls Intercompany transactions validation program to
  --      check the Intercompany transactions.
  --
  --  PARAMETERS:
  --      Out: errbuf                 NOCOPY VARCHAR2
  --      Out: retcode                NOCOPY VARCHAR2
  --      In: P_COA_ID                NMBER               Chart of accounts ID
  --      In: P_LE_ID                 NUMBER              ID of Legal Entity
  --      In: P_LEDGER_ID             NUMBER              ID of ledger
  --      In: P_START_PERIOD          VARCHAR2            Start period
  --      In: P_END_PERIOD            VARCHAR2            End period
  --      In: P_STATUS                VARCHAR2            Specified journal status
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      02/24/2006     Andrew Liu          Created
  --      04/21/2007     Yucheng Sun         Updated
  --                                         delete parameter: P_COM_SEGMENT
  --      02/09/2008     Chaoqun Wu          Updated
  --                                         CNAO Enhancement: add company segment
  --===========================================================================
  PROCEDURE Intercompany_Validation(errbuf         OUT NOCOPY VARCHAR2,
                                    retcode        OUT NOCOPY VARCHAR2,
                                    P_COA_ID       IN NUMBER,
                                    P_LE_ID        IN NUMBER,
                                    P_LEDGER_ID    IN NUMBER,
                                    P_START_PERIOD IN VARCHAR2,
                                    P_END_PERIOD   IN VARCHAR2,
                                    P_STATUS       IN VARCHAR2,
                                    P_COM_SEG      IN VARCHAR2       --Added for CNAO Enhancement
                                    );

  --===========================================================================
  --added by lyb
  --===========================================================================

  PROCEDURE Item_Mapping_Analysis_Report(errbuf                      OUT NOCOPY VARCHAR2,
                                         retcode                     OUT NOCOPY VARCHAR2,
                                         P_APLICATION_ID             IN Number,
                                         P_EVENT_CLASS_CODE          IN Varchar2,
                                         P_SUPPORTING_REFERENCE_CODE IN Varchar2,
                                         P_CHART_OF_ACCOUNTS_ID      IN NUMBER);

  --==========================================================================
  --  PROCEDURE NAME:
  --    cfs_detail_report                 Public
  --
  --  DESCRIPTION:
  --      This procedure is to generate the cfs detail report.
  --
  --  PARAMETERS:
  --      Out: errbuf
  --      Out: retcode
  --      In: P_LE_ID                 ID of Legal Entity
  --      In: P_ledger_ID             ID of ledger
  --      In: P_chart_of_accounts_ID  Identifier of gl chart of account
  --      In: P_ADHOC_PREFIX          Ad hoc prefix for FSG report, a required
  --                                  parameter for FSG report
  --      In: P_INDUSTRY              Industry with constant value 'C' for
  --                                  now, a required parameter for FSG report
  --      In: P_ID_FLEX_CODE          ID flex code, a required parameter for
  --                                  FSG report
  --      In: P_REPORT_ID             Identifier of FSG report
  --      In: P_GL_PERIOD_FROM        Start period
  --      In: P_GL_PERIOD_TO          End period
  --      In: P_SOURCE                Source of the collection
  --      In: P_INTERNAL_TRX          To indicate if intercompany transactions
  --                                  should be involved in amount calculation
  --                                  of cash flow statement.
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      04/28/2007     Qingjun Zhao         Change
  --      09/09/2008     Yao Zhang            Change
  --===========================================================================

  PROCEDURE Cfs_Detail_Report(errbuf            OUT NOCOPY VARCHAR2,
                              retcode           OUT NOCOPY VARCHAR2,
                              P_LEGAL_ENTITY_ID IN NUMBER,
                              P_ledger_ID       IN NUMBER,
                              P_Chart_of_accounts_ID          IN NUMBER,
                              P_ADHOC_PREFIX    IN VARCHAR2,
                              P_INDUSTRY        IN VARCHAR2,
                              P_ID_FLEX_CODE    IN VARCHAR2,
                              P_REPORT_ID       IN NUMBER,
                              P_ROW_SET_ID      IN NUMBER,
                              P_ROW_NAME        IN VARCHAR2,
                              P_GL_PERIOD_FROM  IN VARCHAR2,
                              P_GL_PERIOD_TO    IN VARCHAR2,
                              P_SOURCE          IN VARCHAR2,
                              P_BSV             IN VARCHAR2);--Fix bug#7334017 add

END JA_CN_CFS_CONC_PROG;

/
