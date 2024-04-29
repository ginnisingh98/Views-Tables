--------------------------------------------------------
--  DDL for Package Body IGS_CA_VAL_CIR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CA_VAL_CIR" AS
/* $Header: IGSCA06B.pls 120.1 2005/08/11 07:54:32 appldev ship $ */

  /******************************************************************
  Created By        :
  Date Created By   :
  Purpose           :
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who		 When		 What
  ssawhney      11-apr-2005	 Bug 4252347. Modified find_subordinate, to match the complete CI and not just cal type.
				 major perf gain.
  smadathi      09-Sep-2002      Bug# 2086177. Modified calp_val_ci_rltnshp to
                                 establish relation between Admission Calendar
				 instance and Academic Term(Load) Calendar instance.
  masehgal      29-Aug-2002      # 2442637   SWSD01_Calendar Build
                                 Added validations for Award categories
				 Corrected logic for 'NEW' categories
				 And existing validations
  schodava	 18-Apr-2002	 Enh # 2279265
				 Modifies the FUNCTION calp_val_ci_rltnshp
  schodava	 21-Jan-2002	 Enh # 2187247
				 Modifies the FUNCTION calp_val_ci_rltnshp
  ******************************************************************/

  -- To validate that the calendar has a IGS_CA_TYPE.s_cal_cat of type 'LOAD'
  FUNCTION calp_val_cat_load( p_cal_type IN VARCHAR2 ,
                              p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

  	gv_other_detail		VARCHAR2(255);

  BEGIN
    DECLARE
  	   cst_load	CONSTANT	IGS_CA_TYPE.s_cal_cat%TYPE := 'LOAD';
  	   v_s_cal_cat			IGS_CA_TYPE.s_cal_cat%TYPE;

  	   CURSOR c_cat IS
  		   SELECT s_cal_cat
  		   FROM	 igs_ca_type	cat
  		   WHERE	 cat.cal_type = p_cal_type;

      BEGIN
  	     OPEN c_cat;
        FETCH c_cat INTO v_s_cal_cat;
        CLOSE c_cat;

        IF v_s_cal_cat <> cst_load THEN
           p_message_name := 'IGS_CA_CALTYPE_LOAD_UPD';
           RETURN FALSE;
        END IF;

  	     p_message_name := NULL;
  	     RETURN TRUE;

      EXCEPTION
        WHEN OTHERS THEN
          IF (c_cat%ISOPEN) THEN
             CLOSE c_cat;
          END IF;
  		    RAISE;
        END;
   END calp_val_cat_load;


  --
  -- To validate calendar instanes in a relationship
  -- Code changed for Bug 4252347. by ssawhney
  FUNCTION calp_val_cir_ci( p_sub_cal_type IN VARCHAR2 ,
                            p_sub_ci_sequence_number IN NUMBER ,
                            p_sup_cal_type IN VARCHAR2 ,
                            p_sup_ci_sequence_number IN NUMBER ,
                            p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS

   	cst_planned	CONSTANT VARCHAR2(8) := 'PLANNED';
   	cst_active	CONSTANT VARCHAR2(8) := 'ACTIVE';
   	cst_inactive 	CONSTANT VARCHAR2(8) := 'INACTIVE';
   	v_cal_inst_rltshp_sup_rec	IGS_CA_INST_REL%ROWTYPE;
   	v_cal_inst_rltshp_sub_rec	IGS_CA_INST_REL%ROWTYPE;
   	e_superior_not_found	EXCEPTION;
   	e_subordinate_not_found	EXCEPTION;
   	v_superior_found		BOOLEAN := FALSE;
   	v_subordinate_found	BOOLEAN := FALSE;
   	v_other_detail		VARCHAR2(255);
   	v_sup_cal_status	IGS_CA_STAT.s_cal_status%TYPE;
   	v_sub_cal_status	IGS_CA_STAT.s_cal_status%TYPE;

      CURSOR	c_cal_inst_rltshp_sup IS
   	   SELECT *
         FROM	 igs_ca_inst_rel
   	   WHERE  sub_cal_type = p_sub_cal_type
   	   AND    sub_ci_sequence_number = p_sub_ci_sequence_number
   	   AND    (sup_cal_type <> p_sup_cal_type)
   	   AND    (sup_ci_sequence_number <> p_sup_ci_sequence_number);

      CURSOR	c_cal_inst_rltshp_sub IS
   	   SELECT *
         FROM	 igs_ca_inst_rel
   	   WHERE  sup_cal_type = p_sup_cal_type
   	   AND    sup_ci_sequence_number = p_sup_ci_sequence_number
   	   AND    (sub_cal_type <> p_sub_cal_type)
   	   AND    (sub_ci_sequence_number <> p_sub_ci_sequence_number);

   	CURSOR	c_cal_instance ( cp_cal_type              igs_ca_inst.cal_type%TYPE,
   		                       cp_cal_sequence_number   igs_ca_inst.sequence_number%TYPE) IS
   		SELECT *
   		FROM   igs_ca_inst
   		WHERE	 cal_type = cp_cal_type
   		AND    sequence_number = cp_cal_sequence_number ;

   	CURSOR  c_cal_status( cp_cal_status   igs_ca_stat.cal_status%TYPE) IS
   		SELECT *
   		FROM   igs_ca_stat
   		WHERE  cal_status = cp_cal_status;

	   FUNCTION calp_find_superior( p_sup_cal_type 		      igs_ca_inst_rel.sup_cal_type%TYPE,
					p_sup_ci_sequence_number      igs_ca_inst_rel.sup_ci_sequence_number%TYPE,
					p_sub_cal_type		      igs_ca_inst_rel.sub_cal_type%TYPE,
					p_sub_ci_sequence_number      igs_ca_inst_rel.sub_ci_sequence_number%TYPE)
           RETURN BOOLEAN AS

   	   v_cal_inst_rltshp_sup_rec	igs_ca_inst_rel%ROWTYPE;

   	   CURSOR	c_cal_inst_rltshp_sup( cp_sup_cal_type             igs_ca_inst_rel.sup_cal_type%TYPE,
                                       cp_sup_ci_sequence_number   igs_ca_inst_rel.sup_ci_sequence_number%TYPE) IS
   		SELECT  *
   		FROM	  igs_ca_inst_rel
   		WHERE	  sub_cal_type = cp_sup_cal_type
   		AND	  sub_ci_sequence_number = cp_sup_ci_sequence_number;

   	   BEGIN
   		IF (c_cal_inst_rltshp_sup%ISOPEN = FALSE) THEN
   		OPEN c_cal_inst_rltshp_sup( p_sup_cal_type, p_sup_ci_sequence_number);
   		END IF;

   		LOOP
   			FETCH c_cal_inst_rltshp_sup INTO	v_cal_inst_rltshp_sup_rec;
  			EXIT WHEN c_cal_inst_rltshp_sup%NOTFOUND;

  			IF (v_cal_inst_rltshp_sup_rec.sup_cal_type = p_sub_cal_type AND
			    v_cal_inst_rltshp_sup_rec.sup_ci_sequence_number = p_sub_ci_sequence_number	) THEN
  			    CLOSE c_cal_inst_rltshp_sup;
                            RETURN TRUE;
  		        ELSE
  		 		   IF (calp_find_superior
				      ( v_cal_inst_rltshp_sup_rec.sup_cal_type,
                                        v_cal_inst_rltshp_sup_rec.sup_ci_sequence_number,
                                        p_sub_cal_type,
					p_sub_ci_sequence_number) = TRUE) THEN
  					   CLOSE c_cal_inst_rltshp_sup;
  					   RETURN TRUE;
  				   END IF;
  			   END IF;
  		   END LOOP;

  		IF (c_cal_inst_rltshp_sup%ISOPEN) THEN
  			CLOSE c_cal_inst_rltshp_sup;
  		END IF;

  		RETURN FALSE;

  	END calp_find_superior;

  	FUNCTION calp_find_subordinate( p_sub_cal_type		igs_ca_inst_rel.sub_cal_type%TYPE,
					p_sub_ci_sequence_number igs_ca_inst_rel.sub_ci_sequence_number%TYPE,
					p_sup_cal_type		igs_ca_inst_rel.sup_cal_type%TYPE,
					p_sup_ci_sequence_number igs_ca_inst_rel.sup_ci_sequence_number%TYPE)
					--simran perf
					--)
  	RETURN BOOLEAN AS

  	v_cal_inst_rltshp_sub_rec	igs_ca_inst_rel%ROWTYPE;

  	CURSOR c_cal_inst_rltshp_sub( cp_sub_cal_type igs_ca_inst_rel.sub_cal_type%TYPE,
				      cp_sub_ci_sequence_number   igs_ca_inst_rel.sub_ci_sequence_number%TYPE) IS
				      ----simran perf
  	SELECT *
  	FROM	 igs_ca_inst_rel
  	WHERE	 sup_cal_type = cp_sub_cal_type
	AND	 sup_ci_sequence_number = cp_sub_ci_sequence_number; --simran perf --this was missing.
					--due to which it was FTS on ca_inst_rel and doing recursive FTS as this func is recursive.


  	BEGIN
  		IF (c_cal_inst_rltshp_sub%ISOPEN = FALSE) THEN
  			OPEN c_cal_inst_rltshp_sub( p_sub_cal_type, p_sub_ci_sequence_number); --simran perf
  	  	END IF;

  		LOOP
  		  FETCH 	c_cal_inst_rltshp_sub
  		  INTO		v_cal_inst_rltshp_sub_rec;
  		  EXIT WHEN	c_cal_inst_rltshp_sub%NOTFOUND;
  		  IF (    v_cal_inst_rltshp_sub_rec.sub_cal_type = p_sup_cal_type AND
			  v_cal_inst_rltshp_sub_rec.sub_ci_sequence_number = p_sup_ci_sequence_number	 ) THEN
			--simran perf, validate whether sub's cursors, sub cal = sup cal passed.
  			CLOSE c_cal_inst_rltshp_sub;
  		  	RETURN TRUE;
  		  ELSE
  		    IF (calp_find_subordinate( v_cal_inst_rltshp_sub_rec.sub_cal_type,
		                               v_cal_inst_rltshp_sub_rec.sub_ci_sequence_number,
						p_sup_cal_type,
						p_sup_ci_sequence_number)) = TRUE THEN
  				 CLOSE c_cal_inst_rltshp_sub;
  		  		 RETURN TRUE;
  		  	 END IF;
  		  END IF;

  		END LOOP;

  		IF (c_cal_inst_rltshp_sub%ISOPEN) THEN
  		   CLOSE c_cal_inst_rltshp_sub;
  		END IF;

  		RETURN FALSE;

  	END calp_find_subordinate;

  	BEGIN
  		-- Validate sub-ordinate and superior calendar types cannot be the same
  		IF(p_sup_cal_type = p_sub_cal_type) THEN
  			p_message_name := 'IGS_CA_SUBORD_SUPCAL_NOTSAME';
  			RETURN FALSE;
  		END IF;
  		-- Validate superior calendar instance exists
  		-- Retain system calendar status
  		FOR c_cal_instance_rec IN c_cal_instance( p_sup_cal_type, p_sup_ci_sequence_number)
  		LOOP
  			v_superior_found := TRUE;
  			FOR v_cal_status_rec IN c_cal_status( c_cal_instance_rec.cal_status)
  			LOOP
  			v_sup_cal_status := v_cal_status_rec.s_cal_status;
  			END LOOP;
  		END LOOP;

  		IF (v_superior_found = FALSE) THEN
  			RAISE e_superior_not_found;
  		END IF;

  		-- Validate sub-ordinate calendar instance exists
  		-- Retain system calendar status
  		FOR c_cal_instance_rec IN c_cal_instance ( p_sub_cal_type, p_sub_ci_sequence_number)
  		LOOP
  			v_subordinate_found := TRUE;
  			FOR v_cal_status_rec IN c_cal_status( c_cal_instance_rec.cal_status)
  			LOOP
  				v_sub_cal_status := v_cal_status_rec.s_cal_status;
  			END LOOP;
  		END LOOP;

  		IF (v_subordinate_found = FALSE) THEN
  			RAISE e_subordinate_not_found;
  		END IF;

  		-- Validate calendar status between sub-ordinate and superior
  		IF (v_sup_cal_status = cst_planned AND
  		    v_sub_cal_status = cst_inactive) THEN
  			   p_message_name :='IGS_CA_SUBORD_NOT_INACTIVE_ST';
  			   RETURN FALSE;
  		END IF;

  		IF (v_sup_cal_status = cst_planned OR
  		   v_sup_cal_status = cst_inactive) AND
  		   (v_sub_cal_status = cst_active) THEN
  			   p_message_name :='IGS_CA_SUBORD_CANNOT_ACTIVEST';
  			   RETURN FALSE;
  		END IF;
  		IF (v_sup_cal_status = cst_inactive AND
  		    v_sub_cal_status = cst_planned) THEN
  			   p_message_name :='IGS_CA_SUBORD_CANNOT_PLANST';
  			   RETURN FALSE;
  		END IF;

  		-- Validate that sub-ordinate does not already exist in the superior calendar
  		--structure
  		IF (calp_find_superior(p_sup_cal_type,
                             p_sup_ci_sequence_number,
                             p_sub_cal_type,
			     p_sub_ci_sequence_number) = TRUE) THEN
  	  		p_message_name := 'IGS_CA_SUP_SUBORD_EXISTS';
  			RETURN FALSE;
  		END IF;
  		-- Validate that superior does not already exist in the sub-ordinate calendar
  		--structure
  		IF (calp_find_subordinate(p_sub_cal_type,
					p_sub_ci_sequence_number,
					p_sup_cal_type,
					--p_sup_ci_sequence_number)) THEN  --simran perf
					p_sup_ci_sequence_number)) THEN
  			p_message_name := 'IGS_CA_SUP_SUBORD_EXISTS';
  			RETURN FALSE;
  		END IF;

  		p_message_name :=NULL;
      RETURN TRUE;

  		EXCEPTION
  		   WHEN e_superior_not_found THEN
  			   p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
  			   RETURN FALSE;
  		   WHEN e_subordinate_not_found THEN
  			   p_message_name := 'IGS_GE_VAL_DOES_NOT_XS';
  			   RETURN FALSE;
    	END calp_val_cir_ci;


  --
  -- To validate calendar instances categories in a relationship
  FUNCTION calp_val_ci_rltnshp(
           p_sub_cal_cat IN VARCHAR2 ,
           p_sup_cal_cat IN VARCHAR2
	   )
  RETURN VARCHAR2 AS
  /******************************************************************
  Created By        :
  Date Created By   :
  Purpose           :
  Known limitations,
  enhancements,
  remarks            :
  Change History

  Who		When		 What
  masehgal      05-Nov-2002      # 2613546   FA `05_108 Multi Award Years Build
                                 Added Teach as a possible subordinate for Award categories
  smadathi      09-Sep-2002      Bug# 2086177. SWSFD01_calendar Build.
                                 Established relation between Admission Calendar
				 instance and Academic Term(Load) Calendar instance.
  masehgal      29-Aug-2002      # 2442637   SWSD01_Calendar Build
                                 Added validations for Award categories
				 Corrected logic for 'NEW' categories
				 And existing validations
  schodava	21-Jan-2002	 Bug # 2279265
				 Prevents a relationship between Load and
				 Teaching Calendars
  schodava	21-Jan-2002	 Enh # 2187247
				 Creates a superior-subordinate relationship
				 between Fee and Load Calendars
  ******************************************************************/

	gv_other_detail		VARCHAR2(255);

  BEGIN
        -- calp_val_ci_rltnshp
  	-- Validate the relationship between two calendar instances of nominated
  	-- calendar categories.
  	-- This routine has no return message number as it is designed to be called
  	-- from within LOVs
  	-- and View definitions. Any message displaying must be done by the
  	-- calling routine.
  DECLARE
        -- SWSFD01_Calendar Build
	-- Award is a System defined category but not taken care of.
	-- Including that here.
	cst_award      CONSTANT VARCHAR2(5)    := 'AWARD' ;
  	cst_academic	CONSTANT VARCHAR2(8) 	:= 'ACADEMIC';
  	cst_admission	CONSTANT VARCHAR2(9) 	:= 'ADMISSION';
  	cst_assessment	CONSTANT VARCHAR2(10) 	:= 'ASSESSMENT';
  	cst_enrolment	CONSTANT VARCHAR2(9) 	:= 'ENROLMENT';
  	cst_exam	      CONSTANT VARCHAR2(4) 	:= 'EXAM';
  	cst_fee		   CONSTANT VARCHAR2(3) 	:= 'FEE';
  	cst_finance	   CONSTANT VARCHAR2(7) 	:= 'FINANCE';
  	cst_load	      CONSTANT VARCHAR2(4) 	:= 'LOAD';
  	cst_progress	CONSTANT VARCHAR2(8) 	:= 'PROGRESS';
  	cst_teaching	CONSTANT VARCHAR2(8) 	:= 'TEACHING';
   cst_holiday    CONSTANT VARCHAR2(7)    := 'HOLIDAY';
   cst_graduation CONSTANT VARCHAR2(10)   := 'GRADUATION';
  	cst_userdef	   CONSTANT VARCHAR2(8) 	:= 'USERDEF';

  BEGIN

   -- * If either of the categories are 'user defined' then return 'Y'.
  	--   User defined calendars are not restricted.
  	IF ( p_sup_cal_cat = cst_userdef	OR p_sub_cal_cat = cst_userdef ) THEN
  	    RETURN 'TRUE';
  	END IF;

        -- # 2442637  SWSFD01_Calendar Build
	-- Logic for checking 'NEW' category corrected
	-- Also added 'Award' to the existing categories

  	-- If either the categories are 'new' to the system, then don't enforce any relations
  	IF (p_sup_cal_cat NOT IN (cst_award, cst_academic, cst_admission, cst_assessment,
	                          cst_enrolment,cst_exam, cst_fee, cst_finance, cst_load,
			                    cst_progress, cst_teaching, cst_holiday, cst_graduation)
  	    OR
	    p_sub_cal_cat NOT IN (cst_award, cst_academic, cst_admission, cst_assessment,
	                          cst_enrolment,cst_exam, cst_fee, cst_finance, cst_load,
			                    cst_progress, cst_teaching, cst_holiday, cst_graduation)
       )  THEN
	        IF ( p_sup_cal_cat <> cst_userdef  AND  p_sub_cal_cat <> cst_userdef) THEN
               RETURN 'TRUE';
  		     END IF;
  	END IF;

  	IF (p_sup_cal_cat  IN (cst_award, cst_academic, cst_admission, cst_assessment,
	                       cst_enrolment,cst_exam, cst_fee, cst_finance, cst_load,
			                 cst_progress, cst_teaching, cst_holiday, cst_graduation)
  	    AND (p_sub_cal_cat IN (cst_award, cst_academic, cst_admission, cst_assessment,
	                           cst_enrolment,cst_exam, cst_fee, cst_finance, cst_load,
		                        cst_progress, cst_teaching, cst_holiday, cst_graduation,NULL)
	        )
	    )  THEN

  		-- * Check the p_sup_cal_cat, p_sub_cal_cat values against
  		--   existing superior/subordinate combinations

      -- # 2442637  SWSFD01_Calendar Build
		-- Added check for Award Category
		IF ( p_sup_cal_cat = cst_award  AND  p_sub_cal_cat IN (cst_load, cst_teaching) ) THEN
		    RETURN 'TRUE' ;
		END IF ;

  		IF p_sup_cal_cat = cst_academic THEN
  		   IF (p_sub_cal_cat IN (cst_admission, cst_assessment, cst_enrolment,
		                         cst_exam, cst_fee, cst_load, cst_progress,
					                cst_teaching, cst_holiday, cst_graduation )
		       ) THEN
  		          RETURN 'TRUE';
  		   END IF;
  		END IF;

      -- An Academic Term (Load) calendar instance is a  subordinate calendar
		-- relationship to Admission Calendar Instance
  		IF ( p_sup_cal_cat = cst_admission AND	(p_sub_cal_cat IN (cst_enrolment,cst_load))) THEN
  		    RETURN 'TRUE';
  		END IF;

  		IF p_sup_cal_cat = cst_assessment THEN
  		   IF (p_sub_cal_cat IN (cst_assessment, cst_teaching)) THEN
		       RETURN 'TRUE';
  		   END IF;
  		END IF;

  		IF (p_sup_cal_cat = cst_enrolment AND p_sub_cal_cat IS NULL) THEN
  			 RETURN 'TRUE';
  		END IF;

  		IF p_sup_cal_cat = cst_exam THEN
  		   IF (p_sub_cal_cat IN (cst_exam, cst_teaching)) THEN
  		       RETURN 'TRUE';
  		   END IF;
  		END IF;

		--  Enh # 2187247
		-- Creates a superior-subordinate relationship
		-- between Fee and Load Calendars
  		IF ( p_sup_cal_cat = cst_fee AND	p_sub_cal_cat = cst_load ) THEN
  			RETURN 'TRUE';
  		END IF;

  		IF ( p_sup_cal_cat = cst_finance AND p_sub_cal_cat = cst_fee) THEN
  			RETURN 'TRUE';
  		END IF;

		-- Bug # 2279265
		-- Removed the relationship between Load and Teaching calendars
  		IF p_sup_cal_cat = cst_progress THEN
  		   IF (p_sub_cal_cat IN (cst_progress, cst_teaching, cst_load)) THEN
		       RETURN 'TRUE';
  		   END IF;
  		END IF;

  		IF ( p_sup_cal_cat = cst_teaching AND	p_sub_cal_cat = cst_admission) THEN
  			RETURN 'TRUE';
  		END IF;

      IF ( p_sup_cal_cat = cst_holiday AND p_sub_cal_cat = cst_holiday) THEN
         RETURN 'TRUE';
      END IF;

  	END IF;
  	RETURN 'FALSE';
  END;
  END calp_val_ci_rltnshp;
END IGS_CA_VAL_CIR;

/
