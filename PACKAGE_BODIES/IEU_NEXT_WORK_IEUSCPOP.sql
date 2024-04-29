--------------------------------------------------------
--  DDL for Package Body IEU_NEXT_WORK_IEUSCPOP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_NEXT_WORK_IEUSCPOP" AS
/* $Header: IEUGNWDB.pls 115.6 2004/06/03 15:57:48 pkumble noship $ */


PROCEDURE EXECUTE_NEXT_WORK_PROC(
   p_resource_id  IN  number,
   p_ws_id_str    IN  VARCHAR2,
   p_disp_cnt     IN  number,
   x_wr_item_data_list IN OUT nocopy IEU_NEXT_WORK_IEUSCPOP.IEU_WR_ITEM_DATA)
IS
  l_extra_where_clause varchar2(4000);
  l_sql_stmt varchar2(4000);

  l_ctr number;
  l_nw_ctr number;

  l_nw_cur         IEU_NEXT_WORK_IEUSCPOP.l_get_work;
  l_nw_item        IEU_NEXT_WORK_IEUSCPOP.IEU_WR_ITEM_DATA_REC := null;
--  l_nw_items_list  IEU_NEXT_WORK_IEUSCPOP.IEU_WR_ITEM_DATA;

BEGIN

 -- insert into p_temp(msg) values('inside'); commit;
  l_extra_where_clause := ' ( distribution_status_id = 1 and owner_type = '||''''||'RS_GROUP'||''''||
                          ' and owner_id in(select group_id from jtf_rs_group_members where resource_id = ' || p_resource_id ||
                          ' and nvl(delete_flag,'||''''||'N'||''''||') = '||''''||'N'||''''||') ' || ' ) OR ( '||
			  ' distribution_status_id =  3 and assignee_type = ' || ''''|| 'RS_INDIVIDUAL'||''''||
			  ' and assignee_id = '|| p_resource_id  || ' ) ';

-- insert into p_temp(msg) values(l_extra_where_clause); commit;

  -- Build the complete select stmt
  l_sql_stmt := 'SELECT /*+ FIRST_ROWS */ WORK_ITEM_ID, WORKITEM_OBJ_CODE, WORKITEM_PK_ID,' ||
  		        'PRIORITY_LEVEL, DUE_DATE, OWNER_ID, OWNER_TYPE_ACTUAL OWNER_TYPE, ASSIGNEE_ID, ' ||
                'ASSIGNEE_TYPE_ACTUAL ASSIGNEE_TYPE, SOURCE_OBJECT_TYPE_CODE, RESCHEDULE_TIME, WS_ID, ' ||
                'DISTRIBUTION_STATUS_ID, WORK_ITEM_NUMBER FROM IEU_UWQM_ITEMS '||
               ' WHERE ( '|| l_extra_where_clause  || ' ) '||
               ' AND WS_ID in ( ' || p_ws_id_str || ' ) ' ||
       --        ' AND DISTRIBUTION_STATUS_ID in (1,3) ' ||
               ' AND STATUS_ID = 0 ' ||
               ' and    reschedule_time <= sysdate ' ||
               ' order by priority_level, due_date ';

 -- insert into p_temp(msg) values(l_sql_stmt); commit;

  l_ctr := 0;
  l_nw_ctr := 1;

  OPEN l_nw_cur FOR l_sql_stmt;

  LOOP
     FETCH l_nw_cur into l_nw_item;

     exit when ( (l_nw_cur%NOTFOUND) OR (l_nw_ctr > p_disp_cnt) ) ;

     l_nw_ctr := l_nw_ctr + 1;

     x_wr_item_data_list(l_ctr).WORK_ITEM_ID            :=   l_nw_item.WORK_ITEM_ID;
     x_wr_item_data_list(l_ctr).WORKITEM_OBJ_CODE       :=   l_nw_item.WORKITEM_OBJ_CODE;
     x_wr_item_data_list(l_ctr).WORKITEM_PK_ID          :=   l_nw_item.WORKITEM_PK_ID;
     x_wr_item_data_list(l_ctr).PRIORITY_LEVEL          :=   l_nw_item.PRIORITY_LEVEL;
     x_wr_item_data_list(l_ctr).DUE_DATE                :=   l_nw_item.DUE_DATE;
     x_wr_item_data_list(l_ctr).OWNER_ID                :=   l_nw_item.OWNER_ID;
     x_wr_item_data_list(l_ctr).OWNER_TYPE              :=   l_nw_item.OWNER_TYPE;
     x_wr_item_data_list(l_ctr).ASSIGNEE_ID             :=   l_nw_item.ASSIGNEE_ID;
     x_wr_item_data_list(l_ctr).ASSIGNEE_TYPE           :=   l_nw_item.ASSIGNEE_TYPE;
     x_wr_item_data_list(l_ctr).SOURCE_OBJECT_TYPE_CODE :=   l_nw_item.SOURCE_OBJECT_TYPE_CODE;
     x_wr_item_data_list(l_ctr).RESCHEDULE_TIME         :=   l_nw_item.RESCHEDULE_TIME;
     x_wr_item_data_list(l_ctr).WS_ID                   :=   l_nw_item.WS_ID;
     x_wr_item_data_list(l_ctr).DISTRIBUTION_STATUS_ID  :=   l_nw_item.DISTRIBUTION_STATUS_ID;
     x_wr_item_data_list(l_ctr).WORK_ITEM_NUMBER        :=   l_nw_item.WORK_ITEM_NUMBER;

     l_ctr := l_ctr + 1;

  END LOOP;
  CLOSE l_nw_cur;

commit;
END EXECUTE_NEXT_WORK_PROC;

procedure WORK_SOURCE_PROFILE_ENABLED(p_name IN varchar2, p_user_id IN number, p_responsibility_id IN number, p_application_id IN number, x_enabled_flag out nocopy varchar2) IS
 l_enabled_flag varchar2(5);
begin
 -- insert into p_temp(msg) values('before execute profile flag ');commit;

  execute immediate 'select FND_PROFILE.VALUE_SPECIFIC(:1, :2, :3, :4) from dual' into l_enabled_flag
  using IN p_name, IN p_user_id, IN p_responsibility_id, IN p_application_id;

 -- insert into p_temp(msg) values('profile flag '||l_enabled_flag);commit;
  x_enabled_flag := l_enabled_flag;
end;

END IEU_NEXT_WORK_IEUSCPOP;

/
