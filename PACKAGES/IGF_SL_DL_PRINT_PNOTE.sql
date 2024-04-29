--------------------------------------------------------
--  DDL for Package IGF_SL_DL_PRINT_PNOTE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_DL_PRINT_PNOTE" AUTHID CURRENT_USER AS
/* $Header: IGFSL16S.pls 115.5 2002/11/28 14:35:15 nsidana noship $ */
/***************************************************************
   Created By		:	avenkatr
   Date Created By	:	2001/05/08
   Purpose		:	To Print and process the Promissory note
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			When		What
***************************************************************/


  PROCEDURE process_pnote(
  ERRBUF			OUT NOCOPY		VARCHAR2,
  RETCODE			OUT NOCOPY		NUMBER,
  p_award_year 		IN 		VARCHAR2,
  p_loan_catg			IN		igf_lookups_view.lookup_code%TYPE,
  p_base_id                 IN            igf_ap_fa_base_rec_all.base_id%TYPE,
  p_loan_number		IN		igf_sl_loans_v.loan_number%TYPE,
  p_org_id                  IN            NUMBER
  );


END igf_sl_dl_print_pnote;

 

/
