--------------------------------------------------------
--  DDL for Package Body PAY_MAG_TAPE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MAG_TAPE" as
/* $Header: pymagtpe.pkb 120.8.12010000.1 2008/07/27 23:09:00 appldev ship $ */
  procedure run_proc(comm in varchar2)
   is
   sql_curs number;
   rows_processed integer;
   statem varchar2(256);
  begin
    statem := 'BEGIN '||comm||'; END;';
    sql_curs := dbms_sql.open_cursor;
    dbms_sql.parse(sql_curs,
                   statem,
                   dbms_sql.v7);
    rows_processed := dbms_sql.execute(sql_curs);
    dbms_sql.close_cursor(sql_curs);
  exception
      when no_data_found then
         dbms_sql.close_cursor(sql_curs);
         raise;
  end;


  procedure run_xml_proc(comm in varchar2,
                         source_id in number,
                         source_type in varchar2,
                         file_name in varchar2,
                         sequence in number)
   is
   sql_curs number;
   rows_processed integer;
   statem varchar2(256);
   l_source_type varchar2(30);
   l_source_id number;
  begin



     pay_core_files.open_file
                    (
                     p_source_id     => source_id,
                     p_source_type   => source_type,
                     p_file_location => file_name,
                     p_file_type     => 'XML',
                     p_int_file_name     => 'MAGFILE',
                     p_sequence      => sequence,
                     p_file_id       => pay_mag_tape.g_blob_file_id
                    );

    select blob_file_fragment
    into g_blob_value
    from pay_file_details
    where file_detail_id = pay_mag_tape.g_blob_file_id;

    statem := 'BEGIN '||comm||'; END;';
    sql_curs := dbms_sql.open_cursor;
    dbms_sql.parse(sql_curs,
                   statem,
                   dbms_sql.v7);
    rows_processed := dbms_sql.execute(sql_curs);
    dbms_sql.close_cursor(sql_curs);

      pay_core_files.close_file ( p_file_id       => pay_mag_tape.g_blob_file_id);

  end;


procedure call_leg_xml_proc
is

pactid number;
seq number;
mag_block number;
leg_code varchar2(30);
rep_grp number;
proc_name varchar2(250);
sql_curs number;
rows_processed integer;
statem varchar2(256);

begin

/* get payroll_action,report_group,record_id,legislation_code */
pactid:=pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID');
if (pactid is NULL)
then
pactid:=pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID');
end if;
seq:=pay_magtape_generic.get_parameter_value('rec_sequence');
mag_block:=pay_magtape_generic.get_parameter_value('magnetic_block_id');


select grp.legislation_code,prg.report_group_id
into leg_code ,rep_grp
from pay_payroll_actions ppa,pay_report_groups prg,per_business_groups_perf grp
where ppa.payroll_action_id=pactid
and grp.business_group_id=ppa.business_group_id
and  pay_core_utils.get_parameter('REP_GROUP', ppa.legislative_parameters)=prg.short_name;


/* retrieve procedure */
select procedure_name
into proc_name
from pay_report_magnetic_procedures
where  magnetic_block_id=mag_block
and sequence=seq
and rep_grp=report_group_id
and legislation_code=leg_code;

/* call procedure */
    statem := 'BEGIN '||proc_name||'; END;';
    sql_curs := dbms_sql.open_cursor;
    dbms_sql.parse(sql_curs,
                   statem,
                   dbms_sql.v7);
    rows_processed := dbms_sql.execute(sql_curs);
    dbms_sql.close_cursor(sql_curs);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return;
end;
end pay_mag_tape;

/
