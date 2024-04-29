--------------------------------------------------------
--  DDL for Package XDPSTATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDPSTATUS" AUTHID CURRENT_USER AS
/* $Header: XDPSTATS.pls 120.1 2005/06/16 02:36:38 appldev  $ */

 e_NullValueException		EXCEPTION;


 x_ErrMsg			VARCHAR2(2000);
 x_DebugMsg			VARCHAR2(32767);

Procedure SetFActionStatus (OrderID in number,
                            LineItemID in number,
                            WorkitemInstanceID in number,
                            FAInstanceID in number,
                            Caller in varchar2,
                            Event in varchar2,
                            Status in varchar2,
                            ItemType in varchar2,
                            Itemkey in varchar2,
                            ErrCode OUT NOCOPY number,
                            ErrStr OUT NOCOPY varchar2);

Procedure SetWorkitemStatus (itemtype in varchar2,
                             itemkey in varchar2);

Procedure SetStatusforFA(FAInstanceID in number,
                         Status in varchar2,
                         Event in varchar2);

Procedure SetStatusforWI(WorkitemInstanceID in number,
                         Status in varchar2,
                         Event in varchar2);

Procedure SetStatusForLine (OrderID in number,
                            WorkitemInstanceID in number,
                            LineItemID in number,
                            Status in varchar2,
                            Event in varchar2);
/*
Procedure SetStatusforLine(LineItemID in number,
                         Status in varchar2,
                         Event in varchar2);
 */
Procedure SetStatusforOrder(OrderID in number,
                         Status in varchar2,
                         Event in varchar2);


--  SEND_FE_PROV_STATUS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure SEND_FE_PROV_STATUS (itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       OUT NOCOPY varchar2);



--  SEND_ORDER_STATUS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure SEND_ORDER_STATUS (itemtype        in varchar2,
                             itemkey         in varchar2,
                             actid           in number,
                             funcmode        in varchar2,
                             resultout       OUT NOCOPY varchar2);


--  SEND_LINE_STATUS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure SEND_LINE_STATUS (itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       OUT NOCOPY varchar2);



--  SEND_WORKITEM_STATUS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure SEND_WORKITEM_STATUS (itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       OUT NOCOPY varchar2);



--  SET_FA_STATUS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure SET_FA_STATUS (itemtype        in varchar2,
                         itemkey         in varchar2,
                         actid           in number,
                         funcmode        in varchar2,
                         resultout       OUT NOCOPY varchar2);



--  SET_FE_EXEC_STATUS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure SET_FE_EXEC_STATUS (itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       OUT NOCOPY varchar2);



--  SET_FE_PROV_STATE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure SET_FE_PROV_STATE (itemtype        in varchar2,
                             itemkey         in varchar2,
                             actid           in number,
                             funcmode        in varchar2,
                             resultout       OUT NOCOPY varchar2);



--  SET_ORDER_STATUS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure SET_ORDER_STATUS (itemtype        in varchar2,
                            itemkey         in varchar2,
                            actid           in number,
                            funcmode        in varchar2,
                            resultout       OUT NOCOPY varchar2);



--  SET_BUNDLE_STATUS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure SET_BUNDLE_STATUS (itemtype        in varchar2,
                             itemkey         in varchar2,
                             actid           in number,
                             funcmode        in varchar2,
                             resultout       OUT NOCOPY varchar2);


--  SET_LINE_STATUS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure SET_LINE_STATUS (itemtype        in varchar2,
                           itemkey         in varchar2,
                           actid           in number,
                           funcmode        in varchar2,
                           resultout       OUT NOCOPY varchar2);

--  SET_PACKAGE_STATUS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure SET_PACKAGE_STATUS (itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       OUT NOCOPY varchar2);


--  SET_WORKITEM_STATUS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure SET_WORKITEM_STATUS (itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       OUT NOCOPY varchar2);


--  SET_WI_STATUS_SUCCESS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure SET_WI_STATUS_SUCCESS (itemtype        in varchar2,
                                 itemkey         in varchar2,
                                 actid           in number,
                                 funcmode        in varchar2,
                                 resultout       OUT NOCOPY varchar2);


--  SAVE_WORKITEM
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure SAVE_WORKITEM (itemtype        in varchar2,
                         itemkey         in varchar2,
                         actid           in number,
                         funcmode        in varchar2,
                         resultout       OUT NOCOPY varchar2);

--  SET_XDP_ERROR
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure SET_ERROR_STATUS (itemtype        in varchar2,
                         itemkey         in varchar2,
                         actid           in number,
                         funcmode        in varchar2,
                         resultout       OUT NOCOPY varchar2);

--
-- Your Description here:

PROCEDURE UPDATE_XDP_ORDER_STATUS(p_status   IN VARCHAR2,
                                  p_order_id IN NUMBER);

-- Your Description here:

PROCEDURE UPDATE_XDP_ORDER_LINE_STATUS(p_status       IN VARCHAR2,
                                       p_line_item_id IN NUMBER);

--
-- Your Description here:

PROCEDURE UPDATE_XDP_WORKITEM_STATUS(p_status               IN VARCHAR2,
                                     p_workitem_instance_id IN NUMBER);

--
-- Your Description here:


PROCEDURE UPDATE_XDP_FA_STATUS(p_status         IN VARCHAR2,
                               p_fa_instance_id IN NUMBER);

--
-- Your Description here:


PROCEDURE UPDATE_XDP_ORDER_BUNDLE_STATUS(p_status    IN VARCHAR2,
                                         p_order_id  IN NUMBER,
                                         p_bundle_id IN NUMBER) ;


--  IS_ORDER_IN_ERROR
--   Resultout
--   TRUE/FALSE
--
-- Your Description here:

FUNCTION IS_ORDER_IN_ERROR(p_order_id IN NUMBER) RETURN BOOLEAN;

--  IS_LINE_IN_ERROR
--   Resultout
--   TRUE/FALSE
--
-- Your Description here:

FUNCTION IS_LINE_IN_ERROR(p_lineitem_id IN NUMBER) RETURN BOOLEAN;

--  IS_WI_IN_ERROR
--   Resultout
--   TRUE/FALSE
--
-- Your Description here:

FUNCTION IS_WI_IN_ERROR(p_WIInstance_id IN NUMBER) RETURN BOOLEAN;

--  IS_FA_IN_ERROR
--   Resultout
--   TRUE/FALSE
--
-- Your Description here:

FUNCTION IS_FA_IN_ERROR(p_FAInstance_id IN NUMBER) RETURN BOOLEAN;

--  GET_WI_STATUS
--   Returns
--   VARCHAR2
--
-- Returns the status of Workitem
-- 1)If any of the FAs are in ERROR it returns error.
-- 2)IF any of the FAS are in SYSTEM HOLD it returns System Hold.
-- 3)If some FAs or in ERROR and some FAs are in SYSTEM HOLD then it
--   returns ERROR.

FUNCTION GET_WI_STATUS(p_WIInstance_id IN NUMBER) RETURN VARCHAR2;


--  GET_LINE_STATUS
--   Returns
--   VARCHAR2
--
-- Returns the status of LINE
-- 1)If any of the WIs are in ERROR it returns error.
-- 2)IF any of the FAs are in SYSTEM HOLD it returns System Hold.
-- 3)If some FAs or in ERROR and some FAs are in SYSTEM HOLD then it
--   returns ERROR.

FUNCTION GET_LINE_STATUS(p_line_item_id IN NUMBER) RETURN VARCHAR2;

--  GET_ORDER_STATUS
--   Returns
--   VARCHAR2
--
-- Returns the status of ORDER
-- 1)If any of the LINEs are in ERROR it returns error.
-- 2)If any of the WIs are in ERROR it returns error.
-- 3)IF any of the FAs are in SYSTEM HOLD it returns System Hold.
-- 4)If some FAs or in ERROR and some FAs are in SYSTEM HOLD then it
--   returns ERROR.

FUNCTION GET_ORDER_STATUS( p_order_id IN NUMBER) RETURN VARCHAR2;

Procedure SET_NODE_WI_STATUS(itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       OUT NOCOPY varchar2 );

Procedure SET_NODE_LINE_STATUS(itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       OUT NOCOPY varchar2 );

End XDPSTATUS;

 

/
