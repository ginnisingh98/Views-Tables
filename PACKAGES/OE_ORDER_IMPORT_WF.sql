--------------------------------------------------------
--  DDL for Package OE_ORDER_IMPORT_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_ORDER_IMPORT_WF" AUTHID CURRENT_USER AS
/* $Header: OEXWFOIS.pls 120.1 2005/08/15 14:45:41 jjmcfarl noship $ */
G_PKG_NAME           VARCHAR2(30)           := 'OE_ORDER_IMPORT_WF';
G_WFR_NOT_ELIGIBLE   CONSTANT  VARCHAR2(30) := 'NOT_ELIGIBLE';
G_WFR_COMPLETE       CONSTANT  VARCHAR2(30) := 'COMPLETE';
G_WFR_INCOMPLETE     CONSTANT  VARCHAR2(30) := 'INCOMPLETE';
G_WFI_ORDER_IMPORT   CONSTANT  VARCHAR2(4)  := 'OEOI';
G_WFI_ORDER_ACK      CONSTANT  VARCHAR2(4)  := 'OEOA';
G_WFI_SHOW_SO        CONSTANT  VARCHAR2(4)  := 'OESO';
G_WFI_PROC           CONSTANT  VARCHAR2(4)  := 'PROC';
G_WFI_CONC_PGM       CONSTANT  VARCHAR2(4)  := 'CONC';
G_WFI_CANCEL_PO      CONSTANT  VARCHAR2(4)  := 'OECP';
G_WFI_IMPORT_PGM     CONSTANT  VARCHAR2(4)  := 'OIMP';

PROCEDURE OEOI_SELECTOR
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out NOCOPY /* file.sql.39 change */ varchar2
);

PROCEDURE OESO_SELECTOR
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out NOCOPY /* file.sql.39 change */ varchar2
);

PROCEDURE OEOA_SELECTOR
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out NOCOPY /* file.sql.39 change */ varchar2
);

PROCEDURE START_ORDER_IMPORT
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out NOCOPY /* file.sql.39 change */ varchar2
);

PROCEDURE IS_OI_COMPLETE
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out NOCOPY /* file.sql.39 change */ varchar2
);

PROCEDURE CALL_WF_PURGE
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2
);

PROCEDURE set_delivery_data
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out NOCOPY /* file.sql.39 change */ varchar2
);

PROCEDURE is_partner_setup
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out NOCOPY /* file.sql.39 change */ varchar2
);

PROCEDURE Process_Xml_Acknowledgment_Wf
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out NOCOPY /* file.sql.39 change */ varchar2
);

PROCEDURE Get_Activity_Result
(
        p_itemtype              in      varchar2
,       p_itemkey               in      varchar2
,       p_activity_name         in      varchar2
, x_return_status out nocopy varchar2

, x_activity_result out nocopy varchar2

, x_activity_status_code out nocopy varchar2

, x_activity_id out nocopy number

);

Procedure Raise_Event_Showso_Wf
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out NOCOPY /* file.sql.39 change */ varchar2
);

Procedure Set_User_Key
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out NOCOPY /* file.sql.39 change */ varchar2
);


Procedure Is_CBOD_Out_Reqd
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out NOCOPY /* file.sql.39 change */ varchar2
);

Procedure  Populate_CBOD_Out_Globals
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out NOCOPY /* file.sql.39 change */ varchar2
);

Procedure  Set_CBOD_EVENT_KEY
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out NOCOPY /* file.sql.39 change */ varchar2
);


Procedure Raise_Event_Xmlint_Wf
( p_itemtype   IN     Varchar2,
  p_itemkey    IN     Varchar2,
  p_actid      in     number,
  p_funcmode   IN     Varchar2,
  p_x_result   IN OUT NOCOPY /* file.sql.39 change */ Varchar2
);

Procedure Is_OAG_or_RosettaNet
( p_itemtype   IN     Varchar2,
  p_itemkey    IN     Varchar2,
  p_actid      in     number,
  p_funcmode   IN     Varchar2,
  p_x_result   IN OUT NOCOPY  Varchar2
);

END OE_ORDER_IMPORT_WF;

 

/
