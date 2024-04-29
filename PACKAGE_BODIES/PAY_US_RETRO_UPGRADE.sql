--------------------------------------------------------
--  DDL for Package Body PAY_US_RETRO_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_RETRO_UPGRADE" AS
/* $Header: payusretroupg.pkb 120.1.12010000.2 2008/08/06 06:40:46 ubhat ship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1992 Oracle Corporation UK Ltd.,                *
   *                   Chertsey, England.                           *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation UK Ltd,  *
   *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
   *  England.                                                      *
   *                                                                *
   ******************************************************************

   Name        : pay_us_retro_upgrade

   Description : This procedure is used to upgrade elements for
                 Enhanced Retropay.

   Change List
   -----------
   Date        Name       Vers   Bug No   Description
   ----------- ---------- ------ ------- -----------------------------------
   05-DEC-2004 ahanda     115.0          Intial Version
   10-DEC-2004 ahanda     115.1          Fixed dbdrv issue.
   19-DEC-2004 fusman     115.2          Added code to insert legislation rules.
   29-APR-2005 mmukherj   115.3          Removed hard coded legislation_code
                                         'US' from the package.The
                                         legislation_code are taken from the
                                         legislation_code attached to the
                                         elements,if it is a seeded element or
                                         from the legislation_code
                                         of the Business Group for the elements,
                                         if it is an user defined element.
   21-SEP-2005 ahanda     115.3          Changed the insertion of legislation
                                         rules. Data is inserted if it does not
                                         exist.
   06-06-2008  svannian   115.4          to avoid unique constraint voilation
                                         error when upgradation is ran for the second time.
*/

 gv_package_name       VARCHAR2(100);
 gn_time_span_id       NUMBER;
 gn_retro_component_id NUMBER;

 PROCEDURE insert_retro_comp_usages
                  (p_business_group_id    in        number,
                   p_legislation_code     in        varchar2,
                   p_retro_component_id   in        number,
                   p_creator_id           in        number,
                   p_retro_comp_usage_id out nocopy number)
 IS

   ln_retro_component_usage_id NUMBER;
   lv_procedure_name           VARCHAR2(100);

 BEGIN
   lv_procedure_name := '.insert_retro_comp_usages';
   hr_utility.trace('Entering ' || gv_package_name || lv_procedure_name);

   select pay_retro_component_usages_s.nextval
     into ln_retro_component_usage_id
     from dual;

   insert into pay_retro_component_usages
   (retro_component_usage_id, retro_component_id, creator_id, creator_type,
    default_component, reprocess_type, business_group_id, legislation_code,
    creation_date, created_by, last_update_date, last_updated_by,
    last_update_login, object_version_number)
    select ln_retro_component_usage_id, p_retro_component_id, p_creator_id,
    'ET', 'Y', 'R', p_business_group_id, p_legislation_code,
    sysdate, 2, sysdate, 2, 2, 1
    from dual
    WHERE NOT EXISTS ( SELECT 1 FROM pay_retro_component_usages
    WHERE retro_component_id = p_retro_component_id
    AND creator_id = p_creator_id
    AND creator_type = 'ET'); /* 7138282 */

   p_retro_comp_usage_id := ln_retro_component_usage_id;
   hr_utility.trace('p_retro_comp_usage_id= ' || p_retro_comp_usage_id);
   hr_utility.trace('Leaving ' || gv_package_name || lv_procedure_name);

   exception
     when others then
       hr_utility.set_location(gv_package_name || lv_procedure_name, 200);
       hr_utility.trace('ERROR:' || sqlcode ||'-'|| substr(sqlerrm,1,80));
       raise;
 END insert_retro_comp_usages;


 PROCEDURE insert_element_span_usages
                  (p_business_group_id     in number,
                   p_retro_element_type_id in number,
                   p_legislation_code      in varchar2,
                   p_time_span_id          in number,
                   p_retro_comp_usage_id   in  number)
 IS

   lv_procedure_name           VARCHAR2(100);

 BEGIN
   lv_procedure_name := '.insert_element_span_usages';
   hr_utility.trace('Entering ' || gv_package_name || lv_procedure_name);

   hr_utility.trace('p_business_group_id     ='|| p_business_group_id);
--   hr_utility.trace('p_legcd     ='|| p_legislation_code);
   hr_utility.trace('p_time_span_id     ='|| p_time_span_id);
   hr_utility.trace('p_retro_comp_usage_id     ='|| p_retro_comp_usage_id);
   hr_utility.trace('p_retro_element_type_id     ='|| p_retro_element_type_id);

   insert into pay_element_span_usages
   (element_span_usage_id, business_group_id, time_span_id,
    retro_component_usage_id, retro_element_type_id,
    creation_date, created_by, last_update_date, last_updated_by,
    last_update_login, object_version_number)
    select pay_element_span_usages_s.nextval, p_business_group_id, p_time_span_id,
    p_retro_comp_usage_id, p_retro_element_type_id,
    sysdate, 2, sysdate, 2, 2, 1
    from dual
    WHERE not exists ( SELECT 1 FROM pay_element_span_usages pesu
                       WHERE pesu.business_group_id = p_business_group_id
                       AND   pesu.legislation_code IS NULL
                       AND   pesu.time_span_id = p_time_span_id
                       AND   retro_component_usage_id = p_retro_comp_usage_id); /* 7138282 */

   hr_utility.trace('Leaving ' || gv_package_name || lv_procedure_name);

   exception
     when others then
       hr_utility.set_location(gv_package_name || lv_procedure_name, 200);
       hr_utility.trace('ERROR:' || sqlcode ||'-'|| substr(sqlerrm,1,80));
       raise;
 END insert_element_span_usages;


 /****************************************************************************
 ** Name       : qualify_element
 **
 ** Description: This is the qualifying procedure which determines whether
 **              the element passed in as a parameter needs to be migrated.
 **                The conditions that are checked here are
 **                1. Element is part of a Retro Set used for Retro
 **
 ****************************************************************************/
 PROCEDURE qualify_element(p_object_id  in        varchar2
                          ,p_qualified out nocopy varchar2)
 IS
   cursor c_element_class(cp_element_type_id in number) is
      select classification_id, element_name, legislation_code, business_group_id
        from pay_element_types_f
       where element_type_id = cp_element_type_id;

   cursor c_legislation_code(cp_business_group_id in number) is
     select legislation_code
     from per_business_groups
     where business_group_id = cp_business_group_id;

   cursor c_element_set(cp_element_type_id   in number
                       ,cp_classification_id in number
                       ,cp_legislation_code in varchar2) is
     select petr.element_set_id
       from pay_element_type_rules petr
      where petr.element_type_id = cp_element_type_id
        and petr.include_or_exclude = 'I'
     union all
     select pes.element_set_id
       from pay_ele_classification_rules pecr,
            pay_element_types_f pet,
            pay_element_sets pes
      where pet.classification_id = pecr.classification_id
        and pes.element_set_id = pecr.element_set_id
        and (pes.business_group_id = pet.business_group_id
             or pet.legislation_code = cp_legislation_code)
        and pet.element_type_id = cp_element_type_id
        and pecr.classification_id = cp_classification_id
     minus
     select petr.element_set_id
       from pay_element_type_rules petr
      where petr.element_type_id = cp_element_type_id
        and petr.include_or_exclude = 'E';

   cursor c_element_check(cp_element_set_id in number) is
     select 1
       from pay_payroll_actions ppa
      where ppa.action_type = 'L'
        and ppa.element_set_id = cp_element_set_id;

   cursor c_retro_rule_check(cp_rule_type in varchar2
                            ,cp_legislation_code in Varchar2) is
     select 'Y'
       from pay_legislation_rules
      where legislation_code = cp_legislation_code
        and rule_type = cp_rule_type;

   ln_classification_id NUMBER;
   ln_business_group_id NUMBER;
   ln_element_set_id    NUMBER;
   ln_element_used      NUMBER;
   lv_qualified         VARCHAR2(1);
   lv_element_name      VARCHAR2(100);
   lv_procedure_name    VARCHAR2(100);
   lv_legislation_code         VARCHAR2(150);
   ln_exists            VARCHAR2(1);

   TYPE character_data_table IS TABLE OF VARCHAR2(280)
                               INDEX BY BINARY_INTEGER;

   ltt_rule_type       character_data_table;
   ltt_rule_mode       character_data_table;


 BEGIN

   lv_procedure_name := '.qualify_element';
   hr_utility.trace('Entering ' || gv_package_name || lv_procedure_name);
   lv_qualified := 'N';
   lv_legislation_code  := null;
   ln_business_group_id := null;
   ln_classification_id := null;
   lv_element_name      := null;

   open c_element_class(p_object_id);
   fetch c_element_class into ln_classification_id,
                              lv_element_name,
                              lv_legislation_code,
                              ln_business_group_id;
   close c_element_class;

   if lv_legislation_code is null and
      ln_business_group_id is not null then
      open c_legislation_code(ln_business_group_id);
      FETCH c_legislation_code into lv_legislation_code;
      close c_legislation_code;
   end if;

   ltt_rule_type(1) := 'RETRO_DELETE';
   ltt_rule_mode(1) := 'N';
   ltt_rule_type(2) := 'ADVANCED_RETRO';
   ltt_rule_mode(2) := 'Y';
   ltt_rule_type(3) := 'ADJUSTMENT_EE_SOURCE';
   ltt_rule_mode(3) := 'T';

   FOR i in 1 ..3 LOOP
       OPEN c_retro_rule_check(ltt_rule_type(i),lv_legislation_code) ;
       FETCH c_retro_rule_check into ln_exists;
       IF c_retro_rule_check%NOTFOUND THEN
          INSERT INTO pay_legislation_rules
          (legislation_code, rule_type, rule_mode) VALUES
          (lv_legislation_code, ltt_rule_type(i), ltt_rule_mode(i));
       END IF;
       CLOSE c_retro_rule_check;
   END LOOP;

   open c_element_set(p_object_id
                     ,ln_classification_id
                     ,lv_legislation_code);
   loop
      fetch c_element_set into ln_element_set_id;
      if c_element_set%notfound then
         exit;
      end if;

      hr_utility.trace('Element Set ID ' || ln_element_set_id);
      open c_element_check(ln_element_set_id);
      fetch c_element_check into ln_element_used;
      if c_element_check%found then
         lv_qualified := 'Y';
         hr_utility.trace('UPGRADE Element ' || lv_element_name ||
                          '(' || p_object_id || ')');
         exit;
      else
         lv_qualified := 'N';
         hr_utility.trace('Element ' || lv_element_name ||
                          '(' || p_object_id || ') does not need to be upgraded');
      end if;
      close c_element_check;
   end loop;
   close c_element_set;

   p_qualified := lv_qualified;
   hr_utility.trace('Leaving ' || gv_package_name || lv_procedure_name);

   exception
     when others then
       hr_utility.set_location(gv_package_name || lv_procedure_name, 200);
       hr_utility.trace('ERROR:' || sqlcode ||'-'|| substr(sqlerrm,1,80));
       raise;
 END qualify_element;


 PROCEDURE upgrade_element(p_element_type_id in number)
 IS
   cursor c_element_dtl(cp_element_type_id in number) is
     select business_group_id, legislation_code, classification_id,
            nvl(retro_summ_ele_id, pet.element_type_id),
            element_name
       from pay_element_types_f pet
      where pet.element_type_id = cp_element_type_id
    order by pet.effective_start_date desc;

   cursor c_legislation_code(cp_business_group_id in number) is
     select legislation_code
     from per_business_groups
     where business_group_id = cp_business_group_id;

   cursor c_element_set(cp_element_type_id   in number
                       ,cp_classification_id in number
                       ,cp_legislation_code in varchar2) is
     select petr.element_set_id
       from pay_element_type_rules petr
      where petr.element_type_id = cp_element_type_id
        and petr.include_or_exclude = 'I'
     union all
     select pes.element_set_id
       from pay_ele_classification_rules pecr,
            pay_element_types_f pet,
            pay_element_sets pes
      where pet.classification_id = pecr.classification_id
        and pes.element_set_id = pecr.element_set_id
        and (pes.business_group_id = pet.business_group_id
             or pet.legislation_code = cp_legislation_code)
        and pet.element_type_id = cp_element_type_id
        and pecr.classification_id = cp_classification_id
     minus
     select petr.element_set_id
       from pay_element_type_rules petr
      where petr.element_type_id = cp_element_type_id
        and petr.include_or_exclude = 'E';

   cursor c_get_business_group(cp_element_set_id in number
                               ,cp_legislation_code in varchar2) is
     select hoi.organization_id
       from hr_organization_information hoi,
            hr_organization_information hoi2
     where hoi.org_information_context = 'CLASS'
       and hoi.org_information1 = 'HR_BG'
       and hoi.organization_id = hoi2.organization_id
       and hoi2.org_information_context = 'Business Group Information'
       and hoi2.org_information9 = cp_legislation_code
       and exists (select 1 from pay_payroll_actions ppa
                    where ppa.business_group_id = hoi.organization_id
                      and ppa.action_type = 'L'
                      and ppa.element_set_id = cp_element_set_id
                      );

   cursor c_retro_info(cp_legislation_code in varchar2) is
     select retro_component_id, pts.time_span_id
       from pay_retro_components prc,
            pay_time_spans pts
      where pts.creator_id = prc.retro_component_id
        and prc.legislation_code = cp_legislation_code
       and prc.short_name = 'Retropay';

   ln_ele_business_group_id NUMBER;
   ln_business_group_id     NUMBER;
   ln_classification_id     NUMBER;
   ln_legislation_code      VARCHAR2(10);
   lv_legislation_code      VARCHAR2(10);
   ln_element_set_id        NUMBER;
   ln_retro_element_type_id NUMBER;
   ln_retro_comp_usage_id   NUMBER;
   ln_count                 NUMBER;
   lv_element_name          VARCHAR2(100);
   lv_procedure_name        VARCHAR2(100);

   TYPE numeric_data_table IS TABLE OF NUMBER
                   INDEX BY BINARY_INTEGER;

   ltt_business_group numeric_data_table;
 BEGIN
   lv_procedure_name := '.upgrade_element';
   hr_utility.trace('Entering ' || gv_package_name || lv_procedure_name);

   hr_utility.set_location(gv_package_name || lv_procedure_name, 30);
   open c_element_dtl(p_element_type_id);
   fetch c_element_dtl into ln_ele_business_group_id, ln_legislation_code,
                            ln_classification_id, ln_retro_element_type_id,
                            lv_element_name;
   close c_element_dtl;
   hr_utility.trace('p_element_type_id     ='|| p_element_type_id);
   hr_utility.trace('lv_element_name       ='|| lv_element_name);
   hr_utility.trace('ln_legislation_code      ='|| ln_legislation_code);
   hr_utility.trace('ln_ele_business_group_id ='|| ln_ele_business_group_id);
   hr_utility.trace('ln_retro_element_type_id ='|| ln_retro_element_type_id);

   if ln_legislation_code is null and
      ln_ele_business_group_id is not null then
      open c_legislation_code(ln_ele_business_group_id);
      FETCH c_legislation_code into lv_legislation_code;
      close c_legislation_code;
   else
    lv_legislation_code := ln_legislation_code;
   end if;
   hr_utility.trace('lv_legislation_code      ='|| lv_legislation_code);

   if gn_retro_component_id is null then
   hr_utility.trace('getting gn_retro_component_id ='|| gn_retro_component_id);
      hr_utility.set_location(gv_package_name || lv_procedure_name, 20);
      open c_retro_info(lv_legislation_code);
      fetch c_retro_info into gn_retro_component_id
                             ,gn_time_span_id;
      close c_retro_info;
   end if;
   hr_utility.trace('gn_retro_component_id ='|| gn_retro_component_id);
   hr_utility.trace('gn_time_span_id       ='|| gn_time_span_id);

   hr_utility.set_location(gv_package_name || lv_procedure_name, 40);

   if ln_legislation_code is not null and
      ln_ele_business_group_id is null then

      hr_utility.trace('Seeded Element');
      hr_utility.set_location(gv_package_name || lv_procedure_name, 60);
      insert_retro_comp_usages
                  (p_business_group_id   => null
                  ,p_legislation_code    => ln_legislation_code
                  ,p_retro_component_id  => gn_retro_component_id
                  ,p_creator_id          => p_element_type_id
                  ,p_retro_comp_usage_id => ln_retro_comp_usage_id);

      hr_utility.set_location(gv_package_name || lv_procedure_name, 70);
      open c_element_set(p_element_type_id, ln_classification_id,ln_legislation_code);
      loop
         fetch c_element_set into ln_element_set_id;
         if c_element_set%notfound then
      hr_utility.set_location(gv_package_name || lv_procedure_name, 99999);
            exit;
         end if;

         open c_get_business_group(ln_element_set_id,ln_legislation_code);
         loop
            fetch c_get_business_group into ln_business_group_id;
            if c_get_business_group%notfound then
      hr_utility.set_location(gv_package_name || lv_procedure_name, 8888);
               exit;
            end if;

--            ln_count := ltt_business_group.count;
--            ltt_business_group(ln_count) := ln_business_group_id;

            hr_utility.trace('ln_business_group_id ='|| ln_business_group_id);
            hr_utility.set_location(gv_package_name || lv_procedure_name, 80);

            insert_element_span_usages
               (p_business_group_id   => ln_business_group_id
               ,p_retro_element_type_id => ln_retro_element_type_id
               ,p_legislation_code    => ln_legislation_code
               ,p_time_span_id        => gn_time_span_id
               ,p_retro_comp_usage_id => ln_retro_comp_usage_id);

            hr_utility.set_location(gv_package_name || lv_procedure_name, 90);
         end loop;
         close c_get_business_group;
      end loop;
      close c_element_set;
   end if;
   hr_utility.set_location(gv_package_name || lv_procedure_name, 100);

   if ln_legislation_code is null and
      ln_ele_business_group_id is not null then

      hr_utility.trace('Custom Element');
      hr_utility.set_location(gv_package_name || lv_procedure_name, 110);
      insert_retro_comp_usages
                  (p_business_group_id   => ln_ele_business_group_id
                  ,p_legislation_code    => null
                  ,p_retro_component_id  => gn_retro_component_id
                  ,p_creator_id          => p_element_type_id
                  ,p_retro_comp_usage_id => ln_retro_comp_usage_id);
      hr_utility.set_location(gv_package_name || lv_procedure_name, 120);
      insert_element_span_usages
                  (p_business_group_id   => ln_ele_business_group_id
                  ,p_retro_element_type_id => ln_retro_element_type_id
                  ,p_legislation_code    => null
                  ,p_time_span_id        => gn_time_span_id
                  ,p_retro_comp_usage_id => ln_retro_comp_usage_id);
   end if;

   hr_utility.trace('Leaving ' || gv_package_name || lv_procedure_name);
   exception
     when others then
       hr_utility.set_location(gv_package_name || lv_procedure_name, 200);
       hr_utility.trace('ERROR:' || sqlcode ||'-'|| substr(sqlerrm,1,80));
       raise;
 END upgrade_element;

BEGIN
-- hr_utility.trace_on(null, 'US_RETRO_UPG');
 gv_package_name := 'pay_us_retro_upgrade';

END pay_us_retro_upgrade;

/
