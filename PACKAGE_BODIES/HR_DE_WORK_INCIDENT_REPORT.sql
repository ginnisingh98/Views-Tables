--------------------------------------------------------
--  DDL for Package Body HR_DE_WORK_INCIDENT_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_DE_WORK_INCIDENT_REPORT" AS
  /* $Header: pedewinr.pkb 115.8 2002/11/26 16:33:37 jahobbs noship $ */
  --
  --
  -- Outputs work incidents.
  --
  PROCEDURE run_report
  (errbuf	       OUT NOCOPY VARCHAR2
  ,retcode	       OUT NOCOPY VARCHAR2
  ,p_business_group_id  IN NUMBER
  ,p_from_date	        IN VARCHAR2
  ,p_to_date 	        IN VARCHAR2) IS
    --
    --
    -- Cursor to return all work incident records between two dates.
    --
    CURSOR C_report
      (p_business_group_id NUMBER
      ,p_from_date         VARCHAR2
      ,p_to_date           VARCHAR2) IS
      SELECT
        distinct(wi.incident_id) INCIDENT_ID,
        wi.incident_date INCIDENT_DATE_ORD,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','PERSON_ID'),40,' ') PER, wi.PERSON_ID,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','LAST_NAME'),40,' ') LAN, wi.LAST_NAME,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','FIRST_NAME'),40,' ') FAN, wi.FIRST_NAME,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','DATE_OF_BIRTH'),40,' ') DOB, fnd_date.date_to_chardate(wi.DATE_OF_BIRTH) date_of_birth,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','DATE_OF_INC'),40,' ') IND, fnd_date.date_to_chardate(wi.INCIDENT_DATE) incident_date,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','INC_REF'),40,' ') REF, wi.INCIDENT_REFERENCE,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','GENDER'),40,' ') GEN, hr_general.decode_lookup('SEX',wi.GENDER) gender,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','SOC_INS_NO'),40,' ') SIN, wi.SOCIAL_INSURANCE_NUMBER,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','MAR_STATUS'),40,' ') MAR, hr_general.decode_lookup('MAR_STATUS', wi.MARITAL_STATUS) marital_status,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','NATIONALITY'),40,' ') NAT, hr_general.decode_lookup('NATIONALITY', wi.NATIONALITY) nationality,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','ASSGT_ORG_NAME'),40,' ') ORG, wi.ASSGT_ORG_NAME ,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','BETRIEBS'),40,' ') BET, wi.BETRIEBSNUMBER ,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','SUP_OFF_NAME'),40,' ') SUP, rtrim(substr(wi.SUP_OFF_NAME,1,240)) SUP_OFF,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','LIAB_PROV_NAME'),40,' ') LIP, rtrim(substr(wi.LIAB_PROV_NAME, 1, 240)) LIAB_PROV,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','MEM_NO'),40,' ') MEM, substr(wi.MEMBERSHIP_NO,1,20) MEM_NO,
        substr(wi.loc_id_of_liab_prov,1,20) LOC_ID,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','ADD1'),40,' ') AD1, rtrim(substr(wi.ADDRESS_LINE_1, 1, 240)) ADD1,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','ADD2'),40,' ') AD2, rtrim(substr(wi.ADDRESS_LINE_2, 1, 240)) ADD2,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','ADD3'),40,' ') AD3, rtrim(substr(wi.ADDRESS_LINE_3, 1, 240)) ADD3,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','TOWN'),40,' ') TOW, rtrim(substr(wi.TOWN_OR_CITY, 1, 150)) TOWN,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','COUNTRY'),40,' ') CTY, rtrim(substr(wi.COUNTRY, 1, 100))   CTRY,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','POSTAL'),40,' ') POC, substr(wi.POSTAL_CODE, 1, 20) POST,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','BODY_PART'),40,' ') BOD, wi.BODY_PART,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','INJURY_TYPE'),40,' ') INJ, hr_general.decode_lookup('INJURY_TYPE', wi.INJURY_TYPE) injury_type,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','DOC_NAME'),40, ' ') DOC, wi.DOCTOR_NAME,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','INC_TYPE'),40,' ') INT, wi.D_INCIDENT_TYPE,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','HOSP_DETAILS'),40,' ') HOS, wi.HOSPITAL_DETAILS,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','INC_TIME'),40,' ') INM, wi.INCIDENT_TIME,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','INC_LOC'),40,' ') LOC, wi.LOCATION_OF_INCIDENT,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','REM_ACTION'),40,' ') REA, wi.REMEDIAL_HS_ACTION,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','CHILD'),40,' ') NOC, wi.NO_OF_CHILDREN,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','JOB'),40,' ') JOB, wi.JOB_TYPE,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','JOB_START_DT'),40,' ') JST, fnd_date.date_to_chardate(fnd_date.canonical_to_date(wi.JOB_START_DATE)) job_start_date,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','COMP_PART'),40,' ') CMP, wi.PART_OF_COMPANY,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','LOANED_EMP'),40,' ') LND, wi.D_LOANED_EMP,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','UNDERAGE'),40,' ') UND, wi.D_UNDERAGE,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','SUPER_EMP'),40,' ') SEM, wi.SUPERVISING_EMPLOYEE,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','REL_TO_OWNER'),40,' ') REL, wi.D_RELATION,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','DUR_PAY_ENT'),40,' ') DUR, fnd_date.date_to_chardate(fnd_date.canonical_to_date(wi.DUR_OF_PAYMENT_ENT)) dur_of_payment_ent,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','DT_START'),40,' ') DTS, fnd_date.date_to_chardate(fnd_date.canonical_to_date(wi.DATE_OF_STOPPING_WORK)) date_of_stopping_work,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','DT_STOP'),40,' ') DTE, fnd_date.date_to_chardate(fnd_date.canonical_to_date(wi.DATE_OF_RESUMING_WORK)) date_of_resuming_work,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','1_DOC_ADDR'),40,' ') FAD, wi.ADDR_OF_DOC_FIRST_CON,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','ADD_DOC'),40,' ') ADO, wi.ADDR_OF_CURR_DOC,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','WT_START'),40,' ') WTS, wi.START_OF_WORK_TIME,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','WT_END'),40,' ') WTE, wi.END_OF_WORK_TIME,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','MK_MACH'),40,' ') MKM, wi.MAKE_OF_MACHINE,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','TP_MACH'),40,' ') TYM, wi.TYPE_OF_MACHINE,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','DT_MACH'),40,' ') DTM, fnd_date.date_to_chardate(fnd_date.canonical_to_date(wi.DATE_OF_MACHINE_BUILD)) date_of_machine_build,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','TECH_SAFE'),40,' ') TES, wi.TECHNICAL_SAFETY_ADV,
        rpad(hr_general.decode_lookup('DE_REPORT_LABELS','PERS_SAFE'),40,' ') PES, wi.PERSONAL_SAFETY_ADV
      FROM  hr_de_work_incidents_report wi
           ,per_people_f                per
      WHERE wi.person_id            = per.person_id AND
           per.business_group_id   = p_business_group_id AND
           wi.incident_date BETWEEN per.effective_start_date
                                 AND per.effective_end_date AND
           wi.incident_date BETWEEN fnd_date.canonical_to_date(p_from_date)
                                 AND fnd_date.canonical_to_date(p_to_date)
      ORDER BY incident_date_ord, wi.person_id;
    --
    --
    -- Local Variables.
    --
    l_report varchar2(2000);
    --
  BEGIN
    --
    INSERT INTO fnd_sessions
    (session_id
    ,effective_date)
    VALUES
    (userenv('sessionid')
    ,sysdate);
    --
    --
    --
    --  Print titles on 1st page
    --
    fnd_file.new_line(fnd_file.output, 12);
    fnd_file.put_line(fnd_file.output, '**********************************************************');
    fnd_file.put_line(fnd_file.output, LPAD(hr_general.decode_lookup('DE_REPORT_LABELS','WI_REP_TITLE'), 40, ' '));
    fnd_file.put_line(fnd_file.output, '**********************************************************');
    fnd_file.put_line(fnd_file.output, LPAD(hr_general.decode_lookup('DE_REPORT_LABELS','DT_FROM'), 28, ' ') || ' : '
                                       || fnd_date.date_to_chardate(fnd_date.canonical_to_date(p_from_date)));
    fnd_file.put_line(fnd_file.output, LPAD(hr_general.decode_lookup('DE_REPORT_LABELS','DT_TO'), 28, ' ') || ' : '
                                       || fnd_date.date_to_chardate(fnd_date.canonical_to_date(p_to_date)));
    fnd_file.new_line(fnd_file.output, 45);
    --
    --
    -- Loop through all work incidents between the two dates.
    --
    FOR C_rec IN C_report(p_business_group_id, p_from_date, p_to_date) LOOP
      fnd_file.put_line(fnd_file.output, '----------------------------------------------------------------------------------');
      fnd_file.put(fnd_file.output, C_rec.LAN);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.LAST_NAME);
      fnd_file.put(fnd_file.output, C_rec.FAN);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.FIRST_NAME);
      fnd_file.put(fnd_file.output, C_rec.REF);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.INCIDENT_REFERENCE);
      fnd_file.put(fnd_file.output, C_rec.IND);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.INCIDENT_DATE);
      fnd_file.put(fnd_file.output, C_rec.DOB);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.DATE_OF_BIRTH);
      fnd_file.put(fnd_file.output, C_rec.GEN);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.GENDER);
      fnd_file.put(fnd_file.output, C_rec.SIN);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.SOCIAL_INSURANCE_NUMBER);
      fnd_file.put(fnd_file.output, C_rec.MAR);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.MARITAL_STATUS);
      fnd_file.put(fnd_file.output, C_rec.NAT);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.NATIONALITY);
      fnd_file.put(fnd_file.output, C_rec.ORG);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.ASSGT_ORG_NAME);
      fnd_file.put(fnd_file.output, C_rec.BET);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.BETRIEBSNUMBER);
      fnd_file.put(fnd_file.output, C_rec.SUP);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.SUP_OFF);
      fnd_file.put(fnd_file.output, C_rec.LIP);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.LIAB_PROV);
      fnd_file.put(fnd_file.output, C_rec.MEM);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.MEM_NO);
      fnd_file.put(fnd_file.output, C_rec.AD1);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.ADD1);
      fnd_file.put(fnd_file.output, C_rec.AD2);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.ADD2);
      fnd_file.put(fnd_file.output, C_rec.AD3);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.ADD3);
      fnd_file.put(fnd_file.output, C_rec.TOW);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.TOWN);
      fnd_file.put(fnd_file.output, C_rec.CTY);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.CTRY);
      fnd_file.put(fnd_file.output, C_rec.POC);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.POST);
      fnd_file.put(fnd_file.output, C_rec.BOD);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.BODY_PART);
      fnd_file.put(fnd_file.output, C_rec.INJ);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.INJURY_TYPE);
      fnd_file.put(fnd_file.output, C_rec.DOC);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.DOCTOR_NAME);
      fnd_file.put(fnd_file.output, C_rec.INT);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.D_INCIDENT_TYPE);
      fnd_file.put(fnd_file.output, C_rec.HOS);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.HOSPITAL_DETAILS);
      fnd_file.put(fnd_file.output, C_rec.INM);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.INCIDENT_TIME);
      fnd_file.put(fnd_file.output, C_rec.LOC);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.LOCATION_OF_INCIDENT);
      fnd_file.put(fnd_file.output, C_rec.REA);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.REMEDIAL_HS_ACTION);
      fnd_file.put(fnd_file.output, C_rec.NOC);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.NO_OF_CHILDREN);
      fnd_file.put(fnd_file.output, C_rec.JOB);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.JOB_TYPE);
      fnd_file.put(fnd_file.output, C_rec.JST);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.JOB_START_DATE);
      fnd_file.put(fnd_file.output, C_rec.CMP);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.PART_OF_COMPANY);
      fnd_file.put(fnd_file.output, C_rec.LND);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.D_LOANED_EMP);
      fnd_file.put(fnd_file.output, C_rec.UND);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.D_UNDERAGE);
      fnd_file.put(fnd_file.output, C_rec.SEM);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.SUPERVISING_EMPLOYEE);
      fnd_file.put(fnd_file.output, C_rec.REL);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.D_RELATION);
      fnd_file.put(fnd_file.output, C_rec.DUR);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.DUR_OF_PAYMENT_ENT);
      fnd_file.put(fnd_file.output, C_rec.DTS);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.DATE_OF_STOPPING_WORK);
      fnd_file.put(fnd_file.output, C_rec.DTE);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.DATE_OF_RESUMING_WORK);
      fnd_file.put(fnd_file.output, C_rec.FAD);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.ADDR_OF_DOC_FIRST_CON);
      fnd_file.put(fnd_file.output, C_rec.ADO);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.ADDR_OF_CURR_DOC);
      fnd_file.put(fnd_file.output, C_rec.WTS);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.START_OF_WORK_TIME);
      fnd_file.put(fnd_file.output, C_rec.WTE);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.END_OF_WORK_TIME);
      fnd_file.put(fnd_file.output, C_rec.MKM);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.MAKE_OF_MACHINE);
      fnd_file.put(fnd_file.output, C_rec.TYM);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.TYPE_OF_MACHINE);
      fnd_file.put(fnd_file.output, C_rec.DTM);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.DATE_OF_MACHINE_BUILD);
      fnd_file.put(fnd_file.output, C_rec.TES);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.TECHNICAL_SAFETY_ADV);
      fnd_file.put(fnd_file.output, C_rec.PES);   fnd_file.put(fnd_file.output, ' : ');
      fnd_file.put_line(fnd_file.output, C_rec.PERSONAL_SAFETY_ADV);
      fnd_file.put_line(fnd_file.output, '----------------------------------------------------------------------------------');
      --
      --
      -- An A4 page has 62 lines. As 50 lines have been printed, Print 12 blank lines so that
      -- new record shows on a new page.
      --
      fnd_file.new_line(fnd_file.output, 12);
    END LOOP;
  END run_report;
END hr_de_work_incident_report;

/
