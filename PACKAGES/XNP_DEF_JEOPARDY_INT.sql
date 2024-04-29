--------------------------------------------------------
--  DDL for Package XNP_DEF_JEOPARDY_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XNP_DEF_JEOPARDY_INT" AUTHID CURRENT_USER AS
/* $Header: XNPJINTS.pls 120.0 2005/05/30 11:48:57 appldev noship $ */
--
--
--  API Name      : get_interval
--  Type          : Private
--  Purpose       : Get interval for the default jeopardy timer.
--  Parameters    : p_order_id
--
--
FUNCTION get_interval ( p_order_id IN NUMBER)
RETURN  NUMBER;

END xnp_def_jeopardy_int;

 

/
