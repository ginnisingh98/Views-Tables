--------------------------------------------------------
--  DDL for Package PSP_UPGRADE_EFF_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_UPGRADE_EFF_REPORTS" AUTHID CURRENT_USER AS
/*$Header: PSPERUPS.pls 120.0 2005/06/02 15:59:38 appldev noship $*/

 TYPE t_num_15_type IS TABLE OF NUMBER  INDEX BY BINARY_INTEGER;
 TYPE t_date is TABLE of DATE index by BINARY_INTEGER;
 TYPE t_varchar2_30_type is TABLE of VARCHAR2(30) INDEX BY BINARY_INTEGER;
 TYPE t_varchar2_240_type is TABLE of VARCHAR2(240) INDEX BY BINARY_INTEGER;

  type eff_reports_master_type  is record
  (
  effort_report_id  t_num_15_type,
  person_id         t_num_15_type,
  full_name         t_varchar2_240_type,
  approver_name     t_varchar2_240_type,
  start_date        t_date,
  end_date          t_date,
  da_batch          t_varchar2_30_type,
  business_group_name t_varchar2_240_type
  );

 eff_master_rec eff_reports_master_type;

 type eff_element_type is record
(
 element_type_id t_num_15_type
);

 eff_element_rec eff_element_type;


PROCEDURE migrate_eff_Reports(
		       errBuf          	OUT NOCOPY VARCHAR2,
 		       retCode 	    	OUT NOCOPY VARCHAR2,
		       p_diagnostic_mode 	IN	VARCHAR2,
               p_ignore_appr            IN VARCHAR2,
               p_ignore_da         IN VARCHAR2,
		       p_element_set_name 	IN	VARCHAR2
);

END psp_upgrade_eff_reports;

 

/
