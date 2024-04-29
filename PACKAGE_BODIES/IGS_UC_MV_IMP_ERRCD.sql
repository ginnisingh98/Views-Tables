--------------------------------------------------------
--  DDL for Package Body IGS_UC_MV_IMP_ERRCD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_MV_IMP_ERRCD" AS
/* $Header: IGSUC34B.pls 120.1 2006/02/08 19:55:49 anwest noship $ */

/*===============================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA        |
 |                            All rights reserved.                               |
 +===============================================================================+
 |                                                                               |
 | DESCRIPTION                                                                   |
 |      PL/SQL spec for package: IGS_UC_MV_IMP_ERRCD                             |
 |                                                                               |
 | NOTES                                                                         |
 |     This is a part of Concurrent Requeset Set which updates the main table    |
 |     with the data uploaded into the temporary table from flat file by the  1st|
 |      part of this concurrent request set.                                     |
 |                                                                               |
 | HISTORY                                                                       |
 | Who             When            What                                          |
 | rgangara        05-Nov-2002    Create Version as part of Small systems support|
 |                                Enhancement (UCFD02). Bug 2643048              |
 | ayedubat        09-DEC-2002    added to TO_NUMBER to err_proc_rec.error_code  |
 |                                column as error codes are numeric data.        |
 |                                Also added the update row call if record already|
 |                                found for the bug fix: 2700307                 |
 | pmarada         13-Jun-2003   Removed the igs_uc_refcodetype table references |
 |                               and removed profile references as per the       |
 |                               UCFD203-Multiple cycles, bug 2669208            |
 | anwest          18-Jan-06      Bug# 4950285 R12 Disable OSS Mandate           |
 *==============================================================================*/


  PROCEDURE imp_error_codes  (
                              errbuf       OUT NOCOPY  VARCHAR2,
                              retcode      OUT NOCOPY  NUMBER
                               ) IS
    /*
    ||  Created By : rgangara
    ||  Created On : 05-Nov-2002
    ||  Purpose    : This is main Procedure which will transfer the Error Codes data
    ||               from the temporary table to the main UCAS interface table.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  anwest          18-JAN-2006     Bug# 4950285 R12 Disable OSS Mandate
    ||  (reverse chronological order - newest change first)
    */

    -- Declare all the local variables, cursors

   -- Cursor to pick records from temp table to be processed.
   CURSOR Err_proc_cur IS
   SELECT error_code,
          code_text
   FROM   igs_uc_mv_errcd_int;

   -- Cursor to check for existence of 'EC' in Ref code types table.
   CURSOR refcode_types_cur IS
   SELECT  lookup_code
   FROM   igs_lookup_values
   WHERE  lookup_type = 'IGS_UC_CODE_TYPES'
      AND lookup_code = 'EC';

   -- Cursor to check whether the CODE already exists in ref codes table.
   CURSOR refcodes_cur (p_code igs_uc_ref_codes.code%TYPE) IS
   SELECT rowid,
          code_type,
          code
   FROM   igs_uc_ref_codes
   WHERE  code_type = 'EC'
   AND    code = p_code;

   refcode_types_rec refcode_types_cur%ROWTYPE;
   refcodes_rec refcodes_cur%ROWTYPE;
   l_rowid           VARCHAR2(26) := NULL;
   l_success_cnt   NUMBER := 0;

  BEGIN

    --anwest 18-JAN-2006 Bug# 4950285 R12 Disable OSS Mandate
    IGS_GE_GEN_003.SET_ORG_ID;

    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ');
    retcode := 0;

    -- check for 'EC' lookup code exists in the lookups or not
    OPEN refcode_types_cur;
    FETCH refcode_types_cur INTO  refcode_types_rec;
    IF refcode_types_cur%NOTFOUND THEN
       FND_MESSAGE.SET_NAME('IGS', 'IGS_UC_REFCODETYP_NOT_EXISTS');
       FND_MESSAGE.SET_TOKEN('CODE_TYPE','EC');
       FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());
       RETCODE := 2;
       RETURN;
    END IF;
    CLOSE refcode_types_cur;

    -- Insert Error Code data into Ref Codes table.
    FOR err_proc_rec IN err_proc_cur
    LOOP
      -- check to see whether the code is NULL. If NULL then ignore such records.
      IF err_proc_rec.error_code is NOT NULL THEN

        BEGIN

          -- Check to see whether the current Code already exists. If not found then insert
          OPEN refcodes_cur( TO_NUMBER(err_proc_rec.error_code) );
          FETCH refcodes_cur INTO refcodes_rec;

          IF refcodes_cur%NOTFOUND THEN
            l_rowid := NULL;

            --Call the TBH of the main table to insert a new error code.
            igs_uc_ref_codes_pkg.Insert_Row (
                                    X_ROWID      => l_rowid,
                                    X_CODE_TYPE  => 'EC',
                                    X_CODE       => TO_NUMBER(err_proc_rec.error_code),
                                    X_CODE_TEXT  => err_proc_rec.code_text,
                                    X_IMPORTED   => 'Y',
                                    X_MODE       => 'R' );
            l_success_cnt := l_success_cnt + 1;

          ELSE
            --Call the TBH of the main table to update the existing error code.
            igs_uc_ref_codes_pkg.update_row (
                                    X_ROWID      => refcodes_rec.rowid,
                                    X_CODE_TYPE  => refcodes_rec.code_type,
                                    X_CODE       => refcodes_rec.code,
                                    X_CODE_TEXT  => err_proc_rec.code_text,
                                    X_IMPORTED   => 'Y',
                                    X_MODE       => 'R' );
            l_success_cnt := l_success_cnt + 1;

          END IF;
          CLOSE refcodes_cur;

        EXCEPTION
          WHEN VALUE_ERROR THEN
            FND_MESSAGE.SET_NAME('IGS', 'IGS_UC_NON_NUMERIC_ERR_CD');
            FND_MESSAGE.SET_TOKEN('ERR_CODE',err_proc_rec.error_code);
            FND_FILE.PUT_LINE( FND_FILE.LOG, FND_MESSAGE.GET());
            RETCODE := 2;
            RETURN;
        END ;

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
      FND_MESSAGE.SET_TOKEN('NAME','IGS_UC_MV_IMP_ERRCD.IMP_ERROR_CODES - '||SQLERRM);
      ERRBUF := FND_MESSAGE.GET;
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
  END imp_error_codes;

 END igs_uc_mv_imp_errcd;

/
