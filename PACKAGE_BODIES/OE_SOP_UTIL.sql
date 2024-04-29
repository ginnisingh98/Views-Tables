--------------------------------------------------------
--  DDL for Package Body OE_SOP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_SOP_UTIL" As
/* $Header: OEXUSOPB.pls 120.0 2005/06/01 02:56:39 appldev noship $ */

FUNCTION GET_RESOURCE_ID RETURN NUMBER
IS

cursor get_current_resource_id(p_userid in number) is
select resource_id
from jtf_rs_resource_extns
where user_id = p_userid;

x_userid number;
x_resource_id number;
x_username varchar2(40);

BEGIN

    x_userid := FND_GLOBAL.USER_ID;
    OPEN get_current_resource_id ( x_userid );

    FETCH get_current_resource_id into x_resource_id;
    if get_current_resource_id%NOTFOUND then
    return (0);
    end if;
    CLOSE get_current_resource_id;

    return (x_resource_id);

END;

FUNCTION GET_PERSON_ID RETURN NUMBER
IS

cursor get_current_person_id(p_userid in number) is
select
     per.person_id
from fnd_user usr,
     per_all_people_f per
where usr.employee_id = per.person_id
and user_id = p_userid;

x_userid number;
x_person_id number;
x_username varchar2(40);

BEGIN

    x_userid := FND_GLOBAL.USER_ID;
    OPEN get_current_person_id ( x_userid );

    FETCH get_current_person_id into x_person_id;
    if get_current_person_id%NOTFOUND then
    return (0);
    end if;
    CLOSE get_current_person_id;

    return (x_person_id);

END;

END OE_SOP_UTIL;

/
