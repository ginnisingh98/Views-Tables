--------------------------------------------------------
--  DDL for Package GMAUOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMAUOM" AUTHID CURRENT_USER as
/*      $Header: gmauomvs.pls 120.0 2005/05/25 15:31:51 appldev noship $ */

	function isUomCodeThere(
			p_row_id Varchar2,
			p_uom_code varchar2) return boolean;

	function isUnitOfMeasureThere(
			p_row_id Varchar2,
			p_unit_of_measure varchar2) return boolean;

end gmaUom;

 

/
