--------------------------------------------------------
--  DDL for Package Body IGF_AP_RULE_CALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_RULE_CALL_PKG" AS
/* $Header: IGFAP11B.pls 120.1 2005/09/08 14:34:41 appldev noship $ */

    Function Rule_Call (
      p_rule_number 		    IN NUMBER   ,
      p_person_id	            IN NUMBER   ,
      p_base_id			    IN NUMBER   ,
      p_param_6                     IN VARCHAR2 DEFAULT NULL,
      p_param_7                     IN VARCHAR2 DEFAULT NULL,
      p_param_8                     IN VARCHAR2 DEFAULT NULL,
      p_param_9                     IN VARCHAR2 DEFAULT NULL,
      p_param_10                    IN VARCHAR2 DEFAULT NULL,
      p_param_11                    IN VARCHAR2 DEFAULT NULL
      )
      RETURN VARCHAR2 IS

	v_message VARCHAR2(1000);

-- This cursor has been added for Admission Test Scores and Admission Test Types rule elements.
        CURSOR get_adm_rowid IS SELECT rowid FROM igs_ad_test_results
	  WHERE person_id = p_person_id;


        CURSOR get_per_rowid IS SELECT rowid FROM  igs_pe_prsid_grp_mem_all pgm
	  WHERE pgm.person_id = p_person_id;


	l_rowid     VARCHAR2(50) := NULL;
        v_retflag   VARCHAR2(10);
	l_retflag   VARCHAR2(10);
	l_adm_rowid VARCHAR2(50);
	l_per_rowid VARCHAR2(50);

  BEGIN

 -- John Deekollu 17-JUL-2001.Removed the earlier code and modified according to the OSS FAM Integration DLD. Param_1 thru Pram_5 values are dummy and not required by IGF
    l_retflag := 'FALSE';
--
--  RASINGH: 01-JUL-2002: Code added for Admission Test Score and Admission Test Type Bug: 2430410
--
         IF  get_adm_rowid%ISOPEN THEN
		  NULL;
	  ELSE
		  OPEN get_adm_rowid;
	  END IF;
         FETCH get_adm_rowid INTO l_adm_rowid;
         IF get_adm_rowid%NOTFOUND THEN
		  l_adm_rowid := NULL;
	  END IF;

	  l_adm_rowid := ''''||l_adm_rowid||'''';

         IF  get_per_rowid%ISOPEN THEN
		  NULL;
	  ELSE
		  OPEN get_per_rowid;
	  END IF;

         FETCH get_per_rowid INTO l_per_rowid;
         IF get_per_rowid%NOTFOUND THEN
		  l_per_rowid := NULL;
	  END IF;

	  l_per_rowid := ''''||l_per_rowid||'''';

	       v_retflag := IGS_RU_GEN_001.RULP_VAL_SENNA(
			   p_rule_number => p_rule_number,
		          p_person_id   => p_person_id,
		          p_param_1     => 55,
		          p_param_2     => 'DUMMY',
		          p_param_3     => 55,
		          p_param_4     => 'DUMMY',
		          p_param_5     => p_base_id,
		          p_param_6     => p_param_6,
		          p_param_7     => p_param_7,
		          p_param_8     => p_param_8,
		          p_param_9     => l_per_rowid,
		          p_param_10    => l_adm_rowid,
		          p_param_11    => l_rowid,
		          p_message     => v_message
	         );

      IF UPPER(LTRIM(RTRIM(v_retflag))) = 'TRUE' THEN
       l_retflag := 'TRUE';
      END IF;


    CLOSE get_per_rowid;
    CLOSE get_adm_rowid;
    RETURN l_retflag;
  END Rule_call;

END IGF_AP_RULE_CALL_PKG; -- Package Body IGF_AP_RULE_CALL_PKG

/
