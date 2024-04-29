--------------------------------------------------------
--  DDL for Package IGS_AD_IMP_010
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_IMP_010" AUTHID CURRENT_USER AS
/* $Header: IGSAD88S.pls 120.0 2005/06/01 22:17:13 appldev noship $ */

/******************************************************************
Created By:
Date Created By:
Purpose:
Known limitations,enhancements,remarks:
Change History
Who        When          What
samaresh   02-FEB-2002	 Removed the procedure crt_appcln, as this happens
                         through igsad82b.pls.
			 bug # 2191058
vchappid   29-Aug-2001   Added new parameters into function calls, Enh Bug#1964478
******************************************************************/

 PROCEDURE admp_val_pappl_nots(
                        p_interface_run_id  IN NUMBER,
                        p_enable_log        IN VARCHAR2,
                        p_category_meaning  IN VARCHAR2,
                        p_rule              IN VARCHAR2 );

 PROCEDURE  prcs_applnt_edu_goal_dtls(
                        p_interface_run_id  IN NUMBER,
                        p_enable_log        IN VARCHAR2,
                        p_category_meaning  IN VARCHAR2,
                        p_rule              IN VARCHAR2 );

 PROCEDURE prc_apcnt_uset_apl(
                        p_interface_run_id  IN NUMBER,
                        p_enable_log        IN VARCHAR2,
                        p_category_meaning  IN VARCHAR2,
                        p_rule              IN VARCHAR2 );

END Igs_Ad_Imp_010;

 

/
