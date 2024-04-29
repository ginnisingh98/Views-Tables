--------------------------------------------------------
--  DDL for Package IGW_PROP_RATES_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_RATES_TBH" AUTHID CURRENT_USER as
-- $Header: igwtprts.pls 115.3 2002/11/15 00:44:57 ashkumar ship $
G_package_name   VARCHAR2(30)    := 'IGW_PROP_RATES_TBH';
procedure INSERT_ROW (
	p_proposal_id		            NUMBER
	,p_version_id		            NUMBER
  	,p_rate_class_id	            NUMBER
        ,p_rate_type_id                     NUMBER
        ,p_fiscal_year                      VARCHAR2
        ,p_location_code                    VARCHAR2
        ,p_activity_type_code              VARCHAR2
        ,p_start_date                       DATE
        ,p_applicable_rate                  NUMBER
        ,p_institute_rate                   NUMBER
        ,x_rowid    	               OUT NOCOPY  VARCHAR2
        ,x_return_status               OUT NOCOPY  VARCHAR2);


----------------------------------------------------------------------
procedure UPDATE_ROW (
	p_proposal_id		            NUMBER
	,p_version_id		            NUMBER
  	,p_rate_class_id	            NUMBER
        ,p_rate_type_id                     NUMBER
        ,p_fiscal_year                      VARCHAR2
        ,p_location_code                    VARCHAR2
        ,p_activity_type_code              VARCHAR2
        ,p_start_date                       DATE
        ,p_applicable_rate                  NUMBER
        ,p_institute_rate                   NUMBER
        ,p_rowid    	                    VARCHAR2
        ,p_record_version_number            NUMBER
        ,x_return_status               OUT NOCOPY  VARCHAR2);


-----------------------------------------------------------------------

procedure DELETE_ROW (
        p_rowid                          IN ROWID
	,p_proposal_id		            NUMBER
	,p_version_id		            NUMBER
  	,p_rate_class_id	            NUMBER
        ,p_rate_type_id                     NUMBER
        ,p_fiscal_year                      VARCHAR2
        ,p_location_code                    VARCHAR2
        ,p_activity_type_code              VARCHAR2
        ,p_start_date                       DATE
        ,p_applicable_rate                  NUMBER
        ,p_institute_rate                   NUMBER
        ,p_record_version_number        IN  NUMBER
        ,x_return_status                OUT NOCOPY VARCHAR2);


END IGW_PROP_RATES_TBH;

 

/
