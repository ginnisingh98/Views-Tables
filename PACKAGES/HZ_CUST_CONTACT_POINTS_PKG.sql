--------------------------------------------------------
--  DDL for Package HZ_CUST_CONTACT_POINTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_CUST_CONTACT_POINTS_PKG" AUTHID CURRENT_USER as
/*$Header: ARHCCPTS.pls 115.3 2002/11/21 18:55:07 sponnamb ship $ */



PROCEDURE Insert_Row(
                  x_Rowid            IN OUT NOCOPY       VARCHAR2,
                  x_CUST_CONTACT_POINT_ID         NUMBER,
                  x_CUST_ACCOUNT_ID               NUMBER,
                  x_CUST_ACCOUNT_SITE_ID          NUMBER,
                  x_CUST_ACCOUNT_ROLE_ID          NUMBER,
                  x_CONTACT_POINT_ID              NUMBER,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_STATUS                        VARCHAR2,
                  x_REQUEST_ID                    NUMBER,
                  x_PROGRAM_APPLICATION_ID        NUMBER,
                  x_PROGRAM_ID                    NUMBER,
                  x_PROGRAM_UPDATE_DATE           DATE);



PROCEDURE Lock_Row(
                  x_Rowid                         VARCHAR2,
                  x_CUST_CONTACT_POINT_ID         NUMBER,
                  x_CUST_ACCOUNT_ID               NUMBER,
                  x_CUST_ACCOUNT_SITE_ID          NUMBER,
                  x_CUST_ACCOUNT_ROLE_ID          NUMBER,
                  x_CONTACT_POINT_ID              NUMBER,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_STATUS                        VARCHAR2,
                  x_REQUEST_ID                    NUMBER,
                  x_PROGRAM_APPLICATION_ID        NUMBER,
                  x_PROGRAM_ID                    NUMBER,
                  x_PROGRAM_UPDATE_DATE           DATE);



PROCEDURE Update_Row(
                  x_Rowid                         VARCHAR2,
                  x_CUST_CONTACT_POINT_ID         NUMBER,
                  x_CUST_ACCOUNT_ID               NUMBER,
                  x_CUST_ACCOUNT_SITE_ID          NUMBER,
                  x_CUST_ACCOUNT_ROLE_ID          NUMBER,
                  x_CONTACT_POINT_ID              NUMBER,
                  x_LAST_UPDATED_BY               NUMBER,
                  x_LAST_UPDATE_DATE              DATE,
                  x_CREATED_BY                    NUMBER,
                  x_CREATION_DATE                 DATE,
                  x_LAST_UPDATE_LOGIN             NUMBER,
                  x_STATUS                        VARCHAR2,
                  x_REQUEST_ID                    NUMBER,
                  x_PROGRAM_APPLICATION_ID        NUMBER,
                  x_PROGRAM_ID                    NUMBER,
                  x_PROGRAM_UPDATE_DATE           DATE);



PROCEDURE Delete_Row(                  x_CUST_CONTACT_POINT_ID         NUMBER);

END HZ_CUST_CONTACT_POINTS_PKG;

 

/
