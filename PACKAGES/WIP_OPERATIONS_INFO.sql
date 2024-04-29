--------------------------------------------------------
--  DDL for Package WIP_OPERATIONS_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_OPERATIONS_INFO" AUTHID CURRENT_USER AS
/* $Header: wipopins.pls 115.8 2002/11/29 14:56:55 rmahidha ship $ */

/*=====================================================================+
 | PROCEDURE
 |   DERIVE_INFO
 |
 | PURPOSE
 |   Derives information given job/schedule IDs and operation sequence
 |
 | ARGUMENTS
 |   IN
 |     p_org_id             Organization ID
 |     p_wip_entity_id      WIP entity ID
 |     p_first_schedule_id  ID of first open schedule
 |     p_operation_seq_num  Operation sequence number of the routing
 |   OUT
 |     p_operation_code     Operation code associated with the given sequence
 |     p_department_id      Department ID of the department
 |     p_department_code    Department code of the operation
 |     p_prev_op_seq_num    The given operation's previous operation sequence
 |     p_next_op_seq_num    The given operation's next operation sequence
 |     p_operation_exists   Flag whether the operation exists in the routing
 |
 | EXCEPTIONS
 |
 | NOTES
 |   p_prev_op_seq_num and p_next_op_seq_num are still set even if the
 |   operation does not exist in the routing.  These values are useful
 |   when adding an operation on the fly.
 |
 +=====================================================================*/
  procedure derive_info(
    p_org_id            in  number,
    p_wip_entity_id     in  number,
    p_first_schedule_id in  number,
    p_operation_seq_num in  number,
    p_operation_code    out nocopy varchar2,
    p_department_id     out nocopy number,
    p_department_code   out nocopy varchar2,
    p_prev_op_seq_num   out nocopy number,
    p_next_op_seq_num   out nocopy number,
    p_operation_exists  out nocopy boolean);

/*=====================================================================+
 | PROCEDURE
 |   LAST_OPERATION
 |
 | PURPOSE
 |   Derives last operation information given job/schedule IDs
 |
 | ARGUMENTS
 |   IN
 |     p_org_id                   Organization ID
 |     p_wip_entity_id            WIP entity ID
 |     p_line_id                  ID of the line of the schedule
 |     p_first_schedule_id        ID of first open schedule
 |   OUT
 |     p_last_op_seq              Max operation sequence number of the routing
 |     p_last_op_code             Operation code associated with the last op seq
 |     p_last_dept_id             Department ID of the department
 |     p_last_dept_code           Department code of the operation
 |     p_last_op_move_quantity    Quantity waiting to move as the last op seq
 |     p_last_op_min_transfer_qty Min transfer quantity of last operation
 |     p_last_move_allowed        Indicates moves allowed out nocopy of last op
 |
 | EXCEPTIONS
 |
 | NOTES
 |  If the job/schedule does not have a routing, p_last_op_seq = -1.
 |  All other output arguments will be set to NULL.
 |
 +=====================================================================*/
  procedure last_operation(
    p_org_id                   in  number,
    p_wip_entity_id            in  number,
    p_line_id                  in  number,
    p_first_schedule_id        in  number,
    p_last_op_seq              out nocopy number,
    p_last_op_code             out nocopy varchar2,
    p_last_dept_id             out nocopy number,
    p_last_dept_code           out nocopy varchar2,
    p_last_op_move_quantity    out nocopy number,
    p_last_op_min_transfer_qty out nocopy number,
    p_last_move_allowed        out nocopy number);

/*=====================================================================+
 | PROCEDURE
 |   FIRST_OPERATION
 |
 | PURPOSE
 |   Derives first operation information given job/schedule IDs
 |
 | ARGUMENTS
 |   IN
 |     p_org_id                   Organization ID
 |     p_wip_entity_id            WIP entity ID
 |     p_line_id                  ID of the line of the schedule
 |     p_first_schedule_id        ID of first open schedule
 |   OUT
 |     p_first_op_seq           Max operation sequence number of the routing
 |     p_first_op_code          Operation code associated with the first op seq
 |     p_first_dept_id             Department ID of the department
 |     p_first_dept_code           Department code of the operation
 |     p_first_op_min_transfer_qty Min transfer quantity of first operation
 |
 | EXCEPTIONS
 |
 | NOTES
 |  If the job/schedule does not have a routing, p_first_op_seq = -1.
 |  All other output arguments will be set to NULL.
 |
 +=====================================================================*/
   procedure first_operation
   (
    p_org_id                   in  number,
    p_wip_entity_id            in  number,
    p_line_id                  in  number,
    p_first_schedule_id        in  number,
    p_first_op_seq              out nocopy number,
    p_first_op_code             out nocopy varchar2,
    p_first_dept_id             out nocopy number,
    p_first_dept_code           out nocopy varchar2);

END WIP_OPERATIONS_INFO;

 

/
