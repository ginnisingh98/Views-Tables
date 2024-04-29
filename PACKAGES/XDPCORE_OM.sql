--------------------------------------------------------
--  DDL for Package XDPCORE_OM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDPCORE_OM" AUTHID CURRENT_USER AS
/* $Header: XDPCORMS.pls 120.1 2005/06/15 22:38:28 appldev  $ */


--  CREATE_FULFILLMENT_ORDER
--   Resultout
--     COMPLETE   - Activity was completed without any errors
--     INCOMPLETE   - Activity was incomplete
--
-- Your Description here:

-- ****************    CREATE_FULFILLMENT_ORDER   *********************

PROCEDURE CREATE_FULFILLMENT_ORDER
                     (itemtype      IN VARCHAR2,
                      itemkey       IN VARCHAR2,
                      actid         IN NUMBER,
                      funcmode      IN VARCHAR2,
                      resultout    OUT NOCOPY VARCHAR2);


-- ****************    WAIT_FOR_FULFILLMENT  *********************

PROCEDURE WAIT_FOR_FULFILLMENT
                     (itemtype      IN VARCHAR2,
                      itemkey       IN VARCHAR2,
                      actid         IN NUMBER,
                      funcmode      IN VARCHAR2,
                      resultout    OUT NOCOPY VARCHAR2);


-- ****************    IS_FULFILLMENT_COMPLETED  *********************

PROCEDURE IS_FULFILLMENT_COMPLETED
                     (itemtype      IN VARCHAR2,
                      itemkey       IN VARCHAR2,
                      actid         IN NUMBER,
                      funcmode      IN VARCHAR2,
                      resultout    OUT NOCOPY VARCHAR2);


-- ****************    PROVISION_LINE  *********************

PROCEDURE PROVISION_LINE
                     (itemtype      IN VARCHAR2,
                      itemkey       IN VARCHAR2,
                      actid         IN NUMBER,
                      funcmode      IN VARCHAR2,
                      resultout    OUT NOCOPY VARCHAR2);


-- ****************    LINE_FULFILLMENT_DONE  *********************

PROCEDURE LINE_FULFILLMENT_DONE
                     (itemtype      IN VARCHAR2,
                      itemkey       IN VARCHAR2,
                      actid         IN NUMBER,
                      funcmode      IN VARCHAR2,
                      resultout    OUT NOCOPY VARCHAR2);


-- ****************    UPDATE_TXN_DETAILS  *********************

PROCEDURE UPDATE_TXN_DETAILS
                     (itemtype      IN VARCHAR2,
                      itemkey       IN VARCHAR2,
                      actid         IN NUMBER,
                      funcmode      IN VARCHAR2,
                      resultout    OUT NOCOPY VARCHAR2);


-- ****************    UPDATE_OM_LINE_STATUS  *********************

PROCEDURE UPDATE_OM_LINE_STATUS
                     (itemtype      IN VARCHAR2,
                      itemkey       IN VARCHAR2,
                      actid         IN NUMBER,
                      funcmode      IN VARCHAR2,
                      resultout    OUT NOCOPY VARCHAR2);

-- ****************    START_FULFILLMENT_PROCESS  *********************

PROCEDURE START_FULFILLMENT_PROCESS
                (p_MESSAGE_ID           IN NUMBER ,
                 p_PROCESS_REFERENCE    IN VARCHAR2 ,
                 x_ERROR_CODE          OUT NOCOPY NUMBER ,
                 x_ERROR_MESSAGE       OUT NOCOPY VARCHAR2) ;

End XDPCORE_OM;

 

/
