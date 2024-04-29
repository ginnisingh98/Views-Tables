--------------------------------------------------------
--  DDL for Package QA_RESULT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_RESULT_GRP" AUTHID CURRENT_USER AS
/* $Header: qltgresb.pls 120.3.12000000.1 2007/01/19 07:15:46 appldev ship $*/
--
--  API name   : QA_Result_GRP.Purge
--
--  Type    : Group.
--
--  Function  : This API serves to delete Quality Results for
--        given collection id
--
--  Pre-reqs  : None.
--
--  Parameters  :
--
--  IN    :  p_api_version           IN NUMBER  Required
--          (specify the version number here, see below)
--        p_init_msg_list    IN VARCHAR2   Optional
--          Default = FND_API.G_FALSE
--        p_commit       IN VARCHAR2  Optional
--          Default = FND_API.G_FALSE
--        p_validation_level  IN NUMBER  Optional
--          Default = FND_API.G_VALID_LEVEL_FULL
--        p_collection_id
--
--  OUT    :  p_return_status    OUT  VARCHAR2(1)
--          ('S' - success,
--           'E' - error,
--           'U' - unexpecte error)
--        p_msg_count    OUT  NUMBER
--          (number of error message on the stack)
--        p_msg_data    OUT  VARCHAR2(2000)
--          (return the first messsage on the stack)
--
--  Version    : Current version  1.0
--        previous version  None
--        Initial version   1.0
--
--  Notes    :
--

PROCEDURE Purge
(   p_api_version           IN  NUMBER        ,
    p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE  ,
  p_commit        IN    VARCHAR2 := FND_API.G_FALSE  ,
  p_validation_level  IN    NUMBER   :=
          FND_API.G_VALID_LEVEL_FULL  ,
  p_collection_id    IN  NUMBER        ,
  p_return_status    OUT  NOCOPY VARCHAR2        ,
  p_msg_count    OUT  NOCOPY NUMBER        ,
  p_msg_data    OUT  NOCOPY VARCHAR2
);


--  API name   : QA_Result_GRP.Enable
--
--  Type    : Group.
--
--  Function  : This API serves to enable the Quality Results for
--        given collection id by updating the status
--
--  Pre-reqs  : None.
--
--  Parameters  :
--
--  IN    :  p_api_version           IN NUMBER  Required
--        p_init_msg_list    IN VARCHAR2   Optional
--          Default = FND_API.G_FALSE
--        p_commit        IN VARCHAR2  Optional
--          Default = FND_API.G_FALSE
--        p_validation_level  IN NUMBER  Optional
--          Default = FND_API.G_VALID_LEVEL_FULL
--        p_collection_id
--                              p_incident_id           IN NUMBER DEFAULT NULL
--
--  OUT    :  p_return_status    OUT  VARCHAR2(1)
--        p_msg_count    OUT  NUMBER
--        p_msg_data    OUT  VARCHAR2(2000)
--
--  Version    : Current version  1.0
--        previous version  None
--        Initial version   1.0
--
--  Notes    :
--

--
-- Added the new parameter p_incident_id for Service Request Enhancements Project
-- Default value is null for backward compatibility
-- rkunchal Tue Sep  3 10:20:12 PDT 2002
--
PROCEDURE Enable
(   p_api_version            IN  NUMBER        ,
    p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE  ,
  p_commit       IN    VARCHAR2 := FND_API.G_FALSE  ,
  p_validation_level  IN    NUMBER   :=
          FND_API.G_VALID_LEVEL_FULL  ,
  p_collection_id    IN  NUMBER        ,
  p_return_status    OUT  NOCOPY VARCHAR2        ,
  p_msg_count    OUT  NOCOPY NUMBER        ,
  p_msg_data    OUT  NOCOPY VARCHAR2      ,
  p_incident_id           IN      NUMBER DEFAULT NULL
);

PROCEDURE Enable_QA_Results ( X_Txn_Header_ID Number,
                              P_MSG_COUNT IN OUT NOCOPY Number  );

-- Start R12 EAM Integration. Bug 4345492
PROCEDURE enable_and_fire_action (
    p_api_version      	IN	NUMBER,
    p_init_msg_list	IN	VARCHAR2 := NULL,
    p_commit		IN  	VARCHAR2 := NULL,
    p_validation_level	IN  	NUMBER	 := NULL,
    p_collection_id	IN	NUMBER,
    x_return_status	OUT 	NOCOPY VARCHAR2,
    x_msg_count		OUT 	NOCOPY NUMBER,
    x_msg_data		OUT 	NOCOPY VARCHAR2);
-- End R12 EAM Integration. Bug 4345492

  -- R12 ERES Support in Service Family. Bug 4345768 Start
  -- Record Type to store Quality Events and E-Rcord IDs
  -- This will be used by parent teams to retrieve the E-Record IDs
  -- and pass the same as child E-Records for the parent Events
  -- when Quality E-Records are captured as part of the parent Txn
  -- This would be used primarily by the SR team for R12.
  TYPE qa_erecord_rec_type IS RECORD
  (
      event_name  EDR_PSIG_DOCUMENTS.EVENT_NAME%TYPE,
      event_key   EDR_PSIG_DOCUMENTS.EVENT_KEY%TYPE,
      erec_id     EDR_PSIG_DOCUMENTS.DOCUMENT_ID%TYPE
  );

  TYPE qa_erecord_tbl_type IS TABLE OF qa_erecord_rec_type
       INDEX BY BINARY_INTEGER;

  -- API to retrieve the Quality Results E-Records captured as
  -- part of a Transaction session ( collection )
  -- The E-Record IDs are returned as part of the x_qa_erecord_tbl
  -- output parameter.
  PROCEDURE get_qa_results_erecords
  (
   p_api_version      IN  NUMBER ,
   p_init_msg_list    IN  VARCHAR2 := NULL ,
   p_commit           IN  VARCHAR2 := NULL ,
   p_validation_level IN  NUMBER   := NULL ,
   p_collection_id    IN  NUMBER ,
   x_qa_erecord_tbl   OUT NOCOPY qa_erecord_tbl_type ,
   x_return_status    OUT NOCOPY VARCHAR2 ,
   x_msg_count        OUT NOCOPY NUMBER ,
   x_msg_data         OUT NOCOPY VARCHAR2
  );

  -- API to enable the Quality Results captured as part of the
  -- Transaction session ( collection ). This API will call the existing
  -- enable API to enable the results and fire background quality actions
  -- in addition to invoking EDR API to stamp the acknowledgement status
  -- of the Quality E-Records captured as part of the Txn as SUCCESS
  PROCEDURE enable_results_erecords
  (
   p_api_version      IN  NUMBER ,
   p_init_msg_list    IN  VARCHAR2 := NULL ,
   p_commit           IN  VARCHAR2 := NULL ,
   p_validation_level IN  NUMBER   := NULL ,
   p_collection_id    IN  NUMBER ,
   p_incident_id      IN  NUMBER   := NULL,
   x_return_status    OUT NOCOPY VARCHAR2 ,
   x_msg_count        OUT NOCOPY NUMBER ,
   x_msg_data         OUT NOCOPY VARCHAR2
  );

  -- API to purge the Quality Results captured as part of the
  -- Transaction session ( collection ). This API will call the existing
  -- purge API to delete the results in addition to invoking EDR API to
  -- stamp the acknowledgement status of the Quality E-Records captured
  -- as part of the Txn as SUCCESS
  PROCEDURE purge_results_erecords
  (
   p_api_version      IN  NUMBER ,
   p_init_msg_list    IN  VARCHAR2 := NULL ,
   p_commit           IN  VARCHAR2 := NULL ,
   p_validation_level IN  NUMBER   := NULL ,
   p_collection_id    IN  NUMBER ,
   x_return_status    OUT NOCOPY VARCHAR2 ,
   x_msg_count        OUT NOCOPY NUMBER ,
   x_msg_data         OUT NOCOPY VARCHAR2
  );
  -- R12 ERES Support in Service Family. Bug 4345768 End

  -- Bug 5508639. SHKALYAN 13-Sep-2006.
  -- new API to delete the old invalid results For a collection_id
  PROCEDURE purge_invalid_results
  (
   p_collection_id    IN  NUMBER
  );
END;

 

/
