--------------------------------------------------------
--  DDL for Package Body IGS_AD_IMP_ACIDX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_IMP_ACIDX_PKG" AS
/* $Header: IGSADA9B.pls 120.0 2005/06/01 14:16:23 appldev noship $ */

PROCEDURE prgp_imp_acad_indx(
  errbuf OUT NOCOPY VARCHAR2,
  retcode OUT NOCOPY NUMBER,
  p_acadindex_batch_id IN NUMBER,
  p_org_id IN NUMBER )
 AS
  /**********************************************************
  Created By : jdeekoll

  Date Created By : 06-AUG-2001

  Purpose : For Import Process Academic Index

  Know limitations, enhancements or remarks

  Change History

  Who		When 		What
  samaresh      02-DEC-2001     Bug # 2097333 : Impact of addition of the waitlist_status field to igs_ad_ps_appl_inst_all
  (reverse chronological order - newest change first)
  cdcruz         18-feb-2002    bug 2217104 Admit to future term Enhancement,updated tbh call for
                                new columns being added to IGS_AD_PS_APPL_INST
 nshee     29-Aug-2002  Bug 2395510 added 6 columns as part of deferments build
 ***************************************************************/

-- All records selected from Interface Tables

        CURSOR  c_acai_int (p_acadindex_batch_id NUMBER) IS
	SELECT	aii.acadindex_id,
                aii.person_id,
                aii.admission_appl_number,
                aii.nominated_course_cd,
                aii.sequence_number,
                aii.admission_index,
                aii.calculation_date
        FROM	igs_ad_acad_idx_int_all aii,
	        igs_ad_acidx_hdr aih
        WHERE	aii.record_status ='2'
                AND aih.acadindex_batch_id = p_acadindex_batch_id
                AND aii.acadindex_batch_id = aih.acadindex_batch_id;


CURSOR c_purge (p_acadindex_batch_id  NUMBER) IS
   SELECT 'x'
   FROM igs_ad_acad_idx_int_all
   WHERE acadindex_batch_id = p_acadindex_batch_id;

--  l_appl_inst_rec c_acai%ROWTYPE;
  e_resource_busy_exception EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_resource_busy_exception, -54);
--  l_doc_status c_doc_status%ROWTYPE;
  l_purge c_purge%ROWTYPE;

  l_gather_status       VARCHAR2(5);
  l_industry     VARCHAR2(5);
  l_schema       VARCHAR2(30);
  l_gather_return       BOOLEAN;
  l_owner        VARCHAR2(30);



  l_api_version                NUMBER ;
  l_init_msg_list              VARCHAR2(1);
  l_commit                     VARCHAR2(1);
  l_validation_level           NUMBER;
  l_return_status              VARCHAR2(10);
  l_msg_count		       NUMBER;
  l_msg_data                   VARCHAR2(2000);

-- Local procedure for updating status and error code of interface table

PROCEDURE update_int_table(p_rec_status NUMBER,
                           p_error_code VARCHAR2,
                           p_acadindex_id NUMBER,
                           p_log_text VARCHAR2) AS
BEGIN
     UPDATE igs_ad_acad_idx_int_all
     SET record_status = p_rec_status,
         error_code = p_error_code,
	 error_Text = p_log_text
     WHERE acadindex_id = p_acadindex_id;

  --  FND_MESSAGE.SET_NAME('IGS',p_log_text);
    FND_FILE.PUT_LINE(FND_FILE.LOG,p_log_text||' - '||p_acadindex_id);

END update_int_table;

BEGIN

  l_api_version   := 1.0;
  l_init_msg_list :=  FND_API.G_FALSE;
  l_commit        := FND_API.G_FALSE;
  l_validation_level := FND_API.G_VALID_LEVEL_FULL;


  -- set the multi org id
       igs_ge_gen_003.set_org_id (p_org_id);

  -- Gather statistics for interface table
  -- by rrengara on 20-jan-2003 bug 2711176
--FND_FILE.PUT_LINE(FND_FILE.LOG, '1: Start of procedure');
  BEGIN
    l_gather_return := fnd_installation.get_app_info('IGS', l_gather_status, l_industry, l_schema);

    FND_STATS.GATHER_TABLE_STATS(ownname => l_schema, tabname => 'IGS_AD_ACAD_IDX_INT_ALL', cascade => TRUE);
    FND_STATS.GATHER_TABLE_STATS(ownname => l_schema, tabname => 'IGS_AD_ACIDX_HDR_ALL', cascade => TRUE);
  EXCEPTION WHEN OTHERS THEN
    NULL;
  END;
--FND_FILE.PUT_LINE(FND_FILE.LOG, '2: After gathering statistics');
-- For each record in the Interface Table do the following

  FOR c_acai_inst_rec IN c_acai_int(p_acadindex_batch_id)
  LOOP
-- Fetch the appropriate record from Production Table(Admission Instance)

  BEGIN
--  FND_FILE.PUT_LINE(FND_FILE.LOG, '3: Before calling API');
    igs_admapplication_pub.record_academic_index(
                    p_api_version	=> l_api_version,
		    p_init_msg_list	=> l_init_msg_list,
		    p_commit            => l_commit,
		    p_validation_level	=> l_validation_level,
		    x_return_status     => l_return_status,
		    x_msg_count		=> l_msg_count,
		    x_msg_data          => l_msg_data,
                    p_person_id               => c_acai_inst_rec.person_id,
		    p_admission_appl_number   => c_acai_inst_rec.admission_appl_number,
		    p_nominated_program_cd     => c_acai_inst_rec.nominated_course_cd,
		    p_sequence_number         => c_acai_inst_rec.sequence_number,
		    p_academic_index          => c_acai_inst_rec.admission_index,
		    p_calculation_date        => c_acai_inst_rec.calculation_date
     );
--      FND_FILE.PUT_LINE(FND_FILE.LOG, '4: just after calling API.Return status :='||l_return_status);
    IF l_return_status = FND_API.G_RET_STS_ERROR  THEN
     -- error out the record
--           FND_FILE.PUT_LINE(FND_FILE.LOG, '5: If Return status ='||FND_API.G_RET_STS_ERROR||l_msg_data);
       update_int_table('3','E005',c_acai_inst_rec.acadindex_id,l_msg_data);
    ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
--           FND_FILE.PUT_LINE(FND_FILE.LOG, '6: If Return status ='||FND_API.G_RET_STS_UNEXP_ERROR);
       update_int_table('3','E004',c_acai_inst_rec.acadindex_id,'IGS_GE_UNHANDLED_EXCEPTION');
    ELSE 	       -- Delete the successful record from Interface Table
--      FND_FILE.PUT_LINE(FND_FILE.LOG, '7: If Return status = success then delete the record');
       DELETE igs_ad_acad_idx_int_all
        WHERE acadindex_id=c_acai_inst_rec.acadindex_id;
    END IF;

   EXCEPTION
              WHEN OTHERS THEN
  --             FND_FILE.PUT_LINE(FND_FILE.LOG, '8: When any exception from API block');
               update_int_table('3','E004',c_acai_inst_rec.acadindex_id,'IGS_GE_UNHANDLED_EXCEPTION');
   END;
  END LOOP;

   -- Purge the data from Interface Header table whose child records are successfully deleted
--FND_FILE.PUT_LINE(FND_FILE.LOG, '9: Before purging the parent record');
   OPEN  c_purge(p_acadindex_batch_id);
   FETCH c_purge INTO l_purge;
    IF c_purge%NOTFOUND THEN
     DELETE igs_ad_acidx_hdr_all
     WHERE acadindex_batch_id = p_acadindex_batch_id;
     FND_MESSAGE.SET_NAME('IGS','IGS_AD_ACDX_REC_DELETED');
     FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET||' - '||p_acadindex_batch_id);
    END IF;
--FND_FILE.PUT_LINE(FND_FILE.LOG, '9: After purging the parent record');
   CLOSE c_purge;

   -- End of Procedure
    retcode := 0;

EXCEPTION
    WHEN OTHERS THEN
--      FND_FILE.PUT_LINE(FND_FILE.LOG, '10: When any exception of program');
        retcode:=2;
        ERRBUF := FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION')|| sqlerrm;
--	FND_FILE.PUT_LINE(FND_FILE.LOG, '11: Before Igs_Ge_Msg_Stack.CONC_EXCEPTION_HNDL');
  --      Igs_Ge_Msg_Stack.CONC_EXCEPTION_HNDL;
--	FND_FILE.PUT_LINE(FND_FILE.LOG, '12: After Igs_Ge_Msg_Stack.CONC_EXCEPTION_HNDL');
        ROLLBACK;
 END prgp_imp_acad_indx;
END igs_ad_imp_acidx_pkg;

/
