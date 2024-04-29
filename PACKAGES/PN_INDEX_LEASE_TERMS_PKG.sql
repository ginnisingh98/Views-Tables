--------------------------------------------------------
--  DDL for Package PN_INDEX_LEASE_TERMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_INDEX_LEASE_TERMS_PKG" AUTHID CURRENT_USER AS
-- $Header: PNILTRHS.pls 115.4 2002/11/12 23:00:58 stripath noship $

-- +================================================================+
-- |                Copyright (c) 2001 Oracle Corporation
-- |                   Redwood Shores, California, USA
-- |                        All rights reserved.
-- +================================================================+
-- |  Name
-- |    PN_INDEX_LEASE_TERMS_PKG
-- |
-- |  Description
-- |    This package contains row handler procedures for populating PN_INDEX_LEASE_TERMS_ALL.
-- |
-- |
-- |  History
-- |    05-dec-2001 achauhan  Created
-- |    15-JAN-2002 Mrinal Misra   Added dbdrv command.
-- |    01-FEB-2002 Mrinal Misra   Added checkfile command.
-- +================================================================+

------------------------------------------------------------------------
-- PROCEDURE : INSERT_ROW
------------------------------------------------------------------------
procedure INSERT_ROW
(
	 X_INDEX_LEASE_TERM_ID         IN OUT NOCOPY    NUMBER
	,X_INDEX_LEASE_ID              IN        NUMBER
	,X_INDEX_PERIOD_ID             IN        NUMBER
	,X_LEASE_TERM_ID               IN        NUMBER
	,X_RENT_INCREASE_TERM_ID       IN        NUMBER
	,X_AMOUNT                      IN        NUMBER
	,X_APPROVED_FLAG	       IN        VARCHAR2
	,X_INDEX_TERM_INDICATOR	       IN        VARCHAR2
	,X_LAST_UPDATE_DATE            IN        DATE
	,X_LAST_UPDATED_BY             IN        NUMBER
	,X_CREATION_DATE               IN        DATE
	,X_CREATED_BY                  IN        NUMBER
	,X_LAST_UPDATE_LOGIN           IN        NUMBER
);


------------------------------------------------------------------------
-- PROCEDURE : UPDATE_ROW
------------------------------------------------------------------------
procedure UPDATE_ROW
(
	 X_INDEX_LEASE_TERM_ID         IN 	 NUMBER
	,X_INDEX_LEASE_ID              IN        NUMBER
	,X_INDEX_PERIOD_ID             IN        NUMBER
	,X_LEASE_TERM_ID               IN        NUMBER
	,X_RENT_INCREASE_TERM_ID       IN        NUMBER
	,X_AMOUNT                      IN        NUMBER
	,X_APPROVED_FLAG	       IN	 VARCHAR2
	,X_INDEX_TERM_INDICATOR	       IN	 VARCHAR2
	,X_LAST_UPDATE_DATE            IN        DATE
	,X_LAST_UPDATED_BY             IN        NUMBER
	,X_LAST_UPDATE_LOGIN           IN        NUMBER
);
------------------------------------------------------------------------
-- PROCEDURE : LOCK_ROW
------------------------------------------------------------------------
procedure LOCK_ROW
(
	 X_INDEX_LEASE_TERM_ID         IN 	 NUMBER
	,X_INDEX_LEASE_ID              IN        NUMBER
	,X_INDEX_PERIOD_ID             IN        NUMBER
	,X_LEASE_TERM_ID               IN        NUMBER
	,X_RENT_INCREASE_TERM_ID       IN        NUMBER
	,X_AMOUNT                      IN        NUMBER
	,X_APPROVED_FLAG	       IN	 VARCHAR2
	,X_INDEX_TERM_INDICATOR	       IN        VARCHAR2
);
------------------------------------------------------------------------
-- PROCEDURE : DELETE_ROW
------------------------------------------------------------------------
procedure delete_row
(
	 X_INDEX_LEASE_TERM_ID         IN 	 NUMBER
	,X_INDEX_LEASE_ID              IN        NUMBER
	,X_INDEX_PERIOD_ID             IN        NUMBER
	,X_LEASE_TERM_ID               IN        NUMBER
	,X_RENT_INCREASE_TERM_ID       IN        NUMBER
);



END PN_INDEX_LEASE_TERMS_PKG;

 

/
