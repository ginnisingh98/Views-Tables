--------------------------------------------------------
--  DDL for Package IGW_BUDGET_PERSONNEL_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_BUDGET_PERSONNEL_TBH" AUTHID CURRENT_USER as
--$Header: igwtbpds.pls 115.4 2002/11/14 18:42:24 vmedikon ship $
G_package_name   VARCHAR2(30)    := 'IGW_BUDGET_PERSONNEL_TBH';
  procedure INSERT_ROW (
        p_proposal_id		       NUMBER
	,p_version_id		       NUMBER
        ,p_budget_period_id            NUMBER
        ,p_line_item_id                NUMBER
        ,p_budget_personnel_detail_id  NUMBER
        ,p_person_id                   NUMBER
	,p_party_id		       NUMBER
  	,p_start_date		       DATE
  	,p_end_date		       DATE
        ,p_period_type_code            VARCHAR2
        ,p_appointment_type_code       VARCHAR2
        ,p_salary_requested            NUMBER
        ,p_percent_charged             NUMBER
        ,p_percent_effort              NUMBER
        ,p_cost_sharing_percent        NUMBER
	,p_cost_sharing_amount	       NUMBER
	,p_underrecovery_amount	       NUMBER
        ,x_rowid    	          OUT NOCOPY  VARCHAR2
        ,x_return_status          OUT NOCOPY  VARCHAR2);


----------------------------------------------------------------------
  procedure UPDATE_ROW (
  	p_rowid    	               ROWID
        ,p_proposal_id		       NUMBER
	,p_version_id		       NUMBER
        ,p_budget_period_id            NUMBER
        ,p_line_item_id                NUMBER
        ,p_budget_personnel_detail_id  NUMBER
        ,p_person_id                   NUMBER
	,p_party_id		       NUMBER
  	,p_start_date		       DATE
  	,p_end_date		       DATE
        ,p_period_type_code            VARCHAR2
        ,p_appointment_type_code       VARCHAR2
        ,p_salary_requested            NUMBER
        ,p_percent_charged             NUMBER
        ,p_percent_effort              NUMBER
        ,p_cost_sharing_percent        NUMBER
	,p_cost_sharing_amount	       NUMBER
	,p_underrecovery_amount	       NUMBER
        ,p_record_version_number       NUMBER
        ,x_return_status          OUT NOCOPY  VARCHAR2);
-----------------------------------------------------------------------

procedure DELETE_ROW (
   p_rowid                        IN  ROWID
  ,p_budget_personnel_detail_id       NUMBER
  ,p_proposal_id                  IN  NUMBER
  ,p_version_id                   IN  NUMBER
  ,p_budget_period_id             IN  NUMBER
  ,p_line_item_id                     NUMBER
  ,p_person_id                        NUMBER
  ,p_party_id		              NUMBER
  ,p_record_version_number        IN  NUMBER
  ,x_return_status                OUT NOCOPY VARCHAR2);


END IGW_BUDGET_PERSONNEL_TBH;

 

/
