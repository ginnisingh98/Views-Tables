--------------------------------------------------------
--  DDL for Package CSFW_SERVICEREQUEST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSFW_SERVICEREQUEST_PUB" AUTHID CURRENT_USER AS
/*  $Header: csfwpsrs.pls 120.2.12010000.2 2009/07/29 12:01:19 syenduri ship $ */
PROCEDURE update_request_resolution
  ( p_incident_id     IN  NUMBER
  , p_resolution_code IN  VARCHAR2
  , P_RESOLUTION_SUMMARY IN  VARCHAR2
  , p_problem_code IN varchar2 default null
  , p_cust_po_number  IN varchar2 default null
  , p_commit          IN BOOLEAN DEFAULT TRUE
  , p_init_msg_list  IN BOOLEAN DEFAULT TRUE
  , X_RETURN_STATUS   OUT NOCOPY VARCHAR2
  , X_MSG_COUNT       OUT NOCOPY INTEGER
  , X_MSG_DATA        OUT NOCOPY VARCHAR2
  , p_object_version_number IN NUMBER default null
  , p_incident_severity_id IN  NUMBER default null -- For enhancement in FSTP 12.1.3 Project
  ) ;



-- bug # 4337147
-- signature is changed
PROCEDURE get_reaction_time
  ( p_incident_id   IN  NUMBER
  , p_task_id       IN  NUMBER
  , p_resource_id   IN  NUMBER
  , p_error_type    OUT NOCOPY NUMBER
  , p_error         OUT NOCOPY VARCHAR2
  , x_react_within  OUT NOCOPY NUMBER
  , x_react_tuom    OUT NOCOPY VARCHAR2
  , x_react_by_date OUT NOCOPY VARCHAR2
  , x_contract_service_id OUT NOCOPY NUMBER
  , x_contract_number OUT NOCOPY VARCHAR2
  , x_txn_group_id OUT NOCOPY NUMBER
  ) ;

/*
Wrapper on update_servicerequest for updating task fled field
*/
PROCEDURE update_request_flex
  ( p_incident_id	IN  NUMBER
  , p_attribute_1	IN VARCHAR2
  , p_attribute_2	IN VARCHAR2
  , p_attribute_3	IN VARCHAR2
  , p_attribute_4	IN VARCHAR2
  , p_attribute_5	IN VARCHAR2
  , p_attribute_6	IN VARCHAR2
  , p_attribute_7	IN VARCHAR2
  , p_attribute_8	IN VARCHAR2
  , p_attribute_9	IN VARCHAR2
  , p_attribute_10	IN VARCHAR2
  , p_attribute_11	IN VARCHAR2
  , p_attribute_12	IN VARCHAR2
  , p_attribute_13	IN VARCHAR2
  , p_attribute_14	IN VARCHAR2
  , p_attribute_15	IN VARCHAR2
  , p_context		IN VARCHAR2
  , X_RETURN_STATUS	OUT NOCOPY VARCHAR2
  , X_MSG_COUNT		OUT NOCOPY INTEGER
  , X_MSG_DATA		OUT NOCOPY VARCHAR2
  );

END csfw_servicerequest_pub;

/
