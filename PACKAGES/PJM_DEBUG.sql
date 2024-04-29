--------------------------------------------------------
--  DDL for Package PJM_DEBUG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_DEBUG" AUTHID CURRENT_USER AS
/* $Header: PJMDBGS.pls 115.3 2003/07/09 22:08:52 alaw noship $ */

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
PROCEDURE Indent ( level IN  NUMBER );

END PJM_DEBUG;

 

/
