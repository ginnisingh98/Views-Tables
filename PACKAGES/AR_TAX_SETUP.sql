--------------------------------------------------------
--  DDL for Package AR_TAX_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_TAX_SETUP" AUTHID CURRENT_USER AS
/* $Header: ARTXPROS.pls 115.1 2002/11/15 23:33:29 thwon ship $ */


-----------------------------------------------------------------
-- PROCEDURE GET
-- Use this instead of FND_PROFILE.GET to retrieve the value of
-- a profile option
-----------------------------------------------------------------
PROCEDURE GET
        (NAME           IN VARCHAR2,
         ORG_ID         IN NUMBER default null,
         VAL            OUT NOCOPY VARCHAR2
        );


-----------------------------------------------------------------
-- FUNCTION VALUE
-- Use this function instead of FND_PROFILE.VALUE to retrieve the value of
-- a profile option
-----------------------------------------------------------------
FUNCTION VALUE
        (NAME           IN VARCHAR2,
         ORG_ID         IN NUMBER default null
        )
RETURN VARCHAR2;


END AR_TAX_SETUP;

 

/
