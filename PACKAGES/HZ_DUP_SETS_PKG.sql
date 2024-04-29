--------------------------------------------------------
--  DDL for Package HZ_DUP_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_DUP_SETS_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHDQDSS.pls 120.1 2005/06/16 21:10:51 jhuang ship $*/
PROCEDURE Insert_Row(
                      px_DUP_SET_ID              IN OUT   NOCOPY NUMBER,
                      p_DUP_BATCH_ID                      NUMBER,
                      p_WINNER_PARTY_ID                   NUMBER,
                      p_STATUS                            VARCHAR2,
                      p_ASSIGNED_TO_USER_ID               NUMBER,
                      p_MERGE_TYPE                        VARCHAR2,
                      p_OBJECT_VERSION_NUMBER             NUMBER,
                      p_CREATED_BY                        NUMBER,
                      p_CREATION_DATE                     DATE,
                      p_LAST_UPDATE_LOGIN                 NUMBER,
                      p_LAST_UPDATE_DATE                  DATE,
                      p_LAST_UPDATED_BY                   NUMBER);

PROCEDURE Lock_Row(
                      p_DUP_SET_ID              IN OUT   NOCOPY NUMBER,
                      p_DUP_BATCH_ID                     NUMBER,
                      p_WINNER_PARTY_ID                  NUMBER,
                      p_CREATED_BY                        NUMBER,
                      p_CREATION_DATE                     DATE,
                      p_LAST_UPDATE_LOGIN                 NUMBER,
                      p_LAST_UPDATE_DATE                  DATE,
                      p_LAST_UPDATED_BY                   NUMBER);

PROCEDURE Update_Row(
                      p_DUP_SET_ID                        NUMBER,
                      p_DUP_BATCH_ID                      NUMBER,
                      p_WINNER_PARTY_ID                   NUMBER,
                      p_CREATED_BY                        NUMBER,
                      p_CREATION_DATE                     DATE,
                      p_LAST_UPDATE_LOGIN                 NUMBER,
                      p_LAST_UPDATE_DATE                  DATE,
                      p_LAST_UPDATED_BY                   NUMBER);

PROCEDURE Delete_Row( p_DUP_SET_ID              NUMBER);

END HZ_DUP_SETS_PKG;

 

/
