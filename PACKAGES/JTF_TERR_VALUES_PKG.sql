--------------------------------------------------------
--  DDL for Package JTF_TERR_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERR_VALUES_PKG" AUTHID CURRENT_USER AS
/* $Header: jtfvtvls.pls 120.0.12010000.2 2009/09/07 06:36:24 vpalle ship $ */
-- 02/22/00  JDOCHERT  Passing in ORG_ID to Insert/Update/Lock



PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_TERR_VALUE_ID                  IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_QUAL_ID                   IN     NUMBER,
                  x_INCLUDE_FLAG                   IN     VARCHAR2,
                  x_COMPARISON_OPERATOR            IN     VARCHAR2,
                  x_LOW_VALUE_CHAR                 IN     VARCHAR2,
                  x_HIGH_VALUE_CHAR                IN     VARCHAR2,
                  x_LOW_VALUE_NUMBER               IN     NUMBER,
                  x_HIGH_VALUE_NUMBER              IN     NUMBER,
                  x_VALUE_SET                      IN     NUMBER,
                  x_INTEREST_TYPE_ID               IN     NUMBER,
                  x_PRIMARY_INTEREST_CODE_ID       IN     NUMBER,
                  x_SECONDARY_INTEREST_CODE_ID     IN     NUMBER,
                  x_CURRENCY_CODE                  IN     VARCHAR2,
                  x_ID_USED_FLAG                   IN     VARCHAR2,
                  x_LOW_VALUE_CHAR_ID              IN     NUMBER,
                  x_ORG_ID                         IN     NUMBER,
                  x_CNR_GROUP_ID                   IN     NUMBER,
                  x_VALUE1_ID                      IN     NUMBER,
                  x_VALUE2_ID                      IN     NUMBER,
                  x_VALUE3_ID                      IN     NUMBER,
                  x_VALUE4_ID                      IN     NUMBER);



PROCEDURE Lock_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_TERR_VALUE_ID                  IN     NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_QUAL_ID                   IN     NUMBER,
                  x_INCLUDE_FLAG                   IN     VARCHAR2,
                  x_COMPARISON_OPERATOR            IN     VARCHAR2,
                  x_LOW_VALUE_CHAR                 IN     VARCHAR2,
                  x_HIGH_VALUE_CHAR                IN     VARCHAR2,
                  x_LOW_VALUE_NUMBER               IN     NUMBER,
                  x_HIGH_VALUE_NUMBER              IN     NUMBER,
                  x_VALUE_SET                      IN     NUMBER,
                  x_INTEREST_TYPE_ID               IN     NUMBER,
                  x_PRIMARY_INTEREST_CODE_ID       IN     NUMBER,
                  x_SECONDARY_INTEREST_CODE_ID     IN     NUMBER,
                  x_CURRENCY_CODE                  IN     VARCHAR2,
                  x_ID_USED_FLAG                   IN     VARCHAR2,
                  x_LOW_VALUE_CHAR_ID              IN     NUMBER,
                  x_ORG_ID                         IN     NUMBER,
                  x_CNR_GROUP_ID                   IN     NUMBER,
                  x_VALUE1_ID                      IN     NUMBER,
                  x_VALUE2_ID                      IN     NUMBER,
                  x_VALUE3_ID                      IN     NUMBER,
                  x_VALUE4_ID                      IN     NUMBER);



PROCEDURE Update_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_TERR_VALUE_ID                  IN     NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_QUAL_ID                   IN     NUMBER,
                  x_INCLUDE_FLAG                   IN     VARCHAR2,
                  x_COMPARISON_OPERATOR            IN     VARCHAR2,
                  x_LOW_VALUE_CHAR                 IN     VARCHAR2,
                  x_HIGH_VALUE_CHAR                IN     VARCHAR2,
                  x_LOW_VALUE_NUMBER               IN     NUMBER,
                  x_HIGH_VALUE_NUMBER              IN     NUMBER,
                  x_VALUE_SET                      IN     NUMBER,
                  x_INTEREST_TYPE_ID               IN     NUMBER,
                  x_PRIMARY_INTEREST_CODE_ID       IN     NUMBER,
                  x_SECONDARY_INTEREST_CODE_ID     IN     NUMBER,
                  x_CURRENCY_CODE                  IN     VARCHAR2,
                  x_ID_USED_FLAG                   IN     VARCHAR2,
                  x_LOW_VALUE_CHAR_ID              IN     NUMBER,
                  x_ORG_ID                         IN     NUMBER,
                  x_CNR_GROUP_ID                   IN     NUMBER,
                  x_VALUE1_ID                      IN     NUMBER,
                  x_VALUE2_ID                      IN     NUMBER,
                  x_VALUE3_ID                      IN     NUMBER,
                  x_VALUE4_ID                      IN     NUMBER);



PROCEDURE Delete_Row(                  x_TERR_VALUE_ID                  IN     NUMBER);


END JTF_TERR_VALUES_PKG;

/
