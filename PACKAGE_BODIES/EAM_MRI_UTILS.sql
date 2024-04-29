--------------------------------------------------------
--  DDL for Package Body EAM_MRI_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_MRI_UTILS" AS
/* $Header: EAMMRIUB.pls 115.3 2003/05/02 22:26:24 lllin ship $ */

  /**
   * This is almost a copy of WIP_JDI_Utils.Error_If_Batch. Just modified
   * the table name and such to make it usable for meter reading interface.
   */
  procedure error_if_batch(p_group_id  number,
                           p_new_process_status number,
                           p_where_clause varchar2,
                           p_error_type   number,
                           p_error_msg    varchar2) is
    x_statement varchar2(2000) :=
        ' select interface_id
          from eam_meter_readings_interface mri' ||
        ' where mri.group_id = :x_group_id'||
        ' and mri.process_phase = '|| WIP_CONSTANTS.ML_VALIDATION ||
        ' and mri.process_status in ('|| WIP_CONSTANTS.RUNNING||
                                ','||WIP_CONSTANTS.PENDING||
                                ','||WIP_CONSTANTS.WARNING ||') and '||
        replace(p_where_clause, '    ',' ');

    x_cursor_id integer;
    n_rows_fetched integer;
    x_interface_id number;
    x_error_type   number;
    x_error_msg    varchar2(500);

  begin
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

      x_error_type := p_error_type;

    end if;

    -- Execute dynamic sql.

    x_cursor_id := dbms_sql.open_cursor ;
    dbms_sql.parse(x_cursor_id, x_statement, dbms_sql.native) ;
    dbms_sql.define_column(x_cursor_id, 1, x_interface_id);
    dbms_sql.bind_variable(x_cursor_id, ':x_group_id', p_group_id);
    n_rows_fetched := dbms_sql.execute(x_cursor_id) ;

    LOOP
      n_rows_fetched := dbms_sql.fetch_rows(x_cursor_id) ;

      if (n_rows_fetched = 0) then
        dbms_sql.close_cursor(x_cursor_id);
        exit;
      end if;

      dbms_sql.column_value(x_cursor_id, 1, x_interface_id);

      -- Fetch the requested error message.

      fnd_message.set_name('EAM', p_error_msg) ;
      fnd_message.set_token('INTERFACE', ' '|| x_interface_id, FALSE);
      x_error_msg :=substr(fnd_message.get, 1, 500);

      eam_int_utils.add_error(x_interface_id,
                              x_error_msg,
                              x_error_type);
    END LOOP;

    -- Update process_status of the records.

/*
    x_statement :=
              ' UPDATE  eam_meter_readings_interface mri'||
              ' SET PROCESS_STATUS = ' ||P_New_Process_Status|| '
                WHERE   GROUP_ID = ' || P_Group_Id || '
                AND     PROCESS_PHASE = ' || WIP_CONSTANTS.ML_VALIDATION || '
                AND     PROCESS_STATUS IN ('|| WIP_CONSTANTS.RUNNING||
                                           ','||WIP_CONSTANTS.PENDING||
                                           ','||WIP_CONSTANTS.WARNING ||')'||
              ' AND  ' || replace(p_where_clause, '    ',' ');
*/

    x_statement :=
              ' UPDATE  eam_meter_readings_interface mri'||
              ' SET PROCESS_STATUS = :process_status
                WHERE   GROUP_ID = :group_id
                AND     PROCESS_PHASE = WIP_CONSTANTS.ML_VALIDATION
                AND     PROCESS_STATUS IN (WIP_CONSTANTS.RUNNING,
                                          WIP_CONSTANTS.PENDING,
                                          WIP_CONSTANTS.WARNING)
               AND ' ||  replace(p_where_clause, '    ',' ');


    begin
      x_cursor_id := dbms_sql.open_cursor;
      dbms_sql.parse(x_cursor_id, x_statement, dbms_sql.v7);
      dbms_sql.bind_variable(x_cursor_id, ':process_status', P_New_Process_Status);
      dbms_sql.bind_variable(x_cursor_id, ':group_id',  P_Group_Id);
      n_rows_fetched := dbms_sql.execute(x_cursor_id);
      dbms_sql.close_cursor(x_cursor_id);
    end;

  end error_if_batch;


  procedure error_if(p_current_rowid  in rowid,
                     p_interface_id in number,
                     p_condition in varchar2,
                     p_product_short_name in varchar2,
                     p_message_name in varchar2) is
  begin
    if ( eam_int_utils.request_matches_condition(
                  p_current_rowid,
                  p_interface_id,
                  'eam_meter_readings_interface mri',
                  p_condition) ) then
     FND_Message.set_name(p_product_short_name, p_message_name);
     eam_int_utils.record_error(p_interface_id, FND_Message.get, FALSE);
   end if;
  end error_if;


END eam_mri_utils;

/
