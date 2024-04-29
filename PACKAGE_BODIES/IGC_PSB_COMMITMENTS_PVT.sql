--------------------------------------------------------
--  DDL for Package Body IGC_PSB_COMMITMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_PSB_COMMITMENTS_PVT" AS
/* $Header: IGCVWCLB.pls 120.10.12000000.5 2007/11/19 09:01:11 mbremkum ship $ */

g_debug_level          NUMBER	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
g_state_level          NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
g_proc_level           NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
g_event_level          NUMBER	:=	FND_LOG.LEVEL_EVENT;
g_excep_level          NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
g_error_level          NUMBER	:=	FND_LOG.LEVEL_ERROR;
g_unexp_level          NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
g_path                 VARCHAR2(255) := 'IGC.PLSQL.IGCVWCLB.IGC_PSB_COMMITMENTS_PVT.';
G_PKG_NAME CONSTANT   VARCHAR2(30):= 'IGC_PSB_COMMITMENTS_PVT';

/*Added for Base Bug 6634822. Also refer Bug 6636273 and 6636531 - Start*/

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
END is_bc_enabled;

/*Added for Base Bug 6634822. Also refer Bug 6636273 and 6636531 - End*/

FUNCTION Is_Cbc_Enabled
( p_set_of_books_id IN NUMBER
) RETURN VARCHAR2
IS

 l_full_path VARCHAR2(500);

BEGIN

 --Bug 3199488
 l_full_path := g_path || 'Is_Cbc_Enabled';
 --Bug 3199488

 RETURN is_bc_enabled(p_set_of_books_id, 'CC');

EXCEPTION
  WHEN OTHERS THEN
     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
		FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, 'Is_Cbc_Enabled');
     END IF;
     -- Bug 3199488
     IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
     END IF;
     -- Bug 3199488
     RETURN FND_API.G_FALSE;

END Is_Cbc_Enabled;

/*Added for Base Bug 6634822. Also refer Bug 6636273 and 6636531 - Start*/

FUNCTION IGCFCK_WRAPPER(
   p_sobid             IN  NUMBER,
   p_header_id         IN  NUMBER,
   p_mode              IN  VARCHAR2,
   p_actual_flag       IN  VARCHAR2,
   p_doc_type          IN  VARCHAR2,
   p_ret_status        OUT NOCOPY VARCHAR2,
   p_batch_result_code OUT NOCOPY VARCHAR2,
   p_debug             IN  VARCHAR2:=FND_API.G_FALSE,
   p_conc_proc         IN  VARCHAR2:=FND_API.G_FALSE
) RETURN BOOLEAN IS
BEGIN

RETURN IGC_CBC_FUNDS_CHECKER.igcfck(p_sobid               => p_sobid   ,
                                    p_header_id            => p_header_id,
                                    p_mode                => p_mode,
                                    p_actual_flag		=> p_actual_flag ,
                                    p_doc_type		=> p_doc_type ,
                                    p_ret_status		=> p_ret_status,
                                    p_batch_result_code	=> p_batch_result_code );

END IGCFCK_WRAPPER;

/*Added for Base Bug 6634822. Also refer Bug 6636273 and 6636531 - Start*/

END IGC_PSB_COMMITMENTS_PVT;

/
