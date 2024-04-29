--------------------------------------------------------
--  DDL for Package Body BIS_PMV_APPROVALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_PMV_APPROVALS_PVT" as
/* $Header: BISAPPVB.pls 120.0.12000000.1 2007/01/19 17:54:36 appldev ship $ */
-- dbdrv: sql ~PROD ~PATH ~FILE none none none package &phase=plb \
-- dbdrv: checkfile(115.13=120.0):~PROD:~PATH:~FILE
----------------------------------------------------------------------------
--  PACKAGE:      BIS_PMV_APPROVALS_PVT
--                                                                        --
--  DESCRIPTION:  Approvals APIs for PMV
--                                                                        --
--  MODIFICATIONS                                                         --
--  Date       User       Modification
--  XX-XXX-XX  XXXXXXXX   Modifications made, which procedures changed &  --
--                        list bug number, if fixing a bug.               --
--                                --
--  12/02/05   nkishore   Initial creation                                --
----------------------------------------------------------------------------
PROCEDURE APPROVALS_SQL (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                         ,x_custom_sql         OUT  NOCOPY VARCHAR2
                         ,x_custom_attr        OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS
l_sql varchar2(5000);
l_exp_url varchar2(1000);
l_req_url varchar2(1000);
l_custom_rec  BIS_QUERY_ATTRIBUTES;
l_bind_ctr    NUMBER;
l_code_table  BISVIEWER.t_char;
l_meaning_table BISVIEWER.t_char;
l_type_where VARCHAR2(1000);
l_types VARCHAR(1000);
l_mean_types VARCHAR2(1000);
l_msg_types BISVIEWER.t_char;
l_notif_count BISVIEWER.t_num;
l_more_msg_types BISVIEWER.t_char;
l_more_notif_count BISVIEWER.t_num;
l_found boolean;
l_first boolean;
l_len NUMBER;

CURSOR getApprovalTypes  is
     SELECT lookup_code, meaning FROM fnd_lookup_values_vl WHERE lookup_type = 'BIS_PMV_APPROVAL_TYPES';

CURSOR get_Notifications IS
   SELECT n.message_type, count(distinct n.notification_id)
   FROM wf_notifications n, wf_notification_attributes a
   where n.notification_id = a.notification_id
   AND ( (n.more_info_role is null)
   AND (n.recipient_role in (SELECT role_name from wf_user_roles where user_name=FND_GLOBAL.USER_NAME)))
   and n.status='OPEN' and n.message_type in (SELECT lookup_code FROM fnd_lookup_values WHERE lookup_type = 'BIS_PMV_APPROVAL_TYPES')
   group by n.message_type;

CURSOR get_more_notifications IS
   SELECT n.message_type, count(distinct n.notification_id)
   FROM wf_notifications n, wf_notification_attributes a
   where n.notification_id = a.notification_id  AND
   (n.more_info_role in (SELECT role_name from wf_user_roles where user_name=FND_GLOBAL.USER_NAME))
   and n.status='OPEN' and n.message_type in (SELECT lookup_code FROM fnd_lookup_values WHERE lookup_type = 'BIS_PMV_APPROVAL_TYPES')
   group by n.message_type;

BEGIN
  l_exp_url := '''pFunctionName=BIS_PMV_APPROVALS_DETAIL&pParamIds=Y&APPR_STATUS+APPR_STATUS=OPEN&DBI_OBJ_TYPE=BIS_NOTIFY_PROMPT''';
  l_req_url := '''pFunctionName=BIS_PMV_APPROVALS_DETAIL&pParamIds=Y&APPR_STATUS+APPR_STATUS=OPEN&DBI_OBJ_TYPE=BIS_NOTIFY_PROMPT''';
  --l_exp_url := '''pFunctionName=WF_SS_NOTIFICATIONS&pParamIds=Y'''; --put this if there is a change later for notifications

  IF get_Notifications%ISOPEN THEN
    CLOSE get_Notifications;
  END IF;
  OPEN  get_Notifications;
  FETCH get_Notifications BULK COLLECT INTO l_msg_types, l_notif_count;
  CLOSE get_Notifications;

  IF get_more_notifications%ISOPEN THEN
    CLOSE get_more_notifications;
  END IF;
  OPEN  get_more_notifications;
  FETCH get_more_notifications BULK COLLECT INTO l_more_msg_types, l_more_notif_count;
  CLOSE get_more_notifications;

IF l_more_msg_types IS NOT NULL AND l_more_msg_types.COUNT >0 THEN
      FOR i IN l_more_msg_types.FIRST..l_more_msg_types.LAST LOOP
        l_found := false;
        IF ( (l_msg_types IS NOT NULL) AND (l_msg_types.COUNT >0) ) THEN
          FOR j IN l_msg_types.FIRST..l_msg_types.LAST LOOP
              IF(l_more_msg_types(i) = l_msg_types(j)) THEN
                 l_notif_count(j) := l_notif_count(j)+l_more_notif_count(i);
                 l_found := true;
              END IF;
          END LOOP;
        END IF;
        IF(NOT l_found) THEN
          l_len := l_msg_types.COUNT;
          l_msg_types(l_len+1) := l_more_msg_types(i);
          l_notif_count(l_len+1) := l_more_notif_count(i);
        END IF;
      END LOOP;
END IF;

  IF getApprovalTypes%ISOPEN THEN
        CLOSE getApprovalTypes;
  END IF;
  OPEN  getApprovalTypes;
  FETCH getApprovalTypes BULK COLLECT INTO l_code_table, l_meaning_table;
  CLOSE getApprovalTypes;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();
  l_bind_ctr := 1;
  l_first := true;

  IF l_msg_types IS NOT NULL AND l_msg_types.COUNT >0 THEN
    FOR i IN l_msg_types.FIRST..l_msg_types.LAST LOOP
      IF(NOT l_first) THEN
        l_sql := l_sql || ' UNION ';
      END IF;

      l_custom_rec.attribute_name := ':l_msgtype'||i;
      l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
      l_custom_rec.attribute_value := l_msg_types(i);
      l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
      x_custom_attr.Extend();
      x_custom_attr(l_bind_ctr):=l_custom_rec;
      l_bind_ctr:=l_bind_ctr+1;

      l_mean_types := ' decode(:l_msgtype'||i;

      IF l_code_table IS NOT NULL AND l_code_table.COUNT >0 THEN
         FOR j IN l_code_table.FIRST..l_code_table.LAST LOOP
            l_mean_types := l_mean_types||' ,'||':l_appcode'||j||', '||':l_app_meaning'||j;
         END LOOP;
      END IF;

      l_mean_types := l_mean_types||' ,:l_msgtype'||i||') VIEWBY, ';

      l_sql := l_sql || ' (SELECT '|| l_mean_types || ' :l_msgtype'||i||' BIS_NOTIFY_PROMPT, ' || l_notif_count(i) ||' BIS_OBJECT_ROW_COUNT, '||
               l_exp_url ||' BISREPORTURL '||
               ' FROM DUAL) ';
      l_first := false;
    END LOOP;
  END IF;
    IF( l_first) THEN
      l_sql := ' SELECT n.message_type VIEWBY, n.message_type BIS_NOTIFY_PROMPT, 0 BIS_OBJECT_ROW_COUNT, '||'''url'''||' BISREPORTURL '||
               ' FROM wf_notifications n WHERE 1=2 ';
    END IF;
  /*
  l_sql := ' SELECT '||l_mean_types||
           ' n.message_type BIS_NOTIFY_PROMPT, count(distinct n.notification_id) BIS_OBJECT_ROW_COUNT, '|| l_exp_url ||' BISREPORTURL '||
           ' FROM wf_notifications n, wf_notification_attributes a
             where  n.notification_id = a.notification_id
             and n.status ='||'''OPEN'''||l_type_where||
           ' and n.recipient_role in (SELECT role_name from wf_user_roles where user_name=FND_GLOBAL.USER_NAME) '||
           ' group by n.message_type ';*/

  x_custom_sql := l_sql;


  IF l_code_table IS NOT NULL AND l_code_table.COUNT >0 THEN
      FOR i IN l_code_table.FIRST..l_code_table.LAST LOOP
        l_custom_rec.attribute_name :=':l_appcode'||i;
        l_custom_rec.attribute_value := l_code_table(i);
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

        l_custom_rec.attribute_name :=':l_app_meaning'||i;
        l_custom_rec.attribute_value := l_meaning_table(i);
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;

      END LOOP;
  END IF;

END APPROVALS_SQL;

PROCEDURE APPROVALS_DETAIL_SQL (p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                         ,x_custom_sql         OUT  NOCOPY VARCHAR2
                         ,x_custom_attr        OUT  NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS
l_sql varchar2(5000);
l_drill_url varchar2(1000);
l_status varchar2(30);
l_msg_type varchar2(80);
l_status_where varchar2(250);
l_type_where varchar2(250);
l_orderby VARCHAR2(250);
l_custom_rec  BIS_QUERY_ATTRIBUTES;
l_bind_ctr    NUMBER;
l_code_table  BISVIEWER.t_char;
l_types       VARCHAR2(250);
l_select_clause VARCHAR2(2000);
l_from_clause VARCHAR2(200);
l_notif_where_clause VARCHAR2(200);
l_recipient_where_clause VARCHAR2(500);
l_more_where_clause VARCHAR2(500);
l_isOpen boolean;
--l_req_url varchar2(1000);
cursor getApprovalTypes  is
     SELECT lookup_code FROM fnd_lookup_values_vl WHERE lookup_type = 'BIS_PMV_APPROVAL_TYPES';
BEGIN
    FOR i in 1..p_page_parameter_tbl.COUNT
    LOOP
       IF (p_page_parameter_tbl(i).parameter_name = 'APPR_STATUS+APPR_STATUS') THEN
            l_status := p_page_parameter_tbl(i).parameter_id;
       ELSIF (p_page_parameter_tbl(i).parameter_name = 'APPR_MSGTYPE+APPR_MSGTYPE') THEN
            l_msg_type := p_page_parameter_tbl(i).parameter_id;
       ELSIF (p_page_parameter_tbl(i).parameter_name = 'ORDERBY') THEN
            l_orderby := ' ORDER BY '|| p_page_parameter_tbl(i).parameter_value;
       END IF;
    END LOOP;
    l_isOpen := false;
    IF ((l_msg_type is not null))THEN
     l_msg_type := replace(l_msg_type, '''','');
    END IF;
    IF ((l_status is not null))THEN
     l_status := replace(l_status, '''','');
    END IF;

    IF (l_msg_type ='APEXP') THEN
        l_type_where := ' and n.message_type='||'''APEXP''';
    ELSIF (l_msg_type = 'REQAPPRV') THEN
        l_type_where := ' and n.message_type='||'''REQAPPRV''';
    ELSIF (l_msg_type is not null) THEN
        l_type_where := ' and n.message_type=:msg_type ';
    ELSE
       --Start of getting all approval types
       IF getApprovalTypes%ISOPEN THEN
           CLOSE getApprovalTypes;
       END IF;
       OPEN  getApprovalTypes;
       FETCH getApprovalTypes BULK COLLECT INTO l_code_table;
       CLOSE getApprovalTypes;

       IF l_code_table IS NOT NULL AND l_code_table.COUNT >0 THEN
         FOR i IN l_code_table.FIRST..l_code_table.LAST LOOP
            l_types := l_types||','||':l_appcode'||i;
         END LOOP;
       END IF;
       l_type_where := ' AND n.message_type IN('||substr(l_types,2)||') ';
       --End of getting all approval types
    END IF;
    IF (l_status ='OPEN') THEN
        l_isOpen := true;
        l_status_where := ' and n.status='||'''OPEN''';
    ELSIF (l_status = 'CLOSED') THEN
        l_status_where := ' and n.status='||'''CLOSED''';
    ELSIF (l_status = 'CANCELED') THEN
        l_status_where := ' and n.status='||'''CANCELED''';
    ELSE
       l_status_where := ' ';
    END IF;

    --l_drill_url := '''pFunctionName=FII_IEXPENSES_DRILL&dbiReportHeaderId=BIS_COLUMN_5&pParamIds=Y&APPR_MSGTYPE=BIS_STATUS''';
    --l_req_url := '''pFunctionName=POA_DBI_REQ_DRILL&reqHeaderId=BIS_COLUMN_5''';

    l_drill_url := '''pFunctionName=FND_WFNTF_DETAILS&NtfId=BIS_COLUMN_5&pParamIds=Y''';

    l_select_clause := ' SELECT distinct FROM_USER BIS_COLUMN_1, n.subject BIS_COLUMN_2,'||
                       ' n.begin_date BIS_COLUMN_3, n.end_date BIS_COLUMN_4,'||
                       ' n.notification_id BIS_COLUMN_5 ,'||
                       l_drill_url ||' BIS_COLUMN_6 ';
    l_from_clause := ' FROM wf_notifications n, wf_notification_attributes a ';
    l_notif_where_clause := ' where n.notification_id = a.notification_id ';
    IF (l_isOpen) THEN
      l_recipient_where_clause := ' AND ( (n.more_info_role is null) AND (n.recipient_role in (SELECT role_name from wf_user_roles where user_name=FND_GLOBAL.USER_NAME))) ';
    ELSE
      l_recipient_where_clause := ' AND ( n.recipient_role in (SELECT role_name from wf_user_roles where user_name=FND_GLOBAL.USER_NAME)) ';
    END IF;
    l_more_where_clause := ' AND (n.more_info_role in (SELECT role_name from wf_user_roles where user_name=FND_GLOBAL.USER_NAME)) ';


    l_sql := '('||l_select_clause || l_from_clause ||l_notif_where_clause||
             l_recipient_where_clause ||
             l_status_where || l_type_where ||')';
    l_sql := l_sql||' UNION ('||l_select_clause || l_from_clause ||l_notif_where_clause||
             l_more_where_clause ||
             l_status_where || l_type_where ||')';
    l_sql := l_sql || l_orderby;
    x_custom_sql := l_sql;

    l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
    x_custom_attr := BIS_QUERY_ATTRIBUTES_TBL();

    l_bind_ctr := 1;
    l_custom_rec.attribute_name := ':msg_type';
    l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_value := l_msg_type;
    l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
    x_custom_attr.Extend();
    x_custom_attr(l_bind_ctr):=l_custom_rec;
    l_bind_ctr:=l_bind_ctr+1;

  IF l_code_table IS NOT NULL AND l_code_table.COUNT >0 THEN
      FOR i IN l_code_table.FIRST..l_code_table.LAST LOOP
        l_custom_rec.attribute_name :=':l_appcode'||i;
        l_custom_rec.attribute_value := l_code_table(i);
        l_custom_rec.attribute_data_type :=BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        l_custom_rec.attribute_type :=BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        x_custom_attr.Extend();
        x_custom_attr(l_bind_ctr):=l_custom_rec;
        l_bind_ctr:=l_bind_ctr+1;
      END LOOP;
  END IF;

END APPROVALS_DETAIL_SQL;


END BIS_PMV_APPROVALS_PVT;

/
