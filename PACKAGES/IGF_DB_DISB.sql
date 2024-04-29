--------------------------------------------------------
--  DDL for Package IGF_DB_DISB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_DB_DISB" AUTHID CURRENT_USER AS
/* $Header: IGFDB01S.pls 115.9 2003/12/04 15:48:12 sjadhav ship $ */

-----------------------------------------------------------------------------------
--
--   Created By   : mesriniv
--   Date Created By  : 2000/12/15
--   Purpose    : To Create the Actual Disbursement
--          Records for Awards
--
--   Known Limitations,Enhancements or Remarks
--   Change History :
-----------------------------------------------------------------------------------
-- sjadhav     3-Dec-2003     FA 131 Build changes, Bug 3252832
--                            Removed chk_att_result
-----------------------------------------------------------------------------------
--   Bug No: 2154941
--   sjadhav,Jan 07,2002
--   1. Addition of Run For,Student ID , Person Group, Log Detail Parameters
--
-----------------------------------------------------------------------------------

-- This is the callable from Concurrent Manager

 PROCEDURE disb_process(errbuf            OUT NOCOPY   VARCHAR2,
                        retcode           OUT NOCOPY   NUMBER,
                        p_award_year      IN           VARCHAR2,
                        p_run_for         IN           VARCHAR2,
                        p_per_grp_id      IN           NUMBER,
                        p_base_id         IN           igf_ap_fa_base_rec_all.base_id%TYPE,
                        p_fund_id         IN           igf_aw_fund_mast_all.fund_id%TYPE,
                        p_log_det         IN           VARCHAR2 DEFAULT 'N',
                        p_org_id          IN           NUMBER
                        );

--
-- Parameters
--
-- p_award_year         Award Year
-- p_run_for            Run For ( P - Person Group, S - Student, F - Fund )
-- p_per_grp_id         Person Group ID
-- p_base_id            Base ID
-- p_fund_id            Fund ID
-- p_log_det            Log Detail ( Y - Yes , N - No )
-- p_org_id             Org ID


-- This process is executed via Online Disbursement on Disbursement Detail Screens

PROCEDURE process_student( p_base_id        IN             igf_ap_fa_base_rec_all.base_id%TYPE,
                           p_result         IN OUT NOCOPY  VARCHAR2,
                           p_fund_id        IN             igf_aw_fund_mast_all.fund_id%TYPE DEFAULT NULL,
                           p_award_id       IN             igf_aw_award_all.award_id%TYPE DEFAULT NULL,
                           p_disb_num       IN             igf_aw_awd_disb_all.disb_num%TYPE DEFAULT NULL
                           );


-- Process to Cancel Disbursements
-- Row ID is from igf_aw_awd_disb_all table

PROCEDURE revert_disb ( p_row_id     IN   ROWID,
                        p_flag       IN   VARCHAR2,
                        p_fund_type  IN   VARCHAR2);


END igf_db_disb;

 

/
