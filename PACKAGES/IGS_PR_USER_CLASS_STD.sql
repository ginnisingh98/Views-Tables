--------------------------------------------------------
--  DDL for Package IGS_PR_USER_CLASS_STD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_USER_CLASS_STD" 
/* $Header: IGSPR39S.pls 120.0 2006/04/29 02:15:56 swaghmar noship $ */
AUTHID CURRENT_USER AS
-------------------------------------------------------------------------------------------
--Creation:
--User Hook procedure to allow users to use their own logic to derive the Class Standing.
--If there is no Institution specific Class Standing logic then set customized_class_standing_flag to 'N'
--If Class Standing logic is being customized set customized_class_standing_flag to 'Y'
--Change History:
--Who         When            What
-- swaghmar   20-Apr-2006     Created for Bug# 5171158
-------------------------------------------------------------------------------------------

   customized_class_standing_flag VARCHAR2(1) := 'N';

   FUNCTION get_customized_class_std (
      p_person_id                 IN   NUMBER,
      p_course_cd                 IN   VARCHAR2,
      p_predictive_ind            IN   VARCHAR2 DEFAULT 'N',
      p_effective_dt              IN   DATE,
      p_load_cal_type             IN   VARCHAR2,
      p_load_ci_sequence_number   IN   NUMBER,
      p_init_msg_list             IN   VARCHAR2 DEFAULT fnd_api.g_false
   )  RETURN VARCHAR2;

END igs_pr_user_class_std;

 

/
