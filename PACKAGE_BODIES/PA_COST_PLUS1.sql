--------------------------------------------------------
--  DDL for Package Body PA_COST_PLUS1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_COST_PLUS1" as
-- $Header: PAXCCPFB.pls 120.2.12000000.4 2007/05/02 09:42:33 haananth ship $

NO_DATA_FOUND_ERR	number	      :=  100;


/* Added code for 2798971 */
procedure get_indirect_cost_import_sum1(org_id                    IN     number,
                                 c_base                    IN     varchar2,
                                 rate_sch_rev_id           IN     number,
                                 direct_cost               IN     number,
                                 direct_cost_denom         IN     number,
                                 direct_cost_acct          IN     number,
                                 direct_cost_project       IN     number,
                                 precision                 IN     number,
                                 indirect_cost_sum          IN OUT NOCOPY  number,
                                 indirect_cost_denom_sum    IN OUT NOCOPY  number,
                                 indirect_cost_acct_sum     IN OUT NOCOPY  number,
                                 indirect_cost_project_sum  IN OUT NOCOPY  number,
                                 l_projfunc_currency_code  IN     varchar2,
                                 l_project_currency_code   IN     varchar2,
                                 l_acct_currency_code      IN     varchar2 default null,
                                 l_denom_currency_code     IN     varchar2,
                                 status                     IN OUT NOCOPY  number,
                                 stage                      IN OUT NOCOPY  number)
IS

BEGIN

   status := 0;
   stage := 100;
    /*========================================================+
     | 21-MAY-03 Burdening Enhancements.                      |
     |           Added Cost Base join to pa_ind_compiled_sets |
     +========================================================*/
    SELECT SUM(PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT((direct_cost * icpm.compiled_multiplier),
           l_projfunc_currency_code)),
         SUM(PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT((direct_cost_denom * icpm.compiled_multiplier),
           l_denom_currency_code)),
         SUM(PA_CURRENCY.round_currency_amt(direct_cost_acct * icpm.compiled_multiplier)),
         SUM(PA_CURRENCY.ROUND_TRANS_CURRENCY_AMT((direct_cost_project * icpm.compiled_multiplier),
           l_project_currency_code))
        into indirect_cost_sum,
             indirect_cost_denom_sum,
             indirect_cost_acct_sum,
             indirect_cost_project_sum
                FROM pa_ind_compiled_sets ics,
                     pa_compiled_multipliers icpm
                        WHERE
                              ics.ind_rate_sch_revision_id = rate_sch_rev_id
                              AND ics.organization_id = org_id
                              AND ics.status = 'A'
                              AND ics.ind_compiled_set_id =
                                                icpm.ind_compiled_set_id
                              AND ics.cost_base = c_base
                              AND icpm.cost_base = c_base;

   if (indirect_cost_sum is null) then
      status := NO_DATA_FOUND_ERR;
   end if;

EXCEPTION

   WHEN OTHERS THEN
        status := SQLCODE;

END get_indirect_cost_import_sum1;
/* Added code for 2798971 ends*/
/* Added code for 2798971 */

procedure get_indirect_cost_import
				( task_id       IN     Number,
				   p_txn_interface_id IN Number,    /* 3246794  */
				effective_date   IN     Date,
				expenditure_type IN     Varchar2,
				organization_id  IN     Number,
				schedule_type    IN     Varchar2,
				direct_cost      IN     Number,
				direct_cost_denom         IN     number,
				direct_cost_acct          IN     number,
				direct_cost_project       IN     number,
				indirect_cost_sum     IN OUT NOCOPY  Number,
				indirect_cost_denom_sum    IN OUT NOCOPY  number,
				indirect_cost_acct_sum     IN OUT NOCOPY  number,
				indirect_cost_project_sum  IN OUT NOCOPY  number,
				l_projfunc_currency_code  IN     varchar2,
				l_project_currency_code   IN     varchar2,
				l_acct_currency_code      IN     varchar2,
				l_denom_currency_code     IN     varchar2,
				Compiled_set_id   IN OUT NOCOPY  Number,
				status            IN OUT NOCOPY  Number,
				stage             IN OUT NOCOPY  Number)

IS

--
--  Local variables
--

sch_id                  Number(15);
sch_fixed_date          Date;
rate_sch_rev_id		Number(15);
cp_structure		Varchar2(30);
c_base			Varchar2(30);
--compiled_multiplier     pa_compiled_multipliers.compiled_multiplier%TYPE;
BEGIN

   status := 0;
   Compiled_set_id:= TO_NUMBER(NULL);     /*Bug# 3671809*/

   --
   --  Get the rate schedule revision id
   --

   pa_cost_plus.find_rate_sch_rev_id(
                                   p_txn_interface_id,    -- added instead of NULL Bug 3246794
                                    'TRANSACTION_IMPORT',  -- added instead of 'PA'  Bug 3246794
                                    task_id,
                                    schedule_type,
                                    effective_date,
                                    sch_id,
                                    rate_sch_rev_id,
                                    sch_fixed_date,
                                    status,
                                    stage);

  stage := 100;

  IF (status <> 0) THEN
      return;
  END IF;

  --
  -- Get the cost plus structure
  --

  pa_cost_plus.get_cost_plus_structure(rate_sch_rev_id,
			               cp_structure,
				       status,
				       stage);

  IF (status <> 0) THEN
      stage := 200;
      return;
  END IF;


  --
  -- Get the cost base
  --

  pa_cost_plus.get_cost_base(expenditure_type,
			     cp_structure,
			     c_base,
			     status,
			     stage);

  /* If expenditure type is not defined with a cost base,
     get_cost_base return with status = 100. This means this expenditure
     type should not be burdened.  Thus, indirect costs should be 0. */
  IF (status <> 0) THEN
   IF (status = 100) THEN
		indirect_cost_sum := 0;
		indirect_cost_denom_sum := 0;
		indirect_cost_acct_sum := 0;
		indirect_cost_project_sum := 0;
      status := 0;
		return;
   ELSE
      stage := 300;
      return;
   END IF;
  END IF;

  stage := 400;
  pa_cost_plus.get_compiled_set_id(rate_sch_rev_id,
				 organization_id,
                                 c_base,
				 Compiled_set_id,
				 status,
				 stage);

  IF ( status <>0 ) THEN
	return;
  END IF;

  --
  -- Get the indirect cost
  --
   pa_cost_plus1.get_indirect_cost_import_sum1 ( org_id                    => organization_id
                                        ,c_base                    => c_base
                                        ,rate_sch_rev_id           => rate_sch_rev_id
                                        ,direct_cost               => direct_cost
                                        ,direct_cost_denom         => direct_cost_denom
                                        ,direct_cost_acct          => direct_cost_acct
                                        ,direct_cost_project       => direct_cost_project
                                        ,precision                 => 2                     -- FOR US CURRENCY
                                        ,indirect_cost_sum         => indirect_cost_sum
                                        ,indirect_cost_denom_sum   => indirect_cost_denom_sum
                                        ,indirect_cost_acct_sum    => indirect_cost_acct_sum
                                        ,indirect_cost_project_sum => indirect_cost_project_sum
                                        ,l_projfunc_currency_code  => l_projfunc_currency_code
                                        ,l_project_currency_code   => l_project_currency_code
                                        ,l_acct_currency_code      => l_acct_currency_code
                                        ,l_denom_currency_code     => l_denom_currency_code
                                        ,status                    => status
                                        ,stage                     => stage
                                      );

  IF (status <> 0) THEN
	stage := 400;
	return;
  END IF;

EXCEPTION

   WHEN OTHERS THEN
	status := SQLCODE;

END get_indirect_cost_import;

/* Added code for 2798971 ends */

--
--  PROCEDURE
--     		view_indirect_cost
--
--  PURPOSE
--	        The objective of this procedure is to retrieve the total
--		indirect cost based on a set of qualifications.  User can
--		specify the qualifications and the type of indirect rate
--		schedule, then get the total amount of indirect cost.
--
--  HISTORY
--
--   10-JUN-94      S Lee	Created
--   23-Aug-97      Shree  Added two new parameters
--

procedure view_indirect_cost( task_id       IN     Number,
                             effective_date   IN     Date,
                             expenditure_type IN     Varchar2,
                             organization_id  IN     Number,
                             schedule_type    IN     Varchar2,
                             direct_cost      IN     Number,
                             indirect_cost     IN OUT NOCOPY  Number,
                             status            IN OUT NOCOPY  Number,
                             stage             IN OUT NOCOPY  Number)

IS

--
--  Local variables
--

sch_id                  Number(15);
sch_fixed_date          Date;
rate_sch_rev_id		Number(15);
cp_structure		Varchar2(30);
c_base			Varchar2(30);
compiled_multiplier     pa_compiled_multipliers.compiled_multiplier%TYPE; /*Bug# 1904585*/
BEGIN

   status := 0;

   --
   --  Get the rate schedule revision id
   --

   pa_cost_plus.find_rate_sch_rev_id(
                                    NULL,
                                    'PA',
                                    task_id,
                                    schedule_type,
                                    effective_date,
                                    sch_id,
                                    rate_sch_rev_id,
                                    sch_fixed_date,
                                    status,
                                    stage);

  stage := 100;

  IF (status <> 0) THEN
      return;
  END IF;

  --
  -- Get the cost plus structure
  --

  pa_cost_plus.get_cost_plus_structure(rate_sch_rev_id,
			               cp_structure,
				       status,
				       stage);

  IF (status <> 0) THEN
      stage := 200;
      return;
  END IF;


  --
  -- Get the cost base
  --

  pa_cost_plus.get_cost_base(expenditure_type,
			     cp_structure,
			     c_base,
			     status,
			     stage);

  /* Bug 925488: If expenditure type is not defined with a cost base,
     get_cost_base return with status = 100. This means this expenditure
     type should not be burdened.  Thus, indirect cost should be 0. */
  IF (status <> 0) THEN
   IF (status = 100) THEN
  		indirect_cost := 0;
      status := 0;
		return;
   ELSE
      stage := 300;
      return;
   END IF;
  END IF;

  --
  -- Get the indirect cost
  --
/*For bug# 2110452:To implement the same logic for burdening as is used in R10.7/R11.0*/
                 pa_cost_plus.get_indirect_cost_sum(organization_id,
	                         	             c_base,
				                    rate_sch_rev_id,
				                    direct_cost,
				                     2,                     -- FOR US CURRENCY
				                    indirect_cost,
			     	                    status,
			     	                    stage);

/*Bug# 2110452:Commented out to implement the same logic for burdening as is used in R10.7/R11*/
/*Bug# 2110452:
Get_compiled_multiplier is called to get the sum of the compiled multipliers.
  --
  -- Get the sum of the compiled Multipliers
  --

  pa_cost_plus.get_compiled_multiplier(organization_id,
                                       c_base,
                                       rate_sch_rev_id,
                                       compiled_multiplier,
                                       status,
                                       stage);  */

  IF (status <> 0) THEN
	stage := 400;
	return;
  END IF;

 /*indirect_cost         := PA_CURRENCY.ROUND_CURRENCY_AMT(direct_cost*compiled_multiplier);Bug# 2110452*/

EXCEPTION

   WHEN OTHERS THEN
	status := SQLCODE;

END view_indirect_cost;



--      Bug 886868, BURDEN AMOUNT DOUBLED IN PSI FOR REQUISITIONS
--      Modified get_indirect_cost_amounts procedure to call view_indirect_cost
--      from local package instead of pa_cost_plus.view_indirect_cost
--      This package is being called from form and the objective of the form
--      is to show burden cost as well as burden cost breakdown for
--      entered data. To show true burden calculation we should NOT implement
--      the burden summarization logic into this form
--
--      Also appropriately modified the arguments to view_indirect_cost calls
--      from get_indirect_cost_amounts procedure
--

procedure get_indirect_cost_amounts (x_indirect_cost_costing  IN OUT NOCOPY  number,
                                     x_indirect_cost_revenue  IN OUT NOCOPY  number,
                                     x_indirect_cost_invoice  IN OUT NOCOPY  number,
                                     x_task_id               IN     number,
                                     x_gl_date               IN     date,
                                     x_expenditure_type      IN     varchar2,
                                     x_organization_id       IN     number,
                                     x_direct_cost           IN     number,
			    	     x_return_status	      IN OUT NOCOPY  number,
			    	     x_stage	    	      IN OUT NOCOPY  number)
is
begin

  --
  -- Get the costing indirect cost
  --
  pa_cost_plus1.view_indirect_cost( x_task_id,
                                  x_gl_date,
                                  x_expenditure_type,
                                  x_organization_id,
                                  'C',
                                  x_direct_cost,
				  x_indirect_cost_costing,
                                  x_return_status,
                                  x_stage);

/*
  if (x_return_status <> 0) then
     x_stage := x_stage + 1000;
  end if;
*/

  if (x_return_status <> 0) then
     x_indirect_cost_costing := 0;
  end if;

  --
  -- Get the revenue indirect cost
  --
  pa_cost_plus1.view_indirect_cost( x_task_id,
                                  x_gl_date,
                                  x_expenditure_type,
                                  x_organization_id,
                                  'R',
                                  x_direct_cost,
				  x_indirect_cost_revenue,
                                  x_return_status,
                                  x_stage);

/*
  if (x_return_status = NO_RATE_SCH_ID) then
     -- Acceptable. Reset the status
     x_indirect_cost_revenue := 0;
     x_return_status := 0;
  elsif (x_return_status <> 0) then
     x_stage := x_stage + 2000;
     return;
  end if;
*/

  if (x_return_status <> 0) then
     x_indirect_cost_revenue := 0;
  end if;

  --
  -- Get the invoice indirect cost
  --
  pa_cost_plus1.view_indirect_cost( x_task_id,
                                  x_gl_date,
                                  x_expenditure_type,
                                  x_organization_id,
                                  'I',
                                  x_direct_cost,
				  x_indirect_cost_invoice,
                                  x_return_status,
                                  x_stage);

/*
  if (x_return_status = NO_RATE_SCH_ID) then
     -- Acceptable. Reset the status
     x_indirect_cost_invoice := 0;
     x_return_status := 0;
  elsif (x_return_status <> 0) then
     x_stage := x_stage + 3000;
     return;
  end if;
*/

  if (x_return_status <> 0) then
     x_indirect_cost_invoice := 0;
  end if;


end get_indirect_cost_amounts;



procedure get_ind_rate_sch_rev(x_ind_rate_sch_name           IN OUT NOCOPY  varchar2,
                               x_ind_rate_sch_revision       IN OUT NOCOPY  varchar2,
                               x_ind_rate_sch_revision_type  IN OUT NOCOPY  varchar2,
                               x_start_date_active           IN OUT NOCOPY  date,
                               x_end_date_active             IN OUT NOCOPY  date,
                               x_task_id                    IN     number,
                               x_gl_date                    IN     date,
                               x_detail_type_flag           IN     varchar2,
                               x_expenditure_type           IN     varchar2,
                               x_cost_base                   IN OUT NOCOPY  varchar2,
                               x_ind_compiled_set_id         IN OUT NOCOPY  number,
                               x_organization_id            IN     number,
			       x_return_status	     	     IN OUT NOCOPY  number,
			       x_stage	    	     	     IN OUT NOCOPY  number)
is
  x_sch_id number;
  x_sch_fixed_date date;
  x_rate_sch_rev_id number;
  x_cp_structure varchar2(30);

begin

  x_return_status := 0;
  x_stage := 0;

  pa_cost_plus.find_rate_sch_rev_id (NULL,
                                  'PA',
                                  x_task_id,
                                     x_detail_type_flag,
                                     x_gl_date,
                                     x_sch_id,
                                     x_rate_sch_rev_id,
                                     x_sch_fixed_date,
                                     x_return_status,
                                     x_stage);

  if (x_return_status > 0) then
    begin
      x_stage := 1;
      return;
    end;
  elsif (x_return_status < 0) then
    begin
      return;
    end;
  end if;


  begin

    pa_cost_plus.get_cost_plus_structure(x_rate_sch_rev_id,
				   x_cp_structure,
				   x_return_status,
				   x_stage);

    pa_cost_plus.get_cost_base (x_expenditure_type,
                                x_cp_structure,
                                x_cost_base,
                                x_return_status,
                                x_stage);
    if (x_return_status > 0) then
      begin
        x_stage := 2;
        return;
      end;
    elsif (x_return_status < 0) then
      begin
        return;
      end;
    end if;

    begin
      /*========================================================+
       | 21-MAY-03 Burdening Enhancements.                      |
       |           Added Cost Base join to pa_ind_compiled_sets |
       +========================================================*/
      select ind_compiled_set_id
      into   x_ind_compiled_set_id
      from   pa_ind_compiled_sets
      where  ind_rate_sch_revision_id = x_rate_sch_rev_id
      and    organization_id = x_organization_id
      and    cost_base = x_cost_base
      and    status = 'A';

      EXCEPTION
	WHEN NO_DATA_FOUND then
	x_stage := 3;
	x_return_status := 1;
    end;

    begin
      select s.ind_rate_sch_name,
             sr.ind_rate_sch_revision,
	     pl.meaning,
             sr.start_date_active,
             sr.end_date_active
      into   x_ind_rate_sch_name,
             x_ind_rate_sch_revision,
             x_ind_rate_sch_revision_type,
             x_start_date_active,
             x_end_date_active
      from   pa_ind_rate_schedules s,
             pa_ind_rate_sch_revisions sr,
	     pa_lookups pl
      where  s.ind_rate_sch_id = sr.ind_rate_sch_id
      and    sr.ind_rate_sch_revision_type = pl.lookup_code
      and    pl.lookup_type = 'IND RATE SCHEDULE REV TYPE'
      and    sr.ind_rate_sch_revision_id = x_rate_sch_rev_id;

      EXCEPTION
	WHEN NO_DATA_FOUND then
	if x_stage = 3 then
	  x_stage := 3;
	else
          x_stage := 4;
	end if;
	x_return_status := 1;
    end;


    EXCEPTION
      WHEN NO_DATA_FOUND then
        x_return_status := 1;

      WHEN OTHERS then
        x_return_status := SQLCODE;
  end;

end get_ind_rate_sch_rev;

--
--  PROCEDURE
--              get_mc_indirect_cost
--
--  PURPOSE
--              The objective of this procedure is to retrieve the Multi-Currency
--              indirect cost based on a set of qualifications.  User can
--              specify the qualifications and the type of indirect rate
--              schedule, then get the total amount of indirect cost.
--
--  HISTORY
--

     procedure get_compile_set_info(p_txn_interface_id  IN  number DEFAULT NULL, --added for bug 2563364
				    task_id     	IN Number,
                                    effective_date      IN     Date,
                                    expenditure_type    IN     Varchar2,
                                    organization_id     IN     Number,
                                    schedule_type       IN     Varchar2,
				    compiled_multiplier  IN OUT NOCOPY  Number,
                                    compiled_set_id      IN OUT NOCOPY  Number,
                                    status            IN OUT NOCOPY  Number,
                                    stage             IN OUT NOCOPY  Number,
                                    x_cp_structure   IN OUT NOCOPY VARCHAR2, --Bug# 5743708
				                    x_cost_base      IN OUT NOCOPY VARCHAR2  --Bug# 5743708
				                    )
IS
--
-- Local Variables
--
sch_id                  Number(15);
sch_fixed_date          Date;
rate_sch_rev_id         Number(15);
cp_structure            Varchar2(30);
c_base                  Varchar2(30);

BEGIN

   --
   --  Get the rate schedule revision id
   --

   stage := 100;
 		pa_cost_plus.find_rate_sch_rev_id(
                                    p_txn_interface_id, -- changed from NULL for bug 2563364
                                    'PA', /*Bug 4311703 */ -- changed from 'PA' for bug 2563364
                                    task_id,
                                    schedule_type,
                                    effective_date,
                                    sch_id,
                                    rate_sch_rev_id,
                                    sch_fixed_date,
                                    status,
                                    stage);
  IF (status <> 0) THEN
      return;
  END IF;

  --
  -- Get the cost plus structure
  --

  stage := 200;
  pa_cost_plus.get_cost_plus_structure(rate_sch_rev_id,
                                       cp_structure,
                                       status,
                                       stage);

  IF (status <> 0) THEN
      return;
  END IF;

  x_cp_structure :=  cp_structure; --Bug# 5743708
  --
  -- Get the cost base
  --

  stage := 300;
  pa_cost_plus.get_cost_base(expenditure_type,
                             cp_structure,
                             c_base,
                             status,
                             stage);

  IF (status <> 0) THEN
        return;
  END IF;

  x_cost_base := c_base; --Bug# 5743708
  stage := 400;
  pa_cost_plus.get_compiled_set_id(rate_sch_rev_id,
				 organization_id,
                                 c_base,
				 Compiled_set_id,
				 status,
				 stage);

  IF ( status <>0 ) THEN
	return;
  END IF;

  stage := 500;
  pa_cost_plus.get_compiled_multiplier(	organization_id,
				       	c_base,
					rate_sch_rev_id,
					compiled_multiplier,
					status,
					stage);
  IF ( status <>0 ) THEN
	return;
  END IF;
EXCEPTION WHEN OTHERS THEN
  status := SQLCODE;
END get_compile_set_info;

end PA_COST_PLUS1 ;

/
