--------------------------------------------------------
--  DDL for Package Body WSM_JOBPURGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSM_JOBPURGE_GRP" AS
/* $Header: WSMPLBJB.pls 120.1 2005/12/30 05:37:57 sthangad noship $ */

/*===========================================================================

  PROCEDURE NAME:   delete_osfm_tables

===========================================================================*/


procedure append_report(
                        p_rec           in wip_wictpg.purge_report_type,
                        p_option        in number
                        )
is
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

procedure before_append_report(
                               p_option           in number,
                               p_purge_rec        in wip_wictpg.purge_report_type,
                               num_rows           in number
                               )
is
   x_purge_rec         wip_wictpg.purge_report_type;
begin

      fnd_message.set_name('WIP', 'WIP_PURGE_ROWS');
      fnd_message.set_token('NUMBER', to_char(num_rows));
      x_purge_rec := p_purge_rec;
      x_purge_rec.info := fnd_message.get;
      append_report(x_purge_rec,p_option);

end before_append_report;

-- delete WIE which is referenced by WSM interface table on header_id
procedure delete_wie (
                      p_option        in number,
                      p_header_id     in number,
                      p_request_id    in number,
                      p_wie_num_rows  out NOCOPY number,
                      p_err_num       in out NOCOPY number,
                      p_err_buf       in out NOCOPY varchar2
                      )
is
begin
      if (p_option = REPORT_ONLY) then
         select  count(*)
           into  p_wie_num_rows
           from  WSM_INTERFACE_ERRORS
           where header_id = p_header_id
           and   request_id = nvl(p_request_id, -1);
       else
         DELETE FROM WSM_INTERFACE_ERRORS
           WHERE header_id = p_header_id
           and   request_id = nvl(p_request_id, -1);
         p_wie_num_rows := SQL%ROWCOUNT;
      end if;

exception
   when others then
      p_err_num := SQLCODE;
      p_err_buf:= SUBSTR(SQLERRM, 1, 500);

end delete_wie;


procedure delete_osfm_tables(
                              p_option        in number,
                              p_group_id      in number,
                              p_purge_request in wip_wictpg.get_purge_requests%rowtype,
                              -- ST Fix for bug 4918553 (Added the parameter p_detail_flag)
                              p_detail_flag   IN BOOLEAN DEFAULT TRUE,
                              p_return_status out NOCOPY varchar2
                              )
is
   x_num_rows        number := 0;
   x_tmp_num_rows    number := 0;
   x_wie_rows        number := 0;
   x_wsmti_rows      number := 0;
   x_wsji_rows       number := 0;
   x_wrji_rows       number := 0;
   x_purge_rec       wip_wictpg.purge_report_type;
   x_wip_entity_name VARCHAR2(240);
   x_entity_type     number;
   x_header_id       NUMBER;
   x_request_id      NUMBER;
   p_err_num         number;
   p_err_buf         varchar2(500);
   e_delete_wie_exception      EXCEPTION;

   -- Bug 4722718 : Purge R12 table information as well..
   l_serial_intf_rows   NUMBER := 0;

   cursor get_purge_wtxnis (pEntityName VARCHAR2, pWipEntityId NUMBER, pOrgId NUMBER) is
     select wtxni.header_id, wtxni.request_id
     from wsm_split_merge_txn_interface wtxni
     where wtxni.organization_id = pOrgId
     and   wtxni.header_id in  (
                   select sj.header_id
                   from wsm_starting_jobs_interface sj
                   where  sj.wip_entity_id = pWipEntityId
                   union
                   select rj.header_id
                   from wsm_resulting_jobs_interface rj
                   where  rj.wip_entity_name = pEntityName
                   );

   -- get header_ids of purge job in wlji

   cursor get_purge_wlji (pEntityName VARCHAR2, pOrgId NUMBER) is
      select  wlji.header_id, wlji.request_id
        from  WSM_LOT_JOB_INTERFACE wlji
        where wlji.job_name = pEntityName
        and   wlji.organization_id = pOrgId;


   cursor get_purge_wlmti (pWipEntityId NUMBER, pOrgId NUMBER) is
      select  wlmti.header_id, wlmti.request_id
        from  WSM_LOT_MOVE_TXN_INTERFACE wlmti
        where wlmti.wip_entity_id = pWipEntityId
        and   wlmti.organization_id = pOrgId;

begin

   SAVEPOINT osfm_tables;

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
   x_entity_type               := p_purge_request.entity_type;

   if x_entity_type not in (5,8) then
      p_return_status := FND_API.G_RET_STS_SUCCESS;
      return;
   end if;


   open get_purge_wtxnis (x_purge_rec.entity_name, x_purge_rec.wip_entity_id, x_purge_rec.org_id);

   loop
      FETCH get_purge_wtxnis into x_header_id, x_request_id;
      EXIT when get_purge_wtxnis%NOTFOUND;

      delete_wie(
                 p_option       => p_option,
                 p_header_id    => x_header_id,
                 p_request_id   => x_request_id,
                 p_wie_num_rows => x_tmp_num_rows,
                 p_err_num      => p_err_num,
                 p_err_buf      => p_err_buf
                 );
      if p_err_num <> 0 then
         x_purge_rec.info := p_err_buf;
         raise e_delete_wie_exception;
      end if;

      x_wie_rows := x_tmp_num_rows + x_wie_rows;

      if (p_option = REPORT_ONLY) then
         select  count(*)
           into  x_tmp_num_rows
           from  WSM_STARTING_JOBS_INTERFACE
           where header_id = x_header_id;
       else

         DELETE FROM WSM_STARTING_JOBS_INTERFACE
           WHERE  header_id = x_header_id;
         x_tmp_num_rows := SQL%ROWCOUNT;

      end if;

      x_wsji_rows := x_tmp_num_rows + x_wsji_rows;

      if (p_option = REPORT_ONLY) then
         select  count(*)
           into  x_tmp_num_rows
           from  WSM_RESULTING_JOBS_INTERFACE
           where header_id = x_header_id;
       else

         DELETE FROM WSM_RESULTING_JOBS_INTERFACE
           WHERE  header_id = x_header_id;
         x_tmp_num_rows := SQL%ROWCOUNT;

      end if;

      x_wrji_rows := x_tmp_num_rows + x_wrji_rows;

      if (p_option = REPORT_ONLY) then
         select  count(*)
           into  x_tmp_num_rows
           from  WSM_SPLIT_MERGE_TXN_INTERFACE
           where header_id = x_header_id;
       else

         DELETE FROM WSM_SPLIT_MERGE_TXN_INTERFACE
           WHERE  header_id = x_header_id;
         x_tmp_num_rows := SQL%ROWCOUNT;

      end if;

      x_wsmti_rows := x_tmp_num_rows + x_wsmti_rows;

      -- Bug 4722718 : Purge the Serial txn interface rows as well...
      IF (p_option = REPORT_ONLY) THEN
                SELECT  count(*)
                INTO  x_tmp_num_rows
                FROM  WSM_SERIAL_TXN_INTERFACE
                WHERE header_id = x_header_id
                AND   transaction_type_id = 3;
      ELSE
                DELETE FROM WSM_SERIAL_TXN_INTERFACE
                WHERE  header_id = x_header_id
                AND    transaction_type_id = 3;
                x_tmp_num_rows := SQL%ROWCOUNT;
      END IF;
      l_serial_intf_rows := l_serial_intf_rows + x_tmp_num_rows;
      -- Bug 4722718 : End

   end loop;

   close get_purge_wtxnis;

   if x_wie_rows > 0 then

      x_purge_rec.table_name := 'WSM_INTERFACE_ERRORS';

      before_append_report(
                           p_option           => p_option,
                           p_purge_rec        => x_purge_rec,
                           num_rows           => x_wie_rows);
      x_wie_rows := 0;
   end if;

   if x_wsji_rows > 0 then

      x_purge_rec.table_name := 'WSM_STARTING_JOBS_INTERFACE';

      before_append_report(
                           p_option           => p_option,
                           p_purge_rec        => x_purge_rec,
                           num_rows           => x_wsji_rows);
      x_wsji_rows := 0;
   end if;

   if x_wrji_rows > 0 then

      x_purge_rec.table_name := 'WSM_RESULTING_JOBS_INTERFACE';

      before_append_report(
                           p_option           => p_option,
                           p_purge_rec        => x_purge_rec,
                           num_rows           => x_wrji_rows);
      x_wrji_rows := 0;
   end if;

   if x_wsmti_rows > 0 then

      x_purge_rec.table_name := 'WSM_SPLIT_MERGE_TXN_INTERFACE';

         before_append_report(
                              p_option           => p_option,
                              p_purge_rec        => x_purge_rec,
                              num_rows           => x_wsmti_rows);
         x_wsmti_rows := 0;
   end if;

   -- WIE ref WSM_LOT_JOB_INTERFACE
   -- before delete wlji, purge WIE first
   open get_purge_wlji (x_purge_rec.entity_name, x_purge_rec.org_id);

   loop
      FETCH get_purge_wlji into x_header_id, x_request_id;
      EXIT when get_purge_wlji%NOTFOUND;

      x_purge_rec.table_name := 'WSM_INTERFACE_ERRORS';

      delete_wie(
                 p_option       => p_option,
                 p_header_id    => x_header_id,
                 p_request_id   => x_request_id,
                 p_wie_num_rows => x_tmp_num_rows,
                 p_err_num      => p_err_num,
                 p_err_buf      => p_err_buf
                 );
      if p_err_num <> 0 then
         x_purge_rec.info := p_err_buf;
         raise e_delete_wie_exception;
      end if;

      x_wie_rows := x_tmp_num_rows + x_wie_rows;

      -- Bug 4722718 : Purge the Serial txn interface rows as well...
      IF (p_option = REPORT_ONLY) THEN
                SELECT  count(*)
                INTO  x_tmp_num_rows
                FROM  WSM_SERIAL_TXN_INTERFACE
                WHERE header_id = x_header_id
                AND   transaction_type_id = 1;
      ELSE
                DELETE FROM WSM_SERIAL_TXN_INTERFACE
                WHERE  header_id = x_header_id
                AND    transaction_type_id = 1;
                x_tmp_num_rows := SQL%ROWCOUNT;
      END IF;
      l_serial_intf_rows := l_serial_intf_rows + x_tmp_num_rows;
      -- Bug 4722718 : End

   end loop;
   close get_purge_wlji;

   if x_wie_rows > 0 then

      before_append_report(
                           p_option           => p_option,
                           p_purge_rec        => x_purge_rec,
                           num_rows           => x_wie_rows);
      x_wie_rows := 0;
   end if;

   x_purge_rec.table_name := 'WSM_LOT_JOB_INTERFACE';

   if (p_option = REPORT_ONLY) then
      select  count(*)
        into  x_num_rows
        from  WSM_LOT_JOB_INTERFACE
        where job_name = x_purge_rec.entity_name
        and   organization_id = x_purge_rec.org_id;
    else

      DELETE FROM WSM_LOT_JOB_INTERFACE
        WHERE job_name =  x_purge_rec.entity_name
        AND   organization_id = x_purge_rec.org_id;
      x_num_rows := SQL%ROWCOUNT;

   end if;

   if x_num_rows > 0 then
      before_append_report(
                           p_option           => p_option,
                           p_purge_rec        => x_purge_rec,
                           num_rows           => x_num_rows);
   end if;

   -- WIE ref WSM_LOT_MOVE_TXN_INTERFACE

   x_wie_rows := 0;

   open get_purge_wlmti(x_purge_rec.wip_entity_id, x_purge_rec.org_id);

   loop
      FETCH get_purge_wlmti into x_header_id, x_request_id;
      EXIT when get_purge_wlmti%NOTFOUND;

      x_purge_rec.table_name := 'WSM_INTERFACE_ERRORS';

      delete_wie(
                 p_option       => p_option,
                 p_header_id    => x_header_id,
                 p_request_id   => x_request_id,
                 p_wie_num_rows => x_tmp_num_rows,
                 p_err_num      => p_err_num,
                 p_err_buf      => p_err_buf
                 );
      if p_err_num <> 0 then
         x_purge_rec.info := p_err_buf;
         raise e_delete_wie_exception;
      end if;

      x_wie_rows := x_tmp_num_rows + x_wie_rows;

      -- Bug 4722718 : Purge the Serial txn interface rows as well...
      IF (p_option = REPORT_ONLY) THEN
                SELECT  count(*)
                INTO  x_tmp_num_rows
                FROM  WSM_SERIAL_TXN_INTERFACE
                WHERE header_id = x_header_id
                AND   transaction_type_id = 2;
      ELSE
                DELETE FROM WSM_SERIAL_TXN_INTERFACE
                WHERE  header_id = x_header_id
                AND    transaction_type_id = 2;

                x_tmp_num_rows := SQL%ROWCOUNT;
      END IF;
      l_serial_intf_rows := l_serial_intf_rows + x_tmp_num_rows;
      -- Bug 4722718 : End

   end loop;
   close get_purge_wlmti;

   if x_wie_rows > 0 then

      before_append_report(
                           p_option           => p_option,
                           p_purge_rec        => x_purge_rec,
                           num_rows           => x_wie_rows);
      x_wie_rows := 0;
   end if;

   x_purge_rec.table_name := 'WSM_LOT_MOVE_TXN_INTERFACE';

   if (p_option = REPORT_ONLY) then
      select  count(*)
        into  x_num_rows
        from  WSM_LOT_MOVE_TXN_INTERFACE
        where wip_entity_id = x_purge_rec.wip_entity_id;

    else

      DELETE FROM WSM_LOT_MOVE_TXN_INTERFACE
        WHERE  wip_entity_id = x_purge_rec.wip_entity_id;
      x_num_rows := SQL%ROWCOUNT;

   end if;

   if x_num_rows > 0 then
      before_append_report(
                           p_option           => p_option,
                           p_purge_rec        => x_purge_rec,
                           num_rows           => x_num_rows);
   end if;

   -- Bug 4722718 : Start
   x_purge_rec.table_name := 'WSM_SERIAL_TXN_INTERFACE';
   IF l_serial_intf_rows > 0 THEN
        before_append_report( p_option           => p_option,
                              p_purge_rec        => x_purge_rec,
                              num_rows           => l_serial_intf_rows);
   END IF;

   x_purge_rec.table_name := 'WSM_RESERVATIONS';
   IF (p_option = REPORT_ONLY) THEN
        SELECT  COUNT(*)
        INTO  x_num_rows
        FROM  WSM_RESERVATIONS
        WHERE wip_entity_id = x_purge_rec.wip_entity_id;
   ELSE
        DELETE FROM WSM_RESERVATIONS
        WHERE  wip_entity_id = x_purge_rec.wip_entity_id;
        x_num_rows := SQL%ROWCOUNT;
   END IF;

   IF x_num_rows > 0 THEN
      before_append_report( p_option           => p_option,
                            p_purge_rec        => x_purge_rec,
                            num_rows           => x_num_rows
                          );
   END IF;

   -- IF Clause added for Bug 4918553
   -- Delete the data from the below tables only if the detail flag is set..
   IF p_detail_flag THEN
           x_purge_rec.table_name := 'WSM_OP_REASON_CODES';
           IF (p_option = REPORT_ONLY) THEN
                SELECT  COUNT(*)
                INTO  x_num_rows
                FROM  WSM_OP_REASON_CODES
                WHERE wip_entity_id = x_purge_rec.wip_entity_id;
           ELSE
                DELETE FROM WSM_OP_REASON_CODES
                WHERE  wip_entity_id = x_purge_rec.wip_entity_id;
                x_num_rows := SQL%ROWCOUNT;
           END IF;

           IF x_num_rows > 0 THEN
              before_append_report( p_option           => p_option,
                                    p_purge_rec        => x_purge_rec,
                                    num_rows           => x_num_rows
                                  );
           END IF;

           x_purge_rec.table_name := 'WSM_OP_SECONDARY_QUANTITIES';
           IF (p_option = REPORT_ONLY) THEN
                SELECT  COUNT(*)
                INTO  x_num_rows
                FROM  WSM_OP_SECONDARY_QUANTITIES
                WHERE wip_entity_id = x_purge_rec.wip_entity_id;
           ELSE
                DELETE FROM WSM_OP_SECONDARY_QUANTITIES
                WHERE  wip_entity_id = x_purge_rec.wip_entity_id;
                x_num_rows := SQL%ROWCOUNT;
           END IF;

           IF x_num_rows > 0 THEN
              before_append_report( p_option           => p_option,
                                    p_purge_rec        => x_purge_rec,
                                    num_rows           => x_num_rows
                                  );
           END IF;

           x_purge_rec.table_name := 'WIP_RESOURCE_ACTUAL_TIMES';
           IF (p_option = REPORT_ONLY) THEN
                SELECT  COUNT(*)
                INTO  x_num_rows
                FROM  WIP_RESOURCE_ACTUAL_TIMES
                WHERE wip_entity_id = x_purge_rec.wip_entity_id;
           ELSE
                DELETE FROM WIP_RESOURCE_ACTUAL_TIMES
                WHERE  wip_entity_id = x_purge_rec.wip_entity_id;
                x_num_rows := SQL%ROWCOUNT;
           END IF;

           IF x_num_rows > 0 THEN
              before_append_report( p_option           => p_option,
                                    p_purge_rec        => x_purge_rec,
                                    num_rows           => x_num_rows
                                  );
           END IF;

           x_purge_rec.table_name := 'WSM_JOB_SECONDARY_QUANTITIES';
           IF (p_option = REPORT_ONLY) THEN
                SELECT  COUNT(*)
                INTO  x_num_rows
                FROM  WSM_JOB_SECONDARY_QUANTITIES
                WHERE wip_entity_id = x_purge_rec.wip_entity_id;
           ELSE
                DELETE FROM WSM_JOB_SECONDARY_QUANTITIES
                WHERE  wip_entity_id = x_purge_rec.wip_entity_id;
                x_num_rows := SQL%ROWCOUNT;
           END IF;

           IF x_num_rows > 0 THEN
              before_append_report( p_option           => p_option,
                                    p_purge_rec        => x_purge_rec,
                                    num_rows           => x_num_rows
                                  );
           END IF;
           -- Bug 4722718 : End

           x_purge_rec.table_name := 'WIP_OPERATION_YIELDS';

           if (p_option = REPORT_ONLY) then
              select  count(*)
                into  x_num_rows
                from  WIP_OPERATION_YIELDS
                where wip_entity_id = x_purge_rec.wip_entity_id;

            else

              DELETE FROM WIP_OPERATION_YIELDS
                WHERE  wip_entity_id = x_purge_rec.wip_entity_id;
              x_num_rows := SQL%ROWCOUNT;

           end if;

           if x_num_rows > 0 then
              before_append_report(
                                   p_option           => p_option,
                                   p_purge_rec        => x_purge_rec,
                                   num_rows           => x_num_rows);
           end if;
   END IF;
   -- IF Clause added for Bug 4918553

   x_purge_rec.table_name := 'WSM_COPY_OPERATIONS';

   if (p_option = REPORT_ONLY) then
      select  count(*)
        into  x_num_rows
        from  WSM_COPY_OPERATIONS
        where wip_entity_id = x_purge_rec.wip_entity_id;

    else

      DELETE FROM WSM_COPY_OPERATIONS
        WHERE  wip_entity_id = x_purge_rec.wip_entity_id;
      x_num_rows := SQL%ROWCOUNT;

   end if;

   if x_num_rows > 0 then
      before_append_report(
                           p_option           => p_option,
                           p_purge_rec        => x_purge_rec,
                           num_rows           => x_num_rows);
   end if;

   x_purge_rec.table_name := 'WSM_COPY_OP_NETWORKS';

   if (p_option = REPORT_ONLY) then
      select  count(*)
        into  x_num_rows
        from  WSM_COPY_OP_NETWORKS
        where wip_entity_id = x_purge_rec.wip_entity_id;

    else

      DELETE FROM WSM_COPY_OP_NETWORKS
        WHERE  wip_entity_id = x_purge_rec.wip_entity_id;
      x_num_rows := SQL%ROWCOUNT;

   end if;

   if x_num_rows > 0 then
      before_append_report(
                           p_option           => p_option,
                           p_purge_rec        => x_purge_rec,
                           num_rows           => x_num_rows);
   end if;

   x_purge_rec.table_name := 'WSM_COPY_OP_RESOURCES';

   if (p_option = REPORT_ONLY) then
      select  count(*)
        into  x_num_rows
        from  WSM_COPY_OP_RESOURCES
        where wip_entity_id = x_purge_rec.wip_entity_id;

    else

      DELETE FROM WSM_COPY_OP_RESOURCES
        WHERE  wip_entity_id = x_purge_rec.wip_entity_id;
      x_num_rows := SQL%ROWCOUNT;

   end if;

   if x_num_rows > 0 then
      before_append_report(
                           p_option           => p_option,
                           p_purge_rec        => x_purge_rec,
                           num_rows           => x_num_rows);
   end if;

   x_purge_rec.table_name := 'WSM_COPY_OP_RESOURCE_INSTANCES';

   if (p_option = REPORT_ONLY) then
      select  count(*)
        into  x_num_rows
        from  WSM_COPY_OP_RESOURCE_INSTANCES
        where wip_entity_id = x_purge_rec.wip_entity_id;

    else

      DELETE FROM WSM_COPY_OP_RESOURCE_INSTANCES
        WHERE  wip_entity_id = x_purge_rec.wip_entity_id;
      x_num_rows := SQL%ROWCOUNT;

   end if;

   if x_num_rows > 0 then
      before_append_report(
                           p_option           => p_option,
                           p_purge_rec        => x_purge_rec,
                           num_rows           => x_num_rows);
   end if;


   x_purge_rec.table_name := 'WSM_COPY_OP_RESOURCE_USAGE';

   if (p_option = REPORT_ONLY) then
      select  count(*)
        into  x_num_rows
        from  WSM_COPY_OP_RESOURCE_USAGE
        where wip_entity_id = x_purge_rec.wip_entity_id;

    else

      DELETE FROM WSM_COPY_OP_RESOURCE_USAGE
        WHERE  wip_entity_id = x_purge_rec.wip_entity_id;
      x_num_rows := SQL%ROWCOUNT;

   end if;

   if x_num_rows > 0 then
      before_append_report(
                           p_option           => p_option,
                           p_purge_rec        => x_purge_rec,
                           num_rows           => x_num_rows);
   end if;


   x_purge_rec.table_name := 'WSM_COPY_REQUIREMENT_OPS';

   if (p_option = REPORT_ONLY) then
      select  count(*)
        into  x_num_rows
        from  WSM_COPY_REQUIREMENT_OPS
        where wip_entity_id = x_purge_rec.wip_entity_id;

    else

      DELETE FROM WSM_COPY_REQUIREMENT_OPS
        WHERE  wip_entity_id = x_purge_rec.wip_entity_id;
      x_num_rows := SQL%ROWCOUNT;

   end if;

   if x_num_rows > 0 then
      before_append_report(
                           p_option           => p_option,
                           p_purge_rec        => x_purge_rec,
                           num_rows           => x_num_rows);
   end if;


   -- WSM_LOT_BASED_OPERATIONS attachment
   if (p_Option <> REPORT_ONLY) then
        FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments(
                X_entity_name => 'WSM_LOT_BASED_OPERATIONS',
                X_pk1_value => to_char(x_purge_rec.wip_entity_id),
                X_pk2_value => to_char(x_purge_rec.org_id),
                X_delete_document_flag => 'Y' );
   end if ;
   p_return_status := FND_API.G_RET_STS_SUCCESS;
exception
   when e_delete_wie_exception then
      append_report(x_purge_rec, p_option);
      rollback to osfm_tables;
      p_return_status := FND_API.G_RET_STS_ERROR;
   when others then
      p_err_num := SQLCODE;
      x_purge_rec.info := SUBSTR(SQLERRM, 1, 500);
      append_report(x_purge_rec, p_option);
      rollback to osfm_tables;
      p_return_status := FND_API.G_RET_STS_ERROR;

end delete_osfm_tables;

END WSM_JobPurge_GRP;

/
