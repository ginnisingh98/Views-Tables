--------------------------------------------------------
--  DDL for Package Body QPR_DEAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_DEAL_PVT" AS
/* $Header: QPRPDPRB.pls 120.29 2008/06/20 11:13:31 vinnaray ship $ */

procedure debug_ext_log(text in varchar2, source_id in number) is
begin
   if source_id = 660 then
	oe_debug_pub.add(text);
   end if;
   if source_id = 697 then
      aso_debug_pub.ADD (text);
   end if;
end;

procedure log_debug(text varchar2) is
begin
  fnd_file.put_line( fnd_file.log, text);
end;

function get_number(p_char varchar2) return number is
begin
   if p_char is null then
      return(null);
   else
      return(to_number(p_char));
   end if;
exception
   when others then
		return(-99999);
end;

function get_volume_band(errbuf out nocopy varchar2,
                         retcode out nocopy varchar2,
                         p_inventory_item_id number,
                         p_ordered_qty number,
                         p_transf_group_id number) return varchar2 is

cursor c_vol_band(p_transf_group number) is
select a.LIMIT_DIM_FLAG limit_dim_flag, a.TO_DIM_CODE to_dim_code,
	a.TO_LEVEL_ID to_level_id,
	a.TO_VALUE to_value, a.TO_VALUE_DESC to_value_desc,
	b.limit_dim_level limit_dim_level,
	b.limit_dim_level_value limit_dim_level_value
from qpr_transf_headers_b a, qpr_transf_rules_b b
where a.transf_group_id = p_transf_group
and a.to_dim_code='VLB' and a.transf_header_id = b.transf_header_id
and p_ordered_qty between get_number(b.level_value_from)
and nvl(get_number(b.level_value_to),p_ordered_qty);

l_transf_group number;
l_insert_measure number:=0;
begin
  log_debug('Inside find_volume_band');

  if nvl(p_transf_group_id,0) = 0 then
    log_debug('No transformation group. Unable to determine volume band');
    return(null);
  end if;


  for c_vol_band_rec in c_vol_band(p_transf_group_id) loop
    if nvl(c_vol_band_rec.limit_dim_flag, 'N') = 'Y' then
      log_debug('Inside limit check');
      log_debug('Limit dim level :'||c_vol_band_rec.limit_dim_level);
      log_debug('Limit dim level value :'
                  ||c_vol_band_rec.limit_dim_level_value);

      if c_vol_band_rec.limit_dim_level = 'ITEM' and
      to_char(p_inventory_item_id) = c_vol_band_rec.limit_dim_level_value then
        return(c_vol_band_rec.to_value);
      end if;

      begin
        if c_vol_band_rec.limit_dim_level = 'PRODUCT_CATEGORY' then
          select 1 into l_insert_measure
          from qpr_dimension_values
          where  dim_code='PRD'
          and hierarchy_code='PRODUCTCATEGORY' and
          level2_value = c_vol_band_rec.limit_dim_level_value
          and level1_value = to_char(p_inventory_item_id)
          and rownum<2;
        elsif c_vol_band_rec.limit_dim_level = 'PRODUCT_FAMILY' then
          select 1 into l_insert_measure
          from qpr_dimension_values
          where  dim_code='PRD'
          and hierarchy_code='PRODUCTFAMILY' and
          level2_value = c_vol_band_rec.limit_dim_level_value
          and level1_value = to_char(p_inventory_item_id)
          and rownum<2;
        end if;
      exception
      when others then null;
      end;
      if l_insert_measure = 1 then
        log_debug('Volume band: '||c_vol_band_rec.to_value);
        return(c_vol_band_rec.to_value);
      end if;
    else
      log_debug('Volume band: '||c_vol_band_rec.to_value);
      return(c_vol_band_rec.to_value);
    end if;
  end loop;
  log_debug(' No Volume band');
  return(null);
exception
  When OTHERS then
    retcode := 2;
    errbuf := sqlerrm || dbms_utility.format_error_backtrace;
    raise;
    return(null);
end;

function check_lob(p_scope_id number,
                   p_instance_id number,
                   p_prd_id varchar2,
                   p_org_id varchar2,
                   p_rep_id varchar2,
                   p_cus_id varchar2,
                   p_geo_id varchar2,
                   p_chn_id varchar2,
                   p_psg_id varchar2) return boolean is

cursor c_scope_lines is
	select  a.level_id level_id, a.operator operator,
	a.scope_value scope_value, b.level_ppa_code level_ppa_code,
	b.level_seq_num level_seq_no, c.hierarchy_ppa_code hierarchy_code,
	c.dim_code dim_code
	from qpr_scopes a, qpr_hier_levels b, qpr_hierarchies_v c
	where b.price_plan_id= qpr_sr_util.g_datamart_tmpl_id
  and b.hierarchy_level_id=a.level_id
	and b.hierarchy_id = c.hierarchy_id
	and a.scope_id= p_scope_id
	and c.dim_code in ('ORG', 'PRD', 'CUS', 'GEO', 'REP', 'CHN', 'PSG')
	order by c.dim_code, b.level_seq_num;

cursor c_level_values(p_dim_code varchar2, p_hierarchy_code varchar2,
		p_instance_id number, p_level_seq_num number,
		p_scope_value varchar2, p_value varchar2)  is
	select 1
  from qpr_dimension_values
	where dim_code = p_dim_code
	and hierarchy_code = p_hierarchy_code
	and instance_id = p_instance_id
	and level1_value = p_value
	and (decode(p_level_seq_num, 1, level1_value,
				 2, level2_value,
				 3, level3_value,
				 4, level4_value,
				 5, level5_value,null)=p_scope_value)
  and rownum < 2;

l_org boolean := true;
l_prd boolean := true;
l_cus boolean := true;
l_geo boolean := true;
l_rep boolean := true;
l_chn boolean := true;
l_psg boolean := true;
i_org number := 0;
i_prd number := 0;
i_cus number := 0;
i_geo number := 0;
i_rep number := 0;
i_chn number := 0;
i_psg number := 0;

begin
  log_debug('In check_LOB');

  for c_scope_lines_rec in c_scope_lines loop
  log_debug('Rule found for dim '||c_scope_lines_rec.dim_code||'-'||c_scope_lines_rec.scope_value);

    if c_scope_lines_rec.dim_code = 'ORG' and i_org = 0 then
      l_org:=false;
      for c_level_values_rec in c_level_values(
                                  c_scope_lines_rec.dim_code,
                                  c_scope_lines_rec.hierarchy_code,
                                  p_instance_id,
                                  c_scope_lines_rec.level_seq_no,
                                  c_scope_lines_rec.scope_value,p_org_id) loop
        i_org := 1;
      end loop;
      if i_org = 1 then
        l_org:= true;
      end if;
    elsif c_scope_lines_rec.dim_code = 'PRD' and i_prd = 0 then
      l_prd:=false;
      for c_level_values_rec in c_level_values(
                                c_scope_lines_rec.dim_code,
                                c_scope_lines_rec.hierarchy_code,
                                p_instance_id,
                                c_scope_lines_rec.level_seq_no,
                                c_scope_lines_rec.scope_value,p_prd_id) loop
        i_prd := 1;
      end loop;
      if i_prd = 1 then
        l_prd:= true;
      end if;
    elsif c_scope_lines_rec.dim_code = 'CUS' and i_cus = 0 then
      l_cus:=false;
      for c_level_values_rec in c_level_values(
                                c_scope_lines_rec.dim_code,
                                c_scope_lines_rec.hierarchy_code,
                                p_instance_id,
                                c_scope_lines_rec.level_seq_no,
                                c_scope_lines_rec.scope_value,p_cus_id) loop
        i_cus:= 1;
      end loop;
      if i_cus = 1 then
        l_cus:= true;
      end if;
    elsif c_scope_lines_rec.dim_code = 'GEO' and i_geo=0  then
      l_geo:=false;
      for c_level_values_rec in c_level_values(
                                c_scope_lines_rec.dim_code,
                                c_scope_lines_rec.hierarchy_code,
                                p_instance_id,
                                c_scope_lines_rec.level_seq_no,
                                c_scope_lines_rec.scope_value,p_geo_id) loop
        i_geo:= 1;
      end loop;
      if i_geo = 1 then
        l_geo:= true;
      end if;
    elsif c_scope_lines_rec.dim_code = 'REP'and i_rep=0  then
      l_rep:=false;
      for c_level_values_rec in c_level_values(
                              c_scope_lines_rec.dim_code,
                              c_scope_lines_rec.hierarchy_code,
                              p_instance_id,
                              c_scope_lines_rec.level_seq_no,
                              c_scope_lines_rec.scope_value,p_rep_id) loop
        i_rep := 1;
      end loop;
      if i_rep = 1 then
        l_rep:= true;
      end if;
    elsif c_scope_lines_rec.dim_code = 'CHN' and i_chn=0  then
      l_chn:=false;
      for c_level_values_rec in c_level_values(
                                c_scope_lines_rec.dim_code,
                                c_scope_lines_rec.hierarchy_code,
                                p_instance_id,
                                c_scope_lines_rec.level_seq_no,
                                c_scope_lines_rec.scope_value,p_chn_id) loop
        i_chn := 1;
      end loop;
      if i_chn = 1 then
        l_chn:= true;
      end if;
    elsif c_scope_lines_rec.dim_code = 'PSG' and i_psg=0  then
      l_psg:=false;
      for c_level_values_rec in c_level_values(
                                c_scope_lines_rec.dim_code,
                                c_scope_lines_rec.hierarchy_code,
                                p_instance_id,
                                c_scope_lines_rec.level_seq_no,
                                c_scope_lines_rec.scope_value,p_psg_id) loop
        i_psg := 1;
      end loop;
      if i_psg = 1 then
        l_psg:= true;
      end if;
    end if;
  end loop;

  if l_org and l_prd and l_cus and l_geo and l_rep and l_chn and l_psg then
    return true;
  end if;
  return false;

end check_lob;

function assign_aw(errbuf out nocopy varchar2,
                   retcode out nocopy varchar2,
                   p_instance_id in number,
                   p_inventory_item_id in number,
                   p_org_id in number,
                   p_sales_rep_id in number,
                   p_customer_id in number,
                   p_geography_id in number,
                   p_sales_channel_code in varchar2,
                   p_pr_segment_id in number,
                   p_aw_name out nocopy varchar2
                   ) return number
is

l_datamart number;

cursor c_datamart is
select distinct p.price_plan_id, s.scope_id , p.name, p.start_date
from qpr_price_plans_vl p, qpr_scopes s
where  p.aw_created_flag = 'Y' and p.aw_status_code = 'PROCESS'
--and p.use_for_deal_flag = 'Y'
and p.aw_type_code = 'DATAMART'
and p.instance_id = p_instance_id
and s.parent_entity_type(+) = 'DATAMART'
and s.parent_id(+) = p.price_plan_id
order by p.start_date desc;

begin

   log_debug('Start assign aw..');

   l_datamart := 0;
   for c_datamart_rec in c_datamart loop
   --loop through eligible AWs
      log_debug('Datamart :'|| c_datamart_rec.price_plan_id);
      if c_datamart_rec.scope_id is null then
      -- when there is no LOB restriction that AW is applicable.
	      l_datamart := c_datamart_rec.price_plan_id;
        p_aw_name := c_datamart_rec.name;
    	  exit;
      else
         if check_lob(c_datamart_rec.scope_id,
            p_instance_id,
            p_inventory_item_id,
            p_org_id,
            p_sales_rep_id,
            p_customer_id,
            p_geography_id,
            p_sales_channel_code,
            p_pr_segment_id) then
	          l_datamart := c_datamart_rec.price_plan_id;
            p_aw_name := c_datamart_rec.name;
	          exit;
      	 end if;
      end if;
   end loop; --datamart
   return(l_datamart);
exception
when others then
  errbuf := sqlerrm || dbms_utility.format_error_backtrace;
  retcode := 2;
  raise;
  return(null);
end assign_aw;

procedure get_line_aw_details( errbuf out nocopy varchar2,
                            retcode out nocopy varchar2,
                            p_price_plan_id IN NUMBER,
                            p_instance_id in number,
                  p_t_line_det IN OUT nocopy QPR_DEAL_PVT.PN_AW_TBL_TYPE)
is

line_id Number;
s_product qpr_dimensions.DIM_CODE%TYPE;
s_time qpr_dimensions.DIM_CODE%TYPE;
s_psg qpr_dimensions.DIM_CODE%TYPE;

s_offinv_type varchar2(100);
s_term_type varchar2(100);

s_offinv_value varchar2(100);
offinv_val_eq number;
s_tempDim varchar2(100);
dimMemberCount varchar2(100);

l_counter integer;

limitString varchar2(2000);
limitString1 varchar2(2000);
l_sql varchar2(10000);
s_temp_str VARCHAR2(1000);
awName varchar2(25);

l_tot_cost_meas varchar2(100);
l_ord_qty_meas varchar2(100);
l_cost varchar2(25);
l_ord_qty varchar2(25);
s_cube_code varchar2(25);
l_slope_intercept varchar2(25);
l_slope varchar2(25);
l_intercept varchar2(25);
l_aw_curr varchar2(20);
l_curr_conv number;

cursor c_dims is
select dim_code,dim_ppa_code from qpr_dimensions
where price_plan_id = p_price_plan_id
and dim_ppa_code in ('PRD', 'TIM', 'PSG');

begin
  if p_t_line_det is null then
    return;
  end if;
  if p_t_line_det.count=0 then
    return;
  end if;

--to determine following values and the limits to be applied
-- cost = time and prd and all_pr_seg
-- offinv = time and pr_seg and prd
-- regression = time and pr_Seg and prd

  for r_dims in c_dims loop
    case r_dims.dim_ppa_code
    when 'PRD' then
      s_product := r_dims.dim_code;
    when 'TIM' then
      s_time := r_dims.dim_code;
    when 'PSG' then
      s_psg := r_dims.dim_code;
     else
      null;
    end case;
  end loop;

  select cube_code into s_cube_code
  from qpr_cubes
  where cube_ppa_code ='SALES_DATA'
  and price_plan_id = p_price_plan_id
  and rownum < 2;

  l_ord_qty_meas := s_cube_code || '_QPR_O_Q';
  l_tot_cost_meas := s_cube_code || '_QPR_T_COS';


  SELECT aw_CODE, currency_code into awName, l_aw_curr
  FROM QPR_PRICE_PLANS_VL
  WHERE price_plan_id = p_price_plan_id
  and rownum < 2;

  -- ATTACH AW
  DBMS_AW.EXECUTE('AW ATTACH '||awName||' RO;');

  log_debug('aw attached....');

  DBMS_AW.EXECUTE('oknullstatus = yes;commas = no;limitstrict =no;');

  <<lines>>
  for i in p_t_line_det.first..p_t_line_det.last loop
    -- GET LINE ID
    line_id := p_t_line_det(i).pn_line_id;
    log_debug('Line_ID:' || line_id);

    ---- Cost ---
    if(p_t_line_det(i).GET_COST_FLAG = 'Y')
    and nvl(fnd_profile.value('QPR_ALLOC_MDL_HIST_COST'), 'N') = 'Y' then
      if l_aw_curr <> p_t_line_det(i).DEAL_CURRENCY then
        l_curr_conv := qpr_sr_util.ods_curr_conversion(l_aw_curr,
                          p_t_line_det(i).DEAL_CURRENCY,
                          null,
                          p_t_line_det(i).DEAL_CREATION_DATE,
                          p_instance_id);
      else
        l_curr_conv := 1;
      end if;

      if l_curr_conv > 0 then
--        limitString := 'ALLSTAT ; LIMIT '||s_time||' to last 1;';
        limitString := 'ALLSTAT ; LIMIT '||s_time||' to ancestors; LIMIT ' || s_time || ' remove descendants;';

        dbms_aw.execute(limitString);

        dbms_aw.run('show '||l_tot_cost_meas||'('||s_product ||' '''
                    ||p_t_line_det(i).product_dim_sk||''')',l_cost);
        dbms_aw.run('show '||l_ord_qty_meas||'('||s_product ||' '''
                    ||p_t_line_det(i).product_dim_sk||''')',l_ord_qty);

        l_cost := substr(l_cost,0,length(l_cost) -1);
        l_ord_qty := substr(l_ord_qty,0,length(l_ord_qty) -1);

        IF(l_cost = 'NA') THEN
          l_cost := 0;
        END IF;
        IF(l_ord_qty = 'NA') THEN
          l_ord_qty := 0;
        END IF;

        if(l_ord_qty = 0) then
          p_t_line_det(i).UNIT_COST := 0;
        else
          p_t_line_det(i).UNIT_COST := -1 *to_number(l_cost)/
                                        to_number(l_ord_qty)
                                        * l_curr_conv;
        end if;
      else
        log_debug('Cannot determine conversion between deal currency' ||
                  ' and datamart currency ');
      end if;
      log_debug('product: '|| p_t_line_det(i).product_dim_sk
                  ||' - Cost is: '||l_cost );
    end if;

    ---- OFFINVOICE details------

    l_counter := 1;
--    limitString := 'ALLSTAT; LIMIT ' || s_time || ' to last 1;';
    limitString := 'ALLSTAT ; LIMIT '||s_time||' to ancestors; LIMIT ' || s_time || ' remove descendants;';
    limitString := limitString || ' LIMIT ' || s_psg || ' to '''
                  || p_t_line_det(i).pr_segment_sk|| ''';';
    limitString := limitString || ' LIMIT ' || s_product || ' to '''
                   || p_t_line_det(i).product_dim_sk || ''';';
    << counter_loop >>
    while(l_counter < 4) loop
      if ( l_counter = 1) then
        s_offinv_type := p_t_line_det(i).payment_term_code;
      elsif (l_counter = 2) then
        s_offinv_type := p_t_line_det(i).ship_method_code;
      elsif(l_counter = 3) then
        s_offinv_type := p_t_line_det(i).rebate_code;
      end if;


      -- CHECK FOR NULL VALUE AND EXISTENCE OF THAT VALUE
      s_offinv_value := '0';
      offinv_val_eq := 0;

      if(s_offinv_type is not null) then
        dbms_aw.execute(limitString);

        -- offinv dimension limit is set in retoffinv dml prgm

        limitString1 := 'show retoffinv('''||p_price_plan_id||''', '''
                          ||s_offinv_type||''')';
        DBMS_AW.RUN(limitString1,s_offinv_value);

        s_offinv_value := substr(s_offinv_value,0,length(s_offinv_value) -1);
        offinv_val_eq := -0.01 *
			              fnd_number.canonical_to_number(s_offinv_value) *
                          nvl(p_t_line_det(i).gross_revenue,0);
        log_debug('OFF inv:' || s_offinv_type || ' amount:' || offinv_val_eq);

      end if; -- offinv not null

      if ( l_counter = 1) then
        p_t_line_det(i).payment_term_oad_val := offinv_val_eq;
      elsif (l_counter = 2) then
        p_t_line_det(i).ship_method_oad_val := offinv_val_eq;
      elsif(l_counter = 3) then
        p_t_line_det(i).rebate_oad_val := offinv_val_eq;
      end if;

      l_counter := l_counter + 1;

    end loop counter_loop;

  end loop lines;

  -- DETACH AW
  DBMS_AW.EXECUTE('aw detach '||awName||';');
  log_debug('AW detached');
exception
  when OTHERS then
    retcode := 2;
    errbuf := sqlerrm || dbms_utility.format_error_backtrace;
    raise;
end get_line_aw_details;

procedure cancel_pn_request(p_quote_origin in number,
			    p_quote_header_id in number,
			    p_instance_id in number,
			    return_status out nocopy varchar2)
is
begin
	update qpr_pn_request_hdrs_b
	set request_status = 'CANCELLED'
	where source_id = p_quote_origin
	and source_ref_hdr_id = p_quote_header_id
	and instance_id = p_instance_id
	and request_status in ('ACTIVE', 'CLOSED');
--	and request_status = 'ACTIVE';

	return_status:= FND_API.G_RET_STS_SUCCESS;
exception
	when others then
		return_status:= FND_API.G_RET_STS_ERROR;
end;

procedure handle_request_event(p_quote_origin in number,
			p_quote_header_id in number,
			p_request_header_id number,
			p_response_header_id number,
			p_instance_id number default null,
			callback_status varchar2,
			return_status out nocopy varchar2,
                        p_err_msg out nocopy varchar2)
is
l_api_call_st varchar2(1000);
l_ret varchar2(25);
l_mesg varchar2(240);
instance_ID NUMBER;
quote_origin number;
quote_header_id number;
l_mesg_count number;
l_resource_id number;
l_usr_name varchar2(200);
l_dblink varchar2(500);
l_remote_usr_id number;
l_appl_id number;
l_resp_id number;
l_responsibility_name varchar2(100);
begin
savepoint handle_event;
   if (p_request_header_id is null and p_response_header_id is null and
	(p_quote_origin is null or p_quote_header_id is null)) then
	return_status := FND_API.G_RET_STS_ERROR;
   else
        update_request(p_request_header_id, callback_status);

	if p_instance_id is null or p_quote_origin is null or
		p_quote_header_id is null then
		begin
		select req.source_id, req.source_ref_hdr_id, req.instance_id
		into quote_origin, quote_header_id, instance_id
		from qpr_pn_request_hdrs_b req, qpr_pn_response_hdrs res
		where req.request_header_id = res.request_header_id
		and req.source_ref_hdr_id = nvl(p_quote_header_id, req.source_ref_hdr_id)
		and req.source_id = nvl(p_quote_origin, req.source_id)
		and req.request_header_id = nvl(p_request_header_id, req.request_header_id)
		and res.response_header_id = nvl(p_response_header_id, res.response_header_id);
		exception
		when no_data_found then
			return_status := FND_API.G_RET_STS_ERROR;
			return;
		end;
	else
		instance_id := p_instance_id;
		quote_origin := p_quote_origin;
		quote_header_id := p_quote_header_id;
	end if;

        l_dblink := qpr_sr_util.get_dblink(instance_id);

	if quote_origin = 660 then
		l_api_call_st := ' begin OE_DEALS_UTIL.update_OM_with_deal'||
		                l_dblink || '(:1, :2, :3, :4, :5); end;';
	        execute immediate l_api_call_st using
        	in quote_origin, in quote_header_id, in callback_status,
                out l_ret, out l_mesg;

	elsif quote_origin = 697 then
                select user_name into l_usr_name
                from fnd_user
                where user_id = fnd_global.user_id;

                l_api_call_st:='select resource_id from jtf_rs_resource_extns';
                l_api_call_st := l_api_call_st || l_dblink;
                l_api_call_st := l_api_call_st || ' where category = ''EMPLOYEE'' and user_name = ''' || l_usr_name || ''' and rownum < 2';

		begin
			execute immediate l_api_call_st into l_resource_id;
		exception
			when others then
				l_resource_id := null;
		end;

                l_api_call_st := 'begin :1 := fnd_global.user_id' ;
                l_api_call_st := l_api_call_st || l_dblink || '; end;';
                execute immediate l_api_call_st using out l_remote_usr_id;

                if nvl(l_remote_usr_id , -1) = -1 then
                  l_api_call_st := 'select user_id from fnd_user_view';
                  l_api_call_st := l_api_call_st || l_dblink ||' where user_name = :1';

                  execute immediate l_api_call_st into l_remote_usr_id
                                                using l_usr_name;

                  l_responsibility_name := 'ASO_SALES_AGENT';
                  l_api_call_st := 'select application_id, responsibility_id ';
                  l_api_call_st := l_api_call_st || ' from fnd_responsibility';
                  l_api_call_st := l_api_call_st || l_dblink || ' where responsibility_key = :1';

         	  execute immediate l_api_call_st into l_appl_id, l_resp_id
                  using l_responsibility_name ;

	          l_api_call_st := ' begin ';
          	  l_api_call_st := l_api_call_st || 'fnd_global.apps_initialize' || l_dblink ;
	          l_api_call_st := l_api_call_st || '(:usr, :resp, :appl_id); end; ' ;
                  execute immediate l_api_call_st using l_remote_usr_id,
                                l_resp_id, l_appl_id;
                end if;
   		l_api_call_st := 'begin aso_deal_pub.update_quote_from_deal'||
			qpr_sr_util.get_dblink(instance_id)||
			'(:1, :2, :3, :4, :5, :6); end;';
	        execute immediate l_api_call_st using
        	in quote_header_id, in l_resource_id, in callback_status,
                out l_ret,out l_mesg_count, out l_mesg;
	end if;
	if l_ret <> FND_API.G_RET_STS_SUCCESS then
		return_status := FND_API.G_RET_STS_ERROR;
                p_err_msg := l_mesg;
                rollback to handle_event;
	else
		return_status := FND_API.G_RET_STS_SUCCESS;
	end if;
   end if;
exception
   when others then
	return_status := FND_API.G_RET_STS_ERROR;
        rollback to handle_event;
end handle_request_event;

procedure update_request(p_request_header_id number,
			status varchar2)
is
begin
   if status = 'CREATED' then
	update qpr_pn_request_hdrs_b
	set simulation_flag = 'N'
	where request_header_id = p_request_header_id;
  elsif status = 'ACCEPTED' then
	update qpr_pn_request_hdrs_b
	set request_status = 'CLOSED'
	where request_header_id = p_request_header_id;
  end if;
end;


function has_active_requests(p_quote_origin number,
		p_quote_header_id number,
		p_instance_id number)
return boolean
is
l_dummy varchar2(1);
begin
   select 'Y' into l_dummy
   from qpr_pn_request_hdrs_b req
   where req.source_ref_hdr_id = p_quote_header_id
   and req.source_id = p_quote_origin
   and req.instance_id = p_instance_id
   and nvl(req.request_status, 'ACTIVE') <> 'CANCELLED' ;
--   and nvl(req.request_status, 'ACTIVE') = 'ACTIVE';
   return(true);
exception
   when others then
	return(false);
end;

function has_saved_requests(p_quote_origin number,
		p_quote_header_id number,
		p_instance_id number)
return boolean
is
l_dummy varchar2(1);
begin
   select 'Y' into l_dummy
   from qpr_pn_request_hdrs_b req
   where req.source_ref_hdr_id = p_quote_header_id
   and req.source_id = p_quote_origin
   and req.instance_id = p_instance_id
   and nvl(req.simulation_flag, 'Y') = 'N' ;
   return(true);
exception
   when others then
	return(false);
end;

function get_redirect_function(
			p_quote_origin in number,
			p_quote_header_id in number,
			p_instance_id in number,
			skip_search in boolean default true) return varchar2
is
l_dummy number;
begin
	select count(*) into l_dummy
	from qpr_pn_request_hdrs_b req,
	qpr_pn_response_hdrs res
	where req.request_header_id = res.request_header_id
	and req.source_ref_hdr_id = p_quote_header_id
	and req.source_id = p_quote_origin
	and req.instance_id = p_instance_id
	and nvl(req.request_status, 'ACTIVE') <> 'CANCELLED';
--	and nvl(req.request_status, 'ACTIVE') = 'ACTIVE';
	if l_dummy > 1 or not skip_search then
		return('QPR_DEAL_NEGOTIATION');
	else
		return('QPR_DEAL_WORKBENCH');
	end if;
exception
	when others then
		return null;
end;

function user_allowed( p_response_hdr_id in number,
			p_fnd_user in varchar2) return varchar2
is
l_source_id number;
l_source_header_id number;
l_instance_id number;
l_api_call_st varchar2(200);
l_ret varchar2(25);
l_ret1 varchar2(2);
l_usr_name varchar2(200);
l_resource_id number;
begin
	select req.source_id, req.source_ref_hdr_id, req.instance_id
	into l_source_id, l_source_header_id, l_instance_id
	from qpr_pn_request_hdrs_b req,
	qpr_pn_response_hdrs res
	where req.request_header_id = res.request_header_id
	and res.response_header_id = p_response_hdr_id
	and nvl(req.request_status, 'ACTIVE') <> 'CANCELLED';
--	and nvl(req.request_status, 'ACTIVE') = 'ACTIVE';

	if l_source_id = 697 then
                l_api_call_st:='select resource_id from jtf_rs_resource_extns';
                l_api_call_st := l_api_call_st || qpr_sr_util.get_dblink(
                                          l_instance_id);
                l_api_call_st := l_api_call_st || ' where category = ''EMPLOYEE'' and user_name = ''' || p_fnd_user || ''' and rownum < 2';

                begin
                  execute immediate l_api_call_st into l_resource_id;

  		  l_api_call_st := 'begin :1 := aso_deal_pub.get_deal_access'
                                ||qpr_sr_util.get_dblink(l_instance_id)
                                ||'(:2, :3); end;';
                  execute immediate l_api_call_st
                  using out l_ret, in l_resource_id, in l_source_header_id;
                exception
                  when no_data_found then
                    l_ret := null;
                end;
	end if;

        if nvl(l_ret,'NONE') = 'NONE' then
        begin
              select 'READ' into l_ret
              from
              (
              select view_all_deals_flag
              from qpr_usr_assignments
              where nvl(view_all_deals_flag, 'N') = 'Y'
              and role_id in (fnd_global.user_id, fnd_global.resp_id)
              order by role_type_code desc)
              where rownum < 2;
        exception
                when others then
                        l_ret := null;
        end;
        end if;

        case nvl(l_ret, 'NONE')
        when 'READ' then
          l_ret := 'VIEW';
        when 'UPDATE' then
          l_ret := 'EDIT';
        when 'LOCK' then
          l_ret := 'LOCK';
        when 'NONE' then
          l_ret := null;
        else
          l_ret := null;
        end case;
	return(l_ret);
exception
	when others then
		return(null);
end;

function actions_enable( p_response_hdr_id in number) return varchar2
is
l_source_id number;
l_source_header_id number;
l_instance_id number;
l_api_call_st varchar2(200);
l_ret varchar2(25);
l_ret1 varchar2(2);
l_usr_name varchar2(200);
l_resource_id number;
l_fnd_user varchar2(50);
begin
	l_fnd_user := fnd_global.user_name;
	select req.source_id, req.source_ref_hdr_id, req.instance_id
	into l_source_id, l_source_header_id, l_instance_id
	from qpr_pn_request_hdrs_b req,
	qpr_pn_response_hdrs res
	where req.request_header_id = res.request_header_id
	and res.response_header_id = p_response_hdr_id
	and nvl(req.request_status, 'ACTIVE') <> 'CANCELLED';
	l_ret1 := 'Y';
	if l_source_id = 697 then
                l_api_call_st:='select resource_id from jtf_rs_resource_extns';
                l_api_call_st := l_api_call_st || qpr_sr_util.get_dblink(
                                          l_instance_id);
                l_api_call_st := l_api_call_st || ' where category = ''EMPLOYEE'' and user_name = ''' ||
				l_fnd_user || ''' and rownum < 2';

                begin
                  execute immediate l_api_call_st into l_resource_id;
                exception
                  when others then
                    l_resource_id := null;
                end;
		if l_resource_id is not null then
   		   begin
   		     l_api_call_st := 'begin :1 := aso_deal_pub.get_deal_enable_buttons'
   	   			||qpr_sr_util.get_dblink(l_instance_id)
   				||'(:2, :3); end;';
   	   	     execute immediate l_api_call_st
   		     using out l_ret1, in l_resource_id, in l_source_header_id;
   		   exception
   		     when others then
   		       l_ret1 := 'N';
   		   end;
		else
		       l_ret1 := 'N';
		end if;
	else
		l_ret1 := 'Y';
	end if;
	return(l_ret1);
exception
	when others then
		return('N');
end;

END QPR_DEAL_PVT ;


/
