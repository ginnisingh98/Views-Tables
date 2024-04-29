--------------------------------------------------------
--  DDL for Package HZ_PARAM_TAB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PARAM_TAB_PKG" AUTHID CURRENT_USER as
/*$Header: ARHPRMTS.pls 120.1 2005/06/16 21:14:44 jhuang noship $ */

/*********************
** Insert Statements**
**********************/
 procedure insert_row (
  x_item_key      in varchar2,
  x_param_name    in varchar2,
  x_param_value   in varchar2,
  x_param_indicator    in varchar2
 ) ;

 procedure insert_row (
  x_item_key      in varchar2,
  x_param_name    in varchar2,
  x_param_value   in number,
  x_param_indicator    in varchar2
 ) ;

 procedure insert_row (
  x_item_key      in varchar2,
  x_param_name    in varchar2,
  x_param_value   in date,
  x_param_indicator    in varchar2
 ) ;

 procedure delete_row (
  x_item_key      in varchar2
 ) ;
end;

 

/
