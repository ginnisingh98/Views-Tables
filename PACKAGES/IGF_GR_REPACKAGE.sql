--------------------------------------------------------
--  DDL for Package IGF_GR_REPACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_GR_REPACKAGE" AUTHID CURRENT_USER AS
/* $Header: IGFGR07S.pls 120.1 2005/09/08 14:41:40 appldev noship $ */

/***************************************************************
   Created By		:	prchandr
   Date Created By	:	2001/7/06
   Purpose		:	Package for Repackaging
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			When		     What
   veramach 02-Dec-2003  Adds p_persod_grp,p_test_run,p_cancel_invalid_awds as parameters to repackage_pell
 ***************************************************************/

  g_test_run             VARCHAR2(80) := NULL;
  g_cancel_invalid_awds  VARCHAR2(80) := NULL;

PROCEDURE repackage_pell(
                         errbuf                OUT NOCOPY  VARCHAR2,
                         retcode               OUT NOCOPY  NUMBER,
                         p_award_year          IN          VARCHAR2,
                         p_base_id             IN          igf_ap_fa_base_rec_all.base_id%TYPE,
                         p_org_id              IN          igf_aw_award_all.org_id%TYPE,
                         p_persid_grp          IN          igs_pe_persid_group_all.group_id%TYPE,
                         p_test_run            IN          VARCHAR2,
                         p_cancel_invalid_awds IN          VARCHAR2
                        );

 END igf_gr_repackage;

 

/
