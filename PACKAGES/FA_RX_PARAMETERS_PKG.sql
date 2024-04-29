--------------------------------------------------------
--  DDL for Package FA_RX_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_RX_PARAMETERS_PKG" AUTHID CURRENT_USER as
/* $Header: faxrxpms.pls 120.3.12010000.2 2009/07/19 13:14:23 glchen ship $ */

  procedure insert_row (X_rowid  in out nocopy varchar2,
	X_report_id    number,
	X_lov_id	number,
	X_name		varchar2,
	X_required	varchar2,
	X_max_length	number,
	X_datatype	varchar2,
	X_relop		varchar2,
	X_last_update_date date,
	X_last_updated_by  number,
	X_created_by   number,
	X_creation_date  date,
	X_last_update_login  number,
	X_parameter_counter  number,
	X_column_name	varchar2,
	X_calling_fn	varchar2);

  procedure lock_row (X_rowid	in out nocopy varchar2,
	X_report_id		number,
	X_lov_id		number,
	X_parameter_counter	number,
	X_column_name		varchar2,
	X_name			varchar2,
	X_required		varchar2,
	X_max_length		number,
	X_datatype		varchar2,
	X_relop			varchar2,
	X_calling_fn		varchar2);


  procedure update_row (X_rowid  in out nocopy varchar2,
	X_report_id    number,
	X_lov_id	number,
	X_name		varchar2,
	X_required	varchar2,
	X_max_length	number,
	X_datatype	varchar2,
	X_relop		varchar2,
	X_last_update_date date,
	X_last_updated_by  number,
	X_last_update_login  number,
	X_parameter_counter  number,
	X_column_name	varchar2,
	X_calling_fn	varchar2);

  procedure delete_row (X_rowid	varchar2,
	X_report_id	number,
	X_name		varchar2,
	X_calling_fn	varchar2);

end FA_RX_PARAMETERS_PKG;

/
