--------------------------------------------------------
--  DDL for Package Body ZPB_SC_REASSIGN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_SC_REASSIGN" AS
/* $Header: zpbscreassign.plb 120.0.12010.2 2005/12/23 08:57:23 appldev noship $  */

G_PKG_NAME CONSTANT VARCHAR2(15) := 'zpb_sc_reassign';


/*
 * Public  */

-------------------------------------------------------------------------------
-- REASSIGN_ALL_OBJECTS - Helper routine called from middle tier to re-assign
--                        all objects from current owner to new owner
--
-- IN: p_owner_id     - User_id of current owner
-- IN: p_new_owner_id     - User_id that objects will be transferred to
-- IN: p_business_area_id - Business Area Id
-------------------------------------------------------------------------------

PROCEDURE reassign_all_objects (
  p_owner_id               IN zpb_analysis_cycles.owner_id%TYPE,
  p_new_owner_id           IN zpb_analysis_cycles.owner_id%TYPE,
  p_business_area_id       IN zpb_analysis_cycles.business_area_id%TYPE)

IS
BEGIN
   reassign_bus_proc_objs(p_owner_id, p_new_owner_id, p_business_area_id);
   -- exceptions will come later. see bug 4568557
   -- reassign_exception_objs(p_owner_id, p_new_owner_id, p_business_area_id);

END;

-------------------------------------------------------------------------------
-- REASSIGN_BUS_PROC_OBJS - Re-assign all business process objects to new owner
--
-- IN: p_owner_id     - User_id of current owner
-- IN: p_new_owner_id     - User_id that objects will be transferred to
-- IN: p_business_area_id - Business Area Id
-------------------------------------------------------------------------------

PROCEDURE reassign_bus_proc_objs (
  p_owner_id               IN zpb_analysis_cycles.owner_id%TYPE,
  p_new_owner_id           IN zpb_analysis_cycles.owner_id%TYPE,
  p_business_area_id       IN zpb_analysis_cycles.business_area_id%TYPE)

IS

BEGIN

  zpb_log.write('zpb_sc_reassign.reassign_bus_proc_objs',
                'Reassigning BP objects from user id: ' || p_owner_id ||
                ' to  user id: ' || p_new_owner_id);

  UPDATE
   zpb_analysis_cycles
  SET
   owner_id = p_new_owner_id,
   last_updated_by = fnd_global.USER_ID,
   last_update_date = SYSDATE,
   last_update_login = fnd_global.LOGIN_ID
  WHERE
   owner_id = p_owner_id AND
   business_area_id =  p_business_area_id;

  zpb_log.write('zpb_sc_reassign.reassign_bus_proc_objs', 'End');

END;

-------------------------------------------------------------------------------
-- GET_ACTIVE_BUSINESS_PROCS - Returns comma delimited list of all
-- active Business Processes for a specified user.
--
-- IN: p_owner_id         - User_id of current owner
-- IN: p_business_area_id - Business Area Id
-------------------------------------------------------------------------------

FUNCTION get_active_business_procs (
  p_owner_id           IN zpb_analysis_cycles.owner_id%TYPE,
  p_business_area_id   IN zpb_analysis_cycles.business_area_id%TYPE)
  return varchar2

IS

  CURSOR active_bus_procs_cur is
    SELECT
      name
    FROM
      zpb_analysis_cycles
    WHERE
      owner_id = p_owner_id AND
      business_area_id =  p_business_area_id AND
      status_code in ('DISABLE_ASAP', 'ENABLE_TASK', 'ERROR',
                      'MARKED_FOR_DELETION', 'PAUSED', 'PAUSING', 'PUBLISHED',
                      'WARNING', 'ACTIVE');

  l_business_proc_names varchar2(1000);   -- name is varchar2(300).
                                          -- s/b MAX_LENGTH

BEGIN
  zpb_log.write('zpb_sc_reassign.get_active_business_procs', 'Getting list of active Business Processes');

  for each in active_bus_procs_cur loop
    if  nvl(length(l_business_proc_names),0) + nvl(length(each.name),0) + 2 < MAX_LENGTH then
      l_business_proc_names := l_business_proc_names || each.name || ', ';
    end if;
  end loop;

  zpb_log.write('zpb_sc_reassign.get_active_business_procs', 'End');

  return l_business_proc_names;

END;

-------------------------------------------------------------------------------
-- GET_WORKSHEETS - Returns comma delimited list of all worksheets for a
-- specified user.
--
-- IN: p_owner_id         - User_id of current owner
-- IN: p_business_area_id - Business Area Id
-------------------------------------------------------------------------------

FUNCTION get_worksheets (
  p_owner_id           IN zpb_analysis_cycles.owner_id%TYPE,
  p_business_area_id   IN zpb_analysis_cycles.business_area_id%TYPE)
  return varchar2

IS

  CURSOR worksheets_cur is
    SELECT
      template_name
    FROM
      zpb_dc_objects
    WHERE
      object_user_id = p_owner_id AND
      object_type IN ('W', 'C') AND
      business_area_id = p_business_area_id;


 l_worksheet_names varchar2(1000);   -- name is varchar2(300).
                                     -- s/b MAX_LENGTH

BEGIN
  zpb_log.write('zpb_sc_reassign.get_worksheets', 'Getting list of Worksheets');

  for each in worksheets_cur loop
    if  nvl(length(l_worksheet_names),0) + nvl(length(each.template_name),0) + 2 < MAX_LENGTH then
     l_worksheet_names := l_worksheet_names || each.template_name || ', ';
    end if;
  end loop;

  zpb_log.write('zpb_sc_reassign.zpb_sc_reassign.get_worksheets', 'End');

  return l_worksheet_names;

END;

-------------------------------------------------------------------------------
-- REASSIGN_EXCEPTION_OBJS - Re-assign all business process objects to new owner
--
-- IN: p_owner_id         - User_id of current owner
-- IN: p_new_owner_id     - User_id that objects will be transferred to
-- IN: p_business_area_id - Business Area Id
-------------------------------------------------------------------------------

PROCEDURE reassign_exception_objs (
  p_owner_id              IN zpb_analysis_cycles.owner_id%TYPE,
  p_new_owner_id              IN zpb_analysis_cycles.owner_id%TYPE,
  p_business_area_id          IN zpb_analysis_cycles.business_area_id%TYPE)
IS

  l_new_owner_user_name fnd_user.user_name%TYPE;
  l_owner_user_name fnd_user.user_name%TYPE;

BEGIN

  zpb_log.write('zpb_sc_reassign. reassign_exception_objs',
                'Reassigning Exception objects from user id: ' || p_owner_id ||
                ' to  user id: ' || p_new_owner_id);

 -- Some columns use text name.
  SELECT user_name INTO l_new_owner_user_name FROM fnd_user WHERE user_id = p_new_owner_id;
  SELECT user_name INTO l_owner_user_name FROM fnd_user WHERE user_id = p_owner_id;

  -- zpb_analysis_cycle_tasks
 UPDATE
   zpb_analysis_cycle_tasks
  SET
   owner_id = p_new_owner_id,
   last_updated_by = fnd_global.USER_ID,
   last_update_date = SYSDATE,
   last_update_login = fnd_global.LOGIN_ID
  WHERE
   owner_id = p_owner_id and
   analysis_cycle_id in (SELECT
                          distinct(ZACT.analysis_cycle_id)
                         FROM
                          zpb_analysis_cycle_tasks ZACT,
                          zpb_analysis_cycles ZAC
                         WHERE
                          ZACT.analysis_cycle_id =
                          ZAC.analysis_cycle_id and
                          ZAC.business_area_id = p_business_area_id);


  -- zpb_task_parameters owner_id
  UPDATE
   zpb_task_parameters
  SET
   value = p_new_owner_id,
   last_updated_by = fnd_global.USER_ID,
   last_update_date = SYSDATE,
   last_update_login = fnd_global.LOGIN_ID
  WHERE
   name = 'OWNER_ID' and
   value = p_owner_id and
   task_id in (SELECT
                 ZTP.task_id
               FROM
                 zpb_task_parameters ZTP,
                 zpb_analysis_cycle_tasks ZACT,
                 zpb_analysis_cycles ZAC
               WHERE
                 ZTP.task_id = ZACT.task_id and
                 ZACT.analysis_cycle_id = ZAC.analysis_cycle_id and
                 ZAC.business_area_id = p_business_area_id);

   -- zpb_task_parameters specfied_notification_recipient
  UPDATE
   zpb_task_parameters
  SET
   value = l_new_owner_user_name,
   last_updated_by = fnd_global.USER_ID,
   last_update_date = SYSDATE,
   last_update_login = fnd_global.LOGIN_ID
  WHERE
   name = 'SPECIFIED_NOTIFICATION_RECIPIENT' and
   value = l_owner_user_name and
   task_id in (SELECT
                 ZTP.task_id
               FROM
                 zpb_task_parameters ZTP,
                 zpb_analysis_cycle_tasks ZACT,
                 zpb_analysis_cycles ZAC
               WHERE
                 ZTP.task_id = ZACT.task_id and
                 ZACT.analysis_cycle_id = ZAC.analysis_cycle_id and
                 ZAC.business_area_id = p_business_area_id);

  -- zpb_excp_results owner info
  UPDATE
   zpb_excp_results
  SET
   owner_id = p_new_owner_id,
   owner = l_new_owner_user_name,
   last_updated_by = fnd_global.USER_ID,
   last_update_date = SYSDATE,
   last_update_login = fnd_global.LOGIN_ID
  WHERE
   owner_id = p_owner_id and
   task_id in (SELECT
                 ZTP.task_id
               FROM
                 zpb_task_parameters ZTP,
                 zpb_analysis_cycle_tasks ZACT,
                 zpb_analysis_cycles ZAC
               WHERE
                 ZTP.task_id = ZACT.task_id and
                 ZACT.analysis_cycle_id = ZAC.analysis_cycle_id and
                 ZAC.business_area_id = p_business_area_id);

  -- zpb_excp_results approver info
  UPDATE
   zpb_excp_results
  SET
   approver_id = p_new_owner_id,
   approver = l_new_owner_user_name,
   last_updated_by = fnd_global.USER_ID,
   last_update_date = SYSDATE,
   last_update_login = fnd_global.LOGIN_ID
  WHERE
   approver_id = p_owner_id and
   task_id in (SELECT
                 ZTP.task_id
               FROM
                 zpb_task_parameters ZTP,
                 zpb_analysis_cycle_tasks ZACT,
                 zpb_analysis_cycles ZAC
               WHERE
                 ZTP.task_id = ZACT.task_id and
                 ZACT.analysis_cycle_id = ZAC.analysis_cycle_id and
                 ZAC.business_area_id = p_business_area_id);

  -- zpb_excp_explanations owner info
 UPDATE
   zpb_excp_explanations
  SET
   owner_id = p_new_owner_id,
   owner = l_new_owner_user_name,
   last_updated_by = fnd_global.USER_ID,
   last_update_date = SYSDATE,
   last_update_login = fnd_global.LOGIN_ID
  WHERE
   owner_id = p_owner_id and
   task_id in (SELECT
                 ZTP.task_id
               FROM
                 zpb_task_parameters ZTP,
                 zpb_analysis_cycle_tasks ZACT,
                 zpb_analysis_cycles ZAC
               WHERE
                 ZTP.task_id = ZACT.task_id and
                 ZACT.analysis_cycle_id = ZAC.analysis_cycle_id and
                 ZAC.business_area_id = p_business_area_id);


  -- zpb_excp_explanations approver info
  UPDATE
   zpb_excp_explanations
  SET
   approver_id = p_new_owner_id,
   approver = l_new_owner_user_name,
   last_updated_by = fnd_global.USER_ID,
   last_update_date = SYSDATE,
   last_update_login = fnd_global.LOGIN_ID
  WHERE
   approver_id = p_owner_id and
   task_id in (SELECT
                 ZTP.task_id
               FROM
                 zpb_task_parameters ZTP,
                 zpb_analysis_cycle_tasks ZACT,
                 zpb_analysis_cycles ZAC
               WHERE
                 ZTP.task_id = ZACT.task_id and
                 ZACT.analysis_cycle_id = ZAC.analysis_cycle_id and
                 ZAC.business_area_id = p_business_area_id);

  zpb_log.write('zpb_sc_reassign. reassign_exception_objs', 'End');

END;

END ZPB_SC_REASSIGN;

/
