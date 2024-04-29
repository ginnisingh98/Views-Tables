--------------------------------------------------------
--  DDL for Package PER_FI_POSTALCODE_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_FI_POSTALCODE_UPLOAD" AUTHID CURRENT_USER AS
/* $Header: pefipost.pkh 120.0 2005/05/31 08:44:53 appldev noship $ */

FUNCTION is_number
(p_value		IN		varchar2
)
return boolean;

PROCEDURE READ_FILE
(errbuf			OUT NOCOPY	VARCHAR2
,retcode		OUT NOCOPY	NUMBER
,p_filename		IN		VARCHAR2
,p_business_group_id	IN		per_business_groups.business_group_id%TYPE
);

PROCEDURE READ_RECORD
( p_line		IN		varchar2
);

PROCEDURE INSERT_ROW
( p_lookup_code 	in		fnd_lookup_values.lookup_code%TYPE
,p_meaning 		in		fnd_lookup_values.meaning%TYPE
,p_description		IN		fnd_lookup_values.description%type
);

PROCEDURE UPDATE_ROW
(p_lookup_code		in		fnd_lookup_values.lookup_code%TYPE
,p_meaning		in		fnd_lookup_values.meaning%TYPE
,p_description		IN		fnd_lookup_values.description%type
);

end PER_FI_POSTALCODE_UPLOAD;

 

/
