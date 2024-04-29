--------------------------------------------------------
--  DDL for Package Body PA_ORG_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ORG_UTILS" AS
/* $Header: PAXORUTB.pls 120.7.12010000.7 2010/03/31 05:54:33 pcheruvu ship $ */

-- Start CC Change

FUNCTION get_org_level(
                        p_org_version_id in number,
                        p_child_parent_org_id in number,
                        p_start_org_id in number
                      )
RETURN NUMBER
IS
  l_tmp_level number;
  l_org_level number;
BEGIN

/*

*************Commented this code for bug#2645200

    if ( p_start_org_id = p_child_parent_org_id ) then

        l_org_level := 1;

    else
       SELECT  max(level)
        INTO  l_tmp_level
         FROM    per_org_structure_elements
        WHERE    org_structure_version_id =  p_org_version_id
        AND     organization_id_parent =  p_child_parent_org_id
        CONNECT BY PRIOR organization_id_child = organization_id_parent
        AND  org_structure_version_id = p_org_version_id
        START WITH organization_id_parent = p_start_org_id
        AND   org_structure_version_id = p_org_version_id;

        If l_tmp_level  is NULL then

           SELECT  max(level)
            INTO l_tmp_level
           FROM    per_org_structure_elements
           WHERE    org_structure_version_id =  p_org_version_id
            AND     organization_id_child =  p_child_parent_org_id
            CONNECT BY PRIOR organization_id_child = organization_id_parent
            AND  org_structure_version_id = p_org_version_id
            START WITH organization_id_parent = p_start_org_id
            AND   org_structure_version_id = p_org_version_id;

          --- set the org level based on the formula
          l_org_level := l_tmp_level + 1;

        else

          l_org_level := l_tmp_level ;

        end if;

   end if;

End of Code Commented */

/* Code added for bug#2645200 */

select parent_level  into l_org_level
from pa_org_hierarchy_denorm
where org_hierarchy_version_id = p_org_version_id
and child_organization_id =  p_child_parent_org_id
and parent_organization_id = p_child_parent_org_id
and pa_org_use_type = 'TP_SCHEDULE';

RETURN (l_org_level);

END;

FUNCTION get_max_org_level(
                            p_org_version_id in number,
                            p_start_org_id in number
                           )
RETURN NUMBER
IS
  l_max_org_level number;
BEGIN
        SELECT  max(level) into l_max_org_level
        FROM  per_org_structure_elements
        WHERE  org_structure_version_id = p_org_version_id
        CONNECT BY PRIOR  organization_id_child =  organization_id_parent
               and org_structure_version_id = p_org_version_id
        START WITH  organization_id_parent = p_start_org_id
               and org_structure_version_id = p_org_version_id;

   RETURN (l_max_org_level);
END;

FUNCTION get_start_org_id_sch(
                            p_org_version_id in number
                           )
RETURN NUMBER
IS
  l_start_org_id number;
BEGIN

        SELECT a.organization_id_parent
        INTO   l_start_org_id
        FROM per_org_structure_elements a
        WHERE org_structure_version_id = p_org_version_id
        AND   not exists ( select 'a' from per_org_structure_elements  b
        WHERE a.organization_id_parent = b.organization_id_child and
        a.org_structure_version_id = b.org_structure_version_id)
        AND rownum = 1;

   RETURN (l_start_org_id);
END;


-- End   CC Change
FUNCTION get_org_version_id(x_usage in varchar2) RETURN NUMBER
IS
  x_org_version_id number;
BEGIN
   select decode(x_usage,'PROJECTS',PROJ_ORG_STRUCTURE_VERSION_ID
                 ,'EXPENDITURES',EXP_ORG_STRUCTURE_VERSION_ID
                 ,'REPORTING',ORG_STRUCTURE_VERSION_ID)
   into x_org_version_id
   from pa_implementations;
   RETURN (x_org_version_id);
END;

/* 1333116 Added this function to return the org hierarchy version and to
handle burdening hierarchy */
FUNCTION get_org_version_id2(x_usage in varchar2) RETURN NUMBER
IS
  x_org_version_id number;
BEGIN
   select decode(x_usage,'PROJECTS',PROJ_ORG_STRUCTURE_VERSION_ID
                 ,'EXPENDITURES',EXP_ORG_STRUCTURE_VERSION_ID
                 ,'REPORTING',ORG_STRUCTURE_VERSION_ID
                 ,'BURDENING',to_number(org_information2))
   into x_org_version_id
   from pa_implementations imp,hr_organization_information hr
   where imp.business_group_id = hr.organization_id
     and hr.org_information_context = 'Project Burdening Hierarchy';
   RETURN (x_org_version_id);
 EXCEPTION when no_data_found then
  return NULL;
END;

FUNCTION get_start_org_id(x_usage in varchar2) RETURN NUMBER
IS
  x_start_org_id number;
BEGIN
   select decode(x_usage,'PROJECTS',PROJ_START_ORG_ID
                 ,'EXPENDITURES',EXP_START_ORG_ID
                 ,'REPORTING',START_ORGANIZATION_ID)
   into x_start_org_id
   from pa_implementations;
   RETURN (x_start_org_id);
END;

/* 1333116 Added this function to return the org hierarchy
start organization and to handle burdening hierarchy */
FUNCTION get_start_org_id2(x_usage in varchar2) RETURN NUMBER
IS
  x_start_org_id number;
BEGIN
   if(x_usage <> 'BURDENING') then
   select decode(x_usage,'PROJECTS',PROJ_START_ORG_ID
                 ,'EXPENDITURES',EXP_START_ORG_ID
                 ,'REPORTING',START_ORGANIZATION_ID)
   into x_start_org_id
   from pa_implementations;
   else
    select distinct organization_id_parent into x_start_org_id
    from per_org_structure_elements a
         ,pa_implementations b
         ,hr_organization_information c
         where organization_id_parent not in
          ( select d.ORGANIZATION_ID_CHILD from per_org_structure_elements d
            where d.org_structure_version_id = to_number(c.org_information2)
          )
         and a.org_structure_version_id = to_number(c.org_information2)
         and b.business_group_id = c.organization_id
         and c.org_information_context = 'Project Burdening Hierarchy' ;
   end if;
   RETURN (x_start_org_id);
   EXCEPTION when no_data_found then
    return NULL;
END;

Procedure maintain_org_hist_imp(x_org_id in number,
                               x_old_proj_org_version_id in number,
                               x_new_proj_org_version_id in number,
                               x_old_exp_org_version_id in number,
                               x_new_exp_org_version_id in number,
                               x_old_org_structure_version_id  in number,
                               x_new_org_structure_version_id  in number,
                               x_old_proj_start_org_id in number,
                               x_new_proj_start_org_id in number,
                               x_old_exp_start_org_id in number,
                               x_new_exp_start_org_id in number,
                               x_old_start_organization_id  in number,
                               x_new_start_organization_id  in number,
                               x_err_code in out NOCOPY number, --File.Sql.39 bug 4440895
                               x_err_stage in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                               x_err_stack in out NOCOPY varchar2)  --File.Sql.39 bug 4440895
                                IS
  old_stack             varchar2(630);

/* Bug 3795903 - Added parameters to the cursor c_get_new_org */
  CURSOR c_get_new_org (l_new_org_version_id IN NUMBER, l_new_start_org_id IN NUMBER)  IS
     SELECT l_new_start_org_id
       FROM dual
     UNION ALL
     SELECT organization_id_child
       FROM per_org_structure_elements
      WHERE org_structure_version_id = l_new_org_version_id
    CONNECT BY PRIOR organization_id_child = organization_id_parent
        AND org_structure_version_id = l_new_org_version_id
 START WITH organization_id_parent = l_new_start_org_id
        AND org_structure_version_id = l_new_org_version_id;

/* Bug 3795903 - Added parameters to the cursor c_get_sub_orgs */

  CURSOR c_get_sub_orgs (l_org_id IN NUMBER , l_new_org_version_id IN NUMBER) IS
     SELECT l_org_id
       FROM dual
     UNION ALL
     SELECT organization_id_child
       FROM per_org_structure_elements
      WHERE org_structure_version_id = l_new_org_version_id
 CONNECT BY PRIOR organization_id_child = organization_id_parent
        AND org_structure_version_id = l_new_org_version_id
 START WITH organization_id_parent = l_org_id
        AND org_structure_version_id = l_new_org_version_id;

/* Bug 3795903 - Added parameters to the cursor check_org_exists */

  cursor check_org_exists (l_old_org_version_id IN NUMBER,l_old_org_start_id IN NUMBER, l_new_start_org_id IN NUMBER) is
  (select se.organization_id_child
  from per_org_structure_elements se
  where se.org_structure_version_id = l_old_org_version_id
  connect by prior se.organization_id_child = se.organization_id_parent
  and org_structure_version_id = l_old_org_version_id
  start with se.organization_id_parent = l_old_org_start_id
  and org_structure_version_id = l_old_org_version_id
   union
  select l_old_org_start_id from sys.dual)
   intersect
  (select l_new_start_org_id from sys.dual );

/* Added the cursor for bug 4232613 */
CURSOR proj_exp_check(
			c_org_struct_version_id IN per_org_structure_elements.org_structure_version_id%TYPE,
			l_org_id IN pa_implementations_all.org_id%TYPE
			)
IS
	SELECT 'Y' FROM pa_implementations_all
	WHERE ( proj_org_structure_version_id = c_org_struct_version_id
	OR exp_org_structure_version_id =  c_org_struct_version_id )
	and ORG_ID <> l_org_id;


exp_org_true     varchar2(3);
proj_org_true    varchar2(3);
rebuild_tab      varchar2(1) := 'N';
l_parent_org_id  number;
l_child_org_id   number;
l_imp_proj_exp VARCHAR2(1); -- Added for bug 4232613.
-- Start CC Change

l_tmp_parent_org_id          number;
l_tmp_child_org_id          number;
l_tmp_chr              varchar2(1);

-- End   CC Change

-- Start CC Change

-- End   CC Change

TYPE num1_tbl_type  IS TABLE OF NUMBER   INDEX BY BINARY_INTEGER;  --added for bug 6444664
l_child_org_id_var    num1_tbl_type;   --added for bug 6444664


Begin
  x_err_code := 0;
  old_stack := x_err_stack;
  x_err_stack := x_err_stack || '->Pa_org_utils.maintain_org_history';

  /* Project Orgs */
  if ( (nvl(x_old_proj_org_version_id,x_new_proj_org_version_id +1) <> x_new_proj_org_version_id )
                              or
       (nvl(x_old_proj_start_org_id,x_new_proj_start_org_id +1) <> x_new_proj_start_org_id )
     ) then

    insert into pa_all_organizations
    (organization_id,
     org_id,
     pa_org_use_type )
     ( (select se.organization_id_child
               ,x_org_id
               ,'PROJECTS'
        from per_org_structure_elements se
        where  org_structure_version_id =  x_new_proj_org_version_id
        AND     EXISTS (select 'X'
                        from hr_organization_information info
                        where info.organization_id = se.organization_id_child
                        and   info.org_information1 = 'PA_PROJECT_ORG'
                        and   info.org_information_context||'' = 'CLASS'
                        and   info.org_information2 = 'Y')
        connect by prior se.organization_id_child =
                se.organization_id_parent
        and org_structure_version_id = x_new_proj_org_version_id
        start with se.organization_id_parent = x_new_proj_start_org_id
        and org_structure_version_id = x_new_proj_org_version_id
           union
        select x_new_proj_start_org_id
               ,x_org_id
               ,'PROJECTS'
        from    sys.duaL   /* Exists clause added for bug#2591146 */
        where   EXISTS (select 'X'
                        from hr_organization_information info
                        where info.organization_id = x_new_proj_start_org_id
                        and   info.org_information1 = 'PA_PROJECT_ORG'
                        and   info.org_information_context||'' = 'CLASS'
                        and   info.org_information2 = 'Y')
       )
           minus
       (select organization_id,
               org_id,
               pa_org_use_type
        from pa_all_organizations
        where pa_org_use_type = 'PROJECTS'
        and  org_id = x_org_id --MOAC Changes: Bug 4363092: Removed nvl usage with org_id
       )
      );
 end if;

  --- Delete all rows from pa_cc_tp_schedule_line_lkp
     delete from pa_cc_tp_schedule_line_lkp;

 --- changes for pa_org_hierarchy_denorm table
 if (nvl(x_old_proj_start_org_id,x_new_proj_start_org_id +1) <> x_new_proj_start_org_id ) then
      ---- start org is changed, update only if org is moved up

-- Bug 3795903-  Modified the call to check_org_exists

    open check_org_exists(x_old_proj_org_version_id ,x_old_proj_start_org_id,x_new_proj_start_org_id);
    fetch check_org_exists into l_parent_org_id;
    if check_org_exists%notfound then
        rebuild_tab := 'Y';
    end if;
    close check_org_exists;  /* Added for bug 1736069 */
 end if;

  if (nvl(x_old_proj_org_version_id,x_new_proj_org_version_id +1) <> x_new_proj_org_version_id ) or rebuild_tab = 'Y' then

  --- org hierarchy is changed or version is changed
  -- Bug 3795903-  Modified the call to c_get_new_org by putting x_new_proj_start_org_id in the call
      open c_get_new_org(x_new_proj_org_version_id,x_new_proj_start_org_id);
      loop
         fetch c_get_new_org into l_parent_org_id;
         exit when c_get_new_org%notfound;

  -- Bug 3795903-  Modified the call to c_get_sub_orgs by putting x_new_proj_org_version_id in the call
         open c_get_sub_orgs(l_parent_org_id ,x_new_proj_org_version_id);
         loop
             --fetch c_get_sub_orgs into l_child_org_id;
             fetch c_get_sub_orgs BULK COLLECT into l_child_org_id_var LIMIT 10000;  --bug6444664
             exit when l_child_org_id_var.count = 0;--8915976
             /*bug6444664
                    begin
                         select 'YES' into proj_org_true
                           from hr_organization_information
                          where organization_id = l_child_org_id
                            and ORG_INFORMATION_CONTEXT = 'CLASS'
                            and ORG_INFORMATION1 = 'PA_PROJECT_ORG'
                            and ORG_INFORMATION2 = 'Y';
                         exception when no_data_found then
                            proj_org_true := 'NO';
                     end ;

                         if proj_org_true = 'YES' then

                        pa_org_utils.CREATE_ORG_HIERARCHY_DENORM(p_parent_organization_id=> l_parent_org_id
                                                 , p_child_organization_id => l_child_org_id
                                                 , p_org_hierarchy_version_id=> x_new_proj_org_version_id
                                                 , p_pa_org_use_type =>  'PROJECTS'
                                                 , x_err_code        => x_err_code
                                                 , x_err_stage       => x_err_stage
                                                 , x_err_stack       => x_err_stack);
                        end if;
                        bug6444664*/
             IF l_child_org_id_var.COUNT > 0 THEN
               FORALL i IN l_child_org_id_var.FIRST..l_child_org_id_var.LAST
                 INSERT INTO PA_ORG_HIERARCHY_DENORM ( parent_organization_id
                                        , child_organization_id
                                        , org_hierarchy_version_id
                                        , pa_org_use_type
                                        , creation_date
                                        , created_by
                                        , last_update_date
                                        , last_updated_by
                                        , last_update_login
                                          )
                              SELECT  l_parent_org_id
                                    , l_child_org_id_var(i)
                                    , x_new_proj_org_version_id
                                    , 'PROJECTS'
                                    , sysdate
                                    ,1--     , TO_NUMBER(FND_PROFILE.VALUE('USER_ID'))
                                    , sysdate
                                    ,1--     , TO_NUMBER(FND_PROFILE.VALUE('USER_ID'))
                                    ,1--     , TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'))
                               from dual
                               where not exists
                                    (select 'Y'
                                    from pa_org_hierarchy_denorm
                                   where pa_org_use_type = 'PROJECTS'
                                     and parent_organization_id = l_parent_org_id
                                     and child_organization_id = l_child_org_id_var(i)
                                     and org_hierarchy_version_id = x_new_proj_org_version_id)
                               AND EXISTS (select 'X'
                                    from hr_organization_information
                                    where organization_id = l_child_org_id_var(i)
                                    and   org_information1 = 'PA_PROJECT_ORG'
                                    and   org_information_context = 'CLASS'
                                    and   org_information2 = 'Y');
             END IF;
         l_child_org_id_var.DELETE; --bug6444664
         end loop;
         close c_get_sub_orgs;
      end loop;
      close c_get_new_org;

  end if;



 /* Exp orgs */
  if ( (nvl(x_old_exp_org_version_id,x_new_exp_org_version_id +1) <> x_new_exp_org_version_id )
                              or
       (nvl(x_old_exp_start_org_id,x_new_exp_start_org_id +1) <> x_new_exp_start_org_id )
     ) then

    insert into pa_all_organizations
    (organization_id,
     org_id,
     pa_org_use_type)
     ( (select se.organization_id_child
               ,x_org_id
               ,'EXPENDITURES'
        from per_org_structure_elements se
        where  org_structure_version_id =  x_new_exp_org_version_id
        AND     EXISTS (select 'X'
                        from hr_organization_information info
                        where info.organization_id = se.organization_id_child
                        and   info.org_information1 = 'PA_EXPENDITURE_ORG'
                        and   info.org_information_context||'' = 'CLASS'
                        and   info.org_information2 = 'Y')
        connect by prior se.organization_id_child =
                se.organization_id_parent
        and org_structure_version_id = x_new_exp_org_version_id
        start with se.organization_id_parent = x_new_exp_start_org_id
        and org_structure_version_id = x_new_exp_org_version_id
           union
        select x_new_exp_start_org_id
               ,x_org_id
               ,'EXPENDITURES'
        from    sys.duaL  /* Exists clause added for bug#2591146 */
        where   EXISTS (select 'X'
                        from  hr_organization_information info
                        where info.organization_id = x_new_exp_start_org_id
                        and   info.org_information1 = 'PA_EXPENDITURE_ORG'
                        and   info.org_information_context||'' = 'CLASS'
                        and   info.org_information2 = 'Y')
       )
           minus
       (select organization_id,
               org_id,
               pa_org_use_type
        from pa_all_organizations
        where pa_org_use_type = 'EXPENDITURES'
        and  org_id = x_org_id --MOAC Changes: Bug 4363092: Removed nvl usage with org_id
       )
      );

 end if;

 --- changes for pa_org_hierarchy_denorm table
 if (nvl(x_old_exp_start_org_id,x_new_exp_start_org_id +1) <> x_new_exp_start_org_id ) then
      ---- start org is changed, update only if org is moved up

-- Bug 3795903-  Modified the call to check_org_exists
    open check_org_exists(x_old_exp_org_version_id ,x_old_exp_start_org_id,x_new_exp_start_org_id);

    fetch check_org_exists into l_parent_org_id;
    if check_org_exists%notfound then
        rebuild_tab := 'Y';
    end if;
    close check_org_exists;  /* Added for bug 1736069 */
 end if;

  if (nvl(x_old_exp_org_version_id,x_new_exp_org_version_id +1) <> x_new_exp_org_version_id ) or rebuild_tab = 'Y' then
  --- org hierarchy is changed or version is changed

  --- Bug 3795903-  Modified the call to c_get_new_org
      open c_get_new_org(x_new_exp_org_version_id,x_new_exp_start_org_id);
      loop
         fetch c_get_new_org into l_parent_org_id;
         exit when c_get_new_org%notfound;

--- Bug 3795903-  Modified the call to c_get_sub_orgs
         open c_get_sub_orgs(l_parent_org_id,x_new_exp_org_version_id);
         loop
             fetch c_get_sub_orgs BULK COLLECT into l_child_org_id_var LIMIT 10000; --bug6444664
             exit when l_child_org_id_var.count = 0;--8915976
             /*
                    begin
                         select 'YES' into exp_org_true
                           from hr_organization_information
                          where organization_id = l_child_org_id
                            and ORG_INFORMATION_CONTEXT = 'CLASS'
                            and ORG_INFORMATION1 = 'PA_EXPENDITURE_ORG'
                            and ORG_INFORMATION2 = 'Y';
                         exception when no_data_found then
                            exp_org_true := 'NO';
                     end ;

                         if exp_org_true = 'YES' then

                        pa_org_utils.CREATE_ORG_HIERARCHY_DENORM(p_parent_organization_id=> l_parent_org_id
                                                 , p_child_organization_id => l_child_org_id
                                                 , p_org_hierarchy_version_id=> x_new_exp_org_version_id
                                                 , p_pa_org_use_type =>  'EXPENDITURES'
                                                 , x_err_code        => x_err_code
                                                 , x_err_stage       => x_err_stage
                                                 , x_err_stack       => x_err_stack);
                        end if;
                        bug6444664*/
             IF l_child_org_id_var.COUNT > 0 THEN
              FORALL i IN l_child_org_id_var.FIRST..l_child_org_id_var.LAST
                INSERT INTO PA_ORG_HIERARCHY_DENORM ( parent_organization_id
                                        , child_organization_id
                                        , org_hierarchy_version_id
                                        , pa_org_use_type
                                        , creation_date
                                        , created_by
                                        , last_update_date
                                        , last_updated_by
                                        , last_update_login
                                          )
                              SELECT  l_parent_org_id
                                    , l_child_org_id_var(i)
                                    , x_new_exp_org_version_id
                                    , 'EXPENDITURES'
                                    , sysdate
                                    ,1--     , TO_NUMBER(FND_PROFILE.VALUE('USER_ID'))
                                    , sysdate
                                    ,1--     , TO_NUMBER(FND_PROFILE.VALUE('USER_ID'))
                                    ,1--     , TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'))
                               from dual
                               where not exists
                                    (select 'Y'
                                    from pa_org_hierarchy_denorm
                                   where pa_org_use_type = 'EXPENDITURES'
                                     and parent_organization_id = l_parent_org_id
                                     and child_organization_id = l_child_org_id_var(i)
                                     and org_hierarchy_version_id = x_new_exp_org_version_id)
                               AND EXISTS (select 'X'
                                    from hr_organization_information
                                    where organization_id = l_child_org_id_var(i)
                                    and   org_information1 = 'PA_EXPENDITURE_ORG'
                                    and   org_information_context = 'CLASS'
                                    and   org_information2 = 'Y');
          END IF;
         l_child_org_id_var.DELETE;   --bug6444664
         end loop;
         close c_get_sub_orgs;
      end loop;
      close c_get_new_org;

  end if;

 /* Reporting Orgs */
  If ( (nvl(x_old_org_structure_version_id,x_new_org_structure_version_id ) <>
            x_new_org_structure_version_id )
                              or
     (nvl(x_old_start_organization_id,x_new_start_organization_id ) <>
            x_new_start_organization_id ) ) then
     -- call procedure populate hierarchy denorm to insert rows into
     -- into pa_org_hierarchy_denorm for reporting type of organizations

/* Bug 2976953 - Changed populate_hierarchy_denorm to populate_hierarchy_denorm2 and also added
 the parameter p_org_id for that call */

         pa_org_utils.populate_hierarchy_denorm2
                             ( p_org_version_id         => x_new_org_structure_version_id
                               ,p_organization_id_parent=> x_new_start_organization_id
                               ,p_organization_id_child => 1
                               ,p_org_id   => x_org_id   /* Added this condition for bug 2976953 */
                               ,x_err_code              => x_err_code
                               ,x_err_stage             => x_err_stage
                               ,x_err_stack             => x_err_stack
                             );

  End If;

-- Start CC Change

/* Schedule line Traverse Org Hierarchy */

-- sri_msg(' START ................. ');

/* Bug#2723330 - Commenting the rebuild_tab = 'Y' Condition as TP_SCHEDULE is maintained
for full hierarchy in HR and will not be affected by movind start org in implementation options */

 if (nvl(x_old_proj_org_version_id,x_new_proj_org_version_id +1)
              <> x_new_proj_org_version_id) /* or rebuild_tab = 'Y'  For Bug#2723330*/
  then

 /* Bug 4232613. Added the check before calling populate_hier_denorm_sch.
      If the org version id is already used in the implementation option then the API
      need not be called.   */
      OPEN proj_exp_check(x_new_proj_org_version_id,x_org_id);
      FETCH proj_exp_check INTO l_imp_proj_exp;
      IF proj_exp_check%NOTFOUND THEN
      populate_hier_denorm_sch( p_org_version_id        => x_new_proj_org_version_id
                               ,x_err_code              => x_err_code
                               ,x_err_stage             => x_err_stage
                               ,x_err_stack             => x_err_stack );
      END IF;
      close proj_exp_check;

 end if;

 if (nvl(x_old_exp_org_version_id,x_new_exp_org_version_id +1) <>
            x_new_exp_org_version_id ) /* or rebuild_tab = 'Y' For Bug#2723330 */
  then

   /* Bug 4232613. Added the check before calling populate_hier_denorm_sch.
      If the org version id is already used in the implementation option then the API
      need not be called.   */
      OPEN proj_exp_check(x_new_exp_org_version_id,x_org_id);
      FETCH proj_exp_check INTO l_imp_proj_exp;
      IF proj_exp_check%NOTFOUND THEN
	populate_hier_denorm_sch( p_org_version_id        => x_new_exp_org_version_id
                               ,x_err_code              => x_err_code
                               ,x_err_stage             => x_err_stage
                               ,x_err_stack             => x_err_stack );
      END IF;
      close proj_exp_check;

 end if;

-- End CC Change

 x_err_stack := old_stack;

Exception
 when others then
 x_err_code := SQLCODE;
 x_err_stage := SQLERRM;
 return;
End;

-- Start CC Change

Procedure populate_hier_denorm_sch ( p_org_version_id in number,
                                     x_err_code in out NOCOPY number, --File.Sql.39 bug 4440895
                                     x_err_stage in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                                     x_err_stack in out NOCOPY varchar2) IS --File.Sql.39 bug 4440895

l_dummy_level  number := 0;

  CURSOR c_get_new_org_sch(lp_org_version_id IN NUMBER,
                           lp_start_org_id   IN NUMBER ) IS
     SELECT l_dummy_level,lp_start_org_id
       FROM dual
     UNION ALL
     SELECT level,organization_id_child
       FROM per_org_structure_elements
      WHERE org_structure_version_id = lp_org_version_id
    CONNECT BY PRIOR organization_id_child = organization_id_parent
        AND org_structure_version_id = lp_org_version_id
 START WITH organization_id_parent = lp_start_org_id
        AND org_structure_version_id = lp_org_version_id;

  CURSOR c_get_sub_orgs_sch (lp_org_version_id IN NUMBER,
                         lp_org_id IN NUMBER) IS
     SELECT l_dummy_level,lp_org_id
       FROM dual
     UNION ALL
     SELECT level,organization_id_child
       FROM per_org_structure_elements
      WHERE org_structure_version_id = lp_org_version_id
 CONNECT BY PRIOR organization_id_child = organization_id_parent
        AND org_structure_version_id = lp_org_version_id
 START WITH organization_id_parent = lp_org_id
        AND org_structure_version_id = lp_org_version_id;

/* Commented this cursor for bug#2723330 as this cursor is not used now

CURSOR check_org_ver_not_exists ( lp_org_version_id IN NUMBER ) IS
SELECT 'x'
FROM   dual
WHERE not exists
  ( SELECT 'x' from pa_org_hierarchy_denorm
    WHERE  org_hierarchy_version_id = nvl(lp_org_version_id,org_hierarchy_version_id)
    and    pa_org_use_type = 'TP_SCHEDULE' );

*/

-- End   CC Change

-- Start CC Change

l_tmp_parent_org_id          number;
l_tmp_child_org_id          number;
l_tmp_chr              varchar2(1);

-- End   CC Change

-- Start CC Change

l_start_org_id   number;
l_plevel         number;
l_clevel         number;
l_parent_level   number;
l_child_level    number;

-- End   CC Change
TYPE number_tbl_type  IS TABLE OF NUMBER   INDEX BY BINARY_INTEGER;  --added for bug6444664
l_child_level_var        number_tbl_type;   --added for bug6444664
l_tmp_child_org_id_var   number_tbl_type;   --added for bug6444664
l_pa_org_use_type        VARCHAR2(30);      --added for bug6444664
BEGIN

/*

********** Commented for bug#2723330
********** open check_org_ver_not_exists ( p_org_version_id );
**********   LOOP
**********    fetch check_org_ver_not_exists into l_tmp_chr;
**********    exit when check_org_ver_not_exists%notfound;
**********

*/

    l_start_org_id := get_start_org_id_sch(p_org_version_id);

/* Start of code Added for bug#2723330 */

     BEGIN
          DELETE from pa_org_hierarchy_denorm
          WHERE org_hierarchy_version_id = p_org_version_id
           AND pa_org_use_type = 'TP_SCHEDULE';
     EXCEPTION
          WHEN others  THEN
            Null;
     END;

    /* End of code for bug#2723330 */

    open c_get_new_org_sch ( p_org_version_id ,
                                l_start_org_id );

    LOOP
     fetch c_get_new_org_sch into l_parent_level, l_tmp_parent_org_id;
     exit when c_get_new_org_sch%notfound;

     l_plevel := l_parent_level +1 ;

     open c_get_sub_orgs_sch ( p_org_version_id ,
                                l_tmp_parent_org_id );
--Performance improvement for Bug8395942 Begins Here
--     LOOP

      --fetch c_get_sub_orgs_sch into l_child_level, l_tmp_child_org_id;
        fetch c_get_sub_orgs_sch BULK COLLECT into l_child_level_var, l_tmp_child_org_id_var  LIMIT 10000;  --bug6444664
      exit when l_child_level_var.count = 0;--8915976
    close c_get_sub_orgs_sch;
--      l_clevel := l_child_level +  l_parent_level   +1 ;

      /*pa_org_utils.Create_org_hier_denorm_levels
                   (p_parent_organization_id=> l_tmp_parent_org_id
                   , p_child_organization_id => l_tmp_child_org_id
                   , p_org_hierarchy_version_id=> p_org_version_id
                   , p_pa_org_use_type =>  'TP_SCHEDULE'
                   , p_parent_level =>  l_plevel
                   , p_child_level  =>  l_clevel
                   , x_err_code        => x_err_code
                   , x_err_stage       => x_err_stage
                   , x_err_stack       => x_err_stack); */

       IF l_child_level_var.COUNT > 0 THEN
        FORALL i IN l_child_level_var.FIRST..l_child_level_var.LAST

        INSERT INTO pa_org_hierarchy_denorm ( parent_organization_id
                                        , child_organization_id
                                        , org_hierarchy_version_id
                                        , pa_org_use_type
                                        , creation_date
                                        , created_by
                                        , last_update_date
                                        , last_updated_by
                                        , last_update_login
                                        , parent_level
                                        , child_level
                                          )
                              SELECT  l_tmp_parent_org_id
                                    , l_tmp_child_org_id_var(i)
                                    , p_org_version_id
                                    , 'TP_SCHEDULE'
                                    , sysdate
,1--                                    , TO_NUMBER(FND_PROFILE.VALUE('USER_ID'))
                                    , sysdate
,1--                                    , TO_NUMBER(FND_PROFILE.VALUE('USER_ID'))
,1--                                    , TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'))
                                        , l_plevel
                                        , (l_child_level_var(i) +  l_parent_level   +1)
                               from dual
                               where not exists
                                    (select 'Y'
                                    from pa_org_hierarchy_denorm
                                   where pa_org_use_type = 'TP_SCHEDULE'
                                     and parent_organization_id = l_tmp_parent_org_id
                                     and child_organization_id = l_tmp_child_org_id_var(i)
                                     and org_hierarchy_version_id = p_org_version_id);
             END IF;
         l_child_level_var.DELETE;
         l_tmp_child_org_id_var.DELETE;


--     END LOOP; /* end loop for cursor c_get_sub_orgs_sch */

--Performance improvement for Bug8395942 Ends Here

    END LOOP;   /* end loop for cursor c_get_new_org_sch */

    close c_get_new_org_sch;

/*

**********  Commented for bug#2723330

*********  END LOOP;   end loop for cursor check_org_ver_not_exists

**********  close check_org_ver_not_exists;

*/

Exception
 when others then
 x_err_code := SQLCODE;
 x_err_stage := SQLERRM;
 return;
END;

Procedure maintain_org_hist_bri(x_org_version_id in number,
                               x_organization_id_child in number,
                               x_organization_id_parent in number,
                               x_err_code in out NOCOPY number, --File.Sql.39 bug 4440895
                               x_err_stage in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                               x_err_stack in out NOCOPY varchar2) IS --File.Sql.39 bug 4440895
  v_start_org_id number;
  v_org_child_id number;
  l_parent_org_id number;
  l_exp_org_true  varchar2(1);
  l_proj_org_true varchar2(1);
  org_exists_flag boolean;  /* Added for the bug 2139709 */

/*
Bug#2620151- Commented the old cursor and added new logic for the cursor check_org_exists

New Logic: Traverse from x_organization_id_parent and get all the parents for this, union
with x_organization_id_parent.
In this result, check for v_start_org_id, if present then it means that the org
x_organization_id_parent is under v_start_org_id.

Earlier Logic: Traverse from v_start_org_d and get all the childs for this, union with
v_start_org_id.
In this result, check for x_organization_id_parent, if present then it means
that the org x_organization_id_parent is under v_start_org_id.
*/

  cursor check_org_exists is
  (
  select se.organization_id_parent
  from per_org_structure_elements se
  where se.org_structure_version_id = x_org_version_id
  connect by prior se.organization_id_parent =
                             se.organization_id_child
  and org_structure_version_id = x_org_version_id
  start with se.organization_id_child =
                       x_organization_id_parent
  and org_structure_version_id = x_org_version_id
  union
  select x_organization_id_parent from sys.dual
   )
  intersect
  (
  select v_start_org_id from sys.dual
  );

/* Commented for Bug#2620151 Added cursor above
  cursor check_org_exists is
  (select se.organization_id_child
  from per_org_structure_elements se
  where se.org_structure_version_id =
   x_org_version_id
  connect by prior se.organization_id_child =
            se.organization_id_parent
  and org_structure_version_id = x_org_version_id
  start with se.organization_id_parent =
        v_start_org_id
  and org_structure_version_id = x_org_version_id
      union
  select v_start_org_id
  from sys.dual)
   intersect
  (select x_organization_id_parent
  from sys.dual );
*/

--- To populate pa_org_hierarchy_denorm
  cursor get_all_orgs is
 (SELECT x_organization_id_parent
       FROM dual
     UNION
     SELECT organization_id_parent
       FROM per_org_structure_elements
      WHERE org_structure_version_id = x_org_version_id
 CONNECT BY PRIOR organization_id_parent= organization_id_child
        AND org_structure_version_id = x_org_version_id
 START WITH organization_id_child = x_organization_id_parent
        AND org_structure_version_id = x_org_version_id)    /* Bug#2643047, Added this condition as we have to query only for this org_structure_version_id */
 union ALL
 (SELECT x_organization_id_child from dual);

-- Start CC Change

  cursor get_all_orgs_sch(
                       lp_organization_id_parent in number,
                       lp_organization_id_child  in number,
                       lp_org_version_id  in number  ) is
 (SELECT lp_organization_id_parent
       FROM dual
     UNION
     SELECT organization_id_parent
       FROM per_org_structure_elements
      WHERE org_structure_version_id = lp_org_version_id
 CONNECT BY PRIOR organization_id_parent= organization_id_child
        AND org_structure_version_id = lp_org_version_id
 START WITH organization_id_child = lp_organization_id_parent
        AND org_structure_version_id = lp_org_version_id)
 union ALL
 (SELECT lp_organization_id_child from dual);

l_plevel        number;
l_clevel        number;
l_start_org_id  number;
TYPE num_tbl_type  IS TABLE OF NUMBER         INDEX BY BINARY_INTEGER;  --bug6444664
l_parent_org_id_var num_tbl_type;    --bug6444664
/*Bug# 2247737*/
l_process_schedule_hier varchar2(1);
/*End bug# 2247737*/

-- End   CC Change
Begin

/*Bug# 2247737*/
  l_process_schedule_hier := 'N';
/*End bug# 2247737*/

 /* For all operating units where the Project Org structure
    specified is same as the changed Org structure */
  for imp_rec in ( select org_id,proj_start_org_id
                   from   pa_implementations_all imp
                   where  proj_org_structure_version_id = x_org_version_id
                  )

  loop

   /*Bug# 2247737*/
    l_process_schedule_hier := 'Y';
  /*End bug# 2247737*/

    v_start_org_id := imp_rec.proj_start_org_id;

/* Bug 2139709 Begin */
    org_exists_flag := FALSE;

    IF v_start_org_id = x_organization_id_parent THEN
        org_exists_flag := TRUE;
    ELSE
        open check_org_exists;
        fetch check_org_exists into v_org_child_id;
        if check_org_exists%found then /* Added org is below
                                      the start project org */
            org_exists_flag := TRUE;
        else
            org_exists_flag := FALSE;
        end if;
        close check_org_exists;
     END IF;

     IF org_exists_flag = TRUE THEN
/* Bug 2139709 End */

      insert into pa_all_organizations
        (organization_id,
         org_id,
         pa_org_use_type)
      (select
         x_organization_id_child,
         imp_rec.org_id,
         'PROJECTS'
       from sys.dual
       where exists (select 'x'
            from hr_organization_information info
            where info.organization_id = x_organization_id_child
            and   info.org_information1 = 'PA_PROJECT_ORG'
            and   info.org_information_context||'' = 'CLASS'
            and   info.org_information2 = 'Y')
       and   not exists
             (select 'X'
              from pa_all_organizations
              where organization_id = x_organization_id_child
              and  org_id = imp_rec.org_id  --MOAC Changes: Bug 4363092: Removed nvl usage with org_id
            and   pa_org_use_type = 'PROJECTS')
       ) ;

     /* Added for bug 1550990 */
   if(sql%rowcount=0) then
       Update pa_all_organizations
        set   inactive_date   = NULL
        where organization_id = x_organization_id_child
        and   org_id = imp_rec.org_id --MOAC Changes: Bug 4363092: Removed nvl usage with org_id
        and   pa_org_use_type = 'PROJECTS'
        and  exists (select 'x'                          -- EXISTS condition added for bug 2890516
            from hr_organization_information info
            where info.organization_id = x_organization_id_child
            and   info.org_information1 = 'PA_PROJECT_ORG'
            and   info.org_information_context||'' = 'CLASS'
            and   info.org_information2 = 'Y');

   end if ;

   --- Delete all rows from pa_cc_tp_schedule_line_lkp
     delete from pa_cc_tp_schedule_line_lkp;

   -------- for pa_org_hierarchy_denorm
/*    open get_all_orgs;
    loop
    fetch get_all_orgs into l_parent_org_id;
    exit when get_all_orgs%notfound;  */

    begin
    select 'Y' into l_proj_org_true
      from hr_organization_information info
            where info.organization_id = x_organization_id_child
            and   info.org_information1 = 'PA_PROJECT_ORG'
            and   info.org_information_context||'' = 'CLASS'
            and   info.org_information2 = 'Y';
    exception when no_data_found then
            l_proj_org_true := 'N';
    end;
 open get_all_orgs;
    loop
    fetch get_all_orgs BULK COLLECT into l_parent_org_id_var LIMIT 10000;
    exit when l_parent_org_id_var.count = 0;--8915976
            if l_proj_org_true = 'Y' then
               /* pa_org_utils.CREATE_ORG_HIERARCHY_DENORM(p_parent_organization_id => l_parent_org_id
                                            ,p_child_organization_id =>x_organization_id_child
                                            ,p_org_hierarchy_version_id => x_org_version_id
                                            ,p_pa_org_use_type => 'PROJECTS'
                                            , x_err_code        => x_err_code
                                            , x_err_stage       => x_err_stage
                                            , x_err_stack       => x_err_stack);*/
          IF l_parent_org_id_var.COUNT > 0 THEN
           FORALL i IN l_parent_org_id_var.FIRST..l_parent_org_id_var.LAST
             INSERT INTO PA_ORG_HIERARCHY_DENORM ( parent_organization_id
                                        , child_organization_id
                                        , org_hierarchy_version_id
                                        , pa_org_use_type
                                        , creation_date
                                        , created_by
                                        , last_update_date
                                        , last_updated_by
                                        , last_update_login
                                          )
                              SELECT  l_parent_org_id_var(i)
                                    , x_organization_id_child
                                    , x_org_version_id
                                    , 'PROJECTS'
                                    , sysdate
                                    ,1--      , TO_NUMBER(FND_PROFILE.VALUE('USER_ID'))
                                    , sysdate
                                    ,1--      , TO_NUMBER(FND_PROFILE.VALUE('USER_ID'))
                                    ,1--      , TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'))
                               from dual
                               where not exists
                                    (select 'Y'
                                    from pa_org_hierarchy_denorm
                                   where pa_org_use_type = 'PROJECTS'
                                     and parent_organization_id = l_parent_org_id_var(i)
                                     and child_organization_id = x_organization_id_child
                                     and org_hierarchy_version_id = x_org_version_id);
          END IF;
          l_parent_org_id_var.DELETE;
        end if;
     end loop;
     close get_all_orgs;
  --------

     end if;

   end loop;

 /* For all operating units where the Exp Org structure
    specified is same as the changed Org structure */
  for imp_rec in ( select org_id, exp_start_org_id
                   from   pa_implementations_all imp
                   where  exp_org_structure_version_id = x_org_version_id
                  )
  loop

  /*Bug# 2247737*/

    l_process_schedule_hier := 'Y';

 /*End bug# 2247737*/

    v_start_org_id := imp_rec.exp_start_org_id;

/* Bug 2139709 Begin */
    org_exists_flag := FALSE;

    IF v_start_org_id = x_organization_id_parent THEN
        org_exists_flag := TRUE;
    ELSE
        open check_org_exists;
        fetch check_org_exists into v_org_child_id;
        if check_org_exists%found then /* Added org is below
                                      the start project org */
            org_exists_flag := TRUE;
        else
            org_exists_flag := FALSE;
        end if;
        close check_org_exists;
     END IF;

     IF org_exists_flag = TRUE THEN
/* Bug 2139709 End */

      insert into pa_all_organizations
        (organization_id,
         org_id,
         pa_org_use_type)
      (select
         x_organization_id_child,
         imp_rec.org_id,
         'EXPENDITURES'
       from sys.dual
       where exists (select 'x'
            from hr_organization_information info
            where info.organization_id = x_organization_id_child
            and   info.org_information1 = 'PA_EXPENDITURE_ORG'
            and   info.org_information_context||'' = 'CLASS'
            and   info.org_information2 = 'Y')
       and not exists
             (select 'X'
              from pa_all_organizations
              where organization_id = x_organization_id_child
              and  org_id = imp_rec.org_id --MOAC Changes: Bug 4363092: Removed nvl usage with org_id
              and   pa_org_use_type = 'EXPENDITURES')
        ) ;

/* Added for bug 1550990 */
   if(sql%rowcount=0) then
       Update pa_all_organizations
        set inactive_date=NULL
        where organization_id =x_organization_id_child
        and   org_id = imp_rec.org_id --MOAC Changes: Bug 4363092: Removed nvl usage with org_id
        and   pa_org_use_type = 'EXPENDITURES'
        and  exists (select 'x'                          -- EXISTS condition added for bug 2890516
            from hr_organization_information info
            where info.organization_id = x_organization_id_child
            and   info.org_information1 = 'PA_EXPENDITURE_ORG'
            and   info.org_information_context||'' = 'CLASS'
            and   info.org_information2 = 'Y');

   end if ;

   -------- for pa_org_hierarchy_denorm
   /* open get_all_orgs;
    loop
    fetch get_all_orgs into l_parent_org_id;
    exit when get_all_orgs%notfound;  */

    begin
    select 'Y' into l_exp_org_true
      from hr_organization_information info
            where info.organization_id = x_organization_id_child
            and   info.org_information1 = 'PA_EXPENDITURE_ORG'
            and   info.org_information_context||'' = 'CLASS'
            and   info.org_information2 = 'Y';
    exception when no_data_found then
            l_exp_org_true := 'N';
    end;
    l_parent_org_id_var.DELETE;
    open get_all_orgs;
    loop
    fetch get_all_orgs BULK COLLECT into l_parent_org_id_var LIMIT 10000;
    exit when l_parent_org_id_var.count = 0;--8915976
            if l_exp_org_true = 'Y' then
                /*pa_org_utils.CREATE_ORG_HIERARCHY_DENORM(p_parent_organization_id => l_parent_org_id
                                            ,p_child_organization_id =>x_organization_id_child
                                            ,p_org_hierarchy_version_id => x_org_version_id
                                            ,p_pa_org_use_type => 'EXPENDITURES'
                                            , x_err_code        => x_err_code
                                            , x_err_stage       => x_err_stage
                                            , x_err_stack       => x_err_stack);*/
                 IF l_parent_org_id_var.COUNT > 0 THEN
                   FORALL i IN l_parent_org_id_var.FIRST..l_parent_org_id_var.LAST
                         INSERT INTO PA_ORG_HIERARCHY_DENORM ( parent_organization_id
                                        , child_organization_id
                                        , org_hierarchy_version_id
                                        , pa_org_use_type
                                        , creation_date
                                        , created_by
                                        , last_update_date
                                        , last_updated_by
                                        , last_update_login
                                          )
                              SELECT  l_parent_org_id_var(i)
                                    , x_organization_id_child
                                    , x_org_version_id
                                    , 'EXPENDITURES'
                                    , sysdate
                                    ,1--      , TO_NUMBER(FND_PROFILE.VALUE('USER_ID'))
                                    , sysdate
                                    ,1--      , TO_NUMBER(FND_PROFILE.VALUE('USER_ID'))
                                    ,1--      , TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'))
                               from dual
                               where not exists
                                    (select 'Y'
                                    from pa_org_hierarchy_denorm
                                   where pa_org_use_type = 'EXPENDITURES'
                                     and parent_organization_id = l_parent_org_id_var(i)
                                     and child_organization_id = x_organization_id_child
                                     and org_hierarchy_version_id = x_org_version_id);
                END IF;
                l_parent_org_id_var.DELETE;
            end if;
     end loop;
     close get_all_orgs;
  --------
     end if;

   end loop;
-- Start CC Change

/*Bug# 2247737*/

  if ( l_process_schedule_hier = 'Y' ) then

/*End bug# 2247737*/
    l_start_org_id := get_start_org_id_sch(x_org_version_id);

/* Bug#2645200 - Changed x_organization_id_parent instead of x_organization_id_child as the parameter
  for p_child_parent_org_id  */

    l_clevel :=  get_org_level(
                        p_org_version_id  => x_org_version_id,
                        p_child_parent_org_id  => x_organization_id_parent,      /* 2645200 x_organization_id_child,*/
                        p_start_org_id  => l_start_org_id );

    l_clevel := l_clevel + 1;  /* Bug#2645200 - Added as the level got is for parent in the call earlier */

    open get_all_orgs_sch(x_organization_id_parent,
                          x_organization_id_child,
                          x_org_version_id );
    LOOP
    FETCH get_all_orgs_sch into l_parent_org_id;
    exit when get_all_orgs_sch%notfound;     /*Bug# 2244878*/

    /* 2645200 */
    if (l_parent_org_id = x_organization_id_child) then
         l_plevel := l_clevel;
    else
         l_plevel :=  get_org_level(
                      p_org_version_id  => x_org_version_id,
                      p_child_parent_org_id  => l_parent_org_id,
                      p_start_org_id  => l_start_org_id );
    end if;

    pa_org_utils.Create_org_hier_denorm_levels
                   (p_parent_organization_id=> l_parent_org_id
                    , p_child_organization_id => x_organization_id_child
                    , p_org_hierarchy_version_id=> x_org_version_id
                    , p_pa_org_use_type =>  'TP_SCHEDULE'
                    , p_parent_level =>  l_plevel
                    , p_child_level  =>  l_clevel
                    , x_err_code        => x_err_code
                    , x_err_stage       => x_err_stage
                    , x_err_stack       => x_err_stack);
    END LOOP;
    close get_all_orgs_sch; /*Bug# 2244878*/
-- End   CC Change

/*Bug# 2247737*/

  end if;

/*End bug# 2247737*/

/* Bug#2643047 - Call to populate reporting orgs in pa_org_hierarchy_denorm table */

pa_org_utils.populate_reporting_orgs(x_org_version_id ,
                               x_organization_id_child ,
                               x_organization_id_parent,
                               x_err_code ,
                               x_err_stage,
                               x_err_stack );

Exception
 when others then
 x_err_code := SQLCODE;
 x_err_stage := SQLERRM;
 return;

End;

Procedure maintain_org_hist_brd(x_org_version_id in number,
                               x_organization_id_child in number,
                               x_err_code in out NOCOPY number, --File.Sql.39 bug 4440895
                               x_err_stage in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                               x_err_stack in out NOCOPY varchar2) IS --File.Sql.39 bug 4440895
CURSOR c_get_all_orgs IS
     SELECT child_organization_id
       from pa_org_hierarchy_denorm
      where org_hierarchy_version_id = x_org_version_id
        and parent_organization_id = x_organization_id_child;

l_parent_org_id  number;

Begin
 /* For all operating units where the Project Org structure
     specified is same as the changed Org structure */
  for imp_rec in ( select org_id,proj_start_org_id
                   from   pa_implementations_all imp
                   where  proj_org_structure_version_id = x_org_version_id
                  )

  loop
      update pa_all_organizations
      set inactive_date = trunc(sysdate)
      where organization_id = x_organization_id_child
      and  org_id = imp_rec.org_id --MOAC Changes: Bug 4363092: Removed nvl usage with org_id
      and   pa_org_use_type = 'PROJECTS'
      and inactive_date is null ; -- Bug Ref # 6367868
  end loop;


  /* For all operating units where the Exp Org structure
     specified is same as the changed Org structure */
  for imp_rec in ( select org_id, exp_start_org_id
                   from   pa_implementations_all imp
                   where  exp_org_structure_version_id = x_org_version_id
                  )
  loop
      update pa_all_organizations
      set inactive_date = trunc(sysdate)
      where organization_id = x_organization_id_child
      and  org_id = imp_rec.org_id --MOAC Changes: Bug 4363092: Removed nvl usage with org_id
      and   pa_org_use_type = 'EXPENDITURES'
      and inactive_date is null ; -- Bug Ref # 6367868
  end loop;

  --- Delete all rows from pa_cc_tp_schedule_line_lkp
     delete from pa_cc_tp_schedule_line_lkp;

  open c_get_all_orgs;
  loop
      fetch c_get_all_orgs into l_parent_org_id;
      exit when c_get_all_orgs%notfound;
      delete from pa_org_hierarchy_denorm
            where org_hierarchy_version_id = x_org_version_id
              and (child_organization_id = l_parent_org_id
               or parent_organization_id = l_parent_org_id);
  end loop;
  close c_get_all_orgs;

/* Bug#2643047 - call to restructure levels from pa_org_hierarchy_denorm table*/

   pa_org_utils.restructure_rpt_orgs_denorm(
                               x_org_version_id,
                               x_err_code ,
                               x_err_stage,
                               x_err_stack
         	               );
 Exception
 when others then
 x_err_code := SQLCODE;
 x_err_stage := SQLERRM;
 return;

End;


-----maintain_org_info_hist_bri created on HR_ORGANIZATION_INFORMATION
----- For update and insert in PA_ALL_ORGANIZATIO against BUG NO 1357522
procedure maintain_org_info_hist_bri
                   (x_organization_id           in      number  ,
                    x_org_information1          in      varchar2,
                    x_org_information_context   in      varchar2,
                    x_org_information2          in      varchar2,
                    x_err_code                  in out  NOCOPY number, --File.Sql.39 bug 4440895
                    x_err_stage                 in out  NOCOPY varchar2, --File.Sql.39 bug 4440895
                    x_err_stack                 in out  NOCOPY varchar2 ) is --File.Sql.39 bug 4440895


  v_org_structure_version_id   number;
  v_org_child_id               number;
  v_org_chk                    varchar2(60);
  v_start_org_id               number;

/*
Bug#2620151-Commented the old cursor and added new logic for the cursor check_org_exists

New Logic: Traverse from x_organization_id and get all the parents for this.
In this result, check for v_start_org_id, if present then it means that the org
x_organization_id is under v_start_org_id.

Earlier Logic: Traverse from v_start_org_id and get all the childs for this.
In this result, check for x_organization_id, if present then it means that the
org x_organization_id is under v_start_org_id.
*/

  cursor check_org_exists is
  (
   select se.organization_id_parent
   from   per_org_structure_elements se
   where  se.org_structure_version_id = v_org_structure_version_id
          and     se.organization_id_parent =
                                v_start_org_id
          connect by prior se.organization_id_parent =
	                        se.organization_id_child
          and org_structure_version_id = v_org_structure_version_id
          start with se.organization_id_child =
                                x_organization_id
          and org_structure_version_id = v_org_structure_version_id
  );

/* Commeneted the cursor below for bug#2620151, Added new cursor above
  cursor check_org_exists is
                (select    se.organization_id_child
                 from      per_org_structure_elements se
                 where     se.org_structure_version_id = v_org_structure_version_id
                   and     se.organization_id_child = x_organization_id ---made changes as Suggested
                 connect by prior se.organization_id_child =
                      se.organization_id_parent
                        and org_structure_version_id = v_org_structure_version_id
                      start with se.organization_id_parent =
                      v_start_org_id
                      and org_structure_version_id = v_org_structure_version_id );
*/

--- To populate pa_org_hierarchy_denorm
  cursor get_all_orgs is
 (SELECT x_organization_id
       FROM dual
     UNION ALL
     SELECT organization_id_parent
       FROM per_org_structure_elements
      WHERE org_structure_version_id = v_org_structure_version_id
 CONNECT BY PRIOR organization_id_parent= organization_id_child
        AND org_structure_version_id = v_org_structure_version_id
 START WITH organization_id_child = x_organization_id);

l_parent_org_id number;

Begin
   --- Delete all rows from pa_cc_tp_schedule_line_lkp
     delete from pa_cc_tp_schedule_line_lkp;

if   x_org_information1 = 'PA_PROJECT_ORG' AND
     x_org_information_context = 'CLASS' then
        if  x_org_information2 = 'Y' then

          ----- Means This Organization is being classified as
          ---- Projects Task / owning Organization and classification
          ---  is enabled. Now Loop theough all the records from
          ---  pa_implementations_all. And check that CUrrent Organization
          ---- Being changed is attached to an Organization structure which
          ---- is defined in Implementation as Project Structure.
          for imp_rec  in (select   proj_start_org_id, proj_org_structure_version_id,
                                    org_id
                           from     pa_implementations_all )
          loop
             v_start_org_id := imp_rec.proj_start_org_id;
             v_org_structure_version_id := imp_rec.proj_org_structure_version_id;
             ---- Check that Current Organization which is getting changed is below
             ---- The start organization specified for a Project Organization
             ---- Structure.
                IF(v_start_org_id <> x_organization_id) THEN --made changes as Suggested
               open check_org_exists;
               fetch check_org_exists into v_org_child_id;
                if check_org_exists%found then /* Added org is below the start project org */
                        insert into pa_all_organizations
                        (organization_id,
                         org_id,
                         pa_org_use_type)
                                (select x_organization_id,
                         imp_rec.org_id, 'PROJECTS'
                         from   sys.dual
                         where  not exists ( select    'X'
                         from      pa_all_organizations
                         where     organization_id = x_organization_id
                         and       org_id = imp_rec.org_id --MOAC Changes: Bug 4363092: Removed nvl usage with org_id
                         and       pa_org_use_type = 'PROJECTS' ));

                        if sql%rowcount = 0 then --- Means Row was not inserted as it was there
                                           ---- Earlier, IN This case set inactive_date to
                                           ---  NULL.
                           update    pa_all_organizations
                           set       inactive_date = null
                           where     organization_id = x_organization_id
                           and       org_id = imp_rec.org_id --MOAC Changes: Bug 4363092: Removed nvl usage with org_id
                           and       pa_org_use_type = 'PROJECTS' ;
                        end if;

                        open get_all_orgs;
                       loop
                            fetch get_all_orgs into l_parent_org_id;
                            exit when get_all_orgs%notfound;
                   pa_org_utils.CREATE_ORG_HIERARCHY_DENORM(p_parent_organization_id => l_parent_org_id
                                            , p_child_organization_id => x_organization_id
                                            , p_org_hierarchy_version_id => v_org_structure_version_id
                                            , p_pa_org_use_type => 'PROJECTS'
                                            , x_err_code        => x_err_code
                                            , x_err_stage       => x_err_stage
                                            , x_err_stack       => x_err_stack);
                       end loop;
                    close get_all_orgs;

                  end if;
                 close check_org_exists;
              ELSE
                ---- If Current Organization is Start Organizations then Record has to be
                ---- Created in PA_ALL_ORGANIZATIONS.
                   insert into pa_all_organizations
                        (organization_id,
                         org_id,
                         pa_org_use_type)
                        (select x_organization_id,
                         imp_rec.org_id, 'PROJECTS'
                        from   sys.dual
                                where  not exists ( select    'X'
                                      from      pa_all_organizations
                                      where     organization_id = x_organization_id
                                      and       org_id = imp_rec.org_id --MOAC Changes: Bug 4363092: Removed nvl usage with org_id
                                      and       pa_org_use_type = 'PROJECTS' ));
                        if sql%rowcount = 0 then --- Means Row was not inserted as it was there
                                           ---- Earlier, IN This case set inactive_date to
                                           ---  NULL.
                           update    pa_all_organizations
                           set       inactive_date = null
                           where     organization_id = x_organization_id
                           and       org_id = imp_rec.org_id --MOAC Changes: Bug 4363092: Removed nvl usage with org_id
                           and       pa_org_use_type = 'PROJECTS' ;
                        end if;

                    pa_org_utils.CREATE_ORG_HIERARCHY_DENORM ( p_parent_organization_id => v_start_org_id
                                            , p_child_organization_id => x_organization_id
                                            , p_org_hierarchy_version_id => v_org_structure_version_id
                                            , p_pa_org_use_type => 'PROJECTS'
                                            , x_err_code        => x_err_code
                                            , x_err_stage       => x_err_stage
                                            , x_err_stack       => x_err_stack);

             END IF;
                end loop;
        else
          for imp_rec  in (select   proj_start_org_id, proj_org_structure_version_id,
                                    org_id
                           from     pa_implementations_all )
          loop

                      update    pa_all_organizations
                      set       inactive_date = trunc(sysdate)
                      where     organization_id = x_organization_id
                      and       org_id = imp_rec.org_id --MOAC Changes: Bug 4363092: Removed nvl usage with org_id
                      and       pa_org_use_type = 'PROJECTS'
		      and       inactive_date is null; -- Bug Ref # 6367868

                     delete from pa_org_hierarchy_denorm
                     where child_organization_id = x_organization_id
                       and org_hierarchy_version_id = imp_rec.proj_org_structure_version_id
		       and pa_org_use_type = 'PROJECTS';  /* Bug#2643047 - Only PROJECTS records need to be deleted as we are checking
		                                          for Project task owning classification here */

          end loop;

        end if;
end if;
   ----- Check for Expenditure Organization Type starts here.
if   x_org_information1 = 'PA_EXPENDITURE_ORG' and
     x_org_information_context = 'CLASS' then

        if x_org_information2 = 'Y' then
          ----- Means This Organization is being classified as
          ---- Projects Expenditure owing  Organization and classification
          ---  is enabled. Now Loop theough all the records from
          ---  pa_implementations_all. And check that Current Organization
          ---- Being changed is attached to an Organization structure which
          ---- is defined in Implementation as Project Structure.
          for imp_rec  in (select   exp_start_org_id, exp_org_structure_version_id,
                                    org_id
                           from     pa_implementations_all )
          loop
             v_start_org_id := imp_rec.exp_start_org_id;
             v_org_structure_version_id := imp_rec.exp_org_structure_version_id;
             ---- Check that Current Organization which is getting changed is below
             ---- The start organization specified for a Expenditure Organization
             ---- Structure.
                 IF(v_start_org_id<>x_organization_id) THEN
                     open check_org_exists;
                     fetch check_org_exists into v_org_child_id;
                     if check_org_exists%found then /* Added org is below the start project org */
                         insert into pa_all_organizations
                                        (organization_id,
                                         org_id,
                                         pa_org_use_type)
                                         (select x_organization_id,
                                          imp_rec.org_id, 'EXPENDITURES'
                                          from   sys.dual
                                  where  not exists ( select    'X'
                                      from      pa_all_organizations
                                      where     organization_id = x_organization_id
                                      and       org_id = imp_rec.org_id --MOAC Changes: Bug 4363092: Removed nvl usage with org_id
                                      and       pa_org_use_type = 'EXPENDITURES' ));

                        if sql%rowcount = 0 then --- Means Row was not inserted as it was there
                                           ---- Earlier, IN This case set inactive_date to
                                           ---  NULL.
                                update    pa_all_organizations
                                set       inactive_date = null
                                where     organization_id = x_organization_id
                                and       org_id = imp_rec.org_id --MOAC Changes: Bug 4363092: Removed nvl usage with org_id
                                and       pa_org_use_type = 'EXPENDITURES' ;
                        end if;
                        open get_all_orgs;
                       loop
                            fetch get_all_orgs into l_parent_org_id;
                            exit when get_all_orgs%notfound;
                   pa_org_utils.CREATE_ORG_HIERARCHY_DENORM(p_parent_organization_id => l_parent_org_id
                                            , p_child_organization_id => x_organization_id
                                            , p_org_hierarchy_version_id => v_org_structure_version_id
                                            , p_pa_org_use_type => 'EXPENDITURES'
                                            , x_err_code        => x_err_code
                                            , x_err_stage       => x_err_stage
                                            , x_err_stack       => x_err_stack);
                       end loop;
                    close get_all_orgs;

                   end if;
                    close check_org_exists;
              ELSE
                ---- If Current Organization is Start Organizations then Record has to be
                ---- Created in PA_ALL_ORGANIZATIONS.
                   insert into pa_all_organizations
                        (organization_id,
                         org_id,
                         pa_org_use_type)
                        (select x_organization_id,
                         imp_rec.org_id, 'EXPENDITURES'
                        from   sys.dual
                                where  not exists ( select    'X'
                                      from      pa_all_organizations
                                      where     organization_id = x_organization_id
                                      and       org_id = imp_rec.org_id --MOAC Changes: Bug 4363092: Removed nvl usage with org_id
                                      and       pa_org_use_type = 'EXPENDITURES' ));
                        if sql%rowcount = 0 then --- Means Row was not inserted as it was there
                                           ---- Earlier, IN This case set inactive_date to
                                           ---  NULL.
                           update    pa_all_organizations
                           set       inactive_date = null
                           where     organization_id = x_organization_id
                           and       org_id = imp_rec.org_id--MOAC Changes: Bug 4363092: Removed nvl usage with org_id
                           and       pa_org_use_type = 'EXPENDITURES' ;
                        end if;

                    pa_org_utils.CREATE_ORG_HIERARCHY_DENORM ( p_parent_organization_id => v_start_org_id
                                            , p_child_organization_id => x_organization_id
                                            , p_org_hierarchy_version_id => v_org_structure_version_id
                                            , p_pa_org_use_type => 'EXPENDITURES'
                                            , x_err_code        => x_err_code
                                            , x_err_stage       => x_err_stage
                                            , x_err_stack       => x_err_stack);

             END IF;
              end loop;
        else
          for imp_rec  in (select   exp_start_org_id, exp_org_structure_version_id,
                                    org_id
                           from     pa_implementations_all )
          loop

                      update    pa_all_organizations
                      set       inactive_date = trunc(sysdate)
                      where     organization_id = x_organization_id
                      and       org_id = imp_rec.org_id --MOAC Changes: Bug 4363092: Removed nvl usage with org_id
                      and       pa_org_use_type = 'EXPENDITURES'
		      and       inactive_date is null ; -- Bug Ref # 6367868

                     delete from pa_org_hierarchy_denorm
                     where child_organization_id = x_organization_id
                       and org_hierarchy_version_id = imp_rec.exp_org_structure_version_id
		        and pa_org_use_type = 'EXPENDITURES'; /* Bug#2643047 -  Only EXPENDITURES records need to be deleted as we
			                                 are checking for Project/expenditure owning classification here */

          end loop;

        end if;
  end if;
EXCEPTION
         when others then
           x_err_code := SQLCODE;
           x_err_stage := SQLERRM;
           return;
end;
-------maintain_org_info_hist_bri  ends

Procedure Start_Org_Changed   (x_old_org_version_id in number,
                               x_new_org_version_id in number,
                               x_old_start_org_id in number,
                               x_new_start_org_id in number,
                               x_org_use_type in varchar2,
                               x_org_id in number,
                               x_err_code in out NOCOPY number, --File.Sql.39 bug 4440895
                               x_err_stage in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                               x_err_stack in out NOCOPY varchar2)  --File.Sql.39 bug 4440895
IS

CURSOR cur_all_old_org IS
        SELECT  se.organization_id_child organization_id
                FROM    per_org_structure_elements se
                WHERE   org_structure_version_id =  x_old_org_version_id
                CONNECT BY PRIOR se.organization_id_child
                        = se.organization_id_parent
                AND     org_structure_version_id = x_old_org_version_id
                START WITH se.organization_id_parent = x_old_start_org_id
                AND     org_structure_version_id = x_old_org_version_id
        UNION
                SELECT  x_old_start_org_id FROM Sys.dual ;

CURSOR cur_proj_new_org IS
        SELECT  se.organization_id_child organization_id
                FROM    per_org_structure_elements se
                WHERE   org_structure_version_id =  x_new_org_version_id
                AND     EXISTS (select 'X'
                        from hr_organization_information info
                        where info.organization_id = se.organization_id_child
                        and   info.org_information1 = 'PA_PROJECT_ORG'
                        and   info.org_information_context||'' = 'CLASS'
                        and   info.org_information2 = 'Y')
                CONNECT BY PRIOR se.organization_id_child
                        = se.organization_id_parent
                AND     org_structure_version_id = x_new_org_version_id
                START WITH se.organization_id_parent = x_new_start_org_id
                AND     org_structure_version_id = x_new_org_version_id
        UNION
                SELECT  x_new_start_org_id FROM Sys.dual -- Added exists clause for Bug# 1650520
                WHERE   EXISTS (select 'X'
                        from hr_organization_information info
                        where info.org_information1 = 'PA_PROJECT_ORG'
                        and   info.org_information_context||'' = 'CLASS'
                        and   info.org_information2 = 'Y'
                        and   info.organization_id = x_new_start_org_id);


CURSOR cur_exp_new_org IS
        SELECT  se.organization_id_child organization_id
                FROM    per_org_structure_elements se
                WHERE   org_structure_version_id =  x_new_org_version_id
                AND     EXISTS (select 'X'
                        from hr_organization_information info
                        where info.organization_id = se.organization_id_child
                        and   info.org_information1 = 'PA_EXPENDITURE_ORG'
                        and   info.org_information_context||'' = 'CLASS'
                        and   info.org_information2 = 'Y')
                CONNECT BY PRIOR se.organization_id_child
                        = se.organization_id_parent
                AND     org_structure_version_id = x_new_org_version_id
                START WITH se.organization_id_parent = x_new_start_org_id
                AND     org_structure_version_id = x_new_org_version_id
        UNION
                SELECT  x_new_start_org_id FROM Sys.dual
                 where  EXISTS (select 'X'  /* Made changes for BUG 1180635*/
                        from hr_organization_information info
                        where info.org_information1 = 'PA_EXPENDITURE_ORG'
                        and   info.org_information_context||'' = 'CLASS'
                        and   info.org_information2 = 'Y'
                        and   info.organization_id = x_new_start_org_id);


rec_all_old_org         cur_all_old_org%ROWTYPE;
rec_exp_new_org         cur_exp_new_org%ROWTYPE;
rec_proj_new_org        cur_proj_new_org%ROWTYPE;

BEGIN
  x_err_code := 0;
  x_err_stack := x_err_stack || 'Start_Org_Changed';

/* When either structure version id OR start organization id changes */

IF ( (NVL(x_old_org_version_id,-99) <> x_new_org_version_id )
                        OR
     (NVL(x_old_start_org_id,-99) <> x_new_start_org_id ) )  THEN

     FOR rec_all_old_org in cur_all_old_org LOOP

        /* Update all Organizations (Projects or Expenditures)
           in the old hierarchy with inactive date as Sysdate.
           Union is to include the start organization id in the update */

        UPDATE pa_all_organizations
        SET    Inactive_Date    = TRUNC(SYSDATE)
        WHERE  Pa_Org_Use_Type  = x_org_use_type
        AND    Org_id = x_Org_id --MOAC Changes: Bug 4363092: Removed nvl usage with org_id
        AND    Organization_id  = rec_all_old_org.organization_id
	and inactive_date is null ; -- Bug Ref # 6367868

        /* In case there are no corresponding records for the new
           Organization hierarchy in the Pa_all_Organizations, then,
           create these records in the Pa_All_Organizations
           with Inactive_Date as SYSDATE */

        IF SQL%NOTFOUND THEN
                INSERT INTO  Pa_All_Organizations
                       (organization_id,
                        org_id,
                        pa_org_use_type,
                        inactive_date)
                 VALUES
                       (rec_all_old_org.organization_id,
                        x_org_id,
                        x_org_use_type,
                        TRUNC(SYSDATE));
       END IF;

     END LOOP;

     IF x_org_use_type = 'EXPENDITURES' THEN

     FOR rec_exp_new_org IN cur_exp_new_org LOOP

       /* Update all Organizations (Expenditures)
          in the new hierarchy with inactive date as NULL.
          Union is to include the start organization id in the update */

        UPDATE pa_all_organizations
        SET    Inactive_Date = NULL
        WHERE  Pa_Org_Use_Type = x_org_use_type
        AND    Org_id = x_Org_id --MOAC Changes: Bug 4363092: Removed nvl usage with org_id
        AND    Organization_id = rec_exp_new_org.organization_id;

        /* In case there are no corresponding records for the new
           Organization hierarchy in the Pa_all_Organizations, then,
           create these records in the Pa_All_Organizations
           with Inactive_Date as NULL */

        IF SQL%NOTFOUND THEN
                INSERT INTO  Pa_All_Organizations
                       (organization_id,
                        org_id,
                        pa_org_use_type,
                        inactive_date)
                VALUES
                       (rec_exp_new_org.organization_id,
                        x_org_id,
                        x_org_use_type,
                        NULL);
       END IF;

     END LOOP;

     END IF; /* End of IF for org_use_type = 'EXPENDITURES' */


     IF x_org_use_type = 'PROJECTS' THEN

     FOR rec_proj_new_org IN cur_proj_new_org LOOP

       /* Update all Organizations (Projects)
          in the new hierarchy with inactive date as NULL.
          Union is to include the start organization id in the update */

        UPDATE pa_all_organizations
        SET    Inactive_Date = NULL
        WHERE  Pa_Org_Use_Type = x_org_use_type
        AND    Org_id = x_Org_id --MOAC Changes: Bug 4363092: Removed nvl usage with org_id
        AND    Organization_id = rec_proj_new_org.organization_id;

        /* In case there are no corresponding records for the new
           Organization hierarchy in the Pa_all_Organizations, then,
           create these records in the Pa_All_Organizations
           with Inactive_Date as NULL */

        IF SQL%NOTFOUND THEN
                INSERT INTO  Pa_All_Organizations
                       (organization_id,
                        org_id,
                        pa_org_use_type,
                        inactive_date)
                VALUES
                       (rec_proj_new_org.organization_id,
                        x_org_id,
                        x_org_use_type,
                        NULL);
       END IF;

     END LOOP;

     END IF; /* End of IF for org_use_type = 'PROJECTS' */

END IF;

Exception
 when others then
 x_err_code := SQLCODE;
 x_err_stage := SQLERRM;
 return;

END Start_Org_Changed;

PROCEDURE Create_org_hierarchy_denorm(p_parent_organization_id  in number,
                                      p_child_organization_id   in number,
                                      p_org_hierarchy_version_id in number,
                                      p_pa_org_use_type  in varchar2,
                                      x_err_code         in out NOCOPY number, --File.Sql.39 bug 4440895
                                      x_err_stage        in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                                      x_err_stack        in out NOCOPY varchar2) IS --File.Sql.39 bug 4440895
  old_stack             varchar2(4000);
Begin

  x_err_code := 0;
  old_stack := x_err_stack;
  x_err_stack := x_err_stack || 'Create_org_hierarchy_denorm';
/*
dbms_output.put_line('in create');
dbms_output.put_line('p_pa_org_use_type ='||p_pa_org_use_type);
dbms_output.put_line('p_parent_organization_id ='||p_parent_organization_id);
dbms_output.put_line('p_child_organization_id ='||p_child_organization_id);
dbms_output.put_line('p_org_hierarchy_version_id ='||p_org_hierarchy_version_id);
*/



     INSERT INTO PA_ORG_HIERARCHY_DENORM ( parent_organization_id
                                        , child_organization_id
                                        , org_hierarchy_version_id
                                        , pa_org_use_type
                                        , creation_date
                                        , created_by
                                        , last_update_date
                                        , last_updated_by
                                        , last_update_login
                                          )
                              SELECT  p_parent_organization_id
                                    , p_child_organization_id
                                    , p_org_hierarchy_version_id
                                    , p_pa_org_use_type
                                    , sysdate
,1--                                    , TO_NUMBER(FND_PROFILE.VALUE('USER_ID'))
                                    , sysdate
,1--                                    , TO_NUMBER(FND_PROFILE.VALUE('USER_ID'))
,1--                                    , TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'))
                               from dual
                               where not exists
                                    (select 'Y'
                                    from pa_org_hierarchy_denorm
                                   where pa_org_use_type = p_pa_org_use_type
                                     and parent_organization_id = p_parent_organization_id
                                     and child_organization_id = p_child_organization_id
                                     and org_hierarchy_version_id = p_org_hierarchy_version_id);

x_err_stack := old_stack;
Exception
 when others then
 x_err_code := SQLCODE;
 x_err_stage := SQLERRM;
 return;

End;

-- Start CC Change

/* Take following heirarchy for understanding this piece of logic
   for the use_type = TP_SCHEDULE

Assume that following is the hierarchy:
         org1
          / \
       org2  org3 -> start org in pa_implementations
             /  \
           org5  org6
            |
          org7



In this example the start org defined in the pa_implementations is org3.

For the TP_SCHEDULE purpose the hierarchy is always populated from the start
of the hierarcy rather than the start org mentioned in the pa_implementations.

The aim of this procedure is to populate pa_org_denorm table with following data.

parent      child  p_level   c_level

org1        org1   1         1
org1        org2   1         2
org1        org3   1         2
org2        org2   2         2
org3        org3   2         2
org3        org5   2         3
org3        org6   2         3
org5        org5   3         3
org5        org7   3         4

*/

-- CC Change Added the below procedure.
PROCEDURE Create_org_hier_denorm_levels(p_parent_organization_id  in number,
                                      p_child_organization_id   in number,
                                      p_org_hierarchy_version_id in number,
                                      p_pa_org_use_type  in varchar2,
                                      p_parent_level in number,
                                      p_child_level in number,
                                      x_err_code         in out NOCOPY number, --File.Sql.39 bug 4440895
                                      x_err_stage        in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                                      x_err_stack        in out NOCOPY varchar2) IS --File.Sql.39 bug 4440895
  old_stack             varchar2(4000);
Begin

  x_err_code := 0;
  old_stack := x_err_stack;
  x_err_stack := x_err_stack || 'Create_org_hierarchy_denorm';
/*
dbms_output.put_line('in create');
dbms_output.put_line('p_pa_org_use_type ='||p_pa_org_use_type);
dbms_output.put_line('p_parent_organization_id ='||p_parent_organization_id);
dbms_output.put_line('p_child_organization_id ='||p_child_organization_id);
dbms_output.put_line('p_org_hierarchy_version_id ='||p_org_hierarchy_version_id);
*/



     INSERT INTO pa_org_hierarchy_denorm ( parent_organization_id
                                        , child_organization_id
                                        , org_hierarchy_version_id
                                        , pa_org_use_type
                                        , creation_date
                                        , created_by
                                        , last_update_date
                                        , last_updated_by
                                        , last_update_login
                                        , parent_level
                                        , child_level
                                          )
                              SELECT  p_parent_organization_id
                                    , p_child_organization_id
                                    , p_org_hierarchy_version_id
                                    , p_pa_org_use_type
                                    , sysdate
,1--                                    , TO_NUMBER(FND_PROFILE.VALUE('USER_ID'))
                                    , sysdate
,1--                                    , TO_NUMBER(FND_PROFILE.VALUE('USER_ID'))
,1--                                    , TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'))
                                        , p_parent_level
                                        , p_child_level
                               from dual
                               where not exists
                                    (select 'Y'
                                    from pa_org_hierarchy_denorm
                                   where pa_org_use_type = p_pa_org_use_type
                                     and parent_organization_id = p_parent_organization_id
                                     and child_organization_id = p_child_organization_id
                                     and org_hierarchy_version_id = p_org_hierarchy_version_id);

x_err_stack := old_stack;
Exception
 when others then
 x_err_code := SQLCODE;
 x_err_stage := SQLERRM;
 return;

End;

-- End   CC Change
--
-- Created by Ranga Iyengar
-- Dated : 02-NOV-00
-- PROCEDURE
--
-- populates org hierarchy denorm for reporting type of organizations
--
-- This Procedure inserts records into pa_org_hierarchy_denorm
-- with parent level and child levels for reporting type of
-- organizations
PROCEDURE create_reporting_org
                          ( p_parent_organization_id    IN NUMBER
                           ,p_child_organization_id     IN NUMBER
                           ,p_org_hierarchy_version_id  IN NUMBER
                           ,p_pa_org_use_type           IN VARCHAR2
                           ,p_parent_org_level          IN NUMBER
                           ,p_child_org_level           IN NUMBER
                           ,p_org_id                    IN NUMBER
                           ,x_err_code                  IN OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                           ,x_err_stage                 IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                           ,x_err_stack                 IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                          ) IS
    old_stack    VARCHAR2(2000);
BEGIN

  x_err_code := 0;
  old_stack := x_err_stack;
  x_err_stack := x_err_stack || 'create_reporting_org';
     --r_msg('inserting into pa_org_hierarchy_denorm');
     INSERT INTO pa_org_hierarchy_denorm
                                   ( parent_organization_id
                                   , child_organization_id
                                   , org_hierarchy_version_id
                                   , pa_org_use_type
                                   , creation_date
                                   , created_by
                                   , last_update_date
                                   , last_updated_by
                                   , last_update_login
                                   , parent_level
                                   , child_level
                                   , org_id
                                    )
                              SELECT  p_parent_organization_id
                                   , p_child_organization_id
                                   , p_org_hierarchy_version_id
                                   , p_pa_org_use_type
                                   , sysdate
                                   , nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),1)
                                   , sysdate
                                   , nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),1)
                                   , nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),1)
                                   , p_parent_org_level
                                   , p_child_org_level
                                   , p_org_id
                               from dual
                               where not exists
                                (select 'Y'
                                 from pa_org_hierarchy_denorm
                                where pa_org_use_type = p_pa_org_use_type
                 and parent_organization_id = p_parent_organization_id
                 and child_organization_id = p_child_organization_id
                 and org_hierarchy_version_id = p_org_hierarchy_version_id
                 and nvl(org_id, -99) = nvl(p_org_id, -99));  /* 2976953 Added nvl condition for org_id */
            IF SQL%FOUND THEN
               --r_msg('row inserted');
                null;
            else
               --r_msg('not inserted');
                null;
            end if;
 x_err_stack := old_stack;

EXCEPTION
        when others then
                x_err_code := SQLCODE;
                x_err_stage := SQLERRM;
       --r_msg('could not insert'||x_err_code||x_err_stage);
          return;
END create_reporting_org;


-- This procedure populates parent level and child level for the
-- reporting organizations in pa org hierarchy denorm entity
PROCEDURE populate_org_levels( P_org_version_id          IN NUMBER
                              , P_organization_id_parent IN NUMBER
                              , P_organization_id_child  IN NUMBER
                              , P_org_level              IN NUMBER
                              , P_org_max_level          IN NUMBER
                              , P_org_id                 IN NUMBER
                              , P_start_org_id           IN NUMBER  -- added this to fix bug : 1619922
                              , x_err_code               IN OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                              , x_err_stage              IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                              , x_err_stack              IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                              ) IS


  v_start_org_id number;
  v_org_child_id number;
  v_parent_org_id number;
  v_plevel  number;
  v_clevel  number;
  old_stack  varchar2(2000);
  v_parent_org_level  number;

--- logic to populate hierarchy denorm
--  get all the parent organization for the child
--  example 200p - 205c,201p-205c,202p-205c,203p-205c,204p-205c,205p-205c
--  where p is parent org and c is the child orgs
  cursor get_all_orgs is
 SELECT P_organization_id_parent
    FROM dual
     UNION
  (SELECT distinct organization_id_parent
    FROM per_org_structure_elements
   WHERE org_structure_version_id = P_org_version_id
 CONNECT BY PRIOR organization_id_parent= organization_id_child
     AND org_structure_version_id = P_org_version_id
 START WITH organization_id_child = P_organization_id_parent
       AND org_structure_version_id = P_org_version_id
/* ---- The following query is added to fix the bug : 1654453 ---
 ---- since the start organization id defined in per_org_structure_elements
 ---- may be different from the start_organization_id set up in pa_implementations
 ---- so always the reporting hierarchy is formed based on pa_implementations
 ---- start_organization_id */
 MINUS
  SELECT distinct organization_id_parent
    FROM per_org_structure_elements
   WHERE org_structure_version_id = P_org_version_id
 CONNECT BY PRIOR organization_id_parent= organization_id_child
     AND org_structure_version_id = P_org_version_id
 START WITH organization_id_child = P_start_org_id
       AND org_structure_version_id = P_org_version_id)
 UNION
 (SELECT P_organization_id_child from dual);

BEGIN

  x_err_code := 0;
  old_stack := x_err_stack;
  x_err_stack := x_err_stack || 'populate_org_levels';

 /* For all operating units where the Reporting Org structure
    specified is same as the changed Org structure */


 -------- for pa_org_hierarchy_denorm
    open get_all_orgs;
    loop
    fetch get_all_orgs into v_parent_org_id;
    exit when get_all_orgs%notfound;
/*
      -- get the maximum level of the parent while child level is
      -- is calculated based on the formula maxlevel - level + 1
           SELECT  max(parent_level) into v_plevel
           FROM    pa_org_hierarchy_denorm
           WHERE   org_hierarchy_version_id = P_org_version_id
           and   pa_org_use_type = 'REPORTING'
           and   parent_organization_id =  v_parent_org_id
           and   org_id = p_org_id;

           if v_plevel is null then
             SELECT  max(child_level) into v_plevel
             FROM    pa_org_hierarchy_denorm
             WHERE   org_hierarchy_version_id = P_org_version_id
             and   pa_org_use_type = 'REPORTING'
             and   child_organization_id =  v_parent_org_id
             and   org_id = p_org_id;
          end if;

           if nvl(v_plevel,0) = 0  then
              v_plevel := P_org_max_level - P_org_level + 2;
           end if;

          -- if v_clevel is null then
              v_clevel := P_org_max_level - P_org_level + 1;
           -- end if;


           -- where both parent and child orgs are same then level of
           -- parent org and level of child orgs are same

           if P_organization_id_child = v_parent_org_id then
              v_plevel := v_clevel;
           end if;


          -- the above condition is commented out  and added new condition to fix the bug : 1619922
           if (P_organization_id_child = v_parent_org_id) and (P_organization_id_child <> P_start_org_id) then
              v_plevel := v_clevel;
           elsif (P_organization_id_child = v_parent_org_id) and (P_organization_id_child = P_start_org_id) then
              v_clevel := v_plevel;
           end if;
*/

  ----------- Added the Following lines to fix the bug : 1654453 --------------
     -- set the child level based on the formula
     v_clevel := P_org_max_level - P_org_level + 1;


     -- set the parent level based on the following condition
     -- get the parent organization level from the per_org_structure_elements
     -- then apply the formula
       SELECT  max(level)
        INTO  v_parent_org_level
         FROM    per_org_structure_elements
        WHERE    org_structure_version_id =  P_org_version_id
        AND     organization_id_parent =  v_parent_org_id
        CONNECT BY PRIOR organization_id_child = organization_id_parent
        AND  org_structure_version_id = P_org_version_id
        START WITH organization_id_parent = P_start_org_id
        AND   org_structure_version_id = P_org_version_id;
     If v_parent_org_level  is NULL then

       SELECT  max(level)
        INTO v_parent_org_level
         FROM    per_org_structure_elements
        WHERE    org_structure_version_id =  P_org_version_id
        AND     organization_id_child =  v_parent_org_id
        CONNECT BY PRIOR organization_id_child = organization_id_parent
        AND  org_structure_version_id = P_org_version_id
        START WITH organization_id_parent = P_start_org_id
        AND   org_structure_version_id = P_org_version_id;



        --- set the org level based on the formula
        v_plevel := P_org_max_level - v_parent_org_level + 1;

     Else

        v_plevel := P_org_max_level - v_parent_org_level + 2;

     End if;

    If P_organization_id_child = v_parent_org_id then
          v_clevel := v_plevel;
    End if;
--r_msg('parent'||v_parent_org_id||'child'||P_organization_id_child||'plevel'||v_plevel||'clevel '||v_clevel);

 ---------------------------------end of bug fix---------------------------


       create_reporting_org(
              p_parent_organization_id   => v_parent_org_id
             ,p_child_organization_id    =>P_organization_id_child
             ,p_org_hierarchy_version_id => P_org_version_id
             ,p_org_id                   => p_org_id
             ,p_pa_org_use_type          => 'REPORTING'
             ,P_parent_org_level         => v_plevel
             ,p_child_org_level          => v_clevel
             ,x_err_code                 => x_err_code
             ,x_err_stage                => x_err_stage
             ,x_err_stack                => x_err_stack
             );

     v_plevel := null;
     v_clevel := null;
     end loop;
     close get_all_orgs;

     x_err_stack := old_stack;
EXCEPTION
        when others then
                x_err_code := SQLCODE;
                x_err_stage := SQLERRM;
                 --r_msg('error in populate org level'||x_err_code||x_err_stage);
                return;

END populate_org_levels;


-- This Procedure is called from trigger org_maintn_hist_bri
PROCEDURE populate_hierarchy_denorm
                             ( p_org_version_id         IN NUMBER
                               ,p_organization_id_parent IN  NUMBER
                               ,p_organization_id_child  IN NUMBER
                               ,x_err_code               IN OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                               ,x_err_stage              IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                               ,x_err_stack              IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                             ) IS
        v_org_version_id number;
        v_child_org_id number;
        v_parent_org_id number;
        v_start_org_id number;
        v_org_level  number;
        v_org_id   number;
        v_maximumlevel number;
        v_dummy_child_id number;
        old_stack   varchar2(2000);
        v_success_flag     Number;
        dummy_level number := 1;
-- get all orgs structure from per_org-structure_elemetns for
-- given version- parameter and start org (from the pa implemetnaiton)
cursor get_all_orgs(version_id NUMBER,start_org_id NUMBER)  is
   SELECT  dummy_level plevel             --- This query is added to fix bug : 1619922
          ,start_org_id organization_id_parent
          ,start_org_id organization_id_child
    FROM   dual
   UNION
     SELECT  distinct
           level plevel
           ,organization_id_parent
           ,organization_id_child
     FROM  per_org_structure_elements
    WHERE org_structure_version_id = version_id
 CONNECT BY PRIOR  organization_id_child =  organization_id_parent
              and org_structure_version_id = version_id
 START WITH  organization_id_parent = start_org_id
         and org_structure_version_id = version_id
 ORDER  by 1;

-- check whether the org exist in the given pa implementations ou
-- and falls within the start org
 cursor check_org_exists(version_id NUMBER,start_org_id NUMBER) is
  (SELECT  organization_id_child
   FROM    per_org_structure_elements
   WHERE   org_structure_version_id = version_id
  CONNECT BY PRIOR  organization_id_child = organization_id_parent
               and org_structure_version_id = version_id
  START WITH   organization_id_parent = start_org_id
           and org_structure_version_id = version_id
    UNION
  SELECT   v_start_org_id
  FROM     sys.dual)
   INTERSECT
  (SELECT  p_organization_id_parent
   FROM    sys.dual );


BEGIN


  x_err_code := 0;
  old_stack := x_err_stack;
  x_err_stack := x_err_stack || 'populate_hierarchy_denorm';

  --- Delete all rows from pa_cc_tp_schedule_line_lkp
     delete from pa_cc_tp_schedule_line_lkp;

 -------  Acquire a lock before processing ----------------

  if (pa_debug.acquire_user_lock('FCLOCK:'||to_char(p_org_version_id)) = 0)
     and (pa_debug.acquire_user_lock('ACLOCK:'||to_char(p_org_version_id)) = 0) then

     --dbms_output.put_line('acquired fclock and aclock');

     for imp_rec in ( select org_id, start_organization_id
                   from   pa_implementations_all imp
                   where  org_structure_version_id = p_org_version_id
                  )
    LOOP
    v_start_org_id := imp_rec.start_organization_id;
    v_org_id       := imp_rec.org_id;
 ------ blow off the records  and recreate with parent and child level-----
    --r_msg('startorg'||v_start_org_id||'OU'||v_org_id);
    open check_org_exists(p_org_version_id,v_start_org_id);
    fetch check_org_exists into v_dummy_child_id;
      if check_org_exists%found then
       --r_msg('exists');
        Begin
            DELETE  from pa_org_hierarchy_denorm
            WHERE   pa_org_use_type = 'REPORTING'
            and   org_hierarchy_version_id = p_org_version_id
            and   nvl(org_id, -99) = nvl(v_org_id, -99);    /* 2976953-Added the nvl condition for org_id */
           if sql%rowcount > 0 then
              NULL;
              --r_msg('deleted');
           end if;
        Exception
             when others then
                  null;
        End;
      end if;
    close check_org_exists;

---------------------------------------------------------------------------
 /* For all operating units where the Reporting Org structure
    specified is same as the changed Org structure */

-- get maximum  level for the set up
        SELECT  max(level) into v_maximumlevel
        FROM  per_org_structure_elements
        WHERE  org_structure_version_id = p_org_version_id
        CONNECT BY PRIOR  organization_id_child =  organization_id_parent
               and org_structure_version_id = p_org_version_id
        START WITH  organization_id_parent = v_start_org_id
               and org_structure_version_id = p_org_version_id;

 -------- for pa_org_hierarchy_denorm ---------------------
       open get_all_orgs(p_org_version_id,v_start_org_id);
       loop
           fetch get_all_orgs  into v_org_level,v_parent_org_id,v_child_org_id;
           exit when get_all_orgs%notfound;
          --r_msg('version'||p_org_version_id||'startorg'||v_start_org_id||'OU'||v_org_id);
          --r_msg('calling populate org levels');

           populate_org_levels (
                 P_org_version_id         => p_org_version_id,
                 P_organization_id_parent => v_parent_org_id,
                 P_organization_id_child  => v_child_org_id,
                 P_org_level              => v_org_level,
                 P_org_max_level          => v_maximumlevel,
                 P_org_id                 => v_org_id,
                 P_start_org_id           => v_start_org_id,
                 x_err_code               => x_err_code,
                 x_err_stage              => x_err_stage ,
                 x_err_stack              => x_err_stack
                );

       end loop;
       close get_all_orgs;

 END LOOP;  ------ end of imp loop

     ------------- Release the Lock --------------
       if (pa_debug.release_user_lock('FCLOCK:'||to_char(p_org_version_id)) = 0)
         and  (pa_debug.release_user_lock('ACLOCK:'||to_char(p_org_version_id)) = 0) then
          --dbms_output.put_line('org version '||p_org_version_id ||' is lock released');
          --r_msg('Releasing the lock on project ...');
          null;
       end if;

     --------------------------------------------

else -- not acquired the lock so exit and  set the return status to error
            --x_return_status := FND_API.G_SET_RET_STS_ERROR;
            x_err_stage     := 'Unable to Acqurie Lock on FORCASTING';
            --dbms_output.put_line('org version '||p_org_version_id ||' is locked');
end if;

  x_err_stack := old_stack;

EXCEPTION
        when others then
                v_success_flag := pa_debug.release_user_lock('FCLOCK:'||to_char(p_org_version_id));
                v_success_flag := pa_debug.release_user_lock('ACLOCK:'||to_char(p_org_version_id));
                x_err_code := SQLCODE;
                x_err_stage := SQLERRM;
               --r_msg('exception raised in outer'||x_err_code||x_err_stage);
                return;
END populate_hierarchy_denorm ;


PROCEDURE Check_Org_In_OrgHierarchy(
                p_organization_id  IN PA_ORG_HIERARCHY_DENORM.parent_organization_id%TYPE,
                p_org_structure_version_id IN PA_ORG_HIERARCHY_DENORM.org_hierarchy_version_id%TYPE,
                p_org_structure_type IN PA_ORG_HIERARCHY_DENORM.pa_org_use_type%TYPE,
                x_return_status        OUT     NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
                x_error_message_code   OUT     NOCOPY VARCHAR2)  --File.Sql.39 bug 4440895
 IS

 l_exist VARCHAR2(1):= null;

 BEGIN

    pa_debug.init_err_stack ('pa_org_utils.Check_Org_In_OrgHierarchy');

    select 'X' into l_exist
    from pa_org_hierarchy_denorm
    where parent_organization_id = p_organization_id
    and org_hierarchy_version_id = p_org_structure_version_id
    and pa_org_use_type = p_org_structure_type
    and rownum = 1;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    pa_debug.reset_err_stack;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_error_message_code := 'PA_ORG_NOT_IN_ORGHIER';

  WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg
           (p_pkg_name => 'PA_ORG_UTILS',
            p_procedure_name => pa_debug.g_err_stack );
            x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   RAISE;
END Check_Org_In_OrgHierarchy;

PROCEDURE Check_Org_Type(
                p_organization_id  IN PA_ORG_HIERARCHY_DENORM.parent_organization_id%TYPE,
                p_org_structure_type IN PA_ORG_HIERARCHY_DENORM.pa_org_use_type%TYPE,
                x_return_status        OUT     NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
                x_error_message_code   OUT     NOCOPY VARCHAR2)  --File.Sql.39 bug 4440895
 IS

 l_exist VARCHAR2(1):= null;

 BEGIN

    pa_debug.init_err_stack ('pa_org_utils.Check_Org_Type');

    select 'X' into l_exist
    from pa_org_hierarchy_denorm
    where parent_organization_id = p_organization_id
    and pa_org_use_type = p_org_structure_type
    and rownum = 1;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    pa_debug.reset_err_stack;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     IF p_org_structure_type = 'EXPENDITURES' THEN
       x_error_message_code := 'PA_NOT_EXP_ORG';
     ELSE
       x_error_message_code := 'PA_NOT_PROJ_ORG';
     END IF;

  WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg
           (p_pkg_name => 'PA_ORG_UTILS',
            p_procedure_name => pa_debug.g_err_stack );
            x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   RAISE;
END Check_Org_Type;


PROCEDURE Check_OrgHierarchy_Type(
                p_org_structure_version_id IN PA_ORG_HIERARCHY_DENORM.org_hierarchy_version_id%TYPE,
                p_org_structure_type IN PA_ORG_HIERARCHY_DENORM.pa_org_use_type%TYPE,
                x_return_status        OUT     NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
                x_error_message_code   OUT     NOCOPY VARCHAR2)  --File.Sql.39 bug 4440895
 IS

 l_exist VARCHAR2(1):= null;

 BEGIN

    pa_debug.init_err_stack ('pa_org_utils.Check_OrgHierarchy_Type');

    select 'X' into l_exist
    from pa_org_hierarchy_denorm
    where org_hierarchy_version_id = p_org_structure_version_id
    and pa_org_use_type = p_org_structure_type
    and rownum = 1;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    pa_debug.reset_err_stack;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     IF p_org_structure_type = 'EXPENDITURES' THEN
       x_error_message_code := 'PA_NOT_EXP_ORGHIER';
     ELSE
       x_error_message_code := 'PA_NOT_PROJ_ORGHIER';
     END IF;

  WHEN OTHERS THEN
      fnd_msg_pub.add_exc_msg
           (p_pkg_name => 'PA_ORG_UTILS',
            p_procedure_name => pa_debug.g_err_stack );
            x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
   RAISE;
END Check_OrgHierarchy_Type;


--
-- Procedure
--
-- Created by P Bandla
-- Dated : 06-DEC-2000
--
--
PROCEDURE Populate_Org_Hier_Denorm(
   x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_data       OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
   cursor org_version is
        SELECT distinct
               imp.org_structure_version_id version_id
              ,imp.start_organization_id  start_org_id
        FROM   pa_implementations_all imp,
               per_org_structure_elements posg
        WHERE  posg.org_structure_version_id = imp.org_structure_version_id;

        v_err_code               NUMBER;
        v_err_stack              VARCHAR2(200);
        v_org_version_id         NUMBER;
        v_organization_id_parent NUMBER;
        v_organization_id_child  NUMBER;
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   FOR i IN org_version LOOP
         v_org_version_id         := i.version_id;
         v_organization_id_parent := i.start_org_id;
         v_organization_id_child  := 1;

         pa_org_utils.populate_hierarchy_denorm(
                p_org_version_id          => v_org_version_id
                ,p_organization_id_parent => v_organization_id_parent
                ,p_organization_id_child  => v_organization_id_child
                ,x_err_code               => v_err_code
                ,x_err_stage              => x_msg_data
                ,x_err_stack              => v_err_stack);
     END LOOP;
EXCEPTION
     WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       v_err_code := SQLCODE;
       x_msg_data := SQLERRM;
       raise;
END  Populate_Org_Hier_Denorm;

PROCEDURE POPULATE_HIERARCHY_DENORM2
          (p_org_version_id         IN NUMBER
          ,p_organization_id_parent IN  NUMBER
          ,p_organization_id_child  IN NUMBER
          ,p_org_id                 IN NUMBER
          ,x_err_code               IN OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_err_stage              IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_err_stack              IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ) IS

v_max_level NUMBER;
old_stack   VARCHAR2(2000);
v_success_flag     NUMBER;

/* Take following heirarchy for understanding this piece of logic
         org1
          / \
       org2  org3 -> start org in pa_implementations
       /     /  \
     org4  org5  org6
            |     /   \
          org7  org8  org9
                        |
                      org10
in this example p_organization_id_parent = org3.
The aim of this package is to populate pa_org_denorm table with following data.
parent      child  p_level   c_level
org3        org5   4         3
org3        org6   4         3
org3        org7   4         2
org3        org8   4         2
org3        org9   4         2
org3       org10   4         1
org5       org7    3         2
org6       org8    3         2
org6       org9    3         2
org6       org10   3         1
org9       org10   2         1
org3       org3    4         4
org5       org5    3         3
org6       org6    3         3
org7       org7    2         2
org8       org8    2         2
org9       org9    2         2
org10      org10   1         1
*/

/* this cursor will select all parents in the hierarchy below p_organization_id_parent
   including p_organization_id_parent. This cursor will not select leaf nodes
   for p_organization_id_parent = org3 it will return org3, org5,org6, org9 */

CURSOR all_parents (max_level number) IS
SELECT distinct organization_id_parent
,(max_level - level + 1) rev_level
FROM per_org_structure_elements a
WHERE a.org_structure_version_id = p_org_version_id
CONNECT BY PRIOR a.organization_id_child = a.organization_id_parent
AND a.org_structure_version_id = p_org_version_id
START WITH a.organization_id_parent = p_organization_id_parent
AND a.org_structure_version_id = p_org_version_id
ORDER by rev_level desc;

BEGIN

x_err_code := 0;
old_stack := x_err_stack;
x_err_stack := x_err_stack || 'populate_hierarchy_denorm';

    --- Delete all rows from pa_cc_tp_schedule_line_lkp
     delete from pa_cc_tp_schedule_line_lkp;

-------  Acquire a lock before processing ----------------

IF (pa_debug.acquire_user_lock('FCLOCK:'||to_char(p_org_version_id)) = 0) AND
   (pa_debug.acquire_user_lock('ACLOCK:'||to_char(p_org_version_id)) = 0) THEN

        /*
        mano_msg('p_org_version_id = ' || p_org_version_id );
        mano_msg('p_organization_id_parent = ' || p_organization_id_parent );
        mano_msg('p_organization_id_child = ' || p_organization_id_child );
        mano_msg('p_org_id = ' || p_org_id );
        */

        /* delete from pa_org_hierarchy_denorm */

        DELETE from pa_org_hierarchy_denorm
        WHERE /*org_hierarchy_version_id = p_org_version_id For Bug 8523652*/
           nvl(org_id, -99) = nvl(p_org_id, -99)
          AND pa_org_use_type = 'REPORTING';  /* 2976953-Added nvl condition for org id and check for
                                                 pa_org_use_type being REPORTING */

        /* get the max level i.e. number of levels under p_organization_id_parent.
           value of max_level for the heirarchy shown for p_organization_id_parent = org3
           will be 4
        */

        SELECT MAX(level+1)
        INTO v_max_level
        FROM per_org_structure_elements a
        WHERE a.org_structure_version_id = p_org_version_id
        CONNECT BY PRIOR a.organization_id_child = a.organization_id_parent
        AND a.org_structure_version_id = p_org_version_id
        START WITH a.organization_id_parent = p_organization_id_parent
        AND a.org_structure_version_id = p_org_version_id;

        --mano_msg('v_max_level = ' || v_max_level);

        FOR c1rec  in all_parents (v_max_level) LOOP

                /*
                mano_msg('c1rec.organization_id_parent = ' || c1rec.organization_id_parent);
                mano_msg('c1rec.rev_level = ' || c1rec.rev_level);
                */

                /*
                for each parent insert all childs
                this will be called for each parent i.e. org3, org5, org6, org9
                For each parent it will insert all of its child at any level. Like
                for org3 it will insert org5-10 with their appropriate level
                */

                INSERT INTO pa_org_hierarchy_denorm
                ( parent_organization_id
                , child_organization_id
                , org_hierarchy_version_id
                , pa_org_use_type
                , creation_date
                , created_by
                , last_update_date
                , last_updated_by
                , last_update_login
                , parent_level
                , child_level
                , org_id
                 )
                (SELECT c1rec.organization_id_parent
                , organization_id_child
                , org_structure_version_id
                , 'REPORTING'
                , sysdate
                , nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),1)
                , sysdate
                , nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),1)
                , nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),1)
                , c1rec.rev_level
                , c1rec.rev_level - level
                , p_org_id
                FROM per_org_structure_elements a
                WHERE a.org_structure_version_id = p_org_version_id
                CONNECT BY PRIOR a.organization_id_child = a.organization_id_parent
                AND a.org_structure_version_id = p_org_version_id
                START WITH a.organization_id_parent = c1rec.organization_id_parent
                AND a.org_structure_version_id = p_org_version_id
                );

                --mano_msg('inserted ' || sql%rowcount || ' rows');

        END LOOP;

        /* now insert all organizations in the heirarchy under p_organization_id_parent
           into this table with parent and child organization id same. As all organizations
           in the heirarchy has to be a child of start org so select all childs from denorm
           table for this parent.
        */

        --mano_msg('now inserting for each child  ');

        INSERT INTO pa_org_hierarchy_denorm
        ( parent_organization_id
        , child_organization_id
        , org_hierarchy_version_id
        , pa_org_use_type
        , creation_date
        , created_by
        , last_update_date
        , last_updated_by
        , last_update_login
        , parent_level
        , child_level
        , org_id
         )
        (SELECT child_organization_id
        , child_organization_id
        , org_hierarchy_version_id
        , 'REPORTING'
        , sysdate
        , nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),1)
        , sysdate
        , nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),1)
        , nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),1)
        , child_level
        , child_level
        , p_org_id
        FROM pa_org_hierarchy_denorm
        where org_hierarchy_version_id = p_org_version_id           -- org_hierarchy_version_id Changed via bug 2890156
          and nvl(org_id, -99) = nvl(p_org_id, -99)  /* 2976953-Added nvl to the org_id condition */
          and pa_org_use_type = 'REPORTING'    /* 2976953- Added this condition */
          and parent_organization_id = p_organization_id_parent
        UNION ALL
        SELECT p_organization_id_parent
        , p_organization_id_parent
        , p_org_version_id
        , 'REPORTING'
        , sysdate
        , nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),1)
        , sysdate
        , nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),1)
        , nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),1)
        , v_max_level
        , v_max_level
        , p_org_id
        FROM dual
        );

--mano_msg('inserted ' || sql%rowcount || ' rows');

------------- Release the Lock --------------
IF (pa_debug.release_user_lock('FCLOCK:'||to_char(p_org_version_id)) = 0) AND
   (pa_debug.release_user_lock('ACLOCK:'||to_char(p_org_version_id)) = 0) THEN
  NULL;
END IF;


ELSE
-- not acquired the lock so exit and  set the return status to error
x_err_stage     := 'Unable to Acqurie Lock on FORCASTING';

END IF;

x_err_stack := old_stack;

EXCEPTION
WHEN OTHERS THEN
     v_success_flag := pa_debug.release_user_lock('FCLOCK:'||to_char(p_org_version_id));
     v_success_flag := pa_debug.release_user_lock('ACLOCK:'||to_char(p_org_version_id));
     x_err_code := SQLCODE;
     x_err_stage := SQLERRM;
     --r_msg('exception raised in outer'||x_err_code||x_err_stage);
     RETURN;

END POPULATE_HIERARCHY_DENORM2;

/* Bug#2643047 - This procedure is added so as to populate organizations for REPORTING pa_org_use_type
when a new organization is added in the hierarchy. That is added in per_org_structure_elements table.
The call to this procedure will be made from maintain_org_hist_bri
The newly added organization is x_organiation_id_child which is added under x_organization_id_parent*/

Procedure populate_reporting_orgs(
                               x_org_version_id in number,
                               x_organization_id_child in number,
                               x_organization_id_parent in number,
                               x_err_code in out NOCOPY number, --File.Sql.39 bug 4440895
                               x_err_stage in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                               x_err_stack in out NOCOPY varchar2 --File.Sql.39 bug 4440895
			        ) IS
old_stack   VARCHAR2(2000);

x_parent_level number;
x_child_level number;
x_exists_in_denorm varchar2(1);

Cursor get_all_orgs(p_org_id number) is
select parent_organization_id, parent_level
from pa_org_hierarchy_denorm
where  org_hierarchy_version_id = x_org_version_id
       and child_organization_id = x_organization_id_parent
       and pa_org_use_type = 'REPORTING'
       and nvl(org_id, -99) = nvl(p_org_id, -99);

Begin
x_err_code := 0;
old_stack := x_err_stack;
x_err_stack := x_err_stack || 'populate_reporting_orgs';

 /* For all operating units where the Org structure
    specified is same as the changed Org structure */
  for imp_rec in ( select org_id
                   from   pa_implementations_all imp
                   where  org_structure_version_id = x_org_version_id
                  )
  loop

/* Get the level for the organization x_organization_id_parent */
/* The variable x_exists_in_denorm is to check whether the parent organization is
existing in pa_org_hierarchy_denorm table, if it is not there it means that the parent
organization is not in the reporting hierarchy below the reporting start organization */

       x_exists_in_denorm := 'Y';

          begin
	     select unique parent_level into x_parent_level from pa_org_hierarchy_denorm
	     where org_hierarchy_version_id = x_org_version_id
	     and parent_organization_id = x_organization_id_parent
	     and child_organization_id = x_organization_id_parent
	     and pa_org_use_type = 'REPORTING'
	     and nvl(org_id, -99) = nvl(imp_rec.org_id, -99); /* 2976953 - Added nvl for the org id condition */
	  exception when NO_DATA_FOUND then
	    x_exists_in_denorm := 'N';
	  end;

/*
Take following heirarchy for understanding this piece of logic
          org1
          / \
       org2  org3 -> start org in pa_implementations
       /     /  \
     org4  org5  org6
            |     /   \
          org7  org8  org9
                        |
                      org10
in this example p_organization_id_parent = org3.
The data in pa_org_hierarchy_denorm is as follows:
parent      child  p_level   c_level
org3        org5   4         3
org3        org6   4         3
org3        org7   4         2
org3        org8   4         2
org3        org9   4         2
org3       org10   4         1
org5       org7    3         2
org6       org8    3         2
org6       org9    3         2
org6       org10   3         1
org9       org10   2         1
org3       org3    4         4
org5       org5    3         3
org6       org6    3         3
org7       org7    2         2
org8       org8    2         2
org9       org9    2         2
org10      org10   1         1
now suppose org11 is added under org10, then all the levels for this hierarchy needs to be changed else not reqd.
So if parent_level is equal to 1, then parent is a leaf node, so when a new org is added to leaf org,
the whole hierarchy levels needs to be changed (all levels need to be incremented by 1).
Else not required.
*/

/* Need to process only if x_exists_in_denorm is 'Y' */

   if (x_exists_in_denorm = 'Y') then
	  if (x_parent_level = 1) then
               update pa_org_hierarchy_denorm
	       set parent_level = parent_level + 1,
	           child_level = child_level + 1
	       where org_hierarchy_version_id = x_org_version_id
                     and pa_org_use_type = 'REPORTING'
                     and nvl(org_id, -99) = nvl(imp_rec.org_id, -99); /* 2976953-Added nvl condition for org_id */
                x_child_level := 1;          /* Child level is lowest, so 1 in this case */
           else
                x_child_level := x_parent_level - 1;  /* Child level will be 1 less than parent level as parent level <> 1 */
          end if;

/* Now we have the child level, so far all the parents of x_organization_id_parent, we need add a record in pa_org_hierarchy_denorm
along with x_organization_id_child */

              for rec in get_all_orgs(imp_rec.org_id) loop
                   create_reporting_org(rec.parent_organization_id,
		                         x_organization_id_child,
					 x_org_version_id,
					 'REPORTING',
					 rec.parent_level,
					 x_child_level,
					 imp_rec.org_id,
					 x_err_code,
					 x_err_stage,
					 x_err_stack);
              end loop;
/* We need to populate a record with x_organization_id_child as parent as well as child */
                                    create_reporting_org(x_organization_id_child,
		                         x_organization_id_child,
					 x_org_version_id,
					 'REPORTING',
					 x_child_level,
					 x_child_level,
					 imp_rec.org_id,
					 x_err_code,
					 x_err_stage,
					 x_err_stack);
  end if; /* for check of x_exists_in_denorm */

end loop;

x_err_stack := old_stack;
EXCEPTION
WHEN OTHERS THEN
     x_err_code := SQLCODE;
     x_err_stage := SQLERRM;
     RETURN;

end populate_reporting_orgs;


/* Bug#2643047 - This procedure is added to restructure the levels in the table
pa_og_hierarchy_denorm for REPORTING pa_org_use_type when a organization is deleted from the hierarchy.
The call to this procedure will be made from maintain_org_hist_brd.
The deleted organization is x_organiation_id_child  */

procedure restructure_rpt_orgs_denorm(
                               x_org_version_id in number,
                               x_err_code in out NOCOPY number, --File.Sql.39 bug 4440895
                               x_err_stage in out NOCOPY varchar2, --File.Sql.39 bug 4440895
                               x_err_stack in out NOCOPY varchar2 --File.Sql.39 bug 4440895
			               )
				       IS
old_stack   VARCHAR2(2000);

x_exists number;

Cursor check_lower_org_exists(p_org_id number) IS
   Select 1
   from dual
   where exists
      (select 1 from pa_org_hierarchy_denorm
       where org_hierarchy_version_id = x_org_version_id and
             pa_org_use_type          = 'REPORTING' and
             nvl(org_id, -99)         = nvl(p_org_id, -99) and  /* 2976953 Added nvl for org_id condition */
	     parent_level = 1
      );


Begin
x_err_code := 0;
old_stack := x_err_stack;
x_err_stack := x_err_stack || 'restructure_rpt_orgs_denorm';

 /* For all operating units where the Project Org structure
    specified is same as the changed Org structure */
  for imp_rec in ( select org_id
                   from   pa_implementations_all imp
                   where  org_structure_version_id = x_org_version_id
                  )
  loop

/* check_lower_org_exists is the cursor to find if there is any other organization also at the leaf level
as x_organization_id_child which was deleted, if yes no need to restructure the records else we need to decrement
all the levels so that other organization (s) which are actually now leaf nodes in the hierarchy have their levels as 1
and other organizations in the hierarchy have levels changed accordingly */

    open check_lower_org_exists(imp_rec.org_id);
    fetch check_lower_org_exists into x_exists;

    If check_lower_org_exists%notfound then
      update pa_org_hierarchy_denorm
      set parent_level = parent_level - 1,
          child_level = child_level - 1
          where org_hierarchy_version_id = x_org_version_id
                and pa_org_use_type = 'REPORTING'
                and nvl(org_id, -99) = nvl(imp_rec.org_id, -99); /* 2976953 Added nvl for org_id condition */
    end if;
    close check_lower_org_exists;
    end loop;

x_err_stack := old_stack;
EXCEPTION
WHEN OTHERS THEN
     x_err_code := SQLCODE;
     x_err_stage := SQLERRM;
     RETURN;

end restructure_rpt_orgs_denorm;

/* Bug 3649799 - This procedure will be called by statement level trigger for update on
per_org_structure_elements. */

procedure maintain_org_hist_update(x_err_code                   in out  NOCOPY number, --File.Sql.39 bug 4440895
                                   x_err_stage                  in out  NOCOPY varchar2, --File.Sql.39 bug 4440895
                                   x_err_stack                  in out  NOCOPY varchar2)  is --File.Sql.39 bug 4440895


/* This cursor is to get all the parents for the organization l_start_org_id in hierarchy l_org_struct_ver_id */

CURSOR all_parents (max_level number,
                    l_org_struct_ver_id IN per_org_structure_elements.org_structure_version_id%TYPE,
		    l_start_org_id IN per_org_structure_elements.organization_id_child%TYPE) IS
SELECT distinct organization_id_parent
,(max_level - level + 1) rev_level
FROM per_org_structure_elements a
WHERE a.org_structure_version_id = l_org_struct_ver_id
CONNECT BY PRIOR a.organization_id_child = a.organization_id_parent
AND a.org_structure_version_id = l_org_struct_ver_id
START WITH a.organization_id_parent = l_start_org_id
AND a.org_structure_version_id = l_org_struct_ver_id
ORDER by rev_level desc;

/* Added this cursor for bug 4218163 */
CURSOR proj_exp_check(c_org_struct_version_id IN per_org_structure_elements.org_structure_version_id%TYPE)
IS
SELECT 'Y' FROM pa_implementations_all
WHERE proj_org_structure_version_id = c_org_struct_version_id
   OR exp_org_structure_version_id =  c_org_struct_version_id;

l_version_id per_org_structure_elements.org_structure_version_id%TYPE;
l_new_parent_org_id per_org_structure_elements.organization_id_parent%TYPE;
l_new_child_org_id per_org_structure_elements.organization_id_child%TYPE;
v_max_level number;
l_imp_proj_exp VARCHAR2(1);

 -- Added for bug#5952671

cursor pa_org_hier_rec (l_org_id_parent per_org_structure_elements.organization_id_parent%TYPE,
                        l_level number,
            l_version_id per_org_structure_elements.org_structure_version_id%TYPE) IS
SELECT  organization_id_child
    , l_level - level
    FROM per_org_structure_elements a
    WHERE a.org_structure_version_id = l_version_id
    CONNECT BY PRIOR a.organization_id_child = a.organization_id_parent
    AND a.org_structure_version_id = l_version_id
    START WITH a.organization_id_parent = l_org_id_parent
    AND a.org_structure_version_id = l_version_id;

cursor pa_org_hier_sec_rec (l_version_id per_org_structure_elements.org_structure_version_id%TYPE,
                            l_start_org_id IN per_org_structure_elements.organization_id_child%TYPE,
                l_org_id pa_implementations_all.org_id%type) IS
SELECT child_organization_id
        , child_level
        FROM pa_org_hierarchy_denorm
        where org_hierarchy_version_id = l_version_id
          and nvl(org_id, -99) = nvl(l_org_id, -99)
      and pa_org_use_type = 'REPORTING'
          and parent_organization_id = l_start_org_id;

cursor all_org_id (l_version_id pa_implementations_all.org_structure_version_id%TYPE,
                   l_start_org_id IN pa_implementations_all.start_organization_id%TYPE) IS
SELECT org_id FROM pa_implementations_all
               WHERE org_structure_version_id = l_version_id
               and start_organization_id = l_start_org_id;

l_child_organization_id_tbl    SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();
l_child_level_tbl          SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();
l_org_id_tbl                  SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();

l_tmp_org_id                   pa_implementations_all.org_id%type;
l_plsql_max_array_size         CONSTANT NUMBER  := 1000;
--  End for bug#5952671

--Start  5934849
TYPE l_str_version_id_tbltype IS TABLE OF
per_org_structure_elements.org_structure_version_id%TYPE index by binary_integer;

L_STR_VERSION_ID_TMP l_str_version_id_tbltype;
L_STR_VERSION_ID l_str_version_id_tbltype;
l_str_exists varchar2(1) :='N';
--End  5934849

BEGIN
--Start  5934849
--Get the org_structure_version_id into L_STR_VERSION_ID_TMP tab
--for the rowids in newRows tab
FOR  k in pa_org_utils.newRows.first..pa_org_utils.newRows.last Loop
	select distinct org_structure_version_id
	into L_STR_VERSION_ID_TMP(L_STR_VERSION_ID_TMP.count+1)
	from per_org_structure_elements
	where
	ROWID = pa_org_utils.newRows(k);
End loop;

--Get the distinct rowids into L_STR_VERSION_ID tab
--from L_STR_VERSION_ID_TMP tab
FOR i IN 1 .. L_STR_VERSION_ID_TMP.COUNT LOOP
	l_str_exists := 'N';
	FOR j IN 1 .. L_STR_VERSION_ID.COUNT LOOP
		if L_STR_VERSION_ID_TMP(i) = L_STR_VERSION_ID(j) then
		  l_str_exists := 'Y';
		  Exit;
		end if;
	end loop;
	if l_str_exists = 'N' then
	L_STR_VERSION_ID(L_STR_VERSION_ID.count+1) := L_STR_VERSION_ID_TMP(i);
	End if;
end loop;


 FOR i IN 1 .. L_STR_VERSION_ID.COUNT LOOP

   l_version_id := L_STR_VERSION_ID(i);
--End 5934849


/*FOR i IN 1 .. pa_org_utils.newRows.COUNT LOOP commented for bug 5934849 */


/* Fetching the Organization Hierarchy version id, the new parent organization id and child organization id

  SELECT org_structure_version_id, organization_id_parent, organization_id_child
  INTO l_version_id, l_new_parent_org_id, l_new_child_org_id
  FROM per_org_structure_elements
  WHERE ROWID = pa_org_utils.newRows(i); */
   maintain_pa_all_org(         x_org_version_id => l_version_id,
                               x_err_code => x_err_code,
                               x_err_stage => x_err_stage,
                               x_err_stack => x_err_stack);

  maintain_projexp_org_update(        p_version_id => l_version_id,
                                      p_org_use_type => 'PROJECTS',
				      x_err_code => x_err_code,
                                      x_err_stage => x_err_stage,
                                      x_err_stack => x_err_stack);

  maintain_projexp_org_update(        p_version_id => l_version_id,
                                      p_org_use_type => 'EXPENDITURES',
				      x_err_code => x_err_code,
                                      x_err_stage => x_err_stage,
                                      x_err_stack => x_err_stack);

/* Bug 4218163 - Checking whether the hierarchy version is used in PA, calling rebuild
for TP_SCHEDULE only if the hierarchy is used as Project / Expenditure hierarchy in PA */

  OPEN proj_exp_check(l_version_id);
  FETCH proj_exp_check INTO l_imp_proj_exp;
  IF proj_exp_check%FOUND THEN
    populate_hier_denorm_sch( p_org_version_id        => l_version_id
                           ,x_err_code              => x_err_code
                           ,x_err_stage             => x_err_stage
                           ,x_err_stack             => x_err_stack );
  END IF;
  CLOSE proj_exp_check;

/* The Code below is to populate the denorm data for Reporting pa_org_use_type.
For each org id which uses the hierarchy updated, we first delete the data from denorm table
Then get the maximum level in that hierarchy.
Then insert the appropriate combinations in the denorm table.
The code is similar to the populate_hierarchy_denorm2 procedure added in 115.25 version of this file */

/* Commented and added for bug#5952671
FOR imp_rec IN (SELECT org_id, start_organization_id FROM
               pa_implementations_all
	       WHERE org_structure_version_id = l_version_id) */
FOR imp_rec IN (SELECT distinct start_organization_id FROM
               pa_implementations_all
           WHERE org_structure_version_id = l_version_id)
LOOP
/* Commented for bug#5952671
	DELETE from pa_org_hierarchy_denorm
        WHERE org_hierarchy_version_id = l_version_id
          AND org_id = imp_rec.org_id
	  AND pa_org_use_type = 'REPORTING'; */
/* Added For bug#5952671 */
        l_tmp_org_id := NULL;
        l_org_id_tbl.delete;
        OPEN all_org_id(l_version_id, imp_rec.start_organization_id);
        FETCH all_org_id BULK COLLECT INTO l_org_id_tbl;
        CLOSE all_org_id;

        FORALL i in l_org_id_tbl.first..l_org_id_tbl.last
          DELETE from pa_org_hierarchy_denorm
                WHERE org_hierarchy_version_id = l_version_id
                 AND nvl(org_id, -99) = nvl(l_org_id_tbl(i), -99)
             AND pa_org_use_type = 'REPORTING';
        l_tmp_org_id := l_org_id_tbl(l_org_id_tbl.last);
/* End bug#5952671 */

        SELECT MAX(level+1)
        INTO v_max_level
        FROM per_org_structure_elements a
        WHERE a.org_structure_version_id = l_version_id
        CONNECT BY PRIOR a.organization_id_child = a.organization_id_parent
        AND a.org_structure_version_id = l_version_id
        START WITH a.organization_id_parent = imp_rec.start_organization_id
        AND a.org_structure_version_id = l_version_id;

/* Added for bug#5952671 */
        FOR c1rec  IN all_parents (v_max_level, l_version_id, imp_rec.start_organization_id) LOOP

          OPEN pa_org_hier_rec(c1rec.organization_id_parent
                                  ,c1rec.rev_level
                                  , l_version_id);
             LOOP
               l_child_organization_id_tbl.delete;
               l_child_level_tbl.delete;
               FETCH  pa_org_hier_rec BULK COLLECT INTO
                             l_child_organization_id_tbl
                            ,l_child_level_tbl
               LIMIT  l_plsql_max_array_size;

               IF nvl(l_child_organization_id_tbl.last,0) > 0 THEN
                 FOR imp1_rec IN (SELECT org_id  FROM
                           pa_implementations_all
                       WHERE org_structure_version_id = l_version_id and start_organization_id = imp_rec.start_organization_id)
                 LOOP
                   forall i in l_child_organization_id_tbl.first..l_child_organization_id_tbl.last
                    INSERT INTO pa_org_hierarchy_denorm
                    ( parent_organization_id
                    , child_organization_id
                    , org_hierarchy_version_id
                    , pa_org_use_type
                    , creation_date
                    , created_by
                    , last_update_date
                    , last_updated_by
                    , last_update_login
                    , parent_level
                    , child_level
                    , org_id
                     ) values
                     (
                     c1rec.organization_id_parent
                    ,l_child_organization_id_tbl(i)
                    ,l_version_id
                    ,'REPORTING'
                    ,sysdate
                    ,nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),1)
                    ,sysdate
                    ,nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),1)
                    ,nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),1)
                    ,c1rec.rev_level
                    ,l_child_level_tbl(i)
                    ,imp1_rec.org_id
                     );
                 END LOOP;
               END IF;
               EXIT WHEN nvl(l_child_organization_id_tbl.last,0) < l_plsql_max_array_size;
             END LOOP;
          CLOSE pa_org_hier_rec;
        END LOOP;

        OPEN pa_org_hier_sec_rec (l_version_id ,
                      imp_rec.start_organization_id,
                      l_tmp_org_id);
            LOOP
               l_child_organization_id_tbl.delete;
               l_child_level_tbl.delete;
               FETCH  pa_org_hier_sec_rec BULK COLLECT INTO
                               l_child_organization_id_tbl
                              ,l_child_level_tbl
                 LIMIT  l_plsql_max_array_size;

               IF nvl(l_child_organization_id_tbl.last,0) > 0 THEN
                 FOR imp1_rec IN (SELECT org_id  FROM
                           pa_implementations_all
                       WHERE org_structure_version_id = l_version_id and start_organization_id = imp_rec.start_organization_id)
                 LOOP
                      FORALL i in l_child_organization_id_tbl.first..l_child_organization_id_tbl.last
                    INSERT INTO pa_org_hierarchy_denorm
                    ( parent_organization_id
                    , child_organization_id
                    , org_hierarchy_version_id
                    , pa_org_use_type
                    , creation_date
                    , created_by
                    , last_update_date
                    , last_updated_by
                    , last_update_login
                    , parent_level
                    , child_level
                    , org_id
                     ) values
                     (
                     l_child_organization_id_tbl(i)
                    ,l_child_organization_id_tbl(i)
                    ,l_version_id
                    ,'REPORTING'
                    ,sysdate
                    ,nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),1)
                    ,sysdate
                    ,nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),1)
                    ,nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),1)
                    ,l_child_level_tbl(i)
                    ,l_child_level_tbl(i)
                    ,imp1_rec.org_id
                     );
                 END LOOP;
               END IF;
               EXIT WHEN nvl(l_child_organization_id_tbl.last,0) < l_plsql_max_array_size;
        END LOOP;
        CLOSE pa_org_hier_sec_rec;
        FOR imp1_rec IN (SELECT org_id  FROM
               pa_implementations_all
               WHERE org_structure_version_id = l_version_id AND start_organization_id = imp_rec.start_organization_id)
        LOOP
            INSERT INTO pa_org_hierarchy_denorm
            ( parent_organization_id
            , child_organization_id
            , org_hierarchy_version_id
            , pa_org_use_type
            , creation_date
            , created_by
            , last_update_date
            , last_updated_by
            , last_update_login
            , parent_level
            , child_level
            , org_id
             ) VALUES
             (
             imp_rec.start_organization_id
            ,imp_rec.start_organization_id
            ,l_version_id
            ,'REPORTING'
            ,sysdate
            ,nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),1)
            ,sysdate
            ,nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),1)
            ,nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),1)
            ,v_max_level
            ,v_max_level
            ,imp1_rec.org_id
             );
        END LOOP;
/* End bug#5952671*/
/* Commented for bug#5952671
         FOR c1rec  in all_parents (v_max_level, l_version_id, imp_rec.start_organization_id) LOOP
                INSERT INTO pa_org_hierarchy_denorm
                ( parent_organization_id
                , child_organization_id
                , org_hierarchy_version_id
                , pa_org_use_type
                , creation_date
                , created_by
                , last_update_date
                , last_updated_by
                , last_update_login
                , parent_level
                , child_level
                , org_id
                 )
                (SELECT c1rec.organization_id_parent
                , organization_id_child
                , l_version_id
                , 'REPORTING'
                , sysdate
                , nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),1)
                , sysdate
                , nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),1)
                , nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),1)
                , c1rec.rev_level
                , c1rec.rev_level - level
                , imp_rec.org_id
                FROM per_org_structure_elements a
                WHERE a.org_structure_version_id = l_version_id
                CONNECT BY PRIOR a.organization_id_child = a.organization_id_parent
                AND a.org_structure_version_id = l_version_id
                START WITH a.organization_id_parent = c1rec.organization_id_parent
                AND a.org_structure_version_id = l_version_id
                );
         END LOOP;


        INSERT INTO pa_org_hierarchy_denorm
        ( parent_organization_id
        , child_organization_id
        , org_hierarchy_version_id
        , pa_org_use_type
        , creation_date
        , created_by
        , last_update_date
        , last_updated_by
        , last_update_login
        , parent_level
        , child_level
        , org_id
         )
        (SELECT child_organization_id
        , child_organization_id
        , org_hierarchy_version_id
        , 'REPORTING'
        , sysdate
        , nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),1)
        , sysdate
        , nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),1)
        , nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),1)
        , child_level
        , child_level
        , imp_rec.org_id
        FROM pa_org_hierarchy_denorm
        where org_hierarchy_version_id = l_version_id
          and org_id = imp_rec.org_id
          and pa_org_use_type = 'REPORTING'   --  Added for bug#5361709
          and parent_organization_id = imp_rec.start_organization_id
        UNION ALL
        SELECT imp_rec.start_organization_id
        , imp_rec.start_organization_id
        , l_version_id
        , 'REPORTING'
        , sysdate
        , nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),1)
        , sysdate
        , nvl(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),1)
        , nvl(TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID')),1)
        , v_max_level
        , v_max_level
        , imp_rec.org_id
        FROM dual
        ); */

END LOOP;

END LOOP;

END maintain_org_hist_update;

/* Bug 3649799 - This procedure will be called for rebuilding project and expenditure
hierarchy in pa_org_hierarchy_denorm table. */

procedure maintain_projexp_org_update(p_version_id in number,
                                      p_org_use_type in varchar2,
				      x_err_code                   in out  NOCOPY number, --File.Sql.39 bug 4440895
                                      x_err_stage                  in out  NOCOPY varchar2, --File.Sql.39 bug 4440895
                                      x_err_stack                  in out  NOCOPY varchar2)  is --File.Sql.39 bug 4440895
l_imp_proj_exp VARCHAR2(1);
l_exist_recs VARCHAR2(1);
class_org_true varchar2(3);
l_parent_org_id per_org_structure_elements.organization_id_parent%TYPE;
l_child_org_id per_org_structure_elements.organization_id_parent%TYPE;

TYPE num2_tbl_type  IS TABLE OF NUMBER   INDEX BY BINARY_INTEGER;
l_child_org_id2_var  num2_tbl_type;

Cursor start_orgs (c_version_id in number) IS
SELECT decode(p_org_use_type, 'PROJECTS', proj_start_org_id, 'EXPENDITURES', exp_start_org_id) start_organization_id
FROM   pa_implementations_all imp
WHERE  decode(p_org_use_type, 'PROJECTS', proj_org_structure_version_id,
                   'EXPENDITURES', exp_org_structure_version_id) = c_version_id;


CURSOR c_get_new_org ( c_org_struct_ver_id IN per_org_structure_elements.org_structure_version_id%TYPE,
                       c_start_org_id IN per_org_structure_elements.organization_id_child%TYPE)
IS
SELECT c_start_org_id FROM dual
UNION ALL
SELECT organization_id_child
FROM per_org_structure_elements
WHERE org_structure_version_id = c_org_struct_ver_id
 CONNECT BY PRIOR organization_id_child = organization_id_parent
  AND org_structure_version_id =  c_org_struct_ver_id
 START WITH organization_id_parent = c_start_org_id
  AND org_structure_version_id = c_org_struct_ver_id;

CURSOR c_get_sub_orgs (c_org_struct_ver_id IN per_org_structure_elements.org_structure_version_id%TYPE,
                       c_org_id IN per_org_structure_elements.organization_id_child%TYPE) IS
SELECT c_org_id
FROM dual
UNION ALL
SELECT organization_id_child
FROM per_org_structure_elements
WHERE org_structure_version_id = c_org_struct_ver_id
  CONNECT BY PRIOR organization_id_child = organization_id_parent
     AND org_structure_version_id = c_org_struct_ver_id
  START WITH organization_id_parent = c_org_id
     AND org_structure_version_id = c_org_struct_ver_id ;

BEGIN

  BEGIN

      SELECT 'Y' INTO l_imp_proj_exp
      FROM pa_implementations_all
      WHERE decode(p_org_use_type, 'PROJECTS', proj_org_structure_version_id,
                   'EXPENDITURES', exp_org_structure_version_id) = p_version_id
      AND ROWNUM = 1;

      DELETE FROM pa_org_hierarchy_denorm
      WHERE org_hierarchy_version_id = p_version_id
            AND pa_org_use_type = p_org_use_type;

   EXCEPTION
       WHEN NO_DATA_FOUND THEN
         l_imp_proj_exp := 'N';
  END;

  FOR imp_rec IN start_orgs(p_version_id)
  LOOP
     BEGIN
       SELECT 'Y' INTO l_exist_recs
       FROM pa_org_hierarchy_denorm
       WHERE org_hierarchy_version_id = p_version_id
       AND pa_org_use_type = p_org_use_type
       AND parent_organization_id = imp_rec.start_organization_id
       AND ROWNUM = 1;
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_exist_recs := 'N';
     END;

     IF l_exist_recs = 'N' THEN
      OPEN c_get_new_org(p_version_id, imp_rec.start_organization_id);
      LOOP
         FETCH c_get_new_org INTO l_parent_org_id;
         EXIT WHEN c_get_new_org%NOTFOUND;
         OPEN c_get_sub_orgs(p_version_id, l_parent_org_id);
         LOOP
             FETCH c_get_sub_orgs BULK COLLECT INTO l_child_org_id2_var LIMIT 10000; --bug6444664
             EXIT WHEN l_child_org_id2_var.count = 0;--8915976
             /*
                    BEGIN
                         SELECT 'YES' INTO class_org_true
                           FROM hr_organization_information
                          WHERE organization_id = l_child_org_id
                            AND ORG_INFORMATION_CONTEXT = 'CLASS'
                            AND ORG_INFORMATION1 = decode(p_org_use_type, 'PROJECTS', 'PA_PROJECT_ORG',
			                                  'EXPENDITURES', 'PA_EXPENDITURE_ORG')
                            AND ORG_INFORMATION2 = 'Y';
                         EXCEPTION WHEN NO_DATA_FOUND THEN
                            class_org_true := 'NO';
                     END ;

           IF class_org_true = 'YES' THEN
                pa_org_utils.CREATE_ORG_HIERARCHY_DENORM(p_parent_organization_id=> l_parent_org_id
                                                 , p_child_organization_id => l_child_org_id
                                                 , p_org_hierarchy_version_id=> p_version_id
                                                 , p_pa_org_use_type =>  p_org_use_type
                                                 , x_err_code        => x_err_code
                                                 , x_err_stage       => x_err_stage
                                                 , x_err_stack       => x_err_stack);
           END IF; */
           FORALL i IN l_child_org_id2_var.FIRST..l_child_org_id2_var.LAST
               INSERT INTO PA_ORG_HIERARCHY_DENORM ( parent_organization_id
                                        , child_organization_id
                                        , org_hierarchy_version_id
                                        , pa_org_use_type
                                        , creation_date
                                        , created_by
                                        , last_update_date
                                        , last_updated_by
                                        , last_update_login
                                          )
                              SELECT  l_parent_org_id
                                    , l_child_org_id2_var(i)
                                    , p_version_id
                                    , p_org_use_type
                                    , sysdate
                                    ,1--     , TO_NUMBER(FND_PROFILE.VALUE('USER_ID'))
                                    , sysdate
                                    ,1--     , TO_NUMBER(FND_PROFILE.VALUE('USER_ID'))
                                    ,1--     , TO_NUMBER(FND_PROFILE.VALUE('LOGIN_ID'))
                               from dual
                               where not exists
                                    (select 'Y'
                                    from pa_org_hierarchy_denorm
                                   where pa_org_use_type = p_org_use_type
                                     and parent_organization_id = l_parent_org_id
                                     and child_organization_id  = l_child_org_id2_var(i)
                                     and org_hierarchy_version_id = p_version_id)
                               and exists
                                   (SELECT 'YES'
                                    FROM hr_organization_information
                                    WHERE organization_id = l_child_org_id2_var(i)
                                    AND ORG_INFORMATION_CONTEXT = 'CLASS'
                                    AND ORG_INFORMATION1 = decode(p_org_use_type, 'PROJECTS', 'PA_PROJECT_ORG', 'EXPENDITURES', 'PA_EXPENDITURE_ORG'));
          l_child_org_id2_var.DELETE;
         END LOOP;
        CLOSE c_get_sub_orgs;
      END LOOP;
   CLOSE c_get_new_org;
   END IF;
END LOOP;

END maintain_projexp_org_update;


/* Bug 5934849 - This procedure will be called for maintaining project and expenditure
data in pa_all_organizations table. */

Procedure maintain_pa_all_org(x_org_version_id in number,
                               x_err_code in out  NOCOPY number,
                               x_err_stage in out NOCOPY  varchar2,
                               x_err_stack in out NOCOPY varchar2) IS

  v_start_org_id number;
  v_org_id  number;

CURSOR cur_proj_new_org IS
        SELECT  se.organization_id_child organization_id
                FROM    per_org_structure_elements se
                WHERE   org_structure_version_id =  x_org_version_id
                AND     EXISTS (select 'X'
                        from hr_organization_information info
                        where info.organization_id = se.organization_id_child
                        and   info.org_information1 = 'PA_PROJECT_ORG'
                        and   info.org_information_context||'' = 'CLASS'
                        and   info.org_information2 = 'Y')
                CONNECT BY PRIOR se.organization_id_child
                        = se.organization_id_parent
                AND     org_structure_version_id = x_org_version_id
                START WITH se.organization_id_parent = v_start_org_id
                AND     org_structure_version_id = x_org_version_id
        UNION
                SELECT  v_start_org_id FROM Sys.dual -- Added exists clause for Bug# 1650520
                WHERE   EXISTS (select 'X'
                        from hr_organization_information info
                        where info.org_information1 = 'PA_PROJECT_ORG'
                        and   info.org_information_context||'' = 'CLASS'
                        and   info.org_information2 = 'Y'
                        and   info.organization_id = v_start_org_id);

CURSOR cur_exp_new_org IS
        SELECT  se.organization_id_child organization_id
                FROM    per_org_structure_elements se
                WHERE   org_structure_version_id =  x_org_version_id
                AND     EXISTS (select 'X'
                        from hr_organization_information info
                        where info.organization_id = se.organization_id_child
                        and   info.org_information1 = 'PA_EXPENDITURE_ORG'
                        and   info.org_information_context||'' = 'CLASS'
                        and   info.org_information2 = 'Y')
                CONNECT BY PRIOR se.organization_id_child
                        = se.organization_id_parent
                AND     org_structure_version_id = x_org_version_id
                START WITH se.organization_id_parent = v_start_org_id
                AND     org_structure_version_id = x_org_version_id
        UNION
                SELECT  v_start_org_id FROM Sys.dual
                 where  EXISTS (select 'X'  /* Made changes for BUG 1180635*/
                        from hr_organization_information info
                        where info.org_information1 = 'PA_EXPENDITURE_ORG'
                        and   info.org_information_context||'' = 'CLASS'
                        and   info.org_information2 = 'Y'
                        and   info.organization_id = v_start_org_id);


Begin


  for imp_rec in ( select org_id,proj_start_org_id
                   from   pa_implementations_all imp
                   where  proj_org_structure_version_id = x_org_version_id
                  )

  loop
    v_start_org_id := imp_rec.proj_start_org_id;
    v_org_id       := imp_rec.org_id;

        UPDATE pa_all_organizations
        SET    Inactive_Date    = TRUNC(SYSDATE)
        WHERE  Pa_Org_Use_Type  = 'PROJECTS'
        AND    Org_id = v_org_id and Inactive_Date is null ;

         FOR rec_proj_new_org IN cur_proj_new_org LOOP

       /* Update all Organizations (Projects)
          in the  hierarchy with inactive date as NULL.
          Union is to include the start organization id in the update */

        UPDATE pa_all_organizations
        SET    Inactive_Date = NULL
        WHERE  Pa_Org_Use_Type = 'PROJECTS'
        AND    Org_id = v_org_id
        AND    Organization_id = rec_proj_new_org.organization_id;

        /* In case there are no corresponding records for the
           Organization hierarchy in the Pa_all_Organizations, then,
           create these records in the Pa_All_Organizations
           with Inactive_Date as NULL */

        IF SQL%NOTFOUND THEN
                INSERT INTO  Pa_All_Organizations
                       (organization_id,
                        org_id,
                        pa_org_use_type,
                        inactive_date)
                VALUES
                       (rec_proj_new_org.organization_id,
                        v_org_id,
                        'PROJECTS',
                        NULL);
         END IF;
	 END Loop;

     END LOOP;

  for imp_rec in ( select org_id, exp_start_org_id
                   from   pa_implementations_all imp
                   where  exp_org_structure_version_id = x_org_version_id
                  )

  loop
    v_start_org_id := imp_rec.exp_start_org_id;
    v_org_id       := imp_rec.org_id;

        UPDATE pa_all_organizations
        SET    Inactive_Date    = TRUNC(SYSDATE)
        WHERE  Pa_Org_Use_Type  = 'EXPENDITURES'
        AND    Org_id = v_org_id and Inactive_Date is null ;

         FOR rec_exp_new_org IN cur_exp_new_org LOOP

       /* Update all Organizations (Projects)
          in the  hierarchy with inactive date as NULL.
          Union is to include the start organization id in the update */

        UPDATE pa_all_organizations
        SET    Inactive_Date = NULL
        WHERE  Pa_Org_Use_Type = 'EXPENDITURES'
        AND    Org_id = v_org_id
        AND    Organization_id = rec_exp_new_org.organization_id;

        /* In case there are no corresponding records for the new
           Organization hierarchy in the Pa_all_Organizations, then,
           create these records in the Pa_All_Organizations
           with Inactive_Date as NULL */

        IF SQL%NOTFOUND THEN
                INSERT INTO  Pa_All_Organizations
                       (organization_id,
                        org_id,
                        pa_org_use_type,
                        inactive_date)
                VALUES
                       (rec_exp_new_org.organization_id,
                        v_org_id,
                        'EXPENDITURES',
                        NULL);
         END IF;
	 END Loop;

     END LOOP;

end maintain_pa_all_org;

END;

/
