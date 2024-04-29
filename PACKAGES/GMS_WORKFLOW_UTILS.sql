--------------------------------------------------------
--  DDL for Package GMS_WORKFLOW_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_WORKFLOW_UTILS" AUTHID CURRENT_USER AS
/* $Header: gmsfutls.pls 120.1 2005/07/26 14:22:14 appldev ship $ */



PROCEDURE Insert_WF_Processes
(p_wf_type_code		IN	VARCHAR2
, p_item_type		IN	VARCHAR2
, p_item_key		IN	VARCHAR2
, p_entity_key1		IN	VARCHAR2
, p_entity_key2		IN	VARCHAR2 := GMS_BUDGET_PUB.G_PA_MISS_CHAR
, p_description		IN	VARCHAR2 := GMS_BUDGET_PUB.G_PA_MISS_CHAR
, p_err_code            IN OUT NOCOPY	NUMBER
, p_err_stage		IN OUT NOCOPY	VARCHAR2
, p_err_stack		IN OUT NOCOPY	VARCHAR2
);

PROCEDURE Set_Global_Attr
 (p_item_type                   IN VARCHAR2
  , p_item_key                	IN VARCHAR2
  , p_err_code                  OUT NOCOPY VARCHAR2
);

PROCEDURE Set_Notification_Messages
 (p_item_type 	              IN VARCHAR2
  , p_item_key                    IN VARCHAR2
);

--
--  FUNCTION
--              get_application_id
--  PURPOSE
--              This function retrieves the application id of a responsibility.
--              If no application id is found, null is returned.
--              If Oracle error occurs, Oracle error number is returned.

function get_application_id (x_responsibility_id  IN number) return number;
pragma RESTRICT_REFERENCES (get_application_id, WNDS, WNPS);

END gms_workflow_utils;

 

/
