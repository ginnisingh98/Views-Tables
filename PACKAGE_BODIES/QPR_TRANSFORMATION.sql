--------------------------------------------------------
--  DDL for Package Body QPR_TRANSFORMATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_TRANSFORMATION" AS
/* $Header: QPRUTRNB.pls 120.1 2008/01/10 10:00:03 kdhabali noship $ */

FUNCTION get_null return varchar2 is
begin
	return '*';
end;

FUNCTION get_y return varchar2 is
begin
	return 'Y';
end;

FUNCTION get_n return varchar2 is
begin
	return 'N';
end;

function get_num(p_char varchar2) return number is
begin
	return(to_number(p_char));
exception
	when others then
		return(null);
end;

procedure transform_dimdim_process(
                        errbuf              OUT nocopy VARCHAR2,
                        retcode             OUT nocopy VARCHAR2,
                        p_transf_group_id     IN  NUMBER,
                        p_instance_id     IN  NUMBER
                        );

procedure transform_measdim_process(
                        errbuf              OUT nocopy VARCHAR2,
                        retcode             OUT nocopy VARCHAR2,
                        p_transf_group_id     IN  NUMBER,
                        p_instance_id     IN  NUMBER,
                        p_from_date in date,
                        p_to_date in date);

procedure transform_process(
                        errbuf              OUT  nocopy VARCHAR2,
                        retcode             OUT nocopy VARCHAR2,
                        p_transf_group_id     IN  NUMBER,
                        p_instance_id     IN  NUMBER,
                        p_from_date in varchar2 default null,
                        p_to_date in varchar2 default null) is
l_transf_type_code varchar2(10);
date_from date;
date_to date;

begin
	select transf_type_code into l_transf_type_code
	from qpr_transf_groups_b
	where transf_group_id = p_transf_group_id;
	fnd_file.put_line(fnd_file.log, 'Transf type code:' || l_transf_type_code);
	if nvl(l_transf_type_code, '*') = 'DIMDIM' then

		transform_dimdim_process(errbuf, retcode, p_transf_group_id,p_instance_id);

	elsif nvl(l_transf_type_code, '*') = 'MEASDIM' then

                date_from := fnd_date.canonical_to_date(p_from_date);
                date_to := fnd_date.canonical_to_date(p_to_date);
		transform_measdim_process(errbuf, retcode, p_transf_group_id,
                                          p_instance_id,date_from, date_to);

	end if;

EXCEPTION
     when others then
		errbuf := substr(SQLERRM,1,150);
		retcode := -1;
	fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
end;


procedure transform_measdim_process(
                        errbuf              OUT nocopy VARCHAR2,
                        retcode             OUT nocopy VARCHAR2,
                        p_transf_group_id     IN  NUMBER,
                        p_instance_id     IN  NUMBER,
                        p_from_date in date,
                        p_to_date in date) is

CURSOR GET_TRANSF_HEADER (p_transf_group_id number) is
select TRANSF_HEADER_ID,
	FROM_DIM_MEAS_CODE,
	MEAS_CODE,
	LIMIT_DIM_FLAG,
	TO_DIM_CODE,
	TO_LEVEL_ID,
	TO_VALUE,
	TO_VALUE_DESC
from qpr_transf_headers_b
where TRANSF_GROUP_ID=p_transf_group_id
and from_dim_meas_code is not null
and meas_code is not null
and to_dim_code is not null
and to_level_id is not null
and to_value is not null ;

CURSOR GET_MEASURE (p_transf_header_id number,
p_from_dim_meas_code varchar2,
p_meas_type_code varchar2,
p_instance_id number, p_from_date date, p_to_date date) is
select csd.MEASURE_VALUE_ID,
csd.INSTANCE_ID,
csd.PRD_LEVEL_VALUE,
csd.ORD_LEVEL_VALUE,
csd.MEASURE4_NUMBER,
qtr.LEVEL_VALUE_FROM,
qtr.LEVEL_VALUE_TO,
qtr.LIMIT_DIM_CODE,
qtr.LIMIT_DIM_LEVEL,
qtr.LIMIT_DIM_LEVEL_VALUE
from qpr_measure_data csd, qpr_transf_rules_b qtr
where csd.measure_type_code = p_from_dim_meas_code and
csd.instance_id=p_instance_id and
csd.time_level_value between p_from_date and p_to_date
and qtr.transf_header_id = p_transf_header_id and
((p_meas_type_code = '1' and csd.measure1_number between
  nvl(qpr_transformation.get_num(qtr.level_value_from), csd.measure1_number)
	and nvl(qpr_transformation.get_num(qtr.level_value_to),csd.measure1_number)) or
(p_meas_type_code = '2' and csd.measure2_number between
  nvl(qpr_transformation.get_num(qtr.level_value_from), csd.measure2_number)
	and nvl(qpr_transformation.get_num(qtr.level_value_to),csd.measure2_number)) or
(p_meas_type_code = '3' and csd.measure3_number between
  nvl(qpr_transformation.get_num(qtr.level_value_from), csd.measure3_number)
	and nvl(qpr_transformation.get_num(qtr.level_value_to),csd.measure3_number)) or
(p_meas_type_code = '4' and csd.measure4_number between
  nvl(qpr_transformation.get_num(qtr.level_value_from), csd.measure4_number)
	and nvl(qpr_transformation.get_num(qtr.level_value_to),csd.measure4_number)) or
(p_meas_type_code = '5' and csd.measure5_number between
  nvl(qpr_transformation.get_num(qtr.level_value_from), csd.measure5_number)
	and nvl(qpr_transformation.get_num(qtr.level_value_to),csd.measure5_number)) or
(p_meas_type_code = '6' and csd.measure6_number between
  nvl(qpr_transformation.get_num(qtr.level_value_from), csd.measure6_number)
	and nvl(qpr_transformation.get_num(qtr.level_value_to),csd.measure6_number)) or
(p_meas_type_code = '7' and csd.measure7_number between
  nvl(qpr_transformation.get_num(qtr.level_value_from), csd.measure7_number)
	and nvl(qpr_transformation.get_num(qtr.level_value_to),csd.measure7_number)) or
(p_meas_type_code = '8' and csd.measure8_number between
  nvl(qpr_transformation.get_num(qtr.level_value_from), csd.measure8_number)
	and nvl(qpr_transformation.get_num(qtr.level_value_to),csd.measure8_number)) or
(p_meas_type_code = '9' and csd.measure9_number between
  nvl(qpr_transformation.get_num(qtr.level_value_from), csd.measure9_number)
	and nvl(qpr_transformation.get_num(qtr.level_value_to),csd.measure9_number)) or
(p_meas_type_code = '10' and csd.measure10_number between
  nvl(qpr_transformation.get_num(qtr.level_value_from), csd.measure10_number)
	and nvl(qpr_transformation.get_num(qtr.level_value_to),csd.measure10_number)) or
(p_meas_type_code = '11' and csd.measure11_number between
  nvl(qpr_transformation.get_num(qtr.level_value_from), csd.measure11_number)
	and nvl(qpr_transformation.get_num(qtr.level_value_to),csd.measure11_number)) or
(p_meas_type_code = '12' and csd.measure12_number between
  nvl(qpr_transformation.get_num(qtr.level_value_from), csd.measure12_number)
	and nvl(qpr_transformation.get_num(qtr.level_value_to),csd.measure12_number)) or
(p_meas_type_code = '13' and csd.measure13_number between
  nvl(qpr_transformation.get_num(qtr.level_value_from), csd.measure13_number)
	and nvl(qpr_transformation.get_num(qtr.level_value_to),csd.measure13_number)) or
(p_meas_type_code = '14' and csd.measure14_number between
  nvl(qpr_transformation.get_num(qtr.level_value_from), csd.measure14_number)
	and nvl(qpr_transformation.get_num(qtr.level_value_to),csd.measure14_number)) or
(p_meas_type_code = '15' and csd.measure14_number between
  nvl(qpr_transformation.get_num(qtr.level_value_from), csd.measure15_number)
	and nvl(qpr_transformation.get_num(qtr.level_value_to),csd.measure15_number)) or
(p_meas_type_code = '16' and csd.measure16_number between
  nvl(qpr_transformation.get_num(qtr.level_value_from), csd.measure16_number)
	and nvl(qpr_transformation.get_num(qtr.level_value_to),csd.measure16_number)) or
(p_meas_type_code = '17' and csd.measure17_number between
  nvl(qpr_transformation.get_num(qtr.level_value_from), csd.measure17_number)
	and nvl(qpr_transformation.get_num(qtr.level_value_to),csd.measure17_number)));

l_insert_measure number;
l_next_seq number;
l_dummy number;
l_all_desc varchar2(240);
l_all_value varchar2(240);
begin
fnd_file.put_line(fnd_file.log, 'Inside procedure transform_measdim_process');

for transf_header_rec in get_transf_header(p_transf_group_id) loop

   fnd_file.put_line(fnd_file.log, 'Transf Header ID: '||
		transf_header_rec.TRANSF_HEADER_ID);

   for measure_rec in get_measure(transf_header_rec.transf_header_id,
					transf_header_rec.from_dim_meas_code,
					transf_header_rec.meas_code,
                                      p_instance_id, p_from_date,p_to_date) loop
   	fnd_file.put_line(fnd_file.log, 'Order Line: '||
		measure_rec.ord_level_value);
	l_insert_measure:=0;
	fnd_file.put_line(fnd_file.log, 'Limit Dim flag: '||
		transf_header_rec.limit_dim_flag);
	if nvl(transf_header_rec.limit_dim_flag,'N') = 'Y' then
	fnd_file.put_line(fnd_file.log, 'Limit Dim code: '||
		measure_rec.limit_dim_code);
		if measure_rec.limit_dim_code='PRD' then
	-- Only Product dimension supported now.
	fnd_file.put_line(fnd_file.log, 'Limit Dim level: '||
		measure_rec.limit_dim_level);
		if measure_rec.limit_dim_level = 'ITEM' then
	fnd_file.put_line(fnd_file.log, 'Limit Dim level value: '||
		measure_rec.limit_dim_level_value);
	fnd_file.put_line(fnd_file.log, 'Limit Dim measure value: '||
		measure_rec.prd_level_value);
			if measure_rec.prd_level_value = measure_rec.limit_dim_level_value then
				l_insert_measure:=1;
				fnd_file.put_line(fnd_file.log, 'Insert needed');
			end if;
		else
			l_insert_measure:=0;
			begin
			if measure_rec.limit_dim_level = 'PRODUCT_CATEGORY' then
				select 1 into l_insert_measure
				from qpr_dimension_values
				where  dim_code='PRD'
				and hierarchy_code='PRODUCTCATEGORY'
				and instance_id = p_instance_id and
				level2_value = measure_rec.limit_dim_level_value;
			elsif measure_rec.limit_dim_level = 'PRODUCT_FAMILY' then
				select 1 into l_insert_measure
				from qpr_dimension_values
				where  dim_code='PRD'
				and hierarchy_code='PRODUCTFAMILY'
				and instance_id = p_instance_id and
				level2_value = measure_rec.limit_dim_level_value;
			elsif measure_rec.limit_dim_level = 'ITEM' then
				select 1 into l_insert_measure
				from qpr_dimension_values
				where  dim_code='PRD'
				and hierarchy_code='PRODUCTCATEGORY'
				and instance_id = p_instance_id and
				level1_value = measure_rec.limit_dim_level_value;
			end if;
			exception
			when others then null;
			end;
		end if;
		end if;
	else
		l_insert_measure:=1;
	end if;
	if l_insert_measure = 1 then
		begin
			select 1 into l_dummy
			from qpr_dimension_values
			where dim_code = transf_header_rec.to_dim_code
			and hierarchy_code = nvl(decode(transf_header_rec.to_dim_code,
				'DSB', 'DISC_BAND',
				'VLB', 'VOL_BAND',
				'MGB', 'MRGBAND',  null), hierarchy_code)
			and level1_value = transf_header_rec.to_value
			and instance_id = p_instance_id
			and rownum<2;
			if l_dummy = 1 then
				fnd_file.put_line(fnd_file.log, 'Band exists in Band Dim with value:'||
					transf_header_rec.to_value);
			end if;
		exception
		     WHEN NO_DATA_FOUND THEN
			begin
			  select qpr_dimension_values_s.nextval
				into l_next_seq from dual ;
			 if transf_header_rec.to_dim_code = 'DSB' then
				l_all_desc := qpr_sr_util.get_all_dsb_desc;
				l_all_value := qpr_sr_util.get_all_dsb_pk;
			 elsif transf_header_rec.to_dim_code = 'VLB' then
				l_all_desc := qpr_sr_util.get_all_vlb_desc;
				l_all_value := qpr_sr_util.get_all_vlb_pk;
			 elsif transf_header_rec.to_dim_code = 'MGB' then
				l_all_desc := qpr_sr_util.get_all_mgb_desc;
				l_all_value := qpr_sr_util.get_all_mgb_pk;
			 end if;
			 fnd_file.put_line(fnd_file.log,
			'Inserting band dim with id :'||l_next_seq);
			 INSERT INTO qpr_dimension_values(instance_id,
					dim_value_id,
					dim_code,
					hierarchy_code,
					level1_value,
					level1_desc,
					level2_value,
					level2_desc,
					CREATION_DATE,
					CREATED_BY,
					LAST_UPDATE_DATE,
					LAST_UPDATED_BY,
					LAST_UPDATE_LOGIN,
					REQUEST_ID) values
					(measure_rec.instance_id,
					l_next_seq,
					transf_header_rec.to_dim_code,
					decode(transf_header_rec.to_dim_code,
						'DSB', 'DISC_BAND',
						'VLB', 'VOL_BAND',
						'MGB', 'MRGBAND',  null),
					transf_header_rec.TO_VALUE,
					transf_header_rec.TO_VALUE_DESC,
					l_all_value,
					l_all_desc,
					sysdate,
					FND_GLOBAL.USER_ID,
					sysdate,
					FND_GLOBAL.USER_ID,
					FND_GLOBAL.LOGIN_ID,
					null);
			exception
			     when others then
					errbuf := substr(SQLERRM,1,150);
					retcode := -1;
				fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
			end;
		end;
		begin
			if transf_header_rec.to_dim_code = 'DSB' then
				update qpr_measure_data
				set dsb_level_value = transf_header_rec.to_value,
				measure7_number =
				qpr_transformation.get_num(measure_rec.level_value_to),
				measure8_number =
				qpr_transformation.get_num(measure_rec.level_value_from),
				last_update_date = sysdate,
				last_updated_by = fnd_global.user_id,
				last_update_login = fnd_global.login_id
				where measure_value_id = measure_rec.measure_value_id;
			elsif transf_header_rec.to_dim_code = 'VLB' then
				update qpr_measure_data
				set vlb_level_value = transf_header_rec.to_value,
				measure11_number =
				qpr_transformation.get_num(measure_rec.level_value_to),
				measure12_number =
				qpr_transformation.get_num(measure_rec.level_value_from),
				measure9_number = measure_rec.measure4_number,
				measure10_number = measure_rec.measure4_number,
				last_update_date = sysdate,
				last_updated_by = fnd_global.user_id,
				last_update_login = fnd_global.login_id
				where measure_value_id = measure_rec.measure_value_id;
			elsif transf_header_rec.to_dim_code = 'MGB' then
				update qpr_measure_data
				set mgb_level_value = transf_header_rec.to_value,
				measure18_number =
				qpr_transformation.get_num(measure_rec.level_value_to),
				measure19_number =
				qpr_transformation.get_num(measure_rec.level_value_from),
				last_update_date = sysdate,
				last_updated_by = fnd_global.user_id,
				last_update_login = fnd_global.login_id
				where measure_value_id =
					measure_rec.measure_value_id;
			end if;
			fnd_file.put_line(fnd_file.log, 'Updated '||
				sql%rowcount ||' records');
		exception
		WHEN NO_DATA_FOUND THEN
				errbuf := substr(SQLERRM,1,150);
				retcode := -1;
			fnd_file.put_line(fnd_file.log,
				substr(SQLERRM, 1, 1000));
		end;
	end if;
   end loop;
end loop;
EXCEPTION
     when others then
		errbuf := substr(SQLERRM,1,150);
		retcode := -1;
	fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
end;

function get_attribute_qstring(lvl_no number, attr_no number) return varchar2
is
sql1 varchar2(1000);
begin
   sql1 :=
	'and '||
	'('||
	  '(b.attribute'||lvl_no||'_from is null and b.attribute'||lvl_no||'_to is null) '||
	 'or ('||
	   'nvl(b.attribute'||lvl_no||'_number_flag,qpr_transformation.get_n) '||
	   '= qpr_transformation.get_y  ' ||
	   'and nvl(qpr_transformation.get_num(a.level' ||
		attr_no || '_attribute'||lvl_no||'),0)'||
	   ' between ' ||
	     'nvl(qpr_transformation.get_num(b.attribute'||lvl_no||'_from), '||
		'nvl(qpr_transformation.get_num(a.level' ||
			attr_no || '_attribute'||lvl_no||'),0))  '||
	   'and'||
	     ' nvl(qpr_transformation.get_num(b.attribute'||lvl_no||'_to), '||
		'nvl(qpr_transformation.get_num(a.level' ||
			attr_no || '_attribute'||lvl_no||'),0)) '||
	'or '||
	   'nvl(b.attribute'||lvl_no||'_number_flag,qpr_transformation.get_n) '||
	   '= qpr_transformation.get_n  ' ||
	   'and nvl(a.level' || attr_no || '_attribute'||lvl_no||
		',qpr_transformation.get_null)'||
	   ' between  ' ||
	     'nvl(b.attribute'||lvl_no||'_from, nvl(a.level' || attr_no ||
		  '_attribute'||lvl_no||',qpr_transformation.get_null))  ' ||
	   'and '||
	     'nvl(b.attribute'||lvl_no||'_to, nvl(a.level' || attr_no ||
		  '_attribute'||lvl_no||',qpr_transformation.get_null))'||
	 ') ' ||
	') ' ;
   return(sql1);
end;

procedure transform_dimdim_process(
                        errbuf              OUT nocopy VARCHAR2,
                        retcode             OUT nocopy VARCHAR2,
                        p_transf_group_id     IN  NUMBER,
                        p_instance_id     IN  NUMBER) is

l_level_pk number;
l_created_by_refresh_num number;
l_last_refresh_num number;
l_first number;
l_exist number;
sql1_text varchar2(5000);

CURSOR GET_TRANSF_HEADER (p_transf_group_id number) is
select TRANSF_HEADER_ID,
	FROM_DIM_MEAS_CODE,
	FROM_DIM_HIER_CODE,
	LIMIT_DIM_FLAG,
	FROM_LEVEL_ID,
	TO_LEVEL_ID,
	TO_VALUE,
	TO_VALUE_DESC
from qpr_transf_headers_b
where TRANSF_GROUP_ID=p_transf_group_id;

l_rows natural :=1000;
c_dim_data QPRTRANS;
c_dim_rec DIM_REC;
cl number;

BEGIN

for transf_header_rec in get_transf_header(p_transf_group_id) loop

	fnd_file.put_line(fnd_file.log, 'Transf Header ID: '||
		transf_header_rec.TRANSF_HEADER_ID);

	l_first:=0;
	sql1_text := ' select a.dim_value_id as dim_value_id ' ||
		    ' from qpr_dimension_values a, qpr_transf_rules_b b ';
	sql1_text := sql1_text|| ' where a.dim_code = '|| '''' ||
		replace(transf_header_rec.from_dim_meas_code, '''', '''''') || '''';
	sql1_text := sql1_text|| ' and a.hierarchy_code = '|| '''' ||
		replace(transf_header_rec.from_dim_hier_code, '''', '''''') || '''';
	sql1_text := sql1_text|| ' and b.transf_header_id = '||transf_header_rec.transf_header_id;
	sql1_text := sql1_text|| ' and a.instance_id = '||p_instance_id;
	cl := transf_header_rec.from_level_id;
	if cl>5 then
		fnd_file.put_line(fnd_file.log, 'Error in setup');
		exit;
	end if;
        sql1_text := sql1_text ||
	' and '||
	'('||
	   'b.level_value_from is null '||
	   'or  ' ||
	   '('||
		'nvl(b.level_value_number_flag , qpr_transformation.get_n) '||
		'= qpr_transformation.get_n and ' ||
		'((b.level_value_like_flag =  qpr_transformation.get_y and '||
		'a.level' || cl || '_value like b.level_value_from) ' ||
		'or (b.level_value_like_flag = qpr_transformation.get_n '||
		'and a.level' || cl || '_value >= b.level_value_from ' ||
		'and (b.level_value_to is null or ' ||
		'a.level'||cl||'_value <=  b.level_value_to)))'||
   	   ')'||
	   ' or ' ||
	   '('||
		'nvl(b.level_value_number_flag , qpr_transformation.get_n) '||
		'= qpr_transformation.get_y and '||
		'qpr_transformation.get_num(a.level' || cl || '_value) >= '||
		'qpr_transformation.get_num(b.level_value_from ) and ' ||
		'(qpr_transformation.get_num(b.level_value_to) is null or '||
		'qpr_transformation.get_num(a.level' || cl || '_value) <= '||
		'qpr_transformation.get_num(b.level_value_to))'||
	   ')'||
	')';
        sql1_text := sql1_text ||
	'and '||
	'('||
	  'b.level_desc_from is null '||
	  'or ' ||
	  '('||
	   'b.level_value_like_flag = qpr_transformation.get_y '||
	   'and a.level' || cl || '_desc like b.level_desc_from'||
	  ') '||
	  ' or '||
	  '('||
	    'b.level_value_like_flag=qpr_transformation.get_n and '||
	    'a.level' || cl || '_desc >= b.level_desc_from and ' ||
		'(b.level_desc_to is null or '||
	    'a.level' || cl || '_desc <= b.level_desc_to)'||
	  ')'||
	')  ';
        sql1_text := sql1_text || get_attribute_qstring(1,cl);
        sql1_text := sql1_text || get_attribute_qstring(2,cl);
        sql1_text := sql1_text || get_attribute_qstring(3, cl);
        sql1_text := sql1_text || get_attribute_qstring(4,cl);
        sql1_text := sql1_text || get_attribute_qstring(5,cl);
	fnd_file.put_line(fnd_file.log, 'SQL: '||sql1_text);

	open c_dim_data for sql1_text;
	fnd_file.put_line(fnd_file.log, 'Cursor Opened');

	loop
	c_dim_rec.dim_value_id.delete;
	fnd_file.put_line(fnd_file.log, 'Delete');
	fetch c_dim_data bulk collect into c_dim_rec.dim_value_id limit l_rows;
		fnd_file.put_line(fnd_file.log, 'Fetch');
		for I in 1..c_dim_rec.dim_value_id.count
		loop
		fnd_file.put_line(fnd_file.log, 'Dim_value_id: '||
					c_dim_rec.dim_value_id(I));
		begin
		update qpr_dimension_values
		set
		level2_value = nvl(decode(transf_header_rec.to_level_id, 2,
				transf_header_rec.to_value, null), level2_value),
		level2_desc = nvl(decode(transf_header_rec.to_level_id, 2,
				transf_header_rec.to_value_desc, null), level2_desc),
		level3_value = nvl(decode(transf_header_rec.to_level_id, 3,
				transf_header_rec.to_value, null), level3_value),
		level3_desc = nvl(decode(transf_header_rec.to_level_id, 3,
				transf_header_rec.to_value_desc, null), level3_desc),
		level4_value = nvl(decode(transf_header_rec.to_level_id, 4,
				transf_header_rec.to_value, null), level4_value),
		level4_desc = nvl(decode(transf_header_rec.to_level_id, 4,
				transf_header_rec.to_value_desc, null), level4_desc),
		level5_value = nvl(decode(transf_header_rec.to_level_id, 5,
				transf_header_rec.to_value, null), level5_value),
		level5_desc = nvl(decode(transf_header_rec.to_level_id, 5,
				transf_header_rec.to_value_desc, null), level5_desc),
		level6_value = nvl(decode(transf_header_rec.to_level_id, 6,
				transf_header_rec.to_value, null), level6_value),
		level6_desc = nvl(decode(transf_header_rec.to_level_id, 6,
				transf_header_rec.to_value_desc, null), level6_desc),
		level7_value = nvl(decode(transf_header_rec.to_level_id, 7,
				transf_header_rec.to_value, null), level7_value),
		level7_desc = nvl(decode(transf_header_rec.to_level_id, 7,
				transf_header_rec.to_value_desc, null), level7_desc),
		level8_value = nvl(decode(transf_header_rec.to_level_id, 8,
				transf_header_rec.to_value, null), level8_value),
		level8_desc = nvl(decode(transf_header_rec.to_level_id, 8,
				transf_header_rec.to_value_desc, null), level8_desc),
		last_update_date = sysdate,
		last_updated_by = fnd_global.user_id,
		last_update_login = fnd_global.login_id
		where dim_value_id = c_dim_rec.dim_value_id(I);
		fnd_file.put_line(fnd_file.log, 'Number of rows updated: '||sql%rowcount);
		exception
		     when others then
				errbuf := substr(SQLERRM,1,150);
				retcode := -1;
			fnd_file.put_line(fnd_file.log,
				substr(SQLERRM, 1, 1000));
		end;
/*
		if transf_header_rec.to_level_id = 2 then
			begin
			update qpr_dimension_values
			set level2_value = transf_header_rec.to_value,
			level2_desc = transf_header_rec.to_value_desc,
			last_update_date = sysdate,
			last_updated_by = fnd_global.user_id,
			last_update_login = fnd_global.login_id
			where dim_value_id = c_dim_rec.dim_value_id(I);
			exception
			     when others then
					errbuf := substr(SQLERRM,1,150);
					retcode := -1;
				fnd_file.put_line(fnd_file.log,
					substr(SQLERRM, 1, 1000));
			end;
		end if;
		if transf_header_rec.to_level_id = 3 then
			begin
			update qpr_dimension_values
			set level3_value = transf_header_rec.to_value,
			level3_desc = transf_header_rec.to_value_desc,
			last_update_date = sysdate,
			last_updated_by = fnd_global.user_id,
			last_update_login = fnd_global.login_id
			where dim_value_id = c_dim_rec.dim_value_id(I);
			exception
			     when others then
					errbuf := substr(SQLERRM,1,150);
					retcode := -1;
				fnd_file.put_line(fnd_file.log,
					substr(SQLERRM, 1, 1000));
			end;
		end if;*/
		end loop;
	exit when c_dim_data%NOTFOUND;

	end loop;

	close c_dim_data;
	commit;
end loop; --get_transf_header

EXCEPTION
     when others then
		errbuf := substr(SQLERRM,1,150);
		retcode := -1;
	fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));

END; --transformation process

END QPR_TRANSFORMATION ;

/
