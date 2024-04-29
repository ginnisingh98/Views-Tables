--------------------------------------------------------
--  DDL for Package Body PAY_JP_SWOT_NUMBERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_JP_SWOT_NUMBERS_PKG" AS
/* $Header: pyjppswn.pkb 120.1.12010000.3 2009/06/24 06:49:56 keyazawa ship $ */
--
-------------------------------------------------------------------------------
--                            INSERT ROW
--
-- To insert a row into PAY_JP_SWOT_NUMBERS from PAYJPSWN.fmx
--
-------------------------------------------------------------------------------
PROCEDURE insert_row
(
	x_rowid                 in out nocopy varchar2,
	x_organization_id       in            number,
	x_district_code         in            varchar2,
	x_report_district_code  in            varchar2,
	x_swot_number           in            varchar2,
  x_efile_exclusive_flag  in            varchar2,
  x_output_file_name      in            varchar2,
  x_import_exclusive_flag in            varchar2,
  x_input_file_name       in            varchar2,
	x_last_update_date      in            date,
	x_last_updated_by       in            number,
	x_last_update_login     in            number,
	x_created_by            in            number,
	x_creation_date         in            date
)IS
	--
	cursor cur_row is
		select rowidtochar(rowid)
		from pay_jp_swot_numbers
		where organization_id = x_organization_id
		and district_code = x_district_code;
	--
BEGIN
	--
	insert into pay_jp_swot_numbers
	(
		organization_id,
		district_code,
		report_district_code,
		swot_number,
    efile_exclusive_flag,
    output_file_name,
    import_exclusive_flag,
    input_file_name,
		last_update_date,
		last_updated_by,
		last_update_login,
		created_by,
		creation_date
	)
	values
	(
		x_organization_id,
		x_district_code,
		x_report_district_code,
		x_swot_number,
    x_efile_exclusive_flag,
    x_output_file_name,
    x_import_exclusive_flag,
    x_input_file_name,
		x_last_update_date,
		x_last_updated_by,
		x_last_update_login,
		x_created_by,
		x_creation_date
	);
	--
	open cur_row;
	fetch cur_row into x_rowid;
	--
	if (cur_row%NOTFOUND) then
		close cur_row;
		raise NO_DATA_FOUND;
	end if;
	--
	close cur_row;
--
END insert_row;
--
-------------------------------------------------------------------------------
--                            LOCK ROW
--
-- To lock row of PAY_JP_SWOT_NUMBERS from PAYJPSWN.fmx
--
-------------------------------------------------------------------------------
PROCEDURE lock_row
(
	x_rowid                 in  varchar2,
	x_organization_id       in  number,
	x_district_code         in  varchar2,
	x_report_district_code  in  varchar2,
	x_swot_number           in  varchar2,
  x_efile_exclusive_flag  in  varchar2,
  x_output_file_name      in  varchar2,
  x_import_exclusive_flag in  varchar2,
  x_input_file_name       in  varchar2,
	x_last_update_date      in  date,
	x_last_updated_by       in  number,
	x_last_update_login     in  number,
	x_created_by            in  number,
	x_creation_date         in  date
)IS
	--
	cursor cur_row is
		select
			organization_id,
			district_code,
			report_district_code,
			swot_number,
      efile_exclusive_flag,
      output_file_name,
      import_exclusive_flag,
      input_file_name,
			last_update_date,
			last_updated_by,
			last_update_login,
			created_by,
			creation_date
		from
			pay_jp_swot_numbers
		where
			rowid = chartorowid(x_rowid)
		for update of
			organization_id,
			district_code,
			report_district_code,
			swot_number,
      efile_exclusive_flag,
      output_file_name,
      import_exclusive_flag,
      input_file_name
		nowait;
	--
	l_cur_row cur_row%ROWTYPE;
	--
BEGIN
	--
	open cur_row;
	fetch cur_row into l_cur_row;
	--
	if (cur_row%NOTFOUND) then
		close cur_row;
		fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
		app_exception.raise_exception;
	end if;
	--
	if
		l_cur_row.organization_id = x_organization_id
		and
		l_cur_row.district_code = x_district_code
		and
		(
			l_cur_row.report_district_code = x_report_district_code
			or
			(
				l_cur_row.report_district_code is null
				and
				x_report_district_code is null
			)
		)
		and
		(
			l_cur_row.swot_number = x_swot_number
			or
			(
				l_cur_row.swot_number is null
				and
				x_swot_number is null
			)
		)
		and
		l_cur_row.last_update_date = x_last_update_date
		and
		l_cur_row.last_updated_by = x_last_updated_by
		and
		(
			l_cur_row.last_update_login = x_last_update_login
			or
			(
				l_cur_row.last_update_login is null
				and
				x_last_update_login is null
			)
		)
		and
		l_cur_row.created_by = x_created_by
		and
		l_cur_row.creation_date = x_creation_date
	then
		return;
	else
		fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
		app_exception.raise_exception;
	end if;
	--
END lock_row;
--
-------------------------------------------------------------------------------
--                            UPDATE ROW
--
-- To update row of PAY_JP_SWOT_NUMBERS from PAYJPSWN.fmx
--
-------------------------------------------------------------------------------
PROCEDURE update_row
(
	x_rowid                 in  varchar2,
	x_organization_id       in  number,
	x_district_code         in  varchar2,
	x_report_district_code  in  varchar2,
	x_swot_number           in  varchar2,
  x_efile_exclusive_flag  in  varchar2,
  x_output_file_name      in  varchar2,
  x_import_exclusive_flag in  varchar2,
  x_input_file_name       in  varchar2,
	x_last_update_date      in  date,
	x_last_updated_by       in  number,
	x_last_update_login     in  number,
	x_created_by            in  number,
	x_creation_date         in  date
)IS
BEGIN
	--
	update
		pay_jp_swot_numbers
	set
		organization_id       = x_organization_id,
		district_code         = x_district_code,
		report_district_code  = x_report_district_code,
		swot_number           = x_swot_number,
    efile_exclusive_flag  = x_efile_exclusive_flag,
    output_file_name      = x_output_file_name,
    import_exclusive_flag = x_import_exclusive_flag,
    input_file_name       = x_input_file_name,
		last_update_date      = x_last_update_date,
		last_updated_by       = x_last_updated_by,
		last_update_login     = x_last_update_login,
		created_by            = x_created_by,
		creation_date         = x_creation_date
	where
		rowid = chartorowid(x_rowid);
	--
	if (SQL%NOTFOUND) then
		raise NO_DATA_FOUND;
	end if;
	--
END update_row;
--
--------------------------------------------------------------------------------
--                            DELETE ROW
--
-- To delete row of PAY_JP_SWOT_NUMBERS from PAYJPSWN.fmx
--
-------------------------------------------------------------------------------
PROCEDURE delete_row(x_rowid in varchar2)IS
BEGIN
	--
	delete from pay_jp_swot_numbers
	where rowid = chartorowid(x_rowid);
	--
	if (SQL%NOTFOUND) then
		raise NO_DATA_FOUND;
	end if;
	--
END delete_row;
--
--------------------------------------------------------------------------------
--                            CHK SWOT NUMBER
--
-- To check swot number column length. If the column is over 15 byte length,
-- return False.
--
-------------------------------------------------------------------------------
FUNCTION chk_swot_number(p_value in VARCHAR2) return VARCHAR2 IS
	--
	l_length_swot_num number;
	--
BEGIN
	--
	l_length_swot_num := lengthb(p_value);
	--
	if l_length_swot_num > 15 then
		return('FALSE');
	elsif l_length_swot_num is null then
		return('FALSE');
	elsif l_length_swot_num < 1 then
		return('FALSE');
	else
		return('TRUE');
	end if;
	--
END chk_swot_number;
--
-- -------------------------------------------------------------------------
-- chk_output_file_name
-- -------------------------------------------------------------------------
function chk_output_file_name(
  p_output_file_name in varchar2)
return boolean
is
--
  l_val_symbol     varchar2(255) := '._-';
  l_inv_symbol     varchar2(255) := ' !"#$%&''()*+,/:;<=>?@[\]^`{|}~';
  l_inv_tra_symbol varchar2(255) := '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@';
  l_result boolean := true;
--
begin
--
  if p_output_file_name is not null then
  --
    if lengthb(p_output_file_name) <> length(p_output_file_name) then
      l_result := false;
    elsif instr(translate(p_output_file_name,l_inv_symbol,l_inv_tra_symbol),'@') <> 0 then
      l_result := false;
    elsif translate(p_output_file_name,'@'||l_val_symbol,'@') is null then
      l_result := false;
    end if;
  --
  end if;
--
return l_result;
end chk_output_file_name;
--
END PAY_JP_SWOT_NUMBERS_PKG;

/
