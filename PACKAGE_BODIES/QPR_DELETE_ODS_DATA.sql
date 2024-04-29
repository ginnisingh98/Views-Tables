--------------------------------------------------------
--  DDL for Package Body QPR_DELETE_ODS_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_DELETE_ODS_DATA" AS
/* $Header: QPRUDODB.pls 120.0 2007/10/11 13:12:44 agbennet noship $ */

Type num_type is table of number index by pls_integer;

procedure delete_measure_data(errbuf out nocopy varchar2,
                              retcode out nocopy number,
                              p_instance_id in number,
                              p_measure_code in varchar2,
                              p_from_date in varchar2,
                              p_to_date in varchar2,
                              p_dim_code in varchar2 default 'ALL',
                              p_dummy_dim_code in varchar2 default null,
                              p_dim_value_from in varchar2,
                              p_dim_value_to in varchar2) is

  l_sql varchar2(20000) := '';
  l_sql1 varchar2(20000) := '';
  lrows number := 1000;
  date_from date;
  date_to date;
  c_get_meas_data SYS_REFCURSOR;
  t_meas_data num_type;

begin
  date_from := fnd_date.canonical_to_date(p_from_date);
  date_to := fnd_date.canonical_to_date(p_to_date);

  l_sql := '';
  l_sql := 'select measure_value_id from qpr_measure_data ';
  l_sql := l_sql || ' where instance_id = :1 and measure_type_code = :2 ';
  l_sql := l_sql || ' and time_level_value between :3 and :4';

  case p_dim_code
  when 'ALL' then
    l_sql1 := null;
  when 'ORD' then
    l_sql1 := ' and ORD_LEVEL_VALUE between ''' || p_dim_value_from;
    l_sql1 := l_sql1 || ''' and ''' || p_dim_value_to || '''';
  when 'PRD' then
    l_sql1 := ' and PRD_LEVEL_VALUE between ''' || p_dim_value_from;
    l_sql1 := l_sql1 || ''' and ''' || p_dim_value_to || '''';
  when 'GEO' then
    l_sql1 := ' and GEO_LEVEL_VALUE between ''' || p_dim_value_from;
    l_sql1 := l_sql1 || ''' and ''' || p_dim_value_to || '''';
  when 'CUS' then
    l_sql1 := ' and CUS_LEVEL_VALUE between ''' || p_dim_value_from;
    l_sql1 := l_sql1 || ''' and ''' || p_dim_value_to || '''';
  when 'REP' then
    l_sql1 := ' and REP_LEVEL_VALUE between ''' || p_dim_value_from;
    l_sql1 := l_sql1 || ''' and ''' || p_dim_value_to || '''';
  when 'CHN' then
    l_sql1 := ' and CHN_LEVEL_VALUE between ''' || p_dim_value_from;
    l_sql1 := l_sql1 || ''' and ''' || p_dim_value_to || '''';
  when 'ORG' then
    l_sql1 := ' and ORG_LEVEL_VALUE between ''' || p_dim_value_from;
    l_sql1 := l_sql1 || ''' and ''' || p_dim_value_to || '''';
  else
    l_sql1 := null;
  end case;

  l_sql := l_sql || l_sql1;

  fnd_file.put_line( fnd_file.log, 'Sql to execute: ' || l_sql);
  fnd_file.put_line(fnd_file.log, 'Starting deletion....');
  open c_get_meas_data for l_sql using p_instance_id, p_measure_code,
                                      date_from, date_to;
  loop
    fetch c_get_meas_data bulk collect into t_meas_data limit lrows;
    exit when t_meas_data.count=0;
    forall i in t_meas_data.first..t_meas_data.last
      delete qpr_measure_data where measure_value_id = t_meas_data(i);
    fnd_file.put_line(fnd_file.log, 'Deleted Records = ' || t_meas_data.count);
    t_meas_data.delete;
  end loop;
  commit;
  fnd_file.put_line(fnd_file.log, 'Deletion Complete....');
  close c_get_meas_data;

exception
  when OTHERS then
    retcode := 2;
    errbuf  := 'ERROR: ' || substr(SQLERRM,1,1000);
    fnd_file.put_line(fnd_file.log, 'Unable to delete ODS data');
    fnd_file.put_line(fnd_file.log, 'ERROR: ' || substr(SQLERRM,1,1000));
    fnd_file.put_line(fnd_file.log, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    rollback;
end delete_measure_data;

procedure delete_dimension_data(errbuf out nocopy varchar2,
                              retcode out nocopy number,
                              p_instance_id in number,
                              p_dim_code in varchar2,
                              p_dummy_dim_code in varchar2 default null,
                              p_dim_value_from in varchar2,
                              p_dim_value_to in varchar2) is
  l_sql varchar2(20000) := '';
  l_sql1 varchar2(20000) := '';
  lrows number := 1000;
  c_get_dim_data SYS_REFCURSOR;
  t_dim_data num_type;

begin
  l_sql := '';
  l_sql := 'select dim_value_id from qpr_dimension_values where instance_id = ';
  l_sql := l_sql || p_instance_id ;
  if p_dim_value_from is not null and p_dim_value_to is not null then
    l_sql := l_sql || ' and level1_value between ' ;
    l_sql := l_sql || p_dim_value_from || ' and ' || p_dim_value_to;
  end if;
  if p_dim_code = 'ALL' then
    l_sql1 := null;
  else
   l_sql1 := ' and dim_code = ''' || p_dim_code || '''';
  end if;

  l_sql := l_sql || l_sql1;
  fnd_file.put_line( fnd_file.log, 'Sql to execute: ' || l_sql);
  fnd_file.put_line(fnd_file.log, 'Starting deletion....');
  open c_get_dim_data for l_sql;
  loop
    fetch c_get_dim_data bulk collect into t_dim_data limit lrows;
    exit when t_dim_data.count=0;
    forall i in t_dim_data.first..t_dim_data.last
      delete qpr_dimension_values where dim_value_id = t_dim_data(i);
    fnd_file.put_line(fnd_file.log, 'Deleted Records = ' || t_dim_data.count);
    t_dim_data.delete;
  end loop;
  commit;
  fnd_file.put_line(fnd_file.log, 'Deletion Complete....');
  close c_get_dim_data;
exception
when OTHERS then
    retcode := 2;
    errbuf  := 'ERROR: ' || substr(SQLERRM,1,1000);
    fnd_file.put_line(fnd_file.log, 'Unable to delete ODS data');
    fnd_file.put_line(fnd_file.log, 'ERROR: ' || substr(SQLERRM,1,1000));
    fnd_file.put_line(fnd_file.log, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
    rollback;
end delete_dimension_data;
END;



/
