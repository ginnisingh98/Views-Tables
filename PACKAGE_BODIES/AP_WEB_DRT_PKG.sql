--------------------------------------------------------
--  DDL for Package Body AP_WEB_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_DRT_PKG" AS
/* $Header: apwxdrtb.pls 120.0.12010000.5 2018/06/22 06:55:04 abonthu noship $ */

  PROCEDURE write_log
    (message       IN         varchar2
	,stage		 IN					varchar2) IS
  BEGIN
	if fnd_log.g_current_runtime_level<=fnd_log.level_procedure then
		fnd_log.string(fnd_log.level_procedure,message,stage);
	end if;
  END write_log;

  --
  --- Implement OIE specific DRC for PER entity type
  --
  PROCEDURE oie_hr_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type) IS
	l_employeeId NUMBER(10);
	l_countActiveER NUMBER;
	l_countER NUMBER;
  BEGIN
    write_log ('Entering: oie_per_drc','10');
	l_employeeId := person_id;
        write_log ('employee id is: ' || l_employeeId,'20');
        BEGIN
		select 1 into l_countActiveER from ap_Expense_report_headers_all where employee_id = l_employeeId and
	expense_status_code in ('RESOLUTN','HOLD_PENDING_RECEIPTS','PEND_HOLDS_CLEARANCE','EMPAPPR','PENDMGR','INVOICED','MGRAPPR','SUBMITTED','PENDING_IMAGE_SUBMISSION')
and rownum = 1;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_countActiveER :=0;
        END;
	if(l_countActiveER <> 0)
	then
		per_drt_pkg.add_to_results
			  (person_id => l_employeeId
  			  ,entity_type => 'TCA'
			  ,status => 'W'
			  ,msgcode => 'OIE_ACTIVE_REPORTS_EXISTS'
			  ,msgaplid => 200
			  ,result_tbl => result_tbl);
	end if;
	BEGIN
		select 1 into l_countER from ap_Expense_report_headers_all aerh where aerh.employee_id = l_employeeId and
				EXISTS (select docs.document_id from fnd_attached_documents docs where
						(docs.entity_name = 'OIE_HEADER_ATTACHMENTS' and docs.pk1_value = aerh.report_header_id) OR
						(docs.entity_name = 'OIE_LINE_ATTACHMENTS' and docs.pk1_value in (select aerl.report_line_id from ap_expense_report_lines_all aerl where aerl.report_header_id = aerh.report_header_id))) and rownum = 1;

	EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_countER :=0;
        END;
	if(l_countER <> 0)
	then
		per_drt_pkg.add_to_results
			  (person_id => l_employeeId
  			  ,entity_type => 'TCA'
			  ,status => 'W'
			  ,msgcode => 'OIE_ATTACH_PERSONAL_DATA'
			  ,msgaplid => 200
			  ,result_tbl => result_tbl);
	end if;
  END oie_hr_drc;
PROCEDURE oie_tca_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type) IS
BEGIN
NULL;
END oie_tca_drc;
PROCEDURE oie_fnd_drc
    (person_id       IN         number
    ,result_tbl    OUT NOCOPY per_drt_pkg.result_tbl_type) IS
BEGIN
NULL;
END oie_fnd_drc;
END ap_web_drt_pkg;

/
