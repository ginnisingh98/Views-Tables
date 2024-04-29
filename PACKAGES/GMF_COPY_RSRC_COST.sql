--------------------------------------------------------
--  DDL for Package GMF_COPY_RSRC_COST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_COPY_RSRC_COST" AUTHID CURRENT_USER AS
/* $Header: gmfcprcs.pls 120.3 2005/09/01 07:20:00 jboppana noship $ */

/*****************************************************************************
 *  PACKAGE
 *    gmf_copy_rsrc_cost
 *
 *  DESCRIPTION
 *    Copy Resource Costs Package
 *
 *  CONTENTS
 *    FUNCTION	do_costs_exist ( ... )
 *    PROCEDURE	copy_rsrc_cost ( ... )
 *
 *  HISTORY
 *    11-Oct-1999 Rajesh Seshadri
 *    21-Nov-2000 Uday Moogala - Bug# 1419482 Copy Cost Enhancement.
 *      Add last 6 new parameters
 *    30-OCT-2002  RajaSekhar    Bug#2641405 Added NOCOPY hint.
 *
 ******************************************************************************/

   FUNCTION do_costs_exist
   (
   pi_legal_entity_id	   IN             cm_rsrc_dtl.legal_entity_id%TYPE,
	pi_organization_id	   IN             cm_rsrc_dtl.organization_id%TYPE,
	pi_period_id		      IN             cm_rsrc_dtl.period_id%TYPE,
	pi_resource_class	      IN             cr_rsrc_mst.resource_class%TYPE
	)
   RETURN NUMBER;


   FUNCTION do_costs_exist
   (
   pi_legal_entity_id	   IN             cm_rsrc_dtl.legal_entity_id%TYPE,
   pi_period_id		      IN             cm_rsrc_dtl.period_id%TYPE,
	pi_resource_class	      IN             cr_rsrc_mst.resource_class%TYPE
	)
   RETURN NUMBER;

   PROCEDURE copy_rsrc_cost
   (
	po_errbuf		               OUT NOCOPY  VARCHAR2,
	po_retcode		               OUT NOCOPY  VARCHAR2,
   pi_legal_entity_id_from	   IN             cm_rsrc_dtl.legal_entity_id%TYPE,
	pi_organization_id_from	   IN             cm_rsrc_dtl.organization_id%TYPE,
	pi_calendar_code_from	   IN             cm_rsrc_dtl.calendar_code%TYPE,
	pi_period_code_from	      IN             cm_rsrc_dtl.period_code%TYPE,
	pi_cost_type_id_from	      IN             cm_rsrc_dtl.cost_type_id%TYPE,
   pi_legal_entity_id_to	   IN             cm_rsrc_dtl.legal_entity_id%TYPE,
	pi_organization_id_to		IN             cm_rsrc_dtl.organization_id%TYPE,
	pi_calendar_code_to	      IN             cm_rsrc_dtl.calendar_code%TYPE,
	pi_period_code_to	         IN             cm_rsrc_dtl.period_code%TYPE,
	pi_cost_type_id_to	      IN             cm_rsrc_dtl.cost_type_id%TYPE,
	pi_resource_class	         IN             cr_rsrc_mst.resource_class%TYPE,
   pi_all_periods_from        IN             cm_cmpt_dtl.period_code%TYPE,
   pi_all_periods_to          IN             cm_cmpt_dtl.period_code%TYPE,
   pi_all_organization_flag   IN             NUMBER
	);

END gmf_copy_rsrc_cost;

 

/
