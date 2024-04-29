--------------------------------------------------------
--  DDL for Package Body WIP_LEADTIME_TEMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_LEADTIME_TEMP_PKG" AS
/* $Header: wipltcab.pls 120.0.12000000.2 2007/02/20 23:58:38 vjambhek ship $ */

function wip_populate_leadtime_temp ( p_routing_sequence_id IN number,
                                      p_debug_level IN number) return number
IS

cursor network_csr (p_seq_num number)
is
select to_seq_num
from   bom_operation_networks_v
where  routing_sequence_id = p_routing_sequence_id
and    from_seq_num = p_seq_num
and    transition_type = 1 ;

cursor routing_csr
is
select distinct operation_seq_num
from   bom_operation_sequences
where  routing_sequence_id = p_routing_sequence_id
and    implementation_date is not null ;


l_from_op number    ;
l_next_op number    ;
l_order number := 1 ;
network_found number := 1 ;

procedure insert_temp (p_routing_seq_id number,
                       p_from_op number,
                       p_order number)
is
begin
   insert into wip_leadtime_temp  ( routing_sequence_id,
                                    operation_seq_num,
                                    network_order
                                  )
                           values ( p_routing_seq_id,
                                    p_from_op,
                                    p_order
                                  );

end insert_temp ;

begin

  -- Find Root node and populate temp ;

     begin

     -- Fixed bug #5691032 - FP for bug#5572730.
     -- Added distinct in the select clause below.
     select distinct from_seq_num
     into   l_from_op
     from   bom_operation_networks_v a
     where  routing_sequence_id = p_routing_sequence_id
     and    not exists  (select 1
                         from   bom_operation_networks_v b
                         where  a.routing_sequence_id = b.routing_sequence_id
                         and    b.to_seq_num = a.from_seq_num
                         and    b.transition_type = 1
                         )
     and    a.transition_type = 1 ;

     if p_debug_level = 1 then
      fnd_file.put_line (fnd_file.log, 'Inserting into wip_leadtime_temp for Network routing ' || p_routing_sequence_id );
      fnd_file.put_line(fnd_file.log, 'Operation Seq.Num ' || l_from_op || ' Order ' || l_order) ;
     end if ;

     insert_temp(p_routing_sequence_id, l_from_op, l_order)  ;

     exception
            when no_data_found then
            network_found := 0 ;
            if (p_debug_level = 1) then
               fnd_file.put_line (fnd_file.log, 'Inserting into wip_leadtime_temp for Non Network routing ' || p_routing_sequence_id );          end if ;
            for routing_rec in routing_csr loop
                  if (p_debug_level = 1) then
                   fnd_file.put_line(fnd_file.log, 'Operation Seq.Num ' || routing_rec.operation_seq_num) ;
                  end if ;
                  insert_temp(p_routing_sequence_id, routing_rec.operation_seq_num, l_order)  ;
	    end loop ;

     end ;

     if network_found = 0  then
        return 1 ;
     end if ;



  -- Populate rest of the operations
     loop
      open network_csr (l_from_op) ;
      fetch network_csr into l_next_op ;
      exit when network_csr%NOTFOUND ;
      close network_csr ;
      l_from_op := l_next_op ;
      l_order := l_order + 1 ;
      if (p_debug_level = 1) then
       fnd_file.put_line(fnd_file.log, 'Operation Seq.Num ' || l_from_op || ' Order ' || l_order) ;
      end if ;
      insert_temp(p_routing_sequence_id, l_from_op, l_order)  ;
     end loop ;

     if network_csr%ISOPEN then
        close network_csr ;
     end if ;

     return 1 ;

exception
     when others then
          return 0 ;  -- Unsuccessfull

end wip_populate_leadtime_temp ;

function wip_delete_leadtime_temp (p_debug_level IN number) return number
as
begin

  delete wip_leadtime_temp  ;
  if (p_debug_level = 1) then
     fnd_file.put_line (fnd_file.log, 'Deleted rows ' || sql%ROWCOUNT  ||' from wip_leadtime_temp '  );
  end if ;

  return 1 ; -- successfull

exception
  when others then
       return 0 ; -- Unsuccessfull

end wip_delete_leadtime_temp ;

END WIP_LEADTIME_TEMP_PKG  ;

/
