--------------------------------------------------------
--  DDL for Package PSP_ORG_DLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ORG_DLS_PKG" AUTHID CURRENT_USER AS
  /* $Header: PSPLSDLS.pls 120.1 2006/11/07 06:04:41 tbalacha noship $ */
  Function Insert_Records_To_Table(p_template_id number, p_start_date DATE,p_end_date DATE
                                  ,p_set_of_books_id number,p_business_group_id  number)  return NUMBER;
   g_element_type_id_str  Varchar2(2000);
  g_organization_str     Varchar2(2000);
END;

/
