--------------------------------------------------------
--  DDL for Package WIP_BATCH_MOVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_BATCH_MOVE" AUTHID CURRENT_USER AS
/* $Header: wipbmovs.pls 120.2.12010000.1 2008/07/24 05:21:38 appldev ship $*/

-- declare a PL/SQL table to store jobs, operations, move and scrap quantities.
TYPE move_record IS RECORD(wip_entity_id     NUMBER,
                           wip_entity_name   VARCHAR2(240),
                           op_seq            NUMBER,
                           move_qty          NUMBER,
                           scrap_qty         NUMBER,
                           assy_serial       VARCHAR2(30));

TYPE move_table IS TABLE OF move_record INDEX BY binary_integer;


/***************************************************************************
 * This procedure will be used to do batch move, scrap or both move and scrap.
 * This procedure will be called by OA page. Even if the name is batch move,
 * each move transaction is unlikely to depend on each other. If one record
 * fails, we will rollback only the changes related to that record. We will
 * commit other succesfully processed records.
 *
 * PARAMETER:
 *
 * p_move_table         A PL/SQL table contains jobs, operations, move and
 *                      scrap quantities information. User can pass as many
 *                      records as they want, but it will take longer to
 *                      process because we have to process record one by one
 *                      to support a requirement to rollback only error record.
 * p_resp_key           Responsibility key that the user log in. It is either
 *                      operator or supervisor.
 * p_org_id             Organization ID that user log in.
 * p_dept_id            Department ID that user log in.
 * p_employee_id        Employee ID of the person who submit the transaction.
 * x_return_status      There are 2 possible values
 *                      *fnd_api.g_ret_sts_success*
 *                      means the every record was succesfully processed
 *                      *fnd_api.g_ret_sts_error*
 *                      means some records error out
 *
 * Note: Error message will be put in message stack for caller to display to
 *       the user. If x_returnStatus is equal to fnd_api.g_ret_sts_error,
 *       caller knows that some records error out.
 *
 ****************************************************************************/
PROCEDURE process(p_move_table    IN         wip_batch_move.move_table,
                  p_resp_key      IN         VARCHAR2,
                  p_org_id        IN         NUMBER,
                  p_dept_id       IN         NUMBER,
                  p_employee_id   IN         NUMBER,
                  x_return_status OUT NOCOPY VARCHAR2);
END wip_batch_move;

/
