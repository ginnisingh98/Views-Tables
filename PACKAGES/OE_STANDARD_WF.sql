--------------------------------------------------------
--  DDL for Package OE_STANDARD_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_STANDARD_WF" AUTHID CURRENT_USER as
/* $Header: OEXWSTDS.pls 120.0.12010000.1 2008/07/25 08:09:13 appldev ship $ */

G_PKG_NAME       CONSTANT VARCHAR2(30) := 'OE_STANDARD_WF';

-- This is a global that will be evaluated during the upgrade of OE cycle data
-- to WF in OM. It will be set to TRUE, ONLY by the upgrade process.
G_UPGRADE_MODE BOOLEAN DEFAULT FALSE;

-- This is a Global that determines whether the Save messages procedure will
-- save messages to the database. The caller (eg: Sales Order Form) can set
-- this to false, because he wants to manage the messages himself.
-- The default is set to TRUE so when the Background engine is in control
-- we will save the messages to the db.
G_SAVE_MESSAGES BOOLEAN DEFAULT TRUE;

-- This global determines whether we use the item attributes stored on the
-- Header/line wf item to reset application context. The default is TRUE as
-- in the case of the Background engine running stuff, we do need to set
-- context.  However in case of the Sales Order form calling the WF engine
-- the context is already set and we do not need to set it again.
G_RESET_APPS_CONTEXT BOOLEAN DEFAULT TRUE;

G_USER_ID NUMBER DEFAULT NULL;  -- 3169637

PROCEDURE UPGRADE_MODE_ON;

PROCEDURE SAVE_MESSAGES_ON;

PROCEDURE SAVE_MESSAGES_OFF;

PROCEDURE RESET_APPS_CONTEXT_ON;

PROCEDURE RESET_APPS_CONTEXT_OFF;

PROCEDURE SET_MSG_CONTEXT(P_PROCESS_ACTIVITY IN NUMBER DEFAULT NULL);

PROCEDURE CLEAR_MSG_CONTEXT;

PROCEDURE SAVE_MESSAGES(p_instance_id IN NUMBER DEFAULT NULL);

PROCEDURE STANDARD_BLOCK(
	itemtype   in varchar2,
	itemkey    in varchar2,
	actid      in number,
	funcmode   in varchar2,
	resultout  in out nocopy varchar2 /* file.sql.39 change */
);

PROCEDURE OEOH_SELECTOR
(   p_itemtype in  varchar2
,   p_itemkey  in  varchar2
,   p_actid    in  number
,   p_funcmode in  varchar2
,   p_result   in out nocopy varchar2 /* file.sql.39 change */
);

PROCEDURE OEOL_SELECTOR
(   p_itemtype in  varchar2
,   p_itemkey  in  varchar2
,   p_actid    in  number
,   p_funcmode in  varchar2
,   p_result   in out nocopy varchar2 /* file.sql.39 change */
);

PROCEDURE OENH_SELECTOR
(   p_itemtype in  varchar2
,   p_itemkey  in  varchar2
,   p_actid    in  number
,   p_funcmode in  varchar2
,   p_result   in out nocopy varchar2 /* file.sql.39 change */
);

PROCEDURE OEBH_SELECTOR
(   p_itemtype in  varchar2
,   p_itemkey  in  varchar2
,   p_actid    in  number
,   p_funcmode in  varchar2
,   p_result   in out nocopy varchar2 /* file.sql.39 change */
);

PROCEDURE Get_Supply_Source_Type
(   p_itemtype in  varchar2
,   p_itemkey  in  varchar2
,   p_actid    in  number
,   p_funcmode in  varchar2
,   p_result   in out nocopy varchar2 /* file.sql.39 change */
);

PROCEDURE Get_Line_Category
(   p_itemtype in  varchar2
,   p_itemkey  in  varchar2
,   p_actid    in  number
,   p_funcmode in  varchar2
,   p_result   in out nocopy varchar2 /* file.sql.39 change */
);
PROCEDURE Set_Exception_Message;

PROCEDURE Add_Error_Activity_Msg
(   p_actid IN NUMBER,
    p_itemkey IN VARCHAR2,
    p_itemtype IN VARCHAR2);

END OE_STANDARD_WF;

/
