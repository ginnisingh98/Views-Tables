--------------------------------------------------------
--  DDL for Package Body IGS_PR_CLASS_RANK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_CLASS_RANK" AS
/* $Header: IGSPR37B.pls 120.2 2006/01/18 23:08:00 swaghmar ship $ */
/****************************************************************************************************************
  ||  Created By : DDEY
  ||  Created On : 28-OCT-2002
  ||  Purpose : This Job Rankes the students in a cohert or in an orginization
  ||  This process can be called from the concurrent manager or the from "Class Rank Cohort".
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
****************************************************************************************************************/


PROCEDURE  ranking_process (
             p_cohort_name          IN VARCHAR2,
             p_cal_type             IN VARCHAR2,
             p_ci_sequence_number   IN NUMBER ,
						 p_count                IN OUT NOCOPY NUMBER
                          );



PROCEDURE  run_ranking_process (
     errbuf                OUT	NOCOPY  VARCHAR2,  -- Standard Error Buffer Variable
     retcode               OUT	NOCOPY  NUMBER,    -- Standard Concurrent Return code
     p_cohort_name         IN     VARCHAR2,  -- The Cohart or the Student Group Name
     p_cal_period          IN     VARCHAR2,  -- The Calendar Period ie the concation of term Calendar Type and the sequence Number
     p_org_unit_cd         IN     VARCHAR2   -- Org Unit Code
)  IS
/****************************************************************************************************************
  ||  Created By : DDEY
  ||  Created On : 28-OCT-2002
  ||  Purpose : This Job Rankes the students in a cohert or in an orginization
  ||  This process can be called from the concurrent manager or the from "Class Rank Cohort".
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
	||  anilk           31-Dec-2002     Added parameter cp_cohort_name to cursor cur_cohort_org. Bug#2719698
  ||  swaghmar	16-Jan-2006	 Bug# 4951054 - Added check for disabling UI's
  ||  (reverse chronological order - newest change first)
****************************************************************************************************************/

p_cal_type                      igs_ca_inst.cal_type%TYPE;
p_ci_sequence_number            igs_ca_inst.sequence_number%TYPE;
l_cumulative_ind                VARCHAR2(1);
l_count1                        NUMBER ;
l_count                         NUMBER;
l_rowid                         VARCHAR2(4000)  DEFAULT NULL;
l_student_count                 NUMBER;


invalid_parameter_combination	EXCEPTION;

-- This cursor fetches the Cohart Instances

CURSOR cur_inst_query (cp_cohort_name igs_pr_cohort_inst.cohort_name%TYPE,
                       cp_cal_type igs_pr_cohort_inst.load_cal_type%TYPE,
		       cp_ci_sequence_number igs_pr_cohort_inst.load_ci_sequence_number%TYPE) IS
          SELECT cohiv.*
          FROM igs_pr_cohort_inst_v cohiv
          WHERE cohiv.cohort_name = cp_cohort_name
          AND cohiv.load_cal_type = cp_cal_type
          AND cohiv.load_ci_sequence_number = cp_ci_sequence_number ;



-- This Cursor is used to get all the cohort name in the organization, whose instance are not present.

CURSOR cur_cohort_old (cp_org_unit_cd igs_pr_cohort_inst.cohort_name%TYPE,
                     cp_cal_type igs_pr_cohort_inst.load_cal_type%TYPE,
        	     cp_ci_sequence_number igs_pr_cohort_inst.load_ci_sequence_number%TYPE) IS
	SELECT cohr.cohort_name
	FROM igs_pr_cohort cohr
	WHERE cohr.org_unit_cd = cp_org_unit_cd

	MINUS

	SELECT cohi.cohort_name
	FROM igs_pr_cohort coh,
	     igs_pr_cohort_inst cohi
	WHERE coh.cohort_name = cohi.cohort_name
	AND coh.org_unit_cd = cp_org_unit_cd
	AND cohi.load_cal_type = cp_cal_type
	AND cohi.load_ci_sequence_number = cp_ci_sequence_number ;


-- This Cursor is used to get all the cohort name in the organization, whose instance are not present.

CURSOR cur_cohort_inst_exist (cp_org_unit_cd igs_pr_cohort_inst.cohort_name%TYPE,
                              cp_cal_type igs_pr_cohort_inst.load_cal_type%TYPE,
        	              cp_ci_sequence_number igs_pr_cohort_inst.load_ci_sequence_number%TYPE) IS
 	SELECT cohi.*
	FROM igs_pr_cohort coh,
	     igs_pr_cohort_inst cohi
	WHERE coh.cohort_name = cohi.cohort_name
	AND coh.org_unit_cd = cp_org_unit_cd
	AND cohi.load_cal_type = cp_cal_type
	AND cohi.load_ci_sequence_number = cp_ci_sequence_number ;

-- This Cursor is used to get all the cohort instance when in the particular Orginanization

CURSOR cur_cohort_org_inst (cp_cohort_name igs_pr_cohort_inst.cohort_name%TYPE,
                            cp_org_unit_cd igs_pr_cohort_inst.cohort_name%TYPE,
                            cp_cal_type igs_pr_cohort_inst.load_cal_type%TYPE,
        	            cp_ci_sequence_number igs_pr_cohort_inst.load_ci_sequence_number%TYPE) IS
	SELECT cohi.cohort_name
	FROM igs_pr_cohort coh,
	     igs_pr_cohort_inst cohi
	WHERE coh.cohort_name = cohi.cohort_name
	AND coh.cohort_name = cp_cohort_name
	AND coh.org_unit_cd   = cp_org_unit_cd
	AND cohi.load_cal_type = cp_cal_type
	AND cohi.load_ci_sequence_number = cp_ci_sequence_number ;

-- Cursor Finds if cogert exists for the organization

CURSOR cur_cohort_org (
         cp_org_unit_cd igs_pr_cohort.org_unit_cd%TYPE,
         cp_cohort_name igs_pr_cohort.cohort_name%TYPE) IS
        SELECT coh.cohort_name
	FROM igs_pr_cohort coh
	WHERE coh.org_unit_cd = cp_org_unit_cd
    AND   coh.cohort_name = cp_cohort_name;


   inst_query_rec cur_inst_query%ROWTYPE;
   cohort_old_rec  cur_cohort_old%ROWTYPE ;
   cohort_org_inst_rec cur_cohort_org_inst%ROWTYPE;
   cohort_org_rec  cur_cohort_org%ROWTYPE;
   cohort_inst_exist_rec cur_cohort_inst_exist%ROWTYPE;

BEGIN
retcode:=0;

IGS_GE_GEN_003.SET_ORG_ID(); -- swaghmar, bug# 4951054

FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_cal_period_old : ' ||  p_cal_period);
FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_cohort_name_old : ' ||  p_cohort_name);
l_student_count := 1;

-- Determining the Calander Type from the Calender Period Passed
p_cal_type := RTRIM(LTRIM(SUBSTR(p_cal_period,1,10))) ;

-- Determining the Calander Sequence Number from the Calender Period Passed
p_ci_sequence_number   := SUBSTR(p_cal_period,76,6) ;

--
-- Creating or Fetching the cohort instances
--

-- Condition # 1 when the parameters p_cohort_name,p_cal_type and p_ci_sequence_number are passed
 IF (p_cohort_name IS NOT NULL AND p_cal_type IS NOT NULL AND p_ci_sequence_number IS NOT NULL AND p_org_unit_cd IS NULL) THEN
   OPEN cur_inst_query (p_cohort_name,p_cal_type,p_ci_sequence_number);
   FETCH cur_inst_query INTO inst_query_rec;
     IF cur_inst_query%NOTFOUND THEN
       CLOSE cur_inst_query;

         l_rowid := NULL;

       igs_pr_cohort_inst_pkg.INSERT_ROW(
                                 x_rowid                      =>  l_rowid ,
				 x_cohort_name                =>  p_cohort_name,
				 x_load_cal_type              =>  p_cal_type ,
				 x_load_ci_sequence_number    =>  p_ci_sequence_number ,
				 x_cohort_status              =>  'WORKING' ,
				 x_rank_status                =>  'WORKING' ,
				 x_run_date                   =>  SYSDATE
                  );

         l_rowid := NULL;

     END IF;

     IF  cur_inst_query%ISOPEN THEN
      CLOSE cur_inst_query;
     END IF;

   -- Procedure 'ranking_process' is Called for both the cases
   -- Case 1 : When the Cohort Instance already Exists in the System
   -- Case 2 : When the Cohort Instance is newly created in the System
   -- In both the cases the Cohort Name , Cal Type and the Sequence Number are same ie the parameter passed

       ranking_process (
              p_cohort_name          => p_cohort_name,
              p_cal_type             => p_cal_type,
              p_ci_sequence_number   => p_ci_sequence_number,
				      p_count                =>  l_student_count
                         );

 -- Call to raise a Business Event
	  raise_clsrank_be_cr003 (p_cohort_name     =>  p_cohort_name  ,
                                  p_cohort_instance =>  p_cal_period  ,
    			          p_run_date        =>  SYSDATE  ,
				  p_cohort_total_students => l_student_count    ) ;

-- Condition # 2 when the parameters p_org_unit_cd,p_cal_type and p_ci_sequence_number are passed

 ELSIF (p_org_unit_cd IS NOT NULL AND p_cal_type IS NOT NULL AND p_ci_sequence_number IS NOT NULL AND p_cohort_name IS NULL ) THEN
    FOR cohort_inst_exist_rec IN cur_cohort_inst_exist(p_org_unit_cd,p_cal_type,p_ci_sequence_number) LOOP

        -- The Ranking procedure fo all the Cohort Instances which already existes in the System for the Organization.

	  ranking_process (
              p_cohort_name          => cohort_inst_exist_rec.cohort_name,
              p_cal_type             => cohort_inst_exist_rec.load_cal_type,
              p_ci_sequence_number   => cohort_inst_exist_rec.load_ci_sequence_number ,
				      p_count                =>  l_student_count
                         );

        -- Call to raise a Business Event

	  raise_clsrank_be_cr003 (p_cohort_name     =>  p_cohort_name  ,
                                  p_cohort_instance =>  p_cal_period  ,
    			          p_run_date        =>  SYSDATE  ,
				  p_cohort_total_students => l_student_count   ) ;

   END LOOP;


--
-- A cohort instance needs to be created for each of the cohorts attached to the org unit which do not have instances in the given calendar period.
--
   FOR cohort_old_rec IN cur_cohort_old (p_org_unit_cd,p_cal_type,p_ci_sequence_number) LOOP

   -- The Cohort Instances are created for the Cohort Name which are in the Organization but does not have the Instance

     igs_pr_cohort_inst_pkg.insert_row(
                                 x_rowid                      =>  l_rowid ,
				 x_cohort_name                =>  cohort_old_rec.cohort_name,
				 x_load_cal_type              =>  p_cal_type ,
				 x_load_ci_sequence_number    =>  p_ci_sequence_number ,
				 x_cohort_status              =>  'WORKING' ,
				 x_rank_status                =>  'WORKING' ,
				 x_run_date                   =>  SYSDATE
                                     );
     l_rowid := NULL;

        -- The Ranking procedure fo all the Cohort Instances which are newly created.

	  ranking_process (
              p_cohort_name          => cohort_old_rec.cohort_name,
              p_cal_type             => p_cal_type,
              p_ci_sequence_number   => p_ci_sequence_number  ,
				      p_count                =>  l_student_count
                         );

        -- Call to raise a Business Event
	  raise_clsrank_be_cr003 (p_cohort_name     =>  p_cohort_name  ,
                                  p_cohort_instance =>  p_cal_period  ,
    			          p_run_date        =>  SYSDATE  ,
				  p_cohort_total_students => l_student_count    ) ;
   END LOOP;



-- Condition # 3 when the parameters p_cohort_name,p_org_unit_cd,p_cal_type and p_ci_sequence_number are passed

 ELSIF (p_cohort_name IS NOT NULL AND p_org_unit_cd IS NOT NULL AND p_cal_type IS NOT NULL AND p_ci_sequence_number IS NOT NULL) THEN

	  OPEN  cur_cohort_org_inst(p_cohort_name,p_org_unit_cd,p_cal_type,p_ci_sequence_number);
          FETCH cur_cohort_org_inst INTO cohort_org_inst_rec;

	  IF cur_cohort_org_inst%FOUND THEN

           -- The Ranking procedure fo all the Cohort Instances which already existes in the System for the corresponding cohort name,org unit cd,cal type and ci_sequence_number .

           ranking_process (
              p_cohort_name          => p_cohort_name,
              p_cal_type             => p_cal_type,
              p_ci_sequence_number   => p_ci_sequence_number,
				      p_count                =>  l_student_count
                         );

        -- Call to raise a Business Event

	  raise_clsrank_be_cr003 (p_cohort_name     =>  p_cohort_name  ,
                                  p_cohort_instance =>  p_cal_period  ,
    			          p_run_date        =>  SYSDATE  ,
				  p_cohort_total_students => l_student_count    ) ;


          ELSE

           l_count := 0;

	  -- If no cohort instance exists for the combination of the parameters p_cohort_name,p_org_unit_cd,p_cal_type and p_ci_sequence_number
	  -- are found, check if the org is attached to the cohort

            FOR cohort_org_rec IN cur_cohort_org (p_org_unit_cd, p_cohort_name)  LOOP

	    l_count := l_count + 1;

	    -- Instance for this cohort is created and then the ranking process for this new instance is run.

            igs_pr_cohort_inst_pkg.insert_row(
                 x_rowid                      =>  l_rowid ,
				 x_cohort_name                =>  cohort_org_rec.cohort_name,
				 x_load_cal_type              =>  p_cal_type ,
				 x_load_ci_sequence_number    =>  p_ci_sequence_number ,
				 x_cohort_status              =>  'WORKING' ,
				 x_rank_status                =>  'WORKING' ,
				 x_run_date                   =>  SYSDATE
                                     );
            l_rowid := NULL;

           -- Ranking process for this new instance created .

           ranking_process (
              p_cohort_name          => cohort_org_rec.cohort_name,
              p_cal_type             => p_cal_type,
              p_ci_sequence_number   => p_ci_sequence_number,
				      p_count                =>  l_student_count
                         );

        -- Call to raise a Business Event


	  raise_clsrank_be_cr003 (p_cohort_name     =>  p_cohort_name  ,
                                  p_cohort_instance =>  p_cal_period  ,
    			          p_run_date        =>  SYSDATE  ,
				  p_cohort_total_students => l_student_count    ) ;


           END LOOP;

          END IF;

        -- If the org unit is not attached to the cohort, message 'IGS_PR_RNK_NO_POP' is printed in the log file

	   IF l_count = 0 THEN

            FND_MESSAGE.SET_NAME('IGS','IGS_PR_RNK_NO_POP');
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

	   END IF;


-- Condition # 4 when both the parameters p_cohort_name and p_org_unit_cd are not passed

 ELSIF (p_cohort_name IS NULL AND p_org_unit_cd IS NULL ) THEN

 -- When both the Cohort Name and the Org Unit code is passed as NULL, an error message would be raised and the
 -- process would error out.


  RAISE invalid_parameter_combination;

 END IF;

 	    FND_MESSAGE.SET_NAME('IGS','IGS_PR_RNK_COMP');
            FND_MESSAGE.SET_TOKEN('RANKCOUNT',l_student_count);
            FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
 EXCEPTION
  WHEN invalid_parameter_combination THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'SQL Error Message :' || SQLERRM);
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      retcode := 2;
      errbuf  :=  fnd_message.get_string('IGS','IGS_PR_RNK_INV_PRM');
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
  WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'SQL Error Message :' || SQLERRM);
      Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_CLASS_RANK.RUN_RANKING_PROCESS');
      retcode := 2;
      errbuf := fnd_message.get;
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
END run_ranking_process ;

PROCEDURE  ranking_process (
             p_cohort_name          IN VARCHAR2,
             p_cal_type             IN VARCHAR2,
             p_ci_sequence_number   IN NUMBER,
				     p_count                IN OUT NOCOPY NUMBER
                          ) IS

/****************************************************************************************************************
  ||  Created By : DDEY
  ||  Created On : 28-OCT-2002
  ||  Purpose :  This Procedure is called from the procedure run_making_process . This procedure does the ranking
  ||             of the students in particular cohart instance
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
****************************************************************************************************************/

l_new_count                     NUMBER ;
l_old_count                     NUMBER ;
l_acad_cal                      VARCHAR2(4000) DEFAULT NULL ; -- This stores the concatinated value of Academic Calander
l_cumulative_ind                VARCHAR2(1);
l_rowid                         VARCHAR2(2000);
l_old_flag                      VARCHAR2(1) DEFAULT 'Y';
p_id   number;

-- This Cursor fetches the Rank status for the corrosponding Cohort Name

CURSOR cur_rank_status (cp_cohort_name igs_pr_cohort_inst.cohort_name%TYPE,
                        cp_cal_type igs_pr_cohort_inst.load_cal_type%TYPE,
         		        cp_ci_sequence_number igs_pr_cohort_inst.load_ci_sequence_number%TYPE ) IS
     SELECT *
     FROM igs_pr_cohort_inst_v
     WHERE cohort_name = cp_cohort_name
     AND  load_cal_type = cp_cal_type
     AND  load_ci_sequence_number = cp_ci_sequence_number;


-- This Cursor fetches the Stat type,TimeFrame for the corrosponding Cohort Name

CURSOR cur_stat_type (cp_cohort_name igs_pr_cohort_inst.cohort_name%TYPE) IS
   SELECT *
   FROM igs_pr_cohort
   WHERE cohort_name = cp_cohort_name ;

-- The cursor is used when the Cohort Status is FROZEN and the rank status is Not Final. This cursor is used when,
-- the Dense Rank Indicator is set as 'N' in the table igs_pr_cohort

  TYPE cur_frozen_rank IS REF CURSOR;

-- The cursor is used when the Cohort Status is FROZEN and the rank status is Not Final. This cursor is used when,
-- the Dense Rank Indicator is set as 'Y' in the table igs_pr_cohort

  TYPE cur_frozen_denserank IS REF CURSOR;


-- Cursor to determine the Calander Category for a particular calander type

 CURSOR cur_cal_cat (cp_cal_type igs_pr_cohort_inst.load_cal_type%TYPE ) IS
      SELECT s_cal_cat
      FROM igs_ca_type
      WHERE cal_type = cp_cal_type ;

-- Cursor to determine the Academic Calander for the corrosponding load calander

 CURSOR cur_acad_cal (cp_cal_type igs_pr_cohort_inst.load_cal_type%TYPE,
                     cp_ci_sequence_number igs_pr_cohort_inst.load_ci_sequence_number%TYPE) IS
       SELECT sup_cal_type, sup_ci_sequence_number
       FROM igs_ca_inst_rel
       WHERE
       sub_cal_type  = cp_cal_type
       AND sub_ci_sequence_number = cp_ci_sequence_number
       AND sup_cal_type  IN (SELECT CAL_TYPE FROM IGS_CA_TYPE WHERE S_CAL_CAT = 'ACADEMIC') ;

--
-- Cursor used to rank the student based on the Rule. This is done when the rank status is not FINAL and the cohort status is WORKING
--  This cursor is used when,the Dense Rank Indicator is set as 'N' in the table igs_pr_cohort
--

    TYPE cur_student_ranked_query IS REF CURSOR;


--
-- Cursor used to rank the student based on the Rule. This is done when the rank status is not FINAL and the cohort status is WORKING
--  This cursor is used when,the Dense Rank Indicator is set as 'Y' in the table igs_pr_cohort
--

   TYPE cur_student_denseranked_query IS REF CURSOR;


-- Cursor get the old data when the cohort status is 'WORKING'

CURSOR cur_old_rank (cp_cohort_name igs_pr_cohort_inst.cohort_name%TYPE,
                     cp_cal_type igs_pr_cohort_inst.load_cal_type%TYPE,
        	     cp_ci_sequence_number igs_pr_cohort_inst.load_ci_sequence_number%TYPE) IS
           SELECT cohi.*
           FROM igs_pr_cohort_inst_rank_v cohi
           WHERE cohi.cohort_name = cp_cohort_name
           AND cohi.load_cal_type = cp_cal_type
           AND cohi.load_ci_sequence_number = cp_ci_sequence_number ;


-- Cursor get the cohort Institution Name Corrosponding to the cp_cohort_name,cp_cal_type,cp_ci_sequence_number

CURSOR cur_cohort_inst_person (cp_cohort_name igs_pr_cohort_inst.cohort_name%TYPE,
                     cp_cal_type igs_pr_cohort_inst.load_cal_type%TYPE,
        	     cp_ci_sequence_number igs_pr_cohort_inst.load_ci_sequence_number%TYPE,
		     cp_person_id   igs_en_sca_v.person_id%TYPE,
		     cp_course_cd   igs_en_sca_v.course_cd%TYPE) IS
           SELECT cohi.*
           FROM igs_pr_cohort_inst_rank_v cohi
           WHERE cohi.cohort_name = cp_cohort_name
           AND cohi.load_cal_type = cp_cal_type
           AND cohi.load_ci_sequence_number = cp_ci_sequence_number
	   AND cohi.person_id = cp_person_id
	   AND cohi.course_cd = cp_course_cd;



   rank_status_rec cur_rank_status%ROWTYPE;
   stat_type_rec cur_stat_type%ROWTYPE;
   frozen_rank_type_rec cur_frozen_rank;
   frozen_denserank_type_rec cur_frozen_denserank;
   cohort_inst_person_rec cur_cohort_inst_person%ROWTYPE;
   student_denrank_query_type_rec cur_student_denseranked_query;
   student_ranked_query_type_rec cur_student_ranked_query;
   cal_cat_rec   cur_cal_cat%ROWTYPE;


   TYPE frozen_rank_rec_type IS RECORD (

row_id                      VARCHAR2(2000),
cohort_name                 VARCHAR2(30),
load_cal_type               VARCHAR2(10),
load_ci_sequence_number     NUMBER(6),
person_id                   NUMBER(15),
person_number               VARCHAR2(30),
person_name                 VARCHAR2(360),
course_cd                   VARCHAR2(6),
course_title                VARCHAR2(90),
as_of_rank_gpa              NUMBER,
cohort_rank                 NUMBER(15),
cohort_override_rank        NUMBER(15),
comments                    VARCHAR2(240),
created_by                  NUMBER(15),
creation_date               DATE,
last_updated_by             NUMBER(15),
last_update_date            DATE,
last_update_login           NUMBER(15),
request_id                  NUMBER(15),
program_application_id      NUMBER(15),
program_id                  NUMBER(15),
program_update_date         DATE,
cum_gpa                     NUMBER,
new_rank                    NUMBER

) ;

frozen_rank_rec frozen_rank_rec_type  ;

TYPE frozen_denserank_rec_type IS RECORD (

row_id                      VARCHAR2(2000),
cohort_name                 VARCHAR2(30),
load_cal_type               VARCHAR2(10),
load_ci_sequence_number     NUMBER(6),
person_id                   NUMBER(15),
person_number               VARCHAR2(30),
person_name                 VARCHAR2(360),
course_cd                   VARCHAR2(6),
course_title                VARCHAR2(90),
as_of_rank_gpa              NUMBER,
cohort_rank                 NUMBER(15),
cohort_override_rank        NUMBER(15),
comments                    VARCHAR2(240),
created_by                  NUMBER(15),
creation_date               DATE,
last_updated_by             NUMBER(15),
last_update_date            DATE,
last_update_login           NUMBER(15),
request_id                  NUMBER(15),
program_application_id      NUMBER(15),
program_id                  NUMBER(15),
program_update_date         DATE,
cum_gpa                     NUMBER,
new_rank                    NUMBER

) ;

frozen_denserank_rec frozen_denserank_rec_type  ;


TYPE student_ranked_query_type IS RECORD (

person_id                   NUMBER(15),
course_cd                   VARCHAR2(6),
cum_gpa                     NUMBER,
new_rank                    NUMBER

) ;

student_ranked_query_rec student_ranked_query_type ;


TYPE student_denseranked_query_type IS RECORD (

person_id                   NUMBER(15),
course_cd                   VARCHAR2(6),
cum_gpa                     NUMBER,
new_rank                    NUMBER
) ;

 student_denseranked_query_rec student_denseranked_query_type;
BEGIN


--
-- The Rank Status, Cohort Status for the Cohort Instance is determined
--

  OPEN cur_rank_status(p_cohort_name,p_cal_type,p_ci_sequence_number);
  FETCH  cur_rank_status INTO rank_status_rec;
  CLOSE cur_rank_status ;


   IF rank_status_rec.rank_status = 'FINAL' THEN   -- 1

 --
 -- If the Rank Status is FINAL then no ranking is done and message 'IGS_PR_RNK_FINAL' should be displayed on the log file
 --
      FND_MESSAGE.SET_NAME('IGS','IGS_PR_RNK_FINAL');
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

   -- If the ranking status is not FINAL ie it is WORKING then the following needa to be done

   ELSE  --1

     -- Determining the Stat Type , Time frame and the Dense Rank Indicator

     OPEN  cur_stat_type(p_cohort_name);
     FETCH cur_stat_type INTO  stat_type_rec ;
     CLOSE cur_stat_type ;


--
-- IF timeframe for the corrosponding Cohort Name is 'CUMULATIVE', 'Y' is assign to l_cumulative_ind, else if timeframe is TERM, 'N' is assigned to  l_cumulative_ind
--

    IF stat_type_rec.timeframe = 'CUMULATIVE' THEN --3

       l_cumulative_ind := 'Y' ;

    ELSIF stat_type_rec.timeframe = 'TERM' THEN  --3

       l_cumulative_ind := 'N' ;

    END IF; --3

   -- Ranking for the student are done for the students where the rank status is working and the cohort status is 'FROZEN'
   -- This means that the student population is frozen. The student population is chosen from IGS_PR_COHORT_INST_RANK_V. This is the population that needs to be ranked.

   IF rank_status_rec.cohort_status  = 'FROZEN' THEN  --2
     p_count := 0;

      IF stat_type_rec.dense_rank_ind = 'N' THEN  --4

	--
	--  Ranking the student in the Cohert in a particular Calender Instance when the Rank Status is Not final and the Cohort Status Is Froozen.
	--  The Dense Rank Indicator should be set as 'N' in the table igs_pr_cohort
	--(p_cohort_name,p_cal_type,p_ci_sequence_number,stat_type_rec.stat_type,l_cumulative_ind)

	    OPEN frozen_rank_type_rec FOR
                   'SELECT   res.*,
                    RANK() OVER (ORDER BY res.cum_gpa DESC) new_rank
                    FROM     (SELECT  cohiv.*,
                             igs_pr_class_rank.get_cum_gpa (
		                      cohiv.person_id,
                              cohiv.course_cd,
                              cohiv.cohort_name,
                              cohiv.load_cal_type,
                              cohiv.load_ci_sequence_number,
                              ''' || stat_type_rec.stat_type  || ''',
                              '''|| l_cumulative_ind   || '''
			    ) cum_gpa
                    FROM    igs_pr_cohort_inst_rank_v cohiv
                    WHERE   cohiv.cohort_name = ''' || p_cohort_name  || '''
        		    AND     cohiv.load_cal_type = ''' || p_cal_type  || '''
                    AND     cohiv.load_ci_sequence_number = ' || p_ci_sequence_number  || ') res'  ;

            LOOP   -- Loop 1

		FETCH frozen_rank_type_rec INTO frozen_rank_rec;
                EXIT WHEN frozen_rank_type_rec%NOTFOUND;

	        p_count := p_count + 1;


            -- This FOR loop is to determine the studnet rank already present in the system for the specific Cohort Instance.
	    -- These records need to updated with the recent Ranking anf the GPA.


	     FOR cohort_inst_person_rec IN cur_cohort_inst_person(p_cohort_name,p_cal_type,p_ci_sequence_number,frozen_rank_rec.person_id,frozen_rank_rec.course_cd) LOOP -- Loop2

		--
		-- Updating the Cohert Instance rank table with the recent ranking and the GPA value as of now. Rest of the values are retained.
		--
                 igs_pr_cohinst_rank_pkg.update_row (
					x_rowid                      =>   cohort_inst_person_rec.row_id ,
					x_cohort_name                =>   cohort_inst_person_rec.cohort_name,
					x_load_cal_type              =>   cohort_inst_person_rec.load_cal_type ,
					x_load_ci_sequence_number    =>   cohort_inst_person_rec.load_ci_sequence_number ,
					x_person_id                  =>   cohort_inst_person_rec.person_id ,
					x_course_cd                  =>   cohort_inst_person_rec.course_cd ,
					x_as_of_rank_gpa             =>   frozen_rank_rec.cum_gpa ,
					x_cohort_rank                =>   frozen_rank_rec.new_rank  ,
					x_cohort_override_rank       =>   cohort_inst_person_rec.cohort_override_rank ,
					x_comments                   =>   cohort_inst_person_rec.comments
					        );

	     END LOOP; -- Loop2
          END LOOP;  --Loop 1



        ELSIF stat_type_rec.dense_rank_ind = 'Y' THEN --4

	--
	--  Ranking the student in the Cohert in a particular Calender Instance when the Rank Status is Not final and the Cohort Status Is Froozen
	--  The Dense Rank Indicator should be set as 'Y' in the table igs_pr_cohort
	--

        OPEN frozen_denserank_type_rec FOR
                   'SELECT   res.*,
                    DENSE_RANK() OVER (ORDER BY res.cum_gpa DESC) new_rank
                    FROM     (SELECT  cohiv.*,
                             igs_pr_class_rank.get_cum_gpa (
		                      cohiv.person_id,
                              cohiv.course_cd,
                              cohiv.cohort_name,
                              cohiv.load_cal_type,
                              cohiv.load_ci_sequence_number,
                              ''' || stat_type_rec.stat_type  || ''',
                              '''|| l_cumulative_ind   || '''
			    ) cum_gpa
                    FROM    igs_pr_cohort_inst_rank_v cohiv
                    WHERE   cohiv.cohort_name = ''' || p_cohort_name  || '''
		    AND     cohiv.load_cal_type = ''' || p_cal_type  || '''
                    AND     cohiv.load_ci_sequence_number = ' || p_ci_sequence_number  || ') res' ;




	    LOOP   -- Loop 1

                FETCH frozen_denserank_type_rec INTO frozen_denserank_rec;
                EXIT WHEN frozen_denserank_type_rec%NOTFOUND;

	        p_count := p_count + 1;


            -- This FOR loop is to determine the studnet rank already present in the system for the specific Cohort Instance.
	    -- These records need to updated with the recent Ranking anf the GPA.

         FOR cohort_inst_person_rec IN cur_cohort_inst_person(p_cohort_name,p_cal_type,p_ci_sequence_number,frozen_denserank_rec.person_id,frozen_denserank_rec.course_cd) LOOP


		--
		-- Updating the Cohert Instance rank table with the recent ranking and the GPA value as of now. Rest of the values are retained.
		--

              igs_pr_cohinst_rank_pkg.update_row (
					x_rowid                      =>   cohort_inst_person_rec.row_id ,
					x_cohort_name                =>   cohort_inst_person_rec.cohort_name,
					x_load_cal_type              =>   cohort_inst_person_rec.load_cal_type ,
					x_load_ci_sequence_number    =>   cohort_inst_person_rec.load_ci_sequence_number ,
					x_person_id                  =>   cohort_inst_person_rec.person_id ,
					x_course_cd                  =>   cohort_inst_person_rec.course_cd ,
					x_as_of_rank_gpa             =>   frozen_denserank_rec.cum_gpa ,
					x_cohort_rank                =>   frozen_denserank_rec.new_rank ,
					x_cohort_override_rank       =>   cohort_inst_person_rec.cohort_override_rank ,
					x_comments                   =>   cohort_inst_person_rec.comments
					        );

	     END LOOP;

          END LOOP;

        END IF; -- 4

	--
	-- Updating the Cohert Instance table with the rundate as the System Date. Rest of the values are retained.
	--

	     igs_pr_cohort_inst_pkg.update_row(
                                         x_rowid                    => rank_status_rec.row_id,
                                         x_cohort_name              => rank_status_rec.cohort_name,
                                         x_load_cal_type            => rank_status_rec.load_cal_type,
                                         x_load_ci_sequence_number  => rank_status_rec.load_ci_sequence_number,
                                         x_cohort_status            => rank_status_rec.cohort_status,
                                         x_rank_status              => rank_status_rec.rank_status,
                                         x_run_date                 => SYSDATE
                                                );




-- Ranking for the student are done for the students where the rank status is working and the cohort status is 'WORKING'
-- Cohort status is 'WORKING' means that the number of students in the Cohort Instance is not fixed, the number of students can increase or decrease accourdingly.

   ELSIF rank_status_rec.cohort_Status  = 'WORKING' THEN   -- 2


     p_count := 0;


       OPEN  cur_cal_cat(p_cal_type);
       FETCH cur_cal_cat INTO cal_cat_rec ;
       CLOSE cur_cal_cat ;


      -- Tha Calender Category passed is 'LOAD'

        IF cal_cat_rec.s_cal_cat = 'LOAD' THEN

	   -- Finding out all the Academic Calanders for the corresponding Term Calanders
	   -- Concating all of them and putting them in the format ( 'ACAD-1','ACAD-2')

	     FOR  acad_cal_rec IN cur_acad_cal (p_cal_type,p_ci_sequence_number) LOOP

	         IF l_acad_cal IS NULL THEN

                   l_acad_cal := '(' || '''' || acad_cal_rec.sup_cal_type ||  '''' ;

	         ELSE

		  l_acad_cal :=  l_acad_cal  || ',' || '''' || acad_cal_rec.sup_cal_type ||''''  ;

	         END IF;

	     END LOOP;

        --
	-- L_ACAD_CAL contains all the concatenated values for all the Academic Calanders in the format ( 'ACAD-1','ACAD-2')
	--
        IF l_acad_cal IS NOT NULL THEN
	        l_acad_cal := l_acad_cal || ')' ;
         ELSE
            l_acad_cal := '('''')';
        END IF;

      -- Tha Calender Category passed is 'ACADEMIC'

	ELSE

	    l_acad_cal := '(' || '''' || p_cal_type ||  '''' || ')' ;

	END IF;
       IF stat_type_rec.dense_rank_ind = 'N' THEN    --  The Dense Rank Indicator should be set as 'N' in the table igs_pr_cohort
       	 l_old_count := 0;

	-- The existing list of students whose ranking is done for the Cohort Instance

       	   FOR old_rank_rec IN  cur_old_rank(p_cohort_name,p_cal_type,p_ci_sequence_number) LOOP
             l_old_count := l_old_count + 1;
			l_old_population_table_rec(l_old_count).p_rowid                       :=        old_rank_rec.row_id ;
			l_old_population_table_rec(l_old_count).p_person_id                   :=        old_rank_rec.person_id  ;
			l_old_population_table_rec(l_old_count).p_course_cd                   :=        old_rank_rec.course_cd  ;
			l_old_population_table_rec(l_old_count).p_cohort_name                 :=        old_rank_rec.cohort_name  ;
			l_old_population_table_rec(l_old_count).p_load_cal_type               :=        old_rank_rec.load_cal_type           ;
			l_old_population_table_rec(l_old_count).p_load_ci_sequence_number     :=        old_rank_rec.load_ci_sequence_number           ;
			l_old_population_table_rec(l_old_count).p_as_of_rank_gpa              :=        old_rank_rec.as_of_rank_gpa    ;
			l_old_population_table_rec(l_old_count).p_cohort_rank                 :=        old_rank_rec.cohort_rank  ;
			l_old_population_table_rec(l_old_count).p_cohort_override_rank        :=        old_rank_rec.cohort_override_rank           ;
			l_old_population_table_rec(l_old_count).p_comments                    :=        old_rank_rec.comments    ;
			l_old_population_table_rec(l_old_count).p_deletion_indicator          :=        'Y'                     ;


           END LOOP;

	l_new_count := 0;

      -- The output is a record group consisting of the all the students fitting the cohort rule and correspondingly ranked.
      -- Store this in a PL/SQL table called table l_new_population_table


    OPEN student_ranked_query_type_rec FOR
      ' SELECT res.* , RANK () OVER (order by res.cum_gpa desc) AS new_rank
        FROM
       (SELECT  person_id, course_cd, igs_pr_class_rank.get_cum_gpa ( sca.person_id,sca.course_cd,''' || p_cohort_name || ''',
                                                          ''' || p_cal_type || ''',' || p_ci_sequence_number || ',
                                                          ''' || stat_type_rec.stat_type ||''',
                                                          ''' || l_cumulative_ind || ''' )  cum_gpa
           FROM igs_en_sca_v sca
           WHERE
           sca.cal_type IN ' || l_acad_cal || ' AND
           (sca.person_id, sca.course_cd) IN
            (
            SELECT sca.person_id, sca.course_cd
            FROM igs_en_su_attempt sua, igs_en_sca_v sca
            WHERE sua.person_id = sca.person_id
            AND sua.course_cd = sca.course_cd
            AND unit_attempt_status = ''COMPLETED''
            AND (  sua.cal_type , sua.ci_sequence_number ) IN
            (SELECT teach_cal_type, teach_ci_sequence_number
             FROM igs_ca_load_to_teach_v
             WHERE load_cal_type= ''' || p_cal_type || '''
             AND load_ci_sequence_number = ' || p_ci_sequence_number || '
           )
         )
          AND
        igs_pr_class_rank.rulp_val_senna_res (
          sca.person_id,
          sca.course_cd,
          sca.version_number,
          NULL,
          NULL,
          ''' || p_cal_type || ''',
          ' || p_ci_sequence_number || ','
          || stat_type_rec.rule_sequence_number  || ') = ''true''  ) res';




           LOOP

             FETCH student_ranked_query_type_rec INTO student_ranked_query_rec;

             EXIT WHEN student_ranked_query_type_rec%NOTFOUND;

             p_count := p_count + 1;

             l_old_flag := 'Y';


	--  FOR student_ranked_query_rec IN  cur_student_ranked_query (p_cohort_name,p_cal_type,p_ci_sequence_number,stat_type_rec.stat_type,l_cumulative_ind,l_acad_cal) LOOP

             l_new_count := l_new_count + 1;

			l_new_population_table_rec(l_new_count).p_person_id                   :=        student_ranked_query_rec.person_id  ;
			l_new_population_table_rec(l_new_count).p_course_cd                   :=        student_ranked_query_rec.course_cd  ;
			l_new_population_table_rec(l_new_count).p_cohort_name                 :=        p_cohort_name                       ;
			l_new_population_table_rec(l_new_count).p_load_cal_type               :=        p_cal_type                          ;
			l_new_population_table_rec(l_new_count).p_load_ci_sequence_number     :=        p_ci_sequence_number                ;
			l_new_population_table_rec(l_new_count).p_as_of_rank_gpa              :=        student_ranked_query_rec.cum_gpa    ;
			l_new_population_table_rec(l_new_count).p_cohort_rank                 :=        student_ranked_query_rec.new_rank   ;
			l_new_population_table_rec(l_new_count).p_cohort_override_rank        :=        NULL                                ;
			l_new_population_table_rec(l_new_count).p_comments                    :=        NULL                                ;
			l_new_population_table_rec(l_new_count).p_deletion_indicator          :=        'Y'                                 ;

	       FOR i IN 1..l_old_count LOOP


    	  IF( l_new_population_table_rec(l_new_count).p_person_id = l_old_population_table_rec(i).p_person_id AND
	      l_new_population_table_rec(l_new_count).p_course_cd = l_old_population_table_rec(i).p_course_cd AND
	      l_new_population_table_rec(l_new_count).p_cohort_name =  l_old_population_table_rec(i).p_cohort_name AND
              l_new_population_table_rec(l_new_count).p_load_cal_type = l_old_population_table_rec(i).p_load_cal_type AND
              l_new_population_table_rec(l_new_count).p_load_ci_sequence_number = l_old_population_table_rec(i).p_load_ci_sequence_number ) THEN

		  -- If the students existinf in the old cohort instance list and the new cohort instance then the old rank and the GPA for the student is updated in the
		  -- Cohort Instance Rank table.

                 l_old_flag := 'N';


        igs_pr_cohinst_rank_pkg.update_row (
			x_rowid                      =>   l_old_population_table_rec(i).p_rowid ,
			x_cohort_name                =>   l_old_population_table_rec(i).p_cohort_name,
			x_load_cal_type              =>   l_old_population_table_rec(i).p_load_cal_type ,
			x_load_ci_sequence_number    =>   l_old_population_table_rec(i).p_load_ci_sequence_number ,
			x_person_id                  =>   l_old_population_table_rec(i).p_person_id ,
			x_course_cd                  =>   l_old_population_table_rec(i).p_course_cd ,
			x_as_of_rank_gpa             =>   l_new_population_table_rec(l_new_count).p_as_of_rank_gpa ,
			x_cohort_rank                =>   l_new_population_table_rec(l_new_count).p_cohort_rank ,
			x_cohort_override_rank       =>   l_old_population_table_rec(i).p_cohort_override_rank ,
			x_comments                   =>   l_old_population_table_rec(i).p_comments
                                );


                 -- Marking the Records in the New List and the Old list, for the records which already exist in the
		 -- Cohort Instance Rank table as of this step. This indicator would be used later, when the
		 -- records for the Student Cohort Instance rank has to be deleted from the table Cohort Instance Rank,
		 -- which are not avaliable in the new list.

                 l_new_population_table_rec(l_new_count).p_deletion_indicator        :=        'N'        ;
      		 l_old_population_table_rec(i).p_deletion_indicator                  :=        'N'        ;


          END IF;

        END LOOP;
                  -- Records existing in the new list and not in the old list . Those records are inserted in the Cohort Instance Rank table


       IF l_old_flag = 'Y'  THEN

       igs_pr_cohinst_rank_pkg.insert_row (
			x_rowid                         =>   l_rowid ,
			x_cohort_name                   =>   l_new_population_table_rec(l_new_count).p_cohort_name ,
			x_load_cal_type                 =>   l_new_population_table_rec(l_new_count).p_load_cal_type ,
			x_load_ci_sequence_number       =>   l_new_population_table_rec(l_new_count).p_load_ci_sequence_number,
			x_person_id                     =>   l_new_population_table_rec(l_new_count).p_person_id ,
			x_course_cd                     =>   l_new_population_table_rec(l_new_count).p_course_cd ,
			x_as_of_rank_gpa                =>   l_new_population_table_rec(l_new_count).p_as_of_rank_gpa ,
			x_cohort_rank                   =>   l_new_population_table_rec(l_new_count).p_cohort_rank    ,
			x_cohort_override_rank          =>   l_new_population_table_rec(l_new_count).p_cohort_override_rank   ,
			x_comments                      =>   l_new_population_table_rec(l_new_count).p_comments
                            );

        l_old_flag := 'N' ;

        END IF;

                  l_new_population_table_rec(l_new_count).p_deletion_indicator        :=        'N'        ;
                  l_rowid := NULL ;
    END LOOP;

           -- If Cohort status is "WORKING" and the rule returned no student population to be ranked,
	   -- then write the message IGS_PR_RNK_NO_POP "No population returned" to the log file.

		IF l_new_count = 0 THEN

       	           FND_MESSAGE.SET_NAME('IGS','IGS_PR_RNK_NO_POP');
                   FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

                END IF;

       -- Deleting Records which from the Cohort Instance Rank table, which do not fit the rule criterian any more.

          FOR j IN 1..l_old_count LOOP

             IF  l_old_population_table_rec(j).p_deletion_indicator = 'Y' THEN

	           igs_pr_cohinst_rank_pkg.delete_row (
	                                          x_rowid  => l_old_population_table_rec(j).p_rowid
		 	                              );

	     END IF;

          END LOOP;

       ELSIF stat_type_rec.dense_rank_ind = 'Y' THEN  --  The Dense Rank Indicator should be set as 'Y' in the table igs_pr_cohort

       	l_old_count := 0;

	-- The existing list of students whose ranking is done for the Cohort Instance

       	FOR old_rank_rec IN  cur_old_rank (p_cohort_name,p_cal_type,p_ci_sequence_number) LOOP

            l_old_count := l_old_count + 1;

			l_old_population_table_rec(l_old_count).p_rowid                       :=        old_rank_rec.row_id ;
			l_old_population_table_rec(l_old_count).p_person_id                   :=        old_rank_rec.person_id  ;
			l_old_population_table_rec(l_old_count).p_course_cd                   :=        old_rank_rec.course_cd  ;
			l_old_population_table_rec(l_old_count).p_cohort_name                 :=        old_rank_rec.cohort_name  ;
			l_old_population_table_rec(l_old_count).p_load_cal_type               :=        old_rank_rec.load_cal_type           ;
			l_old_population_table_rec(l_old_count).p_load_ci_sequence_number     :=        old_rank_rec.load_ci_sequence_number           ;
			l_old_population_table_rec(l_old_count).p_as_of_rank_gpa              :=        old_rank_rec.as_of_rank_gpa    ;
			l_old_population_table_rec(l_old_count).p_cohort_rank                 :=        old_rank_rec.cohort_rank  ;
			l_old_population_table_rec(l_old_count).p_cohort_override_rank        :=        old_rank_rec.cohort_override_rank           ;
			l_old_population_table_rec(l_old_count).p_comments                    :=        old_rank_rec.comments    ;
			l_old_population_table_rec(l_old_count).p_deletion_indicator          :=        'Y'                     ;


        END LOOP;

      -- The output is a record group consisting of the all the students fitting the cohort rule and correspondingly ranked.
      -- Store this in a PL/SQL table called table l_new_population_table

	l_new_count := 0;


      OPEN student_denrank_query_type_rec FOR
      ' SELECT res.* , DENSE_RANK () OVER (order by res.cum_gpa desc) AS new_rank
        FROM
       (SELECT  person_id, course_cd, igs_pr_class_rank.get_cum_gpa ( sca.person_id,sca.course_cd,''' || p_cohort_name || ''',
                                                          ''' || p_cal_type || ''',' || p_ci_sequence_number || ',
                                                          ''' || stat_type_rec.stat_type ||''',
                                                          ''' || l_cumulative_ind || ''' )  cum_gpa
           FROM igs_en_sca_v sca
           WHERE sca.cal_type IN ' || l_acad_cal || '
           AND
           (sca.person_id, sca.course_cd) IN
            (
            SELECT sca.person_id, sca.course_cd
            FROM igs_en_su_attempt sua, igs_en_sca_v sca
            WHERE sua.person_id = sca.person_id
            AND sua.course_cd = sca.course_cd
            AND unit_attempt_status = ''COMPLETED''
            AND (  sua.cal_type , sua.ci_sequence_number ) IN
            (SELECT teach_cal_type, teach_ci_sequence_number
             FROM igs_ca_load_to_teach_v
             WHERE load_cal_type= ''' || p_cal_type || '''
             AND load_ci_sequence_number = ' || p_ci_sequence_number || '
           )
         )
          AND
        igs_pr_class_rank.rulp_val_senna_res (
          sca.person_id,
          sca.course_cd,
          sca.version_number,
          NULL,
          NULL,
          ''' || p_cal_type || ''',
          ' || p_ci_sequence_number || ','
          || stat_type_rec.rule_sequence_number  || ') = ''true''  ) res';

           LOOP
             FETCH student_denrank_query_type_rec INTO student_denseranked_query_rec;
             EXIT WHEN student_denrank_query_type_rec%NOTFOUND;

	     p_count := p_count + 1;

             l_old_flag := 'Y';


            l_new_count := l_new_count + 1;

			l_new_population_table_rec(l_new_count).p_person_id                   :=        student_denseranked_query_rec.person_id  ;
			l_new_population_table_rec(l_new_count).p_course_cd                   :=        student_denseranked_query_rec.course_cd  ;
			l_new_population_table_rec(l_new_count).p_cohort_name                 :=        p_cohort_name                       ;
			l_new_population_table_rec(l_new_count).p_load_cal_type               :=        p_cal_type                          ;
			l_new_population_table_rec(l_new_count).p_load_ci_sequence_number     :=        p_ci_sequence_number                ;
			l_new_population_table_rec(l_new_count).p_as_of_rank_gpa              :=        student_denseranked_query_rec.cum_gpa    ;
			l_new_population_table_rec(l_new_count).p_cohort_rank                 :=        student_denseranked_query_rec.new_rank   ;
			l_new_population_table_rec(l_new_count).p_cohort_override_rank        :=        NULL                                ;
			l_new_population_table_rec(l_new_count).p_comments                    :=        NULL                                ;
			l_new_population_table_rec(l_new_count).p_deletion_indicator          :=        'Y'                                 ;


	    FOR i IN 1..l_old_count LOOP


	         IF(   l_new_population_table_rec(l_new_count).p_person_id = l_old_population_table_rec(i).p_person_id AND
		      l_new_population_table_rec(l_new_count).p_course_cd = l_old_population_table_rec(i).p_course_cd AND
		      l_new_population_table_rec(l_new_count).p_cohort_name =  l_old_population_table_rec(i).p_cohort_name AND
                      l_new_population_table_rec(l_new_count).p_load_cal_type = l_old_population_table_rec(i).p_load_cal_type AND
                      l_new_population_table_rec(l_new_count).p_load_ci_sequence_number = l_old_population_table_rec(i).p_load_ci_sequence_number ) THEN

		  -- If the students existinf in the old cohort instance list and the new cohort instance then the old rank and the GPA for the student is updated in the
		  -- Cohort Instance Rank table.


            l_old_flag := 'N';

                       igs_pr_cohinst_rank_pkg.update_row (
			x_rowid                      =>   l_old_population_table_rec(i).p_rowid ,
			x_cohort_name                =>   l_old_population_table_rec(i).p_cohort_name,
			x_load_cal_type              =>   l_old_population_table_rec(i).p_load_cal_type ,
			x_load_ci_sequence_number    =>   l_old_population_table_rec(i).p_load_ci_sequence_number ,
			x_person_id                  =>   l_old_population_table_rec(i).p_person_id ,
			x_course_cd                  =>   l_old_population_table_rec(i).p_course_cd ,
			x_as_of_rank_gpa             =>   l_new_population_table_rec(l_new_count).p_as_of_rank_gpa ,
			x_cohort_rank                =>   l_new_population_table_rec(l_new_count).p_cohort_rank ,
			x_cohort_override_rank       =>   l_old_population_table_rec(i).p_cohort_override_rank  ,
			x_comments                   =>   l_old_population_table_rec(i).p_comments
                                );

                 -- Marking the Records in the New List and the Old list, for the records which already exist in the
		 -- Cohort Instance Rank table as of this step. This indicator would be used later, when the
		 -- records for the Student Cohort Instance rank has to be deleted from the table Cohort Instance Rank,
		 -- which are not avaliable in the new list.

                    l_new_population_table_rec(l_new_count).p_deletion_indicator        :=        'N'        ;
		    l_old_population_table_rec(i).p_deletion_indicator                  :=        'N'        ;

         END IF;

		  -- Records existing in the new list and not in the old list . Those records are inserted in the Cohort Instance Rank table

    	END LOOP;

           IF l_old_flag = 'Y' THEN
                      igs_pr_cohinst_rank_pkg.insert_row (
			x_rowid                         =>   l_rowid ,
			x_cohort_name                   =>   l_new_population_table_rec(l_new_count).p_cohort_name ,
			x_load_cal_type                 =>   l_new_population_table_rec(l_new_count).p_load_cal_type ,
			x_load_ci_sequence_number       =>   l_new_population_table_rec(l_new_count).p_load_ci_sequence_number,
			x_person_id                     =>   l_new_population_table_rec(l_new_count).p_person_id ,
			x_course_cd                     =>   l_new_population_table_rec(l_new_count).p_course_cd ,
			x_as_of_rank_gpa                =>   l_new_population_table_rec(l_new_count).p_as_of_rank_gpa ,
			x_cohort_rank                   =>   l_new_population_table_rec(l_new_count).p_cohort_rank    ,
			x_cohort_override_rank          =>   l_new_population_table_rec(l_new_count).p_cohort_override_rank   ,
			x_comments                      =>   l_new_population_table_rec(l_new_count).p_comments
                            );

            l_old_flag := 'N';

            END IF;

                   l_new_population_table_rec(l_new_count).p_deletion_indicator        :=        'Y'        ;
                   l_rowid := NULL ;


	END LOOP;

          -- If Cohort status is "WORKING" and the rule returned no student population to be ranked,
          -- then write the message IGS_PR_RNK_NO_POP "No population returned" to the log file.

             	IF l_new_count = 0 THEN

       	           FND_MESSAGE.SET_NAME('IGS','IGS_PR_RNK_NO_POP');
                   FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

                END IF;

       -- Deleting Records which from the Cohort Instance Rank table, which do not fit the rule criterian any more.


       FOR j IN 1..l_old_count LOOP

           IF  l_old_population_table_rec(j).p_deletion_indicator = 'Y' THEN

	           igs_pr_cohinst_rank_pkg.delete_row (
	                                          x_rowid  => l_old_population_table_rec(j).p_rowid
		 	                              );

	   END IF;

       END LOOP;


   END IF;

	--
	-- Updating the Cohert Instance table with the rundate as the System Date. Rest of the values are retained.
	--

	     igs_pr_cohort_inst_pkg.update_row(
                                         x_rowid                    => rank_status_rec.row_id,
                                         x_cohort_name              => rank_status_rec.cohort_name,
                                         x_load_cal_type            => rank_status_rec.load_cal_type,
                                         x_load_ci_sequence_number  => rank_status_rec.load_ci_sequence_number,
                                         x_cohort_status            => rank_status_rec.cohort_status,
                                         x_rank_status              => rank_status_rec.rank_status,
                                         x_run_date                 => SYSDATE
                                                );

   END IF ; -- 2

END IF; --1

EXCEPTION
  WHEN OTHERS THEN
        Fnd_Message.Set_Name('IGS', 'Ranking Process => ' || SQLERRM);
    	IGS_GE_MSG_STACK.ADD;
        Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','IGS_PR_CLASS_RANK.RANKING_PROCESS');
    	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
END ranking_process ;


FUNCTION  get_cum_gpa
              ( p_person_id             IN igs_en_sca_v.person_id%TYPE,
                p_course_cd             IN igs_en_sca_v.course_cd%TYPE,
                p_cohort_name           IN igs_pr_cohort.cohort_name%TYPE,
                p_cal_type              IN igs_ca_inst.cal_type%TYPE,
                p_ci_sequence_number    IN igs_ca_inst.sequence_number%TYPE,
                p_stat_type             IN VARCHAR2,
         		p_cumulative_ind        IN VARCHAR2
                ) RETURN NUMBER IS
/****************************************************************************************************************
  ||  Created By : DDEY
  ||  Created On : 28-OCT-2002
  ||  Purpose : A new function called GET_CUM_GPA is required for fetching the GPA, which is used in calculating the rank for each of these students .
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || swaghmar	  15-Sep-2005		Bug# 4491456
  ||  (reverse chronological order - newest change first)
****************************************************************************************************************/

l_gpa_val               NUMBER;
l_gpa_cp                NUMBER;
l_gpa_quality_points    NUMBER;
l_return_status         VARCHAR2(30);
l_msg_count             NUMBER ;
l_msg_data              VARCHAR2(2000);

BEGIN

  igs_pr_cp_gpa.get_gpa_stats(  p_person_id                   => p_person_id             ,
                                p_course_cd                   => p_course_cd             ,
                                p_stat_type                   => p_stat_type             ,
                                p_load_cal_type               => p_cal_type              ,
                                p_load_ci_sequence_number     => p_ci_sequence_number    ,
                                p_system_stat                 => NULL                    ,
                                p_cumulative_ind              => p_cumulative_ind        ,
                                p_gpa_value                   => l_gpa_val               ,
                                p_gpa_cp                      => l_gpa_cp                ,
                                p_gpa_quality_points          => l_gpa_quality_points    ,
                                p_init_msg_list               => NULL                    ,
                                p_return_status               => l_return_status         ,
                                p_msg_count                   => l_msg_count             ,
                                p_msg_data                    => l_msg_data        ) ;



 IF l_gpa_val IS NULL THEN
   return 0 ;
 ELSE
 return l_gpa_val ;
 END IF;


END get_cum_gpa ;

FUNCTION rulp_val_senna_res (
                       p_person_id           IN igs_en_sca_v.person_id%TYPE,
                       p_course_cd           IN igs_en_sca_v.course_cd%TYPE ,
                       p_course_version      IN igs_en_sca_v.version_number%TYPE,
                       p_unit_cd             IN igs_en_su_attempt.unit_cd%TYPE,
                       p_unit_version        IN igs_en_su_attempt.version_number%TYPE,
                       p_cal_type            IN igs_en_su_attempt.cal_type%TYPE,
                       p_ci_sequence_number  IN igs_en_su_attempt.ci_sequence_number%TYPE,
                       p_rule_number         IN igs_ru_call_v.rul_sequence_number%TYPE) RETURN VARCHAR2  IS

/****************************************************************************************************************
  ||  Created By : DDEY
  ||  Created On : 28-OCT-2002
  ||  Purpose : A new function which call IGS_RU_GEN_001.RULP_VAL_SENNA. This function is created
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
****************************************************************************************************************/

l_message  VARCHAR2(2000);
l_status   VARCHAR2(2000);

BEGIN

l_status :=  igs_ru_gen_001.rulp_val_senna (
                p_person_id            => p_person_id,
                p_course_cd            => p_course_cd,
                p_course_version       => p_course_version,
                p_unit_cd              => NULL,
                p_unit_version         => NULL,
                p_cal_type             => p_cal_type,
                p_ci_sequence_number   => p_ci_sequence_number,
                p_message              => l_message ,
                p_rule_number          => p_rule_number,
		p_param_1              => p_course_cd) ;


RETURN l_status ;

END rulp_val_senna_res ;



  PROCEDURE raise_clsrank_be_cr001 (p_cohort_name IN VARCHAR2,
                                    p_cohort_instance IN VARCHAR2,
				    p_new_cohort_status IN VARCHAR2,
				    p_new_rank_status IN VARCHAR2) IS

	l_wf_event_t            WF_EVENT_T;
        l_wf_parameter_list_t   WF_PARAMETER_LIST_T;

  BEGIN
         --
         -- initialize the wf_event_t object
         --
         WF_EVENT_T.Initialize(l_wf_event_t);
         --
         -- set the event name
         --
         l_wf_event_t.setEventName( pEventName => 'oracle.apps.igs.pr.clsrank_be_cr001');
         --
         -- set the event key but before the select a number from sequenec
         --
         l_wf_event_t.setEventKey ( pEventKey => 'be_cr001'||TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS') );
         --
         -- set the parameter list
         --
         l_wf_event_t.setParameterList ( pParameterList => l_wf_parameter_list_t );
         --
         -- now add the parameters to the parameter list
         --
         wf_event.addparametertolist(
		 P_NAME                         => 'COHORT_NAME' ,
		 P_VALUE                        => p_cohort_name  ,
		 P_PARAMETERLIST                => l_wf_parameter_list_t);
         wf_event.addparametertolist(
		 P_NAME                         => 'COHORT_INSTANCE' ,
		 P_VALUE                        => p_cohort_instance,
		 P_PARAMETERLIST                => l_wf_parameter_list_t);
         wf_event.addparametertolist(
		 P_NAME                         => 'NEW_COHORT_STATUS' ,
		 P_VALUE                        => p_new_cohort_status  ,
		 P_PARAMETERLIST                => l_wf_parameter_list_t);
         wf_event.addparametertolist(
		 P_NAME                         => 'NEW_RANK_STATUS' ,
		 P_VALUE                        => p_new_rank_status  ,
		 P_PARAMETERLIST                => l_wf_parameter_list_t);

         --
         -- raise the event
         --
         WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.pr.clsrank_be_cr001',
                         p_event_key  => 'be_cr001'||TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS'),
                         p_event_data => NULL,
                         p_parameters => l_wf_parameter_list_t);

  END raise_clsrank_be_cr001;


  PROCEDURE raise_clsrank_be_cr002 (p_person_id           IN NUMBER,
                                    p_person_number       IN VARCHAR2,
                                    p_person_name         IN VARCHAR2,
				    p_current_rank        IN NUMBER,
				    p_override_rank       IN NUMBER,
				    p_ovrby_person_id     IN NUMBER,
				    p_ovrby_person_number IN VARCHAR2,
				    p_ovrby_person_name   IN VARCHAR2) IS

	l_wf_event_t            WF_EVENT_T;
        l_wf_parameter_list_t   WF_PARAMETER_LIST_T;

  BEGIN
         --
         -- initialize the wf_event_t object
         --
         WF_EVENT_T.Initialize(l_wf_event_t);
         --
         -- set the event name
         --
         l_wf_event_t.setEventName( pEventName => 'oracle.apps.igs.pr.clsrank_be_cr002');
         --
         -- set the event key but before the select a number from sequenec
         --
         l_wf_event_t.setEventKey ( pEventKey => 'be_cr002'||TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS') );
         --
         -- set the parameter list
         --
         l_wf_event_t.setParameterList ( pParameterList => l_wf_parameter_list_t );
         --
         -- now add the parameters to the parameter list
         --
         wf_event.addparametertolist(
		 P_NAME                         => 'PERSON_ID' ,
		 P_VALUE                        => p_person_id  ,
		 P_PARAMETERLIST                => l_wf_parameter_list_t);
         wf_event.addparametertolist(
		 P_NAME                         => 'PERSON_NUMBER' ,
		 P_VALUE                        => p_person_number,
		 P_PARAMETERLIST                => l_wf_parameter_list_t);
         wf_event.addparametertolist(
		 P_NAME                         => 'PERSON_NAME' ,
		 P_VALUE                        => p_person_name  ,
		 P_PARAMETERLIST                => l_wf_parameter_list_t);
         wf_event.addparametertolist(
		 P_NAME                         => 'CURRENT_RANK' ,
		 P_VALUE                        => p_current_rank  ,
		 P_PARAMETERLIST                => l_wf_parameter_list_t);
         wf_event.addparametertolist(
		 P_NAME                         => 'OVERRIDE_RANK' ,
		 P_VALUE                        => p_override_rank  ,
		 P_PARAMETERLIST                => l_wf_parameter_list_t);
         wf_event.addparametertolist(
		 P_NAME                         => 'OVRBY_PERSON_ID' ,
		 P_VALUE                        => p_ovrby_person_id  ,
		 P_PARAMETERLIST                => l_wf_parameter_list_t);
         wf_event.addparametertolist(
		 P_NAME                         => 'OVRBY_PERSON_NUMBER' ,
		 P_VALUE                        => p_ovrby_person_number  ,
		 P_PARAMETERLIST                => l_wf_parameter_list_t);
         wf_event.addparametertolist(
		 P_NAME                         => 'OVRBY_PERSON_NAME' ,
		 P_VALUE                        => p_ovrby_person_name  ,
		 P_PARAMETERLIST                => l_wf_parameter_list_t);
         --
         -- raise the event
         --
         WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.pr.clsrank_be_cr002',
                         p_event_key  => 'be_cr002'||TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS'),
                         p_event_data => NULL,
                         p_parameters => l_wf_parameter_list_t);

  END raise_clsrank_be_cr002;



  PROCEDURE raise_clsrank_be_cr003 (p_cohort_name IN VARCHAR2,
                                    p_cohort_instance IN VARCHAR2,
				    p_run_date IN VARCHAR2,
				    p_cohort_total_students IN VARCHAR2) IS

	l_wf_event_t            WF_EVENT_T;
        l_wf_parameter_list_t   WF_PARAMETER_LIST_T;

  BEGIN
         --
         -- initialize the wf_event_t object
         --
         WF_EVENT_T.Initialize(l_wf_event_t);
         --
         -- set the event name
         --
         l_wf_event_t.setEventName( pEventName => 'oracle.apps.igs.pr.clsrank_be_cr003');
         --
         -- set the event key but before the select a number from sequenec
         --
         l_wf_event_t.setEventKey ( pEventKey => 'be_cr003'||TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS') );
         --
         -- set the parameter list
         --
         l_wf_event_t.setParameterList ( pParameterList => l_wf_parameter_list_t );
         --
         -- now add the parameters to the parameter list
         --
         wf_event.addparametertolist(
		 P_NAME                         => 'COHORT_NAME' ,
		 P_VALUE                        => p_cohort_name  ,
		 P_PARAMETERLIST                => l_wf_parameter_list_t);
         wf_event.addparametertolist(
		 P_NAME                         => 'COHORT_INSTANCE' ,
		 P_VALUE                        => p_cohort_instance,
		 P_PARAMETERLIST                => l_wf_parameter_list_t);
         wf_event.addparametertolist(
		 P_NAME                         => 'NEW_RUN_DATE' ,
		 P_VALUE                        => p_run_date  ,
		 P_PARAMETERLIST                => l_wf_parameter_list_t);
         wf_event.addparametertolist(
		 P_NAME                         => 'NEW_COHORT_TOTAL_STUDENTS' ,
		 P_VALUE                        => p_cohort_total_students  ,
		 P_PARAMETERLIST                => l_wf_parameter_list_t);

         --
         -- raise the event
         --
         WF_EVENT.RAISE (p_event_name => 'oracle.apps.igs.pr.clsrank_be_cr003',
                         p_event_key  => 'be_cr003'||TO_CHAR(SYSDATE,'YYYYMMDDHH24MISS'),
                         p_event_data => NULL,
                         p_parameters => l_wf_parameter_list_t);

  END raise_clsrank_be_cr003;



  PROCEDURE  get_formatted_rank  (p_cohort_name        IN VARCHAR2,
                          p_cal_type           IN VARCHAR2,
			  p_ci_sequence_number IN NUMBER,
			  p_person_id          IN NUMBER,
			  p_disp_type          IN VARCHAR2, /* pass lookup code */
			  p_program_cd         IN VARCHAR2,
			  x_formatted_rank     OUT NOCOPY VARCHAR2,
			  x_return_status      OUT NOCOPY VARCHAR2,
			  x_msg_count          OUT NOCOPY NUMBER,
			  x_msg_data           OUT NOCOPY VARCHAR2)
  AS
       -- cursor to get default display type
     CURSOR c_dflt_disp_type (cp_cohort_name igs_pr_cohort.cohort_name%TYPE) IS
            SELECT dflt_display_type
	    FROM   igs_pr_cohort
	    WHERE  cohort_name = cp_cohort_name;
     l_disp_type 	   igs_pr_cohort.dflt_display_type%TYPE;

     -- cursor to select the rank
     CURSOR c_rank (cp_cohort_name          igs_pr_cohort.cohort_name%TYPE,
                    cp_cal_type             igs_pr_cohort_inst.load_cal_type%TYPE,
		    cp_ci_sequence_number   igs_pr_cohort_inst.load_ci_sequence_number%TYPE,
		    cp_person_id            igs_pr_cohinst_rank.person_id%TYPE,
		    cp_program_cd           igs_pr_cohinst_rank.course_cd%TYPE) IS
            SELECT NVL(cohort_override_rank, cohort_rank)
            FROM igs_pr_cohort_inst_rank_v cohirv
            WHERE cohirv.cohort_name             = cp_cohort_name
            AND   cohirv.load_cal_type           = cp_cal_type
            AND   cohirv.load_ci_sequence_number = cp_ci_sequence_number
            AND   cohirv.person_id               = cp_person_id
            AND   cohirv.course_cd               = cp_program_cd;
     l_rank  igs_pr_cohinst_rank.cohort_rank%TYPE;

     -- cursor to get the cohort population
     CURSOR c_cohort_population (cp_cohort_name          igs_pr_cohort.cohort_name%TYPE,
                                 cp_cal_type             igs_pr_cohort_inst.load_cal_type%TYPE,
		                 cp_ci_sequence_number   igs_pr_cohort_inst.load_ci_sequence_number%TYPE) IS
     	   SELECT COUNT (*)
	   FROM igs_pr_cohort_inst_rank_v cohirv
	   WHERE cohirv.cohort_name            = cp_cohort_name
	   AND cohirv.load_cal_type            = cp_cal_type
           AND cohirv.load_ci_sequence_number  = cp_ci_sequence_number;

     l_cohort_population  NUMBER;

     l_formatted_rank     VARCHAR2(4000);

     -- cursor to get nth for a number like 84th
     CURSOR c_nth (cp_rank VARCHAR2) IS
            SELECT LTRIM (TO_CHAR (TO_DATE (cp_rank,'J'),'Jth'),'0') FROM DUAL;
     l_nth VARCHAR2(4000);

  BEGIN
    Fnd_Msg_Pub.Initialize;
    l_formatted_rank := NULL;
    -- validate parameters
    IF p_cohort_name IS NULL OR
       p_cal_type    IS NULL OR
       p_ci_sequence_number IS NULL OR
       p_person_id   IS NULL OR
       p_program_cd  IS NULL THEN
       l_formatted_rank := NULL;
       FND_MESSAGE.SET_NAME ('IGS','IGS_AD_INVALID_PARAM_COMB');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- select the default display type if p_disp_type is null
    IF  p_disp_type IS NULL THEN
      OPEN c_dflt_disp_type (p_cohort_name);
      FETCH c_dflt_disp_type INTO l_disp_type;
      CLOSE c_dflt_disp_type;
    ELSE
      l_disp_type := p_disp_type;
    END IF;

    -- select the rank
    OPEN c_rank (p_cohort_name       ,
		 p_cal_type          ,
		 p_ci_sequence_number,
		 p_person_id         ,
		 p_program_cd        );
    FETCH c_rank INTO l_rank;
    IF c_rank%NOTFOUND THEN
       CLOSE c_rank;
       FND_MESSAGE.SET_NAME ('IGS','IGS_PR_NO_RANK_AVL');
       FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_rank;

    -- select the cohort population
    OPEN c_cohort_population (p_cohort_name       ,
		              p_cal_type          ,
		              p_ci_sequence_number);
    FETCH c_cohort_population INTO l_cohort_population;
    CLOSE c_cohort_population;

    -- decide number
    IF l_disp_type = 'N_OF_N' THEN
       l_formatted_rank := l_rank||' '||FND_MESSAGE.GET_STRING('IGS','IGS_PR_MSG_OF')||' '||l_cohort_population ;
    ELSIF l_disp_type = 'PERCENTILE' THEN
       l_formatted_rank := CEIL ((l_rank * 100)/(l_cohort_population + 1)) ;
    ELSIF l_disp_type = 'VIGINTILE' THEN
       l_formatted_rank := CEIL ((l_rank * 20)/(l_cohort_population + 1))*100/20 ;
    ELSIF l_disp_type = 'DECILE' THEN
       l_formatted_rank := CEIL ((l_rank * 10)/(l_cohort_population + 1))*100/10 ;
    ELSIF l_disp_type = 'QUINTILE' THEN
       l_formatted_rank := CEIL ((l_rank * 5)/(l_cohort_population + 1))*100/5 ;
    ELSIF l_disp_type = 'QUARTILE' THEN
       l_formatted_rank := CEIL ((l_rank * 4)/(l_cohort_population + 1))*100/4 ;
    ELSIF l_disp_type = 'TOP_THIRD' THEN
       IF ((l_cohort_population-l_rank)/l_cohort_population)*100 > 67 THEN
          l_formatted_rank := FND_MESSAGE.GET_STRING('IGS','IGS_PR_RNK_TP_TRD');
       ELSE
          l_formatted_rank := NULL;
       END IF;
    END IF;
    IF l_formatted_rank IS NOT NULL THEN
       -- check that l_formatted_rank carries a number
       DECLARE
         n NUMBER;
       BEGIN
         n := to_number(l_formatted_rank);
	 OPEN c_nth (l_formatted_rank);
	 FETCH c_nth INTO l_nth;
	 CLOSE c_nth;
	 l_formatted_rank := l_nth||' '||FND_MESSAGE.GET_STRING('IGS','IGS_PR_RNK_PRCNTL');
       EXCEPTION
         WHEN OTHERS THEN
	   NULL;
       END;
    END IF;


    x_formatted_rank := l_formatted_rank;
   --Initialize API return status to success.
    x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   --Standard call to get message count and if count is 1, get message
   --info.
   Fnd_Msg_Pub.Count_And_Get(
                p_encoded => Fnd_Api.G_FALSE,
                p_count =>  x_msg_count,
                p_data  =>  x_msg_data);

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_formatted_rank := l_formatted_rank;
 	X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                 p_encoded => FND_API.G_FALSE,
                 p_count => x_MSG_COUNT,
                 p_data  => X_MSG_DATA);
    RETURN;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
                x_formatted_rank := l_formatted_rank;
                X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.Count_And_Get(
                    p_encoded => FND_API.G_FALSE,
                    p_count => x_MSG_COUNT,
                    p_data  => X_MSG_DATA);
    RETURN;
    WHEN OTHERS THEN
         x_formatted_rank := l_formatted_rank;
         X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MESSAGE.SET_NAME('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
         FND_MESSAGE.SET_TOKEN('NAME','Insert_Row : '||SQLERRM);
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.Count_And_Get(
                           p_encoded => FND_API.G_FALSE,
                           p_count => x_MSG_COUNT,
                           p_data  => X_MSG_DATA);
   RETURN;
  END get_formatted_rank;

    FUNCTION get_formatted_rank (p_cohort_name   IN VARCHAR2,
                                  p_cal_type      IN VARCHAR2,
                                  p_ci_sequence_number IN NUMBER,
                                  p_person_id          IN NUMBER,
                                  p_disp_type          IN VARCHAR2,
                                  p_program_cd         IN VARCHAR2)
    RETURN  VARCHAR2
    /****************************************************************************************************************
      ||  Created By : SMANGLM
      ||  Created On : 28-OCT-2002
      ||  Purpose : This is the function returning rank
      ||  Known limitations, enhancements or remarks :
      ||  Change History :
      ||  Who             When            What
      ||  (reverse chronological order - newest change first)
    ****************************************************************************************************************/
    AS
            l_formatted_rank     VARCHAR2(2000) := null;
            l_return_status      VARCHAR2(10):=null;
            l_msg_count          NUMBER :=null;
            l_msg_data           VARCHAR2(2000):=null;
    BEGIN
        IGS_PR_CLASS_RANK.GET_FORMATTED_RANK (
             P_COHORT_NAME        => p_cohort_name,
             P_CAL_TYPE           => p_cal_type,
             P_CI_SEQUENCE_NUMBER => p_ci_sequence_number,
             P_PERSON_ID          => p_person_id,
             P_DISP_TYPE          => p_disp_type,
             P_PROGRAM_CD         => p_program_cd,
             X_FORMATTED_RANK     => l_formatted_rank,
             X_RETURN_STATUS      => l_return_status  ,
             X_MSG_COUNT          => l_msg_count      ,
             X_MSG_DATA           => l_msg_data );
        IF l_formatted_rank IS NOT NULL THEN
           RETURN l_formatted_rank;
        ELSE
           RETURN NULL;
        END IF;
    END get_formatted_rank;


END igs_pr_class_rank;

/
