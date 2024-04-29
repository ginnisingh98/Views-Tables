--------------------------------------------------------
--  DDL for Package IGS_AD_IMP_014
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_IMP_014" AUTHID CURRENT_USER AS
/* $Header: IGSAD92S.pls 115.10 2003/12/09 11:57:23 akadam ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    27-AUG-2001     Bug No. 1956374 .The procedure declaration of PRC_RELNS_EMP_DTLS
  --                            removed .
  -------------------------------------------------------------------------------------------
        -- Added by rgangara 26-06-2001 Bug#1834307   Modelling and Forecasting_SDQ DLD
PROCEDURE prc_pe_recruitments_dtl (
                  p_interface_run_id  IN NUMBER,
                  p_enable_log        IN VARCHAR2,
                  p_rule              IN VARCHAR2 );

END IGS_AD_IMP_014;

 

/
