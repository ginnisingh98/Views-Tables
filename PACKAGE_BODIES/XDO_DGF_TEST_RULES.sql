--------------------------------------------------------
--  DDL for Package Body XDO_DGF_TEST_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XDO_DGF_TEST_RULES" AS
/* $Header: XDODGFTRB.pls 120.0 2008/01/19 00:14:21 bgkim noship $ */

-------------------------------------
--is_enough_days
-------------------------------------
FUNCTION is_enough_days
     ( p_start_date     IN  VARCHAR2,
       p_end_date       IN  VARCHAR2,
       p_format_mask    IN  VARCHAR2,
       p_number_of_days IN  VARCHAR2 := '30')
RETURN  VARCHAR2
IS

 l_format_mask   VARCHAR2(20);

BEGIN

 -- l_format_mast
 l_format_mask := fnd_profile.value('ICX_DATE_FORMAT');

 IF l_format_mask  IS NULL THEN
    l_format_mask := p_format_mask;
 END IF;

 IF to_date(p_end_date, l_format_mask) - to_date(p_start_date, l_format_mask)
     >= to_number(p_number_of_days) THEN
    return 'Y';
 ELSE
   return 'N';
 END IF;
END;

-------------------------------------
--  get_days
-------------------------------------
FUNCTION get_days
     ( p_start_date  in varchar2,
       p_end_date    in varchar2,
       p_format_mask in varchar2
       )
RETURN  number
IS
 l_format_mask   VARCHAR2(20);
BEGIN
 -- l_format_mast
 l_format_mask := fnd_profile.value('ICX_DATE_FORMAT');

 IF l_format_mask  IS NULL THEN
    l_format_mask := p_format_mask;
 END IF;

 RETURN to_date(p_end_date,l_format_mask) - to_date(p_start_date,l_format_mask);
END;


-------------------------------------
-- is_working_hours
-------------------------------------
function is_working_hours return varchar2
is
begin
 if to_number(to_char(sysdate,'HH24')) between 8 and 16
 then return 'Y';
 else return 'N';
 end if;
end;

END xdo_dgf_test_rules;

/
