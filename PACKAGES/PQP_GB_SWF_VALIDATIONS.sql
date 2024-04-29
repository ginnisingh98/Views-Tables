--------------------------------------------------------
--  DDL for Package PQP_GB_SWF_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQP_GB_SWF_VALIDATIONS" AUTHID CURRENT_USER AS
/* $Header: pqpgbswfv.pkh 120.0.12010000.1 2009/12/07 10:04:24 parusia noship $ */
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

     procedure chk_single_unique_mapping(
                      p_configuration_value_id   number
                    , p_business_group_id        number
                    , p_pcv_information_category varchar2
                    , p_information_column       varchar2
                    , p_value                    varchar2
                    , p_return     OUT NOCOPY    boolean
                    ) ;
     procedure chk_range_unique_mapping(
                      p_configuration_value_id   number
                    , p_business_group_id        number
                    , p_pcv_information_category varchar2
                    , p_information_start_column varchar2
                    , p_information_end_column   varchar2
                    , p_value_start              varchar2
                    , p_value_end                varchar2
                    , p_return      OUT NOCOPY   boolean
                    ) ;
     procedure chk_spine_pt_unique_mapping(
                      p_configuration_value_id   number
                    , p_business_group_id        number
                    , p_pcv_information_category varchar2
                    , p_payscale_column          varchar2
                    , p_information_start_column varchar2
                    , p_information_end_column   varchar2
                    , p_payscale_value           varchar2
                    , p_value_start              varchar2
                    , p_value_end                varchar2
                    , p_return      OUT NOCOPY   boolean
                    ) ;
     procedure chk_unique_lookup_name(
                      p_configuration_value_id   number
                    , p_business_group_id        number
                    , p_pcv_information_category varchar2
                    , p_information_column       varchar2
                    , p_value                    varchar2
                    , p_return     OUT NOCOPY    boolean
                    ) ;
      procedure chk_hours_cntrct_tp_unq_map(
                      p_configuration_value_id   number
                    , p_business_group_id        number
                    , p_pcv_information_category varchar2
                    , p_information_column       varchar2
                    , p_value                    varchar2
                    , p_return     OUT NOCOPY    boolean
                    ) ;
END PQP_GB_SWF_VALIDATIONS ;

/
