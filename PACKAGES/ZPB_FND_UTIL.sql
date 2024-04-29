--------------------------------------------------------
--  DDL for Package ZPB_FND_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_FND_UTIL" AUTHID CURRENT_USER AS
/* $Header: ZPBFNDUS.pls 120.0.12010.2 2006/08/03 11:57:58 appldev noship $ */

  FUNCTION  get_request_status (request_id      IN OUT NOCOPY NUMBER,
		 	      appl_shortname  IN VARCHAR2 DEFAULT NULL,
			      program         IN VARCHAR2 DEFAULT NULL,
	    		      phase      OUT NOCOPY VARCHAR2,
			      status     OUT NOCOPY VARCHAR2,
			      dev_phase  OUT NOCOPY VARCHAR2,
			      dev_status OUT NOCOPY VARCHAR2,
			      message    OUT NOCOPY VARCHAR2

  ) RETURN NUMBER;


END ZPB_FND_UTIL;

 

/
