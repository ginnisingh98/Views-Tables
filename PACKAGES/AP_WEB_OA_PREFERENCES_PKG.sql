--------------------------------------------------------
--  DDL for Package AP_WEB_OA_PREFERENCES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_OA_PREFERENCES_PKG" AUTHID CURRENT_USER AS
/* $Header: apwoapfs.pls 115.6 2002/12/26 10:14:23 srinvenk noship $ */

PROCEDURE ValidateApprover(p_employee_id IN NUMBER,
                           p_approver_name IN OUT NOCOPY VARCHAR2,
                           p_approver_id IN OUT NOCOPY NUMBER,
                           p_return_status OUT NOCOPY VARCHAR2,
                           p_msg_count OUT NOCOPY NUMBER,
                           p_msg_data OUT NOCOPY VARCHAR2);

END AP_WEB_OA_PREFERENCES_PKG;

 

/
