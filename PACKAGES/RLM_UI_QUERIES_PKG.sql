--------------------------------------------------------
--  DDL for Package RLM_UI_QUERIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RLM_UI_QUERIES_PKG" AUTHID CURRENT_USER as
/* $Header: RLMQRYS.pls 115.4 2002/11/09 02:01:21 rlanka ship $ */

TYPE query_rec is RECORD(
        column_name   VARCHAR2(240),
        column_type  VARCHAR2(200),
        column_value  VARCHAR2(2000));

TYPE query_tab_type IS TABLE of query_rec
     INDEX BY BINARY_INTEGER;

procedure  INSERT_ROW (x_query_id in out NOCOPY  number,
		      x_rowid out NOCOPY rowid,
		      query_tab  IN query_tab_type);

procedure  SELECT_ROW (x_query_id in out NOCOPY  number,
		      query_tab  OUT NOCOPY query_tab_type);

procedure  UPDATE_ROW (x_query_id in out NOCOPY  number,
		      query_tab  IN query_tab_type);

procedure  DELETE_ROW (x_query_id in out NOCOPY  number);

end RLM_UI_QUERIES_PKG ;


 

/
