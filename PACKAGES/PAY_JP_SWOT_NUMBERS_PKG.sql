--------------------------------------------------------
--  DDL for Package PAY_JP_SWOT_NUMBERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_JP_SWOT_NUMBERS_PKG" AUTHID CURRENT_USER AS
/* $Header: pyjppswn.pkh 120.1.12010000.3 2009/06/24 06:49:28 keyazawa ship $ */
--
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
);
--
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
);
--
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
);
--
PROCEDURE delete_row(x_rowid in varchar2);
--
FUNCTION chk_swot_number(p_value in VARCHAR2) return varchar2;
--
function chk_output_file_name(
  p_output_file_name in varchar2)
return boolean;
--
END PAY_JP_SWOT_NUMBERS_PKG;

/
