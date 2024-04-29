--------------------------------------------------------
--  DDL for Package Body FPA_PROJECT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FPA_PROJECT_PVT" as
 /* $Header: FPAVPRJB.pls 120.16.12010000.2 2008/08/22 06:57:42 vgovvala ship $ */

 G_PKG_NAME    CONSTANT VARCHAR2(200) := 'FPA_PROJECT_PVT';
 G_APP_NAME    CONSTANT VARCHAR2(3)   :=  FPA_UTILITIES_PVT.G_APP_NAME;
 G_API_TYPE    CONSTANT VARCHAR2(4)   := '_PVT';
 L_API_NAME    CONSTANT VARCHAR2(35)  := 'PROJECT';

 G_SELECTION_CATEGORY VARCHAR2(200) := FND_PROFILE.VALUE('PJP_PORTFOLIO_CLASS_CATEGORY');
 G_PJP_ORGS_HIER   VARCHAR2(200) := FND_PROFILE.VALUE('PJP_ORGANIZATION_HIERARCHY');

PROCEDURE Get_Project_Details
(
    p_project_id            IN              NUMBER,
    x_proj_portfolio        OUT NOCOPY      NUMBER,
    x_proj_pc               OUT NOCOPY      NUMBER,
    x_class_code_id         OUT NOCOPY      NUMBER,
    x_valid_project         OUT NOCOPY      VARCHAR2,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
) IS

 -- standard parameters
  l_return_status          VARCHAR2(1);
  l_api_name               CONSTANT VARCHAR2(30) := 'Get_Project_Details';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_msg_log                VARCHAR2(2000)        := null;
----------------------------------------------------------------------------
  l_org_id                 NUMBER;
  l_validation             BOOLEAN := FALSE;

CURSOR FUNDING_STATUS_CSR
        (P_PROJECT_ID          IN NUMBER) IS
    SELECT
        'T'
    FROM PA_PROJECTS_ALL
    WHERE PROJECT_ID = P_PROJECT_ID
          AND FUNDING_APPROVAL_STATUS_CODE IN
          ('FUNDING_PROPOSED','FUNDING_ONHOLD','FUNDING_APPROVED');

CURSOR HIER_VERSION_CSR IS
    SELECT
    ORG_STRUCTURE_VERSION_ID
    FROM
        PER_ORG_STRUCTURE_VERSIONS
    WHERE
        ORGANIZATION_STRUCTURE_ID = G_PJP_ORGS_HIER
        AND (TRUNC(SYSDATE) BETWEEN TRUNC(DATE_FROM) AND TRUNC(NVL(DATE_TO,
        SYSDATE)));


-- portfolio for submitted project
CURSOR PORTFOLIO_PROJ_CSR
        (P_PROJECT_ID   IN NUMBER,
         P_PJP_ORG_VERSION_ID IN NUMBER) IS
    SELECT
        PTF.PORTFOLIO,
        PAC.CLASS_CODE,
        PTF.PORTFOLIO_ORGANIZATION,
        PA.CARRYING_OUT_ORGANIZATION_ID
    FROM
        PA_PROJECT_CLASSES PAC,
        PA_PROJECTS_ALL PA,
        PA_CLASS_CODES PCC,
        FPA_AW_PORTF_HEADERS_V PTF
    WHERE
        PTF.PORTFOLIO_CLASS_CODE = PCC.CLASS_CODE_ID
        AND PAC.CLASS_CODE       = PCC.CLASS_CODE
        AND PAC.CLASS_CATEGORY   = PCC.CLASS_CATEGORY
        AND PCC.CLASS_CATEGORY   = G_SELECTION_CATEGORY
        AND PAC.PROJECT_ID       = PA.PROJECT_ID
        AND PA.PROJECT_ID        = P_PROJECT_ID
        AND (PTF.PORTFOLIO_ORGANIZATION IS NULL
             OR (PTF.PORTFOLIO_ORGANIZATION IS NOT NULL
             AND  PA.CARRYING_OUT_ORGANIZATION_ID IN
                  (
                    SELECT
                      ORGANIZATION_ID_CHILD
                    FROM
                      PER_ORG_STRUCTURE_ELEMENTS
                    WHERE
                      ORG_STRUCTURE_VERSION_ID = P_PJP_ORG_VERSION_ID
                      CONNECT BY PRIOR ORGANIZATION_ID_CHILD = ORGANIZATION_ID_PARENT
                      AND PRIOR ORG_STRUCTURE_VERSION_ID = P_PJP_ORG_VERSION_ID
                      START WITH ORGANIZATION_ID_PARENT = PTF.PORTFOLIO_ORGANIZATION
                            OR ORGANIZATION_ID_CHILD  = PTF.PORTFOLIO_ORGANIZATION
		    UNION
		     SELECT PTF.PORTFOLIO_ORGANIZATION FROM dual --added for bug 6086945
                   ))); -- IN, OR , AND


-- current planning cycle for portfolio
CURSOR PORTFOLIO_PC_CSR
        (P_PORTFOLIO_ID        IN NUMBER,
         P_PROJECT_ID          IN NUMBER) IS
    SELECT
        PC.PLANNING_CYCLE,
        CC.CLASS_CODE_ID
    FROM
        FPA_AW_PC_INFO_V PC, PA_CLASS_CATEGORIES PCC,
        PA_PROJECT_CLASSES PAC, PA_CLASS_CODES CC
    WHERE
        PC.PC_STATUS IN ('COLLECTING', 'ANALYSIS')
        AND PC.PC_CATEGORY     = PCC.CLASS_CATEGORY_ID
        AND PAC.CLASS_CATEGORY = PCC.CLASS_CATEGORY
        AND PCC.CLASS_CATEGORY = CC.CLASS_CATEGORY
        AND CC.CLASS_CODE      = PAC.CLASS_CODE
        AND PC.PORTFOLIO       = P_PORTFOLIO_ID
        AND PAC.PROJECT_ID     = P_PROJECT_ID;


l_portfolio_id          FPA_AW_PORTF_HEADERS_V.PORTFOLIO%TYPE := null;
l_portfolio_org_id      FPA_AW_PORTF_HEADERS_V.PORTFOLIO_ORGANIZATION%TYPE := null;
l_class_code            PA_CLASS_CODES.CLASS_CODE%TYPE := null;
l_class_code_id         PA_CLASS_CODES.CLASS_CODE_ID%TYPE := null;
l_current_pc_id         FPA_AW_PC_INFO_V.PLANNING_CYCLE%TYPE := null;
l_project_org_id        HR_ALL_ORGANIZATION_UNITS.ORGANIZATION_ID%TYPE := null;
l_pjp_org_version_id    PER_ORG_STRUCTURE_VERSIONS.ORG_STRUCTURE_VERSION_ID%TYPE := null;
l_flag                  VARCHAR2(1) := null;

 BEGIN
    x_valid_project := FND_API.G_FALSE;
    x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

    l_flag := FND_API.G_FALSE;
    open  funding_status_csr(p_project_id);
    fetch funding_status_csr into l_flag;
    close funding_status_csr;

    if(l_flag is null or l_flag <> FND_API.G_TRUE) then
        x_valid_project := FND_API.G_FALSE;
        x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;
        FPA_UTILITIES_PVT.END_ACTIVITY(
                        p_api_name     => l_api_name,
                        p_pkg_name     => G_PKG_NAME,
                        p_msg_log      => null,
                        x_msg_count    => x_msg_count,
                        x_msg_data     => x_msg_data);

        l_validation := Fpa_Validation_Pvt.Add_Validation(
                           'FPA_V_FUNDING_CODE',
                            FPA_VALIDATION_PVT.G_ERROR,
                            p_project_id,
                            'PROJECT');
        if(l_validation = false) then
           return;
        end if;
    end if;

    -- get org version id for the PJP hierarchy org

    if(G_PJP_ORGS_HIER is null) then
        x_valid_project := FND_API.G_FALSE;
        x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;
        FPA_UTILITIES_PVT.END_ACTIVITY(
                        p_api_name     => l_api_name,
                        p_pkg_name     => G_PKG_NAME,
                        p_msg_log      => 'returning: PJP Hierarchy Org not set ',
                        x_msg_count    => x_msg_count,
                        x_msg_data     => x_msg_data);
        l_validation := Fpa_Validation_Pvt.Add_Validation(
                           'FPA_V_PJP_ORG',
                           FPA_VALIDATION_PVT.G_ERROR,
                           null, null);
        if(l_validation) then
           return;
        end if;
    end if;

    open  hier_version_csr;
    fetch hier_version_csr into l_pjp_org_version_id;
    close hier_version_csr;

    open  portfolio_proj_csr(p_project_id, l_pjp_org_version_id);
    fetch portfolio_proj_csr into l_portfolio_id, l_class_code,
                                  l_portfolio_org_id, l_project_org_id;
    close portfolio_proj_csr;

    if(l_portfolio_id is null) then
        x_valid_project := FND_API.G_FALSE;
        x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;
        FPA_UTILITIES_PVT.END_ACTIVITY(
                        p_api_name     => l_api_name,
                        p_pkg_name     => G_PKG_NAME,
                        p_msg_log      => 'returning: no portfolio or class code for '||p_project_id,
                        x_msg_count    => x_msg_count,
                        x_msg_data     => x_msg_data);
        l_validation := Fpa_Validation_Pvt.Add_Validation(
                           'FPA_V_PROJ_PORTFOLIO_CATG',
                            FPA_VALIDATION_PVT.G_ERROR,
                            p_project_id,
                           'PROJECT');
        return;
    end if;

    open  portfolio_pc_csr(l_portfolio_id, p_project_id);
    fetch portfolio_pc_csr into l_current_pc_id, l_class_code_id;
    close portfolio_pc_csr;

    if(l_current_pc_id is null) then
        x_valid_project := FND_API.G_FALSE;
        x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;
        FPA_UTILITIES_PVT.END_ACTIVITY(
                        p_api_name     => l_api_name,
                        p_pkg_name     => G_PKG_NAME,
                        p_msg_log      => 'returning: no planning cycle or pc category for '||l_portfolio_id,
                        x_msg_count    => x_msg_count,
                        x_msg_data     => x_msg_data);
        l_validation := Fpa_Validation_Pvt.Add_Validation(
                           'FPA_V_PROJ_PC_CATG',
                            FPA_VALIDATION_PVT.G_ERROR,
                            p_project_id,
                           'PROJECT');
        if(l_validation = false) then
            return;
        end if;
    end if;

    x_proj_portfolio := l_portfolio_id;
    x_proj_pc        := l_current_pc_id;
    x_class_code_id  := l_class_code_id;
    x_valid_project := FND_API.G_TRUE;
    x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

    FPA_UTILITIES_PVT.END_ACTIVITY(
                    p_api_name     => l_api_name,
                    p_pkg_name     => G_PKG_NAME,
                    p_msg_log      => 'FPA: returning valid project',
                    x_msg_count    => x_msg_count,
                    x_msg_data     => x_msg_data);


EXCEPTION
      when FPA_UTILITIES_PVT.G_EXCEPTION_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            p_msg_log   => l_msg_log||SQLERRM,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

END Get_Project_Details;



FUNCTION Valid_Project(
    p_project_id            IN              NUMBER
) RETURN VARCHAR2 IS

  l_return_status      VARCHAR2(1);
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(4000);

  l_portfolio_id       FPA_AW_PORTF_HEADERS_V.PORTFOLIO%TYPE := null;
  l_current_pc_id      FPA_AW_PC_INFO_V.PLANNING_CYCLE%TYPE  := null;
  l_class_code_id      NUMBER;
  l_valid_project      VARCHAR2(1) := FND_API.G_FALSE;

 BEGIN

    l_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

    Get_Project_Details(
        p_project_id      => p_project_id,
        x_proj_portfolio  => l_portfolio_id,
        x_proj_pc         => l_current_pc_id,
        x_class_code_id   => l_class_code_id,
        x_valid_project   => l_valid_project,
        x_return_status   => l_return_status,
        x_msg_count       => l_msg_count,
        x_msg_data        => l_msg_data);

    if(l_valid_project is null or l_valid_project <> FND_API.G_TRUE) then
        return FND_API.G_FALSE;
    else
        return FND_API.G_TRUE;
    end if;

EXCEPTION
      when OTHERS then
        return FND_API.G_FALSE;
END Valid_Project;

/** Verify_Budget_Versions is used to determine if projects under a given scenario have
    the latest revenue and cost budget data .
    This function is used in two different cases:
    1.  To determine if an individual project under a scenario contains the latest data.
    2.  To determine if a scenario (all projects under the scenario) contains the latest data.
**/

FUNCTION Verify_Budget_Versions(
    p_scenario_id            IN              NUMBER,
    p_project_id             IN              NUMBER
) RETURN VARCHAR2 IS


  l_cost_version_id           NUMBER;
  l_benefit_version_id        NUMBER;
  l_new_cost_version_id       NUMBER;
  l_new_benefit_version_id    NUMBER;

  TYPE PROJTYPE is RECORD(project_id number);
  TYPE PROJTABLE is TABLE of PROJTYPE;
  new_projs PROJTABLE;

  cursor all_projs is
    select project
      from fpa_aw_proj_info_v
     where scenario = p_scenario_id;

  cursor one_proj is
    select p_project_id
      from dual;

 BEGIN

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_project_pvt.Verify_Budget_Versions.begin',
                     'Entering fpa_project_pvt.Verify_Budget_Versions');
    END IF;


    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_project_pvt.Verify_Budget_Versions.begin',
                     'Parameters are Scenario Id: ' || p_scenario_id ||
                     ' Project Id: ' || p_project_id);
    END IF;

    /** if p_project_id is null then we are querying the entire scenario.
        We need to get all projects under the given scenario.
        We place all projecs into the TABLE type.  **/
    if p_project_id is null then

     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_project_pvt.Verify_Budget_Versions.begin',
                     'About to query and fetch all projects from the scenario.');
     end if;

      open all_projs;
      loop
        fetch all_projs BULK COLLECT into new_projs;
        exit when all_projs%NOTFOUND;
      end loop;
      close all_projs;

     IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_project_pvt.Verify_Budget_Versions.begin',
                     'Done fetching all projects from the scenario.');
      end if;

    /** If p_project_id is not null then we are querying an individual project.
        We plase the value of p_project_id in the TABLE type.  **/
    else

      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_project_pvt.Verify_Budget_Versions.begin',
                     'Fetching single project: ' || p_project_id);
      end if;

      open one_proj;
      fetch one_proj BULK COLLECT into new_projs;
      close one_proj;

      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.fpa_project_pvt.Verify_Budget_Versions.begin',
                     'Done fetching single project: ' || p_project_id);
      end if;


    end if;

    /**  Now we loop over all the members of the TABLE type object.
         For each member (project id) we get ID for cost and revenue plan
         from Projects Foundation and compare against the plan IDs stored
         in Portfolio Analysis.
    **/
    for i in new_projs.first..new_projs.last loop

      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                       'fpa.sql.fpa_project_pvt.Verify_Budget_Versions',
                       'Querying Cost and Benefit Plan IDs.');
      END IF;

       SELECT
           DECODE(C.BUDGET_VERSION_ID,NULL,-1,C.BUDGET_VERSION_ID) COST_BUDGET_VERSN_ID,
           DECODE(B.BUDGET_VERSION_ID,NULL,-1,B.BUDGET_VERSION_ID) BENF_BUDGET_VERSN_ID
       INTO
           L_NEW_COST_VERSION_ID, L_NEW_BENEFIT_VERSION_ID
       FROM
           PA_PROJECTS_ALL P, PA_BUDGET_VERSIONS C, PA_BUDGET_VERSIONS B
       WHERE
           'B' = C.BUDGET_STATUS_CODE (+) AND 'Y' = C.CURRENT_FLAG (+)
           AND fnd_profile.value('PJP_FINANCIAL_PLAN_TYPE_COST') = C.FIN_PLAN_TYPE_ID (+)
           AND 'B' = B.BUDGET_STATUS_CODE (+) AND 'Y' = B.CURRENT_FLAG (+)
           AND fnd_profile.value('PJP_FINANCIAL_PLAN_TYPE_BENEFIT') = B.FIN_PLAN_TYPE_ID (+)
           AND P.PROJECT_ID = C.PROJECT_ID (+) AND P.PROJECT_ID = B.PROJECT_ID (+)
           AND P.PROJECT_ID = new_projs(i).project_id;
--           AND P.PROJECT_ID = P_PROJECT_ID;


      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                       'fpa.sql.fpa_project_pvt.Verify_Budget_Versions',
                       'Querying Validation Lines to get latest pulled Plan Version IDs.');
      END IF;


       SELECT
           C.OBJECT_ID BUDGET_VERSION_COST,
           B.OBJECT_ID BUDGET_VERSION_BENEFIT
       INTO
           L_COST_VERSION_ID, L_BENEFIT_VERSION_ID
       FROM
           FPA_VALIDATION_LINES S,
           FPA_VALIDATION_LINES P,
           FPA_VALIDATION_LINES C,
           FPA_VALIDATION_LINES B
       WHERE
           S.OBJECT_TYPE = 'BUDGET_VERSIONS_SCENARIO'
           AND S.HEADER_ID IS NULL
           AND P.OBJECT_TYPE = 'BUDGET_VERSIONS_PROJ'
           AND P.HEADER_ID = S.VALIDATION_ID
           AND C.OBJECT_TYPE = 'BUDGET_VERSION_COST'
           AND C.HEADER_ID = P.VALIDATION_ID
           AND C.VALIDATION_TYPE = 'FPA_V_PROJ_COST_VERSION'
           AND B.OBJECT_TYPE = 'BUDGET_VERSION_BENEFIT'
           AND B.HEADER_ID = P.VALIDATION_ID
           AND B.VALIDATION_TYPE = 'FPA_V_PROJ_BENEFIT_VERSION'
           AND S.OBJECT_ID = P_SCENARIO_ID
           AND P.OBJECT_ID = new_projs(i).project_id;
--           AND P.OBJECT_ID = P_PROJECT_ID;

      IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                       'fpa.sql.fpa_project_pvt.Verify_Budget_Versions',
                       'After queries values were ' ||
                       ' Cost version id in PJP: ' || l_cost_version_id ||
                       ' Cost version id in PJT: ' || l_new_cost_version_id ||
                       ' Budget version id in PJP: ' || l_benefit_version_id ||
                       ' Budget version id in PJT: ' || l_new_benefit_version_id);
      END IF;

      /** If IDs are not identical then we return a FALSE flag, be it for
          an individual project or for the entire scenario.
      **/
      if(l_cost_version_id <> l_new_cost_version_id or
           l_benefit_version_id <> l_new_benefit_version_id) then
          return FND_API.G_FALSE;
      else
        /** If IDs are identical and querying a single project then we return
            a TRUE flag.
        **/
        if p_project_id is not null then
          return FND_API.G_TRUE;
        /** If IDs are identical and we have verified all projects under the scenario
            contain the latest data, then we return a TRUE fla
        **/
        else
          IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            fnd_log.string(FND_LOG.LEVEL_PROCEDURE,
                           'fpa.sql.fpa_project_pvt.Verify_Budget_Versions',
                           'Project ID is null.  The current value is: ' || new_projs(i).project_id ||
                           ' and the last project is: ' || new_projs(new_projs.last).project_id);
          END IF;

          if new_projs(i).project_id = new_projs(new_projs.last).project_id then
            return FND_API.G_TRUE;
          end if;
        end if;
      end if;

    end loop;

EXCEPTION
      when OTHERS then
        return FND_API.G_FALSE;
END Verify_Budget_Versions;


PROCEDURE Submit_Project_Aw
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                IN              VARCHAR2 := FND_API.G_FALSE,
    p_project_id            IN              NUMBER,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
) IS

 -- standard parameters
  l_return_status          VARCHAR2(1);
  l_api_name               CONSTANT VARCHAR2(30) := 'Submit_project_Aw';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_msg_log                VARCHAR2(2000)        := null;
----------------------------------------------------------------------------

  l_portfolio_id       FPA_AW_PORTF_HEADERS_V.PORTFOLIO%TYPE := null;
  l_current_pc_id      FPA_AW_PC_INFO_V.PLANNING_CYCLE%TYPE := null;
  l_class_code_id      NUMBER;
  l_valid_project      VARCHAR2(1) := FND_API.G_FALSE;

  PROCEDURE save_project
            IS
    BEGIN
        BEGIN
            dbms_aw.execute('MAINTAIN project_d ADD '|| p_project_id );
        EXCEPTION
            WHEN OTHERS THEN
            NULL;
        END;
        dbms_aw.execute('oknullstatus = yes');
        dbms_aw.execute('push portfolio_d');
        dbms_aw.execute('push planning_cycle_d');
        dbms_aw.execute('push project_d');

        dbms_aw.execute('LIMIT project_d   TO '|| p_project_id );
        dbms_aw.execute('class_code_project_r = '||l_class_code_id);
        dbms_aw.execute('portfolio_project_r = '||l_portfolio_id);
        dbms_aw.execute('LIMIT planning_cycle_d TO '|| l_current_pc_id );
        dbms_aw.execute('pc_project_r = planning_cycle_d');

        dbms_aw.execute('pop portfolio_d');
        dbms_aw.execute('pop planning_cycle_d');
        dbms_aw.execute('pop project_d');

        dbms_aw.execute('UPDATE');

    EXCEPTION
        WHEN OTHERS then
            if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.String(
                FND_LOG.LEVEL_PROCEDURE,
                'procedure save_project',
                'exception: '||sqlerrm||p_project_id||','||l_class_code_id||','||l_portfolio_id||','||l_current_pc_id);
            end if;
            raise;
    END save_project;


 BEGIN

    x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;
        -- call START_ACTIVITY to create savepoint, check compatibility
        -- and initialize message list
    x_return_status := FPA_UTILITIES_PVT.START_ACTIVITY(
              p_api_name      => l_api_name,
              p_pkg_name      => G_PKG_NAME,
              p_init_msg_list => p_init_msg_list,
              l_api_version   => l_api_version,
              p_api_version   => p_api_version,
              p_api_type      => G_API_TYPE,
              p_msg_log       => 'Entering Fpa_Project_Load_Pvt.Submit_project_Aw',
              x_return_status => x_return_status);

        -- check if activity started successfully
    if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
         l_msg_log := 'start_activity';
         raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
         l_msg_log := 'start_activity';
         raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
    end if;

    Get_Project_Details(
        p_project_id      => p_project_id,
        x_proj_portfolio  => l_portfolio_id,
        x_proj_pc         => l_current_pc_id,
        x_class_code_id   => l_class_code_id,
        x_valid_project   => l_valid_project,
        x_return_status   => x_return_status,
        x_msg_count       => x_msg_count,
        x_msg_data        => x_msg_data);


    if(l_valid_project is null or l_valid_project <> FND_API.G_TRUE) then
        x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;
        FPA_UTILITIES_PVT.END_ACTIVITY(
                        p_api_name     => l_api_name,
                        p_pkg_name     => G_PKG_NAME,
                        p_msg_log      => 'returning: project not saved '||p_project_id,
                        x_msg_count    => x_msg_count,
                        x_msg_data     => x_msg_data);
        return;
    end if;

    save_project;

    x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

    FPA_UTILITIES_PVT.END_ACTIVITY(
                    p_api_name     => l_api_name,
                    p_pkg_name     => G_PKG_NAME,
                    p_msg_log      => null,
                    x_msg_count    => x_msg_count,
                    x_msg_data     => x_msg_data);


EXCEPTION
      when FPA_UTILITIES_PVT.G_EXCEPTION_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            p_msg_log   => l_msg_log||SQLERRM,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

END Submit_project_Aw;


PROCEDURE Load_Project_Details_Aw
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_type                  IN              VARCHAR2,
    p_scenario_id           IN              NUMBER,
    p_projects              IN              VARCHAR2,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
) IS

 -- standard parameters
  l_return_status          VARCHAR2(1);
  l_api_name               CONSTANT VARCHAR2(30) := 'Load_Project_Details_Aw';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_msg_log                VARCHAR2(2000)        := null;
----------------------------------------------------------------------------
  l_projects               VARCHAR2(2000) := null;

  l_pc_id                  NUMBER;

 BEGIN

    x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;
        -- call START_ACTIVITY to create savepoint, check compatibility
        -- and initialize message list
    x_return_status := FPA_UTILITIES_PVT.START_ACTIVITY(
              p_api_name      => l_api_name,
              p_pkg_name      => G_PKG_NAME,
              p_init_msg_list => p_init_msg_list,
              l_api_version   => l_api_version,
              p_api_version   => p_api_version,
              p_api_type      => G_API_TYPE,
              p_msg_log       => 'Entering Fpa_Project_Load_Pvt.Load_Project_Details_Aw',
              x_return_status => x_return_status);

        -- check if activity started successfully
    if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
         l_msg_log := 'start_activity';
         raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
         l_msg_log := 'start_activity';
         raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
    end if;


    l_projects := p_projects;

    if(l_projects is null) then
        l_projects := 'na';
    else
        l_projects := ''''||l_projects||'''';
    end if;

    if(p_type <> 'REFRESH') then
            dbms_aw.execute('CALL LOAD_BUDGET_FORECAST_PRG('
            ||p_scenario_id||','||l_projects||',''LOAD'''||')');
    end if;

    dbms_aw.execute('CALL LOAD_BUDGET_FORECAST_PRG('
            ||p_scenario_id||','||l_projects||',''COST'''||')');

    dbms_aw.execute('CALL LOAD_BUDGET_FORECAST_PRG('
            ||p_scenario_id||','||l_projects||',''BENEFIT'''||')');

    dbms_aw.execute('CALL LOAD_BUDGET_FORECAST_PRG('
            ||p_scenario_id||','||l_projects||',''SUNK_COST'''||')');

    if(p_type <> 'REFRESH') then

        FPA_SCORECARDS_PVT.Handle_Comments(
                p_api_version         => p_api_version,
                p_init_msg_list       => p_init_msg_list,
                p_scenario_id         => p_scenario_id,
                p_type                => 'PJT',
                p_source_scenario_id  => null,
                p_delete_project_id   => null,
                x_return_status       => x_return_status,
                x_msg_count           => x_msg_count,
                x_msg_data            => x_msg_data);
    end if;

    if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
         l_msg_log := 'unexpected error - load_project_details_aw';
         raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
         l_msg_log := 'error - load_project_details_aw';
         raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
    end if;


     IF (p_projects is null) THEN

         SELECT PLANNING_CYCLE INTO l_pc_id
         FROM FPA_AW_SCES_V WHERE SCENARIO = p_scenario_id;

         IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.STRING
              (
              FND_LOG.LEVEL_PROCEDURE,
              'FPA.SQL.FPA_PROCESS_PVT.Validate',
              'Ending FPA_PROCESS_PVT.Validate.call l_pc_id: '||l_pc_id
              );
         END IF;



         Fpa_Validation_Pvt.Validate (
            p_api_version           => 1.0,
            p_init_msg_list         => 'F',
            p_validation_set        => 'FPA_VALIDATION_TYPES',
            p_header_object_id      => l_pc_id,
            p_header_object_type    => 'PLANNING_CYCLE',
            x_return_status         => x_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data);


         IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.STRING
              (
              FND_LOG.LEVEL_PROCEDURE,
              'FPA.SQL.FPA_PROCESS_PVT.Validate',
              'Ending FPA_PROCESS_PVT.Validate.end'
              );
         END IF;

        if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
             l_msg_log := 'unexpected error - load_project_details_aw.Validate';
             raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
        elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
             l_msg_log := 'error - load_project_details_aw.Validate';
             raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
        end if;

        Fpa_Validation_Process_Pvt.Budget_Version_Validations(
            p_api_version           =>  1.0,
            p_init_msg_list         =>  'F',
            p_validation_set        =>  'FPA_VALIDATION_TYPES',
            p_header_object_id      =>  l_pc_id,
            p_header_object_type    =>  'PLANNING_CYCLE',
            x_return_status         =>  x_return_status,
            x_msg_count             =>  x_msg_count,
            x_msg_data              =>  x_msg_data);

         IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
            FND_LOG.STRING
              (
              FND_LOG.LEVEL_PROCEDURE,
              'fpa.sql.Fpa_Validation_Process_Pvt.Validate_Budget_Versions',
              'End Fpa_Validation_Process_Pvt.Validate_Budget_Versions.end'
              );
         END IF;

        if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
             l_msg_log := 'unexpected error - load_project_details_aw.Validate_Budget_Versions';
             raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
        elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
             l_msg_log := 'error - load_project_details_aw.Validate_Budget_Versions';
             raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
        end if;

     END IF;

     FPA_UTILITIES_PVT.END_ACTIVITY(
                    p_api_name     => l_api_name,
                    p_pkg_name     => G_PKG_NAME,
                    p_msg_log      => null,
                    x_msg_count    => x_msg_count,
                    x_msg_data     => x_msg_data);

EXCEPTION
      when FPA_UTILITIES_PVT.G_EXCEPTION_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR',
            p_msg_log   => l_msg_log,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := FPA_UTILITIES_PVT.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            p_msg_log   => l_msg_log||SQLERRM,
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

END Load_Project_Details_Aw;


-- We need the page_id and the pers function name
-- for a Planning cycle if one existed or
-- provide the default parameters
/*
PROCEDURE get_config_page_attributes
(
    p_planning_cycle_id     IN              NUMBER,
    x_page_id               OUT NOCOPY      NUMBER,
    x_pers_function_name    OUT NOCOPY      VARCHAR2,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
) IS


 CURSOR c_default_attr is
    select page_id, pers_function_name
       from pa_page_layouts
       where page_id = 51;

 CURSOR c_pl_cycle_attr is
    select pap.page_id, obj.pers_function_name
       from pa_page_layouts pap, pa_object_page_layouts obj
       where obj.OBJECT_TYPE = 'PA_PROJECTS'
       and obj.object_id = p_planning_cycle_id
       and pap.page_id = obj.page_id;

 l_default_attr c_default_attr%ROWTYPE;
 l_pl_cycle_attr c_pl_cycle_attr%ROWTYPE;

BEGIN

 open c_pl_cycle_attr; -- If this cursor fetched a row, we pass the object specific data
  fetch c_pl_cycle_attr into l_pl_cycle_attr;
  IF c_pl_cycle_attr%FOUND then
    x_page_id  := l_pl_cycle_attr.page_id;
    x_pers_function_name  := l_pl_cycle_attr.pers_function_name;
   ELSE
    -- Default Attributes
    open c_default_attr;
     fetch c_default_attr into l_default_attr;
     x_page_id  := l_default_attr.page_id;
     x_pers_function_name  := l_default_attr.pers_function_name;
    CLOSE c_default_attr;
  END IF;
 CLOSE c_pl_cycle_attr;


END get_config_page_attributes;
*/

-- We need the page_id
-- for a Planning cycle if one existed or
-- provide the default parameters

FUNCTION get_config_page_id
(
    p_planning_cycle_id     IN              NUMBER
)
RETURN NUMBER

IS
 l_page_id NUMBER;
 CURSOR c_pl_cycle_attr is
    select pap.page_id
       from pa_page_layouts pap, pa_object_page_layouts obj
       where obj.OBJECT_TYPE = 'PA_PROJECTS'
       and obj.object_id = p_planning_cycle_id
       and pap.page_id = obj.page_id;

 l_pl_cycle_attr c_pl_cycle_attr%ROWTYPE;

BEGIN

 OPEN c_pl_cycle_attr; -- If this cursor fetched a row, we pass the object specific data
  FETCH c_pl_cycle_attr INTO l_pl_cycle_attr;
  IF c_pl_cycle_attr%FOUND THEN
    l_page_id  := l_pl_cycle_attr.page_id;

  ELSE
    -- Default Attibutes
      l_page_id  := 51;

  END IF;
 CLOSE c_pl_cycle_attr;

RETURN l_page_id;
END get_config_page_id;

-- We need the pers function name
-- for a Planning cycle if one existed or
-- provide the default parameters

FUNCTION get_config_page_function
(
    p_planning_cycle_id     IN              NUMBER
)
RETURN VARCHAR2
IS

 l_pers_function_name VARCHAR2(50);

 CURSOR c_default_attr is
    select page_id, pers_function_name
       from pa_page_layouts
       where page_id = 51;

 CURSOR c_pl_cycle_attr is
    select pap.page_id, obj.pers_function_name
       from pa_page_layouts pap, pa_object_page_layouts obj
       where obj.OBJECT_TYPE = 'PA_PROJECTS'
       and obj.object_id = p_planning_cycle_id
       and pap.page_id = obj.page_id;

 l_default_attr c_default_attr%ROWTYPE;
 l_pl_cycle_attr c_pl_cycle_attr%ROWTYPE;

BEGIN

 OPEN c_pl_cycle_attr; -- If this cursor fetched a row, we pass the object specific data
  FETCH c_pl_cycle_attr INTO l_pl_cycle_attr;
  IF c_pl_cycle_attr%FOUND THEN
    l_pers_function_name  := l_pl_cycle_attr.pers_function_name;
   ELSE
    -- Default Attributes
    OPEN c_default_attr;
     FETCH c_default_attr INTO l_default_attr;
     l_pers_function_name  := l_default_attr.pers_function_name;
    CLOSE c_default_attr;
  END IF;
 CLOSE c_pl_cycle_attr;

 RETURN l_pers_function_name;

END get_config_page_function;


PROCEDURE UPDATE_PROJ_FUNDING_STATUS
(   p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2,
    p_commit                IN              VARCHAR2,
    p_appr_scenario_id           IN              NUMBER,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2) IS

    cursor c_approved_projects IS
     select ppa.rowid, project_id, recommended_funding_status
       from pa_projects_all ppa, fpa_aw_proj_info_v sceproj
       where scenario = p_appr_scenario_id and sceproj.project = ppa.project_id;
       ----------------------------------------------------
       -- Bug Reference :6622099, The For Update clause
       -- is used if its referenced inside Current of clause
       -- of UPDATE or DELETE Statement.This was causing
       -- error in 64 Bit DB
       ----------------------------------------------------
       --for update of funding_approval_status_code nowait;

    l_approved_projects c_approved_projects%ROWTYPE;
    l_msg_count NUMBER;

   BEGIN

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_PROJECT_PVT.UPDATE_PROJ_FUNDING_STATUS.begin',
            'Entering FPA_PROJECT_PVT.UPDATE_PROJ_FUNDING_STATUS'
        );
    END IF;


    BEGIN
      -- Select projects from Approved scenario
      OPEN c_approved_projects;
      LOOP

        FETCH c_approved_projects into l_approved_projects;

        EXIT WHEN c_approved_projects%NOTFOUND;

        UPDATE PA_PROJECTS_ALL
          SET FUNDING_APPROVAL_STATUS_CODE = l_approved_projects.recommended_funding_status
          WHERE ROWID = l_approved_projects.rowid;
          --WHERE project_id = l_approved_projects.project;

       END LOOP;
       CLOSE c_approved_projects;

       EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 FPA_UTILITIES_PVT.SET_MESSAGE( p_app_name => 'PA',
                                        p_msg_name          => 'PA_XC_RECORD_CHANGED');
                 x_msg_data := 'PA_XC_RECORD_CHANGED';

            WHEN TIMEOUT_ON_RESOURCE THEN
                 FPA_UTILITIES_PVT.SET_MESSAGE( p_app_name => 'PA',
                                        p_msg_name          => 'PA_XC_ROW_ALREADY_LOCKED');
                 x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                 x_return_status := 'E' ;

            WHEN OTHERS THEN
              IF SQLCODE = -54 THEN
                 FPA_UTILITIES_PVT.SET_MESSAGE( p_app_name => 'PA',
                                        p_msg_name          => 'PA_XC_ROW_ALREADY_LOCKED');
                 x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
              END IF;

       END;


       l_msg_count := FND_MSG_PUB.count_msg;
       IF l_msg_count > 0 THEN
         x_msg_count := l_msg_count;
         x_return_status := 'E';
         RAISE  FND_API.G_EXC_ERROR;
       END IF;

       IF p_commit = FND_API.G_TRUE then
         COMMIT;
       END IF;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
        FND_LOG.String
        (
            FND_LOG.LEVEL_PROCEDURE,
            'fpa.sql.FPA_PROJECT_PVT.UPDATE_PROJ_FUNDING_STATUS.end',
            'Entering FPA_PROJECT_PVT.UPDATE_PROJ_FUNDING_STATUS'
        );
    END IF;


   EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'FPA_PROJECT_PVT',
                            p_procedure_name => 'UPDATE_PROJ_FUNDING_STATUS',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

      fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                p_data  => x_msg_data);

      IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK;
      END IF;

      raise;

     WHEN FND_API.G_EXC_ERROR THEN
      IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK;
      END IF;
      x_return_status := 'E';

    WHEN OTHERS THEN
      IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'FPA_PROJECT_PVT',
                            p_procedure_name => 'UPDATE_PROJ_FUNDING_STATUS',
                            p_error_text     => SUBSTRB(SQLERRM,1,240));

     RAISE;

   END UPDATE_PROJ_FUNDING_STATUS;


END FPA_PROJECT_PVT;

/
