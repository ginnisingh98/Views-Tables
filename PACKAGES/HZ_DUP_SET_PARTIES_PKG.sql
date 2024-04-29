--------------------------------------------------------
--  DDL for Package HZ_DUP_SET_PARTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_DUP_SET_PARTIES_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHDQDPS.pls 120.1 2005/06/16 21:10:45 jhuang noship $*/

PROCEDURE Insert_Row(
                      p_DUP_PARTY_ID         IN OUT       NOCOPY NUMBER,
                      p_DUP_SET_ID           IN OUT       NOCOPY NUMBER,
                      p_merge_flag                        VARCHAR2,
                      p_not_dup                           VARCHAR2,
                      p_SCORE                             NUMBER,
                      p_MERGE_SEQ_ID                      NUMBER,
                      p_MERGE_BATCH_ID                    NUMBER,
                      p_MERGE_BATCH_NAME                  VARCHAR2,
                      p_CREATED_BY                        NUMBER,
                      p_CREATION_DATE                     DATE,
                      p_LAST_UPDATE_LOGIN                 NUMBER,
                      p_LAST_UPDATE_DATE                  DATE,
                      p_LAST_UPDATED_BY                   NUMBER);

PROCEDURE Lock_Row(
                      p_DUP_PARTY_ID         IN OUT       NOCOPY NUMBER,
                      p_DUP_SET_ID           IN OUT        NOCOPY NUMBER,
                      p_merge_flag                        VARCHAR2,
                      p_not_dup                           VARCHAR2,
                      p_SCORE                             NUMBER,
                      p_MERGE_SEQ_ID                      NUMBER,
                      p_MERGE_BATCH_ID                    NUMBER,
                      p_MERGE_BATCH_NAME                  VARCHAR2,
                      p_CREATED_BY                        NUMBER,
                      p_CREATION_DATE                     DATE,
                      p_LAST_UPDATE_LOGIN                 NUMBER,
                      p_LAST_UPDATE_DATE                  DATE,
                      p_LAST_UPDATED_BY                   NUMBER);

PROCEDURE Update_Row(
                      p_DUP_PARTY_ID                      NUMBER,
                      p_DUP_SET_ID                        NUMBER,
                      p_merge_flag                        VARCHAR2,
                      p_not_dup                           VARCHAR2,
                      p_SCORE                             NUMBER,
                      p_MERGE_SEQ_ID                      NUMBER,
                      p_MERGE_BATCH_ID                    NUMBER,
                      p_MERGE_BATCH_NAME                  VARCHAR2,
                      p_CREATED_BY                        NUMBER,
                      p_CREATION_DATE                     DATE,
                      p_LAST_UPDATE_LOGIN                 NUMBER,
                      p_LAST_UPDATE_DATE                  DATE,
                      p_LAST_UPDATED_BY                   NUMBER);

PROCEDURE Delete_Row( p_DUP_PARTY_ID     NUMBER,
                      p_DUP_SET_ID       NUMBER);

END HZ_DUP_SET_PARTIES_PKG;

 

/
