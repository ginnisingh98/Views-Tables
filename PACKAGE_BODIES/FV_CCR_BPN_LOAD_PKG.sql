--------------------------------------------------------
--  DDL for Package Body FV_CCR_BPN_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_CCR_BPN_LOAD_PKG" as
/* $Header: FVBPNLDB.pls 120.2.12010000.7 2010/04/06 20:03:50 snama noship $*/

--type new_data is varray(235) of varchar2(200);
function insert_ccr_flags(p_duns in number,p_no_flags in number,p_flag_str in varchar2)
return boolean
is
l_flags_counter integer :=length(p_flag_str)/4;
l_flags_str varchar2(100) :=p_flag_str;
l_flag varchar2(3);
l_flag_val varchar2(1);
l_from_ind number :=1;
l_length number :=3;
l_module varchar2(50) := 'FV_CCR_BPN_LOAD_PKG.CCR_FLAGS';
l_errbuff varchar2(2000);


begin
FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,l_module, 'Flag String: ' || l_flags_str);
if p_no_flags <> l_flags_counter then
  fv_utility.log_mesg(FND_LOG.LEVEL_STATEMENT,l_module,'Count mismatch between flags present in string and counter passed.');
  return false;
end if;

for i in 1..l_flags_counter loop
  l_flag := substr(l_flags_str,l_from_ind, l_length);
  l_flag_val := substr(l_flags_str,l_from_ind +l_length,1);
  l_from_ind := i*4+1;
  --dbms_output.put_line('Flag: ' || l_flag || '. Value : '|| l_flag_val);
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,l_module, 'Flag: ' || l_flag || '. Value : '|| l_flag_val);
  insert into fv_ccr_flags(duns, flagtype, flagval) values(p_duns,
                                  l_flag,
                                  l_flag_val);
end loop;
return true;
Exception
when others then
return false;
end insert_ccr_flags;


procedure insert_ccr_codes(clob_buff in clob,
                           field_count_low in number,
                           field_count_high in number,
                           delimiter in varchar2,
                           proc_count in number,
                           from_index in number,
                           duns_num in varchar2,
                           retpos out nocopy  number)
is
--clob_buff clob;
--delimiter varchar2(1) := '"';
type codeTypeTab is table of varchar2(30) index by binary_integer;
codeType codeTypeTab;
field_counter number :=0;
--offset_low number :=1;
ext_from number :=0;
ext_to number :=0;
code_count varchar2(4);
code varchar2(158);
countmax number :=0;
code_counter number :=0;
count_offset number :=0;
l_module_name varchar2(1000);
l_errbuf varchar2(1000);
l_code_delim varchar2(1) := '.';
begin
  l_module_name := 'Insert CCR Codes';
  l_errbuf := 'Start. DUNS Number: '|| duns_num;
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, l_errbuf);
  --codeType(1) := 'BUS TYPE';
  --codeType(2) := 'SIC CODE';
  --codeType(3) := 'NAICS CODE';
  --codeType(4) := 'FSC CODE';
  --codeType(5) := 'PSC CODE';
  codeType(1) := 'FV_BUSINESS_TYPE';
  codeType(2) := 'FV_SIC_TYPE';
  codeType(3) := 'FV_NAICS_TYPE';
  codeType(4) := 'FV_FSC_TYPE';
  codeType(5) := 'FV_PSC_TYPE';

  codeType(6) := 'NAICS Exception';
  codeType(7) := 'External Certification';
  codeType(8) := 'SBA Certification';
  codeType(9) := 'CCR Numerics';
  codeType(10) := 'Disaster Response';
  --select ccr_info into clob_buff from junk_tab where rownum < 2;
  --clob_length := dbms_lob.getlength(clob_buff);
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,'Inside CCR_CODES','BEGIN.');
  for field_counter in field_count_low..field_count_high
  loop
    --insert into fv_ccr_bpn_log_messages values('Inside CCR_CODES','Looking from occurrence no: '||2*(field_counter+count_offset)+1);commit;
    ext_from := dbms_lob.instr(clob_buff, delimiter, from_index, 2*(field_counter+count_offset)+1);--count_offset)+1); --(txt, delim, from (1), 2*(field_counter+count_offset)+1 is the nth occurrence of delimiter)
    ext_to := dbms_lob.instr(clob_buff, delimiter, from_index, 2*(field_counter+count_offset)+2);--count_offset)+2);
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,'Inside CCR_CODES','Entering for loop. DUNS received is ' || duns_num);
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,'Inside CCR_CODES','Looking for counter b/w ' || ext_from || ' &' || ext_to);
    if (ext_from is NULL or ext_to is NULL) then
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,'Inside CCR_DATA','ext_from or ext_to is NULL');
      return;
    end if;
    if(ext_to-ext_from > 1) then
      code_count := dbms_lob.substr(clob_buff,ext_to-ext_from-1,ext_from+1);
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,'Inside CCR_CODES','Extracted counter is ' || code_count);
    else
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,'Inside CCR_CODES','Extracted counter is NULL');
    end if;

    select to_number(nvl(code_count,0)) into countmax from dual;
    if countmax > 0 then
      ext_from := ext_to +3;
    end if;
    for code_counter in  1..countmax loop
      --FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,'Inside CCR_CODES','from_index, field_counter, count_offset, code_counter: ' || from_index || ' , ' ||  field_counter || ' , ' ||  count_offset || ' , ' ||  code_counter);
      --ext_from := dbms_lob.instr(clob_buff, l_code_delim, from_index, 2*(field_counter+count_offset+code_counter)+1); --From_index in place of 1

      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,'Inside CCR_CODES','from_index, field_counter, count_offset, code_counter: ' || from_index || ' , ' || field_counter|| ' , ' || count_offset|| ' , '  ||code_counter);
   --   ext_to := dbms_lob.instr(clob_buff,l_code_delim,from_index,code_counter);--2*(field_counter+count_offset+code_counter)+2);--From_index in place of 1
      ext_to := dbms_lob.instr(clob_buff,l_code_delim,ext_from,1);--code_counter);
      if code_counter = countmax then
        ext_to := dbms_lob.instr(clob_buff,delimiter,ext_from,1);--2*(field_counter+count_offset+code_counter)+2);--From_index in place of 1
      end if;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,'Inside CCR_CODES','Looking for code b/w ' || ext_from || ' &' || ext_to);
      if(ext_to-ext_from > 1) then
        code := dbms_lob.substr(clob_buff,ext_to-ext_from,ext_from);
        --field := dbsm_lob.substr(clob_buff,
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,'Inside CCR_CODES','Extracted code is ' || code);
        insert into fv_ccr_class_codes(duns, codetype, code) values(duns_num,
                                                codeType(field_counter+proc_count+1),
                                                code);
      else
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,'Inside CCR_CODES','Extracted code is NULL');
      end if;
      ext_from :=ext_to +1;
    end loop;
 --   if countmax > 0 then
      count_offset := count_offset + 1; --countmax;
 --   end if;
  end loop;
  if countmax=0 then
     ext_to := ext_to+3;
  end if;
  retpos := ext_to+2;
  l_errbuf := 'End. DUNS Number: '|| duns_num;
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, l_errbuf);
  exception
  when others then
    l_errbuf := 'Exception occurred '||SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, 'Inside CCR_CODES','Unexpected exception: ' ||l_errbuf);
end insert_ccr_codes;

procedure insert_ccr_data(clob_buff in clob,
                          field_count_low in number,
                          field_count_high in number,
                          delimiter in varchar2,
                          proc_count in number,
                          from_index in number,
                          ccr_data in out nocopy new_data,
                          retpos out nocopy number
                          )
is
--clob_buff clob;
--delimiter varchar2(1) := '"';
--field_counter number :=1;
ext_from number :=0;
ext_to number :=0;
l_module_name varchar2(1000);
l_errbuf varchar2(1000);
begin
  l_module_name := 'CCR_DATA';
  l_errbuf := 'Start';
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

  for field_counter in field_count_low..field_count_high
  loop
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,'Inside CCR_DATA','Entering for loop.');
    ext_from := dbms_lob.instr(clob_buff, delimiter, from_index, 2*field_counter+1);
    ext_to := dbms_lob.instr(clob_buff,delimiter,from_index,2*field_counter+2);
    if (ext_from is NULL or ext_to is NULL) then
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,'Inside CCR_DATA','ext_from or ext_to is NULL');
      return;
    end if;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,'Inside CCR_DATA','Extract from ' ||ext_from);
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,'Inside CCR_DATA','Extract till ' ||ext_to);
    if(ext_to-ext_from > 1) then
      ccr_data(proc_count+field_counter+1) := dbms_lob.substr(clob_buff,ext_to-ext_from-1,ext_from+1);
      --field := dbsm_lob.substr(clob_buff,
      if(ccr_data(proc_count+field_counter+1)='!end')then return; end if;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,'Inside CCR_DATA','Extracted field ccr_data( ' || to_char(proc_count+field_counter+1) || ') is ' || ccr_data(proc_count+field_counter+1));
    else
      ccr_data(proc_count+field_counter+1) := null;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,'Inside CCR_DATA','Extracted field is NULL');
    end if;
    ext_from := ext_to;
    --dbms_output.put_line(substr(buff,1,10));
  end loop;
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,'Inside CCR_DATA', 'End');
  retpos := ext_to + 2;
  exception
  when others then
    l_errbuf := 'Exception occurred '||SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, 'Inside CCR_DATA','Unexpected exception: ' ||l_errbuf);
end insert_ccr_data;



procedure main is
--Get rows
cursor c_clob_data is select * from fv_ccr_bpn_clob_data where ccr_info not like '%BOF BPN COMPLETE%' and ccr_info not like '%EOF BPN COMPLETE%';
loop_counter number :=0;
field_counter number :=235; --Number of fields in fv_ccr_file_temp
from_index number :=1;
to_index number :=0;
clob_buff clob;
ccr_data new_data;
--ccr_codes new_codes;
proc_count number :=0;
l_success boolean;
l_module_name varchar2(1000);
l_errbuf varchar2(1000);
l_no_flags number;
begin
  l_module_name := 'CCR BPN Data Load';
  l_errbuf := 'Start of transfer';
  ccr_data := new_data();
  ccr_data.EXTEND(235);
  --ccr_codes := new_codes();
  --ccr_codes.EXTEND(235);
  delete from fv_ccr_file_temp;
--  delete from fv_ccr_class_codes;
--  delete from fv_ccr_flags;
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_PROCEDURE, l_module_name,l_errbuf);
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, 'Inside Main','Entering for loop');
  for rec in c_clob_data loop
    clob_buff := rec.ccr_info;
    --insert into fv_ccr_bpn_log_messages values('Clob text is', dbms_lob.substr(clob_buff,25,1));
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_PROCEDURE, 'Inside Main','Calling ccr_data. Identifying DUNS number.');
    insert_ccr_data(clob_buff,0,23,'"',0,from_index,ccr_data,to_index); -- 0 to 23 for BPN. 0 to 26 for BSD.
    from_index := to_index;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, 'Inside Main','Returned from first call. Continue processing from '|| to_index);
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, 'Inside Main','Calling ccr_codes to process DUNS ' || ccr_data(1));

    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,'Inside Main','Calling delete_ccr_codes, delete_ccr_flags for DUNS '||ccr_data(1));
    delete_ccr_codes(ccr_data(1));
    delete_ccr_flags(ccr_data(1));

    --FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, 'Inside Main','Calling CCR_CODES with 24|28|"|'||from_index || '|'|| ccr_data(1));
    --insert_ccr_codes(clob_buff,24,28,'"',from_index,ccr_data(1),ccr_codes,to_index); Correct for BPN. 27 to 31 for BSD Layout

    insert_ccr_codes(clob_buff,0,4,'"',proc_count,from_index,ccr_data(1),to_index);
    --FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,'Inside Main','Continue processing from '||to_index);commit;
    from_index :=to_index;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_PROCEDURE, 'Inside Main','Calling ccr_data for DUNS ' || ccr_data(1));
    insert_ccr_data(clob_buff,0,195,'"',29,from_index,ccr_data,to_index); --From field 29 for BPN Layout. 32 to 236 for BSD.
    from_index :=to_index;
    --FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,'Inside Main','Returned from 3rd call');
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, 'Inside Main','Calling ccr_codes for DUNS ' || ccr_data(1));
    insert_ccr_codes(clob_buff,0,3,'"',5,from_index,ccr_data(1),to_index);
    --FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,'Inside Main','Returned from last call. Processed till '|| to_index);
    from_index :=to_index;
    to_index :=dbms_lob.instr(clob_buff,'"',from_index+1,1);
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, 'Inside Main','From_index:To_index ' ||from_index||':'||to_index);
    l_no_flags := dbms_lob.substr(clob_buff,to_index-from_index-1,from_index+1);
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, 'Inside Main','No of flags ' ||l_no_flags);
    if l_no_flags > 0 then
      from_index :=to_index+2;
      to_index :=dbms_lob.instr(clob_buff,'"',from_index+1,1);
      l_success := insert_ccr_flags(ccr_data(1),l_no_flags, dbms_lob.substr(clob_buff,to_index-from_index-1,from_index+1));
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_PROCEDURE,'Inside Main','Finished parsing. Inserting record with DUNS' || ccr_data(1));
    end if;

    --Adding call to parse Disaster Response String.
    if l_no_flags > 0 then
    from_index :=to_index+2;
    else
    from_index :=to_index+4;
    end if;
    insert_ccr_codes(clob_buff,0,0,'"',9,from_index,ccr_data(1),to_index);

    /*for i in ccr_data.first..24 loop
      dbms_output.put_line('ccr_data(' ||i||') is :' ||ccr_data(i)||'::');
    end loop;
    for i in 30..ccr_data.last loop
      dbms_output.put_line('ccr_data(' ||i||') is :' ||ccr_data(i)||'::');
    end loop;*/
    INSERT INTO FV_CCR_FILE_TEMP(DUNS
                                  ,PLUS_FOUR
                                  ,CAGE_CODE
                                  ,EXTRACT_CODE
                                  ,REGISTRATION_DATE
                                  ,RENEWAL_DATE
                                  ,LEGAL_BUS_NAME
                                  ,DBA_NAME
                                  ,DIVISION_NAME
                                  ,DIVISION_NUMBER
                                  ,ST_ADDRESS1
                                  ,ST_ADDRESS2
                                  ,CITY
                                  ,STATE
                                  ,POSTAL_CODE
                                  ,COUNTRY
                                  ,BUSINESS_START_DATE
                                  ,FISCAL_YR_CLOSE_DATE
                                  ,CORP_SECURITY_LEVEL
                                  ,EMP_SECURITY_LEVEL
                                  ,WEB_SITE
                                  ,ORGANIZATIONAL_TYPE
                                  ,STATE_OF_INC
                                  ,COUNTRY_OF_INC
                                  ,CREDIT_CARD_FLAG
                                  ,CORRESPONDENCE_FLAG
                                  ,MAIL_POC
                                  ,MAIL_ADD1
                                  ,MAIL_ADD2
                                  ,MAIL_CITY
                                  ,MAIL_POSTAL_CODE
                                  ,MAIL_COUNTRY
                                  ,MAIL_STATE
                                  ,PREV_BUS_POC
                                  ,PREV_BUS_ADD1
                                  ,PREV_BUS_ADD2
                                  ,PREV_BUS_CITY
                                  ,PREV_BUS_POSTAL_CODE
                                  ,PREV_BUS_COUNTRY
                                  ,PREV_BUS_STATE
                                  ,PARENT_POC
                                  ,PARENT_DUNS
                                  ,PARENT_ADD1
                                  ,PARENT_ADD2
                                  ,PARENT_CITY
                                  ,PARENT_POSTAL_CODE
                                  ,PARENT_COUNTRY
                                  ,PARENT_STATE
                                  ,GOV_PARENT_POC
                                  ,GOV_PARENT_ADD1
                                  ,GOV_PARENT_ADD2
                                  ,GOV_PARENT_CITY
                                  ,GOV_PARENT_POSTAL_CODE
                                  ,GOV_PARENT_COUNTRY
                                  ,GOV_PARENT_STATE
                                  ,GOV_BUS_POC
                                  ,GOV_BUS_ADD1
                                  ,GOV_BUS_ADD2
                                  ,GOV_BUS_CITY
                                  ,GOV_BUS_POSTAL_CODE
                                  ,GOV_BUS_COUNTRY
                                  ,GOV_BUS_STATE
                                  ,GOV_BUS_US_PHONE
                                  ,GOV_BUS_US_PHONE_EX
                                  ,GOV_BUS_NON_US_PHONE
                                  ,GOV_BUS_FAX
                                  ,GOV_BUS_EMAIL
                                  ,ALT_GOV_BUS_POC
                                  ,ALT_GOV_BUS_ADD1
                                  ,ALT_GOV_BUS_ADD2
                                  ,ALT_GOV_BUS_CITY
                                  ,ALT_GOV_BUS_POSTAL_CODE
                                  ,ALT_GOV_BUS_COUNTRY
                                  ,ALT_GOV_BUS_STATE
                                  ,ALT_GOV_BUS_US_PHONE
                                  ,ALT_GOV_BUS_US_PHONE_EX
                                  ,ALT_GOV_BUS_NON_US_PHONE
                                  ,ALT_GOV_BUS_FAX
                                  ,ALT_GOV_BUS_EMAIL
                                  ,PAST_PERF_POC
                                  ,PAST_PERF_ADD1
                                  ,PAST_PERF_ADD2
                                  ,PAST_PERF_CITY
                                  ,PAST_PERF_POSTAL_CODE
                                  ,PAST_PERF_COUNTRY
                                  ,PAST_PERF_STATE
                                  ,PAST_PERF_US_PHONE
                                  ,PAST_PERF_US_PHONE_EX
                                  ,PAST_PERF_NON_US_PHONE
                                  ,PAST_PERF_FAX
                                  ,PAST_PERF_EMAIL
                                  ,ALT_PAST_PERF_POC
                                  ,ALT_PAST_PERF_ADD1
                                  ,ALT_PAST_PERF_ADD2
                                  ,ALT_PAST_PERF_CITY
                                  ,ALT_PAST_PERF_POSTAL_CODE
                                  ,ALT_PAST_PERF_COUNTRY
                                  ,ALT_PAST_PERF_STATE
                                  ,ALT_PAST_PERF_US_PHONE
                                  ,ALT_PAST_PERF_US_PHONE_EX
                                  ,ALT_PAST_PERF_NON_US_PHONE
                                  ,ALT_PAST_PERF_FAX
                                  ,ALT_PAST_PERF_EMAIL
                                  ,ELEC_BUS_POC
                                  ,ELEC_BUS_ADD1
                                  ,ELEC_BUS_ADD2
                                  ,ELEC_BUS_CITY
                                  ,ELEC_BUS_POSTAL_CODE
                                  ,ELEC_BUS_COUNTRY
                                  ,ELEC_BUS_STATE
                                  ,ELEC_BUS_US_PHONE
                                  ,ELEC_BUS_US_PHONE_EX
                                  ,ELEC_BUS_NON_US_PHONE
                                  ,ELEC_BUS_FAX
                                  ,ELEC_BUS_EMAIL
                                  ,ALT_ELEC_BUS_POC
                                  ,ALT_ELEC_BUS_ADD1
                                  ,ALT_ELEC_BUS_ADD2
                                  ,ALT_ELEC_BUS_CITY
                                  ,ALT_ELEC_BUS_POSTAL_CODE
                                  ,ALT_ELEC_BUS_COUNTRY
                                  ,ALT_ELEC_BUS_STATE
                                  ,ALT_ELEC_BUS_US_PHONE
                                  ,ALT_ELEC_BUS_US_PHONE_EX
                                  ,ALT_ELEC_BUS_NON_US_PHONE
                                  ,ALT_ELEC_BUS_FAX
                                  ,ALT_ELEC_BUS_EMAIL
                                  ,CERTIFIER_POC
                                  ,CERTIFIER_US_PHONE
                                  ,CERTIFIER_US_PHONE_EX
                                  ,CERTIFIER_NON_US_PHONE
                                  ,CERTIFIER_FAX
                                  ,CERTIFIER_EMAIL
                                  ,ALT_CERTIFIER_POC
                                  ,ALT_CERTIFIER_US_PHONE
                                  ,ALT_CERTIFIER_US_PHONE_EX
                                  ,ALT_CERTIFIER_NON_US_PHONE
                                  ,CORP_INFO_POC
                                  ,CORP_INFO_US_PHONE
                                  ,CORP_INFO_US_PHONE_EX
                                  ,CORP_INFO_NON_US_PHONE
                                  ,CORP_INFO_FAX
                                  ,CORP_INFO_EMAIL
                                  ,OWNER_INFO_POC
                                  ,OWNER_INFO_US_PHONE
                                  ,OWNER_INFO_US_PHONE_EX
                                  ,OWNER_INFO_NON_US_PHONE
                                  ,OWNER_INFO_FAX
                                  ,OWNER_INFO_EMAIL
                                  ,HQ_PARENT_POC
                                  ,HQ_PARENT_DUNS
                                  ,HQ_PARENT_ADD1
                                  ,HQ_PARENT_ADD2
                                  ,HQ_PARENT_CITY
                                  ,HQ_PARENT_POSTAL_CODE
                                  ,HQ_PARENT_COUNTRY
                                  ,HQ_PARENT_STATE
                                  ,HQ_PARENT_PHONE
                                  ,DOMESTIC_PARENT_POC
                                  ,DOMESTIC_PARENT_DUNS
                                  ,DOMESTIC_PARENT_ADD1
                                  ,DOMESTIC_PARENT_ADD2
                                  ,DOMESTIC_PARENT_CITY
                                  ,DOMESTIC_PARENT_POSTAL_CODE
                                  ,DOMESTIC_PARENT_COUNTRY
                                  ,DOMESTIC_PARENT_STATE
                                  ,DOMESTIC_PARENT_PHONE
                                  ,GLOBAL_PARENT_POC
                                  ,GLOBAL_PARENT_DUNS
                                  ,GLOBAL_PARENT_ADD1
                                  ,GLOBAL_PARENT_ADD2
                                  ,GLOBAL_PARENT_CITY
                                  ,GLOBAL_PARENT_POSTAL_CODE
                                  ,GLOBAL_PARENT_COUNTRY
                                  ,GLOBAL_PARENT_STATE
                                  ,GLOBAL_PARENT_PHONE
                                  ,DNB_MONITOR_LAST_UPDATED
                                  ,DNB_MONITOR_STATUS
                                  ,DNB_MONITOR_CORP_NAME
                                  ,DNB_MONITOR_DBA
                                  ,DNB_MONITOR_ST_ADD1
                                  ,DNB_MONITOR_ST_ADD2
                                  ,DNB_MONITOR_CITY
                                  ,DNB_MONITOR_POSTAL_CODE
                                  ,DNB_MONITOR_COUNTRY_CODE
                                  ,DNB_MONITOR_STATE
                                  ,EDI
                                  ,TAXPAYER_ID
                                  ,AVG_NUM_EMPLOYEES
                                  ,ANNUAL_RECEIPTS
                                  ,SOCIAL_SECURITY_NUMBER
                                  ,AUSTIN_TETRA_NUMBER
                                  ,AUSTIN_TETRA_PARENT_NUMBER
                                  ,AUSTIN_TETRA_ULTIMATE_NUMBER
                                  ,AUSTIN_TETRA_PCARD_FLAG
                                  ,FINANCIAL_INSTITUTE
                                  ,BANK_ACCT_NUMBER
                                  ,ABA_ROUTING
                                  ,PAYMENT_TYPE
                                  ,LOCKBOX_NUMBER
                                  ,AUTHORIZATION_DATE
                                  ,EFT_WAIVER
                                  ,ACH_US_PHONE
                                  ,ACH_NON_US_PHONE
                                  ,ACH_FAX
                                  ,ACH_EMAIL
                                  ,REMIT_POC
                                  ,REMIT_ADD1
                                  ,REMIT_ADD2
                                  ,REMIT_CITY
                                  ,REMIT_STATE
                                  ,REMIT_POSTAL_CODE
                                  ,REMIT_COUNTRY
                                  ,AR_POC
                                  ,AR_US_PHONE
                                  ,AR_US_PHONE_EX
                                  ,AR_NON_US_PHONE
                                  ,AR_FAX
                                  ,AR_EMAIL
                                  ,MPIN
                                  ,FILE_DATE)
                          values(ccr_data(1)
                                ,ccr_data(2)
                                ,ccr_data(3)
                                ,ccr_data(4)
                                ,to_date(ccr_data(5),'mmddrryy')
                                ,to_date(ccr_data(6),'mmddrryy')
                                ,ccr_data(7)
                                ,ccr_data(8)
                                ,ccr_data(9)
                                ,ccr_data(10)
                                ,ccr_data(11)
                                ,ccr_data(12)
                                ,ccr_data(13)
                                ,ccr_data(14)
                                ,ccr_data(15)
                                ,ccr_data(16)
                                ,to_date(ccr_data(17),'mmddrryy')
                                ,ccr_data(18)
                                ,ccr_data(19)
                                ,ccr_data(20)
                                ,ccr_data(21)
                                ,ccr_data(22)
                                ,ccr_data(23)
                                ,ccr_data(24)
                                ,ccr_data(30)
                                ,ccr_data(31)
                                ,ccr_data(32)
                                ,ccr_data(33)
                                ,ccr_data(34)
                                ,ccr_data(35)
                                ,ccr_data(36)
                                ,ccr_data(37)
                                ,ccr_data(38)
                                ,ccr_data(39)
                                ,ccr_data(40)
                                ,ccr_data(41)
                                ,ccr_data(42)
                                ,ccr_data(43)
                                ,ccr_data(44)
                                ,ccr_data(45)
                                ,ccr_data(46)
                                ,ccr_data(47)
                                ,ccr_data(48)
                                ,ccr_data(49)
                                ,ccr_data(50)
                                ,ccr_data(51)
                                ,ccr_data(52)
                                ,ccr_data(53)
                                ,ccr_data(54)
                                ,ccr_data(55)
                                ,ccr_data(56)
                                ,ccr_data(57)
                                ,ccr_data(58)
                                ,ccr_data(59)
                                ,ccr_data(60)
                                ,ccr_data(61)
                                ,ccr_data(62)
                                ,ccr_data(63)
                                ,ccr_data(64)
                                ,ccr_data(65)
                                ,ccr_data(66)
                                ,ccr_data(67)
                                ,ccr_data(68)
                                ,ccr_data(69)
                                ,ccr_data(70)
                                ,ccr_data(71)
                                ,ccr_data(72)
                                ,ccr_data(73)
                                ,ccr_data(74)
                                ,ccr_data(75)
                                ,ccr_data(76)
                                ,ccr_data(77)
                                ,ccr_data(78)
                                ,ccr_data(79)
                                ,ccr_data(80)
                                ,ccr_data(81)
                                ,ccr_data(82)
                                ,ccr_data(83)
                                ,ccr_data(84)
                                ,ccr_data(85)
                                ,ccr_data(86)
                                ,ccr_data(87)
                                ,ccr_data(88)
                                ,ccr_data(89)
                                ,ccr_data(90)
                                ,ccr_data(91)
                                ,ccr_data(92)
                                ,ccr_data(93)
                                ,ccr_data(94)
                                ,ccr_data(95)
                                ,ccr_data(96)
                                ,ccr_data(97)
                                ,ccr_data(98)
                                ,ccr_data(99)
                                ,ccr_data(100)
                                ,ccr_data(101)
                                ,ccr_data(102)
                                ,ccr_data(103)
                                ,ccr_data(104)
                                ,ccr_data(105)
                                ,ccr_data(106)
                                ,ccr_data(107)
                                ,ccr_data(108)
                                ,ccr_data(109)
                                ,ccr_data(110)
                                ,ccr_data(111)
                                ,ccr_data(112)
                                ,ccr_data(113)
                                ,ccr_data(114)
                                ,ccr_data(115)
                                ,ccr_data(116)
                                ,ccr_data(117)
                                ,ccr_data(118)
                                ,ccr_data(119)
                                ,ccr_data(120)
                                ,ccr_data(121)
                                ,ccr_data(122)
                                ,ccr_data(123)
                                ,ccr_data(124)
                                ,ccr_data(125)
                                ,ccr_data(126)
                                ,ccr_data(127)
                                ,ccr_data(128)
                                ,ccr_data(129)
                                ,ccr_data(130)
                                ,ccr_data(131)
                                ,ccr_data(132)
                                ,ccr_data(133)
                                ,ccr_data(134)
                                ,ccr_data(135)
                                ,ccr_data(136)
                                ,ccr_data(137)
                                ,ccr_data(138)
                                ,ccr_data(139)
                                ,ccr_data(140)
                                ,ccr_data(141)
                                ,ccr_data(142)
                                ,ccr_data(143)
                                ,ccr_data(144)
                                ,ccr_data(145)
                                ,ccr_data(146)
                                ,ccr_data(147)
                                ,ccr_data(148)
                                ,ccr_data(149)
                                ,ccr_data(150)
                                ,ccr_data(151)
                                ,ccr_data(152)
                                ,ccr_data(153)
                                ,ccr_data(154)
                                ,ccr_data(155)
                                ,ccr_data(156)
                                ,ccr_data(157)
                                ,ccr_data(158)
                                ,ccr_data(159)
                                ,ccr_data(160)
                                ,ccr_data(161)
                                ,ccr_data(162)
                                ,ccr_data(163)
                                ,ccr_data(164)
                                ,ccr_data(165)
                                ,ccr_data(166)
                                ,ccr_data(167)
                                ,ccr_data(168)
                                ,ccr_data(169)
                                ,ccr_data(170)
                                ,ccr_data(171)
                                ,ccr_data(172)
                                ,ccr_data(173)
                                ,ccr_data(174)
                                ,ccr_data(175)
                                ,ccr_data(176)
                                ,ccr_data(177)
                                ,ccr_data(178)
                                ,ccr_data(179)
                                ,ccr_data(180)
                                ,ccr_data(181)
                                ,ccr_data(182)
                                ,ccr_data(183)
                                ,ccr_data(184)
                                ,ccr_data(185)
                                ,ccr_data(186)
                                ,ccr_data(187)
                                ,ccr_data(188)
                                ,ccr_data(189)
                                ,ccr_data(190)
                                ,ccr_data(191)
                                ,ccr_data(192)
                                ,ccr_data(193)
                                ,ccr_data(194)
                                ,ccr_data(195)
                                ,ccr_data(196)
                                ,ccr_data(197)
                                ,ccr_data(198)
                                ,ccr_data(199)
                                ,ccr_data(200)
                                ,ccr_data(201)
                                ,ccr_data(202)
                                ,ccr_data(203)
                                ,ccr_data(204)
                                ,ccr_data(205)
                                ,to_date(ccr_data(206),'mmddrryy')
                                ,ccr_data(207)
                                ,ccr_data(208)
                                ,ccr_data(209)
                                ,ccr_data(210)
                                ,ccr_data(211)
                                ,ccr_data(212)
                                ,ccr_data(213)
                                ,ccr_data(214)
                                ,ccr_data(215)
                                ,ccr_data(216)
                                ,ccr_data(217)
                                ,ccr_data(218)
                                ,ccr_data(219)
                                ,ccr_data(220)
                                ,ccr_data(221)
                                ,ccr_data(222)
                                ,ccr_data(223)
                                ,ccr_data(224)
                                ,ccr_data(225)
                                ,sysdate); --Temporary substitute for file_date
    from_index :=1;
    to_index :=0;
  end loop;
  commit;
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, 'Inside Main','Committed changes. End of Transfer');
  exception
  when others then
    l_errbuf := 'Exception occurred '||SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);
    rollback;
end main;

procedure delete_ccr_codes(p_duns in varchar2)
is
l_module_name varchar2(60);
l_errbuf varchar2(500);
begin
  l_module_name := 'delete_ccr_codes';
  l_errbuf := 'Deleting the entries from fv_ccr_codes for Duns '||p_duns;

  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, l_errbuf);
  begin
  delete from fv_ccr_class_codes where duns = p_duns;
  exception when others then
  l_errbuf := 'Following exception encountered during deletion of codes and is ignored:'||SQLERRM;
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, l_errbuf);
  null;
  end;
end delete_ccr_codes;


procedure delete_ccr_flags(p_duns in varchar2)
is
l_module_name varchar2(60);
l_errbuf varchar2(500);
begin
  l_module_name := 'delete_ccr_flags';
  l_errbuf := 'Deleting the entries from fv_ccr_flags for Duns '||p_duns;

  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, l_errbuf);
  begin
  delete from fv_ccr_flags where duns = p_duns;
  exception when others then
  l_errbuf := 'Following exception encountered during deletion of flags and is ignored:'||SQLERRM;
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name, l_errbuf);
  null;
  end;
end delete_ccr_flags;

end fv_ccr_bpn_load_pkg;


/
