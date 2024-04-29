--------------------------------------------------------
--  DDL for Package Body IGS_UC_PROC_COM_INST_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_PROC_COM_INST_DATA" AS
/* $Header: IGSUC66B.pls 120.5 2006/09/15 01:38:11 jbaber noship $  */

  g_success_rec_cnt NUMBER;
  g_error_rec_cnt   NUMBER;
  g_error_code      igs_uc_ccontrl_ints.error_code%TYPE;
  g_crnt_institute  igs_uc_defaults.current_inst_code%TYPE;


  PROCEDURE common_data_setup (errbuf  OUT NOCOPY   VARCHAR2,
                               retcode OUT NOCOPY   NUMBER) IS
    /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For general derivations which are required while
                         processing reference data views.
                         views
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     rgangara  31-DEC-03   Added Generate Party Number validation as part of Bug# 3327176
    ******************************************************************/

     -- Get the current institution code set in UCAS Setup for FTUG as all systems have the same.
     CURSOR crnt_inst_cur IS
     SELECT current_inst_code
     FROM   igs_uc_defaults
     WHERE  system_code = 'U';

  BEGIN

     OPEN crnt_inst_cur;
     FETCH crnt_inst_cur INTO g_crnt_institute;
     CLOSE crnt_inst_cur;

     IF g_crnt_institute IS NULL THEN
        fnd_message.set_name('IGS','IGS_UC_CURR_INST_NOT_SET');
        errbuf := fnd_message.get;
        fnd_file.put_line(fnd_file.log, errbuf);
        retcode := 2;
        RETURN;
     END IF;

     -- validate that the Generate party Num profile is set to Y else log error message
     -- Added this validation as part of Bug# 3327176
     IF fnd_profile.value('HZ_GENERATE_PARTY_NUMBER') <> 'Y' THEN
        fnd_message.set_name('IGS','IGS_UC_GEN_PRTY_PROF_NOT_SET');
        errbuf := fnd_message.get;
        fnd_file.put_line(fnd_file.log, errbuf);
        retcode := 2;
        RETURN;
     END IF;

  EXCEPTION
     WHEN OTHERS THEN
         retcode := 2;
         fnd_Message.Set_name('IGS','IGS_GE_UNHANDLED_EXP');
         fnd_message.set_token('NAME','IGS_UC_PROC_COM_INST_DATA.COMMON_DATA_SETUP '||' - '||SQLERRM);
         errbuf := fnd_message.get;
         fnd_file.put_line(fnd_file.LOG, errbuf);
         app_exception.raise_exception;
  END common_data_setup;




  PROCEDURE process_uvinstitution IS
    /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing UVINSTITITUTION view
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     rbezawad  27-Apr-04    Added code to insert a record into igs_uc_inst_control
                            when there is no existing record for bug 3595582.
     jbaber    03-Aug-05    Import ALL fields instead of just some for bug 4532072
     jchakrab  08-Aug-2005  Modified for UC315 - removed validation for insttype
                            and updater, as these columns are no longer used
    ***************************************************************** */

    l_rowcnt      NUMBER ;
    l_rowid     VARCHAR2(26) ;
    g_error_code igs_uc_ccontrl_ints.error_code%TYPE;

     CURSOR int_uinst_cur IS
     SELECT  uinst.rowid,
             uinst.*
     FROM   igs_uc_uinst_ints uinst
     WHERE  record_status = 'N';

     CURSOR chk_inst_ctl IS
     SELECT count(*)
     FROM   igs_uc_inst_control;

     CURSOR old_inst_cur IS
     SELECT inst.rowid row_id,
            inst.*
     FROM   igs_uc_inst_control inst;

     old_inst_ctl_rec old_inst_cur%ROWTYPE;

  BEGIN

  -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;
    l_rowcnt := 0;

    -- log record processing message
    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'UVINSTITUTION ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- record level initialization
    g_error_code := NULL;


    -- check the count of records in the main table.
    OPEN chk_inst_ctl;
    FETCH chk_inst_ctl INTO l_rowcnt;
    CLOSE chk_inst_ctl;


    -- check that the Institution data is setup. If not available then insert a record.
    IF(l_rowcnt = 0) THEN
      BEGIN
         igs_uc_inst_control_pkg.insert_row  -- IGSXI20B.pls
          (
           x_rowid                      =>    l_rowid
          ,x_updater                    =>    '-1'
          ,x_inst_type                  =>    'C'
          ,x_inst_short_name            =>    NULL
          ,x_inst_name                  =>    NULL
          ,x_inst_full_name             =>    NULL
          ,x_switchboard_tel_no         =>    NULL
          ,x_decision_cards             =>    NULL
          ,x_record_cards               =>    NULL
          ,x_labels                     =>    NULL
          ,x_weekly_mov_list_seq        =>    NULL
          ,x_weekly_mov_paging          =>    NULL
          ,x_form_seq                   =>    NULL
          ,x_ebl_required               =>    NULL
          ,x_ebl_media_1or2             =>    NULL
          ,x_ebl_media_3                =>    NULL
          ,x_ebl_1or2_merged            =>    NULL
          ,x_ebl_1or2_board_group       =>    NULL
          ,x_ebl_3_board_group          =>    NULL
          ,x_ebl_nc_app                 =>    NULL
          ,x_ebl_major_key1             =>    NULL
          ,x_ebl_major_key2             =>    NULL
          ,x_ebl_major_key3             =>    NULL
          ,x_ebl_minor_key1             =>    NULL
          ,x_ebl_minor_key2             =>    NULL
          ,x_ebl_minor_key3             =>    NULL
          ,x_ebl_final_key              =>    NULL
          ,x_odl1                       =>    NULL
          ,x_odl1a                      =>    NULL
          ,x_odl2                       =>    NULL
          ,x_odl3                       =>    NULL
          ,x_odl_summer                 =>    NULL
          ,x_odl_route_b                =>    NULL
          ,x_monthly_seq                =>    NULL
          ,x_monthly_paper              =>    NULL
          ,x_monthly_page               =>    NULL
          ,x_monthly_type               =>    NULL
          ,x_june_list_seq              =>    NULL
          ,x_june_labels                =>    NULL
          ,x_june_num_labels            =>    NULL
          ,x_course_analysis            =>    NULL
          ,x_campus_used                =>    NULL
          ,x_d3_doc_required            =>    NULL
          ,x_clearing_accept_copy_form  =>    NULL
          ,x_online_message             =>    NULL
          ,x_ethnic_list_seq            =>    NULL
          ,x_mode                       =>    'R'
          ,x_starx                      =>    NULL
          );
      l_rowcnt := 1;
      EXCEPTION
         WHEN OTHERS THEN
            g_error_code := '9999';
            fnd_file.put_line(fnd_file.log, SQLERRM);
      END;
    END IF;

    -- check that the Institution data is setup correctly. Only 1 record must exist. Please check the setup.
    IF(l_rowcnt > 1) THEN
       g_error_code := '1039';
    END IF;


    IF(l_rowcnt = 1) THEN
      OPEN  old_inst_cur;
      FETCH old_inst_cur INTO old_inst_ctl_rec;
      CLOSE old_inst_cur;

      FOR new_uinst_rec IN int_uinst_cur LOOP

        BEGIN

           IF g_error_code IS NULL THEN

              BEGIN
                 igs_uc_inst_control_pkg.update_row  -- IGSXI20B.pls
                  (
                   x_rowid                      =>    old_inst_ctl_rec.row_id
                  ,x_updater                    =>    new_uinst_rec.updater
                  ,x_inst_type                  =>    new_uinst_rec.insttype
                  ,x_inst_short_name            =>    new_uinst_rec.instshortname
                  ,x_inst_name                  =>    new_uinst_rec.instname
                  ,x_inst_full_name             =>    new_uinst_rec.instfullname
                  ,x_switchboard_tel_no         =>    new_uinst_rec.switchboardtelno
                  ,x_decision_cards             =>    new_uinst_rec.decisioncards
                  ,x_record_cards               =>    new_uinst_rec.recordcards
                  ,x_labels                     =>    new_uinst_rec.labels
                  ,x_weekly_mov_list_seq        =>    new_uinst_rec.weeklymovlistseq
                  ,x_weekly_mov_paging          =>    new_uinst_rec.weeklymovpaging
                  ,x_form_seq                   =>    new_uinst_rec.formseq
                  ,x_ebl_required               =>    new_uinst_rec.eblrequired
                  ,x_ebl_media_1or2             =>    new_uinst_rec.eblmedia1or2
                  ,x_ebl_media_3                =>    new_uinst_rec.eblmedia3
                  ,x_ebl_1or2_merged            =>    new_uinst_rec.ebl1or2merged
                  ,x_ebl_1or2_board_group       =>    new_uinst_rec.ebl1or2boardgroup
                  ,x_ebl_3_board_group          =>    new_uinst_rec.ebl3boardgroup
                  ,x_ebl_nc_app                 =>    new_uinst_rec.eblncapp
                  ,x_ebl_major_key1             =>    new_uinst_rec.eblmajorkey1
                  ,x_ebl_major_key2             =>    new_uinst_rec.eblmajorkey2
                  ,x_ebl_major_key3             =>    new_uinst_rec.eblmajorkey3
                  ,x_ebl_minor_key1             =>    new_uinst_rec.eblminorkey1
                  ,x_ebl_minor_key2             =>    new_uinst_rec.eblminorkey2
                  ,x_ebl_minor_key3             =>    new_uinst_rec.eblminorkey3
                  ,x_ebl_final_key              =>    new_uinst_rec.eblfinalkey
                  ,x_odl1                       =>    new_uinst_rec.odl1
                  ,x_odl1a                      =>    new_uinst_rec.odl1a
                  ,x_odl2                       =>    new_uinst_rec.odl2
                  ,x_odl3                       =>    new_uinst_rec.odl3
                  ,x_odl_summer                 =>    new_uinst_rec.odlsummer
                  ,x_odl_route_b                =>    new_uinst_rec.odlrouteb
                  ,x_monthly_seq                =>    new_uinst_rec.monthlyseq
                  ,x_monthly_paper              =>    new_uinst_rec.monthlypaper
                  ,x_monthly_page               =>    new_uinst_rec.monthlypage
                  ,x_monthly_type               =>    new_uinst_rec.monthlytype
                  ,x_june_list_seq              =>    new_uinst_rec.junelistseq
                  ,x_june_labels                =>    new_uinst_rec.junelabels
                  ,x_june_num_labels            =>    new_uinst_rec.junenumlabels
                  ,x_course_analysis            =>    new_uinst_rec.courseanalysis
                  ,x_campus_used                =>    new_uinst_rec.campusused
                  ,x_d3_doc_required            =>    new_uinst_rec.d3docsrequired
                  ,x_clearing_accept_copy_form  =>    new_uinst_rec.clearingacceptcopyform
                  ,x_online_message             =>    new_uinst_rec.onlinemessage
                  ,x_ethnic_list_seq            =>    new_uinst_rec.ethniclistseq
                  ,x_mode                       =>    'R'
                  ,x_starx                      =>    new_uinst_rec.starx
                  );              EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '9998';
                    fnd_file.put_line(fnd_file.log, SQLERRM);
              END;

           END IF;  -- error code check


        EXCEPTION
           WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.

               -- Close any Open cursors
               IF chk_inst_ctl%ISOPEN THEN
                  CLOSE chk_inst_ctl;
               END IF;

               IF old_inst_cur%ISOPEN THEN
                  CLOSE old_inst_cur;
               END IF;

              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);
        END;

        -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
        -- while processing the record.
        IF g_error_code IS NOT NULL THEN

           UPDATE igs_uc_uinst_ints
           SET    error_code    = g_error_code
           WHERE  rowid = new_uinst_rec.rowid;

           -- log error message/meaning.
           igs_uc_proc_ucas_data.log_error_msg(g_error_code);
           -- update error count
           g_error_rec_cnt  := g_error_rec_cnt  + 1;

        ELSE

           UPDATE igs_uc_uinst_ints
           SET    record_status = 'D',
                  error_code    = NULL
           WHERE  rowid = new_uinst_rec.rowid;

           g_success_rec_cnt := g_success_rec_cnt + 1;

        END IF;

     END LOOP;

   END IF;  -- rowcount = 1


   COMMIT;
   -- log process complete
   igs_uc_proc_ucas_data.log_proc_complete('UVINSTITUTION', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    WHEN OTHERS THEN
       -- Process should continue with processing of other view data
       ROLLBACK;
       fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
       fnd_message.set_token('VIEW', 'UVINSTITUTION'||' - '||SQLERRM);
       fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_uvinstitution;


/* ============================================================================================================= */
--                             INSTITUTION VIEWS
/* ============================================================================================================= */


  PROCEDURE process_uvofferabbrev   IS
      /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing Updateable Offer Abbreviations data from UCAS
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     jchakrab  08-Aug-2005  Modified for UC315
                            - Added update-facility for offer abbrevs as UvOfferAbbrev view
                              is no longer updateable via odbc-link
                            - Only AbbrevText can be updateable via net-update system
                            - Removed validation for letterformat, as this column is no longer used
    ***************************************************************** */

    -- Get new interface records
    CURSOR int_uvoffabrv_cur IS
    SELECT rowid
          ,abbrevid
          ,updater
          ,abbrevtext
          ,letterformat
          ,summarychar
          ,abbrevuse
    FROM   igs_uc_uofabrv_ints
    WHERE  record_status = 'N';

    -- check whether corresponding record already exists.
    CURSOR old_uvoffabrv_cur (p_abbrev igs_uc_ref_off_abrv.abbrev_code%TYPE) IS
    SELECT rowid,
           abbrev_code,
           uv_timestamp,
           uv_updater,
           abbrev_text,
           letter_format,
           summary_char,
           uncond,
           withdrawal,
           release,
           imported,
           sent_to_ucas,
           deleted,
           tariff
    FROM   igs_uc_ref_off_abrv
    WHERE  abbrev_code = p_abbrev;

    old_uvoffabrv_rec old_uvoffabrv_cur%ROWTYPE;
    l_rec_status  igs_uc_uofabrv_ints.record_status%TYPE;
    l_uncond      igs_uc_ref_off_abrv.uncond%TYPE;
    l_withdrawal  igs_uc_ref_off_abrv.withdrawal%TYPE;
    l_char_abbrev igs_uc_ref_off_abrv.abbrev_code%TYPE;

  BEGIN
    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;
    l_rec_status := NULL;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'UVOFFERABBREV ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Get all the reocords from interface table with status = 'N'
    FOR new_uvoffabrv_rec IN int_uvoffabrv_cur LOOP

      BEGIN

         -- record level initialization
         g_error_code := NULL;
         l_rec_status := 'N';
         old_uvoffabrv_rec := NULL;

         -- log message for the record being processed
         fnd_message.set_name('IGS','IGS_UC_PROC_INTERFACE_REC');
         fnd_message.set_token('KEY', 'Abbreviation Code ');
         fnd_message.set_token('VALUE', TO_CHAR(new_uvoffabrv_rec.abbrevid));
         fnd_file.put_line(fnd_file.log, fnd_message.get);


         -- validate mandatory fields have values.
         -- jchakrab removed validation check for letterformat as its no longer used
         IF new_uvoffabrv_rec.abbrevid IS NULL THEN
            g_error_code := '1037';
         END IF;

         -- Since UVOfferabbreviations data for abbrevid is NUMERIC only and the data in main table
         -- is VARCHAR2 format. Hence conversion needed and that too for 2 digits only.
         l_char_abbrev := LTRIM(TO_CHAR(new_uvoffabrv_rec.abbrevid,'09'),' ');

         -- derive UNCOND based on the value for abbrev usage
         IF new_uvoffabrv_rec.abbrevuse = 'U' THEN
            l_uncond := 'Y';
         ELSE
            l_uncond := 'N';
         END IF;

         -- derive WITHDRAWAL based on the value for abbrev usage
         IF new_uvoffabrv_rec.abbrevuse = 'W' THEN
            l_withdrawal := 'Y';
         ELSE
            l_withdrawal := 'N';
         END IF;


         IF g_error_code IS NULL THEN

            -- check whether corresponding rec already exists
            OPEN  old_uvoffabrv_cur(l_char_abbrev);
            FETCH old_uvoffabrv_cur INTO old_uvoffabrv_rec;
            CLOSE old_uvoffabrv_cur;


            -- If not found then insert
            IF old_uvoffabrv_rec.rowid IS NULL THEN
               BEGIN
                 igs_uc_ref_off_abrv_pkg.insert_row  --IGSXI30B.pls
                  (
                   x_rowid          => old_uvoffabrv_rec.rowid      -- i.e. NULL.
                  ,x_abbrev_code    => l_char_abbrev
                  ,x_uv_updater     => new_uvoffabrv_rec.updater
                  ,x_abbrev_text    => new_uvoffabrv_rec.abbrevtext
                  ,x_letter_format  => new_uvoffabrv_rec.letterformat
                  ,x_summary_char   => NVL(new_uvoffabrv_rec.summarychar, 'N')
                  ,x_uncond         => l_uncond
                  ,x_withdrawal     => l_withdrawal
                  ,x_release        => 'N'
                  ,x_imported       => 'N'
                  ,x_sent_to_ucas   => 'Y'
                  ,x_deleted        => 'N'
                  ,x_tariff         => NULL
                  ,x_mode           => 'R'
                  );

                  l_rec_status := 'D';

               EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '9999';
                    fnd_file.put_line(fnd_file.log, SQLERRM);
               END;

            ELSE  -- update

               BEGIN
                 igs_uc_ref_off_abrv_pkg.update_row  --IGSXI30B.pls
                  (
                   x_rowid          => old_uvoffabrv_rec.rowid
                  ,x_abbrev_code    => old_uvoffabrv_rec.abbrev_code
                  ,x_uv_updater     => old_uvoffabrv_rec.uv_updater
                  ,x_abbrev_text    => new_uvoffabrv_rec.abbrevtext  -- only abbrev_text is updateable
                  ,x_letter_format  => old_uvoffabrv_rec.letter_format
                  ,x_summary_char   => old_uvoffabrv_rec.summary_char
                  ,x_uncond         => old_uvoffabrv_rec.uncond
                  ,x_withdrawal     => old_uvoffabrv_rec.withdrawal
                  ,x_release        => old_uvoffabrv_rec.release
                  ,x_imported       => old_uvoffabrv_rec.imported
                  ,x_sent_to_ucas   => old_uvoffabrv_rec.sent_to_ucas
                  ,x_deleted        => old_uvoffabrv_rec.deleted
                  ,x_tariff         => old_uvoffabrv_rec.tariff
                  ,x_mode           => 'R'
                  );

                  l_rec_status := 'D';

               EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '9999';
                    fnd_file.put_line(fnd_file.log, SQLERRM);
               END;

            END IF;

         END IF;  -- error not null


       EXCEPTION
          WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.

               -- Close any Open cursors
               IF old_uvoffabrv_cur%ISOPEN THEN
                  CLOSE old_uvoffabrv_cur;
               END IF;

              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);
       END;

       -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
       -- while processing the record.
       IF g_error_code IS NOT NULL THEN

          UPDATE igs_uc_uofabrv_ints
          SET    error_code = g_error_code
          WHERE  rowid      = new_uvoffabrv_rec.rowid;

          -- log error message/meaning.
          igs_uc_proc_ucas_data.log_error_msg(g_error_code);

          -- update error count
          g_error_rec_cnt  := g_error_rec_cnt  + 1;

       ELSE
          UPDATE igs_uc_uofabrv_ints
          SET    record_status = l_rec_status,
                 error_code = NULL
          WHERE  rowid      = new_uvoffabrv_rec.rowid;

          g_success_rec_cnt := g_success_rec_cnt + 1;
       END IF;

    END LOOP;

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('UVOFFERABBREV', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    -- Process should continue with processing of other view data
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'UVOFFERABBREV'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);

  END process_uvofferabbrev;



PROCEDURE process_cvinstitution IS
  /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing Institution details from UCAS
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
   ******************************************************************/
    l_rowid     VARCHAR2(26) ;

    -- Get new interface records
    CURSOR int_cvinst_cur IS
    SELECT cvinst.rowid,
           cvinst.*
    FROM   igs_uc_cinst_ints cvinst
    WHERE  record_status = 'N';

    -- check whether corresponding record already exists.
    CURSOR old_inst_cur (p_inst igs_uc_cinst_ints.inst%TYPE) IS
    SELECT cominst.rowid,
           cominst.*
    FROM   igs_uc_com_inst cominst
    WHERE  cominst.inst = p_inst ;

    old_inst_rec old_inst_cur%ROWTYPE;

  BEGIN
    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'CVINSTITUTION ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Get all the reocords from interface table with status = 'N'
    FOR new_cvinst_rec IN int_cvinst_cur LOOP

      BEGIN
         -- record level initialization
         l_rowid := NULL;
         g_error_code := NULL;
         old_inst_rec := NULL;

         -- log record level processing message
         fnd_message.set_name('IGS','IGS_UC_INST_PROC');
         fnd_message.set_token('INST', new_cvinst_rec.inst);
         fnd_file.put_line(fnd_file.log, fnd_message.get);


         -- validate mandatory fields have values.
         IF new_cvinst_rec.inst IS NULL THEN
            g_error_code := '1037';
         END IF;


         IF g_error_code IS NULL THEN

            -- check whether corresponding rec already exists
            OPEN  old_inst_cur(new_cvinst_rec.inst);
            FETCH old_inst_cur INTO old_inst_rec;
            CLOSE old_inst_cur;


            -- If not found then insert
            IF old_inst_rec.rowid IS NULL THEN

               BEGIN
                 -- insert a new record in the main table
                 igs_uc_com_inst_pkg.insert_row -- IGSXI09B.pls
                 (
                 x_rowid               => old_inst_rec.rowid
                ,x_inst                => new_cvinst_rec.inst
                ,x_inst_code           => new_cvinst_rec.instcode
                ,x_inst_name           => new_cvinst_rec.instname
                ,x_ucas                => 'Y'          -- For FTUG System
                ,x_gttr                => NVL(new_cvinst_rec.gttr, 'N')
                ,x_swas                => NVL(new_cvinst_rec.swas, 'N')
                ,x_nmas                => NVL(new_cvinst_rec.nmas, 'N')
                ,x_imported            => 'Y'
                ,x_mode                => 'R'
                 );

               EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '9999';
                    fnd_file.put_line(fnd_file.log, SQLERRM);
               END;

            ELSE  -- update

               BEGIN
                 -- update a new record in the main table
                 igs_uc_com_inst_pkg.update_row -- IGSXI09B.pls
                 (
                 x_rowid               => old_inst_rec.rowid
                ,x_inst                => old_inst_rec.inst
                ,x_inst_code           => new_cvinst_rec.instcode
                ,x_inst_name           => new_cvinst_rec.instname
                ,x_ucas                => 'Y'          -- For FTUG System
                ,x_gttr                => NVL(old_inst_rec.gttr, 'N')
                ,x_swas                => NVL(old_inst_rec.swas, 'N')
                ,x_nmas                => NVL(old_inst_rec.nmas, 'N')
                ,x_imported            => 'Y'
                ,x_mode                => 'R'
                 );

               EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '9998';
                    fnd_file.put_line(fnd_file.log, SQLERRM);
               END;

            END IF;  -- insert/update

         END IF;  -- error not null

      EXCEPTION
        WHEN OTHERS THEN
             -- catch any unhandled/unexpected errors while processing a record.
             -- This would enable processing to continue with subsequent records.

            -- Close any Open cursors
            IF old_inst_cur%ISOPEN THEN
               CLOSE old_inst_cur;
            END IF;

            g_error_code := '1055';
            fnd_file.put_line(fnd_file.log, SQLERRM);
      END;


      -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
      -- while processing the record.
      IF g_error_code IS NOT NULL THEN

         UPDATE igs_uc_cinst_ints
         SET    error_code = g_error_code
         WHERE  rowid      = new_cvinst_rec.rowid;

         -- log error message/meaning.
         igs_uc_proc_ucas_data.log_error_msg(g_error_code);

         -- update error count
         g_error_rec_cnt  := g_error_rec_cnt  + 1;

      ELSE

         UPDATE igs_uc_cinst_ints
         SET    record_status = 'D',
                error_code = NULL
         WHERE  rowid      = new_cvinst_rec.rowid;

         g_success_rec_cnt := g_success_rec_cnt + 1;
      END IF;

    END LOOP;

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('CVINSTITUTION', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    -- Process should continue with processing of other view data
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'CVINSTITUTION'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_cvinstitution ;



  PROCEDURE process_cveblsubject  IS
  /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing Exam board subject details from UCAS
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     dsridhar  06-JUL-2003  Bug No:3083850. Validation added to check the existance
                            of parent records in igs_uc_ref_awrdbdy.
   ******************************************************************/
    l_rowid     VARCHAR2(26) ;

    -- Get new interface records
    CURSOR int_cveblsubj_cur IS
    SELECT cves.rowid,
           cves.*
    FROM   igs_uc_ceblsbj_ints cves
    WHERE  cves.record_status = 'N';

    -- check whether corresponding record already exists.
    CURSOR old_eblsubj_cur (p_sub_id igs_uc_ceblsbj_ints.subjectid%TYPE) IS
    SELECT ces.rowid,
           ces.*
    FROM   igs_uc_com_ebl_subj ces
    WHERE  ces.subject_id = p_sub_id ;

    -- check for existance of a record in igs_uc_ref_awrdbdy
    CURSOR chk_awd_body (p_year igs_uc_ref_awrdbdy.year%TYPE,
                         p_sitting igs_uc_ref_awrdbdy.sitting%TYPE,
                         p_awd_body  igs_uc_ref_awrdbdy.awarding_body%TYPE) IS
    SELECT 'X'
    FROM   igs_uc_ref_awrdbdy
    WHERE  year = p_year AND
           sitting = p_sitting AND
           awarding_body = p_awd_body;

    old_eblsubj_rec old_eblsubj_cur%ROWTYPE;
    l_awd_body_flag VARCHAR2(1);

  BEGIN
    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'CVEBLSUBJECT ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Get all the reocords from interface table with status = 'N'
    FOR new_eblsubj_rec IN int_cveblsubj_cur LOOP

      BEGIN
         -- record level initialization
         l_rowid := NULL;
         g_error_code := NULL;
         old_eblsubj_rec := NULL;
         l_awd_body_flag := NULL;

         -- log record level processing message
         fnd_message.set_name('IGS','IGS_UC_SUBJ_PROC');
         fnd_message.set_token('SUBJ', TO_CHAR(new_eblsubj_rec.subjectid));
         fnd_file.put_line(fnd_file.log, fnd_message.get);


         -- validate mandatory fields have values.
         IF new_eblsubj_rec.subjectid    IS NULL OR
            new_eblsubj_rec.sitting      IS NULL OR
            new_eblsubj_rec.awardingbody IS NULL OR
            new_eblsubj_rec.examlevel    IS NULL OR
            new_eblsubj_rec.year         IS NULL THEN

               g_error_code := '1037';
         END IF;

         -- validate for a record in igs_uc_ref_awrdbdy
         IF g_error_code IS NULL THEN

            OPEN chk_awd_body (new_eblsubj_rec.year, new_eblsubj_rec.sitting, new_eblsubj_rec.awardingbody);
            FETCH chk_awd_body INTO l_awd_body_flag;

            IF chk_awd_body%NOTFOUND THEN
               g_error_code := '1060';
            END IF;

            CLOSE chk_awd_body;
         END IF;

         IF g_error_code IS NULL THEN

            -- check whether corresponding rec already exists
            OPEN  old_eblsubj_cur(new_eblsubj_rec.subjectid);
            FETCH old_eblsubj_cur INTO old_eblsubj_rec;
            CLOSE old_eblsubj_cur;


            -- If not found then insert
            IF old_eblsubj_rec.rowid IS NULL THEN

               BEGIN
                  -- insert a new record in the main table
                  igs_uc_com_ebl_subj_pkg.insert_row  -- IGSXI08B.pls
                  (
                     x_rowid             => old_eblsubj_rec.rowid
                    ,x_subject_id        => new_eblsubj_rec.subjectid
                    ,x_year              => new_eblsubj_rec.year
                    ,x_sitting           => new_eblsubj_rec.sitting
                    ,x_awarding_body     => new_eblsubj_rec.awardingbody
                    ,x_external_ref      => new_eblsubj_rec.externalref
                    ,x_exam_level        => new_eblsubj_rec.examlevel
                    ,x_title             => new_eblsubj_rec.title
                    ,x_subject_code      => NVL(new_eblsubj_rec.subjcode ,'ZZZZZZ')
                    ,x_imported          => 'Y'
                    ,x_mode              => 'R'
                    );

               EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '9999';
                    fnd_file.put_line(fnd_file.log, SQLERRM);
               END;

            ELSE  -- update

               BEGIN
                  -- update a new record in the main table
                  igs_uc_com_ebl_subj_pkg.update_row   -- IGSXI08B.pls
                    (
                      x_rowid             => old_eblsubj_rec.rowid
                     ,x_subject_id        => old_eblsubj_rec.subject_id
                     ,x_year              => new_eblsubj_rec.year
                     ,x_sitting           => new_eblsubj_rec.sitting
                     ,x_awarding_body     => new_eblsubj_rec.awardingbody
                     ,x_external_ref      => new_eblsubj_rec.externalref
                     ,x_exam_level        => new_eblsubj_rec.examlevel
                     ,x_title             => new_eblsubj_rec.title
                     ,x_subject_code      => NVL(new_eblsubj_rec.subjcode ,'ZZZZZZ')
                     ,x_imported          => 'Y'
                     ,x_mode              => 'R'
                    );

               EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '9998';
                    fnd_file.put_line(fnd_file.log, SQLERRM);
               END;

            END IF;  -- insert/update

         END IF;  -- error not null

       EXCEPTION
           WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.

              -- Close any Open cursors
              IF old_eblsubj_cur%ISOPEN THEN
                 CLOSE old_eblsubj_cur;
              END IF;

              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);
       END;

       -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
       -- while processing the record.
       IF g_error_code IS NOT NULL THEN

          UPDATE igs_uc_ceblsbj_ints
          SET    error_code = g_error_code
          WHERE  rowid      = new_eblsubj_rec.rowid;

          -- log error message/meaning.
          igs_uc_proc_ucas_data.log_error_msg(g_error_code);

          -- update error count
          g_error_rec_cnt  := g_error_rec_cnt  + 1;

       ELSE

          UPDATE igs_uc_ceblsbj_ints
          SET    record_status = 'D',
                 error_code = NULL
          WHERE  rowid      = new_eblsubj_rec.rowid;

          g_success_rec_cnt := g_success_rec_cnt + 1;
       END IF;

    END LOOP;

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('CVEBLSUBJECT', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    -- Process should continue with processing of other view data
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'CVEBLSUBJECT'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_cveblsubject ;



  PROCEDURE process_cvschool  IS
  /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing School details from UCAS
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
   ******************************************************************/
    l_schsite_rowid  VARCHAR2(26) ;

    -- Get new interface records
    CURSOR int_cvschool_cur IS
    SELECT cvs.rowid,
           cvs.*
    FROM   igs_uc_cvsch_ints cvs
    WHERE  cvs.record_status = 'N';

    -- check whether corresponding record already exists.
    CURSOR old_school_cur (p_school_id igs_uc_cvsch_ints.school%TYPE) IS
    SELECT csh.rowid,
           csh.*
    FROM   igs_uc_com_sch csh
    WHERE  csh.school = p_school_id ;


    -- check for school type in Lookups
    CURSOR chk_sch_type (p_sch_type igs_uc_cvsch_ints.schooltype%TYPE) IS
    SELECT 'X'
    FROM   igs_uc_ref_codes
    WHERE  code_type = 'ST'
    AND    code = p_sch_type;

    -- school site details
    CURSOR old_schsite_cur (p_sch_id igs_uc_com_schsites.school%TYPE, p_site_cd igs_uc_com_schsites.sitecode%TYPE ) IS
    SELECT a.ROWID
    FROM   igs_uc_com_schsites a
    WHERE  school = p_sch_id
    AND    sitecode = p_site_cd;


    old_school_rec old_school_cur%ROWTYPE;
    l_sch_type_flag VARCHAR2(1);

  BEGIN
    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'CVSCHOOL ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);


    -- Get all the reocords from interface table with status = 'N'
    FOR new_school_rec IN int_cvschool_cur LOOP

      BEGIN

         -- record level initialization
         g_error_code := NULL;
         old_school_rec := NULL;


         -- log record level processing message
         fnd_message.set_name('IGS','IGS_UC_SCH_PROC');
         fnd_message.set_token('SCH', TO_CHAR(new_school_rec.school));
         fnd_file.put_line(fnd_file.log, fnd_message.get);


         -- validate mandatory fields have values.
         IF new_school_rec.school  IS NULL OR new_school_rec.estabgrp IS NULL THEN
               g_error_code := '1037';
         END IF;

         -- validate school type value
         IF g_error_code IS NULL THEN

            OPEN chk_sch_type (NVL(new_school_rec.schooltype, 'A'));
            FETCH chk_sch_type INTO l_sch_type_flag;

            IF chk_sch_type%NOTFOUND THEN
               g_error_code := '1003';
            END IF;

            CLOSE chk_sch_type;
         END IF;


         -- main processing begins
         IF g_error_code IS NULL THEN

            -- check whether corresponding rec already exists
            OPEN  old_school_cur(new_school_rec.school);
            FETCH old_school_cur INTO old_school_rec;
            CLOSE old_school_cur;


            -- If not found then insert
            IF old_school_rec.rowid IS NULL THEN

               BEGIN
                  -- insert a new record in the main table
                  igs_uc_com_sch_pkg.insert_row  -- IGSXI10B.pls
                  (
                     x_rowid              => old_school_rec.rowid
                    ,x_school             => new_school_rec.school
                    ,x_school_name        => new_school_rec.schoolname
                    ,x_name_change_date   => NULL
                    ,x_former_name        => new_school_rec.formername
                    ,x_ncn                => new_school_rec.ncn
                    ,x_edexcel_ncn        => new_school_rec.edexcelncn
                    ,x_dfee_code          => new_school_rec.dfeecode
                    ,x_country            => new_school_rec.country
                    ,x_lea                => new_school_rec.lea
                    ,x_ucas_status        => new_school_rec.ucasstatus
                    ,x_estab_group        => new_school_rec.estabgrp
                    ,x_school_type        => NVL(new_school_rec.schooltype,'A')
                    ,x_stats_date         => NVL(new_school_rec.statsdate, TRUNC(SYSDATE))
                    ,x_number_on_roll     => NVL(new_school_rec.noroll ,0)
                    ,x_number_in_5_form   => NVL(new_school_rec.no5th ,0)
                    ,x_number_in_6_form   => NVL(new_school_rec.no6th ,0)
                    ,x_number_to_he       => NVL(new_school_rec.nohe ,0)
                    ,x_imported           => 'Y'
                    ,x_mode               => 'R'
                  );

               EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '9999';
                    fnd_file.put_line(fnd_file.log, SQLERRM);
               END;

            ELSE  -- update

               BEGIN
                  -- update a new record in the main table
                  igs_uc_com_sch_pkg.update_row  -- IGSXI10B.pls
                    (
                     x_rowid              => old_school_rec.rowid
                    ,x_school             => old_school_rec.school
                    ,x_school_name        => new_school_rec.schoolname
                    ,x_name_change_date   => NULL
                    ,x_former_name        => new_school_rec.formername
                    ,x_ncn                => new_school_rec.ncn
                    ,x_edexcel_ncn        => new_school_rec.edexcelncn
                    ,x_dfee_code          => new_school_rec.dfeecode
                    ,x_country            => new_school_rec.country
                    ,x_lea                => new_school_rec.lea
                    ,x_ucas_status        => new_school_rec.ucasstatus
                    ,x_estab_group        => new_school_rec.estabgrp
                    ,x_school_type        => NVL(new_school_rec.schooltype,'A')
                    ,x_stats_date         => NVL(new_school_rec.statsdate,TRUNC(SYSDATE))
                    ,x_number_on_roll     => NVL(new_school_rec.noroll ,0)
                    ,x_number_in_5_form   => NVL(new_school_rec.no5th ,0)
                    ,x_number_in_6_form   => NVL(new_school_rec.no6th ,0)
                    ,x_number_to_he       => NVL(new_school_rec.nohe ,0)
                    ,x_imported           => 'Y'
                    ,x_mode               => 'R'
                    );

               EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '9998';
                    fnd_file.put_line(fnd_file.log, SQLERRM);
               END;

            END IF;  -- insert/update


             --- SCHOOL SITES processing begins here
            IF g_error_code IS NULL THEN
               --  Process School sites data now
               l_schsite_rowid := NULL;

               OPEN  old_schsite_cur(new_school_rec.school, NVL(new_school_rec.sitecode,'A'));
               FETCH old_schsite_cur INTO l_schsite_rowid;
               CLOSE old_schsite_cur;

               fnd_message.set_name('IGS','IGS_UC_SCH_SITE_PROC');
               fnd_message.set_token('SCH', TO_CHAR(new_school_rec.school));
               fnd_message.set_token('SITE', NVL(new_school_rec.sitecode,'A'));
               fnd_file.put_line(fnd_file.log, fnd_message.get);

               IF l_schsite_rowid IS NULL THEN
                  BEGIN
                    igs_uc_com_schsites_pkg.insert_row -- IGSXI11B.pls
                    (
                      x_rowid           => l_schsite_rowid
                      ,x_school          => new_school_rec.school
                      ,x_sitecode        => NVL(new_school_rec.sitecode ,'A')
                      ,x_address1        => new_school_rec.address1
                      ,x_address2        => new_school_rec.address2
                      ,x_address3        => new_school_rec.address3
                      ,x_address4        => new_school_rec.address4
                      ,x_postcode        => new_school_rec.postcode
                      ,x_mailsort        => new_school_rec.mailsort
                      ,x_town_key        => new_school_rec.townkey
                      ,x_county_key      => new_school_rec.countykey
                      ,x_country_code    => new_school_rec.countrycode
                      ,x_imported        => 'Y'
                      ,x_mode            => 'R'
                     );
                  EXCEPTION
                     WHEN OTHERS THEN
                         g_error_code := '9999';
                         fnd_file.put_line(fnd_file.log, SQLERRM);
                  END;

               ELSE
                  -- update
                  BEGIN
                    igs_uc_com_schsites_pkg.update_row -- IGSXI11B.pls
                    (
                       x_rowid           => l_schsite_rowid
                       ,x_school          => old_school_rec.school
                       ,x_sitecode        => NVL(new_school_rec.sitecode, 'A')
                       ,x_address1        => new_school_rec.address1
                       ,x_address2        => new_school_rec.address2
                       ,x_address3        => new_school_rec.address3
                       ,x_address4        => new_school_rec.address4
                       ,x_postcode        => new_school_rec.postcode
                       ,x_mailsort        => new_school_rec.mailsort
                       ,x_town_key        => new_school_rec.townkey
                       ,x_county_key      => new_school_rec.countykey
                       ,x_country_code    => new_school_rec.countrycode
                       ,x_imported        => 'Y'
                       ,x_mode            => 'R'
                       );
                  EXCEPTION
                      WHEN OTHERS THEN
                          g_error_code := '9998';
                          fnd_file.put_line(fnd_file.log, SQLERRM);
                  END;

               END IF; -- insert/update school sites

            END IF;  -- for school sites processing


         END IF;  -- error not null

       EXCEPTION
           WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.

               -- Close any Open cursors
               IF old_school_cur%ISOPEN THEN
                  CLOSE old_school_cur;
               END IF;


               IF chk_sch_type%ISOPEN THEN
                  CLOSE chk_sch_type;
               END IF;


               IF old_schsite_cur%ISOPEN THEN
                  CLOSE old_schsite_cur;
               END IF;

              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);
       END;

       -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
       -- while processing the record.
       IF g_error_code IS NOT NULL THEN

          UPDATE igs_uc_cvsch_ints
          SET    error_code = g_error_code
          WHERE  rowid      = new_school_rec.rowid;

          -- log error message/meaning.
          igs_uc_proc_ucas_data.log_error_msg(g_error_code);

          -- update error count
          g_error_rec_cnt  := g_error_rec_cnt  + 1;

       ELSE

          UPDATE igs_uc_cvsch_ints
          SET    record_status = 'D',
                 error_code = NULL
          WHERE  rowid      = new_school_rec.rowid;

          g_success_rec_cnt := g_success_rec_cnt + 1;
       END IF;

    END LOOP;

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('CVSCHOOL', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    -- Process should continue with processing of other view data
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'CVSCHOOL'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_cvschool ;


  PROCEDURE process_cvschoolcontact  IS
  /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing School contact details info. from UCAS
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
   ******************************************************************/

    -- Get new interface records
    CURSOR int_cvschcnt_cur IS
    SELECT csci.rowid,
           csci.*
    FROM   igs_uc_cschcnt_ints csci
    WHERE  csci.record_status = 'N';

    -- check whether corresponding record already exists.
    CURSOR old_schsite_cnt_cur (p_school     igs_uc_cschcnt_ints.school%TYPE,
                                p_site_code  igs_uc_cschcnt_ints.sitecode%TYPE,
                                p_contact_cd igs_uc_cschcnt_ints.contactcode%TYPE) IS
    SELECT csscn.rowid,
           csscn.*
    FROM   igs_uc_com_scsicnts csscn
    WHERE  csscn.school       = p_school
    AND    csscn.sitecode     = p_site_code
    AND    csscn.contact_code = p_contact_cd;

    -- validate school
    CURSOR chk_school (p_school igs_uc_cschcnt_ints.school%TYPE) IS
    SELECT 'X'
    FROM   igs_uc_com_sch
    WHERE  school = p_school;

    -- validate school site details
    CURSOR chk_schsite (p_school igs_uc_cschcnt_ints.school%TYPE, p_site_code igs_uc_cschcnt_ints.sitecode%TYPE) IS
    SELECT 'X'
    FROM   igs_uc_com_schsites
    WHERE  school   = p_school
    AND    sitecode = p_site_code;


    old_schsite_cnt_rec old_schsite_cnt_cur%ROWTYPE;
    l_check_flag VARCHAR2(1);

  BEGIN
    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;
    l_check_flag := NULL;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'CVSCHOOLCONTACT ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Get all the reocords from interface table with status = 'N'
    FOR new_schcntct_rec IN int_cvschcnt_cur LOOP

      BEGIN
         -- record level initialization
         g_error_code := NULL;
         old_schsite_cnt_rec := NULL;


         -- log record level processing message
         fnd_message.set_name('IGS','IGS_UC_SCH_SITE_CNTCT_PROC');
         fnd_message.set_token('SCH', TO_CHAR(new_schcntct_rec.school));
         fnd_message.set_token('SITE', new_schcntct_rec.sitecode);
         fnd_message.set_token('CONTACT', TO_CHAR(new_schcntct_rec.contactcode));
         fnd_file.put_line(fnd_file.log, fnd_message.get);


         -- assigning default to sitecode and assigning to same record variable for further processing.
         new_schcntct_rec.sitecode := NVL(new_schcntct_rec.sitecode, 'A') ;

         -- validate mandatory fields have values.
         IF new_schcntct_rec.school  IS NULL OR new_schcntct_rec.contactcode IS NULL THEN
               g_error_code := '1037';
         END IF;

         -- validate school value
         IF g_error_code IS NULL THEN

            l_check_flag := NULL;
            OPEN chk_school (new_schcntct_rec.school);
            FETCH chk_school INTO l_check_flag;
            CLOSE chk_school;

            IF l_check_flag IS NULL THEN
               g_error_code := '1004';
            END IF;

         END IF;

         -- validate school value
         IF g_error_code IS NULL THEN

            l_check_flag := NULL;  -- initialize again as it is being re-used.
            OPEN chk_schsite (new_schcntct_rec.school, new_schcntct_rec.sitecode);
            FETCH chk_schsite INTO l_check_flag;

            IF chk_schsite%NOTFOUND THEN
               g_error_code := '1005';
            END IF;

            CLOSE chk_schsite;
         END IF;


         -- main processing begins
         IF g_error_code IS NULL THEN

            -- check whether corresponding rec already exists
            OPEN  old_schsite_cnt_cur(new_schcntct_rec.school, new_schcntct_rec.sitecode, new_schcntct_rec.contactcode);
            FETCH old_schsite_cnt_cur INTO old_schsite_cnt_rec;
            CLOSE old_schsite_cnt_cur;

            -- If not found then insert
            IF old_schsite_cnt_rec.rowid IS NULL THEN

               BEGIN
                 -- insert a new record in the main table
                 igs_uc_com_scsicnts_pkg.insert_row --IGSXI12B.pls
                 (
                  x_rowid              => old_schsite_cnt_rec.rowid
                 ,x_school             => new_schcntct_rec.school
                 ,x_sitecode           => new_schcntct_rec.sitecode
                 ,x_contact_code       => new_schcntct_rec.contactcode
                 ,x_contact_post       => new_schcntct_rec.contactpost
                 ,x_contact_name       => new_schcntct_rec.contactname
                 ,x_telephone          => new_schcntct_rec.telephone
                 ,x_fax                => new_schcntct_rec.fax
                 ,x_email              => new_schcntct_rec.email
                 ,x_principal          => NVL(new_schcntct_rec.principal,'N')
                 ,x_lists              => NVL(new_schcntct_rec.lists,'N')
                 ,x_orders             => NVL(new_schcntct_rec.orders,'N')
                 ,x_forms              => NVL(new_schcntct_rec.forms,'N')
                 ,x_referee            => NVL(new_schcntct_rec.referee,'N')
                 ,x_careers            => NVL(new_schcntct_rec.careers,'N')
                 ,x_eas_contact        => NVL(new_schcntct_rec.eascontact,'N')
                 ,x_imported           => 'Y'
                 ,x_mode               => 'R'
                 );

               EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '9999';
                    fnd_file.put_line(fnd_file.log, SQLERRM);
               END;

            ELSE  -- update

               BEGIN
                 -- update a new record in the main table
                 igs_uc_com_scsicnts_pkg.update_row  --IGSXI12B.pls
                 (
                  x_rowid              => old_schsite_cnt_rec.rowid
                 ,x_school             => new_schcntct_rec.school
                 ,x_sitecode           => new_schcntct_rec.sitecode
                 ,x_contact_code       => new_schcntct_rec.contactcode
                 ,x_contact_post       => new_schcntct_rec.contactpost
                 ,x_contact_name       => new_schcntct_rec.contactname
                 ,x_telephone          => new_schcntct_rec.telephone
                 ,x_fax                => new_schcntct_rec.fax
                 ,x_email              => new_schcntct_rec.email
                 ,x_principal          => NVL(new_schcntct_rec.principal,'N')
                 ,x_lists              => NVL(new_schcntct_rec.lists,'N')
                 ,x_orders             => NVL(new_schcntct_rec.orders,'N')
                 ,x_forms              => NVL(new_schcntct_rec.forms,'N')
                 ,x_referee            => NVL(new_schcntct_rec.referee,'N')
                 ,x_careers            => NVL(new_schcntct_rec.careers,'N')
                 ,x_eas_contact        => NVL(new_schcntct_rec.eascontact,'N')
                 ,x_imported           => 'Y'
                 ,x_mode               => 'R'
                 );

               EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '9998';
                    fnd_file.put_line(fnd_file.log, SQLERRM);
               END;

            END IF;  -- insert/update

         END IF;  -- main processing

       EXCEPTION
           WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.

            -- Close any Open cursors
            IF old_schsite_cnt_cur%ISOPEN THEN
               CLOSE old_schsite_cnt_cur;
            END IF;


            IF chk_school%ISOPEN THEN
               CLOSE chk_school;
            END IF;


            IF chk_schsite%ISOPEN THEN
               CLOSE chk_schsite;
            END IF;

              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);
       END;

       -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
       -- while processing the record.
       IF g_error_code IS NOT NULL THEN

         UPDATE igs_uc_cschcnt_ints
         SET    error_code = g_error_code
         WHERE  rowid      = new_schcntct_rec.rowid;

         -- log error message/meaning.
         igs_uc_proc_ucas_data.log_error_msg(g_error_code);

         -- update error count
         g_error_rec_cnt  := g_error_rec_cnt  + 1;

       ELSE

         UPDATE igs_uc_cschcnt_ints
         SET    record_status = 'D',
                error_code = NULL
         WHERE  rowid      = new_schcntct_rec.rowid;

         g_success_rec_cnt := g_success_rec_cnt + 1;
       END IF;

    END LOOP;

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('CVSCHOOLCONTACT', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    -- Process should continue with processing of other view data
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'CVSCHOOLCONTACT'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_cvschoolcontact ;



  PROCEDURE process_cvcourse  IS
  /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing Course details info. from UCAS
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     jbaber   11-Jul-06   Current and deferred validity default to R
                          for UCAS 2007 Support
   ******************************************************************/

    -- Get new interface records
    CURSOR int_cvcrse_cur IS
    SELECT csci.rowid,
           csci.*
    FROM   igs_uc_ccrse_ints csci
    WHERE  csci.record_status = 'N';

    -- check whether corresponding record already exists.
    -- Currently since only FTUG is supported over Hercules and no course data for other systems come from UCAS,
    -- the system code has been hardcoded to U for 'FTUG'.
    CURSOR old_crse_cur (p_course igs_uc_ccrse_ints.course%TYPE, p_campus igs_uc_ccrse_ints.campus%TYPE,
                         p_inst igs_uc_ccrse_ints.inst%TYPE,     p_system_code igs_uc_ccrse_ints.system_code%TYPE) IS
    SELECT crdet.rowid,
           crdet.*
    FROM   igs_uc_crse_dets crdet
    WHERE  crdet.ucas_program_code = p_course
    AND    crdet.institute         = p_inst
    AND    crdet.ucas_campus       = p_campus
    AND    crdet.system_code       = p_system_code;

    -- validate inst
    CURSOR chk_institute (p_inst igs_uc_ccrse_ints.inst%TYPE) IS
    SELECT 'X'
    FROM   igs_uc_com_inst
    WHERE  inst = p_inst;

    -- To get the Course records that require updation to set CLEARING_OPTIONS column value to 'Y'
    -- Those records which are present in uvcoursevacoptions)
    CURSOR crse_vacops_cur IS
    SELECT  a.ROWID row_id,
            a.*
    FROM    igs_uc_crse_dets a, igs_uc_ucrsvop_ints b
    WHERE   a.ucas_program_code = b.course
    AND     a.ucas_campus       = b.campus
    AND     a.institute         = g_crnt_institute
    AND     a.system_code       = 'U'
    AND     b.record_status     = 'N';

    old_crse_rec old_crse_cur%ROWTYPE;
    l_check_flag VARCHAR2(1);

  BEGIN
    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'CVCOURSE ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Get all the reocords from interface table with status = 'N'
    FOR new_cvcrse_rec IN int_cvcrse_cur LOOP

      BEGIN
         -- record level initialization
         g_error_code := NULL;
         old_crse_rec := NULL;


         -- log record level processing message
         fnd_message.set_name('IGS','IGS_UC_INST_CRS_CAMP_PROC');
         fnd_message.set_token('INST', new_cvcrse_rec.inst);
         fnd_message.set_token('COURSE', new_cvcrse_rec.course);
         fnd_message.set_token('CAMPUS', new_cvcrse_rec.campus);
         fnd_file.put_line(fnd_file.log, fnd_message.get);


         -- validate mandatory fields have values.
         IF new_cvcrse_rec.course IS NULL OR new_cvcrse_rec.campus IS NULL OR new_cvcrse_rec.inst IS NULL THEN
             g_error_code := '1037';
         END IF;

         -- validate institute value
         IF g_error_code IS NULL THEN

            l_check_flag := NULL;
            OPEN chk_institute (new_cvcrse_rec.inst);
            FETCH chk_institute INTO l_check_flag;

            IF chk_institute%NOTFOUND THEN
               g_error_code := '1006';
            END IF;

            CLOSE chk_institute;
         END IF;


         -- main processing begins
         IF g_error_code IS NULL THEN

            -- check whether corresponding rec already exists
            OPEN  old_crse_cur(new_cvcrse_rec.course, new_cvcrse_rec.campus, new_cvcrse_rec.inst, new_cvcrse_rec.system_code);
            FETCH old_crse_cur INTO old_crse_rec;
            CLOSE old_crse_cur;

            -- If not found then insert
            IF old_crse_rec.rowid IS NULL THEN

               BEGIN
                 -- insert a new record in the main table
                 igs_uc_crse_dets_pkg.insert_row -- IGSXI14B.pls
                 (
                   x_rowid                            => old_crse_rec.rowid
                  ,x_ucas_program_code                => new_cvcrse_rec.course
                  ,x_oss_program_code                 => NULL
                  ,x_oss_program_version              => NULL
                  ,x_institute                        => new_cvcrse_rec.inst
                  ,x_uvcourse_updater                 => '5'
                  ,x_uvcrsevac_updater                => '5'
                  ,x_short_title                      => new_cvcrse_rec.shortname
                  ,x_long_title                       => new_cvcrse_rec.longname
                  ,x_ucas_campus                      => new_cvcrse_rec.campus
                  ,x_oss_location                     => NULL
                  ,x_faculty                          => new_cvcrse_rec.faculty
                  ,x_total_no_of_seats                => NULL
                  ,x_min_entry_points                 => NULL
                  ,x_max_entry_points                 => NULL
                  ,x_current_validity                 => 'R'
                  ,x_deferred_validity                => 'R'
                  ,x_term_1_start                     => NULL
                  ,x_term_1_end                       => NULL
                  ,x_term_2_start                     => NULL
                  ,x_term_2_end                       => NULL
                  ,x_term_3_start                     => NULL
                  ,x_term_3_end                       => NULL
                  ,x_term_4_start                     => NULL
                  ,x_term_4_end                       => NULL
                  ,x_cl_updated                       => NULL
                  ,x_cl_date                          => NULL
                  ,x_vacancy_status                   => NULL
                  ,x_no_of_vacancy                    => NULL
                  ,x_score                            => NULL
                  ,x_rb_full                          => NULL
                  ,x_scot_vac                         => NULL
                  ,x_sent_to_ucas                     => 'Y'
                  ,x_mode                             => 'R'
                  ,x_ucas_system_id                   => NULL -- passed as NULL as System_code is being used for identifying the System
                  ,x_oss_attendance_type              => NULL
                  ,x_oss_attendance_mode              => NULL
                  ,x_joint_admission_ind              => new_cvcrse_rec.jointadmission
                  ,x_open_extra_ind                   => new_cvcrse_rec.openextra
                  ,x_system_code                      => new_cvcrse_rec.system_code
                  ,x_clearing_options                 => 'N'
                  ,x_imported                         => 'Y'
                  );

               EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '9999';
                    fnd_file.put_line(fnd_file.log, SQLERRM);
               END;

            ELSE  -- update

               BEGIN
                 -- update a new record in the main table
                 igs_uc_crse_dets_pkg.update_row -- IGSXI14B.pls
                 (
                   x_rowid                       => old_crse_rec.rowid
                  ,x_ucas_program_code           => old_crse_rec.ucas_program_code
                  ,x_oss_program_code            => old_crse_rec.oss_program_code
                  ,x_oss_program_version         => old_crse_rec.oss_program_version
                  ,x_institute                   => old_crse_rec.institute
                  ,x_uvcourse_updater            => old_crse_rec.uvcourse_updater
                  ,x_uvcrsevac_updater           => old_crse_rec.uvcrsevac_updater
                  ,x_short_title                 => new_cvcrse_rec.shortname
                  ,x_long_title                  => new_cvcrse_rec.longname
                  ,x_ucas_campus                 => old_crse_rec.ucas_campus
                  ,x_oss_location                => old_crse_rec.oss_location
                  ,x_faculty                     => new_cvcrse_rec.faculty
                  ,x_total_no_of_seats           => old_crse_rec.total_no_of_seats
                  ,x_min_entry_points            => old_crse_rec.min_entry_points
                  ,x_max_entry_points            => old_crse_rec.max_entry_points
                  ,x_current_validity            => old_crse_rec.current_validity
                  ,x_deferred_validity           => old_crse_rec.deferred_validity
                  ,x_term_1_start                => old_crse_rec.term_1_start
                  ,x_term_1_end                  => old_crse_rec.term_1_end
                  ,x_term_2_start                => old_crse_rec.term_2_start
                  ,x_term_2_end                  => old_crse_rec.term_2_end
                  ,x_term_3_start                => old_crse_rec.term_3_start
                  ,x_term_3_end                  => old_crse_rec.term_3_end
                  ,x_term_4_start                => old_crse_rec.term_4_start
                  ,x_term_4_end                  => old_crse_rec.term_4_end
                  ,x_cl_updated                  => old_crse_rec.cl_updated
                  ,x_cl_date                     => old_crse_rec.cl_date
                  ,x_vacancy_status              => old_crse_rec.vacancy_status
                  ,x_no_of_vacancy               => old_crse_rec.no_of_vacancy
                  ,x_score                       => old_crse_rec.score
                  ,x_rb_full                     => old_crse_rec.rb_full
                  ,x_scot_vac                    => old_crse_rec.scot_vac
                  ,x_sent_to_ucas                => old_crse_rec.sent_to_ucas
                  ,x_mode                        => 'R'
                  ,x_ucas_system_id              => NULL -- passed as NULL as System_code is being used for identifying the System
                  ,x_oss_attendance_type         => old_crse_rec.oss_attendance_type
                  ,x_oss_attendance_mode         => old_crse_rec.oss_attendance_mode
                  ,x_joint_admission_ind         => new_cvcrse_rec.jointadmission
                  ,x_open_extra_ind              => new_cvcrse_rec.openextra
                  ,x_system_code                 => old_crse_rec.system_code
                  ,x_clearing_options            => old_crse_rec.clearing_options
                  ,x_imported                    => 'Y'
                   );

               EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '9998';
                    fnd_file.put_line(fnd_file.log, SQLERRM);
               END;

            END IF;  -- insert/update

         END IF;  -- main processing

      EXCEPTION
        WHEN OTHERS THEN
             -- catch any unhandled/unexpected errors while processing a record.
             -- This would enable processing to continue with subsequent records.

            -- Close any Open cursors
            IF old_crse_cur%ISOPEN THEN
               CLOSE old_crse_cur;
            END IF;


            IF chk_institute%ISOPEN THEN
               CLOSE chk_institute;
            END IF;


            IF crse_vacops_cur%ISOPEN THEN
               CLOSE crse_vacops_cur;
            END IF;

             g_error_code := '1055';
             fnd_file.put_line(fnd_file.log, SQLERRM);
      END;


      -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
      -- while processing the record.
      IF g_error_code IS NOT NULL THEN

         UPDATE igs_uc_ccrse_ints
         SET    error_code = g_error_code
         WHERE  rowid      = new_cvcrse_rec.rowid;

         -- log error message/meaning.
         igs_uc_proc_ucas_data.log_error_msg(g_error_code);

         -- update error count
         g_error_rec_cnt  := g_error_rec_cnt  + 1;

      ELSE

         UPDATE igs_uc_ccrse_ints
         SET    record_status = 'D',
                error_code = NULL
         WHERE  rowid      = new_cvcrse_rec.rowid;

         g_success_rec_cnt := g_success_rec_cnt + 1;
      END IF;

    END LOOP;


       -- for updating of Course vacancy information
       -- Update Course records to set CLEARING_OPTIONS column value to 'Y' if the corresponding
       -- course vacancies options are available in uvcoursevacoptions table i.e. igs_uc_ucrsvop_ints
       FOR crse_vacops_rec IN crse_vacops_cur
       LOOP

          BEGIN
              igs_uc_crse_dets_pkg.update_row -- IGSXI14B.pls
              (
                x_rowid                       => crse_vacops_rec.row_id
               ,x_ucas_program_code           => crse_vacops_rec.ucas_program_code
               ,x_oss_program_code            => crse_vacops_rec.oss_program_code
               ,x_oss_program_version         => crse_vacops_rec.oss_program_version
               ,x_institute                   => crse_vacops_rec.institute
               ,x_uvcourse_updater            => crse_vacops_rec.uvcourse_updater
               ,x_uvcrsevac_updater           => crse_vacops_rec.uvcrsevac_updater
               ,x_short_title                 => crse_vacops_rec.short_title
               ,x_long_title                  => crse_vacops_rec.long_title
               ,x_ucas_campus                 => crse_vacops_rec.ucas_campus
               ,x_oss_location                => crse_vacops_rec.oss_location
               ,x_faculty                     => crse_vacops_rec.faculty
               ,x_total_no_of_seats           => crse_vacops_rec.total_no_of_seats
               ,x_min_entry_points            => crse_vacops_rec.min_entry_points
               ,x_max_entry_points            => crse_vacops_rec.max_entry_points
               ,x_current_validity            => crse_vacops_rec.current_validity
               ,x_deferred_validity           => crse_vacops_rec.deferred_validity
               ,x_term_1_start                => crse_vacops_rec.term_1_start
               ,x_term_1_end                  => crse_vacops_rec.term_1_end
               ,x_term_2_start                => crse_vacops_rec.term_2_start
               ,x_term_2_end                  => crse_vacops_rec.term_2_end
               ,x_term_3_start                => crse_vacops_rec.term_3_start
               ,x_term_3_end                  => crse_vacops_rec.term_3_end
               ,x_term_4_start                => crse_vacops_rec.term_4_start
               ,x_term_4_end                  => crse_vacops_rec.term_4_end
               ,x_cl_updated                  => crse_vacops_rec.cl_updated
               ,x_cl_date                     => crse_vacops_rec.cl_date
               ,x_vacancy_status              => crse_vacops_rec.vacancy_status
               ,x_no_of_vacancy               => crse_vacops_rec.no_of_vacancy
               ,x_score                       => crse_vacops_rec.score
               ,x_rb_full                     => crse_vacops_rec.rb_full
               ,x_scot_vac                    => crse_vacops_rec.scot_vac
               ,x_sent_to_ucas                => crse_vacops_rec.sent_to_ucas
               ,x_mode                        => 'R'
               ,x_ucas_system_id              => NULL -- passed as NULL as System_code is being used for identifying the System
               ,x_oss_attendance_type         => crse_vacops_rec.oss_attendance_type
               ,x_oss_attendance_mode         => crse_vacops_rec.oss_attendance_mode
               ,x_joint_admission_ind         => crse_vacops_rec.joint_admission_ind
               ,x_open_extra_ind              => crse_vacops_rec.open_extra_ind
               ,x_system_code                 => crse_vacops_rec.system_code
               ,x_clearing_options            => 'Y'
               ,x_imported                    => crse_vacops_rec.imported
                );

        EXCEPTION
           WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.
              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);
        END;

    END LOOP;
    -- end of processing for course vacancy options flag updation.


    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('CVCOURSE', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    -- Process should continue with processing of other view data
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'CVCOURSE'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_cvcourse ;



  PROCEDURE process_uvcourse  IS
  /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing Updateable Course details info. from UCAS
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
   ******************************************************************/

    -- Get new interface records
    CURSOR int_uvcrse_cur IS
    SELECT usci.rowid,
           usci.*
    FROM   igs_uc_ucrse_ints usci
    WHERE  usci.record_status = 'N';

    -- check whether corresponding record already exists.
    -- Currently since only FTUG is supported over Hercules and no course data for other systems come from UCAS,
    -- the system code has been hardcoded to U for 'FTUG'.
    CURSOR old_ucrse_cur (p_course igs_uc_ccrse_ints.course%TYPE, p_campus igs_uc_ccrse_ints.campus%TYPE,
                          p_inst igs_uc_ccrse_ints.inst%TYPE, p_system igs_uc_crse_dets.system_code%TYPE) IS
    SELECT ucrdet.rowid,
           ucrdet.*
    FROM   igs_uc_crse_dets ucrdet
    WHERE  ucrdet.ucas_program_code = p_course
    AND    ucrdet.institute         = p_inst
    AND    ucrdet.ucas_campus       = p_campus
    AND    ucrdet.system_code       = p_system;

    old_ucrse_rec old_ucrse_cur%ROWTYPE;
    l_check_flag VARCHAR2(1);

  BEGIN
    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'UVCOURSE ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Get all the reocords from interface table with status = 'N'
    FOR new_uvcrse_rec IN int_uvcrse_cur LOOP

      BEGIN
         -- record level initialization
         g_error_code := NULL;
         old_ucrse_rec := NULL;


         -- log record level processing - Course and campus
         fnd_message.set_name('IGS','IGS_UC_CRS_CAMP_PROC');
         fnd_message.set_token('COURSE', new_uvcrse_rec.course);
         fnd_message.set_token('CAMPUS', new_uvcrse_rec.campus);
         fnd_file.put_line(fnd_file.log, fnd_message.get);

         -- validate mandatory fields have values.
         IF new_uvcrse_rec.course IS NULL OR new_uvcrse_rec.campus IS NULL THEN
             g_error_code := '1037';
         END IF;


         -- main processing begins
         IF g_error_code IS NULL THEN

            -- check whether corresponding rec already exists
            OPEN  old_ucrse_cur(new_uvcrse_rec.course, new_uvcrse_rec.campus, g_crnt_institute, 'U');
            FETCH old_ucrse_cur INTO old_ucrse_rec;
            CLOSE old_ucrse_cur;

            -- If not found then insert
            IF old_ucrse_rec.rowid IS NULL THEN
               -- report error if corresponding record does not already exist.
               g_error_code := '1033';

            ELSE  -- update

               BEGIN
                 -- update a new record in the main table
                 igs_uc_crse_dets_pkg.update_row -- IGSXI14B.pls
                 (
                   x_rowid                       => old_ucrse_rec.rowid
                  ,x_ucas_program_code           => old_ucrse_rec.ucas_program_code
                  ,x_oss_program_code            => old_ucrse_rec.oss_program_code
                  ,x_oss_program_version         => old_ucrse_rec.oss_program_version
                  ,x_institute                   => old_ucrse_rec.institute
                  ,x_uvcourse_updater            => NVL(new_uvcrse_rec.updater,'5')
                  ,x_uvcrsevac_updater           => old_ucrse_rec.uvcrsevac_updater
                  ,x_short_title                 => new_uvcrse_rec.shorttitle
                  ,x_long_title                  => new_uvcrse_rec.longtitle
                  ,x_ucas_campus                 => old_ucrse_rec.ucas_campus
                  ,x_oss_location                => old_ucrse_rec.oss_location
                  ,x_faculty                     => new_uvcrse_rec.faculty
                  ,x_total_no_of_seats           => old_ucrse_rec.total_no_of_seats
                  ,x_min_entry_points            => old_ucrse_rec.min_entry_points
                  ,x_max_entry_points            => old_ucrse_rec.max_entry_points
                  ,x_current_validity            => old_ucrse_rec.current_validity
                  ,x_deferred_validity           => old_ucrse_rec.deferred_validity
                  ,x_term_1_start                => new_uvcrse_rec.term1start
                  ,x_term_1_end                  => new_uvcrse_rec.term1end
                  ,x_term_2_start                => new_uvcrse_rec.term2start
                  ,x_term_2_end                  => new_uvcrse_rec.term2end
                  ,x_term_3_start                => new_uvcrse_rec.term3start
                  ,x_term_3_end                  => new_uvcrse_rec.term3end
                  ,x_term_4_start                => new_uvcrse_rec.term4start
                  ,x_term_4_end                  => new_uvcrse_rec.term4end
                  ,x_cl_updated                  => old_ucrse_rec.cl_updated
                  ,x_cl_date                     => old_ucrse_rec.cl_date
                  ,x_vacancy_status              => old_ucrse_rec.vacancy_status
                  ,x_no_of_vacancy               => old_ucrse_rec.no_of_vacancy
                  ,x_score                       => old_ucrse_rec.score
                  ,x_rb_full                     => old_ucrse_rec.rb_full
                  ,x_scot_vac                    => old_ucrse_rec.scot_vac
                  ,x_sent_to_ucas                => old_ucrse_rec.sent_to_ucas
                  ,x_mode                        => 'R'
                  ,x_ucas_system_id              => NULL -- passed as NULL as System_code is being used for identifying the System
                  ,x_oss_attendance_type         => old_ucrse_rec.oss_attendance_type
                  ,x_oss_attendance_mode         => old_ucrse_rec.oss_attendance_mode
                  ,x_joint_admission_ind         => new_uvcrse_rec.jointadmission
                  ,x_open_extra_ind              => new_uvcrse_rec.openextra
                  ,x_system_code                 => old_ucrse_rec.system_code
                  ,x_clearing_options            => old_ucrse_rec.clearing_options
                  ,x_imported                    => 'Y'
                   );


               EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '9998';
                    fnd_file.put_line(fnd_file.log, SQLERRM);
               END;

            END IF;  -- insert/update

         END IF;  -- main processing


      EXCEPTION
           WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.

               -- Close any Open cursors
               IF old_ucrse_cur%ISOPEN THEN
                  CLOSE old_ucrse_cur;
               END IF;

              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);
      END;

      -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
      -- while processing the record.
      IF g_error_code IS NOT NULL THEN

         UPDATE igs_uc_ucrse_ints
         SET    error_code = g_error_code
         WHERE  rowid      = new_uvcrse_rec.rowid;

         -- log error message/meaning.
         igs_uc_proc_ucas_data.log_error_msg(g_error_code);

         -- update error count
         g_error_rec_cnt  := g_error_rec_cnt  + 1;

      ELSE

         UPDATE igs_uc_ucrse_ints
         SET    record_status = 'D',
                error_code = NULL
         WHERE  rowid      = new_uvcrse_rec.rowid;

         g_success_rec_cnt := g_success_rec_cnt + 1;
      END IF;

    END LOOP;


    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('UVCOURSE', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    -- Process should continue with processing of other view data
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'UVCOURSE'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_uvcourse ;


  PROCEDURE process_uvcoursekeyword  IS
  /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing Updateable Course Vacancy option details info. from UCAS
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
     rgangara  16-ARP-04    Modified keyword processing to delete existing keyword records for the
                            combination (Course,campus, optioncode) and insert afresh the entire
                            set. If any records fails in the set, none of the records should get
                            processed. All keyword records with error would as usual get populated
                            with Error Code. For records which are successful but could not be processed
                            as the set has some invalid records would be populated with 2002 error code.
                            This is done as part of bug# 3496874.
     jbaber    15-SEP-05    Removed keyno from cursor for bug 4589994
   ******************************************************************/

 -- Get distinct Course options for new interface records
    CURSOR int_crseops_cur IS
    SELECT DISTINCT int.course,
           int.campus,
           int.optioncode
    FROM   igs_uc_ucrskwd_ints int
    WHERE  int.record_status = 'N';

    -- Cursor to return rows for a course,campus,optioncode combination
    -- which are to be deleted before inserting fresh records.
    CURSOR old_crskwd_del_cur (p_course   igs_uc_ucrskwd_ints.course%TYPE,
                               p_campus   igs_uc_ucrskwd_ints.campus%TYPE,
                               p_opt_code igs_uc_ucrskwd_ints.optioncode%TYPE,
                               p_system   igs_uc_crse_keywrds.system_code%TYPE ) IS
    SELECT ucrvop.rowid, ucrvop.keyword
    FROM   igs_uc_crse_keywrds ucrvop
    WHERE  ucrvop.ucas_program_code = p_course
      AND  ucrvop.institute         = g_crnt_institute
      AND  ucrvop.ucas_campus       = p_campus
      AND  ucrvop.option_code       = p_opt_code
      AND  ucrvop.system_code       = p_system;


    -- Get new interface records for the course, campus, optioncode
    CURSOR int_ucrsekwd_cur (cp_course   igs_uc_ucrskwd_ints.course%TYPE,
                             cp_campus   igs_uc_ucrskwd_ints.campus%TYPE,
                             cp_optioncd igs_uc_ucrskwd_ints.optioncode%TYPE) IS
    SELECT ucvi.rowid,
           ucvi.*
    FROM   igs_uc_ucrskwd_ints ucvi
    WHERE  ucvi.record_status = 'N'
      AND  ucvi.course     = cp_course
      AND  ucvi.campus     = cp_campus
      AND  ucvi.optioncode = cp_optioncd;

    -- check whether corresponding record already exists.
    -- Currently since only FTUG is supported over Hercules and no course data for other systems come from UCAS,
    -- the system code has been hardcoded to U for 'FTUG'.
    CURSOR old_crskwd_cur (p_course   igs_uc_ucrskwd_ints.course%TYPE,
                           p_campus   igs_uc_ucrskwd_ints.campus%TYPE,
                           p_opt_code igs_uc_ucrskwd_ints.optioncode%TYPE,
                           p_keyword  igs_uc_ucrskwd_ints.keyword%TYPE,
                           p_system   igs_uc_crse_keywrds.system_code%TYPE ) IS
    SELECT ucrvop.rowid,
           ucrvop.*
    FROM   igs_uc_crse_keywrds ucrvop
    WHERE  ucrvop.ucas_program_code = p_course
    AND    ucrvop.institute         = g_crnt_institute
    AND    ucrvop.ucas_campus       = p_campus
    AND    ucrvop.option_code       = p_opt_code
    AND    ucrvop.keyword           = p_keyword
    AND    ucrvop.system_code       = p_system;

    -- validate the the UCAS program details are valid i.e exist in Course details table.
    CURSOR validate_crse_cur (p_course igs_uc_ucrsvac_ints.course%TYPE, p_campus igs_uc_ucrsvac_ints.campus%TYPE,
                              p_system igs_uc_crse_dets.system_code%TYPE) IS
    SELECT ucrdet.rowid
    FROM   igs_uc_crse_dets ucrdet
    WHERE  ucrdet.ucas_program_code = p_course
    AND    ucrdet.institute         = g_crnt_institute
    AND    ucrdet.ucas_campus       = p_campus
    AND    ucrdet.system_code       = p_system;


    -- validate keyword value exists in IGS_UC_REF_KEYWORDS
    CURSOR validate_keyword_cur (p_keyword igs_uc_ucrskwd_ints.keyword%TYPE) IS
    SELECT rowid
    FROM   igs_uc_ref_keywords
    WHERE  keyword = p_keyword;


    old_crsekwd_rec old_crskwd_cur%ROWTYPE;
    l_rowid    VARCHAR2(26);
    l_crse_keyword_id igs_uc_crse_keywrds.crse_keyword_id%TYPE;
    l_set_level_success VARCHAR2(1);

  BEGIN
    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;
    l_set_level_success := 'Y';

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'UVCOURSEKEYWORD ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Setting Error code to NULL for 'N' status records.
    -- This is done to support the logic for processing as a combined set whereby the entire set is
    -- marked as error if atleast one rec in the set is invalid.
    UPDATE igs_uc_ucrskwd_ints
    SET    error_code = NULL
    WHERE  record_status = 'N';


    FOR int_crseops_rec IN int_crseops_cur LOOP

       l_set_level_success := 'Y'; -- initializing to Yes for each set
       -- log record level processing message
       fnd_message.set_name('IGS','IGS_UC_CRS_CAMP_OPT_PROC');
       fnd_message.set_token('COURSE', int_crseops_rec.course);
       fnd_message.set_token('CAMPUS', int_crseops_rec.campus);
       fnd_message.set_token('OPTION', int_crseops_rec.optioncode);
       fnd_file.put_line(fnd_file.log, fnd_message.get);

       -- Check whether any correspoinding records exist in UCAS table.
       -- IF exists delete old keyword records for the combination.
       FOR old_crskwd_del_rec IN old_crskwd_del_cur(int_crseops_rec.course,
                                                    int_crseops_rec.campus,
                                                    int_crseops_rec.optioncode,
                                                    'U')
       LOOP
           igs_uc_crse_keywrds_pkg.delete_row (old_crskwd_del_rec.rowid);
       END LOOP;

       -- Get all the reocords for the combination from interface table with status = 'N'
       FOR new_ucrsekwd_rec IN int_ucrsekwd_cur(int_crseops_rec.course,
                                                int_crseops_rec.campus,
                                                int_crseops_rec.optioncode)
       LOOP

         BEGIN
            -- record level initialization
            g_error_code      := NULL;
            old_crsekwd_rec   := NULL;
            l_crse_keyword_id := NULL;

            -- log record level processing message
            fnd_message.set_name('IGS','IGS_UC_CRSE_KEYWORD_PROC');
            fnd_message.set_token('KEYWORD', new_ucrsekwd_rec.keyword);
            fnd_file.put_line(fnd_file.log, '     ' || fnd_message.get);

            -- validate mandatory fields have values.
            IF new_ucrsekwd_rec.course IS NULL OR new_ucrsekwd_rec.campus IS NULL OR new_ucrsekwd_rec.optioncode IS NULL THEN
               g_error_code := '1037';
            END IF;


            -- course validation
            IF g_error_code IS NULL THEN

               l_rowid := NULL;
               OPEN  validate_crse_cur (new_ucrsekwd_rec.course, new_ucrsekwd_rec.campus, 'U');
               FETCH validate_crse_cur INTO l_rowid;
               CLOSE validate_crse_cur;

               IF l_rowid IS NULL THEN
                  g_error_code := '1035';
               END IF;

            END IF;


            -- Keyword validation
            IF g_error_code IS NULL THEN

               l_rowid := NULL;
               OPEN  validate_keyword_cur (new_ucrsekwd_rec.keyword);
               FETCH validate_keyword_cur INTO l_rowid;
               CLOSE validate_keyword_cur;

               IF l_rowid IS NULL THEN
                  g_error_code := '1036';
               END IF;

            END IF;


            -- main processing begins
            IF g_error_code IS NULL THEN
               -- check whether corresponding rec already exists
               OPEN  old_crskwd_cur(new_ucrsekwd_rec.course, new_ucrsekwd_rec.campus, new_ucrsekwd_rec.optioncode, new_ucrsekwd_rec.keyword, 'U');
               FETCH old_crskwd_cur INTO old_crsekwd_rec;
               CLOSE old_crskwd_cur;

               -- If not found then insert
               IF old_crsekwd_rec.rowid IS NULL THEN

                  BEGIN
                    -- insert a new record - call the TBH
                    igs_uc_crse_keywrds_pkg.insert_row  -- IGSXI15B.pls
                    (
                       x_rowid                             => old_crsekwd_rec.rowid
                      ,x_ucas_program_code                 => new_ucrsekwd_rec.course
                      ,x_institute                         => g_crnt_institute
                      ,x_ucas_campus                       => new_ucrsekwd_rec.campus
                      ,x_option_code                       => new_ucrsekwd_rec.optioncode
                      ,x_preference                        => new_ucrsekwd_rec.keyno
                      ,x_keyword                           => new_ucrsekwd_rec.keyword
                      ,x_updater                           => NVL(new_ucrsekwd_rec.updater,'5')
                      ,x_active                            => NVL(new_ucrsekwd_rec.active,'Y')
                      ,x_deleted                           => 'N'
                      ,x_sent_to_ucas                      => 'Y'
                      ,x_mode                              => 'R'
                      ,x_system_code                       => 'U'
                      ,x_crse_keyword_id                   => l_crse_keyword_id
                    );

                  EXCEPTION
                    WHEN OTHERS THEN
                       g_error_code := '9999';
                       fnd_file.put_line(fnd_file.log, SQLERRM);
                  END;


               ELSE  -- update

                  BEGIN
                      -- update a new record in the main table
                      igs_uc_crse_keywrds_pkg.update_row  -- IGSXI15B.pls
                      (
                       x_rowid                           => old_crsekwd_rec.rowid
                      ,x_ucas_program_code               => old_crsekwd_rec.ucas_program_code
                      ,x_institute                       => old_crsekwd_rec.institute
                      ,x_ucas_campus                     => old_crsekwd_rec.ucas_campus
                      ,x_option_code                     => old_crsekwd_rec.option_code
                      ,x_preference                      => old_crsekwd_rec.preference
                      ,x_keyword                         => new_ucrsekwd_rec.keyword
                      ,x_updater                         => NVL(new_ucrsekwd_rec.updater,'5')
                      ,x_active                          => NVL(new_ucrsekwd_rec.active,'Y')
                      ,x_deleted                         => old_crsekwd_rec.deleted
                      ,x_sent_to_ucas                    => 'Y'
                      ,x_mode                            => 'R'
                      ,x_system_code                     => old_crsekwd_rec.system_code
                      ,x_crse_keyword_id                 => old_crsekwd_rec.crse_keyword_id
                      );

                  EXCEPTION
                    WHEN OTHERS THEN
                       g_error_code := '9998';
                       fnd_file.put_line(fnd_file.log, SQLERRM);
                  END;

               END IF;  -- insert/update

            END IF;  -- main processing


          EXCEPTION
              WHEN OTHERS THEN
                 -- catch any unhandled/unexpected errors while processing a record.
                 -- This would enable processing to continue with subsequent records.

               -- Close any Open cursors
               IF old_crskwd_cur%ISOPEN THEN
                  CLOSE old_crskwd_cur;
               END IF;


               IF validate_crse_cur%ISOPEN THEN
                  CLOSE validate_crse_cur;
               END IF;

               IF validate_keyword_cur%ISOPEN THEN
                  CLOSE validate_keyword_cur;
               END IF;

               g_error_code := '1055';
               fnd_file.put_line(fnd_file.log, SQLERRM);
          END;

          -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
          -- while processing the record.
          IF g_error_code IS NOT NULL THEN

               -- set the flag to No if atleast one rec fails in a set.
               l_set_level_success := 'N';

               UPDATE igs_uc_ucrskwd_ints
               SET    error_code = g_error_code
               WHERE  rowid      = new_ucrsekwd_rec.rowid;

               -- log error message/meaning.
               igs_uc_proc_ucas_data.log_error_msg(g_error_code);

               -- update error count
               g_error_rec_cnt  := g_error_rec_cnt  + 1;

          ELSE
               -- No updating of record status to D as they will be done at the SET level below
               g_success_rec_cnt := g_success_rec_cnt + 1;

          END IF;

       END LOOP;

       -- The following logic is to set Status and error codes in INT table for the
       -- combination based on whether all records were successfully processed or not.
       -- If atleast one record failed in the set the entire set is marked as Error.
       -- Errored records will have specific error codes. For records that are valid
       -- in the failed set will have error as 2002. Added as part of bug# 3496874
       IF  l_set_level_success = 'N' THEN
           -- Delete all the successfully created records of the set as the entire set is not successful.
           FOR old_crskwd_del_rec IN old_crskwd_del_cur(int_crseops_rec.course,
                                                        int_crseops_rec.campus,
                                                        int_crseops_rec.optioncode,
                                                        'U')
           LOOP
             igs_uc_crse_keywrds_pkg.delete_row (old_crskwd_del_rec.rowid);
           END LOOP;

           -- update valid INTS records for this course and campus combination to 2002
           -- for records which were successful but cant be processed as a set.
           -- The error code is NULL condition is used to select only success records
           -- for the current set in which they will be NULL. Earlier records if any would
           -- have got deleted or Error Code reset to NULL in the beginning of the keyword processing.
           UPDATE igs_uc_ucrskwd_ints SET error_code = '2002'
            WHERE  record_status = 'N'
              AND  course = int_crseops_rec.course
              AND  campus = int_crseops_rec.campus
              AND  optioncode = int_crseops_rec.optioncode
              AND  error_code IS NULL ;

             -- reset the success count by that many as they were earlier taken to be successful
             g_success_rec_cnt := g_success_rec_cnt - SQL%ROWCOUNT;
             g_error_rec_cnt   := g_error_rec_cnt   + SQL%ROWCOUNT;
       ELSE

           -- Indicates all records in the set are successful.
           -- update all INTS records for this set status 'D'.
           UPDATE igs_uc_ucrskwd_ints SET record_status = 'D' , error_code = NULL
           WHERE  record_status = 'N'
             AND  course = int_crseops_rec.course
             AND  campus = int_crseops_rec.campus
             AND  optioncode = int_crseops_rec.optioncode;
       END IF ;

    END LOOP; -- main loop for the combination

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('UVCOURSEKEYWORD', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    -- Process should continue with processing of other view data
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'UVCOURSEKEYWORD'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_uvcoursekeyword ;

END igs_uc_proc_com_inst_data;

/
