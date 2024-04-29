--------------------------------------------------------
--  DDL for Package Body IGC_CC_APPROVAL_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_APPROVAL_WF_PKG" AS
/* $Header: IGCVAWFB.pls 120.7.12000000.4 2007/10/15 11:26:39 smannava ship $ */

G_PKG_NAME 	CONSTANT VARCHAR2(30) := 'IGC_CC_APPROVAL_WF_PKG';
--l_debug_mode    VARCHAR2(1) := NVL(FND_PROFILE.VALUE('IGC_DEBUG_ENABLED'),'N');
g_debug_mode      VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

g_cc_state              igc_cc_headers.cc_state%TYPE;
g_cc_enc_status         igc_cc_headers.cc_encmbrnc_status%TYPE;
g_cc_appr_status        igc_cc_headers.cc_apprvl_status%TYPE;
g_bc_reqired            VARCHAR2(1);
g_cc_type               igc_cc_headers.cc_type%TYPE;
g_note                  igc_cc_headers.cc_desc%TYPE;
g_reject_note           VARCHAR2(32000);
g_bc_failure_message    VARCHAR2(32000);
g_error_text            VARCHAR2(32000);
g_cc_version_number     igc_cc_headers.cc_version_num%TYPE;
g_bc_executed           VARCHAR2(1);
g_cc_ctrl_status        igc_cc_headers.cc_ctrl_status%TYPE;
g_org_id                igc_cc_headers.org_id%TYPE;
g_sob_id                igc_cc_headers.set_of_books_id%TYPE;
g_cc_header_id          igc_cc_headers.cc_header_id%TYPE;
g_itemtype              VARCHAR2(50);
g_itemkey               VARCHAR2(50);
g_wf_version            NUMBER;
g_cc_new_state          igc_cc_headers.cc_state%TYPE;
g_cc_new_enc_status     igc_cc_headers.cc_encmbrnc_status%TYPE;
g_cc_new_appr_status    igc_cc_headers.cc_apprvl_status%TYPE;
g_owner_id              igc_cc_headers.CC_OWNER_USER_ID%TYPE;
g_approver_id           igc_cc_headers.CC_OWNER_USER_ID%TYPE;
g_acct_date             igc_cc_headers.cc_acct_date%TYPE;
g_owner_name            VARCHAR2(255);
g_preparer_id           igc_cc_headers.cc_preparer_user_id%TYPE;
g_preparer_name         VARCHAR2(255);
g_old_approver_name     VARCHAR2(255);
g_approver_name         VARCHAR2(255);
g_business_group_id     NUMBER;
g_pos_structure_version_id NUMBER(15);
g_create_po_entries     BOOLEAN;
g_restore_enc           BOOLEAN;        --If transfer from PN to CM failed, restoration of enc amounts required
g_action_notes          VARCHAR2(2000); --Action notes for create_action_history
g_cc_action_type        VARCHAR2(10);   --Action type for create_action_history
g_profile_name          VARCHAR2(255)   := 'IGC_DEBUG_LOG_DIRECTORY';
g_debug_init            VARCHAR2(1);
g_process_name          VARCHAR2(255)   :='IGC_APPROVAL_WORKFLOW_MAIN';
g_wf_name               VARCHAR2(255)   :='IGCAPRWF';
g_cc_number             igc_cc_headers.cc_num%TYPE;
-- CBC CC Bug 2111529   07-Feb-2001 S Brewer  Start(1)
g_use_approval_hier     VARCHAR2(1);
-- CBC CC Bug 2111529   07-Feb-2001 S Brewer  End(1)

-- Bug 3199488
g_debug_level          NUMBER	:=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
g_state_level          NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
g_proc_level           NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
g_event_level          NUMBER	:=	FND_LOG.LEVEL_EVENT;
g_excep_level          NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
g_error_level          NUMBER	:=	FND_LOG.LEVEL_ERROR;
g_unexp_level          NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
g_path                 VARCHAR2(255) := 'IGC.PLSQL.IGCVAWFB.IGC_CC_APPROVAL_WF_PKG.';
l_full_path            VARCHAR2(255);

-- Bug 3199488



PROCEDURE Generate_Message;


PROCEDURE Put_Debug_Msg (
   p_path IN VARCHAR2,
   p_debug_msg IN VARCHAR2
);

PROCEDURE message_token(
   tokname         IN VARCHAR2,
   tokval          IN VARCHAR2
);

PROCEDURE add_message(
   appname           IN VARCHAR2,
   msgname           IN VARCHAR2
);


/* This procedure determines the new statuses, states
   and generate the list of neccessary action       */
PROCEDURE Generate_CC_Action(
   p_action        VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2);

/* Checks the person authority */
PROCEDURE Check_Authority(
   p_result        OUT NOCOPY VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2 );

/* Reads values of the WF parameters into global variables */
PROCEDURE Get_Parameters(
   x_return_status OUT NOCOPY VARCHAR2);

/* Initialize Business group id   */
PROCEDURE Get_Business_group(
   x_return_status OUT NOCOPY VARCHAR2);

/* Read values from the original CC to global variables and init WF variables  */
PROCEDURE Init_variables(
   x_return_status OUT NOCOPY VARCHAR2);

/* Looks for the next available approver */
PROCEDURE Find_Next_Approver(
   x_return_status OUT NOCOPY VARCHAR2);

/* Set meaning values for all parameters */
PROCEDURE Set_Parameters(
   x_return_status OUT NOCOPY VARCHAR2);


/* Procedure Initializes g_bc_enabled parameter */
PROCEDURE Set_BC_Parameter(
   x_return_status OUT NOCOPY VARCHAR2);

/* This procedure is call from the execute BC and reinit version number of the CC */

PROCEDURE Reinit_version(
   x_return_status OUT NOCOPY VARCHAR2);

/* Procedure creates a recorn in the history table */
PROCEDURE Create_History_Record(
   x_return_status OUT NOCOPY VARCHAR2);

/* Procedure calls PO generation for a CC  */
PROCEDURE Generate_PO(
   x_return_status OUT NOCOPY VARCHAR2);

/* Main procedure does all neccessary steps */
PROCEDURE Process_Request(
   p_action        IN  VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2);
/* Procedure Checks supplier */
PROCEDURE Check_Supplier(
   x_return_status OUT NOCOPY VARCHAR2);


/* Procedure update CC with the new statuses  */
PROCEDURE Update_CC(
   x_return_status OUT NOCOPY VARCHAR2);

FUNCTION Check_Segment(
   seg      VARCHAR2,
   seg_low  VARCHAR2,
   seg_high VARCHAR2)
RETURN BOOLEAN;

/* this procedure is used when we need to reject cancelled CC,
 it returns approval status before cancellation*/
FUNCTION Get_Last_App_status
RETURN VARCHAR2;

/**************************************************************************/
/*     This procedure is run when WF needs to get next approval person    */
/**************************************************************************/

PROCEDURE Select_Approver
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  resultout                   OUT NOCOPY      VARCHAR2
)
IS

l_api_name         CONSTANT VARCHAR2(30)   := 'Select_Approver' ;
l_return_status    VARCHAR2(1);

l_full_path            VARCHAR2(255) := g_path||'Select_Approver';
BEGIN

  SAVEPOINT Select_Approver;
  g_itemtype:=itemtype;
  g_itemkey:=itemkey;
  g_debug_init:=NULL;

  IF g_debug_mode = 'Y'
  THEN
      Put_Debug_Msg( l_full_path,'**************************************************************************');
      Put_Debug_Msg( l_full_path,'Procedure '||l_api_name||' called IN '||funcmode||' mode '||' Date '||to_char(sysdate,'DD-MON-YY MI:SS'));
      Put_Debug_Msg( l_full_path,'**************************************************************************');
  END IF;

  IF ( funcmode = 'RUN'  ) THEN

    Get_Parameters(x_return_status =>l_return_status );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise FND_API.G_EXC_ERROR;
    END IF;

    IF (g_wf_version = 1)  THEN --First version - no approval hierarchy
      g_approver_name :=  g_owner_name;
      g_approver_id   :=  g_owner_id;

      wf_engine.SetItemAttrText(g_itemtype,g_itemkey,'APPROVER_NAME',g_approver_name);
      wf_engine.SetItemAttrText(g_itemtype,g_itemkey,'APPROVER_ID',g_approver_id);

     IF g_debug_mode = 'Y'
     THEN
          --Put_Debug_Msg( l_full_path,l_api_name||' successfully completed, WF version '||g_wf_version||' new approver name '||g_approver_name);
    -- Bug 3199488
          IF ( g_event_level >=  g_debug_level ) THEN
              FND_LOG.STRING (g_event_level,l_full_path,l_api_name||' successfully completed, WF version '||                                g_wf_version||' new approver name '||g_approver_name);
          END IF;
    -- Bug 3199488
     END IF;

      resultout := 'COMPLETE:S' ;
      return;
    END IF;

    --Version is not 1 - then find approver in the hierarchy.

    IF g_approver_name IS NULL THEN
       g_approver_name :=  g_owner_name;
       g_approver_id   :=  g_owner_id;
    ELSE
       g_old_approver_name:=g_approver_name;

       Find_Next_Approver(x_return_status =>l_return_status );

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           raise FND_API.G_EXC_ERROR;
       END IF;

    END IF;

    wf_engine.SetItemAttrText(g_itemtype,g_itemkey,'APPROVER_OLD_NAME',g_old_approver_name);
    wf_engine.SetItemAttrText(g_itemtype,g_itemkey,'APPROVER_NAME',g_approver_name);
    wf_engine.SetItemAttrText(g_itemtype,g_itemkey,'APPROVER_ID',g_approver_id);

    IF g_debug_mode = 'Y'
    THEN
        --Put_Debug_Msg( l_full_path,l_api_name||' successfully completed, WF version '||g_wf_version||' new approver name '||g_approver_name);
	-- Bug 3199488
	IF ( g_event_level >=  g_debug_level ) THEN
	      FND_LOG.STRING (g_event_level,l_full_path,l_api_name||' successfully completed, WF version '||                                g_wf_version||' new approver name '||g_approver_name);
	END IF;
	-- Bug 3199488
    END IF;

    resultout := 'COMPLETE:S' ;
    return;
  END IF ;

  IF ( funcmode = 'CANCEL' ) THEN
    resultout := 'COMPLETE' ;
    return;
  END IF;

  IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
    resultout := '' ;
    return;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
  --If execution error, rollback all database changes, generate message text
  --and return failure status to the WF
     ROLLBACK TO Select_Approver;
     resultout := 'COMPLETE:E';
     Generate_Message();
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
     END IF;
     --Bug 3199488
     return;

  WHEN OTHERS THEN

    IF g_debug_mode = 'Y'
    THEN
        Put_Debug_Msg( l_full_path,l_api_name||' raised unhandled exception');
    END IF;

    wf_core.context(G_PKG_NAME, l_api_name,
                     itemtype, itemkey, to_char(actid), funcmode);
    -- Bug 3199488
    IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
    END IF;
    -- Bug 3199488
    RAISE ;

END Select_Approver ;


/**************************************************************************/
/* This procedure is run when WF needs to check authority of the approver */
/**************************************************************************/

PROCEDURE Check_Authority
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  resultout                   OUT NOCOPY      VARCHAR2
)
IS

l_api_name                CONSTANT VARCHAR2(30)   := 'Check_Authority' ;
l_return_status    VARCHAR2(1);
l_result           VARCHAR2(1);
l_full_path            VARCHAR2(255) := g_path||'Check_Authority';
BEGIN

  SAVEPOINT Check_Authority;
  g_itemtype:=itemtype;
  g_itemkey:=itemkey;
  g_debug_init:=NULL;

  IF g_debug_mode = 'Y'
  THEN
      Put_Debug_Msg( l_full_path,'**************************************************************************');
      Put_Debug_Msg( l_full_path,'Procedure '||l_api_name||' called IN '||funcmode||' mode'||' Date '||to_char(sysdate,'DD-MON-YY MI:SS'));
      Put_Debug_Msg( l_full_path,'**************************************************************************');
  END IF;

  IF ( funcmode = 'RUN'  ) THEN

    Get_Parameters(x_return_status =>l_return_status );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise FND_API.G_EXC_ERROR;
    END IF;

    --Check the supplier

    Check_Supplier(x_return_status =>l_return_status );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise FND_API.G_EXC_ERROR;
    END IF;

    IF (g_wf_version = 1)  THEN --First version - no approval hierarchy

      IF g_debug_mode = 'Y'
      THEN
          --Put_Debug_Msg( l_full_path,l_api_name||' successfully completed, WF version '||g_wf_version||' result Y');
	  -- Bug 3199488
	  IF ( g_event_level >=  g_debug_level ) THEN
      		FND_LOG.STRING (g_event_level,l_full_path,l_api_name||' successfully completed, WF version '||g_wf_version||' result Y');
	  END IF;
	  -- Bug 3199488
      END IF;

      resultout := 'COMPLETE:Y' ;
      return;
    END IF;

    Check_Authority(p_result=> l_result,
                    x_return_status =>l_return_status );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise FND_API.G_EXC_ERROR;
    END IF;

    IF g_debug_mode = 'Y'
    THEN
        Put_Debug_Msg( l_full_path,l_api_name||' successfully completed, WF version '||g_wf_version||' result '||l_result);
	-- Bug 3199488
	IF ( g_event_level >=  g_debug_level ) THEN
      		FND_LOG.STRING (g_event_level,l_full_path,l_api_name||' successfully completed, WF version '||g_wf_version||' result '||l_result);
	END IF;
	-- Bug 3199488
    END IF;

    resultout := 'COMPLETE:'||l_result ;
    return;
  END IF ;

  IF ( funcmode = 'CANCEL' ) THEN
    resultout := 'COMPLETE' ;
    return;
  END IF;

  IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
    resultout := '' ;
    return;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
  --If execution error, rollback all database changes, generate message text
  --and return failure status to the WF

     ROLLBACK TO Check_Authority;
     resultout := 'COMPLETE:E';
     Generate_Message();
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
     END IF;
     --Bug 3199488
     return;

  WHEN OTHERS THEN
    Put_Debug_Msg( l_full_path,l_api_name||' raised unhandled exception');

    wf_core.context(G_PKG_NAME, l_api_name,
                     itemtype, itemkey, to_char(actid), funcmode);
    -- Bug 3199488
    IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
    END IF;
    -- Bug 3199488
    RAISE ;

END Check_Authority ;


/**************************************************************************/
/*       Procedure returns if CC reqiures encumber                        */
/**************************************************************************/

PROCEDURE Funds_Required
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  resultout                   OUT NOCOPY      VARCHAR2
)
IS

l_api_name                CONSTANT VARCHAR2(30)   := 'Funds_Required' ;
l_return_status    VARCHAR2(1);
l_full_path            VARCHAR2(255) := g_path||'Funds_Required';
BEGIN

  SAVEPOINT Funds_Required;
  g_itemtype:=itemtype;
  g_itemkey:=itemkey;
  g_debug_init:=NULL;

  IF g_debug_mode = 'Y'
  THEN
      Put_Debug_Msg( l_full_path,'**************************************************************************');
      Put_Debug_Msg( l_full_path,'Procedure '||l_api_name||' called IN '||funcmode||' mode'||' Date '||to_char(sysdate,'DD-MON-YY MI:SS'));
      Put_Debug_Msg( l_full_path,'**************************************************************************');
  END IF;

  IF ( funcmode = 'RUN'  ) THEN

    g_bc_reqired:= wf_engine.GetItemAttrText  (g_itemtype,g_itemkey,'BC_REQUIRED');

    IF g_bc_reqired='N' THEN

      IF g_debug_mode = 'Y'
      THEN
          --Put_Debug_Msg( l_full_path,l_api_name||' successfully completed, Return result: N');
	  -- Bug 3199488
	  IF ( g_event_level >=  g_debug_level ) THEN
      		FND_LOG.STRING (g_event_level,l_full_path,l_api_name || ' successfully completed, Return result: N');
	  END IF;
	  -- Bug 3199488
      END IF;

      resultout := 'COMPLETE:N';
    ELSE

     IF g_debug_mode = 'Y'
     THEN
         --Put_Debug_Msg( l_full_path,l_api_name||' successfully completed, Return result: Y');
         -- Bug 3199488
	 IF ( g_event_level >=  g_debug_level ) THEN
      		FND_LOG.STRING (g_event_level,l_full_path,l_api_name || ' successfully completed, Return result: Y');
	 END IF;
	 -- Bug 3199488
     END IF;

      resultout := 'COMPLETE:Y' ;
    END IF;
    return;
  END IF ;

  IF ( funcmode = 'CANCEL' ) THEN
    resultout := 'COMPLETE' ;
    return;
  END IF;

  IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
    resultout := '' ;
    return;
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    Put_Debug_Msg( l_full_path,l_api_name||' raised unhandled exception');

    wf_core.context(G_PKG_NAME, l_api_name,
                     itemtype, itemkey, to_char(actid), funcmode);
    -- Bug 3199488
    IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
    END IF;
    -- Bug 3199488
    RAISE ;

END Funds_Required ;



/**************************************************************************/
/*               Procedure for execution of Reject action                 */
/**************************************************************************/

PROCEDURE Reject_Contract
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  resultout                   OUT NOCOPY      VARCHAR2
)
IS

l_api_name                CONSTANT VARCHAR2(32766)   := g_path||'Reject_Contract' ;
l_return_status    VARCHAR2(1);
BEGIN

  SAVEPOINT Reject_Contract;
  g_itemtype:=itemtype;
  g_itemkey:=itemkey;
  g_debug_init:=NULL;

  IF g_debug_mode = 'Y'
  THEN
      Put_Debug_Msg( l_full_path,'**************************************************************************');
      Put_Debug_Msg( l_full_path,'Procedure '||l_api_name||' called IN '||funcmode||' mode'||' Date '||to_char(sysdate,'DD-MON-YY MI:SS'));
      Put_Debug_Msg( l_full_path,'**************************************************************************');
  END IF;

  IF ( funcmode = 'RUN'  ) THEN

     Process_request(
         p_action        => 'R',
         x_return_status => l_return_status );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       raise FND_API.G_EXC_ERROR;
    END IF;

    IF g_debug_mode = 'Y'
    THEN
        Put_Debug_Msg( l_full_path,l_api_name||' successfully completed, Return result: S');
    -- Bug 3199488
	IF ( g_event_level >=  g_debug_level ) THEN
      		FND_LOG.STRING (g_event_level,l_full_path,l_api_name||' successfully completed, Return result: S');
	END IF;
    -- Bug 3199488
    END IF;

    resultout := 'COMPLETE:S' ;
    return;
  END IF ;

  IF ( funcmode = 'CANCEL' ) THEN
    resultout := 'COMPLETE' ;
    return;
  END IF;

  IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
    resultout := '' ;
    return;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
  --If execution error, rollback all database changes, generate message text
  --and return failure status to the WF

     ROLLBACK TO Reject_Contract;
     resultout := 'COMPLETE:E';
     Generate_Message();
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
     END IF;
     -- Bug 3199488
     return;

  WHEN OTHERS THEN
    Put_Debug_Msg( l_full_path,l_api_name||' raised unhandled exception');

    wf_core.context(G_PKG_NAME, l_api_name,
                     itemtype, itemkey, to_char(actid), funcmode);
    -- Bug 3199488
    IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
    END IF;
    -- Bug 3199488
    RAISE ;

END Reject_Contract ;



/**************************************************************************/
/*               Procedure for execution of Approve  action               */
/**************************************************************************/

PROCEDURE Approve_Contract
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  resultout                   OUT NOCOPY      VARCHAR2
)
IS

l_api_name                CONSTANT VARCHAR2(30)   := 'Approve_Contract' ;
l_return_status    VARCHAR2(1);
l_full_path            VARCHAR2(255) := g_path||'Approve_Contract';
BEGIN

  SAVEPOINT Approve_Contract;
  g_itemtype:=itemtype;
  g_itemkey:=itemkey;
  g_debug_init:=NULL;

  IF g_debug_mode = 'Y'
  THEN
      Put_Debug_Msg( l_full_path,'**************************************************************************');
      Put_Debug_Msg( l_full_path,'Procedure '||l_api_name||' called IN '||funcmode||' mode'||' Date '||to_char(sysdate,'DD-MON-YY MI:SS'));
      Put_Debug_Msg( l_full_path,'**************************************************************************');
  END IF;

  IF ( funcmode = 'RUN'  ) THEN
     Process_request(
         p_action        => 'A',
         x_return_status => l_return_status );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       raise FND_API.G_EXC_ERROR;
    END IF;

    IF g_debug_mode = 'Y'
    THEN
        --Put_Debug_Msg( l_full_path,l_api_name||' successfully completed, Result: S');
      	-- Bug 3199488
	IF ( g_event_level >=  g_debug_level ) THEN
      	     FND_LOG.STRING (g_event_level,l_full_path,l_api_name||' successfully completed, Result: S');
	END IF;
	-- Bug 3199488
    END IF;

    resultout := 'COMPLETE:S' ;
    return;
  END IF ;

  IF ( funcmode = 'CANCEL' ) THEN
    resultout := 'COMPLETE' ;
    return;
  END IF;

  IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
    resultout := '' ;
    return;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
  --If execution error, rollback all database changes, generate message text
  --and return failure status to the WF

     ROLLBACK TO Approve_Contract;
     resultout := 'COMPLETE:E';
     Generate_Message();
     -- Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
     END IF;
     -- Bug 3199488
     return;

  WHEN OTHERS THEN
    Put_Debug_Msg( l_full_path,l_api_name||' raised unhandled exception');

    wf_core.context(G_PKG_NAME, l_api_name,
                     itemtype, itemkey, to_char(actid), funcmode);
    -- Bug 3199488
    IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
    END IF;
    -- Bug 3199488
    RAISE ;

END Approve_Contract ;


/**************************************************************************/
/*               Procedure for execution of Budgetary control             */
/**************************************************************************/

PROCEDURE Execute_BC
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  resultout                   OUT NOCOPY      VARCHAR2
)
IS

l_api_name                CONSTANT VARCHAR2(30)   := 'Execute_BC' ;
l_return_status           VARCHAR2(1) ;
l_msg_count               NUMBER ;
l_msg_data                VARCHAR2(2000) ;
l_bc_status               VARCHAR2(1) ;
l_full_path            VARCHAR2(255) := g_path||'Execute_BC';
BEGIN

  SAVEPOINT Execute_BC;
  g_itemtype:=itemtype;
  g_itemkey:=itemkey;
  g_debug_init:=NULL;

  IF g_debug_mode = 'Y'
  THEN
      Put_Debug_Msg( l_full_path,'**************************************************************************');
      Put_Debug_Msg( l_full_path,'Procedure '||l_api_name||' called IN '||funcmode||' mode'||' Date '||to_char(sysdate,'DD-MON-YY MI:SS'));
      Put_Debug_Msg( l_full_path,'**************************************************************************');
  END IF;

  IF ( funcmode = 'RUN'  ) THEN

    Get_Parameters(x_return_status =>l_return_status );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        raise FND_API.G_EXC_ERROR;
    END IF;

    --Exec BC

    IF g_debug_mode = 'Y'
    THEN
       Put_Debug_Msg( l_full_path,'Executing BC');
    END IF;

    IGC_CC_BUDGETARY_CTRL_PKG.Execute_Budgetary_Ctrl
             (  p_api_version      => 1.0,
                x_return_status    => l_return_status,
                x_bc_status        => l_bc_status,
                x_msg_count        => l_msg_count,
                x_msg_data         => l_msg_data,
                p_cc_header_id     => g_cc_header_id,
                p_accounting_date  => g_acct_date,
                p_mode             => 'R');


    SAVEPOINT Execute_BC;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       IF g_debug_mode = 'Y'
       THEN
           --Put_Debug_Msg( l_full_path,'IGC_CC_BUDGETARY_CTRL_PKG.Execute_Budgetary_Ctrl returned error ');
	   -- Bug 3199488
	   IF ( g_excep_level >=  g_debug_level ) THEN
      	     FND_LOG.STRING (g_excep_level,l_full_path,'IGC_CC_BUDGETARY_CTRL_PKG.Execute_Budgetary_Ctrl returned error ');
	   END IF;
	   -- Bug 3199488
	   END IF;
           raise FND_API.G_EXC_ERROR;
    END IF;

    IF g_debug_mode = 'Y'
    THEN
       Put_Debug_Msg( l_full_path,'Successfully executed');
    END IF;

    IF l_bc_status = FND_API.G_TRUE THEN

      --Setting bc executed status
      Reinit_Version(x_return_status =>l_return_status );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          raise FND_API.G_EXC_ERROR;
      END IF;

      g_bc_executed :='Y';

      wf_engine.SetItemAttrText(g_itemtype,g_itemkey,'BC_EXECUTED',g_bc_executed);

      IF g_debug_mode = 'Y'
      THEN
          --Put_Debug_Msg( l_full_path,l_api_name||' successfully completed, Return result: P');
	  -- Bug 3199488
	  IF ( g_excep_level >=  g_debug_level ) THEN
      	     FND_LOG.STRING (g_excep_level,l_full_path,l_api_name||' successfully completed, Return result: P');
	  END IF;
	  -- Bug 3199488
      END IF;

      resultout := 'COMPLETE:P' ;
    ELSE

      Generate_Message();

      g_bc_failure_message:=g_error_text;

      wf_engine.SetItemAttrText(g_itemtype,g_itemkey,'BC_FAILURE_MESSAGE',g_bc_failure_message);

      IF g_debug_mode = 'Y'
      THEN
          Put_Debug_Msg( l_full_path,l_api_name||' successfully completed, Return result: F, BC failed ');
      END IF;

      resultout := 'COMPLETE:F' ;
      return;
    END IF;

  END IF ;

  IF ( funcmode = 'CANCEL' ) THEN
    resultout := 'COMPLETE' ;
    return;
  END IF;

  IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
    resultout := '' ;
    return;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
  --If execution error, rollback all database changes, generate message text
  --and return failure status to the WF

     ROLLBACK TO Execute_BC;

     resultout := 'COMPLETE:E';
     Generate_Message();
     -- Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
     END IF;
     -- Bug 3199488
     return;

  WHEN OTHERS THEN
    Put_Debug_Msg( l_full_path,l_api_name||' raised unhandled exception');

    wf_core.context(G_PKG_NAME, l_api_name,
                     itemtype, itemkey, to_char(actid), funcmode);
    -- Bug 3199488
    IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
    END IF;
    -- Bug 3199488
    RAISE ;

END Execute_BC ;


/**************************************************************************/
/*               Procedure for execution of Error rollback action         */
/**************************************************************************/

PROCEDURE Failed_Process
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  resultout                   OUT NOCOPY      VARCHAR2
)
IS

l_api_name                CONSTANT VARCHAR2(30)   := 'Failed_Process' ;
l_return_status    VARCHAR2(1);
l_full_path            VARCHAR2(255) := g_path||'Failed_Process';
BEGIN

  SAVEPOINT Failed_Process;
  g_itemtype:=itemtype;
  g_itemkey:=itemkey;
  g_debug_init:=NULL;

  IF g_debug_mode = 'Y'
  THEN
      Put_Debug_Msg( l_full_path,'**************************************************************************');
      Put_Debug_Msg( l_full_path,'Procedure '||l_api_name||' called IN '||funcmode||' mode'||' Date '||to_char(sysdate,'DD-MON-YY MI:SS'));
      Put_Debug_Msg( l_full_path,'**************************************************************************');
  END IF;

  IF ( funcmode = 'RUN'  ) THEN

     Process_request(
         p_action        => 'E',
         x_return_status => l_return_status );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       raise FND_API.G_EXC_ERROR;
    END IF;

    IF g_debug_mode = 'Y'
    THEN
        --Put_Debug_Msg( l_full_path,l_api_name||' successfully completed, Return result: None');
	-- Bug 31994888
	IF ( g_event_level >=  g_debug_level ) THEN
      		FND_LOG.STRING (g_event_level,l_full_path,l_api_name||' successfully completed, Return result: None');
	END IF;
        -- Bug 3199488
    END IF;

    resultout := 'COMPLETE' ;
    return;
  END IF ;

  IF ( funcmode = 'CANCEL' ) THEN
    resultout := 'COMPLETE' ;
    return;
  END IF;

  IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
    resultout := '' ;
    return;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
  --If execution error, rollback all database changes, generate message text
  --and return failure status to the WF

     ROLLBACK TO Failed_Process;
     Generate_Message();
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
     END IF;
     -- Bug 3199488
     RAISE;

  WHEN OTHERS THEN
    Put_Debug_Msg( l_full_path,l_api_name||' raised unhandled exception');

    wf_core.context(G_PKG_NAME, l_api_name,
                     itemtype, itemkey, to_char(actid), funcmode);
    -- Bug 3199488
    IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
    END IF;
    -- Bug 3199488
    RAISE ;

END Failed_Process ;



/**************************************************************************/
/*               Procedure for execution of BC failed action              */
/**************************************************************************/
PROCEDURE BC_Failed
(
  itemtype                    IN       VARCHAR2,
  itemkey                     IN       VARCHAR2,
  actid                       IN       NUMBER,
  funcmode                    IN       VARCHAR2,
  resultout                   OUT NOCOPY      VARCHAR2
)
IS

l_api_name                CONSTANT VARCHAR2(30)   := 'BC_Failed' ;
l_return_status    VARCHAR2(1);
l_full_path            VARCHAR2(255):= g_path||'BC_Failed';
BEGIN

  SAVEPOINT BC_Failed;
  g_itemtype:=itemtype;
  g_itemkey:=itemkey;
  g_debug_init:=NULL;

  IF g_debug_mode = 'Y'
  THEN
      Put_Debug_Msg( l_full_path,'**************************************************************************');
      Put_Debug_Msg( l_full_path,'Procedure '||l_api_name||' called IN '||funcmode||' mode'||' Date '||to_char(sysdate,'DD-MON-YY MI:SS'));
      Put_Debug_Msg( l_full_path,'**************************************************************************');
  END IF;

  IF ( funcmode = 'RUN'  ) THEN

     Process_request(
         p_action        => 'F',
         x_return_status => l_return_status );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       raise FND_API.G_EXC_ERROR;
    END IF;

    IF g_debug_mode = 'Y'
    THEN
        Put_Debug_Msg( l_full_path,l_api_name||' successfully completed, Return result: S');
    -- Bug 31994888
    IF ( g_event_level >=  g_debug_level ) THEN
        FND_LOG.STRING (g_event_level,l_full_path,l_api_name||' successfully completed, Return result: S');
    END IF;
-- Bug 3199488
    END IF;

    resultout := 'COMPLETE:S' ;
    return;
  END IF ;

  IF ( funcmode = 'CANCEL' ) THEN
    resultout := 'COMPLETE' ;
    return;
  END IF;

  IF ( funcmode NOT IN ( 'RUN', 'CANCEL' ) ) THEN
    resultout := '' ;
    return;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
  --If execution error, rollback all database changes, generate message text
  --and return failure status to the WF

     ROLLBACK TO BC_Failed;
     resultout := 'COMPLETE:E';
     Generate_Message();
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
     END IF;
     --Bug 3199488
     return;

  WHEN OTHERS THEN
    Put_Debug_Msg( l_full_path,l_api_name||' raised unhandled exception');

    wf_core.context(G_PKG_NAME, l_api_name,
                     itemtype, itemkey, to_char(actid), funcmode);
    -- Bug 3199488
    IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
    END IF;
    -- Bug 3199488
    RAISE ;

END BC_Failed ;




/**************************************************************************/
/*               Procedure WF submition                                   */
/**************************************************************************/

PROCEDURE Start_Process
(
  p_api_version               IN       NUMBER   ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_wf_version                IN       NUMBER   := 2,
  x_return_status             OUT NOCOPY      VARCHAR2 ,
  x_msg_count                 OUT NOCOPY      NUMBER   ,
  x_msg_data                  OUT NOCOPY      VARCHAR2 ,
  p_item_key                  IN       VARCHAR2 ,
  p_cc_header_id              IN       NUMBER   ,
  p_acct_date                 IN       DATE     ,
  p_note                      IN       VARCHAR2 := '',
  p_debug_mode                IN       VARCHAR2 := FND_API.G_FALSE
)
IS

  l_api_name                CONSTANT VARCHAR2(30)   := 'Start_Process' ;
  l_api_version             CONSTANT NUMBER         :=  1.0 ;
  l_return_status           VARCHAR2(1) ;
  l_msg_count               NUMBER ;
  l_msg_data                VARCHAR2(2000) ;

CURSOR c_update_cc IS
    SELECT cc_apprvl_status
     FROM igc_cc_headers
    WHERE cc_header_id = g_cc_header_id
     FOR UPDATE;

CURSOR c_wf_name IS
    SELECT wf_approval_itemtype,
           wf_approval_process
      FROM igc_cc_routing_ctrls
     WHERE (org_id,cc_type,cc_state)
           IN (
                SELECT org_id                 ,
                       cc_type                ,
                       cc_state
                  FROM igc_cc_headers
                 WHERE cc_header_id = g_cc_header_id
               );

l_full_path            VARCHAR2(255) := g_path||'Start_Prcocess';
BEGIN

  SAVEPOINT Start_Process;
  --
  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS ;


  g_cc_header_id := p_cc_header_id;
  g_itemkey      := p_item_key;
  g_wf_version   := p_wf_version;
  g_debug_init   := 'Y';
  g_note         := p_note;
  g_acct_date    := p_acct_date;

  OPEN c_wf_name;
  FETCH c_wf_name INTO g_wf_name,g_process_name;

  IF c_wf_name%NOTFOUND OR g_wf_name IS NULL OR g_process_name IS NULL THEN
     g_wf_name:= 'IGCAPRWF';
     g_process_name:= 'IGC_APPROVAL_WORKFLOW_MAIN';
  END IF;

  CLOSE c_wf_name;

  g_itemtype     := g_wf_name;


  /*IF p_debug_mode = FND_API.G_TRUE OR p_debug_mode = 'Y' OR (upper(fnd_profile.value('IGC_DEBUG_ENABLED')) ='Y') THEN
     IGC_MSGS_PKG.g_debug_mode := TRUE;
     l_debug_mode := 'Y';
  ELSE
     IGC_MSGS_PKG.g_debug_mode := FALSE;
     l_debug_mode := 'N';
  END IF;*/

  IF g_debug_mode = 'Y'
  THEN
      Put_Debug_Msg( l_full_path,'**************************************************************************');
      Put_Debug_Msg( l_full_path,'WF process is run on '||to_char(sysdate,'DD-MON-YY MI:SS')
                ||' CC header: '||g_cc_header_id
                ||' WF version: '||p_wf_version);
      Put_Debug_Msg( l_full_path,'**************************************************************************');

      -- Lock CC
      Put_Debug_Msg( l_full_path,'Locking CC ');
  END IF;

  OPEN c_update_cc;
  FETCH c_update_cc INTO g_cc_state;

  IF c_update_cc%NOTFOUND THEN

     CLOSE c_update_cc;
     message_token ('CC_HEADER_ID', g_cc_header_id);
     add_message ('IGC', 'IGC_CC_NOT_FOUND');
     RAISE FND_API.G_EXC_ERROR;

  END IF;

  IF g_debug_mode = 'Y'
  THEN
      Put_Debug_Msg( l_full_path,'Success, create process');
  END IF;

  wf_engine.CreateProcess ( ItemType => g_wf_name,
                            ItemKey  => p_item_key,
                            Process  => g_process_name );

  WF_Engine.SetItemUserKey
  (
     ItemType => g_wf_name        ,
     ItemKey  => p_item_key         ,
     UserKey  => p_cc_header_id
  );


  --Read values from the original CC to global variables and init WF variables
  Init_variables(x_return_status =>l_return_status );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     raise FND_API.G_EXC_ERROR;
  END IF;

  --Set meaning values for all parameters

  Set_Parameters(x_return_status =>l_return_status );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     raise FND_API.G_EXC_ERROR;
  END IF;

  --Initialize g_bc_enabled parameter

  Set_BC_Parameter(x_return_status =>l_return_status );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     raise FND_API.G_EXC_ERROR;
  END IF;

  wf_engine.SetItemAttrText  (g_itemtype,g_itemkey,'BC_REQUIRED',g_bc_reqired);

  -- Check if the requested CC state and status are valid and can be handler by the process

  Generate_CC_Action(
        p_action        => 'A',
        x_return_status => l_return_status );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     raise FND_API.G_EXC_ERROR;
  END IF;

  --Insert history record

  g_cc_new_state       := g_cc_state;
  g_cc_new_appr_status := g_cc_appr_status;
  g_cc_action_type     := 'SA';
  g_action_notes       := p_note;

  Create_History_Record(
        x_return_status => l_return_status );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     raise FND_API.G_EXC_ERROR;
  END IF;

  g_cc_new_state       := NULL;
  g_cc_new_appr_status := NULL;


  IF g_debug_mode = 'Y'
  THEN
      Put_Debug_Msg( l_full_path,'Update CC header to IP');
  END IF;

  UPDATE igc_cc_headers
       SET cc_apprvl_status    = 'IP',
           last_update_date   = sysdate,
           last_updated_by    = fnd_global.user_id,
           last_update_login  = fnd_global.login_id
     WHERE CURRENT OF  c_update_cc;

  CLOSE c_update_cc;

  -- Start the process

  IF IGC_MSGS_PKG.g_debug_mode  = TRUE THEN
     wf_engine.SetItemAttrText(g_itemtype,g_itemkey,'DEBUG_MODE', FND_API.G_TRUE);
  ELSE
     wf_engine.SetItemAttrText(g_itemtype,g_itemkey,'DEBUG_MODE', FND_API.G_FALSE);
  END IF;

  IF g_debug_mode = 'Y'
  THEN
      Put_Debug_Msg( l_full_path,'Starting process');
  END IF;

  wf_engine.StartProcess ( ItemType => g_wf_name,
                           ItemKey  => p_item_key   );


  COMMIT WORK;

  IF g_debug_mode = 'Y'
  THEN
      Put_Debug_Msg( l_full_path,l_api_name||' Successfully completed');
  END IF;

  FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     Rollback to Start_Process;
     x_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
     END IF;
     --Bug 3199488

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     Rollback to Start_Process;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
     END IF;
     --Bug 3199488

   WHEN OTHERS THEN

       Put_Debug_Msg( l_full_path,l_api_name||' raised unhandled exception');

       Rollback to Start_Process;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;

       FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                              p_data  => x_msg_data );
       -- Bug 3199488
       IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       -- Bug 3199488

END Start_Process ;

/* This procedure determines the new statuses, states
     and generate the list of neccessary action       */

PROCEDURE Generate_CC_Action(
p_action        VARCHAR2,
x_return_status OUT NOCOPY VARCHAR2)
IS
l_api_name                CONSTANT VARCHAR2(30)   := 'Generate_CC_Action' ;

l_total_state  VARCHAR2(10);
l_new_state    VARCHAR2(10);
l_old_appr_status VARCHAR2(2);

l_full_path            VARCHAR2(255) := g_path||'Generate_CC_action';
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  IF g_debug_mode = 'Y'
  THEN
      Put_Debug_Msg( l_full_path,l_api_name||' started');
  END IF;

  --Initilize total state
  l_total_state:=g_cc_state||g_cc_appr_status||g_cc_enc_status;

  g_restore_enc :=FALSE;

  l_old_appr_status :='IN';

  IF l_total_state='PRINN' THEN
     SELECT decode(p_action,
                   'A','PRAP'||decode(g_bc_reqired,'Y','P','N'),
                   'R','PRRJN',
                   'E','PRINN',
                   'F','PRINN'
                  )
       INTO l_new_state
       FROM dual;
  ELSIF l_total_state='PRINP' THEN
     SELECT decode(p_action,
                   'A','PRAPP',
                   'R','PRRJP',
                   'E','PRINP'
                  ) -- No Failed action
       INTO l_new_state
       FROM dual;
  ELSIF l_total_state='PRRRN' THEN
     SELECT decode(p_action,
                   'A','PRAP'||decode(g_bc_reqired,'Y','P','N'),
                   'R','PRRJN',
                   'E','PRRRN',
                   'F','PRRRN'
                  )
       INTO l_new_state
       FROM dual;
  ELSIF l_total_state='PRRRP' THEN
     SELECT decode(p_action,
                   'A','PRAPP',
                   'R','PRRJP',
                   'E','PRRRP'
                  ) -- No Failed action
       INTO l_new_state
       FROM dual;
  ELSIF l_total_state='CMINN' THEN  --5
     SELECT decode(p_action,
                   'A','CMAP'||decode(g_bc_reqired,'Y','C','N'),
                   'R','PRRRN',
                   'E','CMINN',
                   'F','CMRJN'
                  )
       INTO l_new_state
       FROM dual;
  ELSIF l_total_state='CMINT' THEN  --6
     SELECT decode(p_action,
                   'A','CMAPC',
                   'R','PRRRP',
                   'E','CMINT',
                   'F','CMRJT'
                  )
       INTO l_new_state
       FROM dual;

     IF p_action = 'R' THEN  --Rollback to provisional enc  needed
       g_restore_enc :=TRUE;
     END IF;

  ELSIF l_total_state='CMINC' THEN  --7
     SELECT decode(p_action,
                   'A','CMAPC',
                   'R','CMRJC',
                   'E','CMINC'
                  )
       INTO l_new_state
       FROM dual;
  ELSIF l_total_state='CMRRN' THEN  --8
     SELECT decode(p_action,
                   'A','CMAP'||decode(g_bc_reqired,'Y','C','N'),
                   'R','CMRJN',
                   'E','CMRRN',
                   'F','CMRRN'
                  )
       INTO l_new_state
       FROM dual;
  ELSIF l_total_state='CMRRC' THEN  --9
     SELECT decode(p_action,
                   'A','CMAPC',
                   'R','CMRJC',
                   'E','CMRRC'
                  )
       INTO l_new_state
       FROM dual;
  ELSIF l_total_state='CLINN' THEN  --10
     -- l_old_appr_status:= Get old status from history
     l_old_appr_status:= Get_Last_App_status;
     SELECT decode(p_action,
                   'A','CLAPN',
                   'R','PR'||l_old_appr_status||'N',
                   'E','CLINN'
                  )
       INTO l_new_state
       FROM dual;
  ELSIF l_total_state='CLINP' THEN  --11
     -- Get old status from history
     l_old_appr_status:= Get_Last_App_status;
     SELECT decode(p_action,
                   'A','CLAPN',
                   'R','PR'||l_old_appr_status||'P',
                   'E','CLINP'
                  )
       INTO l_new_state
       FROM dual;

  ELSIF l_total_state='CTINC' THEN  --12
     SELECT decode(p_action,
                   'A','CTAPN',
                   'R','CMAPC',
                   'E','CTINC',
                   'F','CTINC'
                  )
       INTO l_new_state
       FROM dual;
  ELSIF l_total_state='CTINNC' THEN  --13
     SELECT decode(p_action,
                   'A','CTAPN',
                   'R','CMAPN',
                   'E','CTINN'
                  )
       INTO l_new_state
       FROM dual;
  ELSIF  g_cc_appr_status ='RJ' AND g_cc_state IN ('PR','CM') THEN
     SELECT decode(p_action,
                   'A',g_cc_state||'AP'||decode(g_bc_reqired,'N',g_cc_enc_status,decode(g_cc_state,'PR','P','C')),
                   'R',g_cc_state||'RJ'||g_cc_enc_status,
                   'E',g_cc_state||'RJ'||g_cc_enc_status,
                   'F',g_cc_state||'RJ'||'N'
                  )
       INTO l_new_state
       FROM dual;

  ELSE
       --Generate error message, unhandled situation

     message_token ('CC_NUM', g_cc_number);
     message_token ('CC_STATE', g_cc_state);
     message_token ('CC_ENC_STATUS', g_cc_enc_status);
     message_token ('CC_APR_STATUS', g_cc_appr_status);
     add_message ('IGC', 'IGC_CC_STATE_ERROR');
     RAISE FND_API.G_EXC_ERROR;

  END IF;


  g_create_po_entries:=FALSE;

  IF p_action = 'A' AND g_cc_type IN ('S', 'R') AND g_cc_state = 'CM' THEN
     g_create_po_entries :=TRUE;  --Po entries create
     IF g_debug_mode = 'Y'
     THEN
         Put_Debug_Msg( l_full_path,'PO generation required');
     END IF;
  END IF;

  --obtaining the note text

  SELECT decode(p_action,
                'F',g_bc_failure_message,
                'E',substr(g_error_text,1,240),
                'A',substr(g_reject_note,1,240),
                'R',substr(g_reject_note,1,240))
    INTO g_action_notes
    FROM dual;

  --Getting the new statuses and states
  g_cc_new_state      :=substr(l_new_state,1,2);
  g_cc_new_appr_status:=substr(l_new_state,3,2);
  g_cc_new_enc_status :=substr(l_new_state,5,1);

  g_cc_action_type :='RJ';

  IF p_action = 'A' THEN
     g_cc_action_type :='AP';
  END IF;

  IF g_debug_mode = 'Y'
  THEN
     Put_Debug_Msg( l_full_path,'New parameters: '||
                ' state: '||g_cc_new_state||
                ' appr status: '||g_cc_new_appr_status||
                ' enc status: '||g_cc_new_enc_status||
                ' act type: '||g_cc_action_type
                );

     Put_Debug_Msg( l_full_path,l_api_name||' Successfully completed');
  END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
     END IF;
     --Bug 3199488
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
     END IF;
     --Bug 3199488

   WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       Put_Debug_Msg( l_full_path,l_api_name||' raised unhandled exception');

       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       -- Bug 3199488
       IF ( g_unexp_level >= g_debug_level ) THEN
          FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
          FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
          FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
          FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       -- Bug 3199488

END Generate_CC_Action;


/* Reads values of the WF parameters into global vatiables */

PROCEDURE Get_Parameters(
   x_return_status OUT NOCOPY VARCHAR2)
IS

l_api_name                CONSTANT VARCHAR2(30)   := 'Get_Parameters' ;
l_full_path            VARCHAR2(255) := g_path||'Get_Parameters';

BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS ;
 IF g_debug_mode = 'Y'
 THEN
     Put_Debug_Msg( l_full_path,l_api_name||' started');
 END IF;

 g_old_approver_name    := wf_engine.GetItemAttrText(g_itemtype,g_itemkey,'APPROVER_OLD_NAME');
 g_approver_name        := wf_engine.GetItemAttrText(g_itemtype,g_itemkey,'APPROVER_NAME');
 g_preparer_name        := wf_engine.GetItemAttrText(g_itemtype,g_itemkey,'PREPARER_NAME');
 g_approver_id          := wf_engine.GetItemAttrNumber(g_itemtype,g_itemkey,'APPROVER_ID');
 g_owner_name           := wf_engine.GetItemAttrText(g_itemtype,g_itemkey,'OWNER_NAME');
 g_wf_version           := wf_engine.GetItemAttrNumber(g_itemtype,g_itemkey,'WF_VERSION');
 g_cc_header_id         := wf_engine.GetItemAttrNumber(g_itemtype,g_itemkey,'CC_HEADER_ID');
 g_cc_state             := wf_engine.GetItemAttrText  (g_itemtype,g_itemkey,'CC_STATE');
 g_cc_enc_status        := wf_engine.GetItemAttrText  (g_itemtype,g_itemkey,'CC_ENCUMBRANCE_STATUS');
 g_cc_appr_status       := wf_engine.GetItemAttrText  (g_itemtype,g_itemkey,'CC_APPRVL_STATUS');
 g_bc_reqired           := wf_engine.GetItemAttrText  (g_itemtype,g_itemkey,'BC_REQUIRED');
 g_cc_type              := wf_engine.GetItemAttrText  (g_itemtype,g_itemkey,'CC_TYPE');
 g_note                 := wf_engine.GetItemAttrText  (g_itemtype,g_itemkey,'NOTE');
 g_reject_note          := wf_engine.GetItemAttrText  (g_itemtype,g_itemkey,'REJECT_NOTE');
 g_bc_failure_message   := wf_engine.GetItemAttrText  (g_itemtype,g_itemkey,'BC_FAILURE_MESSAGE');
 g_cc_version_number    := wf_engine.GetItemAttrText  (g_itemtype,g_itemkey,'CC_VERSION_NUM');
 g_bc_executed          := wf_engine.GetItemAttrText  (g_itemtype,g_itemkey,'BC_EXECUTED');
 g_cc_ctrl_status       := wf_engine.GetItemAttrText  (g_itemtype,g_itemkey,'CC_CTRL_STATUS');
 g_org_id               := wf_engine.GetItemAttrNumber(g_itemtype,g_itemkey,'ORG_ID');
 g_sob_id               := wf_engine.GetItemAttrNumber(g_itemtype,g_itemkey,'SOB_ID');
 g_cc_number            := wf_engine.GetItemAttrText  (g_itemtype,g_itemkey,'CC_NUMBER');
 g_acct_date            := wf_engine.GetItemAttrDate  (g_itemtype,g_itemkey,'CC_ACCT_DATE');

 IF g_org_id IS NOT NULL THEN

/*Replaced below line with call to mo_global. for MOAC uptake for bug#6341012 */
--fnd_client_info.set_org_context(to_char(g_org_id));
 mo_global.set_policy_context('S',g_org_id);

 END IF;

 IF g_debug_mode = 'Y'
 THEN
     Put_Debug_Msg( l_full_path,'Parameters values:'||
     g_old_approver_name     ||  ' - APPROVER_OLD_NAME '  ||
     g_approver_name         || ' - APPROVER_NAME '  ||
     g_preparer_name         ||  ' - PREPARER_NAME '  ||
     g_owner_name            ||  ' - OWNER_NAME '  ||
     g_wf_version            ||  ' - WF_VERSION '  ||
     g_cc_header_id          ||  ' - CC_HEADER_ID '  ||
     g_cc_state              || ' - CC_STATE '  ||
     g_cc_enc_status         || ' - CC_ENCUMBRANCE_STATUS'   ||
     g_cc_appr_status        || ' - CC_APPRVL_STATUS '  ||
     g_bc_reqired            || ' - BC_REQUIRED '  ||
     g_cc_type               || ' - CC_TYPE '  ||
     g_approver_id           || ' - APPROVER_ID ' ||
     g_note                  || ' - NOTE '  ||
     g_reject_note           || ' - REJECT_NOTE '  ||
     g_bc_failure_message    || ' - BC_FAILURE_MESSAGE '  ||
     g_cc_version_number     || ' - CC_VERSION_NUM '  ||
     g_bc_executed           || ' - BC_EXECUTED '  ||
     g_cc_ctrl_status        || ' - CC_CTRL_STATUS '  ||
     g_org_id                || ' - ORG_ID '  ||
     g_sob_id                || ' - SOB_ID ' );

    Put_Debug_Msg( l_full_path,l_api_name||' Successfully completed');
 END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
     END IF;
     --Bug 3199488

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
     END IF;
     --Bug 3199488

   WHEN OTHERS THEN
       Put_Debug_Msg( l_full_path,l_api_name||' raised unhandled exception');
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       -- Bug 3199488
       IF ( g_unexp_level >= g_debug_level ) THEN
             FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
             FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
             FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
             FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       -- Bug 3199488

END Get_Parameters;

/****************************************************************************/
PROCEDURE Set_Parameters(
   x_return_status OUT NOCOPY VARCHAR2)
IS

l_api_name                CONSTANT VARCHAR2(30)   := 'Set_Parameters' ;

CURSOR c_meaning(l_type VARCHAR2,l_code VARCHAR2) IS
   SELECT meaning
     FROM fnd_lookups
    WHERE lookup_code     = l_code
          AND lookup_type = l_type;
l_value VARCHAR2(255);

l_full_path            VARCHAR2(255) := g_path||'Set_parameters';
BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS ;
 IF g_debug_mode = 'Y'
 THEN
     Put_Debug_Msg( l_full_path,l_api_name||' started');
 END IF;

 l_value:=null;
 OPEN c_meaning('IGC_CC_STATE',g_cc_state);
 FETCH c_meaning INTO l_value;
 CLOSE c_meaning;
 wf_engine.SetItemAttrText (g_itemtype,g_itemkey,'CC_STATE_MEANING',l_value);

 l_value:=null;
 OPEN c_meaning('IGC_CC_STATE',g_cc_new_state);
 FETCH c_meaning INTO l_value;
 CLOSE c_meaning;
 wf_engine.SetItemAttrText (g_itemtype,g_itemkey,'CC_STATE_NEW_MEANING',l_value);

 l_value:=null;
 OPEN c_meaning('IGC_CC_CONTROL_STATUS',g_cc_ctrl_status);
 FETCH c_meaning INTO l_value;
 CLOSE c_meaning;
 wf_engine.SetItemAttrText (g_itemtype,g_itemkey,'CC_CTRL_MEANING',l_value);

 l_value:=null;
 OPEN c_meaning('IGC_CC_TYPE',g_cc_type);
 FETCH c_meaning INTO l_value;
 CLOSE c_meaning;
 wf_engine.SetItemAttrText (g_itemtype,g_itemkey,'CC_TYPE_MEANING',l_value);

 l_value:=null;
 OPEN c_meaning('IGC_CC_APPROVAL_STATUS',g_cc_appr_status);
 FETCH c_meaning INTO l_value;
 CLOSE c_meaning;
 wf_engine.SetItemAttrText (g_itemtype,g_itemkey,'CC_APPRVL_MEANING',l_value);

 l_value:=null;
 OPEN c_meaning('IGC_CC_APPROVAL_STATUS',g_cc_new_appr_status);
 FETCH c_meaning INTO l_value;
 CLOSE c_meaning;
 wf_engine.SetItemAttrText (g_itemtype,g_itemkey,'CC_APPRVL_NEW_MEANING',l_value);


 l_value:=null;
 OPEN c_meaning('IGC_CC_ENCUMBRANCE_STATUS',g_cc_enc_status);
 FETCH c_meaning INTO l_value;
 CLOSE c_meaning;
 wf_engine.SetItemAttrText (g_itemtype,g_itemkey,'CC_ENCU_MEANING',l_value);

 l_value:=null;
 OPEN c_meaning('IGC_CC_ENCUMBRANCE_STATUS',g_cc_new_enc_status);
 FETCH c_meaning INTO l_value;
 CLOSE c_meaning;
 wf_engine.SetItemAttrText (g_itemtype,g_itemkey,'CC_ENCU_NEW_MEANING',l_value);

 wf_engine.SetItemAttrText   (g_itemtype,g_itemkey,'CC_NEW_STATE',g_cc_new_state);
 wf_engine.SetItemAttrText   (g_itemtype,g_itemkey,'CC_ENCUMBRANCE_NEW_STATUS',g_cc_new_enc_status);
 wf_engine.SetItemAttrText   (g_itemtype,g_itemkey,'CC_APPRVL_NEW_STATUS',g_cc_new_appr_status);

 IF g_debug_mode = 'Y'
 THEN
     Put_Debug_Msg( l_full_path,l_api_name||' Successfully completed');
 END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
     END IF;
     --Bug 3199488

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
     END IF;
     --Bug 3199488

   WHEN OTHERS THEN
       Put_Debug_Msg( l_full_path,l_api_name||' raised unhandled exception');

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       -- Bug 3199488
       IF ( g_unexp_level >= g_debug_level ) THEN
            FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
            FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
            FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
            FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       -- Bug 3199488

END Set_Parameters;


PROCEDURE Init_variables(
   x_return_status OUT NOCOPY VARCHAR2)
IS
 l_api_name           CONSTANT VARCHAR2(30)   := 'Init_variables' ;

 l_cc_desc            igc_cc_headers.cc_desc%TYPE;
 l_cc_start_date      igc_cc_headers.cc_start_date%TYPE;
 l_cc_end_date        igc_cc_headers.cc_end_date%TYPE;
 l_note               VARCHAR2(255);
 l_org_name           hr_organization_units.name%TYPE;
 l_account_date       igc_cc_headers.cc_acct_date%TYPE;
 l_user_display_name  VARCHAR2(255);
 l_owner_display_name VARCHAR2(255);
 l_use_pos            VARCHAR2(1);

 CURSOR c_org_name IS
   SELECT name
     FROM hr_organization_units
    WHERE organization_id = g_org_id;

 CURSOR c_cc_data IS
    SELECT org_id                 ,
           cc_type                ,
           cc_num                 ,
           cc_version_num         ,
           cc_state               ,
           cc_ctrl_status         ,
           cc_encmbrnc_status     ,
           cc_apprvl_status       ,
           set_of_books_id        ,
           cc_acct_date           ,
           cc_desc                ,
           cc_start_date          ,
           cc_end_date            ,
           f1.employee_id  user_id ,
           f2.employee_id  owner_id
     FROM igc_cc_headers,
          fnd_user f1,
          fnd_user f2
    WHERE cc_header_id = g_cc_header_id
          AND f1.user_id=cc_owner_user_id
          AND f2.user_id=cc_preparer_user_id;

CURSOR c_fin_par IS
 SELECT use_positions_flag
   FROM financials_system_parameters;


 l_full_path VARCHAR2(500) := g_path || 'Init_variables';
BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS ;
 IF g_debug_mode = 'Y'
 THEN
     Put_Debug_Msg( l_full_path,l_api_name||' started');
 END IF;

 g_bc_executed :='N';

  OPEN c_cc_data;
 FETCH c_cc_data
  INTO g_org_id,
       g_cc_type,
       g_cc_number ,
       g_cc_version_number,
       g_cc_state,
       g_cc_ctrl_status,
       g_cc_enc_status,
       g_cc_appr_status,
       g_sob_id,
       l_account_date,
       l_cc_desc,
       l_cc_start_date,
       l_cc_end_date,
       g_owner_id,
       g_preparer_id ;

 IF c_cc_data%NOTFOUND THEN

     CLOSE c_cc_data;
     message_token ('CC_HEADER_ID', g_cc_header_id);
     add_message ('IGC', 'IGC_CC_NOT_FOUND');
     RAISE FND_API.G_EXC_ERROR;

 END IF;

 CLOSE c_cc_data;

 OPEN  c_org_name;
 FETCH c_org_name INTO l_org_name;
 CLOSE c_org_name;

 WF_DIRECTORY.GetUserName('PER',
                          g_preparer_id,
                          g_preparer_name,
		          l_user_display_name);

 WF_DIRECTORY.GetUserName('PER',
                          g_owner_id,
                          g_owner_name,
		          l_owner_display_name);

 /*Replaced below line with call to mo_global. for MOAC uptake for bug#6341012 */
--fnd_client_info.set_org_context(to_char(g_org_id));
 mo_global.set_policy_context('S',g_org_id);
 IF g_wf_version = 2 THEN
    IF g_debug_mode = 'Y'
    THEN
         Put_Debug_Msg( l_full_path,'Current WF version is: '||g_wf_version||' checking use position hierarchy flag');
    END IF;
     OPEN c_fin_par;
     FETCH c_fin_par INTO l_use_pos;

     IF c_fin_par%NOTFOUND THEN
        --Error - can't find record for the current org

        CLOSE c_fin_par;
        message_token ('ORG_ID', g_org_id);
        add_message ('IGC', 'IGC_ORG_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;

     END IF;

     CLOSE c_fin_par;

     -- CBC CC Bug 2111529   07-Feb-2001 S Brewer  Start(2)
     -- Set the g_use_approval_hier parameter
     g_use_approval_hier := nvl(l_use_pos,'N');
     IF g_debug_mode = 'Y'
     THEN
        Put_Debug_Msg( l_full_path,'g_use_approval_hier = '||g_use_approval_hier);
     END IF;

     -- want to check the g_use_approval_hier value instead of l_use_pos

     IF (g_use_approval_hier = 'N') THEN
     --IF l_use_pos ='N' THEN
        --Put_Debug_Msg( l_full_path,'Flag is None, using WF version 1');
        --g_wf_version :=1;
        -- Will use the supervisor hierarchy instead
        IF g_debug_mode = 'Y'
        THEN
            Put_Debug_Msg( l_full_path,'Use approval hierarchy is N - using supervisor hierarchy');
        END IF;
     -- CBC CC Bug 2111529   07-Feb-2001 S Brewer  End(2)
     ELSE
        IF g_debug_mode = 'Y'
        THEN
            Put_Debug_Msg( l_full_path,'Flag is Y, using WF version 2');
        END IF;
     END IF;

 END IF;

 wf_engine.SetItemAttrText(g_itemtype,g_itemkey,'PREPARER_NAME',g_preparer_name);
 wf_engine.SetItemAttrText(g_itemtype,g_itemkey,'OWNER_NAME',g_owner_name);
 wf_engine.SetItemAttrNumber (g_itemtype,g_itemkey,'WF_VERSION',g_wf_version);
 wf_engine.SetItemAttrText   (g_itemtype,g_itemkey,'CC_STATE',g_cc_state);
 wf_engine.SetItemAttrText   (g_itemtype,g_itemkey,'CC_ENCUMBRANCE_STATUS',g_cc_enc_status);
 wf_engine.SetItemAttrText   (g_itemtype,g_itemkey,'CC_APPRVL_STATUS',g_cc_appr_status);
 wf_engine.SetItemAttrText   (g_itemtype,g_itemkey,'BC_REQUIRED',g_bc_reqired);
 wf_engine.SetItemAttrText   (g_itemtype,g_itemkey,'CC_TYPE',g_cc_type);
 wf_engine.SetItemAttrText   (g_itemtype,g_itemkey,'NOTE',g_note);
 wf_engine.SetItemAttrText   (g_itemtype,g_itemkey,'CC_DESC',l_cc_desc);
 wf_engine.SetItemAttrText   (g_itemtype,g_itemkey,'CC_VERSION_NUM',g_cc_version_number);
 wf_engine.SetItemAttrText   (g_itemtype,g_itemkey,'BC_EXECUTED',g_bc_executed);
 wf_engine.SetItemAttrText   (g_itemtype,g_itemkey,'CC_CTRL_STATUS',g_cc_ctrl_status);
 wf_engine.SetItemAttrNumber (g_itemtype,g_itemkey,'ORG_ID',g_org_id);
 wf_engine.SetItemAttrNumber (g_itemtype,g_itemkey,'SOB_ID',g_sob_id);

 wf_engine.SetItemAttrNumber (g_itemtype,g_itemkey,'CC_HEADER_ID',g_cc_header_id);
 wf_engine.SetItemAttrText   (g_itemtype,g_itemkey,'CC_NUMBER',g_cc_number);
 wf_engine.SetItemAttrNumber (g_itemtype,g_itemkey,'CC_OWNER_USER_ID',g_owner_id);
 wf_engine.SetItemAttrText   (g_itemtype,g_itemkey,'OWNER_NAME',g_owner_name);
 wf_engine.SetItemAttrText   (g_itemtype,g_itemkey,'OWNER_DISP_NAME',l_owner_display_name);
 wf_engine.SetItemAttrNumber (g_itemtype,g_itemkey,'CC_PREPARER_USER_ID',g_preparer_id);
 wf_engine.SetItemAttrText   (g_itemtype,g_itemkey,'PREPARER_NAME',g_preparer_name);
 wf_engine.SetItemAttrText   (g_itemtype,g_itemkey,'PREPARER_DISP_NAME',l_user_display_name);
 wf_engine.SetItemAttrText   (g_itemtype,g_itemkey,'CC_DESC',l_cc_desc);
 wf_engine.SetItemAttrDate   (g_itemtype,g_itemkey,'CC_START_DATE',l_cc_start_date);
 wf_engine.SetItemAttrDate   (g_itemtype,g_itemkey,'CC_END_DATE',l_cc_end_date);
 wf_engine.SetItemAttrText   (g_itemtype,g_itemkey,'ORGANIZATION_NAME',l_org_name);
 wf_engine.SetItemAttrDate   (g_itemtype,g_itemkey,'CC_ACCT_DATE',g_acct_date);

 IF g_debug_mode = 'Y'
 THEN
   Put_Debug_Msg( l_full_path,'Initialized vaules:'
   ||' PREPARER_NAME '   ||g_preparer_name
   ||' OWNER_NAME '   ||g_owner_name
   ||' WF_VERSION '   ||g_wf_version
   ||' CC_STATE '   ||g_cc_state
   ||' CC_ENCUMBRANCE_STATUS '   ||g_cc_enc_status
   ||' CC_APPRVL_STATUS '   ||g_cc_appr_status
   ||' BC_REQUIRED '    ||g_bc_reqired
   ||' CC_TYPE '    ||g_cc_type
   ||' NOTE '    ||g_note
   ||' CC_DESC '    ||l_cc_desc
   ||' CC_VERSION_NUM '    ||g_cc_version_number
   ||' BC_EXECUTED '    ||g_bc_executed
   ||' CC_CTRL_STATUS '    ||g_cc_ctrl_status
   ||' ORG_ID '    ||g_org_id
   ||' SOB_ID '    ||g_sob_id
   ||' CC_HEADER_ID '    ||g_cc_header_id
   ||' CC_NUMBER '    ||g_cc_number
   ||' CC_OWNER_USER_ID '    ||g_owner_id
   ||' OWNER_NAME '    ||g_owner_name
   ||' OWNER_DISP_NAME '    ||l_owner_display_name
   ||' CC_PREPARER_USER_ID '    ||g_preparer_id
   ||' PREPARER_NAME '    ||g_preparer_name
   ||' PREPARER_DISP_NAME '    ||l_user_display_name
   ||' CC_DESC '    ||l_cc_desc
   ||' CC_START_DATE '    ||l_cc_start_date
   ||' CC_END_DATE '  ||l_cc_end_date
   ||' ORGANIZATION_NAME '  ||l_org_name
   ||' CC_ACCT_DATE '  ||l_account_date);

   Put_Debug_Msg( l_full_path,l_api_name||' Successfully completed');
 END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
     END IF;
     --Bug 3199488

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
     END IF;
     --Bug 3199488

   WHEN OTHERS THEN
       Put_Debug_Msg( l_full_path,l_api_name||' raised unhandled exception');

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       -- Bug 3199488
       IF ( g_unexp_level >= g_debug_level ) THEN
            FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
            FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
            FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
            FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       -- Bug 3199488

END Init_variables;

/* This procedure is calld from the execute BC and reinit version number of the CC */

PROCEDURE Reinit_version(
   x_return_status OUT NOCOPY VARCHAR2)
IS
 l_api_name                CONSTANT VARCHAR2(30)   := 'Reinit_version' ;

 CURSOR c_cc_data IS
    SELECT cc_version_num         ,
           cc_encmbrnc_status
     FROM igc_cc_headers
   WHERE cc_header_id = g_cc_header_id;

l_full_path           VARCHAR2(255) := g_path||'Reinit_version';

BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS ;
 IF g_debug_mode = 'Y'
 THEN
     Put_Debug_Msg( l_full_path,l_api_name||' started');
 END IF;

 OPEN c_cc_data;
 FETCH c_cc_data
 INTO g_cc_version_number,
      g_cc_enc_status;

 IF c_cc_data%NOTFOUND THEN

     CLOSE c_cc_data;
     message_token ('CC_HEADER_ID', g_cc_header_id);
     add_message ('IGC', 'IGC_CC_NOT_FOUND');
     RAISE FND_API.G_EXC_ERROR;

 END IF;

 CLOSE c_cc_data;

  wf_engine.SetItemAttrText   (g_itemtype,g_itemkey,'CC_VERSION_NUM',g_cc_version_number);
  wf_engine.SetItemAttrText   (g_itemtype,g_itemkey,'CC_ENCUMBRANCE_NEW_STATUS',g_cc_new_enc_status);

  IF g_debug_mode = 'Y'
  THEN
      Put_Debug_Msg( l_full_path,' New values: '||
                ' Version number: '||g_cc_version_number||
                ' NEw enc status: '||g_cc_new_enc_status);

      Put_Debug_Msg( l_full_path,l_api_name||' Successfully completed');
  END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
     END IF;
     --Bug 3199488

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
     END IF;
     --Bug 3199488

   WHEN OTHERS THEN
       Put_Debug_Msg( l_full_path,l_api_name||' raised unhandled exception');

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       -- Bug 3199488
       IF ( g_unexp_level >= g_debug_level ) THEN
            FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
            FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
            FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
            FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       -- Bug 3199488

END Reinit_version;


/* Procedure calls PO generation for a CC  */
PROCEDURE Generate_PO(
   x_return_status OUT NOCOPY VARCHAR2)
IS

l_api_name                CONSTANT VARCHAR2(30)   := 'Generate_PO' ;
l_return_status           VARCHAR2(1) ;
l_msg_count               NUMBER ;
l_msg_data                VARCHAR2(2000) ;

 l_full_path VARCHAR2(500) := g_path || 'Generate_PO';
BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS ;
 IF g_debug_mode = 'Y'
 THEN
     Put_Debug_Msg( l_full_path,l_api_name||' started');
 END IF;

 IGC_CC_PO_INTERFACE_PKG.Convert_Cc_To_Po
 ( p_api_version      => 1.0,
   x_return_status    => l_return_status,
   x_msg_count	      => l_msg_count,
   x_msg_data	      => l_msg_data,
   p_cc_header_id     => g_cc_header_id
 );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     IF g_debug_mode = 'Y'
     THEN
         Put_Debug_Msg( l_full_path,'Error during PO generation');
     END IF;
     raise FND_API.G_EXC_ERROR;
  END IF;

  IF g_debug_mode = 'Y'
  THEN
      Put_Debug_Msg( l_full_path,l_api_name||' Successfully completed');
  END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
     END IF;
     --Bug 3199488

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
     END IF;
     --Bug 3199488

   WHEN OTHERS THEN
       Put_Debug_Msg( l_full_path,l_api_name||' raised unhandled exception');

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       -- Bug 3199488
       IF ( g_unexp_level >= g_debug_level ) THEN
            FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
            FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
            FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
            FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       -- Bug 3199488

END Generate_PO;



/* Main procedure */
PROCEDURE Process_request(
   p_action        IN  VARCHAR2,
   x_return_status OUT NOCOPY VARCHAR2)
IS
 l_api_name                CONSTANT VARCHAR2(30)   := 'Process_request' ;
 l_return_status           VARCHAR2(1) ;
  l_full_path  VARCHAR2(500) := g_path || 'Process_request';

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  IF g_debug_mode = 'Y'
  THEN
      Put_Debug_Msg( l_full_path,l_api_name||' started');
  END IF;

  --Get parameters from the WF

  Get_Parameters(x_return_status =>l_return_status );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  END IF;

  --Generate appropriate statuses and states

  Generate_CC_Action(
        p_action        => p_action,
        x_return_status => l_return_status );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     raise FND_API.G_EXC_ERROR;
  END IF;

  --Apply changes to CC

  Update_CC(x_return_status =>l_return_status );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  END IF;

  --Check if we need to generate PO

  IF g_create_po_entries THEN

     Generate_PO(x_return_status =>l_return_status );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      raise FND_API.G_EXC_ERROR;
     END IF;
  END IF;

  --Create history record

  Create_History_Record(x_return_status =>l_return_status );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  END IF;

  --Applying new values to a WF process

  Set_Parameters(x_return_status =>l_return_status );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_ERROR;
  END IF;

  IF g_debug_mode = 'Y'
  THEN
      Put_Debug_Msg( l_full_path,l_api_name||' Successfully completed');
  END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
     END IF;
     --Bug 3199488

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
     END IF;
     --Bug 3199488

   WHEN OTHERS THEN
       Put_Debug_Msg( l_full_path,l_api_name||' raised unhandled exception');

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;

       -- Bug 3199488
       IF ( g_unexp_level >= g_debug_level ) THEN
            FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
            FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
            FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
            FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       -- Bug 3199488

END Process_request;


/* This procedure determines if WF process has to run executete BC or not */

PROCEDURE Set_BC_Parameter(
   x_return_status OUT NOCOPY VARCHAR2)
IS
l_api_name                CONSTANT VARCHAR2(30)   := 'Set_BC_Parameter' ;
l_return_status           VARCHAR2(1) ;
l_msg_count               NUMBER ;
l_msg_data                VARCHAR2(2000) ;
 l_full_path VARCHAR2(500) := g_path || 'Set_BC_Parameter';
BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS ;
 IF g_debug_mode = 'Y'
 THEN
     Put_Debug_Msg( l_full_path,l_api_name||' started');
 END IF;

 IGC_CC_BUDGETARY_CTRL_PKG.Check_Budgetary_Ctrl_On(
          p_api_version      => 1.0,
          x_return_status    => l_return_status,
          x_msg_count        => l_msg_count,
          x_msg_data         => l_msg_data,
          p_org_id           => g_org_id,
          p_sob_id           => g_sob_id,
          p_cc_state         => g_cc_state,
          x_encumbrance_on   => g_bc_reqired);

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     raise FND_API.G_EXC_ERROR;
  END IF;

  IF g_bc_reqired = FND_API.G_TRUE THEN
    g_bc_reqired := 'Y';
  ELSE
    g_bc_reqired := 'N';
  END IF;

  IF g_debug_mode = 'Y'
  THEN
      Put_Debug_Msg( l_full_path,'BC value for the contract parameters: '||g_bc_reqired);
  END IF;

  -- CBC CC Bug 2174147   17-Jan-2001 S Brewer  start(1)
  -- The follwing 2 IF statements set the g_bc_required variable to the
  -- wrong value. The above call to the IGC_CC_BUDGETARY_CTRL_PKG is enough to
  -- correctly set the variable g_bc_required.  That is the only call used
  -- when approving through the form IGCCENTR.fmb, so, to keep this consistent
  -- with manual approval, commenting out the following additional
  -- IF statements.

  --  IF (g_cc_state = 'CL' AND g_cc_enc_status='P')
  --    OR (g_cc_state = 'CT' AND g_cc_enc_status='C' ) THEN

  --     g_bc_reqired :='Y';   --Cancellation or Completion requred

  --  END IF;

  --  IF g_bc_reqired = 'Y' THEN
       --Can be reqired only if turned on
       /* Possible values of g_bc_reqired:
            'N' - not reqired,
            'Y' - reservation  */
  --     IF ( g_cc_state IN ('PR','CM')) AND g_cc_enc_status= 'N' OR g_cc_enc_status='T' THEN
  --       g_bc_reqired :='Y';   --Reservation requred
  --     ELSE
  --        g_bc_reqired :='N';
  --     END IF;
  --  END IF;

  -- CBC CC Bug 2174147   17-Jan-2001 S Brewer  end(1)

  IF g_debug_mode = 'Y'
  THEN
      Put_Debug_Msg( l_full_path,'Final BC value : '||g_bc_reqired||' CC state '||g_cc_state||' enc status '||g_cc_enc_status);

      Put_Debug_Msg( l_full_path,l_api_name||' Successfully completed');
  END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
     END IF;
     --Bug 3199488

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
     END IF;
     --Bug 3199488

   WHEN OTHERS THEN
       Put_Debug_Msg( l_full_path,l_api_name||' raised unhandled exception');

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       -- Bug 3199488
       IF ( g_unexp_level >= g_debug_level ) THEN
            FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
            FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
            FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
            FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       -- Bug 3199488

END Set_BC_Parameter;

/* Procedure creates a recorn in the history table */
PROCEDURE Create_History_Record(
   x_return_status OUT NOCOPY VARCHAR2)
IS
l_api_name                CONSTANT VARCHAR2(30)   := 'Create_History_Record' ;
l_return_status           VARCHAR2(1) ;
l_msg_count               NUMBER ;
l_msg_data                VARCHAR2(2000) ;
l_rowid		          VARCHAR2(30);

 l_full_path VARCHAR2(500) := g_path || 'Create_History_Record';
BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS ;
  IF g_debug_mode = 'Y'
  THEN
      Put_Debug_Msg( l_full_path,l_api_name||' started');
  END IF;

  IGC_CC_ACTIONS_PKG.Insert_Row
   ( p_api_version               => 1.0,
     x_return_status             => l_return_status,
     x_msg_count                 => l_msg_count,
     x_msg_data                  => l_msg_data,
     p_rowid			 => l_rowid,
     p_cc_header_id              => g_cc_header_id,
     p_cc_action_version_num     => g_cc_version_number,
     p_cc_action_type            => g_cc_action_type,
     p_cc_action_state           => g_cc_new_state,
     p_cc_action_ctrl_status     => g_cc_ctrl_status,
     p_cc_action_apprvl_status   => g_cc_new_appr_status,
     p_cc_action_notes           => g_action_notes,
     p_last_update_date          => sysdate,
     p_last_updated_by           => fnd_global.user_id,
     p_last_update_login         => fnd_global.login_id,
     p_creation_date             => sysdate,
     p_created_by                => fnd_global.user_id
   );

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     IF g_debug_mode = 'Y'
     THEN
         Put_Debug_Msg( l_full_path,'Error during history record insertion');
     END IF;
     raise FND_API.G_EXC_ERROR;
  END IF;

  IF g_debug_mode = 'Y'
  THEN
      Put_Debug_Msg( l_full_path,l_api_name||' Successfully completed');
  END IF;


EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
     END IF;
     --Bug 3199488

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
     END IF;
     --Bug 3199488

   WHEN OTHERS THEN
       Put_Debug_Msg( l_full_path,l_api_name||' raised unhandled exception');

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       -- Bug 3199488
       IF ( g_unexp_level >= g_debug_level ) THEN
            FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
            FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
            FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
            FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       -- Bug 3199488

END Create_History_Record;


/* Procedure update CC with the new statuses  */

PROCEDURE Update_CC(
   x_return_status OUT NOCOPY VARCHAR2)
   IS
l_api_name                CONSTANT VARCHAR2(30)   := 'Update_CC' ;
CURSOR c_update_cc IS
    SELECT cc_state               ,
           cc_encmbrnc_status     ,
           cc_apprvl_status
     FROM igc_cc_headers
    WHERE cc_header_id = g_cc_header_id
     FOR UPDATE;

 l_return_status           VARCHAR2(1) ;
 l_msg_count               NUMBER ;
 l_msg_data                VARCHAR2(2000) ;

 l_full_path VARCHAR2(500) := g_path || 'Update_CC';

BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS ;
 IF g_debug_mode = 'Y'
 THEN
     Put_Debug_Msg( l_full_path,l_api_name||' started');
 END IF;

 FOR c_update_cc_rec IN c_update_cc LOOP
    UPDATE igc_cc_headers
       SET cc_state           = g_cc_new_state,
           cc_encmbrnc_status = g_cc_new_enc_status,
           cc_apprvl_status   = g_cc_new_appr_status,
           last_update_date   = sysdate,
           last_updated_by    = fnd_global.user_id,
           last_update_login  = fnd_global.login_id
     WHERE CURRENT OF  c_update_cc;
     IF SQL%ROWCOUNT <>1 THEN
        message_token ('CC_HEADER_ID', g_cc_header_id);
        add_message ('IGC', 'IGC_CC_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
     END IF;
 END LOOP;

 IF g_restore_enc THEN

   IF g_debug_mode = 'Y'
   THEN
       Put_Debug_Msg( l_full_path,'Restoring enc status');
   END IF;

   IGC_CC_BUDGETARY_CTRL_PKG.Set_Encumbrance_Status
   ( p_api_version              => 1.0,
     x_return_status            => l_return_status,
     x_msg_count                => l_msg_count,
     x_msg_data                 => l_msg_data,
     p_cc_header_id             => g_cc_header_id,
     p_encumbrance_status_code  => 'P');


    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF g_debug_mode = 'Y'
        THEN
             Put_Debug_Msg( l_full_path,'IGC_CC_BUDGETARY_CTRL_PKG.Set_Encumbrance_Status returned error ');
        END IF;
        raise FND_API.G_EXC_ERROR;
    END IF;

  END IF;

  IF g_debug_mode = 'Y'
  THEN
      Put_Debug_Msg( l_full_path,l_api_name||'Successfully completed');
  END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
     END IF;
     --Bug 3199488

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
     END IF;
     --Bug 3199488

   WHEN OTHERS THEN
       Put_Debug_Msg( l_full_path,l_api_name||' raised unhandled exception');

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       -- Bug 3199488
       IF ( g_unexp_level >= g_debug_level ) THEN
            FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
            FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
            FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
            FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       -- Bug 3199488

END Update_CC;

/* Procedure gets business group id*/

PROCEDURE Get_Business_Group(
   x_return_status OUT NOCOPY VARCHAR2)
IS
l_api_name                CONSTANT VARCHAR2(30)   := 'Get_Business_Group' ;
 l_full_path VARCHAR2(500) := g_path || 'Get_Business_Group';

CURSOR c_bg IS
    SELECT business_group_id
      FROM financials_system_parameters;


-- CBC CC Bug 2111529   07-Feb-2001 S Brewer  Start(3)
-- Cursor to find value in use approval hierarchies flag
CURSOR c_use_positions IS
  SELECT use_positions_flag
  FROM   financials_system_parameters;

  l_use_positions VARCHAR2(1);
-- CBC CC Bug 2111529   07-Feb-2001 S Brewer  End(3)


CURSOR c_hierarchy_id IS
    SELECT pos_structure_version_id
      FROM per_pos_structure_versions
     WHERE position_structure_id =
     ( SELECT default_approval_path_id
         FROM igc_cc_routing_ctrls
        WHERE org_id       = g_org_id
              AND cc_type  = g_cc_type
              AND cc_state = g_cc_state
     )
     AND sysdate
         BETWEEN NVL(date_from,sysdate)  AND NVL(date_to,sysdate);

BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS ;
 IF g_debug_mode = 'Y'
 THEN
     Put_Debug_Msg( l_full_path,l_api_name||' started');
 END IF;

 OPEN c_bg;
 FETCH c_bg INTO g_business_group_id;
 CLOSE c_bg;


  -- CBC CC Bug 2111529   07-Feb-2001 S Brewer  Start(4)
  -- Only need to get the position structure if using approval hierarchies
  OPEN c_use_positions;
  FETCH c_use_positions INTO l_use_positions;
  CLOSE c_use_positions;

  g_use_approval_hier := nvl(l_use_positions,'N');
  IF (g_use_approval_hier = 'Y') THEN


    OPEN c_hierarchy_id;
    FETCH c_hierarchy_id INTO g_pos_structure_version_id;
    CLOSE c_hierarchy_id;

    IF (g_pos_structure_version_id IS NULL) THEN

      -- The Use Approval hierarchies option has been chosen, but no position
      -- hierarchy has been assigned to this document type
      message_token('CC_TYPE',g_cc_type);
      message_token('CC_STATE',g_cc_state);
      add_message('IGC','IGC_NO_POS_HIER');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;
  -- CBC CC Bug 2111529   07-Feb-2001 S Brewer  End(4)


 IF g_debug_mode = 'Y'
 THEN
     Put_Debug_Msg( l_full_path,l_api_name||' Successfully completed');
 END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
     END IF;
     --Bug 3199488

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
     END IF;
     --Bug 3199488

   WHEN OTHERS THEN
       Put_Debug_Msg( l_full_path,l_api_name||' raised unhandled exception');

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       -- Bug 3199488
       IF ( g_unexp_level >= g_debug_level ) THEN
            FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
            FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
            FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
            FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       -- Bug 3199488

END Get_Business_Group;


/* Procedure gets business group id*/
PROCEDURE Find_Next_Approver(
   x_return_status OUT NOCOPY VARCHAR2)
   IS
l_api_name                CONSTANT VARCHAR2(30)   := 'Find_Next_Approver' ;
l_return_status           VARCHAR2(1) ;

l_approver_display_name    VARCHAR2(255);
l_cur_approver_id          NUMBER(15);
l_pos_id                   NUMBER(15);
l_new_pos_id               NUMBER(15);
l_job_id                   NUMBER(15);
l_new_job_id               NUMBER(15);
l_supervisor_id            NUMBER(15);
 l_full_path VARCHAR2(500) := g_path || 'Find_Next_Approver';

/* Find job/position, using person id*/
CURSOR c_user_pos_id IS
    SELECT position_id,
           job_id,
           supervisor_id
      FROM per_assignments_f
     WHERE person_id = g_approver_id
       AND business_group_id  = g_business_group_id
       AND sysdate BETWEEN effective_start_date
                   AND effective_end_date;

/* Find person, using position id*/
CURSOR c_pos_user_id (cpos_id NUMBER) IS
    SELECT pep.person_id
      FROM per_assignments_f  ass,
           per_all_people_f  pep
     WHERE position_id = cpos_id
       AND ass.person_id = pep.person_id
       AND ass.business_group_id  = g_business_group_id
       AND pep.business_group_id  = g_business_group_id
       AND sysdate BETWEEN ass.effective_start_date
                   AND ass.effective_end_date
     ORDER BY pep.full_name;

/* Find person, using job id*/
CURSOR c_job_user_id (cjob_id NUMBER) IS
    SELECT pep.person_id
      FROM per_assignments_f ass,
           per_all_people_f  pep
     WHERE job_id = cjob_id
       AND ass.person_id = pep.person_id
       AND ass.business_group_id  = g_business_group_id
       AND pep.business_group_id  = g_business_group_id
       AND sysdate BETWEEN ass.effective_start_date
                   AND ass.effective_end_date
     ORDER BY pep.full_name;


/* Find upper position id*/
CURSOR c_sub_pos_id (subpos_id NUMBER) IS
    SELECT parent_position_id
      FROM per_pos_structure_elements
     WHERE subordinate_position_id = subpos_id
       AND business_group_id  = g_business_group_id
       AND pos_structure_version_id =g_pos_structure_version_id;

BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS ;
 IF g_debug_mode = 'Y'
 THEN
     Put_Debug_Msg( l_full_path,l_api_name||' started');
 END IF;

 Get_Business_group(x_return_status =>l_return_status );

 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     raise FND_API.G_EXC_ERROR;
 END IF;

 --Looking for positions for current approver

 OPEN c_user_pos_id;
 FETCH c_user_pos_id INTO l_pos_id,l_job_id,l_supervisor_id;


 IF c_user_pos_id%NOTFOUND THEN
     CLOSE c_user_pos_id;
     message_token ('PERSON_ID', g_approver_id);
     message_token ('GROUP_ID', g_business_group_id);
     message_token ('DATE', sysdate);
     add_message ('IGC', 'IGC_ASSIGNMENT_NOT_FOUND');
     RAISE FND_API.G_EXC_ERROR;
 END IF;

 IF g_debug_mode = 'Y'
 THEN
     Put_Debug_Msg( l_full_path,'Getting data for the current approver: '||
                ' Approver id '|| g_approver_id||
                ' Position id '|| l_pos_id||
                ' Job id '|| l_job_id||
                ' Supervisor id '|| l_supervisor_id
                );
 END IF;

 CLOSE c_user_pos_id;


  -- CBC CC Bug 2111529   07-Feb-2001 S Brewer  Start(5)
  -- Want to use the 'Use Approval Hierarchies' flag instead

  IF (g_use_approval_hier = 'Y') THEN
  -- CBC CC Bug 2111529   07-Feb-2001 S Brewer  End(5)


     IF l_pos_id IS NOT NULL AND g_pos_structure_version_id IS NOT NULL THEN
       --Use position hierarchy
       IF g_debug_mode = 'Y'
       THEN
           Put_Debug_Msg( l_full_path,'Using position hierarchy');
       END IF;

       WHILE l_cur_approver_id IS NULL LOOP

         OPEN c_sub_pos_id(l_pos_id);
         FETCH c_sub_pos_id INTO l_new_pos_id;

         IF c_sub_pos_id%NOTFOUND THEN
           CLOSE c_sub_pos_id;
           message_token ('POSITION_ID', l_pos_id);
           message_token ('STRUCTURE_ID', g_pos_structure_version_id);
           message_token ('GROUP_ID', g_business_group_id);
           add_message ('IGC', 'IGC_PARENT_POS_NOT_FOUND');
           RAISE FND_API.G_EXC_ERROR;
         END IF;

         CLOSE c_sub_pos_id;

         IF g_debug_mode = 'Y'
         THEN
             Put_Debug_Msg( l_full_path,'Next position found: '||l_new_pos_id);
         END IF;

         OPEN c_pos_user_id(l_new_pos_id);
         FETCH c_pos_user_id INTO l_cur_approver_id;
         CLOSE c_pos_user_id;

         l_pos_id :=l_new_pos_id;

         IF g_debug_mode = 'Y'
         THEN
             Put_Debug_Msg( l_full_path,'Person for the position: '||NVL(to_char(l_cur_approver_id),' Not assigned'));
         END IF;

       END LOOP;
     ELSIF g_pos_structure_version_id IS NOT NULL THEN
       --Problem position hierarchy assigned for the CC, but no position for the person found
        message_token ('APPROVER_ID', g_approver_id);
        message_token ('STRUCTURE_ID', g_pos_structure_version_id);
        message_token ('GROUP_ID', g_business_group_id);
        add_message ('IGC', 'IGC_POS_STRUCTURE_NOT_FOUND');
        RAISE FND_API.G_EXC_ERROR;
      ELSE

        -- CBC CC Bug 2111529   07-Feb-2001 S Brewer  Start(6)
        -- The option 'Use Approval Hierarchies' has been chosen, but no
        -- position hierarchy has been assigned to this document type
        message_token('CC_TYPE',g_cc_type);
        message_token('CC_STATE',g_cc_state);
        add_message('IGC','IGC_NO_POS_HIER');
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    ELSIF (g_use_approval_hier = 'N') THEN

      -- CBC CC Bug 2111529   07-Feb-2001 S Brewer  End(6)
     IF g_debug_mode = 'Y'
     THEN
         Put_Debug_Msg( l_full_path,'Using job hierarchy');
     END IF;

     IF l_supervisor_id IS NULL THEN  --Problem - no position, no supervisor
         message_token ('APPROVER_ID', g_approver_id);
         message_token ('GROUP_ID', g_business_group_id);
         add_message ('IGC', 'IGC_SUPERVISOR_NOT_FOUND');
         RAISE FND_API.G_EXC_ERROR;
     END IF;
     l_cur_approver_id:= l_supervisor_id;
     IF g_debug_mode = 'Y'
     THEN
         Put_Debug_Msg( l_full_path,'Assigned approver: '||l_cur_approver_id);
     END IF;
 END IF;


 g_approver_id:= l_cur_approver_id;

 WF_DIRECTORY.GetUserName('PER',
                          g_approver_id,
                          g_approver_name,
		          l_approver_display_name);


   IF g_debug_mode = 'Y'
   THEN
       Put_Debug_Msg( l_full_path,l_api_name||' Successfully completed');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
     END IF;
     --Bug 3199488

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
     END IF;
     --Bug 3199488

   WHEN OTHERS THEN
       Put_Debug_Msg( l_full_path,l_api_name||' raised unhandled exception');

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       -- Bug 3199488
       IF ( g_unexp_level >= g_debug_level ) THEN
            FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
            FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
            FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
            FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       -- Bug 3199488

END Find_Next_Approver;



/* Procedure checks authority of the particular position or group */

PROCEDURE Check_Authority(
  p_result        OUT NOCOPY VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2)
IS

l_api_name                CONSTANT VARCHAR2(30)   := 'Check_Authority' ;
l_return_status           VARCHAR2(1) ;

l_pos_structure_version_id NUMBER(15) := 65;
l_pos_id                   NUMBER(15);
l_job_id                   NUMBER(15);
l_control_group_id         igc_cc_control_groups.control_group_id%TYPE;
l_enabled_flag             igc_cc_control_groups.enabled_flag%TYPE;
l_active_date              igc_cc_control_groups.active_date%TYPE;
l_group_amount             igc_cc_control_groups.amount%TYPE;
l_total_amount             igc_cc_control_groups.amount%TYPE;
l_ccid_in_range            boolean;

TYPE control_rules_tbl_type IS TABLE OF igc_cc_control_rules%ROWTYPE
    INDEX BY BINARY_INTEGER;

l_control_rules_tbl control_rules_tbl_type;
l_total_accounts            NUMBER;
l_cur_account               NUMBER;
l_full_path VARCHAR2(500) := g_path || 'Check_Authority';

/* Find job/position, using person id*/
CURSOR c_user_pos_id IS
    SELECT position_id,
           job_id
      FROM per_assignments_f
     WHERE person_id = g_approver_id
       AND business_group_id  = g_business_group_id
       AND sysdate BETWEEN effective_start_date
                   AND effective_end_date;

CURSOR c_control_func_info IS
   SELECT control_group_id
    FROM igc_cc_control_functions
   WHERE sysdate BETWEEN NVL(start_date,sysdate-1) AND NVL(end_date,sysdate+1)
         AND ( (l_pos_id IS NOT NULL AND position_id = l_pos_id)
               OR  (l_job_id IS NOT NULL AND job_id = l_job_id)
             )
         AND cc_state = g_cc_state
         AND cc_type  = g_cc_type
         AND org_id = g_org_id ;

-- CBC CC Bug 2111529   07-Feb-2001 S Brewer  Start(7)
-- Cursor to find control group for the position (if position hierarchies
-- are being used)
CURSOR c_pos_cont_func_info(p_position_id igc_cc_control_functions.position_id%TYPE) IS
  SELECT control_group_id
  FROM   igc_cc_control_functions
  WHERE  sysdate BETWEEN nvl(start_date,sysdate) AND nvl(end_date,sysdate)
  AND    position_id = p_position_id
  AND    cc_state = g_cc_state
  AND    cc_type = g_cc_type
  AND    org_id = g_org_id;

-- CBC CC Bug 2111529   07-Feb-2001 S Brewer  End(7)



CURSOR c_control_rules_info IS
   SELECT control_rule_id                ,
          rule_type_code                 ,
          amount_limit                   ,
          segment1_low                   ,
          segment2_low                   ,
          segment3_low                   ,
          segment4_low                   ,
          segment5_low                   ,
          segment6_low                   ,
          segment7_low                   ,
          segment8_low                   ,
          segment9_low                   ,
          segment10_low                  ,
          segment11_low                  ,
          segment12_low                  ,
          segment13_low                  ,
          segment14_low                  ,
          segment15_low                  ,
          segment16_low                  ,
          segment17_low                  ,
          segment18_low                  ,
          segment19_low                  ,
          segment20_low                  ,
          segment21_low                  ,
          segment22_low                  ,
          segment23_low                  ,
          segment24_low                  ,
          segment25_low                  ,
          segment26_low                  ,
          segment27_low                  ,
          segment28_low                  ,
          segment29_low                  ,
          segment30_low                  ,
          segment1_high                  ,
          segment2_high                  ,
          segment3_high                  ,
          segment4_high                  ,
          segment5_high                  ,
          segment6_high                  ,
          segment7_high                  ,
          segment8_high                  ,
          segment9_high                  ,
          segment10_high                 ,
          segment11_high                 ,
          segment12_high                 ,
          segment13_high                 ,
          segment14_high                 ,
          segment15_high                 ,
          segment16_high                 ,
          segment17_high                 ,
          segment18_high                 ,
          segment19_high                 ,
          segment20_high                 ,
          segment21_high                 ,
          segment22_high                 ,
          segment23_high                 ,
          segment24_high                 ,
          segment25_high                 ,
          segment26_high                 ,
          segment27_high                 ,
          segment28_high                 ,
          segment29_high                 ,
          segment30_high
   FROM igc_cc_control_rules
  WHERE org_id                 = g_org_id
        AND control_group_id   = l_control_group_id;

CURSOR c_control_group_info IS
   SELECT enabled_flag       ,
          active_date        ,
          amount
   FROM igc_cc_control_groups
  WHERE org_id                 = g_org_id
        AND control_group_id   = l_control_group_id;


-- Performance Tuning, replaced view igc_cc_acct_lines_v
-- with igc_cc_acct_lines
-- Also replaced the following :-
--          cc_acct_comp_func_amt         amount
CURSOR c_cc_account_lines IS
   SELECT ccal.cc_acct_line_id               line_id,
          ccal.cc_charge_code_combination_id ccid,
          IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(ccal.cc_header_id,
                      NVL(ccal.cc_acct_entered_amt,0)) amount
     FROM igc_cc_acct_lines ccal
    WHERE ccal.cc_header_id = g_cc_header_id
    ORDER BY ccal.cc_acct_line_id;

-- Performance Tuning, replaced view igc_cc_acct_lines_v
-- with igc_cc_acct_lines
-- Also replaced the following :-
--   SELECT SUM(cc_acct_comp_func_amt)
CURSOR c_total_amount IS
     SELECT SUM(IGC_CC_COMP_AMT_PKG.COMPUTE_FUNCTIONAL_AMT(ccal.cc_header_id,
                     NVL(ccal.cc_acct_entered_amt,0)))
     FROM igc_cc_acct_lines ccal
    WHERE ccal.cc_header_id = g_cc_header_id;


CURSOR c_ccid_info (l_code_id NUMBER) IS
   SELECT segment1       ,
          segment2       ,
          segment3       ,
          segment4       ,
          segment5       ,
          segment6       ,
          segment7       ,
          segment8       ,
          segment9       ,
          segment10      ,
          segment11      ,
          segment12      ,
          segment13      ,
          segment14      ,
          segment15      ,
          segment16      ,
          segment17      ,
          segment18      ,
          segment19      ,
          segment20      ,
          segment21      ,
          segment22      ,
          segment23      ,
          segment24      ,
          segment25      ,
          segment26      ,
          segment27      ,
          segment28      ,
          segment29      ,
          segment30
     FROM gl_code_combinations
    WHERE code_combination_id = l_code_id;


BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS ;
 IF g_debug_mode = 'Y'
 THEN
     Put_Debug_Msg( l_full_path,l_api_name||' started');
 END IF;

 p_result:='N';

 Get_Business_group(x_return_status =>l_return_status );

 IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     raise FND_API.G_EXC_ERROR;
 END IF;

 --Looking for position/job for current approver

 IF g_debug_mode = 'Y'
 THEN
     Put_Debug_Msg( l_full_path,'Searching job/position');
 END IF;

 OPEN c_user_pos_id;
 FETCH c_user_pos_id INTO l_pos_id,l_job_id;

 IF c_user_pos_id%NOTFOUND THEN
     CLOSE c_user_pos_id;
     message_token ('PERSON_ID', g_approver_id);
     message_token ('GROUP_ID', g_business_group_id);
     message_token ('ACTIVE_DATE', sysdate);
     add_message ('IGC', 'IGC_ASSIGNMENT_NOT_FOUND');
     RAISE FND_API.G_EXC_ERROR;
 END IF;

 CLOSE c_user_pos_id;

 IF g_debug_mode = 'Y'
 THEN
     Put_Debug_Msg( l_full_path,'Position: '||l_pos_id||' job: '||l_job_id);
 END IF;

  -- Find the appropriate approval group for the job/position, status, state.

  IF g_debug_mode = 'Y'
  THEN
      Put_Debug_Msg( l_full_path,'Searching control group');
  END IF;


  -- CBC CC Bug 2111529   07-Feb-2001 S Brewer  Start(8)
  -- If position hierarchy is being used (determined by option
  -- 'Use approval hierarchies'), then we want to use a different
  -- cursor to find the control group for the position, not the job
  IF (g_use_approval_hier = 'N') THEN
    -- Use the original cursor

    OPEN c_control_func_info;
    FETCH c_control_func_info INTO l_control_group_id;

    IF (c_control_func_info%NOTFOUND) THEN
      --No group is assigned
      IF g_debug_mode = 'Y'
      THEN
          Put_Debug_Msg( l_full_path,'No control group assigned');
      END IF;
      CLOSE c_control_func_info;
      return;
    END IF;

    CLOSE c_control_func_info;

  ELSIF (g_use_approval_hier = 'Y') THEN

    OPEN c_pos_cont_func_info(l_pos_id);
    FETCH c_pos_cont_func_info INTO l_control_group_id;
    CLOSE c_pos_cont_func_info;

    IF g_debug_mode = 'Y'
    THEN
        Put_Debug_Msg( l_full_path,'g_use_approval_hier = '||g_use_approval_hier);
        Put_Debug_Msg( l_full_path,'Found control group '||l_control_group_id);
    END IF;

  END IF;
  -- CBC CC Bug 2111529   07-Feb-2001 S Brewer  End(8)


  OPEN  c_control_group_info;
  FETCH c_control_group_info
  INTO l_enabled_flag,
       l_active_date ,
       l_group_amount;

    IF g_debug_mode = 'Y'
    THEN
        Put_Debug_Msg( l_full_path,'Control group data: id '||l_control_group_id||' active date: '||l_active_date||' amount: '||l_group_amount);
    END IF;

  IF c_control_group_info%NOTFOUND THEN
     CLOSE c_control_group_info;
     message_token ('CONTROL_GROUP_ID', l_control_group_id);
     add_message ('IGC', 'IGC_CONTROL_GROUP_NOT_FOUND');
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  CLOSE c_control_group_info;

  -- Check the group enable flag and dates

  IF l_enabled_flag<>'Y' OR NVL(l_active_date,sysdate+1)<sysdate THEN
     -- Assigned gruop is expired or not enabled - return 'N'
     IF g_debug_mode = 'Y'
     THEN
         Put_Debug_Msg( l_full_path,'Group is disabled or expired, return N');
     END IF;
     return;
  END IF;


--c_control_group_info
--c_control_func_info
--c_control_rules_info

  -- Initalize rules for the record group

  l_total_accounts:=0;

  IF g_debug_mode = 'Y'
  THEN
      Put_Debug_Msg( l_full_path,'Initializing rules record');
  END IF;

  FOR c_control_rules_info_rec IN c_control_rules_info LOOP

    --Store all ranges for the grup into the PL/SQL table

    IF g_debug_mode = 'Y'
    THEN
       Put_Debug_Msg( l_full_path,'New rule found: '||c_control_rules_info_rec.control_rule_id);
    END IF;

    l_control_rules_tbl(l_total_accounts).control_rule_id:=c_control_rules_info_rec.control_rule_id;
    l_control_rules_tbl(l_total_accounts).rule_type_code:=c_control_rules_info_rec.rule_type_code;
    l_control_rules_tbl(l_total_accounts).amount_limit:=c_control_rules_info_rec.amount_limit;
    l_control_rules_tbl(l_total_accounts).segment1_low:=c_control_rules_info_rec.segment1_low;
    l_control_rules_tbl(l_total_accounts).segment2_low:=c_control_rules_info_rec.segment2_low;
    l_control_rules_tbl(l_total_accounts).segment3_low:=c_control_rules_info_rec.segment3_low;
    l_control_rules_tbl(l_total_accounts).segment4_low:=c_control_rules_info_rec.segment4_low;
    l_control_rules_tbl(l_total_accounts).segment5_low:=c_control_rules_info_rec.segment5_low;
    l_control_rules_tbl(l_total_accounts).segment6_low:=c_control_rules_info_rec.segment6_low;
    l_control_rules_tbl(l_total_accounts).segment7_low:=c_control_rules_info_rec.segment7_low;
    l_control_rules_tbl(l_total_accounts).segment8_low:=c_control_rules_info_rec.segment8_low;
    l_control_rules_tbl(l_total_accounts).segment9_low:=c_control_rules_info_rec.segment9_low;
    l_control_rules_tbl(l_total_accounts).segment10_low:=c_control_rules_info_rec.segment10_low;
    l_control_rules_tbl(l_total_accounts).segment11_low:=c_control_rules_info_rec.segment11_low;
    l_control_rules_tbl(l_total_accounts).segment12_low:=c_control_rules_info_rec.segment12_low;
    l_control_rules_tbl(l_total_accounts).segment13_low:=c_control_rules_info_rec.segment13_low;
    l_control_rules_tbl(l_total_accounts).segment14_low:=c_control_rules_info_rec.segment14_low;
    l_control_rules_tbl(l_total_accounts).segment15_low:=c_control_rules_info_rec.segment15_low;
    l_control_rules_tbl(l_total_accounts).segment16_low:=c_control_rules_info_rec.segment16_low;
    l_control_rules_tbl(l_total_accounts).segment17_low:=c_control_rules_info_rec.segment17_low;
    l_control_rules_tbl(l_total_accounts).segment18_low:=c_control_rules_info_rec.segment18_low;
    l_control_rules_tbl(l_total_accounts).segment19_low:=c_control_rules_info_rec.segment19_low;
    l_control_rules_tbl(l_total_accounts).segment20_low:=c_control_rules_info_rec.segment20_low;
    l_control_rules_tbl(l_total_accounts).segment21_low:=c_control_rules_info_rec.segment21_low;
    l_control_rules_tbl(l_total_accounts).segment22_low:=c_control_rules_info_rec.segment22_low;
    l_control_rules_tbl(l_total_accounts).segment23_low:=c_control_rules_info_rec.segment23_low;
    l_control_rules_tbl(l_total_accounts).segment24_low:=c_control_rules_info_rec.segment24_low;
    l_control_rules_tbl(l_total_accounts).segment25_low:=c_control_rules_info_rec.segment25_low;
    l_control_rules_tbl(l_total_accounts).segment26_low:=c_control_rules_info_rec.segment26_low;
    l_control_rules_tbl(l_total_accounts).segment27_low:=c_control_rules_info_rec.segment27_low;
    l_control_rules_tbl(l_total_accounts).segment28_low:=c_control_rules_info_rec.segment28_low;
    l_control_rules_tbl(l_total_accounts).segment29_low:=c_control_rules_info_rec.segment29_low;
    l_control_rules_tbl(l_total_accounts).segment30_low:=c_control_rules_info_rec.segment30_low;
    l_control_rules_tbl(l_total_accounts).segment1_high:=c_control_rules_info_rec.segment1_high;
    l_control_rules_tbl(l_total_accounts).segment2_high:=c_control_rules_info_rec.segment2_high;
    l_control_rules_tbl(l_total_accounts).segment3_high:=c_control_rules_info_rec.segment3_high;
    l_control_rules_tbl(l_total_accounts).segment4_high:=c_control_rules_info_rec.segment4_high;
    l_control_rules_tbl(l_total_accounts).segment5_high:=c_control_rules_info_rec.segment5_high;
    l_control_rules_tbl(l_total_accounts).segment6_high:=c_control_rules_info_rec.segment6_high;
    l_control_rules_tbl(l_total_accounts).segment7_high:=c_control_rules_info_rec.segment7_high;
    l_control_rules_tbl(l_total_accounts).segment8_high:=c_control_rules_info_rec.segment8_high;
    l_control_rules_tbl(l_total_accounts).segment9_high:=c_control_rules_info_rec.segment9_high;
    l_control_rules_tbl(l_total_accounts).segment10_high:=c_control_rules_info_rec.segment10_high;
    l_control_rules_tbl(l_total_accounts).segment11_high:=c_control_rules_info_rec.segment11_high;
    l_control_rules_tbl(l_total_accounts).segment12_high:=c_control_rules_info_rec.segment12_high;
    l_control_rules_tbl(l_total_accounts).segment13_high:=c_control_rules_info_rec.segment13_high;
    l_control_rules_tbl(l_total_accounts).segment14_high:=c_control_rules_info_rec.segment14_high;
    l_control_rules_tbl(l_total_accounts).segment15_high:=c_control_rules_info_rec.segment15_high;
    l_control_rules_tbl(l_total_accounts).segment16_high:=c_control_rules_info_rec.segment16_high;
    l_control_rules_tbl(l_total_accounts).segment17_high:=c_control_rules_info_rec.segment17_high;
    l_control_rules_tbl(l_total_accounts).segment18_high:=c_control_rules_info_rec.segment18_high;
    l_control_rules_tbl(l_total_accounts).segment19_high:=c_control_rules_info_rec.segment19_high;
    l_control_rules_tbl(l_total_accounts).segment20_high:=c_control_rules_info_rec.segment20_high;
    l_control_rules_tbl(l_total_accounts).segment21_high:=c_control_rules_info_rec.segment21_high;
    l_control_rules_tbl(l_total_accounts).segment22_high:=c_control_rules_info_rec.segment22_high;
    l_control_rules_tbl(l_total_accounts).segment23_high:=c_control_rules_info_rec.segment23_high;
    l_control_rules_tbl(l_total_accounts).segment24_high:=c_control_rules_info_rec.segment24_high;
    l_control_rules_tbl(l_total_accounts).segment25_high:=c_control_rules_info_rec.segment25_high;
    l_control_rules_tbl(l_total_accounts).segment26_high:=c_control_rules_info_rec.segment26_high;
    l_control_rules_tbl(l_total_accounts).segment27_high:=c_control_rules_info_rec.segment27_high;
    l_control_rules_tbl(l_total_accounts).segment28_high:=c_control_rules_info_rec.segment28_high;
    l_control_rules_tbl(l_total_accounts).segment29_high:=c_control_rules_info_rec.segment29_high;
    l_control_rules_tbl(l_total_accounts).segment30_high:=c_control_rules_info_rec.segment30_high;

    l_total_accounts :=l_total_accounts+1;
  END LOOP;

  IF l_total_accounts=0 THEN
    -- No ranges found - return 'Y'
    IF g_debug_mode = 'Y'
    THEN
        Put_Debug_Msg( l_full_path,'No ranges found, calculationg total amount');
    END IF;

      OPEN c_total_amount;
      FETCH c_total_amount INTO l_total_amount;
      CLOSE c_total_amount;

      IF g_debug_mode = 'Y'
      THEN
          Put_Debug_Msg( l_full_path,'Total CC amount is: '||l_total_amount);
      END IF;

      IF l_group_amount IS NOT NULL AND l_group_amount < NVL(l_total_amount,0) THEN
          IF g_debug_mode = 'Y'
          THEN
               Put_Debug_Msg( l_full_path,'Total amount exceeded : return N');
          END IF;
          p_result:='N';
          RETURN;
      END IF;

      IF g_debug_mode = 'Y'
      THEN
          Put_Debug_Msg( l_full_path,'Total amount passed : return Y');
      END IF;
      p_result:='Y';
      RETURN;
  END IF;

  -- Loop through all CC account lines

    IF g_debug_mode = 'Y'
    THEN
        Put_Debug_Msg( l_full_path,'Loop through cc accounts ');
    END IF;

  FOR c_cc_account_lines_rec IN c_cc_account_lines LOOP

     l_ccid_in_range := FALSE; -- Set flag not in range

     -- increase total amount
     l_total_amount:= NVL(l_total_amount,0) + NVL(c_cc_account_lines_rec.amount,0);

    IF g_debug_mode = 'Y'
    THEN
        Put_Debug_Msg( l_full_path,'  New line found: '||c_cc_account_lines_rec.line_id
                    ||' ccid: '||c_cc_account_lines_rec.ccid
                    ||' amount: '||c_cc_account_lines_rec.amount
                    ||' new total: '||l_total_amount);
    END IF;

     FOR c_ccid_info_rec  IN c_ccid_info(c_cc_account_lines_rec.ccid) LOOP

        IF g_debug_mode = 'Y'
        THEN
            Put_Debug_Msg( l_full_path,'  Loop through ranges ');
        END IF;

        -- Loop through ranges
        FOR l_cur_account IN 0..(l_total_accounts-1) LOOP

           -- Check if CCID in range

           IF
             Check_Segment( c_ccid_info_rec.segment1,
                            l_control_rules_tbl(l_cur_account).segment1_low,
                            l_control_rules_tbl(l_cur_account).segment1_high)
             AND
             Check_Segment( c_ccid_info_rec.segment2,
                            l_control_rules_tbl(l_cur_account).segment2_low,
                            l_control_rules_tbl(l_cur_account).segment2_high)

             AND
             Check_Segment( c_ccid_info_rec.segment3,
                            l_control_rules_tbl(l_cur_account).segment3_low,
                            l_control_rules_tbl(l_cur_account).segment3_high)
             AND
             Check_Segment( c_ccid_info_rec.segment4,
                            l_control_rules_tbl(l_cur_account).segment4_low,
                            l_control_rules_tbl(l_cur_account).segment4_high)
             AND
             Check_Segment( c_ccid_info_rec.segment5,
                            l_control_rules_tbl(l_cur_account).segment5_low,
                            l_control_rules_tbl(l_cur_account).segment5_high)
             AND
             Check_Segment( c_ccid_info_rec.segment6,
                            l_control_rules_tbl(l_cur_account).segment6_low,
                            l_control_rules_tbl(l_cur_account).segment6_high)
             AND
             Check_Segment( c_ccid_info_rec.segment7,
                            l_control_rules_tbl(l_cur_account).segment7_low,
                            l_control_rules_tbl(l_cur_account).segment7_high)
             AND
             Check_Segment( c_ccid_info_rec.segment8,
                            l_control_rules_tbl(l_cur_account).segment8_low,
                            l_control_rules_tbl(l_cur_account).segment8_high)
             AND
             Check_Segment( c_ccid_info_rec.segment9,
                            l_control_rules_tbl(l_cur_account).segment9_low,
                            l_control_rules_tbl(l_cur_account).segment9_high)
             AND
             Check_Segment( c_ccid_info_rec.segment10,
                            l_control_rules_tbl(l_cur_account).segment10_low,
                            l_control_rules_tbl(l_cur_account).segment10_high)
             AND
             Check_Segment( c_ccid_info_rec.segment11,
                            l_control_rules_tbl(l_cur_account).segment11_low,
                            l_control_rules_tbl(l_cur_account).segment11_high)
             AND
             Check_Segment( c_ccid_info_rec.segment12,
                            l_control_rules_tbl(l_cur_account).segment12_low,
                            l_control_rules_tbl(l_cur_account).segment12_high)
             AND
             Check_Segment( c_ccid_info_rec.segment13,
                            l_control_rules_tbl(l_cur_account).segment13_low,
                            l_control_rules_tbl(l_cur_account).segment13_high)
             AND
             Check_Segment( c_ccid_info_rec.segment14,
                            l_control_rules_tbl(l_cur_account).segment14_low,
                            l_control_rules_tbl(l_cur_account).segment14_high)
             AND
             Check_Segment( c_ccid_info_rec.segment15,
                            l_control_rules_tbl(l_cur_account).segment15_low,
                            l_control_rules_tbl(l_cur_account).segment15_high)
             AND
             Check_Segment( c_ccid_info_rec.segment16,
                            l_control_rules_tbl(l_cur_account).segment16_low,
                            l_control_rules_tbl(l_cur_account).segment16_high)
             AND
             Check_Segment( c_ccid_info_rec.segment17,
                            l_control_rules_tbl(l_cur_account).segment17_low,
                            l_control_rules_tbl(l_cur_account).segment17_high)
             AND
             Check_Segment( c_ccid_info_rec.segment18,
                            l_control_rules_tbl(l_cur_account).segment18_low,
                            l_control_rules_tbl(l_cur_account).segment18_high)
             AND
             Check_Segment( c_ccid_info_rec.segment19,
                            l_control_rules_tbl(l_cur_account).segment19_low,
                            l_control_rules_tbl(l_cur_account).segment19_high)
             AND
             Check_Segment( c_ccid_info_rec.segment20,
                            l_control_rules_tbl(l_cur_account).segment20_low,
                            l_control_rules_tbl(l_cur_account).segment20_high)
             AND
             Check_Segment( c_ccid_info_rec.segment21,
                            l_control_rules_tbl(l_cur_account).segment21_low,
                            l_control_rules_tbl(l_cur_account).segment21_high)
             AND
             Check_Segment( c_ccid_info_rec.segment22,
                            l_control_rules_tbl(l_cur_account).segment22_low,
                            l_control_rules_tbl(l_cur_account).segment22_high)
             AND
             Check_Segment( c_ccid_info_rec.segment23,
                            l_control_rules_tbl(l_cur_account).segment23_low,
                            l_control_rules_tbl(l_cur_account).segment23_high)
             AND
             Check_Segment( c_ccid_info_rec.segment24,
                            l_control_rules_tbl(l_cur_account).segment24_low,
                            l_control_rules_tbl(l_cur_account).segment24_high)
             AND
             Check_Segment( c_ccid_info_rec.segment25,
                            l_control_rules_tbl(l_cur_account).segment25_low,
                            l_control_rules_tbl(l_cur_account).segment25_high)
             AND
             Check_Segment( c_ccid_info_rec.segment26,
                            l_control_rules_tbl(l_cur_account).segment26_low,
                            l_control_rules_tbl(l_cur_account).segment26_high)
             AND
             Check_Segment( c_ccid_info_rec.segment27,
                            l_control_rules_tbl(l_cur_account).segment27_low,
                            l_control_rules_tbl(l_cur_account).segment27_high)
             AND
             Check_Segment( c_ccid_info_rec.segment28,
                            l_control_rules_tbl(l_cur_account).segment28_low,
                            l_control_rules_tbl(l_cur_account).segment28_high)
             AND
             Check_Segment( c_ccid_info_rec.segment29,
                            l_control_rules_tbl(l_cur_account).segment29_low,
                            l_control_rules_tbl(l_cur_account).segment29_high)
             AND
             Check_Segment( c_ccid_info_rec.segment30,
                            l_control_rules_tbl(l_cur_account).segment30_low,
                            l_control_rules_tbl(l_cur_account).segment30_high)
             THEN

               IF g_debug_mode = 'Y'
               THEN
                   Put_Debug_Msg( l_full_path,'    Line in the range id: '||l_control_rules_tbl(l_cur_account).control_rule_id);
                   Put_Debug_Msg( l_full_path,'    type:'||l_control_rules_tbl(l_cur_account).rule_type_code);
                   Put_Debug_Msg( l_full_path,'    limit before: '||l_control_rules_tbl(l_cur_account).amount_limit);
               END IF;

               -- Check if range type in exclude or include
               IF l_control_rules_tbl(l_cur_account).rule_type_code = 'EXCLUDE' THEN
                  -- Exclude: Return N
                  IF g_debug_mode = 'Y'
                  THEN
                      Put_Debug_Msg( l_full_path,'    Range type exclude, return N');
                  END IF;
                  return;
               END IF;

               -- Include: Decrease the range amount
               l_control_rules_tbl(l_cur_account).amount_limit:=NVL(l_control_rules_tbl(l_cur_account).amount_limit,0) - NVL(c_cc_account_lines_rec.amount,0);

               -- Check if amount is still not negative
               IF l_control_rules_tbl(l_cur_account).amount_limit <0 THEN
                 IF g_debug_mode = 'Y'
                 THEN
                      Put_Debug_Msg( l_full_path,'    Amount exceeded, return N');
                  END IF;
                  --Maxmum limit for line exeeded
                  return;
               END IF;

               -- Set flag in range
               l_ccid_in_range := TRUE;

           END IF;

        END LOOP;  -- End range loop

     END LOOP; --end CCID LOOP (only one value should be returne by the cursor)

     -- Check if CCID was in the range
     IF NOT l_ccid_in_range THEN
        IF g_debug_mode = 'Y'
        THEN
            Put_Debug_Msg( l_full_path,'  Line not in the range, return N');
        END IF;
        -- Not in the range - Return 'N'
        return;
     END IF;

   END LOOP; --End account lines loop


   -- Check if group has total amount
   -- Check document total amount

    IF g_debug_mode = 'Y'
    THEN
       Put_Debug_Msg( l_full_path,'Checking total amount');
    END IF;
   IF l_group_amount IS NOT NULL AND l_group_amount < l_total_amount THEN
      IF g_debug_mode = 'Y'
      THEN
          Put_Debug_Msg( l_full_path,'Total amount exceeded, return N');
      END IF;
      -- Amount exceeded - return 'N'
      return;
   END IF;

   p_result:='Y'; --Has authority

    IF g_debug_mode = 'Y'
    THEN
        Put_Debug_Msg( l_full_path,l_api_name||' Successfully completed, return Y');
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
     END IF;
     --Bug 3199488

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
     END IF;
     --Bug 3199488

   WHEN OTHERS THEN
       Put_Debug_Msg( l_full_path,l_api_name||' raised unhandled exception');

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       -- Bug 3199488
       IF ( g_unexp_level >= g_debug_level ) THEN
            FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
            FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
            FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
            FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       -- Bug 3199488

END Check_Authority;

PROCEDURE message_token(
   tokname IN VARCHAR2,
   tokval  IN VARCHAR2
) IS

BEGIN

  IGC_MSGS_PKG.message_token (p_tokname => tokname,
                              p_tokval  => tokval);

END message_token;


/****************************************************************************/

-- Sets the Message Stack

PROCEDURE add_message(
   appname IN VARCHAR2,
   msgname IN VARCHAR2
) IS

i  BINARY_INTEGER;

   l_full_path VARCHAR2(500) := g_path || 'add_message';
BEGIN
   IGC_MSGS_PKG.add_message (p_appname => appname,
                             p_msgname => msgname);
    IF g_debug_mode = 'Y'
    THEN
        Put_Debug_Msg( l_full_path,'Raising an execution exception: '||fnd_msg_pub.get(1,FND_API.G_FALSE));
    END IF;

END add_message;

PROCEDURE Put_Debug_Msg (
   p_path IN VARCHAR2,
   p_debug_msg IN VARCHAR2
) IS

-- Constants :

   /*l_return_status    VARCHAR2(1);
   l_api_name         CONSTANT VARCHAR2(30) := 'Put_Debug_Msg';*/

BEGIN

--   IF g_debug_init IS NULL THEN --Need to init debug
 -- FND_API.G_TRUE
--       IF wf_engine.GetItemAttrText(g_itemtype,g_itemkey,'DEBUG_MODE') = 'T'
--  THEN
--          IGC_MSGS_PKG.g_debug_mode := TRUE;
--       ELSE
--          IGC_MSGS_PKG.g_debug_mode := FALSE;
--       END IF;
--       g_debug_init :='Y';
--   END IF;

      /*IGC_MSGS_PKG.Put_Debug_Msg ( p_debug_message    => p_debug_msg,
                                  p_profile_log_name => g_profile_name,
                                  p_prod             => NULL,
                                  p_sub_comp         => NULL,
                                  p_filename_val     => g_itemtype||'_'||g_itemkey||'.dbg',
                                  x_Return_Status    => l_return_status
                                 );
      IF (l_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
         raise FND_API.G_EXC_ERROR;
      END IF;*/

     --Bug 3199488
     IF(g_state_level >= g_debug_level) THEN
         FND_LOG.STRING(g_state_level, p_path, p_debug_msg);
     END IF;
     -- Bug 3199488

     RETURN;
-- --------------------------------------------------------------------
-- Exception handler section for the Put_Debug_Msg procedure.
-- --------------------------------------------------------------------
EXCEPTION

   /*WHEN FND_API.G_EXC_ERROR THEN
       RETURN;*/

   WHEN OTHERS THEN
       /*IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;*/
       NULL;
       RETURN;

END Put_Debug_Msg;



PROCEDURE Generate_Message
IS
l_cur                     NUMBER;
l_msg_count               NUMBER ;
l_msg_data                VARCHAR2(32000) ;

  l_full_path VARCHAR2(500) := g_path || 'Generate_Message';
BEGIN
  IF g_debug_mode = 'Y'
  THEN
      Put_Debug_Msg( l_full_path,'Error during the execution ');
  END IF;

  FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
                              p_data  => l_msg_data );

  IF l_msg_count >0 THEN
     g_error_text :='';

     FOR l_cur IN 1..l_msg_count LOOP
        g_error_text := g_error_text||' Mes No'||l_cur||' '||FND_MSG_PUB.GET(l_cur,FND_API.G_FALSE);
        --Bug 3199488
                 IF(g_excep_level >= g_debug_level) THEN
                        FND_LOG.STRING(g_excep_level, l_full_path,g_error_text);
                 END IF;
        --Bug 3199488
     END LOOP;
  ELSE
     g_error_text :='Error stack has no data';
  END IF;
  wf_engine.SetItemAttrText   (g_itemtype,g_itemkey,'ERROR_TEXT',g_error_text);

  IF g_debug_mode = 'Y'
  THEN
      Put_Debug_Msg( l_full_path,'Error text is '||g_error_text);
  END IF;

END Generate_Message;

FUNCTION Check_Segment(
   seg      VARCHAR2,
   seg_low  VARCHAR2,
   seg_high VARCHAR2)
RETURN BOOLEAN IS

BEGIN
   IF (seg IS NULL) OR (seg BETWEEN seg_low AND seg_high) THEN
     return TRUE;
   END IF;
   return FALSE;
END;

/* this procedure is used when we need to reject cancelled CC,
 it returns approval status before cancellation*/
FUNCTION Get_Last_App_status
RETURN VARCHAR2 IS
CURSOR c_app_status IS
  SELECT  cc_action_apprvl_status
    FROM igc_cc_actions
   WHERE (cc_header_id, cc_action_num)
         IN ( SELECT cc_header_id,max(cc_action_num)
                FROM igc_cc_actions
               WHERE cc_action_state ='PR'
                     AND  cc_header_id = g_cc_header_id
            GROUP BY cc_header_id) ;

l_app_status igc_cc_actions.cc_action_apprvl_status%TYPE;

BEGIN

  OPEN c_app_status;
 FETCH c_app_status INTO l_app_status;

 IF c_app_status%NOTFOUND THEN

    CLOSE c_app_status;

    message_token ('CC_NUMBER', g_cc_number);
    add_message ('IGC', 'IGC_PREV_STATE_NOT_FOUND');
    RAISE FND_API.G_EXC_ERROR;

 END IF;

 CLOSE c_app_status;

 RETURN l_app_status;

END Get_Last_App_status;

/* Procedure Checks supplier */

PROCEDURE Check_Supplier(
   x_return_status OUT NOCOPY VARCHAR2)
IS
l_api_name           CONSTANT VARCHAR2(30)   := 'Check_Supplier' ;
l_vendor_flag        VARCHAR2(1);

CURSOR c_sys_par IS
    SELECT enforce_vendor_hold_flag
      FROM igc_cc_system_options_all /*igc_cc_system_parameters*/
     WHERE org_id = g_org_id;


CURSOR c_cc_par IS
    SELECT hold_flag
      FROM po_vendors
     WHERE vendor_id =
           (SELECT vendor_id
              FROM igc_cc_headers
             WHERE cc_header_id = g_cc_header_id);

 l_full_path VARCHAR2(500):= g_path || 'Check_Supplier';
BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS ;
 IF g_debug_mode = 'Y'
 THEN
     Put_Debug_Msg( l_full_path,l_api_name||' started');
 END IF;

 OPEN c_sys_par;
 FETCH c_sys_par INTO l_vendor_flag;
 CLOSE c_sys_par;

 IF l_vendor_flag ='Y' THEN

    IF g_debug_mode = 'Y'
    THEN
        Put_Debug_Msg( l_full_path,'Setup option is Y, checking CC info..');
    END IF;

    l_vendor_flag :=NULL;

    OPEN c_cc_par;
    FETCH c_cc_par INTO l_vendor_flag;
    CLOSE c_cc_par;

    IF NVL(l_vendor_flag,'N') ='Y' AND g_cc_state IN ('PR','CM') THEN

       add_message ('IGC', 'IGC_CC_SUPPLIER_ON_HOLD_NO_APP');
       RAISE FND_API.G_EXC_ERROR;

    END IF;

    IF g_debug_mode = 'Y'
    THEN
        Put_Debug_Msg( l_full_path,'Done');
    END IF;

 END IF;

  IF g_debug_mode = 'Y'
  THEN
      Put_Debug_Msg( l_full_path,l_api_name||' Successfully completed');
  END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
     END IF;
     --Bug 3199488

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     --Bug 3199488
     IF ( g_excep_level >=  g_debug_level ) THEN
           FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
     END IF;
     --Bug 3199488

   WHEN OTHERS THEN
       Put_Debug_Msg( l_full_path,l_api_name||' raised unhandled exception');

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
       -- Bug 3199488
       IF ( g_unexp_level >= g_debug_level ) THEN
            FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
            FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
            FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
            FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
       END IF;
       -- Bug 3199488

END Check_Supplier;




END IGC_CC_APPROVAL_WF_PKG;



/
