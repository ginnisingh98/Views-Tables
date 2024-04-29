--------------------------------------------------------
--  DDL for Package Body CRP_FORM_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CRP_FORM_PK" AS
     /* $Header: CRPSELEB.pls 115.2 2002/06/15 00:42:14 pkm ship      $ */

   /*----------crp_selection_criteria------------*/
    PROCEDURE crp_selection_criteria(
                                   arg_query_id        NUMBER,
                                   arg_type            NUMBER,
                                   arg_org_id          NUMBER,
                                   arg_owning_dept_id  NUMBER DEFAULT NULL,
                                   arg_dept_id         NUMBER DEFAULT NULL,
                                   arg_res_id          NUMBER DEFAULT NULL,
                                   arg_line_id         NUMBER DEFAULT NULL,
                                   arg_res_type        NUMBER DEFAULT NULL,
                                   arg_dept_class      VARCHAR2 DEFAULT NULL,
                                   arg_res_grp         VARCHAR2 DEFAULT NULL) IS
   BEGIN

       IF (arg_query_id IS NULL OR
           arg_type IS NULL OR
           arg_org_id IS NULL) THEN
           RAISE insufficient_args;
       END IF;

       /*==================================
         Column mapping as follows
         char1          Owning department
         char2          Using department
         char3          Resource
         char4          Department Class
         char5          Line
         char6          Line description
         char7          Org code
         char8          Resource Type meaning
         char9          Resource Group
         number1        Owning department id
         number2        Using department id
         number3        Resource id
         number4        Resource Type id
         number5        Line id
         number6        Org id
         number7        Max Util % for
                        RESOURCE_DISCRETE canvass
         number8        Min Util % for
                        RESOURCE_DISCRETE canvass
         number9        Max Rate for line
         number10       Min Rate for line
         number11       Max Util % for
                        RESOURCE_LINE canvass
         number12       Min Util % for
                        RESOURCE_LINE canvass
         number13       Selection checkbox
                        1 - Checked (yes)
                        2 - unchecked (no)
         ==================================*/
       IF (arg_type = RATE_BASED) THEN
           INSERT INTO crp_form_query
                   (query_id,
                   last_update_date,
                   last_updated_by,
                   last_update_login,
                   creation_date,
                   created_by,
                   char5,
                   char6,
                   char7,
                   number5,
                   number9,
                   number10,
                   number13)
           SELECT
                   arg_query_id,
                   SYSDATE,
                   -1,
                   -1,
                   SYSDATE,
                   -1,
                   wl.line_code,
                   wl.description,
                   mtl.organization_code,
                   wl.line_id,
                   wl.maximum_rate,
                   wl.minimum_rate,
                   2
           FROM    mtl_parameters mtl,
                   wip_lines wl
           WHERE   NVL(disable_date, SYSDATE+1) > SYSDATE
           AND     mtl.organization_id = wl.organization_id
           AND     (arg_line_id is NULL OR
                       wl.line_id = arg_line_id)
           AND     wl.organization_id = arg_org_id;

       ELSE
           INSERT INTO crp_form_query
                   (query_id,
                   last_update_date,
                   last_updated_by,
                   last_update_login,
                   creation_date,
                   created_by,
                   char1,
                   char2,
                   char3,
                   char4,
                   char7,
                   char8,
                   char9,
                   number1,
                   number2,
                   number3,
                   number4,
                   number13
                   )
           SELECT
                   arg_query_id,
                   SYSDATE,
                   -1,
                   -1,
                   SYSDATE,
                   -1,
                   depts2.department_code,
                   depts1.department_code,
                   resources.resource_code,
                   depts1.department_class_code,
                   mtl.organization_code,
                   lkps.meaning,
                   dept_res.resource_group_name,
                   depts2.department_id,
                   depts1.department_id,
                   resources.resource_id,
                   resources.resource_type,
                   2
           FROM    mtl_parameters mtl,
                   mfg_lookups lkps,
                   bom_departments depts2,
                   bom_department_resources dept_res,
                   bom_resources resources,
                   bom_departments depts1
           WHERE   resources.resource_id = dept_res.resource_id
           AND     resources.organization_id = depts1.organization_id
           AND     dept_res.department_id = depts1.department_id
           AND     depts2.department_id =
                       nvl(dept_res.share_from_dept_id, dept_res.department_id)
           AND     depts2.organization_id = depts1.organization_id
           AND     depts1.organization_id = arg_org_id
           AND     mtl.organization_id = arg_org_id
           AND     lkps.lookup_code = resources.resource_type
           AND     lkps.lookup_type = 'BOM_RESOURCE_TYPE'
           AND     (arg_dept_class is NULL OR
                       depts1.department_class_code = arg_dept_class)
           AND     (arg_owning_dept_id is NULL OR
                       depts2.department_id = arg_owning_dept_id)
           AND     (arg_dept_id is NULL OR
                       depts1.department_id = arg_dept_id)
           AND     (arg_res_id is NULL OR
                        resources.resource_id = arg_res_id)
           AND     (arg_res_grp is NULL OR
                        dept_res.resource_group_name = arg_res_grp)
           AND     (arg_res_type is NULL OR
                       resources.resource_type = arg_res_type);

       END IF;

       EXCEPTION
           WHEN insufficient_args THEN
                RAISE insufficient_args;

   END crp_selection_criteria;


PROCEDURE crp_update_util(
                            arg_query_id1       NUMBER,
                            arg_query_id2       NUMBER,
                            arg_line_capacity   NUMBER) IS
    BEGIN
        if arg_line_capacity = 2 then
            update  crp_form_query query
            set     (number11, number12) =
                (select ROUND(greatest(NVL(PERIOD1,-1),
                            greatest(NVL(PERIOD2,-1),
                            greatest(NVL(PERIOD3,-1),
                            greatest(NVL(PERIOD4,-1),
                            greatest(NVL(PERIOD5,-1),
                            greatest(NVL(PERIOD6,-1),
                            greatest(NVL(PERIOD7,-1),
                            greatest(NVL(PERIOD8,-1),
                            greatest(NVL(PERIOD9,-1),
                            greatest(NVL(PERIOD10,-1),
                            greatest(NVL(PERIOD11,-1),
                            greatest(NVL(PERIOD12,-1),
                            greatest(NVL(PERIOD13,-1),
                            greatest(NVL(PERIOD14,-1),
                            greatest(NVL(PERIOD15,-1),
                            greatest(NVL(PERIOD16,-1),
                            greatest(NVL(PERIOD17,-1),
                            greatest(NVL(PERIOD18,-1))))))))))))))))))),2),
                        ROUND(least(NVL(PERIOD1,100000000),
                            least(NVL(PERIOD2, 100000000),
                            least(NVL(PERIOD3,100000000),
                            least(NVL(PERIOD4,100000000),
                            least(NVL(PERIOD5,100000000),
                            least(NVL(PERIOD6,100000000),
                            least(NVL(PERIOD7,100000000),
                            least(NVL(PERIOD8,100000000),
                            least(NVL(PERIOD9,100000000),
                            least(NVL(PERIOD10,100000000),
                            least(NVL(PERIOD11,100000000),
                            least(NVL(PERIOD12,100000000),
                            least(NVL(PERIOD13,100000000),
                            least(NVL(PERIOD14,100000000),
                            least(NVL(PERIOD15,100000000),
                            least(NVL(PERIOD16,100000000),
                            least(NVL(PERIOD17,100000000),
                            least(NVL(PERIOD18,100000000))))))))))))))))))), 2)
                from    crp_capacity_plans cap
                where   cap.type_id = 5
                and     cap.line_id = query.number5
                and     cap.query_id = arg_query_id1)
            where   query_id = arg_query_id2
            and     number5 is not null;
        /*----------------------------------------------------------------+
         |  THis statement has been intentionally split to avoid a PL/SQL |
         |  parser stack overflow                                         |
         +----------------------------------------------------------------*/

            update  crp_form_query  query
            set     (number11, number12) =
                    (select         ROUND(greatest(NVL(query.number11,-1),
                                greatest(NVL(PERIOD19,-1),
                                greatest(NVL(PERIOD20,-1),
                                greatest(NVL(PERIOD21,-1),
                                greatest(NVL(PERIOD22,-1),
                                greatest(NVL(PERIOD23,-1),
                                greatest(NVL(PERIOD24,-1),
                                greatest(NVL(PERIOD25,-1),
                                greatest(NVL(PERIOD26,-1),
                                greatest(NVL(PERIOD27,-1),
                                greatest(NVL(PERIOD28,-1),
                                greatest(NVL(PERIOD29,-1),
                                greatest(NVL(PERIOD30,-1),
                                greatest(NVL(PERIOD31,-1),
                                greatest(NVL(PERIOD32,-1),
                                greatest(NVL(PERIOD33,-1),
                                greatest(NVL(PERIOD34,-1),
                                greatest(NVL(PERIOD35,-1),
                                NVL(PERIOD36,-1))))))))))))))))))), 2),
                            ROUND(least(NVL(query.number12, 100000000),
                                least(NVL(PERIOD18,100000000),
                                least(NVL(PERIOD19,100000000),
                                least(NVL(PERIOD20,100000000),
                                least(NVL(PERIOD21,100000000),
                                least(NVL(PERIOD22,100000000),
                                least(NVL(PERIOD23,100000000),
                                least(NVL(PERIOD24,100000000),
                                least(NVL(PERIOD25,100000000),
                                least(NVL(PERIOD26,100000000),
                                least(NVL(PERIOD27,100000000),
                                least(NVL(PERIOD28,100000000),
                                least(NVL(PERIOD29,100000000),
                                least(NVL(PERIOD30,100000000),
                                least(NVL(PERIOD31,100000000),
                                least(NVL(PERIOD32,100000000),
                                least(NVL(PERIOD33,100000000),
                                least(NVL(PERIOD34,100000000),
                                least(NVL(PERIOD35,100000000),
                                NVL(PERIOD36, 100000000)))))))))))))))))))), 2)
                    from    crp_capacity_plans cap
                    where   cap.type_id = 5
                    and     cap.line_id = query.number5
                    and     cap.query_id = arg_query_id1)
            where   query_id = arg_query_id2
            and     number5 is not null;

            update  crp_form_query
            set     number11 = NULL
            where   query_id = arg_query_id2
                        and     number11 = -1
            and number5 is not null;

                        update crp_form_query
                        set     number12 = NULL
                        where   query_id = arg_query_id2
                        and     number12 = 100000000
                        and     number5 is not null;

        else
            update  crp_form_query query
            set     (number7, number8) =
                (select ROUND(greatest(NVL(PERIOD1,-1),
                            greatest(NVL(PERIOD2,-1),
                            greatest(NVL(PERIOD3,-1),
                            greatest(NVL(PERIOD4,-1),
                            greatest(NVL(PERIOD5,-1),
                            greatest(NVL(PERIOD6,-1),
                            greatest(NVL(PERIOD7,-1),
                            greatest(NVL(PERIOD8,-1),
                            greatest(NVL(PERIOD9,-1),
                            greatest(NVL(PERIOD10,-1),
                            greatest(NVL(PERIOD11,-1),
                            greatest(NVL(PERIOD12,-1),
                            greatest(NVL(PERIOD13,-1),
                            greatest(NVL(PERIOD14,-1),
                            greatest(NVL(PERIOD15,-1),
                            greatest(NVL(PERIOD16,-1),
                            greatest(NVL(PERIOD17,-1),
                            greatest(NVL(PERIOD18,-1))))))))))))))))))), 2),
                        ROUND(least(NVL(PERIOD1,100000000),
                            least(NVL(PERIOD2, 100000000),
                            least(NVL(PERIOD3,100000000),
                            least(NVL(PERIOD4,100000000),
                            least(NVL(PERIOD5,100000000),
                            least(NVL(PERIOD6,100000000),
                            least(NVL(PERIOD7,100000000),
                            least(NVL(PERIOD8,100000000),
                            least(NVL(PERIOD9,100000000),
                            least(NVL(PERIOD10,100000000),
                            least(NVL(PERIOD11,100000000),
                            least(NVL(PERIOD12,100000000),
                            least(NVL(PERIOD13,100000000),
                            least(NVL(PERIOD14,100000000),
                            least(NVL(PERIOD15,100000000),
                            least(NVL(PERIOD16,100000000),
                            least(NVL(PERIOD17,100000000),
                            least(NVL(PERIOD18,100000000))))))))))))))))))), 2)
                from    crp_capacity_plans cap
                where   cap.type_id = 5
                and     cap.resource_id = query.number3
                and     cap.department_id = query.number2
                and     cap.query_id = arg_query_id1)
            where   query_id = arg_query_id2
            and     number5 is null;


            update  crp_form_query query
            set     (number7, number8) =
                (select ROUND(greatest(NVL(query.number7, 0),
                            greatest(NVL(PERIOD19,-1),
                            greatest(NVL(PERIOD20,-1),
                            greatest(NVL(PERIOD21,-1),
                            greatest(NVL(PERIOD22,-1),
                            greatest(NVL(PERIOD23,-1),
                            greatest(NVL(PERIOD24,-1),
                            greatest(NVL(PERIOD25,-1),
                            greatest(NVL(PERIOD26,-1),
                            greatest(NVL(PERIOD27,-1),
                            greatest(NVL(PERIOD28,-1),
                            greatest(NVL(PERIOD29,-1),
                            greatest(NVL(PERIOD30,-1),
                            greatest(NVL(PERIOD31,-1),
                            greatest(NVL(PERIOD32,-1),
                            greatest(NVL(PERIOD33,-1),
                            greatest(NVL(PERIOD34,-1),
                            greatest(NVL(PERIOD35,-1),
                            NVL(PERIOD36,-1))))))))))))))))))),2),
                        ROUND(least(NVL(query.number8, 100000000),
                            least(NVL(PERIOD19,100000000),
                            least(NVL(PERIOD20,100000000),
                            least(NVL(PERIOD21,100000000),
                            least(NVL(PERIOD22,100000000),
                            least(NVL(PERIOD23,100000000),
                            least(NVL(PERIOD24,100000000),
                            least(NVL(PERIOD25,100000000),
                            least(NVL(PERIOD26,100000000),
                            least(NVL(PERIOD27,100000000),
                            least(NVL(PERIOD28,100000000),
                            least(NVL(PERIOD29,100000000),
                            least(NVL(PERIOD30,100000000),
                            least(NVL(PERIOD31,100000000),
                            least(NVL(PERIOD32,100000000),
                            least(NVL(PERIOD33,100000000),
                            least(NVL(PERIOD34,100000000),
                            least(NVL(PERIOD35,100000000),
                            NVL(PERIOD36, 100000000))))))))))))))))))), 2)
                from    crp_capacity_plans cap
                where   cap.type_id = 5
                and     cap.resource_id = query.number3
                and     cap.department_id = query.number2
                and     cap.query_id = arg_query_id1)
            where   query_id = arg_query_id2
            and     number5 is null;

            update  crp_form_query
            set     number7 = NULL
            where   query_id = arg_query_id2
                        and     number7 = -1
            and number5 is null;

                        update crp_form_query
                        set     number8 = NULL
                        where   query_id = arg_query_id2
                        and     number8 = 100000000
                        and     number5 is null;

        end if;

        commit;
    END crp_update_util;



   /*----------crp_resource_list------------*/
  FUNCTION crp_resource_list(
                                arg_session_id  NUMBER,
                                arg_type        NUMBER,
                                arg_query_id1   NUMBER,
                                arg_query_id2   NUMBER) RETURN NUMBER IS

  rows_inserted         NUMBER;
  BEGIN

    IF (arg_type = ROUTING_BASED) then
        INSERT INTO crp_form_query(
                    query_id,
                    last_update_date,
                    last_updated_by,
                    last_update_login,
                    creation_date,
                    created_by,
                    number1,
                    number2)
        SELECT      arg_query_id2,
                    SYSDATE,
                    -1,
                    -1,
                    SYSDATE,
                    -1,
                    number2,
                    number3
        FROM        crp_form_query query
        WHERE       not exists
                    (SELECT null
                     FROM   crp_capacity_plans
                     WHERE  query_id = arg_session_id
                     AND    department_id = query.number2
                     AND    resource_id = query.number3)
        AND         number13 = 1
        AND         query.query_id = arg_query_id1;
        rows_inserted := SQL%ROWCOUNT;
    ELSE
        INSERT INTO crp_form_query(
                    query_id,
                    last_update_date,
                    last_updated_by,
                    last_update_login,
                    creation_date,
                    created_by,
                    number3)
        SELECT      arg_query_id2,
                    SYSDATE,
                    -1,
                    -1,
                    SYSDATE,
                    -1,
                    number5
        FROM        crp_form_query query
        WHERE       not exists
                    (SELECT null
                     FROM   crp_capacity_plans
                     WHERE  query_id = arg_session_id
                     AND    line_id = query.number5)
        AND         number13 = 1
        AND         query.query_id = arg_query_id1;
         rows_inserted := SQL%ROWCOUNT;
    END IF;
    COMMIT;
    return(rows_inserted);
  END crp_resource_list;

PROCEDURE crp_upd_dept_class(arg_query_id       NUMBER) IS
BEGIN
        update  crp_capacity_plans plan
        set     department_class  =
				(select	department_class_code
				 from	bom_departments
				 where	department_id = plan.department_id),
				resource_type =
				(select	meaning
				 from	mfg_lookups,
						bom_resources
				 where	lookup_type = 'BOM_RESOURCE_TYPE'
				 and	lookup_code = resource_type
				 and 	resource_id = plan.resource_id),
				resource_group_name =
				(select	resource_group_name
				 from	bom_department_resources
				 where	department_id = plan.department_id
				 and	resource_id = plan.resource_id)
        where   query_id = arg_query_id;

        COMMIT;
END;

END crp_form_pk;

/
