--------------------------------------------------------
--  DDL for Package Body IGS_HE_PROG_TRANSFER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_PROG_TRANSFER_PKG" AS
/* $Header: IGSHE17B.pls 120.1 2006/02/07 14:53:19 jbaber noship $ */

/*---------------------------------------------------------------------
   This procedure will copy old record details to a new record

   Output :  p_message_name - Error messagev_calc
             p_status       - Return code for the procedure.
                              0 - Success
                              1 - Warning
                              2 - Failure
  --smvk       03-Jun-2003    Bug # 2858436.Modified the cursor c_prg_awd to select open program awards only.
--     smaddali (bug#2371477) 16-may-2002 modified this procedure to create the new unit
 --    set attempt hesa details record even when the old susa hesa details record is not found
 --Bayadav     22-OCT-2002    Included four new columns qual_aim_subj1,qual_aim_subj2,qual_aim_subj3,qual_aim_proportion
 --                           in IGS_HE_ST_SPA_ALL table as a part of bug 2636897
 -- Bayadav      05-DEC-2002    Included the check for HESA qualaim instead of award code before copying the old units values back to the new unit
  --                            as a part of bug 2671155
  -- smaddali modified procedure to copy new_he_entrant_cd and modified validation for fundability_cd ,bug 2730371
  -- smaddali modified procedure to copy new_he_entrant_cd for continuous programs of study ,bug 2717755
  -- ayedubat 01-SEP-2003  Changed the procedure to copy the Student Unit Set Attempt Cost Centre details
  --                       for HE207FD bug, 2717753
  ---------------------------------------------------------------------*/

  PROCEDURE hesa_stud_susa_trans(
     p_person_id                IN NUMBER,
     p_old_course_cd            IN VARCHAR2,
     p_new_course_cd            IN VARCHAR2,
     p_old_unit_set_cd          IN VARCHAR2,
     p_new_unit_set_cd          IN VARCHAR2,
     p_old_us_version_number    IN NUMBER,
     p_new_us_version_number    IN NUMBER,
     p_status                   OUT NOCOPY VARCHAR2,
     p_message_name             OUT NOCOPY VARCHAR2 ) IS


  -- Variables to hold old and new values from other tables for record.
  v_old_prg_funding_source       igs_fi_fnd_src_rstn.funding_source%TYPE;
  v_old_hesa_qual_map1           igs_he_code_map_val.map1%TYPE;
  v_old_prg_fundability_cd       igs_he_poous_all.fundability_cd%TYPE;

  v_new_hesa_qual_map1           igs_he_code_map_val.map1%TYPE;
  v_new_prg_funding_source       igs_fi_fnd_src_rstn.funding_source%TYPE;
  v_new_prg_fundability_cd       igs_he_poous_all.fundability_cd%TYPE;

  -- Variables to hold final values for first record
  v_hesa_en_susa_id             igs_he_en_susa.hesa_en_susa_id%TYPE;
  v_term_time_accom             igs_he_en_susa.term_time_accom%TYPE;
  v_study_mode                  igs_he_en_susa.study_mode%TYPE;
  v_student_qual_aim            igs_he_st_spa_all.student_qual_aim%TYPE;
  v_franchising_activity        igs_he_en_susa.franchising_activity%TYPE;
  v_fte_perc_override           igs_he_en_susa.fte_perc_override%TYPE;
  v_fundability_code            igs_he_en_susa.fundability_code%TYPE;
  v_fee_band                    igs_he_en_susa.fee_band%TYPE;
  v_completion_status           igs_he_en_susa.completion_status%TYPE;
  v_good_stand_marker           igs_he_en_susa.good_stand_marker%TYPE;
  v_complete_pyr_study_cd       igs_he_en_susa.complete_pyr_study_cd%TYPE;
  v_grad_sch_grade              igs_he_en_susa.grad_sch_grade%TYPE;
  v_mark                        igs_he_en_susa.mark%TYPE;
  v_type_of_year                igs_he_en_susa.TYPE_OF_YEAR%TYPE;
  v_fte_intensity               igs_he_en_susa.fte_intensity%TYPE;
  v_fte_calc_type               igs_he_en_susa.fte_calc_type%TYPE;
  v_term_time_map1              igs_he_code_map_val.map1%TYPE;
  v_rowid                       VARCHAR2(25);
  v_new_he_entrant_cd           igs_he_en_susa.new_he_entrant_cd%TYPE;

  --Variables to hold old record unique key values
  v_u_old_version_number         igs_en_stdnt_ps_att.version_number%TYPE;
  v_u_old_cal_type               igs_en_stdnt_ps_att.cal_type%TYPE;
  v_u_old_location_cd            igs_en_stdnt_ps_att.location_cd%TYPE;
  v_u_old_attendance_mode        igs_en_stdnt_ps_att.attendance_mode%TYPE;
  v_u_old_attendance_type        igs_en_stdnt_ps_att.attendance_type%TYPE;
  v_u_old_sequence_number        igs_as_su_setatmpt.sequence_number%TYPE;
  v_u_new_version_number         igs_en_stdnt_ps_att.version_number%TYPE;
  v_u_new_cal_type               igs_en_stdnt_ps_att.cal_type%TYPE;
  v_u_new_location_cd            igs_en_stdnt_ps_att.location_cd%TYPE;
  v_u_new_attendance_mode        igs_en_stdnt_ps_att.attendance_mode%TYPE;
  v_u_new_attendance_type        igs_en_stdnt_ps_att.attendance_type%TYPE;
  v_u_new_sequence_number        igs_as_su_setatmpt.sequence_number%TYPE;

  -- Cursor to retrieve unique-key values for passed program_cd which will be used
  -- to extract single records from other tables.
  CURSOR c_prg_ukeyrec (cp_course_cd igs_en_stdnt_ps_att.course_cd%TYPE ) IS
  SELECT version_number,
         cal_type,
         location_cd,
         attendance_mode,
         attendance_type
  FROM   igs_en_stdnt_ps_att
  WHERE  person_id = p_person_id AND
         course_cd = cp_course_cd;


  -- Cursor to retrieve unique-key values for passed unit set attempt which will be used
  -- to extract single records from other tables.
  CURSOR c_us_ukeyrec(cp_course_cd igs_en_stdnt_ps_att.course_cd%TYPE,
                       cp_unit_set_cd igs_as_su_setatmpt.unit_set_cd%TYPE,
                       cp_us_version_number igs_as_su_setatmpt.us_version_number%TYPE) IS
  SELECT max(sequence_number)
  FROM   igs_as_su_setatmpt
  WHERE  person_id = p_person_id AND
         course_cd = cp_course_cd AND
         unit_set_cd = cp_unit_set_cd AND
         us_version_number = cp_us_version_number;



  -- Cursor to retrive values that dont need to be validated for record1.
  -- smaddali merged this cursor with c_oldrec1 for better performance
  CURSOR c_old_susa IS
  SELECT  disability_allow,
          additional_sup_band,
          sldd_discrete_prov,
          credit_level_achieved1,
          credit_level_achieved2,
          credit_pt_achieved1,
          credit_pt_achieved2,
          fee_eligibility,
          non_payment_reason,
          calculated_fte ,
          term_time_accom,
          study_mode,
          franchising_activity,
          fte_perc_override,
          completion_status,
          good_stand_marker,
          complete_pyr_study_cd,
          grad_sch_grade,
          mark,
          fundability_code,
          fee_band ,
          fte_intensity,
          fte_calc_type,
          type_of_year,
          new_he_entrant_cd,
          credit_level_achieved3,
          credit_level_achieved4,
          credit_pt_achieved3,
          credit_pt_achieved4,
          additional_sup_cost,
          enh_fund_elig_cd,
          disadv_uplift_factor,
          year_stu
   FROM   igs_he_en_susa
   WHERE  person_id = p_person_id AND
          course_cd = p_old_course_cd AND
          unit_set_cd = p_old_unit_set_cd AND
          us_version_number = p_old_us_version_number AND
          sequence_number = v_u_old_sequence_number;
   c_old_susa_rec    c_old_susa%ROWTYPE ;


   -- Cursor to retrieve old record values for record 1 from IGS_HE_POOUS_ALL
   -- that will be validated.
   -- smaddali selecting fundability_cd ,for bug 2730371
   -- smaddali added field funding_source as part of hefd208 bug#2717751
   CURSOR c_old_poous IS
   SELECT attendance_type,
          franchising_activity,
          fte_intensity,
          fte_calc_type,
          grading_schema_cd,
          gs_version_number,
          fee_band,
          type_of_year,
          fundability_cd,
          funding_source
   FROM   igs_he_poous_all
   WHERE  course_cd = p_old_course_cd AND
          unit_set_cd = p_old_unit_set_cd AND
          us_version_number = p_old_us_version_number AND
          crv_version_number = v_u_old_version_number AND
          cal_type = v_u_old_cal_type AND
          location_cd = v_u_old_location_cd AND
          attendance_mode = v_u_old_attendance_mode AND
          attendance_type = v_u_old_attendance_type;
   c_old_poous_rec        c_old_poous%ROWTYPE ;

   -- Cursor to retrieve default program award for the passed program from IGS_PS_AWARD
   -- that will be validated.
   CURSOR c_prg_awd( cp_course_cd igs_he_st_prog_all.course_cd%TYPE,
                       cp_version_number igs_he_st_prog_all.version_number%TYPE) IS
   SELECT map1
   FROM   igs_ps_award, igs_he_code_map_val
   WHERE  course_cd = cp_course_cd AND
          version_number = cp_version_number AND
          closed_ind  = 'N' AND
          map2 = award_cd   AND
          association_code = 'OSS_HESA_AWD_ASSOC'
   ORDER BY default_ind DESC, map1 ASC ;

   -- Cursor to retrieve funding source restriction values for passed program from IGS_FI_FND_SRC_RSTN
   -- that will be validated.
   CURSOR c_fnd_src_rstn( cp_course_cd igs_he_st_prog_all.course_cd%TYPE,
                       cp_version_number igs_he_st_prog_all.version_number%TYPE) IS
   SELECT funding_source
   FROM   igs_fi_fnd_src_rstn
   WHERE  course_cd = cp_course_cd AND
          version_number = cp_version_number AND
          dflt_ind = 'Y';

  -- Cursor to retrieve values for new record from IGS_HE_POOUS_ALL
  -- that will be validated against old values.
  -- smaddali selecting fundability_cd ,for bug 2730371
  -- smaddali added field funding_source as part of hefd208 bug#2717751
  CURSOR c_new_poous IS
  SELECT attendance_type,
         franchising_activity,
         fte_intensity,
         fte_calc_type,
         grading_schema_cd,
         gs_version_number,
         fee_band,type_of_year,
         fundability_cd,
         funding_source
  FROM   igs_he_poous_all
  WHERE  course_cd = p_new_course_cd AND
         crv_version_number = v_u_new_version_number AND
         cal_type = v_u_new_cal_type AND
         location_cd = v_u_new_location_cd AND
         attendance_mode = v_u_new_attendance_mode AND
         attendance_type = v_u_new_attendance_type AND
         unit_set_cd = p_new_unit_set_cd AND
         us_version_number = p_new_us_version_number ;
  c_new_poous_rec      c_new_poous%ROWTYPE ;



  -- Required for validation against field in first record.
  CURSOR term_map IS
  SELECT map1
  FROM   igs_he_code_map_val
  WHERE  association_code = 'OSS_HESA_TTA_ASSOC' AND
         map2 = (select term_time_accom
                 from igs_he_en_susa
                 where person_id = p_person_id AND
                       course_cd = p_old_course_cd AND
                       unit_set_cd = p_old_unit_set_cd AND
                       us_version_number = p_old_us_version_number);

  -- smaddali added  new cursor for bug 2730371
  -- Cursor to retrieve fundability_cd for passed program record
  -- that will be validated against old values.
  CURSOR c_prg_fundability(cp_course_cd igs_he_st_prog_all.course_cd%TYPE,
                       cp_version_number igs_he_st_prog_all.version_number%TYPE) IS
  SELECT fundability
  FROM   IGS_he_st_prog_all
  WHERE  course_cd = cp_course_cd AND
         version_number = cp_version_number ;

   -- smaddali added this cursor for Bug# 2717755
   -- check if the old and new programs belong to the same program group with system group type CONTINUOUS
   CURSOR c_prg_grp IS
   SELECT b.course_group_cd
   FROM igs_ps_grp_type a, igs_ps_grp_all  b,  igs_ps_grp_mbr  c ,  igs_ps_grp_mbr  d
   WHERE a.course_group_type = b.course_group_type AND
         a.closed_ind = 'N' AND
         a.s_course_group_type = 'CONTINUOUS' AND
         b.course_group_cd = c.course_group_cd AND
         b.closed_ind = 'N' AND
         c.course_cd = p_old_course_cd AND
         c.version_number = v_u_old_version_number AND
         b.course_group_cd = d.course_group_cd AND
         d.course_cd = p_new_course_cd AND
         d.version_number = v_u_new_version_number ;

   c_prg_grp_rec c_prg_grp%ROWTYPE ;
   l_cont_progs BOOLEAN;

    -- Fetch the Cost Centers of the Old Program Attempt
    CURSOR old_susa_cc_dtls_cur( cp_person_id igs_he_en_susa_cc.person_id%TYPE,
                                 cp_course_cd igs_he_en_susa_cc.course_cd%TYPE,
                                 cp_unit_set_cd igs_he_en_susa_cc.unit_set_cd%TYPE,
                                 cp_sequence_number igs_he_en_susa_cc.sequence_number%TYPE) IS
      SELECT susa.*
      FROM igs_he_en_susa_cc susa
      WHERE susa.person_id = cp_person_id
        AND susa.course_cd = cp_course_cd
        AND susa.unit_set_cd = cp_unit_set_cd
        AND susa.sequence_number = cp_sequence_number;

    -- Check whether the Cost Center record already exist in the new program attempt
    CURSOR new_susa_cc_dtls_cur(cp_person_id    igs_he_en_susa_cc.person_id%TYPE,
                                cp_course_cd    igs_he_en_susa_cc.course_cd%TYPE,
                                cp_unit_set_cd  igs_he_en_susa_cc.unit_set_cd%TYPE,
                                cp_sequence_number igs_he_en_susa_cc.sequence_number%TYPE,
                                cp_cost_centre  igs_he_en_susa_cc.cost_centre%TYPE,
                                cp_subject      igs_he_en_susa_cc.subject%TYPE) IS
      SELECT 'X'
      FROM igs_he_en_susa_cc susa
      WHERE susa.person_id = cp_person_id
        AND susa.course_cd = cp_course_cd
        AND susa.unit_set_cd = cp_unit_set_cd
        AND susa.sequence_number = cp_sequence_number
        AND susa.cost_centre = cp_cost_centre
        AND susa.subject = cp_subject;

    l_rowid VARCHAR2(25) := NULL;
    l_he_susa_cc_id igs_he_en_susa_cc.he_susa_cc_id%TYPE := NULL ;
    l_dummy VARCHAR2(1);

BEGIN

   -- Check if Parameter values are passed incorrectly
   p_status             := 0;
   l_cont_progs         := FALSE ;

   IF p_person_id               IS NULL OR
      p_old_course_cd           IS NULL OR
      p_new_course_cd           IS NULL OR
      p_old_unit_set_cd         IS NULL OR
      p_new_unit_set_cd         IS NULL OR
      p_old_us_version_number   IS NULL OR
      p_new_us_version_number   IS NULL
   THEN
      p_status          := 2;
      p_message_name    := 'IGS_HE_INV_PARAMS';
      RETURN;
   END IF;


   -- fetch Unique Keys for old program_cd
   OPEN c_prg_ukeyrec(p_old_course_cd);
   FETCH c_prg_ukeyrec INTO v_u_old_version_number,
                            v_u_old_cal_type,
                            v_u_old_location_cd,
                            v_u_old_attendance_mode,
                            v_u_old_attendance_type;
   CLOSE c_prg_ukeyrec;

   -- Fetch unique keys for old unit set attempt record
   OPEN c_us_ukeyrec(p_old_course_cd,p_old_unit_set_cd,p_old_us_version_number);
   FETCH c_us_ukeyrec INTO v_u_old_sequence_number;
   CLOSE c_us_ukeyrec;

   --FETCH Unique Keys for new program_cd
   OPEN c_prg_ukeyrec(p_new_course_cd);
   FETCH c_prg_ukeyrec INTO v_u_new_version_number,
                            v_u_new_cal_type,
                            v_u_new_location_cd,
                            v_u_new_attendance_mode,
                            v_u_new_attendance_type;
   CLOSE c_prg_ukeyrec;

   -- Fetch unique keys for new unit set attempt record
   OPEN c_us_ukeyrec(p_new_course_cd,p_new_unit_set_cd,p_new_us_version_number);
   FETCH c_us_ukeyrec INTO v_u_new_sequence_number;
   CLOSE c_us_ukeyrec;

   -- set the flag if the old and new programs are a continuous study
   -- smaddali added this new cursor code for build HEFD209 bug2717755
   OPEN c_prg_grp ;
   FETCH c_prg_grp INTO c_prg_grp_rec;
   IF c_prg_grp%FOUND THEN
         l_cont_progs   := TRUE ;
   END IF;
   CLOSE c_prg_grp;


   -- Check If Old unit set attempt hesa record exists
   OPEN c_old_susa;
   FETCH c_old_susa INTO  c_old_susa_rec;
   IF c_old_susa%NOTFOUND THEN
      -- smaddali added this code instead of raising error ,for bug#2371477
         close c_old_susa;
         -- create the new susa hesa details record
         igs_he_en_susa_pkg.insert_row(
                          x_rowid                       => v_rowid,
                          x_hesa_en_susa_id             => v_hesa_en_susa_id,
                          x_person_id                   => p_person_id,
                          x_course_cd                   => p_new_course_cd,
                          x_unit_set_cd                 => p_new_unit_set_cd,
                          x_us_version_number           => p_new_us_version_number,
                          x_sequence_number             => v_u_new_sequence_number,
                          x_new_he_entrant_cd           => NULL,
                          x_term_time_accom             => NULL ,
                          x_disability_allow            => NULL ,
                          x_additional_sup_band         => NULL,
                          x_sldd_discrete_prov          => NULL ,
                          x_study_mode                  => NULL ,
                          x_study_location              => NULL,
                          x_fte_perc_override           => NULL,
                          x_franchising_activity        => NULL,
                          x_completion_status           => NULL ,
                          x_good_stand_marker           => NULL ,
                          x_complete_pyr_study_cd       => NULL ,
                          x_credit_value_yop1           => NULL,
                          x_credit_value_yop2           => NULL,
                          x_credit_level_achieved1      => NULL ,
                          x_credit_level_achieved2      => NULL ,
                          x_credit_pt_achieved1         => NULL ,
                          x_credit_pt_achieved2         => NULL ,
                          x_credit_level1               => NULL,
                          x_credit_level2               => NULL,
                          x_grad_sch_grade              => NULL ,
                          x_mark                        => NULL ,
                          x_teaching_inst1              => NULL,
                          x_teaching_inst2              => NULL,
                          x_pro_not_taught              => NULL,
                          x_fundability_code            => NULL ,
                          x_fee_eligibility             => NULL ,
                          x_fee_band                    => NULL ,
                          x_non_payment_reason          => NULL,
                          x_student_fee                 => NULL,
                          x_fte_intensity               => NULL ,
                          x_fte_calc_type               => NULL ,
                          x_calculated_fte              => NULL ,
                          x_type_of_year                => NULL,
                          x_mode                        => 'R',
                          x_credit_value_yop3           => NULL,
                          x_credit_value_yop4           => NULL,
                          x_credit_level_achieved3      => NULL,
                          x_credit_level_achieved4      => NULL,
                          x_credit_pt_achieved3         => NULL,
                          x_credit_pt_achieved4         => NULL,
                          x_credit_level3               => NULL,
                          x_credit_level4               => NULL,
                          x_additional_sup_cost         => NULL,
                          x_enh_fund_elig_cd            => NULL,
                          x_disadv_uplift_factor        => NULL,
                          x_year_stu                    => NULL);

   ELSE

      close c_old_susa;

      --FETCH Values for old records from IGS_HE_POOUS_ALL, IGS_PS_AWARD, IGS_FI_FND_SRC_RSTN
      OPEN c_old_poous;
      FETCH c_old_poous INTO c_old_poous_rec;
      CLOSE c_old_poous;

      -- Fetch the old program default award
      v_old_hesa_qual_map1        := NULL;
      OPEN c_prg_awd(p_old_course_cd,v_u_old_version_number);
      FETCH c_prg_awd INTO   v_old_hesa_qual_map1;
      CLOSE c_prg_awd;

      -- Fetch the old programs default funding source restriction
      v_old_prg_funding_source  := NULL;
      OPEN c_fnd_src_rstn(p_old_course_cd,v_u_old_version_number);
      FETCH c_fnd_src_rstn INTO   v_old_prg_funding_source;
      CLOSE c_fnd_src_rstn;

      --FETCH Values for new records from IGS_HE_POOUS_ALL, IGS_PS_AWARD, IGS_FI_FND_SRC_RSTN
      OPEN c_new_poous;
      FETCH c_new_poous INTO   c_new_poous_rec;
      CLOSE c_new_poous;

     -- Fetch the new programs default award code
     v_new_hesa_qual_map1         := NULL;
     OPEN c_prg_awd(p_new_course_cd,v_u_new_version_number);
     FETCH c_prg_awd INTO   v_new_hesa_qual_map1;
     CLOSE c_prg_awd;

     -- Fetch the new programs default funding source restriction
     v_new_prg_funding_source   := NULL;
     OPEN c_fnd_src_rstn(p_new_course_cd,v_u_new_version_number);
     FETCH c_fnd_src_rstn INTO   v_new_prg_funding_source;
     CLOSE c_fnd_src_rstn;

     --Get Value for term_time field.
     v_term_time_map1           := NULL;
     OPEN term_map;
     FETCH term_map INTO v_term_time_map1;
     CLOSE term_map;

     --check conditions for term time accomodation
     IF v_term_time_map1 <> '6' THEN
         --copy value from old record to new record
         v_term_time_accom      := c_old_susa_rec.term_time_accom;
     END IF;

     --check conditions for study_mode.
     IF c_old_poous_rec.attendance_type = c_new_poous_rec.attendance_type AND
         v_old_hesa_qual_map1 = v_new_hesa_qual_map1 THEN
          --copy value from old record to new record
        V_STUDY_MODE            := c_old_susa_rec.study_mode;
     END IF;

     --check conditions for franchising activity field.
     IF (c_old_poous_rec.franchising_activity IS NULL AND c_new_poous_rec.franchising_activity IS NULL) OR
        (c_old_poous_rec.franchising_activity = c_new_poous_rec.franchising_activity )  THEN
         -- copy value from old record to new record
         v_franchising_activity := c_old_susa_rec.franchising_activity;
     END IF;

     --check conditions for fte intensity field.
     IF (c_old_poous_rec.fte_intensity IS NULL AND c_new_poous_rec.fte_intensity IS NULL) OR
        (c_old_poous_rec.fte_intensity = c_new_poous_rec.fte_intensity ) THEN
           --copy value from old record to new record
           v_fte_intensity      := c_old_susa_rec.fte_intensity;
     END IF;

     --check conditions for fte calculation type  field.
     IF (c_old_poous_rec.fte_calc_type IS NULL AND  c_new_poous_rec.fte_calc_type IS NULL) OR
        (c_old_poous_rec.fte_calc_type = c_new_poous_rec.fte_calc_type) THEN
         --copy value from old record to new record
         v_fte_calc_type        := c_old_susa_rec.fte_calc_type;
     END IF;

     --check conditions for completion status, good standing marker, completion
     --of year of program
     IF   v_old_hesa_qual_map1 = v_new_hesa_qual_map1 THEN
         --copy value from old record to new record for fields.
         v_completion_status            := c_old_susa_rec.completion_status;
         v_good_stand_marker            := c_old_susa_rec.good_stand_marker;
         v_complete_pyr_study_cd        := c_old_susa_rec.complete_pyr_study_cd;
     END IF;

     -- smaddali added new check "or both programs are a continuous study" for HEFD209 build , bug#2717755
     IF   v_old_hesa_qual_map1 = v_new_hesa_qual_map1 OR  l_cont_progs THEN
         -- smaddali added new_entrant_cd field , bug 2730371
         v_new_he_entrant_cd            := c_old_susa_rec.new_he_entrant_cd ;
     END IF;

     --check condition for grading schema grade and mark fields.
     IF c_old_poous_rec.grading_schema_cd = c_new_poous_rec.grading_schema_cd AND
        c_old_poous_rec.gs_version_number = c_new_poous_rec.gs_version_number THEN
         --copy old record to new record for fields.
         v_grad_sch_grade               := c_old_susa_rec.grad_sch_grade;
         v_mark                         := c_old_susa_rec.mark;
     END IF;

     --check condition for fundability code.
     -- smaddali modified fundability validation for nug 2730371
     -- If fundability for both POOUS are equal then copy old susa fundability
     -- elsif both poous fundability is null then get from program level
     IF (c_old_poous_rec.fundability_cd IS NULL AND c_new_poous_rec.fundability_cd IS NULL) THEN
              v_old_prg_fundability_cd := NULL;
              v_new_prg_fundability_cd := NULL ;
              OPEN c_prg_fundability(p_old_course_cd,v_u_old_version_number);
              FETCH c_prg_fundability into   v_old_prg_fundability_cd ;
              CLOSE c_prg_fundability;

              OPEN c_prg_fundability(p_new_course_cd,v_u_new_version_number);
              FETCH c_prg_fundability into   v_new_prg_fundability_cd;
              CLOSE c_prg_fundability;

             -- If fundability at both programs is equal then copy old susa fundability
             -- elsif fundability is null for both programs then get funding source at POOUS
             IF (v_old_prg_fundability_cd IS NULL AND v_new_prg_fundability_cd IS NULL) THEN
                 -- smaddali added check for funding_source at POOUS level for HEFD208 bug#2717751
                 -- If funding source at both POOUS is equal then copy old susa fundability
                 -- elsif funding source is null for both POOUS then get funding source at Proogram level
                 IF (c_old_poous_rec.funding_source IS NULL AND c_new_poous_rec.funding_source IS NULL) THEN
                        -- If funding sources are both null or equal then copy the old susa fundability
                        IF (v_old_prg_funding_source IS NULL AND v_new_prg_funding_source IS NULL) OR
                        (v_old_prg_funding_source = v_new_prg_funding_source) THEN
                            --copy old record to new record for field.
                            v_fundability_code := c_old_susa_rec.fundability_code;
                        END IF;
                 ELSIF c_old_poous_rec.funding_source = c_new_poous_rec.funding_source THEN
                        --copy old record to new record for field.
                        v_fundability_code := c_old_susa_rec.fundability_code;
                 END IF ;
             ELSIF  v_old_prg_fundability_cd = v_new_prg_fundability_cd  THEN
                --copy old record to new record for field.
                v_fundability_code := c_old_susa_rec.fundability_code;
             END IF ;
     ELSIF  c_old_poous_rec.fundability_cd = c_new_poous_rec.fundability_cd   THEN
            --copy old record to new record for field.
            v_fundability_code := c_old_susa_rec.fundability_code;
     END IF;

     --check condition for fee band field.
     IF (c_old_poous_rec.fee_band IS NULL AND c_new_poous_rec.fee_band IS NULL ) OR
        (c_old_poous_rec.fee_band = c_new_poous_rec.fee_band ) THEN
         --copy old record to new record.
         v_fee_band := c_old_susa_rec.fee_band;
     END IF;


     --check condition for type of program year
     IF (c_old_poous_rec.type_of_year IS NULL AND  c_new_poous_rec.type_of_year IS NULL) OR
        (c_old_poous_rec.type_of_year = c_new_poous_rec.type_of_year) THEN
         --copy old record to new record.
         v_type_of_year := c_old_susa_rec.type_of_year;
     END IF;


     -- INSERT Values into Record.
     igs_he_en_susa_pkg.insert_row(
                          x_rowid                       => v_rowid,
                          x_hesa_en_susa_id             => v_hesa_en_susa_id,
                          x_person_id                   => p_person_id,
                          x_course_cd                   => p_new_course_cd,
                          x_unit_set_cd                 => p_new_unit_set_cd,
                          x_us_version_number           => p_new_us_version_number,
                          x_sequence_number             => v_u_new_sequence_number,
                          x_new_he_entrant_cd           => v_new_he_entrant_cd,
                          x_term_time_accom             => v_term_time_accom,
                          x_disability_allow            => c_old_susa_rec.disability_allow,
                          x_additional_sup_band         => c_old_susa_rec.additional_sup_band,
                          x_sldd_discrete_prov          => c_old_susa_rec.sldd_discrete_prov,
                          x_study_mode                  => v_study_mode,
                          x_study_location              => NULL,
                          x_fte_perc_override           => NULL,
                          x_franchising_activity        => v_franchising_activity,
                          x_completion_status           => v_completion_status,
                          x_good_stand_marker           => v_good_stand_marker,
                          x_complete_pyr_study_cd       => v_complete_pyr_study_cd,
                          x_credit_value_yop1           => NULL,
                          x_credit_value_yop2           => NULL,
                          x_credit_level_achieved1      => c_old_susa_rec.credit_level_achieved1,
                          x_credit_level_achieved2      => c_old_susa_rec.credit_level_achieved2,
                          x_credit_pt_achieved1         => c_old_susa_rec.credit_pt_achieved1,
                          x_credit_pt_achieved2         => c_old_susa_rec.credit_pt_achieved2,
                          x_credit_level1               => NULL,
                          x_credit_level2               => NULL,
                          x_grad_sch_grade              => v_grad_sch_grade,
                          x_mark                        => v_mark,
                          x_teaching_inst1              => NULL,
                          x_teaching_inst2              => NULL,
                          x_pro_not_taught              => NULL,
                          x_fundability_code            => v_fundability_code,
                          x_fee_eligibility             => c_old_susa_rec.fee_eligibility,
                          x_fee_band                    => v_fee_band,
                          x_non_payment_reason          => c_old_susa_rec.non_payment_reason,
                          x_student_fee                 => NULL,
                          x_fte_intensity               => v_fte_intensity,
                          x_fte_calc_type               => v_fte_calc_type,
                          x_calculated_fte              => c_old_susa_rec.calculated_fte,
                          x_type_of_year                => v_type_of_year,
                          x_mode                        => 'R',
                          x_credit_value_yop3           => NULL,
                          x_credit_value_yop4           => NULL,
                          x_credit_level_achieved3      => c_old_susa_rec.credit_level_achieved3,
                          x_credit_level_achieved4      => c_old_susa_rec.credit_level_achieved4,
                          x_credit_pt_achieved3         => c_old_susa_rec.credit_pt_achieved3,
                          x_credit_pt_achieved4         => c_old_susa_rec.credit_pt_achieved4,
                          x_credit_level3               => NULL,
                          x_credit_level4               => NULL,
                          x_additional_sup_cost         => NULL,
                          x_enh_fund_elig_cd            => NULL,
                          x_disadv_uplift_factor        => NULL,
                          x_year_stu                    => NULL);

    END IF;   -- if old susa hesa details record is not found

    -- CREATE THE STUDENT SET ATTEMPT COST CENTRE RECORD

    -- Loop through all the records in igs_he_en_susa_cc table for the old unit set attempt
    -- and insert if the record does not exist for new Unit Set Attempt
    FOR old_susa_cc_dtls_rec IN old_susa_cc_dtls_cur( p_person_id, p_old_course_cd,
                                         p_old_unit_set_cd, v_u_old_sequence_number ) LOOP

       OPEN new_susa_cc_dtls_cur( p_person_id, p_new_course_cd, p_new_unit_set_cd, v_u_new_sequence_number,
                                old_susa_cc_dtls_rec.cost_centre, old_susa_cc_dtls_rec.subject );
       FETCH new_susa_cc_dtls_cur INTO l_dummy;
       IF new_susa_cc_dtls_cur%NOTFOUND THEN

          -- create the new student unit set attempt cost centre record
          igs_he_en_susa_cc_pkg.insert_row (
            x_rowid             => l_rowid,
            x_he_susa_cc_id     => l_he_susa_cc_id,
            x_person_id         => p_person_id,
            x_course_cd         => p_new_course_cd,
            x_unit_set_cd       => p_new_unit_set_cd,
            x_sequence_number   => v_u_new_sequence_number,
            x_cost_centre       => old_susa_cc_dtls_rec.cost_centre,
            x_subject           => old_susa_cc_dtls_rec.subject,
            x_proportion        => old_susa_cc_dtls_rec.proportion,
            x_mode              => 'R' );

       END IF;
       CLOSE new_susa_cc_dtls_cur;

    END LOOP;

 EXCEPTION
 WHEN OTHERS THEN
   ROLLBACK;
   p_status := 2;
   fnd_message.set_name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
   Fnd_message.set_token('NAME', 'IGS_HE_PROG_TRANSFER_PKG.Hesa_Stud_Susa_Trans');
   igs_ge_msg_stack.add;
   RETURN;

END hesa_stud_susa_trans;


/*---------------------------------------------------------------------
   This procedure will copy old record details to a new record for
   tables IGS_HE_ST_SPA_ALL and IGS_HE_ST_SPA_UT_ALL.

   Output :  p_message_name - Exit error message
             p_status       - Return code for the procedure.
                            0 - Success
                            1 - Warning
                            2 - Failure
  --  smvk     06-Jun-2003      Bug # 2858436. Modified c_old_awardcode to select un closed award code only.
  --     smaddali (bug#2371477) 16-may-2002 modified this procedure to create the old and new uk statistics
  --     record  when the old uk statistics record is not found
  -- Bayadav      05-DEC-2002    Included the check for HESA qualaim for the program code to set the student instance number
  --                            as a part of bug 2671155
  -- smaddali 30-dec-2002 included transfer of highest_qual_on_entry and ucas_tariff_score  for bug 2728756
  -- smaddali modified procedure to copy some fields for continuous programs of study ,bug 2717755
  -- pmarada 23-aug-2003 modified as per HECR008 build, deriving student instance number value.
  -- ayedubat 01-SEP-2003  Changed the procedure to copy the HESA Statitistic Student Program Attempt Cost Centre details
  --                       for HE207FD bug, 2717753
  ---------------------------------------------------------------------*/

PROCEDURE hesa_stud_stat_trans(
     p_person_id        IN NUMBER,
     p_old_course_cd    IN VARCHAR2,
     p_new_course_cd    IN VARCHAR2,
     p_status           OUT NOCOPY VARCHAR2,
     p_message_name     OUT NOCOPY VARCHAR2) IS

        -- Variables to hold old values for third record.
  v_old_qualification_level    igs_he_st_spa_ut_all.qualification_level%TYPE;
  v_old_number_of_qual         igs_he_st_spa_ut_all.number_of_qual%TYPE;
  v_old_tariff_score           igs_he_st_spa_ut_all.tariff_score%TYPE;

        -- Variables to hold final values for second record
  v_hesa_st_spa_id             igs_he_st_spa_all.hesa_st_spa_id%TYPE;
  v_student_qual_aim           igs_he_st_spa_all.student_qual_aim%TYPE;
  v_student_inst_number        igs_he_st_spa_all.student_inst_number%TYPE;
  v_commencement_dt            igs_he_st_spa_all.commencement_dt%TYPE;
  v_fe_student_marker          igs_he_st_spa_all.fe_student_marker%TYPE;
  v_domicile_cd                igs_he_st_spa_all.domicile_cd%TYPE;
  v_postcode                   igs_he_st_spa_all.postcode%TYPE;
  v_special_student            igs_he_st_spa_all.special_student%TYPE;
  v_social_class_ind           igs_he_st_spa_all.social_class_ind%TYPE;
  v_occupation_code            igs_he_st_spa_all.occupation_code%TYPE;
  v_occcode                    igs_he_st_spa_all.occcode%TYPE;
  v_student_fe_qual_aim        igs_he_st_spa_all.student_fe_qual_aim%TYPE;
  v_teacher_train_prog_id      igs_he_st_spa_all.teacher_train_prog_id%TYPE;
  v_nhs_funding_source         igs_he_st_spa_all.nhs_funding_source%TYPE;
  v_qual_aim_subj1             igs_he_st_spa_all.qual_aim_subj1%TYPE;
  v_qual_aim_subj2             igs_he_st_spa_all.qual_aim_subj2%TYPE;
  v_qual_aim_subj3             igs_he_st_spa_all.qual_aim_subj3%TYPE;
  v_qual_aim_proportion        igs_he_st_spa_all.qual_aim_proportion%TYPE;
  v_teach_map1                 igs_he_code_map_val.map1%TYPE;
  v_new_hesa_qual_map1         igs_he_code_map_val.map1%TYPE;
  v_old_hesa_qual_map1         igs_he_code_map_val.map1%TYPE;
  v_rowid                      VARCHAR2(25);
  v_org_id                     NUMBER := igs_ge_gen_003.get_org_id;
  v_highest_qual_on_entry      igs_he_st_spa_all.highest_qual_on_entry%TYPE;
  v_total_ucas_tariff          igs_he_st_spa_all.total_ucas_tariff%TYPE;

        -- Variables to hold final values for third record
  v_hesa_st_spau_id            igs_he_st_spa_ut_all.hesa_st_spau_id%TYPE;
  v_qualification_level        igs_he_st_spa_ut_all.qualification_level%TYPE;
  v_number_of_qual             igs_he_st_spa_ut_all.number_of_qual%TYPE;
  v_tariff_score               igs_he_st_spa_ut_all.tariff_score%TYPE;
  v_ut_rowid                   VARCHAR2(25);

        -- Variables to hold old and new values from other tables for record.
  v_old_tmp_prgfldstudy        igs_ps_field_study.field_of_study%TYPE;
  v_new_tmp_prgfldstudy        igs_ps_field_study.field_of_study%TYPE;

        -- Variables to hold old record unique key values
  v_u_old_version_number       igs_en_stdnt_ps_att.version_number%TYPE;
  v_u_new_version_number       igs_en_stdnt_ps_att.version_number%TYPE;
        -- variables to hold old record program field of study values
  v_u_old_program_fld_study    igs_ps_field_study.field_of_study%TYPE;
  v_u_new_program_fld_study    igs_ps_field_study.field_of_study%TYPE;

  -- Cursor required to retrieve version_number which is required as unique key for another cursor.
  CURSOR old_ukeyrec2 IS
  SELECT version_number
  FROM   igs_en_stdnt_ps_att
  WHERE  person_id = p_person_id AND
         course_cd = p_old_course_cd;

  -- Cursor required to retrieve version_number which is required as unique key for another cursor.
  CURSOR new_ukeyrec2 IS
  SELECT version_number
  FROM   igs_en_stdnt_ps_att
  WHERE  person_id = p_person_id AND
         course_cd = p_new_course_cd;

  -- Cursor to retrieve record values for award code from IGS_PS_AWARD
   CURSOR c_awardcode (cp_course_cd igs_ps_award.course_cd%TYPE ,
                       cp_version_number igs_ps_award.version_number%TYPE) IS
   SELECT map1
   FROM   igs_ps_award , igs_he_code_map_val
   WHERE  course_cd = cp_course_cd AND
          version_number = cp_version_number AND
          closed_ind = 'N' AND
          map2 = award_cd   AND
          association_code = 'OSS_HESA_AWD_ASSOC'
   ORDER BY default_ind DESC, map1 ASC ;

   -- Cursor to retrieve old record values for program field of study  record 2 from IGS_PS_FIELD_STUDY
   CURSOR c_old_prg_fldstudy IS
   SELECT field_of_study
   FROM   igs_ps_field_study
   WHERE  course_cd = p_old_course_cd AND
          version_number = v_u_old_version_number AND
          major_field_ind = 'Y';

   -- Cursor to retrieve new record values for program field of study  record 2 from IGS_PS_FIELD_STUDY
   CURSOR c_new_prg_fldstudy IS
   SELECT field_of_study
   FROM   igs_ps_field_study
   WHERE  course_cd = p_new_course_cd AND
          version_number = v_u_new_version_number AND
          major_field_ind = 'Y';


  -- Cursor to retrive values required for old program attempt hesa record.
  -- smaddali modified this cursor to select highest_ualification_on_entry,total_ucas_tariff also ,bug 2728756
  CURSOR c_old_spa IS
  SELECT student_inst_number,
         commencement_dt,
         fe_student_marker,
         domicile_cd,
         postcode,
         special_student,
         social_class_ind,
         occupation_code,
         occcode,
         student_qual_aim,
         student_fe_qual_aim,
         teacher_train_prog_id,
         nhs_funding_source,
         ufi_place,
         nhs_employer,
         qual_aim_subj1,
         qual_aim_subj2,
         qual_aim_subj3,
         qual_aim_proportion    ,
         highest_qual_on_entry,
         total_ucas_tariff
  FROM   igs_he_st_spa_all
  WHERE  person_id = p_person_id AND
         course_cd = p_old_course_cd;
  c_old_spa_rec     c_old_spa%ROWTYPE;

  -- Cursor required for validation against field in second record.
  -- get the hesa code mapped to the oss tacher code
  CURSOR teach_map(cp_teacher_train_prog_id igs_he_code_map_val.map2%TYPE) IS
  SELECT map1
  FROM   igs_he_code_map_val
  WHERE  association_code = 'OSS_HESA_TTCID_ASSOC' AND
         map2 = cp_teacher_train_prog_id;

  -- Cursor to retrieve values required for ucas tariff record.
   CURSOR ucas_tariff IS
   SELECT qualification_level,
          number_of_qual,
          tariff_score
   FROM   igs_he_st_spa_ut
   WHERE  person_id = p_person_id AND
          course_cd = p_old_course_cd;

   CURSOR cur_std_inst_num(cp_person_id igs_he_st_spa_all.person_id%TYPE) IS
     SELECT student_inst_number
     FROM igs_he_st_spa_all
     WHERE person_id = cp_person_id;

    l_std_inst_num  NUMBER;

   -- smaddali added this cursor for Bug# 2717755
   -- check if the old and new programs belong to the same program group with system group type CONTINUOUS
   CURSOR c_prg_grp IS
   SELECT b.course_group_cd
   FROM igs_ps_grp_type a, igs_ps_grp_all  b,  igs_ps_grp_mbr  c ,  igs_ps_grp_mbr  d
   WHERE a.course_group_type = b.course_group_type AND
         a.closed_ind = 'N' AND
         a.s_course_group_type = 'CONTINUOUS' AND
         b.course_group_cd = c.course_group_cd AND
         b.closed_ind = 'N' AND
         c.course_cd = p_old_course_cd AND
         c.version_number = v_u_old_version_number AND
         b.course_group_cd = d.course_group_cd AND
         d.course_cd = p_new_course_cd AND
         d.version_number = v_u_new_version_number ;

   c_prg_grp_rec c_prg_grp%ROWTYPE ;
   l_cont_progs BOOLEAN;

    -- Fetch the Cost Centers of the Old Program Attempt
    CURSOR old_spa_cc_dtls_cur( cp_person_id IGS_HE_ST_SPA_CC.person_id%TYPE,
                                cp_course_cd IGS_HE_ST_SPA_CC.course_cd%TYPE) IS
      SELECT spa.*
      FROM IGS_HE_ST_SPA_CC spa
      WHERE spa.person_id = cp_person_id
        AND spa.course_cd = cp_course_cd ;

    -- Check whether the Cost Center record already exist in the new program attempt
    CURSOR new_spa_cc_dtls_cur( cp_person_id    IGS_HE_ST_SPA_CC.person_id%TYPE,
                                cp_course_cd    IGS_HE_ST_SPA_CC.course_cd%TYPE,
                                cp_cost_centre  IGS_HE_ST_SPA_CC.cost_centre%TYPE,
                                cp_subject      IGS_HE_ST_SPA_CC.subject%TYPE) IS
      SELECT 'X'
      FROM IGS_HE_ST_SPA_CC spa
      WHERE spa.person_id = cp_person_id
        AND spa.course_cd = cp_course_cd
        AND cost_centre = cp_cost_centre
        AND subject = cp_subject;

    l_rowid VARCHAR2(25) := NULL;
    l_he_spa_cc_id igs_he_st_spa_cc.he_spa_cc_id%TYPE := NULL ;
    l_dummy VARCHAR2(1);

BEGIN

   -- Check Parameter values passed in correctly

   p_status             := 0;
   l_cont_progs         := FALSE ;

   IF p_person_id IS NULL OR
      p_old_course_cd IS NULL OR
      p_new_course_cd IS NULL
   THEN
      p_status          := 2;
      p_message_name    := 'IGS_HE_INV_PARAMS';
      RETURN;
   END IF;

   -- fetch unique keys for old program_cd from igs_en_stdnt_ps_att
   OPEN old_ukeyrec2;
   FETCH old_ukeyrec2 INTO v_u_old_version_number;
   CLOSE old_ukeyrec2;

   -- fetch unique keys for new program_cd from igs_en_stdnt_ps_att
   OPEN new_ukeyrec2;
   FETCH new_ukeyrec2 INTO v_u_new_version_number;
   CLOSE new_ukeyrec2;

   -- fetch award code for old program_cd
   OPEN c_awardcode( p_old_course_cd, v_u_old_version_number);
   FETCH c_awardcode INTO v_old_hesa_qual_map1;
   CLOSE c_awardcode;

   -- fetch award code for new program_cd
   OPEN c_awardcode(p_new_course_cd, v_u_new_version_number);
   FETCH c_awardcode INTO v_new_hesa_qual_map1;
   CLOSE c_awardcode;

   --Fetch program field of study for old program
   OPEN c_old_prg_fldstudy ;
   FETCH c_old_prg_fldstudy  INTO v_old_tmp_prgfldstudy;
   CLOSE c_old_prg_fldstudy ;


   --Fetch program field of study for new program
   OPEN c_new_prg_fldstudy ;
   FETCH c_new_prg_fldstudy  INTO v_new_tmp_prgfldstudy;
   CLOSE c_new_prg_fldstudy ;

   -- set the flag if the old and new programs are a continuous study
   -- smaddali added this new cursor code for build HEFD209 bug2717755
   OPEN c_prg_grp ;
   FETCH c_prg_grp INTO c_prg_grp_rec;
   IF c_prg_grp%FOUND THEN
         l_cont_progs := TRUE ;
   END IF;
   CLOSE c_prg_grp;

   -- SECONDLY CREATE A UK STATISTICS - SPA RECORD.
   -- Check If Old record exists and if so then fetch values into variables.
   OPEN c_old_spa;
   FETCH c_old_spa INTO  c_old_spa_rec;
   IF c_old_spa%NOTFOUND THEN
      CLOSE c_old_spa;
      -- Derive the student instance number value and use this value while creating
      -- new record in igs_he_st_spa_all table, added as per
      -- HECR008-alpha numeric student instance number CR
       l_std_inst_num := 1;
      FOR cur_std_inst_num_rec IN cur_std_inst_num(p_person_id) LOOP
        BEGIN
          IF NVL(TO_NUMBER(cur_std_inst_num_rec.student_inst_number),0) >= l_std_inst_num THEN
             l_std_inst_num := TO_NUMBER(cur_std_inst_num_rec.Student_inst_number) + 1;
          END IF;
          EXCEPTION
          WHEN VALUE_ERROR THEN
           NULL;
        END ;
      END LOOP;

       v_student_inst_number := l_std_inst_num ;

      -- create the SPA record for the old program attempt
      --Insert Values Into Record
      igs_he_st_spa_all_pkg.insert_row(
                                x_rowid                         => v_rowid,
                                x_hesa_st_spa_id                => v_hesa_st_spa_id,
                                x_org_id                        => v_org_id,
                                x_person_id                     => p_person_id,
                                x_course_cd                     => p_old_course_cd,
                                x_version_number                => v_u_old_version_number,
                                x_fe_student_marker             => NULL,
                                x_domicile_cd                   => NULL,
                                x_inst_last_attended            => NULL,
                                x_year_left_last_inst           => NULL,
                                x_highest_qual_on_entry         => NULL,
                                x_date_qual_on_entry_calc       => NULL,
                                x_a_level_point_score           => NULL,
                                x_highers_points_scores         => NULL,
                                x_occupation_code               => NULL,
                                x_commencement_dt               => NULL,
                                x_special_student               => NULL ,
                                x_student_qual_aim              => NULL ,
                                x_student_fe_qual_aim           => NULL ,
                                x_teacher_train_prog_id         => NULL ,
                                x_itt_phase                     => NULL,
                                x_bilingual_itt_marker          => NULL,
                                x_teaching_qual_gain_sector     => NULL,
                                x_teaching_qual_gain_subj1      => NULL,
                                x_teaching_qual_gain_subj2      => NULL,
                                x_teaching_qual_gain_subj3      => NULL,
                                x_student_inst_number           => v_student_inst_number,
                                x_destination                   => NULL,
                                x_itt_prog_outcome              => NULL,
                                x_hesa_return_name              => NULL,
                                x_hesa_return_id                => NULL,
                                x_hesa_submission_name          => NULL,
                                x_associate_ucas_number         => NULL,
                                x_associate_scott_cand          => NULL,
                                x_associate_teach_ref_num       => NULL,
                                x_associate_nhs_reg_num         => NULL,
                                x_nhs_funding_source            => NULL ,
                                x_ufi_place                     => NULL,
                                x_postcode                      => NULL ,
                                x_social_class_ind              => NULL ,
                                x_occcode                       => NULL ,
                                x_total_ucas_tariff             => NULL,
                                x_nhs_employer                  => NULL ,
                                x_return_type                   => NULL,
                                x_qual_aim_subj1                => NULL,
                                x_qual_aim_subj2                => NULL,
                                x_qual_aim_subj3                => NULL,
                                x_qual_aim_proportion           => NULL,
                                x_exclude_flag                  => NULL,
                                x_mode                          => 'R' );

      -- create the SPA record for the new program attempt
      -- check condition for Student Instance Number ,
      -- if a the HESA qual aim  is different or the two programs are not a continuous study then it is considered
      -- as a different qualification aim ,clarified by SARA
      -- smaddali added the check to copy student instance number when the two programs are a continuous study ,Build HEFD209 bug#2717755
      IF  v_old_hesa_qual_map1 =  v_new_hesa_qual_map1 OR l_cont_progs THEN
         --copy value from old spa record created above to new record.
         v_student_inst_number  := v_student_inst_number;
      ELSE
        -- Derive the student instance number value and use this value while creating
        -- new record in igs_he_st_spa_all table, added as per
        -- HECR008-alpha numeric student instance number CR
         l_std_inst_num := 1;
         FOR cur_std_inst_num_rec IN cur_std_inst_num(p_person_id) LOOP
            BEGIN
              IF NVL(TO_NUMBER(cur_std_inst_num_rec.student_inst_number),0) >= l_std_inst_num THEN
                l_std_inst_num := TO_NUMBER(cur_std_inst_num_rec.Student_inst_number) + 1;
              END IF;
              EXCEPTION
              WHEN VALUE_ERROR THEN
              NULL;
            END ;
         END LOOP;
           v_student_inst_number := l_std_inst_num;
      END IF;

            v_rowid                   := NULL ;
            v_hesa_st_spa_id          := NULL ;

            igs_he_st_spa_all_pkg.insert_row(
                                x_rowid                         => v_rowid,
                                x_hesa_st_spa_id                => v_hesa_st_spa_id,
                                x_org_id                        => v_org_id,
                                x_person_id                     => p_person_id,
                                x_course_cd                     => p_new_course_cd,
                                x_version_number                => v_u_new_version_number,
                                x_fe_student_marker             => NULL,
                                x_domicile_cd                   => NULL,
                                x_inst_last_attended            => NULL,
                                x_year_left_last_inst           => NULL,
                                x_highest_qual_on_entry         => NULL,
                                x_date_qual_on_entry_calc       => NULL,
                                x_a_level_point_score           => NULL,
                                x_highers_points_scores         => NULL,
                                x_occupation_code               => NULL,
                                x_commencement_dt               => NULL,
                                x_special_student               => NULL ,
                                x_student_qual_aim              => NULL ,
                                x_student_fe_qual_aim           => NULL ,
                                x_teacher_train_prog_id         => NULL ,
                                x_itt_phase                     => NULL,
                                x_bilingual_itt_marker          => NULL,
                                x_teaching_qual_gain_sector     => NULL,
                                x_teaching_qual_gain_subj1      => NULL,
                                x_teaching_qual_gain_subj2      => NULL,
                                x_teaching_qual_gain_subj3      => NULL,
                                x_student_inst_number           => v_student_inst_number,
                                x_destination                   => NULL,
                                x_itt_prog_outcome              => NULL,
                                x_hesa_return_name              => NULL,
                                x_hesa_return_id                => NULL,
                                x_hesa_submission_name          => NULL,
                                x_associate_ucas_number         => NULL,
                                x_associate_scott_cand          => NULL,
                                x_associate_teach_ref_num       => NULL,
                                x_associate_nhs_reg_num         => NULL,
                                x_nhs_funding_source            => NULL ,
                                x_ufi_place                     => NULL,
                                x_postcode                      => NULL ,
                                x_social_class_ind              => NULL ,
                                x_occcode                       => NULL ,
                                x_total_ucas_tariff             => NULL,
                                x_nhs_employer                  => NULL ,
                                x_return_type                   => NULL,
                                x_qual_aim_subj1                => NULL,
                                x_qual_aim_subj2                => NULL,
                                x_qual_aim_subj3                => NULL,
                                x_qual_aim_proportion           => NULL,
                                x_exclude_flag                  => NULL,
                                x_mode                          => 'R');

   ELSE --  if old spa record exists then copy old uk statistics details to the new spa record

      CLOSE c_old_spa;

     -- check condition for Student Instance Number
     -- smaddali added the check to copy student instance number when the two programs
     -- are a continuous study ,Build HEFD209 bug#2717755
     IF v_old_hesa_qual_map1 = v_new_hesa_qual_map1 OR l_cont_progs  THEN
        --copy value from old record to new record.
        v_student_inst_number   := c_old_spa_rec.student_inst_number;
     ELSE
        -- Derive the student instance number value and use this value while creating
        -- new record in igs_he_st_spa_all table, added as per
        -- HECR008-alpha numeric student instance number CR
            l_std_inst_num := 1;
           FOR cur_std_inst_num_rec IN cur_std_inst_num(p_person_id) LOOP
             BEGIN
              IF NVL(TO_NUMBER(cur_std_inst_num_rec.student_inst_number),0) >= l_std_inst_num THEN
                l_std_inst_num := TO_NUMBER(cur_std_inst_num_rec.Student_inst_number) + 1;
              END IF;
              EXCEPTION
                WHEN VALUE_ERROR THEN
                 NULL;
             END ;
           END LOOP;
          v_student_inst_number := l_std_inst_num ;
     END IF;

     --check condition for commencment date, fe student marker, domicile_cd, postcode,
     --special student, social class, occupation code, old structure occupation code,
     --NHS funding source, general qualification aim, fe general qualification aim.
     -- smaddali added new check "or both programs are a continuous study" for HEFD209 build , bug2717755
     IF v_old_hesa_qual_map1 = v_new_hesa_qual_map1 OR l_cont_progs THEN
               --copy value from old fields to new fields.
               v_commencement_dt        := c_old_spa_rec.commencement_dt;
               v_domicile_cd            := c_old_spa_rec.domicile_cd;
               v_postcode               := c_old_spa_rec.postcode;
               v_social_class_ind       := c_old_spa_rec.social_class_ind;
               v_occupation_code        := c_old_spa_rec.occupation_code;
               v_occcode                := c_old_spa_rec.occcode;
               --smaddali added code to transfer highest_qual_on_entry,total_ucas_tariff field ,bug 2728756
               v_highest_qual_on_entry  := c_old_spa_rec.highest_qual_on_entry ;
               v_total_ucas_tariff      := c_old_spa_rec.total_ucas_tariff ;
     END IF ;

     IF v_old_hesa_qual_map1 = v_new_hesa_qual_map1 THEN

         v_fe_student_marker            := c_old_spa_rec.fe_student_marker;
         v_special_student              := c_old_spa_rec.special_student;
         v_nhs_funding_source           := c_old_spa_rec.nhs_funding_source;
         v_student_qual_aim             := c_old_spa_rec.student_qual_aim;
         v_student_fe_qual_aim          := c_old_spa_rec.student_fe_qual_aim;

        --extra check for teacher_train_prog_id
        -- if hesa code of the qualification aim is 12,13or 20 then copy teacher train prog id
         -- fetch hesa code mapeed to the oss qualification aim value, required for validating teacher_train_prog_id
         v_teach_map1                   := NULL ;
         OPEN teach_map( c_old_spa_rec.teacher_train_prog_id ) ;
         FETCH teach_map INTO v_teach_map1;
         CLOSE teach_map;

         IF v_teach_map1 IN ('12','13','20') THEN

             --copy value from old field to new field
             v_teacher_train_prog_id    := c_old_spa_rec.teacher_train_prog_id;

         END IF;

        IF v_old_tmp_prgfldstudy = v_new_tmp_prgfldstudy THEN

               v_qual_aim_subj1      := c_old_spa_rec.qual_aim_subj1    ;
               v_qual_aim_subj2      := c_old_spa_rec.qual_aim_subj2 ;
               v_qual_aim_subj3      := c_old_spa_rec.qual_aim_subj3;
               v_qual_aim_proportion := c_old_spa_rec.qual_aim_proportion ;

       END IF;


     END IF; -- if old program's qualification aim is same as that of new program

     --Insert Values Into Record
     igs_he_st_spa_all_pkg.insert_row(
                                x_rowid                         => v_rowid,
                                x_hesa_st_spa_id                => v_hesa_st_spa_id,
                                x_org_id                        => v_org_id,
                                x_person_id                     => p_person_id,
                                x_course_cd                     => p_new_course_cd,
                                x_version_number                => v_u_new_version_number,
                                x_fe_student_marker             => v_fe_student_marker,
                                x_domicile_cd                   => v_domicile_cd,
                                x_inst_last_attended            => NULL,
                                x_year_left_last_inst           => NULL,
                                x_highest_qual_on_entry         => v_highest_qual_on_entry,
                                x_date_qual_on_entry_calc       => NULL,
                                x_a_level_point_score           => NULL,
                                x_highers_points_scores         => NULL,
                                x_occupation_code               => v_occupation_code,
                                x_commencement_dt               => v_commencement_dt,
                                x_special_student               => v_special_student,
                                x_student_qual_aim              => v_student_qual_aim,
                                x_student_fe_qual_aim           => v_student_fe_qual_aim,
                                x_teacher_train_prog_id         => v_teacher_train_prog_id,
                                x_itt_phase                     => NULL,
                                x_bilingual_itt_marker          => NULL,
                                x_teaching_qual_gain_sector     => NULL,
                                x_teaching_qual_gain_subj1      => NULL,
                                x_teaching_qual_gain_subj2      => NULL,
                                x_teaching_qual_gain_subj3      => NULL,
                                x_student_inst_number           => v_student_inst_number,
                                x_destination                   => NULL,
                                x_itt_prog_outcome              => NULL,
                                x_hesa_return_name              => NULL,
                                x_hesa_return_id                => NULL,
                                x_hesa_submission_name          => NULL,
                                x_associate_ucas_number         => NULL,
                                x_associate_scott_cand          => NULL,
                                x_associate_teach_ref_num       => NULL,
                                x_associate_nhs_reg_num         => NULL,
                                x_nhs_funding_source            => v_nhs_funding_source,
                                x_ufi_place                     => c_old_spa_rec.ufi_place,
                                x_postcode                      => v_postcode,
                                x_social_class_ind              => v_social_class_ind,
                                x_occcode                       => v_occcode,
                                x_total_ucas_tariff             => v_total_ucas_tariff,
                                x_nhs_employer                  => c_old_spa_rec.nhs_employer,
                                x_return_type                   => NULL,
                                x_qual_aim_subj1                => v_qual_aim_subj1,
                                x_qual_aim_subj2                => v_qual_aim_subj2,
                                x_qual_aim_subj3                => v_qual_aim_subj3,
                                x_qual_aim_proportion           => v_qual_aim_proportion,
                                x_exclude_flag                  => NULL,
                                x_mode                          => 'R');

      -- CREATE UCAS TARIFF RECORD
      -- Fetch Old Values into Variables.
      -- smaddali added new check "or both programs are a continuous study" for HEFD209 build , bug2717755
      IF v_old_hesa_qual_map1 = v_new_hesa_qual_map1 OR l_cont_progs THEN

         OPEN ucas_tariff;
         LOOP
             FETCH ucas_tariff INTO v_qualification_level,
                                v_number_of_qual,
                                v_tariff_score;
             EXIT WHEN ucas_tariff%NOTFOUND;

             --Insert Values into Record
             igs_he_st_spa_ut_all_pkg.insert_row(
                                          x_rowid               => v_ut_rowid,
                                          x_hesa_st_spau_id     => v_hesa_st_spau_id,
                                          x_org_id              => v_org_id,
                                          x_person_id           => p_person_id,
                                          x_course_cd           => p_new_course_cd,
                                          x_version_number      => v_u_new_version_number,
                                          x_qualification_level => v_qualification_level,
                                          x_number_of_qual      => v_number_of_qual,
                                          x_tariff_score        => v_tariff_score,
                                          x_mode                => 'R' );
         END LOOP;
         CLOSE ucas_tariff;
      END IF; -- if old qualification aim is equal to the new qualification aim

    END IF; -- if old UK statistics record found

    -- CREATE THE UK STATISTICS COST CENTRE - SPA RECORD

    -- Loop through all the records in IGS_HE_ST_SPA_CC table for the old program attempt
    -- and insert if the record does not exist for new Program Attempt
    FOR old_spa_cc_dtls_rec IN old_spa_cc_dtls_cur( p_person_id, p_old_course_cd ) LOOP

       OPEN new_spa_cc_dtls_cur( p_person_id, p_new_course_cd,
                                old_spa_cc_dtls_rec.cost_centre, old_spa_cc_dtls_rec.subject );
       FETCH new_spa_cc_dtls_cur INTO l_dummy;
       IF new_spa_cc_dtls_cur%NOTFOUND THEN

          -- create the new student program attempt cost centre record
          igs_he_st_spa_cc_pkg.insert_row (
            x_rowid            => l_rowid,
            x_he_spa_cc_id     => l_he_spa_cc_id,
            x_person_id        => p_person_id,
            x_course_cd        => p_new_course_cd,
            x_cost_centre      => old_spa_cc_dtls_rec.cost_centre,
            x_subject          => old_spa_cc_dtls_rec.subject,
            x_proportion       => old_spa_cc_dtls_rec.proportion,
            x_mode             => 'R' );

       END IF;
       CLOSE new_spa_cc_dtls_cur;

    END LOOP;

 EXCEPTION
 WHEN OTHERS THEN
   ROLLBACK;
   p_status := 2;
   fnd_message.set_name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
   fnd_message.set_token('NAME','IGS_HE_PROG_TRANSFER_PKG.HESA_STUD_STAT_TRANS');
   igs_ge_msg_stack.add;
   RETURN;

END hesa_stud_stat_trans;

END igs_he_prog_transfer_pkg;


/
