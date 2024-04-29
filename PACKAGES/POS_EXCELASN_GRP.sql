--------------------------------------------------------
--  DDL for Package POS_EXCELASN_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_EXCELASN_GRP" AUTHID CURRENT_USER AS
/* $Header: POSGEXAS.pls 115.2 2003/08/21 22:21:12 fuagusti noship $ */

procedure ValidateAndSave_Records(	p_api_version in number,
									x_return_status out NOCOPY varchar2,
									p_file_name in varchar2,
									p_headers_tbl in POS_EXCELASN_HEADER_TABLE,
									p_lines_tbl in POS_EXCELASN_LINE_TABLE,
									p_lots_tbl in out NOCOPY POS_EXCELASN_LOT_TABLE,
									p_serials_tbl in out NOCOPY POS_EXCELASN_SERIAL_TABLE,
									p_lpns_tbl in out NOCOPY POS_EXCELASN_LPN_TABLE,
									x_group_id out NOCOPY number,
									x_return_code out NOCOPY varchar2,
									x_return_msg out NOCOPY varchar2,
									x_error_tbl out NOCOPY POS_EXCELASN_ERROR_TABLE );



END Pos_ExcelAsn_GRP;

 

/
