--------------------------------------------------------
--  DDL for Package IGF_SL_EDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_EDIT" AUTHID CURRENT_USER AS
/* $Header: IGFSL10S.pls 120.0 2005/06/01 14:47:03 appldev noship $ */

  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/07
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

PROCEDURE insert_edit(p_loan_number   igf_sl_edit_report.loan_number%TYPE,
                      p_orig_chg_code igf_sl_edit_report.orig_chg_code%TYPE,
                      p_err_type      igf_sl_edit_report.sl_error_type%TYPE,
                      p_err_code      igf_sl_edit_report.sl_error_code%TYPE,
                      p_field_name    igf_sl_edit_report.field_name%TYPE,
                      p_field_value   igf_sl_edit_report.field_value%TYPE);

PROCEDURE delete_edit(p_loan_number   igf_sl_edit_report.loan_number%TYPE,
                      p_orig_chg_code igf_sl_edit_report.orig_chg_code%TYPE);


END igf_sl_edit;

 

/
