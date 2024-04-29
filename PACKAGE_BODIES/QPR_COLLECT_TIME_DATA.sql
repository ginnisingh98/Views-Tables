--------------------------------------------------------
--  DDL for Package Body QPR_COLLECT_TIME_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_COLLECT_TIME_DATA" AS
/* $Header: QPRUCTMB.pls 120.0 2007/10/11 13:09:10 agbennet noship $ */

  request_id number;
  sys_date date:= sysdate;
  user_id number:= fnd_global.user_id;
  login_id number:= fnd_global.conc_login_id;
  prg_appl_id number:= fnd_global.prog_appl_id;
  prg_id number:= fnd_global.conc_program_id;
  nrows number := 1000;

  UNSUP_CAL_TYPE exception;
  FISCAL_TIME_SRC_TBL varchar2(30):= 'QPR_SR_FISCAL_TIME_V';
  NLS_DATE_LANG varchar2(50) := 'nls_date_language = AMERICAN';
  GREG_CAL_DATE_FMT varchar2(15) := 'DD-MON-YYYY';

  type char15_type is table of varchar2(15) index by PLS_INTEGER;
  type char80_type is table of varchar2(80) index by PLS_INTEGER;
  type date_type is table of date index by PLS_INTEGER;
  type time_type is record(CALENDAR_CODE char15_type,
                           YEAR char15_type,
                           YEAR_DESC char80_type,
                           YEAR_STDT date_type,
                           YEAR_ENDT date_type,
                           QUARTER char15_type,
                           QUARTER_DESC char80_type,
                           QUARTER_STDT date_type,
                           QUARTER_ENDT date_type,
                           MONTH char15_type,
                           MONTH_DESC char80_type,
                           MONTH_STDT date_type,
                           MONTH_ENDT  date_type,
                           DAY date_type,
                           DAY_DESC char80_type);
  type fiscal_per_type is record(
                           CALENDAR_CODE char15_type,
                           YEAR char15_type,
                           YEAR_DESC char15_type,
                           YEAR_STDT date_type,
                           YEAR_ENDT date_type,
                           QUARTER char15_type,
                           QUARTER_DESC char15_type,
                           QUARTER_STDT date_type,
                           QUARTER_ENDT date_type,
                           MONTH char15_type,
                           MONTH_DESC char15_type,
                           MONTH_STDT date_type,
                           MONTH_ENDT  date_type);

  r_fis_cal  fiscal_per_type;
  r_time_data time_type;

procedure clean_time_data is
begin
  r_time_data.CALENDAR_CODE.delete;
  r_time_data.YEAR.delete;
  r_time_data.YEAR_DESC.delete;
  r_time_data.YEAR_STDT.delete;
  r_time_data.YEAR_ENDT.delete;
  r_time_data.QUARTER.delete;
  r_time_data.QUARTER_DESC.delete;
  r_time_data.QUARTER_STDT.delete;
  r_time_data.QUARTER_ENDT.delete;
  r_time_data.MONTH.delete;
  r_time_data.MONTH_DESC.delete;
  r_time_data.MONTH_STDT.delete;
  r_time_data.MONTH_ENDT.delete;
  r_time_data.DAY.delete;
  r_time_data.DAY_DESC.delete;
end clean_time_data;

procedure clean_fiscal_data is
begin
  r_fis_cal.CALENDAR_CODE.delete;
  r_fis_cal.YEAR.delete;
  r_fis_cal.YEAR_DESC.delete;
  r_fis_cal.YEAR_STDT.delete;
  r_fis_cal.YEAR_ENDT.delete;
  r_fis_cal.QUARTER.delete;
  r_fis_cal.QUARTER_DESC.delete;
  r_fis_cal.QUARTER_STDT.delete;
  r_fis_cal.QUARTER_ENDT.delete;
  r_fis_cal.MONTH.delete;
  r_fis_cal.MONTH_DESC.delete;
  r_fis_cal.MONTH_STDT.delete;
  r_fis_cal.MONTH_ENDT.delete;
end clean_fiscal_data;

procedure insert_time_data(p_instance_id in number,
                           p_cal_type in number) is
begin
  forall i in r_time_data.YEAR.first..r_time_data.YEAR.last
    insert into QPR_TIME(TIME_ID,INSTANCE_ID,CALENDAR_TYPE, CALENDAR_CODE,
                         YEAR,YEAR_DESCRIPTION,YEAR_START_DATE,
                         YEAR_END_DATE,QUARTER,QUARTER_DESCRIPTION,
                         QUARTER_START_DATE,QUARTER_END_DATE,MONTH,
                         MONTH_DESCRIPTION,MONTH_START_DATE,MONTH_END_DATE, DAY,
                         DAY_DESCRIPTION,CREATION_DATE, CREATED_BY,
                         LAST_UPDATE_DATE, LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
                         PROGRAM_APPLICATION_ID,PROGRAM_ID,REQUEST_ID)
            values(QPR_TIME_S.nextval, p_instance_id, p_cal_type,
                   r_time_data.CALENDAR_CODE(i), r_time_data.YEAR(i),
                   r_time_data.YEAR_DESC(i),
                   r_time_data.YEAR_STDT(i),
                   r_time_data.YEAR_ENDT(i),
                   r_time_data.QUARTER(i),
                   r_time_data.QUARTER_DESC(i),
                   r_time_data.QUARTER_STDT(i),
                   r_time_data.QUARTER_ENDT(i),
                   r_time_data.MONTH(i),
                   r_time_data.MONTH_DESC(i),
                   r_time_data.MONTH_STDT(i),
                   r_time_data.MONTH_ENDT(i),
                   r_time_data.DAY(i), r_time_data.DAY_DESC(i),
                   sys_date, user_id, sys_date, user_id,login_id,
                   prg_appl_id, prg_id, request_id);
  clean_time_data;
exception
 when OTHERS then
      fnd_file.put_line(fnd_file.log, 'ERROR INSERTING TIME DATA');
      fnd_file.put_line(fnd_file.log, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
      raise;
end insert_time_data;

procedure explode_fiscal_cal(p_instance_id in number) is
  prev_year varchar2(15) := '';
  prev_cal_code varchar2(15);
  l_seq_num PLS_INTEGER;
  l_num_days PLS_INTEGER;
  l_rec_ctr PLS_INTEGER := 0;
begin
  for i in r_fis_cal.YEAR.first..r_fis_cal.YEAR.last loop
    if prev_year is not null and prev_year <> r_fis_cal.YEAR(i) then
        fnd_file.put_line(fnd_file.log,
        'Inserting values for fiscal year ' || prev_year || ' of calendar code '
        || prev_cal_code);
        insert_time_data(p_instance_id, FISCAL_CALENDAR);
        l_rec_ctr := 0;
    end if;
    prev_year := r_fis_cal.YEAR(i);
    prev_cal_code := r_fis_cal.CALENDAR_CODE(i);
    l_num_days := r_fis_cal.MONTH_ENDT(i) - r_fis_cal.MONTH_STDT(i);
    for j in 0..l_num_days loop
      l_rec_ctr := l_rec_ctr + 1;
      r_time_data.CALENDAR_CODE(l_rec_ctr) := r_fis_cal.CALENDAR_CODE(i);
      r_time_data.YEAR(l_rec_ctr) := r_fis_cal.YEAR(i);
      r_time_data.YEAR_DESC(l_rec_ctr) := r_fis_cal.YEAR_DESC(i);
      r_time_data.YEAR_STDT(l_rec_ctr) := r_fis_cal.YEAR_STDT(i);
      r_time_data.YEAR_ENDT(l_rec_ctr) := r_fis_cal.YEAR_ENDT(i);
      r_time_data.QUARTER(l_rec_ctr) := r_fis_cal.QUARTER(i);
      r_time_data.QUARTER_DESC(l_rec_ctr) := r_fis_cal.QUARTER_DESC(i);
      r_time_data.QUARTER_STDT(l_rec_ctr) := r_fis_cal.QUARTER_STDT(i);
      r_time_data.QUARTER_ENDT(l_rec_ctr) := r_fis_cal.QUARTER_ENDT(i);
      r_time_data.MONTH(l_rec_ctr) := r_fis_cal.MONTH(i);
      r_time_data.MONTH_DESC(l_rec_ctr) := r_fis_cal.MONTH_DESC(i);
      r_time_data.MONTH_STDT(l_rec_ctr) := r_fis_cal.MONTH_STDT(i);
      r_time_data.MONTH_ENDT(l_rec_ctr) := r_fis_cal.MONTH_ENDT(i);
      r_time_data.DAY(l_rec_ctr) := r_fis_cal.MONTH_STDT(i) + j;
      r_time_data.DAY_DESC(l_rec_ctr) := r_fis_cal.MONTH_STDT(i) + j;
    end loop;
  end loop;
  if prev_year = r_fis_cal.YEAR(r_fis_cal.YEAR.last) then
    fnd_file.put_line(fnd_file.log,
        'Inserting values for fiscal year ' || prev_year || ' of calendar code '
        || prev_cal_code);
    insert_time_data(p_instance_id, FISCAL_CALENDAR);
  end if;
exception
 when OTHERS then
      fnd_file.put_line(fnd_file.log, 'ERROR EXPLODING FISCAL CALENDAR VALUES');
      fnd_file.put_line(fnd_file.log, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
      raise;
end explode_fiscal_cal;

procedure decode_quarter(p_month in varchar2, p_year in varchar2,
                        p_quarter out nocopy varchar2,
                        p_stdt out nocopy varchar2,
                        p_etdt out nocopy varchar2) is
begin

  if (p_month = '01' or p_month = '02' or p_month = '03') then
    p_quarter := 'Qtr 1';
    p_stdt := '01-JAN-';
    p_etdt := '31-MAR-';
  elsif (p_month = '04' or p_month ='05' or p_month ='06') then
    p_quarter := 'Qtr 2';
    p_stdt := '01-APR-';
    p_etdt := '30-JUN-';
  elsif (p_month ='07' or p_month ='08' or p_month ='09') then
    p_quarter := 'Qtr 3';
    p_stdt := '01-JUL-';
    p_etdt := '30-SEP-';
  elsif (p_month ='10' or p_month ='11' or p_month ='12') then
    p_quarter := 'Qtr 4';
    p_stdt := '01-OCT-';
    p_etdt := '31-DEC-';
  else
    p_quarter := '';
    p_stdt := '';
    p_etdt := '';
  end if;
  p_quarter := p_quarter || ' ' || p_year;
  p_stdt := p_stdt || p_year;
  p_etdt := p_etdt || p_year;
end decode_quarter;

procedure decode_month(p_month in varchar2, p_year in varchar2,
                        p_stdt out nocopy varchar2,
                        p_etdt out nocopy varchar2) is
begin
  case p_month
  when  '01' then
    p_stdt := '01-JAN-';
    p_etdt := '31-JAN-';
  when '02' then
    p_stdt :='01-FEB-';
    if mod(to_number(p_year),4)=0 then
      p_etdt := '29-FEB-';
    else
      p_etdt := '28-FEB-';
    end if;
  when '03' then
    p_stdt :='01-MAR-';
    p_etdt := '31-MAR-';
  when '04' then
  p_stdt := '01-APR-';
  p_etdt := '30-APR-';
  when '05' then
  p_stdt := '01-MAY-';
  p_etdt := '31-MAY-';
  when '06' then
  p_stdt := '01-JUN-';
  p_etdt := '30-JUN-';
  when '07' then
  p_stdt := '01-JUL-';
  p_etdt := '31-JUL-';
  when '08' then
  p_stdt := '01-AUG-';
  p_etdt := '31-AUG-';
  when '09' then
  p_stdt := '01-SEP-';
  p_etdt := '30-SEP-';
  when '10' then
  p_stdt := '01-OCT-';
  p_etdt := '31-OCT-';
  when '11' then
  p_stdt := '01-NOV-';
  p_etdt := '30-NOV-';
  when '12' then
  p_stdt := '01-DEC-';
  p_etdt := '31-DEC-';
  else
    p_stdt := '';
    p_etdt := '';
  end case;
  p_stdt := p_stdt || p_year;
  p_etdt := p_etdt || p_year;
end decode_month;

procedure build_gregorian_cal(p_date_from in date,
                              p_date_to in date) is
  l_num_days PLS_INTEGER;
  l_loop_ctr PLS_INTEGER;
  l_low_limit PLS_INTEGER;
  l_upper_limit PLS_INTEGER;
  l_rec_ctr PLS_INTEGER;
  date_ref date;
  s_year varchar2(4);
  s_month varchar2(4);
  s_mon_name varchar2(20);
  s_qtr varchar2(15);
  s_stdt varchar2(15);
  s_etdt varchar2(15);
begin
  fnd_file.put_line(fnd_file.log,
    'Building Gregorian Calendar for dates between ' || p_date_from || ' and '||
     p_date_to);
  l_num_days := (p_date_to - p_date_from) + 1;
  l_loop_ctr := ceil(l_num_days/nrows);
  for i in 1..l_loop_ctr loop
    if l_num_days < nrows then
      l_upper_limit := l_num_days -1;
    else
      l_upper_limit := nrows-1;
    end if;
    l_num_days := l_num_days - nrows;
    l_rec_ctr := 0;
    for j in 0..l_upper_limit loop
      l_rec_ctr := l_rec_ctr + 1;
      date_ref := p_date_from + j + ((i-1) * nrows);

      s_year := to_char(date_ref,'YYYY', NLS_DATE_LANG);
      r_time_data.CALENDAR_CODE(l_rec_ctr) := 'Gregorian';
      r_time_data.YEAR(l_rec_ctr) := s_year;
      r_time_data.YEAR_DESC(l_rec_ctr) := s_year;
      r_time_data.YEAR_STDT(l_rec_ctr) := fnd_date.string_to_date(
                                        '01-JAN-'|| s_year,GREG_CAL_DATE_FMT);
      r_time_data.YEAR_ENDT(l_rec_ctr) := fnd_date.string_to_date(
                                          '31-DEC-'||s_year,GREG_CAL_DATE_FMT);

      s_month :=  to_char(date_ref,'MM', NLS_DATE_LANG);
      decode_quarter(s_month,s_year, s_qtr, s_stdt, s_etdt);
      r_time_data.QUARTER(l_rec_ctr) := s_qtr;
      r_time_data.QUARTER_DESC(l_rec_ctr) := s_qtr;
      r_time_data.QUARTER_STDT(l_rec_ctr) := fnd_date.string_to_date(s_stdt,
                                                            GREG_CAL_DATE_FMT);
      r_time_data.QUARTER_ENDT(l_rec_ctr) := fnd_date.string_to_date(s_etdt,
                                                            GREG_CAL_DATE_FMT);

      s_mon_name := to_char(date_ref,'MON', NLS_DATE_LANG) || ' ' || s_year;
      decode_month(s_month, s_year, s_stdt, s_etdt);
      r_time_data.MONTH(l_rec_ctr) := s_mon_name;
      r_time_data.MONTH_DESC(l_rec_ctr) := s_mon_name;
      r_time_data.MONTH_STDT(l_rec_ctr) := fnd_date.string_to_date(s_stdt,
                                                            GREG_CAL_DATE_FMT);
      r_time_data.MONTH_ENDT(l_rec_ctr) := fnd_date.string_to_date(s_etdt,
                                                            GREG_CAL_DATE_FMT);

      r_time_data.DAY(l_rec_ctr) := date_ref;
      r_time_data.DAY_DESC(l_rec_ctr) := to_char(date_ref, GREG_CAL_DATE_FMT,
                                                  NLS_DATE_LANG);
    end loop;
    insert_time_data(-1, GREGORIAN_CALENDAR);
  end loop;
exception
 when OTHERS then
      fnd_file.put_line(fnd_file.log, 'ERROR BUILDING GREGORIAN CALENDAR');
      fnd_file.put_line(fnd_file.log, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
      raise;
end build_gregorian_cal;

procedure collect_time_data(errbuf out nocopy varchar2,
                              retcode out nocopy number,
                              p_instance_id in number,
                              p_calendar_type in number,
                              p_calendar_code in varchar2,
                              p_date_from in varchar2,
                              p_date_to in varchar2) is
  bfound boolean := false;
  date_from date;
  date_to date;
  s_sql varchar2(1000);
  src_table varchar2(200);
  c_get_cal_data SYS_REFCURSOR;
  l_sql_check_cal varchar2(1000);
  l_count_cal number;
  l_gl_table varchar2(200);
  c_check_cal_code SYS_REFCURSOR;
begin
  fnd_profile.get('CONC_REQUEST_ID', request_id);

-- Note: the date inputs are mandatory if not null condition needs to be
-- handled
  date_from := FND_DATE.canonical_to_date(p_date_from);
  date_to := FND_DATE.canonical_to_date(p_date_to);


  if p_calendar_type = GREGORIAN_CALENDAR then
    delete QPR_TIME
    where CALENDAR_TYPE = GREGORIAN_CALENDAR
    and day between date_from and date_to;

    build_gregorian_cal(date_from, date_to);
  elsif p_calendar_type = FISCAL_CALENDAR then

    -- Added to resolve bug 5920571
    l_gl_table := 'GL_PERIODS' || qpr_sr_util.get_dblink(p_instance_id);

    l_sql_check_cal := 'select count(period_set_name) from ';
    l_sql_check_cal := l_sql_check_cal || l_gl_table;
    l_sql_check_cal := l_sql_check_cal || ' where period_set_name = ''';
    l_sql_check_cal := l_sql_check_cal || p_calendar_code || '''';

    open c_check_cal_code for l_sql_check_cal;
    fetch c_check_cal_code into l_count_cal;
    close c_check_cal_code;

    if (l_count_cal = 0) then
      fnd_file.put_line(fnd_file.log, 'There does not exist calendar: '||p_calendar_code||' for the specified instance.');
      retcode := 1;
    end if;

    -- End of modification to handle bug 5920571

    --  delete the old data from target table.
    if p_calendar_code is null then
      delete QPR_TIME
      where INSTANCE_ID = p_instance_id
      and CALENDAR_TYPE = FISCAL_CALENDAR
      and day between date_from and date_to;
    else
      delete QPR_TIME
      where INSTANCE_ID = p_instance_id
      and CALENDAR_TYPE = FISCAL_CALENDAR
      and CALENDAR_CODE = p_calendar_code
      and day between date_from and date_to;
    end if;

    src_table := FISCAL_TIME_SRC_TBL || qpr_sr_util.get_dblink(p_instance_id);

    s_sql := 'select CALENDAR_CODE, YEAR,YEAR_DESCRIPTION,YEAR_START_DATE, ';
    s_sql := s_sql || 'YEAR_END_DATE,QUARTER,QUARTER_DESCRIPTION, ';
    s_sql := s_sql || 'QUARTER_START_DATE,QUARTER_END_DATE,MONTH, ' ;
    s_sql := s_sql || 'MONTH_DESCRIPTION,MONTH_START_DATE,MONTH_END_DATE from ';
    s_sql := s_sql || src_table;
    s_sql := s_sql || ' where MONTH_END_DATE between :1 and :2' ;
    if p_calendar_code is null then
      open c_get_cal_data for s_sql using date_from, date_to;
    else
      s_sql := s_sql || ' and CALENDAR_CODE = :3 ' ;
      open c_get_cal_data for s_sql using date_from, date_to, p_calendar_code;
    end if;
    loop
      fetch c_get_cal_data bulk collect into r_fis_cal limit nrows;
      exit when r_fis_cal.YEAR.count = 0;
      explode_fiscal_cal(p_instance_id);
      clean_fiscal_data;
      bfound := true;
    end loop;
    close c_get_cal_data;
    if bfound = false then
      fnd_file.put_line(fnd_file.log,
       'No data retrieved from source for given date range and calendar code');
    end if;
  else
    raise UNSUP_CAL_TYPE;
  end if;
  commit;
exception
  when UNSUP_CAL_TYPE then
      retcode := -1;
      errbuf := 'ERROR: UNSUPPORTED CALENDAR TYPE';
      fnd_file.put_line(fnd_file.log, ' UNSUPPORTED CALENDAR TYPE');
  when OTHERS then
      retcode := -1;
      errbuf  := 'ERROR: ' || substr(sqlerrm, 1, 1000);
      fnd_file.put_line(fnd_file.log, substr(sqlerrm, 1, 1000));
      fnd_file.put_line(fnd_file.log, 'CANNOT POPULATE CALENDAR DATA');
      rollback;
end collect_time_data;
END;



/
