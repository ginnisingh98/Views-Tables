--------------------------------------------------------
--  DDL for Package OKE_CHECK_HOLD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_CHECK_HOLD_PKG" AUTHID CURRENT_USER AS
/*$Header: OKECKHDS.pls 115.6 2003/10/13 05:21:44 yliou ship $ */


  -- GLOBAL VARIABLES

  G_PKG_NAME     CONSTANT VARCHAR2(200) := 'OKE_CHECK_HOLD_PKG';
  G_APP_NAME     CONSTANT VARCHAR2(200) := OKE_API.G_APP_NAME;

-- Overloading function : with OUT parameters, return TRUE or FALSE
-- for PL/SQL in forms.
FUNCTION is_hold(p_api_version         IN  NUMBER,
    	   	     p_init_msg_list       IN  VARCHAR2,
       		     x_return_status       OUT NOCOPY VARCHAR2,
    		     x_msg_count           OUT NOCOPY NUMBER,
    		     x_msg_data            OUT NOCOPY VARCHAR2,
                 p_hold_level 		IN  VARCHAR2,
                 p_k_header_id		IN  NUMBER,
                 p_k_line_id		IN  NUMBER,
                 p_deliverable_id	IN  NUMBER)
                 RETURN BOOLEAN;
-- Overloading function : no OUT parameters, return 1 or 0
-- for SQL view
FUNCTION is_hold(p_hold_level 		IN  VARCHAR2,
                 p_k_header_id		IN  NUMBER,
                 p_k_line_id		IN  NUMBER,
                 p_deliverable_id	IN  NUMBER)
                 RETURN NUMBER;


/*-------------------------------------------------------------------------
 FUNCTION get_hold_descr - get contract description
                  if the hold is on contract level
                  get line description if the hold is on line level
                  get deliverable description if the hold is on
                      deliverable level
--------------------------------------------------------------------------*/
FUNCTION get_hold_descr (p_k_header_id		IN  NUMBER,
                p_k_line_id		IN  NUMBER,
                p_deliverable_id	IN  NUMBER)
                RETURN VARCHAR2;

END OKE_CHECK_HOLD_PKG;


 

/
