--------------------------------------------------------
--  DDL for Package IGF_GR_YTD_LOAD_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_GR_YTD_LOAD_DATA" AUTHID CURRENT_USER AS
/* $Header: IGFGR04S.pls 115.6 2002/11/28 14:20:34 nsidana ship $ */

/***************************************************************
   Created By		:	avenkatr
   Date Created By	:	2000/12/26
   Purpose		:	To upload data into IGF_GR_MRR
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			When		What
 ***************************************************************/
 PROCEDURE ytd_load_file(
    errbuf               OUT NOCOPY		VARCHAR2,
    retcode              OUT NOCOPY		NUMBER,
    p_awd_yr             IN             VARCHAR2,
    p_org_id             IN             NUMBER
  );

END igf_gr_ytd_load_data;

 

/
