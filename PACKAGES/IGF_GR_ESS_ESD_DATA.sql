--------------------------------------------------------
--  DDL for Package IGF_GR_ESS_ESD_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_GR_ESS_ESD_DATA" AUTHID CURRENT_USER AS
/* $Header: IGFGR06S.pls 115.7 2002/11/28 14:20:58 nsidana ship $ */

/***************************************************************
   Created By		:	adhawan
   Date Created By	:	2001/01/09
   Purpose		:       To upload data into
   IGF_GR_ELEC_STAT_SUM and  IGF_GR_ELEC_STAT_DET tables
   Known Limitations,Enhancements or Remarks:
   Change History	:Bug ID: 1694179 : The p_org_id was not passed as the parameter
   Who			When		What
   adhawan		21-03-2001      --Added org_id in the parameter
   					--lv_rowid :=NULL;
--
-- Bug ID :  1731177
-- who       when            what
-- sjadhav   16-apr-2001     Added main_s to call summary procedure
--
--

 ***************************************************************/


 PROCEDURE main(
    errbuf               OUT NOCOPY		VARCHAR2,
    retcode              OUT NOCOPY		NUMBER,
    p_awd_yr             IN             VARCHAR2,
    p_org_id		 IN	   	NUMBER
  );

 PROCEDURE main_s(
    errbuf               OUT NOCOPY		VARCHAR2,
    retcode              OUT NOCOPY		NUMBER,
    p_awd_yr             IN             VARCHAR2,
    p_org_id		 IN	   	NUMBER
  );

END igf_gr_ess_esd_data;

 

/
