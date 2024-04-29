--------------------------------------------------------
--  DDL for Package JTF_EXCEPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_EXCEPTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: jtfvtves.pls 115.1 2000/02/16 16:36:01 pkm ship      $ */


PROCEDURE Insert_Row(
                  x_Rowid                          IN OUT VARCHAR2,
                  x_EXCEPTIONS_ID                  IN OUT NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_ID                        IN     NUMBER,
                  x_RESOURCE_ID                    IN     NUMBER,
                  x_CUSTOMER_ID                    IN     NUMBER,
                  x_ADDRESS_ID                     IN     NUMBER,
                  x_LEAD_ID                        IN     NUMBER,
                  x_OPPORTUNITY_ID                 IN     NUMBER,
                  x_ORG_ID                         IN     NUMBER);



PROCEDURE Lock_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_EXCEPTIONS_ID                  IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_ID                        IN     NUMBER,
                  x_RESOURCE_ID                    IN     NUMBER,
                  x_CUSTOMER_ID                    IN     NUMBER,
                  x_ADDRESS_ID                     IN     NUMBER,
                  x_LEAD_ID                        IN     NUMBER,
                  x_OPPORTUNITY_ID                 IN     NUMBER,
                  x_ORG_ID                         IN     NUMBER);



PROCEDURE Update_Row(
                  x_Rowid                          IN     VARCHAR2,
                  x_EXCEPTIONS_ID                  IN     NUMBER,
                  x_LAST_UPDATE_DATE               IN     DATE,
                  x_LAST_UPDATED_BY                IN     NUMBER,
                  x_CREATION_DATE                  IN     DATE,
                  x_CREATED_BY                     IN     NUMBER,
                  x_LAST_UPDATE_LOGIN              IN     NUMBER,
                  x_TERR_ID                        IN     NUMBER,
                  x_RESOURCE_ID                    IN     NUMBER,
                  x_CUSTOMER_ID                    IN     NUMBER,
                  x_ADDRESS_ID                     IN     NUMBER,
                  x_LEAD_ID                        IN     NUMBER,
                  x_OPPORTUNITY_ID                 IN     NUMBER,
                  x_ORG_ID                         IN     NUMBER);



PROCEDURE Delete_Row(                  x_EXCEPTIONS_ID                  IN     NUMBER);

END JTF_EXCEPTIONS_PKG;

 

/
