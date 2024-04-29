--------------------------------------------------------
--  DDL for Package Body QPR_REGRESSION_ANALYSIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_REGRESSION_ANALYSIS" AS
/* $Header: QPRURGRB.pls 120.11 2008/04/16 13:08:27 kdhabali ship $ */


procedure log_debug(text varchar2) is
begin
	fnd_file.put_line( fnd_file.log, text);
end;

procedure out_debug(text varchar2) is
begin
	fnd_file.put_line(fnd_file.output, text);
end;

function validate_function(
		l_function in varchar2,
		l_parameter in varchar2) return boolean is
l_sql	varchar2(1000);
o_val	number;
begin
	l_sql := 'select ' || l_function || '(';
	if (l_parameter is not null and l_function <> 'sqrt') then
		l_sql := l_sql || l_parameter || ',';
	end if;

	l_sql := l_sql || '2) from dual';
	execute immediate l_sql into o_val;
	return true;
exception
	when others then
		log_debug ('The Transformation Function defined in profile is not valid.');
		return false;
end;

procedure reg_transf(
		i_pp_id in number,
		i_item_id in number,
		i_psg_id in number,
		i_value in number,
		o_value in out nocopy number) is
l_transf varchar2(300);
l_sql varchar2(1000);
begin
	select replace(log_transf,'<num>',i_value)
	into l_transf
	from qpr_regression_result
	where price_plan_id = i_pp_id
	and product_id = i_item_id
	and pr_segment_id = i_psg_id;

	l_sql := 'select '||l_transf||' from dual';
	execute immediate l_sql into o_value;

exception
	when NO_DATA_FOUND then
	o_value := 0;
end;

procedure reg_antitransf(
		i_pp_id in number,
		i_item_id in number,
		i_psg_id in number,
		i_value in number,
		o_value in out nocopy number) is
l_antitransf varchar2(300);
l_sql varchar2(1000);
begin
	select replace(antilog_transf,'<num>',i_value)
	into l_antitransf
	from qpr_regression_result
	where price_plan_id = i_pp_id
	and product_id = i_item_id
	and pr_segment_id = i_psg_id;

	l_sql := 'select '||l_antitransf||' from dual';
	execute immediate l_sql into o_value;

exception
	when NO_DATA_FOUND then
	o_value := 0;

end;

procedure do_regress(
	errbuf		out nocopy varchar2,
	retcode		out nocopy varchar2,
	p_price_plan_id	in number,
	p_start_date	in varchar2,
	p_end_date	in varchar2,
	p_i_prd_id	in varchar2,
	p_f_prd_id	in varchar2,
	p_i_psg_id	in varchar2,
	p_f_psg_id	in varchar2)
is

cursor c_scopes (l_pp_id number) is
select
sc.dim_code dim_code, hier.hierarchy_ppa_code hier_code,
hl.level_seq_num lvl_num, sc.scope_value lvl_value,
sc.operator op_sign
from
qpr_scopes sc, qpr_dimensions dim,
qpr_hierarchies hier, qpr_hier_levels hl
where dim.price_plan_id = 1
and hier.price_plan_id = 1
and hl.price_plan_id = 1
and sc.dim_code = dim.dim_ppa_code
and sc.hierarchy_id = hier.hierarchy_id
and sc.level_id = hl.hierarchy_level_id
and sc.parent_entity_type='DATAMART'
and sc.parent_id = p_price_plan_id;


l_uom		varchar2(3);
l_curr		varchar2(15);
l_start_dt	date;
l_end_dt	date;
date_from	date;
date_to		date;
l_instance_id	number;
l_log		varchar2(30) := '';
l_display_log	varchar2(30) := '';
l_alog		varchar2(30) := '';
l_base		number := 10;
l_request_id	number;
l_pp_name	varchar2(240);
l_x		varchar2(300);
l_y		varchar2(300);
l_transf_func	varchar2(240);
l_atransf_func	varchar2(240);
l_parameter_to_func	varchar2(240);
l_bool_transf	boolean;
l_bool_atransf	boolean;
l_scope_exists	number := 0;
l_dim_clause	varchar2(30);

l_rows		natural := 1000;
l_sql		varchar2(30000);

c_regr_data	QPRREGRDATA;
c_regr_data_rec	REGR_DATA_REC_TYPE;

BEGIN

	date_from := fnd_date.canonical_to_date(p_start_date);
	date_to := fnd_date.canonical_to_date(p_end_date);

	select BASE_UOM_CODE, CURRENCY_CODE,
	START_DATE, END_DATE, INSTANCE_ID, name
	into l_uom, l_curr, l_start_dt, l_end_dt, l_instance_id, l_pp_name
	from qpr_price_plans_vl
	where price_plan_id = p_price_plan_id;

   -- Date Checks
	if (date_from > date_to) then
		log_debug ('The start date is after the end date.') ;
		return;
	end if;

	if (date_from > l_start_dt) then
		l_start_dt := date_from;
	end if;

	if (l_end_dt is not null) then
		if (date_to < l_end_dt) then
			l_end_dt := date_to;
		end if;
	else -- if l_end_dt is null
		l_end_dt := date_to;
	end if;
   --

	l_transf_func := qpr_sr_util.read_parameter('QPR_TRANSF_FUNC');
	case
		when l_transf_func = 'ln' then
			l_atransf_func := 'exp';
			l_parameter_to_func := '';
		when l_transf_func = 'log' then
			l_atransf_func := 'power';
			l_parameter_to_func := qpr_sr_util.read_parameter('QPR_PARAM_FUNC');
		when l_transf_func = 'sqrt' then
			l_atransf_func := 'power';
			l_parameter_to_func := '2';
		when l_transf_func = 'power' then
			l_atransf_func := 'log';
			l_parameter_to_func := qpr_sr_util.read_parameter('QPR_PARAM_FUNC');
		when l_transf_func = 'exp' then
			l_atransf_func := 'ln';
			l_parameter_to_func := '';
		else
			l_atransf_func := qpr_sr_util.read_parameter('QPR_ATRANSF_FUNC');
			l_parameter_to_func := qpr_sr_util.read_parameter('QPR_PARAM_FUNC');
	end case;

	l_bool_transf := validate_function(l_transf_func, l_parameter_to_func);
	l_bool_atransf := validate_function(l_atransf_func, l_parameter_to_func);

	if (l_bool_transf = false or l_bool_atransf = false) then
		retcode := 2;
		return;
	end if;

	l_log := l_transf_func || '(';
	l_alog := l_atransf_func || '(';
	if (l_parameter_to_func is not null) then
		if (l_transf_func <> 'sqrt') then
			l_log := l_log || l_parameter_to_func || ',';
		end if;
		l_alog := l_alog || l_parameter_to_func || ',';
	end if;
	l_display_log := l_log || '<num>)';
	l_alog := l_alog || '<num>)';

	log_debug ('Transformation Function for Regression: '||l_display_log);

    -- Dependant Variable
	l_y := l_log || 'measure4_number'; -- Unit Selling Price
	l_y := l_y || '* qpr_sr_util.ods_curr_conversion(null,'''|| l_curr||''' , null, time_level_value, instance_id)';
	l_y := l_y || '/qpr_sr_util.ods_uom_conv(prd_level_value, measure_uom, '''||l_uom||''', instance_id))';
    -- Independant Variable
	l_x := l_log || 'measure1_number'; -- Ordered Quantity
	l_x := l_x || '* qpr_sr_util.ods_uom_conv(prd_level_value, measure_uom, '''||l_uom||''', instance_id))';

--	log_debug('X: '||l_x);
--	log_debug('Y: '||l_y);

	l_sql := 'select prd_level_value, psg_level_value, ';
	l_sql := l_sql || ' regr_slope('||l_y||','||l_x||'), ';
	l_sql := l_sql || ' regr_intercept('||l_y||','||l_x||'), ';
	l_sql := l_sql || ' regr_r2('||l_y||','||l_x||'), ';
	l_sql := l_sql || ' regr_count('||l_y||','||l_x||') ';
	l_sql := l_sql || ' from qpr_measure_data where measure_type_code=''SALESDATA'' ';
	l_sql := l_sql || ' and instance_id = '|| l_instance_id ||' and time_level_value between :1 and :2 ';

	if (p_i_prd_id is not null) then
		l_sql := l_sql || ' and prd_level_value >= to_number('||p_i_prd_id||') ';
	end if;
	if (p_f_prd_id is not null) then
		l_sql := l_sql || ' and prd_level_value <= to_number('||p_f_prd_id||') ';
	end if;
	if (p_i_psg_id is not null) then
		l_sql := l_sql || ' and psg_level_value >= to_number('||p_i_psg_id||') ';
	end if;
	if (p_f_psg_id is not null) then
		l_sql := l_sql || ' and psg_level_value <= to_number('||p_f_psg_id||') ';
	end if;

	l_sql := l_sql || ' and nvl(measure1_number,0) > 0 ';
	l_sql := l_sql || ' and nvl(measure4_number,0) > 0 ';

	l_sql := l_sql || ' and qpr_sr_util.ods_curr_conversion(null,''';
	l_sql := l_sql || l_curr||''' , null, time_level_value, instance_id) > 0 ';
	l_sql := l_sql || ' and qpr_sr_util.ods_uom_conv(prd_level_value, measure_uom, '''||l_uom||''', instance_id) > 0 ';


	begin
		select 1 into l_scope_exists
		from qpr_scopes
		where parent_entity_type = 'DATAMART'
		and parent_id = p_price_plan_id
		and rownum < 2;
	exception
		when NO_DATA_FOUND then
		l_scope_exists := 0;
	end;

	if (l_scope_exists = 1) then

	for l_scope_rec in c_scopes (p_price_plan_id) loop
		case
			when l_scope_rec.dim_code = 'ORG' then l_dim_clause := 'org_level_value';
			when l_scope_rec.dim_code = 'REP' then l_dim_clause := 'rep_level_value';
			when l_scope_rec.dim_code = 'PSG' then l_dim_clause := 'psg_level_value';
			when l_scope_rec.dim_code = 'PRD' then l_dim_clause := 'prd_level_value';
			when l_scope_rec.dim_code = 'CUS' then l_dim_clause := 'cus_level_value';
			when l_scope_rec.dim_code = 'CHN' then l_dim_clause := 'chn_level_value';
			when l_scope_rec.dim_code = 'GEO' then l_dim_clause := 'geo_level_value';
		end case;
		l_sql := l_sql || ' and ' || l_dim_clause;
		l_sql := l_sql || ' in (select level1_value from qpr_dimension_values where ';
		l_sql := l_sql || ' instance_id = ' || l_instance_id;
		l_sql := l_sql || ' and dim_code = ''' || l_scope_rec.dim_code;
		l_sql := l_sql || ''' and hierarchy_code = ''' || l_scope_rec.hier_code;
		l_sql := l_sql || ''' and level'||l_scope_rec.lvl_num||'_value ';
		l_sql := l_sql || l_scope_rec.op_sign || ' ''' || l_scope_rec.lvl_value || ''') ';
	end loop;

	end if; -- end l_scope_exists


	l_sql := l_sql || ' group by prd_level_value, psg_level_value ';

	log_debug ('SQL: '||l_sql);
	log_debug ('Dates: '||l_start_dt||' to '||l_end_dt);

	out_debug('Regression Analysis on Datamart: '||l_pp_name|| ' on '||sysdate);
	out_debug('Transformation Function for Regression: '||l_display_log);
	out_debug('Transformation Function for Recommended Price Derivation: '||l_alog);
	out_debug(rpad('-',63,'-'));
	out_debug(rpad('| Item',9)||rpad('| Pr-Seg',10)||
		rpad('| Slope',12)||rpad('| Intercept',12)||
		rpad('| R-Square',10)||rpad('| Count',9)||'|');
	out_debug(rpad('-',63,'-'));

	open c_regr_data for l_sql using l_start_dt, l_end_dt;
	loop
		log_debug('Clearing Cursor');
		c_regr_data_rec.product_id.delete;
		c_regr_data_rec.pr_segment_id.delete;
		c_regr_data_rec.regression_slope.delete;
		c_regr_data_rec.regression_intercept.delete;
		c_regr_data_rec.regression_r2.delete;
		c_regr_data_rec.regression_count.delete;

		log_debug('Fetching Data');
		fetch c_regr_data bulk collect into
		c_regr_data_rec.product_id,
		c_regr_data_rec.pr_segment_id,
		c_regr_data_rec.regression_slope,
		c_regr_data_rec.regression_intercept,
		c_regr_data_rec.regression_r2,
		c_regr_data_rec.regression_count
		limit l_rows;

		fnd_profile.get('CONC_REQUEST_ID', l_request_id);

		log_debug ('Count: '||c_regr_data_rec.product_id.count);

		forall I in 1..c_regr_data_rec.product_id.count
			delete from QPR_REGRESSION_RESULT
			where product_id = c_regr_data_rec.product_id(I)
			and pr_segment_id = c_regr_data_rec.pr_segment_id(I)
			and price_plan_id = p_price_plan_id;

		forall I in 1..c_regr_data_rec.product_id.count
			INSERT INTO QPR_REGRESSION_RESULT
			(regression_result_id, price_plan_id,
			product_id, pr_segment_id,
			regression_slope, regression_intercept,
			regression_r2, regression_count,
			log_transf, antilog_transf,
			creation_date, created_by,
			last_update_date, last_updated_by,
			last_update_login, program_application_id,
			program_id, program_login_id,
			request_id)
			values
			(QPR_REGRESSION_RESULT_S.nextval, p_price_plan_id,
			c_regr_data_rec.product_id(I), c_regr_data_rec.pr_segment_id(I),
			c_regr_data_rec.regression_slope(I), c_regr_data_rec.regression_intercept(I),
			c_regr_data_rec.regression_r2(I), c_regr_data_rec.regression_count(I),
			l_display_log, l_alog,
			sysdate, fnd_global.user_id,
			sysdate, fnd_global.user_id,
			fnd_global.conc_login_id, fnd_global.prog_appl_id,
			fnd_global.conc_program_id, null,
			l_request_id);

		for I in 1..c_regr_data_rec.product_id.count
		loop
			out_debug('| '||rpad(c_regr_data_rec.product_id(I),7)||
				'| '||rpad(c_regr_data_rec.pr_segment_id(I),8)||
				'| '||rpad(round(c_regr_data_rec.regression_slope(I),3),10)||
				'| '||rpad(round(c_regr_data_rec.regression_intercept(I),3),10)||
				'| '||rpad(round(c_regr_data_rec.regression_r2(I),3),8)||
				'| '||rpad(c_regr_data_rec.regression_count(I),7)||'|');
		end loop;

		log_debug('No of rows processed: '||sql%rowcount);

		commit;

		exit when c_regr_data%NOTFOUND;
	end loop;
	close c_regr_data;

	out_debug(rpad('-',63,'-'));


EXCEPTION
	WHEN OTHERS THEN
		log_debug('Unexcpected Error in Regression Analysis:'||sqlerrm);
		retcode := 2;

END; -- do_regress

END QPR_REGRESSION_ANALYSIS ;


/
