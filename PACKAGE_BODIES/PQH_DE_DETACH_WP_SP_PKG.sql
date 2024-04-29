--------------------------------------------------------
--  DDL for Package Body PQH_DE_DETACH_WP_SP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQH_DE_DETACH_WP_SP_PKG" as
/* $Header: pqhdedsp.pkb 115.0 2002/04/03 02:32:08 pkm ship        $ */

PROCEDURE DELETE_STELLEN_PLAN(pWrkplc_id IN NUMBER ,pStellen_Plan_id IN NUMBER) is

-- cursor to find stellens attached to workplace

cursor extra_info_id(Wid Number, Sid Number) is
select
position_extra_info_id
,object_version_number
from per_position_extra_info
where information_type='DE_PQH_WRKPLC_STELLE_LINK'
and position_id=Wid
and to_number(poei_information3)=Sid;

-- cursor to a find stellens in stellen plan item

cursor stelle_in_plan(SpId number) is
select
position_id
from hr_all_positions_f
where
       information1='ST'
and    to_number(information6)=SpId;


begin

FOR C1 in stelle_in_plan(pStellen_Plan_id)
LOOP
  FOR C2 in extra_info_id(pWrkplc_id, C1.position_id)
  LOOP
   hr_position_extra_info_api.delete_position_extra_info
    (
     p_position_extra_info_id => C2. position_extra_info_id
    ,p_object_version_number=>C2.object_version_number
    );
  End Loop;
End Loop;
end DELETE_STELLEN_PLAN;
END PQH_DE_DETACH_WP_SP_PKG;

/
