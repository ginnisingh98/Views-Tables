--------------------------------------------------------
--  DDL for Package Body PQP_PENS_AND_AVCS_FUNCTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_PENS_AND_AVCS_FUNCTION" AS
-- $Header: pqgbpafn.pkb 115.4 2003/06/24 15:59:27 bsamuel noship $
-----------------------------------------------------------------------------
-- FUNCTION pqp_check_pension_cap
-----------------------------------------------------------------------------
FUNCTION  pqp_check_pension_cap(    p_salary_cap          IN      NUMBER
                                   ,p_salary_prp_cap      IN      NUMBER
                                   ,p_total_contribution  IN OUT NOCOPY  NUMBER
                                   ,p_superannuable_ptd   IN      NUMBER
                                   ,p_superannuation_tot  IN      NUMBER
                                   ,p_total_pens_cont     IN      NUMBER)
RETURN CHAR IS

  l_final_contribution    number := 0;
  l_adj_contribution      number := 0;
  l_ref_cont              number := 0;
  l_actual_cont           number := 0;
  l_mesg                  varchar2(200);

  -- nocopy changes
  l_total_contrib_nc      number;

BEGIN

 l_total_contrib_nc  := p_total_contribution;

  p_total_contribution := ROUND(p_total_contribution,2);

  -- Added to fix bug 2273146

  IF p_superannuable_ptd <= 0 THEN

     p_total_contribution := 0;
     l_mesg               := 'insufficient pay to make contributions';
     RETURN l_mesg;

  END IF; -- End if of salary check ...
  -- End Bug 2273146

  -- Test the percentage cap
  -- Bug fix 3000682
  -- Check percentage and annual cap limit independently

  l_ref_cont    := ROUND(((p_superannuable_ptd * p_salary_prp_cap)/100),2);
  l_actual_cont := p_total_contribution + p_superannuation_tot;

  IF l_ref_cont < l_actual_cont THEN

     l_adj_contribution   := l_actual_cont - l_ref_cont;

     IF l_adj_contribution < p_total_contribution THEN

        l_final_contribution := p_total_contribution - l_adj_contribution;

     ELSE

        l_final_contribution := 0;

     END IF; -- End if of adj cont < total cont check...
     l_mesg := 'contribution amount exceeds percentage capping limit.';

  ELSE
     l_final_contribution := p_total_contribution;
     l_mesg               := 'SUCCESS';

  END IF; -- End if of percentage cap check ...

  p_total_contribution := l_final_contribution;

  -- Test the total amount cap

  l_ref_cont    := ROUND(((p_salary_cap * p_salary_prp_cap)/100),2);
  l_actual_cont := p_total_contribution + p_total_pens_cont;

  IF l_ref_cont < l_actual_cont THEN

     l_adj_contribution   := l_actual_cont - l_ref_cont;

     IF l_adj_contribution < p_total_contribution THEN

        l_final_contribution := p_total_contribution - l_adj_contribution;

     ELSE

        l_final_contribution := 0;

     END IF; -- End if of adj cont < total cont check...

     IF l_mesg <> 'SUCCESS' THEN
        l_mesg := 'contribution amount exceeds percentage capping limit '
                 ||
                  'and total amount capping limit';
     ELSE
        l_mesg := 'contribution amount exceeds total amount capping limit';
     END IF; -- End if of mesg <> success check ...

  ELSE

      l_final_contribution := p_total_contribution;

  END IF; -- End if of annual cap check...

  p_total_contribution := l_final_contribution;
  RETURN(l_mesg);

-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       p_total_contribution := l_total_contrib_nc;
       raise;


END pqp_check_pension_cap;

-----------------------------------------------------------------------------
-- FUNCTION pqp_check_net_pay
-----------------------------------------------------------------------------
FUNCTION  pqp_check_net_pay(p_total_contribution  IN OUT NOCOPY  NUMBER
                           ,p_net_pay_ptd         IN      NUMBER
                           )
RETURN CHAR IS

  l_mesg                  varchar2(80);

  -- nocopy changes
  l_total_contrib_nc      number;

BEGIN


  -- nocopy changes
  l_total_contrib_nc := p_total_contribution;

  p_total_contribution  := ROUND(p_total_contribution,2);

  -- Added for bug fix 2273146

  IF p_net_pay_ptd <= 0 THEN

     p_total_contribution := 0;
     l_mesg               := 'insufficient net pay to make contributions';
     RETURN l_mesg;

  END IF; -- end if of total contribution is negative check ...

  -- End bug fix 2273146

  IF p_total_contribution > p_net_pay_ptd THEN

     p_total_contribution := p_net_pay_ptd;
     l_mesg               := 'contribution amount exceeds net pay amount';

  ELSE

     l_mesg               := 'SUCCESS';

  END IF; -- End if of net pay check...

  RETURN(l_mesg);
-- Added by tmehra for nocopy changes Feb'03

EXCEPTION
    WHEN OTHERS THEN
       p_total_contribution := l_total_contrib_nc;
       raise;


END pqp_check_net_pay;

-----------------------------------------------------------------------------

END pqp_pens_and_avcs_function;

/
