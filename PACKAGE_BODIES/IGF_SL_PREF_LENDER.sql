--------------------------------------------------------
--  DDL for Package Body IGF_SL_PREF_LENDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_PREF_LENDER" AS
/* $Header: IGFSL21B.pls 120.7 2006/05/05 00:56:24 veramach ship $ */
--=========================================================================
--   Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA
--                               All rights reserved.
-- ========================================================================
--
--  DESCRIPTION
--         PL/SQL body for package: IGF_SL_PREF_LENDER
--
--  NOTES
--
--  This process is used to assign a preferred lender to a group of students
--  using Person ID Groups.
--
----------------------------------------------------------------------------------
--  HISTORY
----------------------------------------------------------------------------------
--  who              when            what
----------------------------------------------------------------------------------
-- upinjark       16-Feb-2005    Bug #4187798. Modified line no 135,168,499
--                                             replacing FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
--					       with FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION
----------------------------------------------------------------------------------
--  ridas            03-JAN-2005    Bug #4097414. Modified the cursor c_get_persons
----------------------------------------------------------------------------------
--  sjadhav          14-oct-2003    Changed update flag code to update
----------------------------------------------------------------------------------
--  bkkumar          01-SEP-2003    FFELP Loans - Assign Preferred Lender
--                                  FA 122 Loan Enhancements
----------------------------------------------------------------------------------
--  bkkumar          29-sep-2003    Incorporated review comments.
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

TYPE log_record IS RECORD
        ( person_number VARCHAR2(30),
          message_text fnd_new_messages.message_text%TYPE);

-- The PL/SQL table for storing the log messages
TYPE LogTab IS TABLE OF log_record
           index by binary_integer;

g_log_tab LogTab;
g_log_tab_index   NUMBER := 0; -- index for the log table

 PROCEDURE print_log_process(
                              p_start_date         IN DATE,
                              p_pergrp_id          IN VARCHAR2,
                              p_rel_code           IN VARCHAR2,
                              p_update             IN VARCHAR2
                             ) IS
    /*
    ||  Created By : bkkumar
    ||  Created On : 26-MAY-2003
    ||  Purpose : This process gets the records from the pl/sql table and print in the log file
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

    l_count NUMBER(5) := g_log_tab.COUNT;
    l_person_number   VARCHAR2(80);
    l_rel_code       VARCHAR2(80);
    l_start_dt       VARCHAR2(80);
    l_pergrp_id      VARCHAR2(80);
    l_yes_no          VARCHAR2(10);
    l_param_passed    VARCHAR2(80);
    l_award_yr_status VARCHAR2(80);
    l_update          VARCHAR2(80);

-- cursor for getting the lookup meanings
   CURSOR  c_get_meaning( cp_lookup_type igf_lookups_view.lookup_type%TYPE)
    IS
    SELECT lookup_code ,
           meaning
    FROM   igf_lookups_view
    WHERE  lookup_type = cp_lookup_type
    AND    lookup_code IN ('PARAMETER_PASS','PERSON_ID_GROUP','REL_CODE','START_DATE','UPDATE');
    l_get_meaning c_get_meaning%ROWTYPE;

  BEGIN
   -- open the cursor for getting the lookup meanings to be displayed on the log file

    FOR l_get_meaning IN c_get_meaning('IGF_GE_PARAMETERS') LOOP
      IF l_get_meaning.lookup_code = 'REL_CODE' THEN
         l_rel_code := l_get_meaning.meaning;
      ELSIF l_get_meaning.lookup_code = 'PERSON_ID_GROUP' THEN
         l_pergrp_id := l_get_meaning.meaning;
      ELSIF l_get_meaning.lookup_code = 'START_DATE' THEN
         l_start_dt := l_get_meaning.meaning;
      ELSIF l_get_meaning.lookup_code = 'PARAMETER_PASS' THEN
         l_param_passed := l_get_meaning.meaning;
      ELSIF l_get_meaning.lookup_code = 'UPDATE' THEN
         l_update := l_get_meaning.meaning;
      END IF;
    END LOOP;

    l_yes_no  := igf_ap_gen.get_lookup_meaning('IGF_AP_YES_NO',p_update);

     -- here the input parameters are to be logged to the log file
    fnd_file.put_line(fnd_file.log,l_param_passed);
    fnd_file.put_line(fnd_file.log,RPAD(l_pergrp_id,30) || ' : ' || p_pergrp_id);
    fnd_file.put_line(fnd_file.log,RPAD(l_rel_code,30) || ' : ' || p_rel_code);
    fnd_file.put_line(fnd_file.log,RPAD(l_start_dt,30) || ' : ' || p_start_date);

    fnd_file.put_line(fnd_file.log,RPAD(l_update,30) || ' : ' || l_yes_no);

    -- loop through the log table to display the message after proper formatiing
    FOR i IN 1..l_count LOOP
      IF g_log_tab(i).person_number IS NOT NULL THEN
          fnd_file.put_line(fnd_file.log,'---------------------------------------------------------------------------------');
          fnd_file.put_line(fnd_file.log,'');
          fnd_message.set_name('IGS','IGS_FI_PERSON_NUM');
          fnd_message.set_token('PERSON_NUM',g_log_tab(i).person_number);
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          fnd_file.put_line(fnd_file.log,'');
       END IF;
      fnd_file.put_line(fnd_file.log,g_log_tab(i).message_text);
    END LOOP;

   EXCEPTION
        WHEN others THEN
        IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'igf.plsql.igf_sl_pref_lender.print_log_process.exception',SQLERRM);
        END IF;
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_SL_PREF_LENDER.PRINT_LOG_PROCESS');
        app_exception.raise_exception;

  END print_log_process;

 PROCEDURE add_log_table_process(
                                  p_person_number     IN VARCHAR2,
                                  p_error             IN VARCHAR2,
                                  p_message_str       IN VARCHAR2
                                 ) IS
    /*
    ||  Created By : bkkumar
    ||  Created On : 26-MAY-2003
    ||  Purpose : This process adds a record to the global pl/sql table containing log messages
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

  BEGIN
    -- add the corresponding message to the log table
    g_log_tab_index := g_log_tab_index + 1;
    g_log_tab(g_log_tab_index).person_number := p_person_number;
    g_log_tab(g_log_tab_index).message_text := RPAD('',12) || p_message_str;

  EXCEPTION
        WHEN others THEN
        IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'igf.plsql.igf_sl_pref_lender.add_log_table_process.exception',SQLERRM);
        END IF;
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_SL_PREF_LENDER.ADD_LOG_TABLE_PROCESS');
        app_exception.raise_exception;

  END add_log_table_process;

  PROCEDURE check_for_todo(
                           p_person_id hz_parties.party_id%TYPE
                          ) AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 03 /June /2005
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  -- Get to do item
  CURSOR c_todo(
                cp_person_id hz_parties.party_id%TYPE
               ) IS
    SELECT tdi.ROWID row_id,
           tdi.*
      FROM igf_ap_td_item_inst_all tdi,
           igf_ap_td_item_mst_all tdm,
           igf_ap_fa_base_rec_all fa
     WHERE fa.person_id = cp_person_id
       AND tdi.item_sequence_number = tdm.todo_number
       AND fa.base_id = tdi.base_id
       AND tdm.system_todo_type_code = 'PREFLEND'
       AND NVL(tdi.inactive_flag,'Y') = 'N'
       AND tdi.status IN ('INC','REQ');

  BEGIN

    FOR l_todo IN c_todo(p_person_id) LOOP
      igf_ap_td_item_inst_pkg.update_row(
                                         x_rowid                    => l_todo.row_id,
                                         x_base_id                  => l_todo.base_id,
                                         x_item_sequence_number     => l_todo.item_sequence_number,
                                         x_status                   => 'COM',
                                         x_status_date              => TRUNC(SYSDATE),
                                         x_add_date                 => l_todo.add_date,
                                         x_corsp_date               => l_todo.corsp_date,
                                         x_corsp_count              => l_todo.corsp_count,
                                         x_inactive_flag            => l_todo.inactive_flag,
                                         x_freq_attempt             => l_todo.freq_attempt,
                                         x_max_attempt              => l_todo.max_attempt,
                                         x_required_for_application => l_todo.required_for_application,
                                         x_mode                     => 'R',
                                         x_legacy_record_flag       => l_todo.legacy_record_flag,
                                         x_clprl_id                 => l_todo.clprl_id
                                        );
    END LOOP;

  EXCEPTION
    WHEN others THEN
      IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'igf.plsql.igf_sl_pref_lender.check_for_todo.exception',SQLERRM);
      END IF;
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_SL_PREF_LENDER.CHECK_FOR_TODO');
      app_exception.raise_exception;
  END check_for_todo;

  PROCEDURE main (
                  errbuf          OUT NOCOPY VARCHAR2,
                  retcode         OUT NOCOPY NUMBER,
                  p_pergrp_id     IN         NUMBER,
                  p_rel_code      IN         VARCHAR2,
                  p_start_date    IN         VARCHAR2,
                  p_update        IN         VARCHAR2
                 )
    IS
    /*
    ||  Created By : bkkumar
    ||  Created On : 01-SEP-2003
    ||  Purpose : Main process which assigns a preferred lender to a student.
    ||
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who					When            What
    ||  ridas       08-Feb-2006     Bug #5021084. Added new parameter 'lv_group_type' in call to igf_ap_ss_pkg.get_pid
	  ||  tsailaja		15/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
    ||  (reverse chronological order - newest change first)
    */

    l_terminate_flag       BOOLEAN := FALSE;
    l_error_flag           BOOLEAN := FALSE;
    l_error                VARCHAR2(80);
    lv_row_id              VARCHAR2(80) := NULL;
    lv_person_id           igs_pe_hz_parties.party_id%TYPE := NULL;
    lv_base_id             igf_ap_fa_base_rec_all.base_id%TYPE := NULL;
    l_success_record_cnt   NUMBER := 0;
    l_error_record_cnt     NUMBER := 0;
    l_message              VARCHAR2(2000);
    l_msg_count            NUMBER;
    l_msg_number           NUMBER;
    l_app                  VARCHAR2(50);
    l_return_status        VARCHAR2(50);
    l_total_record_cnt     NUMBER := 0;
    l_debug_str            VARCHAR2(800) := NULL;
    l_start_date           DATE;
    l_clprl_id             igf_sl_cl_pref_lenders.clprl_id%TYPE := NULL;



    CURSOR c_get_relation_code (
                                cp_rel_code   igf_sl_cl_recipient.relationship_cd%TYPE
                               )
    IS
    SELECT relationship_cd
    FROM   igf_sl_cl_recipient
    WHERE  relationship_cd = cp_rel_code
    AND    enabled = 'Y';


    l_get_relation_code  c_get_relation_code%ROWTYPE;

    CURSOR c_chk_perid_grp (
                             cp_perid_grp   igs_pe_persid_group_all.group_id%TYPE,
                             cp_closed_ind  igs_pe_persid_group_all.closed_ind%TYPE
                           )
    IS
    SELECT group_cd
    FROM   igs_pe_persid_group_all
    WHERE  group_id = cp_perid_grp
    AND    closed_ind = cp_closed_ind
    AND    create_dt <= SYSDATE;

    l_chk_perid_grp   c_chk_perid_grp%ROWTYPE;

    TYPE RefCur IS REF CURSOR;
    c_get_persons RefCur;

    l_person_id     hz_parties.party_id%TYPE;
    l_person_number hz_parties.party_number%TYPE;

    CURSOR c_chk_pref_lender (
                              cp_person_id  igf_sl_cl_pref_lenders.person_id%TYPE
                             )
    IS
    SELECT ROWID row_id,
           clprl_id,
           relationship_cd,
           start_date,
           end_date
    FROM   igf_sl_cl_pref_lenders
    WHERE  person_id = cp_person_id
    AND    end_date IS NULL;

    l_chk_pref_lender   c_chk_pref_lender%ROWTYPE;

    lv_status         VARCHAR2(1);
    l_list            VARCHAR2(32767);
    lv_group_type     igs_pe_persid_group_v.group_type%TYPE;

  BEGIN
	  igf_aw_gen.set_org_id(NULL);

    errbuf             := NULL;
    retcode            := 0;
    g_log_tab_index    := 0;

    l_error := igf_ap_gen.get_lookup_meaning('IGF_AW_LOOKUPS_MSG','ERROR');

    -- validation for the start date
    IF p_start_date IS NOT NULL THEN
      BEGIN
        l_start_date := IGS_GE_DATE.IGSDATE(p_start_date);
      EXCEPTION
        WHEN OTHERS THEN
          fnd_message.set_name('IGF','IGF_SL_INVALID_START_DATE');
          add_log_table_process(NULL,l_error,fnd_message.get);
          l_terminate_flag := TRUE;
      END;
    ELSE
      l_start_date := TRUNC(SYSDATE);
    END IF;

    -- validation for the relationship code
    l_get_relation_code := NULL;
    OPEN  c_get_relation_code(p_rel_code);
    FETCH c_get_relation_code INTO l_get_relation_code;
    CLOSE c_get_relation_code;

    IF l_get_relation_code.relationship_cd IS NULL THEN
        fnd_message.set_name('IGF','IGF_SL_INVALID_REL_CODE');
        add_log_table_process(NULL,l_error,fnd_message.get);
        l_terminate_flag := TRUE;
    END IF;

    -- validation for the person id group
    l_chk_perid_grp := NULL;
    OPEN  c_chk_perid_grp(p_pergrp_id,'N');
    FETCH c_chk_perid_grp INTO l_chk_perid_grp;
    CLOSE c_chk_perid_grp;

    IF l_chk_perid_grp.group_cd IS NULL THEN
        fnd_message.set_name('IGS','IGS_FI_INVPERS_ID_GRP');
        add_log_table_process(NULL,l_error,fnd_message.get);
        l_terminate_flag := TRUE;
    END IF;

    -- if either of the above condition fails then log the message in log file and exit.
    IF l_terminate_flag = TRUE THEN
      print_log_process(l_start_date,l_chk_perid_grp.group_cd,p_rel_code,p_update);
      RETURN;
    END IF;

    -- THE MAIN LOOP STARTS HERE FOR FETCHING THE PERSONS IN THE PERSON ID GROUP
    -- Bug #5021084
    l_list := igf_ap_ss_pkg.get_pid(p_pergrp_id,lv_status,lv_group_type);

    --Bug #5021084. Passing Group ID if the group type is STATIC.
    IF lv_group_type = 'STATIC' THEN
      OPEN c_get_persons FOR ' SELECT party_id person_id, party_number person_number FROM hz_parties WHERE party_id IN (' || l_list  || ') ' USING p_pergrp_id;
    ELSIF lv_group_type = 'DYNAMIC' THEN
      OPEN c_get_persons FOR ' SELECT party_id person_id, party_number person_number FROM hz_parties WHERE party_id IN (' || l_list  || ') ';
    END IF;

    LOOP
      BEGIN
      SAVEPOINT sp1;
      l_person_id     := NULL;
      l_person_number := NULL;

      FETCH c_get_persons INTO l_person_id,l_person_number;
      EXIT WHEN c_get_persons%NOTFOUND OR c_get_persons%NOTFOUND IS NULL;
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        l_debug_str := 'Person Number is:' || l_person_number;
      END IF;
      l_msg_count     := NULL;
      l_msg_number    := NULL;
      l_return_status := NULL;
      -- check if the person has an active lender already
      lv_row_id := NULL;
      l_clprl_id := NULL;
      l_chk_pref_lender := NULL;
      OPEN  c_chk_pref_lender(l_person_id);
      FETCH c_chk_pref_lender INTO l_chk_pref_lender;
      CLOSE c_chk_pref_lender;

      IF l_chk_pref_lender.start_date IS NULL THEN
       l_message := NULL;
       -- insert a record into the igf_sl_cl_pref_lenders table as no active lender exists
       BEGIN
        igf_sl_cl_pref_lenders_pkg.insert_row (
                          x_mode                              => 'R',
                          x_clprl_id                          => l_clprl_id,
                          x_rowid                             => lv_row_id,
                          x_msg_count                         => l_msg_count,
                          x_msg_data                          => l_msg_number,
                          x_return_status                     => l_return_status,
                          x_person_id                         => l_person_id,
                          x_start_date                        => l_start_date,
                          x_relationship_cd                   => p_rel_code,
                          x_end_date                          => NULL
                         );
         -- here exception will be raised if the lender setup is invalid after performing the above operation
         -- the validation is done in the TBH of igf_sl_cl_pref_lenders
         -- if no exception is raised then add the sucessful message to the log
         fnd_message.set_name('IGF','IGF_SL_CL_LEND_ADD');
         fnd_message.set_token('PERS_NUM',l_person_number);
         fnd_message.set_token('REL_CODE',p_rel_code);
         add_log_table_process(l_person_number,'',fnd_message.get);
         check_for_todo(l_person_id);
       EXCEPTION WHEN OTHERS THEN
        -- check which messgae is there in the stack and display the appropriate message
         fnd_message.parse_encoded(fnd_message.get_encoded,l_app,l_message);
         IF l_message IS NOT NULL THEN
           fnd_message.set_name(l_app,l_message);
           add_log_table_process(l_person_number,l_error,fnd_message.get);
           fnd_message.set_name('IGF','IGF_SL_SKIPPING');
           add_log_table_process(NULL,l_error,fnd_message.get);
           ROLLBACK TO sp1;
           l_error_flag := TRUE;
         END IF;
       END;

      ELSE
         IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           l_debug_str := l_debug_str || ' Person has a active lender relationship';
         END IF;
        -- means already the active lender exists
        IF l_chk_pref_lender.relationship_cd = p_rel_code THEN
          -- means same active relationship already exists
          fnd_message.set_name('IGF','IGF_SL_CL_LEND_EXISTS');
          add_log_table_process(l_person_number,l_error,fnd_message.get);
          fnd_message.set_name('IGF','IGF_SL_SKIPPING');
          add_log_table_process(NULL,l_error,fnd_message.get);
          l_error_flag := TRUE;
        ELSE
          IF p_update = 'N' THEN
            -- log a message that existing relationship cannot be updated
            fnd_message.set_name('IGF','IGF_SL_CL_LEND_NOT_ADD');
            add_log_table_process(l_person_number,l_error,fnd_message.get);
            fnd_message.set_name('IGF','IGF_SL_SKIPPING');
            add_log_table_process(NULL,l_error,fnd_message.get);
            l_error_flag := TRUE;
          ELSE
            IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
              l_debug_str := l_debug_str || ' Previous record has to be updated';
            END IF;
            l_message := NULL;
           -- Previous relationship record has to be end dated and a new record has to be added .
            BEGIN
              igf_sl_cl_pref_lenders_pkg.update_row (
                          x_mode                              => 'R',
                          x_clprl_id                          => l_chk_pref_lender.clprl_id,
                          x_rowid                             => l_chk_pref_lender.row_id,
                          x_msg_count                         => l_msg_count,
                          x_msg_data                          => l_msg_number,
                          x_return_status                     => l_return_status,
                          x_person_id                         => l_person_id,
                          x_start_date                        => l_chk_pref_lender.start_date,
                          x_relationship_cd                   => l_chk_pref_lender.relationship_cd,
                          x_end_date                          => TRUNC(l_start_date-1)
                         );
              igf_sl_cl_pref_lenders_pkg.insert_row (
                          x_mode                              => 'R',
                          x_rowid                             => lv_row_id,
                          x_clprl_id                          => l_clprl_id,
                          x_msg_count                         => l_msg_count,
                          x_msg_data                          => l_msg_number,
                          x_return_status                     => l_return_status,
                          x_person_id                         => l_person_id,
                          x_start_date                        => l_start_date,
                          x_relationship_cd                   => p_rel_code,
                          x_end_date                          => NULL
                         );
                -- here exception will be raised if the lender setup is invalid after performing the above operation
                -- the validation is done in the TBH of igf_sl_cl_pref_lenders
                -- if no exception is raised then add the sucessful message to the log
               fnd_message.set_name('IGF','IGF_SL_CL_LEND_ADD');
               fnd_message.set_token('PERS_NUM',l_person_number);
               fnd_message.set_token('REL_CODE',p_rel_code);
               add_log_table_process(l_person_number,'',fnd_message.get);

               check_for_todo(l_person_id);
            EXCEPTION WHEN OTHERS THEN
            -- check which messgae is there in the stack and display the appropriate message
              fnd_message.parse_encoded(fnd_message.get_encoded,l_app,l_message);
              IF l_message IS NOT NULL THEN
                fnd_message.set_name(l_app,l_message);
                add_log_table_process(l_person_number,l_error,fnd_message.get);
                fnd_message.set_name('IGF','IGF_SL_SKIPPING');
                add_log_table_process(NULL,l_error,fnd_message.get);
                ROLLBACK TO sp1;
                l_error_flag := TRUE;
              END IF;
            END;

          END IF;
        END IF;
      END IF;

      IF l_error_flag = TRUE THEN
        l_error_flag := FALSE;
        l_error_record_cnt := l_error_record_cnt + 1;
      ELSE
        l_success_record_cnt := l_success_record_cnt + 1;
      END IF;
      -- log the messgae in the logging framework
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,'igf.plsql.igf_sl_pref_lender.main.debug',l_debug_str);
      END IF;
      l_debug_str := NULL;

      EXCEPTION
       WHEN OTHERS THEN
         l_debug_str := NULL;
         l_error_flag := FALSE;
         fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXP');
         fnd_message.set_token('NAME','IGF_SL_PREF_LENDER.MAIN');
         add_log_table_process(l_person_number,l_error,fnd_message.get || ' ' || SQLERRM);
         ROLLBACK TO sp1;
      END;
      -- commit the sucessful record
      COMMIT;
    END LOOP;
    CLOSE c_get_persons;

  -- if no record is processed then display the following message
    IF l_success_record_cnt = 0 AND l_error_record_cnt = 0 THEN
       fnd_message.set_name('IGF','IGF_DB_NO_PER_GRP');
       add_log_table_process(NULL,l_error,fnd_message.get);
    END IF;

    -- CALL THE PRINT LOG PROCESS
    print_log_process(l_start_date,l_chk_perid_grp.group_cd,p_rel_code,p_update);

  EXCEPTION
        WHEN others THEN
        IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'igf.plsql.igf_sl_pref_lender.main.exception',SQLERRM);
        END IF;
        ROLLBACK;
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_SL_PREF_LENDER.MAIN');
        retcode := 2;
        errbuf  := fnd_message.get;
        igs_ge_msg_stack.conc_exception_hndl;

  END main;

END igf_sl_pref_lender;

/
