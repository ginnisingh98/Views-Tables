--------------------------------------------------------
--  DDL for Package PSA_REP_ATTRIBUTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_REP_ATTRIBUTES" AUTHID CURRENT_USER AS
/* $Header: psagratts.pls 120.0.12000000.1 2007/07/24 21:16:11 sasukuma noship $ */

  --   NAME
  --       GL_PREPARATION
  --   DESCRIPTION
  --   		This program creates the Flexfield and the segments
  -- 		for the Flexfield code 'GLAT'
  --   PARAMETERS
  PROCEDURE gl_preparation
  (
    errbuf      OUT NOCOPY    VARCHAR2,
    retcode     OUT NOCOPY    VARCHAR2,
    p_ledger_id IN NUMBER
  );

  --   NAME
  --      GL_HISTORY
  --   DESCRIPTION
  --		This program updates the GL_CODE_COMBINATIONS table
  --			for the given chart of accounts id
  --   PARAMETERS
  PROCEDURE gl_history
  (
    errbuf                 OUT NOCOPY    VARCHAR2,
    retcode                OUT NOCOPY    VARCHAR2,
    p_ledger_id            IN NUMBER,
    p_segment_name         IN VARCHAR2 DEFAULT NULL,
    p_denormalized_segment IN VARCHAR2 DEFAULT NULL
  );
END PSA_REP_ATTRIBUTES;

 

/
