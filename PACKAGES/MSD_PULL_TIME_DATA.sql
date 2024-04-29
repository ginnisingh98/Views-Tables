--------------------------------------------------------
--  DDL for Package MSD_PULL_TIME_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_PULL_TIME_DATA" AUTHID CURRENT_USER AS
/* $Header: msdptims.pls 115.2 2002/10/28 21:33:42 dkang ship $ */


procedure pull_time_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2) ;

END MSD_PULL_TIME_DATA ;

 

/
