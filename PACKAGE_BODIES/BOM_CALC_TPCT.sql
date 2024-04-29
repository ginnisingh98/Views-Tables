--------------------------------------------------------
--  DDL for Package Body BOM_CALC_TPCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOM_CALC_TPCT" as
/* $Header: bomtpctb.pls 115.5 2002/04/16 15:13:32 pkm ship     $ */

function calc_tpct (
	p_routing_sequence_id	in	number,
	p_operation_type	in	varchar2
) return number is
  -- Declare exceptions
  loop_found	exception;

  pragma exception_init(loop_found, -1436);

  -- Declare variables
  v_ttc		number := 0;	-- system calculated total time
  v_tpct		number := 0; 	-- total product cycle time
  v_max_tpct	number := 0;	-- max total product cycle time

  -- Select all the operations in the routing that do not have a 'from'
  -- operation.  These are valid starting points for multiple paths (i.e.
  -- it includes feeder lines)
  cursor start_ops_cur (cv_routing_sequence_id number,
                        cv_operation_type varchar2) is
  select bos.operation_sequence_id start_operation_sequence_id
  from bom_operation_sequences bos
  where bos.routing_sequence_id = cv_routing_sequence_id
  and bos.operation_type = cv_operation_type
    minus
  select bon.to_op_seq_id start_operation_sequence_id
  from bom_operation_networks bon, bom_operation_sequences bos
  where bon.to_op_seq_id = bos.operation_sequence_id
  and bos.routing_sequence_id = cv_routing_sequence_id
  and bos.operation_type = cv_operation_type
  and nvl(bon.transition_type, 0) <> 3;

  start_ops_rec		start_ops_cur%rowtype;

  -- For each of the starting points, traverse the network to select all the
  -- 'to' operations until the end
  cursor network_cur (cv_start_operation_sequence_id number) is
  select bon.to_op_seq_id
  from bom_operation_networks bon
  connect by prior to_op_seq_id = from_op_seq_id
             and
             nvl(bon.transition_type, 0) not in (2, 3)
  start with from_op_seq_id = cv_start_operation_sequence_id
             and
             nvl(bon.transition_type, 0) not in (2, 3);

  network_rec		network_cur%rowtype;

begin
  -- Fetch all the starting points
  for start_ops_rec in start_ops_cur (p_routing_sequence_id,
                                      p_operation_type) loop
    -- Select total_time_calc for the starting operation
    select nvl(total_time_calc, 0)
    into v_tpct
    from bom_operation_sequences
    where operation_sequence_id = start_ops_rec.start_operation_sequence_id;

    -- Fetch all the to operations from the starting operation
    for network_rec in network_cur
      (start_ops_rec.start_operation_sequence_id) loop
      -- Select total_time_calc for the to_operation
      select nvl(total_time_calc, 0)
      into v_ttc
      from bom_operation_sequences
      where operation_sequence_id = network_rec.to_op_seq_id;

      -- Set the total product cycle time
      v_tpct := v_tpct + v_ttc;
    end loop;  -- End loop for network_cur

    -- Save the max total product cycle time
    if v_tpct > v_max_tpct then
      v_max_tpct := v_tpct;
    end if;

    -- Reset total product cycle time
    v_tpct := 0;
  end loop;  -- End loop for start_ops_cur

  v_max_tpct := Round(v_max_tpct,10);
  -- Return the total product cycle time
  return v_max_tpct;
end calc_tpct;

Procedure calculate_tpct (
        p_routing_sequence_id   in      number,
        p_operation_type        in      varchar2 ) IS

total_cycle_time NUMBER:= 0;
BEGIN
   total_cycle_time := calc_tpct(p_routing_sequence_id,p_operation_type);
   update bom_operational_routings
   set total_product_cycle_time = total_cycle_time
   where common_routing_sequence_id = p_routing_sequence_id;
END calculate_tpct;



END BOM_CALC_TPCT;

/
