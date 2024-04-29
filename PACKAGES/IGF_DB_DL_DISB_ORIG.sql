--------------------------------------------------------
--  DDL for Package IGF_DB_DL_DISB_ORIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_DB_DL_DISB_ORIG" AUTHID CURRENT_USER AS
/* $Header: IGFDB02S.pls 115.9 2003/10/20 05:59:45 ugummall ship $ */


  /****************************************************************************
  Created By : prchandr
  Date Created On : 2000/12/13
  Purpose :Package specification for the direct loan disbursement origination change Process
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  ugummall        17-OCT-2003     Bug 3102439. FA 126 Multiple FA Offices.
                                  Added two new parameters to Disb_originate process.
  (reverse chronological order - newest change first)
  *****************************************************************************/




PROCEDURE Disb_originate(errbuf  OUT NOCOPY     VARCHAR2,
                         retcode  OUT NOCOPY    NUMBER,
                         p_award_year    VARCHAR2,
                         p_org_id  IN    NUMBER,
                         school_type    IN    VARCHAR2,
                         p_school_code  IN    VARCHAR2
                        );

END igf_db_dl_disb_orig;

 

/
