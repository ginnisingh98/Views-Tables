--------------------------------------------------------
--  DDL for Package Body IGF_AP_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_GEN_001" AS
   /* $Header: IGFAP44B.pls 120.1 2005/11/07 01:53:12 appldev ship $ */

  --Function to get Program Attempt Start Date
  FUNCTION get_prog_att_start_dt(cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE)
  RETURN DATE
  AS
  /*
  ||  Created By : rasahoo
  ||  Created On : 26-AUG-2003
  ||  Purpose    : Function to get Program Attempt Start Date
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  sjalasut       Dec 03, 2003     modified the cursor c_comm_date with the new
  ||                                  procedure that gets the key program based on the
  ||                                  award year. this key program will be used in calculating
  ||                                  the course commencement date
  */
   CURSOR c_comm_date(cp_person_id hz_parties.party_id%TYPE, cp_course_cd igs_ps_ver_all.course_cd%TYPE,
                      cp_version_number igs_ps_ver_all.version_number%TYPE)IS
   SELECT commencement_dt
     FROM igs_en_stdnt_ps_att_all
    WHERE course_cd = cp_course_cd
      AND version_number = cp_version_number
      AND person_id = cp_person_id;
   l_comm_date   c_comm_date%ROWTYPE;
   l_person_id   hz_parties.party_id%TYPE;
   x_course_cd igs_ps_ver_all.course_cd%TYPE;
   x_version_number igs_ps_ver_all.version_number%TYPE;
  BEGIN
    -- call igf_gr_gen.get_person_id to get the Person ID for the Base ID
    l_person_id :=igf_gr_gen.get_person_id(cp_base_id);
    -- get the key program from the get_key_program api
    get_key_program(cp_base_id, x_course_cd, x_version_number);
    -- get the course commencement date from the spa table. this date can be null !!!
    OPEN c_comm_date(l_person_id, x_course_cd, x_version_number);
    FETCH c_comm_date INTO l_comm_date;
    CLOSE c_comm_date;
    RETURN l_comm_date.commencement_dt;
  EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
  END get_prog_att_start_dt;


  --Function for Anticipated Completion Date
  FUNCTION get_anticip_compl_date(cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE)
  RETURN DATE
  AS
  /*
  ||  Created By : rasahoo
  ||  Created On : 26-AUG-2003
  ||  Purpose    : Function for Anticipated Completion Date
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
     -- Get the details of the Key Program
     CURSOR key_program_dtl_cur(cp_person_id hz_parties.party_id%TYPE, cp_course_cd igs_ps_ver_all.course_cd%TYPE,
                      cp_version_number igs_ps_ver_all.version_number%TYPE) IS
     SELECT course_cd, version_number, cal_type, location_cd, attendance_mode, attendance_type
       FROM igs_en_stdnt_ps_att_all
      WHERE course_cd = cp_course_cd
        AND version_number = cp_version_number
        AND person_id = cp_person_id;

      l_key_program    key_program_dtl_cur%ROWTYPE;

      -- Get the calendar details passing the values obtained from above query
      CURSOR adm_appl_cur(cp_person_id             igs_ad_appl.person_id%TYPE,
                          cp_course_cd             igs_ad_ps_appl_inst.course_cd%TYPE,
                          cp_crv_version_number    igs_ad_ps_appl_inst.crv_version_number%TYPE ,
                          cp_location_cd           igs_ad_ps_appl_inst.location_cd%TYPE,
                          cp_attendance_mode       igs_ad_ps_appl_inst.attendance_mode%TYPE,
                          cp_attendance_type       igs_ad_ps_appl_inst.attendance_type%TYPE )
          IS
      SELECT adm.acad_cal_type, adm.adm_cal_type adm_cal_type, adm.adm_ci_sequence_number adm_ci_sequence_number,
             acai.expected_completion_yr,acai.expected_completion_perd
        FROM igs_ad_appl   adm, igs_ad_ps_appl_inst  acai
       WHERE adm.person_id             = acai.person_id
         AND adm.admission_appl_number = acai.admission_appl_number
         AND adm.person_id             = cp_PERSON_ID
         AND acai.course_cd            = cp_COURSE_CD
         AND acai.crv_version_number   = cp_CRV_VERSION_NUMBER
         AND acai.location_cd          = cp_LOCATION_CD
         AND acai.attendance_mode      = cp_ATTENDANCE_MODE
         AND acai.attendance_type      = cp_ATTENDANCE_TYPE;
       l_adm_appl                  adm_appl_cur%ROWTYPE;
       l_person_id                 VARCHAR2(20);
       lv_course_start_dt          DATE;
       l_completion_dt             DATE;
       cp_term_enr_dtl_rec         igs_en_spa_terms%ROWTYPE;
       x_course_cd                 igs_ps_ver_all.course_cd%TYPE;
       x_version_number            igs_ps_ver_all.version_number%TYPE;

    CURSOR c_spa( cp_person_id        hz_parties.party_id%TYPE,
		  cp_course_cd        igs_en_stdnt_ps_att.course_cd%TYPE,
		  cp_version_number   igs_en_stdnt_ps_att.version_number%TYPE
		)IS
    SELECT commencement_dt
      FROM igs_en_stdnt_ps_att
     WHERE person_id      = cp_person_id
       AND COURSE_CD      = cp_course_cd
       AND VERSION_NUMBER = cp_version_number;



  BEGIN
    -- Call IGF_GR_GEN.GET_PERSON_ID to get the Person ID for the Base ID
    l_person_id :=igf_gr_gen.get_person_id(cp_base_id);

    -- get the key program from the get_key_program api
    get_key_program(cp_base_id, x_course_cd, x_version_number);

    OPEN key_program_dtl_cur(l_person_id,x_course_cd, x_version_number);
    FETCH key_program_dtl_cur INTO l_key_program; CLOSE key_program_dtl_cur;

    OPEN adm_appl_cur(l_person_id ,l_key_program.course_cd,l_key_program.version_number,l_key_program.location_cd,
                      l_key_program.attendance_mode,l_key_program.attendance_type);
    FETCH adm_appl_cur INTO l_adm_appl;
    CLOSE adm_appl_cur;

    OPEN c_spa (l_person_id, x_course_cd, x_version_number);
    FETCH c_spa INTO lv_course_start_dt;
    CLOSE c_spa;

    -- If there is no enrollment rec for the student use Admissions data to get the start date.
    IF lv_course_start_dt IS NULL THEN -- Enrollment Start Date Check
      lv_course_start_dt := igs_ad_gen_005.admp_get_crv_strt_dt(l_adm_appl.adm_cal_type, l_adm_appl.adm_ci_sequence_number);
    END IF; -- End Enrollment Start Date Check
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN -- Log Level Check
      FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_ap_gen_001.get_anticip_compl_date.debug',
       '| start date                            ' ||   to_char(lv_course_start_dt, 'mm/dd/yyyy')||
       '| l_person_id                           ' ||   l_person_id                         ||
       '| x_course_cd                           ' ||   x_course_cd                         ||
       '| l_key_program.course_cd               ' ||   l_key_program.course_cd             ||
       '| l_key_program.version_number          ' ||   l_key_program.version_number        ||
       '| acad_cal_type                         ' ||   l_adm_appl.acad_cal_type            ||
       '| l_key_program.cal_type                ' ||   l_key_program.cal_type              ||
       '| l_key_program.attendance_type         ' ||   l_key_program.attendance_type       ||
       '| lv_course_start_dt                    ' ||   lv_course_start_dt                  ||
       '| l_adm_appl.expected_completion_yr     ' ||   l_adm_appl.expected_completion_yr   ||
       '| l_adm_appl.expected_completion_perd   ' ||   l_adm_appl.expected_completion_perd ||
       '| l_completion_dt                       ' ||   l_completion_dt                     ||
       '| l_key_program.attendance_mode         ' ||   l_key_program.attendance_mode       ||
       '| l_key_program.location_cd             ' ||   l_key_program.location_cd           ||
       '| l_key_program.attendance_type -       ' ||   l_key_program.attendance_type
       );
    END IF; -- End Log Level Check


    igs_ad_gen_004.admp_get_crv_comp_dt(l_key_program.course_cd,
                                        l_key_program.version_number,
                                        NVL(l_key_program.cal_type, l_adm_appl.acad_cal_type),
                                        l_key_program.attendance_type,
                                        lv_course_start_dt,
                                        l_adm_appl.expected_completion_yr,
                                        l_adm_appl.expected_completion_perd,
                                        l_completion_dt,
                                        l_key_program.attendance_mode,
                                        l_key_program.location_cd
                                       );
    RETURN l_completion_dt;
  EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
  END get_anticip_compl_date;


  --Function to get Class Standing
  FUNCTION get_class_standing(cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE)
  RETURN VARCHAR2
  AS
  /*
  ||  Created By : rasahoo
  ||  Created On : 26-AUG-2003
  ||  Purpose    : Function to get Class Standing
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  l_person_id hz_parties.party_id%TYPE;
  lv_class_standing igs_pr_class_std.class_standing%TYPE;
  x_key_program_course_cd igs_ps_ver_all.course_cd%TYPE;
  x_version_number igs_ps_ver_all.version_number%TYPE;
  BEGIN
    l_person_id :=igf_gr_gen.get_person_id(cp_base_id);
    -- get the key program from the get_key_program api
    get_key_program(cp_base_id, x_key_program_course_cd, x_version_number);
    lv_class_standing := igs_pr_get_class_std.get_class_standing(l_person_id,
                                                                 x_key_program_course_cd,
                                                                 'N',
                                                                 NULL,
                                                                 NULL,
                                                                 NULL);
      RETURN lv_class_standing;
   EXCEPTION WHEN OTHERS THEN
      RETURN NULL;
  END get_class_standing;

  --Function to get Program Type
  FUNCTION get_enrl_program_type(cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE)
  RETURN VARCHAR2
  AS
  /*
  ||  Created By : rasahoo
  ||  Created On : 26-AUG-2003
  ||  Purpose    : Function to get Program Type
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    --  Get the Program Type
   CURSOR Program_Type_Cur(cp_course_cd      VARCHAR2,
                            cp_version_number NUMBER)IS
   SELECT course_type enrl_program_type
     FROM igs_ps_ver
    WHERE course_cd = cp_course_cd
      AND version_number = cp_version_number;
     l_Program_Type Program_Type_Cur%ROWTYPE;
     l_person_id hz_parties.party_id%TYPE;
   x_key_program_course_cd igs_ps_ver_all.course_cd%TYPE;
   x_version_number igs_ps_ver_all.version_number%TYPE;
  BEGIN
    l_person_id :=igf_gr_gen.get_person_id(cp_base_id);
    -- get the key program from the get_key_program api
    get_key_program(cp_base_id, x_key_program_course_cd, x_version_number);
    --  Get the Program Type
    OPEN Program_Type_Cur(x_key_program_course_cd,x_version_number);
    FETCH Program_Type_Cur INTO l_Program_Type;
    CLOSE Program_Type_Cur;
    RETURN l_Program_Type.enrl_program_type;
  EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
  END get_enrl_program_type;

  --Function to get Key Program
  PROCEDURE get_key_program(cp_base_id        IN igf_ap_fa_base_rec_all.base_id%TYPE,
                            cp_course_cd      OUT NOCOPY VARCHAR2,
                            cp_version_number OUT NOCOPY NUMBER)AS
  /*
  ||  Created By : rasahoo
  ||  Created On : 26-AUG-2003
  ||  Purpose    : Function to get Key Program
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  sjalasut       Dec 03, 2003    removed the cursor key_program_cur
  ||                                 and replaced with the get_term_enrlmnt_dtl to get the
  ||                                 key program
  */
    cp_term_enr_dtl_rec igs_en_spa_terms%ROWTYPE;
  BEGIN
    -- call get_term_enrlmnt_dtl so that based on the base_id it calculates the term and
    -- gets the key program from that term (if any) otherwise returns the key program from the spa
    get_term_enrlmnt_dtl(cp_base_id,cp_term_enr_dtl_rec);
    cp_course_cd      := cp_term_enr_dtl_rec.program_cd;
    cp_version_number := cp_term_enr_dtl_rec.program_version;
  EXCEPTION WHEN OTHERS THEN
    cp_course_cd      := NULL;
    cp_version_number := NULL;
  END get_key_program;

  --Procedure to get the applicable enrollment term details.
  PROCEDURE get_term_enrlmnt_dtl(cp_fa_base_id IN IGF_AP_FA_BASE_REC_ALL.BASE_ID%TYPE,
                                 cp_term_enr_dtl_rec OUT NOCOPY IGS_EN_SPA_TERMS%ROWTYPE) IS
  /*
  ||  Created By : sjalasut
  ||  Created On : 03 Dec 2003
  ||  Purpose    : Function to get applicable enrollment details
  ||  - For a past award year, the last term (subordinate) is considered for processing
  ||  - For the current award year, the current term (based on sysdate) is considered
  ||  - For a future Award Year, the first term under that Award Year is considered
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c_fa_base_rec(cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE)IS
    SELECT fa.ci_cal_type, fa.ci_sequence_number, fa.person_id, ci.start_dt, ci.end_dt
      FROM igf_ap_fa_base_rec_all fa, igs_ca_inst ci
     WHERE fa.BASE_ID =  cp_base_id and
           fa.ci_cal_type = ci.cal_type and
           fa.ci_sequence_number = ci.sequence_number;
    l_base_rec   C_FA_BASE_REC%ROWTYPE;

    CURSOR c_ld_calendars_end (cp_aw_cal_type igs_ca_inst.cal_type%TYPE,
                               cp_aw_seq_no   igs_ca_inst.sequence_number%TYPE) IS
    SELECT ci.cal_type        enrl_load_cal_type,
           ci.sequence_number enrl_load_seq_num ,
           ci.alternate_code  terms,
           TRUNC(NVL(get_enr_eff_dt_alias_val(ci.cal_type,ci.sequence_number),ci.start_dt)) enrolled_start_dt,
           TRUNC(ci.end_dt)   enrolled_end_dt
      FROM
           igs_ca_inst ci,
           igs_ca_type cty
     WHERE cty.s_cal_cat = 'LOAD'
       AND cty.cal_type  = ci.cal_type
       AND (ci.cal_type, ci.sequence_number)IN
             (SELECT sup_cal_type,
                     sup_ci_sequence_number
                FROM igs_ca_inst_rel
               WHERE sub_cal_type = cp_aw_cal_type
                 AND sub_ci_sequence_number = cp_aw_seq_no
              UNION
             SELECT sub_cal_type,
                    sub_ci_sequence_number
               FROM igs_ca_inst_rel
              WHERE sup_cal_type           = cp_aw_cal_type
                AND sup_ci_sequence_number = cp_aw_seq_no
        )
     ORDER BY enrolled_end_dt DESC;

    CURSOR c_ld_calendars_start(cp_aw_cal_type igs_ca_inst.cal_type%TYPE,
                                cp_aw_seq_no   igs_ca_inst.sequence_number%TYPE)IS
    SELECT ci.cal_type        enrl_load_cal_type,
           ci.sequence_number enrl_load_seq_num ,
           ci.alternate_code  terms,
           TRUNC(NVL(get_enr_eff_dt_alias_val(ci.cal_type,ci.sequence_number),ci.start_dt)) enrolled_start_dt,
           TRUNC(ci.end_dt)   enrolled_end_dt
      FROM
           igs_ca_inst ci,
           igs_ca_type cty
     WHERE cty.s_cal_cat = 'LOAD'
       AND cty.cal_type  = ci.cal_type
       AND (ci.cal_type, ci.sequence_number)IN
             (SELECT sup_cal_type,
                     sup_ci_sequence_number
                FROM igs_ca_inst_rel
               WHERE sub_cal_type = cp_aw_cal_type
                 AND sub_ci_sequence_number = cp_aw_seq_no
              UNION
             SELECT sub_cal_type,
                    sub_ci_sequence_number
               FROM igs_ca_inst_rel
              WHERE sup_cal_type           = cp_aw_cal_type
                AND sup_ci_sequence_number = cp_aw_seq_no
             )
     ORDER BY enrolled_start_dt;

    CURSOR c_spa_terms( cp_person_id hz_parties.party_id%TYPE, cp_cal_type  igs_ca_inst.cal_type%TYPE, cp_seq_no igs_ca_inst.sequence_number%TYPE)IS
      SELECT  spa.*
        FROM  IGS_EN_SPA_TERMS spa,
              (SELECT su.person_id,
                      su.course_cd,
                      su.version_number,
                      tl.load_cal_type,
                      tl.load_ci_sequence_number
                FROM  igs_en_su_attempt su,
                      igs_ca_teach_to_load_v tl
                WHERE su.cal_type = tl.teach_cal_type
                  AND su.ci_sequence_number = tl.teach_ci_sequence_number) unit_attempt
       WHERE  spa.person_id = cp_person_id
        AND   spa.term_cal_type = cp_cal_type
        AND   spa.term_sequence_number  =  cp_seq_no
        AND   spa.key_program_flag = 'Y'
        AND   unit_attempt.person_id = spa.person_id
        AND   unit_attempt.course_cd = spa.program_cd
        AND   unit_attempt.version_number = spa.program_version
        AND   unit_attempt.load_cal_type = spa.term_cal_type
        AND   unit_attempt.load_ci_sequence_number = spa.term_sequence_number;
    l_term_rec   c_ld_calendars_start%ROWTYPE;

    CURSOR c_spa( cp_person_id hz_parties.party_id%TYPE)IS
    SELECT *
      FROM igs_en_stdnt_ps_att
     WHERE person_id = cp_person_id
       AND key_program = 'Y';
    l_spa_rec    C_SPA%ROWTYPE;

    l_person_id igs_pe_person_base_v.person_id%TYPE;

   BEGIN
     -- For the person in the award year loop. is this loop required ?
     FOR l_base_rec IN C_FA_BASE_REC(cp_fa_base_id) LOOP
       IF TRUNC(SYSDATE) BETWEEN TRUNC(l_base_rec.start_dt) AND TRUNC(l_base_rec.End_dt) THEN
         IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_ap_gen_001.get_term_dtl.debug',
           'sysdate between base record start date '||l_base_rec.start_dt||' and base record end date '|| l_base_rec.End_dt);
         END IF;
          -- the award year is current award year. get the current term based on sysdate and look into the term details
         FOR l_term_rec  in c_ld_calendars_start(l_base_rec.ci_cal_type, l_base_rec.ci_sequence_number) LOOP
           IF TRUNC(SYSDATE) BETWEEN  l_term_rec.enrolled_start_dt AND  l_term_rec.enrolled_end_dt  THEN
             IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_ap_gen_001.get_term_dtl.debug',
               'sysdate between term start date '||l_term_rec.enrolled_start_dt||' and term end date '|| l_term_rec.enrolled_end_dt);
             END IF;
             FOR x_term_enr_dtl_rec IN c_spa_terms(l_base_rec.person_id,l_term_rec.enrl_load_cal_type,l_term_rec.enrl_load_seq_num)LOOP
               IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
                 FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_ap_gen_001.get_term_dtl.debug',
                 'term record for person id '||l_base_rec.person_id||' enr load cal type '|| l_term_rec.enrl_load_cal_type || 'load seq number '||l_term_rec.enrl_load_seq_num);
               END IF;
               cp_term_enr_dtl_rec := x_term_enr_dtl_rec;
               RETURN;
             END LOOP;
           END IF;
         END LOOP;

       -- if the end date of the award year is past. i.e. < sysdate then process the term cals desc
       ELSIF TRUNC(l_base_rec.End_dt) < TRUNC(sysdate) THEN
         IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_ap_gen_001.get_term_dtl.debug',
           'sysdate past base record end date '||l_base_rec.start_dt||' and base record end date '|| l_base_rec.End_dt);
         END IF;

         FOR l_term_rec  in c_ld_calendars_end(l_base_rec.ci_cal_type, l_base_rec.ci_sequence_number) LOOP
           IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_ap_gen_001.get_term_dtl.debug',
             ' term start date for past awd year'||l_term_rec.enrolled_start_dt||' and term end date for past awd year'|| l_term_rec.enrolled_end_dt);
           END IF;

           FOR x_term_enr_dtl_rec IN c_spa_terms(l_base_rec.person_id,l_term_rec.enrl_load_cal_type,l_term_rec.enrl_load_seq_num) LOOP
             IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_ap_gen_001.get_term_dtl.debug',
               'past term record for person id '||l_base_rec.person_id||' enr load cal type '|| l_term_rec.enrl_load_cal_type || 'load seq number '||l_term_rec.enrl_load_seq_num);
             END IF;
             cp_term_enr_dtl_rec := x_term_enr_dtl_rec;
             RETURN;
           END LOOP;
         END LOOP;
       -- if the award year is a future award year then process the term cals asc
       ELSIF TRUNC(l_base_rec.start_dt) > TRUNC(sysdate) THEN
         IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_ap_gen_001.get_term_dtl.debug',
           'sysdate before base record end date '||l_base_rec.start_dt||' and base record end date '|| l_base_rec.End_dt);
         END IF;
         FOR l_term_rec  in c_ld_calendars_start(l_base_rec.ci_cal_type, l_base_rec.ci_sequence_number) LOOP
           IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
             FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_ap_gen_001.get_term_dtl.debug',
             'future term record for person id '||l_base_rec.person_id||' enr load cal type '|| l_term_rec.enrl_load_cal_type || 'load seq number '||l_term_rec.enrl_load_seq_num);
           END IF;
           FOR x_term_enr_dtl_rec IN c_spa_terms(l_base_rec.person_id,l_term_rec.enrl_load_cal_type,l_term_rec.enrl_load_seq_num) LOOP
             IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
               FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_ap_gen_001.get_term_dtl.debug',
               'future term record for person id '||l_base_rec.person_id||' enr load cal type '|| l_term_rec.enrl_load_cal_type || 'load seq number '||l_term_rec.enrl_load_seq_num);
             END IF;
             cp_term_enr_dtl_rec := x_term_enr_dtl_rec;
             RETURN;
           END LOOP;
         END LOOP;
       END IF;
       -- the control reached here. so no term records for the load calendars. peep into the prog att table directly and return the values
       l_person_id := igf_gr_Gen.get_person_id(cp_fa_base_id);
       IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_ap_gen_001.get_term_dtl.debug',
         'no term record details available for '||cp_fa_base_id);
       END IF;
       OPEN c_spa (l_person_id);
       FETCH c_spa INTO l_spa_rec;
       IF c_spa%FOUND THEN
         cp_term_enr_dtl_rec.person_id               := l_spa_rec.person_id;
         cp_term_enr_dtl_rec.program_cd              := l_spa_rec.course_cd;
         cp_term_enr_dtl_rec.program_version         := l_spa_rec.version_number;
         cp_term_enr_dtl_rec.acad_cal_type           := l_spa_rec.cal_type;
         cp_term_enr_dtl_rec.term_cal_type           := NULL;
         cp_term_enr_dtl_rec.term_sequence_number    := NULL;
         cp_term_enr_dtl_rec.key_program_flag        := l_spa_rec.key_program;
         cp_term_enr_dtl_rec.location_cd             := l_spa_rec.location_cd;
         cp_term_enr_dtl_rec.attendance_mode         := l_spa_rec.attendance_mode;
         cp_term_enr_dtl_rec.attendance_type         := l_spa_rec.attendance_type;
         cp_term_enr_dtl_rec.fee_cat                 := l_spa_rec.fee_cat;
         cp_term_enr_dtl_rec.coo_id                  := l_spa_rec.coo_id;
         cp_term_enr_dtl_rec.class_standing_id       := l_spa_rec.igs_pr_class_std_id;
         CLOSE c_spa;
         RETURN;
       END IF;
       CLOSE c_spa;
     END LOOP;
  END get_term_enrlmnt_dtl;

  --Function to get the end date alias value from the Date alias instances table
  FUNCTION get_enr_eff_dt_alias_val (cp_cal_type IN igs_Ca_inst.cal_type%TYPE,
                                 cp_sequence_number IN igs_ca_inst.sequence_number%TYPE)RETURN DATE IS
    CURSOR c_min_date IS
    SELECT TRUNC(MIN(daiv.alias_val)) enrolled_start_dt
      FROM igs_ca_da_inst_v daiv,
           igs_en_cal_conf secc
     WHERE
           secc.s_control_num      = 1 AND
           daiv.cal_type           = cp_cal_type AND
           daiv.ci_sequence_number = cp_sequence_number AND
           daiv.dt_alias           = secc.load_effect_dt_alias;
    c_min_date_rec c_min_date%ROWTYPE;
   BEGIN
     OPEN c_min_date; FETCH c_min_date INTO c_min_date_rec; CLOSE c_min_date;
     RETURN c_min_date_rec.enrolled_start_dt;
   END get_enr_eff_dt_alias_val;

  PROCEDURE get_context_data_for_term(
                                      p_base_id            IN  igf_ap_fa_base_rec_all.base_id%TYPE,
                                      p_ld_cal_type        IN  igs_ca_inst.cal_type%TYPE,
                                      p_ld_sequence_number IN  igs_ca_inst.sequence_number%TYPE,
                                      p_program_cd         OUT NOCOPY igs_ps_ver_all.course_cd%TYPE,
                                      p_version_num        OUT NOCOPY igs_ps_ver_all.version_number%TYPE,
                                      p_program_type       OUT NOCOPY igs_ps_ver_all.course_type%TYPE,
                                      p_org_unit           OUT NOCOPY igs_ps_ver_all.responsible_org_unit_cd%TYPE
                                     ) IS
  ------------------------------------------------------------------
  --Created by  : ssanyal
  --Date created: 29-Oct-2004
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --veramach    29-Oct-2004     Plugged in logic to check profile value before using anticipated values
  -------------------------------------------------------------------

    CURSOR c_fa_base_rec(
                         cp_base_id igf_ap_fa_base_rec_all.base_id%TYPE
                        ) IS
      SELECT fa.person_id
        FROM igf_ap_fa_base_rec_all fa
        WHERE fa.base_id = cp_base_id ;
    l_fa_base_rec   c_fa_base_rec%ROWTYPE;

    CURSOR c_spa_terms(
                       cp_person_id  hz_parties.party_id%TYPE,
                       cp_cal_type   igs_ca_inst.cal_type%TYPE,
                       cp_seq_no     igs_ca_inst.sequence_number%TYPE
                      ) IS
      SELECT *
        FROM igs_en_spa_terms
       WHERE person_id = cp_person_id
         AND term_cal_type = cp_cal_type
         AND term_sequence_number  =  cp_seq_no
         AND key_program_flag = 'Y';
    l_spa_terms   c_spa_terms%ROWTYPE;

    CURSOR c_prog_dtls(
                       cp_program_cd igs_ps_ver_all.course_cd%TYPE,
                       cp_version_num igs_ps_ver_all.version_number%TYPE
                      )IS
    SELECT *
      FROM igs_ps_ver_all
     WHERE course_cd = cp_program_cd
       AND version_number = NVL(cp_version_num,version_number);
    l_prog_dtls   c_prog_dtls%ROWTYPE;

    CURSOR c_anticipated_val(
                             cp_base_id            igf_ap_fa_base_rec_all.base_id%TYPE,
                             cp_ld_cal_type        igs_ca_inst.cal_type%TYPE,
                             cp_ld_sequence_number igs_ca_inst.sequence_number%TYPE
                            ) IS
    SELECT *
      FROM igf_ap_fa_ant_data
     WHERE base_id  =   cp_base_id
       AND ld_cal_type = cp_ld_cal_type
      AND ld_sequence_number = cp_ld_sequence_number;
    l_anticipated_val c_anticipated_val%ROWTYPE;

  BEGIN
    --Get the Person ID from Base Record
    OPEN c_fa_base_rec(p_base_id);
    FETCH c_fa_base_rec INTO l_fa_base_rec;
    IF c_fa_base_rec%NOTFOUND THEN
      CLOSE c_fa_base_rec;
      RETURN; --- Return Back base record not present
    ELSE
      CLOSE c_fa_base_rec;
    END IF;

    -- Get the Details from the Term Record
    OPEN c_spa_terms(l_fa_base_rec.person_id,p_ld_cal_type,p_ld_sequence_number);
    FETCH c_spa_terms INTO l_spa_terms;
    IF c_spa_terms%FOUND THEN
      CLOSE c_spa_terms;
    ELSE
      -- Term Record Does Not exist check in Antiicpated Values
      --anticipated values can be used only if the profile is set
      IF igf_aw_coa_gen.canUseAnticipVal THEN
        OPEN c_anticipated_val(p_base_id,p_ld_cal_type,p_ld_sequence_number);
        FETCH c_anticipated_val INTO l_anticipated_val;
        IF c_anticipated_val%FOUND THEN
          CLOSE c_anticipated_val;
          IF l_anticipated_val.program_cd IS NOT NULL THEN
            -- Since the Program Coe is Present in Anticipated Values use it , derive the other contexts from the Program Version setup
            l_spa_terms.program_cd := l_anticipated_val.program_cd;
          ELSE
            -- Since the Program Code is not present in anticipated valeus get the Org unit and the Program type if present
            p_program_cd   := NULL;
            p_version_num  := NULL;
            p_program_type := l_anticipated_val.program_type;
            p_org_unit     := l_anticipated_val.org_unit_cd;
            RETURN; -- Return Back
          END IF;
        ELSE
          CLOSE c_anticipated_val;
          p_program_cd   := NULL;
          p_version_num  := NULL;
          p_program_type := NULL;
          p_org_unit     := NULL;
          RETURN; -- Return Back with all null values
        END IF;
      ELSE
        --cannot use anticipated values
        p_program_cd   := NULL;
        p_version_num  := NULL;
        p_program_type := NULL;
        p_org_unit     := NULL;
        RETURN; -- Return Back with all null values
      END IF;
    END IF;

    OPEN c_prog_dtls(l_spa_terms.program_cd,l_spa_terms.program_version);
    FETCH c_prog_dtls INTO l_prog_dtls;
    IF c_prog_dtls%FOUND THEN
      CLOSE c_prog_dtls;
      p_program_cd   := l_prog_dtls.course_cd;
      p_version_num  := l_prog_dtls.version_number;
      p_program_type := l_prog_dtls.course_type;
      p_org_unit     := l_prog_dtls.responsible_org_unit_cd;
      RETURN; --Return Back
    ELSE
      CLOSE c_prog_dtls;
      p_program_cd := l_spa_terms.program_cd;
      p_version_num := l_spa_terms.program_version;
      RETURN; -- Return Back no program Setup found;
    END IF;
  END get_context_data_for_term;


  PROCEDURE get_term_dates(
                           p_base_id            IN igf_ap_fa_base_rec_all.base_id%TYPE,
                           p_ld_cal_type        IN igs_ca_inst.cal_type%TYPE,
                           p_ld_sequence_number IN igs_ca_inst.sequence_number%TYPE,
                           p_ld_start_date      OUT NOCOPY DATE,
                           p_ld_end_date        OUT NOCOPY DATE
                          ) IS
  ------------------------------------------------------------------
  --Created by  : ssanyal
  --Date created: 29-Oct-2004
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --veramach    01-Nov-2004     Fixed issues with parameter order
  --veramach    19-Nov-2004     Fixed issues with passing program version
  -------------------------------------------------------------------
  lc_program_cd    igs_ps_ver_all.course_cd%TYPE;
  lc_version_num   igs_ps_ver_all.version_number%TYPE;
  lc_program_type  igs_ps_ver_all.course_type%TYPE;
  lc_org_unit      igs_ps_ver_all.responsible_org_unit_cd%TYPE;

  BEGIN
    get_context_data_for_term(
                              p_base_id,
                              p_ld_cal_type,
                              p_ld_sequence_number,
                              lc_program_cd,
                              lc_version_num,
                              lc_program_type,
                              lc_org_unit
                             );

     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_gen_001.get_term_dates.debug','get_context_data_for_term ->  p_ld_cal_type/p_ld_sequence_number/lc_org_unit/lc_program_type/lc_program_cd/lc_version_num ->'
       || '<>' || p_ld_cal_type || '<>' || p_ld_sequence_number || '<>' || lc_org_unit || '<>'
       || lc_program_type || '<>' || lc_program_cd ||  '<>' || lc_version_num);
     END IF;

    p_ld_start_date := igs_ca_compute_da_val_pkg.cal_da_elt_val(
                                                                'FIRST_DAY_TERM',
                                                                p_ld_cal_type,
                                                                p_ld_sequence_number,
                                                                lc_org_unit,
                                                                lc_program_type,
                                                                lc_program_cd || '/' || lc_version_num
                                                               );

    p_ld_end_date := igs_ca_compute_da_val_pkg.cal_da_elt_val(
                                                              'LAST_DAY_TERM',
                                                              p_ld_cal_type,
                                                              p_ld_sequence_number,
                                                              lc_program_type,
                                                              lc_org_unit,
                                                              lc_program_cd || '/' || lc_version_num
                                                             );

     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_gen_001.get_term_dates.debug','prms to igs_ca_compute_da_val_pkg.cal_da_elt_val() -> FIRST_DAY_TERM<>'
       || '<>' || p_ld_cal_type || '<>' || p_ld_sequence_number || '<>' || lc_org_unit || '<>' || lc_program_type || '<>'
       || lc_program_cd ||  '/' || lc_version_num);
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_gen_001.get_term_dates.debug','ret val of igs_ca_compute_da_val_pkg.cal_da_elt_val() - p_ld_start_date  -> '
       || TO_CHAR(p_ld_start_date));
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_gen_001.get_term_dates.debug','prms to igs_ca_compute_da_val_pkg.cal_da_elt_val() -> LAST_DAY_TERM<>'
       || '<>' || p_ld_cal_type || '<>' || p_ld_sequence_number || '<>' || lc_org_unit || '<>' || lc_program_type || '<>'
       || lc_program_cd ||  '/' || lc_version_num);
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_ap_gen_001.get_term_dates.debug','ret val of igs_ca_compute_da_val_pkg.cal_da_elt_val() - p_ld_end_date ->'
       || TO_CHAR(p_ld_end_date));
     END IF;

  END get_term_dates;


  FUNCTION get_date_alias_val(
                              p_base_id         IN igf_ap_fa_base_rec_all.base_id%TYPE,
                              p_cal_type        IN igs_ca_inst.cal_type%TYPE,
                              p_sequence_number IN igs_ca_inst.sequence_number%TYPE,
                              p_date_alias      IN igs_ca_da_inst.dt_alias%TYPE
                             ) RETURN DATE IS
  ------------------------------------------------------------------
  --Created by  : ssanyal
  --Date created: 29-Oct-2004
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --veramach    19-Nov-2004     Fixed issues with passing program version
  -------------------------------------------------------------------
  CURSOR cur_get_dt(
                    cp_dt_alias igs_ca_da_inst.dt_alias%TYPE,
                    cp_cal_type igs_ca_da_inst.cal_type%TYPE,
                    cp_ci_sequence_number igs_ca_da_inst.ci_sequence_number%TYPE
                   )IS
     SELECT dainst.*
       FROM igs_ca_da_inst dainst
      WHERE dainst.dt_alias = cp_dt_alias
        AND dainst.cal_type = cp_cal_type
        AND dainst.ci_sequence_number = cp_ci_sequence_number;
  lc_dt_inst       cur_get_dt%ROWTYPE;

  lc_derived_val   DATE;
  lc_program_cd    igs_ps_ver_all.course_cd%TYPE;
  lc_version_num   igs_ps_ver_all.version_number%TYPE;
  lc_program_type  igs_ps_ver_all.course_type%TYPE;
  lc_org_unit      igs_ps_ver_all.responsible_org_unit_cd%TYPE;

  BEGIN
    get_context_data_for_term(
                              p_base_id,
                              p_cal_type,
                              p_sequence_number,
                              lc_program_cd,
                              lc_version_num,
                              lc_program_type,
                              lc_org_unit
                             );
    -- Get the Date Instance for the give data alias with respect to the Calendar Type and Sequence Number
    OPEN cur_get_dt(p_date_alias,p_cal_type,p_sequence_number) ;
    FETCH cur_get_dt INTO lc_dt_inst;

    IF cur_get_dt%FOUND THEN
      CLOSE cur_get_dt;
      lc_derived_val := igs_ca_compute_da_val_pkg.cal_da_elt_ofst_val(
                                                                      p_date_alias,
                                                                      lc_dt_inst.sequence_number,
                                                                      p_cal_type,
                                                                      p_sequence_number,
                                                                      lc_org_unit,
                                                                      lc_program_type,
                                                                      lc_program_cd || '/' || lc_version_num
                                                                     );
      -- If the calendar API returns the Derived value for the given calendar Instance
      -- then use this else use obsolute value defined at Calendar Level
      IF lc_derived_val IS NOT NULL THEN
        RETURN lc_derived_val;
      ELSE
        RETURN lc_dt_inst.absolute_val;
      END IF;
    ELSE
      CLOSE cur_get_dt;
      RETURN NULL;
    END IF;
  END get_date_alias_val;


END IGF_AP_GEN_001;

/
