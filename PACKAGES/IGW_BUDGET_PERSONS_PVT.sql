--------------------------------------------------------
--  DDL for Package IGW_BUDGET_PERSONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_BUDGET_PERSONS_PVT" AUTHID CURRENT_USER as
--$Header: igwvbpss.pls 120.3 2005/10/30 05:50:46 appldev ship $
G_package_name   VARCHAR2(30)    := 'IGW_BUDGET_PERSONS_PVT';

procedure DEFINE_SALARY
       (p_init_msg_list                 IN  VARCHAR2   := FND_API.G_TRUE
        ,p_commit                       IN  VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only                IN  VARCHAR2   := FND_API.G_TRUE
	,p_proposal_id		            NUMBER
	,p_version_id		            NUMBER
  	,p_person_id		            NUMBER
        ,p_party_id			    NUMBER
        ,p_person_name                      VARCHAR2
  	,p_appointment_type_code	    VARCHAR2
        ,p_appointment_type                 VARCHAR2
  	,p_effective_date		    DATE
  	,p_calculation_base  	            NUMBER
        ,x_rowid                        OUT NOCOPY ROWID
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY NUMBER
        ,x_msg_data                     OUT NOCOPY VARCHAR2);


----------------------------------------------------------------------
procedure UPDATE_SALARY
       (p_init_msg_list                 IN  VARCHAR2   := FND_API.G_TRUE
        ,p_commit                       IN  VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only                IN  VARCHAR2   := FND_API.G_TRUE
	,p_proposal_id		            NUMBER
	,p_version_id		            NUMBER
  	,p_person_id		            NUMBER
        ,p_party_id			    NUMBER
        ,p_person_name                      VARCHAR2
  	,p_appointment_type_code	    VARCHAR2
        ,p_appointment_type                 VARCHAR2
  	,p_effective_date		    DATE
  	,p_calculation_base  	            NUMBER
        ,p_record_version_number        IN  NUMBER
        ,p_rowid                        IN  ROWID
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY NUMBER
        ,x_msg_data                     OUT NOCOPY VARCHAR2) ;


-----------------------------------------------------------------------

procedure DELETE_SALARY
       (p_init_msg_list                 IN  VARCHAR2   := FND_API.G_TRUE
        ,p_commit                       IN  VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only                IN  VARCHAR2   := FND_API.G_TRUE
        ,p_proposal_id                  IN  NUMBER
        ,p_version_id                   IN  NUMBER
        ,p_person_id                    IN  NUMBER
        ,p_party_id			    NUMBER
  	,p_appointment_type_code	    VARCHAR2
        ,p_record_version_number        IN  NUMBER
        ,p_rowid                        IN  ROWID
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY NUMBER
        ,x_msg_data                     OUT NOCOPY VARCHAR2);


END IGW_BUDGET_PERSONS_PVT;

 

/
