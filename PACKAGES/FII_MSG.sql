--------------------------------------------------------
--  DDL for Package FII_MSG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_MSG" AUTHID CURRENT_USER AS
/* $Header: FIIGLC3S.pls 120.7 2005/10/30 05:08:06 appldev noship $ */

  -- Function
  --   get_msg
  --
  -- Purpose
  -- 	Returns string "XTD"
  --
  -- History
  --   22-JUN-02  M Bedekar 	Created
  --

FUNCTION get_msg (p_page_id           IN     VARCHAR2
,p_user_id           IN     VARCHAR2
,p_session_id           IN     VARCHAR2
,p_function_name           IN     VARCHAR2
)RETURN VARCHAR2;

FUNCTION get_msg1 (p_page_id           IN     VARCHAR2
,p_user_id           IN     VARCHAR2
,p_session_id           IN     VARCHAR2
,p_function_name           IN     VARCHAR2
)RETURN VARCHAR2;

FUNCTION get_msg2 (p_page_id           IN     VARCHAR2
,p_user_id           IN     VARCHAR2
,p_session_id           IN     VARCHAR2
,p_function_name           IN     VARCHAR2
)RETURN VARCHAR2;

FUNCTION get_msg3 ( p_current IN VARCHAR2
)RETURN VARCHAR2;

FUNCTION get_curr RETURN VARCHAR2;

FUNCTION get_manager RETURN NUMBER;

FUNCTION get_dbi_params(region_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION get_curr_label RETURN VARCHAR2;

FUNCTION get_prior_label RETURN VARCHAR2;

FUNCTION get_margin_label RETURN VARCHAR2;

END fii_msg;


 

/
