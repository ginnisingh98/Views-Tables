--------------------------------------------------------
--  DDL for Package JG_XLA_GL_TRANSFER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_XLA_GL_TRANSFER_PKG" AUTHID CURRENT_USER AS
/* $Header: jgzzxlas.pls 115.3 99/10/06 11:53:26 porting ship  $ */

/**************************************************************************
 *                                                                        *
 * Name       : JG_XLA_GL_TRANSFER 		                  	  *
 * Purpose    : This is share procedure which will verify the Product code*
 *              and run the proper Localization Package.          	  *
 *              This procedure is run during the Common Transfer to GL pro*
 *              cess.							  *
 *                                                                        *
 **************************************************************************/

PROCEDURE JG_XLA_GL_TRANSFER (
			  p_application_id                   NUMBER,
			  p_user_id                          NUMBER,
			  p_org_id                           NUMBER,
			  p_request_id                       NUMBER,
			  p_transfer_run_Id		     NUMBER,
			  p_program_name                     VARCHAR2,
			  p_selection_type                   NUMBER DEFAULT 1,
			  p_batch_name                       VARCHAR2,
			  p_start_date                       DATE,
			  p_end_date                         DATE,
			  p_gl_transfer_mode                 VARCHAR2,
			  p_process_days                     NUMBER   DEFAULT 'N',
			  p_debug_flag                       VARCHAR2 );
END JG_XLA_GL_TRANSFER_PKG;

 

/
