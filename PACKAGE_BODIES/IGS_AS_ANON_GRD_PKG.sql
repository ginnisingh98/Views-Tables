--------------------------------------------------------
--  DDL for Package Body IGS_AS_ANON_GRD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_ANON_GRD_PKG" as
/* $Header: IGSAS39B.pls 120.3 2006/09/08 09:58:42 amanohar noship $ */
/*
  ||  Created By : pkpatel
  ||  Created On : 28-JAN-2002
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  smvk            09-Jul-2004     Bug # 3676145. Modified the cursors c_uoo_ai and
  ||                                  c_uoo_ug to select active (not closed) unit classes.
*/

FUNCTION  chk_anon_graded (
       p_uoo_id    IN   igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
	   p_ass_id    IN   igs_as_assessmnt_itm_all.ass_id%TYPE
    ) RETURN VARCHAR2 IS
/*
  ||  Created By : pkpatel
  ||  Created On : 28-JAN-2002
  ||  Purpose :  This function checks if Anonymously Graded. It returns 'Y'/'N'. If P_UOO_ID
  ||             is passed as NULL, it returns NULL.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
*/

  CURSOR	c_uoo_ug
  IS
  SELECT	'X'
  FROM	  igs_ps_unit_ofr_opt		uoo,
          igs_as_anon_method		anm,
       	  igs_ca_teach_to_load_v	ttl
   WHERE uoo.uoo_id = p_uoo_id
   AND	uoo.anon_unit_grading_ind = 'Y'
   AND	uoo.cal_type = ttl.teach_cal_type
   AND	uoo.ci_sequence_number = ttl.teach_ci_sequence_number
   AND	ttl.load_start_dt = (SELECT	MIN(ttl2.load_start_dt)
	                         FROM	  igs_ca_teach_to_load_v	ttl2
                			 WHERE	 uoo.cal_type = ttl2.teach_cal_type
                        	 AND	 uoo.ci_sequence_number = ttl2.teach_ci_sequence_number)
    AND	anm.load_cal_type = ttl.load_cal_type
    AND	(anm.method <> 'ASSESSMENT'
           OR	(anm.method = 'ASSESSMENT'
               AND	(EXISTS (	SELECT	'X'
                          		FROM	igs_ps_unitass_item		uooai,
                          				igs_as_assessmnt_itm  	ai,
                           				igs_as_assessmnt_typ	ast
                      			WHERE	uooai.uoo_id = uoo.uoo_id
                                AND	uooai.logical_delete_dt IS NULL
                                AND	uooai.ass_id = ai.ass_id
                                AND	ai.assessment_type = anm.assessment_type
                                AND	ai.assessment_type = ast.assessment_type
                                AND	ast.anon_grading_ind = 'Y')
                     OR	EXISTS (	SELECT	'X'
                            		FROM	igs_as_unitass_item		uoai,
                                			igs_as_assessmnt_itm  	ai,
                                			igs_as_assessmnt_typ	ast,
                                			igs_as_unit_class		uc
                            		WHERE uoai.unit_cd = uoo.unit_cd
									AND uoai.version_number = uoo.version_number
									AND uoai.cal_type   = uoo.cal_type
									AND uoai.ci_sequence_number = uoo.ci_sequence_number
									AND uc.closed_ind = 'N'
--ijeddy, Bug 3201661, Grade Book.
                                    AND	uoai.logical_delete_dt IS NULL
									AND	uoai.ass_id = ai.ass_id
                                    AND	ai.assessment_type = anm.assessment_type
                                    AND	ai.assessment_type = ast.assessment_type
                                    AND	ast.anon_grading_ind = 'Y'
                                    AND	NOT EXISTS	 (SELECT	'X'
                                       				  FROM	 igs_ps_unitass_item		uooai
                                               		  WHERE	 uooai.uoo_id = uoo.uoo_id
                                                      AND	 uooai.logical_delete_dt IS NOT NULL)))));


  CURSOR	c_uoo_ai
  IS
  SELECT	'X'
  FROM	  igs_ps_unit_ofr_opt		uoo,
		  igs_as_anon_method		anm,
		  igs_ca_teach_to_load_v	ttl
  WHERE	uoo.uoo_id = p_uoo_id
  AND	uoo.anon_assess_grading_ind = 'Y'
  AND	uoo.cal_type = ttl.teach_cal_type
  AND	uoo.ci_sequence_number = ttl.teach_ci_sequence_number
  AND	ttl.load_start_dt = (SELECT	MIN(ttl2.load_start_dt)
              			 	 FROM	igs_ca_teach_to_load_v	ttl2
                			 WHERE	uoo.cal_type = ttl2.teach_cal_type
 			 	             AND	uoo.ci_sequence_number = ttl2.teach_ci_sequence_number)
  AND	anm.load_cal_type = ttl.load_cal_type
  AND	(EXISTS (	SELECT	'X'
   		            FROM	igs_ps_unitass_item		uooai,
                    		igs_as_assessmnt_itm  	ai,
                        	igs_as_assessmnt_typ	ast
                    WHERE uooai.uoo_id = uoo.uoo_id
                    AND	uooai.ass_id = p_ass_id
                    AND	uooai.logical_delete_dt IS NULL
                    AND	uooai.ass_id = ai.ass_id
                    AND	ai.assessment_type = ast.assessment_type
                    AND	ast.anon_grading_ind = 'Y')
         OR	EXISTS (	SELECT	'X'
                		FROM	igs_as_unitass_item		uoai,
                        		igs_as_assessmnt_itm  	ai,
                        		igs_as_assessmnt_typ	ast,
                        		igs_as_unit_class		uc
                        WHERE	uoai.unit_cd = uoo.unit_cd
           				AND uoai.version_number = uoo.version_number
						AND uoai.cal_type   = uoo.cal_type
						AND uoai.ci_sequence_number = uoo.ci_sequence_number
                        AND	uoai.ass_id = p_ass_id
                        AND	uoo.location_cd = NVL(uoai.location_cd, uoo.location_cd)
                        AND	uoo.unit_class = NVL(uoai.unit_class, uoo.unit_class)
                        AND	uoo.unit_class = uc.unit_class
			AND     uc.closed_ind = 'N'
                        AND	uc.unit_mode = NVL(uoai.unit_mode, uc.unit_mode)
                        AND	uoai.logical_delete_dt IS NULL
                        AND	uoai.ass_id = ai.ass_id
                        AND	ai.assessment_type = ast.assessment_type
                        AND	ast.anon_grading_ind = 'Y'
                        AND	NOT EXISTS	 (SELECT	'X'
                                		  FROM	igs_ps_unitass_item		uooai
                                          WHERE	uooai.uoo_id = uoo.uoo_id
                                          AND	uooai.logical_delete_dt IS NOT NULL)));

c_uoo_ai_rec    c_uoo_ai%ROWTYPE;
c_uoo_ug_rec    c_uoo_ug%ROWTYPE;

BEGIN
   IF (p_uoo_id IS NOT NULL AND p_ass_id IS NULL) THEN

         OPEN  c_uoo_ug;
		 FETCH  c_uoo_ug  INTO  c_uoo_ug_rec;

		      -- Unit Grading is done anonymously
		     IF  c_uoo_ug%FOUND  THEN
			      CLOSE   c_uoo_ug;
			      RETURN  'Y';

			 ELSE  -- Unit Grading is NOT done anonymously
			      CLOSE   c_uoo_ug;
			      RETURN  'N';
		     END IF;

   ELSIF  (p_uoo_id IS NOT NULL AND p_ass_id IS NOT NULL ) THEN

         OPEN   c_uoo_ai;
		 FETCH  c_uoo_ai  INTO  c_uoo_ai_rec;

		      -- Assessment Item grading is done anonymously
			 IF  c_uoo_ai%FOUND  THEN
			      CLOSE   c_uoo_ai;
			      RETURN  'Y';

			 ELSE  -- Assessment Item grading is NOT done anonymously
			      CLOSE   c_uoo_ai;
			      RETURN  'N';
		     END IF;

   ELSE
         -- Parameters are not passed properly(P_UOO_ID is passed as NULL),
		 -- hence return NULL
         RETURN  NULL;
  END IF;

EXCEPTION
     WHEN OTHERS THEN
	    FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_ANON_GRD_PKG.CHK_ANON_GRADED');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

END  chk_anon_graded;

PROCEDURE sub_get_insert(
         p_method			IN  igs_as_anon_method.method%TYPE,
         p_person_id		IN  hz_parties.party_id%TYPE,
         p_course_cd		IN  igs_en_su_attempt_all.course_cd%TYPE,
         p_unit_cd			IN  igs_en_su_attempt_all.unit_cd%TYPE,
         p_teach_cal_type	IN  igs_ca_inst_all.cal_type%TYPE,
         p_teach_ci_sequence_number	IN  igs_ca_inst_all.sequence_number%TYPE,
         p_uoo_id			IN  igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
         p_assessment_type	IN  igs_as_assessmnt_typ.assessment_type%TYPE,
         p_load_cal_type	IN  igs_ca_inst_all.cal_type%TYPE,
         p_load_ci_sequence_number	IN igs_ca_inst_all.sequence_number%TYPE )
IS
/*
  ||  Created By : prabhat.patel@Oracle.com
  ||  Created On : 28-JAN-2002
  ||  Purpose : This is a private procedure to Insert records in the Anonymous ID
  ||            tables as per the Method
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    -- Select the first record from the unallocated anonymous number table IGS_AS_ANON_NUMBER
	-- for the different methods. or PROGRAM method the cal_type and ci_sequence_number would be NULL.
   CURSOR	c_anon_number(cp_load_cal_type  igs_as_anon_number.load_cal_type%TYPE,
                          cp_load_ci_sequence_number  igs_as_anon_number.load_ci_sequence_number%TYPE)
   IS
   SELECT	anonymous_number
   FROM	    igs_as_anon_number
   WHERE    ((load_cal_type = cp_load_cal_type) OR
             (load_cal_type IS NULL AND cp_load_cal_type IS NULL))
   AND      ((load_ci_sequence_number = cp_load_ci_sequence_number) OR
              (load_ci_sequence_number IS NULL AND cp_load_ci_sequence_number IS NULL));

   CURSOR   c_delete_anon_number(cp_anonymous_number  igs_as_anon_number.anonymous_number%TYPE,
                                 cp_load_cal_type  igs_as_anon_number.load_cal_type%TYPE,
                                 cp_load_ci_sequence_number  igs_as_anon_number.load_ci_sequence_number%TYPE)
   IS
   SELECT   ROWID
   FROM     igs_as_anon_number
   WHERE    anonymous_number = cp_anonymous_number
   AND      ((load_cal_type = cp_load_cal_type) OR
             (load_cal_type IS NULL AND cp_load_cal_type IS NULL))
   AND      ((load_ci_sequence_number = cp_load_ci_sequence_number) OR
              (load_ci_sequence_number IS NULL AND cp_load_ci_sequence_number IS NULL));


   l_anonymous_number      igs_as_anon_number.anonymous_number%TYPE;
   l_rowid                 ROWID;
   l_rowid_delete          ROWID;
   l_anonymous_id          igs_as_anon_id_ps.anonymous_id%TYPE;
   l_system_generated_ind  VARCHAR2(1);

BEGIN

         OPEN   c_anon_number(p_load_cal_type, p_load_ci_sequence_number);
         FETCH  c_anon_number INTO l_anonymous_number;
         CLOSE  c_anon_number;

       -- Delete the number so it can only be used once
	  OPEN   c_delete_anon_number(l_anonymous_number,p_load_cal_type, p_load_ci_sequence_number);
	  FETCH  c_delete_anon_number  INTO  l_rowid_delete;
	  CLOSE  c_delete_anon_number;

      igs_as_anon_number_pkg.delete_row(l_rowid_delete);


     -- Call the USER_ANON_ID user hook to return an Anonymous ID in a format specified by the Institution
     l_anonymous_id := igs_as_anon_grd_pkg.user_anon_id (
                                 	 p_anonymous_number      => l_anonymous_number,
                                     p_method                => p_method,
                                     p_person_id             => p_person_id,
                                     p_course_cd             => p_course_cd,
                                     p_unit_cd               => p_unit_cd,
                                     p_teach_cal_type        => p_teach_cal_type,
                                     p_teach_ci_sequence_number  => p_teach_ci_sequence_number,
                                     p_uoo_id                => p_uoo_id,
                                     p_assessment_type       => p_assessment_type,
                                     p_load_cal_type         => p_load_cal_type,
                                     p_load_ci_sequence_number  => p_load_ci_sequence_number);


     -- Use the Anonymous Number if there is no Institution specific Anonymous ID
    IF l_anonymous_id IS NULL THEN

       l_anonymous_id := l_anonymous_number;
       l_system_generated_ind := 'Y';
	ELSE

       l_system_generated_ind := 'N';
    END IF;

	IF p_method = 'SECTION' THEN

      igs_as_anon_id_us_pkg.insert_row(
                            x_rowid        => l_rowid,
							x_person_id    => p_person_id,
							x_anonymous_id => l_anonymous_id,
							x_system_generated_ind => l_system_generated_ind,
							x_course_cd    => p_course_cd,
							x_unit_cd      => p_unit_cd,
							x_teach_cal_type => p_teach_cal_type,
							x_teach_ci_sequence_number => p_teach_ci_sequence_number,
							x_uoo_id       => p_uoo_id,
							x_load_cal_type => p_load_cal_type,
							x_load_ci_sequence_number => p_load_ci_sequence_number,
							x_mode => 'R');

   ELSIF p_method = 'ASSESSMENT' THEN

     igs_as_anon_id_ass_pkg.insert_row(
	                       x_rowid            => l_rowid,
                           x_person_id        => p_person_id,
                           x_anonymous_id     => l_anonymous_id,
                           x_system_generated_ind => l_system_generated_ind,
                           x_assessment_type  => p_assessment_type,
                           x_load_cal_type    => p_load_cal_type,
                           x_load_ci_sequence_number  => p_load_ci_sequence_number,
                           x_mode             =>'R');

   ELSE -- p_method = 'PROGRAM'

     igs_as_anon_id_ps_pkg.insert_row(
	                       x_rowid            => l_rowid,
                           x_person_id        => p_person_id,
                           x_anonymous_id     => l_anonymous_id,
                           x_system_generated_ind => l_system_generated_ind,
                           x_course_cd        => p_course_cd,
                           x_mode             => 'R' );
   END IF;

EXCEPTION
     WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'SQL Error Message :'||SQLERRM);
	    FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_ANON_GRD_PKG.MNT_ANON_ID.SUB_GET_INSERT');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

END sub_get_insert; -- END sub_get_insert


PROCEDURE  mnt_anon_id (
     errbuf                OUT NOCOPY	  VARCHAR2,
     retcode               OUT NOCOPY	  NUMBER,
     p_load_calendar       IN     VARCHAR2,
     p_min_number          IN     NUMBER,
     p_max_number          IN     NUMBER,
     p_reallocate_anon_id  IN     VARCHAR2
)
AS
  /*
  ||  Created By : prabhat.patel@Oracle.com
  ||  Created On : 28-JAN-2002
  ||  Purpose :
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  swaghmar	16-Jan-2006	Bug# 4951054
  ||  swaghmar  23-Feb-2006     Bug# 5056679
  */
    -- Define a PL/SQL table to hold the Anonymous
   TYPE  t_temp_table IS TABLE OF igs_as_anon_number.anonymous_number%TYPE
        INDEX BY BINARY_INTEGER;

   temp_table    t_temp_table;

   l_random_number              binary_integer;
   l_index                      binary_integer;
   l_ld_cal_type                igs_ca_inst_all.cal_type%TYPE;
   l_ld_sequence_number         igs_ca_inst_all.sequence_number%TYPE;
   l_anon_id_count              NUMBER;
   l_anon_id_required           NUMBER;
   l_rowid                      ROWID;
   l_method                     igs_as_anon_method.method%TYPE;
   l_anum_id                    NUMBER(15);

    -- Exception to handle the error in parameters.
   PARAM_ERROR                  EXCEPTION;

     -- Find Anonymous Grading Method for the Load Cal Type supplied
   CURSOR   c_method(cp_load_cal_type  igs_as_anon_method.load_cal_type%TYPE)
   IS
   SELECT	anm.method
   FROM	    igs_as_anon_method	anm
   WHERE	anm.load_cal_type = cp_load_cal_type;

     -- COUNT the NUMBER of Anonymous Numbers available for ASSESSMENT/SECTION methods
   CURSOR c_count_anon_num(cp_load_cal_type  igs_as_anon_number.load_cal_type%TYPE,
                             cp_load_ci_sequence_number  igs_as_anon_number.load_ci_sequence_number%TYPE)
   IS
   SELECT COUNT(*)
   FROM	  igs_as_anon_number	ann
   WHERE  ann.load_cal_type = cp_load_cal_type
   AND	  ann.load_ci_sequence_number = cp_load_ci_sequence_number;

     -- COUNT the NUMBER of Anonymous Numbers available for the PROGRAM method
   CURSOR c_count_anon_num_prog
   IS
   SELECT COUNT(*)
   FROM	  igs_as_anon_number	ann
   WHERE  ann.load_cal_type IS NULL;


      -- Count the number of Student Program Attempts
	CURSOR  c_count_program_reqd
	IS
    SELECT	COUNT(*)
	FROM	igs_en_stdnt_ps_att		spa
	WHERE	spa.course_attempt_status IN ('ENROLLED', 'UNCONFIRM', 'INACTIVE')
    AND	NOT EXISTS (SELECT	'X'
                    FROM	igs_as_anon_id_ps  anip
                    WHERE	anip.person_id = spa.person_id
                    AND	    anip.course_cd = spa.course_cd);


     -- Count the Student Unit Attempts for Unit Sections with anonymous assessment item
     -- OR unit grading
	CURSOR  c_count_section_reqd(cp_load_cal_type  igs_as_anon_number.load_cal_type%TYPE,
                                 cp_load_ci_sequence_number  igs_as_anon_number.load_ci_sequence_number%TYPE)
	IS
	SELECT	COUNT(*)
	FROM	igs_en_su_attempt		sua,
            igs_ps_unit_ofr_opt		uoo,
     		igs_ca_teach_to_load_v	ttl
    WHERE sua.unit_attempt_status = 'ENROLLED'
    AND	ttl.load_cal_type = cp_load_cal_type
    AND	ttl.load_ci_sequence_number = cp_load_ci_sequence_number
    AND	uoo.cal_type = ttl.teach_cal_type
    AND	uoo.ci_sequence_number = ttl.teach_ci_sequence_number
    AND	ttl.load_start_dt = (SELECT	MIN(ttl2.load_start_dt)
	   		 	             FROM	igs_ca_teach_to_load_v	ttl2
                		 	 WHERE	uoo.cal_type = ttl2.teach_cal_type
 			 	             AND	uoo.ci_sequence_number = ttl2.teach_ci_sequence_number)
    AND	(uoo.anon_assess_grading_ind = 'Y'
	     OR	uoo.anon_unit_grading_ind = 'Y')
	AND	uoo.uoo_id = sua.uoo_id
    AND	NOT EXISTS	(SELECT	'X'
                     FROM	igs_as_anon_id_us   aniu
                     WHERE	aniu.person_id = sua.person_id
                     AND	aniu.course_cd = sua.course_cd
                     AND	aniu.unit_cd   = sua.unit_cd
                     AND	aniu.teach_cal_type = sua.cal_type
                     AND	aniu.teach_ci_sequence_number = sua.ci_sequence_number
                     AND	aniu.uoo_id = sua.uoo_id);


     --  Count the Student Unit Attempt Assessment Items for anonymous Assessment Types
     --  in anonymous Unit Sections
    CURSOR  c_count_assessment_reqd(cp_load_cal_type  igs_as_anon_number.load_cal_type%TYPE,
                                  cp_load_ci_sequence_number  igs_as_anon_number.load_ci_sequence_number%TYPE)
    IS
    SELECT COUNT(*)
	FROM(
	SELECT DISTINCT  sua.person_id, ast.assessment_type
    FROM igs_ca_teach_to_load_v ttl,
         igs_en_su_attempt  sua,
         igs_ps_unit_ofr_opt  uoo,
         igs_as_assessmnt_typ  ast
    WHERE sua.unit_attempt_status = 'ENROLLED'
    AND ttl.load_cal_type = cp_load_cal_type
    AND ttl.load_ci_sequence_number = cp_load_ci_sequence_number
    AND ttl.load_start_dt = (SELECT MIN(ttl2.load_start_dt)
                            FROM    igs_ca_teach_to_load_v ttl2
                            WHERE   uoo.cal_type = ttl2.teach_cal_type
                            AND     uoo.ci_sequence_number = ttl2.teach_ci_sequence_number)
    AND ttl.teach_cal_type = uoo.cal_type
    AND ttl.teach_ci_sequence_number = uoo.ci_sequence_number
    AND sua.uoo_id = uoo.uoo_id
    AND ((uoo.anon_assess_grading_ind = 'Y'
    AND ast.anon_grading_ind = 'Y'
    AND EXISTS (SELECT 'X'
                FROM   igs_as_su_atmpt_itm  suaai,
                       igs_as_assessmnt_itm   ai
                WHERE  sua.person_id = suaai.person_id
                AND    sua.course_cd = suaai.course_cd
                AND    sua.unit_cd = suaai.unit_cd
                AND    sua.cal_type = suaai.cal_type
                AND    sua.ci_sequence_number = suaai.ci_sequence_number
                AND    suaai.ass_id = ai.ass_id
                AND    ai.assessment_type = ast.assessment_type))
    OR  (uoo.anon_unit_grading_ind = 'Y'
    AND EXISTS (SELECT 'X'
                FROM   igs_as_anon_method anm
                WHERE  anm.load_cal_type = cp_load_cal_type
                AND    anm.assessment_type = ast.assessment_type)))
    AND NOT EXISTS (SELECT 'X'
    FROM igs_as_anon_id_ass   ania
    WHERE ania.person_id = sua.person_id
    AND ania.assessment_type = ast.assessment_type
    AND ania.load_cal_type = cp_load_cal_type
    AND ania.load_ci_sequence_number = cp_load_ci_sequence_number));


     -- Find all Student Program Attempts
   CURSOR	c_spa
   IS
   SELECT	spa.person_id,
	     	spa.course_cd
   FROM	    igs_en_stdnt_ps_att		spa
   WHERE	spa.course_attempt_status IN ('ENROLLED', 'UNCONFIRM','INACTIVE')
   AND	NOT EXISTS (SELECT	'X'
                    FROM	igs_as_anon_id_ps  anip
                    WHERE	anip.person_id = spa.person_id
                    AND	    anip.course_cd = spa.course_cd);

     -- Search for all Student Unit Attempts related to the Load Calendar
   CURSOR	c_sua(cp_load_cal_type  igs_as_anon_number.load_cal_type%TYPE,
                  cp_load_ci_sequence_number  igs_as_anon_number.load_ci_sequence_number%TYPE)
   IS
   SELECT	sua.person_id,
	     	sua.course_cd,
		    sua.unit_cd,
		    sua.cal_type,
		    sua.ci_sequence_number,
		    sua.uoo_id
    FROM	igs_ca_teach_to_load_v	ttl,
            igs_en_su_attempt		sua,
            igs_ps_unit_ofr_opt		uoo
    WHERE	sua.unit_attempt_status = 'ENROLLED'
    AND	ttl.load_cal_type = cp_load_cal_type
    AND	ttl.load_ci_sequence_number = cp_load_ci_sequence_number
    AND	ttl.load_start_dt = (SELECT	MIN(ttl2.load_start_dt)
	             		 	 FROM	igs_ca_teach_to_load_v	ttl2
			 	             WHERE	uoo.cal_type = ttl2.teach_cal_type
             			 	 AND	uoo.ci_sequence_number = ttl2.teach_ci_sequence_number)
    AND	ttl.teach_cal_type = uoo.cal_type
    AND	ttl.teach_ci_sequence_number = uoo.ci_sequence_number
    AND	(uoo.anon_unit_grading_ind = 'Y'
         OR		uoo.anon_assess_grading_ind = 'Y')
    AND	sua.uoo_id = uoo.uoo_id
    AND	NOT EXISTS	(SELECT	'X'
                     FROM	igs_as_anon_id_us  aniu
                     WHERE	aniu.person_id = sua.person_id
                     AND	aniu.course_cd = sua.course_cd
                     AND	aniu.unit_cd = sua.unit_cd
                     AND	aniu.teach_cal_type = sua.cal_type
                     AND	aniu.teach_ci_sequence_number = sua.ci_sequence_number
                     AND	aniu.uoo_id = sua.uoo_id);

    -- Search for all Student Unit Attempt Assessment Items related to the Load Calendar
  CURSOR	c_suaai(cp_load_cal_type  igs_as_anon_number.load_cal_type%TYPE,
                    cp_load_ci_sequence_number  igs_as_anon_number.load_ci_sequence_number%TYPE)
  IS
  SELECT DISTINCT sua.person_id,
                  ast.assessment_type
  FROM igs_ca_teach_to_load_v ttl,
       igs_en_su_attempt  sua,
       igs_ps_unit_ofr_opt  uoo,
       igs_as_assessmnt_typ  ast
  WHERE sua.unit_attempt_status = 'ENROLLED'
  AND ttl.load_cal_type = cp_load_cal_type
  AND ttl.load_ci_sequence_number = cp_load_ci_sequence_number
  AND ttl.load_start_dt = (SELECT MIN(ttl2.load_start_dt)
                          FROM    igs_ca_teach_to_load_v ttl2
                          WHERE   uoo.cal_type = ttl2.teach_cal_type
                          AND     uoo.ci_sequence_number = ttl2.teach_ci_sequence_number)
  AND ttl.teach_cal_type = uoo.cal_type
  AND ttl.teach_ci_sequence_number = uoo.ci_sequence_number
  AND sua.uoo_id = uoo.uoo_id
  AND ((uoo.anon_assess_grading_ind = 'Y'
  AND ast.anon_grading_ind = 'Y'
  AND EXISTS (SELECT 'X'
              FROM   igs_as_su_atmpt_itm  suaai,
                     igs_as_assessmnt_itm   ai
              WHERE  sua.person_id = suaai.person_id
              AND    sua.course_cd = suaai.course_cd
              AND    sua.unit_cd = suaai.unit_cd
              AND    sua.cal_type = suaai.cal_type
              AND    sua.ci_sequence_number = suaai.ci_sequence_number
              AND    suaai.ass_id = ai.ass_id
              AND    ai.assessment_type = ast.assessment_type))
  OR  (uoo.anon_unit_grading_ind = 'Y'
  AND EXISTS (SELECT 'X'
              FROM   igs_as_anon_method anm
              WHERE  anm.load_cal_type = cp_load_cal_type
              AND    anm.assessment_type = ast.assessment_type)))
  AND NOT EXISTS (SELECT 'X'
  FROM igs_as_anon_id_ass   ania
  WHERE ania.person_id = sua.person_id
  AND ania.assessment_type = ast.assessment_type
  AND ania.load_cal_type = cp_load_cal_type
  AND ania.load_ci_sequence_number = cp_load_ci_sequence_number) ;


   -- Find all the records in the Context Load Calendar for ASSESSMENT method
   -- (To delete the records when P_REALLOCATE_ID = 'Y')
  CURSOR c_ass_delete(cp_load_cal_type  igs_as_anon_number.load_cal_type%TYPE,
                      cp_load_ci_sequence_number  igs_as_anon_number.load_ci_sequence_number%TYPE)
  IS
  SELECT ROWID
  FROM	igs_as_anon_id_ass   ania
  WHERE	ania.load_cal_type = cp_load_cal_type
  AND	ania.load_ci_sequence_number = cp_load_ci_sequence_number;

   -- Find all the records in the Context Load Calendar for SECTION method
   -- (To delete the records when P_REALLOCATE_ID = 'Y')
  CURSOR c_section_delete(cp_load_cal_type  igs_as_anon_number.load_cal_type%TYPE,
                          cp_load_ci_sequence_number  igs_as_anon_number.load_ci_sequence_number%TYPE)
  IS
  SELECT ROWID
  FROM	igs_as_anon_id_us   aniu
  WHERE	aniu.load_cal_type = cp_load_cal_type
  AND	aniu.load_ci_sequence_number = cp_load_ci_sequence_number;

   -- Find all the records of PROGRAM method
   -- (To delete the records when P_REALLOCATE_ID = 'Y')
  CURSOR c_program_delete
  IS
  SELECT ROWID
  FROM	igs_as_anon_id_ps;

  -- Find all records of PROGRAM method
  -- (To delete the records when P_REALLOCATE_ID = 'Y')
  CURSOR  c_anon_num_delete_prog
  IS
  SELECT  ROWID
  FROM    igs_as_anon_number  ann
  WHERE	ann.load_cal_type IS NULL;

  -- Find all records of SECTION/ASSESSMENT method
  -- (To delete the records when P_REALLOCATE_ID = 'Y')
  CURSOR  c_anon_num_delete(cp_load_cal_type  igs_as_anon_number.load_cal_type%TYPE,
                            cp_load_ci_sequence_number  igs_as_anon_number.load_ci_sequence_number%TYPE)
  IS
  SELECT  ROWID
  FROM    igs_as_anon_number  ann
  WHERE	ann.load_cal_type = cp_load_cal_type
  AND   ann.load_ci_sequence_number = cp_load_ci_sequence_number;

  -- To get the Parameter Value
  CURSOR  c_reallocate
  IS
  SELECT meaning
  FROM   FND_LOOKUP_VALUES
  WHERE  lookup_type = 'SYS_YES_NO'
  AND    language = userenv ('LANG')
  AND    VIEW_APPLICATION_ID = 8405 AND SECURITY_GROUP_ID  = 0
  AND    lookup_code = p_reallocate_anon_id;

   -- To get the Start and End date of the Calander
  CURSOR  c_cal(cp_load_cal_type  igs_as_anon_number.load_cal_type%TYPE,
                cp_load_ci_sequence_number  igs_as_anon_number.load_ci_sequence_number%TYPE)
  IS
  SELECT  alternate_code,start_dt, end_dt
  FROM    igs_ca_inst
  WHERE   cal_type = cp_load_cal_type
  AND     sequence_number = cp_load_ci_sequence_number;

   -- To get the Person Number of the Person processed.
  CURSOR c_person(cp_person_id  hz_parties.party_id%TYPE)
  IS
  SELECT  party_number
  FROM    hz_parties
  WHERE   party_id = cp_person_id;

  c_method_rec                 c_method%ROWTYPE;
  c_reallocate_rec             c_reallocate%ROWTYPE;
  c_cal_rec                    c_cal%ROWTYPE;
  c_person_rec                 c_person%ROWTYPE;

 BEGIN

     --Intialize Error Code
    retcode := 0;

    IGS_GE_GEN_003.SET_ORG_ID(); -- swaghmar, bug# 4951054

     -- To fetch the cal_type and sequence_number from the Award Year passed.
    l_ld_cal_type        := LTRIM(RTRIM(SUBSTR(p_load_calendar,1,10)));
    l_ld_sequence_number := TO_NUMBER(SUBSTR(p_load_calendar,-6));

    OPEN   c_reallocate;
	FETCH  c_reallocate  INTO  c_reallocate_rec;
	CLOSE  c_reallocate;

    OPEN   c_cal(l_ld_cal_type,l_ld_sequence_number);
	FETCH  c_cal  INTO  c_cal_rec;
	CLOSE  c_cal;

	   /* Print the Parameters Passed */

      FND_FILE.PUT_LINE(FND_FILE.LOG,'+-------------------------Parameters Passed---------------------------------+');
      FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Load Calendar              : ' || l_ld_cal_type);
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Calendar Start Date        : ' || TO_CHAR(c_cal_rec.start_dt,'DD-MON-YYYY'));
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Calendar End Date          : ' || TO_CHAR(c_cal_rec.end_dt,'DD-MON-YYYY'))	;
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Minimum limit of Range     : ' || TO_CHAR(p_min_number));
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Maximum limit of Range     : ' || TO_CHAR(p_max_number));
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Reallocate Anonymous ID    : ' || c_reallocate_rec.meaning );

      FND_FILE.PUT_LINE(FND_FILE.LOG,' ');

      -- Find Anonymous Grading Method for the Load Cal Type supplied
     OPEN    c_method(l_ld_cal_type);
	 FETCH   c_method  INTO  c_method_rec;
	       IF c_method%NOTFOUND THEN
		       CLOSE  c_method;
               FND_MESSAGE.SET_NAME('IGS','IGS_AS_NO_ANON_METHOD');
               IGS_GE_MSG_STACK.ADD;
               RAISE PARAM_ERROR;
		   END IF;
	 CLOSE   c_method;

     l_method := c_method_rec.method;

     -- Check if the anonymous number range supplied is valid
	IF  NVL(p_min_number, 1) > p_max_number THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_AS_INVALID_ANON_RANGE');
        IGS_GE_MSG_STACK.ADD;
        RAISE PARAM_ERROR;
	END IF;

    -- Reallocate Anonymous Numbers
     IF NVL(p_reallocate_anon_id, '2') = '1' THEN

	    IF l_method = 'ASSESSMENT' THEN
     		   -- Delete Allocated Anonymous IDs
      		 FOR c_ass_delete_rec IN c_ass_delete(l_ld_cal_type,l_ld_sequence_number) LOOP
		     igs_as_anon_id_ass_pkg.delete_row(c_ass_delete_rec.ROWID);
		 END LOOP;

    	ELSIF l_method = 'SECTION' THEN
	    	   -- Delete Allocated Anonymous IDs
      		 FOR c_section_delete_rec IN c_section_delete(l_ld_cal_type,l_ld_sequence_number)
			 LOOP
			   igs_as_anon_id_us_pkg.delete_row(c_section_delete_rec.ROWID);
			 END LOOP;

  	    ELSE  -- 'PROGRAM'
		       -- Delete Allocated Anonymous IDs
		     FOR c_program_delete_rec IN c_program_delete
			 LOOP
			   igs_as_anon_id_ps_pkg.delete_row(c_program_delete_rec.ROWID);
			 END LOOP;

			   -- Delete Unallocated Anonymous IDs
       		 FOR c_anon_num_delete_prog_rec IN c_anon_num_delete_prog
			 LOOP
			   igs_as_anon_number_pkg.delete_row(c_anon_num_delete_prog_rec.ROWID);
			 END LOOP;

        END IF;
    	      -- Delete Unallocated Anonymous IDs
       		 FOR c_anon_num_delete_rec IN c_anon_num_delete(l_ld_cal_type,l_ld_sequence_number)
			 LOOP
			   igs_as_anon_number_pkg.delete_row(c_anon_num_delete_rec.ROWID);
			 END LOOP;

    END IF;

         -- Check how many Anonymous Numbers are available for SECTION/ASSESSMENT methods.
                OPEN   c_count_anon_num(l_ld_cal_type,l_ld_sequence_number);
		FETCH  c_count_anon_num INTO l_anon_id_count;
		CLOSE  c_count_anon_num;

    -- Check how many Anonymous Numbers are required not including those with numbers already allocated.
    IF l_method = 'PROGRAM' THEN
         -- Check how many Anonymous Numbers are available for PROGRAM method.
                OPEN   c_count_anon_num_prog;
		FETCH  c_count_anon_num_prog INTO l_anon_id_count;
		CLOSE  c_count_anon_num_prog;

		 -- Count the number of Student Program Attempts
                OPEN   c_count_program_reqd;
		FETCH  c_count_program_reqd INTO  l_anon_id_required;
		CLOSE  c_count_program_reqd;

	ELSIF  l_method = 'SECTION' THEN
        -- Count the Student Unit Attempts for Unit Sections with anonymous assessment item
        -- OR unit grading
                OPEN c_count_section_reqd(l_ld_cal_type,l_ld_sequence_number);
		FETCH  c_count_section_reqd INTO  l_anon_id_required;
		CLOSE  c_count_section_reqd;

    ELSIF l_method = 'ASSESSMENT' THEN
        -- Count the Student Unit Attempt Assessment Items for anonymous Assessment Types
        -- in anonymous Unit Sections
                OPEN   c_count_assessment_reqd(l_ld_cal_type,l_ld_sequence_number);
		FETCH  c_count_assessment_reqd INTO  l_anon_id_required;
		CLOSE  c_count_assessment_reqd;

    END IF;
         -- Check whether Anonymous Numbers are already available for the
	 -- Context Load Calendar. If its present the Range passed will not be considered
	 -- and existing Anonymous Numbers will be used.
    IF l_anon_id_count > 0 THEN

        FND_MESSAGE.SET_NAME('IGS','IGS_AS_ANON_RANGE_N_USE');
	FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
        FND_FILE.PUT_LINE(FND_FILE.LOG, FND_MESSAGE.GET);
	FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

	  -- Check if the available anonymous numbers cover the required number
	  -- If enough Anonymous Numbers are not present then show ERROR with proper Message.

	    IF l_anon_id_count < l_anon_id_required THEN

            FND_MESSAGE.SET_NAME('IGS','IGS_AS_NOT_ENOUGH_ANON_NUMBER');
            IGS_GE_MSG_STACK.ADD;
            RAISE PARAM_ERROR;
    	END IF;

          -- If there are no Anonymous Numbers available generate new ones
		  -- only if the REQUIRED is > 0.
    ELSIF  l_anon_id_required > 0 THEN
          -- Check if the anonymous number range covers the number required plus 50% to allow for growth
          -- If the Range is not sufficient as per the ANON ID required then show ERROR with proper Message.
	    IF (p_max_number - NVL(p_min_number, 0)) < (NVL(l_anon_id_required, 1) * 1.5) THEN
             FND_MESSAGE.SET_NAME('IGS','IGS_AS_ANON_RANGE_TOO_SMALL');
             IGS_GE_MSG_STACK.ADD;
             RAISE PARAM_ERROR;
    	    END IF;


        -- Added by DDEY as a part of Bug # 2280067 .
        -- Return an error if the Range is to large for a Binary Integer
	-- The process becomes less efficient, in case the the whole table is searched, so the
	-- number of records searched are reduced. This acts as temporary solution.

        IF (p_max_number - NVL(p_min_number, 0)) > 1000000000 THEN
            FND_MESSAGE.SET_NAME('IGS','IGS_AS_OUT_ANON_RANGE');
            IGS_GE_MSG_STACK.ADD;
            RAISE PARAM_ERROR;
        END IF;

         -- Populate a PL/SQL table with an anonymous number and a random number
    	FOR l_anonymous_number IN NVL(p_min_number,1) .. p_max_number  LOOP

     -- Added by DDEY as a part of Bug # 2280067 .
     -- This would avoid the negative values and the non-unique values, to be generated.

	   LOOP
	    -- swaghmar 23-Feb-2006 Bug# 5056679
	       l_random_number := FND_CRYPTO.SmallRandomNumber;
               IF NOT temp_table.EXISTS(l_random_number) THEN
                    temp_table(l_random_number) := l_anonymous_number;
                    EXIT;
                END IF;
           END LOOP;

        END LOOP;

        l_index := temp_table.FIRST;

        LOOP

     -- Added by DDEY as a part of Bug # 2280067 .
     -- The If condition is added

	     IF temp_table.EXISTS(l_index) THEN

               -- Insert the Randomly generated Anonymous Numbers
    		  IF c_method_rec.method = 'PROGRAM' THEN
	        	     igs_as_anon_number_pkg.insert_row(
 			             x_rowid               => l_rowid,
				     x_anum_id             => l_anum_id,
                                     x_anonymous_number    => temp_table(l_index),
                                     x_load_cal_type       => NULL,
                                     x_load_ci_sequence_number => NULL,
                                     x_mode                => 'R');
                     ELSE
    		            igs_as_anon_number_pkg.insert_row(
 			             x_rowid               => l_rowid,
			             x_anum_id             => l_anum_id,
                                     x_anonymous_number    => temp_table(l_index),
                                     x_load_cal_type       => l_ld_cal_type,
                                     x_load_ci_sequence_number => l_ld_sequence_number,
                                     x_mode                => 'R');
     		  END IF;
               END IF;
                    EXIT WHEN  l_index = temp_table.LAST;
                    l_index := temp_table.NEXT(l_index);
        END LOOP;

         -- Delete all the Records from the PL/SQL table
        temp_table.DELETE;

    END IF;

    FND_FILE.PUT_LINE(FND_FILE.LOG,'+-------------------------Persons Processed---------------------------------+');

    IF  l_method = 'PROGRAM' THEN
	     FOR c_spa_rec IN c_spa
		 LOOP
		    OPEN    c_person(c_spa_rec.person_id);
			FETCH   c_person  INTO  c_person_rec;
			CLOSE   c_person;

            FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Person Number          : ' || c_person_rec.party_number);
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Course Code            : ' || c_spa_rec.course_cd);
            FND_FILE.PUT_LINE(FND_FILE.LOG,' ');

            sub_get_insert(	p_method => l_method,
                            p_person_id		=> c_spa_rec.person_id,
                            p_course_cd		=> c_spa_rec.course_cd,
                            p_unit_cd			=> NULL,
                            p_teach_cal_type	=> NULL,
                            p_teach_ci_sequence_number => NULL,
                            p_uoo_id			=> NULL,
                            p_assessment_type	=> NULL,
                            p_load_cal_type	=> NULL,
                            p_load_ci_sequence_number => NULL);

		 END LOOP;

	ELSIF l_method = 'SECTION' THEN

         FOR c_sua_rec IN c_sua(l_ld_cal_type,l_ld_sequence_number)
		 LOOP

			OPEN    c_person(c_sua_rec.person_id);
			FETCH   c_person  INTO  c_person_rec;
			CLOSE   c_person;

			FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Person Number          : ' || c_person_rec.party_number);
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Course Code            : ' || c_sua_rec.course_cd);
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Unit Code              : ' || c_sua_rec.unit_cd);
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Unit Offering Option ID: ' || c_sua_rec.uoo_id);
            FND_FILE.PUT_LINE(FND_FILE.LOG,' ');

            sub_get_insert(	p_method => l_method,
                            p_person_id		=> c_sua_rec.person_id,
                            p_course_cd		=> c_sua_rec.course_cd,
                            p_unit_cd			=> c_sua_rec.unit_cd,
                            p_teach_cal_type	=> c_sua_rec.cal_type,
                            p_teach_ci_sequence_number => c_sua_rec.ci_sequence_number,
                            p_uoo_id			=> c_sua_rec.uoo_id,
                            p_assessment_type	=> NULL,
                            p_load_cal_type	=> l_ld_cal_type,
                            p_load_ci_sequence_number => l_ld_sequence_number);

		 END LOOP;

    ELSIF  l_method = 'ASSESSMENT' THEN

    	 FOR c_suaai_rec IN c_suaai(l_ld_cal_type,l_ld_sequence_number)
		 LOOP

 			OPEN    c_person(c_suaai_rec.person_id);
			FETCH   c_person  INTO  c_person_rec;
			CLOSE   c_person;

			FND_FILE.PUT_LINE(FND_FILE.LOG,' ');
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Person Number          : ' || c_person_rec.party_number);
            FND_FILE.PUT_LINE(FND_FILE.LOG,'Assessment Type        : ' || c_suaai_rec.assessment_type);
            FND_FILE.PUT_LINE(FND_FILE.LOG,' ');

            sub_get_insert(	p_method => l_method,
                            p_person_id		=> c_suaai_rec.person_id,
                            p_course_cd		=> NULL,
                            p_unit_cd			=> NULL,
                            p_teach_cal_type	=> NULL,
                            p_teach_ci_sequence_number => NULL,
                            p_uoo_id			=> NULL,
                            p_assessment_type	=> c_suaai_rec.assessment_type,
                            p_load_cal_type	=> l_ld_cal_type,
                            p_load_ci_sequence_number => l_ld_sequence_number);

           END LOOP;
	END IF;


 EXCEPTION

    WHEN PARAM_ERROR  THEN
	   ROLLBACK ;
       retcode := 1 ;

       FND_FILE.PUT_LINE(fnd_file.log,' ');
	   FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
       FND_FILE.PUT_LINE(fnd_file.log,' ');


    WHEN OTHERS THEN
       ROLLBACK ;
       retcode := 2 ;
   	   FND_FILE.PUT_LINE(FND_FILE.LOG,'SQL Error Message :'||SQLERRM);
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
       FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_ANON_GRD_PKG.MNT_ANON_ID');
       FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
       IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL ;

 END mnt_anon_id;


FUNCTION   get_anon_id (
     p_person_id           IN    hz_parties.party_id%TYPE,
     p_course_cd           IN    igs_en_su_attempt_all.course_cd%TYPE,
     p_unit_cd             IN    igs_en_su_attempt_all.unit_cd%TYPE,
     p_teach_cal_type      IN    igs_ca_inst_all.cal_type%TYPE,
     p_teach_ci_sequence_number  IN  igs_ca_inst_all.sequence_number%TYPE,
     p_uoo_id              IN    igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
     p_ass_id              IN    igs_as_assessmnt_itm_all.ass_id%TYPE,
     p_unit_grading_ind    IN    VARCHAR2
) RETURN VARCHAR2 IS
/*
  ||  Created By : pkpatel
  ||  Created On : 28-JAN-2002
  ||  Purpose :  This function returns the Anonymous ID of the Student as Parameters passed.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
*/

  CURSOR c_anip
  IS
  SELECT anonymous_id
  FROM	 igs_as_anon_id_ps		anip,
         igs_en_su_attempt		sua,
	     igs_ps_unit_ofr_opt	uoo
  WHERE	sua.person_id = p_person_id
  AND	sua.course_cd = p_course_cd
  AND	sua.unit_cd   = p_unit_cd
  AND	sua.cal_type  = p_teach_cal_type
  AND	sua.ci_sequence_number = p_teach_ci_sequence_number
  AND	sua.uoo_id  = p_uoo_id
  AND	uoo.unit_cd = p_unit_cd
  AND	uoo.cal_type = p_teach_cal_type
  AND	uoo.ci_sequence_number = p_teach_ci_sequence_number
  AND	uoo.version_number = sua.version_number
  AND	uoo.uoo_id = sua.uoo_id
  AND	anip.person_id = p_person_id
  AND	anip.course_cd = p_course_cd
  AND	(	(	p_unit_grading_ind = 'Y'
		       AND	uoo.anon_unit_grading_ind = 'Y')
           OR	(	p_unit_grading_ind = 'N'
		         AND	p_ass_id IS NOT NULL
                 AND	uoo.anon_assess_grading_ind = 'Y'
                 AND	'Y' = (	SELECT	ast.anon_grading_ind
                     	       	FROM	igs_as_assessmnt_typ		ast,
                            			igs_as_assessmnt_itm		ai
                     	       	WHERE	ai.ass_id = p_ass_id
                         		AND	ai.assessment_type = ast.assessment_type)));

  CURSOR c_aniu
  IS
  SELECT	anonymous_id
  FROM	igs_as_anon_id_us	aniu,
        igs_en_su_attempt	sua,
	    igs_ps_unit_ofr_opt	uoo
  WHERE	sua.person_id = p_person_id
  AND	sua.course_cd = p_course_cd
  AND	sua.unit_cd = p_unit_cd
  AND	sua.cal_type = p_teach_cal_type
  AND	sua.ci_sequence_number = p_teach_ci_sequence_number
  AND	sua.uoo_id = p_uoo_id
  AND	uoo.uoo_id = sua.uoo_id
  AND	uoo.unit_cd = p_unit_cd
  AND	uoo.cal_type = p_teach_cal_type
  AND	uoo.ci_sequence_number = p_teach_ci_sequence_number
  AND	uoo.version_number = sua.version_number
  AND	aniu.person_id = p_person_id
  AND	aniu.course_cd = p_course_cd
  AND	aniu.unit_cd = p_unit_cd
  AND	aniu.teach_cal_type = p_teach_cal_type
  AND	aniu.teach_ci_sequence_number = p_teach_ci_sequence_number
  AND	aniu.uoo_id = p_uoo_id
  AND	(	(	p_unit_grading_ind = 'Y'
        		AND	uoo.anon_unit_grading_ind = 'Y')
           OR	(	p_unit_grading_ind = 'N'
        		AND	p_ass_id IS NOT NULL
                AND	uoo.anon_assess_grading_ind = 'Y'
                AND	'Y' = (	SELECT	ast.anon_grading_ind
                 	       	FROM	igs_as_assessmnt_typ		ast,
                        			igs_as_assessmnt_itm		ai
                           	WHERE	ai.ass_id = p_ass_id
               				AND	ai.assessment_type = ast.assessment_type)));

  CURSOR c_ania
  IS
  SELECT	anonymous_id
  FROM	igs_as_anon_id_ass	ania,
    	igs_en_su_attempt	sua,
	    igs_ps_unit_ofr_opt	uoo,
        igs_ca_teach_to_load_v	ttl
  WHERE	sua.person_id = p_person_id
  AND	sua.course_cd = p_course_cd
  AND	sua.unit_cd = p_unit_cd
  AND	sua.cal_type = p_teach_cal_type
  AND	sua.ci_sequence_number = p_teach_ci_sequence_number
  AND	sua.uoo_id = p_uoo_id
  AND	uoo.unit_cd = p_unit_cd
  AND	uoo.cal_type = p_teach_cal_type
  AND	uoo.ci_sequence_number = p_teach_ci_sequence_number
  AND	uoo.version_number = sua.version_number
  AND	uoo.uoo_id = sua.uoo_id
  AND	ania.person_id = p_person_id
  AND	ania.load_cal_type = ttl.load_cal_type
  AND	ania.load_ci_sequence_number = ttl.load_ci_sequence_number
  AND	ttl.teach_cal_type = p_teach_cal_type
  AND	ttl.teach_ci_sequence_number = p_teach_ci_sequence_number
  AND	ttl.load_start_dt = (SELECT	MIN(ttl2.load_start_dt)
    			             FROM	igs_ca_teach_to_load_v	ttl2
			                 WHERE	ttl2.teach_cal_type = p_teach_cal_type
 			                 AND	ttl2.teach_ci_sequence_number = p_teach_ci_sequence_number)
  AND	(	(	p_unit_grading_ind = 'Y'
		     AND	uoo.anon_unit_grading_ind = 'Y'
		     AND	ania.assessment_type = (SELECT anm.assessment_type
			                         		FROM	igs_as_anon_method  anm
                         					WHERE	anm.method = 'ASSESSMENT'
                                            AND	anm.load_cal_type = ttl.load_cal_type))
           OR	(	p_ass_id IS NOT NULL
		          AND	p_unit_grading_ind = 'N'
                  AND	uoo.anon_assess_grading_ind = 'Y'
                  AND	ania.assessment_type = (SELECT	 ai.assessment_type
	       		                                FROM	igs_as_assessmnt_typ		ast,
                                         				igs_as_assessmnt_itm		ai
                                 	       		WHERE	ai.ass_id = p_ass_id
                                    			AND	    ai.assessment_type = ast.assessment_type
                                                AND	    ast.anon_grading_ind = 'Y')));

  CURSOR  c_method
  IS
  SELECT  anm.method
  FROM	  igs_ca_teach_to_load_v	ttl,
          igs_as_anon_method		anm
  WHERE	ttl.teach_cal_type = p_teach_cal_type
  AND	ttl.teach_ci_sequence_number = p_teach_ci_sequence_number
  AND	ttl.load_start_dt = (SELECT	MIN(ttl2.load_start_dt)
			                 FROM	igs_ca_teach_to_load_v	ttl2
			                 WHERE	ttl2.teach_cal_type = p_teach_cal_type
 			                 AND	ttl2.teach_ci_sequence_number = p_teach_ci_sequence_number)
  AND	ttl.load_cal_type = anm.load_cal_type;

  c_method_rec  c_method%ROWTYPE;
  c_ania_rec    c_ania%ROWTYPE;
  c_aniu_rec    c_aniu%ROWTYPE;
  c_anip_rec    c_anip%ROWTYPE;

BEGIN

      -- Check whether all the Parameters are passed properly. If any of the Parameter is passed INVALID then
	  -- return NULL.
     IF	p_person_id IS NULL OR
        p_course_cd IS NULL OR
        p_unit_cd IS NULL OR
        p_teach_cal_type IS NULL OR
        p_teach_ci_sequence_number IS NULL OR
        p_uoo_id IS NULL OR
        (p_unit_grading_ind = 'Y' AND p_ass_id IS NOT NULL) OR
        (NVL(p_unit_grading_ind, 'N') = 'N' AND p_ass_id IS NULL) THEN

       RETURN NULL;

     END IF;


     OPEN    c_method;
     FETCH   c_method  INTO  c_method_rec;

	       -- Return NULL if no method defined
	       IF  c_method%NOTFOUND  THEN
		       CLOSE  c_method;
		       RETURN  NULL;
           END IF;
	  CLOSE   c_method;

      IF  c_method_rec.method = 'PROGRAM' THEN
	        OPEN   c_anip;
			FETCH  c_anip  INTO  c_anip_rec;
			     IF c_anip%FOUND  THEN
                     CLOSE  c_anip;
					 RETURN  c_anip_rec.anonymous_id;
				 END IF;

			CLOSE  c_anip;

       ELSIF  c_method_rec.method = 'SECTION' THEN
	        OPEN   c_aniu;
			FETCH  c_aniu  INTO  c_aniu_rec;
			     IF c_aniu%FOUND  THEN
                     CLOSE  c_aniu;
					 RETURN  c_aniu_rec.anonymous_id;
				 END IF;
			CLOSE  c_aniu;

       ELSIF   c_method_rec.method = 'ASSESSMENT' THEN
	        OPEN   c_ania;
			FETCH  c_ania  INTO  c_ania_rec;
			     IF c_ania%FOUND  THEN
                     CLOSE  c_ania;
					 RETURN  c_ania_rec.anonymous_id;
				 END IF;
			CLOSE  c_ania;

       END IF;

       -- Return NULL if for any of the method the Anonymous ID is not found
       RETURN  NULL;

EXCEPTION
     WHEN OTHERS THEN
	    FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_ANON_GRD_PKG.GET_ANON_ID');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;

END get_anon_id;



FUNCTION   get_person_id (
     p_anonymous_id        IN    igs_as_anon_id_ps.anonymous_id%TYPE,
     p_teach_cal_type      IN    igs_ca_inst_all.cal_type%TYPE,
     p_teach_ci_sequence_number  IN  igs_ca_inst_all.sequence_number%TYPE
) RETURN NUMBER IS

/*
  ||  Created By : pkpatel
  ||  Created On : 28-JAN-2002
  ||  Purpose :  This function returns the person ID of the Student as Parameters passed.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
*/

  CURSOR c_anip
  IS
  SELECT	person_id
  FROM	igs_as_anon_id_ps	anip
  WHERE anip.anonymous_id = p_anonymous_id;

  CURSOR c_aniu
  IS
  SELECT	person_id
  FROM	igs_as_anon_id_us	aniu,
        igs_ca_teach_to_load_v	ttl
  WHERE	aniu. anonymous_id = p_anonymous_id
  AND	aniu.load_cal_type = ttl.load_cal_type
  AND	aniu.load_ci_sequence_number = ttl.load_ci_sequence_number
  AND	ttl.teach_cal_type = p_teach_cal_type
  AND	ttl.teach_ci_sequence_number = p_teach_ci_sequence_number
  AND	ttl.load_start_dt = ( SELECT MIN(ttl2.load_start_dt)
                              FROM	igs_ca_teach_to_load_v	ttl2
							  WHERE   ttl2.teach_cal_type = p_teach_cal_type
							  AND ttl2.teach_ci_sequence_number =  p_teach_ci_sequence_number);
  CURSOR c_ania
  IS
  SELECT person_id
  FROM	 igs_as_anon_id_ass  ania,
         igs_ca_teach_to_load_v	ttl
  WHERE	 ania. anonymous_id = p_anonymous_id
  AND	 ania.load_cal_type = ttl.load_cal_type
  AND	 ania.load_ci_sequence_number = ttl.load_ci_sequence_number
  AND	 ttl.teach_cal_type = p_teach_cal_type
  AND	 ttl.teach_ci_sequence_number = p_teach_ci_sequence_number
  AND	 ttl.load_start_dt = ( SELECT MIN(ttl2.load_start_dt)
                               FROM	 igs_ca_teach_to_load_v	ttl2
							   WHERE ttl2.teach_cal_type = p_teach_cal_type
							   AND   ttl2.teach_ci_sequence_number = p_teach_ci_sequence_number);


  -- Get the Anonymous Grading Method for this Load Calendar
  CURSOR  c_method
  IS
  SELECT	anm.method
  FROM	igs_ca_teach_to_load_v	ttl,
     	igs_as_anon_method		anm
  WHERE	ttl.teach_cal_type = p_teach_cal_type
  AND	ttl.teach_ci_sequence_number = p_teach_ci_sequence_number
  AND	ttl.load_start_dt = (SELECT	MIN(ttl2.load_start_dt)
                			 FROM	igs_ca_teach_to_load_v	ttl2
                			 WHERE	ttl2.teach_cal_type = p_teach_cal_type
                   			 AND	ttl2.teach_ci_sequence_number = p_teach_ci_sequence_number)
  AND	ttl.load_cal_type = anm.load_cal_type;

  c_method_rec  c_method%ROWTYPE;
  c_ania_rec    c_ania%ROWTYPE;
  c_aniu_rec    c_aniu%ROWTYPE;
  c_anip_rec    c_anip%ROWTYPE;

BEGIN

      -- Check whether all the Parameters are passed properly. If any of the Parameter is passed INVALID then
	  -- return NULL.
     IF	p_anonymous_id IS NULL OR
        p_teach_cal_type IS NULL OR
        p_teach_ci_sequence_number IS NULL THEN

        RETURN NULL;

     END IF;

      OPEN    c_method;
	  FETCH   c_method  INTO  c_method_rec;

	       -- Return NULL if no method defined
	       IF  c_method%NOTFOUND  THEN
		       CLOSE  c_method;
		       RETURN  NULL;
           END IF;
	  CLOSE   c_method;

      IF  c_method_rec.method = 'PROGRAM' THEN
	        OPEN   c_anip;
			FETCH  c_anip  INTO  c_anip_rec;
			     IF c_anip%FOUND  THEN
                     CLOSE  c_anip;
					 RETURN  c_anip_rec.person_id;
				 END IF;
			CLOSE  c_anip;

       ELSIF  c_method_rec.method = 'SECTION' THEN
	        OPEN   c_aniu;
			FETCH  c_aniu  INTO  c_aniu_rec;
			     IF c_aniu%FOUND  THEN
                     CLOSE  c_aniu;
					 RETURN  c_aniu_rec.person_id;
				 END IF;
			CLOSE  c_aniu;

       ELSIF   c_method_rec.method = 'ASSESSMENT' THEN
	        OPEN   c_ania;
			FETCH  c_ania  INTO  c_ania_rec;
			     IF c_ania%FOUND  THEN
                     CLOSE  c_ania;
					 RETURN  c_ania_rec.person_id;
				 END IF;
			CLOSE  c_ania;

       END IF;

       -- Return NULL if for any of the method the Person ID is not found
       RETURN  NULL;

EXCEPTION
     WHEN OTHERS THEN
	    FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_ANON_GRD_PKG.GET_PERSON_ID');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
END get_person_id;


FUNCTION   user_anon_id (
     p_anonymous_number         IN    varchar2,
     p_method                   IN    igs_as_anon_method.METHOD%TYPE,
     p_person_id                IN    hz_parties.party_id%TYPE,
     p_course_cd                IN    igs_en_su_attempt_all.course_cd%TYPE,
     p_unit_cd                  IN    igs_en_su_attempt_all.unit_cd%TYPE,
     p_teach_cal_type           IN    igs_ca_inst_all.cal_type%TYPE,
     p_teach_ci_sequence_number IN    igs_ca_inst_all.sequence_number%TYPE,
     p_uoo_id                   IN    igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
     p_assessment_type          IN    igs_as_assessmnt_typ.assessment_type%TYPE,
     p_load_cal_type            IN    igs_ca_inst_all.cal_type%TYPE,
     p_load_ci_sequence_number  IN    igs_ca_inst_all.sequence_number%TYPE
) RETURN VARCHAR2 IS
/*
  ||  Created By : pkpatel
  ||  Created On : 28-JAN-2002
  ||  Purpose :  The logic for this function will be user defined to allow Institutions
  ||             to define their own specific Anonymous IDs
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
*/

BEGIN

   -- The logic for this function will be user defined to allow Institutions to define their own specific Anonymous IDs
  NULL;
  RETURN NULL;

EXCEPTION
     WHEN OTHERS THEN
	    FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_AS_ANON_GRD_PKG.USER_ANON_ID');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
END user_anon_id;

END igs_as_anon_grd_pkg;

/
