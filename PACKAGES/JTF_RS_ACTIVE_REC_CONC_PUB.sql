--------------------------------------------------------
--  DDL for Package JTF_RS_ACTIVE_REC_CONC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_ACTIVE_REC_CONC_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfrsbas.pls 120.0 2005/05/11 08:19:13 appldev noship $ */

  /****************************************************************************
   This is a concurrent program to populate ACTIVE_FLAG column in JTF_RS_GROUPS_DENORM
   and  JTF_RS_ROLE_RELATIONS table. This program will be used from concurrrent program
   "Maintain Current Groups and Roles".

   Create By       NSINGHAI      06-MAY-2003
   ***************************************************************************/

-- stubbed out procedure because of Bug # 3074562
-- new procedure populate_active_flags will do exactly what this was doing
PROCEDURE  populate_active_flag
  (ERRBUF                    OUT NOCOPY VARCHAR2,
   RETCODE                   OUT NOCOPY VARCHAR2)
;

-- created on 29-July-2003
-- new procedure to do exactly what populate_active_flag was doing
-- the concurrant program is JTFRSBAF and the executable is JTFRSBAF

  PROCEDURE  populate_active_flags
  (ERRBUF                    OUT NOCOPY VARCHAR2,
   RETCODE                   OUT NOCOPY VARCHAR2)
   ;

END jtf_rs_active_rec_conc_pub;

 

/
