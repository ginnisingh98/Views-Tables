--------------------------------------------------------
--  DDL for Package Body IGS_UC_MV_IMP_DEGSUBJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_MV_IMP_DEGSUBJ" AS
/* $Header: IGSUC36B.pls 120.1 2006/02/08 19:56:25 anwest noship $*/

/*===============================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA        |
 |                            All rights reserved.                               |
 +===============================================================================+
 |                                                                               |
 | DESCRIPTION                                                                   |
 |      PL/SQL spec for package: IGS_UC_MV_IMP_DEGSUBJ                           |
 |                                                                               |
 | NOTES                                                                         |
 |     This is a part of Concurrent Requeset Set which updates the main table    |
 |     with the Degree Subjects data for GTTR uploaded into the temporary table  |
 |      from flat file by the  1st (SQL Ldr part of this concurrent request set. |
 |                                                                               |
 | HISTORY                                                                       |
 | Who             When            What                                          |
 | rgangara        05-Nov-2002    Create Version as part of Small systems support|
 |                                Enhancement (UCFD02). Bug 2643048              |
 | pmarada         13-Jun-2003   Removed the igs_uc_refcodetype table references |
 |                               and removed the hercules profiles references as |
 |                               per the UCFD203-Multiple cycles, bug 2669208    |
 | anwest          18-Jan-06      Bug# 4950285 R12 Disable OSS Mandate           |
 *==============================================================================*/


  PROCEDURE Imp_Degsubject_codes  (
                                    errbuf       OUT NOCOPY  VARCHAR2,
                                    retcode      OUT NOCOPY  NUMBER
                                     ) IS
    /*
    ||  Created By : rgangara
    ||  Created On : 05-Nov-2002
    ||  Purpose    : This is main Procedure which will transfer the Degree Subjects (GTTR) data
    ||               from the temporary table to the UCAS Reference codes table.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  anwest          18-JAN-2006     Bug# 4950285 R12 Disable OSS Mandate
    ||  (reverse chronological order - newest change first)
    */

    -- Declare all the local variables, cursors

   -- Cursor to pick records from temp table to be processed.
   CURSOR Degsubj_proc_cur IS
   SELECT deg_subj_code,
          code_text
   FROM   igs_uc_mv_degsb_int;

   -- Cursor to check for existence of 'DS' in Ref code types table.
   CURSOR refcode_types_cur IS
   SELECT lookup_code
   FROM   igs_lookup_values
   WHERE  lookup_type = 'IGS_UC_CODE_TYPES'
     AND  lookup_code = 'DS';

   -- Cursor to check whether the CODE already exists in ref codes table.
   CURSOR refcodes_cur (p_code igs_uc_ref_codes.code%TYPE) IS
   SELECT rowid, code
   FROM   igs_uc_ref_codes
   WHERE  code_type = 'DS'
   AND    code = p_code;

   refcode_types_rec refcode_types_cur%ROWTYPE;
   refcodes_rec refcodes_cur%ROWTYPE;
   l_rowid           VARCHAR2(26) := NULL;
   l_success_cnt     NUMBER := 0;

  BEGIN

    --anwest 18-JAN-2006 Bug# 4950285 R12 Disable OSS Mandate
    IGS_GE_GEN_003.SET_ORG_ID;

    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ');
    retcode := 0;

    -- check for 'DS' lookup code type exists in lookups or not.
    OPEN refcode_types_cur;
    FETCH refcode_types_cur INTO  refcode_types_rec;
    IF refcode_types_cur%NOTFOUND THEN
       FND_MESSAGE.SET_NAME('IGS', 'IGS_UC_REFCODETYP_NOT_EXISTS');
       FND_MESSAGE.SET_TOKEN('CODE_TYPE','DS');
       FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());
       RETCODE := 2;
       RETURN;
    END IF;
    CLOSE refcode_types_cur;

    -- Insert Degree Subjects data into Ref Codes table.
    FOR degsubj_proc_rec IN degsubj_proc_cur
    LOOP
      -- check to see whether the code is NULL. If NULL then ignore such records.
      IF degsubj_proc_rec.deg_subj_code is NOT NULL THEN

         -- Check to see whether the current Code already exists. If not found then insert
         OPEN refcodes_cur(degsubj_proc_rec.deg_subj_code);
         FETCH refcodes_cur INTO refcodes_rec;
         IF refcodes_cur%NOTFOUND THEN
           l_rowid := NULL;

           --Call the TBH of the Reference codes table to insert a new Degree Subject.
           igs_uc_ref_codes_pkg.Insert_Row (
                                    X_ROWID      => l_rowid,
                                    X_CODE_TYPE  => 'DS',
                                    X_CODE       => degsubj_proc_rec.deg_subj_code,
                                    X_CODE_TEXT  => degsubj_proc_rec.code_text,
                                    X_IMPORTED   => 'Y',
                                    X_MODE       => 'R'
                                    );
           l_success_cnt := l_success_cnt + 1;

         ELSE
           l_rowid := refcodes_rec.rowid;
           --Call the TBH of the Reference codes table to update a new Degree Subject.
           igs_uc_ref_codes_pkg.Update_Row (
                                    X_ROWID      => l_rowid,
                                    X_CODE_TYPE  => 'DS',
                                    X_CODE       => degsubj_proc_rec.deg_subj_code,
                                    X_CODE_TEXT  => degsubj_proc_rec.code_text,
                                    X_IMPORTED   => 'Y',
                                    X_MODE       => 'R'
                                    );
           l_success_cnt := l_success_cnt + 1;

         END IF;

         CLOSE refcodes_cur;
      END IF;

    END LOOP;

    -- Print Number of records successfully transferred
    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ');
    FND_MESSAGE.SET_NAME('IGS', 'IGS_UC_MV_LOAD_SUCCESS');
    FND_MESSAGE.SET_TOKEN('CNT', l_success_cnt);
    FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());

    -- commit the data;
    COMMIT;
    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ');

  EXCEPTION
    WHEN app_exception.record_lock_exception THEN
      ROLLBACK;
      retcode := 2;
      errbuf := fnd_message.get_string('IGF','IGF_GE_LOCK_ERROR');
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;

    WHEN OTHERS THEN
      ROLLBACK;
      RETCODE := 2;
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
      FND_MESSAGE.SET_TOKEN('NAME','IGS_UC_MV_IMP_DEGSUBJ.IMP_DEGSUBJECT_CODES - '||SQLERRM);
      ERRBUF := FND_MESSAGE.GET;
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
  END Imp_Degsubject_codes;
 END igs_uc_mv_imp_degsubj;

/
