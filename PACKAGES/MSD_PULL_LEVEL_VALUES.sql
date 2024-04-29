--------------------------------------------------------
--  DDL for Package MSD_PULL_LEVEL_VALUES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_PULL_LEVEL_VALUES" AUTHID CURRENT_USER AS
/* $Header: msdplvls.pls 115.8 2002/10/28 18:54:06 dkang ship $ */


procedure pull_level_values_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_comp_refresh      IN  NUMBER) ;

END MSD_PULL_LEVEL_VALUES ;

 

/
