--------------------------------------------------------
--  DDL for Package Body MRP_SNAPSHOT_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_SNAPSHOT_PK" AS
/* $Header: MRPPSNPB.pls 115.0 99/07/16 12:34:33 porting ship $ */

MAKE_ITEM CONSTANT INTEGER:= 1;

-- ********************** complete_task *************************
PROCEDURE   complete_task(
                            arg_compile_desig   IN  VARCHAR2,
                            arg_org_id          IN  NUMBER,
                            arg_task            IN  NUMBER) IS
BEGIN

    UPDATE  mrp_snapshot_tasks
    SET     completion_date = SYSDATE,
            program_update_date = SYSDATE
    WHERE   task = arg_task
      AND   organization_id = arg_org_id
      AND   compile_designator = arg_compile_desig;

    COMMIT;

END complete_task;

END; -- package

/
