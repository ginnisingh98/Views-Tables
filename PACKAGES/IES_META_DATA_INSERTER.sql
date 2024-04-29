--------------------------------------------------------
--  DDL for Package IES_META_DATA_INSERTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IES_META_DATA_INSERTER" AUTHID CURRENT_USER AS
  /* $Header: iesmdins.pls 115.2 2003/01/06 20:41:40 appldev noship $ */

  type propval_table is table of NUMBER  INDEX BY BINARY_INTEGER;

  FUNCTION  insertMetaObject(element IN xmldom.DOMElement) RETURN NUMBER;
END IES_META_DATA_INSERTER;

 

/
