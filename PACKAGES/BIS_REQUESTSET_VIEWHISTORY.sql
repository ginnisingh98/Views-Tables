--------------------------------------------------------
--  DDL for Package BIS_REQUESTSET_VIEWHISTORY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIS_REQUESTSET_VIEWHISTORY" AUTHID CURRENT_USER AS
/*$Header: BISRSVHS.pls 120.0 2005/06/01 17:22:28 appldev noship $*/

function get_lookup_meaning(p_type in varchar2,
                            p_code in varchar2) return varchar2;

function get_sys_lookup_meaning(p_type in varchar2,
                            p_code in varchar2) return varchar2;

function get_bis_lookup_meaning(p_type in varchar2,
                            p_code in varchar2) return varchar2;
/*
 Removed Get_User_Object_Name for bug3950162
function Get_User_Object_Name (
 P_OBJECT_TYPE          IN VARCHAR2,
 P_OBJECT_NAME          IN VARCHAR2
) RETURN varchar2;
*/
END BIS_REQUESTSET_VIEWHISTORY;

 

/
