--------------------------------------------------------
--  DDL for Package Body IEU_DIAG_AUDIT_TRACK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_DIAG_AUDIT_TRACK_PVT" AS
/* $Header: IEUATRB.pls 120.2 2006/01/14 09:02:40 msista noship $ */
PROCEDURE getUnDis ( x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT NOCOPY NUMBER,
                        x_msg_data  OUT  NOCOPY VARCHAR2,
                        p_from_date IN DATE, -- format : 10-JAN-04
                        p_to_date   IN DATE,
                        x_results OUT NOCOPY IEU_DIAG_DISTRIBUTING_NST
                        )AS
    l_msg_count            NUMBER(2);

    l_msg_data             VARCHAR2(2000);
    l_ws_name              varchar2(100) ;
    prev_ws_name           varchar2(100);
    i                      integer;
    j                      integer;
    l_count                integer;
    l_from_date            date ;
    l_to_date              DATE ;
    l_date                 date;
    owner_name             varchar2(2000);
    assignee_name             varchar2(2000);
    priority               varchar2(2000);
    title                  varchar2(2000);
    l_results              IEU_DIAG_NOTMEMBER_NST;
    l_tmp  number;
    l_temp_count  number;
    work_item_number  number;
    l_ws_code   varchar2(2000);
   cursor cur_items IS
   Select a.workitem_pk_id,
          a.title,
          DECODE(a.STATUS_ID,'0', 'Open', '3', 'Close', '4', 'Delete', '5', 'Sleep') status,
          a.priority_id,
          a.due_date,
          a.reschedule_time,
          a.OWNER_ID,
		a.owner_type,
          a.ASSIGNEE_ID,
		a.assignee_type,
		a.ws_id
   from ieu_uwqm_items a
	 Where a.DISTRIBUTION_STATUS_ID = 0
   And nvl(a.owner_type, 'NULL') <> 'RS_GROUP'
   AND nvl(a.assignee_type, 'NULL') <> 'RS_INDIVIDUAL'
   and a.creation_date  BETWEEN p_from_date AND  p_to_date
   ORDER BY a.title;

BEGIN
    owner_name  :='';
    assignee_name  :='';
    priority  :='';
    l_temp_count  :=0;
    work_item_number :=0;
    l_ws_name := 'ws_name';
    prev_ws_name := 'ws_name';
    l_ws_code:='';
    i := 0;
    l_count :=0;
    j :=0;
    l_tmp :=0;
    title :='';
    --dbms_output.put_line('begin');
    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    x_msg_data := 'begin--> from '||p_from_date||' to '|| p_to_date;
    FND_MSG_PUB.initialize;
    x_results := IEU_DIAG_DISTRIBUTING_NST();
    FOR cur_rec IN cur_items
        LOOP
            --dbms_output.put_line('in the loop of cur_rec');
            i := i+1;

            x_results.EXTEND(1);
           -- dbms_output.put_line('extended');
          owner_name  :='';
          assignee_name  :='';
          priority  :='';
          title := '';
		l_ws_code :='';
		l_ws_name :='';

           if cur_rec.owner_id is not null then
            if cur_rec.owner_type = 'RS_GROUP' then
            begin
              select group_name into owner_name
              from jtf_rs_groups_tl
              where group_id = cur_rec.owner_id and language =  FND_GLOBAL.CURRENT_LANGUAGE;
            exception
            when no_data_found then null;
            end;
            else
            begin
              select resource_name into owner_name
              from JTF_RS_RESOURCE_EXTNS_vl
              where resource_id = cur_rec.owner_id;
                  exception
            when no_data_found then null;
                  end;
            end if;
           end if;

          if cur_rec.assignee_id is not null then
          if cur_rec.assignee_type = 'RS_INDIVIDUAL' then
          begin
            select resource_name into assignee_name
            from JTF_RS_RESOURCE_EXTNS_vl
            where resource_id = cur_rec.assignee_id;
                exception
          when no_data_found then null;
                end;
                else
          begin
                  select group_name into assignee_name
            from jtf_rs_groups_tl
            where group_id = cur_rec.assignee_id and language =  FND_GLOBAL.CURRENT_LANGUAGE;
                exception
          when no_data_found then null;
                end;
            end if;
          end if;


          if cur_rec.priority_id is not null then
		begin
                select name into priority
                from ieu_uwqm_priorities_tl
                where  priority_id = cur_rec.priority_id
                and language = FND_GLOBAL.CURRENT_LANGUAGE;
          exception
          when no_data_found then null;
                end;
        end if;

       if cur_rec.ws_id is not null then
       begin
        select ws_name into l_ws_name
	   from ieu_uwqm_work_sources_tl
	   where ws_id = cur_rec.ws_id
	   and language =  FND_GLOBAL.CURRENT_LANGUAGE;
       exception
       when no_data_found then null;
       end;
	  end if;

           --dbms_output.put_line('extened');
            x_results(x_results.last) :=IEU_DIAG_DISTRIBUTING_OBJ(cur_rec.workitem_pk_id,
                                                               cur_rec.title,
                                                               cur_rec.status,
                                                               priority,
                                                               cur_rec.due_date,
                                                               cur_rec.reschedule_time,
												                                       cur_rec.owner_id,
                                                               owner_name,
												                                       cur_rec.assignee_id,
                                                               assignee_name,
												   l_ws_name
                                                                  );

        end LOOP;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := sqlerrm;
      x_msg_count := fnd_msg_pub.COUNT_MSG();
       FOR i in 1..x_msg_count LOOP
           l_msg_data := '';
           l_msg_count := 0;
           FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
           x_msg_data := x_msg_data || ',' || l_msg_data;
       END LOOP;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data := sqlerrm;
      x_msg_count := fnd_msg_pub.COUNT_MSG();
       FOR i in 1..x_msg_count LOOP
           l_msg_data := '';
           l_msg_count := 0;
           FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
           x_msg_data := x_msg_data || ',' || l_msg_data;
       END LOOP;


    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data := sqlerrm;
        x_msg_count := fnd_msg_pub.COUNT_MSG();
       FOR i in 1..x_msg_count LOOP
           l_msg_data := '';
           l_msg_count := 0;
           FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
           x_msg_data := x_msg_data || ',' || l_msg_data;
       END LOOP;

end getUnDis;

PROCEDURE getDisSpe ( x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT NOCOPY NUMBER,
                        x_msg_data  OUT  NOCOPY VARCHAR2,
                        p_user_name  IN varchar2,
                        p_from_date IN DATE, -- format : 10-JAN-04
                        p_to_date   IN DATE,
                        x_results OUT NOCOPY IEU_DIAG_DISTRIBUTING_NST
                        )AS
    l_msg_count            NUMBER(2);

    l_msg_data             VARCHAR2(2000);
    prev_ws_name           varchar2(100);
    i                      integer;
    j                      integer;
    l_count                integer;
    l_from_date            date ;
    l_to_date              DATE ;
    l_date                 date;
    owner_name             varchar2(2000);
    assignee_name             varchar2(2000);
    priority               varchar2(2000);

    l_results              IEU_DIAG_NOTMEMBER_NST;
    l_tmp  number;
    l_temp_count  number;
    work_item_number  number;
    l_ws_code varchar2(2000);
    l_ws_name varchar2(2000);
    l_user_id FND_USER.USER_ID%TYPE;
    l_sql   VARCHAR2(4000);

   cursor cur_items IS
   Select a.workitem_pk_id,
          a.title,
          DECODE(a.STATUS_ID,'0', 'Open', '3', 'Close', '4', 'Delete', '5', 'Sleep') status,
          a.priority_id,
          a.due_date,
          a.reschedule_time,
          a.OWNER_ID,
		a.owner_type,
          a.ASSIGNEE_ID,
		a.assignee_type,
		a.ws_id
	from ieu_uwqm_items a
	 Where a.DISTRIBUTION_STATUS_ID = 3
   And a.assignee_type = 'RS_INDIVIDUAL'
   And a.assignee_id IN ( select resource_id  from JTF_RS_RESOURCE_EXTNS where lower(user_name) = lower(p_user_name))
   and a.creation_date  BETWEEN p_from_date AND  p_to_date
   ORDER BY a.title;


BEGIN
    owner_name  :='';
    assignee_name  :='';
    priority  :='';
    l_temp_count  :=0;
    work_item_number :=0;
    l_ws_name := 'ws_name';
    prev_ws_name := 'ws_name';
    i := 0;
    l_count :=0;
    j :=0;
    l_tmp :=0;
    --dbms_output.put_line('begin');
    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    --x_msg_data := 'begin--> from '||p_from_date||' to '|| p_to_date;
    x_msg_data := '';
    FND_MSG_PUB.initialize;
    x_results := IEU_DIAG_DISTRIBUTING_NST();

    begin

      -- msista 1/14/06 - the following sql can be removed because the queried
      --                  user_id is not used, but the query is used for
      --                  validating the user_name as a part of the diagnostic
      --                  test, so leaving it as is.
      l_sql := ' select user_id from fnd_user where upper(user_name) like upper( :p_user_name)';
	 EXECUTE IMMEDIATE l_sql into l_user_id USING p_user_name;

	 EXCEPTION
	   WHEN NO_DATA_FOUND THEN
	   FND_MESSAGE.set_name('IEU', 'IEU_DIAG_USER_INVALID');
	   FND_MSG_PUB.Add;
	   x_return_status := FND_API.G_RET_STS_ERROR;
	   x_msg_count := fnd_msg_pub.COUNT_MSG();

	   FOR i in 1..x_msg_count LOOP
	   l_msg_data := '';
	   l_msg_count := 0;
	   FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
	   x_msg_data := x_msg_data || ',' || l_msg_data;
	   END LOOP;

    end;

    if (x_return_status = 'S') then
      FOR cur_rec IN cur_items
        LOOP
            --dbms_output.put_line('in the loop of cur_rec');
            i := i+1;

            x_results.EXTEND(1);
           -- dbms_output.put_line('extended');
          owner_name  :='';
          assignee_name  :='';
          priority  :='';
		l_ws_code:='';
		l_ws_name:='';

           if cur_rec.owner_id is not null then
            if cur_rec.owner_type = 'RS_GROUP' then
            begin
              select group_name into owner_name
              from jtf_rs_groups_tl
              where group_id = cur_rec.owner_id and language =  FND_GLOBAL.CURRENT_LANGUAGE;
            exception
            when no_data_found then null;
            end;
            else
            begin
              select resource_name into owner_name
              from JTF_RS_RESOURCE_EXTNS_vl
              where resource_id = cur_rec.owner_id;
                  exception
            when no_data_found then null;
                  end;
            end if;
           end if;

          if cur_rec.assignee_id is not null then
          if cur_rec.assignee_type = 'RS_INDIVIDUAL' then
          begin
            select resource_name into assignee_name
            from JTF_RS_RESOURCE_EXTNS_vl
            where resource_id = cur_rec.assignee_id;
                exception
          when no_data_found then null;
                end;
                else
          begin
                  select group_name into assignee_name
            from jtf_rs_groups_tl
            where group_id = cur_rec.assignee_id and language =  FND_GLOBAL.CURRENT_LANGUAGE;
                exception
          when no_data_found then null;
                end;
            end if;
          end if;



	       if cur_rec.priority_id is not null then
          begin
                select name into priority
                from ieu_uwqm_priorities_tl
                where  priority_id = cur_rec.priority_id
                and language = FND_GLOBAL.CURRENT_LANGUAGE;
          exception
          when no_data_found then null;
                end;
        end if;

       if cur_rec.ws_id is not null then
       begin
		select ws_name into l_ws_name
	     from ieu_uwqm_work_sources_tl
	     where ws_id = cur_rec.ws_id
	     and language =  FND_GLOBAL.CURRENT_LANGUAGE;
       exception
       when no_data_found then null;
       end;
	  end if;



           --dbms_output.put_line('extened');
            x_results(x_results.last) :=IEU_DIAG_DISTRIBUTING_OBJ(cur_rec.workitem_pk_id,
                                                               cur_rec.title,
                                                               cur_rec.status,
                                                               priority,
                                                               cur_rec.due_date,
                                                               cur_rec.reschedule_time,
												                                       cur_rec.owner_id,
                                                               owner_name,
												                                       cur_rec.assignee_id,
                                                               assignee_name,
												   l_ws_name
                                                                  );
        end LOOP;
	 end if;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := sqlerrm;
      x_msg_count := fnd_msg_pub.COUNT_MSG();
       FOR i in 1..x_msg_count LOOP
           l_msg_data := '';
           l_msg_count := 0;
           FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
           x_msg_data := x_msg_data || ',' || l_msg_data;
       END LOOP;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data := sqlerrm;
      x_msg_count := fnd_msg_pub.COUNT_MSG();
       FOR i in 1..x_msg_count LOOP
           l_msg_data := '';
           l_msg_count := 0;
           FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
           x_msg_data := x_msg_data || ',' || l_msg_data;
       END LOOP;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data := sqlerrm;
        x_msg_count := fnd_msg_pub.COUNT_MSG();
       FOR i in 1..x_msg_count LOOP
           l_msg_data := '';
           l_msg_count := 0;
           FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
           x_msg_data := x_msg_data || ',' || l_msg_data;
       END LOOP;

end getDisSpe;
PROCEDURE getReDis( x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT NOCOPY NUMBER,
                        x_msg_data  OUT  NOCOPY VARCHAR2,
                        p_group_name IN Varchar2,
                        p_from_date IN DATE, -- format : 10-JAN-04
                        p_to_date   IN DATE,
                        x_results OUT NOCOPY IEU_DIAG_REQUEUED_NST
                        )AS
    l_msg_count            NUMBER(2);

    l_msg_data             VARCHAR2(2000);
    l_ws_name              varchar2(100) ;
    prev_ws_name           varchar2(100);
    i                      integer;
    j                      integer;
    l_count                integer;
    l_from_date            date ;
    l_to_date              DATE ;
    l_date                 date;
    owner_name_prev             varchar2(2000);
    assignee_name_prev             varchar2(2000);
    owner_name_curr             varchar2(2000);
    assignee_name_curr             varchar2(2000);
    l_results              IEU_DIAG_NOTMEMBER_NST;
    l_tmp  number;
    l_temp_count  number;
    work_item_number  number;
    title varchar2(2000);
   cursor cur_items IS
   Select a.workitem_pk_id, a.workitem_obj_code,
          DECODE(a.workitem_STATUS_ID_curr,'0', 'Open', '3', 'Close', '4', 'Delete', '5', 'Sleep') status,
          a.owner_id_prev,a.owner_id_curr,a.owner_type_prev,a.owner_type_curr,
          a.assignee_id_prev,a.assignee_id_curr,a.assignee_type_prev,a.assignee_type_curr,
          ws_code
   from ieu_uwqm_audit_log a
	 Where a.creation_date between p_from_date and p_to_date
   And (a.assignee_type_prev ='RS_INDIVIDUAL' )
   and (a.assignee_type_curr ='RS_INDIVIDUAL')
 	 and (a.assignee_id_prev <> a.assignee_id_curr)
   AND a.owner_id_curr in ( select group_id from jtf_rs_groups_vl where lower(group_name) = lower(p_group_name))
    ORDER BY a.creation_date;




BEGIN
    owner_name_prev  :='';
    assignee_name_prev  :='';
    l_temp_count  :=0;
    work_item_number :=0;
    l_ws_name := 'ws_name';
    prev_ws_name := 'ws_name';
    title := '';
    i := 0;
    l_count :=0;
    j :=0;
    l_tmp :=0;
    --dbms_output.put_line('begin');
    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    x_msg_data := 'begin--> from '||p_from_date||' to '|| p_to_date;
    FND_MSG_PUB.initialize;
    x_results := IEU_DIAG_REQUEUED_NST();

    FOR cur_rec IN cur_items
        LOOP
            --dbms_output.put_line('in the loop of cur_rec');
            i := i+1;

            x_results.EXTEND(1);
           -- dbms_output.put_line('extended');
          owner_name_prev  :='';
          assignee_name_prev  :='';
          owner_name_curr  :='';
          assignee_name_curr  :='';
          title  :='';
		l_ws_name := '';


           begin
              select title into title
              from ieu_uwqm_items where workitem_pk_id = cur_rec.workitem_pk_id
              and workitem_obj_code=cur_rec.workitem_obj_code;
           exception
              when no_data_found then null;
           end;
           if cur_rec.owner_id_prev is not null then
            if cur_rec.owner_type_prev = 'RS_GROUP' then
            begin
              select group_name into owner_name_prev
              from jtf_rs_groups_tl
              where group_id = cur_rec.owner_id_prev and language =  FND_GLOBAL.CURRENT_LANGUAGE;
            exception
            when no_data_found then null;
            end;
            else
            begin
              select resource_name into owner_name_prev
              from JTF_RS_RESOURCE_EXTNS_vl
              where resource_id = cur_rec.owner_id_prev;
                  exception
            when no_data_found then null;
                  end;
            end if;
           end if;

          if cur_rec.assignee_id_prev is not null then
            if cur_rec.assignee_type_prev = 'RS_INDIVIDUAL' then
            begin
              select resource_name into assignee_name_prev
              from JTF_RS_RESOURCE_EXTNS_vl
              where resource_id = cur_rec.assignee_id_prev;
            exception
              when no_data_found then null;
                  end;
            else
            begin
              select group_name into assignee_name_prev
              from jtf_rs_groups_tl
              where group_id = cur_rec.assignee_id_prev and language =  FND_GLOBAL.CURRENT_LANGUAGE;
            exception
              when no_data_found then null;
            end;
            end if;
          end if;
           if cur_rec.owner_id_curr is not null then
            if cur_rec.owner_type_curr = 'RS_GROUP' then
            begin
              select group_name into owner_name_curr
              from jtf_rs_groups_tl
              where group_id = cur_rec.owner_id_curr and language =  FND_GLOBAL.CURRENT_LANGUAGE;
            exception
            when no_data_found then null;
            end;
            else
            begin
              select resource_name into owner_name_curr
              from JTF_RS_RESOURCE_EXTNS_vl
              where resource_id = cur_rec.owner_id_curr;
                  exception
            when no_data_found then null;
                  end;
            end if;
           end if;

          if cur_rec.assignee_id_curr is not null then
            if cur_rec.assignee_type_curr = 'RS_INDIVIDUAL' then
            begin
              select resource_name into assignee_name_curr
              from JTF_RS_RESOURCE_EXTNS_vl
              where resource_id = cur_rec.assignee_id_curr;
            exception
              when no_data_found then null;
                  end;
            else
            begin
              select group_name into assignee_name_curr
              from jtf_rs_groups_tl
              where group_id = cur_rec.assignee_id_curr and language =  FND_GLOBAL.CURRENT_LANGUAGE;
            exception
              when no_data_found then null;
            end;
            end if;
          end if;

          if cur_rec.ws_code is not null then
		begin
	     select ws_name into l_ws_name
		from ieu_uwqm_work_sources_tl tl, ieu_uwqm_work_sources_b b
	     where b.ws_id = tl.ws_id
	     and tl.language =  FND_GLOBAL.CURRENT_LANGUAGE
	     and b.ws_code=cur_rec.ws_code;
            exception
              when no_data_found then null;
            end;
		end if;


           --dbms_output.put_line('extened');
            x_results(x_results.last) :=IEU_DIAG_REQUEUED_OBJ(cur_rec.workitem_pk_id,
                                                               title,
                                                               cur_rec.status,
												                                       cur_rec.owner_id_prev,
                                                               owner_name_prev,
                                                               cur_rec.owner_id_curr,
                                                               owner_name_curr,
												                                       cur_rec.assignee_id_prev,
                                                               assignee_name_prev,
                                                               cur_rec.assignee_id_curr,
                                                               assignee_name_curr,
												   l_ws_name
                                                                  );
        end LOOP;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := sqlerrm;
      x_msg_count := fnd_msg_pub.COUNT_MSG();
       FOR i in 1..x_msg_count LOOP
           l_msg_data := '';
           l_msg_count := 0;
           FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
           x_msg_data := x_msg_data || ',' || l_msg_data;
       END LOOP;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data := sqlerrm;
      x_msg_count := fnd_msg_pub.COUNT_MSG();
       FOR i in 1..x_msg_count LOOP
           l_msg_data := '';
           l_msg_count := 0;
           FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
           x_msg_data := x_msg_data || ',' || l_msg_data;
       END LOOP;


    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data := sqlerrm;
        x_msg_count := fnd_msg_pub.COUNT_MSG();
       FOR i in 1..x_msg_count LOOP
           l_msg_data := '';
           l_msg_count := 0;
           FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
           x_msg_data := x_msg_data || ',' || l_msg_data;
       END LOOP;

end getReDis;
PROCEDURE getRequeued( x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT NOCOPY NUMBER,
                        x_msg_data  OUT  NOCOPY VARCHAR2,
                        p_from_date IN DATE, -- format : 10-JAN-04
                        p_to_date   IN DATE,
                        x_results OUT NOCOPY IEU_DIAG_REQUEUED_NST
                        )AS
    l_msg_count            NUMBER(2);

    l_msg_data             VARCHAR2(2000);
    l_ws_name              varchar2(100) ;
    prev_ws_name           varchar2(100);
    i                      integer;
    j                      integer;
    l_count                integer;
    l_from_date            date ;
    l_to_date              DATE ;
    l_date                 date;
    owner_name_prev             varchar2(2000);
    assignee_name_prev             varchar2(2000);
    owner_name_curr             varchar2(2000);
    assignee_name_curr             varchar2(2000);
    l_results              IEU_DIAG_NOTMEMBER_NST;
    l_tmp  number;
    l_temp_count  number;
    work_item_number  number;
    title varchar2(2000);
   cursor cur_items IS
   Select a.workitem_pk_id, a.workitem_obj_code,
          DECODE(a.workitem_STATUS_ID_curr,'0', 'Open', '3', 'Close', '4', 'Delete', '5', 'Sleep') status,
          a.owner_id_prev,a.owner_id_curr,a.owner_type_prev,a.owner_type_curr,
          a.assignee_id_prev,a.assignee_id_curr,a.assignee_type_prev,a.assignee_type_curr,
		ws_code
   from ieu_uwqm_audit_log a
	 Where a.creation_date between p_from_date and p_to_date
   And (   (a.owner_type_prev <> 'RS_GROUP')
            and  (a.owner_type_curr = 'RS_GROUP')
            and  (a.assignee_type_curr is null)
       )
   OR
       (   (a.owner_type_prev = 'RS_GROUP')
            and (a.owner_type_curr = 'RS_GROUP')
            and  (a.assignee_type_curr is null)
            and  (a.owner_id_prev <> a.owner_id_curr)
       )
    OR
			 (   (a.assignee_type_prev is not null)
            and (a.assignee_type_curr is null)
 			      and (a.owner_type_curr = 'RS_GROUP')
       )
    ORDER BY a.creation_date;




BEGIN
    owner_name_prev  :='';
    assignee_name_prev  :='';
    l_temp_count  :=0;
    work_item_number :=0;
    l_ws_name := 'ws_name';
    prev_ws_name := 'ws_name';
    title := '';
    i := 0;
    l_count :=0;
    j :=0;
    l_tmp :=0;
    --dbms_output.put_line('begin');
    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    x_msg_data := 'begin--> from '||p_from_date||' to '|| p_to_date;
    FND_MSG_PUB.initialize;
    x_results := IEU_DIAG_REQUEUED_NST();

    FOR cur_rec IN cur_items
        LOOP
            --dbms_output.put_line('in the loop of cur_rec');
            i := i+1;

            x_results.EXTEND(1);
           -- dbms_output.put_line('extended');
          owner_name_prev  :='';
          assignee_name_prev  :='';
          owner_name_curr  :='';
          assignee_name_curr  :='';
          title  :='';
		l_ws_name := '';


           begin
              select title into title
              from ieu_uwqm_items where workitem_pk_id = cur_rec.workitem_pk_id
              and workitem_obj_code=cur_rec.workitem_obj_code;
           exception
              when no_data_found then null;
           end;
           if cur_rec.owner_id_prev is not null then
            if cur_rec.owner_type_prev = 'RS_GROUP' then
            begin
              select group_name into owner_name_prev
              from jtf_rs_groups_tl
              where group_id = cur_rec.owner_id_prev and language =  FND_GLOBAL.CURRENT_LANGUAGE;
            exception
            when no_data_found then null;
            end;
            else
            begin
              select resource_name into owner_name_prev
              from JTF_RS_RESOURCE_EXTNS_vl
              where resource_id = cur_rec.owner_id_prev;
                  exception
            when no_data_found then null;
                  end;
            end if;
           end if;

          if cur_rec.assignee_id_prev is not null then
            if cur_rec.assignee_type_prev = 'RS_INDIVIDUAL' then
            begin
              select resource_name into assignee_name_prev
              from JTF_RS_RESOURCE_EXTNS_vl
              where resource_id = cur_rec.assignee_id_prev;
            exception
              when no_data_found then null;
                  end;
            else
            begin
              select group_name into assignee_name_prev
              from jtf_rs_groups_tl
              where group_id = cur_rec.assignee_id_prev and language =  FND_GLOBAL.CURRENT_LANGUAGE;
            exception
              when no_data_found then null;
            end;
            end if;
          end if;
           if cur_rec.owner_id_curr is not null then
            if cur_rec.owner_type_curr = 'RS_GROUP' then
            begin
              select group_name into owner_name_curr
              from jtf_rs_groups_tl
              where group_id = cur_rec.owner_id_curr and language =  FND_GLOBAL.CURRENT_LANGUAGE;
            exception
            when no_data_found then null;
            end;
            else
            begin
              select resource_name into owner_name_curr
              from JTF_RS_RESOURCE_EXTNS_vl
              where resource_id = cur_rec.owner_id_curr;
                  exception
            when no_data_found then null;
                  end;
            end if;
           end if;

          if cur_rec.assignee_id_curr is not null then
            if cur_rec.assignee_type_curr = 'RS_INDIVIDUAL' then
            begin
              select resource_name into assignee_name_curr
              from JTF_RS_RESOURCE_EXTNS_vl
              where resource_id = cur_rec.assignee_id_curr;
            exception
              when no_data_found then null;
                  end;
            else
            begin
              select group_name into assignee_name_curr
              from jtf_rs_groups_tl
              where group_id = cur_rec.assignee_id_curr and language =  FND_GLOBAL.CURRENT_LANGUAGE;
            exception
              when no_data_found then null;
            end;
            end if;
          end if;

          if cur_rec.ws_code is not null then
		begin
	     select ws_name into l_ws_name
		from ieu_uwqm_work_sources_tl tl, ieu_uwqm_work_sources_b b
	     where b.ws_id = tl.ws_id
	     and tl.language =  FND_GLOBAL.CURRENT_LANGUAGE
	    and b.ws_code=cur_rec.ws_code;
            exception
              when no_data_found then null;
            end;
		  end if;

           --dbms_output.put_line('extened');
            x_results(x_results.last) :=IEU_DIAG_REQUEUED_OBJ(cur_rec.workitem_pk_id,
                                                               title,
                                                               cur_rec.status,
												                                       cur_rec.owner_id_prev,
                                                               owner_name_prev,
                                                               cur_rec.owner_id_curr,
                                                               owner_name_curr,
												                                       cur_rec.assignee_id_prev,
                                                               assignee_name_prev,
                                                               cur_rec.assignee_id_curr,
                                                               assignee_name_curr,
												   l_ws_name
                                                                  );
        end LOOP;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := sqlerrm;
      x_msg_count := fnd_msg_pub.COUNT_MSG();
       FOR i in 1..x_msg_count LOOP
           l_msg_data := '';
           l_msg_count := 0;
           FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
           x_msg_data := x_msg_data || ',' || l_msg_data;
       END LOOP;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data := sqlerrm;
      x_msg_count := fnd_msg_pub.COUNT_MSG();
       FOR i in 1..x_msg_count LOOP
           l_msg_data := '';
           l_msg_count := 0;
           FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
           x_msg_data := x_msg_data || ',' || l_msg_data;
       END LOOP;


    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data := sqlerrm;
        x_msg_count := fnd_msg_pub.COUNT_MSG();
       FOR i in 1..x_msg_count LOOP
           l_msg_data := '';
           l_msg_count := 0;
           FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
           x_msg_data := x_msg_data || ',' || l_msg_data;
       END LOOP;

end getRequeued;

PROCEDURE getDistributing ( x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT NOCOPY NUMBER,
                        x_msg_data  OUT  NOCOPY VARCHAR2,
                        p_group_name IN varchar2,
                        p_from_date IN DATE, -- format : 10-JAN-04
                        p_to_date   IN DATE,
				    x_results OUT NOCOPY IEU_DIAG_DISTRIBUTING_NST)
				    AS
				    l_msg_count            NUMBER(2);

    l_msg_data             VARCHAR2(2000);
    prev_ws_name           varchar2(100);
    i                      integer;
    j                      integer;
    l_count                integer;
    l_from_date            date ;
    l_to_date              DATE ;
    l_date                 date;
    owner_name             varchar2(2000);
    assignee_name             varchar2(2000);
    priority               varchar2(2000);

    l_results              IEU_DIAG_NOTMEMBER_NST;
    l_tmp  number;
    l_temp_count  number;
    work_item_number  number;
    l_ws_name varchar2(2000);
    l_ws_code varchar2(2000);
   cursor cur_items IS
   Select a.workitem_pk_id,
          a.title,
          DECODE(a.STATUS_ID,'0', 'Open', '3', 'Close', '4', 'Delete', '5', 'Sleep') status,
          a.priority_id,
          a.due_date,
          a.reschedule_time,
          a.OWNER_ID,
		a.owner_type,
          a.ASSIGNEE_ID,
          a.assignee_type,
		a.ws_id
		from ieu_uwqm_items a
	 Where a.DISTRIBUTION_STATUS_ID = 2
   And a.owner_type = 'RS_GROUP'
   And a.owner_id IN (select group_id FROM jtf_rs_groups_vl WHERE lower(GROUP_name) = lower(p_group_name))
   and a.creation_date  BETWEEN p_from_date AND  p_to_date
   ORDER BY a.title;


BEGIN
    owner_name  :='';
    assignee_name  :='';
    priority  :='';
    l_temp_count  :=0;
    work_item_number :=0;
    l_ws_name := 'ws_name'; prev_ws_name := 'ws_name';
    i := 0;
    l_count :=0;
    j :=0;
    l_tmp :=0;
    --dbms_output.put_line('begin');
    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    x_msg_data := 'begin--> from '||p_from_date||' to '|| p_to_date;
    FND_MSG_PUB.initialize;
    x_results := IEU_DIAG_DISTRIBUTING_NST();
    FOR cur_rec IN cur_items
        LOOP
            --dbms_output.put_line('in the loop of cur_rec');
            i := i+1;

            x_results.EXTEND(1);
           -- dbms_output.put_line('extended');
          owner_name  :='';
          assignee_name  :='';
          priority  :='';
		l_ws_code :='';
		l_ws_name :='';

           if cur_rec.owner_id is not null then
            if cur_rec.owner_type = 'RS_GROUP' then
            begin
              select group_name into owner_name
              from jtf_rs_groups_tl
              where group_id = cur_rec.owner_id and language =  FND_GLOBAL.CURRENT_LANGUAGE;
            exception
            when no_data_found then null;
            end;
            else
            begin
              select resource_name into owner_name
              from JTF_RS_RESOURCE_EXTNS_vl
              where resource_id = cur_rec.owner_id;
                  exception
            when no_data_found then null;
                  end;
            end if;
           end if;

          if cur_rec.assignee_id is not null then
          if cur_rec.assignee_type = 'RS_INDIVIDUAL' then
          begin
            select resource_name into assignee_name
            from JTF_RS_RESOURCE_EXTNS_vl
            where resource_id = cur_rec.assignee_id;
                exception
          when no_data_found then null;
                end;
                else
          begin
                  select group_name into assignee_name
            from jtf_rs_groups_tl
            where group_id = cur_rec.assignee_id and language =  FND_GLOBAL.CURRENT_LANGUAGE;
                exception
          when no_data_found then null;
                end;
            end if;
          end if;



	       if cur_rec.priority_id is not null then
          begin
                select name into priority
                from ieu_uwqm_priorities_tl
                where  priority_id = cur_rec.priority_id
                and language = FND_GLOBAL.CURRENT_LANGUAGE;
          exception
          when no_data_found then null;
                end;
        end if;


      if cur_rec.ws_id is not null  then
      begin
	    select ws_name into l_ws_name
	    from ieu_uwqm_work_sources_tl
	    where ws_id = cur_rec.ws_id
	    and language =  FND_GLOBAL.CURRENT_LANGUAGE;
       exception
       when no_data_found then null;
       end;
	  end if;

           --dbms_output.put_line('extened');
            x_results(x_results.last) :=IEU_DIAG_DISTRIBUTING_OBJ(cur_rec.workitem_pk_id,
                                                               cur_rec.title,
                                                               cur_rec.status,
                                                               priority,
                                                               cur_rec.due_date,
                                                               cur_rec.reschedule_time,
												                                       cur_rec.owner_id,
                                                               owner_name,
												                                       cur_rec.assignee_id,
                                                               assignee_name,
												   l_ws_name
                                                                  );
        end LOOP;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := sqlerrm;
      x_msg_count := fnd_msg_pub.COUNT_MSG();
       FOR i in 1..x_msg_count LOOP
           l_msg_data := '';
           l_msg_count := 0;
           FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
           x_msg_data := x_msg_data || ',' || l_msg_data;
       END LOOP;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data := sqlerrm;
      x_msg_count := fnd_msg_pub.COUNT_MSG();
       FOR i in 1..x_msg_count LOOP
           l_msg_data := '';
           l_msg_count := 0;
           FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
           x_msg_data := x_msg_data || ',' || l_msg_data;
       END LOOP;


    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data := sqlerrm;
        x_msg_count := fnd_msg_pub.COUNT_MSG();
       FOR i in 1..x_msg_count LOOP
           l_msg_data := '';
           l_msg_count := 0;
           FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
           x_msg_data := x_msg_data || ',' || l_msg_data;
       END LOOP;

end getDistributing;

PROCEDURE getNotMember ( x_return_status  OUT NOCOPY VARCHAR2,
                        x_msg_count OUT NOCOPY NUMBER,
                        x_msg_data  OUT  NOCOPY VARCHAR2,
                        p_from_date IN DATE, -- format : 10-JAN-04
                        p_to_date   IN DATE,
                         x_groups  OUT NOCOPY IEU_DIAG_GROUP_NST,
                        x_results OUT NOCOPY IEU_DIAG_NOTMEMBER_NST
                        )AS
    l_msg_count            NUMBER(2);

    l_msg_data             VARCHAR2(2000);
    l_ws_name              varchar2(100) ;
    l_ws_code              varchar2(100) ;
    prev_ws_name           varchar2(100);
    i                      integer;
    j                      integer;
    l_count                integer;
    l_from_date            date ;
    l_to_date              DATE ;
    l_date                 date;

    l_results              IEU_DIAG_NOTMEMBER_NST;
    l_tmp  number;
    l_temp_count  number;
    work_item_number  number;
   cursor cur_items IS
   select  distinct a.workitem_pk_id, a.MODULE ,
           DECODE(a.WORKITEM_STATUS_ID_CURR, '0', 'Open', '3', 'Close', '4', 'Delete', '5', 'Sleep') WORKITEM_STATUS_ID_CURR,
           DECODE(a.WORKITEM_DIST_STATUS_ID_CURR, '0', 'On Hold', '1', 'Distributable',
                  '2', 'Distributing', '3', 'Distributed') WORKITEM_DIST_STATUS_ID_CURR ,
           a.workitem_obj_code,a.OWNER_ID_CURR, rs1.group_name owner_name,
           a.ASSIGNEE_ID_CURR, rs2.resource_name assignee_name, a.ws_code, a.work_item_number, b.ws_id, tl.ws_name ws_name
	 FROM ieu_uwqm_audit_log a, ieu_uwqm_work_sources_b b, ieu_uwqm_work_sources_tl tl,
     jtf_rs_groups_vl rs1, JTF_RS_RESOURCE_EXTNS_vl rs2
    WHERE a.owner_type_curr = 'RS_GROUP'
     and a.assignee_type_curr = 'RS_INDIVIDUAL'
     AND a.owner_id_curr = rs1.group_id(+)
     AND a.assignee_id_curr = rs2.resource_id(+)
	and a.workitem_obj_code = b.object_code
	and b.ws_id = tl.ws_id
	and tl.language =  FND_GLOBAL.CURRENT_LANGUAGE
     AND not exists
        (select 1 from jtf_rs_group_members
        where group_id = a.owner_id_curr
        and resource_id = a.assignee_id_curr
        and nvl(delete_flag, 'N') = 'N')
      and a.creation_date BETWEEN p_from_date AND  p_to_date
     ORDER BY a.workitem_obj_code;


BEGIN
    l_from_date := add_months(sysdate, -1 * 2 );
    l_to_date   := add_months(sysdate, 1* 2 );
    l_temp_count  :=0;
    work_item_number :=0;
    l_ws_name := 'ws_name';
    prev_ws_name := 'ws_name';
    i := 0;
    l_count :=0;
    j :=0;
    l_tmp :=0;
    --dbms_output.put_line('begin');
    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    x_msg_data := 'begin--> from '||p_from_date||' to '|| p_to_date;
    FND_MSG_PUB.initialize;
    x_results := IEU_DIAG_NOTMEMBER_NST();
    x_groups := IEU_DIAG_GROUP_NST();
    SELECT count(*) INTO l_tmp FROM (   select  distinct a.workitem_pk_id, a.MODULE ,
           DECODE(a.WORKITEM_STATUS_ID_CURR,'0', 'Not Distributable', '1', 'Distributable',
                  '2', 'Distributing', '3', 'Distributed') WORKITEM_STATUS_ID_CURR,
           DECODE(a.WORKITEM_DIST_STATUS_ID_CURR, '0', 'Not Distributable', '1', 'Distributable',
                  '2', 'Distributing', '3', 'Distributed') WORKITEM_DIST_STATUS_ID_CURR ,
           a.workitem_obj_code,a.OWNER_ID_CURR, rs1.group_name owner_name,
           a.ASSIGNEE_ID_CURR, rs2.resource_name assignee_name, b.ws_id, tl.ws_name ws_name,
		 a.work_item_number
     FROM ieu_uwqm_audit_log a, ieu_uwqm_work_sources_b b, ieu_uwqm_work_sources_tl tl,
     jtf_rs_groups_tl rs1, JTF_RS_RESOURCE_EXTNS_vl rs2
    WHERE a.owner_type_curr = 'RS_GROUP'
     and a.assignee_type_curr = 'RS_INDIVIDUAL'
     and a.workitem_obj_code = b.object_code
     and b.ws_id = tl.ws_id
     AND a.owner_id_curr = rs1.group_id(+)
     AND a.assignee_id_curr = rs2.resource_id(+)
	and rs1.language=FND_GLOBAL.CURRENT_LANGUAGE
     AND not exists
        (select 1 from jtf_rs_group_members
        where group_id = a.owner_id_curr
        and resource_id = a.assignee_id_curr
        and nvl(delete_flag, 'N') = 'N')
      and a.creation_date BETWEEN p_from_date AND  p_to_date
     ORDER BY a.workitem_obj_code);
     x_msg_data := x_msg_data || 'get count is '||l_tmp;
    FOR cur_rec IN cur_items
        LOOP
            x_msg_data := x_msg_data || ' in the loop of cur_rec.';
            --dbms_output.put_line('in the loop of cur_rec');
            i := i+1;
		  l_ws_name :='';

            x_results.EXTEND(1);
           -- dbms_output.put_line('extended');
           x_msg_data := x_msg_data || 'extened';
           --dbms_output.put_line('extened');
	/*   select ws_name into l_ws_name
	   from ieu_uwqm_work_sources_tl tl, ieu_uwqm_work_sources_b b
	   where b.ws_id = tl.ws_id
	   and tl.language =  FND_GLOBAL.CURRENT_LANGUAGE
	   and b.ws_code=cur_rec.ws_code;
*/
            x_results(x_results.last) :=IEU_DIAG_NOTMEMBER_OBJ(cur_rec.workitem_pk_id,
                                                               cur_rec.workitem_obj_code,
                                                               cur_rec.WORKITEM_STATUS_ID_CURR ,
                                                               cur_rec.owner_name,
                                                               cur_rec.assignee_name,
                                                               cur_rec.WORKITEM_DIST_STATUS_ID_CURR,
                                                               cur_rec.MODULE,
                                                               cur_rec.ws_name,
                                                               cur_rec.work_item_number
                                                                  );
           -- dbms_output.put_line('id-->'||i||'....)-'||cur_rec.enum_id);
           --dbms_output.put_line('ws name-->'||cur_rec.workitem_obj_code);
            x_msg_data := x_msg_data || ' primary key is '||cur_rec.workitem_obj_code;
           -- dbms_output.put_line('ws name-->'||cur_rec.ws_name);
           -- x_msg_data := x_msg_data || ' primary key is '||cur_rec.ws_name;
         prev_ws_name := l_ws_name;
	    l_ws_name := cur_rec.ws_name;
         IF (l_ws_name <> prev_ws_name and l_count > 0) THEN
              -- start new work source
              --dbms_output.put_line('l_ws_name is '|| l_ws_name||', cur_rec.ws_name is '||cur_rec.ws_name);
              j := j+1;
              x_groups.extend(1);
              x_groups(x_groups.last) := IEU_DIAG_GROUP_OBJ(l_count, l_ws_name);
             -- x_msg_data := x_msg_data || ' work source name is '||cur_rec.ws_name;
              l_count := 0;
           END IF ;
           l_count := l_count+1;
        end LOOP;
        -- for last record
        IF (l_count > 0) then
        x_groups.extend(1);
        x_groups(x_groups.last) := IEU_DIAG_GROUP_OBJ(l_count, l_ws_name);
        x_msg_data := x_msg_data || ' , outside the loop of  cur_rec. ';
        END if;
    --dbms_output.put_line('x_groups count is '||x_groups.count);



EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        --dbms_output.PUT_LINE('Error : '||sqlerrm);


        x_return_status := FND_API.G_RET_STS_ERROR;
       x_msg_data := sqlerrm;

         x_msg_count := fnd_msg_pub.COUNT_MSG();

             FOR i in 1..x_msg_count LOOP
                 l_msg_data := '';
                 l_msg_count := 0;
                 FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
                 x_msg_data := x_msg_data || ',' || l_msg_data;
             END LOOP;




    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        --dbms_output.PUT_LINE('Error : '||sqlerrm);


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_data := sqlerrm;

           x_msg_count := fnd_msg_pub.COUNT_MSG();

               FOR i in 1..x_msg_count LOOP
                   l_msg_data := '';
                   l_msg_count := 0;
                   FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
                   x_msg_data := x_msg_data || ',' || l_msg_data;
               END LOOP;


    WHEN OTHERS THEN
        --Rollback to IEU_UWQ_MEDIA_TYPES_PVT;
             --dbms_output.PUT_LINE('Error : '||sqlerrm);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         x_msg_data := sqlerrm;

           x_msg_count := fnd_msg_pub.COUNT_MSG();

               FOR i in 1..x_msg_count LOOP
                   l_msg_data := '';
                   l_msg_count := 0;
                   FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
                   x_msg_data := x_msg_data || ',' || l_msg_data;
               END LOOP;

end getNotMember;

PROCEDURE  getLifeCycle(x_return_status  OUT NOCOPY VARCHAR2,
                               x_msg_count OUT NOCOPY NUMBER,
                               x_msg_data  OUT NOCOPY VARCHAR2,
                               p_object_code   IN VARCHAR2,
                               p_item_number   IN varchar2,
                               x_results OUT NOCOPY IEU_DIAG_WORKLIFE_NST
                              )
                              AS

    ws_type  vARCHAR2(2000);
    l_msg_count            NUMBER(2);
    l_language             VARCHAR2(2000);
    l_msg_data             VARCHAR2(2000);
    i integer := 0;
    j integer := 1;
    my_message varchar2(4000);
    l_del_msg  varchar2(4000);
    x_app_name varchar2(25);
    x_msg_name varchar2(1000);

    current_m varchar2(4000) ;
    current_meaning varchar2(4000) ;
    meaning1 varchar2(4000);
    meaning2 varchar2(4000);
    meaning3 varchar2(4000);
    meaning4 varchar2(4000);
    meaning5 varchar2(4000);
    meaning6 varchar2(4000);
    meaning7 varchar2(4000);
    meaning8 varchar2(4000);
    meaning9 varchar2(4000);
    meaning10 varchar2(4000);
    return_status  varchar2(4000) ;
    owner_name varchar2(200) ;
    assignee_name varchar2(200) ;
    action varchar2(200) ;
    event varchar2(200) ;
    l_temp_count NUMBER ;
    priority varchar2(200) ;
    title varchar2(4000) ;
    code varchar2(200) ;
    position number ;
    cursor c_items is
    select a.action_key,a.EVENT_KEY, a.MODULE ,
           DECODE(a.WORKITEM_STATUS_ID_CURR, '0', 'Open', '3', 'Close', '4', 'Delete', '5', 'Sleep') WORKITEM_STATUS_ID_CURR,
           a.owner_id_curr, a.OWNER_TYPE_CURR,
           a.assignee_id_curr,a.ASSIGNEE_TYPE_CURR,
           DECODE(a.PARENT_WORKITEM_STATUS_ID_CURR, '0', 'Open', '3', 'Close',
                  '4', 'Delete', '5', 'Sleep') PARENT_WORKITEM_STATUS_ID_CURR,
           DECODE(a.PARENT_DIST_STATUS_ID_CURR ,'0', 'On Hold', '1', 'Distributable',
                  '2', 'Distributing', '3', 'Distributed') PARENT_DIST_STATUS_ID_CURR,
           DECODE(a.WORKITEM_DIST_STATUS_ID_CURR, '0', 'On Hold', '1', 'Distributable',
                  '2', 'Distributing', '3', 'Distributed') WORKITEM_DIST_STATUS_ID_CURR,
            priority_id_curr ,a.DUE_DATE_CURR ,a.RESCHEDULE_TIME_CURR,
            a.IEU_COMMENT_CODE1 m1,
            a.IEU_COMMENT_CODE2 m2,
            a.IEU_COMMENT_CODE3 m3,
            a.IEU_COMMENT_CODE4 m4,
            a.IEU_COMMENT_CODE5 m5,
            a.WORKITEM_COMMENT_CODE1 m6,
            a.WORKITEM_COMMENT_CODE2 m7,
            a.WORKITEM_COMMENT_CODE3 m8,
            a.WORKITEM_COMMENT_CODE4 m9,
            a.WORKITEM_COMMENT_CODE5 m10, a.LAST_UPDATE_DATE, a.workitem_pk_id,
		  a.return_status, a.error_code, a.ws_code, a.source_object_id_curr, a.source_object_type_code_curr
     FROM ieu_uwqm_audit_log a
	where (a.work_item_number = p_item_number
     AND a.workitem_obj_code = p_object_code)
     or (a.SOURCE_OBJECT_ID_CURR = p_item_number
     and a.SOURCE_OBJECT_TYPE_CODE_CURR = p_object_code)
     order by a.audit_log_id,a.creation_date;

BEGIN

    fnd_msg_pub.delete_msg();
    x_return_status := fnd_api.g_ret_sts_success;
    FND_MSG_PUB.initialize;
    x_results := IEU_DIAG_WORKLIFE_NST();
    l_language := FND_GLOBAL.CURRENT_LANGUAGE;

    current_m :='';
    current_meaning :='';
    meaning1 :='';
    meaning2 :='';
    meaning3 :='';
    meaning4 :='';
    meaning5 :='';
    meaning6 :='';
    meaning7 :='';
    meaning8 :='';
    meaning9 :='';
    meaning10:='';
    return_status  :='';
    owner_name  :='';
    assignee_name  :='';
    action  :='';
    event  :='';
    l_temp_count  :=0;
    priority  :='';
    title  :='';
    code  :='';
    position  :=0;

    FOR cur_rec IN c_items
        LOOP
            --dbms_output.put_line('in the loop of '|| i);
            i := i+1;
            x_results.EXTEND(1);

           -- dbms_output.put_line('extended');
           owner_name :=''; assignee_name :=''; action := ''; event := '';
		 meaning1 := ''; meaning2 := ''; meaning3 := ''; meaning4 := ''; meaning5 :='';
		 meaning6 := ''; meaning7 := ''; meaning8 := ''; meaning9 := ''; meaning10 :='';
		 return_status := '';
           if cur_rec.owner_id_curr is not null then
		  if cur_rec.owner_type_curr = 'RS_GROUP' then
		  begin
              select group_name into owner_name
		    from jtf_rs_groups_tl
		    where group_id = cur_rec.owner_id_curr and language = l_language;
            exception
			when no_data_found then null;
            end;
            else
		  begin
		    select resource_name into owner_name
		    from JTF_RS_RESOURCE_EXTNS_vl
		    where resource_id = cur_rec.owner_id_curr;
            exception
			when no_data_found then null;
            end;
		  end if;
		 end if;

		  if cur_rec.assignee_id_curr is not null then
		  if cur_rec.assignee_type_curr = 'RS_INDIVIDUAL' then
		  begin
		    select resource_name into assignee_name
		    from JTF_RS_RESOURCE_EXTNS_vl
		    where resource_id = cur_rec.assignee_id_curr;
            exception
			when no_data_found then null;
            end;
            else
		  begin
              select group_name into assignee_name
		    from jtf_rs_groups_tl
		    where group_id = cur_rec.assignee_id_curr and language = l_language;
            exception
			when no_data_found then null;
            end;
		    end if;
		  end if;

            if cur_rec.action_key is not null then
		  begin
		  select meaning into action
		  from ieu_lookups where lookup_type = 'IEU_WR_AUDIT_LOG_RULES' and lookup_code = cur_rec.action_key;
            exception
			when no_data_found then action := cur_rec.action_key;
            end;
                  if (cur_rec.SOURCE_OBJECT_ID_CURR = p_item_number
                      and cur_rec.SOURCE_OBJECT_TYPE_CODE_CURR = p_object_code) then
                   begin
		           select ws_type into ws_type
		           from ieu_uwqm_work_sources_b where ws_code = cur_rec.ws_code;
                   exception
			       when no_data_found then null;
                   end;
                  if ws_type = 'ASSOCIATION' then
                  action := action || '<br>(' || cur_rec.ws_code || ')';
			   end if;
                  end if;
	  end if;

            if cur_rec.event_key is not null then
		  begin
		  select meaning into event
		  from ieu_lookups where lookup_type = 'IEU_WR_AUDIT_LOG_RULES' and lookup_code = cur_rec.event_key;
            exception
			when no_data_found then event := cur_rec.event_key;
            end;
		  end if;


            begin
		  select title into title
		  from ieu_uwqm_items where workitem_pk_id = cur_rec.workitem_pk_id
		  and workitem_obj_code=p_object_code;
            exception
			when no_data_found then null;
            end;

	       if cur_rec.priority_id_curr is not null then
		  begin
		  select name into priority
		  from ieu_uwqm_priorities_tl
		  where  priority_id = cur_rec.priority_id_curr
		  and language = l_language;
            exception
			when no_data_found then null;
            end;
		  end if;

            --dbms_output.put_line('m1 is '|| cur_rec.m1);

            for j in 1..10 loop
		  if j=1 then current_m := cur_rec.m1; end if;
		  if j=2 then current_m := cur_rec.m2; end if;
		  if j=3 then current_m := cur_rec.m3; end if;
		  if j=4 then current_m := cur_rec.m4; end if;
		  if j=5 then current_m := cur_rec.m5; end if;
		  if j=6 then current_m := cur_rec.m6; end if;
		  if j=7 then current_m := cur_rec.m7; end if;
		  if j=8 then current_m := cur_rec.m8; end if;
		  if j=9 then current_m := cur_rec.m9; end if;
		  if j=10 then current_m := cur_rec.m10; end if;
            if current_m is not null then
            position := instr(current_m, ' ', 1,1);
            if position > 0 then
              code := substr(current_m, 1, position-1);
            else
              code := current_m;
            end if ;
		  current_meaning :='';
		  begin
            select meaning into current_meaning
            from ieu_lookups where lookup_type = 'IEU_WR_AUDIT_LOG_RULES' and lookup_code = code;
            exception
			when no_data_found then current_meaning :='';
            end;
            if position > 0 then
              current_meaning := current_meaning ||' : '|| substr(current_m, position+1, length(current_m));
            end if ;
		  if j=1 then meaning1 := current_meaning; end if;
		  if j=2 then meaning2 := current_meaning; end if;
		  if j=3 then meaning3 := current_meaning; end if;
		  if j=4 then meaning4 := current_meaning; end if;
		  if j=5 then meaning5 := current_meaning; end if;
		  if j=6 then meaning6 := current_meaning; end if;
		  if j=7 then meaning7 := current_meaning; end if;
		  if j=8 then meaning8 := current_meaning; end if;
		  if j=9 then meaning9 := current_meaning; end if;
		  if j=10 then meaning10 := current_meaning; end if;
            end if;
		  end loop;


            if cur_rec.return_status = 'E' then
		  fnd_msg_pub.reset;
		  fnd_msg_pub.initialize;
		  fnd_message.parse_encoded(cur_rec.error_code, x_app_name, x_msg_name);
		  fnd_message.set_encoded(cur_rec.error_code);
		  fnd_msg_pub.add;
		  fnd_msg_pub.Count_and_Get
				 (
				 p_encoded =>  'F',
		     	         p_count   =>   l_msg_count,
				 p_data    =>  cur_rec.error_code
				 );
		  FND_MESSAGE.set_name('IEU', 'IEU_DIAG_LAU_FAIL');
            return_status :=  FND_MESSAGE.GET();
		  FOR l_index IN 1..l_msg_count LOOP
		     my_message := FND_MSG_PUB.Get(p_msg_index => l_index,p_encoded => 'F');
			if my_message is not null then
		         FND_MESSAGE.set_name('IEU', 'IEU_DIAG_LAU_NEXT_LINE');
			    return_status := return_status || FND_MESSAGE.get()|| my_message ;
			end if;
			--dbms_output.put_line(l_index || ' = ' || my_message);
		     --insert into p_temp(msg) values(l_index || ' = ' || my_message); commit;
		  END LOOP;
		  fnd_msg_pub.set_search_name(x_app_name, x_msg_name);
		  l_del_msg := fnd_msg_pub.delete_msg;
		  end if ;


            x_results(x_results.last) := IEU_DIAG_WORKLIFE_OBJ(
							       event,
                                                               cur_rec.LAST_UPDATE_DATE,
                                                               cur_rec.MODULE,
                                                               cur_rec.WORKITEM_STATUS_ID_CURR ,
                                                               owner_name,
                                                               cur_rec.OWNER_ID_CURR,
                                                               ASSIGNEE_name,
                                                               cur_rec.ASSIGNEE_ID_CURR,
                                                               cur_rec.PARENT_WORKITEM_STATUS_ID_CURR,
                                                               cur_rec.PARENT_DIST_STATUS_ID_CURR,
                                                               cur_rec.WORKITEM_DIST_STATUS_ID_CURR,
                                                               priority,
                                                               cur_rec.DUE_DATE_CURR,
                                                               cur_rec.RESCHEDULE_TIME_CURR,
												   action,
												   title,
												   cur_rec.workitem_pk_id,
												   meaning1,
												   meaning2,
												   meaning3,
												   meaning4,
												   meaning5,
												   meaning6,
												   meaning7,
												   meaning8,
												   meaning9,
												   meaning10,
												   return_status
												   );
           -- dbms_output.put_line('id-->'||i||'....)-'||cur_rec.enum_id);
            --dbms_output.put_line('name-->'||cur_rec.node_name);

        end LOOP;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        --dbms_output.PUT_LINE('Error : '||sqlerrm);


        x_return_status := FND_API.G_RET_STS_ERROR;
       x_msg_data := sqlerrm;

         x_msg_count := fnd_msg_pub.COUNT_MSG();

             FOR i in 1..x_msg_count LOOP
                 l_msg_data := '';
                 l_msg_count := 0;
                 FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
                 x_msg_data := x_msg_data || ',' || l_msg_data;
             END LOOP;




    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        --dbms_output.PUT_LINE('Error : '||sqlerrm);


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_data := sqlerrm;

           x_msg_count := fnd_msg_pub.COUNT_MSG();

               FOR i in 1..x_msg_count LOOP
                   l_msg_data := '';
                   l_msg_count := 0;
                   FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
                   x_msg_data := x_msg_data || ',' || l_msg_data;
               END LOOP;


    WHEN OTHERS THEN
        --Rollback to IEU_UWQ_MEDIA_TYPES_PVT;
             --dbms_output.PUT_LINE('Error : '||sqlerrm);

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         x_msg_data := sqlerrm;

           x_msg_count := fnd_msg_pub.COUNT_MSG();

               FOR i in 1..x_msg_count LOOP
                   l_msg_data := '';
                   l_msg_count := 0;
                   FND_MSG_PUB.Get(i, fnd_api.g_true, l_msg_data, l_msg_count);
                   x_msg_data := x_msg_data || ',' || l_msg_data;
               END LOOP;


end getLifeCycle;


END IEU_DIAG_AUDIT_TRACK_PVT;

/
