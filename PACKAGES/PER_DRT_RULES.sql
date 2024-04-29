--------------------------------------------------------
--  DDL for Package PER_DRT_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_DRT_RULES" AUTHID CURRENT_USER AS
/* $Header: pedrtrul.pkh 120.0.12010000.6 2019/07/01 12:39:18 hardeeps noship $ */
  function getlong (p_table_name varchar2, p_column_name varchar2, p_schema varchar2) return varchar2;
  function ranstr (start_of_range pls_integer, end_of_range pls_integer) return varchar2;
  function rannum(start_of_range pls_integer, end_of_range pls_integer) return number;
	function rannum(start_of_range number, end_of_range number) return varchar2;
  function rannum return number;
  function ranint return integer;
  function ranbyt (p_positive_num positive) return raw;
  function randat (p_date_val date) return date;
  FUNCTION name2mail
  (rid         IN varchar2
  ,table_name  IN varchar2
  ,column_name IN varchar2
  ,person_id   IN number) RETURN varchar2;
	FUNCTION get_cols_for_upd
	  (p_table_id     IN per_drt_tables.table_id%TYPE
	  ,p_column_phase IN per_drt_columns.column_phase%TYPE
	  ,p_context      IN per_drt_col_contexts.context_name%TYPE
	  ,p_ffn          IN per_drt_columns.ff_type%TYPE) RETURN clob;
  procedure validate_dml_or_query (dml_or_query clob, sql_type varchar2 default 'DML');
  function get_param (p1 varchar2 default null,p2 varchar2 default null) return varchar2;
  procedure getdml(p_table_id number, p_ffn varchar2 default NULL, p_context varchar2 default NULL, dml_stmt OUT NOCOPY clob);
  procedure getsql (p_table_name varchar2, p_person_id number, sql_stmt OUT NOCOPY varchar2);
  procedure recompile_proc (etype varchar2);
  procedure submit_request(errbuf out NOCOPY varchar2,
    retcode out NOCOPY number,
    p_entity_type varchar2);
  PROCEDURE drt_compile
    (entity_type IN  VARCHAR2
    ,request_id OUT NOCOPY number);
end PER_DRT_RULES;

/
