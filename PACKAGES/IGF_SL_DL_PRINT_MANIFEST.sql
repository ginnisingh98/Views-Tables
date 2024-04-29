--------------------------------------------------------
--  DDL for Package IGF_SL_DL_PRINT_MANIFEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_DL_PRINT_MANIFEST" AUTHID CURRENT_USER AS
/* $Header: IGFSL17S.pls 115.5 2002/11/28 14:35:27 nsidana noship $ */
/***************************************************************
   Created By		:	rboddu
   Date Created By	:	2001/05/15
   Purpose		:	The Direct Loan Manifest Promissory Note Process
     picks up the Loans which have their PNote Status in the Direct Loan Orignation
     Screen as 'Signed' for different sets of user inputs like "for a particular loan
     ID/Student for a particular Loan Category(Stafford/PLUS), for a particular Award
     Year and inserts the data into Direct Loan Manifest table, and sets the Promissory
     Note Status for these Direct Loans to Manifested.
   Change History	:2216956
   Who			When		What
   adhawan              21-feb-2002     changed student id to base id as parameter
***************************************************************/


  PROCEDURE process_manifest(
  ERRBUF			OUT NOCOPY		VARCHAR2,
  RETCODE			OUT NOCOPY		NUMBER,
  p_award_year 			IN 		VARCHAR2,
  p_loan_catg			IN		igf_lookups_view.lookup_code%TYPE,
  p_base_id                     IN              igf_aw_award.base_id%TYPE,
  p_loan_number			IN		igf_sl_loans_v.loan_number%TYPE,
  p_org_id                      IN              NUMBER
  );


END igf_sl_dl_print_manifest;

 

/
