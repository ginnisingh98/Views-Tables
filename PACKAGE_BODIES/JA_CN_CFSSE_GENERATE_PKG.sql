--------------------------------------------------------
--  DDL for Package Body JA_CN_CFSSE_GENERATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_CN_CFSSE_GENERATE_PKG" AS
  --$Header: JACNCSEB.pls 120.2.12010000.2 2008/10/28 06:31:50 shyan ship $
  --+=======================================================================+
  --|               Copyright (c) 2006 Oracle Corporation                   |
  --|                       Redwood Shores, CA, USA                         |
  --|                         All rights reserved.                          |
  --+=======================================================================+
  --| FILENAME                                                              |
  --|     JACNCSEB.pls                                                      |
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
  --|      14/10/2008  Chaoqun Wu  Fix Bug# 7481444                         |
  --+======================================================================*/

  --==== Golbal Variables ============
  g_module_name VARCHAR2(30) := 'JA_CN_CFSSE_GENERATE_PKG';
  g_dbg_level   NUMBER := FND_LOG.G_Current_Runtime_Level;
  g_proc_level  NUMBER := FND_LOG.Level_Procedure;
  g_stmt_level  NUMBER := FND_LOG.Level_Statement;

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
  --          p_axis_set_id                    FSG report row Set ID
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
  --      03/22/2006      Jackey Li          Created
  --      2006-06-26  Jackey Li   add seven parameters
  --      14/10/2008      Chaoqun Wu        Fix bug# 7481444
  --===========================================================================
  PROCEDURE Submit_Requests(p_legal_entity_id         IN         NUMBER
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
                          ) IS

    l_procedure_name VARCHAR2(30) := 'Submit_Requests';
    --Request id for 'Program - Run Financial Statement Generator'
    l_reqid_fsg NUMBER;
    --Request id for 'Cash flow statement for small enterprise - Calculation'
    l_reqid_cal NUMBER;
    --Request id for the FSG - CFS report that automatically submitted by
    --'Program - Run Financial Statement Generator'
    l_reqid_fsg_cfs NUMBER;

    l_fsg_req_phase      fnd_lookup_values.lookup_code%TYPE;
    l_fsg_req_status     fnd_lookup_values.lookup_code%TYPE;
    l_fsg_req_phase_cfs  fnd_lookup_values.lookup_code%TYPE;
    l_fsg_req_status_cfs fnd_lookup_values.lookup_code%TYPE;
    l_cal_req_phase      fnd_lookup_values.lookup_code%TYPE;
    l_cal_req_status     fnd_lookup_values.lookup_code%TYPE;

    -- Request id for the 'Cash flow statement for small enterprise - Combination'
    l_reqid_combination NUMBER;
    -- Request id for the 'XML report publisher'
    l_reqid_xmlpublisher NUMBER;

    l_combination_req_phase  fnd_lookup_values.lookup_code%TYPE;
    l_combination_req_status fnd_lookup_values.lookup_code%TYPE;

    l_user_phase  fnd_lookup_values.meaning%TYPE;
    l_user_status fnd_lookup_values.meaning%TYPE;

    l_reqid_cvt      NUMBER;
    l_cvt_req_status VARCHAR2(100);

    l_reqid_chg      NUMBER;
    l_chg_req_status VARCHAR2(100);

    l_error_flag BOOLEAN;
    l_error_msg  VARCHAR2(1000) := NULL;
    l_err_code   VARCHAR2(1) := 'N';
    l_exc_cp EXCEPTION;
    l_xml_layout              BOOLEAN;

    l_legal_entity_name hr_all_organization_units_tl.NAME%TYPE;
    l_currency_code     fnd_currencies.currency_code%TYPE;

    L_COMPANY_NAME varchar2(100);

    --Cursor to get request_id for CFS FSG xml output
    CURSOR c_reqid_fsg_cfs IS
      SELECT request_id
        FROM fnd_concurrent_requests
       WHERE parent_request_id = l_reqid_fsg;

    --Cursor to get functional currency code of current set of book
    --this cursor is updated by lyb.
    CURSOR c_func_currency_code
    IS
    SELECT
      currency_code
    FROM
      gl_ledgers
    WHERE
      ledger_id=p_ledger_id;

    --Cursor to get legal entity name
    CURSOR c_legal_entity IS
      SELECT hou.NAME
        FROM hr_organization_units hou
       WHERE hou.organization_id = p_legal_entity_id;

       CURSOR C_COMPANY_NAME
        IS
        SELECT COMPANY_NAME
        FROM JA_CN_SYSTEM_PARAMETERS_ALL
        WHERE LEGAL_ENTITY_ID= p_legal_entity_id;

  BEGIN
    --log for debug
    IF (g_proc_level >= g_dbg_level)
    THEN
      FND_LOG.STRING(g_proc_level,
                     g_module_name || '.' || l_procedure_name || '.begin',
                     'begin procedure');
    END IF; --( g_proc_level >= g_dbg_level)

    --FND_FILE.Put_Line(FND_FILE.LOG,
    --                  'Submit Financial Statement Generator');

    --To get functional currency code of current set of book
    OPEN c_func_currency_code;
    FETCH c_func_currency_code
      INTO l_currency_code;
    CLOSE c_func_currency_code;

    --To get name for current legal entity
    OPEN c_legal_entity;
    FETCH c_legal_entity
      INTO l_legal_entity_name;
    CLOSE c_legal_entity;

  OPEN C_COMPANY_NAME;
  FETCH C_COMPANY_NAME INTO L_COMPANY_NAME;
  CLOSE C_COMPANY_NAME;

    --Submit the first concurrent program 'Program - Run Financial Statement Generator',which
    --will automatically submit another request for the CFS report to generate XML file
    l_reqid_fsg:=FND_REQUEST.Submit_Request( 'SQLGL'
                                         ,'RGRARG'
                                         ,''
                                         ,''
                                         ,FALSE
                                         ,P_DATA_ACCESS_SET_ID
                                         ,p_coa_id
                                         ,p_adhoc_prefix
                                         ,p_industry
                                         ,p_id_flex_code
                                         ,p_ledger_name
                                         ,p_report_id
                                         ,p_axis_set_id
                                         ,p_colset_id
                                         ,p_period_name
                                         ,p_currency_code
                                         ,p_rounding_option
                                         ,p_segment_override
                                         ,p_content_set_id
                                         ,P_ROW_ORDER_ID
                                         ,P_REPORT_DISPLAY_SET_ID
                                         ,p_OUTPUT_OPTION
                                         ,p_EXCEPTIONS_FLAG
                                         ,p_MINIMUM_DISPLAY_LEVEL
                                         ,p_ACCOUNTING_DATE
                                         ,p_parameter_set_id
                                         ,P_PAGE_LENGTH
                                         ,p_SUBREQUEST_ID
                                         ,P_APPL_NAME
                                         ,L_COMPANY_NAME,
                                 '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', '',
                                 '', '', '', '', '', '', '', '', '', ''
                                         );

     IF (p_OUTPUT_OPTION = 'Y') THEN
            UPDATE 	FND_CONCURRENT_REQUESTS
            SET
              OUTPUT_FILE_TYPE = 'XML'
            WHERE
              REQUEST_ID = l_reqid_fsg;
    END IF;
    COMMIT;

    --log for debug
    IF (g_stmt_level >= g_dbg_level)
    THEN
      FND_LOG.STRING(g_stmt_level,
                     g_module_name || '.' || l_procedure_name ||
                     '.submit FSG',
                     'the FSG CP id is ' || l_reqid_fsg);
    END IF; --( g_stmt_level >= g_dbg_level)

    --Waiting for the 'Program - Run Financial Statement Generator' completed,
    -- and then retrive the sub-request id
    -- from the table 'fnd_concurrent_requests' for the FSG - CFS report.
    IF l_reqid_fsg <> 0
    THEN
      IF FND_CONCURRENT.Wait_For_Request(request_id => l_reqid_fsg,
                                         INTERVAL   => 5,
                                         phase      => l_user_phase,
                                         status     => l_user_status,
                                         dev_phase  => l_fsg_req_phase,
                                         dev_status => l_fsg_req_status,
                                         message    => l_error_msg)
      THEN
        --FND_FILE.Put_Line(FND_FILE.LOG,
        --                  'FSG CP status is ' || l_fsg_req_status);

        --IF  status is 'NORMAL'
        IF l_fsg_req_status = 'NORMAL'
        THEN

          --log for debug
          IF (g_stmt_level >= g_dbg_level)
          THEN
            FND_LOG.STRING(g_stmt_level,
                           g_module_name || '.' || l_procedure_name ||
                           '.submit FSG-CFS',
                           'the FSG-CFS CP id is ' || l_reqid_fsg_cfs);
          END IF; --( g_stmt_level >= g_dbg_level)

        ELSIF l_fsg_req_status = 'WARNING'
        THEN
          l_err_code := 'W';
        ELSE
          l_err_code := 'E';
        END IF; --l_fsg_req_phase='Completed'
      END IF; -- FND_CONCURRENT.Wait_For_Request

    END IF; --l_reqid_fsg<>0

    --if FSG xml output request for cfs is completed, then submit
    -- the 'Cash flow statement for small enterprise- Calculation' program
    IF nvl(l_reqid_fsg,
           0) <> 0
       AND l_err_code = 'N'
    THEN

      --Waiting for the concurrent program completed
  /*    IF FND_CONCURRENT.Wait_For_Request(request_id => l_reqid_fsg_cfs,
                                         INTERVAL   => 5,
                                         phase      => l_user_phase,
                                         status     => l_user_status,
                                         dev_phase  => l_fsg_req_phase_cfs,
                                         dev_status => l_fsg_req_status_cfs,
                                         message    => l_error_msg)
      THEN*/
        --IF  status is 'NORMAL'
      --  IF l_fsg_req_status_cfs = 'NORMAL'
      --  THEN
          --FND_FILE.Put_Line(FND_FILE.LOG,
          --                  'Submit Cash flow statement for small enterprise - Calculation');

          --Submit the second concurrent program
          -- 'Cash flow statement for small enterprise - Calculation'
          l_reqid_cal := FND_REQUEST.Submit_Request(application  => 'JA'
                                                   --,program      => 'JACNCFSN'
                                                   ,program      => 'JACNCCEC' --Fix bug# 7481444
                                                   ,argument1    => p_legal_entity_id
                                                   ,argument2    => p_ledger_id
                                                   ,argument3    => p_period_name
                                                   ,argument4    => p_axis_set_id
                                                   ,argument5    => p_rounding_option
                                                   ,argument6    => p_balance_type
                                                  -- ,argument7    => p_internal_trx_flag
                                                   ,argument7    => p_coa_id
                                                   ,argument8    => p_segment_override --Added for CNAO Enhancement
                                                   );



          COMMIT;
          --Waiting for the 'Cash flow statement for small enterprise - Calculation' completed and then submit
          --'Cash Flow Statement for small enterprise - Combination' program

          --log for debug
          IF (g_stmt_level >= g_dbg_level)
          THEN
            FND_LOG.STRING(g_stmt_level,
                           g_module_name || '.' || l_procedure_name ||
                           '.submit CFS for small enterprise - Calculation',
                           'CFS for small enterprise - Calculation CP id is ' ||
                           l_reqid_cal);
          END IF; --( g_stmt_level >= g_dbg_level)

          IF l_reqid_cal <> 0
          THEN

            IF FND_CONCURRENT.Wait_For_Request(request_id => l_reqid_cal,
                                               INTERVAL   => 5,
                                               phase      => l_user_phase,
                                               status     => l_user_status,
                                               dev_phase  => l_cal_req_phase,
                                               dev_status => l_cal_req_status,
                                               message    => l_error_msg)
            THEN
              --IF  status is 'NORMAL'
              IF l_cal_req_status = 'NORMAL'
              THEN
                --FND_FILE.Put_Line(FND_FILE.LOG,
                --                  'Submit Cash flow statement for SE - Combination');

                --Submit the third concurrent program 'Cash flow statement for SE - Combination'
                --As output of Cash flow statement - Combination' is in XML format and
                --need to associate with XML publisher template automatically,
                --it is required to set layout before submit the program, bug 5168016

                l_xml_layout := FND_REQUEST.Add_Layout(template_appl_name => 'JA',
                                                       template_code      => 'JACNCFSS',
                                                       template_language  => p_xml_template_language, --'zh' ('en')
                                                       template_territory => p_xml_template_territory, --'00' ('US')
                                                       output_format      => p_xml_output_format --'ETEXT' (
                                                       );

                l_reqid_combination := FND_REQUEST.Submit_Request(application => 'JA',
                                                                  program     => 'JACNCFSS',
                                                                  argument1   => l_reqid_fsg,
                                                                  argument2   => l_reqid_cal);
                COMMIT;

                --log for debug
                IF (g_stmt_level >= g_dbg_level)
                THEN
                  FND_LOG.STRING(g_stmt_level,
                                 g_module_name || '.' || l_procedure_name ||
                                 '.submit CFS for small enterprise - Combination',
                                 'CFS for small enterprise - Combination CP id is ' ||
                                 l_reqid_combination);
                END IF; --( g_stmt_level >= g_dbg_level)

                --Waiting for the 'Cash flow statement for small enterprise
                -- Combination' completed AND THEN submit THE 'XML Report Publisher'
                IF l_reqid_combination <> 0
                THEN

                  IF FND_CONCURRENT.Wait_For_Request(request_id => l_reqid_combination,
                                                     INTERVAL   => 5,
                                                     phase      => l_user_phase,
                                                     status     => l_user_status,
                                                     dev_phase  => l_combination_req_phase,
                                                     dev_status => l_combination_req_status,
                                                     message    => l_error_msg)
                  THEN
                    --IF  status is 'NORMAL'
                    IF l_combination_req_status = 'NORMAL'
                    THEN
                      --Submit characrter set conversion program
                      --to convert charaterset of output file
                      JA_CN_UTILITY.Submit_Charset_Conversion(p_xml_request_id      => l_reqid_combination,
                                                              p_source_charset      => p_source_charset,
                                                              p_destination_charset => p_destination_charset,
                                                              p_source_separator    => p_source_separator,
                                                              x_charset_request_id  => l_reqid_cvt,
                                                              x_result_flag         => l_cvt_req_status);
                      IF l_cvt_req_status = 'Success'
                      THEN
                        --Submit "Change File Name" concurrent program
                        --to change name of output file
                        JA_CN_UTILITY.Change_Output_Filename(p_xml_request_id       => l_reqid_combination,
                                                             p_destination_charset  => p_destination_charset,
                                                             p_destination_filename => p_destination_filename,
                                                             x_filename_request_id  => l_reqid_chg,
                                                             x_result_flag          => l_chg_req_status);
                        IF l_chg_req_status = 'Success'
                        THEN
                          NULL;
                        ELSIF l_chg_req_status = 'Warning'
                        THEN
                          l_err_code := 'W';
                        ELSIF l_chg_req_status = 'Error'
                        THEN
                          l_err_code := 'E';
                        END IF; --l_chg_req_status='Success'

                      ELSIF l_cvt_req_status = 'Warning'
                      THEN
                        l_err_code := 'W';
                      ELSIF l_cvt_req_status = 'Error'
                      THEN
                        l_err_code := 'E';
                      END IF; --l_cvt_req_status='Success'

                    ELSIF l_combination_req_status = 'WARNING'
                    THEN
                      l_err_code := 'W';
                    ELSE
                      l_err_code := 'E';
                    END IF; -- l_combination_req_phase='NORMAL'
                  END IF; --FND_CONCURRENT.Wait_For_Request(request_id   => l_reqid_combination

                END IF; --l_reqid_combination<>0

              ELSIF l_cal_req_status = 'WARNING'
              THEN
                l_err_code := 'W';
              ELSE
                l_err_code := 'E';
              END IF; --IF l_cal_req_status = 'NORMAL'
            END IF; --IF FND_CONCURRENT.Wait_For_Request(request_id => l_reqid_cal,

          END IF; --l_reqid_cal <> 0
/*
        ELSIF l_fsg_req_status_cfs = 'WARNING'
        THEN
          l_err_code := 'W';
        ELSE
          l_err_code := 'E';
        END IF; -- l_fsg_req_status_cfs = 'NORMAL'*/

 --     END IF; --FND_CONCURRENT.Wait_For_Request

    END IF; --nvl(l_reqid_fsg_cfs,0)<>0

    IF l_err_code = 'E'
    THEN
      --If any of above four concurrent porgrams is failed, set current generation
      --program to status 'error'
      l_error_flag := FND_CONCURRENT.Set_Completion_Status(status  => 'ERROR',
                                                           message => '');
    ELSIF l_err_code = 'W'
    THEN
      l_error_flag := FND_CONCURRENT.Set_Completion_Status(status  => 'WARNING',
                                                           message => '');
    END IF;

    --log for debug
    IF (g_proc_level >= g_dbg_level)
    THEN
      FND_LOG.STRING(g_proc_level,
                     g_module_name || '.' || l_procedure_name || '.end',
                     'end procedure');
    END IF; --( g_proc_level >= g_dbg_level)

  END Submit_Requests;

END JA_CN_CFSSE_GENERATE_PKG;


/
