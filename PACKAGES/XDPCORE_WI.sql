--------------------------------------------------------
--  DDL for Package XDPCORE_WI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDPCORE_WI" AUTHID CURRENT_USER AS
/* $Header: XDPCORWS.pls 120.2 2005/07/10 23:43:48 appldev noship $ */



 e_NullValueException		EXCEPTION;

 x_ErrMsg			VARCHAR2(2000);
 x_DebugMsg			VARCHAR2(2000);
 g_WIInstance_ID_in_Error       VARCHAR2(100);



cursor c_WIList (OrderID number, LineItemID number, prov_seq  number) is
  select WORKITEM_INSTANCE_ID, WORKITEM_ID, PRIORITY, WI_SEQUENCE
  from XDP_FULFILL_WORKLIST
  where ORDER_ID = OrderID
    and LINE_ITEM_ID = LineItemID
    and status_code = 'STANDBY'
    and WI_SEQUENCE = (
			select MIN(WI_SEQUENCE)
			from XDP_FULFILL_WORKLIST
			where ORDER_ID = OrderID
			  and LINE_ITEM_ID = LineItemID
                          and status_code = 'STANDBY'
			  and WI_SEQUENCE > prov_seq);


Procedure CreateWorkitemProcess (wftype in varchar2,
                                 parentitemtype in varchar2,
                                 parentitemkey in varchar2,
                                 itemtype in varchar2,
                                 itemkeyPrefix in varchar2,
                                 itemkey OUT NOCOPY varchar2,
                                 workflowprocessname in varchar2,
                                 OrderID in number,
                                 LineItemID in number,
                                 WorkitemID in number,
                                 WIInstanceID in number,
                                 WFMaster in varchar2,
                                 ErrCode OUT NOCOPY number,
                                 ErrStr OUT NOCOPY varchar2);


--  ARE_ALL_WIS_DONE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure ARE_ALL_WIS_DONE (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);




--  INITIALIZE_WI_LIST
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure INITIALIZE_WI_LIST (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);



--  CONTINUE_WORKITEM
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure CONTINUE_WORKITEM (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);


--  INITIALIZE_WORKITEM_PROCESS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure INITIALIZE_WORKITEM_PROCESS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);


--  LAUNCH_WORKITEM_PROCESS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure LAUNCH_WORKITEM_PROCESS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);


--  LAUNCH_WI_SEQ_PROCESS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure LAUNCH_WI_SEQ_PROCESS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);




--  LAUNCH_WI_SERVICE_PROCESS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure LAUNCH_WI_SERVICE_PROCESS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);

--Evaluate ALL WI Parameters for all Workitems at one go..
Procedure EVALUATE_ALL_WIS_PARAMS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);

--Evaluate WI parameters of a given WI
Procedure EVALUATE_WI_PARAMS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);

Procedure EvaluateWIParamsOnStart(WIInstanceID in number);

Function GET_WI_RESPONSIBILITY (itemtype        in varchar2,
                        itemkey         in varchar2 ) return varchar2;

Procedure GET_ONSTART_WI_PARAMS (itemtype        in varchar2,
                                 itemkey         in varchar2,
                                 actid           in number,
                                 funcmode        in varchar2,
                                 resultout       OUT NOCOPY varchar2 ) ;

Procedure LAUNCH_ALL_IND_WIS (itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       OUT NOCOPY varchar2 );


Procedure INITIALIZE_DEP_WI_PROCESS (itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       OUT NOCOPY varchar2 );


Procedure RESOLVE_IND_DEP_WIS (itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       OUT NOCOPY varchar2 );

Procedure OVERRIDE_WI_PARAM (itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       OUT NOCOPY varchar2 );

Function get_display_name( p_WIInstanceID IN NUMBER) return varchar2;

End XDPCORE_WI;

 

/
