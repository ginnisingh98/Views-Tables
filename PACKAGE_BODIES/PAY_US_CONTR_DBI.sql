--------------------------------------------------------
--  DDL for Package Body PAY_US_CONTR_DBI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_CONTR_DBI" as
/* $Header: pyuscont.pkb 120.0 2005/05/29 09:19:34 appldev noship $ */
/*
--
-- Copyright (c) Oracle Corporation 1991, 1992, 1993. All rights reserved.
--
/*
   NAME
      pyuscont.pkb
--
   DESCRIPTION
   Procedures required to create the startup data for US Benefit Contribution
   Database Items, and procedures required to create the Database Items
   Dynamically on creation of Input Values.
   --
   These procedures create the following objects
   --
   Routes
   ------
   US_CONTRIBUTION_VALUES
   --
   Database Items
   --------------
   <ENTITY_NAME>_BEN_EE_CONTR_VALUE
   <ENTITY_NAME>_BEN_ER_CONTR_VALUE
--
Name       Date          Change Details
--------   ----------    -----------------------------------------------
A.Logue    14-FEB-2000   Utf8 Support. Input value name lengthened to 80.
A.Myers    13-FEB-1998	 Knock on fix from bug 602851, extra parameter and logic
			 for extra parameter to hrdyndbi.insert_user_entity.
			 New Version: 110.1
rfine      24-NOV-1994   Suppressed index on business_group_id
rfine      05-OCT-1994   Prepended package name with 'PAY_' as per naming
                         standards.
mwcallag   09-DEC-1993   G334 : Benefit DB item names changed to be
                         <ELEMENT>_BEN_EE_CONTR_VALUE and
                         <ELEMENT>_BEN_ER_CONTR_VALUE.  Legislation code
                         derived from from per_business_groups if the
                         Legislation code is null on the input value table.
mwcallag   30-NOV-1993   G259 : Routine modified to use externalised database
                         item creation procedures in package hrdyndbi.
JRhodes    05-Nov-1993   Added "and nvl(BC.contributions_used,'Y') = 'Y'"
                         to cater for Payroll Deductions generation of
			 DB items
mwcallag   02-NOV-1993   exception of no_data_found added to procedure
                         create_contr_items.
JRhodes    20-OCT-1993   Created.
SDoshi     22-MAR-1999   Flexible Dates Conversion
irgonzal   24-SEP-2001   Bug fix 2004226. Enabled index  on per_business_groups
                         table by removing "+ 0" from the WHERE clause.
                         Modified create_contr_items procedure.

*/
--
PROCEDURE create_usdbi_startup is
l_text                       long;
l_date_earned_context_id     number;
l_assign_id_context_id       number;
l_payroll_context_id         number;
l_payroll_action_context_id  number;
l_org_pay_method_id          number;
l_per_pay_method_id          number;
l_organization_id            number;
l_temp                       number;
--
-- ******** local procedure : insert_route_parameters  ********
--
procedure insert_route_parameters
(
    p_parameter_name  in  varchar2,
    p_data_type       in  varchar2,
    p_sequence_no     in  number
) is
begin
    hr_utility.set_location('pay_us_contr_dbi.insert_route_parameters', 1);
    insert into ff_route_parameters
          (route_id,
           sequence_no,
           parameter_name,
           data_type,
           route_parameter_id)
   select  ff_routes_s.currval,
           p_sequence_no,
           p_parameter_name,
           p_data_type,
           ff_route_parameters_s.nextval
   from    dual;
end insert_route_parameters;
--
-- ******** local procedure : insert_route_context_usages  ********
--
procedure insert_route_context_usages
(
    p_context_id    in  number,
    p_sequence_no   in  number
) is
begin
    hr_utility.set_location('pay_us_contr_dbi.insert_route_context_usages', 1);
    insert into ff_route_context_usages
           (route_id,
            context_id,
            sequence_no)
    select  ff_routes_s.currval,
            p_context_id,
            p_sequence_no
    from    dual;
end insert_route_context_usages;
--
-- ************ Procedure : create_usdbi_startup ****************
--
BEGIN
    --
    -- get the context ids from the context table
    --
    hr_utility.set_location('pay_us_contr_dbi.create_usdbi_startup', 1);
    select context_id
    into   l_assign_id_context_id
    from   ff_contexts
    where  context_name = 'ASSIGNMENT_ID';
    --
    hr_utility.set_location('pay_us_contr_dbi.create_usdbi_startup', 2);
    select context_id
    into   l_date_earned_context_id
    from   ff_contexts
    where  context_name = 'DATE_EARNED';
    --
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --                                                             +
    -- input value route, name: US_CONTRIBUTION_VALUES             +
    --                                                             +
    --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    --
l_text :=
      'pay_input_values_f                     INPUTV,
       pay_element_entry_values_f             EEV,
       pay_element_types_f                    ETYPE,
       pay_element_links_f                    ELINK,
       pay_element_entries_f                  EE,
       ben_benefit_contributions_f            BCONTR,
       pay_input_values_f                     INPUTV2,
       pay_element_entry_values_f             EEV2
WHERE  INPUTV.input_value_id                 = &U2
AND    &B1                           BETWEEN INPUTV.effective_start_date
                                          AND INPUTV.effective_end_date
AND    INPUTV.input_value_id                = EEV.input_value_id
AND    INPUTV.element_type_id               = ETYPE.element_type_id
AND    &B1                           BETWEEN ETYPE.effective_start_date
                                          AND ETYPE.effective_end_date
AND    ETYPE.element_type_id                = ELINK.element_type_id
AND    &B1                           BETWEEN ELINK.effective_start_date
                                          AND ELINK.effective_end_date
AND    EE.assignment_id                     = &B2
AND    &B1                           BETWEEN EE.effective_start_date
                                          AND EE.effective_end_date
AND    ELINK.element_link_id                = EE.element_link_id
AND    EE.entry_type                        = ''E''
AND    EE.element_entry_id                  = EEV.element_entry_id
AND    &B1                           BETWEEN EEV.effective_start_date
                                          AND EEV.effective_end_date
AND    &B1                           BETWEEN INPUTV2.effective_start_date
                                          AND INPUTV2.effective_end_date
AND    INPUTV2.input_value_id                = EEV2.input_value_id
AND    INPUTV2.element_type_id               = ETYPE.element_type_id
AND    EE.element_entry_id                  = EEV2.element_entry_id
AND    &B1                           BETWEEN EEV2.effective_start_date
                                          AND EEV2.effective_end_date
AND    &U1                                 = BCONTR.element_type_id(+)
AND    &B1,                          BETWEEN BCONTR.effective_start_date(+)
                                          AND BCONTR.effective_end_date(+)
AND    BCONTR.coverage_type(+)              = EEV2.screen_entry_value
AND    upper(INPUTV2.name)                         = ''COVERAGE''';
    --
    hr_utility.set_location('pay_us_contr_dbi.create_usdbi_startup', 5);
    select ff_routes_s.nextval
    into   l_temp
    from   dual;
    --
    -- now do the normal insert
    --
    hr_utility.set_location('pay_us_contr_dbi.create_usdbi_startup', 6);
    insert into ff_routes
           (route_id,
            route_name,
            user_defined_flag,
            description,
            text,
            last_update_date,
            last_updated_by,
            last_update_login,
            created_by,
            creation_date)
    values (ff_routes_s.currval,
            'US_CONTRIBUTION_VALUES',
            'N',
            'route for contribution values using benefit contributions',
            l_text,
            sysdate,
            0,
            0,
            0,
            sysdate);
    --
    insert_route_parameters ('Element Type ID', 'N', 1);
    insert_route_parameters ('Input value ID', 'N', 2);
    insert_route_context_usages (l_date_earned_context_id, 1);
    insert_route_context_usages (l_assign_id_context_id,   2);
    --
END create_usdbi_startup;
--
-- ********** Procedure : create_contr_items ******************
--
PROCEDURE create_contr_items
(p_input_value_id    IN NUMBER
,p_effective_date    IN DATE
,p_start_string      IN VARCHAR2
,p_end_string        IN VARCHAR2
,p_data_type         IN VARCHAR2
) IS
--
l_input_value_name   VARCHAR2(80);
l_business_group_id  NUMBER;
l_legislation_code   VARCHAR2(30);
l_element_name       VARCHAR2(80);
l_element_type_id    NUMBER;
l_route_name         VARCHAR2(50);
l_not_found_flag     VARCHAR2(1);
l_entity_name        VARCHAR2(80);
l_entity_description VARCHAR2(80);
l_text               VARCHAR2(240);
l_description        VARCHAR2(80);
l_created_by         NUMBER;
l_last_login         NUMBER;
--
-- ******** local procedure : get_route ********
--
FUNCTION get_route
	     (p_route_name    VARCHAR2
	     ) return NUMBER IS
--
l_route_id NUMBER;
--
BEGIN
--
   hr_utility.set_location ('pay_us_contr_dbi.get_route', 1);
   SELECT route_id
   INTO   l_route_id
   FROM   ff_routes
   WHERE  route_name         = p_route_name;
--
   return(l_route_id);
--
END get_route;
--
-- ******** local procedure : create_item  ********
--
procedure create_item
(p_business_group_id    in number
,p_legislation_code     in varchar2
,p_route_name           in varchar2
,p_not_found_flag       in varchar2
,p_entity_name          in varchar2
,p_entity_description   in varchar2
,p_data_type            in varchar2
,p_text                 in varchar2
,p_description          in varchar2
,p_creator_id           in number
,p_created_by           in number
,p_last_login           in number
,p_element_type_id      in number
,p_input_value_id       in number
)
IS
l_record_inserted BOOLEAN;
--
BEGIN
   --
   -- create the user entity:
   --
   hrdyndbi.insert_user_entity (p_route_name,
                                p_entity_name,
                                p_entity_description,
                                p_not_found_flag,
                                'I',
                                p_creator_id,
                                p_business_group_id,
                                p_legislation_code,
                                p_created_by,
                                p_last_login,
				l_record_inserted);
   --
   -- insert the parameter values:
   --
   IF l_record_inserted THEN
       hrdyndbi.insert_parameter_value (p_element_type_id, 1);
       hrdyndbi.insert_parameter_value (p_input_value_id,  2);
   --
   -- Insert the Database Item:
   --
       hrdyndbi.insert_database_item (p_entity_name,
                                  'VALUE',
                                  p_data_type,
                                  p_text,
                                  'Y',
                                  p_description);
   END IF;
END create_item;
--
-- ******** procedure : create_contr_items ********
--
BEGIN
--
--
-- retrieve details of the input value and element type
--
    begin
        hr_utility.set_location ('pay_us_contr_dbi.create_contr_items', 1);
        select ET.element_type_id,
	       replace (ltrim (rtrim (upper (ET.element_name))), ' ', '_'),
	       replace (ltrim (rtrim (upper (IV.name))), ' ', '_'),
	       IV.business_group_id,
               nvl (ltrim(rtrim(IV.legislation_code)),
                    ltrim(rtrim(BUSGP.legislation_code))),
               IV.created_by,
               IV.last_update_login
        into   l_element_type_id,
	       l_element_name,
               l_input_value_name,
	       l_business_group_id,
               l_legislation_code,
               l_created_by,
               l_last_login
        from   pay_input_values_f       IV,
               pay_element_types_f      ET,
               per_business_groups      BUSGP,
	       ben_benefit_classifications BC
        where  IV.input_value_id      = p_input_value_id
        and    p_effective_date between IV.effective_start_date
                                and     IV.effective_end_date
        and    IV.element_type_id     = ET.element_type_id
        and    p_effective_date between ET.effective_start_date
                                and     ET.effective_end_date
        and    ET.benefit_classification_id = BC.benefit_classification_id(+)
	and    nvl(BC.contributions_used,'Y')     = 'Y'
        and    BUSGP.business_group_id (+)  = IV.business_group_id + 0; --#2004226
    exception
        when no_data_found then  l_element_type_id := null;
    end;
    --
    if (l_element_type_id is not null) and
       (l_input_value_name = 'ER_CONTR' or l_input_value_name = 'EE_CONTR')
        then
        --
        if l_input_value_name = 'ER_CONTR' then
              --
              l_route_name := 'US_CONTRIBUTION_VALUES';
              l_entity_name := l_element_name || '_BEN_ER_CONTR';
              l_entity_description := 'Entity for ' || l_route_name;
              l_text        := 'nvl(EEV.screen_entry_value,
      			            BCONTR.employer_contribution)';
              l_description := 'employers contribution';
       else
              --
	      l_route_name := 'US_CONTRIBUTION_VALUES';
              l_entity_name := l_element_name || '_BEN_EE_CONTR';
              l_entity_description := 'Entity for ' || l_route_name;
              l_text        := 'nvl(EEV.screen_entry_value,
			            BCONTR.employee_contribution)';
              l_description := 'employees contribution';
       end if;
       --
       -- Handle variable data type
       --
       l_text := 'min (' || p_start_string || l_text || p_end_string || ')';
       --
       hr_utility.set_location ('pay_us_contr_dbi.create_contr_items', 2);
       create_item
       (l_business_group_id
       ,l_legislation_code
       ,l_route_name
       ,'Y'                       -- l_not_found_flag
       ,l_entity_name
       ,l_entity_description
       ,p_data_type
       ,l_text
       ,l_description
       ,p_input_value_id          -- l_creator_id
       ,l_created_by
       ,l_last_login
       ,l_element_type_id
       ,p_input_value_id
       );
       --
    end if;
END create_contr_items;
END pay_us_contr_dbi;

/
