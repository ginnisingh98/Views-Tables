--------------------------------------------------------
--  DDL for Package FV_BUDGET_DISTRIBUTION_HDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_BUDGET_DISTRIBUTION_HDR_PKG" AUTHID CURRENT_USER as
/* $Header: FVBEHDRS.pls 120.2.12010000.2 2009/05/07 05:39:01 bnarang ship $ */

PROCEDURE Insert_Row(X_ROWID 	              IN OUT NOCOPY VARCHAR2,
		     X_DISTRIBUTION_ID        NUMBER,
                     X_FUND_VALUE             VARCHAR2,
		     X_SET_OF_BOOKS_ID        NUMBER,
		     X_LAST_UPDATE_DATE       DATE,
		     X_LAST_UPDATED_BY        NUMBER,
		     X_CREATION_DATE          DATE,
		     X_CREATED_BY             NUMBER,
		     X_LAST_UPDATE_LOGIN      NUMBER,
		     X_ATTRIBUTE1             VARCHAR2,
		     X_ATTRIBUTE2             VARCHAR2,
		     X_ATTRIBUTE3             VARCHAR2,
		     X_ATTRIBUTE4             VARCHAR2,
		     X_ATTRIBUTE5             VARCHAR2,
		     X_ATTRIBUTE6             VARCHAR2,
		     X_ATTRIBUTE7             VARCHAR2,
		     X_ATTRIBUTE8             VARCHAR2,
		     X_ATTRIBUTE9             VARCHAR2,
		     X_ATTRIBUTE10            VARCHAR2,
		     X_ATTRIBUTE11            VARCHAR2,
		     X_ATTRIBUTE12            VARCHAR2,
		     X_ATTRIBUTE13            VARCHAR2,
		     X_ATTRIBUTE14            VARCHAR2,
		     X_ATTRIBUTE15            VARCHAR2,
		     X_ATTRIBUTE_CATEGORY     VARCHAR2,
		     X_ORG_ID                 NUMBER,
		     X_FACTS_PRGM_SEGMENT     VARCHAR2,
		     X_TREASURY_SYMBOL_ID     NUMBER,
                     X_FREEZE_DEFINITION_FLAG VARCHAR2
		    );

PROCEDURE Update_Row(X_ROWID 	              VARCHAR2,
		     X_DISTRIBUTION_ID        NUMBER,
                     X_FUND_VALUE             VARCHAR2,
		     X_SET_OF_BOOKS_ID        NUMBER,
		     X_LAST_UPDATE_DATE       DATE,
		     X_LAST_UPDATED_BY        NUMBER,
		     X_CREATION_DATE          DATE,
		     X_CREATED_BY             NUMBER,
		     X_LAST_UPDATE_LOGIN      NUMBER,
		     X_ATTRIBUTE1             VARCHAR2,
		     X_ATTRIBUTE2             VARCHAR2,
		     X_ATTRIBUTE3             VARCHAR2,
		     X_ATTRIBUTE4             VARCHAR2,
		     X_ATTRIBUTE5             VARCHAR2,
		     X_ATTRIBUTE6             VARCHAR2,
		     X_ATTRIBUTE7             VARCHAR2,
		     X_ATTRIBUTE8             VARCHAR2,
		     X_ATTRIBUTE9             VARCHAR2,
		     X_ATTRIBUTE10            VARCHAR2,
		     X_ATTRIBUTE11            VARCHAR2,
		     X_ATTRIBUTE12            VARCHAR2,
		     X_ATTRIBUTE13            VARCHAR2,
		     X_ATTRIBUTE14            VARCHAR2,
		     X_ATTRIBUTE15            VARCHAR2,
		     X_ATTRIBUTE_CATEGORY     VARCHAR2,
		     X_ORG_ID                 NUMBER,
		     X_FACTS_PRGM_SEGMENT     VARCHAR2,
		     X_TREASURY_SYMBOL_ID     NUMBER,
                     X_FREEZE_DEFINITION_FLAG VARCHAR2
		    );

PROCEDURE Lock_Row(  X_ROWID 	              VARCHAR2,
		     X_DISTRIBUTION_ID        NUMBER,
                     X_FUND_VALUE             VARCHAR2,
		     X_SET_OF_BOOKS_ID        NUMBER,
		     X_ATTRIBUTE_CATEGORY     VARCHAR2,
		     X_ORG_ID                 NUMBER,
		     X_FACTS_PRGM_SEGMENT     VARCHAR2,
		     X_TREASURY_SYMBOL_ID     NUMBER
		  );

PROCEDURE Delete_Row(X_ROWID VARCHAR2);

END FV_BUDGET_DISTRIBUTION_HDR_PKG;

/
