--------------------------------------------------------
--  DDL for Package Body PA_BURDEN_CMTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BURDEN_CMTS" AS
/* $Header: PABCMTB.pls 115.5 2003/08/18 12:50:21 ajdas ship $ */

-- This function returns the compiled_set_id
-- This function will return NULL in case of error or if the compiled_set_id
-- is not found

FUNCTION get_cmt_compiled_set_id
	  ( x_transaction_id        IN NUMBER,
       x_transaction_type      IN VARCHAR2,
       x_task_id               IN NUMBER,
	    x_expenditure_item_date IN DATE,
	    x_organization_id       IN NUMBER,
	    p_expenditure_type       IN pa_expenditure_types.expenditure_type%TYPE,
	    x_schedule_type         IN VARCHAR2)
RETURN NUMBER
IS
  compiled_set_id     NUMBER;
  cost_base           pa_cost_bases.cost_base%TYPE;
  cp_structure        pa_cost_plus_structures.cost_plus_structure%TYPE;
  rate_sch_rev_id     NUMBER;
  sch_id              NUMBER;
  sch_fixed_date      DATE;
  status              NUMBER;
  stage               NUMBER;
BEGIN

  -- First get the rate_sch_rev_id

  compiled_set_id := NULL;

  pa_cost_plus.find_rate_sch_rev_id(
        x_transaction_id,
        x_transaction_type,
	     x_task_id,
	     x_schedule_type,
	     x_expenditure_item_date,
	     sch_id,
	     rate_sch_rev_id,
	     sch_fixed_date,
	     status,
	     stage);

  IF ( status <> 0 ) THEN
    RETURN NULL;
  END IF;

  pa_cost_plus.get_cost_plus_structure( rate_sch_rev_id => rate_sch_rev_id
                                       ,cp_structure    => cp_structure
                                       ,status          => status
                                       ,stage           => stage
                                      );

  IF (status <> 0) THEN
      return NULL;
  END IF;

  pa_cost_plus.get_cost_base( exp_type     => p_expenditure_type
                             ,cp_structure => cp_structure
                             ,c_base       => cost_base
                             ,status       => status
                             ,stage        => stage
                            );

  IF (status <> 0) THEN
        return NULL;
  END IF;

  -- Now get the compiled_set_id

  pa_cost_plus.get_compiled_set_id(
             rate_sch_rev_id,
             x_organization_id,
             cost_base,
             compiled_set_id,
             status,
             stage);

  IF (status <> 0) THEN
        return NULL;
  END IF;

  RETURN compiled_set_id;

EXCEPTION
 WHEN OTHERS THEN
    RETURN NULL;
END get_cmt_compiled_set_id;

-- This function returns the burdened_cost
-- in case if it is not able to calculate the burden cost component
-- then it will return the direct_cost itself.

FUNCTION get_cmt_burdened_cost
	  ( x_transaction_id        IN NUMBER,
       x_transaction_type      IN VARCHAR2,
       x_task_id               IN NUMBER,
	    x_expenditure_item_date IN DATE,
            x_expenditure_type      IN VARCHAR2,
	    x_organization_id       IN NUMBER,
	    x_schedule_type         IN VARCHAR2,
            x_direct_cost           IN NUMBER)
RETURN NUMBER
IS
  indirect_cost       NUMBER;
  status              NUMBER;
  stage               NUMBER;
BEGIN

  -- Get the burden cost component first

  indirect_cost  := 0;

  pa_cost_plus.view_indirect_cost(
        x_transaction_id,
        x_transaction_type,
	    x_task_id,
	    x_expenditure_item_date,
            x_expenditure_type,
	    x_organization_id,
	    x_schedule_type,
            x_direct_cost,
            indirect_cost,
            status,
            stage);

  IF ( status <> 0 ) THEN
    RETURN x_direct_cost;
  END IF;

  RETURN x_direct_cost + indirect_cost;

EXCEPTION
 WHEN OTHERS THEN
    RETURN NULL;
END get_cmt_burdened_cost;

END PA_BURDEN_CMTS;

/
