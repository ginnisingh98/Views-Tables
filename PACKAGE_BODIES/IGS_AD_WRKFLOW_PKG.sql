--------------------------------------------------------
--  DDL for Package Body IGS_AD_WRKFLOW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_WRKFLOW_PKG" AS
/* $Header: IGSADC6B.pls 120.3 2006/05/26 07:21:04 pfotedar ship $ */

PROCEDURE   Extract_Applications
                       (  errbuf OUT NOCOPY VARCHAR2,
                          retcode OUT NOCOPY NUMBER ,
			  p_person_id          		IN   hz_parties.party_id%TYPE,
                          p_person_id_group             IN   igs_pe_prsid_grp_mem_all.group_id%TYPE,
                          p_calendar_details    	IN   VARCHAR2,
                          p_apc  			IN   VARCHAR2,
			  p_appl_type			IN   VARCHAR2,
			  p_prog_code			IN   VARCHAR2,
			  p_location			IN   VARCHAR2,
			  p_att_type			IN   VARCHAR2,
			  p_att_mode			IN   VARCHAR2,
			  p_appl_no_calendar		IN   VARCHAR2,
			  p_appl_range			IN   VARCHAR2
			) IS

 l_appl_exist VARCHAR2(1);
 l_user_id NUMBER;
 l_per_num hz_parties.party_number%type;
 l_per_num1 hz_parties.party_number%type;
 l_person_id NUMBER;
 l_user_name VARCHAR2(100);
 l_full_name VARCHAR2(1000);
 l_count number := 0;

 l_adm_cal varchar2(10) := RTRIM(SUBSTR(p_calendar_details, 23, 10));
 l_acad_cal varchar2(10):= RTRIM(SUBSTR(p_calendar_details,1,10));
 l_acad_cal_seq_num number := IGS_GE_NUMBER.TO_NUM(SUBSTR(p_calendar_details,14,6));
 l_adm_cal_seq_num number :=IGS_GE_NUMBER.TO_NUM(SUBSTR(p_calendar_details,37,6));
 l_adm_cat VARCHAR2(10) := RTRIM(SUBSTR(p_apc,1, 10));
 l_adm_proc_type varchar2(15) := RTRIM(SUBSTR(p_apc, 11, 30));
 l_appl_type varchar2(30) := RTRIM(SUBSTR(p_appl_type, 1, 30));


/*  No program parameter has been provided,include application without calendar is YES and calendar range is CURRENT */
     Cursor c_incom_appl_nopgm_curr_anc IS
	Select aa.person_id
	From IGS_SS_ADM_APPL_STG aa
	Where
	((aa.person_id = p_person_id AND p_person_id IS NOT NULL) OR (p_person_id is NULL))
	AND (p_person_id_group IS NOT NULL AND
	aa.person_id IN (SELECT person_id
                 FROM igs_pe_prsid_grp_mem pgm
                 WHERE pgm.group_id = nvl(p_person_id_group, pgm.group_id)
		 And SYSDATE BETWEEN nvl(START_DATE, SYSDATE) AND nvl(END_DATE, SYSDATE))
                 OR
                (p_person_id_group is null))
	AND ((aa.ACAD_CAL_TYPE= l_acad_cal) AND (aa.ACAD_CAL_SEQ_NUMBER= l_acad_cal_seq_num)
	AND (aa.ADM_CAL_TYPE= l_adm_cal) AND (aa.ADM_CAL_SEQ_NUMBER= l_adm_cal_seq_num))
        AND (((aa.ADMISSION_CAT = l_adm_cat) AND (aa.S_ADM_PROCESS_TYPE = l_adm_proc_type)
   	AND (p_apc IS NOT NULL)) OR (p_apc is NULL))
	AND ((aa.ADMISSION_APPLICATION_TYPE = p_appl_type AND p_appl_type IS NOT NULL ) OR (p_appl_type IS NULL))
	AND aa.APP_SOURCE_ID IN ( select code_id from igs_ad_code_classes where CLASS = 'SYS_APPL_SOURCE' and system_status = 'WEB_APPL' AND CLASS_TYPE_CODE='ADM_CODE_CLASSES')
	Group BY aa.person_id
    UNION
        Select aa.person_id
        From IGS_SS_ADM_APPL_STG aa
	Where
	((aa.person_id = p_person_id AND p_person_id IS NOT NULL) OR (p_person_id is NULL))  AND
        (p_person_id_group IS NOT NULL AND
        aa.person_id IN (SELECT person_id
                 FROM igs_pe_prsid_grp_mem pgm
                 WHERE pgm.group_id = nvl(p_person_id_group,pgm.group_id)
		 And SYSDATE BETWEEN nvl(START_DATE, SYSDATE) AND nvl(END_DATE, SYSDATE))
                 OR
                (p_person_id_group is null)) AND
	(aa.ACAD_CAL_TYPE IS NULL And aa.ACAD_CAL_SEQ_NUMBER IS NULL And aa.ADM_CAL_TYPE IS NULL And aa.ADM_CAL_SEQ_NUMBER IS NULL)
        AND (((aa.ADMISSION_CAT = l_adm_cat) AND (aa.S_ADM_PROCESS_TYPE = l_adm_proc_type)
        AND (p_apc IS NOT NULL)) OR (p_apc is NULL))
	AND ((aa.ADMISSION_APPLICATION_TYPE = p_appl_type AND p_appl_type IS NOT NULL ) OR (p_appl_type IS NULL))
	AND aa.APP_SOURCE_ID IN ( select code_id from igs_ad_code_classes where CLASS = 'SYS_APPL_SOURCE' and system_status = 'WEB_APPL' AND CLASS_TYPE_CODE='ADM_CODE_CLASSES')
    Group BY aa.person_id;

/*  No program parameter has been provided,include application without calendar is NO and calendar range is CURRENT */
     Cursor c_incom_appl_nopgm_curr IS
	Select aa.person_id
	From IGS_SS_ADM_APPL_STG aa
	Where ((aa.person_id = p_person_id AND p_person_id IS NOT NULL) OR (p_person_id is NULL))
        AND (p_person_id_group IS NOT NULL AND
        aa.person_id IN (SELECT person_id
                 FROM igs_pe_prsid_grp_mem pgm
                 WHERE pgm.group_id = nvl(p_person_id_group,pgm.group_id)
		 And SYSDATE BETWEEN nvl(START_DATE, SYSDATE) AND nvl(END_DATE, SYSDATE))
                 OR
                (p_person_id_group is null))
	AND ((aa.ACAD_CAL_TYPE= l_acad_cal) AND (aa.ACAD_CAL_SEQ_NUMBER= l_acad_cal_seq_num)
	AND (aa.ADM_CAL_TYPE= l_adm_cal) AND (aa.ADM_CAL_SEQ_NUMBER= l_adm_cal_seq_num))
        AND (((aa.ADMISSION_CAT = l_adm_cat) AND (aa.S_ADM_PROCESS_TYPE = l_adm_proc_type)
        AND (p_apc IS NOT NULL)) OR (p_apc is NULL))
	AND ((aa.ADMISSION_APPLICATION_TYPE = p_appl_type AND p_appl_type IS NOT NULL ) OR (p_appl_type IS NULL))
	AND aa.APP_SOURCE_ID IN ( select code_id from igs_ad_code_classes where CLASS = 'SYS_APPL_SOURCE' and system_status = 'WEB_APPL' AND CLASS_TYPE_CODE='ADM_CODE_CLASSES')
    Group BY aa.person_id;

/*  Program parameter has been provided,include application without calendar is YES and calendar range is CURRENT */
     Cursor c_incom_appl_pgm_curr_anc IS
        Select aa.person_id
        From IGS_SS_ADM_APPL_STG aa, IGS_SS_APP_PGM_STG aap
        Where
	aap.SS_ADM_APPL_ID = aa.SS_ADM_APPL_ID(+)
        And ((aa.person_id = p_person_id AND p_person_id IS NOT NULL) OR (p_person_id is NULL))
        AND (p_person_id_group IS NOT NULL AND
        aa.person_id IN (SELECT person_id
                 FROM igs_pe_prsid_grp_mem pgm
                 WHERE pgm.group_id = nvl(p_person_id_group,pgm.group_id)
		 And SYSDATE BETWEEN nvl(START_DATE, SYSDATE) AND nvl(END_DATE, SYSDATE))
                 OR
                (p_person_id_group is null))
        AND ((aa.ACAD_CAL_TYPE= l_acad_cal) AND (aa.ACAD_CAL_SEQ_NUMBER= l_acad_cal_seq_num)
        AND (aa.ADM_CAL_TYPE= l_adm_cal) AND (aa.ADM_CAL_SEQ_NUMBER= l_adm_cal_seq_num))
        AND (((aa.ADMISSION_CAT = l_adm_cat) AND (aa.S_ADM_PROCESS_TYPE = l_adm_proc_type)
        AND (p_apc IS NOT NULL)) OR (p_apc is NULL))
        AND ((aa.ADMISSION_APPLICATION_TYPE = p_appl_type AND p_appl_type IS NOT NULL ) OR (p_appl_type IS NULL))
        AND ((aap.NOMINATED_COURSE_CD = p_prog_code AND p_prog_code IS NOT NULL ) OR (p_prog_code IS NULL))
        AND ((aap.LOCATION_CD = p_location AND p_location IS NOT NULL ) OR (p_location IS NULL))
        AND ((aap.ATTENDANCE_TYPE = p_att_type AND p_att_type IS NOT NULL ) OR (p_att_type IS NULL))
        AND ((aap.ATTENDANCE_MODE = p_att_mode AND p_att_mode IS NOT NULL ) OR (p_att_mode IS NULL))
        AND aa.APP_SOURCE_ID IN (select code_id from igs_ad_code_classes where CLASS = 'SYS_APPL_SOURCE' and system_status = 'WEB_APPL' AND CLASS_TYPE_CODE='ADM_CODE_CLASSES')
	Group BY aa.person_id
    UNION
        Select aa.person_id
        From IGS_SS_ADM_APPL_STG aa
        Where
        ((aa.person_id = p_person_id AND p_person_id IS NOT NULL) OR (p_person_id is NULL))
        AND (p_person_id_group IS NOT NULL AND
        aa.person_id IN (SELECT person_id
                 FROM igs_pe_prsid_grp_mem pgm
                 WHERE pgm.group_id = nvl(p_person_id_group,pgm.group_id)
		 And SYSDATE BETWEEN nvl(START_DATE, SYSDATE) AND nvl(END_DATE, SYSDATE))
                 OR
                (p_person_id_group is null))
	AND (aa.ACAD_CAL_TYPE IS NULL And aa.ACAD_CAL_SEQ_NUMBER IS NULL And aa.ADM_CAL_TYPE IS NULL And aa.ADM_CAL_SEQ_NUMBER IS NULL)
	AND (((aa.ADMISSION_CAT = l_adm_cat) AND (aa.S_ADM_PROCESS_TYPE = l_adm_proc_type)
	AND (p_apc IS NOT NULL)) OR (p_apc is NULL))
        AND ((aa.ADMISSION_APPLICATION_TYPE = p_appl_type AND p_appl_type IS NOT NULL ) OR (p_appl_type IS NULL))
        AND aa.APP_SOURCE_ID IN ( select code_id from igs_ad_code_classes where CLASS = 'SYS_APPL_SOURCE' and system_status = 'WEB_APPL' AND CLASS_TYPE_CODE='ADM_CODE_CLASSES')
    	Group BY aa.person_id;

/*  Program parameter has been provided,include application without calendar is NO and calendar range is CURRENT */
     Cursor c_incom_appl_pgm_curr IS
        Select aa.person_id
        From IGS_SS_ADM_APPL_STG aa, IGS_SS_APP_PGM_STG aap
        Where aap.SS_ADM_APPL_ID = aa.SS_ADM_APPL_ID(+)
        And ((aa.person_id = p_person_id AND p_person_id IS NOT NULL) OR (p_person_id is NULL))
        AND (p_person_id_group IS NOT NULL AND
        aa.person_id IN (SELECT person_id
                 FROM igs_pe_prsid_grp_mem pgm
                 WHERE pgm.group_id = nvl(p_person_id_group,pgm.group_id)
		 And SYSDATE BETWEEN nvl(START_DATE, SYSDATE) AND nvl(END_DATE, SYSDATE))
                 OR
                (p_person_id_group is null))
	AND ((aa.ACAD_CAL_TYPE= l_acad_cal) AND (aa.ACAD_CAL_SEQ_NUMBER= l_acad_cal_seq_num)
	AND (aa.ADM_CAL_TYPE= l_adm_cal) AND (aa.ADM_CAL_SEQ_NUMBER= l_adm_cal_seq_num))
	AND (((aa.ADMISSION_CAT = l_adm_cat) AND (aa.S_ADM_PROCESS_TYPE = l_adm_proc_type)
	AND (p_apc IS NOT NULL)) OR (p_apc is NULL))
        AND ((aa.ADMISSION_APPLICATION_TYPE = p_appl_type AND p_appl_type IS NOT NULL ) OR (p_appl_type IS NULL))
        AND ((aap.NOMINATED_COURSE_CD = p_prog_code AND p_prog_code IS NOT NULL ) OR (p_prog_code IS NULL))
        AND ((aap.LOCATION_CD = p_location AND p_location IS NOT NULL ) OR (p_location IS NULL))
        AND ((aap.ATTENDANCE_TYPE = p_att_type AND p_att_type IS NOT NULL ) OR (p_att_type IS NULL))
        AND ((aap.ATTENDANCE_MODE = p_att_mode AND p_att_mode IS NOT NULL ) OR (p_att_mode IS NULL))
        AND aa.APP_SOURCE_ID IN (select code_id from igs_ad_code_classes where CLASS = 'SYS_APPL_SOURCE' and system_status = 'WEB_APPL' AND CLASS_TYPE_CODE='ADM_CODE_CLASSES')
    Group BY aa.person_id;

/*  No program parameter has been provided,include application without calendar is YES and calendar range is CURRFUTURE */
     Cursor c_incom_appl_nopgm_cnf_anc IS
        Select aa.person_id
        From IGS_SS_ADM_APPL_STG aa
        Where
	((aa.person_id = p_person_id AND p_person_id IS NOT NULL) OR (p_person_id is NULL))
        AND (p_person_id_group IS NOT NULL
        AND aa.person_id IN (SELECT person_id
                 FROM igs_pe_prsid_grp_mem pgm
                 WHERE pgm.group_id = p_person_id_group
		 And SYSDATE BETWEEN nvl(START_DATE, SYSDATE) AND nvl(END_DATE, SYSDATE))
                 OR
                (p_person_id_group is null))
	AND ((aa.ACAD_CAL_TYPE= l_acad_cal) AND (aa.ACAD_CAL_SEQ_NUMBER= l_acad_cal_seq_num)
        AND (aa.ADM_CAL_TYPE= l_adm_cal) AND (aa.ADM_CAL_SEQ_NUMBER= l_adm_cal_seq_num))
        AND (((aa.ADMISSION_CAT = l_adm_cat) AND (aa.S_ADM_PROCESS_TYPE = l_adm_proc_type)
        AND (p_apc IS NOT NULL)) OR (p_apc is NULL))
        AND ((aa.ADMISSION_APPLICATION_TYPE = p_appl_type AND p_appl_type IS NOT NULL ) OR (p_appl_type IS NULL))
        AND aa.APP_SOURCE_ID IN ( select code_id from igs_ad_code_classes where CLASS = 'SYS_APPL_SOURCE' and system_status = 'WEB_APPL' AND CLASS_TYPE_CODE='ADM_CODE_CLASSES')
	UNION
	Select aa.person_id
        From IGS_SS_ADM_APPL_STG aa
        Where
	((aa.person_id = p_person_id AND p_person_id IS NOT NULL) OR (p_person_id is NULL))
        AND (p_person_id_group IS NOT NULL
        AND aa.person_id IN (SELECT person_id
                 FROM igs_pe_prsid_grp_mem pgm
                 WHERE pgm.group_id = p_person_id_group
		 And SYSDATE BETWEEN nvl(START_DATE, SYSDATE) AND nvl(END_DATE, SYSDATE))
                 OR
                (p_person_id_group is null))
	AND (((aa.ADMISSION_CAT = l_adm_cat) AND (aa.S_ADM_PROCESS_TYPE = l_adm_proc_type)
	AND (p_apc IS NOT NULL)) OR (p_apc is NULL))
        AND ((aa.ADMISSION_APPLICATION_TYPE = p_appl_type
   	AND p_appl_type IS NOT NULL ) OR (p_appl_type IS NULL))
 	AND ((aa.acad_cal_type,aa.acad_cal_seq_number,aa.adm_cal_type, aa.adm_cal_seq_number) in
   	(
   	select
           r.sup_cal_type,
           r.sup_ci_sequence_number,
           r.sub_cal_type,
           r.sub_ci_sequence_number
   	from
           igs_ca_inst_rel r
   	, igs_ca_type t1
   	, igs_ca_type t2
   	, igs_ca_inst acad
   	, igs_ca_inst adm
   	where
        sup_cal_type = t1.cal_type
   	and t1.s_cal_cat = 'ACADEMIC'
   	and sub_cal_type = t2.cal_type
   	and t2.s_cal_cat = 'ADMISSION'
   	and sup_cal_type = acad.cal_type
   	and sup_ci_sequence_number = acad.sequence_number
   	and sub_cal_type = adm.cal_type
   	and sub_ci_sequence_number = adm.sequence_number
   	and acad.start_dt > ( 	select ci.start_dt
			      	from igs_ca_inst ci
 			      	where ci.cal_type = l_acad_cal
 			      	and ci.sequence_number = l_acad_cal_seq_num)
   	and adm.start_dt > ( 	select ci.start_dt
 				from igs_ca_inst ci
 			   	where ci.cal_type = l_adm_cal
 				and ci.sequence_number = l_adm_cal_seq_num)
  	 )
        )
        AND aa.APP_SOURCE_ID IN ( select code_id from igs_ad_code_classes where CLASS = 'SYS_APPL_SOURCE' and system_status = 'WEB_APPL' AND CLASS_TYPE_CODE='ADM_CODE_CLASSES')
	Group BY aa.person_id
    UNION
        Select aa.person_id
        From IGS_SS_ADM_APPL_STG aa
        Where
	((aa.person_id = p_person_id AND p_person_id IS NOT NULL) OR (p_person_id is NULL))
        AND (p_person_id_group IS NOT NULL
        AND aa.person_id IN (SELECT person_id
                 FROM igs_pe_prsid_grp_mem pgm
                 WHERE pgm.group_id = p_person_id_group
		 And SYSDATE BETWEEN nvl(START_DATE, SYSDATE) AND nvl(END_DATE, SYSDATE))
                 OR
                (p_person_id_group is null))
	AND (aa.ACAD_CAL_TYPE IS NULL And aa.ACAD_CAL_SEQ_NUMBER IS NULL And aa.ADM_CAL_TYPE IS NULL And aa.ADM_CAL_SEQ_NUMBER IS NULL)
        AND (((aa.ADMISSION_CAT = l_adm_cat) AND (aa.S_ADM_PROCESS_TYPE = l_adm_proc_type)
        AND (p_apc IS NOT NULL)) OR (p_apc is NULL))
        AND ((aa.ADMISSION_APPLICATION_TYPE = p_appl_type AND p_appl_type IS NOT NULL ) OR (p_appl_type IS NULL))
        AND aa.APP_SOURCE_ID IN ( select code_id from igs_ad_code_classes where CLASS = 'SYS_APPL_SOURCE' and system_status = 'WEB_APPL' AND CLASS_TYPE_CODE='ADM_CODE_CLASSES')
        Group BY aa.person_id;

/*  No program parameter has been provided,include application without calendar is NO and calendar range is CURRFUTURE */
     Cursor c_incom_appl_nopgm_cnf IS
        Select aa.person_id
        From IGS_SS_ADM_APPL_STG aa
        Where ((aa.person_id = p_person_id AND p_person_id IS NOT NULL) OR (p_person_id is NULL))
        AND (p_person_id_group IS NOT NULL AND
        aa.person_id IN (SELECT person_id
                 FROM igs_pe_prsid_grp_mem pgm
                 WHERE pgm.group_id = p_person_id_group
		 And SYSDATE BETWEEN nvl(START_DATE, SYSDATE) AND nvl(END_DATE, SYSDATE))
                 OR
                (p_person_id_group is null))
        AND ((aa.ACAD_CAL_TYPE= l_acad_cal) AND (aa.ACAD_CAL_SEQ_NUMBER= l_acad_cal_seq_num)
        AND (aa.ADM_CAL_TYPE= l_adm_cal) AND (aa.ADM_CAL_SEQ_NUMBER= l_adm_cal_seq_num))
        AND (((aa.ADMISSION_CAT = l_adm_cat) AND (aa.S_ADM_PROCESS_TYPE = l_adm_proc_type)
        AND (p_apc IS NOT NULL)) OR (p_apc is NULL))
        AND ((aa.ADMISSION_APPLICATION_TYPE = p_appl_type AND p_appl_type IS NOT NULL ) OR (p_appl_type IS NULL))
        AND aa.APP_SOURCE_ID IN ( select code_id from igs_ad_code_classes where CLASS = 'SYS_APPL_SOURCE' and system_status = 'WEB_APPL' AND CLASS_TYPE_CODE='ADM_CODE_CLASSES')
	Group BY aa.person_id
	UNION
	Select aa.person_id
        From IGS_SS_ADM_APPL_STG aa
        Where
	((aa.person_id = p_person_id AND p_person_id IS NOT NULL) OR (p_person_id is NULL))
        AND (p_person_id_group IS NOT NULL AND
        aa.person_id IN (SELECT person_id
                 FROM igs_pe_prsid_grp_mem pgm
                 WHERE pgm.group_id = p_person_id_group
		 And SYSDATE BETWEEN nvl(START_DATE, SYSDATE) AND nvl(END_DATE, SYSDATE))
                 OR
                (p_person_id_group is null))
        AND (((aa.ADMISSION_CAT = l_adm_cat) AND (aa.S_ADM_PROCESS_TYPE = l_adm_proc_type)
        AND (p_apc IS NOT NULL)) OR (p_apc is NULL))
        AND ((aa.ADMISSION_APPLICATION_TYPE = p_appl_type
   	AND p_appl_type IS NOT NULL ) OR (p_appl_type IS NULL))
 	AND ((aa.acad_cal_type,aa.acad_cal_seq_number,aa.adm_cal_type, aa.adm_cal_seq_number) in
   	(
   	select
           r.sup_cal_type,
           r.sup_ci_sequence_number,
           r.sub_cal_type,
           r.sub_ci_sequence_number
   	from
           igs_ca_inst_rel r
   	, igs_ca_type t1
   	, igs_ca_type t2
   	, igs_ca_inst acad
   	, igs_ca_inst adm
   	where
        sup_cal_type = t1.cal_type
   	and t1.s_cal_cat = 'ACADEMIC'
   	and sub_cal_type = t2.cal_type
   	and t2.s_cal_cat = 'ADMISSION'
   	and sup_cal_type = acad.cal_type
   	and sup_ci_sequence_number = acad.sequence_number
   	and sub_cal_type = adm.cal_type
   	and sub_ci_sequence_number = adm.sequence_number
   	and acad.start_dt > ( 	select ci.start_dt
			      	from igs_ca_inst ci
 			      	where ci.cal_type = l_acad_cal
 			      	and ci.sequence_number = l_acad_cal_seq_num)
   	and adm.start_dt > ( 	select ci.start_dt
 				from igs_ca_inst ci
 			   	where ci.cal_type = l_adm_cal
 				and ci.sequence_number = l_adm_cal_seq_num)
  	 )
        )
        AND aa.APP_SOURCE_ID IN ( select code_id from igs_ad_code_classes where CLASS = 'SYS_APPL_SOURCE' and system_status = 'WEB_APPL' AND CLASS_TYPE_CODE='ADM_CODE_CLASSES')
        Group BY aa.person_id;

/*  Program parameter has been provided,include application without calendar is YES and calendar range is CURRFUTURE */
     Cursor c_incom_appl_pgm_cnf_anc IS
        Select aa.person_id
        From IGS_SS_ADM_APPL_STG aa, IGS_SS_APP_PGM_STG aap
        Where
	aap.SS_ADM_APPL_ID = aa.SS_ADM_APPL_ID(+)
        And ((aa.person_id = p_person_id AND p_person_id IS NOT NULL) OR (p_person_id is NULL))
        AND (p_person_id_group IS NOT NULL AND
        aa.person_id IN (SELECT person_id
                 FROM igs_pe_prsid_grp_mem pgm
                 WHERE pgm.group_id = p_person_id_group
		 And SYSDATE BETWEEN nvl(START_DATE, SYSDATE) AND nvl(END_DATE, SYSDATE))
                 OR
                (p_person_id_group is null))
        AND ((aa.ACAD_CAL_TYPE= l_acad_cal) AND (aa.ACAD_CAL_SEQ_NUMBER= l_acad_cal_seq_num)
        AND (aa.ADM_CAL_TYPE= l_adm_cal) AND (aa.ADM_CAL_SEQ_NUMBER= l_adm_cal_seq_num))
        AND (((aa.ADMISSION_CAT = l_adm_cat) AND (aa.S_ADM_PROCESS_TYPE = l_adm_proc_type)
        AND (p_apc IS NOT NULL)) OR (p_apc is NULL))
        AND ((aa.ADMISSION_APPLICATION_TYPE = p_appl_type AND p_appl_type IS NOT NULL ) OR (p_appl_type IS NULL))
        AND ((aap.NOMINATED_COURSE_CD = p_prog_code AND p_prog_code IS NOT NULL ) OR (p_prog_code IS NULL))
        AND ((aap.LOCATION_CD = p_location AND p_location IS NOT NULL ) OR (p_location IS NULL))
        AND ((aap.ATTENDANCE_TYPE = p_att_type AND p_att_type IS NOT NULL ) OR (p_att_type IS NULL))
        AND ((aap.ATTENDANCE_MODE = p_att_mode AND p_att_mode IS NOT NULL ) OR (p_att_mode IS NULL))
        AND aa.APP_SOURCE_ID IN (select code_id from igs_ad_code_classes where CLASS = 'SYS_APPL_SOURCE' and system_status = 'WEB_APPL' AND CLASS_TYPE_CODE='ADM_CODE_CLASSES')
	Group BY aa.person_id
	UNION
	Select aa.person_id
        From IGS_SS_ADM_APPL_STG aa
        Where
	((aa.person_id = p_person_id AND p_person_id IS NOT NULL) OR (p_person_id is NULL))
        AND (p_person_id_group IS NOT NULL AND
        aa.person_id IN (SELECT person_id
                 FROM igs_pe_prsid_grp_mem pgm
                 WHERE pgm.group_id = p_person_id_group
		 And SYSDATE BETWEEN nvl(START_DATE, SYSDATE) AND nvl(END_DATE, SYSDATE))
                 OR
                (p_person_id_group is null))
        AND (((aa.ADMISSION_CAT = l_adm_cat) AND (aa.S_ADM_PROCESS_TYPE = l_adm_proc_type)
        AND (p_apc IS NOT NULL)) OR (p_apc is NULL))
        AND ((aa.ADMISSION_APPLICATION_TYPE = p_appl_type
   	AND p_appl_type IS NOT NULL ) OR (p_appl_type IS NULL))
 	AND ((aa.acad_cal_type,aa.acad_cal_seq_number,aa.adm_cal_type, aa.adm_cal_seq_number) in
   	(
   	select
           r.sup_cal_type,
           r.sup_ci_sequence_number,
           r.sub_cal_type,
           r.sub_ci_sequence_number
   	from
           igs_ca_inst_rel r
   	, igs_ca_type t1
   	, igs_ca_type t2
   	, igs_ca_inst acad
   	, igs_ca_inst adm
   	where
        sup_cal_type = t1.cal_type
   	and t1.s_cal_cat = 'ACADEMIC'
   	and sub_cal_type = t2.cal_type
   	and t2.s_cal_cat = 'ADMISSION'
   	and sup_cal_type = acad.cal_type
   	and sup_ci_sequence_number = acad.sequence_number
   	and sub_cal_type = adm.cal_type
   	and sub_ci_sequence_number = adm.sequence_number
   	and acad.start_dt > ( 	select ci.start_dt
			      	from igs_ca_inst ci
 			      	where ci.cal_type = l_acad_cal
 			      	and ci.sequence_number = l_acad_cal_seq_num)
   	and adm.start_dt > ( 	select ci.start_dt
 				from igs_ca_inst ci
 			   	where ci.cal_type = l_adm_cal
 				and ci.sequence_number = l_adm_cal_seq_num)
  	 )
        )
        AND aa.APP_SOURCE_ID IN ( select code_id from igs_ad_code_classes where CLASS = 'SYS_APPL_SOURCE' and system_status = 'WEB_APPL' AND CLASS_TYPE_CODE='ADM_CODE_CLASSES')
	Group BY aa.person_id
    UNION
        Select aa.person_id
        From IGS_SS_ADM_APPL_STG aa
        Where
        ((aa.person_id = p_person_id AND p_person_id IS NOT NULL) OR (p_person_id is NULL))
        AND (p_person_id_group IS NOT NULL AND
        aa.person_id IN (SELECT person_id
                 FROM igs_pe_prsid_grp_mem pgm
                 WHERE pgm.group_id = p_person_id_group
		 And SYSDATE BETWEEN nvl(START_DATE, SYSDATE) AND nvl(END_DATE, SYSDATE))
                 OR
                (p_person_id_group is null))
        AND (aa.ACAD_CAL_TYPE IS NULL And aa.ACAD_CAL_SEQ_NUMBER IS NULL And aa.ADM_CAL_TYPE IS NULL And aa.ADM_CAL_SEQ_NUMBER IS NULL)
        AND (((aa.ADMISSION_CAT = l_adm_cat) AND (aa.S_ADM_PROCESS_TYPE = l_adm_proc_type)
        AND (p_apc IS NOT NULL)) OR (p_apc is NULL))
        AND ((aa.ADMISSION_APPLICATION_TYPE = p_appl_type AND p_appl_type IS NOT NULL ) OR (p_appl_type IS NULL))
        AND aa.APP_SOURCE_ID IN ( select code_id from igs_ad_code_classes where CLASS = 'SYS_APPL_SOURCE' and system_status = 'WEB_APPL' AND CLASS_TYPE_CODE='ADM_CODE_CLASSES')
        Group BY aa.person_id;

/*  Program parameter has been provided,include application without calendar is YES and calendar range is CURRFUTURE */
     Cursor c_incom_appl_pgm_cnf IS
        Select aa.person_id
        From IGS_SS_ADM_APPL_STG aa, IGS_SS_APP_PGM_STG aap
        Where aap.SS_ADM_APPL_ID = aa.SS_ADM_APPL_ID(+)
        And ((aa.person_id = p_person_id AND p_person_id IS NOT NULL) OR (p_person_id is NULL))
        AND (p_person_id_group IS NOT NULL AND
        aa.person_id IN (SELECT person_id
                 FROM igs_pe_prsid_grp_mem pgm
                 WHERE pgm.group_id = p_person_id_group
		 And SYSDATE BETWEEN nvl(START_DATE, SYSDATE) AND nvl(END_DATE, SYSDATE))
                 OR
                (p_person_id_group is null))
        AND ((aa.ACAD_CAL_TYPE= l_acad_cal) AND (aa.ACAD_CAL_SEQ_NUMBER= l_acad_cal_seq_num)
        AND (aa.ADM_CAL_TYPE= l_adm_cal) AND (aa.ADM_CAL_SEQ_NUMBER= l_adm_cal_seq_num))
        AND (((aa.ADMISSION_CAT = l_adm_cat) AND (aa.S_ADM_PROCESS_TYPE = l_adm_proc_type)
        AND (p_apc IS NOT NULL)) OR (p_apc is NULL))
        AND ((aa.ADMISSION_APPLICATION_TYPE = p_appl_type AND p_appl_type IS NOT NULL ) OR (p_appl_type IS NULL))
        AND ((aap.NOMINATED_COURSE_CD = p_prog_code AND p_prog_code IS NOT NULL ) OR (p_prog_code IS NULL))
        AND ((aap.LOCATION_CD = p_location AND p_location IS NOT NULL ) OR (p_location IS NULL))
        AND ((aap.ATTENDANCE_TYPE = p_att_type AND p_att_type IS NOT NULL ) OR (p_att_type IS NULL))
        AND ((aap.ATTENDANCE_MODE = p_att_mode AND p_att_mode IS NOT NULL ) OR (p_att_mode IS NULL))
        AND aa.APP_SOURCE_ID IN (select code_id from igs_ad_code_classes where CLASS = 'SYS_APPL_SOURCE' and system_status = 'WEB_APPL' AND CLASS_TYPE_CODE='ADM_CODE_CLASSES')
	UNION
	Select aa.person_id
        From IGS_SS_ADM_APPL_STG aa
        Where
	((aa.person_id = p_person_id AND p_person_id IS NOT NULL) OR (p_person_id is NULL))
        AND (p_person_id_group IS NOT NULL AND
        aa.person_id IN (SELECT person_id
                 FROM igs_pe_prsid_grp_mem pgm
                 WHERE pgm.group_id = p_person_id_group
		 And SYSDATE BETWEEN nvl(START_DATE, SYSDATE) AND nvl(END_DATE, SYSDATE))
                 OR
                (p_person_id_group is null))
        AND (((aa.ADMISSION_CAT = l_adm_cat) AND (aa.S_ADM_PROCESS_TYPE = l_adm_proc_type)
        AND (p_apc IS NOT NULL)) OR (p_apc is NULL))
        AND ((aa.ADMISSION_APPLICATION_TYPE = p_appl_type
   	AND p_appl_type IS NOT NULL ) OR (p_appl_type IS NULL))
 	AND ((aa.acad_cal_type,aa.acad_cal_seq_number,aa.adm_cal_type, aa.adm_cal_seq_number) in
   	(
   	select
           r.sup_cal_type,
           r.sup_ci_sequence_number,
           r.sub_cal_type,
           r.sub_ci_sequence_number
   	from
           igs_ca_inst_rel r
   	, igs_ca_type t1
   	, igs_ca_type t2
   	, igs_ca_inst acad
   	, igs_ca_inst adm
   	where
        sup_cal_type = t1.cal_type
   	and t1.s_cal_cat = 'ACADEMIC'
   	and sub_cal_type = t2.cal_type
   	and t2.s_cal_cat = 'ADMISSION'
   	and sup_cal_type = acad.cal_type
   	and sup_ci_sequence_number = acad.sequence_number
   	and sub_cal_type = adm.cal_type
   	and sub_ci_sequence_number = adm.sequence_number
   	and acad.start_dt > ( 	select ci.start_dt
			      	from igs_ca_inst ci
 			      	where ci.cal_type = l_acad_cal
 			      	and ci.sequence_number = l_acad_cal_seq_num)
   	and adm.start_dt > ( 	select ci.start_dt
 				from igs_ca_inst ci
 			   	where ci.cal_type = l_adm_cal
 				and ci.sequence_number = l_adm_cal_seq_num)
  	 )
        )
        AND aa.APP_SOURCE_ID IN ( select code_id from igs_ad_code_classes where CLASS = 'SYS_APPL_SOURCE' and system_status = 'WEB_APPL' AND CLASS_TYPE_CODE='ADM_CODE_CLASSES')
	Group BY aa.person_id;


 CURSOR cur_user(cp_person_id igs_ss_adm_appl_stg.person_id%TYPE) IS
   SELECT user_id, user_name, description
   FROM   FND_USER
   WHERE  person_party_id = cp_person_id ;

 CURSOR c_per_num IS
   SELECT party_number
   FROM   HZ_PARTIES
   WHERE  party_id = p_person_id ;

 CURSOR c_per_num1(cp_person_id igs_ss_adm_appl_stg.person_id%TYPE) IS
   SELECT party_number
   FROM   HZ_PARTIES
   WHERE  party_id = cp_person_id ;

BEGIN

    -- The following code is added for disabling of OSS in R12.IGS.A - Bug 4955192
    igs_ge_gen_003.set_org_id(null);

    RETCODE := 0;
    ERRBUF  := NULL;

    FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_APP_APPNTF_PRMS');
    FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET ());

    OPEN c_per_num;
    FETCH c_per_num INTO l_per_num;
    CLOSE c_per_num;

    FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_APP_LG_PNUM');
    FND_MESSAGE.SET_TOKEN ('PNUM', l_per_num);
    FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET ());

    FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_APP_LG_PID_GRP');
    FND_MESSAGE.SET_TOKEN ('PGPID', p_person_id_group);
    FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET ());

    FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_LG_CL_DTLS');
    FND_MESSAGE.SET_TOKEN('CLDTLS', p_calendar_details);
    FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());

    FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_APP_LG_APC');
    FND_MESSAGE.SET_TOKEN ('APC', p_apc);
    FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET ());

    FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_LG_INAP_APPL_TYPE');
    FND_MESSAGE.SET_TOKEN ('APPLTYPE', p_appl_type);
    FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET ());

    FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_APP_LG_CRCD');
    FND_MESSAGE.SET_TOKEN ('CRCD', p_prog_code);
    FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET ());

    FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_LG_INAP_LOC');
    FND_MESSAGE.SET_TOKEN ('LOC', p_location);
    FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET ());

    FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_LG_INAP_ATT_TYPE');
    FND_MESSAGE.SET_TOKEN ('ATTTYPE', p_att_type);
    FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET ());

    FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_LG_INAP_ATT_MODE');
    FND_MESSAGE.SET_TOKEN ('ATTMODE', p_att_mode);
    FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET ());

    FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_LG_INAP_APPL_NC');
    FND_MESSAGE.SET_TOKEN ('APPLNOCAL', p_appl_no_calendar);
    FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET ());

    FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_LG_INAP_APPL_RANGE');
    FND_MESSAGE.SET_TOKEN ('APPLRNGE', p_appl_range);
    FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET ());
    FND_FILE.PUT_LINE (FND_FILE.LOG, '');
    FND_FILE.PUT_LINE (FND_FILE.LOG, '');

        IF (p_person_id IS NOT NULL AND p_person_id_group IS NOT NULL ) THEN

	  FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_NO_PERID_PERIDGRP');
          FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET ());

	ELSIF NVL( p_appl_range, 'CURRENT') = 'CURRFUTURE' THEN

		IF p_prog_code IS NULL THEN

			IF NVL(p_appl_no_calendar,'N') = 'Y' THEN

			 	l_count := 0;

	   			OPEN c_incom_appl_nopgm_cnf_anc;
				LOOP
				FETCH c_incom_appl_nopgm_cnf_anc INTO l_person_id;
				EXIT WHEN c_incom_appl_nopgm_cnf_anc%NOTFOUND;

		  	    	IF c_incom_appl_nopgm_cnf_anc%FOUND THEN
					l_count := l_count+1;

	  		    		OPEN cur_user(l_person_id);
	  		    		FETCH cur_user INTO l_user_id, l_user_name, l_full_name;

                        		IF cur_user%FOUND THEN

    					OPEN c_per_num1(l_person_id);
    					FETCH c_per_num1 INTO l_per_num1;
    					CLOSE c_per_num1;

					FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF1');
					FND_MESSAGE.SET_TOKEN ('PERSONNUM', l_per_num1);
					FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET());

                                		WF_Inform_Applicant_INAP(l_user_id, l_user_name, l_full_name);
					ELSE
				 	-- write in the log that no user_id exists in the FND_USER table for this person_id
                                	FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_USR_PER_INV_COMB');
					FND_MESSAGE.SET_TOKEN ('PERSONNUM', l_per_num1);
                                	FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());

                        		END IF;

                            		CLOSE cur_user;

				END IF; /* c_incom_appl_nopgm_cnf_anc */
				END LOOP;

                                IF l_count = 0 THEN
                                -- write in the log file that no record exists
                                -- Invalid parameters entered. Valid combinations for parameters to be entered
                                FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF_INV_PRM_COMB');
                                FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());
                                END IF;

				CLOSE c_incom_appl_nopgm_cnf_anc;

	      		ELSIF NVL(p_appl_no_calendar,'N') = 'N' THEN
				l_count := 0;
   				OPEN c_incom_appl_nopgm_cnf;
				LOOP
				FETCH c_incom_appl_nopgm_cnf INTO l_person_id;
				EXIT WHEN c_incom_appl_nopgm_cnf%NOTFOUND;

			  	IF c_incom_appl_nopgm_cnf%FOUND THEN
					l_count := l_count+1;

	  		  		OPEN cur_user(l_person_id);
	  				FETCH cur_user INTO l_user_id, l_user_name, l_full_name;

	  				IF cur_user%FOUND THEN

                                        OPEN c_per_num1(l_person_id);
                                        FETCH c_per_num1 INTO l_per_num1;
                                        CLOSE c_per_num1;

                                        FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF1');
                                        FND_MESSAGE.SET_TOKEN ('PERSONNUM', l_per_num1);
                                        FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET());

	   					WF_Inform_Applicant_INAP(l_user_id, l_user_name, l_full_name);
					ELSE
                                        -- write in the log that no user_id exists in the FND_USER table for this person_id
                                        FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_USR_PER_INV_COMB');
					FND_MESSAGE.SET_TOKEN ('PERSONNUM', l_per_num1);
                                        FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());

	  				END IF; /* cur_user */

	  		  		CLOSE cur_user;

				END IF; /* c_incom_appl_nopgm_cnf */
				END LOOP;

                                IF l_count = 0 THEN
                                -- write in the log file that no record exists
                                -- Invalid parameters entered. Valid combinations for parameters to be entered
                                FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF_INV_PRM_COMB');
                                FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());
                                END IF;

				CLOSE c_incom_appl_nopgm_cnf;

	    		END IF; /* p_appl_no_calendar */

		ELSIF p_prog_code IS NOT NULL THEN -- i.e.program parameter has been supplied

	    		IF NVL(p_appl_no_calendar,'N') = 'Y' THEN

				l_count := 0;
                   		OPEN c_incom_appl_pgm_cnf_anc;
				LOOP
                   		FETCH c_incom_appl_pgm_cnf_anc INTO l_person_id;
				EXIT WHEN c_incom_appl_pgm_cnf_anc%NOTFOUND;

                		IF c_incom_appl_pgm_cnf_anc%FOUND THEN
					l_count := l_count+1;

                        		OPEN cur_user(l_person_id);

                        		FETCH cur_user INTO l_user_id, l_user_name, l_full_name;

                        		IF cur_user%FOUND THEN

                                        OPEN c_per_num1(l_person_id);
                                        FETCH c_per_num1 INTO l_per_num1;
                                        CLOSE c_per_num1;

                                        FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF1');
                                        FND_MESSAGE.SET_TOKEN ('PERSONNUM', l_per_num1);
                                        FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET());

                        			WF_Inform_Applicant_INAP(l_user_id, l_user_name, l_full_name);
					ELSE
                                        -- write in the log that no user_id exists in the FND_USER table for this person_id
                                        FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_USR_PER_INV_COMB');
					FND_MESSAGE.SET_TOKEN ('PERSONNUM', l_per_num1);
                                        FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());

                        		END IF; /* cur_user */

                        		CLOSE cur_user;

                		END IF; /* c_incom_appl_pgm_cnf_anc */
				END LOOP;

                                IF l_count = 0 THEN
                                -- write in the log file that no record exists
                                -- Invalid parameters entered. Valid combinations for parameters to be entered
                                FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF_INV_PRM_COMB');
                                FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());
                                END IF;

                		CLOSE c_incom_appl_pgm_cnf_anc;

	    		ELSIF NVL(p_appl_no_calendar,'N') = 'N' THEN

				l_count := 0;
                		OPEN c_incom_appl_pgm_cnf;
				LOOP

                		FETCH c_incom_appl_pgm_cnf INTO l_person_id;
				EXIT WHEN c_incom_appl_pgm_cnf%NOTFOUND;

                		IF c_incom_appl_pgm_cnf%FOUND THEN
					l_count := l_count+1;

                        		OPEN cur_user(l_person_id);

                        		FETCH cur_user INTO l_user_id, l_user_name, l_full_name;

                        		IF cur_user%FOUND THEN

                                        OPEN c_per_num1(l_person_id);
                                        FETCH c_per_num1 INTO l_per_num1;
                                        CLOSE c_per_num1;

                                        FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF1');
                                        FND_MESSAGE.SET_TOKEN ('PERSONNUM', l_per_num1);
                                        FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET());

                                		WF_Inform_Applicant_INAP(l_user_id, l_user_name, l_full_name);
					ELSE
                                        -- write in the log that no user_id exists in the FND_USER table for this person_id
                                        FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_USR_PER_INV_COMB');
					FND_MESSAGE.SET_TOKEN ('PERSONNUM', l_per_num1);
                                        FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());

                        		END IF; /* cur_user */

                        		CLOSE cur_user;

                		END IF; /* c_incom_appl_pgm_cnf */
				END LOOP;

                                IF l_count = 0 THEN
                                -- write in the log file that no record exists
                                -- Invalid parameters entered. Valid combinations for parameters to be entered
                                FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF_INV_PRM_COMB');
                                FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());
                                END IF;

                		CLOSE c_incom_appl_pgm_cnf;

	    		END IF; /* p_appl_no_calendar */

		END IF; /* p_prog_code */

        ELSIF NVL(p_appl_range, 'CURRENT') = 'CURRENT' THEN

                IF p_prog_code IS NULL THEN

                        IF NVL(p_appl_no_calendar,'N') = 'Y' THEN
				l_count := 0;
                                OPEN c_incom_appl_nopgm_curr_anc;

				LOOP

                                FETCH c_incom_appl_nopgm_curr_anc INTO l_person_id;
				EXIT WHEN c_incom_appl_nopgm_curr_anc%NOTFOUND;

                                IF c_incom_appl_nopgm_curr_anc%FOUND THEN
					l_count := l_count+1;

                                        OPEN cur_user(l_person_id);
                                        FETCH cur_user INTO l_user_id, l_user_name, l_full_name;

                                        IF cur_user%FOUND THEN

                                        OPEN c_per_num1(l_person_id);
                                        FETCH c_per_num1 INTO l_per_num1;
                                        CLOSE c_per_num1;

                                        FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF1');
                                        FND_MESSAGE.SET_TOKEN ('PERSONNUM', l_per_num1);
                                        FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET());

                                                WF_Inform_Applicant_INAP(l_user_id, l_user_name, l_full_name);
                                        ELSE
                                        -- write in the log that no user_id exists in the FND_USER table for this person_id
                                        FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_USR_PER_INV_COMB');
					FND_MESSAGE.SET_TOKEN ('PERSONNUM', l_per_num1);
                                        FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());

                                        END IF;

                                        CLOSE cur_user;
                               END IF; /* c_incom_appl_nopgm_curr_anc */
				END LOOP;
                                IF l_count = 0 THEN
                                -- write in the log file that no record exists
                                -- Invalid parameters entered. Valid combinations for parameters to be entered
                                FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF_INV_PRM_COMB');
                                FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());

				END IF;


                                CLOSE c_incom_appl_nopgm_curr_anc;

                        ELSIF NVL(p_appl_no_calendar,'N') = 'N' THEN
				l_count := 0;
                                OPEN c_incom_appl_nopgm_curr;
				LOOP
                                FETCH c_incom_appl_nopgm_curr INTO l_person_id;
				EXIT WHEN c_incom_appl_nopgm_curr%NOTFOUND;

                                IF c_incom_appl_nopgm_curr%FOUND THEN
					l_count := l_count +1;

                                        OPEN cur_user(l_person_id);
                                        FETCH cur_user INTO l_user_id, l_user_name, l_full_name;

                                        IF cur_user%FOUND THEN

                                        OPEN c_per_num1(l_person_id);
                                        FETCH c_per_num1 INTO l_per_num1;
                                        CLOSE c_per_num1;

                                        FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF1');
                                        FND_MESSAGE.SET_TOKEN ('PERSONNUM', l_per_num1);
                                        FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET());

                                                WF_Inform_Applicant_INAP(l_user_id, l_user_name, l_full_name);

                                        ELSE
                                        -- write in the log that no user_id exists in the FND_USER table for this person_id
                                        FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_USR_PER_INV_COMB');
					FND_MESSAGE.SET_TOKEN ('PERSONNUM', l_per_num1);
                                        FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());

                                        END IF; /* cur_user */

                                        CLOSE cur_user;
                                END IF; /* c_incom_appl_nopgm_curr */
				END LOOP;
				IF l_count = 0 THEN
                                -- write in the log file that no record exists
                                -- Invalid parameters entered. Valid combinations for parameters to be entered
                                FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF_INV_PRM_COMB');
                                FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());
				END IF;

                                CLOSE c_incom_appl_nopgm_curr;

                        END IF; /* p_appl_no_calendar */

                ELSIF p_prog_code IS NOT NULL THEN -- i.e.program parameter has been supplied

                        IF NVL(p_appl_no_calendar,'N') = 'Y' THEN
			l_count := 0;

                                OPEN c_incom_appl_pgm_curr_anc;
				LOOP
                                FETCH c_incom_appl_pgm_curr_anc INTO l_person_id;
				EXIT WHEN c_incom_appl_pgm_curr_anc%NOTFOUND;

                                IF c_incom_appl_pgm_curr_anc%FOUND THEN
					l_count := l_count +1;

                                        OPEN cur_user(l_person_id);

                                        FETCH cur_user INTO l_user_id, l_user_name, l_full_name;

                                        IF cur_user%FOUND THEN

                                        OPEN c_per_num1(l_person_id);
                                        FETCH c_per_num1 INTO l_per_num1;
                                        CLOSE c_per_num1;

                                        FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF1');
                                        FND_MESSAGE.SET_TOKEN ('PERSONNUM', l_per_num1);
                                        FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET());

                                                WF_Inform_Applicant_INAP(l_user_id, l_user_name, l_full_name);
                                        ELSE
                                        -- write in the log that no user_id exists in the FND_USER table for this person_id
                                        FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_USR_PER_INV_COMB');
					FND_MESSAGE.SET_TOKEN ('PERSONNUM', l_per_num1);
                                        FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());

                                        END IF; /* cur_user */

                                        CLOSE cur_user;

                                END IF; /* c_incom_appl_pgm_curr_anc */
				END LOOP;

                                IF l_count = 0 THEN
                                -- write in the log file that no record exists
                                -- Invalid parameters entered. Valid combinations for parameters to be entered
                                FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF_INV_PRM_COMB');
                                FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());
                                END IF;

                                CLOSE c_incom_appl_pgm_curr_anc;

                        ELSIF NVL(p_appl_no_calendar,'N') = 'N' THEN
				l_count := 0;
                                OPEN c_incom_appl_pgm_curr;

				LOOP
                                FETCH c_incom_appl_pgm_curr INTO l_person_id;
				EXIT WHEN c_incom_appl_pgm_curr%NOTFOUND;

                                IF c_incom_appl_pgm_curr%FOUND THEN
					l_count := l_count+1;

                                        OPEN cur_user(l_person_id);

                                        FETCH cur_user INTO l_user_id, l_user_name, l_full_name;

                                        IF cur_user%FOUND THEN

                                        OPEN c_per_num1(l_person_id);
                                        FETCH c_per_num1 INTO l_per_num1;
                                        CLOSE c_per_num1;

                                        FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF1');
                                        FND_MESSAGE.SET_TOKEN ('PERSONNUM', l_per_num1);
                                        FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET());

                                                WF_Inform_Applicant_INAP(l_user_id, l_user_name, l_full_name);
                                        ELSE
                                        -- write in the log that no user_id exists in the FND_USER table for this person_id
                                        FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_USR_PER_INV_COMB');
					FND_MESSAGE.SET_TOKEN ('PERSONNUM', l_per_num1);
                                        FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());

                                        END IF; /* cur_user */

                                        CLOSE cur_user;

                                END IF; /* c_incom_appl_pgm_curr */
				END LOOP;
                                IF l_count = 0 THEN
                                -- write in the log file that no record exists
                                -- Invalid parameters entered. Valid combinations for parameters to be entered
                                FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF_INV_PRM_COMB');
                                FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());
                                END IF;

                                CLOSE c_incom_appl_pgm_curr;

                        END IF; /* p_appl_no_calendar */

                END IF; /* p_prog_code */

	END IF; /* p_appl_range */

  EXCEPTION
     WHEN OTHERS THEN
       RETCODE := 2;
       ERRBUF  := fnd_message.get_string( 'IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

   IF c_incom_appl_nopgm_curr_anc%ISOPEN THEN
      CLOSE c_incom_appl_nopgm_curr_anc;
   END IF;
   IF c_incom_appl_nopgm_curr%ISOPEN THEN
      CLOSE c_incom_appl_nopgm_curr;
   END IF;
   IF c_incom_appl_pgm_curr_anc%ISOPEN THEN
      CLOSE c_incom_appl_pgm_curr_anc;
   END IF;
   IF c_incom_appl_pgm_curr%ISOPEN THEN
      CLOSE c_incom_appl_pgm_curr;
   END IF;
   IF c_incom_appl_nopgm_cnf_anc%ISOPEN THEN
      CLOSE c_incom_appl_nopgm_cnf_anc;
   END IF;
   IF c_incom_appl_nopgm_cnf%ISOPEN THEN
      CLOSE c_incom_appl_nopgm_cnf;
   END IF;
   IF c_incom_appl_pgm_cnf_anc%ISOPEN THEN
      CLOSE c_incom_appl_pgm_cnf_anc;
   END IF;
   IF c_incom_appl_pgm_cnf%ISOPEN THEN
      CLOSE c_incom_appl_pgm_cnf;
   END IF;
   IF c_per_num%ISOPEN THEN
      CLOSE c_per_num;
   END IF;
   IF c_per_num1%ISOPEN THEN
      CLOSE c_per_num1;
   END IF;


END Extract_Applications;

/* *************************************************************************************/
-- This Procedure raises an event when there incomplete application concurrent job is submitted.
/* *************************************************************************************/

PROCEDURE  Wf_Inform_Applicant_INAP
                       (  p_applicant_id        IN   NUMBER,
                          p_applicant_name      IN   VARCHAR2,
                          p_applicant_full_name IN   VARCHAR2
                        )
IS
    l_event_t             wf_event_t;
    l_parameter_list_t    wf_parameter_list_t;
    l_itemKey             varchar2(100);
    l_incomplt_appl_url   varchar2(1000);


     CURSOR  cur_seq IS
         SELECT IGS_AD_WF_INAPPL_S.NEXTVAL
         FROM dual;


BEGIN

         -- initialize the wf_event_t object
         --
         wf_event_t.Initialize(l_event_t);

    	 OPEN cur_seq ;
    	 FETCH cur_seq INTO l_itemKey ;
    	 CLOSE cur_seq ;



         wf_event.AddParameterToList ( p_Name => 'IA_PERSON_ID',p_Value => p_applicant_id, p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_PERSON_NAME',p_Value => p_applicant_name, p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_PERSON_FULL_NAME',p_Value => p_applicant_full_name, p_parameterlist=>l_parameter_list_t);
--       wf_event.AddParameterToList ( p_Name => 'IA_INCOM_APPL_URL',p_Value => l_incomplt_appl_url, p_parameterlist=>l_parameter_list_t);

-- raise the event

WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.ad.appl.incmpl_appl',
                p_event_key  => l_itemKey,
                p_parameters => l_parameter_list_t);

l_parameter_list_t.delete;

END Wf_Inform_Applicant_INAP ;


PROCEDURE wf_set_url_inap (itemtype    IN  VARCHAR2  ,
                        itemkey     IN  VARCHAR2  ,
                        actid       IN  NUMBER   ,
                        funcmode    IN  VARCHAR2  ,
                        resultout   OUT NOCOPY VARCHAR2
                       ) AS

   l_date_prod            VARCHAR2(30);
   l_doc_type             VARCHAR2(30);
   l_role_name            VARCHAR2(320);
   l_role_display_name    VARCHAR2(320) := 'Adhoc Role for IGSAS006';
   l_person_id_sep        VARCHAR2(4000);
   l_person_id            VARCHAR2(30);
--   l_profile_value	  VARCHAR2(200) := FND_PROFILE.VALUE('APPS_JSP_AGENT');


 l_url varchar2(4000) := 'http://qapache.us.oracle.com:16526/OA_HTML/OA.jsp?akRegionCode=IGS_AD_APPL_INCOMPLETE_PAGE&akRegionApplicationId=8405';
 l_value varchar2(100);

 BEGIN
   IF (funcmode  = 'RUN') THEN

       Wf_Engine.SetItemAttrText(  ItemType  =>  itemtype,
                                 ItemKey   =>  itemkey,
                                 aname     =>  'IA_INCOM_APPL_URL',
                                 avalue    =>  l_url
                                );

       l_value  := Wf_Engine.GetItemAttrText(itemtype,itemkey,'IA_INCOM_APPL_URL');
     Resultout:= 'COMPLETE:';
     RETURN;
   END IF;
END wf_set_url_inap;


PROCEDURE   Adm_Application_Req
                       (  errbuf OUT NOCOPY VARCHAR2,
                          retcode OUT NOCOPY NUMBER ,
                          p_person_id                   IN   hz_parties.party_id%TYPE,
                          p_person_id_group             IN   igs_pe_prsid_grp_mem_all.group_id%TYPE,
			  p_appl_id             	IN   igs_ad_appl.application_id%Type,
			  p_calendar_details            IN   VARCHAR2,
			  p_tracking_type		IN   VARCHAR2,
                          p_apc                         IN   VARCHAR2,
			  p_appl_type			IN   VARCHAR2,
			  p_prog_code			IN   VARCHAR2,
			  p_location			IN   VARCHAR2,
			  p_att_type			IN   VARCHAR2,
			  p_att_mode			IN   VARCHAR2
                        ) IS

 l_appl_exist VARCHAR2(1);
 l_user_id NUMBER;
 l_person_id NUMBER;
 l_per_num hz_parties.party_number%type;
 lv_person_id VARCHAR2(300);
 l_person_name VARCHAR2(320);
 l_display_name VARCHAR2(360);
 l_user_name VARCHAR2(100);
 l_full_name VARCHAR2(1000);
 l_count number := 0;

 l_adm_cal igs_ca_inst_all.cal_type%TYPE := RTRIM(SUBSTR(p_calendar_details, 23, 10));
 l_acad_cal igs_ca_inst_all.cal_type%TYPE := RTRIM(SUBSTR(p_calendar_details,1,10));
 l_acad_cal_seq_num igs_ca_inst_all.sequence_number%TYPE := IGS_GE_NUMBER.TO_NUM(SUBSTR(p_calendar_details,14,6));
 l_adm_cal_seq_num igs_ca_inst_all.sequence_number%TYPE :=IGS_GE_NUMBER.TO_NUM(SUBSTR(p_calendar_details,37,6));
 l_adm_cat VARCHAR2(10) := RTRIM(SUBSTR(p_apc,1, 10));
 l_adm_proc_type varchar2(15) := RTRIM(SUBSTR(p_apc, 11, 30));

 l_alt_code_acad igs_ca_inst.alternate_code%TYPE;
 l_alt_code_adm igs_ca_inst.alternate_code%TYPE;

 Cursor c_per_adm_req IS
 select a.person_id
 from igs_ad_appl_all a,
 igs_ad_ps_appl_inst_all i,
 igs_ad_aplins_admreq r,
 igs_tr_item_all t,
 igs_tr_type_all ty
 where a.person_id = i.person_id
        and (p_person_id_group IS NOT NULL and
        a.person_id IN (SELECT person_id
                 FROM igs_pe_prsid_grp_mem pgm
                 WHERE pgm.group_id = nvl(p_person_id_group,pgm.group_id)
		 And SYSDATE BETWEEN nvl(START_DATE, SYSDATE) AND nvl(END_DATE, SYSDATE))
                 OR
                (p_person_id_group is null))
 and a.admission_appl_number = i.admission_appl_number
 and i.person_id = r.person_id
 and i.nominated_course_cd = r.course_cd
 and i.admission_appl_number = r.admission_appl_number
 and i.sequence_number = r.sequence_number
 and r.tracking_id = t.tracking_id
 and t.tracking_status in (select tracking_status from igs_tr_status where s_tracking_status = 'ACTIVE')
 AND ((a.person_id = p_person_id AND p_person_id IS NOT NULL) OR (p_person_id is NULL))
 AND ((a.ACAD_CAL_TYPE= l_acad_cal) AND (a.ACAD_CI_SEQUENCE_NUMBER= l_acad_cal_seq_num))
 AND ((a.ADM_CAL_TYPE= l_adm_cal) AND (a.ADM_CI_SEQUENCE_NUMBER= l_adm_cal_seq_num))
 AND (((a.ADMISSION_CAT =  l_adm_cat) AND (a.S_ADMISSION_PROCESS_TYPE = l_adm_proc_type)
 AND (p_apc IS NOT NULL)) OR (p_apc is NULL))
 AND ((a.application_id = p_appl_id and p_appl_id IS NOT NULL) OR (p_appl_id is NULL))
 AND ((a.application_type = p_appl_type and p_appl_type IS NOT NULL) OR (p_appl_type is NULL))
 AND ((i.nominated_course_cd = p_prog_code and p_prog_code IS NOT NULL) OR (p_prog_code is NULL))
 AND ((i.location_cd = p_location and p_location IS NOT NULL) OR (p_location is NULL))
 AND ((i.attendance_mode = p_att_mode and p_att_mode IS NOT NULL) OR (p_att_mode is NULL))
 AND ((i.attendance_type = p_att_type and p_att_type IS NOT NULL) OR (p_att_type is NULL))
 and t.tracking_type = ty.tracking_type
 and ty.s_tracking_type = 'ADM_PROCESSING'
 Group by a.person_id;

 Cursor c_per_post_adm_req IS
 select a.person_id
 from igs_ad_appl_all a,
 igs_ad_ps_appl_inst_all i,
 igs_ad_aplins_admreq r,
 igs_tr_item_all t,
 igs_tr_type_all ty
 where a.person_id = i.person_id
        and (p_person_id_group IS NOT NULL and
        a.person_id IN (SELECT person_id
                 FROM igs_pe_prsid_grp_mem pgm
                 WHERE pgm.group_id = nvl(p_person_id_group,pgm.group_id)
		 And SYSDATE BETWEEN nvl(START_DATE, SYSDATE) AND nvl(END_DATE, SYSDATE))
                 OR
                (p_person_id_group is null))
 and a.admission_appl_number = i.admission_appl_number
 and i.person_id = r.person_id
 and i.nominated_course_cd = r.course_cd
 and i.admission_appl_number = r.admission_appl_number
 and i.sequence_number = r.sequence_number
 and r.tracking_id = t.tracking_id
 and t.tracking_status in (select tracking_status from igs_tr_status where s_tracking_status = 'ACTIVE')
 AND ((a.person_id = p_person_id AND p_person_id IS NOT NULL) OR (p_person_id is NULL))
 AND ((a.ACAD_CAL_TYPE = l_acad_cal) AND (a.ACAD_CI_SEQUENCE_NUMBER = l_acad_cal_seq_num))
 AND ((a.ADM_CAL_TYPE = l_adm_cal) AND (a.ADM_CI_SEQUENCE_NUMBER = l_adm_cal_seq_num))
 AND (((a.ADMISSION_CAT = l_adm_cat) AND (a.S_ADMISSION_PROCESS_TYPE = l_adm_proc_type)
 AND (p_apc IS NOT NULL)) OR (p_apc is NULL))
 AND ((a.application_id = p_appl_id and p_appl_id IS NOT NULL) OR (p_appl_id is NULL))
 AND ((a.application_type = p_appl_type and p_appl_type IS NOT NULL) OR (p_appl_type is NULL))
 AND ((i.nominated_course_cd = p_prog_code and p_prog_code IS NOT NULL) OR (p_prog_code is NULL))
 AND ((i.location_cd = p_location and p_location IS NOT NULL) OR (p_location is NULL))
 AND ((i.attendance_mode = p_att_mode and p_att_mode IS NOT NULL) OR (p_att_mode is NULL))
 AND ((i.attendance_type = p_att_type and p_att_type IS NOT NULL) OR (p_att_type is NULL))
 and t.tracking_type = ty.tracking_type
 and ty.s_tracking_type = 'POST_ADMISSION'
 group by a.person_id;

 CURSOR c_get_alt_code(cp_cal_type igs_ca_inst.cal_type%TYPE,cp_seq_no igs_ca_inst.sequence_number%TYPE) IS
   SELECT alternate_code
   FROM IGS_CA_INST
   WHERE cal_type = cp_cal_type AND
         sequence_number = cp_seq_no;

 CURSOR cur_user(cp_person_id igs_ad_appl_all.person_id%TYPE) IS
   SELECT user_name, description
   FROM   FND_USER
   WHERE  person_party_id = cp_person_id ;

 CURSOR c_per_num IS
   SELECT party_number
   FROM   HZ_PARTIES
   WHERE  party_id = p_person_id ;

BEGIN

    -- The following code is added for disabling of OSS in R12.IGS.A - Bug 4955192
    igs_ge_gen_003.set_org_id(null);

    RETCODE := 0;
    ERRBUF  := NULL;

    FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_APP_APPNTF_PRMS');
    FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET ());

    OPEN c_per_num;
    FETCH c_per_num INTO l_per_num;
    CLOSE c_per_num;

    FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_APP_LG_PNUM');
    FND_MESSAGE.SET_TOKEN ('PNUM', l_per_num);
    FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET ());

    FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_APP_LG_PID_GRP');
    FND_MESSAGE.SET_TOKEN ('PGPID', p_person_id_group);
    FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET ());

    FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_APP_LG_APPLID');
    FND_MESSAGE.SET_TOKEN ('APPLID', p_appl_id);
    FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET ());

    FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APP_LG_CL_DTLS');
    FND_MESSAGE.SET_TOKEN('CLDTLS', p_calendar_details);
    FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());

    FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_APP_LG_TRKTYP');
    FND_MESSAGE.SET_TOKEN ('TRKTYP', p_tracking_type);
    FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET ());

    FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_APP_LG_APC');
    FND_MESSAGE.SET_TOKEN ('APC', p_apc);
    FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET ());

    FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_LG_INAP_APPL_TYPE');
    FND_MESSAGE.SET_TOKEN ('APPLTYPE', p_appl_type);
    FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET ());

    FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_APP_LG_CRCD');
    FND_MESSAGE.SET_TOKEN ('CRCD', p_prog_code);
    FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET ());

    FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_LG_INAP_LOC');
    FND_MESSAGE.SET_TOKEN ('LOC', p_location);
    FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET ());

    FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_LG_INAP_ATT_TYPE');
    FND_MESSAGE.SET_TOKEN ('ATTTYPE', p_att_type);
    FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET ());

    FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_LG_INAP_ATT_MODE');
    FND_MESSAGE.SET_TOKEN ('ATTMODE', p_att_mode);
    FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET ());

    FND_FILE.PUT_LINE (FND_FILE.LOG, '');
    FND_FILE.PUT_LINE (FND_FILE.LOG, '');

  IF (p_person_id IS NOT NULL AND p_person_id_group IS NOT NULL ) THEN

          FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_NO_PERID_PERIDGRP');
          FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET ());

  ELSIF NVL(p_tracking_type, 'ADM_PROCESSING') = 'ADM_PROCESSING' THEN

	l_count := 0;

	OPEN c_per_adm_req;

	LOOP

	FETCH c_per_adm_req INTO l_person_id;

	EXIT WHEN c_per_adm_req%NOTFOUND;

	IF c_per_adm_req%FOUND THEN

		l_count := l_count+1;
                lv_person_id := IGS_GE_NUMBER.TO_CANN(l_person_id);

--              The following code should be uncommented once the TCA HZ.J patch is applied
/*		Wf_Directory.GetRoleName('HZ_PARTY', lv_person_id, l_person_name, l_display_name);

		IF l_person_name IS NOT NULL THEN

                FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF2');
                FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET());

    		FND_FILE.PUT_LINE (FND_FILE.LOG, '');
                FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF6');
                FND_MESSAGE.SET_TOKEN ('PNAME', l_display_name);
                FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET());

                ELSE
                FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF4');
                FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET());
                END IF; */
                ---------------------------------------------------------------------------------
                --Get Alternate Code
                ---------------------------------------------------------------------------------
                OPEN c_get_alt_code(l_acad_cal,l_acad_cal_seq_num);
                FETCH c_get_alt_code INTO l_alt_code_acad;
                CLOSE c_get_alt_code;

                OPEN c_get_alt_code(l_adm_cal,l_adm_cal_seq_num);
                FETCH c_get_alt_code INTO l_alt_code_adm;
                CLOSE c_get_alt_code;

		OPEN cur_user(l_person_id);
                FETCH cur_user INTO  l_person_name, l_display_name;

                	IF cur_user%FOUND THEN

                	FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF2');
                	FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET());

                	FND_FILE.PUT_LINE (FND_FILE.LOG, '');
                	FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF6');
                	FND_MESSAGE.SET_TOKEN ('PNAME', l_display_name);
                	FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET());

                	Wf_Admission_Req (l_person_id, l_person_name, l_display_name, l_alt_code_acad, l_alt_code_adm);

			ELSE
			Wf_Directory.GetRoleName('HZ_PARTY', lv_person_id, l_person_name, l_display_name);

				IF l_person_name IS NOT NULL THEN

                		FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF2');
                		FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET());

    				FND_FILE.PUT_LINE (FND_FILE.LOG, '');
                		FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF6');
                		FND_MESSAGE.SET_TOKEN ('PNAME', l_display_name);
                		FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET());

                		Wf_Admission_Req (l_person_id, l_person_name, l_display_name, l_alt_code_acad, l_alt_code_adm);

                		ELSE
                		FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF4');
                		FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET());

				END IF ; /* l_person_name */

                	END IF; /* cur_user */
		CLOSE cur_user;

	END IF; /* c_per_adm_req */

	END LOOP;

	        IF l_count = 0 THEN
	        -- write in the log file that no record exists
	        -- Invalid parameters entered. Valid combinations for parameters to be entered
	        FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF_INV_PRM_COMB');
	        FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());
	        END IF;

	CLOSE c_per_adm_req;


  ELSIF NVL(p_tracking_type, 'ADM_PROCESSING') = 'POST_ADMISSION' THEN

	l_count := 0;

	OPEN c_per_post_adm_req;

	LOOP

	FETCH c_per_post_adm_req INTO l_person_id;

	EXIT WHEN c_per_post_adm_req%NOTFOUND;

	IF c_per_post_adm_req%FOUND THEN

		l_count := l_count+1;

		lv_person_id := IGS_GE_NUMBER.TO_CANN(l_person_id);

--  		The following code should be uncommented once the TCA HZ.J patch is applied
/*		Wf_Directory.GetRoleName('HZ_PARTY', l_person_id, l_person_name, l_display_name);

                IF l_person_name IS NOT NULL THEN

                FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF3');
                FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET());

    		FND_FILE.PUT_LINE (FND_FILE.LOG, '');
                FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF6');
                FND_MESSAGE.SET_TOKEN ('PNAME', l_display_name);
                FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET());

                ELSE
                FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF4');
                FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET());

                END IF; */

                ---------------------------------------------------------------------------------
                --Get Alternate Code
                ---------------------------------------------------------------------------------
                OPEN c_get_alt_code(l_acad_cal,l_acad_cal_seq_num);
                FETCH c_get_alt_code INTO l_alt_code_acad;
                CLOSE c_get_alt_code;

                OPEN c_get_alt_code(l_adm_cal,l_adm_cal_seq_num);
                FETCH c_get_alt_code INTO l_alt_code_adm;
                CLOSE c_get_alt_code;

                OPEN cur_user(l_person_id);
                FETCH cur_user INTO  l_person_name, l_display_name;

                        IF cur_user%FOUND THEN

                        FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF2');
                        FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET());

                        FND_FILE.PUT_LINE (FND_FILE.LOG, '');
                        FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF6');
                        FND_MESSAGE.SET_TOKEN ('PNAME', l_display_name);
                        FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET());

                        Wf_Post_Adm_Req (l_person_id, l_person_name, l_display_name, l_alt_code_acad, l_alt_code_adm);

                        ELSE
                        Wf_Directory.GetRoleName('HZ_PARTY', lv_person_id, l_person_name, l_display_name);

                                IF l_person_name IS NOT NULL THEN

                                FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF2');
                                FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET());

                                FND_FILE.PUT_LINE (FND_FILE.LOG, '');
                                FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF6');
                                FND_MESSAGE.SET_TOKEN ('PNAME', l_display_name);
                                FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET());

                                Wf_Post_Adm_Req (l_person_id, l_person_name, l_display_name, l_alt_code_acad, l_alt_code_adm);

                                ELSE
                                FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF4');
                                FND_FILE.PUT_LINE (FND_FILE.LOG, FND_MESSAGE.GET());

                                END IF ; /* l_person_name */

                        END IF; /* cur_user */
                CLOSE cur_user;

	END IF; /* c_per_post_adm_req */

	END LOOP;

        	IF l_count = 0 THEN
        	-- write in the log file that no record exists
	        -- Invalid parameters entered. Valid combinations for parameters to be entered
	        FND_MESSAGE.SET_NAME('IGS', 'IGS_AD_APNTF_INV_PRM_COMB');
	        FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());
        	END IF;

	CLOSE c_per_post_adm_req;

END IF; /* p_tracking_type */

  EXCEPTION
     WHEN OTHERS THEN
       RETCODE := 2;
       ERRBUF  := fnd_message.get_string( 'IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
       IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

   IF c_per_adm_req%ISOPEN THEN
      CLOSE c_per_adm_req;
   END IF;
   IF c_per_post_adm_req%ISOPEN THEN
      CLOSE c_per_post_adm_req;
   END IF;
   IF c_get_alt_code%ISOPEN THEN
      CLOSE c_get_alt_code;
   END IF;
   IF c_per_num%ISOPEN THEN
      CLOSE c_per_num;
   END IF;
   IF cur_user%ISOPEN THEN
      CLOSE cur_user;
   END IF;


END Adm_Application_Req;

/* *************************************************************************************/
-- This Procedure raises an event when the admission requirement concurrent job is submitted.
/* *************************************************************************************/

PROCEDURE  Wf_Admission_Req
                       (  p_applicant_id        	IN   NUMBER,
			  p_applicant_name      	IN   VARCHAR2,
			  p_applicant_display_name      IN   VARCHAR2,
			  p_alt_code_acad		IN   VARCHAR2,
			  p_alt_code_adm		IN   VARCHAR2
                        )
IS
    l_event_t             wf_event_t;
    l_parameter_list_t    wf_parameter_list_t;
    l_itemKey             varchar2(100);
    l_incomplt_appl_url   varchar2(1000);


     CURSOR cur_seq IS
         SELECT IGS_AD_WF_ADREQ_S.NEXTVAL
         FROM dual;


BEGIN

         -- initialize the wf_event_t object
         --
         wf_event_t.Initialize(l_event_t);

         OPEN cur_seq ;
         FETCH cur_seq INTO l_itemKey ;
         CLOSE cur_seq ;



         wf_event.AddParameterToList ( p_Name => 'IA_PERSON_ID',p_Value => p_applicant_id, p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_PERSON_NAME',p_Value => p_applicant_name, p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_PERSON_FULL_NAME',p_Value => p_applicant_display_name, p_parameterlist=>l_parameter_list_t);

         wf_event.AddParameterToList ( p_Name => 'IA_ACAD_CALENDAR',p_Value => p_alt_code_acad, p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_ADM_CALENDAR',p_Value => p_alt_code_adm, p_parameterlist=>l_parameter_list_t);

--
-- raise the event
--
WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.ad.appl.adm_req',
                p_event_key  => l_itemKey,
                p_parameters => l_parameter_list_t);

 l_parameter_list_t.delete;

END Wf_Admission_Req ;

/* *************************************************************************************/
-- This Procedure raises an event when the post-admission requirement concurrent job is submitted.
/* *************************************************************************************/

PROCEDURE  Wf_Post_Adm_Req
                       (  p_applicant_id        	IN   NUMBER,
			  p_applicant_name      	IN   VARCHAR2,
			  p_applicant_display_name      IN   VARCHAR2,
                          p_alt_code_acad            	IN   VARCHAR2,
                          p_alt_code_adm             	IN   VARCHAR2
                        )
IS
    l_event_t             wf_event_t;
    l_parameter_list_t    wf_parameter_list_t;
    l_itemKey             varchar2(100);
    l_incomplt_appl_url   varchar2(1000);


     CURSOR cur_seq IS
         SELECT IGS_AD_WF_POSTREQ_S.NEXTVAL
         FROM dual;


BEGIN

         -- initialize the wf_event_t object
         --
         wf_event_t.Initialize(l_event_t);

         OPEN cur_seq ;
         FETCH cur_seq INTO l_itemKey ;
         CLOSE cur_seq ;


         wf_event.AddParameterToList ( p_Name => 'IA_PERSON_ID',p_Value => p_applicant_id, p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_PERSON_NAME',p_Value => p_applicant_name, p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_PERSON_FULL_NAME',p_Value => p_applicant_display_name, p_parameterlist=>l_parameter_list_t);

         wf_event.AddParameterToList ( p_Name => 'IA_ACAD_CALENDAR',p_Value => p_alt_code_acad, p_parameterlist=>l_parameter_list_t);
         wf_event.AddParameterToList ( p_Name => 'IA_ADM_CALENDAR',p_Value => p_alt_code_adm, p_parameterlist=>l_parameter_list_t);

--
-- raise the event
--

WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.ad.appl.post_adm_req',
                p_event_key  => l_itemKey,
                p_parameters => l_parameter_list_t);

 l_parameter_list_t.delete;

END Wf_Post_Adm_Req ;

END IGS_AD_WRKFLOW_PKG;

/
