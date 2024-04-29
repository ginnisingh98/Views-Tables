--------------------------------------------------------
--  DDL for Package EDW_SYSTEM_PARAMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_SYSTEM_PARAMS_PKG" AUTHID CURRENT_USER AS
/* $Header: edwparms.pls 115.9 2004/02/04 11:16:46 smulye ship $ */

Procedure pushToSource(inst_down OUT NOCOPY VARCHAR2);
Function isInstanceRunning(p_mode IN NUMBER, p_db_link IN VARCHAR2, p_instance IN VARCHAR2) RETURN BOOLEAN;
--Procedure checkInstancesRunning(inst_down OUT VARCHAR2);
function count_item_flex_segments(l_db_link varchar2) return number;
function is_vbh_available (l_db_link varchar2) return varchar2;
function is_eni_pkg_exist (l_db_link varchar2) return varchar2;
End EDW_SYSTEM_PARAMS_PKG;

 

/
