--------------------------------------------------------
--  DDL for Package OKE_GLOBALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_GLOBALS" AUTHID CURRENT_USER AS
/* $Header: OKEGBLS.pls 115.0 2003/11/24 23:09:42 alaw noship $ */

-- -------------------------------------------------------------------
-- Functions and Procedures
-- -------------------------------------------------------------------
PROCEDURE Set_Globals
( P_K_Header_ID      IN      NUMBER
);

FUNCTION K_Header_ID RETURN NUMBER;

END OKE_GLOBALS;

 

/
