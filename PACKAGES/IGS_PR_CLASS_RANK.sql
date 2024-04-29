--------------------------------------------------------
--  DDL for Package IGS_PR_CLASS_RANK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_CLASS_RANK" AUTHID CURRENT_USER AS
 /* $Header: IGSPR37S.pls 115.3 2002/11/29 02:53:02 nsidana noship $ */

/****************************************************************************************************************
  ||  Created By : DDEY
  ||  Created On : 28-OCT-2002
  ||  Purpose : This Job Rankes the students in a cohert or in an orginization
  ||  This process can be called from the concurrent manager or the form "Class Rank Cohort".
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
****************************************************************************************************************/

 FUNCTION rulp_val_senna_res (
                       p_person_id           IN igs_en_sca_v.person_id%TYPE,
                       p_course_cd           IN igs_en_sca_v.course_cd%TYPE ,
                       p_course_version      IN igs_en_sca_v.version_number%TYPE,
                       p_unit_cd             IN igs_en_su_attempt.unit_cd%TYPE,
                       p_unit_version        IN igs_en_su_attempt.version_number%TYPE,
                       p_cal_type            IN igs_en_su_attempt.cal_type%TYPE,
                       p_ci_sequence_number  IN igs_en_su_attempt.ci_sequence_number%TYPE,
                       p_rule_number         IN igs_ru_call_v.rul_sequence_number%TYPE) RETURN VARCHAR2;


 FUNCTION  get_cum_gpa (
                p_person_id             IN igs_en_sca_v.person_id%TYPE,
                p_course_cd             IN igs_en_sca_v.course_cd%TYPE,
                p_cohort_name           IN igs_pr_cohort.cohort_name%TYPE,
                p_cal_type              IN igs_ca_inst.cal_type%TYPE,
                p_ci_sequence_number    IN igs_ca_inst.sequence_number%TYPE,
                p_stat_type             IN VARCHAR2,
		p_cumulative_ind        IN VARCHAR2
                ) RETURN NUMBER ;


PROCEDURE  run_ranking_process (
     errbuf                OUT NOCOPY	  VARCHAR2,  -- Standard Error Buffer Variable
     retcode               OUT NOCOPY	  NUMBER,    -- Standard Concurrent Return code
     p_cohort_name         IN     VARCHAR2,  -- The Cohart or the Student Group Name
     p_cal_period          IN     VARCHAR2,  -- The Calendar Period ie the concation of term Calendar Type and the sequence Number
     p_org_unit_cd         IN     VARCHAR2   -- Org Unit Code
);

TYPE new_population_record_type IS RECORD (
                                 p_person_id                   NUMBER(30),
                                 p_course_cd                   VARCHAR2(6),
                                 p_cohort_name                 VARCHAR2(30),
                                 p_load_cal_type               VARCHAR2(10),
                                 p_load_ci_sequence_number     NUMBER(6),
				 p_as_of_rank_gpa              NUMBER,
				 p_cohort_rank                 NUMBER(15),
				 p_cohort_override_rank        NUMBER(15),
				 p_comments                    VARCHAR2(240),
				 p_deletion_indicator          VARCHAR2(2)
                                    );



TYPE old_population_record_type IS RECORD (
                                 p_rowid                        VARCHAR2(2000),
                                 p_person_id                    NUMBER(30),
                                 p_course_cd                    VARCHAR2(6),
                                 p_cohort_name                  VARCHAR2(30),
                                 p_load_cal_type                VARCHAR2(10),
                                 p_load_ci_sequence_number      NUMBER(6),
				 p_as_of_rank_gpa               NUMBER,
				 p_cohort_rank                  NUMBER(15),
				 p_cohort_override_rank         NUMBER(15),
				 p_comments                     VARCHAR2(240),
				 p_deletion_indicator          	VARCHAR2(2)
                                    );


new_population_record_rec new_population_record_type;
old_population_record_rec old_population_record_type;


-- Table type for the record type NEW_POPULATION_RECORD

TYPE l_new_population_table_type IS TABLE OF new_population_record_rec%TYPE INDEX BY BINARY_INTEGER;
l_new_population_table_rec l_new_population_table_type;

-- Table type for the record type OLD_POPULATION_RECORD

TYPE l_old_population_table_type IS TABLE OF old_population_record_rec%TYPE INDEX BY BINARY_INTEGER;
l_old_population_table_rec l_old_population_table_type;


PROCEDURE raise_clsrank_be_cr001 (p_cohort_name IN VARCHAR2,
                                    p_cohort_instance IN VARCHAR2,
				    p_new_cohort_status IN VARCHAR2,
				    p_new_rank_status IN VARCHAR2);

PROCEDURE raise_clsrank_be_cr002 (p_person_id           IN NUMBER,
                                  p_person_number       IN VARCHAR2,
                                  p_person_name         IN VARCHAR2,
  			          p_current_rank        IN NUMBER,
			          p_override_rank       IN NUMBER,
			          p_ovrby_person_id     IN NUMBER,
			          p_ovrby_person_number IN VARCHAR2,
			          p_ovrby_person_name   IN VARCHAR2) ;



PROCEDURE  get_formatted_rank  (p_cohort_name        IN VARCHAR2,
                          p_cal_type           IN VARCHAR2,
			  p_ci_sequence_number IN NUMBER,
			  p_person_id          IN NUMBER,
			  p_disp_type          IN VARCHAR2, /* pass lookup code */
			  p_program_cd         IN VARCHAR2,
			  x_formatted_rank     OUT NOCOPY VARCHAR2,
			  x_return_status      OUT NOCOPY VARCHAR2,
			  x_msg_count          OUT NOCOPY NUMBER,
			  x_msg_data           OUT NOCOPY VARCHAR2) ;


PROCEDURE raise_clsrank_be_cr003 (p_cohort_name IN VARCHAR2,
                                  p_cohort_instance IN VARCHAR2,
    			          p_run_date IN VARCHAR2,
				  p_cohort_total_students IN VARCHAR2) ;

FUNCTION get_formatted_rank (p_cohort_name   IN VARCHAR2,
                              p_cal_type      IN VARCHAR2,
			      p_ci_sequence_number IN NUMBER,
			      p_person_id          IN NUMBER,
			      p_disp_type          IN VARCHAR2,
			      p_program_cd         IN VARCHAR2)
RETURN  VARCHAR2;
END igs_pr_class_rank;

 

/
