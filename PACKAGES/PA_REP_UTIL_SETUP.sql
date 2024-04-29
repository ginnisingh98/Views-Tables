--------------------------------------------------------
--  DDL for Package PA_REP_UTIL_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_REP_UTIL_SETUP" AUTHID CURRENT_USER AS
/* $Header: PARRSETS.pls 120.1 2005/08/19 17:00:32 mwasowic noship $ */

 /*
  * Procedure.
  */

  PROCEDURE set_flag_cut_off_records(
                                     errbuf                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                    ,retcode               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                    ,p_debug_mode          IN  VARCHAR2
                                    );
END PA_REP_UTIL_SETUP;
 

/
