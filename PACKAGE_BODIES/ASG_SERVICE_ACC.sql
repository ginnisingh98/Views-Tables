--------------------------------------------------------
--  DDL for Package Body ASG_SERVICE_ACC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASG_SERVICE_ACC" AS
/* $Header: asgacctb.pls 120.1 2005/08/12 02:41:21 saradhak noship $ */

/* MRAAP, 26-NOV-2001: this package has been replaced by CSF_ACCESS_PKG */
PROCEDURE run_command
  ( p_command IN VARCHAR2
  )
IS
BEGIN
  NULL;
END run_command;

FUNCTION IsExisting
  ( x_acc       IN varchar2
  , x_pk        IN varchar2
  , x_pk_id     IN number
  , x_server_id IN number
  ) RETURN NUMBER
IS
BEGIN
  NULL;
END IsExisting;

PROCEDURE InsertAcc
  ( x_acc       IN varchar2
  , x_pk        IN varchar2
  , x_pk_id     IN number
  , x_server_id IN number
  )
IS
BEGIN
  NULL;
END InsertAcc;

FUNCTION UpdateAcc
  ( x_acc       IN varchar2
  , x_pk        IN varchar2
  , x_pk_id     IN number
  , x_server_id IN number
  , x_op        IN varchar2
  ) RETURN NUMBER
IS
BEGIN
  NULL;
END UpdateAcc;

FUNCTION IsMobileUser
  ( x_resource_id IN NUMBER
  ) RETURN NUMBER
IS
BEGIN
  NULL;
END IsMobileUser;

FUNCTION GetServerId
  ( x_resource_id IN     NUMBER
  , x_server_id      OUT NOCOPY  NUMBER
  ) RETURN NUMBER
IS
BEGIN
  NULL;
END GetServerId;

PROCEDURE UpdateAccesses_Partyid
  ( x_party_id  IN number
  , x_server_id IN number
  , x_op        IN varchar2
  )
IS
BEGIN
  NULL;
END UpdateAccesses_Partyid;

PROCEDURE UpdateAccesses_Incidentid
  ( x_incident_id IN number
  , x_server_id   IN number
  , x_op          IN varchar2
  )
IS
BEGIN
  NULL;
END UpdateAccesses_Incidentid;

PROCEDURE UpdateAccesses_Taskid
  ( x_task_id   IN number
  , x_server_id IN number
  , x_op        IN varchar2
  )
IS
BEGIN
  NULL;
END UpdateAccesses_Taskid;

PROCEDURE UpdateMobileUserAcc
  ( x_resource_id in number
  , x_server_id   in number
  , x_op          in varchar2
  )
IS
BEGIN
  NULL;
END UpdateMobileUserAcc;

PROCEDURE INCIDENT_PRE_UPDATE
  ( x_return_status OUT NOCOPY  varchar2
  )
IS
BEGIN
   x_return_status := 'S';
END INCIDENT_PRE_UPDATE;

PROCEDURE INCIDENT_POST_UPDATE
  ( x_return_status OUT NOCOPY  varchar2
  )
IS
BEGIN
  x_return_status := 'S';
END INCIDENT_POST_UPDATE;

PROCEDURE TASKS_POST_INSERT
  ( x_return_status OUT NOCOPY  varchar2
  )
IS
BEGIN
  x_return_status := 'S';
END TASKS_POST_INSERT;

PROCEDURE TASKS_PRE_UPDATE
  ( x_return_status OUT NOCOPY  varchar2
  )
IS
BEGIN
  x_return_status := 'S';
END TASKS_PRE_UPDATE;

PROCEDURE TASK_ASSIGN_POST_INSERT
  ( x_return_status OUT NOCOPY  varchar2
  )
IS
BEGIN
  x_return_status :='S';
END TASK_ASSIGN_POST_INSERT;

PROCEDURE TASK_ASSIGN_PRE_UPDATE
  ( x_return_status OUT NOCOPY  varchar2
  )
IS
BEGIN
  x_return_status := 'S';
END TASK_ASSIGN_PRE_UPDATE;

PROCEDURE TASK_ASSIGN_PRE_DELETE
  ( x_return_status OUT NOCOPY  varchar2
  )
IS
BEGIN
  x_return_status :='S';
END TASK_ASSIGN_PRE_DELETE;

PROCEDURE INCIDENT_TRIGGER_HANDLER
  ( INCIDENT_ID   NUMBER
  , o_CUSTOMER_ID NUMBER
  , n_CUSTOMER_ID number
  , Trigger_Mode  VARCHAR2
  )
IS
BEGIN
  NULL;
END INCIDENT_TRIGGER_HANDLER;

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
  )
IS
BEGIN
  NULL;
END Tasks_Trigger_Handler;

PROCEDURE Task_Assign_Trigger_Handler
  ( o_TASK_ASSIGNMENT_ID              NUMBER
  , o_TASK_ID                         NUMBER
  , o_RESOURCE_ID                     NUMBER
  , n_TASK_ASSIGNMENT_ID              NUMBER
  , n_TASK_ID                         NUMBER
  , n_RESOURCE_ID                     NUMBER
  , Trigger_Mode VARCHAR2
  )
IS
BEGIN
  NULL;
END Task_Assign_Trigger_Handler;

PROCEDURE SR_CONTACT_TRIGGER_HANDLER
  ( x_incident_id number
  , x_op          VARCHAR2
  )
IS
BEGIN
  NULL;
END SR_CONTACT_TRIGGER_HANDLER;

END ASG_SERVICE_ACC;

/
