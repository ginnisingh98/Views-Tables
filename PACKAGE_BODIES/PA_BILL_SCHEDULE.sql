--------------------------------------------------------
--  DDL for Package Body PA_BILL_SCHEDULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BILL_SCHEDULE" AS
/*$Header: PAXBILAB.pls 120.1 2005/08/19 17:09:08 mwasowic noship $ */

 g1_debug_mode varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE get_computed_bill_rate  (
         p_array_size                       IN     NUMBER,
         p_bill_rate_sch_id                 IN     pa_plsql_datatypes.IdTabTyp,
         p_expenditure_item_id              IN     pa_plsql_datatypes.IdTabTyp,
         p_exp_sys_linkage                  IN     pa_plsql_datatypes.Char30TabTyp,
         p_expenditure_type                 IN     pa_plsql_datatypes.Char30TabTyp,
         p_expenditure_item_date            IN     pa_plsql_datatypes.DateTabTyp,
         p_fixed_date                       IN     pa_plsql_datatypes.DateTabTyp,
         p_quantity                         IN     pa_plsql_datatypes.NumTabTyp,
         p_incurred_by_person_id            IN     pa_plsql_datatypes.IdTabTyp,
         p_non_labor_resource               IN     pa_plsql_datatypes.Char20TabTyp,
         p_base_curr                        IN     pa_plsql_datatypes.Char15TabTyp,
         p_base_amt                         IN     pa_plsql_datatypes.NumTabTyp,
         p_exp_uom                          IN     pa_plsql_datatypes.Char30TabTyp,
         p_compute_flag                     IN OUT  NOCOPY pa_plsql_datatypes.Char1TabTyp,
         x_error_code                       IN OUT  NOCOPY pa_plsql_datatypes.Char30TabTyp,
         x_reject_cnt                       OUT    NOCOPY number, --File.Sql.39 bug 4440895
         x_computed_rate                    OUT    NOCOPY  pa_plsql_datatypes.NumTabTyp,
         x_computed_markup                  OUT     NOCOPY pa_plsql_datatypes.NumTabTyp,
         x_computed_currency                OUT     NOCOPY pa_plsql_datatypes.Char15TabTyp,
         x_computed_amount                  OUT     NOCOPY pa_plsql_datatypes.NumTabTyp,
         x_tp_job_id                        OUT     NOCOPY pa_plsql_datatypes.IdTabtyp,
         x_error_stage                      OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
  )
IS
/*-----------------------------------------------------------------------------
 declare all the variables.
 ----------------------------------------------------------------------------*/
     bill_rate   pa_bill_rates_all.rate%TYPE;
     markup      pa_bill_rates_all.markup_percentage%TYPE;
     bill_ous    pa_bill_rates_all.org_id%TYPE;
     v_job_id    pa_bill_rates_all.job_id%TYPE;
     v_curr_code pa_bill_rates_all.rate_currency_code%TYPE; -- Added this column for MCB2


 BEGIN
/*-----------------------------------------------------------------------------
 loop until all records  are processed
 ----------------------------------------------------------------------------*/
IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('Entering pa_bill_schedule.get_computed_bill_rate Id :');
END IF;
 FOR i in 1..p_array_size  LOOP

 -- CBGA fix

    x_tp_job_id(i)  := NULL;

/* Selecting currency from bill rate table in all the selects for MCB2 */
 IF p_compute_flag(i) = 'Y'  THEN
 BEGIN
    IF  ( p_exp_sys_linkage(i) NOT IN ( 'ST','OT') ) THEN

    /*Bug# 2036624:Commented for bug# 2036624.Now when non_labor_resource is null
    it will be trapped in exception part and the bill rate will be calculated  */

   /*  AND  ( p_non_labor_resource(i) IS NOT NULL      )   )  THEN      Bug# 2036624 */
   BEGIN
     /* Non Labor Resource Based Bill Rate/Markup   */
     SELECT b.rate,
            b.markup_percentage,
            b.org_id,
            b.rate_currency_code
     INTO   bill_rate,
            markup,
            bill_ous,
            v_curr_code
     FROM pa_bill_rates_all b
     WHERE
         b.bill_rate_sch_id    = p_bill_rate_sch_id(i)
     AND b.expenditure_type    = p_expenditure_type(i)
     AND b.non_labor_resource  = p_non_labor_resource(i)
     AND nvl(p_fixed_date(i), p_expenditure_item_date(i)) BETWEEN
     b.start_date_active  AND nvl(b.end_date_active,p_expenditure_item_date(i));
   EXCEPTION
     WHEN no_data_found  then

     /* Expenditure Type Based Non Labor Based Bill Rate/Markup   */
     /* Bug#3019564 - The following select statement is raised a too may row exception.
        Fix : Add the non_labor_resource is null for the following sql */

     SELECT b.rate,
            b.markup_percentage,
            b.org_id,
            b.rate_currency_code
     INTO   bill_rate,
            markup,
            bill_ous,
            v_curr_code
     FROM pa_bill_rates_all b
     WHERE
         b.bill_rate_sch_id    = p_bill_rate_sch_id(i)
     AND b.expenditure_type    = p_expenditure_type(i)
     AND b.non_labor_resource IS NULL
     AND nvl(p_fixed_date(i), p_expenditure_item_date(i)) BETWEEN
     b.start_date_active  AND nvl(b.end_date_active,p_expenditure_item_date(i));
   END;
 ELSIF ( p_exp_sys_linkage(i) IN ( 'ST','OT') )  THEN
     /* Job Based Labor Bill Rate-Markup   */
   BEGIN

/*  CBGA changes : select the column job_id  */


     SELECT b.rate,
            b.markup_percentage,
            b.org_id,
            b.job_id,
            b.rate_currency_code
     INTO   bill_rate,
            markup,
            bill_ous,
            v_job_id,
            v_curr_code
     FROM pa_bill_rates_all b,
          per_assignments_f pa,
          pa_std_bill_rate_schedules_all brs
     WHERE
         pa.primary_flag       =  'Y'
     -- AND pa.assignment_type    = 'E'   /* bug 2911451 */
     AND pa.assignment_type    IN ('E','C') -- Modified for CWK impact
     AND pa.person_id          =  p_incurred_by_person_id(i)
     AND  p_expenditure_item_date(i) BETWEEN
     pa.effective_start_date  AND
        pa.effective_end_date   /* Removed the nvl on end_date as part of Assignment Type Validation changes for bug 2911451 */
     AND b.bill_rate_sch_id    = p_bill_rate_sch_id(i)
     AND b.bill_rate_sch_id    = brs.bill_rate_sch_id
     AND b.job_id              = PA_cross_Business_Grp.IsMappedToJob(pa.job_id, brs.job_group_id)
     AND nvl(p_fixed_date(i),p_expenditure_item_date(i)) BETWEEN
     b.start_date_active AND nvl(b.end_date_active,p_expenditure_item_date(i));

     x_tp_job_id(I) := v_job_id;


   EXCEPTION
    WHEN no_data_found   THEN
     /* Employee Based Labor Bill Rate/Markup   */
     SELECT b.rate,
            b.markup_percentage,
            b.org_id,
            b.rate_currency_code
     INTO   bill_rate,
            markup,
            bill_ous,
            v_curr_code
     FROM pa_bill_rates_all b
     WHERE
         b.bill_rate_sch_id    = p_bill_rate_sch_id(i)
     AND b.person_id              = p_incurred_by_person_id(i)
     AND nvl(p_fixed_date(i),p_expenditure_item_date(i)) BETWEEN
     b.start_date_active AND nvl(b.end_date_active,p_expenditure_item_date(i));
   END;
 END IF;

 /* Added for MCB2 Assigning the rate currency */
  x_computed_currency(i)   := v_curr_code;

 IF markup  is not null  THEN
   x_computed_currency(i)   := p_base_curr(i);
   x_computed_markup(i)     := markup;
   x_computed_rate(i)       := null;
/*
   select pa_currency.round_trans_curr_amt(x_computed_markup(i)*p_base_amt(i)/100,
                                           x_computed_currency(i))
   into x_computed_amount(i)
   from dual;
*/
 /*  x_computed_amount(i)     := pa_currency.round_trans_currency_amt(x_computed_markup(i)*p_base_amt(i)/100,x_computed_currency(i));
     commented for bug 3697180 */

 /* Added the below for bug 3697180 */

 x_computed_amount(i)     :=
pa_currency.round_trans_currency_amt((100 + x_computed_markup(i))*p_base_amt(i)/100,x_computed_currency(i));
 ELSE
 /* Added for MCB2 : Commented the below select because , now selecting rate currency can be diffrent from PFC */
 /*   select gsb.currency_code
    into   x_computed_currency(i)
    from  pa_implementations_all imp,
          gl_sets_of_books gsb
    where imp.org_id  = bill_ous
    and   imp.set_of_books_id = gsb.set_of_books_id; */
    x_computed_markup(i)  := null;
    x_computed_rate(i)    := bill_rate;
    x_computed_amount(i)  := pa_currency.round_trans_currency_amt(p_quantity(i)*bill_rate,x_computed_currency(i));
IF g1_debug_mode  = 'Y' THEN
	PA_MCB_INVOICE_PKG.log_message('get_computed_bill_rate: ' || 'Leaving pa_bill_schedule.x_computed_markup :'||x_computed_markup(i));
	PA_MCB_INVOICE_PKG.log_message('get_computed_bill_rate: ' || 'Leaving pa_bill_schedule.x_computed_rate :'||x_computed_rate(i));
	PA_MCB_INVOICE_PKG.log_message('get_computed_bill_rate: ' || 'Leaving pa_bill_schedule.x_computed_amount :'||x_computed_amount(i));
END IF;
 END IF;
 EXCEPTION
   when no_data_found then
    /*x_error_code(i) := 'NO_BILL_SCH';commented for bug 3118724*/
    x_error_code(i) := 'NO_BILL_RATE';
    x_reject_cnt    := x_reject_cnt + 1;
 END;
 END IF;
 END LOOP;
END get_computed_bill_rate;

END pa_bill_schedule;

/
