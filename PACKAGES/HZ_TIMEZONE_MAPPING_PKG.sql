--------------------------------------------------------
--  DDL for Package HZ_TIMEZONE_MAPPING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_TIMEZONE_MAPPING_PKG" AUTHID CURRENT_USER as
/*$Header: ARHTZMPS.pls 120.2 2005/10/30 03:55:21 appldev ship $ */

PROCEDURE Insert_Row(
                  x_Rowid                         VARCHAR2,
                  x_MAPPING_ID                    NUMBER,
                  x_AREA_CODE                     VARCHAR2,
                  x_POSTAL_CODE                   VARCHAR2,
                  x_CITY                          VARCHAR2,
                  x_STATE                         VARCHAR2,
                  x_PROVINCE                      VARCHAR2,
                  x_COUNTRY                       VARCHAR2,
                  x_TIMEZONE_ID                   NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_CREATED_BY                    NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_LAST_UPDATE_LOGIN             NUMBER);



PROCEDURE Lock_Row(
                  x_Rowid                         VARCHAR2,
                  x_MAPPING_ID                    NUMBER,
                  x_AREA_CODE                     VARCHAR2,
                  x_POSTAL_CODE                   VARCHAR2,
                  x_CITY                          VARCHAR2,
                  x_STATE                         VARCHAR2,
                  x_PROVINCE                      VARCHAR2,
                  x_COUNTRY                       VARCHAR2,
                  x_TIMEZONE_ID                   NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_CREATED_BY                    NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_LAST_UPDATE_LOGIN             NUMBER);



PROCEDURE Update_Row(
                  x_Rowid                         VARCHAR2,
                  x_MAPPING_ID                    NUMBER,
                  x_AREA_CODE                     VARCHAR2,
                  x_POSTAL_CODE                   VARCHAR2,
                  x_CITY                          VARCHAR2,
                  x_STATE                         VARCHAR2,
                  x_PROVINCE                      VARCHAR2,
                  x_COUNTRY                       VARCHAR2,
                  x_TIMEZONE_ID                   NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_CREATED_BY                    NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_LAST_UPDATE_LOGIN             NUMBER);



PROCEDURE Delete_Row(                  x_MAPPING_ID                    NUMBER);

END HZ_TIMEZONE_MAPPING_PKG;

 

/
