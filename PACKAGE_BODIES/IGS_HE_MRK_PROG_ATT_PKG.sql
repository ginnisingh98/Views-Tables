--------------------------------------------------------
--  DDL for Package Body IGS_HE_MRK_PROG_ATT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_MRK_PROG_ATT_PKG" AS
/* $Header: IGSHE06B.pls 120.1 2006/02/08 19:49:27 anwest noship $ */



PROCEDURE update_data(errbuf OUT NOCOPY varchar2, retcode OUT NOCOPY number,l_extract_run_id igs_he_ex_rn_dat_ln.extract_run_id%type, l_submission_name igs_he_submsn_header.submission_name%type,
l_return_name igs_he_submsn_return.return_name%type ) IS

  /*************************************************************
  Created By      : sowsubra
  Date Created By : 21-JAN-2002
  Purpose : To update the marked program attempts in the IGS_HE_ST_SPA_ALL table  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  anwest          18-JAN-2006     Bug# 4950285 R12 Disable OSS Mandate

  (reverse chronological order - newest change first)
  ***************************************************************/

   CURSOR get_person_course_stud_details IS
   SELECT person_id, course_cd , student_inst_number
     FROM igs_he_ex_rn_dat_ln WHERE
	extract_run_id = l_extract_run_id;
   get_details_rec get_person_course_stud_details%ROWTYPE;

BEGIN

   --anwest 18-JAN-2006 Bug# 4950285 R12 Disable OSS Mandate
   IGS_GE_GEN_003.SET_ORG_ID;

   FOR get_details_rec  IN get_person_course_stud_details
   LOOP
     IF (( get_details_rec.person_id IS NOT NULL ) AND
	( get_details_rec.course_cd IS NOT NULL ) AND
	( get_details_rec.student_inst_number IS NOT NULL )) THEN
   	UPDATE igs_he_st_spa_all
		SET HESA_SUBMISSION_NAME = l_submission_name,
		    HESA_RETURN_NAME =l_return_name,
		    HESA_RETURN_ID = l_extract_run_id
		WHERE PERSON_ID =   get_details_rec.person_id AND
		      COURSE_CD = get_details_rec.course_cd AND
		      STUDENT_INST_NUMBER =get_details_rec.student_inst_number ;

    END IF;
   END LOOP;
 EXCEPTION WHEN OTHERS THEN
  rollback;
  retcode := 2;
  errbuf :=fnd_message.get_string('IGS','IGS_SUB_UPDATE_DATA_ERR');
  IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

END update_data;
END igs_he_mrk_prog_att_pkg;

/
