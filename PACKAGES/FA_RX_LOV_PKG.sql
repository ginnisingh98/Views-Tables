--------------------------------------------------------
--  DDL for Package FA_RX_LOV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_RX_LOV_PKG" AUTHID CURRENT_USER as
/* $Header: faxrxlvs.pls 120.3.12010000.2 2009/07/19 13:13:26 glchen ship $ */

  type param_array is table of varchar2(30)
	index by binary_integer;


  procedure unparse_lov_select (
	X_lovid		number,
	X_params	fa_rx_lov_pkg.param_array,
	X_param_types	fa_rx_lov_pkg.param_array,
	X_num_params	number,
	X_select out nocopy varchar2,
	X_missing_param out nocopy number);

end FA_RX_LOV_PKG;

/
