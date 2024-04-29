--------------------------------------------------------
--  DDL for Package Body CS_SR_SECURITY_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_SECURITY_UTIL" AS
/* $Header: csusecb.pls 120.2 2005/10/12 15:11:38 spusegao noship $ */

G_PKG_NAME          CONSTANT VARCHAR2(30) := 'CS_SR_SECURITY_UTIL';

-- This function returns back the where predicate that gets appended to select
-- statements on the 'cs_incidents_b_sec' secure view. The where predicate is
-- retrieved from the AOL grants model by invoking a FND API.
FUNCTION SET_SR_ACCESS (
   object_schema      IN   VARCHAR2,
   object_name        IN   VARCHAR2 )
RETURN VARCHAR2
IS
   lx_return_status        VARCHAR2(3);
   lx_predicate            VARCHAR2(4000);
BEGIN

   -- invoke the AOL API to return back the where predicate that is defined
   -- as a Grant
   -- Refer to script AFSCDSCS.pls for instructions on how to use the API.
   fnd_data_security.get_security_predicate (
      p_api_version          => 1.0,
      p_function             => 'CS_SR_VIEW',
      p_object_name          => 'CS_SERVICE_REQUEST',
      p_table_alias          => 'CS_INCIDENTS_B_SEC',
--      p_grant_instance_type  => 'SET',
--      p_user_name            => 'GLOBAL',
      x_predicate            => lx_predicate,
      x_return_status        => lx_return_status );

   if ( lx_return_status = 'T' ) then
      return ( lx_predicate );
   else
      -- if a predicate is not returned back, then return NULL
      IF lx_predicate IS NOT NULL THEN
         return lx_predicate ;
      ELSE
         return '1=2';
--         return null;
      END IF ;

      -- if error status is returned from the FND API, clear the message
      -- stack.(The FND API pushes a msg. into the stack incase of an error)
      FND_MESSAGE.CLEAR();
   end if;

EXCEPTION
   when others then
      -- return null if any unknown exception is raised
      return '1=2';

END SET_SR_ACCESS ;

-- This function returns back the where predicate that gets appended to select
-- statements on the 'cs_sr_types_select_b' secure view. The where predicate
-- is retrieved from the AOL grants model by invoking a FND API.
FUNCTION SET_SR_TYPE_ACCESS (
   object_schema      IN   VARCHAR2,
   object_name        IN   VARCHAR2 )
RETURN VARCHAR2
IS
   lx_return_status        VARCHAR2(3);
   lx_predicate            VARCHAR2(4000);
BEGIN

   -- invoke the AOL API to return back the where predicate that is defined
   -- as a Grant
   -- Refer to script AFSCDSCS.pls for instructions on how to use the API.
   fnd_data_security.get_security_predicate (
      p_api_version          => 1.0,
      p_function             => 'CS_SR_TYPES_SELECT_SEC',
      p_object_name          => 'CS_SR_TYPE',
      p_grant_instance_type  => 'SET',
      p_user_name            => 'GLOBAL',
      x_predicate            => lx_predicate,
      x_return_status        => lx_return_status );

   if ( lx_return_status = 'T' ) then
      return ( lx_predicate );
   else
      -- if a predicate is not returned back, then return NULL
      IF lx_predicate IS NOT NULL THEN
         return lx_predicate ;
      ELSE
         return null;
      END IF ;

      -- if error status is returned from the FND API, clear the message
      -- stack.(The FND API pushes a msg. into the stack incase of an error)
      FND_MESSAGE.CLEAR();
   end if;

EXCEPTION
   when others then
      -- return null if any unknown exception is raised
      return null;

END SET_SR_TYPE_ACCESS ;

-- This function returns back the where predicate that gets appended to select
-- statements on the 'cs_jtf_resource_select_sec' secure view. The where
-- predicate is retrieved from the AOL grants model by invoking a FND API.
FUNCTION SET_SR_RESOURCE_ACCESS (
   object_schema      IN   VARCHAR2,
   object_name        IN   VARCHAR2 )
RETURN VARCHAR2
IS
   lx_return_status        VARCHAR2(3);
   lx_predicate            VARCHAR2(4000);
BEGIN

   -- invoke the AOL API to return back the where predicate that is defined
   -- as a Grant
   -- Refer to script AFSCDSCS.pls for instructions on how to use the API.
   fnd_data_security.get_security_predicate (
      p_api_version          => 1.0,
      p_function             => 'CS_JTF_RS_RESOURCE_EXTNS_SEC',
      p_object_name          => 'JTF_TASK_RESOURCE',
      p_grant_instance_type  => 'SET',
      p_user_name            => 'GLOBAL',
      x_predicate            => lx_predicate,
      x_return_status        => lx_return_status );

   if ( lx_return_status = 'T' ) then
      return ( lx_predicate );
   else
      -- if a predicate is not returned back, then return NULL
      IF lx_predicate IS NOT NULL THEN
         return lx_predicate ;
      ELSE
         return null;
      END IF ;

      -- if error status is returned from the FND API, clear the message
      -- stack.(The FND API pushes a msg. into the stack incase of an error)
      FND_MESSAGE.CLEAR();
   end if;

EXCEPTION
   when others then
      -- return null if any unknown exception is raised
      return null;

END SET_SR_RESOURCE_ACCESS ;

-- This function returns back the where predicate that gets appended to select
-- statements on the 'cs_sr_access_resp_sec' secure view. The where predicate is
-- retrieved from the AOL grants model by invoking a FND API.
FUNCTION SET_SR_ACCESS_RESP (
   object_schema      IN   VARCHAR2,
   object_name        IN   VARCHAR2 )
RETURN VARCHAR2
IS
   lx_return_status        VARCHAR2(3);
   lx_predicate            VARCHAR2(4000);
BEGIN

   -- invoke the AOL API to return back the where predicate that is defined
   -- as a Grant
   -- Refer to script AFSCDSCS.pls for instructions on how to use the API.
   fnd_data_security.get_security_predicate (
      p_api_version          => 1.0,
      p_function             => 'CS_SR_ACCESS_RESP_SEC',
      p_object_name          => 'CS_SERVICE_REQUEST',
      p_grant_instance_type  => 'SET',
      p_user_name            => 'GLOBAL',
      x_predicate            => lx_predicate,
      x_return_status        => lx_return_status );

   if ( lx_return_status = 'T' ) then
      return ( lx_predicate );
   else
      -- return back a success status
      IF lx_predicate IS NOT NULL THEN
         return lx_predicate ;
      ELSE
         return null;
      END IF ;

      -- if error status is returned from the FND API, clear the message
      -- stack.(The FND API pushes a msg. into the stack incase of an error)
      FND_MESSAGE.CLEAR();
   end if;

EXCEPTION
   when others then
      -- return null if any unknown exception is raised
      return null;

END SET_SR_ACCESS_RESP ;

-- Procedure to enable Service security VPD policies. This proc. is invoked
-- from the Service Security - System Options OA page.
PROCEDURE ENABLE_SR_POLICIES (
   x_return_status    OUT  NOCOPY VARCHAR2 )
IS
   l_api_name_full    VARCHAR2(40) := g_pkg_name || '.ENABLE_SR_POLICIES';
BEGIN
   x_return_status  := FND_API.G_RET_STS_SUCCESS;

   dbms_rls.enable_policy(
      object_schema     => 'APPS',
      object_name       => 'CS_INCIDENTS_B_SEC',
      policy_name       => 'CS_SR_SEC_SR_ACCESS',
      enable            => TRUE );

   dbms_rls.enable_policy(
      object_schema     => 'APPS',
      object_name       => 'CS_SR_TYPES_SELECT_SEC',
      policy_name       => 'CS_SR_SEC_SRTYPE_ACCESS',
      enable            => TRUE );

   dbms_rls.enable_policy(
      object_schema     => 'APPS',
      object_name       => 'CS_JTF_RS_RESOURCE_EXTNS_SEC',
      policy_name       => 'CS_SR_JTF_RESOURCE_ACCESS',
      enable            => TRUE );

   dbms_rls.enable_policy(
      object_schema     => 'APPS',
      object_name       => 'CS_SR_ACCESS_RESP_SEC',
      policy_name       => 'CS_SR_SEC_RESP_ACCESS',
      enable            => TRUE );

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      fnd_msg_pub.ADD;

END ENABLE_SR_POLICIES;

-- Procedure to disable Service security VPD policies. This proc. is invoked
-- from the Service Security - System Options OA page.
PROCEDURE DISABLE_SR_POLICIES (
   x_return_status    OUT  NOCOPY VARCHAR2 )
IS
   l_api_name_full    VARCHAR2(40) := g_pkg_name || '.DISABLE_SR_POLICIES';
BEGIN
   x_return_status  := FND_API.G_RET_STS_SUCCESS;

   dbms_rls.enable_policy(
      object_schema     => 'APPS',
      object_name       => 'CS_INCIDENTS_B_SEC',
      policy_name       => 'CS_SR_SEC_SR_ACCESS',
      enable            => FALSE );

   dbms_rls.enable_policy(
      object_schema     => 'APPS',
      object_name       => 'CS_SR_TYPES_SELECT_SEC',
      policy_name       => 'CS_SR_SEC_SRTYPE_ACCESS',
      enable            => FALSE );

   dbms_rls.enable_policy(
      object_schema     => 'APPS',
      object_name       => 'CS_JTF_RS_RESOURCE_EXTNS_SEC',
      policy_name       => 'CS_SR_JTF_RESOURCE_ACCESS',
      enable            => FALSE );

   dbms_rls.enable_policy(
      object_schema     => 'APPS',
      object_name       => 'CS_SR_ACCESS_RESP_SEC',
      policy_name       => 'CS_SR_SEC_RESP_ACCESS',
      enable            => FALSE );

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM);
      fnd_msg_pub.ADD;

END DISABLE_SR_POLICIES;

--
-- Subscription function to the JTF task assignment create and update
-- event

FUNCTION SECURE_SR_TASK_ASSIGN (
   p_subscription_guid          IN     RAW,
   p_event                      IN OUT NOCOPY WF_EVENT_T )
RETURN VARCHAR2
IS
   -- cursor to fetch the task id for which the assignment is created or
   -- updated
   cursor get_task_asgn ( c_task_assignment_id   IN  NUMBER ) is
   select task_id
   from   jtf_task_assignments
   where  task_assignment_id = c_task_assignment_id;

   l_task_id                NUMBER;

   -- cursor to fetch the source object id and type to which the task is
   -- associated to
   cursor get_tasks ( c_task_id   IN  NUMBER ) is
   select source_object_id, source_object_type_code
   from   jtf_tasks_b
   where  task_id = c_task_id;

   l_source_id            NUMBER;
   l_source_type          VARCHAR2(240);

   -- cursor to fetch the SR Type id of the SR whose task owner is
   -- getting assigned.
   cursor get_sr_type ( c_incident_id    IN  NUMBER ) is
   select incident_type_id
   from   cs_incidents_all_b
   where  incident_id = c_incident_id;

   l_incident_type_id     NUMBER;

   -- cursor that queries from the service JTF secure view. If security is
   -- enabled and is set to Standard, the following where predicate will be
   -- appended to the cursor select
   -- OR EXISTS
   -- ( SELECT '1'
   --   from fnd_user_resp_groups   ur,
   --        cs_sr_type_mapping     csmap
   --   WHERE   (cs_jtf_rs_resource_extns_sec.user_id IS NULL  )
   --   OR      cs_jtf_rs_resource_extns_sec.user_id =  ur.user_id
   --   AND  ur.responsibility_id      =  csmap.Responsibility_id
   --   AND  ur. responsibility application_id     =  csmap.application_id
   --   AND  csmap.business_usage      = 'AGENT'
   --   AND  csmap.incident_type_id    = sys_context(CS_SR_SECURITY, SRTYPE_ID)
   --   AND  trunc(sysdate) between trunc(nvl(csmap.start_date, sysdate))
   --                           and trunc(nvl(csmap.end_date,sysdate))  ))

   cursor check_sr_access ( c_resource_id   IN  NUMBER )is
   select 1
   from   cs_jtf_rs_resource_extns_sec
   where  resource_id = c_resource_id;

   l_count                         NUMBER;

   l_task_assignment_id            NUMBER;
   l_resource_id                   NUMBER;
   l_resource_type_code            VARCHAR2(240);
   l_assignment_status_id          NUMBER;

   l_api_name             CONSTANT VARCHAR2(40) := '.CS_SR_SECURE_TASK_ASSIGN';
   l_api_name_full                 VARCHAR2(70) := G_PKG_NAME || l_api_name;

    l_event_name        VARCHAR2(240) := p_event.getEventName( );

BEGIN
   -- get the task_assignment_id from the event payload
   l_task_assignment_id   := p_event.GetValueForParameter('TASK_ASSIGNMENT_ID');

   -- if the event is an update, then need to prepend NEW_ to the WF attribute name
   if ( l_event_name = 'oracle.apps.jtf.cac.task.updateTaskAssignment' ) then
      l_resource_id          := p_event.GetValueForParameter('NEW_RESOURCE_ID');
      l_resource_type_code   := p_event.GetValueForParameter('NEW_RESOURCE_TYPE_CODE');
      l_assignment_status_id := p_event.GetValueForParameter('NEW_ASSIGNMENT_STATUS_ID');
   else
      l_resource_id          := p_event.GetValueForParameter('RESOURCE_ID');
      l_resource_type_code   := p_event.GetValueForParameter('RESOURCE_TYPE_CODE');
      l_assignment_status_id := p_event.GetValueForParameter('ASSIGNMENT_STATUS_ID');
   end if;

   -- perform the validation only if the resource id is available. On update, if the
   -- resource is not changed, the JTF event does not publish the old value to the
   -- event.
   if ( l_resource_id is not null ) then
      -- get the task id from the task assignments table
      open get_task_asgn( l_task_assignment_id );
      fetch get_task_asgn into l_task_id;
      close get_task_asgn;

      -- get the task details from the task_id retrieved from the task asgn.
      open  get_tasks ( l_task_id );
      fetch get_tasks into l_source_id, l_source_type;
      close get_tasks;

      -- if the source type is SR then proceed with the check for security,
      -- if not, stop and return control

      if ((l_source_type = 'SR') AND (l_resource_type_code = 'RS_EMPLOYEE'))  then
         -- get the SR Type to set the context
         open  get_sr_type ( l_source_id );
         fetch get_sr_type into l_incident_type_id;
         close get_sr_type;

         -- set the SR Type contex
         cs_sr_security_context.set_sr_security_context (
            p_context_attribute          => 'SRTYPE_ID',
            p_context_attribute_value    => l_incident_type_id );

         -- query from the CS JTF resource secure view
         open  check_sr_access (l_resource_id );
         fetch check_sr_access into l_count;
         close check_sr_access;

         if ( l_count <= 0 or l_count is null ) then
	    -- resource assigned to the task does not have access to the SR type.
	    -- return an error status to the JTF tasks event api.
	    -- since this is a business event, need to set the value of the return
	    -- status on the busines event's parameter list. The jtf API that raised
	    -- the event will retrieve the return status from the parameter list

	    wf_event.addparametertolist(
	       p_name            => 'X_RETURN_STATUS',
               p_value           => 'ERROR',
               p_parameterlist   => p_event.parameter_list );

            fnd_message.set_name ('CS','CS_SR_JTF_TASK_ASSIGN_INVALID');
            fnd_message.set_token('API_NAME', l_api_name_full);
	    fnd_msg_pub.add;
         else
	    -- resource assigned to the task has access to the SR type and can be
	    -- assigned to the task. Return back a sucess status
	    wf_event.addparametertolist(
	       p_name            => 'X_RETURN_STATUS',
               p_value           => 'SUCCESS',
               p_parameterlist   => p_event.parameter_list );
         end if;
      end if;   -- if ( l_source_type = 'SR' )
   else
            -- resource assigned to the task is not an individual resource and hence has access to the SR
            -- type and can be assigned to the task. Return back a sucess status

            wf_event.addparametertolist(
               p_name            => 'X_RETURN_STATUS',
               p_value           => 'SUCCESS',
               p_parameterlist   => p_event.parameter_list );

   end if;  -- if ( l_resource_id is not null ) then

   -- Always return a success for the WF execution. If the assignment does not satisfy
   -- the service security rules, the JTF API that raised the event, will look for
   -- the value of the return status and will stop execution
   RETURN 'SUCCESS';

EXCEPTION
   WHEN OTHERS THEN
      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM );
      fnd_msg_pub.ADD;
      wf_event.addparametertolist(
         p_name            => 'X_RETURN_STATUS',
         p_value           => 'ERROR',
         p_parameterlist   => p_event.parameter_list );
      RETURN 'ERROR';
END SECURE_SR_TASK_ASSIGN;

--
-- Subscription function to the JTF task create and update event

FUNCTION SECURE_SR_TASK_OWNER (
   p_subscription_guid          IN     RAW,
   p_event                      IN OUT NOCOPY WF_EVENT_T )
RETURN VARCHAR2
IS
   -- cursor to fetch the resource, source object id and type for the task
   cursor get_tasks ( c_task_id   IN  NUMBER ) is
   select owner_id,         owner_type_code ,
	  source_object_id, source_object_type_code
   from   jtf_tasks_b
   where  task_id = c_task_id;

   l_task_id              NUMBER;
   l_owner_id             NUMBER;
   l_owner_type_code      VARCHAR2(240);
   l_source_id            NUMBER;
   l_source_type          VARCHAR2(240);

   -- cursor to fetch the SR Type id of the SR associated to the task
   cursor get_sr_type ( c_incident_id    IN  NUMBER ) is
   select incident_type_id
   from   cs_incidents_all_b
   where  incident_id = c_incident_id;

   l_incident_type_id     NUMBER;

   -- cursor that queries from the service JTF secure view. If security is
   -- enabled and is set to Standard, the following where predicate will be
   -- appended to the cursor select
   -- OR EXISTS
   -- ( SELECT '1'
   --   from fnd_user_resp_groups   ur,
   --        cs_sr_type_mapping     csmap
   --   WHERE   (cs_jtf_rs_resource_extns_sec.user_id IS NULL  )
   --   OR      cs_jtf_rs_resource_extns_sec.user_id =  ur.user_id
   --   AND  ur.responsibility_id      =  csmap.Responsibility_id
   --   AND  ur. responsibility application_id     =  csmap.application_id
   --   AND  csmap.business_usage      = 'AGENT'
   --   AND  csmap.incident_type_id    = sys_context(CS_SR_SECURITY, SRTYPE_ID)
   --   AND  trunc(sysdate) between trunc(nvl(csmap.start_date, sysdate))
   --                           and trunc(nvl(csmap.end_date,sysdate))  ))

   cursor check_sr_access ( c_resource_id   IN  NUMBER )is
   select 1
   from   cs_jtf_rs_resource_extns_sec
   where  resource_id = c_resource_id;

   l_count                         NUMBER;

   l_api_name             CONSTANT VARCHAR2(40) := '.SECURE_SR_TASK_OWNER';
   l_api_name_full                 VARCHAR2(70) := G_PKG_NAME || l_api_name;

BEGIN

   -- get the task_id from the event payload
   l_task_id := p_event.GetValueForParameter('TASK_ID');

   -- get the task details from the task_id retrieved from the task asgn.
   open  get_tasks ( l_task_id );
   fetch get_tasks into l_owner_id   , l_owner_type_code,
			l_source_id  , l_source_type;
   close get_tasks;

   -- if the source type is SR then proceed with the check for security,
   -- if not, stop and return control

   if ((l_source_type = 'SR') AND (l_owner_type_code = 'RS_EMPLOYEE')) then
      -- get the SR Type to set the context
      open  get_sr_type ( l_source_id );
      fetch get_sr_type into l_incident_type_id;
      close get_sr_type;

      -- set the SR Type contex
      cs_sr_security_context.set_sr_security_context (
         p_context_attribute          => 'SRTYPE_ID',
         p_context_attribute_value    => l_incident_type_id );

      -- query from the CS JTF resource secure view
      open  check_sr_access (l_owner_id );
      fetch check_sr_access into l_count;
      close check_sr_access;

      if ( l_count <= 0 or l_count is null ) then
	 -- resource assigned to the task does not have access to the SR type.
	 -- return an error status to the JTF tasks event api.
	 -- since this is a business event, need to set the value of the return
	 -- status on the busines event's parameter list. The jtf API that raised
	 -- the event will retrieve the return status from the parameter list
	 wf_event.addparametertolist(
	    p_name            => 'X_RETURN_STATUS',
            p_value           => 'ERROR',
            p_parameterlist   => p_event.parameter_list );

         fnd_message.set_name ('CS','CS_SR_JTF_TASK_OWNER_INVALID');
         fnd_message.set_token('API_NAME', l_api_name_full);
	 fnd_msg_pub.add;
      else
	 -- resource assigned to the task has access to the SR type and can be
	 -- assigned to the task. Return back a sucess status
	 wf_event.addparametertolist(
	    p_name            => 'X_RETURN_STATUS',
            p_value           => 'SUCCESS',
            p_parameterlist   => p_event.parameter_list );
      end if;
   else
        -- resource assigned to the task is not an inidividual resource and hence has access to the SR
        -- type and can be assigned to the task. Return back a sucess status

         wf_event.addparametertolist(
            p_name            => 'X_RETURN_STATUS',
            p_value           => 'SUCCESS',
            p_parameterlist   => p_event.parameter_list );
   end if;   -- if ( l_source_type = 'SR' )

   -- always return a success for the WF execution. If the owner does not satisfy
   -- the service security rules, the JTF API that raised the event, will look for
   -- the value of the return status and will stop execution
   RETURN 'SUCCESS';

EXCEPTION
   WHEN OTHERS THEN
      fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
      fnd_message.set_token ('P_TEXT',l_api_name_full||'-'||SQLERRM );
      fnd_msg_pub.ADD;
      wf_event.addparametertolist(
         p_name            => 'X_RETURN_STATUS',
         p_value           => 'ERROR',
         p_parameterlist   => p_event.parameter_list );
      RETURN 'ERROR';
END SECURE_SR_TASK_OWNER;

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
      x_msg_data          OUT NOCOPY VARCHAR2) IS

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_security_setting = 'ANONE' THEN
      DISABLE_SR_POLICIES(x_return_status => x_return_status);

   ELSIF (p_security_setting = 'BSTANDARD') OR (p_security_setting = 'CCUSTOM') THEN
      -- Drop the service owned VPD policies
       -- Drop the VPD policy associated with CS_INCIDENTS_B_SEC object

          DBMS_RLS.drop_policy
                 (object_schema => 'APPS',
                  object_name   => 'CS_INCIDENTS_B_SEC',
                  policy_name   => 'CS_SR_SEC_SR_ACCESS');

       -- Drop the VPD policy associated with CS_SR_TYPES_SELECT_SEC object
          DBMS_RLS.drop_policy
                 (object_schema => 'APPS',
                  object_name   => 'CS_SR_TYPES_SELECT_SEC',
                  policy_name       => 'CS_SR_SEC_SRTYPE_ACCESS');

       -- Drop the VPD policy associated with CS_JTF_RS_RESOURCE_EXTNS_SEC object
          DBMS_RLS.drop_policy
                 (object_schema => 'APPS',
                  object_name   => 'CS_JTF_RS_RESOURCE_EXTNS_SEC',
                policy_name   => 'CS_SR_JTF_RESOURCE_ACCESS');

       -- Drop the VPD policy associated with CS_SR_ACCESS_RESP_SEC object
          DBMS_RLS.drop_policy
                 (object_schema     => 'APPS',
                  object_name       => 'CS_SR_ACCESS_RESP_SEC',
                  policy_name       => 'CS_SR_SEC_RESP_ACCESS');

      -- re create service owned VPD policies as static VPD policies

       -- Create the VPD policy associated with CS_INCIDENTS_B_SEC object
          DBMS_RLS.add_policy
                 (object_schema   => 'APPS',
                  object_name     => 'CS_INCIDENTS_B_SEC',
                  policy_name     => 'CS_SR_SEC_SR_ACCESS',
                  function_schema => 'APPS',
                  policy_function => 'CS_SR_SECURITY_UTIL.SET_SR_ACCESS',
                  statement_types => 'SELECT',
                  static_policy   => FALSE,
                  long_predicate  => TRUE );

       -- Create the VPD policy associated with CS_SR_TYPES_SELECT_SEC object
          DBMS_RLS.add_policy
                 (object_schema   => 'APPS',
                  object_name     => 'CS_SR_TYPES_SELECT_SEC',
                  policy_name     => 'CS_SR_SEC_SRTYPE_ACCESS',
                  function_schema => 'APPS',
                  policy_function => 'FND_GENERIC_POLICY.GET_PREDICATE',
                  statement_types => 'SELECT',
                  static_policy   => FALSE,
                  long_predicate  => TRUE );

       -- Create the VPD policy associated with CS_JTF_RS_RESOURCE_EXTNS_SEC object
          DBMS_RLS.add_policy
                 (object_schema   => 'APPS',
                  object_name     => 'CS_JTF_RS_RESOURCE_EXTNS_SEC',
                  policy_name     => 'CS_SR_JTF_RESOURCE_ACCESS',
                  function_schema => 'APPS',
                  policy_function => 'FND_GENERIC_POLICY.GET_PREDICATE',
                  statement_types => 'SELECT',
                  static_policy   => FALSE,
                  long_predicate  => TRUE );

       -- Create the VPD policy associated with CS_SR_ACCESS_RESP_SEC object
          DBMS_RLS.add_policy
                 (object_schema   => 'APPS',
                  object_name     => 'CS_SR_ACCESS_RESP_SEC',
                  policy_name     => 'CS_SR_SEC_RESP_ACCESS',
                  function_schema => 'APPS',
                  policy_function => 'FND_GENERIC_POLICY.GET_PREDICATE',
                  statement_types => 'SELECT',
                  static_policy   => FALSE,
                  long_predicate  => TRUE );

   END IF;

EXCEPTION
     WHEN others THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MSG_PUB.Count_And_Get
          (p_count => x_msg_count,
           p_data  => x_msg_data );

END Alter_SR_Policies;

END CS_SR_SECURITY_UTIL;

/
