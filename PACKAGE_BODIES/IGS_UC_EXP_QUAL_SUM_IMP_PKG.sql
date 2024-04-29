--------------------------------------------------------
--  DDL for Package Body IGS_UC_EXP_QUAL_SUM_IMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_EXP_QUAL_SUM_IMP_PKG" AS
/* $Header: IGSUC29B.pls 120.1 2006/02/08 19:54:49 anwest noship $ */


PROCEDURE igs_uc_exp_qual_sum_imp(Errbuf OUT NOCOPY  Varchar2 , Retcode OUT NOCOPY Varchar2) IS
/*************************************************************
  Created By      : vbandaru
  Date Created By : 23-JAN-2002
  Purpose : to insert  or to update the records into igs_uc_exp_qual_sum table

  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
| anwest      18-JAN-2006  Bug# 4950285 R12 Disable OSS Mandate
| jchin       8-Mar-2005   Modified for bug #3944420/4215194 - Removed trunc in date
|                          comparisons
| rgangara    04-ARP-2002  Changes as per CCR UCCR002 - UCAS 2002 Year of
|                          Entry Requirements.  Bug# 2278817
|                          Importing VCE, GCE,SQA, keyskills, pervoeq etc
|
  ***************************************************************/

        --smaddali modified this cursor to add new field ucap.previous for bug 2430178
	CURSOR c1 IS
   SELECT ucap.exam_change_date, ucap.a_levels, ucap.as_levels, ucap.winter,
               ucap.btec, ucap.ilc, ucap.ailc, ucap.ib, ucap.manual, ucap.oeq,
               ucap.roa, ucap.oss_person_id, ucap.GCE,  ucap.VCE,   ucap.SQA,ucap.previous,
               ucap.previousas,  ucap.keyskills, ucap.vocational, ucap.prevoeq
	FROM igs_uc_applicants ucap
	WHERE ucap.oss_person_id IS NOT NULL;

	CURSOR c2(l_oss_person_id igs_uc_applicants.oss_person_id%TYPE) IS
	SELECT uexq.exp_qual_sum_id, uexq.person_id, uexq.seq_updated_date,
               uexq.rowid, uexq.exp_gce, uexq.exp_vce, uexq.winter_a_levels,
               uexq.prev_a_levels, uexq.prev_as_levels, uexq.sqa, uexq.btec,
               uexq.ib, uexq.ilc, uexq.ailc, uexq.ksi, uexq.roa, uexq.manual,
               uexq.oeq, uexq.prev_oeq, uexq.vqi
	FROM igs_uc_exp_qual_sum  uexq
	WHERE uexq.person_id = l_oss_person_id;

	l_row1				c1%ROWTYPE;
	l_row2				c2%ROWTYPE;
   l_rowid           ROWID DEFAULT NULL;
   l_exp_qual_sum_id igs_uc_exp_qual_sum.exp_qual_sum_id%TYPE DEFAULT NULL;

  BEGIN

      --anwest 18-JAN-2006 Bug# 4950285 R12 Disable OSS Mandate
      IGS_GE_GEN_003.SET_ORG_ID;

      OPEN c1;
      LOOP
	FETCH c1 INTO l_row1;
	EXIT WHEN c1%notfound;

	OPEN c2(l_row1.oss_person_id);
  	FETCH c2 INTO  l_row2;

	IF(c2%FOUND) THEN  --(1)

		IF NVL(l_row1.exam_change_date, SYSDATE) >
                                                    l_row2.seq_updated_date THEN --(2)

	            --smaddali passing lrow1.previous instead of lrow2.prev_a_levels to field x_prev_a_levels for bug 2430178
		     igs_uc_exp_qual_sum_pkg.update_row(
					 X_ROWID             =>l_row2.rowid,
					 X_EXP_QUAL_SUM_ID   =>l_row2.exp_qual_sum_id,
					 X_PERSON_ID         =>l_row2.person_id,
					 X_EXP_GCE           =>l_row1.gce,
					 X_EXP_VCE           =>l_row1.vce,
					 X_WINTER_A_LEVELS   =>l_row1.winter,
					 X_PREV_A_LEVELS     =>l_row1.previous,
					 X_PREV_AS_LEVELS    =>l_row1.previousas,
					 X_SQA               =>l_row1.sqa,
					 X_BTEC              =>l_row1.btec,
					 X_IB                =>l_row1.ib,
					 X_ILC               =>l_row1.ilc,
					 X_AILC              =>l_row1.ailc,
					 X_KSI               =>l_row1.keyskills,
					 X_ROA               =>l_row1.roa,
					 X_MANUAL            =>l_row1.manual,
					 X_OEQ               =>l_row1.oeq,
					 X_PREV_OEQ          =>l_row1.prevoeq,
					 X_VQI               =>l_row1.vocational,
					 X_SEQ_UPDATED_DATE  => NVL(l_row1.exam_change_date, SYSDATE),
					 X_MODE              =>'R'
					);
               END IF; -- end of (2)

  	       CLOSE c2;

          ELSIF(c2%NOTFOUND) THEN
	--smaddali passing lrow1.previous instead of NULL to field x_prev_a_levels for bug 2430178
	        igs_uc_exp_qual_sum_pkg.insert_row(
				 X_ROWID             =>l_rowid,
				 X_EXP_QUAL_SUM_ID   =>l_exp_qual_sum_id,
				 X_PERSON_ID         =>l_row1.oss_person_id,
				 X_EXP_GCE           =>l_row1.GCE,
				 X_EXP_VCE           =>l_row1.VCE,
				 X_WINTER_A_LEVELS   =>l_row1.winter,
				 X_PREV_A_LEVELS     =>l_row1.previous,
				 X_PREV_AS_LEVELS    =>l_row1.previousas,
				 X_SQA               =>l_row1.sqa,
				 X_BTEC              =>l_row1.btec,
				 X_IB                =>l_row1.ib,
				 X_ILC               =>l_row1.ilc,
				 X_AILC              =>l_row1.ailc,
				 X_KSI               =>l_row1.keyskills,
				 X_ROA               =>l_row1.roa,
				 X_MANUAL            =>l_row1.manual,
				 X_OEQ               =>l_row1.oeq,
				 X_PREV_OEQ          =>l_row1.prevoeq,
				 X_VQI               =>l_row1.vocational,
				 X_SEQ_UPDATED_DATE  => NVL(l_row1.exam_change_date,SYSDATE),
				 X_MODE              =>'R'
					 );

	  END IF; --end of(1)

          IF C2%ISOPEN THEN
		  CLOSE c2;
	  END IF;

	  Commit;
      END LOOP;

      CLOSE c1;

  EXCEPTION
		WHEN OTHERS THEN
   		Retcode := 2 ;
   	 	Rollback;
   		fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
   		fnd_message.set_token('NAME','IGS_UC_EXP_QUAL_SUM_IMP_PKG.IGS_UC_EXP_QUAL_SUM_IMP');
   		fnd_message.retrieve (Errbuf);
   	 	IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
  END igs_uc_exp_qual_sum_imp;

END igs_uc_exp_qual_sum_imp_pkg;

/
