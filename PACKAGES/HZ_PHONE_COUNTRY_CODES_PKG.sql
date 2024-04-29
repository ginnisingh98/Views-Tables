--------------------------------------------------------
--  DDL for Package HZ_PHONE_COUNTRY_CODES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PHONE_COUNTRY_CODES_PKG" AUTHID CURRENT_USER AS
/*$Header: ARHPHCCS.pls 115.3 2003/09/06 01:44:49 awu noship $ */

PROCEDURE Lock_Row(
                   p_TERRITORY_CODE       IN OUT NOCOPY     VARCHAR2,
                   p_OBJECT_VERSION_NUMBER           NUMBER);

PROCEDURE Update_Row(
                    p_TERRITORY_CODE                    VARCHAR2,
                    p_PHONE_COUNTRY_CODE                VARCHAR2,
                    p_PHONE_LENGTH                      NUMBER,
                    p_AREA_CODE_LENGTH                  NUMBER,
                    p_TRUNK_PREFIX                      VARCHAR2,
                    p_INTL_PREFIX                       VARCHAR2,
                    p_VALIDATION_PROC                   VARCHAR2,
                    p_CREATED_BY                        NUMBER,
                    p_CREATION_DATE                     DATE,
                    p_LAST_UPDATE_LOGIN                 NUMBER,
                    p_LAST_UPDATE_DATE                  DATE,
                    p_LAST_UPDATED_BY                   NUMBER,
                    p_OBJECT_VERSION_NUMBER     IN OUT NOCOPY  NUMBER,
		    p_TIMEZONE_ID			NUMBER DEFAULT NULL);



END HZ_PHONE_COUNTRY_CODES_PKG;

 

/
