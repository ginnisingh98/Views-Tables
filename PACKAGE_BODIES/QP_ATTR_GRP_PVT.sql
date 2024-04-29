--------------------------------------------------------
--  DDL for Package Body QP_ATTR_GRP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_ATTR_GRP_PVT" as
/* $Header: QPXVATGB.pls 120.2.12010000.5 2009/08/12 12:13:37 jputta ship $ */

G_LINES_PER_INSERT CONSTANT NUMBER := 5000;

procedure create_pattern_slabs(
 p_total_lines		IN number,
 p_list_header_id       IN number default null,
 p_no_of_threads	IN NUMBER default 1)
is
  cursor list_line is
    select list_line_id from qp_list_lines where qualification_ind in (8,10,12,14,28,30, 4,6,20,22)
    and list_header_id = nvl(p_list_header_id, list_header_id)
    order by list_line_id;

 l_gap          number := 0;
 l_list_line_id          number := 0;
 l_counter          number := 0;
 l_min_line        number := 0;
 l_max_line        number := 0;
 l_worker_count        number := 0;
 l_start_flag        number := 0;
 l_no_of_threads     number := 0;

begin

    if g_call_from_setup = 'Y' then
       oe_debug_pub.add('Begin create pattern slabs');
    else
       fnd_file.put_line(FND_FILE.LOG, 'Begin create pattern slabs');
       fnd_file.put_line(FND_FILE.LOG, 'Start time :'||to_char(sysdate,'MM/DD/YYYY:HH:MI:SSSS'));
    end if;
    l_no_of_threads := p_no_of_threads;
    if l_no_of_threads > p_total_lines then
	l_no_of_threads := p_total_lines;
    end if;
    l_gap  := round(p_total_lines / l_no_of_threads, 0);

    if g_call_from_setup = 'Y' then
       oe_debug_pub.add('Total lines:'||p_total_lines);
       oe_debug_pub.add('l_gap:'||l_gap);
    else
       fnd_file.put_line(FND_FILE.LOG, 'Total lines:'||p_total_lines);
       fnd_file.put_line(FND_FILE.LOG, 'l_gap:'||l_gap);
    end if;
    if p_total_lines > 0 then
     for line_rec in list_line loop

       l_list_line_id := line_rec.list_line_id;
       l_counter       := l_counter + 1;

       if l_start_flag = 0 then
	 l_start_flag := 1;
	 l_min_line := line_rec.list_line_id;
	 l_max_line := NULL;
	 l_worker_count := l_worker_count + 1;
       end if;

       if l_counter = l_gap and l_worker_count < l_no_of_threads
       then
	 l_max_line := line_rec.list_line_id;

	 -- add l_worker_count, l_min_line, l_max_line into a pl/sql table
	 g_pattern_upg_slab_table(l_worker_count).worker := l_worker_count;
	 g_pattern_upg_slab_table(l_worker_count).low_list_line_id := l_min_line;
	 g_pattern_upg_slab_table(l_worker_count).high_list_line_id := l_max_line;

	 l_counter    := 0;
	 l_start_flag := 0;

       end if;

     end loop;
     l_max_line := l_list_line_id;
	 -- add l_worker_count, l_min_line, l_max_line into a pl/sql table
     g_pattern_upg_slab_table(l_worker_count).worker := l_worker_count;
     g_pattern_upg_slab_table(l_worker_count).low_list_line_id := l_min_line;
     g_pattern_upg_slab_table(l_worker_count).high_list_line_id := l_max_line;

    end if;
    fnd_file.put_line(FND_FILE.LOG, 'End create pattern slabs');
    fnd_file.put_line(FND_FILE.LOG, 'End time :'||to_char(sysdate,'MM/DD/YYYY:HH:MI:SSSS'));

end create_pattern_slabs;

procedure remove_duplicate_patterns
is

l_min_pattern_id number;

cursor c_dupl_pattern is
select distinct b.pattern_type, b.pattern_string, b.pattern_id
from qp_patterns a, qp_patterns b
where a.pattern_type = b.pattern_type
and a.pattern_string = b.pattern_string
and a.pattern_id <> b.pattern_id
and b.pattern_id >(select min(c.pattern_id)
		   from qp_patterns c
		   where c.pattern_type = a.pattern_type
		   and c.pattern_string = a.pattern_string);
begin

  fnd_file.put_line(FND_FILE.LOG, 'In Remove_Duplicate_Patterns');
  fnd_file.put_line(FND_FILE.LOG, 'Start time :'||to_char(sysdate,'MM/DD/YYYY:HH:MI:SSSS'));

  g_pattern_pattern_id_final_tbl.delete;
  g_pattern_pat_type_final_tbl.delete;
  g_pattern_pat_string_final_tbl.delete;

  open c_dupl_pattern;

  FETCH c_dupl_pattern BULK COLLECT INTO
  g_pattern_pat_type_final_tbl,
  g_pattern_pat_string_final_tbl,
  g_pattern_pattern_id_final_tbl;
  CLOSE c_dupl_pattern;

  fnd_file.put_line(FND_FILE.LOG, 'No of Duplicate_Patterns='||g_pattern_pattern_id_final_tbl.count);
  if g_pattern_pattern_id_final_tbl.count > 0 then
    for i in 1..g_pattern_pattern_id_final_tbl.count
    loop
	select min(c.pattern_id)
	into l_min_pattern_id
	from qp_patterns c
	where c.pattern_type = g_pattern_pat_type_final_tbl(i)
	and c.pattern_string = g_pattern_pat_string_final_tbl(i);

	if g_pattern_pat_type_final_tbl(i) = 'PP' then
		update /*+ index(lines QP_LIST_LINES_N9) */ qp_list_lines lines
		set pattern_id = l_min_pattern_id
		where pattern_id = g_pattern_pattern_id_final_tbl(i);
	else
		update qp_attribute_groups
		set pattern_id = l_min_pattern_id
		where pattern_id = g_pattern_pattern_id_final_tbl(i);
	end if;

        -- delete the records where pricing_phase_id matches to avoid duplicates
        delete from qp_pattern_phases a
        where a.pattern_id = g_pattern_pattern_id_final_tbl(i)
          and a.pricing_phase_id in (select b.pricing_phase_id
                                       from qp_pattern_phases b
                                      where b.pattern_id = l_min_pattern_id);

        -- update the records where pricing_phase_id DO NOT matches
	update qp_pattern_phases
	set pattern_id = l_min_pattern_id
	where pattern_id = g_pattern_pattern_id_final_tbl(i);
    end loop;
  end if;

  FORALL i in 1 .. G_pattern_pattern_id_final_tbl.count
  DELETE qp_patterns
  where  pattern_id = g_pattern_pattern_id_final_tbl(i);

  g_pattern_pattern_id_final_tbl.delete;
  g_pattern_pat_type_final_tbl.delete;
  g_pattern_pat_string_final_tbl.delete;

  fnd_file.put_line(FND_FILE.LOG, 'End time :'||to_char(sysdate,'MM/DD/YYYY:HH:MI:SSSS'));
  fnd_file.put_line(FND_FILE.LOG, 'COMMIT in remove_duplicate_patterns');
  commit;

EXCEPTION
  WHEN OTHERS THEN
    if g_call_from_setup = 'Y' then
      oe_debug_pub.add('ATTR_GRP_PVT.Remove_Duplicate_Patterns ' || SQLERRM);
    else
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'ATTR_GRP_PVT.Remove_Duplicate_Patterns ' || SQLERRM );
    end if;

end remove_duplicate_patterns;

PROCEDURE Pattern_Upgrade (
 err_buff 		out NOCOPY VARCHAR2,
 retcode 		out NOCOPY NUMBER,
 p_list_header_id       IN number default null,
 p_low_list_line_id	IN NUMBER default null,
 p_high_list_line_id    IN NUMBER default null,
 p_no_of_threads	IN NUMBER default 1,
 p_spawned_request	IN VARCHAR2 default 'N',
 p_debug                IN VARCHAR2 DEFAULT 'N')
is
l_slab_count	NUMBER;
l_count		NUMBER;
l_new_request_id NUMBER;
l_no_of_threads NUMBER:=p_no_of_threads;
l_req_data VARCHAR2(10);
l_total_lines  number := 0;

l_start_time number;
l_end_time number;
v_sid number;

l_qp_schema           VARCHAR2(30);
l_stmt                 VARCHAR2(200);
l_status               VARCHAR2(30);
l_industry             VARCHAR2(30);


BEGIN
  -- Check Java Engine Installed profile
 -- FND_PROFILE.PUT('QP_INTERNAL_11510_J', 'QWERTY'); -- added to avoid the setting of profile QP_INTERNAL_11510_J to QWERTY manually
  if QP_JAVA_ENGINE_UTIL_PUB.Java_Engine_Installed = 'Y' then
       fnd_file.put_line(FND_FILE.LOG, 'Java Engine Installed');
       fnd_file.put_line(FND_FILE.LOG, 'p_list_header_id ' || p_list_header_id);
       fnd_file.put_line(FND_FILE.LOG, 'p_low_list_line_id ' || p_low_list_line_id);
       fnd_file.put_line(FND_FILE.LOG, 'p_high_list_line_id ' || p_high_list_line_id);
       fnd_file.put_line(FND_FILE.LOG, 'p_no_of_threads ' || p_no_of_threads);
       fnd_file.put_line(FND_FILE.LOG, 'p_spawned_request ' || p_spawned_request);

       select sid into v_sid from v$session where audsid = userenv('SESSIONID');

       fnd_file.put_line(FND_FILE.LOG, 'session ID = ' || v_sid);
  ELSE
       IF FND_PROFILE.VALUE('QP_PATTERN_SEARCH') <> 'N' THEN
       fnd_file.put_line(FND_FILE.LOG, 'Java Engine not Installed');
       END IF;
       QP_PS_ATTR_GRP_PVT.Pattern_Upgrade(err_buff, retcode, p_list_header_id, p_low_list_line_id, p_high_list_line_id, p_no_of_threads, p_spawned_request, p_debug);
    return;
  end if;

  --refresh the pattern data
  if p_spawned_request = 'N' then
     if p_no_of_threads is NULL or p_no_of_threads = 0 then
	l_no_of_threads := 1;
     end if;
     l_req_data := fnd_conc_global.request_data;
     fnd_file.put_line(FND_FILE.LOG, 'l_req_data : ' || l_req_data);
     if l_req_data is not NULL then
	remove_duplicate_patterns;
	return;
     end if;

     select hsecs into l_start_time from v$timer;
     fnd_file.put_line(FND_FILE.LOG, 'Start time :'||to_char(sysdate,'MM/DD/YYYY:HH:MI:SSSS'));

     if p_list_header_id is null then
	    -- like upgrade, refresh everything related to patterns
	    IF (FND_INSTALLATION.GET_APP_INFO('QP', l_status, l_industry, l_qp_schema))
	    THEN
	      l_stmt := 'TRUNCATE TABLE ' || l_qp_schema || '.qp_pattern_phases';
	      EXECUTE IMMEDIATE l_stmt;
	      l_stmt := 'TRUNCATE TABLE ' || l_qp_schema || '.qp_attribute_groups';
	      EXECUTE IMMEDIATE l_stmt;
	      l_stmt := 'TRUNCATE TABLE ' || l_qp_schema || '.qp_patterns';
	      EXECUTE IMMEDIATE l_stmt;
	    END IF;

       fnd_file.put_line(FND_FILE.LOG, 'Deleted all records from 3 Pattern Master tables');
     else
	    -- refresh only for the passed list_header_id
	    delete from qp_attribute_groups
	    where list_header_id = p_list_header_id
	    and	list_line_id = -1;
	    fnd_file.put_line(FND_FILE.LOG, 'Deleted records from qp_attribute_groups for HP for list_header_id:'||p_list_header_id);

     end if;
     Update_Qual_Segment_id(p_list_header_id, null, -1, -1);
     generate_hp_atgrps(p_list_header_id, null);

     g_pattern_upg_slab_table.delete;
     IF p_list_header_id IS NULL THEN
      select count(*)
       into l_total_lines
       from qp_list_lines
      where qualification_ind in (8,10,12,14,28,30, 4,6,20,22);
     ELSE
      select count(*)
       into l_total_lines
       from qp_list_lines
      where qualification_ind in (8,10,12,14,28,30, 4,6,20,22)
	and list_header_id = p_list_header_id;
     END IF;
     fnd_file.put_line(FND_FILE.LOG, 'l_total_lines ' || l_total_lines);
     if l_total_lines > 0 then
	 create_pattern_slabs(l_total_lines, p_list_header_id, l_no_of_threads);
	 l_slab_count := g_pattern_upg_slab_table.count;
         fnd_file.put_line(FND_FILE.LOG, 'l_slab_count ' || l_slab_count);
	 l_count := 1;
	 loop
	 l_new_request_id := fnd_request.submit_request(
			    'QP',
			    'QPXVATG',
			    'Pattern Upgrade '||to_char(l_count),
			    NULL,
			    TRUE,
			    p_list_header_id,
			    g_pattern_upg_slab_table(l_count).low_list_line_id,
			    g_pattern_upg_slab_table(l_count).high_list_line_id,
			    1,
			    'Y',
			    p_debug);
	 if l_new_request_id = 0 then
		 retcode := 2;
		 err_buff := fnd_message.get;
                 fnd_file.put_line(FND_FILE.LOG, 'err_buff ' || err_buff);
		 return;
	 end if;
	 FND_FILE.PUT_LINE(FND_FILE.LOG , 'Child '||l_count||' request_id: '||l_new_request_id);

	 l_count := l_count + 1;
	 exit when l_count > l_slab_count;
	 end loop;

	select hsecs into l_end_time from v$timer;
        fnd_file.put_line(FND_FILE.LOG, 'End time :'||to_char(sysdate,'MM/DD/YYYY:HH:MI:SSSS'));
	fnd_file.put_line(fnd_file.log, 'Time taken for the header process (sec):' ||(l_end_time - l_start_time)/100);

	 fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
     				     request_data => to_char(l_count));

         fnd_file.put_line(FND_FILE.LOG, 'Time after parent request PAUSE over :'||to_char(sysdate,'MM/DD/YYYY:HH:MI:SSSS'));

    else -- if l_total_lines > 0
	  if p_list_header_id is null then
	    -- like upgrade, refresh everything related to patterns
	    update qp_list_lines
	       set pattern_id = null,
		   pricing_attribute_count = null,
		   product_uom_code = null,
		   hash_key = null,
		   cache_key = null
	     where cache_key is not null;

	  else
	    -- refresh only for the passed list_header_id

	    delete from qp_attribute_groups
	    where list_header_id = p_list_header_id
	    and list_line_id <> -1;

	    update qp_list_lines
	       set pattern_id = null,
		   pricing_attribute_count = null,
		   product_uom_code = null,
		   hash_key = null,
		   cache_key = null
	     where cache_key is not null
	       and list_header_id = p_list_header_id;
	 end if;

    end if; -- if l_total_lines > 0
  end if; -- if p_spawned_request = 'N'

  if p_spawned_request = 'Y' then
	  select hsecs into l_start_time from v$timer;
          fnd_file.put_line(FND_FILE.LOG, 'Start time :'||to_char(sysdate,'MM/DD/YYYY:HH:MI:SSSS'));
	  if p_list_header_id is null then
	    -- like upgrade, refresh everything related to patterns
	    update /*+ index_asc(lines QP_LIST_LINES_PK) */ qp_list_lines lines
	       set pattern_id = null,
		   pricing_attribute_count = null,
		   product_uom_code = null,
		   hash_key = null,
		   cache_key = null
	     where cache_key is not null
	     and list_line_id between p_low_list_line_id and p_high_list_line_id;
	  else
	    -- refresh only for the passed list_header_id

	    delete from qp_attribute_groups
	    where list_header_id = p_list_header_id
	    and list_line_id between p_low_list_line_id and p_high_list_line_id;

	    update /*+ index_asc(lines QP_LIST_LINES_PK) */ qp_list_lines lines
	       set pattern_id = null,
		   pricing_attribute_count = null,
		   product_uom_code = null,
		   hash_key = null,
		   cache_key = null
	     where cache_key is not null
	       and list_header_id = p_list_header_id
	       and list_line_id between p_low_list_line_id and p_high_list_line_id;
	 end if;
	  -- update the segment_id columns for qualifiers
	  Update_Qual_Segment_id(p_list_header_id, null,
	  			 p_low_list_line_id,
				 p_high_list_line_id);

	  -- update the product_segment_id and pricing_segment_id columns in
	  -- qp_pricing_attributes
	  Update_Prod_Pric_Segment_id(p_list_header_id,
	  			 p_low_list_line_id,
				 p_high_list_line_id);

	  generate_lp_atgrps(p_list_header_id, null,
	  			 p_low_list_line_id,
				 p_high_list_line_id);
	  update_pp_lines(p_list_header_id,
	  			 p_low_list_line_id,
				 p_high_list_line_id);
	select hsecs into l_end_time from v$timer;
        fnd_file.put_line(FND_FILE.LOG, 'End time :'||to_char(sysdate,'MM/DD/YYYY:HH:MI:SSSS'));
	fnd_file.put_line(fnd_file.log, 'Time taken for the line process (sec):' ||(l_end_time - l_start_time)/100);
  end if; -- if p_spawned_request = 'Y'
  -- commit the changes done so far
  fnd_file.put_line(FND_FILE.LOG, 'COMMIT in Pattern_Upgrade');
  commit;


  err_buff := '';
  retcode  := 0;
exception
  when others then
    if g_call_from_setup = 'Y' then
      oe_debug_pub.add('ATTR_GRP_PVT.Pattern_Upgrade ' || SQLERRM);
    else
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'ATTR_GRP_PVT.Pattern_Upgrade ' || SQLERRM );
    end if;
     err_buff := 'Others Error in procedure Pattern_Upgrade';
     retcode  := 1;

end Pattern_Upgrade;


procedure generate_hp_atgrps(p_list_header_id  number
                            ,p_qualifier_group number)
is
cursor c_attr_grp_hq_csr is
  select qpq.list_header_id,
	qpq.list_line_id,
	qpq.segment_id,
	qpq.active_flag,
	qpq.list_type_code,
	qpq.start_date_active start_date_active_q,
	qpq.end_date_active end_date_active_q,
	qph.currency_code,
	qph.ask_for_flag,
	qph.limit_exists_flag limit_exists,
	qph.source_system_code,
	qpq.qualifier_precedence effective_precedence,
	qpq.qualifier_grouping_no,
	qpq.comparison_operator_code,
	-1 pricing_phase_id,
        null modifier_level_code,
	qpq.qualifier_datatype attribute_datatype,
	qpq.qualifier_attr_value attribute_value,
        'QUAL' attribute_type
	from qp_qualifiers qpq,
             qp_list_headers_b qph
	where qpq.list_line_id = -1
          and qph.list_header_id = qpq.list_header_id
          and qpq.list_header_id = nvl(p_list_header_id, qpq.list_header_id)
          and ((p_qualifier_group is not null and qpq.qualifier_grouping_no in (-1, p_qualifier_group))
               OR
               (p_qualifier_group is null)
              )
          and ((qpq.list_type_code = 'PRL' and qpq.qualifier_context <> 'MODLIST'
                and qpq.qualifier_attribute <> 'QUALIFIER_ATTRIBUTE4')
               OR
               (qpq.list_type_code <> 'PRL')
              )
  order by qpq.list_header_id, qpq.list_line_id, qpq.segment_id;
begin
  -- delete the data from cursor, temp and final tables to start with
  if g_call_from_setup = 'Y' then
       oe_debug_pub.add('Begin generate_hp_atgrps');
  else
       fnd_file.put_line(FND_FILE.LOG, 'Begin generate_hp_atgrps');
  end if;
  Reset_c_tables;
  Reset_tmp_tables;
  Reset_final_tables;

  open c_attr_grp_hq_csr;

  FETCH c_attr_grp_hq_csr BULK COLLECT INTO
    g_list_header_id_c_tbl,
    g_list_line_id_c_tbl,
    g_segment_id_c_tbl,
    g_active_flag_c_tbl,
    g_list_type_code_c_tbl,
    g_start_date_active_q_c_tbl,
    g_end_date_active_q_c_tbl,
    g_currency_code_c_tbl,
    g_ask_for_flag_c_tbl,
    g_limit_exists_c_tbl,
    g_source_system_code_c_tbl,
    g_effective_precedence_c_tbl,
    g_qual_grouping_no_c_tbl,
    g_comparison_opr_code_c_tbl,
    g_pricing_phase_id_c_tbl,
    g_modifier_level_code_c_tbl,
    g_qual_datatype_c_tbl,
    g_qual_attr_val_c_tbl,
    g_attribute_type_c_tbl;

  CLOSE c_attr_grp_hq_csr;

  if g_list_header_id_c_tbl.count > 0 then
    process_c_tables('HP');
  end if;
  if g_call_from_setup = 'Y' then
       oe_debug_pub.add('End generate_hp_atgrps');
  else
       fnd_file.put_line(FND_FILE.LOG, 'End generate_hp_atgrps');
  end if;

EXCEPTION
  WHEN OTHERS THEN
    if g_call_from_setup = 'Y' then
      oe_debug_pub.add('ATTR_GRP_PVT.Generate_Hp_Atgrps ' || SQLERRM);
    else
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'ATTR_GRP_PVT.Generate_Hp_Atgrps ' || SQLERRM );
    end if;

end generate_hp_atgrps;

procedure generate_lp_atgrps(p_list_header_id  number
--                            ,p_list_line_id    number
                            ,p_qualifier_group number
			    ,p_low_list_line_id IN NUMBER
			    ,p_high_list_line_id IN NUMBER)
is
cursor c_attr_grp_lq_csr is
  select * from
  (select /*+ ordered use_nl(qpq, qph) index(qpl QP_LIST_LINES_N6) */ qpq.list_header_id,
	qpq.list_line_id,
	qpq.segment_id,
	qpq.active_flag,
	qpq.list_type_code,
	qpq.start_date_active start_date_active_q,
	qpq.end_date_active end_date_active_q,
	qph.currency_code,
	qph.ask_for_flag,
	qpl.limit_exists_flag limit_exists,
	qph.source_system_code,
	qpq.qualifier_precedence effective_precedence,
	qpq.qualifier_grouping_no,
	qpq.comparison_operator_code,
	qpl.pricing_phase_id pricing_phase_id,
        qpl.modifier_level_code modifier_level_code,
	qpq.qualifier_datatype attribute_datatype,
	qpq.qualifier_attr_value attribute_value,
        'QUAL' attribute_type
	from qp_list_lines qpl, qp_qualifiers qpq, qp_list_headers_b qph
	where qpq.list_line_id <> -1
          and qph.list_header_id = qpq.list_header_id
          and qpl.list_header_id = qph.list_header_id
          and qpl.list_line_id = qpq.list_line_id
          and qpl.pricing_phase_id > 1
          and qpl.qualification_ind in (8,10,12,14,28,30)
	  and qpl.list_line_id between p_low_list_line_id and p_high_list_line_id
          and ((p_qualifier_group is not null and qpq.qualifier_grouping_no in (-1, p_qualifier_group))
               OR
               (p_qualifier_group is null)
              )
  union
  select /*+ ordered use_nl(qpa, qph) index(qpl QP_LIST_LINES_N6) */ distinct qpl.list_header_id,
	qpl.list_line_id,
	qpa.product_segment_id segment_id,
	qph.active_flag,
	qph.list_type_code,
	to_date(null) start_date_active_q,
	to_date(null) end_date_active_q,
	qph.currency_code,
	qph.ask_for_flag,
	qpl.limit_exists_flag limit_exists,
	qph.source_system_code,
	qpl.product_precedence effective_precedence,
	-1 qualifier_grouping_no,
	'=' comparison_operator_code,
	qpl.pricing_phase_id pricing_phase_id,
        qpl.modifier_level_code modifier_level_code,
	qpa.product_attribute_datatype attribute_datatype,
	qpa.product_attr_value attribute_value,
        'PROD' attribute_type
        from qp_list_lines qpl, qp_pricing_attributes qpa, qp_list_headers_b qph
	where qph.list_header_id = qpl.list_header_id
          and qpl.list_line_id = qpa.list_line_id
	  and qpa.excluder_flag = 'N'
          and qpl.pricing_phase_id > 1
          and qpl.qualification_ind in (8,10,12,14,28,30)
          and qpa.product_attribute_context is not null
          and (qpa.pricing_attribute_context = 'VOLUME' or
               qpa.pricing_attribute_context is null
              )
	  and qpl.list_line_id between p_low_list_line_id and p_high_list_line_id
  union
  select /*+ ordered use_nl(qpa, qph) index(qpl QP_LIST_LINES_N6) */ qpl.list_header_id,
	qpl.list_line_id,
	qpa.pricing_segment_id segment_id,
	qph.active_flag,
	qph.list_type_code,
	to_date(null) start_date_active_q,
	to_date(null) end_date_active_q,
	qph.currency_code,
	qph.ask_for_flag,
	qpl.limit_exists_flag limit_exists,
	qph.source_system_code,
	qpl.product_precedence effective_precedence,
	-1 qualifier_grouping_no,
	qpa.comparison_operator_code,
	qpl.pricing_phase_id pricing_phase_id,
        qpl.modifier_level_code modifier_level_code,
	qpa.pricing_attribute_datatype attribute_datatype,
	qpa.pricing_attr_value_from attribute_value,
        'PRIC' attribute_type
        from qp_list_lines qpl, qp_pricing_attributes qpa, qp_list_headers_b qph
	where qph.list_header_id = qpl.list_header_id
          and qpl.list_line_id = qpa.list_line_id
          and qpl.pricing_phase_id > 1
          and qpl.qualification_ind in (8,10,12,14,28,30)
          and qpa.pricing_attribute_context is not null
	  and qpl.list_line_id between p_low_list_line_id and p_high_list_line_id
    ) attr_view
  order by attr_view.list_header_id, attr_view.list_line_id, attr_view.segment_id;
begin
  -- delete the data from cursor, temp and final tables to start with
  Reset_c_tables;
  Reset_tmp_tables;
  Reset_final_tables;

  open c_attr_grp_lq_csr;

  FETCH c_attr_grp_lq_csr BULK COLLECT INTO
    g_list_header_id_c_tbl,
    g_list_line_id_c_tbl,
    g_segment_id_c_tbl,
    g_active_flag_c_tbl,
    g_list_type_code_c_tbl,
    g_start_date_active_q_c_tbl,
    g_end_date_active_q_c_tbl,
    g_currency_code_c_tbl,
    g_ask_for_flag_c_tbl,
    g_limit_exists_c_tbl,
    g_source_system_code_c_tbl,
    g_effective_precedence_c_tbl,
    g_qual_grouping_no_c_tbl,
    g_comparison_opr_code_c_tbl,
    g_pricing_phase_id_c_tbl,
    g_modifier_level_code_c_tbl,
    g_qual_datatype_c_tbl,
    g_qual_attr_val_c_tbl,
    g_attribute_type_c_tbl;

  CLOSE c_attr_grp_lq_csr;

  if g_list_header_id_c_tbl.count > 0 then
    process_c_tables('LP');
  end if;

EXCEPTION
  WHEN OTHERS THEN
    if g_call_from_setup = 'Y' then
      oe_debug_pub.add('ATTR_GRP_PVT.Generate_Lp_Atgrps ' || SQLERRM);
    else
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'ATTR_GRP_PVT.Generate_Lp_Atgrps ' || SQLERRM );
    end if;

end generate_lp_atgrps;

procedure update_pp_lines(p_list_header_id  number
--                         ,p_list_line_id    number
			 ,p_low_list_line_id IN NUMBER
			 ,p_high_list_line_id IN NUMBER)
is
cursor c_lines_pp_csr is
  select * from
  (select /*+ ordered use_nl(qpa) index(qpl QP_LIST_LINES_N6) */ distinct qpa.list_header_id,
        qpa.list_line_id,
        qpa.product_segment_id segment_id,
        '=' comparison_operator_code,
        qpa.pricing_phase_id,
        qpa.product_uom_code,
        qpa.product_attribute_datatype attribute_datatype,
        qpa.product_attr_value attribute_value,
        'PROD' attribute_type
        from qp_list_lines qpl,
             qp_pricing_attributes qpa
        where qpl.list_line_id = qpa.list_line_id
          and qpa.excluder_flag = 'N'
          and qpl.qualification_ind in (4,6,20,22)
          and qpa.product_attribute_context is not null
          and (qpa.pricing_attribute_context = 'VOLUME' or
               qpa.pricing_attribute_context is null
              )
          and qpl.list_line_id between p_low_list_line_id and p_high_list_line_id
  union
  select /*+ ordered use_nl(qpa) index(qpl QP_LIST_LINES_N6) */ qpa.list_header_id,
        qpa.list_line_id,
        qpa.pricing_segment_id segment_id,
        qpa.comparison_operator_code,
        qpa.pricing_phase_id,
        qpa.product_uom_code,
        qpa.pricing_attribute_datatype attribute_datatype,
        qpa.pricing_attr_value_from attribute_value,
        'PRIC' attribute_type
        from qp_list_lines qpl,
             qp_pricing_attributes qpa
        where qpl.list_line_id = qpa.list_line_id
          and qpl.qualification_ind in (20,22)
          and qpa.pricing_attribute_context is not null
          and qpl.list_line_id between p_low_list_line_id and p_high_list_line_id
    ) attr_view
  order by attr_view.list_header_id, attr_view.list_line_id, attr_view.segment_id;
begin
  -- delete the data from cursor, temp and final tables to start with
  Reset_c_tables;
  Reset_tmp_tables;
  Reset_final_tables;

  open c_lines_pp_csr;

  FETCH c_lines_pp_csr BULK COLLECT INTO
    g_list_header_id_c_tbl,
    g_list_line_id_c_tbl,
    g_segment_id_c_tbl,
    g_comparison_opr_code_c_tbl,
    g_pricing_phase_id_c_tbl,
    g_product_uom_code_c_tbl,
    g_qual_datatype_c_tbl,
    g_qual_attr_val_c_tbl,
    g_attribute_type_c_tbl;

  CLOSE c_lines_pp_csr;

  if g_list_header_id_c_tbl.count > 0 then
    process_c_tables_pp('PP');
  end if;

EXCEPTION
  WHEN OTHERS THEN
    if g_call_from_setup = 'Y' then
      oe_debug_pub.add('ATTR_GRP_PVT.Update_Pp_Lines ' || SQLERRM);
    else
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'ATTR_GRP_PVT.Update_Pp_Lines ' || SQLERRM );
    end if;

end update_pp_lines;

procedure process_c_tables(p_pattern_type  VARCHAR2)
is
  l_old_list_header_id            number;
  l_old_list_line_id              number;
  l_current_grp  number;
  l_pat_tmp_index number;
  other_grp_index number;
  l_prefix_value_from_null_grp varchar2(1);
  l_debug               VARCHAR2(3);
  l_line_counter        number := 0;

begin
  l_old_list_header_id := g_init_val;
  l_old_list_line_id := g_init_val;

  if g_call_from_setup = 'Y' then
    oe_debug_pub.add('Start process_c_tables - Pattern type '||p_pattern_type);
    oe_debug_pub.add('cursor tables total = ' || g_list_header_id_c_tbl.count);
  else
    QP_PREQ_GRP.Set_QP_Debug;
    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    IF l_debug = FND_API.G_TRUE THEN
      fnd_file.put_line(FND_FILE.LOG, 'Start process_c_tables - Pattern type '||p_pattern_type);
      fnd_file.put_line(FND_FILE.LOG, 'cursor tables total = ' || g_list_header_id_c_tbl.count);
    END IF;
  end if;

  if g_list_header_id_c_tbl.count > 0 then
    for i in 1..g_list_header_id_c_tbl.count
    loop
      if g_call_from_setup = 'Y' then
        oe_debug_pub.add('i = ' || i ||
                         ', list_header_id = ' || g_list_header_id_c_tbl(i) ||
                         ', list_line_id = ' || g_list_line_id_c_tbl(i) ||
                         ', group = ' || g_qual_grouping_no_c_tbl(i) ||
                         ', operator = ' || g_comparison_opr_code_c_tbl(i));
        --oe_debug_pub.add('l_old_list_header_id ' || l_old_list_header_id);
        --oe_debug_pub.add('l_old_list_line_id ' || l_old_list_line_id);
      elsif l_debug = FND_API.G_TRUE then
        fnd_file.put_line(FND_FILE.LOG, 'i = ' || i ||
                         ', list_header_id = ' || g_list_header_id_c_tbl(i) ||
                         ', list_line_id = ' || g_list_line_id_c_tbl(i) ||
                         ', group = ' || g_qual_grouping_no_c_tbl(i) ||
                         ', operator = ' || g_comparison_opr_code_c_tbl(i));
        --fnd_file.put_line(FND_FILE.LOG, 'l_old_list_header_id ' || l_old_list_header_id);
        --fnd_file.put_line(FND_FILE.LOG, 'l_old_list_line_id ' || l_old_list_line_id);
      end if;

      if (i > 1
          and (g_list_header_id_c_tbl(i) <> l_old_list_header_id
               or g_list_line_id_c_tbl(i) <> l_old_list_line_id)
         ) then
        Move_data_from_tmp_to_final(p_pattern_type);
        Reset_tmp_tables;

        -- logic to insert into tables every G_LINES_PER_INSERT lines
        l_line_counter := l_line_counter + 1;
        if l_line_counter >= G_LINES_PER_INSERT then
          if g_call_from_setup = 'Y' then
            oe_debug_pub.add('inserting data for ' || G_LINES_PER_INSERT || ' lines');
          elsif l_debug = FND_API.G_TRUE then
            fnd_file.put_line(FND_FILE.LOG, 'inserting data for ' || G_LINES_PER_INSERT || ' lines');
          end if;
          populate_atgrps;
          if p_pattern_type = 'LP' then
            update_list_lines_cache_key;
          end if;
          reset_final_tables;
          if g_call_from_setup <> 'Y' then
            if l_debug = FND_API.G_TRUE then
              fnd_file.put_line(FND_FILE.LOG, 'committing data for ' || G_LINES_PER_INSERT || ' lines');
            end if;
            commit;
          end if;
          l_line_counter := 0;
        end if;
      end if;
      l_current_grp := g_qual_grouping_no_c_tbl(i);

      if g_qual_grouping_no_tmp_tbl.exists(l_current_grp) = TRUE then

        /*
        if g_call_from_setup = 'Y' then
          oe_debug_pub.add('record exists in temp table for current group');
          oe_debug_pub.add('current record Operator is  ' || g_comparison_opr_code_c_tbl(i));
        else
          fnd_file.put_line(FND_FILE.LOG, 'record exists in temp table for current group');
          fnd_file.put_line(FND_FILE.LOG, 'current record Operator is  ' || g_comparison_opr_code_c_tbl(i));
        end if;
        */

        -- if grp_no -1 record is getting updated then update the other grps records for pattern string,
        -- hash key, effctive dates of qualifiers, effective precedence
        if l_current_grp = -1 then
          other_grp_index := g_qual_grouping_no_tmp_tbl.first;
          while other_grp_index is not null
          LOOP
            /*
            if g_call_from_setup = 'Y' then
              oe_debug_pub.add('other_grp_index = ' || other_grp_index);
            else
              fnd_file.put_line(FND_FILE.LOG, 'other_grp_index = ' || other_grp_index);
            end if;
            */
            -- do not update the -1 grp no record as -1 grp no record will be updated automatically
            -- outside this loop
            if other_grp_index = -1 then
               null;
            else
              if (g_start_date_active_q_c_tbl(i) is not null
                  and g_start_date_active_q_tmp_tbl(other_grp_index) is not null
                  and g_start_date_active_q_c_tbl(i) > g_start_date_active_q_tmp_tbl(other_grp_index)) then
                g_start_date_active_q_tmp_tbl(other_grp_index) := g_start_date_active_q_c_tbl(i);
              elsif (g_start_date_active_q_tmp_tbl(other_grp_index) is null
                     and g_start_date_active_q_c_tbl(i) is not null) then
                g_start_date_active_q_tmp_tbl(other_grp_index) := g_start_date_active_q_c_tbl(i);
              end if;

              if (g_end_date_active_q_c_tbl(i) is not null
                  and g_end_date_active_q_tmp_tbl(other_grp_index) is not null
                  and g_end_date_active_q_c_tbl(i) < g_end_date_active_q_tmp_tbl(other_grp_index)) then
                g_end_date_active_q_tmp_tbl(other_grp_index) := g_end_date_active_q_c_tbl(i);
              elsif (g_end_date_active_q_tmp_tbl(other_grp_index) is null
                     and g_end_date_active_q_c_tbl(i) is not null) then
                g_end_date_active_q_tmp_tbl(other_grp_index) := g_end_date_active_q_c_tbl(i);
              end if;

              g_limit_exists_tmp_tbl(other_grp_index) := nvl(g_limit_exists_c_tbl(i), 'N');

              if g_effective_precedence_c_tbl(i) < g_effective_precedence_tmp_tbl(other_grp_index) then
                g_effective_precedence_tmp_tbl(other_grp_index) := g_effective_precedence_c_tbl(i);
              end if;

              if g_comparison_opr_code_c_tbl(i) = '=' then
                if g_pat_string_tmp_tbl(other_grp_index) is not null then
                  g_pat_string_tmp_tbl(other_grp_index) := g_pat_string_tmp_tbl(other_grp_index) || g_delimiter || g_segment_id_c_tbl(i);
                else
                  g_pat_string_tmp_tbl(other_grp_index) := g_segment_id_c_tbl(i);
                end if;

                if g_hash_key_tmp_tbl(other_grp_index) is not null then
                  g_hash_key_tmp_tbl(other_grp_index) := g_hash_key_tmp_tbl(other_grp_index) || g_delimiter || g_qual_attr_val_c_tbl(i);
                else
                  g_hash_key_tmp_tbl(other_grp_index) := g_qual_attr_val_c_tbl(i);
                end if;

                if g_attribute_type_c_tbl(i) = 'PROD' then
                  g_cache_key_tmp_tbl(other_grp_index) := g_list_header_id_c_tbl(i) || g_delimiter || g_segment_id_c_tbl(i) || g_delimiter || g_qual_attr_val_c_tbl(i);
                end if;
              end if; -- g_comparison_opr_code_c_tbl(i) = '='

            end if; -- other_grp_index = -1

            other_grp_index := g_qual_grouping_no_tmp_tbl.next(other_grp_index);
          END LOOP; -- other_grp_index is not null

        end if; -- l_current_grp = -1

        if (g_start_date_active_q_c_tbl(i) is not null
            and g_start_date_active_q_tmp_tbl(l_current_grp) is not null
            and g_start_date_active_q_c_tbl(i) > g_start_date_active_q_tmp_tbl(l_current_grp)) then
          g_start_date_active_q_tmp_tbl(l_current_grp) := g_start_date_active_q_c_tbl(i);
        elsif (g_start_date_active_q_tmp_tbl(l_current_grp) is null
               and g_start_date_active_q_c_tbl(i) is not null) then
          g_start_date_active_q_tmp_tbl(l_current_grp) := g_start_date_active_q_c_tbl(i);
        end if;

        if (g_end_date_active_q_c_tbl(i) is not null
            and g_end_date_active_q_tmp_tbl(l_current_grp) is not null
            and g_end_date_active_q_c_tbl(i) < g_end_date_active_q_tmp_tbl(l_current_grp)) then
          g_end_date_active_q_tmp_tbl(l_current_grp) := g_end_date_active_q_c_tbl(i);
        elsif (g_end_date_active_q_tmp_tbl(l_current_grp) is null
               and g_end_date_active_q_c_tbl(i) is not null) then
          g_end_date_active_q_tmp_tbl(l_current_grp) := g_end_date_active_q_c_tbl(i);
        end if;

        g_limit_exists_tmp_tbl(l_current_grp) := nvl(g_limit_exists_c_tbl(i), 'N');

        if g_effective_precedence_c_tbl(i) < g_effective_precedence_tmp_tbl(l_current_grp) then
          g_effective_precedence_tmp_tbl(l_current_grp) := g_effective_precedence_c_tbl(i);
        end if;

        if g_comparison_opr_code_c_tbl(i) = '=' then
          if g_pat_string_tmp_tbl(l_current_grp) is not null then
            g_pat_string_tmp_tbl(l_current_grp) := g_pat_string_tmp_tbl(l_current_grp) || g_delimiter || g_segment_id_c_tbl(i);
          else
            g_pat_string_tmp_tbl(l_current_grp) := g_segment_id_c_tbl(i);
          end if;

          if g_hash_key_tmp_tbl(l_current_grp) is not null then
            g_hash_key_tmp_tbl(l_current_grp) := g_hash_key_tmp_tbl(l_current_grp) || g_delimiter || g_qual_attr_val_c_tbl(i);
          else
            g_hash_key_tmp_tbl(l_current_grp) := g_qual_attr_val_c_tbl(i);
          end if;

          if g_attribute_type_c_tbl(i) = 'PROD' then
            g_cache_key_tmp_tbl(l_current_grp) := g_list_header_id_c_tbl(i) || g_delimiter || g_segment_id_c_tbl(i) || g_delimiter || g_qual_attr_val_c_tbl(i);
          end if;

          -- populate the pattern temp table
          l_pat_tmp_index := g_pattern_grouping_no_tmp_tbl.count;

          g_pattern_grouping_no_tmp_tbl(l_pat_tmp_index + 1) := g_qual_grouping_no_c_tbl(i);
          g_pattern_segment_id_tmp_tbl(l_pat_tmp_index + 1) := g_segment_id_c_tbl(i);
        end if; -- g_comparison_opr_code_c_tbl(i) = '='

      else -- record does not exists for the group
        /*
        if g_call_from_setup = 'Y' then
          oe_debug_pub.add('record DOES NOT exists in temp table for current group');
          oe_debug_pub.add('current record Operator is  ' || g_comparison_opr_code_c_tbl(i));
        else
          fnd_file.put_line(FND_FILE.LOG, 'record DOES NOT exists in temp table for current group');
          fnd_file.put_line(FND_FILE.LOG, 'current record Operator is  ' || g_comparison_opr_code_c_tbl(i));
        end if;
        */

        l_prefix_value_from_null_grp := 'N';
        -- if grp_no -1 record is getting created then update the other grps records for pattern string,
        -- hash key, effctive dates of qualifiers, effective precedence
        if l_current_grp = -1 then
          other_grp_index := g_qual_grouping_no_tmp_tbl.first;
          while other_grp_index is not null
          LOOP
            /*
            if g_call_from_setup = 'Y' then
              oe_debug_pub.add('other_grp_index = ' || other_grp_index);
            else
              fnd_file.put_line(FND_FILE.LOG, 'other_grp_index = ' || other_grp_index);
            end if;
            */

            if (g_start_date_active_q_c_tbl(i) is not null
               and g_start_date_active_q_tmp_tbl(other_grp_index) is not null
               and g_start_date_active_q_c_tbl(i) > g_start_date_active_q_tmp_tbl(other_grp_index)) then
             g_start_date_active_q_tmp_tbl(other_grp_index) := g_start_date_active_q_c_tbl(i);
           elsif (g_start_date_active_q_tmp_tbl(other_grp_index) is null
                  and g_start_date_active_q_c_tbl(i) is not null) then
             g_start_date_active_q_tmp_tbl(other_grp_index) := g_start_date_active_q_c_tbl(i);
           end if;

           if (g_end_date_active_q_c_tbl(i) is not null
               and g_end_date_active_q_tmp_tbl(other_grp_index) is not null
               and g_end_date_active_q_c_tbl(i) < g_end_date_active_q_tmp_tbl(other_grp_index)) then
             g_end_date_active_q_tmp_tbl(other_grp_index) := g_end_date_active_q_c_tbl(i);
           elsif (g_end_date_active_q_tmp_tbl(other_grp_index) is null
                  and g_end_date_active_q_c_tbl(i) is not null) then
             g_end_date_active_q_tmp_tbl(other_grp_index) := g_end_date_active_q_c_tbl(i);
           end if;

           g_limit_exists_tmp_tbl(other_grp_index) := nvl(g_limit_exists_c_tbl(i), 'N');

           if g_effective_precedence_c_tbl(i) < g_effective_precedence_tmp_tbl(other_grp_index) then
             g_effective_precedence_tmp_tbl(other_grp_index) := g_effective_precedence_c_tbl(i);
           end if;

           if g_comparison_opr_code_c_tbl(i) = '=' then
             if g_pat_string_tmp_tbl(other_grp_index) is not null then
               g_pat_string_tmp_tbl(other_grp_index) := g_pat_string_tmp_tbl(other_grp_index) || g_delimiter || g_segment_id_c_tbl(i);
             else
               g_pat_string_tmp_tbl(other_grp_index) := g_segment_id_c_tbl(i);
             end if;

             if g_hash_key_tmp_tbl(other_grp_index) is not null then
               g_hash_key_tmp_tbl(other_grp_index) := g_hash_key_tmp_tbl(other_grp_index) || g_delimiter || g_qual_attr_val_c_tbl(i);
             else
               g_hash_key_tmp_tbl(other_grp_index) := g_qual_attr_val_c_tbl(i);
             end if;

             if g_attribute_type_c_tbl(i) = 'PROD' then
               g_cache_key_tmp_tbl(other_grp_index) := g_list_header_id_c_tbl(i) || g_delimiter || g_segment_id_c_tbl(i) || g_delimiter || g_qual_attr_val_c_tbl(i);
             end if;
           end if; -- g_comparison_opr_code_c_tbl(i) = '='

            other_grp_index := g_qual_grouping_no_tmp_tbl.next(other_grp_index);
          END LOOP; -- other_grp_index is not null
        else
          -- if l_current_grp is not -1 then look for existence of -1 grp no record, if exists then
          -- use it for populating pattern string, hash key, cache key, qualifier dates, precedence etc.
          if g_qual_grouping_no_tmp_tbl.exists(-1) = TRUE then
             l_prefix_value_from_null_grp := 'Y';
          end if;
        end if; -- l_current_grp = -1

        g_list_header_id_tmp_tbl(l_current_grp) := g_list_header_id_c_tbl(i);
        g_list_line_id_tmp_tbl(l_current_grp) := g_list_line_id_c_tbl(i);
        g_active_flag_tmp_tbl(l_current_grp) := g_active_flag_c_tbl(i);
        g_list_type_code_tmp_tbl(l_current_grp) := g_list_type_code_c_tbl(i);
        if l_prefix_value_from_null_grp = 'Y' then
          if (g_start_date_active_q_c_tbl(i) is not null
              and g_start_date_active_q_tmp_tbl(-1) is not null) then
            if g_start_date_active_q_c_tbl(i) > g_start_date_active_q_tmp_tbl(-1) then
              g_start_date_active_q_tmp_tbl(l_current_grp) := g_start_date_active_q_c_tbl(i);
            else
              g_start_date_active_q_tmp_tbl(l_current_grp) := g_start_date_active_q_tmp_tbl(-1);
            end if;
          elsif (g_start_date_active_q_tmp_tbl(-1) is null
                 and g_start_date_active_q_c_tbl(i) is not null) then
            g_start_date_active_q_tmp_tbl(l_current_grp) := g_start_date_active_q_c_tbl(i);
          elsif (g_start_date_active_q_tmp_tbl(-1) is not null
                 and g_start_date_active_q_c_tbl(i) is null) then
            g_start_date_active_q_tmp_tbl(l_current_grp) := g_start_date_active_q_tmp_tbl(-1);
          else
            g_start_date_active_q_tmp_tbl(l_current_grp) := null;
          end if;

          if (g_end_date_active_q_c_tbl(i) is not null
              and g_end_date_active_q_tmp_tbl(-1) is not null) then
            if g_end_date_active_q_c_tbl(i) < g_end_date_active_q_tmp_tbl(-1) then
              g_end_date_active_q_tmp_tbl(l_current_grp) := g_end_date_active_q_c_tbl(i);
            else
              g_end_date_active_q_tmp_tbl(l_current_grp) := g_end_date_active_q_tmp_tbl(-1);
            end if;
          elsif (g_end_date_active_q_tmp_tbl(-1) is null
                 and g_end_date_active_q_c_tbl(i) is not null) then
            g_end_date_active_q_tmp_tbl(l_current_grp) := g_end_date_active_q_c_tbl(i);
          elsif (g_end_date_active_q_tmp_tbl(-1) is not null
                 and g_end_date_active_q_c_tbl(i) is null) then
            g_end_date_active_q_tmp_tbl(l_current_grp) := g_end_date_active_q_tmp_tbl(-1);
          else
            g_end_date_active_q_tmp_tbl(l_current_grp) := null;
          end if;

          if g_effective_precedence_tmp_tbl(-1) < g_effective_precedence_c_tbl(i) then
            g_effective_precedence_tmp_tbl(l_current_grp) := g_effective_precedence_tmp_tbl(-1);
          else
            g_effective_precedence_tmp_tbl(l_current_grp) := g_effective_precedence_c_tbl(i);
          end if;
        else
          g_start_date_active_q_tmp_tbl(l_current_grp) := g_start_date_active_q_c_tbl(i);
          g_end_date_active_q_tmp_tbl(l_current_grp) := g_end_date_active_q_c_tbl(i);
          g_effective_precedence_tmp_tbl(l_current_grp) := g_effective_precedence_c_tbl(i);
        end if; -- l_prefix_value_from_null_grp = 'Y'
        g_currency_code_tmp_tbl(l_current_grp) := g_currency_code_c_tbl(i);
        g_ask_for_flag_tmp_tbl(l_current_grp) := g_ask_for_flag_c_tbl(i);
        g_limit_exists_tmp_tbl(l_current_grp) := nvl(g_limit_exists_c_tbl(i), 'N');
        g_source_system_code_tmp_tbl(l_current_grp) := g_source_system_code_c_tbl(i);
        g_qual_grouping_no_tmp_tbl(l_current_grp) := g_qual_grouping_no_c_tbl(i);
        g_pricing_phase_id_tmp_tbl(l_current_grp) := g_pricing_phase_id_c_tbl(i);
        g_modifier_level_code_tmp_tbl(l_current_grp) := g_modifier_level_code_c_tbl(i);
        g_product_uom_code_tmp_tbl(l_current_grp) := null;
        g_pricing_attr_count_tmp_tbl(l_current_grp) := null;

        if g_comparison_opr_code_c_tbl(i) = '=' then
          if l_prefix_value_from_null_grp = 'Y' then
            if g_pat_string_tmp_tbl(-1) is not null then
              g_pat_string_tmp_tbl(l_current_grp) := g_pat_string_tmp_tbl(-1) || g_delimiter || g_segment_id_c_tbl(i);
            else
              g_pat_string_tmp_tbl(l_current_grp) := g_segment_id_c_tbl(i);
            end if;

            if g_hash_key_tmp_tbl(-1) is not null then
              g_hash_key_tmp_tbl(l_current_grp) :=  g_hash_key_tmp_tbl(-1) || g_delimiter || g_qual_attr_val_c_tbl(i);
            else
              g_hash_key_tmp_tbl(l_current_grp) := g_qual_attr_val_c_tbl(i);
            end if;

            if g_attribute_type_c_tbl(i) = 'PROD' then
              g_cache_key_tmp_tbl(l_current_grp) := g_list_header_id_c_tbl(i) || g_delimiter || g_segment_id_c_tbl(i) || g_delimiter || g_qual_attr_val_c_tbl(i);
            elsif g_cache_key_tmp_tbl(-1) is not null then
              g_cache_key_tmp_tbl(l_current_grp) := g_cache_key_tmp_tbl(-1);
            else
              g_cache_key_tmp_tbl(l_current_grp) := null;
            end if;
          else
            g_pat_string_tmp_tbl(l_current_grp) := g_segment_id_c_tbl(i);
            g_hash_key_tmp_tbl(l_current_grp) := g_qual_attr_val_c_tbl(i);

            if g_attribute_type_c_tbl(i) = 'PROD' then
              g_cache_key_tmp_tbl(l_current_grp) := g_list_header_id_c_tbl(i) || g_delimiter || g_segment_id_c_tbl(i) || g_delimiter || g_qual_attr_val_c_tbl(i);
            else
              g_cache_key_tmp_tbl(l_current_grp) := null;
            end if;
          end if; -- l_prefix_value_from_null_grp = 'Y'

          -- populate the pattern temp table
          l_pat_tmp_index := g_pattern_grouping_no_tmp_tbl.count;

          g_pattern_grouping_no_tmp_tbl(l_pat_tmp_index + 1) := g_qual_grouping_no_c_tbl(i);
          g_pattern_segment_id_tmp_tbl(l_pat_tmp_index + 1) := g_segment_id_c_tbl(i);
        else -- operator other than =
          if l_prefix_value_from_null_grp = 'Y' then
            if g_pat_string_tmp_tbl(-1) is not null then
              g_pat_string_tmp_tbl(l_current_grp) := g_pat_string_tmp_tbl(-1);
            else
              g_pat_string_tmp_tbl(l_current_grp) := null;
            end if;

            if g_hash_key_tmp_tbl(-1) is not null then
              g_hash_key_tmp_tbl(l_current_grp) := g_hash_key_tmp_tbl(-1);
            else
              g_hash_key_tmp_tbl(l_current_grp) := null;
            end if;

            if g_cache_key_tmp_tbl(-1) is not null then
              g_cache_key_tmp_tbl(l_current_grp) := g_cache_key_tmp_tbl(-1);
            else
              g_cache_key_tmp_tbl(l_current_grp) := null;
            end if;
          else
            g_pat_string_tmp_tbl(l_current_grp) := null;
            g_hash_key_tmp_tbl(l_current_grp) := null;
            g_cache_key_tmp_tbl(l_current_grp) := null;
          end if; -- l_prefix_value_from_null_grp = 'Y'
        end if; -- g_comparison_opr_code_c_tbl(i) = '='

      end if; -- g_qual_grouping_no_tmp_tbl.exists(l_current_grp)
      -- store the header and line id
      l_old_list_header_id := g_list_header_id_c_tbl(i);
      l_old_list_line_id := g_list_line_id_c_tbl(i);
    end loop; -- i in 1..g_list_header_id_c_tbl.count

  end if; -- g_list_header_id_c_tbl.count > 0

  -- move data for last pair of header and line id
  Move_data_from_tmp_to_final(p_pattern_type);

  -- insert into qp_attribute_groups from final tables
  populate_atgrps;

  -- for line pattern, qp_list_lines.cache_key need to be populated as well
  if p_pattern_type = 'LP' then
    update_list_lines_cache_key;
  end if;

EXCEPTION
  WHEN OTHERS THEN
    if g_call_from_setup = 'Y' then
      oe_debug_pub.add('ATTR_GRP_PVT.Process_C_Tables ' || SQLERRM);
    else
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'ATTR_GRP_PVT.Process_C_Tables ' || SQLERRM );
    end if;

end process_c_tables;

procedure process_c_tables_pp(p_pattern_type  VARCHAR2)
is
  l_old_list_header_id            number;
  l_old_list_line_id              number;
  l_pat_tmp_index number;
  l_first_pa_rec_for_line         varchar2(1);
  l_debug               VARCHAR2(3);
  l_line_counter        number := 0;

begin
  l_old_list_header_id := g_init_val;
  l_old_list_line_id := g_init_val;

  if g_call_from_setup = 'Y' then
    oe_debug_pub.add('PP cursor tables total = ' || g_list_header_id_c_tbl.count);
  else
    QP_PREQ_GRP.Set_QP_Debug;
    l_debug := QP_PREQ_GRP.G_DEBUG_ENGINE;
    IF l_debug = FND_API.G_TRUE THEN
      fnd_file.put_line(FND_FILE.LOG, 'PP cursor tables total = ' || g_list_header_id_c_tbl.count);
    END IF;
  end if;

  l_first_pa_rec_for_line := 'Y';

  if g_list_header_id_c_tbl.count > 0 then
    for i in 1..g_list_header_id_c_tbl.count
    loop
      if g_call_from_setup = 'Y' then
        oe_debug_pub.add('PP i = ' || i ||
                         ', list_header_id = ' || g_list_header_id_c_tbl(i) ||
                         ', list_line_id = ' || g_list_line_id_c_tbl(i) ||
                         ', operator = ' || g_comparison_opr_code_c_tbl(i));
        --oe_debug_pub.add('PP l_old_list_header_id ' || l_old_list_header_id);
        --oe_debug_pub.add('PP l_old_list_line_id ' || l_old_list_line_id);
      elsif l_debug = FND_API.G_TRUE then
        fnd_file.put_line(FND_FILE.LOG, 'PP i = ' || i ||
                         ', list_header_id = ' || g_list_header_id_c_tbl(i) ||
                         ', list_line_id = ' || g_list_line_id_c_tbl(i) ||
                         ', operator = ' || g_comparison_opr_code_c_tbl(i));
        --fnd_file.put_line(FND_FILE.LOG, 'PP l_old_list_header_id ' || l_old_list_header_id);
        --fnd_file.put_line(FND_FILE.LOG, 'PP l_old_list_line_id ' || l_old_list_line_id);
      end if;

      if (i > 1
          and (g_list_header_id_c_tbl(i) <> l_old_list_header_id
               or g_list_line_id_c_tbl(i) <> l_old_list_line_id)
         ) then
        Move_data_from_tmp_to_final(p_pattern_type);
        Reset_tmp_tables;
        l_first_pa_rec_for_line := 'Y';

        -- logic to insert into tables every G_LINES_PER_INSERT lines
        l_line_counter := l_line_counter + 1;
        if l_line_counter >= G_LINES_PER_INSERT then
          if g_call_from_setup = 'Y' then
            oe_debug_pub.add('inserting data for ' || G_LINES_PER_INSERT || ' lines');
          elsif l_debug = FND_API.G_TRUE then
            fnd_file.put_line(FND_FILE.LOG, 'inserting data for ' || G_LINES_PER_INSERT || ' lines');
          end if;
          update_list_lines;
          reset_final_tables;
          if g_call_from_setup <> 'Y' then
            if l_debug = FND_API.G_TRUE then
              fnd_file.put_line(FND_FILE.LOG, 'committing data for ' || G_LINES_PER_INSERT || ' lines');
            end if;
            commit;
          end if;
          l_line_counter := 0;
        end if;
      end if;

      if l_first_pa_rec_for_line = 'Y' then
        g_list_header_id_tmp_tbl(-1) := g_list_header_id_c_tbl(i);
        g_list_line_id_tmp_tbl(-1) := g_list_line_id_c_tbl(i);
        g_product_uom_code_tmp_tbl(-1) := g_product_uom_code_c_tbl(i);

        g_active_flag_tmp_tbl(-1) := null;
        g_list_type_code_tmp_tbl(-1) := null;
        g_currency_code_tmp_tbl(-1) := null;
        g_ask_for_flag_tmp_tbl(-1) := null;
        g_limit_exists_tmp_tbl(-1) := null;
        g_source_system_code_tmp_tbl(-1) := null;
        g_qual_grouping_no_tmp_tbl(-1) := -1;
        g_pricing_phase_id_tmp_tbl(-1) := g_pricing_phase_id_c_tbl(i);
        g_modifier_level_code_tmp_tbl(-1) := null;
        g_start_date_active_q_tmp_tbl(-1) := null;
        g_end_date_active_q_tmp_tbl(-1) := null;
        g_effective_precedence_tmp_tbl(-1) := null;

        if g_attribute_type_c_tbl(i) = 'PRIC' then
          g_pricing_attr_count_tmp_tbl(-1) := 1;
        else
          g_pricing_attr_count_tmp_tbl(-1) := 0;
        end if;

        if g_comparison_opr_code_c_tbl(i) = '=' then
          g_pat_string_tmp_tbl(-1) := g_segment_id_c_tbl(i);
          g_hash_key_tmp_tbl(-1) := g_qual_attr_val_c_tbl(i);

          if g_attribute_type_c_tbl(i) = 'PROD' then
            g_cache_key_tmp_tbl(-1) := g_list_header_id_c_tbl(i) || g_delimiter || g_segment_id_c_tbl(i) || g_delimiter || g_qual_attr_val_c_tbl(i);
          else
            g_cache_key_tmp_tbl(-1) := null;
          end if;

          -- populate the pattern temp table
          l_pat_tmp_index := g_pattern_grouping_no_tmp_tbl.count;

          g_pattern_grouping_no_tmp_tbl(l_pat_tmp_index + 1) := -1;
          g_pattern_segment_id_tmp_tbl(l_pat_tmp_index + 1) := g_segment_id_c_tbl(i);
        else -- operator other than =
          g_pat_string_tmp_tbl(-1) := null;
          g_hash_key_tmp_tbl(-1) := null;
          g_cache_key_tmp_tbl(-1) := null;
        end if; -- g_comparison_opr_code_c_tbl(i) = '='

      else -- not first pa record for a line
        if g_attribute_type_c_tbl(i) = 'PRIC' then
          g_pricing_attr_count_tmp_tbl(-1) := g_pricing_attr_count_tmp_tbl(-1) + 1;
        end if;

        if g_comparison_opr_code_c_tbl(i) = '=' then
          if g_pat_string_tmp_tbl(-1) is not null then
            g_pat_string_tmp_tbl(-1) := g_pat_string_tmp_tbl(-1) || g_delimiter || g_segment_id_c_tbl(i);
          else
            g_pat_string_tmp_tbl(-1) := g_segment_id_c_tbl(i);
          end if;

          if g_hash_key_tmp_tbl(-1) is not null then
            g_hash_key_tmp_tbl(-1) := g_hash_key_tmp_tbl(-1) || g_delimiter || g_qual_attr_val_c_tbl(i);
          else
            g_hash_key_tmp_tbl(-1) := g_qual_attr_val_c_tbl(i);
          end if;

          if g_attribute_type_c_tbl(i) = 'PROD' then
            g_cache_key_tmp_tbl(-1) := g_list_header_id_c_tbl(i) || g_delimiter || g_segment_id_c_tbl(i) || g_delimiter || g_qual_attr_val_c_tbl(i);
          end if;

          -- populate the pattern temp table
          l_pat_tmp_index := g_pattern_grouping_no_tmp_tbl.count;

          g_pattern_grouping_no_tmp_tbl(l_pat_tmp_index + 1) := -1;
          g_pattern_segment_id_tmp_tbl(l_pat_tmp_index + 1) := g_segment_id_c_tbl(i);

        end if; -- g_comparison_opr_code_c_tbl(i) = '='
      end if; -- l_first_pa_rec_for_line = 'Y'


      -- set first record indicator to 'N'
      l_first_pa_rec_for_line := 'N';

      -- store the header and line id
      l_old_list_header_id := g_list_header_id_c_tbl(i);
      l_old_list_line_id := g_list_line_id_c_tbl(i);
    end loop; -- i in 1..g_list_header_id_c_tbl.count

  end if; -- g_list_header_id_c_tbl.count > 0

  -- move data for last pair of header and line id
  Move_data_from_tmp_to_final(p_pattern_type);

  -- update qp_list_lines from final tables
  update_list_lines;

EXCEPTION
  WHEN OTHERS THEN
    if g_call_from_setup = 'Y' then
      oe_debug_pub.add('ATTR_GRP_PVT.Process_C_Tables_Pp ' || SQLERRM);
    else
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'ATTR_GRP_PVT.Process_C_Tables_Pp ' || SQLERRM );
    end if;

end process_c_tables_pp;

PROCEDURE Move_data_from_tmp_to_final(p_pattern_type VARCHAR2)
is
  l_other_grp_exists varchar2(1);
  l_pattern_id number;
  l_atgrp_final_index number;
  grp_no_index  number;
  l_product_precedence number;
BEGIN
  /*
  if g_call_from_setup = 'Y' then
    oe_debug_pub.add('Moving data from temp table to final table');
    oe_debug_pub.add('temp tables total = ' || g_list_header_id_tmp_tbl.count);
  else
    fnd_file.put_line(FND_FILE.LOG, 'Moving data from temp table to final table');
    fnd_file.put_line(FND_FILE.LOG, 'temp tables total = ' || g_list_header_id_tmp_tbl.count);
  end if;
  */

  -- find out whether any qual groups exists other than -1
  l_other_grp_exists := 'N';
  if g_list_header_id_tmp_tbl.count > 1 and g_list_header_id_tmp_tbl.exists(-1) = TRUE then
     l_other_grp_exists := 'Y';
  end if; -- g_list_header_id_tmp_tbl.count > 1

  /*
  if g_call_from_setup = 'Y' then
    oe_debug_pub.add('l_other_grp_exists = ' || l_other_grp_exists);
  else
    fnd_file.put_line(FND_FILE.LOG, 'l_other_grp_exists = ' || l_other_grp_exists);
  end if;
  */

  -- now loop thru the atgrp temp tables and move to the final atgrp tables
  grp_no_index := g_qual_grouping_no_tmp_tbl.first;
  while grp_no_index is not null
  LOOP
    /*
    if g_call_from_setup = 'Y' then
      oe_debug_pub.add('grouping no = ' || grp_no_index);
    else
      fnd_file.put_line(FND_FILE.LOG, 'grouping no = ' || grp_no_index);
    end if;
    */
    -- if other groups exists then skip -1 record i.e. do not move temp table data to final table
    if l_other_grp_exists = 'Y' and grp_no_index = -1 then
      null;
    else
      if g_pat_string_tmp_tbl(grp_no_index) is not null then
        l_pattern_id := get_pattern_id(p_pattern_type, g_pat_string_tmp_tbl(grp_no_index),
                                       grp_no_index);
      else
        l_pattern_id := -1;
      end if;
    /*
    if g_call_from_setup = 'Y' then
      oe_debug_pub.add('Pattern_id='||l_pattern_id);
    else
      fnd_file.put_line(FND_FILE.LOG, 'Pattern_id='||l_pattern_id);
    end if;
    */

      -- maintain data in qp_pattern_phases
      if p_pattern_type in ('LP', 'PP') then
        Populate_Pattern_Phases(null, g_pricing_phase_id_tmp_tbl(grp_no_index), l_pattern_id);
      elsif p_pattern_type = 'HP' then
        Populate_Pattern_Phases(g_list_header_id_tmp_tbl(grp_no_index), null, l_pattern_id);
      end if;

      -- move the data from tmp tables to final tables for qp_attribute_groups
      /*
      if g_call_from_setup = 'Y' then
        oe_debug_pub.add('move the data from tmp tables to final tables for qp_attribute_groups');
      else
        fnd_file.put_line(FND_FILE.LOG, 'move the data from tmp tables to final tables for qp_attribute_groups');
      end if;
      */

      l_atgrp_final_index := g_list_header_id_final_tbl.count + 1;

      g_list_header_id_final_tbl(l_atgrp_final_index) := g_list_header_id_tmp_tbl(grp_no_index);
      g_list_line_id_final_tbl(l_atgrp_final_index) := g_list_line_id_tmp_tbl(grp_no_index);
      g_active_flag_final_tbl(l_atgrp_final_index) := g_active_flag_tmp_tbl(grp_no_index);
      g_list_type_code_final_tbl(l_atgrp_final_index) := g_list_type_code_tmp_tbl(grp_no_index);
      g_st_date_active_q_final_tbl(l_atgrp_final_index) := g_start_date_active_q_tmp_tbl(grp_no_index);
      g_end_date_active_q_final_tbl(l_atgrp_final_index) := g_end_date_active_q_tmp_tbl(grp_no_index);
      g_pattern_id_final_tbl(l_atgrp_final_index) := l_pattern_id;
      g_currency_code_final_tbl(l_atgrp_final_index) := g_currency_code_tmp_tbl(grp_no_index);
      g_ask_for_flag_final_tbl(l_atgrp_final_index) := g_ask_for_flag_tmp_tbl(grp_no_index);
      g_limit_exists_final_tbl(l_atgrp_final_index) := g_limit_exists_tmp_tbl(grp_no_index);
      g_source_system_code_final_tbl(l_atgrp_final_index) := g_source_system_code_tmp_tbl(grp_no_index);
      g_effec_precedence_final_tbl(l_atgrp_final_index) := g_effective_precedence_tmp_tbl(grp_no_index);
      g_qual_grouping_no_final_tbl(l_atgrp_final_index) := g_qual_grouping_no_tmp_tbl(grp_no_index);
      g_pricing_phase_id_final_tbl(l_atgrp_final_index) := g_pricing_phase_id_tmp_tbl(grp_no_index);
      g_modifier_lvl_code_final_tbl(l_atgrp_final_index) := g_modifier_level_code_tmp_tbl(grp_no_index);
      g_hash_key_final_tbl(l_atgrp_final_index) := g_hash_key_tmp_tbl(grp_no_index);
      -- if there is no product attached to a line then cache_key should contain only list_header_id
      if g_cache_key_tmp_tbl(grp_no_index) is null and p_pattern_type in ('LP', 'PP') then
        g_cache_key_final_tbl(l_atgrp_final_index) := g_list_header_id_tmp_tbl(grp_no_index);

        -- bug 3703391 - if product not given, even then consider product precedence to decide effective precedence
        select product_precedence into l_product_precedence
          from qp_list_lines where list_line_id = g_list_line_id_final_tbl(l_atgrp_final_index);

        if (l_product_precedence is not null) and (g_effec_precedence_final_tbl(l_atgrp_final_index) is not null)
           and (l_product_precedence < g_effec_precedence_final_tbl(l_atgrp_final_index)) then
             g_effec_precedence_final_tbl(l_atgrp_final_index) := l_product_precedence;
        end if;
        /*
        if g_call_from_setup = 'Y' then
          oe_debug_pub.add('cache_key should be just list_header_id ');
        else
          fnd_file.put_line(FND_FILE.LOG, 'cache_key should be just list_header_id ');
        end if;
        */
      else
        g_cache_key_final_tbl(l_atgrp_final_index) := g_cache_key_tmp_tbl(grp_no_index);
        /*
        if g_call_from_setup = 'Y' then
          oe_debug_pub.add('cache_key should be standard OR null');
        else
          fnd_file.put_line(FND_FILE.LOG, 'cache_key should be standard OR null');
        end if;
        */
      end if;

      g_product_uom_code_final_tbl(l_atgrp_final_index) := g_product_uom_code_tmp_tbl(grp_no_index);
      g_pricing_attr_count_final_tbl(l_atgrp_final_index) := g_pricing_attr_count_tmp_tbl(grp_no_index);

      -- populate the standard who columns
      g_creation_date_final_tbl(l_atgrp_final_index) := sysdate;
      g_created_by_final_tbl(l_atgrp_final_index) := FND_GLOBAL.USER_ID;
      g_last_update_date_final_tbl(l_atgrp_final_index) := sysdate;
      g_last_updated_by_final_tbl(l_atgrp_final_index) := FND_GLOBAL.USER_ID;
      g_last_update_login_final_tbl(l_atgrp_final_index) := FND_GLOBAL.LOGIN_ID;
      g_program_appl_id_final_tbl(l_atgrp_final_index) := FND_GLOBAL.PROG_APPL_ID;
      g_program_id_final_tbl(l_atgrp_final_index) := FND_GLOBAL.CONC_PROGRAM_ID;
      g_program_upd_date_final_tbl(l_atgrp_final_index) := sysdate;
      g_request_id_final_tbl(l_atgrp_final_index) := FND_GLOBAL.CONC_REQUEST_ID;

    end if; -- l_other_grp_exists = 'Y' and grp_no_index = -1

    grp_no_index := g_qual_grouping_no_tmp_tbl.next(grp_no_index);

  END LOOP; -- while
  /*
  if g_call_from_setup = 'Y' then
    oe_debug_pub.add('End Moving data from temp table to final table');
  else
    fnd_file.put_line(FND_FILE.LOG, 'End Moving data from temp table to final table');
  end if;
  */

EXCEPTION
  WHEN OTHERS THEN
    if g_call_from_setup = 'Y' then
      oe_debug_pub.add('ATTR_GRP_PVT.Move_Data_From_Tmp_To_Final ' || SQLERRM);
    else
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'ATTR_GRP_PVT.Move_Data_From_Tmp_To_Final ' || SQLERRM );
    end if;

END Move_data_from_tmp_to_final;

-- bulk insert patterns into qp_patterns table
PROCEDURE Populate_Patterns
is
BEGIN

  /*
  if g_call_from_setup = 'Y' then
      oe_debug_pub.add('Begin Populate_patterns');
  else
      fnd_file.put_line(FND_FILE.LOG, 'Begin Populate_patterns');
  end if;
  */

 FORALL i in 1 .. G_pattern_pattern_id_final_tbl.count
  INSERT INTO qp_patterns
  (
  pattern_id,
  segment_id,
  pattern_type,
  pattern_string,
  creation_date,
  created_by,
  last_update_date,
  last_updated_by,
  last_update_login,
  program_application_id,
  program_id,
  program_update_date,
  request_id
  )
  VALUES
  (
  g_pattern_pattern_id_final_tbl(i),
  g_pattern_segment_id_final_tbl(i),
  g_pattern_pat_type_final_tbl(i),
  g_pattern_pat_string_final_tbl(i),
  g_pattern_cr_dt_final_tbl(i),
  g_pattern_cr_by_final_tbl(i),
  g_pattern_lst_up_dt_final_tbl(i),
  g_pattern_lt_up_by_final_tbl(i),
  g_pattern_lt_up_lg_final_tbl(i),
  g_pattern_pr_ap_id_final_tbl(i),
  g_pattern_pr_id_final_tbl(i),
  g_pattern_pr_up_dt_final_tbl(i),
  g_pattern_req_id_final_tbl(i)
  );

  g_pattern_pattern_id_final_tbl.delete;
  g_pattern_segment_id_final_tbl.delete;
  g_pattern_pat_type_final_tbl.delete;
  g_pattern_pat_string_final_tbl.delete;
  g_pattern_cr_dt_final_tbl.delete;
  g_pattern_cr_by_final_tbl.delete;
  g_pattern_lst_up_dt_final_tbl.delete;
  g_pattern_lt_up_by_final_tbl.delete;
  g_pattern_lt_up_lg_final_tbl.delete;
  g_pattern_pr_ap_id_final_tbl.delete;
  g_pattern_pr_id_final_tbl.delete;
  g_pattern_pr_up_dt_final_tbl.delete;
  g_pattern_req_id_final_tbl.delete;

  /*
  if g_call_from_setup = 'Y' then
      oe_debug_pub.add('End Populate_patterns');
  else
      commit;
      fnd_file.put_line(FND_FILE.LOG, 'End Populate_patterns');
  end if;
  */
EXCEPTION
 WHEN OTHERS THEN
    if g_call_from_setup = 'Y' then
      oe_debug_pub.add('ATTR_GRP_PVT.Populate_Patterns ' || SQLERRM);
    else
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'ATTR_GRP_PVT.Populate_Patterns ' || SQLERRM );
    end if;
   raise;
END Populate_Patterns;

-- bulk update qp_list_lines table
PROCEDURE update_list_lines
is
BEGIN

 FORALL i in 1 .. g_list_line_id_final_tbl.count
  UPDATE /*+ index(lines QP_LIST_LINES_PK) */ qp_list_lines lines
     set pattern_id = g_pattern_id_final_tbl(i),
         product_uom_code = g_product_uom_code_final_tbl(i),
         pricing_attribute_count = g_pricing_attr_count_final_tbl(i),
         hash_key = g_hash_key_final_tbl(i),
         cache_key = g_cache_key_final_tbl(i),
         last_update_date = g_last_update_date_final_tbl(i),
         last_updated_by = g_last_updated_by_final_tbl(i),
         last_update_login = g_last_update_login_final_tbl(i)
   where list_line_id = g_list_line_id_final_tbl(i);

EXCEPTION
  WHEN OTHERS THEN
    if g_call_from_setup = 'Y' then
      oe_debug_pub.add('ATTR_GRP_PVT.Update_List_Lines ' || SQLERRM);
    else
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'ATTR_GRP_PVT.Update_List_Lines ' || SQLERRM );
    end if;

end update_list_lines;

-- bulk update qp_list_lines.cache_key for line patterns
PROCEDURE update_list_lines_cache_key
is
BEGIN

 FORALL i in 1 .. g_list_line_id_final_tbl.count
  UPDATE qp_list_lines
     set cache_key = g_cache_key_final_tbl(i),
         last_update_date = g_last_update_date_final_tbl(i),
         last_updated_by = g_last_updated_by_final_tbl(i),
         last_update_login = g_last_update_login_final_tbl(i)
   where list_line_id = g_list_line_id_final_tbl(i);

EXCEPTION
  WHEN OTHERS THEN
    if g_call_from_setup = 'Y' then
      oe_debug_pub.add('ATTR_GRP_PVT.Update_List_Lines_Cache_Key ' || SQLERRM);
    else
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'ATTR_GRP_PVT.Update_List_Lines_Cache_Key ' || SQLERRM );
    end if;

end update_list_lines_cache_key;

-- bulk insert patterns into qp_patterns table
PROCEDURE Populate_Atgrps
is
BEGIN

 FORALL i in 1 .. g_list_header_id_final_tbl.count
  INSERT INTO qp_attribute_groups
  (list_header_id,
   list_line_id,
   active_flag,
   list_type_code,
   start_date_active_q,
   end_date_active_q,
   pattern_id,
   currency_code,
   ask_for_flag,
   limit_exists,
   source_system_code,
   effective_precedence,
   grouping_no,
   pricing_phase_id,
   modifier_level_code,
   hash_key,
   cache_key,
   creation_date,
   created_by,
   last_update_date,
   last_updated_by,
   last_update_login,
   program_application_id,
   program_id,
   program_update_date,
   request_id
  )
  VALUES
  (g_list_header_id_final_tbl(i),
   g_list_line_id_final_tbl(i),
   g_active_flag_final_tbl(i),
   g_list_type_code_final_tbl(i),
   g_st_date_active_q_final_tbl(i),
   g_end_date_active_q_final_tbl(i),
   g_pattern_id_final_tbl(i),
   g_currency_code_final_tbl(i),
   g_ask_for_flag_final_tbl(i),
   g_limit_exists_final_tbl(i),
   g_source_system_code_final_tbl(i),
   g_effec_precedence_final_tbl(i),
   g_qual_grouping_no_final_tbl(i),
   g_pricing_phase_id_final_tbl(i),
   g_modifier_lvl_code_final_tbl(i),
   g_hash_key_final_tbl(i),
   g_cache_key_final_tbl(i),
   g_creation_date_final_tbl(i),
   g_created_by_final_tbl(i),
   g_last_update_date_final_tbl(i),
   g_last_updated_by_final_tbl(i),
   g_last_update_login_final_tbl(i),
   g_program_appl_id_final_tbl(i),
   g_program_id_final_tbl(i),
   g_program_upd_date_final_tbl(i),
   g_request_id_final_tbl(i)
  );
EXCEPTION
 WHEN OTHERS THEN
    if g_call_from_setup = 'Y' then
      oe_debug_pub.add('ATTR_GRP_PVT.Populate_Atgrps ' || SQLERRM);
    else
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'ATTR_GRP_PVT.Populate_Atgrps ' || SQLERRM );
    end if;
   raise;
END Populate_Atgrps;

Procedure Reset_tmp_tables
is
begin
  /*
  if g_call_from_setup = 'Y' then
    oe_debug_pub.add('Reset temp tables');
  else
    fnd_file.put_line(FND_FILE.LOG, 'Reset temp tables');
  end if;
  */
  g_list_header_id_tmp_tbl.delete;
  g_list_line_id_tmp_tbl.delete;
  g_active_flag_tmp_tbl.delete;
  g_list_type_code_tmp_tbl.delete;
  g_start_date_active_q_tmp_tbl.delete;
  g_end_date_active_q_tmp_tbl.delete;
  g_currency_code_tmp_tbl.delete;
  g_ask_for_flag_tmp_tbl.delete;
  g_limit_exists_tmp_tbl.delete;
  g_source_system_code_tmp_tbl.delete;
  g_effective_precedence_tmp_tbl.delete;
  g_qual_grouping_no_tmp_tbl.delete;
  g_pricing_phase_id_tmp_tbl.delete;
  g_modifier_level_code_tmp_tbl.delete;
  g_hash_key_tmp_tbl.delete;
  g_cache_key_tmp_tbl.delete;
  g_pat_string_tmp_tbl.delete;

  g_pattern_grouping_no_tmp_tbl.delete;
  g_pattern_segment_id_tmp_tbl.delete;

  g_product_uom_code_tmp_tbl.delete;
  g_pricing_attr_count_tmp_tbl.delete;
end Reset_tmp_tables;

function get_pattern_id(p_pattern_type varchar2, p_pat_string varchar2,
                        p_grp_no number)
 return number
is
  l_pattern_to_be_created varchar2(1);
  l_pattern_id number;
  l_pattern_final_index number;
begin
  /*
    if g_call_from_setup = 'Y' then
      oe_debug_pub.add('Begin get_pattern_id');
    else
      fnd_file.put_line(FND_FILE.LOG, 'Begin get_pattern_id');
    end if;
  */
  begin
   l_pattern_to_be_created := 'N';
    select /*+ index(qp_pat QP_PATTERNS_N1) */ pattern_id
      into l_pattern_id
      from qp_patterns qp_pat
     where pattern_string = p_pat_string
       and pattern_type = p_pattern_type
       and rownum = 1;
  exception
    when no_data_found then
       select qp_patterns_s.nextval into l_pattern_id from dual;
       l_pattern_to_be_created := 'Y';

    when others then
      raise;
  end;

  /*
  if g_call_from_setup = 'Y' then
      oe_debug_pub.add('l_pattern_to_be_created='||l_pattern_to_be_created);
  else
      fnd_file.put_line(FND_FILE.LOG, 'l_pattern_to_be_created='||l_pattern_to_be_created);
  end if;
  */

  -- move the data from temp tables to final tables for qp_patterns, if new pattern to be created
  if l_pattern_to_be_created = 'Y' then
    for k in 1..g_pattern_grouping_no_tmp_tbl.count
    loop
      if (g_pattern_grouping_no_tmp_tbl(k) = -1 or g_pattern_grouping_no_tmp_tbl(k) = p_grp_no) then
        l_pattern_final_index := g_pattern_pattern_id_final_tbl.count + 1;

        g_pattern_pattern_id_final_tbl(l_pattern_final_index) := l_pattern_id;
        g_pattern_segment_id_final_tbl(l_pattern_final_index) := g_pattern_segment_id_tmp_tbl(k);
        g_pattern_pat_type_final_tbl(l_pattern_final_index) := p_pattern_type;
        g_pattern_pat_string_final_tbl(l_pattern_final_index) := p_pat_string;

        g_pattern_cr_dt_final_tbl(l_pattern_final_index) := sysdate;
        g_pattern_cr_by_final_tbl(l_pattern_final_index) := FND_GLOBAL.USER_ID;
        g_pattern_lst_up_dt_final_tbl(l_pattern_final_index) := sysdate;
        g_pattern_lt_up_by_final_tbl(l_pattern_final_index) := FND_GLOBAL.USER_ID;
        g_pattern_lt_up_lg_final_tbl(l_pattern_final_index) := FND_GLOBAL.LOGIN_ID;
        g_pattern_pr_ap_id_final_tbl(l_pattern_final_index) := FND_GLOBAL.PROG_APPL_ID;
        g_pattern_pr_id_final_tbl(l_pattern_final_index) := FND_GLOBAL.CONC_PROGRAM_ID;
        g_pattern_pr_up_dt_final_tbl(l_pattern_final_index) := sysdate;
        g_pattern_req_id_final_tbl(l_pattern_final_index) := FND_GLOBAL.CONC_REQUEST_ID;
      end if;
    end loop; --k in 1..g_pattern_grouping_no_tmp_tbl.count
    populate_patterns;
  end if; -- l_pattern_to_be_created = 'Y'
  /*
  if g_call_from_setup = 'Y' then
      oe_debug_pub.add('End get_pattern_id');
  else
      fnd_file.put_line(FND_FILE.LOG, 'End get_pattern_id');
  end if;
  */

  return l_pattern_id;

EXCEPTION
  WHEN OTHERS THEN
    if g_call_from_setup = 'Y' then
      oe_debug_pub.add('ATTR_GRP_PVT.Get_Pattern_Id ' || SQLERRM);
    else
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'ATTR_GRP_PVT.Get_Pattern_Id ' || SQLERRM );
    end if;

end get_pattern_id;

procedure reset_final_tables
is
begin
  g_list_header_id_final_tbl.delete;
  g_list_line_id_final_tbl.delete;
  g_active_flag_final_tbl.delete;
  g_list_type_code_final_tbl.delete;
  g_st_date_active_q_final_tbl.delete;
  g_end_date_active_q_final_tbl.delete;
  g_pattern_id_final_tbl.delete;
  g_currency_code_final_tbl.delete;
  g_ask_for_flag_final_tbl.delete;
  g_limit_exists_final_tbl.delete;
  g_source_system_code_final_tbl.delete;
  g_effec_precedence_final_tbl.delete;
  g_qual_grouping_no_final_tbl.delete;
  g_pricing_phase_id_final_tbl.delete;
  g_modifier_lvl_code_final_tbl.delete;
  g_hash_key_final_tbl.delete;
  g_cache_key_final_tbl.delete;

  g_product_uom_code_final_tbl.delete;
  g_pricing_attr_count_final_tbl.delete;

  g_creation_date_final_tbl.delete;
  g_created_by_final_tbl.delete;
  g_last_update_date_final_tbl.delete;
  g_last_updated_by_final_tbl.delete;
  g_last_update_login_final_tbl.delete;
  g_program_appl_id_final_tbl.delete;
  g_program_id_final_tbl.delete;
  g_program_upd_date_final_tbl.delete;
  g_request_id_final_tbl.delete;

EXCEPTION
  WHEN OTHERS THEN
    if g_call_from_setup = 'Y' then
      oe_debug_pub.add('ATTR_GRP_PVT.Reset_Final_Tables ' || SQLERRM);
    else
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'ATTR_GRP_PVT.Reset_Final_Tables ' || SQLERRM );
    end if;

end reset_final_tables;

procedure reset_c_tables
is
begin
    g_list_header_id_c_tbl.delete;
    g_list_line_id_c_tbl.delete;
    g_segment_id_c_tbl.delete;
    g_active_flag_c_tbl.delete;
    g_list_type_code_c_tbl.delete;
    g_start_date_active_q_c_tbl.delete;
    g_end_date_active_q_c_tbl.delete;
    g_currency_code_c_tbl.delete;
    g_ask_for_flag_c_tbl.delete;
    g_limit_exists_c_tbl.delete;
    g_source_system_code_c_tbl.delete;
    g_effective_precedence_c_tbl.delete;
    g_qual_grouping_no_c_tbl.delete;
    g_comparison_opr_code_c_tbl.delete;
    g_pricing_phase_id_c_tbl.delete;
    g_modifier_level_code_c_tbl.delete;
    g_qual_datatype_c_tbl.delete;
    g_qual_attr_val_c_tbl.delete;
    g_attribute_type_c_tbl.delete;

    g_product_uom_code_c_tbl.delete;

EXCEPTION
  WHEN OTHERS THEN
    if g_call_from_setup = 'Y' then
      oe_debug_pub.add('ATTR_GRP_PVT.Reset_C_Tables ' || SQLERRM);
    else
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'ATTR_GRP_PVT.Reset_C_Tables ' || SQLERRM );
    end if;
end reset_c_tables;

PROCEDURE Populate_Pattern_Phases (
 p_list_header_id                    IN NUMBER,
 p_pricing_phase_id                  IN NUMBER,
 p_pattern_id                        IN NUMBER) IS

 CURSOR l_phase_id_to_insert_csr IS
  SELECT distinct pricing_phase_id, list_header_id
  FROM qp_list_header_phases
  WHERE list_header_id = p_list_header_id;

 l_exists   varchar2(1);

BEGIN

 IF p_list_header_id is not null then
   -- HP case
    /*
    if g_call_from_setup = 'Y' then
      oe_debug_pub.add('Begin Populate_Pattern_Phases for HP case');
    else
      fnd_file.put_line(FND_FILE.LOG, 'Begin Populate_Pattern_Phases for HP case');
    end if;
    */
    FOR j IN l_phase_id_to_insert_csr LOOP
      begin
        select /*+ index(qp_pp QP_PATTERN_PHASES_N1) */ 'Y'
          into l_exists
          from qp_pattern_phases qp_pp
         where pattern_id = p_pattern_id
           and pricing_phase_id = j.pricing_phase_id;
      exception
        when no_data_found then
          INSERT INTO qp_pattern_phases
            (pattern_id,
             pricing_phase_id,
             creation_date,
             created_by,
             last_update_date,
             last_updated_by,
             last_update_login,
             program_application_id,
             program_id,
             program_update_date,
             request_id
            )
          VALUES
            (p_pattern_id,
             j.pricing_phase_id,
             sysdate,
             FND_GLOBAL.USER_ID,
             sysdate,
             FND_GLOBAL.USER_ID,
             FND_GLOBAL.LOGIN_ID,
             FND_GLOBAL.PROG_APPL_ID,
             FND_GLOBAL.CONC_PROGRAM_ID,
             sysdate,
             FND_GLOBAL.CONC_REQUEST_ID
            );

          if g_call_from_setup <> 'Y' then
             commit;
          end if;

        when others then
          raise;
      end;
    END LOOP; --j IN l_phase_id_to_insert_csr
 else
   -- LP, PP case
   /*
    if g_call_from_setup = 'Y' then
      oe_debug_pub.add('Begin Populate_Pattern_Phases for LP, PP case');
    else
      fnd_file.put_line(FND_FILE.LOG, 'Begin Populate_Pattern_Phases for LP, PP case');
    end if;
   */
   begin
     select /*+ index(qp_pp QP_PATTERN_PHASES_N1) */ 'Y'
       into l_exists
       from qp_pattern_phases qp_pp
      where pattern_id = p_pattern_id
        and pricing_phase_id = p_pricing_phase_id
        and rownum = 1; -- needed in case same combination is inserted by 2 diff. threads and one has commited before other
   exception
     when no_data_found then
       /*
	if g_call_from_setup = 'Y' then
	      oe_debug_pub.add('No pattern_phases found; go insert');
	else
	      fnd_file.put_line(FND_FILE.LOG, 'No pattern_phases found; go insert');
	end if;
       */
       INSERT INTO qp_pattern_phases
         (pattern_id,
          pricing_phase_id,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login,
          program_application_id,
          program_id,
          program_update_date,
          request_id
         )
       VALUES
         (p_pattern_id,
          p_pricing_phase_id,
          sysdate,
          FND_GLOBAL.USER_ID,
          sysdate,
          FND_GLOBAL.USER_ID,
          FND_GLOBAL.LOGIN_ID,
          FND_GLOBAL.PROG_APPL_ID,
          FND_GLOBAL.CONC_PROGRAM_ID,
          sysdate,
          FND_GLOBAL.CONC_REQUEST_ID
         );

       if g_call_from_setup <> 'Y' then
          commit;
       end if;

     when others then
	if g_call_from_setup = 'Y' then
	      oe_debug_pub.add('Insert failure:'||sqlerrm);
	else
	      fnd_file.put_line(FND_FILE.LOG, 'Insert failure:'||sqlerrm);
	end if;
       raise;
   end;

 END IF; -- p_list_header_id is not null
 /*
 if g_call_from_setup = 'Y' then
      oe_debug_pub.add('End Populate_Pattern_Phases ');
 else
      fnd_file.put_line(FND_FILE.LOG, 'End Populate_Pattern_Phases ');
 end if;
 */

EXCEPTION
 WHEN OTHERS THEN
    if g_call_from_setup = 'Y' then
      oe_debug_pub.add('ATTR_GRP_PVT.Populate_Pattern_Phases ' || SQLERRM);
    else
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'ATTR_GRP_PVT.Populate_Pattern_Phases ' || SQLERRM );
    end if;
    raise;
END Populate_Pattern_Phases;

PROCEDURE Header_Pattern_Main(
  p_list_header_id    IN  NUMBER
 ,p_qualifier_group   IN  NUMBER
 ,p_setup_action      IN VARCHAR2 ) IS

  -- p_setup_action I (for insert), U (for update), D (for delete) or
  -- UD (for update in denormalized columns from header like active_flag, currency etc.)
  l_status_code VARCHAR2(30) := NULL;
  l_status_text VARCHAR2(2000) := NULL;
  l_pattern_id  NUMBER;
  l_qual_exists    VARCHAR2(1) := 'N';
  l_ACTIVE_FLAG                 qp_list_headers_b.active_flag%type;
  l_LIST_TYPE_CODE              qp_list_headers_b.list_type_code%type;
  l_CURRENCY_CODE               qp_list_headers_b.CURRENCY_CODE%type;
  l_ASK_FOR_FLAG                qp_list_headers_b.ASK_FOR_FLAG%type;
  l_HEADER_LIMIT_EXISTS         qp_list_headers_b.LIMIT_EXISTS_FLAG%type;
  l_SOURCE_SYSTEM_CODE          qp_list_headers_b.SOURCE_SYSTEM_CODE%type;

BEGIN
   g_call_from_setup := 'Y';

   if g_call_from_setup = 'Y' then
     oe_debug_pub.add('Header_Pattern_Main - p_list_header_id = ' ||p_list_header_id);
     oe_debug_pub.add('Header_Pattern_Main - p_qualifier_group = ' ||p_qualifier_group);
     oe_debug_pub.add('Header_Pattern_Main - p_setup_action = ' ||p_setup_action);
   else
     fnd_file.put_line(FND_FILE.LOG, 'Header_Pattern_Main - p_list_header_id = ' ||p_list_header_id);
     fnd_file.put_line(FND_FILE.LOG, 'Header_Pattern_Main - p_qualifier_group = ' ||p_qualifier_group);
     fnd_file.put_line(FND_FILE.LOG, 'Header_Pattern_Main - p_setup_action = ' ||p_setup_action);
   end if;

     -- when called while set up of modifier/price list
     if p_setup_action <> 'UD' then
        -- No need to delete pattern in case of update in denormalized columns in header
        -- delete from qp_attribute_groups first
        if p_qualifier_group is null then
          delete from qp_attribute_groups
           where list_header_id = p_list_header_id
             and list_line_id = -1;
        elsif p_qualifier_group is not null then
          delete from qp_attribute_groups
           where list_header_id = p_list_header_id
             and list_line_id = -1
             and GROUPING_NO in (-1, p_qualifier_group);
        end if;

        -- update the segment_id columns for qualifiers
        Update_Qual_Segment_id(p_list_header_id,  p_qualifier_group, -1, -1);
     end if;

     -- populate the records in qp_attribute_groups afresh for p_list_header_id, list_line_id -1
     -- and p_qualifier_group
     if p_setup_action = 'I' then
       -- insert case
       generate_hp_atgrps(p_list_header_id, p_qualifier_group);
     elsif p_setup_action = 'U' or p_setup_action = 'D' then
       -- update or delete case
       if p_qualifier_group is null then
          generate_hp_atgrps(p_list_header_id, p_qualifier_group);
       elsif p_qualifier_group is not null then
          begin
            select 'Y'
              into l_qual_exists
              from qp_qualifiers
             where list_header_id = p_list_header_id
               and list_line_id = -1
               and ((list_type_code = 'PRL'
                     AND QUALIFIER_CONTEXT <> 'MODLIST'
                     AND QUALIFIER_ATTRIBUTE <> 'QUALIFIER_ATTRIBUTE4')
                    OR
                    (list_type_code <> 'PRL')
                   )
               and QUALIFIER_GROUPING_NO = p_qualifier_group
               and rownum = 1;
          exception
            when no_data_found then
              l_qual_exists := 'N';
          end;

          if l_qual_exists = 'Y' then
             -- means some qualifiers still exist for p_qualifier_group
             generate_hp_atgrps(p_list_header_id, p_qualifier_group);
          else
            begin
              select 'Y'
                into l_qual_exists
                from qp_qualifiers
               where list_header_id = p_list_header_id
                 and list_line_id = -1
                 and ((list_type_code = 'PRL'
                       AND QUALIFIER_CONTEXT <> 'MODLIST'
                       AND QUALIFIER_ATTRIBUTE <> 'QUALIFIER_ATTRIBUTE4')
                      OR
                      (list_type_code <> 'PRL')
                     )
                 and QUALIFIER_GROUPING_NO <> -1
                 and rownum = 1;
            exception
              when no_data_found then
                l_qual_exists := 'N';
            end;

             if l_qual_exists = 'N' then
               -- no qualifiers exist other than -1 qualifier_grouping_no
               -- this may insert in qp_attribute_groups with HDR_QUAL_GROUPING_NO = -1, if any
               -- qualifiers exist with qualifier_grouping_no = -1
               generate_hp_atgrps(p_list_header_id, p_qualifier_group);
             end if; -- l_qual_exists = 'N'
          end if; -- l_qual_exists = 'Y'
       end if; --p_qualifier_group is null
     elsif p_setup_action = 'UD' then
	begin
        select ACTIVE_FLAG,
               LIST_TYPE_CODE,
               CURRENCY_CODE,
               ASK_FOR_FLAG,
               LIMIT_EXISTS_FLAG,
               SOURCE_SYSTEM_CODE
          into l_ACTIVE_FLAG,
               l_LIST_TYPE_CODE,
               l_CURRENCY_CODE,
               l_ASK_FOR_FLAG,
               l_HEADER_LIMIT_EXISTS,
               l_SOURCE_SYSTEM_CODE
          from qp_list_headers_b
         where list_header_id = p_list_header_id;

        -- update header pattern records
        update qp_attribute_groups
           set ACTIVE_FLAG = l_ACTIVE_FLAG,
               LIST_TYPE_CODE = l_LIST_TYPE_CODE,
               CURRENCY_CODE = l_CURRENCY_CODE,
               ASK_FOR_FLAG = l_ASK_FOR_FLAG,
               LIMIT_EXISTS = l_HEADER_LIMIT_EXISTS,
               SOURCE_SYSTEM_CODE = l_SOURCE_SYSTEM_CODE
         where list_header_id = p_list_header_id
           and list_line_id = -1;

        -- update line pattern records
        update qp_attribute_groups
           set ACTIVE_FLAG = l_ACTIVE_FLAG,
               LIST_TYPE_CODE = l_LIST_TYPE_CODE,
               CURRENCY_CODE = l_CURRENCY_CODE,
               ASK_FOR_FLAG = l_ASK_FOR_FLAG,
               SOURCE_SYSTEM_CODE = l_SOURCE_SYSTEM_CODE
         where list_header_id = p_list_header_id
           and list_line_id <> -1;

       exception
         when no_data_found then
            if g_call_from_setup = 'Y' then
               oe_debug_pub.add('Header_Pattern_Main - no_data_found in action UD ' );
            end if;
            null;

         when others then
            if g_call_from_setup = 'Y' then
               oe_debug_pub.add('Header_Pattern_Main - others exceptions in action UD ' );
            end if;
           null;
       end;
     end if; -- p_setup_action = 'I'

EXCEPTION
  WHEN OTHERS THEN
    if g_call_from_setup = 'Y' then
      oe_debug_pub.add('ATTR_GRP_PVT.Header_Pattern_Main ' || SQLERRM);
    else
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'ATTR_GRP_PVT.Header_Pattern_Main ' || SQLERRM );
    end if;

END Header_Pattern_Main;

PROCEDURE Line_Pattern_Main(
  p_list_header_id    IN  NUMBER
 ,p_list_line_id      IN  NUMBER
 ,p_qualifier_group   IN  NUMBER
 ,p_setup_action      IN VARCHAR2 ) IS

  l_status_code VARCHAR2(30) := NULL;
  l_status_text VARCHAR2(2000) := NULL;
  l_pid NUMBER := NULL;
  l_qual_exists    varchar2(1) := 'N';
  l_line_LIMIT_EXISTS         qp_list_lines.LIMIT_EXISTS_FLAG%type;

BEGIN
   g_call_from_setup := 'Y';

   if g_call_from_setup = 'Y' then
     oe_debug_pub.add('Line_Pattern_Main - p_list_header_id = ' ||p_list_header_id);
     oe_debug_pub.add('Line_Pattern_Main - p_list_line_id = ' ||p_list_line_id);
     oe_debug_pub.add('Line_Pattern_Main - p_qualifier_group = ' ||p_qualifier_group);
     oe_debug_pub.add('Line_Pattern_Main - p_setup_action = ' ||p_setup_action);
   else
     fnd_file.put_line(FND_FILE.LOG, 'Line_Pattern_Main - p_list_header_id = ' ||p_list_header_id);
     fnd_file.put_line(FND_FILE.LOG, 'Line_Pattern_Main - p_list_line_id = ' ||p_list_line_id);
     fnd_file.put_line(FND_FILE.LOG, 'Line_Pattern_Main - p_qualifier_group = ' ||p_qualifier_group);
     fnd_file.put_line(FND_FILE.LOG, 'Line_Pattern_Main - p_setup_action = ' ||p_setup_action);
   end if;

    -- when called while set up of modifier
    if p_setup_action <> 'UD' then
     -- delete from qp_attribute_groups first
     if p_qualifier_group is null then
       delete from qp_attribute_groups
        where list_header_id = p_list_header_id
          and list_line_id = p_list_line_id;
     elsif p_qualifier_group is not null then
       delete from qp_attribute_groups
        where list_header_id = p_list_header_id
          and list_line_id = p_list_line_id
          and GROUPING_NO in (-1, p_qualifier_group);
     end if;

     -- update the segment_id columns for qualifiers
     Update_Qual_Segment_id(p_list_header_id, p_qualifier_group, p_list_line_id, p_list_line_id);

     -- update the product_segment_id and pricing_segment_id columns in qp_pricing_attributes
     Update_Prod_Pric_Segment_id(p_list_header_id, p_list_line_id, p_list_line_id );
    end if;

     -- populate the records in qp_attribute_groups afresh for p_list_header_id, p_list_line_id
     -- and p_qualifier_group
     if p_setup_action = 'I' then
       -- insert case
          generate_lp_atgrps(p_list_header_id, p_qualifier_group,
       			  p_list_line_id, p_list_line_id);
     elsif p_setup_action = 'U' or p_setup_action = 'D' then
       -- update or delete case
       if p_qualifier_group is null then
	     update qp_list_lines
	     set pattern_id = null,
		 hash_key = null,
		 cache_key = null
	    where list_line_id = p_list_line_id
	    and qualification_ind in (0, 2);
          generate_lp_atgrps(p_list_header_id, p_qualifier_group,
       			  p_list_line_id, p_list_line_id);
       elsif p_qualifier_group is not null then
          begin
            select 'Y'
              into l_qual_exists
              from qp_qualifiers
             where list_header_id = p_list_header_id
               and list_line_id = p_list_line_id
               and QUALIFIER_GROUPING_NO = p_qualifier_group
               and rownum = 1;
          exception
            when no_data_found then
              l_qual_exists := 'N';
          end;

          if l_qual_exists = 'Y' then
             -- means some qualifiers still exist for p_qualifier_group
		 update qp_list_lines
		 set pattern_id = null,
		     hash_key = null,
		     cache_key = null
		where list_line_id = p_list_line_id
		and qualification_ind in (0, 2);
             generate_lp_atgrps(p_list_header_id, p_qualifier_group,
				  p_list_line_id, p_list_line_id);
          else
             begin
               select 'Y'
                 into l_qual_exists
                 from qp_qualifiers
                where list_header_id = p_list_header_id
                  and list_line_id = p_list_line_id
                  and QUALIFIER_GROUPING_NO <> -1
                  and rownum = 1;
             exception
               when no_data_found then
                 l_qual_exists := 'N';
             end;

             if l_qual_exists = 'N' then
               -- no qualifiers exist other than -1 qualifier_grouping_no
               -- this may insert in qp_attribute_groups with LINE_QUAL_GROUPING_NO = -1, if any
               -- qualifiers exist with qualifier_grouping_no = -1
		     update qp_list_lines
		     set pattern_id = null,
			 hash_key = null,
			 cache_key = null
		    where list_line_id = p_list_line_id
		    and qualification_ind in (0, 2);
               generate_lp_atgrps(p_list_header_id,p_qualifier_group,
				  p_list_line_id, p_list_line_id);
             end if; -- l_qual_exists = 'N'
          end if; -- l_qual_exists = 'Y'
       end if; --p_qualifier_group is null
     elsif p_setup_action = 'UD' then
	begin
        select LIMIT_EXISTS_FLAG
          into l_line_LIMIT_EXISTS
          from qp_list_lines
         where list_line_id = p_list_line_id;

        -- update line pattern records
        update qp_attribute_groups
           set LIMIT_EXISTS = l_line_LIMIT_EXISTS
         where list_header_id = p_list_header_id
           and list_line_id = p_list_line_id;

       exception
         when no_data_found then
            if g_call_from_setup = 'Y' then
               oe_debug_pub.add('Line_Pattern_Main - no_data_found in action UD ' );
            end if;
            null;

         when others then
            if g_call_from_setup = 'Y' then
               oe_debug_pub.add('Line_Pattern_Main - others exceptions in action UD ' );
            end if;
           null;
       end;
     end if; -- p_setup_action = 'I'

     -- at last, delete/restore PP depending on whether LP exists or not for passed header_id, line_id
     if p_setup_action = 'D' then
       -- line qualifier delete case
       begin
         select 'Y'
           into l_qual_exists
           from qp_attribute_groups
          where list_header_id = p_list_header_id
            and list_line_id = p_list_line_id
            and rownum = 1;
       exception
         when no_data_found then
           l_qual_exists := 'N';
       end;
     else
       -- line qualifier insert/update case, assume there will be record in qp_attribute_groups
       l_qual_exists := 'Y';
     end if;

     if p_setup_action = 'I' then
       -- assume LP exists, and so nullify the PP values in qp_list_lines table
       --except cache_key
       update qp_list_lines
       set pattern_id = null,
          pricing_attribute_count = null,
          product_uom_code = null,
          hash_key = null
      where list_line_id = p_list_line_id
        and pattern_id is not null;

     end if;

     if l_qual_exists = 'N' and p_setup_action = 'D' then
       -- means restore PP
       remove_prod_pattern_for_line(p_list_line_id);
       update_pp_lines(p_list_header_id, p_list_line_id, p_list_line_id);
     end if;

EXCEPTION
  WHEN OTHERS THEN
    if g_call_from_setup = 'Y' then
      oe_debug_pub.add('ATTR_GRP_PVT.Line_Pattern_Main ' || SQLERRM);
    else
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'ATTR_GRP_PVT.Line_Pattern_Main ' || SQLERRM );
    end if;

END Line_Pattern_Main;

PROCEDURE Product_Pattern_Main(
  p_list_header_id    IN  NUMBER ,
  p_list_line_id      IN  NUMBER ,
  p_setup_action      IN  VARCHAR2 ) IS

  l_status_code VARCHAR2(30) := NULL;
  l_status_text VARCHAR2(2000) := NULL;
  l_qual_exists    varchar2(1) := 'N';
  l_product_uom_code    qp_list_lines.product_uom_code%type;
  l_qual_ind    number;

BEGIN
   g_call_from_setup := 'Y';

   if g_call_from_setup = 'Y' then
     oe_debug_pub.add('Product_Pattern_Main - p_list_header_id = ' ||p_list_header_id);
     oe_debug_pub.add('Product_Pattern_Main - p_list_line_id = ' ||p_list_line_id);
     oe_debug_pub.add('Product_Pattern_Main - p_setup_action = ' ||p_setup_action);
   else
     fnd_file.put_line(FND_FILE.LOG, 'Product_Pattern_Main - p_list_header_id = ' ||p_list_header_id);
     fnd_file.put_line(FND_FILE.LOG, 'Product_Pattern_Main - p_list_line_id = ' ||p_list_line_id);
     fnd_file.put_line(FND_FILE.LOG, 'Product_Pattern_Main - p_setup_action = ' ||p_setup_action);
   end if;

 select qualification_ind
   into l_qual_ind
   from qp_list_lines
  where list_line_id = p_list_line_id;

 oe_debug_pub.add('Product_Pattern_Main - l_qual_ind = ' ||l_qual_ind);

 -- do nothing, return back if called for child line, bug 3581058
 if l_qual_ind in (4, 6, 8, 10, 12, 14, 20, 22, 28, 30) then
    null;
 else
   return;
 end if;

 if p_setup_action = 'UD' then
   -- update qp_list_lines.product_uom_code
   begin
     select product_uom_code
       into l_product_uom_code
       from qp_pricing_attributes
      where list_header_id = p_list_header_id
        and list_line_id = p_list_line_id
        and product_uom_code is not null
        and rownum = 1;
   exception
     when no_data_found then
       l_product_uom_code := null;
   end;

   update qp_list_lines
      set product_uom_code = l_product_uom_code
    where list_line_id = p_list_line_id;
 else
    -- when called while set up of price list/modifier
    begin
      select 'Y'
        into l_qual_exists
        from qp_qualifiers
       where list_header_id = p_list_header_id
         and list_line_id = p_list_line_id
         and rownum = 1;
    exception
      when no_data_found then
        l_qual_exists := 'N';
    end;

    if l_qual_exists = 'Y' then
       if g_call_from_setup = 'Y' then
         oe_debug_pub.add('going to populate LP');
       else
         fnd_file.put_line(FND_FILE.LOG, 'going to populate LP');
       end if;
       Line_Pattern_Main(p_list_header_id, p_list_line_id, null, 'I');
    else
       if g_call_from_setup = 'Y' then
         oe_debug_pub.add('going to populate PP');
       else
         fnd_file.put_line(FND_FILE.LOG, 'going to populate PP');
       end if;

       remove_prod_pattern_for_line(p_list_line_id);

       -- update the product_segment_id and pricing_segment_id columns in qp_pricing_attributes
       Update_Prod_Pric_Segment_id(p_list_header_id, p_list_line_id,
       							p_list_line_id);

       update_pp_lines(p_list_header_id, p_list_line_id, p_list_line_id);
    end if;
 end if; -- p_setup_action = 'UD'

EXCEPTION
  WHEN OTHERS THEN
    if g_call_from_setup = 'Y' then
      oe_debug_pub.add('ATTR_GRP_PVT.Product_Pattern_Main ' || SQLERRM);
    else
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'ATTR_GRP_PVT.Product_Pattern_Main ' || SQLERRM );
    end if;

END Product_Pattern_Main;

procedure Remove_Prod_Pattern_for_Line(p_list_line_id IN NUMBER)
is
begin
     update qp_list_lines
     set pattern_id = null,
	pricing_attribute_count = null,
	product_uom_code = null,
	hash_key = null,
	cache_key = null
    where list_line_id = p_list_line_id
      and pattern_id is not null;

exception
  when no_data_found then
     null;

  when others then
    if g_call_from_setup = 'Y' then
      oe_debug_pub.add('ATTR_GRP_PVT.Remove_Prod_Pattern_For_Line ' || SQLERRM);
    else
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'ATTR_GRP_PVT.Remove_Prod_Pattern_For_Line ' || SQLERRM );
    end if;
     raise;
end remove_prod_pattern_for_line;

procedure Update_Qual_Segment_id(p_list_header_id  IN  NUMBER
                                ,p_qualifier_group IN  NUMBER
				,p_low_list_line_id IN NUMBER
				,p_high_list_line_id IN NUMBER)
is
  cursor c_qual_seg_id is
     select distinct QUALIFIER_CONTEXT, QUALIFIER_ATTRIBUTE
       from qp_qualifiers
      where QUALIFIER_CONTEXT is not null
        and QUALIFIER_ATTRIBUTE is not null
        and list_header_id = nvl(p_list_header_id, list_header_id)
        and list_line_id between p_low_list_line_id and p_high_list_line_id
        and ((p_qualifier_group is not null and qualifier_grouping_no in (-1, p_qualifier_group))
              OR
             (p_qualifier_group is null)
            );

  TYPE segment_id_tab IS TABLE OF qp_qualifiers.segment_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE context_tab IS TABLE OF qp_qualifiers.QUALIFIER_CONTEXT%TYPE INDEX BY BINARY_INTEGER;
  TYPE attribute_tab IS TABLE OF qp_qualifiers.QUALIFIER_ATTRIBUTE%TYPE INDEX BY BINARY_INTEGER;

  segment_id_t  segment_id_tab;
  context_t     context_tab;
  attribute_t   attribute_tab;

begin
  -- update the segment_id columns for qualifiers
  if g_call_from_setup = 'Y' then
     oe_debug_pub.add('Inside Update_Qual_Segment_id');
     oe_debug_pub.add('Start time :'||to_char(sysdate,'MM/DD/YYYY:HH:MI:SSSS'));
  else
     fnd_file.put_line(FND_FILE.LOG, 'Inside Update_Qual_Segment_id');
     fnd_file.put_line(FND_FILE.LOG, 'Start time :'||to_char(sysdate,'MM/DD/YYYY:HH:MI:SSSS'));
  end if;
  segment_id_t.delete;
  context_t.delete;
  attribute_t.delete;

  OPEN c_qual_seg_id;
  FETCH c_qual_seg_id BULK COLLECT INTO
         context_t,
         attribute_t;
  CLOSE c_qual_seg_id;

  if context_t.count > 0 then
    if g_call_from_setup = 'Y' then
       oe_debug_pub.add('Context_t.count='||context_t.count);
    else
       fnd_file.put_line(FND_FILE.LOG, 'Context_t.count='||context_t.count);
    end if;
    FOR i in 1..context_t.count
    LOOP
      select b.segment_id
        into segment_id_t(i)
        from qp_prc_contexts_b a, qp_segments_b b
       where b.prc_context_id = a.prc_context_id
         and a.PRC_CONTEXT_CODE = context_t(i)
         and b.SEGMENT_MAPPING_COLUMN = attribute_t(i);
    END LOOP;

    FORALL j in 1..context_t.count
      update qp_qualifiers
         set segment_id = segment_id_t(j)
       where QUALIFIER_CONTEXT = context_t(j)
         and QUALIFIER_ATTRIBUTE = attribute_t(j)
         and list_header_id = nvl(p_list_header_id, list_header_id)
         and list_line_id between p_low_list_line_id and p_high_list_line_id;

    if g_call_from_setup = 'Y' then
       oe_debug_pub.add('No of qualifiers updated='||SQL%ROWCOUNT);
    else
       fnd_file.put_line(FND_FILE.LOG, 'No of qualifiers updated='||SQL%ROWCOUNT);
    end if;
  end if; -- context_t.count > 0

  if g_call_from_setup = 'Y' then
     oe_debug_pub.add('End Update_Qual_Segment_id');
     oe_debug_pub.add('End time :'||to_char(sysdate,'MM/DD/YYYY:HH:MI:SSSS'));
  else
     fnd_file.put_line(FND_FILE.LOG, 'End Update_Qual_Segment_id');
     fnd_file.put_line(FND_FILE.LOG, 'End time :'||to_char(sysdate,'MM/DD/YYYY:HH:MI:SSSS'));
  end if;
exception
  when no_data_found then
	  if g_call_from_setup = 'Y' then
	       oe_debug_pub.add('No data found in c_qual_seg_id');
	  else
	       fnd_file.put_line(FND_FILE.LOG, 'No data found in c_qual_seg_id');
	  end if;

  when others then
    if g_call_from_setup = 'Y' then
      oe_debug_pub.add('ATTR_GRP_PVT.Update_Qual_Segment_Id ' || SQLERRM);
    else
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'ATTR_GRP_PVT.Update_Qual_Segment_Id ' || SQLERRM );
    end if;

    raise;

end Update_Qual_Segment_id;

procedure Update_Prod_Pric_Segment_id(p_list_header_id  IN  NUMBER
--                                     ,p_list_line_id    IN  NUMBER
				     ,p_low_list_line_id IN NUMBER
				     ,p_high_list_line_id IN NUMBER)
is
  cursor c_prod_seg_id is
     select distinct PRODUCT_ATTRIBUTE_CONTEXT, PRODUCT_ATTRIBUTE
       from qp_pricing_attributes
      where PRODUCT_ATTRIBUTE_CONTEXT is not null
        and PRODUCT_ATTRIBUTE is not null
        --and list_header_id = nvl(p_list_header_id, list_header_id)
	and list_line_id between p_low_list_line_id and p_high_list_line_id;

  cursor c_pric_seg_id is
     select distinct PRICING_ATTRIBUTE_CONTEXT, PRICING_ATTRIBUTE
       from qp_pricing_attributes
      where PRICING_ATTRIBUTE_CONTEXT is not null
        and PRICING_ATTRIBUTE is not null
        --and list_header_id = nvl(p_list_header_id, list_header_id)
	and list_line_id between p_low_list_line_id and p_high_list_line_id;

  TYPE segment_id_tab IS TABLE OF qp_pricing_attributes.product_segment_id%TYPE INDEX BY BINARY_INTEGER;
  TYPE context_tab IS TABLE OF qp_pricing_attributes.PRODUCT_ATTRIBUTE_CONTEXT%TYPE INDEX BY BINARY_INTEGER;
  TYPE attribute_tab IS TABLE OF qp_pricing_attributes.PRODUCT_ATTRIBUTE%TYPE INDEX BY BINARY_INTEGER;

  segment_id_t  segment_id_tab;
  context_t     context_tab;
  attribute_t   attribute_tab;


begin
  if g_call_from_setup = 'Y' then
     oe_debug_pub.add('Inside Update_Prod_Pric_Segment_id');
     oe_debug_pub.add('Start time :'||to_char(sysdate,'MM/DD/YYYY:HH:MI:SSSS'));
  else
     fnd_file.put_line(FND_FILE.LOG, 'Inside Update_Prod_Pric_Segment_id');
     fnd_file.put_line(FND_FILE.LOG, 'Start time :'||to_char(sysdate,'MM/DD/YYYY:HH:MI:SSSS'));
  end if;
  -- update the product_segment_id column in qp_pricing_attributes
  segment_id_t.delete;
  context_t.delete;
  attribute_t.delete;

  OPEN c_prod_seg_id;
  FETCH c_prod_seg_id BULK COLLECT INTO
         context_t,
         attribute_t;
  CLOSE c_prod_seg_id;

  if context_t.count > 0 then
    if g_call_from_setup = 'Y' then
       oe_debug_pub.add('Context_t.count='||context_t.count);
    else
       fnd_file.put_line(FND_FILE.LOG, 'Context_t.count='||context_t.count);
    end if;
    FOR i in 1..context_t.count
    LOOP
      select b.segment_id
        into segment_id_t(i)
        from qp_prc_contexts_b a, qp_segments_b b
       where b.prc_context_id = a.prc_context_id
         and a.PRC_CONTEXT_CODE = context_t(i)
         and b.SEGMENT_MAPPING_COLUMN = attribute_t(i);
    END LOOP;

    FORALL j in 1..context_t.count
      update qp_pricing_attributes
         set product_segment_id = segment_id_t(j)
       where PRODUCT_ATTRIBUTE_CONTEXT = context_t(j)
         and PRODUCT_ATTRIBUTE = attribute_t(j)
         --and list_header_id = nvl(p_list_header_id, list_header_id)
	 and list_line_id between p_low_list_line_id and p_high_list_line_id;

    if g_call_from_setup = 'Y' then
       oe_debug_pub.add('No of product segment ids updated='||SQL%ROWCOUNT);
       oe_debug_pub.add('End Time product segments :'||to_char(sysdate,'MM/DD/YYYY:HH:MI:SSSS'));
    else
       fnd_file.put_line(FND_FILE.LOG, 'No of product segment ids updated='||SQL%ROWCOUNT);
       fnd_file.put_line(FND_FILE.LOG, 'End time product segments :'||to_char(sysdate,'MM/DD/YYYY:HH:MI:SSSS'));
    end if;
  end if; -- context_t.count > 0

  -- update the pricing_segment_id columns in qp_pricing_attributes
  segment_id_t.delete;
  context_t.delete;
  attribute_t.delete;

  OPEN c_pric_seg_id;
  FETCH c_pric_seg_id BULK COLLECT INTO
         context_t,
         attribute_t;
  CLOSE c_pric_seg_id;

  if context_t.count > 0 then
    if g_call_from_setup = 'Y' then
       oe_debug_pub.add('Context_t.count='||context_t.count);
    else
       fnd_file.put_line(FND_FILE.LOG, 'Context_t.count='||context_t.count);
    end if;

    FOR i in 1..context_t.count
    LOOP
      select b.segment_id
        into segment_id_t(i)
        from qp_prc_contexts_b a, qp_segments_b b
       where b.prc_context_id = a.prc_context_id
         and a.PRC_CONTEXT_CODE = context_t(i)
         and b.SEGMENT_MAPPING_COLUMN = attribute_t(i);
    END LOOP;

    FORALL j in 1..context_t.count
      update qp_pricing_attributes
         set pricing_segment_id = segment_id_t(j)
       where PRICING_ATTRIBUTE_CONTEXT = context_t(j)
         and PRICING_ATTRIBUTE = attribute_t(j)
         --and list_header_id = nvl(p_list_header_id, list_header_id)
	 and list_line_id between p_low_list_line_id and p_high_list_line_id;

    if g_call_from_setup = 'Y' then
       oe_debug_pub.add('No of pricing segment ids updated='||SQL%ROWCOUNT);
       oe_debug_pub.add('End Time pricing segments :'||to_char(sysdate,'MM/DD/YYYY:HH:MI:SSSS'));
    else
       fnd_file.put_line(FND_FILE.LOG, 'No of pricing segment ids updated='||SQL%ROWCOUNT);
       fnd_file.put_line(FND_FILE.LOG, 'End time pricing segments :'||to_char(sysdate,'MM/DD/YYYY:HH:MI:SSSS'));
    end if;
  end if; -- context_t.count > 0

  if g_call_from_setup = 'Y' then
       oe_debug_pub.add('End Update_Prod_Pric_Segment_id');
  else
       fnd_file.put_line(FND_FILE.LOG, 'End Update_Prod_Pric_Segment_id');
  end if;
exception
  when no_data_found then
	  if g_call_from_setup = 'Y' then
	       oe_debug_pub.add('No data found in Update_Prod_Pric_Segment_id');
	  else
	       fnd_file.put_line(FND_FILE.LOG, 'No data found in Update_Prod_Pric_Segment_id');
	  end if;

     null;

  when others then
    if g_call_from_setup = 'Y' then
      oe_debug_pub.add('ATTR_GRP_PVT.Update_Prod_Pric_Segment_id ' || SQLERRM);
    else
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'ATTR_GRP_PVT.Update_Prod_Pric_Segment_id ' || SQLERRM );
    end if;

     raise;

end Update_Prod_Pric_Segment_id;

end QP_ATTR_GRP_PVT; -- end package

/
