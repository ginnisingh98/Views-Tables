--------------------------------------------------------
--  DDL for Package Body QPR_COLLECT_CURRENCY_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_COLLECT_CURRENCY_DATA" AS
/* $Header: QPRUCCRB.pls 120.0 2007/10/11 13:08:13 agbennet noship $ */
type char15_type is table of varchar2(15) index by PLS_INTEGER;
  type num_type is table of number index by PLS_INTEGER;
  type date_type is table of date index by PLS_INTEGER;

  type currency_type is record(FROM_CURRENCY char15_type,
                               TO_CURRENCY char15_type,
                               CONVERSION_DATE date_type,
                               CONVERSION_RATE num_type,
                               CONVERSION_CLASS char15_type);
  r_curr_data currency_type;
  CURR_RATE_SRC_TBL constant varchar2(30) := 'QPR_SR_CURRENCY_RATES_V';

procedure insert_curr_rate_data(p_instance_id in number) is
  request_id number;
  sys_date date:= sysdate;
  user_id number:= fnd_global.user_id;
  login_id number:= fnd_global.conc_login_id;
  prg_appl_id number:= fnd_global.prog_appl_id;
  prg_id number:= fnd_global.conc_program_id;
begin
  fnd_profile.get('CONC_REQUEST_ID', request_id);
  forall i in r_curr_data.FROM_CURRENCY.first..r_curr_data.FROM_CURRENCY.last
    insert into QPR_CURRENCY_RATES(CURR_CONV_ID, FROM_CURRENCY, TO_CURRENCY,
                                   CONVERSION_DATE, CONVERSION_RATE,
                                   CONVERSION_CLASS, INSTANCE_ID,
                                   CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE,
                                   LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
                                   PROGRAM_APPLICATION_ID, PROGRAM_ID,
                                   REQUEST_ID)
            values(QPR_CURRENCY_RATES_S.nextval,
                   r_curr_data.FROM_CURRENCY(i), r_curr_data.TO_CURRENCY(i),
                   r_curr_data.CONVERSION_DATE(i),
                   r_curr_data.CONVERSION_RATE(i),
                   r_curr_data.CONVERSION_CLASS(i),
                   p_instance_id, sys_date, user_id, sys_date, user_id,
                   login_id, prg_appl_id, prg_id, request_id) ;
exception
  when OTHERS then
      fnd_file.put_line(fnd_file.log, 'ERROR INSERTING CURRENCT RATE DATA...');
      fnd_file.put_line(fnd_file.log, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
      raise;
end insert_curr_rate_data;

procedure collect_currency_rates(errbuf out nocopy varchar2,
                                retcode out nocopy number,
                                p_instance_id in number,
                                p_date_from in varchar2,
                                p_date_to in varchar2) is
  bfound boolean := false;
  nrows number := 1000;
  date_from date;
  date_to date;
  src_table varchar2(200);
  s_sql varchar2(1000);
  s_conv_type varchar2(30);
  c_get_curr_rate SYS_REFCURSOR;
begin
  src_table := CURR_RATE_SRC_TBL || qpr_sr_util.get_dblink(p_instance_id);
  date_from := FND_DATE.canonical_to_date(p_date_from);
  date_to := FND_DATE.canonical_to_date(p_date_to);

  if nvl(qpr_sr_util.read_parameter('QPR_PULL_CURR_CONV_TO_ODS'), 'N')= 'Y' then
    delete QPR_CURRENCY_RATES
    where INSTANCE_ID = p_instance_id
    and CONVERSION_DATE between date_from and date_to;

    s_sql := 'select FROM_CURRENCY, TO_CURRENCY,CONVERSION_DATE, ';
    s_sql := s_sql || 'CONVERSION_RATE,CONVERSION_CLASS from ' || src_table;
    s_sql := s_sql || ' where CONVERSION_TYPE IS NULL or CONVERSION_TYPE = :1 ' ;
    s_sql := s_sql || ' and CONVERSION_DATE between :2 and :3' ;

    s_conv_type := nvl(qpr_sr_util.read_parameter('QPR_CONVERSION_TYPE'),
                        'Spot');

    open c_get_curr_rate for s_sql using s_conv_type, date_from, date_to;
    loop
      fetch c_get_curr_rate bulk collect into r_curr_data limit nrows;
      exit when r_curr_data.FROM_CURRENCY.count = 0;
      fnd_file.put_line(fnd_file.log,
                        'Record count: ' || r_curr_data.FROM_CURRENCY.count);
      insert_curr_rate_data(p_instance_id);
      bfound := true;
    end loop;
    commit;

    if bfound = false then
      fnd_file.put_line(fnd_file.log,
                        'No data retrieved from source for given date range');
    end if;
  else
    fnd_file.put_line(fnd_file.log,
'Rates not fetched to ODS as parameter QPR_PULL_CURR_CONV_TO_ODS is No/not set');
  end if;
exception
    when OTHERS then
      retcode := -1;
      errbuf  := 'ERROR: ' || substr(sqlerrm, 1, 1000);
      fnd_file.put_line(fnd_file.log, substr(sqlerrm, 1, 1000));
      fnd_file.put_line(fnd_file.log, 'CANNOT POPULATE CURRENCY RATES');
      rollback;
end collect_currency_rates;
END;


/
