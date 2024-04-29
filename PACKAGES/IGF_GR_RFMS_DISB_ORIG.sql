--------------------------------------------------------
--  DDL for Package IGF_GR_RFMS_DISB_ORIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_GR_RFMS_DISB_ORIG" AUTHID CURRENT_USER AS
/* $Header: IGFGR03S.pls 120.0 2005/06/01 15:19:30 appldev noship $ */
  /*************************************************************
  Created By : sjadhav
  Date Created On : 2000/01/03
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who           When            What
  -----------------------------------------------------------------------------------
  ugummall      08-JAN-2004     Bug 3318202. Changed the order of parameters and
                                removed the parameter p_org_id in main procedure.
  -----------------------------------------------------------------------------------
  ugummall      06-NOV-2003     Bug 3102439. FA 126 - Multiple FA Offices.
                                Added two new parameters namely p_reporting_pell and
                                p_attending_pell to main procedure.
  -----------------------------------------------------------------------------------
  --
  -- bug 2216956
  -- sjadhav, FEB13th,2002
  --
  -- Removed flag and disbursement number parameters
  -- Added Award Year parameter to main_ack
  --
  -- Bug ID : 1731177
  -- Who           When           What
  -- sjadhav       19-apr-2001    Added main_ack to process
  --                              rfms disb ack . this will get
  --                              called from conc. mgr.
  --                              Removed l_mode from main
  --

  (reverse chronological order - newest change first)
  ***************************************************************/




PROCEDURE main(
               errbuf           OUT   NOCOPY VARCHAR2,
               retcode          OUT   NOCOPY NUMBER,
               award_year       IN           VARCHAR2,
               p_reporting_pell IN           VARCHAR2,
               p_attending_pell IN           VARCHAR2,
               p_trans_type     IN           VARCHAR2,
               base_id          IN           igf_gr_rfms_all.base_id%TYPE,
               p_dummy          IN           VARCHAR2,
               p_pers_id_grp    IN           NUMBER
              );

PROCEDURE main_ack( errbuf      OUT NOCOPY   VARCHAR2,
                    retcode     OUT NOCOPY   NUMBER,
                    p_awd_yr    IN    VARCHAR2,
                    p_org_id    IN    NUMBER);


END igf_gr_rfms_disb_orig;

 

/
