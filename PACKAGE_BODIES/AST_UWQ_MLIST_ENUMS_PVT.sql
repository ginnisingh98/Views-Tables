--------------------------------------------------------
--  DDL for Package Body AST_UWQ_MLIST_ENUMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AST_UWQ_MLIST_ENUMS_PVT" AS
/* $Header: ASTENMLB.pls 115.12 2004/08/10 06:40:59 rkumares ship $ */

-- Sub-Program Units

PROCEDURE ENUMERATE_MLIST_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  ) AS

  l_node_label VARCHAR2(200);
  l_ld_list  IEU_PUB.EnumeratorDataRecordList;

  l_node_counter           NUMBER;
  l_bind_list IEU_PUB.BindVariableRecordList ;

  l_Profile varchar2(10) ;
  l_Access  varchar2(10) ;

  CURSOR c_mlist_nodes(pResourceID number) IS
    SELECT distinct schedule_id, schedule_name, list_source_type
    FROM
      ast_mlist1_uwq_v
    WHERE
      resource_id = pResourceID
    ORDER BY 1;

  CURSOR c_mlist1_nodes IS
    SELECT schedule_id, schedule_name, list_source_type
    FROM
      ast_mlist1_all_uwq_v
    ORDER BY 1;

   lkp_type VARCHAR2(30) := 'AST_UWQ_LABELS';
   lkp_code VARCHAR2(30) := 'MLIST_WORK_CLASS_LABEL';

BEGIN

	/* label, view, and where for main node taken from enum table anyway */
	l_node_counter := 0;

	Select meaning into l_node_label
		from ast_lookups
		where lookup_type = lkp_type
		and lookup_code = lkp_code;

	l_Profile:=NVL(fnd_profile.value('AST_MLIST_ALL_CAMPAIGNS'),'N');
	l_Access:= NVL(fnd_profile.value('AS_CUST_ACCESS'), 'F');

	/* 'Y' - List All Campaign,  'N' - List only Assigned Campaign using Campaign Assignment  */
	if ( l_profile = 'Y' ) then

		-- Bug # 3595753
	  /* Added the where clause in such a manner that it will always be resulting
          in a true value, because the solution suggested by the base bug that by
	  changing the value of RES_CAT_ENUM_FLAG to 'N' will not look at the where clause
	  didn't help. So instead, changed the procedure to include the where clause. */

		l_bind_list(1).bind_var_name := ':DUMMY_VAR' ;
		l_bind_list(1).bind_var_value := 1 ;
		l_bind_list(1).bind_var_data_type := 'NUMBER' ;
		l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
		l_ld_list(l_node_counter).VIEW_NAME := 'AST_MLIST1_ALL_UWQ_V';
		l_ld_list(l_node_counter).DATA_SOURCE := 'AST_MLIST1_ALL_UWQ_DS';
		l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
		l_ld_list(l_node_counter).WHERE_CLAUSE := '1 = :DUMMY_VAR';
		l_ld_list(l_node_counter).NODE_TYPE := 0;
		l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
		l_ld_list(l_node_counter).NODE_DEPTH := 1;
		l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
		l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';
  		l_node_counter := l_node_counter + 1;

		SAVEPOINT start_mlist_enumeration;

		FOR cur_rec IN c_mlist1_nodes LOOP

			/* Need to check for security */
			if l_Access in ('F','P') then

				l_bind_list(1).bind_var_name := ':SCHEDULE_ID' ;
				l_bind_list(1).bind_var_value := cur_rec.schedule_id ;
				l_bind_list(1).bind_var_data_type := 'NUMBER' ;

				l_ld_list(l_node_counter).WHERE_CLAUSE := ' SCHEDULE_ID = :SCHEDULE_ID ';

				l_ld_list(l_node_counter).VIEW_NAME := 'AST_MLIST_ALL_UWQ_V';
				l_ld_list(l_node_counter).DATA_SOURCE := 'AST_MLIST_ALL_UWQ_DS';

			else

				l_bind_list(1).bind_var_name := ':SCHEDULE_ID' ;
				l_bind_list(1).bind_var_value := cur_rec.schedule_id ;
				l_bind_list(1).bind_var_data_type := 'NUMBER' ;

				l_bind_list(2).bind_var_name := ':RESOURCE_ID' ;
				l_bind_list(2).bind_var_value := P_RESOURCE_ID ;
				l_bind_list(2).bind_var_data_type := 'NUMBER' ;

				l_ld_list(l_node_counter).WHERE_CLAUSE :=
				--For perf bug 2829000

--					' RESOURCE_ID = :RESOURCE_ID and SCHEDULE_ID = :SCHEDULE_ID ';
					' SCHEDULE_ID = :SCHEDULE_ID AND ' ||
					' EXISTS (SELECT /*+ no_unnest */ 1 ' ||
					' FROM AS_ACCESSES_ALL ASS ' ||
					' WHERE ASS.SALESFORCE_ID = :RESOURCE_ID AND ' ||
					' CUSTOMER_ID = ASS.CUSTOMER_ID ) ';

                    if (cur_rec.list_source_type = 'ORGANIZATION_CONTACT_LIST') then

					l_ld_list(l_node_counter).VIEW_NAME := 'AST_MLIST_SECURE_UWQ_V';
					l_ld_list(l_node_counter).DATA_SOURCE := 'AST_MLIST_SECURE_UWQ_DS';

			     else
					l_ld_list(l_node_counter).DATA_SOURCE := 'AST_MLIST_ALLSECURE_UWQ_DS';
					l_ld_list(l_node_counter).VIEW_NAME := 'AST_MLIST_ALLSECURE_UWQ_V';

				end if;

			end if;

			l_ld_list(l_node_counter).NODE_LABEL := cur_rec.schedule_name;
			l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
			l_ld_list(l_node_counter).NODE_TYPE := 0;
			l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
			l_ld_list(l_node_counter).NODE_DEPTH := 2;

			l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
			l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';

			l_node_counter := l_node_counter + 1;
		END LOOP ;

	else
	     l_bind_list(1).bind_var_name := ':RESOURCE_ID' ;
		l_bind_list(1).bind_var_value := P_RESOURCE_ID ;
		l_bind_list(1).bind_var_data_type := 'NUMBER' ;

		l_ld_list(l_node_counter).NODE_LABEL := l_node_label;
		l_ld_list(l_node_counter).VIEW_NAME := 'AST_MLIST1_UWQ_V';
		l_ld_list(l_node_counter).DATA_SOURCE := 'AST_MLIST1_UWQ_DS';
		l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
		l_ld_list(l_node_counter).WHERE_CLAUSE := 'RESOURCE_ID = :RESOURCE_ID ';
		l_ld_list(l_node_counter).NODE_TYPE := 0;
		l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
		l_ld_list(l_node_counter).NODE_DEPTH := 1;
		l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
		l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';

		l_node_counter := l_node_counter + 1;

		SAVEPOINT start_mlist1_enumeration;
		FOR cur_rec IN c_mlist_nodes(p_Resource_ID) LOOP

			/* Need to check for security */
			if l_Access in ('F','P') then

				l_bind_list(1).bind_var_name := ':SCHEDULE_ID' ;
				l_bind_list(1).bind_var_value := cur_rec.schedule_id ;
				l_bind_list(1).bind_var_data_type := 'NUMBER' ;

				l_ld_list(l_node_counter).WHERE_CLAUSE := ' SCHEDULE_ID = :SCHEDULE_ID ';

				l_ld_list(l_node_counter).VIEW_NAME := 'AST_MLIST_UWQ_V';
				l_ld_list(l_node_counter).DATA_SOURCE := 'AST_MLIST_UWQ_DS';

			else

				l_bind_list(1).bind_var_name := ':SCHEDULE_ID' ;
				l_bind_list(1).bind_var_value := cur_rec.schedule_id ;
				l_bind_list(1).bind_var_data_type := 'NUMBER' ;

				l_bind_list(2).bind_var_name := ':RESOURCE_ID' ;
				l_bind_list(2).bind_var_value := P_RESOURCE_ID ;
				l_bind_list(2).bind_var_data_type := 'NUMBER' ;

				l_ld_list(l_node_counter).WHERE_CLAUSE :=
				--For perf bug 2829000

--					' RESOURCE_ID = :RESOURCE_ID and SCHEDULE_ID = :SCHEDULE_ID ';
					' SCHEDULE_ID = :SCHEDULE_ID AND ' ||
					' EXISTS (SELECT /*+ no_unnest */ 1 ' ||
					' FROM AS_ACCESSES_ALL ASS ' ||
					' WHERE ASS.SALESFORCE_ID = :RESOURCE_ID AND ' ||
					' CUSTOMER_ID = ASS.CUSTOMER_ID ) ';


                    if (cur_rec.list_source_type = 'ORGANIZATION_CONTACT_LIST') then

					l_ld_list(l_node_counter).VIEW_NAME := 'AST_MLIST_SECURE_UWQ_V';
					l_ld_list(l_node_counter).DATA_SOURCE := 'AST_MLIST_SECURE_UWQ_DS';
				else

					l_ld_list(l_node_counter).VIEW_NAME := 'AST_MLIST_ALLSECURE_UWQ_V';
					l_ld_list(l_node_counter).DATA_SOURCE := 'AST_MLIST_ALLSECURE_UWQ_DS';
				end if;

			end if;

			l_ld_list(l_node_counter).NODE_LABEL := cur_rec.schedule_name;
			l_ld_list(l_node_counter).MEDIA_TYPE_ID := '';
			l_ld_list(l_node_counter).NODE_TYPE := 0;
			l_ld_list(l_node_counter).HIDE_IF_EMPTY := '';
			l_ld_list(l_node_counter).NODE_DEPTH := 2;

			l_ld_list(l_node_counter).BIND_VARS := IEU_PUB.SET_BIND_VAR_DATA(l_bind_list) ;
			l_ld_list(l_node_counter).RES_CAT_ENUM_FLAG := 'N';

			l_node_counter := l_node_counter + 1;
		END LOOP ;


	END IF ;
	/* END 'Y' - List All Campaign */

--  END LOOP;

	IEU_PUB.ADD_UWQ_NODE_DATA
	(P_RESOURCE_ID,
	P_SEL_ENUM_ID,
	l_ld_list
	);


EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK TO start_mlist_enumeration;
		RAISE;

END ENUMERATE_MLIST_NODES;

-- PL/SQL Block
END AST_UWQ_MLIST_ENUMS_PVT;

/
