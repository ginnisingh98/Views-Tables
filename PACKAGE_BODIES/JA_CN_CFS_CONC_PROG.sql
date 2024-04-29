--------------------------------------------------------
--  DDL for Package Body JA_CN_CFS_CONC_PROG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_CN_CFS_CONC_PROG" AS
  --$Header: JACNCFSB.pls 120.3.12010000.2 2008/10/28 06:21:07 shyan ship $
  --+=======================================================================+
  --|               Copyright (c) 2006 Oracle Corporation
  --|                       Redwood Shores, CA, USA
  --|                         All rights reserved.
  --+=======================================================================
  --| FILENAME
  --|     JACNCFSB.pls
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
  --|   1-Sep-2008     Chaoqun Wu  CNAO Enhancement
  --|                              Updated procedures Calculate_Row_Amount and Calculate_Rows_Amount
  --|                              Added BSV parameter for CFS-Generation
  --|   08/09/2008     Yao Zhang   Fix Bug#7334017 for R12 enhancment
  --|   22-Sep-2008    Chaoqun Wu  CNAO Enhancement for small enterprise
  --|
  --+======================================================================*/
  l_module_prefix VARCHAR2(100) := 'JA_CN_CFS_CONC_PROG';

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
                         p_destination_filename   IN VARCHAR2) IS
    l_error_flag   VARCHAR2(1) := 'N';
    l_error_status BOOLEAN;

    l_dbg_level  NUMBER := FND_LOG.G_Current_Runtime_Level;
    l_proc_level NUMBER := FND_LOG.Level_Procedure;
    l_proc_name  VARCHAR2(100) := 'Cfs_Generate';

  BEGIN

    --log for debug
    IF (l_proc_level >= l_dbg_level) THEN
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.begin',
                     'Enter procedure');

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_legal_entity_id ' || p_legal_entity_id);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_ledger_id  ' || p_ledger_id);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_coa_id   ' || p_coa_id);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_adhoc_prefix ' || p_adhoc_prefix);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_industry ' || p_industry);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_id_flex_code ' || p_id_flex_code);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_report_id ' || p_report_id);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_period_name ' || p_period_name);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_axis_set_id ' || p_axis_set_id);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_colset_id ' || p_colset_id);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_rounding_option ' || p_rounding_option);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_segment_override ' || p_segment_override);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_accounting_date ' || p_accounting_date);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_parameter_set_id ' || p_parameter_set_id);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_PAGE_LENGTH ' || P_PAGE_LENGTH);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_balance_type ' || p_balance_type);

      /*    FND_LOG.String(l_proc_level
      ,l_module_prefix||'.'||l_proc_name||'.parameters'
      ,'p_internal_trx_flag '||p_internal_trx_flag
      );*/

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_xml_template_language ' || p_xml_template_language);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_xml_template_territory  ' ||
                     p_xml_template_territory);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_xml_output_format  ' || p_xml_output_format);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_source_charset ' || p_source_charset);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_destination_charset ' || p_destination_charset);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_source_separator ' || p_source_separator);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_destination_filename ' || p_destination_filename);
    END IF; --(l_proc_level >= l_dbg_level)

    --Call the functon JA_CN_UTILITY.Check_Profile to check if all required profiles has been
    -- properly set for current responsibility. If No, the function will raise corresponding error
    --messages, and the concurrent program will not continue performing next logics,these required
    --profiles include ' JG: Product', which should be set to 'Asia/Pacific Localizations',
    --'JG: Territory', which should be set to 'China' and 'JA: CNAO Legal Entity', which should be
    --NOT NULL
    IF JA_CN_UTILITY.Check_Profile THEN

      JA_CN_CFS_GENERATE_PKG.Submit_Requests(p_legal_entity_id,
                                             p_ledger_id,
                                             P_DATA_ACCESS_SET_ID,
                                             p_coa_id,
                                             p_adhoc_prefix,
                                             p_industry,
                                             p_id_flex_code,
                                             p_ledger_name,
                                             p_report_id,
                                             p_axis_set_id,
                                             p_colset_id,
                                             p_period_name,
                                             p_currency_code,
                                             p_rounding_option,
                                             p_segment_override,
                                             p_content_set_id,
                                             P_ROW_ORDER_ID,
                                             P_REPORT_DISPLAY_SET_ID,
                                             p_OUTPUT_OPTION,
                                             p_EXCEPTIONS_FLAG,
                                             p_MINIMUM_DISPLAY_LEVEL,
                                             p_accounting_date,
                                             p_parameter_set_id,
                                             P_PAGE_LENGTH,
                                             p_SUBREQUEST_ID,
                                             P_APPL_NAME

                                            ,
                                             p_balance_type
                                             --,p_internal_trx_flag       IN         VARCHAR2
                                            ,
                                             p_xml_template_language,
                                             p_xml_template_territory,
                                             p_xml_output_format,
                                             p_source_charset,
                                             p_destination_charset,
                                             p_source_separator,
                                             p_destination_filename);

    ELSE
      l_error_flag := 'Y';
    END IF; --JA_CN_UTILITY.Check_Profile

    --If above check failed, then set status of concurrent program as warning

    IF l_error_flag = 'Y' THEN
      l_error_status := FND_CONCURRENT.Set_Completion_Status(status  => 'WARNING',
                                                             message => '');

    END IF; --JA_CN_UTILITY.Check_Profile
    --log for debug
    IF (l_proc_level >= l_dbg_level) THEN
      FND_LOG.STRING(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.end',
                     'Exit procedure');
    END IF; --( l_proc_level >= l_dbg_level )

  EXCEPTION
    WHEN OTHERS THEN
      IF (l_proc_level >= l_dbg_level) THEN
        FND_LOG.String(l_proc_level,
                       l_module_prefix || '.' || l_proc_name ||
                       '. Other_Exception ',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)

  END Cfs_Generate;

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
  --      1-Sep-2008      Chaoqun Wu CNAO Enhancement
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
                         ) IS
    l_error_status BOOLEAN;
    l_dbg_level    NUMBER := FND_LOG.G_Current_Runtime_Level;
    l_proc_level   NUMBER := FND_LOG.Level_Procedure;
    l_proc_name    VARCHAR2(100) := 'Cfs_Calculate';

  BEGIN

    --log for debug
    IF (l_proc_level >= l_dbg_level) THEN
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.begin',
                     'Enter procedure');

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_legal_entity_id ' || p_legal_entity_id);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_ledger_id ' || p_ledger_id);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_period_name ' || p_period_name);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_axis_set_id ' || p_axis_set_id);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_rounding_option ' || p_rounding_option);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_balance_type ' || p_balance_type);

      FND_LOG.String(l_proc_level,                                          --Added for CNAO Enhancement
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_segmment_override ' || p_segment_override);

      /*    FND_LOG.String(l_proc_level
      ,l_module_prefix||'.'||l_proc_name||'.parameters'
      ,'p_internal_trx_flag '||p_internal_trx_flag
      );*/

    END IF; --(l_proc_level >= l_dbg_level)

    --Call the functon JA_CN_CFS_UTILITY.Check_Profile to check if all required profiles has been
    -- properly set for current responsibility. If No, the function will raise corresponding error
    --messages, and the concurrent program will not continue performing next logics,these required
    --profiles include ' JG: Product', which should be set to 'Asia/Pacific Localizations',
    --'JG: Territory', which should be set to 'China' and 'JA: CNAO Legal Entity', which should be
    --NOT NULL
    IF JA_CN_UTILITY.Check_Profile THEN
      JA_CN_CFS_CALCULATE_PKG.Generate_Cfs_Xml(p_legal_entity_id => p_legal_entity_id,
                                               p_ledger_id       => p_ledger_id,
                                               p_period_name     => p_period_name,
                                               p_axis_set_id     => p_axis_set_id,
                                               p_rounding_option => p_rounding_option,
                                               p_balance_type    => p_balance_type
                                               --,p_internal_trx_flag                  => p_internal_trx_flag
                                              ,p_coa => p_coa
                                              ,p_segment_override => p_segment_override -- Added for CNAO Enhancement
                                              );
    ELSE
      --If above check failed, then set status of concurrent program as warning
      l_error_status := FND_CONCURRENT.Set_Completion_Status(status  => 'WARNING',
                                                             message => '');
    END IF; --JA_CN_UTILITY.Check_Profile

    --log for debug
    IF (l_proc_level >= l_dbg_level) THEN
      FND_LOG.STRING(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.end',
                     'Exit procedure');
    END IF; --( l_proc_level >= l_dbg_level )

  EXCEPTION
    WHEN OTHERS THEN
      IF (l_proc_level >= l_dbg_level) THEN
        FND_LOG.String(l_proc_level,
                       l_module_prefix || '.' || l_proc_name ||
                       '. Other_Exception ',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)

  END Cfs_Calculate;

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
  --      03/29/2006      Jackey Li          Created
  --      06/26/2006      Jackey Li      Add seven parameters
  --      04/29/2007      Joy liu        updated by lyb
  --     change parameter p_set_of_bks_id to  p_ledger_id,
  --     some places has been updated.
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
                         p_destination_filename   IN VARCHAR2) IS

    l_accounting_date DATE := FND_DATE.Canonical_To_Date(p_accounting_date);
   -- l_sets_of_bks_id  gl_sets_of_books.set_of_books_id%TYPE;
    --l_coa_id          gl_sets_of_books.chart_of_accounts_id%TYPE;
    l_flag            NUMBER;
    l_error_flag      VARCHAR2(1) := 'N';
    l_error_status    BOOLEAN;

    l_dbg_level  NUMBER := FND_LOG.G_Current_Runtime_Level;
    l_proc_level NUMBER := FND_LOG.Level_Procedure;
    l_proc_name  VARCHAR2(100) := 'Cfsse_Generate';

  BEGIN
    --log for debug
    IF (l_proc_level >= l_dbg_level)
    THEN
     FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.begin',
                     'Enter procedure');

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_legal_entity_id ' || p_legal_entity_id);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_ledger_id  ' || p_ledger_id);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_coa_id   ' || p_coa_id);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_adhoc_prefix ' || p_adhoc_prefix);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_industry ' || p_industry);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_id_flex_code ' || p_id_flex_code);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_report_id ' || p_report_id);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_period_name ' || p_period_name);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_axis_set_id ' || p_axis_set_id);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_colset_id ' || p_colset_id);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_rounding_option ' || p_rounding_option);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_segment_override ' || p_segment_override);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_accounting_date ' || p_accounting_date);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_parameter_set_id ' || p_parameter_set_id);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_PAGE_LENGTH ' || P_PAGE_LENGTH);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_balance_type ' || p_balance_type);

      /*    FND_LOG.String(l_proc_level
      ,l_module_prefix||'.'||l_proc_name||'.parameters'
      ,'p_internal_trx_flag '||p_internal_trx_flag
      );*/

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_xml_template_language ' || p_xml_template_language);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_xml_template_territory  ' ||
                     p_xml_template_territory);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_xml_output_format  ' || p_xml_output_format);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_source_charset ' || p_source_charset);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_destination_charset ' || p_destination_charset);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_source_separator ' || p_source_separator);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_destination_filename ' || p_destination_filename);
    END IF; --(l_proc_level >= l_dbg_level)

    IF JA_CN_UTILITY.Check_Profile
    THEN

      --To get gl set of book and chart of account for current legal entity
/*      JA_CN_UTILITY.Get_SOB_And_COA(p_legal_entity_id => p_legal_entity_id,
                                    x_sob_id          => l_sets_of_bks_id,
                                    x_coa_id          => l_coa_id,
                                    x_flag            => l_flag);
      IF l_flag = 0
      THEN*/
        FND_FILE.Put_Line(FND_FILE.LOG,
                          'Submit actual CFS SE Generation Concurrent.');

        FND_FILE.Put_Line(FND_FILE.LOG,
                          'Start');

        JA_CN_CFSSE_GENERATE_PKG.Submit_Requests(p_legal_entity_id,
                                             p_ledger_id,
                                             P_DATA_ACCESS_SET_ID,
                                             p_coa_id,
                                             p_adhoc_prefix,
                                             p_industry,
                                             p_id_flex_code,
                                             p_ledger_name,
                                             p_report_id,
                                             p_axis_set_id,
                                             p_colset_id,
                                             p_period_name,
                                             p_currency_code,
                                             p_rounding_option,
                                             p_segment_override,
                                             p_content_set_id,
                                             P_ROW_ORDER_ID,
                                             P_REPORT_DISPLAY_SET_ID,
                                             p_OUTPUT_OPTION,
                                             p_EXCEPTIONS_FLAG,
                                             p_MINIMUM_DISPLAY_LEVEL,
                                             p_accounting_date,
                                             p_parameter_set_id,
                                             P_PAGE_LENGTH,
                                             p_SUBREQUEST_ID,
                                             P_APPL_NAME

                                            ,
                                             p_balance_type
                                             --,p_internal_trx_flag       IN         VARCHAR2
                                            ,
                                             p_xml_template_language,
                                             p_xml_template_territory,
                                             p_xml_output_format,
                                             p_source_charset,
                                             p_destination_charset,
                                             p_source_separator,
                                             p_destination_filename);
        FND_FILE.Put_Line(FND_FILE.LOG,
                          'Complete');
/*      ELSE
        l_error_flag := 'Y';
        --output error message
        FND_MESSAGE.Set_Name('JA',
                             'JA_CN_MISSING_BOOK_INFO');
        FND_FILE.Put_Line(FND_FILE.Output,
                          FND_MESSAGE.Get);
      END IF; --l_flag=0*/
    ELSE
      l_error_flag := 'Y';
    END IF; --JA_CN_UTILITY.Check_Profile

    --If above check failed, then set status of concurrent program as warning

    IF l_error_flag = 'Y'
    THEN
      l_error_status := FND_CONCURRENT.Set_Completion_Status(status  => 'WARNING',
                                                             message => '');

    END IF; --l_error_flag = 'Y'

    --log for debug
    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.STRING(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.end',
                     'Exit procedure');
    END IF; --( l_proc_level >= l_dbg_level )

  EXCEPTION
    WHEN OTHERS THEN
      IF (l_proc_level >= l_dbg_level)
      THEN
        FND_LOG.STRING(l_proc_level,
                       l_module_prefix || '.' || l_proc_name ||
                       '. Other_Exception ',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)

  END Cfsse_Generate;

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
                           ,p_segment_override IN VARCHAR2) IS -- Added for CNAO Enhancement

   -- l_sob_id       gl_sets_of_books.set_of_books_id%TYPE;--updated by lyb
   -- l_coa_id       gl_sets_of_books.chart_of_accounts_id%TYPE;--updated by lyb
    l_flag         NUMBER;
    l_error_flag   VARCHAR2(1) := 'N';
    l_error_status BOOLEAN;

    l_dbg_level  NUMBER := FND_LOG.G_Current_Runtime_Level;
    l_proc_level NUMBER := FND_LOG.Level_Procedure;
    l_proc_name  VARCHAR2(100) := 'Cfsse_Calculate';

  BEGIN
    --log for debug
    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.STRING(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.begin',
                     'Enter procedure');

      FND_LOG.STRING(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_legal_entity_id ' || p_legal_entity_id);
      FND_LOG.STRING(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_period_name ' || p_period_name);

      FND_LOG.STRING(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_axis_set_id ' || p_axis_set_id);

      FND_LOG.STRING(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_rounding_option ' || p_rounding_option);

      FND_LOG.STRING(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_balance_type ' || p_balance_type);

/*      FND_LOG.STRING(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'p_internal_trx_flag ' || p_internal_trx_flag) ;*/
    END IF; --(l_proc_level >= l_dbg_level)

    IF JA_CN_UTILITY.Check_Profile
    THEN

      --To get gl set of book and chart of account for current legal entity
/*      JA_CN_UTILITY.Get_SOB_And_COA(p_legal_entity_id => p_legal_entity_id,
                                    x_sob_id          => l_sob_id,
                                    x_coa_id          => l_coa_id,
                                    x_flag            => l_flag);
      IF l_flag = 0
      THEN*/

        FND_FILE.Put_Line(FND_FILE.LOG,
                          'Submit actual CFS SE Calculation Concurrent.');

        FND_FILE.Put_Line(FND_FILE.LOG,
                          'Start');

        JA_CN_CFSSE_CALCULATE_PKG.Generate_Cfs_Xml(p_legal_entity_id
                                                  ,p_ledger_id
                                                  ,p_period_name
                                                  ,p_axis_set_id
                                                  ,p_rounding_option
                                                  ,p_balance_type
                                                 -- ,p_internal_trx_flag IN VARCHAR2
                                                  ,p_coa
                                                  ,p_segment_override => p_segment_override); -- Added for CNAO Enhancement

        FND_FILE.Put_Line(FND_FILE.LOG,
                          'Complete');
/*      ELSE
        l_error_flag := 'Y';
        --output error message
        FND_MESSAGE.Set_Name('JA',
                             'JA_CN_MISSING_BOOK_INFO');
        FND_FILE.Put_Line(FND_FILE.Output,
                          FND_MESSAGE.Get);
      END IF; --l_flag=0*/
    ELSE
      l_error_flag := 'Y';
    END IF; --JA_CN_UTILITY.Check_Profile

    --If above check failed, then set status of concurrent program as warning

    IF l_error_flag = 'Y'
    THEN
      l_error_status := FND_CONCURRENT.Set_Completion_Status(status  => 'WARNING',
                                                             message => '');

    END IF; --l_error_flag = 'Y'

    --log for debug
    IF (l_proc_level >= l_dbg_level)
    THEN
      FND_LOG.STRING(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.end',
                     'Exit procedure');
    END IF; --( l_proc_level >= l_dbg_level )

  EXCEPTION
    WHEN OTHERS THEN
      IF (l_proc_level >= l_dbg_level)
      THEN
        FND_LOG.STRING(l_proc_level,
                       l_module_prefix || '.' || l_proc_name ||
                       '. Other_Exception ',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)

  END Cfsse_Calculate;


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
  --      In:,P_COA_ID                NUMBER              ID of chart of account
  --      In: P_LE_ID                 NUMBER              ID of Legal Entity
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
  --===========================================================================
  PROCEDURE Collect_Cfs_Data(errbuf           OUT NOCOPY VARCHAR2,
                             retcode          OUT NOCOPY VARCHAR2,
                             P_COA_ID         IN NUMBER,
                             P_LE_ID          IN NUMBER,
                             p_LEDGER_ID      IN NUMBER,
                             P_GL_PERIOD_FROM IN VARCHAR2,
                             P_GL_PERIOD_TO   IN VARCHAR2,
                             P_SOURCE         IN VARCHAR2) IS
    l_dbg_level  NUMBER := FND_LOG.G_Current_Runtime_Level;
    l_proc_level NUMBER := FND_LOG.Level_Procedure;
    l_proc_name  VARCHAR2(100) := 'Collect_Cfs_Data';
    l_flag       VARCHAR2(15); --populate the ledger and the legal entity flag

    JA_CN_INVALID_GLPERIOD exception;
    l_msg_invalid_glperiod varchar2(2000); --'The from period and to period should be within one accounting year.';

    l_sob_coa_flag NUMBER;
    l_account_type_code FND_LOOKUP_VALUES.LOOKUP_CODE%TYPE;

    l_period_set_name GL_LEDGERS.period_set_name%TYPE;
    l_year_from       NUMBER;
    l_year_to         NUMBER;
  BEGIN
    --log for debug
    IF (l_proc_level >= l_dbg_level) THEN
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.begin',
                     'Enter procedure');
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_LE_ID ' || P_LE_ID);
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_GL_PERIOD_FROM ' || P_GL_PERIOD_FROM);
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_GL_PERIOD_TO ' || P_GL_PERIOD_TO);
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_SOURCE ' || P_SOURCE);
    END IF; --(l_proc_level >= l_dbg_level)

         --Check Profile
        IF NOT(JA_CN_UTILITY.Check_Profile)
        THEN
          retcode := 1;
          errbuf  := '';
          RETURN;
        END IF;
    l_flag := Ja_Cn_Utility.Populate_Ledger_Le_Bsv_Gt(p_LEDGER_ID,
                                                     P_LE_ID);

    IF l_flag = 'S' THEN

    --Get Period set name, Year_From and Year_To
    BEGIN
      SELECT LEDGER.PERIOD_SET_NAME, GP1.period_year, GP2.period_year
        INTO l_period_set_name, l_year_from, l_year_to
        FROM GL_LEDGERS LEDGER, gl_periods GP1, gl_periods GP2
       WHERE LEDGER.Ledger_Id = p_LEDGER_ID
         AND GP1.PERIOD_SET_NAME = LEDGER.PERIOD_SET_NAME
         AND GP1.period_name = P_GL_PERIOD_FROM
         AND GP2.PERIOD_SET_NAME = LEDGER.PERIOD_SET_NAME
         AND GP2.period_name = P_GL_PERIOD_TO;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
    END;

    IF l_year_from <> l_year_to THEN
      raise JA_CN_INVALID_GLPERIOD;
    ELSE
      JA_CN_CFS_DATA_CLT_PKG.Cfs_Data_Clt(P_COA_ID          => p_coa_id,
                                          P_LEDGER_ID       => p_ledger_id,
                                          P_LE_ID           => p_le_id,
                                          P_PERIOD_SET_NAME => l_period_set_name,
                                          P_GL_PERIOD_FROM  => p_gl_period_from,
                                          P_GL_PERIOD_TO    => p_gl_period_to,
                                          P_SOURCE          => p_source);
    END IF;

    --log for debug
    IF (l_proc_level >= l_dbg_level) THEN
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.end',
                     'Exit procedure');
    END IF; --(l_proc_level >= l_dbg_level)
  ELSE
     RETURN;
  END IF;
  EXCEPTION
    when JA_CN_INVALID_GLPERIOD then
      FND_MESSAGE.Set_Name(APPLICATION => 'JA',
                           NAME        => 'JA_CN_INVALID_GLPERIOD');
      l_msg_invalid_glperiod := FND_MESSAGE.Get;
      IF (l_proc_level >= l_dbg_level) THEN
        FND_LOG.String(l_proc_level,
                       l_module_prefix || '.' || l_proc_name ||
                       '.JA_CN_INVALID_GLPERIOD ',
                       l_msg_invalid_glperiod);
      END IF; --(l_proc_level >= l_dbg_level)
      retcode := 1;
      errbuf  := l_msg_invalid_glperiod;
    WHEN OTHERS THEN
      IF (l_proc_level >= l_dbg_level) THEN
        FND_LOG.String(l_proc_level,
                       l_module_prefix || '.' || l_proc_name ||
                       '.Other_Exception ',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)
      retcode := 2;
      errbuf  := SQLCODE || ':' || SQLERRM;

  END Collect_Cfs_Data;

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
                          P_COM_SEG      IN VARCHAR2) IS   --Added for CNAO Enhancement
    l_dbg_level  NUMBER := FND_LOG.G_Current_Runtime_Level;
    l_proc_level NUMBER := FND_LOG.Level_Procedure;
    l_proc_name  VARCHAR2(100) := 'GL_Validation';

  BEGIN
 --log for debug
    IF (l_proc_level >= l_dbg_level) THEN
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.begin',
                     'Enter procedure');
       FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_COA_ID ' || P_COA_ID);
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_LE_ID ' || P_LE_ID);
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_LEDGER_ID ' || P_LEDGER_ID);
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_START_PERIOD ' || P_START_PERIOD);
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_END_PERIOD ' || P_END_PERIOD);
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_SOURCE ' || P_SOURCE);
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_JOURNAL_CTG ' || P_JOURNAL_CTG);
      FND_LOG.String(l_proc_level,                                          --Added for CNAO Enhancement
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_COM_SEG ' || P_COM_SEG);
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_STATUS ' || P_STATUS);
    END IF; --(l_proc_level >= l_dbg_level)

    --Check Profile
    IF NOT(JA_CN_UTILITY.Check_Profile)
    THEN
      retcode := 1;
      errbuf  := '';
      RETURN;
    END IF;

    JA_CN_GL_INTER_VALID_PKG.GL_Validation(errbuf         => errbuf,
                                           retcode        => retcode,
                                           P_COA_ID       => P_COA_ID,
                                           P_LE_ID        => P_LE_ID,
                                           P_LEDGER_ID    => P_LEDGER_ID,
                                           P_START_PERIOD => P_START_PERIOD,
                                           P_END_PERIOD   => P_END_PERIOD,
                                           P_SOURCE       => P_SOURCE,
                                           P_JOURNAL_CTG  => P_JOURNAL_CTG,
                                           P_STATUS       => P_STATUS,
                                           P_COM_SEG      => P_COM_SEG);       --Added for CNAO Enhancement
   EXCEPTION
   WHEN OTHERS THEN
      IF (l_proc_level >= l_dbg_level) THEN
        FND_LOG.String(l_proc_level,
                       l_module_prefix || '.' || l_proc_name ||
                       '.Other_Exception ',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)
      retcode := 2;
      errbuf  := SQLCODE || ':' || SQLERRM;

  END GL_Validation;

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
                                    P_COM_SEG      IN VARCHAR2  --Added for CNAO Enhancement
                                    ) IS
   l_dbg_level  NUMBER := FND_LOG.G_Current_Runtime_Level;
    l_proc_level NUMBER := FND_LOG.Level_Procedure;
    l_proc_name  VARCHAR2(100) := 'GL_Validation';

  BEGIN
 --log for debug
    IF (l_proc_level >= l_dbg_level) THEN
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.begin',
                     'Enter procedure');
       FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_COA_ID ' || P_COA_ID);
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_LE_ID ' || P_LE_ID);
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_LEDGER_ID ' || P_LEDGER_ID);
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_START_PERIOD ' || P_START_PERIOD);
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_END_PERIOD ' || P_END_PERIOD);
      FND_LOG.String(l_proc_level,                                          --Added for CNAO Enhancement
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_COM_SEG ' || P_COM_SEG);
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_STATUS ' || P_STATUS);
    END IF; --(l_proc_level >= l_dbg_level)

    --Check Profile
    IF NOT(JA_CN_UTILITY.Check_Profile)
    THEN
      retcode := 1;
      errbuf  := '';
      RETURN;
    END IF;

    JA_CN_GL_INTER_VALID_PKG.Intercompany_Validation(errbuf         => errbuf,
                                                     retcode        => retcode,
                                                     P_COA_ID       => P_COA_ID,
                                                     P_LE_ID        => P_LE_ID,
                                                     P_LEDGER_ID    => P_LEDGER_ID,
                                                     P_START_PERIOD => P_START_PERIOD,
                                                     P_END_PERIOD   => P_END_PERIOD,
                                                     P_COM_SEG      => P_COM_SEG,      --Added for CNAO Enhancement
                                                     P_STATUS       => P_STATUS
                                                     );
 EXCEPTION
   WHEN OTHERS THEN
      IF (l_proc_level >= l_dbg_level) THEN
        FND_LOG.String(l_proc_level,
                       l_module_prefix || '.' || l_proc_name ||
                       '.Other_Exception ',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)
      retcode := 2;
      errbuf  := SQLCODE || ':' || SQLERRM;
 END Intercompany_Validation;

  --==========================================================================
  --  PROCEDURE NAME:
  --
  --  Item_Mapping_Analysis_Report                    Public
  --
  --  DESCRIPTION:
  --
  --    This procedure is used to export the records which item mapping form saved.
  --    It can help the audience know the cash flow of the company and do cash forecasting based on it
  --
  --
  --  PARAMETERS:
  --      Out:       errbuf                  Mandatory parameter for PL/SQL concurrent programs
  --      Out:       retcode                 Mandatory parameter for PL/SQL concurrent programs
  --      In:      P_APLICATION_ID           Application ID
  --      In:    P_EVENT_CLASS_CODE          Event class code
  --      In:  P_SUPPORTING_REFERENCE_CODE   Supporting reference code
  --      In:   P_CHART_OF_ACCOUNTS_ID       Chart of Accounts ID

  --
  --  DESIGN REFERENCES:
  --
  --
  --  CHANGE HISTORY:
  --
  --      27-APR-2007     Joy Liu Created
  --
  --===========================================================================

  PROCEDURE Item_Mapping_Analysis_Report(errbuf                      OUT NOCOPY VARCHAR2,
                                         retcode                     OUT NOCOPY VARCHAR2,
                                         P_APLICATION_ID             IN Number,
                                         P_EVENT_CLASS_CODE          IN Varchar2,
                                         P_SUPPORTING_REFERENCE_CODE IN Varchar2,
                                         P_CHART_OF_ACCOUNTS_ID      IN NUMBER) IS
  BEGIN
    JA_CN_CFS_IMA_PKG.Item_Mapping_Analysis_Report(errbuf                      => errbuf,
                                                   retcode                     => retcode,
                                                   P_APLICATION_ID             => P_APLICATION_ID,
                                                   P_EVENT_CLASS_CODE          => P_EVENT_CLASS_CODE,
                                                   P_SUPPORTING_REFERENCE_CODE => P_SUPPORTING_REFERENCE_CODE,
                                                   P_CHART_OF_ACCOUNTS_ID      => P_CHART_OF_ACCOUNTS_ID);
  END Item_Mapping_Analysis_Report;

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
  --      In: P_LE_ID            ID of Legal Entity
  --      In: P_ledger_ID        ID of ledger
  --      In: P_coa_ID           Identifier of gl chart of account
  --      In: P_ADHOC_PREFIX     Ad hoc prefix for FSG report, a required
  --                             parameter for FSG report
  --      In: P_INDUSTRY         Industry with constant value 'C' for
  --                             now, a required parameter for FSG report
  --      In: P_ID_FLEX_CODE     ID flex code, a required parameter for
  --                             FSG report
  --      In: P_REPORT_ID        Identifier of FSG report
  --      In: P_GL_PERIOD_FROM   Start period
  --      In: P_GL_PERIOD_TO     End period
  --      In: P_SOURCE           Source of the collection
  --      In: P_INTERNAL_TRX     To indicate if intercompany transactions
  --                             should be involved in amount calculation
  --                             of cash flow statement.
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      04/28/2007     Qingjun Zhao         Change
  --      08/09/2008     Yao Zhang            Fix Bug#7334017 for R12 enhancment
  --===========================================================================

  PROCEDURE Cfs_Detail_Report(errbuf                 OUT NOCOPY VARCHAR2,
                              retcode                OUT NOCOPY VARCHAR2,
                              P_LEGAL_ENTITY_ID      IN NUMBER,
                              P_ledger_ID            IN NUMBER,
                              P_chart_of_accounts_ID IN NUMBER,
                              P_ADHOC_PREFIX         IN VARCHAR2,
                              P_INDUSTRY             IN VARCHAR2,
                              P_ID_FLEX_CODE         IN VARCHAR2,
                              P_REPORT_ID            IN NUMBER,
                              P_ROW_SET_ID           IN NUMBER,
                              P_ROW_NAME             IN VARCHAR2,
                              P_GL_PERIOD_FROM       IN VARCHAR2,
                              P_GL_PERIOD_TO         IN VARCHAR2,
                              P_SOURCE               IN VARCHAR2,
                              P_BSV                  IN VARCHAR2) is--Fix Bug#7334017 add

    l_error_status BOOLEAN;
    l_dbg_level    NUMBER := FND_LOG.G_Current_Runtime_Level;
    l_proc_level   NUMBER := FND_LOG.Level_Procedure;
    l_proc_name    VARCHAR2(100) := 'Cfs_Detail_Report';
  begin
    --log for debug
    IF (l_proc_level >= l_dbg_level) THEN
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.begin',
                     'Enter procedure');
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_LEGAL_ENTITY_ID ' || P_LEGAL_ENTITY_ID);
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_LEDGER_ID ' || P_LEDGER_ID);
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_chart_of_accounts_ID ' || P_chart_of_accounts_ID);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_ADHOC_PREFIX ' || p_adhoc_prefix);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_INDUSTRY ' || p_industry);

      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_ID_FLEX_CODE ' || p_id_flex_code);
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_GL_PERIOD_FROM ' || P_GL_PERIOD_FROM);
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_GL_PERIOD_TO' || P_GL_PERIOD_TO);
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_SOURCE ' || P_SOURCE);
      FND_LOG.String(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.parameters',
                     'P_REPORT_ID ' || P_REPORT_ID);

    END IF; --(l_proc_level >= l_dbg_level)

    --Call the functon JA_CN_CFS_UTILITY.Check_Profile to check if all required profiles has been
    -- properly set for current responsibility. If No, the function will raise corresponding error
    --messages, and the concurrent program will not continue performing next logics,these required
    --profiles include ' JG: Product', which should be set to 'Asia/Pacific Localizations',
    --'JG: Territory', which should be set to 'China' and 'JA: CNAO Legal Entity', which should be
    --NOT NULL
    IF JA_CN_UTILITY.Check_Profile THEN
      JA_CN_CFS_REPORT_PKG.Cfs_Detail_Report(errbuf                 => errbuf,
                                             retcode                => retcode,
                                             P_LEGAL_ENTITY_ID      => P_LEGAL_ENTITY_ID,
                                             P_ledger_ID            => p_ledger_id,
                                             P_Chart_of_accounts_ID => p_chart_of_accounts_id,
                                             P_ADHOC_PREFIX         => P_ADHOC_PREFIX,
                                             P_INDUSTRY             => P_INDUSTRY,
                                             P_ID_FLEX_CODE         => P_ID_FLEX_CODE,
                                             P_REPORT_ID            => p_report_id,
                                             P_ROW_SET_ID           => p_row_set_id,
                                             P_ROW_NAME             => p_row_name,
                                             P_GL_PERIOD_FROM       => p_gl_period_from,
                                             P_GL_PERIOD_TO         => p_gl_period_to,
                                             P_SOURCE               => p_source,
                                             P_BSV                  => p_bsv);--Fix Bug#7334017 add
    ELSE
      --If above check failed, then set status of concurrent program as warning
      l_error_status := FND_CONCURRENT.Set_Completion_Status(status  => 'WARNING',
                                                             message => '');
    END IF; --JA_CN_UTILITY.Check_Profile

    --log for debug
    IF (l_proc_level >= l_dbg_level) THEN
      FND_LOG.STRING(l_proc_level,
                     l_module_prefix || '.' || l_proc_name || '.end',
                     'Exit procedure');
    END IF; --( l_proc_level >= l_dbg_level )

  EXCEPTION
    WHEN OTHERS THEN
      IF (l_proc_level >= l_dbg_level) THEN
        FND_LOG.String(l_proc_level,
                       l_module_prefix || '.' || l_proc_name ||
                       '. Other_Exception ',
                       SQLCODE || ':' || SQLERRM);
      END IF; --(l_proc_level >= l_dbg_level)

  end Cfs_Detail_Report;

END JA_CN_CFS_CONC_PROG;


/
