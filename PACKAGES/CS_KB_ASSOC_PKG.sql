--------------------------------------------------------
--  DDL for Package CS_KB_ASSOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_KB_ASSOC_PKG" AUTHID CURRENT_USER AS
/* $Header: cskbass.pls 115.6 2002/11/11 23:49:09 mkettle noship $ */

  /* for return status */
  ERROR_STATUS      CONSTANT NUMBER      := -1;
  OKAY_STATUS       CONSTANT NUMBER      := 0;

 function Clone_Link(
  P_SET_SOURCE_ID in NUMBER,
  P_SET_TARGET_ID in NUMBER
 )return number;

   PROCEDURE add_link(
       p_item_id IN JTF_NUMBER_TABLE,
       p_org_id  IN JTF_NUMBER_TABLE,
       p_set_id  IN NUMBER,
       p_link_type  IN NUMBER,
       p_task IN NUMBER,
       p_result OUT NOCOPY NUMBER
   );
END; -- Package Specification CS_KB_ASSOC_PKG

 

/
