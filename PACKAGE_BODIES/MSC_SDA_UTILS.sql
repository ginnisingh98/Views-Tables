--------------------------------------------------------
--  DDL for Package Body MSC_SDA_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_SDA_UTILS" as
/*  $Header: MSCSDAUB.pls 120.39.12010000.5 2010/04/07 17:44:17 hulu ship $ */

  procedure println(p_msg varchar2) is
  begin
    if ( not(g_log_flag) ) then
      return;
    end if;

    --dbms_output.put_line(p_msg);
    g_log_row := g_log_row + 1;

   if (g_log_file_name is null) then
     select ltrim(rtrim(value))
     into g_log_file_dir
     from (select value from v$parameter2 where name='utl_file_dir'
	     order by rownum desc)
     where rownum <2;
     g_log_file_name := 'mscsda-1.txt';
     g_log_file_handle := utl_file.fopen(g_log_file_dir, g_log_file_name, 'w');
   end if;

   if (utl_file.is_open(g_log_file_handle)) then
     utl_file.put_line(g_log_file_handle, p_msg);
     utl_file.fflush(g_log_file_handle);
     utl_file.fclose(g_log_file_handle);
   else
     g_log_file_handle := utl_file.fopen(g_log_file_dir, g_log_file_name, 'a');
     utl_file.put_line(g_log_file_handle, p_msg);
     utl_file.fflush(g_log_file_handle);
     utl_file.fclose(g_log_file_handle);
   end if;

  exception
   when others then
      return;
  end println;

  function escapeSplChars(p_value varchar2) return varchar2 is
    l_value varchar2(1000);
  begin
    l_value := p_value;
    l_value := replace(l_value, c_field_seperator, c_field_seperator_esc);
    l_value := replace(l_value, c_record_seperator, c_record_seperator_esc);
    if (l_value is null) then
      l_value := c_null_space;
    end if;
    return l_value;
  end escapeSplChars;

  procedure addRecordToOutStream(p_one_record varchar2,
    p_out_data_index in out nocopy number,
    p_out_data in out nocopy msc_sda_utils.maxchartbl) is
  begin
    if (nvl(length(p_out_data(1)),0) = 1) then -- {
      p_out_data(1) := p_one_record;
    elsif ( nvl(length(p_out_data(p_out_data_index)),0) + length(p_one_record) < 32000 ) then
      p_out_data(p_out_data_index) := p_out_data(p_out_data_index) || c_record_seperator || p_one_record;
    else
      p_out_data_index := p_out_data_index + 1;
      p_out_data.extend;
      p_out_data(p_out_data_index) := c_record_seperator || p_one_record;
    end if; -- }
  end addRecordToOutStream;

  procedure addToOutStream(p_one_record varchar2,
    p_out_data_index in out nocopy number,
    p_out_data in out nocopy msc_sda_utils.maxchartbl,
    p_debug_flag number default null) is
    l_one_record varchar2(32000);
  begin
    --println(' addToOutStream in/out');
    if (nvl(length(p_out_data(1)),0) = 1) then -- {
      p_out_data(1) := p_one_record;
    elsif ( nvl(length(p_out_data(p_out_data_index)),0) + length(p_one_record) < 32000 ) then
      p_out_data(p_out_data_index) := p_out_data(p_out_data_index) || p_one_record;
    else
      p_out_data_index := p_out_data_index + 1;
      p_out_data.extend;
      p_out_data(p_out_data_index) := p_one_record;
    end if; -- }
  end addToOutStream;

  function getNewFormQueryId return number is
     cursor c_query is
     select msc_form_query_s.nextval
     from dual;
     l_query_id number;
  begin
    open c_query;
    fetch c_query into l_query_id;
    close c_query;
    return l_query_id;
  end getNewFormQueryId;

  function getNewAnalysisQueryId return number is
     cursor c_query is
     select msc_analysis_query_s.nextval
     from dual;
     l_query_id number;
  begin
    open c_query;
    fetch c_query into l_query_id;
    close c_query;
    return l_query_id;
  end getNewAnalysisQueryId;

  function getRepairItem(p_plan_id number, p_lower_item_id number, p_highest_item_id number) return number is

    cursor c_repair_item_cur is
    select higher_item_id
    from msc_item_substitutes
    where plan_id = p_plan_id
      and relationship_type = c_mis_repair_to_type
      and lower_item_id = p_lower_item_id;
      --and highest_item_id = p_highest_item_id;

      l_repair_item_id number;
  begin
    open c_repair_item_cur;
    fetch c_repair_item_cur into l_repair_item_id;
    close c_repair_item_cur;
    return l_repair_item_id;
  end getRepairItem;

  function flushSupersessionChain(p_plan number, p_item number) return number is
    l_query_id number;
  begin
    l_query_id := getNewFormQueryId;


      insert into msc_form_query(query_id,
    creation_date, created_by, last_updated_by, last_update_date, number1,
number2, number3, number4,
    number5, number6, number7, date1, date2)
    select  l_query_id,sysdate, -1, -1, sysdate,
      b.lower_item_id, b.higher_item_id, b.highest_item_id, level,
      b.reciprocal_flag,
      msc_sda_utils.getRepairItem(plan_id, b.lower_item_id, b.highest_item_id)
repair_item_id,
      b.prime_item_id,
     (select min(a.effective_date) from msc_item_substitutes a
       where a.plan_id=p_plan
       and a.lower_item_id = b.lower_item_id
       and a.HIGHER_ITEM_ID=b.higher_item_id
       and a.relationship_type = c_mis_supersession_type
       and a.inferred_flag = 2
       and a.forward_rule = 1) as effective_date,
       disable_date
    from msc_item_substitutes b
      where b.plan_id = p_plan
        and b.relationship_type = c_mis_supersession_type
        and b.highest_item_id = p_item
        and b.inferred_flag = 2
        and b.forward_rule = 1
      start with b.highest_item_id = p_item
        and b.inferred_flag = 2
        and b.highest_item_id = b.higher_item_id
      connect by nocycle b.higher_item_id = prior b.lower_item_id
        and b.plan_id = prior b.plan_id
        and b.relationship_type = prior b.relationship_type
        and b.inferred_flag = prior b.inferred_flag
        and b.forward_rule = prior b.forward_rule
        --  and effective_date = prior effective_date
      order by level desc;


    return l_query_id;
  end flushSupersessionChain;

  function getOrgList(p_query_id number) return varchar2 is
    cursor c_name is
    select query_name
    from msc_personal_queries
    where query_id = p_query_id;
    l_name varchar2(250);
  begin
    open c_name;
    fetch c_name into l_name;
    close c_name;
    return l_name;
  end getOrgList;

  function getRegionList(p_query_id number) return varchar2 is
    cursor c_name is
    select query_name
    from msc_personal_queries
    where query_id = p_query_id;
    l_name varchar2(250);
  begin
    open c_name;
    fetch c_name into l_name;
    close c_name;
    return l_name;
  end getRegionList;

  function getRegionName(p_region_id number) return varchar2 is
    cursor c_name is
    select decode(region_type,
      0,country,
      1,country||'-'||state,
      2,country||'-'||state||'-'||city,
      3,country||'-'||state||'-'||city||'-'||postal_code_from||'-'||postal_code_to,
      10, mr.zone) reg_list_name
    from msc_regions mr
    where mr.region_id = p_region_id;
    l_name varchar2(250);
  begin
    open c_name;
    fetch c_name into l_name;
    close c_name;
    return l_name;
  end getRegionName;

  procedure  getRegListValues(p_region_list varchar2, p_region_type number,
    p_reg_list_id out nocopy number, p_reg_list out nocopy varchar2,
    p_region_id out nocopy number, p_region_code out nocopy varchar2) is
  begin
        if (p_region_type = c_reg_list_view) then
	  p_reg_list_id := p_region_list;
	  p_reg_list := getRegionList(p_region_list);
	  p_region_id := null;
	  p_region_code := null;
	elsif (p_region_type = c_reg_view) then
	  p_reg_list_id := null;
	  p_reg_list := null;
	  p_region_id := p_region_list;
	  p_region_code := getRegionName(p_region_list);
        end if;
  end getRegListValues;

  procedure  getOrgListValues(p_orglist varchar2, p_org_type number,
    p_org_list_id out nocopy number, p_org_list out nocopy varchar2,
    p_inst_id out nocopy number, p_org_id out nocopy number,
    p_org_code out nocopy varchar2) is

    l_open_pos number;
    l_close_pos number;
    l_comma_pos number;
  begin
	if (p_org_type = c_org_list_view) then
          p_org_list_id := p_orglist;
          p_org_list := getOrgList(p_orglist);
          p_inst_id := null;
          p_org_id := null;
          p_org_code := null;
	elsif (p_org_type = c_org_view) then
          l_open_pos := instr(p_orglist,'(');
          l_comma_pos := instr(p_orglist,'-');
          if (l_comma_pos = 0) then
            l_comma_pos := instr(p_orglist,',');
          end if;
          l_close_pos := instr(p_orglist,')');
          p_org_list_id := null;
          p_org_list := null;
          p_inst_id := substr(p_orglist,l_open_pos+1, l_comma_pos-l_open_pos-1);
          p_org_id := substr(p_orglist,l_comma_pos+1, l_close_pos-l_comma_pos-1);
          p_org_code := msc_get_name.org_code(p_org_id, p_inst_id);
	end if;
     println('getOrgListValues out');
  end getOrgListValues;

  procedure  getItemListValues(p_cur_item_id number, p_item_view_type number,
    p_top_item_id out nocopy number, p_top_item_name out nocopy varchar2,
    p_item_id out nocopy number, p_item_name out nocopy varchar2)  is
  begin
        if (p_item_view_type = c_item_view) then
	  p_top_item_id := null;
	  p_top_item_name := null;
	  p_item_id := p_cur_item_id;
	  p_item_name := msc_get_name.item_name(p_cur_item_id, null, null, null);
	else
	  p_top_item_id := p_cur_item_id;
	  p_top_item_name := msc_get_name.item_name(p_cur_item_id, null, null, null);
	  p_item_id := null;
	  p_item_name := null;
        end if;
   end getItemListValues;

  procedure  getItemPrimeSS(p_plan_id number, p_item_id number,
    p_prime_item_id out nocopy number, p_ss_item_id out nocopy number) is

    l_effective_date date;

    --- change the cursor to sort by effective_date
    --- this is required since we only pick the first row in the cursor
    cursor c_prime_ss_cur is
    select decode(p_item_id, lower_item_id, prime_item_id, higher_item_id),
      highest_item_id
      ,effective_date
    from msc_item_substitutes
    where plan_id = p_plan_id
      and relationship_type = c_mis_supersession_type
      and inferred_flag = 2
      and forward_rule = 1
      and (lower_item_id = p_item_id
           or (higher_item_id = highest_item_id and higher_item_id = p_item_id))
      order by effective_date DESC;

  begin
    open c_prime_ss_cur;
    fetch c_prime_ss_cur into p_prime_item_id, p_ss_item_id,l_effective_date;
    close c_prime_ss_cur;
  end getItemPrimeSS;

  function check_row_exists(p_query_id number, p_row_index number,
    p_org_list_id number, p_inst_id number, p_org_id number,
    p_top_item_id number, p_item_id number, p_orglist_action number, p_itemlist_action number) return number is

    cursor c_maq_cur is
    select count(*)
    from msc_analysis_query
    where query_id = p_query_id
      and parent_row_index = p_row_index
      and nvl(org_list_id, -1) = nvl(p_org_list_id, -1)
      and nvl(inst_id, -1) = nvl(p_inst_id, -1)
      and nvl(org_id, -1) = nvl(p_org_id, -1)
      and nvl(top_item_id, -1) = nvl(p_top_item_id, -1)
      and nvl(item_id, -1) = nvl(p_item_id, -1)
      and nvl(org_list_state, -1) = nvl(p_orglist_action, -1)
      and nvl(top_item_name_state, -1) = nvl(p_itemlist_action, -1) ;
    l_count number;
  begin
    open c_maq_cur;
    fetch c_maq_cur into l_count;
    close c_maq_cur;

    if l_count = 0 then
      return c_sys_no;
    end if;
    return c_sys_yes;
  end check_row_exists;

  procedure flushRegsOrgsIntoMfq(p_plan_id number, p_region_type number, p_region_list number,
    p_org_type number, p_org_list varchar2,
    p_region_query_id out nocopy number, p_org_query_id out nocopy number) is

    cursor c_regions_cur(p_view_type number) is
    select distinct
      to_number(null) region_list_id,
      to_char(null) region_list,
      p_region_list region_id,
      msc_sda_utils.getRegionName(p_region_list) region_code,
      p_region_list sort_column
    from dual
    where p_region_type = c_reg_view
      and p_view_type = 1
    union all
    select distinct
      mpq.query_id region_list_id,
      mpq.query_name region_list,
      mpt.object_type region_id,
      msc_sda_utils.getRegionName(mpt.object_type) region_code,
      mpt.sequence_id sort_column
    from msc_pq_types mpt,
      msc_personal_queries mpq
    where  mpq.query_id = p_region_list
      and mpq.query_id  = mpt.query_id
      and p_region_type = c_reg_list_view
      and p_view_type = 1
    order by 5;

/*
    --pabram..need to use supersession chain also to reduce inserting too many rows
    cursor c_orgs_cur is
    select md.zone_id region_id,
      md.sr_instance_id inst_id,
      md.organization_id org_id,
      msc_get_name.org_code(md.organization_id, md.sr_instance_id) org_code,
      md.inventory_item_id
    from msc_demands md,
      msc_form_query mfq
    where mfq.query_id = p_region_query_id
      and md.plan_id = p_plan_id
      and md.zone_id = mfq.number2;
*/
    cursor c_orgs_cur (p_view_type number, p_inst_id number, p_org_id number) is
    select distinct mfq.number2 region_id,
      mtp.sr_instance_id inst_id,
      mtp.sr_tp_id org_id,
      msc_get_name.org_code(mpo.organization_id, mpo.sr_instance_id) org_code,
      to_number(null) inventory_item_id
    from
      --msc_region_locations mrl,
      --msc_location_associations mla,
      msc_trading_partners mtp,
      msc_plan_organizations mpo,
      msc_form_query mfq
      --,msc_zone_regions mzr
    where mfq.query_id = p_region_query_id
      and nvl(mfq.number2,-1) > 0
      --and mzr.parent_region_id = mfq.number2
      --and mrl.region_id = mzr.region_id
      --and mrl.location_id = mla.location_id
      --and mla.partner_id = mtp.partner_id
      and mtp.partner_type = 3
      and mpo.plan_id = p_plan_id
      and mpo.sr_instance_id = mtp.sr_instance_id
      and mpo.organization_id = mtp.sr_tp_id
      and p_view_type = 1 --region list selected by user
      --pabram..commented out --msc_location_associations, msc_trading_partners for testing,
      --we need to enable this when these tables are flushed correctly
      --6736491, need to add mrl back
    union all
    select distinct
      c_mbp_not_null_value region_id,
      mtp.sr_instance_id inst_id,
      mtp.sr_tp_id org_id,
      msc_get_name.org_code(mtp.sr_tp_id, mtp.sr_instance_id) org_code,
      to_number(null) inventory_item_id
    from msc_trading_partners mtp
    where mtp.sr_tp_id = p_org_id
      and mtp.sr_instance_id = p_inst_id
      and mtp.partner_type = 3
      and p_org_type = c_org_view
      and p_view_type = 2
    union all
    select distinct
      c_mbp_not_null_value region_id,
      mpt.source_type inst_id,
      mpt.object_type org_id,
      msc_get_name.org_code(mpt.object_type, mpt.source_type) org_code,
      to_number(null) inventory_item_id
    from msc_pq_types mpt,
      msc_personal_queries mpq
    where mpq.query_id = p_org_list
      and mpq.query_id  = mpt.query_id
      and p_org_type = c_org_list_view
      and p_view_type = 2
    order by 4;

    ll_org_list_id number;
    ll_org_list varchar2(250);
    ll_inst_id number;
    ll_org_id number;
    ll_org_code varchar2(10);

    ll_view_type number;
  begin
    println('flushRegsOrgsIntoMfq in');
    p_region_query_id := getNewFormQueryId;
    p_org_query_id := getNewFormQueryId;

    if ( p_region_list is not null) then
      ll_view_type := 1;
    elsif (p_org_list is not null) then
      msc_sda_utils.getOrgListValues(p_org_list, p_org_type, ll_org_list_id, ll_org_list, ll_inst_id, ll_org_id, ll_org_code);
      ll_view_type := 2;
    end if;

    for c_regions in c_regions_cur(ll_view_type)
    loop
      println('regions loop in');
      insert into msc_form_query (query_id, creation_date, created_by, last_updated_by, last_update_date,
        number1, char1, number2, char2, number3)
      values (p_region_query_id, sysdate, -1, -1, sysdate,
        c_regions.region_list_id, c_regions.region_list, c_regions.region_id, c_regions.region_code, c_regions.sort_column);

      --insert a global org for each region
      insert into msc_form_query (query_id, creation_date, created_by, last_updated_by, last_update_date,
        number1, number2, number3, char1, number4)
      values (p_org_query_id, sysdate, -1, -1, sysdate,
        c_regions.region_id, to_number(null), -1, to_char(c_mbp_null_value), c_mbp_null_value);

      println('regions loop out');
    end loop;

      --insert one global orgs for global without region_id
      insert into msc_form_query (query_id, creation_date, created_by, last_updated_by, last_update_date,
        number1, number2, number3, char1, number4)
      values (p_org_query_id, sysdate, -1, -1, sysdate,
        c_mbp_null_value, to_number(null), -1, to_char(c_mbp_null_value), c_mbp_null_value);

    --add global region
      insert into msc_form_query (query_id, creation_date, created_by, last_updated_by, last_update_date,
        number1, char1, number2, char2, number3)
      values (p_region_query_id, sysdate, -1, -1, sysdate,
        to_number(null), null, c_global_reg_type, c_global_reg_type_text, c_global_reg_type);

    --add local region
      insert into msc_form_query (query_id, creation_date, created_by, last_updated_by, last_update_date,
        number1, char1, number2, char2, number3)
      values (p_region_query_id, sysdate, -1, -1, sysdate,
        to_number(null), null, c_local_reg_type, c_local_reg_type_text, c_local_reg_type);

      --insert one global orgs for local with region_id for usage based forecast local
      insert into msc_form_query (query_id, creation_date, created_by, last_updated_by, last_update_date,
        number1, number2, number3, char1, number4)
      values (p_org_query_id, sysdate, -1, -1, sysdate,
        c_local_reg_type, to_number(null), -1, to_char(c_mbp_null_value), c_mbp_null_value);

    for c_orgs in c_orgs_cur(ll_view_type, ll_inst_id, ll_org_id)
    loop
      println('region-orgs loop in');
      --insert orgs for regions
      insert into msc_form_query (query_id, creation_date, created_by, last_updated_by, last_update_date,
        number1, number2, number3, char1, number4)
      values (p_org_query_id, sysdate, -1, -1, sysdate,
        c_orgs.region_id, c_orgs.inst_id, c_orgs.org_id, c_orgs.org_code, c_orgs.inventory_item_id);

      --insert orgs for global
      insert into msc_form_query (query_id, creation_date, created_by, last_updated_by, last_update_date,
        number1, number2, number3, char1, number4)
      values (p_org_query_id, sysdate, -1, -1, sysdate,
        c_global_reg_type, c_orgs.inst_id, c_orgs.org_id, c_orgs.org_code, c_orgs.inventory_item_id);

      --insert orgs for local
      insert into msc_form_query (query_id, creation_date, created_by, last_updated_by, last_update_date,
        number1, number2, number3, char1, number4)
      values (p_org_query_id, sysdate, -1, -1, sysdate,
        c_local_reg_type, c_orgs.inst_id, c_orgs.org_id, c_orgs.org_code, c_orgs.inventory_item_id);
    end loop;

    println(' p_org_query_id p_region_query_id '||p_org_query_id||' - '||p_region_query_id);
    println('flushRegsOrgsIntoMfq out');
  end flushRegsOrgsIntoMfq;

  function flushOrgsIntoMfq(p_query_id number, p_row_index number, p_org_type number) return number is
    l_query_id number;

    cursor c_orgs_cur is
    select distinct
      to_number(null) org_list_id,
      to_char(null) org_list,
      mtp.sr_instance_id inst_id,
      mtp.sr_tp_id org_id,
      msc_get_name.org_code(mtp.sr_tp_id, mtp.sr_instance_id) org_code,
      mtp.sr_tp_id sort_column
    from msc_trading_partners mtp,
      msc_analysis_query maq
    where maq.query_id = p_query_id
      and maq.row_index = p_row_index
      and mtp.sr_instance_id = maq.inst_id
      and mtp.sr_tp_id = maq.org_id
      and mtp.partner_type = 3
      and p_org_type = c_org_view
    union all
    select distinct
      mpq.query_id org_list_id,
      mpq.query_name org_list,
      mpt.source_type inst_id,
      mpt.object_type org_id,
      msc_get_name.org_code(mpt.object_type, mpt.source_type) org_code,
      mpt.sequence_id sort_column
    from msc_pq_types mpt,
      msc_personal_queries mpq,
      msc_analysis_query maq
    where maq.query_id = p_query_id
      and maq.row_index = p_row_index
      and mpq.query_id = maq.org_list_id
      and mpq.query_id  = mpt.query_id
      and p_org_type = c_org_list_view
    order by 6;

  begin
    l_query_id := getNewFormQueryId;
    for c_orgs in c_orgs_cur
    loop
      println('inserting +');
      insert into msc_form_query (query_id, creation_date, created_by, last_updated_by, last_update_date,
        number1, char1, number2, number3, char4, number4)
      values (l_query_id, sysdate, -1, -1, sysdate,
        c_orgs.org_list_id, c_orgs.org_list, c_orgs.inst_id, c_orgs.org_id, c_orgs.org_code, c_orgs.sort_column);
    end loop;
    return l_query_id;
  end flushOrgsIntoMfq;

  function flushChainIntoMfq(p_query_id number, p_plan_id number,
    p_item_view_type number, p_item_id number) return number is

   cursor c_sschain_cur is
   select to_number(null) top_item_id,
     to_char(null) top_item_name,
     inventory_item_id item_id,
     item_name,
     1 sort_column
   from msc_items
   where inventory_item_id = p_item_id
     and p_item_view_type = c_item_view
   union all
   select distinct
     p_item_id top_item_id,
     msc_get_name.item_name(p_item_id,null, null, null) top_item_name,
     decode(p_item_id, prime_item_id, lower_item_id, higher_item_id) item_id,
     msc_get_name.item_name(decode(p_item_id, prime_item_id, lower_item_id, higher_item_id),null, null, null) item_name,
     1 sort_column
   from msc_item_substitutes
   where plan_id = p_plan_id
     and (prime_item_id = p_item_id or (higher_item_id = highest_item_id and higher_item_id = p_item_id))
     and relationship_type = c_mis_supersession_type
     and p_item_view_type = c_prime_view
     and inferred_flag = 2
     and forward_rule = 1
/*
   start with prime_item_id = p_item_id
        --and highest_item_id = higher_item_id
      connect by nocycle higher_item_id = prior lower_item_id
        and plan_id = prior plan_id
        and relationship_type = prior relationship_type
	and prime_item_id = prior prime_item_id
	and inferred_flag = prior inferred_flag
        and forward_rule = prior forward_rule
*/ --commented since where cl is enough to fetch this info
   union all
   select distinct
     highest_item_id top_item_id,
     msc_get_name.item_name(highest_item_id,null, null, null) top_item_name,
     lower_item_id item_id,
     msc_get_name.item_name(lower_item_id,null, null, null) item_name,
     1 sort_column
   from msc_item_substitutes
   where plan_id = p_plan_id
     and relationship_type = c_mis_supersession_type
     and p_item_view_type = c_supersession_view
     and highest_item_id = p_item_id
     and inferred_flag = 2
     and forward_rule = 1
/*
   start with highest_item_id = p_item_id
     and inferred_flag = 2
     and highest_item_id = higher_item_id
     --and highest_item_id = higher_item_id
      connect by nocycle higher_item_id = prior lower_item_id
        and plan_id = prior plan_id
        and relationship_type = prior relationship_type
	and inferred_flag = prior inferred_flag
        and forward_rule = prior forward_rule
*/ --commented since where cl is enough to fetch this info
      order by sort_column desc;
      --pabram..need to change.. need to add effective_date logic also

     l_query_id number;
     l_found boolean := false;
     l_item_name varchar2(300);
  begin
    l_query_id := getNewFormQueryId;
    for c_sschain in c_sschain_cur
    loop
      println(' populating into chain '||c_sschain.item_name);
      insert into msc_form_query (query_id, creation_date, created_by, last_updated_by, last_update_date, number1, char1, number2, char2, number3)
      values (l_query_id, sysdate, -1, -1, sysdate, c_sschain.top_item_id, c_sschain.top_item_name, c_sschain.item_id, c_sschain.item_name,
      c_sschain.sort_column);
      if (c_sschain.item_id = p_item_id) then
        l_found := true;
      end if;
    end loop;

    if (p_item_view_type in (c_prime_view, c_supersession_view) ) then
      if  (l_found = false) then
        l_item_name := msc_get_name.item_name(p_item_id, null, null, null);
        insert into msc_form_query (query_id, creation_date, created_by, last_updated_by, last_update_date, number1, char1, number2, char2, number3)
        values (l_query_id, sysdate, -1, -1, sysdate, p_item_id, l_item_name, p_item_id, l_item_name, 1);
      end if;
    end if;
    return l_query_id;
  end flushChainIntoMfq;

function createHistCalInMfq(p_start_date date, p_end_date date) return number is
  l_query_id number;

  l_first_day date;
  l_last_day date;

  l_month number;
  l_year number;
  l_date_index number := 1;

  l_start_date date;
  l_end_date date;
begin
  l_query_id := getNewFormQueryId;
  l_start_date := trunc(p_start_date, 'MM');
  l_end_date :=  trunc(p_end_date, 'MM');

  l_month := to_char(l_start_date, 'MM');
  l_year := to_char(l_start_date, 'YYYY');
  loop
    l_first_day := to_date( '01/' || l_month || '/' ||l_year, 'DD/MM/YYYY');
    l_last_day := last_day(l_first_day);

    insert into msc_form_query (query_id, creation_date, created_by, last_updated_by, last_update_date,
      date1, date2, number1)
    values (l_query_id, sysdate, -1, -1, sysdate, l_first_day, l_last_day, l_date_index);

    if (l_last_day > l_end_date) then
      exit;
    end if;
    if (l_month <12) then
      l_month := l_month + 1;
    else
      l_month := 1;
      l_year := l_year + 1;
    end if;
    l_date_index := l_date_index + 1;
  end loop;
  return l_query_id;
end createHistCalInMfq;

  procedure spreadTableMessages(p_out_data in out nocopy msc_sda_utils.maxCharTbl) is
    cursor c_item_prompts_cur (p_folder_object varchar2) is
    select field_type,
      field_name,
      field_prompt,
      decode(folder_object,
	c_item_folder, nvl(group_by,2),
	1) default_flag
    from msc_criteria
    where folder_object = p_folder_object
       and field_name <> 'PRE_POSITION_INVENTORY'
       order by to_number(field_type);

    l_one_record varchar2(500);
    l_row_count number := 0;
    l_out_data_index number := 1;
  begin
    -- items column prompts
    for c_item_prompts in c_item_prompts_cur(c_item_folder) loop
      l_one_record := c_item_prompts.field_type
        || c_field_seperator || c_item_prompts.field_name
        || c_field_seperator || c_item_prompts.field_prompt
        || c_field_seperator || c_item_prompts.default_flag;

      l_row_count := l_row_count + 1;
      if (l_row_count = 1) then
        l_one_record := c_sdview_items_messages || c_bang_separator || c_record_seperator || l_one_record;
      end if;
      msc_sda_utils.addRecordToOutStream(l_one_record, l_out_data_index, p_out_data);
    end loop;

   l_row_count := 0;

    -- comments column prompts
    for c_item_prompts in c_item_prompts_cur(c_comments_folder) loop
      l_one_record := c_item_prompts.field_type
        || c_field_seperator || c_item_prompts.field_name
        || c_field_seperator || c_item_prompts.field_prompt
        || c_field_seperator || c_item_prompts.default_flag;

      l_row_count := l_row_count + 1;
      if (l_row_count = 1) then
        l_one_record := c_sdview_comments_messages || c_bang_separator || c_record_seperator || l_one_record;
      end if;
      msc_sda_utils.addRecordToOutStream(l_one_record, l_out_data_index, p_out_data);
    end loop;

   l_row_count := 0;

    -- excp_summary column prompts
    for c_item_prompts in c_item_prompts_cur(c_excp_folder) loop
      l_one_record := c_item_prompts.field_type
        || c_field_seperator || c_item_prompts.field_name
        || c_field_seperator || c_item_prompts.field_prompt
        || c_field_seperator || c_item_prompts.default_flag;

      l_row_count := l_row_count + 1;
      if (l_row_count = 1) then
        l_one_record := c_sdview_excp_messages || c_bang_separator || c_record_seperator || l_one_record;
      end if;
      msc_sda_utils.addRecordToOutStream(l_one_record, l_out_data_index, p_out_data);
    end loop;
  end spreadTableMessages;

  procedure getCommentsData(p_plan_id number, p_chain_query_id number,
    p_out_data in out nocopy msc_sda_utils.maxCharTbl, p_stream_label varchar2) is

    cursor c_comments_cur is
    select distinct mun.note_id,
      nvl(mun.last_update_date, mun.creation_date) comment_date,
      msc_get_name.item_name(mun.inventory_item_id, null, null, null) item_name,
      substr(mun.note_text1,1,80) comment_text
    from msc_user_notes mun,
      msc_form_query mfq
    where
      mun.entity_type = c_comment_entity_type
      and mun.inventory_item_id  in (mfq.number1, number2)
      and mfq.query_id = p_chain_query_id
      order by 2 desc;
    --where mun.plan_id = p_plan_id

    l_one_record varchar2(32000);
    l_out_data_index number := 1;
    l_row_count number := 0;
  begin
    println('getCommentsData in');
      for c_comments in c_comments_cur
      loop
         l_row_count := l_row_count + 1;
         l_one_record := to_char(c_comments.note_id)
	    || c_field_seperator || to_char(c_comments.comment_date, c_date_format)
	    || c_field_seperator || msc_sda_utils.escapeSplChars(c_comments.comment_text)
	    || c_field_seperator || msc_sda_utils.escapeSplChars(c_comments.item_name);
        if (l_row_count = 1) then
          l_one_record := p_stream_label || c_bang_separator || c_record_seperator || l_one_record;
	end if;
        msc_sda_utils.addRecordToOutStream(l_one_record, l_out_data_index, p_out_data);
      end loop;
    println('getCommentsData out');
  end getCommentsData;

function getPreference(p_plan_id number, p_plan_type number, p_preference in varchar2) return varchar2 is
  l_pref_value number;
  l_def_pref_id number;

  cursor c_pref_id is
  select preference_id
  from msc_user_preferences
  where default_flag =1
  and user_id = fnd_global.user_id
  and nvl(plan_type,-1) = p_plan_type;

 begin
    open c_pref_id;
    fetch c_pref_id into l_def_pref_id;
    close c_pref_id;
    if (l_def_pref_id is null) then
      l_def_pref_id := msc_get_name.get_default_pref_id(fnd_global.user_id);
    end if;

    l_pref_value:= msc_get_name.get_preference(p_preference,l_def_pref_id, p_plan_type);
    return l_pref_value;
  end getPreference;


  procedure getItemsData(p_plan_id number, p_org_query_id number, p_chain_query_id number, p_out_data in out nocopy maxCharTbl) is
    l_category_set_id number;

  cursor c_item_cur is
  select distinct to_char(sr_instance_id)||'-'||to_char(organization_id)||'-'||to_char(inventory_item_id) node_id,
    item_segments, organization_code, description, planner_code,
    nettable_inventory_quantity, nonnettable_inventory_quantity, buyer_name,
    mrp_planning_code_text, critical_component_flag critical_component_flag,
    wip_supply_type_text,
    bom_item_type_text, end_assembly_pegging_text, base_model,
    category, category_desc, product_family_item, product_family_item_desc,
    planning_exception_set, msc_get_name.lookup_meaning('SYS_YES_NO', nvl(repetitive_type,2)) repetitive_type,
    standard_cost, carrying_cost,
    uom_code, planning_time_fence_date, planning_time_fence_days,
    inventory_use_up_date, planning_make_buy_code_text,
    ato_forecast_control_text, shrinkage_rate, preprocessing_lead_time,
    full_lead_time, postprocessing_lead_time, leadtime_variability,
    fixed_lead_time, variable_lead_time, fixed_order_quantity,
    fixed_lot_multiplier, minimum_order_quantity, maximum_order_quantity,
    safety_stock_days, safety_stock_percent, fixed_days_supply,
    msc_get_name.lookup_meaning('SYS_YES_NO', rounding_control_type) rounding_control_type,
    effectivity_control_type, abc_class_name, selling_price,
    margin, average_discount, net_selling_price, service_level,
    demand_time_fence_days, demand_time_fence_date, safety_stock_code,
    atp_flag, atp_components_flag, drp_planned, weight_uom,
    unit_weight, volume_uom, pip_flag, msc_get_name.lookup_meaning('SYS_YES_NO', create_supply_flag) create_supply_flag,
    substitution_window,
    convergence_text, divergence_text, continous_transfer_text, exclude_from_budget,
    days_tgt_inv_window, days_max_inv_window, days_tgt_inv_supply,
    days_max_inv_supply, shelf_life_days, release_time_fence_days,
    min_shelf_life_days, unit_volume, to_number(null) max_early_days,
   demand_fulfillment_lt, end_of_life_date, fcst_rule_for_demands_text,
   fcst_rule_for_returns_text, interarrival_time, life_time_buy_date,
   msc_get_name.lookup_meaning('SYS_YES_NO', decode(preposition_point,'Y','1','2')) preposition_point,
   repair_cost,
   repair_lead_time, repair_program_text, repair_yield, std_dmd_over_horizon,
   repetitive_planning_flag_text,
    mfq.number3,
    msiv.ROP_SAFETY_STOCK,
    msiv.COMPUTE_SS,
    msiv.COMPUTE_EOQ,
    msiv.ORDER_COST,
    msiv.MAX_USAGE_FACTOR
    from msc_system_items_sc_v msiv,
      msc_form_query mfq,  --items
      msc_form_query mfq1 --orgs
    where plan_id = p_plan_id
      and category_set_id = l_category_set_id
      and inventory_item_id  in (mfq.number2) --, number1)
      and mfq.query_id = p_chain_query_id
      and mfq1.query_id = p_org_query_id
      --and nvl(mfq1.number1,1) >0
      and mfq1.number2 = msiv.sr_instance_id
      and mfq1.number3 = msiv.organization_id
    order by msiv.organization_code, mfq.number3;


    l_one_record varchar2(32000);
    l_out_data_index number := 1;
    l_row_count number := 0;

  begin
    println('getItemsData in');

    --6726798 bugfix
    l_category_set_id := getPreference(p_plan_id, 8, 'CATEGORY_SET_ID');

    for c_item in c_item_cur loop

     l_one_record := c_item.node_id || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.item_segments) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.organization_code) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.description) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.planner_code) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.nettable_inventory_quantity) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.nonnettable_inventory_quantity) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.buyer_name) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.mrp_planning_code_text) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.critical_component_flag) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.wip_supply_type_text) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.bom_item_type_text) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.end_assembly_pegging_text) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.base_model) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.category) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.category_desc) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.product_family_item) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.product_family_item_desc) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.planning_exception_set) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.repetitive_type) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.standard_cost) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.carrying_cost) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.uom_code) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.planning_time_fence_date) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.planning_time_fence_days) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.inventory_use_up_date) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.planning_make_buy_code_text) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.ato_forecast_control_text) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.shrinkage_rate) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.preprocessing_lead_time) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.full_lead_time) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.postprocessing_lead_time) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.leadtime_variability) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.fixed_lead_time) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.variable_lead_time) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.fixed_order_quantity) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.fixed_lot_multiplier) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.minimum_order_quantity) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.maximum_order_quantity) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.safety_stock_days) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.safety_stock_percent) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.fixed_days_supply) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.rounding_control_type) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.effectivity_control_type) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.abc_class_name) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.selling_price) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.margin) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.average_discount) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.net_selling_price) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.service_level) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.demand_time_fence_days) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.demand_time_fence_date) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.safety_stock_code) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.atp_flag) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.atp_components_flag) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.drp_planned) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.weight_uom) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.unit_weight) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.volume_uom) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.pip_flag) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.create_supply_flag) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.substitution_window) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.convergence_text) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.divergence_text) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.continous_transfer_text) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.exclude_from_budget) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.days_tgt_inv_window) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.days_max_inv_window) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.days_tgt_inv_supply) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.days_max_inv_supply) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.shelf_life_days) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.release_time_fence_days) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.min_shelf_life_days) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.unit_volume) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.max_early_days) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.demand_fulfillment_lt) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(to_char(c_item.end_of_life_date, c_datetime_format)) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.fcst_rule_for_demands_text) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.fcst_rule_for_returns_text) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.interarrival_time) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(to_char(c_item.life_time_buy_date, c_datetime_format)) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.preposition_point) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.repair_cost) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.repair_lead_time) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.repair_program_text) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.repair_yield) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.std_dmd_over_horizon) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.repetitive_planning_flag_text) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.MAX_USAGE_FACTOR) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.COMPUTE_SS) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.COMPUTE_EOQ) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.ORDER_COST) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_item.ROP_SAFETY_STOCK);

       l_row_count := l_row_count + 1;

       if (l_row_count = 1) then
         l_one_record := c_sdview_items_data || c_bang_separator || c_record_seperator || l_one_record;
       end if;
       msc_sda_utils.addRecordToOutStream(l_one_record, l_out_data_index, p_out_data);
    end loop;
    println('getItemsData out');
  end getItemsData;

  procedure getExceptionsData(p_plan_id number, p_chain_query_id number, p_org_query_id number,
    p_out_data in out nocopy maxCharTbl) is

  cursor c_excp_summary_cur is
  select med.exception_type,
    msc_get_name.lookup_meaning('MRP_EXCEPTION_CODE_TYPE', med.exception_type) exception_type_text,
    count(*) excp_all_count,
    sum(decode(nvl(action_taken,2),2,1,0)) excp_no_count
  from msc_exception_details med,
    msc_form_query mfq, --items
    msc_form_query mfq1 --orgs
  where med.plan_id = p_plan_id
    and med.inventory_item_id = mfq.number2
    and mfq.query_id = p_chain_query_id
    and mfq1.query_id = p_org_query_id
    and nvl(mfq1.number1,1) >0
    and mfq1.number2 = med.sr_instance_id
    and mfq1.number3 = med.organization_id
  group by med.exception_type,
    msc_get_name.lookup_meaning('MRP_EXCEPTION_CODE_TYPE', med.exception_type)
   union all
   select -99 exception_type,
    msc_get_name.lookup_meaning('MSC_EXCEPTION_GROUP', 10) exception_type_text,
    count(*) excp_all_count,
    0 excp_no_count
  from msc_supplies ms,
    msc_system_items msi,
    msc_form_query mfq, --items
    msc_form_query mfq1 --orgs
  where ms.plan_id = p_plan_id
    and ms.inventory_item_id = mfq.number2
    and mfq.query_id = p_chain_query_id
    and mfq1.query_id = p_org_query_id
    and nvl(mfq1.number1,1) >0
    and mfq1.number2 = ms.sr_instance_id
    and mfq1.number3 = ms.organization_id
   and ms.plan_id = msi.plan_id
   and ms.sr_instance_id = msi.sr_instance_id
   and ms.organization_id = msi.organization_id
   and ms.inventory_item_id = msi.inventory_item_id
   and ( (ms.order_type = 13)
           or (ms.order_type = 5
	           and nvl(ms.implemented_quantity,0)+nvl(ms.quantity_in_process,0) < nvl(ms.firm_quantity,ms.new_order_quantity)
	     and (nvl(msi.lots_exist,0) <> 2 or ms.new_order_quantity =0)
	     and (((ms.source_organization_id <> ms.organization_id or ms.source_sr_instance_id <> ms.sr_instance_id or ms.source_supplier_id is not null)
			   and msi.purchasing_enabled_flag = 1)
	    or (ms.source_organization_id is null and ms.source_supplier_id is null and msi.planning_make_buy_code = 2 and msi.purchasing_enabled_flag = 1)
	    or (ms.source_organization_id = ms.organization_id and ms.source_sr_instance_id = ms.sr_instance_id and msi.build_in_wip_flag = 1)
	    or (ms.source_organization_id is null and ms.source_supplier_id is null and msi.planning_make_buy_code = 1 and msi.build_in_wip_flag = 1))
	    )
	  )
  group by -99,
    msc_get_name.lookup_meaning('MSC_EXCEPTION_GROUP', 10);
  --pabram.need to add recommendations

    l_one_record varchar2(32000);
    l_out_data_index number := 1;
    l_row_count number := 0;
  begin
    println('getExceptionsData in');
    for c_excp_summary in c_excp_summary_cur loop
      l_one_record :=
        msc_sda_utils.escapeSplChars(p_chain_query_id||'-'||c_excp_summary.exception_type) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_excp_summary.exception_type_text) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_excp_summary.excp_all_count) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_excp_summary.excp_no_count);

       l_row_count := l_row_count + 1;
       if (l_row_count = 1) then
         l_one_record := c_sdview_excp_data || c_bang_separator || c_record_seperator || l_one_record;
       end if;
       msc_sda_utils.addRecordToOutStream(l_one_record, l_out_data_index, p_out_data);
    end loop;
    println('getExceptionsData out');
  end getExceptionsData;

  procedure getWorkSheetPrefData(p_out_data in out nocopy maxCharTbl, p_refresh_flag number) is
  cursor c_userpref_cur is
  select name, key, nvl(value, c_null_space) value
  from msc_analyze_preference
  where module = c_sda_pref_set
    and userid= fnd_global.user_id
  order by name, key;

    l_one_record varchar2(32000);
    l_out_data_index number := 1;
    l_row_count number := 0;
    l_stream_label varchar2(200);
  begin
    println('getWorkSheetPrefData in');

    if (p_refresh_flag = 1) then
      l_stream_label := c_sdview_prefset_data_ref;
    else
      l_stream_label := c_sdview_prefset_data;
    end if;
    for c_userpref in c_userpref_cur
    loop
      l_one_record :=
        msc_sda_utils.escapeSplChars(c_userpref.name) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_userpref.key) || c_field_seperator ||
       msc_sda_utils.escapeSplChars(c_userpref.value);

       l_row_count := l_row_count + 1;
       if (l_row_count = 1) then
         l_one_record := l_stream_label || c_bang_separator || c_record_seperator || l_one_record;
       end if;
       msc_sda_utils.addRecordToOutStream(l_one_record, l_out_data_index, p_out_data);
    end loop;
    println('getWorkSheetPrefData out');
  end getWorkSheetPrefData;

  procedure sendSDRowTypes(p_out_data IN OUT NOCOPY msc_sda_utils.maxCharTbl) is
    cursor c_sd_rowtypes_cur is
    select lookup_code, meaning
    from mfg_lookups
    where lookup_type = c_sdview_rowtype_lookup
    order by 1;
    l_one_record varchar2(32000) := null;
    l_token varchar2(1000);
    l_out_data_index number := 1;
    l_flag number; -- 0 or null - sum, 1 - avg, 2- use-last-record-in-bucket, 3 show min
    l_visible_flag number; -- 0 hide, 1 show
    l_total_row_flag number; -- 1 yes, 2 no
  begin
      for c_sd_rowtypes in c_sd_rowtypes_cur
      loop
         l_flag := 0;
	 l_visible_flag := 1;
	 l_total_row_flag := 2;

	 if (c_sd_rowtypes.lookup_code in (45) ) then
	   --safety stock qty
           l_flag := 1;
         end if;
	 if (c_sd_rowtypes.lookup_code in (31,32,44) ) then
           --31 Projected Available Balance
           --32 Projected On-hand
           --44 Projected Available Balance (Defective)
           l_flag := 2;
         end if;
	 if (c_sd_rowtypes.lookup_code in (26,28,29) ) then
	   --26 Safety Stock (Days of Supply)
	   --28 Projected Service Level
	   --29 Target Service Level
           l_flag := 3;
         end if;
	 if (c_sd_rowtypes.lookup_code in (24,26,27,28,29,30) ) then
           --24 Planned Warranty Orders
           --26 Safety Stock (Days of Supply)
           --27 Total Unconstrained Demand
           --28 Projected Service Level (%)
           --29 Target Service Level (%)
           --30 Maximum Level
	   l_visible_flag := 0;
	 end if;

	 if (c_sd_rowtypes.lookup_code in (4,7,8,9,25,27,36,43) ) then
           --4 Independent Demand
           --7 Dependent Demand
           --8 Other Demand
           --9 Total Demand
           --25 Total Supply
           --27 Total Unconstrained Demand
           --36 Total Defective Part Demand
           --43 Total Defective Supply
	   l_total_row_flag := 1;
	 end if;

         l_token := c_sd_rowtypes.lookup_code
	    || c_field_seperator || msc_sda_utils.escapeSplChars(c_sd_rowtypes.meaning)
	    || c_field_seperator || l_flag || c_field_seperator || l_visible_flag || c_field_seperator || l_total_row_flag;
        if (l_one_record is null) then
          l_one_record := c_sdview_rowtypes || c_bang_separator || c_sd_total_row_types || c_record_seperator || l_token;
	else
          l_one_record := l_one_record || c_record_seperator || l_token;
	end if;
      end loop;
      msc_sda_utils.addRecordToOutStream(l_one_record, l_out_data_index, p_out_data);
  end sendSDRowTypes;

  procedure sendFcstRowTypes(p_out_data IN OUT NOCOPY msc_sda_utils.maxCharTbl) is
    cursor c_fcst_rowtypes_cur is
    select lookup_code, meaning
    from mfg_lookups
    where lookup_type = c_fcstview_rowtype_lookup
    order by 1;
    l_one_record varchar2(32000) := null;
    l_token varchar2(1000);
    l_out_data_index number := 1;
    l_flag number; -- 0 - sum, 1 - avg, 2- use-last-record-in-bucket
    l_visible_flag number; -- 0 hide, 1 show
    l_total_row_flag number; -- 1 yes, 2 no
  begin
      for c_fcst_rowtypes in c_fcst_rowtypes_cur
      loop
         l_flag := 0;
         l_visible_flag := 1;
	 l_total_row_flag := 2;

	 if (c_fcst_rowtypes.lookup_code in (8,13,16)) then
           --8 Best Fit forecast
	   --13 Returns Best Fit forecast
           l_visible_flag := 0;
	 end if;
	 --6657610 bugfix,

	 if (c_fcst_rowtypes.lookup_code in (1,9)) then
           --1 Total Forecast
           --9 Total Returns Forecast
           l_total_row_flag := 1;
	 end if;

         l_token := c_fcst_rowtypes.lookup_code
	    || c_field_seperator || msc_sda_utils.escapeSplChars(c_fcst_rowtypes.meaning)
	    || c_field_seperator || l_flag || c_field_seperator || l_visible_flag || c_field_seperator || l_total_row_flag;
        if (l_one_record is null) then
          l_one_record := c_fcstview_rowtypes || c_bang_separator || c_fcst_total_row_types || c_record_seperator || l_token;
	else
          l_one_record := l_one_record || c_record_seperator || l_token;
	end if;
      end loop;
      msc_sda_utils.addRecordToOutStream(l_one_record, l_out_data_index, p_out_data);
  end sendFcstRowTypes;

  procedure sendHistRowTypes(p_out_data IN OUT NOCOPY msc_sda_utils.maxCharTbl) is
    cursor c_hist_rowtypes_cur is
    select lookup_code, meaning
    from mfg_lookups
    where lookup_type = c_histview_rowtype_lookup
    order by 1;
    l_one_record varchar2(32000) := null;
    l_token varchar2(1000);
    l_out_data_index number := 1;
    l_flag number; -- 0 - sum, 1 - avg, 2- use-last-record-in-bucket
    l_visible_flag number; -- 0 hide, 1 show
    l_total_row_flag number; -- 1 yes, 2 no
  begin
      for c_hist_rowtypes in c_hist_rowtypes_cur
      loop
         l_flag := 0;
         l_visible_flag := 1;
	 l_total_row_flag := 2;
         l_token := c_hist_rowtypes.lookup_code
	    || c_field_seperator || msc_sda_utils.escapeSplChars(c_hist_rowtypes.meaning)
	    || c_field_seperator || l_flag || c_field_seperator || l_visible_flag || c_field_seperator || l_total_row_flag;
        if (l_one_record is null) then
          l_one_record := c_histview_rowtypes || c_bang_separator || c_hist_total_row_types || c_record_seperator || l_token;
	else
          l_one_record := l_one_record || c_record_seperator || l_token;
	end if;
      end loop;
      msc_sda_utils.addRecordToOutStream(l_one_record, l_out_data_index, p_out_data);
  end sendHistRowTypes;

  function getTokenizedMsg(p_msg varchar2) return varchar2 is
    l_msg_text varchar2(300);
  begin
    FND_MESSAGE.set_name('MSC', p_msg);
    l_msg_text:= FND_MESSAGE.get;
    if (l_msg_text is null) then
      l_msg_text:= p_msg|| c_field_seperator || p_msg;
    else
      l_msg_text:= p_msg|| c_field_seperator || msc_sda_utils.escapeSplChars(l_msg_text);
    end if;
    return l_msg_text;
  end getTokenizedMsg;

 procedure addMessages(p_msg varchar2, p_out_data_index in out nocopy number,
   p_out_data IN OUT NOCOPY msc_sda_utils.maxCharTbl) is
    l_one_record varchar2(1200) := null;
    l_token varchar2(1000);
 begin
   l_one_record := getTokenizedMsg(p_msg);
   msc_sda_utils.addRecordToOutStream(l_one_record, p_out_data_index, p_out_data);
 end addMessages;

  procedure sendNlsMessages(p_out_data IN OUT NOCOPY msc_sda_utils.maxCharTbl) is
    l_one_record varchar2(32000) := null;
    l_token varchar2(1000);
    l_out_data_index number := 1;
  begin
	 l_token := getTokenizedMsg('MENU_ORDER_DETAILS');
         l_one_record := c_sdview_nls_messages || c_bang_separator || c_record_seperator || l_token;
         msc_sda_utils.addRecordToOutStream(l_one_record, l_out_data_index, p_out_data);

	 addMessages('MENU_FORECAST_RULE', l_out_data_index, p_out_data);
	 addMessages('MENU_CALENDAR', l_out_data_index, p_out_data);
 	 addMessages('MENU_SOURCES', l_out_data_index, p_out_data);
 	 addMessages('MENU_SUPPLY_CHAIN_BILL', l_out_data_index, p_out_data);
 	 addMessages('MENU_DESTINATION', l_out_data_index, p_out_data);
 	 addMessages('MENU_SUPPLY_CHAIN', l_out_data_index, p_out_data);
	 addMessages('PROMPT_ADD_NEW_COMMENT', l_out_data_index, p_out_data);
	 addMessages('MENU_EXCP_ALL', l_out_data_index, p_out_data);
	 addMessages('MENU_EXCP_ACTION_TAKEN', l_out_data_index, p_out_data);
	 addMessages('MENU_EXCP_NO_ACTION', l_out_data_index, p_out_data);
	 addMessages('LABEL_WORKSHEET_PREF', l_out_data_index, p_out_data);
	 addMessages('DLG_TITLE_GRAPH', l_out_data_index, p_out_data);
	 addMessages('DLG_MSG_BAD_GRID_SEL', l_out_data_index, p_out_data);
	 addMessages('MENU_HIDE_COLUMN', l_out_data_index, p_out_data);
	 addMessages('MENU_CHOOSE_COLUMNS', l_out_data_index, p_out_data);
	 addMessages('DLG_TITLE_CHOOSE_COLUMNS', l_out_data_index, p_out_data);
	 addMessages('BTN_LABEL_OK', l_out_data_index, p_out_data);
	 addMessages('BTN_LABEL_CANCEL', l_out_data_index, p_out_data);
	 addMessages('LBL_NOT_ENOUGH_DATA', l_out_data_index, p_out_data);
	 addMessages('GRAPH_ROW_TYPE_PREF', l_out_data_index, p_out_data);
	 addMessages('GRAPH_SEL_ROWTYPES', l_out_data_index, p_out_data);
	 addMessages('GRAPH_AVAIL_ROWTYPES', l_out_data_index, p_out_data);
	 addMessages('GRAPH_BTN_LABEL_REFRESH', l_out_data_index, p_out_data);
	 addMessages('GRAPH_TIME_INTERVAL', l_out_data_index, p_out_data);
	 addMessages('GRAPH_ITEMS', l_out_data_index, p_out_data);
	 addMessages('GRAPH_CHART_TYPE', l_out_data_index, p_out_data);
	 addMessages('GRAPH_BAR', l_out_data_index, p_out_data);
	 addMessages('GRAPH_LINE', l_out_data_index, p_out_data);
	 addMessages('GRAPH_COMBO', l_out_data_index, p_out_data);
	 addMessages('GRAPH_LEGEND', l_out_data_index, p_out_data);
	 addMessages('GRAPH_LABEL_SHOW', l_out_data_index, p_out_data);
	 addMessages('GRAPH_LABEL_HIDE', l_out_data_index, p_out_data);
	 addMessages('GRAPH_PREF', l_out_data_index, p_out_data);
	 addMessages('GRID_LABEL_PAST', l_out_data_index, p_out_data);
	 addMessages('MSC_FORECAST_RULE_RETURNS', l_out_data_index, p_out_data);
	 addMessages('MSC_ITEM_FAILURE_RATES', l_out_data_index, p_out_data);
	 addMessages('PROMPT_NO_TABLEDATA_ROWS', l_out_data_index, p_out_data);
	 addMessages('GRAPH_BTN_LABEL_CLOSE', l_out_data_index, p_out_data);
	 addMessages('SDA_SAVE_FOLDER', l_out_data_index, p_out_data);
	 addMessages('MSC_EC_SAVE_SETTINGS', l_out_data_index, p_out_data);
  end sendNlsMessages;

  procedure set_shuttle_from_to(p_lookup_type varchar2, p_lookup_code_list varchar2,
    p_from_list out nocopy varchar2, p_to_list out nocopy varchar2) is

    TYPE lCurTyp IS REF CURSOR;
    theCursor lCurTyp;

    l_token varchar2(500);
    l_one_record varchar2(32000);

    l_sql_stmt varchar2(500);
    l_sql_stmt1 varchar2(200);
    l_sql_stmt2 varchar2(200);
    l_sql_stmt3 varchar2(200);
    l_sql_stmt4 varchar2(200);
    l_lookup_code number;
    l_meaning varchar2(250);
  begin
    l_sql_stmt1 := 'select lookup_code, meaning from mfg_lookups where lookup_type = :1 ';
    l_sql_stmt4 := ' and lookup_code not in (8,13,16) ';
    l_sql_stmt2 := 'and lookup_code not in ('|| p_lookup_code_list ||') order by 1';
    l_sql_stmt3 := 'and lookup_code in ('|| p_lookup_code_list ||') order by 1';

    if (p_lookup_type = c_fcstview_rowtype_lookup) then
      l_sql_stmt := l_sql_stmt1||l_sql_stmt4||l_sql_stmt2;
    else
      l_sql_stmt := l_sql_stmt1||l_sql_stmt2;
    end if;
    open theCursor for l_sql_stmt using p_lookup_type;
    loop
      fetch theCursor into l_lookup_code, l_meaning;
      exit when theCursor%notfound;
      l_token := l_lookup_code || c_field_seperator || msc_sda_utils.escapeSplChars(l_meaning);
        if (l_one_record is null) then
          l_one_record := SET_FROM_LIST || c_bang_separator || l_token;
	else
          l_one_record := l_one_record || c_record_seperator || l_token;
	end if;
    end loop;
    close theCursor;
    p_from_list := l_one_record;

    l_one_record := null;
    if (p_lookup_type = c_fcstview_rowtype_lookup) then
      l_sql_stmt := l_sql_stmt1||l_sql_stmt4||l_sql_stmt3;
    else
      l_sql_stmt := l_sql_stmt1||l_sql_stmt3;
    end if;
    open theCursor for l_sql_stmt using p_lookup_type;
    loop
      fetch theCursor into l_lookup_code, l_meaning;
      exit when theCursor%notfound;
      l_token := l_lookup_code || c_field_seperator || msc_sda_utils.escapeSplChars(l_meaning);
        if (l_one_record is null) then
          l_one_record := SET_TO_LIST || c_bang_separator || l_token;
	else
          l_one_record := l_one_record || c_record_seperator || l_token;
	end if;
    end loop;
    close theCursor;
    p_to_list := l_one_record;
  end set_shuttle_from_to;

  procedure save_item_folder(p_folder_name varchar, p_folder_value varchar, p_default_flag number, p_public_flag number) is
    pragma autonomous_transaction;
    cursor c_count (p_module_name varchar2, p_name varchar) is
    select count(*)
    from msc_analyze_preference
    where module = p_module_name
      and name = p_name;

    l_temp number;
    l_default_flag number := nvl(p_default_flag,2);
    l_public_flag number := nvl(p_public_flag,2);
  begin
      commit;

      open c_count(c_sda_save_item_folder, p_folder_name);
      fetch c_count into l_temp;
      close c_count;

      if (l_temp <> 0) then
        update msc_analyze_preference
	set defaultset = to_char(l_default_flag),
	  public_flag = l_public_flag,
	  value = p_folder_value
	where name = p_folder_name
	  and module = c_sda_save_item_folder;
      else
        insert into msc_analyze_preference
        (userid, name, module, key, value,  defaultset, public_flag,
          last_update_date, last_updated_by, creation_date, created_by, last_update_login)
        values (fnd_global.user_id, p_folder_name, c_sda_save_item_folder, c_sda_save_item_folder, p_folder_value,
	  to_char(l_default_flag), l_public_flag,
          sysdate, -1, sysdate, -1, -1);
      end if;
      commit;
  end save_item_folder;

  procedure update_close_settings (p_event varchar2, p_event_list varchar2) is
    pragma autonomous_transaction;

    cursor c_count (p_module_name varchar2) is
    select count(*)
    from msc_analyze_preference
    where module = p_module_name
      and userid = fnd_global.user_id;
    l_temp number;

  begin
    commit;
/*
    if (p_event = c_sda_save_item_folder) then
      open c_count(c_sda_save_item_folder);
      fetch c_count into l_temp;
      close c_count;

      if (l_temp <> 0) then
        delete from msc_analyze_preference
        where module = c_sda_save_item_folder
          and userid = fnd_global.user_id;
      end if;

      insert into msc_analyze_preference
        (userid, name, module, key, value,  defaultset,
        last_update_date, last_updated_by, creation_date, created_by, last_update_login)
      values (fnd_global.user_id, c_sda_save_item_folder, c_sda_save_item_folder, c_sda_save_item_folder, p_event_list, 'N',
        sysdate, -1, sysdate, -1, -1);
    end if;
*/

    if (p_event = c_sda_save_settings) then
      open c_count(c_sda_save_settings);
      fetch c_count into l_temp;
      close c_count;

      if (l_temp <> 0) then
        delete from msc_analyze_preference
        where module = c_sda_save_settings
          and userid = fnd_global.user_id;
      end if;

      insert into msc_analyze_preference
        (userid, name, module, key, value,  defaultset,
        last_update_date, last_updated_by, creation_date, created_by, last_update_login)
      values (fnd_global.user_id, c_sda_save_settings, c_sda_save_settings, c_sda_save_settings, p_event_list, 'N',
        sysdate, -1, sysdate, -1, -1);
    end if;
    commit;
  end update_close_settings;

  procedure send_close_settings(p_item_folder_save_list out nocopy varchar2,
    p_save_settings_list out nocopy varchar2) is

    cursor c_pref (p_module_name varchar2) is
    select value
    from msc_analyze_preference
    where module = p_module_name
      and userid = fnd_global.user_id;
  begin
    open c_pref(c_sda_save_item_folder);
    fetch c_pref into p_item_folder_save_list;
    close c_pref;
    if (p_item_folder_save_list is not null) then
      p_item_folder_save_list := c_sda_save_item_folder  || c_bang_separator || c_record_seperator || p_item_folder_save_list;
    end if;

    open c_pref(c_sda_save_settings);
    fetch c_pref into p_save_settings_list;
    close c_pref;
    if (p_save_settings_list is not null) then
      p_save_settings_list := c_sda_save_settings  || c_bang_separator || p_save_settings_list;
    end if;
  end send_close_settings;

  procedure update_pref_set (p_name varchar2, p_desc varchar2,
    p_days number, p_weeks number, p_periods number,
    p_factor number, p_decimal_places number,
    p_sd_row_list varchar2, p_fcst_row_list varchar2) is
    pragma autonomous_transaction;

    cursor c_count is
    select count(*)
    from msc_analyze_preference
    where module = c_sda_pref_set
      and name = p_name;
    l_temp number;
  begin
      commit;
      open c_count;
      fetch c_count into l_temp;
      close c_count;

      if (l_temp = 0) then
	insert into msc_analyze_preference
	(userid, name, module, key, value,  defaultset,
	  last_update_date, last_updated_by, creation_date, created_by, last_update_login)
	values (fnd_global.user_id, p_name, c_sda_pref_set, c_keys_days, p_days, 'N',
	  sysdate, -1, sysdate, -1, -1);

	insert into msc_analyze_preference
	(userid, name, module, key, value,  defaultset,
	  last_update_date, last_updated_by, creation_date, created_by, last_update_login)
	values (fnd_global.user_id, p_name, c_sda_pref_set, c_keys_weeks, p_weeks, 'N',
	  sysdate, -1, sysdate, -1, -1);

	insert into msc_analyze_preference
	(userid, name, module, key, value,  defaultset,
	  last_update_date, last_updated_by, creation_date, created_by, last_update_login)
	values (fnd_global.user_id, p_name, c_sda_pref_set, c_keys_periods, p_periods, 'N',
	  sysdate, -1, sysdate, -1, -1);

	insert into msc_analyze_preference
	(userid, name, module, key, value,  defaultset,
	  last_update_date, last_updated_by, creation_date, created_by, last_update_login)
	values (fnd_global.user_id, p_name, c_sda_pref_set, c_keys_factor, p_factor, 'N',
	  sysdate, -1, sysdate, -1, -1);

	insert into msc_analyze_preference
	(userid, name, module, key, value,  defaultset,
	  last_update_date, last_updated_by, creation_date, created_by, last_update_login)
	values (fnd_global.user_id, p_name, c_sda_pref_set, c_keys_decimals, p_decimal_places, 'N',
	  sysdate, -1, sysdate, -1, -1);

	insert into msc_analyze_preference
	(userid, name, module, key, value,  defaultset,
	  last_update_date, last_updated_by, creation_date, created_by, last_update_login)
	values (fnd_global.user_id, p_name, c_sda_pref_set, c_keys_sd, p_sd_row_list, 'N',
	  sysdate, -1, sysdate, -1, -1);

	insert into msc_analyze_preference
	(userid, name, module, key, value,  defaultset,
	  last_update_date, last_updated_by, creation_date, created_by, last_update_login)
	values (fnd_global.user_id, p_name, c_sda_pref_set, c_keys_fcst, p_fcst_row_list, 'N',
	  sysdate, -1, sysdate, -1, -1);
      else
        update msc_analyze_preference
          set value = p_days
        where module = c_sda_pref_set and name = p_name and key = c_keys_days;

        update msc_analyze_preference
          set value = p_weeks
        where module = c_sda_pref_set and name = p_name and key = c_keys_weeks;

        update msc_analyze_preference
          set value = p_periods
        where module = c_sda_pref_set and name = p_name and key = c_keys_periods;

        update msc_analyze_preference
          set value = p_factor
        where module = c_sda_pref_set and name = p_name and key = c_keys_factor;

        update msc_analyze_preference
          set value = p_decimal_places
        where module = c_sda_pref_set and name = p_name and key = c_keys_decimals;

        update msc_analyze_preference
          set value = p_sd_row_list
        where module = c_sda_pref_set and name = p_name and key = c_keys_sd;

        update msc_analyze_preference
          set value = p_fcst_row_list
        where module = c_sda_pref_set and name = p_name and key = c_keys_fcst;
      end if;
      commit;
  end update_pref_set;

end MSC_SDA_UTILS;

/
