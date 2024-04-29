--------------------------------------------------------
--  DDL for Package IGC_CC_VERSION_VIEW_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_VERSION_VIEW_PKG" AUTHID CURRENT_USER AS
/* $Header: IGCCVVWS.pls 120.2.12000000.1 2007/08/20 12:15:04 mbremkum ship $ */
--
-- Global Variable for Views
--
g_version_num    NUMBER ;

--
-- Functions/Procedures to intialize and return global value (version number)
--

PROCEDURE Initialize_View(p_version_num  IN NUMBER);

FUNCTION Get_Version_Num RETURN NUMBER;

END IGC_CC_VERSION_VIEW_PKG ;

 

/
