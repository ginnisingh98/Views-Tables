--------------------------------------------------------
--  DDL for Package JTF_RS_CONC_WF_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_CONC_WF_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfrsbws.pls 120.0 2005/05/11 08:19:27 appldev noship $ */

  PROCEDURE  synchronize_wf_roles
  (ERRBUF                    OUT NOCOPY VARCHAR2,
   RETCODE                   OUT NOCOPY VARCHAR2,
   P_SYNC_COMP               IN  VARCHAR2
   );

END jtf_rs_conc_wf_pub;

 

/
