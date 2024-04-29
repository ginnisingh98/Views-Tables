--------------------------------------------------------
--  DDL for Package HZ_WORD_LISTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_WORD_LISTS_PKG" AUTHID CURRENT_USER AS
/* $Header: ARHDQWLS.pls 120.3 2005/06/16 21:11:25 jhuang noship $ */

PROCEDURE Insert_Row(
                      X_WORD_LIST_ID           IN OUT   NOCOPY NUMBER,
	                  X_WORD_LIST_NAME                   VARCHAR2,
 		              X_LANGUAGE                         VARCHAR2,
                      X_SOURCE_NAME                      VARCHAR2,
                      X_CREATED_BY                        NUMBER,
                      X_CREATION_DATE                     DATE,
                      X_LAST_UPDATE_LOGIN                 NUMBER,
                      X_LAST_UPDATE_DATE                  DATE,
                      X_LAST_UPDATED_BY                   NUMBER,
                      X_OBJECT_VERSION_NUMBER             NUMBER,
		      X_NON_DELIMITED_FLAG                VARCHAR2 DEFAULT 'N');
PROCEDURE Insert_Row(
                      X_WORD_LIST_ID           IN OUT   NOCOPY NUMBER,
                          X_WORD_LIST_NAME                   VARCHAR2,
                              X_LANGUAGE                         VARCHAR2,
                      X_SOURCE_NAME                      VARCHAR2,
                      X_CREATED_BY                        NUMBER,
                      X_CREATION_DATE                     DATE,
                      X_LAST_UPDATE_LOGIN                 NUMBER,
                      X_LAST_UPDATE_DATE                  DATE,
                      X_LAST_UPDATED_BY                   NUMBER,
                      X_OBJECT_VERSION_NUMBER             NUMBER,
                      X_MSG_COUNT             IN OUT      NOCOPY NUMBER,
		      X_NON_DELIMITED_FLAG                VARCHAR2 DEFAULT 'N');

PROCEDURE Lock_Row(
                      X_WORD_LIST_ID           IN OUT   NOCOPY NUMBER,
	                  X_OBJECT_VERSION_NUMBER             NUMBER);

PROCEDURE Update_Row(
                      X_WORD_LIST_ID                     NUMBER,
	                  X_WORD_LIST_NAME                   VARCHAR2,
 		              X_LANGUAGE                         VARCHAR2,
                      X_SOURCE_NAME                      VARCHAR2,
                      X_CREATED_BY                        NUMBER,
                      X_CREATION_DATE                     DATE,
                      X_LAST_UPDATE_LOGIN                 NUMBER,
                      X_LAST_UPDATE_DATE                  DATE,
                      X_LAST_UPDATED_BY                   NUMBER,
                      X_OBJECT_VERSION_NUMBER  in out     NOCOPY NUMBER,
		      X_NON_DELIMITED_FLAG                VARCHAR2 DEFAULT 'N');
PROCEDURE Update_Row(
                      X_WORD_LIST_ID                     NUMBER,
                          X_WORD_LIST_NAME                   VARCHAR2,
                              X_LANGUAGE                         VARCHAR2,
                      X_SOURCE_NAME                      VARCHAR2,
                      X_CREATED_BY                        NUMBER,
                      X_CREATION_DATE                     DATE,
                      X_LAST_UPDATE_LOGIN                 NUMBER,
                      X_LAST_UPDATE_DATE                  DATE,
                      X_LAST_UPDATED_BY                   NUMBER,
                      X_OBJECT_VERSION_NUMBER  in out     NOCOPY NUMBER,
                      X_MSG_COUNT             IN OUT   NOCOPY NUMBER,
		      X_NON_DELIMITED_FLAG                VARCHAR2 DEFAULT 'N');

PROCEDURE Delete_Row(X_WORD_LIST_ID                       NUMBER);

END HZ_WORD_LISTS_PKG;

 

/
