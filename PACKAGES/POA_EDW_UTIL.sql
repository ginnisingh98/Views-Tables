--------------------------------------------------------
--  DDL for Package POA_EDW_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_EDW_UTIL" AUTHID CURRENT_USER AS
/* $Header: poautils.pls 120.0 2005/06/01 18:09:06 appldev noship $ */

  -- Cloned from inv_convert.inv_um_conversion

  PROCEDURE convert_uom(
      		from_uom_code         	VARCHAR2,
      		to_uom_code           	VARCHAR2,
      		item_id           	NUMBER,
      		uom_rate    	OUT NOCOPY 	NUMBER);

  -- Cloned from inv_convert.inv_um_convert

  FUNCTION get_uom_rate(
      		item_id           	NUMBER,
      		precision		NUMBER,
      		from_quantity     	NUMBER,
      		from_uom_code         	VARCHAR2,
      		to_uom_code           	VARCHAR2,
      		from_uom_name		VARCHAR2,
      		to_uom_name		VARCHAR2) RETURN NUMBER;


  PRAGMA RESTRICT_REFERENCES(convert_uom, WNDS, WNPS, RNPS);
  PRAGMA RESTRICT_REFERENCES(get_uom_rate, WNDS, WNPS, RNPS);

END poa_edw_util;

 

/
