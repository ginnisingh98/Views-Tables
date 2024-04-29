--------------------------------------------------------
--  DDL for Package GMF_ROUTING_STEP_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_ROUTING_STEP_CALC" AUTHID CURRENT_USER AS
/* $Header: gmfsteps.pls 120.0 2005/05/26 00:51:21 appldev noship $ */

/**********************************************************************
* NAME
*	CALC_STEP_QTY
*
* DESCRIPTION
*	Wrapper for GMD_AUTO_STEP_CALC.calc_step_qty procedure
*	Calls the gmd procedure and caches the step table output in
*	a package variable.  The next procedure get_step_qty is
*	used to retrieve the individual rows from the cost_calc_rout
*	function of cost rollup and in variances calculation of
*	subledger.
* HISTORY
*	12-Apr-2002 Rajesh Seshadri Bug 2269125
*	18-Jul-2002 Rajesh Seshadri Bug 2468924 - send process loss to
*	  ASQC routine.
*	02-Jan-2003  Venkat Chukkapalli  Bug#2700453 Added DEFAULT 0 to
*	  process_loss parameters.
**********************************************************************/
PROCEDURE calc_step_qty(
	p_recipe_id IN NUMBER,
	p_fmeff_id IN NUMBER,
	p_scale_factor IN NUMBER,
	p_process_loss IN NUMBER DEFAULT 0,
	x_error_code OUT NOCOPY NUMBER,
	x_error_msg OUT NOCOPY VARCHAR2);

/**********************************************************************
* NAME
*	GET_STEP_QTY
*
* DESCRIPTION
*	Used to retrieve the individual step's quantity.  Called from
*	cost_calc_rout of cost rollup and compute_variances of
*	subledger.
*
* HISTORY
*	12-Apr-2002 Rajesh Seshadri Bug 2269125
**********************************************************************/
PROCEDURE get_step_qty(
	p_recipe_id IN NUMBER,
	p_step_id IN NUMBER,
	p_step_no IN NUMBER,
	x_step_qty OUT NOCOPY NUMBER,
	x_error_code OUT NOCOPY NUMBER);

END gmf_routing_step_calc;

 

/
