--------------------------------------------------------
--  DDL for Package IGS_AD_WF_P2A
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_WF_P2A" AUTHID CURRENT_USER AS
/* $Header: IGSADD4S.pls 120.0 2005/09/09 20:18:09 appldev noship $ */

---------------------------------------------------------------------------------------------------
--  Created By : akadam
--  Date Created On : 06-JUL-2005
--  Purpose : Prospect to Applicant Management Build
--  Know limitations, enhancements or remarks
--  Change History
--  Who             When            What
---------------------------------------------------------------------------------------------------

   PROCEDURE call_apl_pre_crt_apis(
            itemtype  in  VARCHAR2  ,
	    itemkey   in  VARCHAR2  ,
	    actid     in  NUMBER   ,
            funcmode  in  VARCHAR2  ,
	    resultout   OUT NOCOPY VARCHAR2 ) ;

   PROCEDURE call_drv_usr_hks(
            itemtype  in  VARCHAR2  ,
	    itemkey   in  VARCHAR2  ,
	    actid     in  NUMBER   ,
            funcmode  in  VARCHAR2  ,
	    resultout   OUT NOCOPY VARCHAR2 ) ;


   PROCEDURE drv_par_bef_api_cal(
            itemtype  in  VARCHAR2  ,
	    itemkey   in  VARCHAR2  ,
	    actid     in  NUMBER   ,
            funcmode  in  VARCHAR2  ,
	    resultout   OUT NOCOPY VARCHAR2 ) ;

   PROCEDURE val_application_type(
            itemtype  in  VARCHAR2  ,
	    itemkey   in  VARCHAR2  ,
	    actid     in  NUMBER   ,
            funcmode  in  VARCHAR2  ,
	    resultout   OUT NOCOPY VARCHAR2 ) ;

END igs_ad_wf_p2a;

 

/
