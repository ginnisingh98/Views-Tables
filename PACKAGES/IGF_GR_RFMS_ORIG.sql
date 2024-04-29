--------------------------------------------------------
--  DDL for Package IGF_GR_RFMS_ORIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_GR_RFMS_ORIG" AUTHID CURRENT_USER AS
/* $Header: IGFGR02S.pls 115.13 2004/01/08 13:01:42 ugummall ship $ */
  /*************************************************************
  Created By : sjadhav
  Date Created On : 2000/01/03
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  ugummall        08-Jan-2003     Bug 3318202. Changed the order of parameters and removed
                                  the parameter p_org_id in main.
  ugummall        03-DEC-2003     Bug 3252832. FA 131 - COD Updates.
                                  Added two extra parameters namely p_persid_grp
                                  and p_orig_run_mode.
  ugummall        04-NOV-2003     Bug 3102439. FA 126 - Multiple FA Offices.
                                  Added two extra parameters namely p_reporting_pell
                                  and p_attending_pell to main procedure.

  (reverse chronological order - newest change first)
  --
  -- sjadhav, Feb 07,2002
  -- Added Award Year parameter
  --
  -- Bug Id : 1731177
  -- who          when            what
  -- sjadhav      19-apr-2001     added main_ack to the package.
  --                              removed l_mode parameter from
  --                              main.
  --                              Now main calls only origination
  --                              and main_ack calls acknow.
  --
  ***************************************************************/




PROCEDURE main(  errbuf         OUT NOCOPY   VARCHAR2,
                 retcode        OUT NOCOPY   NUMBER,
                 award_year     IN    VARCHAR2,
                 p_reporting_pell   IN    VARCHAR2,
                 p_attending_pell   IN    VARCHAR2,
                 base_id        IN    igf_gr_rfms_all.base_id%TYPE,
                 p_persid_grp       IN    VARCHAR2,
                 p_orig_run_mode    IN    VARCHAR2
                 );

PROCEDURE main_ack( errbuf      OUT NOCOPY   VARCHAR2,
                    retcode     OUT NOCOPY   NUMBER,
                    p_awd_yr    IN    VARCHAR2,
                    p_org_id    IN    NUMBER);



END igf_gr_rfms_orig;

 

/
