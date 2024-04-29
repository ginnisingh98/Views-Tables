--------------------------------------------------------
--  DDL for Package HZ_MOBILE_PREFIXES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_MOBILE_PREFIXES_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHMOPRS.pls 120.1 2005/06/16 21:12:35 jhuang noship $ */

PROCEDURE Insert_Row(
                    p_rowid            IN OUT              NOCOPY VARCHAR2,
                    p_TERRITORY_CODE                       VARCHAR2,
                    p_MOBILE_PREFIX                        VARCHAR2,
                    p_PHONE_COUNTRY_CODE                   VARCHAR2,
                    p_DESCRIPTION                          VARCHAR2,
                    p_CREATED_BY                           NUMBER,
                    p_CREATION_DATE                        DATE,
                    p_LAST_UPDATE_LOGIN                    NUMBER,
                    p_LAST_UPDATE_DATE                     DATE,
                    p_LAST_UPDATED_BY                      NUMBER,
                    p_OBJECT_VERSION_NUMBER                NUMBER);


PROCEDURE Lock_Row(
                   p_TERRITORY_CODE        IN OUT     NOCOPY VARCHAR2,
                   p_MOBILE_PREFIX         IN OUT     NOCOPY VARCHAR2,
                   p_OBJECT_VERSION_NUMBER IN          NUMBER);

PROCEDURE Update_Row(
                    p_rowid                                VARCHAR2,
                    p_TERRITORY_CODE                       VARCHAR2,
                    p_MOBILE_PREFIX                        VARCHAR2,
                    p_PHONE_COUNTRY_CODE                   VARCHAR2,
                    p_DESCRIPTION                          VARCHAR2,
                    p_CREATED_BY                           NUMBER,
                    p_CREATION_DATE                        DATE,
                    p_LAST_UPDATE_LOGIN                    NUMBER,
                    p_LAST_UPDATE_DATE                     DATE,
                    p_LAST_UPDATED_BY                      NUMBER,
                    p_OBJECT_VERSION_NUMBER IN OUT         NOCOPY NUMBER);


PROCEDURE Delete_Row(p_TERRITORY_CODE  VARCHAR2,  P_MOBILE_PREFIX VARCHAR2);

END HZ_MOBILE_PREFIXES_PKG;

 

/
