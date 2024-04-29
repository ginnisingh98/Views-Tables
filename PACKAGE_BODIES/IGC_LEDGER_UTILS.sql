--------------------------------------------------------
--  DDL for Package Body IGC_LEDGER_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_LEDGER_UTILS" AS
/* $Header: IGCLUTLB.pls 120.2.12000000.1 2007/10/25 09:20:10 mbremkum noship $ */
  g_path                 VARCHAR2(255) := 'IGC.PLSQL.IGCLUTLS.IGC_LEDGER_UTILS.';
  G_PKG_NAME CONSTANT   VARCHAR2(30):= 'IGC_LEDGER_UTILS';

  g_debug_level          NUMBER :=  FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  g_state_level          NUMBER :=  FND_LOG.LEVEL_STATEMENT;
  g_proc_level           NUMBER :=  FND_LOG.LEVEL_PROCEDURE;
  g_event_level          NUMBER :=  FND_LOG.LEVEL_EVENT;
  g_excep_level          NUMBER :=  FND_LOG.LEVEL_EXCEPTION;
  g_error_level          NUMBER :=  FND_LOG.LEVEL_ERROR;
  g_unexp_level          NUMBER :=  FND_LOG.LEVEL_UNEXPECTED;
  g_debug_mode           VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  FUNCTION is_bc_enabled
                  (p_ledger_id IN NUMBER,
                  p_doc_type IN varchar2) RETURN VARCHAR2;


  FUNCTION is_bc_enabled
                  (p_ledger_id IN NUMBER,
                  p_doc_type IN varchar2) RETURN VARCHAR2 IS
    l_full_path    VARCHAR2(500) := g_path||'is_bc_enabled';

    CURSOR c_bc_enabled IS
    SELECT cc_bc_enable_flag
          ,cbc_po_enable
    FROM igc_cc_bc_enable
    WHERE set_of_books_id = p_ledger_id;

    l_bc_enable igc_cc_bc_enable.cc_bc_enable_flag%TYPE;
    l_po_enable igc_cc_bc_enable.cbc_po_enable%TYPE;
  BEGIN
    l_full_path := g_path || 'Is_Cbc_Enabled';
    OPEN c_bc_enabled;
    FETCH c_bc_enabled INTO l_bc_enable, l_po_enable;
    CLOSE c_bc_enabled;

    IF (p_doc_type in ('CC','ANY') AND nvl(l_bc_enable,'N') = 'Y') THEN
      RETURN FND_API.G_TRUE;
    ELSIF (p_doc_type in ('PO','ANY') AND nvl(l_po_enable,'N') = 'Y') THEN
      RETURN FND_API.G_TRUE;
    END IF;

    RETURN FND_API.G_FALSE;
  EXCEPTION
    WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                               'Is_bc_enabled');
      END IF;
      IF ( g_unexp_level >= g_debug_level ) THEN
        FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
        FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
        FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
        FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
      END IF;
      RETURN FND_API.G_FALSE;
  END;


-- To check Dual budgetary is enabled for Contract Commitment
  FUNCTION is_cc_dual_bc_enabled
                  (p_ledger_id  NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN is_bc_enabled(p_ledger_id, 'CC');
  END;

  -- To check Dual budgetary is enabled for Purchase Order
  FUNCTION is_po_dual_bc_enabled
                  (p_ledger_id  NUMBER) RETURN VARCHAR2 IS
  BEGIN
    RETURN is_bc_enabled(p_ledger_id, 'PO');
  END;

-- To check Dual budgetary is enabled for either PO or CC
  FUNCTION is_dual_bc_enabled
                (p_ledger_id  NUMBER
                ) RETURN VARCHAR2
                IS
  BEGIN
    RETURN is_bc_enabled(p_ledger_id, 'ANY');
  END is_dual_bc_enabled;

  -- To check Dual budgetary is enabled for either PO or CC
  FUNCTION is_dual_bc_enabled
                (p_ledger_id IN NUMBER
                , p_ledger_category IN VARCHAR2) RETURN VARCHAR2 IS
    l_primary_ledger_id GL_LEDGERS.LEDGER_ID%TYPE;
    CURSOR c_primary_ledger IS
    SELECT  primary_ledger_id
    FROM    GL_LEDGER_RELATIONSHIPS
    WHERE   target_ledger_category_code = 'SECONDARY'
    AND     relationship_type_code <> 'NONE'
    AND     application_id = 101
    AND     target_ledger_id = p_ledger_id;
  BEGIN
    IF p_ledger_category = 'SECONDARY' THEN
      OPEN c_primary_ledger;
      FETCH c_primary_ledger INTO l_primary_ledger_id;
      CLOSE c_primary_ledger;
    ELSE
      l_primary_ledger_id := p_ledger_id;
    END IF;

    IF l_primary_ledger_id is NULL THEN
      RETURN FND_API.G_FALSE;
    ELSE
      RETURN is_bc_enabled(l_primary_ledger_id, 'ANY');
    END IF;
  END is_dual_bc_enabled;

-- Get Commitment Ledger Id for a Primary Ledger.
  PROCEDURE get_cbc_ledger
                  (p_primary_ledger_id  IN NUMBER,
                   p_cbc_ledger_id OUT NOCOPY NUMBER,
                   p_cbc_ledger_Name OUT NOCOPY VARCHAR2) IS

  CURSOR c_cbc_ledger IS
  SELECT SEC.LEDGER_ID,
         SEC.LEDGER_NAME
  FROM   GL_SECONDARY_LEDGER_RSHIPS_V SEC
         , GL_LEDGERS LED
  WHERE  LED.LEDGER_ID = SEC.LEDGER_ID
  AND    LED.COMMITMENT_BUDGET_FLAG = 'Y'
  AND    SEC.PRIMARY_LEDGER_ID = p_primary_ledger_id;

  l_full_path    VARCHAR2(500) := g_path||'get_cbc_ledger';
  l_sec_ledger_id GL_LEDGERS.LEDGER_ID%TYPE;
  l_sec_ledger_name GL_LEDGERS.NAME%TYPE;

  BEGIN
    OPEN c_cbc_ledger;
    FETCH c_cbc_ledger INTO l_sec_ledger_id, l_sec_ledger_name;
    CLOSE c_cbc_ledger;

    p_cbc_ledger_id := l_sec_ledger_id;
    p_cbc_ledger_name := l_sec_ledger_name;
  EXCEPTION
    WHEN OTHERS THEN
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                               'get_cbc_ledger');
      END IF;
      IF ( g_unexp_level >= g_debug_level ) THEN
        FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
        FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
        FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
        FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
      END IF;
  END;

END IGC_LEDGER_UTILS;

/
