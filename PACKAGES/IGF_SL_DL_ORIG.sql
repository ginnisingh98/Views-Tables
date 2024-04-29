--------------------------------------------------------
--  DDL for Package IGF_SL_DL_ORIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_DL_ORIG" AUTHID CURRENT_USER AS
/* $Header: IGFSL03S.pls 115.9 2003/10/20 05:42:16 ugummall ship $ */

  /*************************************************************
  Created By : venagara
  Date Created On : 2000/11/13
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  ugummall        17-OCT-2003     Bug 3102439. FA 126 Multiple FA Offices.
                                  added two new parameters to dl_originate.
  (reverse chronological order - newest change first)
  ***************************************************************/

PROCEDURE dl_originate(errbuf  OUT NOCOPY    VARCHAR2,
                       retcode OUT NOCOPY    NUMBER,
                       p_award_year   VARCHAR2,
                       p_dl_loan_catg igf_lookups_view.lookup_code%TYPE,
                       p_loan_number  igf_sl_loans_all.loan_number%TYPE,
                       p_org_id IN    NUMBER,
                       school_type   IN   VARCHAR2,
                       p_school_code IN   VARCHAR2);

END igf_sl_dl_orig;

 

/
