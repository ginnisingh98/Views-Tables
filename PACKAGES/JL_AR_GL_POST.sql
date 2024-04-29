--------------------------------------------------------
--  DDL for Package JL_AR_GL_POST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_AR_GL_POST" AUTHID CURRENT_USER as
/* $Header: jlbrrgps.pls 115.1 2002/04/09 15:41:16 pkm ship      $ */

/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES  					      |
 *----------------------------------------------------------------------------*/

  PROCEDURE gl_post(
                  p_posting_control_id          IN  NUMBER ,
                  p_start_gl_date               IN  VARCHAR2 ,
                  p_end_gl_date                 IN  VARCHAR2);

END JL_AR_GL_POST;

 

/
