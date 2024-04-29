--------------------------------------------------------
--  DDL for Package Body JA_CN_CFS_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_CN_CFS_INT_PKG" AS
--$Header: JACNINTB.pls 120.2 2007/12/03 04:20:35 qzhao noship $
  --+=======================================================================+
  --|               Copyright (c) 2006 Oracle Corporation                   |
  --|                       Redwood Shores, CA, USA                         |
  --|                         All rights reserved.                          |
  --+=======================================================================+
  --| FILENAME                                                              |
  --|     JACNINTB.pls                                                      |
  --|                                                                       |
  --| DESCRIPTION                                                           |
  --|     This package is used in Collecting CFS Data from SLA              |
  --|     in the CNAO Project.                                              |
  --|                                                                       |
  --| PROCEDURE LIST                                                        |
  --|      PROCEDURE Collect_SLA_Data                 PUBLIC                |
  --|      PROCEDURE put_line                         PRIVATE               |
  --|      PROCEDURE put_log                          PRIVATE               |
  --|      PROCEDURE insert_CFS_Data                  PRIVATE                |
  --|                                                                       |
  --| HISTORY                                                               |
  --|      05/09/2007  Shujuan Yan       Created                            |
  --+======================================================================*/
  --==========================================================================
  --  PROCEDURE NAME:
  --    Put_Line                     private
  --
  --  DESCRIPTION:
  --      This procedure write data to log file.
  --
  --  PARAMETERS:
  --      In: p_str         VARCHAR2
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      05/09/2007     Shujuan Yan         Created
  --===========================================================================
  PROCEDURE put_log(p_module IN VARCHAR2, p_message IN VARCHAR2) AS
  BEGIN
    IF (fnd_log.LEVEL_STATEMENT >= g_debug_devel) THEN
      fnd_log.STRING(LOG_LEVEL => fnd_log.LEVEL_STATEMENT,
                     MODULE    => p_module,
                     MESSAGE   => p_message);
    END IF;

  END put_log;
  --==========================================================================
  --  PROCEDURE NAME:
  --    Put_Line                     private
  --
  --  DESCRIPTION:
  --      This procedure write data to concurrent output file.
  --
  --  PARAMETERS:
  --      In: p_str         VARCHAR2
  --
  --  DESIGN REFERENCES:
  --      None
  --
  --  CHANGE HISTORY:
  --      05/09/2007     Shujuan Yan          Created
  --===========================================================================
  PROCEDURE put_line(p_str IN VARCHAR2) AS
  BEGIN
    FND_FILE.Put_Line(FND_FILE.Output, p_str);
  END put_line;

 --==========================================================================
  --  PROCEDURE NAME:
  --    insert_sla_data                     Public
  --
  --  DESCRIPTION:
  --        This procedure is used to insert the record into
  --        ja_cn_cfs_activities_all from ja_cn_cfs_activities_interface
  --
  --  PARAMETERS:
  --      In: p_coa_id                     Chart of Accounts id
  --          p_ledger_id                  Ledger ID
  --          p_le_id                      legal entity ID
  --
  --  DESIGN REFERENCES:
  --      CNAO_CFS_Data_interface_TD.doc
  --
  --  CHANGE HISTORY:
  --      04/09/2007     Shujuan Yan          Created
  --===========================================================================
  PROCEDURE insert_CFS_data(P_COA_ID               IN NUMBER,
                            P_LEDGER_ID            IN NUMBER,
                            P_LEGAL_ENTITY_ID      IN NUMBER
                            ) AS
   BEGIN

    INSERT INTO ja_cn_cfs_activities_all(CFS_ACTIVITY_ID,
                                          LEGAL_ENTITY_ID,
                                          LEDGER_ID,
                                          ORG_ID,
                                          TRX_ID,
                                          TRX_NUMBER,
                                          TRX_LINE_ID,
                                          SOURCE,
                                          TRANSACTION_TYPE,
                                          DOCUMENT_SEQUENCE_NUMBER,
                                          TRANSACTION_DATE,
                                          GL_DATE,
                                          PERIOD_NAME,
                                          FUNC_CURR_CODE,
                                          FUNC_AMOUNT,
                                          ORIGINAL_CURR_CODE,
                                          ORIGINAL_AMOUNT,
                                          CURRENCY_CONVERSION_RATE,
                                          CURRENCY_CONVERSION_TYPE,
                                          CURRENCY_CONVERSION_DATE,
                                          DESCRIPTION,
                                          DETAILED_CFS_ITEM,
                                          INTERCOMPANY_FLAG,
                                          REFERENCE_NUMBER,
                                          THIRD_PARTY_NAME,
                                          THIRD_PARTY_NUMBER,
                                          EVENT_CLASS_CODE,
                                          SOURCE_APPLICATION_ID,
                                          ANALYTICAL_CRITERION_CODE,
                                          SOURCE_VALUE,
                                          CASH_ITEM_DESC,
                                          UPGRADE_FLAG,
                                          LAST_UPDATE_DATE,
                                          LAST_UPDATED_BY,
                                          CREATION_DATE,
                                          CREATED_BY,
                                          LAST_UPDATE_LOGIN)
    SELECT ja_cn_cfs_activities_s.NEXTVAL,
           LEGAL_ENTITY_ID,
           LEDGER_ID,
           ORG_ID,
           TRX_ID,
           TRX_NUMBER,
           TRX_LINE_ID,
           SOURCE,
           TRANSACTION_TYPE,
           DOCUMENT_SEQUENCE_NUMBER,
           TRANSACTION_DATE,
           GL_DATE,
           PERIOD_NAME,
           FUNC_CURR_CODE,
           FUNC_AMOUNT,
           ORIGINAL_CURR_CODE,
           ORIGINAL_AMOUNT,
           CURRENCY_CONVERSION_RATE,
           CURRENCY_CONVERSION_TYPE,
           CURRENCY_CONVERSION_DATE,
           DESCRIPTION,
           DETAILED_CFS_ITEM,
           INTERCOMPANY_FLAG,
           REFERENCE_NUMBER,
           THIRD_PARTY_NAME,
           THIRD_PARTY_NUMBER,
           EVENT_CLASS_CODE,
           SOURCE_APPLICATION_ID,
           ANALYTICAL_CRITERION_CODE,
           SOURCE_VALUE,
           CASH_ITEM_DESC,
           'I',
           SYSDATE,
           fnd_global.user_id,
           SYSDATE,
           fnd_global.user_id,
           fnd_global.LOGIN_ID
     FROM ja_cn_cfs_activities_interface
     WHERE legal_entity_id = p_legal_entity_id
       AND ledger_id = p_ledger_id
       AND status = 'S';
 END;
  --==========================================================================
  --  PROCEDURE NAME:
  --    collect_sla_data                     Public
  --
  --  DESCRIPTION:
  --        This procedure is used to import the cash flow activity data from
  --        interface table inot CFS tables.
  --
  --  PARAMETERS:
  --      In: p_coa_id                     Chart of Accounts id
  --          p_ledger_id                  Ledger ID
  --          p_legal_entity_id                      legal entity ID
  --  DESIGN REFERENCES:
  --      CNAO_CFS_Data_interface_TD.doc
  --
  --  CHANGE HISTORY:
  --      04/09/2007     Shujuan Yan          Created
  --===========================================================================
  PROCEDURE import_CFS_data(ERRBUF            OUT NOCOPY VARCHAR2,
                            RETCODE           OUT NOCOPY VARCHAR2,
                            P_COA_ID          IN NUMBER,
                            P_LEDGER_ID       IN NUMBER,
                            P_legal_entity_ID IN NUMBER) AS
    l_procedure_name                 VARCHAR2(30) := 'import_CFS_data';
    l_rowid                          VARCHAR2(300);
    l_period_name                    ja_cn_cfs_activities_interface.period_name%TYPE;
    l_func_curr_code                 ja_cn_cfs_activities_interface.func_curr_code%TYPE;
    l_detailed_cfs_item              ja_cn_cfs_activities_interface.detailed_cfs_item%TYPE;
    l_flag                           VARCHAR2(1);
    l_number                         NUMBER;
    l_trx_number                     ja_cn_cfs_activities_interface.trx_number%TYPE;
    l_trx_date                       ja_cn_cfs_activities_interface.transaction_date%TYPE;
    l_msg                            varchar2(2000);

    CURSOR c_activities IS
    SELECT ROWID,
           period_name,
           func_curr_code,
           detailed_cfs_item,
           trx_number,
           transaction_date
      FROM ja_cn_cfs_activities_interface
     WHERE ledger_id = p_ledger_id
       AND legal_entity_id = p_legal_entity_id;

  BEGIN

   --Delete the data whose status is 'Error' and 'Success' in interface table
    DELETE FROM ja_cn_cfs_activities_interface
     WHERE ledger_id = p_ledger_id
       AND legal_entity_id = p_legal_entity_id
       AND (status = 'E' OR status = 'S');

    IF (G_PROC_LEVEL >= g_debug_devel) THEN
      FND_LOG.STRING(G_PROC_LEVEL,
                     G_MODULE_PREFIX || l_procedure_name || '.begin',
                     'Begin procedure');
    END IF; --( G_PROC_LEVEL >= g_debug_devel)

     OPEN c_activities;
     LOOP
     FETCH c_activities INTO
       l_rowid,
       l_period_name,
       l_func_curr_code,
       l_detailed_cfs_item,
       l_trx_number,
       l_trx_date;
     EXIT WHEN c_activities%NOTFOUND;

     l_flag := 'S';

     --Check functional currency code
     SELECT COUNT(*)
       INTO l_number
       FROM gl_ledgers
      WHERE ledger_id = P_LEDGER_ID
       AND  currency_code = l_func_curr_code;

      IF l_number <> 1 THEN
        l_flag := 'E';
        FND_MESSAGE.Set_Name('JA', 'JA_CN_INVALID_CURR');
        FND_MESSAGE.Set_Token('CURR',l_func_curr_code,true);
        FND_MESSAGE.Set_Token('TRX',l_trx_number,true);
        l_msg := FND_MESSAGE.Get;
        fnd_file.PUT_LINE(fnd_file.LOG, l_msg);
        RETCODE := 1;
      END IF;

      --Check period name
      SELECT COUNT(*)
        INTO l_number
        FROM Gl_Periods gp, gl_ledgers gl
       WHERE gl.ledger_id = p_ledger_id
         AND gl.period_set_name = gp.period_set_name
         AND gp.period_name = l_period_name;

       IF l_number <> 1 THEN
        l_flag := 'E';
        FND_MESSAGE.Set_Name('JA', 'JA_CN_INVALID_PERIOD');
        FND_MESSAGE.Set_Token('PERIOD',l_period_name,true);
        FND_MESSAGE.Set_Token('TRX',l_trx_number,true);
        l_msg := FND_MESSAGE.Get;
        fnd_file.PUT_LINE(fnd_file.LOG, l_msg);
        RETCODE := 1;
       END IF;

      --Check detailed CFS item
       SELECT COUNT(*)
         INTO l_number
         FROM Fnd_Flex_Values_Tl Ffvt,
              fnd_flex_values    Ffv,
              ja_cn_cash_valuesets_all Cra
        WHERE Cra.Chart_Of_Accounts_Id = P_COA_Id
          AND Ffv.Flex_Value_Set_Id = Cra.Flex_Value_Set_Id
          AND Ffv.Flex_Value_Id = Ffvt.Flex_Value_Id
          AND Ffv.Flex_Value = l_detailed_cfs_item
          AND ffvt.LANGUAGE = userenv('LANG');

        IF l_number <> 1 THEN
           l_flag := 'E';
        FND_MESSAGE.Set_Name('JA', 'JA_CN_INVALID_CASH_ITEM');
        FND_MESSAGE.Set_Token('ITEM',l_period_name,true);
        FND_MESSAGE.Set_Token('TRX',l_trx_number,true);
        l_msg := FND_MESSAGE.Get;
        fnd_file.PUT_LINE(fnd_file.LOG, l_msg);
        RETCODE := 1;
        END IF;

        IF l_flag = 'S' THEN
           UPDATE ja_cn_cfs_activities_interface
              SET  status = 'S'
             WHERE ROWID = l_rowid;
        END IF;

        IF l_flag = 'E' THEN
           UPDATE ja_cn_cfs_activities_interface
              SET  status = 'E'
             WHERE ROWID = l_rowid;
        END IF;
   END LOOP;
   CLOSE c_activities;
   COMMIT;

   --insert data into ja_cn_cfs_activities_all
   insert_CFS_data(P_COA_ID,
                   P_LEDGER_ID,
                   P_legal_entity_ID);

  IF(  G_PROC_LEVEL >= g_debug_devel )
  THEN
    FND_LOG.STRING(G_PROC_LEVEL
                  ,G_MODULE_PREFIX||l_procedure_name||'.end'
                  ,'End procedure');
  END IF;  --( G_PROC_LEVEL >= g_debug_devel)
EXCEPTION
  WHEN OTHERS THEN
    IF(FND_LOG.LEVEL_UNEXPECTED >= g_debug_devel)
    THEN
      FND_LOG.string( FND_LOG.LEVEL_UNEXPECTED
                    , G_MODULE_PREFIX || l_procedure_name||'.OTHER_EXCEPTION'
                    , SQLCODE||':'||SQLERRM||p_coa_id);
    END IF;
    RAISE;
  END import_CFS_data;

end JA_CN_CFS_INT_PKG;

/
