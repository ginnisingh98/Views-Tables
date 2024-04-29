--------------------------------------------------------
--  DDL for Package Body IGS_AD_ACAD_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_ACAD_HISTORY_PKG" AS
/* $Header: IGSAI81B.pls 120.10 2006/05/30 11:50:09 arvsrini ship $ */
  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_education_id                      OUT NOCOPY    NUMBER,
    x_person_id                         IN     NUMBER,
    x_current_inst                      IN     VARCHAR2,
    x_degree_attempted            IN     VARCHAR2,
    x_program_code                      IN     VARCHAR2,
    x_degree_earned		IN     VARCHAR2,
    x_comments                          IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_planned_completion_date           IN     DATE,
    x_recalc_total_cp_attempted         IN     NUMBER,
    x_recalc_total_cp_earned            IN     NUMBER,
    x_recalc_total_unit_gp              IN     NUMBER,
    x_recalc_tot_gpa_units_attemp       IN     NUMBER,
    x_recalc_inst_gpa                   IN     VARCHAR2,
    x_recalc_grading_scale_id           IN     NUMBER,
    x_selfrep_total_cp_attempted        IN     NUMBER,
    x_selfrep_total_cp_earned           IN     NUMBER,
    x_selfrep_total_unit_gp             IN     NUMBER,
    X_selfrep_tot_gpa_uts_attemp	IN     NUMBER,
    x_selfrep_inst_gpa                  IN     VARCHAR2,
    x_selfrep_grading_scale_id          IN     NUMBER,
    x_selfrep_weighted_gpa              IN     VARCHAR2,
    x_selfrep_rank_in_class             IN     NUMBER,
    x_selfrep_weighed_rank              IN     VARCHAR2,
    x_type_of_school                    IN     VARCHAR2,
    x_institution_code			IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_selfrep_class_size                IN     NUMBER DEFAULT NULL,
    x_transcript_required               IN     VARCHAR2 DEFAULT NULL,
    x_school_party_id                   IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_object_version_number             OUT NOCOPY    NUMBER,
    x_msg_data				OUT NOCOPY	   VARCHAR2,
    x_return_status			OUT NOCOPY	   VARCHAR2,
    x_mode                              IN     VARCHAR2    ,
    x_school_attended_name     IN VARCHAR2  DEFAULT NULL,
    x_program_type_attempted   IN VARCHAR2  ,
    x_program_type_earned      IN VARCHAR2
  )
 AS
 l_education_rec   					HZ_PERSON_INFO_V2PUB.EDUCATION_REC_TYPE;
 lv_return_status					VARCHAR2(1);
 lv_msg_count						NUMBER;
 lv_msg_data						VARCHAR2(200);
 lv_education_id					NUMBER;
 lv_Hz_Acad_Hist_Id					NUMBER;
 l_RowId						VARCHAR2(25);
 lv_institution_code					HZ_PARTIES.party_number%TYPE;
 l_mode VARCHAR2(1);

   CURSOR c_school_party_id (p_party_number hz_parties.party_number%TYPE) IS
    SELECT party_id
    FROM   igs_pe_hz_parties
    WHERE  oss_org_unit_cd = p_party_number;

   CURSOR c_school_attended_name  (p_party_number hz_parties.party_number%TYPE) IS
    SELECT party_name
    FROM   hz_parties hz, igs_pe_hz_parties php
    WHERE  php.oss_org_unit_cd = p_party_number
    AND php.party_id = hz.party_id ;

    CURSOR c_degree_code  (p_degree hz_education.degree_received%TYPE) IS
    SELECT    dg.degree_cd
    FROM       igs_ps_degrees dg,
               igs_ps_type_all ps
    WHERE   dg.degree_cd = p_degree
    AND dg.closed_ind  ='N'
    AND dg.program_type = ps.course_type;

    CURSOR get_dob_dt_cur(p_person_id igs_pe_hz_parties.party_id%TYPE)
    IS
    SELECT birth_date
    FROM  igs_pe_person_base_v
    WHERE person_id = p_person_id;

    tmp_var1          VARCHAR2(2000);
    tmp_var           VARCHAR2(2000);
    lv_school_party_id     hz_education.school_party_id%TYPE;
    lv_school_attended_name hz_parties.party_name%TYPE;
    lv_degree  hz_education.degree_received%TYPE;
    l_birth_dt igs_pe_person_base_v.birth_date%TYPE;
  /*
  ||  Created By : Ramesh.Rengarajan@Oracle.Com
  ||  Created On : 07-SEP-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || samaresh.in      20-NOV-2001   Added a Check to see if
  ||                                current institution already exists
  ||                                for the person id
  || vdixit.in	      23-JULY-2001  Added new column transcript_required
  ||					to the tbh calls
  || pkpatel          30-Jun-2005   Bug 4327807 (Person SS Enhancement)
  ||                                Removed the check for single current institution. Multiple current institutions will be allowed.
  ||                                Removed the cursor to get the object version number. In insert its not needed.
  */
  BEGIN
  l_mode := NVL(x_mode ,'R');

    lv_school_party_id := x_school_party_id;
    l_education_rec.education_id         := NULL;
    l_education_rec.course_major         := x_Program_Code;
    l_education_rec.last_date_attended   :=  x_End_Date;
    l_education_rec.type_of_school       :=    x_type_of_School;
    l_education_rec.party_id             :=  x_person_id;
    l_education_rec.start_date_attended  := x_Start_Date;
    l_education_rec.Degree_received	 := x_degree_earned;
    l_education_rec.school_attended_name := NULL ;
    l_education_rec.status               := NVL(x_status,'A');
    l_education_rec.created_by_module    := 'IGS';
    l_education_rec.application_id       := NULL;

    --For UK Degree Earned and Degree Attempted should be null
    IF NVL(FND_PROFILE.VALUE('OSS_COUNTRY_CODE'),'*') = 'GB'
       AND (x_degree_attempted IS NOT NULL
            OR x_degree_earned IS NOT NULL
            OR x_program_code IS NOT NULL) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_AD_GB_ACAD_HIST');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF  x_school_attended_name IS NOT NULL THEN
      OPEN c_school_attended_name(x_institution_code);
       FETCH c_school_attended_name INTO   lv_school_attended_name;
       CLOSE c_school_attended_name;
       IF lv_school_attended_name <> x_school_attended_name THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_AD_INVALID_INST');
          IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
       END IF;
    END IF;

   --Validate Degree Earned
    IF  x_degree_earned IS NOT NULL THEN
      OPEN c_degree_code(x_degree_earned);
       lv_degree := NULL;
       FETCH c_degree_code INTO   lv_degree;
       CLOSE c_degree_code;
       IF lv_degree IS NULL THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_AD_INVALID_DEG_EARNED');
          IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
       END IF;
    END IF;

     --Validate Degree Attempted
    IF  x_degree_attempted IS NOT NULL THEN
      OPEN c_degree_code(x_degree_attempted);
       lv_degree := NULL;
       FETCH c_degree_code INTO   lv_degree;
       CLOSE c_degree_code;
       IF lv_degree IS NULL THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_AD_INVALID_DEG_ATTEMPTED');
          IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
       END IF;
    END IF;

    -- Validate Start Date and End Date
    IF x_start_date IS NOT NULL AND x_end_date IS NOT NULL THEN
	  IF x_end_date < x_start_date THEN
		FND_MESSAGE.SET_NAME ('IGS', 'IGS_GE_INVALID_DATE');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
	  END IF;
	END IF;

     --Validate Degree Earned earlier than Date of Birth
    IF  x_start_date IS NOT NULL THEN
	OPEN get_dob_dt_cur(x_person_id);
	FETCH get_dob_dt_cur INTO l_birth_dt;
	CLOSE get_dob_dt_cur;
		IF l_birth_dt IS NOT NULL AND l_birth_dt > l_education_rec.start_date_attended THEN
		FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_STRT_DT_LESS_BIRTH_DT');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
    END IF;

     --Validate Degree Earned earlier than Date of Birth
    IF  x_start_date IS NOT NULL OR x_end_date IS NOT NULL THEN

        OPEN get_dob_dt_cur(x_person_id);
        FETCH get_dob_dt_cur INTO l_birth_dt;
        CLOSE get_dob_dt_cur;
        IF l_birth_dt IS NOT NULL AND x_start_date IS NOT NULL AND l_birth_dt > x_start_date THEN
                FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_STRT_DT_LESS_BIRTH_DT');
                IGS_GE_MSG_STACK.ADD;
                APP_EXCEPTION.RAISE_EXCEPTION;
         END IF;

	    IF l_birth_dt IS NOT NULL AND x_end_date IS NOT NULL AND l_birth_dt > x_end_date THEN
                FND_MESSAGE.SET_NAME ('IGS', 'IGS_PE_ENDDT_LESS_BIRTHDT');
                IGS_GE_MSG_STACK.ADD;
                APP_EXCEPTION.RAISE_EXCEPTION;
         END IF;
    END IF;

    --If institution_code is passed then
     IF ( x_school_party_id is NULL
	  AND x_institution_code IS NOT NULL ) THEN
       OPEN c_school_party_id(x_institution_code);
       FETCH c_school_party_id INTO   lv_school_party_id ;
       CLOSE c_school_party_id;
     END IF;
     l_education_rec.school_party_id      := lv_school_party_id;

      hz_person_info_v2pub.create_education(
        p_init_msg_list =>  FND_API.G_TRUE,
        p_education_rec => l_education_rec,
        x_return_status  => lv_return_status,
        x_msg_count   => lv_msg_count,
        x_msg_data => lv_msg_data,
        x_education_id => lv_education_id );

      x_education_id := lv_education_id;

     IF lv_return_Status IN ('E','U') THEN
        -- bug 2338473 logic to display more than one error modified.
      IF lv_msg_count > 1 THEN
            FOR i IN 1..lv_msg_count  LOOP
              tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
              tmp_var1 := tmp_var1 || ' '|| tmp_var;
            END LOOP;
           x_msg_data := tmp_var1;
	   x_return_status :=lv_return_status;
      END IF;
      RETURN;
     ELSE
       Igs_Ad_Hz_Acad_Hist_Pkg.Insert_Row
   	( X_ROWID  => l_RowId,
    	  X_RECALC_TOTAL_CP_ATTEMPTED    => X_RECALC_TOTAL_CP_ATTEMPTED,
 	  X_RECALC_TOTAL_CP_EARNED       => X_RECALC_TOTAL_CP_EARNED,
 	  X_RECALC_TOTAL_UNIT_GP         => X_RECALC_TOTAL_UNIT_GP,
 	  X_RECALC_TOT_GPA_UTS_ATTEMPTED => x_recalc_tot_gpa_units_attemp,
 	  X_RECALC_INST_GPA              => X_RECALC_INST_GPA,
 	  X_RECALC_GRADING_SCALE_ID      => X_RECALC_GRADING_SCALE_ID,
 	  X_SELFREP_TOTAL_CP_ATTEMPTED   => X_SELFREP_TOTAL_CP_ATTEMPTED,
 	  X_SELFREP_TOTAL_CP_EARNED      => X_SELFREP_TOTAL_CP_EARNED,
 	  X_SELFREP_TOTAL_UNIT_GP        => X_SELFREP_TOTAL_UNIT_GP,
 	  X_SELFREP_TOT_GPA_UTS_ATTEMP   => X_SELFREP_TOT_GPA_UTS_ATTEMP,
 	  X_SELFREP_INST_GPA             => X_SELFREP_INST_GPA,
 	  X_SELFREP_GRADING_SCALE_ID     => X_SELFREP_GRADING_SCALE_ID,
 	  X_SELFREP_WEIGHTED_GPA         => X_SELFREP_WEIGHTED_GPA,
 	  X_SELFREP_RANK_IN_CLASS        => X_SELFREP_RANK_IN_CLASS,
 	  X_SELFREP_WEIGHED_RANK         => X_SELFREP_WEIGHED_RANK,
 	  X_ATTRIBUTE_CATEGORY           => X_ATTRIBUTE_CATEGORY,
	  X_SELFREP_CLASS_SIZE           => X_SELFREP_CLASS_SIZE,
 	  X_ATTRIBUTE1                   => X_ATTRIBUTE1,
 	  X_ATTRIBUTE2                   => X_ATTRIBUTE2,
 	  X_ATTRIBUTE3                   => X_ATTRIBUTE3,
 	  X_ATTRIBUTE4                   => X_ATTRIBUTE4,
 	  X_ATTRIBUTE5                   => X_ATTRIBUTE5,
 	  X_ATTRIBUTE6                   => X_ATTRIBUTE6,
 	  X_ATTRIBUTE7                   => X_ATTRIBUTE7,
 	  X_ATTRIBUTE8                   => X_ATTRIBUTE8,
 	  X_ATTRIBUTE9                   => X_ATTRIBUTE9,
 	  X_ATTRIBUTE10                  => X_ATTRIBUTE10,
 	  X_ATTRIBUTE11                  => X_ATTRIBUTE11,
 	  X_ATTRIBUTE12                  => X_ATTRIBUTE12,
 	  X_ATTRIBUTE13                  => X_ATTRIBUTE13,
 	  X_ATTRIBUTE14                  => X_ATTRIBUTE14,
 	  X_ATTRIBUTE15                  => X_ATTRIBUTE15,
 	  X_ATTRIBUTE16                  => X_ATTRIBUTE16,
 	  X_ATTRIBUTE17                  => X_ATTRIBUTE17,
 	  X_ATTRIBUTE18                  => X_ATTRIBUTE18,
 	  X_ATTRIBUTE19                  => X_ATTRIBUTE19,
 	  X_ATTRIBUTE20                  => X_ATTRIBUTE20,
 	  X_HZ_ACAD_HIST_ID              =>  lv_Hz_Acad_Hist_Id,
 	  X_EDUCATION_ID                 =>   lv_Education_Id,
 	  X_CURRENT_INST                 =>  X_CURRENT_INST,
 	  X_DEGREE_ATTEMPTED             => X_DEGREE_ATTEMPTED,
 	  X_COMMENTS                     => X_COMMENTS,
 	  X_PLANNED_COMPLETION_DATE      => X_PLANNED_COMPLETION_DATE,
          X_TRANSCRIPT_REQUIRED	       => X_TRANSCRIPT_REQUIRED	,
 	  X_MODE                         => 'R');
    	  --x_rowid := l_rowId; This line is removed as part of Bug-4089200 fix
     END IF;
-- raise the business event
   igs_ad_wf_001.ACADHIST_CRT_EVENT
   (
      P_HZ_ACAD_HIST_ID   => lv_Hz_Acad_Hist_Id,
      P_EDUCATION_ID => lv_Education_Id,
      P_PERSON_ID    => x_person_id,
      P_ACTIVE_IND   => NVL(x_status,'A'),
      P_REQUIRED_IND    => x_transcript_required
   );

  END insert_row;

 PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_education_id                      IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_current_inst                      IN     VARCHAR2,
    x_degree_attempted            IN     VARCHAR2,
    x_program_code                      IN     VARCHAR2,
    x_degree_earned		IN     VARCHAR2,
    x_comments                          IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_planned_completion_date           IN     DATE,
    x_recalc_total_cp_attempted         IN     NUMBER,
    x_recalc_total_cp_earned            IN     NUMBER,
    x_recalc_total_unit_gp              IN     NUMBER,
    x_recalc_tot_gpa_units_attemp       IN     NUMBER,
    x_recalc_inst_gpa                   IN     VARCHAR2,
    x_recalc_grading_scale_id           IN     NUMBER,
    x_selfrep_total_cp_attempted        IN     NUMBER,
    x_selfrep_total_cp_earned           IN     NUMBER,
    x_selfrep_total_unit_gp             IN     NUMBER,
    x_selfrep_tot_gpa_uts_attemp	IN     NUMBER,
    x_selfrep_inst_gpa                  IN     VARCHAR2,
    x_selfrep_grading_scale_id          IN     NUMBER,
    x_selfrep_weighted_gpa              IN     VARCHAR2,
    x_selfrep_rank_in_class             IN     NUMBER,
    x_selfrep_weighed_rank              IN     VARCHAR2,
    x_type_of_school                    IN     VARCHAR2,
    x_institution_code			IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_selfrep_class_size                IN     NUMBER DEFAULT NULL,
    x_transcript_required               IN     VARCHAR2 DEFAULT NULL,
    x_school_party_id                   IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_object_version_number             IN OUT NOCOPY    NUMBER,
    x_msg_data				OUT NOCOPY    VARCHAR2,
    x_return_status			OUT NOCOPY    VARCHAR2,
    x_mode                              IN     VARCHAR2   ,
    x_school_attended_name     IN VARCHAR2  DEFAULT NULL,
    x_program_type_attempted   IN VARCHAR2  ,
    x_program_type_earned      IN VARCHAR2
  ) AS
  /*
  ||  Created By : Ramesh.Rengarajan@Oracle.Com
  ||  Created On : 07-SEP-2000
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||
  || apadegal.in      10-Jun-2005   Modified the validation logic for
  ||                                UK Degree Earned and Degree Attempted
  ||
  || samaresh.in      20-NOV-2001   Added a Check to see if
  ||                                current institution already exists
  ||                                for the person id
  || vdixit.in	      23-JULY-2001  Added new column transcript_required
  ||					to the tbh calls
  || pkpatel          30-Jun-2005   Bug 4327807 (Person SS Enhancement)
  ||                                Removed the check for single current institution. Multiple current institutions will be allowed.
  ||                                Removed the cursor to get the Created_By_Module. In update no need to pass it.
  ||
  */

  l_education_rec   					hz_person_info_v2pub.education_rec_type;
  lv_return_status					VARCHAR2(1);
  lv_msg_count						NUMBER;
  lv_msg_data						VARCHAR2(200);
  lv_education_id					NUMBER;
  lv_Hz_Acad_Hist_Id					NUMBER;
  l_RowId						VARCHAR2(25);
  lv_institution_code					HZ_PARTIES.party_number%TYPE;
  lv_created_by_module                                  VARCHAR2(255);
  tmp_var1          VARCHAR2(2000);
  tmp_var           VARCHAR2(2000);
  l_mode VARCHAR2(1);
 -- variable added by ravishar
  l_active_ind  VARCHAR2(1);
  l_transcript_required_old VARCHAR2(1);

--new cursor to get old active indicator
  CURSOR c_old_active_ind(cp_rowid IN VARCHAR2) IS
    SELECT status,TRANSCRIPT_REQUIRED from IGS_AD_ACAD_HISTORY_V
    WHERE row_id = cp_rowid;

  CURSOR C1 IS
     SELECT  ROWID, HZ_ACAD_HIST_ID
     FROM IGS_AD_HZ_ACAD_HIST
     WHERE EDUCATION_ID = x_Education_Id;

   CURSOR c_school_party_id (p_party_number hz_parties.party_number%TYPE) IS
    SELECT party_id
    FROM   igs_pe_hz_parties
    WHERE  oss_org_unit_cd = p_party_number;

   CURSOR c_school_attended_name  (p_party_number hz_parties.party_number%TYPE) IS
    SELECT party_name
    FROM   hz_parties hz, igs_pe_hz_parties php
    WHERE  php.oss_org_unit_cd = p_party_number
    AND php.party_id = hz.party_id ;

    CURSOR c_adv_standing  ( p_party_number hz_parties.party_number%TYPE,  p_person_id  hz_parties.party_id%TYPE) IS
    SELECT '1'
    FROM  igs_av_adv_standing
    WHERE person_id = p_person_id
    AND   exemption_institution_cd = p_party_number;

    CURSOR c_degree_code  (p_degree hz_education.degree_received%TYPE) IS
    SELECT    dg.degree_cd
    FROM       igs_ps_degrees dg
    WHERE   dg.degree_cd = p_degree
    AND dg.closed_ind  ='N'
    AND dg.program_type IS NOT NULL;

    CURSOR c_old_references IS
    SELECT degree_attempted, degree_earned, program_code
    FROM IGS_AD_ACAD_HISTORY_V ach
    WHERE ach.education_id = x_education_id;

    CURSOR get_dob_dt_cur(p_person_id igs_pe_hz_parties.party_id%TYPE)
    IS
    SELECT birth_date
    FROM  igs_pe_person_base_v
    WHERE person_id = p_person_id;

    --jchin Bug 4629226 - Cursor added to check external transcripts

    CURSOR cur_check_external(p_education_id igs_ad_acad_history_v.education_id%TYPE)
    IS
    SELECT DISTINCT 1
    FROM igs_ad_transcript_v trans, igs_ad_code_classes code
    WHERE trans.transcript_source = code.code_id
    AND trans.education_id = p_education_id
    AND code.class = 'TRANSCRIPT_SOURCE'
    AND code.class_type_code = 'ADM_CODE_CLASSES'
    AND code.system_status = 'THIRD_PARTY_TRANSFER_EVAL';


    old_degree_attempted  IGS_AD_ACAD_HISTORY_V.degree_attempted%TYPE;
    old_degree_earned     IGS_AD_ACAD_HISTORY_V.degree_earned%TYPE;
    old_program_code      IGS_AD_ACAD_HISTORY_V.program_code%TYPE;

    lv_adv_standing_exists      VARCHAR2(1) := NULL ;
    lv_school_attended_name hz_parties.party_name%TYPE;
    lv_school_party_id     hz_education.school_party_id%TYPE ;
    lv_degree  hz_education.degree_received%TYPE;
    l_birth_dt igs_pe_person_base_v.birth_date%TYPE;

    l_count NUMBER; --jchin Bug 4629226

  BEGIN

   l_mode := NVL(x_mode,'R');

    lv_school_party_id := x_school_party_id;
    --For UK Degree Earned and Degree Attempted should be null

    OPEN  c_old_references;
    FETCH c_old_references INTO old_degree_attempted,old_degree_earned,old_program_code;
    CLOSE c_old_references;

    IF NVL(FND_PROFILE.VALUE('OSS_COUNTRY_CODE'),'*') = 'GB'
       AND (   nvl(old_degree_attempted,'NulL')   <> nvl(x_degree_attempted,'NulL') or
               nvl(old_degree_earned,'NulL')      <> nvl(x_degree_earned,'NulL') or
               nvl(old_program_code,'NulL')       <> nvl(x_program_code,'NulL')
           )
    THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_AD_GB_ACAD_HIST');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;


    IF  x_school_attended_name IS NOT NULL AND x_institution_code IS NOT NULL THEN
      OPEN c_school_attended_name(x_institution_code);
       FETCH c_school_attended_name INTO   lv_school_attended_name;
       CLOSE c_school_attended_name;
       IF lv_school_attended_name <> x_school_attended_name THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_AD_INVALID_INST');
          IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
       END IF;
    END IF;

   --Validate Degree Earned
    IF  x_degree_earned IS NOT NULL THEN
      OPEN c_degree_code(x_degree_earned);
       lv_degree := NULL;
       FETCH c_degree_code INTO   lv_degree;
       CLOSE c_degree_code;
       IF lv_degree IS NULL THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_AD_INVALID_DEGREE_EARNED');
          IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
       END IF;
    END IF;

    -- Validate Start Date and End Date
    IF x_start_date IS NOT NULL AND x_end_date IS NOT NULL THEN
	  IF x_end_date < x_start_date THEN
		FND_MESSAGE.SET_NAME ('IGS', 'IGS_GE_INVALID_DATE');
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
	  END IF;
	END IF;

     --Validate Degree Earned earlier than Date of Birth
    IF  x_start_date IS NOT NULL OR x_end_date IS NOT NULL THEN

        OPEN get_dob_dt_cur(x_person_id);
        FETCH get_dob_dt_cur INTO l_birth_dt;
        CLOSE get_dob_dt_cur;
        IF l_birth_dt IS NOT NULL AND x_start_date IS NOT NULL AND l_birth_dt > x_start_date THEN
                FND_MESSAGE.SET_NAME ('IGS', 'IGS_AD_STRT_DT_LESS_BIRTH_DT');
                IGS_GE_MSG_STACK.ADD;
                APP_EXCEPTION.RAISE_EXCEPTION;
         END IF;

	    IF l_birth_dt IS NOT NULL AND x_end_date IS NOT NULL AND l_birth_dt > x_end_date THEN
                FND_MESSAGE.SET_NAME ('IGS', 'IGS_PE_ENDDT_LESS_BIRTHDT');
                IGS_GE_MSG_STACK.ADD;
                APP_EXCEPTION.RAISE_EXCEPTION;
         END IF;
    END IF;

    --Validate Degree Attempted
    IF  x_degree_attempted IS NOT NULL THEN
      OPEN c_degree_code(x_degree_attempted);
       lv_degree := NULL;
       FETCH c_degree_code INTO   lv_degree;
       CLOSE c_degree_code;
       IF lv_degree IS NULL THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_AD_INVALID_DEGREE_ATTEMPTED');
          IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
       END IF;
    END IF;

    IF  x_status = 'I' THEN
      OPEN c_adv_standing(x_institution_code, x_person_id);
       FETCH c_adv_standing INTO   lv_adv_standing_exists;
       CLOSE c_adv_standing;
       IF lv_adv_standing_exists = '1' THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_AD_ADV_STD_DTLS_EXTS');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
       END IF;
    END IF;
       --If institution_code is passed then
     IF ( x_school_party_id is NULL
	  AND x_institution_code IS NOT NULL ) THEN
       OPEN c_school_party_id(x_institution_code);
       FETCH c_school_party_id INTO   lv_school_party_id ;
       CLOSE c_school_party_id;
     END IF;

    l_education_rec.school_party_id      :=  lv_school_party_id;
    IF lv_school_party_id IS NOT NULL  THEN
        l_education_rec.school_attended_name := chr(0);
    ELSE
        l_education_rec.school_attended_name := x_school_attended_name;
    END IF;
    l_education_rec.course_major := NVL(x_Program_Code,FND_API.G_MISS_CHAR);
    l_education_rec.last_date_attended :=  NVL(x_End_Date, FND_API.G_MISS_DATE);
    l_education_rec.type_of_school  :=  x_type_of_School;
    l_education_rec.party_id  :=  x_person_id;
    l_education_rec.start_date_attended := NVL(x_Start_Date, FND_API.G_MISS_DATE);
    l_education_rec.Education_Id	:= x_Education_Id;
    l_education_rec.Degree_received	:=  NVL(x_degree_earned,FND_API.G_MISS_CHAR) ;
    l_education_rec.status     :=  x_status;


      OPEN c_old_active_ind(x_rowid);
      FETCH c_old_active_ind into l_active_ind,l_transcript_required_old;
      CLOSE c_old_active_ind;

      --jchin Bug 4629226 added check to prevent INACTIVE academic history records from being updated.
      l_count := null;

      OPEN cur_check_external(x_Education_Id);
      FETCH cur_check_external INTO l_count;
      CLOSE cur_check_external;

      IF l_active_ind = 'I' THEN

        IF nvl(x_status, 'I') = 'I' OR (x_status = 'A' AND l_count IS NOT NULL) THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_AD_INACTIVE_ACAD_HIST');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;

      END IF;


       --Update HZ_EDUCATION table by calling this proc hz_per_info_pub.Update_education
       hz_person_info_v2pub.Update_education(
          p_init_msg_list =>  FND_API.G_TRUE,
          p_education_rec => l_education_rec,
	  p_object_version_number => x_object_version_number,
          x_return_status  => lv_return_status,
          x_msg_count   => lv_msg_count,
          x_msg_data => lv_msg_data );

        x_return_status  := lv_return_status;
        x_msg_data := lv_msg_data;

     IF lv_return_Status IN ('E','U') THEN
      -- bug 2338473 logic to display more than one error modified.
      IF lv_msg_count > 1 THEN
            FOR i IN 1..lv_msg_count  LOOP
              tmp_var := fnd_msg_pub.get(p_encoded => fnd_api.g_false);
              tmp_var1 := tmp_var1 || ' '|| tmp_var;
            END LOOP;
           x_msg_data := tmp_var1;
	   x_return_status :=lv_return_status;
      END IF;
      RETURN;
     ELSE
       OPEN C1;
       FETCH C1 INTO l_RowId, lv_Hz_Acad_Hist_Id;
       CLOSE C1;

       Igs_Ad_Hz_Acad_Hist_Pkg.add_Row
	( X_ROWID  => l_RowId,
 	  X_RECALC_TOTAL_CP_ATTEMPTED    => X_RECALC_TOTAL_CP_ATTEMPTED,
 	  X_RECALC_TOTAL_CP_EARNED       => X_RECALC_TOTAL_CP_EARNED,
 	  X_RECALC_TOTAL_UNIT_GP         => X_RECALC_TOTAL_UNIT_GP,
 	  X_RECALC_TOT_GPA_UTS_ATTEMPTED => x_recalc_tot_gpa_units_attemp,
 	  X_RECALC_INST_GPA              => X_RECALC_INST_GPA,
 	  X_RECALC_GRADING_SCALE_ID      => X_RECALC_GRADING_SCALE_ID,
 	  X_SELFREP_TOTAL_CP_ATTEMPTED   => X_SELFREP_TOTAL_CP_ATTEMPTED,
 	  X_SELFREP_TOTAL_CP_EARNED      => X_SELFREP_TOTAL_CP_EARNED,
 	  X_SELFREP_TOTAL_UNIT_GP        => X_SELFREP_TOTAL_UNIT_GP,
 	  X_SELFREP_TOT_GPA_UTS_ATTEMP   => X_SELFREP_TOT_GPA_UTS_ATTEMP,
 	  X_SELFREP_INST_GPA             => X_SELFREP_INST_GPA,
 	  X_SELFREP_GRADING_SCALE_ID     => X_SELFREP_GRADING_SCALE_ID,
 	  X_SELFREP_WEIGHTED_GPA         => X_SELFREP_WEIGHTED_GPA,
 	  X_SELFREP_RANK_IN_CLASS        => X_SELFREP_RANK_IN_CLASS,
 	  X_SELFREP_WEIGHED_RANK         => X_SELFREP_WEIGHED_RANK,
 	  X_SELFREP_CLASS_SIZE           => X_SELFREP_CLASS_SIZE,
 	  X_ATTRIBUTE_CATEGORY           => X_ATTRIBUTE_CATEGORY,
 	  X_ATTRIBUTE1                   => X_ATTRIBUTE1,
 	  X_ATTRIBUTE2                   => X_ATTRIBUTE2,
 	  X_ATTRIBUTE3                   => X_ATTRIBUTE3,
 	  X_ATTRIBUTE4                   => X_ATTRIBUTE4,
 	  X_ATTRIBUTE5                   => X_ATTRIBUTE5,
 	  X_ATTRIBUTE6                   => X_ATTRIBUTE6,
 	  X_ATTRIBUTE7                   => X_ATTRIBUTE7,
 	  X_ATTRIBUTE8                   => X_ATTRIBUTE8,
 	  X_ATTRIBUTE9                   => X_ATTRIBUTE9,
 	  X_ATTRIBUTE10                  => X_ATTRIBUTE10,
 	  X_ATTRIBUTE11                  => X_ATTRIBUTE11,
 	  X_ATTRIBUTE12                  => X_ATTRIBUTE12,
 	  X_ATTRIBUTE13                  => X_ATTRIBUTE13,
 	  X_ATTRIBUTE14                  => X_ATTRIBUTE14,
 	  X_ATTRIBUTE15                  => X_ATTRIBUTE15,
 	  X_ATTRIBUTE16                  => X_ATTRIBUTE16,
 	  X_ATTRIBUTE17                  => X_ATTRIBUTE17,
 	  X_ATTRIBUTE18                  => X_ATTRIBUTE18,
 	  X_ATTRIBUTE19                  => X_ATTRIBUTE19,
 	  X_ATTRIBUTE20                  => X_ATTRIBUTE20,
 	  X_HZ_ACAD_HIST_ID              =>  lv_Hz_Acad_Hist_Id,
 	  X_EDUCATION_ID                 =>   x_Education_Id,
 	  X_CURRENT_INST                 =>  NVL(X_CURRENT_INST,'N'),
 	  X_DEGREE_ATTEMPTED             => X_DEGREE_ATTEMPTED,
 	  X_COMMENTS                     => X_COMMENTS,
 	  X_PLANNED_COMPLETION_DATE      => X_PLANNED_COMPLETION_DATE,
 	  X_TRANSCRIPT_REQUIRED          => X_TRANSCRIPT_REQUIRED,
 	  X_MODE                         => 'R');
	END IF;

--raise business event
  igs_ad_wf_001.ACADHIST_UPD_EVENT
  (
      P_HZ_ACAD_HIST_ID   => lv_Hz_Acad_Hist_Id,
      P_EDUCATION_ID	=> x_Education_Id,
      P_PERSON_ID	=> x_person_id,
      P_ACTIVE_IND_OLD	=> l_active_ind,
      P_ACTIVE_IND_NEW	=> NVL(x_status,l_active_ind),
      P_REQUIRED_IND_NEW => x_transcript_required,
      P_REQUIRED_IND_OLD => l_transcript_required_old
  );
 END update_row;
END Igs_Ad_Acad_History_Pkg;

/
