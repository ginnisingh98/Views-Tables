--------------------------------------------------------
--  DDL for Package HR_ENTRY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ENTRY_API" AUTHID CURRENT_USER as
/* $Header: pyentapi.pkh 120.2.12010000.1 2008/07/27 22:31:54 appldev ship $ */
--
/*
/*

 *  Copyright (C) 1993 Oracle Corporation UK Ltd. Richmond, England.  *

 Name        : hr_entry_api
 Description : API for element entries. Supports insert, update and delete.
 Uses        : hr_entry , hr_utility
 Used By     : hrentmnt

 Change List
 -----------
  Date      Name         Vers    Bug No   Description
 +---------+------------+-------+--------+------------------------------------+
  29-Oct-93 J.S.Hobbs    40.0             First Created.
  04-Nov-93 J.S.Hobbs    40.1             Changed parameters to
                                          update_element_entry.
  01-Mar-94 D.C.Harris   40.2    G590     Added new parameter
                                          p_check_for_update.
  08-Mar-94 D.C.Harris   40.3             Corrected defaulting of
                                          p_dt_update_mode.
                                          Enabled use of passing hot defaulted
                                          values to update api.
  02-Mar-95 J.S.Hobbs    40.5             Added support for new column
                                          SUBPRIORITY
  18-Apr-95 J.S.Hobbs    40.6    274283   Changed parameter p_reason to be a
                                          varchar2 instead of a number.
  16-May-95 D.E.Saxby    40.7    280574   Made validate_entry_value public.
  29-Jun-95 N. Simpson   40.8             Added new columns date_earned and
                                          personal_payment_method_id
  07-May-97 M.Reid       40.9             Changed defaults to API standards
  26-NOV-98 S.Billing    110.1   559467   Modified conv_entry_values_to_table()
                                          and conv_table_to_table(),
                                          added extra parameters so that creator
                                          type and entry type can be passed
                                          down,
                                          if creator type is forms or mix and
                                          and entry type is NOT adjustment and
                                          the user is attempting to set/update
                                          a non-user enterable input value
                                          then throw an error
-- --
  25-Apr-00 sbilling     115.3            Merged in changes made by J.Bailie to
                                          introduce DDFF functionality on the
                                          Element Entry form.
                                          Overloaded insert_element_entry and
                                          update_element_entry procedures
                                          to add developer flex. There now exist
                                          4 versions of each procedure which
                                          have
                                             Table of IV's
                                             Expanded IV's
                                             Table of IV's and DDF
                                             Expanded IV's amd DDF
  19-Jun-00 D.E.Saxby    115.4  1334301   Made set_formula_contexts public.
  15-Aug-00 A.Handa      115.5            Added commit before exit statement.
  24-jul-01 tbattoo      115.6  1869615   Support for new column on pay_element
                                          entries,  updating_action_type
  11-Feb-02 SuSivasu     115.7            Added default for p_entry_information_category
                                          as well as included p_override_user_ent_chk
                                          to the insert and update entry interfaces.
  12-Feb-02 SuSivasu     115.8            GSCC standards fix.
  05-Dec-02 dsaxby       115.9  2692195   Nocopy changes.
  11-Feb-03 swinton      115.10 2793978   Enabled value set validation of
                                          element entry values.
                                          Validate_entry_value modified to
                                          handle value set validated entry
                                          values.
  28-Mar-03 alogue       115.11 2848993   Undo Nocopy changes to insert_element_entry
                                          called from c-code batch processes (to
                                          avoit nasty patching issue!).
  04-Oct-05 swinton      115.12  4646377  Reinstated NOCOPY changes to
                                          insert_element_entry.

 +---------+------------+-------+--------+------------------------------------+
*/
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.conv_entry_values_to_table                                  --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Converts a set of predefined parameters containing the INPUT_VALUE_IDs   --
 -- and SCREEN_ENTRY_VALUEs for an element entry to a pair of PLSQL tables   --
 -- containing the same information. It also returns the number of entry     --
 -- values.                                                                  --
 ------------------------------------------------------------------------------
--
 procedure conv_entry_values_to_table
 (
  p_iv_format          varchar2,
  p_element_entry_id   number,
  p_element_link_id    number,
  p_session_date       date,
  p_creator_type       varchar2,
  p_entry_type         varchar2,
  p_input_value_id1    number,
  p_input_value_id2    number,
  p_input_value_id3    number,
  p_input_value_id4    number,
  p_input_value_id5    number,
  p_input_value_id6    number,
  p_input_value_id7    number,
  p_input_value_id8    number,
  p_input_value_id9    number,
  p_input_value_id10   number,
  p_input_value_id11   number,
  p_input_value_id12   number,
  p_input_value_id13   number,
  p_input_value_id14   number,
  p_input_value_id15   number,
  p_entry_value1       varchar2,
  p_entry_value2       varchar2,
  p_entry_value3       varchar2,
  p_entry_value4       varchar2,
  p_entry_value5       varchar2,
  p_entry_value6       varchar2,
  p_entry_value7       varchar2,
  p_entry_value8       varchar2,
  p_entry_value9       varchar2,
  p_entry_value10      varchar2,
  p_entry_value11      varchar2,
  p_entry_value12      varchar2,
  p_entry_value13      varchar2,
  p_entry_value14      varchar2,
  p_entry_value15      varchar2,
  p_num_entry_values   out nocopy number,
  p_input_value_id_tbl out nocopy hr_entry.number_table,
  p_entry_value_tbl    out nocopy hr_entry.varchar2_table
 );
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry.conv_table_to_table                                             --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Given a table of entry values it converts to DB format if required. Any  --
 -- entry values that are not specified are derived NB. when inserting the   --
 -- values are defaulted, when updating the existing entry values are used.  --
 ------------------------------------------------------------------------------
--
 procedure conv_table_to_table
 (
  p_iv_format          varchar2,
  p_session_date       date,
  p_element_entry_id   number,
  p_element_link_id    number,
  p_num_entry_values   in out nocopy number,
  p_creator_type       varchar2,
  p_entry_type         varchar2,
  p_input_value_id_tbl in out nocopy hr_entry.number_table,
  p_entry_value_tbl    in out nocopy hr_entry.varchar2_table
 );
 --
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.set_formula_contexts                                        --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Called to set the (global) contexts that will be used in any input value --
 -- validation formula.  We obtain the business_group_id from the assignment --
 -- only if it hasn't already been set to save ourselves a database hit.     --
 ------------------------------------------------------------------------------
--
 procedure set_formula_contexts
 (
  p_assignment_id  number,
  p_effective_date date
 );
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry.validate_entry_value                                            --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Validates and converts an entry value to DB format.                      --
 ------------------------------------------------------------------------------
--
 procedure validate_entry_value
 (
  p_element_link_id     number,
  p_input_value_id      number,
  p_session_date        date,
  p_screen_format       in out nocopy varchar2,
  p_db_format           in out nocopy varchar2,
  p_lookup_type         varchar2,
  p_uom                 varchar2,
  p_input_currency_code varchar2,
  p_value_set_id        number default null
 );
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.get_link                                                    --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Returns for the element link that represents the assignments eligibility --
 -- for a particular element type on a given date.                           --
 ------------------------------------------------------------------------------
--
 function get_link
 (
  p_assignment_id   number,
  p_element_type_id number,
  p_session_date    date
 ) return number;
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.insert_element_entry                                        --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Cover routine for call to hr_entry_api.ins_element_entry that accepts    --
 -- entry values passed as a table. It converts the entry values to DB       --
 -- format and also defaults any entry values that were not specified.       --
 -- NB. all entry values specified are validated !                           --
 ------------------------------------------------------------------------------
--
 procedure insert_element_entry
 (
  --
  -- Common Parameters
  --
  p_effective_start_date       in out nocopy date,
  p_effective_end_date         in out nocopy date,
  --
  -- Element Entry Table
  --
  p_element_entry_id           in out nocopy number,
  p_original_entry_id          number    default null,
  p_assignment_id              number,
  p_element_link_id            number,
  p_creator_type               varchar2,
  p_entry_type                 varchar2,
  p_cost_allocation_keyflex_id number    default null,
  p_updating_action_id         number    default null,
  p_updating_action_type       varchar2  default null,
  p_comment_id                 number    default null,
  p_creator_id                 number    default null,
  p_reason                     varchar2  default null,
  p_target_entry_id            number    default null,
  p_subpriority                number    default null,
  p_date_earned                 date    default null,
  p_personal_payment_method_id  number  default null,
  p_attribute_category         varchar2  default null,
  p_attribute1                 varchar2  default null,
  p_attribute2                 varchar2  default null,
  p_attribute3                 varchar2  default null,
  p_attribute4                 varchar2  default null,
  p_attribute5                 varchar2  default null,
  p_attribute6                 varchar2  default null,
  p_attribute7                 varchar2  default null,
  p_attribute8                 varchar2  default null,
  p_attribute9                 varchar2  default null,
  p_attribute10                varchar2  default null,
  p_attribute11                varchar2  default null,
  p_attribute12                varchar2  default null,
  p_attribute13                varchar2  default null,
  p_attribute14                varchar2  default null,
  p_attribute15                varchar2  default null,
  p_attribute16                varchar2  default null,
  p_attribute17                varchar2  default null,
  p_attribute18                varchar2  default null,
  p_attribute19                varchar2  default null,
  p_attribute20                varchar2  default null,
  p_override_user_ent_chk      varchar2  default 'N',
  p_label_identifier           varchar2  default null,

  --
  -- Element Entry Values Table
  --
  p_num_entry_values           number,
  p_input_value_id_tbl         hr_entry.number_table,
  p_entry_value_tbl            hr_entry.varchar2_table
  );
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.insert_element_entry                                        --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Cover routine for call to hr_entry_api.ins_element_entry that accepts    --
 -- entry values passed as parameters. It converts the entry values to DB    --
 -- format and also defaults any entry values that were not specified.       --
 -- NB. all entry values specified are validated !                           --
 ------------------------------------------------------------------------------
--
 procedure insert_element_entry
 (
  --
  -- Common Parameters
  --
  p_effective_start_date       in out nocopy date,
  p_effective_end_date         in out nocopy date,
  --
  -- Element Entry Table
  --
  p_element_entry_id           in out nocopy number,
  p_original_entry_id          number    default null,
  p_assignment_id              number,
  p_element_link_id            number,
  p_creator_type               varchar2,
  p_entry_type                 varchar2,
  p_cost_allocation_keyflex_id number    default null,
  p_updating_action_id         number    default null,
  p_updating_action_type       varchar2  default null,
  p_comment_id                 number    default null,
  p_creator_id                 number    default null,
  p_reason                     varchar2  default null,
  p_target_entry_id            number    default null,
  p_subpriority                number    default null,
  p_date_earned                date     default null,
  p_personal_payment_method_id number   default null,
  p_attribute_category         varchar2  default null,
  p_attribute1                 varchar2  default null,
  p_attribute2                 varchar2  default null,
  p_attribute3                 varchar2  default null,
  p_attribute4                 varchar2  default null,
  p_attribute5                 varchar2  default null,
  p_attribute6                 varchar2  default null,
  p_attribute7                 varchar2  default null,
  p_attribute8                 varchar2  default null,
  p_attribute9                 varchar2  default null,
  p_attribute10                varchar2  default null,
  p_attribute11                varchar2  default null,
  p_attribute12                varchar2  default null,
  p_attribute13                varchar2  default null,
  p_attribute14                varchar2  default null,
  p_attribute15                varchar2  default null,
  p_attribute16                varchar2  default null,
  p_attribute17                varchar2  default null,
  p_attribute18                varchar2  default null,
  p_attribute19                varchar2  default null,
  p_attribute20                varchar2  default null,
  --
  -- Element Entry Values Table
  --
  p_input_value_id1            number    default null,
  p_input_value_id2            number    default null,
  p_input_value_id3            number    default null,
  p_input_value_id4            number    default null,
  p_input_value_id5            number    default null,
  p_input_value_id6            number    default null,
  p_input_value_id7            number    default null,
  p_input_value_id8            number    default null,
  p_input_value_id9            number    default null,
  p_input_value_id10           number    default null,
  p_input_value_id11           number    default null,
  p_input_value_id12           number    default null,
  p_input_value_id13           number    default null,
  p_input_value_id14           number    default null,
  p_input_value_id15           number    default null,
  p_entry_value1               varchar2  default null,
  p_entry_value2               varchar2  default null,
  p_entry_value3               varchar2  default null,
  p_entry_value4               varchar2  default null,
  p_entry_value5               varchar2  default null,
  p_entry_value6               varchar2  default null,
  p_entry_value7               varchar2  default null,
  p_entry_value8               varchar2  default null,
  p_entry_value9               varchar2  default null,
  p_entry_value10              varchar2  default null,
  p_entry_value11              varchar2  default null,
  p_entry_value12              varchar2  default null,
  p_entry_value13              varchar2  default null,
  p_entry_value14              varchar2  default null,
  p_entry_value15              varchar2  default null,
  p_override_user_ent_chk      varchar2  default 'N',
  p_label_identifier           varchar2  default null
 );
--
-- --
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.insert_element_entry                                        --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Cover routine for call to hr_entry_api.ins_element_entry that accepts    --
 -- entry values passed as a table. It converts the entry values to DB       --
 -- format and also defaults any entry values that were not specified.       --
 -- NB. all entry values specified are validated !                           --
 ------------------------------------------------------------------------------
--
--  Overloaded version with Element Entry developer flex
--
 procedure insert_element_entry
 (
  --
  -- Common Parameters
  --
  p_effective_start_date       in out nocopy date,
  p_effective_end_date         in out nocopy date,
  --
  -- Element Entry Table
  --
  p_element_entry_id           in out nocopy number,
  p_original_entry_id          number    default null,
  p_assignment_id              number,
  p_element_link_id            number,
  p_creator_type               varchar2,
  p_entry_type                 varchar2,
  p_cost_allocation_keyflex_id number    default null,
  p_updating_action_id         number    default null,
  p_updating_action_type       varchar2  default null,
  p_comment_id                 number    default null,
  p_creator_id                 number    default null,
  p_reason                     varchar2  default null,
  p_target_entry_id            number    default null,
  p_subpriority                number    default null,
  p_date_earned                 date    default null,
  p_personal_payment_method_id  number  default null,
  p_attribute_category         varchar2  default null,
  p_attribute1                 varchar2  default null,
  p_attribute2                 varchar2  default null,
  p_attribute3                 varchar2  default null,
  p_attribute4                 varchar2  default null,
  p_attribute5                 varchar2  default null,
  p_attribute6                 varchar2  default null,
  p_attribute7                 varchar2  default null,
  p_attribute8                 varchar2  default null,
  p_attribute9                 varchar2  default null,
  p_attribute10                varchar2  default null,
  p_attribute11                varchar2  default null,
  p_attribute12                varchar2  default null,
  p_attribute13                varchar2  default null,
  p_attribute14                varchar2  default null,
  p_attribute15                varchar2  default null,
  p_attribute16                varchar2  default null,
  p_attribute17                varchar2  default null,
  p_attribute18                varchar2  default null,
  p_attribute19                varchar2  default null,
  p_attribute20                varchar2  default null,
  --
  -- Element Entry Values Table
  --
  p_num_entry_values           number,
  p_input_value_id_tbl         hr_entry.number_table,
  p_entry_value_tbl            hr_entry.varchar2_table,
  --
  -- Developer Descriptive Flex
  --
  p_entry_information_category varchar2  ,
  p_entry_information1         varchar2  default null,
  p_entry_information2         varchar2  default null,
  p_entry_information3         varchar2  default null,
  p_entry_information4         varchar2  default null,
  p_entry_information5         varchar2  default null,
  p_entry_information6         varchar2  default null,
  p_entry_information7         varchar2  default null,
  p_entry_information8         varchar2  default null,
  p_entry_information9         varchar2  default null,
  p_entry_information10        varchar2  default null,
  p_entry_information11        varchar2  default null,
  p_entry_information12        varchar2  default null,
  p_entry_information13        varchar2  default null,
  p_entry_information14        varchar2  default null,
  p_entry_information15        varchar2  default null,
  p_entry_information16        varchar2  default null,
  p_entry_information17        varchar2  default null,
  p_entry_information18        varchar2  default null,
  p_entry_information19        varchar2  default null,
  p_entry_information20        varchar2  default null,
  p_entry_information21        varchar2  default null,
  p_entry_information22        varchar2  default null,
  p_entry_information23        varchar2  default null,
  p_entry_information24        varchar2  default null,
  p_entry_information25        varchar2  default null,
  p_entry_information26        varchar2  default null,
  p_entry_information27        varchar2  default null,
  p_entry_information28        varchar2  default null,
  p_entry_information29        varchar2  default null,
  p_entry_information30        varchar2  default null,
  p_override_user_ent_chk      varchar2  default 'N',
  p_label_identifier           varchar2  default null
  );
--
-- --
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.insert_element_entry                                        --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Cover routine for call to hr_entry_api.ins_element_entry that accepts    --
 -- entry values passed as parameters. It converts the entry values to DB    --
 -- format and also defaults any entry values that were not specified.       --
 -- NB. all entry values specified are validated !                           --
 ------------------------------------------------------------------------------
--
--
--  Overloaded version with Element Entry developer flex
--
 procedure insert_element_entry
 (
  --
  -- Common Parameters
  --
  p_effective_start_date       in out nocopy date,
  p_effective_end_date         in out nocopy date,
  --
  -- Element Entry Table
  --
  p_element_entry_id           in out nocopy number,
  p_original_entry_id          number    default null,
  p_assignment_id              number,
  p_element_link_id            number,
  p_creator_type               varchar2,
  p_entry_type                 varchar2,
  p_cost_allocation_keyflex_id number    default null,
  p_updating_action_id         number    default null,
  p_updating_action_type       varchar2  default null,
  p_comment_id                 number    default null,
  p_creator_id                 number    default null,
  p_reason                     varchar2  default null,
  p_target_entry_id            number    default null,
  p_subpriority                number    default null,
  p_date_earned                date     default null,
  p_personal_payment_method_id number   default null,
  p_attribute_category         varchar2  default null,
  p_attribute1                 varchar2  default null,
  p_attribute2                 varchar2  default null,
  p_attribute3                 varchar2  default null,
  p_attribute4                 varchar2  default null,
  p_attribute5                 varchar2  default null,
  p_attribute6                 varchar2  default null,
  p_attribute7                 varchar2  default null,
  p_attribute8                 varchar2  default null,
  p_attribute9                 varchar2  default null,
  p_attribute10                varchar2  default null,
  p_attribute11                varchar2  default null,
  p_attribute12                varchar2  default null,
  p_attribute13                varchar2  default null,
  p_attribute14                varchar2  default null,
  p_attribute15                varchar2  default null,
  p_attribute16                varchar2  default null,
  p_attribute17                varchar2  default null,
  p_attribute18                varchar2  default null,
  p_attribute19                varchar2  default null,
  p_attribute20                varchar2  default null,
  --
  -- Element Entry Values Table
  --
  p_input_value_id1            number    default null,
  p_input_value_id2            number    default null,
  p_input_value_id3            number    default null,
  p_input_value_id4            number    default null,
  p_input_value_id5            number    default null,
  p_input_value_id6            number    default null,
  p_input_value_id7            number    default null,
  p_input_value_id8            number    default null,
  p_input_value_id9            number    default null,
  p_input_value_id10           number    default null,
  p_input_value_id11           number    default null,
  p_input_value_id12           number    default null,
  p_input_value_id13           number    default null,
  p_input_value_id14           number    default null,
  p_input_value_id15           number    default null,
  p_entry_value1               varchar2  default null,
  p_entry_value2               varchar2  default null,
  p_entry_value3               varchar2  default null,
  p_entry_value4               varchar2  default null,
  p_entry_value5               varchar2  default null,
  p_entry_value6               varchar2  default null,
  p_entry_value7               varchar2  default null,
  p_entry_value8               varchar2  default null,
  p_entry_value9               varchar2  default null,
  p_entry_value10              varchar2  default null,
  p_entry_value11              varchar2  default null,
  p_entry_value12              varchar2  default null,
  p_entry_value13              varchar2  default null,
  p_entry_value14              varchar2  default null,
  p_entry_value15              varchar2  default null,
  --
  -- Developer Descriptive Flex
  --
  p_entry_information_category varchar2  ,
  p_entry_information1         varchar2  default null,
  p_entry_information2         varchar2  default null,
  p_entry_information3         varchar2  default null,
  p_entry_information4         varchar2  default null,
  p_entry_information5         varchar2  default null,
  p_entry_information6         varchar2  default null,
  p_entry_information7         varchar2  default null,
  p_entry_information8         varchar2  default null,
  p_entry_information9         varchar2  default null,
  p_entry_information10        varchar2  default null,
  p_entry_information11        varchar2  default null,
  p_entry_information12        varchar2  default null,
  p_entry_information13        varchar2  default null,
  p_entry_information14        varchar2  default null,
  p_entry_information15        varchar2  default null,
  p_entry_information16        varchar2  default null,
  p_entry_information17        varchar2  default null,
  p_entry_information18        varchar2  default null,
  p_entry_information19        varchar2  default null,
  p_entry_information20        varchar2  default null,
  p_entry_information21        varchar2  default null,
  p_entry_information22        varchar2  default null,
  p_entry_information23        varchar2  default null,
  p_entry_information24        varchar2  default null,
  p_entry_information25        varchar2  default null,
  p_entry_information26        varchar2  default null,
  p_entry_information27        varchar2  default null,
  p_entry_information28        varchar2  default null,
  p_entry_information29        varchar2  default null,
  p_entry_information30        varchar2  default null,
  p_override_user_ent_chk      varchar2  default 'N',
  p_label_identifier           varchar2  default null
 );
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.update_element_entry                                        --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Cover routine for call to hr_entry_api.upd_element_entry that accepts    --
 -- entry values passed as a table. It converts the entry values to DB       --
 -- format. Any entry values that were not specified are copied from the     --
 -- element entry being updated.                                             --
 -- NB. all entry values specified are validated !                           --
 ------------------------------------------------------------------------------
--
 procedure update_element_entry
 (
  --
  -- Update Mode
  --
  p_dt_update_mode             varchar2 default null,
  --
  -- Date on which change is taking place
  --
  p_session_date               date,
  --
  -- Check to see if the entry is being updated
  --
  p_check_for_update           varchar2  default 'N',
  --
  -- Element Entry Table
  --
  p_element_entry_id           number,
  p_cost_allocation_keyflex_id number    default hr_api.g_number,
  p_updating_action_id         number    default hr_api.g_number,
  p_updating_action_type       varchar2  default hr_api.g_varchar2,
  p_original_entry_id          number    default hr_api.g_number,
  p_creator_type               varchar2  default hr_api.g_varchar2,
  p_comment_id                 number    default hr_api.g_number,
  p_creator_id                 number    default hr_api.g_number,
  p_reason                     varchar2  default hr_api.g_varchar2,
  p_subpriority                number    default hr_api.g_number,
  p_date_earned                date      default hr_api.g_date,
  p_personal_payment_method_id number    default hr_api.g_number,
  p_attribute_category         varchar2  default hr_api.g_varchar2,
  p_attribute1                 varchar2  default hr_api.g_varchar2,
  p_attribute2                 varchar2  default hr_api.g_varchar2,
  p_attribute3                 varchar2  default hr_api.g_varchar2,
  p_attribute4                 varchar2  default hr_api.g_varchar2,
  p_attribute5                 varchar2  default hr_api.g_varchar2,
  p_attribute6                 varchar2  default hr_api.g_varchar2,
  p_attribute7                 varchar2  default hr_api.g_varchar2,
  p_attribute8                 varchar2  default hr_api.g_varchar2,
  p_attribute9                 varchar2  default hr_api.g_varchar2,
  p_attribute10                varchar2  default hr_api.g_varchar2,
  p_attribute11                varchar2  default hr_api.g_varchar2,
  p_attribute12                varchar2  default hr_api.g_varchar2,
  p_attribute13                varchar2  default hr_api.g_varchar2,
  p_attribute14                varchar2  default hr_api.g_varchar2,
  p_attribute15                varchar2  default hr_api.g_varchar2,
  p_attribute16                varchar2  default hr_api.g_varchar2,
  p_attribute17                varchar2  default hr_api.g_varchar2,
  p_attribute18                varchar2  default hr_api.g_varchar2,
  p_attribute19                varchar2  default hr_api.g_varchar2,
  p_attribute20                varchar2  default hr_api.g_varchar2,
  p_override_user_ent_chk      varchar2  default 'N',
  --
  -- Element Entry Values Table
  --
  p_num_entry_values           number,
  p_input_value_id_tbl         hr_entry.number_table,
  p_entry_value_tbl            hr_entry.varchar2_table
 );
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.update_element_entry                                        --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Cover routine for call to hr_entry_api.upd_element_entry that accepts    --
 -- entry values passed as parameters. It converts the entry values to DB    --
 -- format. Any entry values that were not specified are copied from the     --
 -- element entry being updated.                                             --
 -- NB. all entry values specified are validated !                           --
 ------------------------------------------------------------------------------
--
 procedure update_element_entry
 (
  --
  -- Update Mode
  --
  p_dt_update_mode             varchar2 default null,
  --
  -- Date on which change is taking place
  --
  p_session_date               date,
  --
  -- Check to see if the entry is being updated
  --
  p_check_for_update           varchar2  default 'N',
  --
  -- Element Entry Table
  --
  p_element_entry_id           number,
  p_cost_allocation_keyflex_id number    default hr_api.g_number,
  p_updating_action_id         number    default hr_api.g_number,
  p_updating_action_type       varchar2  default hr_api.g_varchar2,
  p_original_entry_id          number    default hr_api.g_number,
  p_creator_type               varchar2  default hr_api.g_varchar2,
  p_comment_id                 number    default hr_api.g_number,
  p_creator_id                 number    default hr_api.g_number,
  p_reason                     varchar2  default hr_api.g_varchar2,
  p_subpriority                number    default hr_api.g_number,
  p_date_earned                date      default hr_api.g_date,
  p_personal_payment_method_id number    default hr_api.g_number,
  p_attribute_category         varchar2  default hr_api.g_varchar2,
  p_attribute1                 varchar2  default hr_api.g_varchar2,
  p_attribute2                 varchar2  default hr_api.g_varchar2,
  p_attribute3                 varchar2  default hr_api.g_varchar2,
  p_attribute4                 varchar2  default hr_api.g_varchar2,
  p_attribute5                 varchar2  default hr_api.g_varchar2,
  p_attribute6                 varchar2  default hr_api.g_varchar2,
  p_attribute7                 varchar2  default hr_api.g_varchar2,
  p_attribute8                 varchar2  default hr_api.g_varchar2,
  p_attribute9                 varchar2  default hr_api.g_varchar2,
  p_attribute10                varchar2  default hr_api.g_varchar2,
  p_attribute11                varchar2  default hr_api.g_varchar2,
  p_attribute12                varchar2  default hr_api.g_varchar2,
  p_attribute13                varchar2  default hr_api.g_varchar2,
  p_attribute14                varchar2  default hr_api.g_varchar2,
  p_attribute15                varchar2  default hr_api.g_varchar2,
  p_attribute16                varchar2  default hr_api.g_varchar2,
  p_attribute17                varchar2  default hr_api.g_varchar2,
  p_attribute18                varchar2  default hr_api.g_varchar2,
  p_attribute19                varchar2  default hr_api.g_varchar2,
  p_attribute20                varchar2  default hr_api.g_varchar2,
  --
  -- Element Entry Values Table
  --
  p_input_value_id1            number   default null,
  p_input_value_id2            number   default null,
  p_input_value_id3            number   default null,
  p_input_value_id4            number   default null,
  p_input_value_id5            number   default null,
  p_input_value_id6            number   default null,
  p_input_value_id7            number   default null,
  p_input_value_id8            number   default null,
  p_input_value_id9            number   default null,
  p_input_value_id10           number   default null,
  p_input_value_id11           number   default null,
  p_input_value_id12           number   default null,
  p_input_value_id13           number   default null,
  p_input_value_id14           number   default null,
  p_input_value_id15           number   default null,
  p_entry_value1               varchar2 default null,
  p_entry_value2               varchar2 default null,
  p_entry_value3               varchar2 default null,
  p_entry_value4               varchar2 default null,
  p_entry_value5               varchar2 default null,
  p_entry_value6               varchar2 default null,
  p_entry_value7               varchar2 default null,
  p_entry_value8               varchar2 default null,
  p_entry_value9               varchar2 default null,
  p_entry_value10              varchar2 default null,
  p_entry_value11              varchar2 default null,
  p_entry_value12              varchar2 default null,
  p_entry_value13              varchar2 default null,
  p_entry_value14              varchar2 default null,
  p_entry_value15              varchar2 default null,
  p_override_user_ent_chk      varchar2 default 'N'
 );
--
-- --
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.update_element_entry                                        --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Cover routine for call to hr_entry_api.upd_element_entry that accepts    --
 -- entry values passed as a table. It converts the entry values to DB       --
 -- format. Any entry values that were not specified are copied from the     --
 -- element entry being updated.                                             --
 -- NB. all entry values specified are validated !                           --
 ------------------------------------------------------------------------------
--
--  Overloaded version with Element Entry developer flex
--
--
 procedure update_element_entry
 (
  --
  -- Update Mode
  --
  p_dt_update_mode             varchar2 default null,
  --
  -- Date on which change is taking place
  --
  p_session_date               date,
  --
  -- Check to see if the entry is being updated
  --
  p_check_for_update           varchar2  default 'N',
  --
  -- Element Entry Table
  --
  p_element_entry_id           number,
  p_cost_allocation_keyflex_id number    default hr_api.g_number,
  p_updating_action_id         number    default hr_api.g_number,
  p_updating_action_type       varchar2  default hr_api.g_varchar2,
  p_original_entry_id          number    default hr_api.g_number,
  p_creator_type               varchar2  default hr_api.g_varchar2,
  p_comment_id                 number    default hr_api.g_number,
  p_creator_id                 number    default hr_api.g_number,
  p_reason                     varchar2  default hr_api.g_varchar2,
  p_subpriority                number    default hr_api.g_number,
  p_date_earned                date      default hr_api.g_date,
  p_personal_payment_method_id number    default hr_api.g_number,
  p_attribute_category         varchar2  default hr_api.g_varchar2,
  p_attribute1                 varchar2  default hr_api.g_varchar2,
  p_attribute2                 varchar2  default hr_api.g_varchar2,
  p_attribute3                 varchar2  default hr_api.g_varchar2,
  p_attribute4                 varchar2  default hr_api.g_varchar2,
  p_attribute5                 varchar2  default hr_api.g_varchar2,
  p_attribute6                 varchar2  default hr_api.g_varchar2,
  p_attribute7                 varchar2  default hr_api.g_varchar2,
  p_attribute8                 varchar2  default hr_api.g_varchar2,
  p_attribute9                 varchar2  default hr_api.g_varchar2,
  p_attribute10                varchar2  default hr_api.g_varchar2,
  p_attribute11                varchar2  default hr_api.g_varchar2,
  p_attribute12                varchar2  default hr_api.g_varchar2,
  p_attribute13                varchar2  default hr_api.g_varchar2,
  p_attribute14                varchar2  default hr_api.g_varchar2,
  p_attribute15                varchar2  default hr_api.g_varchar2,
  p_attribute16                varchar2  default hr_api.g_varchar2,
  p_attribute17                varchar2  default hr_api.g_varchar2,
  p_attribute18                varchar2  default hr_api.g_varchar2,
  p_attribute19                varchar2  default hr_api.g_varchar2,
  p_attribute20                varchar2  default hr_api.g_varchar2,
  --
  -- Element Entry Values Table
  --
  p_num_entry_values           number,
  p_input_value_id_tbl         hr_entry.number_table,
  p_entry_value_tbl            hr_entry.varchar2_table,
  --
  -- Developer Descriptive Flex
  --
  p_entry_information_category varchar2  ,
  p_entry_information1         varchar2  default hr_api.g_varchar2,
  p_entry_information2         varchar2  default hr_api.g_varchar2,
  p_entry_information3         varchar2  default hr_api.g_varchar2,
  p_entry_information4         varchar2  default hr_api.g_varchar2,
  p_entry_information5         varchar2  default hr_api.g_varchar2,
  p_entry_information6         varchar2  default hr_api.g_varchar2,
  p_entry_information7         varchar2  default hr_api.g_varchar2,
  p_entry_information8         varchar2  default hr_api.g_varchar2,
  p_entry_information9         varchar2  default hr_api.g_varchar2,
  p_entry_information10        varchar2  default hr_api.g_varchar2,
  p_entry_information11        varchar2  default hr_api.g_varchar2,
  p_entry_information12        varchar2  default hr_api.g_varchar2,
  p_entry_information13        varchar2  default hr_api.g_varchar2,
  p_entry_information14        varchar2  default hr_api.g_varchar2,
  p_entry_information15        varchar2  default hr_api.g_varchar2,
  p_entry_information16        varchar2  default hr_api.g_varchar2,
  p_entry_information17        varchar2  default hr_api.g_varchar2,
  p_entry_information18        varchar2  default hr_api.g_varchar2,
  p_entry_information19        varchar2  default hr_api.g_varchar2,
  p_entry_information20        varchar2  default hr_api.g_varchar2,
  p_entry_information21        varchar2  default hr_api.g_varchar2,
  p_entry_information22        varchar2  default hr_api.g_varchar2,
  p_entry_information23        varchar2  default hr_api.g_varchar2,
  p_entry_information24        varchar2  default hr_api.g_varchar2,
  p_entry_information25        varchar2  default hr_api.g_varchar2,
  p_entry_information26        varchar2  default hr_api.g_varchar2,
  p_entry_information27        varchar2  default hr_api.g_varchar2,
  p_entry_information28        varchar2  default hr_api.g_varchar2,
  p_entry_information29        varchar2  default hr_api.g_varchar2,
  p_entry_information30        varchar2  default hr_api.g_varchar2,
  p_override_user_ent_chk      varchar2  default 'N'
 );
--
-- --
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.update_element_entry                                        --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Cover routine for call to hr_entry_api.upd_element_entry that accepts    --
 -- entry values passed as parameters. It converts the entry values to DB    --
 -- format. Any entry values that were not specified are copied from the     --
 -- element entry being updated.                                             --
 -- NB. all entry values specified are validated !                           --
 ------------------------------------------------------------------------------
--
--  Overloaded version with Element Entry developer flex
--
--
 procedure update_element_entry
 (
  --
  -- Update Mode
  --
  p_dt_update_mode             varchar2 default null,
  --
  -- Date on which change is taking place
  --
  p_session_date               date,
  --
  -- Check to see if the entry is being updated
  --
  p_check_for_update           varchar2  default 'N',
  --
  -- Element Entry Table
  --
  p_element_entry_id           number,
  p_cost_allocation_keyflex_id number    default hr_api.g_number,
  p_updating_action_id         number    default hr_api.g_number,
  p_updating_action_type       varchar2  default hr_api.g_varchar2,
  p_original_entry_id          number    default hr_api.g_number,
  p_creator_type               varchar2  default hr_api.g_varchar2,
  p_comment_id                 number    default hr_api.g_number,
  p_creator_id                 number    default hr_api.g_number,
  p_reason                     varchar2  default hr_api.g_varchar2,
  p_subpriority                number    default hr_api.g_number,
  p_date_earned                date      default hr_api.g_date,
  p_personal_payment_method_id number    default hr_api.g_number,
  p_attribute_category         varchar2  default hr_api.g_varchar2,
  p_attribute1                 varchar2  default hr_api.g_varchar2,
  p_attribute2                 varchar2  default hr_api.g_varchar2,
  p_attribute3                 varchar2  default hr_api.g_varchar2,
  p_attribute4                 varchar2  default hr_api.g_varchar2,
  p_attribute5                 varchar2  default hr_api.g_varchar2,
  p_attribute6                 varchar2  default hr_api.g_varchar2,
  p_attribute7                 varchar2  default hr_api.g_varchar2,
  p_attribute8                 varchar2  default hr_api.g_varchar2,
  p_attribute9                 varchar2  default hr_api.g_varchar2,
  p_attribute10                varchar2  default hr_api.g_varchar2,
  p_attribute11                varchar2  default hr_api.g_varchar2,
  p_attribute12                varchar2  default hr_api.g_varchar2,
  p_attribute13                varchar2  default hr_api.g_varchar2,
  p_attribute14                varchar2  default hr_api.g_varchar2,
  p_attribute15                varchar2  default hr_api.g_varchar2,
  p_attribute16                varchar2  default hr_api.g_varchar2,
  p_attribute17                varchar2  default hr_api.g_varchar2,
  p_attribute18                varchar2  default hr_api.g_varchar2,
  p_attribute19                varchar2  default hr_api.g_varchar2,
  p_attribute20                varchar2  default hr_api.g_varchar2,
  --
  -- Element Entry Values Table
  --
  p_input_value_id1            number   default null,
  p_input_value_id2            number   default null,
  p_input_value_id3            number   default null,
  p_input_value_id4            number   default null,
  p_input_value_id5            number   default null,
  p_input_value_id6            number   default null,
  p_input_value_id7            number   default null,
  p_input_value_id8            number   default null,
  p_input_value_id9            number   default null,
  p_input_value_id10           number   default null,
  p_input_value_id11           number   default null,
  p_input_value_id12           number   default null,
  p_input_value_id13           number   default null,
  p_input_value_id14           number   default null,
  p_input_value_id15           number   default null,
  p_entry_value1               varchar2 default null,
  p_entry_value2               varchar2 default null,
  p_entry_value3               varchar2 default null,
  p_entry_value4               varchar2 default null,
  p_entry_value5               varchar2 default null,
  p_entry_value6               varchar2 default null,
  p_entry_value7               varchar2 default null,
  p_entry_value8               varchar2 default null,
  p_entry_value9               varchar2 default null,
  p_entry_value10              varchar2 default null,
  p_entry_value11              varchar2 default null,
  p_entry_value12              varchar2 default null,
  p_entry_value13              varchar2 default null,
  p_entry_value14              varchar2 default null,
  p_entry_value15              varchar2 default null,
  --
  -- Developer Descriptive Flex
  --
  p_entry_information_category varchar2  ,
  p_entry_information1         varchar2  default hr_api.g_varchar2,
  p_entry_information2         varchar2  default hr_api.g_varchar2,
  p_entry_information3         varchar2  default hr_api.g_varchar2,
  p_entry_information4         varchar2  default hr_api.g_varchar2,
  p_entry_information5         varchar2  default hr_api.g_varchar2,
  p_entry_information6         varchar2  default hr_api.g_varchar2,
  p_entry_information7         varchar2  default hr_api.g_varchar2,
  p_entry_information8         varchar2  default hr_api.g_varchar2,
  p_entry_information9         varchar2  default hr_api.g_varchar2,
  p_entry_information10        varchar2  default hr_api.g_varchar2,
  p_entry_information11        varchar2  default hr_api.g_varchar2,
  p_entry_information12        varchar2  default hr_api.g_varchar2,
  p_entry_information13        varchar2  default hr_api.g_varchar2,
  p_entry_information14        varchar2  default hr_api.g_varchar2,
  p_entry_information15        varchar2  default hr_api.g_varchar2,
  p_entry_information16        varchar2  default hr_api.g_varchar2,
  p_entry_information17        varchar2  default hr_api.g_varchar2,
  p_entry_information18        varchar2  default hr_api.g_varchar2,
  p_entry_information19        varchar2  default hr_api.g_varchar2,
  p_entry_information20        varchar2  default hr_api.g_varchar2,
  p_entry_information21        varchar2  default hr_api.g_varchar2,
  p_entry_information22        varchar2  default hr_api.g_varchar2,
  p_entry_information23        varchar2  default hr_api.g_varchar2,
  p_entry_information24        varchar2  default hr_api.g_varchar2,
  p_entry_information25        varchar2  default hr_api.g_varchar2,
  p_entry_information26        varchar2  default hr_api.g_varchar2,
  p_entry_information27        varchar2  default hr_api.g_varchar2,
  p_entry_information28        varchar2  default hr_api.g_varchar2,
  p_entry_information29        varchar2  default hr_api.g_varchar2,
  p_entry_information30        varchar2  default hr_api.g_varchar2,
  p_override_user_ent_chk      varchar2  default 'N'
 );
--
 ------------------------------------------------------------------------------
 -- NAME                                                                     --
 -- hr_entry_api.delete_element_entry                                        --
 --                                                                          --
 -- DESCRIPTION                                                              --
 -- Deletes an element entry providing full validation.                      --
 ------------------------------------------------------------------------------
--
 procedure delete_element_entry
 (
  --
  -- Delete Mode
  --
  p_dt_delete_mode             varchar2,
  --
  -- Date on which change is taking place
  --
  p_session_date               date,
  --
  -- Element Entry Table
  --
  p_element_entry_id           number
 );
--
--
end hr_entry_api;

/
