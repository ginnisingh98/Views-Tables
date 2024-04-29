--------------------------------------------------------
--  DDL for Package Body IGS_AV_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AV_GEN_001" AS
/* $Header: IGSAV01B.pls 120.12 2006/05/04 00:02:26 amanohar ship $ */


/******************************************************************
  Created By         :
  Date Created By    :
  Purpose            :
  remarks            :
  Change History
  Who           When                What
  svenkata  20-NOV-2002     Modified the call to the function igs_en_val_sua.enrp_val_sua_discont to add value 'N' for the parameter
                            p_legacy. Bug#2661533
  nalkumar    12-July-2002      Modify the 'ADVP_UPD_AS_GRANT' procedure to grant only the advanced standing which is of 'CREDIT' type.
                                Modified the 'ADVP_UPD_AS_PE_EXPRY' procedure to expire only the Advanced Standing which is not of 'PRECLUSION' type.
                                this is as per Bug# 2441175.
  nalkumar    05-June-2002      Replaced the referances of the igs_av_stnd_unit/unit_lvl.(PREV_UNIT_CD and TEST_DETAILS_ID) columns
                                to igs_av_stnd_unit/unit_lvl.(unit_details_id and tst_rslt_dtls_id) columns. This is as per Bug# 2401170
  nalkumar      28-May-2002     Bug# 2382566. Added the call to the repeat logic.
  kdande        20-Mar-2002     Bug # 2241710. Changed all references of 'IGS_PS_UNIT ' to 'UNIT ' and
                                'IGS_PS_UNIT LEVEL' to 'UNIT LEVEL'
  nalkumar      04-Mar-2002     Modified the advp_upd_as_pe_grant procedure to fix the Bug# 2121621
  prraj         21-Feb-2002     Added column QUAL_DETS_ID to the tbh calls of pkg
                                IGS_AV_STND_UNIT_LVL_PKG (Bug# 2233334)
  pmarada       27-Nov-2001     Added the AV_STND_UNIT_ID column in igs_av_stnd_unit_pkg and
                                AV_STND_UNIT_LVL_ID column in igs_av_stnd_unit_lvl_pkg.
  sarakshi      21-SEP-2001     Removes all logic of deleting/updating the units enrollemnts due to advance standing
                                records processing.Also changes the percentage logic as mentioned in the dld Acedemic
                                Records Maintanence Build(bug no:1960126)
  knaraset  02-May-03   Modified the function advp_upd_sua_advstnd to pass uoo_id to internal function enrpl_delete_sua_recs
                        as part of MUS build bug 2829262
 rvivekan   09-sep-2003   Modified the behaviour of repeatable_ind column in igs_ps_unit_ver table. PSP integration build #3052433
 stutta     27-Oct-2003   Modified funcion advp_upd_sua_advstnd by removing calls to functions IGS_EN_VAL_SUA.enrp_val_sca_supunit,
                          IGS_EN_VAL_SUA.enrp_val_sca_subunit as part of build #3052438
 nalkumar 10-Dec-2003       Bug# 3270446 RECR50 Build; Obsoleted the IGS_AV_STND_UNIT.CREDIT_PERCENTAGE column.
 swaghmar 15-Jun-2005       Bug# 4377816. Changed the cursor queries to pick party_number from igs_pe_hz_parties instead of hz_parties
 sgurusam 17-Jun-2005       Modified to pass aditional parameter p_calling_obj = 'JOB' in the calls to
                            igs_en_elgbl_unit.eval_unit_repeat
 jhanda    10-july-05	  Build 4327991 BUILD FOR RE105 TRANSFER EVALUATION UI ENHANCEMENTS

 amanohar  23-Nov-2005    Bug#4726833 IGSQUKRM:ADVANCED STANDING CREDIT POINTS NOT SUMMUING IN YOP MODE VAH PAGE
 sepalani  21-Mar-2006    Bug#5104563 12A-M1R: INFO QUERY ON ADV STANDING GRANTING REPORT

*********************************************************************************************************/

FUNCTION advp_del_adv_stnd(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_default_message OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS
  gv_other_detail               VARCHAR2(255);
BEGIN   -- advp_del_adv_stnd
        -- Delete advanced standing details for a student course attempt
  DECLARE
        cst_approved    CONSTANT        VARCHAR2(30) := 'APPROVED';
        e_resource_busy                 EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_resource_busy, -54);
        v_dummy                         VARCHAR2(1);
        v_error_number                  NUMBER;
        v_constraint                    user_constraints.constraint_name%TYPE;
        v_ri_check_failed               BOOLEAN DEFAULT FALSE;
        CURSOR c_asu IS
                SELECT  'X'
                FROM    IGS_AV_STND_UNIT   asu
                WHERE   asu.person_id                   = p_person_id AND
                        asu.as_course_cd                = p_course_cd AND
                        asu.s_adv_stnd_granting_status  <> cst_approved;
        CURSOR c_asul IS
                SELECT  'X'
                FROM    IGS_AV_STND_UNIT_LVL            asul
                WHERE   asul.person_id                  = p_person_id AND
                        asul.as_course_cd               = p_course_cd AND
                        asul.s_adv_stnd_granting_status <> cst_approved;

	 CURSOR c_unit_all IS
                SELECT  rowid,av_stnd_unit_id
                FROM    IGS_AV_STND_UNIT_ALL   asua
                WHERE   asua.person_id                   = p_person_id AND
                        asua.as_course_cd                = p_course_cd ;

	 CURSOR c_adv_all IS
                SELECT  rowid
                FROM    IGS_AV_ADV_STANDING_ALL   asal
                WHERE   asal.person_id                   = p_person_id AND
                        asal.course_cd                   = p_course_cd;

	 CURSOR c_unit_lvl_all IS
                SELECT  rowid,av_stnd_unit_lvl_id
                FROM    IGS_AV_STND_UNIT_LVL_ALL  aslvl
                WHERE   aslvl.person_id                   = p_person_id AND
                        aslvl.as_course_cd                = p_course_cd;

	 CURSOR c_unit_basis_all(cp_unit_id IGS_AV_STD_UNT_BASIS_ALL.av_stnd_unit_id%TYPE) IS
                SELECT  rowid
                FROM    IGS_AV_STD_UNT_BASIS_ALL   asba
                WHERE  	asba.av_stnd_unit_id             = cp_unit_id;

	 CURSOR c_ulvlbasis_all(cp_unit_lvl_id IGS_AV_STD_ULVLBASIS_ALL.av_stnd_unit_lvl_id%TYPE) IS
                SELECT  rowid
                FROM    IGS_AV_STD_ULVLBASIS_ALL   asbl
                WHERE   asbl.av_stnd_unit_lvl_id         = cp_unit_lvl_id;

	 CURSOR c_alt_unt_all(cp_alt_unit_id IGS_AV_STND_ALT_UNIT.av_stnd_unit_id%TYPE) IS
	        SELECT  rowid
	        FROM    IGS_AV_STND_ALT_UNIT   asau
	        WHERE   asau.av_stnd_unit_id         = cp_alt_unit_id;


  BEGIN
        p_default_message := NULL;
        -- Check if the advanced standing can be deleted (Can only delete granting
        -- status of 'APPROVED')
        OPEN c_asu;
        FETCH c_asu INTO v_dummy;
        IF c_asu%FOUND THEN
                CLOSE c_asu;
                 p_message_name := 'IGS_AV_CANNOT_DELETE';
                RETURN FALSE;
        END IF;
        CLOSE c_asu;
        OPEN c_asul;
        FETCH c_asul INTO v_dummy;
        IF c_asul%FOUND THEN
                CLOSE c_asul;
                p_message_name := 'IGS_AV_CANNOT_DELETE';
                RETURN FALSE;
        END IF;
        CLOSE c_asul;



	FOR v_unit_all IN c_unit_all
	LOOP

	FOR v_unit_basis_all IN c_unit_basis_all(v_unit_all.av_stnd_unit_id)
	LOOP
        igs_av_std_unt_basis_pkg.DELETE_ROW (
	    X_ROWID => v_unit_basis_all.rowid );
	END LOOP;

        IF (fnd_log.level_statement >=FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string( fnd_log.level_statement, 'igs.plsql.IGS_AV_GEN_001.advp_del_adv_stnd','Deleted unit basis for'||v_unit_all.av_stnd_unit_id  );
        END IF;

	FOR v_alt_unt_all IN c_alt_unt_all(v_unit_all.av_stnd_unit_id)
	LOOP
        igs_av_stnd_alt_unit_pkg.DELETE_ROW (
	    X_ROWID => v_alt_unt_all.rowid );
	END LOOP;


	igs_av_stnd_unit_pkg.DELETE_ROW (
	    X_ROWID => v_unit_all.rowid );


        IF (fnd_log.level_statement >=FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string( fnd_log.level_statement, 'igs.plsql.IGS_AV_GEN_001.advp_del_adv_stnd','Deleted unit');
        END IF;

	END LOOP;


	FOR v_unit_lvl_all IN c_unit_lvl_all
	LOOP

        FOR v_ulvlbasis_all IN c_ulvlbasis_all(v_unit_lvl_all.av_stnd_unit_lvl_id)
	LOOP
        igs_av_std_ulvlbasis_pkg.DELETE_ROW (
	    X_ROWID => v_ulvlbasis_all.rowid );
	END LOOP;

        IF (fnd_log.level_statement >=FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string( fnd_log.level_statement, 'igs.plsql.IGS_AV_GEN_001.advp_del_adv_stnd','Deleted unit level basis'||v_unit_lvl_all.av_stnd_unit_lvl_id);
        END IF;

       igs_av_stnd_unit_lvl_pkg.DELETE_ROW (
	    X_ROWID => v_unit_lvl_all.rowid );


        IF (fnd_log.level_statement >=FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string( fnd_log.level_statement, 'igs.plsql.IGS_AV_GEN_001.advp_del_adv_stnd','Deleted unit level');
        END IF;

	END LOOP;

 	FOR v_adv_all IN c_adv_all
	LOOP
        igs_av_adv_standing_pkg.DELETE_ROW (
	    X_ROWID => v_adv_all.rowid );

        IF (fnd_log.level_statement >=FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string( fnd_log.level_statement, 'igs.plsql.IGS_AV_GEN_001.advp_del_adv_stnd','Deleted from IGS_AV_ADV_STANDING_ALL');
        END IF;

	END LOOP;

        p_message_name := NULL;
        p_default_message := NULL;
        RETURN TRUE;

  EXCEPTION
        WHEN e_resource_busy THEN
                RETURN FALSE;
        WHEN OTHERS THEN
                IF c_asu%ISOPEN THEN
                        CLOSE c_asu;
                END IF;
                IF c_asul%ISOPEN THEN
                        CLOSE c_asul;
                END IF;
                IF c_unit_all%ISOPEN THEN
                        CLOSE c_unit_all;
                END IF;
                IF c_unit_basis_all%ISOPEN THEN
                        CLOSE c_unit_basis_all;
                END IF;
                IF c_ulvlbasis_all%ISOPEN THEN
                        CLOSE c_ulvlbasis_all;
                END IF;
                IF c_unit_lvl_all%ISOPEN THEN
                        CLOSE c_unit_lvl_all;
                END IF;
                IF c_adv_all%ISOPEN THEN
                        CLOSE c_adv_all;
                END IF;
                RAISE;
  END;
EXCEPTION
        WHEN OTHERS THEN
               Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
               Fnd_Message.Set_Token('NAME','IGS_AV_GEN_001.ADVP_DEL_ADV_STND');
               Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
END advp_del_adv_stnd;

FUNCTION adv_credit_pts(p_person_id IN NUMBER,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE) RETURN NUMBER IS

        CURSOR c_adv_cp_sum IS
                SELECT SUM(NVL(asu.achievable_credit_points,0)) advance_standing_credits,
                SUM(NVL(puv.achievable_Credit_points,puv.enrolled_Credit_points)) enrolled_cp ,
                asu.unit_cd,asu.version_number
                FROM igs_av_stnd_unit asu,igs_ps_unit_ver puv WHERE
                asu.person_id                   = p_person_id AND
                asu.as_course_cd                = p_course_cd AND
                puv.unit_cd                     = asu.unit_cd AND
                puv.version_number              = asu.version_number AND
                asu.s_adv_stnd_granting_status  = 'GRANTED' AND
                asu.s_adv_stnd_recognition_type = 'CREDIT' AND
                (p_effective_dt IS NULL OR asu.granted_dt <= TRUNC(p_effective_dt))
                GROUP BY asu.unit_cd,asu.version_number;

        CURSOR c_adv_cp_per(cp_unit_cd igs_av_stnd_unit.unit_cd%TYPE,
                         cp_version_number igs_av_stnd_unit.version_number%TYPE) IS
               SELECT NVL(puv.achievable_Credit_points,puv.enrolled_Credit_points) enrolled_credits
               FROM igs_av_stnd_unit asu,igs_ps_unit_ver puv
               WHERE asu.person_id             = p_person_id
               AND asu.as_course_cd      = p_course_cd
               AND asu.unit_cd           = cp_unit_cd
               AND asu.version_number    = cp_version_number
               AND asu.s_adv_stnd_granting_status = 'GRANTED'
               AND asu.s_adv_stnd_recognition_type = 'CREDIT'
               AND (p_effective_dt IS NULL OR asu.granted_dt <= TRUNC(p_effective_dt))
               /* AND credit_percentage = 100 */
               AND puv.unit_cd = asu.unit_cd
               AND puv.version_number = asu.version_number;

  l_adv_cp_sum  c_adv_cp_sum%ROWTYPE;
  l_adv_cp_per  c_adv_cp_per%ROWTYPE;
  l_total_cp    NUMBER;

  BEGIN
       l_total_cp := 0;
       OPEN c_adv_cp_sum;
       LOOP
         FETCH c_adv_cp_sum INTO l_adv_cp_sum;
         EXIT WHEN c_adv_cp_sum%NOTFOUND;
         IF l_adv_cp_sum.advance_standing_credits < l_adv_cp_sum.enrolled_cp THEN
            OPEN c_adv_cp_per(l_adv_cp_sum.unit_cd,l_adv_cp_sum.version_number);
            FETCH c_adv_cp_per INTO l_adv_cp_per;
            IF c_adv_cp_per%FOUND THEN
               l_total_cp := l_total_cp + l_adv_cp_per.enrolled_credits;
            END IF;
            CLOSE c_adv_cp_per;
         ELSE
            l_total_cp := l_total_cp + l_adv_cp_sum.advance_standing_credits;
         END IF;
      END LOOP;
      CLOSE c_adv_cp_sum;
      RETURN l_total_cp;

END adv_credit_pts;


FUNCTION advp_get_as_total(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE )
RETURN NUMBER IS
  gv_other_detail               VARCHAR2(255);
BEGIN   -- advp_get_as_total
  DECLARE
        v_adv_total                             NUMBER;
        v_asu_uv_sum                            NUMBER;
        v_asul_sum                              NUMBER;
        cst_granted CONSTANT  IGS_AV_STND_UNIT.s_adv_stnd_granting_status%TYPE := 'GRANTED';

        CURSOR c_asul IS
                SELECT  SUM(credit_points)
                FROM    IGS_AV_STND_UNIT_LVL asul
                WHERE   asul.person_id                  = p_person_id AND
                        asul.as_course_cd               = p_course_cd AND
                        asul.s_adv_stnd_granting_status = cst_granted AND
                        (p_effective_dt IS NULL OR
                         asul.granted_dt        <= TRUNC(p_effective_dt));
  BEGIN
        -- Set the default message number
        v_adv_total := 0.00;
        v_adv_total := ADV_CREDIT_PTS(p_person_id,p_course_cd,p_effective_dt );
        OPEN c_asul;
        FETCH c_asul INTO v_asul_sum;
        IF c_asul%FOUND AND v_asul_sum IS NOT NULL THEN
           v_adv_total := (v_adv_total + v_asul_sum);
        END IF;
        CLOSE c_asul;
        -- Return the default value
        RETURN v_adv_total;
  EXCEPTION
        WHEN OTHERS THEN

                IF c_asul%ISOPEN THEN
                        CLOSE c_asul;
                END IF;
                RAISE;
  END;
END advp_get_as_total;

PROCEDURE adv_validate_grade (p_grdschcode IN VARCHAR2,p_grde IN VARCHAR2,p_grschverno IN NUMBER,validity OUT NOCOPY VARCHAR2)
IS
      v_valid_grades NUMBER(2);

      CURSOR c_validate_grade_cur(grschcd VARCHAR2,grschvno NUMBER,grd VARCHAR2)
      IS
	SELECT COUNT (rowid)
	  FROM igs_as_grd_sch_grade
	 WHERE grading_schema_cd = grschcd
	   AND version_number = grschvno
	   AND grade = grd;

 BEGIN

 OPEN c_validate_grade_cur(p_grdschcode,p_grschverno,p_grde);

 FETCH c_validate_grade_cur INTO v_valid_grades;

 IF (v_valid_grades = 1)
 THEN
      validity := 'VALID';
 ELSE
      validity := 'INVALID';
 END IF;

 CLOSE c_validate_grade_cur;

 END adv_validate_grade;


PROCEDURE advp_upd_as_grant(
            errbuf  OUT NOCOPY  VARCHAR2,
            retcode OUT NOCOPY  NUMBER,
            p_org_id IN   NUMBER )
IS
-- This procedure will get all eligible persons and process them for
-- advance standing
        v_other_details                     VARCHAR2(255);
BEGIN
                -- To set org_id as in request of job.
                -- This is added to fix Bug no# 1635976.
                IGS_GE_GEN_003.set_org_id(p_org_id);

  DECLARE
        v_ret_value                     BOOLEAN;
        v_s_log_type                    IGS_GE_S_LOG.s_log_type%TYPE        DEFAULT NULL;
        v_creation_dt                   IGS_GE_S_LOG.creation_dt%TYPE       DEFAULT NULL;
        cst_approved                    CONSTANT IGS_AV_STND_UNIT.s_adv_stnd_granting_status%TYPE := 'APPROVED';
        cst_credit                      CONSTANT IGS_AV_STND_UNIT.s_adv_stnd_recognition_type%TYPE := 'CREDIT';
        v_message_name                  VARCHAR2(30)    DEFAULT NULL ;
        -- Counters
        tot_rec_process                 NUMBER DEFAULT 0;
        v_ret_false                     NUMBER DEFAULT 0;
        V_MESSAGE1                      VARCHAR2(50);
        V_MESSAGE2                      VARCHAR2(50);
        V_MESSAGE3                      VARCHAR2(50);
        CURSOR c_adv_stnd_unit IS
                SELECT  person_id
                FROM    IGS_AV_STND_UNIT_ALL
                WHERE   s_adv_stnd_granting_status      = cst_approved AND
                        s_adv_stnd_recognition_type     = cst_credit
                UNION
                SELECT  person_id
                FROM    IGS_AV_STND_UNIT_LVL_ALL
                WHERE   s_adv_stnd_granting_status = cst_approved;
  BEGIN
        FOR v_adv_stnd_unit IN c_adv_stnd_unit LOOP
                IF NOT advp_upd_as_pe_grant(
                                v_adv_stnd_unit.person_id,
                                NULL,
                                NULL,
                                SYSDATE,
                                'ALL',
                                v_s_log_type,
                                v_creation_dt,
                                v_message_name) THEN
                        v_ret_false := v_ret_false + 1;

                        V_MESSAGE1 := FND_MESSAGE.GET_STRING ('IGS','IGS_AV_STAND_NOT_GRANT')||TO_CHAR(v_adv_stnd_unit.person_id);
                        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING ('IGS',V_MESSAGE1));
                END IF;
                IF v_message_name IS NOT NULL AND v_message_name NOT IN ('IGS_AV_HAS_UNIT_ATT') THEN
                   FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING ('IGS',V_MESSAGE_NAME));
                END IF;
                tot_rec_process := tot_rec_process + 1;
        END LOOP;
        IF tot_rec_process = 0 THEN
             FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING ('IGS','IGS_AV_NO_AV_STAND_PRS'));
        ELSE
           V_MESSAGE2 := FND_MESSAGE.GET_STRING ('IGS','IGS_GE_TOTAL_REC_PROCESSED')||TO_CHAR(tot_rec_process) ;
           FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING ('IGS',V_MESSAGE2));
           V_MESSAGE3 := FND_MESSAGE.GET_STRING ('IGS','IGS_GE_TOTAL_REC_FAILED')||TO_CHAR(v_ret_false) ;
           FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING ('IGS',V_MESSAGE3));
        END IF;
        FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET_STRING ('IGS','IGS_AV_STAND_PRS_SUCCESS'));
  END;
EXCEPTION
      WHEN OTHERS THEN
            RETCODE:=2;
            ERRBUF:=FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
            IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
END advp_upd_as_grant;

FUNCTION advp_upd_as_inst(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
 p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN IS
        gv_other_detail         VARCHAR2(255);
BEGIN   -- advp_upd_as_inst
        -- Determine the institution which has contributed the majority
        -- of the student's granted advanced standing.  It then updates
        -- the advanced standing exemption institution.
  DECLARE
        e_resource_busy                 EXCEPTION;
        PRAGMA EXCEPTION_INIT (e_resource_busy, -54);
        v_major_exmpt_inst              VARCHAR2(64);
        v_exemption_institution_cd      IGS_AV_STND_UNIT_CREDIT_V.exemption_institution_cd%TYPE;
        v_max_credit                    NUMBER(5);
        v_check                         CHAR;
        v_advanced_standing             IGS_AV_ADV_STANDING%ROWTYPE;
        CURSOR c_ascv IS
          SELECT   suc.exemption_institution_cd,
                   SUM (suc.credit)
          FROM     (SELECT asu.person_id person_id,
                           asu.as_course_cd course_cd,
                           asu.as_version_number version_number,
                           asu.exemption_institution_cd exemption_institution_cd,
                           uv.achievable_credit_points credit
                    FROM   igs_av_stnd_unit_all asu,
                           igs_ps_unit_ver_all uv
                    WHERE  asu.unit_cd = uv.unit_cd
                    AND    asu.version_number = uv.version_number
                    AND    asu.s_adv_stnd_recognition_type = 'CREDIT'
                    AND    asu.s_adv_stnd_granting_status = 'GRANTED'
                    UNION ALL
                    SELECT asule.person_id,
                           asule.as_course_cd,
                           asule.as_version_number,
                           asule.exemption_institution_cd,
                           asule.credit_points credit
                    FROM   igs_av_stnd_unit_lvl_all asule
                    WHERE  asule.s_adv_stnd_granting_status = 'GRANTED') suc
          WHERE    suc.person_id = p_person_id
          AND      suc.course_cd = p_course_cd
          AND      suc.version_number = p_version_number
          GROUP BY suc.exemption_institution_cd
          ORDER BY SUM (suc.credit) DESC;
        CURSOR c_exempt_inst_v (
                        cp_exemption_institution_cd     igs_pe_hz_parties.inst_org_ind%TYPE) IS
			SELECT 'x'
			FROM igs_pe_hz_parties ihp
			 where ihp.inst_org_ind = 'I'
			 AND ihp.oi_govt_institution_cd IS NOT NULL
			 AND ihp.oss_org_unit_cd = cp_exemption_institution_cd
			UNION ALL
			SELECT 'x'
			FROM igs_lookup_values lk
			WHERE lk.lookup_type = 'OR_INST_EXEMPTIONS'
			 AND lk.enabled_flag = 'Y'
			 AND lk.lookup_code = cp_exemption_institution_cd;
        CURSOR c_institution (
                        cp_exemption_institution_cd     IGS_OR_INSTITUTION.institution_cd%TYPE) IS
                SELECT  'x'
                FROM    hz_parties hp,
                        igs_pe_hz_parties ihp
                WHERE   ihp.oss_org_unit_cd  = cp_exemption_institution_cd --swaghmar bug# 4377816
                AND     hp.party_id = ihp.party_id
                AND     ihp.inst_org_ind = 'I'
                AND     ihp.oi_os_ind = 'Y';
        CURSOR c_advanced_standing IS
                SELECT  *
                FROM    IGS_AV_ADV_STANDING
                WHERE   person_id       = p_person_id   AND
                        course_cd       = p_course_cd   AND
                        version_number  = p_version_number
                FOR UPDATE OF exemption_institution_cd NOWAIT;
  BEGIN
         p_message_name := NULL;
        -- Validate input parameters
        IF (            p_person_id IS NULL     OR
                        p_course_cd IS NULL     OR
                        p_version_number IS NULL) THEN
                RETURN TRUE;
        END IF;
        -- Determine if person is a commencing student.
                -- Determine the exemption institution code which has been the source of the
                -- greatest amount of granted credit.
                OPEN c_ascv;
                FETCH c_ascv INTO       v_exemption_institution_cd,
                                        v_max_credit;
                IF ((c_ascv%NOTFOUND) OR
                    ((c_ascv%FOUND) AND
                     (v_max_credit IS NULL))) THEN
                        -- No credit granted
                        v_major_exmpt_inst := '1';
                ELSE
                        -- Map the institution to appropriate DEETYA code for inclusion in Adv_stnd
                        OPEN c_exempt_inst_v (v_exemption_institution_cd);
                        FETCH c_exempt_inst_v INTO v_check;
                        IF (c_exempt_inst_v%FOUND) THEN
                                v_major_exmpt_inst := v_exemption_institution_cd;
                        ELSIF (v_exemption_institution_cd = 'UNKNOWN') THEN
                                v_major_exmpt_inst := '4999';
                        ELSIF (v_exemption_institution_cd = 'NOT INSTN') THEN
                                v_major_exmpt_inst := '8004';
                        ELSE
                                OPEN c_institution (v_exemption_institution_cd);
                                FETCH c_institution INTO v_check;
                                IF (c_institution%FOUND) THEN
                                        v_major_exmpt_inst := '8002';
                                ELSE
                                        v_major_exmpt_inst := '4999';
                                END IF;
                                CLOSE c_institution;
                        END IF;
                        CLOSE c_exempt_inst_v;
                END IF; -- c_ascv%NOTFOUND
                CLOSE c_ascv;
        OPEN c_advanced_standing;
        FETCH c_advanced_standing INTO v_advanced_standing;
        IF (c_advanced_standing%FOUND) THEN
                UPDATE  IGS_AV_ADV_STANDING
                SET     exemption_institution_cd = v_major_exmpt_inst
                WHERE CURRENT OF c_advanced_standing;
        END IF;
        CLOSE c_advanced_standing;
        RETURN TRUE;
  EXCEPTION
        WHEN e_resource_busy THEN
                IF (c_advanced_standing%ISOPEN) THEN
                        CLOSE c_advanced_standing;
                END IF;
                p_message_name := 'IGS_AV_UNABLE_UPD_TOTALS';
                RETURN FALSE;
  END;
END advp_upd_as_inst;

FUNCTION advp_upd_as_pe_grant(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_granted_dt IN DATE ,
  p_process_type IN VARCHAR2 ,
  p_s_log_type IN OUT NOCOPY VARCHAR2 ,
  p_creation_dt IN OUT NOCOPY DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS
gv_other_detail         VARCHAR2(255);
lv_param_values         VARCHAR2(1080);
BEGIN   -- advp_upd_as_pe_grant
        -- Grant approved advance standing for a person/course and
        -- impacts the student's enrolment if necessary.
  --
  --  kdande 20-Mar-2002.
  --  Bug # 2241710. Changed all references of 'IGS_PS_UNIT ' to 'UNIT ' and
  --  'IGS_PS_UNIT LEVEL' to 'UNIT LEVEL'
  --

  --
  -- sepalani - 22-Mar-2006 Bug # 5104563 12A-M1R : INFO QUERY ON ADV STANDING GRANTING REPORT
  -- logic changed for "repeat set to none" unit codes.
  --
  DECLARE
        cst_adv_stnd_grant              CONSTANT VARCHAR2(10)  := 'ADV-GRANT';
        cst_credit                      CONSTANT VARCHAR2(10)  := 'CREDIT';
        cst_course                      CONSTANT VARCHAR2(10)  := 'COURSE';
        cst_person                      CONSTANT VARCHAR2(10)  := 'PERSON';
        cst_all                         CONSTANT VARCHAR2(10)  := 'ALL';
        cst_approved                    CONSTANT VARCHAR2(10)  := 'APPROVED';
        cst_granted                     CONSTANT VARCHAR2(30)  := 'GRANTED';
        cst_granted_ge                  IGS_LOOKUPS_VIEW.lookup_code%TYPE;
        v_total_exmptn_approved         NUMBER(5);
        v_total_exmptn_granted          NUMBER(5);
        v_total_exmptn_perc_grntd       NUMBER(5);
        v_granted_dt                    DATE;
        v_check                         CHAR;
        v_key                           IGS_GE_S_LOG.key%TYPE;
        v_s_log_type                    IGS_GE_S_LOG.s_log_type%TYPE;
        v_creation_dt                   IGS_GE_S_LOG.creation_dt%TYPE;
        v_skip_course_cd                IGS_AV_STND_UNIT.as_course_cd%TYPE      DEFAULT 'ISNULL';
        v_skip_course_cd1               IGS_AV_STND_UNIT.as_course_cd%TYPE      DEFAULT 'ISNULL';
        v_skip_version_number           IGS_AV_STND_UNIT.as_version_number%TYPE DEFAULT 0;
        v_last_course_cd                IGS_AV_STND_UNIT.as_course_cd%TYPE      DEFAULT 'ISNULL';
        v_last_version_number           IGS_AV_STND_UNIT.as_version_number%TYPE DEFAULT 0;
        v_message_name                  VARCHAR2(30) DEFAULT NULL;
        v_message_key                   VARCHAR2(255);
        v_update_flag                   BOOLEAN DEFAULT TRUE;

        CURSOR c_sl (
                cp_s_log_type   IGS_GE_S_LOG.s_log_type%TYPE,
                cp_creation_dt  IGS_GE_S_LOG.creation_dt%TYPE) IS
                SELECT  'x'
                FROM    IGS_GE_S_LOG
                WHERE   s_log_type = cp_s_log_type AND
                        creation_dt = cp_creation_dt;

        CURSOR c_asu (cp_person_id      IGS_PE_PERSON.person_id%TYPE) IS
                SELECT        *
                FROM    IGS_AV_STND_UNIT
                WHERE
                        s_adv_stnd_granting_status = cst_approved       AND
                        s_adv_stnd_recognition_type = cst_credit AND
                        person_id = cp_person_id
                ORDER BY
                        person_id,
                        as_course_cd,
                        as_version_number,
                        approved_dt desc,
                        granted_dt desc;
--              FOR UPDATE NOWAIT;

        CURSOR c_asul (cp_person_id     IGS_PE_PERSON.person_id%TYPE) IS
                SELECT *
                FROM    IGS_AV_STND_UNIT_LVL
          WHERE
                        s_adv_stnd_granting_status = cst_approved       AND
                        person_id = cp_person_id
                ORDER BY
                        person_id,
                        as_course_cd,
                        as_version_number,
                        approved_dt desc,
                        granted_dt desc
                FOR UPDATE NOWAIT;
  BEGIN
         p_message_name := NULL;
        -- Validate input parameters
        IF (p_process_type IN (cst_all, cst_person, cst_course)) THEN
                IF (p_person_id IS NULL) OR
                        (p_process_type = cst_course AND
                                (p_course_cd IS NULL OR p_version_number IS NULL)) THEN
                                p_message_name := 'IGS_AV_NOT_DTRMINE_INSUF_INFO';
                                RETURN FALSE;
                ELSE
                        NULL; -- do nothing, continue processing
                END IF;
        ELSE
                p_message_name := 'IGS_AV_NOT_DTRMINE_INSUF_INFO';
                RETURN FALSE;
        END IF;
        IF (p_granted_dt IS NULL) THEN
                v_granted_dt := SYSDATE;
        ELSE
                v_granted_dt := p_granted_dt;
        END IF;
        -- Insert  Advanced standing granting process into system logging if it
        -- doesn't already exist
        OPEN c_sl(
                p_s_log_type,
                p_creation_dt);
        FETCH c_sl INTO v_check;
        IF c_sl%NOTFOUND THEN
                v_key := NULL;
                v_s_log_type := cst_adv_stnd_grant;
                IF p_process_type IN (cst_person, cst_course) THEN
                        v_key := p_person_id;
                END IF;
                IF (p_process_type = cst_course) THEN
                        v_key := v_key|| '|' || p_course_cd || '|' || p_version_number;
                END IF;
                IGS_GE_GEN_003.GENP_INS_LOG(
                        v_s_log_type,
                        v_key,
                        v_creation_dt);
                -- Set parameters
                p_s_log_type := v_s_log_type;
                p_creation_dt := v_creation_dt;
        ELSE
                v_s_log_type := p_s_log_type;
                v_creation_dt := p_creation_dt;
        END IF;
        CLOSE c_sl;
        -- Update approved IGS_AV_STND_UNIT
        p_message_name := 'IGS_AV_UNIT_UPD_ANOTHER_PRC';


        FOR v_asu_rec IN c_asu(p_person_id) LOOP
                IF (p_process_type = cst_course AND
                                (v_asu_rec.as_course_cd <> p_course_cd OR
                                 v_asu_rec.as_version_number <> p_version_number)) OR
                   (v_asu_rec.as_course_cd = v_skip_course_cd)  OR
                   (v_asu_rec.as_course_cd = v_skip_course_cd1 AND
                                v_asu_rec.as_version_number = v_skip_version_number)
                THEN
                        NULL; -- do nothing, continue IGS_AV_STND_UNIT
                ELSE
                        -- For each IGS_AV_STND_UNIT.as_course_cd
                        -- Validate that person/course is not excluded from advanced standing
                        IF (IGS_EN_VAL_ENCMB.enrp_val_excld_prsn(
                                        v_asu_rec.person_id,
                                        v_asu_rec.as_course_cd,
                                        v_granted_dt,
                                        v_message_name) = FALSE) THEN
                                -- Insert into messages for reporting
                                -- Do not process any more IGS_AV_STND_UNIT for this course
                                v_message_key := 'UNIT '                        || '|'  ||
                                                TO_CHAR(v_asu_rec.person_id)    || '|'  ||
                                                v_asu_rec.as_course_cd          || '|'  ||
                                                TO_CHAR(v_asu_rec.as_version_number) || '|' ||
                                                v_asu_rec.unit_cd               || '|'  ||
                                                TO_CHAR(v_asu_rec.version_number) || '|' ||
                                                FND_DATE.DATE_TO_DISPLAYDATE(v_granted_dt);
                                IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                        v_s_log_type,
                                        v_creation_dt,
                                        v_message_key,
                                        v_message_name,
                                        '');
                                v_skip_course_cd := v_asu_rec.as_course_cd;
                                GOTO continue;
                        END IF;
                        -- For each IGS_AV_STND_UNIT.as_course_cd/as_version_number
                        -- Validate advanced standing course version
                        IF (v_asu_rec.as_course_cd = v_last_course_cd AND
                             v_asu_rec.as_version_number = v_last_version_number) THEN
                                NULL; -- do nothing, continue IGS_AV_STND_UNIT
                        ELSE
                                v_last_course_cd := v_asu_rec.as_course_cd;
                                v_last_version_number :=   v_asu_rec.as_version_number;
                                IF (IGS_AV_VAL_ASU.advp_val_as_grant(
                                        v_asu_rec.person_id,
                                        v_asu_rec.as_course_cd,
                                        v_asu_rec.as_version_number,
                                        v_asu_rec.s_adv_stnd_granting_status,
                                        v_message_name) = FALSE) THEN
                                        -- Insert into messages for reporting
                                        -- Do not process any more IGS_AV_STND_UNIT for this course version
                                        v_message_key := 'UNIT '                        || '|'  ||
                                                TO_CHAR(v_asu_rec.person_id)    || '|'  ||
                                                v_asu_rec.as_course_cd          || '|'  ||
                                                TO_CHAR(v_asu_rec.as_version_number) || '|' ||
                                                v_asu_rec.unit_cd               || '|'  ||
                                                TO_CHAR(v_asu_rec.version_number) || '|' ||
                                                FND_DATE.DATE_TO_DISPLAYDATE(v_granted_dt);
                                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                v_s_log_type,
                                                v_creation_dt,
                                                v_message_key,
                                                v_message_name,
                                                '');
                                        v_skip_course_cd1 := v_asu_rec.as_course_cd;
                                        v_skip_version_number := v_asu_rec.as_version_number;
                                        GOTO continue;
                                END IF;
                        END IF;
                        -- Validate course version advanced standing internal/external limits
                        IF (IGS_AV_VAL_ASU.advp_val_as_totals(
                                        v_asu_rec.person_id,
                                        v_asu_rec.as_course_cd,
                                        v_asu_rec.as_version_number,
                                        TRUE,
                                        v_asu_rec.unit_cd,
                                        v_asu_rec.version_number,
                                        cst_granted,
                                        '', --  IGS_AV_STND_UNIT_LVL.unit_level
                                        '', --  IGS_AV_STND_UNIT_LVL.exemption_institution_cd
                                        '', --  IGS_AV_STND_UNIT_LVL.s_adv_stnd_granting_status
                                        v_total_exmptn_approved,
                                        v_total_exmptn_granted,
                                        v_total_exmptn_perc_grntd,
                                        v_message_name,
                                        v_asu_rec.unit_details_id,
                                        v_asu_rec.tst_rslt_dtls_id,
                                        v_asu_rec.exemption_institution_cd) = FALSE) THEN
                                -- Insert into messages for reporting
                                -- Do not process any more IGS_AV_STND_UNIT for this course
                                v_message_key := 'UNIT '                        || '|'  ||
                                                TO_CHAR(v_asu_rec.person_id)    || '|'  ||
                                                v_asu_rec.as_course_cd          || '|'  ||
                                                TO_CHAR(v_asu_rec.as_version_number) || '|' ||
                                                v_asu_rec.unit_cd               || '|'  ||
                                                TO_CHAR(v_asu_rec.version_number) || '|' ||
                                                FND_DATE.DATE_TO_DISPLAYDATE(v_granted_dt);
                                IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                        v_s_log_type,
                                        v_creation_dt,
                                        v_message_key,
                                        v_message_name,
                                        '');
                                v_skip_course_cd1 := v_asu_rec.as_course_cd;
                                v_skip_version_number := v_asu_rec.as_version_number;
                                GOTO continue;
                        END IF;
                        -- For each IGS_AV_STND_UNIT.unit_cd/version_number
                        -- Update student enrolment
                        IF ( v_asu_rec.s_adv_stnd_recognition_type = cst_credit AND
                             (v_asu_rec.achievable_credit_points > 0 )) THEN
                                v_message_name := NULL;
                                IF (advp_upd_sua_advstnd(
                                                v_asu_rec.person_id,
                                                v_asu_rec.as_course_cd,
                                                v_asu_rec.unit_cd,
                                                v_asu_rec.version_number,
                                                v_granted_dt,
                                                v_message_name) = FALSE) THEN
                                        -- Insert into messages for reporting
                                        -- Do not update IGS_AV_STND_UNIT
                                        v_message_key := 'UNIT '                        || '|'  ||
                                                        TO_CHAR(v_asu_rec.person_id)    || '|'  ||
                                                        v_asu_rec.as_course_cd          || '|'  ||
                                                        TO_CHAR(v_asu_rec.as_version_number) || '|' ||
                                                        v_asu_rec.unit_cd               || '|'  ||
                                                        TO_CHAR(v_asu_rec.version_number) || '|' ||
                                                        FND_DATE.DATE_TO_DISPLAYDATE(v_granted_dt);
                                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                v_s_log_type,
                                                v_creation_dt,
                                                v_message_key,
                                                v_message_name,
                                                '');
                                        --
                                        -- Next IF condition added as pe the bug# 2382566.
                                        --
                                        IF p_message_name NOT IN ('IGS_AV_HAS_UNIT_ATT') THEN
                                          v_update_flag := FALSE;
                                        ELSE
                                          v_update_flag := TRUE;
                                        END IF;
                                END IF;
                        END IF;

                        IF (v_update_flag = TRUE) THEN
                                -- Update IGS_AV_STND_UNIT
      -- *****************************************************************************************
      DECLARE
              /* Cursor to select rowid and all columns of the table */
        CURSOR Cur_IGS_AV_STND_UNIT IS
        SELECT  rowid, IGS_AV_STND_UNIT.*
        FROM IGS_AV_STND_UNIT
        WHERE   person_id       = p_person_id
        AND     as_course_cd    = v_asu_rec.as_course_cd
        AND     as_version_number = v_asu_rec.as_version_number
        AND     unit_cd         = v_asu_rec.unit_cd
        AND     version_number  = v_asu_rec.version_number;

        CURSOR cur_get_person_num IS
        SELECT party_number
        FROM hz_parties
        WHERE party_id = p_person_id;
        l_cur_get_person_num cur_get_person_num%ROWTYPE;
        l_message_name fnd_new_messages.message_name%TYPE;
        l_repeat_tag VARCHAR2(100);
      BEGIN
        FOR IGS_AV_STND_UNIT_rec in Cur_IGS_AV_STND_UNIT LOOP
                   /* For the column to be updated, modify the record variable value fetched */
                   IGS_AV_STND_UNIT_rec.granted_dt      := v_granted_dt;
                   IGS_AV_STND_UNIT_rec.s_adv_stnd_granting_status := cst_granted;
                   /* Call server side TBH package procedure */
             --
             --  To check the repeat logic. Added as per the Bug# 2382566.
             --  Start of new code.

	     --
	     -- sepalani 22-Mar-2006 Bug# 5104563 12A-M1R : INFO QUERY ON ADV STANDING GRANTING REPORT
	     -- "eval_unit_repeat" function returns true, if the unit is repeatable
	     --  it also returns true when the unit has "Repeat set to None" and For Reenroll
	     --

             IF eval_unit_repeat (
               p_person_id               =>  igs_av_stnd_unit_rec.person_id,
               p_load_cal_type           =>  igs_av_stnd_unit_rec.cal_type,
               p_load_cal_seq_number     =>  igs_av_stnd_unit_rec.ci_sequence_number,
               p_uoo_id                  =>  null,
               p_program_cd              =>  igs_av_stnd_unit_rec.as_course_cd,
               p_program_version         =>  igs_av_stnd_unit_rec.as_version_number,
               p_message                 =>  l_message_name,
               p_deny_warn               =>  'DENY',
               p_repeat_tag              =>  l_repeat_tag,
               p_unit_cd                 =>  igs_av_stnd_unit_rec.unit_cd,
               p_unit_version            =>  igs_av_stnd_unit_rec.version_number,
               p_calling_obj             =>  'JOB') = 'N' THEN

               OPEN cur_get_person_num;
               FETCH cur_get_person_num INTO l_cur_get_person_num;
               CLOSE cur_get_person_num;
               fnd_message.set_name( 'IGS', 'IGS_AV_REPEAT_FAIL');
               fnd_message.set_token('UNIT',igs_av_stnd_unit_rec.unit_cd);
               fnd_message.set_token('PERSON',l_cur_get_person_num.party_number);
               fnd_file.put_line(fnd_file.log,fnd_message.get());
               fnd_file.put_line(FND_FILE.LOG,' ');
                v_message_key := 'UNIT '                        || '|'  ||
                        TO_CHAR(v_asu_rec.person_id)    || '|'  ||
                        v_asu_rec.as_course_cd          || '|'  ||
                        TO_CHAR(v_asu_rec.as_version_number) || '|' ||
                        v_asu_rec.unit_cd               || '|'  ||
                        TO_CHAR(v_asu_rec.version_number) || '|' ||
                        FND_DATE.DATE_TO_DISPLAYDATE(v_granted_dt);
                IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                        v_s_log_type,
                        v_creation_dt,
                        v_message_key,
                        'IGS_AV_REPEAT_FAIL',
                        '');
             ELSE -- otherwise grant advanced standing.
             --
             --  End of new code which was added as per the Bug# 2382566.
             --
                    IGS_AV_STND_UNIT_PKG.Update_Row (
                    X_Rowid                                =>       IGS_AV_STND_UNIT_rec.rowid,
                    X_PERSON_ID                            =>       IGS_AV_STND_UNIT_rec.PERSON_ID,
                    X_AS_COURSE_CD                         =>       IGS_AV_STND_UNIT_rec.AS_COURSE_CD,
                    X_AS_VERSION_NUMBER                    =>       IGS_AV_STND_UNIT_rec.AS_VERSION_NUMBER,
                    X_S_ADV_STND_TYPE                      =>       IGS_AV_STND_UNIT_rec.S_ADV_STND_TYPE,
                    X_UNIT_CD                              =>       IGS_AV_STND_UNIT_rec.UNIT_CD,
                    X_VERSION_NUMBER                       =>       IGS_AV_STND_UNIT_rec.VERSION_NUMBER,
                    X_S_ADV_STND_GRANTING_STATUS           =>       IGS_AV_STND_UNIT_rec.S_ADV_STND_GRANTING_STATUS,
                    X_CREDIT_PERCENTAGE                    =>       NULL,
                    X_S_ADV_STND_RECOGNITION_TYPE          =>       IGS_AV_STND_UNIT_rec.S_ADV_STND_RECOGNITION_TYPE,
                    X_APPROVED_DT                          =>       IGS_AV_STND_UNIT_rec.APPROVED_DT,
                    X_AUTHORISING_PERSON_ID                =>       IGS_AV_STND_UNIT_rec.AUTHORISING_PERSON_ID,
                    X_CRS_GROUP_IND                        =>       IGS_AV_STND_UNIT_rec.CRS_GROUP_IND,
                    X_EXEMPTION_INSTITUTION_CD             =>       IGS_AV_STND_UNIT_rec.EXEMPTION_INSTITUTION_CD,
                    X_GRANTED_DT                           =>       IGS_AV_STND_UNIT_rec.granted_dt,
                    X_EXPIRY_DT                            =>       IGS_AV_STND_UNIT_rec.EXPIRY_DT,
                    X_CANCELLED_DT                         =>       IGS_AV_STND_UNIT_rec.CANCELLED_DT,
                    X_REVOKED_DT                           =>       IGS_AV_STND_UNIT_rec.REVOKED_DT,
                    X_COMMENTS                             =>       IGS_AV_STND_UNIT_rec.COMMENTS,
                    X_AV_STND_UNIT_ID                      =>       IGS_AV_STND_UNIT_rec.AV_STND_UNIT_ID,
                    X_CAL_TYPE                             =>       IGS_AV_STND_UNIT_rec.CAL_TYPE,
                    X_CI_SEQUENCE_NUMBER                   =>       IGS_AV_STND_UNIT_rec.CI_SEQUENCE_NUMBER,
                    X_INSTITUTION_CD                       =>       IGS_AV_STND_UNIT_rec.INSTITUTION_CD,
                    X_UNIT_DETAILS_ID                      =>       IGS_AV_STND_UNIT_rec.UNIT_DETAILS_ID,
                    X_TST_RSLT_DTLS_ID                     =>       IGS_AV_STND_UNIT_rec.TST_RSLT_DTLS_ID,
                    X_GRADING_SCHEMA_CD                    =>       IGS_AV_STND_UNIT_rec.GRADING_SCHEMA_CD,
                    X_GRD_SCH_VERSION_NUMBER               =>       IGS_AV_STND_UNIT_rec.GRD_SCH_VERSION_NUMBER,
                    X_GRADE                                =>       IGS_AV_STND_UNIT_rec.GRADE,
                    X_ACHIEVABLE_CREDIT_POINTS             =>       IGS_AV_STND_UNIT_rec.ACHIEVABLE_CREDIT_POINTS,
                    X_MODE                                 =>       'R');
             END IF;
        END LOOP;
      END;
         -- *****************************************************************************************
                                -- Set message key
                                v_message_key := 'UNIT '                        || '|'  ||
                                        TO_CHAR(v_asu_rec.person_id)    || '|'  ||
                                        v_asu_rec.as_course_cd          || '|'  ||
                                        TO_CHAR(v_asu_rec.as_version_number) || '|' ||
                                        v_asu_rec.unit_cd               || '|'  ||
                                        TO_CHAR(v_asu_rec.version_number) || '|' ||
                                        FND_DATE.DATE_TO_DISPLAYDATE(v_granted_dt);
                                -- Insert into messages for reporting

                                        fnd_message.set_name('IGS','IGS_AV_GRANTED');
                                        cst_granted_ge := fnd_message.get;

                                IF (v_message_name is NULL) THEN
                                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                v_s_log_type,
                                                v_creation_dt,
                                                v_message_key,
                                                '',
                                                cst_granted_ge);
                                ELSE
                                        -- Warning from advp_upd_sua_advstnd

                                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                v_s_log_type,
                                                v_creation_dt,
                                                v_message_key,
                                                v_message_name,
                                                cst_granted_ge);
                                        v_message_name := NULL;
                                END IF;
                        ELSE
                                v_update_flag := TRUE;
                        END IF;
                         p_message_name := NULL;
                END IF; -- p_process_type = cst_course
                <<continue>> -- simulate C continue statement
                NULL; -- just make the compiler happy
        END LOOP; -- process IGS_AV_STND_UNIT

        v_skip_course_cd := 'ISNULL';
        v_skip_course_cd1 := 'ISNULL';
        v_skip_version_number := 0;
        v_last_course_cd := 'ISNULL';
        v_last_version_number := 0;
        -- UPDATE APPROVED IGS_AV_STND_UNIT_LVL
        p_message_name := 'IGS_AV_UNITLVL_UPDANOTHER_PRC';

        FOR v_asul_rec IN c_asul(p_person_id) LOOP
                IF (p_process_type = cst_course AND
                                (v_asul_rec.as_course_cd <> p_course_cd OR
                                 v_asul_rec.as_version_number <> p_version_number)) OR
                   (v_asul_rec.as_course_cd = v_skip_course_cd) OR
                   (v_asul_rec.as_course_cd = v_skip_course_cd1 AND
                        v_asul_rec.as_version_number = v_skip_version_number)
                THEN
                        -- Do nothing, continue IGS_AV_STND_UNIT_LVL
                        NULL;
                ELSE
                        -- For each IGS_AV_STND_UNIT_LVL.as_course_cd
                        -- Validate that person/course is not excluded from advanced standing
                        IF (IGS_EN_VAL_ENCMB.enrp_val_excld_prsn(
                                        v_asul_rec.person_id,
                                        v_asul_rec.as_course_cd,
                                        v_granted_dt,
                                        v_message_name) = FALSE) THEN
                                -- Insert into messages for reporting
                                -- Do not process any more IGS_AV_STND_UNIT_LVL for this course
                                v_message_key := 'UNIT LEVEL'|| '|'     ||
                                                TO_CHAR(v_asul_rec.person_id)   || '|'  ||
                                                v_asul_rec.as_course_cd         || '|'  ||
                                                TO_CHAR(v_asul_rec.as_version_number) || '|' ||
                                                v_asul_rec.unit_level           || '|'  ||
                        v_asul_rec.crs_group_ind || '|' ||
                                                v_asul_rec.exemption_institution_cd     ||'|'   ||
                                                FND_DATE.DATE_TO_DISPLAYDATE(v_granted_dt);
                                IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                        v_s_log_type,
                                        v_creation_dt,
                                        v_message_key,
                                        v_message_name,
                                        '');
                                v_skip_course_cd := v_asul_rec.as_course_cd;
                                GOTO continue1;
                        END IF;
                        -- For each IGS_AV_STND_UNIT_LVL.as_course_cd/as_version_number
                        -- Validate advanced standing course version
                        IF (v_asul_rec.as_course_cd = v_last_course_cd AND
                             v_asul_rec.as_version_number = v_last_version_number) THEN
                                NULL; -- do nothing, continue IGS_AV_STND_UNIT
                        ELSE
                                v_last_course_cd := v_asul_rec.as_course_cd;
                                v_last_version_number :=   v_asul_rec.as_version_number;
                                IF (IGS_AV_VAL_ASU.advp_val_as_grant(
                                        v_asul_rec.person_id,
                                        v_asul_rec.as_course_cd,
                                        v_asul_rec.as_version_number,
                                        v_asul_rec.s_adv_stnd_granting_status,
                                        v_message_name) = FALSE) THEN
                                        -- Insert into messages for reporting
                                        -- Do not process any more IGS_AV_STND_UNIT_LVL for this course
                                        v_message_key := 'UNIT LEVEL'|| '|'     ||
                                                TO_CHAR(v_asul_rec.person_id)   || '|'  ||
                                                v_asul_rec.as_course_cd         || '|'  ||
                                                TO_CHAR(v_asul_rec.as_version_number) || '|' ||
                                                v_asul_rec.unit_level           || '|'  ||
                        v_asul_rec.crs_group_ind || '|' ||
                                                v_asul_rec.exemption_institution_cd     ||'|'   ||
                                                FND_DATE.DATE_TO_DISPLAYDATE(v_granted_dt);
                                        IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                                v_s_log_type,
                                                v_creation_dt,
                                                v_message_key,
                                                v_message_name,
                                                '');
                                        v_skip_course_cd1 := v_asul_rec.as_course_cd;
                                        v_skip_version_number := v_asul_rec.as_version_number;
                                        GOTO continue1;
                                END IF;
                        END IF;
                        -- Validate course version advanced standing limits
                        IF (IGS_AV_VAL_ASU.advp_val_as_totals(
                                        v_asul_rec.person_id,
                                        v_asul_rec.as_course_cd,
                                        v_asul_rec.as_version_number,
                                        TRUE,
                                        '', -- IGS_AV_STND_UNIT.unit_cd
                                        '', -- IGS_AV_STND_UNIT.version_number
                                        '', -- IGS_AV_STND_UNIT.s_adv_stnd_granting_status
                                        v_asul_rec.unit_level,
                                        v_asul_rec.exemption_institution_cd,
                                        cst_granted,
                                        v_total_exmptn_approved,
                                        v_total_exmptn_granted,
                                        v_total_exmptn_perc_grntd,
                                        v_message_name,
                                        v_asul_rec.unit_details_id,
                                        v_asul_rec.tst_rslt_dtls_id,
                                        NULL) = FALSE) THEN
                                -- Insert into messages for reporting
                                -- Do not process any more IGS_AV_STND_UNIT_LVL for this course
                                v_message_key := 'UNIT LEVEL'|| '|'     ||
                                                TO_CHAR(v_asul_rec.person_id)   || '|'  ||
                                                v_asul_rec.as_course_cd         || '|'  ||
                                                TO_CHAR(v_asul_rec.as_version_number) || '|' ||
                                                v_asul_rec.unit_level           || '|'  ||
                        v_asul_rec.crs_group_ind || '|' ||
                                                v_asul_rec.exemption_institution_cd     ||'|'   ||
                                                FND_DATE.DATE_TO_DISPLAYDATE(v_granted_dt);
                                IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                        v_s_log_type,
                                        v_creation_dt,
                                        v_message_key,
                                        v_message_name,
                                        '');
                                v_skip_course_cd1 := v_asul_rec.as_course_cd;
                                v_skip_version_number := v_asul_rec.as_version_number;
                                GOTO continue1;
                        END IF;
                        -- Update IGS_AV_STND_UNIT_LVL
      -- ********************************************************************************************
      DECLARE
              /* Cursor to select rowid and all columns of the table */
               CURSOR Cur_IGS_AV_STND_UNIT_lvl IS
                        SELECT  rowid, IGS_AV_STND_UNIT_lvl.*
                        FROM IGS_AV_STND_UNIT_lvl
                        WHERE   person_id       = p_person_id
                        AND     as_course_cd    =  v_asul_rec.as_course_cd
                        AND     as_version_number =  v_asul_rec.as_version_number
                        AND     unit_level      = v_asul_rec.unit_level
                        AND     crs_group_ind   = v_asul_rec.crs_group_ind
                        AND     exemption_institution_cd = v_asul_rec.exemption_institution_cd;
      BEGIN
               FOR IGS_AV_STND_UNIT_lvl_rec IN Cur_IGS_AV_STND_UNIT_LVL LOOP
                   /* For the column to be updated, modify the record variable value fetched */
                   IGS_AV_STND_UNIT_lvl_rec.granted_dt := v_granted_dt;
                   IGS_AV_STND_UNIT_lvl_rec.s_adv_stnd_granting_status := cst_granted;
                   /* Call server side TBH package procedure */
                   IGS_AV_STND_UNIT_LVL_PKG.update_row(
                   X_Rowid                        =>            IGS_AV_STND_UNIT_LVL_rec.rowid,
                   X_PERSON_ID                    =>            IGS_AV_STND_UNIT_LVL_rec.PERSON_ID                      ,
                   X_AS_COURSE_CD                 =>            IGS_AV_STND_UNIT_LVL_rec.AS_COURSE_CD                   ,
                   X_AS_VERSION_NUMBER            =>            IGS_AV_STND_UNIT_LVL_rec.AS_VERSION_NUMBER              ,
                   X_S_ADV_STND_TYPE              =>            IGS_AV_STND_UNIT_LVL_rec.S_ADV_STND_TYPE                ,
                   X_UNIT_LEVEL                   =>            IGS_AV_STND_UNIT_LVL_rec.UNIT_LEVEL                     ,
                   X_CRS_GROUP_IND                =>            IGS_AV_STND_UNIT_LVL_rec.CRS_GROUP_IND                  ,
                   X_EXEMPTION_INSTITUTION_CD     =>            IGS_AV_STND_UNIT_LVL_rec.EXEMPTION_INSTITUTION_CD       ,
                   X_S_ADV_STND_GRANTING_STATUS   =>            IGS_AV_STND_UNIT_LVL_rec.S_ADV_STND_GRANTING_STATUS     ,
                   X_CREDIT_POINTS                =>            IGS_AV_STND_UNIT_LVL_rec.CREDIT_POINTS                  ,
                   X_APPROVED_DT                  =>            IGS_AV_STND_UNIT_LVL_rec.APPROVED_DT                    ,
                   X_AUTHORISING_PERSON_ID        =>            IGS_AV_STND_UNIT_LVL_rec.AUTHORISING_PERSON_ID          ,
                   X_GRANTED_DT                   =>            IGS_AV_STND_UNIT_LVL_rec.GRANTED_DT                     ,
                   X_EXPIRY_DT                    =>            IGS_AV_STND_UNIT_LVL_rec.EXPIRY_DT                      ,
                   X_CANCELLED_DT                 =>            IGS_AV_STND_UNIT_LVL_rec.CANCELLED_DT                   ,
                   X_REVOKED_DT                   =>            IGS_AV_STND_UNIT_LVL_rec.REVOKED_DT                     ,
                   X_COMMENTS                     =>            IGS_AV_STND_UNIT_LVL_rec.COMMENTS                       ,
                   X_AV_STND_UNIT_LVL_ID          =>            IGS_AV_STND_UNIT_LVL_rec.AV_STND_UNIT_LVL_ID            ,
                   X_CAL_TYPE                     =>            IGS_AV_STND_UNIT_LVL_rec.CAL_TYPE                       ,
                   X_CI_SEQUENCE_NUMBER           =>            IGS_AV_STND_UNIT_LVL_rec.CI_SEQUENCE_NUMBER             ,
                   X_INSTITUTION_CD               =>            IGS_AV_STND_UNIT_LVL_rec.INSTITUTION_CD                 ,
                   X_UNIT_DETAILS_ID              =>            IGS_AV_STND_UNIT_LVL_rec.UNIT_DETAILS_ID                   ,
                   X_TST_RSLT_DTLS_ID             =>            IGS_AV_STND_UNIT_LVL_rec.TST_RSLT_DTLS_ID                ,
                   X_MODE                         =>            'R'                                                     ,
                   X_QUAL_DETS_ID                 =>            IGS_AV_STND_UNIT_LVL_rec.QUAL_DETS_ID           -- Added column to tbh call w.r.t to ARCR032 (Bug# 2233334)
                   );
                END LOOP;
      END;
      -- *****************************************************************************************
                        -- Insert into messages for reporting
                        v_message_key := 'UNIT LEVEL'|| '|'     ||
                                TO_CHAR(v_asul_rec.person_id)   || '|'  ||
                                v_asul_rec.as_course_cd         || '|'  ||
                                TO_CHAR(v_asul_rec.as_version_number) || '|' ||
                                v_asul_rec.unit_level           || '|'  ||
                v_asul_rec.crs_group_ind || '|' ||
                                v_asul_rec.exemption_institution_cd     ||'|'   ||
                                FND_DATE.DATE_TO_DISPLAYDATE(v_granted_dt);
                                        fnd_message.set_name('IGS','IGS_AV_GRANTED');
                                        cst_granted_ge := fnd_message.get;
                IGS_GE_GEN_003.GENP_INS_LOG_ENTRY(
                                v_s_log_type,
                                v_creation_dt,
                                v_message_key,
                                '',
                                cst_granted_ge);
                END IF;
                <<continue1>> -- simulate C continue statement
                NULL; -- just make the compiler happy
        END LOOP; -- process IGS_AV_STND_UNIT_LVL
        COMMIT;
         p_message_name := NULL;
        RETURN TRUE;
  END;
EXCEPTION
        WHEN OTHERS THEN
            Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
            Fnd_Message.Set_Token('NAME','IGS_AV_GEN_001.ADVP_UPD_AS_PE_GRANT');
            Igs_Ge_Msg_Stack.Add;

            lv_param_values := To_Char(p_person_id)||p_course_cd||To_Char(p_version_number)||
                               FND_DATE.DATE_TO_DISPLAYDATE(p_granted_dt)||p_process_type||p_s_log_type||
                               FND_DATE.DATE_TO_DISPLAYDATE(p_creation_dt);
            Fnd_Message.Set_Name('IGS','IGS_GE_PARAMETERS');
            Fnd_Message.Set_Token('VALUE',lv_param_values);
            Igs_Ge_Msg_Stack.Add;

       App_Exception.Raise_Exception;
END advp_upd_as_pe_grant;

FUNCTION advp_upd_as_totals(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_exemption_institution_cd IN VARCHAR2)
RETURN BOOLEAN IS
lv_param_values VARCHAR2(1080);
BEGIN
  DECLARE
        CURSOR c_adv_stnd_details (
                        cp_person_id      IGS_AV_STND_UNIT.person_id%TYPE,
                        cp_course_cd      IGS_AV_STND_UNIT.as_course_cd%TYPE,
                        cp_version_number IGS_AV_STND_UNIT.as_version_number%TYPE
                                ) IS
                SELECT  rowid , adv.*
                FROM    IGS_AV_ADV_STANDING adv
                WHERE   adv.person_id           = cp_person_id AND
                        adv.course_cd           = cp_course_cd AND
                        adv.version_number      = cp_version_number AND
                        adv.exemption_institution_cd = p_exemption_institution_cd;
                --NEXT LINE COMMENTED OUT NOCOPY TO FIX BUG# 1618537.
                --FOR UPDATE NOWAIT;
        v_other_detail                  VARCHAR2(255);
        v_total_exmptn_approved         NUMBER;
        v_total_exmptn_granted          NUMBER;
        v_total_exmptn_perc_grntd       NUMBER;
        v_message_name                  VARCHAR2(30);
        v_adv_stnd_recs_found           BOOLEAN;
  BEGIN
        -- This function validates that the advanced standing
        -- approved/granted has not exceeded the advanced
        -- standing limits of the course version.  It then
        -- updates the advanced standing exemption totals.

        -- validate the input parameters
        IF (p_person_id IS NULL                 OR
                        p_course_cd IS NULL     OR
                        p_version_number IS NULL) THEN
                p_message_name := 'IGS_AV_INSUFFICIENT_INFO_VER';
                RETURN FALSE;
        END IF;
        -- get advanced standing exemption totals
        IF (IGS_AV_VAL_ASU.advp_val_as_totals (
                                p_person_id,
                                p_course_cd,
                                p_version_number,
                                TRUE,
                                '', -- IGS_AV_STND_UNIT.unit_cd
                                '', -- IGS_AV_STND_UNIT.version_number
                                                '', -- IGS_AV_STND_UNIT.s_adv_stnd_granting_status
                                '', -- IGS_AV_STND_UNIT_LVL.unit_level
                                p_exemption_institution_cd, -- IGS_AV_STND_UNIT_LVL.exemption_institution_cd
                                '', -- IGS_AV_STND_UNIT_LVL.s_adv_stnd_granting_status
                                v_total_exmptn_approved,
                                v_total_exmptn_granted,
                                v_total_exmptn_perc_grntd,
                                p_message_name,
                                null,
                                null,
                                p_exemption_institution_cd) = FALSE) THEN
                RETURN FALSE;
        END IF;
        -- set that no records have yet been found
        v_adv_stnd_recs_found := FALSE;
        -- setting the message number beforehand
        -- so if failure of the lock occurs, this
        -- value can be passed to the exception handler
         p_message_name := 'IGS_AV_UNABLE_UPD_TOTALS';
        -- select IGS_AV_STND_UNIT for parameters to determine
        -- existing totals

        FOR v_adv_stnd IN c_adv_stnd_details(p_person_id,
                                             p_course_cd,
                                             p_version_number
                                             ) LOOP
            -- set that a record has been found
            v_adv_stnd_recs_found := TRUE;
            -- ****************************************************************************************
            IGS_AV_ADV_STANDING_PKG.Update_Row(
            X_Rowid                      =>   v_adv_stnd.rowid,
            X_PERSON_ID                  =>   v_adv_stnd.person_id,
            X_COURSE_CD                  =>   v_adv_stnd.course_cd,
            X_VERSION_NUMBER             =>   v_adv_stnd.version_number ,
            X_TOTAL_EXMPTN_APPROVED      =>   v_total_exmptn_approved,
            X_TOTAL_EXMPTN_GRANTED       =>   v_total_exmptn_granted ,
            X_TOTAL_EXMPTN_PERC_GRNTD    =>   NVL(v_total_exmptn_perc_grntd,0) ,
            X_EXEMPTION_INSTITUTION_CD   =>   v_adv_stnd.EXEMPTION_INSTITUTION_CD ,
            X_MODE                       =>   'R');
           -- ***************************************************************************************
        END LOOP;
        -- set the default message number and return type
         p_message_name := NULL;
         RETURN TRUE;
  END;
END advp_upd_as_totals;

FUNCTION upd_sua_advstnd(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_granted_dt IN DATE ,
 p_message_name OUT NOCOPY VARCHAR2)
RETURN VARCHAR2 IS
BEGIN

    IF(advp_upd_sua_advstnd(
	  p_person_id  ,
	  p_course_cd  ,
	  p_unit_cd  ,
	  p_version_number  ,
	  p_granted_dt ,
	 p_message_name )) THEN
    RETURN 'Y';
    ELSE
    RETURN 'N';
    END IF;

END upd_sua_advstnd ;
FUNCTION advp_upd_sua_advstnd(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_granted_dt IN DATE ,
 p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN IS
BEGIN
  DECLARE
        cst_unconfirm           CONSTANT VARCHAR2(10) := 'UNCONFIRM';
        cst_enrolled            CONSTANT VARCHAR2(10) := 'ENROLLED';
        cst_invalid             CONSTANT VARCHAR2(10) := 'INVALID';
        cst_discontin           CONSTANT VARCHAR2(10) := 'DISCONTIN';
        cst_completed           CONSTANT VARCHAR2(10) := 'COMPLETED';
        cst_duplicate           CONSTANT VARCHAR2(10) := 'DUPLICATE';
        cst_fail                CONSTANT VARCHAR2(10) := 'FAIL';
        cst_incomp              CONSTANT VARCHAR2(10) := 'INCOMP';
        CURSOR gc_sua_rec (
                        cp_person_id      IGS_EN_SU_ATTEMPT.person_id%TYPE,
                        cp_course_cd      IGS_EN_SU_ATTEMPT.course_cd%TYPE,
                        cp_unit_cd        IGS_EN_SU_ATTEMPT.unit_cd%TYPE,
                        cp_version_number IGS_EN_SU_ATTEMPT.version_number%TYPE) IS
                SELECT  sua.unit_attempt_status,
                        sua.cal_type,
                        sua.ci_sequence_number,
                        sua.ci_start_dt,
                        sua.enrolled_dt,
                        uv.repeatable_ind,
            sua.uoo_id
                FROM    IGS_EN_SU_ATTEMPT sua,
                        IGS_PS_UNIT_VER uv
                WHERE   sua.person_id           = cp_person_id AND
                        sua.course_cd           = cp_course_cd AND
                        sua.unit_cd             = cp_unit_cd   AND
                        sua.version_number      = cp_version_number  AND
                        uv.unit_cd              = sua.unit_cd AND
                        uv.version_number       = sua.version_number
                FOR UPDATE NOWAIT
                ORDER BY DECODE(sua.unit_attempt_status,
                        'DISCONTIN',1,
                        'UNCONFIRM',2,
                        'INVALID',3,
                        'COMPLETED',4,
                        'ENROLLED',5);

        CURSOR gc_sub_sua_rec (
                        cp_person_id      IGS_EN_SU_ATTEMPT.person_id%TYPE,
                        cp_course_cd      IGS_EN_SU_ATTEMPT.course_cd%TYPE,
                        cp_sup_unit_cd    IGS_EN_SU_ATTEMPT.sup_unit_cd%TYPE,
                        cp_sup_vers_num   IGS_EN_SU_ATTEMPT.sup_version_number%TYPE) IS
                SELECT  *
                FROM    IGS_EN_SU_ATTEMPT sub_sua
                WHERE   sub_sua.person_id               = cp_person_id AND
                        sub_sua.course_cd               = cp_course_cd AND
                        sub_sua.sup_unit_cd             = cp_sup_unit_cd   AND
                        sub_sua.sup_version_number      = cp_sup_vers_num
                FOR UPDATE NOWAIT;

        CURSOR gc_daiv(
                        cp_cal_type     IGS_CA_INST.cal_type%TYPE,
                        cp_ci_seq_num   IGS_CA_INST.sequence_number%TYPE) IS
                SELECT  daiv.alias_val
                FROM    IGS_CA_DA_INST_V daiv,
                        IGS_GE_S_GEN_CAL_CON sgcc
                WHERE   daiv.cal_type           = cp_cal_type and
                        daiv.ci_sequence_number = cp_ci_seq_num and
                        daiv.dt_alias           = sgcc.census_dt_alias and
                        sgcc.s_control_num      = 1
                ORDER BY
                        daiv.alias_val DESC;

    CURSOR cur_get_person_num IS
    SELECT party_number
    FROM hz_parties
    WHERE party_id = p_person_id;
    l_cur_get_person_num cur_get_person_num%ROWTYPE;

        gv_other_detail                 VARCHAR2(255);
        gv_s_result_type                VARCHAR2(10);
        v_sua_rec_found                 BOOLEAN;
        v_sub_sua_recs_found            BOOLEAN;
        gv_grading_schema_cd            IGS_AS_GRD_SCH_GRADE.grading_schema_cd%TYPE;
        gv_gs_version_number            IGS_AS_GRD_SCH_GRADE.version_number%TYPE;
        gv_grade                        IGS_AS_GRD_SCH_GRADE.grade%TYPE;
        gv_administrative_unit_status   IGS_EN_SU_ATTEMPT.administrative_unit_status%TYPE;
        gv_unit_cd                      IGS_EN_SU_ATTEMPT.unit_cd%TYPE;
        gv_version_number               IGS_EN_SU_ATTEMPT.version_number%TYPE;
        gv_cal_type                     IGS_EN_SU_ATTEMPT.cal_type%TYPE;
        gv_ci_sequence_number           IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE;
        gv_ci_start_dt                  IGS_EN_SU_ATTEMPT.ci_start_dt%TYPE;
        gv_enrolled_dt                  IGS_EN_SU_ATTEMPT.enrolled_dt%TYPE;
        gv_unit_attempt_status          IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE;
        gv_repeatable_ind               IGS_PS_UNIT_VER.repeatable_ind%TYPE;
        gv_census_dt                    IGS_CA_DA_INST_V.alias_val%TYPE;
        gv_message_num                  VARCHAR2(30);
        gv_message_num2                 VARCHAR2(30);
        gv_sub_unit                     BOOLEAN;
    gv_uoo_id   IGS_EN_SU_ATTEMPT.uoo_id%TYPE;

        FUNCTION enrpl_delete_sua_recs (
                        p_del_person_id         IN      IGS_EN_SU_ATTEMPT.person_id%TYPE,
                        p_del_course_cd         IN      IGS_EN_SU_ATTEMPT.course_cd%TYPE,
                        p_del_granted_dt        IN      DATE,
                        p_del_unit_cd           IN      IGS_EN_SU_ATTEMPT.unit_cd%TYPE,
                        p_del_vers_num          IN      IGS_EN_SU_ATTEMPT.version_number%TYPE,
                        p_del_cal_type          IN      IGS_EN_SU_ATTEMPT.cal_type%TYPE,
                        p_del_ci_seq_num        IN      IGS_EN_SU_ATTEMPT.ci_sequence_number%TYPE,
                        p_del_ci_start_dt       IN      IGS_EN_SU_ATTEMPT.ci_start_dt%TYPE,
                        p_del_enrolled_dt       IN      IGS_EN_SU_ATTEMPT.enrolled_dt%TYPE,
                        p_del_unit_atmpt_status IN      IGS_EN_SU_ATTEMPT.unit_attempt_status%TYPE,
                        p_del_sub_unit          IN      BOOLEAN,
                        p_del_message_num       OUT NOCOPY      NUMBER,
            p_del_uoo_id IN     IGS_EN_SU_ATTEMPT.uoo_id%TYPE)
        RETURN BOOLEAN IS
        BEGIN
        DECLARE
                v_other_detail                  VARCHAR2(255);
                v_administrative_unit_status    IGS_EN_SU_ATTEMPT.administrative_unit_status%TYPE;
                v_message_name                  VARCHAR2(30);
                v_alias_val                     IGS_CA_DA_INST_V.alias_val%TYPE;
                v_admin_unit_status_str         VARCHAR2(2000);
        BEGIN
                -- this module will delete student_unit_attempts
                -- (will need to return TRUE or FALSE)
                -- this determines if a IGS_EN_SU_ATTEMPT
                -- can be deleted because advanced standing is
                -- granted prior to the advanced standing cut-off date
                IF (IGS_AV_VAL_ASU.advp_get_ua_del_alwd (
                                p_del_cal_type,
                                p_del_ci_seq_num,
                                p_del_granted_dt) = TRUE) THEN
                        -- delete the record
              --Deleting functionality has been removed as per the Acedemic record maintenance build. Bug no-1960126
                        -- checking the value of p_del_sub_unit
                        IF (p_del_sub_unit) THEN -- is TRUE
                                p_del_message_num := 2050;
                        ELSE -- is FALSE
                                p_del_message_num := 2049;
                        END IF;
                        -- exit this sub function, and return TRUE
                        RETURN TRUE;
                ELSE -- advp_get_ua_del_alwd = FALSE
                        -- determine if IGS_EN_SU_ATTEMPT can be
                        -- deleted because of UNIT discontinuation date
                        -- criteria

                        IF (IGS_EN_GEN_008.enrp_get_ua_del_alwd (
                                        p_del_cal_type,
                                        p_del_ci_seq_num,
                                        p_del_granted_dt,
                    p_del_uoo_id) = 'Y') THEN
                                -- cheking the value of p_del_sub_unit
                                IF (p_del_sub_unit) THEN -- is TRUE
                                        p_del_message_num :=  2050;
                                ELSE -- is FALSE
                                        p_del_message_num := 2049;
                                END IF;
                                -- exit this sub function, and return TRUE
                                RETURN TRUE;
                        ELSE -- enrp_get_ua_del_alwd returned N
                                -- discontinue IGS_EN_SU_ATTEMPT
                                -- get administrative UNIT status associated
                                -- with disocntinuation v_administrative_unit_status

                                v_administrative_unit_status := (IGS_EN_GEN_008.enrp_get_uddc_aus(
                                                                        p_del_granted_dt,
                                                                        p_del_cal_type,
                                                                        p_del_ci_seq_num,
                                                                        v_admin_unit_status_str,
                                                                        v_alias_val,
                                    p_del_uoo_id));
                                IF (v_administrative_unit_status IS NULL) THEN
                                        IF (p_del_sub_unit) THEN  -- is TRUE
                                                p_del_message_num := 1980;
                                        ELSE -- is FALSE
                                                p_del_message_num := 1979;
                                        END IF;
                                        -- exit this sub function, and return FALSE
                                        RETURN FALSE;
                                END IF;
                                -- validate discontinuation
                                IF (IGS_EN_VAL_SUA.enrp_val_sua_discont(
                                                        p_del_person_id,
                                                        p_del_course_cd,
                                                        p_del_unit_cd,
                                                        p_del_vers_num,
                                                        p_del_ci_start_dt,
                                                        p_del_enrolled_dt,
                                                        v_administrative_unit_status,
                                                        p_del_unit_atmpt_status,
                                                        p_del_granted_dt,
                                                        v_message_name ,
                            'N' ) = FALSE) THEN
                                        -- checking the value of p_del_sub_unit
                                        IF (p_del_sub_unit) THEN -- is TRUE
                                                p_del_message_num := 1797;
                                        ELSE -- is FALSE
                                                p_del_message_num := 1808;
                                        END IF;
                                        -- exit this sub function, and return FALSE
                                        RETURN FALSE;
                                ELSE -- enrp_val_sua_discont returned TRUE
                                        -- checking the value of p_del_sub_unit
                                        IF (p_del_sub_unit) THEN -- is TRUE
                                                p_del_message_num := 1811;
                                        ELSE -- is FALSE
                                                p_del_message_num := 1812;
                                        END IF;
                                        -- exit this sub function, and return TRUE
                                        RETURN TRUE;
                                END IF;
                        END IF;
                END IF;
        EXCEPTION
          WHEN OTHERS THEN
           Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
           Fnd_Message.Set_Token('NAME','IGS_AV_GEN_001.ENRPL_DELETE_SUA_RECS');
           Igs_Ge_Msg_Stack.Add;
           App_Exception.Raise_Exception;
        END;
        END enrpl_delete_sua_recs;
BEGIN
        -- This function updates a student's enrolment
        -- when an advanced standing UNIT is granted
        -- set the default message number
         p_message_name := NULL;
        -- validate the input parameters
        IF (p_person_id IS NULL                  OR
                        p_course_cd IS NULL      OR
                        p_unit_cd IS NULL        OR
                        p_version_number IS NULL OR
                        p_granted_dt IS NULL) THEN
                p_message_name := 'IGS_AV_MAPADV_SUA_CANNOT_DTRM';
                RETURN FALSE;
        END IF;
        -- set that no IGS_EN_SU_ATTEMPT
        -- records haven't been found yet
        v_sua_rec_found := FALSE;
        -- setting the message number beforehand
        -- so if failure of the lock occurs, this
        -- value can be passed to the exception handler
        p_message_name := 'IGS_AV_UNABLE_UPD_ENRDET';
        -- Establish a savepoint
        SAVEPOINT sp_discontinue_sua;
        -- update IGS_EN_SU_ATTEMPT
        FOR gv_sua_rec IN gc_sua_rec (p_person_id,
                                    p_course_cd,
                                    p_unit_cd,
                                    p_version_number) LOOP

                -- set that a record was found
                v_sua_rec_found := TRUE;

              --Deleting functionality has been removed as per the Acedemic record maintenance build. Bug no-1960126

                -- IGS_EN_SU_ATTEMPT is deleted/discontined if enrolled
                IF (gv_sua_rec.unit_attempt_status = cst_enrolled) THEN
                     IF gv_sua_rec.repeatable_ind <> 'X' THEN
                        -- Do not delete student UNIT attempt if UNIT is repeatable
                         p_message_name := 'IGS_AV_CURENR_REPEATABLE_UNIT';
                     ELSE
                        -- setting the values
                        gv_unit_cd := p_unit_cd;
                        gv_version_number := p_version_number;
                        gv_cal_type := gv_sua_rec.cal_type;
                        gv_ci_sequence_number := gv_sua_rec.ci_sequence_number;
                        gv_ci_start_dt := gv_sua_rec.ci_start_dt;
                        gv_enrolled_dt := gv_sua_rec.enrolled_dt;
                        gv_unit_attempt_status := gv_sua_rec.unit_attempt_status;
                        gv_sub_unit := FALSE;
            gv_uoo_id := gv_sua_rec.uoo_id;
                        -- deleting/discontinue IGS_EN_SU_ATTEMPT
                        IF (enrpl_delete_sua_recs(
                                        p_person_id,
                                        p_course_cd,
                                        p_granted_dt,
                                        gv_unit_cd,
                                        gv_version_number,
                                        gv_cal_type,
                                        gv_ci_sequence_number,
                                        gv_ci_start_dt,
                                        gv_enrolled_dt,
                                        gv_unit_attempt_status,
                                        gv_sub_unit,
                                        gv_message_num,
                    gv_uoo_id) = FALSE) THEN
                                -- Rollback any changes to student_unit_attempts
                                ROLLBACK to sp_discontinue_sua;
                                p_message_name := gv_message_num;
                                RETURN FALSE;
                        ELSE  -- returns true
                                --p_message_num := gv_message_num;
                                -- setting another message number
                                -- so if no subordinate records are
                                -- found, it won't return the message
                                -- number for locking problems, but
                                -- the message number returned from
                                -- the called routine
                                gv_message_num2 := gv_message_num;
                        END IF;
                        -- set that no subordinate records
                        -- were found
                        v_sub_sua_recs_found := FALSE;
                        -- setting the message number beforehand
                        -- so if failure of the lock occurs, this
                        -- value can be passed to the exception handler
                        p_message_name := 'IGS_AV_ANOTHERPRC_UPDATING';
                        -- delete/discontinue sub-ordinate student_unit_attempts
                        -- if they exist
                        FOR gv_sub_sua_rec IN gc_sub_sua_rec(
                                                p_person_id,
                                                p_course_cd,
                                                p_unit_cd,
                                                p_version_number) LOOP
                                -- set that subordinate records were found
                                v_sub_sua_recs_found := TRUE;
                                -- setting the values
                                gv_unit_cd := gv_sub_sua_rec.unit_cd;
                                gv_version_number := gv_sub_sua_rec.version_number;
                                gv_cal_type := gv_sub_sua_rec.cal_type;
                                gv_ci_sequence_number := gv_sub_sua_rec.ci_sequence_number;
                                gv_ci_start_dt := gv_sub_sua_rec.ci_start_dt;
                                gv_enrolled_dt := gv_sub_sua_rec.enrolled_dt;
                                gv_unit_attempt_status := gv_sub_sua_rec.unit_attempt_status;
                                gv_sub_unit := TRUE;
                gv_uoo_id := gv_sub_sua_rec.uoo_id;
                                -- deleting/discontinue IGS_EN_SU_ATTEMPT
                                IF (enrpl_delete_sua_recs(
                                                p_person_id,
                                                p_course_cd,
                                                p_granted_dt,
                                                gv_unit_cd,
                                                gv_version_number,
                                                gv_cal_type,
                                                gv_ci_sequence_number,
                                                gv_ci_start_dt,
                                                gv_enrolled_dt,
                                                gv_unit_attempt_status,
                                                gv_sub_unit,
                                                gv_message_num,
                        gv_uoo_id) = FALSE) THEN
                                        -- Rollback any changes to student_unit_attempts
                                        ROLLBACK to sp_discontinue_sua;
                                        p_message_name := gv_message_num;
                                        RETURN FALSE;
                                ELSE -- returned true
                                        p_message_name := gv_message_num;
                                END IF;
                        END LOOP;
                        -- set that no subordinate records were found
                        IF (v_sub_sua_recs_found = FALSE) THEN
                                -- set the message number that was
                                -- returned from the called function
                                -- if this isn't done, and no records
                                -- are found, the message number returned
                                -- would be 1813 (which isn't what we want -
                                -- as no locking problems occurred).
                                p_message_name := gv_message_num2;
                        END IF;
                      END IF;
                END IF;

                -- IGS_EN_SU_ATTEMPT is not altered if invalid, return error
                -- to indiate that the advanced standing should not be granted
                IF (gv_sua_rec.unit_attempt_status = cst_invalid) THEN
                        -- Rollback any changes to student_unit_attempts
                        ROLLBACK to sp_discontinue_sua;
                        p_message_name := 'IGS_AV_CANNOTBE_GRANT_EXISTS';
                        RETURN FALSE;
                END IF;

                IF (gv_sua_rec.unit_attempt_status IN ( cst_enrolled,
                                                        cst_completed,
                                                        cst_invalid)) THEN
                        --
                        -- Added as per the bug# 2382566
                        -- Catch Enrolled, Completed and Invalid and just warn the user that the student has an Unit Attempt with this status.
                        -- Start of new code.
                         OPEN cur_get_person_num;
                         FETCH cur_get_person_num INTO l_cur_get_person_num;
                         CLOSE cur_get_person_num;

                         p_message_name := 'IGS_AV_HAS_UNIT_ATT';
                         fnd_message.set_name('IGS',p_message_name);
                         fnd_message.set_token('PERSON',l_cur_get_person_num.party_number);
                         fnd_message.set_token('UNIT',p_unit_cd);
                         fnd_file.put_line(fnd_file.log,fnd_message.get());
                         fnd_file.put_line(FND_FILE.LOG,' ');
                         -- End of new code. Added as per the bug# 2382566.
                ELSIF (gv_sua_rec.unit_attempt_status NOT IN (cst_duplicate)) THEN
                         p_message_name := NULL;
                END IF;
        END LOOP;
        -- checking whether IGS_EN_SU_ATTEMPT
        -- records were found
        IF (v_sua_rec_found = FALSE) THEN
                 p_message_name := NULL;
                RETURN TRUE;
        END IF;
        -- set the default return type
        RETURN TRUE;
EXCEPTION
        WHEN OTHERS THEN
            Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
            Fnd_Message.Set_Token('NAME','IGS_AV_GEN_001.ADVP_UPD_SUA_ADVSTND');
            Igs_Ge_Msg_Stack.Add;
            App_Exception.Raise_Exception;
END;
END advp_upd_sua_advstnd;

PROCEDURE advp_upd_as_pe_expry(errbuf  OUT NOCOPY VARCHAR2,
                                 retcode OUT NOCOPY NUMBER,
                                 p_org_id IN   NUMBER  ) AS
 BEGIN           -- advp_upd_as_pe_expire
                 --This procedure expires approved advanced standing for a person

                -- To set org_id as in request of job.
                -- This is added to fix Bug no# 1159910.
                IGS_GE_GEN_003.set_org_id(p_org_id);


                DECLARE
                  lv_count                      NUMBER:=0;
                  e_resource_busy               EXCEPTION;
                  PRAGMA EXCEPTION_INIT (e_resource_busy, -54);

                CURSOR c_person IS
                SELECT  person_id
                FROM    IGS_AV_STND_UNIT_ALL
                WHERE   s_adv_stnd_granting_status = 'APPROVED' AND
                NVL(expiry_dt, IGS_GE_DATE.IGSDATE('9999/01/01')) < SYSDATE
                UNION
                SELECT  person_id
                FROM    IGS_AV_STND_UNIT_LVL_ALL
                WHERE   s_adv_stnd_granting_status = 'APPROVED' AND
                NVL(expiry_dt, IGS_GE_DATE.IGSDATE('9999/01/01')) < SYSDATE;

                CURSOR  c_adv_stnd_unit (cp_person_id   IGS_PE_PERSON.person_id%TYPE) IS
                SELECT  rowid , IGS_AV_STND_UNIT.*
                FROM    igs_av_stnd_unit
                WHERE s_adv_stnd_granting_status = 'APPROVED' AND
                      NVL(expiry_dt, IGS_GE_DATE.IGSDATE('9999/01/01')) < SYSDATE AND
                      person_id = cp_person_id AND
                      s_adv_stnd_recognition_type <> 'PRECLUSION' /* Added as per Bug# 2441175 */
                ORDER BY
                        person_id,
                        as_course_cd,
                        as_version_number
                FOR UPDATE OF s_adv_stnd_granting_status NOWAIT;

                CURSOR c_adv_stnd_unit_level (cp_person_id      IGS_PE_PERSON.person_id%TYPE) IS
                SELECT  rowid,IGS_AV_STND_UNIT_LVL.*
                FROM    IGS_AV_STND_UNIT_LVL
                WHERE s_adv_stnd_granting_status = 'APPROVED'   AND
                NVL(expiry_dt, IGS_GE_DATE.IGSDATE('9999/01/01')) < SYSDATE     AND
                person_id       = cp_person_id
                ORDER BY
                        person_id,
                        as_course_cd,
                        as_version_number
                FOR UPDATE OF s_adv_stnd_granting_status NOWAIT;
BEGIN
        errbuf:=NULL;
        FOR v_person_rec IN c_person LOOP
    BEGIN
       RETCODE:=0;
        BEGIN
            FOR v_asu_rec IN c_adv_stnd_unit(v_person_rec.person_id) LOOP

            -- ******************************************************************************************
                IGS_AV_STND_UNIT_PKG.update_row(
                X_Rowid                                 =>              v_asu_rec.rowid                          ,
                X_PERSON_ID                             =>              v_asu_rec.PERSON_ID                      ,
                X_AS_COURSE_CD                          =>              v_asu_rec.AS_COURSE_CD                   ,
                X_AS_VERSION_NUMBER                     =>              v_asu_rec.AS_VERSION_NUMBER              ,
                X_S_ADV_STND_TYPE                       =>              v_asu_rec.S_ADV_STND_TYPE                ,
                X_UNIT_CD                               =>              v_asu_rec.UNIT_CD                        ,
                X_VERSION_NUMBER                        =>              v_asu_rec.VERSION_NUMBER                 ,
                X_S_ADV_STND_GRANTING_STATUS            =>              'EXPIRED'                                ,
               /* X_CREDIT_PERCENTAGE                     =>              v_asu_rec.CREDIT_PERCENTAGE              , */
                X_S_ADV_STND_RECOGNITION_TYPE           =>              v_asu_rec.S_ADV_STND_RECOGNITION_TYPE    ,
                X_APPROVED_DT                           =>              v_asu_rec.APPROVED_DT                    ,
                X_AUTHORISING_PERSON_ID                 =>              v_asu_rec.AUTHORISING_PERSON_ID          ,
                X_CRS_GROUP_IND                         =>              v_asu_rec.CRS_GROUP_IND                  ,
                X_EXEMPTION_INSTITUTION_CD              =>              v_asu_rec.EXEMPTION_INSTITUTION_CD       ,
                X_GRANTED_DT                            =>              v_asu_rec.GRANTED_DT                     ,
                X_EXPIRY_DT                             =>              v_asu_rec.EXPIRY_DT                      ,
                X_CANCELLED_DT                          =>              v_asu_rec.CANCELLED_DT                   ,
                X_REVOKED_DT                            =>              v_asu_rec.REVOKED_DT                     ,
                X_COMMENTS                              =>              v_asu_rec.COMMENTS                       ,
                X_AV_STND_UNIT_ID                       =>              v_asu_rec.AV_STND_UNIT_ID                ,
                X_CAL_TYPE                              =>              v_asu_rec.CAL_TYPE                       ,
                X_CI_SEQUENCE_NUMBER                    =>              v_asu_rec.CI_SEQUENCE_NUMBER             ,
                X_INSTITUTION_CD                        =>              v_asu_rec.INSTITUTION_CD                 ,
                X_UNIT_DETAILS_ID                       =>              v_asu_rec.UNIT_DETAILS_ID                ,
                X_TST_RSLT_DTLS_ID                      =>              v_asu_rec.TST_RSLT_DTLS_ID               ,
                X_GRADING_SCHEMA_CD                     =>              v_asu_rec.GRADING_SCHEMA_CD              ,
                X_GRD_SCH_VERSION_NUMBER                =>              v_asu_rec.GRD_SCH_VERSION_NUMBER         ,
                X_GRADE                                 =>              v_asu_rec.GRADE                          ,
                X_ACHIEVABLE_CREDIT_POINTS              =>              v_asu_rec.ACHIEVABLE_CREDIT_POINTS       ,
                X_MODE                                  =>              'R');
            -- *****************************************************************************************

            END LOOP;
        EXCEPTION
                WHEN e_resource_busy THEN

                        IF (c_adv_stnd_unit%ISOPEN) THEN
                                CLOSE c_adv_stnd_unit;
                        END IF;
                FND_FILE.PUT_LINE(FND_FILE.LOG, TO_CHAR(v_person_rec.person_id) || '  '||
                                                                                              FND_MESSAGE.GET_STRING('IGS',
                                                                                             'IGS_AV_UNABLE_EXP_UNIT_UPD'));
                RAISE;
                WHEN OTHERS THEN
                        RAISE;
              END;
        BEGIN
                FOR v_asul_rec IN c_adv_stnd_unit_level(v_person_rec.person_id) LOOP
                -- ****************************************************************************************

                   IGS_AV_STND_UNIT_LVL_PKG.update_row(
                   X_Rowid                                =>    v_asul_rec.rowid                                        ,
                   X_PERSON_ID                            =>    v_asul_rec.PERSON_ID                                    ,
                   X_AS_COURSE_CD                         =>    v_asul_rec.AS_COURSE_CD                                 ,
                   X_AS_VERSION_NUMBER                    =>    v_asul_rec.AS_VERSION_NUMBER                            ,
                   X_S_ADV_STND_TYPE                      =>    v_asul_rec.S_ADV_STND_TYPE                              ,
                   X_UNIT_LEVEL                           =>    v_asul_rec.UNIT_LEVEL                                   ,
                   X_CRS_GROUP_IND                        =>    v_asul_rec.CRS_GROUP_IND                                ,
                   X_EXEMPTION_INSTITUTION_CD             =>    v_asul_rec.EXEMPTION_INSTITUTION_CD                     ,
                   X_S_ADV_STND_GRANTING_STATUS           =>    'EXPIRED'                                               ,
                   X_CREDIT_POINTS                        =>     v_asul_rec.CREDIT_POINTS                               ,
                   X_APPROVED_DT                          =>     v_asul_rec.APPROVED_DT                                 ,
                   X_AUTHORISING_PERSON_ID                =>     v_asul_rec.AUTHORISING_PERSON_ID                       ,
                   X_GRANTED_DT                           =>     v_asul_rec.GRANTED_DT                                  ,
                   X_EXPIRY_DT                            =>     v_asul_rec.EXPIRY_DT                                   ,
                   X_CANCELLED_DT                         =>     v_asul_rec.CANCELLED_DT                                ,
                   X_REVOKED_DT                           =>     v_asul_rec.REVOKED_DT                                  ,
                   X_COMMENTS                             =>     v_asul_rec.COMMENTS                                    ,
                   X_AV_STND_UNIT_LVL_ID                  =>     v_asul_rec.AV_STND_UNIT_LVL_ID                         ,
                   X_CAL_TYPE                             =>     v_asul_rec.CAL_TYPE                                    ,
                   X_CI_SEQUENCE_NUMBER                   =>     v_asul_rec.CI_SEQUENCE_NUMBER                          ,
                   X_INSTITUTION_CD                       =>     v_asul_rec.INSTITUTION_CD                              ,
                   X_UNIT_DETAILS_ID                      =>     v_asul_rec.UNIT_DETAILS_ID                                ,
                   X_TST_RSLT_DTLS_ID                     =>     v_asul_rec.TST_RSLT_DTLS_ID                             ,
                   X_MODE                                 =>     'R'                                                    ,
                   X_QUAL_DETS_ID                         =>     v_asul_rec.QUAL_DETS_ID  -- Added column to tbh call w.r.t to ARCR032 (Bug# 2233334)
                   );
                -- ***************************************************************************************
                END LOOP;
        EXCEPTION
          WHEN e_resource_busy THEN
            IF (c_adv_stnd_unit_level%ISOPEN) THEN
              CLOSE c_adv_stnd_unit_level;
            END IF;
            FND_FILE.PUT_LINE(FND_FILE.LOG, TO_CHAR(v_person_rec.person_id) || '  '||
            FND_MESSAGE.GET_STRING('IGS','IGS_AV_LVL_UPD_ANOTHER_PRC'));
            RAISE;
          WHEN OTHERS THEN
            RAISE;
        END;
    EXCEPTION
      WHEN e_resource_busy  THEN
        RETCODE:=2;
    END;
    IF RETCODE='0' THEN
      lv_count:=lv_count+1;
    END IF;
  END LOOP;     --End of Person Id Loop
  errbuf:=FND_MESSAGE.GET_STRING('IGS', 'IGS_GE_TOTAL_REC_PROCESSED')||  '  ' ||to_char(lv_count) ;
  retcode:=0;
  EXCEPTION
    WHEN OTHERS THEN
    ERRBUF:= FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
    retcode:=2;
    IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
    END;
  END advp_upd_as_pe_expry;
 PROCEDURE advp_create_basis(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER )  IS
 CURSOR C_AV_UNT is
  select AV_STND_UNIT_ID  from IGS_AV_STND_UNIT_ALL unt where
  person_id =p_person_id  and
  as_course_cd = p_course_cd and
  as_version_number = p_version_number and
  not exists ( select 1 from IGS_AV_STD_UNT_BASIS_ALL basis where  basis.AV_STND_UNIT_ID= unt.AV_STND_UNIT_ID) ;

 CURSOR C_AV_UNT_LVL is
  select AV_STND_UNIT_LVL_ID  from IGS_AV_STND_UNIT_LVL_ALL ulvl where
  person_id =p_person_id  and
  as_course_cd = p_course_cd and
  as_version_number = p_version_number and
   not exists ( select 1 from IGS_AV_STD_ULVLBASIS_ALL basis where  basis.AV_STND_UNIT_LVL_ID= ulvl.AV_STND_UNIT_LVL_ID) ;

 lv_rowid VARCHAR2(25);

 BEGIN


  FOR V_AV_UNT IN C_AV_UNT LOOP
    Igs_Av_Std_Unt_Basis_Pkg.Insert_Row (
      X_Mode                              => 'R',
      X_RowId                             =>  lv_rowid,
      X_Av_Stnd_Unit_Id                   => V_AV_UNT.AV_STND_UNIT_ID,
      X_Basis_Course_Type                 => null,
      X_Basis_Year                        => null,
      X_Basis_Completion_Ind              => null
      ,X_ORG_ID         => FND_PROFILE.VALUE('ORG_ID')
    );
     lv_rowid :=null;
  END LOOP;

  FOR V_AV_UNT IN C_AV_UNT_LVL LOOP
    Igs_Av_Std_Ulvlbasis_Pkg.Insert_Row (
      X_Mode                              => 'R',
      X_RowId                             => lv_rowid  ,
      X_Av_Stnd_Unit_Lvl_Id                   => V_AV_UNT.AV_STND_UNIT_LVL_ID,
      X_Basis_Course_Type                 => null,
      X_Basis_Year                        => null,
      X_Basis_Completion_Ind              => null
      ,X_ORG_ID         => FND_PROFILE.VALUE('ORG_ID')
    );
     lv_rowid :=null;
  END LOOP;
  commit;

 END advp_create_basis;
  FUNCTION advp_val_basis_year(
  p_basis_year IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN VARCHAR2 IS
    gv_other_detail   VARCHAR2(255);
  BEGIN -- advp_val_basis_year
    -- validate the basis year
  DECLARE
    v_qualification_recency IGS_PS_VER.qualification_recency%TYPE;
    CURSOR c_qualification_recency IS
      SELECT  qualification_recency
      FROM  IGS_PS_VER
      WHERE   course_cd = p_course_cd AND
        version_number = p_version_number;
  BEGIN
     p_message_name := null;
    -- Validate input parameter
    IF (p_basis_year IS NULL OR
      p_course_cd IS NULL OR
      p_version_number IS NULL) THEN
      RETURN 'Y';
    END IF;
    -- Validate that basis_year is not greater than the current year.(E)
    IF (p_basis_year > TO_NUMBER(SUBSTR(IGS_GE_DATE.IGSCHAR(SYSDATE),1,4))) THEN
      p_message_name := 'IGS_AV_LYENR_NOTGT_CURYR';
      p_return_type := 'E';
      RETURN 'Y';
    END IF;
    -- Validate that basis_yr is not outside the recency for the IGS_PS_COURSE version (W)
    OPEN c_qualification_recency;
    FETCH c_qualification_recency INTO v_qualification_recency;
    IF (c_qualification_recency%NOTFOUND) THEN
      CLOSE c_qualification_recency;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c_qualification_recency;
        IF (p_basis_year <
      TO_NUMBER(SUBSTR(IGS_GE_DATE.IGSCHAR(SYSDATE),1,4)) - v_qualification_recency) THEN
        p_message_name := 'IGS_AV_LRENR_OUTSIDE_QUALIFY';
        p_return_type := 'W';
        RETURN 'Y';
      END IF;
    RETURN 'Y';
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AV_VAL_ASULEB.ADVP_VAL_BASIS_YEAR');
      App_Exception.Raise_Exception;
      IGS_GE_MSG_STACK.ADD;
    END;
  END advp_val_basis_year;

FUNCTION eval_unit_repeat (
    p_person_id                    IN     NUMBER,
    p_load_cal_type                IN     VARCHAR2,
    p_load_cal_seq_number          IN     NUMBER,
    p_uoo_id                       IN     NUMBER,
    p_program_cd                   IN     VARCHAR2,
    p_program_version              IN     NUMBER,
    p_message                      IN OUT NOCOPY VARCHAR2,
    p_deny_warn                    IN     VARCHAR2,
    p_repeat_tag                   OUT NOCOPY    VARCHAR2 ,
    p_unit_cd                      IN     VARCHAR2  ,
    p_unit_version                 IN     NUMBER,
	  p_calling_obj									 IN VARCHAR2
  ) RETURN VARCHAR2 AS

    -- sepalani 22-Mar-2006 Bug# 5104563
    --
    --  Cursor to select all the Unit Attempts of the Student.
    --
    CURSOR cur_student_attempts (
         cp_unit_cd   igs_ps_unit_ver.unit_cd%TYPE,
         cp_version_number igs_ps_unit_ver.version_number%TYPE
       ) IS
    SELECT  'X'
    FROM     igs_en_su_attempt
    WHERE    person_id = p_person_id
    AND     ((unit_attempt_status IN ('ENROLLED', 'DISCONTIN','COMPLETED','INVALID','UNCONFIRM'))
          OR (unit_attempt_status = 'WAITLISTED' AND FND_PROFILE.VALUE('IGS_EN_VAL_WLST')  ='Y'))
    AND      (unit_cd, version_number) IN
    (SELECT   unit_cd,
          version_number
         FROM     igs_ps_unit_ver
         WHERE   (unit_cd = cp_unit_cd AND version_number = cp_version_number)
         OR       rpt_fmly_id =
    		( SELECT   psu.rpt_fmly_id
    		      FROM igs_ps_unit_ver psu,
    			   igs_ps_rpt_fmly rep
    		      WHERE psu.unit_cd                 = cp_unit_cd
    		      AND   psu.version_number          = cp_version_number
    		      AND   psu.rpt_fmly_id             = rep.rpt_fmly_id
    		      AND   NVL(rep.closed_ind,'N')     = 'N' ));
    --
    -- Cursor to find if the unit version is repeatable
    --
    CURSOR  cur_unit_repeat_for_cp(cp_unit_cd   igs_ps_unit_ver.unit_cd%TYPE,
             cp_version_number igs_ps_unit_ver.version_number%TYPE)  IS
      SELECT  repeatable_ind
      FROM  igs_ps_unit_ver
      WHERE  unit_cd = cp_unit_cd
      AND  version_number = cp_version_number;

	-- sepalani 22-Mar-2006 Bug# 5104563
    v_student_attempts CHAR := 'Y';
    l_unit_repeat BOOLEAN := FALSE;
    v_repeatable_ind CHAR := 'Y';

BEGIN

  --
  -- sepalani 22-Mar-2006 Bug# 5104563
  -- "eval_unit_repeat" function returns true, if the unit is repeatable
  --  it also returns true when the unit has "Repeat set to None" and For Reenroll
  --

    l_unit_repeat := igs_en_elgbl_unit.eval_unit_repeat (
                       p_person_id               =>  p_person_id           ,
                       p_load_cal_type           =>  p_load_cal_type       ,
                       p_load_cal_seq_number     =>  p_load_cal_seq_number ,
                       p_uoo_id                  =>  p_uoo_id              ,
                       p_program_cd              =>  p_program_cd          ,
                       p_program_version         =>  p_program_version     ,
                       p_message                 =>  p_message             ,
                       p_deny_warn               =>  p_deny_warn           ,
                       p_repeat_tag              =>  p_repeat_tag          ,
                       p_unit_cd                 =>  p_unit_cd             ,
                       p_unit_version            =>  p_unit_version         ,
                        p_calling_obj	         =>  p_calling_obj);

    --
    -- open the cursor to find the status of repeatable ind for a given unit and version of the unit.
    -- Logic
    -- v_repeatable_ind = 'X' --> Repeat set to None (Not Allowed)
    -- v_repeatable_ind = 'Y' --> Reenroll Allowed
    -- v_repeatable_ind = 'Y' --> Repeat Allowed

    OPEN cur_unit_repeat_for_cp(p_unit_cd,p_unit_version);
    FETCH cur_unit_repeat_for_cp into v_repeatable_ind;
    CLOSE cur_unit_repeat_for_cp;

    --
    -- open the cursor to find out whether the student has units enrolled
    -- for a given unit and version of the unit.
    --

    OPEN cur_student_attempts(p_unit_cd,p_unit_version);
    FETCH cur_student_attempts into v_student_attempts;
    CLOSE cur_student_attempts;

    --
    -- Check if the unit is repeatable
    --   or
    -- if the student has "Repeat not Allowed" and enrolled the same course.
    -- if the above evaluates to true then throw exception.
    -- otherwise grant advanced standing
    --

    IF l_unit_repeat = FALSE OR
            (l_unit_repeat = TRUE AND v_repeatable_ind = 'X' AND v_student_attempts = 'X') THEN
     RETURN 'N';
    ELSE
     RETURN 'Y';
    END IF;

  RETURN 'Y';
  EXCEPTION
    WHEN OTHERS THEN
      Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AV_VAL_ASULEB.eval_unit_repeat');
      App_Exception.Raise_Exception;
      IGS_GE_MSG_STACK.ADD;
END eval_unit_repeat;

 PROCEDURE advp_updt_advstnd(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ) IS

   CURSOR c_adv_stnd
   IS
      SELECT *
        FROM igs_av_adv_standing_all
       WHERE person_id = p_person_id
         AND course_cd = p_course_cd
         AND version_number = p_version_number;

   l_app_val          NUMBER;
   l_grnt_val         NUMBER;

   CURSOR c_approved (
      p_exemption_institution_cd   igs_av_stnd_unit_all.exemption_institution_cd%TYPE
   )
   IS
      SELECT nvl(SUM (cp) , 0)
        FROM (SELECT SUM (achievable_credit_points) cp
                FROM igs_av_stnd_unit_all unt
               WHERE unt.exemption_institution_cd = p_exemption_institution_cd
                 AND unt.person_id = p_person_id
                 AND p_course_cd = unt.as_course_cd
                 AND p_version_number = unt.as_version_number
                 AND unt.s_adv_stnd_granting_status = 'APPROVED'
              UNION ALL
              SELECT SUM (credit_points) cp
                FROM igs_av_stnd_unit_lvl_all unt
               WHERE unt.exemption_institution_cd = p_exemption_institution_cd
                 AND unt.person_id = p_person_id
                 AND p_course_cd = unt.as_course_cd
                 AND p_version_number = unt.as_version_number
                 AND unt.s_adv_stnd_granting_status = 'APPROVED');

   CURSOR c_granted (
      p_exemption_institution_cd   igs_av_stnd_unit_all.exemption_institution_cd%TYPE
   )
   IS
      SELECT nvl(SUM (cp),0)
        FROM (SELECT SUM (achievable_credit_points) cp
                FROM igs_av_stnd_unit_all unt
               WHERE unt.exemption_institution_cd = p_exemption_institution_cd
                 AND unt.person_id = p_person_id
                 AND p_course_cd = unt.as_course_cd
                 AND p_version_number = unt.as_version_number
                 AND unt.s_adv_stnd_granting_status = 'GRANTED'
              UNION ALL
              SELECT SUM (credit_points) cp
                FROM igs_av_stnd_unit_lvl_all unt
               WHERE unt.exemption_institution_cd = p_exemption_institution_cd
                 AND unt.person_id = p_person_id
                 AND p_course_cd = unt.as_course_cd
                 AND p_version_number = unt.as_version_number
                 AND unt.s_adv_stnd_granting_status = 'GRANTED');
BEGIN
   FOR l_adv_stnd IN c_adv_stnd
   LOOP
      l_app_val := 0;
      l_grnt_val := 0;

      OPEN c_approved (l_adv_stnd.exemption_institution_cd);

      FETCH c_approved
       INTO l_app_val;

      CLOSE c_approved;

      OPEN c_granted (l_adv_stnd.exemption_institution_cd);

      FETCH c_granted
       INTO l_grnt_val;

      CLOSE c_granted;

      UPDATE igs_av_adv_standing_all
         SET total_exmptn_approved = l_app_val,
             total_exmptn_granted = l_grnt_val
       WHERE person_id = p_person_id
         AND course_cd = p_course_cd
         AND version_number = p_version_number
         AND exemption_institution_cd = l_adv_stnd.exemption_institution_cd;
   END LOOP;
EXCEPTION
   WHEN OTHERS
   THEN
      Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AV_VAL_ASULEB.advp_updt_advstnd'  || sqlerrm);
      App_Exception.Raise_Exception;
      IGS_GE_MSG_STACK.ADD;

 END advp_updt_advstnd;


PROCEDURE adv_cal_creditpts (
   p_personid    IN              NUMBER,
   p_coursecd    IN              VARCHAR2,
   p_unitsetcd   IN              VARCHAR2,
   p_usverno     IN              VARCHAR2,
   creditpts     OUT NOCOPY      NUMBER
)
IS
   v_credit_pts_1   NUMBER (10, 5);
   v_credit_pts_2   NUMBER (10, 5);
   v_credit_pts_3   NUMBER (10, 5);



   CURSOR c_credit_pts_1 (
      personid    NUMBER,
      coursecd    VARCHAR2,
      unitsetcd   VARCHAR2,
      usverno     VARCHAR2
   )
   IS
      SELECT SUM
                (igs_as_calc_award_mark.get_earned_cp (he.person_id,
                                                       he.course_cd,
                                                       he.unit_cd,
                                                       he.version_number,
                                                       he.unit_attempt_status,
                                                       he.cal_type,
                                                       he.ci_sequence_number,
                                                       he.uoo_id,
                                                       NULL,
                                                       NULL
                                                      )
                )
        FROM igs_en_sua_year_v he
       WHERE he.person_id = personid
         AND he.course_cd = coursecd
         AND he.unit_set_cd = unitsetcd
         AND he.us_version_number = usverno;

   CURSOR c_credit_pts_2 (
      personid    NUMBER,
      coursecd    VARCHAR2,
      unitsetcd   VARCHAR2,
      usverno     VARCHAR2
   )
   IS
      SELECT SUM (a.achievable_credit_points)
        FROM igs_av_stnd_unit_all a, igs_pe_hz_parties ipz
       WHERE a.s_adv_stnd_granting_status = 'GRANTED'
         AND a.s_adv_stnd_recognition_type = 'CREDIT'
         AND a.exemption_institution_cd(+) = ipz.oss_org_unit_cd
         AND (a.cal_type, a.ci_sequence_number) IN (
                SELECT ca.load_cal_type, ca.load_ci_sequence_number
                  FROM igs_en_sua_year_v susa, igs_ca_teach_to_load_v ca
                 WHERE susa.person_id = a.person_id
                   AND susa.course_cd = a.as_course_cd
                   AND susa.cal_type = ca.teach_cal_type
                   AND susa.ci_sequence_number = ca.teach_ci_sequence_number
                   AND susa.unit_set_cd = unitsetcd
                   AND susa.us_version_number = usverno)
         AND ((personid = person_id) AND (coursecd = as_course_cd));

   CURSOR c_credit_pts_3 (personid NUMBER, coursecd VARCHAR2)
   IS
      SELECT SUM (a.credit_points)
        FROM igs_av_stnd_unit_lvl_all a, igs_pe_hz_parties ipz
       WHERE a.s_adv_stnd_granting_status = 'GRANTED'
         AND a.exemption_institution_cd(+) = ipz.oss_org_unit_cd
         AND (personid = person_id)
         AND (coursecd = as_course_cd);
BEGIN
   creditpts :=0;

   begin
   OPEN c_credit_pts_1 (p_personid, p_coursecd, p_unitsetcd, p_usverno);

   FETCH c_credit_pts_1
    INTO v_credit_pts_1;

   CLOSE c_credit_pts_1;
   end;

   begin
   OPEN c_credit_pts_2 (p_personid, p_coursecd, p_unitsetcd, p_usverno);

   FETCH c_credit_pts_2
    INTO v_credit_pts_2;

   CLOSE c_credit_pts_2;
   end;

   begin
   OPEN c_credit_pts_3 (p_personid, p_coursecd);

   FETCH c_credit_pts_3
    INTO v_credit_pts_3;

   CLOSE c_credit_pts_3;
   end;
   creditpts := nvl(v_credit_pts_1,0) + nvl(v_credit_pts_2,0) + nvl(v_credit_pts_3,0);
END adv_cal_creditpts;



END IGS_AV_GEN_001;

/
