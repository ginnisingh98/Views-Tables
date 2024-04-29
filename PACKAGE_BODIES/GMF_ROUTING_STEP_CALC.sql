--------------------------------------------------------
--  DDL for Package Body GMF_ROUTING_STEP_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_ROUTING_STEP_CALC" AS
/* $Header: gmfstepb.pls 120.1 2005/08/30 14:59:50 sschinch noship $ */

g_step_table GMD_AUTO_STEP_CALC.STEP_REC_TBL;

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
*	14-May-2002 Rajesh Seshadr Bug 2374512 - added the scale factor
*		attribute while calling gmd api
*	18-Jul-2002 Rajesh Seshadri Bug 2468924 - send process loss to
*	  ASQC routine.
*	02-Jan-2003  Venkat Chukkapalli  Bug#2700453 Added DEFAULT 0 to
*	  process_loss parameters.
**********************************************************************/
PROCEDURE calc_step_qty(
	p_recipe_id IN NUMBER,
	p_fmeff_id IN NUMBER,
	p_scale_factor IN NUMBER,
	p_process_loss IN NUMBER,
	x_error_code OUT NOCOPY NUMBER,
	x_error_msg OUT NOCOPY VARCHAR2) AS

	l_msg_count NUMBER(10);
	l_msg_stack VARCHAR2(240);
	l_return_status VARCHAR2(1);

	l_idx INTEGER;
	l_data          VARCHAR2(2000);
	l_concat_data	VARCHAR2(200);
	l_dummy_count     NUMBER  :=0;

	e_step_calc_error EXCEPTION;

BEGIN
	x_error_code := 0;

	/* Clear the cache */
	g_step_table.DELETE;

	FND_MSG_PUB.Initialize;

	/* Call the gmd procedure */
	/**
	* How do we tell it that we need the formula scaled up?
	* We need to send in the scale_factor - B2374512
	*/
	GMD_AUTO_STEP_CALC.CALC_STEP_QTY(
		p_parent_id => p_recipe_id,
		p_step_tbl => g_step_table,
		p_msg_count => l_msg_count,
		p_msg_stack => l_msg_stack,
		p_return_status => l_return_status,
		p_scale_factor => p_scale_factor,
		p_process_loss => p_process_loss,
		p_organization_id => NULL); /* get back here sschinch INVCONV*/

	/* Handle any errors reported */
	IF( l_return_status <> FND_API.G_RET_STS_SUCCESS )
	THEN
		FOR l_loop_count IN 1..l_msg_count
		LOOP

		  FND_MSG_PUB.Get(
		    p_msg_index     => l_loop_count,
		    p_data          => l_data,
		    p_encoded       => FND_API.G_FALSE,
		    p_msg_index_out => l_dummy_count);

		  l_concat_data := substrb(l_concat_data || ' ' || l_data, 1, 200);

		END LOOP;

		x_error_msg := l_concat_data;
		RAISE e_step_calc_error;
	END IF;

	x_error_code := 0;

EXCEPTION
	WHEN e_step_calc_error THEN
		x_error_code := 1;

END calc_step_qty;

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
	x_error_code OUT NOCOPY NUMBER) AS

	l_idx INTEGER;
	l_step_found BOOLEAN;
	e_step_not_found EXCEPTION;

BEGIN
	x_error_code := 0;

	/* loop through the cache and retrieve the step info */
	l_step_found := FALSE;
	l_idx := g_step_table.FIRST;

	LOOP
		IF( NOT g_step_table.EXISTS(l_idx) )
		THEN
			RAISE e_step_not_found;
		END IF;

		IF( g_step_table(l_idx).step_no = p_step_no )
		THEN
			/* step found; return the step qty */
			x_step_qty := g_step_table(l_idx).step_qty;
			l_step_found := TRUE;
		END IF;

		EXIT WHEN l_step_found;
		EXIT WHEN l_idx = g_step_table.LAST;
		l_idx := g_step_table.NEXT(l_idx);
	END LOOP;

	IF( NOT l_step_found )
	THEN
		x_step_qty := 0.0;
		RAISE e_step_not_found;
	END IF;

	x_error_code := 0;

EXCEPTION
	WHEN e_step_not_found THEN
		x_error_code := 1;

END get_step_qty;

END gmf_routing_step_calc;

/
