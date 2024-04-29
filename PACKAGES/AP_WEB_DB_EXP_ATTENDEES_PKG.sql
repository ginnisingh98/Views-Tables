--------------------------------------------------------
--  DDL for Package AP_WEB_DB_EXP_ATTENDEES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_DB_EXP_ATTENDEES_PKG" AUTHID CURRENT_USER AS
/* $Header: apwdbeas.pls 120.2 2006/09/22 08:37:30 mvadera noship $ */

-----------------------------------------------------------------------------
PROCEDURE DeleteAttendees(P_ReportID  IN  NUMBER);
-----------------------------------------------------------------------------
PROCEDURE DuplicateAttendeeInfo(p_user_id IN NUMBER,
                                p_source_report_line_id IN AP_WEB_DB_EXPLINE_PKG.expLines_report_line_id,
				p_target_report_line_id IN AP_WEB_DB_EXPLINE_PKG.expLines_report_line_id);
-----------------------------------------------------------------------------



END AP_WEB_DB_EXP_ATTENDEES_PKG;

 

/
