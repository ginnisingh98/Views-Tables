--------------------------------------------------------
--  DDL for Package Body QPR_COLLECT_UOM_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_COLLECT_UOM_DATA" AS
/* $Header: QPRUCUMB.pls 120.0 2007/10/11 13:09:38 agbennet noship $ */

  type char40_type is table of varchar2(40) index by PLS_INTEGER;
  type char1_type is table of varchar2(1) index by PLS_INTEGER;
  type char240_type is table of varchar2(240) index by PLS_INTEGER;
  type num_type is table of number index by PLS_INTEGER;
  type uom_type is record(FROM_UOM_CLASS char40_type,
                          TO_UOM_CLASS char40_type,
                          FROM_UOM_CODE char40_type,
                          TO_UOM_CODE char40_type,
                          CONVERSION_RATE num_type,
                          BASE_UOM_FLAG char1_type,
                          SR_ITEM_PK char240_type,
                          FROM_UOM_DESC char240_type);
  r_uom_data uom_type;
  UOM_CONV_SRC_TBL constant varchar2(30) := 'QPR_SR_UOM_CONVERSIONS_V';
 procedure insert_uom_data(p_instance_id in number) is
  request_id number;
  sys_date date:= sysdate;
  user_id number:= fnd_global.user_id;
  login_id number:= fnd_global.conc_login_id;
  prg_appl_id number:= fnd_global.prog_appl_id;
  prg_id number:= fnd_global.conc_program_id;
begin
  fnd_profile.get('CONC_REQUEST_ID', request_id);
  forall i in r_uom_data.FROM_UOM_CLASS.first..r_uom_data.FROM_UOM_CLASS.last
    insert into QPR_UOM_CONVERSIONS(UOM_CONV_ID, FROM_UOM_CLASS, TO_UOM_CLASS,
                                   FROM_UOM_CODE, TO_UOM_CODE, BASE_UOM_FLAG,
                                   CONVERSION_RATE, ITEM_KEY, FROM_UOM_DESC,
                                   INSTANCE_ID,
                                   CREATION_DATE, CREATED_BY, LAST_UPDATE_DATE,
                                   LAST_UPDATED_BY, LAST_UPDATE_LOGIN,
                                   PROGRAM_APPLICATION_ID, PROGRAM_ID,
                                   REQUEST_ID)
            values(QPR_UOM_CONVERSIONS_S.nextval,
                   r_uom_data.FROM_UOM_CLASS(i), r_uom_data.TO_UOM_CLASS(i),
                   r_uom_data.FROM_UOM_CODE(i), r_uom_data.TO_UOM_CODE(i),
                   r_uom_data.BASE_UOM_FLAG(i), r_uom_data.CONVERSION_RATE(i),
                   r_uom_data.SR_ITEM_PK(i), r_uom_data.FROM_UOM_DESC(i),
                   p_instance_id,
                   sys_date, user_id, sys_date, user_id,
                   login_id, prg_appl_id, prg_id, request_id) ;
exception
  when OTHERS then
      fnd_file.put_line(fnd_file.log, 'ERROR INSERTING UOM_DATA...');
      fnd_file.put_line(fnd_file.log, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
      raise;
end insert_uom_data;

procedure collect_uom_data(errbuf out nocopy varchar2,
                           retcode out nocopy number,
                           p_instance_id number) is
  bfound boolean := false;
  nrows number := 1000;
  src_table varchar2(200);
  s_sql varchar2(1000);
  c_get_uom_data SYS_REFCURSOR;
begin
  if nvl(qpr_sr_util.read_parameter('QPR_PULL_UOM_CONV_TO_ODS'), 'N')= 'Y' then
    src_table := UOM_CONV_SRC_TBL || qpr_sr_util.get_dblink(p_instance_id);

    delete QPR_UOM_CONVERSIONS where INSTANCE_ID = p_instance_id;

    s_sql := 'select FROM_UOM_CLASS, TO_UOM_CLASS,FROM_UOM_CODE, TO_UOM_CODE, ';
    s_sql := s_sql || 'CONVERSION_RATE,BASE_UOM_FLAG, SR_ITEM_PK,FROM_UOM_DESC';
    s_sql := s_sql || ' FROM ' || src_table;

    open c_get_uom_data for s_sql;
    loop
      fetch c_get_uom_data bulk collect into r_uom_data limit nrows;
      exit when r_uom_data.FROM_UOM_CLASS.count = 0;
      fnd_file.put_line(fnd_file.log,
                        'Record count: ' || r_uom_data.FROM_UOM_CLASS.count);
      insert_uom_data(p_instance_id);
      bfound := true;
    end loop;
    commit;
    if bfound = false then
      fnd_file.put_line(fnd_file.log, 'No data retrieved from source');
    end if;
  else
    fnd_file.put_line(fnd_file.log,
'Rates not fetched to ODS as parameter QPR_PULL_UOM_CONV_TO_ODS is No/not set');
  end if;
exception
    when OTHERS then
      retcode := -1;
      errbuf  := 'ERROR: ' || substr(sqlerrm, 1, 1000);
      fnd_file.put_line(fnd_file.log, substr(sqlerrm, 1, 1000));
      fnd_file.put_line(fnd_file.log, 'CANNOT POPULATE UOM CONVERSION DATA');
      rollback;
end collect_uom_data;
END;



/
