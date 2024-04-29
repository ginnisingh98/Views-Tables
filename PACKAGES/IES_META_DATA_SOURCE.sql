--------------------------------------------------------
--  DDL for Package IES_META_DATA_SOURCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IES_META_DATA_SOURCE" AUTHID CURRENT_USER AS
  /* $Header: iesmdscs.pls 115.2 2003/01/06 20:41:44 appldev noship $ */

  FUNCTION  getObjectAsXML(objId IN NUMBER) RETURN CLOB;
  PROCEDURE convertObjectToXML(objId IN NUMBER);
  PROCEDURE convertChildObjectsToXML(objId IN NUMBER);

END IES_META_DATA_SOURCE;

 

/
