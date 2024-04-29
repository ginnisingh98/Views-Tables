--------------------------------------------------------
--  DDL for Package QP_RLTD_MODIFIER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_RLTD_MODIFIER_PVT" AUTHID CURRENT_USER as
/* $Header: QPXVRMDS.pls 120.1 2005/06/16 00:28:25 appldev  $ */

PROCEDURE Insert_Row(
  X_RLTD_MODIFIER_ID	IN OUT NOCOPY /* file.sql.39 change */	NUMBER
, X_CREATION_DATE                  DATE
, X_CREATED_BY                     NUMBER
, X_LAST_UPDATE_DATE               DATE
, X_LAST_UPDATED_BY                NUMBER
, X_LAST_UPDATE_LOGIN              NUMBER
, X_RLTD_MODIFIER_GRP_NO		NUMBER
, X_FROM_RLTD_MODIFIER_ID		NUMBER
, X_TO_RLTD_MODIFIER_ID		NUMBER
, X_RLTD_MODIFIER_GRP_TYPE         VARCHAR2
, X_CONTEXT                        VARCHAR2
, X_ATTRIBUTE1                     VARCHAR2
, X_ATTRIBUTE2                     VARCHAR2
, X_ATTRIBUTE3                     VARCHAR2
, X_ATTRIBUTE4                     VARCHAR2
, X_ATTRIBUTE5                     VARCHAR2
, X_ATTRIBUTE6                     VARCHAR2
, X_ATTRIBUTE7                     VARCHAR2
, X_ATTRIBUTE8                     VARCHAR2
, X_ATTRIBUTE9                     VARCHAR2
, X_ATTRIBUTE10                    VARCHAR2
, X_ATTRIBUTE11                    VARCHAR2
, X_ATTRIBUTE12                    VARCHAR2
, X_ATTRIBUTE13                    VARCHAR2
, X_ATTRIBUTE14                    VARCHAR2
, X_ATTRIBUTE15                    VARCHAR2
);


PROCEDURE Lock_Row(
 X_RLTD_MODIFIER_ID	IN OUT NOCOPY /* file.sql.39 change */	NUMBER
, X_CREATION_DATE                  DATE
, X_CREATED_BY                     NUMBER
, X_LAST_UPDATE_DATE               DATE
, X_LAST_UPDATED_BY                NUMBER
, X_LAST_UPDATE_LOGIN              NUMBER
, X_RLTD_MODIFIER_GRP_NO		NUMBER
, X_FROM_RLTD_MODIFIER_ID		NUMBER
, X_TO_RLTD_MODIFIER_ID		NUMBER
, X_RLTD_MODIFIER_GRP_TYPE         VARCHAR2
, X_CONTEXT                        VARCHAR2
, X_ATTRIBUTE1                     VARCHAR2
, X_ATTRIBUTE2                     VARCHAR2
, X_ATTRIBUTE3                     VARCHAR2
, X_ATTRIBUTE4                     VARCHAR2
, X_ATTRIBUTE5                     VARCHAR2
, X_ATTRIBUTE6                     VARCHAR2
, X_ATTRIBUTE7                     VARCHAR2
, X_ATTRIBUTE8                     VARCHAR2
, X_ATTRIBUTE9                     VARCHAR2
, X_ATTRIBUTE10                    VARCHAR2
, X_ATTRIBUTE11                    VARCHAR2
, X_ATTRIBUTE12                    VARCHAR2
, X_ATTRIBUTE13                    VARCHAR2
, X_ATTRIBUTE14                    VARCHAR2
, X_ATTRIBUTE15                    VARCHAR2
);


PROCEDURE Update_Row(
 X_RLTD_MODIFIER_ID	IN OUT NOCOPY /* file.sql.39 change */	NUMBER
, X_CREATION_DATE                  DATE
, X_CREATED_BY                     NUMBER
, X_LAST_UPDATE_DATE               DATE
, X_LAST_UPDATED_BY                NUMBER
, X_LAST_UPDATE_LOGIN              NUMBER
, X_RLTD_MODIFIER_GRP_NO		NUMBER
, X_FROM_RLTD_MODIFIER_ID		NUMBER
, X_TO_RLTD_MODIFIER_ID		NUMBER
, X_RLTD_MODIFIER_GRP_TYPE         VARCHAR2
, X_CONTEXT                        VARCHAR2
, X_ATTRIBUTE1                     VARCHAR2
, X_ATTRIBUTE2                     VARCHAR2
, X_ATTRIBUTE3                     VARCHAR2
, X_ATTRIBUTE4                     VARCHAR2
, X_ATTRIBUTE5                     VARCHAR2
, X_ATTRIBUTE6                     VARCHAR2
, X_ATTRIBUTE7                     VARCHAR2
, X_ATTRIBUTE8                     VARCHAR2
, X_ATTRIBUTE9                     VARCHAR2
, X_ATTRIBUTE10                    VARCHAR2
, X_ATTRIBUTE11                    VARCHAR2
, X_ATTRIBUTE12                    VARCHAR2
, X_ATTRIBUTE13                    VARCHAR2
, X_ATTRIBUTE14                    VARCHAR2
, X_ATTRIBUTE15                    VARCHAR2
);

PROCEDURE Delete_Row(
X_TO_RLTD_MODIFIER_ID	NUMBER
);


END QP_RLTD_MODIFIER_PVT;

 

/
