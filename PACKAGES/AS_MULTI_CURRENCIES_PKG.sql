--------------------------------------------------------
--  DDL for Package AS_MULTI_CURRENCIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_MULTI_CURRENCIES_PKG" AUTHID CURRENT_USER as
/* $Header: asxtmcps.pls 120.1 2005/06/05 22:53:15 appldev  $ */
-- Start of Comments
-- Package name     : AS_MULTI_CURRENCIES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

-- Default number of records fetch per call
G_DEFAULT_NUM_REC_FETCH  NUMBER := 30;
--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name: TYPE_MAPPINGS_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    PERIOD_SET_NAME
--    PERIOD_TYPE
--    CONVERSION_TYPE
--    DESCRIPTION
--    UPDATEABLE_FLAG
--    DELETEABLE_FLAG
--    LAST_UPDATE_DATE
--    LAST_UPDATED_BY
--    CREATION_DATE
--    CREATED_BY
--    LAST_UPDATE_LOGIN
--    SECURITY_GROUP_ID
--
--    Required:
--    Defaults:
--    Note: This record maps to AS_MC_TYPE_MAPPINGS table.
--
--   End of Comments

TYPE TYPE_MAPPINGS_Rec_Type IS RECORD
(
       PERIOD_SET_NAME                 VARCHAR2(15) := FND_API.G_MISS_CHAR,
       PERIOD_TYPE                     VARCHAR2(15) := FND_API.G_MISS_CHAR,
       CONVERSION_TYPE                 VARCHAR2(30) := FND_API.G_MISS_CHAR,
       DESCRIPTION                     VARCHAR2(80) := FND_API.G_MISS_CHAR,
       UPDATEABLE_FLAG                 VARCHAR2(1)  := FND_API.G_MISS_CHAR,
       DELETEABLE_FLAG                 VARCHAR2(1)  := FND_API.G_MISS_CHAR,
       LAST_UPDATE_DATE                DATE         := FND_API.G_MISS_DATE,
       LAST_UPDATED_BY                 NUMBER       := FND_API.G_MISS_NUM,
       CREATION_DATE                   DATE         := FND_API.G_MISS_DATE,
       CREATED_BY                      NUMBER       := FND_API.G_MISS_NUM,
       LAST_UPDATE_LOGIN               NUMBER       := FND_API.G_MISS_NUM,
       SECURITY_GROUP_ID               NUMBER       := FND_API.G_MISS_NUM
);

G_MISS_TYPE_MAPPINGS_REC          TYPE_MAPPINGS_Rec_Type;
TYPE  TYPE_MAPPINGS_Tbl_Type      IS TABLE OF TYPE_MAPPINGS_Rec_Type
                                  INDEX BY BINARY_INTEGER;
G_MISS_TYPE_MAPPINGS_TBL          TYPE_MAPPINGS_Tbl_Type;

--   *******************************************************
--    Start of Comments
--   -------------------------------------------------------
--    Record name: PERIOD_RATES_Rec_Type
--   -------------------------------------------------------
--   Parameters:
--    FROM_CURRENCY
--    TO_CURRENCY
--    CONVERSION_DATE
--    USER_CONVERSION_TYPE
--    CONVERSION_RATE
--    MODE_FLAG
--    INVERSE_CONVERSION_RATE
--
--    Required:
--    Defaults:
--    Note: This record is basically mapping to GL_DAILY_RATES_INTERFACE table.
--
--   End of Comments

TYPE PERIOD_RATES_Rec_Type IS RECORD
(
       FROM_CURRENCY                   VARCHAR2(15) := FND_API.G_MISS_CHAR,
       TO_CURRENCY                     VARCHAR2(15) := FND_API.G_MISS_CHAR,
       CONVERSION_DATE                 DATE         := FND_API.G_MISS_DATE,
       CONVERSION_TYPE                 VARCHAR2(30) := FND_API.G_MISS_CHAR,
       CONVERSION_RATE                 NUMBER       := FND_API.G_MISS_NUM
--       MODE_FLAG                       VARCHAR2(1)  := FND_API.G_MISS_CHAR,
--       INVERSE_CONVERSION_RATE         NUMBER       := FND_API.G_MISS_NUM
);

G_MISS_PERIOD_RATES_REC          PERIOD_RATES_Rec_Type;
TYPE  PERIOD_RATES_Tbl_Type      IS TABLE OF PERIOD_RATES_Rec_Type
                                 INDEX BY BINARY_INTEGER;
G_MISS_PERIOD_RATES_TBL          PERIOD_RATES_Tbl_Type;

PROCEDURE Insert_Type_Mappings(
          p_TYPE_MAPPINGS_TBL  IN   TYPE_MAPPINGS_Tbl_Type
                                    DEFAULT G_MISS_TYPE_MAPPINGS_TBL,
          X_Return_Status      OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
          X_Msg_Count          OUT NOCOPY /* file.sql.39 change */  NUMBER,
          X_Msg_Data           OUT NOCOPY /* file.sql.39 change */  VARCHAR2);

PROCEDURE Update_Type_Mappings(
          p_TYPE_MAPPINGS_TBL  IN   TYPE_MAPPINGS_Tbl_Type
                                    DEFAULT G_MISS_TYPE_MAPPINGS_TBL,
          X_Return_Status      OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
          X_Msg_Count          OUT NOCOPY /* file.sql.39 change */  NUMBER,
          X_Msg_Data           OUT NOCOPY /* file.sql.39 change */  VARCHAR2);

PROCEDURE Delete_Type_Mappings(
          p_TYPE_MAPPINGS_TBL  IN   TYPE_MAPPINGS_Tbl_Type
                                    DEFAULT G_MISS_TYPE_MAPPINGS_TBL,
          X_Return_Status      OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
          X_Msg_Count          OUT NOCOPY /* file.sql.39 change */  NUMBER,
          X_Msg_Data           OUT NOCOPY /* file.sql.39 change */  VARCHAR2);

PROCEDURE Insert_Period_Rates(
          p_PERIOD_RATES_TBL   IN   PERIOD_RATES_Tbl_Type
                                    DEFAULT G_MISS_PERIOD_RATES_TBL,
          X_Return_Status      OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
          X_Msg_Count          OUT NOCOPY /* file.sql.39 change */  NUMBER,
          X_Msg_Data           OUT NOCOPY /* file.sql.39 change */  VARCHAR2);

PROCEDURE Update_Period_Rates(
          p_PERIOD_RATES_TBL   IN   PERIOD_RATES_Tbl_Type
                                    DEFAULT G_MISS_PERIOD_RATES_TBL,
          X_Return_Status      OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
          X_Msg_Count          OUT NOCOPY /* file.sql.39 change */  NUMBER,
          X_Msg_Data           OUT NOCOPY /* file.sql.39 change */  VARCHAR2);

PROCEDURE Delete_Period_Rates(
          p_PERIOD_RATES_TBL   IN   PERIOD_RATES_Tbl_Type
                                    DEFAULT G_MISS_PERIOD_RATES_TBL,
          X_Return_Status      OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
          X_Msg_Count          OUT NOCOPY /* file.sql.39 change */  NUMBER,
          X_Msg_Data           OUT NOCOPY /* file.sql.39 change */  VARCHAR2);

End AS_MULTI_CURRENCIES_PKG;

 

/
