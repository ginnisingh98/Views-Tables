--------------------------------------------------------
--  DDL for Package CS_KB_PROFILES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_KB_PROFILES_PKG" AUTHID CURRENT_USER AS
/* $Header: cskbpros.pls 115.3 2003/12/18 23:17:20 mkettle noship $ */

FUNCTION isCategorymember(
  m_user_id  	IN  NUMBER,
  m_category_id IN  NUMBER
  )
  RETURN NUMBER;

FUNCTION isProductmember(
  m_user_id  	   IN  NUMBER,
  m_product_id 	   IN  NUMBER,
  m_product_org_id IN NUMBER
  )
  RETURN NUMBER;

-- Package Specification CS_KB_PROFILES_PKG
END;

 

/
