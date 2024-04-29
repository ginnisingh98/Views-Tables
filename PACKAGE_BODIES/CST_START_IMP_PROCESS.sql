--------------------------------------------------------
--  DDL for Package Body CST_START_IMP_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_START_IMP_PROCESS" as
/* $Header: CSTSIMPB.pls 115.4 2002/11/11 22:57:00 awwang ship $ */

PROCEDURE Start_process(ERRBUF OUT NOCOPY VARCHAR2,
                        RETCODE OUT NOCOPY NUMBER,
                        i_option IN NUMBER,
                        i_run_option IN NUMBER,
                        i_group_option IN NUMBER,
                        i_group_dummy IN VARCHAR2,
                        i_next_val IN VARCHAR2,
                        i_cost_type IN VARCHAR2,
                        i_del_option IN NUMBER
                        ) as
i_opt NUMBER;
i_count NUMBER := 0;
l_next_val VARCHAR2(20);
CONC_STATUS BOOLEAN;
Error_number NUMBER := 0;
l_min_reqid NUMBER;
l_grp_id NUMBER;
l_req_arg VARCHAR2(20);
CST_ERROR_EXCEPTION EXCEPTION;
BEGIN
i_opt := 5;

l_next_val := i_next_val;

fnd_file.put_line(fnd_file.log,'---------------------------------------------');
fnd_file.put_line(fnd_file.log,'Option to import : ' || to_char(i_option));
fnd_file.put_line(fnd_file.log,'Mode to run      : ' || to_char(i_run_option));
fnd_file.put_line(fnd_file.log,'Group ID option  : ' || to_char(i_group_option));
fnd_file.put_line(fnd_file.log,'Group ID selected: ' || i_next_val);
fnd_file.put_line(fnd_file.log,'Cost type        : '|| i_cost_type);
fnd_file.put_line(fnd_file.log,'Delete option    : ' || to_char (i_del_option));
fnd_file.put_line(fnd_file.log,'---------------------------------------------');

/*check first to see if there is another request running with similar parameters */

select FCR.argument5 into l_req_arg
from FND_CONCURRENT_REQUESTS FCR
WHERE FCR.concurrent_program_id = FND_GLOBAL.CONC_PROGRAM_ID
AND FCR.program_application_id = FND_GLOBAL.PROG_APPL_ID
AND FCR.request_id = FND_GLOBAL.CONC_REQUEST_ID;

select min(FCR.request_id) into l_min_reqid
from FND_CONCURRENT_REQUESTS FCR
WHERE FCR.concurrent_program_id = FND_GLOBAL.CONC_PROGRAM_ID
      AND FCR.program_application_id = FND_GLOBAL.PROG_APPL_ID
      AND FCR.phase_code <> 'C'
      AND ((NVL(FCR.argument5,'X') = NVL(l_req_arg,'X'))
           OR (FCR.argument5 is null)
           OR (l_req_arg is null));

if (NVL(l_min_reqid,FND_GLOBAL.CONC_REQUEST_ID) <> FND_GLOBAL.CONC_REQUEST_ID) then
 fnd_file.put_line(fnd_file.log,fnd_message.get_string('BOM','CST_REQ_ERROR'));
 CONC_STATUS := fnd_concurrent.set_completion_status('ERROR',substr(fnd_message.get_string('BOM','CST_REQ_ERROR'),1,240));
 return;
end if;


/* check if the specific group ID has been sent in or null(ALL) has been sent in*/

If  l_next_val is null then
  select CST_LISTS_S.NEXTVAL into l_grp_id
  from dual;
else
  l_grp_id := to_number(l_next_val);
end if;

fnd_file.put_line(fnd_file.log,'---------------------------------------------');

fnd_file.put_line(fnd_file.log,'Group ID selected: ' || l_grp_id);

fnd_file.put_line(fnd_file.log,'---------------------------------------------');

fnd_file.put_line(fnd_file.log,'Start time: ' || to_char(sysdate,'DD-MON-YY HH24:MI:SS'));

IF i_option = 1 then
  CST_ITEM_COST_IMPORT_INTERFACE.Start_item_cost_import_process(Error_number,l_next_val,l_grp_id,i_del_option,i_cost_type,i_run_option);

ELSIF i_option = 2 then
 CST_RES_COST_IMPORT_INTERFACE.Start_res_cost_import_process(Error_number,l_next_val,l_grp_id,i_cost_type,i_del_option,i_run_option);

ELSIF i_option = 3 then
 CST_OVHD_RATE_IMPORT_INTERFACE.Start_process(Error_number,i_cost_type,l_next_val,l_grp_id,i_del_option,i_run_option);

ELSIF i_option = 4 then
  CST_ITEM_COST_IMPORT_INTERFACE.Start_item_cost_import_process(Error_number,l_next_val,l_grp_id,i_del_option,i_cost_type,i_run_option);

  IF Error_number = 1 then
    fnd_file.put_line(fnd_file.log,'Exception in CST_ITEM_COST_IMPORT_INTERFACE');
    raise CST_ERROR_EXCEPTION;
  END IF;

 CST_RES_COST_IMPORT_INTERFACE.Start_res_cost_import_process(Error_number,l_next_val,l_grp_id,i_cost_type,i_del_option,i_run_option);

  IF Error_number = 1 then
    raise CST_ERROR_EXCEPTION;
  END IF;

 CST_OVHD_RATE_IMPORT_INTERFACE.Start_process(Error_number,i_cost_type,l_next_val,l_grp_id,i_del_option,i_run_option);

  IF Error_number = 1 then
    raise CST_ERROR_EXCEPTION;
  END IF;

END IF;

fnd_file.put_line(fnd_file.log,'End date is : ' || to_char(sysdate,'DD-MON-YY HH24:MI:SS'));


EXCEPTION
 When others then
  rollback;
 fnd_file.put_line(fnd_file.log,'CST_START_IMP_PROCESS.Start_Process() '|| to_char(SQLCODE) || ','|| substr(SQLERRM,1,180));
 fnd_file.put_line(fnd_file.log,(fnd_message.get_string('BOM','CST_EXCEPTION_OCCURED')));


END Start_process;

END CST_START_IMP_PROCESS;

/
