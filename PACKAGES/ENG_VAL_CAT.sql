--------------------------------------------------------
--  DDL for Package ENG_VAL_CAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENG_VAL_CAT" AUTHID CURRENT_USER AS
/* $Header: ENGVCATS.pls 115.0.1159.2 2003/06/09 09:05:59 rbehal ship $ */

FUNCTION Has_Change_objects (  p_change_mgmt_type_code	IN VARCHAR2, p_called IN NUMBER) return VARCHAR2;

FUNCTION Has_Active_Change_objects (  p_change_mgmt_type_code	IN VARCHAR2) return VARCHAR2;

END ENG_VAL_CAT;


 

/
