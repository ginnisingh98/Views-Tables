--------------------------------------------------------
--  DDL for Package ECX_DOCUMENT_STANDARDS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_DOCUMENT_STANDARDS_API" AUTHID CURRENT_USER AS
-- $Header: ECXSTDAS.pls 120.2 2005/06/30 11:17:59 appldev ship $

/**
This Retrieve_Standard API is used to retrieve an existing XML standard definition from the ECX_Standards table.
**/
procedure retrieve_standard
	(
	x_return_status	 	Out	 nocopy pls_integer,
	x_msg	 		Out	 nocopy Varchar2,
	x_standard_id	 	Out	 nocopy pls_integer,
	p_standard_code	 	In	 Varchar2,
	x_standard_type	 	In Out	 nocopy Varchar2,
	x_standard_desc	 	Out	 nocopy Varchar2,
	x_data_seeded	 	Out	 nocopy Varchar2
	);

/**
This Create_Standard API is used to create a new XML standard definition in the ECX_Standards table.
**/
procedure create_standard
	(
 	x_return_status	 	Out	 nocopy pls_integer,
  	x_msg	 		Out	 nocopy Varchar2,
   	x_standard_id	 	Out	 nocopy pls_integer,
    	p_standard_code	 	In	 Varchar2,
     	p_standard_type	 	In	 Varchar2,
      	p_standard_desc	 	In	 Varchar2,
       	p_data_seeded	 	In	 Varchar2 default 'N',
        p_owner                 In       varchar2 default 'CUSTOM'
	);
/**
Update_Standards API is used to update an existing XML Standard definition in the ECX_Standards table.
This API allows users to update the description and data seeded fields by specifying standard id
**/
procedure update_standard
	(
 	x_return_status	 	Out	 nocopy pls_integer,
  	x_msg	 		Out	 nocopy Varchar2,
   	p_standard_id	 	In	 pls_integer,
    	p_standard_desc	 	In	 Varchar2,
     	p_data_seeded	 	In	 Varchar2 default 'N',
        p_owner                 In       varchar2 default 'CUSTOM'
	);

/**
Delete_XML_Standard API is used to delete an existing XML Standard definition in the ECX_STANDARDS
table and its attributes.  This API allows users to delete the definitions by specifying the standard id.
**/
procedure delete_standard
	(
      	x_return_status	 	Out	 nocopy pls_integer,
       	x_msg	 		Out	 nocopy Varchar2,
	p_standard_id	 	In	 pls_integer
	);

END ECX_DOCUMENT_STANDARDS_API;

 

/
