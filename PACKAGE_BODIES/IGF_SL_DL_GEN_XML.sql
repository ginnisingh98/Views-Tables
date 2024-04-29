--------------------------------------------------------
--  DDL for Package Body IGF_SL_DL_GEN_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_DL_GEN_XML" AS
/* $Header: IGFSL25B.pls 120.8 2006/08/08 06:59:59 veramach noship $ */

------------------------------------------------------------------------------------------------
--
-- Process Flow
-- main()
--  --> 1.validate parameters
--  --> 2.process_loan()
--      --> 1.igf_sl_dl_validation.cod_loan_validations()
--      --> 2.insert_lor_loc() for valid loans
--  --> check for valid loans in igf_sl_lor_loc_all for document_id
--  --> if yes then submit_xml_event()
--      --> 1.XML Gatway Standard to create xml
--      --> 2.store_xml() - workflow process
--                 --> 1.check for CLOB length, proper document id,
--                      proper submission of request if okay then
--                 --> 2.insert into igf_sl_cod_doc_dtls
--                 --> 3.submit concurrent job IGFSLJ19-print_xml()
--                      --> 1. edit_clob()
--                      --> 2. update_status(), update igf_sl_cod_doc_dtls
--                      --> 3. print_out_xml()
------------------------------------------------------------------------------------------------
gv_document_id_txt VARCHAR2(30);
gv_dl_version      VARCHAR2(30);
gn_new_base_id     NUMBER;
gn_old_base_id     NUMBER;

TYPE loan_ley_record IS RECORD
               (  orig_fee_pct_num        NUMBER,
                  int_reb_pct_num         NUMBER,
                  pnote_print_code        VARCHAR2(30),
                  disclosure_print_code   VARCHAR2(30),
                  grade_level_code        VARCHAR2(30),
                  fin_awd_begin_date      DATE,
                  fin_awd_end_date        DATE,
                  acad_yr_begin_date      DATE,
                  acad_yr_end_date        DATE
               );

TYPE loan_key_list IS TABLE OF loan_ley_record;
loan_key_rec  loan_key_list;

ln_count      NUMBER;


PROCEDURE edit_clob(p_document_id_txt VARCHAR2, p_xml_clob OUT NOCOPY CLOB,p_rowid OUT NOCOPY ROWID)
IS

    CURSOR cur_doc_dtls (p_document_id_txt VARCHAR2)
    IS
    SELECT rowid ,document_id_txt,outbound_doc
    FROM   igf_sl_cod_doc_dtls
    WHERE  document_id_txt = p_document_id_txt
      AND  doc_status = 'R'
    FOR UPDATE OF outbound_doc;

    doc_dtls_rec            cur_doc_dtls%ROWTYPE;
    lc_xmldoc               CLOB;
    lv_buffer               VARCHAR2(32767);
    ln_amount               INTEGER;
    ln_len                  NUMBER;
    ln_offset               NUMBER;
    ln_start_pos            INTEGER;
    ln_end_pos              INTEGER;
    lv_document_id_txt      VARCHAR2(30);

BEGIN

    OPEN  cur_doc_dtls(p_document_id_txt);
    FETCH cur_doc_dtls INTO p_rowid,lv_document_id_txt, lc_xmldoc;
    IF cur_doc_dtls%NOTFOUND THEN
       CLOSE cur_doc_dtls;
       fnd_message.set_name('IGF','IGF_SL_DL_PRINT_DOC_FAIL');
       fnd_file.put_line(fnd_file.log, fnd_message.get);
       RETURN;
    ELSIF cur_doc_dtls%FOUND THEN
       CLOSE cur_doc_dtls;
       OPEN  cur_doc_dtls(p_document_id_txt);
       FETCH cur_doc_dtls INTO p_rowid,lv_document_id_txt, p_xml_clob;
       CLOSE cur_doc_dtls;
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.edit_clob.debug','p doc id is valid');
    END IF;

    -- Editing LoB
    ln_amount := DBMS_LOB.GETLENGTH(p_xml_clob);
    DBMS_LOB.ERASE(p_xml_clob,ln_amount,1);
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.edit_clob.debug','CLOB ln_amount ' || ln_amount);
    END IF;

    -- find doc between first tag and end of root tag
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.edit_clob.debug','Find start and end positions ');
    END IF;

    ln_start_pos :=  DBMS_LOB.INSTR(lc_xmldoc,'<CommonRecord',1,1);
    ln_end_pos   :=  DBMS_LOB.INSTR(lc_xmldoc,'</CR>',1,1);

    DBMS_LOB.COPY(p_xml_clob, lc_xmldoc, ln_end_pos-ln_start_pos, 1, ln_start_pos);
    -- DBMS_LOB.COPY(lobd, lobs, amt, dest_offset, src_offset);
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.edit_clob.debug','End of printing ');
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_dl_gen_xml.edit_clob.exception','Exception:'||SQLERRM);
    END IF;
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_SL_DL_GEN_XML.EDIT_CLOB');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
END edit_clob;

PROCEDURE update_status(p_document_id_txt VARCHAR2)
IS

  CURSOR cur_cod_loans (p_document_id_txt VARCHAR2)
  IS
  SELECT loc.loan_id FROM igf_sl_lor_loc_all loc
  WHERE  loc.document_id_txt = p_document_id_txt;

  CURSOR cur_cod_disb (p_document_id_txt VARCHAR2)
  IS
  SELECT disb.award_id, disb.disb_num, disb.disb_seq_num
  FROM   igf_aw_db_cod_dtls disb
  WHERE  disb.document_id_txt = p_document_id_txt;

  CURSOR cur_sys_loans (p_loan_id NUMBER)
  IS
  SELECT loan.* FROM igf_sl_loans loan
  WHERE  loan.loan_id = p_loan_id;

  CURSOR cur_sys_disb (p_award_id NUMBER,p_disb_num NUMBER, p_disb_seq NUMBER)
  IS
  SELECT disb.rowid row_id,disb.* FROM igf_aw_db_chg_dtls disb
  WHERE  disb.award_id = p_award_id  AND
         disb.disb_num = p_disb_num  AND
         disb.disb_seq_num = p_disb_seq;
BEGIN

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
    fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.update_status.debug','First doc id ' || p_document_id_txt);
  END IF;

  FOR cod_rec IN cur_cod_loans(p_document_id_txt)
  LOOP
     FOR sys_rec IN cur_sys_loans (cod_rec.loan_id)
     LOOP
        IF sys_rec.loan_status = 'A' THEN
           sys_rec.loan_chg_status      := 'S';
           sys_rec.loan_chg_status_date := TRUNC(SYSDATE);
        ELSIF sys_rec.loan_status = 'G' THEN
           sys_rec.loan_status      := 'S';
           sys_rec.loan_status_date := TRUNC(SYSDATE);
        END IF;
        igf_sl_loans_pkg.update_row(x_rowid                => sys_rec.row_id,
                                    x_loan_id              => sys_rec.loan_id,
                                    x_award_id             => sys_rec.award_id,
                                    x_seq_num              => sys_rec.seq_num,
                                    x_loan_number          => sys_rec.loan_number,
                                    x_loan_per_begin_date  => sys_rec.loan_per_begin_date,
                                    x_loan_per_end_date    => sys_rec.loan_per_end_date,
                                    x_loan_status          => sys_rec.loan_status,
                                    x_loan_status_date     => sys_rec.loan_status_date,
                                    x_loan_chg_status      => sys_rec.loan_chg_status,
                                    x_loan_chg_status_date => sys_rec.loan_chg_status_date,
                                    x_active               => sys_rec.active,
                                    x_active_date          => sys_rec.active_date,
                                    x_borw_detrm_code      => sys_rec.borw_detrm_code,
                                    x_mode                 => 'R',
                                    x_legacy_record_flag   => sys_rec.legacy_record_flag,
                                    x_external_loan_id_txt => sys_rec.external_loan_id_txt,
                                    x_called_from          => NULL);
     END LOOP;
  END LOOP;

  FOR cod_rec IN cur_cod_disb(p_document_id_txt)
  LOOP
     FOR sys_rec IN cur_sys_disb(cod_rec.award_id,cod_rec.disb_num,cod_rec.disb_seq_num)
     LOOP

        sys_rec.disb_status      := 'S';
        sys_rec.disb_status_date := TRUNC(SYSDATE);

        igf_aw_db_chg_dtls_pkg.update_row(x_rowid                => sys_rec.row_id,
                                          x_award_id             => sys_rec.award_id,
                                          x_disb_num             => sys_rec.disb_num,
                                          x_disb_seq_num         => sys_rec.disb_seq_num,
                                          x_disb_accepted_amt    => sys_rec.disb_accepted_amt,
                                          x_orig_fee_amt         => sys_rec.orig_fee_amt,
                                          x_disb_net_amt         => sys_rec.disb_net_amt,
                                          x_disb_date            => sys_rec.disb_date,
                                          x_disb_activity        => sys_rec.disb_activity,
                                          x_disb_status          => sys_rec.disb_status,
                                          x_disb_status_date     => sys_rec.disb_status_date,
                                          x_disb_rel_flag        => sys_rec.disb_rel_flag,
                                          x_first_disb_flag      => sys_rec.first_disb_flag,
                                          x_interest_rebate_amt  => sys_rec.interest_rebate_amt,
                                          x_disb_conf_flag       => sys_rec.disb_conf_flag,
                                          x_pymnt_prd_start_date => sys_rec.pymnt_prd_start_date,
                                          x_note_message         => sys_rec.note_message,
                                          x_batch_id_txt         => sys_rec.batch_id_txt,
                                          x_ack_date             => sys_rec.ack_date,
                                          x_booking_id_txt       => sys_rec.booking_id_txt,
                                          x_booking_date         => sys_rec.booking_date,
                                          x_mode                 => 'R'
                                          );
     END LOOP;
  END LOOP;

  EXCEPTION
  WHEN OTHERS THEN
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_dl_gen_xml.update_status.exception','Exception:'||SQLERRM);
    END IF;
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_SL_DL_GEN_XML.UPDATE_STATUS');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
END update_status;

PROCEDURE print_out_xml(p_xml_clob CLOB)
IS
    lv_myclob_text    VARCHAR2(32767);
    ln_len            NUMBER;
    ln_offset         NUMBER;
    ln_amount         INTEGER;
BEGIN

    ln_len    := dbms_lob.getlength(p_xml_clob);
    ln_offset := 1;
    ln_amount := 1023; -- changed from 32767 to 1023 so that it can handle upto Fixed-width-32-byte CLOBs objects (32767/1023 = 32) Bug 4323926

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.print_out_xml.debug','ln_len ' || ln_len);
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.print_out_xml.debug','ln_offset ' || ln_offset);
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.print_out_xml.debug','ln_amount ' || ln_amount);
    END IF;

    WHILE (ln_len > 0) LOOP
        lv_myclob_text := DBMS_LOB.SUBSTR (p_xml_clob, ln_amount, ln_offset);
        fnd_file.put(fnd_file.output,lv_myclob_text);
        ln_amount := LENGTH(lv_myclob_text); -- this will handle any Character Set. But to be optimistic ln_amount is initialized to 1023 instead of 32767. Bug 4323926
        IF ln_amount = 0 THEN
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.print_out_xml.debug','ln_amount is Zero after DBMS_LOB.SUBSTR, ln_len = ' || ln_len);
          END IF;
          EXIT;
        END IF;
        ln_len := ln_len - ln_amount;
        ln_offset := ln_offset + ln_amount;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.print_out_xml.debug','Loop ln_len ' || ln_len);
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.print_out_xml.debug','Loop ln_offset ' || ln_offset);
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.print_out_xml.debug','Loop ln_amount ' || ln_amount);
        END IF;
    END LOOP;
   fnd_file.new_line(fnd_file.output,1);

  EXCEPTION
  WHEN OTHERS THEN
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_dl_gen_xml.print_out_xml.exception','Exception:'||SQLERRM);
    END IF;
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_SL_DL_GEN_XML.PRINT_OUT_XML');
    igs_ge_msg_stack.add;
    app_exception.raise_exception;
END print_out_xml;

PROCEDURE insert_lor_loc(p_loan_rec      cur_pick_loans%ROWTYPE,
                         p_source_id     VARCHAR2,
                         student_dtl_rec igf_sl_gen.person_dtl_rec,
                         parent_dtl_rec  igf_sl_gen.person_dtl_rec,
                         p_isir_ssn      VARCHAR2, p_isir_dob     DATE,
                         p_isir_lname    VARCHAR2, p_isir_dep     VARCHAR2,
                         p_isir_tnum     NUMBER,   p_acad_begin   DATE,
                         p_acad_end      DATE, p_s_phone VARCHAR2, p_p_phone VARCHAR2)
IS

  CURSOR cur_setup (p_cal_type VARCHAR2, p_seq_number NUMBER) IS
  SELECT response_option_code, int_rebate
  FROM   igf_sl_dl_setup_all
  WHERE  ci_cal_type        = p_cal_type
    AND  ci_sequence_number = p_seq_number;

  setup_rec cur_setup%ROWTYPE;

  CURSOR cur_loan_oldinfo (p_loan_id NUMBER) IS
  SELECT loc.*
  FROM   igf_sl_lor_loc_all loc
  WHERE  loc.loan_id = p_loan_id;

  loan_oldinfo_rec cur_loan_oldinfo%ROWTYPE;

  CURSOR cur_disb_rec (p_award_id NUMBER) IS
  SELECT chg.*
  FROM   igf_aw_db_chg_dtls chg
  WHERE  award_id = p_award_id
    --AND  disb_status = 'G'; -- Ready to Send (commented bcz of the bug 4105689)
    AND  disb_status = 'G'; -- Ready to Send (uncommented again bcz of another bug 4390096)

  lv_elig_heal             VARCHAR2(30);
  lv_elig_dep              VARCHAR2(30);
  lv_rowid                 ROWID;
  ln_loan_key              NUMBER;
  lb_add_newkey            BOOLEAN;
  lv_loan_status           VARCHAR2(30);
  ld_loan_status_date      DATE;
  lv_loan_chg_status       VARCHAR2(30);
  ld_loan_chg_status_date  DATE;


BEGIN

   OPEN  cur_setup(p_loan_rec.ci_cal_type,p_loan_rec.ci_sequence_number);
   FETCH cur_setup INTO setup_rec;
   CLOSE cur_setup;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug',setup_rec.response_option_code);
   END IF;

   OPEN  cur_loan_oldinfo(p_loan_rec.loan_id);
   FETCH cur_loan_oldinfo INTO loan_oldinfo_rec;
   CLOSE cur_loan_oldinfo;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN

      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug','start of modified values for Loan ID> ' || loan_oldinfo_rec.loan_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug',loan_oldinfo_rec.b_chg_birth_date);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug',loan_oldinfo_rec.b_chg_last_name);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug',loan_oldinfo_rec.b_chg_ssn);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug',loan_oldinfo_rec.loan_number);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug',loan_oldinfo_rec.p_date_of_birth);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug',loan_oldinfo_rec.p_last_name);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug',loan_oldinfo_rec.p_ssn);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug',loan_oldinfo_rec.s_chg_birth_date);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug',loan_oldinfo_rec.s_chg_last_name);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug',loan_oldinfo_rec.s_chg_ssn);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug',loan_oldinfo_rec.s_date_of_birth);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug','** last name > ' || loan_oldinfo_rec.s_last_name);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug',loan_oldinfo_rec.s_ssn);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug',parent_dtl_rec.p_date_of_birth);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug',parent_dtl_rec.p_last_name);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug',parent_dtl_rec.p_ssn);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug',student_dtl_rec.p_date_of_birth);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug',student_dtl_rec.p_last_name);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug',student_dtl_rec.p_ssn);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug','end of modified values');
   END IF;


   IF loan_oldinfo_rec.loan_number IS NOT NULL THEN
     -- Check for identifier information change?
     IF loan_oldinfo_rec.s_ssn <> student_dtl_rec.p_ssn THEN
        loan_oldinfo_rec.s_chg_ssn := student_dtl_rec.p_ssn;
     END IF;
     IF loan_oldinfo_rec.s_date_of_birth <> student_dtl_rec.p_date_of_birth  THEN
        loan_oldinfo_rec.s_chg_birth_date := student_dtl_rec.p_date_of_birth;
     END IF;
     IF UPPER(loan_oldinfo_rec.s_last_name) <> UPPER(student_dtl_rec.p_last_name) THEN
        loan_oldinfo_rec.s_chg_last_name := student_dtl_rec.p_last_name;

     END IF;
     IF p_loan_rec.fed_fund_code ='DLP' THEN
       IF loan_oldinfo_rec.p_ssn <> parent_dtl_rec.p_ssn THEN
          loan_oldinfo_rec.b_chg_ssn := parent_dtl_rec.p_ssn;
       END IF;
       IF loan_oldinfo_rec.p_date_of_birth <> parent_dtl_rec.p_date_of_birth  THEN
          loan_oldinfo_rec.b_chg_birth_date := parent_dtl_rec.p_date_of_birth;
       END IF;
       IF UPPER(loan_oldinfo_rec.p_last_name) <> UPPER(parent_dtl_rec.p_last_name) THEN
          loan_oldinfo_rec.b_chg_last_name := parent_dtl_rec.p_last_name;
       END IF;
     END IF;
   END IF;

   --
   -- Loan Key derivation
   --
   gn_old_base_id := gn_new_base_id;
   gn_new_base_id := p_loan_rec.base_id;

   IF gn_old_base_id =  gn_new_base_id THEN
      --
      -- use same PL/SQL table data
      --
      NULL;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug','loan key determine');
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug','gn_new_base_id  ' || gn_new_base_id );
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug','gn_old_base_id  ' || gn_old_base_id );
      END IF;
   ELSE
      --
      -- re-initialize the PL/SQL table
      --
      loan_key_rec.DELETE;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug','loan key determine');
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug','gn_new_base_id  ' || gn_new_base_id );
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug','gn_old_base_id  ' || gn_old_base_id );
      END IF;
   END IF;

   ln_count := loan_key_rec.COUNT;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug','loan key determine ln_count ' || ln_count);
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug','loan key gn_new_base_id = gn_old_base_id ');
   END IF;

   IF ln_count = 0 THEN
     loan_key_rec.EXTEND;
     ln_count := loan_key_rec.COUNT;
     loan_key_rec(ln_count).orig_fee_pct_num         := p_loan_rec.orig_fee_perct;
     loan_key_rec(ln_count).int_reb_pct_num          := setup_rec.int_rebate;
     loan_key_rec(ln_count).pnote_print_code         := p_loan_rec.pnote_print_ind;
     loan_key_rec(ln_count).disclosure_print_code    := p_loan_rec.disclosure_print_ind;
     loan_key_rec(ln_count).grade_level_code         := p_loan_rec.grade_level_code;
     loan_key_rec(ln_count).fin_awd_begin_date       := p_loan_rec.loan_per_begin_date;
     loan_key_rec(ln_count).fin_awd_end_date         := p_loan_rec.loan_per_end_date;
     loan_key_rec(ln_count).acad_yr_begin_date       := p_acad_begin;
     loan_key_rec(ln_count).acad_yr_end_date         := p_acad_end;
     ln_loan_key                                     := ln_count;
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug','loan key ' || ln_loan_key);
    END IF;
   END IF;

   IF ln_count >= 1 THEN
      -- check if the data is same, else insert new loan key
      FOR i IN 1..ln_count LOOP
         IF loan_key_rec(i).orig_fee_pct_num      <> p_loan_rec.orig_fee_perct   OR
            loan_key_rec(i).int_reb_pct_num       <> setup_rec.int_rebate   OR
            loan_key_rec(i).pnote_print_code      <> p_loan_rec.pnote_print_ind   OR
            loan_key_rec(i).disclosure_print_code <> p_loan_rec.disclosure_print_ind   OR
            loan_key_rec(i).grade_level_code      <> p_loan_rec.grade_level_code OR
            loan_key_rec(i).fin_awd_begin_date    <> p_loan_rec.loan_per_begin_date   OR
            loan_key_rec(i).fin_awd_end_date      <> p_loan_rec.loan_per_end_date   OR
            loan_key_rec(i).acad_yr_begin_date    <> p_acad_begin   OR
            loan_key_rec(i).acad_yr_end_date      <> p_acad_end
          THEN
            lb_add_newkey := TRUE;
          ELSE
            lb_add_newkey := FALSE;
            ln_loan_key   := i;
            EXIT;
          END IF;
      END LOOP;
      IF  lb_add_newkey  THEN
            loan_key_rec.EXTEND;
            ln_loan_key  := loan_key_rec.COUNT;
            loan_key_rec(ln_loan_key).orig_fee_pct_num         := p_loan_rec.orig_fee_perct;
            loan_key_rec(ln_loan_key).int_reb_pct_num          := setup_rec.int_rebate;
            loan_key_rec(ln_loan_key).pnote_print_code         := p_loan_rec.pnote_print_ind;
            loan_key_rec(ln_loan_key).disclosure_print_code    := p_loan_rec.disclosure_print_ind;
            loan_key_rec(ln_loan_key).grade_level_code         := p_loan_rec.grade_level_code;
            loan_key_rec(ln_loan_key).fin_awd_begin_date       := p_loan_rec.loan_per_begin_date;
            loan_key_rec(ln_loan_key).fin_awd_end_date         := p_loan_rec.loan_per_end_date;
            loan_key_rec(ln_loan_key).acad_yr_begin_date       := p_acad_begin;
            loan_key_rec(ln_loan_key).acad_yr_end_date         := p_acad_end;
      END IF;
   END IF;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug','loan key = ' || ln_loan_key);
   END IF;

   IF ln_loan_key > 99 THEN
      fnd_message.set_name('IGF','IGF_SL_COD_99_KEYS');
      fnd_message.set_token('LOAN_NUMBER',p_loan_rec.loan_number);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      RETURN;
   END IF;

   lv_rowid := NULL;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug','inserting lor loc  ');
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug','inserting lor loc p_p_phone ' || p_p_phone);
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug','inserting lor loc p_s_phone ' || p_s_phone);
   END IF;
   --
   -- update change identifiers and new identifiers
   --
   IF p_loan_rec.unsub_elig_for_heal  IS NULL THEN
      lv_elig_heal := 'false';
   ELSIF p_loan_rec.unsub_elig_for_heal = 'N' THEN
      lv_elig_heal  := 'false';
   ELSIF p_loan_rec.unsub_elig_for_heal = 'Y' THEN
      lv_elig_heal  := 'true';
   END IF;

   IF p_loan_rec.unsub_elig_for_depnt IS NULL THEN
      lv_elig_dep := 'false';
   ELSIF p_loan_rec.unsub_elig_for_depnt = 'N' THEN
      lv_elig_dep := 'false';
   ELSIF p_loan_rec.unsub_elig_for_depnt = 'Y' THEN
      lv_elig_dep := 'true';
   END IF;

   lv_loan_status           := p_loan_rec.loan_status;
   ld_loan_status_date      := p_loan_rec.loan_status_date;
   lv_loan_chg_status       := p_loan_rec.loan_chg_status;
   ld_loan_chg_status_date  := p_loan_rec.loan_chg_status_date;

   IF p_loan_rec.loan_status = 'A' THEN
         lv_loan_chg_status      := 'S';
         ld_loan_chg_status_date := TRUNC(SYSDATE);
   ELSIF p_loan_rec.loan_status = 'G' THEN
         lv_loan_status      := 'S';
         ld_loan_status_date := TRUNC(SYSDATE);
   END IF;

   igf_sl_lor_loc_pkg.add_row(x_rowid                        => lv_rowid,
                              x_loan_id                      => p_loan_rec.loan_id,
                              x_origination_id               => p_loan_rec.origination_id,
                              x_loan_number                  => p_loan_rec.loan_number,
                              x_loan_type                    => p_loan_rec.fed_fund_code,
                              x_loan_amt_offered             => p_loan_rec.offered_amt,
                              x_loan_amt_accepted            => p_loan_rec.accepted_amt,
                              x_loan_per_begin_date          => p_loan_rec.loan_per_begin_date,
                              x_loan_per_end_date            => p_loan_rec.loan_per_end_date,
                              x_acad_yr_begin_date           => p_acad_begin,
                              x_acad_yr_end_date             => p_acad_end,
                              x_loan_status                  => lv_loan_status,
                              x_loan_status_date             => ld_loan_status_date,
                              x_loan_chg_status              => lv_loan_chg_status,
                              x_loan_chg_status_date         => ld_loan_chg_status_date,
                              x_req_serial_loan_code         => NULL, -- FFELP
                              x_act_serial_loan_code         => NULL, -- FFELP
                              x_active                       => p_loan_rec.active,
                              x_active_date                  => p_loan_rec.active_date,
                              x_sch_cert_date                => NULL, -- FFELP
                              x_orig_status_flag             => p_loan_rec.orig_status_flag,
                              x_orig_batch_id                => p_loan_rec.orig_batch_id,
                              x_orig_batch_date              => TRUNC(SYSDATE),
                              x_chg_batch_id                 => p_loan_rec.chg_batch_id,
                              x_orig_ack_date                => p_loan_rec.orig_ack_date,
                              x_credit_override              => p_loan_rec.credit_override,
                              x_credit_decision_date         => p_loan_rec.credit_decision_date,
                              x_pnote_delivery_code          => p_loan_rec.pnote_delivery_code,
                              x_pnote_status                 => p_loan_rec.pnote_status,
                              x_pnote_status_date            => p_loan_rec.pnote_status_date,
                              x_pnote_id                     => p_loan_rec.pnote_id,
                              x_pnote_print_ind              => p_loan_rec.pnote_print_ind,
                              x_pnote_accept_amt             => p_loan_rec.pnote_accept_amt,
                              x_pnote_accept_date            => p_loan_rec.pnote_accept_date,
                              x_p_signature_code             => p_loan_rec.p_signature_code,
                              x_p_signature_date             => p_loan_rec.p_signature_date,
                              x_s_signature_code             => p_loan_rec.s_signature_code,
                              x_unsub_elig_for_heal          => lv_elig_heal,
                              x_disclosure_print_ind         => p_loan_rec.disclosure_print_ind,
                              x_orig_fee_perct               => p_loan_rec.orig_fee_perct,
                              x_borw_confirm_ind             => p_loan_rec.borw_confirm_ind,
                              x_borw_interest_ind            => p_loan_rec.borw_interest_ind,
                              x_unsub_elig_for_depnt         => lv_elig_dep,
                              x_guarantee_amt                => NULL, -- FFELP
                              x_guarantee_date               => NULL, -- FFELP
                              x_guarnt_adj_ind               => NULL, -- FFELP
                              x_guarnt_amt_redn_code         => NULL, -- FFELP
                              x_guarnt_status_code           => NULL, -- FFELP
                              x_guarnt_status_date           => NULL, -- FFELP
                              x_lend_apprv_denied_code       => NULL, -- FFELP
                              x_lend_apprv_denied_date       => NULL, -- FFELP
                              x_lend_status_code             => NULL, -- FFELP
                              x_lend_status_date             => NULL, -- FFELP
                              x_grade_level_code             => p_loan_rec.grade_level_code,
                              x_enrollment_code              => p_loan_rec.enrollment_code,
                              x_anticip_compl_date           => NULL, -- FFELP
                              x_borw_lender_id               => NULL, -- FFELP
                              x_duns_borw_lender_id          => NULL, -- FFELP
                              x_guarantor_id                 => NULL, -- FFELP
                              x_duns_guarnt_id               => NULL, -- FFELP
                              x_prc_type_code                => NULL, -- FFELP
                              x_rec_type_ind                 => NULL, -- FFELP
                              x_cl_loan_type                 => NULL, -- FFELP
                              x_cl_seq_number                => NULL, -- FFELP
                              x_last_resort_lender           => NULL, -- FFELP
                              x_lender_id                    => NULL, -- FFELP
                              x_duns_lender_id               => NULL, -- FFELP
                              x_lend_non_ed_brc_id           => NULL, -- FFELP
                              x_recipient_id                 => NULL, -- FFELP
                              x_recipient_type               => NULL, -- FFELP
                              x_duns_recip_id                => NULL, -- FFELP
                              x_recip_non_ed_brc_id          => NULL, -- FFELP
                              x_cl_rec_status                => NULL, -- FFELP
                              x_cl_rec_status_last_update    => NULL, -- FFELP
                              x_alt_prog_type_code           => NULL, -- FFELP
                              x_alt_appl_ver_code            => NULL, -- FFELP
                              x_borw_outstd_loan_code        => NULL, -- FFELP
                              x_mpn_confirm_code             => NULL, -- FFELP
                              x_resp_to_orig_code            => NULL, -- FFELP
                              x_appl_loan_phase_code         => NULL, -- FFELP
                              x_appl_loan_phase_code_chg     => NULL, -- FFELP
                              x_tot_outstd_stafford          => NULL, -- FFELP
                              x_tot_outstd_plus              => NULL, -- FFELP
                              x_alt_borw_tot_debt            => NULL, -- FFELP
                              x_act_interest_rate            => NULL, -- FFELP
                              x_service_type_code            => NULL, -- FFELP
                              x_rev_notice_of_guarnt         => NULL, -- FFELP
                              x_sch_refund_amt               => NULL, -- FFELP
                              x_sch_refund_date              => NULL, -- FFELP
                              x_uniq_layout_vend_code        => NULL, -- FFELP
                              x_uniq_layout_ident_code       => NULL, -- FFELP
                              x_p_person_id                  => p_loan_rec.p_person_id,
                              x_p_ssn                        => NVL(loan_oldinfo_rec.p_ssn,parent_dtl_rec.p_ssn),                    -- attribute
                              x_p_ssn_chg_date               => NULL,  -- FFELP
                              x_p_last_name                  => UPPER(NVL(loan_oldinfo_rec.p_last_name,parent_dtl_rec.p_last_name)),-- attribute
                              x_p_first_name                 => UPPER(parent_dtl_rec.p_first_name),
                              x_p_middle_name                => UPPER(parent_dtl_rec.p_middle_name),
                              x_p_permt_addr1                => UPPER(parent_dtl_rec.p_permt_addr1),
                              x_p_permt_addr2                => UPPER(parent_dtl_rec.p_permt_addr2),
                              x_p_permt_city                 => UPPER(parent_dtl_rec.p_permt_city),
                              x_p_permt_state                => UPPER(parent_dtl_rec.p_permt_state),
                              x_p_permt_zip                  => UPPER(parent_dtl_rec.p_permt_zip),
                              x_p_permt_addr_chg_date        => NULL, -- FFELP
                              x_p_permt_phone                => p_p_phone,
                              x_p_email_addr                 => UPPER(parent_dtl_rec.p_email_addr),
                              x_p_date_of_birth              => NVL(loan_oldinfo_rec.p_date_of_birth,parent_dtl_rec.p_date_of_birth),     -- attribute
                              x_p_dob_chg_date               => NULL, -- FFELP
                              x_p_license_num                => parent_dtl_rec.p_license_num,
                              x_p_license_state              => UPPER(parent_dtl_rec.p_license_state),
                              x_p_citizenship_status         => parent_dtl_rec.p_citizenship_status,
                              x_p_alien_reg_num              => NULL, -- FFELP
                              x_p_default_status             => p_loan_rec.p_default_status,
                              x_p_foreign_postal_code        => NULL, -- FFELP
                              x_p_state_of_legal_res         => NULL, -- FFELP
                              x_p_legal_res_date             => NULL, -- FFELP
                              x_s_ssn                        => NVL(loan_oldinfo_rec.s_ssn,student_dtl_rec.p_ssn),                           -- attribute
                              x_s_ssn_chg_date               => NULL, -- FFELP
                              x_s_last_name                  => UPPER(NVL(loan_oldinfo_rec.s_last_name,student_dtl_rec.p_last_name)),       -- attribute
                              x_s_first_name                 => UPPER(student_dtl_rec.p_first_name),
                              x_s_middle_name                => UPPER(student_dtl_rec.p_middle_name),
                              x_s_permt_addr1                => UPPER(student_dtl_rec.p_permt_addr1),
                              x_s_permt_addr2                => UPPER(student_dtl_rec.p_permt_addr2),
                              x_s_permt_city                 => UPPER(student_dtl_rec.p_permt_city),
                              x_s_permt_state                => UPPER(student_dtl_rec.p_permt_state),
                              x_s_permt_zip                  => UPPER(student_dtl_rec.p_permt_zip),
                              x_s_permt_addr_chg_date        => NULL, -- FFELP
                              x_s_permt_phone                => p_s_phone,
                              x_s_local_addr1                => NULL, -- Not Supported
                              x_s_local_addr2                => NULL, -- Not Supported
                              x_s_local_city                 => NULL, -- Not Supported
                              x_s_local_state                => NULL, -- Not Supported
                              x_s_local_zip                  => NULL, -- Not Supported
                              x_s_local_addr_chg_date        => NULL, -- Not Supported
                              x_s_email_addr                 => UPPER(student_dtl_rec.p_email_addr),
                              x_s_date_of_birth              => NVL(loan_oldinfo_rec.s_date_of_birth,student_dtl_rec.p_date_of_birth),      -- attribute
                              x_s_dob_chg_date               => NULL, -- FFELP
                              x_s_license_num                => UPPER(student_dtl_rec.p_license_num),
                              x_s_license_state              => UPPER(student_dtl_rec.p_license_state),
                              x_s_depncy_status              => p_isir_dep,
                              x_s_default_status             => p_loan_rec.s_default_status,
                              x_s_citizenship_status         => student_dtl_rec.p_citizenship_status,
                              x_s_alien_reg_num              => NULL, -- FFELP
                              x_s_foreign_postal_code        => NULL, -- FFELP
                              x_mode                         => 'R',
                              x_pnote_batch_id               => p_loan_rec.pnote_batch_id,
                              x_pnote_ack_date               => p_loan_rec.pnote_ack_date,
                              x_pnote_mpn_ind                => p_loan_rec.pnote_mpn_ind,
                              x_award_id                     => p_loan_rec.award_id,
                              x_base_id                      => p_loan_rec.base_id,
                              x_document_id_txt              => gv_document_id_txt,
                              x_loan_key_num                 => ln_loan_key,
                              x_interest_rebate_percent_num  => setup_rec.int_rebate,
                              x_fin_award_year               => SUBSTR(gv_dl_version,-4),
                              x_cps_trans_num                => p_isir_tnum,
                              x_atd_entity_id_txt            => p_loan_rec.atd_entity_id_txt,
                              x_rep_entity_id_txt            => p_loan_rec.rep_entity_id_txt,
                              x_source_entity_id_txt         => p_source_id,
                              x_pymt_servicer_amt            => p_loan_rec.pymt_servicer_amt,
                              x_pymt_servicer_date           => p_loan_rec.pymt_servicer_date,
                              x_book_loan_amt                => p_loan_rec.book_loan_amt,
                              x_book_loan_amt_date           => p_loan_rec.book_loan_amt_date,
                              x_s_chg_birth_date             => loan_oldinfo_rec.s_chg_birth_date,
                              x_s_chg_ssn                    => loan_oldinfo_rec.s_chg_ssn,
                              x_s_chg_last_name              => UPPER(loan_oldinfo_rec.s_chg_last_name),
                              x_b_chg_birth_date             => loan_oldinfo_rec.b_chg_birth_date,
                              x_b_chg_ssn                    => loan_oldinfo_rec.b_chg_ssn,
                              x_b_chg_last_name              => UPPER(loan_oldinfo_rec.b_chg_last_name),
                              x_note_message                 => p_loan_rec.note_message,
                              x_full_resp_code               => NVL(setup_rec.response_option_code,'F'),
                              x_s_permt_county               => UPPER(student_dtl_rec.p_county),
                              x_b_permt_county               => UPPER(parent_dtl_rec.p_county),
                              x_s_permt_country              => UPPER(student_dtl_rec.p_country),
                              x_b_permt_country              => UPPER(parent_dtl_rec.p_country),
                              x_crdt_decision_status         => p_loan_rec.crdt_decision_status,
                              x_mpn_type_flag                => p_loan_rec.elec_mpn_ind,
                              x_alt_borrower_ind_flag        => NULL,-- FFELP
                              x_borower_credit_authoriz_flag => NULL,-- FFELP
                              x_borower_electronic_sign_flag => NULL,-- FFELP
                              x_cost_of_attendance_amt       => NULL,-- FFELP
                              x_deferment_request_code       => NULL,-- FFELP
                              x_eft_authorization_code       => NULL,-- FFELP
                              x_established_fin_aid_amount   => NULL,-- FFELP
                              x_expect_family_contribute_amt => NULL,-- FFELP
                              x_external_loan_id_txt         => NULL,-- FFELP
                              x_flp_approved_amt             => NULL,-- FFELP
                              x_fls_approved_amt             => NULL,-- FFELP
                              x_flu_approved_amt             => NULL,-- FFELP
                              x_guarantor_use_txt            => NULL,-- FFELP
                              x_lender_use_txt               => NULL,-- FFELP
                              x_loan_app_form_code           => NULL,-- FFELP
                              x_reinstatement_amt            => NULL,-- FFELP
                              x_requested_loan_amt           => NULL,-- FFELP
                              x_school_id_txt                => NULL,-- FFELP
                              x_school_use_txt               => NULL,-- FFELP
                              x_student_electronic_sign_flag => NULL,-- FFELP
                              x_actual_record_type_code      => NULL,-- FFELP
                              x_alt_approved_amt             => NULL,
                              x_esign_src_typ_cd             => NULL
                  );-- FFELP

--
-- insert/update disbursement information
--
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug','inserting cod db dtls');
   END IF;

   FOR rec IN cur_disb_rec (p_loan_rec.award_id)
   LOOP
         lv_rowid := NULL; -- pass atd entity id, rep entity id here
         IF rec.disb_conf_flag IS NULL THEN
            rec.disb_conf_flag := 'false';
         END IF;
         IF rec.disb_conf_flag = 'Y' THEN
            rec.disb_conf_flag := 'false';
         ELSIF rec.disb_conf_flag = 'N' THEN
            rec.disb_conf_flag := 'true';
         END IF;
         igf_aw_db_cod_dtls_pkg.add_row(x_rowid                 => lv_rowid,
                                        x_award_id              => rec.award_id,
                                        x_document_id_txt       => gv_document_id_txt,
                                        x_disb_num              => rec.disb_num,
                                        x_disb_seq_num          => rec.disb_seq_num,
                                        x_disb_accepted_amt     => rec.disb_accepted_amt,
                                        x_orig_fee_amt          => rec.orig_fee_amt,
                                        x_disb_net_amt          => rec.disb_net_amt,
                                        x_disb_date             => rec.disb_date,
                                        x_disb_rel_flag         => LOWER(rec.disb_rel_flag),
                                        x_first_disb_flag       => rec.first_disb_flag,
                                        x_interest_rebate_amt   => rec.interest_rebate_amt,
                                        x_disb_conf_flag        => rec.disb_conf_flag,
                                        x_pymnt_per_start_date  => rec.pymnt_prd_start_date,
                                        x_note_message          => rec.note_message,
                                        x_rep_entity_id_txt     => p_loan_rec.rep_entity_id_txt,
                                        x_atd_entity_id_txt     => p_loan_rec.atd_entity_id_txt,
                                        x_mode                  => 'R');

     IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug','after inserting cod db dtls seq num, disb num, award id' || rec.disb_seq_num || ' , ' || rec.disb_num || ' , ' || rec.award_id);
     END IF;
   END LOOP;

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.insert_lor_loc.debug','after inserting cod db dtls');
   END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_dl_gen_xml.log_parameters.exception','Exception:'||SQLERRM);
    END IF;
    fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
    fnd_message.set_token('NAME','IGF_SL_DL_GEN_XML.LOG_PARAMETERS');
    app_exception.raise_exception;

END insert_lor_loc;

PROCEDURE  process_loan(p_loan_rec cur_pick_loans%ROWTYPE, p_source_id VARCHAR2)
IS

  lb_valid_loan BOOLEAN;
  lb_spoint_est BOOLEAN;

  l_msg_name    fnd_new_messages.message_name%TYPE;
  l_aid         NUMBER;
  l_loan_tab    igf_aw_packng_subfns.std_loan_tab := igf_aw_packng_subfns.std_loan_tab();

  student_dtl_cur  igf_sl_gen.person_dtl_cur;
  parent_dtl_cur   igf_sl_gen.person_dtl_cur;
  student_dtl_rec  igf_sl_gen.person_dtl_rec;
  parent_dtl_rec   igf_sl_gen.person_dtl_rec;

  p_isir_ssn     VARCHAR2(30);
  p_isir_dob     DATE;
  p_isir_lname   VARCHAR2(100);
  p_isir_dep     VARCHAR2(1);
  p_isir_tnum    NUMBER;
  p_acad_begin   DATE;
  p_acad_end     DATE;
  p_s_phone      VARCHAR2(30);
  p_p_phone      VARCHAR2(30);

  CURSOR cur_isir_info (p_base_id NUMBER) IS
SELECT  payment_isir,transaction_num,dependency_status,
        date_of_birth,current_ssn,last_name
  FROM  igf_ap_isir_matched_all
  WHERE base_id      = p_base_id
  AND   payment_isir = 'Y'
  AND   system_record_type = 'ORIGINAL';

   isir_info_rec cur_isir_info%ROWTYPE;

BEGIN

  IF gv_document_id_txt IS NULL THEN
    gv_document_id_txt := TO_CHAR(TRUNC(SYSDATE),'YYYY-MM-DD')||'T'||TO_CHAR(SYSDATE,'HH:MM:SS') || '.00' ||LPAD(p_source_id,8,'0');
  END IF;
--
-- 4. validate loans
--

 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.process_loan.debug','Calling validate Loan for Loan Number : ' || p_loan_rec.loan_number);
 END IF;

 lb_valid_loan := igf_sl_dl_validation.cod_loan_validations(p_loan_rec,'JOB',p_isir_ssn,
                                                            p_isir_dob,p_isir_lname,
                                                            p_isir_dep,p_isir_tnum,
                                                            p_acad_begin,p_acad_end,p_s_phone,p_p_phone);

 IF lb_valid_loan THEN

   fnd_file.put_line(fnd_file.log,igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','LOAN_NUMBER')||' : '||p_loan_rec.loan_number);
   fnd_file.new_line(fnd_file.log,1);
   -- Check for Loan Amount
   IF p_loan_rec.fed_fund_code IN ('DLS','DLU') THEN
      l_aid      := 0;
      l_msg_name := NULL;
    -- since the fund amount is already awarded to the student then l_aid is passed as 0.
      igf_aw_packng_subfns.check_loan_limits (
                                              p_loan_rec.base_id,
                                              p_loan_rec.fed_fund_code,
                                              p_loan_rec.award_id,
                                              NULL,
                                              l_aid,
                                              l_loan_tab,
                                              l_msg_name
                                             );
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.process_loan.debug','The values returned from check_loan_limits l_aid : ' || l_aid);
      END IF;
       -- If the returned l_aid is 0 with no message returned or l_aid is greater than 0 then
       -- the set up is fine otherwise show the corresponding error message in the log.
      IF l_msg_name IS NOT NULL THEN
        --Error has occured
        IF l_aid = 0 THEN
          fnd_message.set_name('IGF',l_msg_name);
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          RETURN;
        ELSIF l_aid < 0 THEN
          fnd_message.set_name('IGF',l_msg_name);
          fnd_message.set_token('FUND_CODE',p_loan_rec.fed_fund_code);
          fnd_file.put_line(fnd_file.log,fnd_message.get);
        END IF ;
      END IF;
   END IF;

   igf_sl_gen.get_person_details(igf_gr_gen.get_person_id(p_loan_rec.base_id),student_dtl_cur);
   FETCH student_dtl_cur INTO student_dtl_rec;
   CLOSE student_dtl_cur;

   IF p_loan_rec.fed_fund_code = 'DLP' THEN
      igf_sl_gen.get_person_details(p_loan_rec.p_person_id,parent_dtl_cur);
      FETCH parent_dtl_cur INTO parent_dtl_rec;
      CLOSE parent_dtl_cur;
   END IF;

-- 5. insert valid loans
--
   lb_spoint_est := FALSE;
   SAVEPOINT IGFSL25B_PROCESS_LOAN;
   lb_spoint_est := TRUE;
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.process_loan.debug','inert lor loc for  Loan Loan Number : ' || p_loan_rec.loan_number);
   END IF;

  -- Get ISIR Information
  --
  OPEN  cur_isir_info (p_loan_rec.base_id);
  FETCH cur_isir_info INTO isir_info_rec;
  CLOSE cur_isir_info;


  IF isir_info_rec.date_of_birth <> student_dtl_rec.p_date_of_birth OR
     isir_info_rec.current_ssn <> student_dtl_rec.p_ssn OR
     isir_info_rec.last_name <> UPPER(student_dtl_rec.p_last_name) THEN

        --akomurav
	IF isir_info_rec.date_of_birth <> student_dtl_rec.p_date_of_birth THEN

		fnd_message.set_name('IGF','IGF_SL_DOB_MISMATCH');
		fnd_message.set_token('P_DOB',to_char(student_dtl_rec.p_date_of_birth));
		fnd_message.set_token('ISIR_DOB',to_char(isir_info_rec.date_of_birth));
		fnd_file.put_line(fnd_file.log,'        ' || fnd_message.get);
		student_dtl_rec.p_date_of_birth := isir_info_rec.date_of_birth;

	END IF;

        IF isir_info_rec.current_ssn <> student_dtl_rec.p_ssn THEN

		fnd_message.set_name('IGF','IGF_SL_SSN_MISMATCH');
		fnd_message.set_token('P_SSN',student_dtl_rec.p_ssn);
		fnd_message.set_token('ISIR_SSN',isir_info_rec.current_ssn);
		fnd_file.put_line(fnd_file.log,'        ' || fnd_message.get);
		student_dtl_rec.p_ssn := isir_info_rec.current_ssn;

	END IF;

	IF isir_info_rec.last_name <> UPPER(student_dtl_rec.p_last_name) THEN

		fnd_message.set_name('IGF','IGF_SL_NAME_MISMATCH');
		fnd_message.set_token('P_LAST_NAME',UPPER(student_dtl_rec.p_last_name));
		fnd_message.set_token('ISIR_NAME',UPPER(isir_info_rec.last_name));
		fnd_file.put_line(fnd_file.log,'        ' || fnd_message.get);
		student_dtl_rec.p_last_name := UPPER(isir_info_rec.last_name);



	END IF;

  END IF;

  --
  -- do DML after this savepoint
  -- insert / update UPPERCASE information only
  insert_lor_loc(p_loan_rec,p_source_id,student_dtl_rec,parent_dtl_rec,
                 p_isir_ssn,p_isir_dob,p_isir_lname,p_isir_dep,p_isir_tnum,
                 p_acad_begin,p_acad_end,p_s_phone, p_p_phone);


 ELSE
   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.process_loan.debug',' Failed validations Loan Number : ' || p_loan_rec.loan_number);
   END IF;
 END IF; -- valid loan

 EXCEPTION
  WHEN OTHERS THEN
    IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_dl_gen_xml.process_loan.exception','Exception:'||SQLERRM);
    END IF;
    fnd_message.set_name('IGF','IGF_SL_DL_XML_INSERT_EXC');
    fnd_message.set_token('LOAN_NUMBER',p_loan_rec.loan_number);
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    fnd_file.put_line(fnd_file.log,SQLERRM);
    IF lb_spoint_est THEN
       lb_spoint_est := FALSE;
       ROLLBACK TO IGFSL25B_PROCESS_LOAN;
    END IF;
END process_loan;

FUNCTION per_in_fa ( p_person_id            igf_ap_fa_base_rec_all.person_id%TYPE,
                     p_ci_cal_type          VARCHAR2,
                     p_ci_sequence_number   NUMBER,
                     p_base_id     OUT NOCOPY NUMBER
                    )
RETURN VARCHAR2
IS
        CURSOR cur_get_pers_num ( p_person_id  igf_ap_fa_base_rec_all.person_id%TYPE)
        IS
        SELECT person_number
        FROM   igs_pe_person_base_v
        WHERE
        person_id  = p_person_id;

        get_pers_num_rec   cur_get_pers_num%ROWTYPE;

        CURSOR cur_get_base (p_cal_type        igs_ca_inst_all.cal_type%TYPE,
                             p_sequence_number igs_ca_inst_all.sequence_number%TYPE,
                             p_person_id       igf_ap_fa_base_rec_all.person_id%TYPE)
        IS
        SELECT
        base_id
        FROM
        igf_ap_fa_base_rec_all
        WHERE
        person_id          = p_person_id AND
        ci_cal_type        = p_cal_type  AND
        ci_sequence_number = p_sequence_number;

BEGIN

        OPEN  cur_get_pers_num(p_person_id);
        FETCH cur_get_pers_num  INTO get_pers_num_rec;

        IF    cur_get_pers_num%NOTFOUND THEN
              CLOSE cur_get_pers_num;
              RETURN NULL;
        ELSE
              CLOSE cur_get_pers_num;
              OPEN  cur_get_base(p_ci_cal_type,p_ci_sequence_number,p_person_id);
              FETCH cur_get_base INTO p_base_id;
              CLOSE cur_get_base;

              RETURN get_pers_num_rec.person_number;

        END IF;

        EXCEPTION
        WHEN OTHERS THEN
        fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
        fnd_message.set_token('NAME','IGF_SL_DL_GEN_XML.PER_IN_FA');
        IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_dl_gen_xml.per_in_fa.exception','Exception:'||SQLERRM);
        END IF;
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
  END per_in_fa;

  PROCEDURE  submit_xml_event (p_document_id_txt VARCHAR2)
  IS

    l_parameter_list  wf_parameter_list_t;

    l_event_name  VARCHAR2(255);
    l_event_key   NUMBER;
    l_map_code    VARCHAR2(255);
    l_param_1     VARCHAR2(255);
    lv_role       fnd_user.user_name%TYPE;

    CURSOR cur_sequence IS SELECT IGF_SL_DL_GEN_XML_S.NEXTVAL FROM DUAL;

  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.submit_xml_event','p_document id: '||p_document_id_txt);
    END IF;

    l_parameter_list  := wf_parameter_list_t();
    l_event_name      := 'oracle.apps.igf.sl.genxml';
    l_map_code        := 'IGF_SL_DL_OUT';
    l_param_1         :=  p_document_id_txt;


    OPEN  cur_sequence;
    FETCH cur_sequence INTO l_event_key;
    CLOSE cur_sequence;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.submit_xml_event','l_event_key : '||l_event_key);
    END IF;

    -- Now add the parameters to the list to be passed to the workflow

    lv_role := fnd_global.user_name;

    wf_event.addparametertolist(
       p_name          => 'USER_ID',
       p_value         => lv_role,
       p_parameterlist => l_parameter_list
       );
    wf_event.addparametertolist(
       p_name          => 'EVENT_NAME',
       p_value         => l_event_name,
       p_parameterlist => l_parameter_list
       );
    wf_event.addparametertolist(
      p_name           => 'EVENT_KEY',
      p_value          => l_event_key,
      p_parameterlist  => l_parameter_list
      );
    wf_event.addparametertolist(
      p_name           => 'ECX_MAP_CODE',
      p_value          => l_map_code,
      p_parameterlist  => l_parameter_list
      );

    wf_event.addparametertolist(
      p_name           => 'ECX_PARAMETER1',
      p_value          => l_param_1,
      p_parameterlist  => l_parameter_list
      );

    wf_event.RAISE (
      p_event_name      => l_event_name,
      p_event_key       => l_event_key,
      p_parameters      => l_parameter_list);


   fnd_message.set_name('IGF','IGF_SL_COD_RAISE_EVENT');
   fnd_message.set_token('EVENT_KEY_VALUE',l_event_key);
   fnd_file.new_line(fnd_file.log,1);
   fnd_file.put_line(fnd_file.log,fnd_message.get);
   fnd_file.new_line(fnd_file.log,1);

   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.submit_xml_event','raised event ');
    END IF;

   EXCEPTION
    WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_dl_gen_xml.submit_xml_event.exception','Exception:'||SQLERRM);
      END IF;
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_SL_DL_GEN_XML.SUBMIT_XML_EVENT');
      igs_ge_msg_stack.add;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.submit_xml_event.debug','sqlerrm ' || SQLERRM);
      END IF;
      app_exception.raise_exception;
  END submit_xml_event;

  FUNCTION get_fund_desc(p_fund_id IN NUMBER)
  RETURN VARCHAR2 IS
  CURSOR cur_get_fund_desc (p_fund_id NUMBER)
  IS
  SELECT description FROM igf_aw_fund_mast_all
  WHERE  fund_id = p_fund_id;

  get_fund_desc_rec cur_get_fund_desc%ROWTYPE;

  BEGIN

    OPEN  cur_get_fund_desc (p_fund_id);
    FETCH cur_get_fund_desc INTO get_fund_desc_rec;
    CLOSE cur_get_fund_desc;

    RETURN get_fund_desc_rec.description;

  END get_fund_desc;

  FUNCTION get_loan_number(p_loan_id IN NUMBER)
  RETURN VARCHAR2 IS
  CURSOR cur_get_loan_number (p_loan_id NUMBER)
  IS
  SELECT loan_number FROM igf_sl_loans_all
  WHERE  loan_id = p_loan_id;

  get_loan_number_rec cur_get_loan_number%ROWTYPE;

  BEGIN

    OPEN  cur_get_loan_number (p_loan_id);
    FETCH cur_get_loan_number INTO get_loan_number_rec;
    CLOSE cur_get_loan_number;

    RETURN get_loan_number_rec.loan_number;

  END get_loan_number;

  FUNCTION get_grp_name(p_per_grp_id IN NUMBER)
  RETURN VARCHAR2 IS

  CURSOR cur_get_grp_name (p_per_grp_id NUMBER)
  IS
  SELECT group_cd
  FROM   igs_pe_persid_group_all
  WHERE  group_id = p_per_grp_id;


  get_grp_name_rec cur_get_grp_name%ROWTYPE;

  BEGIN

    OPEN  cur_get_grp_name (p_per_grp_id);
    FETCH cur_get_grp_name INTO get_grp_name_rec;
    CLOSE cur_get_grp_name;

    RETURN get_grp_name_rec.group_cd;

  END get_grp_name;

  FUNCTION check_fa_rec(p_base_id    NUMBER,
                        p_cal_type   VARCHAR2,
                        p_seq_number NUMBER)
  RETURN BOOLEAN
  IS
    CURSOR cur_chk_fa (p_base_id    NUMBER,
                       p_cal_type   VARCHAR2,
                       p_seq_number NUMBER)
    IS
    SELECT base_id
    FROM   igf_ap_fa_base_rec_all
    WHERE  base_id = p_base_id AND
    ci_cal_type = p_cal_type   AND
    ci_sequence_number = p_seq_number;

    chk_fa_rec cur_chk_fa%ROWTYPE;

  BEGIN

    OPEN cur_chk_fa (p_base_id,p_cal_type,p_seq_number);
    FETCH cur_chk_fa INTO chk_fa_rec;
    CLOSE cur_chk_fa;
    IF chk_fa_rec.base_id IS NULL THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;

  END check_fa_rec;

  PROCEDURE log_parameters(p_cal_type   VARCHAR2,
                           p_seq_number NUMBER,
                           p_source_id  VARCHAR2,
                           p_report_id  VARCHAR2,
                           p_attend_id  VARCHAR2,
                           p_fund_id    NUMBER,
                           p_base_id    NUMBER,
                           p_loan_id    NUMBER,
                           p_pgroup_id  NUMBER)
  IS
    CURSOR c_get_parameters
    IS
    SELECT meaning, lookup_code
      FROM igf_lookups_view
     WHERE lookup_type = 'IGF_GE_PARAMETERS'
       AND lookup_code IN ('PARAMETER_PASS',
                           'AWARD_YEAR',
                           'SOURCE_ENTITY_ID', -- New
                           'REPORT_ENTITY_ID', -- New
                           'ATTEND_ENTITY_ID', -- New
                           'LOAN_TYPE',        -- New
                           'PERSON_NUMBER',
                           'LOAN_NUMBER',      -- New
                           'PERSON_ID_GROUP');

    parameter_rec           c_get_parameters%ROWTYPE;

    CURSOR cur_get_loan_number (p_loan_id NUMBER)
    IS
    SELECT loan_number
    FROM   igf_sl_loans_all
    WHERE  loan_id = p_loan_id;

    get_loan_number_rec cur_get_loan_number%ROWTYPE;

    lv_parameter_pass       VARCHAR2(80);
    lv_award_year           VARCHAR2(80);
    lv_source_entity_id     VARCHAR2(80);
    lv_report_entity_id     VARCHAR2(80);
    lv_attend_entity_id     VARCHAR2(80);
    lv_loan_type            VARCHAR2(80);
    lv_person_number        VARCHAR2(80);
    lv_loan_number          VARCHAR2(80);
    lv_person_id_group      VARCHAR2(80);

  BEGIN

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.log_parameters.debug','In log parameters');
    END IF;

    OPEN c_get_parameters;
    LOOP
          FETCH c_get_parameters INTO  parameter_rec;
          EXIT WHEN c_get_parameters%NOTFOUND;

          IF parameter_rec.lookup_code ='PARAMETER_PASS' THEN
            lv_parameter_pass   := TRIM(parameter_rec.meaning);
          ELSIF parameter_rec.lookup_code ='AWARD_YEAR' THEN
            lv_award_year       := TRIM(parameter_rec.meaning);
          ELSIF parameter_rec.lookup_code ='SOURCE_ENTITY_ID' THEN
            lv_source_entity_id := TRIM(parameter_rec.meaning);
          ELSIF parameter_rec.lookup_code ='REPORT_ENTITY_ID' THEN
            lv_report_entity_id := TRIM(parameter_rec.meaning);
          ELSIF parameter_rec.lookup_code ='ATTEND_ENTITY_ID' THEN
            lv_attend_entity_id := TRIM(parameter_rec.meaning);
          ELSIF parameter_rec.lookup_code ='LOAN_TYPE' THEN
            lv_loan_type        := TRIM(parameter_rec.meaning);
          ELSIF parameter_rec.lookup_code ='PERSON_NUMBER' THEN
            lv_person_number    := TRIM(parameter_rec.meaning);
          ELSIF parameter_rec.lookup_code ='LOAN_NUMBER' THEN
            lv_loan_number      := TRIM(parameter_rec.meaning);
          ELSIF parameter_rec.lookup_code ='PERSON_ID_GROUP' THEN
            lv_person_id_group  := TRIM(parameter_rec.meaning);
          END IF;
    END LOOP;
    CLOSE c_get_parameters;

    fnd_file.new_line(fnd_file.log,1);
    fnd_file.put_line(fnd_file.log, lv_parameter_pass); --------------Parameters Passed--------------
    fnd_file.new_line(fnd_file.log,1);

    fnd_file.put_line(fnd_file.log, RPAD(lv_award_year,40)         || ' : '|| igf_gr_gen.get_alt_code(p_cal_type,p_seq_number));
    fnd_file.put_line(fnd_file.log, RPAD(lv_source_entity_id,40)   || ' : '|| p_source_id);
    fnd_file.put_line(fnd_file.log, RPAD(lv_report_entity_id,40)   || ' : '|| p_report_id);
    fnd_file.put_line(fnd_file.log, RPAD(lv_attend_entity_id,40)   || ' : '|| p_attend_id);
    fnd_file.put_line(fnd_file.log, RPAD(lv_loan_type,40)          || ' : '|| get_fund_desc(p_fund_id));
    fnd_file.put_line(fnd_file.log, RPAD(lv_person_number,40)      || ' : '|| igf_gr_gen.get_per_num(p_base_id));
    fnd_file.put_line(fnd_file.log, RPAD(lv_loan_number,40)        || ' : '|| get_loan_number(p_loan_id));
    fnd_file.put_line(fnd_file.log, RPAD(lv_person_id_group,40)    || ' : '|| get_grp_name(p_pgroup_id));

    fnd_file.new_line(fnd_file.log,1);
    fnd_file.put_line(fnd_file.log, '--------------------------------------------------------');
    fnd_file.new_line(fnd_file.log,1);

   EXCEPTION
    WHEN OTHERS THEN
      IF fnd_log.level_exception >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_exception,'igf.plsql.igf_sl_dl_gen_xml.log_parameters.exception','Exception:'||SQLERRM);
      END IF;
      fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
      fnd_message.set_token('NAME','IGF_SL_DL_GEN_XML.LOG_PARAMETERS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;

  END log_parameters;

  PROCEDURE main(errbuf       OUT NOCOPY VARCHAR2,
                 retcode      OUT NOCOPY NUMBER,
                 p_award_year VARCHAR2,
                 p_source_id  VARCHAR2,
                 p_report_id  VARCHAR2,
                 p_attend_id  VARCHAR2,
                 p_fund_id    NUMBER,
                 p_fund_dummy NUMBER,
                 p_base_id    NUMBER,
                 p_base_dummy NUMBER,
                 p_loan_id    NUMBER,
                 p_loan_dummy NUMBER,
                 p_pgroup_id  NUMBER)
  IS
    /* -----------------------------------------------------------------------------------
       Know limitations, enhancements or remarks
       Change History:
    -----------------------------------------------------------------------------------
    Who         When            What
    ridas       08-Feb-2006     Bug #5021084. Added new parameter 'lv_group_type' in call to igf_ap_ss_pkg.get_pid
    tsailaja		15/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
    -----------------------------------------------------------------------------------
    */


    CURSOR cur_cod_dtls (p_document_id_txt VARCHAR2)
    IS
    SELECT document_id_txt
    FROM   igf_sl_lor_loc_all
    WHERE  document_id_txt = p_document_id_txt;

    cod_dtls_rec cur_cod_dtls%ROWTYPE;

    CURSOR cur_award_year (p_cal_type   VARCHAR2,
                           p_seq_number NUMBER)
    IS
    SELECT award_year_status_code,dl_participant_code, sys_award_year
    FROM   igf_ap_batch_aw_map_all
    WHERE  ci_sequence_number =  p_seq_number AND ci_cal_type = p_cal_type;

    award_year_rec  cur_award_year%ROWTYPE;

    CURSOR cur_source_id (p_source_id   VARCHAR2,
                          p_cal_type    VARCHAR2,
                          p_seq_number  NUMBER)
    IS
    SELECT
    rep.rep_entity_id_txt
    FROM
    igf_gr_report_pell rep
    WHERE
    rep.rep_entity_id_txt = p_source_id AND
    rep.ci_cal_type = p_cal_type        AND
    rep.ci_sequence_number = p_seq_number;

    source_id_rec cur_source_id%ROWTYPE;

    CURSOR cur_report_id (p_report_id  VARCHAR2,
                          p_cal_type   VARCHAR2,
                          p_seq_number NUMBER)
    IS
    SELECT
    lor.loan_id
    FROM
    igf_sl_lor_all       lor,
    igf_sl_loans_all     loan,
    igf_aw_award_all     awd,
    igf_aw_fund_mast_all fmast
    WHERE
    loan.award_id = awd.award_id AND
    awd.fund_id   = fmast.fund_id AND
    fmast.ci_sequence_number = p_seq_number AND
    fmast.ci_cal_type = p_cal_type      AND
    lor.loan_id = loan.loan_id  AND
    lor.rep_entity_id_txt = p_report_id;

    report_id_rec cur_report_id%ROWTYPE;


    CURSOR cur_attend_id (p_report_id  VARCHAR2,
                          p_attend_id  VARCHAR2,
                          p_cal_type   VARCHAR2,
                          p_seq_number NUMBER)
    IS
    SELECT
    lor.loan_id
    FROM
    igf_sl_lor_all       lor,
    igf_sl_loans_all     loan,
    igf_aw_award_all     awd,
    igf_aw_fund_mast_all fmast
    WHERE
    loan.award_id = awd.award_id AND
    awd.fund_id   = fmast.fund_id AND
    fmast.ci_sequence_number = p_seq_number AND
    fmast.ci_cal_type = p_cal_type      AND
    lor.loan_id = loan.loan_id  AND
    lor.rep_entity_id_txt = p_report_id AND
    lor.atd_entity_id_txt = p_attend_id;

    attend_id_rec cur_attend_id%ROWTYPE;


    CURSOR cur_chk_loan (p_base_id NUMBER)
    IS
    SELECT loan.loan_id
    FROM
    igf_sl_loans_all loan,
    igf_aw_award_all awd
    WHERE
    awd.award_id = loan.award_id  AND
    awd.base_id  = p_base_id      AND
    (
        loan.loan_status       = 'G'  OR
        loan.loan_chg_status   = 'G'
    );

    chk_loan_rec  cur_chk_loan%ROWTYPE;


    CURSOR cur_chk_pidgroup (p_pgroup_id NUMBER)
    IS
    SELECT group_id
    FROM   igs_pe_persid_group_all
    WHERE
    group_id   = p_pgroup_id AND
    closed_ind = 'N';

    chk_pidgroup_rec  cur_chk_pidgroup%ROWTYPE;

    lv_cal_type      VARCHAR2(30);
    ln_seq_number    NUMBER;
    lv_person_number hz_parties.party_number%TYPE;

    lb_record_exist BOOLEAN;

    l_list    VARCHAR2(32767);
    lv_status VARCHAR2(1);
    TYPE cur_person_id_type IS REF CURSOR;
    cur_per_grp cur_person_id_type;

    l_person_id hz_parties.party_id%TYPE;
    ln_base_id NUMBER;
    ln_top NUMBER;
    ln_sm  NUMBER;
    ln_rs  NUMBER;
    ln_rp  NUMBER;
    ln_as  NUMBER;
    ln_st  NUMBER;
    ln_db  NUMBER;
    lv_group_type     igs_pe_persid_group_v.group_type%TYPE;

  BEGIN

    --
    -- Steps
    -- 1. Print parameters
    -- 2. Validate parameters
    -- 3. Find Loans to be processed
    -- 4. Validate Loans
    -- 5. Insert valid loan records into LOR_LOC, and disb records into _DB_LOC
    -- 6. Raise Business Event
    --
	  igf_aw_gen.set_org_id(NULL);
    lv_cal_type     := RTRIM(SUBSTR(p_award_year,1,10));
    ln_seq_number   := TO_NUMBER(RTRIM(SUBSTR(p_award_year,11)));
    ln_count        := 0;
    loan_key_rec    := loan_key_list();
    loan_key_rec.DELETE;
    gn_old_base_id  := -1;
    gn_new_base_id  := 0;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','p_award_year: '||p_award_year);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','award cal_type : ' || lv_cal_type);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','award ci_seq_num : ' || ln_seq_number);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','p_source_id: '||p_source_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','p_report_id:'||p_report_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','p_attend_id: '||p_attend_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','p_fund_id: '||p_fund_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','p_fund_dummy: '||p_fund_dummy);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','p_base_id: '||p_base_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','p_base_dummy: '||p_base_dummy);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','p_loan_id: '||p_loan_id);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','p_loan_dummy: '||p_loan_dummy);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','p_pgroup_id: '||p_pgroup_id);
    END IF;

    -- 1. Print parameters
    log_parameters(lv_cal_type,ln_seq_number,
                   TRIM(p_source_id),
                   TRIM(p_report_id),
                   TRIM(p_attend_id),
                   p_fund_id,
                   p_base_id,
                   p_loan_id,
                   p_pgroup_id);

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','after log parameters');
    END IF;

    -- 2. Validate parameters
    IF p_award_year IS NULL OR lv_cal_type IS NULL OR ln_seq_number IS NULL THEN
       fnd_message.set_name('IGF','IGF_SL_COD_REQ_PARAM');
       fnd_message.set_token('PARAM',igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','AWARD_YEAR'));
       fnd_file.put_line(fnd_file.log, fnd_message.get);
       fnd_file.new_line(fnd_file.log, 1);
       RETURN;
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','award year is not null');
    END IF;

    IF TRIM(p_source_id) IS NULL THEN
       fnd_message.set_name('IGF','IGF_SL_COD_REQ_PARAM');
       fnd_message.set_token('PARAM',igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','SOURCE_ENTITY_ID'));
       fnd_file.put_line(fnd_file.log, fnd_message.get);
       fnd_file.new_line(fnd_file.log, 1);
       RETURN;
    END IF;

    IF LENGTH(TRIM(p_source_id)) > 8 OR TRIM(p_source_id) > 99999999
       OR NOT igf_sl_dl_validation.validate_id(p_source_id) THEN
       fnd_message.set_name('IGF','IGF_SL_COD_INVL_SOURCE_ID');
       fnd_file.put_line(fnd_file.log, fnd_message.get);
       fnd_file.new_line(fnd_file.log, 1);
       RETURN;
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','source id is not null');
    END IF;

    IF p_pgroup_id IS NOT NULL AND p_base_id IS NOT NULL THEN
       fnd_message.set_name('IGF','IGF_SL_COD_INV_PARAM');
       fnd_message.set_token('PARAM1',igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_ID_GROUP'));
       fnd_message.set_token('PARAM2',igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_NUMBER'));
       fnd_file.put_line(fnd_file.log, fnd_message.get);
       fnd_file.new_line(fnd_file.log, 1);
       RETURN;
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','base id and pgroup id check');
    END IF;

    IF p_pgroup_id IS NOT NULL AND p_loan_id IS NOT NULL THEN
       fnd_message.set_name('IGF','IGF_SL_COD_INV_PARAM');
       fnd_message.set_token('PARAM1',igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','PERSON_ID_GROUP'));
       fnd_message.set_token('PARAM2',igf_aw_gen.lookup_desc('IGF_GE_PARAMETERS','LOAN_NUMBER'));
       fnd_file.put_line(fnd_file.log, fnd_message.get);
       fnd_file.new_line(fnd_file.log, 1);
       RETURN;
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','loan id and pgroup id check');
    END IF;

    IF p_attend_id IS NOT NULL AND p_report_id IS NULL THEN
       fnd_message.set_name('IGF','IGF_SL_COD_INV_ATD_PARAM');
       fnd_file.put_line(fnd_file.log, fnd_message.get);
       fnd_file.new_line(fnd_file.log, 1);
       RETURN;
    END IF;

    OPEN  cur_award_year(lv_cal_type,ln_seq_number);
    FETCH cur_award_year INTO award_year_rec;
    CLOSE cur_award_year;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','loan id and pgroup id check 1');
    END IF;

    IF  award_year_rec.sys_award_year IS NULL OR
        award_year_rec.dl_participant_code IS NULL OR
        award_year_rec.award_year_status_code IS NULL
    THEN
       fnd_message.set_name('IGF','IGF_SL_COD_INV_AWD_YR');
       fnd_file.put_line(fnd_file.log, fnd_message.get);
       fnd_file.new_line(fnd_file.log, 1);
       RETURN;
    END IF;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','batch year not empty');
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','sys award year ' || award_year_rec.sys_award_year);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','dl participant code ' || award_year_rec.dl_participant_code);
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','award year status code ' ||  award_year_rec.award_year_status_code);
    END IF;

    IF award_year_rec.award_year_status_code <> 'O' THEN
       fnd_message.set_name('IGF','IGF_SL_COD_AWDYR_OPEN');
       fnd_file.put_line(fnd_file.log, fnd_message.get);
       fnd_file.new_line(fnd_file.log, 1);
       RETURN;
    END IF;

    IF award_year_rec.dl_participant_code <> 'FULL_PARTICIPANT' THEN
       fnd_message.set_name('IGF','IGF_SL_COD_AWDYR_FULL');
       fnd_file.put_line(fnd_file.log, fnd_message.get);
       fnd_file.new_line(fnd_file.log, 1);
       RETURN;
    END IF;

    IF award_year_rec.sys_award_year < '0405' THEN
       fnd_message.set_name('IGF','IGF_SL_COD_XML_SUPPORT');
       fnd_file.put_line(fnd_file.log, fnd_message.get);
       fnd_file.new_line(fnd_file.log, 1);
       RETURN;
    END IF;

    OPEN cur_source_id(p_source_id,lv_cal_type,ln_seq_number);
    FETCH cur_source_id INTO source_id_rec;
    CLOSE cur_source_id;

    IF source_id_rec.rep_entity_id_txt IS NULL THEN
       fnd_message.set_name('IGF','IGF_SL_COD_INV_SRC_ID');
       fnd_file.put_line(fnd_file.log, fnd_message.get);
       fnd_file.new_line(fnd_file.log, 1);
       RETURN;
    END IF;

    IF p_report_id IS NOT NULL THEN

      OPEN cur_report_id(p_report_id,lv_cal_type,ln_seq_number);
      FETCH cur_report_id INTO report_id_rec;
      CLOSE cur_report_id;

      IF report_id_rec.loan_id IS NULL THEN
         fnd_message.set_name('IGF','IGF_SL_COD_INV_REP_ID');
         fnd_message.set_token('REPORTING_ID',p_report_id);
         fnd_file.put_line(fnd_file.log, fnd_message.get);
         fnd_file.new_line(fnd_file.log, 1);
         RETURN;
      END IF;

      IF p_attend_id IS NOT NULL THEN
        OPEN cur_attend_id(p_report_id,p_attend_id,lv_cal_type,ln_seq_number);
        FETCH cur_attend_id INTO attend_id_rec;
        CLOSE cur_attend_id;

        IF attend_id_rec.loan_id IS NULL THEN
           fnd_message.set_name('IGF','IGF_SL_COD_INV_ATD_ID');
           fnd_message.set_token('REPORTING_ID',p_report_id);
           fnd_message.set_token('ATTENDING_ID',p_attend_id);
           fnd_file.put_line(fnd_file.log, fnd_message.get);
           fnd_file.new_line(fnd_file.log, 1);
           RETURN;
        END IF;
      END IF;

    END IF;

    IF p_base_id IS NOT NULL AND
       ( igf_gr_gen.get_per_num(p_base_id) IS NULL OR
         NOT check_fa_rec(p_base_id, lv_cal_type, ln_seq_number))
      THEN
       fnd_message.set_name('IGF','IGF_SP_NO_FA_BASE_REC');
       fnd_file.put_line(fnd_file.log, fnd_message.get);
       fnd_file.new_line(fnd_file.log, 1);
       RETURN;
    END IF;

    IF p_base_id IS NOT NULL THEN
      OPEN  cur_chk_loan(p_base_id);
      FETCH cur_chk_loan INTO chk_loan_rec;
      CLOSE cur_chk_loan;
      IF  chk_loan_rec.loan_id IS NULL THEN
         fnd_message.set_name('IGF','IGF_SL_COD_NO_ORIG_REC');
         fnd_message.set_token('PERSON_NUMBER', igf_gr_gen.get_per_num(p_base_id));
         fnd_file.put_line(fnd_file.log, fnd_message.get);
         fnd_file.new_line(fnd_file.log, 1);
         RETURN;
      END IF;
    END IF;

    IF p_pgroup_id IS NOT NULL THEN
       OPEN  cur_chk_pidgroup (p_pgroup_id);
       FETCH cur_chk_pidgroup INTO chk_pidgroup_rec;
       CLOSE cur_chk_pidgroup;
       IF chk_pidgroup_rec.group_id IS NULL THEN
         fnd_message.set_name('IGF','IGF_SL_COD_PERSID_GRP_INV');
         fnd_file.put_line(fnd_file.log, fnd_message.get);
         fnd_file.new_line(fnd_file.log, 1);
         RETURN;
       END IF;
    END IF;

    -- End of validations

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','parameter validation successful');
    END IF;
    --
    -- 3. Find Loans to be processed
    --
    gv_dl_version := igf_sl_gen.get_dl_version(lv_cal_type, ln_seq_number);

    lb_record_exist := FALSE;

    IF p_base_id IS NOT NULL THEN
       fnd_message.set_name('IGF','IGF_AW_PROC_STUD');
       fnd_message.set_token('STDNT',igf_gr_gen.get_per_num(p_base_id));
       fnd_file.put_line(fnd_file.log, fnd_message.get);
       FOR rec IN  cur_pick_loans (lv_cal_type,ln_seq_number,
                                   p_base_id,p_report_id,p_attend_id,
                                   p_fund_id,p_loan_id)
       LOOP
          rec.grade_level_code := NVL(rec.override_grade_level_code,rec.grade_level_code);
          process_loan(rec,p_source_id);
          IF NOT lb_record_exist THEN
            lb_record_exist := TRUE;
          END IF;
       END LOOP;
       IF NOT lb_record_exist THEN
          fnd_file.new_line(fnd_file.log, 1);
          fnd_message.set_name('IGF','IGF_SL_NO_LOR_XML_REC');
          fnd_file.put_line(fnd_file.log, fnd_message.get);
          fnd_file.new_line(fnd_file.log, 1);
          RETURN;
       END IF;
    END IF;

    IF p_pgroup_id IS NOT NULL THEN
       fnd_message.set_name('IGF','IGF_AW_PERSON_ID_GROUP');
       fnd_message.set_token('P_PER_GRP',get_grp_name(p_pgroup_id));
       fnd_file.new_line(fnd_file.log, 1);
       fnd_file.put_line(fnd_file.log, fnd_message.get);

       --Bug #5021084
       l_list := igf_ap_ss_pkg.get_pid(p_pgroup_id,lv_status,lv_group_type);

       --Bug #5021084. Passing Group ID if the group type is STATIC.
       IF lv_group_type = 'STATIC' THEN
          OPEN cur_per_grp FOR ' SELECT PARTY_ID FROM HZ_PARTIES WHERE PARTY_ID IN (' || l_list  || ') ' USING p_pgroup_id;
       ELSIF lv_group_type = 'DYNAMIC' THEN
          OPEN cur_per_grp FOR ' SELECT PARTY_ID FROM HZ_PARTIES WHERE PARTY_ID IN (' || l_list  || ') ';
       END IF;

       FETCH cur_per_grp INTO l_person_id;

       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
        fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','Starting to process person group '||p_pgroup_id);
       END IF;

       IF cur_per_grp%NOTFOUND THEN
         CLOSE cur_per_grp;
         fnd_message.set_name('IGF','IGF_DB_NO_PER_GRP');
         fnd_file.put_line(fnd_file.log,fnd_message.get);
         IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','No persons in group '||p_pgroup_id);
         END IF;
       ELSE
         IF cur_per_grp%FOUND THEN -- Check if the person exists in FA.
          lb_record_exist := FALSE;
          LOOP
            ln_base_id := 0;
            lv_person_number  := NULL;
            lv_person_number  := per_in_fa (l_person_id,lv_cal_type,ln_seq_number,ln_base_id);
            IF lv_person_number IS NOT NULL THEN
              IF ln_base_id IS NOT NULL THEN
                 fnd_message.set_name('IGF','IGF_AW_PROC_STUD');
                 fnd_message.set_token('STDNT',lv_person_number);
                 fnd_file.put_line(fnd_file.log, fnd_message.get);
                 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','PIDG base id ' || ln_base_id);
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','PIDG lv_person_number ' || lv_person_number);
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','PIDG l_person_id ' || l_person_id);
                 END IF;
                 FOR rec IN  cur_pick_loans (lv_cal_type,ln_seq_number,
                                             ln_base_id,p_report_id,p_attend_id,
                                             p_fund_id,p_loan_id)
                 LOOP
                   IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','Processing PIDG base id ' || ln_base_id);
                   END IF;
                    rec.grade_level_code := NVL(rec.override_grade_level_code,rec.grade_level_code);
                    process_loan(rec,p_source_id);
                    IF NOT lb_record_exist THEN
                      lb_record_exist := TRUE;
                    END IF;
                 END LOOP;
              ELSE -- log a message and skip this person, base id not found
                 fnd_message.set_name('IGF','IGF_GR_LI_PER_INVALID');
                 fnd_message.set_token('PERSON_NUMBER',lv_person_number);
                 fnd_message.set_token('AWD_YR',igf_gr_gen.get_alt_code(lv_cal_type,ln_seq_number));
                 fnd_file.put_line(fnd_file.log,fnd_message.get);
                 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
                   fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug',igf_gr_gen.get_per_num_oss(l_person_id) || ' not in FA');
                 END IF;
              END IF; -- base id not found
            ELSE
              fnd_message.set_name('IGF','IGF_AP_PE_NOT_EXIST');
              fnd_file.put_line(fnd_file.log,RPAD(' ',5) ||fnd_message.get);
            END IF; -- person number not null

          FETCH   cur_per_grp INTO l_person_id;
          EXIT WHEN cur_per_grp%NOTFOUND;
          END LOOP;
          IF NOT lb_record_exist THEN
            fnd_file.new_line(fnd_file.log, 1);
            fnd_message.set_name('IGF','IGF_SL_NO_LOR_XML_REC');
            fnd_file.put_line(fnd_file.log, fnd_message.get);
            fnd_file.new_line(fnd_file.log, 1);
            CLOSE cur_per_grp;
            RETURN;
          END IF;
          CLOSE cur_per_grp;
         END IF; -- group found
       END IF; -- group not found
    END IF; -- pid group is not null

    -- base id or person group id is not given, so process records for given
    -- input combination
    IF p_base_id IS NULL AND p_pgroup_id IS NULL THEN
      lb_record_exist := FALSE;
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug',' processing for other combo');
      END IF;
      FOR rec IN  cur_pick_loans (lv_cal_type,ln_seq_number,
                                  p_base_id,p_report_id,p_attend_id,
                                  p_fund_id,p_loan_id)
      LOOP
        rec.grade_level_code := NVL(rec.override_grade_level_code,rec.grade_level_code);
        process_loan(rec,p_source_id);
        IF NOT lb_record_exist THEN
          lb_record_exist := TRUE;
        END IF;
      END LOOP;
      IF NOT lb_record_exist THEN
        fnd_file.new_line(fnd_file.log, 1);
        fnd_message.set_name('IGF','IGF_SL_NO_LOR_XML_REC');
        fnd_file.put_line(fnd_file.log, fnd_message.get);
        fnd_file.new_line(fnd_file.log, 1);
        RETURN;
      END IF;
    END IF;
    --
    -- End of Step 3
    --

    -- 6. Submit Business Event, only if there are records to be put
    OPEN  cur_cod_dtls(gv_document_id_txt);
    FETCH cur_cod_dtls INTO cod_dtls_rec;
    CLOSE cur_cod_dtls;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug',' gv_document_id_txt ' || gv_document_id_txt);
    END IF;

    IF cod_dtls_rec.document_id_txt IS NULL THEN
        fnd_message.set_name('IGF','IGF_SL_COD_NO_DL_REC');
        fnd_file.new_line(fnd_file.log, 1);
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        fnd_file.new_line(fnd_file.log, 1);
        RETURN;
    ELSE
        SELECT COUNT(*)  INTO ln_top FROM igf_sl_cod_top_v    WHERE document_id_txt = gv_document_id_txt;
        SELECT COUNT(*)  INTO ln_sm  FROM igf_sl_rep_smry_v   WHERE document_id_txt = gv_document_id_txt;
        SELECT COUNT(*)  INTO ln_rs  FROM igf_sl_rep_rs_v     WHERE document_id_txt = gv_document_id_txt;
        SELECT COUNT(*)  INTO ln_rp  FROM igf_sl_cod_rep_v    WHERE document_id_txt = gv_document_id_txt;
        SELECT COUNT(*)  INTO ln_as  FROM igf_sl_rep_as_v     WHERE document_id_txt = gv_document_id_txt;
        SELECT COUNT(*)  INTO ln_st  FROM igf_sl_rep_stdnt_v  WHERE document_id_txt = gv_document_id_txt;
        SELECT COUNT(*)  INTO ln_db  FROM igf_sl_db_cod_rep_v WHERE document_id_txt = gv_document_id_txt;
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','ln_top ' ||ln_top);
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','ln_sm  ' ||ln_sm );
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','ln_rs  ' ||ln_rs );
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','ln_rp  ' ||ln_rp );
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','ln_as  ' ||ln_as );
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','ln_st  ' ||ln_st );
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug','ln_db  ' ||ln_db );
        END IF;
        IF ln_top = 0 OR ln_sm = 0 OR ln_rs = 0 OR ln_rp = 0 OR ln_as = 0 OR ln_st = 0 THEN
          fnd_message.set_name('IGF','IGF_SL_COD_NO_DL_REC');
          fnd_file.put_line(fnd_file.log,fnd_message.get);
          RETURN;
        ELSE
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug',' before submit event ');
          END IF;
          submit_xml_event (gv_document_id_txt);
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
            fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.main.debug',' after submit event ');
          END IF;
        END IF;
    END IF;

    COMMIT;
    EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    retcode := 2;
    errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
    fnd_file.put_line(fnd_file.log,SQLERRM);
    igs_ge_msg_stack.conc_exception_hndl;
  END main;
/* -----------------------------------------------------------------------------------
   Know limitations, enhancements or remarks
   Change History:
   -----------------------------------------------------------------------------------
   Who        When             What
   tsailaja		  15/Jan/2006     Bug 4947880 Added invocation of igf_aw_gen.set_org_id(NULL);
  -----------------------------------------------------------------------------------
*/
  PROCEDURE print_xml(errbuf        OUT NOCOPY VARCHAR2,
                      retcode       OUT NOCOPY NUMBER,
                      p_document_id_txt VARCHAR2)
  IS

    CURSOR c_get_parameters
    IS
    SELECT meaning, lookup_code
      FROM igf_lookups_view
     WHERE lookup_type = 'IGF_GE_PARAMETERS'
       AND lookup_code IN ('PARAMETER_PASS',
                           'DOCUMENT_ID');

    parameter_rec           c_get_parameters%ROWTYPE;

    lv_parameter_pass       VARCHAR2(80);
    lv_document_id_txt          VARCHAR2(80);
    lc_newxmldoc            CLOB;
    lv_rowid                ROWID;

  BEGIN
	igf_aw_gen.set_org_id(NULL);
    --
    -- Steps
    --
    -- 1. Print parameters
    -- 2. Validate parameters
    -- 3. Edit CLOB for additional tags
    -- 4. Update DOC_DTLS table
    -- 5. Update LOR_LOC table, DISB table for Status
    -- 5. Print CLOB on the output file
    --

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.print_xml.debug','p doc id ' || p_document_id_txt);
    END IF;

    OPEN c_get_parameters;
    LOOP
      FETCH c_get_parameters INTO  parameter_rec;
      EXIT WHEN c_get_parameters%NOTFOUND;

      IF parameter_rec.lookup_code ='PARAMETER_PASS' THEN
        lv_parameter_pass   := TRIM(parameter_rec.meaning);
      ELSIF parameter_rec.lookup_code ='DOCUMENT_ID' THEN
        lv_document_id_txt      := TRIM(parameter_rec.meaning);
      END IF;
    END LOOP;
    CLOSE c_get_parameters;

    fnd_file.new_line(fnd_file.log,1);
    fnd_file.put_line(fnd_file.log, lv_parameter_pass); --------------Parameters Passed--------------
    fnd_file.new_line(fnd_file.log,1);

    fnd_file.put_line(fnd_file.log, RPAD(lv_document_id_txt,40) || ' : '|| p_document_id_txt);

    fnd_file.new_line(fnd_file.log,1);
    fnd_file.put_line(fnd_file.log, '--------------------------------------------------------');
    fnd_file.new_line(fnd_file.log,1);

    edit_clob(p_document_id_txt,lc_newxmldoc,lv_rowid);
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.print_xml.debug','After edit CLOB ');
    END IF;
    --
    -- update loan status or loan change status to sent
    -- update disb status to sent
    update_status(p_document_id_txt);
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.print_xml.debug','Calling update status, doc id ' || p_document_id_txt);
    END IF;
    --
    --
    -- print xml outfile
    -- update clob into database
    print_out_xml(lc_newxmldoc);
    igf_sl_cod_doc_dtls_pkg.update_row(x_rowid            => lv_rowid,
                                       x_document_id_txt  => p_document_id_txt,
                                       x_outbound_doc     => lc_newxmldoc,
                                       x_inbound_doc      => NULL,
                                       x_send_date        => TRUNC(SYSDATE),
                                       x_ack_date         => NULL,
                                       x_doc_status       => 'S',
                                       x_doc_type         => 'DL',
                                       x_full_resp_code   =>  NULL,
                                       x_mode             => 'R');

    COMMIT;
    EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    retcode := 2;
    errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION');
    fnd_file.put_line(fnd_file.log,SQLERRM);
    igs_ge_msg_stack.conc_exception_hndl;
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.print_xml.debug','sqlerrm ' || SQLERRM);
    END IF;
    app_exception.raise_exception;

  END print_xml;

  PROCEDURE store_xml(itemtype   IN VARCHAR2,
                      itemkey    IN VARCHAR2,
                      actid      IN NUMBER,
                      funcmode   IN VARCHAR2,
                      resultout  OUT NOCOPY VARCHAR2)
  IS

    l_clob          CLOB;
    l_event         wf_event_t;
    ln_request_id   NUMBER;
    lv_rowid        ROWID;
    lv_document_id_txt  VARCHAR2(30);

  BEGIN

    --
    -- Steps
    -- 1. Read event data
    -- 2. Push xml into table
    -- 3. Launch Concurrent Request
    --
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.store_xml.debug',' before reading lob ');
    END IF;
    l_event     :=    wf_engine.getitemattrevent(
                      itemtype,
                      itemkey,
                      'ECX_EVENT_MESSAGE');

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.store_xml.debug',' after reading lob ');
    END IF;
    l_clob      :=    l_event.geteventdata;

    IF DBMS_LOB.GETLENGTH(l_clob) = 0 THEN
       resultout := 'EMPTY_CLOB';
    ELSE

       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
         fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.store_xml.debug',' get doc id ');
       END IF;
       lv_document_id_txt := NULL;
       lv_document_id_txt := wf_engine.getitemattrtext(
                          itemtype,
                          itemkey,
                          'ECX_PARAMETER1');
       IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
          fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.store_xml.debug',' get doc id = ' || lv_document_id_txt);
       END IF;

       IF lv_document_id_txt IS NULL THEN
          resultout := 'DOCUMENT_ID_NOT_FOUND';
       ELSE
          lv_rowid    := NULL;
          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.store_xml.debug',' insert into doc dtls ');
          END IF;

          igf_sl_cod_doc_dtls_pkg.insert_row(
                                      x_rowid            => lv_rowid,
                                      x_document_id_txt  => lv_document_id_txt,
                                      x_outbound_doc     => l_clob,
                                      x_inbound_doc      => NULL,
                                      x_send_date        => NULL,
                                      x_ack_date         => NULL,
                                      x_doc_status       => 'R',
                                      x_doc_type         => 'DL',
                                      x_full_resp_code   =>  NULL,
                                      x_mode             => 'R');

          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.store_xml.debug',' before submitting req ');
          END IF;

          ln_request_id := apps.fnd_request.submit_request(
                                               'IGF','IGFSLJ19','','',FALSE,
                                               lv_document_id_txt,CHR(0),
                                               '','','','','','','','',
                                               '','','','','','','','','','',
                                               '','','','','','','','','','',
                                               '','','','','','','','','','',
                                               '','','','','','','','','','',
                                               '','','','','','','','','','',
                                               '','','','','','','','','','',
                                               '','','','','','','','','','',
                                               '','','','','','','','','','',
                                               '','','','','','','','','','');


          IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
           fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.store_xml.debug',' request id ' || ln_request_id);
          END IF;

          IF ln_request_id = 0 THEN
             resultout := 'CONCURRENT_REQUEST_FAILED';
          ELSE
             resultout := 'SUCCESS';
          END IF; -- request failed
       END IF; -- doc id is null
    END IF; -- lob length

    EXCEPTION
    WHEN OTHERS THEN
    resultout := 'E';
    wf_core.context ('IGF_SL_DL_GEN_XML',
                      'STORE_XML', itemtype,
                       itemkey,to_char(actid), funcmode);
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
      fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_dl_gen_xml.store_xml.debug','sqlerrm ' || SQLERRM);
    END IF;
  END store_xml;

END igf_sl_dl_gen_xml;

/
