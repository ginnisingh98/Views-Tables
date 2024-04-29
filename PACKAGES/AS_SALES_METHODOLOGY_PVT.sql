--------------------------------------------------------
--  DDL for Package AS_SALES_METHODOLOGY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SALES_METHODOLOGY_PVT" AUTHID CURRENT_USER AS
/* $Header: asxvsmos.pls 120.0 2005/06/02 17:15:34 appldev noship $ */
---------------------------------------------------------------------------
--Define Global Variables--
---------------------------------------------------------------------------

G_PKG_NAME      CONSTANT        VARCHAR2(30):='AS_SALES_METH_PVT';

---------------------------------------------------------------------------


--Procedure to Create a Sales Methodology

Procedure  CREATE_SALES_METHODOLOGY
  (
  P_API_VERSION             IN  NUMBER,
  P_INIT_MSG_LIST           IN  VARCHAR2    default fnd_api.g_false,
  P_COMMIT                  IN  VARCHAR2    default fnd_api.g_false,
  P_VALIDATE_LEVEL          IN  VARCHAR2    default fnd_api.g_valid_level_full,
  P_SALES_METHODOLOGY_NAME  IN  VARCHAR2,
  P_START_DATE_ACTIVE       IN  DATE,
  P_END_DATE_ACTIVE         IN  DATE DEFAULT NULL,
  P_AUTOCREATETASK_FLAG     IN  VARCHAR2 DEFAULT NULL,
  P_DESCRIPTION             IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE1              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE2              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE3              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE4              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE5              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE6              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE7              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE8              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE9              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE10             IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE11             IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE12             IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE13             IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE14             IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE15             IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE_CATEGORY      IN  VARCHAR2 DEFAULT NULL,
  X_RETURN_STATUS           OUT NOCOPY VARCHAR2,
  X_MSG_COUNT               OUT NOCOPY NUMBER,
  X_MSG_DATA                OUT NOCOPY VARCHAR2,
  X_SALES_METHODOLOGY_ID    OUT NOCOPY NUMBER);

--Procedure to Upate Sales Methodology

Procedure  UPDATE_SALES_METHODOLOGY
  (
  P_API_VERSION             IN  NUMBER,
  P_INIT_MSG_LIST           IN  VARCHAR2    default fnd_api.g_false,
  P_COMMIT                  IN  VARCHAR2    default fnd_api.g_false,
  P_VALIDATE_LEVEL          IN  VARCHAR2    default fnd_api.g_valid_level_full,
  P_SALES_METHODOLOGY_ID    IN  NUMBER,
  P_SALES_METHODOLOGY_NAME  IN  VARCHAR2,
  P_START_DATE_ACTIVE       IN  DATE,
  P_END_DATE_ACTIVE         IN  DATE DEFAULT NULL,
  P_AUTOCREATETASK_FLAG     IN  VARCHAR2 DEFAULT NULL,
  P_DESCRIPTION             IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE1              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE2              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE3              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE4              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE5              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE6              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE7              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE8              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE9              IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE10             IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE11             IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE12             IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE13             IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE14             IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE15             IN  VARCHAR2 DEFAULT NULL,
  P_ATTRIBUTE_CATEGORY      IN  VARCHAR2 DEFAULT NULL,
  X_RETURN_STATUS           OUT NOCOPY VARCHAR2,
  X_MSG_COUNT               OUT NOCOPY NUMBER,
  X_MSG_DATA                OUT NOCOPY VARCHAR2,
  X_OBJECT_VERSION_NUMBER   IN OUT NOCOPY NUMBER
  );


--Procedure to Delete Sales Methodology
Procedure  DELETE_SALES_METHODOLOGY
 (
 P_API_VERSION             IN  NUMBER,
 P_INIT_MSG_LIST           IN  VARCHAR2    default fnd_api.g_false,
 P_COMMIT                  IN  VARCHAR2    default fnd_api.g_false,
 P_VALIDATE_LEVEL          IN  VARCHAR2    default fnd_api.g_valid_level_full,
 P_SALES_METHODOLOGY_ID    IN  NUMBER,
 X_RETURN_STATUS           OUT NOCOPY VARCHAR2,
 X_MSG_COUNT               OUT NOCOPY NUMBER,
 X_MSG_DATA                OUT NOCOPY VARCHAR2,
 X_OBJECT_VERSION_NUMBER   IN  NUMBER
 );


--Procedure to Add a Sales Stage - Template Group Map
Procedure ADD_SALES_METH_STAGE_MAP
 (
 P_API_VERSION             IN  NUMBER,
 P_INIT_MSG_LIST           IN  VARCHAR2    default fnd_api.g_false,
 P_COMMIT                  IN  VARCHAR2    default fnd_api.g_false,
 P_VALIDATE_LEVEL          IN  VARCHAR2    default fnd_api.g_valid_level_full,
 P_SALES_METHODOLOGY_ID    IN  NUMBER,
 P_SALES_STAGE_ID		   IN  NUMBER,
 P_TASK_TEMPLATE_GROUP_ID  IN  NUMBER default fnd_api.g_miss_num,
 P_MAX_WIN_PROBABILITY     IN  NUMBER,
 P_MIN_WIN_PROBABILITY     IN  NUMBER,
 P_SALES_SUPPLEMENT_TEMPLATE IN NUMBER,
 P_STAGE_SEQUENCE          IN  NUMBER,
 X_RETURN_STATUS           OUT NOCOPY VARCHAR2,
 X_MSG_COUNT               OUT NOCOPY NUMBER,
 X_MSG_DATA                OUT NOCOPY VARCHAR2
 );

--Procedure to Delete a Sales Stage - Template Group Map
Procedure DELETE_SALES_METH_STAGE_MAP
 (
 P_API_VERSION             IN  NUMBER,
 P_INIT_MSG_LIST           IN  VARCHAR2    default fnd_api.g_false,
 P_COMMIT                  IN  VARCHAR2    default fnd_api.g_false,
 P_VALIDATE_LEVEL          IN  VARCHAR2    default fnd_api.g_valid_level_full,
 P_SALES_METHODOLOGY_ID    IN  NUMBER,
 P_SALES_STAGE_ID		   IN  NUMBER,
 X_RETURN_STATUS           OUT NOCOPY VARCHAR2,
 X_MSG_COUNT               OUT NOCOPY NUMBER,
 X_MSG_DATA                OUT NOCOPY VARCHAR2
 );

END AS_SALES_METHODOLOGY_PVT;

 

/
