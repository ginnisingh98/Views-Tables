--------------------------------------------------------
--  DDL for Package Body IGS_RATINGS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RATINGS_PUB" AS
/* $Header: IGSPRATB.pls 120.0 2005/07/05 12:46:47 appldev noship $ */
G_PKG_NAME 	CONSTANT VARCHAR2 (30):='IGS_RATINGS_PUB';

PROCEDURE check_length(p_param_name IN VARCHAR2, p_table_name IN VARCHAR2, p_param_length IN NUMBER) AS
 CURSOR c_col_length IS
  SELECT WIDTH , precision , column_type
  FROM FND_COLUMNS
  WHERE  table_id IN
    (SELECT TABLE_ID
     FROM FND_TABLES
     WHERE table_name = p_table_name AND APPLICATION_ID = 8405)
  AND column_name = p_param_name
  AND APPLICATION_ID = 8405;

  l_col_length  c_col_length%ROWTYPE;
BEGIN
  OPEN 	c_col_length;
  FETCH   c_col_length INTO  l_col_length;
  CLOSE  c_col_length;
  IF l_col_length.column_type = 'V' AND p_param_length > l_col_length.width  THEN
---      DBMS_OUTPUT.PUT_LINE('failure  ' || l_col_length.width);
       FND_MESSAGE.SET_NAME('IGS','IGS_AD_EXCEED_MAX_LENGTH');
       FND_MESSAGE.SET_TOKEN('PARAMETER',p_param_name);
       FND_MESSAGE.SET_TOKEN('LENGTH',l_col_length.width);
       IGS_GE_MSG_STACK.ADD;
       RAISE FND_API.G_EXC_ERROR;


  ELSIF 	l_col_length.column_type ='N' AND p_param_length > l_col_length.precision THEN
--      DBMS_OUTPUT.PUT_LINE('failure  ' || l_col_length.precision);
       FND_MESSAGE.SET_NAME('IGS','IGS_AD_EXCEED_MAX_LENGTH');
       FND_MESSAGE.SET_TOKEN('PARAMETER',p_param_name);
       FND_MESSAGE.SET_TOKEN('LENGTH',l_col_length.precision);
       IGS_GE_MSG_STACK.ADD;
       RAISE FND_API.G_EXC_ERROR;
  END IF;

END check_length;

PROCEDURE rec_pgm_approval
  (
 --Standard Parameters Start
                    p_api_version          IN      NUMBER,
		    p_init_msg_list        IN	   VARCHAR2  default FND_API.G_FALSE,
		    p_commit               IN      VARCHAR2  default FND_API.G_FALSE,
		    p_validation_level     IN      NUMBER    default FND_API.G_VALID_LEVEL_FULL,
		    x_return_status        OUT     NOCOPY    VARCHAR2,
		    x_msg_count		   OUT     NOCOPY    NUMBER,
		    x_msg_data             OUT     NOCOPY    VARCHAR2,
--Standard parameter ends
		     p_person_id                   IN     NUMBER,
		     p_admission_appl_number       IN     NUMBER,
		     p_nominated_program_cd         IN     VARCHAR2,
		     p_sequence_number             IN     NUMBER,
		     p_pgm_approver_id             IN     NUMBER,
		     p_program_approval_date       IN     DATE,
		     p_program_approval_status     IN     VARCHAR2,
		     p_approval_notes              IN     VARCHAR2

  )
  IS
  CURSOR c_pgm_appr IS
  SELECT  rowid row_id, appl_pgmapprv_id
  FROM Igs_Ad_Appl_Pgmapprv a
  WHERE person_id = p_person_id
  AND admission_appl_number = p_admission_appl_number
  AND nominated_course_cd = p_nominated_program_cd
  AND sequence_number = p_sequence_number
  AND pgm_approver_id = p_pgm_approver_id ;

  l_pgm_appr Igs_Ad_Appl_Pgmapprv%ROWTYPE;
  l_api_version         CONSTANT    	NUMBER  	:=  1.0;
  l_api_name  	    	CONSTANT    	VARCHAR2(30)	:=  'REC_PGM_APPROVAL';
  l_msg_index                           NUMBER          := 0;
  l_return_status                       VARCHAR2(1);
  l_hash_msg_name_text_type_tab         igs_ad_gen_016.g_msg_name_text_type_table;
  lv_rowid                              ROWID;
  l_appl_pgmapprv_id                    NUMBER;

BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

     SAVEPOINT Rec_Pgm_Approval_PUB;
     -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,p_api_version,l_api_name,G_PKG_NAME) THEN
    	RAISE FND_API.G_EXC_ERROR;
    END IF;
     -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
    l_msg_index := igs_ge_msg_stack.count_msg;

-- P_PERSON_ID
     check_length('PERSON_ID', 'IGS_AD_APPL_PGMAPPRV', length(p_person_id));
-- P_ADMISSION_APPL_NUMBER
     check_length('ADMISSION_APPL_NUMBER', 'IGS_AD_APPL_PGMAPPRV', length(p_admission_appl_number));
-- p_nominated_program_cd
     check_length('NOMINATED_COURSE_CD', 'IGS_AD_APPL_PGMAPPRV', length(p_nominated_program_cd));
-- P_SEQUENCE_NUMBER
     check_length('SEQUENCE_NUMBER', 'IGS_AD_APPL_PGMAPPRV', length(p_sequence_number));
-- P_PGM_APPROVER_ID
     check_length('PGM_APPROVER_ID', 'IGS_AD_APPL_PGMAPPRV', length(p_pgm_approver_id));
-- P_PROGRAM_APPROVAL_STATUS
     check_length('PROGRAM_APPROVAL_STATUS', 'IGS_AD_APPL_PGMAPPRV', length(p_program_approval_status));
-- P_APPROVAL_NOTES
     check_length('APPROVAL_NOTES', 'IGS_AD_APPL_PGMAPPRV', length(p_approval_notes));

  OPEN c_pgm_appr;
  FETCH c_pgm_appr INTO lv_rowid,l_appl_pgmapprv_id;
  CLOSE c_pgm_appr;
  IF l_appl_pgmapprv_id is NULL THEN
    --  Initialize API return status to success
      Igs_Ad_Appl_Pgmapprv_Pkg.Insert_Row (
      X_ROWID                             => lv_rowid,
      x_APPL_PGMAPPRV_ID                  => l_appl_pgmapprv_id ,
      x_PERSON_ID                         => p_person_id,
      x_ADMISSION_APPL_NUMBER             => p_admission_appl_number,
      x_NOMINATED_COURSE_CD               => p_nominated_program_cd,
      x_SEQUENCE_NUMBER                   => p_sequence_number,
      x_PGM_APPROVER_ID                   => p_pgm_approver_id,
      x_ASSIGN_TYPE                       => 'M',
      x_ASSIGN_DATE                       => SYSDATE,
      x_PROGRAM_APPROVAL_DATE             => p_program_approval_date,
      x_PROGRAM_APPROVAL_STATUS           => p_program_approval_status,
      x_APPROVAL_NOTES                    => p_approval_notes,
      X_Mode                              => 'R'
    );
  ELSE
        Igs_Ad_Appl_Pgmapprv_Pkg.update_row (
      X_ROWID                             => lv_rowid,
      x_APPL_PGMAPPRV_ID                  => l_appl_pgmapprv_id,
      x_PERSON_ID                         => p_person_id,
      x_ADMISSION_APPL_NUMBER             => p_admission_appl_number,
      x_NOMINATED_COURSE_CD               => p_nominated_program_cd,
      x_SEQUENCE_NUMBER                   => p_sequence_number,
      x_PGM_APPROVER_ID                   => p_pgm_approver_id,
      x_ASSIGN_TYPE                       => 'M',
      x_ASSIGN_DATE                       => SYSDATE,
      x_PROGRAM_APPROVAL_DATE             => p_program_approval_date,
      x_PROGRAM_APPROVAL_STATUS           => p_program_approval_status,
      x_APPROVAL_NOTES                    => p_approval_notes,
      X_Mode                              => 'R');
  END IF;

  --DBMS_OUTPUT.PUT_LINE('EXCEPTION BLOCK : After extracting XDATA :-' );

--     	 Standard check of p_commit.
 	IF FND_API.To_Boolean( p_commit ) THEN
		COMMIT;
	END IF;
   -- End of Procedure
EXCEPTION
	WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Rec_Pgm_Approval_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		-- Add message to API message list.
       igs_ad_gen_016.extract_msg_from_stack (
                   p_msg_at_index                => l_msg_index,
                   p_return_status               => l_return_status,
                   p_msg_count                   => x_msg_count,
                   p_msg_data                    => x_msg_data,
                   p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
	    x_msg_count := x_msg_count -1 ;
            x_msg_data := l_hash_msg_name_text_type_tab(x_msg_count-1).text;


          IF l_hash_msg_name_text_type_tab(x_msg_count-1).name <>  'ORA'  THEN
	    x_return_status := FND_API.G_RET_STS_ERROR ;
	  ELSE
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  END IF;

	WHEN OTHERS THEN
		ROLLBACK TO Rec_Pgm_Approval_PUB;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		-- Add message to API message list.
       igs_ad_gen_016.extract_msg_from_stack (
                   p_msg_at_index                => l_msg_index,
                   p_return_status               => l_return_status,
                   p_msg_count                   => x_msg_count,
                   p_msg_data                    => x_msg_data,
                   p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
          IF l_hash_msg_name_text_type_tab(x_msg_count-1).name <>  'ORA'  THEN
	    x_return_status := FND_API.G_RET_STS_ERROR ;
	  ELSE
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  END IF;
END rec_pgm_approval;

  PROCEDURE ASSIGN_EVALUATORS_TO_AI (
   --Standard Parameters Start
                    p_api_version          IN      NUMBER,
		    p_init_msg_list        IN	   VARCHAR2  default FND_API.G_FALSE,
		    p_commit               IN      VARCHAR2  default FND_API.G_FALSE,
		    p_validation_level     IN      NUMBER    default FND_API.G_VALID_LEVEL_FULL,

--Standard parameter ends

		    p_person_id                 IN  igs_ad_appl_arp_v.PERSON_ID%TYPE               ,
		    p_admission_appl_number     IN  igs_ad_appl_arp_v.ADMISSION_APPL_NUMBER%TYPE   ,
		    p_nominated_program_cd       IN  igs_ad_appl_arp_v.NOMINATED_COURSE_CD%TYPE,
		    p_sequence_number           IN  igs_ad_appl_arp_v.SEQUENCE_NUMBER%TYPE,
		    p_appl_rev_profile_id       IN  igs_ad_appl_arp_v.APPL_REV_PROFILE_ID%TYPE,
		    p_appl_revprof_revgr_id     IN  igs_ad_appl_arp_v.APPL_REVPROF_REVGR_ID%TYPE,

		    x_return_status        OUT     NOCOPY    VARCHAR2,
		    x_msg_count		   OUT     NOCOPY    NUMBER,
		    x_msg_data             OUT     NOCOPY    VARCHAR2
  ) AS

-- IF API then add API comments here...rsharma and add standard parameters
  /*************************************************************
  Created By :           Rsharma
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
  CURSOR dup_eval_cur(
    l_person_id    igs_ad_appl_eval.person_id%TYPE,
    l_adm_apl_num  igs_ad_appl_eval.admission_appl_number%TYPE,
    l_nom_crs_cd   igs_ad_appl_eval.nominated_course_cd%TYPE,
    l_seq_number   igs_ad_appl_eval.sequence_number%TYPE)
  IS
  SELECT count(*), rating_type_id, rating_scale_id,evaluator_id
  FROM igs_ad_appl_eval
  WHERE person_id = l_person_id
    AND admission_appl_number = l_adm_apl_num
    AND nominated_course_cd = l_nom_crs_cd
    AND sequence_number = l_seq_number
  GROUP BY rating_type_id, rating_scale_id,evaluator_id
  HAVING count(*) > 1;

  /* Cursor to get the Evaluator records which are duplicates */
  CURSOR del_dup_eval_cur(
    l_rating_type_id igs_ad_appl_eval.rating_type_id%TYPE,
    l_evaluator_id igs_ad_appl_eval.evaluator_id%TYPE,
    l_person_id    igs_ad_appl_eval.person_id%TYPE,
    l_adm_apl_num  igs_ad_appl_eval.admission_appl_number%TYPE,
    l_nom_crs_cd   igs_ad_appl_eval.nominated_course_cd%TYPE,
    l_seq_number   igs_ad_appl_eval.sequence_number%TYPE)
  IS
  SELECT rowid
  FROM igs_ad_appl_eval
  WHERE rating_type_id = l_rating_type_id
    AND  evaluator_id = l_evaluator_id
    AND person_id = l_person_id
    AND admission_appl_number = l_adm_apl_num
    AND nominated_course_cd = l_nom_crs_cd
    AND sequence_number = l_seq_number
    AND rowid <>
     (SELECT max(rowid)
      FROM igs_ad_appl_eval
      WHERE rating_type_id = l_rating_type_id
      AND evaluator_id = l_evaluator_id
      AND person_id = l_person_id
      AND admission_appl_number = l_adm_apl_num
      AND nominated_course_cd = l_nom_crs_cd
      AND sequence_number = l_seq_number
     );


  CURSOR c_get_current_eval(
    l_person_id    igs_ad_appl_eval.person_id%TYPE,
    l_adm_apl_num  igs_ad_appl_eval.admission_appl_number%TYPE,
    l_nom_crs_cd   igs_ad_appl_eval.nominated_course_cd%TYPE,
    l_seq_num      igs_ad_appl_eval.sequence_number%TYPE
     ) IS
    SELECT 'X'
    FROM igs_ad_appl_eval
    WHERE person_id = l_person_id
      AND admission_appl_number = l_adm_apl_num
      AND nominated_course_cd = l_nom_crs_cd
      AND sequence_number = l_seq_num ;


      CURSOR c_aplinst_cur IS
      SELECT a.ROWID, a.*
        FROM igs_ad_ps_appl_inst a
       WHERE person_id = p_person_id
         AND admission_appl_number = p_admission_appl_number
         AND nominated_course_cd = p_nominated_program_cd
         AND sequence_number = p_sequence_number;

    CURSOR eval_type_cur( l_appl_rev_profile_id  igs_ad_apl_rev_prf_all.appl_rev_profile_id%TYPE)
    IS
    SELECT distinct sequential_concurrent_ind
    FROM igs_ad_apl_rev_prf_all
    WHERE appl_rev_profile_id = l_appl_rev_profile_id;

      CURSOR c_get_appl_rev_profile_id (
    l_person_id    igs_ad_appl_arp.person_id%TYPE,
    l_adm_apl_num  igs_ad_appl_arp.admission_appl_number%TYPE,
    l_nom_crs_cd   igs_ad_appl_arp.nominated_course_cd%TYPE,
    l_seq_num      igs_ad_appl_arp.sequence_number%TYPE
     ) IS
    SELECT *
    FROM igs_ad_appl_arp_v
    WHERE person_id = l_person_id
    AND admission_appl_number = l_adm_apl_num
    AND nominated_course_cd = l_nom_crs_cd
    AND sequence_number = l_seq_num ;

    CURSOR get_rating_cur(
    l_person_id    igs_ad_appl_eval_v.person_id%TYPE,
    l_adm_apl_num  igs_ad_appl_eval_v.admission_appl_number%TYPE,
    l_nom_crs_cd   igs_ad_appl_eval_v.nominated_course_cd%TYPE,
    l_seq_num      igs_ad_appl_eval_v.sequence_number%TYPE
     ) IS
    SELECT rating
    FROM igs_ad_appl_eval_v
    WHERE person_id = l_person_id
      AND admission_appl_number = l_adm_apl_num
      AND nominated_course_cd = l_nom_crs_cd
      AND sequence_number = l_seq_num
      AND rating IS NOT NULL;

   CURSOR doc_cur(
     l_person_id    igs_ad_appl_arp.person_id%TYPE,
     l_adm_apl_num  igs_ad_appl_arp.admission_appl_number%TYPE,
     l_nom_crs_cd   igs_ad_appl_arp.nominated_course_cd%TYPE,
     l_seq_number   igs_ad_appl_arp.sequence_number%TYPE)
   IS
   SELECT
     doc.s_adm_doc_status
   FROM
     igs_ad_ps_appl_inst  apl,  /* Replaced igs_ad_ps_appl_inst_aplinst_v with igs_ad_ps_appl_inst Bug 3150054 */
     igs_ad_doc_stat doc
   WHERE person_id = l_person_id
     AND admission_appl_number = l_adm_apl_num
     AND nominated_course_cd = l_nom_crs_cd
     AND sequence_number = l_seq_number
     AND doc.adm_doc_status = apl.adm_doc_status;

    l_adm_doc igs_ad_ps_appl_inst.adm_doc_status%TYPE;
    l_rating          igs_ad_appl_eval_v.rating%TYPE;
    l_exist_arp    igs_ad_appl_arp_v%ROWTYPE;
    l_modif_eval_type igs_ad_apl_rev_prf_all.sequential_concurrent_ind%TYPE;
    l_exist_eval_type igs_ad_apl_rev_prf_all.sequential_concurrent_ind%TYPE;
    l_get_current_eval VARCHAR2(1);
  l_c_aplinst_cur               c_aplinst_cur%ROWTYPE;
  l_api_version         CONSTANT    	NUMBER  	:=  1.0;
  l_api_name  	    	CONSTANT    	VARCHAR2(30)	:=  'ASSIGN_EVALUATORS_TO_AI';
  l_msg_index                           NUMBER          := 0;
  l_return_status                       VARCHAR2(1);
  l_hash_msg_name_text_type_tab         igs_ad_gen_016.g_msg_name_text_type_table;

     l_appl_arp_id igs_ad_appl_arp.appl_arp_id%TYPE ;
    lv_rowid VARCHAR2(25) ;
  l_errbuf VARCHAR2(100);
  l_retcode NUMBER;
 BEGIN

       SAVEPOINT ASSIGN_EVALUATORS_TO_AI_PUB;
     l_msg_index := igs_ge_msg_stack.count_msg;
     -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version,p_api_version,l_api_name,G_PKG_NAME) THEN
    	RAISE FND_API.G_EXC_ERROR ;
      END IF;
     -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
      END IF;

-- P_PERSON_ID
     check_length('PERSON_ID', 'IGS_AD_APPL_ARP', length(p_person_id));
-- P_ADMISSION_APPL_NUMBER
     check_length('ADMISSION_APPL_NUMBER', 'IGS_AD_APPL_ARP', length(p_admission_appl_number));
-- p_nominated_program_cd
     check_length('NOMINATED_COURSE_CD', 'IGS_AD_APPL_ARP', length(p_nominated_program_cd));
-- P_SEQUENCE_NUMBER
     check_length('SEQUENCE_NUMBER', 'IGS_AD_APPL_ARP', length(p_sequence_number));
-- P_APPL_REV_PROFILE_ID
     check_length('APPL_REV_PROFILE_ID', 'IGS_AD_APPL_ARP', length(p_appl_rev_profile_id));
-- P_APPL_REVPROF_REVGR_ID
     check_length('APPL_REVPROF_REVGR_ID', 'IGS_AD_APPL_ARP', length(p_appl_revprof_revgr_id));

    --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- Check whether any application is available in OSS to update outcome status
    -- if the corresponding application is not there , then update the interface record with appropriate error code
    OPEN c_aplinst_cur;
    FETCH c_aplinst_cur
      INTO l_c_aplinst_cur;
    CLOSE c_aplinst_cur;
    IF l_c_aplinst_cur.person_id IS NULL THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_PROGRAM_APPL'));
         IGS_GE_MSG_STACK.ADD;
         RAISE FND_API.G_EXC_ERROR;
    END IF;
   --Get the Evaluation Type associated with the entered Application Review Profile Name
    OPEN eval_type_cur(p_appl_rev_profile_id);
    FETCH eval_type_cur INTO l_modif_eval_type;
    CLOSE eval_type_cur;

      --Get the Evaluation Type assocoated with the existing Review Profile Name

    OPEN c_get_appl_rev_profile_id (
                          p_person_id,
                          p_admission_appl_number,
                          p_nominated_program_cd,
                          p_sequence_number);
    FETCH c_get_appl_rev_profile_id INTO l_exist_arp;
    CLOSE c_get_appl_rev_profile_id;

  IF l_exist_arp.appl_rev_profile_id IS NOT NULL THEN
    FND_MESSAGE.SET_NAME('IGS','IGS_AD_REV_PRF_EXISTS');
    IGS_GE_MSG_STACK.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

 /*  The following code is to handle the update of the recview profile record.
    OPEN eval_type_cur(l_exist_arp.appl_rev_profile_id);
    FETCH eval_type_cur INTO l_exist_eval_type;
    CLOSE eval_type_cur;


 -- Review Group and Review Profile is already attached and evaluation type is
    IF l_exist_eval_type IS NOT NULL AND l_exist_eval_type <> l_modif_eval_type THEN
      fnd_message.set_name('IGS', 'IGS_AD_DIFF_EVAL_TYPE');
      IGS_GE_MSG_STACK.ADD;
      RAISE FND_API.G_EXC_ERROR;
    ELSIF  l_exist_eval_type IS NOT NULL THEN
      OPEN get_rating_cur(
                        p_person_id,
                          p_admission_appl_number,
                          p_nominated_program_cd,
                          p_sequence_number
        );
      FETCH get_rating_cur INTO l_rating;
       -- If rating is defined for atleast one of the evaluator records then update is not allowed
        IF (get_rating_cur%FOUND) THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_AD_CANT_UPD_RAT_PRSNT');
          IGS_GE_MSG_STACK.ADD;
      	  CLOSE get_rating_cur;
          RAISE FND_API.G_EXC_ERROR;
	END IF;
	CLOSE get_rating_cur;
     ELSE  -- Evaluation Type is null
      -- This cursor fetches the current evaluators that are assigned
      -- If evaluators are already assigned but no review profile has been assigned , then the evaluation type
      -- is set to No Review Group

      OPEN c_get_current_eval(
                        p_person_id,
                          p_admission_appl_number,
                          p_nominated_program_cd,
                          p_sequence_number);
        FETCH c_get_current_eval INTO l_get_current_eval;
      CLOSE c_get_current_eval;

      IF l_get_current_eval IS NOT NULL THEN
        IF (l_modif_eval_type = 'S') THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_AD_DIFF_EVAL_TYPE');
          IGS_GE_MSG_STACK.ADD;
          RAISE FND_API.G_EXC_ERROR;
	END IF;
      END IF;
    END IF;	   */
     /* Get the System Doc Status associated with the Application Instance */
     OPEN doc_cur(
                p_person_id,
                p_admission_appl_number,
                p_nominated_program_cd,
                p_sequence_number
	      );
     FETCH doc_cur INTO l_adm_doc;
     CLOSE doc_cur;
     --Validtion to check Outcome Status = PENDING is already present in TBH.
     -- The following to check the documentation status is satisfied or NOT.
      IF l_adm_doc <> 'SATISFIED' THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AD_OTCM_DOC_STAT');
          IGS_GE_MSG_STACK.ADD;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

	BEGIN
	      IF l_exist_eval_type IS NULL THEN
		-- insert row of Review Proifile
		   igs_ad_appl_arp_pkg.insert_row (
		      x_mode                              => 'I',
		      x_rowid                             => lv_rowid,
		      x_appl_arp_id                       => l_appl_arp_id,
		      x_person_id                         => p_PERSON_ID,
		      x_admission_appl_number             => p_ADMISSION_APPL_NUMBER,
		      x_nominated_course_cd               => p_nominated_program_cd,
		      x_sequence_number                   => p_SEQUENCE_NUMBER,
		      x_appl_rev_profile_id               => p_APPL_REV_PROFILE_ID,
		      x_appl_revprof_revgr_id             => p_APPL_REVPROF_REVGR_ID
		    );
	      ELSE   -- this case will never happen as we are not allowing the update of review profile
		-- insert row of Review Proifile
		   igs_ad_appl_arp_pkg.update_Row (
		      x_mode                              => 'I',
		      x_rowid                             => l_exist_arp.row_id,
		      x_appl_arp_id                       => l_exist_arp.appl_arp_id,
		      x_person_id                         => p_PERSON_ID,
		      x_admission_appl_number             => p_ADMISSION_APPL_NUMBER,
		      x_nominated_course_cd               => p_nominated_program_cd,
		      x_sequence_number                   => p_SEQUENCE_NUMBER,
		      x_appl_rev_profile_id               => p_APPL_REV_PROFILE_ID,
		      x_appl_revprof_revgr_id             => p_APPL_REVPROF_REVGR_ID
		    );
	      END IF;


	     -- Call to evaluator assigning job
		 igs_ad_assign_eval_ai_pkg.Assign_Eval_To_Ai(
		 l_Errbuf                  ,
		 l_Retcode                 ,
		 p_appl_rev_profile_id     ,
		 p_appl_revprof_revgr_id   ,
		 p_person_id               ,
		 p_admission_appl_number   ,
		 p_nominated_program_cd     ,
		 p_sequence_number
	       );

	   FOR dup_rec IN dup_eval_cur(
				    p_PERSON_ID,
				    p_ADMISSION_APPL_NUMBER,
				    p_nominated_program_cd,
				    p_SEQUENCE_NUMBER)
	    LOOP
	      FOR del_dup_rec IN del_dup_eval_cur(dup_rec.rating_type_id,
						  dup_rec.evaluator_id,
						  p_PERSON_ID,
						  p_ADMISSION_APPL_NUMBER,
						  p_nominated_program_cd,
						  p_SEQUENCE_NUMBER)
	      LOOP
		igs_ad_appl_eval_pkg.delete_row(del_dup_rec.rowid);
	      END LOOP;
	    END LOOP;

	EXCEPTION
	   WHEN OTHERS THEN
	   ROLLBACK TO ASSIGN_EVALUATORS_TO_AI_PUB;
	       igs_ad_gen_016.extract_msg_from_stack (
			   p_msg_at_index                => l_msg_index,
			   p_return_status               => l_return_status,
			   p_msg_count                   => x_msg_count,
			   p_msg_data                    => x_msg_data,
			   p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
		  IF l_hash_msg_name_text_type_tab(x_msg_count-1).name <>  'ORA'  THEN
		    x_return_status := FND_API.G_RET_STS_ERROR ;
		  ELSE
		    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		  END IF;
	END;








EXCEPTION
	WHEN FND_API.G_EXC_ERROR  THEN
--		FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception in API: FND_API.G_EXC_ERROR : '||SQLERRM);
       x_return_status := FND_API.G_RET_STS_ERROR ;
       ROLLBACK TO ASSIGN_EVALUATORS_TO_AI_PUB;
       igs_ad_gen_016.extract_msg_from_stack (
                   p_msg_at_index                => l_msg_index,
                   p_return_status               => l_return_status,
                   p_msg_count                   => x_msg_count,
                   p_msg_data                    => x_msg_data,
                   p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
            x_msg_data := l_hash_msg_name_text_type_tab(x_msg_count-2).text;
--		FND_FILE.PUT_LINE(FND_FILE.LOG, 'aFTER STACK Exception in API: FND_API.G_EXC_ERROR : '|| l_hash_msg_name_text_type_tab(x_msg_count-2).text);

       WHEN OTHERS THEN
       ROLLBACK TO ASSIGN_EVALUATORS_TO_AI_PUB;
       igs_ad_gen_016.extract_msg_from_stack (
                   p_msg_at_index                => l_msg_index,
                   p_return_status               => l_return_status,
                   p_msg_count                   => x_msg_count,
                   p_msg_data                    => x_msg_data,
                   p_hash_msg_name_text_type_tab => l_hash_msg_name_text_type_tab);
          IF l_hash_msg_name_text_type_tab(x_msg_count-1).name <>  'ORA'  THEN
	    x_return_status := FND_API.G_RET_STS_ERROR ;
	  ELSE
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  END IF;

 END ASSIGN_EVALUATORS_TO_AI;

END igs_ratings_pub;

/
