--------------------------------------------------------
--  DDL for Package PA_TRANSACTION_SOURCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TRANSACTION_SOURCES_PKG" AUTHID CURRENT_USER AS
/* $Header: PAXTIXSS.pls 120.1 2005/08/03 12:40:43 aaggarwa noship $ */

--  =====================================================================
--  This procedure performs a referential integrity check for

  PROCEDURE check_references(  X_trx_source  IN      VARCHAR2
                             , status        IN OUT NOCOPY  NUMBER
			     , outcome	     IN OUT NOCOPY  VARCHAR2 );

--  =====================================================================
--  This procedure checks if the transaction source already exists, and
--  if so, returns an error message.

  PROCEDURE check_unique(  X_trx_source        IN      VARCHAR2
                         , X_user_trx_source   IN      VARCHAR2
                         , X_rowid             IN      VARCHAR2
                         , status              IN OUT NOCOPY  NUMBER
                         , outcome             IN OUT NOCOPY  VARCHAR2 );

END PA_TRANSACTION_SOURCES_PKG;

 

/
