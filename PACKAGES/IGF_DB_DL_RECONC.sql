--------------------------------------------------------
--  DDL for Package IGF_DB_DL_RECONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_DB_DL_RECONC" AUTHID CURRENT_USER AS
/* $Header: IGFDB07S.pls 115.3 2003/10/16 15:21:37 ugummall noship $ */
/***************************************************************
   Created By		:	adhawan
   Date Created By	:	22-jan-2002
   Purpose		    :	To load the
   Known Limitations,Enhancements or Remarks:
   Change History	:2154941
   Who			When		What
   ugummall     15-OCT-2003    Bug # 3102439. FA 126 Multiple FA Offices.
                               added two new parameters school_type and p_school_code to
                               main_smr and main_dtl procedures.
   adhawan      22-jan-2002 Disbursements build
 ***************************************************************/
PROCEDURE main_smr      (errbuf			OUT NOCOPY 	    VARCHAR2,
                         retcode	        OUT NOCOPY         NUMBER,
                         p_award_year           IN         VARCHAR2,
                         SCHOOL_TYPE    IN      VARCHAR2,
                         P_SCHOOL_CODE  IN      VARCHAR2
                         ) ;

PROCEDURE main_dtl       (errbuf		OUT NOCOPY          VARCHAR2,
                          retcode	        OUT NOCOPY          NUMBER,
                          p_award_year          IN         VARCHAR2,
                          SCHOOL_TYPE    IN      VARCHAR2,
                          P_SCHOOL_CODE  IN      VARCHAR2
                         );

END igf_db_dl_reconc;

 

/
