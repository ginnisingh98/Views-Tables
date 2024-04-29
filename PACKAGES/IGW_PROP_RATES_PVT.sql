--------------------------------------------------------
--  DDL for Package IGW_PROP_RATES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_RATES_PVT" AUTHID CURRENT_USER as
-- $Header: igwvprts.pls 115.3 2002/11/15 00:44:39 ashkumar ship $
G_package_name   VARCHAR2(30)    := 'IGW_PROP_RATES_PVT';

procedure PROCESS_PROP_RATES
       (p_init_msg_list                 IN  VARCHAR2   := FND_API.G_TRUE
        ,p_commit                       IN  VARCHAR2   := FND_API.G_FALSE
        ,p_validate_only                IN  VARCHAR2   := FND_API.G_TRUE
	,p_proposal_id		            NUMBER
	,p_version_id		            NUMBER
  	,p_rate_class_id	            NUMBER
        ,p_rate_type_id                     NUMBER
        ,p_fiscal_year                      NUMBER
        ,p_location_code                    VARCHAR2
        ,p_activity_type_code               VARCHAR2
        ,p_start_date                       DATE
        ,p_applicable_rate                  NUMBER
        ,p_institute_rate                   NUMBER
        ,p_rowid                    IN  OUT NOCOPY ROWID
        ,p_record_version_number            NUMBER
        ,x_return_status                OUT NOCOPY VARCHAR2
        ,x_msg_count                    OUT NOCOPY NUMBER
        ,x_msg_data                     OUT NOCOPY VARCHAR2);


END IGW_PROP_RATES_PVT;

 

/
