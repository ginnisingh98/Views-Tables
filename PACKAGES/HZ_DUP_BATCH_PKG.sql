--------------------------------------------------------
--  DDL for Package HZ_DUP_BATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_DUP_BATCH_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHDQDBS.pls 115.4 2003/04/15 18:03:33 acng ship $*/
PROCEDURE Insert_Row(
                      px_DUP_BATCH_ID              IN OUT NOCOPY  NUMBER,
	                  p_DUP_BATCH_NAME               VARCHAR2,
                      p_MATCH_RULE_ID                     NUMBER,
                      p_APPLICATION_ID               NUMBER,
                      p_REQUEST_TYPE                 VARCHAR2,
 		              p_CREATED_BY                        NUMBER,
                      p_CREATION_DATE                     DATE,
                      p_LAST_UPDATE_LOGIN                 NUMBER,
                      p_LAST_UPDATE_DATE                  DATE,
                      p_LAST_UPDATED_BY                   NUMBER);

PROCEDURE Lock_Row(
                      p_DUP_BATCH_ID       IN OUT NOCOPY  NUMBER,
	                  p_DUP_BATCH_NAME              VARCHAR2,
                      p_CREATED_BY                        NUMBER,
                      p_CREATION_DATE                     DATE,
                      p_LAST_UPDATE_LOGIN                 NUMBER,
                      p_LAST_UPDATE_DATE                  DATE,
                      p_LAST_UPDATED_BY                   NUMBER);

PROCEDURE Update_Row(
                      p_DUP_BATCH_ID                NUMBER,
	                  p_DUP_BATCH_NAME              VARCHAR2,
                      p_CREATED_BY                        NUMBER,
                      p_CREATION_DATE                     DATE,
                      p_LAST_UPDATE_LOGIN                 NUMBER,
                      p_LAST_UPDATE_DATE                  DATE,
                      p_LAST_UPDATED_BY                   NUMBER);

PROCEDURE Delete_Row( p_DUP_BATCH_ID              NUMBER);

END HZ_DUP_BATCH_PKG;

 

/
