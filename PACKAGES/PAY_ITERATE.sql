--------------------------------------------------------
--  DDL for Package PAY_ITERATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ITERATE" AUTHID CURRENT_USER as
/* $Header: pyiterat.pkh 120.4.12010000.1 2008/07/27 22:56:37 appldev ship $ */
/*
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

    Name              Date        Vers    Description
    ----------------  ----------- ------  -----------------------------------
    alogue            17-MAY-2007 115.17  Added p_assignment_action_id to
                                          is_amount_set.
    alogue            26-MAR-2007 115.16  Added p_assignment_action_id to
                                          is_first_setting.
    nbristow          25-JUl-2006 115.14  Added new functions for DEFAULT
                                          GROSSUP formula.
    nbristow          02-MAR-2004 115.13  Added get_high_gross_factor.
    rthirlby          26-FEB-2003 115.12  Bug 2823132 - New function
                                          order_cumulative used to determine
                                          the order run types should be
                                          downloaded. Called from the lct
                                          pycoiter.lct.
    prsundar          06-FEB-2003 115.11  Added parameters inclusion_flag &
					  usage_type to up_element_type_usage
					  procedure. Bug 2764101
    prsundar          30-JAN-2003 115.10  Renamed attribute_category to
					  run_informatIon_category and
				          attribute1....30 to
					  run_information1....run_information30
    prsundar	      23-jan-2003 115.9   Added parameters attribute_category
					  and attribute1....attribute30 to
					  procedure up_run_type. Bug 2577516
    Scchakra          04-DEC-2002 115.8   Added default 'Y' to parameter
                                          p_srs_flag in up_run_type.
    Scchakra          03-DEC-2002 115.7   Added parameter srs_flag to procedure
                                          up_run_type. Bug 2607325.
    RThirlby          10-DEC-2001 115.6   Added checkfile line
    RThirlby          01-DEC-2001 115.5   Added dbdrv line
    RThirlby          14-AUG-2001 115.4   Amended upload procedures for
                                          pay_run_types and pay_run_type_usages.
                                          Added upload procedure translate_row
                                          for run type translations.
    JTOMKINS          10-JUL-2001 115.3   Amended upload procedures for
                                          element_type_usages and
                                          run_type_org_methods to use
                                          apis and reflect table changes.
    NBRISTOW          19-MAY-2000 115.2   Added upload procedures.
    NBRISTOW          12-JAN-2000 115.1   Changes made for NTG.
    NBRISTOW          26-MAY-1999 115.0   Created.

*/
TYPE number_tbl     IS TABLE OF NUMBER      INDEX BY binary_integer;
TYPE varchar_60_tbl IS TABLE OF VARCHAR(60) INDEX BY binary_integer;
--
TYPE rt_record IS RECORD(rt_id        number
                        ,rt_name      varchar2(80)
                        ,rt_shortname varchar2(30)
                        ,rt_srs_flag  varchar2(30)
			,rt_run_information_category varchar2(30)
			,rt_run_information1 varchar2(150)
			,rt_run_information2 varchar2(150)
			,rt_run_information3 varchar2(150)
			,rt_run_information4 varchar2(150)
			,rt_run_information5 varchar2(150)
			,rt_run_information6 varchar2(150)
			,rt_run_information7 varchar2(150)
			,rt_run_information8 varchar2(150)
			,rt_run_information9 varchar2(150)
			,rt_run_information10 varchar2(150)
			,rt_run_information11 varchar2(150)
			,rt_run_information12 varchar2(150)
			,rt_run_information13 varchar2(150)
			,rt_run_information14 varchar2(150)
			,rt_run_information15 varchar2(150)
			,rt_run_information16 varchar2(150)
			,rt_run_information17 varchar2(150)
			,rt_run_information18 varchar2(150)
			,rt_run_information19 varchar2(150)
			,rt_run_information20 varchar2(150)
			,rt_run_information21 varchar2(150)
			,rt_run_information22 varchar2(150)
			,rt_run_information23 varchar2(150)
			,rt_run_information24 varchar2(150)
			,rt_run_information25 varchar2(150)
			,rt_run_information26 varchar2(150)
			,rt_run_information27 varchar2(150)
			,rt_run_information28 varchar2(150)
			,rt_run_information29 varchar2(150)
			,rt_run_information30 varchar2(150)
                        ,rt_leg_code  varchar2(30)
                        ,rt_bg        number
                        ,rt_esd       date
                        ,rt_eed       date
                        ,rt_ovn       number
                        ,rt_mode      varchar2(10)
                        );
--
g_old_rt_id              number     := -1;
g_to_be_uploaded_eed     date       := hr_api.g_eot;
rec_uploaded             rt_record;
l_call_set_end_date      boolean    := true;
--
TYPE rtu_record IS RECORD(rtu_id             number
                         ,rtu_parent_rt_id   varchar2(80)
                         ,rtu_child_rt_id    varchar2(80)
                         ,rtu_sequence       number
                         ,rtu_leg_code       varchar2(30)
                         ,rtu_bg             number
                         ,rtu_esd            date
                         ,rtu_eed            date
                         ,rtu_ovn            number
                         ,rtu_mode           varchar2(10)
                         );
--
g_old_rtu_id             number      := -1;
g_rtu_to_be_uploaded_eed date        := hr_api.g_eot;
rec_rtu_uploaded         rtu_record;
l_call_rtu_set_end_date  boolean     := true;
--
TYPE g_rtopm_record IS RECORD
  (old_rom_id   number(9) default -1
  ,new_rom_id   number(9) default -1
  ,new_esd      date
  ,old_esd      date
  ,new_eed      date default hr_api.g_eot
  ,old_eed      date default hr_api.g_eot
  ,ovn          number(9)
  );
--
G_ROM_REC g_rtopm_record;
--
TYPE g_et_usage_record IS RECORD
  (old_etu_id   number(9) default -1
  ,new_etu_id   number(9) default -1
  ,new_esd      date
  ,old_esd      date
  ,new_eed      date   default hr_api.g_eot
  ,old_eed      date   default hr_api.g_eot
  ,ovn          number(9)
  ,l_mode       varchar2(30)
  );
--
G_ETU_REC g_et_usage_record;
--
function initialise_amount (
                     p_bg_id         in number,
                     p_entry_id      in number,
                     p_assignment_action_id  in number default null,
                     p_target_value  in number default null
                     ) return number;
function initialise (p_entry_id      in number,
                     p_assignment_action_id  in number default null,
                      p_high_value    in number,
                      p_low_value     in number,
                      p_target_value  in number default null
                     ) return number;
--
function get_binary_guess(p_entry_id   in number,
                          p_mode       in varchar2) return number;
--
function get_interpolation_guess (p_entry_id in number,
                                  p_result   in number default null)
return number;
function is_amount_set (p_entry_id in number,
                        p_assignment_action_id in number default null)
return number;
function is_first_setting (p_entry_id in number,
                           p_assignment_action_id in number default null)
return number;
function get_high_value (p_entry_id in number)
return number;
function get_target_value (p_entry_id in number)
return number;
function get_low_value (p_entry_id in number)
return number;
function get_high_gross_factor (p_bg_id in number)
return number;
--
PROCEDURE up_run_type (p_rt_id                number
                      ,p_rt_name              varchar2
                      ,p_effective_start_date date
                      ,p_effective_end_date   date
                      ,p_legislative_code     varchar2
                      ,p_business_group       varchar2
                      ,p_shortname            varchar2
                      ,p_method               varchar2
                      ,p_rt_name_tl           varchar2
                      ,p_shortname_tl         varchar2
                      ,p_eof_number           number
		      ,p_srs_flag             varchar2  default 'Y'
		      ,p_run_information_category  varchar2  default null
		      ,p_run_information1       varchar2  default null
		      ,p_run_information2	varchar2  default null
		      ,p_run_information3       varchar2  default null
		      ,p_run_information4	varchar2  default null
		      ,p_run_information5	varchar2  default null
		      ,p_run_information6	varchar2  default null
		      ,p_run_information7	varchar2  default null
		      ,p_run_information8       varchar2  default null
		      ,p_run_information9	varchar2  default null
		      ,p_run_information10	varchar2  default null
		      ,p_run_information11	varchar2  default null
		      ,p_run_information12	varchar2  default null
		      ,p_run_information13      varchar2  default null
		      ,p_run_information14	varchar2  default null
		      ,p_run_information15	varchar2  default null
		      ,p_run_information16	varchar2  default null
		      ,p_run_information17	varchar2  default null
		      ,p_run_information18      varchar2  default null
		      ,p_run_information19	varchar2  default null
		      ,p_run_information20	varchar2  default null
		      ,p_run_information21	varchar2  default null
		      ,p_run_information22	varchar2  default null
		      ,p_run_information23      varchar2  default null
		      ,p_run_information24	varchar2  default null
		      ,p_run_information25	varchar2  default null
		      ,p_run_information26	varchar2  default null
		      ,p_run_information27	varchar2  default null
		      ,p_run_information28      varchar2  default null
		      ,p_run_information29	varchar2  default null
		      ,p_run_information30	varchar2  default null
                      );
--
PROCEDURE up_run_type_usage(p_rtu_id               number
                           ,p_parent_run_type_name varchar2
                           ,p_child_run_type_name  varchar2
                           ,p_child_leg_code       varchar2
                           ,p_child_bg             varchar2
                           ,p_effective_start_date date
                           ,p_effective_end_date   date
                           ,p_legislation_code     varchar2
                           ,p_business_group       varchar2
                           ,p_sequence             number
                           ,p_rtu_eof_number       number
                           );
--
PROCEDURE translate_row(p_base_rt_name  varchar2
                       ,p_rt_leg_code   varchar2
                       ,p_rt_bg         varchar2
                       ,p_rt_name_tl    varchar2
                       ,p_shortname_tl  varchar2
                       );
--
procedure up_run_type_org_method (
                           p_rt_opm_id            number,
                           p_rt_name              varchar2,
                           p_opm_name             varchar2,
                           p_effective_start_date date,
                           p_effective_end_date   date,
                           p_priority             number,
                           p_percentage           number default null,
                           p_amount               number default null,
                           p_business_group       varchar2,
                           p_rt_bg                varchar2 default null,
                           p_rt_lc                varchar2 default null,
                           p_eof_number           number
                         );
--
procedure up_element_type_usage (
                           p_etu_id               number,
                           p_rt_name              varchar2,
                           p_element_name         varchar2,
                           p_effective_start_date date,
                           p_effective_end_date   date,
                           p_business_group       varchar2 default null,
                           p_legislative_code     varchar2 default null,
                           p_rt_bg_name           varchar2 default null,
                           p_rt_leg_code          varchar2 default null,
                           p_et_bg_name           varchar2 default null,
                           p_et_leg_code          varchar2 default null,
			   p_inclusion_flag	  varchar2 default 'N',
			   p_usage_type		  varchar2,
                           p_eof_number           number
                         );
function order_cumulative (p_run_type_name     in varchar2
                          ,p_business_grp_name in varchar2
                          ,p_legislation_code  in varchar2)
return VARCHAR2;
--
end pay_iterate;

/
