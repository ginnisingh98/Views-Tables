--------------------------------------------------------
--  DDL for Package Body IGF_SL_EDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_EDIT" AS
/* $Header: IGFSL10B.pls 120.0 2005/06/01 13:58:43 appldev noship $ */

PROCEDURE insert_edit(p_loan_number   igf_sl_edit_report.loan_number%TYPE,
                      p_orig_chg_code igf_sl_edit_report.orig_chg_code%TYPE,
                      p_err_type      igf_sl_edit_report.sl_error_type%TYPE,
                      p_err_code      igf_sl_edit_report.sl_error_code%TYPE,
                      p_field_name    igf_sl_edit_report.field_name%TYPE,
                      p_field_value   igf_sl_edit_report.field_value%TYPE)
IS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/07
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  lv_rowid     VARCHAR2(25);
  lv_edtr_id   NUMBER;
BEGIN

  IF p_err_code NOT IN ('0','00','000','0000','00000') THEN
    igf_sl_edit_report_pkg.insert_row (
      x_mode                              => 'R',
      x_rowid                             => lv_rowid,
      x_edtr_id                           => lv_edtr_id,
      x_loan_number                       => p_loan_number,
      x_orig_chg_code                     => p_orig_chg_code,
      x_sl_error_type                     => p_err_type,
      x_sl_error_code                     => p_err_code,
      x_field_name                        => p_field_name,
      x_field_value                       => p_field_value
    );
  END IF;
EXCEPTION
WHEN others THEN
   fnd_message.set_name('IGF','IGF_GE_UNHANDLED_EXP');
   fnd_message.set_token('NAME','igf_sl_edit.insert_edit');
   igs_ge_msg_stack.add;
   app_exception.raise_exception;
END insert_edit;


PROCEDURE delete_edit(p_loan_number   igf_sl_edit_report.loan_number%TYPE,
                      p_orig_chg_code igf_sl_edit_report.orig_chg_code%TYPE)
IS
  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/07
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   lv_row_id  VARCHAR2(25);
   CURSOR c_tbh_cur IS
   SELECT rowid row_id FROM igf_sl_edit_report
   WHERE loan_number   = p_loan_number
   AND   orig_chg_code = p_orig_chg_code;
BEGIN

   FOR tbh_rec in c_tbh_cur LOOP
       igf_sl_edit_report_pkg.delete_row (tbh_rec.row_id);
   END LOOP;

END delete_edit;


END igf_sl_edit;

/
