--------------------------------------------------------
--  DDL for Package Body FPA_VALIDATION_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FPA_VALIDATION_PROCESS_PVT" as
 /* $Header: FPAVVLPB.pls 120.9.12010000.5 2008/10/21 12:12:26 jcgeorge ship $ */

 G_PKG_NAME    CONSTANT VARCHAR2(200) := 'FPA_VALIDATION_PROCESS_PVT';
 G_APP_NAME    CONSTANT VARCHAR2(3)   :=  FPA_UTILITIES_PVT.G_APP_NAME;
 G_API_TYPE    CONSTANT VARCHAR2(4)   := '_PVT';
 L_API_NAME    CONSTANT VARCHAR2(35)  := 'VALIDATION_PROCESS';

PROCEDURE Validate_Project_Details
(
    p_validation_set        IN              VARCHAR2,
    p_header_object_id      IN              NUMBER,
    p_header_object_type    IN              VARCHAR2,
    p_object_id             IN              NUMBER,
    p_object_type           IN              VARCHAR2,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
) IS

 -- standard parameters
  l_return_status          VARCHAR2(1);
  l_api_name               CONSTANT VARCHAR2(30) := 'Validate_Projects_Details';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_msg_log                VARCHAR2(2000)        := null;
----------------------------------------------------------------------------

CURSOR FUNDING_DATES_CSR (PC_ID IN NUMBER) IS
  SELECT GLS.START_DATE,
         GLE.END_DATE
  FROM FPA_AW_PC_INFO_V PC, GL_PERIODS GLS, GL_PERIODS GLE
  WHERE PC.CALENDAR_NAME = GLS.PERIOD_SET_NAME
        AND PC.PERIOD_TYPE = GLS.PERIOD_TYPE
        AND PC.CALENDAR_NAME = GLE.PERIOD_SET_NAME
        AND PC.PERIOD_TYPE = GLE.PERIOD_TYPE
        AND PC.FUNDING_PERIOD_FROM = GLS.PERIOD_NAME
        AND PC.FUNDING_PERIOD_TO   = GLE.PERIOD_NAME
        AND PC.PLANNING_CYCLE = PC_ID;


CURSOR FIN_PLANS_CSR (P_PROJECT_ID IN NUMBER,
                      P_PLAN_TYPE  IN NUMBER,
                      P_START_DATE IN DATE,
                      P_END_DATE   IN DATE) IS
 SELECT 'T'
 FROM PA_PROJECTS_ALL P, PA_BUDGET_VERSIONS V,
      PA_BUDGET_LINES L
 WHERE
  V.BUDGET_VERSION_ID       =  L.BUDGET_VERSION_ID
  AND V.BUDGET_STATUS_CODE  =  'B'
  AND V.CURRENT_FLAG        =  'Y'
  AND V.PROJECT_ID          =  P.PROJECT_ID
  AND P.PROJECT_ID          =  P_PROJECT_ID
  AND V.FIN_PLAN_TYPE_ID    =  P_PLAN_TYPE
  AND ((P_START_DATE BETWEEN L.START_DATE  AND L.END_DATE)
  OR (P_END_DATE BETWEEN L.START_DATE AND L.END_DATE));


 l_start_date          DATE         := NULL;
 l_end_date            DATE         := NULL;
 l_cost_plan_type      NUMBER       := NULL;
 l_benefit_plan_type   NUMBER       := NULL;
 l_validation          BOOLEAN      := NULL;
 l_exists              VARCHAR2(1)  := NULL;

 BEGIN

    x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

    select
    fnd_profile.value('PJP_FINANCIAL_PLAN_TYPE_COST'),
    fnd_profile.value('PJP_FINANCIAL_PLAN_TYPE_BENEFIT')
    into l_cost_plan_type, l_benefit_plan_type from dual;
    if(l_cost_plan_type is null or l_benefit_plan_type is null) then
        return;
    end if;

    open  funding_dates_csr(pc_id => p_header_object_id);
    fetch funding_dates_csr into l_start_date, l_end_date;
    close funding_dates_csr;


    if(l_start_date is null or l_end_date is null) then
        return;
    end if;

    open  fin_plans_csr(p_project_id => p_object_id,
                        p_plan_type  => l_cost_plan_type,
                        p_start_date => l_start_date,
                        p_end_date   => l_end_date);
    fetch fin_plans_csr into l_exists;
    close fin_plans_csr;

    if(l_exists is null or l_exists <> FND_API.G_TRUE) then
        l_validation := Fpa_Validation_Pvt.Add_Validation(
                           'FPA_V_PROJ_COST_PTYPE',
                            FPA_VALIDATION_PVT.G_WARNING,
                            p_object_id, 'PROJECT');
    end if;

    l_exists := null;
    open  fin_plans_csr(p_project_id => p_object_id,
                        p_plan_type  => l_benefit_plan_type,
                        p_start_date => l_start_date,
                        p_end_date   => l_end_date);
    fetch fin_plans_csr into l_exists;

    close  fin_plans_csr;
    if(l_exists is null or l_exists <> FND_API.G_TRUE) then
        l_validation := Fpa_Validation_Pvt.Add_Validation(
                           'FPA_V_PROJ_BENF_PTYPE',
                            FPA_VALIDATION_PVT.G_WARNING,
                            p_object_id, 'PROJECT');
    end if;

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

END Validate_Project_Details;


PROCEDURE Create_Proj_Budget_Versions
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2,
    p_validation_set        IN              VARCHAR2,
    p_scen_vline_id         IN              NUMBER,
    p_project_id            IN              NUMBER,
    p_cost_bversion_id      IN              NUMBER,
    p_benefit_bversion_id   IN              NUMBER,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
) IS

  -- standard parameters
  l_return_status          VARCHAR2(1);
  l_init_msg_list          VARCHAR2(1)           := 'F';
  l_api_name               CONSTANT VARCHAR2(30) := 'Create_Proj_Budget_Versions';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_msg_log                VARCHAR2(2000)        := null;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);
  ----------------------------------------------------------------------------

 L_VALIDATION_LINES_REC FPA_VALIDATION_PVT.FPA_VALIDATION_LINES_REC;
 L_PROJ_VALIDATION_ID   NUMBER;

 L_COST_VLINE_ID           NUMBER;
 L_BENEFIT_VLINE_ID        NUMBER;


 BEGIN

    x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

    BEGIN
         SELECT
             C.VALIDATION_ID,
             B.VALIDATION_ID
         INTO
             L_COST_VLINE_ID, L_BENEFIT_VLINE_ID
         FROM
             FPA_VALIDATION_LINES S,
             FPA_VALIDATION_LINES P,
             FPA_VALIDATION_LINES C,
             FPA_VALIDATION_LINES B
         WHERE
             S.VALIDATION_ID = P_SCEN_VLINE_ID
             AND P.OBJECT_TYPE = 'BUDGET_VERSIONS_PROJ'
             AND P.HEADER_ID = S.VALIDATION_ID
             AND C.OBJECT_TYPE = 'BUDGET_VERSION_COST'
             AND C.HEADER_ID = P.VALIDATION_ID
             AND C.VALIDATION_TYPE = 'FPA_V_PROJ_COST_VERSION'
             AND B.OBJECT_TYPE = 'BUDGET_VERSION_BENEFIT'
             AND B.HEADER_ID = P.VALIDATION_ID
             AND B.VALIDATION_TYPE = 'FPA_V_PROJ_BENEFIT_VERSION'
             AND P.OBJECT_ID = P_PROJECT_ID;

        DELETE FROM FPA_VALIDATION_LINES
        WHERE VALIDATION_ID IN (L_COST_VLINE_ID, L_BENEFIT_VLINE_ID);

    EXCEPTION
        WHEN OTHERS THEN
            NULL;
    END;

    l_validation_lines_rec := null;
    l_validation_lines_rec.header_id        := p_scen_vline_id;
    l_validation_lines_rec.object_id        := p_project_id;
    l_validation_lines_rec.object_type      := 'BUDGET_VERSIONS_PROJ';
    l_validation_lines_rec.validation_type  := p_validation_set;
    l_validation_lines_rec.message_id       := null;
    l_validation_lines_rec.severity         := 'I';

    Fpa_Validation_Pvt.Create_Validation_Line(
           p_api_version          => l_api_version,
           p_init_msg_list        => l_init_msg_list,
           p_validation_set       => p_validation_set,
           p_validation_lines_rec => l_validation_lines_rec,
           x_validation_id        => l_proj_validation_id,
           x_return_status        => l_return_status,
           x_msg_count            => l_msg_count,
           x_msg_data             => l_msg_data);

    if (l_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
         l_msg_log := 'BUDGET_VERSIONS_PROJ-Create_Validation_Line';
         raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
         l_msg_log := 'BUDGET_VERSIONS_PROJ-Create_Validation_Line';
         raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
    end if;

        l_validation_lines_rec := null;
        l_validation_lines_rec.header_id        := l_proj_validation_id;
        l_validation_lines_rec.object_id        := p_cost_bversion_id;
        l_validation_lines_rec.object_type      := 'BUDGET_VERSION_COST';
        l_validation_lines_rec.validation_type  := 'FPA_V_PROJ_COST_VERSION';
        l_validation_lines_rec.message_id       := 'FPA_V_PROJ_COST_VERSION';
        l_validation_lines_rec.severity         := 'I';

        Fpa_Validation_Pvt.Create_Validation_Line(
               p_api_version          => l_api_version,
               p_init_msg_list        => l_init_msg_list,
               p_validation_set       => p_validation_set,
               p_validation_lines_rec => l_validation_lines_rec,
               x_validation_id        => l_validation_lines_rec.validation_id,
               x_return_status        => l_return_status,
               x_msg_count            => l_msg_count,
               x_msg_data             => l_msg_data);

        if (l_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
             l_msg_log := 'BUDGET_VERSION_COST-Create_Validation_Line';
             raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
        elsif (l_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
             l_msg_log := 'BUDGET_VERSION_COST-Create_Validation_Line';
             raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
        end if;

        l_validation_lines_rec := null;
        l_validation_lines_rec.header_id        := l_proj_validation_id;
        l_validation_lines_rec.object_id        := p_benefit_bversion_id;
        l_validation_lines_rec.object_type      := 'BUDGET_VERSION_BENEFIT';
        l_validation_lines_rec.validation_type  := 'FPA_V_PROJ_BENEFIT_VERSION';
        l_validation_lines_rec.message_id       := 'FPA_V_PROJ_BENEFIT_VERSION';
        l_validation_lines_rec.severity         := 'I';

        Fpa_Validation_Pvt.Create_Validation_Line(
               p_api_version          => l_api_version,
               p_init_msg_list        => l_init_msg_list,
               p_validation_set       => p_validation_set,
               p_validation_lines_rec => l_validation_lines_rec,
               x_validation_id        => l_validation_lines_rec.validation_id,
               x_return_status        => l_return_status,
               x_msg_count            => l_msg_count,
               x_msg_data             => l_msg_data);

        if (l_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
             l_msg_log := 'BUDGET_VERSION_BENEFIT-Create_Validation_Line';
             raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
        elsif (l_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
             l_msg_log := 'BUDGET_VERSION_BENEFIT-Create_Validation_Line';
             raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
        end if;

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

END Create_Proj_Budget_Versions;


PROCEDURE Update_Proj_Budget_Versions
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2,
    p_validation_set        IN              VARCHAR2,
    p_scen_vline_id         IN              NUMBER,
    p_project_id            IN              NUMBER,
    p_cost_bversion_id      IN              NUMBER,
    p_benefit_bversion_id   IN              NUMBER,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
) IS

  -- standard parameters
  l_return_status          VARCHAR2(1);
  l_init_msg_list          VARCHAR2(1)           := 'F';
  l_api_name               CONSTANT VARCHAR2(30) := 'Update_Proj_Budget_Versions';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_msg_log                VARCHAR2(2000)        := null;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);
  ----------------------------------------------------------------------------

 L_COST_VLINE_ID           NUMBER;
 L_BENEFIT_VLINE_ID        NUMBER;

 BEGIN

    x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

     SELECT
         C.VALIDATION_ID,
         B.VALIDATION_ID
     INTO
         L_COST_VLINE_ID, L_BENEFIT_VLINE_ID
     FROM
         FPA_VALIDATION_LINES S,
         FPA_VALIDATION_LINES P,
         FPA_VALIDATION_LINES C,
         FPA_VALIDATION_LINES B
     WHERE
         S.VALIDATION_ID = P_SCEN_VLINE_ID
         AND P.OBJECT_TYPE = 'BUDGET_VERSIONS_PROJ'
         AND P.HEADER_ID = S.VALIDATION_ID
         AND C.OBJECT_TYPE = 'BUDGET_VERSION_COST'
         AND C.HEADER_ID = P.VALIDATION_ID
         AND C.VALIDATION_TYPE = 'FPA_V_PROJ_COST_VERSION'
         AND B.OBJECT_TYPE = 'BUDGET_VERSION_BENEFIT'
         AND B.HEADER_ID = P.VALIDATION_ID
         AND B.VALIDATION_TYPE = 'FPA_V_PROJ_BENEFIT_VERSION'
         AND P.OBJECT_ID = P_PROJECT_ID;

    UPDATE
        FPA_VALIDATION_LINES
    SET
        OBJECT_ID          = P_COST_BVERSION_ID,
        LAST_UPDATED_BY    = FND_GLOBAL.USER_ID,
        LAST_UPDATE_DATE   = SYSDATE,
        LAST_UPDATE_LOGIN  = FND_GLOBAL.LOGIN_ID
    WHERE
        VALIDATION_ID = L_COST_VLINE_ID;

    UPDATE
        FPA_VALIDATION_LINES
    SET
        OBJECT_ID          = P_BENEFIT_BVERSION_ID,
        LAST_UPDATED_BY    = FND_GLOBAL.USER_ID,
        LAST_UPDATE_DATE   = SYSDATE,
        LAST_UPDATE_LOGIN  = FND_GLOBAL.LOGIN_ID
    WHERE
        VALIDATION_ID = L_BENEFIT_VLINE_ID;

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

END Update_Proj_Budget_Versions;



PROCEDURE Budget_Version_Validations
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2,
    p_validation_set        IN              VARCHAR2,
    p_header_object_id      IN              NUMBER,
    p_header_object_type    IN              VARCHAR2,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
) IS

  -- standard parameters
  l_return_status          VARCHAR2(1);
  l_init_msg_list          VARCHAR2(1)           := 'F';
  l_api_name               CONSTANT VARCHAR2(30) := 'Budget_Version_Validations';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_msg_log                VARCHAR2(2000)        := null;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);
  ----------------------------------------------------------------------------


 CURSOR BUDGET_VERS_CSR (P_SCENARIO_ID      IN NUMBER) IS
  SELECT
      S.PROJECT PROJECT,
      DECODE(C.BUDGET_VERSION_ID,NULL,-1,C.BUDGET_VERSION_ID) COST_BUDGET_VERSN_ID,
      DECODE(B.BUDGET_VERSION_ID,NULL,-1,B.BUDGET_VERSION_ID) BENF_BUDGET_VERSN_ID
  FROM
      PA_BUDGET_VERSIONS C, PA_BUDGET_VERSIONS B,
      FPA_AW_PROJ_INFO_V S
  WHERE
      'B' = C.BUDGET_STATUS_CODE (+) AND 'Y' = C.CURRENT_FLAG (+)
      AND FND_PROFILE.value('PJP_FINANCIAL_PLAN_TYPE_COST') = C.FIN_PLAN_TYPE_ID (+)
      AND S.PROJECT = C.PROJECT_ID (+)
      AND 'B' = B.BUDGET_STATUS_CODE (+) AND 'Y' = B.CURRENT_FLAG (+)
      AND FND_PROFILE.value('PJP_FINANCIAL_PLAN_TYPE_BENEFIT') = B.FIN_PLAN_TYPE_ID (+)
      AND S.PROJECT = B.PROJECT_ID (+)
      AND S.SCENARIO = P_SCENARIO_ID;

 L_PC_ID               NUMBER       := NULL;
 L_SCENARIO_ID         NUMBER       := NULL;

 BUDGET_VERSIONS_REC    BUDGET_VERS_CSR%ROWTYPE;
 L_VALIDATION_LINES_REC FPA_VALIDATION_PVT.FPA_VALIDATION_LINES_REC;
 L_SCEN_VALIDATION_ID   NUMBER;
 L_PROJ_VALIDATION_ID   NUMBER;

 BEGIN

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string ( FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.FPA_VALIDATION_PROCESS_PVT.Budget_Version_Validations 1.begin',
                     'Entering FPA_VALIDATION_PROCESS_PVT.Budget_Version_Validations 1.');
   END IF;

    dbms_aw.execute('ALLSTAT');
    x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

    if(p_header_object_type = 'SCENARIO') then
        l_scenario_id := p_header_object_id;
    else
        SELECT SCENARIO  INTO L_SCENARIO_ID
        FROM FPA_AW_SCE_INFO_V
        WHERE IS_INITIAL_SCENARIO = 1 AND PLANNING_CYCLE = P_HEADER_OBJECT_ID;

    end if;

    l_validation_lines_rec := null;
    l_validation_lines_rec.header_id        := null;
    l_validation_lines_rec.object_id        := l_scenario_id;
    l_validation_lines_rec.object_type      := 'BUDGET_VERSIONS_SCENARIO';
    l_validation_lines_rec.validation_type  := p_validation_set;
    l_validation_lines_rec.message_id       := null;
    l_validation_lines_rec.severity         := 'I';

    Fpa_Validation_Pvt.Create_Validation_Line(
           p_api_version          => l_api_version,
           p_init_msg_list        => l_init_msg_list,
           p_validation_set       => p_validation_set,
           p_validation_lines_rec => l_validation_lines_rec,
           x_validation_id        => l_scen_validation_id,
           x_return_status        => l_return_status,
           x_msg_count            => l_msg_count,
           x_msg_data             => l_msg_data);

    if (l_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
         l_msg_log := 'BUDGET_VERSIONS_SCENARIO-Create_Validation_Line';
         raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (l_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
         l_msg_log := 'BUDGET_VERSIONS_SCENARIO-Create_Validation_Line';
         raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
    end if;



    FOR budget_versions_rec in budget_vers_csr(l_scenario_id) LOOP

            Create_Proj_Budget_Versions(
                p_api_version          => l_api_version,
                p_init_msg_list        => l_init_msg_list,
                p_validation_set       => p_validation_set,
                p_scen_vline_id        => l_scen_validation_id,
                p_project_id           => budget_versions_rec.project,
                p_cost_bversion_id     => budget_versions_rec.cost_budget_versn_id,
                p_benefit_bversion_id  => budget_versions_rec.benf_budget_versn_id,
                x_return_status        => l_return_status,
                x_msg_count            => l_msg_count,
                x_msg_data             => l_msg_data);

            if (l_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
                 l_msg_log := 'BUDGET_VERSIONS_PROJ-Create_Validation_Line';
                 raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
            elsif (l_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
                 l_msg_log := 'BUDGET_VERSIONS_PROJ-Create_Validation_Line';
                 raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
            end if;

    END LOOP;

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

END Budget_Version_Validations;


PROCEDURE Budget_Version_Validations
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2,
    p_validation_set        IN              VARCHAR2,
    p_header_object_id      IN              NUMBER,
    p_header_object_type    IN              VARCHAR2,
    p_line_projects_tbl     IN              PROJECT_ID_TBL_TYPE,
    p_type                  IN              VARCHAR2,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
) IS

cursor val_lines_csr(sce_id IN NUMBER,
                     validation_set IN VARCHAR2) is
    SELECT VALIDATION_ID
    FROM FPA_VALIDATION_LINES
    WHERE OBJECT_TYPE = 'BUDGET_VERSIONS_SCENARIO' AND
          OBJECT_ID = sce_id AND
          HEADER_ID IS NULL AND
          VALIDATION_TYPE = validation_set;

  -- standard parameters
  l_return_status          VARCHAR2(1);
  l_init_msg_list          VARCHAR2(1)           := 'F';
  l_api_name               CONSTANT VARCHAR2(30) := 'Budget_Version_Validations';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_msg_log                VARCHAR2(2000)        := null;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);
  ----------------------------------------------------------------------------

  TYPE BUDGET_VERS_CSR IS REF CURSOR;
  L_BUDGET_VERS_CSR BUDGET_VERS_CSR;

  I                      NUMBER;
  L_SQL_STR              VARCHAR2(1000);
  L_SCENARIO_ID          NUMBER;
  L_COST_BVERSION_ID     NUMBER;
  L_BENEFIT_BVERSION_ID  NUMBER;
  L_SCEN_VALIDATION_ID   NUMBER;

  l_type		 VARCHAR2(10);

 BEGIN

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string ( FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.FPA_VALIDATION_PROCESS_PVT.Budget_Version_Validations 2.',
                     'Entering FPA_VALIDATION_PROCESS_PVT.Budget_Version_Validations 2.begin');
   END IF;

    l_type := p_type;

    x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

    IF(p_header_object_type = 'SCENARIO') THEN
        l_scenario_id := p_header_object_id;
    ELSE
        SELECT SCENARIO  INTO L_SCENARIO_ID
        FROM FPA_AW_SCE_INFO_V
        WHERE IS_INITIAL_SCENARIO = 1 AND PLANNING_CYCLE = P_HEADER_OBJECT_ID;

    END IF;

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string ( FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.FPA_VALIDATION_PROCESS_PVT.Budget_Version_Validations 2.',
                     'Querying FPA_VALIDATION_LINES to obtain current validation ID.  Values are, scenario id: ' || l_scenario_id || ', Validation Type: ' || p_validation_set);
   END IF;

    -- Bug Reference : 6006705
    -- We need to trap the no data found condition here.
    BEGIN
      open val_lines_csr(sce_id => L_SCENARIO_ID,
                         validation_set => P_VALIDATION_SET);
      fetch val_lines_csr into L_SCEN_VALIDATION_ID;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
         L_SCEN_VALIDATION_ID := 0;
         l_type := 'CREATE';
      WHEN OTHERS THEN
        NULL;
    END;
    close val_lines_csr;

    -- Check value returned from cursor above, if the value is null then this is an upgrade step
    -- and need to default it to a value.
    if L_SCEN_VALIDATION_ID is null then
      L_SCEN_VALIDATION_ID := 0;
      l_type := 'CREATE';
    end if;

/*
    SELECT VALIDATION_ID
    INTO L_SCEN_VALIDATION_ID
    FROM FPA_VALIDATION_LINES
    WHERE OBJECT_TYPE = 'BUDGET_VERSIONS_SCENARIO' AND
          OBJECT_ID = L_SCENARIO_ID AND
          HEADER_ID IS NULL AND
          VALIDATION_TYPE = P_VALIDATION_SET;
*/

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string ( FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.FPA_VALIDATION_PROCESS_PVT.Budget_Version_Validations 2.',
                     'Constructing dynamic SQL to query Budget Version information.');
   END IF;

    l_sql_str := 'SELECT '
              || 'DECODE(C.BUDGET_VERSION_ID,NULL,-1,C.BUDGET_VERSION_ID) COST_BUDGET_VERSN_ID, '
              || 'DECODE(B.BUDGET_VERSION_ID,NULL,-1,B.BUDGET_VERSION_ID) BENF_BUDGET_VERSN_ID '
              || 'FROM  PA_PROJECTS_ALL P, PA_BUDGET_VERSIONS C, PA_BUDGET_VERSIONS B '
              || 'WHERE ''B'' = C.BUDGET_STATUS_CODE (+) AND ''Y'' = C.CURRENT_FLAG  (+) '
              || 'AND fnd_profile.value(''PJP_FINANCIAL_PLAN_TYPE_COST'') = C.FIN_PLAN_TYPE_ID (+) '
              || 'AND ''B'' = B.BUDGET_STATUS_CODE (+) AND ''Y'' = B.CURRENT_FLAG (+) '
              || 'AND fnd_profile.value(''PJP_FINANCIAL_PLAN_TYPE_BENEFIT'') = B.FIN_PLAN_TYPE_ID (+) '
              || 'AND P.PROJECT_ID = C.PROJECT_ID (+) AND P.PROJECT_ID = B.PROJECT_ID (+) '
              || 'AND P.PROJECT_ID = :1';

   IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     fnd_log.string ( FND_LOG.LEVEL_PROCEDURE,
                     'fpa.sql.FPA_VALIDATION_PROCESS_PVT.Budget_Version_Validations 2.',
                     'Entering loop for insert or updates into FPA_VALIDATION_LINES. Operation to be performed is: ' || l_type);
   END IF;


    FOR i IN p_line_projects_tbl.first .. p_line_projects_tbl.last LOOP

        OPEN  l_budget_vers_csr FOR  l_sql_str USING p_line_projects_tbl(i);
        FETCH l_budget_vers_csr INTO l_cost_bversion_id, l_benefit_bversion_id;
        CLOSE l_budget_vers_csr;

        IF(l_type = 'CREATE') THEN

         IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           fnd_log.string ( FND_LOG.LEVEL_PROCEDURE,
                           'fpa.sql.FPA_VALIDATION_PROCESS_PVT.Budget_Version_Validations 2.',
                           'Calling procedure Create_Proj_Budget_Versions.');
         END IF;

            Create_Proj_Budget_Versions(
                p_api_version          => l_api_version,
                p_init_msg_list        => l_init_msg_list,
                p_validation_set       => p_validation_set,
                p_scen_vline_id        => l_scen_validation_id,
                p_project_id           => p_line_projects_tbl(i),
                p_cost_bversion_id     => l_cost_bversion_id,
                p_benefit_bversion_id  => l_benefit_bversion_id,
                x_return_status        => l_return_status,
                x_msg_count            => l_msg_count,
                x_msg_data             => l_msg_data);

        ELSIF(l_type = 'UPDATE') THEN

         IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           fnd_log.string ( FND_LOG.LEVEL_PROCEDURE,
                           'fpa.sql.FPA_VALIDATION_PROCESS_PVT.Budget_Version_Validations 2.',
                           'Calling procedure Update_Proj_Budget_Versions.');
         END IF;

            Update_Proj_Budget_Versions(
                p_api_version          => l_api_version,
                p_init_msg_list        => l_init_msg_list,
                p_validation_set       => p_validation_set,
                p_scen_vline_id        => l_scen_validation_id,
                p_project_id           => p_line_projects_tbl(i),
                p_cost_bversion_id     => l_cost_bversion_id,
                p_benefit_bversion_id  => l_benefit_bversion_id,
                x_return_status        => l_return_status,
                x_msg_count            => l_msg_count,
                x_msg_data             => l_msg_data);

        END IF;

         IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           fnd_log.string ( FND_LOG.LEVEL_PROCEDURE,
                           'fpa.sql.FPA_VALIDATION_PROCESS_PVT.Budget_Version_Validations 2.',
                           'Checking return status inside loop for inserting creating FPA_VALIDATION_LINES.');
         END IF;

        if (l_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
             l_msg_log := 'BUDGET_VERSIONS_PROJ-Create_Validation_Line';
             raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
        elsif (l_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
             l_msg_log := 'BUDGET_VERSIONS_PROJ-Create_Validation_Line';
             raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
        end if;

    END LOOP;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string ( FND_LOG.LEVEL_PROCEDURE,
                      'fpa.sql.FPA_VALIDATION_PROCESS_PVT.Budget_Version_Validations 2.',
                      'Finished loop for inserting updating FPA_VALIDATION_LINES.');
    END IF;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string ( FND_LOG.LEVEL_PROCEDURE,
                      'fpa.sql.FPA_VALIDATION_PROCESS_PVT.Budget_Version_Validations 2.',
                      'Calling FPA_UTILITIES_PVT.G_RET_STS_SUCCESS.');
    END IF;

    x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string ( FND_LOG.LEVEL_PROCEDURE,
                      'fpa.sql.FPA_VALIDATION_PROCESS_PVT.Budget_Version_Validations 2.',
                      'Calling FPA_UTILITIES_PVT.END_ACTIVITY.');
    END IF;

    FPA_UTILITIES_PVT.END_ACTIVITY(
                    p_api_name     => l_api_name,
                    p_pkg_name     => G_PKG_NAME,
                    p_msg_log      => null,
                    x_msg_count    => x_msg_count,
                    x_msg_data     => x_msg_data);

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      fnd_log.string ( FND_LOG.LEVEL_PROCEDURE,
                      'fpa.sql.FPA_VALIDATION_PROCESS_PVT.Budget_Version_Validations 2.end.',
                      'Finishing FPA_VALIDATION_PROCESS_PVT.Budget_Version_Validations 2.');
    END IF;


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

END Budget_Version_Validations;


PROCEDURE Validate_Collect_Projects
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2,
    p_validation_set      IN              VARCHAR2,
    p_header_object_id      IN              NUMBER,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
) IS

 -- standard parameters
  l_return_status          VARCHAR2(1);
  l_api_name               CONSTANT VARCHAR2(30) := 'Validate_Collect_Projects';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_msg_log                VARCHAR2(2000)        := null;
----------------------------------------------------------------------------
--  l_org_id                 NUMBER;
  l_level_error            BOOLEAN := FALSE;

CURSOR COLLECT_PROJECTS_CSR
        (P_PC_ID          IN NUMBER) IS
    SELECT
        PROJECT
    FROM FPA_AW_PROJS_V
    WHERE PLANNING_CYCLE = P_PC_ID;

  l_portfolio_id       FPA_AW_PORTF_HEADERS_V.PORTFOLIO%TYPE := null;
  l_current_pc_id      FPA_AW_PC_INFO_V.PLANNING_CYCLE%TYPE  := null;
  l_class_code_id      NUMBER;
  l_valid_project      VARCHAR2(1) := FND_API.G_FALSE;
  l_validation         BOOLEAN := FALSE;

  collect_projects_rec collect_projects_csr%ROWTYPE;

 BEGIN
    l_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

    FOR collect_projects_rec in collect_projects_csr(p_header_object_id) LOOP

        Fpa_Project_Pvt.Get_Project_Details(
                p_project_id      => collect_projects_rec.project,
                x_proj_portfolio  => l_portfolio_id,
                x_proj_pc         => l_current_pc_id,
                x_class_code_id   => l_class_code_id,
                x_valid_project   => l_valid_project,
                x_return_status   => x_return_status,
                x_msg_count       => x_msg_count,
                x_msg_data        => x_msg_data);

        Validate_Project_Details(
                p_validation_set     => p_validation_set,
                p_header_object_id   => p_header_object_id,
                p_header_object_type => 'PLANNING_CYCLE',
                p_object_id          => collect_projects_rec.project,
                p_object_type        => 'PROJECT',
                x_return_status      => x_return_status,
                x_msg_count          => x_msg_count,
                x_msg_data           => x_msg_data);

        l_level_error := FPA_VALIDATION_PVT.Check_Error_Level(
                                collect_projects_rec.project,
                               'PROJECT',
                                FPA_VALIDATION_PVT.G_ERROR);

        if(not l_level_error) then
            l_validation   := Fpa_Validation_Pvt.Add_Validation(
                             'FPA_V_PROJECT_SUBMITTED',
                              FPA_VALIDATION_PVT.G_INFORMATION,
                              collect_projects_rec.project,
                             'PROJECT');
        end if;

    END LOOP;


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

END Validate_Collect_Projects;


PROCEDURE Validate_Proj_Refresh_Plans
(
    p_project_id            IN              NUMBER,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
) IS

 -- standard parameters
  l_return_status          VARCHAR2(1);
  l_api_name               CONSTANT VARCHAR2(30) := 'Validate_Proj_Refresh_Plans';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_msg_log                VARCHAR2(2000)        := null;
----------------------------------------------------------------------------

CURSOR FIN_PLANS_CSR (P_PROJECT_ID IN NUMBER,
                      P_PLAN_TYPE  IN NUMBER) IS
 SELECT 'T'
 FROM PA_PROJECTS_ALL P, PA_BUDGET_VERSIONS V,
      PA_BUDGET_LINES L
 WHERE
  V.BUDGET_VERSION_ID       =  L.BUDGET_VERSION_ID
  AND V.BUDGET_STATUS_CODE  =  'B'
  AND V.CURRENT_FLAG        =  'Y'
  AND V.PROJECT_ID          =  P.PROJECT_ID
  AND P.PROJECT_ID          =  P_PROJECT_ID
  AND V.FIN_PLAN_TYPE_ID    =  P_PLAN_TYPE;


 l_cost_plan_type      NUMBER       := NULL;
 l_benefit_plan_type   NUMBER       := NULL;
 l_validation          BOOLEAN      := NULL;
 l_exists              VARCHAR2(1)  := NULL;

 BEGIN

    x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

    SELECT
        FND_PROFILE.VALUE('PJP_FINANCIAL_PLAN_TYPE_COST'),
        FND_PROFILE.VALUE('PJP_FINANCIAL_PLAN_TYPE_BENEFIT')
    INTO L_COST_PLAN_TYPE, L_BENEFIT_PLAN_TYPE FROM DUAL;

    if(l_cost_plan_type is null or l_benefit_plan_type is null) then
        return;
    end if;

    open  fin_plans_csr(p_project_id => p_project_id,
                        p_plan_type  => l_cost_plan_type);
    fetch fin_plans_csr into l_exists;
    close fin_plans_csr;

    if(l_exists is null or l_exists <> FND_API.G_TRUE) then
        l_validation := Fpa_Validation_Pvt.Add_Validation(
                           'FPA_V_PROJ_COST_PTYPE',
                            FPA_VALIDATION_PVT.G_WARNING,
                            p_project_id, 'PROJECT');
    end if;

    l_exists := null;
    open  fin_plans_csr(p_project_id => p_project_id,
                        p_plan_type  => l_benefit_plan_type);
    fetch fin_plans_csr into l_exists;

    close  fin_plans_csr;
    if(l_exists is null or l_exists <> FND_API.G_TRUE) then
        l_validation := Fpa_Validation_Pvt.Add_Validation(
                           'FPA_V_PROJ_BENF_PTYPE',
                            FPA_VALIDATION_PVT.G_WARNING,
                            p_project_id, 'PROJECT');
    end if;

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

END Validate_Proj_Refresh_Plans;


PROCEDURE Validate_Project_Refresh
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2,
    p_validation_set        IN              VARCHAR2,
    p_scenario_id           IN              NUMBER,
    p_projects_tbl          IN              PROJECT_ID_TBL_TYPE,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
) IS

 -- standard parameters
  l_return_status          VARCHAR2(1);
  l_api_name               CONSTANT VARCHAR2(30) := 'Validate_Project_Refresh';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_msg_log                VARCHAR2(2000)        := null;
----------------------------------------------------------------------------
--  l_org_id                 NUMBER;
  l_level_error            BOOLEAN := FALSE;


  l_portfolio_id       FPA_AW_PORTF_HEADERS_V.PORTFOLIO%TYPE := null;
  l_current_pc_id      FPA_AW_PC_INFO_V.PLANNING_CYCLE%TYPE  := null;
  l_class_code_id      NUMBER;
  l_pc_id              NUMBER;
  l_valid_project      VARCHAR2(1) := FND_API.G_FALSE;
  l_validation         BOOLEAN := FALSE;
  i                    NUMBER;


 BEGIN
    l_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

    SELECT PLANNING_CYCLE INTO L_PC_ID
    FROM FPA_AW_SCES_V WHERE SCENARIO = P_SCENARIO_ID;

    FOR i IN p_projects_tbl.first .. p_projects_tbl.last
    LOOP

       IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING
        (
        FND_LOG.LEVEL_PROCEDURE,
        'fpa.sql.FPA_VALIDATION_PROCESS_PVT.Validate_Project_Refresh',
        'processing project = '||p_projects_tbl(i)
        );
       END IF;

       Validate_Proj_Refresh_Plans(
                p_project_id         => p_projects_tbl(i),
                x_return_status      => x_return_status,
                x_msg_count          => x_msg_count,
                x_msg_data           => x_msg_data);


    END LOOP;

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

END Validate_Project_Refresh;

PROCEDURE Validate
(
    p_api_version           IN              NUMBER,
    p_init_msg_list         IN              VARCHAR2,
    p_validation_set        IN                VARCHAR2,
    p_header_object_id      IN              NUMBER,
    p_header_object_type    IN              VARCHAR2,
    p_line_projects_tbl     IN              PROJECT_ID_TBL_TYPE,
    x_return_status         OUT NOCOPY      VARCHAR2,
    x_msg_count             OUT NOCOPY      NUMBER,
    x_msg_data              OUT NOCOPY      VARCHAR2
) IS

 -- standard parameters
  l_return_status          VARCHAR2(1);
  l_api_name               CONSTANT VARCHAR2(30) := 'Validate';
  l_api_version            CONSTANT NUMBER       := 1.0;
  l_msg_log                VARCHAR2(2000)        := null;
----------------------------------------------------------------------------

 BEGIN

    x_return_status := FPA_UTILITIES_PVT.G_RET_STS_SUCCESS;

    x_return_status := FPA_UTILITIES_PVT.START_ACTIVITY(
              p_api_name      => l_api_name,
              p_pkg_name      => G_PKG_NAME,
              p_init_msg_list => p_init_msg_list,
              l_api_version   => l_api_version,
              p_api_version   => p_api_version,
              p_api_type      => G_API_TYPE,
              p_msg_log       => 'Entering Fpa_Validation_Process_Pvt.Validate',
              x_return_status => x_return_status);

    if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
         l_msg_log := 'start_activity';
         raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
         l_msg_log := 'start_activity';
         raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
    end if;

    if(p_header_object_type = 'PLANNING_CYCLE') then

        Validate_Collect_Projects(
            p_api_version      => p_api_version,
            p_init_msg_list    => p_init_msg_list,
            p_validation_set   => p_validation_set,
            p_header_object_id => p_header_object_id,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);

    elsif (p_header_object_type = 'SCENARIO') then

        Validate_Project_Refresh(
            p_api_version      => p_api_version,
            p_init_msg_list    => p_init_msg_list,
            p_validation_set   => p_validation_set,
            p_scenario_id      => p_header_object_id,
            p_projects_tbl     => p_line_projects_tbl,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);

    end if;

    if (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_UNEXP_ERROR) then
         l_msg_log := 'Validate_Collect_Projects';
         raise FPA_UTILITIES_PVT.G_EXCEPTION_UNEXPECTED_ERROR;
    elsif (x_return_status = FPA_UTILITIES_PVT.G_RET_STS_ERROR) then
         l_msg_log := 'Validate_Collect_Projects';
         raise FPA_UTILITIES_PVT.G_EXCEPTION_ERROR;
    end if;

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

END Validate;


FUNCTION Object_Name(
   p_object_id      IN  NUMBER,
   p_object_type    IN  VARCHAR2) RETURN VARCHAR2 IS

l_object_name VARCHAR2(200);

BEGIN

    if(p_object_type = 'PROJECT') then
        SELECT NAME INTO L_OBJECT_NAME
        FROM PA_PROJECTS_ALL WHERE PROJECT_ID = P_OBJECT_ID;
    else
        SELECT NAME INTO L_OBJECT_NAME
        FROM FPA_OBJECTS_TL WHERE ID = P_OBJECT_ID
	AND LANGUAGE = USERENV('LANG'); -- Bug Ref # 6327682;
    end if;

    return l_object_name;

EXCEPTION
   WHEN OTHERS THEN
   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
       FND_LOG.String(
               FND_LOG.LEVEL_PROCEDURE,
               'fpa.sql.FPA_VALIDATIONS_PROCESS_PVT.Object_Name',
               'EXCEPTION:'||sqlerrm||p_object_id||','||p_object_type);
    end if;
   return null;
END Object_Name;



END FPA_VALIDATION_PROCESS_PVT;

/
