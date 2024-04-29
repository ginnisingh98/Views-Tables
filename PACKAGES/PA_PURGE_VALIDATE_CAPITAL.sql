--------------------------------------------------------
--  DDL for Package PA_PURGE_VALIDATE_CAPITAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PURGE_VALIDATE_CAPITAL" AUTHID CURRENT_USER AS
/* $Header: PAXGCPVS.pls 120.1 2005/08/09 04:17:00 avajain noship $ */

g_purge_capital_flag   	VARCHAR2(1);

/* The following Procedure will be called as part of the validations done before Archiving/
   Purging a project                                                                        */

  PROCEDURE validate_capital(p_project_id 	IN NUMBER,
                             p_purge_to_date    IN DATE,
                             p_active_flag      IN VARCHAR2,
                             p_err_code         IN OUT NOCOPY NUMBER,
                             p_err_stack        IN OUT NOCOPY VARCHAR2,
                             p_err_stage        IN OUT NOCOPY VARCHAR2) ;

END PA_PURGE_VALIDATE_CAPITAL;
 

/
