--------------------------------------------------------
--  DDL for Package Body PA_COST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_COST" as
/* $Header: PAXCSRTB.pls 120.5.12010000.2 2009/02/16 10:42:52 amehrotr ship $ */

l_exp_func_curr_code_null   EXCEPTION;
l_project_curr_code_null    EXCEPTION; /* Added for Org Forecasting */
l_multi_conversion_fail     EXCEPTION; /* Added for Org Forecasting */
l_proj_func_curr_code_null  EXCEPTION;
l_raw_cost_null             EXCEPTION;
l_burden_cost_null          EXCEPTION;
l_x_return_status           VARCHAR2(50);

g_debug_mode varchar2(1);


PROCEDURE PRINT_MSG(p_msg  varchar2) IS

BEGIN
	--r_debug.r_msg('LOG:'||p_msg);
	--dbms_output.put_line('LOG:'||p_msg);
	IF g_debug_mode = 'Y' Then
      		PA_DEBUG.g_err_stage := Substr('LOG:'||p_msg,1,500);
      		PA_DEBUG.Log_Message(p_message => PA_DEBUG.g_err_stage);

	END IF;

END PRINT_MSG;


PROCEDURE Get_Raw_Cost(P_person_id               IN      NUMBER    ,
                       P_expenditure_org_id      IN      NUMBER    ,
                       P_expend_organization_id  IN      NUMBER    ,     /*LCE changes*/
                       P_labor_Cost_Mult_Name    IN      VARCHAR2  ,
                       P_Item_date               IN      DATE      ,
                       px_exp_func_curr_code     IN OUT NOCOPY  VARCHAR2  ,
                       P_Quantity                IN      NUMBER    ,
                       X_Raw_cost_rate           OUT NOCOPY     NUMBER    ,
                       X_Raw_cost                OUT NOCOPY     NUMBER    ,
                       X_return_status           OUT NOCOPY     VARCHAR2  ,
                       X_msg_count               OUT NOCOPY     NUMBER    ,
                       X_msg_data                OUT NOCOPY     VARCHAR2
                      )
IS

l_cost_multiplier             pa_labor_cost_multipliers.multiplier%TYPE;
l_labor_cost_rate             pa_compensation_details_all.HOURLY_COST_RATE%TYPE;
l_x_raw_cost                  NUMBER;
l_x_raw_cost_rate             NUMBER;

l_no_labor_cost_rate          EXCEPTION;

/*LCE changes*/
l_expend_organization_id   pa_expenditures_all.incurred_by_organization_id%type;
l_exp_org_id               pa_expenditures_all.org_id%TYPE;                       /*2879644*/
l_job_id                   pa_expenditure_items_all.job_id%type;
l_costing_rule             pa_compensation_details_all.compensation_rule_set%type;
l_start_date_active        date;
l_end_date_active          date;
l_org_labor_sch_rule_id    pa_org_labor_sch_rule.org_labor_sch_rule_id%type;
l_rate_sch_id              pa_std_bill_rate_schedules.bill_rate_sch_id%type;
l_override_type            pa_compensation_details.override_type%type;
l_cost_rate_curr_code      pa_compensation_details.cost_rate_currency_code%type;
l_acct_rate_type           pa_compensation_details.acct_rate_type%type;
l_acct_rate_date_code      pa_compensation_details.acct_rate_date_code%type;
l_acct_exch_rate           pa_compensation_details.acct_exchange_rate%type;
l_acct_cost_rate           pa_compensation_details.acct_exchange_rate%type;
l_ot_project_id            pa_projects_all.project_id%type;
l_ot_task_id               pa_tasks.task_id%type;
l_err_code                 varchar2(200);
l_err_stage                number;
l_return_value             varchar2(100);
l_numerator                number;
l_denominator              number;
l_conversion_date          DATE;
user_exception             EXCEPTION;
/*LCE changes*/


BEGIN


     --------------------------------------------
     -- Initialize the successfull return status
     --------------------------------------------

     l_x_return_status := FND_API.G_RET_STS_SUCCESS;

/*****Commented for LCE Changes

     -----------------------------------------------------------
     -- Get the labor cost rate from pa_compensation_details_all
     -----------------------------------------------------------

     SELECT hourly_cost_rate
       INTO l_labor_cost_rate
       FROM pa_compensation_details_all cd
      WHERE cd.person_id = p_person_id
        AND cd.org_id = p_expenditure_org_id --Bug#5903720
        AND p_item_date BETWEEN cd.start_date_active AND NVL(cd.end_date_active,P_item_date);

**End of comment for LCE******/

/***Start of LCE changes***/
      -------------------------
     -- Get the labor cost rate
     --------------------------

      l_expend_organization_id := P_expend_organization_id;
      l_exp_org_id             := P_expenditure_org_id;       /*2879644*/

     pa_cc_utils.log_message('p_person_id = '||p_person_id||' P_Item_date = '||to_char(trunc(P_Item_date),'DD-MON-YY'));
     pa_cc_utils.log_message('l_expend_organization_id = '||l_expend_organization_id||' l_exp_org_id = '||l_exp_org_id);

      PA_COST_RATE_PUB.get_labor_rate(p_person_id             =>P_person_id
                                     ,p_txn_date              =>P_Item_date
                                     ,p_calling_module        =>'STAFFED'
                                     ,p_org_id                =>l_exp_org_id            /*2879644*/
                                     ,x_job_id                =>l_job_id
                                     ,x_organization_id       =>l_expend_organization_id
                                     ,x_cost_rate             =>l_labor_cost_rate
                                     ,x_start_date_active     =>l_start_date_active
                                     ,x_end_date_active       =>l_end_date_active
                                     ,x_org_labor_sch_rule_id =>l_org_labor_sch_rule_id
                                     ,x_costing_rule          =>l_costing_rule
                                     ,x_rate_sch_id           =>l_rate_sch_id
                                     ,x_cost_rate_curr_code   =>l_cost_rate_curr_code
                                     ,x_acct_rate_type        =>l_acct_rate_type
                                     ,x_acct_rate_date_code   =>l_acct_rate_date_code
                                     ,x_acct_exch_rate        =>l_acct_exch_rate
                                     ,x_ot_project_id         =>l_ot_project_id
                                     ,x_ot_task_id            =>l_ot_task_id
                                     ,x_err_stage             =>l_err_stage
                                     ,x_err_code              =>l_err_code
                                     );

     If l_err_code is NOT NULL THEN
     pa_cc_utils.log_message('Error Occured in stage'||l_err_stage||' with err code '||l_err_code);
     pa_cc_utils.log_message('Error '||SQLERRM);
     RAISE user_exception;
     END IF;

      pa_cc_utils.log_message('Converting from transaction currency to functional currency');
      -- Get the Functional Currency code
       ----------------------------------------------------------------------
       -- If Input expenditure functional currency code is null then call the
       -- procedure get_curr_code to get the currency code
       ----------------------------------------------------------------------


       IF (px_exp_func_curr_code IS NULL) THEN

           px_exp_func_curr_code := get_curr_code(p_expenditure_org_id);

       END IF;

      pa_cc_utils.log_message('px_exp_func_curr_code '||px_exp_func_curr_code);

       IF (px_exp_func_curr_code IS NULL) THEN

           RAISE l_exp_func_curr_code_null;

       END IF;

      pa_cc_utils.log_message('l_cost_rate_curr_code '||l_cost_rate_curr_code);

      --Check if the denom and functional currencies are different

       IF px_exp_func_curr_code <> l_cost_rate_curr_code THEN

          l_conversion_date := P_Item_date;

      pa_cc_utils.log_message('Before calling pa_multi_currency.convert_amount'); -- Bug 7423839

      begin
       pa_multi_currency.convert_amount( P_from_currency         =>l_cost_rate_curr_code,
                                         P_to_currency           =>px_exp_func_curr_code,
                                         P_conversion_date       =>l_conversion_date,
                                         P_conversion_type       =>l_acct_rate_type,
                                         P_amount                =>l_labor_cost_rate,
                                         P_user_validate_flag    =>'N',
                                         P_handle_exception_flag =>'Y', --Bug 7423839 changed to Y
                                         P_converted_amount      =>l_acct_cost_rate,
                                         P_denominator           =>l_denominator,
                                         P_numerator             =>l_numerator,
                                         P_rate                  =>l_acct_exch_rate,
                                         X_status                =>l_err_code ) ;
      exception
          when others then
          pa_cc_utils.log_message('Inside when others exception '||substr(SQLERRM,1,300));
          RAISE;
      end;

       IF l_err_code is NOT NULL THEN
         pa_cc_utils.log_message('Error occured in conversion stage '||l_err_code);
         RAISE user_exception;
       END IF;
      ELSE
            pa_cc_utils.log_message('l_acct_cost_rate '||l_acct_cost_rate||' l_labor_cost_rate '||l_labor_cost_rate);
            l_acct_cost_rate := l_labor_cost_rate;   /*When  denom and functional are same*/
      END IF;
/***End of LCE changes ***/

     -----------------------------------------------------------------------
     -- Get the cost multiplier from pa_labor_cost_multipliers for the given
     -- labor cost multiplier name
     -----------------------------------------------------------------------


    IF  P_labor_Cost_Mult_Name IS NOT NULL THEN

         pa_cc_utils.log_message('P_labor_Cost_Mult_Name '||P_labor_Cost_Mult_Name);

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
         pa_cc_utils.log_message('l_cost_multiplier '||l_cost_multiplier);

    END IF;


       ----------------------------------------
       -- Calulating Raw cost and Raw cost rate
       ----------------------------------------
/*LCE :Changed l_labor_cost_rate to l_acct_cost_rate */

       l_x_raw_cost_rate := l_acct_cost_rate * NVL(l_cost_multiplier,1);

       l_x_Raw_cost      := pa_currency.round_trans_currency_amt(
                            l_x_raw_cost_rate * NVL(p_quantity,0), px_exp_func_curr_code);

         pa_cc_utils.log_message('l_x_raw_cost_rate '||l_x_raw_cost_rate||' l_x_Raw_cost '||l_x_Raw_cost);

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
         pa_cc_utils.log_message('inside l_exp_func_curr_code_null exception ');
        /* Checking error condition. Added for bug 2218386 */
        IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
           PA_UTILS.add_message('PA', 'PA_FCST_EXP_CURR_CODE_NULL');
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        x_msg_count     :=  1;
        x_msg_data      :=  'PA_FCST_EXP_CURR_CODE_NULL';

   WHEN NO_DATA_FOUND THEN
         pa_cc_utils.log_message('inside NO_DATA_FOUND exception ');

        x_raw_cost_rate   := 0;
        x_raw_cost        := 0;
        /* Checking error condition. Added for bug 2218386 */
        IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
           PA_UTILS.add_message('PA', 'PA_FCST_NO_COST_RATE');
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        x_msg_count     :=  1;
        x_msg_data      :=  'PA_FCST_NO_COST_RATE';

   WHEN l_raw_cost_null THEN
         pa_cc_utils.log_message('inside l_raw_cost_null exception ');

        x_raw_cost_rate   := 0;
        x_raw_cost        := 0;
        /* Checking error condition. Added for bug 2218386 */
        IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
           PA_UTILS.add_message('PA', 'PA_FCST_NO_COST_RATE');
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        x_msg_count     :=  1;
        x_msg_data      :=  'PA_FCST_NO_COST_RATE';

   /*LCE changes*/
   WHEN user_exception THEN
         pa_cc_utils.log_message('inside user_exception exception ');

      IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
           PA_UTILS.add_message('PA',l_err_code);
      END IF;
      x_return_status   := FND_API.G_RET_STS_ERROR;
      x_msg_count       :=  1;
      x_msg_data        :=  l_err_code;
  /*End of LCE changes*/

   WHEN OTHERS THEN
         pa_cc_utils.log_message('inside others exception '||SUBSTR(SQLERRM,1,300));

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR(SQLERRM,1,30);
        /* Checking error condition. Added for bug 2218386 */
        IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
           FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_COST', /* Moved this here to fix bug 2434663 */
                                    p_procedure_name => 'Get_Raw_Cost');
          RAISE;
        END IF;
END Get_Raw_Cost;



PROCEDURE Override_exp_organization(P_item_date                IN  DATE      ,
                           P_person_id                         IN  NUMBER    ,
                           P_project_id                        IN  NUMBER    ,
                           P_incurred_by_organz_id             IN  NUMBER    ,
                           P_Expenditure_type                  IN  VARCHAR2  ,
                           X_overr_to_organization_id          OUT NOCOPY NUMBER    ,
                           X_return_status                     OUT NOCOPY VARCHAR2  ,
                           X_msg_count                         OUT NOCOPY NUMBER    ,
                           X_msg_data                          OUT NOCOPY VARCHAR2
                          )
IS


l_x_override_to_org_id         NUMBER;
-- l_override_organz_id_null      EXCEPTION;


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
/*Removed pa_expenditure_types from 'from' clause as it is not used Bug # 2634995 */

          SELECT OVERRIDE_TO_ORGANIZATION_ID
            INTO l_x_override_to_org_id
            FROM pa_cost_dist_overrides CDO
			--,pa_expenditure_types   ET
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
        /*Removed pa_expenditure_types from 'from' clause as it is not used Bug # 2634995 */

        SELECT OVERRIDE_TO_ORGANIZATION_ID
          INTO l_x_override_to_org_id
          FROM pa_cost_dist_overrides CDO
		  --,pa_expenditure_types   ET
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

  /*   IF (l_x_override_to_org_id IS NULL) THEN

         RAISE l_override_organz_id_null;

     END IF;  */


     ----------------------------------------------------
     --Assign override to org Id into the output variable
     ----------------------------------------------------

     x_overr_to_organization_id  := l_x_override_to_org_id;


     -------------------------------------------------------
     -- Assign the successful status back to output variable
     -------------------------------------------------------

     x_return_status := l_x_return_status;


EXCEPTION
   WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := 1;
        x_msg_data := SUBSTR(SQLERRM,1,30);
        IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
          FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_COST', /* Moved this here to fix bug 2434663 */
                                   p_procedure_name => 'Override_exp_organization');
        END IF;

END Override_exp_organization;



PROCEDURE Get_Burdened_cost(p_project_type          IN      VARCHAR2 ,
                            p_project_id            IN      NUMBER   ,
                            p_task_id               IN      NUMBER   ,
                            p_item_date             IN      DATE     ,
                            p_expenditure_type      IN      VARCHAR2 ,
                            p_schedule_type         IN      VARCHAR2 ,
                            px_exp_func_curr_code   IN OUT NOCOPY  VARCHAR2 ,
                            p_Incurred_by_organz_id IN      NUMBER   ,
                            p_raw_cost              IN      NUMBER   ,
                            p_raw_cost_rate         IN      NUMBER   ,
                            p_quantity              IN      NUMBER   ,
                            p_override_to_organz_id IN      NUMBER   ,
                            x_burden_cost           OUT NOCOPY     NUMBER   ,
                            x_burden_cost_rate      OUT NOCOPY     NUMBER   ,
                            x_return_status         OUT NOCOPY     VARCHAR2 ,
                            x_msg_count             OUT NOCOPY     NUMBER   ,
                            x_msg_data              OUT NOCOPY     VARCHAR2
                           )
IS

l_burden_cost_flag                  pa_project_types_all.burden_cost_flag%TYPE;
l_burden_amt_disp_method            pa_project_types_all.burden_amt_display_method%TYPE;
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


BEGIN


     --------------------------------------------
     -- Initialize the successfull return status
     --------------------------------------------

	print_msg('Inside Get_Burdened_cost API IN params: prjtype['||p_project_type||
		 ']prjId['||p_project_id||']taskid['||p_task_id||']ItemDate['||p_item_date||
		 ']expType['||p_expenditure_type||']schType['||p_schedule_type||
		 ']expFuncurr['||px_exp_func_curr_code||']IncOrgId['||p_Incurred_by_organz_id||
		 ']Rawcost['||p_raw_cost||']CostRate['||p_raw_cost_rate||']Qty['||p_quantity||
                 ']OverrideOrgId['||p_override_to_organz_id||']');

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
     -- Bug 7423839 removed refernce to project type
       SELECT burden_cost_flag
         INTO l_burden_cost_flag
         FROM pa_project_types_all typ, pa_projects_all proj
        WHERE proj.project_id = p_project_id
        AND   proj.project_type = typ.project_type
        AND   proj.org_id = typ.org_id; -- bug 5365286
/* Commented for Bug 7423839
       SELECT burden_cost_flag
         INTO l_burden_cost_flag
         FROM pa_project_types_all typ, pa_projects_all proj
        WHERE typ.project_type = P_project_type
        AND   proj.project_type = typ.project_type
        AND   proj.project_id = p_project_id
        AND   proj.org_id = typ.org_id; -- bug 5365286
        -- AND   nvl(proj.org_id,-99)   = nvl(typ.org_id,-99); -- bug 5365286
*/

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
      print_msg('calling get_schedule_id API');
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
	print_msg('After get_schedule_id['||l_x_burden_sch_revision_id||']date['||l_x_burden_sch_fixed_date||']');


         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN

             RAISE l_invalid_schedule_id;

         END IF;


          --------------------------------------------------------------------
          -- Get cost plus structure for the given burden schdeule revision id
          --------------------------------------------------------------------

            l_burden_sch_revision_id  := l_x_burden_sch_revision_id;

	    print_msg('Calling get_cost_plus_structure API');

            pa_cost_plus.get_cost_plus_structure(l_burden_sch_revision_id,
                                                 l_x_cp_structure        ,
                                                 l_x_status              ,
                                                 l_x_stage
                                                );
	    print_msg('After get_cost_plus_structure ['||l_x_cp_structure||']l_x_stage['||l_x_stage);

            IF (l_x_status <> 0) THEN

                RAISE l_cost_plus_struture_not_found;

            END IF;


          ------------------------------------------------------------------------
          -- Get Cost Base for the given Expenditure Type and Cost plus structure
          ------------------------------------------------------------------------

            l_cp_structure := l_x_cp_structure;

	    print_msg('Calling get_cost_base API');

            pa_cost_plus.get_cost_base(P_expenditure_type     ,
                                       l_cp_structure         ,
                                       l_x_cost_base          ,
                                       l_x_status             ,
                                       l_x_stage
                                      );
	   print_msg('After get_cost_base ['||l_x_cost_base||']l_x_stage['||l_x_stage||']');

           IF (l_x_status <> 0) THEN

              RAISE l_cost_base_not_found;

           END IF;


         -------------------------------------------------------------------------------
         -- Get compiled Multiplier for the given Expenditure Org, Cost Base,
         -- Burden schedule revision id. If override to organization id is not null then
         -- consider it as expenditure Org. If Override to organization is null then
         -- consider Incurred by organization is an expenditure Org.
         ------------------------------------------------------------------------------


            l_expenditure_org_id := NVL(p_override_to_organz_id, P_Incurred_by_organz_id);


            ------------------------------
            -- Get the compiled multiplier
            ------------------------------

            l_cost_base := l_x_cost_base;

	    print_msg('Calling get_compiled_multiplier API');

            pa_cost_plus.get_compiled_multiplier(l_expenditure_org_id     ,
                                                 l_cost_base              ,
                                                 l_burden_sch_revision_id ,
                                                 l_x_compiled_multiplier  ,
                                                 l_x_status               ,
                                                 l_x_stage
                                                 );

	   print_msg('After Calling get_compiled_multiplier ['||l_x_compiled_multiplier||']');


            IF (l_x_status <> 0) THEN

                RAISE l_comp_multiplier_not_found;

            END IF;


            -------------------------------------------------------
            -- Get Burden Cost and rate from Raw Cost and Quantity.
            -------------------------------------------------------

            l_burden_cost       := pa_currency.round_trans_currency_amt(
                                            l_raw_cost * l_x_compiled_multiplier,px_exp_func_curr_code) +
                                            l_raw_cost ;

              -- Bug 4434977 -- corrected logic for burden cost rate to avoid rounding error.
                             -- by giving precedence to raw_cost_rate before amout and quantiy based logic.
               If  (nvl(p_raw_cost_rate,0)  <> 0) Then
                   l_burden_cost_rate  := p_raw_cost_rate * ( 1 + l_x_compiled_multiplier );
               Else
                   If (nvl(P_quantity,0) <> 0 ) THEN  /* Added for Org forecasting */
                      l_burden_cost_rate  := l_burden_cost / P_quantity;
                   End If;
               End If;

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
    WHEN l_raw_cost_null THEN
         x_burden_cost      := 0;
         x_burden_cost_rate := 0;

         /* Checking error condition. Added for bug 2218386 */
         IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
           PA_UTILS.add_message('PA', 'PA_FCST_NO_COST_RATE');
         END IF;

         x_return_status :=  FND_API.G_RET_STS_ERROR;
         x_msg_count     :=  1;
         x_msg_data      :=  'PA_FCST_NO_COST_RATE';

    WHEN l_done_burden_cost_calc THEN
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         x_msg_count := NULL;
         x_msg_data  := NULL;

    WHEN l_cost_plus_struture_not_found THEN

         /* Checking error condition. Added for bug 2218386 */
         IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
           PA_UTILS.add_message('PA', 'PA_FCST_NO_COST_PLUS_ST');
         END IF;

         x_return_status :=  FND_API.G_RET_STS_ERROR;
         x_msg_count     :=  1;
         x_msg_data      :=  'PA_FCST_NO_COST_PLUS_ST';

    WHEN l_cost_base_not_found THEN

         /* Checking error condition. Added for bug 2218386 */
         IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
            PA_UTILS.add_message('PA', 'PA_FCST_COST_BASE_NOT_FOUND');
         END IF;

         x_return_status :=  FND_API.G_RET_STS_ERROR;
         x_msg_count     :=  1;
         x_msg_data      :=  'PA_FCST_COST_BASE_NOT_FOUND';

    WHEN l_comp_multiplier_not_found THEN

         /* Checking error condition. Added for bug 2218386 */
         IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
            PA_UTILS.add_message('PA', 'PA_FCST_NO_COMPILED_MULTI');
         END IF;

         x_return_status :=  FND_API.G_RET_STS_ERROR;
         x_msg_count     :=  1;
         x_msg_data      :=  'PA_FCST_NO_COMPILED_MULTI';

    WHEN l_invalid_schedule_id THEN

         /* Checking error condition. Added for bug 2218386 */
         IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
            PA_UTILS.add_message('PA', 'PA_FCST_INVL_BURDEN_SCH_REV_ID');
         END IF;

         x_return_status :=  FND_API.G_RET_STS_ERROR;
         x_msg_count     :=  1;
         x_msg_data      :=  'PA_FCST_INVL_BURDEN_SCH_REV_ID';

    WHEN l_burden_cost_null THEN
         x_burden_cost      := 0;
         x_burden_cost_rate := 0;

         /* Checking error condition. Added for bug 2218386 */
         IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
            PA_UTILS.add_message('PA', 'PA_FCST_NO_COST_RATE');
         END IF;

         x_return_status :=  FND_API.G_RET_STS_ERROR;
         x_msg_count     :=  1;
         x_msg_data      :=  'PA_FCST_NO_COST_RATE';

    WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_count := 1;
         x_msg_data  := SUBSTR(SQLERRM,1,30);
	 print_msg('Others Exception:l_x_stage['||l_x_stage||']'||SQLERRM||SQLCODE);
        /* Checking error condition. Added for bug 2218386 */
        IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_COST', /* Moved this here to fix bug 2434663 */
                                  p_procedure_name => 'Get_Burden_cost');
          RAISE;
        END IF;

END Get_burdened_cost;


/* Changed the name of the procedure from get_proj_raw_burdened_cost to
   get_projfunc_raw_burdened_cost and changed the params also for MCB II */

/* Changed the name of this proc from Get_projfunc_raw_Burdened_cost to
   Get_Converted_Cost_Amounts for Org Forecasting */

PROCEDURE  Get_Converted_Cost_Amounts(

              P_exp_org_id                   IN      NUMBER,
              P_proj_org_id                  IN      NUMBER,
              P_project_id                   IN      NUMBER,
              P_task_id                      IN      NUMBER,
              P_item_date                    IN      DATE,
              p_system_linkage               IN     pa_expenditure_items_all.system_linkage_function%TYPE,/* Added */
                                                    /* for Org Forecasting */
              px_txn_curr_code               IN  OUT NOCOPY VARCHAR2,/* Added for Org Forecasting */
              px_raw_cost                    IN  OUT NOCOPY NUMBER,  /* Txn raw cost,change from IN */
                                                              /* to IN OUT for Org forecasting */
              px_raw_cost_rate               IN  OUT NOCOPY NUMBER,  /* Txn raw cost rate,change from IN to */
                                                              /* IN OUT for Org forecasting */
              px_burden_cost                 IN  OUT NOCOPY NUMBER,  /* Txn burden cost,change from IN to */
                                                              /* IN OUT for Org forecasting */
              px_burden_cost_rate            IN  OUT NOCOPY NUMBER,  /* Txn burden cost rate,change from IN to */
                                                              /* IN OUT for Org forecasting */
              px_exp_func_curr_code          IN  OUT NOCOPY VARCHAR2,
              px_exp_func_rate_date          IN  OUT NOCOPY DATE,    /* Added for Org Forecasting */
              px_exp_func_rate_type          IN  OUT NOCOPY VARCHAR2,/* Added for Org Forecasting */
              px_exp_func_exch_rate          IN  OUT NOCOPY NUMBER,  /* Added for Org Forecasting */
              px_exp_func_cost               IN  OUT NOCOPY NUMBER,  /* Added for Org Forecasting */
              px_exp_func_cost_rate          IN  OUT NOCOPY NUMBER,  /* Added for Org Forecasting */
              px_exp_func_burden_cost        IN  OUT NOCOPY NUMBER,  /* Added for Org Forecasting */
              px_exp_func_burden_cost_rate   IN  OUT NOCOPY NUMBER,  /* Added for Org Forecasting */
              px_proj_func_curr_code         IN  OUT NOCOPY VARCHAR2,
              px_projfunc_cost_rate_date     IN  OUT NOCOPY DATE,    /* Added for Org Forecasting */
              px_projfunc_cost_rate_type     IN  OUT NOCOPY VARCHAR2,/* Added for Org Forecasting */
              px_projfunc_cost_exch_rate     IN  OUT NOCOPY NUMBER,  /* Added for Org Forecasting */
              px_projfunc_raw_cost           IN  OUT NOCOPY NUMBER , /* The following 4 para name changed for MCB II */
                                                              /* change from OUT to IN OUT for Org forecasting */
              px_projfunc_raw_cost_rate      IN  OUT NOCOPY NUMBER , /* change from OUT to IN OUT for Org forecasting */
              px_projfunc_burden_cost        IN  OUT NOCOPY NUMBER , /* change from OUT to IN OUT for Org forecasting */
              px_projfunc_burden_cost_rate   IN  OUT NOCOPY NUMBER , /* change from OUT to IN OUT for Org forecasting */
              px_project_curr_code           IN  OUT NOCOPY VARCHAR2,/* Added for Org Forecasting */
              px_project_rate_date           IN  OUT NOCOPY DATE,    /* Added for Org Forecasting */
              px_project_rate_type           IN  OUT NOCOPY VARCHAR2,/* Added for Org Forecasting */
              px_project_exch_rate           IN  OUT NOCOPY NUMBER,  /* Added for Org Forecasting */
              px_project_cost                IN  OUT NOCOPY NUMBER,  /* Added for Org Forecasting */
              px_project_cost_rate           IN  OUT NOCOPY NUMBER,  /* Added for Org Forecasting */
              px_project_burden_cost         IN  OUT NOCOPY NUMBER,  /* Added for Org Forecasting */
              px_project_burden_cost_rate    IN  OUT NOCOPY NUMBER,  /* Added for Org Forecasting */
              x_return_status                OUT NOCOPY     VARCHAR2  ,
              x_msg_count                    OUT NOCOPY     NUMBER    ,
              x_msg_data                     OUT NOCOPY     VARCHAR2
                                     )
IS

l_proj_org_id                    pa_projects_all.org_id%TYPE;
l_exp_org_id                     pa_project_assignments.expenditure_org_id%TYPE; /* Changed for Org Forecasting */
l_txn_raw_cost                   NUMBER; /* Added for Org Forecasting */
l_txn_raw_cost_rate              NUMBER; /* Added for Org Forecasting */
l_txn_burden_cost                NUMBER; /* Added for Org Forecasting */
l_txn_burden_cost_rate           NUMBER; /* Added for Org Forecasting */
l_txn_currency_code              fnd_currencies.currency_code%TYPE; /* Added for Org Forecasting */
l_project_currency_code          fnd_currencies.currency_code%TYPE; /* Added for Org Forecasting */
l_proj_func_curr_code            fnd_currencies.currency_code%TYPE;
l_exp_func_curr_code             fnd_currencies.currency_code%TYPE;
l_projfunc_rate_date             DATE; /* changed the name of these varible for MCB 2 */
l_projfunc_rate_type             VARCHAR2(30);
l_x_projfunc_raw_cost            NUMBER;
l_x_projfunc_raw_cost_rate       NUMBER;
l_x_projfunc_burden_cost         NUMBER;
l_x_projfunc_burden_cost_rate    NUMBER; /* Till here  for MCB 2 */
l_denominator                    NUMBER;
l_numerator                      NUMBER;
l_exchange_rate                  NUMBER;


x_status                         NUMBER;

l_multi_status                   VARCHAR2(30); /* Added for Org Forecasting */
l_stage                          NUMBER;       /* Added for Org Forecasting */


l_done_proj_cost_calc            EXCEPTION;
l_invalid_rate_date_type         EXCEPTION;

-- l_status                         VARCHAR2(100); /* Added for bug 2238712 */
-- l_conversion_fail                EXCEPTION; /* Added for bug 2238712 */

BEGIN


     --------------------------------------------
     -- Initialize the successfull return status
     --------------------------------------------

      l_x_return_status := FND_API.G_RET_STS_SUCCESS;



      ---------------------------------------------
      -- Check If Input Raw Cost is null
      ---------------------------------------------

      IF (px_raw_cost IS NULL) THEN /* Changed for Org Forecasting */

          RAISE l_raw_cost_null;

      END IF;


     ---------------------------------------------
      -- Check If Input Burden cost is null
      ---------------------------------------------

      IF  (px_burden_cost IS NULL) THEN /* Changed for Org Forecasting */

          RAISE l_burden_cost_null;

      END IF;


      -------------------------------------------------------------------------------
      -- Assigning the denorm raw cost, rate and burden cost, rate to local variable
      ------------------------------------------------------------------------------
        l_txn_raw_cost                   :=  px_raw_cost;                /* Added for Org Forecasting */
        l_txn_raw_cost_rate              :=  NVL(px_raw_cost_rate,0);    /* Added for Org Forecasting */
        l_txn_burden_cost                :=  px_burden_cost;             /* Added for Org Forecasting */
        l_txn_burden_cost_rate           :=  NVL(px_burden_cost_rate,0); /* Added for Org Forecasting */

      -------------------------------------------
      -- Get Project functional currency code
      -------------------------------------------


      IF (px_proj_func_curr_code IS NULL) THEN

          px_proj_func_curr_code  := get_curr_code(p_proj_org_id);
          l_proj_func_curr_code   := px_proj_func_curr_code; /* Added for Org Forecasting */
      ELSE
          l_proj_func_curr_code   := px_proj_func_curr_code; /* Added for Org Forecasting */
      END IF;


      IF (px_proj_func_curr_code IS NULL) THEN

         RAISE l_proj_func_curr_code_null;

      END IF;


      -------------------------------------------
      -- Get Expenditure functional currency code
      -------------------------------------------


      IF (px_exp_func_curr_code IS NULL) THEN

          px_exp_func_curr_code  := get_curr_code(p_exp_org_id);
          l_exp_func_curr_code   := px_exp_func_curr_code; /* Added for Org Forecasting */
          l_txn_currency_code    := px_exp_func_curr_code; /* Added for Org Forecasting */
      ELSE
          l_exp_func_curr_code   := px_exp_func_curr_code; /* Added for Org Forecasting */
          l_txn_currency_code    := px_exp_func_curr_code; /* Added for Org Forecasting */
      END IF;


      IF (px_exp_func_curr_code IS NULL) THEN

         RAISE l_exp_func_curr_code_null;

      END IF;

      -------------------------------------------
      -- Get Project currency code
      -------------------------------------------

      IF (px_project_curr_code IS NOT NULL) THEN

          l_project_currency_code   := px_project_curr_code; /* Added for Org Forecasting */

      END IF;


  /*  COMMENTED FOR ORG FORECASTING, BECAUSE GOING TO CALL COSTING PROCEDURE
      WHICH WILL GIVE THE AMOUNTS IN ALL THE CURRENCIES

      -------------------------------------------------------------------------------
      -- If expenditure org and project org are same then project raw and burden cost
      -- are equal to transaction raw and burden cost
      -------------------------------------------------------------------------------
      IF (NVL(P_exp_org_id,-99) = NVL(P_proj_org_id,-99)) THEN
           x_projfunc_raw_cost         := p_raw_cost;
           x_projfunc_raw_cost_rate    := p_raw_cost_rate;
           x_projfunc_burden_cost      := p_burden_cost;
           x_projfunc_burden_cost_rate := p_burden_cost_rate;
           RAISE l_done_proj_cost_calc;
      END IF;
      l_projfunc_rate_date := NULL;
      l_projfunc_rate_type := NULL;
      IF (p_task_id IS NOT NULL) THEN
        BEGIN
          -- Get the project_rate_date and project_rate_type
          SELECT NVL(tsk.project_rate_date,
                 DECODE(imp.default_rate_date_code,'E',p_item_date,
                                                 'P',get_pa_date(p_item_date,p_exp_org_id))),
                 NVL(tsk.project_rate_type, imp.default_rate_type)
            INTO l_projfunc_rate_date,
                 l_projfunc_rate_type
            FROM pa_projects_all prj,
                 pa_tasks tsk,
                 pa_implementations_all imp
           WHERE prj.project_id = p_project_id
             AND prj.project_id = tsk.project_id
             AND tsk.task_id    = p_task_id
             AND nvl(prj.org_id ,-99)   = nvl(imp.org_id,-99)
             AND nvl(imp.org_id,-99)    = nvl(p_proj_org_id,-99);
           EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    l_projfunc_rate_date := NULL;
                    l_projfunc_rate_type := NULL;
        END;
      END IF;
      IF (l_projfunc_rate_type IS NULL) THEN
         -- Get the Project Rate Date and Rate Type
         BEGIN
         -- Selecting projfunc_cost_rate_type,projfunc_cost_rate_date in place of project_rate_date
         --  project_rate_type for MCB 2
          SELECT NVL(prj.projfunc_cost_rate_date,
                 DECODE(imp.default_rate_date_code,'E',p_item_date,
                                                   'P',get_pa_date(p_item_date,p_exp_org_id))),
                 NVL(prj.projfunc_cost_rate_type, imp.default_rate_type)
            INTO l_projfunc_rate_date,
                 l_projfunc_rate_type
            FROM pa_projects_all prj,
                 pa_implementations_all imp
           WHERE prj.project_id = p_project_id
             AND nvl(prj.org_id,-99)     = nvl(imp.org_id,-99)
             AND nvl(imp.org_id,-99)     = nvl(p_proj_org_id,-99);
           EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    l_projfunc_rate_date := NULL;
                    l_projfunc_rate_type := NULL;
        END;
      END IF;
      IF (l_projfunc_rate_type IS NULL)  OR  (l_projfunc_rate_date IS NULL) THEN
         RAISE l_invalid_rate_date_type ;
      END IF;

       -------------------------------
       -- Get the Project Raw cost
       -------------------------------
       pa_multi_currency.convert_amount(px_exp_func_curr_code      ,
                                        px_proj_func_curr_code     ,
                                        l_projfunc_rate_date          ,
                                        l_projfunc_rate_type          ,
                                        p_Raw_cost                ,
                                        'N'                       ,
                                 --     'N'                       ,  commented for bug 2238712
                                        'Y'                       ,
                                        l_x_projfunc_raw_cost         ,
                                        l_denominator             ,
                                        l_numerator               ,
                                        l_exchange_rate           ,
                               --        x_status               commented for bug 2238712
                                        l_status
                                       );

      -- Added for bug 2238712
       IF (l_status IS NOT NULL) THEN
           RAISE l_conversion_fail;
       END IF;
       ------------------------------------
       -- Get the Project Raw cost rate
       ------------------------------------
                 pa_multi_currency.convert_amount(px_exp_func_curr_code      ,
                                        px_proj_func_curr_code     ,
                                        l_projfunc_rate_date          ,
                                        l_projfunc_rate_type          ,
                                        p_Raw_cost_rate           ,
                                        'N'                       ,
                                 --     'N'                       ,  commented for bug 2238712
                                        'Y'                       ,
                                        l_x_projfunc_raw_cost_rate    ,
                                        l_denominator             ,
                                        l_numerator               ,
                                        l_exchange_rate           ,
                               --        x_status               commented for bug 2238712
                                        l_status
                                       );
      -- Added for bug 2238712
       IF (l_status IS NOT NULL) THEN
           RAISE l_conversion_fail;
       END IF;
       IF (l_x_projfunc_raw_cost IS NULL) THEN
           RAISE l_raw_cost_null;
       END IF;
       x_projfunc_raw_cost      := l_x_projfunc_raw_cost;
       x_projfunc_raw_cost_rate := l_x_projfunc_raw_cost_rate;
       ------------------------------
       -- Get the Project Burden cost
       ------------------------------
       pa_multi_currency.convert_amount(px_exp_func_curr_code      ,
                                        px_proj_func_curr_code     ,
                                        l_projfunc_rate_date          ,
                                        l_projfunc_rate_type          ,
                                        p_burden_cost             ,
                                        'N'                       ,
                                 --     'N'                       ,  commented for bug 2238712
                                        'Y'                       ,
                                        l_x_projfunc_burden_cost      ,
                                        l_denominator             ,
                                        l_numerator               ,
                                        l_exchange_rate           ,
                               --        x_status               commented for bug 2238712
                                        l_status
                                       );
      -- Added for bug 2238712
       IF (l_status IS NOT NULL) THEN
           RAISE l_conversion_fail;
       END IF;
       ------------------------------------
       -- Get the Project Burden cost rate
       -------------------------------------
       pa_multi_currency.convert_amount(px_exp_func_curr_code      ,
                                        px_proj_func_curr_code     ,
                                        l_projfunc_rate_date          ,
                                        l_projfunc_rate_type          ,
                                        p_burden_cost_rate        ,
                                        'N'                       ,
                                 --     'N'                       ,  commented for bug 2238712
                                        'Y'                       ,
                                        l_x_projfunc_burden_cost_rate ,
                                        l_denominator             ,
                                        l_numerator               ,
                                        l_exchange_rate           ,
                               --        x_status               commented for bug 2238712
                                        l_status
                                       );
      -- Added for bug 2238712
       IF (l_status IS NOT NULL) THEN
           RAISE l_conversion_fail;
       END IF;
       IF (l_x_projfunc_burden_cost IS NULL) THEN
           RAISE l_burden_cost_null;
       END IF;
       x_projfunc_burden_cost      := l_x_projfunc_burden_cost;
       x_projfunc_burden_cost_rate := l_x_projfunc_burden_cost_rate;

   TILL HERE  FOR ORG FORECASTING */



    IF (P_exp_org_id IS NULL ) THEN
        l_exp_org_id := -99;
    ELSE /* 2868851 */
        l_exp_org_id := P_exp_org_id;
    END IF;


       ----------------------------------------------------------------------------
       -- Get the Raw cost in Project, Project Functional, and Expenditure currency
       ---------------------------------------------------------------------------
         -- DBMS_OUTPUT.PUT_LINE(' IN COST date '||p_item_date);
     PA_MULTI_CURRENCY_TXN.get_currency_amounts(
                        P_project_id                  => p_project_id ,
                        P_exp_org_id                  => l_exp_org_id ,
                        P_calling_module              => 'FORECAST',
                        P_task_id                     => P_task_id,
                        P_EI_date                     => p_item_date,
                        p_system_linkage              => p_system_linkage,
                        P_denom_raw_cost              => l_txn_raw_cost,
                        P_denom_curr_code             => l_txn_currency_code,
                        P_acct_curr_code              => l_exp_func_curr_code,
                        P_acct_rate_date              => px_exp_func_rate_date,
                        P_acct_rate_type              => px_exp_func_rate_type,
                        P_acct_exch_rate              => px_exp_func_exch_rate,
                        P_acct_raw_cost               => px_exp_func_cost,
                        P_project_curr_code           => l_project_currency_code,
                        P_project_rate_date           => px_project_rate_date,
                        P_project_rate_type           => px_project_rate_type ,
                        P_project_exch_rate           => px_project_exch_rate,
                        P_project_raw_cost            => px_project_cost,
                        P_projfunc_curr_code          => l_proj_func_curr_code,
                        P_projfunc_cost_rate_date     => px_projfunc_cost_rate_date,
                        P_projfunc_cost_rate_type     => px_projfunc_cost_rate_type ,
                        P_projfunc_cost_exch_rate     => px_projfunc_cost_exch_rate,
                        P_projfunc_raw_cost           => px_projfunc_raw_cost,
                        P_status                      => l_multi_status,
                        P_stage                       => l_stage) ;

         -- DBMS_OUTPUT.PUT_LINE(' IN COST L_STATUS '||l_multi_status||' amount '||px_projfunc_raw_cost);

          IF ( l_multi_status IS NOT NULL ) THEN
             -- Error in get_currency_amounts
             RAISE l_multi_conversion_fail;
          END IF;


       ---------------------------------------------------------------------------------------
       -- Get the Raw cost rate in Project, Project Functional, and Expenditure currency
       ---------------------------------------------------------------------------------------

     PA_MULTI_CURRENCY_TXN.get_currency_amounts(
                        P_project_id                  => p_project_id ,
                        P_exp_org_id                  => l_exp_org_id ,
                        P_calling_module              => 'FORECAST',
                        P_task_id                     => P_task_id,
                        P_EI_date                     => p_item_date,
                        p_system_linkage              => p_system_linkage,
                        P_denom_raw_cost              => l_txn_raw_cost_rate,
                        P_denom_curr_code             => l_txn_currency_code,
                        P_acct_curr_code              => l_exp_func_curr_code,
                        P_acct_rate_date              => px_exp_func_rate_date,
                        P_acct_rate_type              => px_exp_func_rate_type,
                        P_acct_exch_rate              => px_exp_func_exch_rate,
                        P_acct_raw_cost               => px_exp_func_cost_rate,
                        P_project_curr_code           => l_project_currency_code,
                        P_project_rate_date           => px_project_rate_date,
                        P_project_rate_type           => px_project_rate_type ,
                        P_project_exch_rate           => px_project_exch_rate,
                        P_project_raw_cost            => px_project_cost_rate,
                        P_projfunc_curr_code          => l_proj_func_curr_code,
                        P_projfunc_cost_rate_date     => px_projfunc_cost_rate_date,
                        P_projfunc_cost_rate_type     => px_projfunc_cost_rate_type ,
                        P_projfunc_cost_exch_rate     => px_projfunc_cost_exch_rate,
                        P_projfunc_raw_cost           => px_projfunc_raw_cost_rate,
                        P_status                      => l_multi_status,
                        P_stage                       => l_stage) ;

         -- DBMS_OUTPUT.PUT_LINE(' IN COST  1 L_STATUS '||l_multi_status||' rate '||px_projfunc_raw_cost_rate);
          IF ( l_multi_status IS NOT NULL ) THEN
             -- Error in get_currency_amounts
             RAISE l_multi_conversion_fail;
          END IF;

       IF (px_projfunc_raw_cost IS NULL) THEN

           -- dbms_output.put_line(' IN COST API');
           RAISE l_raw_cost_null;

       END IF;


       ----------------------------------------------------------------------------
       -- Get the Burden cost in Project, Project Functional, and Expenditure currency
       ---------------------------------------------------------------------------
     PA_MULTI_CURRENCY_TXN.get_currency_amounts(
                        P_project_id                  => p_project_id ,
                        P_exp_org_id                  => l_exp_org_id ,
                        P_calling_module              => 'FORECAST',
                        P_task_id                     => P_task_id,
                        P_EI_date                     => p_item_date,
                        p_system_linkage              => p_system_linkage,
                        P_denom_raw_cost              => l_txn_burden_cost,
                        P_denom_curr_code             => l_txn_currency_code,
                        P_acct_curr_code              => l_exp_func_curr_code,
                        P_acct_rate_date              => px_exp_func_rate_date,
                        P_acct_rate_type              => px_exp_func_rate_type,
                        P_acct_exch_rate              => px_exp_func_exch_rate,
                        P_acct_raw_cost               => px_exp_func_burden_cost,
                        P_project_curr_code           => l_project_currency_code,
                        P_project_rate_date           => px_project_rate_date,
                        P_project_rate_type           => px_project_rate_type ,
                        P_project_exch_rate           => px_project_exch_rate,
                        P_project_raw_cost            => px_project_burden_cost,
                        P_projfunc_curr_code          => l_proj_func_curr_code,
                        P_projfunc_cost_rate_date     => px_projfunc_cost_rate_date,
                        P_projfunc_cost_rate_type     => px_projfunc_cost_rate_type ,
                        P_projfunc_cost_exch_rate     => px_projfunc_cost_exch_rate,
                        P_projfunc_raw_cost           => px_projfunc_burden_cost,
                        P_status                      => l_multi_status,
                        P_stage                       => l_stage) ;

         -- DBMS_OUTPUT.PUT_LINE(' IN COST  2 L_STATUS '||l_multi_status);
         -- DBMS_OUTPUT.PUT_LINE(' IN COST px_project_burden_cost '||l_multi_status||' amount '||px_project_burden_cost);
          IF ( l_multi_status IS NOT NULL ) THEN
             -- Error in get_currency_amounts
             RAISE l_multi_conversion_fail;
          END IF;


       ---------------------------------------------------------------------------------------
       -- Get the Burden cost rate in Project, Project Functional, and Expenditure currency
       ---------------------------------------------------------------------------------------

     PA_MULTI_CURRENCY_TXN.get_currency_amounts(
                        P_project_id                  => p_project_id ,
                        P_exp_org_id                  => l_exp_org_id ,
                        P_calling_module              => 'FORECAST',
                        P_task_id                     => P_task_id,
                        P_EI_date                     => p_item_date,
                        p_system_linkage              => p_system_linkage,
                        P_denom_raw_cost              => l_txn_burden_cost_rate,
                        P_denom_curr_code             => l_txn_currency_code,
                        P_acct_curr_code              => l_exp_func_curr_code,
                        P_acct_rate_date              => px_exp_func_rate_date,
                        P_acct_rate_type              => px_exp_func_rate_type,
                        P_acct_exch_rate              => px_exp_func_exch_rate,
                        P_acct_raw_cost               => px_exp_func_burden_cost_rate,
                        P_project_curr_code           => l_project_currency_code,
                        P_project_rate_date           => px_project_rate_date,
                        P_project_rate_type           => px_project_rate_type ,
                        P_project_exch_rate           => px_project_exch_rate,
                        P_project_raw_cost            => px_project_burden_cost_rate,
                        P_projfunc_curr_code          => l_proj_func_curr_code,
                        P_projfunc_cost_rate_date     => px_projfunc_cost_rate_date,
                        P_projfunc_cost_rate_type     => px_projfunc_cost_rate_type ,
                        P_projfunc_cost_exch_rate     => px_projfunc_cost_exch_rate,
                        P_projfunc_raw_cost           => px_projfunc_burden_cost_rate,
                        P_status                      => l_multi_status,
                        P_stage                       => l_stage) ;

         -- DBMS_OUTPUT.PUT_LINE(' IN COST  3 L_STATUS '||l_multi_status);
          IF ( l_multi_status IS NOT NULL ) THEN
             -- Error in get_currency_amounts
             RAISE l_multi_conversion_fail;
          END IF;

       IF (px_projfunc_burden_cost IS NULL) THEN

           -- dbms_output.put_line(' IN COST API');
           RAISE l_burden_cost_null;

       END IF;

      -------------------------------------------------------------------------------
      -- Assigning back the local varible to in out parameters
      ------------------------------------------------------------------------------
        px_raw_cost            := l_txn_raw_cost;           /* Added for Org Forecasting */
        px_raw_cost_rate       := l_txn_raw_cost_rate;      /* Added for Org Forecasting */
        px_burden_cost         := l_txn_burden_cost;        /* Added for Org Forecasting */
        px_burden_cost_rate    := l_txn_burden_cost_rate;   /* Added for Org Forecasting */
        px_proj_func_curr_code := l_proj_func_curr_code;    /* Added for Org Forecasting */
        px_exp_func_curr_code  := l_exp_func_curr_code;     /* Added for Org Forecasting */
        px_txn_curr_code       := l_txn_currency_code;      /* Added for Org Forecasting */
        px_project_curr_code   := l_project_currency_code;  /* Added for Org Forecasting */


       x_return_status := l_x_return_status;


EXCEPTION
/*    WHEN l_conversion_fail THEN   Added for bug 2238712
         x_return_status :=  FND_API.G_RET_STS_ERROR;
         x_msg_count     :=  1;
         x_msg_data      := SUBSTR(l_status,1,30);
         x_projfunc_burden_cost      := 0;
         x_projfunc_burden_cost_rate := 0;
         x_projfunc_raw_cost         := 0;
         x_projfunc_raw_cost_rate    := 0;

         IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
            PA_UTILS.add_message('PA', SUBSTR(l_status,1,30));
         END IF;   */
    WHEN l_proj_func_curr_code_null THEN
         /* Checking error condition. Added for bug 2218386 */
         IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
           PA_UTILS.add_message('PA', 'PA_FCST_PROJ_CURR_CODE_NULL');
         END IF;

         x_return_status :=  FND_API.G_RET_STS_ERROR;
         x_msg_count     :=  1;
         x_msg_data      :=  'PA_FCST_PROJ_CURR_CODE_NULL';

    WHEN l_exp_func_curr_code_null THEN
         /* Checking error condition. Added for bug 2218386 */
         IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
           PA_UTILS.add_message('PA', 'PA_FCST_EXP_CURR_CODE_NULL');
         END IF;

         x_return_status :=  FND_API.G_RET_STS_ERROR;
         x_msg_count     :=  1;
         x_msg_data      :=  'PA_FCST_EXP_CURR_CODE_NULL';

    WHEN l_invalid_rate_date_type THEN
         /* Checking error condition. Added for bug 2218386 */
         IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
            PA_UTILS.add_message('PA', 'PA_FCST_INVL_RATE_DT_TYP');
         END IF;

         x_return_status :=  FND_API.G_RET_STS_ERROR;
         x_msg_count     :=  1;
         x_msg_data      :=  'PA_FCST_INVL_RATE_DT_TYP';

    WHEN l_raw_cost_null THEN
         px_raw_cost                   := 0;
         px_raw_cost_rate              := 0;
         px_burden_cost                := 0;
         px_burden_cost_rate           := 0;
         px_exp_func_cost              := 0;
         px_exp_func_cost_rate         := 0;
         px_exp_func_burden_cost       := 0;
         px_exp_func_burden_cost_rate  := 0;
         px_projfunc_raw_cost          := 0;
         px_projfunc_raw_cost_rate     := 0;
         px_projfunc_burden_cost       := 0;
         px_projfunc_burden_cost_rate  := 0;
         px_project_cost               := 0;
         px_project_cost_rate          := 0;
         px_project_burden_cost        := 0;
         px_project_burden_cost_rate   := 0;

         /* Checking error condition. Added for bug 2218386 */
         IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
            PA_UTILS.add_message('PA', 'PA_FCST_NO_COST_RATE');
         END IF;

         x_return_status :=  FND_API.G_RET_STS_ERROR;
         x_msg_count     :=  1;
         x_msg_data      :=  'PA_FCST_NO_COST_RATE';

   WHEN l_burden_cost_null THEN
         px_raw_cost                   := 0;
         px_raw_cost_rate              := 0;
         px_burden_cost                := 0;
         px_burden_cost_rate           := 0;
         px_exp_func_cost              := 0;
         px_exp_func_cost_rate         := 0;
         px_exp_func_burden_cost       := 0;
         px_exp_func_burden_cost_rate  := 0;
         px_projfunc_raw_cost          := 0;
         px_projfunc_raw_cost_rate     := 0;
         px_projfunc_burden_cost       := 0;
         px_projfunc_burden_cost_rate  := 0;
         px_project_cost               := 0;
         px_project_cost_rate          := 0;
         px_project_burden_cost        := 0;
         px_project_burden_cost_rate   := 0;

         /* Checking error condition. Added for bug 2218386 */
         IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
            PA_UTILS.add_message('PA', 'PA_FCST_NO_COST_RATE');
         END IF;

         x_return_status :=  FND_API.G_RET_STS_ERROR;
         x_msg_count     :=  1;
         x_msg_data      :=  'PA_FCST_NO_COST_RATE';

 WHEN l_multi_conversion_fail THEN
         px_raw_cost                   := 0;
         px_raw_cost_rate              := 0;
         px_burden_cost                := 0;
         px_burden_cost_rate           := 0;
         px_exp_func_cost              := 0;
         px_exp_func_cost_rate         := 0;
         px_exp_func_burden_cost       := 0;
         px_exp_func_burden_cost_rate  := 0;
         px_projfunc_raw_cost          := 0;
         px_projfunc_raw_cost_rate     := 0;
         px_projfunc_burden_cost       := 0;
         px_projfunc_burden_cost_rate  := 0;
         px_project_cost               := 0;
         px_project_cost_rate          := 0;
         px_project_burden_cost        := 0;
         px_project_burden_cost_rate   := 0;

   IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
      PA_UTILS.add_message('PA', l_multi_status);
   END IF;

   x_return_status :=  FND_API.G_RET_STS_ERROR;
   x_msg_count     :=  1;
   x_msg_data      :=  l_multi_status;

    WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_count := 1;
         x_msg_data  := SUBSTR(SQLERRM,1,30);
        /* Checking error condition. Added for bug 2218386 */
        IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_COST', /* Moved this here to fix bug 2434663 */
                                  p_procedure_name => 'Get_Converted_Cost_Amounts');
          RAISE;
        END IF;
END Get_Converted_Cost_Amounts;



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
        /* Checking error condition. Added for bug 2218386 */
        IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
          RAISE;
        ELSE
          NULL;
        END IF;

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
        AND IMP.org_id  = p_org_id; --Bug#5903720

      return l_currency_code;


EXCEPTION
   WHEN NO_DATA_FOUND THEN
        NULL;

   WHEN OTHERS THEN
        /* Checking error condition. Added for bug 2218386 */
        IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
           Raise;
        ELSE
          NULL;
        END IF;


END Get_curr_code;



PROCEDURE get_schedule_id( p_schedule_type          IN   VARCHAR2  ,
                           p_project_id             IN   NUMBER    ,
                           p_task_id                IN   NUMBER    ,
                           p_item_date              IN   DATE      ,
                           p_exp_type               IN   VARCHAR2  ,
                           x_burden_sch_rev_id      OUT NOCOPY  NUMBER    ,
                           x_burden_sch_fixed_date  OUT NOCOPY  DATE      ,
                           x_return_status          OUT NOCOPY  VARCHAR2  ,
                           x_msg_count              OUT NOCOPY  NUMBER    ,
                           x_msg_data               OUT NOCOPY  VARCHAR2
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


       /* Use the decode statement to select the ind_rate_sch_id according
          to the passed schedule_type to fix the bug  2046094  */
      IF p_task_id IS NOT NULL THEN

         BEGIN

            SELECT DECODE(p_schedule_type,'COST',    t.cost_ind_rate_sch_id,
                                          'REVENUE', t.rev_ind_rate_sch_id,
                                          'INVOICE', t.inv_ind_rate_sch_id),
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

       /* Use the decode statement to select the ind_rate_sch_id according
          to the passed schedule_type to fix the bug  2046094  */

         BEGIN

            SELECT DECODE(p_schedule_type,'COST',    prj.cost_ind_rate_sch_id,
                                          'REVENUE', prj.rev_ind_rate_sch_id,
                                          'INVOICE', prj.inv_ind_rate_sch_id),
                   DECODE(p_schedule_type,'COST',    prj.cost_ind_sch_fixed_date,
                                          'REVENUE', prj.rev_ind_sch_fixed_date,
                                          'INVOICE', prj.inv_ind_sch_fixed_date)
              INTO l_burden_sch_id,
                   l_burden_sch_fixed_date
              FROM pa_projects_all prj
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
         /* Checking error condition. Added for bug 2218386 */
         IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
           PA_UTILS.add_message('PA', 'PA_FCST_INVL_BURDEN_SCH_REV_ID');
         END IF;
         x_return_status :=  FND_API.G_RET_STS_ERROR;
         x_msg_count     :=  1;
         x_msg_data      :=  'PA_FCST_INVL_BURDEN_SCH_REV_ID';

    WHEN l_sch_rev_id_found THEN
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         x_msg_count := NULL;
         x_msg_data  := NULL;

    WHEN l_sch_rev_id_not_found THEN
         /* Checking error condition. Added for bug 2218386 */
         IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
            PA_UTILS.add_message('PA', 'PA_FCST_INVL_BURDEN_SCH_REV_ID');
         END IF;
         x_return_status :=  FND_API.G_RET_STS_ERROR;
         x_msg_count     :=  1;
         x_msg_data      :=  'PA_FCST_INVL_BURDEN_SCH_REV_ID';

    WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_count := 1;
         x_msg_data  := SUBSTR(SQLERRM,1,30);
        /* Checking error condition. Added for bug 2218386 */
        IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
          FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_COST', /* Moved this here to fix bug 2434663 */
                                    p_procedure_name => 'Get_Schedule_Id');
        END IF;

END get_schedule_id;

/* Added four new columns and changed the logic to return the cost and rate in
   PFC for MCB II */

PROCEDURE  Requirement_raw_cost(
              p_forecast_cost_job_group_id    IN       NUMBER   ,
              p_forecast_cost_job_id          IN       NUMBER   ,
              p_proj_cost_job_group_id        IN       NUMBER   ,
              px_proj_cost_job_id             IN  OUT NOCOPY  NUMBER ,
              p_item_date                     IN       DATE     ,
              p_job_cost_rate_sch_id          IN       NUMBER   ,
              p_schedule_date                 IN       DATE     ,
              p_quantity                      IN       NUMBER   ,
              p_cost_rate_multiplier          IN       NUMBER   ,
              p_org_id                        IN       NUMBER   ,
              P_expend_organization_id        IN       NUMBER   ,          /*LCE*/
          /*  p_projfunc_currency_code        IN       VARCHAR2, -- The following 4
              px_projfunc_cost_rate_type      IN OUT NOCOPY   VARCHAR2, -- added for MCB2
              px_projfunc_cost_rate_date      IN OUT NOCOPY   DATE,
              px_projfunc_cost_exchange_rate  IN OUT NOCOPY   NUMBER  ,
               Commented for Org Forecasting */
              x_raw_cost_rate                 OUT NOCOPY      NUMBER   ,
              x_raw_cost                      OUT NOCOPY      NUMBER   ,
              x_txn_currency_code             OUT NOCOPY      VARCHAR2 , /* Added for Org Forecasting */
              x_return_status                 OUT NOCOPY      VARCHAR2 ,
              x_msg_count                     OUT NOCOPY      NUMBER   ,
              x_msg_data                      OUT NOCOPY      VARCHAR2
                 )
IS

l_x_raw_cost_rate            NUMBER;
l_x_raw_cost                 NUMBER;
l_to_job_id                  NUMBER;
l_currency_code              fnd_currencies.currency_code%TYPE;

l_raw_cost_null              EXCEPTION;
l_conversion_fail            EXCEPTION;

  /* Added for MCB2 */
   l_txn_cost_rate          NUMBER :=null; -- It will be used to store cost amount transaction curr.
   l_txn_cost               NUMBER :=null; -- It will be used to store the raw revenue trans. curr.
   l_rate_currency_code     pa_bill_rates_all.rate_currency_code%TYPE;
   l_denominator            Number;
   l_numerator              Number;
   l_status                  Varchar2(30);
   l_converted_cost_amount  Number;
   l_converted_cost_rate    NUMBER :=null;
   l_conversion_date        DATE;  -- variable to store item date

/*LCE changes*/
l_expend_organization_id   pa_expenditures_all.incurred_by_organization_id%type;
l_exp_org_id               pa_expenditures_all.org_id%type;        /*2879644*/
l_acct_cost_rate           pa_compensation_details.acct_exchange_rate%type;
l_acct_currency_code       fnd_currencies.currency_code%TYPE;
l_costing_rule             pa_compensation_details_all.compensation_rule_set%type;
l_start_date_active        date;
l_end_date_active          date;
l_org_labor_sch_rule_id    pa_org_labor_sch_rule.org_labor_sch_rule_id%type;
l_rate_sch_id              pa_std_bill_rate_schedules.bill_rate_sch_id%type;
l_override_type            pa_compensation_details.override_type%type;
l_acct_rate_type           pa_compensation_details.acct_rate_type%type;
l_acct_rate_date_code      pa_compensation_details.acct_rate_date_code%type;
l_acct_exch_rate           pa_compensation_details.acct_exchange_rate%type;
l_ot_project_id            pa_projects_all.project_id%type;
l_ot_task_id               pa_tasks.task_id%type;
l_err_code                 varchar2(200);
l_err_stage                number;
l_return_value             varchar2(100);
user_exception             EXCEPTION;
/*LCE changes*/


BEGIN

	g_debug_mode := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
        --Initialize the error stack
        PA_DEBUG.init_err_stack('PA_COST.Requirement_raw_cost');

	PA_DEBUG.SET_PROCESS( x_process        => 'PLSQL'
                             ,x_write_file     => 'LOG'
                             ,x_debug_mode     => g_debug_mode
                            );

              print_msg('IN Params :CostJobgoup_id['||p_forecast_cost_job_group_id||
			']jobId['|| p_forecast_cost_job_id||']projJobGroupId['||p_proj_cost_job_group_id||
              	        ']projCostJobId['||px_proj_cost_job_id||']ItemDate['||p_item_date||
                        ']rateSchId['||p_job_cost_rate_sch_id||']SchDate['||p_schedule_date||
              	        ']Qty['||p_quantity||']rateMultplier['||p_cost_rate_multiplier||
                        ']OrgId['||p_org_id||']ExpOrgId['||P_expend_organization_id||']');



          --------------------------------------------
          -- Initialize the successfull return status
          --------------------------------------------

           l_x_return_status := FND_API.G_RET_STS_SUCCESS;


           ---------------------------------------
           -- Get the Project Cost Job Id from API.
           ---------------------------------------


           IF (px_proj_cost_job_id IS NULL) THEN

		print_msg('Calling Pa_Resource_Utils.GetToJobId');

               Pa_Resource_Utils.GetToJobId( p_forecast_cost_job_group_id   ,
                                             p_forecast_cost_job_id         ,
                                             p_proj_cost_job_group_id       ,
                                             px_proj_cost_job_id
                                           );

		print_msg('After Pa_Resource_Utils.GetToJobId API costJobid['||px_proj_cost_job_id||']');
           END IF;

/****Commented for LCE Changes

              SELECT DECODE(b.rate, NULL, NULL,b.rate * NVL(p_cost_rate_multiplier,1)),
                   (b.rate * NVL(p_cost_rate_multiplier,1) * p_quantity),rate_currency_code
              INTO l_x_raw_cost_rate, l_x_raw_cost ,l_rate_currency_code
              FROM pa_bill_rates_all b
             WHERE b.bill_rate_sch_id = p_job_cost_rate_sch_id
               AND b.job_id =  px_proj_cost_job_id
               AND b.rate is NOT NULL
               AND to_date(nvl(to_date(p_schedule_date), to_date(p_item_date))+ 0.99999)
                    BETWEEN b.start_date_active AND NVL(to_date(b.end_date_active),
                             to_date(nvl(to_date(p_schedule_date), to_date(p_item_date)))) + 0.99999
               AND  NVL(b.org_id,-99) = NVL(p_org_id,-99);
End of comment for LCE ******/

/***LCE changes***/

            l_expend_organization_id := P_expend_organization_id;

	      print_msg('Calling PA_COST_RATE_PUB.get_labor_rate API');

              PA_COST_RATE_PUB.get_labor_rate(p_person_id             =>NULL
                                             ,p_txn_date              =>P_Item_date
                                             ,p_calling_module        =>'REQUIREMENT'
                                             ,p_org_id                =>l_expend_organization_id      /*5511578*/
                                             ,x_job_id                =>px_proj_cost_job_id
                                             ,x_organization_id       =>l_expend_organization_id
                                             ,x_cost_rate             =>l_x_raw_cost_rate
                                             ,x_start_date_active     =>l_start_date_active
                                             ,x_end_date_active       =>l_end_date_active
                                             ,x_org_labor_sch_rule_id =>l_org_labor_sch_rule_id
                                             ,x_costing_rule          =>l_costing_rule
                                             ,x_rate_sch_id           =>l_rate_sch_id
                                             ,x_cost_rate_curr_code   =>l_rate_currency_code
                                             ,x_acct_rate_type        =>l_acct_rate_type
                                             ,x_acct_rate_date_code   =>l_acct_rate_date_code
                                             ,x_acct_exch_rate        =>l_acct_exch_rate
                                             ,x_ot_project_id         =>l_ot_project_id
                                             ,x_ot_task_id            =>l_ot_task_id
                                             ,x_err_stage             =>l_err_stage
                                             ,x_err_code              =>l_err_code
                                           );
	      print_msg('l_x_raw_cost_rate['||l_x_raw_cost_rate||']l_org_labor_sch_rule_id['||l_org_labor_sch_rule_id||
			']l_costing_rule['||l_costing_rule||']l_rate_sch_id['||l_rate_sch_id||
			']l_rate_currency_code['||l_rate_currency_code||']l_acct_rate_type['||l_acct_rate_type||
			']l_acct_rate_date_code['||l_acct_rate_date_code||']l_acct_exch_rate['||l_acct_exch_rate||
			']l_ot_project_id['||l_ot_project_id||']l_ot_task_id['||l_ot_task_id||
			']l_err_stage['||l_err_stage||']l_err_code['||l_err_code||']');


               IF l_err_code is NOT NULL THEN
                pa_cc_utils.log_message('Error Occured in stage'||l_err_stage);
                RAISE user_exception;
               END IF;

          pa_cc_utils.log_message('Converting from transaction currency to functional currency');
      --  Get the Functional Currency code

          l_acct_currency_code := get_curr_code(p_org_id);


       IF (l_acct_currency_code IS NULL) THEN

           RAISE l_exp_func_curr_code_null;

       END IF;


      --Check if the denom and functional currencies are different

       IF l_acct_currency_code <> l_rate_currency_code THEN

          l_conversion_date := P_Item_date;

	print_msg('Calling pa_multi_currency.convert_amount API');

       pa_multi_currency.convert_amount( P_from_currency         =>l_rate_currency_code,
                                         P_to_currency           =>l_acct_currency_code,
                                         P_conversion_date       =>l_conversion_date,
                                         P_conversion_type       =>l_acct_rate_type,
                                         P_amount                =>l_x_raw_cost_rate,
                                         P_user_validate_flag    =>'N',
                                         P_handle_exception_flag =>'N',
                                         P_converted_amount      =>l_acct_cost_rate,
                                         P_denominator           =>l_denominator,
                                         P_numerator             =>l_numerator,
                                         P_rate                  =>l_acct_exch_rate,
                                         X_status                =>l_err_code ) ;
		print_msg('l_x_raw_cost_rate['||l_x_raw_cost_rate||']l_acct_cost_rate['||l_acct_cost_rate||
			']l_denominator['||l_denominator||']l_numerator['||l_numerator||
			']l_acct_exch_rate['||l_acct_exch_rate||']l_err_code['||l_err_code||
			']l_x_raw_cost_rate['||l_x_raw_cost_rate||']');

        IF l_err_code is NOT NULL THEN
          pa_cc_utils.log_message('Error occured in conversion stage');
          RAISE user_exception;
         END IF;

      ELSE

         l_acct_cost_rate := l_x_raw_cost_rate;  /*When  denom and functional are same*/

      END IF ;

           l_x_raw_cost := l_acct_cost_rate *  NVL(p_cost_rate_multiplier,1) * p_quantity;

/***End of LCE changes ***/

           l_txn_cost_rate      := NVL(l_acct_cost_rate,0);
           l_txn_cost           := NVL(l_x_raw_cost,0);


       IF (l_txn_cost_rate IS NULL) OR (l_txn_cost IS NULL) THEN

          RAISE l_raw_cost_null;

       END IF;

       x_raw_cost_rate     := NVL(l_txn_cost_rate,0);  /* Added for Org Forecasting */
       x_raw_cost          := NVL(l_txn_cost,0);       /* Added for Org Forecasting */
       x_txn_currency_code := l_acct_currency_code;    /* Added for Org Forecasting */

/* COMMENTED FOR ORG FORECASTING, BECAUSE GOING TO CALL COSTING PROCEDURE
      WHICH WILL GIVE THE AMOUNTS IN ALL THE CURRENCIES

       -- The following code has been added for MCB2
          l_conversion_date := p_item_date;

      -- Calling convert amount proc to convert revenue amount in PFC
          PA_MULTI_CURRENCY.convert_amount(
                            P_FROM_CURRENCY          => l_rate_currency_code,
                            P_TO_CURRENCY            => p_projfunc_currency_code,
                            P_CONVERSION_DATE        => l_conversion_date,
                            P_CONVERSION_TYPE        => px_projfunc_cost_rate_type,
                            P_AMOUNT                 => l_txn_cost,
                            P_USER_VALIDATE_FLAG     => 'Y',
                            P_HANDLE_EXCEPTION_FLAG  => 'Y',
                            P_CONVERTED_AMOUNT       => l_converted_cost_amount,
                            P_DENOMINATOR            => l_denominator,
                            P_NUMERATOR              => l_numerator,
                            P_RATE                   => px_projfunc_cost_exchange_rate,
                            X_STATUS                 => l_status);

                           IF (l_status IS NOT NULL) THEN
                             RAISE l_conversion_fail;
                           END IF;

      -- Calling convert amount proc to convert rate in PFC
          PA_MULTI_CURRENCY.convert_amount(
                            P_FROM_CURRENCY          => l_rate_currency_code,
                            P_TO_CURRENCY            => p_projfunc_currency_code,
                            P_CONVERSION_DATE        => l_conversion_date,
                            P_CONVERSION_TYPE        => px_projfunc_cost_rate_type,
                            P_AMOUNT                 => l_txn_cost_rate,
                            P_USER_VALIDATE_FLAG     => 'Y',
                            P_HANDLE_EXCEPTION_FLAG  => 'Y',
                            P_CONVERTED_AMOUNT       => l_converted_cost_rate,
                            P_DENOMINATOR            => l_denominator,
                            P_NUMERATOR              => l_numerator,
                            P_RATE                   => px_projfunc_cost_exchange_rate,
                            X_STATUS                 => l_status);

                           IF (l_status IS NOT NULL) THEN
                             RAISE l_conversion_fail;
                           END IF;



TILL HERE FRO ORG FORECASTING
*/

 x_return_status := l_x_return_status;
 PA_DEBUG.reset_err_stack;

EXCEPTION
  WHEN l_conversion_fail THEN
    x_raw_cost_rate   := 0;
    x_raw_cost        := 0;

    /* Checking error condition. Added for bug 2218386 */
    IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
       PA_UTILS.add_message('PA', l_status||'_BC_PF'); /*  fix for bug 2199203 */
    END IF;

    x_return_status :=  FND_API.G_RET_STS_ERROR;
    x_msg_count     :=  1;
    x_msg_data      :=  l_status||'_BC_PF'; /*  fix for bug 2199203 */
	PA_DEBUG.reset_err_stack;
  WHEN NO_DATA_FOUND THEN
    x_raw_cost_rate   := 0;
    x_raw_cost        := 0;

    /* Checking error condition. Added for bug 2218386 */
    IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
      PA_UTILS.add_message('PA', 'PA_FCST_NO_COST_RATE');
    END IF;

    x_return_status :=  FND_API.G_RET_STS_ERROR;
    x_msg_count     :=  1;
    x_msg_data      :=  'PA_FCST_NO_COST_RATE';
	PA_DEBUG.reset_err_stack;
  WHEN l_raw_cost_null THEN
    x_raw_cost_rate   := 0;
    x_raw_cost        := 0;

    /* Checking error condition. Added for bug 2218386 */
    IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
       PA_UTILS.add_message('PA', 'PA_FCST_NO_COST_RATE');
    END IF;

    x_return_status :=  FND_API.G_RET_STS_ERROR;
    x_msg_count     :=  1;
    x_msg_data      :=  'PA_FCST_NO_COST_RATE';
	PA_DEBUG.reset_err_stack;

  /*LCE changes*/
   WHEN user_exception THEN
     IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
           PA_UTILS.add_message('PA',l_err_code);
      END IF;
      x_return_status   := FND_API.G_RET_STS_ERROR;
      x_msg_count       :=  1;
      x_msg_data        :=  l_err_code;
	PA_DEBUG.reset_err_stack;

   WHEN l_exp_func_curr_code_null THEN
        /* Checking error condition. Added for bug 2218386 */
        IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
           PA_UTILS.add_message('PA', 'PA_FCST_EXP_CURR_CODE_NULL');
        END IF;
        x_return_status :=  FND_API.G_RET_STS_ERROR;
        x_msg_count     :=  1;
        x_msg_data      :=  'PA_FCST_EXP_CURR_CODE_NULL';
	PA_DEBUG.reset_err_stack;
  /*LCE changes*/

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count := 1;
    x_msg_data := SUBSTR(SQLERRM,1,30);
    /* Checking error condition. Added for bug 2218386 */
    IF (NVL(PA_RATE_PVT_PKG.G_add_error_to_stack_flag,'Y') = 'Y') THEN
       FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_COST', /* Moved this here to fix bug 2434663 */
                                p_procedure_name => 'Requirement_raw_cost');
          RAISE;
    END IF;
END Requirement_raw_cost;


END PA_COST;

/
