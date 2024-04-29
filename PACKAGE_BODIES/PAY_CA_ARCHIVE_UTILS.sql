--------------------------------------------------------
--  DDL for Package Body PAY_CA_ARCHIVE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CA_ARCHIVE_UTILS" AS
/* $Header: pycaroep.pkb 120.1 2006/09/15 06:42:51 ydevi noship $ */

--
-- Name 	  : get_archive_value
-- Parameters 	  : p_archive_action_id,p_db_name
-- Return	  : VARCHAR2 - the value of db_name
-- Description	  : This function retrieves the archive value for a given
-- assignment_action_id and user_name used for the ROE paper report
--


FUNCTION get_archive_value(p_archive_action_id number,
			     p_db_name varchar2)
RETURN VARCHAR2 IS
CURSOR csr_get_value(p_archive_action_id NUMBER,p_db_name varchar2) IS
select fai.value
from 	ff_archive_items fai,
	ff_database_items fdi
where fai.context1 = p_archive_action_id
and 	fai.user_entity_id=fdi.user_entity_id
and 	fdi.user_name=p_db_name;

l_value  varchar2(200);

BEGIN

OPEN csr_get_value(p_archive_action_id,p_db_name);
FETCH csr_get_value INTO l_value;

IF csr_get_value%NOTFOUND THEN
	l_value := null;
END IF;

CLOSE csr_get_value;
return(l_value);


EXCEPTION
WHEN NO_DATA_FOUND THEN
CLOSE csr_get_value;
return (null);

WHEN OTHERS THEN
CLOSE csr_get_value;
return (null);

END get_archive_value;


--
-- Name 	  : get_archive_value
-- Parameters 	  : p_asg_action_id,p_context,p_context_name,p_db_name
-- Return	  : VARCHAR2 - the value of db_name
-- Description    : This function retrieves the archive value for a given
--                  assignment_action_id,user_name,context and context_name
--                  used for the T4,T4A and RL1 reports
--

FUNCTION get_archive_value(p_asg_action_id number,
				   p_context varchar2,
				   p_context_name varchar2,
			         p_db_name varchar2)
RETURN VARCHAR2 IS
CURSOR csr_get_value(p_asg_act_id NUMBER,p_context varchar2,p_context_name varchar2,
				p_db_name varchar2) IS
select fai.value
from 	ff_archive_items 	fai,
	ff_database_items fdi,
	ff_archive_item_contexts fac,
      ff_contexts		ffc
where fai.context1  =  p_asg_act_id
and   fai.archive_item_id = fac.archive_item_id
and   fai.user_entity_id  = fdi.user_entity_id
and 	fdi.user_name = p_db_name
and   fac.context   = p_context
and   fac.context_id = ffc.context_id
and   ffc.context_name = p_context_name;

l_value  varchar2(200);

BEGIN

OPEN csr_get_value(p_asg_action_id,p_context,p_context_name,p_db_name);
FETCH csr_get_value INTO l_value;

IF csr_get_value%NOTFOUND THEN
	l_value := null;
END IF;
CLOSE csr_get_value;

return(l_value);


EXCEPTION
WHEN NO_DATA_FOUND THEN
CLOSE csr_get_value;
return (null);
WHEN OTHERS THEN
CLOSE csr_get_value;
return (null);

END get_archive_value;


END pay_ca_archive_utils;

/
