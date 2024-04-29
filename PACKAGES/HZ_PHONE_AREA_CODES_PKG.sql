--------------------------------------------------------
--  DDL for Package HZ_PHONE_AREA_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PHONE_AREA_CODES_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHPHARS.pls 115.3 2003/09/06 01:40:10 awu noship $ */
PROCEDURE Insert_Row(
                    p_rowid                 IN OUT NOCOPY         VARCHAR2,
                    p_TERRITORY_CODE                       VARCHAR2,
                    p_AREA_CODE                            VARCHAR2,
                    p_PHONE_COUNTRY_CODE                   VARCHAR2,
                    p_DESCRIPTION                          VARCHAR2,
                    p_CREATED_BY                           NUMBER,
                    p_CREATION_DATE                        DATE,
                    p_LAST_UPDATE_LOGIN                    NUMBER,
                    p_LAST_UPDATE_DATE                     DATE,
                    p_LAST_UPDATED_BY                      NUMBER,
                    p_OBJECT_VERSION_NUMBER                NUMBER,
		    p_TIMEZONE_ID			   NUMBER DEFAULT NULL);


PROCEDURE Lock_Row(
                   p_TERRITORY_CODE        IN OUT NOCOPY     VARCHAR2,
                   p_AREA_CODE             IN OUT NOCOPY     VARCHAR2,
                   p_OBJECT_VERSION_NUMBER IN          NUMBER);

PROCEDURE Update_Row(
                    p_rowid                                VARCHAR2,
                    p_TERRITORY_CODE                       VARCHAR2,
                    p_AREA_CODE                            VARCHAR2,
                    p_PHONE_COUNTRY_CODE                   VARCHAR2,
                    p_DESCRIPTION                          VARCHAR2,
                    p_CREATED_BY                           NUMBER,
                    p_CREATION_DATE                        DATE,
                    p_LAST_UPDATE_LOGIN                    NUMBER,
                    p_LAST_UPDATE_DATE                     DATE,
                    p_LAST_UPDATED_BY                      NUMBER,
                    p_OBJECT_VERSION_NUMBER IN OUT NOCOPY         NUMBER,
		    p_TIMEZONE_ID			   NUMBER DEFAULT NULL);


PROCEDURE Delete_Row(p_TERRITORY_CODE  VARCHAR2,  P_AREA_CODE VARCHAR2);

END HZ_PHONE_AREA_CODES_PKG;

 

/
