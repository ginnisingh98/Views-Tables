--------------------------------------------------------
--  DDL for Package FND_IREP_CP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_IREP_CP_PKG" AUTHID CURRENT_USER AS
/* $Header: AFIRCPPS.pls 115.1 2004/05/26 21:39:39 mfisher noship $ */
--
-- Procedure
--   GET_CP_PARAM_ANNOTATIONS
--
-- Purpose
--   Get the parameter details of the given CP
--
-- Returns: the parameter annotations as a clob enclosed within
-- /** and */
--
--
FUNCTION GET_CP_PARAM_ANNOTATIONS(
                          p_cp_id IN NUMBER,
                          p_app_id IN NUMBER)
			  RETURN VARCHAR2;


END FND_IREP_CP_PKG ;

 

/
