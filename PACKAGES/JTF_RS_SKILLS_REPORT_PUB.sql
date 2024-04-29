--------------------------------------------------------
--  DDL for Package JTF_RS_SKILLS_REPORT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_SKILLS_REPORT_PUB" AUTHID CURRENT_USER AS
  /* $Header: jtfrsbss.pls 120.0 2005/05/11 08:19:25 appldev ship $ */

  /*****************************************************************************************
   ******************************************************************************************/

  PROCEDURE show_res_skills (
      ERRBUF              OUT NOCOPY VARCHAR2,
      RETCODE             OUT NOCOPY VARCHAR2,
      X_REPORT_TYPE       IN  VARCHAR2,
      X_RESOURCE_ID       IN  NUMBER,
      X_GROUP_ID          IN  NUMBER
  ) ;

  PROCEDURE get_res_skills (
      P_RESOURCE_ID IN JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE
     ,P_LEVEL       IN NUMBER
  ) ;

END jtf_rs_skills_report_pub;

 

/
