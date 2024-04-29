--------------------------------------------------------
--  DDL for Package INVPROFL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INVPROFL" AUTHID CURRENT_USER as
/*$Header: INVPROFS.pls 120.1 2005/06/21 04:52:42 appldev ship $ */

procedure inv_pr_get_profile
(
appl_short_name  	IN  VARCHAR2,
profile_name  		IN  VARCHAR2,
user_id  		IN  NUMBER,
resp_appl_id 		IN  NUMBER,
resp_id 		IN  NUMBER,
profile_value 		OUT NOCOPY VARCHAR2,
return_code  		OUT NOCOPY NUMBER,
return_message  	OUT NOCOPY VARCHAR2
);

end INVPROFL;

 

/
