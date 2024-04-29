--------------------------------------------------------
--  DDL for Package IGF_AW_EXT_FUND_LD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_EXT_FUND_LD" AUTHID CURRENT_USER AS
/* $Header: IGFAW05S.pls 115.7 2003/11/04 05:01:19 veramach ship $ */

/***************************************************************
   Created By   : mesriniv
   Date Created By  : 2000/15/06
   Purpose    : To Funds from Flat File and Create awards and
                Disbursements accordingly
   Bug No               :       2400442
   Bug Desc             :       Import External Awards
   Who                  When        What
   veramach             3-NOV-2003  FA 125 Multiple Distr Methods
                                    Obsoleted the process
   mesriniv            7-jun-2002   Added a new parameter p_award_year
   Bug No     :       1806850
   Bug Desc   :       Awards Build for Nov 2001 Rel

   To be Peer Reviewed and Tested.
   Known Limitations,Enhancements or Remarks
   Change History :
   Who      When    What
 ***************************************************************/
  PROCEDURE process_ack(
  ERRBUF      OUT NOCOPY    VARCHAR2,
  RETCODE     OUT NOCOPY    NUMBER,
  p_award_year      IN    VARCHAR2,
  p_org_id                      IN              NUMBER
  );
END igf_aw_ext_fund_ld;

 

/
