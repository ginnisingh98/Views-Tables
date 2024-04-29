--------------------------------------------------------
--  DDL for Package HZ_SECONDARY_TRANSFORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_SECONDARY_TRANSFORM_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHDQSTS.pls 115.3 2002/11/21 20:00:16 sponnamb noship $*/

PROCEDURE Insert_Row(
                    px_SECONDARY_TRANSFORM_ID IN OUT NOCOPY     NUMBER,
                    p_SECONDARY_ATTRIBUTE_ID            NUMBER,
                    p_FUNCTION_ID                      NUMBER,
                    p_TRANSFORMATION_WEIGHT            NUMBER,
                    p_SIMILARITY_CUTOFF                NUMBER,
                    p_ACTIVE_FLAG                      VARCHAR2,
                    p_USE_EXACT                        VARCHAR2,
                    p_CREATED_BY                       NUMBER,
                    p_CREATION_DATE                    DATE,
                    p_LAST_UPDATE_LOGIN                NUMBER,
                    p_LAST_UPDATE_DATE                 DATE,
                    p_LAST_UPDATED_BY                  NUMBER,
                    p_OBJECT_VERSION_NUMBER            NUMBER);


PROCEDURE Lock_Row(
                    p_SECONDARY_TRANSFORM_ID IN OUT NOCOPY     NUMBER,
                    p_OBJECT_VERSION_NUMBER            NUMBER);

PROCEDURE Update_Row(
                    p_SECONDARY_TRANSFORM_ID            NUMBER,
                    p_SECONDARY_ATTRIBUTE_ID           NUMBER,
                    p_FUNCTION_ID                     NUMBER,
                    p_TRANSFORMATION_WEIGHT            NUMBER,
                    p_SIMILARITY_CUTOFF                NUMBER,
                    p_ACTIVE_FLAG                     VARCHAR2,
                    p_USE_EXACT                        VARCHAR2,
                    p_CREATED_BY                      NUMBER,
                    p_CREATION_DATE                   DATE,
                    p_LAST_UPDATE_LOGIN               NUMBER,
                    p_LAST_UPDATE_DATE                DATE,
                    p_LAST_UPDATED_BY                 NUMBER,
                    p_OBJECT_VERSION_NUMBER IN OUT NOCOPY    NUMBER);

PROCEDURE Delete_Row(p_SECONDARY_TRANSFORM_ID                 NUMBER);

END HZ_SECONDARY_TRANSFORM_PKG;

 

/
