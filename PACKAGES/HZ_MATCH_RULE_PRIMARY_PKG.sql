--------------------------------------------------------
--  DDL for Package HZ_MATCH_RULE_PRIMARY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_MATCH_RULE_PRIMARY_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHDQMPS.pls 120.2 2005/10/30 04:19:08 appldev noship $*/
PROCEDURE Insert_Row(
                    px_PRIMARY_ATTRIBUTE_ID IN OUT  NOCOPY   NUMBER,
                    p_MATCH_RULE_ID                   NUMBER,
                    p_ATTRIBUTE_ID                    NUMBER,
                    p_ACTIVE_FLAG                     VARCHAR2,
                    p_FILTER_FLAG                     VARCHAR2,
                    p_CREATED_BY                      NUMBER,
                    p_CREATION_DATE                   DATE,
                    p_LAST_UPDATE_LOGIN               NUMBER,
                    p_LAST_UPDATE_DATE                DATE,
                    p_LAST_UPDATED_BY                 NUMBER,
                    p_OBJECT_VERSION_NUMBER           NUMBER,
		    p_DISPLAY_ORDER		      NUMBER DEFAULT NULL);


PROCEDURE Lock_Row(
                   p_PRIMARY_ATTRIBUTE_ID  IN OUT  NOCOPY   NUMBER,
                   p_OBJECT_VERSION_NUMBER           NUMBER);

PROCEDURE Update_Row(
                    p_PRIMARY_ATTRIBUTE_ID           NUMBER,
                    p_MATCH_RULE_ID                   NUMBER,
                    p_ATTRIBUTE_ID                    NUMBER,
                    p_ACTIVE_FLAG                     VARCHAR2,
                    p_FILTER_FLAG                     VARCHAR2,
                    p_CREATED_BY                      NUMBER,
                    p_CREATION_DATE                   DATE,
                    p_LAST_UPDATE_LOGIN               NUMBER,
                    p_LAST_UPDATE_DATE                DATE,
                    p_LAST_UPDATED_BY                 NUMBER,
                    p_OBJECT_VERSION_NUMBER in out NOCOPY   NUMBER,
		    p_DISPLAY_ORDER		      NUMBER DEFAULT NULL);


PROCEDURE Delete_Row(p_PRIMARY_ATTRIBUTE_ID                 NUMBER);

END HZ_MATCH_RULE_PRIMARY_PKG;

 

/
