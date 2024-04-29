--------------------------------------------------------
--  DDL for Package Body PA_RESOURCE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RESOURCE_UTILS" AS
-- $Header: PARSUTLB.pls 120.23.12010000.24 2010/03/24 07:20:25 sugupta ship $
--
--  PROCEDURE
--              check_internal_or_external
--  PURPOSE
--              This procedure returns the correct resource_type_id
--              for a given resource name (whether Employee or Party).
--              Raise no_data_found or too_many_rows, if no resource
--              exists or more than one resource has the same name
--  HISTORY
--   26-APR-2002      Adzilah A.       Created
PROCEDURE check_internal_or_external(p_resource_name     IN   VARCHAR2,
                                     x_resource_type_id  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                     x_return_status     OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
 IS

     CURSOR internal IS
         SELECT 'Y'
         FROM   per_all_people_f
         WHERE  full_name = p_resource_name
           and  rownum=1;

     CURSOR external IS
         SELECT 'Y'
     FROM   pa_party_resource_details_v
         WHERE  party_name = p_resource_name
           and  rownum=1;

     l_internal  VARCHAR2(1)  := 'N';
     l_external  VARCHAR2(1)  := 'N';

BEGIN

     OPEN internal;
     FETCH internal into l_internal;
     CLOSE internal;

     --dbms_output.put_line('INTERNAL = ' || l_internal);

     OPEN external;
     FETCH external into l_external;
     CLOSE external;

     --dbms_output.put_line('EXTERNAL = ' || l_external);

     if(l_internal = 'Y' and l_external = 'Y') then
         raise TOO_MANY_ROWS;

     elsif (l_internal='Y' and l_external= 'N') then
         -- EMPLOYEE
         x_resource_type_id := 101;

     elsif (l_internal='N' and l_external= 'Y') then
         -- HZ_PARTY
         x_resource_type_id := 112;
     else
         raise NO_DATA_FOUND;
     end if;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
     WHEN NO_DATA_FOUND THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
         raise;
     WHEN TOO_MANY_ROWS THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     raise;
     WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     raise;
END check_internal_or_external;

--
--  PROCEDURE
--              Check_ResourceName_Or_Id
--  PURPOSE
--              This procedure does the following
--              If Resource name is passed converts it to the id
--      If Resource Id is passed,
--      based on the check_id_flag validates it
--  HISTORY
--   27-JUN-2000      P. Bandla       Created
--   19-JUL-2000      E  Yefimov      Modified
--     Added resource_type_id as an out parameter
--   05-SEP-2000      P. Bandla       Modified
--     Added p_date parameter
--   11-APR-2001      virangan        Added LOV fixes

 PROCEDURE Check_ResourceName_Or_Id(
            p_resource_id       IN  NUMBER,
            p_resource_name     IN  VARCHAR2,
            p_date              IN  DATE,
   	    p_end_date          IN  DATE :=null, -- 3235018
            p_check_id_flag     IN  VARCHAR2,
                        p_resource_type_id      IN      NUMBER,
            x_resource_id       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_resource_type_id      OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_return_status     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_error_message_code    OUT NOCOPY VARCHAR2 )  --File.Sql.39 bug 4440895
  IS

          -- l_sys_per_type       VARCHAR2(30);
          l_current_id         NUMBER     := NULL;
          l_num_ids            NUMBER     := 0;
          l_id_found_flag      VARCHAR(1) := 'N';
          l_resource_type_id   NUMBER     := p_resource_type_id;

         /* Added for Bug# 6056112 */
          l_pa_resource_id     NUMBER ;
          l_future_term_wf_flag   pa_resources.future_term_wf_flag%TYPE := NULL  ;

          CURSOR r_ids IS
              SELECT person_id
              FROM   per_all_people_f
              WHERE  full_name = p_resource_name
          AND    trunc(p_date) between trunc(effective_start_date)
                                       and trunc(effective_end_date);

 BEGIN

     IF (p_resource_id IS NULL and p_resource_name IS NOT NULL) THEN
          check_internal_or_external (
               p_resource_name      => p_resource_name,
               x_resource_type_id   => l_resource_type_id,
               x_return_status      => x_return_status);

     END IF;

    /* Start of Changes for Bug 6056112 */
     SELECT  pa_resource_utils.get_resource_id(p_resource_id)
     INTO l_pa_resource_id
     FROM dual;

     IF (l_pa_resource_id <> -999) THEN
             SELECT nvl(future_term_wf_flag,'N')
            INTO l_future_term_wf_flag
            FROM pa_resources
            WHERE resource_id = l_pa_resource_id;
     END IF ;
    /* End of Changes for Bug 6056112 */

     --dbms_output.put_line('Resource Type Id = ' || l_resource_type_id);

     -----------------------------------------
     -- This check is for EMPLOYEE type
     -- because we now handle external people
     -----------------------------------------
     IF l_resource_type_id = 101 THEN

    IF p_resource_id IS NOT NULL AND p_resource_id<>FND_API.G_MISS_NUM THEN

        IF p_check_id_flag = 'Y' THEN

          /* Start of Changes for Bug 6056112 */
          IF (nvl(l_future_term_wf_flag,'N') = 'Y') THEN

           SELECT  DISTINCT(prd.person_id)
           INTO   x_resource_id
           FROM pa_resources_denorm prd
           WHERE prd.person_id = p_resource_id
           AND  trunc(p_date) > = (Select trunc(min(prd1.resource_effective_start_date))
                                   from pa_resources_denorm prd1
                                   where prd1.person_id = prd.person_id)
           AND (trunc(p_end_date) is null
                       OR
                trunc(p_end_date) < = (Select trunc(max(prd2.resource_effective_end_date))
                                       from pa_resources_denorm prd2
                                       where prd2.person_id = prd.person_id) );
          ELSE

            SELECT per.person_id
                   -- type.system_person_type -- FP M CWK
                INTO   x_resource_id
                   -- l_sys_per_type
                FROM   per_all_people_f per
                               -- per_person_types type
                WHERE  per.person_id = p_resource_id
                        -- AND    per.person_type_id = type.person_type_id
            AND trunc(p_date) between trunc(per.effective_start_date) and trunc(per.effective_end_date)
            AND (p_end_date is null
                         OR
                -- Start changes for Bug 6828493
                --(trunc(p_end_date) between trunc(per.effective_start_date) and trunc(per.effective_end_date))
                (trunc(p_end_date) < =     (Select trunc(max(per2.effective_end_date))
                                            from per_all_people_f per2
                                            where per2.person_id = p_resource_id
                                            AND (per2.current_employee_flag = 'Y' OR per2.current_npw_flag = 'Y')) -- AND Codn added for bug 6851095
                 AND trunc(p_end_date) > = (Select trunc(min(per3.effective_start_date))
                                            from per_all_people_f per3
                                            where per3.person_id = p_resource_id
                                            AND (per3.current_employee_flag = 'Y' OR per3.current_npw_flag = 'Y')))) -- AND Codn added for bug 6851095
                -- End changes for Bug 6828493
            AND (per.current_employee_flag = 'Y'
                         OR
                 per.current_npw_flag = 'Y'); -- FP M CWK

          END IF ; --IF (nvl(l_future_term_wf_flag,'N') = 'Y') THEN
          /* End of Changes for Bug 6056112 */

            ELSIF p_check_id_flag = 'N' THEN
            x_resource_id := p_resource_id;

/* FP M CWK - no need to do this at all since l_sys_per_type is not
 * used for anything */
/*                      SELECT type.system_person_type
                INTO   l_sys_per_type
                FROM   per_all_people_f per,
                               per_person_types type
                WHERE  per.person_id = x_resource_id
                        AND    per.person_type_id = type.person_type_id
            AND    trunc(p_date) between trunc(per.effective_start_date)
                                and trunc(per.effective_end_date)
            AND    (per.current_employee_flag = 'Y' OR -- Added this check for bug#2683266
                                per.current_npw_flag = 'Y'); -- FP M CWK */

                ELSIF p_check_id_flag = 'A' THEN
                     IF (p_resource_name IS NULL) THEN
                        -- Return a null ID since the name is null.
                        x_resource_id := NULL;
                     ELSE
                        -- Find the ID which matches the Name passed
                        OPEN r_ids;
                        LOOP
                           FETCH r_ids INTO l_current_id;
                           EXIT WHEN r_ids%NOTFOUND;
                           IF (l_current_id = p_resource_id) THEN
                              l_id_found_flag := 'Y';
                              x_resource_id := p_resource_id;
                           END IF;
                        END LOOP;
                        l_num_ids := r_ids%ROWCOUNT;
                        CLOSE r_ids;

                        IF (l_num_ids = 0) THEN
                           -- No IDs for name
                           RAISE NO_DATA_FOUND;
                        ELSIF (l_num_ids = 1) THEN
                           -- Since there is only one ID for the name use it.
                           x_resource_id := l_current_id;
/* FP M CWK - no need to do this at all since l_sys_per_type is not
 * used for anything */
/*                         SELECT type.system_person_type
                           INTO   l_sys_per_type
                           FROM   per_all_people_f per,
                                  per_person_types type
                           WHERE  per.person_id = x_resource_id
                           AND    per.person_type_id = type.person_type_id
                           AND    trunc(p_date) between trunc(per.effective_start_date) and trunc(per.effective_end_date)
            AND    (per.current_employee_flag = 'Y' OR -- Added this check for bug#2683266
                                per.current_npw_flag = 'Y'); -- FP M CWK */

                        ELSIF (l_id_found_flag = 'N') THEN
                           -- More than one ID for the name and none of the IDs matched
                           -- the ID passed in.
                           RAISE TOO_MANY_ROWS;
                        END IF;
                      END IF;
        END IF;
        ELSE          -- Find ID since it was not passed.
            IF (p_resource_name IS NOT NULL) THEN

        SELECT per.person_id
               -- type.system_person_type -- FP M CWK
            INTO   x_resource_id
               -- l_sys_per_type -- FP M CWK
            FROM   per_all_people_f per
                       -- per_person_types type -- FP M CWK
            WHERE  per.full_name = p_resource_name
                -- AND    per.person_type_id = type.person_type_id -- FP M CWK
        AND    trunc(p_date) between trunc(per.effective_start_date)
                                         and trunc(per.effective_end_date)
        AND (p_end_date is null OR (trunc(p_end_date) between trunc(per.effective_start_date) -- 3235018 Added end date condition
                      and trunc(per.effective_end_date)))
        AND    (per.current_employee_flag = 'Y' OR /* Added this check for bug#2683266 */
                        per.current_npw_flag = 'Y'); -- FP M CWK

            ELSE
                x_resource_id := NULL;
            END IF;
        END IF;

/* Commented for bug#2683266 as person type should not be checked in pa_resource_types table
   as pa_resource_types does not contain all person_types defined in HR table per_person_types

        IF l_sys_per_type is not null THEN
           select resource_type_id
           into x_resource_type_id
           from pa_resource_types
           where resource_type_code = decode(l_sys_per_type,
                                            'EMP','EMPLOYEE');
        END IF;
*/
    x_resource_type_id := l_resource_type_id; /* Added for bug#2683266 as the earlier select is commented */

     ELSIF l_resource_type_id = 112 THEN

     ---------------------
     -- For type HZ_PARTY
     ---------------------
        IF p_resource_id IS NOT NULL AND p_resource_id<>FND_API.G_MISS_NUM THEN

                SELECT party_id
            INTO   x_resource_id
            FROM   pa_party_resource_details_v hz
            WHERE  hz.party_id = p_resource_id
        AND    trunc(p_date) between trunc(hz.start_date)
                   and trunc(nvl(hz.end_date, to_date('31-12-4712', 'DD-MM-YYYY')));

        ELSE
            IF (p_resource_name IS NOT NULL) THEN
        SELECT party_id
            INTO   x_resource_id
            FROM   pa_party_resource_details_v hz
            WHERE  hz.party_name = p_resource_name
        AND    trunc(p_date) between trunc(hz.start_date)
                   and trunc(nvl(hz.end_date, to_date('31-12-4712', 'DD-MM-YYYY')));
            ELSE
                x_resource_id := NULL;
            END IF;

        END IF;

        -- also set the resource_type_id to 112 for HZ_PARTY
        x_resource_type_id := 112;

     END IF;    /* after checking the resource_type_id */

     x_return_status := FND_API.G_RET_STS_SUCCESS;

 EXCEPTION
        WHEN NO_DATA_FOUND THEN
                x_resource_id := NULL;
            x_return_status := FND_API.G_RET_STS_ERROR;
        x_error_message_code := 'PA_RESOURCE_INVALID_AMBIGUOUS';
        WHEN TOO_MANY_ROWS THEN
                x_resource_id := NULL;
            x_return_status := FND_API.G_RET_STS_ERROR;
        x_error_message_code := 'PA_MULTIPLE_RESOURCE';
        WHEN OTHERS THEN
        --PA_Error_Utils.Set_Error_Stack
        -- (`pa_resource_utils.check_resourcename_or_id');
            -- This sets the current program unit name in the
            -- error stack. Helpful in Debugging
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                x_resource_id := NULL;

 END Check_ResourceName_Or_Id;

--
--  PROCEDURE
--              Get_CRM_Res_id
--  PURPOSE
--              Returns the CRM Resource_id based on the
--              project_player_id

--  HISTORY
--   27-JUN-2000      P. Bandla       Created

 PROCEDURE Get_CRM_Res_id(
    P_PROJECT_PLAYER_ID IN  NUMBER,
        P_RESOURCE_ID           IN      NUMBER,
    X_JTF_RESOURCE_ID   OUT NOCOPY NUMBER,  --File.Sql.39 bug 4440895
        X_RETURN_STATUS     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        X_ERROR_MESSAGE_CODE    OUT NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895

    l_project_player_id NUMBER := p_project_player_id;
        l_resource_id       NUMBER := p_resource_id ;
 BEGIN
    IF P_PROJECT_PLAYER_ID is null
    AND P_RESOURCE_ID is not null THEN
      -- use p_resource_id to get the CRM resource_id

      select jtf_resource_id
      into x_jtf_resource_id
      from pa_resources
      where resource_id = l_resource_id;

    ELSIF P_PROJECT_PLAYER_ID is not null
    AND P_RESOURCE_ID is null THEN

       -- use p_project_player_id to get the CRM resource_id

    select a.jtf_resource_id
    into x_jtf_resource_id
    from pa_resources a, pa_project_parties  b
    where a.resource_id = b.resource_id
    and b.project_party_id = l_project_player_id;

    ELSIF (P_PROJECT_PLAYER_ID is not null
    AND P_RESOURCE_ID is not null)
    OR (P_PROJECT_PLAYER_ID is null
    AND P_RESOURCE_ID is null) THEN

       x_jtf_resource_id := null ;

    END IF;

       x_return_status := FND_API.G_RET_STS_SUCCESS;

 EXCEPTION
        WHEN NO_DATA_FOUND THEN
            x_jtf_resource_id := null ;
            x_return_status := FND_API.G_RET_STS_SUCCESS;
            --x_return_status := FND_API.G_RET_STS_ERROR;
                    --x_error_message_code := 'PA_CRM_RES_NULL';
    WHEN OTHERS THEN
        --PA_Error_Utils.Set_Error_Stack
        -- (`pa_resource_utils.check_resourcename_or_id');
            -- This sets the current program unit name in the
            -- error stack. Helpful in Debugging

        X_JTF_RESOURCE_ID := NULL ; -- 4537865
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

 END Get_CRM_Res_id;

 PROCEDURE CHECK_CC_FOR_RESOURCE(
        P_RESOURCE_ID           IN      NUMBER,
    P_PROJECT_ID            IN      NUMBER,
    P_START_DATE            IN      DATE,
        P_END_DATE              IN      DATE,
        X_CC_OK                 OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        X_RETURN_STATUS         OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        X_ERROR_MESSAGE_CODE    OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

 IS
    cursor get_org_id_from_resource is
        select
        resource_org_id
        from
        pa_resources_denorm
        where
        resource_id = p_resource_id
    and     p_start_date between resource_effective_start_date
                                 and resource_effective_end_date;

    NULL_INVALID_PARAMS  EXCEPTION;
    l_prvdr_org_id       NUMBER := NULL;

 BEGIN

   -- IF this is a single-org instance, there will be
   -- no cross-charge setup. Return 'Y' for single-org
   -- instances.

   IF PA_UTILS.pa_morg_implemented = 'N' THEN
       X_CC_OK            := 'Y';
       X_RETURN_STATUS    := FND_API.G_RET_STS_SUCCESS;
   ELSE
    /* Dependency against pa_projects_expend_v v115.14 */

    open get_org_id_from_resource;
    fetch get_org_id_from_resource into l_prvdr_org_id;
    close get_org_id_from_resource;

    If l_prvdr_org_id IS NULL Then
         /* A resource identifier was passed that does not
              * exist in pa_resources_denorm table and is therefore
              * invalid so raise exception.
              */
         raise NULL_INVALID_PARAMS;
    End If;

      -- Added the same where clause here as in view pavw168.sql. This is due to      -- Bug # 1478149. Removed the check for project status.

   -- MOAC Changes: Bug 4363092: removed nvl with org_id
        select
        'Y'
        into
        X_CC_OK
        FROM HR_ORGANIZATION_INFORMATION PLE,
             HR_ORGANIZATION_INFORMATION RLE,
             pa_project_types_all PT,
             pa_projects_all P,
             pa_implementations_all iprv,
             pa_implementations_all irecv
        WHERE P.project_type = PT.project_type
          AND NVL(P.template_flag, 'N') <> 'Y'
          --Bug2538692 AND pa_security.allow_query(P.project_id) = 'Y'
          AND ((iprv.business_group_id = irecv.business_group_id
          and pa_cross_business_grp.IsCrossBGProfile='N')
           OR pa_cross_business_grp.IsCrossBGProfile ='Y')
          -- bug 8967761 .. below 2 are changed to remove IS NULL
          --AND (irecv.org_id IS NULL OR irecv.org_id = P.org_id)
          --AND (PT.org_id IS NULL or PT.org_id = P.org_id)
          AND (irecv.org_id = P.org_id)
          AND (PT.org_id = P.org_id)
          AND PT.project_type <> 'AWARD_PROJECT'
          AND nvl(PT.cc_prvdr_flag, 'N') <> 'Y'
          AND PLE.organization_id (+) = iprv.org_id
          AND PLE.org_information_context (+) = 'Operating Unit Information'
          AND RLE.organization_id (+) = irecv.org_id
          AND RLE.org_information_context (+) = 'Operating Unit Information'
          AND ( P.org_id = iprv.org_id
              OR
              ( PLE.org_information2 = RLE.org_information2
                AND ( EXISTS ( SELECT null FROM PA_CC_ORG_RELATIONSHIPS CO
                               WHERE CO.prvdr_org_id = iprv.org_id
                               AND   CO.recvr_org_id = irecv.org_id
                               AND   CO.prvdr_allow_cc_flag = 'Y')
                      OR
                      (iprv.cc_allow_iu_flag = 'Y'
                       AND NOT EXISTS ( SELECT null FROM
                                        PA_CC_ORG_RELATIONSHIPS CO
                                        WHERE CO.prvdr_org_id = iprv.org_id
                                        AND   CO.recvr_org_id = irecv.org_id
                                        AND   CO.prvdr_allow_cc_flag = 'N')
                       )
                     )
               )
              OR
              ( PLE.org_information2 <> RLE.org_information2
                AND PT.project_type_class_code <> 'CAPITAL'
                AND EXISTS ( SELECT null FROM PA_CC_ORG_RELATIONSHIPS CO
                             WHERE CO.prvdr_org_id = iprv.org_id
                             AND   CO.recvr_org_id = irecv.org_id
                             AND   CO.prvdr_allow_cc_flag = 'Y'
                             AND  (( CO.prvdr_project_id IS NOT NULL
                                   AND CO.vendor_site_id IS NOT NULL
                                   AND CO.cross_charge_code  = 'I')
                                   OR CO.cross_charge_code  = 'N' )
                             )
                )
              )
              AND P.project_id = p_project_id
              AND     iprv.org_id = l_prvdr_org_id;
   END IF; /* If multiorg implemented */

 EXCEPTION
    WHEN NO_DATA_FOUND THEN
        /* This exception should only occur if the provider org id
                 * does not exist in pa_projects_expend_v in which case the
                 * Cross Charge condition is not met and the employee/resource
                 * cannot be used for the project which is having resources
                 * allocated to it.
                 */
        X_CC_OK := 'N';
        x_return_status := NULL;
        x_error_message_code := NULL;
    WHEN NULL_INVALID_PARAMS THEN
                /*
                 * When p_resource_id passed in is invalid.
         */
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_error_message_code := 'PA_RS_OU_DATE_NULL';
    WHEN OTHERS THEN
        X_CC_OK := NULL ; -- 4537865
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        x_error_message_code := NULL;
        RAISE ; -- 4537865
 END CHECK_CC_FOR_RESOURCE;

--
--  PROCEDURE
--              Check_Resource_Belongs_ExpOrg
--  PURPOSE
--              This procedure does the following
--              For the given Resource Id,
--              checks if that resource
--      belongs to an expenditure organization
--  HISTORY
--   22-AUG-2000      P.Bandla       Created
--   11-APR-2001      virangan       Removed join to pa_c_elig_resource_v
--                                   and added joins to base table
--                                   for performance tuning BUG 1713739
--   24-APR-2001      virangan       Changed back to cursor logic for the check
--
 PROCEDURE CHECK_RES_BELONGS_EXPORG(
                p_resource_id          IN      NUMBER,
                x_valid            OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                x_return_status        OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                x_error_message_code   OUT     NOCOPY VARCHAR2)  --File.Sql.39 bug 4440895
 IS
    l_exist VARCHAR2(1):= null;
    l_future_resource VARCHAR2(1);
    l_future_rehire VARCHAR2(1); -- added for bug 8988264
    l_effective_date DATE;
    -- Bug 8567601
    cursor cur_exist(l_res_id in NUMBER, l_date IN date) is
         select 'X'
             from dual
             where exists (select res.resource_id
                           from   pa_resources_denorm res,
                                  pa_all_organizations org
                           where  org.pa_org_use_type  = 'EXPENDITURES'
                           and    org.inactive_date    IS NULL
                           and    org.organization_id  = res.resource_organization_id
                           and    res.resource_id      = p_resource_id
                           and    TRUNC(l_date) between TRUNC(res.resource_effective_start_date) and TRUNC(res.resource_effective_end_date));

 BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_future_resource := is_future_resource( p_resource_id);

    --bug 8988264 : skkoppul
    l_future_rehire := is_future_rehire(p_resource_id);

    IF l_future_resource = 'Y' THEN
       l_effective_date := get_resource_start_date( p_resource_id);
    ELSE
       l_effective_date := sysdate;
    END IF;

    --bug 8988264 : skkoppul the following condition
    IF (l_future_rehire = 'Y' AND l_future_resource = 'N') THEN
        l_effective_date := get_resource_start_date_rehire(p_resource_id);
    ELSE
       l_effective_date := sysdate;
    END IF;

    open cur_exist(p_resource_id, l_effective_date);
    fetch cur_exist into l_exist;
    close cur_exist;

    if l_exist is not null then
        x_valid := 'Y';
    else
        x_valid := 'N';
    end if;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

 EXCEPTION
        WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message_code := 'PA_RES_NOT_EXPORG';
        WHEN OTHERS THEN
          --PA_Error_Utils.Set_Error_Stack
          -- (`pa_job_utils.check_resource_belongs_exporg');
      -- This sets the current program unit name in the
          -- error stack. Helpful in Debugging

      x_valid := NULL ; -- 4537865
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_error_message_code := NULL;

 END CHECK_RES_BELONGS_EXPORG;


--
--  PROCEDURE
--              Check_Resource_Belongs_ExpOrg
--  PURPOSE
--              This is a overloaded procedure which does the following
--              For the given Resource Id, Resource Start Date and Resource End Date
--              checks if that resource
--              belongs to an expenditure organization
--  HISTORY
--   01-JAN-2009      asahoo       Created
--
 PROCEDURE CHECK_RES_BELONGS_EXPORG(
                p_resource_id          IN      NUMBER,
                p_start_date_active    IN      DATE,
                p_end_date_active      IN      DATE,
                x_valid                OUT     NOCOPY VARCHAR2,
                x_return_status        OUT     NOCOPY VARCHAR2,
                x_error_message_code   OUT     NOCOPY VARCHAR2)
 IS
    l_exist VARCHAR2(1):= null;

    cursor cur_exist(l_res_id IN NUMBER,
                     l_start_date_active IN DATE,
                     l_end_date_active IN DATE) is
         select 'X'
             from dual
             where exists (select res.resource_id
                           from   pa_resources_denorm res,
                                  pa_all_organizations org
                           where  org.pa_org_use_type  = 'EXPENDITURES'
                           and    org.inactive_date    IS NULL
                           and    org.organization_id  = res.resource_organization_id
                           and    res.resource_id      = p_resource_id
                           and    l_start_date_active between get_resource_start_date(p_resource_id) and get_resource_end_date(p_resource_id)
                           and    l_end_date_active <=  get_resource_end_date(p_resource_id));
						   -- modified this cursor for bug#9233998

 BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    open cur_exist(p_resource_id, p_start_date_active, p_end_date_active);
    fetch cur_exist into l_exist;
    close cur_exist;

    if l_exist is not null then
        x_valid := 'Y';
    else
        x_valid := 'N';
    end if;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

 EXCEPTION
        WHEN NO_DATA_FOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message_code := 'PA_RES_NOT_EXPORG';
        WHEN OTHERS THEN
          x_valid := NULL ;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          x_error_message_code := NULL;

 END CHECK_RES_BELONGS_EXPORG;
--
-- This procedure is called from form PAXRESSC
--
PROCEDURE set_global_variables( p_selected_flag IN VARCHAR2
                               ,p_person_id     IN PA_EMPLOYEES.PERSON_ID%TYPE
                               ,p_version_id    IN PER_ORG_STRUCTURE_ELEMENTS.ORG_STRUCTURE_VERSION_ID%TYPE
                               ,p_start_org_id  IN PER_ORG_STRUCTURE_ELEMENTS.ORGANIZATION_ID_PARENT%TYPE
                              )
IS
BEGIN

  G_SELECTED_FLAG := p_selected_flag;
  G_PERSON_ID     := p_person_id;
  G_VERSION_ID    := p_version_id;
  G_START_ORG_ID  := p_start_org_id;

END set_global_variables;

--
-- This Function is used by the view pa_org_authority_v.
--
FUNCTION get_selected_flag RETURN VARCHAR2
IS
BEGIN
 RETURN G_SELECTED_FLAG;
END get_selected_flag;

--
-- This Function is used by the view pa_org_authority_v.
--
FUNCTION get_person_id RETURN PA_EMPLOYEES.PERSON_ID%TYPE
IS
BEGIN
 RETURN G_PERSON_ID;
END get_person_id;

--
-- This Function is used by the view pa_org_authority_v.
--
FUNCTION get_version_id RETURN PER_ORG_STRUCTURE_ELEMENTS.ORG_STRUCTURE_VERSION_ID%TYPE
IS
BEGIN
 RETURN G_VERSION_ID;
END get_version_id;

--
-- This Function is used by the view pa_org_authority_v.
--
FUNCTION get_start_org_id RETURN PER_ORG_STRUCTURE_ELEMENTS.ORGANIZATION_ID_PARENT%TYPE
IS
BEGIN
 RETURN G_START_ORG_ID;
END get_start_org_id;

FUNCTION get_period_date RETURN DATE
IS
BEGIN
 RETURN G_PERIOD_DATE;
END;
--
-- This Procedure, receives person_id, org_id and populates the flags corresponding the
-- check-boxes in the form. (Used in PAXRESSC)
--

PROCEDURE populate_role_flags( p_person_id       IN PA_EMPLOYEES.PERSON_ID%TYPE
                              ,p_org_id         IN PER_ORG_STRUCTURE_ELEMENTS.ORGANIZATION_ID_PARENT%TYPE
                              ,x_res_aut_flag   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                              ,x_proj_aut_flag  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                              ,x_prim_ctct_flag OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                  ,x_frcst_aut_flag   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                              ,x_frcst_prim_ctct_flag OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                  ,x_utl_aut_flag  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                             )
IS
  l_role_id FND_GRANTS.MENU_ID%TYPE;
BEGIN
  x_res_aut_flag   := 'N';
  x_proj_aut_flag  := 'N';
  x_prim_ctct_flag := 'N';
  x_frcst_aut_flag   := 'N';
  x_utl_aut_flag  := 'N';
  x_frcst_prim_ctct_flag := 'N';

  l_role_id := pa_security_pvt.get_menu_id('PA_PRM_RES_AUTH');
  IF pa_security_pvt.is_role_exists( 'ORGANIZATION'
                  ,'INSTANCE'
                  ,l_role_id
                  ,p_org_id
                  ,p_person_id
                 ) THEN
    x_res_aut_flag := 'Y';
  END IF;

  l_role_id := pa_security_pvt.get_menu_id('PA_PRM_PROJ_AUTH');
  IF pa_security_pvt.is_role_exists( 'ORGANIZATION'
                  ,'INSTANCE'
                  ,l_role_id
                  ,p_org_id
                  ,p_person_id
                 )
  THEN
    x_proj_aut_flag := 'Y';
  END IF;

  --changed role name to Resource Primary Contact
  l_role_id := pa_security_pvt.get_menu_id('PA_PRM_RES_PRMRY_CONTACT');
  IF pa_security_pvt.is_role_exists( 'ORGANIZATION'
                  ,'INSTANCE'
                  ,l_role_id
                  ,p_org_id
                  ,p_person_id
                 )
  THEN
    x_prim_ctct_flag := 'Y';
  END IF;


/*6519194 for enhancement*/
/*  l_role_id := pa_security_pvt.get_menu_id('PA_PRM_FCST_AUTH');
  IF pa_security_pvt.is_role_exists( 'ORGANIZATION'
                  ,'INSTANCE'
                  ,l_role_id
                  ,p_org_id
                  ,p_person_id) THEN
             x_frcst_aut_flag := 'Y';
  END IF;

  l_role_id := pa_security_pvt.get_menu_id('PA_PRM_FCST_PRMRY_CONTACT');
  IF pa_security_pvt.is_role_exists( 'ORGANIZATION'
            ,'INSTANCE'
                    ,l_role_id
            ,p_org_id
            ,p_person_id) THEN
              x_frcst_prim_ctct_flag := 'Y';
  END IF;
*/
  l_role_id := pa_security_pvt.get_menu_id('PA_PRM_UTL_AUTH');
  IF pa_security_pvt.is_role_exists( 'ORGANIZATION'
                  ,'INSTANCE'
                  ,l_role_id
                  ,p_org_id
                  ,p_person_id) THEN
            x_utl_aut_flag := 'Y';
  END IF;
EXCEPTION -- 4537865
WHEN OTHERS THEN

-- Reset all OUT params
  x_res_aut_flag   := 'N';
  x_proj_aut_flag  := 'N';
  x_prim_ctct_flag := 'N';
  x_frcst_aut_flag   := 'N';
  x_utl_aut_flag  := 'N';
  x_frcst_prim_ctct_flag := 'N';

-- Populate the Error Message
  Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'pa_resource_utils'
                    , p_procedure_name  => 'populate_role_flags'
                    , p_error_text      => SUBSTRB(SQLERRM,1,100));

-- Raise the Error
    RAISE;
END populate_role_flags;

FUNCTION get_organization_name(p_org_id IN HR_ORGANIZATION_UNITS.ORGANIZATION_ID%TYPE)
            RETURN HR_ORGANIZATION_UNITS.NAME%TYPE
IS
  l_org_name HR_ORGANIZATION_UNITS.NAME%TYPE;
BEGIN
-- 4882876 : Adding caching logic
IF G_ORGANIZATION_ID IS NULL OR G_ORGANIZATION_ID <> p_org_id THEN
	G_ORGANIZATION_ID := p_org_id;
	SELECT name
	INTO l_org_name
	FROM hr_organization_units
	WHERE organization_id = p_org_id;
	G_ORGANIZATION_NAME := l_org_name;
ELSIF p_org_id IS NULL THEN  -- Bug 9156671
  G_ORGANIZATION_ID := NULL;
  l_org_name := NULL;
ELSE
	l_org_name := G_ORGANIZATION_NAME;
END IF;

   RETURN l_org_name;
 EXCEPTION
   WHEN OTHERS THEN
     RAISE;
END get_organization_name;

--
-- This procedure is used to insert a INSTANCE/SET into fnd_grants
--
PROCEDURE insert_grant( p_person_id  IN NUMBER
                       ,p_org_id     IN NUMBER
                       ,p_role_name  IN VARCHAR2
                       ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                      )
IS

l_grant_id      FND_GRANTS.GRANT_GUID%TYPE;
l_object_name   FND_OBJECTS.OBJ_NAME%TYPE;
l_role_id       FND_GRANTS.MENU_ID%TYPE;
l_return_status VARCHAR2(30);
l_msg_data      VARCHAR2(2000); -- Changed from 30 to 2000 to avoid ora 6502 error
l_msg_count     NUMBER;
l_set_name      FND_OBJECT_INSTANCE_SETS.INSTANCE_SET_NAME%TYPE;
l_set_id        FND_GRANTS.INSTANCE_SET_ID%TYPE;
BEGIN
l_role_id := PA_SECURITY_PVT.get_menu_id(p_role_name);
--
-- At this point, the global variable for person_id cannot be used,
-- because, the global variable is populated - when the FIND button is
-- pressed.
-- But the resource name could have been entered - AFTER pressing the FIND button.
--
IF p_role_name = 'PA_PRM_RES_AUTH' THEN
  l_object_name := 'PA_RESOURCES';
  l_set_name    := 'PA_RESOURCE_AUTHORITY';
ELSIF p_role_name = 'PA_PRM_PROJ_AUTH' THEN
  l_object_name := 'PA_PROJECTS';
  l_set_name    := 'PA_PROJECT_AUTHORITY';
END IF;
l_set_id := pa_security_pvt.get_instance_set_id(l_set_name);

--
-- First, check whether there is a SET record this role in the table.
-- IF NO,
--   Create SET record.
-- END IF.
-- CREATE the INSTANCE record.
--

--
-- When selected_flag is 'O' its possible that the user may try to grant a
-- role to a resource , which the resource already has. In that case, the following
-- check is necessary.
--
   IF
      --G_SELECTED_FLAG = 'O' AND
      pa_security_pvt.is_role_exists( 'ORGANIZATION'
                                         ,'INSTANCE'
                                         ,l_role_id
                                         ,p_org_id
                                         ,p_person_id
                                        )
   THEN
    --Role already exists.
     return;
   END IF;

        IF p_role_name <> 'PA_PRM_RES_PRMRY_CONTACT' AND
/*        p_role_name <> 'PA_PRM_FCST_AUTH' AND
        p_role_name <> 'PA_PRM_FCST_PRMRY_CONTACT' AND*/ /*6519194 for enhancement*/
        p_role_name <> 'PA_PRM_UTL_AUTH' AND
            NOT pa_security_pvt.is_role_exists(p_object_name   => l_object_name
                                               ,p_object_key_type  => 'INSTANCE_SET'
                                               ,p_role_id          => l_role_id
                                               ,p_object_key       => l_set_id
                                               ,p_party_id         => p_person_id)
        THEN
            --Create the SET record.
            pa_security_pvt.grant_org_authority
              (
                p_commit           => NULL
               ,p_debug_mode       => NULL
           ,p_project_role_id  => NULL
               ,p_menu_name        => p_role_name
               ,p_object_name      => l_object_name
               ,p_object_key_type  => 'INSTANCE_SET'
               ,p_object_key       => l_set_id
               ,p_party_id         => p_person_id
               ,p_source_type      => 'PERSON'
               ,p_start_date       => SYSDATE
               ,p_end_date         => NULL
               ,x_grant_guid         => l_grant_id
               ,x_return_status    => l_return_status
               ,x_msg_count        => l_msg_count
               ,x_msg_data         => l_msg_data
             );

            IF l_return_status <> fnd_api.g_ret_sts_success
            THEN
              x_return_status := l_return_status;
              return;
            END IF;
        END IF;

        --Create the INSTANCE record.
        pa_security_pvt.grant_org_authority
          (
            p_commit           => NULL
           ,p_debug_mode       => NULL
           ,p_project_role_id  => NULL
           ,p_menu_name        => p_role_name
           ,p_object_name      => 'ORGANIZATION'
           ,p_object_key_type  => 'INSTANCE'
           ,p_object_key       => p_org_id
           ,p_party_id         => p_person_id
           ,p_source_type      => 'PERSON'
           ,p_start_date       => SYSDATE
           ,p_end_date         => NULL
           ,x_grant_guid         => l_grant_id
           ,x_return_status    => l_return_status
           ,x_msg_count        => l_msg_count
           ,x_msg_data         => l_msg_data
          );
          IF l_return_status <> 'S'
          THEN
            x_return_status := l_return_status;
            return;
          END IF;

COMMIT;
--4537865
EXCEPTION
WHEN OTHERS THEN
    x_return_status :=  Fnd_Api.G_RET_STS_UNEXP_ERROR;
    Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'pa_resource_utils'
                    , p_procedure_name  => 'insert_grant'
                    , p_error_text      => SUBSTRB(SQLERRM,1,100));
    RAISE;
END insert_grant;

--
-- This procedure is used to delete a INSTANCE/SET from fnd_grants
--
PROCEDURE delete_grant( p_person_id  IN NUMBER
                        ,p_org_id     IN NUMBER
                        ,p_role_name  IN VARCHAR2
                        ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                      )
IS

l_set_id        FND_GRANTS.INSTANCE_SET_ID%TYPE;
l_set_name      FND_OBJECT_INSTANCE_SETS.INSTANCE_SET_NAME%TYPE;
l_object_name   FND_OBJECTS.OBJ_NAME%TYPE;
l_role_id       FND_GRANTS.MENU_ID%TYPE;
l_return_status VARCHAR2(30);
l_msg_data      VARCHAR2(2000); -- Changed from 30 to 2000 to avoid ora 6502 error
l_msg_count     NUMBER;

BEGIN

IF p_role_name = 'PA_PRM_RES_AUTH' THEN
  l_object_name := 'PA_RESOURCES';
  l_set_name := 'PA_RESOURCE_AUTHORITY';
ELSIF p_role_name = 'PA_PRM_PROJ_AUTH' THEN
  l_object_name := 'PA_PROJECTS';
  l_set_name := 'PA_PROJECT_AUTHORITY';
END IF;

--
-- At this point, the global variable for person_id cannot be used,
-- because, the global variable is populated - when the FIND button is
-- pressed.
-- But the resource name could have been entered - AFTER pressing the FIND button.
--

--
-- delete_grant will be called only when G_SELECTED_FLAG is 'R' or 'B'
--

--Call API to delete INSTANCE record.

 pa_security_pvt.revoke_role
  (
   p_commit             => FND_API.G_TRUE
   ,p_debug_mode        => NULL
   ,p_project_role_id   => NULL
   ,p_menu_name         => p_role_name
   ,p_object_name       => 'ORGANIZATION'
   ,p_object_key_type   => 'INSTANCE'
   ,p_object_key        => p_org_id
   ,p_party_id          => p_person_id
   ,p_source_type       => 'PERSON'
   ,x_return_status     => l_return_status
   ,x_msg_count         => l_msg_count
   ,x_msg_data          => l_msg_data
  );
  IF l_return_status <> 'S'
  THEN
    x_return_status := l_return_status;
    return;
  END IF;


--Check if there's any more INSTANCE record available for the combination.
--Call API to delete SET record.

--Added the check if role = Resource Authority or Project Authority
--then delete the SET record if no more INSTANCE records exist.

  IF ((p_role_name = 'PA_PRM_RES_AUTH') or (p_role_name = 'PA_PRM_PROJ_AUTH')) THEN
    l_role_id := PA_SECURITY_PVT.get_menu_id(p_role_name);
    IF NOT pa_security_pvt.is_role_exists ( p_object_name      => 'ORGANIZATION'
                       ,p_object_key_type  => 'INSTANCE'
                       ,p_role_id          => l_role_id
                       ,p_object_key       => NULL
                       ,p_party_id         => p_person_id
                      ) THEN

      -- Delete the INSTANCE_SET record.
      l_set_id := pa_security_pvt.get_instance_set_id(l_set_name);
      pa_security_pvt.revoke_role(
        p_commit             => FND_API.G_TRUE
        ,p_debug_mode        => NULL
            ,p_project_role_id   => NULL
            ,p_menu_name         => p_role_name
        ,p_object_name       => l_object_name
        ,p_object_key_type   => 'INSTANCE_SET'
        ,p_object_key        => l_set_id
        ,p_party_id          => p_person_id
        ,p_source_type       => 'PERSON'
        ,x_return_status     => l_return_status
        ,x_msg_count         => l_msg_count
        ,x_msg_data          => l_msg_data);

      IF l_return_status <> 'S'
      THEN
        x_return_status := l_return_status;
        return;
      END IF;
    END IF;
  END IF;
COMMIT;
--4537865
EXCEPTION
WHEN OTHERS THEN
        x_return_status :=  Fnd_Api.G_RET_STS_UNEXP_ERROR;
        Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'pa_resource_utils'
                    , p_procedure_name  => 'delete_grant'
                    , p_error_text      => SUBSTRB(SQLERRM,1,100));
        RAISE;
END delete_grant;



FUNCTION GetValJobGradeId (P_Job_Id     IN per_jobs.job_id%TYPE,
                           P_Job_Grp_Id IN  per_jobs.job_group_id%TYPE)
                                        RETURN per_valid_grades.grade_id%type

IS

        /*CURSOR grades_sequences is -- commented out for perf bug 4887375
        select
                distinct pg.grade_id,pg.sequence
        from
                per_job_groups pjg,
                per_grades pg,
                per_valid_grades pvg
        where
                pjg.master_flag = 'Y'
        and     pjg.job_group_id = P_Job_Grp_Id
        and     pvg.job_id = P_Job_Id
        and     pg.grade_id = pvg.grade_id
    and     trunc(sysdate) between pvg.date_from and nvl(pvg.date_to,trunc(sysdate))
       UNION
        select
                distinct pg.grade_id,pg.sequence
        from
                per_valid_grades pvg,
                pa_job_relationships pjr,
                per_job_groups pjg,
                per_grades pg
        where
                pjg.master_flag = 'Y'
        and     pjr.from_job_id = P_Job_Id
        and     pjr.to_job_id = pvg.job_id
        and     pjr.to_job_group_id = pjg.job_group_id
        and     pg.grade_id = pvg.grade_id
        and     trunc(sysdate) between pvg.date_from and nvl(pvg.date_to,trunc(sysdate))
       UNION
        select
                distinct pg.grade_id,pg.sequence
        from
                per_valid_grades pvg,
                pa_job_relationships pjr,
                per_job_groups pjg,
                per_grades pg
        where
                pjg.master_flag = 'Y'
        and     pjr.to_job_id = P_Job_Id
        and     pjr.from_job_id = pvg.job_id
        and     pjr.from_job_group_id = pjg.job_group_id
        and     pg.grade_id = pvg.grade_id
        and     trunc(sysdate) between pvg.date_from and nvl(pvg.date_to,trunc(sysdate))
       UNION
        select
                distinct pg.grade_id,pg.sequence
        from
                per_job_groups pjg,
                per_grades pg,
                per_valid_grades pvg
        where   pjg.master_flag = 'N'
        and     pjg.job_group_id = P_Job_Grp_Id
        and     pvg.job_id = P_Job_Id
        and     pg.grade_id = pvg.grade_id
        and     not exists (select null
                            from per_job_groups
                            where master_flag = 'Y')
        and     trunc(sysdate) between pvg.date_from and nvl(pvg.date_to,trunc(sysdate));*/

    l_max_seq per_grades.sequence%TYPE := NULL;
    l_grade_id per_grades.grade_id%TYPE := NULL;
    --grades_seq grades_sequences%ROWTYPE;

BEGIN
    /* This function is not used. comment it out. perf bug 4887375
    open grades_sequences;
    LOOP
        fetch grades_sequences into grades_seq;
        EXIT WHEN grades_sequences%NOTFOUND;

        IF l_max_seq IS NULL THEN
            l_max_seq := grades_seq.sequence;
            l_grade_id := grades_seq.grade_id;
        ELSIF l_max_seq < grades_seq.sequence THEN
            l_max_seq := grades_seq.sequence;
            l_grade_id := grades_seq.grade_id;
        END IF;

    END LOOP;

    close grades_sequences;*/
    return ( l_grade_id );

EXCEPTION
    WHEN OTHERS THEN
        RAISE;

END GetValJobGradeId;


/* --------------------------------------------------------------------
Procedure: GetToJobId
PURPOSE:  This procedure returns the job_id from the job mapping table.
          If the job_group_ids are same, it returns the same job id
          as what is passed in (does not looking into the mapping table
          since there will be no mapping)
-------------------------------------------------------------------- */
PROCEDURE GetToJobId (P_From_Forecast_JobGrpId IN per_jobs.job_group_id%TYPE,
                      P_From_JobId IN per_jobs.job_id%TYPE,
                      P_To_Proj_Cost_JobGrpId IN per_jobs.job_group_id%TYPE,
                      X_To_JobId OUT NOCOPY per_jobs.job_id%TYPE )  --File.Sql.39 bug 4440895
IS

BEGIN

        IF P_From_Forecast_JobGrpId = P_To_Proj_Cost_JobGrpId THEN
           X_To_JobId := P_From_JobId;
        ELSE
          select to_job_id
          into X_To_JobId
          from pa_job_relationships_view
          where from_job_group_id = P_From_Forecast_JobGrpId
          and   to_job_group_id = P_To_Proj_Cost_JobGrpId
          and   from_job_id = P_From_JobId;
        END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        X_To_JobId := NULL;
        WHEN OTHERS THEN
        X_To_JobId :=  NULL ; --4537865
        -- RAISE; Commented RAISE per Review Comment from Rajnish : 4537865

END GetToJobId;

/* --------------------------------------------------------------------
Procedure: GetToJobName
PURPOSE:  This procedure returns the job name from the job mapping table.
          If the job_group_ids are same, it returns the job name
          of the passed in job_id (from the per_jobs_table)
-------------------------------------------------------------------- */
PROCEDURE GetToJobName (P_From_Forecast_JobGrpId IN per_jobs.job_group_id%TYPE,
                        P_From_JobId IN per_jobs.job_id%TYPE,
                        P_To_Proj_Cost_JobGrpId IN per_jobs.job_group_id%TYPE,
                X_To_JobName OUT NOCOPY per_jobs.name%TYPE) --File.Sql.39 bug 4440895
IS

BEGIN

        IF P_From_Forecast_JobGrpId = P_To_Proj_Cost_JobGrpId THEN
           SELECT name
           INTO   X_To_JobName
           FROM   per_jobs
           WHERE  job_id = P_From_JobId
           AND ROWNUM = 1;
        ELSE
           select to_job_name
           into X_To_JobName
           from pa_job_relationships_view
           where from_job_group_id = P_From_Forecast_JobGrpId
           and   to_job_group_id = P_To_Proj_Cost_JobGrpId
           and   from_job_id = P_From_JobId;
        END IF;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
                X_To_JobName := NULL;
        WHEN OTHERS THEN
        X_To_JobName := NULL; -- 4537865
                RAISE;


End GetToJobName;


--
--  PROCEDURE
--              get_resource_analyst
--  PURPOSE
--              This procedure does the following
--              If Person Id is passed ite retrives the corresponding
--              resource analyst Id ,Resource Analyst Name,Primary contact Id ,
--              Name.
--  HISTORY
--   25-SEP-2000      R Iyengar

PROCEDURE get_resource_analyst
                          (P_PersonId             IN NUMBER,
                           P_ResourceIdTab        OUT NOCOPY PLSQLTAB_INTARRAY,
                           P_ResourceAnalystTab   OUT NOCOPY PLSQLTAB_NAMEARRAY,
                           P_PrimaryContactId     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                           P_PrimaryContactName   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                           X_return_Status        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                           X_error_message_code   OUT NOCOPY VARCHAR2) is --File.Sql.39 bug 4440895

        v_validated     VARCHAR2(1);
        v_orgid         per_all_assignments_f.organization_id%TYPE;
        v_roleid        fnd_grants.menu_id%TYPE;
        v_objid         fnd_grants.object_id%TYPE;
        v_resid         fnd_grants.grantee_key%TYPE;
        v_objname       VARCHAR2(25) := 'ORGANIZATION';
        v_rolename      VARCHAR2(30) := 'PA_PRM_RES_AUTH';
        v_primrolename  VARCHAR2(30) := 'PA_PRM_RES_PRMRY_CONTACT';
        v_primroleid     fnd_grants.menu_id%TYPE;
        PersonException EXCEPTION;
        missing_role    EXCEPTION;
        j               NUMBER;

        cursor analystid(objid  fnd_grants.object_id%TYPE,
                     orgid  per_all_assignments_f.organization_id%TYPE,
                     roleid fnd_grants.menu_id%TYPE ) is
                    SELECT  distinct per.person_id
                    FROM   fnd_grants fg, wf_roles wfr, per_all_people_f per
                    WHERE  fg.object_id = objid
                    AND    fg.instance_pk1_value = TO_CHAR(orgid)
                    AND    fg.menu_id = roleid
                    AND    fg.instance_type = 'INSTANCE'
                    AND fg.grantee_key    = wfr.name
                    AND wfr.orig_system    = 'HZ_PARTY'
                    AND per.party_id = wfr.orig_system_id
                    AND sysdate between per.effective_start_date and
                                        per.effective_end_date
                    AND    trunc(SYSDATE) BETWEEN trunc(fg.start_date)
                                  AND     trunc(NVL(fg.end_date, SYSDATE+1));

BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Validate the PersonId

        BEGIN

            SELECT 'Y'
            INTO  v_validated
            FROM  per_all_people_f -- Bug 4684198 - use base table not view
            WHERE person_id = P_PersonId
            AND   trunc(sysdate) BETWEEN effective_start_date
                                 AND     effective_end_date
            -- Bug 4684198 - remove nvl on effective_end_date - col is not null
            AND   rownum = 1;

        EXCEPTION
            WHEN OTHERS THEN
                raise PersonException;
        END;

        IF v_validated <> 'Y' then
                raise PersonException;
        END IF;

        -- pick the Organization id for the Current Assignment
        -- where assignment type is primary type.
        -- it may raise no data found exception if person is not on
        -- current assignment
        SELECT organization_id
        INTO   v_orgid
        FROM   per_all_assignments_f -- Bug 4684198 - use base table not view
        WHERE  person_id = P_PersonId
        AND    trunc(sysdate) BETWEEN effective_start_date
                              AND     effective_end_date
        -- Bug 4684198 - remove nvl on effective_end_date - col is not null
        AND    primary_flag = 'Y'
    AND    assignment_type in ('E', 'C'); /* added for bug 2745823 */

        -- pick the Object id for the organization
        SELECT distinct object_id
        INTO   v_objid
        FROM   fnd_objects
        WHERE  obj_name = v_objname;

        -- get the roleid for the Responsibility of type 'Resource Authority');
        v_roleid := pa_security_pvt.get_menu_id(v_rolename);
        v_Primroleid := pa_security_pvt.get_menu_id(v_primrolename);

        IF (v_Primroleid is  NULL and  v_roleid is  NULL) then
                raise missing_role;
        END IF;

        BEGIN
                SELECT  pep.person_id,
      --distinct to_number(substr(fg.grantee_key,instr(fg.grantee_key,':')+1)),
                        pep.full_name
                INTO    P_PrimaryContactId,P_PrimaryContactName
                FROM   fnd_grants fg,
                       per_all_people_f pep, -- Bug 4684198 - use table
                       wf_roles wfr
                WHERE  fg.object_id = v_objid
                AND    fg.instance_pk1_value = TO_CHAR(v_orgid)
                AND    fg.menu_id = v_Primroleid
                AND    fg.instance_type = 'INSTANCE'
                AND wfr.orig_system    = 'HZ_PARTY'
                AND pep.party_id = wfr.orig_system_id
                -- AND    'PER:' || pep.person_id = fg.grantee_key
                -- AND    pep.person_id = substr(fg.grantee_key,instr(fg.grantee_key,':')+1)
                AND    trunc(SYSDATE) BETWEEN trunc(fg.start_date)
                                      AND     trunc(NVL(fg.end_date, SYSDATE+1))
                AND    trunc(sysdate) BETWEEN pep.effective_start_date
                                      AND     pep.effective_end_date
                AND    wfr.name = fg.grantee_key; -- added for perf bug 4887312
            -- Bug 4684198 - remove nvl on effective_end_date - col is not null

                --dbms_output.put_line(P_primarycontactid||P_primarycontactName);

        EXCEPTION
                WHEN  NO_DATA_FOUND THEN
                       -- x_return_status := FND_API.G_RET_STS_ERROR;
                       -- x_error_message_code := 'PA_RESOURCE_NO_PRIMARY_CONTACT';
                       -- NULL; Commented NULL for 4537865

               P_PrimaryContactId := NULL ; -- 4537865
            P_PrimaryContactName := NULL ; -- 4537865
                WHEN OTHERS THEN
                       -- NULL; 4537865
             P_PrimaryContactId := NULL ; -- 4537865
                        P_PrimaryContactName := NULL ; -- 4537865
        END;
        -- get the  analystid for the Person
        -- initialize the plsqltab value to avoid nodatafound exception
        -- in calling program
          j := 1;
        P_ResourceAnalystTab(1):= NULL;
        P_ResourceIdTab(1) := NULL;
        FOR i IN analystid(v_objid, v_orgid, v_roleid) LOOP
       -- P_ResourceIdTab(j) := to_number(substr(i.grantee_key,instr(i.grantee_key,':')+1));
       P_ResourceIdTab(j) := i.person_id;
                   IF (P_ResourceIdTab(j) is NOT NULL)  then
                        BEGIN
                             SELECT full_name
                             INTO   P_ResourceAnalystTab(j)
                             FROM   per_all_people_f -- Bug 4684198
                             WHERE  person_id = P_ResourceIdTab(j)
                             AND    trunc(sysdate) BETWEEN effective_start_date
                                                   AND     effective_end_date;
            -- Bug 4684198 - remove nvl on effective_end_date - col is not null

                       EXCEPTION
                             WHEN  NO_DATA_FOUND THEN
                               -- x_return_status := FND_API.G_RET_STS_ERROR;
                               -- x_error_message_code := 'PA_RESOURCE_NO_ANALYST';
                                 NULL;
                             WHEN OTHERS THEN
                                 NULL;
                       END;


                             j := j + 1;
                   END IF;
        END LOOP;
          -- if no rows found for the roleid,orgid,objid for a
          -- person then raie exception to avoid no data found in
          -- out paraemter plsql tables - P_ResourceIdTab.
        IF P_ResourceIdTab(1) IS NULL and P_PrimaryContactId is NULL  then
                  x_return_status := FND_API.G_RET_STS_ERROR;
                  x_error_message_code := 'PA_RESOURCE_NO_APPROVAL';
        END IF;
EXCEPTION


        WHEN  PersonException then
          P_PrimaryContactId := NULL ;  --4537865
          P_PrimaryContactName := NULL ; --4537865
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message_code := 'PA_RESOURCE_INVALID_PERSON';

         WHEN  NO_DATA_FOUND THEN

          P_PrimaryContactId := NULL ;  --4537865
          P_PrimaryContactName := NULL ; --4537865

          x_return_status := FND_API.G_RET_STS_ERROR;
          x_error_message_code := 'PA_RESOURCE_INVALID_PERSON';


        WHEN OTHERS THEN  -- will also handle missing role
      P_PrimaryContactId := NULL ;  --4537865
      P_PrimaryContactName := NULL ; --4537865
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          --dbms_output.put_line('missing role exception');
          raise;

end get_resource_analyst ;

--
--  PROCEDURE
--              get_org_primary_contact_id_name
--  PURPOSE
--              This  procedure does the following
--              If Resource Id is passed it retrives the corresponding
--              Primary resoruce contact Id and Name, Manager id and Name.
--
--  HISTORY
--  29-SEP-2000      R Iyengar

PROCEDURE get_prim_contact_id_name(P_objid   IN NUMBER,
                                   P_orgid   IN NUMBER,
                                   P_Primroleid IN NUMBER,
                                   p_start_date IN DATE,
                                   x_PrimaryContactId OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                   x_PrimaryContactName OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                   x_return_status   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                   x_error_message_code OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
BEGIN


                -- initialize the error stack
                PA_DEBUG.init_err_stack('PA_RESOURCE_UTILS.get_prim_contact_id_name');
                -- initialize the return  status to success
                x_return_status := FND_API.G_RET_STS_SUCCESS;


                SELECT  distinct pep.person_id -- changes for 11.5.10 security
                      --  to_number(substr(fg.grantee_key,instr(fg.grantee_key,':')+1))
                        ,pep.full_name
                INTO    x_PrimaryContactId,x_PrimaryContactName
                FROM   fnd_grants fg,
                       per_all_people_f pep,  -- Bug 4684198 - use table
                       wf_roles wfr
                WHERE  fg.object_id = P_objid
                AND    fg.instance_pk1_value = to_char(P_orgid)
                AND    fg.menu_id = P_Primroleid
                AND    fg.instance_type = 'INSTANCE'
                AND    fg.grantee_key   = wfr.name
                AND    wfr.orig_system  = 'HZ_PARTY'
                AND    pep.party_id = wfr.orig_system_id
                AND    trunc(SYSDATE) BETWEEN trunc(fg.start_date)
                                      AND     trunc(NVL(fg.end_date, SYSDATE+1))
               -- AND    'PER:' || pep.person_id = fg.grantee_key --bug 2795616:perfomance
                -- AND    pep.person_id = substr(fg.grantee_key,instr(fg.grantee_key,':')+1)
                AND    p_start_date BETWEEN pep.effective_start_date
                                    AND     pep.effective_end_date
                and (PEP.current_employee_flag = 'Y' or PEP.current_npw_flag = 'Y');
            -- Bug 4684198 - remove nvl on effective_end_date - col is not null

                -- reset the error stack
                PA_DEBUG.reset_err_stack;

        EXCEPTION
                WHEN  NO_DATA_FOUND THEN
                   -- as discussed with Mr.Ramesh,this is not a business rule violation
                   --  so commented
                   --     x_return_status := FND_API.G_RET_STS_ERROR;
                   --     x_error_message_code := 'PA_RESOURCE_NO_ANALYST';

             x_PrimaryContactId := NULL; -- 4537865
                   x_PrimaryContactName := NULL ; -- 4537865

          --  Null; Commented NULL for 4537865

                WHEN OTHERS THEN
           x_PrimaryContactId := NULL; -- 4537865
           x_PrimaryContactName := NULL ; -- 4537865
                   -- this is not business rule violation
                     -- Null; -- Commented null for 4537865


END get_prim_contact_id_name ;

--
--  PROCEDURE
--              get_manager_id_name
-- this  procedure gets the Manager name and id for specified person
-- and called from get_org_primary_contact

PROCEDURE get_manager_id_name(P_personid           IN  NUMBER,
                              p_start_date         IN  DATE,
                              x_ManagerId          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_ManagerName        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_error_message_code OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_return_status      OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
        BEGIN
                -- initialize the error stack
                PA_DEBUG.init_err_stack('PA_RESOURCE_UTILS.get_manager_id_name');
                -- initialize the return  status to success
                x_return_status := FND_API.G_RET_STS_SUCCESS;

                --Modified code for future dated person
                --Manager check is still as of sysdate
                SELECT assn.supervisor_id,pep.full_name
                INTO   x_ManagerId,x_ManagerName
                FROM   per_all_assignments_f assn,per_all_people_f pep
                WHERE  assn.person_id = P_personId
                AND    pep.person_id = assn.supervisor_id
                AND    trunc(p_start_date) BETWEEN assn.effective_start_date /*Bug 8817301 */
                                    AND     assn.effective_end_date
                AND    trunc(sysdate) BETWEEN pep.effective_start_date
                                      AND     pep.effective_end_date
                AND    primary_flag = 'Y'
		AND    assignment_type in ('C', 'E') /* added for bug 2745823 */
                AND ((SELECT per_system_status
                      FROM per_assignment_status_types past
                      WHERE past.assignment_status_type_id = assn.assignment_status_type_id) IN ('ACTIVE_ASSIGN','ACTIVE_CWK')); --Bug#8879958
                -- reset the error stack
                PA_DEBUG.reset_err_stack;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
                   -- as discussed with Mr.Ramesh,this is not a business rule violation
                   --  so commented
                   --     x_return_status := FND_API.G_RET_STS_ERROR;
                   --     x_error_message_code := 'PA_RESOURCE_NO_MANAGER';

              x_ManagerId := NULL ; -- 4537865
              x_ManagerName :=  NULL ; -- 4537865

              /*bug 3737529 - Code addition starts*/
               BEGIN
              SELECT assn.supervisor_id,pep.full_name
              INTO   x_ManagerId,x_ManagerName
              FROM   per_all_assignments_f assn,
                                 per_all_people_f pep
              WHERE  assn.person_id = P_personId
              AND    pep.person_id = assn.supervisor_id
              AND    trunc(p_start_date) BETWEEN assn.effective_start_date /*Bug 8817301 */
                                  AND     assn.effective_end_date
              AND    trunc(sysdate) BETWEEN pep.effective_start_date
                                    AND     pep.effective_end_date
              AND    primary_flag = 'Y'
              AND    assignment_type = 'B';


            EXCEPTION
              WHEN NO_DATA_FOUND THEN
                x_ManagerId := NULL ; -- 4537865
                x_ManagerName :=  NULL ; -- 4537865
               -- l NULL; Commented NULL for 4537865
            END;
              /*bug 3737529 - Code addition ends*/

    WHEN OTHERS THEN
     -- this is not a business rule violation
     x_ManagerId := NULL ; -- 4537865
     x_ManagerName :=  NULL ; -- 4537865
    -- Null; Commented NULL for 4537865

END get_manager_id_name;


--
--  PROCEDURE
--              get_org_id
-- This procedure is called from get_org_primary_contact
PROCEDURE get_org_id(P_personid            IN  NUMBER,
                     p_start_date          IN  DATE,
                     x_orgid               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                     x_error_message_code  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                     x_return_status       OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN

        -- initialize the error stack
        PA_DEBUG.init_err_stack('PA_RESOURCE_UTILS.get_org_id');
        -- initialize the return  status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- pick the Organization id for the Current Assignment
        -- where assignment type is primary type.
        -- may raise exception if the person is not on current assnment
        SELECT organization_id
        INTO   x_orgid
        FROM   per_all_assignments_f
        WHERE  person_id = P_personId
        AND    p_start_date  BETWEEN effective_start_date
                             AND     effective_end_date
        AND    primary_flag = 'Y'
    AND    assignment_type in ('E', 'C'); /* added for bug 2745823 */

        -- reset the error stack
        PA_DEBUG.reset_err_stack;

EXCEPTION
                WHEN OTHERS THEN
                   -- set the exception message and stack
                 --  FND_MSG_PUB.add_exc_msg('PA_RESOURCE_UTILS.get_org_id'
                 --                          ,PA_DEBUG.g_err_stack);
                 --  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                  -- raise;
                 -- null; 4537865
         x_orgid   := NULL ;

END get_org_id;


--
--  PROCEDURE
--              get_person_id
-- This procedure is called from get_org_primary_contact
PROCEDURE get_person_id(P_resourceid          IN  NUMBER,
                        x_personid            OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_error_message_code  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_return_status       OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895


IS
        PersonException         EXCEPTION;
        v_validated             VARCHAR2(1);

BEGIN

        -- initialize the error stack
        PA_DEBUG.init_err_stack('PA_RESOURCE_UTILS.get_person_id');
        -- initialize the return  status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF P_resourceid is NOT NULL  then
                -- may raise too many rows exception
                SELECT Person_id
                INTO   x_personId
                FROM   pa_resource_txn_attributes
                WHERE  resource_id = P_ResourceId;

                IF x_PersonId is NULL then
                        raise PersonException;
                END IF;


             /* The code below is commented out to accomodate
                future dated employees Bug 1944726
              */
             /*
                  -- Validate the PersonId
                BEGIN

                    SELECT 'Y'
                    INTO  v_validated
                    FROM  per_people_f
                    WHERE person_id = x_personId
                    AND   trunc(sysdate) BETWEEN effective_start_date
                    AND   NVL(effective_end_date,sysdate + 1)
                    AND   rownum = 1;

                EXCEPTION
                    WHEN OTHERS THEN
                        raise PersonException;
                END;

                IF v_validated <> 'Y' then
                    raise PersonException;
                END IF;

             */

        END IF;

        -- reset the error stack
        PA_DEBUG.reset_err_stack;


EXCEPTION
        WHEN  NO_DATA_FOUND THEN
        x_PersonId := NULL ; --4537865
                x_error_message_code := 'PA_RESOURCE_INVALID_RESOURCE';
                x_return_status := FND_API.G_RET_STS_ERROR;

        WHEN PersonException then
        x_PersonId := NULL ; -- 4537865
                x_error_message_code := 'PA_RESOURCE_INVALID_PERSON';
                x_return_status := FND_API.G_RET_STS_ERROR;


        WHEN OTHERS THEN
                -- set the exception message and stack
        x_PersonId := NULL ; -- 4537865
                FND_MSG_PUB.add_exc_msg('PA_RESOURCE_UTILS.get_org_id'
                                        ,PA_DEBUG.g_err_stack);
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                raise;

END get_person_id;


PROCEDURE get_object_id(P_objname            IN VARCHAR2,
                        x_objid              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                        x_error_message_code OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_return_status      OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN

        -- initialize the error stack
        PA_DEBUG.init_err_stack('PA_RESOURCE_UTILS.get_object_id');
        -- initialize the return  status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;


       -- pick the Object id for the organization (seeded data)
        SELECT distinct object_id
        INTO   x_objid
        FROM   fnd_objects
        WHERE  obj_name = P_objname;


        -- reset the error stack
        PA_DEBUG.reset_err_stack;

EXCEPTION
        WHEN OTHERS THEN
        x_objid := NULL ; -- 4537865
                    -- 4537865  Null;


END get_object_id;


--
--  PROCEDURE
--              get_org_primary_contact
--  PURPOSE
--              This  procedure does the following
--              If Resource Id is passed it retrives the corresponding
--              resource primary contact Id , Name,Managerid and manager name.
--  HISTORY
--
--  29-SEP-2000      R Iyengar   created
--  05-SEP-2001      Vijay Ranganathan  Added p_assignment_id parameter
PROCEDURE get_org_primary_contact
                          (p_ResourceId           IN  NUMBER,
                           p_assignment_id        IN  NUMBER,
                           x_PrimaryContactId     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                           x_PrimaryContactName   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                           x_ManagerId            OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                           x_ManagerName          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                           x_return_Status        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                           x_msg_count            OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                           x_msg_data             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                           ) is

        v_personId              NUMBER;
        v_numrows               NUMBER;
        v_orgid                 per_all_assignments_f.organization_id%TYPE;
        v_objid                 fnd_grants.object_id%TYPE;
        --v_resid                 fnd_grants.grantee_key%TYPE;
        v_objname               VARCHAR2(25) := 'ORGANIZATION';
        v_primrolename          VARCHAR2(30) := 'PA_PRM_RES_PRMRY_CONTACT';
        v_primroleid            fnd_grants.menu_id%TYPE;
        v_error_message_code    fnd_new_messages.message_name%TYPE;
        v_return_status         VARCHAR2(1);
        v_msg_data              VARCHAR2(2000);
        v_msg_count             NUMBER;
        v_msg_index_out         NUMBER;
        l_start_date            DATE;

BEGIN
       -- initialize the error stack
       PA_DEBUG.init_err_stack('PA_RESOURCE_UTILS.get_org_primary_contact');

       -- initialize the return status to success
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       IF p_assignment_id IS NULL THEN
          l_start_date := sysdate;
       ELSE
          --Get the assignment start date
           BEGIN
              SELECT start_date
              INTO   l_start_date
              FROM   pa_project_assignments
              WHERE  assignment_id = p_assignment_id
              ;
           EXCEPTION
              WHEN OTHERS THEN
                l_start_date := sysdate;
           END;
       END IF;

       -- Added for bug 7623859
       IF (sysdate > l_start_date) THEN
         l_start_date := sysdate;
       END IF;

       -- get the person id for resource id
        get_person_id(P_ResourceId
                     ,v_personid
                     ,v_error_message_code
                     ,v_return_status);
        --check for return status if error found then add it to stack
        IF v_return_status =  FND_API.G_RET_STS_ERROR THEN
           PA_UTILS.add_message(p_app_short_name => 'PA',
                                p_msg_name => v_error_message_code);
        END IF;

       -- get the organization id for the name for the person
       get_org_id(v_personid
                 ,l_start_date
                 ,v_orgid
                 ,v_error_message_code
                 ,v_return_status);
        IF v_return_status =  FND_API.G_RET_STS_ERROR THEN
           PA_UTILS.add_message(p_app_short_name => 'PA',
                                p_msg_name       => v_error_message_code);
        END IF;


     -- get object id for the object name
       get_object_id(v_objname
                    ,v_objid
                    ,v_error_message_code
                    ,v_return_status);


        IF v_return_status =  FND_API.G_RET_STS_ERROR THEN
           PA_UTILS.add_message(p_app_short_name => 'PA',
                                p_msg_name => v_error_message_code);
        END IF;


       -- get the roleid for the Responsibility of type 'Primary Resource Contact'
       v_Primroleid := pa_security_pvt.get_menu_id(v_primrolename);
      -- get primary contact name and id
      get_prim_contact_id_name(v_objid
                              ,v_orgid
                              ,v_Primroleid
                              ,l_start_date
                              ,x_PrimaryContactId
                              ,x_PrimaryContactName
                              ,v_return_status
                              ,v_error_message_code );

        IF v_return_status =  FND_API.G_RET_STS_ERROR THEN
           PA_UTILS.add_message(p_app_short_name => 'PA',
                                p_msg_name => v_error_message_code);
        END IF;


       -- get manager name and id
       get_manager_id_name(v_personid
                          ,l_start_date
                          ,x_ManagerId
                          ,x_ManagerName
                          ,v_error_message_code
                          ,v_return_status);
        IF v_return_status =  FND_API.G_RET_STS_ERROR THEN
           PA_UTILS.add_message(p_app_short_name => 'PA',
                                p_msg_name => v_error_message_code);
        END IF;

        -- as discussed with Ms.Angela if both manager and primary contact  is null
        -- then  pass the error messages.
        IF (x_ManagerId is NULL and x_primarycontactid is NULL) then
                    PA_UTILS.add_message(p_app_short_name => 'PA',
                                p_msg_name => 'PA_RESOURCE_NO_APPROVAL');
                    x_return_status := FND_API.G_RET_STS_ERROR;

        END IF;

      v_msg_count := FND_MSG_PUB.count_msg;

      -- if num of message is one then pass it to out parameter x_msg_data
      IF v_msg_count = 1 and (x_ManagerId is NULL and x_primarycontactid is NULL) then
          PA_INTERFACE_UTILS_PUB.get_messages(
                        p_encoded  => FND_API.G_TRUE
                       ,p_msg_index => 1
                       ,p_msg_count => v_msg_count
                       ,p_data      => v_msg_data
                       ,p_msg_index_out => v_msg_index_out);
          x_msg_data := v_msg_data;
          x_msg_count := v_msg_count;
      ELSE
          x_msg_count := v_msg_count;
      END IF;

        -- reset the error stack
        PA_DEBUG.reset_err_stack;


EXCEPTION

        WHEN OTHERS THEN

        -- Reset OUT params : 4537865
        x_PrimaryContactId := NULL ;
        x_PrimaryContactName  :=  NULL ;
                x_ManagerId  := NULL;
                x_ManagerName      := NULL ;
                x_return_Status    := NULL ;

                -- set the exception message and stack
                FND_MSG_PUB.add_exc_msg('PA_RESOURCE_UTILS.get_org_primary_contact'
                                        ,PA_DEBUG.g_err_stack);
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                --      dbms_output.put_line('missing');
                raise;


end get_org_primary_contact ;

FUNCTION get_resource_id(P_Person_Id IN NUMBER)
RETURN NUMBER
IS
l_resource_id NUMBER;
BEGIN

   SELECT resource_id
   INTO l_resource_id
   FROM pa_resource_txn_attributes
   WHERE person_id = p_person_id;

   RETURN l_resource_id;
EXCEPTION
  WHEN OTHERS THEN
       RETURN -999;
END get_resource_id;

-- Changes for BUG: 1660614 are as follows.
--      Added parameter p_date in DATE
--      The above parameter p_date stands for period_end_date
--      and is used instead of sysdate used before
-- Changes for Organization Utilization performance improvements
-- Logic uses PA_RESOURCES_DENORM table instead of PER_ASSIGNMENTS_F
FUNCTION Get_People_Assigned(p_org_id in pa_resources_denorm.resource_organization_id%TYPE,
                             p_date in DATE,
			     p_emp_type IN VARCHAR DEFAULT 'EMP') RETURN NUMBER --Added p_emp_type for bug 5680366
IS
 l_count NUMBER;
BEGIN
/* Commented for bug 5680366
  select count(*) into l_count
  from   pa_resources_denorm
  where  resource_organization_id   = p_org_id
  and    p_date between resource_effective_start_date and resource_effective_end_date;
*/

IF p_emp_type = 'EMP' THEN -- Added IF for 5680366
  select count(*) into l_count
  from   pa_resources_denorm
  where  resource_organization_id   = p_org_id
  and    p_date between resource_effective_start_date and resource_effective_end_date
  AND    RESOURCE_PERSON_TYPE = 'EMP';
ELSIF p_emp_type = 'CWK' THEN -- Added ELSE for 5680366
  select count(*) into l_count
  from   pa_resources_denorm
  where  resource_organization_id   = p_org_id
  and    p_date between resource_effective_start_date and resource_effective_end_date
  AND    RESOURCE_PERSON_TYPE = 'CWK';
ELSE ---Same as earlier
  select count(*) into l_count
  from   pa_resources_denorm
  where  resource_organization_id   = p_org_id
  and    p_date between resource_effective_start_date and resource_effective_end_date;
END IF;

  --dbms_output.put_line('Count in Get_People_Assigned =  '|| to_char(l_count));
  return l_count;

EXCEPTION
 WHEN NO_DATA_FOUND THEN
   return 0;
 WHEN OTHERS THEN
   return -999;
END Get_People_Assigned;

--
--  FUNCTION
--              Get_Resource_Headcount
--  PURPOSE
--              This  function gets the resource head count for a given
--              organization, category, period type, period name, Global
--              week end date and year.
--
--  HISTORY     Changes for BUG: 1660614
--              Added the following new parameters:
--              p_category : This could be one of the following.
--                         1. SUBORG_EMP - Includes all subordinate excluding the direct reports
--                         2. DIRECT_EMP - Includes all the direct reports
--                         3. TOTAL_EMP - Includes all subordinates
--              p_period_type: Possible values are GL - gl period, GE - global expenditure
--                             week, PA - pa period, QR - quarter, YR - year
--              p_period_name: Values only for GL and PA periods, Quarter number for QR
--              p_end_date: Only for global expenditure week GE
--              p_year : For YR and QR types - pass the year
--              Changes for Performance enhancement of Organization Utilization page
--              For GL, PA, QR and YR period types the where clause
--              uses base tables instead of pa_rep_periods_dates_v
FUNCTION Get_Resource_Headcount(p_org_id IN NUMBER,
                p_category IN VARCHAR2,
                                p_period_type IN VARCHAR2,
                                p_period_name IN VARCHAR2,
                                p_end_date in DATE,
                                p_year in NUMBER) RETURN NUMBER
    IS
    --MOAC Changes : Bug 4363092: Get the value of org from PA_MOAC_UTILS.GET_CURRENT_ORG_ID
/*      CURSOR c_suborg(p_org_id in pa_resources_denorm.resource_organization_id%TYPE) IS
        select org.child_organization_id c_org
        from   pa_org_hierarchy_denorm org,
               pa_implementations imp
        where  org.parent_organization_id         = p_org_id
        and    org.parent_level - org.child_level = 1
        and    org.pa_org_use_type                = 'REPORTING'
        and    org.org_hierarchy_version_id       = imp.org_structure_version_id
        and    nvl(org.org_id,nvl(to_number(decode(substr(userenv('client_info'),1,1),' ',null,
               substr(userenv('client_info'),1,10))), -99)) =
                 nvl(to_number(decode(substr(userenv('client_info'),1,1),' ',null,substr(userenv('client_info'),1,10))),-99)
        order by org.child_organization_id; */
        CURSOR c_suborg(p_org_id in pa_resources_denorm.resource_organization_id%TYPE) IS
        select org.child_organization_id c_org
        from   pa_org_hierarchy_denorm org,
               pa_implementations imp
        where  org.parent_organization_id         = p_org_id
        and    org.parent_level - org.child_level = 1
        and    org.pa_org_use_type                = 'REPORTING'
        and    org.org_hierarchy_version_id       = imp.org_structure_version_id
        and    nvl(org.org_id,NVL(PA_MOAC_UTILS.GET_CURRENT_ORG_ID,-99)) = NVL(PA_MOAC_UTILS.GET_CURRENT_ORG_ID,-99)
        order by org.child_organization_id;

        l_count  NUMBER := 0;
        l_num    NUMBER := 0 ;

        l_org_sub_count       PA_PLSQL_DATATYPES.NumTabTyp;
        l_org_direct_count    PA_PLSQL_DATATYPES.NumTabTyp;

        l_date                DATE;

BEGIN

        IF (p_period_type = 'GL') THEN

      select glp.end_date into l_date
          from   gl_periods glp,
                 gl_sets_of_books glsob,
                 pa_implementations pai
          where  pai.set_of_books_id         = glsob.set_of_books_id
          and    glsob.period_set_name       = glp.period_set_name
          and    glsob.accounted_period_type = glp.period_type
          and    glp.period_name             = p_period_name;

        ELSIF (p_period_type = 'PA') THEN
              /* code commented for  Bug 2634995
                       select pap.pa_end_date into l_date
                       from   pa_periods_v pap,
                              pa_implementations pai
                       where  pap.period_name     = p_period_name
                       and    pai.set_of_books_id = pap.set_of_books_id;
              */

            /* Select from pa_periods_v is replaced by view definition for Perfomance
               Bug 2634995        */
            SELECT pap.end_date
            INTO   l_date
            FROM   PA_PERIODS PAP,
                   GL_PERIOD_STATUSES GLP,
                   PA_IMPLEMENTATIONS PAIMP,
                   PA_LOOKUPS PAL
            WHERE PAP.period_name  = p_period_name
            AND   PAP.GL_PERIOD_NAME = GLP.PERIOD_NAME
            AND   GLP.SET_OF_BOOKS_ID = PAIMP.SET_OF_BOOKS_ID
            AND   GLP.APPLICATION_ID = Pa_Period_Process_Pkg.Application_id
            AND   GLP.ADJUSTMENT_PERIOD_FLAG = 'N'
            AND   GLP.CLOSING_STATUS = PAL.LOOKUP_CODE /*Added for bug 5484203*/
            AND   PAL.LOOKUP_TYPE = 'CLOSING STATUS';


        ELSIF (p_period_type = 'YR') THEN

          select max(glp.end_date)
          into l_date
          from   gl_periods glp,
                 gl_sets_of_books glsob,
                 pa_implementations pai
          where  pai.set_of_books_id         = glsob.set_of_books_id
          and    glsob.period_set_name       = glp.period_set_name
          and    glsob.accounted_period_type = glp.period_type
          and    glp.period_year             = p_year;

        ELSIF (p_period_type = 'QR') THEN

          select max(glp.end_date)
          into l_date
          from   gl_periods glp,
                 gl_sets_of_books glsob,
                 pa_implementations pai
          where  pai.set_of_books_id         = glsob.set_of_books_id
          and    glsob.period_set_name       = glp.period_set_name
          and    glsob.accounted_period_type = glp.period_type
          and    glp.quarter_num             = to_number(p_period_name)
          and    glp.period_year             = p_year;

        ELSE
          l_date := p_end_date;
        END IF;
	/*
		Bug5680366	1.Added conditions for 'SUBORG_OTHERS' , 'DIRECT_OTHERS' and 'TOTALS_OTHERS' based on
				'SUBORG_EMP' , 'DIRECT_EMP' and 'TOTALS_EMP' resp.
	`			2.Added 'EMP' param for EMPs and 'CWK' param for OTHERs  in Get_People_Assigned
	*/
        IF (p_category = 'SUBORG_EMP') THEN
          IF  not l_org_sub_count.exists(p_org_id) THEN
            FOR eRec IN c_suborg(p_org_id) LOOP
              --  l_num := Get_People_Assigned(eRec.c_org,l_date);
                l_num := get_resource_headcount(eRec.c_org,'TOTALS_EMP',p_period_type,p_period_name,l_date,p_year);
                l_count := l_count + l_num ;
             END LOOP;
             l_org_sub_count(p_org_id) := l_count;
           ELSE
             l_count := l_org_sub_count(p_org_id);
           END IF;
        ELSIF (p_category = 'DIRECT_EMP') THEN
           IF  not l_org_direct_count.exists(p_org_id) THEN
               l_count := Get_People_Assigned(p_org_id,l_date);
               l_org_direct_count(p_org_id) := l_count;
           ELSE
               l_count := l_org_direct_count(p_org_id);
           END IF;
        ELSIF (p_category = 'TOTALS_EMP') THEN
           IF  not l_org_sub_count.exists(p_org_id) and not l_org_direct_count.exists(p_org_id) THEN
                l_count := Get_People_Assigned(p_org_id,l_date) + get_resource_headcount(p_org_id,'SUBORG_EMP',p_period_type,p_period_name,p_end_date,p_year);
           ELSE
                l_count := l_org_sub_count(p_org_id) + l_org_direct_count(p_org_id);
           END IF;
	ELSIF (p_category = 'SUBORG_OTHERS') THEN --Added for bug 5680366
          IF  not l_org_sub_count.exists(p_org_id) THEN
            FOR eRec IN c_suborg(p_org_id) LOOP
              --  l_num := Get_People_Assigned(eRec.c_org,l_date);
                l_num := get_resource_headcount(eRec.c_org,'TOTALS_OTHERS',p_period_type,p_period_name,l_date,p_year);
                l_count := l_count + l_num ;
             END LOOP;
             l_org_sub_count(p_org_id) := l_count;
           ELSE
             l_count := l_org_sub_count(p_org_id);
           END IF;
        ELSIF (p_category = 'DIRECT_OTHERS') THEN --Added for bug 5680366
           IF  not l_org_direct_count.exists(p_org_id) THEN
               l_count := Get_People_Assigned(p_org_id,l_date,'CWK');
               l_org_direct_count(p_org_id) := l_count;
           ELSE
               l_count := l_org_direct_count(p_org_id);
           END IF;
        ELSIF (p_category = 'TOTALS_OTHERS') THEN --Added for bug 5680366
           IF  not l_org_sub_count.exists(p_org_id) and not l_org_direct_count.exists(p_org_id) THEN
                l_count := Get_People_Assigned(p_org_id,l_date,'CWK') + get_resource_headcount(p_org_id,'SUBORG_OTHERS',p_period_type,p_period_name,p_end_date,p_year);
           ELSE
                l_count := l_org_sub_count(p_org_id) + l_org_direct_count(p_org_id);
           END IF;
        END IF;
        return l_count;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
        --dbms_output.put_line('No Data Found');
        return 10;
   WHEN OTHERS THEN
        return -999;
END Get_Resource_Headcount;

/* --------------------------------------------------------------------
--  FUNCTION
--              Get_Period_Date
--  PURPOSE
--              This  function returns the period date for the following
--              types of periods:
--                GL - gl period
--                GE - global expenditure week
--                PA - pa period
--                QR - quarter
--                YR - year
--  ARGUMENTS
--
--              p_period_name: Values only for GL and PA periods, Quarter
--                             number for QR
--              p_end_date:    Only for global expenditure week GE
--              p_year :       For YR and QR types - pass the year
 -------------------------------------------------------------------- */

PROCEDURE Set_Period_Date(p_period_type IN VARCHAR2,
                          p_period_name IN VARCHAR2,
                          p_end_date    IN DATE,
                          p_year        IN NUMBER)
IS

  l_date                DATE;

BEGIN

        IF (p_period_type = 'GL') THEN

      select glp.start_date into l_date
          from   gl_periods glp,
                 gl_sets_of_books glsob,
                 pa_implementations pai
          where  pai.set_of_books_id         = glsob.set_of_books_id
          and    glsob.period_set_name       = glp.period_set_name
          and    glsob.accounted_period_type = glp.period_type
          and    glp.period_name             = p_period_name;

        ELSIF (p_period_type = 'PA') THEN

          /* code commented for  Bug 2634995
           select pap.pa_start_date into l_date
          from   pa_periods_v pap,
                 pa_implementations pai
          where  pap.period_name     = p_period_name
          and    pai.set_of_books_id = pap.set_of_books_id;
          */

          /* Select from pa_periods_v is replaced by view definition for Perfomance
             Bug 2634995        */

            SELECT pap.start_date
            INTO   l_date
            FROM   PA_PERIODS PAP,
                   GL_PERIOD_STATUSES GLP,
                   PA_IMPLEMENTATIONS PAIMP,
                   PA_LOOKUPS PAL
            WHERE PAP.period_name  = p_period_name
            AND   PAP.GL_PERIOD_NAME = GLP.PERIOD_NAME
            AND   GLP.SET_OF_BOOKS_ID = PAIMP.SET_OF_BOOKS_ID
            AND   GLP.APPLICATION_ID = Pa_Period_Process_Pkg.Application_id
            AND   GLP.ADJUSTMENT_PERIOD_FLAG = 'N'
            AND   PAL.LOOKUP_TYPE = 'CLOSING STATUS';

        ELSIF (p_period_type = 'YR') THEN

          select min(glp.start_date)
          into l_date
          from   gl_periods glp,
                 gl_sets_of_books glsob,
                 pa_implementations pai
          where  pai.set_of_books_id         = glsob.set_of_books_id
          and    glsob.period_set_name       = glp.period_set_name
          and    glsob.accounted_period_type = glp.period_type
          and    glp.period_year             = p_year;

        ELSIF (p_period_type = 'QR') THEN

          select min(glp.start_date)
          into l_date
          from   gl_periods glp,
                 gl_sets_of_books glsob,
                 pa_implementations pai
          where  pai.set_of_books_id         = glsob.set_of_books_id
          and    glsob.period_set_name       = glp.period_set_name
          and    glsob.accounted_period_type = glp.period_type
          and    glp.quarter_num             = to_number(p_period_name)
          and    glp.period_year             = p_year;

        ELSE
          l_date := p_end_date - 6;
        END IF;

        PA_RESOURCE_UTILS.G_PERIOD_DATE := l_date;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
        PA_RESOURCE_UTILS.G_PERIOD_DATE := sysdate - 50 * 365;
   WHEN OTHERS THEN
        PA_RESOURCE_UTILS.G_PERIOD_DATE := sysdate - 50 * 365;
END Set_Period_Date;

FUNCTION get_resource_manager_id(p_user_id IN NUMBER) RETURN NUMBER IS
   l_root_manager_id NUMBER;
BEGIN
   SELECT employee_id
   INTO l_root_manager_id
   FROM  fnd_user
   WHERE user_id = p_user_id;
   RETURN l_root_manager_id;
EXCEPTION
 WHEN NO_DATA_FOUND THEN
   return 0;
 WHEN OTHERS THEN
   return -999;
END get_resource_manager_id;

--  PROCEDURE
--              get_resource_capacity
--  PURPOSE
--              This function returns the capacity hours for a resource
--              for the given week. If capacity = 0 it returns 1
--  HISTORY
--  14-MAR-2001 virangan created
--  27-APR-2001 virangan modified code to return 1 if capacity = 0
--  29-APR-2001 virangan modified assigned hours to be from res_asgn
--                       table instead of proj_asgn
--  07-MAY-2001 virangan  Removed group by clause for performance
--                        Bug 1767793
--  21-MAY-2001 virangan  Removed join to row label table
--

FUNCTION get_resource_capacity(res_id IN NUMBER, week_start_date IN DATE)
                               RETURN NUMBER
  IS
     capacity NUMBER;

BEGIN

  BEGIN

     SELECT sum(capacity_quantity)
     INTO   capacity
     FROM   pa_forecast_items
     WHERE  resource_id      = res_id
     AND    delete_flag      = 'N'
     AND    forecast_item_type = 'U'
     AND    item_date  between week_start_date
                       and     week_start_date + 6;
  EXCEPTION
        WHEN NO_DATA_FOUND THEN
             capacity := 0;
  END;

  --The following logic is used because resource capacity
  --is used in denomonator in Staffing Home page
  IF ( capacity = 0) then
      RETURN 1;
  ELSE
      RETURN  capacity;
  END IF;

END get_resource_capacity;


--  PROCEDURE
--              Get_Current_Project_NameNumber
--  PURPOSE
--              This function has been created for CURRENT_PROJECT_NAME_NUMBER column
--              of pa_resource_availability_v. This will return the project namd and
--              number in the format: project_name(project_number).
--
--  HISTORY
--  09-APR-2001 snam  Created
FUNCTION Get_Current_Project_NameNumber(p_resource_id IN NUMBER)
RETURN VARCHAR2
IS
  l_proj_name_number varchar2(65);
  l_project_id NUMBER;
BEGIN
  -- reset current_project_id before set it up again
  PA_RESOURCE_UTILS.G_CURRENT_PROJECT_ID := NULL;

-- 4778041 : For performance , removed join of pa_resources_denorm
  SELECT proj.name || '(' || proj.segment1 || ')',
         proj.project_id
    INTO l_proj_name_number,
         l_project_id
    FROM --pa_resources_denorm res,
         pa_project_assignments asgmt,
         pa_projects_all proj,
         pa_project_statuses ps
   WHERE --trunc(sysdate) between trunc(res.resource_effective_start_date)
         --               and trunc(res.resource_effective_end_date)
         --AND  res.resource_id = asgmt.resource_id
         --AND  res.resource_id = p_resource_id
	      asgmt.resource_id = p_resource_id
         AND  trunc(sysdate) BETWEEN trunc(asgmt.start_date) and trunc(asgmt.end_date)
         AND  asgmt.project_id = proj.project_id
         AND  asgmt.status_code  = ps.project_status_code
         AND  ps.project_system_status_code = 'STAFFED_ASGMT_CONF'
         AND  rownum=1;

 -- set current project_id to the global variable so that we can get it from
 -- the procedure 'Get_Current_Project_Id'
 G_CURRENT_PROJECT_ID := l_project_id;

 RETURN l_proj_name_number;

 EXCEPTION
   WHEN NO_DATA_FOUND THEN
     RETURN null;
   WHEN OTHERS THEN
     RETURN null;
END Get_Current_Project_NameNumber;

--  PROCEDURE
--              Get_Current_Project_Id
--  PURPOSE
--              This function has been created for CURRENT_PROJECT_ID column
--              of pa_resource_availability_v. This procedure should be called after
--              calling 'Get_Current_Project_NameNumber'.
--
--  HISTORY
--  09-APR-2001 snam  Created
FUNCTION Get_Current_Project_Id(p_resource_id IN NUMBER)
RETURN NUMBER
IS
BEGIN
  return PA_RESOURCE_UTILS.G_CURRENT_PROJECT_ID;

END  Get_Current_Project_Id;

--  PROCEDURE
--              Get_Person_name
--  PURPOSE
--              This procedure returns the persons name for
--              a given person_id
--
--  HISTORY
--              10-MAY-2001  created  virangan
--
PROCEDURE get_person_name (     p_person_id           IN  NUMBER,
                                x_person_name         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_return_status       OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN

        -- initialize the error stack
        PA_DEBUG.init_err_stack('PA_RESOURCE_UTILS.get_person_name');
        -- initialize the return  status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF p_person_id IS NOT NULL  then

/* changed the select statement to be based on per_all_people_f and added
the sysdate condition for bug 2983491 */

                SELECT full_name
                INTO   x_person_name
                FROM   per_all_people_f
                WHERE  person_id   =  p_person_id
        AND    EFFECTIVE_START_DATE = (SELECT MIN(EFFECTIVE_START_DATE)  FROM   per_all_people_f
                                                WHERE  person_id   =  p_person_id
                                        and trunc(EFFECTIVE_END_DATE) >= trunc(sysdate));

                --AND    TRUNC(SYSDATE) BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE;
                --Bug 3877472 The AND condition in where clause is changed so as to include future dated employees also.
        ELSE
               x_person_name := null;
        END IF;

        -- reset the error stack
        PA_DEBUG.reset_err_stack;

EXCEPTION
        WHEN  NO_DATA_FOUND THEN
                x_person_name := null;
                x_return_status := FND_API.G_RET_STS_ERROR;

        WHEN OTHERS THEN

        -- RESET OUT PARAM 4537865
        x_person_name := null;

                -- set the exception message and stack
                FND_MSG_PUB.add_exc_msg('PA_RESOURCE_UTILS.get_person_name'
                                        ,PA_DEBUG.g_err_stack);
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                raise;

END get_person_name;

--  PROCEDURE
--              Get_Location_Details
--  PURPOSE
--              This procedure returns  location details for
--              given location id
--
--  HISTORY
--              10-MAY-2001  created  virangan
--
PROCEDURE get_location_details (p_location_id         IN  NUMBER,
                                x_address_line_1      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_address_line_2      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_address_line_3      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_town_or_city        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_postal_code         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_country             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_return_status       OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN

        -- initialize the error stack
        PA_DEBUG.init_err_stack('PA_RESOURCE_UTILS.get_location_details');
        -- initialize the return  status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF p_location_id IS NOT NULL  then

                SELECT address_line_1,
                       address_line_2,
                       address_line_3,
                       town_or_city,
                       postal_code,
                       country
                INTO   x_address_line_1,
                       x_address_line_2,
                       x_address_line_3,
                       x_town_or_city,
                       x_postal_code,
                       x_country
                FROM   hr_locations
                WHERE  location_id   = p_location_id;

        ELSE
               x_address_line_1 := null;
               x_address_line_2 := null;
               x_address_line_3 := null;
               x_town_or_city := null;
               x_postal_code := null;
               x_country := null;
        END IF;

        -- reset the error stack
        PA_DEBUG.reset_err_stack;

EXCEPTION
        WHEN  NO_DATA_FOUND THEN
                x_address_line_1 := null;
                x_address_line_2 := null;
                x_address_line_3 := null;
                x_town_or_city := null;
                x_postal_code := null;
                x_country := null;
                x_return_status := FND_API.G_RET_STS_ERROR;

        WHEN OTHERS THEN
        -- RESET OUT PARAMS 4537865
        x_address_line_1 := null;
                x_address_line_2 := null;
                x_address_line_3 := null;
                x_town_or_city := null;
                x_postal_code := null;
                x_country := null;

                -- set the exception message and stack
                FND_MSG_PUB.add_exc_msg('PA_RESOURCE_UTILS.get_location_details'
                                        ,PA_DEBUG.g_err_stack);
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                raise;

END get_location_details;

--  PROCEDURE
--              Get_Org_Defaults
--  PURPOSE
--              This procedure returns the default operating unit and default
--              calendar for an organization
--
--  HISTORY
--              10-MAY-2001  created  virangan
--
PROCEDURE get_org_defaults (p_organization_id           IN  NUMBER,
                            x_default_ou                OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                            x_default_cal_id            OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                            x_return_status             OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN

        -- initialize the error stack
        PA_DEBUG.init_err_stack('PA_RESOURCE_UTILS.get_org_defaults');
        -- initialize the return  status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF p_organization_id IS NOT NULL  then
                -- split into two separate selects - one for OU and one
                -- for Calendar

                BEGIN
                SELECT to_number(ou.org_information1)
                INTO   x_default_ou
                FROM   hr_organization_information ou
                WHERE  ou.org_information_context = 'Exp Organization Defaults'
                AND    ou.organization_id         = p_organization_id
                AND    rownum                  = 1;

                EXCEPTION WHEN OTHERS THEN
                   x_default_ou := NULL;
                END;

                BEGIN
                SELECT to_number(cal.org_information1)
                INTO   x_default_cal_id
                FROM   hr_organization_information cal-- R12 HR Org Info change
                WHERE  cal.organization_id         = p_organization_id
                AND    cal.org_information_context = 'Resource Defaults'
                AND    rownum                      = 1;

                EXCEPTION WHEN OTHERS THEN
                   x_default_cal_id := NULL;
                END;
        ELSE
               x_default_ou := null;
               x_default_cal_id := null;
        END IF;

        -- reset the error stack
        PA_DEBUG.reset_err_stack;

EXCEPTION
        WHEN  NO_DATA_FOUND THEN
                x_default_ou := null;
                x_default_cal_id := null;

        WHEN OTHERS THEN

        -- RESET OUT PARAMS 4537865
        x_default_ou := null;
                x_default_cal_id := null;

                -- set the exception message and stack
                FND_MSG_PUB.add_exc_msg('PA_RESOURCE_UTILS.get_org_defaults'
                                        ,PA_DEBUG.g_err_stack);
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                raise;

END get_org_defaults;


--  PROCEDURE
--              Check_Exp_Org
--  PURPOSE
--              This procedure checks if an organization belongs
--              to an expenditure hierarchy or not
--
--  HISTORY
--              10-MAY-2001  created  virangan
--
--              04-DEC-2002  sacgupta Bug#2673140.Table pa_implementations is included to check Expenditure organization.
--              28-MAR-2003  sacgupta Bug#2876296. Reverted the fix done for bug#2673140.
--                                    The fix for the bug#2673140 has resulted in other
--                                    issues related to resource pull.
PROCEDURE Check_Exp_Org (p_organization_id   IN  NUMBER,
                         x_valid             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                         x_return_status     OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN

        -- initialize the error stack
        PA_DEBUG.init_err_stack('PA_RESOURCE_UTILS.check_exp_org');
        -- initialize the return  status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        x_valid := 'N';
        IF p_organization_id IS NOT NULL  then

-- Commented out for bug 2876296
/*
                SELECT 'Y'
                INTO   x_valid
                FROM   pa_all_organizations o,
                       pa_implementations  i                 -- Added for bug 2673140
                WHERE  o.pa_org_use_type = 'EXPENDITURES'
                AND    o.inactive_date is null
                AND    o.organization_id = p_organization_id
                AND    rownum          = 1
                AND    o.org_id = i.org_id;                 -- Added for bug 2673140
*/

                  SELECT 'Y'
                  INTO   x_valid
                  FROM   pa_all_organizations
                  WHERE  pa_org_use_type = 'EXPENDITURES'
                  AND    inactive_date is null
                  AND    organization_id = p_organization_id
                  AND    rownum          = 1;

        END IF;

        -- reset the error stack
        PA_DEBUG.reset_err_stack;

EXCEPTION
        WHEN  NO_DATA_FOUND THEN
                x_valid := 'N';
                x_return_status := FND_API.G_RET_STS_ERROR;

        WHEN OTHERS THEN

        -- RESET OUT PARAMS : 4537865

                 x_valid := 'N';

                -- set the exception message and stack
                FND_MSG_PUB.add_exc_msg('PA_RESOURCE_UTILS.check_exp_org'
                                        ,PA_DEBUG.g_err_stack);
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                raise;

END check_exp_org;


--  PROCEDURE
--              Check_Res_Exists
--  PURPOSE
--              This procedure checks if a person exists in PA
--              giver a person_id
--
--  HISTORY
--              10-MAY-2001  virangan   Created
--              28-MAR-2001  adabdull   Added parameter p_party_id and set
--                                      this and p_person_id with default null
--
PROCEDURE Check_Res_Exists (p_person_id         IN  NUMBER,
                            p_party_id          IN  NUMBER,
                            x_valid             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            x_return_status     OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN

        -- initialize the error stack
        PA_DEBUG.init_err_stack('PA_RESOURCE_UTILS.check_res_exists');
        -- initialize the return  status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        x_valid := 'N';
        IF p_person_id IS NOT NULL  then

                SELECT 'Y'
                INTO   x_valid
                FROM   pa_resource_txn_attributes
                WHERE  person_id = p_person_id
                AND    rownum          = 1;

        ELSIF p_party_id IS NOT NULL then

                SELECT 'Y'
                INTO   x_valid
                FROM   pa_resource_txn_attributes
                WHERE  party_id = p_party_id
                AND    rownum = 1;

        END IF;

        -- reset the error stack
        PA_DEBUG.reset_err_stack;

EXCEPTION
        WHEN  NO_DATA_FOUND THEN
                x_valid := 'N';
                x_return_status := FND_API.G_RET_STS_ERROR;

        WHEN OTHERS THEN
        --4537865 RESET OUT PARAMS
         x_valid := 'N';

                -- set the exception message and stack
                FND_MSG_PUB.add_exc_msg('PA_RESOURCE_UTILS.check_res_exists'
                                        ,PA_DEBUG.g_err_stack);
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                raise;

END check_res_exists;

--  FUNCTION
--           Get_Org_Prim_Contact_Name
--  PURPOSE
--           This function returns the primary contact name of the given organzation
--  HISTORY
--           11-JUL-2001 snam  Created
FUNCTION Get_Org_Prim_Contact_Name(p_org_id   IN NUMBER,
                                   p_prim_role_name IN VARCHAR2) RETURN VARCHAR2
IS

BEGIN

   RETURN PA_RESOURCE_UTILS.G_PRIMARY_CONTACT_NAME;

END get_org_prim_contact_name;


--  FUNCTION
--           Get_Org_Prim_Contact_Id
--  PURPOSE
--           This function returns the primary_contact_id of the org which has been queried
--           in the function 'Get_Org_Prim_Contact_Name'. This function should be used only
--           after calling the funtion 'Get_Org_Prim_Contact_Name'.
--  HISTORY
--           27-AUG-2001 snam  Created
FUNCTION Get_Org_Prim_Contact_Id(p_org_id   IN NUMBER,
                                 p_prim_role_name IN VARCHAR2) RETURN NUMBER
IS
   l_primary_contact_name VARCHAR2(240) := NULL;
   l_primary_contact_id NUMBER;
   l_menu_id            NUMBER; /* Bug# 2499051 */
BEGIN
   -- reset primary_contact_id before set it up again
   PA_RESOURCE_UTILS.G_PRIMARY_CONTACT_NAME:= NULL;

/* Bug# 2499051 */
   select pa_security_pvt.get_menu_id(p_prim_role_name)
   into   l_menu_id
   from   dual;
/* Bug# 2499051 */

   SELECT pep.full_name,
          pep.person_id
   INTO  l_primary_contact_name,
         l_primary_contact_id
   FROM  fnd_grants fg,
         fnd_objects fob,
         per_all_people_f pep, -- Bug 4684198 - use base table not secure view
         wf_roles wfr
  /* Bug# 2499051 - Moved the function call to fetch to a local variable at the start of the procedure
         (select pa_security_pvt.get_menu_id(p_prim_role_name) menu_id from dual) temp */
   WHERE  fg.object_id = fob.object_id
          AND  fob.obj_name = 'ORGANIZATION'
          AND  fg.instance_pk1_value = to_char(p_org_id)
/*        AND  fg.menu_id = temp.menu_id -- Bug# 2499051 - Using local variable */
          AND  fg.menu_id = l_menu_id /* Bug# 2499051 */
          AND  fg.instance_type = 'INSTANCE'
          AND  fg.grantee_type = 'USER'
          AND  trunc(SYSDATE) BETWEEN trunc(fg.start_date)
                              AND     trunc(NVL(fg.end_date, SYSDATE+1))
        --  AND  'PER:' || pep.person_id = fg.grantee_key --bug 2795616:perfomance
          AND    fg.grantee_key   = wfr.name
          AND    wfr.orig_system  = 'HZ_PARTY'
          AND    pep.party_id = wfr.orig_system_id -- Added for 11.5.10 security
          -- AND PEP.PERSON_ID  = substr(fg.grantee_key,instr(fg.grantee_key,':')+1)
          AND  sysdate BETWEEN pep.effective_start_date
               AND pep.effective_end_date
          AND (pep.current_employee_flag = 'Y' OR pep.current_npw_flag = 'Y'); -- Added for bug 4938392

   -- set primary_contact_name to the global variable to get it later
   -- from the function 'Get_Org_Prim_Contact_Name'
   PA_RESOURCE_UTILS.G_PRIMARY_CONTACT_NAME := l_primary_contact_name;

   RETURN l_primary_contact_id;

   EXCEPTION
        WHEN  NO_DATA_FOUND THEN
           RETURN l_primary_contact_id;
        WHEN OTHERS THEN
           RETURN l_primary_contact_id;

END Get_Org_Prim_Contact_Id;

--  FUNCTION
--              Is_Future_Resource
--  PURPOSE
--              This procedure checks if a person has only future
--              records in pa_resources_denorm
--
--  HISTORY
--              31-AUG-2001  created  virangan
--
FUNCTION Is_Future_Resource (p_resource_id IN NUMBER)
    RETURN VARCHAR2
IS
   l_future_res VARCHAR2(1) := 'Y';
   l_start_date DATE;
BEGIN

    SELECT min(resource_effective_start_date)
    INTO l_start_date
    FROM pa_resources_denorm
    WHERE resource_id = p_resource_id
    ;

    IF l_start_date <= sysdate THEN
       l_future_res := 'N';
    ELSE
       l_future_res := 'Y';
    END IF;

    RETURN l_future_res;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN l_future_res;
    WHEN OTHERS THEN
        RETURN null;

END Is_Future_Resource;

--  FUNCTION
--              Is_Future_Rehire -- Added for bug 8988264
--  PURPOSE
--              This procedure checks if a person has
--              records in pa_resources_denorm for a rehire scenario.
--
--  HISTORY
--              28-DEC-2009  created  skkoppul
--
FUNCTION Is_Future_Rehire (p_resource_id IN NUMBER)
        RETURN VARCHAR2
IS
   l_future_reh VARCHAR2(1) := 'N';
   l_start_date DATE;
BEGIN

    SELECT min(resource_effective_start_date)
        INTO l_start_date
    FROM pa_resources_denorm
        WHERE resource_id = p_resource_id
        and resource_effective_start_date > sysdate
        ;

        IF l_start_date > sysdate THEN
           l_future_reh := 'Y';
        END IF;

    RETURN l_future_reh;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
      l_future_reh := 'N';
        RETURN l_future_reh;
    WHEN OTHERS THEN
        RETURN null;

END Is_Future_Rehire;

--  FUNCTION
--              Is_Past_Resource
--  PURPOSE
--              This procedure checks if a person has only past
--              records in pa_resources_denorm
--
--  HISTORY
--              01-JAN-2009  created  asahoo
--
FUNCTION Is_Past_Resource (p_resource_id IN NUMBER)
    RETURN VARCHAR2
IS
   l_past_res VARCHAR2(1) := 'N';
   l_end_date DATE;
BEGIN

    SELECT max(resource_effective_end_date)
    INTO l_end_date
    FROM pa_resources_denorm
    WHERE resource_id = p_resource_id ;

    IF l_end_date < sysdate THEN
       l_past_res := 'Y';
    ELSE
       l_past_res := 'N';
    END IF;

    RETURN l_past_res;

EXCEPTION
    WHEN OTHERS THEN
        RETURN null;

END Is_Past_Resource;


--  FUNCTION
--              Get_Resource_Start_date
--  PURPOSE
--              This procedure returns the start date of the resource
--              in pa_resources_denorm
--
--  HISTORY
--              31-AUG-2001  created  virangan
--
FUNCTION Get_Resource_Start_Date (p_resource_id IN NUMBER)
    RETURN DATE
IS

    l_start_date DATE;

BEGIN

    SELECT min(resource_effective_start_date)
    INTO   l_start_date
    FROM   pa_resources_denorm
    WHERE  resource_id = p_resource_id
    ;

    RETURN l_start_date;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN l_start_date;
    WHEN OTHERS THEN
        RETURN null;
END Get_Resource_Start_Date;

--  FUNCTION
--              Get_Resource_Start_date_rehire -- Added for bug 8988264
--  PURPOSE
--              This procedure returns the start date of the resource
--              in pa_resources_denorm for rehires
--
--  HISTORY
--              28-DEC-2009  created  skkoppul
--
FUNCTION Get_Resource_Start_Date_Rehire (p_resource_id IN NUMBER)
        RETURN DATE
IS

        l_start_date DATE;

BEGIN

    SELECT min(resource_effective_start_date)
    INTO   l_start_date
    FROM   pa_resources_denorm
    WHERE  resource_id = p_resource_id
    and resource_effective_start_date > sysdate
    ;

    RETURN l_start_date;

EXCEPTION
        WHEN NO_DATA_FOUND THEN
        RETURN l_start_date;
    WHEN OTHERS THEN
        RETURN null;
END Get_Resource_Start_Date_Rehire;

-- start for bug#9233998
--  FUNCTION
--              Get_Resource_end_date
--  PURPOSE
--              This procedure returns the end date of the resource
--              in pa_resources_denorm
--
--  HISTORY
--              28-10-2009 NISINHA Created
--
FUNCTION Get_Resource_end_Date (p_resource_id IN NUMBER)
    RETURN DATE
IS

    l_end_date DATE;

BEGIN

    SELECT max(resource_effective_end_date)
    INTO   l_end_date
    FROM   pa_resources_denorm
    WHERE  resource_id = p_resource_id
    ;

    RETURN l_end_date;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN l_end_date;
    WHEN OTHERS THEN
        RETURN null;
END Get_Resource_end_Date;
-- end for bug#9233998

--  FUNCTION
--              Get_Resource_Effective_date
--  PURPOSE
--              This procedure returns the effective date of the resource
--              in pa_resources_denorm. This is the resource_effective_start_date
--              for a future resource or sysdate for active resources
--
--  HISTORY
--              17-SEP-2001  created  virangan
--
FUNCTION Get_Resource_Effective_Date (p_resource_id IN NUMBER)
    RETURN DATE
IS

    l_start_date DATE := sysdate;

BEGIN

    IF is_future_resource( p_resource_id ) = 'Y' THEN
        l_start_date := get_resource_start_date( p_resource_id );
    ELSE
    -- made changes for 8988264 : skkoppul
        IF is_future_rehire(p_resource_id) = 'Y' THEN
           l_start_date := get_resource_start_date_rehire(p_resource_id);
        ELSE
           l_start_date := sysdate;
        END IF;
    END IF;

    RETURN l_start_date;

EXCEPTION
    WHEN OTHERS THEN
        RETURN l_start_date;

END Get_Resource_Effective_Date;


--  FUNCTION
--              Get_Person_Start_date
--  PURPOSE
--              This procedure returns the start date of the person
--              in per_all_people_f
--
--  HISTORY
--              21-jan-2003  created  sramesh for the bug 2686120
--
FUNCTION Get_Person_Start_Date (p_person_id IN NUMBER)
    RETURN DATE
IS

    l_start_date DATE;

BEGIN
/* Commented for bug 4510084
    SELECT P.EFFECTIVE_START_DATE
    INTO   l_start_date
    FROM   PER_ALL_PEOPLE_F P
    WHERE  P.PERSON_ID = p_person_id
    AND p.EFFECTIVE_START_DATE = (SELECT MIN(PP.EFFECTIVE_START_DATE)
                            FROM PER_ALL_PEOPLE_F PP
                            WHERE PP.PERSON_ID = p_person_id
                            AND PP.EFFECTIVE_END_DATE >= SYSDATE)
                            AND (P.EMPLOYEE_NUMBER IS NOT NULL OR
                                     P.npw_number is not null); -- FP M CWK
End for bug 4510084*/

/* Added for bug 4510084 */
     SELECT MIN(PP.EFFECTIVE_START_DATE)
     INTO   l_start_date
         FROM PER_ALL_PEOPLE_F PP
         WHERE PP.PERSON_ID = p_person_id
     AND (PP.CURRENT_EMPLOYEE_FLAG='Y' OR PP.CURRENT_NPW_FLAG = 'Y')
         AND (PP.EMPLOYEE_NUMBER IS NOT NULL OR
               PP.npw_number is not null);-- FP M CWK

/* End for bug 4510084 */

    RETURN l_start_date;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN null;  /*Commented the code for bug 3071483 l_start_date*/
    WHEN OTHERS THEN
        RETURN null;
END Get_Person_Start_Date;

--
--  PROCEDURE
--              Get_Res_Capacity
--  PURPOSE
--              This procedure does the following
--              For the given Resource Id, start date and end date
--              gets the capacity hours for the resource
--  HISTORY
--              04-SEP-2001 Vijay Ranganathan    created
--
FUNCTION  get_res_capacity( p_resource_id          IN      NUMBER,
                            p_start_date           IN      DATE,
                            p_end_date             IN      DATE)
RETURN NUMBER
IS
l_capacity        NUMBER;

BEGIN


  BEGIN

     SELECT sum(capacity_quantity)
     INTO   l_capacity
     FROM   pa_forecast_items
     WHERE  resource_id      = p_resource_id
     AND    delete_flag      = 'N'
     AND    forecast_item_type = 'U'
     AND    item_date  between p_start_date
                       and     p_end_date;
  EXCEPTION
        WHEN NO_DATA_FOUND THEN
             l_capacity := 0;
  END;


   RETURN l_capacity;
EXCEPTION
   WHEN OTHERS THEN
        RETURN 0;
END get_res_capacity;

--
--  PROCEDURE
--              Get_Res_Wk_Capacity
--  PURPOSE
--              This procedure does the following
--              For the given Resource Id, week date date
--              gets the capacity hours for the resource
--  HISTORY
--              13-SEP-2001 Vijay Ranganathan    created
--
 FUNCTION  get_res_wk_capacity( p_resource_id          IN      NUMBER,
                                p_wk_date              IN      DATE)
  RETURN NUMBER
  IS
  l_calendar_id     NUMBER;
  x_capacity        NUMBER;
  l_organization_id NUMBER;
  l_default_ou      NUMBER;
  l_return_status   VARCHAR2(30);

 BEGIN

    ---------------------------------------------------------------------
    --If Future resource use organization calendar, otherwise use resources
    --JTF calendar
    ----------------------------------------------------------------------
    IF pa_resource_utils.is_future_resource ( p_resource_id ) = 'Y' THEN

       --dbms_output.put_line('Future Resource');

       BEGIN
          SELECT resource_organization_id
          INTO   l_organization_id
          FROM   pa_resources_denorm
          WHERE  p_wk_date BETWEEN resource_effective_start_date AND resource_effective_end_date
          AND    resource_id = p_resource_id  ;

       EXCEPTION
          WHEN NO_DATA_found THEN
            --dbms_output.put_line('Organization is null');
            l_organization_id := NULL;
       END;

       --dbms_output.put_line('Resource Organization Id: ' || l_organization_id);

       pa_resource_utils.get_org_defaults ( P_ORGANIZATION_ID   => l_organization_id,
                                            X_DEFAULT_OU        => l_default_ou,
                                            X_DEFAULT_CAL_ID    => l_calendar_id,
                                            X_RETURN_STATUS     => l_return_status);

       --dbms_output.put_line('Calendar Id: ' || l_calendar_id);

       IF l_calendar_id IS NULL THEN
          l_calendar_id := fnd_profile.value_specific('PA_PRM_DEFAULT_CALENDAR');
       END IF;

    ELSE --If not a future resource

       BEGIN

           SELECT jcra.calendar_id
           INTO   l_calendar_id
           FROM   pa_resources par,
                  jtf_cal_resource_assign jcra
           WHERE  par.jtf_resource_id = jcra.resource_id
           AND    par.resource_id     = p_resource_id
           AND    p_wk_date between jcra.start_date_time and nvl(jcra.end_date_time,to_date('31-12-4712', 'DD-MM-YYYY'));

       EXCEPTION
          WHEN no_data_found THEN
             l_calendar_id := NULL;
       END;

    END IF;

    --dbms_output.put_line('Calendar Id: ' || l_calendar_id);

    -------------------------------------------------------------
    --Calculate capacity for the given day once calendar is known
    -------------------------------------------------------------
    BEGIN
        SELECT decode( to_char( p_wk_date,'D'),
                        '1',SUNDAY_HOURS,
                        '2',MONDAY_HOURS,
                        '3',TUESDAY_HOURS,
                        '4',WEDNESDAY_HOURS,
                        '5',THURSDAY_HOURS,
                        '6',FRIDAY_HOURS,
                            SATURDAY_HOURS )
        INTO  x_capacity
        FROM  pa_schedules pas
        WHERE p_wk_date BETWEEN pas.start_date AND pas.end_date
        AND   pas.SCHEDULE_TYPE_CODE = 'CALENDAR'
        AND   pas.CALENDAR_ID        = l_calendar_id
        ;
    EXCEPTION
       WHEN OTHERS THEN
           x_capacity := 0;
    END;

  RETURN x_capacity;

 EXCEPTION
    WHEN OTHERS THEN
   RETURN 0;

 END get_res_wk_capacity;

--  FUNCTION
--              get_pa_logged_user
--  PURPOSE
--              This procedure checks if logged user is
--              Project Super User or Resource Manager
--              or Staffing Manager
--
--  HISTORY
--              25-SEP-2001  created  virangan
--
FUNCTION get_pa_logged_user (p_authority IN VARCHAR2)
    RETURN VARCHAR2
IS

    l_menu_name varchar2(255);
    l_pa_logged_user varchar2(2) := 'SM'; -- 'TM'; // changed back to SM for 8403781 -- 'SM'; // Bug 7500918
    is_project_super_user varchar2(1);

BEGIN
    -- If p_authority is 'RESOURCE', check PA_SUPER_RESOURCE profile option
    -- If p_authority is 'PROJECT', check PA_SUPER_PROJECT_VIEW profile option

    IF p_authority = 'RESOURCE' THEN
      is_project_super_user := fnd_profile.value_specific('PA_SUPER_RESOURCE',
                                                           fnd_global.user_id,
                                                           fnd_global.resp_id,
                                                           fnd_global.resp_appl_id) ;
    ELSE
      is_project_super_user := fnd_profile.value_specific('PA_SUPER_PROJECT_VIEW',
                                                           fnd_global.user_id,
                                                           fnd_global.resp_id,
                                                           fnd_global.resp_appl_id) ;
    END IF;

    if is_project_super_user = 'Y' then
        return 'SU';
    end if;
     /* resp.application_id = fnd_global.resp_appl_id join is added for Perfomance
        Bug 2634995        */
    select menu_name
    into   l_menu_name
    from   fnd_menus menu,
           fnd_responsibility resp
    where  resp.responsibility_id = fnd_global.resp_id
    and    resp.menu_id           = menu.menu_id
    and    resp.application_id = fnd_global.resp_appl_id ;


    /* changed for bug 2775111: recently the function 'PA_STAFF_HOME_RM'
       got moved from menu 'PA_PRM_RES_MGR' to the submenu 'PA_STAFFING_RES_MGR'.
       Since FND_FUNCTION_SECURITY.MENU_ENTRY_EXISTS doesn't work recursively,
       we needed use new submenu to tell the login resp of resource manager.
     if FND_FUNCTION_SECURITY.MENU_ENTRY_EXISTS(
           menu_name          => l_menu_name,
           sub_menu_name      => '',
           function_name      => 'PA_STAFF_HOME_RM')  */

    if FND_FUNCTION_SECURITY.MENU_ENTRY_EXISTS(
           menu_name          => l_menu_name,
           sub_menu_name      => 'PA_STAFFING_RES_MGR',
           function_name      => '')
    then
           l_pa_logged_user := 'RM';

    elsif FND_FUNCTION_SECURITY.MENU_ENTRY_EXISTS(
           menu_name          => l_menu_name,
           sub_menu_name      => '',
           function_name      => 'PA_STAFF_HOME')
    then
           l_pa_logged_user := 'SM';
    end if;

    return l_pa_logged_user;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'SU';
    WHEN OTHERS THEN
        RETURN null;

END get_pa_logged_user;

--
--  PROCEDURE
--              Get_Provisional_hours
--  PURPOSE
--              This procedure gets the provisional hours
--              for a resource on a given date
--  HISTORY
--              22-OCT-2001 Vijay Ranganathan    created
--
FUNCTION get_provisional_hours
    ( p_resource_id IN Number,
      p_Week_date IN DATE)
RETURN NUMBER
IS

l_date DATE;
l_date2 DATE;
l_resource_id NUMBER;

BEGIN

     select pfi.global_exp_period_end_date,
            pfi.item_date,
            sum(decode(pfi.provisional_flag,'Y',pfi.item_quantity,0)),
            sum(decode(pfi.provisional_flag,'N',pfi.item_quantity,0)),
            pfi.resource_id
     into   l_date,
            l_date2,
            g_provisional_hours,
            g_confirmed_hours,
            l_resource_id
  from   pa_forecast_items pfi
  where  pfi.forecast_item_type = 'A'
  and    pfi.delete_flag        = 'N'
  and    pfi.resource_id        = p_resource_id
  and    pfi.item_date          = p_week_date
  group by pfi.global_exp_period_end_date,
           pfi.item_date,
           pfi.resource_id;

  return g_provisional_hours;

END;

--
--  PROCEDURE
--              Get_Confirmed_hours
--  PURPOSE
--              This procedure gets the confirmed hours
--              for a resource based on the date set in
--              the get_provisional_hours call
--  HISTORY
--              22-OCT-2001 Vijay Ranganathan    created
--
FUNCTION get_confirmed_hours
RETURN NUMBER
IS
BEGIN
    RETURN g_confirmed_hours;
END;

--+
--  FUNCTION
--           check_user_has_res_auth
--  PURPOSE
--           This function checks if the given user has resource authority
--           over the specified resource
--  HISTORY
--           03-OCT-2001 virangan  Created
--           05-SEP-2002 adabdull  Modified to support resource supervisor
--                                 hierarchy
--+
FUNCTION check_user_has_res_auth (p_user_person_id  IN NUMBER
                                 ,p_resource_id     IN NUMBER ) RETURN VARCHAR2
IS

  l_res_auth     VARCHAR2(1) := 'N';
  l_resource_id  NUMBER      := p_resource_id;
  l_manager_id   NUMBER      := p_user_person_id;

  -- this cursor checks whether the person is the Resource Manager of
  -- the resource in the supervisor hierarchy
  CURSOR check_res_mgr IS
     SELECT 'Y'
     FROM pa_resources_denorm
     WHERE sysdate    < resource_effective_end_date
     AND   manager_id = l_manager_id
     START WITH resource_id = l_resource_id
     CONNECT BY
          prior manager_id = person_id
          and manager_id <> prior person_id
          and sysdate < resource_effective_end_date
          and sysdate < prior resource_effective_end_date;

  -- this cursor checks whether the person is the Staffing Manager of
  -- the resource
  CURSOR check_staff_mgr IS
     SELECT 'Y'
     FROM pa_resources_denorm res,
          fnd_grants          fg,
          fnd_objects         fob,
          per_all_people_f    per,
      wf_roles            wfr,
          (select pa_security_pvt.get_menu_id('PA_PRM_RES_AUTH') menu_id
           from dual)         res_auth_menu
     WHERE fob.obj_name           = 'ORGANIZATION'
       and res.resource_id        = l_resource_id
       and sysdate                < res.resource_effective_end_date
       and fg.instance_pk1_value  = to_char(res.resource_organization_id)
       and fg.instance_type       = 'INSTANCE'
       and fg.object_id           = fob.object_id
       and fg.grantee_type        = 'USER'
       and fg.menu_id             = res_auth_menu.menu_id
       and trunc(SYSDATE) between trunc(fg.start_date)
                          and     trunc(NVL(fg.end_date, SYSDATE+1))
       -- and fg.grantee_key         = 'PER:'|| per.person_id
       AND fg.grantee_key   = wfr.name
       AND wfr.orig_system  = 'HZ_PARTY'
       AND per.party_id     = wfr.orig_system_id -- Added for 11.5.10 security
       and SYSDATE between per.effective_start_date and per.effective_end_date
       and per.person_id          <> res.manager_id
       and per.person_id          = l_manager_id;
BEGIN

     OPEN check_res_mgr;
     FETCH check_res_mgr INTO l_res_auth;

     IF check_res_mgr%NOTFOUND THEN

         OPEN check_staff_mgr;
         FETCH check_staff_mgr INTO l_res_auth;

         IF check_staff_mgr%NOTFOUND THEN
            l_res_auth := 'N';
         END IF;
         CLOSE check_staff_mgr;

     END IF;
     CLOSE check_res_mgr;

     RETURN l_res_auth;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        RETURN l_res_auth;
    WHEN OTHERS THEN
        RETURN null;

END check_user_has_res_auth;

FUNCTION get_person_id(p_resource_id IN NUMBER)
RETURN NUMBER
IS
l_person_id NUMBER;
BEGIN

   SELECT person_id
   INTO l_person_id
   FROM pa_resource_txn_attributes
   WHERE resource_id = p_resource_id;

   RETURN l_person_id;
EXCEPTION
  WHEN OTHERS THEN
       RETURN -999;
END get_person_id;

--
--
--  FUNCTION
--              get_person_id_from_party_id
--  PURPOSE
--              This  function returns back the person_id
--              for a person based on the party_id passed in.
--  HISTORY
--  22-OCT-2002      ramurthy
--start 29-Oct-09  cklee                        Bug 8972676 - CLICKING ON ISSUE OWNER TAKES YOU TO RESOURCE DETAILS FOR ANOTHER PERSON
/*
FUNCTION get_person_id_from_party_id(p_party_id IN NUMBER)
RETURN NUMBER
IS
l_person_id NUMBER;
BEGIN

   SELECT person_id
   INTO l_person_id
   FROM per_all_people_f
   WHERE party_id = p_party_id
   AND   trunc(sysdate) between trunc(effective_start_date)
                            and trunc(effective_end_date);

   RETURN l_person_id;
EXCEPTION
  WHEN OTHERS THEN
       RETURN -999;
END get_person_id_from_party_id;
*/
 FUNCTION get_person_id_from_party_id(p_party_id IN NUMBER)
 RETURN NUMBER
 IS

   cursor p_active is
    SELECT person_id
    FROM per_all_people_f
    WHERE party_id = p_party_id
    AND   CURRENT_EMPLOYEE_FLAG = 'Y'
    AND   trunc(sysdate) between trunc(effective_start_date)
                             and trunc(effective_end_date);

   cursor p_teminated is
    SELECT person_id
    FROM per_all_people_f
    WHERE party_id = p_party_id
    and trunc(effective_end_date) =
    (select max(trunc(effective_end_date))
     from per_all_people_f
      WHERE   trunc(sysdate) not between trunc(effective_start_date)
                             and trunc(effective_end_date)
      and party_id = p_party_id);

 l_person_id NUMBER;

 BEGIN

    OPEN p_active;
    FETCH p_active INTO l_person_id;
    CLOSE p_active;

    -- IF this person has been terminated
    IF l_person_id IS NULL THEN
      OPEN p_teminated;
      FETCH p_teminated INTO l_person_id;
      CLOSE p_teminated;
    END IF;

    -- if still not able to find a person
    IF l_person_id IS NULL THEN
      l_person_id := -999;
    END IF;
    RETURN l_person_id;
 EXCEPTION
   WHEN OTHERS THEN
        RETURN -999;
 END get_person_id_from_party_id;
--end:-- 29-Oct-09  cklee                        Bug 8972676 - CLICKING ON ISSUE OWNER TAKES YOU TO RESOURCE DETAILS FOR ANOTHER PERSON
--  PROCEDURE
--              check_res_not_terminated
--  PURPOSE
--              This function returns true if the person has not been
--              terminated and false if it is a terminated employee.
--  HISTORY
--  14-FEB-2003 ramurthy  Created
FUNCTION check_res_not_terminated(p_object_type          IN VARCHAR2,
                                  p_object_id            IN NUMBER,
                                  p_effective_start_date IN DATE)
RETURN BOOLEAN IS

  cursor chk_no_termination(p_person_id NUMBER) is
   select 'Y'
   from per_all_people_f per
   where per.person_id             = p_person_id
     and (per.current_employee_flag = 'Y' OR per.current_npw_flag = 'Y')
     and p_effective_start_date between per.effective_start_date
                                    and per.effective_end_date;
l_chk VARCHAR2(1) := 'N';

BEGIN
IF p_object_type = 'PERSON' THEN
   open chk_no_termination(p_object_id);
   fetch chk_no_termination into l_chk;
   close chk_no_termination;

   IF l_chk = 'Y' THEN
      return true;
   ELSE
      return false;
   END IF;
ELSE
   return false;
END IF;
END check_res_not_terminated;

--
--
--  PROCEDURE
--           validate_person
--  PURPOSE
--           This procedure checks if the resource is valid as of the assignment
--           start date in the pa_resources_denorm table
--  HISTORY
--           26-FEB-2002 adabdull Created
--
PROCEDURE validate_person (   p_person_id             IN NUMBER,
                              p_start_date            IN DATE,
                              x_return_status         OUT NOCOPY VARCHAR2)                  --File.Sql.39 bug 4440895
IS
   l_assignment_id    NUMBER;
   l_job_id           NUMBER;
   l_person_type      VARCHAR2(30);
   l_person_id        NUMBER;

/* Bug#2683266-Commented the cursor get_person_type and added cursor

   cursor get_person_type
   is
   select person_id
   from per_people_f per,
        per_person_types ptype
   where per.person_id             = p_person_id
   and   per.person_type_id        = ptype.person_type_id
   and   (ptype.system_person_type  = 'EMP'
          OR ptype.system_person_type = 'EMP_APL');

End of comment for bug#2683266 */

/* New cursor validate_person_type added for bug#2683266 */

   cursor validate_person_type
   is
   select person_id
   from per_all_people_f per
   where per.person_id             = p_person_id
     and (per.current_employee_flag = 'Y' OR per.current_npw_flag = 'Y');

   cursor get_active_assignment
   is
   select asgn.assignment_id
   from per_all_assignments_f asgn,
        per_assignment_status_types status,
        (select person_id, actual_termination_date
           from per_periods_of_service
         union all
         select person_id, actual_termination_date
           from per_periods_of_placement) po -- FP M CWK
   where asgn.person_id                  = p_person_id
   and   nvl(po.actual_termination_date, trunc(sysdate)) >= trunc(sysdate)
   and   asgn.person_id                  = po.person_id
   and   po.person_id                    = p_person_id
   and   asgn.assignment_status_type_id  = status.assignment_status_type_id
   and   status.per_system_status in ('ACTIVE_ASSIGN', 'ACTIVE_CWK')
   and   p_start_date between asgn.effective_start_date
                          and asgn.effective_end_date
   and   asgn.assignment_type in ('E', 'C'); /* Bug 2777643 */

   cursor get_primary_assignment
   is
   select asgn.assignment_id
   from per_all_assignments_f asgn,
        (select person_id, actual_termination_date
           from per_periods_of_service
         union all
         select person_id, actual_termination_date
           from per_periods_of_placement) po -- FP M CWK
   where asgn.person_id            = p_person_id
   and   asgn.primary_flag         = 'Y'
   and   po.person_id              = p_person_id
   and   nvl(po.actual_termination_date, trunc(sysdate)) >= trunc(sysdate)
   and   asgn.person_id            = po.person_id
   -- and   po.period_of_service_id  = asgn.period_of_service_id
   and   p_start_date  between asgn.effective_start_date and asgn.effective_end_date
   and   asgn.assignment_type in ('E', 'C'); /* Bug 2777643 */

   cursor get_job_on_assignment
   is
   select asgn.job_id
   from per_all_assignments_f asgn,
        (select person_id, actual_termination_date
           from per_periods_of_service
         union all
         select person_id, actual_termination_date
           from per_periods_of_placement) po -- FP M CWK
   where asgn.person_id            = p_person_id
   and   asgn.primary_flag         = 'Y'
   and   po.person_id              = p_person_id
   and   nvl(po.actual_termination_date, trunc(sysdate)) >= trunc(sysdate)
   and   asgn.person_id            = po.person_id
   -- and   pos.period_of_service_id  = asgn.period_of_service_id
   and   asgn.job_id is not null
   and   p_start_date between asgn.effective_start_date
                          and asgn.effective_end_date
   and   asgn.assignment_type in ('E', 'C'); /* Bug 2777643 */

   cursor validate_resource is
   select person_id
   from   pa_resources_denorm
   where  person_id = p_person_id
   and    p_start_date between resource_effective_start_date
                           and resource_effective_end_date;


BEGIN
   PA_DEBUG.set_err_stack('Validate_person');

  -------------------------------------------------------------------------
  --Cursor which checks if record exists in pa_resources_denorm
  --as of the p_Start_date
  -------------------------------------------------------------------------
  OPEN validate_resource;
  FETCH validate_resource into l_person_id;
  IF validate_resource%NOTFOUND THEN
      x_return_status := 'E';
  ELSE
      x_return_status := 'S';
  END IF;
  CLOSE validate_resource;

  IF x_return_status = 'S' THEN
      PA_DEBUG.Reset_Err_Stack;
      return;
  END IF;

  ------------------------------------------------------------
  --Logic which identifies the setup issue when a resource
  --record does not exist as of p_start_date
  ------------------------------------------------------------
/* Bug#2683266 - Changed get_person_type cursor to validate_person_type in code below */

  OPEN validate_person_type;
  FETCH validate_person_type into l_person_type;
  IF validate_person_type%NOTFOUND THEN
     CLOSE validate_person_type;
     PA_UTILS.Add_Message( p_app_short_name  => 'PA'
                           ,p_msg_name       => 'PA_INVALID_PERSON_TYPE');

  ELSE
    CLOSE validate_person_type;
    OPEN get_active_assignment;
    FETCH get_active_assignment into l_assignment_id;
    IF get_active_assignment%NOTFOUND THEN
       CLOSE get_active_assignment;
       PA_UTILS.Add_Message( p_app_short_name  => 'PA'
                             ,p_msg_name       => 'PA_NO_ACTIVE_ASSIGNMENT');
    ELSE
      CLOSE get_active_assignment;
      OPEN get_primary_assignment;
      FETCH get_primary_assignment into l_assignment_id;
      IF get_primary_assignment%NOTFOUND THEN
         CLOSE get_primary_assignment;
         PA_UTILS.Add_Message( p_app_short_name  => 'PA'
                               ,p_msg_name       => 'PA_NO_PRIMARY_ASSIGNMENT');
      ELSE
        CLOSE get_primary_assignment;
        OPEN get_job_on_assignment;
        FETCH get_job_on_assignment into l_job_id;
        IF get_job_on_assignment%NOTFOUND THEN
           CLOSE get_job_on_assignment;
           PA_UTILS.Add_Message( p_app_short_name  => 'PA'
                                 ,p_msg_name       => 'PA_NO_JOB_ON_ASSIGNMENT');
        ELSE
           CLOSE get_job_on_assignment;
           PA_UTILS.Add_Message( p_app_short_name  => 'PA'
                                 ,p_msg_name       => 'PA_RS_INVALID_SETUP');
        END IF;
      END IF;
    END IF;
  END IF;

  PA_DEBUG.Reset_Err_Stack;

EXCEPTION

    WHEN OTHERS THEN
     -- Set the exception Message and the stack
     FND_MSG_PUB.add_exc_msg(p_pkg_name       => 'PA_RESOURCE_UTILS.Validate_person'
                            ,p_procedure_name => PA_DEBUG.G_Err_Stack );
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     RAISE;

END validate_person;


-- This function returns the party_id of a
-- resource
-- IN PARAMETER: p_resource_id
FUNCTION get_party_id(p_resource_id IN NUMBER)
RETURN NUMBER
IS
l_party_id NUMBER;
BEGIN

   SELECT party_id
   INTO l_party_id
   FROM pa_resource_txn_attributes
   WHERE resource_id = p_resource_id;

   RETURN l_party_id;
EXCEPTION
  WHEN OTHERS THEN
       RETURN -999;
END get_party_id;

-- This function returns the resource_type_code
-- (i.e. EMPLOYEE or HZ_PARTY, etc) of a resource
-- IN PARAMETER: p_resource_id
FUNCTION get_resource_type(p_resource_id IN NUMBER)
RETURN VARCHAR2
IS
   l_resource_type  VARCHAR2(30);
BEGIN

   SELECT resource_type_code
   INTO l_resource_type
   FROM pa_resources pr, pa_resource_types pt
   WHERE pr.resource_id = p_resource_id
     AND pr.resource_type_id = pt.resource_type_id;

   RETURN l_resource_type;
EXCEPTION
  WHEN OTHERS THEN
       RETURN NULL;
END get_resource_type;


-- This function returns a lock handle for retrieving
-- and releasing a dbms_lock.  We have made it as
-- an autonomous transaction because it issues a commit.
-- However, requesting and releasing a lock does not
-- issue a commit;
PROCEDURE allocate_unique(p_lock_name  IN VARCHAR2,
                          p_lock_handle OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
     dbms_lock.allocate_unique(
         lockname => p_lock_name,
         lockhandle => p_lock_handle);
   commit;

--4537865
EXCEPTION
WHEN OTHERS THEN
    p_lock_handle := NULL ;
    -- RAISE is not needed here . Caller takes care of this scenario by checking against p_lock_handle
END allocate_unique;


-- This function will set and acquire the user lock
--
-- Input parameters
-- Parameter    Type       Required  Description
-- p_source_id  NUMBER      Yes      Any unique id (person_id, resource_id, etc)
-- p_lock_for   VARCHAR2    Yes      Any descriptive word to be used
--                                   (e.g. Resource Pull)
--
-- Return Values
--  0         Success
-- Other      Unable to acquire lock


FUNCTION Acquire_User_Lock ( p_source_id         IN  NUMBER,
                             p_lock_for          IN  VARCHAR2)

RETURN NUMBER
IS
     lock_status    NUMBER;
     lock_name      VARCHAR2(50);
     lockhndl       VARCHAR2(128);
     lock_mode      NUMBER:=6;
     lock_commitmode    BOOLEAN:=TRUE;
BEGIN

    lock_name   := p_lock_for || '-' || p_source_id;
    IF ( p_source_id IS NULL ) THEN
      Return -99;
    END IF;

    /* Get lock handle for user lock */
    pa_resource_utils.allocate_unique(
            p_lock_name   =>lock_name,
            p_lock_handle =>lockhndl);

    IF ( lockhndl IS NOT NULL ) then
       /* Request the lock */
       lock_status := dbms_lock.request( lockhandle        => lockhndl,
                                         lockmode          => lock_mode,
                                         release_on_commit => lock_CommitMode,
                                         timeout           => 1);

       IF ( lock_status = 0 ) then  -- Got the lock
          Return 0;
       ELSE
          Return (-1*lock_status);
          -- Return the status obtained on request
       END IF;

    ELSE
          Return -99;  -- Failed to allocate lock
    END IF;

    RETURN(lock_status);

END  Acquire_User_Lock;


-- This procedure will release user lock
--
-- Input parameters
-- Parameter    Type       Required            Description
-- p_source_id  NUMBER      Yes      Any unique id (person_id, resource_id, etc)
-- p_lock_for   VARCHAR2    Yes      Any descriptive word to be used
--                                   (e.g. Resource Pull)
--
-- Return Values
--  0         Success
-- Other      Unable to acquire lock

FUNCTION Release_User_Lock (p_source_id   IN  NUMBER,
                            p_lock_for    IN  VARCHAR2)
 RETURN NUMBER
 IS
     lock_status   number;
     lock_name     VARCHAR2(50);
     lockhndl      VARCHAR2(128);
BEGIN

    lock_name   := p_lock_for || '-' || p_source_id;
    IF ( p_source_id IS NULL ) THEN
      Return -99;
    END IF;

    /* Get lock handle for user lock */
    pa_resource_utils.allocate_unique(
            p_lock_name   =>lock_name,
            p_lock_handle =>lockhndl);

    IF ( lockhndl IS NOT NULL ) then
          lock_status := dbms_lock.release(lockhandle =>lockhndl);

          IF ( lock_status = 0 ) then  -- Got the lock
                Return 0;
          ELSE
                Return (-1*lock_status);
                -- Return the status obtained on request
          END IF;
    ELSE
          Return -99;  -- Failed to allocate lock
    END IF;

    RETURN(lock_status);

END Release_User_Lock;


--  PROCEDURE
--             get_resource_id
--  PURPOSE
--             This function returns the resource_id of the
--             person using the fnd user name or user ID passed to the
--             function
FUNCTION get_resource_id(p_user_name IN VARCHAR2 DEFAULT NULL,
                         p_user_id   IN NUMBER   DEFAULT NULL)
  RETURN NUMBER
  IS
      l_emp_id NUMBER;
      l_cust_id NUMBER;
      l_res_id NUMBER;
BEGIN
      IF (p_user_name IS NULL) AND (p_user_id IS NULL) THEN
         RETURN -999;
      END IF;

      -- 4586987 customer_id is changed to person_party_id
      /*
      SELECT employee_id, customer_id
      INTO   l_emp_id, l_cust_id
      FROM   fnd_user
      WHERE  user_name = nvl(p_user_name, user_name)
      AND    user_id = nvl(p_user_id, user_id);
      */

      /* rewrite it for perf bug 4887375
      SELECT employee_id,person_party_id
      INTO l_emp_id,l_cust_id
      FROM fnd_user
      WHERE user_name = nvl(p_user_name,user_name)
      AND user_id =nvl(p_user_id,user_id);*/

      IF p_user_name IS NULL THEN
        SELECT employee_id, person_party_id
        INTO   l_emp_id, l_cust_id
        FROM   fnd_user
        WHERE  user_id = p_user_id;
      ELSIF p_user_id IS NULL THEN
        SELECT employee_id, person_party_id
        INTO   l_emp_id, l_cust_id
        FROM   fnd_user
        WHERE  user_name = p_user_name;
      ELSE
        SELECT employee_id, person_party_id
        INTO   l_emp_id, l_cust_id
        FROM   fnd_user
        WHERE  user_name = p_user_name
        AND user_id = p_user_id;
      END IF;

      -- 4586987 end

      IF l_emp_id IS NOT NULL THEN
         RETURN get_resource_id(p_person_id => l_emp_id);
      ELSIF l_cust_id IS NOT NULL THEN
         SELECT resource_id
         INTO l_res_id
         FROM pa_resource_txn_attributes
         WHERE party_id = l_cust_id;

         RETURN l_res_id;
      END IF;

      RETURN -999;

EXCEPTION
      WHEN OTHERS THEN
          RETURN -999;
END get_resource_id;

--  PROCEDURE
--             get_res_name_from_type
--  PURPOSE
--             This function returns the name of the
--             person using the resource type to determine whether
--             it is an HR or HZ resource.
FUNCTION get_res_name_from_type(p_resource_type_id     IN NUMBER,
                                p_resource_source_id   IN NUMBER)
RETURN VARCHAR2 IS

l_resource_type_code pa_resource_types.resource_type_code%TYPE;
l_name pa_resources.name%TYPE;

BEGIN

      BEGIN

         SELECT resource_type_code
         INTO l_resource_type_code
         FROM pa_resource_types
         WHERE resource_type_id = p_resource_type_id;

         EXCEPTION
            WHEN OTHERS THEN
            RETURN NULL;
      END;

      IF l_resource_type_code = 'EMPLOYEE' THEN

         SELECT hzp.party_name
         INTO l_name
         FROM per_all_people_f peo, hz_parties hzp
         WHERE peo.person_id = p_resource_source_id
         AND   sysdate BETWEEN peo.effective_start_date AND
                               peo.effective_end_date
         AND   peo.party_id = hzp.party_id;

         RETURN l_name;

      ELSIF l_resource_type_code = 'HZ_PARTY' THEN

         SELECT hzp.party_name
         INTO l_name
         FROM hz_parties hzp
         WHERE hzp.party_id = p_resource_source_id;

         RETURN l_name;

     ELSE
         RETURN NULL;

     END IF;

EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;

END get_res_name_from_type;

--  PROCEDURE
--             get_resource_name
--  PURPOSE
--             This function returns the resource_name of the
--             resource_id passed in using pa_resources table
FUNCTION get_resource_name(p_resource_id IN NUMBER)
  RETURN VARCHAR2
  IS
      l_name pa_resources.name%TYPE;
BEGIN
      SELECT name
      INTO l_name
      FROM pa_resources
      WHERE resource_id = p_resource_id;

      RETURN l_name;
EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
END get_resource_name;

--  FUNCTION
--              get_pa_logged_resp
--  PURPOSE
--              This procedure checks if logged responsibility is
--              Project Super User or Resource Manager
--              or Staffing Manager
--
--  HISTORY
--              25-SEP-2001  created  virangan
--
FUNCTION get_pa_logged_resp
    RETURN VARCHAR2
IS

    l_menu_name varchar2(255);
    l_pa_logged_resp varchar2(2) := 'TM';
    l_function_id number;
    l_menu_id number;

BEGIN
   /* resp.application_id = fnd_global.resp_appl_id join is added for Perfomance
        Bug 2634995        */
    select menu_name, resp.menu_id
    into   l_menu_name, l_menu_id
    from   fnd_menus menu,
           fnd_responsibility resp
    where  resp.responsibility_id = fnd_global.resp_id
    and    resp.menu_id           = menu.menu_id
    and    resp.application_id    = fnd_global.resp_appl_id ;

    select function_id
    into l_function_id
    from fnd_form_functions
    where function_name='PA_RES_LIST';

    /* changed for bug 2775111: recently the function 'PA_STAFF_HOME_RM'
       got moved from menu 'PA_PRM_RES_MGR' to 'PA_STAFFING_RES_MGR'.
       Since FND_FUNCTION_SECURITY.MENU_ENTRY_EXISTS doesn't work recursively,
       we needed use new submenu to tell the login resp of resource manager.
     if FND_FUNCTION_SECURITY.MENU_ENTRY_EXISTS(
           menu_name          => l_menu_name,
           sub_menu_name      => '',
           function_name      => 'PA_STAFF_HOME_RM')  */

    if FND_FUNCTION_SECURITY.MENU_ENTRY_EXISTS(
           menu_name          => l_menu_name,
           sub_menu_name      => 'PA_STAFFING_RES_MGR',
           function_name      => '')
    then
           l_pa_logged_resp := 'RM';

    elsif FND_FUNCTION_SECURITY.MENU_ENTRY_EXISTS(
           menu_name          => l_menu_name,
           sub_menu_name      => '',
           function_name      => 'PA_STAFF_HOME')
    then
           l_pa_logged_resp := 'SM';
 /* Updated following code since the menu got changed and
    'PA_RES_LIST' is not loger direct under the main menu.
    elsif FND_FUNCTION_SECURITY.MENU_ENTRY_EXISTS(
           menu_name          => l_menu_name,
           sub_menu_name      => '',
           function_name      => 'PA_RES_LIST') */
    elsif FND_FUNCTION.Is_function_on_menu (
          p_menu_id       => l_menu_id,
          p_function_id       => l_function_id )
    then
           l_pa_logged_resp := 'SU';
    end if;

    return l_pa_logged_resp;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'SU';
    WHEN OTHERS THEN
        RETURN null;

END get_pa_logged_resp;


--  PROCEDURE
--             get_person_id_name
--  PURPOSE
--             This procedure gives the person_name and person_id
--             based on person_name with a wildcard character '%'.
--             Will only return one row (even if more exists) and uses like comparison.
--             This is used by Check_ManagerName_Or_Id when the p_check=Y.
--             Currently, p_check is Y only when it comes from My Resources
--             page.
--  HISTORY
--             25-JUL-2002  Created    adabdull
--+
PROCEDURE get_person_id_name ( p_person_name IN  VARCHAR2
                              ,x_person_id   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                              ,x_person_name OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN

     SELECT person_id, resource_name
     INTO x_person_id, x_person_name
     FROM pa_resources_denorm
     WHERE resource_name like p_person_name
       AND rownum=1;

EXCEPTION
    WHEN OTHERS THEN
        x_person_id   := NULL;
        x_person_name := NULL;
END get_person_id_name;


--  PROCEDURE
--             Check_ManagerName_Or_Id
--  PURPOSE
--             Specifically for resource supervisor hierarchy use.
--             This procedure validates the manager_id and manager_name passed.
--             It also depends on the responsibility value. User needs to pass
--             RM if resource manager because it uses another view to validate
--             the manager (whether the manager belongs to the login user
--             HR supervisor hierarchy).
--  HISTORY
--             20-AUG-2002  Created    adabdull
--+
PROCEDURE Check_ManagerName_Or_Id(
                            p_manager_name       IN  VARCHAR2
                           ,p_manager_id         IN  NUMBER
                           ,p_responsibility     IN  VARCHAR2
                           ,p_check              IN  VARCHAR2
                           ,x_manager_id         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                           ,x_msg_count          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                           ,x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                           ,x_error_message_code OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
     l_manager_name   PA_RESOURCES_DENORM.RESOURCE_NAME%TYPE;
     l_manager_id     NUMBER;
BEGIN

     -- this comes from My Resources page because the manager_name passed
     -- here can contain '%'. So we need to get the 'real' person_name and
     -- person_id
     IF p_check = 'Y' THEN
          Get_Person_Id_Name ( p_person_name => p_manager_name
                              ,x_person_id   => l_manager_id
                              ,x_person_name => l_manager_name);
     ELSE
          l_manager_name := p_manager_name;
          l_manager_id   := p_manager_id;
     END IF;


     -- Do not use the manager_id in the select statements if it is null.
     -- Case when user just entered the name, without using LOV
     IF l_manager_id IS NULL THEN
         --dbms_output.put_line('Manager Id is null');

         -- p_responsibility = RM
         -- Validates using pa_rep_res_mgr_v when the user's responsibility
         -- is Resource Manager
         IF p_responsibility = 'RM' THEN
             -- Changes for bug 3616010 - added hint and removed use
             -- of view for performance
             select /* +index PA_RESOURCES_DENORM PA_RESOURCES_DENORM_N2 */
                    manager_id into x_manager_id
             from pa_resources_denorm --pa_rep_res_mgr_v
             where manager_name = l_manager_name
             and rownum = 1; -- to stop multiple rows error
             --dbms_output.put_line('mgr id RM - id null ' || x_manager_id);

         ELSE
         -- Validates using pa_managers_v when the user's responsibility is
         -- Super User or Staffing Manager
             select distinct manager_id into x_manager_id
             from pa_managers_v
             where manager_full_name = l_manager_name;
             --dbms_output.put_line('mgr id M - id null ' || x_manager_id);
         END IF;

     ELSE
         --dbms_output.put_line('Manager Id is NOT null');
         -- do a similar check as above, except also use manager_id to
         -- refine the search better (this is the case, when user uses the
         -- LOV to select the manager)
         IF p_responsibility = 'RM' THEN
             -- Changes for bug 3616010 - removed use
             -- of view for performance
             select manager_id into x_manager_id
             from pa_resources_denorm --pa_rep_res_mgr_v
             where manager_name = l_manager_name
               and manager_id   = l_manager_id
               and rownum = 1;
             --dbms_output.put_line('mgr id RM - id not null ' || x_manager_id);
         ELSE
             select distinct manager_id into x_manager_id
             from pa_managers_v
             where manager_full_name = l_manager_name
               and manager_id        = l_manager_id;
             --dbms_output.put_line('mgr id M - id not null ' || x_manager_id);
         END IF;
     END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;
     x_msg_count     := FND_MSG_PUB.Count_Msg;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_manager_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message_code := 'PA_RES_INVALID_MGR_HIER';
      x_msg_count     := FND_MSG_PUB.Count_Msg;

   WHEN TOO_MANY_ROWS THEN
      x_manager_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message_code := 'PA_MULTIPLE_RESOURCE';
      x_msg_count     := FND_MSG_PUB.Count_Msg;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_manager_id := NULL;
      x_msg_count     := FND_MSG_PUB.Count_Msg;

END Check_ManagerName_Or_Id;


--  FUNCTION
--              get_person_name_no_date
--  PURPOSE
--              This function returns the latest person name not
--              based on any date.
--
--  HISTORY
--  28-APR-2003   shyugen

FUNCTION get_person_name_no_date(p_person_id IN NUMBER) RETURN VARCHAR IS

 l_person_name PER_all_PEOPLE_F.FULL_NAME%TYPE := null;

BEGIN

 IF p_person_id IS NOT NULL THEN

   SELECT full_name
     INTO l_person_name
     FROM per_all_people_f
    WHERE person_id = p_person_id
      AND effective_end_date = (SELECT MAX(effective_end_date)
                                  FROM per_all_people_f
                                 WHERE person_id = p_person_id);
 END IF;

 RETURN l_person_name;

EXCEPTION
 WHEN OTHERS THEN
   RETURN null;

END get_person_name_no_date;

--  FUNCTION
--              get_projected_end_date
--  PURPOSE
--              This function returns the projected end date for a
--              contingent worker.
--
--  HISTORY
--  15-APR-2004   ramurthy


FUNCTION get_projected_end_date(p_person_id IN NUMBER) RETURN DATE IS

l_term_date DATE;

BEGIN

 IF p_person_id IS NOT NULL THEN

   SELECT pp.projected_termination_date
     INTO l_term_date
     FROM per_all_assignments_f asg,
          per_periods_of_placement pp
    WHERE asg.person_id = p_person_id
      AND pp.person_id = p_person_id
      AND asg.primary_flag = 'Y'
      AND asg.assignment_type = 'C'
      AND asg.period_of_placement_date_start = pp.date_start
      AND trunc(SYSDATE) BETWEEN trunc(asg.effective_start_date)
                             AND trunc(asg.effective_end_date);

 END IF;

 RETURN l_term_date;

EXCEPTION
 WHEN OTHERS THEN
   RETURN null;

END get_projected_end_date;

 /*bug 3737529 - Code addition starts
 Added the function get_hr_manager_id for this 3737529*/

FUNCTION get_hr_manager_id(p_resource_id IN NUMBER,
                           p_start_date IN  DATE DEFAULT NULL) --Bug 4473484
               RETURN NUMBER
IS

 x_ManagerId PER_PEOPLE_F.PERSON_ID%TYPE := null;
 l_manager_start_date DATE := null;
 v_return_status VARCHAR2(1);
 v_personid NUMBER;
 v_error_message_code    fnd_new_messages.message_name%TYPE;
 l_start_date DATE;
 x_ManagerName  PER_all_PEOPLE_F.FULL_NAME%TYPE :=null;


BEGIN

       -- initialize the return status to success
           v_return_status := FND_API.G_RET_STS_SUCCESS;

--Bug 4473484
      IF p_start_date IS NULL THEN
          l_start_date := sysdate;
      ELSE
          l_start_date := p_start_date;
      END IF;
/*      IF p_assignment_id IS NULL THEN
                  l_start_date := sysdate;
      ELSE
                  --Get the assignment start date
           BEGIN
                  SELECT start_date
                  INTO   l_start_date
                  FROM   pa_project_assignments
                  WHERE  assignment_id = p_assignment_id
                  ;
           EXCEPTION
                          WHEN OTHERS THEN
                l_start_date := sysdate;
                   END;
       END IF; */

         get_person_id(p_resource_id
                     ,v_personid
                     ,v_error_message_code
                     ,v_return_status);
        --check for return status if error found then add it to stack
        IF v_return_status =  FND_API.G_RET_STS_ERROR THEN
           PA_UTILS.add_message(p_app_short_name => 'PA',
                                p_msg_name => v_error_message_code);
        END IF;

if l_start_date > sysdate then
   l_start_date := l_start_date;
elsif l_start_date < sysdate then
   l_start_date := sysdate;
end if;

WHILE (l_manager_start_date is NULL) LOOP
       -- get manager name and id
       get_manager_id_name(v_personid
                          ,l_start_date
                          ,x_ManagerId
                          ,x_ManagerName
                          ,v_error_message_code
                          ,v_return_status);
        IF v_return_status =  FND_API.G_RET_STS_ERROR THEN
           PA_UTILS.add_message(p_app_short_name => 'PA',
                                p_msg_name => v_error_message_code);
        END IF;
        IF x_ManagerId IS NULL  THEN
     x_ManagerName := null;
          l_manager_start_date := trunc(sysdate);
        ELSE

                BEGIN
                        select effective_start_date into l_manager_start_date from pa_employees
                        where person_id=x_ManagerId
                        and active='*';
                EXCEPTION
                        WHEN NO_DATA_FOUND then
                        l_manager_start_date := NULL;
                        v_personid := x_ManagerId;
                        x_ManagerId := null;
                        x_ManagerName:= null;
                END;
        END IF;
END LOOP;

PA_RESOURCE_UTILS.G_HR_SUPERVISOR_NAME := x_ManagerName;
PA_RESOURCE_UTILS.G_HR_SUPERVISOR_ID := x_ManagerId;
-- PA_RESOURCE_UTILS.G_ASSIGNMENT_ID := p_assignment_id; -- Bug 4473484
PA_RESOURCE_UTILS.G_START_DATE := p_start_date;  -- Bug 4473484
PA_RESOURCE_UTILS.G_RESOURCE_ID := p_resource_id;

RETURN x_ManagerId;

END get_hr_manager_id;

FUNCTION get_hr_manager_name(p_resource_id IN NUMBER,p_start_date IN  DATE DEFAULT NULL) RETURN VARCHAR2  -- Bug 4473484
IS
l_supervisor NUMBER;
BEGIN
 IF PA_RESOURCE_UTILS.G_RESOURCE_ID = p_resource_id and PA_RESOURCE_UTILS.G_START_DATE = p_start_date THEN -- Bug 4473484
   null;
 ELSE
   l_supervisor := get_hr_manager_id(p_resource_id => p_resource_id, p_start_date => p_start_date); -- Bug 4473484
 END IF;
   RETURN PA_RESOURCE_UTILS.G_HR_SUPERVISOR_NAME;

END get_hr_manager_name;

/*Bug 3737529: Code Addition ends*/

/* *******************************************************************
 * This function checks to see if the given supplier ID is used by any
 * planning resource lists or resource breakdown structures.  If it is
 * in use, it returns 'Y'; if not, it returns 'N'
 * ******************************************************************* */
FUNCTION chk_supplier_in_use(p_supplier_id IN NUMBER)
RETURN VARCHAR2 IS

l_in_use VARCHAR2(1) := 'N';

BEGIN

   BEGIN
   SELECT 'Y'
   INTO   l_in_use
   FROM   DUAL
   WHERE  EXISTS (SELECT 'Y'
                  FROM   pa_resource_list_members
                  WHERE  vendor_id = p_supplier_id
                  UNION ALL
                  SELECT 'Y'
                  FROM   pa_rbs_elements
                  WHERE  supplier_id = p_supplier_id);

   EXCEPTION WHEN NO_DATA_FOUND THEN
      l_in_use := 'N';
   END;

RETURN l_in_use;

END chk_supplier_in_use;

--
--  FUNCTION
--              get_term_type
--  PURPOSE
--              This function returns the leaving/termination reason type
--              of an employee/contingent worker as 'V' or 'I'
--  HISTORY
--   05-MAR-207       kjai       Created for Bug 5683340
--
FUNCTION get_term_type( p_person_id     IN PA_EMPLOYEES.PERSON_ID%TYPE )
RETURN VARCHAR2
IS

l_formula_id          NUMBER;
l_term_type           VARCHAR2(1);
l_resource_person_type PA_RESOURCES_DENORM.RESOURCE_PERSON_TYPE%TYPE ;

l_leav_reas PER_PERIODS_OF_SERVICE.LEAVING_REASON%TYPE ;
l_term_reas PER_PERIODS_OF_PLACEMENT.TERMINATION_REASON%TYPE ;

CURSOR c_formula
IS
   SELECT formula_id
   FROM   ff_formulas_f
   --WHERE  business_group_id+0 = 0  -- commented as part of bug 7613549
   WHERE  nvl(business_group_id,0) = 0 -- added as part of bug 7613549
   AND    SYSDATE BETWEEN effective_start_date AND effective_end_date
   AND    formula_name = 'HR_PA_MOVE'
   AND    formula_type_id
               = HR_PERSON_FLEX_LOGIC.GetFormulaTypeID('Oracle Payroll');

CURSOR c_leav_reas (c_person_id PA_EMPLOYEES.PERSON_ID%TYPE)
IS
SELECT leaving_reason
FROM (SELECT leaving_reason
      FROM per_periods_of_service
      WHERE person_id = c_person_id
      AND actual_termination_date IS NOT NULL
      ORDER BY actual_termination_date DESC)
WHERE ROWNUM = 1;

CURSOR c_term_reas (c_person_id PA_EMPLOYEES.PERSON_ID%TYPE)
IS
SELECT termination_reason
FROM (SELECT termination_reason
      FROM per_periods_of_placement
      WHERE person_id = c_person_id
      AND actual_termination_date IS NOT NULL
      ORDER BY actual_termination_date DESC)
WHERE ROWNUM = 1;

-- Bug 7588937
CURSOR c_res_person_type (c_person_id PA_EMPLOYEES.PERSON_ID%TYPE)
IS
SELECT  distinct(resource_person_type)
FROM    pa_resources_denorm
WHERE   person_id = c_person_id;

BEGIN

 OPEN  c_formula;
 FETCH c_formula INTO l_formula_id;
 IF (c_formula%NOTFOUND OR c_formula%NOTFOUND IS NULL) THEN

    CLOSE c_formula;
    l_term_type := 'V';

 ELSE

    -- Start Changes for Bug 7588937

    /*SELECT  distinct(resource_person_type)
    INTO    l_resource_person_type
    FROM    pa_resources_denorm
    WHERE   person_id = p_person_id;*/

    OPEN c_res_person_type(p_person_id);
    FETCH c_res_person_type INTO l_resource_person_type;
    IF c_res_person_type%NOTFOUND THEN
      --CLOSE c_res_person_type;
      l_term_type := 'V';
    END IF;

    IF ( l_resource_person_type is NULL or l_resource_person_type = '') THEN
      l_term_type := 'V';
    END IF;

    CLOSE c_res_person_type;

    -- End of changes for Bug 7588937

    IF ( l_resource_person_type = 'EMP') THEN

      OPEN c_leav_reas(p_person_id);
      FETCH c_leav_reas INTO l_leav_reas;
      IF c_leav_reas%FOUND THEN
        CLOSE c_leav_reas;
        l_term_type := HR_PERSON_FLEX_LOGIC.GetTermType(p_term_formula_id	=> l_formula_id
                                                             ,p_leaving_reason => l_leav_reas
                                                             ,p_session_date => sysdate);
      ELSE
        CLOSE c_leav_reas;
        l_term_type := 'V';
      END IF ; --IF c_leav_reas%FOUND

    ELSIF (l_resource_person_type = 'CWK' ) THEN

      OPEN c_term_reas(p_person_id);
      FETCH c_term_reas INTO l_term_reas;
      IF c_term_reas%FOUND THEN
        CLOSE c_term_reas;
        l_term_type := HR_PERSON_FLEX_LOGIC.GetTermType(p_term_formula_id	=> l_formula_id
                                                             ,p_leaving_reason => l_term_reas
                                                             ,p_session_date => sysdate);
      ELSE
        CLOSE c_term_reas;
        l_term_type := 'V';
      END IF ; --IF c_term_reas%FOUND

    END IF ;  --IF (l_system_person_type = 'EMP' )

    CLOSE c_formula;

 END IF ;  --IF (c_formula%NOTFOUND OR c_formula%NOTFOUND IS NULL)

 RETURN l_term_type ;

END get_term_type;

--
--  PROCEDURE
--              Init_FTE_Sync_WF
--  PURPOSE
--              This procedure is used to initiate Timeout_termination_process
--              workflow for future termination of employee.
--  HISTORY
--   05-MAR-207       kjai       Created for Bug 5683340
--
PROCEDURE Init_FTE_Sync_WF( p_person_id     IN PA_EMPLOYEES.PERSON_ID%TYPE,
                            x_invol_term        OUT NOCOPY VARCHAR2,
			    x_return_status  OUT NOCOPY VARCHAR2,
			    x_msg_data       OUT NOCOPY VARCHAR2,
			    x_msg_count      OUT NOCOPY NUMBER
			    )
 IS

     l_term_type  VARCHAR2(1);
     l_invol_term VARCHAR2(1);
     l_return_end_date DATE;
     l_wait_days NUMBER;

     l_resource_effective_end_date DATE ;
     l_future_term_wf_flag pa_resources.future_term_wf_flag%TYPE ;

     l_msg_index_out NUMBER;

BEGIN

     -- initialize the error stack
     PA_DEBUG.init_err_stack('PA_RESOURCE_UTILS.Init_FTE_Sync_WF');
     -- initialize the return  status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     l_term_type := pa_resource_utils.get_term_type(p_person_id) ;

	IF (l_term_type = 'I') THEN

            IF( p_person_id <> nvl(G_TERM_PERSON_ID, -999) ) THEN

                G_TERM_PERSON_ID := p_person_id ;

	        pa_resource_utils.is_fte(p_person_id => G_TERM_PERSON_ID,
	                                 x_return_end_date => l_return_end_date,
					 x_invol_term => l_invol_term ,
	                                 x_wait_days => l_wait_days ,
					 x_msg_data => x_msg_data,
					 x_msg_count => x_msg_count,
                                         x_return_status => x_return_status );

		G_FTE_FLAG := l_invol_term;
                G_FTE_DATE := l_return_end_date ;

	    END IF ; --IF( l_person_id <> G_PERSON_ID )


	    IF (NVL(G_FTE_FLAG,'N') = 'Y') THEN

                SELECT max(resource_effective_end_date)
		INTO l_resource_effective_end_date
		FROM pa_resources_denorm
                WHERE person_id = G_TERM_PERSON_ID; --l_person_id

		UPDATE pa_resources_denorm
		SET resource_effective_end_date = G_FTE_DATE,
                last_update_date      = sysdate,
                last_updated_by       = fnd_global.user_id,
                last_update_login     = fnd_global.login_id
		WHERE person_id = G_TERM_PERSON_ID --l_person_id
		AND resource_effective_end_date = l_resource_effective_end_date;

                pa_resource_utils.get_fte_flag(p_person_id => G_TERM_PERSON_ID,
		                               x_future_term_wf_flag => l_future_term_wf_flag,
                                               x_msg_data => x_msg_data,
                                               x_msg_count => x_msg_count,
                                               x_return_status => x_return_status);

                IF l_future_term_wf_flag IS NULL THEN

		   PA_HR_UPDATE_PA_ENTITIES.create_fte_sync_wf(p_person_id => G_TERM_PERSON_ID,
		                                               p_wait_days => l_wait_days,
		                                               x_return_status => x_return_status,
							       x_msg_count => x_msg_count,
							       x_msg_data => x_msg_data);


                   pa_resource_utils.set_fte_flag(p_person_id  => G_TERM_PERSON_ID,
                                                  p_future_term_wf_flag => 'Y',
						  x_msg_data => x_msg_data,
                                                  x_msg_count => x_msg_count,
                                                  x_return_status => x_return_status  ) ;

		   l_invol_term  := 'Y';


                ELSE -- IF l_future_term_wf_flag IS NULL

		   l_invol_term  := 'Y';

		END IF ; --IF l_future_term_wf_flag IS NULL

	    ELSE -- IF (G_FTE_FLAG = 'Y')

	       pa_resource_utils.set_fte_flag(p_person_id  => G_TERM_PERSON_ID,
                                              p_future_term_wf_flag => NULL,
					      x_msg_data => x_msg_data,
                                              x_msg_count => x_msg_count,
                                              x_return_status => x_return_status) ;

               l_invol_term := 'N';

	    END IF ; --IF (G_FTE_FLAG = 'Y')


	ELSE   --IF (l_term_type = 'I')

	 l_invol_term := 'N';

	 /* Added for Bug 6056112 */
	 pa_resource_utils.set_fte_flag(p_person_id  => p_person_id,
                                  p_future_term_wf_flag => NULL,
                                  x_msg_data => x_msg_data,
                                  x_msg_count => x_msg_count,
                                  x_return_status => x_return_status) ;

	END IF ; --IF (l_term_type = 'I')


    x_invol_term := l_invol_term ;

    -- reset the error stack
    PA_DEBUG.reset_err_stack;


EXCEPTION
     WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data  := substr(SQLERRM,1,240);
     FND_MSG_PUB.add_exc_msg( p_pkg_name => 'PA_RESOURCE_UTILS',
       p_procedure_name   => 'Init_FTE_sync_wf');
       If x_msg_count = 1 THEN
          pa_interface_utils_pub.get_messages
            (p_encoded        => FND_API.G_TRUE,
             p_msg_index      => 1,
             p_msg_count      => x_msg_count,
             p_msg_data       => x_msg_data,
             p_data           => x_msg_data,
             p_msg_index_out  => l_msg_index_out );
       End If;
     raise;
END Init_FTE_Sync_WF;


--
--  PROCEDURE
--              set_fte_flag
--  PURPOSE
--              This procedure sets the new future_term_wf_flag
--              in table pa_resources for the passed person_id
--  HISTORY
--  05-MAR-207       kjai       Created for Bug 5683340
--
PROCEDURE set_fte_flag(p_person_id     IN PA_EMPLOYEES.PERSON_ID%TYPE,
                       p_future_term_wf_flag IN PA_RESOURCES.FUTURE_TERM_WF_FLAG%TYPE,
		       x_return_status OUT	NOCOPY VARCHAR2,
		       x_msg_data OUT NOCOPY VARCHAR2,
                       x_msg_count OUT NOCOPY NUMBER)
IS
     l_resource_id  PA_RESOURCES.RESOURCE_ID%TYPE ;

     l_msg_index_out NUMBER;

BEGIN
     -- initialize the error stack
     PA_DEBUG.init_err_stack('PA_RESOURCE_UTILS.set_fte_flag');
     -- initialize the return  status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     l_resource_id := pa_resource_utils.get_resource_id(p_person_id);

     IF NVL(l_resource_id,-999) <> -999 THEN

       UPDATE pa_resources
       SET future_term_wf_flag = p_future_term_wf_flag,
         last_update_date      = sysdate,
         last_updated_by       = fnd_global.user_id,
         last_update_login     = fnd_global.login_id
       WHERE
         resource_id = l_resource_id;

     ELSIF NVL(l_resource_id,-999) = -999 THEN
       x_return_status := FND_API.G_RET_STS_ERROR;

     END IF ; --IF l_resource_id <> -999

    -- reset the error stack
    PA_DEBUG.reset_err_stack;

EXCEPTION
     WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data  := substr(SQLERRM,1,240);
     FND_MSG_PUB.add_exc_msg( p_pkg_name => 'PA_RESOURCE_UTILS',
       p_procedure_name   => 'set_fte_flag');
       If x_msg_count = 1 THEN
          pa_interface_utils_pub.get_messages
            (p_encoded        => FND_API.G_TRUE,
             p_msg_index      => 1,
             p_msg_count      => x_msg_count,
             p_msg_data       => x_msg_data,
             p_data           => x_msg_data,
             p_msg_index_out  => l_msg_index_out );
       End If;
     raise;

END set_fte_flag;

--
--  FUNCTION
--              get_fte_flag
--  PURPOSE
--              This function gets the new future_term_wf_flag
--              in table pa_resources for the passed person_id
--  HISTORY
--  05-MAR-207       kjai       Created for Bug 5683340
--
PROCEDURE Get_fte_flag(p_person_id     IN PA_EMPLOYEES.PERSON_ID%TYPE,
                       x_future_term_wf_flag OUT NOCOPY PA_RESOURCES.FUTURE_TERM_WF_FLAG%TYPE,
                       x_return_status OUT  NOCOPY VARCHAR2,
                       x_msg_data      OUT  NOCOPY VARCHAR2,
                       x_msg_count OUT NOCOPY NUMBER)
IS
     l_resource_id  PA_RESOURCES.RESOURCE_ID%TYPE ;
     l_future_term_wf_flag PA_RESOURCES.FUTURE_TERM_WF_FLAG%TYPE ;

     l_msg_index_out NUMBER;

BEGIN
     -- initialize the error stack
     PA_DEBUG.init_err_stack('PA_RESOURCE_UTILS.get_fte_flag');
     -- initialize the return  status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     l_resource_id := pa_resource_utils.get_resource_id(p_person_id);

     IF NVL(l_resource_id,-999) <> -999 THEN

       SELECT pa_resources.future_term_wf_flag
       INTO l_future_term_wf_flag
       FROM pa_resources
       WHERE resource_id = l_resource_id;

     ELSIF NVL(l_resource_id,-999) = -999 THEN

       x_return_status := FND_API.G_RET_STS_ERROR;
       l_future_term_wf_flag := NULL ;

     END IF ;

     x_future_term_wf_flag := l_future_term_wf_flag ;

    -- reset the error stack
    PA_DEBUG.reset_err_stack;

EXCEPTION
     WHEN OTHERS THEN
     x_future_term_wf_flag := NULL;
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data  := substr(SQLERRM,1,240);
     FND_MSG_PUB.add_exc_msg( p_pkg_name => 'PA_RESOURCE_UTILS',
       p_procedure_name   => 'get_fte_flag');
       If x_msg_count = 1 THEN
          pa_interface_utils_pub.get_messages
            (p_encoded        => FND_API.G_TRUE,
             p_msg_index      => 1,
             p_msg_count      => x_msg_count,
             p_msg_data       => x_msg_data,
             p_data           => x_msg_data,
             p_msg_index_out  => l_msg_index_out );
       End If;
     raise;

END get_fte_flag;

--
--  PROCEDURE
--              is_fte
--  PURPOSE
--              This procedure checks whether the person is an FTE, as of sysdate.
--              If he is, then returns the actual term date , wait days.
--  HISTORY
--  05-MAR-207       kjai       Created for Bug 5683340
--
PROCEDURE is_fte(p_person_id     IN PA_EMPLOYEES.PERSON_ID%TYPE ,
                  x_return_end_date OUT	NOCOPY DATE ,
		  x_wait_days OUT	NOCOPY NUMBER ,
		  x_invol_term OUT	NOCOPY VARCHAR2,
		  x_return_status OUT	NOCOPY VARCHAR2,
		  x_msg_data OUT	NOCOPY VARCHAR2,
		  x_msg_count OUT	NOCOPY NUMBER)
IS
     l_resource_person_type PA_RESOURCES_DENORM.RESOURCE_PERSON_TYPE%TYPE ;
     l_end_date DATE ;
     l_valid_end_date DATE ;
     l_time_left NUMBER ;

     l_msg_index_out NUMBER;

BEGIN
    -- initialize the error stack
     PA_DEBUG.init_err_stack('PA_RESOURCE_UTILS.is_fte');
     -- initialize the return  status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT  distinct(resource_person_type)
    INTO    l_resource_person_type
    FROM    pa_resources_denorm
    WHERE   person_id = p_person_id;

    IF ( l_resource_person_type = 'EMP') THEN

         SELECT TRUNC (NVL( MAX(actual_termination_date), SYSDATE ))
	 INTO l_end_date
	 FROM per_periods_of_service
         WHERE person_id = p_person_id
	 AND actual_termination_date IS NOT NULL;

    ELSIF (l_resource_person_type = 'CWK' ) THEN

	 SELECT TRUNC (NVL( MAX(actual_termination_date), SYSDATE ))
	 INTO l_end_date
	 FROM per_periods_of_placement
         WHERE person_id = p_person_id
         AND actual_termination_date IS NOT NULL;

    END IF ;  --IF (l_system_person_type = 'EMP' )

    IF (l_end_date > trunc(sysdate)) THEN

             pa_resource_utils.get_valid_enddate(p_person_id => p_person_id,
                                                 p_actual_term_date => l_end_date,
                                                 x_valid_end_date => l_valid_end_date,
						 x_msg_data => x_msg_data,
                                                 x_msg_count => x_msg_count,
                                                 x_return_status => x_return_status);

	     l_time_left := l_end_date - trunc(SYSDATE) +1 ; -- bug#8916777

             x_return_end_date := l_valid_end_date ;
	     x_wait_days :=  l_time_left ;
	     x_invol_term := 'Y' ;

    ELSE
             x_return_end_date := NULL ;
	     x_wait_days :=  0 ;
	     x_invol_term := 'N' ;

    END IF ; --(trunc(l_end_date) > trunc(sysdate))

    -- reset the error stack
    PA_DEBUG.reset_err_stack;

EXCEPTION
     WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data  := substr(SQLERRM,1,240);
     FND_MSG_PUB.add_exc_msg( p_pkg_name => 'PA_RESOURCE_UTILS',
       p_procedure_name   => 'is_fte');
       If x_msg_count = 1 THEN
          pa_interface_utils_pub.get_messages
            (p_encoded        => FND_API.G_TRUE,
             p_msg_index      => 1,
             p_msg_count      => x_msg_count,
             p_msg_data       => x_msg_data,
             p_data           => x_msg_data,
             p_msg_index_out  => l_msg_index_out );
       End If;
     raise;

END is_fte;

--
--  PROCEDURE
--              get_valid_enddate
--  PURPOSE
--              This procedure returns a valid end date if person is an FTE(as of sysdate)
--
--  HISTORY
--  05-MAR-207       kjai       Created for Bug 5683340
--
PROCEDURE get_valid_enddate(p_person_id     IN PA_EMPLOYEES.PERSON_ID%TYPE ,
                            p_actual_term_date IN DATE  ,
		            x_valid_end_date OUT NOCOPY DATE,
			    x_return_status OUT	NOCOPY VARCHAR2,
                            x_msg_data OUT	NOCOPY VARCHAR2,
                            x_msg_count OUT	NOCOPY NUMBER)
IS
       l_max_res_denorm_end_date DATE ;

       l_msg_index_out NUMBER;

BEGIN
     -- initialize the error stack
     PA_DEBUG.init_err_stack('PA_RESOURCE_UTILS.get_valid_enddate');
     -- initialize the return  status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;


       SELECT TRUNC (MAX (resource_effective_end_date))
       INTO l_max_res_denorm_end_date
       FROM pa_resources_denorm
       WHERE person_id = p_person_id;

       IF ( (l_max_res_denorm_end_date <> to_date('31/12/4712','DD/MM/YYYY'))
            AND
            (l_max_res_denorm_end_date <> p_actual_term_date )
	  ) THEN

            x_valid_end_date := l_max_res_denorm_end_date ;

      ELSE

           x_valid_end_date := to_date('31/12/4712','DD/MM/YYYY') ;

      END IF ;

    -- reset the error stack
    PA_DEBUG.reset_err_stack;

EXCEPTION
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count := 1;
     x_msg_data  := substr(SQLERRM,1,240);
     FND_MSG_PUB.add_exc_msg( p_pkg_name => 'PA_RESOURCE_UTILS',
       p_procedure_name   => 'get_valid_enddate');
       If x_msg_count = 1 THEN
          pa_interface_utils_pub.get_messages
            (p_encoded        => FND_API.G_TRUE,
             p_msg_index      => 1,
             p_msg_count      => x_msg_count,
             p_msg_data       => x_msg_data,
             p_data           => x_msg_data,
             p_msg_index_out  => l_msg_index_out );
       End If;
     raise;
END get_valid_enddate;

--
--  PROCEDURE
--              is_term_as_of_sys_date
--  PURPOSE
--              This procedure checks whether the employee / cwk
--              is terminated as of sysdate
--  HISTORY
--   05-MAR-207       kjai       Created for Bug 5683340
--
PROCEDURE is_term_as_of_sys_date( itemtype                       IN      VARCHAR2
                                 , itemkey                       IN      VARCHAR2
                                 , actid                         IN      NUMBER
                                 , funcmode                      IN      VARCHAR2
                                 , resultout                     OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

CURSOR c_act_term_date (c_person_id PA_EMPLOYEES.PERSON_ID%TYPE)
IS
SELECT TRUNC (NVL (ACT_TERM_DATE, sysdate))
FROM
(SELECT MAX(actual_termination_date)"ACT_TERM_DATE"
 FROM per_periods_of_service
 WHERE person_id = c_person_id
 AND actual_termination_date IS NOT NULL
 UNION
 SELECT MAX(actual_termination_date)"ACT_TERM_DATE"
 FROM per_periods_of_placement
 WHERE person_id = c_person_id
 AND actual_termination_date IS NOT NULL )
WHERE ACT_TERM_DATE IS NOT NULL ;


l_person_id             PA_EMPLOYEES.PERSON_ID%TYPE;
l_future_term_wf_flag pa_resources.future_term_wf_flag%TYPE ;
l_end_date DATE ;

l_msg_count                NUMBER;
l_msg_data                VARCHAR(2000);
l_return_status                VARCHAR2(1);

l_pa_debug_mode VARCHAR2(1):= NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

BEGIN
-- initialize the error stack
--
   PA_DEBUG.init_err_stack('PA_RESOURCE_UTILS.is_term_as_of_sys_date');

IF (l_pa_debug_mode = 'Y') THEN
 pa_debug.write('PA_RESOURCE_UTILS',
                'log: ' || 'in procedure is_term_as_of_sys_date', 3);
END IF;


-- Get the workflow attribute values
--
l_person_id  := wf_engine.GetItemAttrNumber(itemtype        => itemtype,
                                            itemkey         => itemkey,
                                            aname           => 'PERSON_ID' );

--get the future_term_wf_flag from pa_resources
--
pa_resource_utils.get_fte_flag(p_person_id => l_person_id,
		               x_future_term_wf_flag => l_future_term_wf_flag,
                               x_msg_data => l_msg_data,
                               x_msg_count => l_msg_count,
                               x_return_status => l_return_status);

IF (l_pa_debug_mode = 'Y') THEN
       pa_debug.write('PA_RESOURCE_UTILS',
                'log: ' || 'in procedure is_term_as_of_sys_date, l_future_term_wf_flag: '||l_future_term_wf_flag, 3);
END IF ;

OPEN c_act_term_date(l_person_id);
FETCH c_act_term_date INTO l_end_date;

IF c_act_term_date%NOTFOUND THEN
   CLOSE c_act_term_date;
   resultout := wf_engine.eng_completed||':'||'E';
   IF (l_pa_debug_mode = 'Y') THEN
       pa_debug.write('PA_RESOURCE_UTILS',
                'log: ' || 'in procedure is_term_as_of_sys_date, no end date found', 3);
   END IF;

ELSE --IF c_act_term_date%NOTFOUND

   CLOSE c_act_term_date;
   IF (l_pa_debug_mode = 'Y') THEN
       pa_debug.write('PA_RESOURCE_UTILS',
                'log: ' || 'in procedure is_term_as_of_sys_date, l_end_date: '||l_end_date, 3);
   END IF;


   IF ((l_future_term_wf_flag = 'Y') AND (l_end_date <= trunc(sysdate))) THEN   --Bug#9463127
       resultout := wf_engine.eng_completed||':'||'S';
   ELSE
       resultout := wf_engine.eng_completed||':'||'E';
   END IF ;

END IF ; --IF c_act_term_date%NOTFOUND

IF (l_pa_debug_mode = 'Y') THEN
 pa_debug.write('PA_RESOURCE_UTILS',
                'log: ' || 'in procedure is_term_as_of_sys_date, resultout: '||resultout, 3);
END IF;


EXCEPTION
WHEN OTHERS THEN
  wf_core.context('pa_resource_utils',
                            'is_term_as_of_sys_date',
                             itemtype,
                             itemkey,
                             to_char(actid),
                             funcmode);
  resultout := wf_engine.eng_completed||':'||'U';



END is_term_as_of_sys_date;

END pa_resource_utils ;

/
