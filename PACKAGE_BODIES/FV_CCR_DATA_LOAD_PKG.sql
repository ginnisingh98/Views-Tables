--------------------------------------------------------
--  DDL for Package Body FV_CCR_DATA_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FV_CCR_DATA_LOAD_PKG" AS
/* $Header: FVCCRLDB.pls 120.4.12010000.7 2009/10/26 11:30:59 sthota ship $*/

type l_bus_codes is table of fnd_lookup_values.lookup_code%type index by binary_integer;

--sthota
type l_vendor_ids is table of fv_ccr_vendors.vendor_id%type index by binary_integer;
vendor_ids l_vendor_ids;

type l_duns is table of fv_ccr_vendors.duns%type index by binary_integer;
duns_ids l_duns;


type lookup_info is record
 ( rec_type varchar2(2),
   code varchar2(10)
   );

type lookup_data  is table of lookup_info index by  binary_integer;

bus_code l_bus_codes;
sic_code l_bus_codes;
naic_code l_bus_codes;
fsc_code l_bus_codes;
psc_code l_bus_codes;

CURSOR c_bus_codes IS SELECT lookup_code from fnd_lookup_values where lookup_type = 'FV_BUSINESS_TYPE' and language = userenv('LANG');
CURSOR c_sic_codes IS SELECT lookup_code from fnd_lookup_values where lookup_type = 'FV_SIC_TYPE' and language = userenv('LANG');
CURSOR c_naic_codes IS SELECT lookup_code from fnd_lookup_values where lookup_type = 'FV_NAICS_TYPE' and language = userenv('LANG');
CURSOR c_fsc_codes IS SELECT lookup_code from fnd_lookup_values where lookup_type = 'FV_FSC_TYPE' and language = userenv('LANG');
CURSOR c_psc_codes IS SELECT lookup_code from fnd_lookup_values where lookup_type = 'FV_PSC_TYPE' and language = userenv('LANG');

PROCEDURE INSERT_TEMP_DATA( p_record_type number,
                            p_duns varchar2,
                            p_reference1 varchar2,
                            p_reference2 varchar2,
                            p_reference3 varchar2 ,
                            p_reference4 varchar2 ,
                            p_reference5 varchar2 )
IS
BEGIN
  INSERT INTO FV_CCR_PROCESS_REPORT
    (record_type,
     duns_info,
     reference1,
     reference2,
     reference3,
     reference4,
     reference5
     )
  VALUES
    (p_record_type,
     p_duns ,
     p_reference1,
     p_reference2,
     p_reference3,
     p_reference4,
     p_reference5
    );

EXCEPTION WHEN OTHERS THEN
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, 'Insert into temp table',SQLERRM);
END;

PROCEDURE find_code ( p_lookup IN OUT NOCOPY lookup_data
                    )
IS

CURSOR c_lookup_info(c_type varchar2, c_code varchar2) IS
    select lookup_code from fnd_lookup_values
    where lookup_type = c_type
    and lookup_code = c_code
    and language = userenv('LANG');

code_exist boolean;
idx binary_integer;
l_errbuf varchar2(1000);
message_text varchar2(2000);
message_action varchar(2000);
l_token varchar2(100);

l_lookup_code fnd_lookup_values.lookup_code%type;

BEGIN
  l_errbuf := 'Start - > find code ';
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, 'find code ',l_errbuf);

  FOR i in p_lookup.first..p_lookup.last
  LOOP
  code_exist := false ;
  idx:= 1;
  IF (p_lookup(i).rec_type ='B' and p_lookup(i).code <> '  ') THEN
    FOR idx in 1 ..bus_code.count
    LOOP
     IF bus_code.exists( idx ) THEN
        IF bus_code(idx) = p_lookup(i).code  THEN
           code_exist := true;
        END IF;
     END IF;
    END LOOP;
  IF not code_exist THEN

       FND_MESSAGE.set_NAME('FV','FV_CCR_TYPE_INEXISTS');
       FND_MESSAGE.set_TOKEN('TYPE','Business Type');
       FND_MESSAGE.SET_TOKEN('CODE',p_lookup(i).code);
       message_text := FND_MESSAGE.get;

       FND_MESSAGE.set_NAME('FV','FV_CCR_ACTION5');
       FND_MESSAGE.set_token('TYPE',p_lookup(i).code);

       message_action := FND_MESSAGE.get;

       l_errbuf :=p_lookup(i).code||' -> Code does not exist' ;
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, 'find_code',l_errbuf);
       insert_temp_data(3,null,message_text ,message_action,'ORACLE',null,null);
  END IF;
  ELSIF (p_lookup(i).rec_type ='B' and p_lookup(i).code = '  ') THEN
    p_lookup(i).code := null;
  ELSIF (p_lookup(i).rec_type ='S' and p_lookup(i).code <> '        ') THEN
    IF substr(p_lookup(i).code,5,4) ='    ' THEN
       p_lookup(i).code := substr(p_lookup(i).code,1,4);
    END IF;
    FOR idx in 1 ..sic_code.count
    LOOP
     IF sic_code.exists( idx ) THEN
        IF sic_code(idx) = p_lookup(i).code  THEN
           code_exist := true;
        END IF;
     END IF;
    END LOOP;
  IF not code_exist THEN

       FND_MESSAGE.set_NAME('FV','FV_CCR_TYPE_INEXISTS');
       FND_MESSAGE.set_TOKEN('TYPE','SIC Code');
       FND_MESSAGE.SET_TOKEN('CODE',p_lookup(i).code);

       message_text := FND_MESSAGE.get;

       FND_MESSAGE.set_NAME('FV','FV_CCR_ACTION5');
       FND_MESSAGE.set_token('TYPE',p_lookup(i).code);

       message_action := FND_MESSAGE.get;

       l_errbuf :=p_lookup(i).code||' -> Code does not exist' ;
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, 'find_code',l_errbuf);
       insert_temp_data(3,null,message_text ,message_action,'ORACLE',null,null);
  END IF;
  ELSIF (p_lookup(i).rec_type ='S' and p_lookup(i).code = '        ') THEN
    p_lookup(i).code := null;
  ELSIF (p_lookup(i).rec_type ='N' and p_lookup(i).code <> '      ') THEN
    FOR idx in 1 ..naic_code.count
    LOOP
     IF naic_code.exists( idx ) THEN
        IF naic_code(idx) = p_lookup(i).code  THEN
           code_exist := true;
        END IF;
     END IF;
    END LOOP;
  IF not code_exist THEN

       FND_MESSAGE.set_NAME('FV','FV_CCR_TYPE_INEXISTS');
       FND_MESSAGE.set_TOKEN('TYPE','NAICS Code');
       FND_MESSAGE.SET_TOKEN('CODE',p_lookup(i).code);
       message_text := FND_MESSAGE.get;

       FND_MESSAGE.set_NAME('FV','FV_CCR_ACTION5');
       FND_MESSAGE.set_token('TYPE',p_lookup(i).code);

       message_action := FND_MESSAGE.get;

       l_errbuf :=p_lookup(i).code||' -> Code does not exist' ;
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, 'find_code',l_errbuf);
       insert_temp_data(3,null,message_text ,message_action,'ORACLE',null,null);
  END IF;
  ELSIF (p_lookup(i).rec_type ='N' and p_lookup(i).code = '      ') THEN
    p_lookup(i).code := null;
  ELSIF (p_lookup(i).rec_type ='F' and p_lookup(i).code <> '    ') THEN
    FOR idx in 1 ..fsc_code.count
    LOOP
     IF fsc_code.exists( idx ) THEN
        IF fsc_code(idx) = p_lookup(i).code  THEN
           code_exist := true;
        END IF;
     END IF;
    END LOOP;
  IF not code_exist THEN

       FND_MESSAGE.set_NAME('FV','FV_CCR_TYPE_INEXISTS');
       FND_MESSAGE.set_TOKEN('TYPE','FSC code');
       FND_MESSAGE.SET_TOKEN('CODE',p_lookup(i).code);

       message_text := FND_MESSAGE.get;

       FND_MESSAGE.set_NAME('FV','FV_CCR_ACTION5');
       FND_MESSAGE.set_token('TYPE',p_lookup(i).code);

       message_action := FND_MESSAGE.get;

       l_errbuf :=p_lookup(i).code||' -> Code does not exist' ;
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, 'find_code',l_errbuf);
       insert_temp_data(3,null,message_text ,message_action,'ORACLE',null,null);
  END IF;
  ELSIF (p_lookup(i).rec_type ='F' and p_lookup(i).code = '    ') THEN
    p_lookup(i).code := null;
  ELSIF (p_lookup(i).rec_type ='P' and p_lookup(i).code <> '    ') THEN
    FOR idx in 1 ..psc_code.count
    LOOP
     IF psc_code.exists( idx ) THEN
        IF psc_code(idx) = p_lookup(i).code  THEN
           code_exist := true;
        END IF;
     END IF;
    END LOOP;
  IF not code_exist THEN

       FND_MESSAGE.set_NAME('FV','FV_CCR_TYPE_INEXISTS');
       FND_MESSAGE.set_TOKEN('TYPE','PSC Code');
       FND_MESSAGE.SET_TOKEN('CODE',p_lookup(i).code);

       message_text := FND_MESSAGE.get;

       FND_MESSAGE.set_NAME('FV','FV_CCR_ACTION5');
       FND_MESSAGE.set_token('TYPE',p_lookup(i).code);

       message_action := FND_MESSAGE.get;

       l_errbuf :=p_lookup(i).code||' -> Code does not exist' ;
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, 'find_code',l_errbuf);
       insert_temp_data(3,null,message_text ,message_action,'ORACLE',null,null);
  END IF;
  ELSIF (p_lookup(i).rec_type ='P' and p_lookup(i).code = '    ') THEN
    p_lookup(i).code := null;

  ELSIF (p_lookup(i).rec_type ='O' and p_lookup(i).code <> '  ') THEN
    OPEN c_lookup_info('FV_ORGANIZATION_TYPE',p_lookup(i).code);
    FETCH c_lookup_info into l_lookup_code;
    IF c_lookup_info%FOUND THEN
       code_exist := true;
    END IF;
    CLOSE c_lookup_info;
    IF not code_exist THEN

       FND_MESSAGE.set_NAME('FV','FV_CCR_TYPE_INEXISTS');
       FND_MESSAGE.set_TOKEN('TYPE','Organization Type');
       FND_MESSAGE.SET_TOKEN('CODE',p_lookup(i).code);
       message_text := FND_MESSAGE.get;

       FND_MESSAGE.set_NAME('FV','FV_CCR_ACTION5');
       FND_MESSAGE.set_token('TYPE',p_lookup(i).code);

       message_action := FND_MESSAGE.get;

       l_errbuf :=p_lookup(i).code||' -> Code does not exist' ;
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, 'find_code',l_errbuf);
       insert_temp_data(3,null,message_text ,message_action,'ORACLE',null,null);
    END IF;
  ELSIF (p_lookup(i).rec_type ='O' and p_lookup(i).code = '  ') THEN
    p_lookup(i).code := null;
  ELSIF (p_lookup(i).rec_type ='C' and p_lookup(i).code <> ' ') THEN
    OPEN c_lookup_info('FV_CORRESPOND_TYPE',p_lookup(i).code);
    FETCH c_lookup_info into l_lookup_code;
    IF c_lookup_info%FOUND THEN
       code_exist := true;
    END IF;
    CLOSE c_lookup_info;
    IF not code_exist THEN

       FND_MESSAGE.set_NAME('FV','FV_CCR_TYPE_INEXISTS');
       FND_MESSAGE.set_TOKEN('TYPE','Correspondence Type');
       FND_MESSAGE.SET_TOKEN('CODE',p_lookup(i).code);
       message_text := FND_MESSAGE.get;

       FND_MESSAGE.set_NAME('FV','FV_CCR_ACTION5');
       FND_MESSAGE.set_token('TYPE',p_lookup(i).code);

       message_action := FND_MESSAGE.get;

       l_errbuf :=p_lookup(i).code||' -> Code does not exist' ;
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, 'find_code',l_errbuf);
       insert_temp_data(3,null,message_text ,message_action,'ORACLE',null,null);
    END IF;
  ELSIF (p_lookup(i).rec_type ='C' and p_lookup(i).code = ' ') THEN
    p_lookup(i).code := null;
  ELSIF ( (p_lookup(i).rec_type ='CS' or p_lookup(i).rec_type ='ES'  )
           and p_lookup(i).code <> '               '
        ) THEN
    OPEN c_lookup_info('FV_SECURITY_LEVEL',p_lookup(i).code);
    FETCH c_lookup_info into l_lookup_code;
    IF c_lookup_info%FOUND THEN
       code_exist := true;
    END IF;
    CLOSE c_lookup_info;
    IF not code_exist THEN

       select decode(p_lookup(i).code,'CS','Corporate Security Code', 'Employee Security Code')  into  l_token
       from dual;

       FND_MESSAGE.set_NAME('FV','FV_CCR_TYPE_INEXISTS');
       FND_MESSAGE.set_TOKEN('TYPE',p_lookup(i).rec_type);
       FND_MESSAGE.SET_TOKEN('CODE',l_token);
       message_text := FND_MESSAGE.get;

       FND_MESSAGE.set_NAME('FV','FV_CCR_ACTION5');
       FND_MESSAGE.set_token('TYPE',p_lookup(i).code);

       message_action := FND_MESSAGE.get;

       l_errbuf :=p_lookup(i).code||' -> Code does not exist' ;
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, 'find_code',l_errbuf);
       insert_temp_data(3,null,message_text ,message_action,'ORACLE',null,null);
    END IF;
  ELSIF ( (p_lookup(i).rec_type ='CS' or p_lookup(i).rec_type ='ES'  )
          and p_lookup(i).code = '               '
        ) THEN
    p_lookup(i).code := null;
  END IF; -- end of type -B
  END LOOP;

exception when others then
       IF c_lookup_info%isopen then
            close c_lookup_info;
       END IF;
       l_errbuf := 'unexpected exception ' || SQLERRM;
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, 'find code',l_errbuf);
END;

PROCEDURE MAIN(   errbuf                OUT NOCOPY VARCHAR2,
                          retcode               OUT NOCOPY NUMBER,
                  p_file_location               IN  VARCHAR2,
                  p_file_Name           IN  VARCHAR2,
                  p_file_type           IN  VARCHAR2,
                  p_update_type                 IN  VARCHAR2,
                  p_dummy               IN NUMBER,
                  p_duns                        IN  VARCHAR2  ,
                  p_xml_import IN VARCHAR2 ,
                  p_insert_data IN VARCHAR2
                  ) IS

l_data_file VARCHAR2(100);
p_phase                 VARCHAR2(100);
p_status                VARCHAR2(100);
p_dev_phase             VARCHAR2(100);
p_dev_status    VARCHAR2(100);
p_message       VARCHAR2(100);
l_request_id            NUMBER;
l_request_wait_status BOOLEAN;
l_module_name   VARCHAR2(1000);
l_errbuf VARCHAR2(1000);
l_file_type varchar2(1);
l_invalid_file_name boolean;
l_file_date DATE;
l_juliandate VARCHAR2(5);
l_extract_code varchar2(1);
l_extract_type varchar2(1);
l_status varchar2(1);
l_pos23 varchar2(2);
l_message_action1 varchar2(2000);
l_message_action2 varchar2(2000);
l_message_action3 varchar2(2000);
l_message_action4 varchar2(2000);
l_msg_inv_file_name varchar2(2000);
l_msg_inv_file_type varchar2(2000);
l_msg_julian_date varchar2(2000);
l_msg_no_duns varchar2(2000);
l_msg_pay_obj varchar2(2000);
l_verify_existence VARCHAR2(1);
l_title1set boolean :=false;
l_title2set boolean :=false;
l_title3set boolean :=false;
--sthota
l_title4set boolean :=false;
l_lbe_change varchar2(120);
message_text varchar2(1000);
dummy number;
l_duns_list varchar2(1000);
l_counter number;
l_valid_tin varchar2(9);
l_user_id CONSTANT number := fnd_global.user_id;
l_xml_opt_param_set varchar2(1);
l_update_type varchar2(1);
l_report_count number;
l_run_from_xml varchar2(1); -- added by ks for 5906546
i number;

CURSOR c_ccr_data IS
SELECT * from fv_ccr_process_gt g
WHERE ( extract_code in ('A','2','3')
        or ( l_run_from_xml = 'Y' and extract_code = '4' -- modified by ks 5906546.
            and not exists (select 'first run'
                           from fv_ccr_orgs o
			    where o.duns = g.duns)
            )
        )
order by rowid;

CURSOR c_ccr_rep IS
SELECT
 DUNS_INFO,
 RECORD_TYPE,
 NVL(REFERENCE1,' ') REFERENCE1,
 NVL(REFERENCE2,' ') REFERENCE2,
 NVL(REFERENCE3,' ') REFERENCE3,
 DECODE(REFERENCE4,'A','Active','E','Expired','N','Unknown','U','Unregistered',REFERENCE4) REFERENCE4,
 REFERENCE5,
 REFERENCE6,
 REFERENCE7,
 REFERENCE8,
 REFERENCE9,
 REFERENCE10
from fv_ccr_process_report order by record_type,rowid;



  CURSOR c_taxpayer is
  select distinct fcv.taxpayer_id,fcv.vendor_id
  from fv_ccr_vendors  fcv
  where exists (SELECT 1 FROM fv_ccr_vendors fcv_in
  WHERE fcv_in.taxpayer_id=fcv.taxpayer_id
  AND fcv_in.vendor_id = fcv.vendor_id
  AND fcv_in.legal_bus_name<>fcv.legal_bus_name
  AND fcv_in.taxpayer_id is not null
  AND fcv_in.plus_four is null
  AND fcv_in.vendor_id is not null
  AND fcv_in.ccr_status not in ('E','D'))
  AND fcv.plus_four IS NULL
  AND fcv.taxpayer_id IS NOT NULL
  AND fcv.vendor_id is not null
  AND fcv.ccr_status not in ('E','D')
  AND exists (select 1 from fv_ccr_process_gt fcpg
  where fcpg.duns = fcv.duns and fcpg.plus_four IS NULL);

  CURSOR c_duns_info(p_taxpayer_id varchar2,p_vendor_id number)  IS
  select fcv.duns,fcv.plus_four ,fcv.legal_bus_name,fcv.taxpayer_id
  from fv_ccr_vendors fcv
  where fcv.plus_four is null
  and fcv.taxpayer_id=p_taxpayer_id
  and fcv.vendor_id=p_vendor_id;

  cursor c_vendor_info(p_vid number) is
  select vendor_name from po_vendors
  where vendor_id =p_vid;

l_ccr_data c_ccr_data%rowtype;
l_code lookup_data;
l_vendor_id varchar2(240);
--sthota
l_active_vendor_id varchar2(240);
l_vendor_cnt number := 0;
l_active_vendor_exists number;
l_vendor_name varchar2(240);

BEGIN
  -- Bug 3872908
  IF (p_xml_import = 'Y') THEN
    l_xml_opt_param_set := SUBSTR(p_update_type, 2, 1);
    l_update_type := SUBSTR(p_update_type, 1, 1);
    SELECT sysdate into l_file_date FROM dual; -- Bug 3931555, 3936532
  ELSE
    l_update_type := p_update_type;
  END IF;

  l_module_name := 'CCR Data Load Tfr';
  l_errbuf :='Start of Transfer';

  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

  -- construct the file name from the file location and name
  -- file name ( '\\' --> for WINDOWS NT , '/' --> UNIX )


  FND_MESSAGE.SET_NAME('FV','FV_CCR_ACTION1');
  l_message_action1 := FND_MESSAGE.GET;

  FND_MESSAGE.SET_NAME('FV','FV_CCR_ACTION2');
  l_message_action2 := FND_MESSAGE.GET;

  FND_MESSAGE.SET_NAME('FV','FV_CCR_ACTION3');
  l_message_action3 := FND_MESSAGE.GET;

  FND_MESSAGE.SET_NAME('FV','FV_CCR_ACTION4');
  l_message_action4 := FND_MESSAGE.GET;

  FND_MESSAGE.SET_NAME('FV','FV_CCR_NO_DUNS');
  l_msg_no_duns := FND_MESSAGE.GET;

  -- need to perform file name validations only if we are intending to call direct
  IF p_xml_import <> 'Y' THEN

  l_errbuf :='Compare the Directory - unix/NT ';
  l_invalid_file_name := FALSE;

  IF (INSTR(p_file_location, '/') <> 0 ) THEN
       l_data_file :=  p_file_location || '/' || p_file_name;
       l_errbuf := 'Unix directory -'||l_data_file;
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);
  ELSE
       l_data_file :=  p_file_location || '\\' || p_file_name;
       l_errbuf := 'NT Directory file name - '||l_data_file;
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

  END IF;


  -- check for file naming convention
  -- Position #1
  IF (substr(p_file_name,1,1) <> 'B') THEN
        l_invalid_file_name  := TRUE;
        l_errbuf := 'Error in Position#1 of filename';
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

    FND_MESSAGE.SET_NAME('FV','FV_CCR_INVALID_FILE_NAME');
    FND_MESSAGE.SET_TOKEN('FILE',p_file_name);
    l_msg_inv_file_name := FND_MESSAGE.GET;

    insert_temp_data(3,null,l_msg_inv_file_name,l_message_action1,null,null,null);
  END IF;


  -- Position #2-3
  l_pos23 := substr(p_file_name,2,2) ;
  IF (l_pos23 not in ('CR','CD')) THEN
        l_invalid_file_name := TRUE;
        l_errbuf := 'Error in Position#2-3 of filename';
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

    FND_MESSAGE.SET_NAME('FV','FV_CCR_INVALID_FILE_NAME');
    FND_MESSAGE.SET_TOKEN('FILE',p_file_name);
    l_msg_inv_file_name := FND_MESSAGE.GET;
    insert_temp_data(3,null,l_msg_inv_file_name,l_message_action1,null,null,null);
  END IF;

  --find out if master/sensitive
/*
  l_errbuf := 'File Type '|| p_file_type;
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

  IF ((p_file_type ='M' and l_pos23 not in ('CR','CD'))
       OR
       (p_file_type ='S' and l_pos23 not in ('SR','SD')) ) THEN
        l_invalid_file_name := TRUE;
        l_errbuf := 'The file name does not match the file type';
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

    FND_MESSAGE.SET_NAME('FV','FV_CCR_INVALID_FILE_NAME');
    FND_MESSAGE.SET_TOKEN('FILE',p_file_name);
    l_msg_inv_file_name := FND_MESSAGE.GET;
    insert_temp_data(3,null,l_msg_inv_file_name,l_message_action4,null,null,null);

  END IF;*/

  -- Throw error if invalid file name
  IF l_invalid_file_name  THEN
        retcode :=-1;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);
        RETURN;
  END IF;

  -- Julian date validation
  l_juliandate := substr(p_file_name,10,5);--Changed 4 to 9
  begin
        select to_date(l_juliandate,'YYDDD') into l_file_date from dual;
  exception when others THEN
        retcode :=-1;
        l_errbuf := SQLERRM;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

    FND_MESSAGE.SET_NAME('FV','FV_CCR_INVALID_FILE_NAME');
    FND_MESSAGE.SET_TOKEN('FILE',p_file_name);
    l_msg_inv_file_name := FND_MESSAGE.GET;

    FND_MESSAGE.SET_NAME('FV','FV_CCR_JULIAN_DATE_ACTION');
    FND_MESSAGE.SET_TOKEN('DATE',l_juliandate);
    l_msg_julian_date := FND_MESSAGE.GET;

    insert_temp_data(3,null,l_msg_inv_file_name,l_msg_julian_date,null,null,null);
        RETURN;
  end; -- end of julian date check


  -- Check for file format to decide which Loader to Run
  --FVCCRLDC -> for Complete
  --FVCCRLDS -> for Sensitive

  --submit the request for SQLLOAD
--  IF (p_file_type ='M' ) THEN
    l_errbuf := 'Submitting the Master Complete Load request ';
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

    l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                              application => 'FV',
                              program     => 'FVCCRLDC',
                              description => 'CCR Data Load Complete',
                              start_time  => '',
                              sub_request => FALSE ,
                              argument1   => l_data_file ) ;
   commit;
    l_errbuf :='Request Id - >'||l_request_id||SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

/*  ELSIF (p_file_type ='S') THEN
    l_errbuf :='Submitting Sensitive Load Request';
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

    l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                              application => 'FV',
                              program     => 'FVCCRLDS',
                              description => 'CCR Data Load Sensitive',
                              start_time  => '',
                              sub_request => FALSE ,
                              argument1   => l_data_file ) ;
    commit;
    l_errbuf :='Request Id - >'||l_request_id||SQLERRM;
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

  END IF;*/


  IF (l_request_id = 0) THEN
           retcode := -1;
           l_errbuf := 'Failed to submit request for SQL*LOADER';
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);
           RETURN;
  ELSE
           COMMIT;
  END IF;

  -- wait for request to get completed
  l_request_wait_status := fnd_concurrent.wait_for_request(
                                    request_id => l_request_id,
                                    interval => 20,
                                    max_wait => 0,
                                    phase => p_phase,
                                    status => p_status,
                                    dev_phase => p_dev_phase,
                                    dev_status => p_dev_status,
                                    message => p_message);


  -- end of SQL LOAD

  l_errbuf := 'SQL Loader completed upload successfully in Status '||p_status;
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

  -- incase the request completed in error , parent request also should be errored
  IF p_status ='Error' THEN
        retcode := -1;
        l_errbuf := 'Loader Request Errored out';
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);
        RETURN;
  END IF;

  -- find out the type of file - monthly extract /daily extract
  IF l_pos23 = 'CR' THEN
    --TODO  check for exception thrown by this select statement
    l_errbuf := 'Checking the info in Extract code';
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

    IF p_status ='Warning' THEN
        SELECT count(1) into dummy from fv_ccr_file_temp;
        IF dummy >=1 THEN
            SELECT extract_code into l_extract_type from fv_ccr_file_temp WHERE rownum=1;
        ELSE
            retcode := -1;
            l_errbuf := 'Not even a single row was processed in Loader. Please verify';
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);
            RETURN;
        END IF;
    END IF;


    -- if extract_code is not 'A' for a monthly file type then error out
    IF l_extract_type <>'A' THEN
           retcode := -1;
           l_errbuf := 'Not a valid Monthly refresh file ';
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);
           insert_temp_data(3,null,'FV_CCR_INVALID_FILE_TYPE',l_message_action2,null,null,null);
           RETURN;
    END IF;  -- end of extract type check in 'M'

  ELSIF  l_pos23 = 'CD' THEN
    l_errbuf := 'Checking the info in Extract code';
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

    IF p_status ='Warning' THEN
        SELECT count(1) into dummy from fv_ccr_file_temp;
        IF dummy >=1 THEN
            SELECT extract_code into l_extract_type from fv_ccr_file_temp WHERE rownum=1;
        ELSE
            retcode := -1;
            l_errbuf := 'Not even a single row was processed in Loader. Please verify';
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);
            RETURN;
        END IF;
    END IF;


    -- if extract_code is 'A' for sensitive data file type then error out
    IF l_extract_type = 'A' THEN
           retcode := -1;
           l_errbuf := 'Not a valid Daily Refresh file';
               FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

           FND_MESSAGE.SET_NAME('FV','FV_CCR_INVALID_FILE_TYPE');
            l_msg_inv_file_type := FND_MESSAGE.GET;
           insert_temp_data(3,null,l_msg_inv_file_type,l_message_action2,null,null,null);
           RETURN;
    END IF;  -- end of extract type check in 'S'
  END IF; -- end of file type  validation
--End of change for CP test run

  l_errbuf := 'Calling BPN Load package to load data into fv_ccr_file_temp';
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);
  FV_CCR_BPN_LOAD_PKG.MAIN();

  l_errbuf := 'Push data into fv_ccr_process_gt based on the update type';
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

  -- reset the status in fv_ccr_vendors as 'N' for extract code
  UPDATE fv_ccr_vendors fcv SET fcv.extract_code ='N';

  ELSE
  --This program is called from xml import
  -- Added the below code as Data Load will be called from xml with update_type A
  UPDATE fv_ccr_vendors fcv SET fcv.extract_code ='N';
  l_errbuf := 'The program is being called from xml import -> xml-import parameter '|| p_xml_import;
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);
  END IF ; --end of xml_import <> Y

  l_run_from_xml := p_xml_import;
  -- push data into fv_ccr_process_gt based on the update type
  IF (l_update_type ='A') THEN

    l_errbuf :='Update type A - Inserting into second temp table';
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);
    --check if atleast one record exists
    Begin

    --need to process all data if insert is Yes.
    IF (p_xml_import ='Y' and p_insert_data ='Y')  THEN
     l_errbuf := 'Copying info - xml import';
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);
        INSERT INTO fv_ccr_process_gt ( FILE_DATE
            ,DUNS
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
            ,EDI
            ,TAXPAYER_ID
            ,AVG_NUM_EMPLOYEES
            ,SOCIAL_SECURITY_NUMBER
            ,FINANCIAL_INSTITUTE
            ,BANK_ACCT_NUMBER
            ,ABA_ROUTING
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
            ,HQ_PARENT_DUNS
            ,HQ_PARENT_ADD1
            ,HQ_PARENT_ADD2
            ,HQ_PARENT_CITY
            ,HQ_PARENT_STATE
            ,HQ_PARENT_POSTAL_CODE
            ,HQ_PARENT_COUNTRY
            ,HQ_PARENT_PHONE
            ,AUSTIN_TETRA_NUMBER
            ,AUSTIN_TETRA_PARENT_NUMBER
            ,AUSTIN_TETRA_ULTIMATE_NUMBER
            ,AUSTIN_TETRA_PCARD_FLAG
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
            ,HQ_PARENT_POC
            ,PAYMENT_TYPE
            ,ANNUAL_RECEIPTS
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

            )
    SELECT l_file_date
            ,fcft.DUNS
            ,replace(fcft.PLUS_FOUR,' ',null)
            ,fcft.CAGE_CODE
            ,fcft.EXTRACT_CODE
            ,fcft.REGISTRATION_DATE
            ,fcft.RENEWAL_DATE
            ,fcft.LEGAL_BUS_NAME
            ,fcft.DBA_NAME
            ,fcft.DIVISION_NAME
            ,fcft.DIVISION_NUMBER
            ,fcft.ST_ADDRESS1
            ,fcft.ST_ADDRESS2
            ,fcft.CITY
            ,fcft.STATE
            ,fcft.POSTAL_CODE
            ,fcft.COUNTRY
            ,fcft.BUSINESS_START_DATE
            ,fcft.FISCAL_YR_CLOSE_DATE
            ,fcft.CORP_SECURITY_LEVEL
            ,fcft.EMP_SECURITY_LEVEL
            ,fcft.WEB_SITE
            ,fcft.ORGANIZATIONAL_TYPE
            ,fcft.STATE_OF_INC
            ,fcft.COUNTRY_OF_INC
            ,fcft.CREDIT_CARD_FLAG
            ,fcft.CORRESPONDENCE_FLAG
            ,fcft.MAIL_POC
            ,fcft.MAIL_ADD1
            ,fcft.MAIL_ADD2
            ,fcft.MAIL_CITY
            ,fcft.MAIL_POSTAL_CODE
            ,fcft.MAIL_COUNTRY
            ,fcft.MAIL_STATE
            ,fcft.PREV_BUS_POC
            ,fcft.PREV_BUS_ADD1
            ,fcft.PREV_BUS_ADD2
            ,fcft.PREV_BUS_CITY
            ,fcft.PREV_BUS_POSTAL_CODE
            ,fcft.PREV_BUS_COUNTRY
            ,fcft.PREV_BUS_STATE
            ,fcft.PARENT_POC
            ,fcft.PARENT_DUNS
            ,fcft.PARENT_ADD1
            ,fcft.PARENT_ADD2
            ,fcft.PARENT_CITY
            ,fcft.PARENT_POSTAL_CODE
            ,fcft.PARENT_COUNTRY
            ,fcft.PARENT_STATE
            ,fcft.GOV_PARENT_POC
            ,fcft.GOV_PARENT_ADD1
            ,fcft.GOV_PARENT_ADD2
            ,fcft.GOV_PARENT_CITY
            ,fcft.GOV_PARENT_POSTAL_CODE
            ,fcft.GOV_PARENT_COUNTRY
            ,fcft.GOV_PARENT_STATE
            ,fcft.GOV_BUS_POC
            ,fcft.GOV_BUS_ADD1
            ,fcft.GOV_BUS_ADD2
            ,fcft.GOV_BUS_CITY
            ,fcft.GOV_BUS_POSTAL_CODE
            ,fcft.GOV_BUS_COUNTRY
            ,fcft.GOV_BUS_STATE
            ,fcft.GOV_BUS_US_PHONE
            ,fcft.GOV_BUS_US_PHONE_EX
            ,fcft.GOV_BUS_NON_US_PHONE
            ,fcft.GOV_BUS_FAX
            ,fcft.GOV_BUS_EMAIL
            ,fcft.ALT_GOV_BUS_POC
            ,fcft.ALT_GOV_BUS_ADD1
            ,fcft.ALT_GOV_BUS_ADD2
            ,fcft.ALT_GOV_BUS_CITY
            ,fcft.ALT_GOV_BUS_POSTAL_CODE
            ,fcft.ALT_GOV_BUS_COUNTRY
            ,fcft.ALT_GOV_BUS_STATE
            ,fcft.ALT_GOV_BUS_US_PHONE
            ,fcft.ALT_GOV_BUS_US_PHONE_EX
            ,fcft.ALT_GOV_BUS_NON_US_PHONE
            ,fcft.ALT_GOV_BUS_FAX
            ,fcft.ALT_GOV_BUS_EMAIL
            ,fcft.PAST_PERF_POC
            ,fcft.PAST_PERF_ADD1
            ,fcft.PAST_PERF_ADD2
            ,fcft.PAST_PERF_CITY
            ,fcft.PAST_PERF_POSTAL_CODE
            ,fcft.PAST_PERF_COUNTRY
            ,fcft.PAST_PERF_STATE
            ,fcft.PAST_PERF_US_PHONE
            ,fcft.PAST_PERF_US_PHONE_EX
            ,fcft.PAST_PERF_NON_US_PHONE
            ,fcft.PAST_PERF_FAX
            ,fcft.PAST_PERF_EMAIL
            ,fcft.ALT_PAST_PERF_POC
            ,fcft.ALT_PAST_PERF_ADD1
            ,fcft.ALT_PAST_PERF_ADD2
            ,fcft.ALT_PAST_PERF_CITY
            ,fcft.ALT_PAST_PERF_POSTAL_CODE
            ,fcft.ALT_PAST_PERF_COUNTRY
            ,fcft.ALT_PAST_PERF_STATE
            ,fcft.ALT_PAST_PERF_US_PHONE
            ,fcft.ALT_PAST_PERF_US_PHONE_EX
            ,fcft.ALT_PAST_PERF_NON_US_PHONE
            ,fcft.ALT_PAST_PERF_FAX
            ,fcft.ALT_PAST_PERF_EMAIL
            ,fcft.ELEC_BUS_POC
            ,fcft.ELEC_BUS_ADD1
            ,fcft.ELEC_BUS_ADD2
            ,fcft.ELEC_BUS_CITY
            ,fcft.ELEC_BUS_POSTAL_CODE
            ,fcft.ELEC_BUS_COUNTRY
            ,fcft.ELEC_BUS_STATE
            ,fcft.ELEC_BUS_US_PHONE
            ,fcft.ELEC_BUS_US_PHONE_EX
            ,fcft.ELEC_BUS_NON_US_PHONE
            ,fcft.ELEC_BUS_FAX
            ,fcft.ELEC_BUS_EMAIL
            ,fcft.ALT_ELEC_BUS_POC
            ,fcft.ALT_ELEC_BUS_ADD1
            ,fcft.ALT_ELEC_BUS_ADD2
            ,fcft.ALT_ELEC_BUS_CITY
            ,fcft.ALT_ELEC_BUS_POSTAL_CODE
            ,fcft.ALT_ELEC_BUS_COUNTRY
            ,fcft.ALT_ELEC_BUS_STATE
            ,fcft.ALT_ELEC_BUS_US_PHONE
            ,fcft.ALT_ELEC_BUS_US_PHONE_EX
            ,fcft.ALT_ELEC_BUS_NON_US_PHONE
            ,fcft.ALT_ELEC_BUS_FAX
            ,fcft.ALT_ELEC_BUS_EMAIL
            ,fcft.CERTIFIER_POC
            ,fcft.CERTIFIER_US_PHONE
            ,fcft.CERTIFIER_US_PHONE_EX
            ,fcft.CERTIFIER_NON_US_PHONE
            ,fcft.CERTIFIER_FAX
            ,fcft.CERTIFIER_EMAIL
            ,fcft.ALT_CERTIFIER_POC
            ,fcft.ALT_CERTIFIER_US_PHONE
            ,fcft.ALT_CERTIFIER_US_PHONE_EX
            ,fcft.ALT_CERTIFIER_NON_US_PHONE
            ,fcft.CORP_INFO_POC
            ,fcft.CORP_INFO_US_PHONE
            ,fcft.CORP_INFO_US_PHONE_EX
            ,fcft.CORP_INFO_NON_US_PHONE
            ,fcft.CORP_INFO_FAX
            ,fcft.CORP_INFO_EMAIL
            ,fcft.OWNER_INFO_POC
            ,fcft.OWNER_INFO_US_PHONE
            ,fcft.OWNER_INFO_US_PHONE_EX
            ,fcft.OWNER_INFO_NON_US_PHONE
            ,fcft.OWNER_INFO_FAX
            ,fcft.OWNER_INFO_EMAIL
            ,fcft.EDI
            ,fcft.TAXPAYER_ID
            ,fcft.AVG_NUM_EMPLOYEES
            ,fcft.SOCIAL_SECURITY_NUMBER
            ,fcft.FINANCIAL_INSTITUTE
            ,fcft.BANK_ACCT_NUMBER
            ,fcft.ABA_ROUTING
            ,fcft.LOCKBOX_NUMBER
            ,fcft.AUTHORIZATION_DATE
            ,fcft.EFT_WAIVER
            ,fcft.ACH_US_PHONE
            ,fcft.ACH_NON_US_PHONE
            ,fcft.ACH_FAX
            ,fcft.ACH_EMAIL
            ,fcft.REMIT_POC
            ,fcft.REMIT_ADD1
            ,fcft.REMIT_ADD2
            ,fcft.REMIT_CITY
            ,fcft.REMIT_STATE
            ,fcft.REMIT_POSTAL_CODE
            ,fcft.REMIT_COUNTRY
            ,fcft.AR_POC
            ,fcft.AR_US_PHONE
            ,fcft.AR_US_PHONE_EX
            ,fcft.AR_NON_US_PHONE
            ,fcft.AR_FAX
            ,fcft.AR_EMAIL
            ,fcft.MPIN
            ,fcft.HQ_PARENT_DUNS
            ,fcft.HQ_PARENT_ADD1
            ,fcft.HQ_PARENT_ADD2
            ,fcft.HQ_PARENT_CITY
            ,fcft.HQ_PARENT_STATE
            ,fcft.HQ_PARENT_POSTAL_CODE
            ,fcft.HQ_PARENT_COUNTRY
            ,fcft.HQ_PARENT_PHONE
            ,fcft.AUSTIN_TETRA_NUMBER
            ,fcft.AUSTIN_TETRA_PARENT_NUMBER
            ,fcft.AUSTIN_TETRA_ULTIMATE_NUMBER
            ,fcft.AUSTIN_TETRA_PCARD_FLAG
            ,fcft.DNB_MONITOR_LAST_UPDATED
            ,fcft.DNB_MONITOR_STATUS
            ,fcft.DNB_MONITOR_CORP_NAME
            ,fcft.DNB_MONITOR_DBA
            ,fcft.DNB_MONITOR_ST_ADD1
            ,fcft.DNB_MONITOR_ST_ADD2
            ,fcft.DNB_MONITOR_CITY
            ,fcft.DNB_MONITOR_POSTAL_CODE
            ,fcft.DNB_MONITOR_COUNTRY_CODE
            ,fcft.DNB_MONITOR_STATE
            ,fcft.HQ_PARENT_POC
            ,fcft.PAYMENT_TYPE
            ,fcft.ANNUAL_RECEIPTS
            ,fcft.DOMESTIC_PARENT_POC
            ,fcft.DOMESTIC_PARENT_DUNS
            ,fcft.DOMESTIC_PARENT_ADD1
            ,fcft.DOMESTIC_PARENT_ADD2
            ,fcft.DOMESTIC_PARENT_CITY
            ,fcft.DOMESTIC_PARENT_POSTAL_CODE
            ,fcft.DOMESTIC_PARENT_COUNTRY
            ,fcft.DOMESTIC_PARENT_STATE
            ,fcft.DOMESTIC_PARENT_PHONE
            ,fcft.GLOBAL_PARENT_POC
            ,fcft.GLOBAL_PARENT_DUNS
            ,fcft.GLOBAL_PARENT_ADD1
            ,fcft.GLOBAL_PARENT_ADD2
            ,fcft.GLOBAL_PARENT_CITY
            ,fcft.GLOBAL_PARENT_POSTAL_CODE
            ,fcft.GLOBAL_PARENT_COUNTRY
            ,fcft.GLOBAL_PARENT_STATE
            ,fcft.GLOBAL_PARENT_PHONE

    FROM        fv_ccr_file_temp fcft
    order by rowid;
    ELSE
     l_errbuf := 'Copying info - Standalone / insert as N';
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

    INSERT INTO fv_ccr_process_gt ( FILE_DATE
            ,DUNS
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
            ,EDI
            ,TAXPAYER_ID
            ,AVG_NUM_EMPLOYEES
            ,SOCIAL_SECURITY_NUMBER
            ,FINANCIAL_INSTITUTE
            ,BANK_ACCT_NUMBER
            ,ABA_ROUTING
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
            ,HQ_PARENT_DUNS
            ,HQ_PARENT_ADD1
            ,HQ_PARENT_ADD2
            ,HQ_PARENT_CITY
            ,HQ_PARENT_STATE
            ,HQ_PARENT_POSTAL_CODE
            ,HQ_PARENT_COUNTRY
            ,HQ_PARENT_PHONE
            ,AUSTIN_TETRA_NUMBER
            ,AUSTIN_TETRA_PARENT_NUMBER
            ,AUSTIN_TETRA_ULTIMATE_NUMBER
            ,AUSTIN_TETRA_PCARD_FLAG
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
            ,HQ_PARENT_POC
            ,PAYMENT_TYPE
            ,ANNUAL_RECEIPTS
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

            )

    SELECT l_file_date
            ,fcft.DUNS
            ,replace(fcft.PLUS_FOUR,' ',null)
            ,fcft.CAGE_CODE
            ,fcft.EXTRACT_CODE
            ,fcft.REGISTRATION_DATE
            ,fcft.RENEWAL_DATE
            ,fcft.LEGAL_BUS_NAME
            ,fcft.DBA_NAME
            ,fcft.DIVISION_NAME
            ,fcft.DIVISION_NUMBER
            ,fcft.ST_ADDRESS1
            ,fcft.ST_ADDRESS2
            ,fcft.CITY
            ,fcft.STATE
            ,fcft.POSTAL_CODE
            ,fcft.COUNTRY
            ,fcft.BUSINESS_START_DATE
            ,fcft.FISCAL_YR_CLOSE_DATE
            ,fcft.CORP_SECURITY_LEVEL
            ,fcft.EMP_SECURITY_LEVEL
            ,fcft.WEB_SITE
            ,fcft.ORGANIZATIONAL_TYPE
            ,fcft.STATE_OF_INC
            ,fcft.COUNTRY_OF_INC
            ,fcft.CREDIT_CARD_FLAG
            ,fcft.CORRESPONDENCE_FLAG
            ,fcft.MAIL_POC
            ,fcft.MAIL_ADD1
            ,fcft.MAIL_ADD2
            ,fcft.MAIL_CITY
            ,fcft.MAIL_POSTAL_CODE
            ,fcft.MAIL_COUNTRY
            ,fcft.MAIL_STATE
            ,fcft.PREV_BUS_POC
            ,fcft.PREV_BUS_ADD1
            ,fcft.PREV_BUS_ADD2
            ,fcft.PREV_BUS_CITY
            ,fcft.PREV_BUS_POSTAL_CODE
            ,fcft.PREV_BUS_COUNTRY
            ,fcft.PREV_BUS_STATE
            ,fcft.PARENT_POC
            ,fcft.PARENT_DUNS
            ,fcft.PARENT_ADD1
            ,fcft.PARENT_ADD2
            ,fcft.PARENT_CITY
            ,fcft.PARENT_POSTAL_CODE
            ,fcft.PARENT_COUNTRY
            ,fcft.PARENT_STATE
            ,fcft.GOV_PARENT_POC
            ,fcft.GOV_PARENT_ADD1
            ,fcft.GOV_PARENT_ADD2
            ,fcft.GOV_PARENT_CITY
            ,fcft.GOV_PARENT_POSTAL_CODE
            ,fcft.GOV_PARENT_COUNTRY
            ,fcft.GOV_PARENT_STATE
            ,fcft.GOV_BUS_POC
            ,fcft.GOV_BUS_ADD1
            ,fcft.GOV_BUS_ADD2
            ,fcft.GOV_BUS_CITY
            ,fcft.GOV_BUS_POSTAL_CODE
            ,fcft.GOV_BUS_COUNTRY
            ,fcft.GOV_BUS_STATE
            ,fcft.GOV_BUS_US_PHONE
            ,fcft.GOV_BUS_US_PHONE_EX
            ,fcft.GOV_BUS_NON_US_PHONE
            ,fcft.GOV_BUS_FAX
            ,fcft.GOV_BUS_EMAIL
            ,fcft.ALT_GOV_BUS_POC
            ,fcft.ALT_GOV_BUS_ADD1
            ,fcft.ALT_GOV_BUS_ADD2
            ,fcft.ALT_GOV_BUS_CITY
            ,fcft.ALT_GOV_BUS_POSTAL_CODE
            ,fcft.ALT_GOV_BUS_COUNTRY
            ,fcft.ALT_GOV_BUS_STATE
            ,fcft.ALT_GOV_BUS_US_PHONE
            ,fcft.ALT_GOV_BUS_US_PHONE_EX
            ,fcft.ALT_GOV_BUS_NON_US_PHONE
            ,fcft.ALT_GOV_BUS_FAX
            ,fcft.ALT_GOV_BUS_EMAIL
            ,fcft.PAST_PERF_POC
            ,fcft.PAST_PERF_ADD1
            ,fcft.PAST_PERF_ADD2
            ,fcft.PAST_PERF_CITY
            ,fcft.PAST_PERF_POSTAL_CODE
            ,fcft.PAST_PERF_COUNTRY
            ,fcft.PAST_PERF_STATE
            ,fcft.PAST_PERF_US_PHONE
            ,fcft.PAST_PERF_US_PHONE_EX
            ,fcft.PAST_PERF_NON_US_PHONE
            ,fcft.PAST_PERF_FAX
            ,fcft.PAST_PERF_EMAIL
            ,fcft.ALT_PAST_PERF_POC
            ,fcft.ALT_PAST_PERF_ADD1
            ,fcft.ALT_PAST_PERF_ADD2
            ,fcft.ALT_PAST_PERF_CITY
            ,fcft.ALT_PAST_PERF_POSTAL_CODE
            ,fcft.ALT_PAST_PERF_COUNTRY
            ,fcft.ALT_PAST_PERF_STATE
            ,fcft.ALT_PAST_PERF_US_PHONE
            ,fcft.ALT_PAST_PERF_US_PHONE_EX
            ,fcft.ALT_PAST_PERF_NON_US_PHONE
            ,fcft.ALT_PAST_PERF_FAX
            ,fcft.ALT_PAST_PERF_EMAIL
            ,fcft.ELEC_BUS_POC
            ,fcft.ELEC_BUS_ADD1
            ,fcft.ELEC_BUS_ADD2
            ,fcft.ELEC_BUS_CITY
            ,fcft.ELEC_BUS_POSTAL_CODE
            ,fcft.ELEC_BUS_COUNTRY
            ,fcft.ELEC_BUS_STATE
            ,fcft.ELEC_BUS_US_PHONE
            ,fcft.ELEC_BUS_US_PHONE_EX
            ,fcft.ELEC_BUS_NON_US_PHONE
            ,fcft.ELEC_BUS_FAX
            ,fcft.ELEC_BUS_EMAIL
            ,fcft.ALT_ELEC_BUS_POC
            ,fcft.ALT_ELEC_BUS_ADD1
            ,fcft.ALT_ELEC_BUS_ADD2
            ,fcft.ALT_ELEC_BUS_CITY
            ,fcft.ALT_ELEC_BUS_POSTAL_CODE
            ,fcft.ALT_ELEC_BUS_COUNTRY
            ,fcft.ALT_ELEC_BUS_STATE
            ,fcft.ALT_ELEC_BUS_US_PHONE
            ,fcft.ALT_ELEC_BUS_US_PHONE_EX
            ,fcft.ALT_ELEC_BUS_NON_US_PHONE
            ,fcft.ALT_ELEC_BUS_FAX
            ,fcft.ALT_ELEC_BUS_EMAIL
            ,fcft.CERTIFIER_POC
            ,fcft.CERTIFIER_US_PHONE
            ,fcft.CERTIFIER_US_PHONE_EX
            ,fcft.CERTIFIER_NON_US_PHONE
            ,fcft.CERTIFIER_FAX
            ,fcft.CERTIFIER_EMAIL
            ,fcft.ALT_CERTIFIER_POC
            ,fcft.ALT_CERTIFIER_US_PHONE
            ,fcft.ALT_CERTIFIER_US_PHONE_EX
            ,fcft.ALT_CERTIFIER_NON_US_PHONE
            ,fcft.CORP_INFO_POC
            ,fcft.CORP_INFO_US_PHONE
            ,fcft.CORP_INFO_US_PHONE_EX
            ,fcft.CORP_INFO_NON_US_PHONE
            ,fcft.CORP_INFO_FAX
            ,fcft.CORP_INFO_EMAIL
            ,fcft.OWNER_INFO_POC
            ,fcft.OWNER_INFO_US_PHONE
            ,fcft.OWNER_INFO_US_PHONE_EX
            ,fcft.OWNER_INFO_NON_US_PHONE
            ,fcft.OWNER_INFO_FAX
            ,fcft.OWNER_INFO_EMAIL
            ,fcft.EDI
            ,fcft.TAXPAYER_ID
            ,fcft.AVG_NUM_EMPLOYEES
            ,fcft.SOCIAL_SECURITY_NUMBER
            ,fcft.FINANCIAL_INSTITUTE
            ,fcft.BANK_ACCT_NUMBER
            ,fcft.ABA_ROUTING
            ,fcft.LOCKBOX_NUMBER
            ,fcft.AUTHORIZATION_DATE
            ,fcft.EFT_WAIVER
            ,fcft.ACH_US_PHONE
            ,fcft.ACH_NON_US_PHONE
            ,fcft.ACH_FAX
            ,fcft.ACH_EMAIL
            ,fcft.REMIT_POC
            ,fcft.REMIT_ADD1
            ,fcft.REMIT_ADD2
            ,fcft.REMIT_CITY
            ,fcft.REMIT_STATE
            ,fcft.REMIT_POSTAL_CODE
            ,fcft.REMIT_COUNTRY
            ,fcft.AR_POC
            ,fcft.AR_US_PHONE
            ,fcft.AR_US_PHONE_EX
            ,fcft.AR_NON_US_PHONE
            ,fcft.AR_FAX
            ,fcft.AR_EMAIL
            ,fcft.MPIN
            ,fcft.HQ_PARENT_DUNS
            ,fcft.HQ_PARENT_ADD1
            ,fcft.HQ_PARENT_ADD2
            ,fcft.HQ_PARENT_CITY
            ,fcft.HQ_PARENT_STATE
            ,fcft.HQ_PARENT_POSTAL_CODE
            ,fcft.HQ_PARENT_COUNTRY
            ,fcft.HQ_PARENT_PHONE
            ,fcft.AUSTIN_TETRA_NUMBER
            ,fcft.AUSTIN_TETRA_PARENT_NUMBER
            ,fcft.AUSTIN_TETRA_ULTIMATE_NUMBER
            ,fcft.AUSTIN_TETRA_PCARD_FLAG
            ,fcft.DNB_MONITOR_LAST_UPDATED
            ,fcft.DNB_MONITOR_STATUS
            ,fcft.DNB_MONITOR_CORP_NAME
            ,fcft.DNB_MONITOR_DBA
            ,fcft.DNB_MONITOR_ST_ADD1
            ,fcft.DNB_MONITOR_ST_ADD2
            ,fcft.DNB_MONITOR_CITY
            ,fcft.DNB_MONITOR_POSTAL_CODE
            ,fcft.DNB_MONITOR_COUNTRY_CODE
            ,fcft.DNB_MONITOR_STATE
            ,fcft.HQ_PARENT_POC
            ,fcft.PAYMENT_TYPE
            ,fcft.ANNUAL_RECEIPTS
            ,fcft.DOMESTIC_PARENT_POC
            ,fcft.DOMESTIC_PARENT_DUNS
            ,fcft.DOMESTIC_PARENT_ADD1
            ,fcft.DOMESTIC_PARENT_ADD2
            ,fcft.DOMESTIC_PARENT_CITY
            ,fcft.DOMESTIC_PARENT_POSTAL_CODE
            ,fcft.DOMESTIC_PARENT_COUNTRY
            ,fcft.DOMESTIC_PARENT_STATE
            ,fcft.DOMESTIC_PARENT_PHONE
            ,fcft.GLOBAL_PARENT_POC
            ,fcft.GLOBAL_PARENT_DUNS
            ,fcft.GLOBAL_PARENT_ADD1
            ,fcft.GLOBAL_PARENT_ADD2
            ,fcft.GLOBAL_PARENT_CITY
            ,fcft.GLOBAL_PARENT_POSTAL_CODE
            ,fcft.GLOBAL_PARENT_COUNTRY
            ,fcft.GLOBAL_PARENT_STATE
            ,fcft.GLOBAL_PARENT_PHONE

    FROM        fv_ccr_file_temp fcft
    WHERE  exists ( select 1 from   fv_ccr_vendors fcv
                    where fcft.duns = fcv.duns)
    order by rowid;

    END IF;

    exception when no_data_found then
        l_errbuf :='No records found for DUNS in FV Extension Tables';
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);
        insert_temp_data(3,null,l_msg_no_duns,l_message_action3,null,null,null);
    end;
  ELSIF (l_update_type ='N') THEN
    l_errbuf :='Update Type as N - inserting into second temp table';
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

    INSERT INTO fv_ccr_process_gt ( FILE_DATE
            ,DUNS
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
            ,EDI
            ,TAXPAYER_ID
            ,AVG_NUM_EMPLOYEES
            ,SOCIAL_SECURITY_NUMBER
            ,FINANCIAL_INSTITUTE
            ,BANK_ACCT_NUMBER
            ,ABA_ROUTING
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
            ,HQ_PARENT_DUNS
            ,HQ_PARENT_ADD1
            ,HQ_PARENT_ADD2
            ,HQ_PARENT_CITY
            ,HQ_PARENT_STATE
            ,HQ_PARENT_POSTAL_CODE
            ,HQ_PARENT_COUNTRY
            ,HQ_PARENT_PHONE
            ,AUSTIN_TETRA_NUMBER
            ,AUSTIN_TETRA_PARENT_NUMBER
            ,AUSTIN_TETRA_ULTIMATE_NUMBER
            ,AUSTIN_TETRA_PCARD_FLAG
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
            ,HQ_PARENT_POC
            ,PAYMENT_TYPE
            ,ANNUAL_RECEIPTS
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
            )

    SELECT l_file_date
            ,fcft.DUNS
            ,replace(FCFT.PLUS_FOUR,' ',null)
            ,fcft.CAGE_CODE
            ,fcft.EXTRACT_CODE
            ,fcft.REGISTRATION_DATE
            ,fcft.RENEWAL_DATE
            ,fcft.LEGAL_BUS_NAME
            ,fcft.DBA_NAME
            ,fcft.DIVISION_NAME
            ,fcft.DIVISION_NUMBER
            ,fcft.ST_ADDRESS1
            ,fcft.ST_ADDRESS2
            ,fcft.CITY
            ,fcft.STATE
            ,fcft.POSTAL_CODE
            ,fcft.COUNTRY
            ,fcft.BUSINESS_START_DATE
            ,fcft.FISCAL_YR_CLOSE_DATE
            ,fcft.CORP_SECURITY_LEVEL
            ,fcft.EMP_SECURITY_LEVEL
            ,fcft.WEB_SITE
            ,fcft.ORGANIZATIONAL_TYPE
            ,fcft.STATE_OF_INC
            ,fcft.COUNTRY_OF_INC
            ,fcft.CREDIT_CARD_FLAG
            ,fcft.CORRESPONDENCE_FLAG
            ,fcft.MAIL_POC
            ,fcft.MAIL_ADD1
            ,fcft.MAIL_ADD2
            ,fcft.MAIL_CITY
            ,fcft.MAIL_POSTAL_CODE
            ,fcft.MAIL_COUNTRY
            ,fcft.MAIL_STATE
            ,fcft.PREV_BUS_POC
            ,fcft.PREV_BUS_ADD1
            ,fcft.PREV_BUS_ADD2
            ,fcft.PREV_BUS_CITY
            ,fcft.PREV_BUS_POSTAL_CODE
            ,fcft.PREV_BUS_COUNTRY
            ,fcft.PREV_BUS_STATE
            ,fcft.PARENT_POC
            ,fcft.PARENT_DUNS
            ,fcft.PARENT_ADD1
            ,fcft.PARENT_ADD2
            ,fcft.PARENT_CITY
            ,fcft.PARENT_POSTAL_CODE
            ,fcft.PARENT_COUNTRY
            ,fcft.PARENT_STATE
            ,fcft.GOV_PARENT_POC
            ,fcft.GOV_PARENT_ADD1
            ,fcft.GOV_PARENT_ADD2
            ,fcft.GOV_PARENT_CITY
            ,fcft.GOV_PARENT_POSTAL_CODE
            ,fcft.GOV_PARENT_COUNTRY
            ,fcft.GOV_PARENT_STATE
            ,fcft.GOV_BUS_POC
            ,fcft.GOV_BUS_ADD1
            ,fcft.GOV_BUS_ADD2
            ,fcft.GOV_BUS_CITY
            ,fcft.GOV_BUS_POSTAL_CODE
            ,fcft.GOV_BUS_COUNTRY
            ,fcft.GOV_BUS_STATE
            ,fcft.GOV_BUS_US_PHONE
            ,fcft.GOV_BUS_US_PHONE_EX
            ,fcft.GOV_BUS_NON_US_PHONE
            ,fcft.GOV_BUS_FAX
            ,fcft.GOV_BUS_EMAIL
            ,fcft.ALT_GOV_BUS_POC
            ,fcft.ALT_GOV_BUS_ADD1
            ,fcft.ALT_GOV_BUS_ADD2
            ,fcft.ALT_GOV_BUS_CITY
            ,fcft.ALT_GOV_BUS_POSTAL_CODE
            ,fcft.ALT_GOV_BUS_COUNTRY
            ,fcft.ALT_GOV_BUS_STATE
            ,fcft.ALT_GOV_BUS_US_PHONE
            ,fcft.ALT_GOV_BUS_US_PHONE_EX
            ,fcft.ALT_GOV_BUS_NON_US_PHONE
            ,fcft.ALT_GOV_BUS_FAX
            ,fcft.ALT_GOV_BUS_EMAIL
            ,fcft.PAST_PERF_POC
            ,fcft.PAST_PERF_ADD1
            ,fcft.PAST_PERF_ADD2
            ,fcft.PAST_PERF_CITY
            ,fcft.PAST_PERF_POSTAL_CODE
            ,fcft.PAST_PERF_COUNTRY
            ,fcft.PAST_PERF_STATE
            ,fcft.PAST_PERF_US_PHONE
            ,fcft.PAST_PERF_US_PHONE_EX
            ,fcft.PAST_PERF_NON_US_PHONE
            ,fcft.PAST_PERF_FAX
            ,fcft.PAST_PERF_EMAIL
            ,fcft.ALT_PAST_PERF_POC
            ,fcft.ALT_PAST_PERF_ADD1
            ,fcft.ALT_PAST_PERF_ADD2
            ,fcft.ALT_PAST_PERF_CITY
            ,fcft.ALT_PAST_PERF_POSTAL_CODE
            ,fcft.ALT_PAST_PERF_COUNTRY
            ,fcft.ALT_PAST_PERF_STATE
            ,fcft.ALT_PAST_PERF_US_PHONE
            ,fcft.ALT_PAST_PERF_US_PHONE_EX
            ,fcft.ALT_PAST_PERF_NON_US_PHONE
            ,fcft.ALT_PAST_PERF_FAX
            ,fcft.ALT_PAST_PERF_EMAIL
            ,fcft.ELEC_BUS_POC
            ,fcft.ELEC_BUS_ADD1
            ,fcft.ELEC_BUS_ADD2
            ,fcft.ELEC_BUS_CITY
            ,fcft.ELEC_BUS_POSTAL_CODE
            ,fcft.ELEC_BUS_COUNTRY
            ,fcft.ELEC_BUS_STATE
            ,fcft.ELEC_BUS_US_PHONE
            ,fcft.ELEC_BUS_US_PHONE_EX
            ,fcft.ELEC_BUS_NON_US_PHONE
            ,fcft.ELEC_BUS_FAX
            ,fcft.ELEC_BUS_EMAIL
            ,fcft.ALT_ELEC_BUS_POC
            ,fcft.ALT_ELEC_BUS_ADD1
            ,fcft.ALT_ELEC_BUS_ADD2
            ,fcft.ALT_ELEC_BUS_CITY
            ,fcft.ALT_ELEC_BUS_POSTAL_CODE
            ,fcft.ALT_ELEC_BUS_COUNTRY
            ,fcft.ALT_ELEC_BUS_STATE
            ,fcft.ALT_ELEC_BUS_US_PHONE
            ,fcft.ALT_ELEC_BUS_US_PHONE_EX
            ,fcft.ALT_ELEC_BUS_NON_US_PHONE
            ,fcft.ALT_ELEC_BUS_FAX
            ,fcft.ALT_ELEC_BUS_EMAIL
            ,fcft.CERTIFIER_POC
            ,fcft.CERTIFIER_US_PHONE
            ,fcft.CERTIFIER_US_PHONE_EX
            ,fcft.CERTIFIER_NON_US_PHONE
            ,fcft.CERTIFIER_FAX
            ,fcft.CERTIFIER_EMAIL
            ,fcft.ALT_CERTIFIER_POC
            ,fcft.ALT_CERTIFIER_US_PHONE
            ,fcft.ALT_CERTIFIER_US_PHONE_EX
            ,fcft.ALT_CERTIFIER_NON_US_PHONE
            ,fcft.CORP_INFO_POC
            ,fcft.CORP_INFO_US_PHONE
            ,fcft.CORP_INFO_US_PHONE_EX
            ,fcft.CORP_INFO_NON_US_PHONE
            ,fcft.CORP_INFO_FAX
            ,fcft.CORP_INFO_EMAIL
            ,fcft.OWNER_INFO_POC
            ,fcft.OWNER_INFO_US_PHONE
            ,fcft.OWNER_INFO_US_PHONE_EX
            ,fcft.OWNER_INFO_NON_US_PHONE
            ,fcft.OWNER_INFO_FAX
            ,fcft.OWNER_INFO_EMAIL
            ,fcft.EDI
            ,fcft.TAXPAYER_ID
            ,fcft.AVG_NUM_EMPLOYEES
            ,fcft.SOCIAL_SECURITY_NUMBER
            ,fcft.FINANCIAL_INSTITUTE
            ,fcft.BANK_ACCT_NUMBER
            ,fcft.ABA_ROUTING
            ,fcft.LOCKBOX_NUMBER
            ,fcft.AUTHORIZATION_DATE
            ,fcft.EFT_WAIVER
            ,fcft.ACH_US_PHONE
            ,fcft.ACH_NON_US_PHONE
            ,fcft.ACH_FAX
            ,fcft.ACH_EMAIL
            ,fcft.REMIT_POC
            ,fcft.REMIT_ADD1
            ,fcft.REMIT_ADD2
            ,fcft.REMIT_CITY
            ,fcft.REMIT_STATE
            ,fcft.REMIT_POSTAL_CODE
            ,fcft.REMIT_COUNTRY
            ,fcft.AR_POC
            ,fcft.AR_US_PHONE
            ,fcft.AR_US_PHONE_EX
            ,fcft.AR_NON_US_PHONE
            ,fcft.AR_FAX
            ,fcft.AR_EMAIL
            ,fcft.MPIN
            ,fcft.HQ_PARENT_DUNS
            ,fcft.HQ_PARENT_ADD1
            ,fcft.HQ_PARENT_ADD2
            ,fcft.HQ_PARENT_CITY
            ,fcft.HQ_PARENT_STATE
            ,fcft.HQ_PARENT_POSTAL_CODE
            ,fcft.HQ_PARENT_COUNTRY
            ,fcft.HQ_PARENT_PHONE
            ,fcft.AUSTIN_TETRA_NUMBER
            ,fcft.AUSTIN_TETRA_PARENT_NUMBER
            ,fcft.AUSTIN_TETRA_ULTIMATE_NUMBER
            ,fcft.AUSTIN_TETRA_PCARD_FLAG
            ,fcft.DNB_MONITOR_LAST_UPDATED
            ,fcft.DNB_MONITOR_STATUS
            ,fcft.DNB_MONITOR_CORP_NAME
            ,fcft.DNB_MONITOR_DBA
            ,fcft.DNB_MONITOR_ST_ADD1
            ,fcft.DNB_MONITOR_ST_ADD2
            ,fcft.DNB_MONITOR_CITY
            ,fcft.DNB_MONITOR_POSTAL_CODE
            ,fcft.DNB_MONITOR_COUNTRY_CODE
            ,fcft.DNB_MONITOR_STATE
            ,fcft.HQ_PARENT_POC
            ,fcft.PAYMENT_TYPE
            ,fcft.ANNUAL_RECEIPTS
            ,fcft.DOMESTIC_PARENT_POC
            ,fcft.DOMESTIC_PARENT_DUNS
            ,fcft.DOMESTIC_PARENT_ADD1
            ,fcft.DOMESTIC_PARENT_ADD2
            ,fcft.DOMESTIC_PARENT_CITY
            ,fcft.DOMESTIC_PARENT_POSTAL_CODE
            ,fcft.DOMESTIC_PARENT_COUNTRY
            ,fcft.DOMESTIC_PARENT_STATE
            ,fcft.DOMESTIC_PARENT_PHONE
            ,fcft.GLOBAL_PARENT_POC
            ,fcft.GLOBAL_PARENT_DUNS
            ,fcft.GLOBAL_PARENT_ADD1
            ,fcft.GLOBAL_PARENT_ADD2
            ,fcft.GLOBAL_PARENT_CITY
            ,fcft.GLOBAL_PARENT_POSTAL_CODE
            ,fcft.GLOBAL_PARENT_COUNTRY
            ,fcft.GLOBAL_PARENT_STATE
            ,fcft.GLOBAL_PARENT_PHONE

    FROM        fv_ccr_file_temp fcft
    WHERE  ( (p_xml_import = 'N' AND exists ( select 1 from   fv_ccr_vendors fcv
                    where fcft.duns = fcv.duns
                    and   fcv.ccr_status ='N'))
            OR p_xml_import='Y')
    order by rowid;


  ELSIF (l_update_type ='S') THEN

    l_errbuf := 'Update type as S - inserting into seciond temp table';
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);
    INSERT INTO fv_ccr_process_gt ( FILE_DATE
            ,DUNS
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
            --,BUSINESS_TYPES
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
            ,EDI
            ,TAXPAYER_ID
            ,AVG_NUM_EMPLOYEES
            ,SOCIAL_SECURITY_NUMBER
            ,FINANCIAL_INSTITUTE
            ,BANK_ACCT_NUMBER
            ,ABA_ROUTING
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
            ,HQ_PARENT_DUNS
            ,HQ_PARENT_ADD1
            ,HQ_PARENT_ADD2
            ,HQ_PARENT_CITY
            ,HQ_PARENT_STATE
            ,HQ_PARENT_POSTAL_CODE
            ,HQ_PARENT_COUNTRY
            ,HQ_PARENT_PHONE
            ,AUSTIN_TETRA_NUMBER
            ,AUSTIN_TETRA_PARENT_NUMBER
            ,AUSTIN_TETRA_ULTIMATE_NUMBER
            ,AUSTIN_TETRA_PCARD_FLAG
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
            ,HQ_PARENT_POC
            ,PAYMENT_TYPE
            ,ANNUAL_RECEIPTS
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
            )
    SELECT l_file_date
            ,fcft.DUNS
            ,replace(PLUS_FOUR,' ',null)
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
            --,BUSINESS_TYPES
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
            ,EDI
            ,TAXPAYER_ID
            ,AVG_NUM_EMPLOYEES
            ,SOCIAL_SECURITY_NUMBER
            ,FINANCIAL_INSTITUTE
            ,BANK_ACCT_NUMBER
            ,ABA_ROUTING
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
            ,HQ_PARENT_DUNS
            ,HQ_PARENT_ADD1
            ,HQ_PARENT_ADD2
            ,HQ_PARENT_CITY
            ,HQ_PARENT_STATE
            ,HQ_PARENT_POSTAL_CODE
            ,HQ_PARENT_COUNTRY
            ,HQ_PARENT_PHONE
            ,AUSTIN_TETRA_NUMBER
            ,AUSTIN_TETRA_PARENT_NUMBER
            ,AUSTIN_TETRA_ULTIMATE_NUMBER
            ,AUSTIN_TETRA_PCARD_FLAG
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
            ,HQ_PARENT_POC
            ,PAYMENT_TYPE
            ,ANNUAL_RECEIPTS
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
    FROM        fv_ccr_file_temp fcft
    WHERE fcft.duns = substr(p_duns, 1, 9)
    order by rowid;



  END IF;

  l_errbuf := 'Processing data for Extract Code as 1  ';
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

   -- set the status to disabled for code as 1
   UPDATE fv_ccr_vendors fcv SET fcv.ccr_status ='D',
                                fcv.enabled ='N' ,
                                fcv.extract_code ='1' ,
                                fcv.last_update_date = sysdate,
                                fcv.last_import_date = nvl(l_file_date,sysdate),
                                fcv.last_updated_by = fnd_global.user_id
      WHERE  exists ( SELECT 1 FROM fv_ccr_process_gt fcpg
                      WHERE fcv.duns = fcpg.duns
                      AND nvl(fcv.plus_four,-99)= nvl(fcpg.plus_four,-99)
                      AND fcpg.extract_code = '1');

      l_errbuf := 'Processing data for Extract Code as 4  ';
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);
   UPDATE fv_ccr_vendors fcv SET  ccr_status ='E',
                                                enabled='N',
                                                extract_code ='4',
                                                last_update_date = sysdate,
                                                last_updated_by = fnd_global.user_id,
                                                last_import_date = nvl(l_file_date,sysdate)
   WHERE exists ( SELECT 1 FROM fv_ccr_process_gt fcpg
                      WHERE fcv.duns = fcpg.duns
                      AND nvl(fcv.plus_four,-99)= nvl(fcpg.plus_four,-99)
                      AND fcpg.extract_code = '4');

   -- Fixed as part of BUG 3960809 for showing deleted/expired DUNS returned
   insert into fv_ccr_process_report(duns_info,record_type,reference1,reference2,reference3,reference4)
   SELECT DUNS||nvl(plus_four,''),'1',legal_bus_name,' ',' ',decode(fcpg.extract_code,'1','Deleted','4','Expired')
   FROM fv_ccr_process_gt fcpg
   WHERE fcpg.extract_code IN ('1','4');


  l_errbuf := 'Processing  CCR Data for a,2,3';
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

  FND_MESSAGE.SET_NAME('FV','FV_CCR_ASSIGN_PAY_OBJ');
  l_msg_pay_obj := FND_MESSAGE.GET;

  FOR l_ccr_data IN c_ccr_data
  LOOP


  l_errbuf := 'Processing DUNS - > '|| l_ccr_data.duns;
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

  l_valid_tin := nvl(l_ccr_data.taxpayer_id,l_ccr_data.social_security_number);
  IF((l_valid_tin IS NULL or length(l_valid_tin)<>9)
       AND l_ccr_data.country = 'USA') THEN
    FND_MESSAGE.set_NAME('FV','FV_CCR_INVALID_TAXPAYER_NUMBER');
    message_text := FND_MESSAGE.get;
    l_errbuf :='Invalid Taxpayer Number: '||nvl(l_valid_tin,'null');
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, 'main',l_errbuf);
    insert_temp_data(3,null,message_text ,null,l_ccr_data.duns||nvl(l_ccr_data.plus_four,''),null,null);

  ELSE

    /*l_code(1).code:=substr(l_ccr_data.business_types,1,2) ;
    l_code(2).code:=substr(l_ccr_data.business_types,3,2) ;
    l_code(3).code:=substr(l_ccr_data.business_types,5,2) ;
    l_code(4).code:=substr(l_ccr_data.business_types,7,2) ;
    l_code(5).code:=substr(l_ccr_data.business_types,9,2) ;
    l_code(6).code:=substr(l_ccr_data.business_types,11,2)        ;
    l_code(7).code:=substr(l_ccr_data.business_types,13,2)        ;
    l_code(8).code:=substr(l_ccr_data.business_types,15,2)        ;
    l_code(9).code:=substr(l_ccr_data.business_types,17,2)        ;
    l_code(10).code:=substr(l_ccr_data.business_types,19,2)       ;
    l_code(11).code:=substr(l_ccr_data.sic_codes,1,8)     ;
    l_code(12).code:=substr(l_ccr_data.sic_codes,9,8)     ;
    l_code(13).code:=substr(l_ccr_data.sic_codes,17,8)    ;
    l_code(14).code:=substr(l_ccr_data.sic_codes,25,8)    ;
    l_code(15).code:=substr(l_ccr_data.sic_codes,33,8)    ;
    l_code(16).code:=substr(l_ccr_data.sic_codes,41,8)    ;
    l_code(17).code:=substr(l_ccr_data.sic_codes,49,8)    ;
    l_code(18).code:=substr(l_ccr_data.sic_codes,57,8)    ;
    l_code(19).code:=substr(l_ccr_data.sic_codes,65,8)    ;
    l_code(20).code:=substr(l_ccr_data.sic_codes,73,8)    ;
    l_code(21).code:=substr(l_ccr_data.sic_codes,81,8)    ;
    l_code(22).code:=substr(l_ccr_data.sic_codes,89,8)    ;
    l_code(23).code:=substr(l_ccr_data.sic_codes,97,8)    ;
    l_code(24).code:=substr(l_ccr_data.sic_codes,105,8)   ;
    l_code(25).code:=substr(l_ccr_data.sic_codes,113,8)   ;
    l_code(26).code:=substr(l_ccr_data.sic_codes,121,8)   ;
    l_code(27).code:=substr(l_ccr_data.sic_codes,129,8)   ;
    l_code(28).code:=substr(l_ccr_data.sic_codes,137,8)   ;
    l_code(29).code:=substr(l_ccr_data.sic_codes,145,8)   ;
    l_code(30).code:=substr(l_ccr_data.sic_codes,153,8)   ;
    l_code(31).code:=substr(l_ccr_data.naics_codes,1,6)   ;
    l_code(32).code:=substr(l_ccr_data.naics_codes,7,6)   ;
    l_code(33).code:=substr(l_ccr_data.naics_codes,13,6)  ;
    l_code(34).code:=substr(l_ccr_data.naics_codes,19,6)  ;
    l_code(35).code:=substr(l_ccr_data.naics_codes,25,6)  ;
    l_code(36).code:=substr(l_ccr_data.naics_codes,31,6)  ;
    l_code(37).code:=substr(l_ccr_data.naics_codes,37,6)  ;
    l_code(38).code:=substr(l_ccr_data.naics_codes,43,6)  ;
    l_code(39).code:=substr(l_ccr_data.naics_codes,49,6)  ;
    l_code(40).code:=substr(l_ccr_data.naics_codes,55,6)  ;
    l_code(41).code:=substr(l_ccr_data.naics_codes,61,6)  ;
    l_code(42).code:=substr(l_ccr_data.naics_codes,67,6)  ;
    l_code(43).code:=substr(l_ccr_data.naics_codes,73,6)  ;
    l_code(44).code:=substr(l_ccr_data.naics_codes,79,6)  ;
    l_code(45).code:=substr(l_ccr_data.naics_codes,85,6)  ;
    l_code(46).code:=substr(l_ccr_data.naics_codes,91,6)  ;
    l_code(47).code:=substr(l_ccr_data.naics_codes,97,6)  ;
    l_code(48).code:=substr(l_ccr_data.naics_codes,103,6) ;
    l_code(49).code:=substr(l_ccr_data.naics_codes,109,6) ;
    l_code(50).code:=substr(l_ccr_data.naics_codes,115,6) ;
    l_code(51).code:=substr(l_ccr_data.fsc_codes,1,4)     ;
    l_code(52).code:=substr(l_ccr_data.fsc_codes,5,4)     ;
    l_code(53).code:=substr(l_ccr_data.fsc_codes,9,4)     ;
    l_code(54).code:=substr(l_ccr_data.fsc_codes,13,4)    ;
    l_code(55).code:=substr(l_ccr_data.fsc_codes,17,4)    ;
    l_code(56).code:=substr(l_ccr_data.fsc_codes,21,4)    ;
    l_code(57).code:=substr(l_ccr_data.fsc_codes,25,4)    ;
    l_code(58).code:=substr(l_ccr_data.fsc_codes,29,4)    ;
    l_code(59).code:=substr(l_ccr_data.fsc_codes,34,4)    ;
    l_code(60).code:=substr(l_ccr_data.fsc_codes,37,4)    ;
    l_code(61).code:=substr(l_ccr_data.psc_codes,1,4)     ;
    l_code(62).code:=substr(l_ccr_data.psc_codes,5,4)     ;
    l_code(63).code:=substr(l_ccr_data.psc_codes,9,4)     ;
    l_code(64).code:=substr(l_ccr_data.psc_codes,13,4)    ;
    l_code(65).code:=substr(l_ccr_data.psc_codes,17,4)    ;
    l_code(66).code:=substr(l_ccr_data.psc_codes,21,4)    ;
    l_code(67).code:=substr(l_ccr_data.psc_codes,25,4)    ;
    l_code(68).code:=substr(l_ccr_data.psc_codes,29,4)    ;
    l_code(69).code:=substr(l_ccr_data.psc_codes,33,4)    ;
    l_code(70).code:=substr(l_ccr_data.psc_codes,37,4)    ;*/
    l_code(71).code:=l_ccr_data.ORGANIZATIONAL_TYPE;
    l_code(72).code:=l_ccr_data.CORRESPONDENCE_FLAG       ;
    l_code(73).code:=l_ccr_data.CORP_SECURITY_LEVEL       ;
    l_code(74).code:=l_ccr_data.EMP_SECURITY_LEVEL        ;


    /*l_code(1).rec_type:='B'       ;
    l_code(2).rec_type:='B'       ;
    l_code(3).rec_type:='B'       ;
    l_code(4).rec_type:='B'       ;
    l_code(5).rec_type:='B'       ;
    l_code(6).rec_type:='B'       ;
    l_code(7).rec_type:='B'       ;
    l_code(8).rec_type:='B'       ;
    l_code(9).rec_type:='B'       ;
    l_code(10).rec_type:='B'      ;
    l_code(11).rec_type:='S'      ;
    l_code(12).rec_type:='S'      ;
    l_code(13).rec_type:='S'      ;
    l_code(14).rec_type:='S'      ;
    l_code(15).rec_type:='S'      ;
    l_code(16).rec_type:='S'      ;
    l_code(17).rec_type:='S'      ;
    l_code(18).rec_type:='S'      ;
    l_code(19).rec_type:='S'      ;
    l_code(20).rec_type:='S'      ;
    l_code(21).rec_type:='S'      ;
    l_code(22).rec_type:='S'      ;
    l_code(23).rec_type:='S'      ;
    l_code(24).rec_type:='S'      ;
    l_code(25).rec_type:='S'      ;
    l_code(26).rec_type:='S'      ;
    l_code(27).rec_type:='S'      ;
    l_code(28).rec_type:='S'      ;
    l_code(29).rec_type:='S'      ;
    l_code(30).rec_type:='S'      ;
    l_code(31).rec_type:='N'      ;
    l_code(32).rec_type:='N'      ;
    l_code(33).rec_type:='N'      ;
    l_code(34).rec_type:='N'      ;
    l_code(35).rec_type:='N'      ;
    l_code(36).rec_type:='N'      ;
    l_code(37).rec_type:='N'      ;
    l_code(38).rec_type:='N'      ;
    l_code(39).rec_type:='N'      ;
    l_code(40).rec_type:='N'      ;
    l_code(41).rec_type:='N'      ;
    l_code(42).rec_type:='N'      ;
    l_code(43).rec_type:='N'      ;
    l_code(44).rec_type:='N'      ;
    l_code(45).rec_type:='N'      ;
    l_code(46).rec_type:='N'      ;
    l_code(47).rec_type:='N'      ;
    l_code(48).rec_type:='N'      ;
    l_code(49).rec_type:='N'      ;
    l_code(50).rec_type:='N'      ;
    l_code(51).rec_type:='F'      ;
    l_code(52).rec_type:='F'      ;
    l_code(53).rec_type:='F'      ;
    l_code(54).rec_type:='F'      ;
    l_code(55).rec_type:='F'      ;
    l_code(56).rec_type:='F'      ;
    l_code(57).rec_type:='F'      ;
    l_code(58).rec_type:='F'      ;
    l_code(59).rec_type:='F'      ;
    l_code(60).rec_type:='F'      ;
    l_code(61).rec_type:='P'      ;
    l_code(62).rec_type:='P'      ;
    l_code(63).rec_type:='P'      ;
    l_code(64).rec_type:='P'      ;
    l_code(65).rec_type:='P'      ;
    l_code(66).rec_type:='P'      ;
    l_code(67).rec_type:='P'      ;
    l_code(68).rec_type:='P'      ;
    l_code(69).rec_type:='P'      ;
    l_code(70).rec_type:='P'      ;*/
    l_code(71).rec_type:='O'      ;
    l_code(72).rec_type:='C'      ;
    l_code(73).rec_type:='CS'     ;
    l_code(74).rec_type:='ES'     ;

    /*bug 3897523, no longer need to check codes against lookups.
    l_errbuf := 'calling  - > find code ';
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

    find_code(l_code);
    l_errbuf := 'after -> find code';
    FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);
   */
    -- set the status as active
    l_status :='A';

 --sthota
    begin
       select vendor_id into l_active_vendor_id from fv_ccr_vendors
       where DUNS = l_ccr_data.duns and plus_four is null and ccr_status in ('E');

       if l_ccr_data.renewal_date > trunc(sysdate) then

        if l_active_vendor_id is not null then
        l_errbuf := 'Found New Active Vendor Id:'||l_active_vendor_id||' For DUNS: '||l_ccr_data.duns;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

        l_active_vendor_exists := 0;

        if l_vendor_cnt > 0 then
           for i in 1..l_vendor_cnt
           loop
            if vendor_ids(i) = l_active_vendor_id then
            l_active_vendor_exists := 1;
            end if;
           end loop;
        end if;

        if l_active_vendor_exists <> 1 then
        l_vendor_cnt := l_vendor_cnt + 1;
        vendor_ids(l_vendor_cnt) := l_active_vendor_id;
        duns_ids(l_vendor_cnt) := l_ccr_data.duns;
        end if;

        else

        l_errbuf := 'Found No Vendor Id:'||l_active_vendor_id||' For New Active DUNS: '||l_ccr_data.duns;
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

        end if; --if vendor id is null
       end if; --renewal date

      exception when no_data_found then
      null;
     end;

    IF l_ccr_data.plus_four is not null  THEN
      BEGIN
      l_errbuf := 'Processing -> DUN+4 now '||l_ccr_data.plus_four;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

      SELECT legal_bus_name into l_lbe_change FROM fv_ccr_vendors fcv
              WHERE fcv.duns = l_ccr_data.duns
                      AND fcv.plus_four= l_ccr_data.plus_four ;
      -- if this select does not return rows ,we need to update DUNS and duns+4 information
      l_errbuf := 'DUNS+4 exists';
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

        --validate for the renewal date)
        IF (l_ccr_data.renewal_date < trunc(sysdate) ) THEN
                                l_status:='E';
        END IF; --end of renewal date

           --call to update the DUNS record
       l_errbuf := 'Updating DUNS+4 info ';
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

       -- BUG 3839843
       IF (l_lbe_change <> l_ccr_data.legal_bus_name) THEN

           FND_MESSAGE.set_NAME('FV','FV_CCR_LBE_CHANGED');
           message_text := FND_MESSAGE.get;

           l_errbuf :='Legal Bus Name changed from '||l_lbe_change||' -> '||l_ccr_data.legal_bus_name;
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, 'find_code',l_errbuf);
           insert_temp_data(3,null,message_text ,null,l_ccr_data.duns||l_ccr_data.plus_four,null,null);

       END IF;


       update fv_ccr_vendors fcv set
         fcv.CCR_FLAG                                   ='R'                            ,
         fcv.CCR_STATUS                                 =l_status                       ,
         fcv.DUNS                                       =l_ccr_data.DUNS                                ,
         fcv.PLUS_FOUR                                  =l_ccr_data.PLUS_FOUR                           ,
         fcv.CAGE_CODE                                  =l_ccr_data.CAGE_CODE                           ,
         fcv.EXTRACT_CODE                               =l_ccr_data.EXTRACT_CODE                    ,
         fcv.REGISTRATION_DATE                          =l_ccr_data.REGISTRATION_DATE                   ,
         fcv.RENEWAL_DATE                               =l_ccr_data.RENEWAL_DATE                        ,
         fcv.LEGAL_BUS_NAME                             =l_ccr_data.LEGAL_BUS_NAME                      ,
         fcv.DBA_NAME                                   =l_ccr_data.DBA_NAME                            ,
         fcv.DIVISION_NAME                              =l_ccr_data.DIVISION_NAME                       ,
         fcv.DIVISION_NUMBER                            =l_ccr_data.DIVISION_NUMBER                     ,
         fcv.ST_ADDRESS1                                =l_ccr_data.ST_ADDRESS1                         ,
         fcv.ST_ADDRESS2                                =l_ccr_data.ST_ADDRESS2                         ,
         fcv.CITY                                       =l_ccr_data.CITY                                ,
         fcv.STATE                                      =l_ccr_data.STATE                               ,
         fcv.POSTAL_CODE                                =l_ccr_data.POSTAL_CODE                         ,
         --Bug8335551
         --fcv.COUNTRY                                    =l_ccr_data.COUNTRY                             ,
         fcv.COUNTRY                                    =get_territory_code(l_ccr_data.COUNTRY)         ,
         fcv.BUSINESS_START_DATE                        =l_ccr_data.BUSINESS_START_DATE                 ,
         fcv.FISCAL_YR_CLOSE_DATE                       =l_ccr_data.FISCAL_YR_CLOSE_DATE                ,
         fcv.WEB_SITE                                   =l_ccr_data.WEB_SITE                            ,
         fcv.CREDIT_CARD_FLAG                           =l_ccr_data.CREDIT_CARD_FLAG                            ,
         fcv.MAIL_POC                                   =l_ccr_data.MAIL_POC                                    ,
         fcv.MAIL_ADD1                                  =l_ccr_data.MAIL_ADD1                                   ,
         fcv.MAIL_ADD2                                  =l_ccr_data.MAIL_ADD2                                   ,
         fcv.MAIL_CITY                                  =l_ccr_data.MAIL_CITY                                   ,
         fcv.MAIL_POSTAL_CODE                           =l_ccr_data.MAIL_POSTAL_CODE                            ,
         --Bug8335551
         --fcv.MAIL_COUNTRY                               =l_ccr_data.MAIL_COUNTRY                                ,
         fcv.MAIL_COUNTRY                               =get_territory_code(l_ccr_data.MAIL_COUNTRY)                                ,
         fcv.MAIL_STATE                                 =l_ccr_data.MAIL_STATE                                  ,
         fcv.PREV_BUS_POC                               =l_ccr_data.PREV_BUS_POC                                ,
         fcv.PREV_BUS_ADD1                              =l_ccr_data.PREV_BUS_ADD1                               ,
         fcv.PREV_BUS_ADD2                              =l_ccr_data.PREV_BUS_ADD2                               ,
         fcv.PREV_BUS_CITY                              =l_ccr_data.PREV_BUS_CITY                               ,
         fcv.PREV_BUS_POSTAL_CODE                       =l_ccr_data.PREV_BUS_POSTAL_CODE                        ,
         fcv.PREV_BUS_COUNTRY                           =l_ccr_data.PREV_BUS_COUNTRY                            ,
         fcv.PREV_BUS_STATE                             =l_ccr_data.PREV_BUS_STATE                              ,
         fcv.PARENT_POC                                 =l_ccr_data.PARENT_POC                                  ,
         fcv.PARENT_DUNS                                =l_ccr_data.PARENT_DUNS                                 ,
         fcv.PARENT_ADD1                                =l_ccr_data.PARENT_ADD1                                 ,
         fcv.PARENT_ADD2                                =l_ccr_data.PARENT_ADD2                                 ,
         fcv.PARENT_CITY                                =l_ccr_data.PARENT_CITY                                 ,
         fcv.PARENT_POSTAL_CODE                         =l_ccr_data.PARENT_POSTAL_CODE                          ,
         fcv.PARENT_COUNTRY                             =l_ccr_data.PARENT_COUNTRY                              ,
         fcv.PARENT_STATE                               =l_ccr_data.PARENT_STATE                                ,
         fcv.PARTY_PERF_POC                             =l_ccr_data.PARTY_PERF_POC                              ,
         fcv.PARTY_PERF_ADD1                            =l_ccr_data.PARTY_PERF_ADD1                             ,
         fcv.PARTY_PERF_ADD2                            =l_ccr_data.PARTY_PERF_ADD2                             ,
         fcv.PARTY_PERF_CITY                            =l_ccr_data.PARTY_PERF_CITY                             ,
         fcv.PARTY_PERF_POSTAL_CODE                     =l_ccr_data.PARTY_PERF_POSTAL_CODE                      ,
         fcv.PARTY_PERF_COUNTRY                         =l_ccr_data.PARTY_PERF_COUNTRY                          ,
         fcv.PARTY_PERF_STATE                           =l_ccr_data.PARTY_PERF_STATE                            ,
         fcv.GOV_PARENT_POC                             =l_ccr_data.GOV_PARENT_POC                              ,
         fcv.GOV_PARENT_ADD1                            =l_ccr_data.GOV_PARENT_ADD1                             ,
         fcv.GOV_PARENT_ADD2                            =l_ccr_data.GOV_PARENT_ADD2                             ,
         fcv.GOV_PARENT_CITY                            =l_ccr_data.GOV_PARENT_CITY                             ,
         fcv.GOV_PARENT_POSTAL_CODE                     =l_ccr_data.GOV_PARENT_POSTAL_CODE                      ,
         fcv.GOV_PARENT_COUNTRY                         =l_ccr_data.GOV_PARENT_COUNTRY                          ,
         fcv.GOV_PARENT_STATE                           =l_ccr_data.GOV_PARENT_STATE                            ,
         fcv.GOV_BUS_POC                                =l_ccr_data.GOV_BUS_POC                                 ,
         fcv.GOV_BUS_ADD1                               =l_ccr_data.GOV_BUS_ADD1                                ,
         fcv.GOV_BUS_ADD2                               =l_ccr_data.GOV_BUS_ADD2                                ,
         fcv.GOV_BUS_CITY                               =l_ccr_data.GOV_BUS_CITY                                ,
         fcv.GOV_BUS_POSTAL_CODE                        =l_ccr_data.GOV_BUS_POSTAL_CODE                         ,
         fcv.GOV_BUS_COUNTRY                            =l_ccr_data.GOV_BUS_COUNTRY                             ,
         fcv.GOV_BUS_STATE                              =l_ccr_data.GOV_BUS_STATE                               ,
         fcv.GOV_BUS_US_PHONE                           =l_ccr_data.GOV_BUS_US_PHONE                            ,
         fcv.GOV_BUS_US_PHONE_EX                        =l_ccr_data.GOV_BUS_US_PHONE_EX                         ,
         fcv.GOV_BUS_NON_US_PHONE                       =l_ccr_data.GOV_BUS_NON_US_PHONE                        ,
         fcv.GOV_BUS_FAX                                =l_ccr_data.GOV_BUS_FAX                                 ,
         fcv.GOV_BUS_EMAIL                              =l_ccr_data.GOV_BUS_EMAIL                               ,
         fcv.ALT_GOV_BUS_POC                            =l_ccr_data.ALT_GOV_BUS_POC                             ,
         fcv.ALT_GOV_BUS_ADD1                           =l_ccr_data.ALT_GOV_BUS_ADD1                            ,
         fcv.ALT_GOV_BUS_ADD2                           =l_ccr_data.ALT_GOV_BUS_ADD2                            ,
         fcv.ALT_GOV_BUS_CITY                           =l_ccr_data.ALT_GOV_BUS_CITY                            ,
         fcv.ALT_GOV_BUS_POSTAL_CODE                    =l_ccr_data.ALT_GOV_BUS_POSTAL_CODE                     ,
         fcv.ALT_GOV_BUS_COUNTRY                        =l_ccr_data.ALT_GOV_BUS_COUNTRY                         ,
         fcv.ALT_GOV_BUS_STATE                          =l_ccr_data.ALT_GOV_BUS_STATE                           ,
         fcv.ALT_GOV_BUS_US_PHONE                       =l_ccr_data.ALT_GOV_BUS_US_PHONE                        ,
         fcv.ALT_GOV_BUS_US_PHONE_EX                    =l_ccr_data.ALT_GOV_BUS_US_PHONE_EX                     ,
         fcv.ALT_GOV_BUS_NON_US_PHONE                   =l_ccr_data.ALT_GOV_BUS_NON_US_PHONE                    ,
         fcv.ALT_GOV_BUS_FAX                            =l_ccr_data.ALT_GOV_BUS_FAX                             ,
         fcv.ALT_GOV_BUS_EMAIL                          =l_ccr_data.ALT_GOV_BUS_EMAIL                           ,
         fcv.PAST_PERF_POC                              =l_ccr_data.PAST_PERF_POC                               ,
         fcv.PAST_PERF_ADD1                             =l_ccr_data.PAST_PERF_ADD1                              ,
         fcv.PAST_PERF_ADD2                             =l_ccr_data.PAST_PERF_ADD2                              ,
         fcv.PAST_PERF_CITY                             =l_ccr_data.PAST_PERF_CITY                              ,
         fcv.PAST_PERF_POSTAL_CODE                      =l_ccr_data.PAST_PERF_POSTAL_CODE                       ,
         fcv.PAST_PERF_COUNTRY                          =l_ccr_data.PAST_PERF_COUNTRY                           ,
         fcv.PAST_PERF_STATE                            =l_ccr_data.PAST_PERF_STATE                             ,
         fcv.PAST_PERF_US_PHONE                         =l_ccr_data.PAST_PERF_US_PHONE                          ,
         fcv.PAST_PERF_US_PHONE_EX                      =l_ccr_data.PAST_PERF_US_PHONE_EX                       ,
         fcv.PAST_PERF_NON_US_PHONE                     =l_ccr_data.PAST_PERF_NON_US_PHONE                      ,
         fcv.PAST_PERF_FAX                              =l_ccr_data.PAST_PERF_FAX                               ,
         fcv.PAST_PERF_EMAIL                            =l_ccr_data.PAST_PERF_EMAIL                             ,
         fcv.ALT_PAST_PERF_POC                          =l_ccr_data.ALT_PAST_PERF_POC                           ,
         fcv.ALT_PAST_PERF_ADD1                         =l_ccr_data.ALT_PAST_PERF_ADD1                          ,
         fcv.ALT_PAST_PERF_ADD2                         =l_ccr_data.ALT_PAST_PERF_ADD2                          ,
         fcv.ALT_PAST_PERF_CITY                         =l_ccr_data.ALT_PAST_PERF_CITY                          ,
         fcv.ALT_PAST_PERF_POSTAL_CODE                  =l_ccr_data.ALT_PAST_PERF_POSTAL_CODE                   ,
         fcv.ALT_PAST_PERF_COUNTRY                      =l_ccr_data.ALT_PAST_PERF_COUNTRY                       ,
         fcv.ALT_PAST_PERF_STATE                        =l_ccr_data.ALT_PAST_PERF_STATE                         ,
         fcv.ALT_PAST_PERF_US_PHONE                     =l_ccr_data.ALT_PAST_PERF_US_PHONE                      ,
         fcv.ALT_PAST_PERF_US_PHONE_EX                  =l_ccr_data.ALT_PAST_PERF_US_PHONE_EX                   ,
         fcv.ALT_PAST_PERF_NON_US_PHONE                 =l_ccr_data.ALT_PAST_PERF_NON_US_PHONE                  ,
         fcv.ALT_PAST_PERF_FAX                          =l_ccr_data.ALT_PAST_PERF_FAX                           ,
         fcv.ALT_PAST_PERF_EMAIL                        =l_ccr_data.ALT_PAST_PERF_EMAIL                         ,
         fcv.ELEC_BUS_POC                               =l_ccr_data.ELEC_BUS_POC                                ,
         fcv.ELEC_BUS_ADD1                              =l_ccr_data.ELEC_BUS_ADD1                               ,
         fcv.ELEC_BUS_ADD2                              =l_ccr_data.ELEC_BUS_ADD2                               ,
         fcv.ELEC_BUS_CITY                              =l_ccr_data.ELEC_BUS_CITY                               ,
         fcv.ELEC_BUS_POSTAL_CODE                       =l_ccr_data.ELEC_BUS_POSTAL_CODE                        ,
         fcv.ELEC_BUS_COUNTRY                           =l_ccr_data.ELEC_BUS_COUNTRY                            ,
         fcv.ELEC_BUS_STATE                             =l_ccr_data.ELEC_BUS_STATE                              ,
         fcv.ELEC_BUS_US_PHONE                          =l_ccr_data.ELEC_BUS_US_PHONE                           ,
         fcv.ELEC_BUS_US_PHONE_EX                       =l_ccr_data.ELEC_BUS_US_PHONE_EX                        ,
         fcv.ELEC_BUS_NON_US_PHONE                      =l_ccr_data.ELEC_BUS_NON_US_PHONE                       ,
         fcv.ELEC_BUS_FAX                               =l_ccr_data.ELEC_BUS_FAX                                ,
         fcv.ELEC_BUS_EMAIL                             =l_ccr_data.ELEC_BUS_EMAIL                              ,
         fcv.ALT_ELEC_BUS_POC                           =l_ccr_data.ALT_ELEC_BUS_POC                            ,
         fcv.ALT_ELEC_BUS_ADD1                          =l_ccr_data.ALT_ELEC_BUS_ADD1                           ,
         fcv.ALT_ELEC_BUS_ADD2                          =l_ccr_data.ALT_ELEC_BUS_ADD2                           ,
         fcv.ALT_ELEC_BUS_CITY                          =l_ccr_data.ALT_ELEC_BUS_CITY                           ,
         fcv.ALT_ELEC_BUS_POSTAL_CODE                   =l_ccr_data.ALT_ELEC_BUS_POSTAL_CODE                    ,
         fcv.ALT_ELEC_BUS_COUNTRY                       =l_ccr_data.ALT_ELEC_BUS_COUNTRY                        ,
         fcv.ALT_ELEC_BUS_STATE                         =l_ccr_data.ALT_ELEC_BUS_STATE                          ,
         fcv.ALT_ELEC_BUS_US_PHONE                      =l_ccr_data.ALT_ELEC_BUS_US_PHONE                       ,
         fcv.ALT_ELEC_BUS_US_PHONE_EX                   =l_ccr_data.ALT_ELEC_BUS_US_PHONE_EX                    ,
         fcv.ALT_ELEC_BUS_NON_US_PHONE                  =l_ccr_data.ALT_ELEC_BUS_NON_US_PHONE                   ,
         fcv.ALT_ELEC_BUS_FAX                           =l_ccr_data.ALT_ELEC_BUS_FAX                            ,
         fcv.ALT_ELEC_BUS_EMAIL                         =l_ccr_data.ALT_ELEC_BUS_EMAIL                          ,
         fcv.CERTIFIER_POC                              =l_ccr_data.CERTIFIER_POC                               ,
         fcv.CERTIFIER_US_PHONE                         =l_ccr_data.CERTIFIER_US_PHONE                          ,
         fcv.CERTIFIER_US_PHONE_EX                      =l_ccr_data.CERTIFIER_US_PHONE_EX                       ,
         fcv.CERTIFIER_NON_US_PHONE                     =l_ccr_data.CERTIFIER_NON_US_PHONE                      ,
         fcv.CERTIFIER_FAX                              =l_ccr_data.CERTIFIER_FAX                               ,
         fcv.CERTIFIER_EMAIL                            =l_ccr_data.CERTIFIER_EMAIL                             ,
         fcv.ALT_CERTIFIER_POC                          =l_ccr_data.ALT_CERTIFIER_POC                           ,
         fcv.ALT_CERTIFIER_US_PHONE                     =l_ccr_data.ALT_CERTIFIER_US_PHONE                      ,
         fcv.ALT_CERTIFIER_US_PHONE_EX                  =l_ccr_data.ALT_CERTIFIER_US_PHONE_EX                   ,
         fcv.ALT_CERTIFIER_NON_US_PHONE                 =l_ccr_data.ALT_CERTIFIER_NON_US_PHONE                  ,
         fcv.CORP_INFO_POC                              =l_ccr_data.CORP_INFO_POC                               ,
         fcv.CORP_INFO_US_PHONE                         =l_ccr_data.CORP_INFO_US_PHONE                          ,
         fcv.CORP_INFO_US_PHONE_EX                      =l_ccr_data.CORP_INFO_US_PHONE_EX                       ,
         fcv.CORP_INFO_NON_US_PHONE                     =l_ccr_data.CORP_INFO_NON_US_PHONE                      ,
         fcv.CORP_INFO_FAX                              =l_ccr_data.CORP_INFO_FAX                               ,
         fcv.CORP_INFO_EMAIL                            =l_ccr_data.CORP_INFO_EMAIL                             ,
         fcv.OWNER_INFO_POC                             =l_ccr_data.OWNER_INFO_POC                              ,
         fcv.OWNER_INFO_US_PHONE                        =l_ccr_data.OWNER_INFO_US_PHONE                         ,
         fcv.OWNER_INFO_US_PHONE_EX                     =l_ccr_data.OWNER_INFO_US_PHONE_EX                      ,
         fcv.OWNER_INFO_NON_US_PHONE                    =l_ccr_data.OWNER_INFO_NON_US_PHONE                     ,
         fcv.OWNER_INFO_FAX                             =l_ccr_data.OWNER_INFO_FAX                              ,
         fcv.OWNER_INFO_EMAIL                           =l_ccr_data.OWNER_INFO_EMAIL                            ,
         fcv.EDI                                        =l_ccr_data.EDI                                         ,
         fcv.TAXPAYER_ID                                =l_ccr_data.TAXPAYER_ID                                 ,
         fcv.AVG_NUM_EMPLOYEES                          =l_ccr_data.AVG_NUM_EMPLOYEES                           ,
         fcv.ANNUAL_REVENUE                             =l_ccr_data.ANNUAL_REVENUE                              ,
         fcv.SOCIAL_SECURITY_NUMBER                     =l_ccr_data.SOCIAL_SECURITY_NUMBER                      ,
         fcv.FINANCIAL_INSTITUTE                        =l_ccr_data.FINANCIAL_INSTITUTE                         ,
         fcv.BANK_ACCT_NUMBER                           =l_ccr_data.BANK_ACCT_NUMBER                            ,
         fcv.ABA_ROUTING                                =l_ccr_data.ABA_ROUTING                                 ,
         fcv.BANK_ACCT_TYPE                             =l_ccr_data.BANK_ACCT_TYPE                              ,
         fcv.LOCKBOX_NUMBER                             =l_ccr_data.LOCKBOX_NUMBER                              ,
         fcv.AUTHORIZATION_DATE                         =l_ccr_data.AUTHORIZATION_DATE                          ,
         fcv.EFT_WAIVER                                 =l_ccr_data.EFT_WAIVER                                  ,
         fcv.ACH_US_PHONE                               =l_ccr_data.ACH_US_PHONE                                ,
         fcv.ACH_NON_US_PHONE                           =l_ccr_data.ACH_NON_US_PHONE                            ,
         fcv.ACH_FAX                                    =l_ccr_data.ACH_FAX                                     ,
         fcv.ACH_EMAIL                                  =l_ccr_data.ACH_EMAIL                                   ,
         fcv.REMIT_POC                                  =l_ccr_data.REMIT_POC                                   ,
         fcv.REMIT_ADD1                                 =l_ccr_data.REMIT_ADD1                                  ,
         fcv.REMIT_ADD2                                 =l_ccr_data.REMIT_ADD2                                  ,
         fcv.REMIT_CITY                                 =l_ccr_data.REMIT_CITY                                  ,
         fcv.REMIT_STATE                                =l_ccr_data.REMIT_STATE                                 ,
         fcv.REMIT_POSTAL_CODE                          =l_ccr_data.REMIT_POSTAL_CODE                           ,
         --Bug8335551
         --fcv.REMIT_COUNTRY                              =l_ccr_data.REMIT_COUNTRY                               ,
         fcv.REMIT_COUNTRY                              =get_territory_code(l_ccr_data.REMIT_COUNTRY)                               ,
         fcv.AR_POC                                     =l_ccr_data.AR_POC                                      ,
         fcv.AR_US_PHONE                                =l_ccr_data.AR_US_PHONE                                 ,
         fcv.AR_US_PHONE_EX                             =l_ccr_data.AR_US_PHONE_EX                              ,
         fcv.AR_NON_US_PHONE                            =l_ccr_data.AR_NON_US_PHONE                             ,
         fcv.AR_FAX                                     =l_ccr_data.AR_FAX                                      ,
         fcv.AR_EMAIL                                   =l_ccr_data.AR_EMAIL                                    ,
         fcv.MPIN                                       =l_ccr_data.MPIN                                        ,
         fcv.EDI_COORDINATOR                            =l_ccr_data.EDI_COORDINATOR                             ,
         fcv.EDI_US_PHONE                               =l_ccr_data.EDI_US_PHONE                                ,
         fcv.EDI_US_PHONE_EX                            =l_ccr_data.EDI_US_PHONE_EX                             ,
         fcv.EDI_NON_US_PHONE                           =l_ccr_data.EDI_NON_US_PHONE                            ,
         fcv.EDI_FAX                                    =l_ccr_data.EDI_FAX                                     ,
         fcv.EDI_EMAIL                                  =l_ccr_data.EDI_EMAIL                                   ,
         fcv.STATE_OF_INC                               =l_ccr_data.state_of_inc                                    ,
         fcv.COUNTRY_OF_INC                             =l_ccr_data.country_of_inc                                  ,
         fcv.organizational_type                        =l_code(71).code    ,
         fcv.correspondence_flag                        =l_code(72).code    ,
         fcv.corp_security_level                        =l_code(73).code    ,
         fcv.emp_security_level                         =l_code(74).code    ,
         fcv.last_update_date                           =sysdate,
         fcv.last_updated_by                            =l_user_id,
         fcv.last_import_date                           =l_ccr_data.file_date
           ,fcv.AUSTIN_TETRA_NUMBER                    =l_ccr_data.AUSTIN_TETRA_NUMBER
,fcv.AUSTIN_TETRA_PARENT_NUMBER             =l_ccr_data.AUSTIN_TETRA_PARENT_NUMBER
,fcv.AUSTIN_TETRA_ULTIMATE_NUMBER           =l_ccr_data.AUSTIN_TETRA_ULTIMATE_NUMBER
,fcv.AUSTIN_TETRA_PCARD_FLAG                =l_ccr_data.AUSTIN_TETRA_PCARD_FLAG
,fcv.DNB_MONITOR_LAST_UPDATED               =l_ccr_data.DNB_MONITOR_LAST_UPDATED
,fcv.DNB_MONITOR_STATUS                     =l_ccr_data.DNB_MONITOR_STATUS
,fcv.DNB_MONITOR_CORP_NAME                  =l_ccr_data.DNB_MONITOR_CORP_NAME
,fcv.DNB_MONITOR_DBA                        =l_ccr_data.DNB_MONITOR_DBA
,fcv.DNB_MONITOR_ST_ADD1                    =l_ccr_data.DNB_MONITOR_ST_ADD1
,fcv.DNB_MONITOR_ST_ADD2                    =l_ccr_data.DNB_MONITOR_ST_ADD2
,fcv.DNB_MONITOR_CITY                       =l_ccr_data.DNB_MONITOR_CITY
,fcv.DNB_MONITOR_POSTAL_CODE                =l_ccr_data.DNB_MONITOR_POSTAL_CODE
,fcv.DNB_MONITOR_COUNTRY_CODE               =l_ccr_data.DNB_MONITOR_COUNTRY_CODE
,fcv.DNB_MONITOR_STATE                      =l_ccr_data.DNB_MONITOR_STATE
,fcv.HQ_PARENT_POC                          =l_ccr_data.HQ_PARENT_POC
,fcv.PAYMENT_TYPE                           =l_ccr_data.PAYMENT_TYPE
,fcv.ANNUAL_RECEIPTS                        =l_ccr_data.ANNUAL_RECEIPTS
,fcv.DOMESTIC_PARENT_POC                    =l_ccr_data.DOMESTIC_PARENT_POC
,fcv.DOMESTIC_PARENT_DUNS                   =l_ccr_data.DOMESTIC_PARENT_DUNS
,fcv.DOMESTIC_PARENT_ADD1                   =l_ccr_data.DOMESTIC_PARENT_ADD1
,fcv.DOMESTIC_PARENT_ADD2                   =l_ccr_data.DOMESTIC_PARENT_ADD2
,fcv.DOMESTIC_PARENT_CITY                   =l_ccr_data.DOMESTIC_PARENT_CITY
,fcv.DOMESTIC_PARENT_POSTAL_CODE            =l_ccr_data.DOMESTIC_PARENT_POSTAL_CODE
,fcv.DOMESTIC_PARENT_COUNTRY                =l_ccr_data.DOMESTIC_PARENT_COUNTRY
,fcv.DOMESTIC_PARENT_STATE                  =l_ccr_data.DOMESTIC_PARENT_STATE
,fcv.DOMESTIC_PARENT_PHONE                  =l_ccr_data.DOMESTIC_PARENT_PHONE
,fcv.GLOBAL_PARENT_POC                      =l_ccr_data.GLOBAL_PARENT_POC
,fcv.GLOBAL_PARENT_DUNS                     =l_ccr_data.GLOBAL_PARENT_DUNS
,fcv.GLOBAL_PARENT_ADD1                     =l_ccr_data.GLOBAL_PARENT_ADD1
,fcv.GLOBAL_PARENT_ADD2                     =l_ccr_data.GLOBAL_PARENT_ADD2
,fcv.GLOBAL_PARENT_CITY                     =l_ccr_data.GLOBAL_PARENT_CITY
,fcv.GLOBAL_PARENT_POSTAL_CODE              =l_ccr_data.GLOBAL_PARENT_POSTAL_CODE
,fcv.GLOBAL_PARENT_COUNTRY                  =l_ccr_data.GLOBAL_PARENT_COUNTRY
,fcv.GLOBAL_PARENT_STATE                    =l_ccr_data.GLOBAL_PARENT_STATE
,fcv.GLOBAL_PARENT_PHONE                    =l_ccr_data.GLOBAL_PARENT_PHONE
         WHERE fcv.duns= l_ccr_data.duns
         AND nvl(fcv.plus_four,-99)= nvl(l_ccr_data.plus_four,-99) ;
        l_errbuf := 'Updating DUNS+4 info - done ';
        FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

           --add into the plus four processed section of the report
           insert_temp_data(1,l_ccr_data.duns||l_ccr_data.plus_four,l_ccr_data.legal_bus_name,l_ccr_data.cage_code,nvl(l_ccr_data.taxpayer_id,l_ccr_data.social_security_number),l_status,null);

     exception
     when no_data_found then
      l_errbuf := 'No data found for duns plus four ';
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

          -- This case DUns+4 doesn ot exist
          l_errbuf := 'DUNS+4 does not exist in FV_CCR_VENDORS';
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

          IF (p_xml_import = 'N' OR p_insert_data = 'Y') THEN -- bug 3931251

          IF (l_ccr_data.extract_code ='3') THEN
             l_errbuf := 'Error - the DUNS+4 does not exist in FV_CCR_VENDORS';
             FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);
          ELSE

                --validate for the renewal date)
                IF (l_ccr_data.renewal_date < trunc(sysdate) ) THEN
                                 l_status:='E';
                        ELSE
                                l_status :='A';
                 END IF; -- end of renewal date val


            --call procedureto insert duns+4 info
            l_errbuf := 'Insert DUNS+4' || l_ccr_data.plus_four;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);
            INSERT INTO FV_CCR_VENDORS (
                    CCR_ID                          ,
                                ENABLED                                         ,
                                CCR_FLAG                        ,
                                CCR_STATUS                      ,
                                DUNS                            ,
                                PLUS_FOUR                       ,
                                CAGE_CODE                       ,
                                EXTRACT_CODE                    ,
                                REGISTRATION_DATE               ,
                                RENEWAL_DATE                    ,
                                LEGAL_BUS_NAME                  ,
                                DBA_NAME                        ,
                                DIVISION_NAME                   ,
                                DIVISION_NUMBER                 ,
                                ST_ADDRESS1                     ,
                                ST_ADDRESS2                     ,
                                CITY                            ,
                                STATE                           ,
                                POSTAL_CODE                     ,
                                COUNTRY                         ,
                                BUSINESS_START_DATE             ,
                                FISCAL_YR_CLOSE_DATE            ,
                                CORP_SECURITY_LEVEL             ,
                                EMP_SECURITY_LEVEL              ,
                                WEB_SITE                        ,
                                CREDIT_CARD_FLAG                        ,
                                CORRESPONDENCE_FLAG                     ,
                                MAIL_POC                                ,
                                MAIL_ADD1                               ,
                                MAIL_ADD2                               ,
                                MAIL_CITY                               ,
                                MAIL_POSTAL_CODE                        ,
                                MAIL_COUNTRY                            ,
                                MAIL_STATE                              ,
                                PREV_BUS_POC                            ,
                                PREV_BUS_ADD1                           ,
                                PREV_BUS_ADD2                           ,
                                PREV_BUS_CITY                           ,
                                PREV_BUS_POSTAL_CODE                    ,
                                PREV_BUS_COUNTRY                        ,
                                PREV_BUS_STATE                          ,
                                PARENT_POC                              ,
                                PARENT_DUNS                             ,
                                PARENT_ADD1                             ,
                                PARENT_ADD2                             ,
                                PARENT_CITY                             ,
                                PARENT_POSTAL_CODE                      ,
                                PARENT_COUNTRY                          ,
                                PARENT_STATE                            ,
                                PARTY_PERF_POC                          ,
                                PARTY_PERF_ADD1                         ,
                                PARTY_PERF_ADD2                         ,
                                PARTY_PERF_CITY                         ,
                                PARTY_PERF_POSTAL_CODE                  ,
                                PARTY_PERF_COUNTRY                      ,
                                PARTY_PERF_STATE                        ,
                                GOV_PARENT_POC                          ,
                                GOV_PARENT_ADD1                         ,
                                GOV_PARENT_ADD2                         ,
                                GOV_PARENT_CITY                         ,
                                GOV_PARENT_POSTAL_CODE                  ,
                                GOV_PARENT_COUNTRY                      ,
                                GOV_PARENT_STATE                        ,
                                GOV_BUS_POC                             ,
                                GOV_BUS_ADD1                            ,
                                GOV_BUS_ADD2                            ,
                                GOV_BUS_CITY                            ,
                                GOV_BUS_POSTAL_CODE                     ,
                                GOV_BUS_COUNTRY                         ,
                                GOV_BUS_STATE                           ,
                                GOV_BUS_US_PHONE                        ,
                                GOV_BUS_US_PHONE_EX                     ,
                                GOV_BUS_NON_US_PHONE                    ,
                                GOV_BUS_FAX                             ,
                                GOV_BUS_EMAIL                           ,
                                ALT_GOV_BUS_POC                         ,
                                ALT_GOV_BUS_ADD1                        ,
                                ALT_GOV_BUS_ADD2                        ,
                                ALT_GOV_BUS_CITY                        ,
                                ALT_GOV_BUS_POSTAL_CODE                 ,
                                ALT_GOV_BUS_COUNTRY                     ,
                                ALT_GOV_BUS_STATE                       ,
                                ALT_GOV_BUS_US_PHONE                    ,
                                ALT_GOV_BUS_US_PHONE_EX                 ,
                                ALT_GOV_BUS_NON_US_PHONE                ,
                                ALT_GOV_BUS_FAX                         ,
                                ALT_GOV_BUS_EMAIL                       ,
                                PAST_PERF_POC                           ,
                                PAST_PERF_ADD1                          ,
                                PAST_PERF_ADD2                          ,
                                PAST_PERF_CITY                          ,
                                PAST_PERF_POSTAL_CODE                   ,
                                PAST_PERF_COUNTRY                       ,
                                PAST_PERF_STATE                         ,
                                PAST_PERF_US_PHONE                      ,
                                PAST_PERF_US_PHONE_EX                   ,
                                PAST_PERF_NON_US_PHONE                  ,
                                PAST_PERF_FAX                           ,
                                PAST_PERF_EMAIL                         ,
                                ALT_PAST_PERF_POC                       ,
                                ALT_PAST_PERF_ADD1                      ,
                                ALT_PAST_PERF_ADD2                      ,
                                ALT_PAST_PERF_CITY                      ,
                                ALT_PAST_PERF_POSTAL_CODE               ,
                                ALT_PAST_PERF_COUNTRY                   ,
                                ALT_PAST_PERF_STATE                     ,
                                ALT_PAST_PERF_US_PHONE                  ,
                                ALT_PAST_PERF_US_PHONE_EX               ,
                                ALT_PAST_PERF_NON_US_PHONE              ,
                                ALT_PAST_PERF_FAX                       ,
                                ALT_PAST_PERF_EMAIL                     ,
                                ELEC_BUS_POC                            ,
                                ELEC_BUS_ADD1                           ,
                                ELEC_BUS_ADD2                           ,
                                ELEC_BUS_CITY                           ,
                                ELEC_BUS_POSTAL_CODE                    ,
                                ELEC_BUS_COUNTRY                        ,
                                ELEC_BUS_STATE                          ,
                                ELEC_BUS_US_PHONE                       ,
                                ELEC_BUS_US_PHONE_EX                    ,
                                ELEC_BUS_NON_US_PHONE                   ,
                                ELEC_BUS_FAX                            ,
                                ELEC_BUS_EMAIL                          ,
                                ALT_ELEC_BUS_POC                        ,
                                ALT_ELEC_BUS_ADD1                       ,
                                ALT_ELEC_BUS_ADD2                       ,
                                ALT_ELEC_BUS_CITY                       ,
                                ALT_ELEC_BUS_POSTAL_CODE                ,
                                ALT_ELEC_BUS_COUNTRY                    ,
                                ALT_ELEC_BUS_STATE                      ,
                                ALT_ELEC_BUS_US_PHONE                   ,
                                ALT_ELEC_BUS_US_PHONE_EX                ,
                                ALT_ELEC_BUS_NON_US_PHONE               ,
                                ALT_ELEC_BUS_FAX                        ,
                                ALT_ELEC_BUS_EMAIL                      ,
                                CERTIFIER_POC                           ,
                                CERTIFIER_US_PHONE                      ,
                                CERTIFIER_US_PHONE_EX                   ,
                                CERTIFIER_NON_US_PHONE                  ,
                                CERTIFIER_FAX                           ,
                                CERTIFIER_EMAIL                         ,
                                ALT_CERTIFIER_POC                       ,
                                ALT_CERTIFIER_US_PHONE                  ,
                                ALT_CERTIFIER_US_PHONE_EX               ,
                                ALT_CERTIFIER_NON_US_PHONE              ,
                                CORP_INFO_POC                           ,
                                CORP_INFO_US_PHONE                      ,
                                CORP_INFO_US_PHONE_EX                   ,
                                CORP_INFO_NON_US_PHONE                  ,
                                CORP_INFO_FAX                           ,
                                CORP_INFO_EMAIL                         ,
                                OWNER_INFO_POC                          ,
                                OWNER_INFO_US_PHONE                     ,
                                OWNER_INFO_US_PHONE_EX                  ,
                                OWNER_INFO_NON_US_PHONE                 ,
                                OWNER_INFO_FAX                          ,
                                OWNER_INFO_EMAIL                        ,
                                EDI                                     ,
                                TAXPAYER_ID                             ,
                                AVG_NUM_EMPLOYEES                       ,
                                ANNUAL_REVENUE                          ,
                                SOCIAL_SECURITY_NUMBER                  ,
                                FINANCIAL_INSTITUTE                     ,
                                BANK_ACCT_NUMBER                        ,
                                ABA_ROUTING                             ,
                                BANK_ACCT_TYPE                          ,
                                LOCKBOX_NUMBER                          ,
                                AUTHORIZATION_DATE                      ,
                                EFT_WAIVER                              ,
                                ACH_US_PHONE                            ,
                                ACH_NON_US_PHONE                        ,
                                ACH_FAX                                 ,
                                ACH_EMAIL                               ,
                                REMIT_POC                               ,
                                REMIT_ADD1                              ,
                                REMIT_ADD2                              ,
                                REMIT_CITY                              ,
                                REMIT_STATE                             ,
                                REMIT_POSTAL_CODE                       ,
                                REMIT_COUNTRY                           ,
                                AR_POC                                  ,
                                AR_US_PHONE                             ,
                                AR_US_PHONE_EX                          ,
                                AR_NON_US_PHONE                         ,
                                AR_FAX                                  ,
                                AR_EMAIL                                ,
                                MPIN                                    ,
                                EDI_COORDINATOR                         ,
                                EDI_US_PHONE                            ,
                                EDI_US_PHONE_EX                         ,
                                EDI_NON_US_PHONE                        ,
                                EDI_FAX                                 ,
                                EDI_EMAIL                               ,
                    LAST_UPDATE_DATE                        ,
                    LAST_UPDATED_BY                         ,
                    last_import_date                        ,
                    ALT_CERTIFIER_FAX                       ,
                    ALT_CERTIFIER_EMAIL                                         ,
                        CREATION_DATE                                                   ,
                        CREATED_BY                                                              ,
                        LAST_UPDATE_LOGIN                    ,
                        STATE_OF_INC,
                        COUNTRY_OF_INC,
                        -- Added for bug 6339382
                        ORGANIZATIONAL_TYPE
			,AUSTIN_TETRA_NUMBER
                        ,AUSTIN_TETRA_PARENT_NUMBER
                        ,AUSTIN_TETRA_ULTIMATE_NUMBER
                        ,AUSTIN_TETRA_PCARD_FLAG
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
            ,HQ_PARENT_POC
            ,PAYMENT_TYPE
            ,ANNUAL_RECEIPTS
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

            )
            SELECT FV_CCR_VENDORS_S.nextval ,'Y','R',l_status,
                                DUNS                            ,
                                PLUS_FOUR                       ,
                                CAGE_CODE                       ,
                                EXTRACT_CODE                            ,
                                REGISTRATION_DATE               ,
                                RENEWAL_DATE                    ,
                                LEGAL_BUS_NAME                  ,
                                DBA_NAME                        ,
                                DIVISION_NAME                   ,
                                DIVISION_NUMBER                 ,
                                ST_ADDRESS1                     ,
                                ST_ADDRESS2                     ,
                                CITY                            ,
                                STATE                           ,
                                POSTAL_CODE                     ,
                                --Bug8335551
                                --COUNTRY                         ,
                                get_territory_code(COUNTRY)     ,
                                BUSINESS_START_DATE             ,
                                FISCAL_YR_CLOSE_DATE            ,
                                CORP_SECURITY_LEVEL             ,
                                EMP_SECURITY_LEVEL              ,
                                WEB_SITE                        ,
                                CREDIT_CARD_FLAG                        ,
                                CORRESPONDENCE_FLAG                     ,
                                MAIL_POC                                ,
                                MAIL_ADD1                               ,
                                MAIL_ADD2                               ,
                                MAIL_CITY                               ,
                                MAIL_POSTAL_CODE                        ,
                                --Bug8335551
                                --MAIL_COUNTRY                            ,
                                get_territory_code(MAIL_COUNTRY)        ,
                                MAIL_STATE                              ,
                                PREV_BUS_POC                            ,
                                PREV_BUS_ADD1                           ,
                                PREV_BUS_ADD2                           ,
                                PREV_BUS_CITY                           ,
                                PREV_BUS_POSTAL_CODE                    ,
                                PREV_BUS_COUNTRY                        ,
                                PREV_BUS_STATE                          ,
                                PARENT_POC                              ,
                                PARENT_DUNS                             ,
                                PARENT_ADD1                             ,
                                PARENT_ADD2                             ,
                                PARENT_CITY                             ,
                                PARENT_POSTAL_CODE                      ,
                                PARENT_COUNTRY                          ,
                                PARENT_STATE                            ,
                                PARTY_PERF_POC                          ,
                                PARTY_PERF_ADD1                         ,
                                PARTY_PERF_ADD2                         ,
                                PARTY_PERF_CITY                         ,
                                PARTY_PERF_POSTAL_CODE                  ,
                                PARTY_PERF_COUNTRY                      ,
                                PARTY_PERF_STATE                        ,
                                GOV_PARENT_POC                          ,
                                GOV_PARENT_ADD1                         ,
                                GOV_PARENT_ADD2                         ,
                                GOV_PARENT_CITY                         ,
                                GOV_PARENT_POSTAL_CODE                  ,
                                GOV_PARENT_COUNTRY                      ,
                                GOV_PARENT_STATE                        ,
                                GOV_BUS_POC                             ,
                                GOV_BUS_ADD1                            ,
                                GOV_BUS_ADD2                            ,
                                GOV_BUS_CITY                            ,
                                GOV_BUS_POSTAL_CODE                     ,
                                GOV_BUS_COUNTRY                         ,
                                GOV_BUS_STATE                           ,
                                GOV_BUS_US_PHONE                        ,
                                GOV_BUS_US_PHONE_EX                     ,
                                GOV_BUS_NON_US_PHONE                    ,
                                GOV_BUS_FAX                             ,
                                GOV_BUS_EMAIL                           ,
                                ALT_GOV_BUS_POC                         ,
                                ALT_GOV_BUS_ADD1                        ,
                                ALT_GOV_BUS_ADD2                        ,
                                ALT_GOV_BUS_CITY                        ,
                                ALT_GOV_BUS_POSTAL_CODE                 ,
                                ALT_GOV_BUS_COUNTRY                     ,
                                ALT_GOV_BUS_STATE                       ,
                                ALT_GOV_BUS_US_PHONE                    ,
                                ALT_GOV_BUS_US_PHONE_EX                 ,
                                ALT_GOV_BUS_NON_US_PHONE                ,
                                ALT_GOV_BUS_FAX                         ,
                                ALT_GOV_BUS_EMAIL                       ,
                                PAST_PERF_POC                           ,
                                PAST_PERF_ADD1                          ,
                                PAST_PERF_ADD2                          ,
                                PAST_PERF_CITY                          ,
                                PAST_PERF_POSTAL_CODE                   ,
                                PAST_PERF_COUNTRY                       ,
                                PAST_PERF_STATE                         ,
                                PAST_PERF_US_PHONE                      ,
                                PAST_PERF_US_PHONE_EX                   ,
                                PAST_PERF_NON_US_PHONE                  ,
                                PAST_PERF_FAX                           ,
                                PAST_PERF_EMAIL                         ,
                                ALT_PAST_PERF_POC                       ,
                                ALT_PAST_PERF_ADD1                      ,
                                ALT_PAST_PERF_ADD2                      ,
                                ALT_PAST_PERF_CITY                      ,
                                ALT_PAST_PERF_POSTAL_CODE               ,
                                ALT_PAST_PERF_COUNTRY                   ,
                                ALT_PAST_PERF_STATE                     ,
                                ALT_PAST_PERF_US_PHONE                  ,
                                ALT_PAST_PERF_US_PHONE_EX               ,
                                ALT_PAST_PERF_NON_US_PHONE              ,
                                ALT_PAST_PERF_FAX                       ,
                                ALT_PAST_PERF_EMAIL                     ,
                                ELEC_BUS_POC                            ,
                                ELEC_BUS_ADD1                           ,
                                ELEC_BUS_ADD2                           ,
                                ELEC_BUS_CITY                           ,
                                ELEC_BUS_POSTAL_CODE                    ,
                                ELEC_BUS_COUNTRY                        ,
                                ELEC_BUS_STATE                          ,
                                ELEC_BUS_US_PHONE                       ,
                                ELEC_BUS_US_PHONE_EX                    ,
                                ELEC_BUS_NON_US_PHONE                   ,
                                ELEC_BUS_FAX                            ,
                                ELEC_BUS_EMAIL                          ,
                                ALT_ELEC_BUS_POC                        ,
                                ALT_ELEC_BUS_ADD1                       ,
                                ALT_ELEC_BUS_ADD2                       ,
                                ALT_ELEC_BUS_CITY                       ,
                                ALT_ELEC_BUS_POSTAL_CODE                ,
                                ALT_ELEC_BUS_COUNTRY                    ,
                                ALT_ELEC_BUS_STATE                      ,
                                ALT_ELEC_BUS_US_PHONE                   ,
                                ALT_ELEC_BUS_US_PHONE_EX                ,
                                ALT_ELEC_BUS_NON_US_PHONE               ,
                                ALT_ELEC_BUS_FAX                        ,
                                ALT_ELEC_BUS_EMAIL                      ,
                                CERTIFIER_POC                           ,
                                CERTIFIER_US_PHONE                      ,
                                CERTIFIER_US_PHONE_EX                   ,
                                CERTIFIER_NON_US_PHONE                  ,
                                CERTIFIER_FAX                           ,
                                CERTIFIER_EMAIL                         ,
                                ALT_CERTIFIER_POC                       ,
                                ALT_CERTIFIER_US_PHONE                  ,
                                ALT_CERTIFIER_US_PHONE_EX               ,
                                ALT_CERTIFIER_NON_US_PHONE              ,
                                CORP_INFO_POC                           ,
                                CORP_INFO_US_PHONE                      ,
                                CORP_INFO_US_PHONE_EX                   ,
                                CORP_INFO_NON_US_PHONE                  ,
                                CORP_INFO_FAX                           ,
                                CORP_INFO_EMAIL                         ,
                                OWNER_INFO_POC                          ,
                                OWNER_INFO_US_PHONE                     ,
                                OWNER_INFO_US_PHONE_EX                  ,
                                OWNER_INFO_NON_US_PHONE                 ,
                                OWNER_INFO_FAX                          ,
                                OWNER_INFO_EMAIL                        ,
                                EDI                                     ,
                                TAXPAYER_ID                             ,
                                AVG_NUM_EMPLOYEES                       ,
                                ANNUAL_REVENUE                          ,
                                SOCIAL_SECURITY_NUMBER                  ,
                                FINANCIAL_INSTITUTE                     ,
                                BANK_ACCT_NUMBER                        ,
                                ABA_ROUTING                             ,
                                BANK_ACCT_TYPE                          ,
                                LOCKBOX_NUMBER                          ,
                                AUTHORIZATION_DATE                      ,
                                EFT_WAIVER                              ,
                                ACH_US_PHONE                            ,
                                ACH_NON_US_PHONE                        ,
                                ACH_FAX                                 ,
                                ACH_EMAIL                               ,
                                REMIT_POC                               ,
                                REMIT_ADD1                              ,
                                REMIT_ADD2                              ,
                                REMIT_CITY                              ,
                                REMIT_STATE                             ,
                                REMIT_POSTAL_CODE                       ,
                                --Bug8335551
                                --REMIT_COUNTRY                           ,
                                get_territory_code(REMIT_COUNTRY)       ,
                                AR_POC                                  ,
                                AR_US_PHONE                             ,
                                AR_US_PHONE_EX                          ,
                                AR_NON_US_PHONE                         ,
                                AR_FAX                                  ,
                                AR_EMAIL                                ,
                                MPIN                                    ,
                                EDI_COORDINATOR                         ,
                                EDI_US_PHONE                            ,
                                EDI_US_PHONE_EX                         ,
                                EDI_NON_US_PHONE                        ,
                                EDI_FAX                                 ,
                                EDI_EMAIL
                    ,sysdate      ,
                    l_user_id,
                    file_date       ,
                    ALT_CERTIFIER_FAX                       ,
                    ALT_CERTIFIER_EMAIL,
                        sysdate,
                    l_user_id,
                        l_user_id ,
                        State_of_inc,
                        COUNTRY_OF_INC,
                        -- Added for bug 6339382
                        l_code(71).code
                                ,AUSTIN_TETRA_NUMBER
                                ,AUSTIN_TETRA_PARENT_NUMBER
                                ,AUSTIN_TETRA_ULTIMATE_NUMBER
                                ,AUSTIN_TETRA_PCARD_FLAG
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
            ,HQ_PARENT_POC
            ,PAYMENT_TYPE
            ,ANNUAL_RECEIPTS
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

            FROM  FV_CCR_PROCESS_GT fcpg
            WHERE fcpg.duns = l_ccr_data.duns
            AND fcpg.extract_code=l_ccr_data.extract_code
            AND fcpg.plus_four = l_ccr_data.plus_four;

          -- add into the dunplus four inserted section of report
          insert_temp_data(2,l_ccr_data.duns||l_ccr_data.plus_four,l_ccr_data.legal_bus_name,l_msg_pay_obj,null,null,null);

          -- call to update business type validation
          END IF; -- end of extractcode as '3'
          END IF;
        when others then
         FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,SQLERRM);
      END; -- end of select for dummy
     ELSE
      -- this is root DUNS record !!!
      BEGIN
      l_errbuf := 'Processing root DUNS -> '||l_ccr_data.duns;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);


      SELECT legal_bus_name into l_lbe_change FROM fv_ccr_vendors fcv
              WHERE fcv.duns = l_ccr_data.duns
                      AND fcv.plus_four is null;

      -- if this select does not return rows ,we need to update DUNS and duns+4 information
      l_errbuf := 'DUNS exists';
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

       --BUG 3839843
       IF (l_lbe_change <> l_ccr_data.legal_bus_name) THEN

           FND_MESSAGE.set_NAME('FV','FV_CCR_LBE_CHANGED');
           message_text := FND_MESSAGE.get;

           l_errbuf :='Legal Bus Name changed from '||l_lbe_change||' -> '||l_ccr_data.legal_bus_name;
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, 'find_code',l_errbuf);
           insert_temp_data(3,null,message_text ,null,l_ccr_data.duns||l_ccr_data.plus_four,null,null);

       END IF;


        --validate for the renewal date)
        IF (l_ccr_data.renewal_date < trunc(sysdate) ) THEN
                                l_status:='E';
        END IF; --end of renewal date

          --call to update the DUNS record
       l_errbuf := 'Updating Root DUNS info '||l_ccr_data.duns;
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

       update fv_ccr_vendors fcv set
         fcv.CCR_FLAG                                   ='R'                                            ,
         fcv.CCR_STATUS                                 =l_status                                       ,
         fcv.DUNS                                       =l_ccr_data.DUNS                                ,
         fcv.PLUS_FOUR                                  =null                                           ,
         fcv.CAGE_CODE                                  =l_ccr_data.CAGE_CODE                           ,
         fcv.EXTRACT_CODE                               =l_ccr_data.EXTRACT_CODE                        ,
         fcv.REGISTRATION_DATE                          =l_ccr_data.REGISTRATION_DATE                   ,
         fcv.RENEWAL_DATE                               =l_ccr_data.RENEWAL_DATE                        ,
         fcv.LEGAL_BUS_NAME                             =l_ccr_data.LEGAL_BUS_NAME                      ,
         fcv.DBA_NAME                                   =l_ccr_data.DBA_NAME                            ,
         fcv.DIVISION_NAME                              =l_ccr_data.DIVISION_NAME                       ,
         fcv.DIVISION_NUMBER                            =l_ccr_data.DIVISION_NUMBER                     ,
         fcv.ST_ADDRESS1                                =l_ccr_data.ST_ADDRESS1                         ,
         fcv.ST_ADDRESS2                                =l_ccr_data.ST_ADDRESS2                         ,
         fcv.CITY                                       =l_ccr_data.CITY                                ,
         fcv.STATE                                      =l_ccr_data.STATE                               ,
         fcv.POSTAL_CODE                                =l_ccr_data.POSTAL_CODE                         ,
         --Bug8335551
         --fcv.COUNTRY                                    =l_ccr_data.COUNTRY                             ,
         fcv.COUNTRY                                    =get_territory_code(l_ccr_data.COUNTRY)         ,
         fcv.BUSINESS_START_DATE                        =l_ccr_data.BUSINESS_START_DATE                 ,
         fcv.FISCAL_YR_CLOSE_DATE                       =l_ccr_data.FISCAL_YR_CLOSE_DATE                ,
         fcv.WEB_SITE                                   =l_ccr_data.WEB_SITE                            ,
         fcv.CREDIT_CARD_FLAG                           =l_ccr_data.CREDIT_CARD_FLAG                            ,
         fcv.MAIL_POC                                   =l_ccr_data.MAIL_POC                                    ,
         fcv.MAIL_ADD1                                  =l_ccr_data.MAIL_ADD1                                   ,
         fcv.MAIL_ADD2                                  =l_ccr_data.MAIL_ADD2                                   ,
         fcv.MAIL_CITY                                  =l_ccr_data.MAIL_CITY                                   ,
         fcv.MAIL_POSTAL_CODE                           =l_ccr_data.MAIL_POSTAL_CODE                            ,
         --Bug8335551
         --fcv.MAIL_COUNTRY                               =l_ccr_data.MAIL_COUNTRY                                ,
         fcv.MAIL_COUNTRY                               =get_territory_code(l_ccr_data.MAIL_COUNTRY)    ,
         fcv.MAIL_STATE                                 =l_ccr_data.MAIL_STATE                                  ,
         fcv.PREV_BUS_POC                               =l_ccr_data.PREV_BUS_POC                                ,
         fcv.PREV_BUS_ADD1                              =l_ccr_data.PREV_BUS_ADD1                               ,
         fcv.PREV_BUS_ADD2                              =l_ccr_data.PREV_BUS_ADD2                               ,
         fcv.PREV_BUS_CITY                              =l_ccr_data.PREV_BUS_CITY                               ,
         fcv.PREV_BUS_POSTAL_CODE                       =l_ccr_data.PREV_BUS_POSTAL_CODE                        ,
         fcv.PREV_BUS_COUNTRY                           =l_ccr_data.PREV_BUS_COUNTRY                            ,
         fcv.PREV_BUS_STATE                             =l_ccr_data.PREV_BUS_STATE                              ,
         fcv.PARENT_POC                                 =l_ccr_data.PARENT_POC                                  ,
         fcv.PARENT_DUNS                                =l_ccr_data.PARENT_DUNS                                 ,
         fcv.PARENT_ADD1                                =l_ccr_data.PARENT_ADD1                                 ,
         fcv.PARENT_ADD2                                =l_ccr_data.PARENT_ADD2                                 ,
         fcv.PARENT_CITY                                =l_ccr_data.PARENT_CITY                                 ,
         fcv.PARENT_POSTAL_CODE                         =l_ccr_data.PARENT_POSTAL_CODE                          ,
         fcv.PARENT_COUNTRY                             =l_ccr_data.PARENT_COUNTRY                              ,
         fcv.PARENT_STATE                               =l_ccr_data.PARENT_STATE                                ,
         fcv.PARTY_PERF_POC                             =l_ccr_data.PARTY_PERF_POC                              ,
         fcv.PARTY_PERF_ADD1                            =l_ccr_data.PARTY_PERF_ADD1                             ,
         fcv.PARTY_PERF_ADD2                            =l_ccr_data.PARTY_PERF_ADD2                             ,
         fcv.PARTY_PERF_CITY                            =l_ccr_data.PARTY_PERF_CITY                             ,
         fcv.PARTY_PERF_POSTAL_CODE                     =l_ccr_data.PARTY_PERF_POSTAL_CODE                      ,
         fcv.PARTY_PERF_COUNTRY                         =l_ccr_data.PARTY_PERF_COUNTRY                          ,
         fcv.PARTY_PERF_STATE                           =l_ccr_data.PARTY_PERF_STATE                            ,
         fcv.GOV_PARENT_POC                             =l_ccr_data.GOV_PARENT_POC                              ,
         fcv.GOV_PARENT_ADD1                            =l_ccr_data.GOV_PARENT_ADD1                             ,
         fcv.GOV_PARENT_ADD2                            =l_ccr_data.GOV_PARENT_ADD2                             ,
         fcv.GOV_PARENT_CITY                            =l_ccr_data.GOV_PARENT_CITY                             ,
         fcv.GOV_PARENT_POSTAL_CODE                     =l_ccr_data.GOV_PARENT_POSTAL_CODE                      ,
         fcv.GOV_PARENT_COUNTRY                         =l_ccr_data.GOV_PARENT_COUNTRY                          ,
         fcv.GOV_PARENT_STATE                           =l_ccr_data.GOV_PARENT_STATE                            ,
         fcv.GOV_BUS_POC                                =l_ccr_data.GOV_BUS_POC                                 ,
         fcv.GOV_BUS_ADD1                               =l_ccr_data.GOV_BUS_ADD1                                ,
         fcv.GOV_BUS_ADD2                               =l_ccr_data.GOV_BUS_ADD2                                ,
         fcv.GOV_BUS_CITY                               =l_ccr_data.GOV_BUS_CITY                                ,
         fcv.GOV_BUS_POSTAL_CODE                        =l_ccr_data.GOV_BUS_POSTAL_CODE                         ,
         fcv.GOV_BUS_COUNTRY                            =l_ccr_data.GOV_BUS_COUNTRY                             ,
         fcv.GOV_BUS_STATE                              =l_ccr_data.GOV_BUS_STATE                               ,
         fcv.GOV_BUS_US_PHONE                           =l_ccr_data.GOV_BUS_US_PHONE                            ,
         fcv.GOV_BUS_US_PHONE_EX                        =l_ccr_data.GOV_BUS_US_PHONE_EX                         ,
         fcv.GOV_BUS_NON_US_PHONE                       =l_ccr_data.GOV_BUS_NON_US_PHONE                        ,
         fcv.GOV_BUS_FAX                                =l_ccr_data.GOV_BUS_FAX                                 ,
         fcv.GOV_BUS_EMAIL                              =l_ccr_data.GOV_BUS_EMAIL                               ,
         fcv.ALT_GOV_BUS_POC                            =l_ccr_data.ALT_GOV_BUS_POC                             ,
         fcv.ALT_GOV_BUS_ADD1                           =l_ccr_data.ALT_GOV_BUS_ADD1                            ,
         fcv.ALT_GOV_BUS_ADD2                           =l_ccr_data.ALT_GOV_BUS_ADD2                            ,
         fcv.ALT_GOV_BUS_CITY                           =l_ccr_data.ALT_GOV_BUS_CITY                            ,
         fcv.ALT_GOV_BUS_POSTAL_CODE                    =l_ccr_data.ALT_GOV_BUS_POSTAL_CODE                     ,
         fcv.ALT_GOV_BUS_COUNTRY                        =l_ccr_data.ALT_GOV_BUS_COUNTRY                         ,
         fcv.ALT_GOV_BUS_STATE                          =l_ccr_data.ALT_GOV_BUS_STATE                           ,
         fcv.ALT_GOV_BUS_US_PHONE                       =l_ccr_data.ALT_GOV_BUS_US_PHONE                        ,
         fcv.ALT_GOV_BUS_US_PHONE_EX                    =l_ccr_data.ALT_GOV_BUS_US_PHONE_EX                     ,
         fcv.ALT_GOV_BUS_NON_US_PHONE                   =l_ccr_data.ALT_GOV_BUS_NON_US_PHONE                    ,
         fcv.ALT_GOV_BUS_FAX                            =l_ccr_data.ALT_GOV_BUS_FAX                             ,
         fcv.ALT_GOV_BUS_EMAIL                          =l_ccr_data.ALT_GOV_BUS_EMAIL                           ,
         fcv.PAST_PERF_POC                              =l_ccr_data.PAST_PERF_POC                               ,
         fcv.PAST_PERF_ADD1                             =l_ccr_data.PAST_PERF_ADD1                              ,
         fcv.PAST_PERF_ADD2                             =l_ccr_data.PAST_PERF_ADD2                              ,
         fcv.PAST_PERF_CITY                             =l_ccr_data.PAST_PERF_CITY                              ,
         fcv.PAST_PERF_POSTAL_CODE                      =l_ccr_data.PAST_PERF_POSTAL_CODE                       ,
         fcv.PAST_PERF_COUNTRY                          =l_ccr_data.PAST_PERF_COUNTRY                           ,
         fcv.PAST_PERF_STATE                            =l_ccr_data.PAST_PERF_STATE                             ,
         fcv.PAST_PERF_US_PHONE                         =l_ccr_data.PAST_PERF_US_PHONE                          ,
         fcv.PAST_PERF_US_PHONE_EX                      =l_ccr_data.PAST_PERF_US_PHONE_EX                       ,
         fcv.PAST_PERF_NON_US_PHONE                     =l_ccr_data.PAST_PERF_NON_US_PHONE                      ,
         fcv.PAST_PERF_FAX                              =l_ccr_data.PAST_PERF_FAX                               ,
         fcv.PAST_PERF_EMAIL                            =l_ccr_data.PAST_PERF_EMAIL                             ,
         fcv.ALT_PAST_PERF_POC                          =l_ccr_data.ALT_PAST_PERF_POC                           ,
         fcv.ALT_PAST_PERF_ADD1                         =l_ccr_data.ALT_PAST_PERF_ADD1                          ,
         fcv.ALT_PAST_PERF_ADD2                         =l_ccr_data.ALT_PAST_PERF_ADD2                          ,
         fcv.ALT_PAST_PERF_CITY                         =l_ccr_data.ALT_PAST_PERF_CITY                          ,
         fcv.ALT_PAST_PERF_POSTAL_CODE                  =l_ccr_data.ALT_PAST_PERF_POSTAL_CODE                   ,
         fcv.ALT_PAST_PERF_COUNTRY                      =l_ccr_data.ALT_PAST_PERF_COUNTRY                       ,
         fcv.ALT_PAST_PERF_STATE                        =l_ccr_data.ALT_PAST_PERF_STATE                         ,
         fcv.ALT_PAST_PERF_US_PHONE                     =l_ccr_data.ALT_PAST_PERF_US_PHONE                      ,
         fcv.ALT_PAST_PERF_US_PHONE_EX                  =l_ccr_data.ALT_PAST_PERF_US_PHONE_EX                   ,
         fcv.ALT_PAST_PERF_NON_US_PHONE                 =l_ccr_data.ALT_PAST_PERF_NON_US_PHONE                  ,
         fcv.ALT_PAST_PERF_FAX                          =l_ccr_data.ALT_PAST_PERF_FAX                           ,
         fcv.ALT_PAST_PERF_EMAIL                        =l_ccr_data.ALT_PAST_PERF_EMAIL                         ,
         fcv.ELEC_BUS_POC                               =l_ccr_data.ELEC_BUS_POC                                ,
         fcv.ELEC_BUS_ADD1                              =l_ccr_data.ELEC_BUS_ADD1                               ,
         fcv.ELEC_BUS_ADD2                              =l_ccr_data.ELEC_BUS_ADD2                               ,
         fcv.ELEC_BUS_CITY                              =l_ccr_data.ELEC_BUS_CITY                               ,
         fcv.ELEC_BUS_POSTAL_CODE                       =l_ccr_data.ELEC_BUS_POSTAL_CODE                        ,
         fcv.ELEC_BUS_COUNTRY                           =l_ccr_data.ELEC_BUS_COUNTRY                            ,
         fcv.ELEC_BUS_STATE                             =l_ccr_data.ELEC_BUS_STATE                              ,
         fcv.ELEC_BUS_US_PHONE                          =l_ccr_data.ELEC_BUS_US_PHONE                           ,
         fcv.ELEC_BUS_US_PHONE_EX                       =l_ccr_data.ELEC_BUS_US_PHONE_EX                        ,
         fcv.ELEC_BUS_NON_US_PHONE                      =l_ccr_data.ELEC_BUS_NON_US_PHONE                       ,
         fcv.ELEC_BUS_FAX                               =l_ccr_data.ELEC_BUS_FAX                                ,
         fcv.ELEC_BUS_EMAIL                             =l_ccr_data.ELEC_BUS_EMAIL                              ,
         fcv.ALT_ELEC_BUS_POC                           =l_ccr_data.ALT_ELEC_BUS_POC                            ,
         fcv.ALT_ELEC_BUS_ADD1                          =l_ccr_data.ALT_ELEC_BUS_ADD1                           ,
         fcv.ALT_ELEC_BUS_ADD2                          =l_ccr_data.ALT_ELEC_BUS_ADD2                           ,
         fcv.ALT_ELEC_BUS_CITY                          =l_ccr_data.ALT_ELEC_BUS_CITY                           ,
         fcv.ALT_ELEC_BUS_POSTAL_CODE                   =l_ccr_data.ALT_ELEC_BUS_POSTAL_CODE                    ,
         fcv.ALT_ELEC_BUS_COUNTRY                       =l_ccr_data.ALT_ELEC_BUS_COUNTRY                        ,
         fcv.ALT_ELEC_BUS_STATE                         =l_ccr_data.ALT_ELEC_BUS_STATE                          ,
         fcv.ALT_ELEC_BUS_US_PHONE                      =l_ccr_data.ALT_ELEC_BUS_US_PHONE                       ,
         fcv.ALT_ELEC_BUS_US_PHONE_EX                   =l_ccr_data.ALT_ELEC_BUS_US_PHONE_EX                    ,
         fcv.ALT_ELEC_BUS_NON_US_PHONE                  =l_ccr_data.ALT_ELEC_BUS_NON_US_PHONE                   ,
         fcv.ALT_ELEC_BUS_FAX                           =l_ccr_data.ALT_ELEC_BUS_FAX                            ,
         fcv.ALT_ELEC_BUS_EMAIL                         =l_ccr_data.ALT_ELEC_BUS_EMAIL                          ,
         fcv.CERTIFIER_POC                              =l_ccr_data.CERTIFIER_POC                               ,
         fcv.CERTIFIER_US_PHONE                         =l_ccr_data.CERTIFIER_US_PHONE                          ,
         fcv.CERTIFIER_US_PHONE_EX                      =l_ccr_data.CERTIFIER_US_PHONE_EX                       ,
         fcv.CERTIFIER_NON_US_PHONE                     =l_ccr_data.CERTIFIER_NON_US_PHONE                      ,
         fcv.CERTIFIER_FAX                              =l_ccr_data.CERTIFIER_FAX                               ,
         fcv.CERTIFIER_EMAIL                            =l_ccr_data.CERTIFIER_EMAIL                             ,
         fcv.ALT_CERTIFIER_POC                          =l_ccr_data.ALT_CERTIFIER_POC                           ,
         fcv.ALT_CERTIFIER_US_PHONE                     =l_ccr_data.ALT_CERTIFIER_US_PHONE                      ,
         fcv.ALT_CERTIFIER_US_PHONE_EX                  =l_ccr_data.ALT_CERTIFIER_US_PHONE_EX                   ,
         fcv.ALT_CERTIFIER_NON_US_PHONE                 =l_ccr_data.ALT_CERTIFIER_NON_US_PHONE                  ,
         fcv.CORP_INFO_POC                              =l_ccr_data.CORP_INFO_POC                               ,
         fcv.CORP_INFO_US_PHONE                         =l_ccr_data.CORP_INFO_US_PHONE                          ,
         fcv.CORP_INFO_US_PHONE_EX                      =l_ccr_data.CORP_INFO_US_PHONE_EX                       ,
         fcv.CORP_INFO_NON_US_PHONE                     =l_ccr_data.CORP_INFO_NON_US_PHONE                      ,
         fcv.CORP_INFO_FAX                              =l_ccr_data.CORP_INFO_FAX                               ,
         fcv.CORP_INFO_EMAIL                            =l_ccr_data.CORP_INFO_EMAIL                             ,
         fcv.OWNER_INFO_POC                             =l_ccr_data.OWNER_INFO_POC                              ,
         fcv.OWNER_INFO_US_PHONE                        =l_ccr_data.OWNER_INFO_US_PHONE                         ,
         fcv.OWNER_INFO_US_PHONE_EX                     =l_ccr_data.OWNER_INFO_US_PHONE_EX                      ,
         fcv.OWNER_INFO_NON_US_PHONE                    =l_ccr_data.OWNER_INFO_NON_US_PHONE                     ,
         fcv.OWNER_INFO_FAX                             =l_ccr_data.OWNER_INFO_FAX                              ,
         fcv.OWNER_INFO_EMAIL                           =l_ccr_data.OWNER_INFO_EMAIL                            ,
         fcv.EDI                                        =l_ccr_data.EDI                                         ,
         fcv.TAXPAYER_ID                                =l_ccr_data.TAXPAYER_ID                                 ,
         fcv.AVG_NUM_EMPLOYEES                          =l_ccr_data.AVG_NUM_EMPLOYEES                           ,
         fcv.ANNUAL_REVENUE                             =l_ccr_data.ANNUAL_REVENUE                              ,
         fcv.SOCIAL_SECURITY_NUMBER                     =l_ccr_data.SOCIAL_SECURITY_NUMBER                      ,
         fcv.FINANCIAL_INSTITUTE                        =l_ccr_data.FINANCIAL_INSTITUTE                         ,
         fcv.BANK_ACCT_NUMBER                           =l_ccr_data.BANK_ACCT_NUMBER                            ,
         fcv.ABA_ROUTING                                =l_ccr_data.ABA_ROUTING                                 ,
         fcv.BANK_ACCT_TYPE                             =l_ccr_data.BANK_ACCT_TYPE                              ,
         fcv.LOCKBOX_NUMBER                             =l_ccr_data.LOCKBOX_NUMBER                              ,
         fcv.AUTHORIZATION_DATE                         =l_ccr_data.AUTHORIZATION_DATE                          ,
         fcv.EFT_WAIVER                                 =l_ccr_data.EFT_WAIVER                                  ,
         fcv.ACH_US_PHONE                               =l_ccr_data.ACH_US_PHONE                                ,
         fcv.ACH_NON_US_PHONE                           =l_ccr_data.ACH_NON_US_PHONE                            ,
         fcv.ACH_FAX                                    =l_ccr_data.ACH_FAX                                     ,
         fcv.ACH_EMAIL                                  =l_ccr_data.ACH_EMAIL                                   ,
         fcv.REMIT_POC                                  =l_ccr_data.REMIT_POC                                   ,
         fcv.REMIT_ADD1                                 =l_ccr_data.REMIT_ADD1                                  ,
         fcv.REMIT_ADD2                                 =l_ccr_data.REMIT_ADD2                                  ,
         fcv.REMIT_CITY                                 =l_ccr_data.REMIT_CITY                                  ,
         fcv.REMIT_STATE                                =l_ccr_data.REMIT_STATE                                 ,
         fcv.REMIT_POSTAL_CODE                          =l_ccr_data.REMIT_POSTAL_CODE                           ,
         --Bug8335551
         --fcv.REMIT_COUNTRY                              =l_ccr_data.REMIT_COUNTRY                               ,
         fcv.REMIT_COUNTRY                              =get_territory_code(l_ccr_data.REMIT_COUNTRY)     ,
         fcv.AR_POC                                     =l_ccr_data.AR_POC                                      ,
         fcv.AR_US_PHONE                                =l_ccr_data.AR_US_PHONE                                 ,
         fcv.AR_US_PHONE_EX                             =l_ccr_data.AR_US_PHONE_EX                              ,
         fcv.AR_NON_US_PHONE                            =l_ccr_data.AR_NON_US_PHONE                             ,
         fcv.AR_FAX                                     =l_ccr_data.AR_FAX                                      ,
         fcv.AR_EMAIL                                   =l_ccr_data.AR_EMAIL                                    ,
         fcv.MPIN                                       =l_ccr_data.MPIN                                        ,
         fcv.EDI_COORDINATOR                            =l_ccr_data.EDI_COORDINATOR                             ,
         fcv.EDI_US_PHONE                               =l_ccr_data.EDI_US_PHONE                                ,
         fcv.EDI_US_PHONE_EX                            =l_ccr_data.EDI_US_PHONE_EX                             ,
         fcv.EDI_NON_US_PHONE                           =l_ccr_data.EDI_NON_US_PHONE                            ,
         fcv.EDI_FAX                                    =l_ccr_data.EDI_FAX                                     ,
         fcv.EDI_EMAIL                                  =l_ccr_data.EDI_EMAIL                                   ,
         fcv.last_update_date                           =sysdate                               ,
         fcv.last_updated_by                            =l_user_id                                          ,
         fcv.organizational_type                        =l_code(71).code  ,
         fcv.correspondence_flag                        =l_code(72).code    ,
         fcv.corp_security_level                        =l_code(73).code    ,
         fcv.emp_security_level                         =l_code(74).code    ,
         fcv.last_import_date                           =l_ccr_data.file_date   ,
         fcv.STATE_OF_INC                               =l_ccr_data.state_of_inc                                    ,
         fcv.COUNTRY_OF_INC                             =l_ccr_data.country_of_inc                                  ,
         fcv.alt_certifier_email                        =l_ccr_data.alt_certifier_email,
         fcv.alt_certifier_fax                          =l_ccr_data.alt_certifier_fax
           ,fcv.AUSTIN_TETRA_NUMBER                    =l_ccr_data.AUSTIN_TETRA_NUMBER
,fcv.AUSTIN_TETRA_PARENT_NUMBER             =l_ccr_data.AUSTIN_TETRA_PARENT_NUMBER
,fcv.AUSTIN_TETRA_ULTIMATE_NUMBER           =l_ccr_data.AUSTIN_TETRA_ULTIMATE_NUMBER
,fcv.AUSTIN_TETRA_PCARD_FLAG                =l_ccr_data.AUSTIN_TETRA_PCARD_FLAG
,fcv.DNB_MONITOR_LAST_UPDATED               =l_ccr_data.DNB_MONITOR_LAST_UPDATED
,fcv.DNB_MONITOR_STATUS                     =l_ccr_data.DNB_MONITOR_STATUS
,fcv.DNB_MONITOR_CORP_NAME                  =l_ccr_data.DNB_MONITOR_CORP_NAME
,fcv.DNB_MONITOR_DBA                        =l_ccr_data.DNB_MONITOR_DBA
,fcv.DNB_MONITOR_ST_ADD1                    =l_ccr_data.DNB_MONITOR_ST_ADD1
,fcv.DNB_MONITOR_ST_ADD2                    =l_ccr_data.DNB_MONITOR_ST_ADD2
,fcv.DNB_MONITOR_CITY                       =l_ccr_data.DNB_MONITOR_CITY
,fcv.DNB_MONITOR_POSTAL_CODE                =l_ccr_data.DNB_MONITOR_POSTAL_CODE
,fcv.DNB_MONITOR_COUNTRY_CODE               =l_ccr_data.DNB_MONITOR_COUNTRY_CODE
,fcv.DNB_MONITOR_STATE                      =l_ccr_data.DNB_MONITOR_STATE
,fcv.HQ_PARENT_POC                          =l_ccr_data.HQ_PARENT_POC
,fcv.PAYMENT_TYPE                           =l_ccr_data.PAYMENT_TYPE
,fcv.ANNUAL_RECEIPTS                        =l_ccr_data.ANNUAL_RECEIPTS
,fcv.DOMESTIC_PARENT_POC                    =l_ccr_data.DOMESTIC_PARENT_POC
,fcv.DOMESTIC_PARENT_DUNS                   =l_ccr_data.DOMESTIC_PARENT_DUNS
,fcv.DOMESTIC_PARENT_ADD1                   =l_ccr_data.DOMESTIC_PARENT_ADD1
,fcv.DOMESTIC_PARENT_ADD2                   =l_ccr_data.DOMESTIC_PARENT_ADD2
,fcv.DOMESTIC_PARENT_CITY                   =l_ccr_data.DOMESTIC_PARENT_CITY
,fcv.DOMESTIC_PARENT_POSTAL_CODE            =l_ccr_data.DOMESTIC_PARENT_POSTAL_CODE
,fcv.DOMESTIC_PARENT_COUNTRY                =l_ccr_data.DOMESTIC_PARENT_COUNTRY
,fcv.DOMESTIC_PARENT_STATE                  =l_ccr_data.DOMESTIC_PARENT_STATE
,fcv.DOMESTIC_PARENT_PHONE                  =l_ccr_data.DOMESTIC_PARENT_PHONE
,fcv.GLOBAL_PARENT_POC                      =l_ccr_data.GLOBAL_PARENT_POC
,fcv.GLOBAL_PARENT_DUNS                     =l_ccr_data.GLOBAL_PARENT_DUNS
,fcv.GLOBAL_PARENT_ADD1                     =l_ccr_data.GLOBAL_PARENT_ADD1
,fcv.GLOBAL_PARENT_ADD2                     =l_ccr_data.GLOBAL_PARENT_ADD2
,fcv.GLOBAL_PARENT_CITY                     =l_ccr_data.GLOBAL_PARENT_CITY
,fcv.GLOBAL_PARENT_POSTAL_CODE              =l_ccr_data.GLOBAL_PARENT_POSTAL_CODE
,fcv.GLOBAL_PARENT_COUNTRY                  =l_ccr_data.GLOBAL_PARENT_COUNTRY
,fcv.GLOBAL_PARENT_STATE                    =l_ccr_data.GLOBAL_PARENT_STATE
,fcv.GLOBAL_PARENT_PHONE                    =l_ccr_data.GLOBAL_PARENT_PHONE

         WHERE fcv.duns= l_ccr_data.duns
         and (fcv.plus_four is null
         and l_ccr_data.plus_four is null);

         --add into the duns processed section
         insert_temp_data(1,l_ccr_data.duns||l_ccr_data.plus_four,l_ccr_data.legal_bus_name,l_ccr_data.cage_code,nvl(l_ccr_data.taxpayer_id,l_ccr_data.social_security_number),l_status,null);

       l_errbuf := 'Updating Root DUNS info '||l_ccr_data.duns || 'done';
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);
    exception
    when NO_data_found THEN
      IF (p_xml_import  ='N' or  p_insert_data='Y') THEN
      l_errbuf := 'exception no data found for duns ';
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

          -- This case DUns doesn ot exist
          l_errbuf := 'DUNS does not exist in FV_CCR_VENDORS';
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

          IF (l_ccr_data.extract_code ='3') THEN
             l_errbuf := 'Error - the DUNS does not exist in FV_CCR_VENDORS';
             FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);
          ELSE

                --validate for the renewal date)
                IF (l_ccr_data.renewal_date < trunc(sysdate) ) THEN
                                 l_status:='E';
                        ELSE
                                l_status :='A';
                END IF; -- end of renewal date val

            --call procedureto insert duns info
            l_errbuf := 'Insert DUNS' || l_ccr_data.duns;
            FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);
            INSERT INTO FV_CCR_VENDORS (
                        CCR_ID                          ,
                                ENABLED                                                 ,
                        CCR_FLAG                        ,
                                CCR_STATUS                      ,
                                DUNS                            ,
                                PLUS_FOUR                       ,
                                CAGE_CODE                       ,
                                EXTRACT_CODE                    ,
                                REGISTRATION_DATE               ,
                                RENEWAL_DATE                    ,
                                LEGAL_BUS_NAME                  ,
                                DBA_NAME                        ,
                                DIVISION_NAME                   ,
                                DIVISION_NUMBER                 ,
                                ST_ADDRESS1                     ,
                                ST_ADDRESS2                     ,
                                CITY                            ,
                                STATE                           ,
                                POSTAL_CODE                     ,
                                COUNTRY                         ,
                                BUSINESS_START_DATE             ,
                                FISCAL_YR_CLOSE_DATE            ,
                                CORP_SECURITY_LEVEL             ,
                                EMP_SECURITY_LEVEL              ,
                                WEB_SITE                        ,
                                CREDIT_CARD_FLAG                        ,
                                CORRESPONDENCE_FLAG                     ,
                                MAIL_POC                                ,
                                MAIL_ADD1                               ,
                                MAIL_ADD2                               ,
                                MAIL_CITY                               ,
                                MAIL_POSTAL_CODE                        ,
                                MAIL_COUNTRY                            ,
                                MAIL_STATE                              ,
                                PREV_BUS_POC                            ,
                                PREV_BUS_ADD1                           ,
                                PREV_BUS_ADD2                           ,
                                PREV_BUS_CITY                           ,
                                PREV_BUS_POSTAL_CODE                    ,
                                PREV_BUS_COUNTRY                        ,
                                PREV_BUS_STATE                          ,
                                PARENT_POC                              ,
                                PARENT_DUNS                             ,
                                PARENT_ADD1                             ,
                                PARENT_ADD2                             ,
                                PARENT_CITY                             ,
                                PARENT_POSTAL_CODE                      ,
                                PARENT_COUNTRY                          ,
                                PARENT_STATE                            ,
                                PARTY_PERF_POC                          ,
                                PARTY_PERF_ADD1                         ,
                                PARTY_PERF_ADD2                         ,
                                PARTY_PERF_CITY                         ,
                                PARTY_PERF_POSTAL_CODE                  ,
                                PARTY_PERF_COUNTRY                      ,
                                PARTY_PERF_STATE                        ,
                                GOV_PARENT_POC                          ,
                                GOV_PARENT_ADD1                         ,
                                GOV_PARENT_ADD2                         ,
                                GOV_PARENT_CITY                         ,
                                GOV_PARENT_POSTAL_CODE                  ,
                                GOV_PARENT_COUNTRY                      ,
                                GOV_PARENT_STATE                        ,
                                GOV_BUS_POC                             ,
                                GOV_BUS_ADD1                            ,
                                GOV_BUS_ADD2                            ,
                                GOV_BUS_CITY                            ,
                                GOV_BUS_POSTAL_CODE                     ,
                                GOV_BUS_COUNTRY                         ,
                                GOV_BUS_STATE                           ,
                                GOV_BUS_US_PHONE                        ,
                                GOV_BUS_US_PHONE_EX                     ,
                                GOV_BUS_NON_US_PHONE                    ,
                                GOV_BUS_FAX                             ,
                                GOV_BUS_EMAIL                           ,
                                ALT_GOV_BUS_POC                         ,
                                ALT_GOV_BUS_ADD1                        ,
                                ALT_GOV_BUS_ADD2                        ,
                                ALT_GOV_BUS_CITY                        ,
                                ALT_GOV_BUS_POSTAL_CODE                 ,
                                ALT_GOV_BUS_COUNTRY                     ,
                                ALT_GOV_BUS_STATE                       ,
                                ALT_GOV_BUS_US_PHONE                    ,
                                ALT_GOV_BUS_US_PHONE_EX                 ,
                                ALT_GOV_BUS_NON_US_PHONE                ,
                                ALT_GOV_BUS_FAX                         ,
                                ALT_GOV_BUS_EMAIL                       ,
                                PAST_PERF_POC                           ,
                                PAST_PERF_ADD1                          ,
                                PAST_PERF_ADD2                          ,
                                PAST_PERF_CITY                          ,
                                PAST_PERF_POSTAL_CODE                   ,
                                PAST_PERF_COUNTRY                       ,
                                PAST_PERF_STATE                         ,
                                PAST_PERF_US_PHONE                      ,
                                PAST_PERF_US_PHONE_EX                   ,
                                PAST_PERF_NON_US_PHONE                  ,
                                PAST_PERF_FAX                           ,
                                PAST_PERF_EMAIL                         ,
                                ALT_PAST_PERF_POC                       ,
                                ALT_PAST_PERF_ADD1                      ,
                                ALT_PAST_PERF_ADD2                      ,
                                ALT_PAST_PERF_CITY                      ,
                                ALT_PAST_PERF_POSTAL_CODE               ,
                                ALT_PAST_PERF_COUNTRY                   ,
                                ALT_PAST_PERF_STATE                     ,
                                ALT_PAST_PERF_US_PHONE                  ,
                                ALT_PAST_PERF_US_PHONE_EX               ,
                                ALT_PAST_PERF_NON_US_PHONE              ,
                                ALT_PAST_PERF_FAX                       ,
                                ALT_PAST_PERF_EMAIL                     ,
                                ELEC_BUS_POC                            ,
                                ELEC_BUS_ADD1                           ,
                                ELEC_BUS_ADD2                           ,
                                ELEC_BUS_CITY                           ,
                                ELEC_BUS_POSTAL_CODE                    ,
                                ELEC_BUS_COUNTRY                        ,
                                ELEC_BUS_STATE                          ,
                                ELEC_BUS_US_PHONE                       ,
                                ELEC_BUS_US_PHONE_EX                    ,
                                ELEC_BUS_NON_US_PHONE                   ,
                                ELEC_BUS_FAX                            ,
                                ELEC_BUS_EMAIL                          ,
                                ALT_ELEC_BUS_POC                        ,
                                ALT_ELEC_BUS_ADD1                       ,
                                ALT_ELEC_BUS_ADD2                       ,
                                ALT_ELEC_BUS_CITY                       ,
                                ALT_ELEC_BUS_POSTAL_CODE                ,
                                ALT_ELEC_BUS_COUNTRY                    ,
                                ALT_ELEC_BUS_STATE                      ,
                                ALT_ELEC_BUS_US_PHONE                   ,
                                ALT_ELEC_BUS_US_PHONE_EX                ,
                                ALT_ELEC_BUS_NON_US_PHONE               ,
                                ALT_ELEC_BUS_FAX                        ,
                                ALT_ELEC_BUS_EMAIL                      ,
                                CERTIFIER_POC                           ,
                                CERTIFIER_US_PHONE                      ,
                                CERTIFIER_US_PHONE_EX                   ,
                                CERTIFIER_NON_US_PHONE                  ,
                                CERTIFIER_FAX                           ,
                                CERTIFIER_EMAIL                         ,
                                ALT_CERTIFIER_POC                       ,
                                ALT_CERTIFIER_US_PHONE                  ,
                                ALT_CERTIFIER_US_PHONE_EX               ,
                                ALT_CERTIFIER_NON_US_PHONE              ,
                                CORP_INFO_POC                           ,
                                CORP_INFO_US_PHONE                      ,
                                CORP_INFO_US_PHONE_EX                   ,
                                CORP_INFO_NON_US_PHONE                  ,
                                CORP_INFO_FAX                           ,
                                CORP_INFO_EMAIL                         ,
                                OWNER_INFO_POC                          ,
                                OWNER_INFO_US_PHONE                     ,
                                OWNER_INFO_US_PHONE_EX                  ,
                                OWNER_INFO_NON_US_PHONE                 ,
                                OWNER_INFO_FAX                          ,
                                OWNER_INFO_EMAIL                        ,
                                EDI                                     ,
                                TAXPAYER_ID                             ,
                                AVG_NUM_EMPLOYEES                       ,
                                ANNUAL_REVENUE                          ,
                                SOCIAL_SECURITY_NUMBER                  ,
                                FINANCIAL_INSTITUTE                     ,
                                BANK_ACCT_NUMBER                        ,
                                ABA_ROUTING                             ,
                                BANK_ACCT_TYPE                          ,
                                LOCKBOX_NUMBER                          ,
                                AUTHORIZATION_DATE                      ,
                                EFT_WAIVER                              ,
                                ACH_US_PHONE                            ,
                                ACH_NON_US_PHONE                        ,
                                ACH_FAX                                 ,
                                ACH_EMAIL                               ,
                                REMIT_POC                               ,
                                REMIT_ADD1                              ,
                                REMIT_ADD2                              ,
                                REMIT_CITY                              ,
                                REMIT_STATE                             ,
                                REMIT_POSTAL_CODE                       ,
                                REMIT_COUNTRY                           ,
                                AR_POC                                  ,
                                AR_US_PHONE                             ,
                                AR_US_PHONE_EX                          ,
                                AR_NON_US_PHONE                         ,
                                AR_FAX                                  ,
                                AR_EMAIL                                ,
                                MPIN                                    ,
                                EDI_COORDINATOR                         ,
                                EDI_US_PHONE                            ,
                                EDI_US_PHONE_EX                         ,
                                EDI_NON_US_PHONE                        ,
                                EDI_FAX                                 ,
                                EDI_EMAIL                               ,
                    LAST_UPDATE_DATE                        ,
                    LAST_UPDATED_BY                         ,
                    last_import_date                        ,
                    ALT_CERTIFIER_FAX                       ,
                    ALT_CERTIFIER_EMAIL,
                        CREATION_DATE                                                   ,
                        CREATED_BY                                                              ,
                        LAST_UPDATE_LOGIN                               ,
                        state_of_inc                                ,
                        COUNTRY_OF_INC,
                        -- Added for bug 6339382
                        ORGANIZATIONAL_TYPE                        ,AUSTIN_TETRA_NUMBER
                        ,AUSTIN_TETRA_PARENT_NUMBER
                        ,AUSTIN_TETRA_ULTIMATE_NUMBER
                        ,AUSTIN_TETRA_PCARD_FLAG
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
            ,HQ_PARENT_POC
            ,PAYMENT_TYPE
            ,ANNUAL_RECEIPTS
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
            )
            SELECT FV_CCR_VENDORS_S.nextval ,'Y','R',l_status,
                                DUNS                            ,
                                PLUS_FOUR                       ,
                                CAGE_CODE                       ,
                                EXTRACT_CODE                            ,
                                REGISTRATION_DATE               ,
                                RENEWAL_DATE                    ,
                                LEGAL_BUS_NAME                  ,
                                DBA_NAME                        ,
                                DIVISION_NAME                   ,
                                DIVISION_NUMBER                 ,
                                ST_ADDRESS1                     ,
                                ST_ADDRESS2                     ,
                                CITY                            ,
                                STATE                           ,
                                POSTAL_CODE                     ,
                                --Bug8335551
                                --COUNTRY                         ,
                                get_territory_code(COUNTRY)     ,
                                BUSINESS_START_DATE             ,
                                FISCAL_YR_CLOSE_DATE            ,
                                CORP_SECURITY_LEVEL             ,
                                EMP_SECURITY_LEVEL              ,
                                WEB_SITE                        ,
                                CREDIT_CARD_FLAG                        ,
                                CORRESPONDENCE_FLAG                     ,
                                MAIL_POC                                ,
                                MAIL_ADD1                               ,
                                MAIL_ADD2                               ,
                                MAIL_CITY                               ,
                                MAIL_POSTAL_CODE                        ,
                                --Bug8335551
                                --MAIL_COUNTRY                            ,
                                get_territory_code(MAIL_COUNTRY)        ,
                                MAIL_STATE                              ,
                                PREV_BUS_POC                            ,
                                PREV_BUS_ADD1                           ,
                                PREV_BUS_ADD2                           ,
                                PREV_BUS_CITY                           ,
                                PREV_BUS_POSTAL_CODE                    ,
                                PREV_BUS_COUNTRY                        ,
                                PREV_BUS_STATE                          ,
                                PARENT_POC                              ,
                                PARENT_DUNS                             ,
                                PARENT_ADD1                             ,
                                PARENT_ADD2                             ,
                                PARENT_CITY                             ,
                                PARENT_POSTAL_CODE                      ,
                                PARENT_COUNTRY                          ,
                                PARENT_STATE                            ,
                                PARTY_PERF_POC                          ,
                                PARTY_PERF_ADD1                         ,
                                PARTY_PERF_ADD2                         ,
                                PARTY_PERF_CITY                         ,
                                PARTY_PERF_POSTAL_CODE                  ,
                                PARTY_PERF_COUNTRY                      ,
                                PARTY_PERF_STATE                        ,
                                GOV_PARENT_POC                          ,
                                GOV_PARENT_ADD1                         ,
                                GOV_PARENT_ADD2                         ,
                                GOV_PARENT_CITY                         ,
                                GOV_PARENT_POSTAL_CODE                  ,
                                GOV_PARENT_COUNTRY                      ,
                                GOV_PARENT_STATE                        ,
                                GOV_BUS_POC                             ,
                                GOV_BUS_ADD1                            ,
                                GOV_BUS_ADD2                            ,
                                GOV_BUS_CITY                            ,
                                GOV_BUS_POSTAL_CODE                     ,
                                GOV_BUS_COUNTRY                         ,
                                GOV_BUS_STATE                           ,
                                GOV_BUS_US_PHONE                        ,
                                GOV_BUS_US_PHONE_EX                     ,
                                GOV_BUS_NON_US_PHONE                    ,
                                GOV_BUS_FAX                             ,
                                GOV_BUS_EMAIL                           ,
                                ALT_GOV_BUS_POC                         ,
                                ALT_GOV_BUS_ADD1                        ,
                                ALT_GOV_BUS_ADD2                        ,
                                ALT_GOV_BUS_CITY                        ,
                                ALT_GOV_BUS_POSTAL_CODE                 ,
                                ALT_GOV_BUS_COUNTRY                     ,
                                ALT_GOV_BUS_STATE                       ,
                                ALT_GOV_BUS_US_PHONE                    ,
                                ALT_GOV_BUS_US_PHONE_EX                 ,
                                ALT_GOV_BUS_NON_US_PHONE                ,
                                ALT_GOV_BUS_FAX                         ,
                                ALT_GOV_BUS_EMAIL                       ,
                                PAST_PERF_POC                           ,
                                PAST_PERF_ADD1                          ,
                                PAST_PERF_ADD2                          ,
                                PAST_PERF_CITY                          ,
                                PAST_PERF_POSTAL_CODE                   ,
                                PAST_PERF_COUNTRY                       ,
                                PAST_PERF_STATE                         ,
                                PAST_PERF_US_PHONE                      ,
                                PAST_PERF_US_PHONE_EX                   ,
                                PAST_PERF_NON_US_PHONE                  ,
                                PAST_PERF_FAX                           ,
                                PAST_PERF_EMAIL                         ,
                                ALT_PAST_PERF_POC                       ,
                                ALT_PAST_PERF_ADD1                      ,
                                ALT_PAST_PERF_ADD2                      ,
                                ALT_PAST_PERF_CITY                      ,
                                ALT_PAST_PERF_POSTAL_CODE               ,
                                ALT_PAST_PERF_COUNTRY                   ,
                                ALT_PAST_PERF_STATE                     ,
                                ALT_PAST_PERF_US_PHONE                  ,
                                ALT_PAST_PERF_US_PHONE_EX               ,
                                ALT_PAST_PERF_NON_US_PHONE              ,
                                ALT_PAST_PERF_FAX                       ,
                                ALT_PAST_PERF_EMAIL                     ,
                                ELEC_BUS_POC                            ,
                                ELEC_BUS_ADD1                           ,
                                ELEC_BUS_ADD2                           ,
                                ELEC_BUS_CITY                           ,
                                ELEC_BUS_POSTAL_CODE                    ,
                                ELEC_BUS_COUNTRY                        ,
                                ELEC_BUS_STATE                          ,
                                ELEC_BUS_US_PHONE                       ,
                                ELEC_BUS_US_PHONE_EX                    ,
                                ELEC_BUS_NON_US_PHONE                   ,
                                ELEC_BUS_FAX                            ,
                                ELEC_BUS_EMAIL                          ,
                                ALT_ELEC_BUS_POC                        ,
                                ALT_ELEC_BUS_ADD1                       ,
                                ALT_ELEC_BUS_ADD2                       ,
                                ALT_ELEC_BUS_CITY                       ,
                                ALT_ELEC_BUS_POSTAL_CODE                ,
                                ALT_ELEC_BUS_COUNTRY                    ,
                                ALT_ELEC_BUS_STATE                      ,
                                ALT_ELEC_BUS_US_PHONE                   ,
                                ALT_ELEC_BUS_US_PHONE_EX                ,
                                ALT_ELEC_BUS_NON_US_PHONE               ,
                                ALT_ELEC_BUS_FAX                        ,
                                ALT_ELEC_BUS_EMAIL                      ,
                                CERTIFIER_POC                           ,
                                CERTIFIER_US_PHONE                      ,
                                CERTIFIER_US_PHONE_EX                   ,
                                CERTIFIER_NON_US_PHONE                  ,
                                CERTIFIER_FAX                           ,
                                CERTIFIER_EMAIL                         ,
                                ALT_CERTIFIER_POC                       ,
                                ALT_CERTIFIER_US_PHONE                  ,
                                ALT_CERTIFIER_US_PHONE_EX               ,
                                ALT_CERTIFIER_NON_US_PHONE              ,
                                CORP_INFO_POC                           ,
                                CORP_INFO_US_PHONE                      ,
                                CORP_INFO_US_PHONE_EX                   ,
                                CORP_INFO_NON_US_PHONE                  ,
                                CORP_INFO_FAX                           ,
                                CORP_INFO_EMAIL                         ,
                                OWNER_INFO_POC                          ,
                                OWNER_INFO_US_PHONE                     ,
                                OWNER_INFO_US_PHONE_EX                  ,
                                OWNER_INFO_NON_US_PHONE                 ,
                                OWNER_INFO_FAX                          ,
                                OWNER_INFO_EMAIL                        ,
                                EDI                                     ,
                                TAXPAYER_ID                             ,
                                AVG_NUM_EMPLOYEES                       ,
                                ANNUAL_REVENUE                          ,
                                SOCIAL_SECURITY_NUMBER                  ,
                                FINANCIAL_INSTITUTE                     ,
                                BANK_ACCT_NUMBER                        ,
                                ABA_ROUTING                             ,
                                BANK_ACCT_TYPE                          ,
                                LOCKBOX_NUMBER                          ,
                                AUTHORIZATION_DATE                      ,
                                EFT_WAIVER                              ,
                                ACH_US_PHONE                            ,
                                ACH_NON_US_PHONE                        ,
                                ACH_FAX                                 ,
                                ACH_EMAIL                               ,
                                REMIT_POC                               ,
                                REMIT_ADD1                              ,
                                REMIT_ADD2                              ,
                                REMIT_CITY                              ,
                                REMIT_STATE                             ,
                                REMIT_POSTAL_CODE                       ,
                                --Bug8335551
                                --REMIT_COUNTRY                           ,
                                get_territory_code(REMIT_COUNTRY)       ,
                                AR_POC                                  ,
                                AR_US_PHONE                             ,
                                AR_US_PHONE_EX                          ,
                                AR_NON_US_PHONE                         ,
                                AR_FAX                                  ,
                                AR_EMAIL                                ,
                                MPIN                                    ,
                                EDI_COORDINATOR                         ,
                                EDI_US_PHONE                            ,
                                EDI_US_PHONE_EX                         ,
                                EDI_NON_US_PHONE                        ,
                                EDI_FAX                                 ,
                                EDI_EMAIL                               ,
                    sysdate      ,
                    l_user_id,
                    file_date,
                    ALT_CERTIFIER_FAX                       ,
                    ALT_CERTIFIER_EMAIL,
                        sysdate,
                        l_user_id,
                        l_user_id ,
                        state_of_inc,
                        COUNTRY_OF_INC,
                        -- Added for bug 6339382
                        l_code(71).code
                        ,AUSTIN_TETRA_NUMBER
                        ,AUSTIN_TETRA_PARENT_NUMBER
                        ,AUSTIN_TETRA_ULTIMATE_NUMBER
                        ,AUSTIN_TETRA_PCARD_FLAG
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
            ,HQ_PARENT_POC
            ,PAYMENT_TYPE
            ,ANNUAL_RECEIPTS
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
            FROM  FV_CCR_PROCESS_GT fcpg
            WHERE fcpg.duns = l_ccr_data.duns
            AND fcpg.extract_code=l_ccr_data.extract_code
            AND fcpg.plus_four is null ;

            --add  into new section of exception  report
            insert_temp_data(2,l_ccr_data.duns||l_ccr_data.plus_four,l_ccr_data.legal_bus_name,l_msg_pay_obj,null,null,null);

          END IF ; -- end of extractcode as '3'    root duns
        END IF ; -- xml import =y for no data found
    when others THEN
       l_errbuf := 'Exception occurred while updating root duns  '||SQLERRM;
       FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

    END; -- end of begin for root duns

    END IF;  -- end of duns+4 not null
   END IF; -- end of if l_valid_tin IS NULL
  END LOOP;

      --sthota
      if l_vendor_cnt>0 then
       for i in 1..l_vendor_cnt
       loop
          ap_approval_pkg.BATCH_APPROVAL_FOR_VENDOR(vendor_ids(l_vendor_cnt), l_module_name);
          l_errbuf := 'New Active Vendor Id: '||vendor_ids(i);
          FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);
           FND_FILE.PUT_LINE(FND_FILE.OUTPUT,l_errbuf);
           select vendor_name into l_vendor_name from po_vendors where vendor_id = vendor_ids(i);
           insert_temp_data(4,duns_ids(i),vendor_ids(i),l_vendor_name,null,null,null);

       end loop;
      end if;

  -- bug 3838149
  FOR l_taxpayer in c_taxpayer
  LOOP
    l_counter:=1;
    l_duns_list:='';

    FOR l_duns_info in c_duns_info( l_taxpayer.taxpayer_id,l_taxpayer.vendor_id)
    LOOP
      IF l_counter > 1 THEN
        l_duns_list:= l_duns_list||',';
        l_counter := l_counter+1;
      END IF;
      l_duns_list:= l_duns_list|| l_duns_info.duns;
        l_counter := l_counter+1;

    END LOOP;

    OPEN c_vendor_info(l_taxpayer.vendor_id);
    FETCH c_vendor_info into l_vendor_id;
    CLOSE c_vendor_info;

       FND_MESSAGE.set_NAME('FV','FV_CCR_DUPLICATE_TAXPAYER_NUM');
       FND_MESSAGE.set_TOKEN('LISTDUNS',l_duns_list);
       FND_MESSAGE.SET_TOKEN('VENDOR', l_vendor_id);
       message_text := FND_MESSAGE.get;


       insert_temp_data(3,null,message_text ,null,'ORACLE',null,null);
  END LOOP;

  -- bug 3849198
  l_errbuf := 'Updating the duns+4 as expired/deleted based on DUNS';
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

  update fv_ccr_vendors fcvp set fcvp.ccr_status='E' ,
                          fcvp.enabled='N',
                          fcvp.extract_code=decode(fcvp.ccr_status,'E',fcvp.extract_code,'4')
  where duns in ( select duns from fv_ccr_vendors fcvr where   fcvr.duns= fcvp.duns
                                                 and  fcvr.plus_four is null
                                                 and  fcvr.ccr_status='E' )
  and fcvp.ccr_status<>'N';

  update fv_ccr_vendors fcvp set fcvp.ccr_status='D' ,
                          fcvp.enabled='N',
                          fcvp.extract_code=decode(fcvp.ccr_status,'D',fcvp.extract_code,'1')
  where duns in ( select duns from fv_ccr_vendors fcvr where   fcvr.duns= fcvp.duns
                                                 and  fcvr.plus_four is null
                                                 and  fcvr.ccr_status='D' )
  and fcvp.ccr_status<>'N';


  l_errbuf := 'Updating the duns+4 as expired/deleted based on DUNS - Done';
  FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

  IF (p_xml_import = 'Y' AND l_xml_opt_param_set = 'Y') THEN -- Bug 3872908
      l_verify_existence := 'N';
  ELSIF (l_pos23 IN ('SR', 'CR') OR p_xml_import = 'Y') THEN
      l_verify_existence := 'Y';
  ELSE
      l_verify_existence := 'N';
  END IF;



  IF l_verify_existence = 'Y' THEN
    IF l_update_type = 'A' THEN
       UPDATE fv_ccr_vendors fcv SET ccr_status = DECODE(ccr_status, 'N', 'U',
                 CASE WHEN renewal_date < trunc(sysdate) THEN 'E' ELSE 'D' END)
       WHERE  not exists ( SELECT 1 FROM fv_ccr_process_gt fcpg
                           WHERE fcv.duns = fcpg.duns
                             AND NVL(fcv.plus_four, 'NO_PLUS4') =
                           NVL(fcpg.plus_four, 'NO_PLUS4'))
       AND (fcv.ccr_status ='A' OR fcv.ccr_status = 'N');
    ELSIF l_update_type = 'S' THEN
    --sthota need to check
       UPDATE fv_ccr_vendors fcv SET ccr_status = DECODE(ccr_status, 'N', 'U', 'A', 'A',
                 CASE WHEN renewal_date < trunc(sysdate) THEN 'E' ELSE 'D' END)
       WHERE  not exists ( SELECT 1 FROM fv_ccr_process_gt fcpg
                           WHERE fcv.duns = fcpg.duns
                             AND NVL(fcv.plus_four, 'NO_PLUS4') =
                           NVL(fcpg.plus_four, 'NO_PLUS4'))
       AND (fcv.ccr_status ='A' OR fcv.ccr_status = 'N')
       AND fcv.duns = SUBSTR(p_duns, 1, 9)
       AND (p_xml_import <> 'Y'  OR
           ((NVL(fcv.plus_four, 'NO_PLUS4') = NVL(SUBSTR(p_duns, 10, 4), 'NO_PLUS4'))
            OR fcv.plus_four IS NULL));
    ELSIF l_update_type = 'N' THEN
        UPDATE fv_ccr_vendors fcv SET ccr_status = DECODE(ccr_status, 'N', 'U',
                 CASE WHEN renewal_date < trunc(sysdate) THEN 'E' ELSE 'D' END)
       WHERE  not exists ( SELECT 1 FROM fv_ccr_process_gt fcpg
                           WHERE fcv.duns = fcpg.duns
                             AND NVL(fcv.plus_four, 'NO_PLUS4') =
                           NVL(fcpg.plus_four, 'NO_PLUS4'))
       AND fcv.ccr_status = 'N';
    END IF;
  END IF;

  -- made this change a part of bug 3872249
  update fv_ccr_vendors set extract_code=decode(l_file_type,'M','A','2')
  where  duns in ( select distinct duns from fv_ccr_process_gt)
  and extract_code ='N'
  and    plus_four is null;

  --bug 3931200

  -- made this change as part of BUG 3989083
  update fv_ccr_vendors fcv set fcv.enabled='Y'
  where fcv.enabled='N' and fcv.ccr_status='A'
  and not exists (select 1 from fv_ccr_orgs fco
  where fco.ccr_id = fcv.ccr_id);
  -- BUG 3989083

  IF (p_xml_import='Y' and p_insert_data='Y') THEN

    FOR crec in (SELECT duns, plus_four from fv_ccr_process_gt fcpg
                 WHERE fcpg.extract_code in ('1', '4')
                 AND not exists (SELECT 1 FROM fv_ccr_vendors
                                 WHERE duns = fcpg.duns
                                 AND nvl(plus_four,'N') = nvl(fcpg.plus_four,'N')
                                 ))
        LOOP
           FND_MESSAGE.set_NAME('FV','FV_CCR_XML_INACTIVE_DUNS');
           message_text := FND_MESSAGE.get;
           l_errbuf :='Expired/inactive DUNS/DUNS+4: '||crec.duns||'-'||crec.plus_four;
           FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, 'main',l_errbuf);
           insert_temp_data(3,null,message_text ,null,crec.duns||crec.plus_four,null,null);
    END LOOP;
  END IF;

  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'                                              CCR Data Load Report');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'   ');

  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Concurrent Request ID:    '||l_request_id);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'Extract File Parameters ');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'   ');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad('File Location: '||p_file_location,75,' ')||rpad('File Name: '||p_file_name,75,' ')||'File Type: '||p_file_type);
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad('DUNS Numbers To Query: '||nvl(p_duns,'All'),75,' ')||rpad('Enter DUNS Number: '||nvl(p_duns,'N/A'),75,' '));
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');

  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'XML Parameters');
--  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad('DUNS Numbers To Query: '||nvl(p_duns,'All'),75,' ')||rpad('Enter DUNS Number: '||nvl(p_duns,'N/A'),35,' ')||'CAGE Code: '||'N/A');
--  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad('Taxpayer Number: '||'N/A',75,' ')||'Registration Status: '||'N/A');
--  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad('Start Date: '||'N/A',75,' ')||'End Date: '||'N/A');

  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad('DUNS Numbers To Query: '||nvl(p_duns,'All'),75,' ')||rpad('Enter DUNS Number: '||nvl(p_duns,'N/A'),75,' ')||'Insert New Records: '||p_insert_data);

  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');

  l_report_count := 0;

  FOR l_ccr_rep in c_ccr_rep
  LOOP
    l_report_count := l_report_count + 1;
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'');
    IF l_ccr_rep.record_type ='1' THEN
        IF (l_title1set = false) THEN
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'====================================================================== DUNS/DUNS+4 Returned ======================================================================= ');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad('DUNS/DUNS+4 Number',20,' ')||' '||rpad('Legal Business Name',90,' ')||' '||rpad('CAGE Code',10,' ')||' '||rpad('SSN/TIN',20,' ')||' '||rpad('Registration Status',30,' '));
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad('------------------',20,' ')||' '||rpad('-------------------',90,' ')||' '||rpad('---------',10,' ')||' '||rpad('-------',20,' ')||' '||rpad('-------------------',30,' '));
              l_title1set := true;
        END IF;
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad(l_ccr_rep.duns_info,20,' ')||' '||rpad(substr(l_ccr_rep.reference1,1,90),90,' ')||' '||
                                          rpad(l_ccr_rep.reference2,10,' ')||' '||rpad(l_ccr_rep.reference3,20,' ')||' '||l_ccr_rep.reference4);
    ELSIF l_ccr_rep.record_type ='2' THEN
        IF (l_title2set = false) THEN
             if p_xml_import = 'Y' then
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'========================================================================== DUN/DUNS+4  ============================================================================ ');
             else
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'====================================================================== New DUN/DUNS+4  ============================================================================ ');
             end if;
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad('DUNS/DUNS+4 Number',20,' ')||' '||rpad('Legal Business Name',90,' ')||' '||'Notes');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad('------------------',20,' ')||' '||rpad('-------------------',90,' ')||' '||'-----');
              l_title2set := true;
        END IF;
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad(l_ccr_rep.duns_info,20,' ')||' '||rpad(substr(l_ccr_rep.reference1,1,90),90,' ')||' '||l_ccr_rep.reference2);

    ELSIF l_ccr_rep.record_type ='3' THEN
        IF (l_title3set = false) THEN
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'====================================================================== Messages Reported ========================================================================== ');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad('Source',20,' ')||' '||rpad('Message',90 ,' ')||' '||'Action');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad('------',20,' ')||' '||rpad('-------',90 ,' ')||' '||'------');
              l_title3set := true;
        END IF;

        IF length(l_ccr_rep.reference1) > 90 THEN
          i := 1;
          WHILE i < length(l_ccr_rep.reference1)
          LOOP
            if i = 1 then
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad(l_ccr_rep.reference3,20,' ')||' '||substr(l_ccr_rep.reference1,i,90)||' '||l_ccr_rep.reference2);
            else
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad(' ',20,' ')||' '||substr(l_ccr_rep.reference1,i,90));
            end if;
            i := i + 90;
          END LOOP;
        ELSE
          FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad(l_ccr_rep.reference3,20,' ')||' '||rpad(l_ccr_rep.reference1,length(l_ccr_rep.reference1),' ')||' '||l_ccr_rep.reference2);
        END IF;

        --sthota
    ELSIF l_ccr_rep.record_type ='4' THEN
        IF (l_title4set = false) THEN
             if p_xml_import = 'Y' then
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'====================================================================== Active Vendors - DUN/DUNS+4 ============================================================ ');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'The following vendors are made active with the current Data Transfer program ');
              FND_FILE.put_line(FND_FILE.OUTPUT,'and an Invoice Validation program will be submitted automatically ');
             else
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'====================================================================== Active Vendors - DUN/DUNS+4 ============================================================ ');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'The following vendors are made active with the current Data Transfer program ');
              FND_FILE.put_line(FND_FILE.OUTPUT,'and an Invoice Validation program will be submitted automatically ');

             end if;
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad('DUNS/DUNS+4 Number',20,' ')||' '||rpad('Vendor Id',90,' ')||' '||'Vendor Name');
              FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad('------------------',20,' ')||' '||rpad('---------',90,' ')||' '||'-----------');
              l_title4set := true;
        END IF;
        FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad(l_ccr_rep.duns_info,20,' ')||' '||rpad(substr(l_ccr_rep.reference1,1,90),90,' ')||' '||l_ccr_rep.reference2);


    END IF;
  END LOOP;

  --bug3958492
  if l_report_count = 0 then
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'====================================================================== DUNS/DUNS+4 Processed ====================================================================== ');
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,' ');
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad('DUNS/DUNS+4 Number',20,' ')||' '||rpad('Legal Business Name',90,' ')||' '||rpad('CAGE Code',10,' ')||' '||rpad('Taxpayer ID',20,' ')||' '||rpad('Registration Status',30,' '));
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,rpad('------------------',20,' ')||' '||rpad('-------------------',90,' ')||' '||rpad('---------',10,' ')||' '||rpad('-----------',20,' ')||' '||rpad('-------------------',30,' '));
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,'None');
  end if;


  -- purge the temporary tables
  delete from fv_ccr_file_temp;
  delete from fv_ccr_process_gt;
  delete from fv_ccr_process_report ;
commit;

exception when others then
      l_errbuf := 'Exception occurred '||SQLERRM;
      FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, l_module_name,l_errbuf);

END Main;

-------------------------------------------------------------------------------
--Bug 8335551
--Retrieve the 2 digit territory code from the passed 3 digit
--iso territory code.
--If a row is not found in fnd_territories for the passed
--3 digit iso territory code, then pass back the 2 digit iso territory code so
--that the CCR code will behave as it does before this fix was done.
FUNCTION get_territory_code(p_iso_territory_code IN VARCHAR2)
   RETURN varchar2 IS

l_module_name   VARCHAR2(1000):= 'fv_ccr_data_load_pkg.get_territory_code';
l_2char_territory_code VARCHAR2(2);

BEGIN

 FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT,'In: '||l_module_name);

 SELECT territory_code
 INTO   l_2char_territory_code
 FROM   fnd_territories
 WHERE  iso_territory_code = p_iso_territory_code;

 RETURN l_2char_territory_code;

 EXCEPTION
     --In case a 2 digit code is not found in the table for
     --the passed 3 digit code send back the 3 digit code
     WHEN NO_DATA_FOUND THEN RETURN p_iso_territory_code;

     WHEN OTHERS THEN
     FV_UTILITY.LOG_MESG(FND_LOG.LEVEL_STATEMENT, 'When others error in: '||
                          l_module_name||':'||SQLERRM);
END;
-------------------------------------------------------------------------------


begin
open c_bus_codes;
fetch c_bus_codes bulk collect into bus_code;
close c_bus_codes;

open c_sic_codes;
fetch c_sic_codes bulk collect into sic_code;
close c_sic_codes;

open c_naic_codes;
fetch c_naic_codes bulk collect into naic_code;
close c_naic_codes;

open c_fsc_codes;
fetch c_fsc_codes bulk collect into fsc_code;
close c_fsc_codes;

open c_psc_codes;
fetch c_psc_codes bulk collect into psc_code;
close c_psc_codes;

end FV_CCR_DATA_LOAD_PKG;

/
