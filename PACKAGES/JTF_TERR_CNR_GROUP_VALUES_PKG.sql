--------------------------------------------------------
--  DDL for Package JTF_TERR_CNR_GROUP_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERR_CNR_GROUP_VALUES_PKG" AUTHID CURRENT_USER AS
/* $Header: jtfvtcvs.pls 120.0 2005/06/02 18:22:40 appldev ship $ */

-- 05/15/01  ARPATEL  Created table handlers
-- 05/16/01  ARPATEL  Added Start_Date_Active and End_Date_Active
-- 04/25/02  ARPATEL  Removed SECURITY_GROUP_ID references for bug#2269867

PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_CNR_GROUP_VALUE_ID             IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_CNR_GROUP_ID                   IN     NUMBER,
                  x_COMPARISON_OPERATOR            IN     VARCHAR2,
                  x_LOW_VALUE_CHAR                 IN     VARCHAR2,
                  x_HIGH_VALUE_CHAR                IN     VARCHAR2,
                  x_START_DATE_ACTIVE              IN     DATE,
                  x_END_DATE_ACTIVE                IN     DATE,
                  x_ORG_ID                         IN     NUMBER);



PROCEDURE Lock_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_CNR_GROUP_VALUE_ID             IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_CNR_GROUP_ID                   IN     NUMBER,
                  x_COMPARISON_OPERATOR            IN     VARCHAR2,
                  x_LOW_VALUE_CHAR                 IN     VARCHAR2,
                  x_HIGH_VALUE_CHAR                IN     VARCHAR2,
                  x_START_DATE_ACTIVE              IN     DATE,
                  x_END_DATE_ACTIVE                IN     DATE,
                  x_ORG_ID                         IN     NUMBER);



PROCEDURE Update_Row(
                  x_Rowid                          IN OUT NOCOPY VARCHAR2,
                  x_CNR_GROUP_VALUE_ID             IN OUT NOCOPY NUMBER,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_CNR_GROUP_ID                   IN     NUMBER,
                  x_COMPARISON_OPERATOR            IN     VARCHAR2,
                  x_LOW_VALUE_CHAR                 IN     VARCHAR2,
                  x_HIGH_VALUE_CHAR                IN     VARCHAR2,
                  x_START_DATE_ACTIVE              IN     DATE,
                  x_END_DATE_ACTIVE                IN     DATE,
                  x_ORG_ID                         IN     NUMBER);



PROCEDURE Delete_Row(                  x_CNR_GROUP_VALUE_ID                  IN     NUMBER);


END JTF_TERR_CNR_GROUP_VALUES_PKG;

 

/
