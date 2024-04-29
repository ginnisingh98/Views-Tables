--------------------------------------------------------
--  DDL for Package AMS_PROD_TEMP_RESP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_PROD_TEMP_RESP_PKG" AUTHID CURRENT_USER as
/* $Header: amstptrs.pls 115.2 2003/03/07 21:56:18 mukumar noship $ */

procedure  LOAD_ROW(
   X_TEMPL_RESPONSIBILITY_ID  IN NUMBER
  ,X_TEMPLATE_ID              IN NUMBER
  ,X_RESPONSIBILITY_ID        IN NUMBER
  ,X_Owner                    IN VARCHAR2
  ,X_CUSTOM_MODE              IN       VARCHAR2
);

end AMS_PROD_TEMP_RESP_PKG;

 

/
