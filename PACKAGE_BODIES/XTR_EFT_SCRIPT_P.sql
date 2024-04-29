--------------------------------------------------------
--  DDL for Package Body XTR_EFT_SCRIPT_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XTR_EFT_SCRIPT_P" as
/* $Header: xtreftsb.pls 120.14.12010000.3 2009/12/16 09:26:51 srsampat ship $ */
---------------------------------------------------------------------------------
PROCEDURE CALL_SCRIPTS(l_company IN VARCHAR2,
			     l_cparty IN VARCHAR2,
                       l_account IN VARCHAR2,
			     l_currency IN VARCHAR2,
			     l_script_name VARCHAR2,
                       paydate IN VARCHAR2,
			     l_prev_run IN VARCHAR2,
                        l_transmit_payment IN VARCHAR2,
			l_transmit_config_id  IN VARCHAR2,
			retcode OUT nocopy   NUMBER) is

-- This script will call all other eft scripts where appropriate based on the scripts selected
-- for running on the settlement_scripts table
--
cursor SEL_SCRIPTS is
 select distinct substr(script_name,1,4), package_name,eft_script_output_path,
 transmission_code
 from XTR_SETTLEMENT_SCRIPTS
   where script_type = 'SCRIPT'
   and script_name = l_script_name
   and authorised = 'Y';
  -- and run_requested_on is NOT NULL;
--
 v_request_id	VARCHAR2(8);
cursor SEL_FILE_NAME is
select outfile_name
 from fnd_concurrent_requests
  where request_id = v_request_id;

 cursor UNIQUE_FILE_NOS is
   select 1
     from DUAL;
--
 sett           VARCHAR2(1);
 l_eft_script VARCHAR2(4);
 l_package  VARCHAR2(20);
 l_path        VARCHAR2(50);
 l_transmit_number NUMBER;
 l_transmission_code VARCHAR2(100);
 l_unique_file_nos NUMBER;
 l_file_name  VARCHAR2(100);
 include_prev_generated_eft VARCHAR2(1);
 settlement_date DATE;
 v_procedure_call		VARCHAR2(250) := 'BEGIN XTR_EXT_SETTLE_SCRIPTS.';
 l_request_id number ;

--
begin
-- get request id
fnd_profile.get('CONC_REQUEST_ID', v_request_id);

IF xtr_risk_debug_pkg.g_Debug THEN
   XTR_RISK_DEBUG_PKG.dpush('CALL_SCRIPTS: ' || 'Call scripts');
END IF;
sett := l_prev_run;
-- cep_standard.enable_debug;
 IF xtr_risk_debug_pkg.g_Debug THEN
    XTR_RISK_DEBUG_PKG.dlog('>XTR_EFT_SCRIPT_P.call_scripts');
 END IF;
 settlement_date := to_date(paydate, 'YYYY/MM/DD HH24:MI:SS');

 IF xtr_risk_debug_pkg.g_Debug THEN
    XTR_RISK_DEBUG_PKG.dlog('CALL_SCRIPTS: ' || '>OPEN SEL_SCRIPTS');
 END IF;
 open SEL_SCRIPTS;
 LOOP
   IF xtr_risk_debug_pkg.g_Debug THEN
      XTR_RISK_DEBUG_PKG.dlog('CALL_SCRIPTS: ' || '>> LOOP');
   END IF;
   fetch SEL_SCRIPTS INTO l_eft_script, l_package, l_path, l_transmission_code;  --, sett; RV
   IF xtr_risk_debug_pkg.g_Debug THEN
      XTR_RISK_DEBUG_PKG.dlog('CALL_SCRIPTS: ' || '>> l_eft_script = '||l_eft_script||
			' l_package = '||l_package||
			' l_path = '||l_path ||
			' sett = '||sett);
   END IF;
 EXIT WHEN SEL_SCRIPTS%NOTFOUND;
 v_procedure_call := v_procedure_call || l_package || '(:a, :b, :c, :d, :e, :f, :g, :h); END;';
 -- Call the packages based on package name
 -- Get eft file number
 open UNIQUE_FILE_NOS;
   fetch UNIQUE_FILE_NOS INTO l_unique_file_nos;
   IF xtr_risk_debug_pkg.g_Debug THEN
      XTR_RISK_DEBUG_PKG.dlog('CALL_SCRIPTS: ' || '>> lunique_file_nos = ' ||l_unique_file_nos);
   END IF;
 close UNIQUE_FILE_NOS;
 --



-- Updated to grab correct file name
 --l_file_name :=  l_path||l_eft_script||to_char(l_unique_file_nos)||'.txt';

 open SEL_FILE_NAME;
   fetch SEL_FILE_NAME INTO l_file_name;
 close SEL_FILE_NAME;

/*select outfile_name  from fnd_concurrent_requests
 	into l_file_name
 	where request_id = v_request_id;
 */

IF xtr_risk_debug_pkg.g_Debug THEN
    XTR_RISK_DEBUG_PKG.dlog('CALL_SCRIPTS: ' || '>> l_file_name = ' ||l_file_name);
 END IF;
 --
 -- ***** As we add more scripts they need to be added in the if clause below *****
  if upper(l_package) = 'BNZ_EFT' then
   IF xtr_risk_debug_pkg.g_Debug THEN
      XTR_RISK_DEBUG_PKG.dlog('CALL_SCRIPTS: ' || '> Call XTR_EFT_SCRIPT_P.bnz_eft ...');
      XTR_RISK_DEBUG_PKG.dlog('CALL_SCRIPTS: ' || '> l_company = '|| l_company||
		      ' l_account = '||l_account||
                      ' l_currency = '|| l_currency||
		      ' l_eft_script = '||l_eft_script||
		      ' settlement_date = '||settlement_date||
		      ' include_prev_generated_eft = '||l_prev_run||
		      ' l_file_name = '||l_file_name);
   END IF;

    XTR_EFT_SCRIPT_P.BNZ_EFT(l_company,l_cparty,l_account, l_currency,l_eft_script,paydate,l_prev_run,l_file_name);

  elsif upper(l_package) = 'SWT_EFT' then
    XTR_EFT_SCRIPT_P.SWT_EFT(l_company, l_cparty,l_account, l_currency,l_eft_script,paydate,l_prev_run,l_file_name, retcode);

  elsif upper(l_package) = 'X12_EFT' then
    XTR_EFT_SCRIPT_P.X12_EFT(l_company, l_cparty,l_account, l_currency,l_eft_script,paydate,l_prev_run, l_file_name, retcode);

  else
    IF xtr_risk_debug_pkg.g_Debug THEN
      XTR_RISK_DEBUG_PKG.dlog('CALL_SCRIPTS: procedure call ' || v_procedure_call);
    end if;
    EXECUTE IMMEDIATE v_procedure_call
	USING l_company, l_cparty, l_account, l_currency, l_eft_script, paydate, l_prev_run, l_file_name, retcode;
   IF xtr_risk_debug_pkg.g_Debug THEN
      XTR_RISK_DEBUG_PKG.dlog('CALL_SCRIPTS: procedure call ' || v_procedure_call);
    end if;
  end if;
 END LOOP;
 IF xtr_risk_debug_pkg.g_Debug THEN
    XTR_RISK_DEBUG_PKG.dlog('CALL_SCRIPTS: ' || '>out of Loop');
 END IF;
 close SEL_SCRIPTS;

IF xtr_risk_debug_pkg.g_Debug THEN
   XTR_RISK_DEBUG_PKG.dpop('CALL_SCRIPTS: ' || 'Call scripts');
END IF;

 update XTR_SETTLEMENT_SCRIPTS
  set run_requested_on  = trunc(sysdate),
       last_run_on  = trunc(sysdate),
       last_run_by  = fnd_global.user_id,
       last_file_created = l_file_name
 where script_name = l_script_name
 and script_type = 'SCRIPT'
 and company_code = l_company;

 -- transmit if necessary
  if (l_transmit_payment = 'Yes') then -- payment transmission project
 -- Changed the sub reuest parameter value to false Bug 9203542
    l_request_id := FND_REQUEST.SUBMIT_REQUEST('XTR', 'XTRPAYTRANSDEF', '','', FALSE,
					      l_company,l_cparty, l_currency,
					      l_account, l_script_name, l_transmit_payment,
					      paydate, l_prev_run, l_file_name,
					      l_transmit_config_id );
	IF l_request_id = 0 THEN
		RAISE APP_EXCEPTION.application_exception;
	END IF;

  end if;

end CALL_SCRIPTS;
----------------------------------------------------------------------------------------------------------------
PROCEDURE BNZ_EFT (l_company IN VARCHAR2,
			 l_cparty IN VARCHAR2,
                              l_account IN VARCHAR2,
                              l_currency IN VARCHAR2,
                              l_eft_script_name IN VARCHAR2,
                              paydate  IN VARCHAR2,
                              sett IN VARCHAR2,
                              l_file_name IN VARCHAR2) is
--
-- paydate = Date to generate EFT transactions (in char format DDMMYYYY)
-- sett       = Include transactions previously generated
--
spce                   VARCHAR2(1) := ',';
comp_acct          VARCHAR2(20);
comp_acct_ins    VARCHAR2(20);
deb_header         VARCHAR2(255);
deb_rec              VARCHAR2(255);
deb_ctrl              VARCHAR2(255);
deb_count          NUMBER := 0;
deb_amt             NUMBER := 0;
deb_tot_amt       NUMBER := 0;
deb_hash           VARCHAR2(13);
--d_hash              NUMBER := 0; RV
d_hash              VARCHAR2(100);
deb_acct           VARCHAR2(20);
cre_header        VARCHAR2(255);
cre_rec             VARCHAR2(255);
cre_ctrl             VARCHAR2(255);
cre_count          NUMBER := 0;
cre_amt            NUMBER := 0;
cre_tot_amt      NUMBER := 0;
cre_hash          VARCHAR2(13);
--c_hash             NUMBER := 0;
c_hash             VARCHAR2(100);
cre_acct           VARCHAR2(20);
settlement_date    DATE;
curr NUMBER := 0;
mts_details 	VARCHAR2(255);
mts_file_name     VARCHAR2(255);

--
-- Header Block
cursor HEADER_REC is
 select distinct d.account_no
  from XTR_DEAL_DATE_AMOUNTS_V d,
       XTR_BANK_ACCOUNTS b,
       XTR_SETTLEMENT_SCRIPTS s
-- RV 2305918 where d.actual_settlement_date = NVL(to_date(settlement_date,'DD-MON-RR'), d.actual_settlement_date)
  where d.actual_settlement_date = NVL(trunc(settlement_date), d.actual_settlement_date)
  and d.company_code = l_company
  and NVL(d.beneficiary_party,d.cparty_code)  like nvl(l_cparty,'%')
  and d.account_no = NVL(l_account, d.account_no)
  and d.currency = NVL(l_currency, d.currency)
  and d.trans_mts = 'Y'
  and ((upper(sett) = 'Y') or (upper(sett) = 'N' and d.settlement_actioned is NULL))
  and b.account_number = d.account_no
  and b.party_code = l_company
  and SUBSTR(b.eft_script_name,1,4) = l_eft_script_name --RV
  and s.script_name = b.eft_script_name
  and nvl(s.currency_code,b.currency) = b.currency
  and s.script_type = 'SCRIPT';
--
-- Direct Debits
cursor DEBIT_REC is
 select abs(d.settle_amount * 100),
           d.cparty_account_no,'2'||spce||substr(d.cparty_account_no,1,2)||
           substr(d.cparty_account_no,4,4)||substr(d.cparty_account_no,9,7)||
           substr(d.cparty_account_no,17)||spce||'50'||spce||to_char(abs(d.settle_amount * 100))||
           spce||p.short_name||spce||spce||spce||spce||q.short_name||spce||
           'Ref '||rtrim(l_file_name)||spce
  from XTR_EFT_DEBITS_V d,
       XTR_PARTIES_V p,
       XTR_PARTIES_V q,
       XTR_BANK_ACCOUNTS b
-- 2305918  where d.actual_settlement_date = NVL(to_date(settlement_date,'DD-MON-RR'), d.actual_settlement_date)
  where d.actual_settlement_date = NVL(trunc(settlement_date), d.actual_settlement_date)
  and d.account_no = comp_acct
  and d.company_code = l_company
  and NVL(d.settle_party,d.cparty_code) like nvl(l_cparty,'%')
  and d.trans_mts = 'Y'
  and ((upper(sett) = 'Y') or (upper(sett) = 'N' and d.settlement_actioned is NULL))
  and q.party_code = d.company_code
  and p.party_code = d.settle_party
  and b.account_number = d.account_no
  and b.party_code = d.company_code;
--
-- Direct Credits
cursor CREDIT_REC is
 select abs(d.settle_amount * 100),
           d.cparty_account_no,'2'||spce||substr(d.cparty_account_no,1,2)||
           substr(d.cparty_account_no,4,4)||substr(d.cparty_account_no,9,7)||
           substr(d.cparty_account_no,17)||spce||'50'||spce||to_char(abs(d.settle_amount *
           100))||spce||p.short_name||spce||spce||spce||
           spce||q.short_name||spce||'Ref '||rtrim(l_file_name)||spce
  from XTR_EFT_CREDITS_V d,
       XTR_PARTIES_V p,
       XTR_PARTIES_V q,
       XTR_BANK_ACCOUNTS b
--2305918  where d.actual_settlement_date = NVL(to_date(settlement_date,'DD-MON-RR'), d.actual_settlement_date)
  where d.actual_settlement_date = NVL(trunc(settlement_date), d.actual_settlement_date)
  and d.account_no = comp_acct
  and d.company_code = l_company
  and NVL(d.settle_party,d.cparty_code) like nvl(l_cparty,'%')
  and ((upper(sett) = 'Y' ) or (upper(sett) = 'N' and d.settlement_actioned is NULL))
  and q.party_code = d.company_code
  and p.party_code = d.settle_party
  and b.account_number = d.account_no
  and b.party_code = d.company_code;


--
-- fetch from XTR_MTS_RECORDS spool to file
--
cursor MTS_REC is
 select transfer_details, file_name
 from XTR_MTS_RECORDS
 order by FILE_NAME,CREATED_ON_DATE asc;

--
 l_date DATE := sysdate;
--
begin
--
IF xtr_risk_debug_pkg.g_Debug THEN
   XTR_RISK_DEBUG_PKG.dlog('>XTR_SETTLEMENT.bnz_eft');
END IF;
settlement_date := to_date(paydate, 'YYYY/MM/DD HH24:MI:SS');
IF xtr_risk_debug_pkg.g_Debug THEN
   XTR_RISK_DEBUG_PKG.dlog('BNZ_EFT: ' || '>settlement_date = '||settlement_date);
   XTR_RISK_DEBUG_PKG.dlog('BNZ_EFT: ' || '>OPEN Header_Rec');
END IF;
open HEADER_REC;
 fetch HEADER_REC INTO comp_acct;
 IF xtr_risk_debug_pkg.g_Debug THEN
    XTR_RISK_DEBUG_PKG.dlog('BNZ_EFT: ' || '> comp_acct = '|| comp_acct);
 END IF;
while HEADER_REC%FOUND LOOP
 comp_acct_ins := substr(comp_acct,1,2)||substr(comp_acct,4,4)||substr(comp_acct,9,7)||
                            substr(comp_acct,17);
 IF xtr_risk_debug_pkg.g_Debug THEN
    XTR_RISK_DEBUG_PKG.dlog('BNZ_EFT: ' || '> OPEN DEBIT_REC');
 END IF;
 open DEBIT_REC;
  IF xtr_risk_debug_pkg.g_Debug THEN
     XTR_RISK_DEBUG_PKG.dlog('BNZ_EFT: ' || '> Fetch Debit_rec ...');
  END IF;
  fetch DEBIT_REC into deb_amt,deb_acct,deb_rec;

 if DEBIT_REC%FOUND then
 IF xtr_risk_debug_pkg.g_Debug THEN
    XTR_RISK_DEBUG_PKG.dlog('BNZ_EFT: ' || '> IF Debit_rec Found');
 END IF;

 deb_header := '1'||spce||spce||spce||spce||comp_acct_ins||spce||'6'||spce||
		   settlement_date||spce|| sysdate||spce;
 IF xtr_risk_debug_pkg.g_Debug THEN
    XTR_RISK_DEBUG_PKG.dlog('BNZ_EFT: ' || '>deb_header = '|| deb_header);
 END IF;

   l_date := l_date + 0.000011;
   IF xtr_risk_debug_pkg.g_Debug THEN
      XTR_RISK_DEBUG_PKG.dlog('BNZ_EFT: ' || '> l_date = '|| l_date);
      XTR_RISK_DEBUG_PKG.dlog('BNZ_EFT: ' || '>Insert into XTR_MTS_RECORDS');
      XTR_RISK_DEBUG_PKG.dlog('BNZ_EFT: ' || '>l_eft_Script_name = '|| l_eft_script_name||
 		      ' cre_header = '||cre_header||
                      ' l_date = '||l_date||
                      ' l_file_name = '|| l_file_name||
                      ' settlement_date = '|| settlement_date);
   END IF;

   insert into XTR_MTS_RECORDS(script_name,transfer_details,created_on_date,
                                            file_name,settlement_date)
                                  values(l_eft_script_name,deb_header,l_date,l_file_name,
--2305918                                            to_date(settlement_date,'DD-MON-RR'));
                                            trunc(settlement_date));

   IF xtr_risk_debug_pkg.g_Debug THEN
      XTR_RISK_DEBUG_PKG.dlog('BNZ_EFT: ' || '> End of insertion');
   END IF;
 end if;
 while DEBIT_REC%FOUND LOOP
   IF xtr_risk_debug_pkg.g_Debug THEN
      XTR_RISK_DEBUG_PKG.dlog('BNZ_EFT: ' || '>> while DEBIT_REC Found ');
   END IF;
   deb_tot_amt := deb_tot_amt + deb_amt;
   deb_count := deb_count + 1;
   IF xtr_risk_debug_pkg.g_Debug THEN
      XTR_RISK_DEBUG_PKG.dlog('BNZ_EFT: ' || 'deb_acct = '||deb_acct);
   END IF;
   curr := 1;

   --RV
   Begin
   d_hash := d_hash ||substr(substr(deb_acct,1,2)||substr(deb_acct,4,4)||
                   substr(deb_acct,9,7)||substr(deb_acct,17),3,11);
   Exception
   	When Others then NULL;
   End;

   curr := 2;
   l_date := l_date + 0.000011;
   IF xtr_risk_debug_pkg.g_Debug THEN
      XTR_RISK_DEBUG_PKG.dlog('BNZ_EFT: ' || '>>Insert into XTR_MTS_RECORDS');
   END IF;
   insert into XTR_MTS_RECORDS(script_name,transfer_details,created_on_date,
                                            file_name,settlement_date)
                                  values(l_eft_script_name,deb_rec,l_date,l_file_name,
--RV 2305918                                            to_date(settlement_date,'DD-MON-RR'));
                                            trunc(settlement_date));
   IF xtr_risk_debug_pkg.g_Debug THEN
      XTR_RISK_DEBUG_PKG.dlog('BNZ_EFT: ' || '>>Fetch...');
   END IF;
  fetch DEBIT_REC into deb_amt,deb_acct,deb_rec;
 END LOOP;
 IF xtr_risk_debug_pkg.g_Debug THEN
    XTR_RISK_DEBUG_PKG.dlog('BNZ_EFT: ' || '>>Close Debit_Rec');
 END IF;
 close DEBIT_REC;
 if deb_count > 0 then
  if length(d_hash) < 11 then
   deb_hash := lpad(d_hash,11,'0');
  elsif length(d_hash) = 12 then
   deb_hash := substr(d_hash,2);
  elsif length(d_hash) = 13 then
   deb_hash := substr(d_hash,3);
  elsif length(d_hash) = 14 then
   deb_hash := substr(d_hash,4);
  end if;
  deb_ctrl := '3'||spce||to_char(deb_tot_amt)||spce||to_char(deb_count)||spce||deb_hash;
   l_date := l_date + 0.000011;
   insert into XTR_MTS_RECORDS(script_name,transfer_details,created_on_date,
                                            file_name,settlement_date)
                                  values(l_eft_script_name,deb_ctrl,l_date,l_file_name,
--RV 2305918                                            to_date(settlement_date,'DD-MON-RR'));
                                            trunc(settlement_date));

 end if;
 deb_count := 0;
 IF xtr_risk_debug_pkg.g_Debug THEN
    XTR_RISK_DEBUG_PKG.dlog('BNZ_EFT: ' || '>Open CREDIT_REC');
 END IF;
 open CREDIT_REC;
  IF xtr_risk_debug_pkg.g_Debug THEN
     XTR_RISK_DEBUG_PKG.dlog('BNZ_EFT: ' || '>Fetch  CREDIT_REC');
  END IF;
  fetch CREDIT_REC into cre_amt,cre_acct,cre_rec;
 if CREDIT_REC%FOUND then
  cre_header := '1'||spce||spce||spce||spce||comp_acct_ins||spce||'7'||spce||
                       settlement_date||spce||sysdate||spce;

   l_date := l_date + 0.000011;
   IF xtr_risk_debug_pkg.g_Debug THEN
      XTR_RISK_DEBUG_PKG.dlog('BNZ_EFT: ' || '> l_date = ' || l_date);
      XTR_RISK_DEBUG_PKG.dlog('BNZ_EFT: ' || '> Insert into XTR_MTS_RECORDS');
      XTR_RISK_DEBUG_PKG.dlog('BNZ_EFT: ' || '>l_eft_Script_name = '|| l_eft_script_name||
 		      ' cre_header = '||cre_header||
                      ' l_date = '||l_date||
                      ' l_file_name = '|| l_file_name||
                      ' settlement_date = '|| settlement_date);
   END IF;
   insert into XTR_MTS_RECORDS(script_name,transfer_details,created_on_date,
                                            file_name,settlement_date)
                                  values(l_eft_script_name,cre_header,l_date,l_file_name,
-- RV 2305918                                            to_date(settlement_date,'DD-MON-RR'));
                                            trunc(settlement_date));
   IF xtr_risk_debug_pkg.g_Debug THEN
      XTR_RISK_DEBUG_PKG.dlog('BNZ_EFT: ' || '> End of Insert');
   END IF;
 end if;

--
 while CREDIT_REC%FOUND LOOP
  cre_tot_amt := cre_tot_amt + cre_amt;
  cre_count := cre_count + 1;
  curr := 1;
  Begin
  c_hash := c_hash ||substr(substr(cre_acct,1,2)||substr(cre_acct,4,4)||
                 substr(cre_acct,9,7)||substr(cre_acct,17),3,11);
  Exception
 	When Others then NULL;
  End;

   curr := 2;
   l_date := l_date + 0.000011;
   insert into XTR_MTS_RECORDS(script_name,transfer_details,created_on_date,
                                            file_name,settlement_date)
                                  values(l_eft_script_name,cre_rec,l_date,l_file_name,
-- RV 2305918                                            to_date(settlement_date,'DD-MON-RR'));
                                            trunc(settlement_date));

  fetch CREDIT_REC into cre_amt,cre_acct,cre_rec;
 END LOOP;
--
close CREDIT_REC;
 if cre_count > 0 then
  if length(c_hash) < 11 then
   cre_hash := lpad(c_hash,11,'0');
  elsif length(c_hash) = 12 then
   cre_hash := substr(c_hash,2);
  elsif length(c_hash) = 13 then
   cre_hash := substr(c_hash,3);
  elsif length(c_hash) = 14 then
   cre_hash := substr(c_hash,4);
  end if;
  cre_ctrl := '3'||spce||to_char(cre_tot_amt)||spce||to_char(cre_count)||spce||cre_hash;
   l_date := l_date + 0.000011;
   insert into XTR_MTS_RECORDS(script_name,transfer_details,created_on_date,
                                            file_name,settlement_date)
                                  values(l_eft_script_name,cre_ctrl,l_date,l_file_name,
--RV 2305198                                            to_date(settlement_date,'DD-MON-RR'));
                                            trunc(settlement_date));


 end if;
 cre_count := 0;
 --
 IF xtr_risk_debug_pkg.g_Debug THEN
    XTR_RISK_DEBUG_PKG.dlog('BNZ_EFT: ' || '>UPDATE xtr_settlement_scripts table');
 END IF;
 update XTR_SETTLEMENT_SCRIPTS
  set run_requested_on  = null,
       only_new_transactions = null,
--RV 2305918       last_run_on  = to_date(settlement_date,'DD-MON-RR'),
       last_run_on  = trunc(settlement_date),
       last_run_by  = fnd_global.user_id,
       last_file_created = l_file_name
 where substr(script_name,1,4) = l_eft_script_name
 and script_type = 'SCRIPT';
--
IF xtr_risk_debug_pkg.g_Debug THEN
   XTR_RISK_DEBUG_PKG.dlog('BNZ_EFT: ' || '>UPDATE dda table');
END IF;
update XTR_DEAL_DATE_AMOUNTS d
 set d.SETTLEMENT_ACTIONED = 'Y',
       d.SETTLEMENT_ACTIONED_FILE  = l_file_name
-- RV 2305918 where d.actual_settlement_date = NVL(to_date(settlement_date,'DD-MON-RR'), d.actual_settlement_date)
 where d.actual_settlement_date = NVL(trunc(settlement_date), d.actual_settlement_date)
 and d.cashflow_amount <> 0
 and d.account_no = comp_acct
 and d.company_code = l_company
 and NVL(d.beneficiary_party,d.cparty_code) like nvl(l_cparty,'%')
 and d.trans_mts = 'Y'
 and d.settle = 'Y'
 and ((upper(sett) = 'Y') or (upper(sett) = 'N' and d.settlement_actioned is NULL))
 and d.account_no = (select distinct b.account_number
                                  from XTR_BANK_ACCOUNTS b,
                                       XTR_SETTLEMENT_SCRIPTS s
                                  where b.account_number = d.account_no
                                  and b.party_code = upper(l_company)
                                  and SUBSTR(b.eft_script_name,1,4) = l_eft_script_name --RV
                                  and s.script_name = b.eft_script_name
                                  and nvl(s.currency_code,b.currency) = b.currency
                                  and s.script_type = 'SCRIPT');

--
 fetch HEADER_REC INTO comp_acct;
END LOOP;
--

--
-- spool into file
--
IF xtr_risk_debug_pkg.g_Debug THEN
   XTR_RISK_DEBUG_PKG.dlog('BNZ_EFT: ' || '>OPEN MTS_REC');
END IF;
OPEN MTS_REC;
  Fetch MTS_REC into mts_details, mts_file_name;
  IF xtr_risk_debug_pkg.g_Debug THEN
     XTR_RISK_DEBUG_PKG.dlog('BNZ_EFT: ' || '> mts_details = '||mts_details||
		     ' mts_file_name = '||mts_file_name);
  END IF;

WHILE MTS_REC%FOUND LOOP
  IF xtr_risk_debug_pkg.g_Debug THEN
     XTR_RISK_DEBUG_PKG.dlog('BNZ_EFT: ' || '> LOOP...');
     XTR_RISK_DEBUG_PKG.dlog('BNZ_EFT: ' || '> mts_details = '||mts_details||
		     ' mts_file_name = '||mts_file_name);
  END IF;

  --FND_FILE.put_names ('eft.log', 'eft.out', '/tmp/');
  FND_FILE.put_line(FND_FILE.OUTPUT, mts_details);
  --FND_FILE.new_line(FND_FILE.OUTPUT,1);
  --
  -- delete data from XTR_MTS_RECORDS table
  --
  DELETE from XTR_MTS_RECORDS
  WHERE file_name = mts_file_name
	AND transfer_details = mts_details;

  IF xtr_risk_debug_pkg.g_Debug THEN
     XTR_RISK_DEBUG_PKG.dlog('BNZ_EFT: ' || '>fetch MTS_REC');
  END IF;
  Fetch MTS_REC into mts_details, mts_file_name;
END LOOP;

commit;

EXCEPTION
  WHEN OTHERS THEN
    IF (curr=1) THEN
       IF xtr_risk_debug_pkg.g_Debug THEN
          XTR_RISK_DEBUG_PKG.dlog('BNZ_EFT: ' || 'EXCEPTION: Wrong Debit Account Format');
       END IF;
       FND_FILE.put_line(FND_FILE.LOG, 'EXCEPTION: Debit Account is in the wrong format');
       FND_FILE.put_line(FND_FILE.LOG, 'EXCEPTION: Correct Format is XX-XXXX-XXXXXXX-XX');
       RAISE;
    ELSE
       IF xtr_risk_debug_pkg.g_Debug THEN
          XTR_RISK_DEBUG_PKG.dlog('EXCEPTION: XTR_EFT_SCRIPT_P.BNZ_EFT');
       END IF;
       RAISE;
    END IF;

END BNZ_EFT;
----------------------------------------------------------------------------------------------------------------











PROCEDURE SWT_EFT (l_company IN VARCHAR2,
			 l_cparty IN VARCHAR2,
                              l_account IN VARCHAR2,
                              l_currency IN VARCHAR2,
                              l_eft_script_name IN VARCHAR2,
                              paydate  IN VARCHAR2,
                              sett IN VARCHAR2,
			      l_file_name IN VARCHAR2,
				retcode OUT nocopy   NUMBER) is

v_account_no		VARCHAR2(20);
v_settlement_number	NUMBER;
v_company		VARCHAR2(7);
v_cparty		VARCHAR2(7);
v_comp_name		VARCHAR2(50);
v_cp_name		VARCHAR2(50);
v_currency		VARCHAR2(15);
v_settlement_amount	NUMBER;
v_settlement_amount_c	VARCHAR2(15);
v_settlement_date	DATE;
v_company_acct_no       VARCHAR2(20);
v_cparty_acct_no	VARCHAR2(20);
v_comp_swift_id		VARCHAR2(50);
v_cp_swift_id		VARCHAR2(50);
v_comp_address1		VARCHAR2(50);
v_comp_address2		VARCHAR2(50);
v_comp_address3		VARCHAR2(50);
v_cp_address1		VARCHAR2(50);
v_cp_address2		VARCHAR2(50);
v_cp_address3		VARCHAR2(50);
v_comp_bank_code	VARCHAR2(7);
v_cp_bank_code		VARCHAR2(7);
v_comp_bank_name	VARCHAR2(50);
v_cp_bank_name		VARCHAR2(50);
v_comp_bank_location	VARCHAR2(35);
v_cp_bank_location	VARCHAR2(35);
v_comp_bank_street	VARCHAR2(35);
v_cp_bank_street	VARCHAR2(35);
v_cp_corr_bank_name     VARCHAR2(100);
v_cp_corr_bank_no	VARCHAR2(20);
v_output_date		DATE;
v_paydate		DATE;
v_request_id		VARCHAR2(8);
v_exc_description	VARCHAR2(256);
v_settlement_summary_id NUMBER;
v_netcount		NUMBER;
v_sett_act		NUMBER;
v_correct_cp		NUMBER;
v_group_id		NUMBER;
-- Gets applicable bank accounts
cursor HEADER_REC is
 select distinct sw.company_acct_no
  from XTR_SWIFT_EFT_V sw,
       XTR_BANK_ACCOUNTS b,
       XTR_SETTLEMENT_SCRIPTS s
  where sw.settlement_date = NVL(trunc(settlement_date), sw.settlement_date)
  and sw.company = l_company
  and sw.cparty = nvl(l_cparty,sw.cparty)
  and sw.company_acct_no = NVL(l_account, sw.company_acct_no)
  and sw.currency = NVL(l_currency, sw.currency)
  and b.account_number = sw.company_acct_no
  and b.party_code = l_company
  and SUBSTR(b.eft_script_name,1,4) = l_eft_script_name --RV
  and s.script_name = b.eft_script_name
  and nvl(s.currency_code,b.currency) = b.currency
  and s.script_type = 'SCRIPT';

cursor CREDIT_REC is
 select s.settlement_number, s.settlement_date, s.currency,
	abs(s.settlement_amount), comp_name, comp_address1,
	comp_address2, comp_address3, company_acct_no, comp_swift_id,
	comp_bank_name, comp_bank_street, comp_bank_location,
	cparty_acct_no, cp_swift_id, cp_bank_name, cp_bank_street,
	cp_bank_location, cp_name, cp_address1, cp_address2,
	cp_address3, cp_corr_bank_name,cp_corr_bank_no,
        s.settlement_summary_id, s.cparty
  from XTR_SWIFT_EFT_V s
  where trunc(s.settlement_date) = trunc(NVL(trunc(v_paydate), s.settlement_date))
  and s.company_acct_no = v_account_no
  and s.company = l_company
  and s.cparty = nvl(l_cparty,s.cparty);

cursor NET_COUNT is
  select count(*)
    from xtr_settlement_summary
    where net_id = v_settlement_summary_id;


  cursor correct_counterparty is
    select count(*)
    from xtr_deal_date_amounts x
    where x.settlement_number = v_settlement_number
    and ((x.beneficiary_account_no is not null and v_cparty = x.beneficiary_party)
         or
         (x.beneficiary_account_no is null and v_cparty = x.cparty_code));

  cursor correct_counterparty_net is
    select count(*)
    from xtr_deal_date_amounts x, xtr_settlement_summary s1,
    xtr_settlement_summary s2
    where s1.settlement_number = v_settlement_number
    and s1.settlement_summary_id = s2.net_id
    and s2.settlement_number = x.settlement_number
    and ((x.beneficiary_account_no is not null and v_cparty = x.beneficiary_party)
         or
         (x.beneficiary_account_no is null and v_cparty = x.cparty_code));

  cursor settlement_actioned is
    select count(*)
    from xtr_deal_date_amounts x
    where x.settlement_number = v_settlement_number
    and ((upper(sett) = 'Y') OR (x.settlement_actioned is null));

  cursor settlement_actioned_net is
    select count(*)
    from xtr_deal_date_amounts x, xtr_settlement_summary s1,
    xtr_settlement_summary s2
    where s1.settlement_number = v_settlement_number
    and s1.settlement_summary_id = s2.net_id
    and s2.settlement_number = x.settlement_number
    and ((upper(sett) = 'Y') OR (x.settlement_actioned is null));

  --bug 3195086
  cursor get_groupid(p_netid VARCHAR2) is
    SELECT netoff_number
    FROM xtr_deal_date_amounts
    where settlement_number = (select settlement_number
                               from xtr_settlement_summary
                               WHERE net_id = p_netid
                               and ROWNUM=1);

  --bug 3195086
  procedure filter_blanks(p_string varchar2) is
  begin
    if (p_string is not null) then
      FND_FILE.put_line(FND_FILE.OUTPUT, p_string);
    end if;
  end filter_blanks;

begin
v_paydate := to_date(paydate, 'YYYY/MM/DD HH24:MI:SS');

IF xtr_risk_debug_pkg.g_Debug THEN
   XTR_RISK_DEBUG_PKG.dpush('SWT_EFT');
   XTR_RISK_DEBUG_PKG.dlog('SWT_EFT: prev run is ' || sett);
  XTR_RISK_DEBUG_PKG.dlog('SWT_EFT: l_company is ' || l_company);
   XTR_RISK_DEBUG_PKG.dlog('SWT_EFT: l_cparty is' || l_cparty);
   XTR_RISK_DEBUG_PKG.dlog('SWT_EFT: CHAR Settlement date is ' || paydate);
   XTR_RISK_DEBUG_PKG.dlog('SWT_EFT: Settlement date is ' || v_paydate);
   XTR_RISK_DEBUG_PKG.dlog('SWT_EFT: attempt at varchar ' || to_char( v_paydate, 'YYMMDD'));
END IF;

IF xtr_risk_debug_pkg.g_Debug THEN
   XTR_RISK_DEBUG_PKG.dlog('SWT_EFT: ' || '>OPEN Header_Rec');
END IF;

open HEADER_REC;
 fetch HEADER_REC INTO v_account_no;
 IF xtr_risk_debug_pkg.g_Debug THEN
    XTR_RISK_DEBUG_PKG.dlog('SWT_EFT: ' || '> comp_acct = '|| v_account_no);
 END IF;
 while HEADER_REC%FOUND LOOP


 open CREDIT_REC;
  IF xtr_risk_debug_pkg.g_Debug THEN
     XTR_RISK_DEBUG_PKG.dlog('SWT_EFT: ' || '>Fetch  CREDIT_REC');
  END IF;
  fetch CREDIT_REC into v_settlement_number, v_settlement_date, v_currency,
  	v_settlement_amount, v_comp_name, v_comp_address1, v_comp_address2,
      	v_comp_address3, v_company_acct_no, v_comp_swift_id, v_comp_bank_name,
	v_comp_bank_street, v_comp_bank_location, v_cparty_acct_no,
	v_cp_swift_id, v_cp_bank_name, v_cp_bank_street, v_cp_bank_location,
	v_cp_name, v_cp_address1, v_cp_address2, v_cp_address3,
	v_cp_corr_bank_name, v_cp_corr_bank_no, v_settlement_summary_id,
        v_cparty;

--
 while CREDIT_REC%FOUND LOOP
  /* Code to take care of the case where settlements have been netted */
  open NET_COUNT;
  fetch NET_COUNT into v_netcount;
  close NET_COUNT;
  if v_netcount > 0 then
    open settlement_actioned_net;
    fetch settlement_actioned_net into v_sett_act;
    close settlement_actioned_net;
  else
    open settlement_actioned;
    fetch settlement_actioned into v_sett_act;
    close settlement_actioned;
  end if;

  if v_netcount > 0 then
    open correct_counterparty_net;
    fetch correct_counterparty_net into v_correct_cp;
    close correct_counterparty_net;
  else
    open correct_counterparty;
    fetch correct_counterparty into v_correct_cp;
    close correct_counterparty;
  end if;

  if v_netcount > 0 then
    open get_groupid(v_settlement_summary_id);
    fetch get_groupid into v_group_id;
    close get_groupid;
    v_settlement_number := nvl(v_group_id,v_settlement_number);
  end if;


  if v_sett_act > 0 and v_correct_cp > 0 then

    IF xtr_risk_debug_pkg.g_Debug THEN
      XTR_RISK_DEBUG_PKG.dlog('SWT_EFT: inside credit rec settlement number ' || v_settlement_number  );
    END IF;
    FND_FILE.put_line(FND_FILE.OUTPUT, ':20:' || v_settlement_number);

    v_settlement_amount_c := replace(to_char(v_settlement_amount), '.', ',');

    if INSTR(v_settlement_amount_c, ',') = 0 THEN
	 IF xtr_risk_debug_pkg.g_Debug THEN
   		XTR_RISK_DEBUG_PKG.dlog('SWT_EFT: adding comma'  );
  	END IF;
	v_settlement_amount_c := v_settlement_amount_c || ',';
    end if;




    FND_FILE.put_line(FND_FILE.OUTPUT, ':32A:' || to_char( v_settlement_date, 'YYMMDD') || v_currency || v_settlement_amount_c);
    IF xtr_risk_debug_pkg.g_Debug THEN
      XTR_RISK_DEBUG_PKG.dlog('SWT_EFT: ' || ':32A:' || to_char( v_settlement_date, 'YYMMDD') || v_currency || v_settlement_amount_c);
    END IF;

    FND_FILE.put_line(FND_FILE.OUTPUT, ':50:' || substr(v_comp_name, 1, 35));
    --Bug 3195086
    FILTER_BLANKS(substr(v_comp_address1, 1, 35));
    FILTER_BLANKS(substr(v_comp_address2, 1, 35));
    FILTER_BLANKS(substr(v_comp_address3, 1, 35));
    IF xtr_risk_debug_pkg.g_Debug THEN
      XTR_RISK_DEBUG_PKG.dlog('SWT_EFT: ' ||':50:' || substr(v_comp_name, 1, 35));
    END IF;

    --Bug 3195086: FND_FILE.put_line(FND_FILE.OUTPUT, ':53B:/' || v_company_acct_no);

    if ((v_cp_corr_bank_name IS NOT NULL) AND (v_cp_corr_bank_no IS NOT NULL)) THEN
	FND_FILE.put_line(FND_FILE.OUTPUT, ':54A:' || v_cp_corr_bank_name);
	FND_FILE.put_line(FND_FILE.OUTPUT, v_cp_corr_bank_no);

    END IF;

    if v_cp_swift_id is null then
      FND_FILE.put_line(FND_FILE.OUTPUT, ':57D:/' || v_cparty_acct_no);
      FND_FILE.put_line(FND_FILE.OUTPUT, v_cp_bank_name);
      FND_FILE.put_line(FND_FILE.OUTPUT, v_cp_bank_street);
      FND_FILE.put_line(FND_FILE.OUTPUT, v_cp_bank_location);
      FND_FILE.put_line(FND_FILE.OUTPUT, '');
    else
      FND_FILE.put_line(FND_FILE.OUTPUT, ':57A:/' || v_cparty_acct_no);
      FND_FILE.put_line(FND_FILE.OUTPUT, v_cp_swift_id);
    end if;

    FND_FILE.put_line(FND_FILE.OUTPUT, ':59:/' || v_cparty_acct_no);
    --Bug 3195086
    FILTER_BLANKS(substr(v_cp_name, 1, 35));
    FILTER_BLANKS(substr(v_cp_address1, 1, 35));
    FILTER_BLANKS(substr(v_cp_address2, 1, 35));
    FILTER_BLANKS(substr(v_cp_address3, 1, 35));

    FND_FILE.put_line(FND_FILE.OUTPUT, ':70:/ROC/' || v_settlement_number);

    FND_FILE.put_line(FND_FILE.OUTPUT, '');

    fnd_profile.get('CONC_REQUEST_ID', v_request_id);

    if v_netcount > 0 then
  	  update XTR_DEAL_DATE_AMOUNTS d
          set d.SETTLEMENT_ACTIONED = 'Y',
    	     d.SETTLEMENT_ACTIONED_FILE  = l_file_name
  	  where SETTLEMENT_NUMBER in
            (select settlement_number from xtr_settlement_summary x
                    where x.net_id = v_settlement_summary_id);
    else
          update XTR_DEAL_DATE_AMOUNTS d
  	   set d.SETTLEMENT_ACTIONED = 'Y',
    	     d.SETTLEMENT_ACTIONED_FILE  = l_file_name
  	  where SETTLEMENT_NUMBER = v_settlement_number;
    end if;

  end if;
  fetch CREDIT_REC into v_settlement_number, v_settlement_date, v_currency,
  	v_settlement_amount, v_comp_name, v_comp_address1, v_comp_address2,
      	v_comp_address3, v_company_acct_no, v_comp_swift_id, v_comp_bank_name,
	v_comp_bank_street, v_comp_bank_location, v_cparty_acct_no,
	v_cp_swift_id, v_cp_bank_name, v_cp_bank_street, v_cp_bank_location,
	v_cp_name, v_cp_address1, v_cp_address2, v_cp_address3,
	v_cp_corr_bank_name, v_cp_corr_bank_no, v_settlement_summary_id,
        v_cparty;
 END LOOP;

 close CREDIT_REC;



 fetch HEADER_REC INTO v_account_no;
END LOOP;

close HEADER_REC;
IF xtr_risk_debug_pkg.g_Debug THEN
   XTR_RISK_DEBUG_PKG.dpop('SWT_EFT');
END IF;

commit;

END SWT_EFT;


PROCEDURE X12_EFT (l_company IN VARCHAR2,
			 l_cparty IN VARCHAR2,
                              l_account IN VARCHAR2,
                              l_currency IN VARCHAR2,
                              l_eft_script_name IN VARCHAR2,
                              paydate  IN VARCHAR2,
                              sett IN VARCHAR2,
			      l_file_name IN VARCHAR2,
				retcode OUT nocopy   NUMBER) is


v_account_no		VARCHAR2(20);
v_settlement_number	NUMBER;
v_company		VARCHAR2(7);
v_cparty		VARCHAR2(7);
v_comp_name		VARCHAR2(50);
v_cp_name		VARCHAR2(50);
v_currency		VARCHAR2(15);
v_settlement_amount	NUMBER;
v_settlement_amount_c	VARCHAR2(15);
v_settlement_date	DATE;
v_company_acct_no       VARCHAR2(20);
v_cparty_acct_no	VARCHAR2(20);
v_comp_swift_id		VARCHAR2(50);
v_cp_swift_id		VARCHAR2(50);
v_comp_address1		VARCHAR2(50);
v_comp_address2		VARCHAR2(50);
v_comp_address3		VARCHAR2(50);
v_cp_address1		VARCHAR2(50);
v_cp_address2		VARCHAR2(50);
v_cp_address3		VARCHAR2(50);
v_comp_bank_code	VARCHAR2(7);
v_cp_bank_code		VARCHAR2(7);
v_comp_bank_name	VARCHAR2(50);
v_cp_bank_name		VARCHAR2(50);
v_comp_bank_location	VARCHAR2(35);
v_cp_bank_location	VARCHAR2(35);
v_comp_bank_street	VARCHAR2(35);
v_cp_bank_street	VARCHAR2(35);
v_exc_desc		VARCHAR2(256);
v_output_date		DATE;
v_paydate		DATE;
v_request_id		VARCHAR2(8);
v_settlement_summary_id NUMBER;
v_netcount		NUMBER;
v_sett_act		NUMBER;
v_correct_cp		NUMBER;
v_prompt		VARCHAR2(100);

-- Gets applicable bank accounts
cursor HEADER_REC is
 select distinct sw.company_acct_no
  from XTR_SWIFT_EFT_V sw,
       XTR_BANK_ACCOUNTS b,
       XTR_SETTLEMENT_SCRIPTS s
  where sw.settlement_date = NVL(trunc(settlement_date), sw.settlement_date)
  and sw.company = l_company
  and sw.cparty = nvl(l_cparty,sw.cparty)
  and sw.company_acct_no = NVL(l_account, sw.company_acct_no)
  and sw.currency = NVL(l_currency, sw.currency)
  and b.account_number = sw.company_acct_no
  and b.party_code = l_company
  and SUBSTR(b.eft_script_name,1,4) = l_eft_script_name --RV
  and s.script_name = b.eft_script_name
  and nvl(s.currency_code,b.currency) = b.currency
  and s.script_type = 'SCRIPT';

cursor CREDIT_REC is
 select s.settlement_number, s.settlement_date, s.currency,
	abs(s.settlement_amount), comp_name, comp_address1,
	comp_address2, comp_address3, company_acct_no, comp_swift_id,
	comp_bank_name, comp_bank_street, comp_bank_location,
	cparty_acct_no, cp_swift_id, cp_bank_name, cp_bank_street,
	cp_bank_location, cp_name, cp_address1, cp_address2,
	cp_address3, s.company, s.cparty, s.settlement_summary_id
  from XTR_SWIFT_EFT_V s
  where trunc(s.settlement_date) = trunc(NVL(trunc(v_paydate), s.settlement_date))
  and s.company_acct_no = v_account_no
  and s.company = l_company
  and s.cparty = nvl(l_cparty,s.cparty);

  cursor NET_COUNT is
  select count(*)
    from xtr_settlement_summary x
    where x.net_id = v_settlement_summary_id;

  cursor settlement_actioned is
    select count(*)
    from xtr_deal_date_amounts x
    where x.settlement_number = v_settlement_number
    and ((upper(sett) = 'Y') OR (x.settlement_actioned is null));

  cursor settlement_actioned_net is
    select count(*)
    from xtr_deal_date_amounts x, xtr_settlement_summary s1,
    xtr_settlement_summary s2
    where s1.settlement_number = v_settlement_number
    and s1.settlement_summary_id = s2.net_id
    and s2.settlement_number = x.settlement_number
    and ((upper(sett) = 'Y') OR (x.settlement_actioned is null));

  cursor correct_counterparty is
    select count(*)
    from xtr_deal_date_amounts x
    where x.settlement_number = v_settlement_number
    and ((x.beneficiary_account_no is not null and v_cparty = x.beneficiary_party)
         or
         (x.beneficiary_account_no is null and v_cparty = x.cparty_code));

  cursor correct_counterparty_net is
    select count(*)
    from xtr_deal_date_amounts x, xtr_settlement_summary s1,
    xtr_settlement_summary s2
    where s1.settlement_number = v_settlement_number
    and s1.settlement_summary_id = s2.net_id
    and s2.settlement_number = x.settlement_number
    and ((x.beneficiary_account_no is not null and v_cparty = x.beneficiary_party)
         or
         (x.beneficiary_account_no is null and v_cparty = x.cparty_code));

  cursor company_address_prompt is
    SELECT text
    FROM xtr_sys_languages_tl
    WHERE module_name='XTRSECOM'
    AND item_name='PTY.ADDRESS_1'
    AND LANGUAGE=USERENV('lang');

  cursor cparty_address_prompt is
    SELECT text
    FROM xtr_sys_languages_tl
    WHERE module_name='XTRSECPY'
    AND item_name='PTY.P_ADDRESS_1'
    AND LANGUAGE=USERENV('lang');

begin



v_paydate := to_date(paydate, 'YYYY/MM/DD HH24:MI:SS');

IF xtr_risk_debug_pkg.g_Debug THEN
   XTR_RISK_DEBUG_PKG.dpush('X12_EFT');
   XTR_RISK_DEBUG_PKG.dlog('X12_EFT: prev run is ' || sett);
  XTR_RISK_DEBUG_PKG.dlog('X12_EFT: l_company is ' || l_company);
   XTR_RISK_DEBUG_PKG.dlog('X12_EFT: l_cparty is' || l_cparty);
   XTR_RISK_DEBUG_PKG.dlog('X12_EFT: CHAR Settlement date is ' || paydate);
   XTR_RISK_DEBUG_PKG.dlog('X12_EFT: Settlement date is ' || v_paydate);

END IF;

IF xtr_risk_debug_pkg.g_Debug THEN
   XTR_RISK_DEBUG_PKG.dlog('X12_EFT: ' || '>OPEN Header_Rec');
END IF;

open HEADER_REC;
 fetch HEADER_REC INTO v_account_no;

 IF xtr_risk_debug_pkg.g_Debug THEN
    XTR_RISK_DEBUG_PKG.dlog('X12_EFT: ' || '> comp_acct = '|| v_account_no);
 END IF;
 while HEADER_REC%FOUND LOOP


 open CREDIT_REC;
  IF xtr_risk_debug_pkg.g_Debug THEN
     XTR_RISK_DEBUG_PKG.dlog('X12_EFT: ' || '>Fetch  CREDIT_REC');
  END IF;
  fetch CREDIT_REC into v_settlement_number, v_settlement_date, v_currency,
  	v_settlement_amount, v_comp_name, v_comp_address1, v_comp_address2,
      	v_comp_address3, v_company_acct_no, v_comp_swift_id, v_comp_bank_name,
	v_comp_bank_street, v_comp_bank_location, v_cparty_acct_no,
	v_cp_swift_id, v_cp_bank_name, v_cp_bank_street, v_cp_bank_location,
	v_cp_name, v_cp_address1, v_cp_address2, v_cp_address3, v_company,
        v_cparty, v_settlement_summary_id;

--
 while CREDIT_REC%FOUND LOOP

  /* Code to take care of the case where settlements have been netted */
  open NET_COUNT;
  fetch NET_COUNT into v_netcount;
  close NET_COUNT;

  if v_netcount > 0 then
    open settlement_actioned_net;
    fetch settlement_actioned_net into v_sett_act;
    close settlement_actioned_net;
  else
    open settlement_actioned;
    fetch settlement_actioned into v_sett_act;
    close settlement_actioned;
  end if;

   if v_netcount > 0 then
    open correct_counterparty_net;
    fetch correct_counterparty_net into v_correct_cp;
    close correct_counterparty_net;
  else
    open correct_counterparty;
    fetch correct_counterparty into v_correct_cp;
    close correct_counterparty;
  end if;

  if v_sett_act > 0 and v_correct_cp > 0 then

    -- If settlement amount is more that 99,999,999.99 this format is not valid
    IF v_settlement_amount > 99999999.99 THEN
	FND_MESSAGE.set_name('XTR', 'XTR_X12_EXCEED_AMOUNT');
        FND_MESSAGE.set_token('SETT_NO',v_settlement_number);
        v_exc_desc := FND_MESSAGE.get;
	retcode := 1;
    	FND_FILE.put_line(FND_FILE.LOG, v_exc_desc);

    -- Must have a swift id set up for company's bank account
    ELSIF v_comp_swift_id is null THEN
        FND_MESSAGE.set_name('XTR', 'XTR_X12_NO_COMP_SID');
        FND_MESSAGE.set_token('COMP', v_comp_name);
        FND_MESSAGE.set_token('BANK_ACC',v_company_acct_no);
        FND_MESSAGE.set_token('SETT_NO',v_settlement_number);
        v_exc_desc := FND_MESSAGE.get;
	retcode:=1;
	FND_FILE.put_line(FND_FILE.LOG, v_exc_desc);

    ELSIF v_cp_swift_id is null THEN
        FND_MESSAGE.set_name('XTR', 'XTR_X12_NO_CP_SID');
        FND_MESSAGE.set_token('CP', v_cp_name);
        FND_MESSAGE.set_token('BANK_ACC',v_cparty_acct_no);
        FND_MESSAGE.set_token('SETT_NO',v_settlement_number);
        v_exc_desc := FND_MESSAGE.get;
	retcode:=1;
	FND_FILE.put_line(FND_FILE.LOG, v_exc_desc);

    --bug 3185544
    ELSIF v_comp_address1 is null THEN
        FND_MESSAGE.set_name('XTR', 'XTR_X12_NO_COMP_ADDRESS');
        open company_address_prompt;
        fetch company_address_prompt into v_prompt;
        close company_address_prompt;
        FND_MESSAGE.set_token('ADDR_TAG',v_prompt);
        FND_MESSAGE.set_token('COMP', v_comp_name);
        FND_MESSAGE.set_token('SETT_NO',v_settlement_number);
        v_exc_desc := FND_MESSAGE.get;
	retcode:=1;
	FND_FILE.put_line(FND_FILE.LOG, v_exc_desc);

    --bug 3185544
    ELSIF v_cp_address1 is null THEN
        FND_MESSAGE.set_name('XTR', 'XTR_X12_NO_CP_ADDRESS');
        open cparty_address_prompt;
        fetch cparty_address_prompt into v_prompt;
        close cparty_address_prompt;
        FND_MESSAGE.set_token('ADDR_TAG',v_prompt);
        FND_MESSAGE.set_token('COMP', v_cp_name);
        FND_MESSAGE.set_token('SETT_NO',v_settlement_number);
        v_exc_desc := FND_MESSAGE.get;
	retcode:=1;
	FND_FILE.put_line(FND_FILE.LOG, v_exc_desc);

    ELSE

  	IF xtr_risk_debug_pkg.g_Debug THEN
   	  XTR_RISK_DEBUG_PKG.dlog('X12_EFT: inside credit rec settlement number ' || v_settlement_number  );
  	END IF;

	FND_FILE.put_line(FND_FILE.OUTPUT, 'ST*820*' || v_settlement_number);
	FND_FILE.put_line(FND_FILE.OUTPUT, 'BPR*D*'|| v_settlement_amount ||
		'*C*FWT**02*' || v_comp_swift_id || '*DA*'|| v_company_acct_no
		|| '**' || v_company || '*02*' || v_cp_swift_id || '*DA*' ||
		v_cparty_acct_no || '*' || to_char( v_settlement_date, 'YYYYMMDD') );
	FND_FILE.put_line(FND_FILE.OUTPUT, 'CUR*PR*' || v_currency);

	FND_FILE.put_line(FND_FILE.OUTPUT, 'N1*PR*' || v_comp_name);
	FND_FILE.put_line(FND_FILE.OUTPUT, 'N3*' || v_comp_address1 || '*'
		|| v_comp_address2);

	FND_FILE.put_line(FND_FILE.OUTPUT, 'N1*PE*' || v_cp_name);
	FND_FILE.put_line(FND_FILE.OUTPUT, 'N3*' || v_cp_address1 || '*'
		|| v_cp_address2);
	FND_FILE.put_line(FND_FILE.OUTPUT, 'SE*8*' || v_settlement_number);



  	fnd_profile.get('CONC_REQUEST_ID', v_request_id);

        if v_netcount > 0 then
  	  update XTR_DEAL_DATE_AMOUNTS d
          set d.SETTLEMENT_ACTIONED = 'Y',
    	     d.SETTLEMENT_ACTIONED_FILE  = l_file_name
  	  where SETTLEMENT_NUMBER in
            (select settlement_number from xtr_settlement_summary x
                    where x.net_id = v_settlement_summary_id);
        else
          update XTR_DEAL_DATE_AMOUNTS d
  	   set d.SETTLEMENT_ACTIONED = 'Y',
    	     d.SETTLEMENT_ACTIONED_FILE  = l_file_name
  	  where SETTLEMENT_NUMBER = v_settlement_number;
        end if;
    END IF;
  end if;
  fetch CREDIT_REC into v_settlement_number, v_settlement_date, v_currency,
  	v_settlement_amount, v_comp_name, v_comp_address1, v_comp_address2,
      	v_comp_address3, v_company_acct_no, v_comp_swift_id, v_comp_bank_name,
	v_comp_bank_street, v_comp_bank_location, v_cparty_acct_no,
	v_cp_swift_id, v_cp_bank_name, v_cp_bank_street, v_cp_bank_location,
	v_cp_name, v_cp_address1, v_cp_address2, v_cp_address3, v_company,
        v_cparty, v_settlement_summary_id;
 END LOOP;

 close CREDIT_REC;



 fetch HEADER_REC INTO v_account_no;
END LOOP;

close HEADER_REC;
IF xtr_risk_debug_pkg.g_Debug THEN
   XTR_RISK_DEBUG_PKG.dpop('X12_EFT');
END IF;

commit;



END X12_EFT;







end XTR_EFT_SCRIPT_P;

/
