--------------------------------------------------------
--  DDL for Package IES_META_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IES_META_DATA_PKG" AUTHID CURRENT_USER AS
  /* $Header: iesmdpks.pls 115.2 2003/01/06 20:41:42 appldev noship $ */

  type childEntities_table is table of xmldom.DOMNode INDEX BY BINARY_INTEGER;

  PROCEDURE writeMetaDataObject(obj IN CLOB);
  PROCEDURE writeMetaDataObjectDebug(obj IN varchar2);

  FUNCTION  getTemporaryClob return CLOB;
  FUNCTION  saveObjectToDB(element   IN xmldom.DOMElement,
                           rootObjId IN NUMBER,
                           objOrder  IN NUMBER)   return NUMBER;
  FUNCTION  getMetaDataObject(objectId IN NUMBER) return CLOB;
END IES_META_DATA_PKG;

 

/
