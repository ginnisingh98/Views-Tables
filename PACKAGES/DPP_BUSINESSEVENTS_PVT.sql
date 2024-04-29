--------------------------------------------------------
--  DDL for Package DPP_BUSINESSEVENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DPP_BUSINESSEVENTS_PVT" AUTHID CURRENT_USER AS
/* $Header: dppvbevs.pls 120.2.12010000.4 2009/06/10 06:32:21 pvaramba ship $ */

TYPE dpp_txn_hdr_rec_type IS RECORD
(
    Transaction_Header_ID   NUMBER,
    Transaction_number      VARCHAR2(240),
    Process_code            VARCHAR2(240),
    claim_id                NUMBER,
    claim_type_flag         VARCHAR2(30),
    claim_creation_source   VARCHAR2(20)
);


TYPE dpp_txn_line_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

---------------------------------------------------------------------
-- PROCEDURE
--    Raise_Business_Event
--
-- PURPOSE
--    Raise Business event
--
-- PARAMETERS
--
-- NOTES
--    1.
--    2.
----------------------------------------------------------------------
PROCEDURE Raise_Business_Event(
	 p_api_version   	 IN 	        NUMBER
  	,p_init_msg_list	 IN 	        VARCHAR2     := FND_API.G_FALSE
   	,p_commit	         IN 	        VARCHAR2     := FND_API.G_FALSE
   	,p_validation_level	 IN 	        NUMBER       := FND_API.G_VALID_LEVEL_FULL

   	,x_return_status	 OUT NOCOPY     VARCHAR2
        ,x_msg_count	         OUT NOCOPY     NUMBER
        ,x_msg_data	         OUT NOCOPY     VARCHAR2

   	,p_txn_hdr_rec           IN       dpp_txn_hdr_rec_type
        ,p_txn_line_id           IN       dpp_txn_line_tbl_type
     );

---------------------------------------------------------------------
-- PROCEDURE
--    RAISE_EFFECTIVE_DATE_EVENT
--
-- PURPOSE
--    Raise a business event on the effective date of a txn.
--
-- PARAMETERS
--	  program id of the cc program which does the status change.
--
----------------------------------------------------------------------
PROCEDURE RAISE_EFFECTIVE_DATE_EVENT(
        P_API_VERSION        IN  NUMBER,
        P_INIT_MSG_LIST      IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
        P_COMMIT             IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
        P_VALIDATION_LEVEL   IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
        X_RETURN_STATUS      OUT NOCOPY   VARCHAR2,
        X_MSG_DATA           OUT NOCOPY   VARCHAR2,
        X_MSG_COUNT          OUT NOCOPY   NUMBER,
        P_PROGRAM_ID         IN NUMBER );

---------------------------------------------------------------------
-- PROCEDURE
--    SEND_EFFECTIVE_DATE_NOTIF
--
-- PURPOSE
--    Called by the wf to send notif to the user
--
----------------------------------------------------------------------
PROCEDURE SEND_EFFECTIVE_DATE_NOTIF(
          ITEMTYPE IN VARCHAR2,
          ITEMKEY  IN VARCHAR2,
          ACTID    IN NUMBER,
          FUNCMODE IN VARCHAR2,
          RESULT   IN OUT NOCOPY VARCHAR2
  );

---------------------------------------------------------------------
-- PROCEDURE
--    SEND_CANCEL_NOTIFICATIONS
--
-- PURPOSE
--    Procedure to invoke the cancel notifications.
--
----------------------------------------------------------------------
PROCEDURE SEND_CANCEL_NOTIFICATIONS(
	P_API_VERSION IN NUMBER,
	P_INIT_MSG_LIST IN VARCHAR2 := FND_API.G_FALSE,
	P_COMMIT IN VARCHAR2 := FND_API.G_FALSE,
	P_VALIDATION_LEVEL IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
	X_RETURN_STATUS OUT NOCOPY VARCHAR2,
	X_MSG_COUNT OUT NOCOPY NUMBER,
	X_MSG_DATA OUT NOCOPY VARCHAR2,
	P_TXN_HDR_ID IN NUMBER
);

---------------------------------------------------------------------
-- PROCEDURE
--    RAISE_BUSINESS_EVT_FOR_PROCESS
--
-- PURPOSE
--    Raises the business event for the specified process.
--
----------------------------------------------------------------------
PROCEDURE RAISE_BUSINESS_EVT_FOR_PROCESS (
    P_API_VERSION IN NUMBER,
    P_INIT_MSG_LIST IN VARCHAR2 := FND_API.G_FALSE,
    P_COMMIT IN VARCHAR2 := FND_API.G_FALSE,
    P_VALIDATION_LEVEL IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    X_RETURN_STATUS OUT NOCOPY VARCHAR2,
    X_MSG_COUNT OUT NOCOPY NUMBER,
    X_MSG_DATA OUT NOCOPY VARCHAR2,
    P_TXN_HDR_ID IN NUMBER,
    P_PROCESS_CODE IN VARCHAR2
);


END DPP_BUSINESSEVENTS_PVT;

/
