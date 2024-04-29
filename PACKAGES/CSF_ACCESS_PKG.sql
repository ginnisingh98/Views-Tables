--------------------------------------------------------
--  DDL for Package CSF_ACCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_ACCESS_PKG" AUTHID CURRENT_USER AS
/* $Header: csfvaccs.pls 115.3.1157.1 2002/03/22 16:14:07 pkm ship       $ */

PROCEDURE UpdateMobileUserAcc
  ( x_resource_id IN NUMBER
  , x_server_id   IN NUMBER
  , x_op          IN VARCHAR2
  );
PROCEDURE INCIDENT_POST_INSERT
  ( x_return_status OUT VARCHAR2
  );
PROCEDURE INCIDENT_PRE_UPDATE
  ( x_return_status OUT VARCHAR2
  );
PROCEDURE INCIDENT_POST_UPDATE
  ( x_return_status OUT VARCHAR2
  );
PROCEDURE TASKS_POST_INSERT
  ( x_return_status OUT VARCHAR2
  );
PROCEDURE TASKS_PRE_UPDATE
  ( x_return_status OUT VARCHAR2
  );
PROCEDURE TASKS_POST_UPDATE
  ( x_return_status OUT VARCHAR2
  );
PROCEDURE TASKS_PRE_DELETE
  ( x_return_status OUT VARCHAR2
  );
PROCEDURE TASK_ASSIGN_POST_INSERT
  ( x_return_status OUT VARCHAR2
  );
PROCEDURE TASK_ASSIGN_PRE_UPDATE
  ( x_return_status OUT VARCHAR2
  );
PROCEDURE TASK_ASSIGN_POST_UPDATE
  ( x_return_status OUT VARCHAR2
  );
PROCEDURE TASK_ASSIGN_PRE_DELETE
  ( x_return_status OUT VARCHAR2
  );
PROCEDURE CUST_RELATIONS_POST_INSERT
  ( x_return_status OUT VARCHAR2
  );
PROCEDURE INCIDENT_TRIGGER_HANDLER
  ( INCIDENT_ID   IN NUMBER
  , o_CUSTOMER_ID IN NUMBER
  , n_CUSTOMER_ID IN NUMBER
  , Trigger_Mode  IN VARCHAR2
  );
PROCEDURE TASKS_TRIGGER_HANDLER
  ( o_task_id                 IN NUMBER
  , o_source_object_id        IN NUMBER
  , o_source_object_name      IN VARCHAR2
  , o_source_object_type_code IN VARCHAR2
  , n_task_id                 IN NUMBER
  , n_source_object_id        IN NUMBER
  , n_source_object_name      IN VARCHAR2
  , n_source_object_type_code IN VARCHAR2
  , trigger_mode              IN VARCHAR2
  );
PROCEDURE TASK_ASSIGN_TRIGGER_HANDLER
  ( o_task_assignment_id IN NUMBER
  , o_task_id            IN NUMBER
  , o_resource_id        IN NUMBER
  , n_task_assignment_id IN NUMBER
  , n_task_id            IN NUMBER
  , n_resource_id        IN NUMBER
  , trigger_mode         IN VARCHAR2
  );
PROCEDURE SR_CONTACT_TRIGGER_HANDLER
  ( x_incident_id IN NUMBER
  , x_op          IN VARCHAR2
  );
PROCEDURE CUST_RELATIONS_TRIGGER_HANDLER
  ( rs_cust_relation_id IN NUMBER
  , o_party_id          IN NUMBER
  , n_party_id          IN NUMBER
  , resource_id         IN NUMBER
  , trigger_mode        IN VARCHAR2
  );
END CSF_ACCESS_PKG;

 

/
