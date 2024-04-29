--------------------------------------------------------
--  DDL for Package Body IGS_UC_MV_IMP_INST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_MV_IMP_INST" AS
/* $Header: IGSUC35B.pls 120.1 2006/02/08 19:56:06 anwest noship $*/

/*===============================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA        |
 |                            All rights reserved.                               |
 +===============================================================================+
 |                                                                               |
 | DESCRIPTION                                                                   |
 |      PL/SQL spec for package: IGS_UC_MV_IMP_INST                              |
 |                                                                               |
 | NOTES                                                                         |
 |     This is a part of Concurrent Requeset Set which updates the Insittutions  |
 |     table with the Institutions data uploaded into the temporary table        |
 |      from flat file by the SQL Ldr part of this concurrent request set        |
 |                                                                               |
 | HISTORY                                                                       |
 | Who        When        What                                                   |
 | rgangara  05-Nov-2002  Create Version as part of Small systems support        |
 |                        Enhancement. UCFD02. Enh Bug# 2643048                  |
 | pmarada   13-jun-2003  Obsoleted the datetimestamp column references from the |
 |                        object, removed the profile references as per UCFD203  |
 |                         Multiple cycle build, bug 2669208                     |
 | anwest    18-Jan-06    Bug# 4950285 R12 Disable OSS Mandate                   |
 *==============================================================================*/


  PROCEDURE Import_Inst_codes  (
                                errbuf        OUT NOCOPY  VARCHAR2,
                                retcode       OUT NOCOPY  NUMBER  ,
                                p_system_code  IN  VARCHAR2
                               ) IS
    /*
    ||  Created By : rgangara
    ||  Created On : 05-Nov-2002
    ||  Purpose    : This is main Procedure which will transfer the Institutions data
    ||               from the temporary table to the UCAS Institutions table.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  anwest          18-JAN-2006     Bug# 4950285 R12 Disable OSS Mandate
    ||  (reverse chronological order - newest change first)
    */

    -- Declare all the local variables, cursors

   -- Cursor to pick records from temp table to be processed.
   CURSOR inst_int_cur IS
   SELECT inst,
          inst_code,
          inst_name
   FROM   igs_uc_mv_inst_int;

   -- Cursor to check whether the CODE already exists in Institutions table.
   CURSOR instcodes_cur (p_inst igs_uc_com_inst.inst%TYPE) IS
   SELECT   rowid        ,
            inst         ,
            inst_code    ,
            inst_name    ,
            ucas         ,
            gttr         ,
            swas         ,
            nmas         ,
            imported
   FROM   igs_uc_com_inst
   WHERE  inst = p_inst;


   instcodes_rec instcodes_cur%ROWTYPE;
   l_rowid           VARCHAR2(26) := NULL;
   l_success_cnt     NUMBER := 0;
   l_gttr            VARCHAR2(1);
   l_ucas            VARCHAR2(1);
   l_nmas            VARCHAR2(1);
   l_swas            VARCHAR2(1);

  BEGIN

    --anwest 18-JAN-2006 Bug# 4950285 R12 Disable OSS Mandate
    IGS_GE_GEN_003.SET_ORG_ID;

    FND_FILE.PUT_LINE( FND_FILE.LOG, ' ');
    retcode := 0;

    -- Check If profile Country Code is set to GB. If not, then close form.
    IF NOT igs_uc_utils.is_ucas_hesa_enabled THEN
      fnd_message.set_name('IGS','IGS_UC_HE_NOT_ENABLED');
      fnd_file.put_line( fnd_file.log, fnd_message.get());
      retcode := 2;
      RETURN;
    END IF;

    -- Insert/Update Institutions data into UCAS Institutions table IGS_UC_COM_INST.
    FOR inst_int_rec IN inst_int_cur
    LOOP


      -- check to see whether the code is NULL. If NULL then ignore such records.
      IF inst_int_rec.inst is NOT NULL THEN
         -- Check to see whether the current Code already exists. If not found then insert
         OPEN instcodes_cur(inst_int_rec.inst);
         FETCH instcodes_cur INTO instcodes_rec;
         IF instcodes_cur%NOTFOUND THEN
           l_rowid := NULL;
           -- Initializing flags
           l_gttr := 'N';
           l_ucas := 'N';
           l_nmas := 'N';
           l_swas := 'N';

           IF p_system_code = 'U' THEN
              l_ucas := 'Y';
           ELSIF p_system_code = 'G' THEN
              l_gttr := 'Y';
           ELSIF p_system_code = 'N' THEN
              l_nmas := 'Y';
           ELSIF p_system_code = 'S' THEN
              l_swas := 'Y';
           END IF;

           fnd_message.set_name('IGS', 'IGS_UC_MV_INST_IMP');
           fnd_message.set_token('IMPORT', 'INSERTING ');
           fnd_message.set_token('INST', inst_int_rec.inst);
           fnd_file.put_line( fnd_file.log, fnd_message.get());

           --Call the TBH of the Reference codes table to insert a new Degree Subject.
           igs_uc_com_inst_pkg.Insert_Row (
                                           x_rowid              => l_rowid,
                                           x_inst               => inst_int_rec.inst,
                                           x_inst_code          => inst_int_rec.inst_code,
                                           x_inst_name          => inst_int_rec.inst_name,
                                           x_ucas               => l_ucas,
                                           x_gttr               => l_gttr,
                                           x_swas               => l_swas,
                                           x_nmas               => l_nmas,
                                           x_imported           => 'Y',
                                           x_mode               => 'R'
                                          );

           l_success_cnt := l_success_cnt + 1;

         ELSE
           l_rowid := instcodes_rec.rowid;
           -- Initializing flags with the current/existing values
           l_ucas := instcodes_rec.ucas;
           l_gttr := instcodes_rec.gttr;
           l_nmas := instcodes_rec.nmas;
           l_swas := instcodes_rec.swas;

           -- updating the appropriate system flag as per the input parmaeter
           IF p_system_code = 'U' THEN
              l_ucas := 'Y';
           ELSIF p_system_code = 'G' THEN
              l_gttr := 'Y';
           ELSIF p_system_code = 'N' THEN
              l_nmas := 'Y';
           ELSIF p_system_code = 'S' THEN
              l_swas := 'Y';
           END IF;

           fnd_message.set_name('IGS', 'IGS_UC_MV_INST_IMP');
           fnd_message.set_token('IMPORT', 'UPDATING ');
           fnd_message.set_token('INST', instcodes_rec.inst);
           fnd_file.put_line( fnd_file.log, fnd_message.get());

           --Call the TBH of the Reference codes table to update a new Degree Subject.
           igs_uc_com_inst_pkg.Update_Row (
                                           x_rowid              => l_rowid,
                                           x_inst               => instcodes_rec.inst,
                                           x_inst_code          => inst_int_rec.inst_code,
                                           x_inst_name          => inst_int_rec.inst_name,
                                           x_ucas               => l_ucas,
                                           x_gttr               => l_gttr,
                                           x_swas               => l_swas,
                                           x_nmas               => l_nmas,
                                           x_imported           => 'Y',
                                           x_mode               => 'R'
                                          );

           l_success_cnt := l_success_cnt + 1;

         END IF;

         CLOSE instcodes_cur;
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

  END Import_Inst_codes;
 END igs_uc_mv_imp_inst;

/
