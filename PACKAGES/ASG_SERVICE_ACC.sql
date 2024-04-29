--------------------------------------------------------
--  DDL for Package ASG_SERVICE_ACC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASG_SERVICE_ACC" AUTHID CURRENT_USER AS
/* $Header: asgaccts.pls 120.1 2005/08/12 02:41:44 saradhak noship $ */

/* MRAAP, 26-NOV-2001: this package has been replaced by CSF_ACCESS_PKG */
PROCEDURE UpdateMobileUserAcc
  ( x_resource_id in NUMBER
  , x_server_id   in NUMBER
  , x_op          in VARCHAR2
  );
PROCEDURE INCIDENT_PRE_UPDATE
  ( x_return_status out nocopy varchar2
  );
PROCEDURE INCIDENT_POST_UPDATE
  ( x_return_status OUT NOCOPY  varchar2
  );
PROCEDURE TASKS_POST_INSERT
  ( x_return_status OUT NOCOPY  varchar2
  );
PROCEDURE TASKS_PRE_UPDATE
  ( x_return_status OUT NOCOPY  varchar2
  );
PROCEDURE TASK_ASSIGN_POST_INSERT
  ( x_return_status OUT NOCOPY  varchar2
  );
PROCEDURE TASK_ASSIGN_PRE_UPDATE
  ( x_return_status OUT NOCOPY  varchar2
  );
PROCEDURE TASK_ASSIGN_PRE_DELETE
  ( x_return_status OUT NOCOPY  varchar2
  );
PROCEDURE INCIDENT_TRIGGER_HANDLER
  ( INCIDENT_ID   NUMBER
  , o_CUSTOMER_ID NUMBER
  , n_CUSTOMER_ID NUMBER
  , Trigger_Mode  VARCHAR2
  );
PROCEDURE Tasks_Trigger_Handler
  ( o_TASK_ID                 NUMBER
  , o_SOURCE_OBJECT_ID        NUMBER
  , o_SOURCE_OBJECT_NAME      VARCHAR2
  , o_source_object_type_code VARCHAR2
  , n_TASK_ID                 NUMBER
  , n_SOURCE_OBJECT_ID        NUMBER
  , n_SOURCE_OBJECT_NAME      VARCHAR2
  , n_source_object_type_code VARCHAR2
  , Trigger_Mode              VARCHAR2
  );
PROCEDURE Task_Assign_Trigger_Handler
  ( o_TASK_ASSIGNMENT_ID NUMBER
  , o_TASK_ID            NUMBER
  , o_RESOURCE_ID        NUMBER
  , n_TASK_ASSIGNMENT_ID NUMBER
  , n_TASK_ID            NUMBER
  , n_RESOURCE_ID        NUMBER
  , Trigger_Mode         VARCHAR2
  );
PROCEDURE SR_CONTACT_TRIGGER_HANDLER
  ( x_incident_id NUMBER
  , x_op          VARCHAR2
  );

END ASG_SERVICE_ACC;

 

/
