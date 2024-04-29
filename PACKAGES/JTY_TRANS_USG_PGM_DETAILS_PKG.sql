--------------------------------------------------------
--  DDL for Package JTY_TRANS_USG_PGM_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTY_TRANS_USG_PGM_DETAILS_PKG" AUTHID CURRENT_USER as
/* $Header: jtftupds.pls 120.1 2005/11/18 11:37:02 achanda noship $ */

PROCEDURE Insert_Row(
              X_ROW_ID                           IN OUT NOCOPY VARCHAR2,
              X_TRANS_USG_PGM_DETAILS_ID         IN OUT NOCOPY NUMBER,
              P_SOURCE_ID                        IN NUMBER,
              P_TRANS_TYPE_ID                    IN NUMBER,
              P_PROGRAM_NAME                     IN VARCHAR2,
              P_LAST_UPDATE_DATE                 IN DATE,
              P_LAST_UPDATED_BY                  IN NUMBER,
              P_CREATION_DATE                    IN DATE,
              P_CREATED_BY                       IN NUMBER,
              P_LAST_UPDATE_LOGIN                IN NUMBER,
              P_PARAM_PASSING_MECHANISM          IN VARCHAR2,
              P_REAL_TIME_ENABLE_FLAG            IN VARCHAR2,
              P_BATCH_ENABLE_FLAG                IN VARCHAR2,
              P_MULTI_LEVEL_WINNING_FLAG         IN VARCHAR2,
              P_REAL_TIME_TRANS_TABLE            IN VARCHAR2,
              P_BATCH_TRANS_TABLE                IN VARCHAR2,
              P_BATCH_NM_TRANS_TABLE             IN VARCHAR2,
              P_BATCH_DEA_TRANS_TABLE            IN VARCHAR2,
              P_BATCH_MATCH_TABLE                IN VARCHAR2,
              P_BATCH_UNIQUE_MATCH_TABLE         IN VARCHAR2,
              P_BATCH_WINNER_TABLE               IN VARCHAR2,
              P_BATCH_UNIQUE_WINNER_TABLE        IN VARCHAR2,
              P_BATCH_L1_WINNER_TABLE            IN VARCHAR2,
              P_BATCH_L2_WINNER_TABLE            IN VARCHAR2,
              P_BATCH_L3_WINNER_TABLE            IN VARCHAR2,
              P_BATCH_L4_WINNER_TABLE            IN VARCHAR2,
              P_BATCH_L5_WINNER_TABLE            IN VARCHAR2,
              P_BATCH_WT_WINNER_TABLE            IN VARCHAR2,
              P_BATCH_MP_WINNER_TABLE            IN VARCHAR2,
              P_BATCH_DMC_WINNER_TABLE           IN VARCHAR2,
              P_INDEX_EXTN                       IN VARCHAR2);

PROCEDURE Update_Row(
              P_ROW_ID                           IN VARCHAR2,
              P_TRANS_USG_PGM_DETAILS_ID         IN NUMBER,
              P_SOURCE_ID                        IN NUMBER,
              P_TRANS_TYPE_ID                    IN NUMBER,
              P_PROGRAM_NAME                     IN VARCHAR2,
              P_LAST_UPDATE_DATE                 IN DATE,
              P_LAST_UPDATED_BY                  IN NUMBER,
              P_CREATION_DATE                    IN DATE,
              P_CREATED_BY                       IN NUMBER,
              P_LAST_UPDATE_LOGIN                IN NUMBER,
              P_PARAM_PASSING_MECHANISM          IN VARCHAR2,
              P_REAL_TIME_ENABLE_FLAG            IN VARCHAR2,
              P_BATCH_ENABLE_FLAG                IN VARCHAR2,
              P_MULTI_LEVEL_WINNING_FLAG         IN VARCHAR2,
              P_REAL_TIME_TRANS_TABLE            IN VARCHAR2,
              P_BATCH_TRANS_TABLE                IN VARCHAR2,
              P_BATCH_NM_TRANS_TABLE             IN VARCHAR2,
              P_BATCH_DEA_TRANS_TABLE            IN VARCHAR2,
              P_BATCH_MATCH_TABLE                IN VARCHAR2,
              P_BATCH_UNIQUE_MATCH_TABLE         IN VARCHAR2,
              P_BATCH_WINNER_TABLE               IN VARCHAR2,
              P_BATCH_UNIQUE_WINNER_TABLE        IN VARCHAR2,
              P_BATCH_L1_WINNER_TABLE            IN VARCHAR2,
              P_BATCH_L2_WINNER_TABLE            IN VARCHAR2,
              P_BATCH_L3_WINNER_TABLE            IN VARCHAR2,
              P_BATCH_L4_WINNER_TABLE            IN VARCHAR2,
              P_BATCH_L5_WINNER_TABLE            IN VARCHAR2,
              P_BATCH_WT_WINNER_TABLE            IN VARCHAR2,
              P_BATCH_MP_WINNER_TABLE            IN VARCHAR2,
              P_BATCH_DMC_WINNER_TABLE           IN VARCHAR2,
              P_INDEX_EXTN                       IN VARCHAR2);

PROCEDURE Delete_Row(P_TRANS_USG_PGM_DETAILS_ID IN NUMBER);

END JTY_TRANS_USG_PGM_DETAILS_PKG;

 

/
