--------------------------------------------------------
--  DDL for Package JL_CO_GL_MG_MEDIA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_CO_GL_MG_MEDIA_PKG" AUTHID CURRENT_USER AS
/* $Header: jlcogmgs.pls 120.4.12010000.1 2008/07/31 04:23:56 appldev ship $ */


  /*********************************************************************
   PROCEDURE
     get_movement

   DESCRIPTION
     Use this procedure to insert transactions and balances from nit
     tables into jl_co_gl_mg_headers and jl_co_gl_mg_lines tables, for a
     set of literal/sub-literal, reported_value (called report_group)
     for a given range of accounts from magnetic media set-up tables

   PURPOSE:
     Oracle Applications Rel 11.0

   PARAMETERS:
     p_set_of_books_id
     p_reported_year
     p_period_start
     p_period_end
     p_literal_start
     p_literal_end

   HISTORY:
     23-DEC-1998   Raja Reddy Kappera    Created

   *********************************************************************/


  PROCEDURE 	get_movement
		(ERRBUF			OUT NOCOPY	VARCHAR2,
		 RETCODE		OUT NOCOPY	VARCHAR2,
 		 p_set_of_books_id 	IN 	gl_sets_of_books.set_of_books_id%TYPE,
 		 p_reported_year 	IN 	jl_co_gl_mg_literals.reported_year%TYPE,
                 p_period_start 	IN 	gl_periods.period_num%TYPE,
		 p_period_end		IN	gl_periods.period_num%TYPE,
		 p_literal_start	IN	jl_co_gl_mg_literals.literal_code%TYPE,
		 p_literal_end		IN	jl_co_gl_mg_literals.literal_code%TYPE
		);


  /*********************************************************************
   PROCEDURE
     threshold

   DESCRIPTION
     Use this procedure to apply Parent Report Grouping Threshold,
     Literal Threshold and Child Report Grouping Threshold to the rows
     in jl_co_gl_mg_lines table.

   PURPOSE:
     Oracle Applications Rel 11.0

   PARAMETERS:
     p_set_of_books_id
     p_reported_year
     p_literal_start
     p_literal_end

   HISTORY:
     23-DEC-1998   Raja Reddy Kappera    Created

   *********************************************************************/

  PROCEDURE 	threshold
		(ERRBUF			OUT NOCOPY	VARCHAR2,
		 RETCODE		OUT NOCOPY	VARCHAR2,
 		 p_set_of_books_id 	IN 	gl_sets_of_books.set_of_books_id%TYPE,
 		 p_reported_year 	IN 	jl_co_gl_mg_literals.reported_year%TYPE,
		 p_literal_start	IN	jl_co_gl_mg_literals.literal_code%TYPE,
		 p_literal_end		IN	jl_co_gl_mg_literals.literal_code%TYPE
		);


  /*********************************************************************
   PROCEDURE
     generate_mg_media

   DESCRIPTION
     Use this procedure to generate magnetic media flat file in standard
     out directory of application with a file name of "o.request_id.out"

   PURPOSE:
     Oracle Applications Rel 11.0

   PARAMETERS:
     p_set_of_books_id
     p_legal_entity_id
     p_reported_year
     p_label

   HISTORY:
     23-DEC-1998   Raja Reddy Kappera    Created

   *********************************************************************/

  PROCEDURE	generate_mg_media
		(ERRBUF			OUT NOCOPY	VARCHAR2,
		 RETCODE		OUT NOCOPY	VARCHAR2,
 		 p_set_of_books_id 	IN 	gl_sets_of_books.set_of_books_id%TYPE,
                 p_legal_entity_id      IN      xle_entity_profiles.legal_entity_id%TYPE,
 		 p_reported_year 	IN 	jl_co_gl_mg_literals.reported_year%TYPE,
		 p_label		IN	VARCHAR2
		);


END JL_CO_GL_MG_MEDIA_PKG;

/
