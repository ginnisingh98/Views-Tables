--------------------------------------------------------
--  DDL for Package Body JA_CN_UPDATE_JL_SEQ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_CN_UPDATE_JL_SEQ_PKG" AS
  --$Header: JACNVJSB.pls 120.1.12000000.1 2007/08/13 14:09:55 qzhao noship $
  --+=======================================================================+
  --|               Copyright (c) 2006 Oracle Corporation                   |
  --|                       Redwood Shores, CA, USA                         |
  --|                         All rights reserved.                          |
  --+=======================================================================+
  --| FILENAME                                                              |
  --|     JACNVJSB.pls                                                      |
  --|                                                                       |
  --| DESCRIPTION                                                           |
  --|     This package is used to fetch a sequence number                   |
  --|        for Journal Itemization program                                |
  --|                                                                       |
  --| PROCEDURE LIST                                                        |
  --|      FUNCTION  Fetch_JL_Seq                                           |
  --|      PROCEDURE Create_JL_Seq                                          |
  --|      PROCEDURE Update_JL_Seq                                          |
  --|                                                                       |
  --| HISTORY                                                               |
  --|      03/13/2006     Jackey Li          Created                        |
  --      04/28/2007     Qingjun Zhao       Add column Ledger_id to table   |
  --                                        ja_cn_journal_numbering         |
  --+======================================================================*/

  --==== Golbal Variables ============
  g_module_name VARCHAR2(30) := 'JA_CN_UPDATE_JL_SEQ_PKG';
  g_dbg_level   NUMBER := FND_LOG.G_Current_Runtime_Level;
  g_proc_level  NUMBER := FND_LOG.Level_Procedure;
  g_stmt_level  NUMBER := FND_LOG.Level_Statement;

  --==========================================================================
  --  PROCEDURE NAME:
  --    Create_JL_Seq                     Private
  --
  --  DESCRIPTION:
  --        This procedure is used to create a sequence number under the
  --           Legal Entity, ledger and Period Name with the initial value '2'
  --
  --  PARAMETERS:
  --      In: p_legal_entity_ID            legal entity ID
  --          p_period_name                period_name
  --
  --  DESIGN REFERENCES:
  --      CNAO_Update_Journal_Sequence_PKG_TD.doc
  --
  --  CHANGE HISTORY:
  --      03/13/2006     Jackey Li          Created
  --      04/28/2007     Qingjun Zhao       Add column Ledger_id to table
  --                                        ja_cn_journal_numbering
  --===========================================================================
  PROCEDURE Create_JL_Seq(p_legal_entity_ID IN NUMBER,
                          p_ledger_id       in number,
                          p_period_name     IN VARCHAR2) IS

    l_procedure_name VARCHAR2(30) := 'Create_JL_Seq';

  BEGIN
    --log for debug
    IF (g_proc_level >= g_dbg_level) THEN
      FND_LOG.STRING(g_proc_level,
                     g_module_name || '.' || l_procedure_name || '.begin',
                     'begin procedure');
    END IF; --( g_proc_level >= g_dbg_level)

    --insert 1 into JA_CN_JOURNAL_NUMBERING table
    INSERT INTO JA_CN_JOURNAL_NUMBERING
      (legal_entity_id,
       ledger_id,
       Period_Name,
       NEXT_NUMBER,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN)
    VALUES
      (p_legal_entity_ID,
       p_ledger_id,
       p_period_name,
       2,
       fnd_global.USER_ID,
       SYSDATE,
       fnd_global.USER_ID,
       SYSDATE,
       fnd_global.LOGIN_ID);

    --log for debug
    IF (g_proc_level >= g_dbg_level) THEN
      FND_LOG.STRING(g_proc_level,
                     g_module_name || '.' || l_procedure_name || '.end',
                     'end procedure');
    END IF; --( g_proc_level >= g_dbg_level)

  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= g_dbg_level) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_module_name || ',' || l_procedure_name ||
                       '.OTHER_EXCEPTION',
                       SQLCODE || ':' || SQLERRM);
      END IF;
      ROLLBACK;

  END Create_JL_Seq;

  --==========================================================================
  --  PROCEDURE NAME:
  --    Update_JL_Seq                     Private
  --
  --  DESCRIPTION:
  --        This procedure is used to update a sequence number under the
  --           Legal Entity, Ledger and Period Name with old number plus '1'
  --
  --  PARAMETERS:
  --      In: p_legal_entity_ID            legal entity ID
  --          p_ledger_id                  ledger ID
  --          p_period_name                period_name
  --          p_next_number                next number
  --
  --  DESIGN REFERENCES:
  --      CNAO_Update_Journal_Sequence_PKG_TD.doc
  --
  --  CHANGE HISTORY:
  --      03/13/2006     Jackey Li          Created
  --      04/28/2007     Qingjun Zhao       Add column Ledger_id to table
  --                                        ja_cn_journal_numbering
  --===========================================================================
  PROCEDURE Update_JL_Seq(p_legal_entity_ID IN NUMBER,
                          p_ledger_id       in number,
                          p_period_name     IN VARCHAR2,
                          p_next_number     IN NUMBER) IS

    l_procedure_name VARCHAR2(30) := 'Update_JL_Seq';

  BEGIN
    --log for debug
    IF (g_proc_level >= g_dbg_level) THEN
      FND_LOG.STRING(g_proc_level,
                     g_module_name || '.' || l_procedure_name || '.begin',
                     'begin procedure');
    END IF; --( g_proc_level >= g_dbg_level)

    -- update the JA_CN_JOURNAL_NUMBERING table with new next_number
    UPDATE JA_CN_JOURNAL_NUMBERING jcjn
       SET jcjn.next_number       = p_next_number,
           jcjn.last_updated_by   = fnd_global.USER_ID,
           jcjn.last_update_date  = SYSDATE,
           jcjn.last_update_login = fnd_global.LOGIN_ID
     WHERE jcjn.legal_entity_id = nvl(p_legal_entity_ID, -1)
       and jcjn.ledger_id = p_ledger_id
       AND jcjn.period_name = p_period_name;

    --log for debug
    IF (g_proc_level >= g_dbg_level) THEN
      FND_LOG.STRING(g_proc_level,
                     g_module_name || '.' || l_procedure_name || '.end',
                     'end procedure');
    END IF; --( g_proc_level >= g_dbg_level)

  EXCEPTION
    WHEN OTHERS THEN
      IF (FND_LOG.LEVEL_UNEXPECTED >= g_dbg_level) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_module_name || ',' || l_procedure_name ||
                       '.OTHER_EXCEPTION',
                       SQLCODE || ':' || SQLERRM);
      END IF;
      ROLLBACK;

  END Update_JL_Seq;

  --==========================================================================
  --  PROCEDURE NAME:
  --    Fetch_JL_Seq                     Public
  --
  --  DESCRIPTION:
  --        This procedure is used to fetch a sequence number under the
  --           Legal Entity and Period Name for Journal Itemization program
  --
  --  PARAMETERS:
  --      In: p_legal_entity_ID            legal entity ID
  --          p_ledger_id                  ledger ID
  --          p_period_name                period_name
  --
  --  DESIGN REFERENCES:
  --      CNAO_Update_Journal_Sequence_PKG_TD.doc
  --
  --  CHANGE HISTORY:
  --      03/13/2006      Jackey Li          Created
  --      04/28/2007     Qingjun Zhao       Add column Ledger_id to table
  --                                        ja_cn_journal_numbering
  --===========================================================================
  FUNCTION Fetch_JL_Seq(p_legal_entity_ID IN NUMBER,
                        p_ledger_id       in number,
                        p_period_name     IN VARCHAR2) RETURN NUMBER IS

    l_procedure_name VARCHAR2(30) := 'Fetch_JL_Seq';
    l_next_number    NUMBER;

    l_exc_invalid_argument EXCEPTION;

    -- this cursor is used to get stored next_number
    CURSOR c_sequence IS
      SELECT next_number
        FROM JA_CN_JOURNAL_NUMBERING jcjn
       WHERE jcjn.legal_entity_id = NVL(p_legal_entity_ID, -1)
         and jcjn.ledger_id = P_ledger_id
         AND jcjn.period_name = p_period_name;
  BEGIN

    --log for debug
    IF (g_proc_level >= g_dbg_level) THEN
      FND_LOG.STRING(g_proc_level,
                     g_module_name || '.' || l_procedure_name || '.begin',
                     'begin procedure');
    END IF; --( g_proc_level >= g_dbg_level)

    -- if some parameter is null, return 0
    IF p_legal_entity_ID IS NULL OR p_period_name IS NULL or
       p_ledger_id is null THEN
      RAISE l_exc_invalid_argument;
    END IF;

    OPEN c_sequence;
    FETCH c_sequence
      INTO l_next_number;
    IF c_sequence%NOTFOUND THEN
      CLOSE c_sequence;
      Create_JL_Seq(p_legal_entity_ID, p_ledger_id, p_period_name);
      RETURN 1;
    ELSE
      CLOSE c_sequence;
      Update_JL_Seq(p_legal_entity_ID,
                    p_ledger_id,
                    p_period_name,
                    l_next_number + 1);
      RETURN l_next_number;
    END IF; --c_sequence%NOTFOUND

    --log for debug
    IF (g_proc_level >= g_dbg_level) THEN
      FND_LOG.STRING(g_proc_level,
                     g_module_name || '.' || l_procedure_name || '.end',
                     'end procedure');
    END IF; --( g_proc_level >= g_dbg_level)

  EXCEPTION
    WHEN l_exc_invalid_argument THEN
      /*
      IF (FND_LOG.LEVEL_UNEXPECTED >= g_debug_level) THEN
        FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                       g_module_prefix ||','|| l_procedure_name ||
                       '.INVALID_ARGUMENT',
                       'invalid_argument';
      END IF;
      */
      RETURN 0;

  END Fetch_JL_Seq;

END JA_CN_UPDATE_JL_SEQ_PKG;

/
