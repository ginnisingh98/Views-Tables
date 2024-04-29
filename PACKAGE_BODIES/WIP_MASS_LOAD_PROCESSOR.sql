--------------------------------------------------------
--  DDL for Package Body WIP_MASS_LOAD_PROCESSOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_MASS_LOAD_PROCESSOR" AS
/* $Header: wipmlprb.pls 120.1 2006/01/30 02:00:51 panagara noship $ */


PROCEDURE Delete_Completed_Records(P_Group_Id IN NUMBER) IS

  -- Here, we fetch all requests that were processed successfully
  -- or that had a kanban reference. The kanban reference is a special
  -- case: we want these rows deleted regardless of whether they
  -- were processed correctly.
  cursor old_requests is
  select rowid, interface_id, header_id
  from wip_job_schedule_interface
  where
    group_id = p_group_id and
    ((process_phase = WIP_CONSTANTS.ML_COMPLETE and
      process_status = WIP_CONSTANTS.ML_COMPLETE) or
     (kanban_card_id is not null))
  for update ;

BEGIN

  for old_request in old_requests loop

    delete from wip_interface_errors
    where interface_id = old_request.interface_id ;

    delete from wip_job_dtls_interface
    where  group_id = p_group_id
    and    parent_header_id = old_request.header_id;

    delete from wip_job_schedule_interface
    where rowid = old_request.rowid ;

  end loop ;

END Delete_Completed_Records;


PROCEDURE ML_Release(P_Wip_Entity_Id IN NUMBER,
                    P_Organization_Id IN NUMBER,
                    P_Class_Code IN VARCHAR2,
                    P_New_Status_Type IN NUMBER,
                    P_Success_Flag OUT NOCOPY NUMBER,
                    P_Error_Msg OUT NOCOPY VARCHAR2,
                    P_Release_Date IN Date DEFAULT NULL) IS /* 2424987 */
x_dummy NUMBER;
BEGIN
        WIP_CHANGE_STATUS.Release
        (P_Wip_Entity_Id,
         P_Organization_Id,
         NULL, NULL,
         P_Class_Code,
         WIP_CONSTANTS.UNRELEASED,
         P_New_Status_Type,
         x_dummy,
         nvl(P_Release_Date,sysdate)); /* 2424987 */

        P_Success_Flag := 1;
EXCEPTION
        WHEN OTHERS THEN
                P_Success_Flag := 0;
                P_Error_Msg := SUBSTR(FND_MESSAGE.get,1,500);
END ML_Release;

PROCEDURE ML_Status_Change(P_Wip_Entity_Id IN NUMBER,
                    P_Organization_Id IN NUMBER,
                    P_Class_Code IN VARCHAR2,
                    P_New_Status_Type IN NUMBER,
                    P_Old_Status_Type IN NUMBER,
                    P_Success_Flag OUT NOCOPY NUMBER,
                    P_Error_Msg OUT NOCOPY VARCHAR2,
                    P_Release_Date IN Date DEFAULT NULL) IS /* 2424987 */
BEGIN

        /* bug#3388658: added more combination of new and old job status
             types instead of just P_New_Status_Type=RELEASED */
        /* Bug 4955616. Removed WIP_CONSTANTS.CANCELLED from new status list and added to old status list*/
        IF(P_New_Status_Type IN (WIP_CONSTANTS.RELEASED,
                             WIP_CONSTANTS.COMP_CHRG,
                             WIP_CONSTANTS.HOLD) AND
           P_Old_Status_Type IN (WIP_CONSTANTS.UNRELEASED,
                                  WIP_CONSTANTS.FAIL_BOM,
                                  WIP_CONSTANTS.FAIL_ROUT,
                                  WIP_CONSTANTS.PEND_SCHED,
                                  WIP_CONSTANTS.CANCELLED)) THEN
                ML_Release(P_Wip_Entity_Id,
                           P_Organization_Id,
                           P_Class_Code,
                           P_New_Status_Type,
                           P_Success_Flag,
                           P_Error_Msg,
                           nvl(P_Release_Date,sysdate)); /* 2424987 */

        ELSIF(P_New_Status_Type = WIP_CONSTANTS.UNRELEASED) THEN
                WIP_UNRELEASE.Unrelease(P_Organization_Id,
                                        P_Wip_Entity_Id,
                                        NULL,
                                        NULL,
                                        1);

        END IF;

        P_Success_Flag := 1;

EXCEPTION
        WHEN OTHERS THEN
                P_Success_Flag := 0;
                P_Error_Msg := SUBSTR(FND_MESSAGE.get,1,500);
END;

PROCEDURE Raise_Sql_Error(P_Group_Id IN NUMBER) IS
err_num NUMBER;
error_text varchar2(500);
BEGIN

        UPDATE WIP_JOB_SCHEDULE_INTERFACE
        SET PROCESS_STATUS = WIP_CONSTANTS.ERROR
        WHERE GROUP_ID = P_Group_Id
        AND PROCESS_PHASE <> WIP_CONSTANTS.ML_COMPLETE;

        err_num := SQLCODE;
        error_text := SUBSTR(SQLERRM, 1, 500);

        INSERT INTO WIP_INTERFACE_ERRORS(
                        interface_id,
                        error_type,
                        error,
                        last_update_date,
                        creation_date,
                        created_by,
                        last_update_login,
                        last_updated_by)
        SELECT  interface_id, 1,
                Error_Text, sysdate, sysdate,
                created_by, last_update_login,
                last_updated_by
        FROM    WIP_JOB_SCHEDULE_INTERFACE
        WHERE GROUP_ID = P_Group_Id
        AND PROCESS_PHASE <> WIP_CONSTANTS.ML_COMPLETE;

END Raise_Sql_Error;

END WIP_MASS_LOAD_PROCESSOR;

/
