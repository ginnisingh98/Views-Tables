--------------------------------------------------------
--  DDL for Package XDPCORE_LINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDPCORE_LINE" AUTHID CURRENT_USER AS
/* $Header: XDPCORLS.pls 120.1 2005/06/08 23:48:12 appldev  $ */



 e_NullValueException		EXCEPTION;




 x_ErrMsg			VARCHAR2(2000);
 x_DebugMsg			VARCHAR2(2000);


 cursor c_LineSeqNullBundle(OrderID number, LineSeq number) is
  select LINE_ITEM_ID, LINE_NUMBER, LINE_ITEM_NAME, IS_PACKAGE_FLAG, LINE_SEQUENCE ,
         IB_SOURCE , NVL(IB_SOURCE_ID,-999) IB_SOURCE_ID
  from XDP_ORDER_LINE_ITEMS
  where ORDER_ID = OrderID
   and status_code    = 'READY'
   and IS_VIRTUAL_LINE_FLAG = 'N'
   and BUNDLE_ID is null
   and LINE_SEQUENCE = (
                        select MIN(LINE_SEQUENCE)
                        from XDP_ORDER_LINE_ITEMS
                        where ORDER_ID = OrderID
                          and status_code    = 'READY'
                          and IS_VIRTUAL_LINE_FLAG = 'N'
                          and BUNDLE_ID is null
                          and LINE_SEQUENCE > LineSeq);

 cursor c_LineSeqForBundle(OrderID number, BundleID number, LineSeq number) is
  select LINE_ITEM_ID, LINE_NUMBER, LINE_ITEM_NAME, IS_PACKAGE_FLAG, LINE_SEQUENCE ,
         IB_SOURCE , NVL(IB_SOURCE_ID,-999) IB_SOURCE_ID
  from XDP_ORDER_LINE_ITEMS
  where ORDER_ID = OrderID
   and status_code    = 'READY'
   and IS_VIRTUAL_LINE_FLAG = 'N'
   and BUNDLE_ID = BundleID
   and LINE_SEQUENCE = (
                        select MIN(LINE_SEQUENCE)
                        from XDP_ORDER_LINE_ITEMS
                        where ORDER_ID = OrderID
                          and status_code    = 'READY'
                          and IS_VIRTUAL_LINE_FLAG = 'N'
                          and BUNDLE_ID = BundleID
                          and LINE_SEQUENCE > LineSeq);

 cursor c_LineSeq(OrderID number, LineSeq number) is
  select LINE_ITEM_ID, LINE_NUMBER, LINE_ITEM_NAME, IS_PACKAGE_FLAG, LINE_SEQUENCE,
         IB_SOURCE,NVL(IB_SOURCE_ID,-999) IB_SOURCE_ID
  from XDP_ORDER_LINE_ITEMS
  where ORDER_ID = OrderID
   and status_code    = 'READY'
   and IS_VIRTUAL_LINE_FLAG = 'N'
   and LINE_SEQUENCE = (
                        select MIN(LINE_SEQUENCE)
                        from XDP_ORDER_LINE_ITEMS
                        where ORDER_ID = OrderID
                          and status_code    = 'READY'
                          and IS_VIRTUAL_LINE_FLAG = 'N'
                          and LINE_SEQUENCE > LineSeq);

--  ARE_ALL_LINES_DONE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure ARE_ALL_LINES_DONE (itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       OUT NOCOPY varchar2);


--  LAUNCH_LINEITEM_PROCESS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure LAUNCH_LINEITEM_PROCESS (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);


--  INITIALIZE_LINE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure INITIALIZE_LINE (itemtype        in varchar2,
                             itemkey         in varchar2,
                             actid           in number,
                             funcmode        in varchar2,
                             resultout       OUT NOCOPY varchar2);

--  IS_LINE_A_PACKAGE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure IS_LINE_A_PACKAGE (itemtype        in varchar2,
			itemkey         in varchar2,
			actid           in number,
			funcmode        in varchar2,
			resultout       OUT NOCOPY varchar2);



--  LAUNCH_LINE_FOR_ORDER_PROCESS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure LAUNCH_LINE_FOR_ORDER_PROCESS (itemtype        in varchar2,
                                          itemkey         in varchar2,
                                          actid           in number,
                                          funcmode        in varchar2,
                                          resultout       OUT NOCOPY varchar2);

--  LAUNCH_SERVICE_PROCESS
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:


Procedure LAUNCH_SERVICE_PROCESS (itemtype        in varchar2,
                        itemkey         in varchar2,
                        actid           in number,
                        funcmode        in varchar2,
                        resultout       OUT NOCOPY varchar2);



Procedure UPDATE_INSTALL_BASE (itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       OUT NOCOPY varchar2);

Procedure LAUNCH_ALL_IND_LINES (itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       OUT NOCOPY varchar2);

Procedure INITIALIZE_DEP_LINE_PROCESS (itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       OUT NOCOPY varchar2);

Procedure RESOLVE_IND_DEP_LINES (itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       OUT NOCOPY varchar2);

Procedure IS_SER_PART_PACKAGE (itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       OUT NOCOPY varchar2);

-- ****************    PUBLISH_XDP_LINE_DONE  *********************

PROCEDURE PUBLISH_XDP_LINE_DONE
                     (itemtype      IN VARCHAR2,
                      itemkey       IN VARCHAR2,
                      actid         IN NUMBER,
                      funcmode      IN VARCHAR2,
                      resultout    OUT NOCOPY VARCHAR2) ;

End XDPCORE_LINE;

 

/
