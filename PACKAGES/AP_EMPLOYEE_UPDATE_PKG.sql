--------------------------------------------------------
--  DDL for Package AP_EMPLOYEE_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_EMPLOYEE_UPDATE_PKG" AUTHID CURRENT_USER AS
/* $Header: aphrupds.pls 120.1 2004/10/28 00:00:35 pjena noship $ */

FUNCTION Update_Employee(
		p_update_date           IN      DATE,
		p_from_supplier         IN      VARCHAR2,
		p_to_supplier           IN	VARCHAR2,
                p_debug_mode            IN      VARCHAR2,
                p_calling_sequence      IN      VARCHAR2
		) RETURN BOOLEAN;

END AP_EMPLOYEE_UPDATE_PKG;

 

/
