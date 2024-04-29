--------------------------------------------------------
--  DDL for Package Body IEU_UWQ_GET_NEXT_WORK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_UWQ_GET_NEXT_WORK_PVT" AS
/* $Header: IEUVGNWB.pls 120.3 2006/03/08 22:40:21 msathyan noship $ */

-- SORT NOT DONE BY WORKITEM OBJECT CODE SO IT WAS REMOVED FROM THE ORDER BY CLAUSE (DEC-06-2001) - ckurian

 resource_busy_nowait EXCEPTION;
 PRAGMA EXCEPTION_INIT(resource_busy_nowait, -54);

 l_dist_deliver_num_of_attempts  NUMBER;

 PROCEDURE GET_NEXT_WORKITEM
 ( p_api_version           IN  NUMBER,
   p_resource_id           IN  NUMBER,
   p_user_id               IN  NUMBER,
   x_uwqm_workitem_data    OUT NOCOPY IEU_FRM_PVT.T_IEU_MEDIA_DATA,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   x_return_status         OUT NOCOPY VARCHAR2)
 IS

BEGIN

   null;

END GET_NEXT_WORKITEM;

PROCEDURE GET_WORKITEM_ACTION_FUNC_DATA
 ( p_workitem_data         IN IEU_UWQ_GET_NEXT_WORK_PVT.ieu_uwqm_item_data_rec,
   x_workitem_action_data OUT NOCOPY IEU_FRM_PVT.T_IEU_MEDIA_DATA )
AS


BEGIN

	null;

END GET_WORKITEM_ACTION_FUNC_DATA;


PROCEDURE GET_NEXT_WORK_ITEM_CONT
 (p_release_api_version   IN NUMBER,
  p_next_work_api_version IN NUMBER,
  p_workitem_obj_code     IN VARCHAR2,
  p_workitem_pk_id        IN NUMBER,
  p_work_item_id          IN NUMBER,
  p_user_id               IN NUMBER,
  p_resource_id           IN NUMBER,
  p_worklist_cont_mode    IN VARCHAR2,
  x_uwqm_workitem_data    OUT NOCOPY IEU_FRM_PVT.T_IEU_MEDIA_DATA,
  x_release_return_status OUT NOCOPY VARCHAR2,
  x_release_msg_count     OUT NOCOPY NUMBER,
  x_release_msg_data      OUT NOCOPY VARCHAR2,
  x_nw_return_status      OUT NOCOPY VARCHAR2,
  x_nw_msg_count          OUT NOCOPY NUMBER,
  x_nw_msg_data           OUT NOCOPY VARCHAR2)
 IS

 l_status_id              NUMBER;
 l_source_object_id       NUMBER;
 l_source_obj_type_code   VARCHAR2(30);
 L_SOURCEOBJ_WORKITEM_ID  NUMBER;

BEGIN
null;
/*
  IF ( (p_work_item_id is not null) OR
       ( (p_workitem_pk_id is not null) AND (p_workitem_obj_code is not null) )
     )
  THEN

      BEGIN

        IF (p_work_item_id is not null)
        THEN

          SELECT status_id, source_object_id, source_object_type_code
          INTO   l_status_id, l_source_object_id, l_source_obj_type_code
          FROM   ieu_uwqm_items
          WHERE  work_item_id = p_work_item_id;

        ELSE

          SELECT status_id, source_object_id, source_object_type_code
          INTO   l_status_id, l_source_object_id, l_source_obj_type_code
          FROM   ieu_uwqm_items
          WHERE  workitem_pk_id = p_workitem_pk_id
          AND    workitem_obj_code = p_workitem_obj_code;

        END IF;

      EXCEPTION
       WHEN NO_DATA_FOUND THEN
         NULL;
      END;

      IF (l_status_id = 1)
      THEN

         -- Release Work Item

         IEU_UWQM_PUB.RELEASE_UWQM_ITEM
         ( p_api_version        => p_release_api_version,
           p_init_msg_list      => 'T',
           p_commit             => 'T',
           p_workitem_obj_code  => p_workitem_obj_code,
           p_workitem_pk_id     => p_workitem_pk_id,
           p_work_item_id       => p_work_item_id,
           p_user_id            => p_user_id,
           p_login_id           => null,
           x_msg_count          => x_release_msg_count,
           x_msg_data           => x_release_msg_data,
           x_return_status      => x_release_return_status);


         -- Release source_doc_id

/*         SELECT WORK_ITEM_ID
         INTO   L_SOURCEOBJ_WORKITEM_ID
         FROM   IEU_UWQM_ITEMS
         WHERE  (WORKITEM_PK_ID, WORKITEM_OBJ_CODE) IN
             (SELECT SOURCE_OBJECT_ID, SOURCE_OBJECT_TYPE_CODE
              FROM IEU_UWQM_ITEMS
              WHERE ( (WORK_ITEM_ID = P_WORK_ITEM_ID) OR
                       ( (WORKITEM_PK_ID = P_WORKITEM_PK_ID) AND (WORKITEM_OBJ_CODE = P_WORKITEM_OBJ_CODE) )
                    )
             );
*/
/*
         SELECT WORK_ITEM_ID
         INTO   L_SOURCEOBJ_WORKITEM_ID
         FROM   IEU_UWQM_ITEMS
         WHERE  WORKITEM_PK_ID = l_source_object_id
         AND    WORKITEM_OBJ_CODE = l_source_obj_type_code;

         IF (L_SOURCEOBJ_WORKITEM_ID is not null)
         THEN

            IEU_UWQM_PUB.RELEASE_UWQM_ITEM
            ( p_api_version        => p_release_api_version,
              p_init_msg_list      => 'T',
              p_commit             => 'T',
              p_workitem_obj_code  => null,
              p_workitem_pk_id     => null,
              p_work_item_id       => L_SOURCEOBJ_WORKITEM_ID,
              p_user_id            => p_user_id,
              p_login_id           => null,
              x_msg_count          => x_release_msg_count,
              x_msg_data           => x_release_msg_data,
              x_return_status      => x_release_return_status);

         END IF;
*/
/*
      END IF;

   END IF;

   IF (p_worklist_cont_mode = 'TRUE')
   THEN

      IEU_UWQ_GET_NEXT_WORK_PVT.GET_NEXT_WORKITEM
      ( p_api_version        => p_next_work_api_version,
        p_resource_id        => p_resource_id,
        p_user_id            => p_user_id,
        x_uwqm_workitem_data => x_uwqm_workitem_data,
        x_msg_count          => x_nw_msg_count,
        x_msg_data           => x_nw_msg_data,
        x_return_status      => x_nw_return_status);

   END IF;
*/
END  GET_NEXT_WORK_ITEM_CONT;

PROCEDURE GET_WORKLIST_QUEUE
 ( p_api_version           IN  NUMBER,
   p_resource_id           IN  NUMBER,
   p_user_id               IN  NUMBER,
   p_no_of_recs            IN  NUMBER,
   x_uwqm_workitem_data    OUT NOCOPY IEU_UWQ_GET_NEXT_WORK_PVT.ieu_uwqm_item_data,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   x_return_status         OUT NOCOPY VARCHAR2)
 IS

  -- Used to Validate API version and name
  l_api_version        CONSTANT NUMBER        := 1.0;
  l_api_name           CONSTANT VARCHAR2(30)  := 'GET_WORKLIST_QUEUE';

  -- Used for Time Analysis
  t1           NUMBER;  -- start time
  t2           NUMBER;  -- end time
  l_time_spent NUMBER;  -- time elapsed

  -- Used to get Workitems based on Individual/Group Ownership/Asssignment

  l_ind_own_work_item_id     number(15);
  l_ind_asg_work_item_id     number(15);
  l_grp_own_work_item_id     number(15);
  l_grp_asg_work_item_id     number(15);

  -- Used for sorting

  l_work_item_id        number(15);
  l_priority_level      number(1);
  l_due_date            varchar2(30);
  l_workitem_obj_code   varchar2(30);

  l_work_item_id_1      number(15);
  l_priority_level_1    number(1);
  l_due_date_1          varchar2(30);
  l_workitem_obj_code_1 varchar2(30);

  -- Used for removing duplicate work item ids

  l_work_item_id_last   number(15);

  -- Used to get the group count

  l_grp_count  NUMBER;
  l_grp_id     NUMBER;

  res_code varchar2(30); -- Result Code

  -- status_flag
  l_open_status_id NUMBER := 0; -- Not In Use
  l_lock_status_id NUMBER := 1; -- Status 'L' - Locked by UWQ

  -- cursor to get Owned items
  l_next_ind_own_work    IEU_UWQ_GET_NEXT_WORK_PVT.l_get_work;
  l_next_grp_own_work_1  IEU_UWQ_GET_NEXT_WORK_PVT.l_get_work;
  l_next_grp_own_work_2  IEU_UWQ_GET_NEXT_WORK_PVT.l_get_work;

  -- cursor to get Assigned items
  l_next_ind_asg_work    IEU_UWQ_GET_NEXT_WORK_PVT.l_get_work;
  l_next_grp_asg_work_1  IEU_UWQ_GET_NEXT_WORK_PVT.l_get_work;
  l_next_grp_asg_work_2  IEU_UWQ_GET_NEXT_WORK_PVT.l_get_work;


  l_ind_own_no_data_found number := 0;
  l_grp1_own_no_data_found number := 0;
  l_grp2_own_no_data_found number := 0;

  l_ind_asg_no_data_found number := 0;
  l_grp1_asg_no_data_found number := 0;
  l_grp2_asg_no_data_found number := 0;

  l_ctr  PLS_INTEGER := 0;
  l_loop_ctr  PLS_INTEGER := 0;

  l_nw_item_list      IEU_UWQ_GET_NEXT_WORK_PVT.IEU_UWQ_NEXTWORK_ITEM_LIST;
  l_uwqm_item_data    IEU_UWQ_GET_NEXT_WORK_PVT.ieu_uwqm_item_data; -- := null;

  --- Values assigned for different work items ---

  l_owner_type_ind	varchar2(25);
  l_owner_type_grp  	varchar2(25);

begin

    l_owner_type_ind := 'RS_INDIVIDUAL';
    l_owner_type_grp := 'RS_GROUP';
    x_return_status := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
    THEN
         RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize Message list

    FND_MSG_PUB.INITIALIZE;

    t1 := DBMS_UTILITY.GET_TIME;

  ------ If no of records to be selected is not passed in the parameter
  ------ then select all records

    begin
         -------------- Individual Owned Work Items ----------1
         declare
           cursor c1 is
           select work_item_id, priority_level, to_char(due_date,'dd-mon-yyyy hh24:mi:ss') due_date,
                  workitem_obj_code
           from   ieu_uwqm_items
           where  owner_type =  l_owner_type_ind
           and    owner_id   =  p_resource_id
           and    status_id  in (0,1,2)
           and    reschedule_time <= sysdate
           order by priority_level, due_date;
         begin
              for c1_rec in c1 loop
                -- Update Work Item Rec
                l_nw_item_list(l_ctr).work_item_id      := c1_rec.work_item_id;
                l_nw_item_list(l_ctr).priority_level    := c1_rec.priority_level;
                l_nw_item_list(l_ctr).due_date          := c1_rec.due_date;
                l_nw_item_list(l_ctr).workitem_obj_code := c1_rec.workitem_obj_code;
                l_ctr := l_ctr + 1;
                if nvl(p_no_of_recs, 0) <= 0 then
                   exit when c1%notfound;
                elsif nvl(p_no_of_recs, 0) > 0 and c1%found then
                   if nvl(p_no_of_recs, 0) = c1%rowcount then
                      exit;
                   end if;
                else
                   exit;
                end if;
              end loop;
         end;

         -------------- Group Owned Work Items ----------2
         declare
           cursor c1 is
           select work_item_id, priority_level, to_char(due_date,'dd-mon-yyyy hh24:mi:ss') due_date,
                  workitem_obj_code
           from   ieu_uwqm_items
           where  owner_type = l_owner_type_grp
           and    owner_id  in (select group_id from jtf_rs_group_members where resource_id = p_resource_id)
           and    status_id in (0,1,2)
           and    reschedule_time <= sysdate
           order by priority_level, due_date;

         begin
              for c1_rec in c1 loop
                -- Update Work Item Rec
                l_nw_item_list(l_ctr).work_item_id      := c1_rec.work_item_id;
                l_nw_item_list(l_ctr).priority_level    := c1_rec.priority_level;
                l_nw_item_list(l_ctr).due_date          := c1_rec.due_date;
                l_nw_item_list(l_ctr).workitem_obj_code := c1_rec.workitem_obj_code;
                l_ctr := l_ctr + 1;
                if nvl(p_no_of_recs, 0) <= 0 then
                   exit when c1%notfound;
                elsif nvl(p_no_of_recs, 0) > 0 and c1%found then
                   if nvl(p_no_of_recs, 0) = c1%rowcount then
                      exit;
                   end if;
                else
                   exit;
                end if;
              end loop;
         end;

         -------------- Individual Assigned Work Items ----------3

         declare
           cursor c1 is
           select work_item_id, priority_level, to_char(due_date,'dd-mon-yyyy hh24:mi:ss') due_date,
                  workitem_obj_code
           from   ieu_uwqm_items
           where  assignee_type = l_owner_type_ind
           and    assignee_id   = p_resource_id
           and    status_id    in (0,1,2)
           and    reschedule_time <= sysdate
           order by priority_level, due_date;

         begin
              for c1_rec in c1 loop
                -- Update Work Item Rec
                l_nw_item_list(l_ctr).work_item_id      := c1_rec.work_item_id;
                l_nw_item_list(l_ctr).priority_level    := c1_rec.priority_level;
                l_nw_item_list(l_ctr).due_date          := c1_rec.due_date;
                l_nw_item_list(l_ctr).workitem_obj_code := c1_rec.workitem_obj_code;
                l_ctr := l_ctr + 1;
                if nvl(p_no_of_recs, 0) <= 0 then
                   exit when c1%notfound;
                elsif nvl(p_no_of_recs, 0) > 0 and c1%found then
                   if nvl(p_no_of_recs, 0) = c1%rowcount then
                      exit;
                   end if;
                else
                   exit;
                end if;
              end loop;
         end;

         -------------- Group Assigned Work Items ----------4

         declare
           cursor c1 is
           select work_item_id, priority_level, to_char(due_date,'dd-mon-yyyy hh24:mi:ss') due_date,
                  workitem_obj_code
           from   ieu_uwqm_items
           where  assignee_type = l_owner_type_grp
           and    assignee_id  in (select group_id from jtf_rs_group_members where resource_id =p_resource_id)
           and    status_id    in (0,1,2)
           and    reschedule_time <= sysdate
           order by priority_level, due_date;

         begin
              for c1_rec in c1 loop
                -- Update Work Item Rec
                l_nw_item_list(l_ctr).work_item_id      := c1_rec.work_item_id;
                l_nw_item_list(l_ctr).priority_level    := c1_rec.priority_level;
                l_nw_item_list(l_ctr).due_date          := c1_rec.due_date;
                l_nw_item_list(l_ctr).workitem_obj_code := c1_rec.workitem_obj_code;
                l_ctr := l_ctr + 1;
                if nvl(p_no_of_recs, 0) <= 0 then
                   exit when c1%notfound;
                elsif nvl(p_no_of_recs, 0) > 0 and c1%found then
                   if nvl(p_no_of_recs, 0) = c1%rowcount then
                      exit;
                   end if;
                else
                   exit;
                end if;
              end loop;
         end;
    exception
       when no_data_found then
       l_ind_own_no_data_found := 1;
    end;

    -- (If there is no work owned or assigned to an INDIVIDUAL
    -- or a GROUP then raise exception and return the message)

    l_ctr := l_nw_item_list.count;

   if (l_ctr = 0)
      then
         null;
/*
         x_return_status := fnd_api.g_ret_sts_error;

         FND_MESSAGE.SET_NAME('IEU', 'IEU_UWQ_GET_NEXT_WORK_FAILED');

         fnd_msg_pub.ADD;
         fnd_msg_pub.Count_and_Get
         (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
         );

         RAISE fnd_api.g_exc_error;
*/
   else

      -- Order the work items by priority level, due date and Object_code
      -- Return the best work item

      -------------------- Sort by Priority Level -------------

      for i in l_nw_item_list.first..(l_nw_item_list.last-1)
      loop
          l_loop_ctr := i;

          l_work_item_id   := l_nw_item_list(i).work_item_id;
          l_priority_level := l_nw_item_list(i).priority_level;
          l_due_date       := l_nw_item_list(i).due_date;
          l_workitem_obj_code := l_nw_item_list(i).workitem_obj_code;

          if ( l_priority_level  > l_nw_item_list(i+1).priority_level) then

                ----move second to first
                l_nw_item_list(i).work_item_id   := l_nw_item_list(i+1).work_item_id;
                l_nw_item_list(i).priority_level := l_nw_item_list(i+1).priority_level;
                l_nw_item_list(i).due_date       := l_nw_item_list(i+1).due_date;
                l_nw_item_list(i).workitem_obj_code := l_nw_item_list(i+1).workitem_obj_code;

                ----move swapped to second
                l_nw_item_list(i+1).work_item_id      := l_work_item_id;
                l_nw_item_list(i+1).priority_level    := l_priority_level;
                l_nw_item_list(i+1).due_date          := l_due_date;
                l_nw_item_list(i+1).workitem_obj_code := l_workitem_obj_code;

                ----------------------------------------------------------------------------
                for k in reverse l_nw_item_list.first..l_loop_ctr
                loop

                   l_work_item_id_1   := l_nw_item_list(k).work_item_id;
                   l_priority_level_1 := l_nw_item_list(k).priority_level;
                   l_due_date_1       := l_nw_item_list(k).due_date;
                   l_workitem_obj_code_1 := l_nw_item_list(k).workitem_obj_code;

                   if ( l_priority_level_1  > l_nw_item_list(k+1).priority_level) then

                     ----move second to first
                     l_nw_item_list(k).work_item_id   := l_nw_item_list(k+1).work_item_id;
                     l_nw_item_list(k).priority_level := l_nw_item_list(k+1).priority_level;
                     l_nw_item_list(k).due_date       := l_nw_item_list(k+1).due_date;
                     l_nw_item_list(k).workitem_obj_code := l_nw_item_list(k+1).workitem_obj_code;

                     ----move swapped to second
                     l_nw_item_list(k+1).work_item_id      := l_work_item_id_1;
                     l_nw_item_list(k+1).priority_level    := l_priority_level_1;
                     l_nw_item_list(k+1).due_date          := l_due_date_1;
                     l_nw_item_list(k+1).workitem_obj_code := l_workitem_obj_code_1;

                   elsif ( l_priority_level_1  < l_nw_item_list(k+1).priority_level) then
                     l_work_item_id_1   := l_nw_item_list(k+1).work_item_id;
                     l_priority_level_1 := l_nw_item_list(k+1).priority_level;
                     l_due_date_1       := l_nw_item_list(k+1).due_date;
                     l_workitem_obj_code_1 := l_nw_item_list(k+1).workitem_obj_code;
                   end if;

                end loop; -- for k loop

          elsif ( l_priority_level  < l_nw_item_list(i+1).priority_level) then

                l_work_item_id   := l_nw_item_list(i+1).work_item_id;
                l_priority_level := l_nw_item_list(i+1).priority_level;
                l_due_date       := l_nw_item_list(i+1).due_date;
                l_workitem_obj_code := l_nw_item_list(i+1).workitem_obj_code;

          end if;

      end loop;

      -------------------- Sort by Due date -------------

      for i in l_nw_item_list.first..(l_nw_item_list.last-1)
      loop
          l_loop_ctr := i;

          l_work_item_id   := l_nw_item_list(i).work_item_id;
          l_priority_level := l_nw_item_list(i).priority_level;
          l_due_date       := l_nw_item_list(i).due_date;
          l_workitem_obj_code := l_nw_item_list(i).workitem_obj_code;

        if ( l_priority_level  = l_nw_item_list(i+1).priority_level) then

            If  l_due_date is null and l_nw_item_list(i+1).due_date is not null then

                ----move second to first
                l_nw_item_list(i).work_item_id   := l_nw_item_list(i+1).work_item_id;
                l_nw_item_list(i).priority_level := l_nw_item_list(i+1).priority_level;
                l_nw_item_list(i).due_date       := l_nw_item_list(i+1).due_date;
                l_nw_item_list(i).workitem_obj_code := l_nw_item_list(i+1).workitem_obj_code;

                ----move swapped to second
                l_nw_item_list(i+1).work_item_id      := l_work_item_id;
                l_nw_item_list(i+1).priority_level    := l_priority_level;
                l_nw_item_list(i+1).due_date          := l_due_date;
                l_nw_item_list(i+1).workitem_obj_code := l_workitem_obj_code;

            elsif ( FND_DATE.STRING_TO_DATE(l_due_date, 'dd-mon-yyyy hh24:mi:ss')  >
                 FND_DATE.STRING_TO_DATE(l_nw_item_list(i+1).due_date, 'dd-mon-yyyy hh24:mi:ss') ) then

                ----move second to first
                l_nw_item_list(i).work_item_id   := l_nw_item_list(i+1).work_item_id;
                l_nw_item_list(i).priority_level := l_nw_item_list(i+1).priority_level;
                l_nw_item_list(i).due_date       := l_nw_item_list(i+1).due_date;
                l_nw_item_list(i).workitem_obj_code := l_nw_item_list(i+1).workitem_obj_code;

                ----move swapped to second
                l_nw_item_list(i+1).work_item_id      := l_work_item_id;
                l_nw_item_list(i+1).priority_level    := l_priority_level;
                l_nw_item_list(i+1).due_date          := l_due_date;
                l_nw_item_list(i+1).workitem_obj_code := l_workitem_obj_code;

                ----------------------------------------------------------------------------
                for k in reverse l_nw_item_list.first..l_loop_ctr
                loop

                   l_work_item_id_1   := l_nw_item_list(k).work_item_id;
                   l_priority_level_1 := l_nw_item_list(k).priority_level;
                   l_due_date_1       := l_nw_item_list(k).due_date;
                   l_workitem_obj_code_1 := l_nw_item_list(k).workitem_obj_code;

                   if ( l_priority_level_1  = l_nw_item_list(k+1).priority_level) then

                     if ( FND_DATE.STRING_TO_DATE(l_due_date_1, 'dd-mon-yyyy hh24:mi:ss')  >
                          FND_DATE.STRING_TO_DATE(l_nw_item_list(k+1).due_date, 'dd-mon-yyyy hh24:mi:ss')) then

                       ----move second to first
                       l_nw_item_list(k).work_item_id   := l_nw_item_list(k+1).work_item_id;
                       l_nw_item_list(k).priority_level := l_nw_item_list(k+1).priority_level;
                       l_nw_item_list(k).due_date       := l_nw_item_list(k+1).due_date;
                       l_nw_item_list(k).workitem_obj_code := l_nw_item_list(k+1).workitem_obj_code;

                       ----move swapped to second
                       l_nw_item_list(k+1).work_item_id      := l_work_item_id_1;
                       l_nw_item_list(k+1).priority_level    := l_priority_level_1;
                       l_nw_item_list(k+1).due_date          := l_due_date_1;
                       l_nw_item_list(k+1).workitem_obj_code := l_workitem_obj_code_1;

                     elsif ( FND_DATE.STRING_TO_DATE(l_due_date_1, 'dd-mon-yyyy hh24:mi:ss')  <
                             FND_DATE.STRING_TO_DATE(l_nw_item_list(k+1).due_date, 'dd-mon-yyyy hh24:mi:ss')) then
                       l_work_item_id_1   := l_nw_item_list(k+1).work_item_id;
                       l_priority_level_1 := l_nw_item_list(k+1).priority_level;
                       l_due_date_1       := l_nw_item_list(k+1).due_date;
                       l_workitem_obj_code_1 := l_nw_item_list(k+1).workitem_obj_code;
                     end if;

                   end if;

                end loop; -- for k loop

          elsif ( FND_DATE.STRING_TO_DATE(l_due_date, 'dd-mon-yyyy hh24:mi:ss')  <
                  FND_DATE.STRING_TO_DATE(l_nw_item_list(i+1).due_date, 'dd-mon-yyyy hh24:mi:ss')) then

                l_work_item_id   := l_nw_item_list(i+1).work_item_id;
                l_priority_level := l_nw_item_list(i+1).priority_level;
                l_due_date       := l_nw_item_list(i+1).due_date;
                l_workitem_obj_code := l_nw_item_list(i+1).workitem_obj_code;

          end if;

        end if;

      end loop;

/*
--      REMOVED THE SORTING BY WORKITEM OBJECT CODE (DEC-06-2001) - ckurian

      ---------------- Sort by Workitem Object Code -------------

      for i in l_nw_item_list.first..(l_nw_item_list.last-1)
      loop
          l_loop_ctr := i;

          l_work_item_id   := l_nw_item_list(i).work_item_id;
          l_priority_level := l_nw_item_list(i).priority_level;
          l_due_date       := l_nw_item_list(i).due_date;
          l_workitem_obj_code := l_nw_item_list(i).workitem_obj_code;

        if (( l_priority_level  = l_nw_item_list(i+1).priority_level) and
           ( l_due_date is null and l_nw_item_list(i+1).due_date is null)) OR
           (( l_priority_level  = l_nw_item_list(i+1).priority_level) and
           ( l_due_date = l_nw_item_list(i+1).due_date)) then

            If ( l_workitem_obj_code  > l_nw_item_list(i+1).workitem_obj_code) then

                ----move second to first
                l_nw_item_list(i).work_item_id   := l_nw_item_list(i+1).work_item_id;
                l_nw_item_list(i).priority_level := l_nw_item_list(i+1).priority_level;
                l_nw_item_list(i).due_date       := l_nw_item_list(i+1).due_date;
                l_nw_item_list(i).workitem_obj_code := l_nw_item_list(i+1).workitem_obj_code;

                ----move swapped to second
                l_nw_item_list(i+1).work_item_id      := l_work_item_id;
                l_nw_item_list(i+1).priority_level    := l_priority_level;
                l_nw_item_list(i+1).due_date          := l_due_date;
                l_nw_item_list(i+1).workitem_obj_code := l_workitem_obj_code;

                ----------------------------------------------------------------------------
                for k in reverse l_nw_item_list.first..l_loop_ctr
                loop

                   l_work_item_id_1   := l_nw_item_list(k).work_item_id;
                   l_priority_level_1 := l_nw_item_list(k).priority_level;
                   l_due_date_1       := l_nw_item_list(k).due_date;
                   l_workitem_obj_code_1 := l_nw_item_list(k).workitem_obj_code;

                   If (( l_priority_level_1  = l_nw_item_list(k+1).priority_level) and
                      ( l_due_date_1 is null and l_nw_item_list(k+1).due_date is null)) OR
                      (( l_priority_level_1  = l_nw_item_list(k+1).priority_level) and
                      ( l_due_date_1  = l_nw_item_list(k+1).due_date)) then

                     If ( l_workitem_obj_code_1  > l_nw_item_list(k+1).workitem_obj_code) then

                       ----move second to first
                       l_nw_item_list(k).work_item_id   := l_nw_item_list(k+1).work_item_id;
                       l_nw_item_list(k).priority_level := l_nw_item_list(k+1).priority_level;
                       l_nw_item_list(k).due_date       := l_nw_item_list(k+1).due_date;
                       l_nw_item_list(k).workitem_obj_code := l_nw_item_list(k+1).workitem_obj_code;

                       ----move swapped to second
                       l_nw_item_list(k+1).work_item_id      := l_work_item_id_1;
                       l_nw_item_list(k+1).priority_level    := l_priority_level_1;
                       l_nw_item_list(k+1).due_date          := l_due_date_1;
                       l_nw_item_list(k+1).workitem_obj_code := l_workitem_obj_code_1;

                     elsif ( l_workitem_obj_code_1  < l_nw_item_list(k+1).workitem_obj_code) then
                       l_work_item_id_1   := l_nw_item_list(k+1).work_item_id;
                       l_priority_level_1 := l_nw_item_list(k+1).priority_level;
                       l_due_date_1       := l_nw_item_list(k+1).due_date;
                       l_workitem_obj_code_1 := l_nw_item_list(k+1).workitem_obj_code;
                     end if;
                   end if;
                end loop; -- for k loop

          elsif ( l_workitem_obj_code  < l_nw_item_list(i+1).workitem_obj_code) then
                l_work_item_id   := l_nw_item_list(i+1).work_item_id;
                l_priority_level := l_nw_item_list(i+1).priority_level;
                l_due_date       := l_nw_item_list(i+1).due_date;
                l_workitem_obj_code := l_nw_item_list(i+1).workitem_obj_code;
          end if;

        end if;

      end loop;

*/
      ------------- To eliminate duplicate Work Item Ids ----------------

      for i in l_nw_item_list.first..l_nw_item_list.last loop
          l_work_item_id_last  :=  l_nw_item_list(i).work_item_id;

          for k in reverse l_nw_item_list.first..i loop
              if l_work_item_id_last = l_nw_item_list(k).work_item_id and
                 i <> k then
                 l_nw_item_list(k).work_item_id := null;
              end if;
          end loop;
      end loop;


      l_ctr := l_nw_item_list.first;

      for i in l_nw_item_list.first..l_nw_item_list.last loop
          if nvl(l_nw_item_list(i).work_item_id,0) > 0 then
             x_uwqm_workitem_data(l_ctr).work_item_id      := l_nw_item_list(i).work_item_id;
             x_uwqm_workitem_data(l_ctr).priority_level    := l_nw_item_list(i).priority_level;
             x_uwqm_workitem_data(l_ctr).due_date          := FND_DATE.STRING_TO_DATE(l_nw_item_list(i).due_date, 'dd-mon-yyyy hh24:mi:ss');
             x_uwqm_workitem_data(l_ctr).workitem_obj_code := l_nw_item_list(i).workitem_obj_code;
             l_ctr := l_ctr + 1;
          end if;
      end loop;

      l_nw_item_list.delete;

      for i in x_uwqm_workitem_data.first..x_uwqm_workitem_data.last loop
            l_nw_item_list(i).work_item_id      := x_uwqm_workitem_data(i).work_item_id;
            l_nw_item_list(i).priority_level    := x_uwqm_workitem_data(i).priority_level;
            l_nw_item_list(i).due_date          := x_uwqm_workitem_data(i).due_date;
            l_nw_item_list(i).workitem_obj_code := x_uwqm_workitem_data(i).workitem_obj_code;
      end loop;

      x_uwqm_workitem_data.delete;


      BEGIN

      for i in l_nw_item_list.first..l_nw_item_list.last
      loop

         SELECT UWQM.WORK_ITEM_ID,
                UWQM.WORKITEM_OBJ_CODE,
                UWQM.WORKITEM_PK_ID,
                UWQM.STATUS_ID,
                UWQM.PRIORITY_ID,
                UWQM.PRIORITY_LEVEL,
                PR.NAME PRIORITY,
                UWQM.DUE_DATE,
                UWQM.TITLE,
                UWQM.PARTY_ID,
                UWQM.OWNER_ID,
                UWQM.OWNER_TYPE,
                UWQM.ASSIGNEE_ID,
                UWQM.ASSIGNEE_TYPE,
                UWQM.SOURCE_OBJECT_ID,
                UWQM.SOURCE_OBJECT_TYPE_CODE,
                UWQM.OWNER_TYPE_ACTUAL,
                UWQM.ASSIGNEE_TYPE_ACTUAL,
                UWQM.APPLICATION_ID,
                ENUM.ENUM_TYPE_UUID IEU_ENUM_TYPE_UUID,
                UWQM.STATUS_UPDATE_USER_ID,
                UWQM.WORK_ITEM_NUMBER,
                UWQM.RESCHEDULE_TIME,
                LKUPS.MEANING WORK_TYPE,
                DECODE(STATUS_ID, 0, '', 1, LKUPS1.MEANING, 2, LKUPS1.MEANING) STATUS_CODE
         INTO   X_UWQM_WORKITEM_DATA(i)
         FROM   IEU_UWQM_ITEMS UWQM,
                IEU_UWQ_SEL_ENUMERATORS ENUM,
         		IEU_UWQM_PRIORITIES_TL PR,
                FND_LOOKUP_VALUES_VL LKUPS,
                FND_LOOKUP_VALUES_VL LKUPS1
         WHERE  UWQM.WORK_ITEM_ID    = l_nw_item_list(i).work_item_id
           AND  ENUM.ENUM_TYPE_UUID  = UWQM.IEU_ENUM_TYPE_UUID
           AND  PR.PRIORITY_ID       = UWQM.PRIORITY_ID
           AND  LKUPS.LOOKUP_TYPE(+) = ENUM.WORK_Q_LABEL_LU_TYPE
           AND  LKUPS.VIEW_APPLICATION_ID(+) = ENUM.APPLICATION_ID
           AND  LKUPS.LOOKUP_CODE(+) = ENUM.WORK_Q_LABEL_LU_CODE
           AND  LKUPS1.LOOKUP_TYPE   = 'IEU_NODE_LABELS'
           AND  LKUPS1.VIEW_APPLICATION_ID = ENUM.APPLICATION_ID
           AND  LKUPS1.LOOKUP_CODE   = 'IN_USE' ;
      end loop;

      EXCEPTION
        when no_data_found
        then
          raise fnd_api.g_exc_unexpected_error;
      END;

      t2 := DBMS_UTILITY.GET_TIME;
      l_time_spent := t2 - t1;

--      insert into IEU_UNIQUE_TEST_RESULTS (result_code,user_id, time_spent, task_id)
--           values ('CK', p_resource_id, l_time_spent, l_work_item_id);

      commit;

    end if;

 EXCEPTION

   WHEN fnd_api.g_exc_error THEN

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.Count_and_Get
      (
         p_count   =>   x_msg_count,
         p_data    =>   x_msg_data
      );

   WHEN fnd_api.g_exc_unexpected_error THEN

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.Count_and_Get
      (
        p_count   =>   x_msg_count,
        p_data    =>   x_msg_data
      );

   WHEN OTHERS THEN

     IF FND_MSG_PUB.Check_msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN

        fnd_msg_pub.Count_and_Get
        (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
        );
     end if;

END GET_WORKLIST_QUEUE;



FUNCTION GET_WORKLIST_QUEUE_COUNT
 ( p_resource_id           IN  NUMBER,
   p_status_id             IN  NUMBER,
   p_node_type             IN  NUMBER)
   RETURN NUMBER
   IS x_tot_count   NUMBER(20);

  -- Used for Time Analysis
  t1           NUMBER;  -- start time
  t2           NUMBER;  -- end time
  l_time_spent NUMBER;  -- time elapsed

  -- Used to get the group count

  l_count  NUMBER := 0;
  l_ctr  PLS_INTEGER := 0;

  --- Values assigned for different work items ---

  l_owner_type_ind	    varchar2(25);
  l_owner_type_grp  	varchar2(25);
  l_work_item_id        number(15);

  l_nw_item_list      IEU_UWQ_GET_NEXT_WORK_PVT.IEU_UWQ_NEXTWORK_ITEM_LIST;

BEGIN

  l_owner_type_ind    := 'RS_INDIVIDUAL';
  l_owner_type_grp   := 'RS_GROUP';
    x_tot_count :=  0;

         -------------- Individual Owned Work Items ----------1
         declare
           cursor c1 is
              select work_item_id
              from   ieu_uwqm_items
              where  owner_type  =  l_owner_type_ind
              and    owner_id    =  p_resource_id
              and    status_id   =  p_status_id
              and   (p_node_type = 1 or p_node_type = 2)
              and    reschedule_time <= sysdate
            union
              select work_item_id
              from   ieu_uwqm_items
              where  owner_type  = l_owner_type_grp
              and    owner_id   in (select group_id from jtf_rs_group_members where resource_id = p_resource_id)
              and    status_id   =  p_status_id
              and   (p_node_type = 1 or p_node_type = 3)
              and    reschedule_time <= sysdate
            union
              select work_item_id
              from   ieu_uwqm_items
              where  assignee_type = l_owner_type_ind
              and    assignee_id   = p_resource_id
              and    status_id     =  p_status_id
              and   (p_node_type   = 1 or p_node_type = 4)
              and    reschedule_time <= sysdate
            union
              select work_item_id
              from   ieu_uwqm_items
              where  assignee_type = l_owner_type_grp
              and    assignee_id  in (select group_id from jtf_rs_group_members where resource_id =p_resource_id)
              and    status_id     =  p_status_id
              and   (p_node_type   = 1 or p_node_type = 5)
              and    reschedule_time <= sysdate;
         begin
            for c1_rec in c1 loop
              -- Update Work Item Rec
              l_nw_item_list(l_ctr).work_item_id   :=  c1_rec.work_item_id;
              l_ctr := l_ctr + 1;
              exit when c1%notfound;
            end loop;
         end;

         x_tot_count := l_nw_item_list.count;

/*
         ------------- To eliminate duplicate Work Item Ids ----------------
         If x_tot_count > 0 then

            for i in l_nw_item_list.first..l_nw_item_list.last loop
                l_work_item_id  :=  l_nw_item_list(i).work_item_id;

                for k in reverse l_nw_item_list.first..i loop
                    if l_work_item_id = l_nw_item_list(k).work_item_id and
                       i <> k then
                       x_tot_count := x_tot_count - 1;
                    end if;
                end loop;
            end loop;

         end if;
*/

   RETURN (x_tot_count);

END GET_WORKLIST_QUEUE_COUNT;

PROCEDURE DISTRIBUTE_AND_DELIVER_WR_ITEM
 ( p_api_version               IN  NUMBER,
   p_resource_id               IN  NUMBER,
   p_language                  IN  VARCHAR2,
   p_source_lang               IN  VARCHAR2,
   p_dist_from_extra_where_clause   IN  VARCHAR2,
   p_dist_to_extra_where_clause    IN  VARCHAR2,
   p_bindvar_from_list        IN  IEU_UWQ_BINDVAR_LIST,
   p_bindvar_to_list          IN  IEU_UWQ_BINDVAR_LIST,
   x_uwqm_workitem_data       OUT NOCOPY IEU_FRM_PVT.T_IEU_MEDIA_DATA,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2,
   x_return_status            OUT NOCOPY VARCHAR2) IS

  -- Used to Validate API version and name
  l_api_version        CONSTANT NUMBER        := 1.0;
  l_api_name           CONSTANT VARCHAR2(30)  := 'DISTRIBUTE_AND_DELIVER_WR_ITEM';


  l_num_of_items_distributed   NUMBER := 0;

  l_sql_stmt     		      VARCHAR2(4000);
  l_del_status 		      NUMBER := 3;
  l_dist_status 		      NUMBER := 1;
  l_open_status_id		NUMBER := 0;
  l_resource_id               NUMBER := 100001713;
  l_next_wr_items             IEU_UWQ_GET_NEXT_WORK_PVT.l_get_work;


-- Table of records for all OUT variables
  l_del_wr_cur                    IEU_UWQ_GET_NEXT_WORK_PVT.l_get_work;
  l_dist_wr_cur                   IEU_UWQ_GET_NEXT_WORK_PVT.l_get_work;
  l_del_nw_item                   IEU_UWQ_GET_NEXT_WORK_PVT.IEU_WR_ITEM_DATA_REC := null;
  l_dist_nw_item                  IEU_UWQ_GET_NEXT_WORK_PVT.IEU_WR_ITEM_DATA_REC := null;
  l_nw_items_list                 IEU_UWQ_GET_NEXT_WORK_PVT.IEU_WR_ITEM_DATA;
  l_dist_flag                     VARCHAR2(10);
  l_del_items_flag                VARCHAR2(10);
  l_dist_items_flag               VARCHAR2(10);
  l_delivery_only_flag            VARCHAR2(10);

  l_object_function            VARCHAR2(40);
  l_object_parameters          VARCHAR2(500);
  l_enter_from_task            VARCHAR2(10);
  l_ws_id                      NUMBER;
  l_ctr                        NUMBER := 0;

  -- used for Distribution
  l_distribute_to                   IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_TO%TYPE;
  l_distribute_from                 IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_FROM%TYPE;
  l_distribution_function           IEU_UWQM_WORK_SOURCES_B.DISTRIBUTION_FUNCTION%TYPE;
  l_dist_st_based_on_parent_flag    IEU_UWQM_WS_ASSCT_PROPS.DIST_ST_BASED_ON_PARENT_FLAG%TYPE;
  l_ws_code                         IEU_UWQM_WORK_SOURCES_B.WS_CODE%TYPE;
  l_dist_bus_rules                  SYSTEM.DIST_BUS_RULES_NST;
  l_work_item_status                VARCHAR2(50);
  l_work_item_status_id             NUMBER;
  l_dist_items                      SYSTEM.WR_ITEM_DATA_NST;
  l_priority_code                   IEU_UWQM_PRIORITIES_B.PRIORITY_CODE%TYPE;
  l_NUM_OF_DIST_ITEMS               NUMBER := 1;
  l_dist_wr_cur_cnt                 NUMBER;
  l_dist_work_item_id               NUMBER;
  l_priority_level                  NUMBER;

  L_MSG_COUNT NUMBER;
  L_MSG_DATA VARCHAR2(4000);
  L_RETURN_STATUS VARCHAR2(10);

  l_dist_item_ctr    number := 0;

-- Audit Trail
  l_action_key  VARCHAR2(500);
  l_event_key  VARCHAR2(500);
  l_module VARCHAR2(1000);
  l_application_id NUMBER;
  --l_ws_code VARCHAR2(500);
  l_ret_sts VARCHAR2(10);
  l_audit_log_val VARCHAR2(100);
  l_ieu_comment_code1 VARCHAR2(2000);
  l_ieu_comment_code2 VARCHAR2(2000);
  l_ieu_comment_code3 VARCHAR2(2000);
  l_ieu_comment_code4 VARCHAR2(2000);
  l_ieu_comment_code5 VARCHAR2(2000);
  l_workitem_comment_code1 VARCHAR2(2000);
  l_workitem_comment_code2 VARCHAR2(2000);
  l_workitem_comment_code3 VARCHAR2(2000);
  l_workitem_comment_code4 VARCHAR2(2000);
  l_workitem_comment_code5 VARCHAR2(2000);

  l_workitem_pk_id NUMBER;
  l_workitem_obj_code VARCHAR2(50);
  l_audit_log_sts VARCHAR2(50);
  l_owner_id NUMBER;
  l_owner_type VARCHAR2(500);
  l_assignee_id NUMBER;
  l_assignee_type VARCHAR2(500);
  l_priority_id  NUMBER;
  l_due_date DATE;
  l_source_object_id  NUMBER;
  l_source_object_type_code VARCHAR2(500);
  l_status_id NUMBER;
  l_distribution_status_id NUMBER;
  l_reschedule_time DATE;
  l_token_str VARCHAR2(4000);
  TYPE AUDIT_LOG_ID_TBL is TABLE OF NUMBER  INDEX BY BINARY_INTEGER;
  l_audit_log_id_list AUDIT_LOG_ID_TBL;
  l_audit_log_id NUMBER;
  l_not_valid_flag VARCHAR2(1);
  cursor_id    PLS_INTEGER;
  dummy        PLS_INTEGER;
  temp number;
  v varchar2(1000);
  BEGIN
  v := p_bindvar_to_list.count;
  l_del_items_flag := 'Y';
  l_dist_items_flag := 'Y';
  l_distribute_to := 'INDIVIDUAL_ASSIGNED';
  l_distribute_from := 'GROUP_OWNED';
  l_not_valid_flag := 'N';
  l_audit_log_val := FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG');

    x_return_status := fnd_api.g_ret_sts_success;

    IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
    THEN
         RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize Message list

    FND_MSG_PUB.INITIALIZE;

    LOOP

        exit when ((l_dist_item_ctr >= 2) or (l_num_of_items_distributed > 0));

        l_dist_item_ctr := l_dist_item_ctr + 1;

        -- Audit Trail
	l_action_key := 'DELIVERY';
	if (l_audit_log_val = 'DETAILED')
	then
            l_ieu_comment_code1 := 'NUM_OF_ATTEMPTS '||l_dist_item_ctr;
	end if;

	--- *** Get the Distributed Work Item with sorted by pty and due_date *** ---

	--  IEU_UWQ_GET_NEXT_WORK_PVT.GET_WS_WHERE_CLAUSE('DIST_TO',l_where_clause);

	  -- Build the complete select stmt
	  l_sql_stmt := 'SELECT /*+ first_rows */
				WORK_ITEM_ID,
				WORKITEM_OBJ_CODE,
				WORKITEM_PK_ID,
				STATUS_ID,
				PRIORITY_ID,
				PRIORITY_LEVEL,
			        null,   -- Selecting null for pty code
				DUE_DATE,
				TITLE,
				PARTY_ID,
				OWNER_ID,
				OWNER_TYPE,
				ASSIGNEE_ID,
				ASSIGNEE_TYPE,
				SOURCE_OBJECT_ID,
				SOURCE_OBJECT_TYPE_CODE,
				APPLICATION_ID,
				IEU_ENUM_TYPE_UUID,
				WORK_ITEM_NUMBER,
				RESCHEDULE_TIME,
				WS_ID
			 FROM IEU_UWQM_ITEMS '||
		       ' WHERE ( '|| p_dist_to_extra_where_clause   || ' ) '||
		       ' AND DISTRIBUTION_STATUS_ID = :l_del_status' ||
		       ' AND STATUS_ID = :l_open_status_id ' ||
		       ' and    reschedule_time <= sysdate ' ||
		       ' order by priority_level, due_date ';

	--  insert into p_temp values ('dist to sql- '||l_sql_stmt, l_instr_to_num); commit;

--	  OPEN l_del_wr_cur FOR l_sql_stmt
--	  USING IN p_resource_id, IN l_del_status, IN l_open_status_id;



          cursor_id := dbms_sql.open_cursor;

          DBMS_SQL.PARSE(cursor_id, l_sql_stmt, dbms_sql.native);

          DBMS_SQL.BIND_VARIABLE(cursor_id,':l_del_status', l_del_status);
          DBMS_SQL.BIND_VARIABLE(cursor_id,':l_open_status_id', l_open_status_id);
          DBMS_SQL.BIND_VARIABLE(cursor_id,':resource_id', p_resource_id);



--insert into temp values (' to proc ',p_dist_to_extra_where_clause);

          for i in 1..p_bindvar_to_list.count loop
--insert into temp values (' to proc bind vars',p_bindvar_to_list(i).bind_name||' '||p_bindvar_to_list(i).value);
              DBMS_SQL.BIND_VARIABLE(cursor_id,p_bindvar_to_list(i).bind_name, p_bindvar_to_list(i).value);

          end loop;
             DBMS_SQL.DEFINE_COLUMN(cursor_id,1,l_del_nw_item.WORK_ITEM_ID);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,2,l_del_nw_item.WORKITEM_OBJ_CODE,30);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,3,l_del_nw_item.WORKITEM_PK_ID);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,4,l_del_nw_item.STATUS_ID);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,5,l_del_nw_item.PRIORITY_ID);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,6,l_del_nw_item.PRIORITY_LEVEL);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,7,l_del_nw_item.PRIORITY_CODE,30);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,8,l_del_nw_item.DUE_DATE);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,9,l_del_nw_item.TITLE,1990);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,10,l_del_nw_item.PARTY_ID);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,11,l_del_nw_item.OWNER_ID);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,12,l_del_nw_item.OWNER_TYPE,25);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,13,l_del_nw_item.ASSIGNEE_ID);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,14,l_del_nw_item.ASSIGNEE_TYPE,25);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,15,l_del_nw_item.SOURCE_OBJECT_ID);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,16,l_del_nw_item.SOURCE_OBJECT_TYPE_CODE,30);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,17,l_del_nw_item.APPLICATION_ID);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,18,l_del_nw_item.IEU_ENUM_TYPE_UUID,38);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,19,l_del_nw_item.WORK_ITEM_NUMBER,64);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,20,l_del_nw_item.RESCHEDULE_TIME);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,21,l_del_nw_item.WS_ID);
          dummy := DBMS_SQL.EXECUTE(cursor_id);
          temp := DBMS_SQL.FETCH_ROWS(cursor_id);
          if temp <> 0 then
             DBMS_SQL.COLUMN_VALUE(cursor_id,1,l_del_nw_item.WORK_ITEM_ID);
             DBMS_SQL.COLUMN_VALUE(cursor_id,2,l_del_nw_item.WORKITEM_OBJ_CODE);
             DBMS_SQL.COLUMN_VALUE(cursor_id,3,l_del_nw_item.WORKITEM_PK_ID);
             DBMS_SQL.COLUMN_VALUE(cursor_id,4,l_del_nw_item.STATUS_ID);
             DBMS_SQL.COLUMN_VALUE(cursor_id,5,l_del_nw_item.PRIORITY_ID);
             DBMS_SQL.COLUMN_VALUE(cursor_id,6,l_del_nw_item.PRIORITY_LEVEL);
             DBMS_SQL.COLUMN_VALUE(cursor_id,7,l_del_nw_item.PRIORITY_CODE);
             DBMS_SQL.COLUMN_VALUE(cursor_id,8,l_del_nw_item.DUE_DATE);
             DBMS_SQL.COLUMN_VALUE(cursor_id,9,l_del_nw_item.TITLE);
             DBMS_SQL.COLUMN_VALUE(cursor_id,10,l_del_nw_item.PARTY_ID);
             DBMS_SQL.COLUMN_VALUE(cursor_id,11,l_del_nw_item.OWNER_ID);
             DBMS_SQL.COLUMN_VALUE(cursor_id,12,l_del_nw_item.OWNER_TYPE);
             DBMS_SQL.COLUMN_VALUE(cursor_id,13,l_del_nw_item.ASSIGNEE_ID);
             DBMS_SQL.COLUMN_VALUE(cursor_id,14,l_del_nw_item.ASSIGNEE_TYPE);
             DBMS_SQL.COLUMN_VALUE(cursor_id,15,l_del_nw_item.SOURCE_OBJECT_ID);
             DBMS_SQL.COLUMN_VALUE(cursor_id,16,l_del_nw_item.SOURCE_OBJECT_TYPE_CODE);
             DBMS_SQL.COLUMN_VALUE(cursor_id,17,l_del_nw_item.APPLICATION_ID);
             DBMS_SQL.COLUMN_VALUE(cursor_id,18,l_del_nw_item.IEU_ENUM_TYPE_UUID);
             DBMS_SQL.COLUMN_VALUE(cursor_id,19,l_del_nw_item.WORK_ITEM_NUMBER);
             DBMS_SQL.COLUMN_VALUE(cursor_id,20,l_del_nw_item.RESCHEDULE_TIME);
             DBMS_SQL.COLUMN_VALUE(cursor_id,21,l_del_nw_item.WS_ID);
          else
              -- NO Distributed Work item
	     l_del_items_flag := 'N';
          end if;
         DBMS_SQL.CLOSE_CURSOR(cursor_id);




--	  FETCH l_del_wr_cur into l_del_nw_item;

	  -- Check if there are any Distributed Items for this resource

/*	  if (l_del_wr_cur%NOTFOUND)
	  then
	     -- NO Distributed Work item
	     l_del_items_flag := 'N';
	  end if;
*/
--	  CLOSE l_del_wr_cur;

	--- *** Get the Distributable Work Item with sorted by pty and due_date *** ---

	-- IEU_UWQ_GET_NEXT_WORK_PVT.GET_WS_WHERE_CLAUSE('DIST_FROM',l_where_clause);

	-- Get the Distributed Work Item with sorted by pty and due_date

	-- Build the complete select stmt
	  l_sql_stmt := 'SELECT /*+ first_rows */
				WORK_ITEM_ID,
				WORKITEM_OBJ_CODE,
				WORKITEM_PK_ID,
				STATUS_ID,
				PRIORITY_ID,
				PRIORITY_LEVEL,
			  null,   -- Selecting null for pty code
				DUE_DATE,
				TITLE,
				PARTY_ID,
				OWNER_ID,
				OWNER_TYPE,
				ASSIGNEE_ID,
				ASSIGNEE_TYPE,
				SOURCE_OBJECT_ID,
				SOURCE_OBJECT_TYPE_CODE,
				APPLICATION_ID,
				IEU_ENUM_TYPE_UUID,
				WORK_ITEM_NUMBER,
				RESCHEDULE_TIME,
				WS_ID
			 FROM IEU_UWQM_ITEMS '||
		       ' WHERE ( '|| p_dist_from_extra_where_clause   || ' ) '||
		       ' AND DISTRIBUTION_STATUS_ID = :l_dist_status' ||
		       ' AND STATUS_ID = :l_open_status_id ' ||
		       ' and    reschedule_time <= sysdate ' ||
		       ' order by priority_level, due_date ' ||
		       ' for update skip locked ';

	--  insert into p_temp(msg) values ('dist from sql- '||l_sql_stmt|| ' res id: '||p_resource_id ||' dist st: '||l_dist_status
	-- || ' open st: '||l_open_status_id); commit;

	  l_ctr := 0;
	  l_dist_wr_cur_cnt := 1;

	  -- Select the top 5 Work Items for Distribution

--	  OPEN l_dist_wr_cur FOR l_sql_stmt
--	  USING IN l_dist_status, IN l_open_status_id;

          cursor_id := dbms_sql.open_cursor;
          DBMS_SQL.PARSE(cursor_id, l_sql_stmt, dbms_sql.native);

          DBMS_SQL.BIND_VARIABLE(cursor_id,':l_dist_status', l_dist_status);
          DBMS_SQL.BIND_VARIABLE(cursor_id,':l_open_status_id', l_open_status_id);


          for i in 1..p_bindvar_from_list.count loop
              DBMS_SQL.BIND_VARIABLE(cursor_id,p_bindvar_from_list(i).bind_name, p_bindvar_from_list(i).value);
          end loop;

               DBMS_SQL.DEFINE_COLUMN(cursor_id,1,l_dist_nw_item.WORK_ITEM_ID);
               DBMS_SQL.DEFINE_COLUMN(cursor_id,2,l_dist_nw_item.WORKITEM_OBJ_CODE,30);
               DBMS_SQL.DEFINE_COLUMN(cursor_id,3,l_dist_nw_item.WORKITEM_PK_ID);
               DBMS_SQL.DEFINE_COLUMN(cursor_id,4,l_dist_nw_item.STATUS_ID);
               DBMS_SQL.DEFINE_COLUMN(cursor_id,5,l_dist_nw_item.PRIORITY_ID);
               DBMS_SQL.DEFINE_COLUMN(cursor_id,6,l_dist_nw_item.PRIORITY_LEVEL);
               DBMS_SQL.DEFINE_COLUMN(cursor_id,7,l_dist_nw_item.PRIORITY_CODE,30);
               DBMS_SQL.DEFINE_COLUMN(cursor_id,8,l_dist_nw_item.DUE_DATE);
               DBMS_SQL.DEFINE_COLUMN(cursor_id,9,l_dist_nw_item.TITLE,1990);
               DBMS_SQL.DEFINE_COLUMN(cursor_id,10,l_dist_nw_item.PARTY_ID);
               DBMS_SQL.DEFINE_COLUMN(cursor_id,11,l_dist_nw_item.OWNER_ID);
               DBMS_SQL.DEFINE_COLUMN(cursor_id,12,l_dist_nw_item.OWNER_TYPE,25);
               DBMS_SQL.DEFINE_COLUMN(cursor_id,13,l_dist_nw_item.ASSIGNEE_ID);
               DBMS_SQL.DEFINE_COLUMN(cursor_id,14,l_dist_nw_item.ASSIGNEE_TYPE,25);
               DBMS_SQL.DEFINE_COLUMN(cursor_id,15,l_dist_nw_item.SOURCE_OBJECT_ID);
               DBMS_SQL.DEFINE_COLUMN(cursor_id,16,l_dist_nw_item.SOURCE_OBJECT_TYPE_CODE,30);
               DBMS_SQL.DEFINE_COLUMN(cursor_id,17,l_dist_nw_item.APPLICATION_ID);
               DBMS_SQL.DEFINE_COLUMN(cursor_id,18,l_dist_nw_item.IEU_ENUM_TYPE_UUID,38);
               DBMS_SQL.DEFINE_COLUMN(cursor_id,19,l_dist_nw_item.WORK_ITEM_NUMBER,64);
               DBMS_SQL.DEFINE_COLUMN(cursor_id,20,l_dist_nw_item.RESCHEDULE_TIME);
               DBMS_SQL.DEFINE_COLUMN(cursor_id,21,l_dist_nw_item.WS_ID);
               dummy := DBMS_SQL.EXECUTE(cursor_id);

          LOOP


--dbms_output.put_line(' row cnt '||DBMS_SQL.FETCH_ROWS(cursor_id));

   temp := DBMS_SQL.FETCH_ROWS(cursor_id);

            if  temp = 0 or (l_dist_wr_cur_cnt > 5) then
               exit;
            elsif temp <> 0 then
               DBMS_SQL.COLUMN_VALUE(cursor_id,1,l_dist_nw_item.WORK_ITEM_ID);
               DBMS_SQL.COLUMN_VALUE(cursor_id,2,l_dist_nw_item.WORKITEM_OBJ_CODE);
               DBMS_SQL.COLUMN_VALUE(cursor_id,3,l_dist_nw_item.WORKITEM_PK_ID);
               DBMS_SQL.COLUMN_VALUE(cursor_id,4,l_dist_nw_item.STATUS_ID);
               DBMS_SQL.COLUMN_VALUE(cursor_id,5,l_dist_nw_item.PRIORITY_ID);
               DBMS_SQL.COLUMN_VALUE(cursor_id,6,l_dist_nw_item.PRIORITY_LEVEL);
               DBMS_SQL.COLUMN_VALUE(cursor_id,7,l_dist_nw_item.PRIORITY_CODE);
               DBMS_SQL.COLUMN_VALUE(cursor_id,8,l_dist_nw_item.DUE_DATE);
               DBMS_SQL.COLUMN_VALUE(cursor_id,9,l_dist_nw_item.TITLE);
               DBMS_SQL.COLUMN_VALUE(cursor_id,10,l_dist_nw_item.PARTY_ID);
               DBMS_SQL.COLUMN_VALUE(cursor_id,11,l_dist_nw_item.OWNER_ID);
               DBMS_SQL.COLUMN_VALUE(cursor_id,12,l_dist_nw_item.OWNER_TYPE);
               DBMS_SQL.COLUMN_VALUE(cursor_id,13,l_dist_nw_item.ASSIGNEE_ID);
               DBMS_SQL.COLUMN_VALUE(cursor_id,14,l_dist_nw_item.ASSIGNEE_TYPE);
               DBMS_SQL.COLUMN_VALUE(cursor_id,15,l_dist_nw_item.SOURCE_OBJECT_ID);
               DBMS_SQL.COLUMN_VALUE(cursor_id,16,l_dist_nw_item.SOURCE_OBJECT_TYPE_CODE);
               DBMS_SQL.COLUMN_VALUE(cursor_id,17,l_dist_nw_item.APPLICATION_ID);
               DBMS_SQL.COLUMN_VALUE(cursor_id,18,l_dist_nw_item.IEU_ENUM_TYPE_UUID);
               DBMS_SQL.COLUMN_VALUE(cursor_id,19,l_dist_nw_item.WORK_ITEM_NUMBER);
               DBMS_SQL.COLUMN_VALUE(cursor_id,20,l_dist_nw_item.RESCHEDULE_TIME);
               DBMS_SQL.COLUMN_VALUE(cursor_id,21,l_dist_nw_item.WS_ID);

            end if;
	 -- LOOP

	   --  FETCH l_dist_wr_cur into l_dist_nw_item;

	--     insert into p_temp(msg) values ('Dist item: '||l_dist_nw_item.workitem_pk_id);

	    -- exit when ( (l_dist_wr_cur%NOTFOUND) OR (l_dist_wr_cur_cnt > 5) ) ;

	     l_dist_wr_cur_cnt := l_dist_wr_cur_cnt + 1;


	     update ieu_uwqm_items
	     set distribution_status_id = 2
	     where work_item_id = l_dist_nw_item.WORK_ITEM_ID;


	     -- Add items to the Table of rec
	     BEGIN
	       select priority_code
	       into   l_priority_code
	       from   ieu_uwqm_priorities_b
	       where  priority_id = l_dist_nw_item.PRIORITY_ID;
	     EXCEPTION
	      WHEN OTHERS THEN
	       null;
	     END;

	     l_nw_items_list(l_ctr).WORK_ITEM_ID            :=   l_dist_nw_item.WORK_ITEM_ID;
	     l_nw_items_list(l_ctr).WORKITEM_OBJ_CODE       :=   l_dist_nw_item.WORKITEM_OBJ_CODE;
	     l_nw_items_list(l_ctr).WORKITEM_PK_ID          :=   l_dist_nw_item.WORKITEM_PK_ID;
	     l_nw_items_list(l_ctr).STATUS_ID               :=   l_dist_nw_item.STATUS_ID;
	     l_nw_items_list(l_ctr).PRIORITY_CODE           :=   l_priority_code;
	     l_nw_items_list(l_ctr).DUE_DATE                :=   l_dist_nw_item.DUE_DATE;
	     l_nw_items_list(l_ctr).TITLE                   :=   l_dist_nw_item.TITLE;
	     l_nw_items_list(l_ctr).PARTY_ID                :=   l_dist_nw_item.PARTY_ID;
	     l_nw_items_list(l_ctr).OWNER_ID                :=   l_dist_nw_item.OWNER_ID;
	     l_nw_items_list(l_ctr).OWNER_TYPE              :=   l_dist_nw_item.OWNER_TYPE;
	     l_nw_items_list(l_ctr).ASSIGNEE_ID             :=   l_dist_nw_item.ASSIGNEE_ID;
	     l_nw_items_list(l_ctr).ASSIGNEE_TYPE           :=   l_dist_nw_item.ASSIGNEE_TYPE;
	     l_nw_items_list(l_ctr).SOURCE_OBJECT_ID        :=   l_dist_nw_item.SOURCE_OBJECT_ID;
	     l_nw_items_list(l_ctr).SOURCE_OBJECT_TYPE_CODE :=   l_dist_nw_item.SOURCE_OBJECT_TYPE_CODE;
	     l_nw_items_list(l_ctr).APPLICATION_ID          :=   l_dist_nw_item.APPLICATION_ID;
	     l_nw_items_list(l_ctr).IEU_ENUM_TYPE_UUID      :=   l_dist_nw_item.IEU_ENUM_TYPE_UUID;
	     l_nw_items_list(l_ctr).WORK_ITEM_NUMBER        :=   l_dist_nw_item.WORK_ITEM_NUMBER;
	     l_nw_items_list(l_ctr).RESCHEDULE_TIME         :=   l_dist_nw_item.RESCHEDULE_TIME;
	     l_nw_items_list(l_ctr).WS_ID                   :=   l_dist_nw_item.WS_ID;

	     l_ctr := l_ctr + 1;

	  END LOOP;
--	  CLOSE l_dist_wr_cur;


          DBMS_SQL.CLOSE_CURSOR(cursor_id);
	  COMMIT;

	  -- Check if there are any Distributed Items for this resource
	  if (l_nw_items_list.COUNT = 0)
	  then
	      -- no Distributable Work items
	      l_dist_items_flag := 'N';
	  end if;


	  --insert into p_temp(msg) values ('l_dist_items_flag: '||l_dist_items_flag ||' l_del_items_flag: '||l_del_items_flag ); commit;


	  --- *** Check if Work Item is Distributed OR Distributable Sorted by Pty_level and Due Date *** ---

	  -- Sort the Work Items (Distributed, Distributable) base on pty and due date
	  -- Set the l_delivery_only_flag to 'Y' if Distribution is not required, 'N'if Distributionb may be required
	  -- '-1' if No Distributable or Distributed Items are present

	  if (nvl(l_dist_items_flag, 'Y') = 'Y') AND  (nvl(l_del_items_flag, 'Y') = 'Y')
	  then
	     l_delivery_only_flag := 'N';
	  elsif (nvl(l_dist_items_flag,'Y') = 'N') AND  (nvl(l_del_items_flag,'Y') = 'Y')
	  then
	     l_delivery_only_flag := 'Y';
	  elsif (nvl(l_dist_items_flag,'Y') = 'Y') AND  (nvl(l_del_items_flag,'Y') = 'N')
	  then
	     l_delivery_only_flag := 'N';
	  elsif (nvl(l_dist_items_flag,'Y') = 'N') AND  (nvl(l_del_items_flag,'Y') = 'N')
	  then
	     l_delivery_only_flag := '-1';
	     raise fnd_api.g_exc_error;
	  end if; /* Check to see if Distributed or Distributable items are present */

          -- Audit Logging
	  if (l_audit_log_val = 'DETAILED')
	  then
              if ( l_delivery_only_flag = 'Y' )
	      then
	         l_ieu_comment_code2 := 'DELIVERY_ONLY';
	      end if;
	  end if;/* Audit Log Val is detailed */

	--  insert into p_temp(msg) values(' l_delivery_only_flag : '||l_delivery_only_flag );


	  --- *** Process Distribution/Delivery *** --

	  if (l_delivery_only_flag =  'Y')
	  then

		-- Workitem is disrtibuted for this resource
		-- Copy the Work item data from l_del_nw_item to table of rec - x_uwqm_workitem_data

		--dbms_output.put_line('Delivery Only');



		IEU_UWQ_GET_NEXT_WORK_PVT.SET_DIST_AND_DEL_ITEM_DATA_REC(p_var_in_type_code => 'REC',
							       p_dist_workitem_data => null,
							       p_dist_del_workitem_data => l_del_nw_item,
							       x_ctr => l_ctr,
							       x_workitem_action_data => x_uwqm_workitem_data);

  	        l_num_of_items_distributed := 1;

		 if x_uwqm_workitem_data.count > 0
		 then
		  for j in x_uwqm_workitem_data.first .. x_uwqm_workitem_data.last
		  loop
		    if (x_uwqm_workitem_data(j).param_name = 'WORKITEM_PK_ID')
		    then
			 l_workitem_pk_id := x_uwqm_workitem_data(j).param_value;
		    end if;
		    if (x_uwqm_workitem_data(j).param_name = 'WORKITEM_OBJ_CODE')
		    then
			 l_workitem_obj_code := x_uwqm_workitem_data(j).param_value;
		    end if;
		    if (x_uwqm_workitem_data(j).param_name = 'PRIORITY_ID')
		    then
			 l_priority_id := x_uwqm_workitem_data(j).param_value;
		    end if;
		    if (x_uwqm_workitem_data(j).param_name = 'DUE_DATE')
		    then
			 l_due_date := x_uwqm_workitem_data(j).param_value;
		    end if;
		    if (x_uwqm_workitem_data(j).param_name = 'OWNER_ID')
		    then
			 l_owner_id := x_uwqm_workitem_data(j).param_value;
		    end if;
		    if (x_uwqm_workitem_data(j).param_name = 'OWNER_TYPE')
		    then
			 l_owner_type := x_uwqm_workitem_data(j).param_value;
		    end if;
		    if (x_uwqm_workitem_data(j).param_name = 'ASSIGNEE_ID')
		    then
			 l_assignee_id := x_uwqm_workitem_data(j).param_value;
		    end if;
		    if (x_uwqm_workitem_data(j).param_name = 'ASSIGNEE_TYPE')
		    then
			 l_assignee_type := x_uwqm_workitem_data(j).param_value;
		    end if;
		    if (x_uwqm_workitem_data(j).param_name = 'SOURCE_OBJECT_ID')
		    then
			 l_source_object_id := x_uwqm_workitem_data(j).param_value;
		    end if;
		    if (x_uwqm_workitem_data(j).param_name = 'SOURCE_OBJECT_TYPE_CODE')
		    then
			 l_source_object_type_code := x_uwqm_workitem_data(j).param_value;
		    end if;
		    if (x_uwqm_workitem_data(j).param_name = 'STATUS_ID')
		    then
			 l_status_id := x_uwqm_workitem_data(j).param_value;
		    end if;


		  end loop;
		end if;

		if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') )
		then
		       l_event_key := 'DELIVER';
		else
		       l_event_key := null;
		end if;
		l_module := 'IEU_GET_NEXT_WORK_PVT.DISTRIBUTE_AND_DELIVER';
		l_application_id := 696;
		l_ws_code := null;
  	        l_ret_sts := 'S';

	     BEGIN
		select ws_code
		into   l_ws_code
		from ieu_uwqm_work_sources_b
		where ws_id = l_del_nw_item.ws_id;
	     EXCEPTION
	       WHEN OTHERS THEN
		  l_ws_code := '';
	     END;

	        if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') OR  (l_audit_log_val = 'MINIMAL') )
	        then

		     BEGIN

			select reschedule_time, distribution_status_id
			into   l_reschedule_time, l_distribution_status_id
			from   ieu_uwqm_items
			where  workitem_pk_id = l_workitem_pk_id
			and    workitem_obj_code = l_workitem_obj_code;

		     EXCEPTION
		       when others then
		         null;
		     END;

		     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
		     (
			P_ACTION_KEY => l_action_key,
			P_EVENT_KEY =>	l_event_key,
			P_MODULE => l_module,
			P_WS_CODE => l_ws_code,
			P_APPLICATION_ID => l_application_id,
			P_WORKITEM_PK_ID => l_workitem_pk_id,
			P_WORKITEM_OBJ_CODE => l_workitem_obj_code,
			P_WORK_ITEM_STATUS_PREV => l_status_id,
			P_WORK_ITEM_STATUS_CURR	=> l_status_id,
			P_OWNER_ID_PREV	 => l_owner_id,
			P_OWNER_ID_CURR	=> l_owner_id,
			P_OWNER_TYPE_PREV => l_owner_type,
			P_OWNER_TYPE_CURR => l_owner_type,
			P_ASSIGNEE_ID_PREV => l_assignee_id,
			P_ASSIGNEE_ID_CURR => l_assignee_id,
			P_ASSIGNEE_TYPE_PREV => l_assignee_type,
			P_ASSIGNEE_TYPE_CURR => l_assignee_type,
			P_SOURCE_OBJECT_ID_PREV => l_source_object_id,
			P_SOURCE_OBJECT_ID_CURR => l_source_object_id,
			P_SOURCE_OBJECT_TYPE_CODE_PREV => l_source_object_type_code,
			P_SOURCE_OBJECT_TYPE_CODE_CURR => l_source_object_type_code,
			P_PARENT_WORKITEM_STATUS_PREV => null,
			P_PARENT_WORKITEM_STATUS_CURR => null,
			P_PARENT_DIST_STATUS_PREV => null,
			P_PARENT_DIST_STATUS_CURR => null,
			P_WORKITEM_DIST_STATUS_PREV => l_distribution_status_id,
			P_WORKITEM_DIST_STATUS_CURR => l_distribution_status_id,
			P_PRIORITY_PREV => l_priority_id,
			P_PRIORITY_CURR	=> l_priority_id,
			P_DUE_DATE_PREV	=> l_due_date,
			P_DUE_DATE_CURR	=> l_due_date,
			P_RESCHEDULE_TIME_PREV => l_reschedule_time,
			P_RESCHEDULE_TIME_CURR => l_reschedule_time,
			P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
			P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
			P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
			P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
			P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
			P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
			P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
			P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
			P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
			P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
			P_STATUS => 'S',
			P_ERROR_CODE => l_msg_data,
			X_AUDIT_LOG_ID => l_audit_log_id,
			X_MSG_DATA => l_msg_data,
			X_RETURN_STATUS => l_ret_sts); commit;

		end if;

	  elsif (l_delivery_only_flag =  'N')
	  then

	     -- Loop thru all Distributable Items

	     for z in l_nw_items_list.first .. l_nw_items_list.last
	     loop

	       -- Select the Work Items with highest pty, due date
	       -- l_dist_flag = 'Y' if Distribution is required.

	       if (nvl(l_del_items_flag,'Y') = 'N')
	       then

		  l_dist_flag := 'Y';

	       else

		 --insert into p_temp(msg) values('Attempting Dist for ID: '||l_nw_items_list(z).workitem_pk_id); commit;
		 BEGIN
		    select priority_level
		    into   l_priority_level
		    from   ieu_uwqm_priorities_b
		    where  priority_code  = l_nw_items_list(z).priority_code;
		 EXCEPTION
		    WHEN OTHERS THEN
		      null;
		 END;

		 --insert into p_temp(msg) values('dist pty lvl: '||l_priority_level);
		 --insert into p_temp(msg) values(' due date: '||l_nw_items_list(z).due_date);
		 --insert into p_temp(msg) values('del pty lvl: '||l_del_nw_item.priority_level||' due date: '||l_del_nw_item.due_date );

		 if (l_priority_level < l_del_nw_item.priority_level)
		 then
		   l_dist_flag := 'Y';
		 elsif (l_priority_level > l_del_nw_item.priority_level)
		 then
		   l_dist_flag := 'N';
		 elsif (l_priority_level = l_del_nw_item.priority_level)
		 then
		   if (l_nw_items_list(z).due_date is null) and (l_del_nw_item.due_date is null)
		   then
		       l_dist_flag := 'N';
		   elsif (l_nw_items_list(z).due_date is null) and (l_del_nw_item.due_date is not null)
		   then
		       l_dist_flag := 'N';
		   elsif (l_nw_items_list(z).due_date is not null) and (l_del_nw_item.due_date is null)
		   then
		       l_dist_flag := 'Y';
		   elsif (l_nw_items_list(z).due_date < l_del_nw_item.due_date)
		   then
		       l_dist_flag := 'Y';
		   elsif (l_nw_items_list(z).due_date > l_del_nw_item.due_date)
		   then
		       l_dist_flag := 'N';
		   elsif (l_nw_items_list(z).due_date = l_del_nw_item.due_date)
		   then
		       l_dist_flag := 'N';
		   end if; /*due date */
		 end if;/* pty_level */

	       end if; /* (nvl(l_del_items_flag,'Y') = 'N') */

	       if (l_dist_flag <> 'Y')
	       then

		   -- Workitem is disrtibuted for this resource
		   -- Copy the Work item data from l_del_nw_item to table of rec - x_uwqm_workitem_data

		   --dbms_output.put_line('Delivery Only');



		   IEU_UWQ_GET_NEXT_WORK_PVT.SET_DIST_AND_DEL_ITEM_DATA_REC(p_var_in_type_code => 'REC',
							       p_dist_workitem_data => null,
							       p_dist_del_workitem_data => l_del_nw_item,
							       x_ctr => l_ctr,
							       x_workitem_action_data => x_uwqm_workitem_data);

			if x_uwqm_workitem_data.count > 0
			 then
			  for j in x_uwqm_workitem_data.first .. x_uwqm_workitem_data.last
			  loop
			    if (x_uwqm_workitem_data(j).param_name = 'WORKITEM_PK_ID')
			    then
				 l_workitem_pk_id := x_uwqm_workitem_data(j).param_value;
			    end if;
			    if (x_uwqm_workitem_data(j).param_name = 'WORKITEM_OBJ_CODE')
			    then
				 l_workitem_obj_code := x_uwqm_workitem_data(j).param_value;
			    end if;
			    if (x_uwqm_workitem_data(j).param_name = 'PRIORITY_ID')
			    then
				 l_priority_id := x_uwqm_workitem_data(j).param_value;
			    end if;
			    if (x_uwqm_workitem_data(j).param_name = 'DUE_DATE')
			    then
				 l_due_date := x_uwqm_workitem_data(j).param_value;
			    end if;
			    if (x_uwqm_workitem_data(j).param_name = 'OWNER_ID')
			    then
				 l_owner_id := x_uwqm_workitem_data(j).param_value;
			    end if;
			    if (x_uwqm_workitem_data(j).param_name = 'OWNER_TYPE')
			    then
				 l_owner_type := x_uwqm_workitem_data(j).param_value;
			    end if;
			    if (x_uwqm_workitem_data(j).param_name = 'ASSIGNEE_ID')
			    then
				 l_assignee_id := x_uwqm_workitem_data(j).param_value;
			    end if;
			    if (x_uwqm_workitem_data(j).param_name = 'ASSIGNEE_TYPE')
			    then
				 l_assignee_type := x_uwqm_workitem_data(j).param_value;
			    end if;
			    if (x_uwqm_workitem_data(j).param_name = 'SOURCE_OBJECT_ID')
			    then
				 l_source_object_id := x_uwqm_workitem_data(j).param_value;
			    end if;
			    if (x_uwqm_workitem_data(j).param_name = 'SOURCE_OBJECT_TYPE_CODE')
			    then
				 l_source_object_type_code := x_uwqm_workitem_data(j).param_value;
			    end if;
			    if (x_uwqm_workitem_data(j).param_name = 'STATUS_ID')
			    then
				 l_status_id := x_uwqm_workitem_data(j).param_value;
			    end if;
			  end loop;
			end if;

		   l_num_of_items_distributed := 1;
		   if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') )
		   then
                       l_event_key := 'DELIVER';
		   else
                       l_event_key := null;
		   end if;
		   l_module := 'IEU_GET_NEXT_WORK_PVT.DISTRIBUTE_AND_DELIVER';
		   l_application_id := 696;
		   l_ws_code := null;
		   l_ret_sts := 'S';

		     BEGIN
			select ws_code
			into   l_ws_code
			from ieu_uwqm_work_sources_b
			where ws_id = l_del_nw_item.ws_id;
		     EXCEPTION
		       WHEN OTHERS THEN
			  l_ws_code := '';
		     END;

--insert into p_temp(msg) values('audit log val: '||l_audit_log_val||' ret sts: '||l_ret_sts ||' ws code: '||l_ws_code);
	           if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') OR  (l_audit_log_val = 'MINIMAL') )
	           then

			     BEGIN

				select reschedule_time, distribution_status_id
				into   l_reschedule_time, l_distribution_status_id
				from   ieu_uwqm_items
				where  workitem_pk_id = l_workitem_pk_id
				and    workitem_obj_code = l_workitem_obj_code;

			     EXCEPTION
			       when others then
				 null;
			     END;

			     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
			     (
				P_ACTION_KEY => l_action_key,
				P_EVENT_KEY =>	l_event_key,
				P_MODULE => l_module,
				P_WS_CODE => l_ws_code,
				P_APPLICATION_ID => l_application_id,
				P_WORKITEM_PK_ID => l_workitem_pk_id,
				P_WORKITEM_OBJ_CODE => l_workitem_obj_code,
				P_WORK_ITEM_STATUS_PREV => l_status_id,
				P_WORK_ITEM_STATUS_CURR	=> l_status_id,
				P_OWNER_ID_PREV	 => l_owner_id,
				P_OWNER_ID_CURR	=> l_owner_id,
				P_OWNER_TYPE_PREV => l_owner_type,
				P_OWNER_TYPE_CURR => l_owner_type,
				P_ASSIGNEE_ID_PREV => l_assignee_id,
				P_ASSIGNEE_ID_CURR => l_assignee_id,
				P_ASSIGNEE_TYPE_PREV => l_assignee_type,
				P_ASSIGNEE_TYPE_CURR => l_assignee_type,
				P_SOURCE_OBJECT_ID_PREV => l_source_object_id,
				P_SOURCE_OBJECT_ID_CURR => l_source_object_id,
				P_SOURCE_OBJECT_TYPE_CODE_PREV => l_source_object_type_code,
				P_SOURCE_OBJECT_TYPE_CODE_CURR => l_source_object_type_code,
				P_PARENT_WORKITEM_STATUS_PREV => null,
				P_PARENT_WORKITEM_STATUS_CURR => null,
				P_PARENT_DIST_STATUS_PREV => null,
				P_PARENT_DIST_STATUS_CURR => null,
				P_WORKITEM_DIST_STATUS_PREV => l_distribution_status_id,
				P_WORKITEM_DIST_STATUS_CURR => l_distribution_status_id,
				P_PRIORITY_PREV => l_priority_id,
				P_PRIORITY_CURR	=> l_priority_id,
				P_DUE_DATE_PREV	=> l_due_date,
				P_DUE_DATE_CURR	=> l_due_date,
				P_RESCHEDULE_TIME_PREV => l_reschedule_time,
				P_RESCHEDULE_TIME_CURR => l_reschedule_time,
				P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
				P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
				P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
				P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
				P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
				P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
				P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
				P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
				P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
				P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
				P_STATUS => 'S',
				P_ERROR_CODE => l_msg_data,
				X_AUDIT_LOG_ID => l_audit_log_id,
				X_MSG_DATA => l_msg_data,
				X_RETURN_STATUS => l_ret_sts); commit;


		   end if;
		   exit;

	       elsif (l_dist_flag = 'Y')
	       then


		  /************ THIS IS NOT REQUIRED NOW AS WE HAVE TWO DIFFERENT EVENTS FOR DIST AND DELIVER *********
	          -- Audit Logging
		  if (l_audit_log_val = 'DETAILED')
		  then
			 l_ieu_comment_code2 := 'DISTRIBUTE_AND_DELIVER';
		  end if;
		  ******************************************************************************************************/

		  l_ws_code := '';
		  --dbms_output.put_line('Distributing for ws..'||l_nw_items_list(z).WS_ID);
		  l_num_of_items_distributed := 0;

		  -- Initialize Collection
		  l_dist_bus_rules := SYSTEM.DIST_BUS_RULES_NST();
		  l_dist_items := SYSTEM.WR_ITEM_DATA_NST();
		  --l_dist_workitem_data := SYSTEM.WR_ITEM_DATA_NST();

		  BEGIN

		       SELECT WS_B.DISTRIBUTION_FUNCTION ,
			      WS_A.DIST_ST_BASED_ON_PARENT_FLAG, WS_B.WS_CODE
		       INTO   l_distribution_function,
			      l_dist_st_based_on_parent_flag, l_ws_code
		       FROM   IEU_UWQM_WORK_SOURCES_B WS_B, IEU_UWQM_WS_ASSCT_PROPS WS_A
		       WHERE  ws_b.ws_id = l_nw_items_list(z).WS_ID
		       AND    ws_b.not_valid_flag = l_not_valid_flag
		       AND    ws_b.ws_id = ws_a.ws_id(+);

		  EXCEPTION
		       WHEN OTHERS THEN
			    null;
		  END;

		  if (l_audit_log_val = 'DETAILED')
		  then
			l_ieu_comment_code4 := 'DISTRIBUTION_FUNC '||l_distribution_function;
		  end if;

		  l_dist_bus_rules.extend;
		  l_dist_bus_rules(l_dist_bus_rules.last) :=  SYSTEM.DIST_BUS_RULES_OBJ ( l_ws_code,
											  l_distribute_from,
											  l_distribute_to,
											  l_DIST_ST_BASED_ON_PARENT_FLAG);
		 if (l_distribute_from = 'GROUP_OWNED') and
			(l_distribute_to = 'INDIVIDUAL_OWNED')
		 then
			l_ieu_comment_code3 := 'GO_IO';
		 elsif (l_distribute_from = 'GROUP_OWNED') and
			  (l_distribute_to = 'INDIVIDUAL_ASSIGNED')
		 then
			l_ieu_comment_code3 := 'GO_IA';
		 elsif (l_distribute_from = 'GROUP_ASSIGNED') and
			 (l_distribute_to = 'INDIVIDUAL_OWNED')
		 then
			l_ieu_comment_code3 := 'GA_IO';
		 elsif (l_distribute_from = 'GROUP_ASSIGNED') and
			 (l_distribute_to = 'INDIVIDUAL_ASSIGNED')
		 then
			l_ieu_comment_code3 := 'GA_IA';
		 end if;

		  if (l_nw_items_list(z).STATUS_ID = 0)
		  then
		       l_work_item_status := 'OPEN';
		  elsif (l_nw_items_list(z).STATUS_ID = 3)
		  then
		       l_work_item_status := 'CLOSE';
		  elsif (l_nw_items_list(z).STATUS_ID = 4)
		  then
		       l_work_item_status := 'DELETE';
		  elsif (l_nw_items_list(z).STATUS_ID = 5)
		  then
		       l_work_item_status := 'SLEEP';
		  end if;

		  --dbms_output.put_line('ws id matches: '||l_nw_items_list(i).ws_id|| ' ID: '||l_nw_items_list(i).WORKITEM_PK_ID);
		  l_dist_items.extend;
		  l_dist_items(l_dist_items.last) := SYSTEM.WR_ITEM_DATA_OBJ(l_nw_items_list(z).WORK_ITEM_ID,
												 l_nw_items_list(z).WORKITEM_OBJ_CODE,
												   l_nw_items_list(z).WORKITEM_PK_ID,
												   l_work_item_status,
												   l_nw_items_list(z).PRIORITY_ID,
												   l_nw_items_list(z).PRIORITY_LEVEL,
												   l_nw_items_list(z).PRIORITY_CODE,
												   l_nw_items_list(z).DUE_DATE,
												   l_nw_items_list(z).TITLE,
												   l_nw_items_list(z).PARTY_ID,
												   l_nw_items_list(z).OWNER_ID,
												   l_nw_items_list(z).OWNER_TYPE,
		 										   l_nw_items_list(z).ASSIGNEE_ID,
												   l_nw_items_list(z).ASSIGNEE_TYPE,
												   l_nw_items_list(z).SOURCE_OBJECT_ID,
												   l_nw_items_list(z).SOURCE_OBJECT_TYPE_CODE,
												   l_nw_items_list(z).APPLICATION_ID,
												   l_nw_items_list(z).IEU_ENUM_TYPE_UUID,
												   l_nw_items_list(z).WORK_ITEM_NUMBER,
												   l_nw_items_list(z).RESCHEDULE_TIME,
												   l_ws_code,   --l_nw_items_list(i).WS_ID,
												   null,
												   null);


		   --dbms_output.put_line('dist items cnt'||l_dist_items.count);

		    -- Call the Distribution Function
		    if (l_dist_items.count > 0)
		    then
			 --dbms_output.put_line('calling dist func: '||L_DISTRIBUTION_FUNCTION);

		       if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') OR  (l_audit_log_val = 'MINIMAL') )
		       then

			     for k in l_dist_items.first .. l_dist_items.last
			     loop

				 IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
				 (
					P_ACTION_KEY => l_action_key,
					P_EVENT_KEY =>	l_event_key,
					P_MODULE => l_module,
					P_WS_CODE => l_ws_code,
					P_APPLICATION_ID => l_dist_items(k).application_id,
					P_WORKITEM_PK_ID => l_dist_items(k).workitem_pk_id,
					P_WORKITEM_OBJ_CODE => l_dist_items(k).workitem_obj_code,
					P_WORK_ITEM_STATUS_PREV => l_status_id,
					P_WORK_ITEM_STATUS_CURR	=> l_status_id,
					P_OWNER_ID_PREV	 => l_dist_items(k).owner_id,
					P_OWNER_ID_CURR	=> l_dist_items(k).owner_id,
					P_OWNER_TYPE_PREV => l_dist_items(k).owner_type,
					P_OWNER_TYPE_CURR => l_dist_items(k).owner_type,
					P_ASSIGNEE_ID_PREV => null,
					P_ASSIGNEE_ID_CURR => l_dist_items(k).assignee_id,
					P_ASSIGNEE_TYPE_PREV => null,
					P_ASSIGNEE_TYPE_CURR => l_dist_items(k).assignee_type,
					P_SOURCE_OBJECT_ID_PREV => l_dist_items(k).source_object_id,
					P_SOURCE_OBJECT_ID_CURR => l_dist_items(k).source_object_id,
					P_SOURCE_OBJECT_TYPE_CODE_PREV => l_dist_items(k).source_object_type_code,
					P_SOURCE_OBJECT_TYPE_CODE_CURR => l_dist_items(k).source_object_type_code,
					P_PARENT_WORKITEM_STATUS_PREV => null,
					P_PARENT_WORKITEM_STATUS_CURR => null,
					P_PARENT_DIST_STATUS_PREV => null,
					P_PARENT_DIST_STATUS_CURR => null,
					P_WORKITEM_DIST_STATUS_PREV => l_distribution_status_id,
					P_WORKITEM_DIST_STATUS_CURR => l_distribution_status_id,
					P_PRIORITY_PREV => l_dist_items(k).priority_id,
					P_PRIORITY_CURR	=> l_dist_items(k).priority_id,
					P_DUE_DATE_PREV	=> l_dist_items(k).due_date,
					P_DUE_DATE_CURR	=> l_dist_items(k).due_date,
					P_RESCHEDULE_TIME_PREV => l_reschedule_time,
					P_RESCHEDULE_TIME_CURR => l_reschedule_time,
					P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
					P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
					P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
					P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
					P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
					P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
					P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
					P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
					P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
					P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
					P_STATUS => 'E',
					P_ERROR_CODE => x_msg_data,
					X_AUDIT_LOG_ID => l_audit_log_id_list(k),
					X_MSG_DATA => x_msg_data,
					X_RETURN_STATUS => l_ret_sts
				 );

			     end loop;
			 end if;

			 BEGIN
			   EXECUTE IMMEDIATE
			     'BEGIN '|| L_DISTRIBUTION_FUNCTION||'(:1,:2,:3,:4,:5,:6,:7,:8,:9); END;'
			   USING IN P_RESOURCE_ID, IN P_LANGUAGE, IN  P_SOURCE_LANG, IN L_NUM_OF_DIST_ITEMS, IN L_DIST_BUS_RULES, IN OUT L_DIST_ITEMS,
			      OUT L_MSG_COUNT, OUT L_MSG_DATA, OUT L_RETURN_STATUS;
			 EXCEPTION
			    when others then
			     -- Set the status back from 'Distributing' to 'Distributable'
			     for k in l_dist_items.first .. l_dist_items.last
			     loop
			          l_workitem_pk_id := l_dist_items(k).workitem_pk_id;
				  l_workitem_obj_code := l_dist_items(k).workitem_obj_code;
				  l_owner_id := l_dist_items(k).owner_id;
				  l_owner_type := l_dist_items(k).owner_type;
				  l_assignee_id := l_dist_items(k).assignee_id;
				  l_assignee_type := l_dist_items(k).assignee_type;
				  l_priority_id := l_dist_items(k).priority_id;
				  l_due_date := l_dist_items(k).due_date;
				  l_source_object_id := l_dist_items(k).source_object_id;
				  l_source_object_type_code := l_dist_items(k).source_object_type_code;

				  if (l_dist_items(k).work_item_status = 'OPEN')
				  then
				       l_status_id := 0;
				  elsif (l_dist_items(k).work_item_status = 'CLOSE')
				  then
				       l_status_id := 3;
				  elsif (l_dist_items(k).work_item_status = 'DELETE')
				  then
				       l_status_id := 4;
				  elsif (l_dist_items(k).work_item_status = 'SLEEP')
				  then
				       l_status_id := 5;
				  end if;

				  update ieu_uwqm_items
				  set distribution_status_id = 1
				  where work_item_id = l_dist_items(k).work_item_id;
				  commit;

				  if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') )
				  then
					l_event_key := 'DISTRIBUTE';
				  else
					l_event_key := null;
				  end if;
				  l_module := 'IEU_GET_NEXT_WORK_PVT.DISTRIBUTE_AND_DELIVER';
				  l_application_id := 696;
				  l_ret_sts := 'E';

				  FND_MSG_PUB.INITIALIZE;
				  FND_MESSAGE.SET_NAME('IEU', 'IEU_SQL_ERROR');
				  FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_GET_NEXT_WORK_PVT.DISTRIBUTE_AND_DELIVER');
				  FND_MESSAGE.SET_TOKEN('SQL_ERROR_MSG',l_token_str);
				  fnd_msg_pub.ADD;

				  fnd_msg_pub.Count_and_Get
					(
					 p_count   =>   x_msg_count,
					 p_data    =>   x_msg_data
					);


				  if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') OR  (l_audit_log_val = 'MINIMAL') )
				  then
					     BEGIN

						select reschedule_time, distribution_status_id, priority_id
						into   l_reschedule_time, l_distribution_status_id, l_priority_id
						from   ieu_uwqm_items
						where  workitem_pk_id = l_workitem_pk_id
						and    workitem_obj_code = l_workitem_obj_code;

					     EXCEPTION
					       when others then
						 null;
					     END;


					     IEU_UWQM_AUDIT_LOG_PKG.UPDATE_ROW
					     (
						P_AUDIT_LOG_ID => l_audit_log_id_list(k),
						P_ACTION_KEY => l_action_key,
						P_EVENT_KEY =>	l_event_key,
						P_MODULE => l_module,
						P_WS_CODE => l_ws_code,
						P_APPLICATION_ID => l_application_id,
						P_WORKITEM_PK_ID => l_workitem_pk_id,
						P_WORKITEM_OBJ_CODE => l_workitem_obj_code,
						P_WORK_ITEM_STATUS_PREV => l_status_id,
						P_WORK_ITEM_STATUS_CURR	=> l_status_id,
						P_OWNER_ID_PREV	 => l_owner_id,
						P_OWNER_ID_CURR	=> l_owner_id,
						P_OWNER_TYPE_PREV => l_owner_type,
						P_OWNER_TYPE_CURR => l_owner_type,
						P_ASSIGNEE_ID_PREV => l_assignee_id,
						P_ASSIGNEE_ID_CURR => l_assignee_id,
						P_ASSIGNEE_TYPE_PREV => l_assignee_type,
						P_ASSIGNEE_TYPE_CURR => l_assignee_type,
						P_SOURCE_OBJECT_ID_PREV => l_source_object_id,
						P_SOURCE_OBJECT_ID_CURR => l_source_object_id,
						P_SOURCE_OBJECT_TYPE_CODE_PREV => l_source_object_type_code,
						P_SOURCE_OBJECT_TYPE_CODE_CURR => l_source_object_type_code,
						P_PARENT_WORKITEM_STATUS_PREV => null,
						P_PARENT_WORKITEM_STATUS_CURR => null,
						P_PARENT_DIST_STATUS_PREV => null,
						P_PARENT_DIST_STATUS_CURR => null,
						P_WORKITEM_DIST_STATUS_PREV => l_distribution_status_id,
						P_WORKITEM_DIST_STATUS_CURR => l_distribution_status_id,
						P_PRIORITY_PREV => l_priority_id,
						P_PRIORITY_CURR	=> l_priority_id,
						P_DUE_DATE_PREV	=> l_due_date,
						P_DUE_DATE_CURR	=> l_due_date,
						P_RESCHEDULE_TIME_PREV => l_reschedule_time,
						P_RESCHEDULE_TIME_CURR => l_reschedule_time,
						P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
						P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
						P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
						P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
						P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
						P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
						P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
						P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
						P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
						P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
						P_STATUS => 'E',
						P_ERROR_CODE => x_msg_data); commit;

				  end if;

			     end loop;
			 END;

			 -- Check the # of items distributed
			 -- l_dist_items will contain only 1 item. This loop was required just to retrieve the values
			 -- instead or hardcoding 0/1

			 for j in l_dist_items.FIRST..l_dist_items.LAST
			 loop

				l_workitem_pk_id := l_dist_items(j).workitem_pk_id;
				l_workitem_obj_code := l_dist_items(j).workitem_obj_code;
				l_owner_id := l_dist_items(j).owner_id;
				l_owner_type := l_dist_items(j).owner_type;
				l_assignee_id := l_dist_items(j).assignee_id;
				l_assignee_type := l_dist_items(j).assignee_type;
				l_priority_id := l_dist_items(j).priority_id;
				l_due_date := l_dist_items(j).due_date;
				l_source_object_id := l_dist_items(j).source_object_id;
				l_source_object_type_code := l_dist_items(j).source_object_type_code;
				  if (l_dist_items(j).work_item_status = 'OPEN')
				  then
				       l_status_id := 0;
				  elsif (l_dist_items(j).work_item_status = 'CLOSE')
				  then
				       l_status_id := 3;
				  elsif (l_dist_items(j).work_item_status = 'DELETE')
				  then
				       l_status_id := 4;
				  elsif (l_dist_items(j).work_item_status = 'SLEEP')
				  then
				       l_status_id := 5;
				  end if;


				if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') )
				then
					l_event_key := 'DISTRIBUTE';
				else
					l_event_key := null;
				end if;
				l_module := 'IEU_GET_NEXT_WORK_PVT.DISTRIBUTE_AND_DELIVER';
				l_application_id := 696;

				if (l_dist_items(j).DISTRIBUTED = 'TRUE')
				then
				    l_audit_log_sts := 'S';
				else
			            l_audit_log_sts := 'E';
				end if;

				if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') OR  (l_audit_log_val = 'MINIMAL') )
				then

				     BEGIN

					select reschedule_time, distribution_status_id, priority_id
					into   l_reschedule_time, l_distribution_status_id, l_priority_id
					from   ieu_uwqm_items
					where  workitem_pk_id = l_workitem_pk_id
					and    workitem_obj_code = l_workitem_obj_code;

				     EXCEPTION
				       when others then
					 null;
				     END;


				     IEU_UWQM_AUDIT_LOG_PKG.UPDATE_ROW
				     (
					P_AUDIT_LOG_ID => l_audit_log_id_list(j),
					P_ACTION_KEY => l_action_key,
					P_EVENT_KEY =>	l_event_key,
					P_MODULE => l_module,
					P_WS_CODE => l_ws_code,
					P_APPLICATION_ID => l_application_id,
					P_WORKITEM_PK_ID => l_workitem_pk_id,
					P_WORKITEM_OBJ_CODE => l_workitem_obj_code,
					P_WORK_ITEM_STATUS_PREV => l_status_id,
					P_WORK_ITEM_STATUS_CURR	=> l_status_id,
					P_OWNER_ID_PREV	 => l_owner_id,
					P_OWNER_ID_CURR	=> l_owner_id,
					P_OWNER_TYPE_PREV => l_owner_type,
					P_OWNER_TYPE_CURR => l_owner_type,
					P_ASSIGNEE_ID_PREV => l_assignee_id,
					P_ASSIGNEE_ID_CURR => l_assignee_id,
					P_ASSIGNEE_TYPE_PREV => l_assignee_type,
					P_ASSIGNEE_TYPE_CURR => l_assignee_type,
					P_SOURCE_OBJECT_ID_PREV => l_source_object_id,
					P_SOURCE_OBJECT_ID_CURR => l_source_object_id,
					P_SOURCE_OBJECT_TYPE_CODE_PREV => l_source_object_type_code,
					P_SOURCE_OBJECT_TYPE_CODE_CURR => l_source_object_type_code,
					P_PARENT_WORKITEM_STATUS_PREV => null,
					P_PARENT_WORKITEM_STATUS_CURR => null,
					P_PARENT_DIST_STATUS_PREV => null,
					P_PARENT_DIST_STATUS_CURR => null,
					P_WORKITEM_DIST_STATUS_PREV => 1,
					P_WORKITEM_DIST_STATUS_CURR => l_distribution_status_id,
					P_PRIORITY_PREV => l_priority_id,
					P_PRIORITY_CURR	=> l_priority_id,
					P_DUE_DATE_PREV	=> l_due_date,
					P_DUE_DATE_CURR	=> l_due_date,
					P_RESCHEDULE_TIME_PREV => l_reschedule_time,
					P_RESCHEDULE_TIME_CURR => l_reschedule_time,
					P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
					P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
					P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
					P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
					P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
					P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
					P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
					P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
					P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
					P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
					P_STATUS => l_audit_log_sts,
					P_ERROR_CODE => l_msg_data);commit;

			     end if;

			    if (l_dist_items(j).DISTRIBUTED = 'TRUE')
			    then
				  IF (l_dist_items(j).WORK_ITEM_STATUS is not null)
				  THEN
				    IF (l_dist_items(j).WORK_ITEM_STATUS = 'OPEN')
				    THEN
				      l_work_item_status_id := 0;
				    ELSIF (l_dist_items(j).WORK_ITEM_STATUS = 'CLOSE')
				    THEN
				      l_work_item_status_id := 3;
				    ELSIF (l_dist_items(j).WORK_ITEM_STATUS = 'DELETE')
				    THEN
				      l_work_item_status_id := 4;
				    ELSIF (l_dist_items(j).WORK_ITEM_STATUS = 'SLEEP')
				    THEN
				      l_work_item_status_id := 5;
				    END IF;
				   END IF;

				   --dbms_output.put_line('dist status set to TRUE work item pkid: '||l_dist_items(j).WORKITEM_PK_ID);

				   l_num_of_items_distributed := l_num_of_items_distributed + 1;
				    -- Update the same object
				   l_dist_items(l_dist_items.LAST) := SYSTEM.WR_ITEM_DATA_OBJ(l_dist_items(j).WORK_ITEM_ID,
												 l_dist_items(j).WORKITEM_OBJ_CODE,
												   l_dist_items(j).WORKITEM_PK_ID,
												   l_work_item_status_id,
												   l_dist_items(j).PRIORITY_ID,
												   l_dist_items(j).PRIORITY_LEVEL,
												   l_dist_items(j).PRIORITY_CODE,
												   l_dist_items(j).DUE_DATE,
												   l_dist_items(j).TITLE,
												   l_dist_items(j).PARTY_ID,
												   l_dist_items(j).OWNER_ID,
												   l_dist_items(j).OWNER_TYPE,
												   l_dist_items(j).ASSIGNEE_ID,
												   l_dist_items(j).ASSIGNEE_TYPE,
												   l_dist_items(j).SOURCE_OBJECT_ID,
												   l_dist_items(j).SOURCE_OBJECT_TYPE_CODE,
												   l_dist_items(j).APPLICATION_ID,
												   l_dist_items(j).IEU_ENUM_TYPE_UUID,
												   l_dist_items(j).WORK_ITEM_NUMBER,
												   l_dist_items(j).RESCHEDULE_TIME,
												   l_dist_items(j).WORK_SOURCE,
												   l_dist_items(j).DISTRIBUTED,
												   l_dist_items(j).ITEM_INCLUDED_BY_APP);

				-- If a work item was distributed, copy the Work Item data from table of obj - l_dist_workitem_data
				-- to table of Rec - x_uwqm_workitem_data

				IEU_UWQ_GET_NEXT_WORK_PVT.SET_DIST_AND_DEL_ITEM_DATA_REC(p_var_in_type_code => 'OBJ',
	--                                                                     p_dist_workitem_data => l_dist_workitem_data,
									     p_dist_workitem_data => l_dist_items,
									     p_dist_del_workitem_data => null,
									     x_ctr => l_ctr,
									     x_workitem_action_data => x_uwqm_workitem_data);

				/********************************* Added New Event Deliver *****************************/


				if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') )
				then
					l_event_key := 'DELIVER';
				else
					l_event_key := null;
				end if;
				l_module := 'IEU_GET_NEXT_WORK_PVT.DISTRIBUTE_AND_DELIVER';
				l_application_id := 696;

				l_audit_log_sts := 'S';
				l_ieu_comment_code1 := null;
				l_ieu_comment_code2 := null;
				l_ieu_comment_code3 := null;
				l_ieu_comment_code4 := null;
				l_ieu_comment_code5 := null;

				if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') OR  (l_audit_log_val = 'MINIMAL') )
				then

				     BEGIN

					select reschedule_time, distribution_status_id, priority_id
					into   l_reschedule_time, l_distribution_status_id, l_priority_id
					from   ieu_uwqm_items
					where  workitem_pk_id = l_dist_items(j).workitem_pk_id
					and    workitem_obj_code = l_dist_items(j).workitem_obj_code;

				     EXCEPTION
				       when others then
					 null;
				     END;

				     IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
				     (
					P_ACTION_KEY => l_action_key,
					P_EVENT_KEY =>	l_event_key,
					P_MODULE => l_module,
					P_WS_CODE => l_ws_code,
					P_APPLICATION_ID => l_application_id,
					P_WORKITEM_PK_ID =>l_dist_items(j).workitem_pk_id,
					P_WORKITEM_OBJ_CODE =>l_dist_items(j).workitem_obj_code,
					P_WORK_ITEM_STATUS_PREV =>l_work_item_status_id,
					P_WORK_ITEM_STATUS_CURR	=>l_work_item_status_id,
					P_OWNER_ID_PREV	 =>l_dist_items(j).owner_id,
					P_OWNER_ID_CURR	=>l_dist_items(j).owner_id,
					P_OWNER_TYPE_PREV =>l_dist_items(j).owner_type,
					P_OWNER_TYPE_CURR =>l_dist_items(j).owner_type,
					P_ASSIGNEE_ID_PREV =>l_dist_items(j).assignee_id,
					P_ASSIGNEE_ID_CURR =>l_dist_items(j).assignee_id,
					P_ASSIGNEE_TYPE_PREV =>l_dist_items(j).assignee_type,
					P_ASSIGNEE_TYPE_CURR =>l_dist_items(j).assignee_type,
					P_SOURCE_OBJECT_ID_PREV =>l_dist_items(j).source_object_id,
					P_SOURCE_OBJECT_ID_CURR =>l_dist_items(j).source_object_id,
					P_SOURCE_OBJECT_TYPE_CODE_PREV =>l_dist_items(j).source_object_type_code,
					P_SOURCE_OBJECT_TYPE_CODE_CURR =>l_dist_items(j).source_object_type_code,
					P_PARENT_WORKITEM_STATUS_PREV => null,
					P_PARENT_WORKITEM_STATUS_CURR => null,
					P_PARENT_DIST_STATUS_PREV => null,
					P_PARENT_DIST_STATUS_CURR => null,
					P_WORKITEM_DIST_STATUS_PREV => l_distribution_status_id,
					P_WORKITEM_DIST_STATUS_CURR => l_distribution_status_id,
					P_PRIORITY_PREV => l_priority_id,
					P_PRIORITY_CURR	=> l_priority_id,
					P_DUE_DATE_PREV	=>l_dist_items(j).due_date,
					P_DUE_DATE_CURR	=>l_dist_items(j).due_date,
					P_RESCHEDULE_TIME_PREV => l_reschedule_time,
					P_RESCHEDULE_TIME_CURR => l_reschedule_time,
					P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
					P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
					P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
					P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
					P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
					P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
					P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
					P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
					P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
					P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
					P_STATUS => l_audit_log_sts,
					P_ERROR_CODE => l_msg_data,
					X_AUDIT_LOG_ID => l_audit_log_id,
					X_MSG_DATA => l_msg_data,
					X_RETURN_STATUS => l_ret_sts);commit;

			         end if;
				/***************************************************************************************/
				exit;
			    else
				if ((l_dist_items(j).DISTRIBUTED = 'FALSE') and
				   (l_del_items_flag = 'Y') and
				   (z = l_nw_items_list.last)) then

				       if (l_audit_log_val = 'DETAILED')
				       then
  					   l_ieu_comment_code3 := 'DIST_FAILURE_DELIVERY_ONLY';
				       end if;/* Audit Log Val is detailed */


				       IEU_UWQ_GET_NEXT_WORK_PVT.SET_DIST_AND_DEL_ITEM_DATA_REC(p_var_in_type_code => 'REC',
												p_dist_workitem_data => null,
												p_dist_del_workitem_data => l_del_nw_item,
												x_ctr => l_ctr,
												x_workitem_action_data => x_uwqm_workitem_data);

				      l_num_of_items_distributed := 1;
				end if;
			    end if;/* l_dist_items(j).DISTRIBUTED */
			 end loop;/* l_nw_items.FIRST to LAST */

		     end if; /* l_dist_items.count > 1 */

		  end if; /* l_dist_flag */

		  --dbms_output.put_line('Num of Items Dist: '||l_num_of_items_distributed);

		  if (l_num_of_items_distributed > 0)
		  then
		       --dbms_output.put_line('exiting..');
			exit;
		   end if;


	       end loop; /*l_nw_items_list.first to last */

	   end if; /* l_delivery_only_flag */

	   -- Set the status back to 'Distributable' for the Work Items Selected for Distribution except the Distributed Work Item
	   -- This check is required here for the following reasons
	   -- 1. Any Item out of the 5 we are selecting for Distribution can be Distributed. If for eg. the 2nd item is Distributed
	   --    then the Dist Status for all others should be reset here
	   -- 2. If No Distribution was done, then the Dist Status should be reset here.

	   if (x_uwqm_workitem_data.count >= 1)
	   then
	     for p in x_uwqm_workitem_data.first .. x_uwqm_workitem_data.last
	     loop
		if (x_uwqm_workitem_data(p).param_name = 'WORK_ITEM_ID')
		then
		  l_dist_work_item_id := x_uwqm_workitem_data(p).param_value;
		end if;
	     end loop;
	   end if;

	   if (nvl(l_dist_items_flag,'Y') = 'Y')
	   then
	       --dbms_output.put_line('dist flag = Y.. cnt: '||l_nw_items_list.count);
	       for y in l_nw_items_list.first..l_nw_items_list.last
	       loop
		 -- The work_item_id should not be Distributed Work item Id
		 --dbms_output.put_line('Work item id: '||l_nw_items_list(y).workitem_pk_id);
		 --dbms_output.put_line('Distributed Work Item Id: '||l_dist_work_item_id );
		 if (l_nw_items_list(y).work_item_id <> nvl(l_dist_work_item_id,-1))
		 then
		     update ieu_uwqm_items
		     set distribution_status_id = 1
		     where work_item_id =  l_nw_items_list(y).work_item_id;
		     commit;
		 end if;
	       end loop;
	   end if;

end loop;
   --dbms_output.put_line('# of items distributed '||l_num_of_items_distributed );

/*****************
if (x_uwqm_workitem_data.count > 0)
then
for p in x_uwqm_workitem_data.first .. x_uwqm_workitem_data.last
loop
    dbms_output.put_line('workitem id: '||x_uwqm_workitem_data(p).work_item_id||' obj code: '||x_uwqm_workitem_data(p).WORKITEM_OBJ_CODE||
                         ' obj func: '||x_uwqm_workitem_data(p).IEU_OBJECT_FUNCTION ||
                         ' params: '||x_uwqm_workitem_data(p).IEU_OBJECT_PARAMETERS);
end loop;
end if;
******************/


if (x_uwqm_workitem_data.count < 1)
   then

      raise fnd_api.g_exc_error;
end if;
--commit;
 EXCEPTION

   WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.Count_and_Get
      (
         p_count   =>   x_msg_count,
         p_data    =>   x_msg_data
      );

 WHEN fnd_api.g_exc_unexpected_error THEN

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.Count_and_Get
      (
        p_count   =>   x_msg_count,
        p_data    =>   x_msg_data
      );

 WHEN OTHERS THEN

      x_return_status := fnd_api.g_ret_sts_unexp_error;

     IF FND_MSG_PUB.Check_msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN

        fnd_msg_pub.Count_and_Get
        (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
        );

     END IF;
END DISTRIBUTE_AND_DELIVER_WR_ITEM;

PROCEDURE DISTRIBUTE_WR_ITEMS
 ( p_api_version               IN  NUMBER,
   p_resource_id               IN  NUMBER,
   p_language                  IN  VARCHAR2,
   p_source_lang               IN  VARCHAR2,
   p_num_of_dist_items         IN  NUMBER,                                 -- Number of Items Requested to be Distributed
   p_extra_where_clause        IN  VARCHAR2,
   p_bindvar_list              IN  IEU_UWQ_BINDVAR_LIST,
   x_uwqm_workitem_data       OUT NOCOPY IEU_UWQ_GET_NEXT_WORK_PVT.IEU_WR_ITEM_ACT_DATA_LIST,
   x_num_of_items_distributed OUT NOCOPY NUMBER,                           -- Number of Items finally Distributed
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2,
   x_return_status            OUT NOCOPY VARCHAR2) IS

  -- Used to Validate API version and name
  l_api_version        CONSTANT NUMBER        := 1.0;
  l_api_name           CONSTANT VARCHAR2(30)  := 'DISTRIBUTE_WR_ITEMS';

  l_num_of_items_distributed   NUMBER := 0;  -- Number of Items Distributed
  l_dist_workitem_data         SYSTEM.WR_ITEM_DATA_NST;
  l_dist_items_ctr             NUMBER := 1;
  l_ctr                        NUMBER := 0;
  l_num_of_dist_items          NUMBER := 0; -- Number of Items Requested to be Distributed

  l_object_function            VARCHAR2(40);
  l_object_parameters          VARCHAR2(500);
  l_enter_from_task            VARCHAR2(10);
  l_ws_id                      NUMBER;


BEGIN

x_return_status := fnd_api.g_ret_sts_success;



IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
THEN
      RAISE fnd_api.g_exc_unexpected_error;
END IF;

-- Initialize Message list

FND_MSG_PUB.INITIALIZE;

x_num_of_items_distributed := 0;

loop

   -- exit when one of the following conditions is satisfied
   --  1. Requested Num of Items are distributed (p_num_of_dist_items - Request num of items to be distributed)
   --  2. No more items in Distributable status (flag 'l_num_of_items_distributed ' will be set to -1)
   --  3. Attempt distribution only 2 times. This is done for performance reasons.

   exit when ( (l_num_of_items_distributed >= p_num_of_dist_items) OR
               (l_num_of_items_distributed = -1) OR
               ( l_dist_items_ctr > 2) OR
               (l_num_of_items_distributed > 0) ) ;

   l_num_of_dist_items := p_num_of_dist_items - x_num_of_items_distributed;

 --  dbms_output.put_line('calling get_next_wr_item..requesting '||l_num_of_dist_items ||' items');

   l_dist_deliver_num_of_attempts := l_dist_items_ctr;

   IEU_UWQ_GET_NEXT_WORK_PVT.GET_DIST_WR_ITEMS
     ( p_api_version               => p_api_version,
       p_resource_id               => p_resource_id,
       p_language                  => p_language,
       p_source_lang               => p_source_lang,
       p_num_of_dist_items         => l_num_of_dist_items,
       p_extra_where_clause        => p_extra_where_clause,
       p_bindvar_list              => p_bindvar_list,
       x_uwqm_workitem_data        => l_dist_workitem_data,
       x_num_of_items_distributed  => l_num_of_items_distributed,
       x_msg_count                 => x_msg_count,
       x_msg_data                  => x_msg_data,
       x_return_status             => x_return_status);

   l_dist_items_ctr := l_dist_items_ctr  + 1;

   -- If items were distributed, then copy values from table of objects to table of records.
   -- Also, set the appropriate values for Object Function, Object params etc.

   if (l_num_of_items_distributed <> -1)
   then

       -- The actual num of items distributed will be the sum of items distributed in each attempt
       --  x_num_of_items_distributed - Final num of items distributed
       --  l_num_of_items_distributed - Items distributed this time

       x_num_of_items_distributed := x_num_of_items_distributed  + l_num_of_items_distributed;

       IEU_UWQ_GET_NEXT_WORK_PVT.SET_WR_ITEM_DATA_REC(p_var_in_type_code => 'OBJ',
                                                      p_dist_workitem_data => l_dist_workitem_data,
                                                      p_dist_del_workitem_data => null,
                                                      x_ctr => l_ctr,
                                                      x_uwqm_workitem_data => x_uwqm_workitem_data);

   end if; /* l_num_of_items_distributed <> -1 */

end loop;

--dbms_output.put_line('# of items distributed '||x_num_f_items_distributed ||' cnt: '||x_uwqm_workitem_data.count);


 EXCEPTION

   WHEN fnd_api.g_exc_error THEN

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.Count_and_Get
      (
         p_count   =>   x_msg_count,
         p_data    =>   x_msg_data
      );

 WHEN fnd_api.g_exc_unexpected_error THEN

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.Count_and_Get
      (
        p_count   =>   x_msg_count,
        p_data    =>   x_msg_data
      );

 WHEN OTHERS THEN

      x_return_status := fnd_api.g_ret_sts_unexp_error;

     IF FND_MSG_PUB.Check_msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN

        fnd_msg_pub.Count_and_Get
        (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
        );

     END IF;
END DISTRIBUTE_WR_ITEMS;


/**
 ** Used in Proc - Distribute_wr_items, distribute_and_deliver_wr_item
 **/

/************* Open issues ***********************
*** 1. Handling multiple bind variables - Restrictions on usage of Ref Cursors/Open-for
***    ex: sql_stmt := 'select .... where owner_id = :resource_id or assignee_id = :resource_id';
***      open cur for sql_stmt using In l_res_id
*** 2. Performance enh#
***     - indexes, loops, proc calls
*** 3. Setting Distributing status back to distributable after 2 attempts
**************************************************/

PROCEDURE GET_DIST_WR_ITEMS
 ( p_api_version               IN  NUMBER,
   p_resource_id               IN  NUMBER,
   p_language                  IN  VARCHAR2,
   p_source_lang               IN  VARCHAR2,
   p_num_of_dist_items         IN  NUMBER,
   p_extra_where_clause        IN  VARCHAR2,
   p_bindvar_list              IN  IEU_UWQ_BINDVAR_LIST,
   x_uwqm_workitem_data       OUT NOCOPY SYSTEM.WR_ITEM_DATA_NST,
   x_num_of_items_distributed OUT NOCOPY NUMBER,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2,
   x_return_status            OUT NOCOPY VARCHAR2) IS

  -- Used to Validate API version and name
  l_api_version        CONSTANT NUMBER        := 1.0;
  l_api_name           CONSTANT VARCHAR2(30)  := 'GET_DIST_WR_ITEMS';


l_sql_stmt     		VARCHAR2(4000);
l_dist_status 		NUMBER := 1;
l_open_status_id		NUMBER := 0;
l_resource_id           NUMBER := 100001713;
l_next_wr_items        IEU_UWQ_GET_NEXT_WORK_PVT.l_get_work;


-- Table of records for all OUT variables
l_work_item_num NUMBER;

l_wr_cur  IEU_UWQ_GET_NEXT_WORK_PVT.l_get_work;
l_nw_item IEU_UWQ_GET_NEXT_WORK_PVT.IEU_WR_ITEM_DATA_REC := null;
l_nw_items_list IEU_UWQ_GET_NEXT_WORK_PVT.IEU_WR_ITEM_DATA;

l_nw_items_list2 IEU_UWQ_GET_NEXT_WORK_PVT.IEU_WR_ITEM_DATA;
l_nw_ctr number := 1;
z number := 0;

l_num_of_dist_items_incr number := 0;

/*
l_dist_items  IEU_UWQ_GET_NEXT_WORK_PVT.IEU_WR_DIST_ITEM_DATA;
l_dist_bus_rules  IEU_UWQ_GET_NEXT_WORK_PVT.IEU_WR_DIST_RULES;
*/

l_dist_items  SYSTEM.WR_ITEM_DATA_NST;
l_dist_bus_rules  SYSTEM.DIST_BUS_RULES_NST;

L_MSG_COUNT NUMBER;
L_MSG_DATA VARCHAR2(4000);
L_RETURN_STATUS VARCHAR2(10);
l_ctr NUMBER := 1;
l_curr_ws_id  NUMBER;
l_priority_code IEU_UWQM_PRIORITIES_B.PRIORITY_CODE%TYPE;
l_ws_code VARCHAR2(500);
l_work_item_status  VARCHAR2(500);
l_work_item_status_id NUMBER;
l_wr_cur_cnt NUMBER;
cursor_id    PLS_INTEGER;
dummy        PLS_INTEGER;
temp number;


l_not_valid_flag VARCHAR2(1);
cursor c_ws is
select WS_B.WS_ID, 'INDIVIDUAL_ASSIGNED' DISTRIBUTE_TO, 'GROUP_OWNED' DISTRIBUTE_FROM , WS_B.DISTRIBUTION_FUNCTION ,
WS_A.DIST_ST_BASED_ON_PARENT_FLAG, WS_B.WS_CODE
from IEU_UWQM_WORK_SOURCES_B WS_B, IEU_UWQM_WS_ASSCT_PROPS WS_A
where ws_b.not_valid_flag = l_not_valid_flag
and   ws_b.ws_id = ws_a.ws_id(+);

-- Audit Trail
  l_action_key  VARCHAR2(500);
  l_event_key  VARCHAR2(500);
  l_module VARCHAR2(1000);
  l_application_id NUMBER;
  --l_ws_code VARCHAR2(500);
  l_ret_sts VARCHAR2(10);
  l_audit_log_val VARCHAR2(100);
  l_ieu_comment_code1 VARCHAR2(2000);
  l_ieu_comment_code2 VARCHAR2(2000);
  l_ieu_comment_code3 VARCHAR2(2000);
  l_ieu_comment_code4 VARCHAR2(2000);
  l_ieu_comment_code5 VARCHAR2(2000);
  l_workitem_comment_code1 VARCHAR2(2000);
  l_workitem_comment_code2 VARCHAR2(2000);
  l_workitem_comment_code3 VARCHAR2(2000);
  l_workitem_comment_code4 VARCHAR2(2000);
  l_workitem_comment_code5 VARCHAR2(2000);

  l_workitem_pk_id NUMBER;
  l_workitem_obj_code VARCHAR2(50);
  l_audit_log_sts VARCHAR2(50);
  l_owner_id NUMBER;
  l_owner_type VARCHAR2(500);
  l_assignee_id NUMBER;
  l_assignee_type VARCHAR2(500);
  l_priority_id  NUMBER;
  l_due_date DATE;
  l_source_object_id  NUMBER;
  l_source_object_type_code VARCHAR2(500);
  l_status_id NUMBER;
  l_distribution_status_id NUMBER;
  l_reschedule_time DATE;
  l_token_str VARCHAR2(4000);
--  l_audit_log_id	       NUMBER;
  TYPE AUDIT_LOG_ID_TBL is TABLE OF NUMBER  INDEX BY BINARY_INTEGER;
  l_audit_log_id_list AUDIT_LOG_ID_TBL;
v varchar2(1000);
BEGIN
    l_not_valid_flag := 'N';
    x_return_status := fnd_api.g_ret_sts_success;

l_audit_log_val := FND_PROFILE.VALUE('IEU_WR_DIST_AUDIT_LOG');

    IF NOT fnd_api.compatible_api_call (
                l_api_version,
                p_api_version,
                l_api_name,
                g_pkg_name
             )
    THEN
         RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize Message list

    FND_MSG_PUB.INITIALIZE;

  x_uwqm_workitem_data  := SYSTEM.WR_ITEM_DATA_NST();

  -- Get the Where Clause
--  IEU_UWQ_GET_NEXT_WORK_PVT.GET_WS_WHERE_CLAUSE('DIST_FROM',l_where_clause);

  -- Build the complete select stmt
  l_sql_stmt := 'SELECT /*+ first_rows */
                	WORK_ITEM_ID,
			WORKITEM_OBJ_CODE,
			WORKITEM_PK_ID,
			STATUS_ID,
			PRIORITY_ID,
			PRIORITY_LEVEL,
                  null,   -- Selecting null for pty code
			DUE_DATE,
			TITLE,
			PARTY_ID,
			OWNER_ID,
			OWNER_TYPE,
			ASSIGNEE_ID,
			ASSIGNEE_TYPE,
			SOURCE_OBJECT_ID,
			SOURCE_OBJECT_TYPE_CODE,
			APPLICATION_ID,
			IEU_ENUM_TYPE_UUID,
			WORK_ITEM_NUMBER,
			RESCHEDULE_TIME,
			WS_ID
                 FROM IEU_UWQM_ITEMS '||
               ' WHERE ' || ' ( ' ||p_extra_where_clause || ' ) '||
               ' AND DISTRIBUTION_STATUS_ID = :l_dist_status' ||
               ' AND STATUS_ID = :l_status_id ' ||
               ' and    reschedule_time <= sysdate ' ||
--               l_where_clause ||' ) '||
--               ' ) AND rownum <= '|| p_num_of_dist_items||
--               ' ) AND rownum <= :p_num_of_dist_items '||
               ' order by priority_level, due_date '||
               ' for update skip locked ';

--  insert into p_temp(msg) values ('sql- '||l_sql_stmt||' res id : '||p_resource_id||' dist stat: '||l_dist_status||' open stat '||l_open_status_id); commit;

  -- Select the items based on Business rules

--  OPEN l_wr_cur FOR l_sql_stmt
--  USING  IN l_dist_status, IN l_open_status_id;

  cursor_id := dbms_sql.open_cursor;
  DBMS_SQL.PARSE(cursor_id, l_sql_stmt, dbms_sql.native);
  DBMS_SQL.BIND_VARIABLE(cursor_id,':l_dist_status', l_dist_status);
  DBMS_SQL.BIND_VARIABLE(cursor_id,':l_status_id', l_open_status_id);

  for i in 1..p_bindvar_list.count loop
      DBMS_SQL.BIND_VARIABLE(cursor_id,p_bindvar_list(i).bind_name, p_bindvar_list(i).value);

  end loop;


--  USING IN l_dist_status, IN l_open_status_id, IN p_resource_id, IN p_num_of_dist_items;
--  USING IN l_dist_status, IN l_open_status_id, IN p_resource_id;

  l_wr_cur_cnt := 1;

             DBMS_SQL.DEFINE_COLUMN(cursor_id,1,l_nw_item.WORK_ITEM_ID);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,2,l_nw_item.WORKITEM_OBJ_CODE,30);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,3,l_nw_item.WORKITEM_PK_ID);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,4,l_nw_item.STATUS_ID);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,5,l_nw_item.PRIORITY_ID);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,6,l_nw_item.PRIORITY_LEVEL);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,7,l_nw_item.PRIORITY_CODE,30);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,8,l_nw_item.DUE_DATE);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,9,l_nw_item.TITLE,1990);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,10,l_nw_item.PARTY_ID);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,11,l_nw_item.OWNER_ID);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,12,l_nw_item.OWNER_TYPE,25);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,13,l_nw_item.ASSIGNEE_ID);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,14,l_nw_item.ASSIGNEE_TYPE,25);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,15,l_nw_item.SOURCE_OBJECT_ID);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,16,l_nw_item.SOURCE_OBJECT_TYPE_CODE,30);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,17,l_nw_item.APPLICATION_ID);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,18,l_nw_item.IEU_ENUM_TYPE_UUID,38);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,19,l_nw_item.WORK_ITEM_NUMBER,64);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,20,l_nw_item.RESCHEDULE_TIME);
             DBMS_SQL.DEFINE_COLUMN(cursor_id,21,l_nw_item.WS_ID);



--    FETCH l_wr_cur into l_nw_item;

       dummy := DBMS_SQL.EXECUTE(cursor_id);

       LOOP
            temp := DBMS_SQL.FETCH_ROWS(cursor_id);

            if p_num_of_dist_items <= 2 then
               l_num_of_dist_items_incr := p_num_of_dist_items * 4;
            elsif p_num_of_dist_items > 2 and p_num_of_dist_items <= 4 then
               l_num_of_dist_items_incr := p_num_of_dist_items * 3;
            elsif p_num_of_dist_items > 4 and p_num_of_dist_items <=6 then
               l_num_of_dist_items_incr := P_num_of_dist_items * 2;
            elsif p_num_of_dist_items > 6 then
               l_num_of_dist_items_incr := p_num_of_dist_items;
            end if;
            if  temp = 0 or (l_wr_cur_cnt > l_num_of_dist_items_incr) then
               exit;
           elsif temp <> 0 then

             DBMS_SQL.COLUMN_VALUE(cursor_id,1,l_nw_item.WORK_ITEM_ID);
             DBMS_SQL.COLUMN_VALUE(cursor_id,2,l_nw_item.WORKITEM_OBJ_CODE);
             DBMS_SQL.COLUMN_VALUE(cursor_id,3,l_nw_item.WORKITEM_PK_ID);
             DBMS_SQL.COLUMN_VALUE(cursor_id,4,l_nw_item.STATUS_ID);
             DBMS_SQL.COLUMN_VALUE(cursor_id,5,l_nw_item.PRIORITY_ID);
             DBMS_SQL.COLUMN_VALUE(cursor_id,6,l_nw_item.PRIORITY_LEVEL);
             DBMS_SQL.COLUMN_VALUE(cursor_id,7,l_nw_item.PRIORITY_CODE);
             DBMS_SQL.COLUMN_VALUE(cursor_id,8,l_nw_item.DUE_DATE);
             DBMS_SQL.COLUMN_VALUE(cursor_id,9,l_nw_item.TITLE);
             DBMS_SQL.COLUMN_VALUE(cursor_id,10,l_nw_item.PARTY_ID);
             DBMS_SQL.COLUMN_VALUE(cursor_id,11,l_nw_item.OWNER_ID);
             DBMS_SQL.COLUMN_VALUE(cursor_id,12,l_nw_item.OWNER_TYPE);
             DBMS_SQL.COLUMN_VALUE(cursor_id,13,l_nw_item.ASSIGNEE_ID);
             DBMS_SQL.COLUMN_VALUE(cursor_id,14,l_nw_item.ASSIGNEE_TYPE);
             DBMS_SQL.COLUMN_VALUE(cursor_id,15,l_nw_item.SOURCE_OBJECT_ID);
             DBMS_SQL.COLUMN_VALUE(cursor_id,16,l_nw_item.SOURCE_OBJECT_TYPE_CODE);
             DBMS_SQL.COLUMN_VALUE(cursor_id,17,l_nw_item.APPLICATION_ID);
             DBMS_SQL.COLUMN_VALUE(cursor_id,18,l_nw_item.IEU_ENUM_TYPE_UUID);
             DBMS_SQL.COLUMN_VALUE(cursor_id,19,l_nw_item.WORK_ITEM_NUMBER);
             DBMS_SQL.COLUMN_VALUE(cursor_id,20,l_nw_item.RESCHEDULE_TIME);
             DBMS_SQL.COLUMN_VALUE(cursor_id,21,l_nw_item.WS_ID);
         end if;



   -- exit when ( (l_wr_cur%NOTFOUND) OR (l_wr_cur_cnt > l_num_of_dist_items_incr) ) ;

    l_wr_cur_cnt := l_wr_cur_cnt + 1;

    -- update work item status to distributing
    update ieu_uwqm_items
    set distribution_status_id = 2
    where work_item_id = l_nw_item.WORK_ITEM_ID;


    -- Add items to the Table of rec
    select priority_code
    into   l_priority_code
    from ieu_uwqm_priorities_b
    where priority_id = l_nw_item.PRIORITY_ID;

    l_nw_items_list(l_ctr).WORK_ITEM_ID            :=   l_nw_item.WORK_ITEM_ID;
    l_nw_items_list(l_ctr).WORKITEM_OBJ_CODE       :=   l_nw_item.WORKITEM_OBJ_CODE;
    l_nw_items_list(l_ctr).WORKITEM_PK_ID          :=   l_nw_item.WORKITEM_PK_ID;
    l_nw_items_list(l_ctr).STATUS_ID               :=   l_nw_item.STATUS_ID;
    l_nw_items_list(l_ctr).PRIORITY_CODE           :=   l_priority_code;
    l_nw_items_list(l_ctr).DUE_DATE                :=   l_nw_item.DUE_DATE;
    l_nw_items_list(l_ctr).TITLE                   :=   l_nw_item.TITLE;
    l_nw_items_list(l_ctr).PARTY_ID                :=   l_nw_item.PARTY_ID;
    l_nw_items_list(l_ctr).OWNER_ID                :=   l_nw_item.OWNER_ID;
    l_nw_items_list(l_ctr).OWNER_TYPE              :=   l_nw_item.OWNER_TYPE;
    l_nw_items_list(l_ctr).ASSIGNEE_ID             :=   l_nw_item.ASSIGNEE_ID;
    l_nw_items_list(l_ctr).ASSIGNEE_TYPE           :=   l_nw_item.ASSIGNEE_TYPE;
    l_nw_items_list(l_ctr).SOURCE_OBJECT_ID        :=   l_nw_item.SOURCE_OBJECT_ID;
    l_nw_items_list(l_ctr).SOURCE_OBJECT_TYPE_CODE :=   l_nw_item.SOURCE_OBJECT_TYPE_CODE;
    l_nw_items_list(l_ctr).APPLICATION_ID          :=   l_nw_item.APPLICATION_ID;
    l_nw_items_list(l_ctr).IEU_ENUM_TYPE_UUID      :=   l_nw_item.IEU_ENUM_TYPE_UUID;
    l_nw_items_list(l_ctr).WORK_ITEM_NUMBER        :=   l_nw_item.WORK_ITEM_NUMBER;
    l_nw_items_list(l_ctr).RESCHEDULE_TIME         :=   l_nw_item.RESCHEDULE_TIME;
    l_nw_items_list(l_ctr).WS_ID                   :=   l_nw_item.WS_ID;

    l_ctr := l_ctr + 1;

  END LOOP;
  DBMS_SQL.CLOSE_CURSOR(cursor_id);

--   CLOSE l_wr_cur;
  commit;

  -- dbms_output.put_line('item cnt: '||l_nw_items_list.COUNT);

  -- Check if there any any Distributable Items for this resource
  -- x_num_of_items_distributed will be set to -1 if there are no Distributable Items

  if (l_nw_items_list.COUNT < 1)
  then
        x_num_of_items_distributed := -1;
  else
        x_num_of_items_distributed := 0;
  end if;

  --dbms_output.put_line('dist flag: '||x_num_of_items_distributed);

  -- If there are distributable items for this resource then
  --  1. get the distribution rules for each work source
  --  2. Select the Distributable Work Item details
  --  3. call the appropriate distribution function based on the Work Source

  if  (x_num_of_items_distributed <> -1)
  then

     while (l_nw_ctr <= l_nw_items_list.count)
     loop

          z := z +1;

--        insert into p_temp values(p_num_of_dist_items||' '||x_num_of_items_distributed||' '||z||' '||l_nw_ctr, 10001);commit;

       if (z <= (p_num_of_dist_items - x_num_of_items_distributed)) then

        l_nw_items_list2(z).WORK_ITEM_ID            :=   l_nw_items_list(l_nw_ctr).WORK_ITEM_ID;
        l_nw_items_list2(z).WORKITEM_OBJ_CODE       :=   l_nw_items_list(l_nw_ctr).WORKITEM_OBJ_CODE;
        l_nw_items_list2(z).WORKITEM_PK_ID          :=   l_nw_items_list(l_nw_ctr).WORKITEM_PK_ID;
        l_nw_items_list2(z).STATUS_ID               :=   l_nw_items_list(l_nw_ctr).STATUS_ID;
        l_nw_items_list2(z).PRIORITY_CODE           :=   l_nw_items_list(l_nw_ctr).priority_code;
        l_nw_items_list2(z).DUE_DATE                :=   l_nw_items_list(l_nw_ctr).DUE_DATE;
        l_nw_items_list2(z).TITLE                   :=   l_nw_items_list(l_nw_ctr).TITLE;
        l_nw_items_list2(z).PARTY_ID                :=   l_nw_items_list(l_nw_ctr).PARTY_ID;
        l_nw_items_list2(z).OWNER_ID                :=   l_nw_items_list(l_nw_ctr).OWNER_ID;
        l_nw_items_list2(z).OWNER_TYPE              :=   l_nw_items_list(l_nw_ctr).OWNER_TYPE;
        l_nw_items_list2(z).ASSIGNEE_ID             :=   l_nw_items_list(l_nw_ctr).ASSIGNEE_ID;
        l_nw_items_list2(z).ASSIGNEE_TYPE           :=   l_nw_items_list(l_nw_ctr).ASSIGNEE_TYPE;
        l_nw_items_list2(z).SOURCE_OBJECT_ID        :=   l_nw_items_list(l_nw_ctr).SOURCE_OBJECT_ID;
        l_nw_items_list2(z).SOURCE_OBJECT_TYPE_CODE :=   l_nw_items_list(l_nw_ctr).SOURCE_OBJECT_TYPE_CODE;
        l_nw_items_list2(z).APPLICATION_ID          :=   l_nw_items_list(l_nw_ctr).APPLICATION_ID;
        l_nw_items_list2(z).IEU_ENUM_TYPE_UUID      :=   l_nw_items_list(l_nw_ctr).IEU_ENUM_TYPE_UUID;
        l_nw_items_list2(z).WORK_ITEM_NUMBER        :=   l_nw_items_list(l_nw_ctr).WORK_ITEM_NUMBER;
        l_nw_items_list2(z).RESCHEDULE_TIME         :=   l_nw_items_list(l_nw_ctr).RESCHEDULE_TIME;
        l_nw_items_list2(z).WS_ID                   :=   l_nw_items_list(l_nw_ctr).WS_ID;

        end if;

        if x_num_of_items_distributed = p_num_of_dist_items then
            exit;
        else
            l_nw_ctr := l_nw_ctr + z;
            z := 0;
        end if;


      --     dbms_output.put_line('getting ws id');
      -- loop thru all seeded Work sources
      for cur_rec in c_ws
      loop

          l_curr_ws_id := cur_rec.ws_id;
          l_ws_code    := cur_rec.ws_code;

/*
          begin
            select ws_code
            into   l_ws_name
            from   ieu_uwqm_work_sources_b
            where  ws_id = l_curr_ws_id;
          exception
            when others then
             l_ws_name := '';
          end;
*/
          --dbms_output.put_line('curr ws id: '||l_curr_ws_id);

          -- Get the Business rules to be passed to the Distribution Function
          l_dist_bus_rules := SYSTEM.DIST_BUS_RULES_NST();

          l_dist_bus_rules.extend;
          l_dist_bus_rules(l_dist_bus_rules.last) :=  SYSTEM.DIST_BUS_RULES_OBJ ( l_ws_code,
                                                                                  cur_rec.distribute_from,
                                                                                  cur_rec.distribute_to,
                                                                                  cur_rec.DIST_ST_BASED_ON_PARENT_FLAG);


          if (l_audit_log_val = 'DETAILED')
	  then

		 if (cur_rec.distribute_from = 'GROUP_OWNED') and
			(cur_rec.distribute_to = 'INDIVIDUAL_OWNED')
		 then
			l_ieu_comment_code3 := 'GO_IO';
		 elsif (cur_rec.distribute_from = 'GROUP_OWNED') and
			  (cur_rec.distribute_to = 'INDIVIDUAL_ASSIGNED')
		 then
			l_ieu_comment_code3 := 'GO_IA';
		 elsif (cur_rec.distribute_from = 'GROUP_ASSIGNED') and
			 (cur_rec.distribute_to = 'INDIVIDUAL_OWNED')
		 then
			l_ieu_comment_code3 := 'GA_IO';
		 elsif (cur_rec.distribute_from = 'GROUP_ASSIGNED') and
			 (cur_rec.distribute_to = 'INDIVIDUAL_ASSIGNED')
		 then
			l_ieu_comment_code3 := 'GA_IA';
		 end if;
          end if;
          --dbms_output.put_line('loop 5');

          --dbms_output.put_line('bus rules: '||l_dist_bus_rules.count);

          -- Initialize this table for new WS
          l_dist_items := SYSTEM.WR_ITEM_DATA_NST();

          for i in l_nw_items_list2.first .. l_nw_items_list2.last
          loop


               -- group the Distributable Work Items based on Work Source
               if (l_nw_items_list2(i).ws_id = l_curr_ws_id)
               then

                    if (l_nw_items_list2(i).STATUS_ID = 0)
                    then
                       l_work_item_status := 'OPEN';
                    elsif (l_nw_items_list2(i).STATUS_ID = 3)
                    then
                       l_work_item_status := 'CLOSE';
                    elsif (l_nw_items_list2(i).STATUS_ID = 4)
                    then
                       l_work_item_status := 'DELETE';
                    elsif (l_nw_items_list2(i).STATUS_ID = 5)
                    then
                       l_work_item_status := 'SLEEP';
                    end if;

                    --dbms_output.put_line('ws id matches: '||l_nw_items_list(i).ws_id|| ' ID: '||l_nw_items_list(i).WORKITEM_PK_ID);
                    l_dist_items.extend;
                    l_dist_items(l_dist_items.last) := SYSTEM.WR_ITEM_DATA_OBJ(l_nw_items_list2(i).WORK_ITEM_ID,
			  				 			         l_nw_items_list2(i).WORKITEM_OBJ_CODE,
	    										   l_nw_items_list2(i).WORKITEM_PK_ID,
	    										   l_work_item_status,
	    										   l_nw_items_list2(i).PRIORITY_ID,
	    										   l_nw_items_list2(i).PRIORITY_LEVEL,
	    										   l_nw_items_list2(i).PRIORITY_CODE,
	    										   l_nw_items_list2(i).DUE_DATE,
	    										   l_nw_items_list2(i).TITLE,
	    										   l_nw_items_list2(i).PARTY_ID,
	    										   l_nw_items_list2(i).OWNER_ID,
	    										   l_nw_items_list2(i).OWNER_TYPE,
    	    										   l_nw_items_list2(i).ASSIGNEE_ID,
	    										   l_nw_items_list2(i).ASSIGNEE_TYPE,
	    										   l_nw_items_list2(i).SOURCE_OBJECT_ID,
	    										   l_nw_items_list2(i).SOURCE_OBJECT_TYPE_CODE,
	    										   l_nw_items_list2(i).APPLICATION_ID,
	    										   l_nw_items_list2(i).IEU_ENUM_TYPE_UUID,
	    										   l_nw_items_list2(i).WORK_ITEM_NUMBER,
	    										   l_nw_items_list2(i).RESCHEDULE_TIME,
											   l_ws_code,   --l_nw_items_list(i).WS_ID,
											   null,
											   null);
                end if;

           end loop;  /* l_nw_items_list2 */


           --dbms_output.put_line('dist items cnt'||l_dist_items.count);

            -- Call the Distribution Function


            if (l_dist_items.count > 0)
            then
--                 insert into p_temp values('calling dist func', 1001);commit;
                 --dbms_output.put_line('calling dist func');

  	       if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') OR  (l_audit_log_val = 'MINIMAL') )
	       then

                     for k in l_dist_items.first .. l_dist_items.last
                     loop

			 IEU_UWQM_AUDIT_LOG_PKG.INSERT_ROW
			 (
				P_ACTION_KEY => l_action_key,
				P_EVENT_KEY =>	l_event_key,
				P_MODULE => l_module,
				P_WS_CODE => l_ws_code,
				P_APPLICATION_ID => l_application_id,
				P_WORKITEM_PK_ID => l_dist_items(k).workitem_pk_id,
				P_WORKITEM_OBJ_CODE => l_dist_items(k).workitem_obj_code,
				P_WORK_ITEM_STATUS_PREV => l_status_id,
				P_WORK_ITEM_STATUS_CURR	=> l_status_id,
				P_OWNER_ID_PREV	 => l_dist_items(k).owner_id,
				P_OWNER_ID_CURR	=> l_dist_items(k).owner_id,
				P_OWNER_TYPE_PREV => l_dist_items(k).owner_type,
				P_OWNER_TYPE_CURR => l_dist_items(k).owner_type,
				P_ASSIGNEE_ID_PREV => null,
				P_ASSIGNEE_ID_CURR => l_dist_items(k).assignee_id,
				P_ASSIGNEE_TYPE_PREV => null,
				P_ASSIGNEE_TYPE_CURR => l_dist_items(k).assignee_type,
				P_SOURCE_OBJECT_ID_PREV => l_dist_items(k).source_object_id,
				P_SOURCE_OBJECT_ID_CURR => l_dist_items(k).source_object_id,
				P_SOURCE_OBJECT_TYPE_CODE_PREV => l_dist_items(k).source_object_type_code,
				P_SOURCE_OBJECT_TYPE_CODE_CURR => l_dist_items(k).source_object_type_code,
				P_PARENT_WORKITEM_STATUS_PREV => null,
				P_PARENT_WORKITEM_STATUS_CURR => null,
				P_PARENT_DIST_STATUS_PREV => null,
				P_PARENT_DIST_STATUS_CURR => null,
				P_WORKITEM_DIST_STATUS_PREV => l_distribution_status_id,
				P_WORKITEM_DIST_STATUS_CURR => l_distribution_status_id,
				P_PRIORITY_PREV => l_dist_items(k).priority_id,
				P_PRIORITY_CURR	=> l_dist_items(k).priority_id,
				P_DUE_DATE_PREV	=> l_dist_items(k).due_date,
				P_DUE_DATE_CURR	=> l_dist_items(k).due_date,
				P_RESCHEDULE_TIME_PREV => l_reschedule_time,
				P_RESCHEDULE_TIME_CURR => l_reschedule_time,
				P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
				P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
				P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
				P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
				P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
				P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
				P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
				P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
				P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
				P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
				P_STATUS => 'S',
				P_ERROR_CODE => x_msg_data,
				X_AUDIT_LOG_ID => l_audit_log_id_list(k),
				X_MSG_DATA => x_msg_data,
				X_RETURN_STATUS => l_ret_sts
			 );

		     end loop;
		 end if;

		-- Set the Resource_id and type in IEU_WR_PUB
		--IEU_WR_PUB.l_dist_resource_id := p_resource_id;
		--IEU_WR_PUB.l_dist_resource_type := 'RS_INDIVIDUAL';

                 BEGIN
                   EXECUTE IMMEDIATE
                     'BEGIN '|| cur_rec.DISTRIBUTION_FUNCTION||'(:1,:2,:3,:4,:5,:6,:7,:8,:9); END;'
                   USING IN P_RESOURCE_ID, IN P_LANGUAGE, IN  P_SOURCE_LANG, IN P_NUM_OF_DIST_ITEMS, IN L_DIST_BUS_RULES, IN OUT L_DIST_ITEMS,
                      OUT L_MSG_COUNT, OUT L_MSG_DATA, OUT L_RETURN_STATUS;
                 EXCEPTION
                    when others then

		   -- insert into p_temp(msg) values('exception');
                     -- Set the status back from 'Distributing' to 'Distributable'
                     for k in l_dist_items.first .. l_dist_items.last
                     loop
		          l_workitem_pk_id := l_dist_items(k).workitem_pk_id;
			  l_workitem_obj_code := l_dist_items(k).workitem_obj_code;
			  l_owner_id := l_dist_items(k).owner_id;
			  l_owner_type := l_dist_items(k).owner_type;
			  l_assignee_id := l_dist_items(k).assignee_id;
			  l_assignee_type := l_dist_items(k).assignee_type;
			  l_priority_id := l_dist_items(k).priority_id;
			  l_due_date := l_dist_items(k).due_date;
			  l_source_object_id := l_dist_items(k).source_object_id;
			  l_source_object_type_code := l_dist_items(k).source_object_type_code;
			  if (l_dist_items(k).work_item_status = 'OPEN')
			  then
			       l_status_id := 0;
			  elsif (l_dist_items(k).work_item_status = 'CLOSE')
			  then
			       l_status_id := 3;
			  elsif (l_dist_items(k).work_item_status = 'DELETE')
			  then
			       l_status_id := 4;
			  elsif (l_dist_items(k).work_item_status = 'SLEEP')
			  then
			       l_status_id := 5;
			  end if;

 --                        insert into p_temp values('dist func failed '||l_return_status||' '||l_msg_data, l_dist_items(k).work_item_id);commit;
                          update ieu_uwqm_items
                          set distribution_status_id = 1
                          where work_item_id = l_dist_items(k).work_item_id;
                          commit;

			  -- Set the Resource_id and type in IEU_WR_PUB

			     l_action_key := 'DISTRIBUTION';
			     if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED'))
			     then
				  l_event_key := 'DISTRIBUTE';
			     else
				  l_event_key := null;
			     end if;
			     l_module := 'IEU_GET_NEXT_WORK_PVT.DISTRIBUTE_WR_ITEMS';
			     l_application_id := 696;
			     l_ret_sts := 'E';
			     l_token_str := SQLCODE||': '||SQLERRM;
			     --l_token_str := SQLERRM;
			     --insert into p_temp('errcode: '||SQLCODE);
			     --insert inot p_temp('errm: '||SQLERRM);

			     FND_MSG_PUB.INITIALIZE;
			     FND_MESSAGE.SET_NAME('IEU', 'IEU_SQL_ERROR');
			     FND_MESSAGE.SET_TOKEN('PACKAGE_NAME','IEU_GET_NEXT_WORK_PVT.DISTRIBUTE_AND_DELIVER');
			     FND_MESSAGE.SET_TOKEN('SQL_ERROR_MSG',l_token_str);
			     fnd_msg_pub.ADD;

			     fnd_msg_pub.Count_and_Get
				 (
				  p_count   =>   x_msg_count,
				  p_data    =>   x_msg_data
				 );


			     if (l_audit_log_val = 'DETAILED')
			     then
				    l_ieu_comment_code1 := 'NUM_OF_ATTEMPTS '||l_dist_deliver_num_of_attempts;
				    l_ieu_comment_code2 := 'DISTRIBUTION_FUNC '||cur_rec.DISTRIBUTION_FUNCTION;
			     end if;


			     if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') OR  (l_audit_log_val = 'MINIMAL') )
			     then

					     BEGIN

						select reschedule_time, distribution_status_id, priority_id
						into   l_reschedule_time, l_distribution_status_id, l_priority_id
						from   ieu_uwqm_items
						where  workitem_pk_id = l_workitem_pk_id
						and    workitem_obj_code = l_workitem_obj_code;

					     EXCEPTION
					       when others then
						 null;
					     END;

					     l_distribution_status_id := 1;
					     l_msg_data:= x_msg_data;

					     IEU_UWQM_AUDIT_LOG_PKG.UPDATE_ROW
					     (
						P_AUDIT_LOG_ID => l_audit_log_id_list(k),
						P_ACTION_KEY => l_action_key,
						P_EVENT_KEY =>	l_event_key,
						P_MODULE => l_module,
						P_WS_CODE => l_ws_code,
						P_APPLICATION_ID => l_application_id,
						P_WORKITEM_PK_ID => l_workitem_pk_id,
						P_WORKITEM_OBJ_CODE => l_workitem_obj_code,
						P_WORK_ITEM_STATUS_PREV => l_status_id,
						P_WORK_ITEM_STATUS_CURR	=> l_status_id,
						P_OWNER_ID_PREV	 => l_owner_id,
						P_OWNER_ID_CURR	=> l_owner_id,
						P_OWNER_TYPE_PREV => l_owner_type,
						P_OWNER_TYPE_CURR => l_owner_type,
						P_ASSIGNEE_ID_PREV => null,
						P_ASSIGNEE_ID_CURR => l_assignee_id,
						P_ASSIGNEE_TYPE_PREV => null,
						P_ASSIGNEE_TYPE_CURR => l_assignee_type,
						P_SOURCE_OBJECT_ID_PREV => l_source_object_id,
						P_SOURCE_OBJECT_ID_CURR => l_source_object_id,
						P_SOURCE_OBJECT_TYPE_CODE_PREV => l_source_object_type_code,
						P_SOURCE_OBJECT_TYPE_CODE_CURR => l_source_object_type_code,
						P_PARENT_WORKITEM_STATUS_PREV => null,
						P_PARENT_WORKITEM_STATUS_CURR => null,
						P_PARENT_DIST_STATUS_PREV => null,
						P_PARENT_DIST_STATUS_CURR => null,
						P_WORKITEM_DIST_STATUS_PREV => l_distribution_status_id,
						P_WORKITEM_DIST_STATUS_CURR => l_distribution_status_id,
						P_PRIORITY_PREV => l_priority_id,
						P_PRIORITY_CURR	=> l_priority_id,
						P_DUE_DATE_PREV	=> l_due_date,
						P_DUE_DATE_CURR	=> l_due_date,
						P_RESCHEDULE_TIME_PREV => l_reschedule_time,
						P_RESCHEDULE_TIME_CURR => l_reschedule_time,
						P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
						P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
						P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
						P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
						P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
						P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
						P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
						P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
						P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
						P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
						P_STATUS => 'E',
						P_ERROR_CODE => l_msg_data);

					 -- insert into p_temp(msg) values('l_msg_data3: '||x_msg_data);

			 end if;
                     end loop;
                 END;

                 -- Check the # of items distributed

                 for j in l_dist_items.first .. l_dist_items.last
                 loop

			l_workitem_pk_id := l_dist_items(j).workitem_pk_id;
			l_workitem_obj_code := l_dist_items(j).workitem_obj_code;
			l_owner_id := l_dist_items(j).owner_id;
			l_owner_type := l_dist_items(j).owner_type;
			l_assignee_id := l_dist_items(j).assignee_id;
			l_assignee_type := l_dist_items(j).assignee_type;
			l_priority_id := l_dist_items(j).priority_id;
			l_due_date := l_dist_items(j).due_date;
			l_source_object_id := l_dist_items(j).source_object_id;
			l_source_object_type_code := l_dist_items(j).source_object_type_code;
			if (l_dist_items(j).work_item_status = 'OPEN')
			then
			     l_status_id := 0;
			elsif (l_dist_items(j).work_item_status = 'CLOSE')
			then
			     l_status_id := 3;
			elsif (l_dist_items(j).work_item_status = 'DELETE')
			then
			     l_status_id := 4;
			elsif (l_dist_items(j).work_item_status = 'SLEEP')
			then
			     l_status_id := 5;
			end if;


		        l_action_key := 'DISTRIBUTION';
		        if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED'))
		        then
			  l_event_key := 'DISTRIBUTE';
		        else
			  l_event_key := null;
		        end if;
			l_module := 'IEU_GET_NEXT_WORK_PVT.DISTRIBUTE_WR_ITEMS';
			l_application_id := 696;

			if (l_audit_log_val = 'DETAILED')
			then
			    l_ieu_comment_code1 := 'NUM_OF_ATTEMPTS '||l_dist_deliver_num_of_attempts;
			    l_ieu_comment_code2 := 'DISTRIBUTION_FUNC '||cur_rec.DISTRIBUTION_FUNCTION;
			end if;

			if (l_dist_items(j).DISTRIBUTED = 'TRUE')
			then
			    l_audit_log_sts := 'S';
			    l_distribution_status_id := 3;
			else
		            l_audit_log_sts := 'E';
			    l_distribution_status_id := 1;
			end if;

			if ( (l_audit_log_val = 'FULL') OR (l_audit_log_val = 'DETAILED') OR  (l_audit_log_val = 'MINIMAL') )
			then

				     BEGIN

					select reschedule_time, priority_id
					into   l_reschedule_time, l_priority_id
					from   ieu_uwqm_items
					where  workitem_pk_id = l_workitem_pk_id
					and    workitem_obj_code = l_workitem_obj_code;

				     EXCEPTION
				       when others then
					 null;
				     END;

				     IEU_UWQM_AUDIT_LOG_PKG.UPDATE_ROW
				     (
				        P_AUDIT_LOG_ID => l_audit_log_id_list(j),
					P_ACTION_KEY => l_action_key,
					P_EVENT_KEY =>	l_event_key,
					P_MODULE => l_module,
					P_WS_CODE => l_ws_code,
					P_APPLICATION_ID => l_application_id,
					P_WORKITEM_PK_ID => l_workitem_pk_id,
					P_WORKITEM_OBJ_CODE => l_workitem_obj_code,
					P_WORK_ITEM_STATUS_PREV => l_status_id,
					P_WORK_ITEM_STATUS_CURR	=> l_status_id,
					P_OWNER_ID_PREV	 => l_owner_id,
					P_OWNER_ID_CURR	=> l_owner_id,
					P_OWNER_TYPE_PREV => l_owner_type,
					P_OWNER_TYPE_CURR => l_owner_type,
					P_ASSIGNEE_ID_PREV => null,
					P_ASSIGNEE_ID_CURR => l_assignee_id,
					P_ASSIGNEE_TYPE_PREV => null,
					P_ASSIGNEE_TYPE_CURR => l_assignee_type,
					P_SOURCE_OBJECT_ID_PREV => l_source_object_id,
					P_SOURCE_OBJECT_ID_CURR => l_source_object_id,
					P_SOURCE_OBJECT_TYPE_CODE_PREV => l_source_object_type_code,
					P_SOURCE_OBJECT_TYPE_CODE_CURR => l_source_object_type_code,
					P_PARENT_WORKITEM_STATUS_PREV => null,
					P_PARENT_WORKITEM_STATUS_CURR => null,
					P_PARENT_DIST_STATUS_PREV => null,
					P_PARENT_DIST_STATUS_CURR => null,
					P_WORKITEM_DIST_STATUS_PREV => 1,
					P_WORKITEM_DIST_STATUS_CURR => l_distribution_status_id,
					P_PRIORITY_PREV => l_priority_id,
					P_PRIORITY_CURR	=> l_priority_id,
					P_DUE_DATE_PREV	=> l_due_date,
					P_DUE_DATE_CURR	=> l_due_date,
					P_RESCHEDULE_TIME_PREV => l_reschedule_time,
					P_RESCHEDULE_TIME_CURR => l_reschedule_time,
					P_IEU_COMMENT_CODE1 => l_ieu_comment_code1,
					P_IEU_COMMENT_CODE2 => l_ieu_comment_code2,
					P_IEU_COMMENT_CODE3 => l_ieu_comment_code3,
					P_IEU_COMMENT_CODE4 => l_ieu_comment_code4,
					P_IEU_COMMENT_CODE5 => l_ieu_comment_code5,
					P_WORKITEM_COMMENT_CODE1 => l_workitem_comment_code1,
					P_WORKITEM_COMMENT_CODE2 => l_workitem_comment_code2,
					P_WORKITEM_COMMENT_CODE3 => l_workitem_comment_code3,
					P_WORKITEM_COMMENT_CODE4 => l_workitem_comment_code4,
					P_WORKITEM_COMMENT_CODE5 => l_workitem_comment_code5,
					P_STATUS => l_audit_log_sts,
					P_ERROR_CODE => l_msg_data
					);

		    end if;


                    if (l_dist_items(j).DISTRIBUTED = 'TRUE')
                    then
                          IF (l_dist_items(j).WORK_ITEM_STATUS is not null)
                          THEN
                            IF (l_dist_items(j).WORK_ITEM_STATUS = 'OPEN')
                            THEN
                              l_work_item_status_id := 0;
                            ELSIF (l_dist_items(j).WORK_ITEM_STATUS = 'CLOSE')
                            THEN
                              l_work_item_status_id := 3;
                            ELSIF (l_dist_items(j).WORK_ITEM_STATUS = 'DELETE')
                            THEN
                              l_work_item_status_id := 4;
                            ELSIF (l_dist_items(j).WORK_ITEM_STATUS = 'SLEEP')
                            THEN
                       	      l_work_item_status_id := 5;
                            END IF;
                           END IF;

                          --dbms_output.put_line('dist status set to TRUE work item pkid: '||l_dist_items(j).WORKITEM_PK_ID);

                           x_num_of_items_distributed := x_num_of_items_distributed + 1;
                           x_uwqm_workitem_data.extend;
                           x_uwqm_workitem_data(x_uwqm_workitem_data.last) := SYSTEM.WR_ITEM_DATA_OBJ(l_dist_items(j).WORK_ITEM_ID,
							 			         l_dist_items(j).WORKITEM_OBJ_CODE,
	    										   l_dist_items(j).WORKITEM_PK_ID,
	    										   l_work_item_status_id,
	    										   l_dist_items(j).PRIORITY_ID,
	    										   l_dist_items(j).PRIORITY_LEVEL,
	    										   l_dist_items(j).PRIORITY_CODE,
	    										   l_dist_items(j).DUE_DATE,
	    										   l_dist_items(j).TITLE,
	    										   l_dist_items(j).PARTY_ID,
	    										   l_dist_items(j).OWNER_ID,
	    										   l_dist_items(j).OWNER_TYPE,
    	    										   l_dist_items(j).ASSIGNEE_ID,
	    										   l_dist_items(j).ASSIGNEE_TYPE,
	    										   l_dist_items(j).SOURCE_OBJECT_ID,
	    										   l_dist_items(j).SOURCE_OBJECT_TYPE_CODE,
	    										   l_dist_items(j).APPLICATION_ID,
	    										   l_dist_items(j).IEU_ENUM_TYPE_UUID,
	    										   l_dist_items(j).WORK_ITEM_NUMBER,
	    										   l_dist_items(j).RESCHEDULE_TIME,
											   l_dist_items(j).WORK_SOURCE,
											   l_dist_items(j).DISTRIBUTED,
											   l_dist_items(j).ITEM_INCLUDED_BY_APP);
                     elsif (l_dist_items(j).DISTRIBUTED = 'FALSE')
                     then
                        -- set the distribution_status_id back to 'Distributable'
                          --dbms_output.put_line('dist status set to FALSE work item pkid: '||l_dist_items(j).WORKITEM_PK_ID);
                          update ieu_uwqm_items
                          set distribution_status_id = 1
                          where work_item_id = l_dist_items(j).work_item_id;
                          commit;

                     end if;
                   end loop;
                   --dbms_output.put_line('Num of Items Dist: '||x_num_of_items_distributed||' l_dist_item_obj cnt: '||x_uwqm_workitem_data.count);

             end if; /* l_dist_items.count > 1 */

      end loop; /* cur_res in c_ws */

    end loop; /* l_nw_items_list */

  end if; /* x_num_of_items_distributed <> -1 */
if l_nw_items_list.count > 0 then
    for y in l_nw_items_list.first..l_nw_items_list.last
    loop
               update ieu_uwqm_items
               set distribution_status_id = 1
               where work_item_id = l_nw_items_list(y).work_item_id
                and distribution_status_id = 2;
               commit;
    end loop;
end if;
 --  commit;
--  dbms_output.put_line('cnt: '||l_nw_item_list.count);
 EXCEPTION

   WHEN fnd_api.g_exc_error THEN

      x_return_status := fnd_api.g_ret_sts_error;

      fnd_msg_pub.Count_and_Get
      (
         p_count   =>   x_msg_count,
         p_data    =>   x_msg_data
      );

 WHEN fnd_api.g_exc_unexpected_error THEN

      x_return_status := fnd_api.g_ret_sts_unexp_error;

      fnd_msg_pub.Count_and_Get
      (
        p_count   =>   x_msg_count,
        p_data    =>   x_msg_data
      );

 WHEN OTHERS THEN

      x_return_status := fnd_api.g_ret_sts_unexp_error;

     IF FND_MSG_PUB.Check_msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN

        fnd_msg_pub.Count_and_Get
        (
          p_count   =>   x_msg_count,
          p_data    =>   x_msg_data
        );

     END IF;

END GET_DIST_WR_ITEMS;

/**
 **  Called by PROCEDURE - DISTRIBUTE_AND_DELIVER_WR_ITEM, DISTRIBUTE_WORK_ITEMS
 **  The in var can be either a rec of type IEU_UWQ_GET_NEXT_WORK_PVT.IEU_WR_ITEM_DATA_REC OR
 **  table of objects SYSTEM.WR_ITEM_DATA_NST
 **  The In var - p_var_in_type_code  indicates if its a record - 'REC' or an object - 'OBJ'
 **  Copies the Work Item data from table of objects - SYSTEM.WR_ITEM_DATA_NST or rec - IEU_UWQ_GET_NEXT_WORK_PVT.IEU_WR_ITEM_DATA_REC
 **  to table of records of type - IEU_UWQ_GET_NEXT_WORK_PVT.IEU_WR_ITEM_ACT_DATA_LIST
 **/

PROCEDURE SET_WR_ITEM_DATA_REC( p_var_in_type_code IN VARCHAR2,
                                p_dist_workitem_data IN SYSTEM.WR_ITEM_DATA_NST,
                                p_dist_del_workitem_data IN IEU_UWQ_GET_NEXT_WORK_PVT.IEU_WR_ITEM_DATA_REC,
                                x_ctr IN OUT NOCOPY NUMBER,
                                x_uwqm_workitem_data IN OUT NOCOPY IEU_UWQ_GET_NEXT_WORK_PVT.IEU_WR_ITEM_ACT_DATA_LIST) IS

  l_object_function            VARCHAR2(40);
  l_object_parameters          VARCHAR2(500);
  l_enter_from_task            VARCHAR2(10);
  l_ws_id                      NUMBER;
  l_not_valid_flag             VARCHAR2(1);
BEGIN

 if (p_var_in_type_code = 'OBJ')
 then

       -- If a work item was distributed, copy the Work Item data from table of obj - l_dist_workitem_data
       -- to table of Rec - x_uwqm_workitem_data

       for n in 1 .. p_dist_workitem_data .count
       loop

          -- Changes reqd for object function and params
          -- Get the Object func and params based from JTF_OBJECTS
          IF (p_dist_workitem_data(n).SOURCE_OBJECT_TYPE_CODE is not null)
          THEN


                 BEGIN
                    SELECT enter_from_task, object_function, object_parameters
                    INTO   l_enter_from_task, l_object_function, l_object_parameters
                    FROM   JTF_OBJECTS_B
                    WHERE  OBJECT_CODE = p_dist_workitem_data(n).SOURCE_OBJECT_TYPE_CODE;
                 EXCEPTION
                     when no_data_found then
                       null;
                 END;

                 x_uwqm_workitem_data(x_ctr).IEU_OBJECT_FUNCTION := l_object_function;
                 x_uwqm_workitem_data(x_ctr).IEU_OBJECT_PARAMETERS := l_object_parameters;
         	     x_uwqm_workitem_data(x_ctr).IEU_PARAM_PK_VALUE      := p_dist_workitem_data(n).SOURCE_OBJECT_ID;
                 x_uwqm_workitem_data(x_ctr).IEU_PARAM_PK_COL        := 'SOURCE_OBJECT_ID';

          ELSIF (p_dist_workitem_data(n).SOURCE_OBJECT_TYPE_CODE is null)
          THEN

                 BEGIN
                    SELECT enter_from_task, object_function, object_parameters
                    INTO   l_enter_from_task, l_object_function, l_object_parameters
                    FROM   JTF_OBJECTS_B
                    WHERE  OBJECT_CODE = p_dist_workitem_data(n).WORKITEM_OBJ_CODE;
                 EXCEPTION
                     when no_data_found then
                       null;
                 END;

                 x_uwqm_workitem_data(x_ctr).IEU_OBJECT_FUNCTION := l_object_function;
                 x_uwqm_workitem_data(x_ctr).IEU_OBJECT_PARAMETERS := l_object_parameters;
         	     x_uwqm_workitem_data(x_ctr).IEU_PARAM_PK_VALUE      := p_dist_workitem_data(n).WORKITEM_PK_ID;
                 x_uwqm_workitem_data(x_ctr).IEU_PARAM_PK_COL        := 'WORKITEM_PK_ID';


          END IF; /* SOURCE_OBJECT_TYPE_CODE is not null */

          BEGIN
            l_not_valid_flag := 'N';
            SELECT ws_id
            INTO   l_ws_id
            FROM   ieu_uwqm_work_sources_b
            WHERE  ws_code = p_dist_workitem_data(n).WORK_SOURCE
--	    AND    nvl(not_valid_flag,'N') = 'N';
	    AND    nvl(not_valid_flag,'N') = l_not_valid_flag;

          EXCEPTION
           WHEN OTHERS THEN
               l_ws_id := null;
          END;

          x_uwqm_workitem_data(x_ctr).IEU_MEDIA_TYPE_UUID     := '';
	    x_uwqm_workitem_data(x_ctr).WORK_ITEM_ID            := p_dist_workitem_data(n).WORK_ITEM_ID;
	    x_uwqm_workitem_data(x_ctr).WORKITEM_OBJ_CODE       := p_dist_workitem_data(n).WORKITEM_OBJ_CODE;
	    x_uwqm_workitem_data(x_ctr).WORKITEM_PK_ID          := p_dist_workitem_data(n).WORKITEM_PK_ID;
	    x_uwqm_workitem_data(x_ctr).STATUS_ID               := p_dist_workitem_data(n).WORK_ITEM_STATUS;
	    x_uwqm_workitem_data(x_ctr).PRIORITY_ID             := p_dist_workitem_data(n).PRIORITY_ID;
	    x_uwqm_workitem_data(x_ctr).PRIORITY_LEVEL          := p_dist_workitem_data(n).PRIORITY_LEVEL;
	    x_uwqm_workitem_data(x_ctr).DUE_DATE                := p_dist_workitem_data(n).DUE_DATE;
	    x_uwqm_workitem_data(x_ctr).TITLE                   := p_dist_workitem_data(n).TITLE;
	    x_uwqm_workitem_data(x_ctr).PARTY_ID                := p_dist_workitem_data(n).PARTY_ID;
	    x_uwqm_workitem_data(x_ctr).OWNER_ID                := p_dist_workitem_data(n).OWNER_ID;
	    x_uwqm_workitem_data(x_ctr).OWNER_TYPE              := p_dist_workitem_data(n).OWNER_TYPE;
    	    x_uwqm_workitem_data(x_ctr).ASSIGNEE_ID             := p_dist_workitem_data(n).ASSIGNEE_ID;
	    x_uwqm_workitem_data(x_ctr).ASSIGNEE_TYPE           := p_dist_workitem_data(n).ASSIGNEE_TYPE;
	    x_uwqm_workitem_data(x_ctr).SOURCE_OBJECT_ID        := p_dist_workitem_data(n).SOURCE_OBJECT_ID;
	    x_uwqm_workitem_data(x_ctr).SOURCE_OBJECT_TYPE_CODE := p_dist_workitem_data(n).SOURCE_OBJECT_TYPE_CODE;
	    x_uwqm_workitem_data(x_ctr).APPLICATION_ID          := p_dist_workitem_data(n).APPLICATION_ID;
	    x_uwqm_workitem_data(x_ctr).IEU_ENUM_TYPE_UUID      := p_dist_workitem_data(n).IEU_ENUM_TYPE_UUID;
	    x_uwqm_workitem_data(x_ctr).WORK_ITEM_NUMBER        := p_dist_workitem_data(n).WORK_ITEM_NUMBER;
	    x_uwqm_workitem_data(x_ctr).RESCHEDULE_TIME         := p_dist_workitem_data(n).RESCHEDULE_TIME;
	    x_uwqm_workitem_data(x_ctr).IEU_GET_NEXTWORK_FLAG   := 'Y';
	    x_uwqm_workitem_data(x_ctr).IEU_ACTION_OBJECT_CODE  := p_dist_workitem_data(n).SOURCE_OBJECT_TYPE_CODE;
	    x_uwqm_workitem_data(x_ctr).WS_ID                   := l_ws_id;
          x_ctr := x_ctr + 1;

       end loop;/* p_dist_workitem_data  */

 elsif (p_var_in_type_code = 'REC')
 then

       -- If a work item was distributed, copy the Work Item data from table of obj - l_dist_workitem_data
       -- to table of Rec - x_uwqm_workitem_data

          -- Changes reqd for object function and params
          -- Get the Object func and params based from JTF_OBJECTS

          IF (p_dist_del_workitem_data.SOURCE_OBJECT_TYPE_CODE is not null)
          THEN

                 BEGIN
                    SELECT enter_from_task, object_function, object_parameters
                    INTO   l_enter_from_task, l_object_function, l_object_parameters
                    FROM   JTF_OBJECTS_B
                    WHERE  OBJECT_CODE = p_dist_del_workitem_data.SOURCE_OBJECT_TYPE_CODE;
                 EXCEPTION
                     when no_data_found then
                       null;
                 END;

                 x_uwqm_workitem_data(x_ctr).IEU_OBJECT_FUNCTION := l_object_function;
                 x_uwqm_workitem_data(x_ctr).IEU_OBJECT_PARAMETERS := l_object_parameters;
         	     x_uwqm_workitem_data(x_ctr).IEU_PARAM_PK_VALUE    := p_dist_del_workitem_data.SOURCE_OBJECT_ID;
                 x_uwqm_workitem_data(x_ctr).IEU_PARAM_PK_COL      := 'SOURCE_OBJECT_ID';


          ELSIF (p_dist_del_workitem_data.SOURCE_OBJECT_TYPE_CODE is null)
          THEN

                 BEGIN
                    SELECT enter_from_task, object_function, object_parameters
                    INTO   l_enter_from_task, l_object_function, l_object_parameters
                    FROM   JTF_OBJECTS_B
                    WHERE  OBJECT_CODE = p_dist_del_workitem_data.WORKITEM_OBJ_CODE;
                 EXCEPTION
                     when no_data_found then
                       null;
                 END;

                 x_uwqm_workitem_data(x_ctr).IEU_OBJECT_FUNCTION := l_object_function;
                 x_uwqm_workitem_data(x_ctr).IEU_OBJECT_PARAMETERS := l_object_parameters;
         	     x_uwqm_workitem_data(x_ctr).IEU_PARAM_PK_VALUE    := p_dist_del_workitem_data.WORKITEM_PK_ID;
                 x_uwqm_workitem_data(x_ctr).IEU_PARAM_PK_COL      := 'WORKITEM_PK_ID';


          END IF; /* SOURCE_OBJECT_TYPE_CODE is not null */

          x_uwqm_workitem_data(x_ctr).IEU_MEDIA_TYPE_UUID     := '';
	    x_uwqm_workitem_data(x_ctr).WORK_ITEM_ID            := p_dist_del_workitem_data.WORK_ITEM_ID;
	    x_uwqm_workitem_data(x_ctr).WORKITEM_OBJ_CODE       := p_dist_del_workitem_data.WORKITEM_OBJ_CODE;
	    x_uwqm_workitem_data(x_ctr).WORKITEM_PK_ID          := p_dist_del_workitem_data.WORKITEM_PK_ID;
	    x_uwqm_workitem_data(x_ctr).STATUS_ID               := p_dist_del_workitem_data.STATUS_ID;
	    x_uwqm_workitem_data(x_ctr).PRIORITY_ID             := p_dist_del_workitem_data.PRIORITY_ID;
	    x_uwqm_workitem_data(x_ctr).PRIORITY_LEVEL          := p_dist_del_workitem_data.PRIORITY_LEVEL;
	    x_uwqm_workitem_data(x_ctr).DUE_DATE                := p_dist_del_workitem_data.DUE_DATE;
	    x_uwqm_workitem_data(x_ctr).TITLE                   := p_dist_del_workitem_data.TITLE;
	    x_uwqm_workitem_data(x_ctr).PARTY_ID                := p_dist_del_workitem_data.PARTY_ID;
	    x_uwqm_workitem_data(x_ctr).OWNER_ID                := p_dist_del_workitem_data.OWNER_ID;
	    x_uwqm_workitem_data(x_ctr).OWNER_TYPE              := p_dist_del_workitem_data.OWNER_TYPE;
    	    x_uwqm_workitem_data(x_ctr).ASSIGNEE_ID             := p_dist_del_workitem_data.ASSIGNEE_ID;
	    x_uwqm_workitem_data(x_ctr).ASSIGNEE_TYPE           := p_dist_del_workitem_data.ASSIGNEE_TYPE;
	    x_uwqm_workitem_data(x_ctr).SOURCE_OBJECT_ID        := p_dist_del_workitem_data.SOURCE_OBJECT_ID;
	    x_uwqm_workitem_data(x_ctr).SOURCE_OBJECT_TYPE_CODE := p_dist_del_workitem_data.SOURCE_OBJECT_TYPE_CODE;
	    x_uwqm_workitem_data(x_ctr).APPLICATION_ID          := p_dist_del_workitem_data.APPLICATION_ID;
	    x_uwqm_workitem_data(x_ctr).IEU_ENUM_TYPE_UUID      := p_dist_del_workitem_data.IEU_ENUM_TYPE_UUID;
	    x_uwqm_workitem_data(x_ctr).WORK_ITEM_NUMBER        := p_dist_del_workitem_data.WORK_ITEM_NUMBER;
	    x_uwqm_workitem_data(x_ctr).RESCHEDULE_TIME         := p_dist_del_workitem_data.RESCHEDULE_TIME;
	    x_uwqm_workitem_data(x_ctr).IEU_GET_NEXTWORK_FLAG   := 'Y';
	    x_uwqm_workitem_data(x_ctr).IEU_ACTION_OBJECT_CODE  := p_dist_del_workitem_data.SOURCE_OBJECT_TYPE_CODE;
	    x_uwqm_workitem_data(x_ctr).WS_ID                   := p_dist_del_workitem_data.WS_ID;
          x_ctr := x_ctr + 1;

 end if; /* p_var_in_type_code */

END SET_WR_ITEM_DATA_REC;


/**
 **  Distribute Only returns the table of Records in a different format compared to Distribute and Deliver.
 **  This was required as Distribute Only can return multiple records. Distribute and Deliver requires the Return Record
 **  to be of type IEU_FRM_PVT.T_IEU_MEDIA_DATA for processing on the FORM.
 **  Called by PROCEDURE - DISTRIBUTE_AND_DELIVER_WR_ITEM
 **  The in var can be either a rec of type IEU_UWQ_GET_NEXT_WORK_PVT.IEU_WR_ITEM_DATA_REC OR
 **  table of objects SYSTEM.WR_ITEM_DATA_NST
 **  The In var - p_var_in_type_code  indicates if its a record - 'REC' or an object - 'OBJ'
 **  Copies the Work Item data from table of objects - SYSTEM.WR_ITEM_DATA_NST or rec - IEU_UWQ_GET_NEXT_WORK_PVT.IEU_WR_ITEM_DATA_REC
 **  to table of records of type - IEU_FRM_PVT.T_IEU_MEDIA_DATA
 **/

PROCEDURE SET_DIST_AND_DEL_ITEM_DATA_REC( p_var_in_type_code IN VARCHAR2,
                                p_dist_workitem_data IN SYSTEM.WR_ITEM_DATA_NST,
                                p_dist_del_workitem_data IN IEU_UWQ_GET_NEXT_WORK_PVT.IEU_WR_ITEM_DATA_REC,
                                x_ctr IN OUT NOCOPY NUMBER,
                                x_workitem_action_data IN OUT NOCOPY IEU_FRM_PVT.T_IEU_MEDIA_DATA) IS


--l_ctr NUMBER := 0;
l_enter_from_task   VARCHAR2(1);
l_object_function   VARCHAR2(30);
l_object_parameters VARCHAR2(2000);
l_work_type         VARCHAR2(80);

BEGIN

 if (p_var_in_type_code = 'OBJ')
 then

       -- If a work item was distributed, copy the Work Item data from table of obj - l_dist_workitem_data
       -- to table of Rec - x_uwqm_workitem_data

          -- Changes reqd for object function and params
          -- Get the Object func and params based from JTF_OBJECTS

    for n in 1 .. p_dist_workitem_data.count
    loop

          IF ( p_dist_workitem_data(n).SOURCE_OBJECT_TYPE_CODE is not null)
          THEN

                   BEGIN
                      SELECT enter_from_task, object_function, object_parameters
                      INTO   l_enter_from_task, l_object_function, l_object_parameters
                      FROM   JTF_OBJECTS_B
                      WHERE  OBJECT_CODE = p_dist_workitem_data(n).SOURCE_OBJECT_TYPE_CODE;
                    EXCEPTION
                     when no_data_found then
                       null;
                    END;

		        x_workitem_action_data(x_ctr).param_name  := 'IEU_OBJECT_FUNCTION';
		        x_workitem_action_data(x_ctr).param_value := l_object_function;
		        x_workitem_action_data(x_ctr).param_type  := 'CHAR';
		        x_ctr := x_ctr + 1;

		        x_workitem_action_data(x_ctr).param_name  := 'IEU_OBJECT_PARAMETERS';
		        x_workitem_action_data(x_ctr).param_value := l_object_parameters;
		        x_workitem_action_data(x_ctr).param_type  := 'CHAR';
		        x_ctr := x_ctr + 1;

		        x_workitem_action_data(x_ctr).param_name  := 'IEU_PARAM_PK_VALUE';
		        x_workitem_action_data(x_ctr).param_value := p_dist_workitem_data(n).source_object_id;
		        x_workitem_action_data(x_ctr).param_type  := 'NUMBER';
		        x_ctr := x_ctr + 1;

		        x_workitem_action_data(x_ctr).param_name  := 'IEU_PARAM_PK_COL';
		        x_workitem_action_data(x_ctr).param_value := 'SOURCE_OBJECT_ID';
		        x_workitem_action_data(x_ctr).param_type  := '';
		        x_ctr := x_ctr + 1;


          ELSIF (p_dist_workitem_data(n).SOURCE_OBJECT_TYPE_CODE is null)
          THEN

                 BEGIN
                    SELECT enter_from_task, object_function, object_parameters
                    INTO   l_enter_from_task, l_object_function, l_object_parameters
                    FROM   JTF_OBJECTS_B
                    WHERE  OBJECT_CODE = p_dist_workitem_data(n).WORKITEM_OBJ_CODE;
                 EXCEPTION
                     when no_data_found then
                       null;
                 END;

		     x_workitem_action_data(x_ctr).param_name  := 'IEU_OBJECT_FUNCTION';
		     x_workitem_action_data(x_ctr).param_value := l_object_function;
		     x_workitem_action_data(x_ctr).param_type  := 'CHAR';
		     x_ctr := x_ctr + 1;

		     x_workitem_action_data(x_ctr).param_name  := 'IEU_OBJECT_PARAMETERS';
		     x_workitem_action_data(x_ctr).param_value := l_object_parameters;
		     x_workitem_action_data(x_ctr).param_type  := 'CHAR';
		     x_ctr := x_ctr + 1;

  	           x_workitem_action_data(x_ctr).param_name  := 'IEU_PARAM_PK_VALUE';
		     x_workitem_action_data(x_ctr).param_value := p_dist_workitem_data(n).workitem_pk_id;
		     x_workitem_action_data(x_ctr).param_type  := 'NUMBER';
		     x_ctr := x_ctr + 1;

  	           x_workitem_action_data(x_ctr).param_name  := 'IEU_PARAM_PK_COL';
		     x_workitem_action_data(x_ctr).param_value := 'WORKITEM_PK_ID';
		     x_workitem_action_data(x_ctr).param_type  := '';
		     x_ctr := x_ctr + 1;


          END IF; /* SOURCE_OBJECT_TYPE_CODE is not null */


      x_workitem_action_data(x_ctr).param_name  := 'IEU_MEDIA_TYPE_UUID';
      x_workitem_action_data(x_ctr).param_value := '';
      x_workitem_action_data(x_ctr).param_type  := '';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'WORK_ITEM_ID';
      x_workitem_action_data(x_ctr).param_value := p_dist_workitem_data(n).WORK_ITEM_ID;
      x_workitem_action_data(x_ctr).param_type  := 'NUMBER';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'WORKITEM_OBJ_CODE';
      x_workitem_action_data(x_ctr).param_value := p_dist_workitem_data(n).WORKITEM_OBJ_CODE;
      x_workitem_action_data(x_ctr).param_type  := 'CHAR';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'WORKITEM_PK_ID';
      x_workitem_action_data(x_ctr).param_value := p_dist_workitem_data(n).WORKITEM_PK_ID;
      x_workitem_action_data(x_ctr).param_type  := 'NUMBER';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'STATUS_ID';
      x_workitem_action_data(x_ctr).param_value := p_dist_workitem_data(n).WORK_ITEM_STATUS;
      x_workitem_action_data(x_ctr).param_type  := 'NUMBER';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'PRIORITY_ID';
      x_workitem_action_data(x_ctr).param_value := p_dist_workitem_data(n).PRIORITY_ID;
      x_workitem_action_data(x_ctr).param_type  := 'NUMBER';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'PRIORITY_LEVEL';
      x_workitem_action_data(x_ctr).param_value := p_dist_workitem_data(n).PRIORITY_LEVEL;
      x_workitem_action_data(x_ctr).param_type  := 'NUMBER';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'DUE_DATE';
      x_workitem_action_data(x_ctr).param_value := p_dist_workitem_data(n).DUE_DATE;
      x_workitem_action_data(x_ctr).param_type  := 'DATE';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'TITLE';
      x_workitem_action_data(x_ctr).param_value := p_dist_workitem_data(n).TITLE;
      x_workitem_action_data(x_ctr).param_type  := 'CHAR';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'PARTY_ID';
      x_workitem_action_data(x_ctr).param_value := p_dist_workitem_data(n).PARTY_ID;
      x_workitem_action_data(x_ctr).param_type  := 'NUMBER';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'OWNER_TYPE';
      x_workitem_action_data(x_ctr).param_value := p_dist_workitem_data(n).OWNER_TYPE;
      x_workitem_action_data(x_ctr).param_type  := 'CHAR';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'OWNER_ID';
      x_workitem_action_data(x_ctr).param_value := p_dist_workitem_data(n).OWNER_ID;
      x_workitem_action_data(x_ctr).param_type  := 'NUMBER';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'ASSIGNEE_TYPE';
      x_workitem_action_data(x_ctr).param_value := p_dist_workitem_data(n).ASSIGNEE_TYPE;
      x_workitem_action_data(x_ctr).param_type  := 'CHAR';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'ASSIGNEE_ID';
      x_workitem_action_data(x_ctr).param_value := p_dist_workitem_data(n).ASSIGNEE_ID;
      x_workitem_action_data(x_ctr).param_type  := 'NUMBER';
      x_ctr := x_ctr + 1;
/*
      x_workitem_action_data(x_ctr).param_name  := 'OWNER_TYPE_ACTUAL';
      x_workitem_action_data(x_ctr).param_value := p_dist_workitem_data(n).OWNER_TYPE_ACTUAL;
      x_workitem_action_data(x_ctr).param_type  := 'CHAR';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'ASSIGNEE_TYPE_ACTUAL';
      x_workitem_action_data(x_ctr).param_value := p_dist_workitem_data(n).ASSIGNEE_TYPE_ACTUAL;
      x_workitem_action_data(x_ctr).param_type  := 'CHAR';
      x_ctr := x_ctr + 1;
*/
      x_workitem_action_data(x_ctr).param_name  := 'SOURCE_OBJECT_ID';
      x_workitem_action_data(x_ctr).param_value := p_dist_workitem_data(n).SOURCE_OBJECT_ID;
      x_workitem_action_data(x_ctr).param_type  := 'NUMBER';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'SOURCE_OBJECT_TYPE_CODE';
      x_workitem_action_data(x_ctr).param_value := p_dist_workitem_data(n).SOURCE_OBJECT_TYPE_CODE;
      x_workitem_action_data(x_ctr).param_type  := 'CHAR';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'APPLICATION_ID';
      x_workitem_action_data(x_ctr).param_value := p_dist_workitem_data(n).APPLICATION_ID;
      x_workitem_action_data(x_ctr).param_type  := 'NUMBER';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'IEU_ACTION_OBJECT_CODE';
      x_workitem_action_data(x_ctr).param_value := p_dist_workitem_data(n).SOURCE_OBJECT_TYPE_CODE;
      x_workitem_action_data(x_ctr).param_type  := 'CHAR';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'IEU_GET_NEXTWORK_FLAG';
      x_workitem_action_data(x_ctr).param_value := 'Y';
      x_workitem_action_data(x_ctr).param_type  := 'CHAR';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'RESCHEDULE_TIME';
      x_workitem_action_data(x_ctr).param_value := p_dist_workitem_data(n).RESCHEDULE_TIME;
      x_workitem_action_data(x_ctr).param_type  := 'DATE';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'IEU_ENUM_TYPE_UUID';
      x_workitem_action_data(x_ctr).param_value := p_dist_workitem_data(n).IEU_ENUM_TYPE_UUID;
      x_workitem_action_data(x_ctr).param_type  := 'NUMBER';
      x_ctr := x_ctr + 1;

      BEGIN

      SELECT LKUPS.MEANING
      INTO   L_WORK_TYPE
      FROM   FND_LOOKUP_VALUES_VL LKUPS,  IEU_UWQ_SEL_ENUMERATORS ENUM
      WHERE  ENUM.ENUM_TYPE_UUID = p_dist_workitem_data(n).IEU_ENUM_TYPE_UUID
      AND    LKUPS.LOOKUP_TYPE(+) = ENUM.WORK_Q_LABEL_LU_TYPE
      AND    LKUPS.VIEW_APPLICATION_ID(+) = ENUM.APPLICATION_ID
      AND    LKUPS.LOOKUP_CODE(+) = WORK_Q_LABEL_LU_CODE;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      END;

      x_workitem_action_data(x_ctr).param_name  := 'WORK_TYPE';
      x_workitem_action_data(x_ctr).param_value := L_WORK_TYPE;
      x_workitem_action_data(x_ctr).param_type  := 'VARCHAR2';
      x_ctr := x_ctr + 1;

   end loop;/* p_dist_workitem_data */

 elsif (p_var_in_type_code = 'REC')
 then

       -- If a work item was distributed, copy the Work Item data from table of obj - l_dist_workitem_data
       -- to table of Rec - x_uwqm_workitem_data

          -- Changes reqd for object function and params
          -- Get the Object func and params based from JTF_OBJECTS

          IF (p_dist_del_workitem_data.SOURCE_OBJECT_TYPE_CODE is not null)
          THEN


                   BEGIN
                      SELECT enter_from_task, object_function, object_parameters
                      INTO   l_enter_from_task, l_object_function, l_object_parameters
                      FROM   JTF_OBJECTS_B
                      WHERE  OBJECT_CODE = p_dist_del_workitem_data.SOURCE_OBJECT_TYPE_CODE;
                    EXCEPTION
                     when no_data_found then
                       null;
                    END;

		        x_workitem_action_data(x_ctr).param_name  := 'IEU_OBJECT_FUNCTION';
		        x_workitem_action_data(x_ctr).param_value := l_object_function;
		        x_workitem_action_data(x_ctr).param_type  := 'CHAR';
		        x_ctr := x_ctr + 1;

		        x_workitem_action_data(x_ctr).param_name  := 'IEU_OBJECT_PARAMETERS';
		        x_workitem_action_data(x_ctr).param_value := l_object_parameters;
		        x_workitem_action_data(x_ctr).param_type  := 'CHAR';
		        x_ctr := x_ctr + 1;

		        x_workitem_action_data(x_ctr).param_name  := 'IEU_PARAM_PK_VALUE';
		        x_workitem_action_data(x_ctr).param_value := p_dist_del_workitem_data.source_object_id;
		        x_workitem_action_data(x_ctr).param_type  := 'NUMBER';
		        x_ctr := x_ctr + 1;

		        x_workitem_action_data(x_ctr).param_name  := 'IEU_PARAM_PK_COL';
		        x_workitem_action_data(x_ctr).param_value := 'SOURCE_OBJECT_ID';
		        x_workitem_action_data(x_ctr).param_type  := '';
		        x_ctr := x_ctr + 1;


          ELSIF (p_dist_del_workitem_data.SOURCE_OBJECT_TYPE_CODE is null)
          THEN

                 BEGIN
                    SELECT enter_from_task, object_function, object_parameters
                    INTO   l_enter_from_task, l_object_function, l_object_parameters
                    FROM   JTF_OBJECTS_B
                    WHERE  OBJECT_CODE = p_dist_del_workitem_data.WORKITEM_OBJ_CODE;
                 EXCEPTION
                     when no_data_found then
                       null;
                 END;

		     x_workitem_action_data(x_ctr).param_name  := 'IEU_OBJECT_FUNCTION';
		     x_workitem_action_data(x_ctr).param_value := l_object_function;
		     x_workitem_action_data(x_ctr).param_type  := 'CHAR';
		     x_ctr := x_ctr + 1;

		     x_workitem_action_data(x_ctr).param_name  := 'IEU_OBJECT_PARAMETERS';
		     x_workitem_action_data(x_ctr).param_value := l_object_parameters;
		     x_workitem_action_data(x_ctr).param_type  := 'CHAR';
		     x_ctr := x_ctr + 1;

  	           x_workitem_action_data(x_ctr).param_name  := 'IEU_PARAM_PK_VALUE';
		     x_workitem_action_data(x_ctr).param_value := p_dist_del_workitem_data.workitem_pk_id;
		     x_workitem_action_data(x_ctr).param_type  := 'NUMBER';
		     x_ctr := x_ctr + 1;

  	           x_workitem_action_data(x_ctr).param_name  := 'IEU_PARAM_PK_COL';
		     x_workitem_action_data(x_ctr).param_value := 'WORKITEM_PK_ID';
		     x_workitem_action_data(x_ctr).param_type  := '';
		     x_ctr := x_ctr + 1;


          END IF; /* SOURCE_OBJECT_TYPE_CODE is not null */


      x_workitem_action_data(x_ctr).param_name  := 'IEU_MEDIA_TYPE_UUID';
      x_workitem_action_data(x_ctr).param_value := '';
      x_workitem_action_data(x_ctr).param_type  := '';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'WORK_ITEM_ID';
      x_workitem_action_data(x_ctr).param_value := p_dist_del_workitem_data.WORK_ITEM_ID;
      x_workitem_action_data(x_ctr).param_type  := 'NUMBER';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'WORKITEM_OBJ_CODE';
      x_workitem_action_data(x_ctr).param_value := p_dist_del_workitem_data.WORKITEM_OBJ_CODE;
      x_workitem_action_data(x_ctr).param_type  := 'CHAR';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'WORKITEM_PK_ID';
      x_workitem_action_data(x_ctr).param_value := p_dist_del_workitem_data.WORKITEM_PK_ID;
      x_workitem_action_data(x_ctr).param_type  := 'NUMBER';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'STATUS_ID';
      x_workitem_action_data(x_ctr).param_value := p_dist_del_workitem_data.STATUS_ID;
      x_workitem_action_data(x_ctr).param_type  := 'NUMBER';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'PRIORITY_ID';
      x_workitem_action_data(x_ctr).param_value := p_dist_del_workitem_data.PRIORITY_ID;
      x_workitem_action_data(x_ctr).param_type  := 'NUMBER';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'PRIORITY_LEVEL';
      x_workitem_action_data(x_ctr).param_value := p_dist_del_workitem_data.PRIORITY_LEVEL;
      x_workitem_action_data(x_ctr).param_type  := 'NUMBER';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'DUE_DATE';
      x_workitem_action_data(x_ctr).param_value := p_dist_del_workitem_data.DUE_DATE;
      x_workitem_action_data(x_ctr).param_type  := 'DATE';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'TITLE';
      x_workitem_action_data(x_ctr).param_value := p_dist_del_workitem_data.TITLE;
      x_workitem_action_data(x_ctr).param_type  := 'CHAR';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'PARTY_ID';
      x_workitem_action_data(x_ctr).param_value := p_dist_del_workitem_data.PARTY_ID;
      x_workitem_action_data(x_ctr).param_type  := 'NUMBER';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'OWNER_TYPE';
      x_workitem_action_data(x_ctr).param_value := p_dist_del_workitem_data.OWNER_TYPE;
      x_workitem_action_data(x_ctr).param_type  := 'CHAR';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'OWNER_ID';
      x_workitem_action_data(x_ctr).param_value := p_dist_del_workitem_data.OWNER_ID;
      x_workitem_action_data(x_ctr).param_type  := 'NUMBER';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'ASSIGNEE_TYPE';
      x_workitem_action_data(x_ctr).param_value := p_dist_del_workitem_data.ASSIGNEE_TYPE;
      x_workitem_action_data(x_ctr).param_type  := 'CHAR';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'ASSIGNEE_ID';
      x_workitem_action_data(x_ctr).param_value := p_dist_del_workitem_data.ASSIGNEE_ID;
      x_workitem_action_data(x_ctr).param_type  := 'NUMBER';
      x_ctr := x_ctr + 1;
/*
      x_workitem_action_data(x_ctr).param_name  := 'OWNER_TYPE_ACTUAL';
      x_workitem_action_data(x_ctr).param_value := p_dist_del_workitem_data.OWNER_TYPE_ACTUAL;
      x_workitem_action_data(x_ctr).param_type  := 'CHAR';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'ASSIGNEE_TYPE_ACTUAL';
      x_workitem_action_data(x_ctr).param_value := p_dist_del_workitem_data.ASSIGNEE_TYPE_ACTUAL;
      x_workitem_action_data(x_ctr).param_type  := 'CHAR';
      x_ctr := x_ctr + 1;
*/
      x_workitem_action_data(x_ctr).param_name  := 'SOURCE_OBJECT_ID';
      x_workitem_action_data(x_ctr).param_value := p_dist_del_workitem_data.SOURCE_OBJECT_ID;
      x_workitem_action_data(x_ctr).param_type  := 'NUMBER';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'SOURCE_OBJECT_TYPE_CODE';
      x_workitem_action_data(x_ctr).param_value := p_dist_del_workitem_data.SOURCE_OBJECT_TYPE_CODE;
      x_workitem_action_data(x_ctr).param_type  := 'CHAR';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'APPLICATION_ID';
      x_workitem_action_data(x_ctr).param_value := p_dist_del_workitem_data.APPLICATION_ID;
      x_workitem_action_data(x_ctr).param_type  := 'NUMBER';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'IEU_ACTION_OBJECT_CODE';
      x_workitem_action_data(x_ctr).param_value := p_dist_del_workitem_data.SOURCE_OBJECT_TYPE_CODE;
      x_workitem_action_data(x_ctr).param_type  := 'CHAR';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'IEU_GET_NEXTWORK_FLAG';
      x_workitem_action_data(x_ctr).param_value := 'Y';
      x_workitem_action_data(x_ctr).param_type  := 'CHAR';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'RESCHEDULE_TIME';
      x_workitem_action_data(x_ctr).param_value := p_dist_del_workitem_data.RESCHEDULE_TIME;
      x_workitem_action_data(x_ctr).param_type  := 'DATE';
      x_ctr := x_ctr + 1;

      x_workitem_action_data(x_ctr).param_name  := 'IEU_ENUM_TYPE_UUID';
      x_workitem_action_data(x_ctr).param_value := p_dist_del_workitem_data.IEU_ENUM_TYPE_UUID;
      x_workitem_action_data(x_ctr).param_type  := 'NUMBER';
      x_ctr := x_ctr + 1;

      BEGIN

      SELECT LKUPS.MEANING
      INTO   L_WORK_TYPE
      FROM   FND_LOOKUP_VALUES_VL LKUPS,  IEU_UWQ_SEL_ENUMERATORS ENUM
      WHERE  ENUM.ENUM_TYPE_UUID = p_dist_del_workitem_data.IEU_ENUM_TYPE_UUID
      AND    LKUPS.LOOKUP_TYPE(+) = ENUM.WORK_Q_LABEL_LU_TYPE
      AND    LKUPS.VIEW_APPLICATION_ID(+) = ENUM.APPLICATION_ID
      AND    LKUPS.LOOKUP_CODE(+) = WORK_Q_LABEL_LU_CODE;

      EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      END;

      x_workitem_action_data(x_ctr).param_name  := 'WORK_TYPE';
      x_workitem_action_data(x_ctr).param_value := L_WORK_TYPE;
      x_workitem_action_data(x_ctr).param_type  := 'VARCHAR2';
      x_ctr := x_ctr + 1;

  end if; /* p_var_in_type_code */

END SET_DIST_AND_DEL_ITEM_DATA_REC;

/**
 **  Called by PROCEDURE - GET_NEXT_WORK_FOR_APPS
 **  Sets the where clause based on business rules like ws_id, distribute_to and distribute_from
 **  This extra where clause will be appened to actual where clause to fetch the set of distributable items
 **/
PROCEDURE GET_WS_WHERE_CLAUSE
    (p_type             IN VARCHAR2,
     p_ws_det_list      IN IEU_UWQ_GET_NEXT_WORK_PVT.IEU_WS_DETAILS_LIST,
     p_resource_id      IN NUMBER,
     x_dist_from_where OUT NOCOPY VARCHAR2,
     x_dist_to_where   OUT NOCOPY VARCHAR2,
     x_bindvar_from_list  OUT NOCOPY IEU_UWQ_BINDVAR_LIST,
     x_bindvar_to_list    OUT NOCOPY IEU_UWQ_BINDVAR_LIST) IS

/*
  cursor C1 is
  select WS_B.WS_ID, WS_B.DISTRIBUTE_TO, WS_B.DISTRIBUTE_FROM , WS_B.DISTRIBUTION_FUNCTION
  from IEU_UWQM_WORK_SOURCES_B WS_B
  where ws_b.not_valid_flag = 'N';
*/

  l_dist_from     IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_FROM%TYPE;
  l_dist_to       IEU_UWQM_WORK_SOURCES_B.DISTRIBUTE_TO%TYPE;
  l_ws_id         IEU_UWQM_WORK_SOURCES_B.WS_ID%TYPE;

  -- Variables for Distribute_from

  l_df_own_where_clause varchar2(4000);
  l_df_asg_where_clause varchar2(4000);

  l_df_own_ws_clause varchar2(4000);
  l_df_own_ws_clause1 varchar2(4000);
  l_df_asg_ws_clause varchar2(4000);
  l_df_asg_ws_clause1 varchar2(4000);

  l_df_final_where varchar2(4000);

  l_df_grp_own_ctr number := 0;
  l_df_grp_asg_ctr number := 0;

  -- Variables for Distribute_to

  l_dt_own_where_clause varchar2(4000);
  l_dt_asg_where_clause varchar2(4000);

  l_dt_own_ws_clause varchar2(4000);
  l_dt_own_ws_clause1 varchar2(4000);
  l_dt_asg_ws_clause varchar2(4000);
  l_dt_asg_ws_clause1 varchar2(4000);

  l_dt_final_where varchar2(4000);

  l_dt_grp_own_ctr number := 0;
  l_dt_grp_asg_ctr number := 0;

  z  number := 1;
  p_grp_id_list     IEU_UWQ_GET_NEXT_WORK_PVT.IEU_GRP_ID_LIST;
  l_df_grp_id_clause varchar2(4000);
  l_df_grp_id_ctr number := 0;

  l_delete_flag_yes	varchar2(1);

  cursor c_grp_id(p_resource_id in number) is
    select group_id from jtf_rs_group_members
    where resource_id = p_resource_id
    and nvl(delete_flag, 'N') <> l_delete_flag_yes;

  l_not_valid_flag VARCHAR2(1);

  l_bindvar_fm_ctr number;
  l_bindvar_to_ctr number;
  t number;

  l_fm_group_owned_flag varchar2(1) := 'F';
  l_fm_group_assigned_flag varchar2(1) := 'F';
  l_to_ind_owned_flag varchar2(1) := 'F';
  l_to_ind_assigned_flag varchar2(1) := 'F';


BEGIN


  l_dist_from := 'GROUP_OWNED';
  l_dist_to  := 'INDIVIDUAL_ASSIGNED';
  l_delete_flag_yes	:= 'Y';
  l_bindvar_fm_ctr := 0;
  l_bindvar_to_ctr := 0;

 /* performance issues with the query and try three different approach and using the one that is giving better performance
    1. owner_id in (select group_id from jtf_rs_group_members
                    where resource_id = :resource_id
                    and nvl(delete_flag,'N') <> 'Y');
    2. exists (select 1 from jtf_rs_group_members
                    where resource_id = :resource_id
                    and nvl(delete_flag,'N') <> 'Y');
    3. owner_id in (group_id1, group_id2, group_id3); - Explicitly passing the string.

    Using # 3 approach so, the following loop is getting the group_ids for that resource_id and building the
    string: if only one group_id then string would be 'owner_id = group_id1' if no group_id then owner_id = ''
    if more than one group_ids then 'owner_id in (group_id1, group_id2...group_idx)'

    Note: Right now, this approch is only applied for GROUP_OWNED because GROUP_ASSIGNED is not being used. In the future when
    GROUP_ASSIGNED is used then should apply the same logic to build the string.
  */

   for grp_id in c_grp_id(p_resource_id)
   loop
     p_grp_id_list(z).group_id := grp_id.group_id;
     z := z + 1;
   end loop;

   if p_grp_id_list.count = 0 then
          l_bindvar_fm_ctr := l_bindvar_fm_ctr + 1;
          l_df_grp_id_clause := 'owner_id in ('||':owner_id'||l_bindvar_fm_ctr||')';
          x_bindvar_from_list(l_bindvar_fm_ctr).bind_name := ':owner_id'||l_bindvar_fm_ctr;
          x_bindvar_from_list(l_bindvar_fm_ctr).value :='';

   elsif p_grp_id_list.count > 0 then
      for x in p_grp_id_list.first..p_grp_id_list.last
      loop

        if ((p_grp_id_list.count = 1) and (l_df_grp_id_ctr = 0)) then
           l_bindvar_fm_ctr := l_bindvar_fm_ctr + 1;
           x_bindvar_from_list(l_bindvar_fm_ctr).bind_name := ':owner_id'||l_bindvar_fm_ctr;
           x_bindvar_from_list(l_bindvar_fm_ctr).value := p_grp_id_list(x).group_id;

           l_df_grp_id_clause := 'owner_id = '||':owner_id'||l_bindvar_fm_ctr;

        elsif p_grp_id_list.count > 1 then
           if l_df_grp_id_ctr = 0 then
              l_bindvar_fm_ctr := l_bindvar_fm_ctr + 1;
              x_bindvar_from_list(l_bindvar_fm_ctr).bind_name := ':owner_id'||l_bindvar_fm_ctr;
              x_bindvar_from_list(l_bindvar_fm_ctr).value := p_grp_id_list(x).group_id;
              l_df_grp_id_clause := 'owner_id in ('||':owner_id'||l_bindvar_fm_ctr;
              l_df_grp_id_ctr := l_df_grp_id_ctr + 1;
           else
              l_bindvar_fm_ctr := l_bindvar_fm_ctr + 1;
              x_bindvar_from_list(l_bindvar_fm_ctr).bind_name := ':owner_id'||l_bindvar_fm_ctr;
              x_bindvar_from_list(l_bindvar_fm_ctr).value := p_grp_id_list(x).group_id;
              l_df_grp_id_clause := l_df_grp_id_clause||', '||':owner_id'||l_bindvar_fm_ctr;
              l_df_grp_id_ctr := l_df_grp_id_ctr + 1;
           end if;
         end if;
         if l_df_grp_id_ctr = p_grp_id_list.count then
            l_df_grp_id_clause := l_df_grp_id_clause||')';
         end if;
      end loop;
   end if;
--   insert into p_temp values('final grp where clause '||l_df_grp_id_clause, 101);commit;

   for i in p_ws_det_list.first .. p_ws_det_list.last
   loop

      -- This will not throw any exception here, as the ws_code will be validated in the public api before calling
      -- this procedure.

      BEGIN
	   l_not_valid_flag := 'N';
           select WS_B.WS_ID
           into   l_ws_id
           from   IEU_UWQM_WORK_SOURCES_B WS_B
           where  ws_code = p_ws_det_list(i).ws_code
--           and    ws_b.not_valid_flag = 'N';
           and    ws_b.not_valid_flag = l_not_valid_flag;
      EXCEPTION
           when others then
              null;
      END;

	-- Group Owned
        if (l_dist_from= 'GROUP_OWNED')
        then

             -- Build the Work Source Where clause
             -- If this is the 1st WS, then where clause should be ws_id = :1
             -- else use ws_id in (:1,:2,..)

             if (l_df_grp_own_ctr = 0)
             then
              l_bindvar_fm_ctr := l_bindvar_fm_ctr + 1;
              x_bindvar_from_list(l_bindvar_fm_ctr).bind_name := ':ws_id'||l_bindvar_fm_ctr;
              x_bindvar_from_list(l_bindvar_fm_ctr).value := l_ws_id;

                 l_df_own_ws_clause1 := ' ws_id = '||':ws_id'||l_bindvar_fm_ctr;
                 l_df_own_ws_clause := ' ws_id in ('||':ws_id'||l_bindvar_fm_ctr;
                 l_df_grp_own_ctr := l_df_grp_own_ctr + 1;
             else
              l_bindvar_fm_ctr := l_bindvar_fm_ctr + 1;
              x_bindvar_from_list(l_bindvar_fm_ctr).bind_name := ':ws_id'||l_bindvar_fm_ctr;
              x_bindvar_from_list(l_bindvar_fm_ctr).value := l_ws_id;
                 l_df_own_ws_clause := l_df_own_ws_clause || ', '||':ws_id'||l_bindvar_fm_ctr;
                 l_df_grp_own_ctr := l_df_grp_own_ctr + 1;
             end if;

          if l_fm_group_owned_flag = 'F' then
             l_bindvar_fm_ctr := l_bindvar_fm_ctr + 1;
             x_bindvar_from_list(l_bindvar_fm_ctr).bind_name := ':owner_type'||l_bindvar_fm_ctr;
             x_bindvar_from_list(l_bindvar_fm_ctr).value := 'RS_GROUP';
             -- Build the complete Grp Own Where clause
             l_df_own_where_clause := ' owner_type = '||':owner_type'||l_bindvar_fm_ctr||
                                      ' and '||l_df_grp_id_clause;
            l_fm_group_owned_flag := 'T';
          end if;

--             insert into p_temp values(' Dist from group owned '||l_df_own_ws_clause1||' '||l_df_own_ws_clause||' '
--             ||l_df_own_where_clause, l_df_grp_own_ctr);commit;

        end if;

        -- Group Assigned
        if (l_dist_from= 'GROUP_ASSIGNED')
        then

            -- Build the Work Source Where clause
            -- If this is the 1st WS, then where clause should be ws_id = :1
            -- else use ws_id in (:1,:2,..)
            if (l_df_grp_asg_ctr = 0)
            then
              l_bindvar_fm_ctr := l_bindvar_fm_ctr + 1;
              x_bindvar_from_list(l_bindvar_fm_ctr).bind_name := ':ws_id'||l_bindvar_fm_ctr;
              x_bindvar_from_list(l_bindvar_fm_ctr).value := l_ws_id;
                l_df_asg_ws_clause1 := ' ws_id = '||'ws_id'||l_bindvar_fm_ctr;
                l_df_asg_ws_clause := ' ws_id in ('||'ws_id'||l_bindvar_fm_ctr;
                l_df_grp_asg_ctr := l_df_grp_asg_ctr + 1;
            else
              l_bindvar_fm_ctr := l_bindvar_fm_ctr + 1;
              x_bindvar_from_list(l_bindvar_fm_ctr).bind_name := ':ws_id'||l_bindvar_fm_ctr;
              x_bindvar_from_list(l_bindvar_fm_ctr).value := l_ws_id;
                l_df_asg_ws_clause := l_df_asg_ws_clause || ', '||'ws_id'||l_bindvar_fm_ctr;
                l_df_grp_asg_ctr := l_df_grp_asg_ctr + 1;
            end if;

          if l_fm_group_assigned_flag = 'F' then
             l_bindvar_fm_ctr := l_bindvar_fm_ctr + 1;

             x_bindvar_from_list(l_bindvar_fm_ctr).bind_name := ':assignee_type'||l_bindvar_fm_ctr;
             x_bindvar_from_list(l_bindvar_fm_ctr).value := 'RS_GROUP';

             l_bindvar_fm_ctr := l_bindvar_fm_ctr + 1;

             x_bindvar_from_list(l_bindvar_fm_ctr).bind_name := ':delete_flag'||l_bindvar_fm_ctr;
             x_bindvar_from_list(l_bindvar_fm_ctr).value := 'N';


             l_bindvar_fm_ctr := l_bindvar_fm_ctr + 1;

             x_bindvar_from_list(l_bindvar_fm_ctr).bind_name := ':delete_flag'||l_bindvar_fm_ctr;
             x_bindvar_from_list(l_bindvar_fm_ctr).value := 'Y';



            -- Build the complete Grp Asg Where clause
            l_df_asg_where_clause := ' assignee_type = '||':assignee_type'||(l_bindvar_fm_ctr-2)||
                                     ' and assignee_id in
						(select group_id from jtf_rs_group_members
                                                 where resource_id = :resource_id'||
                                                 ' and nvl(delete_flag,'||':delete_flag'||(l_bindvar_fm_ctr-1)||') <> '||':delete_flag'||l_bindvar_fm_ctr||')';

            l_fm_group_assigned_flag := 'T';
         end if;

         end if;



         -- Distribute_To

         if (p_type = 'DELIVER')
         then

	     -- Group Owned
	     if (l_dist_to = 'INDIVIDUAL_OWNED')
	     then

	        -- Build the Work Source Where clause
	        -- If this is the 1st WS, then where clause should be ws_id = :1
	        -- else use ws_id in (:1,:2,..)
	        if (l_dt_grp_own_ctr = 0)
	        then
                   l_bindvar_to_ctr := l_bindvar_to_ctr + 1;

                   x_bindvar_to_list(l_bindvar_to_ctr).bind_name := ':ws_id'||l_bindvar_to_ctr;
                   x_bindvar_to_list(l_bindvar_to_ctr).value := l_ws_id;
	           l_dt_own_ws_clause1 := ' ws_id = '||':ws_id'||l_bindvar_to_ctr;
	           l_dt_own_ws_clause := ' ws_id in ('||':ws_id'||l_bindvar_to_ctr;
	           l_dt_grp_own_ctr := l_dt_grp_own_ctr + 1;
	        else
                   l_bindvar_to_ctr := l_bindvar_to_ctr + 1;

                   x_bindvar_to_list(l_bindvar_to_ctr).bind_name := ':ws_id'||l_bindvar_to_ctr;
                   x_bindvar_to_list(l_bindvar_to_ctr).value := l_ws_id;
        	   l_dt_own_ws_clause := l_dt_own_ws_clause || ', '||':ws_id'||l_bindvar_to_ctr;
	           l_dt_grp_own_ctr := l_dt_grp_own_ctr + 1;
	        end if;

          if l_to_ind_owned_flag = 'F' then
             l_bindvar_to_ctr := l_bindvar_to_ctr + 1;

             x_bindvar_to_list(l_bindvar_to_ctr).bind_name := ':owner_type'||l_bindvar_to_ctr;
             x_bindvar_to_list(l_bindvar_to_ctr).value := 'RS_INDIVIDUAL';

     		-- Build the complete Grp Own Where clause
	        l_dt_own_where_clause := ' owner_type = '||':owner_type'||l_bindvar_to_ctr||
                	                 ' and owner_id = :resource_id';
             l_to_ind_owned_flag := 'T' ;
          end if;


          end if;


 	     -- Group Assigned
	     if (l_dist_to = 'INDIVIDUAL_ASSIGNED')
	     then

	        -- Build the Work Source Where clause
	        -- If this is the 1st WS, then where clause should be ws_id = :1
	        -- else use ws_id in (:1,:2,..)

	        if (l_dt_grp_asg_ctr = 0)
	        then
                   l_bindvar_to_ctr := l_bindvar_to_ctr + 1;

                   x_bindvar_to_list(l_bindvar_to_ctr).bind_name := ':ws_id'||l_bindvar_to_ctr;
                   x_bindvar_to_list(l_bindvar_to_ctr).value := l_ws_id;
	           l_dt_asg_ws_clause1 := ' ws_id = '||':ws_id'||l_bindvar_to_ctr;
	           l_dt_asg_ws_clause := ' ws_id in ('||':ws_id'||l_bindvar_to_ctr;
	           l_dt_grp_asg_ctr := l_dt_grp_asg_ctr + 1;
	        else
                   l_bindvar_to_ctr := l_bindvar_to_ctr + 1;

                   x_bindvar_to_list(l_bindvar_to_ctr).bind_name := ':ws_id'||l_bindvar_to_ctr;
                   x_bindvar_to_list(l_bindvar_to_ctr).value := l_ws_id;
	           l_dt_asg_ws_clause := l_dt_asg_ws_clause || ', '||':ws_id'||l_bindvar_to_ctr;
	           l_dt_grp_asg_ctr := l_dt_grp_asg_ctr + 1;
	        end if;
          if l_to_ind_assigned_flag = 'F' then
             l_bindvar_to_ctr := l_bindvar_to_ctr + 1;

             x_bindvar_to_list(l_bindvar_to_ctr).bind_name := ':assignee_type'||l_bindvar_to_ctr;
             x_bindvar_to_list(l_bindvar_to_ctr).value := 'RS_INDIVIDUAL';

	        -- Build the complete Grp Asg Where clause
	        l_dt_asg_where_clause := ' assignee_type = '||':assignee_type'||l_bindvar_to_ctr||
             	                         ' and assignee_id = :resource_id';

--             insert into p_temp values('dist to individual assigned '||l_df_asg_ws_clause1||' '||l_df_asg_ws_clause||' '
--             ||l_df_asg_where_clause, l_df_grp_asg_ctr);commit;
             l_to_ind_assigned_flag := 'T';
         end if;


	      end if;

          end if; /* p_type = Deliver */

   end loop; /* p_ws_det_list.first . p_ws_det_list.last */


   ---------------- **************** Built The where Clause for Distribute_from **************** ----------------------

   -- Add closing paranthesis to Work Source Where Clause
   -- ws_id in (1,2,3)
   if (l_df_grp_own_ctr > 1)
   then
      if (l_df_own_ws_clause is not null)
      then
        l_df_own_ws_clause  := l_df_own_ws_clause  || ')';
      end if;
   end if;

   if (l_df_grp_asg_ctr > 1)
   then
      if (l_df_asg_ws_clause is not null)
      then
       l_df_asg_ws_clause  := l_df_asg_ws_clause  || ')';
      end if;
   end if;

   l_df_final_where := null;

   -- set the final where_clause
   -- This includes both Grp Own and Grp Asg where clause

   if (l_df_grp_own_ctr = 1)
   then
     if ((l_df_own_ws_clause1 is not null) and
         (l_df_own_where_clause is not null))
     then
--       l_final_where := '( '||l_own_ws_clause1 || l_own_where_clause || ')';
       l_df_final_where := '( '||l_df_own_where_clause || ' and ' || l_df_own_ws_clause1 || ')';
     end if;
   elsif (l_df_grp_own_ctr > 1)
   then
     if ((l_df_own_ws_clause is not null) and
         (l_df_own_where_clause is not null))
     then
--       l_final_where := '( '||l_own_ws_clause || l_own_where_clause || ')';
       l_df_final_where := '( '|| l_df_own_where_clause || ' and ' || l_df_own_ws_clause || ')';
     end if;
   end if;


   if (l_df_grp_asg_ctr = 1)
   then
     if ((l_df_asg_ws_clause1 is not null) and
         (l_df_asg_where_clause is not null))
     then
       if (l_df_final_where is null)
       then
--          l_final_where := '( '||l_asg_ws_clause1 || l_asg_where_clause || ')';
          l_df_final_where := '( '||l_df_asg_where_clause || ' and '||l_df_asg_ws_clause1 ||  ')';
       elsif (l_df_final_where is not null)
       then
--           l_final_where := l_final_where||' OR '|| '( '|| l_asg_ws_clause1 || l_asg_where_clause|| ')';
           l_df_final_where := l_df_final_where||' OR '|| '( '|| l_df_asg_where_clause||' and '||l_df_asg_ws_clause1|| ')';
       end if;
     end if;
   elsif (l_df_grp_asg_ctr > 1)
   then
     if ((l_df_asg_ws_clause is not null) and
        (l_df_asg_where_clause is not null))
     then
       if (l_df_final_where is null)
       then
--           l_final_where := '( '||l_asg_ws_clause || l_asg_where_clause|| ')';
           l_df_final_where := '( '||l_df_asg_where_clause|| ' and '||l_df_asg_ws_clause ||  ')';
       elsif (l_df_final_where is not null)
       then
--           l_final_where := l_final_where||' OR '|| '( '|| l_asg_ws_clause || l_asg_where_clause|| ')';
           l_df_final_where := l_df_final_where||' OR '|| '( '|| l_df_asg_where_clause||' and '||l_df_asg_ws_clause ||  ')';
       end if;
     end if;
   end if;

   x_dist_from_where := l_df_final_where;

--   insert into p_temp values('final from where '||x_dist_from_where, 1);commit;
   --dbms_output.put_line('dist from: '||x_dist_from_where);

   ---------------- **************** Built The where Clause for Distribute_to **************** ----------------------


   if (p_type = 'DELIVER')
   then


	   -- Add closing paranthesis to Work Source Where Clause
	   -- ws_id in (1,2,3)
	   if (l_dt_grp_own_ctr > 1)
	   then
	      if (l_dt_own_ws_clause is not null)
	      then
	           l_dt_own_ws_clause  := l_dt_own_ws_clause  || ')';
	      end if;
	   end if;


	   if (l_dt_grp_asg_ctr > 1)
	   then
	      if (l_dt_asg_ws_clause is not null)
	      then
		   l_dt_asg_ws_clause  := l_dt_asg_ws_clause  || ')';
	      end if;
  	   end if;

	   l_dt_final_where := null;

	   -- set the final where_clause
	   -- This includes both Grp Own and Grp Asg where clause

	   if (l_dt_grp_own_ctr = 1)
	   then
	     if ((l_dt_own_ws_clause1 is not null) and
	         (l_dt_own_where_clause is not null))
	     then
	--       l_final_where := '( '||l_own_ws_clause1 || l_own_where_clause || ')';
	       l_dt_final_where := '( '||l_dt_own_where_clause ||' and '||l_dt_own_ws_clause1 ||')';
	     end if;
	   elsif (l_dt_grp_own_ctr > 1)
	   then
	     if ((l_dt_own_ws_clause is not null) and
	         (l_dt_own_where_clause is not null))
	     then
	--       l_final_where := '( '||l_own_ws_clause || l_own_where_clause || ')';
	       l_dt_final_where := '( '||l_dt_own_where_clause ||' and '||l_dt_own_ws_clause || ')';
	     end if;
	   end if;

	   if (l_dt_grp_asg_ctr = 1)
	   then
	     if ((l_dt_asg_ws_clause1 is not null) and
	         (l_dt_asg_where_clause is not null))
	     then
	       if (l_dt_final_where is null)
	       then
	--          l_final_where := '( '||l_asg_ws_clause1 || l_asg_where_clause || ')';
	          l_dt_final_where := '( '||l_dt_asg_where_clause ||' and '||l_dt_asg_ws_clause1 || ')';
	       elsif (l_dt_final_where is not null)
	       then
	--           l_final_where := l_final_where||' OR '|| '( '|| l_asg_ws_clause1 || l_asg_where_clause|| ')';
	           l_dt_final_where := l_dt_final_where||' OR '|| '( '|| l_dt_asg_where_clause||' and '||l_dt_asg_ws_clause1 || ')';
	       end if;
	     end if;
	   elsif (l_dt_grp_asg_ctr > 1)
	   then
	     if ((l_dt_asg_ws_clause is not null) and
	        (l_dt_asg_where_clause is not null))
	     then
	       if (l_dt_final_where is null)
	       then
	--           l_final_where := '( '||l_asg_ws_clause || l_asg_where_clause|| ')';
	           l_dt_final_where := '( '||l_dt_asg_where_clause||' and '||l_dt_asg_ws_clause || ')';
	       elsif (l_dt_final_where is not null)
	       then
	--           l_final_where := l_final_where||' OR '|| '( '|| l_asg_ws_clause || l_asg_where_clause|| ')';
	           l_dt_final_where := l_dt_final_where||' OR '|| '( '|| l_dt_asg_where_clause||' and '||l_dt_asg_ws_clause || ')';
	       end if;
	     end if;
	   end if;


         x_dist_to_where := l_dt_final_where;
        --dbms_output.put_line('dist from: '||x_dist_to_where);
   --insert into p_temp values('final to where '||x_dist_to_where, 2);commit;



   end if; /* p_type = Deliver */

END GET_WS_WHERE_CLAUSE;

PROCEDURE GET_WS_WHERE_CLAUSE
    (p_ws_det_list      IN IEU_UWQ_GET_NEXT_WORK_PVT.IEU_WS_DETAILS_LIST,
     p_resource_id      IN NUMBER,
     x_dist_from_where OUT NOCOPY VARCHAR2,
     x_dist_to_where   OUT NOCOPY VARCHAR2
    ) IS
 l_list IEU_UWQ_BINDVAR_LIST;
BEGIN
  GET_WS_WHERE_CLAUSE ('DISTRIBUTE', p_ws_det_list, p_resource_id, x_dist_from_where, x_dist_to_where,l_list,l_list);
END GET_WS_WHERE_CLAUSE;
PROCEDURE CLEANUP_DISTRIBUTING_STATUS
 (
  P_resource_id IN NUMBER,
  X_MSG_DATA   OUT NOCOPY VARCHAR2,
  X_RETURN_STATUS OUT NOCOPY VARCHAR2
 )
  IS

 p_grp_id_list     IEU_UWQ_GET_NEXT_WORK_PVT.IEU_GRP_ID_LIST;
 l_df_grp_id_clause varchar2(1000);
 l_df_grp_id_ctr number := 0;
 z number := 1;
 l_sql_stmt varchar2(4000);

 l_distribution_status_id number;
 l_status_id number;
 l_last_update_date date;

 l_delete_flag_no varchar2(1);

  cursor c_grp_id(p_resource_id in number) is
    select group_id from jtf_rs_group_members
    where resource_id = p_resource_id
    and nvl(delete_flag, 'N') =  l_delete_flag_no;

BEGIN
  l_delete_flag_no :='N';
  l_distribution_status_id := 2;
  l_status_id := 0;
  l_last_update_date := sysdate - 10/1440;

  if ( p_resource_id is not null)
  then
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   for grp_id in c_grp_id(p_resource_id)
   loop
     p_grp_id_list(z).group_id := grp_id.group_id;
     z := z + 1;
   end loop;

    if p_grp_id_list.count = 0 then
          l_df_grp_id_clause := 'owner_id in ('||''''||''||''''||')';
   elsif p_grp_id_list.count > 0 then
      for x in p_grp_id_list.first..p_grp_id_list.last
      loop

        if ((p_grp_id_list.count = 1) and (l_df_grp_id_ctr = 0)) then
           l_df_grp_id_clause := 'owner_id = '||p_grp_id_list(x).group_id;
        elsif p_grp_id_list.count > 1 then
           if l_df_grp_id_ctr = 0 then
              l_df_grp_id_clause := 'owner_id in ('||p_grp_id_list(x).group_id;
              l_df_grp_id_ctr := l_df_grp_id_ctr + 1;
           else
              l_df_grp_id_clause := l_df_grp_id_clause||', '||p_grp_id_list(x).group_id;
              l_df_grp_id_ctr := l_df_grp_id_ctr + 1;
           end if;
         end if;
         if l_df_grp_id_ctr = p_grp_id_list.count then
            l_df_grp_id_clause := l_df_grp_id_clause||')';
         end if;
      end loop;
   end if;
   l_df_grp_id_clause := '(  owner_type = '||''''||'RS_GROUP'||''''||' and '||l_df_grp_id_clause||')';


   l_sql_stmt := 'UPDATE IEU_UWQM_ITEMS
                  SET DISTRIBUTION_STATUS_ID = 1
                  WHERE '|| l_df_grp_id_clause ||
                  'AND DISTRIBUTION_STATUS_ID = '||':l_distribution_status_id '||
                   'AND STATUS_ID = '||':l_status_id'
                   ||' and to_date(last_update_date'||','||''''||'DD-MON-YYYY HH24:MI:SS'||''''||')  < '
                   ||' to_date('||''''||l_last_update_date||''''||','||''''||'DD-MON-YYYY HH24:MI:SS'||''''||')' ;

   BEGIN
       execute immediate l_sql_stmt
       using in l_distribution_status_id, in l_status_id;
     EXCEPTION WHEN OTHERS THEN
      X_MSG_DATA := SQLCODE||' '||SQLERRM;
    END;
    commit;
   end if;

EXCEPTION
  WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_msg_data := SQLCODE||' '||sqlerrm;

END CLEANUP_DISTRIBUTING_STATUS;


END IEU_UWQ_GET_NEXT_WORK_PVT;


/
