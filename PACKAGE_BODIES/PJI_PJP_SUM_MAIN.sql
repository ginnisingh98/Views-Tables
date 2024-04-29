--------------------------------------------------------
--  DDL for Package Body PJI_PJP_SUM_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_PJP_SUM_MAIN" as
  /* $Header: PJISP01B.pls 120.38.12010000.11 2010/05/13 23:14:15 rkuttiya ship $ */


  -- -----------------------------------------------------
  -- function WORKER_STATUS
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  function WORKER_STATUS (p_worker_id in number,
                          p_mode in varchar2) return boolean is

    l_process varchar2(30);
    l_request_id number;

  begin

    l_process := g_process || p_worker_id;

    l_request_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process,
                                                           l_process);

    if (PJI_PROCESS_UTIL.REQUEST_STATUS(p_mode,
                                        l_request_id,
                                        g_full_disp_name) or
        PJI_PROCESS_UTIL.REQUEST_STATUS(p_mode,
                                        l_request_id,
                                        g_incr_disp_name) or
        PJI_PROCESS_UTIL.REQUEST_STATUS(p_mode,
                                        l_request_id,
                                        g_prtl_disp_name) or
        PJI_PROCESS_UTIL.REQUEST_STATUS(p_mode,
                                        l_request_id,
                                        g_rbs_disp_name)) then

      return true;

    else

      return false;

    end if;

  end WORKER_STATUS;


  -- -----------------------------------------------------
  -- function MY_PAD
  -- -----------------------------------------------------
  function MY_PAD (p_length in number,
                   p_char   in varchar2) return varchar2 is

    l_stmt varchar2(2000) := '';

  begin

    for x in 1 .. p_length loop

      l_stmt := l_stmt || p_char;

    end loop;

    return l_stmt;

  end MY_PAD;

 -- -----------------------------------------------------
  -- Function SUBMIT_REQUEST
  --
  --   History
  --   8-Aug-2006  DEGUPTA  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
procedure SUBMIT_REQUEST(
p_worker_id number,
p_request_id OUT nocopy number,
p_prog_name OUT nocopy varchar2)
 IS
 pragma autonomous_transaction;

    l_e_process                  varchar2(30);
    l_e_extraction_type          varchar2(30);
    l_e_run_mode                 varchar2(30);
    l_e_program                  varchar2(240);
    l_e_project_operating_unit   number;
    l_e_project_organization_id  number;
    l_e_project_type             varchar2(50);
    l_e_from_project             varchar2(50);
    l_e_to_project               varchar2(50);
    l_e_plan_type_id             number;
    l_e_rbs_header_id            number;
    l_e_transaction_type   	 varchar2(40);
    l_e_plan_versions         varchar2 (40);

  begin
    l_e_process := g_process || p_worker_id;

    l_e_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                             (l_e_process, 'EXTRACTION_TYPE');

    If PJI_PJP_SUM_MAIN.WORKER_STATUS(p_worker_id, 'RUNNING') then

       -- Means its already running so get the request id and wait to complete that request

	select PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER (l_e_process,l_e_process),
        DECODE(l_e_extraction_type,'PARTIAL',g_prtl_disp_name,'RBS',g_rbs_disp_name,NULL,NULL,g_incr_disp_name)
	into p_request_id,p_prog_name
	from dual;

    else

	-- Need to submit the existing failed worker request

        l_e_project_operating_unit := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                                    (l_e_process, 'PROJECT_OPERATING_UNIT');

        l_e_project_organization_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                                     (l_e_process, 'PROJECT_ORGANIZATION_ID');

        l_e_project_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                          (l_e_process, 'PROJECT_TYPE');

        l_e_from_project := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                          (l_e_process, 'FROM_PROJECT');

        l_e_to_project := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                        (l_e_process, 'TO_PROJECT');

        l_e_plan_type_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                          (l_e_process, 'PLAN_TYPE_ID');

        l_e_rbs_header_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                           (l_e_process, 'RBS_HEADER_ID');

        l_e_transaction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                                 (l_e_process, 'TRANSACTION_TYPE');

        l_e_plan_versions := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                              (l_e_process, 'PLAN_VERSION');

        SELECT
        DECODE(l_e_extraction_type,'PARTIAL','P','RBS','R',NULL,NULL,'I'),
        DECODE(l_e_extraction_type,'PARTIAL',g_prtl_disp_name,'RBS',g_rbs_disp_name,NULL,NULL,g_incr_disp_name),
        DECODE(l_e_project_operating_unit,-1,NULL,l_e_project_operating_unit),
        DECODE(l_e_project_organization_id,-1,NULL,l_e_project_organization_id),
        DECODE(l_e_project_type,'PJI$NULL',NULL,l_e_project_type),
        DECODE(l_e_from_project,'PJI$NULL',NULL,l_e_from_project),
        DECODE(l_e_to_project,'PJI$NULL',NULL,l_e_to_project),
        DECODE(l_e_plan_type_id,-1,NULL,l_e_plan_type_id),
        DECODE(l_e_rbs_header_id,-1,NULL,l_e_rbs_header_id),
        DECODE(l_e_transaction_type,'PJI$NULL',NULL,l_e_transaction_type),
        DECODE(l_e_plan_versions,'PJI$NULL',NULL,l_e_plan_versions)
        INTO
        l_e_run_mode,
        l_e_program,
        l_e_project_operating_unit,
        l_e_project_organization_id,
        l_e_project_type,
        l_e_from_project,
        l_e_to_project,
        l_e_plan_type_id,
        l_e_rbs_header_id,
        l_e_transaction_type,
        l_e_plan_versions
        FROM
        DUAL;


        IF l_e_program is not null then
           p_request_id := FND_REQUEST.SUBMIT_REQUEST(
             application => PJI_UTILS.GET_PJI_SCHEMA_NAME ,	-- Application Name
             program     => l_e_program,						-- Program Name
             sub_request => FALSE,							-- Sub Request
             argument1 => l_e_run_mode,						-- p_run_mode
             argument2 => NVL(to_char(l_e_project_operating_unit),''),   -- p_operating_unit
             argument3 => NVL(to_char(l_e_project_organization_id),''),  -- p_project_organization_id
             argument4 => l_e_project_type,						 -- p_project_type
             argument5 => l_e_from_project ,					 -- p_from_project_num
             argument6 => l_e_to_project ,						 -- p_to_project_num
             argument7 => NVL(to_char(l_e_plan_type_id),'') ,           -- p_plan_type_id
    	     argument8 => NVL(to_char(l_e_rbs_header_id),''),         -- p_rbs_header_id
    	     argument9 => l_e_transaction_type,                             -- p_transaction_type_id
    	     argument10 => l_e_plan_versions);
   pa_debug.log_message('Current Program is submitting failed related Concurrent request with the request no: '||p_request_id, 1);
	       p_prog_name := l_e_program;
        else
		  p_request_id := -1;
		  p_prog_name := NULL;
        end if;
    end if;
Commit;
end;

  -- -----------------------------------------------------
  -- procedure NO_WORK_RUNS
  --
  --   History
  --   20-SEP-2005  DEGUPTA  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure NO_WORK_RUNS (
    p_operating_unit          in            number   default null,
    p_project_organization_id in            number   default null,
    p_project_type            in            varchar2 default null,
    p_from_project            in            varchar2 default null,
    p_to_project              in            varchar2 default null,
    p_extraction_type         in            varchar2 default null,
    p_project_status          in            varchar2 default null )
    is

    l_newline                 varchar2(10) := '
';
    l_no_selection            varchar2(50);

    l_project_type_tg         varchar2(40);
    l_project_organization_tg varchar2(40);
    l_from_project_tg         varchar2(40);
    l_to_project_tg           varchar2(40);
    l_project_operating_unit_tg varchar2(40);
  --12.1.3 enhancement
    l_project_status_tg       varchar2(40);

    l_project_type            varchar2(50);
    l_project_organization    varchar2(300);
    l_from_project            varchar2(50);
    l_to_project              varchar2(50);
    l_project_operating_unit_name varchar2(240);
   --12.1.3 enhancement
    l_project_status          varchar2(100);


  begin

        FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_NO_SUMM_WORK');

        PJI_UTILS.WRITE2OUT(l_newline       ||
                              l_newline       ||
                              FND_MESSAGE.GET ||
                              l_newline);

        FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_NO_SELECTION');

        l_no_selection := FND_MESSAGE.GET;


          if (nvl(p_operating_unit, -1) = -1) then
            l_project_operating_unit_name := l_no_selection;
          else
            select NAME
            into   l_project_operating_unit_name
            from   HR_OPERATING_UNITS
            where  ORGANIZATION_ID = p_operating_unit;
          end if;

          FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_PRJ_OP_UNIT');

          l_project_operating_unit_tg := substr(FND_MESSAGE.GET, 1, 30);

          PJI_UTILS.WRITE2OUT(l_project_operating_unit_tg                      ||
                              my_pad(30 - length(l_project_operating_unit_tg),
                                     ' ')                                    ||
                              ': '                                           ||
                              l_project_operating_unit_name                  ||
                              l_newline);

 if (p_extraction_type in ('FULL', 'INCREMENTAL')) then
        if (nvl(p_project_type, 'PJI$NULL') = 'PJI$NULL') then

            l_project_type := l_no_selection;
        else
            l_project_type := p_project_type;
        end if;

          FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_PRJ_TYPE');

          l_project_type_tg := substr(FND_MESSAGE.GET, 1, 30);

          PJI_UTILS.WRITE2OUT(l_project_type_tg                           ||
                              my_pad(30 - length(l_project_type_tg), ' ') ||
                              ': '                                        ||
                              l_project_type                              ||
                              l_newline);

   --12.1.3 enhancement
        if (nvl(p_project_status, 'PJI$NULL')  = 'PJI$NULL') then
             l_project_status := l_no_selection;
        else
             l_project_status := p_project_status;
        end if;

           FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_PRJ_STATUS');

           l_project_status_tg := substr(FND_MESSAGE.GET, 1, 30);

           PJI_UTILS.WRITE2OUT(l_project_status_tg                          ||
                               my_pad(30 - length(l_project_status_tg), ' ')  ||
                               ':'                                          ||
                               l_project_status                               ||
                               l_newline);



        if (nvl(p_project_organization_id, -1) = -1) then

            l_project_organization := l_no_selection;

          else

            select NAME
            into   l_project_organization
            from   HR_ALL_ORGANIZATION_UNITS_VL
            where  ORGANIZATION_ID = p_project_organization_id;

          end if;

          FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_PRJ_ORG');

          l_project_organization_tg := substr(FND_MESSAGE.GET, 1, 30);

          PJI_UTILS.WRITE2OUT(l_project_organization_tg                      ||
                              my_pad(30 - length(l_project_organization_tg),
                                     ' ')                                    ||
                              ': '                                           ||
                              l_project_organization                         ||
                              l_newline);
end if;

          if (nvl(p_from_project, 'PJI$NULL') = 'PJI$NULL') then

            l_from_project := l_no_selection;
          else
            l_from_project := p_from_project;
          end if;

          FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_FROM_PRJ');

          l_from_project_tg := substr(FND_MESSAGE.GET, 1, 30);

          PJI_UTILS.WRITE2OUT(l_from_project_tg                           ||
                              my_pad(30 - length(l_from_project_tg), ' ') ||
                              ': '                                        ||
                              l_from_project                              ||
                              l_newline);


          if (nvl(p_to_project, 'PJI$NULL') = 'PJI$NULL') then

            l_to_project := l_no_selection;
          else
            l_to_project := p_to_project;
          end if;

          FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_TO_PRJ');

          l_to_project_tg := substr(FND_MESSAGE.GET, 1, 30);

          PJI_UTILS.WRITE2OUT(l_to_project_tg                           ||
                              my_pad(30 - length(l_to_project_tg), ' ') ||
                              ': '                                      ||
                              l_to_project                              ||
                              l_newline);


end NO_WORK_RUNS;

  -- -----------------------------------------------------
  -- procedure OUTPUT_FAILED_RUNS
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure OUTPUT_FAILED_RUNS is

    l_process                 varchar2(30);
    l_extraction_type         varchar2(30);

    l_newline                 varchar2(10) := '
';
    l_no_selection            varchar2(50);
    l_header_flag             varchar2(1);

    l_extraction_type_tg      varchar2(40);
    l_project_type_tg         varchar2(40);
    l_project_organization_tg varchar2(40);
    l_from_project_tg         varchar2(40);
    l_to_project_tg           varchar2(40);
    l_plan_type_tg            varchar2(40);
    l_rbs_header_tg           varchar2(40);
    l_only_pt_projects_tg     varchar2(40);

    l_project_organization_id number;
    l_from_project_id         number;
    l_to_project_id           number;
    l_plan_type_id            number;
    l_rbs_header_id           number;

    l_project_type            varchar2(50);
    l_project_organization    varchar2(300);
    l_from_project            varchar2(50);
    l_to_project              varchar2(50);
    l_plan_type               varchar2(200);
    l_rbs_header              varchar2(300);
    l_only_pt_projects        varchar2(50);
    l_request_id              number;
    l_request_id_tg           varchar2(40);
    l_project_operating_unit  number;
    l_project_operating_unit_name varchar2(240);
    l_project_operating_unit_tg varchar2(40);

    l_transaction_type   		 varchar2(40);	 --  Bug#5099574 - New parameter for Partial Refresh
    l_plan_versions		varchar2 (40);
    l_transaction_type_tg    		 varchar2(40);
    l_plan_versions_tg	     		varchar2 (40);
    l_transaction_type_id   		 varchar2(40);
    l_plan_versions_id     		varchar2 (40);



  begin

    FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_NO_SELECTION');

    l_no_selection := FND_MESSAGE.GET;

    l_header_flag := 'Y';

    for x in 1 .. PJI_PJP_SUM_MAIN.g_parallel_processes loop

      l_process := PJI_PJP_SUM_MAIN.g_process || x;

      l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                           (l_process, 'EXTRACTION_TYPE');

      if (l_extraction_type is not null and
          not PJI_PJP_SUM_MAIN.WORKER_STATUS(x, 'RUNNING')) then

        if (l_header_flag = 'Y') then

          l_header_flag := 'N';

          FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_HEADER');

          PJI_UTILS.WRITE2OUT(l_newline       ||
                              l_newline       ||
                              FND_MESSAGE.GET ||
                              l_newline);

        end if;

        FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_LINE');

        PJI_UTILS.WRITE2OUT(l_newline       ||
                            FND_MESSAGE.GET ||
                            l_newline       ||
                            l_newline);

        FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_EXTR_TYPE');

        l_extraction_type_tg := substr(FND_MESSAGE.GET, 1, 30);

        PJI_UTILS.WRITE2OUT(l_extraction_type_tg                           ||
                            my_pad(30 - length(l_extraction_type_tg), ' ') ||
                            ': ');

        if (l_extraction_type = 'FULL') then

          FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_EXTR_TYPE_FULL');

        elsif (l_extraction_type = 'INCREMENTAL') then

          FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_EXTR_TYPE_INCR');

        elsif (l_extraction_type = 'PARTIAL') then

          FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_EXTR_TYPE_PRTL');

        elsif (l_extraction_type = 'RBS') then

          FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_EXTR_TYPE_RBS');

        end if;

        PJI_UTILS.WRITE2OUT(FND_MESSAGE.GET ||
                            l_newline);

        if (l_extraction_type in ('FULL', 'INCREMENTAL', 'PARTIAL')) then

          l_request_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                                       (l_process, l_process);

          FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_REQ_ID');

          l_request_id_tg := substr(FND_MESSAGE.GET, 1, 30);

          PJI_UTILS.WRITE2OUT(l_request_id_tg                                ||
                              my_pad(30 - length(l_request_id_tg),
                                     ' ')                                    ||
                              ': '                                           ||
                              l_request_id                                ||
                              l_newline);

        end if;


     if (l_extraction_type in ('FULL', 'INCREMENTAL', 'PARTIAL')) then

          l_project_operating_unit := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                                       (l_process, 'PROJECT_OPERATING_UNIT');

          if (nvl(l_project_operating_unit, -1) = -1) then

            l_project_operating_unit_name := l_no_selection;

          else

            select NAME
            into   l_project_operating_unit_name
            from   HR_OPERATING_UNITS
            where  ORGANIZATION_ID = l_project_operating_unit;

          end if;

          FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_PRJ_OP_UNIT');

          l_project_operating_unit_tg := substr(FND_MESSAGE.GET, 1, 30);

          PJI_UTILS.WRITE2OUT(l_project_operating_unit_tg                      ||
                              my_pad(30 - length(l_project_operating_unit_tg),
                                     ' ')                                    ||
                              ': '                                           ||
                              l_project_operating_unit_name                  ||
                              l_newline);

        end if;

        if (l_extraction_type in ('FULL', 'INCREMENTAL')) then

          l_project_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                            (l_process, 'PROJECT_TYPE');

          if (nvl(l_project_type, 'PJI$NULL') = 'PJI$NULL') then

            l_project_type := l_no_selection;

          end if;

          FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_PRJ_TYPE');

          l_project_type_tg := substr(FND_MESSAGE.GET, 1, 30);

          PJI_UTILS.WRITE2OUT(l_project_type_tg                           ||
                              my_pad(30 - length(l_project_type_tg), ' ') ||
                              ': '                                        ||
                              l_project_type                              ||
                              l_newline);

        end if;

        if (l_extraction_type in ('FULL', 'INCREMENTAL')) then

          l_project_organization_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                                       (l_process, 'PROJECT_ORGANIZATION_ID');

          if (nvl(l_project_organization_id, -1) = -1) then

            l_project_organization := l_no_selection;

          else

            select NAME
            into   l_project_organization
            from   HR_ALL_ORGANIZATION_UNITS_VL
            where  ORGANIZATION_ID = l_project_organization_id;

          end if;

          FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_PRJ_ORG');

          l_project_organization_tg := substr(FND_MESSAGE.GET, 1, 30);

          PJI_UTILS.WRITE2OUT(l_project_organization_tg                      ||
                              my_pad(30 - length(l_project_organization_tg),
                                     ' ')                                    ||
                              ': '                                           ||
                              l_project_organization                         ||
                              l_newline);

        end if;

        if (l_extraction_type in ('FULL', 'INCREMENTAL', 'PARTIAL')) then

         l_from_project := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                               (l_process, 'FROM_PROJECT');

          if (nvl(l_from_project, 'PJI$NULL') = 'PJI$NULL') then

            l_from_project := l_no_selection;

          end if;

          FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_FROM_PRJ');

          l_from_project_tg := substr(FND_MESSAGE.GET, 1, 30);

          PJI_UTILS.WRITE2OUT(l_from_project_tg                           ||
                              my_pad(30 - length(l_from_project_tg), ' ') ||
                              ': '                                        ||
                              l_from_project                              ||
                              l_newline);

        end if;

        if (l_extraction_type in ('FULL', 'INCREMENTAL', 'PARTIAL')) then

          l_to_project := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                             (l_process, 'TO_PROJECT');

          if (nvl(l_to_project, 'PJI$NULL') = 'PJI$NULL') then

            l_to_project := l_no_selection;

          end if;

          FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_TO_PRJ');

          l_to_project_tg := substr(FND_MESSAGE.GET, 1, 30);

          PJI_UTILS.WRITE2OUT(l_to_project_tg                           ||
                              my_pad(30 - length(l_to_project_tg), ' ') ||
                              ': '                                      ||
                              l_to_project                              ||
                              l_newline);

        end if;

        if (l_extraction_type in ('PARTIAL')) then

          l_plan_type_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                            (l_process, 'PLAN_TYPE_ID');

          if (nvl(l_plan_type_id, -1) = -1) then

            l_plan_type := l_no_selection;

          else

            select NAME
            into   l_plan_type
            from   PA_FIN_PLAN_TYPES_VL
            where  FIN_PLAN_TYPE_ID = l_plan_type_id;

          end if;

          FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_PLAN_TYPE');

          l_plan_type_tg := substr(FND_MESSAGE.GET, 1, 30);

          PJI_UTILS.WRITE2OUT(l_plan_type_tg                           ||
                              my_pad(30 - length(l_plan_type_tg), ' ') ||
                              ': '                                     ||
                              l_plan_type                              ||
                              l_newline);

        end if;

        if (l_extraction_type in ('RBS')) then

          l_rbs_header_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                             (l_process, 'RBS_HEADER_ID');

          if (nvl(l_rbs_header_id, -1) = -1) then

            l_rbs_header := l_no_selection;

          else

            select NAME
            into   l_rbs_header
            from   PA_RBS_HEADERS_VL
            where  RBS_HEADER_ID = l_rbs_header_id;

          end if;

          FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_RBS_HDR');

          l_rbs_header_tg := substr(FND_MESSAGE.GET, 1, 30);

          PJI_UTILS.WRITE2OUT(l_rbs_header_tg                           ||
                              my_pad(30 - length(l_rbs_header_tg), ' ') ||
                              ': '                                      ||
                              l_rbs_header                              ||
                              l_newline);

        end if;

        if (l_extraction_type in ('PARTIAL')) then		-- Bug#5099574  Start

          l_transaction_type_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                            (l_process, 'TRANSACTION_TYPE');

          l_plan_versions_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                            (l_process, 'PLAN_VERSION');

          if (nvl(l_transaction_type_id, 'PJI$NULL') = 'PJI$NULL') then

            l_transaction_type := l_no_selection;

          else

            select MEANING
            into   l_transaction_type
            from   fnd_lookup_values_vl
            where  LOOKUP_TYPE = 'PJI_REF_TXN_TYPE' and
                   LOOKUP_CODE =l_transaction_type_id;

         FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_TXN_TYPE');

          l_transaction_type_tg := substr(FND_MESSAGE.GET, 1, 30);

          PJI_UTILS.WRITE2OUT(l_transaction_type_tg                           ||
                              my_pad(30 - length(l_transaction_type_tg), ' ') ||
                              ': '                                     ||
                              l_transaction_type                              ||
                              l_newline);


          end if;

	   if (nvl(l_plan_versions_id, 'PJI$NULL') = 'PJI$NULL') then

            l_plan_versions := l_no_selection;

          else

            select MEANING
            into   l_plan_versions
            from   fnd_lookup_values_vl
            where  LOOKUP_TYPE = 'PJI_REF_PLAN_VERSION' and
                   LOOKUP_CODE =l_plan_versions_id;

             FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_PLAN_VER');

          l_plan_versions_tg := substr(FND_MESSAGE.GET, 1, 30);

          PJI_UTILS.WRITE2OUT(l_plan_versions_tg                           ||
                              my_pad(30 - length(l_plan_versions_tg), ' ') ||
                              ': '                                     ||
                              l_plan_versions                              ||
                              l_newline);

          end if;


        end if;	-- Bug#5099574 Ends

        if (l_extraction_type in ('FULL', 'INCREMENTAL') and 1 = 2) then

          l_only_pt_projects := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                                (l_process, 'ONLY_PT_PROJECTS_FLAG');

          if (nvl(l_only_pt_projects, 'PJI$NULL') = 'PJI$NULL') then

            l_only_pt_projects := l_no_selection;

          else

            select MEANING
            into   l_only_pt_projects
            from   FND_LOOKUPS
            where  LOOKUP_TYPE = 'YES_NO' and
                   LOOKUP_CODE = l_only_pt_projects;

          end if;

          FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_SUM_ONLY_PT_PRJ');

          l_only_pt_projects_tg := substr(FND_MESSAGE.GET, 1, 30);

          PJI_UTILS.WRITE2OUT(l_only_pt_projects_tg                      ||
                              my_pad(30 - length(l_only_pt_projects_tg),
                                     ' ')                                ||
                              ': '                                       ||
                              l_only_pt_projects                         ||
                              l_newline);

        end if;

      end if;

    end loop;

  end OUTPUT_FAILED_RUNS;


procedure OUTPUT_ACT_FAILED_RUNS(p_worker_id NUMBER) is

    l_process                 varchar2(30);
    l_extraction_type         varchar2(30);

    l_newline                 varchar2(10) := '
';
    l_report_exists        varchar2(1):='N';
    l_segment1		 varchar2(25);--SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type();
    l_act_err_msg		 varchar2(2000);--SYSTEM.pa_varchar2_2000_tbl_type := SYSTEM.pa_varchar2_2000_tbl_type();
    l_rpt_header varchar2(60);
    l_rpt_info varchar2(500);
    l_proj_number varchar2(30);
    l_rpt_excep_reason varchar2(30);
    l_rpt_footer varchar2(60);
   cursor c_err_report is
   select pa.segment1,map.act_err_msg
   from   pji_pjp_proj_batch_map map,pa_projects_all pa
   where  pa.project_id=map.project_id
   and map.worker_id=p_worker_id
    and    map.act_err_msg is not null
   order by segment1;
   --   and    map.act_err_msg is not null;

  begin


open c_err_report;
fetch c_err_report into l_segment1,    l_act_err_msg;
    IF c_err_report%FOUND THEN
    l_report_exists        :='Y';
    g_retcode := 1;
    END IF;
close c_err_report;
IF    l_report_exists        ='Y' THEN
    FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_FAILED_RPT_HEADER');
    l_rpt_header := FND_MESSAGE.GET;
        FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_FAILED_RPT_INFO');
    l_rpt_info := FND_MESSAGE.GET;
        FND_MESSAGE.SET_NAME('PA', 'PA_XC_PROJECT_NUMBER');
    l_proj_number := FND_MESSAGE.GET;
        FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_EXCEPTION_REASON');
    l_rpt_excep_reason := FND_MESSAGE.GET;
/*    The following projects may have incorrect actuals on workplan pages, please run summarization after rectifying the mentioned exception reason:*/

     FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_RPT_FOOTER');
    l_rpt_footer := FND_MESSAGE.GET;
        PJI_UTILS.WRITE2OUT('-----------------------------------------------------------------------------------------------------------------------------------------' ||
	fnd_global.local_chr(10));


        PJI_UTILS.WRITE2OUT(fnd_global.local_chr(10)       ||
                               '                                                '||l_rpt_header);
        PJI_UTILS.WRITE2OUT(fnd_global.local_chr(10)       ||
                               '-----------------------------------------------------------------------------------------------------------------------------------------' ||
                              fnd_global.local_chr(10));

        PJI_UTILS.WRITE2OUT(fnd_global.local_chr(10)       || l_rpt_info ||
                               fnd_global.local_chr(10));

        PJI_UTILS.WRITE2OUT(fnd_global.local_chr(10)       ||l_proj_number||'            '||l_rpt_excep_reason );
        PJI_UTILS.WRITE2OUT(fnd_global.local_chr(10)       ||
                               '=====================     =================' );
   for  i in c_err_report LOOP

        PJI_UTILS.WRITE2OUT(fnd_global.local_chr(10)       ||rpad(i.segment1,27,' ')||i.act_err_msg);

   END LOOp;

        PJI_UTILS.WRITE2OUT(fnd_global.local_chr(10)       ||
                               '----------------------------------------------------------'||l_rpt_footer||'----------------------------------------------------------');
 END IF;
  end OUTPUT_ACT_FAILED_RUNS;

procedure OUTPUT_ACT_PASSED_RUNS(p_worker_id NUMBER) is

    l_process                 varchar2(30);
    l_extraction_type         varchar2(30);

    l_newline                 varchar2(10) := '
';
    l_report_exists        varchar2(1):='N';
    l_segment1		 varchar2(25);--SYSTEM.pa_varchar2_15_tbl_type := SYSTEM.pa_varchar2_15_tbl_type();
    l_name		 varchar2(50);--SYSTEM.pa_varchar2_2000_tbl_type := SYSTEM.pa_varchar2_2000_tbl_type();
    l_rpt_header varchar2(60);
    l_proj_number varchar2(30);
    l_proj_name varchar2(30);
    l_rpt_footer varchar2(60);

   cursor c_err_report is
   select pa.segment1,pa.name
   from   pji_pjp_proj_batch_map map,pa_projects_all pa
   where  pa.project_id=map.project_id
   and map.worker_id=p_worker_id
   and    map.act_err_msg is  null
   order by segment1;

  begin

    open c_err_report;
    fetch c_err_report into l_segment1,    l_name;
    IF c_err_report%FOUND THEN
        l_report_exists :='Y';
    END IF;
    close c_err_report;

    IF l_report_exists ='Y' THEN
    FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_PASSED_RPT_HEADER');
    l_rpt_header := FND_MESSAGE.GET;
        FND_MESSAGE.SET_NAME('PA', 'PA_XC_PROJECT_NUMBER');
    l_proj_number := FND_MESSAGE.GET;

        FND_MESSAGE.SET_NAME('PA', 'PA_XC_PROJECT_NAME');
    l_proj_name := FND_MESSAGE.GET;
    FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_RPT_FOOTER');
    l_rpt_footer := FND_MESSAGE.GET;

        PJI_UTILS.WRITE2OUT(fnd_global.local_chr(10)       ||
                               '-----------------------------------------------------------------------------------------------------------------------------------------' );

        PJI_UTILS.WRITE2OUT(fnd_global.local_chr(10)       ||
                               '                                                         '||l_rpt_header);
        PJI_UTILS.WRITE2OUT(fnd_global.local_chr(10)       ||
                               '-----------------------------------------------------------------------------------------------------------------------------------------' );

        PJI_UTILS.WRITE2OUT(fnd_global.local_chr(10)       ||
                               l_Proj_Number||'             '||l_Proj_Name );
        PJI_UTILS.WRITE2OUT(fnd_global.local_chr(10)       ||
	                   '======================     =================' );

        for  i in c_err_report LOOP

          PJI_UTILS.WRITE2OUT(fnd_global.local_chr(10)       ||rpad(i.segment1,27,' ')||i.name);

        END LOOp;

        PJI_UTILS.WRITE2OUT(fnd_global.local_chr(10)       ||
                               '----------------------------------------------------------'||l_rpt_footer||'----------------------------------------------------------');
END IF;
  end OUTPUT_ACT_PASSED_RUNS;

  -- -----------------------------------------------------
  -- procedure PLAN_TYPE_CODE_CHANGES
  --
  --   History
  --   4-APR-2006  DEGUPTA  Created
  --
  -- Internal PJP Summarization API for Plan type code enhancement upgradation.
  --
  -- -----------------------------------------------------

Procedure PLAN_TYPE_CODE_CHANGES(p_worker_id in number)  is
  l_count number(10) := 0;
  l_level number(10);
  l_creation_date     date := sysdate;
  l_created_by        number := FND_GLOBAL.USER_ID;
  l_last_update_date     date   := SYSDATE;
  l_last_updated_by      NUMBER := FND_GLOBAL.USER_ID;
  l_last_update_login    NUMBER := FND_GLOBAL.LOGIN_ID;

   cursor C_BOTTOM_UP is
    select /*+ INDEX_FFS (den PJI_XBS_DENORM_N3) */
      SUP_LEVEL
    from
      PJI_XBS_DENORM den
    where
      STRUCT_TYPE = 'PRG' and
      SUB_LEVEL = SUP_LEVEL and
      EXISTS ( SELECT 1 from PJI_FM_EXTR_PLNVER4 ver where ver.worker_id = p_worker_id
      and ver.project_id = den.SUP_PROJECT_ID)
    group by
      SUP_LEVEL
    order by
      SUP_LEVEL desc;

BEGIN
--  pji_utils.write2log('In Procedure plan type code changes');

    select count(bmap.project_id) into l_count
    from PA_PJI_PROJ_EVENTS_LOG elog,
         PJI_PJP_PROJ_BATCH_MAP bmap
       where elog.event_object = to_char(bmap.project_id)
      and elog.event_type = 'PLANTYPE_UPG'
      and bmap.worker_id = p_worker_id;

--  pji_utils.write2log('plan_type_code changes exist count'||l_count);

if l_count > 0 then

   DELETE    PJI_FM_EXTR_PLNVER4 where worker_id = p_worker_id;
   DELETE    PJI_FP_AGGR_PJP1 where worker_id = p_worker_id;

	INSERT INTO PJI_FM_EXTR_PLNVER4
    (
      WORKER_ID                ,
      PROJECT_ID               ,
      PLAN_VERSION_ID          ,
      WBS_STRUCT_VERSION_ID    ,
      RBS_STRUCT_VERSION_ID    ,
      PLAN_TYPE_CODE           ,
      PLAN_TYPE_ID             ,
      TIME_PHASED_TYPE_CODE    ,
      TIME_DANGLING_FLAG       ,
      RATE_DANGLING_FLAG       ,
      PROJECT_TYPE_CLASS       ,
      WP_FLAG                  ,
      CURRENT_FLAG             ,
      ORIGINAL_FLAG            ,
      CURRENT_ORIGINAL_FLAG    ,
      BASELINED_FLAG           ,
	  SECONDARY_RBS_FLAG       ,
      LP_FLAG
    )
      SELECT
        DISTINCT
            worker_id
          , project_id
          , plan_version_id
          , wbs_struct_version_id
          , rbs_struct_version_id
          , plan_type_code
          , plan_type_id
          , time_phased_type_code
          , NULL time_dangling_flag
          , NULL rate_dangling_flag
          , NULL PROJECT_TYPE_CLASS
          , is_wp_flag
          , current_flag          , original_flag
          , current_original_flag
          , baselined_flag
          , SECONDARY_RBS_FLAG
          , lp_flag
     FROM
	 (
    SELECT  p_worker_id worker_id,
            bv.project_id                      project_id
          , bv.budget_version_id               plan_version_id
          , DECODE ( NVL(bv.wp_version_flag, 'N')
		           , 'Y', bv.project_structure_version_id
		           , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
				   )                           wbs_struct_version_id
          , fpo.rbs_version_id                 rbs_struct_version_id -- extract for this rbs version id
          , DECODE (bv.version_type, 'COST' ,'C' , 'REVENUE', 'R', 'A') plan_type_code
          , fpo.fin_plan_type_id               plan_type_id
          , DECODE(bv.version_type
                      , 'ALL',     fpo.all_time_phased_code
                      , 'COST',    fpo.cost_time_phased_code
                      , 'REVENUE', fpo.revenue_time_phased_code
                     )                       time_phased_type_code
		  , NVL(bv.wp_version_flag, 'N') is_wp_flag
		  , bv.current_flag                  current_flag
		  , bv.original_flag                 original_flag
		  , bv.current_original_flag         current_original_flag
		  , DECODE(bv.baselined_date, NULL, 'N', 'Y') baselined_flag
		  , 'N'  		                     SECONDARY_RBS_FLAG
		  , DECODE( NVL(bv.wp_version_flag, 'N')
		          , 'Y'
				  , DECODE(bv.project_structure_version_id
				            , PA_PROJECT_STRUCTURE_UTILS.GET_LATEST_WP_VERSION( bv.project_id) --  IN NUMBER
				         -- , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(bv.project_id)
						 , 'Y'
						 , 'N')
				  , 'N'
				  ) lp_flag
    FROM
           pa_budget_versions bv
         , pa_proj_fp_options  fpo
         , (select distinct bmap.project_id,elog.ATTRIBUTE1 plan_type_id from
                                    PA_PJI_PROJ_EVENTS_LOG elog,
                                    PJI_PJP_PROJ_BATCH_MAP bmap
	                               where elog.event_object = to_char(bmap.project_id)
                                      and elog.EVENT_TYPE = 'PLANTYPE_UPG'
                                      and bmap.worker_id = p_worker_id) logmap
    WHERE 1=1
          AND logmap.project_id = bv.project_id
          AND bv.fin_plan_type_id = logmap.plan_type_id
          AND bv.version_type is not NULL
          AND bv.fin_plan_type_id is not NULL
          AND fpo.project_id = bv.project_id
          AND bv.fin_plan_type_id = fpo.fin_plan_type_id
          AND bv.budget_version_id = fpo.fin_plan_version_id
          AND (bv.current_original_flag = 'Y'
              OR (bv.current_flag||DECODE(bv.baselined_date, NULL, 'N', 'Y')) = 'YY')
          AND fpo.fin_plan_option_level_code = 'PLAN_VERSION'
          AND bv.version_type IN ( 'ALL' , 'COST' , 'REVENUE'));

--  pji_utils.write2log('Inserted +ve records into ver4'||sql%rowcount);
-- This sql will insert all the -3,-4 plan versions for Cost and Rev seperate plan_type_id

INSERT INTO PJI_FM_EXTR_PLNVER4
    (
      WORKER_ID                ,
      PROJECT_ID               ,
      PLAN_VERSION_ID          ,
      WBS_STRUCT_VERSION_ID    ,
      RBS_STRUCT_VERSION_ID    ,
      PLAN_TYPE_CODE           ,
      PLAN_TYPE_ID             ,
      TIME_PHASED_TYPE_CODE    ,
      TIME_DANGLING_FLAG       ,
      RATE_DANGLING_FLAG       ,
      PROJECT_TYPE_CLASS       ,
      WP_FLAG                  ,
      CURRENT_FLAG             ,
      ORIGINAL_FLAG            ,
     CURRENT_ORIGINAL_FLAG    ,
	BASELINED_FLAG        	 ,
	SECONDARY_RBS_FLAG       ,
      LP_FLAG
    )
SELECT DISTINCT bv.worker_id worker_id
               , den.sup_project_id project_id
               , cbco.plan_version_id
               , PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(den.sup_project_id) wbs_struct_version_id
               , bv.rbs_struct_version_id
               , bv.plan_type_code
               , bv.plan_type_id
               , bv.time_phased_type_code
               , NULL -- time dangl flg
               , NULL -- rate dangl flg
               , NULL -- project type class
               , 'N' -- wp flag
               , DECODE(cbco.plan_version_id, -3, 'Y', 'N') current_flag
               , DECODE(cbco.plan_version_id, -4, 'Y', 'N') original_flag
               , DECODE(cbco.plan_version_id, -4, 'Y', 'N') curr_original_flag
               , DECODE(cbco.plan_version_id, -3, 'Y', 'N') baselined_flag
               , bv.SECONDARY_RBS_FLAG
               , bv.lp_flag
          FROM PJI_FM_EXTR_PLNVER4 bv
        	 , pji_xbs_denorm den
        	 , ( SELECT -3 plan_version_id FROM DUAL
        	     UNION ALL
        	     SELECT -4 FROM DUAL ) cbco
          WHERE 1=1
            AND bv.plan_version_id > 0
        	AND bv.wp_flag = 'N'
        	AND bv.baselined_flag = 'Y'
        	AND den.struct_version_id IS NULL
            AND den.struct_type = 'PRG'
        	AND den.sub_id = bv.wbs_struct_version_id
            AND NVL(den.relationship_type, 'WF') IN ('LF', 'WF');

--  pji_utils.write2log('Inserted -3,-4 records into ver4'||sql%rowcount);
-- Delete all the -3,-4 lines from the pji_fp_xbs_accum_f for Cost and Rev plan type  having plan type code is null
--       l_Stage := ' Delete all the -3,-4 lines from the pji_fp_xbs_accum_f for Cost and Rev plan type';

	DELETE pji_rollup_level_status hdr
        where  hdr.plan_version_id < -1
        and exists (select 1 from  pji_fm_extr_plnver4 ver3
                        where ver3.worker_id = p_worker_id
                         and ver3.project_id = hdr.project_id
                         and ver3.plan_version_id = hdr.plan_version_id
			 and ver3.plan_version_id < -1);


       DELETE FROM pji_fp_xbs_accum_f fact
       WHERE fact.plan_version_id <  -1
           and exists (select 1 from  pji_fm_extr_plnver4 ver3
                      where ver3.worker_id = p_worker_id
                       and ver3.project_id = fact.project_id
		       and ver3.plan_version_id = fact.plan_version_id
		       and ver3.plan_type_id = fact.plan_type_id
		       and ver3.plan_version_id < -1);

/*************************************************Rollup for Program Reporting and creating -3 and -4 lines for COST_AND_REV_SEP*/
  -- Inserting all the positive plan version data into the PJP1 table for futher
  -- creation of wbs_rollup_flag = 'Y' lines  and
  -- prg_rollup_flag = 'Y' lines if required
-- Commit;
--  pji_utils.write2log('Inserting all the positive plan version data into the PJP1 table for futher ');

 INSERT INTO PJI_FP_AGGR_PJP1
    (
         WORKER_ID
       , PROJECT_ID
       , PROJECT_ORG_ID
       , PROJECT_ORGANIZATION_ID
       , PROJECT_ELEMENT_ID
       , TIME_ID
       , PERIOD_TYPE_ID
       , CALENDAR_TYPE
       , RBS_AGGR_LEVEL
       , WBS_ROLLUP_FLAG
       , PRG_ROLLUP_FLAG
       , CURR_RECORD_TYPE_ID
       , CURRENCY_CODE
       , RBS_ELEMENT_ID
       , RBS_VERSION_ID
       , PLAN_VERSION_ID
       , PLAN_TYPE_ID
       , RAW_COST
       , BRDN_COST
       , REVENUE
       , BILL_RAW_COST
       , BILL_BRDN_COST
       , BILL_LABOR_RAW_COST
       , BILL_LABOR_BRDN_COST
       , BILL_LABOR_HRS
       , EQUIPMENT_RAW_COST
       , EQUIPMENT_BRDN_COST
       , CAPITALIZABLE_RAW_COST
       , CAPITALIZABLE_BRDN_COST
       , LABOR_RAW_COST
       , LABOR_BRDN_COST
       , LABOR_HRS
       , LABOR_REVENUE
       , EQUIPMENT_HOURS
       , BILLABLE_EQUIPMENT_HOURS
       , SUP_INV_COMMITTED_COST
       , PO_COMMITTED_COST
       , PR_COMMITTED_COST
       , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
       , CUSTOM1
       , CUSTOM2
       , CUSTOM3
       , CUSTOM4
       , CUSTOM5
       , CUSTOM6
       , CUSTOM7
       , CUSTOM8
       , CUSTOM9
       , CUSTOM10
       , CUSTOM11
       , CUSTOM12
       , CUSTOM13
       , CUSTOM14
       , CUSTOM15
       , LINE_TYPE
       , RATE_DANGLING_FLAG
       , TIME_DANGLING_FLAG
       , START_DATE
       , END_DATE
       , PRG_LEVEL
	   , PLAN_TYPE_CODE
	)
select   WORKER_ID
       , F.PROJECT_ID
       , PROJECT_ORG_ID
       , PROJECT_ORGANIZATION_ID
       , PROJECT_ELEMENT_ID
       , TIME_ID
       , PERIOD_TYPE_ID
       , CALENDAR_TYPE
       , RBS_AGGR_LEVEL
       , WBS_ROLLUP_FLAG
       , PRG_ROLLUP_FLAG
       , CURR_RECORD_TYPE_ID
       , CURRENCY_CODE
       , RBS_ELEMENT_ID
       , RBS_VERSION_ID
       , F.PLAN_VERSION_ID
       , f.PLAN_TYPE_ID
       , RAW_COST
       , BRDN_COST
       , REVENUE
       , BILL_RAW_COST
       , BILL_BRDN_COST
       , BILL_LABOR_RAW_COST
       , BILL_LABOR_BRDN_COST
       , BILL_LABOR_HRS
       , EQUIPMENT_RAW_COST
       , EQUIPMENT_BRDN_COST
       , CAPITALIZABLE_RAW_COST
       , CAPITALIZABLE_BRDN_COST
       , LABOR_RAW_COST
       , LABOR_BRDN_COST
       , LABOR_HRS
       , LABOR_REVENUE
       , EQUIPMENT_HOURS
       , BILLABLE_EQUIPMENT_HOURS
       , SUP_INV_COMMITTED_COST
       , PO_COMMITTED_COST
       , PR_COMMITTED_COST
       , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
       , CUSTOM1
       , CUSTOM2
       , CUSTOM3
       , CUSTOM4
       , CUSTOM5
       , CUSTOM6
       , CUSTOM7
       , CUSTOM8
       , CUSTOM9
       , CUSTOM10
       , CUSTOM11
       , CUSTOM12
       , CUSTOM13
       , CUSTOM14
       , CUSTOM15
       , 'UPD'
       , RATE_DANGLING_FLAG
       , TIME_DANGLING_FLAG
       , SYSDATE
       , SYSDATE
       , 0
       ,ver.PLAN_TYPE_CODE
       FROM pji_fp_xbs_accum_f f
      , pji_fm_extr_plnver4 ver
  WHERE 1 = 1
   AND ver.project_id = f.project_id
   AND ver.plan_version_id = f.plan_version_id
   AND ver.plan_type_id = f.plan_type_id
   AND ver.plan_version_id > 0
   AND f.rbs_aggr_level IN ( 'L', 'T' )
   AND f.wbs_rollup_flag = 'N'
   AND f.prg_rollup_flag = 'N'
   AND ver.worker_id = p_worker_id;

--  pji_utils.write2log('Inserted records into pjp1'||sql%rowcount);
   -- for -3,-4 lines having prg_rollup_flag = 'N'
--  pji_utils.write2log('Before rollup_fpr_wbs');

--- pji_pjp_sum_rollup.rollup_fpr_wbs(null);
  for c in C_BOTTOM_UP loop

        l_level := c.SUP_LEVEL;

--  pji_utils.write2log('In loop of rollup_fpr_wbs'||l_level);
        -- rollup project hiearchy

        insert into PJI_FP_AGGR_PJP1
        (
          WORKER_ID,
          RECORD_TYPE,
          PRG_LEVEL,
          LINE_TYPE,
          PROJECT_ID,
          PROJECT_ORG_ID,
          PROJECT_ORGANIZATION_ID,
          PROJECT_ELEMENT_ID,
          TIME_ID,
          PERIOD_TYPE_ID,
          CALENDAR_TYPE,
          RBS_AGGR_LEVEL,
          WBS_ROLLUP_FLAG,
          PRG_ROLLUP_FLAG,
          CURR_RECORD_TYPE_ID,
          CURRENCY_CODE,
          RBS_ELEMENT_ID,
          RBS_VERSION_ID,
          PLAN_VERSION_ID,
          PLAN_TYPE_ID,
          PLAN_TYPE_CODE,
          RAW_COST,
          BRDN_COST,
          REVENUE,
          BILL_RAW_COST,
          BILL_BRDN_COST,
          BILL_LABOR_RAW_COST,
          BILL_LABOR_BRDN_COST,
          BILL_LABOR_HRS,
          EQUIPMENT_RAW_COST,
          EQUIPMENT_BRDN_COST,
          CAPITALIZABLE_RAW_COST,
          CAPITALIZABLE_BRDN_COST,
          LABOR_RAW_COST,
          LABOR_BRDN_COST,
          LABOR_HRS,
          LABOR_REVENUE,
          EQUIPMENT_HOURS,
          BILLABLE_EQUIPMENT_HOURS,
          SUP_INV_COMMITTED_COST,
          PO_COMMITTED_COST,
          PR_COMMITTED_COST,
          OTH_COMMITTED_COST,
          ACT_LABOR_HRS,
          ACT_EQUIP_HRS,
          ACT_LABOR_BRDN_COST,
          ACT_EQUIP_BRDN_COST,
          ACT_BRDN_COST,
          ACT_RAW_COST,
          ACT_REVENUE,
          ACT_LABOR_RAW_COST,
          ACT_EQUIP_RAW_COST,
          ETC_LABOR_HRS,
          ETC_EQUIP_HRS,
          ETC_LABOR_BRDN_COST,
          ETC_EQUIP_BRDN_COST,
          ETC_BRDN_COST,
          ETC_RAW_COST,
          ETC_LABOR_RAW_COST,
          ETC_EQUIP_RAW_COST,
          CUSTOM1,
          CUSTOM2,
          CUSTOM3,
          CUSTOM4,
          CUSTOM5,
          CUSTOM6,
          CUSTOM7,
          CUSTOM8,
          CUSTOM9,
          CUSTOM10,
          CUSTOM11,
          CUSTOM12,
          CUSTOM13,
          CUSTOM14,
          CUSTOM15
        )
        select
          pjp1_i.WORKER_ID,
          pjp1_i.RECORD_TYPE,
          pjp1_i.PRG_LEVEL,
          pjp1_i.LINE_TYPE,
          pjp1_i.PROJECT_ID,
          pjp1_i.PROJECT_ORG_ID,
          pjp1_i.PROJECT_ORGANIZATION_ID,
          pjp1_i.PROJECT_ELEMENT_ID,
          pjp1_i.TIME_ID,
          pjp1_i.PERIOD_TYPE_ID,
          pjp1_i.CALENDAR_TYPE,
          pjp1_i.RBS_AGGR_LEVEL,
          pjp1_i.WBS_ROLLUP_FLAG,
          pjp1_i.PRG_ROLLUP_FLAG,
          pjp1_i.CURR_RECORD_TYPE_ID,
          pjp1_i.CURRENCY_CODE,
          pjp1_i.RBS_ELEMENT_ID,
          pjp1_i.RBS_VERSION_ID,
          pjp1_i.PLAN_VERSION_ID,
          pjp1_i.PLAN_TYPE_ID,
          pjp1_i.PLAN_TYPE_CODE,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.RAW_COST))                    RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.BRDN_COST))                   BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.REVENUE))                     REVENUE,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.BILL_RAW_COST))               BILL_RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.BILL_BRDN_COST))              BILL_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.BILL_LABOR_RAW_COST))         BILL_LABOR_RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.BILL_LABOR_BRDN_COST))        BILL_LABOR_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.BILL_LABOR_HRS))              BILL_LABOR_HRS,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.EQUIPMENT_RAW_COST))          EQUIPMENT_RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.EQUIPMENT_BRDN_COST))         EQUIPMENT_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.CAPITALIZABLE_RAW_COST))      CAPITALIZABLE_RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.CAPITALIZABLE_BRDN_COST))     CAPITALIZABLE_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.LABOR_RAW_COST))              LABOR_RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.LABOR_BRDN_COST))             LABOR_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.LABOR_HRS))                   LABOR_HRS,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.LABOR_REVENUE))               LABOR_REVENUE,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.EQUIPMENT_HOURS))             EQUIPMENT_HOURS,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.BILLABLE_EQUIPMENT_HOURS))    BILLABLE_EQUIPMENT_HOURS,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.SUP_INV_COMMITTED_COST))      SUP_INV_COMMITTED_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.PO_COMMITTED_COST))           PO_COMMITTED_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.PR_COMMITTED_COST))           PR_COMMITTED_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUB_STATUS_CODE
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y__', to_number(null),
                 decode(pjp1_i.RELATIONSHIP_TYPE
                          || '_' || pjp1_i.WBS_ROLLUP_FLAG
                          || '_' || pjp1_i.PRG_ROLLUP_FLAG
                          || '_' || pjp1_i.SUP_VER_ENABLED,
                        'LW_N_Y_Y', to_number(null),
                 pjp1_i.OTH_COMMITTED_COST))          OTH_COMMITTED_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ACT_LABOR_HRS)       ACT_LABOR_HRS,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ACT_EQUIP_HRS)       ACT_EQUIP_HRS,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ACT_LABOR_BRDN_COST) ACT_LABOR_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ACT_EQUIP_BRDN_COST) ACT_EQUIP_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ACT_BRDN_COST)       ACT_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ACT_RAW_COST)        ACT_RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ACT_REVENUE)         ACT_REVENUE,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ACT_LABOR_RAW_COST)  ACT_LABOR_RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ACT_EQUIP_RAW_COST)  ACT_EQUIP_RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ETC_LABOR_HRS)       ETC_LABOR_HRS,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ETC_EQUIP_HRS)       ETC_EQUIP_HRS,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ETC_LABOR_BRDN_COST) ETC_LABOR_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ETC_EQUIP_BRDN_COST) ETC_EQUIP_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ETC_BRDN_COST)       ETC_BRDN_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ETC_RAW_COST)        ETC_RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ETC_LABOR_RAW_COST)  ETC_LABOR_RAW_COST,
          decode(pjp1_i.RELATIONSHIP_TYPE
                   || '_' || pjp1_i.WBS_ROLLUP_FLAG
                   || '_' || pjp1_i.PRG_ROLLUP_FLAG
                   || '_' || pjp1_i.SUP_STATUS_CODE,
                 'LW_N_Y_', to_number(null),
                          pjp1_i.ETC_EQUIP_RAW_COST)  ETC_EQUIP_RAW_COST,
          pjp1_i.CUSTOM1,
          pjp1_i.CUSTOM2,
          pjp1_i.CUSTOM3,
          pjp1_i.CUSTOM4,
          pjp1_i.CUSTOM5,
          pjp1_i.CUSTOM6,
          pjp1_i.CUSTOM7,
          pjp1_i.CUSTOM8,
          pjp1_i.CUSTOM9,
          pjp1_i.CUSTOM10,
          pjp1_i.CUSTOM11,
          pjp1_i.CUSTOM12,
          pjp1_i.CUSTOM13,
          pjp1_i.CUSTOM14,
          pjp1_i.CUSTOM15
        from
          (
        select
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.INSERT_FLAG, 'Y')                INSERT_FLAG,
          pjp.RELATIONSHIP_TYPE,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, sub_ver.STATUS_CODE)           SUB_STATUS_CODE,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, sup_ver.STATUS_CODE)           SUP_STATUS_CODE,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, sup_wpa.WP_ENABLE_VERSION_FLAG)SUP_VER_ENABLED,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, decode(pjp.PLAN_VERSION_ID,
                              -1, prg.SUP_ID,
                              -3, prg.SUP_ID,
                              -4, prg.SUP_ID,
                                  null))              SUP_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, decode(pjp.PLAN_VERSION_ID,
                              -1, prg.SUP_EMT_ID,
                              -3, prg.SUP_EMT_ID,
                              -4, prg.SUP_EMT_ID,
                                  null))              SUP_EMT_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, decode(pjp.PLAN_VERSION_ID,
                              -1, prg.WP_FLAG,
                              -3, prg.WP_FLAG,
                              -4, prg.WP_FLAG,
                                  null))              SUP_WP_FLAG,
         -- 1                                           WORKER_ID,
           p_worker_id                              WORKER_ID,
          'W'                                         RECORD_TYPE,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 l_level, prg.SUP_LEVEL)              PRG_LEVEL,
          pjp.LINE_TYPE,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ID, prg.SUP_PROJECT_ID)  PROJECT_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ORG_ID,
                 prg.SUP_PROJECT_ORG_ID)              PROJECT_ORG_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ORGANIZATION_ID,
                 prg.SUP_PROJECT_ORGANIZATION_ID)     PROJECT_ORGANIZATION_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ELEMENT_ID,
                 prg.SUB_ROLLUP_ID)                   PROJECT_ELEMENT_ID,
          pjp.TIME_ID,
          pjp.PERIOD_TYPE_ID,
          pjp.CALENDAR_TYPE,
          pjp.RBS_AGGR_LEVEL,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.WBS_ROLLUP_FLAG, 'N')            WBS_ROLLUP_FLAG,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PRG_ROLLUP_FLAG, 'Y')            PRG_ROLLUP_FLAG,
          pjp.CURR_RECORD_TYPE_ID,
          pjp.CURRENCY_CODE,
          pjp.RBS_ELEMENT_ID,
          pjp.RBS_VERSION_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PLAN_VERSION_ID,
                 decode(pjp.PLAN_VERSION_ID,
                        -1, pjp.PLAN_VERSION_ID,
                        -2, pjp.PLAN_VERSION_ID,
                        -3, pjp.PLAN_VERSION_ID,
                        -4, pjp.PLAN_VERSION_ID,
                            wbs_hdr.PLAN_VERSION_ID)) PLAN_VERSION_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PLAN_TYPE_ID,
                 decode(pjp.PLAN_VERSION_ID,
                        -1, pjp.PLAN_TYPE_ID,
                        -2, pjp.PLAN_TYPE_ID,
                        -3, pjp.PLAN_TYPE_ID,
                        -4, pjp.PLAN_TYPE_ID,
                            wbs_hdr.PLAN_TYPE_ID))    PLAN_TYPE_ID,
          pjp.PLAN_TYPE_CODE,
          sum(pjp.RAW_COST)                           RAW_COST,
          sum(pjp.BRDN_COST)                          BRDN_COST,
          sum(pjp.REVENUE)                            REVENUE,
          sum(pjp.BILL_RAW_COST)                      BILL_RAW_COST,
          sum(pjp.BILL_BRDN_COST)                     BILL_BRDN_COST,
          sum(pjp.BILL_LABOR_RAW_COST)                BILL_LABOR_RAW_COST,
          sum(pjp.BILL_LABOR_BRDN_COST)               BILL_LABOR_BRDN_COST,
          sum(pjp.BILL_LABOR_HRS)                     BILL_LABOR_HRS,
          sum(pjp.EQUIPMENT_RAW_COST)                 EQUIPMENT_RAW_COST,
          sum(pjp.EQUIPMENT_BRDN_COST)                EQUIPMENT_BRDN_COST,
          sum(pjp.CAPITALIZABLE_RAW_COST)             CAPITALIZABLE_RAW_COST,
          sum(pjp.CAPITALIZABLE_BRDN_COST)            CAPITALIZABLE_BRDN_COST,
          sum(pjp.LABOR_RAW_COST)                     LABOR_RAW_COST,
          sum(pjp.LABOR_BRDN_COST)                    LABOR_BRDN_COST,
          sum(pjp.LABOR_HRS)                          LABOR_HRS,
          sum(pjp.LABOR_REVENUE)                      LABOR_REVENUE,
          sum(pjp.EQUIPMENT_HOURS)                    EQUIPMENT_HOURS,
          sum(pjp.BILLABLE_EQUIPMENT_HOURS)           BILLABLE_EQUIPMENT_HOURS,
          sum(pjp.SUP_INV_COMMITTED_COST)             SUP_INV_COMMITTED_COST,
          sum(pjp.PO_COMMITTED_COST)                  PO_COMMITTED_COST,
          sum(pjp.PR_COMMITTED_COST)                  PR_COMMITTED_COST,
          sum(pjp.OTH_COMMITTED_COST)                 OTH_COMMITTED_COST,
          sum(pjp.ACT_LABOR_HRS)                      ACT_LABOR_HRS,
          sum(pjp.ACT_EQUIP_HRS)                      ACT_EQUIP_HRS,
          sum(pjp.ACT_LABOR_BRDN_COST)                ACT_LABOR_BRDN_COST,
          sum(pjp.ACT_EQUIP_BRDN_COST)                ACT_EQUIP_BRDN_COST,
          sum(pjp.ACT_BRDN_COST)                      ACT_BRDN_COST,
          sum(pjp.ACT_RAW_COST)                       ACT_RAW_COST,
          sum(pjp.ACT_REVENUE)                        ACT_REVENUE,
          sum(pjp.ACT_LABOR_RAW_COST)                 ACT_LABOR_RAW_COST,
          sum(pjp.ACT_EQUIP_RAW_COST)                 ACT_EQUIP_RAW_COST,
          sum(pjp.ETC_LABOR_HRS)                      ETC_LABOR_HRS,
          sum(pjp.ETC_EQUIP_HRS)                      ETC_EQUIP_HRS,
          sum(pjp.ETC_LABOR_BRDN_COST)                ETC_LABOR_BRDN_COST,
          sum(pjp.ETC_EQUIP_BRDN_COST)                ETC_EQUIP_BRDN_COST,
          sum(pjp.ETC_BRDN_COST)                      ETC_BRDN_COST,
          sum(pjp.ETC_RAW_COST)                       ETC_RAW_COST,
          sum(pjp.ETC_LABOR_RAW_COST)                 ETC_LABOR_RAW_COST,
          sum(pjp.ETC_EQUIP_RAW_COST)                 ETC_EQUIP_RAW_COST,
          sum(pjp.CUSTOM1)                            CUSTOM1,
          sum(pjp.CUSTOM2)                            CUSTOM2,
          sum(pjp.CUSTOM3)                            CUSTOM3,
          sum(pjp.CUSTOM4)                            CUSTOM4,
          sum(pjp.CUSTOM5)                            CUSTOM5,
          sum(pjp.CUSTOM6)                            CUSTOM6,
          sum(pjp.CUSTOM7)                            CUSTOM7,
          sum(pjp.CUSTOM8)                            CUSTOM8,
          sum(pjp.CUSTOM9)                            CUSTOM9,
          sum(pjp.CUSTOM10)                           CUSTOM10,
          sum(pjp.CUSTOM11)                           CUSTOM11,
          sum(pjp.CUSTOM12)                           CUSTOM12,
          sum(pjp.CUSTOM13)                           CUSTOM13,
          sum(pjp.CUSTOM14)                           CUSTOM14,
          sum(pjp.CUSTOM15)                           CUSTOM15
        from
          (
          select /*+ ordered index(wbs PA_XBS_DENORM_N2) */
                 -- get incremental task level amounts from source and
                 -- program rollup amounts from interim
            to_char(null)                             LINE_TYPE,
            wbs_hdr.WBS_VERSION_ID,
            decode(wbs_hdr.WP_FLAG, 'Y', 'LW', 'LF')  RELATIONSHIP_TYPE,
            decode(wbs_hdr.WP_FLAG
                     || '_' || to_char(sign(pjp1.PLAN_VERSION_ID))
                     || '_' || nvl(fin_plan.INVERT_ID, 'PRJ'),
                   'N_1_PRJ', 'N',
                   'N_-1_PRG', 'N',
                   decode(top_slice.INVERT_ID,
                          'PRJ', 'Y',
                          decode(wbs.SUB_LEVEL,
                                 1, 'Y', 'N')))       PUSHUP_FLAG,
            decode(pjp1.RBS_AGGR_LEVEL,
                   'L', 'N',
                        decode(wbs_hdr.WP_FLAG
                                 || '_' || to_char(sign(pjp1.PLAN_VERSION_ID))
                                 || '_' || fin_plan.INVERT_ID,
                               'N_1_PRG', decode(top_slice.INVERT_ID,
                                                 'PRJ', 'Y',
                                                 decode(wbs.SUB_LEVEL,
                                                        1, 'Y', 'N')),
                               'N_-1_PRG', 'N',
                               decode(wbs_hdr.WP_FLAG
                                        || '_' || fin_plan.INVERT_ID
                                        || '_' || fin_plan.CB
                                        || '_' || fin_plan.CO
                                        || '_'
                                        || to_char(fin_plan.PLAN_VERSION_ID),
                                      'N_PRJ_Y_Y_-4', 'N',
                                                      'Y'))
                  )                                   INSERT_FLAG,
            pjp1.PROJECT_ID,
            pjp1.PROJECT_ORG_ID,
            pjp1.PROJECT_ORGANIZATION_ID,
            decode(top_slice.INVERT_ID,
                   'PRJ', prg.SUP_EMT_ID,
                          decode(wbs.SUB_LEVEL,
                                 1, prg.SUP_EMT_ID,
                                    wbs.SUP_EMT_ID))  PROJECT_ELEMENT_ID,
            pjp1.TIME_ID,
            pjp1.PERIOD_TYPE_ID,
            pjp1.CALENDAR_TYPE,
            pjp1.RBS_AGGR_LEVEL,
            'Y'                                       WBS_ROLLUP_FLAG,
            pjp1.PRG_ROLLUP_FLAG,
            pjp1.CURR_RECORD_TYPE_ID,
            pjp1.CURRENCY_CODE,
            pjp1.RBS_ELEMENT_ID,
            pjp1.RBS_VERSION_ID,
            decode(wbs_hdr.WP_FLAG || '_' || fin_plan.INVERT_ID,
                   'N_PRG', fin_plan.PLAN_VERSION_ID,
                            pjp1.PLAN_VERSION_ID)     PLAN_VERSION_ID,
            pjp1.PLAN_TYPE_ID,
            pjp1.PLAN_TYPE_CODE,
            pjp1.RAW_COST,
            pjp1.BRDN_COST,
            pjp1.REVENUE,
            pjp1.BILL_RAW_COST,
            pjp1.BILL_BRDN_COST,
            pjp1.BILL_LABOR_RAW_COST,
            pjp1.BILL_LABOR_BRDN_COST,
            pjp1.BILL_LABOR_HRS,
            pjp1.EQUIPMENT_RAW_COST,
            pjp1.EQUIPMENT_BRDN_COST,
            pjp1.CAPITALIZABLE_RAW_COST,
            pjp1.CAPITALIZABLE_BRDN_COST,
            pjp1.LABOR_RAW_COST,
            pjp1.LABOR_BRDN_COST,
            pjp1.LABOR_HRS,
            pjp1.LABOR_REVENUE,
            pjp1.EQUIPMENT_HOURS,
            pjp1.BILLABLE_EQUIPMENT_HOURS,
            pjp1.SUP_INV_COMMITTED_COST,
            pjp1.PO_COMMITTED_COST,
            pjp1.PR_COMMITTED_COST,
            pjp1.OTH_COMMITTED_COST,
            pjp1.ACT_LABOR_HRS,
            pjp1.ACT_EQUIP_HRS,
            pjp1.ACT_LABOR_BRDN_COST,
            pjp1.ACT_EQUIP_BRDN_COST,
            pjp1.ACT_BRDN_COST,
            pjp1.ACT_RAW_COST,
            pjp1.ACT_REVENUE,
            pjp1.ACT_LABOR_RAW_COST,
            pjp1.ACT_EQUIP_RAW_COST,
            pjp1.ETC_LABOR_HRS,
            pjp1.ETC_EQUIP_HRS,
            pjp1.ETC_LABOR_BRDN_COST,
            pjp1.ETC_EQUIP_BRDN_COST,
            pjp1.ETC_BRDN_COST,
            pjp1.ETC_RAW_COST,
            pjp1.ETC_LABOR_RAW_COST,
            pjp1.ETC_EQUIP_RAW_COST,
            pjp1.CUSTOM1,
            pjp1.CUSTOM2,
            pjp1.CUSTOM3,
            pjp1.CUSTOM4,
            pjp1.CUSTOM5,
            pjp1.CUSTOM6,
            pjp1.CUSTOM7,
            pjp1.CUSTOM8,
            pjp1.CUSTOM9,
            pjp1.CUSTOM10,
            pjp1.CUSTOM11,
            pjp1.CUSTOM12,
            pjp1.CUSTOM13,
            pjp1.CUSTOM14,
            pjp1.CUSTOM15
          from
            PJI_FP_AGGR_PJP1 pjp1,
            PJI_PJP_WBS_HEADER wbs_hdr,
            PA_XBS_DENORM      wbs,
            PJI_XBS_DENORM     prg,
            (
              select 'Y' CB, 'N' CO, -3 PLAN_VERSION_ID, 'PRG' INVERT_ID
              from DUAL union all
              select 'Y' CB, 'N' CO, -3 PLAN_VERSION_ID, 'PRJ' INVERT_ID
              from DUAL union all
              select 'N' CB, 'Y' CO, -4 PLAN_VERSION_ID, 'PRG' INVERT_ID
              from DUAL union all
              select 'N' CB, 'Y' CO, -4 PLAN_VERSION_ID, 'PRJ' INVERT_ID
              from DUAL union all
              select 'Y' CB, 'Y' CO, -3 PLAN_VERSION_ID, 'PRG' INVERT_ID
              from DUAL union all
              select 'Y' CB, 'Y' CO, -3 PLAN_VERSION_ID, 'PRJ' INVERT_ID
              from DUAL union all
              select 'Y' CB, 'Y' CO, -4 PLAN_VERSION_ID, 'PRG' INVERT_ID
              from DUAL union all
              select 'Y' CB, 'Y' CO, -4 PLAN_VERSION_ID, 'PRJ' INVERT_ID
              from DUAL
            ) fin_plan,
            (
              select 1     WBS_SUP_LEVEL,
                     1     WBS_SUB_LEVEL,
                     'PRJ' INVERT_ID
              from   DUAL
              union all
              select 1     WBS_SUP_LEVEL,
                     1     WBS_SUB_LEVEL,
                     'WBS' INVERT_ID
              from   DUAL
            ) top_slice
          where
            prg.STRUCT_TYPE         =  'PRG'                       and
            prg.SUP_LEVEL           =  l_level                     and
            prg.SUB_LEVEL           =  l_level                     and
            wbs.STRUCT_TYPE         =  'WBS'                       and
            ((wbs.SUP_LEVEL = 1 and
              wbs.SUB_LEVEL = 1) or
             (wbs.SUP_LEVEL <> wbs.SUB_LEVEL))                     and
            wbs.STRUCT_VERSION_ID   =  prg.SUP_ID                  and
            wbs.SUP_PROJECT_ID      =  prg.SUP_PROJECT_ID          and
            pjp1.WORKER_ID       =  p_worker_id                 and
            pjp1.PRG_LEVEL          in (0, l_level)                and
            pjp1.RBS_AGGR_LEVEL     in ('T', 'L')                  and
            pjp1.WBS_ROLLUP_FLAG    =  'N'                         and
            pjp1.PRG_ROLLUP_FLAG    in ('Y', 'N')                  and
            pjp1.PROJECT_ID         =  wbs_hdr.PROJECT_ID          and
            pjp1.PLAN_VERSION_ID    =  wbs_hdr.PLAN_VERSION_ID     and
            pjp1.PLAN_TYPE_CODE     =  wbs_hdr.PLAN_TYPE_CODE      and
            decode(pjp1.PLAN_VERSION_ID,
                   -3, pjp1.PLAN_TYPE_ID,
                   -4, pjp1.PLAN_TYPE_ID,
                       -1)          =  decode(pjp1.PLAN_VERSION_ID,
                                              -3, wbs_hdr.PLAN_TYPE_ID,
                                              -4, wbs_hdr.PLAN_TYPE_ID,
                                                  -1)              and
            wbs.STRUCT_VERSION_ID   =  wbs_hdr.WBS_VERSION_ID      and
            pjp1.PROJECT_ELEMENT_ID =  wbs.SUB_EMT_ID              and
            wbs_hdr.CB_FLAG         =  fin_plan.CB             (+) and
            wbs_hdr.CO_FLAG         =  fin_plan.CO             (+) and
            wbs.SUP_LEVEL           =  top_slice.WBS_SUP_LEVEL (+) and
            wbs.SUB_LEVEL           <> top_slice.WBS_SUB_LEVEL (+)
          union all
          select /*+ ordered */
                 -- get incremental project level amounts from source
            to_char(null)                             LINE_TYPE,
            wbs_hdr.WBS_VERSION_ID,
            decode(wbs_hdr.WP_FLAG, 'Y', 'LW', 'LF')  RELATIONSHIP_TYPE,
            'Y'                                       PUSHUP_FLAG,
            decode(pjp1.RBS_AGGR_LEVEL,
                   'L', 'N',
                        decode(fin_plan.PLAN_VERSION_ID,
                               null, 'N', 'Y'))       INSERT_FLAG,
            pjp1.PROJECT_ID,
            pjp1.PROJECT_ORG_ID,
            pjp1.PROJECT_ORGANIZATION_ID,
            pjp1.PROJECT_ELEMENT_ID,
            pjp1.TIME_ID,
            pjp1.PERIOD_TYPE_ID,
            pjp1.CALENDAR_TYPE,
            pjp1.RBS_AGGR_LEVEL,
            'Y'                                       WBS_ROLLUP_FLAG,
            pjp1.PRG_ROLLUP_FLAG,
            pjp1.CURR_RECORD_TYPE_ID,
            pjp1.CURRENCY_CODE,
            pjp1.RBS_ELEMENT_ID,
            pjp1.RBS_VERSION_ID,
            decode(wbs_hdr.WP_FLAG,
                   'N', decode(pjp1.PLAN_VERSION_ID,
                               -1, pjp1.PLAN_VERSION_ID,
                               -2, pjp1.PLAN_VERSION_ID,
                               -3, pjp1.PLAN_VERSION_ID, -- won't exist
                               -4, pjp1.PLAN_VERSION_ID, -- won't exist
                                   fin_plan.PLAN_VERSION_ID),
                        pjp1.PLAN_VERSION_ID)         PLAN_VERSION_ID,
            pjp1.PLAN_TYPE_ID,
            pjp1.PLAN_TYPE_CODE,
            pjp1.RAW_COST,
            pjp1.BRDN_COST,
            pjp1.REVENUE,
            pjp1.BILL_RAW_COST,
            pjp1.BILL_BRDN_COST,
            pjp1.BILL_LABOR_RAW_COST,
            pjp1.BILL_LABOR_BRDN_COST,
            pjp1.BILL_LABOR_HRS,
            pjp1.EQUIPMENT_RAW_COST,
            pjp1.EQUIPMENT_BRDN_COST,
            pjp1.CAPITALIZABLE_RAW_COST,
            pjp1.CAPITALIZABLE_BRDN_COST,
            pjp1.LABOR_RAW_COST,
            pjp1.LABOR_BRDN_COST,
            pjp1.LABOR_HRS,
            pjp1.LABOR_REVENUE,
            pjp1.EQUIPMENT_HOURS,
            pjp1.BILLABLE_EQUIPMENT_HOURS,
            pjp1.SUP_INV_COMMITTED_COST,
            pjp1.PO_COMMITTED_COST,
            pjp1.PR_COMMITTED_COST,
            pjp1.OTH_COMMITTED_COST,
            pjp1.ACT_LABOR_HRS,
            pjp1.ACT_EQUIP_HRS,
            pjp1.ACT_LABOR_BRDN_COST,
            pjp1.ACT_EQUIP_BRDN_COST,
            pjp1.ACT_BRDN_COST,
            pjp1.ACT_RAW_COST,
            pjp1.ACT_REVENUE,
            pjp1.ACT_LABOR_RAW_COST,
            pjp1.ACT_EQUIP_RAW_COST,
            pjp1.ETC_LABOR_HRS,
            pjp1.ETC_EQUIP_HRS,
            pjp1.ETC_LABOR_BRDN_COST,
            pjp1.ETC_EQUIP_BRDN_COST,
            pjp1.ETC_BRDN_COST,
            pjp1.ETC_RAW_COST,
            pjp1.ETC_LABOR_RAW_COST,
            pjp1.ETC_EQUIP_RAW_COST,
            pjp1.CUSTOM1,
            pjp1.CUSTOM2,
            pjp1.CUSTOM3,
            pjp1.CUSTOM4,
            pjp1.CUSTOM5,
            pjp1.CUSTOM6,
            pjp1.CUSTOM7,
            pjp1.CUSTOM8,
            pjp1.CUSTOM9,
            pjp1.CUSTOM10,
            pjp1.CUSTOM11,
            pjp1.CUSTOM12,
            pjp1.CUSTOM13,
            pjp1.CUSTOM14,
            pjp1.CUSTOM15
          from
            PJI_FP_AGGR_PJP1 pjp1,
            PJI_PJP_WBS_HEADER wbs_hdr,
            PJI_XBS_DENORM     prg,
            (
              select 'Y' CB_FLAG,
                     'N' CO_FLAG,
                     -3  PLAN_VERSION_ID
              from DUAL union all
              select 'N' CB_FLAG,
                     'Y' CO_FLAG,
                     -4  PLAN_VERSION_ID
              from DUAL union all
              select 'Y' CB_FLAG,
                     'Y' CO_FLAG,
                     -3  PLAN_VERSION_ID
              from DUAL union all
              select 'Y' CB_FLAG,
                     'Y' CO_FLAG,
                     -4  PLAN_VERSION_ID
              from DUAL
            ) fin_plan
          where
            prg.STRUCT_TYPE         = 'PRG'                    and
            prg.SUP_LEVEL           = l_level                  and
            prg.SUB_LEVEL           = l_level                  and
            pjp1.WORKER_ID       = p_worker_id              and
            pjp1.PROJECT_ID         = prg.SUP_PROJECT_ID       and
            pjp1.PROJECT_ELEMENT_ID = prg.SUP_EMT_ID           and
            pjp1.PRG_LEVEL          = 0                        and
            pjp1.RBS_AGGR_LEVEL     in ('T', 'L')              and
            pjp1.WBS_ROLLUP_FLAG    = 'N'                      and
            pjp1.PRG_ROLLUP_FLAG    = 'N'                      and
            wbs_hdr.PROJECT_ID      = pjp1.PROJECT_ID          and
            wbs_hdr.PLAN_VERSION_ID = pjp1.PLAN_VERSION_ID     and
            wbs_hdr.PLAN_TYPE_CODE  = pjp1.PLAN_TYPE_CODE      and
            decode(wbs_hdr.WP_FLAG,
                   'N', decode(pjp1.PLAN_VERSION_ID,
                               -1, 'Y',
                               -2, 'Y',
                               -3, 'Y', -- won't exist
                               -4, 'Y', -- won't exist
                                   decode(wbs_hdr.CB_FLAG || '_' ||
                                          wbs_hdr.CO_FLAG,
                                          'Y_Y', 'Y',
                                          'N_Y', 'Y',
                                          'Y_N', 'Y',
                                                 'N')),
                        'Y')        =  'Y'                     and
            wbs_hdr.WBS_VERSION_ID  = prg.SUP_ID               and
            wbs_hdr.CB_FLAG         = fin_plan.CB_FLAG     (+) and
            wbs_hdr.CO_FLAG         = fin_plan.CO_FLAG     (+)
          ) pjp,
          (
          select /*+ index(prg PJI_XBS_DENORM_N3)
                     index(map PA_PROJECTS_U1) */
            prg.SUP_PROJECT_ID,
            map.ORG_ID                       SUP_PROJECT_ORG_ID,
            map.CARRYING_OUT_ORGANIZATION_ID SUP_PROJECT_ORGANIZATION_ID,
            prg.SUP_ID,
            prg.SUP_EMT_ID,
            prg.SUP_LEVEL,
            prg.SUB_ID,
            prg.SUB_EMT_ID,
            prg.SUB_ROLLUP_ID,
            invert.INVERT_VALUE              RELATIONSHIP_TYPE,
            decode(prg.RELATIONSHIP_TYPE,
                   'LW', 'Y',
                   'LF', 'N')                WP_FLAG,
            'Y'                              PUSHUP_FLAG
          from
            PJI_XBS_DENORM prg,
            PA_PROJECTS_ALL map,
            (
              select 'LF' INVERT_ID, 'LF' INVERT_VALUE from dual union all
              select 'LW' INVERT_ID, 'LW' INVERT_VALUE from dual union all
              select 'A'  INVERT_ID, 'LF' INVERT_VALUE from dual union all
              select 'A'  INVERT_ID, 'LW' INVERT_VALUE from dual
            ) invert
          where
            prg.STRUCT_TYPE               = 'PRG'              and
            prg.SUB_ROLLUP_ID             is not null          and
            prg.SUB_LEVEL                 = l_level            and
            -- map.WORKER_ID              = p_worker_id        and
            map.PROJECT_ID                = prg.SUP_PROJECT_ID and
            decode(prg.SUB_LEVEL,
                   prg.SUP_LEVEL, 'A',
                   prg.RELATIONSHIP_TYPE) = invert.INVERT_ID
          )                          prg,
          PJI_PJP_WBS_HEADER         wbs_hdr,
          PA_PROJ_ELEM_VER_STRUCTURE sub_ver,
          PA_PROJ_ELEM_VER_STRUCTURE sup_ver,
          PA_PROJ_WORKPLAN_ATTR      sup_wpa
        where
          pjp.PROJECT_ID         = sub_ver.PROJECT_ID                (+) and
          pjp.WBS_VERSION_ID     = sub_ver.ELEMENT_VERSION_ID        (+) and
          'STRUCTURE_PUBLISHED'  = sub_ver.STATUS_CODE               (+) and
          pjp.WBS_VERSION_ID     = prg.SUB_ID                        (+) and
          pjp.RELATIONSHIP_TYPE  = prg.RELATIONSHIP_TYPE             (+) and
          pjp.PUSHUP_FLAG        = prg.PUSHUP_FLAG                   (+) and
          prg.SUP_PROJECT_ID     = wbs_hdr.PROJECT_ID                (+) and
          prg.SUP_ID             = wbs_hdr.WBS_VERSION_ID            (+) and
          prg.WP_FLAG            = wbs_hdr.WP_FLAG                   (+) and
          'Y'                    = wbs_hdr.WP_FLAG                   (+) and
          wbs_hdr.PROJECT_ID     = sup_ver.PROJECT_ID                (+) and
          wbs_hdr.WBS_VERSION_ID = sup_ver.ELEMENT_VERSION_ID        (+) and
          'STRUCTURE_PUBLISHED'  = sup_ver.STATUS_CODE               (+) and
          'Y'                    = sup_ver.LATEST_EFF_PUBLISHED_FLAG (+) and
          prg.SUP_EMT_ID         = sup_wpa.PROJ_ELEMENT_ID           (+)
        group by
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.INSERT_FLAG, 'Y'),
          pjp.RELATIONSHIP_TYPE,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, sub_ver.STATUS_CODE),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, sup_ver.STATUS_CODE),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, sup_wpa.WP_ENABLE_VERSION_FLAG),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, decode(pjp.PLAN_VERSION_ID,
                              -1, prg.SUP_ID,
                              -3, prg.SUP_ID,
                              -4, prg.SUP_ID,
                                  null)),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, decode(pjp.PLAN_VERSION_ID,
                              -1, prg.SUP_EMT_ID,
                              -3, prg.SUP_EMT_ID,
                              -4, prg.SUP_EMT_ID,
                                  null)),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 null, decode(pjp.PLAN_VERSION_ID,
                              -1, prg.WP_FLAG,
                              -3, prg.WP_FLAG,
                              -4, prg.WP_FLAG,
                                  null)),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 l_level, prg.SUP_LEVEL),
          pjp.LINE_TYPE,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ID, prg.SUP_PROJECT_ID),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ORG_ID,
                 prg.SUP_PROJECT_ORG_ID),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ORGANIZATION_ID,
                 prg.SUP_PROJECT_ORGANIZATION_ID),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PROJECT_ELEMENT_ID,
                 prg.SUB_ROLLUP_ID),
          pjp.TIME_ID,
          pjp.PERIOD_TYPE_ID,
          pjp.CALENDAR_TYPE,
          pjp.RBS_AGGR_LEVEL,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.WBS_ROLLUP_FLAG, 'N'),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PRG_ROLLUP_FLAG, 'Y'),
          pjp.CURR_RECORD_TYPE_ID,
          pjp.CURRENCY_CODE,
          pjp.RBS_ELEMENT_ID,
          pjp.RBS_VERSION_ID,
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PLAN_VERSION_ID,
                 decode(pjp.PLAN_VERSION_ID,
                        -1, pjp.PLAN_VERSION_ID,
                        -2, pjp.PLAN_VERSION_ID,
                        -3, pjp.PLAN_VERSION_ID,
                        -4, pjp.PLAN_VERSION_ID,
                            wbs_hdr.PLAN_VERSION_ID)),
          decode(nvl(prg.SUB_EMT_ID, -1), nvl(prg.SUB_ROLLUP_ID, -1),
                 pjp.PLAN_TYPE_ID,
                 decode(pjp.PLAN_VERSION_ID,
                        -1, pjp.PLAN_TYPE_ID,
                        -2, pjp.PLAN_TYPE_ID,
                        -3, pjp.PLAN_TYPE_ID,
                        -4, pjp.PLAN_TYPE_ID,
                            wbs_hdr.PLAN_TYPE_ID)),
          pjp.PLAN_TYPE_CODE
          )                          pjp1_i,
          PA_PROJ_ELEM_VER_STRUCTURE sup_fin_ver,
          PA_PROJ_WORKPLAN_ATTR      sup_wpa
        where
          pjp1_i.INSERT_FLAG  = 'Y'                                and
          pjp1_i.PROJECT_ID   = sup_fin_ver.PROJECT_ID         (+) and
          pjp1_i.SUP_ID       = sup_fin_ver.ELEMENT_VERSION_ID (+) and
          'STRUCTURE_WORKING' = sup_fin_ver.STATUS_CODE        (+) and
          pjp1_i.SUP_EMT_ID   = sup_wpa.PROJ_ELEMENT_ID        (+) and
          'N'                 = sup_wpa.WP_ENABLE_VERSION_FLAG (+) and
          (pjp1_i.SUP_ID is null or
           (pjp1_i.SUP_ID is not null and
            (sup_fin_ver.PROJECT_ID is not null or
             sup_wpa.PROJ_ELEMENT_ID is not null)));

      end loop;


--     pji_utils.write2log('After Rollup_fpr_wbs');

--below call is required for updating
--the date columns on the wbs header

  UPDATE /*+ index(whdr,PJI_PJP_WBS_HEADER_N1) */
         PJI_PJP_WBS_HEADER whdr
  SET ( MIN_TXN_DATE
      , MAX_TXN_DATE
      , LAST_UPDATE_DATE
      , LAST_UPDATED_BY
      , LAST_UPDATE_LOGIN
      ) = (
  SELECT MIN(LEAST(cal.start_date,  NVL(whdr.min_txn_date, cal.start_date))) start_date
       , MAX(GREATEST(cal.end_date, NVL(whdr.max_txn_date, cal.end_date))) end_date
       , l_last_update_date
       , l_last_updated_by
       , l_last_update_login
    FROM PJI_FP_AGGR_PJP1    pjp1
       , pji_time_cal_period_v   cal
   WHERE
         pjp1.worker_id = p_worker_id
     AND pjp1.plan_version_id = whdr.plan_version_id
     AND pjp1.project_id = whdr.project_id
     AND pjp1.plan_type_id = whdr.plan_type_id
     AND pjp1.time_id = cal.cal_period_id
     AND pjp1.calendar_type IN ('P', 'G') -- Non time ph and ent cals don't need to be considered.
                                      )
 WHERE exists (select 1 from  pji_fp_aggr_pjp1 ver where worker_id = p_worker_id
               and ver.project_id = whdr.project_id
               and ver.plan_version_id = whdr.plan_version_id
               and ver.plan_type_id = whdr.plan_type_id);

  --  pji_utils.write2log('Updated records in wbs_header'||sql%rowcount);


  INSERT INTO pji_fp_xbs_accum_f  fact
  (
       PROJECT_ID
     , PROJECT_ORG_ID
     , PROJECT_ORGANIZATION_ID
     , PROJECT_ELEMENT_ID
     , TIME_ID
     , PERIOD_TYPE_ID
     , CALENDAR_TYPE
     , RBS_AGGR_LEVEL
     , WBS_ROLLUP_FLAG
     , PRG_ROLLUP_FLAG
     , CURR_RECORD_TYPE_ID
     , CURRENCY_CODE
     , RBS_ELEMENT_ID
     , RBS_VERSION_ID
     , PLAN_VERSION_ID
     , PLAN_TYPE_ID
     , LAST_UPDATE_DATE
     , LAST_UPDATED_BY
     , CREATION_DATE
     , CREATED_BY
     , LAST_UPDATE_LOGIN
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , ETC_LABOR_HRS
	   , ETC_EQUIP_HRS
	   , ETC_LABOR_BRDN_COST
	   , ETC_EQUIP_BRDN_COST
	   , ETC_BRDN_COST
         , ETC_RAW_COST
         , ETC_LABOR_RAW_COST
         , ETC_EQUIP_RAW_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , PLAN_TYPE_CODE
  )
  (
  SELECT
       tmp.PROJECT_ID
     , tmp.PROJECT_ORG_ID
     , tmp.PROJECT_ORGANIZATION_ID
     , tmp.PROJECT_ELEMENT_ID
     , tmp.TIME_ID
     , tmp.PERIOD_TYPE_ID
     , tmp.CALENDAR_TYPE
     , tmp.RBS_AGGR_LEVEL
     , tmp.WBS_ROLLUP_FLAG
     , tmp.PRG_ROLLUP_FLAG
     , tmp.CURR_RECORD_TYPE_ID
     , tmp.CURRENCY_CODE
     , tmp.RBS_ELEMENT_ID
     , tmp.RBS_VERSION_ID
     , ver3.PLAN_VERSION_ID
     , tmp.PLAN_TYPE_ID
     , l_last_update_date
     , l_last_updated_by
     , l_creation_date
     , l_created_by
     , l_last_update_login
     , RAW_COST
     , BRDN_COST
     , REVENUE
     , BILL_RAW_COST
     , BILL_BRDN_COST
     , BILL_LABOR_RAW_COST
     , BILL_LABOR_BRDN_COST
     , BILL_LABOR_HRS
     , EQUIPMENT_RAW_COST
     , EQUIPMENT_BRDN_COST
     , CAPITALIZABLE_RAW_COST
     , CAPITALIZABLE_BRDN_COST
     , LABOR_RAW_COST
     , LABOR_BRDN_COST
     , LABOR_HRS
     , LABOR_REVENUE
     , EQUIPMENT_HOURS
     , BILLABLE_EQUIPMENT_HOURS
     , SUP_INV_COMMITTED_COST
     , PO_COMMITTED_COST
     , PR_COMMITTED_COST
     , OTH_COMMITTED_COST
       , ACT_LABOR_HRS
	   , ACT_EQUIP_HRS
	   , ACT_LABOR_BRDN_COST
	   , ACT_EQUIP_BRDN_COST
	   , ACT_BRDN_COST
	   , ACT_RAW_COST
	   , ACT_REVENUE
         , ACT_LABOR_RAW_COST
         , ACT_EQUIP_RAW_COST
	   , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_LABOR_HRS)  -- For Workplan
	                         , NULL
                             , NVL(tmp.labor_hrs, 0)
                             , NVL(tmp.ETC_LABOR_HRS, 0)
                              )
				      , NVL(tmp.ETC_LABOR_HRS, 0)
		       ) ETC_LABOR_HRS
		 , DECODE ( ver3.wp_flag
                          , 'Y'
                          , DECODE(TO_CHAR(tmp.ETC_EQUIP_HRS)
		                         , NULL
                                 , NVL(tmp.EQUIPMENT_hours, 0)
					             , NVL(tmp.ETC_EQUIP_HRS, 0)
					    )
			       , NVL(tmp.ETC_EQUIP_HRS, 0)
			    ) ETC_EQUIP_HRS
		 , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_LABOR_BRDN_COST)
		                     , NULL
                             , NVL(tmp.labor_BRDN_COST, 0)
				             , NVL(tmp.ETC_LABOR_BRDN_COST, 0)
					 )
			         , NVL(tmp.ETC_LABOR_BRDN_COST, 0)
			   ) ETC_LABOR_BRDN_COST
		 , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_EQUIP_BRDN_COST)
		                     , NULL
                             , NVL(tmp.EQUIPment_BRDN_COST, 0)
	                         , NVL(tmp.ETC_equip_BRDN_COST, 0)
				      )
			          , NVL(tmp.ETC_EQUIP_BRDN_COST, 0)
				  ) ETC_equip_BRDN_COST
		 , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_BRDN_COST)
		                     , NULL
                             , NVL(tmp.BRDN_COST, 0)
				             , NVL(tmp.ETC_BRDN_COST, 0)
				      )
			        , NVL(tmp.ETC_BRDN_COST, 0)
				  ) ETC_BRDN_COST
		 , DECODE ( ver3.wp_flag
                     , 'Y'
                     , DECODE(TO_CHAR(tmp.ETC_raw_COST)
		                    , NULL
                            , NVL(tmp.raw_COST, 0)
				            , NVL(tmp.ETC_raw_COST, 0)
				     )
			       , NVL(tmp.ETC_raw_COST, 0)
				  ) ETC_raw_COST
		 , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_labor_raw_COST)
		                     , NULL
                             , NVL(tmp.labor_raw_COST, 0)
				             , NVL(tmp.ETC_labor_raw_COST, 0)
			  	      )
			        , NVL(tmp.ETC_labor_raw_COST, 0)
				  ) ETC_labor_raw_COST
		 , DECODE ( ver3.wp_flag
                      , 'Y'
                      , DECODE(TO_CHAR(tmp.ETC_equip_raw_COST)
		                     , NULL
                             , NVL(tmp.equipment_raw_COST, 0)
                             ,  NVL(tmp.ETC_equip_raw_COST, 0)
				      )
			        , NVL(tmp.ETC_equip_raw_COST, 0)
			    ) ETC_equip_raw_COST
     , CUSTOM1
     , CUSTOM2
     , CUSTOM3
     , CUSTOM4
     , CUSTOM5
     , CUSTOM6
     , CUSTOM7
     , CUSTOM8
     , CUSTOM9
     , CUSTOM10
     , CUSTOM11
     , CUSTOM12
     , CUSTOM13
     , CUSTOM14
     , CUSTOM15
     , tmp.plan_type_code
  FROM pji_fp_aggr_pjp1 tmp
     , pji_pjp_wbs_header ver3
  WHERE 1 = 1
    AND ver3.plan_version_id = tmp.plan_version_id
   AND ver3.plan_type_code = tmp.plan_type_code    /* 4471527 */
   AND tmp.project_id = ver3.project_id -- use index.
   AND tmp.plan_type_id = NVL(ver3.plan_type_id, -1)
   AND tmp.plan_version_id in (-3, -4)
   AND tmp.worker_id = p_worker_id
  );

 --  pji_utils.write2log('Inserted records into fact'||sql%rowcount);

DELETE pa_pji_proj_events_log log
where log.event_type = 'PLANTYPE_UPG'
and exists (select 1  from pji_fm_extr_plnver4 ver
            where ver.worker_id = p_worker_id and
             to_char(ver.project_id) = log.event_object);


--pji_utils.write2log('Deleted records from pa_pji_proj_events_log'||sql%rowcount);

DELETE FROM pji_fm_extr_plnver4 where worker_id = p_worker_id;

--pji_utils.write2log('Deleted records from pji_fm_extr_plnver4'||sql%rowcount);

DELETE FROM pji_fp_aggr_pjp1 where worker_id = p_worker_id;

--pji_utils.write2log('Deleted records from pji_fp_aggr_pjp1'||sql%rowcount);

end if;

Begin
    select 1 into l_count from dual
    where exists ( select event_type
    from PA_PJI_PROJ_EVENTS_LOG elog
    where elog.event_type = 'PLANTYPE_UPG');
exception when NO_DATA_FOUND then
           PJI_UTILS.SET_PARAMETER ('PJI_PTC_UPGRADE', 'C');
end;

--dbms_output.put_line('Script end time..'||to_char(sysdate,'MM/DD/YYYY HH:MI:SS'));
  /* End of processing for all -3,-4 plans with plan_type=COST_AND_REV_SEP */
COMMIT;

End;

  -- -----------------------------------------------------
  -- procedure INIT_PROCESS
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure INIT_PROCESS(
    p_worker_id               in out nocopy number,
    p_run_mode                in            varchar2,
    p_operating_unit          in            number   default null,
    p_project_type            in            varchar2 default null,
    p_project_organization_id in            number   default null,
    p_from_project            in            varchar2 default null,
    p_to_project              in            varchar2 default null,
    p_plan_type_id            in            number   default null,
    p_rbs_header_id           in            number   default null,
    p_only_pt_projects_flag   in            varchar2 default null,
    p_transaction_type    in		 varchar2 default null,	 --  Bug#5099574 - New parameter for Partial Refresh
    p_plan_versions     in		varchar2 default null,	--  Bug#5099574 - New parameter for Partial Refresh
    p_project_status          in        varchar2  default null  -- 12.1.3
    ) is

    cursor lock_headers (p_worker_id in number) is
    select
      wbs_hdr.ROWID HDR_ROWID
    from
      PJI_PJP_PROJ_BATCH_MAP map,
      PJI_PJP_WBS_HEADER wbs_hdr
    where
      map.WORKER_ID           = p_worker_id    and
      wbs_hdr.PROJECT_ID      = map.PROJECT_ID and
      wbs_hdr.PLAN_VERSION_ID = -1
    for update;

    l_process                  varchar2(30);
    l_extraction_type          varchar2(30);

    l_preload                  varchar2(30);

    l_settings_proj_perf_flag  varchar2(1);
    l_type                     number;
    l_worker_id                number;
    l_incomplete_partial_count number;
    l_failed_process_count     number;
    l_count                    number;
    l_rbs_version_id           number := null;

    l_from_project_num         varchar2(25);
    l_to_project_num           varchar2(25);
    l_project_num              varchar2(25);
    p_from_project_id          number  ;
    p_to_project_id            number  ;
    l_newline                  varchar2(10) := '
';
    l_refresh_code   number := null;   --  Bug#5099574 - New parameter for Partial Refresh
    l_prg_exists varchar2(25);
    l_rbs_exists varchar2(1):='N' ;
    l_existing_worker varchar2(1);
    request_id_table SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
    prog_name_table SYSTEM.pa_varchar2_240_tbl_type := SYSTEM.pa_varchar2_240_tbl_type();
    l_prg_group_flag varchar2(1) := 'Y';  /* Added for bug 7551819 */

  begin


    if (PJI_UTILS.GET_PARAMETER('PJI_FPM_UPGRADE') = 'P') then
      FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_FPM_UPG_RUN');
      dbms_standard.raise_application_error(-20010, FND_MESSAGE.GET);
    end if;
      /*Check for  from project and to project based on the run , idea is to recreate the same check which was done thru mandatory parameter*/
    if (p_operating_unit is null and p_project_type is null and p_project_organization_id is null and
        p_from_project is null and p_to_project is null and p_run_mode <> 'R') then
         FND_MESSAGE.SET_NAME('PJI', 'PJI_NO_PARAMETER');
         dbms_standard.raise_application_error(-20090, FND_MESSAGE.GET);
    end if;


    if p_from_project > p_to_project then
         FND_MESSAGE.SET_NAME('PJI', 'PJI_INVALID_RANGE');
         dbms_standard.raise_application_error(-20091, FND_MESSAGE.GET);
    end if;

      IF  p_from_project is not null
    or  p_to_project is not null then
        select min(segment1) ,max(segment1)
        into l_from_project_num, l_to_project_num
        from pa_projects_all
        where segment1 between nvl(p_from_project,segment1) and nvl(p_to_project,segment1);
     END if;
        /* Get the Project Ids ,this is required to keep the impact minimum , these values will be updated in pji_system_parameters Table */
     IF l_from_project_num is not null and p_from_project is not null THEN
        select project_id
        into p_from_project_id
        from pa_projects_all
        where segment1= l_from_project_num;
      else
        p_from_project_id:=-1;
      END IF;
      IF l_to_project_num is not null and p_to_project is not null THEN
        select project_id
        into p_to_project_id
        from pa_projects_all
        where segment1= l_to_project_num;
      else
        p_to_project_id:=-1;
      END IF;

    select
      nvl(CONFIG_PROJ_PERF_FLAG, 'N')
    into
      l_settings_proj_perf_flag
    from
      PJI_SYSTEM_SETTINGS;

    if (l_settings_proj_perf_flag = 'N') then
      FND_MESSAGE.SET_NAME('PJI', 'PJI_PJP_NOT_ENABLED');
      dbms_standard.raise_application_error(-20010, FND_MESSAGE.GET);
    end if;

    lock table PJI_PJP_PROJ_BATCH_MAP in exclusive mode;

    if (p_run_mode = 'F') then
      l_extraction_type := 'FULL';
    elsif (p_run_mode = 'I' or
           p_run_mode = 'NO_PRELOAD') then
      l_extraction_type := 'INCREMENTAL';
    elsif (p_run_mode = 'P') then
      l_extraction_type := 'PARTIAL';
    elsif (p_run_mode = 'R') then
      l_extraction_type := 'RBS';
    else
      commit;
      dbms_standard.raise_application_error(-20010, 'Invalid run type');
    end if;

    p_worker_id                := 0;
    l_type                     := 0;
    l_worker_id                := 0;
    l_incomplete_partial_count := 0;
    l_failed_process_count     := 0;
    l_existing_worker          := 'N';  -- To check the resubmit of failed run Bug 5057835

    while l_worker_id < PJI_PJP_SUM_MAIN.g_parallel_processes loop

      l_worker_id := l_worker_id + 1;

      l_process := g_process || l_worker_id;

      l_preload := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process,'PRELOAD');

      if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
          (l_process, l_process) is null) then

        if (p_worker_id = 0) then
          p_worker_id := l_worker_id;
        end if;

      elsif (not PJI_PJP_SUM_MAIN.WORKER_STATUS(l_worker_id, 'RUNNING')     and
             ((l_extraction_type = 'FULL' and
               PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                 (l_process, 'EXTRACTION_TYPE') = 'FULL') or
              (l_extraction_type = 'INCREMENTAL' and
               PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                 (l_process, 'EXTRACTION_TYPE') = 'FULL') or
              (l_extraction_type = 'INCREMENTAL' and
               PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                 (l_process, 'EXTRACTION_TYPE') = 'INCREMENTAL') or
              (l_extraction_type = 'PARTIAL' and
               PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                 (l_process, 'EXTRACTION_TYPE') = 'PARTIAL') or
              (l_extraction_type = 'RBS' and
               PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                 (l_process, 'EXTRACTION_TYPE') = 'RBS'))                   and
               nvl(p_operating_unit, -1) =
               PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process,
                                                 'PROJECT_OPERATING_UNIT')  and
             nvl(p_project_type, 'PJI$NULL') =
               PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process,
                                                 'PROJECT_TYPE')            and
             nvl(p_project_organization_id, -1) =
               PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process,
                                                 'PROJECT_ORGANIZATION_ID') and
             nvl(p_from_project, 'PJI$NULL') =
               PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process,
                                                 'FROM_PROJECT')            and
             nvl(p_to_project, 'PJI$NULL') =
               PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process,
                                                 'TO_PROJECT')              and
             nvl(p_plan_type_id, -1) =
               PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process,
                                                 'PLAN_TYPE_ID')            and
             nvl(p_rbs_header_id, -1) =
               PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process,
                                                 'RBS_HEADER_ID')           and
             nvl(p_transaction_type, 'PJI$NULL') =
               PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process,		 --  Bug#5099574
                                                 'TRANSACTION_TYPE')		and
	     nvl(p_plan_versions, 'PJI$NULL') =
               PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process,		 --  Bug#5099574
                                                 'PLAN_VERSION')			and
             nvl(p_only_pt_projects_flag, 'PJI$NULL') =
               PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process,
                                                 'ONLY_PT_PROJECTS_FLAG') and
         --12.1.3 enhancement
             nvl(p_project_status, 'PJI$NULL') =
               PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process,
                                                 'PROJECT_STATUS'))       then

        p_worker_id := l_worker_id;
        l_existing_worker := 'Y';  -- To check the resubmit of failed run Bug 5057835
        if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process,
                                                   'EXTRACTION_TYPE')
            = 'PARTIAL') then
          l_type := 1;
          l_incomplete_partial_count := l_incomplete_partial_count + 1;
        else
          l_type := 2;
          l_failed_process_count := l_failed_process_count + 1;
        end if;

      elsif (not PJI_PJP_SUM_MAIN.WORKER_STATUS(l_worker_id, 'RUNNING')) then

        if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process,
                                                   'EXTRACTION_TYPE')
            = 'PARTIAL') then
          l_incomplete_partial_count := l_incomplete_partial_count + 1;
        else
          l_failed_process_count := l_failed_process_count + 1;
        end if;

      end if;

    end loop;

--  if (p_worker_id > 0 and
--        ((l_incomplete_partial_count + l_failed_process_count > 0 and   l_type = 0) or
--           (l_type = 1 and l_failed_process_count > 0)
--	  )
--	 ) then
--    OUTPUT_FAILED_RUNS;
--  elsif (p_worker_id = 0) then
    if (p_worker_id = 0) then
      rollback;
      OUTPUT_FAILED_RUNS;
      FND_MESSAGE.SET_NAME('PJI', 'PJI_NO_PRC_AVAILABLE');
      dbms_standard.raise_application_error(-20030, FND_MESSAGE.GET);
    end if;

    l_process := g_process || p_worker_id;

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(l_process, l_process,
                                           FND_GLOBAL.CONC_REQUEST_ID);

    PJI_PJP_EXTRACTION_UTILS.SET_WORKER_ID(p_worker_id);

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(l_process, 'PROCESS_RUNNING', 'Y');
    -- Putting this insert here, Config Hist in case of resubmit of failed run Bug 5057835
        insert into PJI_SYSTEM_CONFIG_HIST
    (
      REQUEST_ID,
      USER_NAME,
      PROCESS_NAME,
      RUN_TYPE,
      PARAMETERS,
      CONFIG_PROJ_PERF_FLAG,
      CONFIG_COST_FLAG,
      CONFIG_PROFIT_FLAG,
      CONFIG_UTIL_FLAG,
      START_DATE,
      END_DATE,
      COMPLETION_TEXT
    )
    select
      FND_GLOBAL.CONC_REQUEST_ID                         REQUEST_ID,
      substr(FND_GLOBAL.USER_NAME, 1, 10)                USER_NAME,
      l_process                                          PROCESS_NAME,
      l_extraction_type                                  RUN_TYPE,
      substr(p_run_mode || ', ' ||
             to_char(p_operating_unit) || ', ' ||
             p_project_type || ', ' ||
          --12.1.3 enhancement add new Project Status Parameter
             p_project_status || ',' ||
             to_char(p_project_organization_id) || ', ' ||
             p_from_project || ', ' ||
             p_to_project || ', ' ||
             to_char(p_plan_type_id) || ', ' ||
             to_char(p_rbs_header_id) || ', ' ||
	     p_transaction_type || ', ' ||
             p_plan_versions || ', ' ||
             p_only_pt_projects_flag, 1, 240)            PARAMETERS,
      null                                               CONFIG_PROJ_PERF_FLAG,
      null                                               CONFIG_COST_FLAG,
      null                                               CONFIG_PROFIT_FLAG,
      null                                               CONFIG_UTIL_FLAG,
      sysdate                                            START_DATE,
      null                                               END_DATE,
      null                                               COMPLETION_TEXT
    from
      dual;

    -- If this is the resubmit of already existing failed run then Bug 5057835
    if l_existing_worker = 'Y' and
    (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_MAIN.INIT_PROCESS(p_worker_id, p_run_mode);')) then
      commit;  -- To release lock/ stamp parameters / config hist
      return;
    end if;

    PJI_PROCESS_UTIL.REFRESH_STEP_TABLE;

	savepoint no_need_to_run_step; --Bug#5171542 Moving up, preload should not set when rollback

    if (p_run_mode = 'NO_PRELOAD') then
      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(l_process, 'PRELOAD', 'N');
    end if;

    l_preload := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'PRELOAD');

    PJI_PJP_EXTRACTION_UTILS.UPDATE_EXTR_SCOPE;

--  Moving down the query for l_rbs_ for the stamping of parameters Bug 5057835

    if (l_extraction_type = 'FULL' or
        l_extraction_type = 'INCREMENTAL' or
        l_extraction_type = 'PARTIAL') then

      -- identify all projects that fit the concurrent program parameters
/*  No Need to check in the table PA_PROJ_ELEMENT_VERSIONS Bug 5057835
      begin -- bug 5356051

        select 'Y'
        into   l_prg_exists
        from   DUAL
        where  exists (select 1
                       from   PA_PROJ_ELEMENT_VERSIONS proj
                       where  proj.OBJECT_TYPE = 'PA_STRUCTURES' and
                              proj.PRG_GROUP is not null and
                              ROWNUM = 1);

        exception when NO_DATA_FOUND then

          l_prg_exists := 'N';

      end;

      if  (l_prg_exists = 'N')  then
*/

/* Added for bug 7551819 */
        begin
        select 'Y' into l_prg_group_flag
        from dual where  p_from_project like 'UPP-BATCH-%';
        exception
             when no_data_found  then
               l_prg_group_flag := 'N'  ;
        end;

     if ( l_prg_group_flag = 'N' )  then
/* Added for bug 7551819 */
      insert into PJI_PJP_PROJ_BATCH_MAP
      (
        WORKER_ID,
        PROJECT_ID,
        PJI_PROJECT_STATUS,
        EXTRACTION_TYPE,
        EXTRACTION_STATUS,
        PROJECT_TYPE,
        PROJECT_ORG_ID,
        PROJECT_ORGANIZATION_ID,
        PROJECT_TYPE_CLASS,
        PRJ_CURRENCY_CODE,
        PROJECT_ACTIVE_FLAG
      )
      select
        p_worker_id,
        status.PROJECT_ID,
        null                                               PJI_PROJECT_STATUS,
        null                                               EXTRACTION_TYPE,
        status.EXTRACTION_STATUS,
        prj.PROJECT_TYPE,
        prj.ORG_ID                                         PROJECT_ORG_ID,
        status.PROJECT_ORGANIZATION_ID,
        status.PROJECT_TYPE_CLASS,
        prj.PROJECT_CURRENCY_CODE,
        'Y'                         PROJECT_ACTIVE_FLAG
/*      Processing is not depending on Project status    Bug 5057835
        decode(active_projects.PROJECT_STATUS_CODE,
               null, 'N', 'Y')                             PROJECT_ACTIVE_FLAG  */
      from
        PJI_PJP_PROJ_EXTR_STATUS status,
        PA_PROJECTS_ALL prj,
        PA_PROJECT_STATUSES proj_status   /*,
        (        Processing is not depending on Project status Bug 5057835
        select
          distinct
          stat.PROJECT_STATUS_CODE
        from
          PA_PROJECT_STATUSES stat
        where
          stat.STATUS_TYPE = 'PROJECT' and
          stat.PROJECT_SYSTEM_STATUS_CODE not in ('CLOSED',
                                                  'PENDING_CLOSE',
                                                  'PENDING_PURGE',
                                                  'PURGED')
        ) active_projects    */
      where
        status.PROJECT_ID = prj.PROJECT_ID and
        prj.PROJECT_TYPE = nvl(p_project_type, prj.PROJECT_TYPE) and
        nvl(prj.ORG_ID, -99) = nvl(p_operating_unit, nvl(prj.ORG_ID, -99)) and
        status.PROJECT_ORGANIZATION_ID = nvl(p_project_organization_id,
                                            status.PROJECT_ORGANIZATION_ID) and
        prj.SEGMENT1 between nvl(p_from_project, prj.SEGMENT1) and
                             nvl(p_to_project, prj.SEGMENT1)
        and proj_status.status_type = 'PROJECT'
        and prj.PROJECT_STATUS_CODE = proj_status.PROJECT_STATUS_CODE
         and proj_status.PROJECT_STATUS_CODE =
nvl(p_project_status,prj.PROJECT_STATUS_CODE)
     /* and prj.PROJECT_STATUS_CODE = active_projects.PROJECT_STATUS_CODE (+)  */;

/* Added for bug 7551819 */
else  -- l_prg_group_flag = 'Y'

     insert into PJI_PJP_PROJ_BATCH_MAP
      (
        WORKER_ID,
        PROJECT_ID,
        PJI_PROJECT_STATUS,
        EXTRACTION_TYPE,
        EXTRACTION_STATUS,
        PROJECT_TYPE,
        PROJECT_ORG_ID,
        PROJECT_ORGANIZATION_ID,
        PROJECT_TYPE_CLASS,
        PRJ_CURRENCY_CODE,
        PROJECT_ACTIVE_FLAG
      )
      select
        p_worker_id,
        status.PROJECT_ID,
        null               PJI_PROJECT_STATUS,
        null               EXTRACTION_TYPE,
        status.EXTRACTION_STATUS,
        prj.PROJECT_TYPE,
        prj.ORG_ID          PROJECT_ORG_ID,
        status.PROJECT_ORGANIZATION_ID,
        status.PROJECT_TYPE_CLASS,
        prj.PROJECT_CURRENCY_CODE,
         'Y'                PROJECT_ACTIVE_FLAG
      from
        PJI_PJP_PROJ_EXTR_STATUS status,
        PA_PROJECTS_ALL prj  ,
        PJI_PRG_GROUP prg1
      where
        status.PROJECT_ID = prj.PROJECT_ID and
        prj.project_id = prg1.project_id  and
        prg1.batch_name = p_from_project ;

end  if;
/* Added for bug 7551819 */


    /*  Not required changed the logic of l_prg_exist Bug 5057835
	elsif (l_prg_exists = 'Y') then

      insert into PJI_PJP_PROJ_BATCH_MAP
      (
        WORKER_ID,
        PROJECT_ID,
        PJI_PROJECT_STATUS,
        EXTRACTION_TYPE,
        EXTRACTION_STATUS,
        PROJECT_TYPE,
        PROJECT_ORG_ID,
        PROJECT_ORGANIZATION_ID,
        PROJECT_TYPE_CLASS,
        PRJ_CURRENCY_CODE,
        PROJECT_ACTIVE_FLAG
      )
      select
        p_worker_id,
        status.PROJECT_ID,
        null                                               PJI_PROJECT_STATUS,
        null                                               EXTRACTION_TYPE,
        status.EXTRACTION_STATUS,
        prj.PROJECT_TYPE,
        prj.ORG_ID                                         PROJECT_ORG_ID,
        status.PROJECT_ORGANIZATION_ID,
        status.PROJECT_TYPE_CLASS,
        prj.PROJECT_CURRENCY_CODE,
        decode(active_projects.PROJECT_ID, null, 'N', 'Y') PROJECT_ACTIVE_FLAG
      from
        PJI_PJP_PROJ_EXTR_STATUS status,
        PA_PROJECTS_ALL          prj,
        (
          select /*+ ordered
                     index(prg, PA_XBS_DENORM_N3)
            distinct
            emt.PROJECT_ID
          from
            PA_PROJECT_STATUSES stat,
            PA_PROJECTS_ALL     prj,
            PA_XBS_DENORM       prg,
            PA_PROJ_ELEMENTS    emt
          where
            stat.STATUS_TYPE                =  'PROJECT'                and
            stat.PROJECT_SYSTEM_STATUS_CODE not in ('CLOSED',
                                                    'PENDING_CLOSE',
                                                    'PENDING_PURGE',
                                                    'PURGED')           and
            prj.PROJECT_STATUS_CODE         =  stat.PROJECT_STATUS_CODE and
            prg.STRUCT_TYPE                 =  'PRG'                    and
            prg.SUP_PROJECT_ID              =  prj.PROJECT_ID           and
            emt.PROJ_ELEMENT_ID             =  prg.SUB_EMT_ID
        ) active_projects
      where
        status.PROJECT_ID = prj.PROJECT_ID and
        prj.PROJECT_TYPE = nvl(p_project_type, prj.PROJECT_TYPE) and
        nvl(prj.org_id,-99) = nvl(p_operating_unit, nvl(prj.org_id,-99)) and
        status.PROJECT_ORGANIZATION_ID = nvl(p_project_organization_id,
                                            status.PROJECT_ORGANIZATION_ID) and
        prj.segment1 between nvl(p_from_project,prj.segment1) and nvl(p_to_project,prj.segment1) and
        status.PROJECT_ID = active_projects.PROJECT_ID (+);    */

      -- identify all projects in the same program groups as the above projects

      begin -- bug 5356051

        select /*+ ordered */
          'Y'
        into
          l_prg_exists
        from
          PJI_PJP_PROJ_BATCH_MAP map,
          PA_PROJ_ELEMENT_VERSIONS proj
        where
          map.WORKER_ID    = p_worker_id     and
          map.PROJECT_ID   = proj.PROJECT_ID and
          proj.OBJECT_TYPE = 'PA_STRUCTURES' and
          proj.PRG_GROUP   is not null       and
          ROWNUM           = 1;

        exception when NO_DATA_FOUND then

          l_prg_exists := 'N';

      end;

/* Added for bug 7551819 */
      -- if (l_prg_exists = 'Y') then
      if (l_prg_exists = 'Y' AND  l_prg_group_flag = 'N' ) then


      insert into PJI_PJP_PROJ_BATCH_MAP
      (
        WORKER_ID,
        PROJECT_ID,
        PJI_PROJECT_STATUS,
        EXTRACTION_TYPE,
        EXTRACTION_STATUS,
        PROJECT_TYPE,
        PROJECT_ORG_ID,
        PROJECT_ORGANIZATION_ID,
        PROJECT_TYPE_CLASS,
        PRJ_CURRENCY_CODE,
        PROJECT_ACTIVE_FLAG
      )
      select /*+ ordered */
        p_worker_id,
        status.PROJECT_ID,
        null                                               PJI_PROJECT_STATUS,
        null                                               EXTRACTION_TYPE,
        status.EXTRACTION_STATUS,
        prj.PROJECT_TYPE,
        prj.ORG_ID                                         PROJECT_ORG_ID,
        status.PROJECT_ORGANIZATION_ID,
        status.PROJECT_TYPE_CLASS,
        prj.PROJECT_CURRENCY_CODE,
        'Y'                                                PROJECT_ACTIVE_FLAG
      from
        (
        select /*+ ordered */
          distinct
          ver2.PROJECT_ID
        from
          PJI_PJP_PROJ_BATCH_MAP   map,
          PA_PROJ_ELEMENT_VERSIONS ver1,
          PA_PROJ_ELEMENT_VERSIONS ver2
        where
          map.WORKER_ID    = p_worker_id     and
          ver1.PROJECT_ID  = map.PROJECT_ID  and
          ver1.PRG_GROUP   is not null       and
          ver2.OBJECT_TYPE = 'PA_STRUCTURES' and
          ver2.PRG_GROUP   = ver1.PRG_GROUP
        union
        select /*+ ordered
                   index(prg1 PJI_XBS_DENORM_N3)
                   index(prg2 PJI_XBS_DENORM_N3) */
          distinct
          prg2.SUP_PROJECT_ID PROJECT_ID
        from
          PJI_PJP_PROJ_BATCH_MAP map,
          PJI_XBS_DENORM         prg1,
          PJI_XBS_DENORM         prg2
        where
          map.WORKER_ID       = p_worker_id    and
          prg1.STRUCT_TYPE    = 'PRG'          and
          prg1.SUP_PROJECT_ID = map.PROJECT_ID and
          prg1.PRG_GROUP      is not null      and
          prg2.STRUCT_TYPE    = 'PRG'          and
          prg2.SUB_LEVEL      = prg2.SUP_LEVEL and
          prg2.PRG_GROUP      = prg1.PRG_GROUP
        ) map,
        PJI_PJP_PROJ_BATCH_MAP   existing_projects,
        PJI_PJP_PROJ_EXTR_STATUS status,
        PA_PROJECTS_ALL          prj
      where
        p_worker_id                  = existing_projects.WORKER_ID  (+) and
        map.PROJECT_ID               = existing_projects.PROJECT_ID (+) and
        existing_projects.PROJECT_ID is null                            and
        map.PROJECT_ID               = status.PROJECT_ID                and
        map.PROJECT_ID               = prj.PROJECT_ID;

      end if;

--      end if; -- Moving this because NO_work_run check is for all projects (including non-prg)

      select
        count(*)
      into
        l_count
      from
        PJI_PJP_PROJ_BATCH_MAP new_worker
      where
        new_worker.WORKER_ID = p_worker_id;

      if (l_count = 0) then

        rollback ;

        NO_WORK_RUNS(p_operating_unit,
                     p_project_organization_id,
                     p_project_type,
                     p_from_project,
                     p_to_project,
                     l_extraction_type,
                     p_project_status);
        FND_MESSAGE.SET_NAME('PJI', 'PJI_NO_WORK');
        dbms_standard.raise_application_error(-20041,FND_MESSAGE.GET);

        end if;

    elsif (l_extraction_type = 'RBS') then

      insert into PJI_PJP_PROJ_BATCH_MAP
      (
        WORKER_ID,
        PROJECT_ID,
        PJI_PROJECT_STATUS,
        EXTRACTION_TYPE,
        EXTRACTION_STATUS,
        PROJECT_TYPE,
        PROJECT_ORG_ID,
        PROJECT_ORGANIZATION_ID,
        PROJECT_TYPE_CLASS,
        PRJ_CURRENCY_CODE,
        PROJECT_ACTIVE_FLAG
      )
      select /*+ ordered
                 index(log, PA_PJI_PROJ_EVENTS_LOG_N1)
                 index(rbs_asg, PA_RBS_PRJ_ASSIGNMENTS_N1) */
        distinct
        p_worker_id,
        rbs_asg.PROJECT_ID,
        null                                           PJI_PROJECT_STATUS,
        null                                           EXTRACTION_TYPE,
        'R'                                            EXTRACTION_STATUS,
        prj.PROJECT_TYPE,
        prj.ORG_ID                                     PROJECT_ORG_ID,
        prj.CARRYING_OUT_ORGANIZATION_ID               PROJECT_ORGANIZATION_ID,
        decode(pt.PROJECT_TYPE_CLASS_CODE,
               'CAPITAL',  'C',
               'CONTRACT', 'B',
               'INDIRECT', 'I')                        PROJECT_TYPE_CLASS,
        prj.PROJECT_CURRENCY_CODE,
        'Y' PROJECT_ACTIVE_FLAG
/*        decode(active_projects.PROJECT_ID,
               null, 'N', 'Y')                         PROJECT_ACTIVE_FLAG  */
      from
        PA_PJI_PROJ_EVENTS_LOG log,
        PA_RBS_PRJ_ASSIGNMENTS rbs_asg,
        PA_PROJECTS_ALL        prj,
        PA_PROJECT_TYPES_ALL   pt    /*,
        (       Processing is now not depending on status Bug 5057835
          select /*+ ordered
                     index(prg, PA_XBS_DENORM_N3)
            distinct
            emt.PROJECT_ID
          from
            PA_PROJECT_STATUSES stat,
            PA_PROJECTS_ALL     prj,
            PA_XBS_DENORM       prg,
            PA_PROJ_ELEMENTS    emt
          where
            stat.STATUS_TYPE = 'PROJECT' and
            stat.PROJECT_SYSTEM_STATUS_CODE not in ('CLOSED',
                                                    'PENDING_CLOSE',
                                                    'PENDING_PURGE',
                                                    'PURGED') and
            prj.PROJECT_STATUS_CODE = stat.PROJECT_STATUS_CODE and
            prg.STRUCT_TYPE                 =  'PRG'                    and
            prg.SUP_PROJECT_ID              =  prj.PROJECT_ID           and
            emt.PROJ_ELEMENT_ID             =  prg.SUB_EMT_ID
        ) active_projects    */
      where
        log.EVENT_TYPE         in ('RBS_PUSH', 'RBS_DELETE')         and
   --     rbs_asg.RBS_VERSION_ID in (log.EVENT_OBJECT, log.ATTRIBUTE2) and --Commented for Bug#5728852 by VVJOSHI
        rbs_asg.RBS_HEADER_ID  =  nvl(p_rbs_header_id,
                                      rbs_asg.RBS_HEADER_ID)         and
        nvl(prj.org_id,-99) = nvl(p_operating_unit, nvl(prj.org_id,-99)) and
        rbs_asg.PROJECT_ID     =  prj.PROJECT_ID                     and
        nvl(prj.ORG_ID, -1)    =  nvl(pt.ORG_ID, -1)                 and
        prj.PROJECT_TYPE       =  pt.PROJECT_TYPE      ;       /*       and
        rbs_asg.PROJECT_ID     =  active_projects.PROJECT_ID (+);  */

    end if;

    		if (l_extraction_type ='INCREMENTAL'  and p_run_mode <> 'NO_PRELOAD') then			--Bug#5171542 - Start

			begin
			SELECT 'FULL' INTO l_extraction_type FROM DUAL
			WHERE EXISTS
			(
			SELECT 1
			FROM pji_pjp_proj_extr_status extr,
				 PJI_PJP_PROJ_BATCH_MAP map
			WHERE map.project_id=extr.project_id
				  AND extr.extraction_status='F'
				  AND WORKER_ID = p_worker_id
			);
			exception
			WHEN no_data_found THEN
			l_extraction_type:='INCREMENTAL';
			end;


	if( l_extraction_type = 'FULL'  ) then
	      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(l_process,
                                             'PRELOAD',
                                             'Y');

		end if;



	end if;
-- Code for delete moved down Bug 5057835
           PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(l_process,
                                           'EXTRACTION_TYPE',
                                           l_extraction_type);


    PJI_PROCESS_UTIL.ADD_STEPS(l_process, 'PJI_PJP', l_extraction_type);


    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_MAIN.INIT_PROCESS(p_worker_id, p_run_mode);')) then
	rollback to no_need_to_run_step;
	Commit; -- To release lock/ stamp parameters / config hist
    return;
    end if;

    --Bug#5171542 - End
-- start of overlapping work check Bug 5057835

    l_count := 0;
 for c in
      (
      select distinct
             existing_workers.WORKER_ID
      from   PJI_PJP_PROJ_BATCH_MAP existing_workers
      where  existing_workers.WORKER_ID <> p_worker_id and
             exists (select 1
                     from  PJI_PJP_PROJ_BATCH_MAP new_worker
                     where new_worker.WORKER_ID = p_worker_id and
                           new_worker.PROJECT_ID = existing_workers.PROJECT_ID)
      ) loop

      l_count := l_count + 1;
      request_id_table.EXTEND;
      prog_name_table.EXTEND;
      -- SUBMIT_REQUEST should check if the request is already running and
      -- just return the request id and program name if it is.

  --  IF PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER( g_process || c.WORKER_ID, 'EXTRACTION_TYPE')<> 'RBS' THEN

      SUBMIT_REQUEST(c.WORKER_ID,               -- to retrieve the parameters
                     request_id_table(l_count), -- in / out
                     prog_name_table(l_count)   -- in / out
                    );
   -- ELSE
   -- l_rbs_exists:='Y';
   -- END IF;
    end loop;

    if (l_count > 0) then

        rollback; -- unlock PJI_PJP_PROJ_BATCH_MAP

        for i in 1..l_count loop
           if request_id_table(i) <> -1 then
   pa_debug.log_message('Current Program is waiting for the Concurrent request with the request no: '||request_id_table(i), 1);
              PJI_PROCESS_UTIL.WAIT_FOR_REQUEST(request_id_table(i), 10);

              if (not PJI_PROCESS_UTIL.REQUEST_STATUS('OKAY',
                                                request_id_table(i),
                                                prog_name_table(i))) then

                 -- We may want to add, to the error message, the request
                 -- ID that is causing the program to fail
                 OUTPUT_FAILED_RUNS;
                 FND_MESSAGE.SET_NAME('PJI', 'PJI_OVERLAPPING_WORK');
                 dbms_standard.raise_application_error(-20040, FND_MESSAGE.GET);

              end if;
           end if;
        end loop;
       -- IF l_rbs_exists ='Y' THEN
       --    FND_MESSAGE.SET_NAME('PJI', 'PJI_OVERLAPPING_WORK');
       --    dbms_standard.raise_application_error(-20040, FND_MESSAGE.GET);
       --  END IF;
        INIT_PROCESS(p_worker_id,
                    p_run_mode,
                    p_operating_unit,
                    p_project_type,
                    p_project_organization_id,
                    p_from_project,
                    p_to_project,
                    p_plan_type_id,
                    p_rbs_header_id,
                    p_only_pt_projects_flag,
                    p_transaction_type,
                    p_plan_versions,
                 -- 12.1.3 enhancement
                    p_project_status);

         return;
    else
       if (p_worker_id > 0 and
          ((l_incomplete_partial_count + l_failed_process_count > 0 and   l_type = 0) or
            (l_type = 1 and l_failed_process_count > 0)
	   )
	  ) then
          OUTPUT_FAILED_RUNS;
       end if;
    end if;

    -- end of overlapping work check Bug 5057835


	        if (l_extraction_type = 'FULL' or
 	       l_extraction_type = 'INCREMENTAL' or
  	      l_extraction_type = 'PARTIAL') then

	      delete
 	     from   PJI_PJP_PROJ_BATCH_MAP
	      where  WORKER_ID = p_worker_id and
	             ((l_extraction_type = 'FULL' and
	               EXTRACTION_STATUS <> 'F') or
	              (l_extraction_type = 'INCREMENTAL' and
	               EXTRACTION_STATUS <> 'I') or
	              (l_extraction_type = 'PARTIAL' and
	               EXTRACTION_STATUS <> 'I'));

 	     delete
	      from   PA_PJI_PROJ_EVENTS_LOG log
 	     where  log.EVENT_TYPE in ('WBS_CHANGE',
	                                'WBS_PUBLISH'/*,
	                                'RBS_ASSOC',
 	                               'RBS_PRG'*/	--Commented for bug#6113807 by VVJOSHI
				       ) and
  	           log.ATTRIBUTE1 in (select stat.PROJECT_ID
   	                             from   PJI_PJP_PROJ_BATCH_MAP map,
    	                                   PJI_PJP_PROJ_EXTR_STATUS stat
     	                           where  map.WORKER_ID = p_worker_id  and
      	                                 stat.PROJECT_ID = map.PROJECT_ID and
       	                                stat.EXTRACTION_STATUS = 'F');

	end if;

    update PJI_PJP_PROJ_EXTR_STATUS
    set    EXTRACTION_STATUS = 'I',
           LAST_UPDATE_DATE = sysdate
    where  l_extraction_type = 'FULL' and
           EXTRACTION_STATUS = 'F' and
           PROJECT_ID in (select PROJECT_ID
                          from   PJI_PJP_PROJ_BATCH_MAP
                          where  WORKER_ID = p_worker_id);

    for c in lock_headers(p_worker_id) loop
      update PJI_PJP_WBS_HEADER wbs_hdr
      set    wbs_hdr.LOCK_FLAG = 'P'
      where  wbs_hdr.ROWID = c.HDR_ROWID;
    end loop;


	 --  Bug#5099574 - Changes  for Partial Refresh - Start - Populating the Refresh Code

        if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process,'EXTRACTION_TYPE') = 'PARTIAL') then

--   If p_transaction_type is null then l_refresh_code is set to 63 . So All Actuals and Plans get refreshed
--  This change is done to make sure the code is compatible with R12 Code  Bug# 5453009

			if p_transaction_type is not null then
				SELECT SUM(REFRESH_CODE) INTO l_refresh_code
				FROM (
					  SELECT
					  DECODE(p_transaction_type,'ALL_TXN_TYPE',1,'ACTUAL_TXN_TYPE',1,0) 	REFRESH_CODE
					  FROM DUAL
						UNION ALL
					  SELECT
					  (CASE p_plan_versions
					     WHEN 'ALL_PLAN_VERSION' 		THEN 62
					     WHEN 'CB_VERSION'				THEN 2
					     WHEN 'CO_VERSION'				THEN 4
					     WHEN 'LP_VERSION'				THEN 8
					     WHEN 'WK_VERSION'				THEN 16
					     WHEN 'LAT_VERSION'				THEN 30
						 ELSE 0
						 END)  			   		REFRESH_CODE
					FROM DUAL
					);

			else
					l_refresh_code :=63;
			end if;

         end if;

	 --  Bug#5099574 - Changes  for Partial Refresh - End

    -- Set global process parameters
    -- Reshuffle the following query
   if (p_rbs_header_id is not null) then

      select max(ver.RBS_VERSION_ID)
      into   l_rbs_version_id
      from   PA_RBS_VERSIONS_B ver,
             PJI_PJP_RBS_HEADER rbs_hdr
      where  ver.RBS_HEADER_ID = p_rbs_header_id and
             ver.STATUS_CODE = 'FROZEN' and
             ver.RBS_VERSION_ID = rbs_hdr.RBS_VERSION_ID;

    end if;


    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
      (l_process, 'PROJECT_TYPE', nvl(p_project_type, 'PJI$NULL'));
    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
      (l_process, 'PROJECT_OPERATING_UNIT', nvl(p_operating_unit, -1));
    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
      (l_process,
       'PROJECT_ORGANIZATION_ID', nvl(p_project_organization_id, -1));
    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
      (l_process, 'FROM_PROJECT', nvl(p_from_project, 'PJI$NULL'));
    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
      (l_process, 'TO_PROJECT', nvl(p_to_project, 'PJI$NULL'));
    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
      (l_process, 'FROM_PROJECT_ID', nvl(p_from_project_id, -1));
    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
      (l_process, 'TO_PROJECT_ID', nvl(p_to_project_id, -1));
    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
      (l_process, 'PLAN_TYPE_ID', nvl(p_plan_type_id, -1));
    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
      (l_process, 'RBS_HEADER_ID', nvl(p_rbs_header_id, -1));
    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
      (l_process, 'RBS_VERSION_ID', nvl(l_rbs_version_id, -1));
    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
      (l_process,
       'ONLY_PT_PROJECTS_FLAG', nvl(p_only_pt_projects_flag, 'PJI$NULL'));

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
      (l_process,
       'TRANSACTION_TYPE', nvl(p_transaction_type, 'PJI$NULL'));
    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
      (l_process,
       'PLAN_VERSION', nvl(p_plan_versions, 'PJI$NULL'));

   --12.1.3 enhancement
    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
     (l_process, 'PROJECT_STATUS',NVL(p_project_status,'PJI$NULL'));


    if (PJI_UTILS.GET_SETUP_PARAMETER('PA_PERIOD_FLAG') = 'N') then
      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(l_process,
                                             'PA_CALENDAR_FLAG',
                                             'N');
    else
      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(l_process,
                                             'PA_CALENDAR_FLAG',
                                              'Y');
    end if;

    if (PJI_UTILS.GET_SETUP_PARAMETER('GL_PERIOD_FLAG') = 'N') then
      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(l_process,
                                             'GL_CALENDAR_FLAG',
                                             'N');
    else
      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(l_process,
                                             'GL_CALENDAR_FLAG',
                                             'Y');
    end if;

	 --  Bug#5099574 - Changes  for Partial Refresh - Start - setting up the global process parameters


	  if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process,'EXTRACTION_TYPE') = 'PARTIAL') then
   	       PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
		      (l_process,
		       'REFRESH_CODE', nvl(l_refresh_code, -1));
	  end if;

		 --  Bug#5099574 - Changes  for Partial Refresh - End  -

    PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER
      (l_process, 'PROGRAM_EXISTS', l_prg_exists);

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_MAIN.INIT_PROCESS(p_worker_id, p_run_mode);');

    commit;

  end INIT_PROCESS;


  -- -----------------------------------------------------
  -- procedure RUN_PROCESS
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure RUN_PROCESS (p_worker_id in number) is

    l_process varchar2(30);
    l_extraction_type varchar2(30);
    l_profile_check varchar2(30); /* Added for Bug 8708651 */

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_MAIN.RUN_PROCESS(p_worker_id);')) then
      return;
    end if;

    l_extraction_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (l_process, 'EXTRACTION_TYPE');

   /* Added for Bug 8708651 */
   l_profile_check := FND_PROFILE.VALUE('PJI_SUM_CLEANALL');

    PJI_PJP_EXTRACTION_UTILS.SEED_PJI_PJP_STATS(p_worker_id);

    PJI_PJP_SUM_ROLLUP.POPULATE_TIME_DIMENSION(p_worker_id);

    PJI_PJP_EXTRACTION_UTILS.POPULATE_ORG_EXTR_INFO;

    -- implicit commit
    FND_STATS.GATHER_TABLE_STATS(ownname => PJI_UTILS.GET_PJI_SCHEMA_NAME,
                                 tabname => 'PJI_ORG_EXTR_INFO',
                                 percent => 10,
                                 degree  => PJI_UTILS.
                                            GET_DEGREE_OF_PARALLELISM);
    -- implicit commit
    FND_STATS.GATHER_INDEX_STATS(ownname => PJI_UTILS.GET_PJI_SCHEMA_NAME,
                                 indname => 'PJI_ORG_EXTR_INFO_N1',
                                 percent => 10);

    PJI_PJP_SUM_ROLLUP.SET_ONLINE_CONTEXT(null, null, null, null, null, null,
                                          null, null, null, null);

    PJI_PJP_SUM_ROLLUP.CREATE_EVENTS_SNAPSHOT(p_worker_id);

    PJI_PJP_SUM_ROLLUP.LOCK_HEADERS(p_worker_id);

/* plan type code changes (4882640) This API call will be shifted to step entry */
     if (PJI_UTILS.GET_PARAMETER('PJI_PTC_UPGRADE') = 'P') and l_extraction_type <> 'PARTIAL' then
         PLAN_TYPE_CODE_CHANGES (p_worker_id);
     end if;
/*---------- plan type code changes (4882640) ------------*/


    PJI_PJP_SUM_ROLLUP.PROCESS_RBS_CHANGES(p_worker_id);

    PJI_PJP_SUM_DENORM.POPULATE_XBS_DENORM(p_worker_id, 'ALL',
                                           null, null, null);

    PJI_PJP_SUM_ROLLUP.UPDATE_XBS_DENORM_FULL(p_worker_id);

    PJI_PJP_SUM_ROLLUP.UPDATE_PROGRAM_WBS(p_worker_id);
    PJI_PJP_SUM_ROLLUP.PURGE_EVENT_DATA(p_worker_id);
    PJI_PJP_SUM_ROLLUP.UPDATE_PROGRAM_RBS(p_worker_id);

    PJI_PJP_SUM_ROLLUP.CREATE_MAPPING_RULES(p_worker_id);
    PJI_PJP_SUM_ROLLUP.MAP_RBS_HEADERS(p_worker_id);

    PJI_PJP_SUM_DENORM.POPULATE_RBS_DENORM(p_worker_id, 'ALL', null);

    PJI_PJP_SUM_ROLLUP.POPULATE_XBS_DENORM_DELTA(p_worker_id);
    PJI_PJP_SUM_ROLLUP.POPULATE_RBS_DENORM_DELTA(p_worker_id);

    PJI_FM_SUM_PSI.BALANCES_ROWID_TABLE(p_worker_id);
    PJI_FM_SUM_PSI.ACT_ROWID_TABLE(p_worker_id);

    PJI_PJP_SUM_ROLLUP.AGGREGATE_FP_SLICES(p_worker_id);
    PJI_PJP_SUM_ROLLUP.AGGREGATE_AC_SLICES(p_worker_id);

/* Added for bug 8353629 */
    FND_STATS.GATHER_TABLE_STATS(ownname => PJI_UTILS.GET_PJI_SCHEMA_NAME,
                                 tabname => 'PJI_FP_AGGR_PJP0',
                                 percent => 10,
                                 degree  => PJI_UTILS.
                                            GET_DEGREE_OF_PARALLELISM);

    FND_STATS.GATHER_TABLE_STATS(ownname => PJI_UTILS.GET_PJI_SCHEMA_NAME,
                                 tabname => 'PJI_PJP_PROJ_BATCH_MAP',
                                 percent => 10,
                                 degree  => PJI_UTILS.
                                            GET_DEGREE_OF_PARALLELISM);
/* Added for bug 8353629 */


    PJI_PJP_SUM_ROLLUP.MARK_EXTRACTED_PROJECTS(p_worker_id);

    PJI_PJP_SUM_CUST.PJP_CUSTOM_FPR_API(p_worker_id);
    PJI_PJP_SUM_CUST.PJP_CUSTOM_ACR_API(p_worker_id);

    PJI_PJP_SUM_ROLLUP.AGGREGATE_FP_CUST_SLICES(p_worker_id);
    PJI_PJP_SUM_ROLLUP.AGGREGATE_AC_CUST_SLICES(p_worker_id);

    PJI_PJP_SUM_ROLLUP.GET_PLANRES_ACTUALS(p_worker_id);
    PJI_PJP_SUM_ROLLUP.PULL_PLANS_FOR_PR(p_worker_id);
    PJI_PJP_SUM_ROLLUP.PULL_PLANS_FOR_RBS(p_worker_id);
    PJI_PJP_SUM_ROLLUP.PULL_DANGLING_PLANS(p_worker_id);
    PJI_PJP_SUM_ROLLUP.PROCESS_PENDING_PLAN_UPDATES(p_worker_id);

    PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_CAL_ALL(p_worker_id);
    PJI_PJP_SUM_ROLLUP.ROLLUP_ACR_CAL_ALL(p_worker_id);

    PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_CAL_NONTP(p_worker_id);
    PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_CAL_PA(p_worker_id);
    PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_CAL_GL(p_worker_id);
    PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_CAL_EN(p_worker_id);
    PJI_PJP_SUM_ROLLUP.ROLLUP_ACR_CAL_PA(p_worker_id);
    PJI_PJP_SUM_ROLLUP.ROLLUP_ACR_CAL_GL(p_worker_id);
    PJI_PJP_SUM_ROLLUP.ROLLUP_ACR_CAL_EN(p_worker_id);

    PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_RBS_TOP(p_worker_id);
    PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_WBS(p_worker_id);
    PJI_PJP_SUM_ROLLUP.ROLLUP_ACR_WBS(p_worker_id);

    PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_PRG(p_worker_id);
    PJI_PJP_SUM_ROLLUP.ROLLUP_ACR_PRG(p_worker_id);

    PJI_PJP_SUM_ROLLUP.ROLLUP_FPR_RBS_SMART_SLICES(p_worker_id);

    PJI_PJP_SUM_ROLLUP.AGGREGATE_PLAN_DATA(p_worker_id);
    PJI_PJP_SUM_ROLLUP.PURGE_PLAN_DATA(p_worker_id);

    PJI_PJP_SUM_ROLLUP.UPDATE_WBS_HDR(p_worker_id);

    /* Addded for Bug 8708651 Start */
    if (l_profile_check = 'Y') then
        PJI_PJP_SUM_ROLLUP.GET_FPR_ROWIDS(p_worker_id);
        PJI_PJP_SUM_ROLLUP.UPDATE_FPR_ROWS(p_worker_id);
        PJI_PJP_SUM_ROLLUP.INSERT_FPR_ROWS(p_worker_id);
        PJI_PJP_SUM_ROLLUP.CLEANUP_FPR_ROWID_TABLE(p_worker_id);
    else
        PJI_PJP_SUM_ROLLUP.MERGE_INTO_FP_FACTS(p_worker_id);
    end if;
    /* Addded for Bug 8708651 End */

    PJI_PJP_SUM_ROLLUP.GET_ACR_ROWIDS(p_worker_id);
    PJI_PJP_SUM_ROLLUP.UPDATE_ACR_ROWS(p_worker_id);
    PJI_PJP_SUM_ROLLUP.INSERT_ACR_ROWS(p_worker_id);
    PJI_PJP_SUM_ROLLUP.CLEANUP_ACR_ROWID_TABLE(p_worker_id);

    PJI_PJP_SUM_ROLLUP.UPDATE_XBS_DENORM(p_worker_id);
    PJI_PJP_SUM_ROLLUP.UPDATE_RBS_DENORM(p_worker_id);

    PJI_PJP_SUM_ROLLUP.PROCESS_PENDING_EVENTS(p_worker_id);
    PJI_PJP_SUM_ROLLUP.GET_TASK_ROLLUP_ACTUALS(p_worker_id);

    PJI_FM_SUM_PSI.BALANCES_UPDATE_DELTA(p_worker_id);
    PJI_FM_SUM_PSI.BALANCES_INSERT_DELTA(p_worker_id);
    PJI_FM_SUM_PSI.PURGE_BALANCES_CMT(p_worker_id);
    PJI_FM_SUM_PSI.BALANCES_INSERT_DELTA_CMT(p_worker_id);
    PJI_FM_SUM_PSI.PURGE_INCREMENTAL_BALANCES(p_worker_id);
    PJI_FM_SUM_PSI.PURGE_BALANCES_ACT(p_worker_id);

    PJI_PJP_SUM_ROLLUP.UNLOCK_ALL_HEADERS(p_worker_id);
    PJI_PJP_SUM_ROLLUP.CLEANUP(p_worker_id);

    -- if (PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
    --       (l_process, 'FROM_PROJECT_ID') = -1 and
    --     PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
    --       (l_process, 'TO_PROJECT_ID') = -1) then
    --   PJI_PJP_EXTRACTION_UTILS.ANALYZE_PJP_FACTS;
    -- end if;

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_MAIN.RUN_PROCESS(p_worker_id);');

    commit;

  end RUN_PROCESS;


  -- -----------------------------------------------------
  -- procedure WRAPUP_PROCESS
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure WRAPUP_PROCESS (p_worker_id in number) is

    l_process                 varchar2(30);
    l_pji_schema              varchar2(30);

    l_worker_id               number;
    l_preload                 varchar2(30);
    l_project_type            varchar2(255);
    l_project_organization_id number;
    l_from_project_id         number;
    l_to_project_id           number;
    l_plan_type_id            number;
    l_rbs_header_id           number;
    l_only_pt_projects_flag   varchar2(255);
    l_operating_unit  number;
    l_from_project            pa_projects_all.segment1%TYPE;
    l_to_project              pa_projects_all.segment1%TYPE;
    l_project_status          varchar2(30);  --12.1.3 enhancement

  begin

    l_process := PJI_PJP_SUM_MAIN.g_process || p_worker_id;

    if (not PJI_PROCESS_UTIL.NEED_TO_RUN_STEP(l_process, 'PJI_PJP_SUM_MAIN.WRAPUP_PROCESS(p_worker_id);')) then
      return;
    end if;
  --    Changes for bug 6266824
  /* Commented for bug 6266824
  --    lock table PJI_PJP_PROJ_BATCH_MAP in exclusive mode;
  if p_worker_id = 1 then
    lock table PJI_PJP_PROJ_BATCH_MAP PARTITION(P1) in exclusive mode;
  elsif p_worker_id = 2 then
    lock table PJI_PJP_PROJ_BATCH_MAP PARTITION(P2) in exclusive mode;
  elsif p_worker_id = 3 then
    lock table PJI_PJP_PROJ_BATCH_MAP PARTITION(P3) in exclusive mode;
  elsif p_worker_id = 4 then
    lock table PJI_PJP_PROJ_BATCH_MAP PARTITION(P4) in exclusive mode;
  elsif p_worker_id = 5 then
    lock table PJI_PJP_PROJ_BATCH_MAP PARTITION(P5) in exclusive mode;
  elsif p_worker_id = 6 then
    lock table PJI_PJP_PROJ_BATCH_MAP PARTITION(P6) in exclusive mode;
  elsif p_worker_id = 7 then
    lock table PJI_PJP_PROJ_BATCH_MAP PARTITION(P7) in exclusive mode;
  elsif p_worker_id = 8 then
    lock table PJI_PJP_PROJ_BATCH_MAP PARTITION(P8) in exclusive mode;
  elsif p_worker_id = 9 then
    lock table PJI_PJP_PROJ_BATCH_MAP PARTITION(P9) in exclusive mode;
  elsif p_worker_id = 10 then
    lock table PJI_PJP_PROJ_BATCH_MAP PARTITION(P10) in exclusive mode;
  end if;
*/
    l_preload := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER(l_process, 'PRELOAD');

    if (l_preload = 'Y') then

      l_project_type := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                        (l_process, 'PROJECT_TYPE');

      if (l_project_type = 'PJI$NULL') then
        l_project_type := null;
      end if;

      l_operating_unit := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                           (l_process, 'PROJECT_OPERATING_UNIT');

      if (l_operating_unit = -1) then
        l_operating_unit  := null;
      end if;

      l_project_organization_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                                   (l_process, 'PROJECT_ORGANIZATION_ID');

      if (l_project_organization_id = -1) then
        l_project_organization_id := null;
      end if;

      l_from_project_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                           (l_process, 'FROM_PROJECT_ID');

      if (l_from_project_id = -1) then
        l_from_project_id := null;
      end if;

      l_to_project_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (l_process, 'TO_PROJECT_ID');

      if (l_to_project_id = -1) then
        l_to_project_id := null;
      end if;

     l_from_project := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                           (l_process, 'FROM_PROJECT');

      if (l_from_project = 'PJI$NULL') then
        l_from_project := null;
      end if;

      l_to_project := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (l_process, 'TO_PROJECT');

      if (l_to_project = 'PJI$NULL') then
        l_to_project := null;
      end if;

      l_plan_type_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                        (l_process, 'PLAN_TYPE_ID');

      if (l_plan_type_id = -1) then
        l_plan_type_id := null;
      end if;

      l_rbs_header_id := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (l_process, 'RBS_HEADER_ID');

      if (l_rbs_header_id = -1) then
        l_rbs_header_id := null;
      end if;

      l_only_pt_projects_flag := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                                 (l_process, 'ONLY_PT_PROJECTS_FLAG');

      if (l_only_pt_projects_flag = 'PJI$NULL') then
        l_only_pt_projects_flag := null;
      end if;

     -- 12.1.3 enhancement
     l_project_status  := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                          (l_process, 'PROJECT_STATUS');

     if (l_project_status = 'PJI$NULL') then
        l_project_status := null;
     end if;

    end if;


    -- clean up worker tables

    l_pji_schema := PJI_UTILS.GET_PJI_SCHEMA_NAME;

    if (NVL(l_preload,'N') <> 'Y') then
      OUTPUT_ACT_FAILED_RUNS(p_worker_id);
      OUTPUT_ACT_PASSED_RUNS(p_worker_id);
    end if;

    update PJI_PJP_PROJ_EXTR_STATUS
    set    LAST_UPDATE_DATE = sysdate
    where  PROJECT_ID in (select map.PROJECT_ID
                          from   PJI_PJP_PROJ_BATCH_MAP map
                          where  map.WORKER_ID = p_worker_id);

    delete from PJI_PJP_PROJ_BATCH_MAP where WORKER_ID = p_worker_id;

    -- mark current iteration as successful

    PJI_PROCESS_UTIL.WRAPUP_PROCESS(l_process);

    update PJI_SYSTEM_CONFIG_HIST
    set    END_DATE = sysdate,
           COMPLETION_TEXT = 'Normal completion'
    where  PROCESS_NAME = l_process and
           END_DATE is null;

    -- update default report as-of date

    PJI_UTILS.SET_PARAMETER('LAST_PJP_EXTR_DATE_' || l_process,
                            to_char(sysdate, PJI_PJP_SUM_MAIN.g_date_mask));

    PJI_PROCESS_UTIL.REGISTER_STEP_COMPLETION(l_process, 'PJI_PJP_SUM_MAIN.WRAPUP_PROCESS(p_worker_id);');

    if (l_preload = 'Y') then

      INIT_PROCESS(l_worker_id,
                   'NO_PRELOAD',
                   l_operating_unit,
                   l_project_type,
                   l_project_organization_id,
                   l_from_project,
                   l_to_project,
                /* l_from_project_id,
                   l_to_project_id, */
                   l_plan_type_id,
                   l_rbs_header_id,
                   l_only_pt_projects_flag,
                   NULL,
                   NULL,
                   l_project_status);   --12.1.3 enhancement

      RUN_PROCESS(l_worker_id);
      WRAPUP_PROCESS(l_worker_id);

    end if;

    commit;

  end WRAPUP_PROCESS;


  -- -----------------------------------------------------
  -- procedure WRAPUP_FAILURE
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure WRAPUP_FAILURE (p_worker_id in number) is

    l_process_running varchar2(240);
    l_sqlerrm varchar2(240);

  begin

    rollback;

    l_process_running := PJI_PROCESS_UTIL.GET_PROCESS_PARAMETER
                         (g_process || p_worker_id, 'PROCESS_RUNNING');

    if (l_process_running is not null) then

      PJI_PROCESS_UTIL.SET_PROCESS_PARAMETER(g_process || p_worker_id,
                                             'PROCESS_RUNNING',
                                             'F');

    end if;

    l_sqlerrm := substr(sqlerrm, 1, 240);

    update PJI_SYSTEM_CONFIG_HIST
    set    END_DATE = sysdate,
           COMPLETION_TEXT = l_sqlerrm
    where  PROCESS_NAME = g_process || p_worker_id and
           END_DATE is null;

    commit;

    pji_utils.write2log(sqlerrm, true, 0);

    commit;

  end WRAPUP_FAILURE;


  -- -----------------------------------------------------
  -- procedure SUMMARIZE
  --
  -- This the the main procedure, it is invoked from
  -- a concurrent program.
  --
  --   History
  --   19-MAR-2004  SVERMETT  Created
  --
  -- Internal PJP Summarization API.
  --
  -- -----------------------------------------------------
  procedure SUMMARIZE
  (
    errbuf                    out nocopy varchar2,
    retcode                   out nocopy varchar2,
    p_run_mode                in         varchar2,
    p_operating_unit          in         number   default null,
    p_project_organization_id in         number   default null,
    p_project_type            in         varchar2 default null,
    p_from_project            in         varchar2 default null,
    p_to_project              in         varchar2 default null,
    p_plan_type_id            in         number   default null,
    p_rbs_header_id           in         number   default null,
    p_transaction_type    in         varchar2 default null,		 --  Bug#5099574 - New parameter for Partial Refresh
    p_plan_versions     in         varchar2 default null,		 --  Bug#5099574 - New parameter for Partial Refresh
    p_project_status          in   varchar2 default null, --12.1.3 enhancement
    p_only_pt_projects_flag   in         varchar2 default null
  ) is

    l_pji_not_licensed exception;
    pragma exception_init(l_pji_not_licensed, -20020);

    l_worker_id       number;
    l_from_project_id number;
    l_to_project_id   number;

  begin

    -- if (PA_INSTALL.is_pji_licensed = 'N') then
    --   pji_utils.write2log('Error: PJI is not licensed.');
    --   commit;
    --   raise l_pji_not_licensed;
    -- end if;
    commit;
    execute immediate 'alter session enable parallel query';
    execute immediate 'alter session enable parallel dml';

    g_retcode := 0;

    pa_debug.set_process('PLSQL');  /* start 4893117 */
    IF p_run_mode IN ('I','F') then
      pa_debug.log_message('=======Concurrent Program Parameters Start =======', 1);
      pa_debug.log_message('Argument => Operating Unit ['||p_operating_unit||']', 1);
      pa_debug.log_message('Argument => Project Organization ['||p_project_organization_id||']', 1);
      pa_debug.log_message('Argument => Project Type ['||p_project_type||']', 1);
--12.1.3 enhancement
      pa_debug.log_message('Argument => Project Status ['||p_project_status||']',1);
      pa_debug.log_message('Argument => From Project Number ['||p_from_project||']', 1);
      pa_debug.log_message('Argument => To Project Number ['||p_to_project||']', 1);
      pa_debug.log_message('=======Concurrent Program Parameters End =======', 1);
    ELSIF p_run_mode in ('P') then
      pa_debug.log_message('=======Concurrent Program Parameters Start =======', 1);
      pa_debug.log_message('Argument => Operating Unit ['||p_operating_unit||']', 1);
      pa_debug.log_message('Argument => From Project Number ['||p_from_project||']', 1);
      pa_debug.log_message('Argument => To Project Number ['||p_to_project||']', 1);
      pa_debug.log_message('Argument => Plan Type ['||p_plan_type_id||']', 1);
      pa_debug.log_message('Argument => Transaction Type ['||p_transaction_type||']', 1);
      pa_debug.log_message('Argument => Plan Version ['||p_plan_versions||']', 1);
      pa_debug.log_message('=======Concurrent Program Parameters End =======', 1);
    ELSIF p_run_mode in ('R') then
      pa_debug.log_message('=======Concurrent Program Parameters Start =======', 1);
      pa_debug.log_message('Argument => RBS Header Name ['||p_rbs_header_id||']', 1);
      pa_debug.log_message('=======Concurrent Program Parameters End =======', 1);
    END IF;   /* end 4893117 */

    INIT_PROCESS(l_worker_id,
                 p_run_mode,
                 p_operating_unit,
                 p_project_type,
                 p_project_organization_id,
                 p_from_project,
                 p_to_project,
                 p_plan_type_id,
                 p_rbs_header_id,
                 p_only_pt_projects_flag,
	         p_transaction_type  ,	 --  Bug#5099574 - New parameter for Partial Refresh
	         p_plan_versions,         --  Bug#5099574 - New parameter for Partial Refresh
                 p_project_status        --  12.1.3 enhancement
		 );

    begin

      RUN_PROCESS(l_worker_id);
      WRAPUP_PROCESS(l_worker_id);

      exception when others then

        WRAPUP_FAILURE(l_worker_id);
        execute immediate 'alter session disable parallel dml';
        retcode := 2;
        errbuf := sqlerrm;
        raise;

    end;

    commit;
    execute immediate 'alter session disable parallel dml';

    retcode := g_retcode;

    exception when others then
      rollback;
      IF SQLCODE = -20041 then
        retcode := 1;
      ELSE
        retcode := 2;
        errbuf := sqlerrm;
        -- raise; commented for  bug 6015217
      END IF;

  end SUMMARIZE;

end PJI_PJP_SUM_MAIN;

/
