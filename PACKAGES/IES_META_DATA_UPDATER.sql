--------------------------------------------------------
--  DDL for Package IES_META_DATA_UPDATER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IES_META_DATA_UPDATER" AUTHID CURRENT_USER AS
  /* $Header: iesmdups.pls 115.3 2003/01/06 20:41:48 appldev noship $ */

  type propval_table is table of NUMBER  INDEX BY BINARY_INTEGER;
  FUNCTION  updateMetaObject(element IN xmldom.DOMElement) RETURN NUMBER;
END IES_META_DATA_UPDATER;

 

/
