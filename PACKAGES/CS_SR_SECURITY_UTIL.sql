--------------------------------------------------------
--  DDL for Package CS_SR_SECURITY_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_SECURITY_UTIL" AUTHID CURRENT_USER AS
/* $Header: csusecs.pls 120.1 2005/10/04 13:53:28 spusegao noship $ */

FUNCTION SET_SR_ACCESS (
   object_schema      IN   VARCHAR2,
   object_name        IN   VARCHAR2 )
RETURN VARCHAR2;

FUNCTION SET_SR_TYPE_ACCESS (
   object_schema      IN   VARCHAR2,
   object_name        IN   VARCHAR2 )
RETURN VARCHAR2;

FUNCTION SET_SR_RESOURCE_ACCESS (
   object_schema      IN   VARCHAR2,
   object_name        IN   VARCHAR2 )
RETURN VARCHAR2;

FUNCTION SET_SR_ACCESS_RESP (
   object_schema      IN   VARCHAR2,
   object_name        IN   VARCHAR2 )
RETURN VARCHAR2;

PROCEDURE ENABLE_SR_POLICIES (
   x_return_status    OUT  NOCOPY VARCHAR2 );

PROCEDURE DISABLE_SR_POLICIES (
   x_return_status    OUT  NOCOPY VARCHAR2 );


/*************************************************************************

DESCRIPTION of function SECURE_SR_TASK_ASSIGN

  The function is seeded as a subscription to the following JTF business
  events:
    Assigned is added     - oracle.apps.jtf.cac.task.createTaskAssignment
    Assignment is updated - oracle.apps.jtf.cac.task.updateTaskAssignment

  The purpose of this subscription is that it is executed whenever a
  resource is either assigned for the first time or is updated to/for
  a service request associated Task.

  The subscription will pass back to the JTF publisher a return status
  indicating if the resource assignment satisfies the Service Security
  policies or not.

  This subscription is a 'synchronous' subscription to be executed
  similar to a post insert / update internal hook.

  LOGIC FLOW
    1. The task_assignment_id is known to the subscription
    2. Get the task_id and resource_id for the task_assignment_id
    3. Get the source_id and source_type for the task_id
    4. If the source_type = 'SR' then continue else stop and return success
    5. Query the CS JTF resource secure view with the resource_id from
       step 2. Return success if query return a record, else return failure.
    6. The Tasks pub api will continue processing or stop depending on the
       return status of the service subscription

*************************************************************************/
FUNCTION SECURE_SR_TASK_ASSIGN (
   p_subscription_guid          IN     RAW,
   p_event                      IN OUT NOCOPY WF_EVENT_T )
RETURN VARCHAR2;



/*************************************************************************

DESCRIPTION of function SECURE_SR_TASK_OWNER

  The function is seeded as a subscription to the following JTF business
  events:
    Task is created - oracle.apps.jtf.cac.task.createTask
    Task is updated - oracle.apps.jtf.cac.task.updateTaskHdr

  The purpose of this subscription is that it is executed whenever a
  task is create or updated and the task is associated to a service
  request.

  The subscription will pass back to the JTF publisher a return status
  indicating if the owner assigned to the task satisfies the service
  security policies or not.

  This subscription is a 'synchronous' subscription to be executed
  similar to a post insert / update internal hook.

  LOGIC FLOW
    1. The task_id is know to the subscription
    2. Get the owner id and type, source id and type for the task
    3. If the source_type = 'SR' then continue else stop and return success
    4. Query the CS JTF resource secure view with the owner_id from
       step 2. Return success if query return a record, else return failure.
    5. The Tasks pub api will continue processing or stop depending on the
       return status of the service subscription

*************************************************************************/
FUNCTION SECURE_SR_TASK_OWNER (
   p_subscription_guid          IN     RAW,
   p_event                      IN OUT NOCOPY WF_EVENT_T )
RETURN VARCHAR2;


/*************************************************************************
Name - Alter_SR_Policies

DESCRIPTION of Procedure Alter_SR_Policies
   The proccedure is to alter the service owned database VPD policies.
   Logic
        IF p_security_setting  = 'ANONE' THEN
           Disable the existing service VPD policies
	ELSIF p_security_setting = 'BSTANDARD' THEN
              Drop the existing Service VPD policies
	      Create the service VPD policies as 'Static' policies
        ELSIF p_security_setting = 'CCUSTOM' THEN
	      Drop the existing Service VPD policies
	      Create the service VPD policies as 'Dynamic' policies
 	END IF ;

*************************************************************************/

PROCEDURE Alter_SR_Policies
     (p_security_setting   IN VARCHAR2,
      x_return_status     OUT NOCOPY VARCHAR2,
      x_msg_count         OUT NOCOPY NUMBER,
      x_msg_data          OUT NOCOPY VARCHAR2);

END CS_SR_SECURITY_UTIL;

 

/
