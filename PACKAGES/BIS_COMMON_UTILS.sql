--------------------------------------------------------
--  DDL for Package BIS_COMMON_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_COMMON_UTILS" AUTHID CURRENT_USER AS
  /* $Header: BISCUTLS.pls 120.0 2005/06/01 17:43:30 appldev noship $ */
---  Copyright (c) 2000 Oracle Corporation, Redwood Shores, CA, USA
---  All rights reserved.
---
---==========================================================================
---  FILENAME
---
---     BISCUTLS.pls
---
---  DESCRIPTION
---     Package Specification File for common (Non-Product) specific utility functions
---
---  NOTES
---
---  HISTORY
---
---  25-Dec-2003 mdamle     Created
---  19-MAY-2005  visuri   GSCC Issues bug 4363854
---===========================================================================

G_DEF_CHAR   	CONSTANT    VARCHAR2(1) := chr(0);
G_DEF_NUM  	CONSTANT    NUMBER  	:= 9.99E125;
G_DEF_DATE    	CONSTANT    DATE    	:= TO_DATE('1','j');

G_MISS_CHAR   	CONSTANT    VARCHAR2(1) := chr(0);
G_MISS_NUM  	CONSTANT    NUMBER  	:= 9.99E125;
G_MISS_DATE    	CONSTANT    DATE    	:= TO_DATE('1','j');


function replaceParameterValue(
 p_param_string	IN VARCHAR2
,p_key		IN VARCHAR2
,p_new_value	IN VARCHAR2) return VARCHAR2;

function getParameterValue(
 p_param_string	IN VARCHAR2
,p_key		IN VARCHAR2) return VARCHAR2;

end BIS_COMMON_UTILS;


 

/
