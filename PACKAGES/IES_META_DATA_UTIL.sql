--------------------------------------------------------
--  DDL for Package IES_META_DATA_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IES_META_DATA_UTIL" AUTHID CURRENT_USER AS
  /* $Header: iesmduts.pls 115.2 2003/01/06 20:41:50 appldev noship $ */

  FUNCTION getObjectTypeId(x_name IN VARCHAR2) return NUMBER;
  FUNCTION getProperty(element IN xmldom.DOMElement, key IN VARCHAR2) return VARCHAR2;
  FUNCTION  getLookupId(propId IN NUMBER, key IN VARCHAR2) return NUMBER;
  FUNCTION getRelationshipTypeId(typeName VARCHAR2) return NUMBER;
END IES_META_DATA_UTIL;

 

/
