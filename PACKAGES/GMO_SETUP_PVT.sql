--------------------------------------------------------
--  DDL for Package GMO_SETUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMO_SETUP_PVT" 
/* $Header: GMOVSTPS.pls 120.0 2005/07/13 18:10 swasubra noship $ */

AUTHID CURRENT_USER AS

--This procedure enables GMO profile option that would enable process operation modules
--to start functioning in the environment.
--This procedure is called through a concurrent program request.
PROCEDURE ENABLE_GMO(ERRBUF    OUT NOCOPY VARCHAR2,
                     RETCODE   OUT NOCOPY VARCHAR2);

END;

 

/
