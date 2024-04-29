--------------------------------------------------------
--  DDL for Package MSD_COLLECT_TIME_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_COLLECT_TIME_DATA" AUTHID CURRENT_USER AS
/* $Header: msdctims.pls 115.4 2002/10/28 21:31:00 dkang ship $ */

/** The Level Id definitions as well as the View Name defintions  **/


/* Public Procedures */

procedure collect_time_data(
                     errbuf              OUT NOCOPY VARCHAR2,
                     retcode             OUT NOCOPY VARCHAR2,
                     p_instance_id       IN  NUMBER,
                     p_calendar_type_id      IN  VARCHAR2,
                     p_calendar_code         IN  VARCHAR2,
                     p_from_date             IN  VARCHAR2,
                     p_to_date               IN  VARCHAR2) ;

END MSD_COLLECT_TIME_DATA ;

 

/
