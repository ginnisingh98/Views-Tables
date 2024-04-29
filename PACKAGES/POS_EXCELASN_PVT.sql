--------------------------------------------------------
--  DDL for Package POS_EXCELASN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_EXCELASN_PVT" AUTHID CURRENT_USER AS
/* $Header: POSVEXAS.pls 120.1.12010000.2 2008/11/07 20:23:47 sthoppan ship $ */


TYPE vendor_id_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

procedure ProcessExcelAsn(p_api_version in number,
							x_return_status out nocopy varchar2,
							x_return_code out nocopy varchar2,
							x_return_msg out nocopy varchar2,
							x_error_tbl out NOCOPY POS_EXCELASN_ERROR_TABLE,
							x_user_vendor_id out nocopy number);


function getConvertedQuantity(p_line_location_id in number,
												p_quantity in number,
												p_uom in varchar2
												) return number;

procedure CheckLlsControl(x_return_status out nocopy varchar2,
											x_error_tbl in out nocopy POS_EXCELASN_ERROR_TABLE,
											l_error_pointer in out nocopy number);
procedure CreateNewHeader(p_asn_header_id in number, p_ex_header_id in number,
p_ex_vendor_id in number, p_ex_ship_to_org_id in number, p_ex_vendor_site_id in number);

procedure CreateNewLine(p_qty in number, p_lpn in varchar2, p_line_id in number, p_old_ln in number);
procedure FixHeadersAndLines(x_error_tbl in out NOCOPY POS_EXCELASN_ERROR_TABLE,
												l_error_pointer in out NOCOPY number);

function InsertError(p_error_tbl in out NOCOPY POS_EXCELASN_ERROR_TABLE,
										p_error_msg in varchar2,
										p_error_index in out NOCOPY number)
return number;
procedure InsertIntoLLS(x_return_status out nocopy varchar2,
						p_error_tbl in out nocopy POS_EXCELASN_ERROR_TABLE,
						p_error_pointer in out nocopy number);

procedure CreateRTI4Lot;
procedure CreateRTI4Lpn;
procedure CreateRTI4Ser;
procedure UpdateLinesAndLls(x_error_tbl in out NOCOPY POS_EXCELASN_ERROR_TABLE,
												l_error_pointer in out NOCOPY number);
procedure ValidateHeaders(x_return_status out nocopy varchar2,
											p_error_tbl in out nocopy POS_EXCELASN_ERROR_TABLE,
											p_error_pointer in out nocopy number);
procedure ValidateLines(x_return_status out nocopy varchar2,
										p_user_vendor_id_tbl in vendor_id_tbl_type,
										p_secure_by_site in varchar2,
										p_secure_by_contact in varchar2,
										x_error_tbl in out nocopy POS_EXCELASN_ERROR_TABLE,
										x_error_pointer in out nocopy number);
procedure ValidateLls(x_return_status out nocopy varchar2,
										x_error_tbl in out NOCOPY POS_EXCELASN_ERROR_TABLE,
										x_error_pointer in out NOCOPY number);

function get_status(p_group_id in number) return varchar2;

--Refer the bug 7338353 and its package body for more information
function getvendorpaysiteid(p_vendor_id in varchar2,p_vendor_site_id IN varchar2,p_currency_code IN varchar2) RETURN PO_VENDOR_SITES_ALL.vendor_site_id%TYPE;


END Pos_ExcelAsn_PVT;

/
