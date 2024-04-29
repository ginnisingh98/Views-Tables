--------------------------------------------------------
--  DDL for Package Body HR_360_MESSAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_360_MESSAGE" as
/* $Header: perhrhd360vw.pkb 120.6 2008/03/19 09:51:41 sathkris noship $ */
procedure HR_360_PERSON_VIEW ( P_EMPLOYEE_NUMBER VARCHAR2 ,
                               p_effective_date date default sysdate,
                               P_BUSINESS_GROUP_ID NUMBER,
	                           p_tp_site_id number,
                               p_trxn_id varchar2)

is

l_params WF_PARAMETER_LIST_T;

L_EMPLOYEE_NUMBER  PER_ALL_PEOPLE_F.EMPLOYEE_NUMBER%type;
L_USER_PERSON_TYPE VARCHAR2(60);
L_DATE_OF_BIRTH DATE;
L_TOWN_OF_BIRTH PER_ALL_PEOPLE_F.TOWN_OF_BIRTH%type;
L_COUNTRY_OF_BIRTH PER_ALL_PEOPLE_F.COUNTRY_OF_BIRTH%type;
L_DATE_OF_DEATH DATE;
L_ORIGINAL_DATE_OF_HIRE DATE;
L_EFFECTIVE_START_DATE DATE;
L_SEX VARCHAR2(30);
L_MARITAL_STATUS VARCHAR2(30);
L_FULL_NAME PER_ALL_PEOPLE_F.FULL_NAME%type;
L_PRE_NAME_ADJUNCT PER_ALL_PEOPLE_F.PRE_NAME_ADJUNCT%type;
L_SUFFIX VARCHAR2(30);
L_TITLE VARCHAR2(30);
L_LAST_NAME PER_ALL_PEOPLE_F.LAST_NAME%type;
L_FIRST_NAME PER_ALL_PEOPLE_F.FIRST_NAME%type;
L_MIDDLE_NAMES PER_ALL_PEOPLE_F.MIDDLE_NAMES%type;
L_ADDRESS_TYPE PER_ADDRESSES.ADDRESS_TYPE%type;
L_DATE_FROM DATE;
L_COUNTRY PER_ADDRESSES.COUNTRY%type;
L_ADDRESS_LINE1 PER_ADDRESSES.ADDRESS_LINE1%type;
L_ADDRESS_LINE2 PER_ADDRESSES.ADDRESS_LINE2%type;
L_ADDRESS_LINE3 PER_ADDRESSES.ADDRESS_LINE3%type;
L_TOWN_OR_CITY PER_ADDRESSES.TOWN_OR_CITY%type;
L_TELEPHONE_NUMBER_1 PER_ADDRESSES.TELEPHONE_NUMBER_1%type;
L_REGION_1 PER_ADDRESSES.REGION_1%type;
L_REGION_2 PER_ADDRESSES.REGION_1%type;
L_POSTAL_CODE PER_ADDRESSES.POSTAL_CODE%type;
L_EMAIL_ADDRESS PER_ALL_PEOPLE_F.EMAIL_ADDRESS%type;
L_PHONE_TYPE PER_PHONES.PHONE_TYPE%type;
L_PHONE_NUMBER PER_PHONES.PHONE_NUMBER%type;
L_NATIONALITY VARCHAR2(30);
L_NATIONAL_IDENTIFIER PER_ALL_PEOPLE_F.NATIONAL_IDENTIFIER%type;
L_CONTACT_NAME VARCHAR2(240);
L_CONTACT_ADDRESSLINE1 PER_ADDRESSES.ADDRESS_LINE1%type;
L_CONTACT_ADDRESSLINE2 PER_ADDRESSES.ADDRESS_LINE2%type;
L_CONTACT_ADDRESSLINE3 PER_ADDRESSES.ADDRESS_LINE3%type;
L_CONTACT_COUNTRY PER_ADDRESSES.COUNTRY%type;
L_CONTACT_TOWN_OR_CITY PER_ADDRESSES.TOWN_OR_CITY%type;
L_CONTACT_TELEPHONE_NUMBER_1 PER_ADDRESSES.TELEPHONE_NUMBER_1%type;
L_CONTACT_REGION_1 PER_ADDRESSES.REGION_1%type;
L_CONTACT_REGION_2 PER_ADDRESSES.REGION_1%type;
L_CONTACT_POSTAL_CODE PER_ADDRESSES.POSTAL_CODE%type;
L_RELATIONSHIP VARCHAR2(30);
l_EMP_JOB_NAME VARCHAR2(700);
L_EMP_GRADE_NAME VARCHAR2(240);
L_POSITION_NAME 	VARCHAR2(240);
L_EMPLOYMENT_CATEGORY VARCHAR2(30);
L_NORMAL_HOURS number;
L_ASG_LOCATION VARCHAR2(60) ;
L_ASSIGNMENT_STATUS VARCHAR2(80);
L_DEPARTMENT_NAME VARCHAR2 (240);
L_BUSINESS_GROUP_NAME VARCHAR2 	(240) ;
L_PAYROLL_NAME 	VARCHAR2(80);
L_SUPERVISOR_NAME VARCHAR2(240) ;

--- VAR DECL -----
l_style varchar2(30);
l_end_user_col_name1 varchar2(60);
l_end_user_col_name2 varchar2(60);
l_end_user_col_name3 varchar2(60);
l_end_user_col_name4 varchar2(60);
l_end_user_col_name5 varchar2(60);
l_end_user_col_name6 varchar2(60);
l_end_user_col_name7 varchar2(60);
l_end_user_col_name8 varchar2(60);
l_end_user_col_name9 varchar2(60);
l_end_user_col_name10 varchar2(60);
l_end_user_col_name11 varchar2(60);
l_end_user_col_name12 varchar2(60);
l_end_user_col_name13 varchar2(60);
l_end_user_col_name14 varchar2(60);
l_end_user_col_name15 varchar2(60);
l_end_user_col_name16 varchar2(60);
l_end_user_col_name17 varchar2(60);
l_end_user_col_name18 varchar2(60);
l_end_user_col_name19 varchar2(60);
l_end_user_col_name20 varchar2(60);
l_end_user_col_name21 varchar2(60);
l_end_user_col_name22 varchar2(60);
l_end_user_col_name23 varchar2(60);
l_end_user_col_name24 varchar2(60);
l_end_user_col_name25 varchar2(60);

l_app_col_name1 varchar2(30);
l_app_col_name2 varchar2(30);
l_app_col_name3 varchar2(30);
l_app_col_name4 varchar2(30);
l_app_col_name5 varchar2(30);
l_app_col_name6 varchar2(30);
l_app_col_name7 varchar2(30);
l_app_col_name8 varchar2(30);
l_app_col_name9 varchar2(30);
l_app_col_name10 varchar2(30);
l_app_col_name11 varchar2(30);
l_app_col_name12 varchar2(30);
l_app_col_name13 varchar2(30);
l_app_col_name14 varchar2(30);
l_app_col_name15 varchar2(30);
l_app_col_name16 varchar2(30);
l_app_col_name18 varchar2(30);
l_app_col_name19 varchar2(30);
l_app_col_name20 varchar2(30);
l_app_col_name21 varchar2(30);
l_app_col_name22 varchar2(30);
l_app_col_name23 varchar2(30);
l_app_col_name24 varchar2(30);
l_app_col_name25 varchar2(30);
p_tp_site_id_act varchar2(100);

L_APP_COL_VALUE VARCHAR2(150);


L_SEQNUM NUMBER(30);
l_con_personid number;
l_con_bgid number;

cursor csr_check_person_add is
select style,ADDRESS_ID
 from per_addresses padr, per_all_people_f papf
 where papf.employee_number =P_EMPLOYEE_NUMBER
       and papf.business_group_id =P_BUSINESS_GROUP_ID
       AND P_EFFECTIVE_DATE BETWEEN PAPF.EFFECTIVE_START_DATE AND PAPF.EFFECTIVE_END_DATE
       AND PADR.PERSON_ID=PAPF.PERSON_ID
       AND PADR.business_group_id =PAPF.BUSINESS_GROUP_ID
       AND PRIMARY_FLAG ='Y'
       and p_effective_date
       between padr.date_from and nvl (padr.date_to, to_date('31-12-4712', 'DD-MM-YYYY')) ;

CURSOR CSR_GET_LEG_SPEC_COLS (P_STYLE VARCHAR2) IS
    SELECT end_user_column_name ,APPLICATION_COLUMN_NAME
    FROM fnd_descr_flex_col_usage_vl
    WHERE(application_id = 800)
    AND(descriptive_flexfield_name = 'Address Structure')
    AND(descriptive_flex_context_code =P_STYLE)
    ORDER BY column_seq_num;

CURSOR CSR_GET_CONTACT_ADD (P_PERSONID NUMBER, P_BG_ID NUMBER) IS
select style,ADDRESS_ID
 from per_addresses padr
 where person_id=P_PERSONID and BUSINESS_GROUP_ID =P_BG_ID;

/*Modified the cursor to select the employee number for the ex-employees also
  for the bug 6892089*/

CURSOR CSR_PERSON_FULL_VIEW IS

SELECT PPF.PERSON_ID,
DECODE ( ppf.CURRENT_NPW_FLAG , 'Y',ppf.NPW_NUMBER,ppf.EMPLOYEE_NUMBER) EMPLOYEE_NUMBER,
        HR_PERSON_TYPE_USAGE_INFO.GET_USER_PERSON_TYPE(p_effective_date , PPF.PERSON_ID) ,
        PPF.DATE_OF_BIRTH,
        PPF.TOWN_OF_BIRTH,
        PPF.COUNTRY_OF_BIRTH,
        PPF.DATE_OF_DEATH,
        PPF.ORIGINAL_DATE_OF_HIRE,
        PPF.EFFECTIVE_START_DATE,
        HL1.MEANING SEX,
        HL4.MEANING MARITAL_STATUS,
        PPF.FULL_NAME,
        PPF.PRE_NAME_ADJUNCT,
        PPF.SUFFIX,
        HL3.MEANING TITLE,
        PPF.LAST_NAME,
        PPF.FIRST_NAME,
        PPF.MIDDLE_NAMES,
        PPF.EMAIL_ADDRESS,
        PHONE_TYPE,
        PHONE_NUMBER,
        HL2.MEANING NATIONALITY,
        PPF.NATIONAL_IDENTIFIER ,
	    PCR.FULL_NAME CONTACT_NAME,
        PCR.MEANING RELATIONSHIP,
        JBT.NAME EMP_JOB_NAME,
        GDT.NAME EMP_GRADE_NAME,
        HR_GENERAL.DECODE_POSITION_LATEST_NAME(PA.POSITION_ID) POSITION_NAME,
        HR_GENERAL.DECODE_LOOKUP('EMP_CAT', PA.EMPLOYMENT_CATEGORY) EMPLOYMENT_CATEGORY,
        PA.NORMAL_HOURS,
        LOCTL.LOCATION_CODE ASG_LOCATION ,
        NVL(AMDTL.USER_STATUS , STTL.USER_STATUS) ASSIGNMENT_STATUS ,
        OTL.NAME DEPARTMENT_NAME ,
        OTL1.NAME BUSINESS_GROUP_NAME  ,
        PAY.PAYROLL_NAME PAYROLL_NAME,
        PPF1.FULL_NAME  SUPERVISOR_NAME,
        PCR.CONTACT_PERSON_ID,
        PCR.BUSINESS_GROUP_ID


FROM    PER_ALL_PEOPLE_F ppf,
        PER_ALL_PEOPLE_F ppf1,
        PER_PHONES ppn ,
        hr_lookups HL1 ,
        HR_LOOKUPS HL2 ,
        HR_LOOKUPS HL3 ,
        HR_LOOKUPS HL4 ,
        PER_ALL_ASSIGNMENTS_F PA,
        PER_GRADES PG ,
        PER_JOBS J,
        PER_GRADES_TL GDT,
        PER_JOBS_TL JBT ,
        HR_LOCATIONS_ALL_TL LOCTL,
        HR_LOCATIONS_ALL LOC,
        PER_ASSIGNMENT_STATUS_TYPES ST ,
        PER_ASSIGNMENT_STATUS_TYPES_TL STTL ,
        PER_ASS_STATUS_TYPE_AMENDS AMD,
        PER_ASS_STATUS_TYPE_AMENDS_TL AMDTL,
        HR_ALL_ORGANIZATION_UNITS O,
        HR_ALL_ORGANIZATION_UNITS_TL OTL ,
        HR_ALL_ORGANIZATION_UNITS_TL OTL1 ,
        pay_all_payrolls_f pay,


(	SELECT FULL_NAME ,
           PCR1.PERSON_ID ,
           PCR1.BUSINESS_GROUP_ID,
           C.MEANING,
           PCR1.CONTACT_PERSON_ID

	FROM PER_ALL_PEOPLE_F PPF1 ,
         PER_CONTACT_RELATIONSHIPS PCR1 ,
         HR_LOOKUPS C

	WHERE PPF1.PERSON_ID = CONTACT_PERSON_ID
    AND   PRIMARY_CONTACT_FLAG = 'Y'
    AND   C.LOOKUP_TYPE = 'CONTACT'
    AND C.LOOKUP_CODE = PCR1.CONTACT_TYPE
    AND PCR1.BUSINESS_GROUP_ID= PPF1.BUSINESS_GROUP_ID
       )PCR

WHERE   ppn.PARENT_ID (+) = PPF.PERSON_ID
 -- Modified for the bug 6895752 starts here
    /*AND ( ppn.parent_id is null
     OR ( ppn.parent_id is not null
    AND PPN.PARENT_TABLE            = 'PER_ALL_PEOPLE_F'
    AND PPN.PHONE_TYPE              = 'W1' ))*/
-- Modified for the bug 6895752 ends here

    AND PPN.PARENT_TABLE  (+)          = 'PER_ALL_PEOPLE_F'
    AND PPN.PHONE_TYPE (+)             = 'W1'

    AND HL1.LOOKUP_TYPE (+)     = 'SEX'
    AND HL1.LOOKUP_CODE (+)     = ppf.SEX
    AND HL2.LOOKUP_TYPE (+)     = 'NATIONALITY'
    AND HL2.LOOKUP_CODE (+)     = Ppf.NATIONALITY
    AND HL3.LOOKUP_TYPE (+)     = 'TITLE'
    AND HL3.LOOKUP_CODE (+)     = PPF.TITLE
    AND HL4.LOOKUP_TYPE (+)     = 'MAR_STATUS'
    AND HL4.LOOKUP_CODE (+)     = PPF.MARITAL_STATUS
    AND p_effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
    AND PCR.PERSON_ID(+) =PPF.PERSON_ID
    AND PCR.BUSINESS_GROUP_ID(+) = ppf.business_group_id
    AND PPF.EMPLOYEE_NUMBER =P_EMPLOYEE_NUMBER
    and ppf.business_group_id =P_BUSINESS_GROUP_ID

    --  FOR JOBS AND GRADES DATA
    AND PPF.PERSON_ID= PA.PERSON_ID
    AND PPF.BUSINESS_GROUP_ID=PA.BUSINESS_GROUP_ID
    AND PA.ASSIGNMENT_TYPE IN ('E','C')
    AND PA.PRIMARY_FLAG ='Y'
    AND PA.GRADE_ID = PG.GRADE_ID (+)
    AND PA.GRADE_ID =GDT.GRADE_ID (+)
    AND GDT.LANGUAGE(+) = USERENV('LANG')
    AND PA.JOB_ID = JBT.JOB_ID (+)
    AND JBT.LANGUAGE(+) = USERENV('LANG')
    AND PA.JOB_ID = J.JOB_ID (+)
    -- FOR LOCATION DATA
    AND PA.LOCATION_ID = LOC.LOCATION_ID (+)
    AND LOC.LOCATION_ID = LOCTL.LOCATION_ID (+)
    AND DECODE(LOCTL.LOCATION_ID, NULL, '1', LOCTL.LANGUAGE)= DECODE(LOCTL.LOCATION_ID, NULL, '1', USERENV('LANG'))
    -- FOR ASG STATUS

    AND PA.ASSIGNMENT_STATUS_TYPE_ID = ST.ASSIGNMENT_STATUS_TYPE_ID
    AND PA.ASSIGNMENT_STATUS_TYPE_ID = AMD.ASSIGNMENT_STATUS_TYPE_ID (+)
    AND PA.BUSINESS_GROUP_ID + 0 = AMD.BUSINESS_GROUP_ID (+) + 0
    AND ST.ASSIGNMENT_STATUS_TYPE_ID = STTL.ASSIGNMENT_STATUS_TYPE_ID
    AND STTL.LANGUAGE = USERENV('LANG')
    AND AMD.ASS_STATUS_TYPE_AMEND_ID = AMDTL.ASS_STATUS_TYPE_AMEND_ID (+)
    AND DECODE(AMDTL.ASS_STATUS_TYPE_AMEND_ID, NULL, '1', AMDTL.LANGUAGE) =
                    DECODE(AMDTL.ASS_STATUS_TYPE_AMEND_ID, NULL, '1', USERENV('LANG'))
    -- FOR ORGANIZATION NAME

    AND PA.ORGANIZATION_ID = O.ORGANIZATION_ID
    AND O.ORGANIZATION_ID = OTL.ORGANIZATION_ID
    AND OTL.LANGUAGE = USERENV('LANG')
    AND PA.BUSINESS_GROUP_ID = OTL1.ORGANIZATION_ID
    AND OTL1.LANGUAGE = USERENV('LANG')
   -- FOR PAYROLL DATA
    AND PA.PAYROLL_ID = PAY.PAYROLL_ID (+)
    AND p_effective_date BETWEEN PAY.EFFECTIVE_START_DATE(+) AND PAY.EFFECTIVE_END_DATE (+)
    AND PA.BUSINESS_GROUP_ID=PAY.BUSINESS_GROUP_ID (+)

    AND  p_effective_date  BETWEEN PA.EFFECTIVE_START_DATE AND PA.EFFECTIVE_END_DATE
   -- AND PPF.PERSON_ID in( 317570 ,317599)
   -- SUPERVISOR  NAME
   AND PA.SUPERVISOR_ID = PPF1.PERSON_ID(+)
   AND p_effective_date BETWEEN PPF1.EFFECTIVE_START_DATE(+) AND PPF1.EFFECTIVE_END_DATE(+)
    ;

 type G_ADD_COLS is record
  (end_user_column_name        varchar2(30),
    APPLICATION_COLUMN_NAME      varchar2(30)
   );
  --
  type g_ADD_table is table of G_ADD_COLS index by binary_integer;
   G_ADD_ATTR  g_ADD_table;
   G_ADD_ATTR_TO_INSERT g_ADD_table ;

   L_SQL VARCHAR2(2000);
      L_SQL1 VARCHAR2(2000);
      L_ADDRESS_ID NUMBER;
      K NUMBER:=1;
      J NUMBER :=24;
      L_CURRENT_DATE DATE;
      P_UNIQUE_KEY NUMBER;
      L_PERSON_ID NUMBER;

      L_REP_NAME VARCHAR2(240);
      L_REP_EMPLOYEE_NUM VARCHAR2(30);
      L_REP_ASG_STATUS VARCHAR2(80);
      l_rep_clob clob;

   --  Reportee  data

   CURSOR CSR_REPORTEES_DATA IS

 SELECT ppf.full_name, employee_number ,
  NVL(AMDTL.USER_STATUS , STTL.USER_STATUS) ASSIGNMENT_STATUS
 FROM   per_all_assignments_f papf , per_all_people_f ppf ,
  PER_ASSIGNMENT_STATUS_TYPES ST ,
        PER_ASSIGNMENT_STATUS_TYPES_TL STTL ,
        PER_ASS_STATUS_TYPE_AMENDS AMD,
        PER_ASS_STATUS_TYPE_AMENDS_TL AMDTL

 WHERE
 SYSDATE BETWEEN  papf.effective_start_date AND papf.effective_end_date
 and papf.business_group_id = P_BUSINESS_GROUP_ID
 and   papf.supervisor_id =  L_PERSON_ID
 and papf.assignment_type <> 'B'
 and papf.primary_flag = 'Y'
 and papf.person_id=ppf.person_id
 -- for asg status

  AND PApf.ASSIGNMENT_STATUS_TYPE_ID = ST.ASSIGNMENT_STATUS_TYPE_ID
    AND PApf.ASSIGNMENT_STATUS_TYPE_ID = AMD.ASSIGNMENT_STATUS_TYPE_ID (+)
    AND PApf.BUSINESS_GROUP_ID + 0 = AMD.BUSINESS_GROUP_ID (+) + 0
    AND ST.ASSIGNMENT_STATUS_TYPE_ID = STTL.ASSIGNMENT_STATUS_TYPE_ID
    AND STTL.LANGUAGE = USERENV('LANG')
    AND AMD.ASS_STATUS_TYPE_AMEND_ID = AMDTL.ASS_STATUS_TYPE_AMEND_ID (+)
    AND DECODE(AMDTL.ASS_STATUS_TYPE_AMEND_ID, NULL, '1', AMDTL.LANGUAGE) =
                    DECODE(AMDTL.ASS_STATUS_TYPE_AMEND_ID, NULL, '1', USERENV('LANG')) ;


-- END OF CUROSR


BEGIN

SELECT party_site_id into p_tp_site_id_act
from ECX_TP_HEADERS
where TP_HEADER_ID = p_tp_site_id;

OPEN CSR_PERSON_FULL_VIEW;

FETCH CSR_PERSON_FULL_VIEW INTO
L_PERSON_ID ,L_EMPLOYEE_NUMBER  ,L_USER_PERSON_TYPE ,L_DATE_OF_BIRTH ,L_TOWN_OF_BIRTH ,L_COUNTRY_OF_BIRTH ,
L_DATE_OF_DEATH ,L_ORIGINAL_DATE_OF_HIRE ,L_EFFECTIVE_START_DATE ,L_SEX ,L_MARITAL_STATUS ,
L_FULL_NAME ,L_PRE_NAME_ADJUNCT ,L_SUFFIX ,L_TITLE ,L_LAST_NAME ,L_FIRST_NAME ,L_MIDDLE_NAMES ,
L_EMAIL_ADDRESS ,
L_PHONE_TYPE ,L_PHONE_NUMBER ,L_NATIONALITY ,L_NATIONAL_IDENTIFIER ,L_CONTACT_NAME ,
L_RELATIONSHIP ,l_EMP_JOB_NAME ,L_EMP_GRADE_NAME ,
L_POSITION_NAME ,L_EMPLOYMENT_CATEGORY ,L_NORMAL_HOURS ,L_ASG_LOCATION ,
L_ASSIGNMENT_STATUS ,L_DEPARTMENT_NAME ,L_BUSINESS_GROUP_NAME ,L_PAYROLL_NAME,
L_SUPERVISOR_NAME,l_con_personid,l_con_bgid;

CLOSE CSR_PERSON_FULL_VIEW;

select hrhd_delta_sync_seq.nextval into L_SEQNUM from dual;

L_CURRENT_DATE :=SYSDATE;
INSERT INTO HR_360_PERSON_VIEW (
EMPLOYEE_NUMBER   ,
USER_PERSON_TYPE ,
DATE_OF_BIRTH  ,
TOWN_OF_BIRTH ,
COUNTRY_OF_BIRTH  ,
DATE_OF_DEATH  ,
ORIGINAL_DATE_OF_HIRE  ,
EFFECTIVE_START_DATE  ,
SEX  ,
MARITAL_STATUS  ,
FULL_NAME   ,
PRE_NAME_ADJUNCT  ,
SUFFIX,
TITLE ,
LAST_NAME ,
FIRST_NAME ,
MIDDLE_NAMES,
EMAIL_ADDRESS,
PHONE_TYPE  ,
PHONE_NUMBER  ,
NATIONALITY  ,
NATIONAL_IDENTIFIER  ,
CONTACT_NAME  	       ,
RELATIONSHIP 	      ,
EMP_JOB_NAME 	     ,
EMP_GRADE_NAME      ,
POSITION_NAME 	   ,
EMPLOYMENT_CATEGORY  ,
NORMAL_HOURS  ,
ASG_LOCATION   ,
ASSIGNMENT_STATUS ,
DEPARTMENT_NAME   ,
BUSINESS_GROUP_NAME  ,
PAYROLL_NAME   ,
SUPERVISOR_NAME ,
RECSEQ,STATUS,PER_STATUS_DATE,
TRANSACTION_ID) VALUES
(
L_EMPLOYEE_NUMBER  ,L_USER_PERSON_TYPE ,L_DATE_OF_BIRTH ,L_TOWN_OF_BIRTH ,L_COUNTRY_OF_BIRTH ,
L_DATE_OF_DEATH ,L_ORIGINAL_DATE_OF_HIRE ,L_EFFECTIVE_START_DATE ,L_SEX ,L_MARITAL_STATUS ,
L_FULL_NAME ,L_PRE_NAME_ADJUNCT ,L_SUFFIX ,L_TITLE ,L_LAST_NAME ,L_FIRST_NAME ,L_MIDDLE_NAMES ,
L_EMAIL_ADDRESS ,L_PHONE_TYPE ,L_PHONE_NUMBER ,L_NATIONALITY ,L_NATIONAL_IDENTIFIER ,
L_CONTACT_NAME ,l_RELATIONSHIP ,l_EMP_JOB_NAME ,L_EMP_GRADE_NAME ,
L_POSITION_NAME ,L_EMPLOYMENT_CATEGORY ,L_NORMAL_HOURS ,L_ASG_LOCATION ,
L_ASSIGNMENT_STATUS ,L_DEPARTMENT_NAME ,L_BUSINESS_GROUP_NAME ,L_PAYROLL_NAME,
L_SUPERVISOR_NAME,L_EMPLOYEE_NUMBER||'-'||L_SEQNUM,'QUEUED',L_CURRENT_DATE,P_TRXN_ID);

 commit;




commit;

OPEN csr_check_person_add ;
FETCH csr_check_person_add INTO L_STYLE,L_ADDRESS_ID;
CLOSE csr_check_person_add;

IF l_style IS NOT NULL and L_ADDRESS_ID is not null THEN

OPEN CSR_GET_LEG_SPEC_COLS(l_style );
FETCH CSR_GET_LEG_SPEC_COLS BULK COLLECT INTO G_ADD_ATTR ;
CLOSE CSR_GET_LEG_SPEC_COLS;

 FOR I IN G_ADD_ATTR.FIRST .. G_ADD_ATTR.LAST
 LOOP

L_SQL:= ' begin
 SELECT ' ||G_ADD_ATTR(I).APPLICATION_COLUMN_NAME ||','||''''||G_ADD_ATTR(I).end_user_column_name||''''||
 ' INTO :1 ,:2 FROM PER_ADDRESSES WHERE ADDRESS_ID = '||L_ADDRESS_ID ||';
 end;';

  EXECUTE IMMEDIATE l_sql using in out L_APP_COL_VALUE,IN OUT l_end_user_col_name1 ;


L_SQL1:='UPDATE HR_360_PERSON_VIEW
          SET PER_ADD_LABLE'||J||'='||''''||L_APP_COL_VALUE||''''||',PER_ADD_LABLE'||K||
          '='||''''||l_end_user_col_name1||''''||'WHERE RECSEQ='||''''||L_EMPLOYEE_NUMBER||'-'||L_SEQNUM||'''';



 EXECUTE IMMEDIATE l_sql1;


J:=J+1;
K:=K+1;

end LOOP;

--  inserting  contact address data


END IF;



update HR_360_PERSON_VIEW
set address_STYLE=l_style
where RECSEQ=L_EMPLOYEE_NUMBER||'-'||L_SEQNUM ;



L_STYLE :=NULL;
K:=1;
J:=24;

OPEN CSR_GET_CONTACT_ADD (l_con_personid ,l_CON_BGID);
FETCH CSR_GET_CONTACT_ADD  INTO L_STYLE,L_ADDRESS_ID;
CLOSE CSR_GET_CONTACT_ADD;


IF l_style IS NOT NULL and L_ADDRESS_ID is not null THEN

OPEN CSR_GET_LEG_SPEC_COLS(l_style );
FETCH CSR_GET_LEG_SPEC_COLS BULK COLLECT INTO G_ADD_ATTR ;
CLOSE CSR_GET_LEG_SPEC_COLS;


 FOR I IN G_ADD_ATTR.FIRST .. G_ADD_ATTR.LAST
 LOOP

L_SQL:= ' begin
 SELECT ' ||G_ADD_ATTR(I).APPLICATION_COLUMN_NAME ||','||''''||G_ADD_ATTR(I).end_user_column_name||''''||
 ' INTO :1 ,:2 FROM PER_ADDRESSES WHERE ADDRESS_ID = '||L_ADDRESS_ID ||';
 end;';

-- EXECUTE IMMEDIATE l_sql using in out L_APP_COL_VALUE,IN OUT l_end_user_col_name1 ;


L_SQL1:='UPDATE HR_360_PERSON_VIEW
          SET CON_ADD_LABLE'||J||'='||''''||L_APP_COL_VALUE||''''||',CON_ADD_LABLE'||K||
          '='||''''||l_end_user_col_name1||''''||'WHERE RECSEQ='||''''||L_EMPLOYEE_NUMBER||'-'||L_SEQNUM||'''' ;






J:=J+1;
K:=K+1;


end LOOP;
END IF;

-- END OF INSERTING  CONTACTS ADDRESS DATA.

open CSR_REPORTEES_DATA;
loop
fetch CSR_REPORTEES_DATA into L_REP_NAME ,L_REP_EMPLOYEE_NUM ,L_REP_ASG_STATUS;
exit when CSR_REPORTEES_DATA%notfound;


insert into hr_360_per_reportee(
SUPERVISOR_ID,
REPORTEE_NAME,
REPORTEE_EMP_NUMBER,
REPORTEE_ASG_STATUS,
event_key)
 values(L_EMPLOYEE_NUMBER ,L_REP_NAME,L_REP_EMPLOYEE_NUM,L_REP_ASG_STATUS,
 L_EMPLOYEE_NUMBER||'-'||L_SEQNUM);

end loop;
close CSR_REPORTEES_DATA;

commit;



            WF_EVENT.AddParameterToList('ECX_TRANSACTION_TYPE', 'HRHD', l_params);
            WF_EVENT.AddParameterToList('ECX_TRANSACTION_SUBTYPE', 'PERVW',l_params);
            WF_EVENT.AddParameterToList('ECX_PARTY_SITE_ID', to_char(p_tp_site_id_act), l_params);
            WF_EVENT.AddParameterToList('ECX_DOCUMENT_ID', L_EMPLOYEE_NUMBER||'-'||to_char(L_SEQNUM), l_params);
            WF_EVENT.Raise(p_event_name => 'oracle.apps.per.hrhdrir.xml.out',
                           p_event_key => L_EMPLOYEE_NUMBER||'-'||to_char(L_SEQNUM),
                           p_parameters => l_params);



COMMIT;

END;

procedure  hr_wflow_360
		(itemtype   in varchar2,
		   itemkey    in varchar2,
		   actid      in number,
		   funcmode   in varchar2,
	 	   resultout  in out NOCOPY varchar2)
is
l_params WF_PARAMETER_LIST_T;
L_SEQNUM number;
p_person_id varchar2(30);
p_bg_id varchar2(30);
p_eff_dt varchar2(40);
p_tp_id varchar2(30);
p_eff_date date;
p_txn_id varchar2(200);
begin
p_person_id := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'PARAMETER1');
p_bg_id := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'PARAMETER2');
p_eff_dt := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'PARAMETER3');
p_tp_id := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'PARAMETER4');
p_txn_id := Wf_Engine.GetActivityAttrText(itemtype, itemkey, actid, 'PARAMETER5');
p_eff_date := nvl(to_date(p_eff_dt,'DD/MM/YYYY'),sysdate);

HR_360_MESSAGE.HR_360_PERSON_VIEW(P_EMPLOYEE_NUMBER => p_person_id,
                                  P_EFFECTIVE_DATE  => p_eff_date,
                                  P_BUSINESS_GROUP_ID => to_number(p_bg_id),
                                  p_tp_site_id => p_tp_id,
                                  p_trxn_id => p_txn_id);

resultout := 'COMPLETE';
exception
when OTHERS then
 resultout := 'FAILED';

end;

end HR_360_MESSAGE;

/
