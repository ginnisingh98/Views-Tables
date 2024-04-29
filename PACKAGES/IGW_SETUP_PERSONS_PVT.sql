--------------------------------------------------------
--  DDL for Package IGW_SETUP_PERSONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_SETUP_PERSONS_PVT" AUTHID CURRENT_USER AS
--$Header: igwvspes.pls 115.2 2002/11/15 00:48:46 ashkumar noship $

PROCEDURE CREATE_PERSON
(
p_init_msg_list     		IN VARCHAR2   := Fnd_Api.G_False,
p_validate_only     		IN VARCHAR2   := Fnd_Api.G_False,
p_commit            		IN VARCHAR2   := Fnd_Api.G_False,
p_status			IN VARCHAR2,
p_person_pre_name_adjunct	IN VARCHAR2,
p_person_first_name 		IN VARCHAR2,
p_person_middle_name  		IN VARCHAR2,
p_person_last_name  		IN VARCHAR2,
p_ssn				IN VARCHAR2,
p_date_of_birth			IN DATE,
p_address1          		IN VARCHAR2,
p_address2          		IN VARCHAR2,
p_address3          		IN VARCHAR2,
p_city              		IN VARCHAR2,
p_state             		IN VARCHAR2,
p_postal_code       		IN VARCHAR2,
p_county            		IN VARCHAR2,
p_country_name      		IN VARCHAR2,
p_country_code			IN VARCHAR2,
x_party_id          		OUT NOCOPY NUMBER,
x_return_status     		OUT NOCOPY VARCHAR2,
x_msg_count         		OUT NOCOPY NUMBER,
x_msg_data          		OUT NOCOPY VARCHAR2
);
--------------------------------------------------------------------
PROCEDURE UPDATE_PERSON (
p_init_msg_list     			IN VARCHAR2   := Fnd_Api.G_False,
p_validate_only     			IN VARCHAR2   := Fnd_Api.G_False,
p_commit            			IN VARCHAR2   := Fnd_Api.G_False,
p_party_id				IN NUMBER,
p_location_id  				IN NUMBER,
p_status				IN VARCHAR2,
p_person_pre_name_adjunct		IN VARCHAR2,
p_person_first_name 			IN VARCHAR2,
p_person_middle_name  			IN VARCHAR2,
p_person_last_name  			IN VARCHAR2,
p_ssn					IN VARCHAR2,
p_date_of_birth				IN DATE,
p_address1          			IN VARCHAR2,
p_address2          			IN VARCHAR2,
p_address3          			IN VARCHAR2,
p_city              			IN VARCHAR2,
p_state             			IN VARCHAR2,
p_postal_code       			IN VARCHAR2,
p_county            			IN VARCHAR2,
p_country_name      			IN VARCHAR2,
p_country_code                  	IN VARCHAR2,
p_party_object_version_number   	IN NUMBER,
p_loc_object_version_number		IN NUMBER,
x_return_status     			OUT NOCOPY VARCHAR2,
x_msg_count         			OUT NOCOPY NUMBER,
x_msg_data          			OUT NOCOPY VARCHAR2);
----------------------------------------------------------------------------------------
PROCEDURE GET_COUNTRY_CODE (P_COUNTRY_NAME         IN    	VARCHAR2,
			    X_COUNTRY_CODE	   OUT NOCOPY          VARCHAR2);
----------------------------------------------------------------------------------------
PROCEDURE CHECK_ERRORS;

END IGW_SETUP_PERSONS_PVT;

 

/
