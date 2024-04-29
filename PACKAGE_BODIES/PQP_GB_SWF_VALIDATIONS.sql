--------------------------------------------------------
--  DDL for Package Body PQP_GB_SWF_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PQP_GB_SWF_VALIDATIONS" AS
/* $Header: pqpgbswfv.pkb 120.0.12010000.1 2009/12/07 10:04:16 parusia noship $ */
/* Copyright (c) Oracle Corporation 2005. All rights reserved. */
/*
   PRODUCT
      Oracle Public Sector Payroll - GB Localisation School Workforce

   NAME
      PQP_GB_SWF_VALIDATIONS package

   DESCRIPTION
      This package contains utility functions for School Workforce
      configuration setup validation.

   MODIFICATION HISTORY
   Person    Date       Version        Bug     Comments
   --------- ---------- -------------- ------- --------------------------------
   P Arusia  8-Jul-2009 115.0          8682922 This package contains utility
                                               functions for School Workforce
					       configuration setup validation
 */

-------------------------------------------------------------------------------
--                               PACKAGE BODY                                --
-------------------------------------------------------------------------------

     function get_lookup_meaning (p_lookup_type varchar2
                                , p_code        varchar2)
        return varchar2 is
           cursor csr_lookup_meaning is
                select meaning
                from hr_lookups
                where lookup_type = p_lookup_type
                  and lookup_code = p_code ;
            l_meaning varchar2(100);
     begin
            open csr_lookup_meaning;
            fetch csr_lookup_meaning into l_meaning ;
            close csr_lookup_meaning ;

            return l_meaning ;

     end  get_lookup_meaning ;


     --
     /* procedure to verify that an application information value should not
        be already mapped with any DCSF value.
        Returns true if the value is not already mapped
        Retruns false if the value is already mapped
        */
     --
     procedure chk_single_unique_mapping(p_configuration_value_id number
                    , p_business_group_id                         number
                    , p_pcv_information_category                  varchar2
                    , p_information_column                        varchar2
                    , p_value                                     varchar2
                    , p_return                         out NOCOPY boolean
                    ) as
        l_count number;
        l_query varchar2(4000) ;
        l_value_start_meaning varchar2(100);
        l_value_end_meaning varchar2(100);
      begin
         l_query := 'select count(*)
                     from pqp_configuration_values
                      where pcv_information_category = '''|| p_pcv_information_category || '''' ||
                     '  and business_group_id = ''' || p_business_group_id || '''' ||
                     '  and ' || p_information_column || ' = ''' || p_value || '''' ||
                     '  and ( ' || nvl(to_char(p_configuration_value_id),'null') || ' is null ' ||
                             ' or  configuration_value_id <> ' || nvl(to_char(p_configuration_value_id),'null') || ' )';
         hr_utility.trace('l_query = '|| l_query );

        execute immediate l_query into l_count;

        if l_count > 0 then
            p_return := false  ;
        else
            p_return := true ;
        end if ;
      end chk_single_unique_mapping;

     --
     /* procedure to verify that an application information value should not
        be already mapped with any DCSF value when it is possible to
        map a range of values directly with a DCSF code.
        Returns true if the value is not already mapped
        Retruns false if the value is already mapped
        */
     --
     procedure chk_range_unique_mapping(
                      p_configuration_value_id         number
                    , p_business_group_id              number
                    , p_pcv_information_category       varchar2
                    , p_information_start_column       varchar2
                    , p_information_end_column         varchar2
                    , p_value_start                    varchar2
                    , p_value_end                      varchar2
                    , p_return              out NOCOPY boolean
                    ) as
        l_count number;
        l_query varchar2(4000) ;
        l_value_end varchar2(100);
      begin
        if p_value_end is null then
            l_value_end := p_value_start ;
        else
            l_value_end := p_value_end;
        end if;

        l_query := 'select count(*)
                    from pqp_configuration_values
                    where pcv_information_category = '''|| p_pcv_information_category || '''' ||
                     ' and business_group_id = ''' || p_business_group_id || '''' ||
                     ' and ( ' || p_information_start_column || ' between ''' || p_value_start || '''' ||
                                                                    ' and ''' || l_value_end || ''' ' ||
                              ' or ' || nvl(p_information_end_column, p_information_start_column) ||
                                                                 ' between ''' || p_value_start || '''' ||
                                                                     ' and ''' || l_value_end || ''' ' ||
                              ' or ''' ||  p_value_start || ''' between '|| p_information_start_column ||
                                                                  ' and ' || nvl(p_information_end_column, p_information_start_column) ||
                              ' or ''' ||  l_value_end   || ''' between '|| p_information_start_column ||
                                                                  ' and ' || nvl(p_information_end_column, p_information_start_column) ||
                           ' ) ' ||
                     '  and ( ' || nvl(to_char(p_configuration_value_id),'null') || ' is null ' ||
                             ' or  configuration_value_id <> ' || nvl(to_char(p_configuration_value_id),'null') || ' )';

       hr_utility.trace('l_query = '|| l_query );

        execute immediate l_query into l_count;

        if l_count > 0 then
            p_return := false  ;
        else
            p_return := true ;
        end if ;
      end chk_range_unique_mapping;


     --
     /* procedure to verify that a spine point value should not
        be already mapped with any DCSF value.
        Returns true if the value is not already mapped
        Retruns false if the value is already mapped
        */
     --
      procedure chk_spine_pt_unique_mapping(
                      p_configuration_value_id    number
                    , p_business_group_id         number
                    , p_pcv_information_category  varchar2
                    , p_payscale_column           varchar2
                    , p_information_start_column  varchar2
                    , p_information_end_column    varchar2
                    , p_payscale_value            varchar2
                    , p_value_start               varchar2
                    , p_value_end                 varchar2
                    , p_return         out NOCOPY boolean
                    ) as
        l_count number;
        l_query varchar2(4000) ;
        l_updated_val_end varchar2(100);
        l_updated_val_start varchar2(100);
      begin
        hr_utility.trace('Spine Point mapping -- ');
        if p_value_start is null then
            l_updated_val_start := 'null';
        else
            l_updated_val_start := ''''||p_value_start||'''';
        end if;

        if p_value_end is null then
            l_updated_val_end := l_updated_val_start ;
        else
            l_updated_val_end := ''''||p_value_end||'''';
        end if;

        l_query := 'select count(*)
                    from pqp_configuration_values
                    where pcv_information_category = '''|| p_pcv_information_category || '''' ||
                     ' and business_group_id = ''' || p_business_group_id || '''' ||
                     ' and ' || p_payscale_column || ' = ''' || p_payscale_value || '''' ||
                     ' and ( ' || l_updated_val_start || ' is null ' ||
                              ' or ' || p_information_start_column || ' is null ' ||
                              ' or ' || p_information_start_column || ' between ' || l_updated_val_start ||
                                                                    ' and ' || l_updated_val_end ||
                              ' or ' || nvl(p_information_end_column, p_information_start_column) ||
                                                                 ' between ' || l_updated_val_start ||
                                                                     ' and ' || l_updated_val_end ||
                              ' or ' ||  l_updated_val_start || ' between '|| p_information_start_column ||
                                                                  ' and ' || nvl(p_information_end_column, p_information_start_column) ||
                              ' or ' ||  l_updated_val_end   || ' between '|| p_information_start_column ||
                                                                  ' and ' || nvl(p_information_end_column, p_information_start_column) ||
                           ' ) ' ||
                     '  and ( ' || nvl(to_char(p_configuration_value_id),'null') || ' is null ' ||
                             ' or  configuration_value_id <> ' || nvl(to_char(p_configuration_value_id),'null') || ' )';

       hr_utility.trace('l_query = '|| l_query );

        execute immediate l_query into l_count;

        if l_count > 0 then
            p_return := false  ;
        else
            p_return := true ;
        end if ;
      end chk_spine_pt_unique_mapping;

     --
     /* procedure to verify that a Hours configuration for a contract type
        should not be already done.
        Returns true if the the hours data is NOT already mapped for given contract type
        Retruns false if it is already mapped
        */
     --
      procedure chk_hours_cntrct_tp_unq_map(
                      p_configuration_value_id   number
                    , p_business_group_id        number
                    , p_pcv_information_category varchar2
                    , p_information_column       varchar2
                    , p_value                    varchar2
                    , p_return        out NOCOPY boolean
                    ) as
        l_count number;
        l_query varchar2(4000) ;
        l_updated_val varchar2(50);
      begin
        if p_value is null then
            l_updated_val := 'null';
        else
            l_updated_val := ''''||p_value||'''';
        end if;
        l_query := 'select count(*)
                    from pqp_configuration_values
                    where pcv_information_category = '''|| p_pcv_information_category || '''' ||
                     ' and business_group_id = ''' || p_business_group_id || '''' ||
                     ' and ( ' || l_updated_val || ' is null ' ||
                              ' or ' || p_information_column || ' is null ' ||
                              ' or ' || p_information_column || ' = ' || l_updated_val ||
                           ' ) ' ||
                     '  and ( ' || nvl(to_char(p_configuration_value_id),'null') || ' is null ' ||
                             ' or  configuration_value_id <> ' || nvl(to_char(p_configuration_value_id),'null') || ' )';

       hr_utility.trace('l_query = '|| l_query );

        execute immediate l_query into l_count;

        if l_count > 0 then
            p_return := false  ;
        else
            p_return := true ;
        end if ;
      end chk_hours_cntrct_tp_unq_map;


     /* This procedure returns true, if for the given configuration_type
        only the lookup name mentioned currently is being used. If some other
        lookup name has been used, then it retruns false
     */
     procedure chk_unique_lookup_name(
                      p_configuration_value_id   number
                    , p_business_group_id        number
                    , p_pcv_information_category varchar2
                    , p_information_column       varchar2
                    , p_value                    varchar2
                    , p_return        out NOCOPY boolean
                    )   IS
        l_count number;
        l_query varchar2(4000) ;
      begin
        l_query := 'select count(*)
                   from pqp_configuration_values
                   where pcv_information_category = '''|| p_pcv_information_category || '''' ||
                     ' and business_group_id = ''' || p_business_group_id || '''' ||
                     ' and ' || p_information_column || ' <> ''' || p_value || '''' ||
                     '  and (' || nvl(to_char(p_configuration_value_id),'null') || ' is null ' ||
                             ' or  configuration_value_id <> ' || nvl(to_char(p_configuration_value_id),'null') || ' )';
        hr_utility.trace('l_query = '|| l_query );

        execute immediate l_query into l_count;

        if l_count > 0 then
            p_return := false  ;
        else
            p_return := true ;
        end if ;
     end chk_unique_lookup_name ;

END PQP_GB_SWF_VALIDATIONS;

/
