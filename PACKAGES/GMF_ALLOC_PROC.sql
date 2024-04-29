--------------------------------------------------------
--  DDL for Package GMF_ALLOC_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_ALLOC_PROC" AUTHID CURRENT_USER AS
/* $Header: gmfalocs.pls 120.2.12010000.1 2008/07/30 05:36:47 appldev ship $ */

/*****************************************************************************
 * PROCEDURE
 *    cost_alloc_proc
 *
 *  DESCRIPTION
 *    This procedure allocates the expenses and is the
 *	 main call.
 *
 *  INPUT PARAMETERS
 *
 *	  v_from_alloc_code   = From Allocation Code.
 *	  v_to_alloc_code     = To Allocation Code.
 *    v_refresh_interface = 0  do not refresh the interface table
 *	                        1  Refresh the interface table.
 *
 *  OUTPUT PARAMETERS
 *    errbuf    holds the exception information
 *
 ******************************************************************************/

   P_fiscal_plcy    gmf_fiscal_policies%ROWTYPE;  		/* To hold fiscal policy information.*/

   C_MODULE  CONSTANT VARCHAR2(80) := 'gmf.plsql.cost_alloc_proc';
   C_LOG_FILE CONSTANT NUMBER(1) := 1;
   C_OUT_FILE CONSTANT NUMBER(1) := 2;

   TYPE segment_value  IS TABLE OF VARCHAR2(255)
	INDEX BY BINARY_INTEGER;

   /* The variables below are used to stored ROW WHO information.*/

   P_created_by            NUMBER   DEFAULT fnd_global.user_id;
   P_login_id              NUMBER   DEFAULT fnd_global.login_id;
   P_prog_application_id   NUMBER   DEFAULT fnd_global.prog_appl_id;
   P_program_id            NUMBER   DEFAULT fnd_global.conc_program_id;
   P_request_id            NUMBER   DEFAULT fnd_global.conc_request_id;

   /* The variables below are used to hold account key mask information.*/

   P_of_segment_delimeter   VARCHAR2(1);

  PROCEDURE cost_alloc_proc(errbuf              OUT NOCOPY VARCHAR2,
                          retcode             OUT NOCOPY VARCHAR2,
                          p_legal_entity_id   IN NUMBER,
                          p_calendar_code     IN VARCHAR2,
                          p_period_code       IN VARCHAR2,
                          p_cost_type_id      IN NUMBER,
                          p_fiscal_year       IN VARCHAR2,
                          p_period_num        IN NUMBER,
                          v_from_alloc_code   IN gl_aloc_mst.alloc_code%TYPE,
                          v_to_alloc_code     IN gl_aloc_mst.alloc_code%TYPE,
                          v_refresh_interface IN VARCHAR2
                         );

   PROCEDURE delete_allocations(v_from_alloc_code VARCHAR2,
	  	        	                v_to_alloc_code   VARCHAR2,
		  		                      v_status      OUT NOCOPY NUMBER);


   FUNCTION get_legal_entity_details RETURN NUMBER; /* INVCONV sschinch */

   PROCEDURE delete_interface(v_status OUT NOCOPY NUMBER);

   PROCEDURE cost_allocate(v_from_alloc_code   VARCHAR2,
			                     v_to_alloc_code     VARCHAR2,
                           v_refresh_interface NUMBER,
	  	                     v_status            OUT NOCOPY NUMBER);


  PROCEDURE get_expenses(v_from_alloc_code VARCHAR2,
                         v_to_alloc_code   VARCHAR2);


  PROCEDURE insert_alloc_inp(v_alloc_id     NUMBER,
						                 v_line_no      VARCHAR2,
			     			             v_account_type NUMBER,
						                 v_to_segment   NUMBER, /* INVCONV sschinch*/
                             v_amount       NUMBER);

  PROCEDURE put_alloc_expenses(v_alloc_id     NUMBER,
                               v_line_no      VARCHAR2,
                               v_from_segment NUMBER, /* INVCONV sschinch */
						                   v_to_segment   NUMBER, /* INVCONV sschinch */
                               v_balance_type NUMBER,
                               v_ytd_ptd      NUMBER,
                               v_account_type NUMBER);

  PROCEDURE get_alloc_basis(v_from_alloc_code VARCHAR2,
			                      v_to_alloc_code   VARCHAR2);

  PROCEDURE refresh_fixed(v_from_alloc_code VARCHAR2,
						              v_to_alloc_code VARCHAR2);


  PROCEDURE process_alloc_dtl(v_from_alloc_code VARCHAR2,
						                  v_to_alloc_code   VARCHAR2);

END GMF_ALLOC_PROC;

/
