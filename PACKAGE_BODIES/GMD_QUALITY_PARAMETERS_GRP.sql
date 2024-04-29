--------------------------------------------------------
--  DDL for Package Body GMD_QUALITY_PARAMETERS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_QUALITY_PARAMETERS_GRP" AS
/* $Header: GMDGQLPB.pls 120.3.12000000.2 2007/02/07 08:46:00 srakrish ship $ */
-- Start of comments
--+============================================================================+
--|                   Copyright (c) 2005 Oracle Corporation                    |
--|                          Redwood Shores, CA, USA                           |
--|                            All rights reserved.                            |
--+============================================================================+
--| File Name          : GMDGQLPB.pls                                          |
--| Package Name       : GMD_QUALITY_PARAMETERS_GRP                            |
--| Type               : Group                                                 |
--|                                                                            |
--| Notes                                                                      |
--|  This package contains group layer APIs for retrieving quality parameters  |
--|                                                                            |
--| HISTORY                                                                    |
--|    Saikiran Vankadari  14-Feb-2005	Created as part of Convergence.        |
--|                                                                            |
--|    Srakrish	bug 5570258 20-Nov-2006 Created the funtcion sort_by_orgn_code |
--+============================================================================+
-- End of comments


--Start of comments
--+========================================================================+
--| API Name    : get_quality_parameters                                   |
--| TYPE        : Group                                                    |
--| Notes       : This procedure retrieves quality parameters of a         |
--|               particular organization.                                 |
--|									                                       |
--| Parameters :							                               |
--| p_organization_id      Organization ID as input parameter		       |
--| x_quality_parameters   Out Parameter. This record variable contains    |
--|			   values of all parameters of an organization                 |
--| x_return_status        E in case of an exception. Otherwise,S  |
--| x_orgn_found           TRUE if the parameters are present for an       |
--|		     	   organization. Otherwise, FALSE.		                   |
--|								                                    	   |
--| HISTORY                                                                |
--|   Saikiran Vankadari   14-Feb-2005 	 Created.                          |
--|                                                                        |
--+========================================================================+
-- End of comments




PROCEDURE get_quality_parameters
(p_organization_id IN NUMBER,
  x_quality_parameters OUT NOCOPY GMD_QUALITY_CONFIG%ROWTYPE,
  x_return_status  OUT NOCOPY VARCHAR2,
  x_orgn_found OUT NOCOPY BOOLEAN
)
IS

CURSOR cr_get_process_parameters (p_orgn_id NUMBER) IS
SELECT * FROM GMD_QUALITY_CONFIG
WHERE organization_id = p_orgn_id;

BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
x_orgn_found := FALSE;

OPEN cr_get_process_parameters (p_organization_id);

  FETCH cr_get_process_parameters INTO x_quality_parameters;
  IF cr_get_process_parameters%FOUND THEN
  x_orgn_found := TRUE;
ELSE
   x_quality_parameters.exact_spec_match_ind := 'N';
   x_quality_parameters.include_optional_test_rslt_ind := 'Y';
   x_quality_parameters.spec_version_control_ind := 'N';
END IF;
CLOSE cr_get_process_parameters;

EXCEPTION

WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END get_quality_parameters;


--Start of comments
--+========================================================================+
--| API Name    : get_next_sample_no                                       |
--| TYPE        : Group                                                    |
--| Notes       : This function returns the next sample number for a       |
--|               particular organization.                                 |
--|							                                        	   |
--| Parameters :			                            				   |
--| p_organization_id      Organization ID as input parameter   		   |
--|									                                       |
--| HISTORY                                                                |
--|   Saikiran Vankadari   14-Feb-2005 	 Created.                          |
--|                                                                        |
--+========================================================================+
-- End of comments


FUNCTION get_next_sample_no
(p_organization_id IN NUMBER
)
RETURN VARCHAR2
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_sample_no        VARCHAR2(10);
l_last_assigned NUMBER(10);
CURSOR cr_get_sample_seq IS
SELECT
  sample_last_assigned
FROM
  gmd_quality_config
WHERE
  organization_id = p_organization_id;

BEGIN

  -- Update gmd_quality_config
  UPDATE gmd_quality_config
  SET
    sample_last_assigned = sample_last_assigned + 1
  WHERE
    organization_id = p_organization_id;

  -- Now get sample no
  OPEN cr_get_sample_seq;

  FETCH cr_get_sample_seq INTO
    l_last_assigned;

  CLOSE cr_get_sample_seq;

    l_sample_no   := TO_CHAR(l_last_assigned);

  commit;
  RETURN l_sample_no;

END get_next_sample_no;


--Start of comments
--+========================================================================+
--| API Name    : get_next_ss_no                                           |
--| TYPE        : Group                                                    |
--| Notes       : This function returns the next stability study number for|
--|                a particular organization.                              |
--|									                                       |
--| Parameters :						                            	   |
--| p_organization_id      Organization ID as input parameter		       |
--|									                                       |
--| HISTORY                                                                |
--|   Saikiran Vankadari   14-Feb-2005 	 Created.                          |
--|                                                                        |
--+========================================================================+
-- End of comments


FUNCTION get_next_ss_no
(p_organization_id IN NUMBER
)
RETURN VARCHAR2
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_ss_no        VARCHAR2(10);
l_last_assigned NUMBER(10);
CURSOR cr_get_ss_seq IS
SELECT
  ss_last_assigned
FROM
  gmd_quality_config
WHERE
  organization_id = p_organization_id;

BEGIN

  -- Update gmd_quality_config
  UPDATE gmd_quality_config
  SET
    ss_last_assigned = ss_last_assigned + 1
  WHERE
    organization_id = p_organization_id;

  -- Now get ss no
  OPEN cr_get_ss_seq;

  FETCH cr_get_ss_seq INTO
    l_last_assigned;
  CLOSE cr_get_ss_seq;

   l_ss_no   := TO_CHAR(l_last_assigned);

  commit;
  RETURN l_ss_no;

END get_next_ss_no;

--Start of comments
--+========================================================================+
--| API Name    : sort_by_orgn_code                                        |
--| TYPE        : Group                                                    |
--| Notes       : This function is returns teh value based on which the    |
--|		  organizations need to be sorted			   |
--| Parameters :						           |
--| p_organization_id      Organization ID as input parameter		   |
--|									   |
--| HISTORY                                                                |
--|   srakrish   20-Nov-2006 	 Created.       	                   |
--|                                                                        |
--+========================================================================+
-- End of comments

FUNCTION sort_by_orgn_code(p_organization_id in number)
return varchar2 is

l_organization_code varchar2(20);

cursor cr_get_orgn_code(p_organization_id Number) IS
select organization_code
from mtl_parameters
where organization_id = p_organization_id;

begin

open cr_get_orgn_code(p_organization_id);
fetch cr_get_orgn_code INTO l_organization_code;
close cr_get_orgn_code;

return l_organization_code;

end sort_by_orgn_code;

END gmd_quality_parameters_grp;

/
