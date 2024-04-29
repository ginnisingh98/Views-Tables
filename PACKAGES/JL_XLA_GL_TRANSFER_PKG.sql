--------------------------------------------------------
--  DDL for Package JL_XLA_GL_TRANSFER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_XLA_GL_TRANSFER_PKG" AUTHID CURRENT_USER AS
/* $Header: jlzzxlas.pls 115.1 99/09/13 16:30:26 porting ship  $ */

/**************************************************************************
 *                                                                        *
 * Name       : JL_XLA_GL_TRANSFER 		                  	  *
 * Purpose    : This is a procedure which will run the country  Balance   *
 *		Maintenance.					  	  *
 *              							  *
 *  Parameters:								  *
 *  p_request_id contains the concurrent program request id		  *
 *  p_transfer_run_id contains the Transfer Run ID for a batch		  *
 *  p_start_date contains the start date of current commit cycle iteration*
 *  p_end_date contains the end date of current commit cycle iteration.   *
 *                                                                        *
 *                                                                        *
 **************************************************************************/

PROCEDURE jl_xla_gl_transfer ( p_request_id 	 NUMBER,
			      p_transfer_run_id	 NUMBER,
			      p_start_date 	 DATE,
			      p_end_date   	 DATE);

END jl_xla_gl_transfer_pkg;

 

/
