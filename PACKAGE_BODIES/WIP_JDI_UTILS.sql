--------------------------------------------------------
--  DDL for Package Body WIP_JDI_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_JDI_UTILS" as
/* $Header: wipjdiub.pls 120.2 2005/12/13 11:41:23 yulin noship $ */

Procedure Begin_Processing_Request(p_group_id 		number,
				   p_parent_header_id	number,
                                   x_err_code		 out NOCOPY varchar2,
                                   x_err_msg		 out NOCOPY varchar2,
				   x_return_status	 out NOCOPY varchar2) IS


BEGIN

  -- Provide interface_id for every record
  -- Update process status to be RUNNING
  -- Do autonomous commit;

  begin

    IF (WIP_JOB_DETAILS.STD_ALONE = 1) THEN
      Update WIP_JOB_DTLS_INTERFACE
      SET interface_id = WIP_INTERFACE_S.NEXTVAL,
          process_status = WIP_CONSTANTS.RUNNING
      WHERE group_id = p_group_id
      AND   process_status =  WIP_CONSTANTS.PENDING
      AND   process_phase =  WIP_CONSTANTS.ML_VALIDATION;
    ELSE
      Update WIP_JOB_DTLS_INTERFACE
      SET interface_id = WIP_INTERFACE_S.NEXTVAL,
          process_status = WIP_CONSTANTS.RUNNING
      WHERE group_id = p_group_id
      AND   parent_header_id = p_parent_header_id
      AND   process_status =  WIP_CONSTANTS.PENDING
      AND   process_phase =  WIP_CONSTANTS.ML_VALIDATION;
    END IF;

  exception
    when no_data_found then
      x_err_code := SQLCODE;
      x_err_msg  := 'No pending request!';
      x_return_status := FND_API.G_RET_STS_ERROR;
  end;

END Begin_Processing_Request;


Procedure Error_If_Batch(p_group_id 	number,
                         p_new_process_status number,
			 p_where_clause varchar2,
			 p_error_type	number,
			 p_error_msg	varchar2) IS

  x_statement varchar2(2000) :=
 	' select interface_id
          from wip_job_dtls_interface WJDI' ||
	' where WJDI.group_id = :x_group_id'||
        ' and WJDI.process_phase = '|| WIP_CONSTANTS.ML_VALIDATION ||
        ' and WJDI.process_status in ('|| WIP_CONSTANTS.RUNNING||
                                ','||WIP_CONSTANTS.PENDING||
                                ','||WIP_CONSTANTS.WARNING ||') and '||
        replace(p_where_clause, '    ',' ');

  x_cursor_id integer;
  n_rows_fetched integer;
  x_jdi_interface_id number;
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
   dbms_sql.define_column(x_cursor_id, 1, x_jdi_interface_id);
   dbms_sql.bind_variable(x_cursor_id, ':x_group_id', p_group_id);
   n_rows_fetched := dbms_sql.execute(x_cursor_id) ;

   LOOP
     n_rows_fetched := dbms_sql.fetch_rows(x_cursor_id) ;

      if (n_rows_fetched = 0) then
         dbms_sql.close_cursor(x_cursor_id);
         exit;
      end if;

     dbms_sql.column_value(x_cursor_id, 1,x_jdi_interface_id);

    -- Fetch the requested error message.

     fnd_message.set_name('WIP', p_error_msg) ;
     fnd_message.set_token('INTERFACE', ' '||x_jdi_interface_id,FALSE);
     x_error_msg :=substr(fnd_message.get,1,500);

    -- If it stand alone, insert the interface_id of details
    -- else insert the interface_id of job header.

     if WIP_JOB_DETAILS.std_alone = 1 THEN

       WIP_INTERFACE_ERR_Utils.add_error(x_jdi_interface_id,
                                         x_error_msg,
 					 x_error_type);

     elsif WIP_JOB_DETAILS.std_alone = 0 then

       WIP_INTERFACE_ERR_Utils.add_error(WIP_JSI_Utils.current_interface_id,
                                         x_error_msg,
					 x_error_type);

     end if;

   END LOOP;

   -- Update process_status of the records.

   x_statement :=
              ' UPDATE  WIP_JOB_DTLS_INTERFACE WJDI'||
              ' SET PROCESS_STATUS = :x_New_Process_Status ' ||
              ' WHERE   GROUP_ID =   :x_Group_Id ' ||
              ' AND     PROCESS_PHASE = ' || WIP_CONSTANTS.ML_VALIDATION || '
                AND     PROCESS_STATUS IN ('|| WIP_CONSTANTS.RUNNING||
                                           ','||WIP_CONSTANTS.PENDING||
                                           ','||WIP_CONSTANTS.WARNING ||')'||
              ' AND  ' || replace(p_where_clause, '    ',' ');

   begin
     x_cursor_id := dbms_sql.open_cursor;
     dbms_sql.parse(x_cursor_id, x_statement, dbms_sql.native);
     dbms_sql.bind_variable(x_cursor_id, ':x_Group_Id', P_Group_Id);
     dbms_sql.bind_variable(x_cursor_id, ':x_New_Process_Status', P_New_Process_Status);
     n_rows_fetched := dbms_sql.execute(x_cursor_id);
     dbms_sql.close_cursor(x_cursor_id);
   end;

END Error_If_Batch;


Procedure End_Processing_Request(p_wip_entity_id 	number,
				 p_organization_id	number) IS

  x_count  number;

BEGIN

   IF WIP_JOB_DETAILS.std_alone = 1 THEN

      select count(*) into x_count
      from wip_job_dtls_interface
      where wip_entity_id = p_wip_entity_id
      and organization_id = p_organization_id
      and process_phase = WIP_CONSTANTS.ML_VALIDATION
      and process_status = WIP_CONSTANTS.ERROR ;

      if x_count > 0 then
         rollback;

         -- Update the process status in detail interface table.

         Change_Status_Error(null,null, p_wip_entity_id, p_organization_id);

         commit;
      else
         commit;
      end if;

   END IF;

   /* bug 4650624, move load_errors out of if so errors got recorded no matter what mode it is in */
      -- Load all errors from PL/SQL table into wip_interface_errors.

      WIP_INTERFACE_ERR_Utils.load_errors;


END End_Processing_Request;


Procedure Change_Status_Error(p_group_id number := null,
                              p_parent_header_id number := null,
                              p_wip_entity_id    number := null,
                              p_organization_id  number := null) IS

BEGIN
  begin
   IF WIP_JOB_DETAILS.std_alone = 1 THEN

      Update WIP_JOB_DTLS_INTERFACE
      SET process_status = WIP_CONSTANTS.ERROR
      WHERE wip_entity_id = p_wip_entity_id
      AND   organization_id = p_organization_id;

   ELSIF WIP_JOB_DETAILS.std_alone = 0 THEN

     Update WIP_JOB_DTLS_INTERFACE
     SET process_status = WIP_CONSTANTS.ERROR
     WHERE group_id = p_group_id
     AND   parent_header_id = p_parent_header_id;

   END IF;

  exception
    when no_data_found then
     null;
    WHEN others then
     raise;
  end;

END Change_Status_Error;


/****** Used in pending jobs and schedules form for resubmitting******/
Procedure Change_Status_Pending(p_row_id varchar2,p_group_id number) IS

  x_group_id number;
  x_header_id number;

BEGIN
  begin

     select group_id, header_id
     into x_group_id, x_header_id
     from wip_job_schedule_interface
     where rowid = p_row_id
     and   load_type in (WIP_CONSTANTS.CREATE_JOB,WIP_CONSTANTS.RESCHED_JOB,
                   WIP_CONSTANTS.CREATE_NS_JOB);

     Update WIP_JOB_DTLS_INTERFACE
     SET process_status = WIP_CONSTANTS.PENDING,
         group_id = p_group_id
     WHERE group_id = x_group_id
     AND   parent_header_id = x_header_id;

  exception
    WHEN no_data_found then
     null;
    WHEN others then
     raise;
  end;

END Change_Status_Pending;

end WIP_JDI_Utils;

/
