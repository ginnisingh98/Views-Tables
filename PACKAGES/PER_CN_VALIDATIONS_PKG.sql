--------------------------------------------------------
--  DDL for Package PER_CN_VALIDATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_CN_VALIDATIONS_PKG" AUTHID CURRENT_USER as
/* $Header: percnval.pkh 115.1 2002/11/20 07:20:23 mkandasa noship $ */
--------------------------------------------------------------------------------

/*
+==============================================================================+
|			Copyright (c) 1994 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	National Identifier card number validations.
Purpose
	To validate the National Identifier entered in people form.
History
	23-OCT-02       mkandasa        Created
*/

--------------------------------------------------------------------------------
function validate_national_identifier(
p_national_identifier in  varchar2,
p_dob                 in  date,
p_gender              in  varchar2
)return number;
--------------------------------------------------------------------------------
end PER_CN_VALIDATIONS_PKG;

 

/
