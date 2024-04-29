--------------------------------------------------------
--  DDL for Package IGS_AD_IMP_027
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_IMP_027" AUTHID CURRENT_USER AS
/* $Header: IGSADC7S.pls 115.3 2003/12/09 11:57:46 akadam noship $ */
/*******************************************************************************
Created by  : Ramesh Rengarajan
Date created: 21 APR 2003

Purpose:
  To Import Legacy Data

Known limitations/enhancements and/or remarks:

Change History: (who, when, what: )
Who             When            What
**********************************************************************************/
PROCEDURE prc_appl_hist (
           p_interface_run_id  igs_ad_interface_all.interface_run_id%TYPE,
           p_enable_log   VARCHAR2,
           p_rule     VARCHAR2);

PROCEDURE prc_appl_inst_hist(
           p_interface_run_id  igs_ad_interface_all.interface_run_id%TYPE,
           p_enable_log   VARCHAR2,
           p_rule     VARCHAR2);

END IGS_AD_IMP_027;

 

/
