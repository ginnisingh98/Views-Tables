--------------------------------------------------------
--  DDL for Package IGS_AD_IMP_016
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_IMP_016" AUTHID CURRENT_USER AS
/* $Header: IGSAD94S.pls 115.9 2003/12/09 11:57:34 akadam ship $ */
/******************************************************************
Created By:
Date Created By:
Purpose:
Known limitations,enhancements,remarks:
Change History
Who        When          What
samaresh   05-FEB-2002	 Obsoleted this job as a part of bug# 2191058,
-------------------------------------------------------------------*/
PROCEDURE prc_tst_rslts(
                        p_interface_run_id  IN NUMBER,
                        p_enable_log        IN VARCHAR2,
                        p_rule              IN VARCHAR2 );


END igs_ad_imp_016;

 

/
