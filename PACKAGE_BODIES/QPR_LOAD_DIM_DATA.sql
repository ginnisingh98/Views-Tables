--------------------------------------------------------
--  DDL for Package Body QPR_LOAD_DIM_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_LOAD_DIM_DATA" AS
/* $Header: QPRUDLDB.pls 120.1 2007/12/06 11:28:21 kdhabali noship $ */
/* Private Procedures */

procedure get_data_from_cursor(
	l_dim_src_instance_id in number,
	p_dim_code in varchar2,
	p_hier_code in varchar2,
	p_instance_id in number,
	date_from in date,
	date_to in date,
	l_inst_type in varchar2);

procedure insert_dimension_data(
	p_instance_id in number,
	p_dim_code in varchar2,
	p_hier_code in varchar2,
	c_dim_data_rec in out nocopy QPR_LOAD_DIM_DATA.DIM_DATA_REC_TYPE);

procedure delete_duplicate_data(
	p_instance_id in number);

procedure load_dim_data(
	errbuf OUT NOCOPY VARCHAR2,
	retcode OUT NOCOPY VARCHAR2,
	p_dim_code in varchar2,
	p_hier_code in varchar2,
	p_instance_id in number,
	p_start_date in varchar2,
	p_end_date in varchar2)
is

cursor get_all_dim_hier (l_dim_src_instance_id number, l_inst_type varchar2)
is
select distinct dim_code dim, hier_code hier
from qpr_dim_sources
where instance_id = l_dim_src_instance_id
and instance_type = l_inst_type;

cursor get_all_hier (p_dim_code varchar2, l_dim_src_instance_id number, l_inst_type varchar2)
is
select distinct hier_code hier
from qpr_dim_sources
where instance_id = l_dim_src_instance_id
and dim_code = p_dim_code
and instance_type = l_inst_type;

l_start_time number;
l_end_time number;
l_check_instance number;
l_dim_src_instance_id number;
l_param_check number;
date_from date;
date_to date;
l_inst_type varchar2(30);

Begin

	date_from := fnd_date.canonical_to_date(p_start_date);
	date_to := fnd_date.canonical_to_date(p_end_date);

	fnd_file.put_line(fnd_file.log, 'Starting...');
	select hsecs into l_start_time from v$timer;
	fnd_file.put_line(fnd_file.log, 'Start time :'||to_char(sysdate,'MM/DD/YYYY:HH:MM:SS'));

	fnd_file.put_line(fnd_file.log, 'Dimension: '||p_dim_code);
	fnd_file.put_line(fnd_file.log, 'Hierarchy: '||p_hier_code);

	l_dim_src_instance_id := p_instance_id;

	select instance_type into l_inst_type
	from qpr_instances
	where instance_id = p_instance_id;

	select count(*) into l_check_instance
	from qpr_dim_sources
	where instance_id = p_instance_id;

	if (l_check_instance = 0)
	then
		l_dim_src_instance_id := 1;
	end if;

	if not qpr_sr_util.dm_parameters_ok then
		retcode:= 2;
		fnd_file.put_line(fnd_file.log, 'One or more mandatory parameters are NULL');
		return;
	end if;

	-- Calling procedure with proper parameters based on the Dimension/Hierarchy --
	if (p_dim_code = 'ALL')
	then
		for l_dim_hier_rec in get_all_dim_hier (l_dim_src_instance_id, l_inst_type)
		loop
			get_data_from_cursor(l_dim_src_instance_id, l_dim_hier_rec.dim, l_dim_hier_rec.hier, p_instance_id, date_from, date_to, l_inst_type);
		end loop;

	elsif (p_hier_code = 'ALL')
	then
		for l_hier_rec in get_all_hier (p_dim_code, l_dim_src_instance_id, l_inst_type)
		loop
			get_data_from_cursor(l_dim_src_instance_id, p_dim_code, l_hier_rec.hier, p_instance_id, date_from, date_to, l_inst_type);
		end loop;

	else
		get_data_from_cursor(l_dim_src_instance_id, p_dim_code, p_hier_code, p_instance_id, date_from, date_to, l_inst_type);

	end if;

	delete_duplicate_data (p_instance_id);
	commit;

	select hsecs into l_end_time from v$timer;
	fnd_file.put_line(fnd_file.log, 'End time :'||to_char(sysdate,'MM/DD/YYYY:HH:MM:SS'));
	FND_FILE.PUT_LINE(FND_FILE.LOG, 'Time taken for loading dimension data (sec):' ||(l_end_time - l_start_time)/100);

exception
	WHEN NO_DATA_FOUND THEN
		retcode := 2;
		errbuf  := FND_MESSAGE.GET;
		fnd_file.put_line( fnd_file.log, 'Unexpected error '||substr(sqlerrm,1200));
End;


procedure delete_duplicate_data (p_instance_id in number)
is
Begin
	delete from qpr_dimension_values a
	where a.instance_id = p_instance_id
	and a.rowid >
	ANY
	(select b.rowid
	from qpr_dimension_values b
	where a.dim_code = b.dim_code
	and a.hierarchy_code = b.hierarchy_code
	and a.instance_id = b.instance_id
	and a.level1_value = b.level1_value);
End;


procedure get_data_from_cursor(
	l_dim_src_instance_id in number,
	p_dim_code in varchar2,
	p_hier_code in varchar2,
	p_instance_id in number,
	date_from in date,
	date_to in date,
	l_inst_type in varchar2)
is

c_dim_data QPRDIMDATA;
c_dim_data_rec DIM_DATA_REC_TYPE;

l_rows			natural := 1000;
l_sql			varchar2(4000);

l_count			number;
l_attr_num		number;
l_level_defined		number;
l_attr_defined		number;
l_source_view_name	varchar2(30);
l_desc_column		varchar2(30);
l_value_column		varchar2(30);
l_attr_column		varchar2(30);
l_level_number		number;
l_hierarchy_level_id	number;
l_date_column		varchar2(30);

Begin
	fnd_file.put_line(fnd_file.log, 'Dimension: '||p_dim_code);
	fnd_file.put_line(fnd_file.log, 'Hierarchy: '||p_hier_code);

	l_source_view_name := null;
	l_sql := 'select ';
	l_count := 1;

	while l_count <= 8
	loop

		select count(nvl(user_value_column, value_column)) into l_level_defined
		from qpr_dim_sources
		where instance_id = l_dim_src_instance_id
		and instance_type = l_inst_type
		and dim_code = p_dim_code
		and hier_code = p_hier_code
		and nvl(user_level_number, level_number) = l_count;

		if (l_level_defined <> 0)
		then

			select count(nvl(user_attr_column, attr_column)) into l_attr_defined
			from qpr_dim_sources
			where instance_id = l_dim_src_instance_id
			and instance_type = l_inst_type
			and dim_code = p_dim_code
			and hier_code = p_hier_code
			and nvl(user_level_number, level_number) = l_count;

			if (l_attr_defined <> 0)
			then
				l_attr_num := 1;
				while (l_attr_num <= l_attr_defined)
				loop
					select
					nvl(user_value_column, value_column),
					nvl(user_desc_column, desc_column),
					nvl(user_attr_column, attr_column)
					into
					l_value_column,
					l_desc_column,
					l_attr_column
					from qpr_dim_sources
					where instance_id = l_dim_src_instance_id
					and instance_type = l_inst_type
					and dim_code = p_dim_code
					and hier_code = p_hier_code
					and nvl(user_level_number, level_number) = l_count
					and nvl(user_attr_number, attr_number) = l_attr_num;

					if (l_attr_num = 1)
					then
						l_sql := l_sql || l_value_column || ' level';
						l_sql := l_sql || l_count || '_value, ';

						l_sql := l_sql || l_desc_column || ' level';
						l_sql := l_sql || l_count || '_desc, ';
					end if;

					l_sql := l_sql || l_attr_column || ' level';
					l_sql := l_sql || l_count || '_attribute';
					l_sql := l_sql || l_attr_num;
					if (l_count <> 8 or l_attr_num <> 5)
					then
						l_sql := l_sql || ', ';
					end if;

					l_attr_num := l_attr_num + 1;

				end loop;

				while l_attr_num <= 5
				loop
					l_sql := l_sql || 'null level';
					l_sql := l_sql || l_count || '_attribute';
					l_sql := l_sql || l_attr_num;
					if (l_count <> 8 or l_attr_num <> 5)
					then
						l_sql := l_sql || ', ';
					end if;
					l_attr_num := l_attr_num + 1;
				end loop;

			else
				select
				nvl(user_value_column, value_column),
				nvl(user_desc_column, desc_column)
				into
				l_value_column,
				l_desc_column
				from qpr_dim_sources
				where instance_id = l_dim_src_instance_id
				and instance_type = l_inst_type
				and dim_code = p_dim_code
				and hier_code = p_hier_code
				and nvl(user_level_number, level_number) = l_count;

				l_sql := l_sql || l_value_column || ' level';
				l_sql := l_sql || l_count || '_value, ';

				l_sql := l_sql || l_desc_column || ' level';
				l_sql := l_sql || l_count || '_desc, ';

				l_attr_num := 1;
				while l_attr_num <= 5
				loop
					l_sql := l_sql || 'null level';
					l_sql := l_sql || l_count || '_attribute';
					l_sql := l_sql || l_attr_num;
					if (l_count <> 8 or l_attr_num <> 5)
					then
						l_sql := l_sql || ', ';
					end if;
					l_attr_num := l_attr_num + 1;
				end loop;
			end if;

		else
			l_sql := l_sql || 'null level';
			l_sql := l_sql || l_count || '_value, ';
			l_sql := l_sql || 'null level';
			l_sql := l_sql || l_count || '_desc, ';
			l_sql := l_sql || 'null level';
			l_sql := l_sql || l_count || '_attribute1, ';
			l_sql := l_sql || 'null level';
			l_sql := l_sql || l_count || '_attribute2, ';
			l_sql := l_sql || 'null level';
			l_sql := l_sql || l_count || '_attribute3, ';
			l_sql := l_sql || 'null level';
			l_sql := l_sql || l_count || '_attribute4, ';
			l_sql := l_sql || 'null level';
			l_sql := l_sql || l_count || '_attribute5 ';

			if (l_count <> 8)
			then
				l_sql := l_sql || ', ';
			end if;


		end if;

		l_count := l_count + 1;

	end loop;
	begin
		l_value_column:=null;
		select
		nvl(user_value_column, value_column)
		into
		l_value_column
		from qpr_dim_sources
		where instance_id = l_dim_src_instance_id
		and instance_type = l_inst_type
		and dim_code = p_dim_code
		and hier_code = p_hier_code
		and nvl(user_level_number, level_number) = 999;
	exception
		when others then null;
	end;
	if l_value_column is not null then
		l_sql := l_sql||', '||l_value_column||' ';
	else
		l_sql := l_sql||', null ';
	end if;

	select distinct nvl(user_view_name, view_name)
	into l_source_view_name
	from qpr_dim_sources
	where instance_id = l_dim_src_instance_id
	and instance_type = l_inst_type
	and dim_code = p_dim_code
	and hier_code = p_hier_code;

	if (l_source_view_name is not null)
	then
		l_sql := l_sql || ' from ' || l_source_view_name || qpr_sr_util.get_dblink(p_instance_id);
	else
		fnd_file.put_line(fnd_file.log, 'Source view name not specified for Dimension: ' || p_dim_code || ' and Hierrarchy: ' || p_hier_code);
		return;
	end if;

        if (date_from is not null) or (date_to is not null) then
		l_date_column:=null;
		select nvl(user_value_column, value_column)
		into l_date_column
		from qpr_dim_sources
		where instance_id = l_dim_src_instance_id
		and instance_type = l_inst_type
		and dim_code = p_dim_code
		and hier_code = p_hier_code
		and nvl(user_level_number, level_number) = 998
                and rownum < 2;

		l_sql := l_sql || ' where (' || l_date_column || ' is null) or (' ;
		l_sql := l_sql || l_date_column || ' between nvl('''||date_from;
                l_sql := l_sql || ''', ' || l_date_column || ') and nvl('''|| date_to;
                l_sql := l_sql || ''', ' || l_date_column || ')) ';
        end if;

	fnd_file.put_line(fnd_file.log, 'SQL: '||l_sql);

	open c_dim_data for l_sql;
	loop
		fnd_file.put_line( fnd_file.log, 'Delete arrays ');
 		c_dim_data_rec.level1_value.delete;
 		c_dim_data_rec.level1_desc.delete;
 		c_dim_data_rec.level1_attribute1.delete;
 		c_dim_data_rec.level1_attribute2.delete;
 		c_dim_data_rec.level1_attribute3.delete;
 		c_dim_data_rec.level1_attribute4.delete;
 		c_dim_data_rec.level1_attribute5.delete;
 		c_dim_data_rec.level2_value.delete;
 		c_dim_data_rec.level2_desc.delete;
 		c_dim_data_rec.level2_attribute1.delete;
 		c_dim_data_rec.level2_attribute2.delete;
 		c_dim_data_rec.level2_attribute3.delete;
 		c_dim_data_rec.level2_attribute4.delete;
 		c_dim_data_rec.level2_attribute5.delete;
 		c_dim_data_rec.level3_value.delete;
 		c_dim_data_rec.level3_desc.delete;
 		c_dim_data_rec.level3_attribute1.delete;
 		c_dim_data_rec.level3_attribute2.delete;
 		c_dim_data_rec.level3_attribute3.delete;
 		c_dim_data_rec.level3_attribute4.delete;
 		c_dim_data_rec.level3_attribute5.delete;
 		c_dim_data_rec.level4_value.delete;
 		c_dim_data_rec.level4_desc.delete;
 		c_dim_data_rec.level4_attribute1.delete;
 		c_dim_data_rec.level4_attribute2.delete;
 		c_dim_data_rec.level4_attribute3.delete;
 		c_dim_data_rec.level4_attribute4.delete;
 		c_dim_data_rec.level4_attribute5.delete;
 		c_dim_data_rec.level5_value.delete;
 		c_dim_data_rec.level5_desc.delete;
 		c_dim_data_rec.level5_attribute1.delete;
 		c_dim_data_rec.level5_attribute2.delete;
 		c_dim_data_rec.level5_attribute3.delete;
 		c_dim_data_rec.level5_attribute4.delete;
 		c_dim_data_rec.level5_attribute5.delete;
 		c_dim_data_rec.level6_value.delete;
 		c_dim_data_rec.level6_desc.delete;
 		c_dim_data_rec.level6_attribute1.delete;
 		c_dim_data_rec.level6_attribute2.delete;
 		c_dim_data_rec.level6_attribute3.delete;
 		c_dim_data_rec.level6_attribute4.delete;
 		c_dim_data_rec.level6_attribute5.delete;
 		c_dim_data_rec.level7_value.delete;
 		c_dim_data_rec.level7_desc.delete;
 		c_dim_data_rec.level7_attribute1.delete;
 		c_dim_data_rec.level7_attribute2.delete;
 		c_dim_data_rec.level7_attribute3.delete;
 		c_dim_data_rec.level7_attribute4.delete;
 		c_dim_data_rec.level7_attribute5.delete;
 		c_dim_data_rec.level8_value.delete;
 		c_dim_data_rec.level8_desc.delete;
 		c_dim_data_rec.level8_attribute1.delete;
 		c_dim_data_rec.level8_attribute2.delete;
 		c_dim_data_rec.level8_attribute3.delete;
 		c_dim_data_rec.level8_attribute4.delete;
 		c_dim_data_rec.level8_attribute5.delete;
 		c_dim_data_rec.check_date.delete;

	fetch c_dim_data bulk collect
	into  	c_dim_data_rec.level1_value,
 		c_dim_data_rec.level1_desc,
 		c_dim_data_rec.level1_attribute1,
 		c_dim_data_rec.level1_attribute2,
 		c_dim_data_rec.level1_attribute3,
 		c_dim_data_rec.level1_attribute4,
 		c_dim_data_rec.level1_attribute5,
 		c_dim_data_rec.level2_value,
 		c_dim_data_rec.level2_desc,
 		c_dim_data_rec.level2_attribute1,
 		c_dim_data_rec.level2_attribute2,
 		c_dim_data_rec.level2_attribute3,
 		c_dim_data_rec.level2_attribute4,
 		c_dim_data_rec.level2_attribute5,
 		c_dim_data_rec.level3_value,
 		c_dim_data_rec.level3_desc,
 		c_dim_data_rec.level3_attribute1,
 		c_dim_data_rec.level3_attribute2,
 		c_dim_data_rec.level3_attribute3,
 		c_dim_data_rec.level3_attribute4,
 		c_dim_data_rec.level3_attribute5,
 		c_dim_data_rec.level4_value,
 		c_dim_data_rec.level4_desc,
 		c_dim_data_rec.level4_attribute1,
 		c_dim_data_rec.level4_attribute2,
 		c_dim_data_rec.level4_attribute3,
 		c_dim_data_rec.level4_attribute4,
 		c_dim_data_rec.level4_attribute5,
 		c_dim_data_rec.level5_value,
 		c_dim_data_rec.level5_desc,
 		c_dim_data_rec.level5_attribute1,
 		c_dim_data_rec.level5_attribute2,
 		c_dim_data_rec.level5_attribute3,
 		c_dim_data_rec.level5_attribute4,
 		c_dim_data_rec.level5_attribute5,
 		c_dim_data_rec.level6_value,
 		c_dim_data_rec.level6_desc,
 		c_dim_data_rec.level6_attribute1,
 		c_dim_data_rec.level6_attribute2,
 		c_dim_data_rec.level6_attribute3,
 		c_dim_data_rec.level6_attribute4,
 		c_dim_data_rec.level6_attribute5,
 		c_dim_data_rec.level7_value,
 		c_dim_data_rec.level7_desc,
 		c_dim_data_rec.level7_attribute1,
 		c_dim_data_rec.level7_attribute2,
 		c_dim_data_rec.level7_attribute3,
 		c_dim_data_rec.level7_attribute4,
 		c_dim_data_rec.level7_attribute5,
 		c_dim_data_rec.level8_value,
 		c_dim_data_rec.level8_desc,
 		c_dim_data_rec.level8_attribute1,
 		c_dim_data_rec.level8_attribute2,
 		c_dim_data_rec.level8_attribute3,
 		c_dim_data_rec.level8_attribute4,
 		c_dim_data_rec.level8_attribute5,
 		c_dim_data_rec.check_date
	limit l_rows;

	fnd_file.put_line( fnd_file.log, 'Populated arrays for dim: '||p_dim_code||' and hier: '||p_hier_code);
	insert_dimension_data(p_instance_id, p_dim_code, p_hier_code, c_dim_data_rec);

	exit when c_dim_data%NOTFOUND;

	end loop;

	close c_dim_data;

End; -- procedure get_data_from_cursor

procedure insert_dimension_data(
	p_instance_id in number,
	p_dim_code in varchar2,
	p_hier_code in varchar2,
	c_dim_data_rec in out nocopy QPR_LOAD_DIM_DATA.DIM_DATA_REC_TYPE)
is

l_request_id number;

Begin
	fnd_file.put_line(fnd_file.log,'Entering insert dimension data ');
	fnd_file.put_line(fnd_file.log,'Inserting dimension data for: '||p_dim_code||'_'||p_hier_code);

--	fnd_file.put_line(fnd_file.log,'Count '||c_dim_data_rec.day_sr_level_value_pk.count);
	fnd_profile.get('CONC_REQUEST_ID', l_request_id);

	forall I in
	    1..c_dim_data_rec.level1_value.count
		delete from QPR_DIMENSION_VALUES
		where dim_code = p_dim_code
		and hierarchy_code = p_hier_code
		and instance_id = p_instance_id
		and level1_value = c_dim_data_rec.level1_value(I);

	FORALL I IN
	    1..c_dim_data_rec.level1_value.count
		INSERT INTO QPR_DIMENSION_VALUES
		(dim_value_id,
		instance_id,
		dim_code,
		hierarchy_code,
		level1_value,
		level1_desc,
		level1_attribute1,
		level1_attribute2,
		level1_attribute3,
		level1_attribute4,
		level1_attribute5,
		level2_value,
		level2_desc,
		level2_attribute1,
		level2_attribute2,
		level2_attribute3,
		level2_attribute4,
		level2_attribute5,
		level3_value,
		level3_desc,
		level3_attribute1,
		level3_attribute2,
		level3_attribute3,
		level3_attribute4,
		level3_attribute5,
		level4_value,
		level4_desc,
		level4_attribute1,
		level4_attribute2,
		level4_attribute3,
		level4_attribute4,
		level4_attribute5,
		level5_value,
		level5_desc,
		level5_attribute1,
		level5_attribute2,
		level5_attribute3,
		level5_attribute4,
		level5_attribute5,
		level6_value,
		level6_desc,
		level6_attribute1,
		level6_attribute2,
		level6_attribute3,
		level6_attribute4,
		level6_attribute5,
		level7_value,
		level7_desc,
		level7_attribute1,
		level7_attribute2,
		level7_attribute3,
		level7_attribute4,
		level7_attribute5,
		level8_value,
		level8_desc,
		level8_attribute1,
		level8_attribute2,
		level8_attribute3,
		level8_attribute4,
		level8_attribute5,
		check_date,
		creation_date,
		created_by,
		last_update_date,
		last_updated_by,
		last_update_login,
		program_application_id,
		program_id,
		program_login_id,
		request_id)
		values
		(QPR_DIMENSION_VALUES_S.nextval,
		p_instance_id,
		p_dim_code,
		p_hier_code,
		c_dim_data_rec.level1_value(I),
		c_dim_data_rec.level1_desc(I),
		c_dim_data_rec.level1_attribute1(I),
		c_dim_data_rec.level1_attribute2(I),
		c_dim_data_rec.level1_attribute3(I),
		c_dim_data_rec.level1_attribute4(I),
		c_dim_data_rec.level1_attribute5(I),
		c_dim_data_rec.level2_value(I),
		c_dim_data_rec.level2_desc(I),
		c_dim_data_rec.level2_attribute1(I),
		c_dim_data_rec.level2_attribute2(I),
		c_dim_data_rec.level2_attribute3(I),
		c_dim_data_rec.level2_attribute4(I),
		c_dim_data_rec.level2_attribute5(I),
		c_dim_data_rec.level3_value(I),
		c_dim_data_rec.level3_desc(I),
		c_dim_data_rec.level3_attribute1(I),
		c_dim_data_rec.level3_attribute2(I),
		c_dim_data_rec.level3_attribute3(I),
		c_dim_data_rec.level3_attribute4(I),
		c_dim_data_rec.level3_attribute5(I),
		c_dim_data_rec.level4_value(I),
		c_dim_data_rec.level4_desc(I),
		c_dim_data_rec.level4_attribute1(I),
		c_dim_data_rec.level4_attribute2(I),
		c_dim_data_rec.level4_attribute3(I),
		c_dim_data_rec.level4_attribute4(I),
		c_dim_data_rec.level4_attribute5(I),
		c_dim_data_rec.level5_value(I),
		c_dim_data_rec.level5_desc(I),
		c_dim_data_rec.level5_attribute1(I),
		c_dim_data_rec.level5_attribute2(I),
		c_dim_data_rec.level5_attribute3(I),
		c_dim_data_rec.level5_attribute4(I),
		c_dim_data_rec.level5_attribute5(I),
		c_dim_data_rec.level6_value(I),
		c_dim_data_rec.level6_desc(I),
		c_dim_data_rec.level6_attribute1(I),
		c_dim_data_rec.level6_attribute2(I),
		c_dim_data_rec.level6_attribute3(I),
		c_dim_data_rec.level6_attribute4(I),
		c_dim_data_rec.level6_attribute5(I),
		c_dim_data_rec.level7_value(I),
		c_dim_data_rec.level7_desc(I),
		c_dim_data_rec.level7_attribute1(I),
		c_dim_data_rec.level7_attribute2(I),
		c_dim_data_rec.level7_attribute3(I),
		c_dim_data_rec.level7_attribute4(I),
		c_dim_data_rec.level7_attribute5(I),
		c_dim_data_rec.level8_value(I),
		c_dim_data_rec.level8_desc(I),
		c_dim_data_rec.level8_attribute1(I),
		c_dim_data_rec.level8_attribute2(I),
		c_dim_data_rec.level8_attribute3(I),
		c_dim_data_rec.level8_attribute4(I),
		c_dim_data_rec.level8_attribute5(I),
		c_dim_data_rec.check_date(I),
		sysdate,
		fnd_global.user_id,
		sysdate,
		fnd_global.user_id,
		fnd_global.conc_login_id,
		fnd_global.prog_appl_id,
		fnd_global.conc_program_id,
		null,
		l_request_id);
	fnd_file.put_line(fnd_file.log, 'No of rows processed: '||sql%rowcount);

	commit;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       fnd_file.put_line(fnd_file.log, 'UNEXCPECTED ERROR IN INSERT_DIMENSION_DATA:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    WHEN OTHERS THEN
       fnd_file.put_line(fnd_file.log, 'UNEXCPECTED ERROR IN INSERT_DIMENSION_DATA:'||sqlerrm);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
End;

End;


/
