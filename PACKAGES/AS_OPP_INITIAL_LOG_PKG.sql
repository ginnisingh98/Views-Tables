--------------------------------------------------------
--  DDL for Package AS_OPP_INITIAL_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_OPP_INITIAL_LOG_PKG" AUTHID CURRENT_USER AS
/* $Header: asxoplgs.pls 115.4 2002/12/16 05:26:18 nkamble ship $ */


   -- The following two variables are used to indicate debug message is
   -- written to message stack(G_DEBUG_TRIGGER) or to log/output file
   -- (G_DEBUG_CONCURRENT).
   G_DEBUG_CONCURRENT       CONSTANT NUMBER := 1;
   G_DEBUG_TRIGGER          CONSTANT NUMBER := 2;
   G_Debug                  Boolean := True;

	PROCEDURE Initial_logs(   ERRBUF                OUT NOCOPY VARCHAR2,
    				  RETCODE               OUT NOCOPY VARCHAR2,
    				  p_debug_mode          IN  VARCHAR2,
				  p_trace_mode          IN  VARCHAR2);
END AS_OPP_INITIAL_LOG_PKG;

 

/
