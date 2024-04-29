--------------------------------------------------------
--  DDL for Package Body WIP_OPERATIONS_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_OPERATIONS_INFO" AS
/* $Header: wipopinb.pls 120.2 2006/03/01 16:35:22 hshu noship $ */

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
    p_operation_exists  out nocopy boolean) is
    x_operation_exists boolean;
  begin
    begin
      select bso.operation_code,
             bd.department_code,
             wo.department_id,
             wo.previous_operation_seq_num,
             wo.next_operation_seq_num
      into   p_operation_code,
             p_department_code,
             p_department_id,
             p_prev_op_seq_num,
             p_next_op_seq_num
      from   bom_standard_operations bso,
             bom_departments bd,
             wip_operations wo
      where  wo.organization_id = p_org_id
/* %cfm  Ignore cfm ops. */
      and    nvl(bso.operation_type, 1) = 1
      and    bso.line_id is null
/* %/cfm */
      and    wo.wip_entity_id = p_wip_entity_id
      and    wo.operation_seq_num = p_operation_seq_num
      and    (wo.repetitive_schedule_id is null
              or
              wo.repetitive_schedule_id = p_first_schedule_id)
      and    bso.organization_id (+) = wo.organization_id
      and    bso.standard_operation_id (+) = wo.standard_operation_id
      and    bd.organization_id = wo.organization_id
      and    bd.department_id = wo.department_id;

      x_operation_exists := TRUE;
    exception
      when NO_DATA_FOUND then
        p_operation_code   := NULL;
        p_department_id    := NULL;
        p_department_code  := NULL;
        x_operation_exists := FALSE;
    end;

    -- get previous and next operation for a newly added operation
    if (not x_operation_exists) then
      select max(wo1.operation_seq_num),
             min(wo2.operation_seq_num)
      into   p_prev_op_seq_num,
             p_next_op_seq_num
      from   dual sd,
             wip_operations wo1,
             wip_operations wo2
      where  wo1.organization_id(+) = p_org_id
      and    wo1.wip_entity_id(+) = decode(1, 1, p_wip_entity_id, sd.dummy)
      and    wo1.operation_seq_num(+) < p_operation_seq_num
      and    wo2.organization_id(+) = p_org_id
      and    wo2.wip_entity_id(+) = decode(1, 1, p_wip_entity_id, sd.dummy)
      and    wo2.operation_seq_num(+) > p_operation_seq_num;
    end if;

    p_operation_exists := x_operation_exists;
    return;

  exception
    when others then
      wip_constants.get_ora_error(
        application => 'WIP',
        proc_name   => 'WIP_OPERATIONS_PKG.DERIVE_INFO');
      fnd_message.raise_error;
  end derive_info;

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
    p_last_move_allowed        out nocopy number) is

    -- cursors to get last operation and shop floor status information
    cursor get_last_operation_yes(
      c_org_id            number,
      c_wip_entity_id     number,
      c_line_id           number,
      c_first_schedule_id number) is
    select distinct
	   wo.operation_seq_num,
           bso.operation_code,
           wo.department_id,
           bd.department_code,
           wo.minimum_transfer_quantity,
           wo.quantity_waiting_to_move,
           WIP_CONSTANTS.YES allow_moves
    from   bom_standard_operations bso,
           bom_departments bd,
           wip_operations wo
    where  wo.operation_seq_num =
             (select max(operation_seq_num)
              from   wip_operations wo1
              where  wo1.organization_id = wo.organization_id
              and    wo1.wip_entity_id = wo.wip_entity_id
              and    (wo1.repetitive_schedule_id is NULL
                      or
                      wo1.repetitive_schedule_id = c_first_schedule_id))
/* %cfm  Ignore cfm ops. */
    and    nvl(bso.operation_type, 1) = 1
    and    bso.line_id is null
/* %/cfm */
    and    wo.department_id = bd.department_id
    and    wo.standard_operation_id = bso.standard_operation_id (+)
    and    wo.organization_id = c_org_id
    and    wo.wip_entity_id = c_wip_entity_id
    and    (wo.repetitive_schedule_id is NULL
            or
            wo.repetitive_schedule_id = c_first_schedule_id)
    and    not exists
          (select 'No move status exists'
           from   wip_shop_floor_statuses ws,
                  wip_shop_floor_status_codes wsc
           where  wsc.organization_id = wo.organization_id
           and    ws.organization_id = wo.organization_id
           and    ws.wip_entity_id = wo.wip_entity_id
           and    (ws.line_id is NULL
                   or
                   ws.line_id = c_line_id)
           and    ws.operation_seq_num = wo.operation_seq_num
           and    ws.intraoperation_step_type = WIP_CONSTANTS.TOMOVE
           and    ws.shop_floor_status_code = wsc.shop_floor_status_code
           and    wsc.status_move_flag = WIP_CONSTANTS.NO
           and    nvl(wsc.disable_date, SYSDATE + 1) > SYSDATE);

    cursor get_last_operation_no(
      c_org_id            number,
      c_wip_entity_id     number,
      c_line_id           number,
      c_first_schedule_id number) is
    select distinct
	   wo.operation_seq_num,
           bso.operation_code,
           wo.department_id,
           bd.department_code,
           wo.minimum_transfer_quantity,
           wo.quantity_waiting_to_move,
           WIP_CONSTANTS.NO allow_moves
    from   bom_standard_operations bso,
           bom_departments bd,
           wip_operations wo
    where  wo.operation_seq_num =
             (select max(operation_seq_num)
              from   wip_operations wo1
              where  wo1.organization_id = wo.organization_id
              and    wo1.wip_entity_id = wo.wip_entity_id
              and    (wo1.repetitive_schedule_id is NULL
                      or
                      wo1.repetitive_schedule_id = c_first_schedule_id))
/* %cfm  Ignore cfm ops. */
    and    nvl(bso.operation_type, 1) = 1
    and    bso.line_id is null
/* %/cfm */
    and    wo.department_id = bd.department_id
    and    wo.standard_operation_id = bso.standard_operation_id (+)
    and    wo.organization_id = c_org_id
    and    wo.wip_entity_id = c_wip_entity_id
    and    (wo.repetitive_schedule_id is NULL
            or
            wo.repetitive_schedule_id = c_first_schedule_id)
    and    exists
          (select 'Move status exists'
           from   wip_shop_floor_statuses ws,
                  wip_shop_floor_status_codes wsc
           where  wsc.organization_id = wo.organization_id
           and    ws.organization_id = wo.organization_id
           and    ws.wip_entity_id = wo.wip_entity_id
           and    (ws.line_id is NULL
                   or
                   ws.line_id = c_line_id)
           and    ws.operation_seq_num = wo.operation_seq_num
           and    ws.intraoperation_step_type = WIP_CONSTANTS.TOMOVE
           and    ws.shop_floor_status_code = wsc.shop_floor_status_code
           and    wsc.status_move_flag = WIP_CONSTANTS.NO
           and    nvl(wsc.disable_date, SYSDATE + 1) > SYSDATE);

    yes_vals get_last_operation_yes%ROWTYPE;
    no_vals get_last_operation_no%ROWTYPE;
  begin
    open get_last_operation_yes(
      c_org_id            => p_org_id,
      c_wip_entity_id     => p_wip_entity_id,
      c_line_id           => p_line_id,
      c_first_schedule_id => p_first_schedule_id);
    open get_last_operation_no(
      c_org_id            => p_org_id,
      c_wip_entity_id     => p_wip_entity_id,
      c_line_id           => p_line_id,
      c_first_schedule_id => p_first_schedule_id);

    fetch get_last_operation_yes into yes_vals;
    fetch get_last_operation_no into no_vals;
    if (get_last_operation_yes%FOUND) then
      p_last_op_seq              := yes_vals.operation_seq_num;
      p_last_op_code             := yes_vals.operation_code;
      p_last_dept_id             := yes_vals.department_id;
      p_last_dept_code           := yes_vals.department_code;
      p_last_op_min_transfer_qty := yes_vals.minimum_transfer_quantity;
      p_last_op_move_quantity    := yes_vals.quantity_waiting_to_move;
      p_last_move_allowed        := WIP_CONSTANTS.YES;
    elsif (get_last_operation_no%FOUND) then
      p_last_op_seq              := no_vals.operation_seq_num;
      p_last_op_code             := no_vals.operation_code;
      p_last_dept_id             := no_vals.department_id;
      p_last_dept_code           := no_vals.department_code;
      p_last_op_min_transfer_qty := no_vals.minimum_transfer_quantity;
      p_last_op_move_quantity    := no_vals.quantity_waiting_to_move;
      p_last_move_allowed        := WIP_CONSTANTS.NO;
    else
      p_last_op_seq              := -1;
      p_last_op_code             := NULL;
      p_last_dept_id             := NULL;
      p_last_dept_code           := NULL;
      p_last_op_min_transfer_qty := NULL;
      p_last_op_move_quantity    := NULL;
      p_last_move_allowed        := WIP_CONSTANTS.YES;
    end if;

    close get_last_operation_yes;
    close get_last_operation_no;

    return;
  end last_operation;

/*=====================================================================+
 | PROCEDURE
 |   FIRST_OPERATION
 */

  procedure first_operation(
    p_org_id                   in  number,
    p_wip_entity_id            in  number,
    p_line_id                  in  number,
    p_first_schedule_id        in  number,
    p_first_op_seq              out nocopy number,
    p_first_op_code             out nocopy varchar2,
    p_first_dept_id             out nocopy number,
    p_first_dept_code           out nocopy varchar2) is

    -- cursor to get first operation and shop floor status information
    cursor get_first_operation(
      c_org_id            number,
      c_wip_entity_id     number,
      c_line_id           number,
      c_first_schedule_id number) is
    select distinct
	   wo.operation_seq_num,
           bso.operation_code,
           wo.department_id,
           bd.department_code
    from   bom_standard_operations bso,
           bom_departments bd,
           wip_operations wo
    where  wo.operation_seq_num =
             (select min(operation_seq_num)
              from   wip_operations wo1
              where  wo1.organization_id = wo.organization_id
              and    wo1.wip_entity_id = wo.wip_entity_id
              and    (wo1.repetitive_schedule_id is NULL
                      or
                      wo1.repetitive_schedule_id = c_first_schedule_id))
/* %cfm  Ignore cfm ops. */
    and    nvl(bso.operation_type, 1) = 1
    and    bso.line_id is null
/* %/cfm */
    and    wo.department_id = bd.department_id
    and    wo.standard_operation_id = bso.standard_operation_id (+)
    and    wo.organization_id = c_org_id
    and    wo.wip_entity_id = c_wip_entity_id
    and    (wo.repetitive_schedule_id is NULL
            or
            wo.repetitive_schedule_id = c_first_schedule_id);
  begin
     open get_first_operation
       (
	c_org_id            => p_org_id,
	c_wip_entity_id     => p_wip_entity_id,
	c_line_id           => p_line_id,
	c_first_schedule_id => p_first_schedule_id);

     fetch get_first_operation into
       p_first_op_seq,
       p_first_op_code,
       p_first_dept_id,
       p_first_dept_code;

     if (get_first_operation%NOTFOUND) then
	p_first_op_seq              := -1;
	p_first_op_code             := NULL;
	p_first_dept_id             := NULL;
	p_first_dept_code           := NULL;
     end if;

     close get_first_operation;

     return;

  end first_operation;


END WIP_OPERATIONS_INFO;

/
