--------------------------------------------------------
--  DDL for Package AMS_PROD_TEMPLATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_PROD_TEMPLATE_PKG" AUTHID CURRENT_USER as
/* $Header: amstptms.pls 115.3 2003/03/07 21:56:15 mukumar ship $ */

procedure  LOAD_ROW(
 X_TEMPLATE_ID             IN        NUMBER,
 X_PRODUCT_SERVICE_FLAG    IN       VARCHAR2,
 X_TEMPLATE_NAME           IN       VARCHAR2,
 X_DESCRIPTION             IN       VARCHAR2 ,
 X_Owner                   IN       VARCHAR2,
 X_CUSTOM_MODE                 IN       VARCHAR2
);

procedure ADD_LANGUAGE;

PROCEDURE TRANSLATE_ROW (
   x_template_id      IN NUMBER,
   x_template_name    IN VARCHAR2,
   x_description      IN VARCHAR2,
   x_owner            IN VARCHAR2
);
end AMS_PROD_TEMPLATE_PKG;

 

/
