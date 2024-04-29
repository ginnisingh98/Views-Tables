--------------------------------------------------------
--  DDL for Package Body OKE_GLOBALS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_GLOBALS" AS
/* $Header: OKEGBLB.pls 115.0 2003/11/24 23:09:50 alaw noship $ */

-- -------------------------------------------------------------------
-- PL/SQL Globals
-- -------------------------------------------------------------------
G_K_Header_ID          NUMBER := NULL;

-- -------------------------------------------------------------------
-- Functions and Procedures
-- -------------------------------------------------------------------
PROCEDURE Set_Globals
( P_K_Header_ID      IN      NUMBER
) IS
BEGIN
  G_K_Header_ID := P_K_Header_ID;
END Set_Globals;

FUNCTION K_Header_ID RETURN NUMBER IS
BEGIN
  RETURN ( G_K_Header_ID );
END K_Header_ID;

END OKE_GLOBALS;

/
