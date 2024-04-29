--------------------------------------------------------
--  DDL for Package Body CSF_ACCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_ACCESS_PKG" AS
/* $Header: csfvaccb.pls 115.3.1157.1 2002/03/22 17:21:08 pkm ship       $ */

PROCEDURE RUN_COMMAND
  ( p_command IN VARCHAR2
  )
is
/********************************************************
 Name:
   Run_Command

 Purpose:
   Execute a dynamic SQL command.

 Arguments:
   p_command   The dynamic SQL command to be executed.

 Known Limitations:

 Notes:

 History:
   ??-???-???? ?     Created

********************************************************/
  v_cursor_id INTEGER;
  v_dummy     INTEGER;
  v_sqlcode   NUMBER;
BEGIN
  v_cursor_id := DBMS_SQL.OPEN_CURSOR;
  DBMS_SQL.PARSE( v_cursor_id, p_command, DBMS_SQL.V7 );
  v_dummy := DBMS_SQL.EXECUTE( v_cursor_id );
  DBMS_SQL.CLOSE_CURSOR( v_cursor_id );
EXCEPTION
  WHEN OTHERS
  THEN
    v_sqlcode := SQLCODE;
    DBMS_SQL.CLOSE_CURSOR( v_cursor_id );
  RAISE;
END RUN_COMMAND;

FUNCTION IsExisting
  ( x_acc       IN VARCHAR2
  , x_pk        IN VARCHAR2
  , x_pk_id     IN NUMBER
  , x_server_id IN NUMBER
  ) RETURN NUMBER
IS
/********************************************************
 Name:
   IsExisting

 Purpose:
   Check whether access record exists and return the
   number of users interested in this access record.

 Arguments:
   x_acc         Name of the access table.
   x_pk          Name of the PK column.
   x_pk_id       Value of the PK.
   x_server_id   Id of the MDG server.

 Known Limitations:

 Notes:

 History:
   ??-???-???? ?     Created

********************************************************/
  v_id        NUMBER;
  v_dummy     NUMBER;
  v_statement VARCHAR2(1000);
  v_counter   NUMBER;
BEGIN
  v_counter := 0;
  v_statement := 'select counter'
               ||' from '||x_acc
               ||' where '||x_pk||' = '||x_pk_id
               ||' and server_id = '||x_server_id;
  v_id := DBMS_SQL.OPEN_CURSOR;

  DBMS_SQL.PARSE
    ( v_id
    , v_statement
    , DBMS_SQL.V7
    );

  DBMS_SQL.DEFINE_COLUMN
    ( v_id
    , 1
    , v_counter
    );

  v_dummy := DBMS_SQL.EXECUTE(v_id);

  IF DBMS_SQL.FETCH_ROWS(v_id) <> 0
  THEN
    DBMS_SQL.COLUMN_VALUE(v_id, 1, v_counter);
  END IF;
  DBMS_SQL.CLOSE_CURSOR(v_id);

  RETURN v_counter;
END IsExisting;

PROCEDURE InsertAcc
  ( x_acc       IN VARCHAR2
  , x_pk        IN VARCHAR2
  , x_pk_id     IN NUMBER
  , x_server_id IN NUMBER
  )
IS
/********************************************************
 Name:
   InsertAcc

 Purpose:
   Insert access record.

 Arguments:
   x_acc         Name of the access table.
   x_pk          Name of the PK column.
   x_pk_id       Value of the PK.
   x_server_id   Id of the MDG server.

 Known Limitations:

 Notes:

 History:
   ??-???-???? ?     Created

********************************************************/
  v_statement varchar2(1000);
BEGIN
  v_statement := 'insert into '||x_acc
               ||'('||x_pk||',server_id, last_update_date, last_updated_by, '
               ||'creation_date, created_by, counter) '
               ||'values('||x_pk_id||','||x_server_id
               ||',sysdate,1,sysdate,1,1)';
  RUN_COMMAND
    ( p_command => v_statement
    );
END InsertAcc;

FUNCTION UpdateAcc
  ( x_acc       IN VARCHAR2
  , x_pk        IN VARCHAR2
  , x_pk_id     IN NUMBER
  , x_server_id IN NUMBER
  , x_op        IN VARCHAR2
  ) RETURN NUMBER
IS
/********************************************************
 Name:
   UpdateAcc

 Purpose:
   Update the access record. If the access record does
   not exist, insert the access record, else increase the
   counter. If it is a deletion, decrease the counter. If
   last record, delete the access record.

   Return-value 0 means the record has been inserted.
   Return-value 1 means the record has been updated.

 Arguments:
   x_acc         Name of the access table.
   x_pk          Name of the PK column.
   x_pk_id       Value of the PK.
   x_server_id   Id of the MDG server.
   x_op          Operation to be performed: '+' for
                 increase, '-' for decrease.

 Known Limitations:

 Notes:

 History:
   ??-???-???? ?     Created

********************************************************/
  v_id        NUMBER;
  v_dummy     NUMBER;
  v_statement VARCHAR2(1000);
  v_return    NUMBER;
  v_counter   NUMBER;
BEGIN
  v_return := 0;
  v_counter := IsExisting
                 ( x_acc       => x_acc
                 , x_pk        => x_pk
                 , x_pk_id     => x_pk_id
                 , x_server_id => x_server_id
                 );

  IF v_counter = 0
  THEN
    IF x_op = '+'
    THEN
      InsertAcc
        ( x_acc       => x_acc
        , x_pk        => x_pk
        , x_pk_id     => x_pk_id
        , x_server_id => x_server_id
        );
    END IF;
    RETURN 0;
  END IF;

  IF x_op = '+'
  THEN
    v_counter := v_counter + 1;
  ELSIF x_op = '-'
  THEN
    v_counter := v_counter - 1;
  END IF;

  IF v_counter > 0
  THEN
    v_statement := 'update '||x_acc
                 ||' set counter = '||v_counter
                 ||' where '||x_pk||'='||x_pk_id
                 || ' and server_id ='||x_server_id;
  ELSE
    v_statement := 'delete from '||x_acc
                 ||' where '||x_pk||'='||x_pk_id
                 ||' and server_id ='||x_server_id;
  END IF;

  RUN_COMMAND
    ( p_command => v_statement
    );

  RETURN 0;
END UpdateAcc;

Function IsMobileUser
  ( x_resource_id IN NUMBER
  ) RETURN NUMBER
IS
/********************************************************
 Name:
   IsMobileUser

 Purpose:
   Check if it is a mobile user. Return 0 if it's not,
   return 1 if it is.

 Arguments:
   x_resource_id   The resource_id of the user to be
                   checked.

 Known Limitations:

 Notes:

 History:
   ??-???-???? ?     Created

********************************************************/
  CURSOR c_mobile_user
    ( x_resource_id NUMBER
    )
  IS
    SELECT 1
    FROM   asg_device_users
    WHERE  resource_id = x_resource_id;

  v_dummy NUMBER;

BEGIN
  OPEN c_mobile_user
    ( x_resource_id => x_resource_id
    );
  FETCH c_mobile_user
  into v_dummy;
  IF c_mobile_user%NOTFOUND
  THEN
    CLOSE c_mobile_user;
    RETURN 0;
  END IF;

  CLOSE c_mobile_user;
  RETURN 1;

END IsMobileUser;

Function GetServerId
  ( x_resource_id IN     NUMBER
  , x_server_id      OUT NUMBER
  ) RETURN NUMBER
IS
/********************************************************
 Name:
   GetServerId

 Purpose:
   Get Server id of mobile user.

   Return-value -1 means server_id not found.
   Return-value 0 means server_id found.

 Arguments:
   x_resource_id   The resource_id of the user to be
                   checked.
   x_server_id     The retrieved server_id (if found).

 Known Limitations:

 Notes:

 History:
   ??-???-???? ?     Created

********************************************************/
  CURSOR c_server_id
    ( x_resource_id NUMBER
    )
  IS
    SELECT server_id
    FROM   asg_server_resources
    WHERE  resource_id = x_resource_id;

BEGIN
  OPEN c_server_id
    ( x_resource_id => x_resource_id
    );
  FETCH c_server_id
  INTO x_server_id;
  IF c_server_id%NOTFOUND
  THEN
    CLOSE c_server_id;
    RETURN -1;
  END IF;

  CLOSE c_server_id;
  RETURN 0;
END GetServerId;

Procedure UpdateAccesses_Partyid
  ( x_party_id  IN NUMBER
  , x_server_id IN NUMBER
  , x_op        IN VARCHAR2
  )
IS
/********************************************************
 Name:
   UpdateAccesses_Partyid

 Purpose:
   Update Service Access records based on party_id.

 Arguments:
   x_party_id    The id of the party for which the access
                 record must be updated.
   x_server_id   Id of the MDG server.
   x_op          Operation to be performed: '+' for
                 increase, '-' for decrease.

 Known Limitations:

 Notes:

 History:
   ??-???-???? ?     Created

********************************************************/
  v_ret NUMBER;
BEGIN
  -- Update access table for this party_id
  v_ret := UpdateAcc
             ( x_acc       => 'ASG_PARTY_ACC'
             , x_pk        => 'PARTY_ID'
             , x_pk_id     => x_party_id
             , x_server_id => x_server_id
             , x_op        => x_op
             );
END UpdateAccesses_Partyid;

Procedure UpdateAccesses_Incidentid
  ( x_incident_id IN NUMBER
  , x_server_id   IN NUMBER
  , x_op          IN VARCHAR2
  )
IS
/********************************************************
 Name:
   UpdateAccesses_Incidentid

 Purpose:
   Update Service Access records based on incident_id.

 Arguments:
   x_incident_id   The id of the incident for which the
                   access record must be updated.
   x_server_id     Id of the MDG server.
   x_op            Operation to be performed: '+' for
                   increase, '-' for decrease.

 Known Limitations:

 Notes:

 History:
   ??-???-???? ?        Created
   29-OCT-2001 MRAAP    Added cursor to retrieve
                        party_id of Installed At address
                        of Task. This is needed, because
                        this customer may differ from
                        the Service Request customer.

                        This is part of the fix for
                        bug 1931013.
********************************************************/
  CURSOR c_customer
    ( x_incident_id NUMBER
    )
  IS
    SELECT customer_id
    FROM   cs_incidents_all_b
    WHERE  incident_id = x_incident_id;

  CURSOR c_primary_contact
    ( x_incident_id NUMBER
    )
  IS
    SELECT party_id
    FROM   cs_hz_sr_contact_points contact
    WHERE  contact.incident_id = x_incident_id
    AND    contact.primary_flag = 'Y';

  CURSOR c_installed_at_party
    ( x_incident_id NUMBER
    )
  IS
    SELECT hps.party_id
    FROM   hz_party_sites hps
    ,      jtf_tasks_b jt_b
    WHERE  jt_b.source_object_id = x_incident_id
    AND    jt_b.source_object_type_code = 'SR'
    AND    jt_b.address_id = hps.party_site_id;

  v_party_id NUMBER;
  v_ret      NUMBER;
BEGIN
  -- Update access table for this incident_id
  v_ret := UpdateAcc
             ( x_acc       => 'ASG_INCIDENT_ACC'
             , x_pk        => 'INCIDENT_ID'
             , x_pk_id     => x_incident_id
             , x_server_id => x_server_id
             , x_op        => x_op
             );

  -- Find corresponding Customer party_id
  OPEN c_customer
    ( x_incident_id => x_incident_id
    );
  FETCH c_customer
  INTO v_party_id;
  IF c_customer%NOTFOUND
  OR v_party_id IS NULL
  THEN
    CLOSE c_customer;
  ELSE
    -- Call to update access table for this party_id
    UpdateAccesses_Partyid
      ( x_party_id  => v_party_id
      , x_server_id => x_server_id
      , x_op        => x_op
      );
    CLOSE c_customer;
  END IF;

  -- Find corresponding Primary Contact party_id
  OPEN c_primary_contact
    ( x_incident_id => x_incident_id
    );
  FETCH c_primary_contact
  INTO v_party_id;
  IF c_primary_contact%NOTFOUND
  OR v_party_id IS NULL
  THEN
    CLOSE c_primary_contact;
  ELSE
    -- Call to update access table for this party_id
    UpdateAccesses_Partyid
      ( x_party_id  => v_party_id
      , x_server_id => x_server_id
      , x_op        => x_op
      );
    CLOSE c_primary_contact;
  END IF;

  -- Find corresponding Installed At party_id
  OPEN c_installed_at_party
    ( x_incident_id
    );
  FETCH c_installed_at_party
  INTO v_party_id;
  IF c_installed_at_party%NOTFOUND
  OR v_party_id IS NULL
  THEN
    CLOSE c_installed_at_party;
  ELSE
    -- Call to update access table for this party_id
    UpdateAccesses_Partyid
      ( x_party_id  => v_party_id
      , x_server_id => x_server_id
      , x_op        => x_op
      );
    CLOSE c_installed_at_party;
  END IF;

END UpdateAccesses_Incidentid;

Procedure UpdateAccesses_Taskid
  ( x_task_id   IN NUMBER
  , x_server_id IN NUMBER
  , x_op        IN VARCHAR2
  )
IS
/********************************************************
 Name:
   UpdateAccesses_Taskid

 Purpose:
   Update Service Access records based on task_id.

   Determine if the task needs to be replicated to the
   mobile client, according to the following conditions:

   - the task is not deleted (deleted_flag is not 'Y')
   - the type of the task is 'Dispatch' or the task is
     private or the task is an departure or arrival
     task.

   If the conditions apply, proceed with inserting/updating
   the access record in ASG_TASK_ACC and make a call to
   see if the Service Request related to the task needs
   to be replicated as well.

 Arguments:
   x_task_id     The id of the task for which the access
                 record must be updated.
   x_server_id   Id of the MDG server.
   x_op          Operation to be performed: '+' for
                 increase, '-' for decrease.

 Known Limitations:

 Notes:

 History:
   ??-???-???? ?        Created
   16-OCT-2001 MRAAP    Modified WHERE-clause of cursor
                        c_task to include task with
		        type_id = 21 (arrival task).
		        This is a fix for bug 2055402.

********************************************************/
  CURSOR c_service_req
    ( x_task_id NUMBER
    )
  IS
    SELECT source_object_id
    FROM   jtf_tasks_b
    WHERE  source_object_type_code = 'SR'
    AND    task_id = x_task_id;

  CURSOR c_task
    ( x_task_id NUMBER
    )
  IS
    SELECT task_id
    FROM   jtf_tasks_b      jt_b
    ,      jtf_task_types_b jtt_b
    WHERE  jt_b.task_id = x_task_id
    AND    jt_b.task_type_id = jtt_b.task_type_id
    AND    NVL(jt_b.deleted_flag, 'N') <> 'Y'
    AND    (  jtt_b.rule = 'DISPATCH'
           OR jt_b.private_flag = 'Y'
           OR jt_b.task_type_id IN (20, 21)
           );

  v_incident_id NUMBER;
  v_task_id     NUMBER;

  v_ret         NUMBER;
BEGIN
  OPEN c_task
    ( x_task_id => x_task_id
    );
  FETCH c_task
  INTO v_task_id;
  IF (c_task%FOUND)
  THEN
    -- Update access table for this task_id
    v_ret := UpdateAcc
               ( x_acc       => 'ASG_TASK_ACC'
               , x_pk        => 'TASK_ID'
               , x_pk_id     => x_task_id
               , x_server_id => x_server_id
               , x_op        => x_op
               );

    -- Fetch corresponding Service Request incident_id
    OPEN c_service_req
      ( x_task_id => x_task_id
      );
    FETCH c_service_req
    INTO v_incident_id;
    IF c_service_req%NOTFOUND
    THEN
      CLOSE c_service_req;
    ELSE
      -- Call to update access table for this incident_id
      UpdateAccesses_Incidentid
        ( x_incident_id => v_incident_id
        , x_server_id   => x_server_id
        , x_op          => x_op
        );
      CLOSE c_service_req;

    END IF;
  END IF;

  CLOSE c_task;

END UpdateAccesses_Taskid;

PROCEDURE UpdateMobileUserAcc
  ( x_resource_id IN NUMBER
  , x_server_id   IN NUMBER
  , x_op          IN VARCHAR2
  )
IS
/********************************************************
 Name:
   UpdateMobileUserAcc

 Purpose:
   Add/Delete all accesses related to a mobile User
   This procedure is called from Create/Delete Mobile
   User.

 Arguments:
   x_resource_id   Resource_id of the mobile user.
   x_server_id     Id of the MDG server.
   x_op            Operation to be performed: '+' for
                   increase, '-' for decrease.

 Known Limitations:

 Notes:

 History:
   ??-???-???? ?     Created

********************************************************/
  CURSOR c_tasks
    ( x_resource_id number
    )
  IS
    SELECT task_id
    FROM   jtf_task_assignments
    WHERE  resource_id = x_resource_id;

  v_task_id NUMBER;

BEGIN
  OPEN c_tasks
    ( x_resource_id => x_resource_id
    );
  LOOP
    FETCH c_tasks
    INTO v_task_id;
    EXIT WHEN c_tasks%NOTFOUND;
    UpdateAccesses_Taskid
      ( x_task_id   => v_task_id
      , x_server_id => x_Server_id
      , x_op        => x_op
      );
  END LOOP;
  CLOSE c_tasks;

EXCEPTION
  WHEN OTHERS
  THEN
    RAISE_APPLICATION_ERROR(-20000,'Mobile: Failed in updating ' || v_task_id);
END UpdateMobileUserAcc;

PROCEDURE INCIDENT_POST_INSERT
  ( x_return_status OUT VARCHAR2
  )
IS
BEGIN
  x_return_status := 'S';
END INCIDENT_POST_INSERT;

PROCEDURE INCIDENT_PRE_UPDATE
  ( x_return_status OUT VARCHAR2
  )
IS
/********************************************************
 Name:
   INCIDENT_PRE_UPDATE

 Purpose:
   Retrieve more info about the incident (old and new values)
   and call the sr-contact-trigger-handler.

 Arguments:
   x_return_status   'S' indicates successfull completion.
                     Any other value indicates an error.

 Known Limitations:

 Notes:

 History:
   ??-???-???? ?     Created

********************************************************/
  CURSOR c_customer_id
    ( b_incident_id NUMBER
    )
  IS
    SELECT customer_id
    FROM   cs_incidents_all
    WHERE  incident_id = b_incident_id;

  incident_id   NUMBER;

  o_customer_id NUMBER;
  n_customer_id NUMBER;
BEGIN
  incident_id   := CS_ServiceRequest_Pvt.user_hooks_rec.Request_ID;
  o_customer_id := CS_ServiceRequest_Pvt.user_hooks_rec.customer_id;

  OPEN c_customer_id
    ( b_incident_id => incident_id
    );
  FETCH c_customer_id
  INTO o_customer_id;
  CLOSE c_customer_id;

  Incident_Trigger_Handler
    ( incident_id   => incident_id
    , o_customer_id => o_customer_id
    , n_customer_id => n_customer_id
    , trigger_mode  => 'ON-UPDATE'
    );

  Sr_Contact_Trigger_Handler
    ( x_incident_id => incident_id
    , x_op          => '-'
    );

  x_return_status := 'S';

END INCIDENT_PRE_UPDATE;

PROCEDURE INCIDENT_POST_UPDATE
  ( x_return_status OUT VARCHAR2
  )
IS
/********************************************************
 Name:
   INCIDENT_POST_UPDATE

 Purpose:
   Retrieve the incident_id
   and call the sr-contact-trigger-handler.

 Arguments:
   x_return_status   'S' indicates successfull completion.
                     Any other value indicates an error.

 Known Limitations:

 Notes:

 History:
   ??-???-???? ?     Created

********************************************************/
  incident_id NUMBER;
BEGIN
  incident_id := CS_ServiceRequest_Pvt.user_hooks_rec.Request_ID;

  Sr_Contact_Trigger_Handler
    ( x_incident_id => incident_id
    , x_op          => '+'
    );

  x_return_status := 'S';

END INCIDENT_POST_UPDATE;

PROCEDURE TASKS_POST_INSERT
  ( x_return_status OUT VARCHAR2
  )
IS
/********************************************************
 Name:
   TASKS_POST_INSERT

 Purpose:
   Retrieve more info about the task (new values)
   and call the task-trigger-handler.

 Arguments:
   x_return_status   'S' indicates successfull completion.
                     Any other value indicates an error.

 Known Limitations:

 Notes:

 History:
   29-NOV-2001 MRAAP     Created

********************************************************/
  n_task_id                 NUMBER;
  n_source_object_id        NUMBER;
  n_source_object_name      VARCHAR2(80);
  n_source_object_type_code VARCHAR2(30);
BEGIN
  n_task_id                 := Jtf_Tasks_Pub.p_task_user_hooks.Task_Id;
  n_source_object_id        := Jtf_Tasks_Pub.p_task_user_hooks.Source_Object_Id;
  n_source_object_name      := Jtf_Tasks_Pub.p_task_user_hooks.Source_Object_Name;
  n_source_object_type_code := Jtf_Tasks_Pub.p_task_user_hooks.Source_Object_Type_Code;

  Tasks_Trigger_Handler
    ( o_task_id                 => NULL
    , o_source_object_id        => NULL
    , o_source_object_name      => NULL
    , o_source_object_type_code => NULL
    , n_task_id                 => n_task_id
    , n_source_object_id        => n_source_object_id
    , n_source_object_name      => n_source_object_name
    , n_source_object_type_code => n_source_object_type_code
    , trigger_mode              => 'ON-INSERT'
    );

  x_return_status := 'S';
END TASKS_POST_INSERT;

PROCEDURE TASKS_PRE_UPDATE
  ( x_return_status OUT VARCHAR2
  )
IS
/********************************************************
 Name:
   TASKS_PRE_UPDATE

 Purpose:
   Retrieve more info about the task (old and new values)
   and call the task-trigger-handler.

 Arguments:
   x_return_status   'S' indicates successfull completion.
                     Any other value indicates an error.

 Known Limitations:

 Notes:

 History:
   ??-???-???? ?     Created

********************************************************/
  CURSOR c_task
    ( b_task_id NUMBER
    )
  IS
    SELECT source_object_id
    ,      source_object_name
    ,      source_object_type_code
    FROM   jtf_tasks_b
    WHERE  task_id =  b_task_id;

  task_id                   NUMBER;

  n_source_object_id        NUMBER;
  o_source_object_id        NUMBER;
  n_source_object_name      VARCHAR2(80);
  o_source_object_name      VARCHAR2(80);
  n_source_object_type_code VARCHAR2(30);
  o_source_object_type_code VARCHAR2(30);
BEGIN
  task_id                   := Jtf_Tasks_Pub.p_task_user_hooks.Task_Id;
  n_source_object_id        := Jtf_Tasks_Pub.p_task_user_hooks.Source_Object_Id;
  n_source_object_name      := Jtf_Tasks_Pub.p_task_user_hooks.Source_Object_Name;
  n_source_object_type_code := Jtf_Tasks_Pub.p_task_user_hooks.Source_Object_Type_Code;

  OPEN c_task
    ( b_task_id => task_id
    );
  FETCH c_task
  INTO o_source_object_id
  ,    o_source_object_name
  ,    o_source_object_type_code;
  CLOSE c_task;

  Tasks_Trigger_Handler
    ( o_task_id                 => task_id
    , o_source_object_id        => o_source_object_id
    , o_source_object_name      => o_source_object_name
    , o_source_object_type_code => o_source_object_type_code
    , n_task_id                 => task_id
    , n_source_object_id        => n_source_object_id
    , n_source_object_name      => n_source_object_name
    , n_source_object_type_code => n_source_object_type_code
    , trigger_mode              => 'ON-UPDATE'
    );

  x_return_status := 'S';

END TASKS_PRE_UPDATE;

PROCEDURE TASKS_POST_UPDATE
  ( x_return_status OUT VARCHAR2
  )
IS
BEGIN
  x_return_status := 'S';
END TASKS_POST_UPDATE;

PROCEDURE TASKS_PRE_DELETE
  ( x_return_status OUT VARCHAR2
  )
IS
BEGIN
  x_return_status := 'S';
END TASKS_PRE_DELETE;

PROCEDURE TASK_ASSIGN_POST_INSERT
  ( x_return_status OUT VARCHAR2
  )
IS
/********************************************************
 Name:
   TASK_ASSIGN_POST_INSERT

 Purpose:
   Retrieve more info about the task_assignment (new values)
   and call the task-assignment-trigger-handler.

 Arguments:
   x_return_status   'S' indicates successfull completion.
                     Any other value indicates an error.

 Known Limitations:

 Notes:

 History:
   ??-???-???? ?     Created

********************************************************/
  n_task_assignment_id NUMBER;
  n_task_id            NUMBER;
  n_resource_id        NUMBER;
BEGIN
  n_task_assignment_id := Jtf_Task_Assignments_Pub.p_task_assignments_user_hooks.Task_Assignment_Id;
  n_task_id            := Jtf_Task_Assignments_Pub.p_task_assignments_user_hooks.Task_Id;
  n_resource_id        := Jtf_Task_Assignments_Pub.p_task_assignments_user_hooks.Resource_Id;

  Task_Assign_Trigger_Handler
    ( o_task_assignment_id => n_task_assignment_id
    , o_task_id            => n_task_id
    , o_resource_id        => n_resource_id
    , n_task_assignment_id => n_task_assignment_id
    , n_task_id            => n_task_id
    , n_resource_id        => n_resource_id
    , Trigger_Mode         => 'ON-INSERT'
    );

  x_return_status :='S';
END TASK_ASSIGN_POST_INSERT;

PROCEDURE TASK_ASSIGN_PRE_UPDATE
  ( x_return_status OUT VARCHAR2
  )
IS
/********************************************************
 Name:
   TASK_ASSIGN_PRE_UPDATE

 Purpose:
   Retrieve more info about the task_assignment (old and new values)
   and call the task-assignment-trigger-handler.

 Arguments:
   x_return_status   'S' indicates successfull completion.
                     Any other value indicates an error.

 Known Limitations:

 Notes:

 History:
   ??-???-???? ?     Created

********************************************************/
  CURSOR c_task_assign
    ( b_task_assignment_id NUMBER
    )
  IS
    SELECT task_id
    ,      resource_id
    FROM   jtf_task_assignments
    WHERE  task_assignment_id = b_task_assignment_id;

  task_assignment_id NUMBER;

  o_task_id          NUMBER;
  n_task_id          NUMBER;
  o_resource_id      NUMBER;
  n_resource_id      NUMBER;
BEGIN
  task_assignment_id := Jtf_Task_Assignments_Pub.p_task_assignments_user_hooks.Task_Assignment_Id;
  n_task_id          := Jtf_Task_Assignments_Pub.p_task_assignments_user_hooks.Task_Id;
  n_resource_id      := Jtf_Task_Assignments_Pub.p_task_assignments_user_hooks.Resource_Id;

  OPEN c_task_assign
    ( b_task_assignment_id => task_assignment_id
    );
  FETCH c_task_assign
  INTO o_task_id
  ,    o_resource_id;
  CLOSE c_task_assign;

  Task_Assign_Trigger_Handler
    ( o_task_assignment_id => task_assignment_id
    , o_task_id            => o_task_id
    , o_resource_id        => o_resource_id
    , n_task_assignment_id => task_assignment_id
    , n_task_id            => n_task_id
    , n_resource_id        => n_resource_id
    , trigger_mode         => 'ON-UPDATE'
    );

  x_return_status := 'S';
END TASK_ASSIGN_PRE_UPDATE;

PROCEDURE TASK_ASSIGN_POST_UPDATE
  ( x_return_status OUT VARCHAR2
  )
IS
BEGIN
  x_return_status := 'S';
END TASK_ASSIGN_POST_UPDATE;

PROCEDURE TASK_ASSIGN_PRE_DELETE
  ( x_return_status OUT VARCHAR2
  )
IS
/********************************************************
 Name:
   TASK_ASSIGN_PRE_DELETE

 Purpose:
   Retrieve more info about the task_assignment (old values)
   and call the task-assignment-trigger-handler.

 Arguments:
   x_return_status   'S' indicates successfull completion.
                     Any other value indicates an error.

 Known Limitations:

 Notes:

 History:
   ??-???-???? ?     Created

********************************************************/
  CURSOR c_task_assign
    ( b_task_assignment_id NUMBER
    )
  IS
    SELECT task_id
    ,      resource_id
    FROM   jtf_task_assignments jta
    WHERE  task_assignment_id = b_task_assignment_id;

  r_task_assign c_task_assign%ROWTYPE;

  o_task_assignment_id NUMBER;
  o_task_id            NUMBER;
  o_resource_id        NUMBER;
BEGIN
  o_task_assignment_id := Jtf_Task_Assignments_Pub.p_task_assignments_user_hooks.Task_Assignment_Id;

  OPEN c_task_assign
    ( b_task_assignment_id => o_task_assignment_id
    );
  FETCH c_task_assign
  INTO r_task_assign;
  CLOSE c_task_assign;

  o_task_id := r_task_assign.task_id;
  o_resource_id := r_task_assign.resource_id;

  Task_Assign_Trigger_Handler
    ( o_task_assignment_id => o_task_assignment_id
    , o_task_id            => o_task_id
    , o_resource_id        => o_resource_id
    , n_task_assignment_id => o_task_assignment_id
    , n_task_id            => o_task_id
    , n_resource_id        => o_resource_id
    , trigger_mode         => 'ON-DELETE'
    );

  x_return_status := 'S';
END TASK_ASSIGN_PRE_DELETE;

PROCEDURE CUST_RELATIONS_POST_INSERT
  ( x_return_status OUT VARCHAR2
  )
IS
/********************************************************
 Name:
   CUST_RELATIONS_POST_INSERT

 Purpose:
   Retrieve more info about the ship_to_address(new values)
   and call the ship-to-address-trigger-handler.

 Arguments:
   x_return_status   'S' indicates successfull completion.
                     Any other value indicates an error.

 Known Limitations:

 Notes:

 History:
   21-JAN-2002 ASOYKAN  Created

********************************************************/
  CURSOR c_cust_relations
    ( b_rs_cust_relation_id NUMBER
    )
  IS
    SELECT crcr.resource_id
    ,      hps.party_id
    FROM   csp_rs_cust_relations  crcr
    ,      hz_cust_acct_sites_all hcas_all
    ,      hz_party_sites         hps
    WHERE  crcr.customer_id       = hcas_all.cust_account_id
    AND    hcas_all.party_site_id = hps.party_site_id
    AND    rs_cust_relation_id    = b_rs_cust_relation_id
    AND    crcr.resource_type     = 'RS_EMPLOYEE';

  r_cust_relations c_cust_relations%ROWTYPE;

  rs_cust_relation_id csp_rs_cust_relations.rs_cust_relation_id%TYPE;
BEGIN
  rs_cust_relation_id := csp_ship_to_address_pvt.g_rs_cust_relation_id;

  OPEN c_cust_relations
    ( b_rs_cust_relation_id => rs_cust_relation_id
    );
  FETCH c_cust_relations
  INTO r_cust_relations;
  CLOSE c_cust_relations;

  Cust_Relations_Trigger_Handler
    ( rs_cust_relation_id => rs_cust_relation_id
    , o_party_id          => r_cust_relations.party_id
    , n_party_id          => r_cust_relations.party_id
    , resource_id         => r_cust_relations.resource_id
    , trigger_mode        => 'ON-INSERT'
    );

  x_return_status := 'S';
END CUST_RELATIONS_POST_INSERT;

PROCEDURE INCIDENT_TRIGGER_HANDLER
  ( incident_id   NUMBER
  , o_customer_id NUMBER
  , n_customer_id NUMBER
  , trigger_mode  VARCHAR2
  )
IS
/********************************************************
 Name:
   INCIDENT_TRIGGER_HANDLER

 Purpose:
   This procedure acts as a trigger on CS_INCIDENTS_ALL
   and is fired in case of insert, update or delete.

 Arguments:


 Known Limitations:

 Notes:

 History:
   ??-???-???? ?       Created
********************************************************/
  CURSOR c_incident
    ( v_incident_id NUMBER
    )
  IS
    SELECT server_id
    FROM   asg_incident_acc
    WHERE  incident_id = v_incident_id;

  v_server_id NUMBER;
BEGIN
  -- customer associated with incident is changed
  IF trigger_mode = 'ON-UPDATE'
  AND o_customer_id <> n_customer_id
  THEN
    OPEN c_incident
      ( v_incident_id => incident_id
      );

    -- Find all the Middle-tiers associated with this SR.
    -- Remove the old Party associated with all these middle-tiers
    -- Add the new Party associated with all these middle-tiers
    LOOP
      FETCH c_incident
      INTO v_server_id;
      IF c_incident%NOTFOUND
      THEN
        EXIT;
      END IF;

      -- Remove the old customer and add the new one
      UpdateAccesses_Partyid
        ( x_party_id  => o_customer_id
	, x_server_id => v_server_id
	, x_op        => '-'
	);
      UpdateAccesses_Partyid
        ( x_party_id  => n_customer_id
	, x_server_id => v_server_id
	, x_op        => '+'
	);

    END LOOP;
    CLOSE c_incident;
  END IF;
END INCIDENT_TRIGGER_HANDLER;

PROCEDURE TASKS_TRIGGER_HANDLER
  ( o_task_id                 NUMBER
  , o_source_object_id        NUMBER
  , o_source_object_name      VARCHAR2
  , o_source_object_type_code VARCHAR2
  , n_task_id                 NUMBER
  , n_source_object_id        NUMBER
  , n_source_object_name      VARCHAR2
  , n_source_object_type_code VARCHAR2
  , trigger_mode              VARCHAR2
  )
IS
/********************************************************
 Name:
   TASKS_TRIGGER_HANDLER

 Purpose:
   This procedure acts as a trigger on JTF_TASKS_B
   and is fired in case of insert, update or delete.

 Arguments:


 Known Limitations:

 Notes:

 History:
   ??-???-???? ?       Created
********************************************************/
  CURSOR c_task
    ( v_task_id NUMBER
    )
  IS
    SELECT server_id
    FROM   asg_task_acc
    WHERE  task_id = v_task_id;

  v_server_id NUMBER;

BEGIN
  -- service request associated with task is changed
  IF trigger_mode = 'ON-UPDATE'
  AND o_source_object_id <> n_source_object_id
  THEN
    OPEN c_task
      ( v_task_id => n_task_id
      );

    -- Find all the Middle-tiers associated with this task.
    -- Remove the old SR associated with all these middle-tiers
    -- Add the new SR associated with all these middle-tiers
    LOOP
      FETCH c_task
      INTO v_server_id;
      IF c_task%NOTFOUND
      THEN
        EXIT;
      END IF;

      -- Remove the old incident and add the new one
      IF o_source_object_type_code = 'SR'
      THEN
        UpdateAccesses_Incidentid
	  ( x_incident_id => o_source_object_id
	  , x_server_id   => v_server_id
	  , x_op          => '-'
	  );
      END IF;

      IF n_source_object_type_code = 'SR'
      THEN
        UpdateAccesses_Incidentid
	  ( n_source_object_id
	  , v_server_id
	  , '+'
	  );
      END IF;

    END LOOP;
    CLOSE c_task;
  END IF;
END TASKS_TRIGGER_HANDLER;

PROCEDURE TASK_ASSIGN_TRIGGER_HANDLER
  ( o_task_assignment_id NUMBER
  , o_task_id            NUMBER
  , o_resource_id        NUMBER
  , n_task_assignment_id NUMBER
  , n_task_id            NUMBER
  , n_resource_id        NUMBER
  , trigger_mode         VARCHAR2
  )
IS
/********************************************************
 Name:
   TASK_ASSIGN_TRIGGER_HANDLER

 Purpose:
   This procedure acts as a trigger on JTF_TASK_ASSIGNMENTS
   and is fired in case of insert, update or delete.

 Arguments:


 Known Limitations:

 Notes:

 History:
   ??-???-???? ?       Created
********************************************************/
  CURSOR c_device_users
    ( v_resource_id number
    )
  IS
    SELECT server_id
    FROM   asg_server_resources
    WHERE  resource_id = v_resource_id;

  v_server_id     NUMBER;
  v_old_server_id NUMBER;

BEGIN

  IF trigger_mode = 'ON-INSERT'
  THEN
    -- Add this task to all the middle tiers for the resource
    OPEN c_device_users
      ( v_resource_id => n_resource_id
      );
    LOOP
      FETCH c_device_users
      INTO v_server_id;
      IF c_device_users%NOTFOUND
      THEN
        EXIT;
      END IF;
      UpdateAccesses_Taskid
        ( x_task_id   => o_task_id
	, x_server_id => v_server_id
	, x_op        => '+'
	);
    END LOOP;
    CLOSE c_device_users;

  ELSIF trigger_mode = 'ON-UPDATE'
  THEN
    IF n_resource_id <> o_resource_id
    THEN
      -- Remove the task from all the middle tiers for this old resource
      OPEN c_device_users
        ( v_resource_id => o_resource_id
        );
      LOOP
        FETCH c_device_users
        into v_old_server_id;
        IF c_device_users%NOTFOUND
        THEN
          EXIT;
        END IF;
        UpdateAccesses_Taskid
	  ( x_task_id   => o_task_id
	  , x_server_id => v_old_server_id
	  , x_op        => '-'
	  );
      END LOOP;
      CLOSE c_device_users;

      -- Add the task to all the middle tiers for this new resource
      OPEN c_device_users
        ( v_resource_id => n_resource_id
        );
      LOOP
        FETCH c_device_users
        INTO v_server_id;
        IF c_device_users%NOTFOUND
        THEN
          EXIT;
        END IF;
        UpdateAccesses_Taskid
	  ( x_task_id   => n_task_id
	  , x_server_id => v_server_id
	  , x_op        => '+'
	  );
      END LOOP;
      CLOSE c_device_users;
    END IF;

  ELSIF Trigger_Mode = 'ON-DELETE'
  THEN
    -- Delete this task from all the middle tiers for this resource
    OPEN c_device_users
      ( v_resource_id => o_resource_id
      );
    LOOP
      FETCH C_DEVICE_USERS
      INTO v_old_server_id;
      IF c_device_users%NOTFOUND
      THEN
        EXIT;
      END IF;
      UpdateAccesses_Taskid
        ( x_task_id   => o_task_id
	, x_server_id => v_old_server_id
	, x_op        => '-'
	);
    END LOOP;
    CLOSE c_device_users;
  END IF;
END TASK_ASSIGN_TRIGGER_HANDLER;

PROCEDURE SR_CONTACT_TRIGGER_HANDLER
  ( x_incident_id NUMBER
  , x_op          VARCHAR2
  )
IS
/********************************************************
 Name:
   SR_CONTACT_TRIGGER_HANDLER

 Purpose:
   This procedure acts as a trigger on ???
   and is fired in case of insert, update or delete.

 Arguments:


 Known Limitations:

 Notes:

 History:
   ??-???-???? ?       Created
********************************************************/
  CURSOR c_primary_contact
    ( x_incident_id NUMBER
    )
  IS
    SELECT party_id
    FROM   cs_hz_sr_contact_points contact
    WHERE  contact.incident_id = x_incident_id
    AND    contact.primary_flag = 'Y'
    AND    EXISTS (SELECT incident_id
                   FROM   asg_incident_acc acc
                   WHERE  acc.incident_id = x_incident_id
                  );

  CURSOR c_server
    ( x_incident_id NUMBER
    )
  IS
    SELECT server_id
    FROM   asg_incident_acc
    WHERE  incident_id = x_incident_id;

  l_party_id  NUMBER;
  l_server_id NUMBER;

BEGIN
  OPEN c_primary_contact
    ( x_incident_id => x_incident_id
    );
  IF c_primary_contact%FOUND
  THEN
    FETCH c_primary_contact
    INTO l_party_id;
    OPEN c_server
      ( x_incident_id => x_incident_id
      );
    LOOP
      FETCH c_server
      INTO l_server_id;
      IF c_server%NOTFOUND
      THEN
        EXIT;
      END IF;
      UpdateAccesses_Partyid
        ( x_party_id  => l_party_id
	, x_server_id => l_server_id
	, x_op        => x_op
	);
    END LOOP;
    CLOSE c_server;
  END IF;
  CLOSE c_primary_contact;
END SR_CONTACT_TRIGGER_HANDLER;

PROCEDURE CUST_RELATIONS_TRIGGER_HANDLER
  ( rs_cust_relation_id   NUMBER
  , o_party_id    NUMBER
  , n_party_id    NUMBER
  , resource_id   NUMBER
  , trigger_mode  VARCHAR2
  )
IS
/********************************************************
 Name:
   CUST_RELATIONS_TRIGGER_HANDLER

 Purpose:
   This procedure acts as a trigger on CSP_RS_CUST_RELATIONS
   and is fired in case of insert, update or delete.

 Arguments:


 Known Limitations:

 Notes:

 History:
   21-JAN-2002 ASOYKAN    Created
********************************************************/
  CURSOR c_device_users
    ( v_resource_id number
    )
  IS
    SELECT server_id
    FROM   asg_server_resources
    WHERE  resource_id = v_resource_id;

  CURSOR c_party
    ( v_party_id NUMBER
    )
  IS
    SELECT server_id
    FROM   asg_party_acc
    WHERE  party_id = v_party_id;

  v_server_id NUMBER;
BEGIN
  IF trigger_mode = 'ON-INSERT'
  THEN
    -- Add this party to all the middle tiers for the resource
    OPEN c_device_users
      ( v_resource_id => resource_id
      );
    LOOP
      FETCH c_device_users
      INTO v_server_id;
      IF c_device_users%NOTFOUND
      THEN
        EXIT;
      END IF;
      UpdateAccesses_Partyid
        ( x_party_id  => o_party_id
	, x_server_id => v_server_id
	, x_op        => '+'
	);
    END LOOP;
    CLOSE c_device_users;

  -- update not possible
  ELSIF trigger_mode = 'ON-UPDATE'
  THEN
    NULL;
  END IF;

END CUST_RELATIONS_TRIGGER_HANDLER;
END CSF_ACCESS_PKG;

/
