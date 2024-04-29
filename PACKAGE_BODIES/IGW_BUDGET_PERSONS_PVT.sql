--------------------------------------------------------
--  DDL for Package Body IGW_BUDGET_PERSONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_BUDGET_PERSONS_PVT" AS
--$Header: igwvbpsb.pls 120.4 2006/02/22 23:23:51 dsadhukh ship $

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
        ,x_msg_data                     OUT NOCOPY VARCHAR2)IS



BEGIN
 null;

END; --DEFINE SALARY


-----------------------------------------------------------------------------------
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
        ,x_msg_data                     OUT NOCOPY VARCHAR2) IS


BEGIN
   null;

END; --UPDATE SALARY
-------------------------------------------------------------------------------------------

procedure DELETE_SALARY
       (p_init_msg_list                 IN  VARCHAR2   := FND_API.G_TRUE
        ,p_commit                       IN  VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only                IN  VARCHAR2   := FND_API.G_TRUE
        ,p_proposal_id                  IN  NUMBER
        ,p_version_id                   IN  NUMBER
        ,p_person_id                    IN  NUMBER
        ,p_party_id			    NUMBER
  	,p_appointment_type_code	IN  VARCHAR2
        ,p_record_version_number        IN  NUMBER
        ,p_rowid                        IN  ROWID
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY NUMBER
        ,x_msg_data                     OUT NOCOPY VARCHAR2) is


BEGIN
 null;
END; --DELETE BUDGET VERSION

END IGW_BUDGET_PERSONS_PVT;

/
