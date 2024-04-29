--------------------------------------------------------
--  DDL for Package XNP_TRACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_TRACE" AUTHID CURRENT_USER AS
/* $Header: XNPDEBGS.pls 120.0 2005/05/30 11:48:41 appldev noship $ */
--
--
-- Used to log messages for debugging purpose
--
PROCEDURE LOG
 (p_DEBUG_LEVEL NUMBER
 ,p_CONTEXT VARCHAR2
 ,p_DESCRIPTION VARCHAR2
 );

END;

 

/
