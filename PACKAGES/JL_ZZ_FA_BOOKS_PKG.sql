--------------------------------------------------------
--  DDL for Package JL_ZZ_FA_BOOKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_ZZ_FA_BOOKS_PKG" AUTHID CURRENT_USER AS
/* $Header: jlzzffbs.pls 115.2 99/07/16 03:13:30 porting ship  $ */

  v_asset_id                 NUMBER(15);
  v_book_type_code           varchar2(150);
  v_transaction_header_id_in NUMBER(15);
  v_dist_book                varchar2(150);
  v_counter                  binary_integer := 0;
  v_global_attribute1        varchar2(150);
  v_global_attribute2        varchar2(150);
  v_global_attribute3        varchar2(150);
  v_global_attribute4        varchar2(150);
  v_global_attribute5        varchar2(150);
  v_global_attribute6        varchar2(150);
  v_global_attribute7        varchar2(150);
  v_global_attribute8        varchar2(150);
  v_global_attribute9        varchar2(150);
  v_global_attribute10       varchar2(150);
  v_global_attribute11       varchar2(150);
  v_global_attribute12       varchar2(150);
  v_global_attribute13       varchar2(150);
  v_global_attribute14       varchar2(150);
  v_global_attribute15       varchar2(150);
  v_global_attribute16       varchar2(150);
  v_global_attribute17       varchar2(150);
  v_global_attribute18       varchar2(150);
  v_global_attribute19       varchar2(150);
  v_global_attribute20       varchar2(150);
  v_global_attribute_category varchar2(150);

PROCEDURE get_dist_book;

FUNCTION update_insert RETURN BOOLEAN;

FUNCTION insert_update RETURN BOOLEAN;

PROCEDURE update_row;

PROCEDURE get_flag_category;

PROCEDURE get_ga_dist_book;

END jl_zz_fa_books_pkg;

 

/
