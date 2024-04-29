--------------------------------------------------------
--  DDL for Package AR_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_SETUP" AUTHID CURRENT_USER AS
/* $Header: ARXPROFS.pls 115.3 2002/11/15 04:22:10 anukumar noship $ */


-----------------------------------------------------------------
-- PROCEDURE GET
-- Use this instead of FND_PROFILE.GET to retrieve the value of
-- a profile option
-----------------------------------------------------------------
PROCEDURE GET
	(NAME		IN VARCHAR2,
         ORG_ID         IN NUMBER default null,
	 VAL		OUT NOCOPY VARCHAR2
	);


-----------------------------------------------------------------
-- FUNCTION VALUE
-- Use this function instead of FND_PROFILE.VALUE to retrieve the value of
-- a profile option
-----------------------------------------------------------------
FUNCTION VALUE
	(NAME 		IN VARCHAR2,
         ORG_ID         IN NUMBER default null
	)
RETURN VARCHAR2;


END AR_SETUP;

 

/
