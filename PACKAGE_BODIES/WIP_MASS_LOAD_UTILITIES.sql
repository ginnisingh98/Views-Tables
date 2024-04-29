--------------------------------------------------------
--  DDL for Package Body WIP_MASS_LOAD_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_MASS_LOAD_UTILITIES" AS
/* $Header: wipmlutb.pls 115.10 2002/12/12 15:02:21 rmahidha ship $ */


procedure set_current_message(message varchar2) is
begin
  WIP_MASS_LOAD_UTILITIES.CURRENT_MESSAGE := message ;
end set_current_message ;


function get_current_message return varchar2 is
begin
  return WIP_MASS_LOAD_UTILITIES.CURRENT_MESSAGE ;
end get_current_message ;


procedure record_bad_query(x_statement in varchar2) is
  remaining varchar2(2000) ;
  leaving varchar2(500) ; -- must match length of WIP_INTERFACE_ERRORS.ERROR
begin
  leaving := '' ;
  remaining := x_statement ;

  while (length(remaining) <> 0) loop

     if(length(remaining) <= 500) then
       leaving := remaining ;
       remaining := '' ;
     else
       leaving := substr(remaining,1,500) ;
       remaining := substr(remaining,501) ;
     end if ;

     insert into wip_interface_errors (
       interface_id, error_type, creation_date, error
     ) values (
       -1, 1, sysdate, leaving
     ) ;
  end loop ;

end record_bad_query ;

FUNCTION Dynamic_Sql(x_statement IN VARCHAR2,
		     P_Group_Id IN NUMBER) RETURN NUMBER IS
x_cursor_id NUMBER;
x_num_rows NUMBER;
x_run_def1 NUMBER:=WIP_CONSTANTS.RUNNING;
x_run_def2 NUMBER:=WIP_CONSTANTS.WARNING;
x_process_phase NUMBER:=WIP_CONSTANTS.ML_VALIDATION;
BEGIN
      begin
	x_cursor_id := dbms_sql.open_cursor;
	dbms_sql.parse(x_cursor_id, x_statement, dbms_sql.native);
        dbms_sql.bind_variable(x_cursor_id, 'x_group_id_bind',
                                        to_char(p_group_id));
        dbms_sql.bind_variable(x_cursor_id, 'x_run_def1_bind',x_run_def1);
        dbms_sql.bind_variable(x_cursor_id, 'x_run_def2_bind',x_run_def2);
        dbms_sql.bind_variable(x_cursor_id, 'x_process_phase_bind',
                                                to_char(x_process_phase));
	x_num_rows := dbms_sql.execute(x_cursor_id);
	dbms_sql.close_cursor(x_cursor_id);
      exception
        when others then
          record_bad_query(x_statement) ;
          commit ;
          raise ;
      end ;

    --  COMMIT;
      return(x_num_rows);

END Dynamic_Sql;

PROCEDURE Error(P_Group_Id IN NUMBER,
		P_Table IN VARCHAR2,
		P_New_Process_Status IN NUMBER,
		P_Where_Clause IN VARCHAR2,
		P_Error_Type IN NUMBER,
		P_Error_Msg IN VARCHAR2) IS
x_statement VARCHAR2(2000);
x_error_type NUMBER;
x_num_rows NUMBER;
x_where_clause VARCHAR2(2000) := replace(P_Where_Clause, '    ', ' ');

BEGIN

  if (p_error_type = MSG_COLUMN) then

    -- Fetch the invalid-column message.

    fnd_message.set_name('WIP', 'WIP_ML_FIELD_INVALID');
    fnd_message.set_token('COLUMN', p_error_msg, false);
    x_error_type := MSG_ERROR;

  elsif (p_error_type = MSG_CONC) then

    -- Use the message that is already on the stack;
    -- there is no need to fetch it.

    x_error_type := MSG_ERROR;

  else

    -- Fetch the requested error message.

    fnd_message.set_name('WIP', p_error_msg) ;
    x_error_type := p_error_type;

  end if;

  -- Grab the message at the top of the Fnd_Message stack, truncating it
  -- to 500 characters (the width of WIP_INTERFACE_ERRORS.ERROR) if necessary.
  -- Store its text so that we can retrieve it with get_current_message().
  wip_mass_load_utilities.set_current_message(substr(fnd_message.get,1,500)) ;

  /* Insert records into the Errors table if appropriate */

  x_statement := '
      INSERT INTO WIP_INTERFACE_ERRORS (
        INTERFACE_ID, ERROR_TYPE, ERROR,
        LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY,
        LAST_UPDATE_LOGIN
      )
      SELECT
        INTERFACE_ID,
        ' || to_char(x_error_type) || ',
        wip_mass_load_utilities.get_current_message,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN
      FROM ' || P_TABLE ||
    ' WHERE GROUP_ID = :x_group_id_bind
      AND PROCESS_PHASE = :x_process_phase_bind
      AND (PROCESS_STATUS = :x_run_def1_bind
      OR   PROCESS_STATUS = :x_run_def2_bind)
      AND ' || X_Where_Clause ;

  x_num_rows := Dynamic_Sql(x_statement,P_group_id);

  /* Change the PROCESS_STATUS of the records in the interface table,
     This is unnecessary if the previous statement did not insert
     any rows.  It is also unnecessary if the error was just a warning */

  IF (P_Error_Type <> MSG_WARNING AND x_num_rows > 0) THEN
    x_statement :=
	      ' UPDATE 	' || P_TABLE ||
	      '	SET PROCESS_STATUS = ' || to_char(P_New_Process_Status) ||
              ' WHERE	GROUP_ID = :x_group_id_bind
                AND     PROCESS_PHASE = :x_process_phase_bind
                AND     (PROCESS_STATUS =:x_run_def1_bind
                OR       PROCESS_STATUS =:x_run_def2_bind)
		AND	' || X_Where_Clause;

    x_num_rows := Dynamic_Sql(x_statement,P_group_id);
  END IF;

END Error;


END WIP_MASS_LOAD_UTILITIES;

/
