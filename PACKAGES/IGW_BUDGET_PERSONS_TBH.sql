--------------------------------------------------------
--  DDL for Package IGW_BUDGET_PERSONS_TBH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_BUDGET_PERSONS_TBH" AUTHID CURRENT_USER as
-- $Header: igwtbpss.pls 115.4 2002/11/14 18:43:14 vmedikon ship $
G_package_name   VARCHAR2(30)    := 'IGW_BUDGET_PERSONS_TBH';
procedure INSERT_ROW (
	p_proposal_id		            NUMBER
	,p_version_id		            NUMBER
  	,p_person_id		            NUMBER
	,p_party_id			    NUMBER
  	,p_appointment_type_code	    VARCHAR2
  	,p_effective_date		    DATE
  	,p_calculation_base  	            NUMBER
        ,x_rowid    	               OUT NOCOPY  VARCHAR2
        ,x_return_status               OUT NOCOPY  VARCHAR2);


----------------------------------------------------------------------
procedure UPDATE_ROW (
	p_proposal_id		            NUMBER
	,p_version_id		            NUMBER
  	,p_person_id		            NUMBER
	,p_party_id			    NUMBER
  	,p_appointment_type_code	    VARCHAR2
  	,p_effective_date		    DATE
  	,p_calculation_base  	            NUMBER
        ,p_rowid    	                    VARCHAR2
        ,p_record_version_number            NUMBER
        ,x_return_status               OUT NOCOPY  VARCHAR2);


-----------------------------------------------------------------------

procedure DELETE_ROW (
   p_rowid                        IN ROWID
  ,p_proposal_id                  IN NUMBER
  ,p_version_id                   IN NUMBER
  ,p_person_id                    IN NUMBER
  ,p_party_id			     NUMBER
  ,p_record_version_number        IN NUMBER
  ,x_return_status                OUT NOCOPY VARCHAR2);


END IGW_BUDGET_PERSONS_TBH;

 

/
