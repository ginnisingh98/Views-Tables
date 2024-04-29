--------------------------------------------------------
--  DDL for Package Body IGS_PR_USER_CLASS_STD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_USER_CLASS_STD" 
/* $Header: IGSPR39B.pls 120.0 2006/04/29 02:16:28 swaghmar noship $ */
AS
 -------------------------------------------------------------------------------------------
--Creation:
--User Hook procedure to allow users to use their own logic to derive the Class Standing.
--If there is no Institution specific Class Standing logic then get_customized_class_std
--should remain empty.
--Change History:
--Who         When            What
-- swaghmar   20-Apr-2006     Created for bug# 5171158
-------------------------------------------------------------------------------------------
   FUNCTION get_customized_class_std (
      p_person_id                 IN   NUMBER,
      p_course_cd                 IN   VARCHAR2,
      p_predictive_ind            IN   VARCHAR2 DEFAULT 'N',
      p_effective_dt              IN   DATE,
      p_load_cal_type             IN   VARCHAR2,
      p_load_ci_sequence_number   IN   NUMBER,
      p_init_msg_list             IN   VARCHAR2 DEFAULT fnd_api.g_false
   )RETURN VARCHAR2   IS
   BEGIN
	RETURN 'NULL'; -- Should be the class standing derived by the customized method
   END get_customized_class_std;

END igs_pr_user_class_std;

/
