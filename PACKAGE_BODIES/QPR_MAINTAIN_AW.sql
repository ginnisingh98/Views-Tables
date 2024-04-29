--------------------------------------------------------
--  DDL for Package Body QPR_MAINTAIN_AW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_MAINTAIN_AW" AS
/* $Header: QPRUMNTB.pls 120.3 2008/01/18 14:47:18 vinnaray noship $ */

procedure maint_aw(p_plan_id number, p_clean_meas varchar2,
		p_clean_dim varchar2,
		p_include_dim varchar2);



procedure log_debug(text varchar2) is
begin
	fnd_file.put_line( fnd_file.log, text);
end;

FUNCTION get_day(p_time_pk varchar2, p_low_lvl_time varchar2) return date is
i_date date;
begin

if p_low_lvl_time = 'MONTH'   then
	begin
	select day into i_date
	from qpr_time_allhier_v
	where month = p_time_pk
	and rownum<2;
	exception
	when others then null;
	end;
elsif p_low_lvl_time = 'FISCAL_MONTH'   then
	begin
	select day into i_date
	from qpr_time_allhier_v
	where fiscal_month = p_time_pk
	and rownum<2;
	exception
	when others then null;
	end;
elsif p_low_lvl_time = 'QUARTER'   then
	begin
	select day into i_date
	from qpr_time_allhier_v
	where quarter = p_time_pk
	and rownum<2;
	exception
	when others then null;
	end;
elsif p_low_lvl_time = 'FISCAL_QUARTER'   then
	begin
	select day into i_date
	from qpr_time_allhier_v
	where fiscal_quarter = p_time_pk
	and rownum<2;
	exception
	when others then null;
	end;
elsif p_low_lvl_time = 'YEAR'   then
	begin
	select day into i_date
	from qpr_time_allhier_v
	where year = p_time_pk
	and rownum<2;
	exception
	when others then null;
	end;
elsif p_low_lvl_time = 'FISCAL_YEAR'   then
	begin
	select day into i_date
	from qpr_time_allhier_v
	where fiscal_year = p_time_pk
	and rownum<2;
	exception
	when others then null;
	end;
end if;
return(i_date);
end;

FUNCTION get_run_number return number is
begin
	return g_run_number;
end;

FUNCTION get_instance return number is
begin
	return g_instance;
end;

FUNCTION get_price_plan_id return number is
begin
	return g_price_plan_id;
end;

FUNCTION get_calendar_code return varchar2 is
begin
	return g_calendar_code;
end;

FUNCTION get_start_date return date is
begin
	return g_start_date;
end;

FUNCTION get_end_date return date is
begin
	return g_end_date;
end;

function get_base_uom return varchar2 is
begin
    return g_base_uom;
end;

function get_currency_code return varchar2 is
begin
    return g_currency_code;
end;

--LOB Functions
FUNCTION get_ORD_LINE return varchar2 is
begin
	return g_ord_line;
end;

FUNCTION get_ITEM return varchar2 is
begin
	return g_item;
end;

FUNCTION get_TP_SITE return varchar2 is
begin
	return g_tp_site;
end;

FUNCTION get_CUS return varchar2 is
begin
	return g_cus;
end;

FUNCTION get_OU return varchar2 is
begin
	return g_ou;
end;

FUNCTION get_SR return varchar2 is
begin
	return g_sr;
end;

FUNCTION get_CHN return varchar2 is
begin
	return g_chn;
end;

FUNCTION get_ADJ return varchar2 is
begin
	return g_adj;
end;

FUNCTION get_psg return varchar2 is
begin
	return g_psg;
end;
--
procedure insert_lob_values (p_dim_code varchar2,
				p_hierarchy_code varchar2,
				p_level_code varchar2,
				p_level_seq_num number,
				p_scope_value varchar2) is

cursor c_level_values  is
	select level1_value from qpr_dimension_values
	where dim_code = p_dim_code
	and hierarchy_code = p_hierarchy_code
	and instance_id = g_instance
	and (decode(p_level_seq_num, 1, level1_value,
				 2, level2_value,
				 3, level3_value,
				 4, level4_value,
				 5, level5_value,null)=p_scope_value);
level_value_rec char240_type;
l_rows natural :=1000;
begin
	open c_level_values;
	loop
		level_value_rec.delete;
		fetch c_level_values bulk collect into
			level_value_rec limit l_rows;
		   FORALL I IN
		      1..level_value_rec.count
			INSERT INTO qpr_plan_measures
			(PRICE_PLAN_DATA_ID,
			PRICE_PLAN_ID,
			PRICE_PLAN_MEAS_GRP_ID,
			PRICE_PLAN_MEAS_GRP_NAME,
			run_number,
			attribute_1,
			CREATION_DATE,
			CREATED_BY,
			LAST_UPDATE_DATE,
			LAST_UPDATED_BY,
			LAST_UPDATE_LOGIN,
			REQUEST_ID) values
			(qpr_plan_measures_s.nextval,
			g_price_plan_id,
			decode(p_dim_code,
				'ORD', 1,
				'PRD', 2,
				'GEO', 3,
				'CUS', 4,
				'ORG', 5,
				'REP', 6,
				'CHN', 7,
				'PSG', 8,
				'ADJ', 0),
			p_level_code,
			g_run_number,
			level_value_rec(I)
			,SYSDATE
			,FND_GLOBAL.USER_ID
			,SYSDATE
			,FND_GLOBAL.USER_ID
			,FND_GLOBAL.CONC_LOGIN_ID
			,FND_GLOBAL.conc_request_id);
	exit when c_level_values%NOTFOUND;
	end loop;
	close c_level_values;
	commit;
end;

procedure maintanance_process(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_price_plan_id     NUMBER,
			p_from_date	    varchar2,
			p_to_date	    varchar2,
			p_clean_temp varchar2 default 'Y',
			p_clean_meas varchar2 default 'N',
			p_clean_dim varchar2 default 'N',
			p_include_dim varchar2 default 'Y',
			p_run_number number default 0) IS

cursor c_scope_lines is
	select  a.level_id level_id, a.operator operator,
	a.scope_value scope_value, b.level_ppa_code level_ppa_code,
	b.level_seq_num level_seq_num, c.hierarchy_ppa_code hierarchy_ppa_code,
	c.dim_code dim_code
	from qpr_scopes a, qpr_hier_levels b, qpr_hierarchies_v c
	where b.price_plan_id= qpr_sr_util.g_datamart_tmpl_id
  and b.hierarchy_level_id=a.level_id
	and b.hierarchy_id = c.hierarchy_id
	and a.parent_entity_type = 'DATAMART'
  and a.parent_id = p_price_plan_id;

  i number := 1;
  i_cube number;
  l_rows natural :=1000;
  p_sr_instance_id number;
  l_scope_id number;
  l_dummy number;
  l_start_date date;
  l_end_date date;
  l_start_time number;
  l_end_time number;
  l_return_status varchar2(10);
  l_msg_count number;
  l_msg_data varchar2(30);

Begin
     log_debug('Starting...');
     select hsecs into l_start_time from v$timer;
     log_debug('Start time :'||to_char(sysdate,'MM/DD/YYYY:HH:MM:SS'));
     begin
	select instance_id,
		base_uom_code, currency_code,
		start_date, end_date
	into p_sr_instance_id, g_base_uom,
              g_currency_code,
	      l_start_date, l_end_date
	from qpr_price_plans_b
	where price_plan_id=p_price_plan_id
	and aw_created_flag = 'Y';
    exception
	 WHEN NO_DATA_FOUND THEN
	    retcode := 2;
	    errbuf  := FND_MESSAGE.GET;
	    log_debug('Unexpected error '||substr(sqlerrm,1200));
	    Return;
    end;
    g_instance:=p_sr_instance_id;
    g_price_plan_id := p_price_plan_id;
    if p_run_number = 0 then
	fnd_profile.get('CONC_REQUEST_ID', g_run_number);
    else
    	g_run_number := p_run_number;
    end if;

    log_debug('Price Plan read.');
    begin
    select calendar_code into g_calendar_code
    from qpr_hierarchies_v
    where price_plan_id=p_price_plan_id
    --and dim_code = 'TIM'
    and rownum<2
    and hierarchy_ppa_code='FISCAL';
    exception
	when others then null;
    end;
    g_start_date := fnd_date.canonical_to_date(p_from_date);
    g_end_date := FND_DATE.canonical_to_date(p_to_date);

    if g_start_date is null or g_start_date < l_start_date then
	g_start_date := l_start_date;
    end if;
    if (g_end_date is null and l_end_date is not null) or
       (g_end_date is not null and l_end_date is not null and
	g_end_date > l_end_date) then
  	g_end_date := l_end_date;
    end if;
    begin
	select 1
	into l_dummy
	from qpr_measure_data
	where instance_id = g_instance
	and measure_type_code = 'SALESDATA'
	and time_level_value between g_start_date and
	nvl(g_end_date, time_level_value)
	and rownum<2;
    exception
	 WHEN NO_DATA_FOUND THEN
	    retcode := 2;
	    errbuf  := FND_MESSAGE.GET;
	    log_debug('Unexpected error '||substr(sqlerrm,1200));
	    log_debug('No fact data found');
	    Return;
    end;

    g_ord_line :=null;
    g_item :=null;
    g_tp_site :=null;
    g_cus :=null;
    g_ou :=null;
    g_sr :=null;
    g_chn :=null;
    g_adj :=null;
    g_psg :=null;

    for c_scope_lines_rec in c_scope_lines loop
	log_debug('inside scope loop '||c_scope_lines_rec.level_ppa_code);
	if c_scope_lines_rec.level_ppa_code = 'ORDER_LINE'
	or c_scope_lines_rec.level_ppa_code= 'MODEL'
	or c_scope_lines_rec.level_ppa_code= 'TOP_MODEL'
	or c_scope_lines_rec.level_ppa_code= 'ORDER'
	or c_scope_lines_rec.level_ppa_code= 'ORDER_TYPE' then
		log_debug('Inside '||c_scope_lines_rec.level_ppa_code);
		log_debug('Scope value '||c_scope_lines_rec.scope_value);
		g_ord_line := c_scope_lines_rec.scope_value;
	elsif c_scope_lines_rec.level_ppa_code= 'PRODUCT_FAMILY'
	or c_scope_lines_rec.level_ppa_code= 'PRODUCT_CATEGORY'
	or c_scope_lines_rec.level_ppa_code= 'ITEM' then
		log_debug('Inside '||c_scope_lines_rec.level_ppa_code);
		log_debug('Scope value '||c_scope_lines_rec.scope_value);
		g_item  := c_scope_lines_rec.scope_value;
	elsif c_scope_lines_rec.level_ppa_code= 'AREA'
	or c_scope_lines_rec.level_ppa_code= 'COUNTRY'
	or c_scope_lines_rec.level_ppa_code= 'REGION'
	or c_scope_lines_rec.level_ppa_code= 'GEO_SEGMENT'
	or c_scope_lines_rec.level_ppa_code= 'TRADING_PARTNER_SITE' then
		log_debug('Inside '||c_scope_lines_rec.level_ppa_code);
		log_debug('Scope value '||c_scope_lines_rec.scope_value);
		g_tp_site  := c_scope_lines_rec.scope_value;
	elsif c_scope_lines_rec.level_ppa_code= 'TRADING_PARTNER_CLASS'
	or c_scope_lines_rec.level_ppa_code= 'CUSTOMER_GROUP'
	or c_scope_lines_rec.level_ppa_code= 'TRADING_PARTNER' then
		log_debug('Inside '||c_scope_lines_rec.level_ppa_code);
		log_debug('Scope value '||c_scope_lines_rec.scope_value);
		g_cus  := c_scope_lines_rec.scope_value;
	elsif c_scope_lines_rec.level_ppa_code= 'LEGAL_ENTITY'
	or c_scope_lines_rec.level_ppa_code= 'BUSINESS_GROUP'
	or c_scope_lines_rec.level_ppa_code= 'OPERATING_UNIT' then
		log_debug('Inside '||c_scope_lines_rec.level_ppa_code);
		log_debug('Scope value '||c_scope_lines_rec.scope_value);
		g_ou  := c_scope_lines_rec.scope_value;
	elsif c_scope_lines_rec.level_ppa_code= 'SALES_CHANNEL' then
		log_debug('Inside '||c_scope_lines_rec.level_ppa_code);
		log_debug('Scope value '||c_scope_lines_rec.scope_value);
		g_chn  := c_scope_lines_rec.scope_value;
	elsif c_scope_lines_rec.level_ppa_code= 'PR_SEGMENT' then
		log_debug('Inside '||c_scope_lines_rec.level_ppa_code);
		log_debug('Scope value '||c_scope_lines_rec.scope_value);
		g_psg  := c_scope_lines_rec.scope_value;
	elsif c_scope_lines_rec.level_ppa_code= 'SALES_GROUP1'
	or c_scope_lines_rec.level_ppa_code= 'SALES_GROUP2'
	or c_scope_lines_rec.level_ppa_code= 'SALES_GROUP3'
	or c_scope_lines_rec.level_ppa_code= 'SALES_GROUP4'
	or c_scope_lines_rec.level_ppa_code= 'SALES_REP' then
		log_debug('Inside '||c_scope_lines_rec.level_ppa_code);
		log_debug('Scope value '||c_scope_lines_rec.scope_value);
		g_sr  := c_scope_lines_rec.scope_value;
	elsif c_scope_lines_rec.level_ppa_code= 'ADJUSTMENT'
	or c_scope_lines_rec.level_ppa_code= 'ADJUSTMENT_TYPE'
	or c_scope_lines_rec.level_ppa_code= 'ADJUSTMENT_GROUP' then
		log_debug('Inside '||c_scope_lines_rec.level_ppa_code);
		log_debug('Scope value '||c_scope_lines_rec.scope_value);
		g_adj  := c_scope_lines_rec.scope_value;
	end if;
	insert_lob_values(c_scope_lines_rec.dim_code,
				c_scope_lines_rec.hierarchy_ppa_code,
				c_scope_lines_rec.level_ppa_code,
				c_scope_lines_rec.level_seq_num,
				c_scope_lines_rec.scope_value);
    end loop; --c_scope_lines

select hsecs into l_start_time from v$timer;
log_debug('Start time :'||to_char(sysdate,'MM/DD/YYYY:HH:MM:SS'));

log_debug('PricePlanId: '||p_price_plan_id);

maint_aw(p_price_plan_id, p_clean_meas,
		p_clean_dim,
		p_include_dim);

/*
This is not needed in deal management
log_debug('user plan initialization');
qpr_user_plan_init_pvt.Initialize
	(  p_api_version     =>1.0,
	   p_init_msg_list   =>FND_API.G_TRUE,
	 p_commit   =>FND_API.G_FALSE,
		p_validation_level=>FND_API.G_VALID_LEVEL_NONE,
		p_user_id          =>null,
		p_plan_id          =>p_price_plan_id,
		p_event_id         =>qpr_user_plan_init_pvt.g_maintain_datamart,
	 x_return_status    =>l_return_status,
	 x_msg_count =>l_msg_count,
	 x_msg_data =>l_msg_data
	);
	if l_return_status <> FND_API.G_RET_STS_SUCCESS then
		retcode := 1;
		log_debug('User Plan initialization is not fully successful');
	end if;
*/
select hsecs into l_end_time from v$timer;
log_debug('End time :'||to_char(sysdate,'MM/DD/YYYY:HH:MM:SS'));
FND_FILE.PUT_LINE(FND_FILE.LOG, 'Time taken for AW Maintanance (sec):' ||
		(l_end_time - l_start_time)/100);

if p_clean_temp='Y' then
	delete qpr_plan_measures
	where run_number=g_run_number;
end if;
	update qpr_price_plans_b
	set aw_status_code = 'PROCESS'
	where price_plan_id=p_price_plan_id;
	commit;

exception
 WHEN NO_DATA_FOUND THEN
    retcode := 2;
    errbuf  := FND_MESSAGE.GET;
    log_debug('Unexpected error '||substr(sqlerrm,1200));
End;
/* Public Procedures */

procedure maint_aw(p_plan_id number, p_clean_meas varchar2,
		p_clean_dim varchar2,
		p_include_dim varchar2) is

  cursor c_aw_dim is
  select dim_code
  from qpr_dimensions
  where price_plan_id = p_plan_id;

  cursor c_cube_meas is
  select a.cube_code cube_code,
	b.measure_ppa_code measure_ppa_code,
	c.measure_id measure_id
  from qpr_cubes a, qpr_measures b, qpr_measures c
  where a.cube_id=b.cube_id and
  b.price_plan_id=p_plan_id
  and b.measure_ppa_code = c.measure_ppa_code
  and c.price_plan_id = qpr_sr_util.g_datamart_tmpl_id
  and b.meas_type='INPUT'
  order by a.cube_id, c.measure_id;

  cursor c_xml_load_log is
  select xml_message
  from olapsys.xml_load_log
  where xml_loadid = (select max(xml_loadid) from olapsys.xml_load_log )
  order by xml_date  ;


xml_clob clob;
xml_clob1 clob;
xml_clob2 clob;
xml_str varchar2(4000);
xml_str_temp varchar2(9000);
xml_str_temp1 varchar2(9000);
l_str varchar2(250);
--l_request_id number;
isAW number;
l_aw_name varchar2(30);
l_schem varchar2(5):='APPS';
measure_count number;
measure_limit number;
itr number ;
begin

begin
	select  aw_code into l_aw_name
	from qpr_price_plans_b
	where price_plan_id= p_plan_id;
exception
	when others then null;
end;


select count(*) into measure_count
from qpr_cubes a, qpr_measures b
where a.cube_id=b.cube_id and
b.price_plan_id=p_plan_id
and b.meas_type='INPUT';


itr:=0;

DBMS_LOB.CREATETEMPORARY(xml_clob,TRUE);
dbms_lob.open(xml_clob, DBMS_LOB.LOB_READWRITE);
l_str:='  <BuildDatabase ';
l_str:= l_str|| 'Id="Action'||g_run_number||'" ';
l_str:= l_str|| 'AWName="'||l_schem||'.'||l_aw_name||
		'" BuildType="EXECUTE" RunSolve="true" ';
if p_clean_meas = 'Y' then
	l_str:= l_str|| 'CleanMeasures="true" ';
else
	l_str:= l_str|| 'CleanMeasures="false" ';
end if;
if p_clean_dim = 'Y' then
	l_str:= l_str|| 'CleanAttrs="true" CleanDim="true" '||
			'trackStatus="false" MaxJobQueues="0">';
else
	l_str:= l_str|| 'CleanAttrs="false" CleanDim="false" '||
			'trackStatus="false" MaxJobQueues="0">';
end if;
dbms_lob.writeappend(xml_clob, length(l_str), l_str);
log_debug(l_str);
if p_include_dim = 'Y' then
	for c_aw_dim_rec in c_aw_dim loop
		log_debug(c_aw_dim_rec.dim_code);
		l_str:='	<BuildList XMLIDref="'||
			c_aw_dim_rec.dim_code||'.DIMENSION" />';
		dbms_lob.writeappend(xml_clob, length(l_str), l_str);
		log_debug(l_str);
	end loop;
end if;
for c_cube_meas_rec in c_cube_meas loop
	itr:=itr+1;
	l_str:= '	<BuildList XMLIDref="'||
			c_cube_meas_rec.cube_code||'.'||
			c_cube_meas_rec.measure_ppa_code||'.MEASURE" />';
	if measure_count > 40 and itr > 40 then
		if measure_count > 83 and itr > 83 then
			xml_str_temp1:=xml_str_temp1 || l_str;
		else
			xml_str_temp:=xml_str_temp || l_str;
		end if;
	else
		dbms_lob.writeappend(xml_clob, length(l_str), l_str);
		log_debug(l_str);
	end if;
end loop;
dbms_lob.writeappend(xml_clob, 18, '  </BuildDatabase>');
dbms_lob.close(xml_clob);
xml_str := sys.interactionExecute(xml_clob);
log_debug(xml_str);
for c_xml_load_log_rec in c_xml_load_log loop
	log_debug(c_xml_load_log_rec.xml_message);
end loop;

if xml_str_temp is not null then
	log_debug('Second Load');
	DBMS_LOB.CREATETEMPORARY(xml_clob1,TRUE);
	dbms_lob.open(xml_clob1, DBMS_LOB.LOB_READWRITE);
	l_str:='  <BuildDatabase ';
	l_str:= l_str|| 'Id="Action1'||g_run_number||'" ';
	l_str:= l_str|| 'AWName="'||l_schem||'.'||l_aw_name||
			'" BuildType="EXECUTE" RunSolve="true" ';
	if p_clean_meas = 'Y' then
		l_str:= l_str|| 'CleanMeasures="true" ';
	else
		l_str:= l_str|| 'CleanMeasures="false" ';
	end if;
	if p_clean_dim = 'Y' then
		l_str:= l_str|| 'CleanAttrs="true" CleanDim="true" '||
				'trackStatus="false" MaxJobQueues="0">';
	else
		l_str:= l_str|| 'CleanAttrs="false" CleanDim="false" '||
				'trackStatus="false" MaxJobQueues="0">';
	end if;
	dbms_lob.writeappend(xml_clob1, length(l_str), l_str);
	dbms_lob.writeappend(xml_clob1, length(xml_str_temp), xml_str_temp);
	log_debug(l_str);
	log_debug(xml_str_temp);
	dbms_lob.writeappend(xml_clob1, 18, '  </BuildDatabase>');
	dbms_lob.close(xml_clob1);
	xml_str := sys.interactionExecute(xml_clob1);
	log_debug(xml_str);
	for c_xml_load_log_rec in c_xml_load_log loop
		log_debug(c_xml_load_log_rec.xml_message);
	end loop;
end if;

if xml_str_temp1 is not null then
	log_debug('Third Load');
	DBMS_LOB.CREATETEMPORARY(xml_clob2,TRUE);
	dbms_lob.open(xml_clob2, DBMS_LOB.LOB_READWRITE);
	l_str:='  <BuildDatabase ';
	l_str:= l_str|| 'Id="Action2'||g_run_number||'" ';
	l_str:= l_str|| 'AWName="'||l_schem||'.'||l_aw_name||
			'" BuildType="EXECUTE" RunSolve="true" ';
	if p_clean_meas = 'Y' then
		l_str:= l_str|| 'CleanMeasures="true" ';
	else
		l_str:= l_str|| 'CleanMeasures="false" ';
	end if;
	if p_clean_dim = 'Y' then
		l_str:= l_str|| 'CleanAttrs="true" CleanDim="true" '||
				'trackStatus="false" MaxJobQueues="0">';
	else
		l_str:= l_str|| 'CleanAttrs="false" CleanDim="false" '||
				'trackStatus="false" MaxJobQueues="0">';
	end if;
	dbms_lob.writeappend(xml_clob2, length(l_str), l_str);
	dbms_lob.writeappend(xml_clob2, length(xml_str_temp1), xml_str_temp1);
	log_debug(l_str);
	log_debug(xml_str_temp1);
	dbms_lob.writeappend(xml_clob2, 18, '  </BuildDatabase>');
	dbms_lob.close(xml_clob2);
	xml_str := sys.interactionExecute(xml_clob2);
	log_debug(xml_str);
	for c_xml_load_log_rec in c_xml_load_log loop
		log_debug(c_xml_load_log_rec.xml_message);
	end loop;
end if;
end;

END QPR_MAINTAIN_AW ;


/
