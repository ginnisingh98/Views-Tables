--------------------------------------------------------
--  DDL for Package Body PA_FORECAST_COST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FORECAST_COST" as
/* $Header: PARFRTCB.pls 120.4 2005/08/19 16:52:15 mwasowic noship $ */


l_exp_func_curr_code_null   EXCEPTION;
l_proj_func_curr_code_null  EXCEPTION;
l_raw_cost_null             EXCEPTION;
l_burden_cost_null          EXCEPTION;
l_x_return_status           VARCHAR2(50);


PROCEDURE Get_Raw_Cost(P_person_id  IN      NUMBER    ,
                       P_expenditure_org_id      IN      NUMBER    ,
                       P_labor_Cost_Mult_Name    IN      VARCHAR2  ,
                       P_Item_date               IN      DATE      ,
                       P_exp_func_curr_code      IN OUT  NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
                       P_Quantity                IN      NUMBER    ,
                       X_Raw_cost_rate           OUT     NOCOPY NUMBER    , --File.Sql.39 bug 4440895
                       X_Raw_cost                OUT     NOCOPY NUMBER    , --File.Sql.39 bug 4440895
                       X_return_status           OUT     NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
                       X_msg_count               OUT     NOCOPY NUMBER    , --File.Sql.39 bug 4440895
                       X_msg_data                OUT     NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
                      )
IS

l_cost_multiplier             pa_labor_cost_multipliers.multiplier%TYPE;
l_labor_cost_rate             pa_compensation_details_all.HOURLY_COST_RATE%TYPE;
l_x_raw_cost                  NUMBER;
l_x_raw_cost_rate             NUMBER;

l_no_labor_cost_rate          EXCEPTION;


l_exp_func_curr_code         varchar2(15);

BEGIN


    /* ATG Changes */

    l_exp_func_curr_code  :=  p_exp_func_curr_code;

     --------------------------------------------
     -- Initialize the successfull return status
     --------------------------------------------

     l_x_return_status := FND_API.G_RET_STS_SUCCESS;



     -----------------------------------------------------------
     -- Get the labor cost rate from pa_compensation_details_all
     -----------------------------------------------------------

     SELECT HOURLY_COST_RATE
       INTO l_labor_cost_rate
       FROM PA_COMPENSATION_DETAILS_ALL CD
      WHERE CD.person_id = P_person_id
        AND CD.org_id = P_expenditure_org_id
        AND P_item_date BETWEEN CD.start_date_active AND NVL(CD.end_date_active,P_item_date);


     -----------------------------------------------------------------------
     -- Get the cost multiplier from pa_labor_cost_multipliers for the given
     -- labor cost multiplier name
     -----------------------------------------------------------------------


    IF  P_labor_Cost_Mult_Name IS NOT NULL THEN


       BEGIN


           SELECT multiplier
             INTO l_cost_multiplier
             FROM PA_LABOR_COST_MULTIPLIERS LCM
            WHERE LCM.LABOR_COST_MULTIPLIER_NAME = P_labor_Cost_Mult_Name
              AND P_item_date BETWEEN LCM.start_date_active AND NVL(LCM.end_date_active,P_item_date);


          EXCEPTION
             WHEN NO_DATA_FOUND THEN
                  l_cost_multiplier := NULL;

       END;


    END IF;



       ----------------------------------------------------------------------
       -- If Input expenditure functional currency code is null then call the
       -- procedure get_curr_code to get the currency code
       ----------------------------------------------------------------------


       IF (p_exp_func_curr_code IS NULL) THEN

           p_exp_func_curr_code := get_curr_code(p_expenditure_org_id);

       END IF;


       IF (p_exp_func_curr_code IS NULL) THEN

           RAISE l_exp_func_curr_code_null;

       END IF;


       ----------------------------------------
       -- Calulating Raw cost and Raw cost rate
       ----------------------------------------

       l_x_raw_cost_rate := l_labor_cost_rate * NVL(l_cost_multiplier,1.0);

       l_x_Raw_cost      := pa_currency.round_trans_currency_amt(
                            l_x_raw_cost_rate * nvl(P_Quantity,0), p_exp_func_curr_code);


       -------------------------------------------------
       -- Checking If Calculated raw cost is null or not
       -------------------------------------------------

       IF (l_x_raw_cost_rate is NULL)  OR  (l_x_raw_cost is NULL) THEN

           Raise l_raw_cost_null;

       END IF;



       ----------------------------------------------------------
       -- Storing Calculated raw cost values into output variable
       ----------------------------------------------------------

       x_raw_cost_rate   := l_x_raw_cost_rate;
       x_raw_cost        := l_x_raw_cost;


       -------------------------------------------------------
       -- Assign the successful status back to output variable
       -------------------------------------------------------

       x_return_status := l_x_return_status;


EXCEPTION
   WHEN l_exp_func_curr_code_null THEN
        PA_UTILS.add_message('PA', 'PA_EXP_FUNC_CURR_CODE_NULL');
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        x_msg_count     :=  1;
        x_msg_data      :=  'PA_EXP_FUNC_CURR_CODE_NULL';

   WHEN NO_DATA_FOUND THEN
        PA_UTILS.add_message('PA', 'PA_NO_LABOR_COST_RATE');
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        x_msg_count     :=  1;
        x_msg_data      :=  'PA_NO_LABOR_COST_RATE';

   WHEN l_raw_cost_null THEN
        PA_UTILS.add_message('PA', 'PA_RAW_COST_NULL');
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        x_msg_count     :=  1;
        x_msg_data      :=  'PA_RAW_COST_NULL';

   WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SQLERRM;

        /* ATG Changes */

          p_exp_func_curr_code  :=  l_exp_func_curr_code;


        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_GET_RAW_BURDEN_COST',
                                 p_procedure_name => 'Get_Raw_Cost');

END Get_Raw_Cost;



PROCEDURE Override_exp_organization(P_item_date                IN  DATE      ,
                           P_person_id                         IN  NUMBER    ,
                           P_project_id                        IN  NUMBER    ,
                           P_incurred_by_organz_id             IN  NUMBER    ,
                           P_Expenditure_type                  IN  VARCHAR2  ,
                           X_overr_to_organization_id          OUT NOCOPY NUMBER    ,                                 --File.Sql.39 bug 4440895
                           X_return_status                     OUT NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
                           X_msg_count                         OUT NOCOPY NUMBER    , --File.Sql.39 bug 4440895
                           X_msg_data                          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                          )
IS


l_x_override_to_org_id         NUMBER;
l_override_organz_id_null      EXCEPTION;


BEGIN


     --------------------------------------------
     -- Initialize the successfull return status
     --------------------------------------------

     l_x_return_status := FND_API.G_RET_STS_SUCCESS;



     l_x_override_to_org_id := NULL;


     BEGIN

      -------------------------------------------------------------
      -- Organization overrides for person and expenditure_category
      -------------------------------------------------------------


      SELECT OVERRIDE_TO_ORGANIZATION_ID
        INTO l_x_override_to_org_id
        FROM pa_cost_dist_overrides CDO,
             pa_expenditure_types   ET
       WHERE P_item_date between CDO.start_date_active and nvl(CDO.end_date_active, p_item_date)
         AND CDO.person_id   = P_person_id
         AND CDO.project_id  = P_project_id
         AND CDO.expenditure_category = ET.expenditure_category
         AND ET.expenditure_type      = P_expenditure_type;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
             l_x_override_to_org_id := NULL;


     END;



     IF l_x_override_to_org_id IS NULL THEN

        BEGIN

          -----------------------------------------
          -- Organization overrides for person only
          -----------------------------------------


          SELECT OVERRIDE_TO_ORGANIZATION_ID
            INTO l_x_override_to_org_id
            FROM pa_cost_dist_overrides CDO,
                 pa_expenditure_types   ET
           WHERE P_item_date between CDO.start_date_active and nvl(CDO.end_date_active, p_item_date)
             AND CDO.person_id   = P_person_id
             AND CDO.project_id  = P_project_id
             AND CDO.expenditure_category IS NULL;

           EXCEPTION
             WHEN NO_DATA_FOUND THEN
                  l_x_override_to_org_id := NULL;

        END;

     END IF;



      IF l_x_override_to_org_id IS NULL THEN

        BEGIN


          ----------------------------------------------------------------------
          -- Organization overrides for organization id and expenditure_category
          ----------------------------------------------------------------------


          SELECT OVERRIDE_TO_ORGANIZATION_ID
            INTO l_x_override_to_org_id
            FROM pa_cost_dist_overrides CDO,
                 pa_expenditure_types   ET
           WHERE P_item_date between CDO.start_date_active and nvl(CDO.end_date_active, p_item_date)
             AND CDO.project_id  = P_project_id
             AND CDO.override_from_organization_id = P_incurred_by_organz_id
             AND CDO.expenditure_category = ET.expenditure_category
             AND ET.expenditure_type      = P_expenditure_type;

          EXCEPTION
              WHEN NO_DATA_FOUND THEN
                   l_x_override_to_org_id := NULL;

         END;

      END IF;




     IF l_x_override_to_org_id IS NULL THEN

       BEGIN



        -----------------------------------------------
        -- Organization overrides for organization only
        -----------------------------------------------


        SELECT OVERRIDE_TO_ORGANIZATION_ID
          INTO l_x_override_to_org_id
          FROM pa_cost_dist_overrides CDO,
               pa_expenditure_types   ET
         WHERE P_item_date between CDO.start_date_active and nvl(CDO.end_date_active, p_item_date)
           AND CDO.project_id  = P_project_id
           AND CDO.override_from_organization_id = P_incurred_by_organz_id
           AND CDO.expenditure_category is NULL;

         EXCEPTION
              WHEN NO_DATA_FOUND THEN
                   l_x_override_to_org_id := NULL;

        END;

     END IF;



     --------------------------------------------------------------
     -- Raise the exception, If override to organization Id is null
     --------------------------------------------------------------

     IF (l_x_override_to_org_id IS NULL) THEN

         RAISE l_override_organz_id_null;

     END IF;


     ----------------------------------------------------
     --Assign override to org Id into the output variable
     ----------------------------------------------------

     x_overr_to_organization_id  := l_x_override_to_org_id;


     -------------------------------------------------------
     -- Assign the successful status back to output variable
     -------------------------------------------------------

     x_return_status := l_x_return_status;


EXCEPTION
   WHEN l_override_organz_id_null THEN
        PA_UTILS.add_message('PA', 'PA_OVERRIDE_TO_ORGANZ_ID_NULL');
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        x_msg_count     :=  1;
        x_msg_data      :=  'PA_OVERRIDE_TO_ORGANZ_ID_NULL';

   WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SQLERRM;

        X_overr_to_organization_id := null;

        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_GET_RAW_BURDEN_COST',
                                 p_procedure_name => 'Override_exp_org');

END Override_exp_organization;



PROCEDURE Get_Burden_cost(p_project_type          IN      VARCHAR2 ,
                          p_project_id            IN      NUMBER   ,
                          p_task_id               IN      NUMBER   ,
                          p_item_date             IN      DATE     ,
                          p_expenditure_type      IN      VARCHAR2 ,
                          p_schedule_type         IN      VARCHAR2 ,
                          p_exp_func_curr_code    IN OUT  NOCOPY VARCHAR2 , --File.Sql.39 bug 4440895
                          p_Incurred_by_organz_id IN      NUMBER   ,
                          p_raw_cost              IN      NUMBER   ,
                          p_raw_cost_rate         IN      NUMBER   ,
                          p_quantity              IN      NUMBER   ,
                          p_override_to_organz_id IN      NUMBER   ,
                          x_burden_cost           OUT     NOCOPY NUMBER   , --File.Sql.39 bug 4440895
                          x_burden_cost_rate      OUT     NOCOPY NUMBER   , --File.Sql.39 bug 4440895
                          x_return_status         OUT     NOCOPY VARCHAR2 , --File.Sql.39 bug 4440895
                          x_msg_count             OUT     NOCOPY NUMBER   , --File.Sql.39 bug 4440895
                          x_msg_data              OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                         )
IS

l_burden_cost_flag                  pa_project_types.burden_cost_flag%TYPE;
l_burden_amt_disp_method            pa_project_types.burden_amt_display_method%TYPE;
l_x_burden_sch_fixed_date           DATE;
l_x_burden_sch_revision_id          NUMBER;
l_burden_sch_revision_id            NUMBER;
l_cost_base                         VARCHAR2(30);
l_x_cost_base                       VARCHAR2(30);
l_expenditure_org_id                NUMBER;
l_cp_structure                      VARCHAR2(30);
l_x_cp_structure                    VARCHAR2(30);
l_x_compiled_multiplier             NUMBER;
l_raw_cost_rate                     NUMBER;
l_raw_cost                          NUMBER;
l_x_status                          NUMBER;
l_x_stage                           NUMBER;
l_burden_cost                       NUMBER;
l_burden_cost_rate                  NUMBER;


l_done_burden_cost_calc             EXCEPTION;
l_cost_plus_struture_not_found      EXCEPTION;
l_cost_base_not_found               EXCEPTION;
l_comp_multiplier_not_found         EXCEPTION;
l_invalid_schedule_id               EXCEPTION;


l_exp_func_curr_code            varchar2(15);

BEGIN


l_exp_func_curr_code := p_exp_func_curr_code;

     --------------------------------------------
     -- Initialize the successfull return status
     --------------------------------------------

     l_x_return_status := FND_API.G_RET_STS_SUCCESS;


     ---------------------------------------------------------------------------------------
     -- Assign Input Raw cost into local variables anc check if input raw cost i null or not
     ---------------------------------------------------------------------------------------

     l_raw_cost_rate     := p_raw_cost_rate ;
     l_raw_cost          := p_raw_cost;


     IF (l_raw_cost IS NULL) OR (l_raw_cost_rate IS NULL) THEN

         RAISE l_raw_cost_null;

     END IF;


      ------------------------------------------------------------------------------
      -- If schedule type is not equal to REVENUE then only get the burden cost flag
      -- for calculate the burden cost.
      ------------------------------------------------------------------------------

      IF p_schedule_type <> 'REVENUE' THEN


       ------------------------------------------------------
       -- Get the burden cost flag for the given project type.
       ------------------------------------------------------

       SELECT burden_cost_flag
         INTO l_burden_cost_flag
         FROM pa_project_types ptypes
        WHERE project_type = P_project_type;


     --------------------------------------------------------------
     -- Assign Raw Cost into Burden cost, If burden_cost flag  = 'N'
     --------------------------------------------------------------


     IF (NVL(l_burden_cost_flag,'N') = 'N') THEN

         X_burden_cost_rate   := l_raw_cost_rate;
         X_burden_cost        := l_raw_cost;

         RAISE l_done_burden_cost_calc;

     END IF;


    END IF;

     ---------------------------------------------------------------------
     -- Get burden schdeule Revision Id from the procedure get_schedule_id
     ---------------------------------------------------------------------

      get_schedule_id(p_schedule_type           ,
                      p_project_id              ,
                      p_task_id                 ,
                      p_item_date               ,
                      p_expenditure_type        ,
                      l_x_burden_sch_revision_id  ,
                      l_x_burden_sch_fixed_date   ,
                      x_return_status           ,
                      x_msg_count               ,
                      x_msg_data
                     );


         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

             RAISE l_invalid_schedule_id;

         END IF;


          --------------------------------------------------------------------
          -- Get cost plus structure for the given burden schdeule revision id
          --------------------------------------------------------------------

            l_burden_sch_revision_id  := l_x_burden_sch_revision_id;

            pa_cost_plus.get_cost_plus_structure(l_burden_sch_revision_id,
                                                 l_x_cp_structure        ,
                                                 l_x_status              ,
                                                 l_x_stage
                                                );

            IF (l_x_status <> 0) THEN

                RAISE l_cost_plus_struture_not_found;

            END IF;


          ------------------------------------------------------------------------
          -- Get Cost Base for the given Expenditure Type and Cost plus structure
          ------------------------------------------------------------------------

            l_cp_structure := l_x_cp_structure;

            pa_cost_plus.get_cost_base(P_expenditure_type     ,
                                       l_cp_structure         ,
                                       l_x_cost_base          ,
                                       l_x_status             ,
                                       l_x_stage
                                      );

           IF (l_x_status <> 0) THEN

              RAISE l_cost_base_not_found;

           END IF;


         -------------------------------------------------------------------------------
         -- Get compiled Multiplier for the given Expenditure Org, Cost Base,
         -- Burden schedule revision id. If override to organization id is not null then
         -- consider it as expenditure Org. If Override to organization is is null then
         -- consider Incurred by organization is an expenditure Org.
         ------------------------------------------------------------------------------


            l_expenditure_org_id := NVL(p_override_to_organz_id, P_Incurred_by_organz_id);


            ------------------------------
            -- Get the compiled multiplier
            ------------------------------

            l_cost_base := l_x_cost_base;

            pa_cost_plus.get_compiled_multiplier(l_expenditure_org_id     ,
                                                 l_cost_base              ,
                                                 l_burden_sch_revision_id ,
                                                 l_x_compiled_multiplier  ,
                                                 l_x_status               ,
                                                 l_x_stage
                                                 );


            IF (l_x_status <> 0) THEN

                RAISE l_comp_multiplier_not_found;

            END IF;


            -------------------------------------------------------
            -- Get Burden Cost and rate from Raw Cost and Quantity.
            -------------------------------------------------------

            l_burden_cost       := pa_currency.round_trans_currency_amt(
                                            l_raw_cost * l_x_compiled_multiplier,p_exp_func_curr_code) +
                                            l_raw_cost ;


            l_burden_cost_rate  := X_burden_cost / NVL(P_quantity, 1) ;


            -----------------------------------------------
            -- Check If output burden cost and rate is null
            -----------------------------------------------

            IF (l_burden_cost IS NULL) OR (l_burden_cost_rate IS NULL) THEN

                RAISE l_burden_cost_null;

            END IF;


            ------------------------------------------
            -- Assing Burden cost into Output variable
            ------------------------------------------

            x_burden_cost      := l_burden_cost;
            x_burden_cost_rate := l_burden_cost_rate;



            -------------------------------------------------------
             -- Assign the successful status back to output variable
            -------------------------------------------------------

            x_return_status := l_x_return_status;


EXCEPTION
    WHEN NO_DATA_FOUND THEN
         PA_UTILS.add_message('PA', 'PA_NO_BURDEN_COST_FLAG');
         x_return_status :=  FND_API.G_RET_STS_ERROR;
         x_msg_count     :=  1;
         x_msg_data      :=  'PA_NO_BURDEN_COST_FLAG';

    WHEN l_raw_cost_null THEN
         PA_UTILS.add_message('PA', 'PA_RAW_COST_NULL');
         x_return_status :=  FND_API.G_RET_STS_ERROR;
         x_msg_count     :=  1;
         x_msg_data      :=  'PA_RAW_COST_NULL';

    WHEN l_done_burden_cost_calc THEN
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         x_msg_count := NULL;
         x_msg_data  := NULL;

    WHEN l_cost_plus_struture_not_found THEN
         PA_UTILS.add_message('PA', 'PA_NO_COST_PLUS_STRUCTURE');
         x_return_status :=  FND_API.G_RET_STS_ERROR;
         x_msg_count     :=  1;
         x_msg_data      :=  'PA_NO_COST_PLUS_STRUCTURE';

    WHEN l_cost_base_not_found THEN
         PA_UTILS.add_message('PA', 'PA_COST_BASE_NOT_FOUND');
         x_return_status :=  FND_API.G_RET_STS_ERROR;
         x_msg_count     :=  1;
         x_msg_data      :=  'PA_COST_BASE_NOT_FOUND';

    WHEN l_comp_multiplier_not_found THEN
         PA_UTILS.add_message('PA', 'PA_NO_COMPILED_MULTIPLIER');
         x_return_status :=  FND_API.G_RET_STS_ERROR;
         x_msg_count     :=  1;
         x_msg_data      :=  'PA_NO_COMPILED_MULTIPLIER';

    WHEN l_invalid_schedule_id THEN
         x_return_status :=  FND_API.G_RET_STS_ERROR;
         x_msg_count     :=  1;
         x_msg_data      :=  'PA_INVALID_SCH_REV_ID';

    WHEN l_burden_cost_null THEN
         PA_UTILS.add_message('PA', 'PA_BURDEN_COST_NULL');
         x_return_status :=  FND_API.G_RET_STS_ERROR;
         x_msg_count     :=  1;
         x_msg_data      :=  'PA_BURDEN_COST_NULL';

    WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_count := 1;
         x_msg_data  := SQLERRM;

          p_exp_func_curr_code := l_exp_func_curr_code;
          x_burden_cost      := null;
          x_burden_cost_rate := null;


         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_GET_RAW_BURDEN_COST',
                                  p_procedure_name => 'Get_Burden_cost');


END Get_burden_cost;




PROCEDURE  Get_proj_raw_Burden_cost(P_exp_org_id             IN      NUMBER    ,
                                    P_proj_org_id            IN      NUMBER    ,
                                    P_project_id             IN      NUMBER    ,
                                    P_task_id                IN      NUMBER    ,
                                    P_item_date              IN      DATE      ,
                                    P_exp_func_curr_code     IN  OUT NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
                                    p_proj_func_curr_code    IN  OUT NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
                                    p_raw_cost               IN      NUMBER    ,
                                    p_burden_cost            IN      NUMBER    ,
                                    x_proj_raw_cost          OUT     NOCOPY NUMBER    , --File.Sql.39 bug 4440895
                                    x_proj_raw_cost_rate     OUT     NOCOPY NUMBER    , --File.Sql.39 bug 4440895
                                    x_proj_burden_cost       OUT     NOCOPY NUMBER    , --File.Sql.39 bug 4440895
                                    x_proj_burden_cost_rate  OUT     NOCOPY NUMBER    ,  --File.Sql.39 bug 4440895
                                    x_return_status          OUT     NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
                                    x_msg_count              OUT     NOCOPY NUMBER    , --File.Sql.39 bug 4440895
                                    x_msg_data               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                   )
IS


l_proj_org_id                    NUMBER;
l_proj_func_curr_code            fnd_currencies.currency_code%TYPE;
l_exp_func_curr_code             fnd_currencies.currency_code%TYPE;
l_proj_rate_date                 DATE;
l_proj_rate_type                 VARCHAR2(30);
l_x_proj_raw_cost                NUMBER;
l_x_burden_raw_cost              NUMBER;
l_x_proj_burden_cost             NUMBER;
l_denominator                    NUMBER;
l_numerator                      NUMBER;
l_exchange_rate                  NUMBER;


x_status                         NUMBER;


l_done_proj_cost_calc            EXCEPTION;
l_invalid_rate_date_type         EXCEPTION;

lx_proj_func_curr_code            varchar2(15);
lx_exp_func_curr_code             varchar2(15);

BEGIN

   lx_proj_func_curr_code     := p_proj_func_curr_code;
   lx_exp_func_curr_code      := p_exp_func_curr_code;

     --------------------------------------------
     -- Initialize the successfull return status
     --------------------------------------------

      l_x_return_status := FND_API.G_RET_STS_SUCCESS;



      ---------------------------------------------
      -- Check If Input Raw Cost is null
      ---------------------------------------------

      IF (p_raw_cost IS NULL) THEN

          RAISE l_raw_cost_null;

      END IF;


     ---------------------------------------------
      -- Check If Input Burden cost is null
      ---------------------------------------------

      IF  (p_burden_cost IS NULL) THEN

          RAISE l_burden_cost_null;

      END IF;



      -------------------------------------------------------------------------------
      -- If expenditure org and project org are same then project raw and burden cost
      -- are equal to transaction raw and burden cost
      -------------------------------------------------------------------------------

      IF (P_exp_org_id = P_proj_org_id) THEN

           x_proj_raw_cost      := p_raw_cost;
           x_proj_burden_cost   := p_burden_cost;

           RAISE l_done_proj_cost_calc;

      END IF;



      -------------------------------------------
      -- Get Project functional currency code
      -------------------------------------------


      IF (p_proj_func_curr_code IS NULL) THEN

          p_proj_func_curr_code  := get_curr_code(p_proj_org_id);

      END IF;


      IF (p_proj_func_curr_code IS NULL) THEN

         RAISE l_proj_func_curr_code_null;

      END IF;


      -------------------------------------------
      -- Get Expenditure functional currency code
      -------------------------------------------


      IF (p_exp_func_curr_code IS NULL) THEN

          p_exp_func_curr_code  := get_curr_code(p_exp_org_id);

      END IF;


      IF (p_exp_func_curr_code IS NULL) THEN

         RAISE l_exp_func_curr_code_null;

      END IF;



      l_proj_rate_date := NULL;
      l_proj_rate_type := NULL;



      IF (p_task_id IS NOT NULL) THEN


        BEGIN


          -- Get the project_rate_date and project_rate_type


          SELECT NVL(tsk.project_rate_date,
                 DECODE(imp.default_rate_date_code,'E',p_item_date,
                                                 'P',get_pa_date(p_item_date,p_exp_org_id))),
                 NVL(tsk.project_rate_type, imp.default_rate_type)
            INTO l_proj_rate_date,
                 l_proj_rate_type
            FROM pa_projects_all prj,
                 pa_tasks tsk,
                 pa_implementations_all imp
           WHERE prj.project_id = p_project_id
             AND prj.project_id = tsk.project_id
             AND tsk.task_id    = p_task_id
             AND prj.org_id     = imp.org_id
             AND imp.org_id     = p_proj_org_id;

           EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    l_proj_rate_date := NULL;
                    l_proj_rate_type := NULL;

        END;

      END IF;



      IF (l_proj_rate_type IS NULL) THEN

         -- Get the Project Rate Date and Rate Type

         BEGIN


          SELECT NVL(prj.project_rate_date,
                 DECODE(imp.default_rate_date_code,'E',p_item_date,
                                                   'P',get_pa_date(p_item_date,p_exp_org_id))),
                 NVL(prj.project_rate_type, imp.default_rate_type)
            INTO l_proj_rate_date,
                 l_proj_rate_type
            FROM pa_projects_all prj,
                 pa_implementations_all imp
           WHERE prj.project_id = p_project_id
             AND prj.org_id     = imp.org_id
             AND imp.org_id     = p_proj_org_id;


           EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    l_proj_rate_date := NULL;
                    l_proj_rate_type := NULL;

        END;

      END IF;


      IF (l_proj_rate_type IS NULL)  OR  (l_proj_rate_date IS NULL) THEN

         RAISE l_invalid_rate_date_type ;

      END IF;



       -------------------------------
       -- Get the Project Raw cost
       -------------------------------

       pa_multi_currency.convert_amount(p_exp_func_curr_code      ,
                                        p_proj_func_curr_code     ,
                                        l_proj_rate_date          ,
                                        l_proj_rate_type          ,
                                        p_Raw_cost                ,
                                        'N'                       ,
                                        'N'                       ,
                                        l_x_proj_raw_cost         ,
                                        l_denominator             ,
                                        l_numerator               ,
                                        l_exchange_rate           ,
                                        x_status
                                       );




       IF (l_x_proj_raw_cost IS NULL) THEN

           RAISE l_raw_cost_null;

       END IF;


       x_proj_raw_cost    := l_x_proj_raw_cost;


       ------------------------------
       -- Get the Project Burden cost
       ------------------------------

       pa_multi_currency.convert_amount(p_exp_func_curr_code      ,
                                        p_proj_func_curr_code     ,
                                        l_proj_rate_date          ,
                                        l_proj_rate_type          ,
                                        p_burden_cost             ,
                                        'N'                       ,
                                        'N'                       ,
                                        l_x_proj_burden_cost      ,
                                        l_denominator             ,
                                        l_numerator               ,
                                        l_exchange_rate           ,
                                        x_status
                                       );


       IF (l_x_proj_burden_cost IS NULL) THEN

           RAISE l_burden_cost_null;

       END IF;


       x_proj_burden_cost := l_x_proj_burden_cost;


       x_return_status := l_x_return_status;


EXCEPTION
    WHEN l_done_proj_cost_calc THEN
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         x_msg_count := NULL;
         x_msg_data  := NULL;

    WHEN l_proj_func_curr_code_null THEN
         PA_UTILS.add_message('PA', 'PA_PROJ_FUNC_CURR_CODE_NULL');
         x_return_status :=  FND_API.G_RET_STS_ERROR;
         x_msg_count     :=  1;
         x_msg_data      :=  'PA_PROJ_FUNC_CURR_CODE_NULL';

    WHEN l_exp_func_curr_code_null THEN
         PA_UTILS.add_message('PA', 'PA_EXP_FUNC_CURR_CODE_NULL');
         x_return_status :=  FND_API.G_RET_STS_ERROR;
         x_msg_count     :=  1;
         x_msg_data      :=  'PA_EXP_FUNC_CURR_CODE_NULL';

    WHEN l_invalid_rate_date_type THEN
         PA_UTILS.add_message('PA', 'PA_INVALID_RATE_DATE_TYPE');
         x_return_status :=  FND_API.G_RET_STS_ERROR;
         x_msg_count     :=  1;
         x_msg_data      :=  'PA_INVALID_RATE_DATE_TYPE';

    WHEN l_raw_cost_null THEN
         PA_UTILS.add_message('PA', 'PA_RAW_COST_NULL');
         x_return_status :=  FND_API.G_RET_STS_ERROR;
         x_msg_count     :=  1;
         x_msg_data      :=  'PA_PA_PROJ_RAW_COST_NULL';

   WHEN l_burden_cost_null THEN
         PA_UTILS.add_message('PA', 'PA_BURDEN_COST_NULL');
         x_return_status :=  FND_API.G_RET_STS_ERROR;
         x_msg_count     :=  1;
         x_msg_data      :=  'PA_BURDEN_COST_NULL';

    WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_count := 1;
         x_msg_data  := SQLERRM;

        /* ATG Changes */
          p_proj_func_curr_code := lx_proj_func_curr_code;
          p_exp_func_curr_code := lx_exp_func_curr_code;
          x_proj_raw_cost           := null;
          x_proj_raw_cost_rate      := null;
          x_proj_burden_cost        := null;
          x_proj_burden_cost_rate   := null;

         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_GET_RAW_BURDEN_COST',
                                  p_procedure_name => 'Get_Proj_Raw_Burden_Cost');

END Get_proj_raw_Burden_cost;



FUNCTION Get_pa_date(P_item_date                 IN  DATE,
                     P_expenditure_org_id        IN  NUMBER
                    )
return date
IS

   l_pa_date  date ;

BEGIN

       -- Get the PA Date

       SELECT MIN(pap.end_date)
         INTO l_pa_date
         FROM pa_periods pap
        WHERE status in ('O','F')
          AND pap.end_date >= P_item_date
          AND NVL(pap.org_id, -99) = NVL(p_expenditure_org_id, -99);

     return l_pa_date ;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
         RETURN NULL;
    WHEN OTHERS THEN
         RAISE;

END Get_pa_date;



FUNCTION Get_curr_code(p_org_id         IN  NUMBER
                      )

RETURN VARCHAR2
IS

l_currency_code      fnd_currencies.currency_code%TYPE;

BEGIN

     SELECT FC.currency_code
       INTO l_currency_code
       FROM FND_CURRENCIES FC,
            GL_SETS_OF_BOOKS GB,
            PA_IMPLEMENTATIONS_ALL IMP
      WHERE FC.currency_code = DECODE(imp.set_of_books_id, NULL, NULL, GB.currency_code)
        AND GB.set_of_books_id = IMP.set_of_books_id
        AND IMP.org_id  = p_org_id;

      return l_currency_code;


EXCEPTION
   WHEN NO_DATA_FOUND THEN
        NULL;

   WHEN OTHERS THEN
        Raise;


END Get_curr_code;



PROCEDURE get_schedule_id( p_schedule_type          IN   VARCHAR2  ,
                           p_project_id             IN   NUMBER    ,
                           p_task_id                IN   NUMBER    ,
                           p_item_date              IN   DATE      ,
                           p_exp_type               IN   VARCHAR2  ,
                           x_burden_sch_rev_id      OUT  NOCOPY NUMBER    ,                          --File.Sql.39 bug 4440895
                           x_burden_sch_fixed_date  OUT  NOCOPY DATE      , --File.Sql.39 bug 4440895
                           x_return_status          OUT  NOCOPY VARCHAR2  , --File.Sql.39 bug 4440895
                           x_msg_count              OUT  NOCOPY NUMBER    , --File.Sql.39 bug 4440895
                           x_msg_data               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                         )
IS


l_sch_fixed_date               DATE;
l_burden_sch_fixed_date        DATE;
l_burden_schedule_id           NUMBER;
l_x_burden_sch_revision_id     NUMBER;
l_burden_sch_id                NUMBER;
l_x_status                     NUMBER;
l_x_stage                      NUMBER;

l_sch_rev_id_found             EXCEPTION;
l_sch_rev_id_not_found         EXCEPTION;
l_invalid_revision_by_date     EXCEPTION;

BEGIN


     --------------------------------------------
     -- Initialize the successfull return status
     --------------------------------------------

      l_x_return_status := FND_API.G_RET_STS_SUCCESS;



      l_burden_sch_id         := NULL;
      l_burden_sch_fixed_date := NULL;

      --------------------------------------------
      -- Task level schedule override
      --------------------------------------------


      IF p_task_id IS NOT NULL THEN

         BEGIN

            SELECT irs.ind_rate_sch_id,
                   DECODE(p_schedule_type,'COST',    t.cost_ind_sch_fixed_date,
                                          'REVENUE', t.rev_ind_sch_fixed_date,
                                          'INVOICE', t.inv_ind_sch_fixed_date)
              INTO l_burden_sch_id,
                   l_burden_sch_fixed_date
              FROM pa_tasks t,
                   pa_ind_rate_schedules irs
             WHERE t.task_id = p_task_id
               AND t.task_id = irs.task_id
               AND (  (p_schedule_type = 'COST'
                       AND NVL(cost_ovr_sch_flag,'N') = 'Y')
                   OR (p_schedule_type = 'REVENUE'
                       AND NVL(rev_ovr_sch_flag,'N')  = 'Y')
                   OR (p_schedule_type = 'INVOICE'
                       AND  NVL(inv_ovr_sch_flag,'N')  = 'Y')
                   );

            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_burden_sch_id := NULL;
                   l_burden_sch_fixed_date := NULL;

         END;

      END IF;



      IF (l_burden_sch_id IS NOT NULL) THEN

          pa_cost_plus.get_revision_by_date(l_burden_sch_id,
                                            l_burden_sch_fixed_date,
                                            p_item_date,
                                            l_x_burden_sch_revision_id,
                                            l_x_status,
                                            l_x_stage
                                           );
      END IF;


      IF (l_x_status) <> 0 THEN

          RAISE l_invalid_revision_by_date;

      END IF;


      -------------------------------------------------------
      -- Calling client extension to override rate_sch_rev_id
      -------------------------------------------------------

-------------------------------------------------------------------
---------------------- This is a open Issue -----------------------

/*      PA_CLIENT_EXTN_BURDEN.Override_Rate_Rev_Id(
                            p_expenditure_id,
                            p_exp_type,
                            p_task_id,
                            p_schedule_type,
                            p_item_date,
                            l_sch_fixed_date,
                            l_burden_schedule_id,
                            status
                           );

      IF (l_burden_schedule_id IS NOT NULL) THEN

          l_x_burden_sch_revision_id := l_burden_schedule_id;

          IF (l_sch_fixed_date IS NOT NULL) THEN

              l_burden_sch_fixed_date  := l_sch_fixed_date;

          END IF;

     END IF;*/
------------------------------------------------------------------


      IF (l_x_burden_sch_revision_id IS NOT NULL) THEN

          x_burden_sch_rev_id      :=  l_x_burden_sch_revision_id;
          x_burden_sch_fixed_date  :=  l_burden_sch_fixed_date;

          RAISE l_sch_rev_id_found;

      END IF;


      ----------------------------------------------------------------
      -- There is no override rate schedule id found at the task level
      -- Find the override rate schedule at project level
      ----------------------------------------------------------------


       l_burden_sch_id := NULL;
       l_burden_sch_fixed_date := NULL;


      BEGIN

        SELECT irs.ind_rate_sch_id,
               DECODE(p_schedule_type,'COST',    prj.cost_ind_sch_fixed_date,
                                      'REVENUE', prj.rev_ind_sch_fixed_date,
                                      'INVOICE', prj.inv_ind_sch_fixed_date )
          INTO l_burden_sch_id,
               l_burden_sch_fixed_date
          FROM pa_ind_rate_schedules irs,
               pa_projects_all       prj
         WHERE irs.project_id = prj.project_id
           AND irs.project_id = p_project_id
           AND irs.task_id is NULL
           AND (  (p_schedule_type = 'COST'
                   AND NVL(cost_ovr_sch_flag,'N') = 'Y')
               OR (p_schedule_type = 'REVENUE'
                   AND NVL(rev_ovr_sch_flag,'N')  = 'Y')
               OR (p_schedule_type = 'INVOICE'
                   AND  NVL(inv_ovr_sch_flag,'N')  = 'Y')
                );

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                 l_burden_sch_id := NULL;
                 l_burden_sch_fixed_date := NULL;

      END;


      IF (l_burden_sch_id IS NOT NULL) THEN

         -- Get the project override schedule id and fixed date

          pa_cost_plus.get_revision_by_date(l_burden_sch_id,
                                            l_burden_sch_fixed_date,
                                            p_item_date,
                                            l_x_burden_sch_revision_id,
                                            l_x_status,
                                            l_x_stage
                                           );
      END IF;


      IF (l_x_status) <> 0 THEN

          RAISE l_invalid_revision_by_date;

      END IF;




      IF (l_x_burden_sch_revision_id) is NOT NULL THEN

          x_burden_sch_rev_id      :=  l_x_burden_sch_revision_id;
          x_burden_sch_fixed_date  :=  l_burden_sch_fixed_date;

          RAISE l_sch_rev_id_found;

      END IF;


      -------------------------------------------------------------------
      -- There is no override rate schedule id found at the project level
      -- Find the override rate schedule at lowest task level
      -------------------------------------------------------------------


      l_burden_sch_id := NULL;
      l_burden_sch_fixed_date := NULL;


      IF p_task_id IS NOT NULL THEN

         BEGIN

            SELECT t.cost_ind_rate_sch_id,
                   DECODE(p_schedule_type,'COST',    t.cost_ind_sch_fixed_date,
                                          'REVENUE', t.rev_ind_sch_fixed_date,
                                          'INVOICE', t.inv_ind_sch_fixed_date)
              INTO l_burden_sch_id,
                   l_burden_sch_fixed_date
              FROM pa_tasks t
             WHERE t.task_id = p_task_id
               AND (   p_schedule_type = 'COST'
                    OR p_schedule_type = 'REVENUE'
                    OR p_schedule_type = 'INVOICE'
                   );

            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_burden_sch_id := NULL;
                   l_burden_sch_fixed_date := NULL;

         END;

      END IF;


      IF (l_burden_sch_id IS NOT NULL) THEN

          pa_cost_plus.get_revision_by_date(l_burden_sch_id,
                                            l_burden_sch_fixed_date,
                                            p_item_date,
                                            l_x_burden_sch_revision_id,
                                            l_x_status,
                                            l_x_stage
                                           );

      END IF;

------------------------------------------------------

      IF (l_x_burden_sch_revision_id) is NOT NULL THEN

          x_burden_sch_rev_id      :=  l_x_burden_sch_revision_id;
          x_burden_sch_fixed_date  :=  l_burden_sch_fixed_date;

          RAISE l_sch_rev_id_found;

      END IF;


         l_burden_sch_id := NULL;
         l_burden_sch_fixed_date := NULL;


         BEGIN

            SELECT prj.cost_ind_rate_sch_id,
                   DECODE(p_schedule_type,'COST',    prj.cost_ind_sch_fixed_date,
                                          'REVENUE', prj.rev_ind_sch_fixed_date,
                                          'INVOICE', prj.inv_ind_sch_fixed_date)
              INTO l_burden_sch_id,
                   l_burden_sch_fixed_date
              FROM pa_projects prj
             WHERE prj.project_id = p_project_id
               AND (   p_schedule_type = 'COST'
                    OR p_schedule_type = 'REVENUE'
                    OR p_schedule_type = 'INVOICE'
                   );

            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   l_burden_sch_id := NULL;
                   l_burden_sch_fixed_date := NULL;

         END;


      IF (l_burden_sch_id IS NOT NULL) THEN

          pa_cost_plus.get_revision_by_date(l_burden_sch_id,
                                            l_burden_sch_fixed_date,
                                            p_item_date,
                                            l_x_burden_sch_revision_id,
                                            l_x_status,
                                            l_x_stage
                                           );
      END IF;

------------------------------------------------------

      IF (l_x_status) <> 0 THEN

          RAISE l_invalid_revision_by_date;

      END IF;



      IF (l_x_burden_sch_revision_id) is NOT NULL THEN

          x_burden_sch_rev_id      :=  l_x_burden_sch_revision_id;
          x_burden_sch_fixed_date  :=  l_burden_sch_fixed_date;

          RAISE l_sch_rev_id_found;

      ELSE

          RAISE l_sch_rev_id_not_found;

      END IF;



      x_return_status := l_x_return_status;



EXCEPTION
    WHEN l_invalid_revision_by_date THEN
         PA_UTILS.add_message('PA', 'PA_SCH_REV_NOT_FOUND');
         x_return_status :=  FND_API.G_RET_STS_ERROR;
         x_msg_count     :=  1;
         x_msg_data      :=  'PA_SCH_REV_NOT_FOUND';

    WHEN l_sch_rev_id_found THEN
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         x_msg_count := NULL;
         x_msg_data  := NULL;

    WHEN l_sch_rev_id_not_found THEN
         PA_UTILS.add_message('PA', 'PA_SCH_REV_ID_NOT_FOUND');
         x_return_status :=  FND_API.G_RET_STS_ERROR;
         x_msg_count     :=  1;
         x_msg_data      :=  'PA_SCH_REV_ID_NOT_FOUND';

    WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_count := 1;
         x_msg_data  := SQLERRM;


        /* ATG Changes */

         x_burden_sch_rev_id       := null;
         x_burden_sch_fixed_date   := null;

         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_GET_RAW_BURDEN_COST',
                                  p_procedure_name => 'Get_Schedule_Id');

END get_schedule_id;



PROCEDURE  Requirement_raw_cost(
                                   p_forecast_cost_job_group_id  IN  NUMBER   ,
                                   p_forecast_cost_job_id        IN  NUMBER   ,
                                   p_proj_cost_job_group_id      IN  NUMBER   ,
                                   p_proj_cost_job_id            IN  OUT NOCOPY NUMBER , --File.Sql.39 bug 4440895
                                   p_item_date                   IN  DATE     ,
                                   p_job_cost_rate_sch_id        IN  NUMBER   ,
                                   p_schedule_date               IN  DATE     ,
                                   p_quantity                    IN  NUMBER   ,
                                   p_cost_rate_multiplier        IN  NUMBER   ,
                                   x_raw_cost_rate               OUT NOCOPY NUMBER   , --File.Sql.39 bug 4440895
                                   x_raw_cost                    OUT NOCOPY NUMBER   , --File.Sql.39 bug 4440895
                                   x_return_status               OUT NOCOPY VARCHAR2 , --File.Sql.39 bug 4440895
                                   x_msg_count                   OUT NOCOPY NUMBER   , --File.Sql.39 bug 4440895
                                   x_msg_data                    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                  )
IS

l_x_raw_cost_rate            NUMBER;
l_x_raw_cost                 NUMBER;
l_to_job_id                  NUMBER;
l_currency_code              fnd_currencies.currency_code%TYPE;

l_raw_cost_null              EXCEPTION;

l_proj_cost_job_id           number;

BEGIN

/* ATG Changes */
l_proj_cost_job_id  := p_proj_cost_job_id ;

          --------------------------------------------
          -- Initialize the successfull return status
          --------------------------------------------

           l_x_return_status := FND_API.G_RET_STS_SUCCESS;


           ---------------------------------------
           -- Get the Project Cost Job Id from API.
           ---------------------------------------


/*           IF (p_proj_cost_job_id IS NULL) THEN

               Pa_Resource_Utils.GetToJobId( p_forecast_cost_job_group_id   ,
                                             p_forecast_cost_job_id         ,
                                             p_proj_cost_job_group_id       ,
                                             p_proj_cost_job_id
                                           );
           END IF;
*/


            SELECT DECODE(b.rate, NULL, NULL,b.rate * NVL(p_cost_rate_multiplier,1)),
                   PA_CURRENCY.ROUND_CURRENCY_AMT(b.rate * NVL(p_cost_rate_multiplier,1)
                                                  * p_quantity)
              INTO l_x_raw_cost_rate, l_x_raw_cost
              FROM pa_bill_rates b
             WHERE b.bill_rate_sch_id = p_job_cost_rate_sch_id
               AND b.job_id =  p_proj_cost_job_id
               AND b.rate is NOT NULL
               AND to_date(nvl(to_date(p_schedule_date, 'YYYY/MM/DD'), to_date(p_item_date, 'YYYY/MM/DD'))+ 0.99999, 'YYYY/MM/DD')
                    BETWEEN b.start_date_active
                    AND NVL(to_date(b.end_date_active, 'YYYY/MM/DD'),
                             to_date(nvl(to_date(p_schedule_date,'YYYY/MM/DD'), to_date(p_item_date,'YYYY/MM/DD')), 'YYYY/MM/DD')) + 0.99999;




       IF (l_x_raw_cost_rate IS NULL) OR (l_x_raw_cost IS NULL) THEN

          RAISE l_raw_cost_null;

       END IF;


       x_raw_cost_rate   := l_x_raw_cost_rate;
       x_raw_cost        := l_x_raw_cost;


       x_return_status := l_x_return_status;


EXCEPTION
   WHEN NO_DATA_FOUND THEN
        PA_UTILS.add_message('PA', 'PA_NO_COST_RATE');
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        x_msg_count     :=  1;
        x_msg_data      :=  'PA_NO_COST_RATE';

   WHEN l_raw_cost_null THEN
        PA_UTILS.add_message('PA', 'PA_RAW_COST_NULL');
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        x_msg_count     :=  1;
        x_msg_data      :=  'PA_RAW_COST_NULL';

   WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SQLERRM;

        /* ATG Changes */

    /* ATG Changes */
        p_proj_cost_job_id  := l_proj_cost_job_id ;
        x_raw_cost_rate   := null;
        x_raw_cost        := null;

        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_GET_RAW_BURDEN_COST',
                                 p_procedure_name => 'Requirement_raw_cost');

END Requirement_raw_cost;



END PA_FORECAST_COST;

/
