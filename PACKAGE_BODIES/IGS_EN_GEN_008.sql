--------------------------------------------------------
--  DDL for Package Body IGS_EN_GEN_008
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_GEN_008" AS
/* $Header: IGSEN08B.pls 120.6 2006/02/22 02:22:14 ckasu ship $ */
/*-------------------------------------------------------------------------------------------
--Change History:
--Who         When            What
amuthu     23-Sep-02     Modified the cursor c_sca in batch pre enrollment procedure
                         as per the Core Vs Optional EN TD.

vchappid   04-Jul-01     this function was considering the date aliases defined at the institutional
                         level only. Now it is changed to consider date aliases/dates at person type,
                         unit section level, institutional level in the same hierarchy
nalkumar   04-May-2002   Modified the enrp_get_var_window procedure as per the Bug# 2356997.
prraj      07-May-2002   Truncated the date values to remove timestamp before date
                         comparisons as part of (Bug# 2355143)
nalkumar   14-May-2002   Modified the 'enrp_val_chg_cp' function as per the bug# 2364461.
Nishikant  07OCT2002     UK Enhancement build. Bug#2580731. Five new parameters p_start_day, p_start_month,
                         p_end_day, p_end_month, p_selection_date added in the procedure enrp_ins_btch_prenrl.
Nishikant  16DEC2002     ENCR030(UK Enh) - Bug#2708430. One more parameter p_completion_date added in the procedure
                         enrp_ins_btch_prenrl.
prraj      11-Dec-2003   Replaced reference to view IGS_EN_NSTD_USEC_DL_V
                         with base table IGS_EN_NSTD_USEC_DL Bug# 2750716
knaraset   05-Mar-2003   Modified the date comparison in function enrp_get_ua_del_alwd,
                         such that it returns N, when the first unit discontinuation date is
                         less than or equal to the given effective date. Bug 2833794
myoganat   23-May-2003   Created cursor cur_no_assesment_ind in ENRP_VAL_CHG_CP to
                         check for audit attempt - Bug  #2855870
svenkata  6-Jun-03	 Modified the routine enrp_get_var_window to check for Variation cutoff override at
			 Person Type level. Bug 2829272.
amuthu     04-JUN-2003   added new parameter p_progress_status to enrp_ins_btch_prenrl as part of bug 2829265
                         Also added the same parameter in the call to IGS_EN_GEN_10.enrp_ins_sret/snew_prenrl
kkillams   16-06-2003    Three new parameters are added to the enrp_ins_btch_prenrl procedure as part of bug 2829270
amuthu     03-JUL-2003   Added logic to filter Advance and repeating students before call the call to
--                       enrp_ins_snew_prenrl and enrp_ins_sret_prenrl instead of checking it within
--                       the above mentioned procedures.
rvivekan   29-JUL-2003	 Modified several message_name variables from varchar2(30) to varchar2(2000) as
			 a part of bug#3045405
vkarthik   21-Jan-2004   Removed recursive search from the function enrp_get_within_ci for checking if
                         the passed calendars are related anywhere in the hierarchy and replaced it with
                         direct search as part of Bug 3083153

snambaka   14-Mar-2005	 Truncated the Effective Dates passed to the Procedure enrp_get_var_window
			 to ensure the standard validation between the Dates with and without time stamps.
			 Bug :3930440
ckasu      20-Feb-2006	 modified cursor c_sca of enrp_ins_btch_prenrl procedure as a part of bug#5049068

-------------------------------------------------------------------------------------------*/

FUNCTION enrp_get_pr_outcome(
  p_person_id IN NUMBER,
  p_course_cd IN VARCHAR2
) RETURN VARCHAR2 ;

FUNCTION enrp_get_ua_del_alwd( p_cal_type            IN VARCHAR2 ,
                               p_ci_sequence_number  IN NUMBER ,
                               p_effective_dt        IN DATE,
                               p_uoo_id              IN NUMBER
                             ) RETURN VARCHAR2 AS
/******************************************************************
Created By        :
Date Created By   :
Purpose           : This function is used to determine whether deletion of unit attempts
                    is allowed within the nominated teaching calendar instance as at the
                    nominated date
Known limitations,
enhancements,
remarks            :
Change History
Who        When          What

******************************************************************/


  -- cursor for getting the date aliases that are defined
  -- at the person type level for the logged on person
  --modified cursor for bug 3696257
  CURSOR cur_pe_usr_adisc (cp_person_type igs_pe_person_types.person_type_code%TYPE)
  IS
  SELECT   nvl(daiv.absolute_val,
               IGS_CA_GEN_001.calp_set_alias_value(daiv.absolute_val,
               IGS_CA_GEN_002.cals_clc_dt_from_dai(daiv.ci_sequence_number,
               daiv.CAL_TYPE,
               daiv.DT_ALIAS, daiv.sequence_number) )  ) alias_val
     FROM  igs_pe_usr_adisc_all pua,
           igs_ca_da_inst daiv
     WHERE  daiv.cal_type          = p_cal_type
     AND    daiv.ci_sequence_number = p_ci_sequence_number
     AND    daiv.dt_alias          = pua.disc_dt_alias
     AND    pua.person_type        = cp_person_type
     ORDER BY 1;

  -- cursor for getting the dates that are defined
  -- at the unit level for the logged on person and for the uoo_id passed
  CURSOR cur_usec_disc_dl
  IS
  SELECT usec_disc_dl_date alias_val
  FROM   igs_en_usec_disc_dl
  WHERE  uoo_id = p_uoo_id
  ORDER BY usec_disc_dl_date, administrative_unit_status;

  -- cursor for getting the date aliases that are defined
  -- at the institutional level for the logged on person
  CURSOR cur_unit_disc_crt
  IS
  SELECT daiv.alias_val
  FROM   igs_ps_unit_disc_crt uddc,
         igs_ca_da_inst_v daiv
  WHERE  uddc.delete_ind         = 'N'
  AND    daiv.cal_type           = p_cal_type
  AND    daiv.ci_sequence_number = p_ci_sequence_number
  AND    daiv.dt_alias           = uddc.unit_discont_dt_alias
  ORDER BY daiv.alias_val;

  -- Rowtype variables
  l_cur_pe_usr_adisc   cur_pe_usr_adisc%ROWTYPE;
  l_cur_usec_disc_dl   cur_usec_disc_dl%ROWTYPE;
  l_cur_unit_disc_crt  cur_unit_disc_crt%ROWTYPE;

  l_v_person_type      igs_pe_person_types.person_type_code%TYPE;

  -- constant return variables
  cst_yes              CONSTANT VARCHAR2(1) := 'Y';
  cst_no               CONSTANT VARCHAR2(1) := 'N';

BEGIN
  -- Get the person type of the logged on user by calling the function
  l_v_person_type := igs_en_gen_008.enrp_get_person_type(p_course_cd =>NULL);

  -- If the logged on user is a self service type then a person type will be returned
  -- If the user logged is a back-office user the validations defined at Unit level has to be validated
  IF l_v_person_type IS NOT NULL THEN

    -- Check for the Person Type there exists date aliases at the Person Level
    -- If exists then do the validations else validations at Unit Level has to be validated
    OPEN cur_pe_usr_adisc(l_v_person_type);
    FETCH cur_pe_usr_adisc INTO l_cur_pe_usr_adisc;
    IF cur_pe_usr_adisc%FOUND THEN

      -- If the records are found then close the cursor and reopen the cursor
      -- for the person_type in a loop to process all the fetched records
      CLOSE cur_pe_usr_adisc;
      OPEN cur_pe_usr_adisc(l_v_person_type);
      LOOP
      FETCH cur_pe_usr_adisc INTO l_cur_pe_usr_adisc;
      EXIT WHEN cur_pe_usr_adisc%NOTFOUND;

      -- If the alias_val is less than the date passed into the function
      -- then then function has to return 'N'
      IF (l_cur_pe_usr_adisc.alias_val <= TRUNC(p_effective_dt)) THEN
        CLOSE cur_pe_usr_adisc;
        RETURN cst_no;
      END IF;
      END LOOP;
      CLOSE cur_pe_usr_adisc;

      -- If the alias_val is not less than the date passed into the function
      -- then then function has to return 'Y'
      RETURN cst_yes;
    ELSE

      -- Closing the cursor after checking that no date aliases are defined at person level
      CLOSE cur_pe_usr_adisc;
    END IF;
  END IF;

  -- Check for the Uoo_id passed there exists dead line dates at the Unit Level
  -- If exists then do the validations else validations at Institutional Level has to be validated
  OPEN cur_usec_disc_dl;
  FETCH cur_usec_disc_dl INTO l_cur_usec_disc_dl;
  IF cur_usec_disc_dl%FOUND THEN

    -- If the records are found then close the cursor and reopen the cursor
    -- for the Uoo_id in a loop to process all the fetched records
    CLOSE cur_usec_disc_dl;
    OPEN cur_usec_disc_dl;
    LOOP
    FETCH cur_usec_disc_dl INTO l_cur_usec_disc_dl;
    EXIT WHEN cur_usec_disc_dl%NOTFOUND;

    -- If the alias_val is less than the date passed into the function
    -- then then function has to return 'N'
    IF (l_cur_usec_disc_dl.alias_val <= TRUNC(p_effective_dt)) THEN
      CLOSE cur_usec_disc_dl;
      RETURN cst_no;
    END IF;
    END LOOP;
    CLOSE cur_usec_disc_dl;

    -- If the alias_val is not less than the date passed into the function
    -- then then function has to return 'Y'
    RETURN cst_yes;
  ELSE
    CLOSE cur_usec_disc_dl;
  END IF;

  -- Check for the Logged on user there exists date aliases at the Institutional Level
  -- If exists then do the validations else the function should return 'Y'
  OPEN cur_unit_disc_crt;
  FETCH cur_unit_disc_crt INTO l_cur_unit_disc_crt;
  IF cur_unit_disc_crt%FOUND THEN

    -- If the records are found then close the cursor and reopen the cursor
    -- for the parameters in a loop to process all the fetched records
    CLOSE cur_unit_disc_crt;
    OPEN cur_unit_disc_crt;
    LOOP
    FETCH cur_unit_disc_crt INTO l_cur_unit_disc_crt;
    EXIT WHEN cur_unit_disc_crt%NOTFOUND;
    IF (l_cur_unit_disc_crt.alias_val <= TRUNC(p_effective_dt)) THEN
      CLOSE cur_unit_disc_crt;
      RETURN cst_no;
    END IF;
    END LOOP;
    CLOSE cur_unit_disc_crt;
    RETURN cst_yes;
  ELSE
    CLOSE cur_unit_disc_crt;
    -- If no dead line dates are defined at any level then the function should return 'Y'
    RETURN cst_yes;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGS_EN_GEN_008.enrp_get_ua_del_alwd');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
END enrp_get_ua_del_alwd;


FUNCTION enrp_get_ua_rty( p_person_id          IN NUMBER ,
                          p_course_cd          IN VARCHAR2 ,
                          p_unit_cd            IN VARCHAR2 ,
                          p_cal_type           IN VARCHAR2 ,
                          p_ci_sequence_number IN NUMBER,
                          p_uoo_id             IN NUMBER
                        ) RETURN VARCHAR2 AS
 -------------------------------------------------------------------------------------------
 --Who         When            What
 --kkillams    25-04-2003      New paramater p_uoo_id is added to the function.
 --                            w.r.t. bug number 2829262
 -------------------------------------------------------------------------------------------
BEGIN
DECLARE
        v_grade                         igs_as_su_stmptout.grade%TYPE;
        v_grading_schema_cd             igs_as_su_stmptout.grading_schema_cd%TYPE;
        v_version_number                igs_as_su_stmptout.version_number%TYPE;
        v_s_result_type                 igs_as_grd_sch_grade.s_result_type%TYPE;

        CURSOR c_suao (
                cp_person_id            igs_en_su_attempt.person_id%TYPE,
                cp_course_cd            igs_en_su_attempt.course_cd%TYPE,
                cp_uoo_id               igs_en_su_attempt.uoo_id%TYPE)IS
                SELECT  suao.grade,
                        suao.grading_schema_cd,
                        suao.version_number,
                        suao.finalised_outcome_ind
                FROM    igs_as_su_stmptout suao
                WHERE   suao.person_id = cp_person_id AND
                        suao.course_cd = cp_course_cd AND
                        suao.uoo_id    = cp_uoo_id
                ORDER BY suao.outcome_dt;

        CURSOR c_gsg (
                cp_grading_schema_cd    igs_as_su_stmptout.grading_schema_cd%TYPE,
                cp_version_number       igs_as_su_stmptout.version_number%TYPE,
                cp_grade                igs_as_su_stmptout.grade%TYPE) IS
                SELECT  gsg.s_result_type
                FROM    igs_as_grd_sch_grade gsg
                WHERE   gsg.grading_schema_cd = cp_grading_schema_cd AND
                        gsg.version_number = cp_version_number AND
                        gsg.grade = cp_grade;
BEGIN
        -- This function gets the result type of a student IGS_PS_UNIT attempt.
        -- The routine will determine the latest finalized grade for the UA and
        -- return it's result type. The valid return values are those in the
        -- s_result_type table.
        -- 1. Select the latest finalised grade from the IGS_AS_SU_STMPTOUT
        -- table.
        FOR     v_suao_row      IN      c_suao( p_person_id,
                                                p_course_cd,
                                                p_uoo_id) LOOP
                IF ((v_suao_row.finalised_outcome_ind = 'Y') OR
                   (v_suao_row.grade IS NULL))THEN
                        v_grade := v_suao_row.grade;
                        v_grading_schema_cd := v_suao_row.grading_schema_cd;
                        v_version_number := v_suao_row.version_number;
                END IF;
        END LOOP;
        IF (v_grade IS NULL) THEN
                RETURN NULL;
        END IF;
        -- 2. Get the result type from the grading schema
        OPEN    c_gsg(
                        v_grading_schema_cd,
                        v_version_number,
                        v_grade);
        FETCH   c_gsg   INTO    v_s_result_type;
        CLOSE   c_gsg;
        RETURN  v_s_result_type;
END;
EXCEPTION
        WHEN OTHERS THEN
        fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGS_EN_GEN_008.enrp_get_ua_rty');
        IGS_GE_MSG_STACK.ADD;
        app_exception.raise_exception;
END enrp_get_ua_rty;


FUNCTION enrp_get_uddc_aus( p_discontinued_dt       IN  DATE,
                            p_cal_type              IN  VARCHAR2,
                            p_ci_sequence_number    IN  NUMBER,
                            p_admin_unit_status_str OUT NOCOPY VARCHAR2,
                            p_alias_val             OUT NOCOPY DATE,
                            p_uoo_id                IN  NUMBER
                          ) RETURN VARCHAR2 AS
/******************************************************************
Created By        :
Date Created By   :
Purpose           : This function is used to determine the recent administrative unit status
                    that applies to the the student Unit attempt discontinued date
Known limitations,
enhancements,
remarks            :
Change History
Who      When        What
amuthu   12-Jun-02   Modified the code to return the only value that was being
                     passed out NOCOPY using the out NOCOPY parameter and passing null to the out NOCOPY parameter.
vchappid 04-Jul-01   this function was considering the date aliases defined at the institutional
                     level only. Now it is changed to consider date aliases/dates at person type,
                     unit section level, institutional level in the same hierarchy
kkillams 14-Apr-03   Removed the cur_per_unit_disc cursor and related logic w.r.t. bug the 2893263
rvivekan 17-nov-2003 Bug3264064. Changed the datatype of variable holding the concatenated
                     administrative unit status list to l_v_admin_unit_status_str varchar(2000)

******************************************************************/

  -- cursor for getting the dates that are defined
  -- at the unit level for the logged on person and for the uoo_id passed
  CURSOR cur_unit_usec_disc
  IS
  SELECT usec_disc_dl_date alias_val,administrative_unit_status
  FROM   igs_en_usec_disc_dl
  WHERE  uoo_id = p_uoo_id
  ORDER BY usec_disc_dl_date;

  -- cursor for getting the date aliases that are defined
  -- at the institutional level for the logged on person
  CURSOR cur_inst_date_aliases
  IS
  SELECT igs_ca_gen_001.calp_set_alias_value(dai.absolute_val,
                                             igs_ca_gen_002.cals_clc_dt_from_dai(dai.ci_sequence_number,
                                                                                 dai.cal_type,
                                                                                 dai.dt_alias,
                                                                                 dai.sequence_number
                                                                                )
                                            ) alias_val,
         uddc.administrative_unit_status,
         uddc.dflt_ind
  FROM  igs_ca_da_inst dai,
        igs_ps_unit_disc_crt uddc
  WHERE dai.cal_type           = p_cal_type                AND
        dai.ci_sequence_number = p_ci_sequence_number      AND
        dai.dt_alias           = uddc.unit_discont_dt_alias
  ORDER BY 1;

  -- Rowtype Variables
  l_cur_unit_usec_disc                cur_unit_usec_disc%ROWTYPE;
  l_cur_inst_date_aliases             cur_inst_date_aliases%ROWTYPE;
  l_v_alias_val                       igs_ca_da_inst_v.alias_val%TYPE;
  l_v_administrative_unit_status      igs_ps_unit_disc_crt.administrative_unit_status%TYPE;
  l_v_return_value                    igs_ps_unit_disc_crt.administrative_unit_status%TYPE;
  l_v_admin_unit_status_str           VARCHAR2(2000);
  l_b_dflt_admin_unit_found           BOOLEAN;
  l_n_aus_count                       NUMBER(2);
BEGIN
  -- Check for the Uoo_id there exists date aliases defined at the Unit Level
  -- If exists then do the validations else validations at Institutional Level has to be validated
  OPEN  cur_unit_usec_disc;
  FETCH cur_unit_usec_disc INTO l_cur_unit_usec_disc;
  IF cur_unit_usec_disc%FOUND THEN
    -- If the records are found then close the cursor and reopen the cursor
    -- for the Uoo_id in a loop to process all the fetched records
    CLOSE cur_unit_usec_disc;
    OPEN  cur_unit_usec_disc;
    LOOP
    FETCH cur_unit_usec_disc INTO l_cur_unit_usec_disc;
    EXIT WHEN cur_unit_usec_disc%NOTFOUND;
    -- checking if this is the first time the loop is entered
    IF (l_v_alias_val IS NULL) THEN
      -- if it is the first time then all the alias_val is NULL
      -- if the discontinuation date is less than the alias value then NULL is returned
      IF (TRUNC(p_discontinued_dt) <  l_cur_unit_usec_disc.alias_val) THEN
        p_alias_val             := NULL;
        p_admin_unit_status_str := NULL;
        l_v_return_value        := NULL;
        RETURN l_v_return_value;
      ELSE
        l_v_alias_val                  := l_cur_unit_usec_disc.alias_val;
        l_v_administrative_unit_status := l_cur_unit_usec_disc.administrative_unit_status;
        -- Checking if the current administrative status is null
        -- if it is NULL then ';' is not appended
        IF l_cur_unit_usec_disc.administrative_unit_status IS NOT NULL THEN
          l_v_admin_unit_status_str := RPAD(l_cur_unit_usec_disc.administrative_unit_status,10,' ')||',';
        ELSE
          l_v_admin_unit_status_str := RPAD(l_cur_unit_usec_disc.administrative_unit_status,10,' ');
        END IF;
      END IF;
    ELSE  -- l_v_alias_val is not NULL
      IF (TRUNC(p_discontinued_dt) >=  l_v_alias_val and TRUNC(p_discontinued_dt) < l_cur_unit_usec_disc.alias_val) THEN
          p_alias_val             := l_v_alias_val;
          IF l_v_admin_unit_status_str IS NOT NULL
             AND l_v_administrative_unit_status IS NULL
             AND length(TRIM(l_v_admin_unit_status_str)) = 11 THEN
            p_admin_unit_status_str := l_v_admin_unit_status_str;
            l_v_return_value        := TRIM(SUBSTR(TRIM(l_v_admin_unit_status_str),1,10));
          ELSE
            p_admin_unit_status_str := l_v_admin_unit_status_str;
            l_v_return_value        := l_v_administrative_unit_status;
          END IF;
          RETURN l_v_return_value;
      ELSE
        IF l_cur_unit_usec_disc.alias_val = l_v_alias_val THEN
          -- If the date aliases are having the same absolute value then the administrative status
          -- is concatenated and the value is returned else the recent date alias is returned
          IF l_cur_unit_usec_disc.administrative_unit_status IS NOT NULL THEN
            l_v_admin_unit_status_str := l_v_admin_unit_status_str||RPAD(l_cur_unit_usec_disc.administrative_unit_status,10,' ')||',';
          ELSE
            l_v_admin_unit_status_str := l_v_admin_unit_status_str||RPAD(l_cur_unit_usec_disc.administrative_unit_status,10,' ');
          END IF;
        ELSE
          IF l_cur_unit_usec_disc.administrative_unit_status IS NOT NULL THEN
            l_v_admin_unit_status_str := RPAD(l_cur_unit_usec_disc.administrative_unit_status,10,' ')||',';
          ELSE
            l_v_admin_unit_status_str := RPAD(l_cur_unit_usec_disc.administrative_unit_status,10,' ');
          END IF;
          l_b_dflt_admin_unit_found := FALSE;
        END IF;
        -- If the more recent date alias is found then the OUT NOCOPY parameter value is set to the recent one
        IF l_b_dflt_admin_unit_found = FALSE THEN
          l_b_dflt_admin_unit_found := TRUE;
          l_v_administrative_unit_status  := l_cur_unit_usec_disc.administrative_unit_status;
        ELSE
          l_v_administrative_unit_status := NULL;
        END IF;
        l_v_alias_val := l_cur_unit_usec_disc.alias_val;
      END IF;
    END IF;
    END LOOP;
    CLOSE cur_unit_usec_disc;
    -- when none of the date aliases are not violating the validations
    -- then the recent values are returned from the function
    p_alias_val := l_v_alias_val;
    IF l_v_admin_unit_status_str IS NOT NULL
       AND l_v_administrative_unit_status IS NULL
       AND length(TRIM(l_v_admin_unit_status_str)) = 11 THEN
      p_admin_unit_status_str := l_v_admin_unit_status_str;
      l_v_return_value        := TRIM(SUBSTR(TRIM(l_v_admin_unit_status_str),1,10));
    ELSE
      p_admin_unit_status_str := l_v_admin_unit_status_str;
      l_v_return_value := l_v_administrative_unit_status;
    END IF;
    RETURN l_v_return_value;
  ELSE
    CLOSE cur_unit_usec_disc;
  END IF;
  -- selecting the IGS_PS_UNIT discontinuation date aliases
  -- in the student IGS_PS_UNIT attempt teaching period
  OPEN cur_inst_date_aliases;
  LOOP
  FETCH cur_inst_date_aliases INTO l_cur_inst_date_aliases;
  EXIT WHEN cur_inst_date_aliases%NOTFOUND;
  -- searching for the administrative IGS_PS_UNIT status
  -- applicable to the discontinued date
  IF (l_v_alias_val IS NULL) THEN
    IF (TRUNC(p_discontinued_dt) <  l_cur_inst_date_aliases.alias_val) THEN
      p_alias_val := NULL;
      p_admin_unit_status_str := NULL;
      l_v_return_value := NULL;
      RETURN l_v_return_value;
    ELSE
      l_v_alias_val := l_cur_inst_date_aliases.alias_val;
      IF l_cur_inst_date_aliases.dflt_ind = 'Y' THEN
        l_v_administrative_unit_status := l_cur_inst_date_aliases.administrative_unit_status;
      ELSE
        l_v_administrative_unit_status := NULL;
      END IF;
      IF l_cur_inst_date_aliases.administrative_unit_status IS NOT NULL THEN
        l_v_admin_unit_status_str := RPAD(l_cur_inst_date_aliases.administrative_unit_status,10,' ')||',';
      ELSE
        l_v_admin_unit_status_str := RPAD(l_cur_inst_date_aliases.administrative_unit_status,10,' ');
      END IF;
    END IF;
  ELSE -- l_v_alias_val is not NULL
    IF (TRUNC(p_discontinued_dt) >=  l_v_alias_val and TRUNC(p_discontinued_dt) < l_cur_inst_date_aliases.alias_val) THEN
      p_alias_val := l_v_alias_val;
      IF l_v_admin_unit_status_str IS NOT NULL
         AND l_v_administrative_unit_status IS NULL
         AND length(TRIM(l_v_admin_unit_status_str)) = 11 THEN
        p_admin_unit_status_str := l_v_admin_unit_status_str;
        l_v_return_value        := TRIM(SUBSTR(TRIM(l_v_admin_unit_status_str),1,10));
      ELSE
        p_admin_unit_status_str := l_v_admin_unit_status_str;
        l_v_return_value := l_v_administrative_unit_status;
      END IF;
      RETURN l_v_return_value;
    ELSE
      IF l_cur_inst_date_aliases.alias_val = l_v_alias_val THEN
        IF l_cur_inst_date_aliases.administrative_unit_status IS NOT NULL THEN
          l_v_admin_unit_status_str := l_v_admin_unit_status_str||RPAD(l_cur_inst_date_aliases.administrative_unit_status,10,' ')||',';
        ELSE
          l_v_admin_unit_status_str := l_v_admin_unit_status_str||RPAD(l_cur_inst_date_aliases.administrative_unit_status,10,' ');
        END IF;
      ELSE
        IF l_cur_inst_date_aliases.administrative_unit_status IS NOT NULL THEN
          l_v_admin_unit_status_str := RPAD(l_cur_inst_date_aliases.administrative_unit_status,10,' ')||',';
        ELSE
          l_v_admin_unit_status_str := RPAD(l_cur_inst_date_aliases.administrative_unit_status,10,' ');
        END IF;
        l_b_dflt_admin_unit_found := FALSE;
      END IF;
      IF l_cur_inst_date_aliases.dflt_ind = 'Y' THEN
        IF l_b_dflt_admin_unit_found = FALSE THEN
          l_b_dflt_admin_unit_found := TRUE;
          l_v_administrative_unit_status  := l_cur_inst_date_aliases.administrative_unit_status;
        ELSE
          l_v_administrative_unit_status := NULL;
        END IF;
      ELSE
        IF l_b_dflt_admin_unit_found = FALSE THEN
          l_v_administrative_unit_status := NULL;
        END IF;
      END IF;
    l_v_alias_val :=    l_cur_inst_date_aliases.alias_val;
    END IF;
  END IF;
  END LOOP;

  -- return the unit_administrative_status
  p_alias_val             := l_v_alias_val;
  IF l_v_admin_unit_status_str IS NOT NULL
     AND l_v_administrative_unit_status IS NULL
     AND length(TRIM(l_v_admin_unit_status_str)) = 11 THEN
    p_admin_unit_status_str := l_v_admin_unit_status_str;
    l_v_return_value        := TRIM(SUBSTR(TRIM(l_v_admin_unit_status_str),1,10));
  ELSE
    p_admin_unit_status_str := l_v_admin_unit_status_str;
    l_v_return_value        := l_v_administrative_unit_status;
  END IF;
  RETURN l_v_return_value;

END enrp_get_uddc_aus;


FUNCTION enrp_get_ug_pg_crs( p_course_cd      IN VARCHAR2 ,
                             p_version_number    NUMBER
                           ) RETURN VARCHAR2 AS
BEGIN
DECLARE
        v_govt_course_type      IGS_PS_TYPE.govt_course_type%TYPE ;
        CURSOR  c_crv_ct IS
                SELECT  ct.govt_course_type
                FROM    igs_ps_ver      crv,
                        igs_ps_type ct
                WHERE   crv.course_cd           = p_course_cd AND
                        crv.version_number      = p_version_number AND
                        crv.course_type         = ct.course_type;
BEGIN

    v_govt_course_type := NULL;

        -- Validate the input parameter.
        IF p_course_cd IS NULL OR
                        p_version_number IS NULL THEN
                RETURN NULL;
        END IF;
        -- Retrieve the government IGS_PS_COURSE type for the IGS_PS_COURSE code.
        OPEN c_crv_ct;
        FETCH c_crv_ct INTO v_govt_course_type;
        CLOSE c_crv_ct;
        -- Determine if the IGS_PS_COURSE is an undergraduate or a postgraduate IGS_PS_COURSE.
        IF v_govt_course_type IN (8, 9, 10, 13, 20, 21, 22, 30, 40, 41) THEN
                RETURN 'UG';
        ELSIF v_govt_course_type IN (1, 2, 3, 4, 5, 6, 7, 11, 12, 42) THEN
                RETURN 'PG';
        END IF;
        RETURN NULL;
EXCEPTION
        WHEN OTHERS THEN
                IF c_crv_ct%ISOPEN THEN
                        CLOSE c_crv_ct;
                END IF;
                RAISE;
END;
EXCEPTION
        WHEN OTHERS THEN
        Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_008.enrp_get_ug_pg_crs');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END enrp_get_ug_pg_crs;

FUNCTION enrp_get_us_title(
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_person_id IN NUMBER )
RETURN VARCHAR2 AS
BEGIN   -- enrp_get_us_title
        -- This routine will get the IGS_EN_UNIT_SET title from either the
        -- IGS_AS_SU_SETATMPT, IGS_PS_OFR_UNIT_SET or IGS_EN_UNIT_SET table,
        -- taking the lowest level which is set.
DECLARE
        v_override_title                igs_as_su_setatmpt.override_title%TYPE;
        v_cous_override_title   igs_ps_ofr_unit_set.override_title%TYPE;
        v_us_title                      igs_en_unit_set.title%TYPE;
        CURSOR c_susa IS
                SELECT  susa.override_title
                FROM    igs_as_su_setatmpt      susa
                WHERE   susa.person_id          = p_person_id AND
                        susa.course_cd          = p_course_cd AND
                        susa.unit_set_cd              = p_unit_set_cd AND
                        susa.sequence_number    = p_sequence_number;
        CURSOR c_us_cous IS
                SELECT  cous.override_title,
                        us.title
                FROM    igs_en_unit_set us,
                        igs_ps_ofr_unit_set cous
                WHERE   us.unit_set_cd                  = p_unit_set_cd AND
                        us.version_number               = p_us_version_number AND
                        cous.unit_set_cd(+)             = us.unit_set_cd AND
                        cous.us_version_number(+)       = us.version_number AND
                        cous.course_cd(+)                     = p_course_cd AND
                        cous.crv_version_number(+)      = p_version_number AND
                        cous.cal_type(+)                      = p_cal_type;
BEGIN
        -- If the IGS_PE_PERSON details are set then query for a IGS_PE_PERSON based title
        IF (p_person_id IS NOT NULL AND
                        p_sequence_number IS NOT NULL) THEN
                OPEN c_susa;
                FETCH c_susa INTO v_override_title;
                IF (c_susa%FOUND AND
                                v_override_title IS NOT NULL) THEN
                        CLOSE c_susa;
                        RETURN v_override_title;
                END IF;
                CLOSE c_susa;
        END IF;
        -- Query the titles from IGS_PS_UNIT set and IGS_PS_COURSE offering IGS_PS_UNIT set
        OPEN c_us_cous;
        FETCH c_us_cous INTO    v_cous_override_title,
                                v_us_title;
        IF (c_us_cous%NOTFOUND) THEN
                CLOSE c_us_cous;
                RETURN NULL;
        ELSE
                CLOSE c_us_cous;
                IF (v_cous_override_title IS NOT NULL) THEN
                        RETURN v_cous_override_title;
                ELSE
                        RETURN v_us_title;
                END IF;
        END IF;
EXCEPTION
        WHEN OTHERS THEN
                IF (c_susa%ISOPEN) THEN
                        CLOSE c_susa;
                END IF;
                IF (c_us_cous%ISOPEN) THEN
                        CLOSE c_us_cous;
                END IF;
END;

END enrp_get_us_title;


FUNCTION enrp_get_var_window( p_cal_type           IN VARCHAR2,
                              p_ci_sequence_number IN NUMBER,
                              p_effective_dt       IN DATE,
                              p_uoo_id             IN NUMBER) RETURN BOOLEAN AS
/******************************************************************
Created By        :
Date Created By   :
Purpose           : This function is used to determine if the effective date of an insert, update or
                    delete of a student unit attempts is within the enrollments variation window
Known limitations,
enhancements,
remarks            :
Change History
Who      When        What
vchappid 04-Jul-01   this function was considering the date aliases defined at the institutional
                     level only. Now it is changed to consider date aliases/dates at unit section level,
                     institutional level in the same hierarchy
kkillams 27-Feb-03   Modified cur_dai_v Cursor, replaced * with alias_val w.r.t. bug 2749648
svenkata  6-Jun-03   Added new validation to check if the Variation cutt off has been overriden at the Person Type level.Bug 2829272
snambaka 14-Mar-05   Truncated the p_effective_dt and l_cur_en_nstd_usec_dl.enr_dl_date
		      to ensure date validation without timestamp to avaoid inconsistency.
******************************************************************/
  -- Determine if the effective date of an insert, update or delete
  -- of a student IGS_PS_UNIT attempt is within the enrollments variation window.
  -- This is determined  by an enrollments variation cutoff date within the
  -- teaching period calendar instance of the student IGS_PS_UNIT attempt.

  -- cursor for getting the dates that are defined
  -- at the unit level for the logged on person and for the uoo_id passed
  CURSOR cur_en_nstd_usec_dl
  IS
  SELECT enr_dl_date
  FROM   igs_en_nstd_usec_dl
  WHERE  uoo_id = p_uoo_id
  AND    function_name='VARIATION_CUTOFF'
  ORDER BY enr_dl_date;

  -- cursor for getting the variation cut off date aliases that are defined
  -- at the institutional level
  CURSOR cur_s_enr_cal_conf
  IS
  SELECT variation_cutoff_dt_alias
  FROM   IGS_EN_CAL_CONF
  WHERE  s_control_num = 1;

  -- cursor for getting the date aliases that are defined
  -- at the institutional level for the logged on person and for the cal type, sequence number passed
  CURSOR cur_dai_v( cp_dt_alias  igs_en_cal_conf.variation_cutoff_dt_alias%TYPE)
  IS
  SELECT alias_val
  FROM   igs_ca_da_inst_v
  WHERE  cal_type           = p_cal_type
  AND    ci_sequence_number = p_ci_sequence_number
  AND    dt_alias           = cp_dt_alias
  ORDER BY alias_val DESC;

  -- Cursor to check if an override has been setup for the 'Variation Cutoff' Step at the Person Type level.
  CURSOR c_get_ovr (p_person_type igs_pe_person.party_type%TYPE ) IS
  SELECT 'x'
  FROM IGS_PE_USR_AVAL
  WHERE person_type = p_person_type  AND
  validation = 'OVR_VAR_CUT_OFF' AND
  override_ind = 'Y' ;

  -- ROWTYPE Variables
  l_cur_en_nstd_usec_dl       cur_en_nstd_usec_dl%ROWTYPE;
  l_cur_s_enr_cal_conf        cur_s_enr_cal_conf%ROWTYPE;
  l_cur_dai_v                 cur_dai_v%ROWTYPE;
  l_person_type		      igs_pe_person.party_type%TYPE := NULL ;
  l_dummy		      VARCHAR2(10);
  l_effective_dt 	  	l_cur_dai_v.alias_val%TYPE ;
BEGIN
  --
  -- Check if an override exists for Variation Cut off Window at the Person Type level. First , get the Person Type in context.
  l_person_type := enrp_get_person_type ( P_COURSE_CD => NULL );
  l_effective_dt  := trunc(p_effective_dt);

  IF l_person_type IS NOT NULL THEN
	OPEN c_get_ovr( l_person_type );
	FETCH c_get_ovr INTO l_dummy ;
	--
	-- If an override exists at the Person Type level , return TRUE.
	IF c_get_ovr%FOUND THEN
		CLOSE c_get_ovr;
		RETURN TRUE;
	END IF ;
	CLOSE c_get_ovr;
  END IF ;

  -- Added next IF condition as per the Bug# 2356997.
  IF fnd_function.test('IGSENVAR') = TRUE THEN
    RETURN TRUE;
  ELSE
    -- Check if the deadline dates are defined at the Unit level
    OPEN cur_en_nstd_usec_dl;
    FETCH cur_en_nstd_usec_dl INTO l_cur_en_nstd_usec_dl;
    -- If the dates are defined then the cursor is closed and reopened to loop through all the records
    IF cur_en_nstd_usec_dl%FOUND THEN
      CLOSE cur_en_nstd_usec_dl;
      OPEN cur_en_nstd_usec_dl;
      LOOP
      FETCH cur_en_nstd_usec_dl INTO l_cur_en_nstd_usec_dl;
      EXIT WHEN cur_en_nstd_usec_dl%NOTFOUND;
      -- If the effective deadline date passed into the function  is greater than
      -- the deadline alias value at the Unit Level then the function returns FALSE
      IF (l_effective_dt > trunc(l_cur_en_nstd_usec_dl.enr_dl_date)) THEN
        RETURN FALSE;
      END IF;
      END LOOP;
      CLOSE cur_en_nstd_usec_dl;
      -- If the effective deadline date passed into the function  is not greater than
      -- the deadline alias value at the Unit Level then the function returns TRUE
      RETURN TRUE;
    ELSE
      -- If the date aliases are not defined at the Unit Level then
      -- close the cursor and then do next level validations
      CLOSE cur_en_nstd_usec_dl;
    END IF;
    -- This module gets whether it is possible as at the effective date to
    --vary  IGS_PS_UNIT attempts in the nominated teaching period cal instance
    OPEN  cur_s_enr_cal_conf;
    FETCH cur_s_enr_cal_conf INTO l_cur_s_enr_cal_conf;
    IF (cur_s_enr_cal_conf%NOTFOUND) THEN
      CLOSE cur_s_enr_cal_conf;
      RETURN TRUE;
    END IF;
    CLOSE cur_s_enr_cal_conf;
    IF(l_cur_s_enr_cal_conf.variation_cutoff_dt_alias IS NULL) THEN
      RETURN TRUE;
    END IF;
    OPEN  cur_dai_v(l_cur_s_enr_cal_conf.variation_cutoff_dt_alias);
    FETCH cur_dai_v INTO l_cur_dai_v;
    IF cur_dai_v%NOTFOUND THEN
      CLOSE cur_dai_v;
        RETURN TRUE;
    END IF;
    CLOSE cur_dai_v;
    IF (l_effective_dt >   trunc(l_cur_dai_v.alias_val)) THEN
      RETURN FALSE;
    END IF;
    RETURN TRUE;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGS_EN_GEN_008.enrp_get_var_window');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
END enrp_get_var_window;

FUNCTION enrp_get_within_ci(
  p_sup_cal_type        IN VARCHAR2 ,
  p_sup_sequence_number IN NUMBER ,
  p_sub_cal_type        IN VARCHAR2 ,
  p_sub_sequence_number IN NUMBER ,
  p_direct_match_ind    IN boolean )
RETURN BOOLEAN AS
/* --Change History:
Who         When            What
vkarthik    21-Jan-2004     Removed recursive search from the function for checking if
                            the passed calendars are related anywhere in the hierarchy */
        CURSOR  c_cir (
                        cp_sup_cal_ty         igs_ca_inst_rel.sup_cal_type%TYPE,
                        cp_sup_ci_seq_num     igs_ca_inst_rel.sup_ci_sequence_number%TYPE,
                        cp_sub_cal_ty         igs_ca_inst_rel.sub_cal_type%TYPE,
                        cp_sub_ci_seq_num     igs_ca_inst_rel.sub_ci_sequence_number%TYPE) IS
                        SELECT  sup_cal_type,
                                sup_ci_sequence_number
                        FROM    igs_ca_inst_rel
                        WHERE
                                sup_cal_type            = cp_sup_cal_ty         AND
                                sup_ci_sequence_number  = cp_sup_ci_seq_num     AND
                                sub_cal_type            = cp_sub_cal_ty         AND
                                sub_ci_sequence_number  = cp_sub_ci_seq_num;
        l_ret_status    BOOLEAN := FALSE;
        vc_cir          c_cir%ROWTYPE;
BEGIN
        -- This module determines whether the nominated subordinate
        -- calendar is within the nominated superior calendar.
        OPEN c_cir(p_sup_cal_type, p_sup_sequence_number,
                   p_sub_cal_type, p_sub_sequence_number);
        FETCH c_cir INTO vc_cir;
        IF c_cir%FOUND THEN
                l_ret_status := TRUE;
        END IF;
        CLOSE c_cir;
        RETURN l_ret_status;
END enrp_get_within_ci;

FUNCTION get_commence_date_range(
        p_start_day          IN NUMBER,
        p_start_month        IN NUMBER,
        p_end_day            IN NUMBER,
        p_end_month          IN NUMBER,
        p_commencement_dt    IN DATE)
RETURN VARCHAR2 AS
    /*  HISTORY
        WHO         WHEN         WHAT
        Nishikant   07OCT2002    This local function Created in the UK Enhancement Build. Enh Bug#2580731.
                                 It returns TRUE if the Commencement date falls between the Start_day/Start_month AND
                                 End_day/End_month. Else it returns FALSE. This is being used in the cursor c_sca of the
                                 Procedure enrp_ins_btch_prenrl.    */

    l_year               NUMBER;
    l_start_day          NUMBER;
    l_start_month        NUMBER;
    l_end_day            NUMBER;
    l_end_month          NUMBER;

    PROCEDURE leap_chk_start_date(
            p_l_start_day          IN OUT NOCOPY NUMBER,
            p_l_start_month        IN OUT NOCOPY NUMBER,
            p_l_year               IN     NUMBER
            ) AS
    BEGIN
        --If the Start day and Month is 29thFeb then check the year is a LEAP year or not.
        --If its a LEAP year then fine. If not then make the Start day and Month to 28th of February.
            IF SUBSTR(LAST_DAY(TO_DATE('28'||'-'||'02'||'-'||TO_CHAR(p_l_year),'DD-MM-YYYY')),1,2) = '28' THEN
               p_l_start_day := 28;
            END IF;
    END leap_chk_start_date;

    PROCEDURE leap_chk_end_date(
            p_l_end_day            IN OUT NOCOPY NUMBER,
            p_l_end_month          IN OUT NOCOPY NUMBER,
            p_l_year               IN     NUMBER
            ) AS
    BEGIN
        --If the End day and Month is 29thFeb then check the year is a LEAP year or not.
        --If its a LEAP year then fine. If not then make the End day and Month to 1st of March.
            IF SUBSTR(LAST_DAY(TO_DATE('28'||'-'||'02'||'-'||TO_CHAR(p_l_year),'DD-MM-YYYY')),1,2) = '28' THEN
               p_l_end_day := 1;
               p_l_end_month := 3;
            END IF;
    END leap_chk_end_date;

BEGIN
    --If any of the parameter p_start_day, p_end_day, p_start_month and p_end_month IS NULL then return TRUE
    IF  p_start_day  IS NULL OR p_start_month  IS NULL OR
        p_end_day  IS NULL OR p_end_month  IS NULL  THEN
         RETURN 'TRUE';
    END IF;

    -- The year part of the Start and End date is based on the year part of the p_commencement_date parameter
    l_year        := TO_NUMBER(TO_CHAR(p_commencement_dt, 'YYYY'));
    l_start_day   := p_start_day;
    l_start_month := p_start_month;
    l_end_day     := p_end_day;
    l_end_month   := p_end_month;

    -- If Min Program Attempt Start Month < Max Program Attempt Start Month
    --     OR ( Min Program Attempt Start Month = Max Program Attempt Start Month AND
    --          Min Program Attempt Start Day < Max Program Attempt Start  Day )
    -- (E.g.: Start Date = 10-Feb and End Date = 20-Feb , the range spans across 10 Days of the same Year only )
    -- And if the commencement date falls between the range then return TRUE
    IF  ( p_start_month < p_end_month ) OR
        ( p_start_month = p_end_month AND p_start_day <= p_end_day ) THEN

        IF  l_start_day = 29 AND l_start_month = 02 THEN
             leap_chk_start_date(l_start_day, l_start_month, l_year);
        END IF;
        IF  l_end_day = 29 AND l_end_month = 02 THEN
             leap_chk_end_date(l_end_day, l_end_month, l_year);
        END IF;

        IF  p_commencement_dt BETWEEN TO_DATE(l_start_day||'-'||p_start_month||'-'||TO_CHAR(l_year),'DD-MM-YYYY')
                                  AND TO_DATE(l_end_day||'-'||l_end_month||'-'||TO_CHAR(l_year),'DD-MM-YYYY') THEN
             RETURN 'TRUE';
        END IF;

    -- If Min Program Attempt Start Month > Max Program Attempt Start Month
    --     OR ( Min Program Attempt Start Month = Max Program Attempt Start Month AND
    --           Min Program Attempt Start Day > Max Program Attempt Start  Day )
    -- (E.g.: Start Date = 20-Feb and End Date = 10-Feb , the range spans across YEARS )
    -- Here arises two scenarios.
    ELSIF ( p_start_month > p_end_month ) OR
          ( p_start_month = p_end_month AND p_start_day > p_end_day ) THEN

        IF  l_start_day = 29 AND l_start_month = 02 THEN
             leap_chk_start_date(l_start_day, l_start_month, l_year-1);
        END IF;
        IF  l_end_day = 29 AND l_end_month = 02 THEN
             leap_chk_end_date(l_end_day, l_end_month, l_year);
        END IF;

        -- First Scenario
        -- Check whether the commencement date lies between the range of the Start Day/Month with the year of the commencement date Minus 1
        -- and the End Day/Month with the year of the commencement date. If yes then return TRUE.
        IF  p_commencement_dt BETWEEN TO_DATE(l_start_day||'-'||l_start_month||'-'||TO_CHAR(l_year - 1),'DD-MM-YYYY')
                                  AND TO_DATE(l_end_day||'-'||l_end_month||'-'||TO_CHAR(l_year),'DD-MM-YYYY') THEN
             RETURN 'TRUE';
        END IF;

        --Setting all the local variables again, in case value of these might have been changed
        l_start_day   := p_start_day;
        l_start_month := p_start_month;
        l_end_day     := p_end_day;
        l_end_month   := p_end_month;

        IF  l_start_day = 29 AND l_start_month = 02 THEN
             leap_chk_start_date(l_start_day, l_start_month, l_year);
        END IF;
        IF  l_end_day = 29 AND l_end_month = 02 THEN
             leap_chk_end_date(l_end_day, l_end_month, l_year+1);
        END IF;

        -- Second Scenario
        -- Check whether the commencement date lies between the range of the Start Day/Month with the year of the commencement date
        -- and the End Day/Month with the year of the commencement date plus 1. If yes then return TRUE.
        IF  p_commencement_dt BETWEEN TO_DATE(l_start_day||'-'||l_start_month||'-'||TO_CHAR(l_year),'DD-MM-YYYY')
                                     AND TO_DATE(l_end_day||'-'||l_end_month||'-'||TO_CHAR(l_year + 1),'DD-MM-YYYY') THEN
             RETURN 'TRUE';
        END IF;
    END IF;

    --If fails above then return FALSE
    RETURN 'FALSE';
END get_commence_date_range;

PROCEDURE enrp_ins_btch_prenrl(
  p_course_cd                  IN VARCHAR2 ,
  p_acad_cal_type              IN VARCHAR2 ,
  p_acad_sequence_number       IN NUMBER ,
  p_course_type                IN VARCHAR2 ,
  p_responsible_org_unit_cd    IN VARCHAR2 ,
  p_location_cd                IN VARCHAR2 ,
  p_attendance_type            IN VARCHAR2 ,
  p_attendance_mode            IN VARCHAR2 ,
  p_student_comm_type          IN VARCHAR2 ,
  p_person_group_id            IN NUMBER ,
  p_dflt_enrolment_cat         IN VARCHAR2 ,
  p_units_indicator            IN VARCHAR2 ,
  p_override_enr_form_due_dt   IN DATE ,
  p_override_enr_pckg_prod_dt  IN DATE ,
  p_enr_cal_type               IN VARCHAR2 ,
  p_enr_sequence_number        IN NUMBER ,
  p_last_enrolment_cat         IN VARCHAR2 ,
  p_admission_cat              IN VARCHAR2 ,
  p_adm_cal_type               IN VARCHAR2 ,
  p_adm_sequence_number        IN NUMBER ,
  p_dflt_confirmed_ind         IN VARCHAR2 ,
  p_unit1_unit_cd              IN VARCHAR2 ,
  p_unit1_cal_type             IN VARCHAR2 ,
  p_unit1_location_cd          IN VARCHAR2 ,
  p_unit1_unit_class           IN VARCHAR2 ,
  p_unit2_unit_cd              IN VARCHAR2 ,
  p_unit2_cal_type             IN VARCHAR ,
  p_unit2_location_cd          IN VARCHAR2 ,
  p_unit2_unit_class           IN VARCHAR2 ,
  p_unit3_unit_cd              IN VARCHAR2 ,
  p_unit3_cal_type             IN VARCHAR2 ,
  p_unit3_location_cd          IN VARCHAR2 ,
  p_unit3_unit_class           IN VARCHAR2 ,
  p_unit4_unit_cd              IN VARCHAR2 ,
  p_unit4_cal_type             IN VARCHAR2 ,
  p_unit4_location_cd          IN VARCHAR2 ,
  p_unit4_unit_class           IN VARCHAR2 ,
  p_unit5_unit_cd              IN VARCHAR2 ,
  p_unit5_cal_type             IN VARCHAR2 ,
  p_unit5_location_cd          IN VARCHAR2 ,
  p_unit5_unit_class           IN VARCHAR2 ,
  p_unit6_unit_cd              IN VARCHAR2 ,
  p_unit6_cal_type             IN VARCHAR2 ,
  p_unit6_location_cd          IN VARCHAR2 ,
  p_unit6_unit_class           IN VARCHAR2 ,
  p_unit7_unit_cd              IN VARCHAR2 ,
  p_unit7_cal_type             IN VARCHAR2 ,
  p_unit7_location_cd          IN VARCHAR2 ,
  p_unit7_unit_class           IN VARCHAR2 ,
  p_unit8_unit_cd              IN VARCHAR2 ,
  p_unit8_cal_type             IN VARCHAR2 ,
  p_unit8_location_cd          IN VARCHAR2 ,
  p_unit8_unit_class           IN VARCHAR2 ,
  p_unit9_unit_cd              IN VARCHAR2 ,     --cloumns are added w.r.t. YOP-EN build by kkillams from p_unit9_unit_cd to p_unit_set_cd2
  p_unit9_cal_type             IN VARCHAR2 ,
  p_unit9_location_cd          IN VARCHAR2 ,
  p_unit9_unit_class           IN VARCHAR2 ,
  p_unit10_unit_cd             IN VARCHAR2 ,
  p_unit10_cal_type            IN VARCHAR2 ,
  p_unit10_location_cd         IN VARCHAR2 ,
  p_unit10_unit_class          IN VARCHAR2 ,
  p_unit11_unit_cd             IN VARCHAR2 ,
  p_unit11_cal_type            IN VARCHAR2 ,
  p_unit11_location_cd         IN VARCHAR2 ,
  p_unit11_unit_class          IN VARCHAR2 ,
  p_unit12_unit_cd             IN VARCHAR2 ,
  p_unit12_cal_type            IN VARCHAR2 ,
  p_unit12_location_cd         IN VARCHAR2 ,
  p_unit12_unit_class          IN VARCHAR2 ,
  p_unit_set_cd1               IN VARCHAR2 ,
  p_unit_set_cd2               IN VARCHAR2 ,
  -- The Below five parameters are added as part of the Enh bug#2580731
  p_start_day                  IN NUMBER,
  p_start_month                IN NUMBER,
  p_end_day                    IN NUMBER,
  p_end_month                  IN NUMBER,
  p_selection_date             IN DATE,
  --Below parameter added as part of ENCR030(UK Enh) - Bug#2708430
  p_completion_date            IN DATE ,
  p_log_creation_dt            OUT NOCOPY DATE,
  p_progress_stat              IN VARCHAR2,
  p_dflt_enr_method            IN VARCHAR2,
  p_load_cal_type              IN VARCHAR2,
  p_load_ci_seq_num            IN NUMBER)
AS
/*  HISTORY
   WHO        WHEN            WHAT
   ayedubat   25-MAY-2002    Changed the cursor,c_acaiv to replace the view,IGS_AD_PS_APPL_INST_APLINST_V
                             with the base table,IGS_AD_PS_APPL_INST and also replaced the function calls
                             Igs_En_Gen_002.enrp_get_acai_offer and Igs_En_Gen_014.ENRS_GET_WITHIN_CI as aprt of the bug fix: 2384449
   Nishikant  11JUN2002      Bug#2392277. The cursor c_sca modified to add a condition to check whether any of the unit code parameter is provided or not.
                             If provided then the pre enrollment process will consider all the unit code(s) provided for the persons
                             evenif they have already enrolled into any unit in the provided enrollment period.
   Nishikant  04OCT2002      UK Enhancement build. Bug#2580731. Five new parameters p_start_day, p_start_month, p_end_day, p_end_month, p_selection_date
                             added to the procedure. Also the cursor c_sca modified to call local Function get_commence_date_range.
   Nishikant  16DEC2002      ENCR030(UK Enh), Bug#2708430. One more parameter p_completion date added to the signature.
   ptandon    23-JUN-2003    The Cursor c_sca was modified to replace call to the IGS_EN_GEN_014.ENRS_GET_WITHIN_CI routine with
                             direct joins to the calendar instance tables. Bug# 3004806.
   svanukur   02-jul-2003    The cursors c_sca and c_acaiv were modified to include only the active members of a groupid
                              as per bug# 3030782
   rvivekan  29-JUL-2003	Modified several message_name variables from varchar2(30) to varchar2(2000) as
				a part of bug#3045405
   ckasu     20-Feb-2006      modified cursor c_sca as a part of performance bug#5049068

*/
BEGIN   -- enrp_ins_btch_prenrl
        -- This routine will pre-enrol a group of students in
        -- ?batch? mode as specified by the parameters passed to it.
        -- The routine will process both new and returning students,
        -- with the logic being the following:
        -- New Students:
        -- * Loop through IGS_AD_PS_APPL_INST_APLINST_V records matching the academic period
        -- and the specified IGS_PS_COURSE offering option parameters (eg. IGS_PS_COURSE code,
        -- IGS_AD_LOCATION, etc).
        -- * Call the ENRP_INS_SNEW_PRENRL routine to perform the pre-enrolment on each
        -- student.
        -- Returning Students:
        -- * Loop through IGS_EN_STDNT_PS_ATT records with a status of ENROLLED,
        -- INACTIVE, INTERMIT or UNCONFIRM matching the specified IGS_PS_COURSE offering
        -- option parameters.
        -- * Call the ENRP_INS_SRET_PRENRL routine to perform the pre-enrolment on
        -- each student.
        -- The output from the processing is logged to the IGS_GE_S_LOG table, which produces
        -- an- exception report.
        -- Following is a description of the parameters:
        -- p_course_cd; the IGS_PS_COURSE on which to match students. Can be %.
        -- p_acad_cal_type, p_acad_sequence_number; the academic calendar type the
        -- pre-enrolment is for.
        -- p_location_cd, p_attendance_type, p_attendance_mode; the elements of the
        -- student's  enrolled IGS_PS_COURSE offering option on which to match. All of these
        -- can be %
        -- p_student_comm_type; the commencement type of students to process, being
        -- ?NEW? or  ?RETURN?. No ALL option is permitted.
        -- p_person_id_group (optional); a IGS_PE_PERSON id group from which to limit the
        -- students  processed. This will allow the pre-enrolments to be confined to
        -- any nominated group of specific students.
        -- p_dflt_enrolment_cat (optional); indicates the default enrolment cat. This
        -- value will only be used if the student has not had one specified (via the
        -- admission category)  through admissions, or if (for re-enrolling) there
        -- wasn?t a category from a previous enrolment period.
        -- p_enrol_cal_type, p_enrol_sequence_number; the target enrolment period for
        -- all of the  students pre-enrolled. Applies to only returning students. New
        -- students are always derived from their admission period.
        -- p_units_indicator; indicates whether to pre-enrol IGS_PS_UNIT attempts.
        -- p_dflt_fee_cat (optional); the fee category to assign to new students being
        -- pre-enrolled. Only applies to new students. Any fee category assigned to
        -- the student through admissions will take precedence.
        -- p_dflt_correspondence_cat (optional); the correspondence category to assign
        -- to new students being pre-enrolled. Only applies to new students.
        -- p_dflt_confirmed_ind; indicates whether to default the created IGS_PS_COURSE/IGS_PS_UNIT
        -- attempts to confirmed or not (defaults to N). For returning students it
        -- only applies to the  IGS_PS_UNIT attempts as the IGS_PS_COURSE attempt will have
        -- already been confirmed.
        -- p_override_enr_form_due_dt (optional); the enrolment form due date which
        -- will be entered as the override against the students pre-enrolment
        -- detail. This will override  the date alias stored against the enrolment
        -- period calendar instance.
        -- p_override_enr_pckg_prod_dt (optional); the enrolment package production
        -- date which  will be entered as the override against the students
        -- pre-enrolment detail. This will  override the date alias stored against
        -- the enrolment period calendar.
        -- p_unit1_unit_cd, p_unit1_cal_type, p_unit1_location_cd,
        --  p_unit1_unit_class (1-8)
        -- (optional): represent the IGS_PS_UNIT attempts in which to enrol all students being
        -- pre-enrolled. The version number is not specified, as it will assume the
        -- current  ACTIVE and non-expired version. The calendar instance will be
        -- determined from the academic calendar instance in which the
        -- pre-enrolment is occurring. IGS_GE_NOTE: In the  first instance, this will only
        -- be possible for NEW students.
DECLARE
        cst_enrolled            CONSTANT VARCHAR(10) := 'ENROLLED';
        cst_inactive            CONSTANT VARCHAR(10) := 'INACTIVE';
        cst_intermit            CONSTANT VARCHAR(10) := 'INTERMIT';
        cst_active              CONSTANT VARCHAR(10) := 'ACTIVE';
        cst_success             CONSTANT VARCHAR(10) := 'SUCCESS';
        cst_error               CONSTANT VARCHAR2(5) := 'ERROR';
        cst_return              CONSTANT VARCHAR(10) := 'RETURN';
        cst_exception           CONSTANT VARCHAR(10) := 'EXCEPTION';
        cst_pre_enrol           CONSTANT VARCHAR(10) := 'PRE-ENROL';
        cst_new                 CONSTANT VARCHAR(10) := 'NEW';

        CURSOR c_sca IS
                SELECT  sca.person_id,
                        sca.course_cd
                FROM    IGS_EN_STDNT_PS_ATT     sca,
                        IGS_PS_VER              crv,
                        IGS_PS_STAT             cs
                WHERE   sca.course_cd           LIKE p_course_cd AND
                        sca.cal_type            = p_acad_cal_type AND
                        sca.location_cd                 LIKE p_location_cd AND
                        sca.attendance_type     LIKE p_attendance_type AND
                        sca.attendance_mode     LIKE p_attendance_mode AND
                        sca.course_attempt_status IN (
                                                cst_enrolled,
                                                cst_inactive,
                                                cst_intermit) AND
                        (p_person_group_id      IS NULL OR
                        EXISTS (SELECT  'x'
                                FROM    IGS_PE_PRSID_GRP_MEM gm
                                WHERE   gm.group_id  = p_person_group_id AND
                                        gm.person_id = sca.person_id AND
                                       (gm.end_date IS NULL OR gm.end_date >= trunc(sysdate))AND
                                       (gm.start_date IS NULL OR gm.start_date <= trunc(sysdate)))) AND
                        crv.course_cd           = sca.course_cd AND
                        crv.version_number      = sca.version_number AND
                        crv.course_status               = cs.course_status AND
                        cs.s_course_status      = cst_active AND
                        crv.course_type like p_course_type AND
                        (crv.responsible_org_unit_cd LIKE p_responsible_org_unit_cd OR
                         EXISTS (SELECT 'x'
                                 FROM    IGS_OR_INST_ORG_BASE_V ou,
                                         IGS_OR_STATUS os
                                 WHERE   ou.PARTY_NUMBER  LIKE p_responsible_org_unit_cd AND
                                         ou.org_status   = os.org_status AND
                                         ou.inst_org_ind = 'O' AND
                                         os.s_org_status = cst_active AND
                                         IGS_OR_GEN_001.ORGP_GET_WITHIN_OU(
                                          ou.PARTY_NUMBER,
                                          ou.start_dt,
                                          crv.responsible_org_unit_cd,
                                          crv.responsible_ou_start_dt,
                                          'N') = 'Y')) AND
                -- IGS_GE_NOTE: this section of the query deals with determining if the student has
                -- already been pre-enrolled and whether they may require a IGS_PS_UNIT pre-enrolment
                        (
                        NOT EXISTS      (
                                SELECT  person_id
                                FROM    IGS_AS_SC_ATMPT_ENR
                                WHERE   person_id = sca.person_id AND
                                                course_cd = sca.course_cd AND
                                                cal_type = p_enr_cal_type AND
                                                ci_sequence_number = p_enr_sequence_number) OR
                -- The bellow condition is added by Nishikant - bug#2392277 - 11JUN2002.
                -- Its checking whether any of the unit code parameter is provided or not.
                        (   p_unit1_unit_cd is not null   OR
                            p_unit2_unit_cd is not null   OR
                            p_unit3_unit_cd is not null   OR
                            p_unit4_unit_cd is not null   OR
                            p_unit5_unit_cd is not null   OR
                            p_unit6_unit_cd is not null   OR
                            p_unit7_unit_cd is not null   OR
                            p_unit8_unit_cd is not null   OR
                            p_unit9_unit_cd is not null   OR
                            p_unit10_unit_cd is not null  OR
                            p_unit11_unit_cd is not null  OR
                            p_unit12_unit_cd is not null     ) OR
                        ( ( p_units_indicator = 'Y' OR p_units_indicator = 'CORE_ONLY') AND
                         EXISTS (
                                SELECT  course_cd
                                FROM    IGS_PS_PAT_OF_STUDY pos
                                WHERE   course_cd = sca.course_cd AND
                                                version_number = sca.version_number) AND
                         NOT EXISTS     (
				SELECT  person_id
				FROM  IGS_EN_SU_ATTEMPT sua,
				IGS_CA_INST_REL cr
				WHERE sua.person_id = sca.person_id                AND
					sua.course_cd = sca.course_cd                AND
					sua.cal_type = cr.sub_cal_type                  AND
					sua.ci_sequence_number = cr.sub_ci_sequence_number AND
					cr.sup_cal_type = p_acad_cal_type              AND
					cr.sup_ci_sequence_number= p_acad_sequence_number)
                        ))
                -- The Below Function call added as part of the UK Enhancement. Enh bug#2580731 - 04OCT2002
                        AND get_commence_date_range(
                                        p_start_day,
                                        p_start_month,
                                        p_end_day,
                                        p_end_month,
                                        sca.commencement_dt) = 'TRUE';

        CURSOR c_scae (
                cp_person_id    IGS_AS_SC_ATMPT_ENR.person_id%TYPE,
                cp_course_cd    IGS_AS_SC_ATMPT_ENR.course_cd%TYPE,
                cp_start_dt     IGS_CA_INST.start_dt%TYPE) IS
                SELECT  scae.enrolment_cat
                FROM    IGS_AS_SC_ATMPT_ENR     scae,
                        IGS_CA_INST             ci
                WHERE   scae.person_id  = cp_person_id AND
                        scae.course_cd  = cp_course_cd AND
                        ci.cal_type     = scae.cal_type AND
                        ci.sequence_number = scae.ci_sequence_number AND
                        ci.start_dt     <= cp_start_dt;
        v_scae_rec      c_scae%ROWTYPE;

  -- Cursor to fetch the list of students eligible to pre-enrollment
  CURSOR c_acaiv IS
    SELECT  acai.person_id,
            acai.course_cd,
            acai.admission_appl_number,
            acai.nominated_course_cd,
            acai.sequence_number
    FROM  IGS_AD_PS_APPL_INST acai,
          IGS_AD_APPL         aa,
          IGS_PS_VER          crv,
          IGS_PS_STAT         cs
    WHERE
      acai.course_cd          LIKE p_course_cd                        AND
      acai.location_cd        LIKE p_location_cd                      AND
      acai.attendance_mode    LIKE p_attendance_mode                  AND
      acai.attendance_type    LIKE p_attendance_type                  AND
      aa.person_id              =  acai.person_id                     AND
      aa.admission_appl_number  =  acai.admission_appl_number         AND
      aa.admission_cat        LIKE p_admission_cat                    AND
      aa.acad_cal_type          =  p_acad_cal_type                    AND
      aa.acad_ci_sequence_number = p_acad_sequence_number             AND
      (( p_adm_cal_type     IS NULL        AND
         p_adm_sequence_number    IS NULL)           OR
       ( NVL(acai.adm_cal_type,aa.adm_cal_type) = p_adm_cal_type AND
         NVL(acai.adm_ci_sequence_number,aa.adm_ci_sequence_number) = p_adm_sequence_number) ) AND
      EXISTS( SELECT 'X'
              FROM IGS_AD_OU_STAT       os,
                   IGS_AD_OFR_RESP_STAT rs
              WHERE os.adm_outcome_status = acai.adm_outcome_status        AND
                    rs.adm_offer_resp_status = acai.adm_offer_resp_status  AND
                    IGS_AD_GEN_008.Admp_Get_Saos(acai.adm_outcome_status) IN ('OFFER','COND-OFFER')      AND
                    IGS_AD_GEN_008.Admp_Get_Saors(acai.adm_offer_resp_status) NOT IN ('LAPSED','REJECTED')) AND
      (p_person_group_id is null            OR
      EXISTS (SELECT 'x'
              FROM  IGS_PE_PRSID_GRP_MEM gm
              WHERE gm.group_id  = p_person_group_id AND
                    gm.person_id   = acai.person_id AND
                    (gm.end_date IS NULL OR gm.end_date >= trunc(sysdate))AND
                    (gm.start_date IS NULL OR gm.start_date <= trunc(sysdate))   )) AND
      crv.course_cd       =  acai.course_cd                           AND
      crv.version_number    = acai.crv_version_number                 AND
      crv.course_status     = cs.course_status                        AND
      cs.s_course_status    = cst_active                              AND
      crv.course_type    LIKE p_course_type                           AND
      (crv.responsible_org_unit_cd LIKE p_responsible_org_unit_cd OR
       EXISTS (SELECT 'x'
               FROM IGS_OR_UNIT   ou,
                    IGS_OR_STATUS   os
               WHERE ou.org_unit_cd LIKE p_responsible_org_unit_cd AND
                     ou.org_status =  os.org_status AND
                     os.s_org_status = cst_active AND
                     IGS_OR_GEN_001.ORGP_GET_WITHIN_OU(
                       ou.org_unit_cd,
                       ou.start_dt,
                       crv.responsible_org_unit_cd,
                       crv.responsible_ou_start_dt,'N') = 'Y' ) )     AND
      -- IGS_GE_NOTE: this section of the query deals with determining if the student has
      -- already been pre-enrolled and whether they may require a IGS_PS_UNIT pre-enrolment
      (NOT EXISTS (
              SELECT  person_id
              FROM  IGS_EN_STDNT_PS_ATT
              WHERE person_id = acai.person_id AND
                    course_cd = acai.course_cd AND
                    adm_admission_appl_number = acai.admission_appl_number AND
                    adm_nominated_course_cd =  acai.nominated_course_cd AND
                    adm_sequence_number = acai.sequence_number)   OR
        (p_unit1_unit_cd is not null   OR
         p_unit2_unit_cd is not null   OR
         p_unit3_unit_cd is not null   OR
         p_unit4_unit_cd is not null   OR
         p_unit5_unit_cd is not null   OR
         p_unit6_unit_cd is not null   OR
         p_unit7_unit_cd is not null   OR
         p_unit8_unit_cd is not null   OR
         p_unit9_unit_cd is not null   OR
         p_unit10_unit_cd is not null  OR
         p_unit11_unit_cd is not null  OR
         p_unit12_unit_cd is not null) OR
        ( ( p_units_indicator = 'Y' OR p_units_indicator = 'CORE_ONLY') AND
         EXISTS (
             SELECT course_cd
             FROM  IGS_PS_PAT_OF_STUDY pos
             WHERE course_cd = acai.course_cd AND
                   version_number = acai.crv_version_number )  AND
         NOT EXISTS (
             SELECT  person_id
             FROM  IGS_EN_SU_ATTEMPT sua,
                   IGS_CA_INST_REL cr
             WHERE sua.person_id = acai.person_id                AND
                   sua.course_cd = acai.course_cd                AND
                   sua.cal_type = cr.sub_cal_type                  AND
                   sua.ci_sequence_number = cr.sub_ci_sequence_number AND
                   cr.sup_cal_type = p_acad_cal_type              AND
                   cr.SUP_CI_SEQUENCE_NUMBER= p_acad_sequence_number) ))
    ORDER BY
      acai.person_id,
      acai.course_cd,
      acai.offer_dt DESC;

        CURSOR c_eci IS
                SELECT  start_dt
                FROM    IGS_CA_INST eci
                WHERE   cal_type        = p_enr_cal_type AND
                        sequence_number = p_enr_sequence_number;
        --new cursor is by kkillams added w.r.t. to YOP-EN build bug id :2156956
        CURSOR c_yop_us_st(cp_person_id   NUMBER,
                           cp_course_cd   VARCHAR2,
                           cp_unit_set_cd VARCHAR2)IS
                        SELECT sca.course_cd,susa.unit_set_cd
                        FROM IGS_AS_SU_SETATMPT  susa,
                             IGS_EN_STDNT_PS_ATT sca
                        WHERE sca.person_id   =cp_person_id
                        AND   sca.course_cd   =cp_course_cd
                        AND   susa.person_id  =sca.person_id
                        AND   susa.course_cd  =sca.course_cd
                        AND   susa.unit_set_cd=cp_unit_set_cd
                        AND   susa.selection_dt IS NOT NULL
                        AND   susa.rqrmnts_complete_dt IS NULL
                        AND   susa.end_dt IS NULL;
        r_yop_us_st c_yop_us_st%ROWTYPE;
        CURSOR c_load_cal(p_acad_cal_type IGS_CA_INST.CAL_TYPE%TYPE,
                          p_acad_seq_num  IGS_CA_INST.SEQUENCE_NUMBER%TYPE) IS
        SELECT rel.sub_cal_type, rel.sub_ci_sequence_number FROM igs_ca_inst_rel rel,
                                                                 igs_ca_inst ci,
                                                                 igs_ca_type cal
                                                            WHERE rel.sup_cal_type           = p_acad_cal_type
                                                            AND   rel.sup_ci_sequence_number = p_acad_seq_num
                                                            AND   rel.sub_cal_type           = ci.cal_type
                                                            AND   rel.sub_ci_sequence_number = ci.sequence_number
                                                            AND   rel.sub_cal_type           = cal.cal_type
                                                            AND   cal.s_cal_cat              = 'LOAD'
                                                            AND   cal.closed_ind             = 'N'
                                                            ORDER BY ci.start_dt;

        v_eci_rec               c_eci%ROWTYPE;
        v_person_id             IGS_AD_PS_APPL_INST.person_id%TYPE;
        v_course_cd             IGS_AD_PS_APPL_INST.course_cd%TYPE;
        v_log_creation_dt       DATE ;
        v_log_error_ind         VARCHAR2(1) := 'N';
        v_warn_level            VARCHAR2(10) := NULL;
        v_message_name          Varchar2(2000) := NULL;
        successful_total        NUMBER := 0;
        exception_total         NUMBER := 0;
        v_output_message        VARCHAR(255) := NULL;
        l_us_count               NUMBER := 0;
        l_load_cal_type         igs_ca_inst.cal_type%TYPE;
        l_load_seq_num          igs_ca_inst.sequence_number%TYPE;
        l_enr_method            igs_en_method_type.enr_method_type%TYPE;
        l_return_status         VARCHAR2(10);
        l_message               VARCHAR2(100);
        l_mesg_txt VARCHAR2(4000);
        vl_process              BOOLEAN;
        v_prog_outcome          igs_pr_ou_type.s_progression_outcome_type%TYPE;
        l_enc_message_name VARCHAR2(2000);
       l_app_short_name VARCHAR2(10);
       l_message_name VARCHAR2(100);
        l_msg_index NUMBER;
BEGIN

        v_person_id          := NULL ;
        v_course_cd          := NULL ;
        v_log_creation_dt    := NULL ;

        -- Initialise the log for reporting of IGS_GE_EXCEPTIONS
        IGS_GE_GEN_003.genp_ins_log (cst_pre_enrol,
                                p_course_cd || ',' ||
                                p_acad_cal_type || ',' ||
                                TO_CHAR(p_acad_sequence_number) || ',' ||
                                p_course_type || ',' ||
                                p_responsible_org_unit_cd || ',' ||
                                TO_CHAR(p_person_group_id) || ',' ||
                                p_location_cd || ',' ||
                                p_attendance_mode || ',' ||
                                p_attendance_type || ',' ||
                                p_student_comm_type || ',' ||
                                p_dflt_enrolment_cat || ',' ||
                                p_units_indicator || ',' ||
                                igs_ge_date.igschar(p_override_enr_form_due_dt) || ',' ||
                                igs_ge_date.igscharDT(p_override_enr_pckg_prod_dt) || ',' ||
                                p_enr_cal_type || ',' ||
                                TO_CHAR(p_enr_sequence_number) || ',' ||
                                p_last_enrolment_cat || ',' ||
                                p_admission_cat || ',' ||
                                p_adm_cal_type || ',' ||
                                TO_CHAR(p_adm_sequence_number) || ',' ||
                                p_dflt_confirmed_ind || ',' ||
                                NVL(p_unit1_unit_cd,'')||'/'||
                                NVL(p_unit1_cal_type,'')||'/'||
                                NVL(p_unit1_location_cd,'')||'/'||
                                NVL(p_unit1_unit_class,'')||','||
                                NVL(p_unit2_unit_cd,'')||'/'||
                                NVL(p_unit2_cal_type,'')||'/'||
                                NVL(p_unit2_location_cd,'')||'/'||
                                NVL(p_unit2_unit_class,'')||','||
                                NVL(p_unit3_unit_cd,'')||'/'||
                                NVL(p_unit3_cal_type,'')||'/'||
                                NVL(p_unit3_location_cd,'')||'/'||
                                NVL(p_unit3_unit_class,'')||','||
                                NVL(p_unit4_unit_cd,'')||'/'||
                                NVL(p_unit4_cal_type,'')||'/'||
                                NVL(p_unit4_location_cd,'')||'/'||
                                NVL(p_unit4_unit_class,'')||','||
                                NVL(p_unit5_unit_cd,'')||'/'||
                                NVL(p_unit5_cal_type,'')||'/'||
                                NVL(p_unit5_location_cd,'')||'/'||
                                NVL(p_unit5_unit_class,'')||','||
                                NVL(p_unit6_unit_cd,'')||'/'||
                                NVL(p_unit6_cal_type,'')||'/'||
                                NVL(p_unit6_location_cd,'')||'/'||
                                NVL(p_unit6_unit_class,'')||','||
                                NVL(p_unit7_unit_cd,'')||'/'||
                                NVL(p_unit7_cal_type,'')||'/'||
                                NVL(p_unit7_location_cd,'')||'/'||
                                NVL(p_unit7_unit_class,'')||','||
                                NVL(p_unit8_unit_cd,'')||'/'||
                                NVL(p_unit8_cal_type,'')||'/'||
                                NVL(p_unit8_location_cd,'')||'/'||
                                NVL(p_unit8_unit_class,'')||'/'||
                                NVL(p_unit9_unit_cd,'')||'/'||
                                NVL(p_unit9_cal_type,'')||'/'||
                                NVL(p_unit9_location_cd,'')||'/'||
                                NVL(p_unit9_unit_class,'')||'/'||
                                NVL(p_unit10_unit_cd,'')||'/'||
                                NVL(p_unit10_cal_type,'')||'/'||
                                NVL(p_unit10_location_cd,'')||'/'||
                                NVL(p_unit10_unit_class,'')||'/'||
                                NVL(p_unit11_unit_cd,'')||'/'||
                                NVL(p_unit11_cal_type,'')||'/'||
                                NVL(p_unit11_location_cd,'')||'/'||
                                NVL(p_unit11_unit_class,'')||'/'||
                                NVL(p_unit12_unit_cd,'')||'/'||
                                NVL(p_unit12_cal_type,'')||'/'||
                                NVL(p_unit12_location_cd,'')||'/'||
                                NVL(p_unit12_unit_class,'')||'/'||
                                NVL(p_unit_set_cd1,'')||'/'||
                                NVL(p_unit_set_cd2,'')||'/'||
                  -- The Below five parameters are added as part of the UK Enhancement - bug#2580731 - 04OCT2002
                                NVL(p_start_day,'')||'/'||
                                NVL(p_start_month,'')||'/'||
                                NVL(p_end_day,'')||'/'||
                                NVL(p_end_month,'')||'/'||
                                NVL(p_selection_date,'')||'/'||
                  -- The Below parameter completion_date added as part of ENCR030(UK Enh) - Bug#2708430 - 16DEC2002
                                NVL(p_completion_date,'')||'/'||
                                p_dflt_enr_method||'/'||
                                p_load_cal_type||'/'||
                                TO_CHAR(p_load_ci_seq_num),
                                v_log_creation_dt
                                );
        p_log_creation_dt := v_log_creation_dt;
        IF p_load_cal_type IS NULL THEN
           OPEN c_load_cal(p_acad_cal_type,p_acad_sequence_number);
           FETCH c_load_cal INTO l_load_cal_type, l_load_seq_num;
           IF c_load_cal%NOTFOUND THEN
               CLOSE c_load_cal;
               Fnd_Message.Set_name('IGS','IGS_EN_CN_FIND_TERM_CAL');
               IGS_GE_MSG_STACK.ADD;
               App_Exception.Raise_Exception;
           END IF;
           CLOSE c_load_cal;
        ELSE
           l_load_cal_type := p_load_cal_type;
           l_load_seq_num  := p_load_ci_seq_num;
        END IF;
        l_enr_method:=p_dflt_enr_method;
        IF p_student_comm_type = cst_new THEN
                -- Select all of the students who have been granted offers in the
                -- relevant academic period matching the supplied parameters.
                FOR v_acaiv_rec IN c_acaiv LOOP
                        BEGIN
                        -- Only process the latest offer in the IGS_PS_COURSE for the person_id
                              IF (v_person_id IS NULL AND
                                        v_course_cd IS NULL) OR
                                        NOT (v_acaiv_rec.person_id = v_person_id AND
                                        v_acaiv_rec.course_cd = v_course_cd) THEN
                                v_person_id := v_acaiv_rec.person_id;
                                v_course_cd := v_acaiv_rec.course_cd;
                                v_message_name := null;
                                vl_process := FALSE;
                              --logicall code is adding w.r.t. to YOP-EN build bug id :2156956 by kkillams
                              --checking of passing parameter unitset are active or not.
                              l_us_count :=0;
                              --Checking the whether pre-enrollment profile value is set Y or not.
                              IF NVL(fnd_profile.value('IGS_PS_PRENRL_YEAR_IND'),'N') = 'Y' THEN
                                      IF p_unit_set_cd1 is NULL THEN
                                          l_us_count:= l_us_count + 1;
                                      ELSE
                                            OPEN c_yop_us_st(v_acaiv_rec.person_id,v_acaiv_rec.course_cd,p_unit_set_cd1);
                                            FETCH c_yop_us_st INTO r_yop_us_st;
                                            IF c_yop_us_st%FOUND THEN
                                                l_us_count:= l_us_count + 1;
                                            END IF;
                                            CLOSE c_yop_us_st;
                                      END IF;
                                      IF p_unit_set_cd2 is NULL THEN
                                          l_us_count:= l_us_count + 1;
                                      ELSIF l_us_count =1 THEN
                                            OPEN c_yop_us_st(v_acaiv_rec.person_id,v_acaiv_rec.course_cd,p_unit_set_cd2);
                                            FETCH c_yop_us_st INTO r_yop_us_st;
                                            IF c_yop_us_st%FOUND THEN
                                                l_us_count:= l_us_count + 1;
                                            END IF;
                                            CLOSE c_yop_us_st;
                                      END IF;
                              ELSE
                                 l_us_count:=2;
                              END IF;

                              IF l_us_count = 2 THEN
                                vl_process := TRUE;
                              END IF;

                              IF vl_process THEN
                                IF NVL(fnd_profile.value('IGS_PS_PRENRL_YEAR_IND'),'N') = 'Y' THEN
                                   v_prog_outcome := enrp_get_pr_outcome(v_acaiv_rec.person_id,v_acaiv_rec.course_cd);
                                   IF v_prog_outcome IS NULL THEN
                                     vl_process := FALSE;
                                   ELSIF v_prog_outcome = 'ADVANCE' AND NVL(p_progress_stat,'ADVANCE') IN ('ADVANCE','BOTH') THEN
                                     vl_process := TRUE;
                                   ELSIF v_prog_outcome = 'REPEATYR' AND NVL(p_progress_stat,'ADVANCE') IN ('REPEATYR','BOTH') THEN
                                     vl_process := TRUE;
                                   ELSIF v_prog_outcome = 'NEW' AND NVL(p_progress_stat,'ADVANCE') IN ('ADVANCE','BOTH') THEN
                                     vl_process := TRUE;
                                   ELSE
                                     vl_process := FALSE;
                                   END IF;
                                END IF;
                              END IF;

                              IF vl_process THEN
                                -- Call the pre-enrolment routine for the single IGS_PE_PERSON
                                  IF IGS_EN_GEN_010.ENRP_INS_SNEW_PRENRL(
                                                v_acaiv_rec.person_id,
                                                v_acaiv_rec.course_cd,
                                                p_dflt_enrolment_cat,
                                                p_acad_cal_type,
                                                p_acad_sequence_number,
                                                p_units_indicator,
                                                p_dflt_confirmed_ind,
                                                p_override_enr_form_due_dt,
                                                p_override_enr_pckg_prod_dt,
                                                'Y',            -- Check eligibility
                                                v_acaiv_rec.admission_appl_number,
                                                v_acaiv_rec.nominated_course_cd,
                                                v_acaiv_rec.sequence_number,
                                                p_unit1_unit_cd,
                                                p_unit1_cal_type,
                                                p_unit1_location_cd,
                                                p_unit1_unit_class,
                                                p_unit2_unit_cd,
                                                p_unit2_cal_type,
                                                p_unit2_location_cd,
                                                p_unit2_unit_class,
                                                p_unit3_unit_cd,
                                                p_unit3_cal_type,
                                                p_unit3_location_cd,
                                                p_unit3_unit_class,
                                                p_unit4_unit_cd,
                                                p_unit4_cal_type,
                                                p_unit4_location_cd,
                                                p_unit4_unit_class,
                                                p_unit5_unit_cd,
                                                p_unit5_cal_type,
                                                p_unit5_location_cd,
                                                p_unit5_unit_class,
                                                p_unit6_unit_cd,
                                                p_unit6_cal_type,
                                                p_unit6_location_cd,
                                                p_unit6_unit_class,
                                                p_unit7_unit_cd,
                                                p_unit7_cal_type,
                                                p_unit7_location_cd,
                                                p_unit7_unit_class,
                                                p_unit8_unit_cd,
                                                p_unit8_cal_type,
                                                p_unit8_location_cd,
                                                p_unit8_unit_class,
                                                v_log_creation_dt,
                                                v_warn_level,
                                                v_message_name,
                                                p_unit9_unit_cd,
                                                p_unit9_cal_type,
                                                p_unit9_location_cd,
                                                p_unit9_unit_class,
                                                p_unit10_unit_cd,
                                                p_unit10_cal_type,
                                                p_unit10_location_cd,
                                                p_unit10_unit_class,
                                                p_unit11_unit_cd,
                                                p_unit11_cal_type,
                                                p_unit11_location_cd,
                                                p_unit11_unit_class,
                                                p_unit12_unit_cd,
                                                p_unit12_cal_type,
                                                p_unit12_location_cd,
                                                p_unit12_unit_class,
                                                p_unit_set_cd1,
                                                p_unit_set_cd2,
                                                p_progress_stat,
                                                l_enr_method,
                                                l_load_cal_type,
                                                l_load_seq_num
                                                ) THEN
                                        -- Log entry indicating successful pre-enrolment.
                                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                cst_pre_enrol,
                                                v_log_creation_dt ,
                                                cst_success || ',' ||
                                                        v_acaiv_rec.person_id || ',' ||
                                                        v_acaiv_rec.course_cd,
                                                'IGS_EN_SUCCESSFULLY_PRE_ENR',
                                                NULL);
                                        successful_total := successful_total + 1;
                                  ELSE
                                        exception_total := exception_total + 1;
                                  END IF;
                               END IF;  --Unit Set condition end if, l_us_count =2
                        END IF;
                     EXCEPTION
                       WHEN OTHERS THEN
                         IF v_log_creation_dt IS NOT NULL THEN
                           IGS_GE_MSG_STACK.GET(-1, 'T', l_enc_message_name, l_msg_index);
                           FND_MESSAGE.PARSE_ENCODED(l_enc_message_name,l_app_short_name,l_message_name);
                           IF l_message_name <> 'IGS_GE_UNHANDLED_EXP' THEN
                             IF l_message_name IS NOT NULL THEN
                               -- If the log creation date is set then log the HECS error
                                -- This is if the pre-enrolment is being performed in batch.
                                FND_MESSAGE.SET_NAME(l_app_short_name,l_message_name);
                                l_mesg_txt := FND_MESSAGE.GET;
                                igs_ge_gen_003.genp_ins_log_entry(p_s_log_type       => cst_pre_enrol,
                                                           p_creation_dt      => v_log_creation_dt,
                                                           p_key              => cst_error||','||TO_CHAR(v_acaiv_rec.person_id)||','||v_acaiv_rec.course_cd,
                                                           p_s_message_name   => l_message_name,
                                                           p_text             => l_mesg_txt);
                             END IF;
                           ELSE
                             FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
                             FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_008.enrp_ins_btch_prenrl');
                             l_mesg_txt := fnd_message.get;
                             igs_ge_gen_003.genp_ins_log_entry(p_s_log_type       => cst_pre_enrol,
                                                               p_creation_dt      => v_log_creation_dt,
                                                               p_key              => cst_error||','||TO_CHAR(v_acaiv_rec.person_id)||','||v_acaiv_rec.course_cd,
                                                               p_s_message_name   => 'IGS_GE_UNHANDLED_EXP',
                                                               p_text             => l_mesg_txt);
                           END IF;
                           l_message_name := NULL;
                         ELSE -- v_log_creation_dt is null
                           RAISE;
                         END IF;
                 END;
                END LOOP;
        ELSIF p_student_comm_type = cst_return THEN

                -- It is assumed that p_enr_cal_type and
                -- p_enr_sequence_number are not null and are
                -- correct.
                OPEN c_eci;
                FETCH c_eci INTO v_eci_rec;
                CLOSE c_eci;
                FOR v_sca_rec IN c_sca LOOP
                   BEGIN

                        -- If the last enrolment category parameter has been set then
                        -- check that the enrolment category last used for the IGS_PS_COURSE
                        -- attempt matches the parameter
                        IF p_last_enrolment_cat IS NOT NULL THEN
                                OPEN c_scae(
                                        v_sca_rec.person_id,
                                        v_sca_rec.course_cd,
                                        v_eci_rec.start_dt);
                                FETCH c_scae INTO v_scae_rec;
                                IF c_scae%FOUND THEN
                                        CLOSE c_scae;
                                        IF v_scae_rec.enrolment_cat = p_last_enrolment_cat THEN
                                                v_message_name := null;
                                                vl_process := FALSE;
                                                --logicall code is adding w.r.t. to YOP-EN build bug id :2156956 by kkillams
                                                --checking of passing unitset are active or not.
                                                   l_us_count:=0;

                                              --Checking the whether pre-enrollment profile value is set Y or not.
                                                IF NVL(fnd_profile.value('IGS_PS_PRENRL_YEAR_IND'),'N') = 'Y' THEN
                                                     IF p_unit_set_cd1 is NULL THEN
                                                          l_us_count:= l_us_count + 1;
                                                     ELSE
                                                         OPEN c_yop_us_st(v_sca_rec.person_id,v_sca_rec.course_cd,p_unit_set_cd1);
                                                         FETCH c_yop_us_st INTO r_yop_us_st;
                                                         IF c_yop_us_st%FOUND THEN
                                                                  l_us_count:= l_us_count + 1;
                                                         END IF;
                                                         CLOSE c_yop_us_st;
                                                     END IF;
                                                     IF p_unit_set_cd2 is NULL THEN
                                                            l_us_count:= l_us_count + 1;
                                                     ELSIF l_us_count =1 THEN
                                                           OPEN c_yop_us_st(v_sca_rec.person_id,v_sca_rec.course_cd,p_unit_set_cd2);
                                                           FETCH c_yop_us_st INTO r_yop_us_st;
                                                           IF c_yop_us_st%FOUND THEN
                                                                   l_us_count:= l_us_count + 1;
                                                            END IF;
                                                            CLOSE c_yop_us_st;
                                                     END IF;
                                                ELSE
                                                       l_us_count:=2;
                                                END IF;

                                                IF l_us_count = 2 THEN
                                                  vl_process := TRUE;
                                                END IF;

                                                IF vl_process THEN
                                                  IF NVL(fnd_profile.value('IGS_PS_PRENRL_YEAR_IND'),'N') = 'Y' THEN
                                                     v_prog_outcome := enrp_get_pr_outcome(v_sca_rec.person_id,v_sca_rec.course_cd);
                                                     IF v_prog_outcome IS NULL OR v_prog_outcome = 'NEW' THEN
                                                       vl_process := FALSE;
                                                     ELSIF v_prog_outcome = 'ADVANCE' AND NVL(p_progress_stat,'ADVANCE') IN ('ADVANCE','BOTH') THEN
                                                       vl_process := TRUE;
                                                     ELSIF v_prog_outcome = 'REPEATYR' AND NVL(p_progress_stat,'ADVANCE') IN ('REPEATYR','BOTH') THEN
                                                       vl_process := TRUE;
                                                     ELSE
                                                       vl_process := FALSE;
                                                     END IF;
                                                  END IF;
                                                END IF;



                                                IF vl_process THEN
                                                  IF NOT IGS_EN_GEN_010.enrp_ins_sret_prenrl(
                                                                v_sca_rec.person_id,
                                                                v_sca_rec.course_cd,
                                                                p_dflt_enrolment_cat,
                                                                p_acad_cal_type,
                                                                p_acad_sequence_number,
                                                                p_enr_cal_type,
                                                                p_enr_sequence_number,
                                                                p_units_indicator,
                                                                p_override_enr_form_due_dt,
                                                                p_override_enr_pckg_prod_dt,
                                                                v_log_creation_dt,
                                                                v_warn_level,
                                                                v_message_name,
                                                                p_unit1_unit_cd,
                                                                p_unit1_cal_type,
                                                                p_unit1_location_cd,
                                                                p_unit1_unit_class,
                                                                p_unit2_unit_cd,
                                                                p_unit2_cal_type,
                                                                p_unit2_location_cd,
                                                                p_unit2_unit_class,
                                                                p_unit3_unit_cd,
                                                                p_unit3_cal_type,
                                                                p_unit3_location_cd,
                                                                p_unit3_unit_class,
                                                                p_unit4_unit_cd,
                                                                p_unit4_cal_type,
                                                                p_unit4_location_cd,
                                                                p_unit4_unit_class,
                                                                p_unit5_unit_cd,
                                                                p_unit5_cal_type,
                                                                p_unit5_location_cd,
                                                                p_unit5_unit_class,
                                                                p_unit6_unit_cd,
                                                                p_unit6_cal_type,
                                                                p_unit6_location_cd,
                                                                p_unit6_unit_class,
                                                                p_unit7_unit_cd,
                                                                p_unit7_cal_type,
                                                                p_unit7_location_cd,
                                                                p_unit7_unit_class,
                                                                p_unit8_unit_cd,
                                                                p_unit8_cal_type,
                                                                p_unit8_location_cd,
                                                                p_unit8_unit_class,
                                                                p_unit9_unit_cd,
                                                                p_unit9_cal_type,
                                                                p_unit9_location_cd,
                                                                p_unit9_unit_class,
                                                                p_unit10_unit_cd,
                                                                p_unit10_cal_type,
                                                                p_unit10_location_cd,
                                                                p_unit10_unit_class,
                                                                p_unit11_unit_cd,
                                                                p_unit11_cal_type,
                                                                p_unit11_location_cd,
                                                                p_unit11_unit_class,
                                                                p_unit12_unit_cd,
                                                                p_unit12_cal_type,
                                                                p_unit12_location_cd,
                                                                p_unit12_unit_class,
                                                                p_unit_set_cd1,
                                                                p_unit_set_cd2,
                                                                p_selection_date,  --Added as part of the UK Enh Buid- Bug#2580731
                                                                p_completion_date,  --Added as part of ENCR030(UK Enh) - Bug#2708430 - 16DEC2002
                                                                p_progress_stat,
                                                                l_enr_method,
                                                                l_load_cal_type,
                                                                l_load_seq_num
                                                                ) THEN
                                                        exception_total := exception_total + 1;
                                                  ELSE
                                                        -- Log entry indicating successful pre-enrolment.
                                                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                                cst_pre_enrol,
                                                                v_log_creation_dt ,
                                                                cst_success || ',' ||
                                                                        v_sca_rec.person_id || ',' ||
                                                                        v_sca_rec.course_cd,
                                                                'IGS_EN_SUCCESSFULLY_PRE_ENR',
                                                                NULL);
                                                        successful_total := successful_total + 1;
                                                  END IF;
                                             END IF;  --UNIT SET's condition(IGS_PS_PRENRL_YEAR_IND ='Y' , l_count_us_st =2
                                        END IF; -- v_scae_rec.enrolment_cat = p_last_enrolment_cat
                                ELSE    -- c_scae%NOTFOUND
                                        CLOSE c_scae;
                                END IF; -- c_scae
                        ELSE
                                vl_process := FALSE;
                               --logicall code is adding w.r.t. to YOP-EN build bug id :2156956 by kkillams
                                --checking of passing unitset are active or not.
                                 l_us_count:=0;
                              --Checking the whether pre-enrollment profile value is set Y or not.
                               IF NVL(fnd_profile.value('IGS_PS_PRENRL_YEAR_IND'),'N') = 'Y' THEN
                                     IF p_unit_set_cd1 is NULL THEN
                                                  l_us_count:= l_us_count + 1;
                                     ELSE
                                                 OPEN c_yop_us_st(v_sca_rec.person_id,v_sca_rec.course_cd,p_unit_set_cd1);
                                                 FETCH c_yop_us_st INTO r_yop_us_st;
                                                         IF c_yop_us_st%FOUND THEN
                                                                  l_us_count:= l_us_count + 1;
                                                         END IF;
                                                         CLOSE c_yop_us_st;
                                     END IF;
                                     IF p_unit_set_cd2 is NULL THEN
                                                    l_us_count:= l_us_count + 1;
                                     ELSIF l_us_count =1 THEN
                                                   OPEN c_yop_us_st(v_sca_rec.person_id,v_sca_rec.course_cd,p_unit_set_cd2);
                                                   FETCH c_yop_us_st INTO r_yop_us_st;
                                                   IF c_yop_us_st%FOUND THEN
                                                           l_us_count:= l_us_count + 1;
                                                    END IF;
                                                    CLOSE c_yop_us_st;
                                     END IF;
                               ELSE
                                              l_us_count:=2;
                               END IF;

                               IF l_us_count = 2 THEN
                                 vl_process := TRUE;
                               END IF;

                               IF vl_process THEN
                                 IF NVL(fnd_profile.value('IGS_PS_PRENRL_YEAR_IND'),'N') = 'Y' THEN
                                    v_prog_outcome := enrp_get_pr_outcome(v_sca_rec.person_id,v_sca_rec.course_cd);
                                    IF v_prog_outcome IS NULL OR v_prog_outcome = 'NEW' THEN
                                      vl_process := FALSE;
                                    ELSIF v_prog_outcome = 'ADVANCE' AND NVL(p_progress_stat,'ADVANCE') IN ('ADVANCE','BOTH') THEN
                                      vl_process := TRUE;
                                    ELSIF v_prog_outcome = 'REPEATYR' AND NVL(p_progress_stat,'ADVANCE') IN ('REPEATYR','BOTH') THEN
                                      vl_process := TRUE;
                                    ELSE
                                      vl_process := FALSE;
                                    END IF;
                                 END IF;
                               END IF;

                               IF vl_process THEN
                                    v_message_name := null;
                                     IF NOT IGS_EN_GEN_010.enrp_ins_sret_prenrl(
                                                v_sca_rec.person_id,
                                                v_sca_rec.course_cd,
                                                p_dflt_enrolment_cat,
                                                p_acad_cal_type,
                                                p_acad_sequence_number,
                                                p_enr_cal_type,
                                                p_enr_sequence_number,
                                                p_units_indicator,
                                                p_override_enr_form_due_dt,
                                                p_override_enr_pckg_prod_dt,
                                                v_log_creation_dt,
                                                v_warn_level,
                                                v_message_name,
                                                p_unit1_unit_cd,
                                                p_unit1_cal_type,
                                                p_unit1_location_cd,
                                                p_unit1_unit_class,
                                                p_unit2_unit_cd,
                                                p_unit2_cal_type,
                                                p_unit2_location_cd,
                                                p_unit2_unit_class,
                                                p_unit3_unit_cd,
                                                p_unit3_cal_type,
                                                p_unit3_location_cd,
                                                p_unit3_unit_class,
                                                p_unit4_unit_cd,
                                                p_unit4_cal_type,
                                                p_unit4_location_cd,
                                                p_unit4_unit_class,
                                                p_unit5_unit_cd,
                                                p_unit5_cal_type,
                                                p_unit5_location_cd,
                                                p_unit5_unit_class,
                                                p_unit6_unit_cd,
                                                p_unit6_cal_type,
                                                p_unit6_location_cd,
                                                p_unit6_unit_class,
                                                p_unit7_unit_cd,
                                                p_unit7_cal_type,
                                                p_unit7_location_cd,
                                                p_unit7_unit_class,
                                                p_unit8_unit_cd,
                                                p_unit8_cal_type,
                                                p_unit8_location_cd,
                                                p_unit8_unit_class,
                                                p_unit9_unit_cd,
                                                p_unit9_cal_type,
                                                p_unit9_location_cd,
                                                p_unit9_unit_class,
                                                p_unit10_unit_cd,
                                                p_unit10_cal_type,
                                                p_unit10_location_cd,
                                                p_unit10_unit_class,
                                                p_unit11_unit_cd,
                                                p_unit11_cal_type,
                                                p_unit11_location_cd,
                                                p_unit11_unit_class,
                                                p_unit12_unit_cd,
                                                p_unit12_cal_type,
                                                p_unit12_location_cd,
                                                p_unit12_unit_class,
                                                p_unit_set_cd1,
                                                p_unit_set_cd2,
                                                p_selection_date,  --Added as part of the UK Enh Buid- Bug#2580731
                                                p_completion_date,  --Added as part of ENCR030(UK Enh) - Bug#2708430 - 18DEC2002
                                                p_progress_stat,
                                                l_enr_method,
                                                l_load_cal_type,
                                                l_load_seq_num
                                                ) THEN
                                        exception_total := exception_total + 1;
                                ELSE
                                        -- Log entry indicating successful pre-enrolment.
                                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                cst_pre_enrol,
                                                v_log_creation_dt ,
                                                cst_success || ',' ||
                                                        v_sca_rec.person_id || ',' ||
                                                        v_sca_rec.course_cd,
                                                'IGS_EN_SUCCESSFULLY_PRE_ENR',
                                                NULL);
                                                successful_total := successful_total + 1;
                                END IF;
                          END IF;
                        END IF; -- p_last_enrolment_cat IS NOT NULL
                EXCEPTION
                   WHEN OTHERS THEN
                     IF v_log_creation_dt IS NOT NULL THEN
                       IGS_GE_MSG_STACK.GET(-1, 'T', l_enc_message_name, l_msg_index);
                       FND_MESSAGE.PARSE_ENCODED(l_enc_message_name,l_app_short_name,l_message_name);
                       IF l_message_name <> 'IGS_GE_UNHANDLED_EXP' THEN
                           IF l_message_name IS NOT NULL THEN
                               -- If the log creation date is set then log the HECS error
                                -- This is if the pre-enrolment is being performed in batch.
                                FND_MESSAGE.SET_NAME(l_app_short_name,l_message_name);
                                l_mesg_txt := FND_MESSAGE.GET;
                                igs_ge_gen_003.genp_ins_log_entry(p_s_log_type       => cst_pre_enrol,
                                                           p_creation_dt      => v_log_creation_dt,
                                                           p_key              => cst_error||','||TO_CHAR(v_sca_rec.person_id)||','||v_sca_rec.course_cd,
                                                           p_s_message_name   => l_message_name,
                                                           p_text             => l_mesg_txt);
                            END IF;
                       ELSE
                         FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
                         FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_008.enrp_ins_btch_prenrl');
                         l_mesg_txt := fnd_message.get;
                         igs_ge_gen_003.genp_ins_log_entry(p_s_log_type       => cst_pre_enrol,
                                                           p_creation_dt      => v_log_creation_dt,
                                                           p_key              => cst_error||','||TO_CHAR(v_sca_rec.person_id)||','||v_sca_rec.course_cd,
                                                           p_s_message_name   => 'IGS_GE_UNHANDLED_EXP',
                                                           p_text             => l_mesg_txt);
                      END IF;
                      l_message_name := NULL;
                    ELSE -- v_log_creation_dt is null
                      RAISE;
                    END If;

                END;

                END LOOP; -- v_sca_rec IN c_sca
        END IF; -- p_student_comm_type
--        COMMIT; this commit is not needed
        RETURN;
EXCEPTION
        WHEN OTHERS THEN
                IF c_scae%ISOPEN THEN
                        CLOSE c_scae;
                END IF;
                IF c_eci%ISOPEN THEN
                        CLOSE c_eci;
                END IF;
                IF c_sca%ISOPEN THEN
                        CLOSE c_sca;
                END IF;
                IF c_acaiv%ISOPEN THEN
                        CLOSE c_acaiv;
                END IF;
                RAISE;
END;
EXCEPTION
        WHEN OTHERS THEN
                Fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
                FND_MESSAGE.SET_TOKEN('NAME','IGS_EN_GEN_008.enrp_ins_btch_prenrl');
                IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
END enrp_ins_btch_prenrl;

FUNCTION enrp_get_person_type(p_course_cd IN VARCHAR2) RETURN VARCHAR2 AS
/******************************************************************
Created By        : Vinay Chappidi
Date Created By   : 04-Jul-2001
Purpose           : This function returns the person type of the user logged into the application
                    returns TRUE for a Self Service User and FLASE for back office user
Known limitations,
enhancements,
remarks            :
Change History
Who      When        What
kkillams 22-04-22    Cursor cur_hz_parties changed to Cur_person_id modified w.r.t. 2249114
knaraset 07-May-02   Bug 2335276,Modified the logic of getting the person type, to consider RoleType
                     information also, To make in sync with self service session utilities.
kkillams 11-Apr-03   Modified the cur_fun_name cursor definition as part of the performance bug 2893267 fix.
bdeviset 14-APR-2005 changed cursor cur_person_id for bug # 4303661
******************************************************************/

  -- cursor for getting the person_id of the user who has logged into the application
  --Cursor cur_hz_parties is replaced with new cursor cur_person_id w.r.t. 2249114
  --cur_hz_parties select statement is SELECT party_id person_id FROM igs_pe_hz_parties
  --WHERE  oracle_username = cp_user_name
  CURSOR cur_person_id( cp_user_name IN fnd_user.user_name%TYPE)
  IS
  SELECT person_party_id person_id
  FROM   fnd_user
  WHERE  user_name = cp_user_name;
  -- cursor for getting the person type code of the user who has logged into the application
  -- minimum rank for the person id is returned
  -- cursor is modified for performance bug 3713057
  CURSOR cur_person_type( cp_person_id  igs_pe_typ_instances.person_id%TYPE)
  IS
  SELECT pti.person_type_code
  FROM   igs_pe_typ_instances pti,
         igs_pe_person_types pt
  WHERE  pti.person_id = cp_person_id AND
         pti.person_type_code = pt.person_type_code AND
         pt.system_type = 'SS_ENROLL_STAFF' AND
         TRUNC(SYSDATE) BETWEEN pti.start_date AND NVL(pti.end_date,SYSDATE)
  order by rank asc;

  -- cursor for getting the person type code of the user who has logged into the application
  -- depending on the course code passed into the function
  -- cursor is modified for performance bug 3696901
  CURSOR cur_typ_instances( cp_person_id  igs_pe_hz_parties.party_id%TYPE) IS
  SELECT person_type_code
  FROM  igs_pe_typ_instances_all
  WHERE person_id = cp_person_id AND
        course_cd = NVL(p_course_cd,course_cd) AND
        end_date IS NULL AND
        person_type_code IN ( SELECT person_type_code
                              FROM igs_pe_person_types
                              WHERE system_type = 'STUDENT');
--
-- Cursor to select the Function name of home page attached to the given responsibility.
--
  CURSOR cur_fun_name  IS
  SELECT fun.function_name
  FROM fnd_form_functions fun
  WHERE fun.type = 'JSP' AND
        fun.function_name  IN ('IGS_SS_ADMIN_HOME','IGS_SS_STUDENT_HOME') AND
        fun.FUNCTION_ID IN (SELECT menu.FUNCTION_ID
                            FROM fnd_menu_entries menu
                            CONNECT BY menu.menu_id = PRIOR menu.SUB_MENU_ID
                            START WITH menu.menu_id = (SELECT resp.MENU_ID
                                                       FROM fnd_responsibility resp
                                                       WHERE responsibility_id = fnd_global.RESP_ID
                                                       AND   resp.application_id = 8405));


  l_cur_person_id      cur_person_id%ROWTYPE;
  l_cur_person_type     cur_person_type%ROWTYPE;
  l_cur_typ_instances   cur_typ_instances%ROWTYPE;
  l_fun_name_rec cur_fun_name%ROWTYPE;
  -- Variables
  l_v_logged_username   fnd_user.user_name%TYPE;
BEGIN
  -- get the username of the person who has logged into the application
  l_v_logged_username := fnd_global.user_name();

  -- if the username is not found then return NULL
  IF l_v_logged_username IS NULL THEN
    RETURN NULL;
  ELSE
    -- get the person id for the user who has logged into the application by passing the username
    OPEN cur_person_id(l_v_logged_username);
    FETCH cur_person_id INTO l_cur_person_id;
    CLOSE cur_person_id;

    -- when person id is not found for the person logged into the application then the function
    -- returns NULL expecting that the user looged is a backoffice user
    IF l_cur_person_id.person_id IS NULL THEN
      RETURN NULL;
    ELSE
    -- Below coded is modified as per Bug 2335276.
    -- when person id is found for the person logged into the application
          OPEN cur_fun_name;
          FETCH cur_fun_name INTO l_fun_name_rec;
          CLOSE cur_fun_name;
      IF l_fun_name_rec.function_name = 'IGS_SS_ADMIN_HOME' THEN
          -- If logged in user has access to Admin Home Page, means he/she is a Admin.
          -- get the person type code of the logged in user based on Rank
          OPEN cur_person_type(l_cur_person_id.person_id);
          FETCH cur_person_type INTO l_cur_person_type;
          CLOSE cur_person_type;
          RETURN l_cur_person_type.person_type_code;
      ELSIF  l_fun_name_rec.function_name = 'IGS_SS_STUDENT_HOME' THEN
          -- If logged in user has access to Student Home Page, means he/she is a Student.
          -- get the person type code corresponding to the SyatemType STUDENT,
          OPEN  cur_typ_instances(l_cur_person_id.person_id);
          FETCH cur_typ_instances INTO l_cur_typ_instances;
          CLOSE cur_typ_instances;
          RETURN l_cur_typ_instances.person_type_code;
      ELSE
          -- If the user got access to Other than Admin/Student Home Pages
          OPEN cur_person_type(l_cur_person_id.person_id);
          FETCH cur_person_type INTO l_cur_person_type;
          CLOSE cur_person_type;
          RETURN l_cur_person_type.person_type_code;
      END IF; -- fnd_function.test
    END IF; -- person_id is NULL
  END IF;  -- Logged in User Name is NULL
END enrp_get_person_type;

FUNCTION enrp_val_chg_grd_sch ( p_uoo_id             IN   NUMBER,
                                p_cal_type           IN   VARCHAR2,
                                p_ci_sequence_number IN   NUMBER,
                                p_message_name       OUT NOCOPY  VARCHAR2
                              ) RETURN BOOLEAN AS
/******************************************************************
Created By        : Vinay Chappidi
Date Created By   : 04-Jul-2001
Purpose           : This function is used to determine whether the current date is after the Grading Schema
                    change deadline date or not and also whether more than one grading schema exist or not.
                    If only one grading schema avilable or date is after the deadline date then the function
                    return FALSE otherwise returns TRUE
Known limitations,
enhancements,
remarks            :
Change History
Who      When        What
knaraset 21-May-2002 Bug 2357310, modified the logic to return false when only one grading schema defined at unit section
                     level, so that the item will be displayed as Read-Only in self service page.
kkillams 27-02-2003  Modified cur_ps_unit_ofr cursor, * replaced with unit_cd and version_number w.r.t. bug 2749648
******************************************************************/


  -- cursor for getting the count of Grading Schemas for the Uoo_id passed at the Unit Level
  CURSOR cur_usec_grd_schm
  IS
  SELECT COUNT(1) num_grade_schemas
  FROM   igs_ps_usec_grd_schm
  WHERE  uoo_id = p_uoo_id;

  -- cursor for getting the Unit_cd and Version Number for the Uoo_id passed
  CURSOR cur_ps_unit_ofr
  IS
  SELECT unit_cd, version_number
  FROM   igs_ps_unit_ofr_opt
  WHERE  uoo_id = p_uoo_id;

  -- cursor for getting the count of Grading Schema's for the Uoo_id passed at the Unit Section Level
  CURSOR cur_unit_grd_schm( cp_unit_code       igs_ps_unit_grd_schm.unit_code%TYPE,
                            cp_version_number  igs_ps_unit_grd_schm.unit_version_number%TYPE
                          )
  IS
  SELECT COUNT(1) num_grade_schemas
  FROM   igs_ps_unit_grd_schm
  WHERE  unit_code           = cp_unit_code
  AND    unit_version_number = cp_version_number;

  -- Cursor for getting different grading schema's defined for the logged on person type
  -- Modiified cursor for performance bug 3696153
  CURSOR cur_pe_usr_arg( cp_person_type  IN igs_pe_person_types.person_type_code%TYPE)
  IS
 SELECT nvl(dai.absolute_val,
          IGS_CA_GEN_001.calp_set_alias_value(dai.absolute_val,
          IGS_CA_GEN_002.cals_clc_dt_from_dai(dai.ci_sequence_number, dai.CAL_TYPE,
          dai.DT_ALIAS, dai.sequence_number) )  ) alias_val
   FROM  IGS_PE_USR_ARG_ALL  pua,
          IGS_CA_DA_INST dai
  WHERE  pua.person_type         = cp_person_type
   AND    dai.dt_alias           = pua.grad_sch_dt_alias
   AND    dai.cal_type           = p_cal_type
   AND    dai.ci_sequence_number = p_ci_sequence_number
   ORDER BY 1;



  -- Cursor for getting different grading schemas defined at the Unit Level
  CURSOR cur_en_nstd_usec
  IS
  SELECT enr_dl_date  alias_val
  FROM   igs_en_nstd_usec_dl
  WHERE  function_name = 'GRADING_SCHEMA'
  AND    uoo_id        = p_uoo_id
  ORDER BY 1;

  -- Cursor for getting different grading schemas defined at the Institutional Level
  CURSOR cur_en_cal_conf
  IS
  SELECT dai.alias_val alias_val
  FROM   igs_ca_da_inst_v dai, igs_en_cal_conf ecc
  WHERE  dai.cal_type           = p_cal_type
  AND    dai.ci_sequence_number = p_ci_sequence_number
  AND    dai.dt_alias           = ecc.grading_schema_dt_alias
  AND    ecc.s_control_num      =1
  ORDER BY 1;

  -- ROWTYPE Variables for Cursors
  l_cur_usec_grd_schm   cur_usec_grd_schm%ROWTYPE;
  l_cur_ps_unit_ofr     cur_ps_unit_ofr%ROWTYPE;
  l_cur_unit_grd_schm   cur_unit_grd_schm%ROWTYPE;
  l_cur_pe_usr_arg      cur_pe_usr_arg%ROWTYPE;
  l_cur_en_nstd_usec    cur_en_nstd_usec%ROWTYPE;
  l_cur_en_cal_conf     cur_en_cal_conf%ROWTYPE;

  -- Variables
  l_v_person_type   igs_pe_person_types.person_type_code%TYPE;
  l_b_grade_schema  BOOLEAN ;

BEGIN


  -- Initializing the local variable to FALSE
  -- If more then one grading schemas are defined for the Unit Or at the Unit Section
  -- level then this variable is set to TRUE
  l_b_grade_schema :=FALSE;

  -- Check if more than one grading schemas are defined at Unit Level
  -- if there are more than one grading schemas then the variable l_b_grade_schema is set to TRUE
  -- else grading schemas defined at Unit section level have to be fetched
  OPEN  cur_usec_grd_schm;
  FETCH cur_usec_grd_schm INTO l_cur_usec_grd_schm;
  CLOSE cur_usec_grd_schm;
  IF (l_cur_usec_grd_schm.num_grade_schemas > 1) THEN
        l_b_grade_schema := TRUE;
  ELSIF (l_cur_usec_grd_schm.num_grade_schemas = 0) THEN
     -- get the Unit, version_number for the UOO_ID passed into the function
     OPEN  cur_ps_unit_ofr;
     FETCH cur_ps_unit_ofr INTO l_cur_ps_unit_ofr;
     CLOSE cur_ps_unit_ofr;

    -- If the Unit code and version number are not fetched then the local variable
    -- l_b_grade_schema is set to FALSE else set to TRUE
    IF (l_cur_ps_unit_ofr.unit_cd IS NOT NULL AND l_cur_ps_unit_ofr.version_number IS NOT NULL) THEN
      OPEN  cur_unit_grd_schm( l_cur_ps_unit_ofr.unit_cd, l_cur_ps_unit_ofr.version_number);
      FETCH cur_unit_grd_schm INTO l_cur_unit_grd_schm;
      CLOSE cur_unit_grd_schm;
      IF (l_cur_unit_grd_schm.num_grade_schemas > 1) THEN
        l_b_grade_schema := TRUE;
      END IF;
    END IF;
  END IF;

  -- If the local variable is set to TRUE then start validating the date aliases
  -- at person level
  IF l_b_grade_schema THEN
    -- get the person_type of the logged on user
    l_v_person_type := igs_en_gen_008.enrp_get_person_type( p_course_cd => NULL);

    -- If there is a person_type defined then validate date aliases at person type level
    -- else validate dates at the unit section level
    IF l_v_person_type IS NOT NULL THEN

      -- check if any date_aliases are defined for the person_type
      -- if found then validate them
      -- else validate dates at Unit Section Level
      OPEN cur_pe_usr_arg(l_v_person_type);
      FETCH cur_pe_usr_arg INTO l_cur_pe_usr_arg;
      IF cur_pe_usr_arg%FOUND THEN
          CLOSE cur_pe_usr_arg;

        OPEN cur_pe_usr_arg(l_v_person_type);
        LOOP
        EXIT WHEN cur_pe_usr_arg%NOTFOUND;
        FETCH cur_pe_usr_arg INTO l_cur_pe_usr_arg;
        IF ( TRUNC(l_cur_pe_usr_arg.alias_val) < TRUNC(SYSDATE) ) THEN
          p_message_name := 'IGS_EN_GRAD_DL_PASS';
          RETURN FALSE;
        END IF;
        END LOOP;
          CLOSE cur_pe_usr_arg;
        RETURN TRUE;
      ELSE
          CLOSE cur_pe_usr_arg;
      END IF;
    END IF;

    -- check if any dates are defined for the unit_section level
    -- if found then validate them
    -- else validate date aliases at institutional Level
    OPEN cur_en_nstd_usec;
    FETCH cur_en_nstd_usec INTO l_cur_en_nstd_usec;
    IF cur_en_nstd_usec%FOUND THEN
      CLOSE cur_en_nstd_usec;

      OPEN cur_en_nstd_usec;
      LOOP
      EXIT WHEN cur_en_nstd_usec%NOTFOUND;
      FETCH cur_en_nstd_usec INTO l_cur_en_nstd_usec;
      IF ( TRUNC(l_cur_en_nstd_usec.alias_val) < TRUNC(SYSDATE) ) THEN
        p_message_name := 'IGS_EN_GRAD_DL_PASS';
        RETURN FALSE;
      END IF;
      END LOOP;
      CLOSE cur_en_nstd_usec;
      RETURN TRUE;
    ELSE
      CLOSE cur_en_nstd_usec;
    END IF;

    -- check if any date_aliases are defined at the institutional level
    -- if found then validate them
    -- else the function should return FALSE by setting p_message_name to 'IGS_EN_GRAD_DL_PASS'
    OPEN cur_en_cal_conf;
    FETCH cur_en_cal_conf INTO l_cur_en_cal_conf;
    IF cur_en_cal_conf%FOUND THEN
      CLOSE cur_en_cal_conf;

      OPEN cur_en_cal_conf;
      LOOP
      EXIT WHEN cur_en_cal_conf%NOTFOUND;
      FETCH cur_en_cal_conf INTO l_cur_en_cal_conf;
      IF ( TRUNC(l_cur_en_cal_conf.alias_val) < TRUNC(SYSDATE) ) THEN
        p_message_name := 'IGS_EN_GRAD_DL_PASS';
        RETURN FALSE;
      END IF;
      END LOOP;
      CLOSE cur_en_cal_conf;
      RETURN TRUE;
    ELSE
      CLOSE cur_en_cal_conf;
      RETURN TRUE;
    END IF;
  ELSE
    p_message_name := 'IGS_EN_GRAD_DL_PASS';
    RETURN FALSE;
  END IF;
END enrp_val_chg_grd_sch;


FUNCTION enrp_val_chg_grd_sch_wrapper ( p_uoo_id             IN   NUMBER,
                                p_cal_type           IN   VARCHAR2,
                                p_ci_sequence_number IN   NUMBER
                              ) RETURN CHAR AS
/******************************************************************
Created By        : Manu Srinivasan
Date Created By   : 04-Oct-2001
Purpose           : This is wrapper on the function enrp_val_chg_grd_sch since it has to be used in a view definition and the function has out NOCOPY parameters. This function internall calls this function and has no additional functions
Known limitations,
enhancements,
remarks            :
Change History
Who      When        What
******************************************************************/
   l_dummy          VARCHAR2(100);
BEGIN

IF( enrp_val_chg_grd_sch ( p_uoo_id,
                                p_cal_type,
                                p_ci_sequence_number,
                                    l_dummy)) THEN
   RETURN 'Y';

ELSE RETURN 'N';
END IF;

END enrp_val_chg_grd_sch_wrapper;

FUNCTION enrp_val_chg_cp (
                           p_person_id          IN   NUMBER,
                           p_uoo_id             IN   NUMBER,
                           p_cal_type           IN   VARCHAR2,
                           p_ci_sequence_number IN   NUMBER
                         ) RETURN CHAR AS
/******************************************************************
Created By        : Manu Srinivasan
Date Created By   : 04-Oct-2001
Purpose           : This func determines if credit points can be updated
Known limitations,
enhancements,
remarks            :
Change History
Who      When        What
kkillams 27-02-2003  Modified cur_ps_unit_ofr cursor, * replaced with unit_cd and version_number w.r.t. bug 2749648
myoganat 23-05-2003  Created cursor cur_no_assesment_ind to check for
             audit attempts #2855870
******************************************************************/
   l_dummy          VARCHAR2(100);
   -- cursor for getting the Unit_cd and Version Number for the Uoo_id passed
  CURSOR cur_ps_unit_ofr
  IS
  SELECT unit_cd, version_number
  FROM   igs_ps_unit_ofr_opt
  WHERE  uoo_id = p_uoo_id;

   -- Check if the unit is set up for variable cp
   CURSOR cur_chk_cp_chg_val (p_unit_cd igs_ps_unit_ver_v.unit_cd%TYPE,p_unit_ver_num igs_ps_unit_ver_v.version_number%TYPE)
   IS SELECT points_override_ind
   FROM igs_ps_unit_ver_v
   WHERE unit_cd = p_unit_cd
   AND version_number = p_unit_ver_num;

   --Check if there exist any user level deadline
   --Modified the cursor for performance bug 3696257
  CURSOR cur_pe_usr_arg( cp_person_type  IN igs_pe_person_types.person_type_code%TYPE)
  IS
  SELECT   nvl(dai.absolute_val,
              IGS_CA_GEN_001.calp_set_alias_value(dai.absolute_val,
              IGS_CA_GEN_002.cals_clc_dt_from_dai(dai.ci_sequence_number, dai.CAL_TYPE,
              dai.DT_ALIAS, dai.sequence_number) )  ) alias_val
    FROM  igs_ca_da_inst dai,igs_pe_usr_arg_all pua
    WHERE  pua.person_type        = cp_person_type
    AND    dai.dt_alias          = pua.grad_sch_dt_alias
    AND    dai.cal_type          = p_cal_type
    AND    dai.ci_sequence_number = p_ci_sequence_number
    ORDER BY 1;


  --Check if deadline has passed for cp change at usec level
  CURSOR cur_en_nstd_usec
  IS
  SELECT enr_dl_date  alias_val
  FROM   igs_en_nstd_usec_dl
  WHERE  function_name = 'GRADING_SCHEMA'
  AND    uoo_id        = p_uoo_id
  ORDER BY 1;

 --Check if deadline has passed for cp change at institution level
  CURSOR cur_en_cal_conf
  IS
  SELECT dai.alias_val alias_val
  FROM   igs_ca_da_inst_v dai, igs_en_cal_conf ecc
  WHERE  dai.cal_type           = p_cal_type
  AND    dai.ci_sequence_number = p_ci_sequence_number
  AND    dai.dt_alias           = ecc.grading_schema_dt_alias
  AND    ecc.s_control_num      =1
  ORDER BY 1;

  -- Cursor to get the System Type corresponding to the Person Type Code
  -- Added as per the bug# 2364461.
  CURSOR cur_sys_per_typ(cp_person_type VARCHAR2) IS
  SELECT system_type
  FROM   igs_pe_person_types
  WHERE  person_type_code = cp_person_type;
  l_cur_sys_per_typ cur_sys_per_typ%ROWTYPE;

  -- Cursor to check for audit attempts
  -- By selecting no_assessment_ind column corresponding
  -- to the Person Id, Unit Offering Options Id, Calendar Type
  -- and Calendar Instance
  CURSOR cur_no_assessment_ind
  IS
  SELECT no_assessment_ind
  FROM igs_en_su_attempt
  WHERE person_id = p_person_id
  AND uoo_id = p_uoo_id
  AND cal_type = p_cal_type
  AND ci_sequence_number = p_ci_sequence_number;
  l_no_assessment_ind VARCHAR2(1);

  --Row type variables
  l_cur_pe_usr_arg      cur_pe_usr_arg%ROWTYPE;
  l_cur_en_nstd_usec    cur_en_nstd_usec%ROWTYPE;
  l_cur_en_cal_conf     cur_en_cal_conf%ROWTYPE;
  l_cur_chk_cp_chg_val  cur_chk_cp_chg_val%ROWTYPE;
  l_cur_ps_unit_ofr    cur_ps_unit_ofr%ROWTYPE;

  -- Variables
  l_v_person_type   igs_pe_person_types.person_type_code%TYPE;
  l_cp_out NUMBER;

  BEGIN

  -- Check for audit attempt
  OPEN cur_no_assessment_ind;
  FETCH cur_no_assessment_ind INTO l_no_assessment_ind;
  CLOSE cur_no_assessment_ind;
  -- Incase of an audit attempt the enrolled CP should not be
  -- updateable by the student, hence return 'N'
  IF l_no_assessment_ind = 'Y' THEN
      RETURN 'N';
  END IF;

  --Get the person logged in frmo session
  l_v_person_type := igs_en_gen_008.enrp_get_person_type(p_course_cd=>NULL);

  -- According to ENCR012, check that approved cp are not defined for this student
  -- Added as per the bug# 2364461.
  -- Start of new code.
  OPEN cur_sys_per_typ(l_v_person_type);
  FETCH cur_sys_per_typ INTO l_cur_sys_per_typ;
  CLOSE cur_sys_per_typ;
  -- End of new code.
  -- For Bug 2398133,removed the assignment
  -- l_v_person_type := l_cur_sys_per_typ.system_type
  -- as it was overwritting the person type of the logged in user.
  --
  IF l_cur_sys_per_typ.system_type = 'STUDENT' THEN
    IF fnd_profile.value('IGS_EN_UPDATE_CP_GS')='Y' THEN
      RETURN 'N';
    END IF;

    IF igs_en_gen_015.validation_step_is_overridden(
      p_eligibility_step_type        => 'VAR_CREDIT_APPROVAL',
      p_load_cal_type                => p_cal_type,
      p_load_cal_seq_number          => p_ci_sequence_number,
      p_person_id                    => p_person_id,
      p_uoo_id                       => p_uoo_id,
      p_step_override_limit          => l_cp_out) THEN
        RETURN 'N';
      END IF;
  END IF;


  -- Get the Unit, version_number for the UOO_ID passed into the function
  OPEN  cur_ps_unit_ofr;
  FETCH cur_ps_unit_ofr INTO l_cur_ps_unit_ofr;
  CLOSE cur_ps_unit_ofr;

  -- check that the unit is set up as allowing points override in PSP
  OPEN cur_chk_cp_chg_val(l_cur_ps_unit_ofr.unit_cd,l_cur_ps_unit_ofr.version_number);
  FETCH cur_chk_cp_chg_val INTO l_cur_chk_cp_chg_val;
  CLOSE cur_chk_cp_chg_val;

  IF l_cur_chk_cp_chg_val.points_override_ind = 'Y' THEN
  --This above condition means that override cp is allowed
  --So check for deadlines at user,unit section level and institution level



  --If person type exists, check that any user level deadlines are not passed
  IF l_v_person_type IS NOT NULL THEN
    -- check if any date_aliases are defined for the person_type
    -- if found then validate them
    -- else validate dates at Unit Section Level
    OPEN cur_pe_usr_arg(l_v_person_type);
    FETCH cur_pe_usr_arg INTO l_cur_pe_usr_arg;
    IF cur_pe_usr_arg%FOUND THEN
      CLOSE cur_pe_usr_arg;
      OPEN cur_pe_usr_arg(l_v_person_type);
        LOOP
          EXIT WHEN cur_pe_usr_arg%NOTFOUND;
          FETCH cur_pe_usr_arg INTO l_cur_pe_usr_arg;
          IF ( TRUNC(l_cur_pe_usr_arg.alias_val) < TRUNC(SYSDATE) ) THEN
            RETURN 'N';
          END IF;
        END LOOP;
      CLOSE cur_pe_usr_arg;
      RETURN 'Y';
    ELSE
      CLOSE cur_pe_usr_arg;
    END IF;
  END IF;

  --Check if unit section level deadline has not passed
  OPEN cur_en_nstd_usec;
  FETCH cur_en_nstd_usec INTO l_cur_en_nstd_usec;
  IF cur_en_nstd_usec%FOUND THEN
    CLOSE cur_en_nstd_usec;
    OPEN cur_en_nstd_usec;
    LOOP
      EXIT WHEN cur_en_nstd_usec%NOTFOUND;
      FETCH cur_en_nstd_usec INTO l_cur_en_nstd_usec;
      IF ( TRUNC(l_cur_en_nstd_usec.alias_val) < TRUNC(SYSDATE) ) THEN
        RETURN 'N';
      END IF;
    END LOOP;
    CLOSE cur_en_nstd_usec;
    RETURN 'Y';
  ELSE
      CLOSE cur_en_nstd_usec;
  END IF;

  --Check if institution level deadline has not passed
    OPEN cur_en_cal_conf;
    FETCH cur_en_cal_conf INTO l_cur_en_cal_conf;
    IF cur_en_cal_conf%FOUND THEN
      CLOSE cur_en_cal_conf;
      OPEN cur_en_cal_conf;
      LOOP
        EXIT WHEN cur_en_cal_conf%NOTFOUND;
        FETCH cur_en_cal_conf INTO l_cur_en_cal_conf;
        IF ( TRUNC(l_cur_en_cal_conf.alias_val) < TRUNC(SYSDATE) ) THEN
          RETURN 'N';
        END IF;
      END LOOP;
      CLOSE cur_en_cal_conf;
      RETURN 'Y';
    ELSE
      CLOSE cur_en_cal_conf;
      RETURN 'Y';
    END IF;

  ELSE
    RETURN 'N';
  END IF;

  END enrp_val_chg_cp;

  FUNCTION enrp_get_dflt_sdrt(
  p_s_discont_reason_type IN VARCHAR2 )
  RETURN VARCHAR2 IS

    /******************************************************************
    Created By        : Prajeesh Chandran
    Date Created By   : 14-May-2002
    Purpose           :This function Returns the Default discontinuation reason code if exists
    Known limitations,
    enhancements,
    remarks            :
    Change History
    Who      When        What
    ******************************************************************/
        -- enrp_get_dflt_sdt
        -- Get the default discontinuation_reason_cd for a nominated
        -- s_discontinuation_reason_type, based on the sys_dflt_ind field.
        v_discontinuation_reason_cd  IGS_EN_DCNT_REASONCD.discontinuation_reason_cd%TYPE;
        CURSOR  c_dr IS
                SELECT discontinuation_reason_cd
                FROM    IGS_EN_DCNT_REASONCD            dr
                WHERE   dr.s_discontinuation_reason_type        = p_s_discont_reason_type AND
                        dr.sys_dflt_ind                         = 'Y' AND
                        dr.closed_ind                           = 'N';

BEGIN
        OPEN c_dr;
        FETCH c_dr INTO v_discontinuation_reason_cd;
        IF c_dr%NOTFOUND THEN
                CLOSE c_dr;
                RETURN NULL;
        END IF;
        CLOSE c_dr;
        RETURN v_discontinuation_reason_cd;
EXCEPTION
        WHEN OTHERS THEN
                IF c_dr%ISOPEN THEN
                        CLOSE c_dr;
                END IF;
                RETURN NULL;

END enrp_get_dflt_sdrt;


FUNCTION enrp_get_pr_outcome(
  p_person_id IN NUMBER,
  p_course_cd IN VARCHAR2
) RETURN VARCHAR2 AS


        -- get the currently active unit set for the person course attempt
        CURSOR c_active_us IS
          SELECT susa.selection_dt
          FROM  igs_as_su_setatmpt susa , igs_en_unit_set us , igs_en_unit_set_cat usc
          WHERE  susa.person_id = p_person_id  AND
            susa.course_cd  = p_course_cd      AND
            susa.selection_dt IS NOT NULL      AND
            susa.end_dt IS NULL                AND
            susa.rqrmnts_complete_dt  IS NULL  AND
            susa.unit_set_cd = us.unit_set_cd  AND
            us.unit_set_cat = usc.unit_set_cat AND
            usc.s_unit_set_cat  = 'PRENRL_YR' ;


      -- find the last active unit set for the person program
      CURSOR c_last_us  IS
      SELECT susa.selection_dt
      FROM  igs_as_su_setatmpt susa , igs_en_unit_set us , igs_en_unit_set_cat usc
      WHERE susa.person_id = p_person_id AND
        susa.course_cd = p_course_cd  AND
        susa.rqrmnts_complete_dt IS NOT NULL   AND
        susa.unit_set_cd = us.unit_set_cd AND
        us.unit_set_cat = usc.unit_set_cat AND
        usc.s_unit_set_cat  = 'PRENRL_YR'
      ORDER BY susa.rqrmnts_complete_dt  desc ;

        -- checks the eligibility of the student to be moved to the next year of program (unit set)
        -- by checking if there is any outcome preventing the progress of the student program attempt
        CURSOR  c_prog_outcome(cp_select_dt  igs_as_su_setatmpt.selection_dt%TYPE) IS
          SELECT  pou.decision_dt, pout.s_progression_outcome_type
          FROM  igs_pr_stdnt_pr_ou_all pou , igs_pr_ou_type pout
          WHERE   pou.person_id = p_person_id  AND
                pou.course_cd  = p_course_cd       AND
                pou.decision_status = 'APPROVED'   AND
                pou.decision_dt IS NOT NULL        AND
                pou.decision_dt  >  cp_select_dt   AND
                pou.progression_outcome_type = pout.progression_outcome_type
         ORDER BY pou.decision_dt desc ;
        c_prog_outcome_rec   c_prog_outcome%ROWTYPE;

        v_selection_dt    IGS_AS_SU_SETATMPT.SELECTION_DT%TYPE;
        cst_advance       CONSTANT VARCHAR2(30) := 'ADVANCE';
        cst_repeatyr      CONSTANT VARCHAR2(30) := 'REPEATYR';

BEGIN

    v_selection_dt := NULL;
    -- If there is a currently active year of program then make it completed
    --and pre-enrol in the  next year of program , if it exists
    OPEN c_active_us ;
    FETCH c_active_us INTO v_selection_dt;
    IF c_active_us%FOUND  THEN
      CLOSE c_active_us ;
      NULL;
    ELSE -- c_active_us
      CLOSE c_active_us ;
      OPEN c_last_us ;
      FETCH c_last_us INTO v_selection_dt ;
      IF c_last_us%NOTFOUND THEN
        CLOSE c_last_us ;
        RETURN 'NEW';
      END IF;
      CLOSE c_last_us ;
    END IF; --  c_active_us%FOUND

    -- check if there is any progression outcome preventing this student
    -- from completing this unit set attempt and going into the next year of program
    OPEN  c_prog_outcome(v_selection_dt) ;
    FETCH c_prog_outcome INTO c_prog_outcome_rec ;

    IF c_prog_outcome%NOTFOUND THEN
      CLOSE  c_prog_outcome;
      RETURN cst_advance;
    ELSIF c_prog_outcome_rec.s_progression_outcome_type = cst_advance  OR
          c_prog_outcome_rec.s_progression_outcome_type = cst_repeatyr  THEN
      CLOSE  c_prog_outcome;
      RETURN c_prog_outcome_rec.s_progression_outcome_type;
    ELSE
      CLOSE  c_prog_outcome;
      RETURN NULL;
    END IF;

    IF c_prog_outcome%ISOPEN THEN
      CLOSE  c_prog_outcome;
    END IF;

    RETURN cst_advance;

END enrp_get_pr_outcome;

END igs_en_gen_008;

/
