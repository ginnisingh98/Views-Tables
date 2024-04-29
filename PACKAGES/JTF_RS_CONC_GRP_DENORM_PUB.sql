--------------------------------------------------------
--  DDL for Package JTF_RS_CONC_GRP_DENORM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_CONC_GRP_DENORM_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfrsbds.pls 120.0 2005/05/11 08:19:17 appldev ship $ */

  /*****************************************************************************************
   This is a concurrent program to fetch all the records which are avaialble in
   in JTF_RS_CHGD_GRP_RELATIONS Table. This is the intermidiate table which will keep all
   the records which have to be  updated / deleted / inserted in JTF_RS_GROUP_RELATIONS.
   After successful processing the row will be deleted from JTF_RS_CHGD_GRP_RELATIONS.

   ******************************************************************************************/



  PROCEDURE  sync_grp_denorm
  (ERRBUF                    OUT NOCOPY VARCHAR2,
   RETCODE                   OUT NOCOPY VARCHAR2
   );


END jtf_rs_conc_grp_denorm_pub;

 

/
