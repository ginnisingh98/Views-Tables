--------------------------------------------------------
--  DDL for Package XLA_OA_FUNCTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XLA_OA_FUNCTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: xlaoaftn.pkh 120.3 2003/11/19 19:22:38 wychan ship $ */
-------------------------------------------------------------------------------
-- declaring global constants
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Public API
-------------------------------------------------------------------------------

FUNCTION get_ccid_description
  (p_coa_id		IN INTEGER
  ,p_ccid               IN INTEGER)
RETURN VARCHAR2;

FUNCTION get_message
  (p_encoded_msg	IN VARCHAR2)
RETURN VARCHAR2;

END xla_oa_functions_pkg;
 

/
