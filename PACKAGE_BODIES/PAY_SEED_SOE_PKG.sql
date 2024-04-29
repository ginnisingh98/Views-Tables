--------------------------------------------------------
--  DDL for Package Body PAY_SEED_SOE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SEED_SOE_PKG" AS
/* $Header: paysesoe.pkb 120.0 2005/05/29 02:42 appldev noship $ */

PROCEDURE update_profile(
                       errbuf                   out NOCOPY varchar2
                      ,retcode                  out NOCOPY varchar2
                      ,p_business_group_id      in  varchar2
                      ,p_action                 in  varchar2) IS

    cursor get_legislation_code is
    select legislation_code
    from   per_business_groups
    where  business_group_id = p_business_group_id;

    cursor get_profile(p_leg_code IN varchar2)  is
    select decode(rule_mode,'Y','ENABLE','DISABLE')
    from   pay_legislative_field_info
    where  legislation_code = p_leg_code
    and    field_name = 'ONLINE_SOE'
    and    rule_type  = 'DISPLAY';

    l_leg_code      varchar2(50);
    l_rule_mode     varchar2(50);

BEGIN
      OPEN  get_legislation_code;
      FETCH get_legislation_code into l_leg_code;
      CLOSE get_legislation_code;

      OPEN  get_profile(l_leg_code);
      FETCH get_profile into l_rule_mode;

      IF get_profile%FOUND THEN
         IF l_rule_mode <> p_action THEN
            update pay_legislative_field_info
            set    rule_mode = decode(p_action,'ENABLE','Y','N')
            where  legislation_code = l_leg_code
            and    field_name = 'ONLINE_SOE'
            and    rule_type  = 'DISPLAY';
         END IF;
      ELSE
         insert into pay_legislative_field_info(field_name, legislation_code,rule_type,rule_mode)
         select 'ONLINE_SOE',
                l_leg_code,
                'DISPLAY',
                decode(p_action,'ENABLE','Y','N')
         from   dual;

      END IF;

      CLOSE get_profile;

END update_profile;

END;

/
