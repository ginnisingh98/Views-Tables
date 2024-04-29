--------------------------------------------------------
--  DDL for Package Body CCT_JTFRESOURCEROUTING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_JTFRESOURCEROUTING_PUB" as
/* $Header: cctjtfrb.pls 120.0 2005/06/02 10:02:41 appldev noship $ */

------------------------------------------------------------------------------
--  Function	: Get_Agents_for_Competency
--  Usage	: Used by the Routing module to get the agents assigned to
--		  a comp name and type.
--  Description	: This function retrieves a collection of agent IDs from
--		  the competency tables given a comp name and type.
--  Parameters	:
--      p_competency_type       IN      VARCHAR2        Required
--	p_competency_name	IN	VARCHAR2	Required
--	x_agent_tbl		 out nocopy 	CCT_ROUTINGWORKFLOW_UTL.agent_tbl_type
--
--  Return	: NUMBER
--		  This function returns the number of agents assigned to
--		  the given competency_name (0 if there is no agent assigned
--		  to the competency_name).
------------------------------------------------------------------------------
FUNCTION Get_Agents_For_Competency (
	p_competency_type       IN      VARCHAR2
	, p_competency_name	IN	VARCHAR2
	, x_agent_tbl		 out nocopy 	CCT_ROUTINGWORKFLOW_UTL.agent_tbl_type
)
RETURN NUMBER IS

    v_total_num_of_emps    NUMBER:=0;
    v_agent_id           JTF_RS_RESOURCE_EXTNS.SOURCE_ID%type;

    --
    -- get a list of employees that is responsible for a given comp name andy type
    --  Changed 06FRB2002
    CURSOR c_employees IS
      SELECT distinct res.resource_id
      FROM   jtf_rs_resource_extns res,
		   jtf_rs_role_relations res_roles,
		   jtf_rs_roles_b roles
      where  res.resource_id in
      ((SELECT DISTINCT comp_ele.person_id
      FROM per_competence_elements comp_ele,
           per_competences comp
      WHERE (upper(comp_ele.competence_type) = upper(p_competency_type) and
	     upper(comp.name) = upper(p_competency_name) and
		comp.competence_id = comp_ele.competence_id)))
      and res.resource_id=res_roles.role_resource_id
	 and res_roles.role_id=roles.role_id
	 and (roles.role_type_code='CALLCENTER'
	 or roles.role_type_code='ICENTER');

BEGIN

    OPEN c_employees;
    LOOP

      FETCH c_employees INTO v_agent_id;
	 --dbms_output.put_line('Employee Id from query is'||to_char(v_agent_id));
      IF c_employees%NOTFOUND THEN
         CLOSE c_employees;
         return v_total_num_of_emps;
      ELSE
         x_agent_tbl(v_total_num_of_emps) := v_agent_id;
      END IF;
      v_total_num_of_emps := v_total_num_of_emps + 1;

    END LOOP;
  END Get_Agents_For_Competency;




 FUNCTION  Get_agents_from_stat_grp_nam (
        p_group_name        IN VARCHAR2
        ,p_agent_tbl		 out nocopy 	CCT_ROUTINGWORKFLOW_UTL.agent_tbl_type
   )
 RETURN number IS

    l_total_num_of_agents    NUMBER:=0;
    l_group_id               jtf_rs_groups_vl.group_id%TYPE;
    l_agent_id               cct_agent_rt_stats.agent_id%TYPE;



    CURSOR csr_agents IS
       SELECT resource_id
       FROM jtf_rs_group_members
       WHERE delete_flag='N'
       AND group_id = (  SELECT distinct a.group_id
                        FROM jtf_rs_groups_vl a,
                             jtf_rs_group_usages_vl b
                        WHERE b.usage='CALL'
                        AND b.group_ID=a.group_ID
                        AND a.start_date_active<=sysdate
                        AND nvl(a.end_date_active,sysdate)>=sysdate
                        AND upper(a.group_name) = upper(p_group_name));




BEGIN
     --dbms_output.put_line ('IN GET LOGGED IN AGENTS');
          OPEN csr_agents;
          LOOP
            FETCH csr_agents into l_agent_id;
            IF csr_agents%NOTFOUND THEN
              CLOSE csr_agents;
              RETURN l_total_num_of_agents;
            ELSE
               l_total_num_of_agents := l_total_num_of_agents +1;
               p_agent_tbl(l_total_num_of_agents) :=  l_agent_id;
            END IF;
          END LOOP;


 EXCEPTION
	WHEN OTHERS THEN
    CLOSE csr_agents;
    --dbms_output.put_line(' ERROR in Get_logged In Agents '||sqlerrm );

 END Get_agents_from_stat_grp_nam;

 FUNCTION  Get_agents_from_stat_grp_num (
        p_group_number      IN  VARCHAR2
        ,p_agent_tbl		 out nocopy 	CCT_ROUTINGWORKFLOW_UTL.agent_tbl_type
   )
 RETURN number IS

    l_total_num_of_agents    NUMBER:=0;
    l_agent_id               cct_agent_rt_stats.agent_id%TYPE;
    l_group_id               jtf_rs_groups_vl.group_id%TYPE;


    CURSOR csr_agents IS
       SELECT resource_id
       FROM jtf_rs_group_members
       WHERE delete_flag='N'
       AND group_id= ( SELECT  a.group_id
                       FROM jtf_rs_groups_vl a,
                            jtf_rs_group_usages_vl b
                       WHERE b.usage='CALL'
                       AND b.group_ID=a.group_ID
                       AND a.start_date_active<=sysdate
                       AND nvl(a.end_date_active,sysdate)>=sysdate
                       AND a.group_number = p_group_number);

BEGIN

     --dbms_output.put_line ('IN GET LOGGED IN AGENTS');

        OPEN csr_agents;
        LOOP
          FETCH csr_agents into l_agent_id;
          IF csr_agents%NOTFOUND THEN
             CLOSE csr_agents;
             RETURN l_total_num_of_agents;
          ELSE
            l_total_num_of_agents := l_total_num_of_agents +1;
            p_agent_tbl(l_total_num_of_agents) :=  l_agent_id;
          END IF;

        END LOOP;

 EXCEPTION
	WHEN OTHERS THEN
    CLOSE csr_agents;
    --dbms_output.put_line(' ERROR in Get_logged In Agents '||sqlerrm );

 END Get_agents_from_stat_grp_num;

FUNCTION  Get_agents_from_dyn_grp_nam (
         p_group_name       IN VARCHAR2
         ,p_agent_tbl		 out nocopy 	CCT_ROUTINGWORKFLOW_UTL.agent_tbl_type
   )
 RETURN number IS
    l_total_num_of_agents    NUMBER:=0;
    l_text                   jtf_rs_dynamic_groups_b.sql_text%TYPE;
    l_agent_id               cct_agent_rt_stats.agent_id%TYPE;
    l_select_csr             INTEGER;
    l_sort_num               NUMBER := 0;
    l_dummy                  INTEGER;

    CURSOR csr_text IS
       SELECT a.sql_text
       FROM JTF_RS_DYNAMIC_GROUPS_vl a
       WHERE upper(a.usage)='CALL'
       AND a.start_date_active<=sysdate
       AND nvl(a.end_date_active,sysdate)>=sysdate
       AND a.group_name = p_group_name
       AND sql_text is not null;


BEGIN
    OPEN csr_text;
    FETCH csr_text into l_text;
      IF csr_text%NOTFOUND THEN
         CLOSE csr_text;
      END IF;

      BEGIN
        l_select_csr := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(l_select_csr, l_text, DBMS_SQL.native);
        DBMS_SQL.DEFINE_COLUMN(l_select_csr, 1, l_agent_ID);
        l_dummy := DBMS_SQL.EXECUTE(l_select_csr);

        l_sort_num  := 0;
        LOOP
          IF DBMS_SQL.FETCH_ROWS(l_select_csr) = 0 THEN
	        EXIT;
          END IF;

          DBMS_SQL.COLUMN_VALUE(l_select_csr, 1, l_agent_ID);

          -- insert the cursor record into the l_agents_tbl Table
          l_sort_num := l_sort_num + 1;
          p_agent_tbl(l_sort_num) :=  l_agent_id;
        END LOOP;
        -- Close the cursor
        DBMS_SQL.CLOSE_CURSOR(l_select_csr);
      END;
      RETURN l_sort_num;
 EXCEPTION
	WHEN OTHERS THEN
        CLOSE csr_text;
        RETURN 0;
 END Get_agents_from_dyn_grp_nam;

FUNCTION  Get_agents_from_dyn_grp_num (
         p_group_number     IN VARCHAR2
         ,p_agent_tbl		 out nocopy 	CCT_ROUTINGWORKFLOW_UTL.agent_tbl_type
   )
 RETURN number IS
    l_total_num_of_agents    NUMBER:=0;
    l_text                   jtf_rs_dynamic_groups_b.sql_text%TYPE;
    l_dummy                  INTEGER;
    l_agent_id               cct_agent_rt_stats.agent_id%TYPE;
    l_sort_num           NUMBER := 0;

    l_select_csr         INTEGER;

    CURSOR csr_text IS
       SELECT a.sql_text
       FROM JTF_RS_DYNAMIC_GROUPS_B a
       WHERE upper(a.usage)='CALL'
       AND a.start_date_active<=sysdate
       AND nvl(a.end_date_active,sysdate)>=sysdate
       AND a.group_number = p_group_number
       AND sql_text is not null;


BEGIN
    OPEN csr_text;
    FETCH csr_text into l_text;
    IF csr_text%NOTFOUND THEN
      CLOSE csr_text;
    END IF;

       BEGIN
        l_select_csr := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(l_select_csr, l_text, DBMS_SQL.native);
        DBMS_SQL.DEFINE_COLUMN(l_select_csr, 1, l_agent_ID);
        l_dummy := DBMS_SQL.EXECUTE(l_select_csr);

        l_sort_num  := 0;
        LOOP
          IF DBMS_SQL.FETCH_ROWS(l_select_csr) = 0 THEN
	        EXIT;
          END IF;

          DBMS_SQL.COLUMN_VALUE(l_select_csr, 1, l_agent_ID);

          -- insert the cursor record into the l_agents_tbl Table
          l_sort_num := l_sort_num + 1;
          p_agent_tbl(l_sort_num) :=  l_agent_id;
        END LOOP;
        -- Close the cursor
        DBMS_SQL.CLOSE_CURSOR(l_select_csr);
       END;

       RETURN l_sort_num;
 EXCEPTION
	WHEN OTHERS THEN
       CLOSE csr_text;
       RETURN 0;
 END Get_agents_from_dyn_grp_num;

 FUNCTION  Get_agents_not_in_stat_grp_nam (
         p_group_name       IN VARCHAR2
         ,p_agent_tbl		 out nocopy 	CCT_ROUTINGWORKFLOW_UTL.agent_tbl_type
   )
 RETURN number IS
    l_total_num_of_agents    NUMBER:=0;
    l_agent_id               cct_agent_rt_stats.agent_id%TYPE;


    CURSOR csr_agents IS
    select  res.resource_id
        from jtf_rs_resource_extns res
            ,jtf_rs_role_relations res_roles
                ,jtf_rs_roles_b roles
        where  res.resource_id = res_roles.role_resource_id
            and res_roles.role_resource_type = 'RS_INDIVIDUAL'
            and res_roles.start_date_active<=sysdate
            and nvl(res_roles.end_date_active,sysdate)>=sysdate
            and res_roles.delete_flag = 'N'
            and res_roles.role_id=roles.role_id
            and (roles.role_type_code = 'CALLCENTER'
            or roles.role_type_code='ICENTER')
        MINUS
        select resource_id
        from jtf_rs_group_members
        where delete_flag='N'
        and group_id =  ( select a.group_id
                       from jtf_rs_groups_vl a,
                            jtf_rs_group_usages b
                       where upper(a.group_name) = upper(p_group_name)
                       and b.usage='CALL'
                       and b.group_ID=a.group_ID
                       and a.start_date_active<=sysdate
                       and nvl(a.end_date_active,sysdate)>=sysdate );
      -- Changed 09/12/02 rajayara
      --SELECT distinct res.resource_id
      --  FROM jtf_rs_resource_extns res
      --      ,jtf_rs_role_relations res_roles
      --        ,jtf_rs_roles_b roles
      --  WHERE  res.resource_id = res_roles.role_resource_id
      --    and res_roles.role_id=roles.role_id
      --    and (roles.role_type_code = 'CALLCENTER'
      --    or roles.role_type_code='ICENTER')
      --  MINUS
      --    SELECT resource_id
      --    FROM jtf_rs_group_members
      --    WHERE delete_flag='N'
      --    AND group_id= (  SELECT distinct a.group_id
      --                     FROM jtf_rs_groups_vl a,
      --                             jtf_rs_group_usages_vl b
      --                        WHERE b.usage='CALL'
      --                        AND b.group_ID=a.group_ID
      --                        AND a.start_date_active<=sysdate
      --                        AND nvl(a.end_date_active,sysdate)>=sysdate
      --                        AND upper(a.group_name) = upper(p_group_name));


BEGIN
    OPEN csr_agents;
    LOOP
      FETCH csr_agents into l_agent_id;
      IF csr_agents%NOTFOUND THEN
         CLOSE csr_agents;
         RETURN l_total_num_of_agents;
      ELSE
      p_agent_tbl(l_total_num_of_agents) :=  l_agent_id;
      END IF;

      l_total_num_of_agents := l_total_num_of_agents + 1;
    END LOOP;

EXCEPTION
	WHEN OTHERS THEN
       CLOSE csr_agents;
       RETURN 0;
END Get_agents_not_in_stat_grp_nam;

FUNCTION  Get_agents_not_in_stat_grp_num (
        p_group_number      IN VARCHAR2
        ,p_agent_tbl		 out nocopy 	CCT_ROUTINGWORKFLOW_UTL.agent_tbl_type
   )
 RETURN number IS
    l_total_num_of_agents    NUMBER:=0;
    l_agent_id           cct_agent_rt_stats.agent_id%TYPE;


    CURSOR csr_agents IS
    select  res.resource_id
        from jtf_rs_resource_extns res
            ,jtf_rs_role_relations res_roles
                ,jtf_rs_roles_b roles
        where  res.resource_id = res_roles.role_resource_id
            and res_roles.role_resource_type = 'RS_INDIVIDUAL'
            and res_roles.start_date_active<=sysdate
            and nvl(res_roles.end_date_active,sysdate)>=sysdate
            and res_roles.delete_flag = 'N'
            and res_roles.role_id=roles.role_id
            and (roles.role_type_code = 'CALLCENTER'
            or roles.role_type_code='ICENTER')
        MINUS
        select resource_id
        from jtf_rs_group_members
        where delete_flag='N'
        and group_id =  ( select a.group_id
                       from jtf_rs_groups_b a,
                            jtf_rs_group_usages b
                       where a.group_number = p_group_number
                       and b.usage='CALL'
                       and b.group_ID=a.group_ID
                       and a.start_date_active<=sysdate
                       and nvl(a.end_date_active,sysdate)>=sysdate );

        -- Changed 09/12/02 rajayara
        -- SELECT distinct res.resource_id
        -- FROM jtf_rs_resource_extns res
        --  ,jtf_rs_role_relations res_roles
        --  ,jtf_rs_roles_b roles
        -- WHERE  res.resource_id = res_roles.role_resource_id
	--    and res_roles.role_id=roles.role_id
	--    and (roles.role_type_code = 'CALLCENTER'
	--    or roles.role_type_code='ICENTER')
        -- MINUS
        --  SELECT resource_id
        --  FROM jtf_rs_group_members
        --  WHERE delete_flag='N'
        --  AND group_id =  ( SELECT a.group_id
        --               FROM jtf_rs_groups_vl a,
        --                    jtf_rs_group_usages_vl b
        --              WHERE b.usage='CALL'
        --               AND b.group_ID=a.group_ID
        --               AND a.start_date_active<=sysdate
        --               AND nvl(a.end_date_active,sysdate)>=sysdate
        --              AND a.group_number = p_group_number);


BEGIN
    OPEN csr_agents;
    LOOP
      FETCH csr_agents into l_agent_id;
      IF csr_agents%NOTFOUND THEN
         CLOSE csr_agents;
         RETURN l_total_num_of_agents;
      ELSE
      p_agent_tbl(l_total_num_of_agents) :=  l_agent_id;
      END IF;

      l_total_num_of_agents := l_total_num_of_agents + 1;
    END LOOP;

 EXCEPTION
	WHEN OTHERS THEN
       CLOSE csr_agents;
       RETURN 0;
 END Get_agents_not_in_stat_grp_num;


FUNCTION  Get_agents_not_in_dyn_grp_nam (
        p_group_name        IN VARCHAR2
        ,p_agent_tbl		 out nocopy 	CCT_ROUTINGWORKFLOW_UTL.agent_tbl_type
   )
 RETURN number IS
    l_agent_id               cct_agent_rt_stats.agent_id%TYPE;
    l_default_select         VARCHAR2(4000);
    l_apos			         VARCHAR2(4) := '''';
    l_query                  VARCHAR2(5000);
    l_text                   jtf_rs_dynamic_groups_b.sql_text%TYPE;
    l_select_csr             INTEGER;
    l_dummy              INTEGER;
    l_sort_num               NUMBER := 0;

    CURSOR csr_text IS
       SELECT a.sql_text
       FROM JTF_RS_DYNAMIC_GROUPS_vl a
       WHERE upper(a.usage)='CALL'
       AND a.start_date_active<=sysdate
       AND nvl(a.end_date_active,sysdate)>=sysdate
       AND upper(a.group_name) = upper(p_group_name)
       AND sql_text is not null;


 BEGIN
     OPEN csr_text;
     FETCH csr_text into l_text;
     IF csr_text%NOTFOUND THEN
       CLOSE csr_text;
     END IF;

      l_default_select :=
        'SELECT distinct res.resource_id '||
        'FROM jtf_rs_resource_extns res '||
         '   ,jtf_rs_role_relations res_roles '||
	     '   ,jtf_rs_roles_b roles '||
        'WHERE  res.resource_id = res_roles.role_resource_id '||
	    'and res_roles.role_id=roles.role_id '||
	    'and (roles.role_type_code = '||l_apos|| 'CALLCENTER' ||l_apos||
	    'or roles.role_type_code='||l_apos||'ICENTER'||l_apos||
        ' MINUS  ' ;
     l_query := l_default_select || l_text ;
     --dbms_output.put_line ('l_dyn_select'|| l_query);

       BEGIN
        l_select_csr := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(l_select_csr, l_query, DBMS_SQL.native);
        DBMS_SQL.DEFINE_COLUMN(l_select_csr, 1, l_agent_ID);
        l_dummy := DBMS_SQL.EXECUTE(l_select_csr);

        l_sort_num  := 0;
        LOOP
          IF DBMS_SQL.FETCH_ROWS(l_select_csr) = 0 THEN
	        EXIT;
          END IF;

          DBMS_SQL.COLUMN_VALUE(l_select_csr, 1, l_agent_ID);

          -- insert the cursor record into the l_agents_tbl Table
          l_sort_num := l_sort_num + 1;
          p_agent_tbl(l_sort_num) :=  l_agent_id;
        END LOOP;
        -- Close the cursor
        DBMS_SQL.CLOSE_CURSOR(l_select_csr);
       END;

       RETURN l_sort_num;

 EXCEPTION
	WHEN OTHERS THEN
       CLOSE csr_text;
       RETURN 0;
 END Get_agents_not_in_dyn_grp_nam;

FUNCTION  Get_agents_not_in_dyn_grp_num (
        p_group_number      IN VARCHAR2
        ,p_agent_tbl		 out nocopy 	CCT_ROUTINGWORKFLOW_UTL.agent_tbl_type
   )
 RETURN number IS

    l_agent_id               cct_agent_rt_stats.agent_id%TYPE;
    l_default_select         VARCHAR2(4000);
    l_apos			         VARCHAR2(4) := '''';
    l_query                  VARCHAR2(5000);
    l_text                   jtf_rs_dynamic_groups_b.sql_text%TYPE;
    l_select_csr             INTEGER;
    l_dummy              INTEGER;
    l_sort_num               NUMBER := 0;

    CURSOR csr_text IS
       SELECT a.sql_text
       FROM JTF_RS_DYNAMIC_GROUPS_vl a
       WHERE upper(a.usage)='CALL'
       AND a.start_date_active<=sysdate
       AND nvl(a.end_date_active,sysdate)>=sysdate
       AND a.group_number = p_group_number
       AND sql_text is not null;


BEGIN
     OPEN csr_text;
     FETCH csr_text into l_text;
     IF csr_text%NOTFOUND THEN
       CLOSE csr_text;
     END IF;

      l_default_select :=
        'SELECT distinct res.resource_id '||
        'FROM jtf_rs_resource_extns res '||
         '   ,jtf_rs_role_relations res_roles '||
	     '   ,jtf_rs_roles_b roles '||
        'WHERE  res.resource_id = res_roles.role_resource_id '||
	    'and res_roles.role_id=roles.role_id '||
	    'and (roles.role_type_code = '||l_apos|| 'CALLCENTER' ||l_apos||
	    'or roles.role_type_code='||l_apos||'ICENTER'||l_apos||
        ' MINUS  ' ;
     l_query := l_default_select || l_text ;


       BEGIN
        l_select_csr := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(l_select_csr, l_query, DBMS_SQL.native);
        DBMS_SQL.DEFINE_COLUMN(l_select_csr, 1, l_agent_ID);
        l_dummy := DBMS_SQL.EXECUTE(l_select_csr);

        l_sort_num  := 0;
        LOOP
          IF DBMS_SQL.FETCH_ROWS(l_select_csr) = 0 THEN
	        EXIT;
          END IF;

          DBMS_SQL.COLUMN_VALUE(l_select_csr, 1, l_agent_ID);

          -- insert the cursor record into the l_agents_tbl Table
          l_sort_num := l_sort_num + 1;
          p_agent_tbl(l_sort_num) :=  l_agent_id;
        END LOOP;
        -- Close the cursor
        DBMS_SQL.CLOSE_CURSOR(l_select_csr);
       END;

       RETURN l_sort_num;


 EXCEPTION
	WHEN OTHERS THEN
      CLOSE csr_text;
      RETURN 0;
 END Get_agents_not_in_dyn_grp_num;

END CCT_JTFRESOURCEROUTING_PUB;

/
