--------------------------------------------------------
--  DDL for Package HZ_DUP_MERGE_PARTIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_DUP_MERGE_PARTIES_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHDQDMS.pls 120.1 2005/06/16 21:10:39 jhuang noship $*/

PROCEDURE Insert_Row(
                      p_DUP_BATCH_ID      IN OUT          NOCOPY NUMBER,
                      p_MERGE_FROM_ID     IN OUT          NOCOPY NUMBER,
                      p_MERGE_TO_ID       IN OUT          NOCOPY NUMBER,
                      p_CREATED_BY                        NUMBER,
                      p_CREATION_DATE                     DATE,
                      p_LAST_UPDATE_LOGIN                 NUMBER,
                      p_LAST_UPDATE_DATE                  DATE,
                      p_LAST_UPDATED_BY                   NUMBER);

PROCEDURE Lock_Row(
                      p_DUP_BATCH_ID      IN OUT          NOCOPY NUMBER,
                      p_MERGE_FROM_ID     IN OUT          NOCOPY NUMBER,
                      p_MERGE_TO_ID       IN OUT          NOCOPY NUMBER,
                      p_CREATED_BY                        NUMBER,
                      p_CREATION_DATE                     DATE,
                      p_LAST_UPDATE_LOGIN                 NUMBER,
                      p_LAST_UPDATE_DATE                  DATE,
                      p_LAST_UPDATED_BY                   NUMBER);

PROCEDURE Delete_Row(p_DUP_batch_id NUMBER,
                     p_MERGE_FROM_ID   NUMBER,
                     p_MERGE_TO_ID     NUMBER);


END HZ_DUP_MERGE_PARTIES_PKG;

 

/
