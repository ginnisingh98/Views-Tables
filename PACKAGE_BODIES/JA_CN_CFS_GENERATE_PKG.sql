--------------------------------------------------------
--  DDL for Package Body JA_CN_CFS_GENERATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_CN_CFS_GENERATE_PKG" AS
--$Header: JACNCGEB.pls 120.7.12010000.2 2008/10/28 06:24:39 shyan ship $
--+=======================================================================+
--|               Copyright (c) 2006 Oracle Corporation
--|                       Redwood Shores, CA, USA
--|                         All rights reserved.
--+=============a==========================================================
--| FILENAME
--|     JACNCGEB.pls
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
--|   1-Sep-2008      Chaoqun Wu Updated for CNAO Enhancement
--|
--+======================================================================*/

l_module_prefix   VARCHAR2(100):='JA_CN_CFS_GENERATE_PKG';

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
--
--  PARAMETERS:
--      In: p_legal_entity_id           Identifier of legal entity
--          p_ledger_id             Identifier of GL set of book, a required
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
--the parameter is updated by lyb,because the rg30rfsg program is changed.
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
)
IS
l_legal_entity_id         NUMBER(15)                              :=p_legal_entity_id;
l_legal_entity_name       hr_all_organization_units_tl.name%TYPE;
l_currency_code           fnd_currencies.currency_code%TYPE;
l_reqid_fsg               NUMBER;  --Request id for 'Program - Run Financial Statement Generator'
l_reqid_cal               NUMBER;  --Request id for 'Cash flow statement - Calculation'
l_reqid_fsg_cfs           NUMBER;  --Request id for the FSG - CFS report that automatically submitted by
                                 --'Program - Run Financial Statement Generator'
l_fsg_req_phase           fnd_lookup_values.meaning%TYPE;
l_fsg_req_status          fnd_lookup_values.meaning%TYPE;
l_fsg_req_status_code     fnd_lookup_values.lookup_code%TYPE;

l_fsg_req_phase_cfs       fnd_lookup_values.meaning%TYPE;
l_fsg_req_status_cfs      fnd_lookup_values.meaning%TYPE;
l_fsg_req_status_cfs_code fnd_lookup_values.lookup_code%TYPE;

l_cal_req_phase           fnd_lookup_values.meaning%TYPE;
l_cal_req_status          fnd_lookup_values.meaning%TYPE;
l_cal_req_status_code     fnd_lookup_values.lookup_code%TYPE;

l_reqid_comb              NUMBER;  -- Request id for the 'Cash flow statement - Combination'


l_comb_req_phase          fnd_lookup_values.meaning%TYPE;
l_comb_req_status         fnd_lookup_values.meaning%TYPE;
l_comb_req_status_code    fnd_lookup_values.lookup_code%TYPE;

l_error_flag              VARCHAR2(1);
l_error_status            BOOLEAN;

l_waiting_interval        NUMBER   :=10;
l_dev_phase               VARCHAR2(100);
l_dev_status              VARCHAR2(100);
l_message                 VARCHAR2(1000);
l_xml_layout              BOOLEAN;

l_reqid_cvt               NUMBER;
l_cvt_req_status          VARCHAR2(100);

l_reqid_chg               NUMBER;
l_chg_req_status          VARCHAR2(100);

L_COMPANY_NAME            VARCHAR2(100);



--Cursor to get request_id for CFS FSG xml output
CURSOR c_reqid_fsg_cfs
IS
SELECT
  request_id
FROM
  fnd_concurrent_requests
WHERE parent_request_id=l_reqid_fsg;

--Cursor to get functional currency code of current set of book
--this cursor is updated by lyb, get functional currency code from gl_ledgers
CURSOR c_func_currency_code
IS
SELECT
  currency_code
FROM
  gl_ledgers
WHERE
  ledger_id=p_ledger_id;

--Cursor to get legal entity name
CURSOR c_legal_entity
IS
SELECT
  name
FROM
  hr_legal_entities
WHERE organization_id=l_legal_entity_id;

CURSOR C_COMPANY_NAME
IS
SELECT COMPANY_NAME
INTO L_COMPANY_NAME
FROM JA_CN_SYSTEM_PARAMETERS_ALL
WHERE LEGAL_ENTITY_ID= l_legal_entity_id;


l_dbg_level           NUMBER            :=FND_LOG.G_Current_Runtime_Level;
l_proc_level          NUMBER            :=FND_LOG.Level_Procedure;
l_proc_name           VARCHAR2(100)     :='Submit_Requests';

BEGIN

--log for debug
  IF (l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.begin'
                  ,'Enter procedure'
                  );

    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_legal_entity_id '||p_legal_entity_id
                  );

    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_ledger_id '||p_ledger_id
                  );
    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_coa_id '||p_coa_id
                  );
    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_adhoc_prefix '||p_adhoc_prefix
                  );
    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_industry '||p_industry
                  );
    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_id_flex_code '||p_id_flex_code
                  );
    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_report_id '||p_report_id
                  );
    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_period_name '||p_period_name
                  );
    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_axis_set_id '||p_axis_set_id
                  );
    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_colset_id '||p_colset_id
                  );

    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_rounding_option '||p_rounding_option
                  );
    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_segment_override '||p_segment_override
                  );
    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_accounting_date '||p_accounting_date
                  );
    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_parameter_set_id '||p_parameter_set_id
                  );

    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'P_PAGE_LENGTH '||P_PAGE_LENGTH
                  );
    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_balance_type '||p_balance_type
                  );
    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_xml_template_language  '||p_xml_template_language
                  );
    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_xml_template_territory  '||p_xml_template_territory
                  );
    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_xml_output_format  '||p_xml_output_format
                  );
   FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_source_charset '||p_source_charset
                  );

    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_destination_charset '||p_destination_charset
                  );

    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_source_separator '||p_source_separator
                  );

    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.parameters'
                  ,'p_destination_filename '||p_destination_filename
                  );
  END IF;  --(l_proc_level >= l_dbg_level)
  l_error_flag:='N';

  --To get functional currency code of current set of book
  OPEN  c_func_currency_code;
  FETCH c_func_currency_code INTO l_currency_code;
  CLOSE c_func_currency_code;

  --To get name for current legal entity
  OPEN c_legal_entity;
  FETCH c_legal_entity INTO l_legal_entity_name;
  CLOSE c_legal_entity;

  OPEN C_COMPANY_NAME;
  FETCH C_COMPANY_NAME INTO L_COMPANY_NAME;
  CLOSE C_COMPANY_NAME;

  --Submit the first concurrent program 'Cash Flow Statement - FSG',which
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

  --Waiting for the 'Cash Flow Statement - FSG' completed, and then retrive the sub-request id
  --from the table 'fnd_concurrent_requests' for the FSG - CFS report.
  IF l_reqid_fsg<>0
  THEN


    IF FND_CONCURRENT.Wait_For_Request(request_id   => l_reqid_fsg
                                      ,interval     => l_waiting_interval
                                      ,phase        => l_fsg_req_phase
                                      ,status       => l_fsg_req_status
                                      ,dev_phase    => l_dev_phase
                                      ,dev_status   => l_dev_status
                                      ,message      => l_message
                                      )
    THEN

      --To get lookup code for current status
      SELECT
        lookup_code
      INTO
        l_fsg_req_status_code
      FROM
        fnd_lookup_values
      WHERE lookup_type = 'CP_STATUS_CODE'
        AND view_application_id=0
        AND security_group_id=0
        AND meaning=l_fsg_req_status
        AND enabled_flag='Y'
        AND language = USERENV('LANG');

      --To judge if the Program - Run Financial Statement Generator' has been
      --completed successfully.

      --Completed with 'Normal'
      IF l_fsg_req_status_code='C'
      THEN
       null;
      --Completed with 'Warning'
      ELSIF l_fsg_req_status_code='G'
      THEN
        l_error_flag:='W';
      --Completed with 'Error'
      ELSIF l_fsg_req_status_code='E'
      THEN
        l_error_flag:='E';
      END IF; --l_fsg_req_status_code='C'
    END IF;   -- FND_CONCURRENT.Wait_For_Request  ...
  ELSE
    l_error_flag:='E';
  END IF; --l_reqid_fsg<>0

  --if FSG xml output request for cfs is successfully completed, then submit the 'Cash flow statement- Calculation'
  --program


  IF nvl(l_reqid_fsg,0)<>0 AND l_error_flag='N'
  THEN
        --Submit the second concurrent program 'Cash flow statement - Calculation'
        --this parameter is changed by lyb, add p_coa_id and delete p_internal_trx_flag
        l_reqid_cal:=FND_REQUEST.Submit_Request(application  => 'JA'
                                               ,program      => 'JACNCFSN'
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
        --Waiting for the 'Cash flow statement - Calculation' successfully completed and then submit
        --'Cash Flow Statement - Combination' program
        IF l_reqid_cal<>0
        THEN
          IF FND_CONCURRENT.Wait_For_Request(request_id   => l_reqid_cal
                                            ,interval     => l_waiting_interval
                                            ,phase        => l_cal_req_phase
                                            ,status       => l_cal_req_status
                                            ,dev_phase    => l_dev_phase
                                            ,dev_status   => l_dev_status
                                            ,message      => l_message
                                            )
          THEN



            --Submit the third concurrent program 'Cash flow statement - Combination' after the
            --'Cash flow statement - Calculation' succesfully

            --To get lookup code for current status
            SELECT
              lookup_code
            INTO
              l_cal_req_status_code
            FROM
              fnd_lookup_values
            WHERE lookup_type = 'CP_STATUS_CODE'
              AND view_application_id=0
              AND security_group_id=0
              AND meaning=l_cal_req_status
              AND enabled_flag='Y'
              AND language = USERENV('LANG');

            --Completed with successful
            IF l_cal_req_status_code='C'
            THEN
              --Submit the third concurrent program 'Cash flow statement - Combination'

              --As output of Cash flow statement - Combination' is in XML format and
              --need to associate with XML publisher template automatically,
              --it is required to set layout before submit the program, bug 5168016

               l_xml_layout := FND_REQUEST.Add_Layout(template_appl_name  => 'JA'
                                                     ,template_code       => 'JACNCFSC'
                                                     ,template_language   => p_xml_template_language --'zh' ('en')
                                                     ,template_territory  => p_xml_template_territory--'00' ('US')
                                                     ,output_format       => p_xml_output_format --'ETEXT' (
                                            );


              l_reqid_comb:=FND_REQUEST.Submit_Request(application => 'JA'
                                                      ,program     => 'JACNCFSC'
                                                      ,argument1   => l_reqid_fsg
                                                      ,argument2   => l_reqid_cal
                                                      );
              COMMIT;
              --Waiting for the 'Cash flow statement - Combination' completed
              --get its status

              IF l_reqid_comb<>0
              THEN

                IF FND_CONCURRENT.Wait_For_Request(request_id   => l_reqid_comb
                                                  ,interval     => l_waiting_interval
                                                  ,phase        => l_comb_req_phase
                                                  ,status       => l_comb_req_status
                                                  ,dev_phase    => l_dev_phase
                                                  ,dev_status   => l_dev_status
                                                  ,message      => l_message
                                                  )
                THEN

                  --To get lookup code for current status
                  SELECT
                    lookup_code
                  INTO
                    l_comb_req_status_code
                  FROM
                    fnd_lookup_values
                  WHERE lookup_type = 'CP_STATUS_CODE'
                    AND view_application_id=0
                    AND security_group_id=0
                    AND meaning=l_comb_req_status
                    AND enabled_flag='Y'
                    AND language = USERENV('LANG');

                  --Completed with Normal
                  IF l_comb_req_status_code='C'
                  THEN
                    --Submit characrter set conversion program
                    --to convert charaterset of output file
                    JA_CN_UTILITY.Submit_Charset_Conversion(p_xml_request_id      => l_reqid_comb
                                                           ,p_source_charset      => p_source_charset
                                                           ,p_destination_charset => p_destination_charset
                                                           ,p_source_separator    => p_source_separator
                                                           ,x_charset_request_id  => l_reqid_cvt
                                                           ,x_result_flag         => l_cvt_req_status
                                                           );
                    IF l_cvt_req_status='Success'
                    THEN
                      --Submit "Change File Name" concurrent program
                      --to change name of output file
                      JA_CN_UTILITY.Change_Output_Filename(p_xml_request_id       => l_reqid_comb
                                                          ,p_destination_charset  => p_destination_charset
                                                          ,p_destination_filename => p_destination_filename
                                                          ,x_filename_request_id  => l_reqid_chg
                                                          ,x_result_flag          => l_chg_req_status
                                                          );
                      IF l_chg_req_status='Success'
                      THEN
                        NULL;
                      ELSIF  l_chg_req_status='Warning'
                      THEN
                        l_error_flag:='W';
                      ELSIF  l_chg_req_status='Error'
                      THEN
                        l_error_flag:='E';
                      END IF;  --l_chg_req_status='Success'


                    ELSIF l_cvt_req_status='Warning'
                    THEN
                      l_error_flag:='W';
                    ELSIF l_cvt_req_status='Error'
                    THEN
                      l_error_flag:='E';
                    END IF; --l_cvt_req_status='Success'

                  --Completed with 'Warning'
                  ELSIF l_comb_req_status_code='G'
                  THEN
                    l_error_flag:='W';
                  --Completed with 'Error'
                  ELSIF l_comb_req_status_code='E'
                  THEN
                    l_error_flag:='E';
                  END IF; --l_comb_req_status_code='C'
                END IF; --FND_CONCURRENT.Wait_For_Request(request_id   => l_reqid_comb
              ELSE
                l_error_flag:='E';
              END IF; --l_reqid_comb<>0

            --Completed with 'Warning'
            ELSIF l_cal_req_status_code='G'
            THEN
              l_error_flag:='W';
            --Completed with 'Error'
            ELSIF l_cal_req_status_code='E'
            THEN
              l_error_flag:='E';
            END IF; --l_cal_req_status_code='C'

          END IF; --FND_CONCURRENT.Wait_For_Request(request_id   => l_reqid_cal

        ELSE
          l_error_flag:='E';
        END IF; --l_reqid_cal<>0

  END IF; --nvl(l_reqid_fsg_cfs,0)<>0 AND l_error_flag='N'





  --If any of above four concurrent porgrams is Warning/Failed, set current generation
  --program to status 'Warning'/'Error' accordingly.
  IF l_error_flag='W'
  THEN
    l_error_status:=FND_CONCURRENT.Set_Completion_Status(status => 'WARNING'
                                                        ,message => ''
                                                        );
  ELSIF l_error_flag='E'
  THEN
    l_error_status:=FND_CONCURRENT.Set_Completion_Status(status => 'ERROR'
                                                        ,message => ''
                                                        );
  END IF;  --l_error_flag='W'

  --log for debug
  IF ( l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.STRING(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name
                  ,l_error_flag
                  );
    FND_LOG.STRING(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'.end'
                  ,'Exit procedure'
                  );
  END IF;  --( l_proc_level >= l_dbg_level )

EXCEPTION
WHEN OTHERS THEN

  IF (l_proc_level >= l_dbg_level)
  THEN
    FND_LOG.STRING(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'EXCEPTION'
                  ,l_error_flag
                  );
    FND_LOG.String(l_proc_level
                  ,l_module_prefix||'.'||l_proc_name||'. Other_Exception '
                  ,SQLCODE||':'||SQLERRM
                  );
  END IF;  --(l_proc_level >= l_dbg_level)

END Submit_Requests;
END JA_CN_CFS_GENERATE_PKG;


/
