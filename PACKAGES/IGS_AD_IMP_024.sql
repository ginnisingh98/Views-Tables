--------------------------------------------------------
--  DDL for Package IGS_AD_IMP_024
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_IMP_024" AUTHID CURRENT_USER AS
/* $Header: IGSADB2S.pls 115.3 2003/12/09 13:40:10 pbondugu ship $ */
 PROCEDURE prc_trscrpt(
p_interface_run_id  igs_ad_interface_all.interface_run_id%TYPE,
p_rule     VARCHAR2,
p_enable_log   VARCHAR2);

END igs_ad_imp_024;

 

/
