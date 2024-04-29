--------------------------------------------------------
--  DDL for Package IGF_SL_DL_CHG_ORIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_DL_CHG_ORIG" AUTHID CURRENT_USER AS
/* $Header: IGFSL05S.pls 115.9 2003/10/20 05:47:22 ugummall ship $ */


  /****************************************************************************
  Created By : prchandr
  Date Created On : 2000/12/13
  Purpose :Package specification for the direct loan origination change Process
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  ugummall        17-OCT-2003     Bug 3102439. FA 126 Multiple FA Offices.
                                  Added two new parameters to chg_originate process.
  (reverse chronological order - newest change first)
  *****************************************************************************/




PROCEDURE chg_originate(errbuf  OUT NOCOPY    VARCHAR2,
                       retcode  OUT NOCOPY    NUMBER,
                       p_award_year    VARCHAR2,
                       p_dl_loan_catg  igf_lookups_view.lookup_code%TYPE,
                       p_org_id IN     NUMBER,
                       school_type    IN    VARCHAR2,
                       p_school_code  IN    VARCHAR2
                       );

END igf_sl_dl_chg_orig;

 

/
