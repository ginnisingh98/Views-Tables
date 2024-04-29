--------------------------------------------------------
--  DDL for Package Body PQP_GB_CONFIGURATION_VALUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_CONFIGURATION_VALUE" as
/* $Header: pqgbpcvp.pkb 120.0.12010000.4 2009/08/25 10:57:52 parusia ship $ */

g_debug boolean;
g_QTS_LOOKUP_NAME varchar2(10) := 'YES_NO';
g_QTS_ROUTE_LOOKUP_NAME varchar2(30) := 'PQP_GB_SWF_QTS_ROUTES';
g_REG_SPINE_LOOKUP_NAME varchar2(30) := 'PQP_GB_REGIONAL_SPINE_CODE';

procedure chk_pension_scheme_mapping(p_pcv_information2 in varchar2
                                    ,p_pcv_information3 in varchar2
                                      ) as
l_proc varchar2(53);
Begin
 l_proc:='PQP_GB_CONFIGURATION_VALUE.chk_pension_scheme_mapping';

 if g_debug then
  hr_utility.set_location('Entering:'||l_proc,10);
  hr_utility.trace('p_pcv_information2 '||p_pcv_information2);
  hr_utility.trace('p_pcv_information3 '||p_pcv_information3);
 end if;

   -- pcv_information3(Partnership scheme) must have value if
   -- pcv_information2 is PARTNER
   if (
        p_pcv_information2 ='PARTNER' and p_pcv_information3 is null
      ) then

      hr_utility.set_message(8303,'PQP_230236_ENTER_PARTNER_SCH');
      hr_utility.raise_error;

    --else
    -- pcv_information2 is not PARTNER then ignore.
   end if;


  if g_debug then
   hr_utility.set_location('Leaving:'||l_proc,20);
  end if;

End chk_pension_scheme_mapping;


------------
-- School Workforce Census- Teacher Number Validation
-- p_pcv_information1 => Source
-- p_pcv_information3 => Context Name
-- p_pcv_information4 => Segment Name
-----------
procedure chk_teacher_number(p_configuration_value_id in number
                             , p_pcv_information1 in varchar2
                           , p_pcv_information3 in varchar2
                           , p_pcv_information4 in varchar2
                              ) as
begin

  -- If Person EIT or Person DFF is selected as source
  -- then Context and Segment names are mandatory
  if p_pcv_information1 = 'PER_PEOPLE' then
      if p_pcv_information3 is null then
        fnd_message.set_name('PQP', 'PQP_230238_FIELD_MANDATORY');
        fnd_message.set_token('FIELD', 'Context Name');
        fnd_message.set_token('SOURCE', 'Person DFF (Additional Personal Details Flexfield)');
        fnd_message.raise_error;
      elsif p_pcv_information4 is null then
        fnd_message.set_name('PQP', 'PQP_230238_FIELD_MANDATORY');
        fnd_message.set_token('FIELD', 'Segment Column');
        fnd_message.set_token('SOURCE', 'Person DFF (Additional Personal Details Flexfield)');
        fnd_message.raise_error;
      end if ;
  elsif p_pcv_information1 = 'Extra Person Info DDF' then
      if p_pcv_information3 is null then
        fnd_message.set_name('PQP', 'PQP_230238_FIELD_MANDATORY');
        fnd_message.set_token('FIELD', 'Context Name');
        fnd_message.set_token('SOURCE', 'Person EIT (Extra Person Information Flexfield)');
        fnd_message.raise_error;
      elsif p_pcv_information4 is null then
        fnd_message.set_name('PQP', 'PQP_230238_FIELD_MANDATORY');
        fnd_message.set_token('FIELD', 'Segment Column');
        fnd_message.set_token('SOURCE', 'Person EIT (Extra Person Information Flexfield)');
        fnd_message.raise_error;
      end if ;
  end if ;
  --
end chk_teacher_number ;



------------
-- School Workforce Census- Ethnic Origin Validation
-- p_pcv_information1 => User Ethnic Origin Value
-----------
procedure chk_ethnic_origin(p_configuration_value_id in number
                             , p_business_group_id in number
                          , p_pcv_information_category in varchar2
                          , p_pcv_information1 in varchar2
                           ) as
p_return boolean ;
begin
    -- If the given user ethnic origin is already mapped
    -- then user should not be able to map it again
    pqp_gb_swf_validations.chk_single_unique_mapping(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                             , p_pcv_information_category => p_pcv_information_category
                             , p_information_column => 'PCV_INFORMATION1'
                             , p_value => p_pcv_information1
                             , p_return => p_return);
    if (p_return = false) then
        fnd_message.set_name('PQP', 'PQP_230239_DUPLICATE_MAPPING');
        fnd_message.set_token('VALUE', 'Ethnic Origin Value');
        fnd_message.set_token('DCSF_CODE', 'DCSF Ethnic Code');
        fnd_message.raise_error;
    end if ;
  --
end chk_ethnic_origin ;



------------
-- School Workforce Census- QTS/QTS Route Mapping Validation
-- p_pcv_information1 => Lookup Name
-- p_pcv_information2 => Segment Start Value
-- p_pcv_information3 => Segment End Value
-- p_pcv_information4 => DCSF QTS/QTS Route Code
-----------
procedure  chk_qts_mapping(p_configuration_value_id in number
                             , p_business_group_id in number
                         , p_pcv_information_category in varchar2
                         , p_pcv_information1 in varchar2
                         , p_pcv_information2 in varchar2
                         , p_pcv_information3 in varchar2
                         , p_pcv_information4 in varchar2
                         ) as
p_return boolean ;
p_seeded_lookup_name varchar(50);
l_field_name varchar2(50);
l_count number;
begin

    -- 1) While creating multiple configuration records for this oconfiguration type
    --    user should not be able to create records with different lookup names
    pqp_gb_swf_validations.chk_unique_lookup_name(p_configuration_value_id => p_configuration_value_id
                           , p_business_group_id => p_business_group_id
                           , p_pcv_information_category => p_pcv_information_category
                           , p_information_column => 'PCV_INFORMATION1'
                           , p_value => p_pcv_information1
                           , p_return => p_return);
    if (p_return = false) then
        fnd_message.set_name('PQP', 'PQP_230243_USE_SAME_LOOKUP');
        fnd_message.raise_error;
    end if ;

    -- 2) If the user has given seeded QTS/QTS Route lookup name
    --    Then he should not be required to give the mapping
    --    Else Segment Start Value and DCSF Code are mandatory

    if p_pcv_information_category = 'PQP_GB_SWF_QTS_MAPPING' then
        p_seeded_lookup_name := g_QTS_LOOKUP_NAME;
        l_field_name := 'Qualified Teacher Status Value';
    else
        p_seeded_lookup_name := g_QTS_ROUTE_LOOKUP_NAME;
        l_field_name := 'DCSF QTS Route Code';
    end if ;

    if p_pcv_information1 <> p_seeded_lookup_name then
        if p_pcv_information2 is null or p_pcv_information4 is null then
            fnd_message.set_name('PQP', 'PQP_230241_ENTER_MAPPING');
            fnd_message.set_token('DCSF_CODE', l_field_name);
            fnd_message.set_token('LOOKUP_NAME', p_seeded_lookup_name);
            fnd_message.raise_error;
        end if;
    end if;

    -- 3) If Segment End Value is provided
    --    Then Segment Start Value should not be less than Segment End Value
    if p_pcv_information1 <> p_seeded_lookup_name then
        if p_pcv_information3 is not null then
            if p_pcv_information3 < p_pcv_information2 then
                fnd_message.set_name('PQP', 'PQP_230242_WRONG_END_VAL');
                fnd_message.set_token('TYPE', 'Segment');
                fnd_message.raise_error;
            end if;
        end if ;


        -- 4) While creating multiple configuration records for this oconfiguration type
        --    user should not be able to map same segment value twice
        pqp_gb_swf_validations.chk_range_unique_mapping(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                             , p_pcv_information_category => p_pcv_information_category
                             , p_information_start_column => 'PCV_INFORMATION2'
                             , p_information_end_column => 'PCV_INFORMATION3'
                             , p_value_start => p_pcv_information2
                             , p_value_end => p_pcv_information3
                             , p_return => p_return);
        if (p_return = false) then
                fnd_message.set_name('PQP', 'PQP_230244_DUP_RANGE_MAP');
                fnd_message.raise_error;
        end if ;
    else
        -- seeded lookup used
        -- check if there already exists a row with seeded lookup
        -- then raise error saying mapping already defined
        begin
            select 1
            into l_count
            from pqp_configuration_values
            where pcv_information_category = p_pcv_information_category
              and business_group_id = p_business_group_id
              and (p_configuration_value_id is null
                   or  configuration_value_id <> p_configuration_value_id)
              and pcv_information1 = p_pcv_information1 ;
        exception
           when others then
              null ;
        end;

        if l_count is not null then
            fnd_message.set_name('PQP', 'PQP_230240_DUPLICATE_MAPPING');
            fnd_message.raise_error;
        end if;
    end if;
    --
end chk_qts_mapping ;



------------
-- School Workforce Census- HLTA Source Validation
-- p_pcv_information1 => Source ( Job KFF, Person DFF, Assignment DFF)
-- p_pcv_information3 => Job KFF Segment
-- p_pcv_information4 => Person/Assignment DFF Context
-- p_pcv_information5 => Person/Assignment DFF Segment
-----------
procedure chk_hlta_source(p_configuration_value_id in number
                             , p_business_group_id in number
                          , p_pcv_information_category in varchar2
                          , p_pcv_information1 in varchar2
                          , p_pcv_information3 in varchar2
                          , p_pcv_information4 in varchar2
                          , p_pcv_information5 in varchar2
                          )as
begin
    -- 1) If Job Key Flexfield is selected as source
    -- Then Job Key Flexfield segment must be entered
    if p_pcv_information1 = 'JOB' and p_pcv_information3 is null then
        fnd_message.set_name('PQP', 'PQP_230238_FIELD_MANDATORY');
        fnd_message.set_token('FIELD', 'Job Key Flexfield Segment Column');
        fnd_message.set_token('SOURCE', 'Job Key Flexfield');
        fnd_message.raise_error;

    end if ;

    -- 2) If Person/Assignment DFF is selected as source
    --    Then Person/Assignment Context and Segment must be provided
    if p_pcv_information1 = 'PER_PEOPLE' then
        if p_pcv_information4 is null then
            fnd_message.set_name('PQP', 'PQP_230238_FIELD_MANDATORY');
            fnd_message.set_token('FIELD', 'Person/Assignment Context Name');
            fnd_message.set_token('SOURCE', 'Person DFF (Additional Personal Details Flexfield)');
            fnd_message.raise_error;
        elsif p_pcv_information5 is null then
            fnd_message.set_name('PQP', 'PQP_230238_FIELD_MANDATORY');
            fnd_message.set_token('FIELD', 'Person/Assignment Segment Column');
            fnd_message.set_token('SOURCE', 'Person DFF (Additional Personal Details Flexfield)');
            fnd_message.raise_error;
        end if;
    elsif p_pcv_information1 = 'PER_ASSIGNMENTS' then
        if p_pcv_information4 is null then
            fnd_message.set_name('PQP', 'PQP_230238_FIELD_MANDATORY');
            fnd_message.set_token('FIELD', 'Person/Assignment Context Name');
            fnd_message.set_token('SOURCE', 'Assignment DFF (Additional Assignment Details DFF)');
            fnd_message.raise_error;
        elsif p_pcv_information5 is null then
            fnd_message.set_name('PQP', 'PQP_230238_FIELD_MANDATORY');
            fnd_message.set_token('FIELD', 'Person/Assignment Segment Column');
            fnd_message.set_token('SOURCE', 'Assignment DFF (Additional Assignment Details DFF)');
            fnd_message.raise_error;
        end if;
    end if;
    --
end chk_hlta_source;



------------
-- School Workforce Census- HLTA Mapping Validation
-- p_pcv_information1 => Lookup Name
-- p_pcv_information2 => User Segment Value
-- p_pcv_information3 => HLTA Status Value
-----------
procedure chk_hlta_mapping(p_configuration_value_id in number
                             , p_business_group_id in number
                          , p_pcv_information_category in varchar2
                          , p_pcv_information1 in varchar2
                          , p_pcv_information2 in varchar2
                          , p_pcv_information3 in varchar2
                          )as
p_return boolean ;
begin
    -- 1) While creating multiple configuration records for this oconfiguration type
    --    user should not be able to create records with different lookup names
    pqp_gb_swf_validations.chk_unique_lookup_name( p_configuration_value_id => p_configuration_value_id
                           , p_business_group_id => p_business_group_id
                           , p_pcv_information_category => p_pcv_information_category
                           , p_information_column => 'PCV_INFORMATION1'
                           , p_value => p_pcv_information1
                           , p_return => p_return);
    if (p_return = false) then
        fnd_message.set_name('PQP', 'PQP_230243_USE_SAME_LOOKUP');
        fnd_message.raise_error;
    end if ;

    --
    -- 2) If the given user segment value is already mapped
    --    Then user should not be able to map it again
    pqp_gb_swf_validations.chk_single_unique_mapping(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                             , p_pcv_information_category => p_pcv_information_category
                             , p_information_column => 'PCV_INFORMATION2'
                             , p_value => p_pcv_information2
                             , p_return => p_return);
    if (p_return = false) then
            fnd_message.set_name('PQP', 'PQP_230239_DUPLICATE_MAPPING');
            fnd_message.set_token('VALUE', 'User Segment Value');
            fnd_message.set_token('DCSF_CODE', 'HLTA Status Value');
            fnd_message.raise_error;
    end if ;
    --
end chk_hlta_mapping;



------------
-- School Workforce Census- Arrival Date Validation
-- p_pcv_information1 => Source (Assignment Start Date / Calcuated)
-- p_pcv_information2 => User Formula
-----------
procedure chk_arrival_date(p_configuration_value_id in number
                             , p_business_group_id in number
                          , p_pcv_information_category in varchar2
                          , p_pcv_information1 in varchar2
                          , p_pcv_information2 in varchar2
                          ) as
begin
    if p_pcv_information1 = 'CAL' and p_pcv_information2 is null then
            fnd_message.set_name('PQP', 'PQP_230238_FIELD_MANDATORY');
            fnd_message.set_token('FIELD', 'User Formula Name');
            fnd_message.set_token('SOURCE', 'Calculated');
            fnd_message.raise_error;
    end if ;
    --
end chk_arrival_date;

--
------------
-- School Workforce Census- Contract Type Validation
-- p_pcv_information1 => Source (Assignment Category/ PQP Contract Type)
-- p_pcv_information3 => Assignment Category Value
-- p_pcv_information4 => PQP Contract Type Value
-- p_pcv_information5 => DCSF Contract Type Value
-----------
procedure chk_contract_type(p_configuration_value_id in number
                             , p_business_group_id in number
                          , p_pcv_information_category in varchar2
                          , p_pcv_information1 in varchar2
                          , p_pcv_information3 in varchar2
                          , p_pcv_information4 in varchar2
                          , p_pcv_information5 in varchar2
                          ) as
p_return boolean;
begin
    -- 1) While creating multiple configuration records for this oconfiguration type
    --    user should not be able to create records with different source names
    pqp_gb_swf_validations.chk_unique_lookup_name(p_configuration_value_id => p_configuration_value_id
                           , p_business_group_id => p_business_group_id
                           , p_pcv_information_category => p_pcv_information_category
                           , p_information_column => 'PCV_INFORMATION1'
                           , p_value => p_pcv_information1
                           , p_return => p_return);
    if (p_return = false) then
            fnd_message.set_name('PQP', 'PQP_230245_USE_SAME_SOURCE');
            fnd_message.raise_error;
    end if ;


    --
    -- 2) Assignment Category Value must  be provided if assignment category
    --    is selected as source
    if p_pcv_information1 = 'ASG_CAT' then
       if p_pcv_information3 is null then
            fnd_message.set_name('PQP', 'PQP_230238_FIELD_MANDATORY');
            fnd_message.set_token('FIELD', 'Assignment Category Value');
            fnd_message.set_token('SOURCE', 'Assignment Category');
            fnd_message.raise_error;
       end if ;
    end if ;


    --
    -- 3) PQP Contract Type Value must  be provided if PQP contract type
    --    is selected as source
    if p_pcv_information1 = 'CNTRCT_TYPE' then
       if p_pcv_information4 is null then
            fnd_message.set_name('PQP', 'PQP_230238_FIELD_MANDATORY');
            fnd_message.set_token('FIELD', 'PQP Contract Type Value');
            fnd_message.set_token('SOURCE', 'PQP Contract Type');
            fnd_message.raise_error;
       end if ;
    end if ;


    --
    -- 4) If the given user value(Assignment Category or PQP contract type) is already mapped
    --    Then user should not be able to map it again
    if p_pcv_information1 = 'ASG_CAT' then
        pqp_gb_swf_validations.chk_single_unique_mapping(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                             , p_pcv_information_category => p_pcv_information_category
                             , p_information_column => 'PCV_INFORMATION3'
                             , p_value => p_pcv_information3
                             , p_return => p_return);
        if (p_return = false) then
            fnd_message.set_name('PQP', 'PQP_230239_DUPLICATE_MAPPING');
            fnd_message.set_token('VALUE', 'Assignment Category');
            fnd_message.set_token('DCSF_CODE', 'DCSF Contract Type Value');
            fnd_message.raise_error;
        end if ;
    elsif p_pcv_information1 = 'CNTRCT_TYPE' then
        pqp_gb_swf_validations.chk_single_unique_mapping(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                             , p_pcv_information_category => p_pcv_information_category
                             , p_information_column => 'PCV_INFORMATION4'
                             , p_value => p_pcv_information4
                             , p_return => p_return);
        if (p_return = false) then
            fnd_message.set_name('PQP', 'PQP_230239_DUPLICATE_MAPPING');
            fnd_message.set_token('VALUE', 'PQP Contract Type Value');
            fnd_message.set_token('DCSF_CODE', 'DCSF Contract Type Value');
            fnd_message.raise_error;
        end if ;
    end if ;


end chk_contract_type ;

--
------------
-- School Workforce Census- Origin Mapping Validation
-- p_pcv_information1 => Lookup Name
-- p_pcv_information3 => Origin Value
-- p_pcv_information4 => DCSF Origin Code
-----------
procedure chk_origin_mapping(p_configuration_value_id in number
                             , p_business_group_id in number
                          , p_pcv_information_category in varchar2
                          , p_pcv_information1 in varchar2
                          , p_pcv_information2 in varchar2
                          , p_pcv_information3 in varchar2
                          ) as
p_return boolean;
begin

    -- 1) While creating multiple configuration records for this oconfiguration type
    --    user should not be able to create records with different lookup names
    pqp_gb_swf_validations.chk_unique_lookup_name(p_configuration_value_id => p_configuration_value_id
                           , p_business_group_id => p_business_group_id
                           , p_pcv_information_category => p_pcv_information_category
                           , p_information_column => 'PCV_INFORMATION1'
                           , p_value => p_pcv_information1
                           , p_return => p_return);
    if (p_return = false) then
            fnd_message.set_name('PQP', 'PQP_230243_USE_SAME_LOOKUP');
            fnd_message.raise_error;
    end if ;

    -- 2) If the given user origin value is already mapped
    --   then user should not be able to map it again
    pqp_gb_swf_validations.chk_single_unique_mapping(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                             , p_pcv_information_category => p_pcv_information_category
                             , p_information_column => 'PCV_INFORMATION2'
                             , p_value => p_pcv_information2
                             , p_return => p_return);
    if (p_return = false) then
            fnd_message.set_name('PQP', 'PQP_230239_DUPLICATE_MAPPING');
            fnd_message.set_token('VALUE', 'Origin Value');
            fnd_message.set_token('DCSF_CODE', 'DCSF Origin Code');
            fnd_message.raise_error;
    end if ;
end chk_origin_mapping;

--
------------
-- School Workforce Census- Destination Mapping Validation
-- p_pcv_information1 => Lookup Name
-- p_pcv_information3 => Destination Value
-- p_pcv_information4 => DCSF Destination Code
-----------
procedure chk_destination_mapping(p_configuration_value_id in number
                             , p_business_group_id in number
                          , p_pcv_information_category in varchar2
                          , p_pcv_information1 in varchar2
                          , p_pcv_information2 in varchar2
                          , p_pcv_information3 in varchar2
                          ) as
p_return boolean;
begin

    -- 1) While creating multiple configuration records for this oconfiguration type
    --    user should not be able to create records with different lookup names
    pqp_gb_swf_validations.chk_unique_lookup_name(p_configuration_value_id => p_configuration_value_id
                           , p_business_group_id => p_business_group_id
                           , p_pcv_information_category => p_pcv_information_category
                           , p_information_column => 'PCV_INFORMATION1'
                           , p_value => p_pcv_information1
                           , p_return => p_return);
    if (p_return = false) then
            fnd_message.set_name('PQP', 'PQP_230243_USE_SAME_LOOKUP');
            fnd_message.raise_error;
    end if ;

    -- 2) If the given user Destination value is already mapped
    --   then user should not be able to map it again
    pqp_gb_swf_validations.chk_single_unique_mapping(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                             , p_pcv_information_category => p_pcv_information_category
                             , p_information_column => 'PCV_INFORMATION2'
                             , p_value => p_pcv_information2
                             , p_return => p_return);
    if (p_return = false) then
            fnd_message.set_name('PQP', 'PQP_230239_DUPLICATE_MAPPING');
            fnd_message.set_token('VALUE', 'Destination Value');
            fnd_message.set_token('DCSF_CODE', 'DCSF Destination Code');
            fnd_message.raise_error;
    end if ;
    --
end chk_destination_mapping;

--
--
------------
-- School Workforce Census- Role/Post Source Validation
-- p_pcv_information1 => Source(Job, Grade, Position KFF, Assignment Category)
-- p_pcv_information3 => Job/ Grade/ Position segment
-----------
procedure chk_role_post_source(p_configuration_value_id in number
                             , p_business_group_id in number
                          , p_pcv_information_category in varchar2
                          , p_pcv_information1 in varchar2
                          , p_pcv_information3 in varchar2
                          ) as
p_return boolean;
l_mapping_info_category varchar2(100);
l_mapping_lookup varchar2(100) ;
begin
--   hr_utility.trace_on(null,'SWFTRC');
   hr_utility.trace('Inside Post source');
   hr_utility.trace('p_pcv_information_category='||p_pcv_information_category);
   hr_utility.trace('p_pcv_information1='||p_pcv_information1);
   hr_utility.trace('p_pcv_information3='||p_pcv_information3);

   -- Get role/post mapping
   if p_pcv_information_category = 'PQP_GB_SWF_ROLE_SOURCE' then
       l_mapping_info_category := 'PQP_GB_SWF_ROLE_MAPPING';
   else
       l_mapping_info_category := 'PQP_GB_SWF_POST_MAPPING';
   end if ;

   begin
         select pcv_information1
         into l_mapping_lookup
         from pqp_configuration_values
         where business_group_id = p_business_group_id
           and pcv_information_category = l_mapping_info_category
           and rownum<2 ;
  exception
        when no_data_found then
            null ;
  end ;

   hr_utility.trace('l_mapping_lookup='||l_mapping_lookup);
   hr_utility.trace('p_pcv_information1='||p_pcv_information1);

    if p_pcv_information1 = 'EMP_CAT' and l_mapping_lookup <> 'EMP_CAT' then
        hr_utility.trace('Raising error for EMP_CAT');
        fnd_message.set_name('PQP', 'PQP_230246_INCORRECT_LOOKUP');
        fnd_message.set_token('LOOKUP_NAME', 'EMP_CAT');
        fnd_message.set_token('SOURCE', 'Assignment Category');
        fnd_message.raise_error;
    elsif p_pcv_information1 = 'EMPLOYEE_CATG' and l_mapping_lookup <> 'EMPLOYEE_CATG' then
        hr_utility.trace('Raising error for EMPLOYEE_CATG');
        fnd_message.set_name('PQP', 'PQP_230246_INCORRECT_LOOKUP');
        fnd_message.set_token('LOOKUP_NAME', 'EMPLOYEE_CATG');
        fnd_message.set_token('SOURCE', 'Employee Category');
        fnd_message.raise_error;
    end if;

        hr_utility.trace('Outside error raising section');
    --
    -- 1) Segment Name must  be provided if Job/Position/Grade KFF
    --    is selected as source
    if p_pcv_information1 = 'JOB' and p_pcv_information3 is null then
            fnd_message.set_name('PQP', 'PQP_230238_FIELD_MANDATORY');
            fnd_message.set_token('FIELD', 'Segment Column');
            fnd_message.set_token('SOURCE', 'Job Key Flexfield');
            fnd_message.raise_error;
    elsif p_pcv_information1 = 'POS' and p_pcv_information3 is null then
            fnd_message.set_name('PQP', 'PQP_230238_FIELD_MANDATORY');
            fnd_message.set_token('FIELD', 'Segment Column');
            fnd_message.set_token('SOURCE', 'Position Key Flexfield');
            fnd_message.raise_error;
    elsif p_pcv_information1 = 'GRD' and p_pcv_information3 is null then
            fnd_message.set_name('PQP', 'PQP_230238_FIELD_MANDATORY');
            fnd_message.set_token('FIELD', 'Segment Column');
            fnd_message.set_token('SOURCE', 'Grade Key Flexfield');
            fnd_message.raise_error;
    end if ;
        hr_utility.trace('Leaving Post source checks');
    --
end chk_role_post_source;

--
--
--
------------
-- School Workforce Census- Role/Post Mapping Validation
-- p_pcv_information1 => Lookup Name
-- p_pcv_information2 => Segment Start Value
-- p_pcv_information3 => Segment End Value
-- p_pcv_information4 => DCSF Role/Post Code
-----------
procedure chk_role_post_mapping(p_configuration_value_id in number
                             , p_business_group_id in number
                          , p_pcv_information_category in varchar2
                          , p_pcv_information1 in varchar2
                          , p_pcv_information2 in varchar2
                          , p_pcv_information3 in varchar2
                          , p_pcv_information4 in varchar2
                          ) as
p_return boolean;
l_source varchar2(50);
l_source_info_category varchar2(50);
begin

   -- Get role/post source
   if p_pcv_information_category = 'PQP_GB_SWF_ROLE_MAPPING' then
       l_source_info_category := 'PQP_GB_SWF_ROLE_SOURCE';
   else
       l_source_info_category := 'PQP_GB_SWF_POST_SOURCE';
   end if ;

   begin
         select pcv_information1
         into l_source
         from pqp_configuration_values
         where business_group_id = p_business_group_id
           and pcv_information_category = l_source_info_category ;
  exception
        when no_data_found then
            null ;
  end ;

  --
  -- 1) If source = Assignment/Employee Category, then lookup name must be 'EMP_CAT'/'EMPLOYEE_CATG'
    if l_source = 'EMP_CAT' and p_pcv_information1 <> 'EMP_CAT' then
            fnd_message.set_name('PQP', 'PQP_230246_INCORRECT_LOOKUP');
            fnd_message.set_token('LOOKUP_NAME', 'EMP_CAT');
            fnd_message.set_token('SOURCE', 'Assignment Category');
            fnd_message.raise_error;
    end if ;

    if l_source = 'EMPLOYEE_CATG' and p_pcv_information1 <> 'EMPLOYEE_CATG' then
            fnd_message.set_name('PQP', 'PQP_230246_INCORRECT_LOOKUP');
            fnd_message.set_token('LOOKUP_NAME', 'EMPLOYEE_CATG');
            fnd_message.set_token('SOURCE', 'Employee Category');
            fnd_message.raise_error;
    end if ;
    --
    -- 2) While creating multiple configuration records for this oconfiguration type
    --    user should not be able to create records with different lookup names
    pqp_gb_swf_validations.chk_unique_lookup_name(p_configuration_value_id => p_configuration_value_id
                           , p_business_group_id => p_business_group_id
                           , p_pcv_information_category => p_pcv_information_category
                           , p_information_column => 'PCV_INFORMATION1'
                           , p_value => p_pcv_information1
                           , p_return => p_return);
    if (p_return = false) then
            fnd_message.set_name('PQP', 'PQP_230243_USE_SAME_LOOKUP');
            fnd_message.raise_error;
    end if ;

  --
  -- 3) If source = Grade KFF, and Segment End Value is provided
  --    Then Segment End Value should not be less than Segment Start Value
  if l_source = 'GRD' and p_pcv_information3 is not null then
      if p_pcv_information3 < p_pcv_information2 then
            fnd_message.set_name('PQP', 'PQP_230242_WRONG_END_VAL');
            fnd_message.set_token('TYPE', 'Segment');
            fnd_message.raise_error;
      end if ;
  end if ;


    -- 4) While creating multiple configuration records for this oconfiguration type
    --    user should not be able to map same segment value twice
    pqp_gb_swf_validations.chk_range_unique_mapping(
                               p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                             , p_pcv_information_category => p_pcv_information_category
                             , p_information_start_column => 'PCV_INFORMATION2'
                             , p_information_end_column => 'PCV_INFORMATION3'
                             , p_value_start => p_pcv_information2
                             , p_value_end => p_pcv_information3
                             , p_return => p_return);
    if (p_return = false) then
            fnd_message.set_name('PQP', 'PQP_230244_DUP_RANGE_MAP');
            fnd_message.raise_error;
    end if ;
    --
end chk_role_post_mapping;


--
------------
-- School Workforce Census- Payscale Validation
-- p_pcv_information1 => User PayScale Value
-- p_pcv_information2 => DCSF PayScale Value
-----------
procedure chk_payscale_mapping(p_configuration_value_id in number
                             , p_business_group_id in number
                          , p_pcv_information_category in varchar2
                          , p_pcv_information1 in varchar2
                          , p_pcv_information2 in varchar2
                          ) as
p_return boolean;
begin
    -- If the given user payscale is already mapped
    -- then user should not be able to map it again
    pqp_gb_swf_validations.chk_single_unique_mapping(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                             , p_pcv_information_category => p_pcv_information_category
                             , p_information_column => 'PCV_INFORMATION1'
                             , p_value => p_pcv_information1
                             , p_return => p_return);
    if (p_return = false) then
            fnd_message.set_name('PQP', 'PQP_230239_DUPLICATE_MAPPING');
            fnd_message.set_token('Value', 'Pay Scale Value');
            fnd_message.set_token('DCSF_CODE', 'DCSF Pay Scale Code');
            fnd_message.raise_error;
    end if ;
    --
end chk_payscale_mapping;


--
--
------------
-- School Workforce Census- Regional Spine Source Validation
-- p_pcv_information1 => Source(Grade, PayScale or Spine Point, Default)
-- p_pcv_information2 => Grade Key Flexfield segment
-- p_pcv_information3 => Default Value
-----------
procedure chk_regional_spine_source(p_configuration_value_id in number
                             , p_business_group_id in number
                          , p_pcv_information_category in varchar2
                          , p_pcv_information1 in varchar2
                          , p_pcv_information2 in varchar2
                          , p_pcv_information3 in varchar2
                          ) as
p_return boolean;
begin
    --
    -- 1) Grade Flexfield Segment Name must  be provided if Grade KFF
    --    is selected as source
    if p_pcv_information1 = 'GRD' and p_pcv_information2 is null then
            fnd_message.set_name('PQP', 'PQP_230238_FIELD_MANDATORY');
            fnd_message.set_token('Field', 'Grade Flexfield Segment Column');
            fnd_message.set_token('SOURCE', 'Grade Key Flexfield');
            fnd_message.raise_error;
    end if ;

    --
    -- 2) Default Value must  be provided if Default is selected as source
    if p_pcv_information1 = 'DEFAULT' and p_pcv_information3 is null then
            fnd_message.set_name('PQP', 'PQP_230238_FIELD_MANDATORY');
            fnd_message.set_token('Field', 'Default Value');
            fnd_message.set_token('SOURCE', 'Default');
            fnd_message.raise_error;
    end if ;
    --
end chk_regional_spine_source;


------------
-- School Workforce Census- Regional Spine mapping with Grade Validation
-- p_pcv_information1 => Lookup Name
-- p_pcv_information2 => Segment Start Value
-- p_pcv_information3 => Segment End Value
-- p_pcv_information4 => DCSF Regional Spine Code
-----------
procedure chk_regional_spine_map_grade(p_configuration_value_id in number
                             , p_business_group_id in number
                         , p_pcv_information_category in varchar2
                         , p_pcv_information1 in varchar2
                         , p_pcv_information2 in varchar2
                         , p_pcv_information3 in varchar2
                         , p_pcv_information4 in varchar2
                         ) as
p_return boolean ;
l_field_name varchar2(50);
l_count number;
begin
    -- 1) While creating multiple configuration records for this oconfiguration type
    --    user should not be able to create records with different lookup names
    pqp_gb_swf_validations.chk_unique_lookup_name(
                             p_configuration_value_id => p_configuration_value_id
                           , p_business_group_id => p_business_group_id
                           , p_pcv_information_category => p_pcv_information_category
                           , p_information_column => 'PCV_INFORMATION1'
                           , p_value => p_pcv_information1
                           , p_return => p_return);
    if (p_return = false) then
            fnd_message.set_name('PQP', 'PQP_230243_USE_SAME_LOOKUP');
            fnd_message.raise_error;
    end if ;

    -- 2) If the user has given seeded Regional Spine lookup name
    --    Then he should not be required to give the mapping
    --    Else Segment Start Value and DCSF Regional Spine Code are mandatory

    if p_pcv_information1 <> g_REG_SPINE_LOOKUP_NAME then
        if p_pcv_information2 is null or p_pcv_information4 is null then
            fnd_message.set_name('PQP', 'PQP_230241_ENTER_MAPPING');
            fnd_message.set_token('DCSF_CODE', 'DCSF Regional Spine Code');
            fnd_message.set_token('LOOKUP_NAME', g_REG_SPINE_LOOKUP_NAME);
            fnd_message.raise_error;
        end if;
    end if;

    -- 3) If Segment End Value is provided
    --    Then Segment Start Value should not be less than Segment End Value
    if p_pcv_information1 <> g_REG_SPINE_LOOKUP_NAME then
        if p_pcv_information3 is not null then
            if p_pcv_information3 < p_pcv_information2 then
                fnd_message.set_name('PQP', 'PQP_230242_WRONG_END_VAL');
                fnd_message.set_token('TYPE', 'Segment');
                fnd_message.raise_error;
            end if;
        end if ;


        -- 4) While creating multiple configuration records for this oconfiguration type
        --    user should not be able to map same segment value twice
        pqp_gb_swf_validations.chk_range_unique_mapping(
                               p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                             , p_pcv_information_category => p_pcv_information_category
                             , p_information_start_column => 'PCV_INFORMATION2'
                             , p_information_end_column => 'PCV_INFORMATION3'
                             , p_value_start => p_pcv_information2
                             , p_value_end => p_pcv_information3
                             , p_return => p_return);
        if (p_return = false) then
                fnd_message.set_name('PQP', 'PQP_230244_DUP_RANGE_MAP');
                fnd_message.raise_error;
        end if ;
    else
        -- seeded lookup used
        -- check if there already exists a row with seeded lookup
        -- then raise error saying mapping already defined
        begin
            select 1
            into l_count
            from pqp_configuration_values
            where pcv_information_category = p_pcv_information_category
              and business_group_id = p_business_group_id
              and (p_configuration_value_id is null
                   or  configuration_value_id <> p_configuration_value_id)
              and pcv_information1 = p_pcv_information1 ;
        exception
           when others then
              null ;
        end;

        if l_count is not null then
            fnd_message.set_name('PQP', 'PQP_230240_DUPLICATE_MAPPING');
            fnd_message.raise_error;
        end if;
    end if ;
    --
end chk_regional_spine_map_grade ;


------------
-- School Workforce Census- Regional Spine mapping with PayScale Validation
-- p_pcv_information1 => Pay Scale Name
-- p_pcv_information2 => Spine Point Start Value
-- p_pcv_information3 => Spine Point End Value
-- p_pcv_information4 => DCSF Regional Spine Code
-----------
procedure chk_regional_spine_map_pyscl(p_configuration_value_id in number
                             , p_business_group_id in number
                         , p_pcv_information_category in varchar2
                         , p_pcv_information1 in varchar2
                         , p_pcv_information2 in varchar2
                         , p_pcv_information3 in varchar2
                         , p_pcv_information4 in varchar2
                         ) as
p_return boolean ;
l_field_name varchar2(50);
begin
    -- 1) If Spine Point End Value is provided
    --    Then Spine Point Start Value should not be less than Spine Point End Value
    if p_pcv_information3 is not null then
        if p_pcv_information3 < p_pcv_information2 then
            fnd_message.set_name('PQP', 'PQP_230242_WRONG_END_VAL');
            fnd_message.set_token('TYPE', 'Spine Point');
            fnd_message.raise_error;
        end if;
    end if ;

    -- 2) While creating multiple configuration records for this oconfiguration type
    --    user should not be able to map same spine point value twice
    pqp_gb_swf_validations.chk_spine_pt_unique_mapping(
                               p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                             , p_pcv_information_category => p_pcv_information_category
                             , p_payscale_column => 'PCV_INFORMATION1'
                             , p_information_start_column => 'PCV_INFORMATION2'
                             , p_information_end_column => 'PCV_INFORMATION3'
                             , p_payscale_value => p_pcv_information1
                             , p_value_start => p_pcv_information2
                             , p_value_end => p_pcv_information3
                             , p_return => p_return);

    if (p_return = false) then
            fnd_message.set_name('PQP', 'PQP_230249_DUP_SPINE_MAP');
            fnd_message.raise_error;
    end if ;
    --
end chk_regional_spine_map_pyscl ;


------------
-- School Workforce Census- Spine Point Validation
-- p_pcv_information1 => User Pay Scale
-- p_pcv_information2 => User Spine Point Value
-- p_pcv_information3 => DCSF Spine Point Value
-----------
procedure chk_spine_point_mapping(p_configuration_value_id in number
                             , p_business_group_id in number
                           , p_pcv_information_category in varchar2
                           , p_pcv_information1 in varchar2
                           , p_pcv_information2 in varchar2
                           , p_pcv_information3 in varchar2
                              ) as
p_return boolean;
begin
    -- If the given user spine point is already mapped
    -- then user should not be able to map it again
    pqp_gb_swf_validations.chk_single_unique_mapping(
                               p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                             , p_pcv_information_category => p_pcv_information_category
                             , p_information_column => 'PCV_INFORMATION2'
                             , p_value => p_pcv_information2
                             , p_return => p_return);
    if (p_return = false) then
            fnd_message.set_name('PQP', 'PQP_230239_DUPLICATE_MAPPING');
            fnd_message.set_token('VALUE', 'Spine Point Value');
            fnd_message.set_token('DCSF_CODE', 'DCSF Spine Point Code');
            fnd_message.raise_error;
    end if ;

  --
end chk_spine_point_mapping ;


------------
-- School Workforce Census- Absence Code Validation
-- p_pcv_information1 => Source ( Absence Type/category/reason)
-- p_pcv_information3 => Absence Category/Reason Value
-- p_pcv_information4 => Absence Type Value
-- p_pcv_information5 => DCSF Absence Category
-----------
procedure chk_absence_code_mapping(p_configuration_value_id in number
                             , p_business_group_id in number
                           , p_pcv_information_category in varchar2
                           , p_pcv_information1 in varchar2
                           , p_pcv_information3 in varchar2
                           , p_pcv_information4 in varchar2
                           , p_pcv_information5 in varchar2
                              ) as
p_return boolean;
l_information_column varchar2(50);
l_value varchar2(50);
l_message_token varchar2(50);
begin
    -- 1) While creating multiple configuration records for this oconfiguration type
    --    user should not be able to create records with different source names
    pqp_gb_swf_validations.chk_unique_lookup_name(
                             p_configuration_value_id => p_configuration_value_id
                           , p_business_group_id => p_business_group_id
                           , p_pcv_information_category => p_pcv_information_category
                           , p_information_column => 'PCV_INFORMATION1'
                           , p_value => p_pcv_information1
                           , p_return => p_return);
    if (p_return = false) then
        fnd_message.set_name('PQP', 'PQP_230245_USE_SAME_SOURCE');
        fnd_message.raise_error;
    end if ;


    -- 2) If Absence Category/Reason is selected as source
    --    Then Absence Category/Reason Value must be provided
    if p_pcv_information1 = 'ABSENCE_CATEGORY' and p_pcv_information3 is null then
        fnd_message.set_name('PQP', 'PQP_230238_FIELD_MANDATORY');
        fnd_message.set_token('FIELD', 'Absence Category/Reason Value');
        fnd_message.set_token('SOURCE', 'Absence Category');
        fnd_message.raise_error;
    elsif p_pcv_information1 = 'ABSENCE_REASON' and p_pcv_information3 is null then
        fnd_message.set_name('PQP', 'PQP_230238_FIELD_MANDATORY');
        fnd_message.set_token('FIELD', 'Absence Category/Reason Value');
        fnd_message.set_token('SOURCE', 'Absence Reason');
        fnd_message.raise_error;
    end if ;

    -- 3) If Absence Type is selected as source
    --    Then Absence Type Value must be provided
    if p_pcv_information1 = 'ABSENCE_TYPE' and p_pcv_information4 is null then
        fnd_message.set_name('PQP', 'PQP_230238_FIELD_MANDATORY');
        fnd_message.set_token('FIELD', 'Absence Type Value');
        fnd_message.set_token('SOURCE', 'Absence Type');
        fnd_message.raise_error;
    end if ;

    -- 4) If the given user Absence Category/Type/reason value is already mapped
    --    then user should not be able to map it again
    if p_pcv_information1 = 'ABSENCE_CATEGORY' then
        l_information_column := 'PCV_INFORMATION3' ;
        l_value := p_pcv_information3;
        l_message_token := 'Absence Category Value';
    elsif p_pcv_information1 = 'ABSENCE_REASON' then
        l_information_column := 'PCV_INFORMATION3' ;
        l_value := p_pcv_information3;
        l_message_token := 'Absence Reason Value';
    elsif p_pcv_information1 = 'ABSENCE_TYPE' then
        l_information_column := 'PCV_INFORMATION4' ;
        l_value := p_pcv_information4;
        l_message_token := 'Absence Type Value';
    end if ;

    pqp_gb_swf_validations.chk_single_unique_mapping(
                               p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                             , p_pcv_information_category => p_pcv_information_category
                             , p_information_column => l_information_column
                             , p_value => l_value
                             , p_return => p_return);
    if (p_return = false) then
        fnd_message.set_name('PQP', 'PQP_230239_DUPLICATE_MAPPING');
        fnd_message.set_token('VALUE', l_message_token);
        fnd_message.set_token('DCSF_CODE', 'DCSF Absence category');
        fnd_message.raise_error;
    end if ;

  --
end chk_absence_code_mapping ;

------------
-- School Workforce Census- Qualification Code Validation
-- p_pcv_information1 => Source ( Qualification Type/category)
-- p_pcv_information3 => Qualification Category Value
-- p_pcv_information4 => Qualification Type Value
-- p_pcv_information5 => DCSF Qualification Code
-----------
procedure chk_qualification_code_map(p_configuration_value_id in number
                             , p_business_group_id in number
                           , p_pcv_information_category in varchar2
                           , p_pcv_information1 in varchar2
                           , p_pcv_information3 in varchar2
                           , p_pcv_information4 in varchar2
                           , p_pcv_information5 in varchar2
                              ) as
p_return boolean;
l_information_column varchar2(50);
l_value varchar2(50);
l_message_token varchar2(50);
begin
    -- 1) While creating multiple configuration records for this oconfiguration type
    --    user should not be able to create records with different source names
    pqp_gb_swf_validations.chk_unique_lookup_name(
                             p_configuration_value_id => p_configuration_value_id
                           , p_business_group_id => p_business_group_id
                           , p_pcv_information_category => p_pcv_information_category
                           , p_information_column => 'PCV_INFORMATION1'
                           , p_value => p_pcv_information1
                           , p_return => p_return);
    if (p_return = false) then
        fnd_message.set_name('PQP', 'PQP_230245_USE_SAME_SOURCE');
        fnd_message.raise_error;
    end if ;


    -- 2) If Qualification Category is selected as source
    --    Then Qualification Category Value must be provided
    if p_pcv_information1 = 'QUALIFICATION_CATEGORY' and p_pcv_information3 is null then
        fnd_message.set_name('PQP', 'PQP_230238_FIELD_MANDATORY');
        fnd_message.set_token('FIELD', 'Qualification Category Value');
        fnd_message.set_token('SOURCE', 'Qualification Category');
        fnd_message.raise_error;
    end if ;

    -- 3) If Qualification Type is selected as source
    --    Then Qualification Type Value must be provided
    if p_pcv_information1 = 'QUALIFICATION_TYPE' and p_pcv_information4 is null then
        fnd_message.set_name('PQP', 'PQP_230238_FIELD_MANDATORY');
        fnd_message.set_token('FIELD', 'Qualification Type Value');
        fnd_message.set_token('SOURCE', 'Qualification Type');
        fnd_message.raise_error;
    end if ;

    -- 4) If the given user Qualification Category/Type value is already mapped
    --    then user should not be able to map it again
    if p_pcv_information1 = 'QUALIFICATION_CATEGORY' then
        l_information_column := 'PCV_INFORMATION3' ;
        l_value := p_pcv_information3;
        l_message_token := 'Qualification Category Value';
    elsif p_pcv_information1 = 'QUALIFICATION_TYPE' then
        l_information_column := 'PCV_INFORMATION4' ;
        l_value := p_pcv_information4;
        l_message_token := 'Qualification Type Value';
    end if ;

    pqp_gb_swf_validations.chk_single_unique_mapping(
                               p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                             , p_pcv_information_category => p_pcv_information_category
                             , p_information_column => l_information_column
                             , p_value => l_value
                             , p_return => p_return);
    if (p_return = false) then
        fnd_message.set_name('PQP', 'PQP_230239_DUPLICATE_MAPPING');
        fnd_message.set_token('VALUE', l_message_token);
        fnd_message.set_token('DCSF_CODE', 'DCSF Qualification Code');
        fnd_message.raise_error;
    end if ;

  --
end chk_qualification_code_map ;

------------
-- School Workforce Census- Subject Code Validation
-- p_pcv_information1 => User Subject Value
-- p_pcv_information2 => DCSF Subject Code
-----------
procedure chk_subject_code_map(p_configuration_value_id in number
                             , p_business_group_id in number
                          , p_pcv_information_category in varchar2
                          , p_pcv_information1 in varchar2
                          , p_pcv_information2 in varchar2
                           ) as
p_return boolean ;
begin
    -- If the given user subject code is already mapped
    -- then user should not be able to map it again
    pqp_gb_swf_validations.chk_single_unique_mapping(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                             , p_pcv_information_category => p_pcv_information_category
                             , p_information_column => 'PCV_INFORMATION1'
                             , p_value => p_pcv_information1
                             , p_return => p_return);
    if (p_return = false) then
        fnd_message.set_name('PQP', 'PQP_230239_DUPLICATE_MAPPING');
        fnd_message.set_token('VALUE', 'Subject Code');
        fnd_message.set_token('DCSF_CODE', 'DCSF Subject Code');
        fnd_message.raise_error;
    end if ;
  --
end chk_subject_code_map ;

------------
-- School Workforce Census- Hours Validation
-- p_pcv_information1 => Source (Assignemnt, PQP Contract Type)
-- p_pcv_information2 => Contract Type
-- p_pcv_information3 => Hours per Week column
-- p_pcv_information4 => Weeks per Year Column
-- p_pcv_information5 => Staff Category
-- p_pcv_information6 => Default Weeks per Year
-----------
procedure chk_hours(p_configuration_value_id in number
                          , p_business_group_id in number
                          , p_pcv_information_category in varchar2
                          , p_pcv_information1 in varchar2
                          , p_pcv_information2 in varchar2
                          , p_pcv_information3 in varchar2
                          , p_pcv_information4 in varchar2
                          , p_pcv_information5 in varchar2
                          , p_pcv_information6 in varchar2
                          , p_pcv_information7 in varchar2
                          , p_pcv_information8 in varchar2
                          ) as
p_return boolean;
begin
    -- 1) While creating multiple configuration records for this oconfiguration type
    --    user should not be able to create records with different source names
    pqp_gb_swf_validations.chk_unique_lookup_name(
                             p_configuration_value_id => p_configuration_value_id
                           , p_business_group_id => p_business_group_id
                           , p_pcv_information_category => p_pcv_information_category
                           , p_information_column => 'PCV_INFORMATION1'
                           , p_value => p_pcv_information1
                           , p_return => p_return);
    if (p_return = false) then
        fnd_message.set_name('PQP', 'PQP_230245_USE_SAME_SOURCE');
        fnd_message.raise_error;
    end if ;

    -- 2) Check for mandatory columns as per selected source columns
    if p_pcv_information1 = 'CONTRACT_TYPE' then
        if p_pcv_information3 is null then
            fnd_message.set_name('PQP', 'PQP_230238_FIELD_MANDATORY');
            fnd_message.set_token('FIELD', 'Hours Per Week formula name');
            fnd_message.set_token('SOURCE', 'PQP Contract Type');
            fnd_message.raise_error;
        elsif p_pcv_information4 is null then
            fnd_message.set_name('PQP', 'PQP_230238_FIELD_MANDATORY');
            fnd_message.set_token('FIELD', 'Weeks Per Year source');
            fnd_message.set_token('SOURCE', 'PQP Contract Type');
            fnd_message.raise_error;
        end if;

        if p_pcv_information4 = 'FORMULA' then
            if p_pcv_information5 is null then
                fnd_message.set_name('PQP', 'PQP_230238_FIELD_MANDATORY');
                fnd_message.set_token('FIELD', 'Weeks Per Year formula name');
                fnd_message.set_token('SOURCE', 'PQP Contract Type');
                fnd_message.raise_error;
             end if;
        else
            if p_pcv_information6 is null then
                fnd_message.set_name('PQP', 'PQP_230238_FIELD_MANDATORY');
                fnd_message.set_token('FIELD', 'Weeks Per Year column name');
                fnd_message.set_token('SOURCE', 'PQP Contract Type');
                fnd_message.raise_error;
             end if ;
        end if ;
    elsif p_pcv_information1 = 'ASG' then
        if p_pcv_information7 is null then
            fnd_message.set_name('PQP', 'PQP_230238_FIELD_MANDATORY');
            fnd_message.set_token('FIELD', 'Staff Category');
            fnd_message.set_token('SOURCE', 'Assignment Hours');
            fnd_message.raise_error;
        elsif p_pcv_information8 is null then
            fnd_message.set_name('PQP', 'PQP_230238_FIELD_MANDATORY');
            fnd_message.set_token('FIELD', 'Default Weeks Per Year');
            fnd_message.set_token('SOURCE', 'Assignment Hours');
            fnd_message.raise_error;
        end if;
    end if ;

    -- 3) When source is PQP Contract Types, then user should not be able to map
    --    same contract type twice
    if p_pcv_information1 = 'CONTRACT_TYPE' then
        pqp_gb_swf_validations.chk_hours_cntrct_tp_unq_map(
                               p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                             , p_pcv_information_category => p_pcv_information_category
                             , p_information_column => 'PCV_INFORMATION2'
                             , p_value => p_pcv_information2
                             , p_return => p_return);
        if (p_return = false) then
            fnd_message.set_name('PQP', 'PQP_230239_DUPLICATE_MAPPING');
            fnd_message.set_token('VALUE', 'Contract Type');
            fnd_message.set_token('DCSF_CODE', 'PQP_CONTRACT_TYPES UDT Column Name');
            fnd_message.raise_error;
        end if ;
    end if ;

    -- 4) When source is Assignment Hours, then user should not be able to map
    --    same Staff Category twice
    pqp_gb_swf_validations.chk_single_unique_mapping(
                               p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                             , p_pcv_information_category => p_pcv_information_category
                             , p_information_column => 'PCV_INFORMATION7'
                             , p_value => p_pcv_information7
                             , p_return => p_return);
    if (p_return = false) then
        fnd_message.set_name('PQP', 'PQP_230239_DUPLICATE_MAPPING');
        fnd_message.set_token('VALUE', 'Staff Category');
        fnd_message.set_token('DCSF_CODE', 'Default Weeks Per Year Value');
        fnd_message.raise_error;
    end if ;
end chk_hours;


------------
-- School Workforce Census- FTE Hours Validation
-- p_pcv_information1 => Source (Assignment - Budget FTE Value, Calculated)
-- p_pcv_information2 => User formula name
-----------
procedure chk_fte_hours(p_configuration_value_id in number
                          , p_business_group_id in number
                          , p_pcv_information_category in varchar2
                          , p_pcv_information1 in varchar2
                          , p_pcv_information2 in varchar2
                          ) as
begin
    if p_pcv_information1 = 'CAL' and p_pcv_information2 is null then
            fnd_message.set_name('PQP', 'PQP_230238_FIELD_MANDATORY');
            fnd_message.set_token('FIELD', 'User Formula Name');
            fnd_message.set_token('SOURCE', 'Calculated');
            fnd_message.raise_error;
    end if ;
    --
end chk_fte_hours;
--

PROCEDURE  create_configuration_value_bp
                  (p_configuration_value_id         in     number
                  ,p_effective_date                 in     date
                  ,p_business_group_id              in     number
                  ,p_legislation_code               in     varchar2
                  ,p_pcv_information_category       in     varchar2
                  ,p_pcv_information1               in     varchar2
                  ,p_pcv_information2               in     varchar2
                  ,p_pcv_information3               in     varchar2
                  ,p_pcv_information4               in     varchar2
                  ,p_pcv_information5               in     varchar2
                  ,p_pcv_information6               in     varchar2
                  ,p_pcv_information7               in     varchar2
                  ,p_pcv_information8               in     varchar2
                  ,p_pcv_information9               in     varchar2
                  ,p_pcv_information10              in     varchar2
                  ,p_pcv_information11              in     varchar2
                  ,p_pcv_information12              in     varchar2
                  ,p_pcv_information13              in     varchar2
                  ,p_pcv_information14              in     varchar2
                  ,p_pcv_information15              in     varchar2
                  ,p_pcv_information16              in     varchar2
                  ,p_pcv_information17              in     varchar2
                  ,p_pcv_information18              in     varchar2
                  ,p_pcv_information19              in     varchar2
                  ,p_pcv_information20              in     varchar2
                  ,p_configuration_name             in     varchar2

                   ) as

l_proc  varchar2(56);
p_return boolean ;
l_count number;
l_role_source varchar2(100);
BEGIN
   l_proc:='PQP_GB_CONFIGURATION_VALUE.CREATE_CONFIGURATION_VALUE_BP';

   if g_debug is null then
      g_debug :=  Hr_utility.debug_enabled;
   end if;

   if g_debug then
      hr_utility.set_location('Entering:'||l_proc,10);
   end if;

  /* Create private procedures to validate
     pcv_information_category you are interested in */

--    hr_utility.trace_on(null,'CNFTRC');
    case (p_pcv_information_category)
      when 'PQP_GB_PENSERV_SCHEME_MAP_INFO'then
            chk_pension_scheme_mapping(p_pcv_information2 =>p_pcv_information2 --Penserv Scheme
                                      ,p_pcv_information3 =>p_pcv_information3 --Partner Scheme
                                      );
      when 'PQP_GB_SWF_TEACHER_NUM' then
            chk_teacher_number(p_configuration_value_id => p_configuration_value_id
                             , p_pcv_information1 => p_pcv_information1
                             , p_pcv_information3 => p_pcv_information3
                             , p_pcv_information4 => p_pcv_information4
                              );
      when 'PQP_GB_SWF_ETHNIC_CODES' then
            chk_ethnic_origin(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                            , p_pcv_information_category => p_pcv_information_category
                            , p_pcv_information1 => p_pcv_information1
                             );
      when 'PQP_GB_SWF_QTS_MAPPING' then
            chk_qts_mapping(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information2 => p_pcv_information2
                          , p_pcv_information3 => p_pcv_information3
                          , p_pcv_information4 => p_pcv_information4
                           );
      when 'PQP_GB_SWF_QTS_ROUTE_MAPPING' then
            chk_qts_mapping(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information2 => p_pcv_information2
                          , p_pcv_information3 => p_pcv_information3
                          , p_pcv_information4 => p_pcv_information4
                           );
      when 'PQP_GB_SWF_HLTA_STATUS_SRC' then
            chk_hlta_source(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information3 => p_pcv_information3
                          , p_pcv_information4 => p_pcv_information4
                          , p_pcv_information5 => p_pcv_information5
                          );
      when 'PQP_GB_SWF_HLTA_STATUS_MAPPING' then
            chk_hlta_mapping(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information2 => p_pcv_information2
                          , p_pcv_information3 => p_pcv_information3
                          );
      when 'PQP_GB_SWF_CNTRT_ARRIVAL_DATE' then
            chk_arrival_date(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information2 => p_pcv_information2
                          );
      when 'PQP_GB_SWF_CONTRACT_TYPE' then
            chk_contract_type(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information3 => p_pcv_information3
                          , p_pcv_information4 => p_pcv_information4
                          , p_pcv_information5 => p_pcv_information5
                          );
      when 'PQP_GB_SWF_ORIGIN_MAPPING' then
            chk_origin_mapping(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                            , p_pcv_information_category => p_pcv_information_category
                            , p_pcv_information1 => p_pcv_information1
                            , p_pcv_information2 => p_pcv_information2
                            , p_pcv_information3 => p_pcv_information3
                             );
      when 'PQP_GB_SWF_DESTINATION_MAPPING' then
            chk_destination_mapping(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                            , p_pcv_information_category => p_pcv_information_category
                            , p_pcv_information1 => p_pcv_information1
                            , p_pcv_information2 => p_pcv_information2
                            , p_pcv_information3 => p_pcv_information3
                             );
      when 'PQP_GB_SWF_ROLE_SOURCE' then
            chk_role_post_source(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                            , p_pcv_information_category => p_pcv_information_category
                            , p_pcv_information1 => p_pcv_information1
                            , p_pcv_information3 => p_pcv_information3
                             );
      when 'PQP_GB_SWF_ROLE_MAPPING' then
            chk_role_post_mapping(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information2 => p_pcv_information2
                          , p_pcv_information3 => p_pcv_information3
                          , p_pcv_information4 => p_pcv_information4
                          ) ;
      when 'PQP_GB_SWF_POST_SOURCE' then
            chk_role_post_source(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                            , p_pcv_information_category => p_pcv_information_category
                            , p_pcv_information1 => p_pcv_information1
                            , p_pcv_information3 => p_pcv_information3
                             );
      when 'PQP_GB_SWF_POST_MAPPING' then
            chk_role_post_mapping(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information2 => p_pcv_information2
                          , p_pcv_information3 => p_pcv_information3
                          , p_pcv_information4 => p_pcv_information4
                          ) ;
      when 'PQP_GB_SWF_HOURS' then
            chk_hours(p_configuration_value_id => p_configuration_value_id
                          , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information2 => p_pcv_information2
                          , p_pcv_information3 => p_pcv_information3
                          , p_pcv_information4 => p_pcv_information4
                          , p_pcv_information5 => p_pcv_information5
                          , p_pcv_information6 => p_pcv_information6
                          , p_pcv_information7 => p_pcv_information7
                          , p_pcv_information8 => p_pcv_information8
                          ) ;
      when 'PQP_GB_SWF_FTE_HOURS' then
            chk_fte_hours(p_configuration_value_id => p_configuration_value_id
                          , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information2 => p_pcv_information2
                          ) ;
      when 'PQP_GB_SWF_PAY_SCALE_MAPPING' then
            chk_payscale_mapping(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information2 => p_pcv_information2
                          ) ;
      when 'PQP_GB_SWF_REG_SPINE_SRC' then
            chk_regional_spine_source(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information2 => p_pcv_information2
                          , p_pcv_information3 => p_pcv_information3
                          ) ;
      when 'PQP_GB_SWF_REG_SPINE_MAP_GRD' then
            chk_regional_spine_map_grade(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information2 => p_pcv_information2
                          , p_pcv_information3 => p_pcv_information3
                          , p_pcv_information4 => p_pcv_information4
                          ) ;
      when 'PQP_GB_SWF_REG_SPINE_MAP_PYSCL' then
            chk_regional_spine_map_pyscl(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information2 => p_pcv_information2
                          , p_pcv_information3 => p_pcv_information3
                          , p_pcv_information4 => p_pcv_information4
                          ) ;
      when 'PQP_GB_SWF_SPINE_POINT_MAPPING' then
            chk_spine_point_mapping(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information2 => p_pcv_information2
                          , p_pcv_information3 => p_pcv_information3
                          ) ;
      when 'PQP_GB_SWF_ABSENCE_CODE' then
            chk_absence_code_mapping(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information3 => p_pcv_information3
                          , p_pcv_information4 => p_pcv_information4
                          , p_pcv_information5 => p_pcv_information5
                          ) ;
      when 'PQP_GB_SWF_QUAL_CODE_MAP' then
            chk_qualification_code_map(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information3 => p_pcv_information3
                          , p_pcv_information4 => p_pcv_information4
                          , p_pcv_information5 => p_pcv_information5
                          ) ;
      when 'PQP_GB_SWF_QUAL_SUBJECT_MAP' then
            chk_subject_code_map(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information2 => p_pcv_information2
                          ) ;
      else
              null;
      end case;


    if g_debug then
      hr_utility.set_location('Leaving:'||l_proc,20);
    end if;

END;

procedure update_configuration_value_bp
                  (p_configuration_value_id         in     number
                  ,p_effective_date                 in     date
                  ,p_business_group_id              in     number
                  ,p_legislation_code               in     varchar2
                  ,p_pcv_information_category       in     varchar2
                  ,p_pcv_information1               in     varchar2
                  ,p_pcv_information2               in     varchar2
                  ,p_pcv_information3               in     varchar2
                  ,p_pcv_information4               in     varchar2
                  ,p_pcv_information5               in     varchar2
                  ,p_pcv_information6               in     varchar2
                  ,p_pcv_information7               in     varchar2
                  ,p_pcv_information8               in     varchar2
                  ,p_pcv_information9               in     varchar2
                  ,p_pcv_information10              in     varchar2
                  ,p_pcv_information11              in     varchar2
                  ,p_pcv_information12              in     varchar2
                  ,p_pcv_information13              in     varchar2
                  ,p_pcv_information14              in     varchar2
                  ,p_pcv_information15              in     varchar2
                  ,p_pcv_information16              in     varchar2
                  ,p_pcv_information17              in     varchar2
                  ,p_pcv_information18              in     varchar2
                  ,p_pcv_information19              in     varchar2
                  ,p_pcv_information20              in     varchar2
                  ,p_object_version_number          in     number
                  ,p_configuration_name             in     varchar2
                   )as
l_proc  varchar2(56);
p_return boolean ;
l_count number;
l_role_source varchar2(100);
BEGIN
   if g_debug is null then
        g_debug :=  Hr_utility.debug_enabled;
   end if;
  l_proc:='PQP_GB_CONFIGURATION_VALUE.UPDATE_CONFIGURATION_VALUE_BP';

 if g_debug then
      hr_utility.set_location('Entering:'||l_proc,10);
   end if;


  /* Create private procedures to validate
     pcv_information_category you are interested in */

    case (p_pcv_information_category)
      when 'PQP_GB_PENSERV_SCHEME_MAP_INFO'then
            chk_pension_scheme_mapping(p_pcv_information2 =>p_pcv_information2 --Penserv Scheme
                                      ,p_pcv_information3 =>p_pcv_information3 --Partner Scheme
                                      );
      when 'PQP_GB_SWF_TEACHER_NUM' then
            chk_teacher_number(p_configuration_value_id => p_configuration_value_id
                             , p_pcv_information1 => p_pcv_information1
                             , p_pcv_information3 => p_pcv_information3
                             , p_pcv_information4 => p_pcv_information4
                              );
      when 'PQP_GB_SWF_ETHNIC_CODES' then
            chk_ethnic_origin(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                            , p_pcv_information_category => p_pcv_information_category
                            , p_pcv_information1 => p_pcv_information1
                             );
      when 'PQP_GB_SWF_QTS_MAPPING' then
            chk_qts_mapping(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information2 => p_pcv_information2
                          , p_pcv_information3 => p_pcv_information3
                          , p_pcv_information4 => p_pcv_information4
                           );
      when 'PQP_GB_SWF_QTS_ROUTE_MAPPING' then
            chk_qts_mapping(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information2 => p_pcv_information2
                          , p_pcv_information3 => p_pcv_information3
                          , p_pcv_information4 => p_pcv_information4
                           );
      when 'PQP_GB_SWF_HLTA_STATUS_SRC' then
            chk_hlta_source(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information3 => p_pcv_information3
                          , p_pcv_information4 => p_pcv_information4
                          , p_pcv_information5 => p_pcv_information5
                          );
      when 'PQP_GB_SWF_HLTA_STATUS_MAPPING' then
            chk_hlta_mapping(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information2 => p_pcv_information2
                          , p_pcv_information3 => p_pcv_information3
                          );
      when 'PQP_GB_SWF_CNTRT_ARRIVAL_DATE' then
            chk_arrival_date(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information2 => p_pcv_information2
                          );
      when 'PQP_GB_SWF_CONTRACT_TYPE' then
            chk_contract_type(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information3 => p_pcv_information3
                          , p_pcv_information4 => p_pcv_information4
                          , p_pcv_information5 => p_pcv_information5
                          );
      when 'PQP_GB_SWF_ORIGIN_MAPPING' then
            chk_origin_mapping(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                            , p_pcv_information_category => p_pcv_information_category
                            , p_pcv_information1 => p_pcv_information1
                            , p_pcv_information2 => p_pcv_information2
                            , p_pcv_information3 => p_pcv_information3
                             );
      when 'PQP_GB_SWF_DESTINATION_MAPPING' then
            chk_origin_mapping(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                            , p_pcv_information_category => p_pcv_information_category
                            , p_pcv_information1 => p_pcv_information1
                            , p_pcv_information2 => p_pcv_information2
                            , p_pcv_information3 => p_pcv_information3
                             );
      when 'PQP_GB_SWF_ROLE_SOURCE' then
            chk_role_post_source(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                            , p_pcv_information_category => p_pcv_information_category
                            , p_pcv_information1 => p_pcv_information1
                            , p_pcv_information3 => p_pcv_information3
                             );
      when 'PQP_GB_SWF_ROLE_MAPPING' then
            chk_role_post_mapping(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information2 => p_pcv_information2
                          , p_pcv_information3 => p_pcv_information3
                          , p_pcv_information4 => p_pcv_information4
                          ) ;
      when 'PQP_GB_SWF_POST_SOURCE' then
            chk_role_post_source(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                            , p_pcv_information_category => p_pcv_information_category
                            , p_pcv_information1 => p_pcv_information1
                            , p_pcv_information3 => p_pcv_information3
                             );
      when 'PQP_GB_SWF_POST_MAPPING' then
            chk_role_post_mapping(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information2 => p_pcv_information2
                          , p_pcv_information3 => p_pcv_information3
                          , p_pcv_information4 => p_pcv_information4
                          ) ;
      when 'PQP_GB_SWF_HOURS' then
            chk_hours(p_configuration_value_id => p_configuration_value_id
                          , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information2 => p_pcv_information2
                          , p_pcv_information3 => p_pcv_information3
                          , p_pcv_information4 => p_pcv_information4
                          , p_pcv_information5 => p_pcv_information5
                          , p_pcv_information6 => p_pcv_information6
                          , p_pcv_information7 => p_pcv_information7
                          , p_pcv_information8 => p_pcv_information8
                          ) ;
      when 'PQP_GB_SWF_FTE_HOURS' then
            chk_fte_hours(p_configuration_value_id => p_configuration_value_id
                          , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information2 => p_pcv_information2
                          ) ;
      when 'PQP_GB_SWF_PAY_SCALE_MAPPING' then
            chk_payscale_mapping(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information2 => p_pcv_information2
                          ) ;
      when 'PQP_GB_SWF_REG_SPINE_SRC' then
            chk_regional_spine_source(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information2 => p_pcv_information2
                          , p_pcv_information3 => p_pcv_information3
                          ) ;
      when 'PQP_GB_SWF_REG_SPINE_MAP_GRD' then
            chk_regional_spine_map_grade(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information2 => p_pcv_information2
                          , p_pcv_information3 => p_pcv_information3
                          , p_pcv_information4 => p_pcv_information4
                          ) ;
      when 'PQP_GB_SWF_REG_SPINE_MAP_PYSCL' then
            chk_regional_spine_map_pyscl(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information2 => p_pcv_information2
                          , p_pcv_information3 => p_pcv_information3
                          , p_pcv_information4 => p_pcv_information4
                          ) ;
      when 'PQP_GB_SWF_SPINE_POINT_MAPPING' then
            chk_spine_point_mapping(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information2 => p_pcv_information2
                          , p_pcv_information3 => p_pcv_information3
                          ) ;
      when 'PQP_GB_SWF_ABSENCE_CODE' then
            chk_absence_code_mapping(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information3 => p_pcv_information3
                          , p_pcv_information4 => p_pcv_information4
                          , p_pcv_information5 => p_pcv_information5
                          ) ;
      when 'PQP_GB_SWF_QUAL_CODE_MAP' then
            chk_qualification_code_map(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information3 => p_pcv_information3
                          , p_pcv_information4 => p_pcv_information4
                          , p_pcv_information5 => p_pcv_information5
                          ) ;
      when 'PQP_GB_SWF_QUAL_SUBJECT_MAP' then
            chk_subject_code_map(p_configuration_value_id => p_configuration_value_id
                             , p_business_group_id => p_business_group_id
                          , p_pcv_information_category => p_pcv_information_category
                          , p_pcv_information1 => p_pcv_information1
                          , p_pcv_information2 => p_pcv_information2
                          ) ;
      else
            null;
      end case;


    if g_debug then
      hr_utility.set_location('Leaving:'||l_proc,20);
    end if;

END;
END PQP_GB_CONFIGURATION_VALUE;


/
