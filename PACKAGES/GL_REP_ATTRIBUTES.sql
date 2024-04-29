--------------------------------------------------------
--  DDL for Package GL_REP_ATTRIBUTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_REP_ATTRIBUTES" AUTHID CURRENT_USER AS
/* $Header: glgratts.pls 120.3 2005/05/05 02:05:43 kvora noship $ */

  --   NAME
  --       GL_PREPARATION
  --   DESCRIPTION
  --   		This program creates the Flexfield and the segments
  -- 		for the Flexfield code 'GLAT'
  --   PARAMETERS
  PROCEDURE gl_preparation( retcode             OUT NOCOPY    VARCHAR2,
  			    errbuf             OUT NOCOPY    VARCHAR2,
  			    p_chart_of_accounts_id    IN     NUMBER );

  --   NAME
  --      GL_HISTORY
  --   DESCRIPTION
  --		This program updates the GL_CODE_COMBINATIONS table
  --			for the given chart of accounts id
  --   PARAMETERS
  PROCEDURE gl_history ( retcode      OUT NOCOPY    VARCHAR2,
  			 errbuf	      OUT NOCOPY    VARCHAR2,
  			p_chart_of_accounts_id    IN NUMBER,
  			p_segment_name 		  IN VARCHAR2 DEFAULT NULL,
  			p_denormalized_segment	  IN VARCHAR2 DEFAULT NULL);
END GL_REP_ATTRIBUTES;

 

/
