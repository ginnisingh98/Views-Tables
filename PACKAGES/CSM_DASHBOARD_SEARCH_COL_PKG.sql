--------------------------------------------------------
--  DDL for Package CSM_DASHBOARD_SEARCH_COL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_DASHBOARD_SEARCH_COL_PKG" AUTHID CURRENT_USER as
/* $Header: csmldscs.pls 120.2 2005/12/05 23:16:07 utekumal noship $ */

--
--    Table handler for CSM_CUSTOMIZATION_VIEWS table.
--
-- HISTORY
--   JUL 10, 2005  yazhang created.
--   Dec 6 , 2005  SARADHAK updated as table definition is modified.

procedure insert_row (
  x_column_name in varchar2,
  x_NAME      in VARCHAR2,
  x_lov_vo_name in varchar2,
  x_INPUT_TYPE in varchar2,
  x_display    in varchar2 );


procedure update_row (
  x_column_name in varchar2,
  x_NAME      in VARCHAR2,
  x_lov_vo_name in varchar2,
  x_INPUT_TYPE in varchar2,
  x_display    in varchar2);

procedure load_row (
  x_column_name in varchar2,
  x_NAME      in VARCHAR2,
  x_lov_vo_name in varchar2,
  x_INPUT_TYPE in varchar2,
  x_display    in varchar2,
  x_owner in VARCHAR2);

END csm_dashboard_search_col_pkg;

 

/
