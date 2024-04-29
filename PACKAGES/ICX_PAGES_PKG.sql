--------------------------------------------------------
--  DDL for Package ICX_PAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_PAGES_PKG" AUTHID CURRENT_USER as
/* $Header: ICXPAGHS.pls 115.2 1999/11/23 18:44:48 pkm ship      $ */

procedure INSERT_ROW (
  x_rowid in out varchar2,
  x_page_id in number,
  x_page_code in varchar2,
  x_main_region_id in number,
  x_sequence_number in number,
  x_page_type in varchar2,
  x_user_id in number,
  x_refresh_rate in number,
  x_page_name in varchar2,
  x_page_description in varchar2,
  x_creation_date in date,
  x_created_by in number,
  x_last_update_date in date,
  x_last_updated_by in number,
  x_last_update_login in number);

procedure UPDATE_ROW (
  x_page_id in number,
  x_page_code in varchar2,
  x_main_region_id in number,
  x_sequence_number in number,
  x_page_type in varchar2,
  x_user_id in number,
  x_refresh_rate in number,
  x_page_name in varchar2,
  x_page_description in varchar2,
  x_last_update_date in date,
  x_last_updated_by in number,
  x_last_update_login in number
);

procedure ADD_LANGUAGE;

procedure TRANSLATE_ROW (
  x_page_id			in varchar2,
  x_page_name		in varchar2,
  x_page_description	in varchar2
);

procedure LOAD_ROW (
  X_PAGE_ID		in	number,
  X_PAGE_CODE		in 	VARCHAR2,
  x_main_region_id	in number,
  x_sequence_number	in number,
  x_page_type		in varchar2,
  x_user_id		in number,
  x_refresh_rate	in number,
  x_page_name		in varchar2,
  x_page_description	in varchar2
);

end ICX_PAGES_PKG;

 

/
