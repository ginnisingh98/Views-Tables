--------------------------------------------------------
--  DDL for Package IGF_GR_VERIFY_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_GR_VERIFY_PROCESS" AUTHID CURRENT_USER AS
/* $Header: IGFGR09S.pls 115.0 2003/02/07 14:18:20 smvk noship $ */

  /***************************************************************
    Created By		: smvk
    Date Created By	: 06-Feb-2003
    Purpose		: To update the Verification status of the person in the person id group p_c_per_grp
                          whose current verification status is p_c_from to p_c_to.

    Known Limitations,Enhancements or Remarks
    Change History	:
    Who			When		What
  ***************************************************************/

PROCEDURE main(
    errbuf               OUT NOCOPY		VARCHAR2,
    retcode              OUT NOCOPY		NUMBER,
    p_c_awd_yr           IN                     VARCHAR2,
    p_n_per_grp_id       IN                     NUMBER,
    p_c_from             IN                     VARCHAR2,
    p_c_to               IN                     VARCHAR2
  );

END igf_gr_verify_process;

 

/
