--------------------------------------------------------
--  DDL for Package JTF_RS_SRP_GROUPS_CONC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_SRP_GROUPS_CONC_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfrsbbs.pls 120.0 2005/05/11 08:19:14 appldev noship $ */

  /****************************************************************************
   This is a concurrent program to populate the data in JTF_RS_SRP_GROUPS_INT
   and JTF_RS_SRP_GROUPS. This program will create primary groups for salesreps
   for date date range from 01/01/1900 to 01/01/4713. For a specific date there
   will be only one primary group for a salesrep.

   CREATED BY    nsinghai      01/16/2003
   MODIFIED BY
   ***************************************************************************/

PROCEDURE  populate_default_groups
  (ERRBUF                    OUT NOCOPY VARCHAR2,
   RETCODE                   OUT NOCOPY VARCHAR2)
 ;

END jtf_rs_srp_groups_conc_pub;

 

/
