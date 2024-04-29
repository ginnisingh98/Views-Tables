--------------------------------------------------------
--  DDL for Package Body WIP_WICTPG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WICTPG" as
/* $Header: wiptpgb.pls 120.14.12010000.2 2009/06/09 22:59:43 pding ship $ */

  -- procedure to insert a line into the report
  procedure append_report(
        p_rec           in purge_report_type,
        p_option        in number) is
  begin
   if ( p_option IN (REPORT_ONLY, PURGE_AND_REPORT) ) then
    insert into Wip_temp_reports(
      key1,              /* Group ID */
      program_source,
      last_updated_by,
      organization_id,
      wip_entity_id,
      inventory_item_id,
      key2,              /* line ID */
      key3,              /* Repetitive schedule ID */
      description,       /* Table Name */
      key6,              /* Info Type */
      attribute1        /* Info */,
      date1,            /* Start Date */
      date2,            /* Completion Date */
      date3,            /* Close Date */
      attribute2,       /*Job Name*/
      attribute3        /*Line Code*/
    ) values (
      p_rec.group_id,
      'WICTPG',          /* program_source  */
      -1,                /* Last Updated By */
      p_rec.org_id,
      p_rec.wip_entity_id,
      p_rec.primary_item_id,
      p_rec.line_id,
      p_rec.schedule_id,
      p_rec.table_name,
      p_rec.info_type,
      p_rec.info,
      p_rec.start_date,
      p_rec.complete_date,
      p_rec.close_date,
      p_rec.entity_name,
      p_rec.line_code
    );
  end if ;

  end append_report;


  -- Procedure to delete the records entered in the WIP_PURGE_TEMP table
  procedure delete_purge_temp_table(
    p_group_id           in number ) is

  begin

        delete from Wip_Purge_Temp where group_id = p_group_id ;
        commit ;

  end delete_purge_temp_table ;


  procedure construct_report_content(p_option    in number,
                                     p_num_rows  in number,
                                     p_purge_rec in out nocopy purge_report_type) is

  begin
    if ( p_num_rows > 0 ) then
      fnd_message.set_name('WIP', 'WIP_PURGE_ROWS');
      fnd_message.set_token('NUMBER', to_char(p_num_rows));
      p_purge_rec.info := fnd_message.get;
      append_report(p_purge_rec, p_option);
    end if;
  end construct_report_content;


 /*
  -- procedure to delete from a table and get a count of records
  procedure delete_from_table(
    p_option           in number,
    p_purge_rec        in purge_report_type,
    p_delete_statement in varchar2) is

    x_cursor_id number;
    x_num_rows  number := 0;
    x_message   varchar2(255);
    x_purge_rec purge_report_type;
  begin
    -- issue savepoint to restore deletes later
    savepoint wictpg_sp;

    -- delete from table using dynamic SQL
    x_cursor_id := dbms_sql.open_cursor;
    dbms_sql.parse(x_cursor_id, p_delete_statement, dbms_sql.v7);
    x_num_rows := dbms_sql.execute(x_cursor_id);
    dbms_sql.close_cursor(x_cursor_id);

    if (p_option = REPORT_ONLY) then
      -- rollback deletes
      rollback to wictpg_sp;
    end if;

    if (x_num_rows > 0) then
      fnd_message.set_name('WIP', 'WIP_PURGE_ROWS');
      fnd_message.set_token('NUMBER', to_char(x_num_rows));
      x_message := fnd_message.get;
      x_purge_rec := p_purge_rec;
      x_purge_rec.info := x_message;
      append_report(x_purge_rec,p_option);
    end if;

  end delete_from_table;
 */

 /* Bug# 1280455
        ** New procedure created to do the same work as done by
        ** delete_from_table except the dynamic sql execution.
        */
  procedure before_append_report(
    p_option           in number,
    p_purge_rec        in purge_report_type,
    num_rows               in number) is
    x_purge_rec purge_report_type;
  begin

      fnd_message.set_name('WIP', 'WIP_PURGE_ROWS');
      fnd_message.set_token('NUMBER', to_char(num_rows));
      x_purge_rec := p_purge_rec;
      x_purge_rec.info := fnd_message.get;
      append_report(x_purge_rec,p_option);

  end before_append_report;


  -- procedure to delete the details of a job
  procedure delete_job_details(
    p_option        in number,
    p_group_id      in number,
    p_purge_request in get_purge_requests%rowtype) is

    x_num_rows  number := 0;
    x_purge_rec purge_report_type;
    l_op_count  number := 0;   /*Bug 6056455: (FP of 5224338) Added variable l_op_count to store operation count*/
  begin

    x_purge_rec.group_id        := p_group_id;
    x_purge_rec.org_id          := p_purge_request.organization_id;
    x_purge_rec.wip_entity_id   := p_purge_request.wip_entity_id;
    x_purge_rec.schedule_id     := NULL;
    x_purge_rec.primary_item_id := p_purge_request.primary_item_id;
    x_purge_rec.line_id         := NULL;
    x_purge_rec.start_date      := p_purge_request.start_date;
    x_purge_rec.complete_date   := p_purge_request.complete_date;
    x_purge_rec.close_date      := p_purge_request.close_date;
    x_purge_rec.info_type       := ROWS_AFFECTED;
    x_purge_rec.entity_name     := p_purge_request.wip_entity_name;
    x_purge_rec.line_code       := p_purge_request.line_code;

    x_purge_rec.table_name := 'WIP_OPERATIONS';
     if (p_option = REPORT_ONLY) then
                select count(*) into x_num_rows from WIP_OPERATIONS where
                        WIP_ENTITY_ID= x_purge_rec.wip_entity_id;
    else
        DELETE FROM WIP_OPERATIONS
         WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id;
                x_num_rows := SQL%ROWCOUNT;
    end if;

        if x_num_rows > 0 then
                before_append_report(
       p_option           => p_option,
      p_purge_rec        => x_purge_rec,
      num_rows                   => x_num_rows);
        end if;
    x_purge_rec.table_name := 'WIP_REQUIREMENT_OPERATIONS';
    if (p_option = REPORT_ONLY) then
        select count(*) into x_num_rows from WIP_REQUIREMENT_OPERATIONS where
            WIP_ENTITY_ID= x_purge_rec.wip_entity_id;
    else
        DELETE FROM WIP_REQUIREMENT_OPERATIONS
         WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id;
        x_num_rows := SQL%ROWCOUNT;
    end if;

    l_op_count := x_num_rows;   /*Bug 6056455: (FP of 5224338) Store operation count in variable l_op_count*/

    if x_num_rows > 0 then
        before_append_report(
      p_option           => p_option,
      p_purge_rec        => x_purge_rec,
      num_rows           => x_num_rows);
    end if;

    x_purge_rec.table_name := 'WIP_OPERATION_RESOURCES';
    if (p_option = REPORT_ONLY) then
        select count(*) into x_num_rows from WIP_OPERATION_RESOURCES where
            WIP_ENTITY_ID= x_purge_rec.wip_entity_id;
    else
        DELETE FROM WIP_OPERATION_RESOURCES
         WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id;
        x_num_rows := SQL%ROWCOUNT;
    end if;

    if x_num_rows > 0 then
        before_append_report(
      p_option           => p_option,
      p_purge_rec        => x_purge_rec,
      num_rows           => x_num_rows);
    end if;

    /*fix for bug no 4774572*/
    x_purge_rec.table_name := 'WIP_OP_RESOURCE_INSTANCES';
    if (p_option = REPORT_ONLY) then
        select count(*) into x_num_rows from WIP_OP_RESOURCE_INSTANCES where
            WIP_ENTITY_ID= x_purge_rec.wip_entity_id
            AND ORGANIZATION_ID = x_purge_rec.org_id;
    else
        DELETE FROM WIP_OP_RESOURCE_INSTANCES
         WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id
         AND ORGANIZATION_ID = x_purge_rec.org_id;
        x_num_rows := SQL%ROWCOUNT;
    end if;

    if x_num_rows > 0 then
        before_append_report(
      p_option           => p_option,
      p_purge_rec        => x_purge_rec,
      num_rows           => x_num_rows);
    end if;
    /* end fix for bug#4774572*/

    x_purge_rec.table_name := 'WIP_SHOP_FLOOR_STATUSES';
    if (p_option = REPORT_ONLY) then
        select count(*) into x_num_rows from WIP_SHOP_FLOOR_STATUSES where
            WIP_ENTITY_ID= x_purge_rec.wip_entity_id;
    else
        DELETE FROM WIP_SHOP_FLOOR_STATUSES
         WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id;
        x_num_rows := SQL%ROWCOUNT;
    end if;

    if x_num_rows > 0 then
        before_append_report(
      p_option           => p_option,
      p_purge_rec        => x_purge_rec,
      num_rows           => x_num_rows);
    end if;

  /* Fix for bug 2146528*/
  x_purge_rec.table_name := 'WIP_OPERATION_OVERHEADS';
  if (p_option = REPORT_ONLY) then
      select count(*) into x_num_rows from WIP_OPERATION_OVERHEADS
      where  WIP_ENTITY_ID=to_char(x_purge_rec.wip_entity_id);
  else
      DELETE FROM WIP_OPERATION_OVERHEADS
      WHERE WIP_ENTITY_ID = to_char(x_purge_rec.wip_entity_id);
        x_num_rows := SQL%ROWCOUNT;
  end if;

   if x_num_rows > 0 then
        before_append_report(
      p_option           => p_option,
      p_purge_rec        => x_purge_rec,
      num_rows           => x_num_rows);
   end if;

  x_purge_rec.table_name := 'WIP_REQ_OPERATION_COST_DETAILS';

   if (p_option = REPORT_ONLY) then
      select count(*) into x_num_rows from WIP_REQ_OPERATION_COST_DETAILS
      where  WIP_ENTITY_ID=to_char(x_purge_rec.wip_entity_id);
    else
      DELETE FROM  WIP_REQ_OPERATION_COST_DETAILS
      WHERE WIP_ENTITY_ID = to_char(x_purge_rec.wip_entity_id);
        x_num_rows := SQL%ROWCOUNT;
  end if;

   if x_num_rows > 0 then
        before_append_report(
      p_option           => p_option,
      p_purge_rec        => x_purge_rec,
      num_rows           => x_num_rows);
   end if;

   if ( p_option IN (REPORT_ONLY, PURGE_AND_REPORT) ) then
      -- This procedure is used for counting only, later it will be deleted
      x_purge_rec.table_name := 'FND_ATTACHED_DOCUMENTS';

/* Removed commented code */
/* Bug 2943615 - modified wip_entity_id, org_id on the R.H.S to char
                 to avoid ORA-1722 error */
        select count(*)
        into   x_num_rows
        from   FND_ATTACHED_DOCUMENTS
        WHERE PK1_VALUE = to_char(x_purge_rec.wip_entity_id)
        AND ((   PK2_VALUE = to_char(x_purge_rec.org_id)
                 AND   ENTITY_NAME = 'WIP_DISCRETE_JOBS'
             )
          OR (   PK3_VALUE = to_char(x_purge_rec.org_id)
                AND ENTITY_NAME = 'WIP_DISCRETE_OPERATIONS'
             )
            );

        if x_num_rows > 0 then
           before_append_report(
             p_option           => p_option,
             p_purge_rec        => x_purge_rec,
             num_rows           => x_num_rows);
        end if;
    end if;

    -- If the action type option is to purge then call the API supplied by dlane
    if (p_Option <> REPORT_ONLY) then

        /* Bug 6056455: (FP of 5224338) Added following if condition before calling FND API to delete attachments*/
        if ( l_op_count > 0) then
        FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments(
                X_entity_name => 'WIP_DISCRETE_OPERATIONS',
                X_pk1_value => to_char(x_purge_rec.wip_entity_id),
                X_pk3_value => to_char(x_purge_rec.org_id),
                X_delete_document_flag => 'Y' );
        end if;

        FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments(
                X_entity_name => 'WIP_DISCRETE_JOBS',
                X_pk1_value => to_char(x_purge_rec.wip_entity_id),
                X_pk2_value => to_char(x_purge_rec.org_id),
                X_delete_document_flag => 'Y' );
    end if ;

  end delete_job_details;

  -- procedure to delete the details of a schedule
  procedure delete_sched_details(
    p_option        in number,
    p_group_id      in number,
    p_purge_request in get_purge_requests%rowtype) is

    x_purge_rec purge_report_type;
    x_num_rows  number := 0;
  begin

    x_purge_rec.group_id        := p_group_id;
    x_purge_rec.org_id          := p_purge_request.organization_id;
    x_purge_rec.wip_entity_id   := p_purge_request.wip_entity_id;
    x_purge_rec.schedule_id     := p_purge_request.repetitive_schedule_id;
    x_purge_rec.primary_item_id := p_purge_request.primary_item_id;
    x_purge_rec.line_id         := p_purge_request.line_id;
    x_purge_rec.start_date      := p_purge_request.start_date;
    x_purge_rec.complete_date   := p_purge_request.complete_date;
    x_purge_rec.close_date      := p_purge_request.close_date;
    x_purge_rec.info_type       := ROWS_AFFECTED;
    x_purge_rec.entity_name     := p_purge_request.wip_entity_name;
    x_purge_rec.line_code       := p_purge_request.line_code;

 x_purge_rec.table_name := 'WIP_OPERATIONS';
     if (p_option = REPORT_ONLY) then
        select count(*) into x_num_rows from WIP_OPERATIONS
         WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id
         AND REPETITIVE_SCHEDULE_ID = x_purge_rec.schedule_id
         AND ORGANIZATION_ID = x_purge_rec.org_id;
    else
        DELETE FROM WIP_OPERATIONS
         WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id
         AND REPETITIVE_SCHEDULE_ID = x_purge_rec.schedule_id
         AND ORGANIZATION_ID = x_purge_rec.org_id;
        x_num_rows := SQL%ROWCOUNT;
    end if;

    if x_num_rows > 0 then
        before_append_report(
      p_option           => p_option,
      p_purge_rec        => x_purge_rec,
      num_rows           => x_num_rows);
    end if;


    x_purge_rec.table_name := 'WIP_REQUIREMENT_OPERATIONS';
    if (p_option = REPORT_ONLY) then
        select count(*) into x_num_rows from WIP_REQUIREMENT_OPERATIONS
         WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id
         AND REPETITIVE_SCHEDULE_ID = x_purge_rec.schedule_id;
    else
        DELETE FROM WIP_REQUIREMENT_OPERATIONS
         WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id
         AND REPETITIVE_SCHEDULE_ID = x_purge_rec.schedule_id;
        x_num_rows := SQL%ROWCOUNT;
    end if;

    if x_num_rows > 0 then
        before_append_report(
      p_option           => p_option,
      p_purge_rec        => x_purge_rec,
      num_rows           => x_num_rows);
    end if;

    x_purge_rec.table_name := 'WIP_OPERATION_RESOURCES';
    if (p_option = REPORT_ONLY) then
        select count(*) into x_num_rows from WIP_OPERATION_RESOURCES
         WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id
         AND REPETITIVE_SCHEDULE_ID = x_purge_rec.schedule_id;
    else
        DELETE FROM WIP_OPERATION_RESOURCES
         WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id
         AND REPETITIVE_SCHEDULE_ID = x_purge_rec.schedule_id;
        x_num_rows := SQL%ROWCOUNT;
    end if;

    if x_num_rows > 0 then
        before_append_report(
      p_option           => p_option,
      p_purge_rec        => x_purge_rec,
      num_rows           => x_num_rows);
    end if;

    /*fix for bug no 4774572*/
    x_purge_rec.table_name := 'WIP_OP_RESOURCE_INSTANCES';
    if (p_option = REPORT_ONLY) then
        select count(*) into x_num_rows from WIP_OP_RESOURCE_INSTANCES
         WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id
         AND ORGANIZATION_ID = x_purge_rec.org_id;
    else
        DELETE FROM WIP_OP_RESOURCE_INSTANCES
         WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id
         AND ORGANIZATION_ID = x_purge_rec.org_id;
        x_num_rows := SQL%ROWCOUNT;
    end if;

    if x_num_rows > 0 then
        before_append_report(
      p_option           => p_option,
      p_purge_rec        => x_purge_rec,
      num_rows           => x_num_rows);
    end if;
    /* end fix for bug#4774572*/



   if ( p_option IN (REPORT_ONLY, PURGE_AND_REPORT) ) then
     -- This procedure is used for counting only, later it will be deleted
     x_purge_rec.table_name := 'FND_ATTACHED_DOCUMENTS';

/* Removed commented code */
/* Bug 2943615 - modified wip_entity_id, org_id, schedule_id on the R.H.S to char
                 to avoid ORA-1722 error */
      select count(*)
      into   x_num_rows
      from   FND_ATTACHED_DOCUMENTS
      WHERE  PK1_VALUE = to_char(x_purge_rec.wip_entity_id)
      AND    PK3_VALUE = to_char(x_purge_rec.org_id)
      AND   (    ( PK2_VALUE = to_char(x_purge_rec.schedule_id)
                   AND ENTITY_NAME = 'WIP_REPETITIVE_SCHEDULES'
                 )
              OR ( PK4_VALUE = to_char(x_purge_rec.schedule_id)
                   AND ENTITY_NAME = 'WIP_REPETITIVE_OPERATIONS'
                 )
            ) ;

    if x_num_rows > 0 then
        before_append_report(
      p_option           => p_option,
      p_purge_rec        => x_purge_rec,
      num_rows           => x_num_rows);
    end if;


    end if;


    -- If the action type option is to purge then call the API supplied by dlane
    if (p_Option <> REPORT_ONLY) then
        FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments(
                X_entity_name => 'WIP_REPETITIVE_OPERATIONS',
                X_pk1_value => to_char(x_purge_rec.wip_entity_id),
                X_pk3_value => to_char(x_purge_rec.org_id),
                X_pk4_value => to_char(x_purge_rec.schedule_id),
                X_delete_document_flag => 'Y' );

        FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments(
                X_entity_name => 'WIP_REPETITIVE_SCHEDULES',
                X_pk1_value => to_char(x_purge_rec.wip_entity_id),
                X_pk2_value => to_char(x_purge_rec.schedule_id),
                X_pk3_value => to_char(x_purge_rec.org_id),
                X_delete_document_flag => 'Y' );
    end if ;

  end delete_sched_details;

  -- procedure to delete job move transactions
  procedure delete_job_move_trx(
    p_option        in number,
    p_group_id      in number,
    p_purge_request in get_purge_requests%rowtype) is

    x_purge_rec purge_report_type;
    x_num_rows  number := 0;
  begin

    x_purge_rec.group_id        := p_group_id;
    x_purge_rec.org_id          := p_purge_request.organization_id;
    x_purge_rec.wip_entity_id   := p_purge_request.wip_entity_id;
    x_purge_rec.schedule_id     := NULL;
    x_purge_rec.primary_item_id := p_purge_request.primary_item_id;
    x_purge_rec.line_id         := NULL;
    x_purge_rec.start_date      := p_purge_request.start_date;
    x_purge_rec.complete_date   := p_purge_request.complete_date;
    x_purge_rec.close_date      := p_purge_request.close_date;
    x_purge_rec.info_type       := ROWS_AFFECTED;
    x_purge_rec.entity_name     := p_purge_request.wip_entity_name;
    x_purge_rec.line_code       := p_purge_request.line_code;

    x_purge_rec.table_name := 'WIP_SERIAL_MOVE_TRANSACTIONS';
    if ( p_option = REPORT_ONLY ) then
      select count(*) into x_num_rows
        from wip_serial_move_transactions wsmt
       where wsmt.transaction_id in (select wmt.transaction_id
                                       from wip_move_transactions wmt
                                      where wmt.wip_entity_id = x_purge_rec.wip_entity_id);
    else
      delete from wip_serial_move_transactions
      where transaction_id in (select wmt.transaction_id
                                 from wip_move_transactions wmt
                                where wmt.wip_entity_id = x_purge_rec.wip_entity_id);
      x_num_rows := SQL%ROWCOUNT;
    end if;
    if x_num_rows > 0 then
        before_append_report(
      p_option           => p_option,
      p_purge_rec        => x_purge_rec,
      num_rows           => x_num_rows);
    end if;

    x_num_rows := 0;
    x_purge_rec.table_name := 'WIP_MOVE_TRANSACTIONS';

    if (p_option = REPORT_ONLY) then
        select count(*) into x_num_rows from WIP_MOVE_TRANSACTIONS
         WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id;
    else
        DELETE FROM WIP_MOVE_TRANSACTIONS
         WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id;
        x_num_rows := SQL%ROWCOUNT;
    end if;

    if x_num_rows > 0 then
        before_append_report(
      p_option           => p_option,
      p_purge_rec        => x_purge_rec,
      num_rows           => x_num_rows);
    end if;

  end delete_job_move_trx;



 /*
  -- procedure to check if open scheules exists for a transaction
  procedure verify_open_schedules(
    p_option     in number,
    p_purge_rec  in purge_report_type,
    p_sql        in varchar2,
    p_rec_exists in out nocopy boolean) is

    x_cursor_id number;
    x_count     number := 0;
    x_purge_rec purge_report_type;
    x_ret number := 0 ;
  begin


    x_cursor_id := dbms_sql.open_cursor;
    dbms_sql.parse(x_cursor_id, p_sql, dbms_sql.v7);
    dbms_sql.define_column(x_cursor_id, 1, x_count);
    x_ret := dbms_sql.execute(x_cursor_id);
    x_ret := dbms_sql.fetch_rows(x_cursor_id);
    dbms_sql.column_value(x_cursor_id, 1, x_count);
    dbms_sql.close_cursor(x_cursor_id);

    if (x_count > 0) then
      p_rec_exists := TRUE ;
      append_report(p_purge_rec,p_option);
    end if;


  end verify_Open_Schedules;
 */





  -- procedure to delete schedule move transactions
  -- this still needs work
  procedure delete_sched_move_trx(
    p_option        in number,
    p_group_id      in number,
    p_purge_request in get_purge_requests%rowtype,
    p_cutoff_date   in date,
    p_sched_move_txn_flag in out nocopy boolean) is

    x_purge_rec purge_report_type;
    x_records_found  boolean := FALSE ;
    l_num_rows number := 0;
  begin

    x_purge_rec.group_id        := p_group_id;
    x_purge_rec.org_id          := p_purge_request.organization_id;
    x_purge_rec.wip_entity_id   := p_purge_request.wip_entity_id;
    x_purge_rec.schedule_id     := p_purge_request.repetitive_schedule_id;
    x_purge_rec.primary_item_id := p_purge_request.primary_item_id;
    x_purge_rec.line_id         := p_purge_request.line_id;
    x_purge_rec.start_date      := p_purge_request.start_date;
    x_purge_rec.complete_date   := p_purge_request.complete_date;
    x_purge_rec.close_date      := p_purge_request.close_date;
    x_purge_rec.info_type       := EXCEPTIONS;
    x_purge_rec.entity_name     := p_purge_request.wip_entity_name;
    x_purge_rec.line_code       := p_purge_request.line_code;


    -- verify that no other schedules exists
    fnd_message.set_name('WIP', 'WIP_TRANSACTIONS_PURGE_ERROR');
    x_purge_rec.info := fnd_message.get;
    x_purge_rec.table_name := 'WIP_MOVE_TXN_ALLOCATIONS';
    SELECT COUNT(*) into l_num_rows
      FROM DUAL WHERE EXISTS (
                   SELECT out_wmta.transaction_id
                     FROM wip_move_txn_allocations out_wmta
                    WHERE out_wmta.organization_id = p_purge_request.organization_id
                      AND out_wmta.repetitive_schedule_id = p_purge_request.repetitive_schedule_id
                      AND transaction_id IN (
                              SELECT transaction_id
                                FROM wip_repetitive_schedules wrs,
                                     wip_move_txn_allocations wmta
                               WHERE wmta.transaction_id = out_wmta.transaction_id
                                 AND wmta.repetitive_schedule_id <> out_wmta.repetitive_schedule_id
                                 AND nvl(wrs.date_closed, p_cutoff_date+1) > p_cutoff_date
                                 AND wrs.repetitive_schedule_id = wmta.repetitive_schedule_id
                                 AND wmta.organization_id = p_purge_request.organization_id
                                 AND wrs.organization_id = p_purge_request.organization_id));
    if ( l_num_rows > 0 ) then
      x_records_found := true;
      append_report(x_purge_rec, p_option);
    end if;
    l_num_rows := 0;

    -- If records whre found then it means that there records still sitting
    -- in the WIP_MOVE_TRANSACTIONS table.

    if x_records_found then
            p_sched_move_txn_flag := TRUE ;
            x_purge_rec.table_name := 'WIP_MOVE_TRANSACTIONS';
            append_report(x_purge_rec,p_option);
    end if ;


    x_purge_rec.info_type       := ROWS_AFFECTED;
    x_purge_rec.table_name := 'WIP_MOVE_TRANSACTIONS';

    savepoint wictpg_sp01;
    DELETE FROM WIP_MOVE_TRANSACTIONS
     WHERE TRANSACTION_ID IN (
              SELECT out_wmta.transaction_id
                FROM wip_move_txn_allocations out_wmta
               WHERE out_wmta.organization_id = p_purge_request.organization_id
                 AND out_wmta.repetitive_schedule_id = p_purge_request.repetitive_schedule_id
                 AND out_wmta.transaction_id IN (
                           SELECT transaction_id
                             FROM wip_repetitive_schedules wrs,
                                  wip_move_txn_allocations wmta
                            WHERE wmta.transaction_id = out_wmta.transaction_id
                              AND wmta.repetitive_schedule_id <> out_wmta.repetitive_schedule_id
                              AND nvl(wrs.date_closed, p_cutoff_date+1) <= p_cutoff_date
                              AND wrs.repetitive_schedule_id = wmta.repetitive_schedule_id
                              AND wmta.organization_id =  p_purge_request.organization_id
                              AND wrs.organization_id = p_purge_request.organization_id));
    l_num_rows := sql%rowcount;
    if ( p_option = REPORT_ONLY) then
      -- rollback deletes
      rollback to wictpg_sp01;
    end if;
    construct_report_content(p_option => p_option,
                             p_num_rows => l_num_rows,
                             p_purge_rec => x_purge_rec);
    l_num_rows := 0;


    x_purge_rec.table_name := 'WIP_MOVE_TXN_ALLOCATIONS';

    savepoint wictpg_sp02;
    DELETE FROM WIP_MOVE_TXN_ALLOCATIONS
     WHERE TRANSACTION_ID IN (
               SELECT out_wmta.transaction_id
                 FROM wip_move_txn_allocations out_wmta
                WHERE out_wmta.organization_id = p_purge_request.organization_id
                  AND out_wmta.repetitive_schedule_id = p_purge_request.repetitive_schedule_id
                  AND out_wmta.transaction_id IN (
                          SELECT transaction_id
                            FROM wip_repetitive_schedules wrs,
                                 wip_move_txn_allocations wmta
                           WHERE wmta.transaction_id = out_wmta.transaction_id
                             AND wmta.repetitive_schedule_id <> out_wmta.repetitive_schedule_id
                             AND nvl(wrs.date_closed, p_cutoff_date+1) <= p_cutoff_date
                             AND wrs.repetitive_schedule_id = wmta.repetitive_schedule_id
                             AND wmta.organization_id = p_purge_request.organization_id
                             AND wrs.organization_id = p_purge_request.organization_id));
    l_num_rows := sql%rowcount;
    if ( p_option = REPORT_ONLY) then
      -- rollback deletes
      rollback to wictpg_sp02;
    end if;
    construct_report_content(p_option => p_option,
                             p_num_rows => l_num_rows,
                             p_purge_rec => x_purge_rec);
    l_num_rows := 0;

  end delete_sched_move_trx;



  -- procedure to delete job resource transactions
  procedure delete_job_cost_trx(
    p_option        in number,
    p_group_id      in number,
    p_purge_request in get_purge_requests%rowtype,
    p_cut_off_date  in date) is   /*bug 4082908*/
    x_purge_rec purge_report_type;
    x_num_rows  number := 0;
    x_num_rows_non_lot  number := 0;
    x_num_rows_lot  number := 0;
  begin

    x_purge_rec.group_id        := p_group_id;
    x_purge_rec.org_id          := p_purge_request.organization_id;
    x_purge_rec.wip_entity_id   := p_purge_request.wip_entity_id;
    x_purge_rec.schedule_id     := NULL;
    x_purge_rec.primary_item_id := p_purge_request.primary_item_id;
    x_purge_rec.line_id         := NULL;
    x_purge_rec.start_date      := p_purge_request.start_date;
    x_purge_rec.complete_date   := p_purge_request.complete_date;
    x_purge_rec.close_date      := p_purge_request.close_date;
    x_purge_rec.info_type       := ROWS_AFFECTED;
    x_purge_rec.entity_name     := p_purge_request.wip_entity_name;
    x_purge_rec.line_code       := p_purge_request.line_code;


x_purge_rec.table_name := 'WIP_TRANSACTION_ACCOUNTS';
/* Bug 4082908 -> Changed following deletion statement to consider
lot-merge transactions, so that they are purged as a unit */
if (p_option = REPORT_ONLY) then
        SELECT count(*) into x_num_rows_non_lot
        FROM WIP_TRANSACTION_ACCOUNTS WTA
        WHERE WTA.TRANSACTION_ID IN
        ( SELECT WT.TRANSACTION_ID
          FROM WIP_TRANSACTIONS WT
          WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id
          AND WT.TRANSACTION_TYPE NOT IN (11,12));
        SELECT count(*) into x_num_rows_lot
        FROM WIP_TRANSACTION_ACCOUNTS WTA
        WHERE WTA.TRANSACTION_ID IN
        ( SELECT WT.TRANSACTION_ID
          FROM WIP_TRANSACTIONS WT
          WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id
          AND WT.TRANSACTION_TYPE IN (11,12)
          AND NOT EXISTS (SELECT 1 FROM
                          WIP_TRANSACTION_ACCOUNTS WTA1, WIP_DISCRETE_JOBS WDJ
                          WHERE WTA1.WIP_ENTITY_ID=WDJ.WIP_ENTITY_ID
                          AND WTA1.TRANSACTION_ID=WT.TRANSACTION_ID
                          AND NVL(WDJ.DATE_CLOSED,SYSDATE) >= p_cut_off_date)
                          UNION
                          SELECT WT.TRANSACTION_ID
                          FROM WIP_TRANSACTION_ACCOUNTS WT
                          WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id
                          AND NOT EXISTS
                          ( SELECT 1 FROM
                            WIP_TRANSACTION_ACCOUNTS WTA1, WIP_DISCRETE_JOBS WDJ
                            WHERE WTA1.WIP_ENTITY_ID=WDJ.WIP_ENTITY_ID
                            AND WTA1.TRANSACTION_ID=WT.TRANSACTION_ID
                            AND NVL(WDJ.DATE_CLOSED,SYSDATE) > p_cut_off_date)
                          );
    else
        DELETE FROM WIP_TRANSACTION_ACCOUNTS WTA
        WHERE WTA.TRANSACTION_ID IN
        ( SELECT WT.TRANSACTION_ID
          FROM WIP_TRANSACTIONS WT
          WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id
          AND WT.TRANSACTION_TYPE NOT IN (11,12));

        x_num_rows_non_lot := nvl(SQL%ROWCOUNT,0);

        DELETE FROM WIP_TRANSACTION_ACCOUNTS WTA
        WHERE WTA.TRANSACTION_ID IN
        ( SELECT WT.TRANSACTION_ID
          FROM WIP_TRANSACTIONS WT
          WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id
          AND WT.TRANSACTION_TYPE IN (11,12)
          AND NOT EXISTS (SELECT 1 FROM
                          WIP_TRANSACTION_ACCOUNTS WTA1, WIP_DISCRETE_JOBS WDJ
                          WHERE WTA1.WIP_ENTITY_ID=WDJ.WIP_ENTITY_ID
                          AND WTA1.TRANSACTION_ID=WT.TRANSACTION_ID
                          AND NVL(WDJ.DATE_CLOSED,SYSDATE) >= p_cut_off_date)
                          UNION
                          SELECT WT.TRANSACTION_ID
                          FROM WIP_TRANSACTION_ACCOUNTS WT
                          WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id
                          AND NOT EXISTS
                          ( SELECT 1 FROM
                            WIP_TRANSACTION_ACCOUNTS WTA1, WIP_DISCRETE_JOBS WDJ
                            WHERE WTA1.WIP_ENTITY_ID=WDJ.WIP_ENTITY_ID
                            AND WTA1.TRANSACTION_ID=WT.TRANSACTION_ID
                            AND NVL(WDJ.DATE_CLOSED,SYSDATE) > p_cut_off_date)
                          );

        x_num_rows_lot := nvl(SQL%ROWCOUNT,0);
    end if;

    if (x_num_rows_non_lot + x_num_rows_lot) > 0 then
        before_append_report(
      p_option           => p_option,
      p_purge_rec        => x_purge_rec,
      num_rows           => x_num_rows_non_lot + x_num_rows_lot);
    end if;

    x_purge_rec.table_name := 'WIP_TRANSACTIONS';
    if (p_option = REPORT_ONLY) then
        select count(*) into x_num_rows from WIP_TRANSACTIONS
                WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id;
    else
        DELETE FROM WIP_TRANSACTIONS
                WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id;
        x_num_rows := SQL%ROWCOUNT;
    end if;

    if x_num_rows > 0 then
        before_append_report(
      p_option           => p_option,
      p_purge_rec        => x_purge_rec,
      num_rows           => x_num_rows);
    end if;

end delete_job_cost_trx;



  -- procedure to delete schedule resource transactions
  -- This need work also
  procedure delete_sched_cost_trx(
    p_option        in number,
    p_group_id      in number,
    p_purge_request in get_purge_requests%rowtype,
    p_cutoff_date   in date,
    p_sched_txn_flag in out nocopy boolean ) is
    x_purge_rec purge_report_type;
    x_records_found boolean := FALSE ;
    l_num_rows number :=0;
  begin

    x_purge_rec.group_id        := p_group_id;
    x_purge_rec.org_id          := p_purge_request.organization_id;
    x_purge_rec.wip_entity_id   := p_purge_request.wip_entity_id;
    x_purge_rec.schedule_id     := p_purge_request.repetitive_schedule_id;
    x_purge_rec.primary_item_id := p_purge_request.primary_item_id;
    x_purge_rec.line_id         := p_purge_request.line_id;
    x_purge_rec.start_date      := p_purge_request.start_date;
    x_purge_rec.complete_date   := p_purge_request.complete_date;
    x_purge_rec.close_date      := p_purge_request.close_date;
    x_purge_rec.info_type       := EXCEPTIONS;
    x_purge_rec.entity_name     := p_purge_request.wip_entity_name;
    x_purge_rec.line_code       := p_purge_request.line_code;


    -- verify that no other schedules exists
    fnd_message.set_name('WIP', 'WIP_TRANSACTIONS_PURGE_ERROR');
    x_purge_rec.info := fnd_message.get;
    x_purge_rec.table_name := 'WIP_TXN_ALLOCATIONS';

    SELECT COUNT(*) into l_num_rows
    FROM DUAL WHERE EXISTS (
                SELECT out_wta.transaction_id
                  FROM wip_txn_allocations out_wta
                 WHERE out_wta.organization_id = p_purge_request.organization_id
                   AND out_wta.repetitive_schedule_id = p_purge_request.repetitive_schedule_id
                   AND out_wta.transaction_id IN (
                           SELECT transaction_id
                             FROM wip_repetitive_schedules wrs,
                                  wip_txn_allocations wta
                            WHERE wta.transaction_id = out_wta.transaction_id
                              AND wta.repetitive_schedule_id <> out_wta.repetitive_schedule_id
                              AND nvl(wrs.date_closed, p_cutoff_date+1) > p_cutoff_date
                              AND wrs.repetitive_schedule_id = wta.repetitive_schedule_id
                              AND wta.organization_id = p_purge_request.organization_id
                              AND wrs.organization_id = p_purge_request.organization_id));
    if ( l_num_rows > 0 ) then
      x_records_found := true;
      append_report(x_purge_rec, p_option);
    end if;
    l_num_rows := 0;

    -- If records whre found then it means that there records still sitting
    -- in the WIP_TRANSACTIONS table.
    if x_records_found then
            p_sched_txn_flag := TRUE ;
            x_purge_rec.table_name := 'WIP_TRANSACTIONS';
            append_report(x_purge_rec, p_option);
            x_purge_rec.table_name := 'WIP_TRANSACTION_ACCOUNTS';
            append_report(x_purge_rec, p_option);
    end if ;


    x_purge_rec.info_type       := ROWS_AFFECTED;
    x_purge_rec.table_name := 'WIP_TRANSACTIONS';

    savepoint sched_cost01;
    DELETE FROM WIP_TRANSACTIONS
     WHERE TRANSACTION_ID IN (
              SELECT out_wta.transaction_id
                FROM wip_txn_allocations out_wta
               WHERE out_wta.organization_id =  p_purge_request.organization_id
                 AND out_wta.repetitive_schedule_id = p_purge_request.repetitive_schedule_id
                 AND NOT EXISTS (
                         SELECT transaction_id
                           FROM wip_repetitive_schedules wrs,
                                wip_txn_allocations wta
                          WHERE wta.transaction_id = out_wta.transaction_id
                            AND wta.repetitive_schedule_id <> out_wta.repetitive_schedule_id
                            AND nvl(wrs.date_closed, p_cutoff_date+1) > p_cutoff_date /*Fixed for bug 7375928 (FP of 7120544)*/
                            AND wrs.repetitive_schedule_id = wta.repetitive_schedule_id
                            AND wta.organization_id = p_purge_request.organization_id
                            AND  wrs.organization_id = p_purge_request.organization_id));
    l_num_rows := sql%rowcount;
    if ( p_option = REPORT_ONLY) then
      -- rollback deletes
      rollback to sched_cost01;
    end if;
    construct_report_content(p_option => p_option,
                             p_num_rows => l_num_rows,
                             p_purge_rec => x_purge_rec);
    l_num_rows := 0;


    x_purge_rec.table_name := 'WIP_TRANSACTION_ACCOUNTS';

    savepoint sched_cost02;
    DELETE FROM WIP_TRANSACTION_ACCOUNTS
     WHERE TRANSACTION_ID IN (
               SELECT out_wta.transaction_id
                 FROM wip_txn_allocations out_wta
                WHERE out_wta.organization_id = p_purge_request.organization_id
                  AND out_wta.repetitive_schedule_id = p_purge_request.repetitive_schedule_id
                  AND NOT EXISTS (
                          SELECT transaction_id
                            FROM wip_repetitive_schedules wrs,
                                 wip_txn_allocations wta
                           WHERE wta.transaction_id = out_wta.transaction_id
                             AND wta.repetitive_schedule_id <> out_wta.repetitive_schedule_id
                             AND nvl(wrs.date_closed, p_cutoff_date+1) > p_cutoff_date /*Fixed for bug 7375928 (FP of 7120544)*/
                             AND wrs.repetitive_schedule_id = wta.repetitive_schedule_id
                             AND wta.organization_id = p_purge_request.organization_id
                             AND wrs.organization_id = p_purge_request.organization_id));
    l_num_rows := sql%rowcount;
    if ( p_option = REPORT_ONLY) then
      -- rollback deletes
      rollback to sched_cost02;
    end if;
    construct_report_content(p_option => p_option,
                             p_num_rows => l_num_rows,
                             p_purge_rec => x_purge_rec);
    l_num_rows := 0;


    x_purge_rec.table_name := 'WIP_TXN_ALLOCATIONS';

    savepoint sched_cost03;
    DELETE FROM WIP_TXN_ALLOCATIONS
     WHERE TRANSACTION_ID IN (
               SELECT out_wta.transaction_id
                 FROM wip_txn_allocations out_wta
                WHERE out_wta.organization_id = p_purge_request.organization_id
                  AND out_wta.repetitive_schedule_id = p_purge_request.repetitive_schedule_id
                  AND NOT EXISTS (
                          SELECT transaction_id
                            FROM wip_repetitive_schedules wrs,
                                 wip_txn_allocations wta
                           WHERE wta.transaction_id = out_wta.transaction_id
                             AND wta.repetitive_schedule_id <> out_wta.repetitive_schedule_id
                             AND nvl(wrs.date_closed, p_cutoff_date+1) > p_cutoff_date /*Fixed for bug 7375928 (FP of 7120544)*/
                             AND wrs.repetitive_schedule_id = wta.repetitive_schedule_id
                             AND wta.organization_id = p_purge_request.organization_id
                             AND wrs.organization_id = p_purge_request.organization_id));

    l_num_rows := sql%rowcount;
    if ( p_option = REPORT_ONLY) then
      -- rollback deletes
      rollback to sched_cost03;
    end if;
    construct_report_content(p_option => p_option,
                             p_num_rows => l_num_rows,
                             p_purge_rec => x_purge_rec);
    l_num_rows := 0;

end delete_sched_cost_trx;



 /*
  -- procedure to check if record exists
  procedure verify_foreign_key(
    p_option     in number,
    p_purge_rec  in purge_report_type,
    p_sql        in varchar2,
    p_rec_exists in out nocopy boolean) is

    x_cursor_id number;
    x_count     number := 0;
    x_purge_rec purge_report_type;
    x_ret number := 0 ;
  begin


    x_cursor_id := dbms_sql.open_cursor;
    dbms_sql.parse(x_cursor_id, p_sql, dbms_sql.v7);
    dbms_sql.define_column(x_cursor_id, 1, x_count);
    x_ret := dbms_sql.execute(x_cursor_id);
    x_ret := dbms_sql.fetch_rows(x_cursor_id);
    dbms_sql.column_value(x_cursor_id, 1, x_count);
    dbms_sql.close_cursor(x_cursor_id);

    -- set count of rows
    p_rec_exists := p_rec_exists OR (x_count > 0);

    if (x_count > 0) then
      append_report(p_purge_rec, p_option);
    end if;

  end verify_foreign_key;
 */

  -- procedure to delete the job header record
  procedure delete_job_header(
    p_option        in number,
    p_group_id      in number,
    p_purge_request in get_purge_requests%rowtype) is

    x_purge_rec       purge_report_type;
    x_records_found   boolean := FALSE;
    x_records_returned  number := 0;
    x_Temp_Where_Clause Varchar2(150);
    x_num_rows  number := 0;
  begin



    -- initialize
    -- G_Continue_Purging := TRUE ;
    x_purge_rec.group_id        := p_group_id;
    x_purge_rec.org_id          := p_purge_request.organization_id;
    x_purge_rec.wip_entity_id   := p_purge_request.wip_entity_id;
    x_purge_rec.schedule_id     := NULL;
    x_purge_rec.primary_item_id := p_purge_request.primary_item_id;
    x_purge_rec.line_id         := NULL;
    x_purge_rec.start_date      := p_purge_request.start_date;
    x_purge_rec.complete_date   := p_purge_request.complete_date;
    x_purge_rec.close_date      := p_purge_request.close_date;
    x_purge_rec.info_type       := EXCEPTIONS;
    x_purge_rec.entity_name     := p_purge_request.wip_entity_name;
    x_purge_rec.line_code       := p_purge_request.line_code;


    -- verify no period balance activity
    fnd_message.set_name('WIP', 'WIP_PERIOD_BALANCES_EXIST');
    x_purge_rec.info := fnd_message.get;
    x_purge_rec.table_name := 'WIP_PERIOD_BALANCES';

    /* Fixing bug 935919. The following sql is introduced to replace the earlier one because
       the checking should be done to see whether the sum of (IN - OUT NOCOPY - VAR) of each cost
       component is zero over all accounting periods in WIP_PERIOD_BALANCES, not each of the
       individula cost columns in WIP_PERIOD_BALANCES is zero as it was in the earlier sql.
    */

      select count(*)
      into   x_records_returned
      from   dual
      where (0,0,0,0,0,0,0,0,0,0) <>
     (select   sum(NVL(TL_RESOURCE_IN, 0) - NVL(TL_RESOURCE_OUT, 0) - NVL(TL_RESOURCE_VAR,0)),
               sum(NVL(TL_OVERHEAD_IN, 0) - NVL(TL_OVERHEAD_OUT, 0) - NVL(TL_OVERHEAD_VAR,0)),
               sum(NVL(TL_OUTSIDE_PROCESSING_IN,0) - NVL(TL_OUTSIDE_PROCESSING_OUT, 0) - NVL(TL_OUTSIDE_PROCESSING_VAR,0)),
               sum(0 - NVL(TL_MATERIAL_OUT, 0) -  NVL(TL_MATERIAL_VAR,0)),
               sum(0 - NVL(TL_MATERIAL_OVERHEAD_OUT, 0) - NVL(TL_MATERIAL_OVERHEAD_VAR,0)),
               sum(NVL(PL_MATERIAL_IN, 0) - NVL(PL_MATERIAL_OUT, 0) - NVL(PL_MATERIAL_VAR,0)),
               sum(NVL(PL_MATERIAL_OVERHEAD_IN, 0) - NVL(PL_MATERIAL_OVERHEAD_OUT, 0) - NVL(PL_MATERIAL_OVERHEAD_VAR,0)),
               sum(NVL(PL_RESOURCE_IN, 0) - NVL(PL_RESOURCE_OUT, 0) - NVL(PL_RESOURCE_VAR,0)),
               sum(NVL(PL_OVERHEAD_IN, 0) - NVL(PL_OVERHEAD_OUT, 0) - NVL(PL_OVERHEAD_VAR,0)),
               sum(NVL(PL_OUTSIDE_PROCESSING_IN, 0) - NVL(PL_OUTSIDE_PROCESSING_OUT, 0) - NVL(PL_OUTSIDE_PROCESSING_VAR,0))
     from    WIP_PERIOD_BALANCES
     where WIP_ENTITY_ID = x_purge_rec.wip_entity_id);

     x_records_found := x_records_found OR (x_records_returned > 0);

    if (x_records_returned > 0) then
      append_report(x_purge_rec, p_option);
    end if;


    -- check for foreign key references
    fnd_message.set_name('WIP', 'WIP_PURGE_FOREIGN_KEY');
    fnd_message.set_token('TABLE', 'WIP_DISCRETE_JOBS', TRUE);
    x_purge_rec.info := fnd_message.get;

    x_purge_rec.table_name := 'CST_STD_COST_ADJ_VALUES';

       SELECT COUNT(*)
       into x_records_returned
       FROM DUAL
       WHERE EXISTS
       (SELECT 1
        FROM   CST_STD_COST_ADJ_VALUES
        WHERE  WIP_ENTITY_ID = x_purge_rec.wip_entity_id);

     x_records_found := x_records_found OR (x_records_returned > 0);

    if (x_records_returned > 0) then
      append_report(x_purge_rec, p_option);
    end if;


    x_purge_rec.table_name := 'PO_DISTRIBUTIONS_ALL';


       SELECT COUNT(*)
       into x_records_returned
       FROM DUAL
       WHERE EXISTS
       (SELECT 1
        FROM   PO_DISTRIBUTIONS_ALL
        WHERE  WIP_ENTITY_ID = x_purge_rec.wip_entity_id
               /* Fixed bug 3115844 */
          AND  po_line_id IS NOT NULL
          AND  line_location_id IS NOT NULL);

     x_records_found := x_records_found OR (x_records_returned > 0);

    if (x_records_returned > 0) then
      append_report(x_purge_rec, p_option);
    end if;


    x_purge_rec.table_name := 'PO_DISTRIBUTIONS_ARCHIVE_ALL';

       SELECT COUNT(*)
       into x_records_returned
       FROM DUAL
       WHERE EXISTS
        (SELECT 1
         FROM  PO_DISTRIBUTIONS_ARCHIVE_ALL
         WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id);

     x_records_found := x_records_found OR (x_records_returned > 0);

    if (x_records_returned > 0) then
      append_report(x_purge_rec, p_option);
    end if;



    x_purge_rec.table_name := 'PO_REQUISITION_LINES_ALL';

       SELECT COUNT(*)
       into x_records_returned
       FROM DUAL
       WHERE EXISTS
         (SELECT 1
          FROM   PO_REQUISITION_LINES_ALL
          WHERE  WIP_ENTITY_ID = x_purge_rec.wip_entity_id );

     x_records_found := x_records_found OR (x_records_returned > 0);

    if (x_records_returned > 0) then
      append_report(x_purge_rec, p_option);
    end if;



    x_purge_rec.table_name := 'RCV_TRANSACTIONS';

       SELECT COUNT(*)
       into x_records_returned
       FROM DUAL
       WHERE EXISTS
        (SELECT 1
         FROM  RCV_TRANSACTIONS
         WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id );

     x_records_found := x_records_found OR (x_records_returned > 0);

    if (x_records_returned > 0) then
      append_report(x_purge_rec, p_option);
    end if;


    -- This is included inorder to use the existing index on inventory_item_id in
    -- the MTL tables

    /* Fix for bug#4902938 - Comment this piece of code since it is NOT used anywhere.*/
    /*
    if (x_purge_rec.primary_item_id IS NULL) then
        x_Temp_Where_Clause :=  ' AND INVENTORY_ITEM_ID IS NULL ' ;
    else
        x_Temp_Where_Clause :=  '  AND INVENTORY_ITEM_ID = ' || to_char(x_purge_rec.primary_item_id) ;
    end if ;
    */
    /* END - Fix for bug#4902938 */

    x_purge_rec.table_name := 'MTL_DEMAND';

    if (x_purge_rec.primary_item_id IS NULL) then

      -- Bug 4880984
      -- Removed this SQL as check is redundand. This is because
      -- inventory_item_id is mandatory column in MTL_DEMAND table.
      -- Assigning value of Zero to x_records_returned instead.
      /*
        SELECT COUNT(*)
        into x_records_returned
        FROM DUAL
        WHERE EXISTS
             (SELECT 1
              FROM  MTL_DEMAND
              WHERE SUPPLY_SOURCE_TYPE = 5
              AND INVENTORY_ITEM_ID IS NULL
              AND SUPPLY_SOURCE_HEADER_ID = x_purge_rec.wip_entity_id
              AND ORGANIZATION_ID = x_purge_rec.org_id);
      */

        x_records_returned := 0;

    else

        SELECT COUNT(*)
        into x_records_returned
        FROM DUAL
        WHERE EXISTS
              (SELECT 1
               FROM  MTL_DEMAND
               WHERE SUPPLY_SOURCE_TYPE = 5
               AND INVENTORY_ITEM_ID = x_purge_rec.primary_item_id
               AND SUPPLY_SOURCE_HEADER_ID = x_purge_rec.wip_entity_id
               AND ORGANIZATION_ID = x_purge_rec.org_id);

    end if ;

    x_records_found := x_records_found OR (x_records_returned > 0);

    if (x_records_returned > 0) then
       append_report(x_purge_rec, p_option);
    end if;



    x_purge_rec.table_name := 'MTL_USER_SUPPLY';


    if (x_purge_rec.primary_item_id IS NULL) then

        SELECT COUNT(*)
        into x_records_returned
        FROM DUAL
        WHERE EXISTS
              (SELECT 1
               FROM   MTL_USER_SUPPLY
               WHERE SOURCE_TYPE_ID = 4
               AND SOURCE_ID = x_purge_rec.wip_entity_id
               AND INVENTORY_ITEM_ID IS NULL );

    else

        SELECT COUNT(*)
        into x_records_returned
        FROM DUAL
        WHERE EXISTS
              (SELECT 1
               FROM   MTL_USER_SUPPLY
               WHERE SOURCE_TYPE_ID = 4
               AND SOURCE_ID = x_purge_rec.wip_entity_id
               AND INVENTORY_ITEM_ID = x_purge_rec.primary_item_id );
    end if;

    x_records_found := x_records_found OR (x_records_returned > 0);

    if (x_records_returned > 0) then
       append_report(x_purge_rec, p_option);
    end if;


    x_purge_rec.table_name := 'MTL_USER_DEMAND';


    if (x_purge_rec.primary_item_id IS NULL) then

        SELECT COUNT(*)
        into x_records_returned
        FROM DUAL
        WHERE EXISTS
              (SELECT 1
               FROM   MTL_USER_DEMAND
               WHERE SOURCE_TYPE_ID = 4
               AND SOURCE_ID = x_purge_rec.wip_entity_id
               AND INVENTORY_ITEM_ID IS NULL );
    else
        SELECT COUNT(*)
        into x_records_returned
        FROM DUAL
        WHERE EXISTS
              (SELECT 1
               FROM   MTL_USER_DEMAND
               WHERE SOURCE_TYPE_ID = 4
               AND SOURCE_ID = x_purge_rec.wip_entity_id
               AND INVENTORY_ITEM_ID = x_purge_rec.primary_item_id );

    end if;

    x_records_found := x_records_found OR (x_records_returned > 0);

    if (x_records_returned > 0) then
       append_report(x_purge_rec, p_option);
    end if;


    x_purge_rec.table_name := 'MTL_SERIAL_NUMBERS';

    if (x_purge_rec.primary_item_id IS NULL) then

        SELECT COUNT(*)
        into x_records_returned
        FROM DUAL
        WHERE EXISTS
                (SELECT 1
                 FROM   MTL_SERIAL_NUMBERS
                 WHERE ORIGINAL_WIP_ENTITY_ID = x_purge_rec.wip_entity_id
                 AND INVENTORY_ITEM_ID IS NULL );
    else

        SELECT COUNT(*)
        into x_records_returned
        FROM DUAL
        WHERE EXISTS
                (SELECT 1
                 FROM   MTL_SERIAL_NUMBERS
                 WHERE ORIGINAL_WIP_ENTITY_ID = x_purge_rec.wip_entity_id
                 AND INVENTORY_ITEM_ID = x_purge_rec.primary_item_id );

    end if;

    /*  Bug 5935560.  Need to update original_wip_entity_id in MSN to -999
        and purge if there is a associated serial number. */

    /* x_records_found := x_records_found OR (x_records_returned > 0); */

    if (x_records_returned > 0) then
       /* append_report(x_purge_rec, p_option);  */
       fnd_file.put_line(FND_FILE.LOG,'Note: job/schedule '||x_purge_rec.wip_entity_id||' has Serial Number reference');
    end if;

	x_purge_rec.table_name := 'MTL_MATERIAL_TRANSACTIONS';

        SELECT COUNT(*)
        into x_records_returned
        FROM DUAL
        WHERE EXISTS
              (SELECT 1
               FROM  MTL_MATERIAL_TRANSACTIONS
               WHERE TRANSACTION_SOURCE_TYPE_ID + 0 = 5
               AND TRANSACTION_SOURCE_ID = x_purge_rec.wip_entity_id
               AND ORGANIZATION_ID = x_purge_rec.org_id );

    x_records_found := x_records_found OR (x_records_returned > 0);

    if (x_records_returned > 0) then
       append_report(x_purge_rec, p_option);
    end if;



    x_purge_rec.table_name := 'MTL_TRANSACTION_ACCOUNTS';

        SELECT COUNT(*)
        into x_records_returned
        FROM DUAL
        WHERE EXISTS
                (SELECT 1
                 FROM MTL_TRANSACTION_ACCOUNTS MTA , MTL_MATERIAL_TRANSACTIONS MMT
                WHERE MMT.TRANSACTION_SOURCE_TYPE_ID + 0 = 5
                AND MMT.TRANSACTION_SOURCE_ID = x_purge_rec.wip_entity_id
                AND MMT.TRANSACTION_ID = MTA.TRANSACTION_ID
                AND MMT.ORGANIZATION_ID = x_purge_rec.org_id );

    x_records_found := x_records_found OR (x_records_returned > 0);

    if (x_records_returned > 0) then
       append_report(x_purge_rec, p_option);
    end if;


    x_purge_rec.table_name := 'MTL_TRANSACTION_LOT_NUMBERS';

        SELECT COUNT(*)
        into x_records_returned
        FROM DUAL
        WHERE EXISTS
                (SELECT 1
                 FROM  MTL_TRANSACTION_LOT_NUMBERS
                WHERE TRANSACTION_SOURCE_TYPE_ID = 5
                AND TRANSACTION_SOURCE_ID = x_purge_rec.wip_entity_id );

    x_records_found := x_records_found OR (x_records_returned > 0);

    if (x_records_returned > 0) then
       append_report(x_purge_rec, p_option);
    end if;



    x_purge_rec.table_name := 'MTL_UNIT_TRANSACTIONS';

        SELECT COUNT(*)
        into x_records_returned
        FROM DUAL
        WHERE EXISTS
                (SELECT 1
                 FROM MTL_UNIT_TRANSACTIONS
                WHERE TRANSACTION_SOURCE_TYPE_ID = 5
                AND TRANSACTION_SOURCE_ID = x_purge_rec.wip_entity_id );

    x_records_found := x_records_found OR (x_records_returned > 0);

    if (x_records_returned > 0) then
       append_report(x_purge_rec, p_option);
    end if;



    -- PASSED VALIDATIONS SO DELETE HEADER AND INTERFACE RECORDS

--   if (G_Continue_Purging = TRUE) then

    if x_records_found = FALSE then

     x_purge_rec.info_type := EXCEPTIONS;

     if (p_option = REPORT_ONLY) then
        select count(*) into x_num_rows
        from MTL_SERIAL_NUMBERS
        WHERE ORIGINAL_WIP_ENTITY_ID = x_purge_rec.wip_entity_id ;
     else
        update MTL_SERIAL_NUMBERS
        set original_wip_entity_id = -999
        WHERE ORIGINAL_WIP_ENTITY_ID = x_purge_rec.wip_entity_id;

        x_num_rows := SQL%ROWCOUNT ;
     end if;

     if x_num_rows > 0 then
        x_purge_rec.table_name := 'MTL_SERIAL_NUMBERS';
        fnd_message.set_name('WIP', 'WIP_SERIAL_FOREIGN_KEY');
        x_purge_rec.info := fnd_message.get;
        append_report(x_purge_rec, p_option);
     end if;

     x_purge_rec.info_type := ROWS_AFFECTED;

     x_purge_rec.table_name := 'CST_PERIOD_VALUE_TEMP';


        if (p_option = REPORT_ONLY) then
              SELECT COUNT(*) INTO x_num_rows
               FROM CST_PERIOD_VALUE_TEMP
              WHERE  WIP_ENTITY_ID = x_purge_rec.wip_entity_id
                AND  ORGANIZATION_ID = x_purge_rec.org_id;
         else
              DELETE FROM CST_PERIOD_VALUE_TEMP
              WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id
              AND ORGANIZATION_ID = x_purge_rec.org_id;

              x_num_rows := SQL%ROWCOUNT ;

          end if ;

          if x_num_rows > 0 then
                   before_append_report(
                                p_option           => p_option,
                                p_purge_rec        => x_purge_rec,
                                num_rows           => x_num_rows);
        end if;

     /* Fix for Bug#3125050. Changed CST_STD_COST_ADJ_TEMP TO
                                     CST_STD_COST_ADJ_DEBUG
     */
     x_purge_rec.table_name := 'CST_STD_COST_ADJ_DEBUG';


      if (p_option = REPORT_ONLY) then
          SELECT COUNT(*) INTO x_num_rows
          FROM CST_STD_COST_ADJ_DEBUG
          WHERE  WIP_ENTITY_ID = x_purge_rec.wip_entity_id
          AND  ORGANIZATION_ID = x_purge_rec.org_id;
      else
          DELETE FROM CST_STD_COST_ADJ_DEBUG
          WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id
          AND ORGANIZATION_ID = x_purge_rec.org_id;

          x_num_rows := SQL%ROWCOUNT ;

      end if ;

      if x_num_rows > 0 then
                before_append_report(
                             p_option           => p_option,
                             p_purge_rec        => x_purge_rec,
                             num_rows           => x_num_rows);
      end if;


     x_purge_rec.table_name := 'PO_REQUISITIONS_INTERFACE_ALL';

      if (p_option = REPORT_ONLY) then
          SELECT COUNT(*) INTO x_num_rows
          FROM PO_REQUISITIONS_INTERFACE_ALL
          WHERE  WIP_ENTITY_ID = x_purge_rec.wip_entity_id;
      else
          DELETE FROM PO_REQUISITIONS_INTERFACE_ALL
          WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id;

          x_num_rows := SQL%ROWCOUNT ;

      end if ;

      if x_num_rows > 0 then
                before_append_report(
                             p_option           => p_option,
                             p_purge_rec        => x_purge_rec,
                             num_rows           => x_num_rows);
      end if;


     x_purge_rec.table_name := 'RCV_TRANSACTIONS_INTERFACE';

      if (p_option = REPORT_ONLY) then
          SELECT COUNT(*) INTO x_num_rows
          FROM RCV_TRANSACTIONS_INTERFACE
          WHERE  WIP_ENTITY_ID = x_purge_rec.wip_entity_id;
      else
          DELETE FROM RCV_TRANSACTIONS_INTERFACE
          WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id;

          x_num_rows := SQL%ROWCOUNT ;

      end if ;

      if x_num_rows > 0 then
                before_append_report(
                             p_option           => p_option,
                             p_purge_rec        => x_purge_rec,
                             num_rows           => x_num_rows);
      end if;


     x_purge_rec.table_name := 'MRP_RELIEF_INTERFACE';

      if (p_option = REPORT_ONLY) then
          SELECT COUNT(*) INTO x_num_rows
          FROM MRP_RELIEF_INTERFACE
          WHERE  DISPOSITION_TYPE = 1
          AND  DISPOSITION_ID   = x_purge_rec.wip_entity_id;
      else
          DELETE FROM MRP_RELIEF_INTERFACE
          WHERE  DISPOSITION_TYPE = 1
          AND  DISPOSITION_ID   = x_purge_rec.wip_entity_id;

          x_num_rows := SQL%ROWCOUNT ;

      end if ;

      if x_num_rows > 0 then
                before_append_report(
                             p_option           => p_option,
                             p_purge_rec        => x_purge_rec,
                             num_rows           => x_num_rows);
      end if;

     x_purge_rec.table_name := 'MTL_DEMAND_INTERFACE';

     if (p_option = REPORT_ONLY) then
          SELECT COUNT(*) INTO x_num_rows
            FROM MTL_DEMAND_INTERFACE
           WHERE ORGANIZATION_ID = x_purge_rec.org_id
             AND SUPPLY_SOURCE_TYPE = 5
             AND SUPPLY_HEADER_ID = x_purge_rec.wip_entity_id;
      else
          DELETE FROM MTL_DEMAND_INTERFACE
           WHERE ORGANIZATION_ID = x_purge_rec.org_id
           AND SUPPLY_SOURCE_TYPE = 5
           AND SUPPLY_HEADER_ID = x_purge_rec.wip_entity_id;

          x_num_rows := SQL%ROWCOUNT ;

      end if ;

      if x_num_rows > 0 then
                before_append_report(
                             p_option           => p_option,
                             p_purge_rec        => x_purge_rec,
                             num_rows           => x_num_rows);
      end if;


     x_purge_rec.table_name := 'MTL_TRANSACTIONS_INTERFACE';

 if (p_option = REPORT_ONLY) then
          SELECT COUNT(*) INTO x_num_rows
            FROM MTL_TRANSACTIONS_INTERFACE
          WHERE  TRANSACTION_SOURCE_TYPE_ID = 5
            AND TRANSACTION_SOURCE_ID = x_purge_rec.wip_entity_id;
      else
          DELETE FROM MTL_TRANSACTIONS_INTERFACE
          WHERE  TRANSACTION_SOURCE_TYPE_ID = 5
            AND TRANSACTION_SOURCE_ID = x_purge_rec.wip_entity_id;
          x_num_rows := SQL%ROWCOUNT ;
      end if ;

      if x_num_rows > 0 then
                before_append_report(
                             p_option           => p_option,
                             p_purge_rec        => x_purge_rec,
                             num_rows           => x_num_rows);
      end if;


     x_purge_rec.table_name := 'MTL_MATERIAL_TRANSACTIONS_TEMP';

    if (x_purge_rec.primary_item_id IS NULL) then
         if (p_option = REPORT_ONLY) then
                  SELECT COUNT(*)
                  INTO x_num_rows
                  FROM MTL_MATERIAL_TRANSACTIONS_TEMP
                  WHERE  TRANSACTION_SOURCE_TYPE_ID = 5
                  AND    INVENTORY_ITEM_ID IS NULL
                  AND TRANSACTION_SOURCE_ID = x_purge_rec.wip_entity_id;
         else
                  DELETE FROM MTL_MATERIAL_TRANSACTIONS_TEMP
                  WHERE  TRANSACTION_SOURCE_TYPE_ID = 5
                  AND    INVENTORY_ITEM_ID IS NULL
                  AND TRANSACTION_SOURCE_ID = x_purge_rec.wip_entity_id;

                  x_num_rows := SQL%ROWCOUNT ;
        end if ;

    else

         if (p_option = REPORT_ONLY) then
                  SELECT COUNT(*)
                  INTO x_num_rows
                  FROM MTL_MATERIAL_TRANSACTIONS_TEMP
                  WHERE  TRANSACTION_SOURCE_TYPE_ID = 5
                  AND    INVENTORY_ITEM_ID = x_purge_rec.primary_item_id
                  AND TRANSACTION_SOURCE_ID = x_purge_rec.wip_entity_id;
         else
                  DELETE FROM MTL_MATERIAL_TRANSACTIONS_TEMP
                  WHERE  TRANSACTION_SOURCE_TYPE_ID = 5
                  AND    INVENTORY_ITEM_ID = x_purge_rec.primary_item_id
                  AND TRANSACTION_SOURCE_ID = x_purge_rec.wip_entity_id;

                  x_num_rows := SQL%ROWCOUNT ;
        end if ;

    end if;

      if x_num_rows > 0 then
                before_append_report(
                             p_option           => p_option,
                             p_purge_rec        => x_purge_rec,
                             num_rows           => x_num_rows);
      end if;



    --
    --Bug#4715338 START - Purge Time Entry records
    --Purge records from WIP_RESOURCE_ACTUAL_TIMES
    --
     x_purge_rec.table_name := 'WIP_RESOURCE_ACTUAL_TIMES';

      if (p_option = REPORT_ONLY) then
          SELECT  COUNT(*) INTO X_NUM_ROWS
          FROM    WIP_RESOURCE_ACTUAL_TIMES
          WHERE   ORGANIZATION_ID = X_PURGE_REC.ORG_ID AND
                  WIP_ENTITY_ID = X_PURGE_REC.WIP_ENTITY_ID;
      else
          DELETE FROM WIP_RESOURCE_ACTUAL_TIMES
          WHERE   ORGANIZATION_ID = X_PURGE_REC.ORG_ID AND
                  WIP_ENTITY_ID = X_PURGE_REC.WIP_ENTITY_ID;
          x_num_rows := SQL%ROWCOUNT ;
      end if;

      if x_num_rows > 0 then
                before_append_report(
                             p_option           => p_option,
                             p_purge_rec        => x_purge_rec,
                             num_rows           => x_num_rows);
      end if;
    --
    --Bug#4715338 ENDS
    --


    --
    --Bug#4716115 START
    --Purge records from WIP_LPN_COMPLETIONS, WIP_LPN_COMPLETIONS_LOTS, WIP_LPN_COMPLETIONS_SERIALS
    --

    -- delete from wip_lpn_completions_lots
     x_purge_rec.table_name := 'WIP_LPN_COMPLETIONS_LOTS';

      if (p_option = REPORT_ONLY) then
          SELECT  COUNT(*) INTO X_NUM_ROWS
          FROM    WIP_LPN_COMPLETIONS_LOTS WLCL
          WHERE   WLCL.HEADER_ID IN
          (
            SELECT  WLC.HEADER_ID
            FROM    WIP_LPN_COMPLETIONS WLC
            WHERE   TRANSACTION_SOURCE_ID = X_PURGE_REC.WIP_ENTITY_ID
          );
      else
          DELETE FROM WIP_LPN_COMPLETIONS_LOTS WLCL
          WHERE   WLCL.HEADER_ID IN
          (
            SELECT  WLC.HEADER_ID
            FROM    WIP_LPN_COMPLETIONS WLC
            WHERE   WLC.TRANSACTION_SOURCE_ID = X_PURGE_REC.WIP_ENTITY_ID
          );
          x_num_rows := SQL%ROWCOUNT ;
      end if;

      if x_num_rows > 0 then
                before_append_report(
                             p_option           => p_option,
                             p_purge_rec        => x_purge_rec,
                             num_rows           => x_num_rows);
      end if;

    -- delete from wip_lpn_completions_serials
     x_purge_rec.table_name := 'WIP_LPN_COMPLETIONS_SERIALS';

      if (p_option = REPORT_ONLY) then
          SELECT  COUNT(*) INTO X_NUM_ROWS
          FROM    WIP_LPN_COMPLETIONS_SERIALS WLCS
          WHERE   WLCS.HEADER_ID IN
          (
            SELECT  WLC.HEADER_ID
            FROM    WIP_LPN_COMPLETIONS WLC
            WHERE   TRANSACTION_SOURCE_ID = X_PURGE_REC.WIP_ENTITY_ID
          );
      else
          DELETE FROM WIP_LPN_COMPLETIONS_SERIALS WLCS
          WHERE   WLCS.HEADER_ID IN
          (
            SELECT  WLC.HEADER_ID
            FROM    WIP_LPN_COMPLETIONS WLC
            WHERE   WLC.TRANSACTION_SOURCE_ID = X_PURGE_REC.WIP_ENTITY_ID
          );
          x_num_rows := SQL%ROWCOUNT ;
      end if;

      if x_num_rows > 0 then
                before_append_report(
                             p_option           => p_option,
                             p_purge_rec        => x_purge_rec,
                             num_rows           => x_num_rows);
      end if;


    -- delete from wip_lpn_completions
     x_purge_rec.table_name := 'WIP_LPN_COMPLETIONS';

      if (p_option = REPORT_ONLY) then
          SELECT  COUNT(*) INTO X_NUM_ROWS
          FROM    WIP_LPN_COMPLETIONS
          WHERE   TRANSACTION_SOURCE_ID = X_PURGE_REC.WIP_ENTITY_ID;
      else
          DELETE FROM WIP_LPN_COMPLETIONS
          WHERE   TRANSACTION_SOURCE_ID = X_PURGE_REC.WIP_ENTITY_ID;
          x_num_rows := SQL%ROWCOUNT ;
      end if;

      if x_num_rows > 0 then
                before_append_report(
                             p_option           => p_option,
                             p_purge_rec        => x_purge_rec,
                             num_rows           => x_num_rows);
      end if;

    --
    --Fix for Bug#4716115 ENDS
    --


     x_purge_rec.table_name := 'MTL_SUPPLY_DEMAND_TEMP';

        if (p_option = REPORT_ONLY) then
          SELECT COUNT(*) INTO x_num_rows
            FROM MTL_SUPPLY_DEMAND_TEMP
          WHERE  DISPOSITION_TYPE = 5
            AND  DISPOSITION_ID = x_purge_rec.wip_entity_id;
      else
          DELETE FROM MTL_SUPPLY_DEMAND_TEMP
          WHERE  DISPOSITION_TYPE = 5
            AND  DISPOSITION_ID = x_purge_rec.wip_entity_id;
          x_num_rows := SQL%ROWCOUNT ;
      end if;

      if x_num_rows > 0 then
                before_append_report(
                             p_option           => p_option,
                             p_purge_rec        => x_purge_rec,
                             num_rows           => x_num_rows);
      end if;



 /* Moved WIP_SO_ALLOCATIONS deletion codes to this section so that it will go
    through the foreign key verifications to ensure that WIP_SO_ALLOCATIONS will
    NOT be purged if foreign key references exist in the MTL_DEMAND table.
    Bug # 622330                                                             */

  if (OE_INSTALL.Get_Active_Product = 'OE') then
    x_purge_rec.table_name := 'WIP_SO_ALLOCATIONS';

     if (p_option = REPORT_ONLY) then
          SELECT COUNT(*) INTO x_num_rows
            FROM WIP_SO_ALLOCATIONS
          WHERE  WIP_ENTITY_ID = x_purge_rec.wip_entity_id;
      else
          DELETE FROM WIP_SO_ALLOCATIONS
           WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id;
          x_num_rows := SQL%ROWCOUNT ;
      end if ;

      if x_num_rows > 0 then
                before_append_report(
                             p_option           => p_option,
                             p_purge_rec        => x_purge_rec,
                             num_rows           => x_num_rows);
      end if;

  end if;



     x_purge_rec.table_name := 'WIP_SCHEDULING_EXCEPTIONS';

        if (p_option = REPORT_ONLY) then
          SELECT COUNT(*)
          INTO x_num_rows
          FROM WIP_SCHEDULING_EXCEPTIONS
          WHERE  WIP_ENTITY_ID = x_purge_rec.wip_entity_id;
      else
          DELETE FROM WIP_SCHEDULING_EXCEPTIONS
           WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id;
          x_num_rows := SQL%ROWCOUNT ;
      end if ;

      if x_num_rows > 0 then
                before_append_report(
                             p_option           => p_option,
                             p_purge_rec        => x_purge_rec,
                             num_rows           => x_num_rows);
      end if;

     /* Bug#4675116 */
     x_purge_rec.table_name := 'WIP_EXCEPTIONS';

      if (p_option = REPORT_ONLY) then
          SELECT COUNT(*)
          INTO x_num_rows
          FROM WIP_EXCEPTIONS
          WHERE  WIP_ENTITY_ID = x_purge_rec.wip_entity_id
          AND ORGANIZATION_ID = x_purge_rec.org_id;
      else
          DELETE FROM WIP_EXCEPTIONS
           WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id
           AND ORGANIZATION_ID = x_purge_rec.org_id;
          x_num_rows := SQL%ROWCOUNT ;
      end if ;

      if x_num_rows > 0 then
                before_append_report(
                             p_option           => p_option,
                             p_purge_rec        => x_purge_rec,
                             num_rows           => x_num_rows);
      end if;



     x_purge_rec.table_name := 'WIP_PERIOD_BALANCES';

        if (p_option = REPORT_ONLY) then
          SELECT COUNT(*) INTO x_num_rows
            FROM WIP_PERIOD_BALANCES
          WHERE  WIP_ENTITY_ID = x_purge_rec.wip_entity_id;
      else
          DELETE FROM WIP_PERIOD_BALANCES
           WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id;
          x_num_rows := SQL%ROWCOUNT ;
      end if ;

      if x_num_rows > 0 then
                before_append_report(
                             p_option           => p_option,
                             p_purge_rec        => x_purge_rec,
                             num_rows           => x_num_rows);
      end if;


     x_purge_rec.table_name := 'WIP_DISCRETE_JOBS';

        if (p_option = REPORT_ONLY) then
          SELECT COUNT(*) INTO x_num_rows
            FROM WIP_DISCRETE_JOBS
          WHERE  WIP_ENTITY_ID = x_purge_rec.wip_entity_id;
      else
          DELETE FROM WIP_DISCRETE_JOBS
           WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id;
          x_num_rows := SQL%ROWCOUNT ;
      end if ;

      if x_num_rows > 0 then
                before_append_report(
                             p_option           => p_option,
                             p_purge_rec        => x_purge_rec,
                             num_rows           => x_num_rows);
      end if;



     x_purge_rec.table_name := 'WIP_ENTITIES';

        if (p_option = REPORT_ONLY) then
          SELECT COUNT(*) INTO x_num_rows
            FROM WIP_ENTITIES
          WHERE  WIP_ENTITY_ID = x_purge_rec.wip_entity_id;
        else
          DELETE FROM WIP_ENTITIES
           WHERE WIP_ENTITY_ID = x_purge_rec.wip_entity_id;
          x_num_rows := SQL%ROWCOUNT ;
        end if ;

      if x_num_rows > 0 then
                before_append_report(
                             p_option           => p_option,
                             p_purge_rec        => x_purge_rec,
                             num_rows           => x_num_rows);
      end if;


   end if;

  end delete_job_header;



-- procedure to delete schedule headers
procedure delete_sched_header (
    p_option        in number,
    p_group_id      in number,
    p_purge_request in get_purge_requests%rowtype,
    p_sched_move_txn_flag in out nocopy boolean,
    p_sched_txn_flag in out nocopy boolean ) is

    x_purge_rec       purge_report_type;
    x_records_found   boolean := FALSE;
    x_num_rows  number := 0;
    l_num_rows number := 0;
  begin
    -- initialize
    x_purge_rec.group_id        := p_group_id;
    x_purge_rec.org_id          := p_purge_request.organization_id;
    x_purge_rec.wip_entity_id   := p_purge_request.wip_entity_id;
    x_purge_rec.schedule_id     := p_purge_request.repetitive_schedule_id;
    x_purge_rec.primary_item_id := p_purge_request.primary_item_id;
    x_purge_rec.line_id         := p_purge_request.line_id;
    x_purge_rec.start_date      := p_purge_request.start_date;
    x_purge_rec.complete_date   := p_purge_request.complete_date;
    x_purge_rec.close_date      := p_purge_request.close_date;
    x_purge_rec.info_type       := EXCEPTIONS;
    x_purge_rec.entity_name     := p_purge_request.wip_entity_name;
    x_purge_rec.line_code       := p_purge_request.line_code;

    -- set message; verify no period balance activity
    fnd_message.set_name('WIP', 'WIP_PERIOD_BALANCES_EXIST');
    x_purge_rec.info := fnd_message.get;

    x_purge_rec.table_name := 'WIP_PERIOD_BALANCES';

    /* Fixing bug 935919. The following sql is introduced to replace the earlier one because
       the checking should be done to see whether the sum of (IN - OUT NOCOPY - VAR) of each cost
       component is zero over all accounting periods in WIP_PERIOD_BALANCES, not each of the
       individula cost columns in WIP_PERIOD_BALANCES is zero as it was in the earlier sql.
    */

     select count(*) into l_num_rows
       from sys.dual
      where (0,0,0,0,0,0,0,0,0,0) <>
                (select sum(NVL(TL_RESOURCE_IN, 0) - NVL(TL_RESOURCE_OUT, 0)
                                    -  NVL(TL_RESOURCE_VAR,0)),
                        sum(NVL(TL_OVERHEAD_IN, 0) - NVL(TL_OVERHEAD_OUT, 0)
                                    -  NVL(TL_OVERHEAD_VAR,0)),
                        sum(NVL(TL_OUTSIDE_PROCESSING_IN,0) - NVL(TL_OUTSIDE_PROCESSING_OUT, 0)
                                    -  NVL(TL_OUTSIDE_PROCESSING_VAR,0)),
                        sum(0 - NVL(TL_MATERIAL_OUT, 0) -  NVL(TL_MATERIAL_VAR,0)),
                        sum(0 - NVL(TL_MATERIAL_OVERHEAD_OUT, 0)
                                    -  NVL(TL_MATERIAL_OVERHEAD_VAR,0)),
                        sum(NVL(PL_MATERIAL_IN, 0) - NVL(PL_MATERIAL_OUT, 0)
                                    -  NVL(PL_MATERIAL_VAR,0)),
                        sum(NVL(PL_MATERIAL_OVERHEAD_IN, 0) - NVL(PL_MATERIAL_OVERHEAD_OUT, 0)
                                    -  NVL(PL_MATERIAL_OVERHEAD_VAR,0)),
                        sum(NVL(PL_RESOURCE_IN, 0) - NVL(PL_RESOURCE_OUT, 0)
                                    -  NVL(PL_RESOURCE_VAR,0)),
                        sum(NVL(PL_OVERHEAD_IN, 0) - NVL(PL_OVERHEAD_OUT, 0)
                                    -  NVL(PL_OVERHEAD_VAR,0)),
                        sum(NVL(PL_OUTSIDE_PROCESSING_IN, 0) - NVL(PL_OUTSIDE_PROCESSING_OUT, 0)
                                    -  NVL(PL_OUTSIDE_PROCESSING_VAR,0))
                   from WIP_PERIOD_BALANCES
                  where WIP_ENTITY_ID = x_purge_rec.wip_entity_id
                    and REPETITIVE_SCHEDULE_ID = x_purge_rec.schedule_id);
    x_records_found := x_records_found OR (l_num_rows > 0);
    if ( l_num_rows > 0 ) then
      append_report(x_purge_rec, p_option);
    end if;
    l_num_rows := 0;

    -- reset message; check for foreign key references
    fnd_message.set_name('WIP', 'WIP_PURGE_FOREIGN_KEY');
    fnd_message.set_token('TABLE', 'WIP_REPETITIVE_SCHEDULES', TRUE);
    x_purge_rec.info := fnd_message.get;

    x_purge_rec.table_name := 'PO_DISTRIBUTIONS_ALL';
    SELECT COUNT(*) into l_num_rows
      FROM DUAL
     WHERE EXISTS (SELECT 1
                     FROM PO_DISTRIBUTIONS_ALL
                    WHERE WIP_REPETITIVE_SCHEDULE_ID = x_purge_rec.schedule_id
                      AND WIP_ENTITY_ID = x_purge_rec.wip_entity_id
                          /* Fixed bug 3115844 */
                      AND po_line_id IS NOT NULL
                      AND line_location_id IS NOT NULL);
    x_records_found := x_records_found OR (l_num_rows > 0);
    if ( l_num_rows > 0 ) then
      append_report(x_purge_rec, p_option);
    end if;
    l_num_rows := 0;

    x_purge_rec.table_name := 'PO_DISTRIBUTIONS_ARCHIVE_ALL';
    SELECT COUNT(*) into l_num_rows
      FROM DUAL
     WHERE EXISTS (SELECT 1
                     FROM PO_DISTRIBUTIONS_ARCHIVE_ALL
                    WHERE WIP_REPETITIVE_SCHEDULE_ID = x_purge_rec.schedule_id
                      and WIP_ENTITY_ID = x_purge_rec.wip_entity_id);
     x_records_found := x_records_found OR (l_num_rows > 0);
    if ( l_num_rows > 0 ) then
      append_report(x_purge_rec, p_option);
    end if;
    l_num_rows := 0;

    x_purge_rec.table_name := 'PO_REQUISITION_LINES_ALL';
    SELECT COUNT(*) into l_num_rows
      FROM DUAL
     WHERE EXISTS (SELECT 1
                     FROM PO_REQUISITION_LINES_ALL
                    WHERE WIP_REPETITIVE_SCHEDULE_ID = x_purge_rec.schedule_id
                      AND WIP_ENTITY_ID = x_purge_rec.wip_entity_id);
    x_records_found := x_records_found OR (l_num_rows > 0);
    if ( l_num_rows > 0 ) then
      append_report(x_purge_rec, p_option);
    end if;
    l_num_rows := 0;


    x_purge_rec.table_name := 'RCV_TRANSACTIONS';
    SELECT COUNT(*) into l_num_rows
      FROM DUAL
     WHERE EXISTS (SELECT 1
                     FROM RCV_TRANSACTIONS
                    WHERE WIP_REPETITIVE_SCHEDULE_ID = x_purge_rec.schedule_id
                      AND WIP_ENTITY_ID = x_purge_rec.wip_entity_id);
    x_records_found := x_records_found OR (l_num_rows > 0);
    if ( l_num_rows > 0 ) then
      append_report(x_purge_rec, p_option);
    end if;
    l_num_rows := 0;

    x_purge_rec.table_name := 'MTL_TRANSACTION_ACCOUNTS';
    SELECT COUNT(*) into l_num_rows
      FROM DUAL
     WHERE EXISTS (SELECT 1
                     FROM MTL_TRANSACTION_ACCOUNTS MTA,
                          MTL_MATERIAL_TRANSACTIONS MMT
                    WHERE MMT.TRANSACTION_SOURCE_TYPE_ID + 0 = 5
                      AND MMT.TRANSACTION_SOURCE_ID = x_purge_rec.wip_entity_id
                      AND MMT.REPETITIVE_LINE_ID = x_purge_rec.line_id
                      AND MMT.TRANSACTION_ID = MTA.TRANSACTION_ID
                      AND MMT.ORGANIZATION_ID = x_purge_rec.org_id
                      AND MTA.REPETITIVE_SCHEDULE_ID = x_purge_rec.schedule_id);
    x_records_found := x_records_found OR (l_num_rows > 0);
    if ( l_num_rows > 0 ) then
      append_report(x_purge_rec, p_option);
    end if;
    l_num_rows := 0;

    -- reset message; check for allocations
    fnd_message.set_name('WIP', 'WIP_ALLOCATIONS_EXIST');
    x_purge_rec.info := fnd_message.get;

    x_purge_rec.table_name := 'MTL_MATERIAL_TXN_ALLOCATIONS';
    SELECT COUNT(*) into l_num_rows
      FROM DUAL
     WHERE EXISTS (SELECT 1
                     FROM MTL_MATERIAL_TXN_ALLOCATIONS
                    WHERE REPETITIVE_SCHEDULE_ID = x_purge_rec.schedule_id
                      AND ORGANIZATION_ID = x_purge_rec.org_id);
    x_records_found := x_records_found OR (l_num_rows > 0);
    if ( l_num_rows > 0 ) then
      append_report(x_purge_rec, p_option);
    end if;
    l_num_rows := 0;


    -- PASSED VALIDATIONS SO DELETE HEADER AND INTERFACE RECORDS

    if (x_records_found = FALSE and p_sched_txn_flag = FALSE
        and p_sched_move_txn_flag = FALSE) then

      x_purge_rec.info_type       := ROWS_AFFECTED ;
      x_purge_rec.table_name := 'PO_DISTRIBUTIONS_INTERFACE';

      savepoint sched_header01;
      DELETE FROM PO_DISTRIBUTIONS_INTERFACE
       WHERE WIP_REPETITIVE_SCHEDULE_ID = x_purge_rec.schedule_id;
      l_num_rows := sql%rowcount;
      if ( p_option = REPORT_ONLY) then
        -- rollback deletes
        rollback to sched_header01;
      end if;
      construct_report_content(p_option => p_option,
                               p_num_rows => l_num_rows,
                               p_purge_rec => x_purge_rec);
      l_num_rows := 0;


      x_purge_rec.table_name := 'PO_REQUISITIONS_INTERFACE_ALL';

      savepoint sched_header02;

      -- Bug 4880984
      -- Added wip_entity_id filter to this SQL to improve performance
      -- since an index based on wip_entity_id is available for
      -- table PO_REQUISITIONS_INTERFACE_ALL.
      DELETE FROM PO_REQUISITIONS_INTERFACE_ALL
       WHERE WIP_REPETITIVE_SCHEDULE_ID = x_purge_rec.schedule_id
       AND   WIP_ENTITY_ID = x_purge_rec.wip_entity_id;
      l_num_rows := sql%rowcount;
      if ( p_option = REPORT_ONLY) then
        -- rollback deletes
        rollback to sched_header02;
      end if;
      construct_report_content(p_option => p_option,
                               p_num_rows => l_num_rows,
                               p_purge_rec => x_purge_rec);
      l_num_rows := 0;


      x_purge_rec.table_name := 'RCV_TRANSACTIONS_INTERFACE';

      -- Bug 4880984
      -- Added wip_entity_id filter to these SQLs to improve performance
      -- since an index based on wip_entity_id is available for
      -- table rcv_transactions_interface
      if (p_option = REPORT_ONLY) then
          SELECT COUNT(*) INTO x_num_rows
            FROM RCV_TRANSACTIONS_INTERFACE
           WHERE WIP_REPETITIVE_SCHEDULE_ID = x_purge_rec.schedule_id
           AND   WIP_ENTITY_ID = x_purge_rec.wip_entity_id;
      else
          DELETE FROM RCV_TRANSACTIONS_INTERFACE
           WHERE WIP_REPETITIVE_SCHEDULE_ID = x_purge_rec.schedule_id
           AND   WIP_ENTITY_ID = x_purge_rec.wip_entity_id;
          x_num_rows := SQL%ROWCOUNT ;
      end if ;

      if x_num_rows > 0 then
                before_append_report(
                             p_option           => p_option,
                             p_purge_rec        => x_purge_rec,
                             num_rows           => x_num_rows);
      end if;



/*  --  The following tables need not be checked - decided after the
        dicussion with mikec and djoffe - dsoosai 01/06/1996 --

      x_purge_rec.table_name := 'WIP_MOVE_TXN_INTERFACE';
      delete_from_table(
        p_option           => p_option,
        p_purge_rec        => x_purge_rec,
        p_delete_statement =>
          'DELETE FROM ' || x_purge_rec.table_name ||
          ' WHERE REPETITIVE_SCHEDULE_ID = ' || to_char(x_purge_rec.schedule_id));

      x_purge_rec.table_name := 'WIP_COST_TXN_INTERFACE';
      delete_from_table(
        p_option           => p_option,
        p_purge_rec        => x_purge_rec,
        p_delete_statement =>
          'DELETE FROM ' || x_purge_rec.table_name ||
          ' WHERE REPETITIVE_SCHEDULE_ID = ' || to_char(x_purge_rec.schedule_id));

 ----------------------------------------------------------------------------*/

     x_purge_rec.table_name := 'WIP_PERIOD_BALANCES';

     if (p_option = REPORT_ONLY) then
          SELECT COUNT(*) INTO x_num_rows
            FROM WIP_PERIOD_BALANCES
          WHERE  REPETITIVE_SCHEDULE_ID = x_purge_rec.schedule_id
            AND  WIP_ENTITY_ID = x_purge_rec.wip_entity_id;
      else
          DELETE FROM WIP_PERIOD_BALANCES
          WHERE  REPETITIVE_SCHEDULE_ID = x_purge_rec.schedule_id
            AND  WIP_ENTITY_ID = x_purge_rec.wip_entity_id;
          x_num_rows := SQL%ROWCOUNT ;
      end if ;

      if x_num_rows > 0 then
                before_append_report(
                             p_option           => p_option,
                             p_purge_rec        => x_purge_rec,
                             num_rows           => x_num_rows);
      end if;

      x_purge_rec.table_name := 'WIP_REPETITIVE_SCHEDULES';
      if (p_option = REPORT_ONLY) then
          SELECT COUNT(*) INTO x_num_rows
            FROM WIP_REPETITIVE_SCHEDULES
          WHERE  REPETITIVE_SCHEDULE_ID = x_purge_rec.schedule_id;
      else
          DELETE FROM WIP_REPETITIVE_SCHEDULES
          WHERE  REPETITIVE_SCHEDULE_ID = x_purge_rec.schedule_id;
          x_num_rows := SQL%ROWCOUNT ;
      end if ;

      if x_num_rows > 0 then
                before_append_report(
                             p_option           => p_option,
                             p_purge_rec        => x_purge_rec,
                             num_rows           => x_num_rows);
      end if;

    end if;
  end delete_sched_header ;

  -- Bug 5129924
  -- Added the parameter p_days_before_cutoff
  -- ntungare Wed May 31 00:23:41 PDT 2006
  --
  function find(
    p_purge_type      in number,
    p_conf_flag       in boolean,
    p_org_id          in number,
    p_cutoff_date     in date,
    p_days_before_cutoff in number,
    p_from_job        in varchar2,
    p_to_job          in varchar2,
    p_primary_item_id in number,
    p_line_id         in number,
    p_err_num         in out nocopy number,
    p_error_text      in out nocopy varchar2 ) return number is

    x_group_id    number;
    x_count       number;
    x_group       number;
    x_sql_stm1    varchar2(10000);
    x_sql_stm2    varchar2(10000);
    x_cursor_id   integer;
    x_num_rows    integer;

    x_from_date   date;

  begin
    -- generate a group ID
    select Wip_purge_temp_s.nextval into x_group_id from dual;

    -- find jobs
    if (p_purge_type in (PURGE_JOBS, PURGE_LOTBASED, PURGE_ALL)) then

        x_sql_stm1 := ' insert into wip_purge_temp '||
                        '           (group_id, ' ||
                        '            wip_entity_id, ' ||
                        '            repetitive_schedule_id, ' ||
                        '            primary_item_id, ' ||
                        '            line_id, ' ||
                        '            start_date, ' ||
                        '            complete_date, ' ||
                        '            close_date, ' ||
                        '            status_type, ' ||
                        '          organization_id) ' ||
                        '         select ' ||
                        /* Fix for bug#4902938 - Convert Literal to Bind variable*/
                        '            :l_group_id , ' ||
                        '            wdj.wip_entity_id, ' ||
                        '            NULL, ' ||
                        '            wdj.primary_item_id, ' ||
                        '            NULL, ' ||
                        '            wdj.scheduled_start_date, ' ||
                        '            wdj.scheduled_completion_date, ' ||
                        '            wdj.date_closed, ' ||
                        '            wdj.status_type, ' ||
                        '          wdj.organization_id ' ||
                        '         from  wip_discrete_jobs wdj, ' ||
                        '               wip_entities we ' ||
                        /* Fix for bug#4902938 - Convert Literal to Bind variable*/
                        '         where we.organization_id = :l_organization_id' ||
                        '         and we.organization_id = wdj.organization_id ' ||
                        '         and wdj.status_type = 12 ' || -- WIP_CONSTANTS.CLOSED
                        /* Fix for bug#4902938 - Convert Literal to Bind variable*/
                        /* Fix for bug#5137027 - remove '' for date bind variables */
			-- bug 5129924
			-- Commented out this condition as its handled
			-- separately below
			-- ntungare Wed May 31 00:25:28 PDT 2006
			--
                        -- '         and wdj.date_closed <=  :l_cutoff_date '||
                        '         and we.wip_entity_id = wdj.wip_entity_id ' ;
     -- bug 5129924
     -- Added following if statement and removed
     -- wdj.date_closed condition from above sql
     -- ntungare Thu May 25 11:48:33 PDT 2006
     --
     if (p_days_before_cutoff is null ) then
         x_sql_stm1 := x_sql_stm1 || ' and wdj.date_closed <= :l_cutoff_date ' ;
     else
         select p_cutoff_date - nvl(p_days_before_cutoff, 0)
          into   x_from_date
          from   dual ;

         x_sql_stm1 := x_sql_stm1 ||
                         '  and wdj.date_closed between :l_from_date and :l_cutoff_date  '  ;
     end if ;

    if (p_purge_type = PURGE_JOBS) then
        x_sql_stm1 :=  x_sql_stm1 || ' and we.entity_type = 3 ' ; -- WIP_CONSTANTS.CLOSED_DISCRETE_JOBS
    elsif (p_purge_type = PURGE_LOTBASED) then
        x_sql_stm1 :=  x_sql_stm1 || ' and we.entity_type = 8 ' ; -- WIP_CONSTANTS.CLOSED_OSFM
    elsif (p_purge_type = PURGE_ALL) then
        x_sql_stm1 :=  x_sql_stm1 || ' and we.entity_type in (3, 8)  ' ;
    end if ;

      if (p_primary_item_id is not null) then
        x_sql_stm1 :=  x_sql_stm1 || ' and wdj.primary_item_id = :l_primary_item_id ' ;
      end if;

      if (p_from_job is not null) then
        x_sql_stm1 :=  x_sql_stm1 || ' and we.wip_entity_name >= :l_from_job ' ;
      end if ;

      if (p_to_job is not null) then
        x_sql_stm1 :=  x_sql_stm1 || ' and we.wip_entity_name <= :l_to_job ';
      end if;

     if (not p_conf_flag) then
        x_sql_stm1 := x_sql_stm1 || '  and (wdj.primary_item_id is null ' ||
                        '              or ' ||
                        '              exists ' ||
                        '                (select msi.inventory_item_id ' ||
                        '                 from   mtl_system_items msi ' ||
                        '                 where  msi.inventory_item_id = wdj.primary_item_id ' ||
                        '                 and    msi.organization_id = wdj.organization_id ' ||
                        '                 and    msi.base_item_id is null ' ||
                        '                 and    msi.bom_item_type = 4 /*standard*/)) ';
      end if;

    x_cursor_id := dbms_sql.open_cursor;
    dbms_sql.parse(x_cursor_id, x_sql_stm1, dbms_sql.v7);

    /* Fix for bug#4902938 */
    if ( x_group_id is not null ) then
      dbms_sql.bind_variable(x_cursor_id, ':l_group_id', x_group_id);
    end if;
    if ( to_char(p_org_id) is not null ) then
      dbms_sql.bind_variable(x_cursor_id, ':l_organization_id', to_char(p_org_id));
    end if;

    -- Bug 5129924
    -- Binding the values
    -- ntungare
    --
    if (p_days_before_cutoff is not null ) then
      dbms_sql.bind_variable(x_cursor_id, ':l_from_date', x_from_date);
    end if;

    if ( p_cutoff_date is not null ) then
      dbms_sql.bind_variable(x_cursor_id, ':l_cutoff_date', p_cutoff_date);
    end if;

    /* END Fix for bug#4902938 */

    if ( p_primary_item_id is not null ) then
      dbms_sql.bind_variable(x_cursor_id, ':l_primary_item_id', p_primary_item_id);
    end if;
    if ( p_from_job is not null ) then
      dbms_sql.bind_variable(x_cursor_id, ':l_from_job', p_from_job);
    end if;
    if ( p_to_job is not null ) then
      dbms_sql.bind_variable(x_cursor_id, ':l_to_job', p_to_job);
    end if;
    x_num_rows := dbms_sql.execute(x_cursor_id);
    dbms_sql.close_cursor(x_cursor_id);

    end if;

    -- find schedules
    if (p_purge_type in (PURGE_SCHEDS, PURGE_ALL)) then


        x_sql_stm2 := ' insert into wip_purge_temp '||
                        '           (group_id, ' ||
                        '            wip_entity_id, ' ||
                        '            repetitive_schedule_id, ' ||
                        '            primary_item_id, ' ||
                        '            line_id, ' ||
                        '            start_date, ' ||
                        '            complete_date, ' ||
                        '            close_date, ' ||
                        '            status_type, ' ||
                        '          organization_id) ' ||
                        '         select distinct ' ||
                        /* Fix for bug#4902938 - Convert Literal to Bind variable*/
                        '            :l_group_id , ' ||
                        '            wrs.wip_entity_id, ' ||
                        '            wrs.repetitive_schedule_id, ' ||
                        '            wri.primary_item_id, ' ||
                        '            wri.line_id, ' ||
                        '            wrs.first_unit_start_date, ' ||
                        '            wrs.last_unit_completion_date, ' ||
                        '            wrs.date_closed, ' ||
                        '            wrs.status_type, ' ||
                        '            wrs.organization_id ' ||
                        '         from  wip_repetitive_schedules wrs , ' ||
                        '               wip_repetitive_items wri ' ||
                        /* Fix for bug#4902938 - Convert Literal to Bind variable*/
                        '         where wri.organization_id = :l_organization_id' ||
                        '         and wrs.organization_id = wri.organization_id ' ||
                        '         and wrs.wip_entity_id = wri.wip_entity_id ' ||
                        '         and wrs.line_id = wri.line_id ' ||
                        /* Fix for bug#4902938 - Convert Literal to Bind variable*/
                        /* Fix for bug#5137027 - remove '' for date bind variables */
                        -- bug 5129924
                        -- Commented this where clause as its handled below
                        -- ntungare
                        -- '         and wrs.date_closed <=  :l_cutoff_date '||
                        '         and wrs.status_type  in  ( 7,5 ) ' ; -- WIP_CONSTANTS.COMP_NOCHRG, CANCELLED

        -- bug 5129924
        -- Added following if statement and
        -- removed wrs.date_closed condition in
        -- above sql
	-- ntungare
	--
        if (p_days_before_cutoff is null ) then
           x_sql_stm2 := x_sql_stm2 || ' and wrs.date_closed <= :l_cutoff_date ' ;
        else
           select p_cutoff_date - nvl(p_days_before_cutoff, 0)
           into   x_from_date
           from   dual ;

           x_sql_stm2 := x_sql_stm2 ||
                         '  and wrs.date_closed between :l_from_date and :l_cutoff_date '  ;
        end if ;

       if (p_line_id is not null) then
        x_sql_stm2 := x_sql_stm2 || ' and wrs.line_id = :l_line_id ';
       end if;

       if (p_primary_item_id is not null) then
        x_sql_stm2 := x_sql_stm2 || ' and wri.primary_item_id = :l_primary_item_id ';
       end if;


    x_cursor_id := dbms_sql.open_cursor;
    dbms_sql.parse(x_cursor_id, x_sql_stm2, dbms_sql.v7);

    /* Fix for bug#4902938 */
    if ( x_group_id is not null ) then
      dbms_sql.bind_variable(x_cursor_id, ':l_group_id', x_group_id);
    end if;
    if ( to_char(p_org_id) is not null ) then
      dbms_sql.bind_variable(x_cursor_id, ':l_organization_id', to_char(p_org_id));
    end if;

    -- Bug 5129924
    -- Binding the values
    -- ntungare
    --
    if ( p_days_before_cutoff is not null ) then
      dbms_sql.bind_variable(x_cursor_id, ':l_from_date', x_from_date);
    end if;

    if ( p_cutoff_date is not null ) then
      dbms_sql.bind_variable(x_cursor_id, ':l_cutoff_date', p_cutoff_date);
    end if;
    /* END Fix for bug#4902938 */

    if ( p_line_id is not null ) then
      dbms_sql.bind_variable(x_cursor_id, ':l_line_id', p_line_id);
    end if;
    if ( p_primary_item_id is not null ) then
      dbms_sql.bind_variable(x_cursor_id, ':l_primary_item_id', p_primary_item_id);
    end if;

    x_num_rows := dbms_sql.execute(x_cursor_id);
    dbms_sql.close_cursor(x_cursor_id);


    end if;

    -- write changes
    commit;

    -- get count
    select count(group_id)
    into   x_count
    from wip_purge_temp
    where group_id = x_group_id;

    -- if nothing was found then return a 0
    if (x_count = 0) then
      x_group := x_count;
    else
      x_group := x_group_id ;
    end if;

    return(x_group);

  exception
    when others then
      p_err_num := SQLCODE;
      p_error_text := SUBSTR(SQLERRM, 1, 500);
      rollback;
      return(-1);
  end find;

  -- Bug 5129924
  -- Added a new parameter
  -- p_days_before_cutoff
  -- ntungare
  --
  function purge(
    p_purge_type      in number,
    p_group_id        in number,
    p_org_id          in number,
    p_cutoff_date     in date,
    p_days_before_cutoff in number,
    p_from_job        in varchar2,
    p_to_job          in varchar2,
    p_primary_item_id in number,
    p_line_id         in number,
    p_option          in number default NULL,
    p_conf_flag       in boolean default NULL,
    p_header_flag     in boolean default NULL,
    p_detail_flag     in boolean default NULL,
    p_move_trx_flag   in boolean default NULL,
    p_cost_trx_flag   in boolean default NULL,
    p_err_num         in out NOCOPY number,
    p_error_text      in out NOCOPY varchar2
    ) return number is

    x_dummy number;
    x_group_id      number;
    x_found         boolean;
    x_sched_move_txn_flag boolean := FALSE;
    x_sched_txn_flag boolean := FALSE;
    x_purge_request get_purge_requests%rowtype;

    x_ret_success varchar2(1)  := FND_API.G_RET_STS_SUCCESS ;
    x_commit_count number := 0 ;
  begin
    -- this procedure performs periodic commits to prevent rollback segments
    -- from filling up
    -- Bug 2413526 -- introduced a batch commit counter so that commit
    -- occurs every 100 th record.This reduces rollback segment error

    -- use passed in group ID or generate one after finding
    -- Bug 5129924
    -- Passing the parameter p_days_before_cutoff
    -- to the find function
    -- ntungare
    --
    if (p_group_id is NULL) then
      x_group_id := find(p_purge_type      => p_purge_type,
                         p_conf_flag       => nvl(p_conf_flag,FALSE),
                         p_org_id          => p_org_id,
                         p_cutoff_date     => p_cutoff_date,
			 p_days_before_cutoff => p_days_before_cutoff,
                         p_from_job        => p_from_job,
                         p_to_job          => p_to_job,
                         p_primary_item_id => p_primary_item_id,
                         p_line_id         => p_line_id,
                         p_err_num         => p_err_num,
                         p_error_text      => p_error_text );

       -- return 0 if no data found
       if (x_group_id <= 0) then
         return(x_group_id);
       end if ;

     else
         x_group_id := p_group_id;
     end if;

      open get_purge_requests(
        c_purge_type => p_purge_type,
        c_group_id   => x_group_id);
       x_commit_count := 0;
      loop
        fetch get_purge_requests into x_purge_request;

        x_found := get_purge_requests%FOUND;

        -- break out if no more jobs
        exit when (not x_found);
        x_commit_count := x_commit_count + 1;
        if ((p_purge_type = PURGE_LOTBASED) OR (p_purge_type = PURGE_ALL)) then
           -- Call OSFM API To Delete OSFM specific tables
           WSM_JobPurge_GRP.delete_osfm_tables(
                           p_option        => p_option,
                           p_group_id      => x_group_id,
                           p_purge_request => x_purge_request,
                           --Bug#4918553 - Passing detail_flag to OSFM
                           p_detail_flag   => nvl(p_detail_flag, false),
                           p_return_status => x_ret_success
                           );
        end if ;

       if (x_ret_success = FND_API.G_RET_STS_SUCCESS)  then
          /* OSFM API returns success status to continue .
             For other purge_type it is defaulted to success
           */

        -- delete the job details
        if (nvl(p_detail_flag,FALSE)) then
          -- For Jobs
          if ( (p_purge_type in (PURGE_JOBS, PURGE_LOTBASED)) or
               ( (p_purge_type = PURGE_ALL) and (x_purge_request.line_id is NULL) ) ) then
                delete_job_details(
                 p_option        => nvl(p_option,REPORT_ONLY),
                 p_group_id      => x_group_id,
                 p_purge_request => x_purge_request);
          else
          -- For Repetitive Schedules
                delete_sched_details(
                 p_option        => nvl(p_option,REPORT_ONLY),
                 p_group_id      => x_group_id,
                 p_purge_request => x_purge_request);

         end if;

        end if;


        -- delete the move transactions
        if (nvl(p_move_trx_flag,FALSE)) then
          -- For Jobs
          if ( (p_purge_type in (PURGE_JOBS, PURGE_LOTBASED)) or
               ( (p_purge_type = PURGE_ALL) and (x_purge_request.line_id is NULL) ) ) then
                delete_job_move_trx(
                 p_option        => nvl(p_option,REPORT_ONLY),
                 p_group_id      => x_group_id,
                 p_purge_request => x_purge_request);
          else
          -- For Repetitive Schedules
                delete_sched_move_trx(
                 p_option        => nvl(p_option,REPORT_ONLY),
                 p_group_id      => x_group_id,
                 p_purge_request => x_purge_request,
                 p_cutoff_date   => p_cutoff_date,
                 p_sched_move_txn_flag => x_sched_move_txn_flag );
          end if;

        end if;

        -- delete the resource transactions
        if (nvl(p_cost_trx_flag,FALSE))  then
          -- For Jobs
          if ( (p_purge_type in (PURGE_JOBS, PURGE_LOTBASED)) or
               ( (p_purge_type = PURGE_ALL) and (x_purge_request.line_id is NULL) ) ) then
                delete_job_cost_trx(
                 p_option        => nvl(p_option,REPORT_ONLY),
                 p_group_id      => x_group_id,
            	 p_purge_request => x_purge_request,
                 p_cut_off_date  => p_cutoff_date);
          else
          -- For Repetitive Schedules
                delete_sched_cost_trx(
                 p_option        => nvl(p_option,REPORT_ONLY),
                 p_group_id      => x_group_id,
                 p_purge_request => x_purge_request,
                 p_cutoff_date   => p_cutoff_date,
                 p_sched_txn_flag => x_sched_txn_flag  );
          end if;

        end if;

        -- delete the job header
        if (nvl(p_header_flag,FALSE)) then
          -- For Jobs
          if ( (p_purge_type = PURGE_JOBS) or
               ( (p_purge_type = PURGE_ALL) and (x_purge_request.line_id is NULL)
                  and (x_purge_request.entity_type <> WIP_CONSTANTS.CLOSED_OSFM)) ) then
                delete_job_header(
                 p_option        => nvl(p_option,REPORT_ONLY),
                 p_group_id      => x_group_id,
                 p_purge_request => x_purge_request);
          elsif (p_purge_type = PURGE_SCHEDS) then
          -- For Repetitive Schedules
                delete_sched_header(
                 p_option        => nvl(p_option,REPORT_ONLY),
                 p_group_id      => x_group_id,
                 p_purge_request => x_purge_request,
                 p_sched_move_txn_flag => x_sched_move_txn_flag,
                 p_sched_txn_flag => x_sched_txn_flag  );

          end if;

        end if;

      end if ; /* If l_ret_sucess */
      if (x_commit_count = 100 ) then
        commit ;
        x_commit_count := 0 ;
      end if ;
      end loop;
      commit;
      close get_purge_requests;

    -- delete the records sitting in the WIP_PURGE_TEMP table
   delete_purge_temp_table(x_group_id);
   return (x_group_id);

  exception
    when others then
      p_err_num := SQLCODE;
      p_error_text := SUBSTR(SQLERRM, 1, 500);

      if get_purge_requests%ISOPEN then
         close get_purge_requests ;
      end if ;

      rollback;
      return(-1);


  end purge;

end wip_wictpg;

/
