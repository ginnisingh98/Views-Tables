--------------------------------------------------------
--  DDL for Package Body AR_BR_FORMAT_WRAPPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_BR_FORMAT_WRAPPER_PKG" AS
/* $Header: ARBRFMTB.pls 120.2 2006/05/15 06:25:03 ggadhams ship $*/


PROCEDURE SUBMIT_FORMATS(
  errbuf            OUT NOCOPY VARCHAR2,
  retcode           OUT NOCOPY VARCHAR2,
  FORMAT   IN  VARCHAR2,
  BR   IN  NUMBER,
  AFROM       IN  NUMBER default NULL,
  ATO         IN  NUMBER default NULL,
  SOB     IN NUMBER
)
IS

v_format VARCHAR2(30):= (FORMAT);
v_br_id  NUMBER   := (BR);
v_amount_from NUMBER := (AFROM);
v_amount_to NUMBER := (ATO);
v_sob NUMBER := (SOB);

req_id NUMBER;

--Bug 5222370
l_org_id NUMBER;

-- Cursor For BR batches
CURSOR c_programs_br IS
select distinct prog.program_name program_name
from ra_cust_trx_types_all types
,  ap_payment_programs prog
,  ra_customer_trx trx
where types.format_program_id = prog.program_id
and types.cust_trx_type_id = trx.cust_trx_type_id
and trx.batch_id = v_br_id;

-- Cursor for Remittance batches
CURSOR c_programs_remit IS
select distinct prog.program_name program_name
from ra_cust_trx_types_all types
,  ap_payment_programs prog
,  ra_customer_trx trx
,  ar_payment_schedules sched
where types.format_program_id = prog.program_id
and types.cust_trx_type_id = trx.cust_trx_type_id
and sched.customer_trx_id = trx.customer_trx_id
and sched.reserved_type = 'REMITTANCE'
and sched.reserved_value = v_br_id;

-- For Individual BRs
CURSOR c_programs_ind IS
select distinct prog.program_name program_name
from ra_cust_trx_types_all types
,  ap_payment_programs prog
,  ra_customer_trx trx
where types.format_program_id = prog.program_id
and types.cust_trx_type_id = trx.cust_trx_type_id
and trx.customer_trx_id = v_br_id;

begin

--Bug 5222370
select org_id
into l_org_id
from fnd_concurrent_requests
where request_id = FND_PROFILE.value('CONC_REQUEST_ID');

IF v_format = 'BR BATCH' THEN
     for c_programs_br_rec in c_programs_br LOOP
        fnd_request.set_org_id(l_org_id);
        req_id:=fnd_request.submit_request('AR'
                            ,c_programs_br_rec.program_name
                            ,NULL
                            ,NULL
                            ,NULL
                            ,'P_FORMAT_OPTION="'||v_format||'"'
                            ,'P_BR_IDENTIFIER="'||v_br_id||'"'
                            ,'P_SET_OF_BOOKS_ID="'||v_sob||'"'
                            ,'P_AMOUNT_FROM="'||v_amount_from||'"'
                            ,'P_AMOUNT_TO="'||v_amount_to||'"'
                        );

        if (req_id = 0) then
                   FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured submiting request for BR Batch');
        else
           FND_FILE.PUT_LINE(FND_FILE.LOG,'Submitted Request - '||c_programs_br_rec.program_name||'. Request Id: '||to_char(req_id));
	end if;
        commit;
     END LOOP;
ELSIF v_format = 'REMIT BATCH' THEN
   for c_programs_remit_rec in c_programs_remit LOOP

	fnd_request.set_org_id(l_org_id);
        req_id:=fnd_request.submit_request('AR'
                            ,c_programs_remit_rec.program_name
                            ,NULL
                            ,NULL
                            ,NULL
                            ,'P_FORMAT_OPTION="'||v_format||'"'
                            ,'P_BR_IDENTIFIER="'||v_br_id||'"'
                            ,'P_SET_OF_BOOKS_ID="'||v_sob||'"'
                            ,'P_AMOUNT_FROM="'||v_amount_from||'"'
                            ,'P_AMOUNT_TO="'||v_amount_to||'"'
                        );

        if (req_id = 0) then
               FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured submiting request for Remittance Batch');
        else
             FND_FILE.PUT_LINE(FND_FILE.LOG,'Submitted Request - '||c_programs_remit_rec.program_name||'. Request Id: '||to_char(req_id));
	end if;
        commit;
     END LOOP;

ELSIF v_format = 'IND' THEN

	for c_programs_ind_rec in c_programs_ind LOOP

       fnd_request.set_org_id(l_org_id);
        req_id:=fnd_request.submit_request('AR'
                            ,c_programs_ind_rec.program_name
                            ,NULL
                            ,NULL
                            ,NULL
                            ,'P_FORMAT_OPTION="'||v_format||'"'
                            ,'P_BR_IDENTIFIER="'||v_br_id||'"'
                            ,'P_SET_OF_BOOKS_ID="'||v_sob||'"'
                            ,'P_AMOUNT_FROM="'||v_amount_from||'"'
                            ,'P_AMOUNT_TO="'||v_amount_to||'"'
                        );

        if (req_id = 0) then
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Error occured submiting request for Individual BR');
        else
           FND_FILE.PUT_LINE(FND_FILE.LOG,'Submitted Request - '||c_programs_ind_rec.program_name||'. Request Id: '||to_char(req_id));
        end if;
        commit;
     END LOOP;
ELSE
           FND_FILE.PUT_LINE(FND_FILE.LOG,'Invalid Format option');
END IF;

EXCEPTION
   WHEN FND_FILE.UTL_FILE_ERROR then
       errbuf:= substr(fnd_message.get,1,254);
       retcode:=2;
   WHEN OTHERS then
	errbuf:= substr(SQLERRM,1,254);
	retcode:=SQLCODE;

end SUBMIT_FORMATS;


end AR_BR_FORMAT_WRAPPER_PKG;

/
