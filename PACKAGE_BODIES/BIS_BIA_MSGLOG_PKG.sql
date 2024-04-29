--------------------------------------------------------
--  DDL for Package Body BIS_BIA_MSGLOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIS_BIA_MSGLOG_PKG" AS
/* $Header: BISPMVRB.pls 120.0 2005/06/01 15:35:25 appldev noship $ */

PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY 	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sqltext 			VARCHAR2(20000);
  l_sql_stmt			VARCHAR2(20000);
  l_org				VARCHAR2(20000);
  l_cat 			VARCHAR2(20000);
  l_prod			VARCHAR2(20000);
  l_org_where 			VARCHAR2(20000);
  l_cat_where 			VARCHAR2(20000);
  l_prod_where			VARCHAR2(20000);

  l_temp			VARCHAR2(240);
  l_currency			VARCHAR2(240);
  l_period_type 		VARCHAR2(30);
  l_bklg_amt 			VARCHAR2(20);
  l_g_currency			VARCHAR2(15)	:= '''FII_GLOBAL1''';
  l_cur_suffix 			VARCHAR2(1);

  l_custom_rec			BIS_QUERY_ATTRIBUTES;

  l_span			NUMBER;
  l_item_cat_flag		NUMBER; -- 0 for product and 1 for product category; 3 for no item dimension

  pname      VARCHAR2(1024) := NULL;
  pvalue     VARCHAR2(1024) := NULL;
  message    varchar2(1024) := '%';
  session_id_value varchar2(1024) := null;
  object_key_value varchar2(1024) := null;
  bis_prefix varchar2(4) := 'bis';


BEGIN

bis_prefix := bis_prefix || '.';



  FOR i IN 1..p_param.count LOOP
         pname  := p_param(i).parameter_name;
         pvalue := p_param(i).parameter_value;

         if pname = 'BIS_LOG_MESSAGE' and upper(pvalue) <> 'ALL' then
            message := '%' || pvalue || '%';
         end if;

         if pname = 'BIS_ICX_SESSION_ID' then
            session_id_value := pvalue;
         end if;

         if pname = 'BIS_OBJECT_KEY' then
            object_key_value := bis_prefix || pvalue ||  '.%.TIME' ;
         end if;

  END LOOP;




l_sql_stmt := '
SELECT /*+ index(a , fnd_log_messages_u1) */
b.PROGRESS_NAME BIS_LOG_MODULE,
a.MESSAGE_TEXT BIS_LOG_MESSAGE_TEXT,
b.DURATION_TXT BIS_LOG_DURATION,
b.START_DATE_TXT BIS_LOG_START,
b.END_DATE_TXT BIS_LOG_END
FROM FND_LOG_MESSAGES a ,
    (SELECT /*+ ordered */
     max(timestamp)  over( partition by msg.session_id,module)   max_timestamp,
     max(log_sequence) over(partition by msg.session_id,module)   max_seq,
     min(timestamp)  over( partition by msg.session_id,module)   min_timestamp,
     min(log_sequence) over(partition by msg.session_id,module)   min_seq,
     msg.session_id,
     substr(MODULE, instr(MODULE, '''|| bis_prefix ||''') + 4 , instr(MODULE, ''.'', 1, 2 ) - instr(MODULE, '''|| bis_prefix ||''') - 4  ) OBJECT_KEY,
     substr(MODULE, instr(MODULE, '''|| bis_prefix ||''') + 4,  instr(MODULE, ''__'') - instr(MODULE, '''|| bis_prefix ||''') - 4  ) OBJECT_NAME,
     substr(MODULE, instr(MODULE, ''__'', 1, 2) + 2 , instr(MODULE, ''.'', -1, 2) - instr(MODULE, ''__'', 1, 2) -2 ) OBJECT_TYPE,
     substr(MODULE, instr(MODULE, ''.'', -1, 2) + 1, instr(MODULE, ''.'', -1, 1) - instr(MODULE, ''.'', -1, 2) -1 ) PROGRESS_NAME,
     substr(MESSAGE_TEXT, 1, instr(MESSAGE_TEXT,''#'', 1, 1) -1 ) START_DATE_TXT,
     substr(MESSAGE_TEXT, instr(MESSAGE_TEXT,''#'', 1, 1) + 1, instr(MESSAGE_TEXT,''#'', 1, 2) - instr(MESSAGE_TEXT,''#'', 1, 1) -1) END_DATE_TXT,
     substr(MESSAGE_TEXT, instr(MESSAGE_TEXT,''#'', 1, 2) + 1, length(MESSAGE_TEXT)) DURATION_TXT
     FROM FND_LOG_TRANSACTION_CONTEXT ctx, fnd_log_messages msg
         where msg.session_id = :BIS_ICX_SESSION_ID
         and msg.log_level = 6
         and msg.module like &BIS_OBJECT_KEY
         AND ctx.TRANSACTION_CONTEXT_ID = msg.TRANSACTION_CONTEXT_ID
         AND ctx.creation_date > sysdate - 0.5
         AND msg.session_id = ctx.session_id
         and ctx.session_id = :BIS_ICX_SESSION_ID
         and msg.timestamp between sysdate - 0.5 and sysdate
    ) b
where a.session_id = b.session_id
and b.START_DATE_TXT is not null
and b.max_seq >= a.log_sequence
and b.min_seq <= a.log_sequence
and b.max_timestamp >= a.timestamp
and b.min_timestamp <= a.timestamp
and a.module like '''|| bis_prefix ||'''||b.object_key||''.''|| b.PROGRESS_NAME ||''.%''
and substr(MODULE, instr(MODULE, ''.'', -1, 1) +1, length(MODULE) - instr(MODULE, ''.'', -1, 1) ) <> ''TIME''
and upper(a.message_text) like UPPER(:BIS_MSG_CRT)
&ORDER_BY_CLAUSE NULLS LAST';


  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := bis_query_attributes_tbl();
  x_custom_sql := l_sql_stmt;

  l_custom_rec.attribute_name := ':BIS_ICX_SESSION_ID';
  l_custom_rec.attribute_value := session_id_value;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.INTEGER_BIND;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':BIS_MSG_CRT';
  l_custom_rec.attribute_value := message;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

END GET_SQL ;
END; -- Package Body BIS_BIA_MSGLOG_PKG

/
