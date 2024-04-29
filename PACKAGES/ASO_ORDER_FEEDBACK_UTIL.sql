--------------------------------------------------------
--  DDL for Package ASO_ORDER_FEEDBACK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_ORDER_FEEDBACK_UTIL" AUTHID CURRENT_USER AS
/* $Header: asouomfs.pls 115.1 2002/05/21 17:02:04 pkm ship      $ */

-- ---------------------------------------------------------
-- Declare Data Types
-- ---------------------------------------------------------

-- ---------------------------------------------------------
-- Declare Procedures
-- ---------------------------------------------------------

PROCEDURE Check_LookupCode
(
   p_lookup_type       IN   VARCHAR2,
   p_lookup_code       IN   VARCHAR2,
   p_param_name        IN   VARCHAR2,
   p_api_name          IN   VARCHAR2
);

PROCEDURE Check_Reqd_Param
(
   p_var1      IN NUMBER,
   p_param_name   IN VARCHAR2,
   p_api_name  IN VARCHAR2
);


PROCEDURE Check_Reqd_Param
(
   p_var1      IN VARCHAR2,
   p_param_name   IN VARCHAR2,
   p_api_name  IN VARCHAR2
);


PROCEDURE Check_Reqd_Param
(
   p_var1      IN DATE,
   p_param_name   IN VARCHAR2,
   p_api_name  IN VARCHAR2
);


END ASO_ORDER_FEEDBACK_UTIL;

 

/
