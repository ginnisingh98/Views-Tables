--------------------------------------------------------
--  DDL for Package Body IGS_UC_PROC_REFERENCE_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_PROC_REFERENCE_DATA" AS
/* $Header: IGSUC67B.pls 120.2 2006/08/21 06:15:58 jbaber noship $  */

  g_success_rec_cnt NUMBER;
  g_error_rec_cnt   NUMBER;
  g_error_code      igs_uc_crfcode_ints.error_code%TYPE;


  PROCEDURE process_cvrefcodes  IS
    /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing CVCONTROL data
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ******************************************************************/

     CURSOR int_crfcode_cur IS
     SELECT rowid,
            code_type,
            code,
            code_text
     FROM   igs_uc_crfcode_ints
     WHERE  record_status = 'N';

     CURSOR chk_code_type_cur (p_code  igs_uc_crfcode_ints.code%TYPE) IS
     SELECT 'X'
     FROM   igs_lookup_values
     WHERE  lookup_type  = 'IGS_UC_CODE_TYPES'
     AND    lookup_code  = p_code
     AND    enabled_flag = 'Y'
     AND    NVL(closed_ind, 'N') = 'N';

     CURSOR old_rfcode_cur(p_code igs_uc_ref_codes.code%TYPE, p_type igs_uc_ref_codes.code_type%TYPE) IS
     SELECT rfc.rowid
     FROM   igs_uc_ref_codes rfc
     WHERE  code_type = p_type
     AND    code      = p_code ;

     old_rfcode_rec old_rfcode_cur%ROWTYPE ;
     l_valid_type VARCHAR2(1);
     l_rowid  VARCHAR2(26) := NULL;

  BEGIN

    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'REFERENCE CODES ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Get all the reocords from interface table with status = 'N'
    FOR new_crfcode_rec IN int_crfcode_cur
    LOOP

       BEGIN
          -- initialize record level variables.
          l_rowid      := NULL;
          g_error_code := NULL;
          l_valid_type := NULL;

          -- log record level processing message
          fnd_message.set_name('IGS','IGS_UC_PROC_REFCODE_REC');
          fnd_message.set_token('CODE', new_crfcode_rec.code);
          fnd_message.set_token('TYPE', new_crfcode_rec.code_type);
          fnd_file.put_line(fnd_file.log, fnd_message.get);


          -- validate mandatory fields have values.
          IF new_crfcode_rec.code_type IS NULL OR new_crfcode_rec.code IS NULL THEN
             g_error_code := '1037';
          END IF;

          IF g_error_code IS NULL THEN
             -- validate Code type value.
             OPEN  chk_code_type_cur (new_crfcode_rec.code_type);
             FETCH chk_code_type_cur INTO l_valid_type;
             CLOSE chk_code_type_cur;

             IF l_valid_type IS NULL THEN
                -- invalid code type hence not found and is NULL
                g_error_code := '1040';
             END IF;
          END IF;

          IF g_error_code IS NULL THEN  -- i.e. Code type is valid

             l_rowid := NULL;

             -- Check whther the error code already exists or not
             -- If exists , update the records otherwise insert a new record
             OPEN old_rfcode_cur(new_crfcode_rec.code, new_crfcode_rec.code_type);
             FETCH old_rfcode_cur INTO l_rowid;
             CLOSE old_rfcode_cur;

             IF l_rowid IS NULL THEN
                BEGIN
                   --Insert a new record
                   igs_uc_ref_codes_pkg.insert_row --IGSXI26B.pls
                   (
                     x_rowid        => l_rowid
                    ,x_code_type    => new_crfcode_rec.code_type
                    ,x_code         => new_crfcode_rec.code
                    ,x_code_text    => new_crfcode_rec.code_text
                    ,x_imported     => 'Y'
                    ,x_mode         => 'R'
                    );
                EXCEPTION
                   WHEN OTHERS THEN
                     g_error_code := '9998';
                     fnd_file.put_line(fnd_file.log, SQLERRM);

                END;

             ELSE /* Update the record */
                BEGIN
                   igs_uc_ref_codes_pkg.update_row --IGSXI26B.pls
                   (
                    x_rowid         => l_rowid
                    ,x_code_type    => new_crfcode_rec.code_type
                    ,x_code         => new_crfcode_rec.code
                    ,x_code_text    => new_crfcode_rec.code_text
                    ,x_imported     => 'Y'
                    ,x_mode         => 'R'
                    );
                EXCEPTION
                   WHEN OTHERS THEN
                     g_error_code := '9998';
                     fnd_file.put_line(fnd_file.log, SQLERRM);

                     -- log error message
                     igs_uc_proc_ucas_data.log_error_msg(g_error_code);
                END;
             END IF; -- insert / update
          END IF; -- Code type validation


        EXCEPTION
           WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.

               -- Close any Open cursors
               IF chk_code_type_cur%ISOPEN THEN
                  CLOSE chk_code_type_cur;
               END IF;

               IF old_rfcode_cur%ISOPEN THEN
                  CLOSE old_rfcode_cur;
               END IF;

               IF chk_code_type_cur%ISOPEN THEN
                  CLOSE chk_code_type_cur;
               END IF;

              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);
        END;

        -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
        -- while processing the record.
        IF g_error_code IS NOT NULL THEN
             UPDATE igs_uc_crfcode_ints
             SET    error_code    = g_error_code
             WHERE  rowid = new_crfcode_rec.rowid;

             -- log error message/meaning.
             igs_uc_proc_ucas_data.log_error_msg(g_error_code);
             -- update error count
             g_error_rec_cnt  := g_error_rec_cnt  + 1;

        ELSE
             UPDATE igs_uc_crfcode_ints
             SET    record_status = 'D',
                    error_code    = NULL
             WHERE  rowid = new_crfcode_rec.rowid;

             g_success_rec_cnt := g_success_rec_cnt + 1;  -- count successfully processed records
        END IF;

    END LOOP;

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('REFERENCE CODES', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    -- Process should continue with processing of other view data
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'REF CODES'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_cvrefcodes;



  PROCEDURE process_cvrefawardbody  IS
    /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing Ref Award body data
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */
    l_rowid     VARCHAR2(26) := NULL;

    -- Get new interface records
    CURSOR int_awdbdy_cur IS
    SELECT  rowid
           ,year
           ,sitting
           ,awardingbody
           ,bodyname
           ,bodyabbrev
    FROM   igs_uc_crawdbd_ints
    WHERE  record_status = 'N';

    -- check whether corresponding record already exists.
    CURSOR old_awdbdy_cur (p_year igs_uc_ref_awrdbdy.year%TYPE,
                           p_sitting igs_uc_ref_awrdbdy.sitting%TYPE,
                           p_awd_body igs_uc_ref_awrdbdy.awarding_body%TYPE) IS
    SELECT awd.rowid
    FROM   igs_uc_ref_awrdbdy awd
    WHERE  awd.year = p_year
    AND    awd.sitting = p_sitting
    AND    awd.awarding_body = p_awd_body;

  BEGIN
    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;

        fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
        fnd_message.set_token('VIEW', 'CVREFAWARDBODY ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
        fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Get all the reocords from interface table with status = 'N'
    FOR new_awdbdy_rec IN int_awdbdy_cur LOOP

      BEGIN
         -- record level initialization
         l_rowid := NULL;
         g_error_code := NULL;

         -- log record level processing message
         fnd_message.set_name('IGS','IGS_UC_PROC_REFAWD_REC');
         fnd_message.set_token('YEAR', new_awdbdy_rec.year);
         fnd_message.set_token('SITTING', new_awdbdy_rec.sitting);
         fnd_message.set_token('AWDBDY', new_awdbdy_rec.awardingbody);
         fnd_file.put_line(fnd_file.log, fnd_message.get);


         -- validate mandatory fields have values.
         IF new_awdbdy_rec.year IS NULL OR new_awdbdy_rec.sitting IS NULL OR new_awdbdy_rec.awardingbody IS NULL THEN
            g_error_code := '1037';
         END IF;

         IF g_error_code IS NULL THEN

            -- check whether corresponding rec already exists
            OPEN  old_awdbdy_cur(new_awdbdy_rec.year, new_awdbdy_rec.sitting, new_awdbdy_rec.awardingbody);
            FETCH old_awdbdy_cur INTO l_rowid;
            CLOSE old_awdbdy_cur;


            -- If not found then insert
            IF l_rowid IS NULL THEN
               BEGIN
                igs_uc_ref_awrdbdy_pkg.insert_row --IGSXI25B.pls
                (
                  x_rowid           => l_rowid
                  ,x_year           => new_awdbdy_rec.year
                  ,x_sitting        => new_awdbdy_rec.sitting
                  ,x_awarding_body  => new_awdbdy_rec.awardingbody
                  ,x_body_name      => new_awdbdy_rec.bodyname
                  ,x_body_abbrev    => new_awdbdy_rec.bodyabbrev
                  ,x_imported       => 'Y'
                  ,x_mode           => 'R'
                 );

               EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '9999';
                    fnd_file.put_line(fnd_file.log, SQLERRM);

               END;

            ELSE  -- update
               BEGIN
                igs_uc_ref_awrdbdy_pkg.update_row --IGSXI25B.pls
                (
                  x_rowid           => l_rowid
                  ,x_year           => new_awdbdy_rec.year
                  ,x_sitting        => new_awdbdy_rec.sitting
                  ,x_awarding_body  => new_awdbdy_rec.awardingbody
                  ,x_body_name      => new_awdbdy_rec.bodyname
                  ,x_body_abbrev    => new_awdbdy_rec.bodyabbrev
                  ,x_imported       => 'Y'
                  ,x_mode           => 'R'
                 );

               EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '9998';
                    fnd_file.put_line(fnd_file.log, SQLERRM);

               END;
            END IF; -- insert/update

         END IF; -- error code check

         EXCEPTION
           WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.

              -- Close any Open cursors
              IF old_awdbdy_cur%ISOPEN THEN
                 CLOSE old_awdbdy_cur;
              END IF;

              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);
         END;

         -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
         -- while processing the record.
         IF g_error_code IS NOT NULL THEN
            UPDATE igs_uc_crawdbd_ints
            SET    error_code    = g_error_code
            WHERE  rowid = new_awdbdy_rec.rowid;

            -- log error message/meaning.
            igs_uc_proc_ucas_data.log_error_msg(g_error_code);
            -- update error count
            g_error_rec_cnt  := g_error_rec_cnt  + 1;

         ELSE
            UPDATE igs_uc_crawdbd_ints
            SET    record_status = 'D',
                   error_code    = NULL
            WHERE  rowid = new_awdbdy_rec.rowid;

            g_success_rec_cnt := g_success_rec_cnt + 1;

         END IF;

    END LOOP;

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('CVREFAWARDBODY', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    -- Process should continue with processing of other view data
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'CVREFAWARDBODY'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_cvrefawardbody;



  PROCEDURE process_cvrefapr  IS
    /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing Results data from UCAS
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */
    l_rowid     VARCHAR2(26) := NULL;

    -- Get new interface records
    CURSOR int_refapr_cur IS
    SELECT  rowid
           ,dom
           ,domtext
           ,leaflag
    FROM   igs_uc_crapr_ints
    WHERE  record_status = 'N';

    -- check whether corresponding record already exists.
    CURSOR old_refapr_cur (p_dom igs_uc_crapr_ints.dom%TYPE) IS
    SELECT rapr.rowid
    FROM   igs_uc_ref_apr rapr
    WHERE  rapr.dom = p_dom ;

  BEGIN
    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'CVREFAPR ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Get all the reocords from interface table with status = 'N'
    FOR new_refapr_rec IN int_refapr_cur LOOP

      BEGIN

         -- record level initialization
         l_rowid := NULL;
         g_error_code := NULL;

         -- log record level processing message
         fnd_message.set_name('IGS','IGS_UC_PROC_INTERFACE_REC');
         fnd_message.set_token('KEY', 'DOM');
         fnd_message.set_token('VALUE', new_refapr_rec.dom);
         fnd_file.put_line(fnd_file.log, fnd_message.get);


         -- validate mandatory fields have values.
         IF new_refapr_rec.dom IS NULL THEN
            g_error_code := '1037';
         END IF;

         IF g_error_code IS NULL THEN

            -- check whether corresponding rec already exists
            OPEN  old_refapr_cur(new_refapr_rec.dom);
            FETCH old_refapr_cur INTO l_rowid;
            CLOSE old_refapr_cur;


            -- If not found then insert
            IF l_rowid IS NULL THEN
               BEGIN
                 igs_uc_ref_apr_pkg.insert_row --IGSXI24B.pls
                 (
                  x_rowid      => l_rowid
                 ,x_dom        => new_refapr_rec.dom
                 ,x_dom_text   => new_refapr_rec.domtext
                 ,x_lea_flag   => NVL(new_refapr_rec.leaflag,'Y')
                 ,x_imported   => 'Y'
                 ,x_mode       => 'R'
                 );

               EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '9999';
                    fnd_file.put_line(fnd_file.log, SQLERRM);
               END;

            ELSE  -- update
               BEGIN
                 igs_uc_ref_apr_pkg.update_row --IGSXI24B.pls
                 (
                  x_rowid        => l_rowid
                 ,x_dom          => new_refapr_rec.dom
                 ,x_dom_text     => new_refapr_rec.domtext
                 ,x_lea_flag     => NVL(new_refapr_rec.leaflag,'Y')
                 ,x_imported     => 'Y'
                 ,x_mode         => 'R'
                 );

               EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '9998';
                    fnd_file.put_line(fnd_file.log, SQLERRM);
               END;
            END IF;

         END IF;  -- error not null

       EXCEPTION
           WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.

              -- Close any Open cursors
              IF old_refapr_cur%ISOPEN THEN
                 CLOSE old_refapr_cur;
              END IF;

              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);
       END;

       -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
       -- while processing the record.
       IF g_error_code IS NOT NULL THEN
            UPDATE igs_uc_crapr_ints
            SET    error_code    = g_error_code
            WHERE  rowid = new_refapr_rec.rowid;

            -- log error message/meaning.
            igs_uc_proc_ucas_data.log_error_msg(g_error_code);

            -- update error count
            g_error_rec_cnt  := g_error_rec_cnt  + 1;

       ELSE
            UPDATE igs_uc_crapr_ints
            SET    record_status = 'D',
                   error_code    = NULL
            WHERE  rowid = new_refapr_rec.rowid;

            g_success_rec_cnt := g_success_rec_cnt + 1;
       END IF;

    END LOOP;

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('CVREFAPR', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    -- Process should continue with processing of other view data
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'CVREFAPR'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_cvrefapr;


  PROCEDURE process_cvrefkeyword  IS
    /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing Reference Keywords data from UCAS
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */
    l_rowid     VARCHAR2(26) := NULL;

    -- Get new interface records
    CURSOR int_refkwd_cur IS
    SELECT rowid,
           keyword
    FROM   igs_uc_crkywd_ints
    WHERE  record_status = 'N';

    -- check whether corresponding record already exists.
    CURSOR old_refkwd_cur (p_keyword igs_uc_crkywd_ints.keyword%TYPE) IS
    SELECT rowid
    FROM   igs_uc_ref_keywords
    WHERE  keyword = p_keyword ;

  BEGIN
    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'CVREFKEYWORD ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Get all the reocords from interface table with status = 'N'
    FOR new_refkwd_rec IN int_refkwd_cur LOOP

      BEGIN
         -- record level initialization
         l_rowid := NULL;
         g_error_code := NULL;

         -- log record level processing message
         fnd_message.set_name('IGS','IGS_UC_PROC_INTERFACE_REC');
         fnd_message.set_token('KEY', 'KEYWORD');
         fnd_message.set_token('VALUE', new_refkwd_rec.keyword);
         fnd_file.put_line(fnd_file.log, fnd_message.get);


         -- validate mandatory fields have values.
         IF new_refkwd_rec.keyword IS NULL THEN
            g_error_code := '1037';
         END IF;

         IF g_error_code IS NULL THEN

            -- check whether corresponding rec already exists
            OPEN  old_refkwd_cur(new_refkwd_rec.keyword);
            FETCH old_refkwd_cur INTO l_rowid;
            CLOSE old_refkwd_cur;


            -- If not found then insert
            IF l_rowid IS NULL THEN
               BEGIN
                 igs_uc_ref_keywords_pkg.insert_row --IGSXI29B.pls
                 (
                  x_rowid      => l_rowid
                 ,x_keyword    => new_refkwd_rec.keyword
                 ,x_imported   => 'Y'
                 ,x_mode       => 'R'
                 );

               EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '9999';
                    fnd_file.put_line(fnd_file.log, SQLERRM);
               END;

            ELSE  -- update
               BEGIN
                 igs_uc_ref_keywords_pkg.update_row --IGSXI29B.pls
                 (
                  x_rowid        => l_rowid
                 ,x_keyword      => new_refkwd_rec.keyword
                 ,x_imported     => 'Y'
                 ,x_mode         => 'R'
                 );

               EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '9998';
                    fnd_file.put_line(fnd_file.log, SQLERRM);
               END;
            END IF;

         END IF;  -- error not null

       EXCEPTION
           WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.

              -- Close any Open cursors
              IF old_refkwd_cur%ISOPEN THEN
                 CLOSE old_refkwd_cur;
              END IF;

              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);
       END;

       -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
       -- while processing the record.
       IF g_error_code IS NOT NULL THEN
            UPDATE igs_uc_crkywd_ints
            SET    error_code = g_error_code
            WHERE  rowid      = new_refkwd_rec.rowid;

            -- log error message/meaning.
            igs_uc_proc_ucas_data.log_error_msg(g_error_code);
            -- update error count
            g_error_rec_cnt  := g_error_rec_cnt  + 1;

       ELSE
            UPDATE igs_uc_crkywd_ints
            SET    record_status = 'D',
                   error_code = NULL
            WHERE  rowid      = new_refkwd_rec.rowid;

            g_success_rec_cnt := g_success_rec_cnt + 1;
       END IF;

    END LOOP;

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('CVREFKEYWORD', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    -- Process should continue with processing of other view data
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'CVREFKEYWORD'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_cvrefkeyword;


  PROCEDURE process_cvrefpocc IS
    /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing REFPOCC data from UCAS
     Known limitations,enhancements,remarks:
     Change History
     Who       When        What
     jbaber    15-Sep-05   Removed NULL check on socialclass and socioeconomic
                           for bug 4589994
    ***************************************************************** */
    l_rowid     VARCHAR2(26) := NULL;

    -- Get new interface records
    CURSOR int_refpocc_cur IS
    SELECT rowid
          ,pocc
          ,socialclass
          ,occupationtext
          ,alternativetext
          ,alternateclass1
          ,alternateclass2
          ,socioeconomic
    FROM   igs_uc_crefpoc_ints
    WHERE  record_status = 'N';

    -- check whether corresponding record already exists.
    CURSOR old_refpocc_cur (p_pocc igs_uc_crefpoc_ints.pocc%TYPE) IS
    SELECT rowid
    FROM   igs_uc_ref_pocc
    WHERE  pocc = p_pocc ;

  BEGIN
    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'CVREFPOCC ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Get all the reocords from interface table with status = 'N'
    FOR new_refpocc_rec IN int_refpocc_cur LOOP

      BEGIN

         -- record level initialization
         l_rowid := NULL;
         g_error_code := NULL;

         -- log record level processing message
         fnd_message.set_name('IGS','IGS_UC_PROC_INTERFACE_REC');
         fnd_message.set_token('KEY', 'POCC');
         fnd_message.set_token('VALUE', new_refpocc_rec.pocc);
         fnd_file.put_line(fnd_file.log, fnd_message.get);


         -- validate mandatory fields have values.
         IF new_refpocc_rec.pocc IS NULL THEN
            g_error_code := '1037';
         END IF;


         IF g_error_code IS NULL THEN

            -- check whether corresponding rec already exists
            OPEN  old_refpocc_cur(new_refpocc_rec.pocc);
            FETCH old_refpocc_cur INTO l_rowid;
            CLOSE old_refpocc_cur;


            -- If not found then insert
            IF l_rowid IS NULL THEN

               BEGIN
                   igs_uc_ref_pocc_pkg.insert_row --IGSXI31B.pls
                   (
                    x_rowid              => l_rowid
                   ,x_pocc               => new_refpocc_rec.pocc
                   ,x_social_class       => new_refpocc_rec.socialclass
                   ,x_occupation_text    => new_refpocc_rec.occupationtext
                   ,x_alternative_text   => new_refpocc_rec.alternativetext
                   ,x_alternative_class1 => new_refpocc_rec.alternateclass1
                   ,x_alternative_class2 => new_refpocc_rec.alternateclass2
                   ,x_imported           => 'Y'
                   ,x_socio_economic     => new_refpocc_rec.socioeconomic
                   ,x_mode               => 'R'
                   );

               EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '9999';
                    fnd_file.put_line(fnd_file.log, SQLERRM);
               END;

            ELSE  -- update
               BEGIN
                 igs_uc_ref_pocc_pkg.update_row --IGSXI31B.pls
                 (
                    x_rowid              => l_rowid
                   ,x_pocc               => new_refpocc_rec.pocc
                   ,x_social_class       => new_refpocc_rec.socialclass
                   ,x_occupation_text    => new_refpocc_rec.occupationtext
                   ,x_alternative_text   => new_refpocc_rec.alternativetext
                   ,x_alternative_class1 => new_refpocc_rec.alternateclass1
                   ,x_alternative_class2 => new_refpocc_rec.alternateclass2
                   ,x_imported           => 'Y'
                   ,x_socio_economic     => new_refpocc_rec.socioeconomic
                   ,x_mode               => 'R'
                 );

               EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '9998';
                    fnd_file.put_line(fnd_file.log, SQLERRM);
               END;
            END IF;

         END IF;  -- error not null

        EXCEPTION
           WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.

              -- Close any Open cursors
              IF old_refpocc_cur%ISOPEN THEN
                 CLOSE old_refpocc_cur;
              END IF;

              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);
        END;

         -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
         -- while processing the record.
         IF g_error_code IS NOT NULL THEN
            UPDATE igs_uc_crefpoc_ints
            SET    error_code = g_error_code
            WHERE  rowid      = new_refpocc_rec.rowid;

            -- log error message/meaning.
            igs_uc_proc_ucas_data.log_error_msg(g_error_code);
            -- update error count
            g_error_rec_cnt  := g_error_rec_cnt  + 1;

         ELSE
            UPDATE igs_uc_crefpoc_ints
            SET    record_status = 'D',
                   error_code = NULL
            WHERE  rowid      = new_refpocc_rec.rowid;

            g_success_rec_cnt := g_success_rec_cnt + 1;
         END IF;

    END LOOP;

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('CVREFPOCC', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'CVREFPOCC'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_cvrefpocc;




PROCEDURE process_cvrefofferabbrev  IS
  /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing REF Offer Abbreviations data from UCAS
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */
    l_rowid     VARCHAR2(26) := NULL;

    -- Get new interface records
    CURSOR int_refoffab_cur IS
    SELECT offab.rowid,
           offab.*
    FROM   igs_uc_croffab_ints offab
    WHERE  record_status = 'N';

    -- check whether corresponding record already exists.
    CURSOR old_refoffab_cur (p_abbrev igs_uc_croffab_ints.abbrevcode%TYPE) IS
    SELECT roab.rowid,
           roab.*
    FROM   igs_uc_ref_off_abrv roab
    WHERE  abbrev_code = p_abbrev ;

    old_refoffab_rec old_refoffab_cur%ROWTYPE;

  BEGIN

    -- Populate seed abbreviation codes if not present in main table.
    -- check for 'TO'.
    OPEN old_refoffab_cur ('TO');
    FETCH old_refoffab_cur INTO old_refoffab_rec;

    IF old_refoffab_cur%NOTFOUND THEN
       l_rowid := NULL;
       -- create a new record with Abbreviation = 'TO' if not found
       igs_uc_ref_off_abrv_pkg.insert_row --IGSXI30B.pls
        (
        x_rowid            => l_rowid
       ,x_abbrev_code      => 'TO'
       ,x_uv_updater       => NULL
       ,x_abbrev_text      => 'Tariff Offer'
       ,x_letter_format    => 'B'
       ,x_summary_char     => NULL
       ,x_uncond           => 'N'
       ,x_withdrawal       => 'N'
       ,x_release          => 'N'
       ,x_imported         => 'N'
       ,x_sent_to_ucas     => 'Y'
       ,x_deleted          => 'N'
       ,x_tariff           => 'Y'
       ,x_mode             => 'R'
       );
    END IF;
    CLOSE old_refoffab_cur;

    old_refoffab_rec := NULL; -- initialize it back to NULL.

    -- Populate seed abbreviation codes if not present in main table.
    -- check for 'TE'
    OPEN old_refoffab_cur ('TE');
    FETCH old_refoffab_cur INTO old_refoffab_rec;

    IF old_refoffab_cur%NOTFOUND THEN
       l_rowid := NULL;
       -- create a new record with Abbreviation = 'TE' if not found
       igs_uc_ref_off_abrv_pkg.insert_row --IGSXI30B.pls
        (
        x_rowid            => l_rowid
       ,x_abbrev_code      => 'TE'
       ,x_uv_updater       => NULL
       ,x_abbrev_text      => 'End Tariff Offer'
       ,x_letter_format    => 'B'
       ,x_summary_char     => NULL
       ,x_uncond           => 'N'
       ,x_withdrawal       => 'N'
       ,x_release          => 'N'
       ,x_imported         => 'N'
       ,x_sent_to_ucas     => 'Y'
       ,x_deleted          => 'N'
       ,x_tariff           => 'Y'
       ,x_mode             => 'R'
       );
    END IF;
    CLOSE old_refoffab_cur;
    old_refoffab_rec := NULL;

-- Interface table processing begins from here.
    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'CVREFOFFERABBREV ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Get all the reocords from interface table with status = 'N'
    FOR new_refoffab_rec IN int_refoffab_cur LOOP

      BEGIN

         -- record level initialization
         l_rowid := NULL;
         g_error_code := NULL;
         old_refoffab_rec := NULL;

         -- log record level processing message
         fnd_message.set_name('IGS','IGS_UC_PROC_INTERFACE_REC');
         fnd_message.set_token('KEY', 'Abbreviation Code');
         fnd_message.set_token('VALUE', new_refoffab_rec.abbrevcode);
         fnd_file.put_line(fnd_file.log, fnd_message.get);


         -- validate mandatory fields have values.
         IF new_refoffab_rec.abbrevcode IS NULL OR new_refoffab_rec.letterformat IS NULL THEN
            g_error_code := '1037';
         END IF;

         IF g_error_code IS NULL THEN

            -- check whether corresponding rec already exists
            OPEN  old_refoffab_cur(new_refoffab_rec.abbrevcode);
            FETCH old_refoffab_cur INTO old_refoffab_rec;
            CLOSE old_refoffab_cur;


            -- If not found then insert
            IF old_refoffab_rec.rowid IS NULL THEN
               BEGIN
                igs_uc_ref_off_abrv_pkg.insert_row --IGSXI30B.pls
                (
                 x_rowid            => l_rowid
                ,x_abbrev_code      => new_refoffab_rec.abbrevcode
                ,x_uv_updater       => ''
                ,x_abbrev_text      => new_refoffab_rec.abbrevtext
                ,x_letter_format    => new_refoffab_rec.letterformat
                ,x_summary_char     => NVL(new_refoffab_rec.summarychar, 'N')
                ,x_uncond           => NVL(new_refoffab_rec.uncond, 'N')
                ,x_withdrawal       => NVL(new_refoffab_rec.withdrawal, 'N')
                ,x_release          => NVL(new_refoffab_rec.release, 'N')
                ,x_imported         => 'Y'
                ,x_sent_to_ucas     => 'Y'
                ,x_deleted          => 'N'
                ,x_tariff           => new_refoffab_rec.tariff
                ,x_mode             => 'R'
                );

               EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '9999';
                    fnd_file.put_line(fnd_file.log, SQLERRM);
               END;

            ELSE  -- update
               BEGIN
                 igs_uc_ref_off_abrv_pkg.update_row --IGSXI30B.pls
                 (
                 x_rowid            => old_refoffab_rec.rowid
                ,x_abbrev_code      => old_refoffab_rec.abbrev_code
                ,x_uv_updater         => old_refoffab_rec.uv_updater
                ,x_abbrev_text      => new_refoffab_rec.abbrevtext
                ,x_letter_format      => new_refoffab_rec.letterformat
                ,x_summary_char     => NVL(new_refoffab_rec.summarychar, 'N')
                ,x_uncond             => NVL(new_refoffab_rec.uncond, 'N')
                ,x_withdrawal       => NVL(new_refoffab_rec.withdrawal, 'N')
                ,x_release            => NVL(new_refoffab_rec.release, 'N')
                ,x_imported         => 'Y'
                ,x_sent_to_ucas       => 'Y'
                ,x_deleted          => 'N'
                ,x_tariff           => new_refoffab_rec.tariff
                ,x_mode               => 'R'
                 );

               EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '9998';
                    fnd_file.put_line(fnd_file.log, SQLERRM);
               END;
            END IF;

         END IF;  -- error not null

        EXCEPTION
           WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.

              -- Close any Open cursors
              IF old_refoffab_cur%ISOPEN THEN
                 CLOSE old_refoffab_cur;
              END IF;

              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);
        END;

        -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
        -- while processing the record.
        IF g_error_code IS NOT NULL THEN
            UPDATE igs_uc_croffab_ints
            SET    error_code = g_error_code
            WHERE  rowid      = new_refoffab_rec.rowid;

            -- log error message/meaning.
            igs_uc_proc_ucas_data.log_error_msg(g_error_code);
            -- update error count
            g_error_rec_cnt  := g_error_rec_cnt  + 1;


        ELSE
            UPDATE igs_uc_croffab_ints
            SET    record_status = 'D',
                   error_code = NULL
            WHERE  rowid      = new_refoffab_rec.rowid;

            g_success_rec_cnt := g_success_rec_cnt + 1;
        END IF;

    END LOOP;

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('CVREFOFFERABBREV', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'CVREFOFFERABBREV'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_cvrefofferabbrev;




PROCEDURE process_cvrefsubj IS
  /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing Subjects data from UCAS
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */
    l_rowid     VARCHAR2(26) := NULL;

    -- Get new interface records
    CURSOR int_refsubj_cur IS
    SELECT rowid,
           subjcode,
           subjtext,
           subjabbrev,
           ebl_subj
    FROM   igs_uc_crsubj_ints
    WHERE  record_status = 'N';

    -- check whether corresponding record already exists.
    CURSOR old_refsubj_cur (p_subject igs_uc_crsubj_ints.subjcode%TYPE) IS
    SELECT rowid
    FROM   igs_uc_ref_subj
    WHERE  SUBJ_CODE = p_subject ;

  BEGIN
    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'CVREFSUBJ ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Get all the reocords from interface table with status = 'N'
    FOR new_refsubj_rec IN int_refsubj_cur LOOP

      BEGIN

         -- record level initialization
         l_rowid := NULL;
         g_error_code := NULL;

         -- log record level processing message
         fnd_message.set_name('IGS','IGS_UC_PROC_INTERFACE_REC');
         fnd_message.set_token('KEY', 'SUBJECT ');
         fnd_message.set_token('VALUE', new_refsubj_rec.subjcode);
         fnd_file.put_line(fnd_file.log, fnd_message.get);


         -- validate mandatory fields have values.
         IF new_refsubj_rec.subjcode IS NULL OR new_refsubj_rec.SUBJTEXT IS NULL THEN
            g_error_code := '1037';
         END IF;

         IF g_error_code IS NULL THEN

            -- check whether corresponding rec already exists
            OPEN  old_refsubj_cur(new_refsubj_rec.subjcode);
            FETCH old_refsubj_cur INTO l_rowid;
            CLOSE old_refsubj_cur;


            -- If not found then insert
            IF l_rowid IS NULL THEN
               BEGIN
                igs_uc_ref_subj_pkg.Insert_row
                 (
                  x_rowid         => l_rowid,
                  x_subj_code     => new_refsubj_rec.subjcode,
                  x_subj_text     => new_refsubj_rec.subjtext  ,
                  x_subj_abbrev   => new_refsubj_rec.subjabbrev,
                  x_ebl_subj      => new_refsubj_rec.ebl_subj,
                  x_imported      => 'Y',
                  x_mode          => 'R'
                 );

               EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '9999';
                    fnd_file.put_line(fnd_file.log, SQLERRM);
               END;

            ELSE  -- update
               BEGIN
                igs_uc_ref_subj_pkg.update_row
                 (
                  x_rowid         => l_rowid,
                  x_subj_code     => new_refsubj_rec.subjcode,
                  x_subj_text     => new_refsubj_rec.subjtext  ,
                  x_subj_abbrev   => new_refsubj_rec.subjabbrev,
                  x_ebl_subj      => new_refsubj_rec.ebl_subj,
                  x_imported      => 'Y',
                  x_mode          => 'R'
                 );

               EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '9998';
                    fnd_file.put_line(fnd_file.log, SQLERRM);
               END;
            END IF;

         END IF;  -- error not null

        EXCEPTION
           WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.

              -- Close any Open cursors
              IF old_refsubj_cur%ISOPEN THEN
                 CLOSE old_refsubj_cur;
              END IF;

              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);
        END;

         -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
         -- while processing the record.
         IF g_error_code IS NOT NULL THEN
            UPDATE igs_uc_crsubj_ints
            SET    error_code = g_error_code
            WHERE  rowid      = new_refsubj_rec.rowid;

            -- log error message/meaning.
            igs_uc_proc_ucas_data.log_error_msg(g_error_code);
            -- update error count
            g_error_rec_cnt  := g_error_rec_cnt  + 1;

         ELSE
            UPDATE igs_uc_crsubj_ints
            SET    record_status = 'D',
                   error_code = NULL
            WHERE  rowid      = new_refsubj_rec.rowid;

            g_success_rec_cnt := g_success_rec_cnt + 1;
         END IF;

    END LOOP;

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('CVREFSUBJ', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'CVREFSUBJ'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_cvrefsubj;




PROCEDURE process_cvreftariff IS
  /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing Tariff data from UCAS
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */

    -- Get new interface records
    CURSOR int_reftariff_cur IS
    SELECT rowid,
           examlevel,
           examgrade,
           tariffscore
    FROM   igs_uc_ctariff_ints
    WHERE  record_status = 'N';

    -- check whether corresponding record already exists.
    CURSOR old_reftariff_cur (p_examlevel igs_uc_ctariff_ints.examlevel%TYPE,
                              p_examgrade igs_uc_ctariff_ints.examgrade%TYPE) IS
    SELECT rtrf.rowid,
           rtrf.*
    FROM   igs_uc_ref_tariff rtrf
    WHERE  rtrf.exam_level = p_examlevel
    AND    rtrf.exam_grade = p_examgrade;

    old_tariff_rec old_reftariff_cur%ROWTYPE;

  BEGIN
    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'CVREFTARIFF ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Get all the reocords from interface table with status = 'N'
    FOR new_reftariff_rec IN int_reftariff_cur LOOP

      BEGIN
         -- record level initialization
         g_error_code := NULL;
         old_tariff_rec := NULL;

         -- log record level processing message
         fnd_message.set_name('IGS','IGS_UC_PROC_REFTARIFF_REC');
         fnd_message.set_token('EXAMLVL' , new_reftariff_rec.examlevel);
         fnd_message.set_token('EXAMGRADE', new_reftariff_rec.examgrade);
         fnd_file.put_line(fnd_file.log, fnd_message.get);

         -- validate mandatory fields have values.
         IF new_reftariff_rec.examlevel IS NULL OR new_reftariff_rec.examgrade IS NULL OR new_reftariff_rec.tariffscore IS NULL THEN
            g_error_code := '1037';
         END IF;


         IF g_error_code IS NULL THEN

            -- check whether corresponding rec already exists
            OPEN  old_reftariff_cur(new_reftariff_rec.examlevel, new_reftariff_rec.examgrade);
            FETCH old_reftariff_cur INTO old_tariff_rec;
            CLOSE old_reftariff_cur;


            -- If not found then insert
            IF old_tariff_rec.rowid IS NULL THEN
               BEGIN
                igs_uc_ref_tariff_pkg.insert_row --
                (
                   x_rowid           => old_tariff_rec.rowid
                  ,x_exam_level      => new_reftariff_rec.examlevel
                  ,x_exam_grade      => new_reftariff_rec.examgrade
                  ,x_tariff_score    => new_reftariff_rec.tariffscore
                  ,x_imported        =>'Y'
                  ,x_mode            =>'R'
                 );

               EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '9999';
                    fnd_file.put_line(fnd_file.log, SQLERRM);
               END;

            ELSE  -- update
               BEGIN
                igs_uc_ref_tariff_pkg.update_row --
                (
                   x_rowid           => old_tariff_rec.rowid
                  ,x_exam_level      => old_tariff_rec.exam_level
                  ,x_exam_grade      => old_tariff_rec.exam_grade
                  ,x_tariff_score    => new_reftariff_rec.tariffscore
                  ,x_imported        =>'Y'
                  ,x_mode            =>'R'
                 );

               EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '9998';
                    fnd_file.put_line(fnd_file.log, SQLERRM);
               END;
            END IF;

         END IF;  -- error not null

        EXCEPTION
           WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.

              -- Close any Open cursors
              IF old_reftariff_cur%ISOPEN THEN
                 CLOSE old_reftariff_cur;
              END IF;

              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);
        END;

         -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
         -- while processing the record.
         IF g_error_code IS NOT NULL THEN
            UPDATE igs_uc_ctariff_ints
            SET    error_code = g_error_code
            WHERE  rowid      = new_reftariff_rec.rowid;

            -- log error message/meaning.
            igs_uc_proc_ucas_data.log_error_msg(g_error_code);

            -- update error count
            g_error_rec_cnt  := g_error_rec_cnt  + 1;

         ELSE
            UPDATE igs_uc_ctariff_ints
            SET    record_status = 'D',
                   error_code = NULL
            WHERE  rowid      = new_reftariff_rec.rowid;

            g_success_rec_cnt := g_success_rec_cnt + 1;
         END IF;

    END LOOP;

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('CVREFTARIFF', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'CVREFTARIFF'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);

  END process_cvreftariff;


  PROCEDURE process_cvjointadmissions IS
  /******************************************************************
     Created By      :   rgangara
     Date Created By :   12-JUNE-2003
     Purpose         :   For processing Joint Admissions data from UCAS
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */
    l_rowid     VARCHAR2(26) := NULL;

    -- Get new interface records
    CURSOR int_cjntadm_cur IS
    SELECT rowid
          ,childinst
          ,parentinst1
          ,parentinst2
          ,parentinst3
          ,parentinst4
          ,parentinst5
    FROM   igs_uc_cjntadm_ints
    WHERE  record_status = 'N';

    -- check whether corresponding record already exists.
    CURSOR old_cjntadm_cur (p_childinst igs_uc_cjntadm_ints.childinst%TYPE) IS
    SELECT rowid
    FROM   igs_uc_jnt_adm_inst
    WHERE  child_inst = p_childinst ;

    CURSOR chk_inst_cur (p_inst igs_uc_com_inst.inst%TYPE) IS
    SELECT 'X'
    FROM   igs_uc_com_inst
    WHERE  inst = p_inst;

    chk_inst_rec chk_inst_cur%ROWTYPE;
    l_inst_exists VARCHAR2(1);

  BEGIN
    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'CVJOINTADMISSIONS ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Get all the reocords from interface table with status = 'N'
    FOR new_cjntadm_rec IN int_cjntadm_cur LOOP

      BEGIN
         -- record level initialization
         l_rowid := NULL;
         g_error_code := NULL;

         -- log record level processing message
         fnd_message.set_name('IGS','IGS_UC_PROC_INTERFACE_REC');
         fnd_message.set_token('KEY' , 'CHILDINST ');
         fnd_message.set_token('VALUE', new_cjntadm_rec.childinst);
         fnd_file.put_line(fnd_file.log, fnd_message.get);


         -- validate mandatory fields have values.
         IF new_cjntadm_rec.childinst IS NULL OR new_cjntadm_rec.parentinst1 IS NULL THEN
            g_error_code := '1037';
         END IF;

         -- validate that the child institution field has valid institution code value.
         IF g_error_code IS NULL THEN
            OPEN chk_inst_cur (new_cjntadm_rec.childinst);
            FETCH chk_inst_cur INTO chk_inst_rec;

            IF  chk_inst_cur%NOTFOUND THEN
                g_error_code := '1027';
            END IF;

            CLOSE chk_inst_cur;
         END IF;

         -- validate that the parent institution 1 field has valid institution code value.
         IF g_error_code IS NULL THEN

            OPEN chk_inst_cur (new_cjntadm_rec.parentinst1);
            FETCH chk_inst_cur INTO chk_inst_rec;

            IF chk_inst_cur%NOTFOUND THEN
                g_error_code := '1028';
            END IF;

            CLOSE chk_inst_cur;
         END IF;

         -- validate that the parent institution 2 field has valid institution code value.
         IF g_error_code IS NULL AND new_cjntadm_rec.parentinst2 IS NOT NULL THEN

            OPEN chk_inst_cur (new_cjntadm_rec.parentinst2);
            FETCH chk_inst_cur INTO chk_inst_rec;

            IF chk_inst_cur%NOTFOUND THEN
                g_error_code := '1029';
            END IF;

            CLOSE chk_inst_cur;
         END IF;

         -- validate that the parent institution 3 field has valid institution code value.
         IF g_error_code IS NULL AND new_cjntadm_rec.parentinst3 IS NOT NULL THEN

            OPEN chk_inst_cur (new_cjntadm_rec.parentinst3);
            FETCH chk_inst_cur INTO chk_inst_rec;

            IF chk_inst_cur%NOTFOUND THEN
                g_error_code := '1030';
            END IF;

            CLOSE chk_inst_cur;
         END IF;

         -- validate that the parent institution 4 field has valid institution code value.
         IF g_error_code IS NULL AND new_cjntadm_rec.parentinst4 IS NOT NULL THEN

            OPEN chk_inst_cur (new_cjntadm_rec.parentinst4);
            FETCH chk_inst_cur INTO chk_inst_rec;

            IF chk_inst_cur%NOTFOUND THEN
                g_error_code := '1031';
            END IF;

            CLOSE chk_inst_cur;
         END IF;

         -- validate that the parent institution 5 field has valid institution code value.
         IF g_error_code IS NULL AND new_cjntadm_rec.parentinst5 IS NOT NULL THEN

            OPEN chk_inst_cur (new_cjntadm_rec.parentinst5);
            FETCH chk_inst_cur INTO chk_inst_rec;

            IF chk_inst_cur%NOTFOUND THEN
                g_error_code := '1032';
            END IF;

            CLOSE chk_inst_cur;
         END IF;


         IF g_error_code IS NULL THEN

            -- check whether corresponding rec already exists
            OPEN  old_cjntadm_cur(new_cjntadm_rec.childinst);
            FETCH old_cjntadm_cur INTO l_rowid;
            CLOSE old_cjntadm_cur;


            -- If not found then insert
            IF l_rowid IS NULL THEN
               BEGIN
                igs_uc_jnt_adm_inst_pkg.insert_row --
                (
                  x_rowid           => l_rowid
                 ,x_child_inst      => new_cjntadm_rec.childinst
                 ,x_parent_inst1    => new_cjntadm_rec.parentinst1
                 ,x_parent_inst2    => new_cjntadm_rec.parentinst2
                 ,x_parent_inst3    => new_cjntadm_rec.parentinst3
                 ,x_parent_inst4    => new_cjntadm_rec.parentinst4
                 ,x_parent_inst5    => new_cjntadm_rec.parentinst5
                 ,x_mode            =>'R'
                 );

               EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '9999';
                    fnd_file.put_line(fnd_file.log, SQLERRM);
               END;

            ELSE  -- update
               BEGIN
                igs_uc_jnt_adm_inst_pkg.update_row
                (
                  x_rowid           => l_rowid
                 ,x_child_inst      => new_cjntadm_rec.childinst
                 ,x_parent_inst1    => new_cjntadm_rec.parentinst1
                 ,x_parent_inst2    => new_cjntadm_rec.parentinst2
                 ,x_parent_inst3    => new_cjntadm_rec.parentinst3
                 ,x_parent_inst4    => new_cjntadm_rec.parentinst4
                 ,x_parent_inst5    => new_cjntadm_rec.parentinst5
                 ,x_mode            =>'R'
                 );

               EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '9998';
                    fnd_file.put_line(fnd_file.log, SQLERRM);
               END;
            END IF;

         END IF;  -- error not null


        EXCEPTION
           WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.

              -- Close any Open cursors
              IF old_cjntadm_cur%ISOPEN THEN
                 CLOSE old_cjntadm_cur;
              END IF;

              IF chk_inst_cur%ISOPEN THEN
                 CLOSE chk_inst_cur;
              END IF;

              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);
        END;

         -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
         -- while processing the record.
         IF g_error_code IS NOT NULL THEN
            UPDATE igs_uc_cjntadm_ints
            SET    error_code = g_error_code
            WHERE  rowid      = new_cjntadm_rec.rowid;

            -- log error message/meaning.
            igs_uc_proc_ucas_data.log_error_msg(g_error_code);
            -- update error count
            g_error_rec_cnt  := g_error_rec_cnt  + 1;

         ELSE
            UPDATE igs_uc_cjntadm_ints
            SET    record_status = 'D',
                   error_code = NULL
            WHERE  rowid      = new_cjntadm_rec.rowid;

            g_success_rec_cnt := g_success_rec_cnt + 1;
         END IF;

    END LOOP;

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('CVJOINTADMISSIONS', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'CVJOINTADMISSIONS'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_cvjointadmissions;


  PROCEDURE process_cvrefcountry  IS
    /******************************************************************
     Created By      :   jbaber
     Date Created By :   14-July-2006
     Purpose         :   For processing Ref Country data
     Known limitations,enhancements,remarks:
     Change History
     Who       When         What
    ***************************************************************** */
    l_rowid     VARCHAR2(26) := NULL;

    -- Get new interface records
    CURSOR int_country_cur IS
    SELECT  rowid
           ,countrycode
           ,description
           ,type
    FROM   igs_uc_country_ints
    WHERE  record_status = 'N';

    -- check whether corresponding record already exists.
    CURSOR old_country_cur (p_country_code igs_uc_ref_country.country_code%TYPE) IS
    SELECT rowid
    FROM   igs_uc_ref_country
    WHERE  country_code = p_country_code;

  BEGIN
    -- initialize variables
    g_success_rec_cnt := 0;
    g_error_rec_cnt   := 0;

    fnd_message.set_name('IGS','IGS_UC_PROC_VIEW_DATA');
    fnd_message.set_token('VIEW', 'CVREFCOUNTRY ON '||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    fnd_file.put_line(fnd_file.log, fnd_message.get);

    -- Get all the reocords from interface table with status = 'N'
    FOR new_country_rec IN int_country_cur LOOP

      BEGIN
         -- record level initialization
         l_rowid := NULL;
         g_error_code := NULL;

         -- log record level processing message
         fnd_message.set_name('IGS','IGS_UC_PROC_INTERFACE_REC');
         fnd_message.set_token('KEY' , 'COUNTRY CODE');
         fnd_message.set_token('VALUE', new_country_rec.countrycode);
         fnd_file.put_line(fnd_file.log, fnd_message.get);


         -- validate mandatory fields have values.
         IF new_country_rec.countrycode IS NULL THEN
            g_error_code := '1037';
         END IF;

         IF g_error_code IS NULL THEN

            -- check whether corresponding rec already exists
            OPEN  old_country_cur(new_country_rec.countrycode);
            FETCH old_country_cur INTO l_rowid;
            CLOSE old_country_cur;


            -- If not found then insert
            IF l_rowid IS NULL THEN
               BEGIN
                igs_uc_ref_country_pkg.insert_row --
                (
                 x_rowid              => l_rowid
                ,x_country_code       => new_country_rec.countrycode
                ,x_description        => new_country_rec.description
                ,x_type               => new_country_rec.type
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
                igs_uc_ref_country_pkg.update_row
                 (
                  x_rowid              => l_rowid
                 ,x_country_code       => new_country_rec.countrycode
                 ,x_description        => new_country_rec.description
                 ,x_type               => new_country_rec.type
                 ,x_imported           => 'Y'
                 ,x_mode               => 'R'
                 );

               EXCEPTION
                 WHEN OTHERS THEN
                    g_error_code := '9998';
                    fnd_file.put_line(fnd_file.log, SQLERRM);
               END;
            END IF;

         END IF;  -- error not null

        EXCEPTION
           WHEN OTHERS THEN
              -- catch any unhandled/unexpected errors while processing a record.
              -- This would enable processing to continue with subsequent records.

              -- Close any Open cursors
              IF old_country_cur%ISOPEN THEN
                 CLOSE old_country_cur;
              END IF;

              g_error_code := '1055';
              fnd_file.put_line(fnd_file.log, SQLERRM);
        END;

         -- update the interface table rec - record_status if successfully processed or Error Code if any error encountered
         -- while processing the record.
         IF g_error_code IS NOT NULL THEN
            UPDATE igs_uc_country_ints
            SET    error_code = g_error_code
            WHERE  rowid      = new_country_rec.rowid;

            -- log error message/meaning.
            igs_uc_proc_ucas_data.log_error_msg(g_error_code);
            -- update error count
            g_error_rec_cnt  := g_error_rec_cnt  + 1;

         ELSE
            UPDATE igs_uc_country_ints
            SET    record_status = 'D',
                   error_code = NULL
            WHERE  rowid      = new_country_rec.rowid;

            g_success_rec_cnt := g_success_rec_cnt + 1;
         END IF;


    END LOOP;

    COMMIT;
    -- log processing complete for this view
    igs_uc_proc_ucas_data.log_proc_complete('CVREFCOUNTRY', g_success_rec_cnt, g_error_rec_cnt);

  EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    fnd_message.set_name('IGS','IGS_UC_ERROR_PROC_DATA');
    fnd_message.set_token('VIEW', 'CVREFPRECOUNTRY'||' - '||SQLERRM);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END process_cvrefcountry;




END igs_uc_proc_reference_data;

/
