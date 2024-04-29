--------------------------------------------------------
--  DDL for Package GMF_COPY_ITEM_COST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_COPY_ITEM_COST" AUTHID CURRENT_USER AS
/* $Header: gmfcpics.pls 120.1.12000000.1 2007/01/17 16:56:06 appldev ship $ */

/*****************************************************************************
 *  PACKAGE
 *    gmf_copy_item_cost
 *
 *  DESCRIPTION
 *    Copy Item Costs Package
 *
 *  CONTENTS
 *    PROCEDURE	copy_item_cost ( ... )
 *
 *  HISTORY
 *    13-Oct-1999 Rajesh Seshadri
 *    21-Nov-2000 Uday Moogala - Bug# 1419482 Copy Cost Enhancement.
 *      Add last 6 new parameters.
 *    24-Jan-2002 Chetan Nagar - B2198228 Added paramter copy_to_upper_lvl
 *      for enhancement fix related to cost rollup (Ref. Bug 2116142).
 *    30/Oct/2002  R.Sharath Kumar    Bug# 2641405
 *      Added NOCOPY hint
 ******************************************************************************/


PROCEDURE copy_item_cost
(
po_errbuf				      OUT 	NOCOPY 	VARCHAR2,
po_retcode			         OUT 	NOCOPY 	VARCHAR2,
pi_organization_id_from    IN 		      cm_cmpt_dtl.organization_id%TYPE,
pi_calendar_code_from		IN 		      cm_cmpt_dtl.calendar_code%TYPE,
pi_period_code_from		   IN 		      cm_cmpt_dtl.period_code%TYPE,
pi_cost_type_id_from		   IN 		      cm_cmpt_dtl.cost_type_id%TYPE,
pi_organization_id_to		IN 		      cm_cmpt_dtl.organization_id%TYPE,
pi_calendar_code_to		   IN 		      cm_cmpt_dtl.calendar_code%TYPE,
pi_period_code_to			   IN 		      cm_cmpt_dtl.period_code%TYPE,
pi_cost_type_id_to		   IN 		      cm_cmpt_dtl.cost_type_id%TYPE,
pi_item_from			      IN 		      mtl_system_items_b_kfv.concatenated_segments%TYPE,
pi_item_to			         IN 		      mtl_system_items_b_kfv.concatenated_segments%TYPE,
pi_itemcc_from			      IN 		      mtl_categories_b_kfv.concatenated_segments%TYPE,
pi_itemcc_to			      IN 		      mtl_categories_b_kfv.concatenated_segments%TYPE,
pi_incr_pct			         IN 		      VARCHAR2,
pi_incr_decr_cost			   IN 		      VARCHAR2,
pi_rem_repl			         IN 		      VARCHAR2,
pi_all_periods_from		   IN 		      cm_cmpt_dtl.period_code%TYPE,
pi_all_periods_to			   IN 		      cm_cmpt_dtl.period_code%TYPE,
pi_all_org_id			      IN 		      gmf_legal_entities.legal_entity_id%TYPE,
pi_copy_to_upper_lvl		   IN 		      VARCHAR2
);


PROCEDURE copy_burden_cost
(
po_errbuf				         OUT 	NOCOPY 	VARCHAR2,
po_retcode			            OUT 	NOCOPY 	VARCHAR2,
pi_organization_id_from		   IN 		cm_cmpt_dtl.organization_id%TYPE,
pi_calendar_code_from		   IN 		cm_cmpt_dtl.calendar_code%TYPE,
pi_period_code_from		      IN 		cm_cmpt_dtl.period_code%TYPE,
pi_cost_type_id_from		      IN 		cm_cmpt_dtl.cost_type_id%TYPE,
pi_organization_id_to		   IN 		cm_cmpt_dtl.organization_id%TYPE,
pi_calendar_code_to		      IN 		cm_cmpt_dtl.calendar_code%TYPE,
pi_period_code_to		         IN 		cm_cmpt_dtl.period_code%TYPE,
pi_cost_type_id_to		      IN 		cm_cmpt_dtl.cost_type_id%TYPE,
pi_item_from			         IN 		mtl_item_flexfields.item_number%TYPE,
pi_item_to			            IN 		mtl_item_flexfields.item_number%TYPE,
pi_itemcc_from			         IN 		mtl_categories_b_kfv.concatenated_segments%TYPE,
pi_itemcc_to			         IN 		mtl_categories_b_kfv.concatenated_segments%TYPE,
pi_rem_repl			            IN 		VARCHAR2,
pi_all_periods_from		      IN 		cm_cmpt_dtl.period_code%TYPE,
pi_all_periods_to		         IN 		cm_cmpt_dtl.period_code%TYPE,
pi_all_org_id			         IN 		gmf_legal_entities.legal_entity_id%TYPE
);

END gmf_copy_item_cost;

 

/
