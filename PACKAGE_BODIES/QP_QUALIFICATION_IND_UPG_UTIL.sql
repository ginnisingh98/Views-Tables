--------------------------------------------------------
--  DDL for Package Body QP_QUALIFICATION_IND_UPG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_QUALIFICATION_IND_UPG_UTIL" as
/* $Header: QPXUQUAB.pls 120.0 2005/06/02 00:41:44 appldev noship $ */

procedure initialize_qualification_ind(
p_batchsize IN NUMBER := 5000,
l_worker    IN NUMBER := 1)
IS
err_msg VARCHAR2(240);
v_min_line number := 0;
v_max_line number := 0;

BEGIN

  begin

     select start_line_id,
            end_line_id
     into v_min_line,
          v_max_line
     from qp_upg_lines_distribution
     where worker = l_worker
	and line_type = 'QUA';

  exception

      when no_data_found then

            /* log the error */
            v_min_line := 0;
            v_max_line := 0;
            commit;
            return;
  end;

--dbms_output.put_line(v_min_line);
--dbms_output.put_line(v_max_line);
loop
update qp_list_lines qpl set qpl.qualification_ind=3
where list_line_id between v_min_line and v_max_line
and (qualification_ind is null or qualification_ind <> 3)
and rownum<=p_batchsize;

--dbms_output.put_line(p_batchsize);
--dbms_output.put_line(SQL%ROWCOUNT);

IF (SQL%ROWCOUNT<p_batchsize) THEN
 exit;
END IF;

commit;

end loop;

commit;

EXCEPTION

     WHEN OTHERS THEN

               err_msg := SUBSTR(SQLERRM, 1, 240);
               rollback;
               QP_UTIL.Log_Error (
                  p_id1 => v_min_line,
                  p_id2 => v_max_line,
               	  p_error_type => 'QUALIFICATION_IND',
	          p_error_desc => err_msg,
	          p_error_module => 'INITIALIZE_QUALIFICATION_IND');
               raise;

END initialize_qualification_ind;

procedure reinit_qualification_ind(
p_batchsize IN NUMBER := 5000,
l_worker    IN NUMBER := 1)
IS
err_msg VARCHAR2(240);
v_min_line number := 0;
v_max_line number := 0;

BEGIN

  begin

     select start_line_id,
            end_line_id
     into v_min_line,
          v_max_line
     from qp_upg_lines_distribution
     where worker = l_worker
	and line_type = 'QUA';

  exception

      when no_data_found then

            /* log the error */
            v_min_line := 0;
            v_max_line := 0;
            commit;
            return;
  end;

loop
update qp_list_lines qpl set qpl.qualification_ind=1
where list_line_id between v_min_line and v_max_line
and qualification_ind = 3
and (exists (select 'X' from qp_rltd_modifiers qprltd where qprltd.to_rltd_modifier_id=qpl.list_line_id and rltd_modifier_grp_type<>'COUPON')
or exists (select 'X' from qp_qualifiers q where q.list_header_id=qpl.list_header_id and (q.list_line_id=qpl.list_line_id or q.list_line_id IS NULL))
or not exists (select 'X' from qp_pricing_attributes qpprod where qpprod.list_line_id = qpl.list_line_id))
and rownum<=p_batchsize;

--dbms_output.put_line(SQL%ROWCOUNT);

IF (SQL%ROWCOUNT<p_batchsize) THEN
 exit;
END IF;

commit;

end loop;

commit;

EXCEPTION

     WHEN OTHERS THEN

               err_msg := SUBSTR(SQLERRM, 1, 240);
               rollback;
               QP_UTIL.Log_Error (
                  p_id1 => v_min_line,
                  p_id2 => v_max_line,
               	  p_error_type => 'QUALIFICATION_IND',
	          p_error_desc => err_msg,
	          p_error_module => 'REINIT_QUALIFICATION_IND');
               raise;

END reinit_qualification_ind;

procedure set_qualification_ind(
p_batchsize IN NUMBER := 5000,
l_worker IN NUMBER := 1)
IS
err_msg VARCHAR2(240);
v_min_line number := 0;
v_max_line number := 0;

BEGIN

  begin

     select start_line_id,
            end_line_id
     into v_min_line,
          v_max_line
     from qp_upg_lines_distribution
     where worker = l_worker
	and line_type = 'QUA';

  exception

      when no_data_found then

            /* log the error */
            v_min_line := 0;
            v_max_line := 0;
            commit;
            return;
  end;

--dbms_output.put_line('v_min_line : ' || v_min_line);
--dbms_output.put_line('v_max_line : ' || v_max_line);

loop
update qp_list_lines qpl set qpl.qualification_ind=2
where qpl.list_line_id between v_min_line and v_max_line
and exists (select 'X' from qp_rltd_modifiers qprltd where qprltd.to_rltd_modifier_id=qpl.list_line_id and rltd_modifier_grp_type<>'COUPON')
and not exists (select 'X' from qp_qualifiers q where q.list_header_id=qpl.list_header_id and (q.list_line_id=qpl.list_line_id or q.list_line_id IS NULL))
and exists (select 'X' from qp_pricing_attributes qpprod where qpprod.list_line_id = qpl.list_line_id)
and qpl.qualification_ind=1
and rownum<=p_batchsize;

--dbms_output.put_line(SQL%ROWCOUNT);

IF (SQL%ROWCOUNT<p_batchsize) THEN
 exit;
END IF;

commit;

end loop;

commit;

loop
update qp_list_lines qpl set qpl.qualification_ind=4
where qpl.list_line_id between v_min_line and v_max_line
and exists (select 'X' from qp_rltd_modifiers qprltd where qprltd.to_rltd_modifier_id=qpl.list_line_id and rltd_modifier_grp_type<>'COUPON')
and exists (select 'X' from qp_qualifiers q where q.list_header_id=qpl.list_header_id and (q.list_line_id=qpl.list_line_id or q.list_line_id IS NULL))
and not exists (select 'X' from qp_pricing_attributes qpprod where qpprod.list_line_id = qpl.list_line_id)
and qpl.qualification_ind=1
and rownum<=p_batchsize;

--dbms_output.put_line(SQL%ROWCOUNT);

IF (SQL%ROWCOUNT<p_batchsize) THEN
 exit;
END IF;

commit;

end loop;

commit;

loop
update qp_list_lines qpl set qpl.qualification_ind=5
where qpl.list_line_id between v_min_line and v_max_line
and not exists (select 'X' from qp_rltd_modifiers qprltd where qprltd.to_rltd_modifier_id=qpl.list_line_id and rltd_modifier_grp_type<>'COUPON')
and exists (select 'X' from qp_qualifiers q where q.list_header_id=qpl.list_header_id and (q.list_line_id=qpl.list_line_id or q.list_line_id IS NULL))
and not exists (select 'X' from qp_pricing_attributes qpprod where qpprod.list_line_id = qpl.list_line_id)
and qpl.qualification_ind=1
and rownum<=p_batchsize;

--dbms_output.put_line(SQL%ROWCOUNT);

IF (SQL%ROWCOUNT<p_batchsize) THEN
 exit;
END IF;

commit;

end loop;

commit;

loop
update qp_list_lines qpl set qpl.qualification_ind=6
where qpl.list_line_id between v_min_line and v_max_line
and exists (select 'X' from qp_rltd_modifiers qprltd where qprltd.to_rltd_modifier_id=qpl.list_line_id and rltd_modifier_grp_type<>'COUPON')
and not exists (select 'X' from qp_qualifiers q where q.list_header_id=qpl.list_header_id and (q.list_line_id=qpl.list_line_id or q.list_line_id IS NULL))
and not exists (select 'X' from qp_pricing_attributes qpprod where qpprod.list_line_id = qpl.list_line_id)
and qpl.qualification_ind=1
and rownum<=p_batchsize;

--dbms_output.put_line(SQL%ROWCOUNT);

IF (SQL%ROWCOUNT<p_batchsize) THEN
 exit;
END IF;

commit;

end loop;

commit;

loop
update qp_list_lines qpl set qpl.qualification_ind=7
where qpl.list_line_id between v_min_line and v_max_line
and not exists (select 'X' from qp_rltd_modifiers qprltd where qprltd.to_rltd_modifier_id=qpl.list_line_id and rltd_modifier_grp_type<>'COUPON')
and not exists (select 'X' from qp_qualifiers q where q.list_header_id=qpl.list_header_id and (q.list_line_id=qpl.list_line_id or q.list_line_id IS NULL))
and not exists (select 'X' from qp_pricing_attributes qpprod where qpprod.list_line_id = qpl.list_line_id)
and qpl.qualification_ind=1
and rownum<=p_batchsize;

--dbms_output.put_line(SQL%ROWCOUNT);

IF (SQL%ROWCOUNT<p_batchsize) THEN
 exit;
END IF;

commit;

end loop;

commit;

loop
update qp_list_lines qpl set qpl.qualification_ind=NULL
where qpl.list_line_id between v_min_line and v_max_line
and exists (select 'X' from qp_rltd_modifiers qprltd where qprltd.to_rltd_modifier_id=qpl.list_line_id and rltd_modifier_grp_type<>'COUPON')
and exists (select 'X' from qp_qualifiers q where q.list_header_id=qpl.list_header_id and (q.list_line_id=qpl.list_line_id or q.list_line_id IS NULL))
and exists (select 'X' from qp_pricing_attributes qpprod where qpprod.list_line_id = qpl.list_line_id)
and qpl.qualification_ind=1
and rownum<=p_batchsize;

--dbms_output.put_line(SQL%ROWCOUNT);

IF (SQL%ROWCOUNT<p_batchsize) THEN
 exit;
END IF;

commit;

end loop;

commit;

EXCEPTION

     WHEN OTHERS THEN

               err_msg := SUBSTR(SQLERRM, 1, 240);
               rollback;
               QP_UTIL.Log_Error (
                  p_id1 => v_min_line,
                  p_id2 => v_max_line,
               	  p_error_type => 'QUALIFICATION_IND',
	          p_error_desc => err_msg,
	          p_error_module => 'SET_QUALIFICATION_IND');
               raise;

END set_qualification_ind;

PROCEDURE  create_parallel_slabs
       (  l_workers IN NUMBER := 5,
		l_type    IN VARCHAR2 := 'QUA')
      IS
      V_TYPE              VARCHAR2(1);


      L_TOTAL_LINES     NUMBER;
      L_MIN_LINE        NUMBER;
      L_MAX_LINE        NUMBER;
      L_COUNTER           NUMBER;
      L_GAP               NUMBER;
      L_WORKER_COUNT        NUMBER;
      L_WORKER_START        NUMBER;
      L_WORKER_END          NUMBER;
      L_PRICE_LIST_LINE_ID     NUMBER;
      L_START_FLAG        NUMBER;
      L_TOTAL_WORKERS       NUMBER;

   BEGIN

      DELETE FROM qp_upg_lines_distribution
      WHERE line_type = l_type;
      COMMIT;

      BEGIN
	   IF l_type = 'QUA' THEN
          select nvl(min(list_line_id),0), nvl(max(list_line_id),0)
          into   l_min_line, l_max_line
          from   qp_list_lines;

        ELSIF l_type = 'DEN' THEN -- Related to Denormalization code
          select nvl(min(list_header_id),0), nvl(max(list_header_id),0)
          into   l_min_line, l_max_line
          from   qp_list_headers_b;

        END IF;

      EXCEPTION
        when others then
          l_min_line := 0;
          l_max_line := 0;
      END;


      FOR I in 1..l_workers loop

          l_worker_start := l_min_line + trunc( (i-1) * (l_max_line-l_min_line)/l_workers);

          l_worker_end := l_min_line + trunc(i*(l_max_line-l_min_line)/l_workers);

          if i <> l_workers then

             l_worker_end := l_worker_end - 1;

          end if;

                qp_modifier_upgrade_util_pvt.insert_line_distribution
                (
                    l_worker             => i,
                    l_start_line  => l_worker_start,
                    l_end_line    => l_worker_end,
                    l_type_var         =>l_type
                );

       END LOOP;

       commit;


end create_parallel_slabs;


PROCEDURE create_parallel_count_slabs(l_workers IN NUMBER := 5,
				      l_type    IN VARCHAR2 := 'QIN')
IS

l_max  NUMBER := 0;
l_min  NUMBER := 0;
l_slab NUMBER := 0;

l_count NUMBER;

begin

  --Check if any re-runnable slab already exists. Create new slabs only if
  --there isn't even 1 such slab existing.
  begin
     select 1
     into   l_count
     from   qp_upg_lines_distribution
     where  line_type = l_type
     and    last_proc_line is not null
     and    rownum = 1;
  exception
    when no_data_found then
      l_count := 0;
  end;


  --Re-runnable slabs do not already exist.
  if l_count = 0 then

     --So that even non-rerunnable slabs, if any, may be purged.
     delete from qp_upg_lines_distribution
     where  line_type = l_type;
     commit;

     select round(count(*)/l_workers) + 1
     into   l_slab
     from   qp_list_lines;

     for i in 1..l_workers
     loop
       begin
         select max(list_line_id), min(list_line_id)
         into   l_max, l_min
         from   (select list_line_id
                 from   (select list_line_id
                         from   qp_list_lines
                         where  list_line_id > l_max
                         order  by list_line_id
                        )
	         where  rownum <  l_slab + 1
                 );

         qp_modifier_upgrade_util_pvt.insert_line_distribution
	   	   (l_worker      => i,
		    l_start_line  => l_min,
		    l_end_line    => l_max,
		    l_type_var    => 'QIN');

         commit;

       exception
         when others then
	      l_min := 0;
	      l_max := 0;
       end;
     end loop;

  end if; --If l_count = 0, i.e.,slabs do not already exist.

end create_parallel_count_slabs;


end qp_qualification_ind_upg_util;

/
