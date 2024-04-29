--------------------------------------------------------
--  DDL for Package Body PAY_DEL_PERSON_FORM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DEL_PERSON_FORM" as
/* $Header: pyded01t.pkb 115.1 99/07/17 05:56:40 porting ship $ */
/*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +===========================================================================*/
--
/*---------------------------------------------------------------------------
Description
-----------


History
-------
Date       Author    Version
---------  -------   -------   --------------------------------------
18-Apr-94  JRhodes   40.1      Made use of FND_INSTALLATION procedure
23-Nov-94  RFine     40.4      Suppressed index on business_group_id
03-Jun-97  VTreiger  40.7      Changed parameters in call to
                               fnd_installation.get in procedure
                               delete_validation to be in sync with the
                               latest version of FND_INSTALLATION package
                               for function GET. Bug #494239.
24-Feb-99 J. Moyano 115.1      MLS changes. Reference to per_person_types_tl
                               base table added to cursor c2.
---------------------------------------------------------------------------*/
procedure get_displayed_values(p_business_group_id NUMBER
                              ,p_title VARCHAR2
                              ,p_title_meaning IN OUT VARCHAR2
                              ,p_person_type_id NUMBER
                              ,p_user_person_type IN OUT VARCHAR2) is
--
cursor c1 is
  select meaning
  from   hr_lookups
  where  lookup_type = 'TITLE'
  and    lookup_code = p_title;
--
cursor c2 is
  select  type_tl.user_person_type
  from    per_person_types_tl TYPE_TL,
          per_person_types TYPE
  where   type_tl.person_type_id          = type.person_type_id
  and     type.business_group_id + 0      = p_business_group_id
  and     type.person_type_id             = p_person_type_id
  and     userenv('LANG')                 = type_tl.language;
--
begin
hr_utility.set_location('pay_del_person_form.get_displayed_values',1);
   open c1;
   fetch c1 into p_title_meaning;
   close c1;
--
   open c2;
   fetch c2 into p_user_person_type;
   close c2;
--
end get_displayed_values;
--
--
procedure delete_validation(p_person_id NUMBER
                           ,p_session_date DATE) is
--
function product_installed(l_appl_id NUMBER) return BOOLEAN is
l_status varchar2(1);
l_industry varchar2(1);
l_ret boolean;
begin
hr_utility.set_location('pay_del_person_form.product_installed',1);
   -- VT #494239 06/03/97
   -- l_ret := fnd_installation.get(appl_id => l_appl_id
   --                         ,dep_appl_id => null
   --                         ,status => l_status
   --                         ,industry => l_industry);
   l_ret := fnd_installation.get(appl_id => null
                            ,dep_appl_id => l_appl_id
                            ,status => l_status
                            ,industry => l_industry);
   --
   return(l_status = 'I');
end product_installed;
--
begin
--
hr_utility.set_location('pay_del_person_form.delete_validation',1);
  hr_person.weak_predel_validation(p_person_id
                                  ,p_session_date);
  --
  -- 'SQLAP'
  if product_installed(200) then
     ap_person.ap_predel_validation(p_person_id);
  end if;
  -- 'ENG'
  if product_installed(703) then
     eng_person.eng_predel_validation(p_person_id);
  end if;
  -- 'OFA'
  if product_installed(140) then
     fa_person.fa_predel_validation(p_person_id);
  end if;
  -- 'PA'
  if product_installed(275) then
     pa_person.pa_predel_validation(p_person_id);
  end if;
  -- 'PO'
  if product_installed(201) then
     po_person.po_predel_validation(p_person_id);
  end if;
  -- 'WIP'
  if product_installed(706) then
     wip_person.wip_predel_validation(p_person_id);
  end if;
--
end delete_validation;
--
--
END PAY_DEL_PERSON_FORM;

/
