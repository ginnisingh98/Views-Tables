--------------------------------------------------------
--  DDL for Package Body IGS_EN_GEN_014
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_GEN_014" AS
/* $Header: IGSEN14B.pls 120.0 2005/06/02 03:33:13 appldev noship $ */

-------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --prchandr    08-Jan-01       Enh Bug No: 2174101, As the Part of Change in IGSEN18B
  --                            Passing NULL as parameters  to ENRP_CLC_SUA_EFTSU
  --                            ENRP_CLC_EFTSU_TOTAL for Key course cd and version number
  -- anilk      10-Nov-2003     Audit special fee build, Added p_include_audit
  -- ckasu     22-JUL-2004      added new Functions and Procedures Specs inorder to incorporate
  --                            the logic for getting current,future load calendars information.
  --                            as a part of Bug# 3784635
  -------------------------------------------------------------------------------------------

Function Enrs_Clc_Sua_Cp(
  p_person_id  IGS_EN_SU_ATTEMPT_ALL.person_id%TYPE ,
  p_course_cd  IGS_EN_STDNT_PS_ATT_ALL.course_cd%TYPE ,
  p_crv_version_number  IGS_EN_STDNT_PS_ATT_ALL.version_number%TYPE ,
  p_unit_cd  IGS_EN_SU_ATTEMPT_ALL.unit_cd%TYPE ,
  p_unit_version_number  IGS_EN_SU_ATTEMPT_ALL.version_number%TYPE ,
  p_teach_cal_type  IGS_EN_SU_ATTEMPT_ALL.cal_type%TYPE ,
  p_teach_sequence_number  IGS_EN_SU_ATTEMPT_ALL.ci_sequence_number%TYPE ,
  p_uoo_id IN NUMBER ,
  p_load_cal_type  IGS_CA_INST_ALL.cal_type%TYPE ,
  p_load_sequence_number  IGS_CA_INST_ALL.sequence_number%TYPE ,
  p_override_enrolled_cp IN NUMBER ,
  p_override_eftsu IN NUMBER ,
  p_truncate_ind IN VARCHAR2 ,
  p_sca_cp_total IN NUMBER,
  -- anilk, Audit special fee build
  p_include_audit IN VARCHAR2 DEFAULT 'N' )
RETURN NUMBER  AS
BEGIN
DECLARE
	v_sua_eftsu  NUMBER;
	v_sua_cp  NUMBER;
BEGIN
	v_sua_eftsu := IGS_EN_PRC_LOAD.enrp_clc_sua_eftsu(
				p_person_id,
				p_course_cd,
				p_crv_version_number,
				p_unit_cd,
				p_unit_version_number,
				p_teach_cal_type,
				p_teach_sequence_number,
				p_uoo_id,
				p_load_cal_type,
				p_load_sequence_number,
				p_override_enrolled_cp,
				p_override_eftsu,
				p_truncate_ind,
				p_sca_cp_total,
                                NULL,
                                NULL,
				v_sua_cp,
				p_include_audit );
	RETURN v_sua_cp;
END;
END enrs_clc_sua_cp;

Function Enrs_Clc_Sua_Eftsu(
  p_person_id  IGS_EN_SU_ATTEMPT_ALL.person_id%TYPE ,
  p_course_cd  IGS_EN_STDNT_PS_ATT_ALL.course_cd%TYPE ,
  p_crv_version_number  IGS_EN_STDNT_PS_ATT_ALL.version_number%TYPE ,
  p_unit_cd  IGS_EN_SU_ATTEMPT_ALL.unit_cd%TYPE ,
  p_unit_version_number  IGS_EN_SU_ATTEMPT_ALL.version_number%TYPE ,
  p_teach_cal_type  IGS_EN_SU_ATTEMPT_ALL.cal_type%TYPE ,
  p_teach_sequence_number  IGS_EN_SU_ATTEMPT_ALL.ci_sequence_number%TYPE ,
  p_uoo_id IN NUMBER ,
  p_load_cal_type  IGS_CA_INST_ALL.cal_type%TYPE ,
  p_load_sequence_number  IGS_CA_INST_ALL.sequence_number%TYPE ,
  p_override_enrolled_cp IN NUMBER ,
  p_override_eftsu IN NUMBER ,
  p_truncate_ind IN VARCHAR2 ,
  p_sca_cp_total IN NUMBER ,
  -- anilk, Audit special fee build
  p_include_audit IN VARCHAR2 DEFAULT 'N' )
RETURN NUMBER  AS
BEGIN
DECLARE
	v_sua_cp  NUMBER;
BEGIN
	RETURN IGS_EN_PRC_LOAD.enrp_clc_sua_eftsu(
				p_person_id,
				p_course_cd,
				p_crv_version_number,
				p_unit_cd,
				p_unit_version_number,
				p_teach_cal_type,
				p_teach_sequence_number,
				p_uoo_id,
				p_load_cal_type,
				p_load_sequence_number,
				p_override_enrolled_cp,
				p_override_eftsu,
				p_truncate_ind,
				p_sca_cp_total,
                               NULL,
                                NULL,
				v_sua_cp,
				p_include_audit );
END;
END enrs_clc_sua_eftsu;

Function Enrs_Clc_Sua_Eftsut(
  P_PERSON_ID IN NUMBER ,
  P_COURSE_CD IN VARCHAR2 ,
  P_CRV_VERSION_NUMBER IN NUMBER ,
  P_UNIT_CD IN VARCHAR2 ,
  P_UNIT_VERSION_NUMBER IN NUMBER ,
  P_TEACH_CAL_TYPE IN VARCHAR2 ,
  P_TEACH_SEQUENCE_NUMBER IN NUMBER ,
  p_uoo_id IN NUMBER ,
  p_override_enrolled_cp IN NUMBER ,
  p_override_eftsu IN NUMBER ,
  p_sca_cp_total IN NUMBER )
RETURN NUMBER  AS
BEGIN
DECLARE
	v_original_eftsu  NUMBER;
BEGIN
	RETURN IGS_EN_PRC_LOAD.enrp_clc_sua_eftsut(
				p_person_id,
				p_course_cd,
				p_crv_version_number,
				p_unit_cd,
				p_unit_version_number,
				p_teach_cal_type,
				p_teach_sequence_number,
				p_uoo_id,
				p_override_enrolled_cp,
				p_override_eftsu,
				p_sca_cp_total,
				v_original_eftsu);
END;
END enrs_clc_sua_eftsut;

Function Enrs_Get_Acad_Alt_Cd(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER )
RETURN VARCHAR2  AS
v_acad_cal_type			IGS_CA_INST.cal_type%TYPE;
v_acad_ci_sequence_number	IGS_CA_INST.sequence_number%TYPE;
v_acad_ci_start_dt			IGS_CA_INST.start_dt%TYPE;
v_acad_ci_end_dt			IGS_CA_INST.end_dt%TYPE;
v_message_name			Varchar2(30);
BEGIN
	RETURN IGS_EN_GEN_002.enrp_get_acad_alt_cd(p_cal_type,
				p_ci_sequence_number,
				v_acad_cal_type,
				v_acad_ci_sequence_number,
				v_acad_ci_start_dt,
				v_acad_ci_end_dt,
				v_message_name);
END enrs_get_acad_alt_cd;

Function Enrs_Get_Acai_Cndtnl(
  p_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_cndtnl_off_must_be_stsfd_ind IN VARCHAR2 DEFAULT 'N')
RETURN VARCHAR2  AS
	v_message_name 		Varchar2(30);
	v_s_adm_cndtnl_offer_status
		IGS_AD_CNDNL_OFRSTAT.s_adm_cndtnl_offer_status%TYPE;
	v_other_detail			VARCHAR2(255);
BEGIN
	IF IGS_EN_VAL_SCA.ENRP_VAL_ACAI_CNDTNL(
			p_adm_cndtnl_offer_status,
			p_cndtnl_off_must_be_stsfd_ind,
			v_s_adm_cndtnl_offer_status,
			v_message_name) THEN
		RETURN 'Y';
	ELSE
		RETURN 'N';
	END IF;
/*
EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		App_Exception.Raise_Exception;
*/
END enrs_get_acai_cndtnl ;

Function Enrs_Get_Sca_Comm(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_student_confirmed_ind IN VARCHAR2 DEFAULT 'N',
  p_effective_date IN DATE )
RETURN VARCHAR2  AS
BEGIN
	IF IGS_EN_GEN_006.ENRP_GET_SCA_COMM(p_person_id,
		p_course_cd,
		p_student_confirmed_ind,
		p_effective_date) THEN
			RETURN 'NEW';
	ELSE
			RETURN 'RETURN';
	END IF;
END enrs_get_sca_comm;

Function Enrs_Get_Sca_Elgbl(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_student_comm_type IN VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER )
RETURN VARCHAR2  AS
	v_message_name	Varchar2(30);
	v_other_detail	VARCHAR2(255);
BEGIN
	IF IGS_EN_GEN_006.ENRP_GET_SCA_ELGBL(
			p_person_id,
			p_course_cd,
			p_student_comm_type,
			p_acad_cal_type,
			p_acad_ci_sequence_number,
			'N',
			v_message_name) THEN
		RETURN 'TRUE';
	ELSE
		RETURN 'FALSE';
	END IF;
/*
EXCEPTION
	WHEN OTHERS THEN
		Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
		App_Exception.Raise_Exception;
*/
END enrs_get_sca_elgbl ;

Function Enrs_Get_Sca_Trnsfr(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 )
RETURN VARCHAR2  AS
	v_message_name			Varchar2(30);
BEGIN
	IF IGS_EN_GEN_006.enrp_get_sca_trnsfr(
		p_person_id,
		p_course_cd,
		v_message_name) = FALSE THEN
		RETURN 'N';
	ELSE
		RETURN 'Y';
	END IF;
END enrs_get_sca_trnsfr;

Function Enrs_Get_Within_Ci(
  p_sup_cal_type IN VARCHAR2 ,
  p_sup_sequence_number IN NUMBER ,
  p_sub_cal_type IN VARCHAR2 ,
  p_sub_sequence_number IN NUMBER ,
  p_direct_match_ind IN VARCHAR2 )
RETURN VARCHAR2  AS
	v_p_direct_match_ind	BOOLEAN;
BEGIN
	-- Convert char to boolean.
	IF p_direct_match_ind = 'Y' THEN
		v_p_direct_match_ind := TRUE;
	ELSE
		v_p_direct_match_ind := FALSE;
	END IF;
	IF  IGS_EN_GEN_008.enrp_get_within_ci(p_sup_cal_type,
			p_sup_sequence_number,
			p_sub_cal_type,
			p_sub_sequence_number,
			v_p_direct_match_ind) = TRUE THEN
		RETURN 'Y';
	ELSE
		RETURN 'N';
	END IF;
END enrs_get_within_ci;


 PROCEDURE get_all_cur_load_cal (
   p_acad_cal_type       IN VARCHAR2,
   p_effective_dt        IN DATE,
   p_load_cal_table_info_str OUT NOCOPY VARCHAR2
  ) AS

  /*------------------------------------------------------------------
  --Created by  : CKASU, Oracle IDC
  --Date created: 21-JUL-2004
  --this was created  as a part of Bug#3784635
  --Purpose:  This Procedure takes academic cal type and effective date as input and
  --gets all the current term calendar information and returns p_load_cal_table_info_str
  --which contains all current calendar info concatenated by '||' where current
  --calendar info is a combination of sequencenumberand cal_type seperated by '*'.
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What

  --------------------------------------------------------------------*/

   cst_active VARCHAR2(10);
   cst_load   VARCHAR2(10);

  CURSOR c_all_cur_load_cal (cp_cal_type         igs_ca_inst.cal_type%TYPE,
                            cp_effective_dt     DATE
                            )
  IS
       SELECT  DISTINCT  ci.cal_type,
                         ci.sequence_number,
                         ci.alternate_code,
                         ci.start_dt,
                         ci.end_dt,
                         ci.description
       FROM    igs_ca_type ct,
               igs_ca_inst ci,
               igs_ca_stat cs,
               igs_ca_inst_rel cir
      WHERE    cs.s_cal_status = cst_active
      AND      ci.cal_status = cs.cal_status
      AND      ct.s_cal_cat = cst_load
      AND      ci.cal_type = ct.cal_type
      AND      CIR.SUB_CAL_TYPE = CI.CAL_TYPE
      AND      cir.sub_ci_sequence_number =ci.sequence_number
      AND      cir.sup_cal_type = cp_cal_type
      AND      p_effective_dt Between ci.start_dt AND ci.end_dt
      ORDER BY ci.start_dt;

   l_all_cur_load_cal_rec   c_all_cur_load_cal%ROWTYPE;
   l_load_cal_table_info load_cal_table_type;
   l_next_row Number;

 BEGIN

   cst_active  := 'ACTIVE';
   cst_load    := 'LOAD';

   -- encapsulating  all the current term details in l_load_cal_table_info table.
   FOR  l_all_cur_load_cal_rec IN c_all_cur_load_cal(p_acad_cal_type,p_effective_dt) LOOP
     l_next_row := NVL(l_load_cal_table_info.LAST,0) + 1;
     l_load_cal_table_info(l_next_row)  :=  l_all_cur_load_cal_rec;
   END LOOP;

   p_load_cal_table_info_str := get_seqno_caltyp_from_caltable(l_load_cal_table_info);
   --this returns the concatened string which a contains term details seperated by '||'
   --and term details itself is represented as a combination of 'sequence_no*cal_type'

 END get_all_cur_load_cal;


 PROCEDURE get_all_future_load_cal (
   p_acad_cal_type       IN VARCHAR2,
   p_future_ld_cal_table_info_str OUT NOCOPY VARCHAR2
 ) AS

 /*------------------------------------------------------------------
  --Created by  : CKASU, Oracle IDC
  --Date created: 21-JUL-2004
  --this was created  as a part of Bug#3784635
  --Purpose:  This Procedure takes academic cal type as input and gets all
  --the future term calendar information and returns p_future_ld_cal_table_info_str
  --which contains all future calendar info concatenated by '||' where current
  --calendar info is a combination of sequencenumberand cal_type seperated by '*'.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What

  --------------------------------------------------------------------*/

   cst_active VARCHAR2(10);
   cst_load   VARCHAR2(10);

   CURSOR c_all_fut_load_cal (cp_cal_type     igs_ca_inst.cal_type%TYPE,
                                cp_cur_cal_erly_st_dt igs_ca_inst.start_dt%TYPE)
   IS
       SELECT   DISTINCT ci.cal_type,
                         ci.sequence_number,
                         ci.alternate_code,
                         ci.start_dt,
                         ci.end_dt,
                         ci.description
       FROM    igs_ca_type ct,
               igs_ca_inst ci,
               igs_ca_stat cs,
               igs_ca_inst_rel cir
       WHERE    cs.s_cal_status = cst_active
       AND      ci.cal_status = cs.cal_status
       AND      ct.s_cal_cat = cst_load
       AND      ci.cal_type = ct.cal_type
       AND      CIR.SUB_CAL_TYPE = CI.CAL_TYPE
       AND      cir.sub_ci_sequence_number =ci.sequence_number
       AND      cir.sup_cal_type = cp_cal_type
       AND      ci.start_dt > cp_cur_cal_erly_st_dt
       ORDER BY ci.start_dt ;

   l_future_ld_cal_table_info  load_cal_table_type;
   l_cur_load_cal_table_info_str  VARCHAR2(2000);
   l_cur_cal_erly_st_dt  igs_ca_inst.start_dt%TYPE;
   l_cur_load_cal_table_info  load_cal_table_type;
   l_next_row NUMBER;

  BEGIN

     cst_active  := 'ACTIVE';
     cst_load    := 'LOAD';
     -- getting all current term calendar details
     get_all_cur_load_cal (p_acad_cal_type,SYSDATE,l_cur_load_cal_table_info_str);

     --populates current term calendar details in to l_cur_load_cal_table_info pl/sql table
     --where each record in table contains caltype,sequenceno,start date,end date,description
     l_cur_load_cal_table_info := get_cal_tbl_frm_caltyp_seq_lst(l_cur_load_cal_table_info_str);

     --gets the earlier start date among tha start dates of all current term calendars
     IF l_cur_load_cal_table_info IS NOT NULL THEN
       IF l_cur_load_cal_table_info.count > 0 THEN
          l_cur_cal_erly_st_dt :=  l_cur_load_cal_table_info(1).p_load_ci_start_dt ;
       END IF;
     END IF;

     --All the Terms calendars whose startdate is greater than earlier start are selected
     --and those term calendars  which are not part of Current calendars are populated into
     --future term calendar l_future_ld_cal_table_info pl/sql table where each record in
     --table contains caltype,sequenceno,start date,end date,description

     FOR c_fut_load_cal_rec  IN  c_all_fut_load_cal( p_acad_cal_type, l_cur_cal_erly_st_dt)  LOOP

         IF NOT is_fut_cal_exists_as_cur_cal(l_cur_load_cal_table_info,c_fut_load_cal_rec) THEN
             l_next_row := NVL(l_future_ld_cal_table_info.LAST,0) + 1;
             l_future_ld_cal_table_info(l_next_row)  :=  c_fut_load_cal_rec;
         END IF;

     END LOOP;

    --get_seqno_caltyp_from_caltable takes l_future_ld_cal_table_info table as parameter and
    --returns the concatened string which contains term details seperated by '||' and term
    --details itself is represented as a combination of 'sequence_no*cal_type'.
     p_future_ld_cal_table_info_str := get_seqno_caltyp_from_caltable(l_future_ld_cal_table_info);

  END get_all_future_load_cal;

   FUNCTION get_cal_tbl_frm_caltyp_seq_lst (
     p_seqno_caltype_info  VARCHAR2
   ) RETURN load_cal_table_type AS

  /*------------------------------------------------------------------
    --Created by  : CKASU, Oracle IDC
    --Date created: 21-JUL-2004
    --this was created  as a part of Bug#3784635
    --Purpose: This function takes calendar information which contains
    --calendar info concatenated by '||' where current calendar info
    --is a combination of sequencenumber and cal_type seperated by '*'
    --(Example: 300*TERM SU||400*TERM SP||500*DEVRY LOAD ) as input
    --and gets the term Calendar details from the calendar info and encapsulates
    --the information in pl/sql table and returns the Table type as ouput
    --pl/sql table returned contains Records as elements.Each record
    --contains caltype,sequenceno,start date,end date,description
    --
    --Known limitations/enhancements and/or remarks:
    --
    --Change History:
    --Who         When            What

    --------------------------------------------------------------------*/

     l_strtpoint INTEGER;
     l_endpoint  INTEGER;
     l_cindex    INTEGER;
     l_pre_cindex INTEGER;
     l_nth_occurence INTEGER;
     l_seqno_caltype_info  VARCHAR2(2000);
     l_load_cal_table_info load_cal_table_type ;
     l_seqno_and_caltype  VARCHAR2(100);
     l_cal_type  IGS_CA_INST.CAL_TYPE%TYPE;
     l_cal_seqno IGS_CA_INST.SEQUENCE_NUMBER%TYPE;
     l_cal_seq_sep_index INTEGER;
     l_next_row INTEGER;
     CURSOR c_get_cal_inst_info(cp_caltype IGS_CA_INST.CAL_TYPE%TYPE,
                              cp_cal_seqno IGS_CA_INST.SEQUENCE_NUMBER%TYPE)
     IS
         SELECT   ci.cal_type,
                  ci.sequence_number,
                  ci.alternate_code,
                  ci.start_dt,
                  ci.end_dt,
                  ci.description
         FROM    igs_ca_inst ci
         WHERE   ci.cal_type = cp_caltype
         AND     ci.sequence_number = cp_cal_seqno;

     c_load_cal_rec   c_get_cal_inst_info%ROWTYPE;

  BEGIN

   l_strtpoint      :=  0;
   l_pre_cindex     := -1;
   l_nth_occurence  :=  1;

   l_seqno_caltype_info := p_seqno_caltype_info;

   IF l_seqno_caltype_info IS NULL THEN
        RETURN l_load_cal_table_info;
   END IF;

   l_seqno_caltype_info := l_seqno_caltype_info || '||';
   l_cindex := INSTR(l_seqno_caltype_info,'||',1,l_nth_occurence);
   -- getting the poistion of first occurence of '||'
   WHILE (l_cindex <> 0 )  LOOP
       l_strtpoint  :=  l_pre_cindex + 2;
       l_endpoint   :=  l_cindex - l_strtpoint;
       l_pre_cindex :=  l_cindex;
       l_seqno_and_caltype := substr(l_seqno_caltype_info,l_strtpoint,l_endpoint);
       -- l_seqno_and_caltype contains sequence_number*cal_type
       l_cal_seq_sep_index := INSTR(l_seqno_and_caltype,'*',1);
       l_cal_seqno:= SUBSTR(l_seqno_and_caltype,1,l_cal_seq_sep_index - 1);
       l_cal_type := SUBSTR(l_seqno_and_caltype,l_cal_seq_sep_index + 1);
       -- l_cal_seqno ,l_cal_type contains extratcs sequence_number and
       --cal_type from l_seqno_and_caltype

       --this cursor gets the details of calendar whose sequence number and
       --cal_type are l_cal_seqno ,l_cal_typ and populates l_load_cal_table_info
       --table with this information.
       OPEN   c_get_cal_inst_info(l_cal_type,TO_NUMBER(l_cal_seqno));
       FETCH c_get_cal_inst_info INTO c_load_cal_rec;
       IF c_get_cal_inst_info%FOUND THEN
         l_next_row := NVL(l_load_cal_table_info.LAST,0) +1;
         l_load_cal_table_info(l_next_row) := c_load_cal_rec;
       END IF;
       CLOSE c_get_cal_inst_info;
       --now increasing l_nth_occurence by 1 inorder to get index for the next
       --occurence of '||'
       l_nth_occurence := l_nth_occurence + 1;
       l_cindex := INSTR(l_seqno_caltype_info,'||',1,l_nth_occurence);

   END LOOP;
   RETURN l_load_cal_table_info;

  END get_cal_tbl_frm_caltyp_seq_lst;

  FUNCTION get_cur_ld_cal_with_erly_st_dt (
     p_load_cal_table_info_str IN VARCHAR2
   )  RETURN VARCHAR2 AS

   /*------------------------------------------------------------------
  --Created by  : CKASU, Oracle IDC
  --Date created: 21-JUL-2004
  --this was created  as a part of Bug#3784635
  --Purpose:  This function takes  calendar information which contains
  --calendar info concatenated by '||' where current load calendar info
  --is a combination of sequencenumber and cal_type seperated by '*'
  --(Example: 300*TERM SU||400*TERM SP||500*DEVRY LOAD ) as input
  --and gets the term Calendar details which has earlier start date
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
    ckasu      22-JUL-2004    changed the code in if case by removing DELETE Function
  --------------------------------------------------------------------*/

    l_load_cal_table_info load_cal_table_type;
    l_load_cal_with_erly_st_dt load_cal_table_type;
    l_load_cal_table_info_str VARCHAR2(2000);

  BEGIN

     --populates current term calendar details in to l_cur_load_cal_table_info pl/sql table
     --where each record in table contains caltype,sequenceno,start date,end date,description

     l_load_cal_table_info := get_cal_tbl_frm_caltyp_seq_lst(p_load_cal_table_info_str);

     --this deletes all other records in table except the first record which is the
     --current calendar with earlier startdate.
     IF l_load_cal_table_info IS NOT NULL THEN
      IF l_load_cal_table_info.count > 0 THEN
        l_load_cal_with_erly_st_dt(1) := l_load_cal_table_info(1);
        l_load_cal_table_info_str := get_seqno_caltyp_from_caltable(l_load_cal_with_erly_st_dt);
        RETURN l_load_cal_table_info_str;
      END IF;
     END IF;
     RETURN l_load_cal_table_info_str;

  END get_cur_ld_cal_with_erly_st_dt;

  FUNCTION get_load_eff_dt_alias
     RETURN VARCHAR2 AS

  /*------------------------------------------------------------------
  --Created by  : CKASU, Oracle IDC
  --Date created: 21-JUL-2004
  --this was created  as a part of Bug#3784635
  --Purpose:  This function returns the load effective date alias from
  --enrollment calendar configuration
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What

  --------------------------------------------------------------------*/

     CURSOR  c_s_enr_cal_conf
     IS
          SELECT  secc.load_effect_dt_alias
          FROM    igs_en_cal_conf secc
          WHERE   secc.s_control_num = 1;

       l_load_effect_dt_alias igs_en_cal_conf.LOAD_EFFECT_DT_ALIAS%TYPE;

   BEGIN

     --fetch load effective date alias from enrollment calendar configuration
        OPEN c_s_enr_cal_conf;
        FETCH c_s_enr_cal_conf INTO l_load_effect_dt_alias;
        IF c_s_enr_cal_conf%NOTFOUND THEN
           CLOSE c_s_enr_cal_conf;
           RETURN NULL;
        END IF;
        CLOSE c_s_enr_cal_conf;
        RETURN l_load_effect_dt_alias;

  END get_load_eff_dt_alias;

  FUNCTION get_seqno_caltyp_from_caltable (
    p_cal_table_info IN load_cal_table_type
  ) RETURN VARCHAR2 AS

  /*------------------------------------------------------------------
  --Created by  : CKASU, Oracle IDC
  --Date created: 21-JUL-2004
  --this was created  as a part of Bug#3784635
  --Purpose: This function takes pl/sql table as input.this table
  --contains Records as elements.Each record contains caltype,sequenceno,
  --start date,end date,description of load calendars.
  --This functions prepares a String of form sequenceno*cal_type for each
  --record in pl/sql table and concatenates these strings and returns as
  --output.(Example : 300*TERM SU||400*TERM SP||500*DEVRY LOAD)
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What

  --------------------------------------------------------------------*/

   caltype_seq_info VARCHAR2(2000);
   no_of_records  NUMBER;

  BEGIN

  --this returns the concatened string which a contains term details seperated by '||'
  --and term details itself is represented as a combination of 'sequence_no*cal_type'
  IF p_cal_table_info IS NOT NULL THEN
       IF p_cal_table_info.count > 0 THEN
           no_of_records := p_cal_table_info.count;

         FOR i IN p_cal_table_info.first..p_cal_table_info.last LOOP
           IF p_cal_table_info.exists(i) THEN
             IF i = 1  THEN
                caltype_seq_info := caltype_seq_info||p_cal_table_info(i).P_LOAD_CI_SEQ_NUM||'*'||p_cal_table_info(i).P_LOAD_CAL_TYPE;
             ELSE
                caltype_seq_info := caltype_seq_info||'||'||p_cal_table_info(i).P_LOAD_CI_SEQ_NUM||'*'||p_cal_table_info(i).P_LOAD_CAL_TYPE;
             END IF;
           END IF;
         END LOOP;

       END IF;

   END IF;

   RETURN   caltype_seq_info;

  END get_seqno_caltyp_from_caltable;

  FUNCTION is_cur_ld_cal_has_eff_dt_alias  (
    p_acad_cal_type       IN VARCHAR2,
    p_effective_dt        IN DATE,
    p_all_cur_load_cal_info_str OUT NOCOPY VARCHAR2
  ) RETURN BOOLEAN AS

  /*------------------------------------------------------------------
  --Created by  : CKASU, Oracle IDC
  --Date created: 21-JUL-2004
  --this was created  as a part of Bug#3784635
  --Purpose:  This function checks whether all the current term calndar
  --has effective date alias or not and returns TRUE if load effective
  --date alias exists even for any one of current term calendars else
  --returns FALSE
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What

  --------------------------------------------------------------------*/

     CURSOR c_dai_v (cp_cal_type             igs_ca_da_inst_v.cal_type%TYPE,
                     cp_ci_sequence_number   igs_ca_da_inst_v.ci_sequence_number%TYPE,
                     cp_load_effect_dt_alias igs_en_cal_conf.load_effect_dt_alias%TYPE)
     IS
          SELECT   daiv.alias_val
          FROM     igs_ca_da_inst_v daiv
          WHERE    daiv.cal_type = cp_cal_type
          AND      daiv.ci_sequence_number = cp_ci_sequence_number
          AND      daiv.dt_alias = cp_load_effect_dt_alias;

      l_all_cur_load_cal_info_str   VARCHAR2(2000);
      l_load_effect_dt_alias igs_en_cal_conf.LOAD_EFFECT_DT_ALIAS%TYPE;
      l_all_cur_load_cal_info  load_cal_table_type;
      isloaddtaliasfound BOOLEAN;
    BEGIN

      isloaddtaliasfound := FALSE;
      l_load_effect_dt_alias :=  get_load_eff_dt_alias ;
      get_all_cur_load_cal(p_acad_cal_type,p_effective_dt,l_all_cur_load_cal_info_str);
      l_all_cur_load_cal_info := get_cal_tbl_frm_caltyp_seq_lst(l_all_cur_load_cal_info_str);
      p_all_cur_load_cal_info_str := l_all_cur_load_cal_info_str ;
      -- returns TRUE when any one of current term calendars has effective load alias date
      -- and is les than sysdate else return FALSE
      IF l_all_cur_load_cal_info IS NOT NULL THEN

       IF l_all_cur_load_cal_info.count > 0 THEN
         FOR i IN l_all_cur_load_cal_info.first..l_all_cur_load_cal_info.last LOOP
           IF l_all_cur_load_cal_info.exists(i) THEN
             FOR rec_dai_v IN c_dai_v (l_all_cur_load_cal_info(i).P_LOAD_CAL_TYPE,
                                       l_all_cur_load_cal_info(i).P_LOAD_CI_SEQ_NUM,
                                       l_load_effect_dt_alias)
             LOOP
                IF (p_effective_dt >= rec_dai_v.alias_val) THEN
                   isloaddtaliasfound := TRUE;
                   RETURN isloaddtaliasfound;
                END IF;
             END LOOP;
            END IF;
          END LOOP;
       END IF;
      END IF;
      RETURN isloaddtaliasfound;

    END is_cur_ld_cal_has_eff_dt_alias;

  FUNCTION is_fut_cal_exists_as_cur_cal (
   p_all_cur_load_cal_info IN load_cal_table_type,
   p_fut_load_cal_rec  IN  load_cal_rec_type
  ) RETURN BOOLEAN AS
  /*------------------------------------------------------------------
  --Created by  : CKASU, Oracle IDC
  --Date created: 21-JUL-2004
  --this was created  as a part of Bug#3784635
  --Purpose:This function returns TRUE when the passed future term cal
  --is present as one of Current  terms calendars else return FALSE.
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What

  --------------------------------------------------------------------*/

   cal_already_exists  BOOLEAN;

   BEGIN

     cal_already_exists   := FALSE;
     IF p_all_cur_load_cal_info IS NOT NULL THEN
       IF p_all_cur_load_cal_info.count > 0 THEN

         --returns TRUE  when the passed term calendar exists in Current term
         --calendars else returns FALSE
         FOR i IN p_all_cur_load_cal_info.first..p_all_cur_load_cal_info.last LOOP
           IF p_all_cur_load_cal_info.exists(i) THEN
             IF ( p_all_cur_load_cal_info(i).p_load_cal_type    = p_fut_load_cal_rec.p_load_cal_type AND
                  p_all_cur_load_cal_info(i).p_load_ci_seq_num  = p_fut_load_cal_rec.p_load_ci_seq_num AND
                  p_all_cur_load_cal_info(i).p_load_ci_alt_code = p_fut_load_cal_rec.p_load_ci_alt_code AND
                  p_all_cur_load_cal_info(i).p_load_ci_start_dt = p_fut_load_cal_rec.p_load_ci_start_dt AND
                  p_all_cur_load_cal_info(i).p_load_ci_end_dt   = p_fut_load_cal_rec.p_load_ci_end_dt AND
                  p_all_cur_load_cal_info(i).p_load_cal_desc    = p_fut_load_cal_rec.p_load_cal_desc
                 )  THEN

                    cal_already_exists := TRUE;
                    RETURN cal_already_exists;

             END IF;
           END IF;
         END LOOP;
        END IF;
       END IF;

       RETURN  cal_already_exists;

   END is_fut_cal_exists_as_cur_cal;


END IGS_EN_GEN_014;

/
