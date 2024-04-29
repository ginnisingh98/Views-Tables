--------------------------------------------------------
--  DDL for Package PSP_ROLLBACK_EFF_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ROLLBACK_EFF_REPORTS" AUTHID CURRENT_USER AS
/*$Header: PSPERRBS.pls 120.0.12010000.1 2008/07/28 08:06:23 appldev ship $*/

  TYPE t_num_15_type IS TABLE OF NUMBER  INDEX BY BINARY_INTEGER;

  type eff_reports_master_type  is record
  (
  effort_report_id  t_num_15_type,
  person_id         t_num_15_type
  );

 eff_report_master_rec eff_reports_master_type;

 type eff_report_Details_type is record
  (
 effort_report_detail_id t_num_15_type

  );

eff_report_details_rec eff_report_details_type;

PROCEDURE delete_eff_Reports(
  errBuf          	OUT NOCOPY VARCHAR2,
 		    retCode 	    	OUT NOCOPY VARCHAR2,
		       p_request_id		IN	NUMBER,
		       p_person_id		IN	NUMBER
);

END psp_rollback_eff_reports;

/
