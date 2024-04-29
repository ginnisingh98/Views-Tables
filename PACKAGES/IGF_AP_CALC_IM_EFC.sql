--------------------------------------------------------
--  DDL for Package IGF_AP_CALC_IM_EFC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_CALC_IM_EFC" AUTHID CURRENT_USER AS
/* $Header: IGFAP45S.pls 115.1 2003/10/28 13:46:52 veramach noship $ */
------------------------------------------------------------------
--Created by  : veramach, Oracle India
--Date created: 08-OCT-2003
--
--Purpose: This package calls the user hook for calculating IM EFC if INAS is integrated
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
-------------------------------------------------------------------

PROCEDURE main(
                errbuf           OUT NOCOPY    VARCHAR2,
                retcode          OUT NOCOPY    NUMBER,
                p_award_year     IN            VARCHAR2,
                p_base_id        IN            igf_ap_fa_base_rec_all.base_id%TYPE,
                p_persid_grp     IN            igs_pe_persid_group_all.group_id%TYPE
          );

END igf_ap_calc_im_efc;

 

/
