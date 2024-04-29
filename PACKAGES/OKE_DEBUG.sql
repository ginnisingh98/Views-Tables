--------------------------------------------------------
--  DDL for Package OKE_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_DEBUG" AUTHID CURRENT_USER AS
/* $Header: OKEDBGS.pls 115.0 2003/10/06 23:41:56 alaw noship $ */

-- -------------------------------------------------------------------
-- PL/SQL Server Debug Log Utilities
-- -------------------------------------------------------------------
PROCEDURE Enable_Debug;
PROCEDURE Disable_Debug;
FUNCTION  Debug_Mode RETURN VARCHAR2;
PROCEDURE Debug
( text       IN  VARCHAR2
, module     IN  VARCHAR2  DEFAULT NULL
, log_level  IN  NUMBER    DEFAULT NULL
);

END OKE_DEBUG;

 

/
