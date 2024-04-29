--------------------------------------------------------
--  DDL for Package MSC_CL_ITEM_PULL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_ITEM_PULL" AUTHID CURRENT_USER AS -- specification
/* $Header: MSCPITES.pls 120.1 2007/04/09 06:51:20 vpalla noship $ */
--   SYS_YES                      CONSTANT NUMBER := MSC_UTIL.SYS_YES;
--   SYS_NO                       CONSTANT NUMBER := MSC_UTIL.SYS_NO   ;

--   G_SUCCESS                    CONSTANT NUMBER := MSC_UTIL.G_SUCCESS;
--   G_WARNING                    CONSTANT NUMBER := MSC_UTIL.G_WARNING;
--   G_ERROR                      CONSTANT NUMBER := MSC_UTIL.G_ERROR  ;

 --  G_APPS107                    CONSTANT NUMBER := MSC_UTIL.G_APPS107;
 --  G_APPS110                    CONSTANT NUMBER := MSC_UTIL.G_APPS110;
  -- G_APPS115                    CONSTANT NUMBER := MSC_UTIL.G_APPS115;
 --  G_APPS120                    CONSTANT NUMBER := MSC_UTIL.G_APPS120;

 --  G_ALL_ORGANIZATIONS     CONSTANT NUMBER := MSC_UTIL.G_ALL_ORGANIZATIONS;

   /* p_worker_num is added to increases the degree of parallelism */
   PROCEDURE LOAD_ITEM( p_worker_num IN NUMBER);
   --New procedure added for Product Substitution ---
   PROCEDURE LOAD_ITEM_SUBSTITUTES;
   PROCEDURE LOAD_SUPPLIER_CAPACITY;
   PROCEDURE LOAD_CATEGORY;
   PROCEDURE INSERT_DUMMY_ITEMS;
   PROCEDURE INSERT_DUMMY_CATEGORIES;
   /*added for bug:4765403*/
   PROCEDURE LOAD_ABC_CLASSES;


END MSC_CL_ITEM_PULL;

/
