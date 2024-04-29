--------------------------------------------------------
--  DDL for Package Body FA_RX_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_RX_PARAMETERS_PKG" as
/* $Header: faxrxpmb.pls 120.4.12010000.2 2009/07/19 13:13:55 glchen ship $ */

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
	X_calling_fn	varchar2) is

  cursor c is select rowid from fa_rx_rep_parameters
	where report_id = X_report_id and name = X_name;

  begin


    insert into fa_rx_rep_parameters (
	report_id,	lov_id,	name,	required,
	max_length,	datatype,	relational_op, last_update_date,
	last_updated_by,	created_by,	creation_date,
	last_update_login,	parameter_counter,	column_name)
	values (	X_report_id,	X_lov_id,	X_name,	X_required,
	X_max_length,	X_datatype,	X_relop, X_last_update_date,
	X_last_updated_by,	X_created_by,	X_creation_date,
	X_last_update_login,	X_parameter_counter,	X_column_name);

    open c;
    fetch c into X_rowid;
    if (c%notfound) then
	close c;
	raise no_data_found;
    end if;
    close c;

  exception when others then
                FA_STANDARD_PKG.RAISE_ERROR
                        (Called_Fn      => 'FA_RX_PARAMETERS_PKG.Insert_Row',
                        Calling_Fn      => X_Calling_Fn);

  end insert_row;

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
	X_calling_fn		varchar2) is

 cursor c_reports is
 SELECT *
 FROM FA_RX_REP_parameters
 WHERE ROWID = X_ROWID
 FOR UPDATE OF REPORT_ID, name NOWAIT;
 Recinfo c_reports%rowtype;

  begin

 Open c_reports;
 Fetch c_reports into recinfo;
 IF (c_reports%notfound) then
   close c_reports;
   fnd_message.set_name('FND','FORM_RECORD_DELETED');
   app_exception.raise_exception;

 End if;
 Close c_reports;

 if (
	(recinfo.report_id = X_report_id)
 AND	(nvl(recinfo.lov_id,-9999) = nvl(X_lov_id,-9999))
 AND	(recinfo.parameter_counter = X_parameter_counter)
 AND	(nvl(recinfo.column_name,'X') = nvl(X_column_name,'X'))
 AND	(nvl(recinfo.name,'X') = nvl(X_name,'X'))
 AND    (nvl(recinfo.relational_op,'X') = nvl(X_relop,'X'))
 AND	(recinfo.required = X_required)
 AND	(recinfo.max_length = X_max_length)
 AND	(recinfo.datatype = X_datatype)) then
	return;
   else
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if;

  end lock_row;


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
	X_calling_fn	varchar2) is

  begin

  update fa_rx_rep_parameters set
	report_id = X_report_id,
	lov_id = X_lov_id,
	name = X_name,
	required = X_required,
	max_length = X_max_length,
	datatype = X_datatype,
	relational_op = X_relop,
	last_update_date = X_last_update_date,
	last_updated_by = X_last_updated_by,
	last_update_login = X_last_update_login,
	parameter_counter = X_parameter_counter,
	column_name = X_column_name
  where rowid = X_rowid;

  if (SQL%NOTFOUND) then
	raise no_data_found;
  end if;

  exception WHEN Others THEN
                FA_STANDARD_PKG.RAISE_ERROR
                        (Called_Fn      => 'FA_RX_PARAMETERS_PKG.Update_Row',
                        Calling_Fn      => X_Calling_Fn);


  end update_row;

  procedure delete_row (X_rowid	varchar2,
	X_report_id	number,
	X_name		varchar2,
	X_calling_fn	varchar2) is
  begin

    if x_rowid is not null then
	delete from fa_rx_rep_parameters
	where rowid = X_rowid;
    else  -- error
	null;
    end if;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  EXCEPTION
        WHEN Others THEN
                FA_STANDARD_PKG.RAISE_ERROR
                        (Called_Fn      => 'FA_RX_PARAMETERS_PKG.Delete_Row',
                        Calling_Fn      => X_Calling_Fn);
  end delete_row;

end FA_RX_PARAMETERS_PKG;

/
