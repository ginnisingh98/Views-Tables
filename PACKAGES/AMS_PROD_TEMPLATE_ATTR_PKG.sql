--------------------------------------------------------
--  DDL for Package AMS_PROD_TEMPLATE_ATTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_PROD_TEMPLATE_ATTR_PKG" AUTHID CURRENT_USER as
/* $Header: amstptas.pls 115.3 2003/03/07 21:56:12 mukumar ship $ */

procedure  LOAD_ROW(
  X_template_attribute_id	IN        NUMBER
 ,X_template_id			IN        NUMBER
 ,X_parent_attribute_code	IN       VARCHAR2
 ,X_parent_select_all		IN       VARCHAR2
 ,X_attribute_code		IN       VARCHAR2
 ,X_default_flag		IN       VARCHAR2
 ,X_editable_flag		IN       VARCHAR2
 ,X_hide_flag			IN       VARCHAR2
 ,X_Owner			IN       VARCHAR2
 ,X_CUSTOM_MODE                 IN       VARCHAR2
);

end AMS_PROD_TEMPLATE_ATTR_PKG;

 

/
