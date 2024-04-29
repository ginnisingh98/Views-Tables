--------------------------------------------------------
--  DDL for Package MSD_COLLECT_ORGANIZATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_COLLECT_ORGANIZATIONS" AUTHID CURRENT_USER AS
/* $Header: msdcorgs.pls 115.2 2002/11/06 23:01:09 pinamati ship $ */


/* Public Procedures */

procedure collect_organizations(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_instance_id       IN  NUMBER) ;

END MSD_COLLECT_ORGANIZATIONS;

 

/
