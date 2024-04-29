--------------------------------------------------------
--  DDL for Package PER_NO_POSTALCODE_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_NO_POSTALCODE_UPLOAD" AUTHID CURRENT_USER AS
/* $Header: penopost.pkh 120.0 2005/05/31 11:57 appldev noship $ */

-- Procedure to upload postal code lookup
PROCEDURE upload(errbuf			OUT NOCOPY   VARCHAR2,
                 retcode		OUT NOCOPY   NUMBER,
		 p_file_name		IN           VARCHAR2,
		 p_business_group_id    IN           per_business_groups.business_group_id%TYPE);

-- Procedure to read lines from file and insert to /update the lookup.
PROCEDURE read_record
         ( p_line  IN varchar2);

-- Procedure to insert a row into fnd_lookup_values table
PROCEDURE insert_row
         ( p_lookup_code  IN fnd_lookup_values.lookup_code%type,
	   p_meaning      IN fnd_lookup_values.meaning%type,
	   p_description  IN fnd_lookup_values.description%type);

-- Procedure to update a row in fnd_lookup_values table
PROCEDURE update_row
         ( p_lookup_code  IN fnd_lookup_values.lookup_code%type,
	   p_meaning      IN fnd_lookup_values.meaning%type,
	   p_description  IN fnd_lookup_values.description%type);

end PER_NO_POSTALCODE_UPLOAD;


 

/
