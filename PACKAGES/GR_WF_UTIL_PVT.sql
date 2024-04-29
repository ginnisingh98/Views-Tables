--------------------------------------------------------
--  DDL for Package GR_WF_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_WF_UTIL_PVT" AUTHID CURRENT_USER AS
/*  $Header: GRWFUPTS.pls 120.2 2007/12/13 21:02:16 plowe ship $    */

/*  Global variables */
G_tmp	      CONSTANT BOOLEAN   := FND_MSG_PUB.Check_Msg_Level(0) ;  -- temp call to initialize the
						              -- msg level threshhold gobal
							      -- variable.
G_debug_level CONSTANT NUMBER := FND_MSG_PUB.G_Msg_Level_Threshold; -- Use this variable everywhere
							       -- to decide to log a debug msg.
G_PKG_NAME    CONSTANT varchar2(30) := 'GR_WF_UTIL_PVT';

g_log_head    CONSTANT VARCHAR2(50) := 'gr.plsql.'|| G_PKG_NAME || '.';

/*===========================================================================
--  PROCEDURE:
--    GET_ITEM_DETAILS
--
--  DESCRIPTION:
--    	This procedure will retrieve the Item Details based on the Inventory Item Id.
--      It will be called from the Regulatory Workflow Utilities Public API.
--
--  PARAMETERS:
--    p_orgn_id       IN  NUMBER            - Organization Id of an Item
--    p_item_id       IN  NUMBER            - Item Id of an Item
--    p_item_no       OUT NOCOPY  VARCHAR2  - Item Number of an Item
--    p_item_desc     OUT NOCOPY  VARCHAR2  - Item Description of an Item
--
--  SYNOPSIS:
--    GET_ITEM_DETAILS(p_orgn_id, p_item_id,l_item_no,l_item_desc);
--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--
--=========================================================================== */

	PROCEDURE GET_ITEM_DETAILS
    (p_orgn_id           IN         NUMBER,
     p_item_id           IN         NUMBER,
     p_item_no          OUT  NOCOPY VARCHAR2,
     p_item_desc        OUT  NOCOPY VARCHAR2);

/*===========================================================================
--  PROCEDURE:
--    GET_FORMULA_DETAILS
--
--  DESCRIPTION:
--    	This procedure will retrieve the Formula Details based on the Formula Id.
--      It will be called from the Regulatory Workflow Utilities Public API.
--
--  PARAMETERS:
--    p_formula_id        IN         NUMBER    - Formula Id of an Item
--    p_formula_no       OUT NOCOPY  VARCHAR2  - Formula Number of an Item
--    p_formula_vers     OUT NOCOPY  NUMBER    - Formula Vers of an Item
--
--  SYNOPSIS:
--    GET_FORMULA_DETAILS(p_formula_id,l_formula_no,l_formula_vers);
--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--
--=========================================================================== */

	PROCEDURE GET_FORMULA_DETAILS
    (p_formula_id        IN         NUMBER,
     p_formula_no       OUT  NOCOPY VARCHAR2,
     p_formula_vers     OUT  NOCOPY NUMBER  );

/*===========================================================================
--  PROCEDURE:
--    WF_INIT
--
--  DESCRIPTION:
--    	This procedure will initiate the Document Rebuild Required Workflow
--      when called from the Regulatory Workflow Utilities Public API.
--
--  PARAMETERS:
--    p_orgn_id       IN  NUMBER    - Organization ID of an Item
--    p_item_id       IN  NUMBER    - Item ID of an Item
--    p_item_no       IN  VARCHAR2  - Item Number of an Item
--    p_item_desc     IN  VARCHAR2  - Item Description of an Item
--    p_formula_no    IN  VARCHAR2  - Formula Number of an Item
--    p_formula_vers  IN  NUMBER    - Formula Description of an Item
--
--  SYNOPSIS:
--    WF_INIT(p_orgn_id, p_item_id, p_item_no,p_item_desc,p_formula_no,p_formula_vers);
--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--
--=========================================================================== */

	PROCEDURE WF_INIT
    (p_orgn_id           IN   NUMBER,
     p_item_id           IN   NUMBER,
	 p_item_no           IN   VARCHAR2,
     p_item_desc         IN   VARCHAR2,
     p_formula_no        IN   VARCHAR2 DEFAULT NULL,
     p_formula_vers      IN   NUMBER   DEFAULT NULL,
     p_user              IN   NUMBER);

/*===========================================================================
--  PROCEDURE:
--    GET_DEFAULT_ROLE
--
--  DESCRIPTION:
--    This function will return the Default User set for in AME for the respective transaction.
--    This will be used by Document Rebuild Required Workflow to determine the user the
--    notification will be sent to.
--
--  PARAMETERS:
--    P_transaction       IN  VARCHAR2          - Transaction Type for an Item
--    P_transactionId     IN  VARCHAR2          - Transaction Type Id for an Item
--
--  SYNOPSIS:
--    GET_DEFAULT_ROLE(P_transaction,P_transactionId);
--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--
--=========================================================================== */

    FUNCTION GET_DEFAULT_ROLE
    (P_transaction              IN             VARCHAR2,
     P_transactionId            IN             VARCHAR2)
    RETURN VARCHAR2;



/*===========================================================================
--  PROCEDURE:
--    CHECK_FOR_TECH_PARAM
--
--  DESCRIPTION:
--    This function will be called from the Regulatory Workflow Utilities Public API
--    to check if the Technical Parameter is used in Regulatory.
--
--  PARAMETERS:
--    P_tech_parm_name    IN  VARCHAR2          - Technical Parameter Name
--
--  SYNOPSIS:
--    l_check_for_tech_parm := CHECK_FOR_TECH_PARAM(p_tech_parm_name);
--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--
--=========================================================================== */

    FUNCTION CHECK_FOR_TECH_PARAM
    (p_tech_parm_name                 IN VARCHAR2)
    RETURN BOOLEAN;

/*===========================================================================
--  PROCEDURE:
--    IS_IT_PROP_OR_FORMULA_CHANGE
--
--  DESCRIPTION:
--    This function will be called from the Document Rebuild Required Workflow
--    to check if the Formula ot Item Change notification must be initiated.
--
--  PARAMETERS:
--    p_itemtype        VARCHAR2   -- type of the current item
--    p_itemkey         VARCHAR2   -- key of the current item
--    p_actid           NUMBER     -- process activity instance id
--    p_funcmode        VARCHAR2   -- function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--    p_resultout       VARCHAR2
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.
--
--  SYNOPSIS:
--    IS_IT_PROP_OR_FORMULA_CHANGE(p_itemtype, p_itemkey, p_actid, p_funcmode, l_resultout);
--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--
--=========================================================================== */


PROCEDURE IS_IT_PROP_OR_FORMULA_CHANGE(
      p_itemtype   IN         VARCHAR2,
      p_itemkey    IN         VARCHAR2,
      p_actid      IN         NUMBER,
      p_funcmode   IN         VARCHAR2,
      p_resultout  OUT NOCOPY VARCHAR2
	  );

/*===========================================================================
--  PROCEDURE:
--    SEND_OUTBOUND_DOCUMENT
--
--  DESCRIPTION:
--    This procedure will initiate the XML Outbound Message when called from the
--    Regulatory Workflow Utilities Public API.
--
--  PARAMETERS:
--    p_transaction_type       IN  VARCHAR2 - Transaction Type
--    p_transaction_subtype    IN  VARCHAR2 - Transaction SubType
--    p_document_id            IN  VARCHAR2 - Document Id
--    p_parameter1             IN  VARCHAR2 - Parameter 1
--    p_parameter2             IN  VARCHAR2 - Parameter 2
--	  p_parameter3             IN  VARCHAR2 - Parameter 3
--	  p_parameter4             IN  VARCHAR2 - Parameter 4
--	  p_parameter5             IN  VARCHAR2 - Parameter 5
--
--  SYNOPSIS:
--    SEND_OUTBOUND_DOCUMENT(p_transaction_type,p_transaction_subtype, p_document_id, p_parameter1,
--                         p_parameter2, p_parameter3, p_parameter4, p_parameter5);
--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--
--=========================================================================== */

    PROCEDURE SEND_OUTBOUND_DOCUMENT
    ( p_transaction_type       IN         VARCHAR2,
      p_transaction_subtype    IN         VARCHAR2,
      p_document_id            IN         VARCHAR2,
      p_parameter1             IN         VARCHAR2 DEFAULT NULL,
      p_parameter2             IN         VARCHAR2 DEFAULT NULL,
      p_parameter3             IN         VARCHAR2 DEFAULT NULL,
      p_parameter4             IN         VARCHAR2 DEFAULT NULL,
      p_parameter5             IN         VARCHAR2 DEFAULT NULL);

/*===========================================================================
--  PROCEDURE:
--    SEND_DOC_RBLD_OUTBND
--
--  DESCRIPTION:
--    This procedure will initiate the XML Outbound Message when called from the
--    Regulatory Workflow Utilities Public API.
--
--  PARAMETERS:
--    p_itemtype        VARCHAR2   -- type of the current item
--    p_itemkey         VARCHAR2   -- key of the current item
--    p_actid           NUMBER     -- process activity instance id
--    p_funcmode        VARCHAR2   -- function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--    p_resultout       VARCHAR2
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.
--
--  SYNOPSIS:
--    SEND_DOC_RBLD_OUTBND(p_itemtype, p_itemkey, p_actid, p_funcmode, l_resultout);
--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--
--=========================================================================== */

PROCEDURE SEND_DOC_RBLD_OUTBND    ( p_itemtype   IN         VARCHAR2,
                                    p_itemkey    IN         VARCHAR2,
                                    p_actid      IN         NUMBER,
                                    p_funcmode   IN         VARCHAR2,
                                    p_resultout  OUT NOCOPY VARCHAR2);

/*===========================================================================
--  PROCEDURE:
--    GetXMLTP
--
--  DESCRIPTION:
--      This procedure is used to set the Third Party Delivery details based
--      on Transaction Details.
--    	This procedure is called from 'GR Item Information Message' Workflow
--  PARAMETERS:
--    p_itemtype        VARCHAR2   -- type of the current item
--    p_itemkey         VARCHAR2   -- key of the current item
--    p_actid           NUMBER     -- process activity instance id
--    p_funcmode        VARCHAR2   -- function execution mode ('RUN', 'CANCEL', 'TIMEOUT', ...)
-- OUT
--    p_resultout       VARCHAR2
--       - COMPLETE[:<result>]
--           activity has completed with the indicated result
--       - WAITING
--           activity is waiting for additional transitions
--       - DEFERED
--           execution should be defered to background
--       - NOTIFIED[:<notification_id>:<assigned_user>]
--           activity has notified an external entity that this
--           step must be performed.  A call to wf_engine.CompleteActivty
--           will signal when this step is complete.  Optional
--           return of notification ID and assigned user.
--       - ERROR[:<error_code>]
--           function encountered an error.
--
--  SYNOPSIS:
--    GetXMLTP(p_itemtype, p_itemkey, p_actid, p_funcmode, l_resultout);
----
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--
--=========================================================================== */


PROCEDURE GetXMLTP        ( itemtype     IN	       VARCHAR2,
		                    itemkey      IN	       VARCHAR2,
		                    actid        IN	       NUMBER,
		                    funcmode     IN	       VARCHAR2,
	 	                    resultout    IN OUT NOCOPY VARCHAR2);

/*===========================================================================
--  PROCEDURE:
--    INIT_THRDPRTY_WF(P_message_icn NUMBER);
--
--  DESCRIPTION:
--    	This procedure will initiate the 3rd Party Property Change Workflow
--
--
--  SYNOPSIS:
--    INIT_THRDPRTY_WF;
--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--
--=========================================================================== */

	PROCEDURE INIT_THRDPRTY_WF(P_message_icn NUMBER);
/*===========================================================================
--  PROCEDURE:
--    THRDPRTY_INS
--
--  DESCRIPTION:
--    	This procedure will insert the details into gr_prop_chng_temp the details from the
--      third party property change inbound message.
--
--  PARAMETERS:
--    p_message_icn      IN  NUMBER    - Message Id of the request
--    p_orgn_id          IN  NUMBER    - Organization ID of an Item
--    p_item_code        IN  VARCHAR2  - Item Code
--    p_property_name    IN  VARCHAR2  - XML element (Label and property ID combination)
--    p_property_value   IN  VARCHAR2  - Field Name Value
--
--  SYNOPSIS:
--    THRDPRTY_INS(p_message_icn, p_orgn_id,p_item_code,p_property_name,p_property_value, p_session_id);
--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--=========================================================================== */

PROCEDURE THRDPRTY_INS (
    p_message_icn      IN  NUMBER,
    p_orgn_id          IN  NUMBER,
    p_item_code        IN  VARCHAR2,
    p_property_name    IN  VARCHAR2,
    p_property_value   IN  VARCHAR2);

/*===========================================================================
--  PROCEDURE:
--    LOG_MSG
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to create debug log for the Regulatory
--    Workflow Utilities Public API.
--
--  PARAMETERS:
--    p_msg_txt       IN  VARCHAR2          - Message Text
--
--  SYNOPSIS:
--    LOG_MSG(p_msg_text);
--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--
--=========================================================================== */

PROCEDURE log_msg(p_msg_text IN VARCHAR2);


/*===========================================================================
--  PROCEDURE:
--    ITEMS_REQUESTED_INS
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to create debug log for the Regulatory
--    Workflow Utilities Public API.
--
--  PARAMETERS:
--    p_message_icn    IN   NUMBER     - Message Id
--    p_orgn_id        IN   NUMBER     - Organizaion Id
--    p_from_item      IN   VARCHAR2   - From Item Code
--    p_to_item        IN   VARCHAR2   - To Item Code
--
--  SYNOPSIS:
--   ITEMS_REQUESTED_INS(p_message_icn , 1381, '8002', '8005');

--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--
--=========================================================================== */

PROCEDURE ITEMS_REQUESTED_INS(p_message_icn    IN   NUMBER,
                              p_orgn_id        IN   NUMBER,
                              p_from_item      IN   VARCHAR2,
                              p_to_item        IN   VARCHAR2);



/*===========================================================================
--  PROCEDURE:
--    WF_INIT_ITEM_INFO_REQ
--
--  DESCRIPTION:
--    	This procedure will initiate the Document Rebuild Required Workflow
--      when called from the Regulatory Workflow Utilities Public API.
--
--  PARAMETERS:
--    p_message_icn    IN   NUMBER     - Message Id

--  SYNOPSIS:
--    WF_INIT_ITEM_INFO_REQ(p_message_icn);
--
--  HISTORY
--    Mercy Thomas   31-Mar-2005  BUG 4276612 - Created.
--
--=========================================================================== */

PROCEDURE WF_INIT_ITEM_INFO_REQ
    (p_message_icn       IN   NUMBER);


/*===========================================================================
--  PROCEDURE:
--    APPS_INITIALIZE
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to initialize apps context from GRDDI.
--
--  PARAMETERS:
--    p_user_id       IN  NUMBER - User id
--
--  SYNOPSIS:
--    APPS_INITIALIZE(p_user_id);
--
--  HISTORY
--    Preetam Bamb   31-Mar-2005  Created.
--
--=========================================================================== */
PROCEDURE APPS_INITIALIZE( p_user_id IN NUMBER);

END GR_WF_UTIL_PVT;

/
