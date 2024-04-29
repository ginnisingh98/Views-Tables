--------------------------------------------------------
--  DDL for Package Body EAM_INT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_INT_UTILS" AS
/* $Header: EAMINTUB.pls 120.0 2005/05/25 15:42:55 appldev noship $ */

  procedure add_error(p_interface_id      number,
                      p_text              varchar2,
                      p_error_type        number)  IS

    error_record request_error;
    error_type   number;
  begin

    error_record.interface_id := p_interface_id;
    error_record.error_type := p_error_type;
    error_record.error := substr(p_text,1,500);

    current_errors(current_errors.count+1) := error_record;

  end add_error;


  procedure load_errors(p_source_interface_table in varchar2) is
    n_errors number;
    error_no number := 1;
    x_statement varchar2(2000);
    x_cursor_id integer;
    x_dummy integer;
  begin
    x_statement :=
     ' insert into wip_interface_errors ( ' ||
     ' interface_id, error_type, error, ' ||
     ' last_update_date, creation_date, created_by, ' ||
     ' last_update_login, last_updated_by ' ||
     ' ) ' ||
     ' select ' ||
     ' :interface_id_1, :error_type, :error, ' ||
     ' sysdate, sysdate, created_by, ' ||
     ' last_update_login, last_updated_by ' ||
--4247057 begin
     ' from :l_source_table where interface_id = :interface_id_2 ';
--4247057  End

    x_cursor_id := dbms_sql.open_cursor;

    n_errors := current_errors.count;

    dbms_sql.parse(x_cursor_id, x_statement, dbms_sql.native);
    WHILE (error_no <= n_errors) LOOP
      dbms_sql.bind_variable(x_cursor_id, ':interface_id_1',
                             current_errors(error_no).interface_id);
      dbms_sql.bind_variable(x_cursor_id, ':error_type',
                             current_errors(error_no).error_type);
      dbms_sql.bind_variable(x_cursor_id, ':error',
                             current_errors(error_no).error);
      dbms_sql.bind_variable(x_cursor_id, ':interface_id_2',
                             current_errors(error_no).interface_id);
--4247057  Begin
      dbms_sql.bind_variable(x_cursor_id, ':l_source_table', p_source_interface_table);
--4247057  End

      x_dummy := dbms_sql.execute(x_cursor_id);
      error_no := error_no + 1;

    END LOOP;
    dbms_sql.close_cursor(x_cursor_id);
    current_errors.delete;

  end load_errors;


  function has_errors return boolean is
    n_errors number;
    error_no number := 1;
    error_happened boolean := false;
  begin
    n_errors := current_errors.count;
    WHILE (error_no <= n_errors AND error_happened = false) LOOP
      if ( current_errors(error_no).error_type = 1 ) then
        error_happened := true;
      end if;
      error_no := error_no + 1;
    END LOOP;

    return error_happened;
  end has_errors;


  procedure abort_request is
  begin
    raise_application_error(
      -20240,
      'EAM Interface Request Processing Aborted');
  end abort_request;


  procedure warn_irrelevant_column(p_current_rowid in rowid,
                                   p_current_interface_id in number,
                                   p_table_name in varchar2,
                                   p_column in varchar2,
                                   p_condition in varchar2) is
    x_condition varchar2(2000);
  begin
    x_condition := p_column || ' is not null';
    if ( p_condition is not null ) then
      x_condition := x_condition || ' and ' || p_condition;
    end if;

    if (request_matches_condition(p_current_rowid,
                                  p_current_interface_id,
                                  p_table_name,
                                  x_condition)) then
      record_ignored_column_warning(p_current_interface_id,
                                    p_column);
    end if ;
  end warn_irrelevant_column;


  procedure warn_redundant_column(p_current_rowid  in rowid,
                                  p_current_interface_id in number,
                                  p_table_name in varchar2,
                                  p_column_being_used in varchar2,
                                  p_column_being_ignored in varchar2,
                                  p_condition in varchar2 default null) is
    x_condition varchar2(2000);
    x_interface_id number;
  begin
    x_condition :=
      p_column_being_used || ' is not null and ' ||
      p_column_being_ignored || ' is not null';
    if ( p_condition is not null ) then
      x_condition := x_condition || ' and ' || p_condition;
    end if;

    if ( request_matches_condition(p_current_rowid,
                                   p_current_interface_id,
                                   p_table_name,
                                   x_condition) ) then
      record_ignored_column_warning(p_current_interface_id, p_column_being_ignored);
    end if;

  end warn_redundant_column;


  procedure derive_id_from_code(p_current_rowid in rowid,
                                p_current_interface_id in number,
                                p_table_name in varchar2,
                                p_id_column in varchar2,
                                p_code_column in varchar2,
                                p_derived_value_expression in varchar2,
                                p_id_required in boolean default true) is
    x_condition varchar2(2000);
  begin
    -- if both the code and id filled in, we ignore the code column.
    warn_redundant_column(p_current_rowid,
                          p_current_interface_id,
                          p_table_name,
                          p_id_column,
                          p_code_column);

    x_condition := p_code_column || ' is not null';


    default_if_null(p_current_rowid,
                    p_current_interface_id,
                    p_table_name,
                    p_id_column,
                    x_condition,
                    p_derived_value_expression);

    -- In the end, we require that the ID column not be null
    -- if the code column was not null.
    if( p_id_required AND request_matches_condition (p_current_rowid,
                                  p_current_interface_id,
                                  p_table_name,
                                  p_code_column || ' is not null and ' ||
                                    p_id_column || ' is null')) then
      record_invalid_column_error(p_current_interface_id, p_code_column);
    end if ;

  end derive_id_from_code;

  procedure derive_code_from_id(p_current_rowid in rowid,
                                  p_current_interface_id in number,
                                  p_table_name in varchar2,
                                  p_id_column in varchar2,
                                  p_code_column in varchar2,
                                  p_derived_value_expression in varchar2,
                                  p_id_required in boolean default true) is
      x_condition varchar2(2000);
    begin
      /* not required
      -- if both the code and id filled in, we ignore the code column.
      warn_redundant_column(p_current_rowid,
                            p_current_interface_id,
                            p_table_name,
                            p_id_column,
                            p_code_column);
      */

      x_condition := p_id_column || ' is not null';


      default_if_null(p_current_rowid,
                      p_current_interface_id,
                      p_table_name,
                      p_code_column,
                      x_condition,
                      p_derived_value_expression);
      /* not required
      -- In the end, we require that the ID column not be null
      -- if the code column was not null.
      if( p_id_required AND request_matches_condition (p_current_rowid,
                                    p_current_interface_id,
                                    p_table_name,
                                    p_code_column || ' is not null and ' ||
                                      p_id_column || ' is null')) then
        record_invalid_column_error(p_current_interface_id, p_code_column);
      end if ;
      */

  end derive_code_from_id;

  procedure default_if_null(p_current_rowid in rowid,
                            p_interface_id in number,
                            p_table_name in varchar2,
                            p_column     in varchar2,
                            p_condition  in varchar2,
                            p_default_value_expression in varchar2) is
    x_cursor_id integer ;
    x_dummy integer ;
    x_statement varchar2(2000);
  begin
-- Bug 4247057 begin

x_statement := 'update :l_table set :l_column = :l_default where rowid = :x_row_id and :l_column is null and :l_condition' ;


-- Bug 4247057 end
    x_cursor_id := dbms_sql.open_cursor ;
    dbms_sql.parse(x_cursor_id, x_statement, dbms_sql.native) ;
 dbms_sql.bind_variable_rowid(x_cursor_id, ':x_row_id', p_current_rowid) ;
-- Bug 4247057 begin
dbms_sql.bind_variable(x_cursor_id, ':l_table', p_table_name);
dbms_sql.bind_variable(x_cursor_id, ':l_column', p_column);
dbms_sql.bind_variable(x_cursor_id, ':l_default', replace(p_default_value_expression, '    ', ' '));
dbms_sql.bind_variable(x_cursor_id, ':l_condition', replace(p_condition, '    ', ' '));
-- Bug 4247057 end

    x_dummy := dbms_sql.execute(x_cursor_id) ;
    dbms_sql.close_cursor(x_cursor_id) ;

  exception when others then
    record_error(p_interface_id,
                 'EAM_INT_UTILS: ORA-' || -sqlcode || ' : ' || x_statement,
                 FALSE);
    abort_request;
  end default_if_null;


  function request_matches_condition(p_current_rowid  in rowid,
                                     p_interface_id in number,
                                     p_table_name   in varchar2,
                                     p_where_clause in varchar2)
                                                    return boolean is
--4247057 begin
 x_statement varchar2(2000) := 'select 1 from :l_table where rowid = :x_row_id and :l_where';
--4247057 end

    x_cursor_id integer;
    n_rows_fetched integer;
  begin
    x_cursor_id := dbms_sql.open_cursor;
    dbms_sql.parse(x_cursor_id, x_statement, dbms_sql.native);
    dbms_sql.bind_variable_rowid(x_cursor_id, ':x_row_id', p_current_rowid);

--4247057 begin
    dbms_sql.bind_variable(x_cursor_id, ':l_table', p_table_name);
    dbms_sql.bind_variable(x_cursor_id, ':l_where', replace(p_where_clause, '    ', ' '));
--4247057 end

     n_rows_fetched := dbms_sql.execute_and_fetch(x_cursor_id);
    dbms_sql.close_cursor(x_cursor_id);

    return (n_rows_fetched > 0);

  exception when others then
    record_error(p_interface_id,
                 'EAM_INT_UTILS: ORA-' || -sqlcode || ' : ' || x_statement,
                 FALSE);
    abort_request;
    return false; -- not reached here
  end request_matches_condition;


  procedure record_ignored_column_warning(p_interface_id in number,
                                          p_column_name in varchar2) is
  begin
    FND_Message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
    FND_Message.set_token('COLUMN', p_column_name, false);
    record_error(p_interface_id,
                 FND_Message.get,
                 true);
  end record_ignored_column_warning;


  procedure record_invalid_column_error(p_interface_id in number,
                                        p_column_name in varchar2) is
  begin
    FND_Message.set_name('WIP', 'WIP_ML_FIELD_INVALID');
    FND_Message.set_token('COLUMN', p_column_name, false);
    record_error(p_interface_id,
                 FND_Message.get,
                 FALSE);
  end record_invalid_column_error;


  procedure record_error(p_interface_id in number,
                         p_text in varchar2,
                         p_warning_only in boolean) is
    error_type number;
  begin
    error_type := 1;
    if ( p_warning_only ) then
      error_type := 2;
    end if;

    add_error(p_interface_id, p_text, error_type);
  end record_error;


END eam_int_utils;

/
