--------------------------------------------------------
--  DDL for Package PN_INDEX_EXCLUDE_TERM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_INDEX_EXCLUDE_TERM_PKG" AUTHID CURRENT_USER AS
-- $Header: PNINXTRS.pls 120.1 2006/12/20 07:41:51 rdonthul noship $

------------------------------------------------------------------------
-- PROCEDURE : INSERT_ROW
------------------------------------------------------------------------
procedure INSERT_ROW
(
    X_INDEX_EXCLUDE_TERM_ID         IN OUT NOCOPY    NUMBER
   ,X_ORG_ID                        IN        NUMBER
   ,X_INDEX_LEASE_ID                IN        NUMBER
   ,X_PAYMENT_TERM_ID               IN        NUMBER
   ,X_LAST_UPDATE_DATE              IN        DATE
   ,X_LAST_UPDATED_BY               IN        NUMBER
   ,X_CREATION_DATE                 IN        DATE
   ,X_CREATED_BY                    IN        NUMBER
   ,X_LAST_UPDATE_LOGIN             IN        NUMBER
   ,X_INCLUDE_EXCLUDE_FLAG          IN        VARCHAR2
);
------------------------------------------------------------------------
-- PROCEDURE : UPDATE_ROW
------------------------------------------------------------------------
procedure UPDATE_ROW
(
--x_rowid in varchar2,
    X_INDEX_EXCLUDE_TERM_ID         IN        NUMBER
   ,X_INDEX_LEASE_ID                IN        NUMBER
   ,X_PAYMENT_TERM_ID               IN        NUMBER
   ,X_LAST_UPDATE_DATE              IN        DATE
   ,X_LAST_UPDATED_BY               IN        NUMBER
   ,X_LAST_UPDATE_LOGIN             IN        NUMBER
   ,X_INCLUDE_EXCLUDE_FLAG          IN        VARCHAR2
);
------------------------------------------------------------------------
-- PROCEDURE : LOCK_ROW
------------------------------------------------------------------------
procedure LOCK_ROW
(
--X_ROWID in VARCHAR2,
    X_INDEX_EXCLUDE_TERM_ID         IN        NUMBER
   ,X_INDEX_LEASE_ID                IN        NUMBER
   ,X_PAYMENT_TERM_ID               IN        NUMBER
   ,X_INCLUDE_EXCLUDE_FLAG          IN        VARCHAR2
);
------------------------------------------------------------------------
-- PROCEDURE : DELETE_ROW
------------------------------------------------------------------------
procedure delete_row
(
    X_INDEX_LEASE_ID                IN        NUMBER
   ,X_PAYMENT_TERM_ID               IN        NUMBER
);

------------------------------------------------------------------------
-- PROCEDURE : DELETE_ALL_EXCLUDE_TERMS
------------------------------------------------------------------------
procedure DELETE_ALL_EXCLUDE_TERMS
(
    X_INDEX_LEASE_ID                IN        NUMBER
);
END PN_INDEX_EXCLUDE_TERM_PKG;

/
