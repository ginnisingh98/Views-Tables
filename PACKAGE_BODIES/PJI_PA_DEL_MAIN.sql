--------------------------------------------------------
--  DDL for Package Body PJI_PA_DEL_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_PA_DEL_MAIN" as
  /* $Header: PJIDFW1B.pls 120.0.12010000.4 2010/01/22 07:19:01 arbandyo noship $ */

  -- -----------------------------------------------------
  -- procedure DELETE
  --
  -- This the the main procedure, it is invoked from
  -- a concurrent program.
  -- -----------------------------------------------------
  procedure DELETE
  (
    errbuf                    out nocopy varchar2,
    retcode                   out nocopy varchar2,
    p_operating_unit          in         number   default null,
    p_from_project            in         varchar2 default null,
    p_to_project              in         varchar2 default null,
    p_fp_option               in         varchar2 default null,
    p_plan_type               in         number   default null,
    p_wp_option               in         varchar2 default null,
    p_rep_only                in         varchar2 default 'Y'
  )
is
    l_from_project_num         varchar2(25);
    l_to_project_num           varchar2(25);
    l_return_status            varchar2(2);
    l_plan_type_id             number(15);
    l_rep_only                 varchar2(1);
    l_from_project_id          number(20);
    l_to_project_id            number(20);

    cursor proj is
    select project_id
    from pa_projects_all
    where segment1 between l_from_project_num and l_to_project_num;

  begin

    g_retcode := 0;
    g_from_conc := 'Y';

    pa_debug.set_process('PLSQL');
    pa_debug.log_message('=======Concurrent Program Parameters Start =======', 1);
    pa_debug.log_message('Argument => Operating Unit ['||p_operating_unit||']', 1);
    pa_debug.log_message('Argument => From Project Number ['||p_from_project||']', 1);
    pa_debug.log_message('Argument => To Project Number ['||p_to_project||']', 1);
    pa_debug.log_message('Argument => Delete Financial Plans ['||p_fp_option||']', 1);
    pa_debug.log_message('Argument => Financial Plan Type ['||p_plan_type||']', 1);
    pa_debug.log_message('Argument => Delete Workplans ['||p_wp_option||']', 1);
    pa_debug.log_message('Argument => Reporting Data Only ['||p_rep_only||']', 1);
    pa_debug.log_message('=======Concurrent Program Parameters End =======', 1);

      /*Check for minimum imput parameters */
    if (p_operating_unit is null and p_from_project is null and p_to_project is null) then
         FND_MESSAGE.SET_NAME('PJI', 'PJI_NO_PARAMETER');
         dbms_standard.raise_application_error(-20090, FND_MESSAGE.GET);
    end if;

    /* User should not be able to run for entire operating unit without specifying some
       project range */
    if (p_operating_unit is not null and p_from_project is null and p_to_project is null) then
         FND_MESSAGE.SET_NAME('PJI', 'PJI_NO_PARAMETER');
         dbms_standard.raise_application_error(-20090, FND_MESSAGE.GET);
    end if;

    if p_from_project > p_to_project then
         FND_MESSAGE.SET_NAME('PJI', 'PJI_INVALID_RANGE');
         dbms_standard.raise_application_error(-20091, FND_MESSAGE.GET);
    end if;

    IF  p_from_project is not null or p_to_project is not null then
        select min(segment1) ,max(segment1)
        into l_from_project_num, l_to_project_num
        from pa_projects_all
        where segment1 between nvl(p_from_project,segment1) and nvl(p_to_project,segment1)
        and decode(p_operating_unit,NULL,org_id,p_operating_unit) = org_id; /* Added for bug 9072943 */
    END if;

    /* Plan Type id */
    if (p_plan_type is not null) then
        l_plan_type_id := p_plan_type;
    else
        l_plan_type_id := 0;
    end if;

    /* Reporting Only */
    if (p_rep_only is not null) then
        l_rep_only := p_rep_only;
    else
        l_rep_only := 'Y';
    end if;

    pa_debug.log_message('Validated inputs :', 1);
    pa_debug.log_message('From Project Num :'||l_from_project_num, 1);
    pa_debug.log_message('To Project Num :'||l_to_project_num, 1);
    pa_debug.log_message('Plan Type ID :'||l_plan_type_id, 1);
    pa_debug.log_message('Reporting Only :'||l_rep_only, 1);

    for c1 in proj loop

        if p_wp_option = 'DEL_NLE_PUB_VER'  then
            /* Call procedure to delete eligible workplan versions */
            DELETE_WP(p_project_id     => c1.project_id,
                      p_rep_only       => l_rep_only,
                      p_return_status  => l_return_status);

            if l_return_status = 'S' then
               COMMIT;
            end if;
        end if;

        if p_fp_option = 'DEL_NC_NO_BSL_VER'  then
            /* Call procedure to delete eligible financial plan versions */
            DELETE_FP(p_project_id     => c1.project_id,
                      p_plan_type_id   => l_plan_type_id,
                      p_rep_only       => l_rep_only,
                      p_return_status  => l_return_status);

            if l_return_status = 'S' then
               COMMIT;
            end if;
        end if;

    end loop;

    retcode := g_retcode;

    PRINT_OUTPUT(p_from_project => l_from_project_num,
                 p_to_project   => l_to_project_num);

    exception when others then
      rollback;
      IF SQLCODE = -20041 then
        retcode := 1;
      ELSE
        retcode := 2;
        errbuf := sqlerrm;
      END IF;

  end DELETE;

  -- -----------------------------------------------------
  -- procedure PRINT_OUTPUT
  --
  -- This procedure will generate the output report.
  -- -----------------------------------------------------
  procedure PRINT_OUTPUT(p_from_project IN varchar2,
                         p_to_project   IN varchar2)
  is

    l_newline varchar2(10) := '';
    l_rpt_header varchar2(60);
    l_proj_number varchar2(30);
    l_version_name varchar2(30);
    l_proj_name varchar2(30);
    l_rpt_footer varchar2(60);
    l_wp_version  varchar2(60);
    l_from_proj_num  varchar2(30);
    l_to_proj_num  varchar2(30);

    cursor proj_wp(p_from_proj varchar2,p_to_proj varchar2) is
    select pa.segment1 num,wp.name wp_name
    from pa_projects_all pa, pa_proj_elem_ver_structure wp
    where pa.segment1 between p_from_proj and p_to_proj
    and pa.project_id = wp.project_id
    and wp.purged_flag = 'Y'
    and wp.conc_request_id = FND_GLOBAL.CONC_REQUEST_ID; /* Modified for bug 9049425 */

    cursor proj_fp(p_from_proj varchar2,p_to_proj varchar2) is
    select pa.segment1 num,fp.version_name fp_name
    from pa_projects_all pa, pa_budget_versions fp
    where pa.segment1 between p_from_proj and p_to_proj
    and pa.project_id = fp.project_id
    and fp.purged_flag = 'Y'
    and fp.fin_plan_type_id <> 10
    and fp.request_id = FND_GLOBAL.CONC_REQUEST_ID;  /* Modified for bug 9049425 */

  begin

  l_from_proj_num := p_from_project;
  l_to_proj_num := p_to_project;

    pa_debug.log_message('======= Print Output ========== :', 1);
    pa_debug.log_message('From Project Num :'||l_from_proj_num, 1);
    pa_debug.log_message('To Project Num :'||l_from_proj_num, 1);

    FND_MESSAGE.SET_NAME('PA', 'PA_CISI_TEXT_DELETE');
    l_rpt_header := FND_MESSAGE.GET;

    FND_MESSAGE.SET_NAME('PA', 'PA_XC_REPORT');
    l_rpt_header := l_rpt_header||' '||FND_MESSAGE.GET;

        FND_MESSAGE.SET_NAME('PA', 'PA_XC_PROJECT_NUMBER');
    l_proj_number := FND_MESSAGE.GET;

        FND_MESSAGE.SET_NAME('PA', 'PA_XC_PROJECT_NAME');
    l_proj_name := FND_MESSAGE.GET;

        FND_MESSAGE.SET_NAME('PA', 'PA_PMC_FINANCIAL');
    l_version_name := FND_MESSAGE.GET;

        FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_PLAN_VER');
    l_version_name := l_version_name||' '||FND_MESSAGE.GET;

    FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_RPT_FOOTER');
    l_rpt_footer := FND_MESSAGE.GET;

    FND_MESSAGE.SET_NAME('PA', 'PA_PMC_WORKPLAN_VER');
    l_wp_version := FND_MESSAGE.GET;

        PJI_UTILS.WRITE2OUT(fnd_global.local_chr(10)       ||
                               '-----------------------------------------------------------------------------------------------------------------------------------------' );

        PJI_UTILS.WRITE2OUT(fnd_global.local_chr(10)       ||
                               '                                                         '||l_rpt_header);
        PJI_UTILS.WRITE2OUT(fnd_global.local_chr(10)       ||
                               '-----------------------------------------------------------------------------------------------------------------------------------------' );

        PJI_UTILS.WRITE2OUT(fnd_global.local_chr(10)       ||
                               l_Proj_Number||'             '||l_wp_version );
        PJI_UTILS.WRITE2OUT(fnd_global.local_chr(10)       ||
	                   '======================     =================' );

        for rec in proj_wp(l_from_proj_num,l_to_proj_num) loop
          PJI_UTILS.WRITE2OUT(fnd_global.local_chr(10)       ||rpad(rec.num,27,' ')||rec.wp_name);
        END LOOp;

        PJI_UTILS.WRITE2OUT(fnd_global.local_chr(10)       ||
                               '-----------------------------------------------------------------------------------------------------------------------------------------' );

        PJI_UTILS.WRITE2OUT(fnd_global.local_chr(10)       ||
                               l_Proj_Number||'             '||l_version_name );
        PJI_UTILS.WRITE2OUT(fnd_global.local_chr(10)       ||
	                   '======================     ======================' );

        for rec in proj_fp(l_from_proj_num,l_to_proj_num) loop
          PJI_UTILS.WRITE2OUT(fnd_global.local_chr(10)       ||rpad(rec.num,27,' ')||rec.fp_name);
        END LOOp;

        PJI_UTILS.WRITE2OUT(fnd_global.local_chr(10)       ||
                               '----------------------------------------------------------'||l_rpt_footer||'----------------------------------------------------------');

    pa_debug.log_message('======= Print Output End ========== :', 1);

  end PRINT_OUTPUT;

  -- -----------------------------------------------------
  -- procedure DELETE_WP
  --
  -- This procedure will delete eligible workplan versions.
  -- -----------------------------------------------------
  procedure DELETE_WP(p_project_id IN number,
                      p_rep_only   IN varchar2,
                      p_return_status OUT nocopy varchar2) is

  l_api_version_number          NUMBER(10,3) := 1.0; -- API Version
  l_return_status               VARCHAR2(1);
  l_init_msg_list               VARCHAR2(1) := 'T';
  l_msg_count                   NUMBER(20);
  l_msg_index_out               NUMBER(10);
  l_msg_data                    VARCHAR2(2000);
  l_data                        VARCHAR2(2000);

  API_ERROR                     EXCEPTION;

  l_project_id                  NUMBER(15);
  l_budget_version_id           number(20);
  l_structure_version_id_tbl    SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
  l_record_version_number_tbl   SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();

  CURSOR c1 IS
  select element_version_id, record_version_number
  from pa_proj_elem_ver_structure
  where project_id = l_project_id
  and status_code = 'STRUCTURE_PUBLISHED'
  and current_flag <> 'Y'
  and original_flag <> 'Y'
  and nvl(purged_flag,'N') <> 'Y'
  and latest_eff_published_flag <> 'Y';

  BEGIN

  pa_debug.log_message('=======Delete Workplans Start =======', 1);
  pa_debug.log_message('Project ID :'||p_project_id, 1);
  pa_debug.log_message('Reporting Only :'||p_rep_only, 1);

  l_project_id := p_project_id;

  -- Delete only reporting data only
  if p_rep_only = 'Y' then
     pa_debug.log_message('** Delete only Reporting Data **', 1);

     for rec1 in c1 loop

         begin

              select budget_version_id
              into l_budget_version_id
              from pa_budget_versions
              where project_id = l_project_id
              and fin_plan_type_id = 10
              and project_structure_version_id = rec1.element_version_id;

              pa_debug.log_message('To Delete Plan Version id :'||l_budget_version_id, 1);

              delete from pji_fp_xbs_accum_f
              where project_id = l_project_id
              and plan_type_id = 10
              and plan_version_id = l_budget_version_id;

              pa_debug.log_message('Records deleted :'||sql%rowcount, 1);

         exception
              when no_data_found then
                   null;
              when others then
                   --DBMS_OUTPUT.PUT_LINE('An error occurred, sqlcode = ' || sqlcode);
                   rollback;
                   raise_application_error(-20002, 'ORACLE error: '||sqlerrm);
         end;

     end loop;

  else /* else of Delete only reporting data only */

   -- Fetching all the Published Workplan Version except Latest Pubished,
   -- Original Baseline and Current Working Versions.
   FOR rec IN c1 LOOP
   		 l_structure_version_id_tbl.extend(1);
   		 l_record_version_number_tbl.extend(1);
   		 l_structure_version_id_tbl(l_structure_version_id_tbl.count)   := rec.element_version_id;
   		 l_record_version_number_tbl(l_record_version_number_tbl.count) := rec.record_version_number;
   END LOOP;

   if l_structure_version_id_tbl.count >0 then
   -- Calling DELETE_PUBLISHED_STRUCTURE_VER API
   pa_debug.log_message('Calling Delete API for workplans', 1);
   PA_PROJECT_STRUCTURE_PUB1.DELETE_PUBLISHED_STRUCTURE_VER
   ( p_api_version                => l_api_version_number
    ,p_init_msg_list              => l_init_msg_list
    ,p_project_id                 => l_project_id
    ,p_structure_version_id_tbl   => l_structure_version_id_tbl
    ,p_record_version_number_tbl  => l_record_version_number_tbl
    ,x_return_status              => l_return_status
    ,x_msg_count                  => l_msg_count
    ,x_msg_data                   => l_msg_data
   );
   end if;

end if; /* else of Delete only reporting data only */

   pa_debug.log_message('Done deleting workplans', 1);
   pa_debug.log_message('Return status :'||l_return_status, 1);

   IF l_return_status <> 'S' THEN
    raise API_ERROR;
   END IF;

   p_return_status := l_return_status;
   pa_debug.log_message('=======Delete Workplans End =======', 1);

  EXCEPTION
     WHEN NO_DATA_FOUND then
        NULL;
     When OTHERS then
        --DBMS_OUTPUT.PUT_LINE('An error occurred, sqlcode = ' || sqlcode);
        if l_msg_count >= 1 then
          for i in 1..l_msg_count loop
            pa_interface_utils_pub.get_messages(
                    p_msg_count     => l_msg_count,
                    p_encoded       => 'F',
                    p_msg_data      => l_msg_data,
                    p_data          => l_data,
                    p_msg_index_out => l_msg_index_out);
            --DBMS_OUTPUT.PUT_LINE('error message: ' || l_data);
          end loop;
          rollback;
        end if;
        raise_application_error(-20002, 'ORACLE error: '||sqlerrm);

  END DELETE_WP;

  -- -----------------------------------------------------
  -- procedure DELETE_FP
  --
  -- This procedure will delete eligible financial plan
  -- versions.
  -- -----------------------------------------------------
  procedure DELETE_FP(p_project_id IN number,
                      p_plan_type_id IN number,
                      p_rep_only   IN varchar2,
                      p_return_status OUT nocopy varchar2) is

  l_return_status               VARCHAR2(1);
  l_init_msg_list               VARCHAR2(1) := 'T';
  l_msg_count                   NUMBER(20);
  l_msg_index_out               NUMBER(10);
  l_msg_data                    VARCHAR2(2000);
  l_data                        VARCHAR2(2000);

  API_ERROR                     EXCEPTION;

  l_project_id                  NUMBER(15);
  l_plan_type_id                number(15);
  -- Fetching the Baselined Versions eligible for deletion
  CURSOR c1 IS
  SELECT budget_version_id,record_version_number
  FROM pa_budget_versions
  WHERE project_id = l_project_id
  AND fin_plan_type_id <> 10
  AND budget_status_code = 'B'
  AND current_flag <> 'Y'
  AND current_original_flag <> 'Y'
  and nvl(purged_flag,'N') <> 'Y';

  CURSOR c2 IS
  SELECT budget_version_id,record_version_number
  FROM pa_budget_versions
  WHERE project_id = l_project_id
  AND fin_plan_type_id = l_plan_type_id
  AND budget_status_code = 'B'
  AND current_flag <> 'Y'
  AND current_original_flag <> 'Y'
  and nvl(purged_flag,'N') <> 'Y';

  BEGIN

  pa_debug.log_message('=======Delete Financial Plans Start =======', 1);
  pa_debug.log_message('Project ID :'||p_project_id, 1);
  pa_debug.log_message('Plan Type ID :'||p_plan_type_id, 1);

  l_project_id := p_project_id;
  l_plan_type_id := p_plan_type_id;

  if (p_plan_type_id <> 0) then

       pa_debug.log_message('Plan Type ID is passed', 1);
       FOR rec IN c2 LOOP

        if p_rep_only = 'Y' then
            pa_debug.log_message('** Delete only Reporting Data **', 1);

            begin
              pa_debug.log_message('To Delete Plan Version id :'||rec.budget_version_id, 1);

              delete from pji_fp_xbs_accum_f
              where project_id = l_project_id
              and plan_version_id = rec.budget_version_id;

              pa_debug.log_message('Records deleted :'||sql%rowcount, 1);

           exception
                when no_data_found then
                     null;
                when others then
                     --DBMS_OUTPUT.PUT_LINE('An error occurred, sqlcode = ' || sqlcode);
                     rollback;
                     raise_application_error(-20002, 'ORACLE error: '||sqlerrm);
           end;

        else
            pa_debug.log_message('To Delete Plan Version id :'||rec.budget_version_id, 1);
            pa_fin_plan_pub.Delete_Version
              (p_project_id              => l_project_id,
               p_budget_version_id       => rec.budget_version_id,
               p_record_version_number   => rec.record_version_number,
               x_return_status           => l_return_status,
               x_msg_count               => l_msg_count,
               x_msg_data                => l_msg_data);
       end if;

       END LOOP;

       IF l_return_status <> 'S' THEN
        raise API_ERROR;
       END IF;

       pa_debug.log_message('Done deleting Financial Plans', 1);
       pa_debug.log_message('Return status :'||l_return_status, 1);

       p_return_status := l_return_status;
       pa_debug.log_message('=======Delete Financial Plans End =======', 1);

  else

       pa_debug.log_message('Plan Type ID is not passed', 1);
       FOR rec IN c1 LOOP

        if p_rep_only = 'Y' then
            pa_debug.log_message('** Delete only Reporting Data **', 1);

            begin
              pa_debug.log_message('To Delete Plan Version id :'||rec.budget_version_id, 1);

              delete from pji_fp_xbs_accum_f
              where project_id = l_project_id
              and plan_version_id = rec.budget_version_id;

              pa_debug.log_message('Records deleted :'||sql%rowcount, 1);

           exception
                when no_data_found then
                     null;
                when others then
                     --DBMS_OUTPUT.PUT_LINE('An error occurred, sqlcode = ' || sqlcode);
                     rollback;
                     raise_application_error(-20002, 'ORACLE error: '||sqlerrm);
           end;

        else
            pa_debug.log_message('To Delete Plan Version id :'||rec.budget_version_id, 1);
            pa_fin_plan_pub.Delete_Version
              (p_project_id              => l_project_id,
               p_budget_version_id       => rec.budget_version_id,
               p_record_version_number   => rec.record_version_number,
               x_return_status           => l_return_status,
               x_msg_count               => l_msg_count,
               x_msg_data                => l_msg_data);
       end if;

       END LOOP;

       IF l_return_status <> 'S' THEN
        raise API_ERROR;
       END IF;

       pa_debug.log_message('Done deleting Financial Plans', 1);
       pa_debug.log_message('Return status :'||l_return_status, 1);

       p_return_status := l_return_status;
       pa_debug.log_message('=======Delete Financial Plans End =======', 1);

  end if;

  EXCEPTION
     WHEN NO_DATA_FOUND then
        NULL;
     When OTHERS then
        --DBMS_OUTPUT.PUT_LINE('An error occurred, sqlcode = ' || sqlcode);
        if l_msg_count >= 1 then
          for i in 1..l_msg_count loop
            pa_interface_utils_pub.get_messages(
                    p_msg_count     => l_msg_count,
                    p_encoded       => 'F',
                    p_msg_data      => l_msg_data,
                    p_data          => l_data,
                    p_msg_index_out => l_msg_index_out);
            --DBMS_OUTPUT.PUT_LINE('error message: ' || l_data);
          end loop;
          rollback;
        end if;
        raise_application_error(-20002, 'ORACLE error: '||sqlerrm);

  END DELETE_FP;

end PJI_PA_DEL_MAIN;

/
