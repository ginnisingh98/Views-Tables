--------------------------------------------------------
--  DDL for Package IGS_AD_IMP_004
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_IMP_004" AUTHID CURRENT_USER AS
/* $Header: IGSAD82S.pls 115.12 2003/12/09 12:23:21 pbondugu ship $ */

PROCEDURE  PRC_APPCLN (
 p_interface_run_id  igs_ad_interface_all.interface_run_id%TYPE,
p_rule     VARCHAR2,
p_enable_log   VARCHAR2,
p_legacy_ind IN VARCHAR2);



END Igs_Ad_Imp_004;

 

/
