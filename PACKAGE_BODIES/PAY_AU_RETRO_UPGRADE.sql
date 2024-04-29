--------------------------------------------------------
--  DDL for Package Body PAY_AU_RETRO_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_RETRO_UPGRADE" AS
/* $Header: payauretroupg.pkb 120.14.12010000.8 2010/03/25 11:33:40 pmatamsr ship $ */
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

   Name        : pay_au_retro_upgrade

   Description : This procedure is used to upgrade elements for
                 Enhanced Retropay.

   Change List
   -----------
   Date        Name       Vers   Bug No   Description
   ----------- ---------- ------ ------- -----------------------------------
   05-JAN-2006 ksingla   120.0  4753806    Intial Version
   29-AUG-2006 priupadh  120.2  5461632    Removed Trace on and Off in Package
   11-Sep-2006 abhargav  120.3  5461629    Added log messages.
   13-Sep-2006 abhargav  120.4  5461629    Added check whether debug is enabled before printing hr_utility trace messages.
   18-Sep-2006 abhargav  120.5  5461633    Modified procedure upgrade_element() and function create_element() so that
                                           element get upgraded for the cases where retro element for the element
                                           has already been upgraded.
   19-Sep-2006 abhargav  120.7 5461633     Modified the comments.
   25-Sep-2006 abhargav  120.8 5556042     Added condition so that new time span Start Of Time - End Of time should not be
                                           attached while upgradng earning elements.
   06-Oct-2006 abhargav  120.9 5583165    Created new procedure element_exist_check() and modified fucntion create_element()
                                          to make sure element should not be partially upgrade.

================================================================================================
11i Versions - Package backported to 11i - Bug 5731490
================================================================================================
   22-Dec-2006 avenkatk  115.0 5731490      (A)Added Function  - set_retro_leg_rule
                                                     Procedure - create_enhanced_retro_defn
                                            (B)Added private procedures to create Enh Retropay Components
                                               and retro definitions.
                                            (C) Modified procedures qualify element and upgrade element to
                                                upgrade Non Earnings Standard and Non Pre Tax elements.
   04-Jan-2007 avenkatk  115.1 5731490      Added Procedure - set_enh_retro_request_group
                                                            - enable_au_enhanced_retro
   17-Jan-2007 avenkatk  115.2 5749509      Fixed issues with Null Values in Once_each_period_flag,OVN etc.
   23-Feb-2007 abhargav  115.3  5731490     Fixed issue for cases where retro element has multiple links. corrected message logic when retro
                                            element is included in multiple element sets.
   26-Feb-2007 priupadh  115.4  5879422     1. Added Warning Message to remove retro pay by element from all customer menus in procedure enable_au_enhanced_retro
                                            2. Added Cursor for listing of all business groups in  procedure enable_au_enhanced_retro

   26-Feb-2007 abhargav  115.5  5899688    Modified procedure create_input_value() so that display sequence of input value 'Pay Value' get created
                                           same as of display sequence of retro element.
   27-Feb-2007 priupadh  115.6  5879422    Adjusted Spaces in Warning message and added bug references

   22-Oct-2007 avenkatk  115.7  6455303    Added balance feeds for Retro Pre Tax Deductions LT12 Prev and GT12
   19-Jan-2009 avenkatk  115.8  5889919    Added Procedure - set_retro_status_rule. This procedure inserts/updates legislation rule for
                                           updating assignment status using View-> Retropay Status page
   09-Apr-2009 dduvvuri  115.9  8416815    Added two more parameters p_cost_allocation_keyflex_id and
                                           p_balancing_keyflex_id in call pay_element_link_api.create_element_link
                                           in procedure create_element
   20-APR-2009 skshin    115.10  7665727    Modifed qualify_element and upgrade_element procedure to upgrade Earnings Spread classification.
                                            Modifed create_element, create_element and create_ff_results procedures accordingly
                                            Added component usage for HECS Deduction, SFSS Deduction, HECS Spread Deduction and SFSS Spread Deduction in create_enhanced_retro_defn procedure
   21-MAY-2009 skshin    115.11  8406009    Added component usage for Spread Deduction in create_enhanced_retro_defn procedure
   29-Sep-2009 avenkatk  115.12  8765082    Modified qualify_element and upgrade_element for Earnings Leave Loading classification.
   10-Mar-2010 pmatamsr  115.13  9299082    Added Procedure - enable_au_retro_overlap
   25-Mar-2010 pmatamsr  115.14  9299082    Added comments for the new procedure - enable_au_retro_overlap.
*/

gv_package_name       VARCHAR2(100);
 gn_time_span_id       NUMBER;
 gn_retro_component_id NUMBER;
 g_legislation_code    VARCHAR2(10);
 g_debug boolean;

/* Procedure attaches the event group returned by the procedure create_event_group
   to the element which is retro paid. */

PROCEDURE insert_event_group(p_business_group_id IN NUMBER
                           ,p_element_type_id IN NUMBER
                           ,p_event_group_id IN NUMBER)
IS

/* Cursor fetches the information of retro element */
/* Bug 5749509 - Modified cursor for Time_definition_type.
   'N' is not a valid value for Time Definition Type, set value as Null
*/
cursor c_get_retro_element_info
is
select
ELEMENT_TYPE_ID,
EFFECTIVE_START_DATE,
EFFECTIVE_END_DATE,
FORMULA_ID,
INPUT_CURRENCY_CODE,
OUTPUT_CURRENCY_CODE,
CLASSIFICATION_ID,
BENEFIT_CLASSIFICATION_ID,
ADDITIONAL_ENTRY_ALLOWED_FLAG,
ADJUSTMENT_ONLY_FLAG,
CLOSED_FOR_ENTRY_FLAG,
ELEMENT_NAME,
REPORTING_NAME,
DESCRIPTION,
INDIRECT_ONLY_FLAG,
MULTIPLE_ENTRIES_ALLOWED_FLAG,
MULTIPLY_VALUE_FLAG,
POST_TERMINATION_RULE,
PROCESS_IN_RUN_FLAG,
PROCESSING_PRIORITY,
PROCESSING_TYPE,
STANDARD_LINK_FLAG,
COMMENT_ID,
LEGISLATION_SUBGROUP,
QUALIFYING_AGE,
QUALIFYING_LENGTH_OF_SERVICE,
QUALIFYING_UNITS,
ELEMENT_INFORMATION_CATEGORY,
ELEMENT_INFORMATION1,
ELEMENT_INFORMATION2,
ELEMENT_INFORMATION3,
THIRD_PARTY_PAY_ONLY_FLAG,
ITERATIVE_FLAG,
ITERATIVE_FORMULA_ID,
ITERATIVE_PRIORITY,
CREATOR_TYPE,
RETRO_SUMM_ELE_ID,
GROSSUP_FLAG,
PROCESS_MODE,
ADVANCE_INDICATOR,
ADVANCE_PAYABLE,
ADVANCE_DEDUCTION,
PROCESS_ADVANCE_ENTRY,
PRORATION_GROUP_ID,
PRORATION_FORMULA_ID,
RECALC_EVENT_GROUP_ID,
ONCE_EACH_PERIOD_FLAG,
decode(TIME_DEFINITION_TYPE,'N',NULL,TIME_DEFINITION_TYPE) TIME_DEFINITION_TYPE,  /* Bug 5749509*/
TIME_DEFINITION_ID,
OBJECT_VERSION_NUMBER
from pay_element_types_f
where element_type_id = p_element_type_id
and business_group_id = p_business_group_id
ORDER BY effective_start_date;

rec_element_types c_get_retro_element_info%ROWTYPE;
l_effective_start_date DATE;
l_effective_end_date DATE;
l_comment_id NUMBER;
lv_procedure_name VARCHAR2(50);
l_ovn NUMBER;
l_processing_priority_warning BOOLEAN ;
l_element_name_warning BOOLEAN;
l_element_name_change_warning BOOLEAN;

BEGIN
g_debug := hr_utility.debug_enabled;
lv_procedure_name := 'insert_event_group';

IF g_debug THEN
 hr_utility.trace('Entering ' || lv_procedure_name);
END if;


open c_get_retro_element_info;
LOOP
   fetch c_get_retro_element_info into rec_element_types;

   IF c_get_retro_element_info%NOTFOUND THEN
      EXIT;
   END IF;

   IF rec_element_types.RECALC_EVENT_GROUP_ID IS NULL THEN

/* Bug 5749509 - Set OVN as 1 if its found to be NULL */

      l_ovn := NVL(rec_element_types.OBJECT_VERSION_NUMBER,1);

/* Bug 5749509 - ONCE_EACH_PERIOD_FLAG - Specify default of 'N' if existing value is Null
               - TIME_DEFINITION_TYPE,TIME_DEFINITION_TYPE added in API call
               - If TIME_DEFINITION_TYPE is 'N', set it as Null
*/
      PAY_ELEMENT_TYPES_API.UPDATE_ELEMENT_TYPE
      (p_effective_date                  => rec_element_types.EFFECTIVE_START_DATE
      ,p_datetrack_update_mode           => 'CORRECTION'
      ,p_element_type_id                 => rec_element_types.ELEMENT_TYPE_ID
      ,p_object_version_number           => l_ovn
      ,p_recalc_event_group_id           => p_event_group_id
      ,p_formula_id                      => rec_element_types.FORMULA_ID
      ,p_benefit_classification_id       => rec_element_types.BENEFIT_CLASSIFICATION_ID
      ,p_additional_entry_allowed_fla    => rec_element_types.ADDITIONAL_ENTRY_ALLOWED_FLAG
      ,p_adjustment_only_flag            => rec_element_types.ADJUSTMENT_ONLY_FLAG
      ,p_closed_for_entry_flag           => rec_element_types.CLOSED_FOR_ENTRY_FLAG
      ,p_element_name                    => rec_element_types.ELEMENT_NAME
      ,p_reporting_name                  => rec_element_types.REPORTING_NAME
      ,p_description                     => rec_element_types.DESCRIPTION
      ,p_indirect_only_flag              => rec_element_types.INDIRECT_ONLY_FLAG
      ,p_multiple_entries_allowed_fla    => rec_element_types.MULTIPLE_ENTRIES_ALLOWED_FLAG
      ,p_multiply_value_flag             => rec_element_types.MULTIPLY_VALUE_FLAG
      ,p_post_termination_rule           => rec_element_types.POST_TERMINATION_RULE
      ,p_process_in_run_flag             => rec_element_types.PROCESS_IN_RUN_FLAG
      ,p_processing_priority             => rec_element_types.PROCESSING_PRIORITY
      ,p_standard_link_flag              => rec_element_types.STANDARD_LINK_FLAG
      ,p_third_party_pay_only_flag       => rec_element_types.THIRD_PARTY_PAY_ONLY_FLAG
      ,p_iterative_flag                  => rec_element_types.ITERATIVE_FLAG
      ,p_iterative_formula_id            => rec_element_types.ITERATIVE_FORMULA_ID
      ,p_iterative_priority              => rec_element_types.ITERATIVE_PRIORITY
      ,p_creator_type                    => rec_element_types.CREATOR_TYPE
      ,p_retro_summ_ele_id               => rec_element_types.RETRO_SUMM_ELE_ID
      ,p_grossup_flag                    => rec_element_types.GROSSUP_FLAG
      ,p_process_mode                    => rec_element_types.PROCESS_MODE
      ,p_advance_indicator               => rec_element_types.ADVANCE_INDICATOR
      ,p_advance_payable                 => rec_element_types.ADVANCE_PAYABLE
      ,p_advance_deduction               => rec_element_types.ADVANCE_DEDUCTION
      ,p_process_advance_entry           => rec_element_types.PROCESS_ADVANCE_ENTRY
      ,p_proration_group_id              => rec_element_types.PRORATION_GROUP_ID
      ,p_proration_formula_id            => rec_element_types.PRORATION_FORMULA_ID
      ,p_qualifying_age                  => rec_element_types.QUALIFYING_AGE
      ,p_qualifying_length_of_service    => rec_element_types.QUALIFYING_LENGTH_OF_SERVICE
      ,p_qualifying_units                => rec_element_types.QUALIFYING_UNITS
      ,p_element_information_category    => rec_element_types.ELEMENT_INFORMATION_CATEGORY
      ,p_element_information1            => rec_element_types.ELEMENT_INFORMATION1
      ,p_element_information2            => rec_element_types.ELEMENT_INFORMATION2
      ,p_element_information3            => rec_element_types.ELEMENT_INFORMATION3
      ,p_once_each_period_flag           => nvl(rec_element_types.ONCE_EACH_PERIOD_FLAG,'N')
      ,p_time_definition_type            => rec_element_types.TIME_DEFINITION_TYPE
      ,p_time_definition_id              => rec_element_types.TIME_DEFINITION_ID
      ,p_effective_start_date            => l_effective_start_date
      ,p_effective_end_date              => l_effective_end_date
      ,p_comment_id                      => l_comment_id
      ,p_processing_priority_warning     => l_processing_priority_warning
      ,p_element_name_warning            => l_element_name_warning
      ,p_element_name_change_warning     => l_element_name_change_warning
      );

      IF g_debug THEN
       hr_utility.trace('Updated Event Group for Element: ' || p_element_type_id);
      END if;

   END IF;

END LOOP;

close c_get_retro_element_info;

   IF g_debug THEN
      hr_utility.trace('Leaving ' || lv_procedure_name);
   END if;

exception
   when others then
      IF g_debug THEN
       hr_utility.set_location(gv_package_name || lv_procedure_name, 200);
       hr_utility.trace('ERROR:' || sqlcode ||'-'|| substr(sqlerrm,1,80));
      End if;

      raise;

END;

/* Procedure creates the event group of name "AU Enhanced Retro Event Group"
   and returns the event group id. */

PROCEDURE create_event_group(p_business_group_id IN NUMBER,
                             p_event_group_id OUT NOCOPY NUMBER)
IS

/* Checks whehter AU Enhanced Retro Event Group already exist */

CURSOR c_get_event_group_id
IS
SELECT event_group_id
FROM pay_event_groups
WHERE business_group_id = p_business_group_id
AND event_group_name = 'AU Enhanced Retro Event Group';

/* Gets the dated_table_id for tables PAY_ELEMENT_ENTRIES_F and PAY_ELEMENT_ENTRY_VALUES_F */
CURSOR c_get_dated_table_id(c_table_name pay_dated_tables.table_name%TYPE)
IS
select dated_table_id
from pay_dated_tables
where table_name = c_table_name;

l_event_group_id NUMBER;
l_effective_date DATE;
l_ovn NUMBER;
lv_procedure_name VARCHAR2(50);
l_datetracked_event_id NUMBER;
l_ele_entry_table_id NUMBER;
l_ele_entry_value_table_id NUMBER;


BEGIN
g_debug := hr_utility.debug_enabled;
l_effective_date := to_date('1900/01/01','YYYY/MM/DD');

lv_procedure_name := 'create_event_group';

IF g_debug THEN
  hr_utility.trace('Entering ' || lv_procedure_name);
END if;

/* Checks whether event group already exist */
OPEN c_get_event_group_id;
FETCH c_get_event_group_id INTO l_event_group_id;
IF c_get_event_group_id%NOTFOUND THEN
   pay_event_groups_api.create_event_group(p_effective_date                 => l_effective_date
                                          ,p_event_group_name               => 'AU Enhanced Retro Event Group'
                                          ,p_event_group_type               => 'R'
                                          ,p_business_group_id              => p_business_group_id
                                          ,p_event_group_id                 => l_event_group_id
                                          ,p_object_version_number          => l_ovn
                                          );
   OPEN c_get_dated_table_id('PAY_ELEMENT_ENTRIES_F');
   FETCH c_get_dated_table_id INTO l_ele_entry_table_id;
   CLOSE c_get_dated_table_id;

   OPEN c_get_dated_table_id('PAY_ELEMENT_ENTRY_VALUES_F');
   FETCH c_get_dated_table_id INTO l_ele_entry_value_table_id;
   CLOSE c_get_dated_table_id;

/* Creates Date Tracked event of Type Update on column EFFECTIVE_START_DATE of table PAY_ELEMENT_ENTRIES_F  */
   pay_datetracked_events_api.create_datetracked_event(p_effective_date               => l_effective_date
                                                      ,p_event_group_id               => l_event_group_id
                                                      ,p_dated_table_id               => l_ele_entry_table_id
                                                      ,p_update_type                  => 'U'
                                                      ,p_column_name                  => 'EFFECTIVE_START_DATE'
                                                      ,p_business_group_id            => p_business_group_id
                                                      ,p_legislation_code             => NULL
                                                      ,p_datetracked_event_id         => l_datetracked_event_id
                                                      ,p_object_version_number        => l_ovn
                                                     );
/* Creates Date Tracked event of Type Update on column EFFECTIVE_END_DATE of table PAY_ELEMENT_ENTRIES_F  */
   pay_datetracked_events_api.create_datetracked_event(p_effective_date               => l_effective_date
                                                      ,p_event_group_id               => l_event_group_id
                                                      ,p_dated_table_id               => l_ele_entry_table_id
                                                      ,p_update_type                  => 'U'
                                                      ,p_column_name                  => 'EFFECTIVE_END_DATE'
                                                      ,p_business_group_id            => p_business_group_id
                                                      ,p_legislation_code             => NULL
                                                      ,p_datetracked_event_id         => l_datetracked_event_id
                                                      ,p_object_version_number        => l_ovn
                                                     );
/* Creates Date Tracked event of Type End Date on table PAY_ELEMENT_ENTRIES_F  */
 pay_datetracked_events_api.create_datetracked_event(p_effective_date               => l_effective_date
                                                      ,p_event_group_id               => l_event_group_id
                                                      ,p_dated_table_id               => l_ele_entry_table_id
                                                      ,p_update_type                  => 'E'
                                                      ,p_column_name                  => NULL
                                                      ,p_business_group_id            => p_business_group_id
                                                      ,p_legislation_code             => NULL
                                                      ,p_datetracked_event_id         => l_datetracked_event_id
                                                      ,p_object_version_number        => l_ovn
                                                     );
/* Creates Date Tracked event of Type insert on table PAY_ELEMENT_ENTRIES_F  */

   pay_datetracked_events_api.create_datetracked_event(p_effective_date               => l_effective_date
                                                      ,p_event_group_id               => l_event_group_id
                                                      ,p_dated_table_id               => l_ele_entry_table_id
                                                      ,p_update_type                  => 'I'
                                                      ,p_column_name                  => NULL
                                                      ,p_business_group_id            => p_business_group_id
                                                      ,p_legislation_code             => NULL
                                                      ,p_datetracked_event_id         => l_datetracked_event_id
                                                      ,p_object_version_number        => l_ovn
                                                     );
/* Creates Date Tracked event of Type delete on table PAY_ELEMENT_ENTRIES_F  */
   pay_datetracked_events_api.create_datetracked_event(p_effective_date               => l_effective_date
                                                      ,p_event_group_id               => l_event_group_id
                                                      ,p_dated_table_id               => l_ele_entry_table_id
                                                      ,p_update_type                  => 'D'
                                                      ,p_column_name                  => NULL
                                                      ,p_business_group_id            => p_business_group_id
                                                      ,p_legislation_code             => NULL
                                                      ,p_datetracked_event_id         => l_datetracked_event_id
                                                      ,p_object_version_number        => l_ovn
                                                     );
/* Creates Date Tracked event of Type Correction  on table PAY_ELEMENT_ENTRY_VALUES_F  */
   pay_datetracked_events_api.create_datetracked_event(p_effective_date               => l_effective_date
                                                      ,p_event_group_id               => l_event_group_id
                                                      ,p_dated_table_id               => l_ele_entry_value_table_id
                                                      ,p_update_type                  => 'C'
                                                      ,p_column_name                  => 'SCREEN_ENTRY_VALUE'
                                                      ,p_business_group_id            => p_business_group_id
                                                      ,p_legislation_code             => NULL
                                                      ,p_datetracked_event_id         => l_datetracked_event_id
                                                      ,p_object_version_number        => l_ovn
                                                     );

END IF;

p_event_group_id := l_event_group_id;

 IF g_debug THEN
   hr_utility.trace('p_event_group_id: ' || p_event_group_id);
   hr_utility.trace('Leaving ' || lv_procedure_name);
 End If;

exception
   when others then
     IF g_debug THEN
      hr_utility.set_location(gv_package_name || lv_procedure_name, 200);
      hr_utility.trace('ERROR:' || sqlcode ||'-'|| substr(sqlerrm,1,80));
     End If;

      raise;
END;

/* procedure attaches the formula AU_RETRO_PROCESSED_COUNT to the created  elements and also create the required formula result rules.
 Following parameters are passed to the procedure:
  a) Business Group ID
  b) Retro Type - This parameter can have three values: "GT12", "LT12 Prev", and "LT12 Curr".
  c) Retro Element Type ID: In parameter to hold the element type id of the retro element created. */
PROCEDURE create_ff_results(p_business_group_id IN NUMBER,
                       p_retro_type IN VARCHAR2,
                       p_element_type_id IN NUMBER,
                       p_bal_type NUMBER)  --bug 7665727
IS

/* Gets the formula id for formula AU_RETRO_PROCESSED_COUNT*/

CURSOR c_get_formula_id
IS
SELECT ff.formula_id
FROM ff_formulas_f ff
WHERE ff.formula_name = 'AU_RETRO_PROCESSED_COUNT'
AND ff.legislation_code = 'AU';

/* Gets the processing rule id for element */
CURSOR c_get_formula_results(c_element_type_id pay_element_types_f.element_type_id%type)
IS
SELECT pspr.status_processing_rule_id
FROM pay_status_processing_rules_f pspr
WHERE pspr.business_group_id = p_business_group_id
AND pspr.element_type_id = c_element_type_id;

/* Checks whether formula result rule exist for the element */
CURSOR c_get_formula_result_rules(c_element_type_id pay_element_types_f.element_type_id%type,
                                  c_result_name pay_formula_result_rules_f.result_name%type,
                                  c_result_rule_type pay_formula_result_rules_f.result_rule_type%type,
                                  c_input_value_id pay_formula_result_rules_f.input_value_id%type)
IS
select count(*)
from pay_status_processing_rules_f pssp,
     pay_formula_result_rules_f pfrr
where pssp.element_type_id = c_element_type_id
and   pfrr.status_processing_rule_id = pssp.status_processing_rule_id
AND   pfrr.result_name = c_result_name
AND   pfrr.result_rule_type = c_result_rule_type
AND   DECODE(c_result_rule_type, 'M', '999', pfrr.input_value_id) = DECODE(c_result_rule_type, 'M', '999', c_input_value_id);

/* Fetches the input value id for seeded Retropay elements */

CURSOR c_get_input_value_id(c_element_name pay_element_types_f.element_name%type, c_name pay_input_values_f.name%type)
IS
SELECT DISTINCT pet.element_type_id, piv.input_value_id
FROM pay_input_values_f piv,
     pay_element_types_f pet
WHERE pet.element_name = c_element_name
AND pet.legislation_code = 'AU'
AND piv.element_type_id = pet.element_type_id
AND piv.NAME = c_name
AND piv.legislation_code = 'AU';

l_status_processing_rule_id NUMBER;
l_legislation_code VARCHAR2(10);
l_effective_start_date DATE ;
l_effective_end_date DATE ;
l_processing_rule VARCHAR2(2);
l_formula_id NUMBER;
l_result_name VARCHAR2(50);
l_result_element_name VARCHAR2(80);
l_result_rule_type VARCHAR2(10);
l_input_value_id NUMBER;
l_rules_exists NUMBER;
l_rowid VARCHAR2(100);
l_formula_result_rule_id NUMBER;
l_element_type_id NUMBER;
lv_procedure_name VARCHAR2(50);

BEGIN
g_debug := hr_utility.debug_enabled;
lv_procedure_name := 'create_ff_results';

IF g_debug THEN
 hr_utility.trace('Entering ' || lv_procedure_name);
End if;


l_legislation_code := 'AU';
IF p_bal_type = 1 THEN  /*bug 7665727 to set effective_date for Retro Earnings Spread */
  l_effective_start_date := to_date('2009/07/01','YYYY/MM/DD');
ELSE
  l_effective_start_date := to_date('2005/07/01','YYYY/MM/DD');
END IF;
l_effective_end_date := to_date('4712/12/31','YYYY/MM/DD');
l_processing_rule := 'P';
l_result_name := 'L_DUMMY';
l_result_rule_type := 'I';

IF g_debug THEN
 hr_utility.trace('p_business_group_id: ' || p_business_group_id);
 hr_utility.trace('p_retro_type: ' || p_retro_type);
 hr_utility.trace('p_element_type_id: ' || p_element_type_id);
End if;

/* Gets the processing rule id for element */
OPEN c_get_formula_results(p_element_type_id);
FETCH c_get_formula_results INTO l_status_processing_rule_id;
CLOSE c_get_formula_results;

/* Gets the formula id for formula AU_RETRO_PROCESSED_COUNT*/
OPEN c_get_formula_id;
FETCH c_get_formula_id INTO l_formula_id;
CLOSE c_get_formula_id;

IF g_debug THEN
 hr_utility.trace('l_formula_id: ' || l_formula_id);
End if;

IF nvl(l_status_processing_rule_id,9999) = 9999 THEN

        l_Status_Processing_Rule_Id := pay_formula_results.ins_stat_proc_rule(
                  p_legislation_code           => l_legislation_code,
                  p_effective_start_date       => l_effective_start_date,
                  p_effective_end_date         => l_effective_end_date,
                  p_element_type_id            => p_element_type_id,
                  p_formula_id                 => l_formula_id,
                  p_processing_rule            => l_processing_rule);
END IF;


/* Bug 8765082, p_bal_type values is used to decide the Indirect Results in the following manner
               Index    Element Type
                0       Earnings Standard
                1       Earnings Spread
                2       Pre Tax Deductions
                3       Earnings Leave Loading
*/

IF p_bal_type = 1 THEN /* bug 7665727 Retro Earnings Spread */
      IF p_retro_type = 'GT12' THEN

         l_result_element_name := 'Retropay Earnings Spread GT 12 Mths Amount';
         OPEN c_get_input_value_id('Retropay Earnings Spread GT 12 Mths Amount','GT_12_Mths_Amount');
         FETCH c_get_input_value_id INTO l_element_type_id, l_input_value_id;
         CLOSE c_get_input_value_id;

      ELSIF p_retro_type = 'LT12 Prev' THEN

         l_result_element_name := 'Retropay Earnings Spread LT 12 Mths Prev Yr Amount';
         OPEN c_get_input_value_id('Retropay Earnings Spread LT 12 Mths Prev Yr Amount','LT_12_Mths_Prev_Yr_Amount');
         FETCH c_get_input_value_id INTO l_element_type_id, l_input_value_id;
         CLOSE c_get_input_value_id;

      ELSIF p_retro_type = 'LT12 Curr' THEN

         l_result_element_name := 'Retropay Earnings Spread LT 12 Mths Curr Amount';
         OPEN c_get_input_value_id('Retropay Earnings Spread LT 12 Mths Curr Amount','LT_12_Mths_Curr_Amount');
         FETCH c_get_input_value_id INTO l_element_type_id, l_input_value_id;
         CLOSE c_get_input_value_id;

      END IF;
ELSIF p_bal_type = 2 THEN  /* Bug 8765082 - Pre Tax Deductions */
      IF p_retro_type = 'GT12' THEN

         l_result_element_name := 'Retro Pre Tax GT 12 Mths Amount';
         OPEN c_get_input_value_id('Retro Pre Tax GT 12 Mths Amount','GT_12_Mths_Amount');
         FETCH c_get_input_value_id INTO l_element_type_id, l_input_value_id;
         CLOSE c_get_input_value_id;

      ELSIF p_retro_type = 'LT12 Prev' THEN

         l_result_element_name := 'Retro Pre Tax LT 12 Mths Prev Yr Amount';
         OPEN c_get_input_value_id('Retro Pre Tax LT 12 Mths Prev Yr Amount','LT_12_Mths_Prev_Yr_Amount');
         FETCH c_get_input_value_id INTO l_element_type_id, l_input_value_id;
         CLOSE c_get_input_value_id;

     END IF;
ELSIF p_bal_type = 3 THEN   /* Bug 8765082 - Earnings Leave Loading */

      IF p_retro_type = 'GT12' THEN

         l_result_element_name := 'Retropay Earnings Leave Loading GT 12 Mths Amount';
         OPEN c_get_input_value_id('Retropay Earnings Leave Loading GT 12 Mths Amount','GT_12_Mths_Amount');
         FETCH c_get_input_value_id INTO l_element_type_id, l_input_value_id;
         CLOSE c_get_input_value_id;

      ELSIF p_retro_type = 'LT12 Prev' THEN

         l_result_element_name := 'Retropay Earnings Leave Loading LT 12 Mths Prev Yr Amount';
         OPEN c_get_input_value_id('Retropay Earnings Leave Loading LT 12 Mths Prev Yr Amount','LT_12_Mths_Prev_Yr_Amount');
         FETCH c_get_input_value_id INTO l_element_type_id, l_input_value_id;
         CLOSE c_get_input_value_id;
     END IF;

ELSE /* Retro Earnings Standard */
      IF p_retro_type = 'GT12' THEN

         l_result_element_name := 'Retropay GT 12 Mths Amount';
         OPEN c_get_input_value_id('Retropay GT 12 Mths Amount','GT_12_Mths_Amount');
         FETCH c_get_input_value_id INTO l_element_type_id, l_input_value_id;
         CLOSE c_get_input_value_id;

      ELSIF p_retro_type = 'LT12 Prev' THEN

         l_result_element_name := 'Retropay LT 12 Mths Prev Yr Amount';
         OPEN c_get_input_value_id('Retropay LT 12 Mths Prev Yr Amount','LT_12_Mths_Prev_Yr_Amount');
         FETCH c_get_input_value_id INTO l_element_type_id, l_input_value_id;
         CLOSE c_get_input_value_id;

      ELSIF p_retro_type = 'LT12 Curr' THEN

         l_result_element_name := 'Retropay LT 12 Mths Curr Yr Amount';
         OPEN c_get_input_value_id('Retropay LT 12 Mths Curr Yr Amount','LT_12_Mths_Curr_Yr_Amount');
         FETCH c_get_input_value_id INTO l_element_type_id, l_input_value_id;
         CLOSE c_get_input_value_id;

      END IF;
END IF;
/* Checks whether formula result rule exists for the retro element */

OPEN c_get_formula_result_rules(p_element_type_id,
                                l_result_name,
                                l_result_rule_type,
                                l_input_value_id);
FETCH c_get_formula_result_rules INTO l_rules_exists;
CLOSE c_get_formula_result_rules;

IF l_rules_exists = 0 THEN

         l_formula_result_rule_id := pay_formula_results.ins_form_res_rule
          (
           p_business_group_id          => p_business_group_id,
           p_effective_start_date       => l_effective_start_date,
           p_effective_end_date         => l_effective_end_date,
           p_status_processing_rule_id  => l_status_processing_rule_id,
           p_input_value_id             => l_input_value_id,
           p_result_name                => l_result_name,
           p_result_rule_type           => l_result_rule_type,
           p_element_type_id              => l_element_type_id
            );
END IF;

IF g_debug THEN
   hr_utility.trace('Leaving ' || lv_procedure_name);
End if;

exception
   when others then
   IF g_debug THEN
      hr_utility.set_location(gv_package_name || lv_procedure_name, 200);
      hr_utility.trace('ERROR:' || sqlcode ||'-'|| substr(sqlerrm,1,80));
   End if;
      raise;
END;

/* Procedure creates the balance feeds for the created elements.
   Following parameters are passed to the above procedure:
   a)   Business Group ID
   b)   Element Type ID - Element Type ID of the element for which the Retro element is created
   c)   Retro Type - This parameter can have three values: "GT12", "LT12 Prev", and "LT12 Curr".
   d)   Retro Element Type ID: In parameter to hold the element type id of the retro element created.
   e)   Balance Type Id - Balance Type Id of the seeded balance
   f)   Scale - This parameter decides whether the pay value of the retro element should add or subtract to
                the seeded balance based on element classification. */

procedure create_balance_feeds(p_business_group_id IN NUMBER,
                       p_retro_element_id IN NUMBER,
                       p_retro_type IN VARCHAR2,
                       p_element_type_id IN NUMBER,
                       p_balance_type_id IN NUMBER,
                       p_scale IN NUMBER,
                       p_bal_type IN NUMBER)  --bug7665727
IS

/* Gets the input value id of Retro Element */
CURSOR c_get_input_values
IS
SELECT name,
       input_value_id
FROM pay_input_values_f
WHERE business_group_id = p_business_group_id
AND element_type_id = p_retro_element_id;

/* Gets the balance feeds attached with the input value of retro element*/
CURSOR c_get_balance_feeds(c_input_value_id pay_input_values_f.input_value_id%TYPE)
IS
SELECT balance_type_id, scale
FROM pay_balance_feeds_f
WHERE input_value_id = c_input_value_id
AND business_group_id = p_business_group_id;

/* Checks whether balance feed exist for element created by upgrade process */
cursor check_feed_exists(c_balance_type_id pay_balance_feeds_f.balance_type_id%type
        ,c_input_value_id pay_balance_feeds_f.input_value_id%type)
is
select count(*)
from pay_balance_feeds_f
where balance_type_id = c_balance_type_id
and input_value_id = c_input_value_id;

/* Gets the input value id of Element created by Upgrade Process*/
CURSOR c_get_input_value_id(c_name pay_input_values_f.name%type)
IS
SELECT input_value_id
FROM pay_input_values_f
WHERE NAME = c_name
AND element_type_id = p_element_type_id
AND business_group_id = p_business_group_id;

l_input_value_id NUMBER;
l_exists NUMBER;
l_effective_date DATE;
lv_procedure_name VARCHAR2(50);

BEGIN
g_debug := hr_utility.debug_enabled;

lv_procedure_name := 'create_balance_feeds';

IF g_debug THEN
 hr_utility.trace('Entering ' || lv_procedure_name);
End if;

IF p_bal_type IN (1,3) THEN  /*bug 7665727, 8765082 to set effective_date for Retro Earnings Spread, Leave Loading */
l_effective_date := to_date('2009/07/01','YYYY/MM/DD');
ELSE
l_effective_date := to_date('2005/07/01','YYYY/MM/DD');
END IF;

/* Gets the input value id of Retro Element */
FOR csr_rec_iv IN c_get_input_values
LOOP
/* Gets the balance feed attached with the input value */
   FOR csr_rec_bf IN c_get_balance_feeds(csr_rec_iv.input_value_id)
   LOOP
      /* Gets the input value id of Element created by Upgrade Process*/
      OPEN c_get_input_value_id(csr_rec_iv.name);
      FETCH c_get_input_value_id INTO l_input_value_id;
      CLOSE c_get_input_value_id;

      IF g_debug THEN
       hr_utility.trace('Creating Balance Feed for input value ' || csr_rec_iv.name);
       hr_utility.trace('Input Value ID: ' || l_input_value_id);
      End if;

      IF UPPER(csr_rec_iv.NAME) = UPPER('Pay Value') THEN
         /* Checks whether seeded balance feed exist for element created by upgrade process */
         OPEN check_feed_exists(p_balance_type_id, l_input_value_id);
         FETCH check_feed_exists INTO l_exists;
         CLOSE check_feed_exists;
         /* Checks whether balance feed does not exist and element classification is not of type Pre Tax Deductions */
         IF l_exists = 0 AND p_scale <> 0 THEN

          IF g_debug THEN
            hr_utility.trace('Create Seeded Balance Feed');
           End if;
                /* Creates balance feeds for the elements created by upgrade process */
                hr_balances.ins_balance_feed(
                p_option                        => 'INS_MANUAL_FEED',
                p_input_value_id                => l_input_value_id,
                p_element_type_id               => NULL,
                p_primary_classification_id     => NULL,
                p_sub_classification_id         => NULL,
                p_sub_classification_rule_id    => NULL,
                p_balance_type_id               => p_balance_type_id,
                p_scale                         => to_char(p_scale),
                p_session_date                  => l_effective_date,
                p_business_group                => p_business_group_id,
                p_legislation_code              => NULL,
                p_mode                          => 'USER');
             IF g_debug THEN
               hr_utility.trace('Created Seeded Balance Feed');
             End if;
         END IF;
      END IF;
    /* Checks whether user balance feed exist for element created by upgrade process */
      OPEN check_feed_exists(csr_rec_bf.balance_type_id, l_input_value_id);
      FETCH check_feed_exists INTO l_exists;
      CLOSE check_feed_exists;

      IF l_exists = 0 THEN

         IF g_debug THEN
           hr_utility.trace('Create User Balance Feed FOR balance TYPE id: ' || csr_rec_bf.balance_type_id);
         End if;

                hr_balances.ins_balance_feed(
                p_option                        => 'INS_MANUAL_FEED',
                p_input_value_id                => l_input_value_id,
                p_element_type_id               => NULL,
                p_primary_classification_id     => NULL,
                p_sub_classification_id         => NULL,
                p_sub_classification_rule_id    => NULL,
                p_balance_type_id               => csr_rec_bf.balance_type_id,
                p_scale                         => to_char(csr_rec_bf.scale),
                p_session_date                  => l_effective_date,
                p_business_group                => p_business_group_id,
                p_legislation_code              => NULL,
                p_mode                          => 'USER');
         IF g_debug THEN
          hr_utility.trace('Created User Balance Feed');
         End if;

      END IF;

   END LOOP;

END LOOP;

 IF g_debug THEN
   hr_utility.trace('Leaving ' || lv_procedure_name);
 End if;
exception
   when others then
      IF g_debug THEN
        hr_utility.set_location(gv_package_name || lv_procedure_name, 200);
        hr_utility.trace('ERROR:' || sqlcode ||'-'|| substr(sqlerrm,1,80));
       End if;
       raise;
END;

 /*  procedure creates the input value for the retro elements created.
    Following parameters are passed to the above procedure:
     a) Business Group ID
     b) Element Type ID - Element Type ID of the element for which the Retro element is created
     c) Retro Type - This parameter can have three values: "GT12", "LT12 Prev", and "LT12 Curr"
     d) Retro Element Type ID: In parameter to hold the element type id of the retro element created. */
procedure create_input_value(p_business_group_id IN NUMBER,
                       p_retro_element_id IN NUMBER,
                       p_retro_type IN VARCHAR2,
                       p_element_type_id IN NUMBER)
is
/* Fetches the details of input value of retro element */
cursor c_get_input_value_info
is
select
LOOKUP_TYPE,
BUSINESS_GROUP_ID,
FORMULA_ID,
DISPLAY_SEQUENCE,
GENERATE_DB_ITEMS_FLAG,
HOT_DEFAULT_FLAG,
MANDATORY_FLAG,
NAME,
UOM,
DEFAULT_VALUE,
MAX_VALUE,
MIN_VALUE,
WARNING_OR_ERROR,
VALUE_SET_ID
from pay_input_values_f
where element_type_id = p_retro_element_id
and business_group_id = p_business_group_id;

rec_input_values c_get_input_value_info%ROWTYPE;
l_input_value_id NUMBER;
l_ovn NUMBER ;
l_effective_start_date date;
l_effective_end_date date;
l_val_warning boolean;
l_max_warning boolean;
l_basis_warning boolean;
l_formula_warning boolean;
l_asg_warning boolean;
l_message VARCHAR2(100);
l_effective_date date;

/* Checks whether input value already exist for the element created by Upgrade process */

CURSOR c_input_exists(c_input_value_name VARCHAR2)
IS
SELECT piv.input_value_id,effective_start_date,object_version_number
FROM pay_input_values_f piv
WHERE piv.element_type_id = p_element_type_id
AND piv.NAME = c_input_value_name
AND piv.business_group_id = p_business_group_id;

lv_procedure_name VARCHAR2(50);

/* Bug#5899688 */
l_EFFECTIVE_START_DATE_invl  date;
l_EFFECTIVE_END_DATE_invl    date;
l_DEFAULT_VAL_WARNING_invl   boolean;
l_MIN_MAX_WARNING_invl       boolean;
l_LINK_INP_VAL_WARNING_invl  boolean;
l_PAY_BASIS_WARNING_invl     boolean;
l_FORMULA_WARNING_invl       boolean;
l_ASSIGNMENT_ID_WARNING_invl boolean;
l_FORMULA_MESSAGE_invl       varchar2(100);
lv_ovn_invl number;

rec_input_values_user c_input_exists%ROWTYPE;
begin
g_debug := hr_utility.debug_enabled;
lv_procedure_name := 'create_input_value';

 IF g_debug THEN
   hr_utility.trace('Entering ' || lv_procedure_name);
  End if;

l_effective_date := to_date('2005/07/01','YYYY/MM/DD');

IF g_debug THEN
  hr_utility.trace(p_business_group_id || ' p_business_group_id');
  hr_utility.trace(p_retro_element_id || ' p_retro_element_id');
  hr_utility.trace(p_element_type_id || ' p_element_type_id');
  hr_utility.trace(p_retro_type || ' p_retro_type');
 End if;

/* Fetches the details of input value of retro element */
open c_get_input_value_info;
loop
   fetch c_get_input_value_info into rec_input_values;
   /* Exit if retro element does not exist  */
   IF c_get_input_value_info%NOTFOUND THEN
    exit;
   END IF;
   /* Checks whether input value already exist for the element created by Upgrade process */
   open c_input_exists(rec_input_values.NAME);
    fetch c_input_exists into rec_input_values_user;
        /* Bug#5899688 checking whether sequence of input value 'Pay Value' of GT12, LT12 elements
                       is different from retro element */
    if c_input_exists%found and rec_input_values.name='Pay Value'
       and rec_input_values.DISPLAY_SEQUENCE <> 1 then

            lv_ovn_invl :=  rec_input_values_user.object_version_number;
            /* Bug#5899688 updates display sequence of input value 'Pay Value' of GT12, LT12 elements
                           if sequence is different from retro element's input value */
             PAY_INPUT_VALUE_API.UPDATE_INPUT_VALUE
              ( P_EFFECTIVE_DATE           =>  rec_input_values_user.effective_start_date
               ,P_DATETRACK_MODE       =>  'CORRECTION'
               ,P_INPUT_VALUE_ID       =>  rec_input_values_user.input_value_id
               ,P_OBJECT_VERSION_NUMBER    =>  lv_ovn_invl
               ,P_DISPLAY_SEQUENCE         =>  rec_input_values.DISPLAY_SEQUENCE
               ,P_EFFECTIVE_START_DATE     =>  l_EFFECTIVE_START_DATE_invl
               ,P_EFFECTIVE_END_DATE       =>  l_EFFECTIVE_END_DATE_invl
               ,P_DEFAULT_VAL_WARNING      =>  l_DEFAULT_VAL_WARNING_invl
               ,P_MIN_MAX_WARNING          =>  l_MIN_MAX_WARNING_invl
               ,P_LINK_INP_VAL_WARNING     =>  l_LINK_INP_VAL_WARNING_invl
               ,P_PAY_BASIS_WARNING        =>  l_PAY_BASIS_WARNING_invl
               ,P_FORMULA_WARNING          =>  l_FORMULA_WARNING_invl
               ,P_ASSIGNMENT_ID_WARNING    =>  l_ASSIGNMENT_ID_WARNING_invl
               ,P_FORMULA_MESSAGE          =>  l_FORMULA_MESSAGE_invl
                 );
   end if;

   if c_input_exists%notfound then
     IF g_debug THEN
       hr_utility.trace(rec_input_values.NAME || ' does not exists');
      End if;
         /* Created input value similar to retro element for the element created by Upgrade process */
       PAY_INPUT_VALUE_API.CREATE_INPUT_VALUE
      ( P_EFFECTIVE_DATE          => l_effective_date
       ,P_ELEMENT_TYPE_ID         => p_element_type_id
       ,P_NAME                    => rec_input_values.NAME
       ,P_UOM                     => rec_input_values.UOM
       ,P_LOOKUP_TYPE             => rec_input_values.LOOKUP_TYPE
       ,P_FORMULA_ID              => rec_input_values.FORMULA_ID
       ,P_VALUE_SET_ID            => rec_input_values.VALUE_SET_ID
       ,P_DISPLAY_SEQUENCE        => rec_input_values.DISPLAY_SEQUENCE
       ,P_GENERATE_DB_ITEMS_FLAG  => rec_input_values.GENERATE_DB_ITEMS_FLAG
       ,P_HOT_DEFAULT_FLAG        => rec_input_values.HOT_DEFAULT_FLAG
       ,P_MANDATORY_FLAG          => rec_input_values.MANDATORY_FLAG
       ,P_DEFAULT_VALUE           => rec_input_values.DEFAULT_VALUE
       ,P_MAX_VALUE               => rec_input_values.MAX_VALUE
       ,P_MIN_VALUE               => rec_input_values.MIN_VALUE
       ,P_WARNING_OR_ERROR        => rec_input_values.WARNING_OR_ERROR
       ,P_INPUT_VALUE_ID          => l_input_value_id
       ,P_OBJECT_VERSION_NUMBER   => l_ovn
       ,P_EFFECTIVE_START_DATE    => l_effective_start_date
       ,P_EFFECTIVE_END_DATE      => l_effective_end_date
       ,P_DEFAULT_VAL_WARNING     => l_val_warning
       ,P_MIN_MAX_WARNING         => l_max_warning
       ,P_PAY_BASIS_WARNING       => l_basis_warning
       ,P_FORMULA_WARNING        =>  l_formula_warning
       ,P_ASSIGNMENT_ID_WARNING   => l_asg_warning
       ,P_FORMULA_MESSAGE         => l_message
      );

       IF g_debug THEN
         hr_utility.trace(rec_input_values.NAME || ' Created');
       End if;

   end if;
   close c_input_exists;

end loop;

close c_get_input_value_info;

     IF g_debug THEN
       hr_utility.trace('Leaving ' || lv_procedure_name);
     End if;
exception
   when others then
      IF g_debug THEN
       hr_utility.set_location(gv_package_name || lv_procedure_name, 200);
       hr_utility.trace('ERROR:' || sqlcode ||'-'|| substr(sqlerrm,1,80));
      End if;
      raise;
end;

/*  procedure creates the Retro elements and the required element links for the different retro types.
     New elements will be created with the following name: 'Name of the old Retro Element' + <Retro Type>.
     Reporting name of the element will be same as that of old Retro Element.
     Following parameters are passed to the  procedure:
     a) Business Group ID
     b) Element Type ID - Element Type ID of the element for which the Retro element is created
     c) Retro Type - This parameter can have three values: "GT12", "LT12 Prev", and "LT12 Curr".
     d) Retro Element Type ID: Out parameter to hold the element type id of the element getting created.

    Bug#5583165 moved some code to element_exist_check() to check GT12,LT12 element already exist.
    */

PROCEDURE create_element(
                       p_business_group_id IN NUMBER,
                       p_retro_element_id IN NUMBER,
                       p_retro_type IN VARCHAR2,
                       p_class_label IN VARCHAR2,  --bug 7665727
                       p_element_type_id OUT NOCOPY NUMBER
                       )
IS

/* Bug 5749509 - Modified cusror for Time_definition_type.
   'N' is not a valid value for Time Definition Type, set value as Null
*/
/* Gets the details of Retro Element */
cursor c_get_retro_element_info
is
select
FORMULA_ID,
INPUT_CURRENCY_CODE,
OUTPUT_CURRENCY_CODE,
CLASSIFICATION_ID,
BENEFIT_CLASSIFICATION_ID,
ADDITIONAL_ENTRY_ALLOWED_FLAG,
ADJUSTMENT_ONLY_FLAG,
CLOSED_FOR_ENTRY_FLAG,
ELEMENT_NAME,
REPORTING_NAME,
DESCRIPTION,
INDIRECT_ONLY_FLAG,
MULTIPLE_ENTRIES_ALLOWED_FLAG,
MULTIPLY_VALUE_FLAG,
POST_TERMINATION_RULE,
PROCESS_IN_RUN_FLAG,
PROCESSING_PRIORITY,
PROCESSING_TYPE,
STANDARD_LINK_FLAG,
COMMENT_ID,
LEGISLATION_SUBGROUP,
QUALIFYING_AGE,
QUALIFYING_LENGTH_OF_SERVICE,
QUALIFYING_UNITS,
ELEMENT_INFORMATION_CATEGORY,
ELEMENT_INFORMATION1,
ELEMENT_INFORMATION2,
ELEMENT_INFORMATION3,
THIRD_PARTY_PAY_ONLY_FLAG,
ITERATIVE_FLAG,
ITERATIVE_FORMULA_ID,
ITERATIVE_PRIORITY,
CREATOR_TYPE,
RETRO_SUMM_ELE_ID,
GROSSUP_FLAG,
PROCESS_MODE,
ADVANCE_INDICATOR,
ADVANCE_PAYABLE,
ADVANCE_DEDUCTION,
PROCESS_ADVANCE_ENTRY,
PRORATION_GROUP_ID,
PRORATION_FORMULA_ID,
RECALC_EVENT_GROUP_ID,
ONCE_EACH_PERIOD_FLAG,
decode(TIME_DEFINITION_TYPE,'N',NULL,TIME_DEFINITION_TYPE) TIME_DEFINITION_TYPE,
TIME_DEFINITION_ID
from pay_element_types_f
where element_type_id = p_retro_element_id
and business_group_id = p_business_group_id
ORDER BY effective_start_date desc;

rec_element_types c_get_retro_element_info%ROWTYPE;
l_effective_date DATE;
l_effective_start_date DATE;
l_effective_end_date DATE;
l_ovn NUMBER ;
l_comment_id NUMBER;
l_warning BOOLEAN;
l_element_type_id NUMBER;
l_element_link_id NUMBER;
l_eei_info_id     Number;
l_ovn_eei         Number;

/* Checks whether retro element (LT12,GT12...) already exist before creating the element*/
CURSOR c_element_exists
IS
SELECT pet.element_type_id
FROM pay_element_types_f pet
WHERE pet.element_name = rec_element_types.ELEMENT_NAME || ' ' || p_retro_type
AND pet.business_group_id = p_business_group_id;


/* Gets the details of the element link of retro element */
/*  5731490 Fetches all the links associated with retro elements*/
CURSOR c_get_element_links(c_element_type_id pay_element_types_f.element_type_id%type, p_effective_date date)
IS
SELECT pel.PAYROLL_ID,
pel.JOB_ID,
pel.POSITION_ID,
pel.PEOPLE_GROUP_ID,
pel.COST_ALLOCATION_KEYFLEX_ID,
pel.ORGANIZATION_ID,
pel.ELEMENT_TYPE_ID,
pel.LOCATION_ID,
pel.GRADE_ID,
pel.BALANCING_KEYFLEX_ID,
pel.BUSINESS_GROUP_ID,
pel.ELEMENT_SET_ID,
pel.PAY_BASIS_ID,
pel.COSTABLE_TYPE,
pel.LINK_TO_ALL_PAYROLLS_FLAG,
pel.MULTIPLY_VALUE_FLAG,
pel.STANDARD_LINK_FLAG,
pel.TRANSFER_TO_GL_FLAG,
pel.COMMENT_ID,
pel.EMPLOYMENT_CATEGORY,
pel.QUALIFYING_AGE,
pel.QUALIFYING_LENGTH_OF_SERVICE,
pel.QUALIFYING_UNITS,
greatest(pel.EFFECTIVE_START_DATE, to_date('2005/07/01','YYYY/MM/DD')) EFFECTIVE_START_DATE /* 5731490 */
,pel.EFFECTIVE_END_DATE
from pay_element_links_f  pel
where pel.element_type_id = c_element_type_id
and pel.business_group_id = p_business_group_id
and pel.effective_start_date = (
                              select max(pel.effective_start_date)
                              from pay_element_links_f pel1
                              where pel.element_link_id=pel1.element_link_id
                             )  /* 5731490 */
and ( p_effective_date between pel.effective_start_date and  pel.effective_end_date
      or  pel.effective_start_date > p_effective_date)  /* 5731490 */
order by pel.effective_start_date asc;

rec_element_links c_get_element_links%ROWTYPE;
lv_procedure_name VARCHAR2(50);
l_upgraded_element char(1);

/* 5731490 */
l_effective_start_date_li date;
l_effective_end_date_li date;
l_entries_warning_li boolean;

/*bug 7665727*/
l_sub_classification_rule_id pay_sub_classification_rules_f.sub_classification_rule_id%type;
l_rowid     varchar2(18) default null;
l_classification_id pay_element_classifications.classification_id%type;
dummy_rowid     varchar2(18) default null;
dummy_id        number(38) default null;

begin
g_debug := hr_utility.debug_enabled;
l_upgraded_element :='N'; /* Flag to check whether element was created by Upgrade process */
l_effective_date := to_date('2005/07/01','YYYY/MM/DD');

lv_procedure_name := 'create_element';

 IF g_debug THEN
   hr_utility.trace('Entering ' || lv_procedure_name);
 End if;

/* Gets the details of Retro Element */
open c_get_retro_element_info;
fetch c_get_retro_element_info into rec_element_types;
close c_get_retro_element_info;

 IF g_debug THEN
  hr_utility.trace('Retro Element Name: ' || rec_element_types.element_name);
 End if;
/* Checks whether element already exist before creating the element <Retro Element> + <Retro Type> */
OPEN c_element_exists;
FETCH c_element_exists INTO l_element_type_id;
IF c_element_exists%NOTFOUND THEN

    IF g_debug THEN
      hr_utility.trace('Creating New Retro Element: ' || rec_element_types.element_name || ' ' || p_retro_type );
    End if;
/*  Creates element  <Retro Element> + <Retro Type> */
/* Bug 5749509 - ONCE_EACH_PERIOD_FLAG - Specify default of 'N' if existing value is Null
               - TIME_DEFINITION_TYPE,TIME_DEFINITION_TYPE added in API call
               - If TIME_DEFINITION_TYPE is 'N', set it as Null
*/

     PAY_ELEMENT_TYPES_API.CREATE_ELEMENT_TYPE
  (p_effective_date                  => l_effective_date
  ,p_classification_id               => rec_element_types.CLASSIFICATION_ID
  ,p_element_name                    => rec_element_types.ELEMENT_NAME || ' ' || p_retro_type
  ,p_input_currency_code             => 'AUD'
  ,p_output_currency_code            => 'AUD'
  ,p_multiple_entries_allowed_fla    => rec_element_types.MULTIPLE_ENTRIES_ALLOWED_FLAG
  ,p_processing_type                 => rec_element_types.PROCESSING_TYPE
  ,p_business_group_id               => p_business_group_id
  ,p_formula_id                      => rec_element_types.FORMULA_ID
  ,p_benefit_classification_id       => rec_element_types.BENEFIT_CLASSIFICATION_ID
  ,p_additional_entry_allowed_fla    => rec_element_types.ADDITIONAL_ENTRY_ALLOWED_FLAG
  ,p_adjustment_only_flag            => rec_element_types.ADJUSTMENT_ONLY_FLAG
  ,p_closed_for_entry_flag           => rec_element_types.CLOSED_FOR_ENTRY_FLAG
  ,p_reporting_name                  => nvl(rec_element_types.REPORTING_NAME, rec_element_types.ELEMENT_NAME)
  ,p_description                     => nvl(rec_element_types.DESCRIPTION, rec_element_types.ELEMENT_NAME) || ' for ' || p_retro_type
  ,p_indirect_only_flag              => rec_element_types.INDIRECT_ONLY_FLAG
  ,p_multiply_value_flag             => rec_element_types.MULTIPLY_VALUE_FLAG
  ,p_post_termination_rule           => rec_element_types.POST_TERMINATION_RULE
  ,p_process_in_run_flag             => rec_element_types.PROCESS_IN_RUN_FLAG
  ,p_processing_priority             => rec_element_types.PROCESSING_PRIORITY
  ,p_standard_link_flag              => rec_element_types.STANDARD_LINK_FLAG
  ,p_third_party_pay_only_flag       => rec_element_types.THIRD_PARTY_PAY_ONLY_FLAG
  ,p_iterative_flag                  => rec_element_types.ITERATIVE_FLAG
  ,p_iterative_formula_id            => rec_element_types.ITERATIVE_FORMULA_ID
  ,p_iterative_priority              => rec_element_types.ITERATIVE_PRIORITY
  ,p_creator_type                    => rec_element_types.CREATOR_TYPE
  ,p_retro_summ_ele_id               => null
  ,p_grossup_flag                    => rec_element_types.GROSSUP_FLAG
  ,p_process_mode                    => rec_element_types.PROCESS_MODE
  ,p_advance_indicator               => rec_element_types.ADVANCE_INDICATOR
  ,p_advance_payable                 => rec_element_types.ADVANCE_PAYABLE
  ,p_advance_deduction               => rec_element_types.ADVANCE_DEDUCTION
  ,p_process_advance_entry           => rec_element_types.PROCESS_ADVANCE_ENTRY
  ,p_proration_group_id              => rec_element_types.PRORATION_GROUP_ID
  ,p_proration_formula_id            => rec_element_types.PRORATION_FORMULA_ID
  ,p_recalc_event_group_id           => rec_element_types.RECALC_EVENT_GROUP_ID
  ,p_legislation_subgroup            => null
  ,p_qualifying_age                  => rec_element_types.QUALIFYING_AGE
  ,p_qualifying_length_of_service    => rec_element_types.QUALIFYING_LENGTH_OF_SERVICE
  ,p_qualifying_units                => rec_element_types.QUALIFYING_UNITS
  ,p_element_information_category    => rec_element_types.ELEMENT_INFORMATION_CATEGORY
  ,p_element_information1            => rec_element_types.ELEMENT_INFORMATION1
  ,p_element_information2            => rec_element_types.ELEMENT_INFORMATION2
  ,p_element_information3            => rec_element_types.ELEMENT_INFORMATION3
  ,p_once_each_period_flag           => NVL(rec_element_types.ONCE_EACH_PERIOD_FLAG,'N')
  ,p_time_definition_type            => rec_element_types.TIME_DEFINITION_TYPE
  ,p_time_definition_id              => rec_element_types.TIME_DEFINITION_ID
  ,p_element_type_id                 => p_element_type_id
  ,p_effective_start_date            => l_effective_start_date
  ,p_effective_end_date              => l_effective_end_date
  ,p_object_version_number           => l_ovn
  ,p_comment_id                      => l_comment_id
  ,p_processing_priority_warning     => l_warning);

/*Bug 7665727 - deleting Standard sub classification and adding Spread sub classification */
/*Bug 8765082 - Added Sub classification for Leave Loading */
IF p_class_label = 'Spread' OR p_class_label = 'Leave Loading' THEN

   IF g_debug THEN
    hr_utility.trace('sub classification change to : ' || p_class_label ||' for '|| rec_element_types.ELEMENT_NAME || ' ' || p_retro_type ||'('||p_element_type_id||')' );
   End if;

    select    rowid, sub_classification_rule_id
    into l_rowid, l_sub_classification_rule_id
    from    pay_sub_classification_rules_f
    where   element_type_id     = p_element_type_id
    and business_group_id       = p_business_group_id;

    select  classification_id
    into l_classification_id
    from    pay_element_classifications
    where   classification_name = p_class_label /* Bug 8765082 */
    and legislation_code = 'AU';

  /* Deleting Standard sub classification*/
  pay_sub_class_rules_pkg.DELETE_ROW (l_rowid,l_sub_classification_rule_id,'ZAP',l_effective_start_date,l_effective_end_date);

  /* Adding Spread sub classification*/
  pay_sub_class_rules_pkg.insert_row (
    dummy_rowid,
    dummy_id,
    l_effective_start_date,
    l_effective_end_date,
    p_element_type_id,
    l_classification_id,
    p_business_group_id,
    'AU',
    null,null,null,null,null);

END IF;

  /*An entry is created in the table pay_element_type_extra_info table. This
   table is used to identify whether a retro element is already created by the
   upgrade process. If so, for the given element no corresponding reto elements
   are created*/

   pay_element_extra_info_api.create_element_extra_info   /*Bug# 5461633 */
     (p_element_type_id          => p_element_type_id
     ,p_information_type         => 'AU_RETRO_UPGRADE_INFO'
     ,p_eei_information_category => 'AU_RETRO_UPGRADE_INFO'
     ,p_element_type_extra_info_id => l_eei_info_id
     ,p_object_version_number      => l_ovn_eei);

   IF g_debug THEN
    hr_utility.trace('Created New Retro Element: ' || rec_element_types.element_name || ' ' || p_retro_type );
   End if;
  /* Gets the details of element link of retro element, if link exist
   create the similar element link for newly created element */

   OPEN c_get_element_links(p_retro_element_id,l_effective_date);
   Loop /* 5731490 */
   FETCH c_get_element_links INTO rec_element_links;

   IF c_get_element_links%NOTFOUND THEN
     exit;
   ELSE
     IF g_debug THEN
      hr_utility.trace('Creating Element links for New Retro Element: ' || rec_element_types.element_name || ' ' || p_retro_type );
     End if;

  /* 8416815 - Added two more input parameters p_cost_allocation_keyflex_id and p_balancing_keyflex_id
              to the below call*/
   pay_element_link_api.create_element_link
  (p_effective_date                  => rec_element_links.effective_start_date  /* 5731490 */
  ,p_element_type_id                 => p_element_type_id
  ,p_business_group_id               => p_business_group_id
  ,p_costable_type                   => rec_element_links.COSTABLE_TYPE
  ,p_payroll_id                      => rec_element_links.PAYROLL_ID
  ,p_job_id                          => rec_element_links.JOB_ID
  ,p_position_id                     => rec_element_links.POSITION_ID
  ,p_people_group_id                 => rec_element_links.PEOPLE_GROUP_ID
  ,p_organization_id                 => rec_element_links.ORGANIZATION_ID
  ,p_location_id                     => rec_element_links.LOCATION_ID
  ,p_grade_id                        => rec_element_links.GRADE_ID
  ,p_element_set_id                  => rec_element_links.ELEMENT_SET_ID
  ,p_pay_basis_id                    => rec_element_links.PAY_BASIS_ID
  ,p_link_to_all_payrolls_flag       => rec_element_links.LINK_TO_ALL_PAYROLLS_FLAG
  ,p_standard_link_flag              => rec_element_links.STANDARD_LINK_FLAG
  ,p_transfer_to_gl_flag             => rec_element_links.TRANSFER_TO_GL_FLAG
  ,p_employment_category             => rec_element_links.EMPLOYMENT_CATEGORY
  ,p_qualifying_age                  => rec_element_links.QUALIFYING_AGE
  ,p_qualifying_length_of_service    => rec_element_links.QUALIFYING_LENGTH_OF_SERVICE
  ,p_qualifying_units                => rec_element_links.QUALIFYING_UNITS
  ,p_cost_allocation_keyflex_id      => rec_element_links.COST_ALLOCATION_KEYFLEX_ID /* 8416815 */
  ,p_balancing_keyflex_id            => rec_element_links.BALANCING_KEYFLEX_ID /* 8416815 */
  ,p_cost_concat_segments            => null
  ,p_balance_concat_segments         => null
  ,p_element_link_id             => l_element_link_id
  ,p_comment_id              => l_comment_id
  ,p_object_version_number       => l_ovn
  ,p_effective_start_date        => l_effective_start_date
  ,p_effective_end_date          => l_effective_end_date
  );
      IF g_debug THEN
        hr_utility.trace('Created Element links for New Retro Element: ' || rec_element_types.element_name || ' ' || p_retro_type );
      End if;
   /* 5731490 End dates link*/
  if to_char(rec_element_links.effective_end_date,'YYYY/MM/DD') <> '4712/12/31' then
    pay_element_link_api.delete_element_link
    (
     p_effective_date              => rec_element_links.effective_end_date
    ,p_element_link_id             => l_element_link_id
    ,p_datetrack_delete_mode      => 'DELETE'
    ,p_object_version_number       => l_ovn
    ,p_effective_start_date        => l_effective_start_date_li
    ,p_effective_end_date          => l_effective_end_date_li
    ,p_entries_warning      =>  l_entries_warning_li
    );
  end if;

  END IF;
End Loop;
   CLOSE c_get_element_links;

ELSE
      p_element_type_id := l_element_type_id;
END IF;

CLOSE c_element_exists;

  IF g_debug THEN
   hr_utility.trace('Leaving ' || lv_procedure_name);
  End if;
exception
   when others then
     IF g_debug THEN
      hr_utility.set_location(gv_package_name || lv_procedure_name, 200);
      hr_utility.trace('ERROR:' || sqlcode ||'-'|| substr(sqlerrm,1,80));
     End if;
     raise;
end;
/*
  Procedure attaches the Retro Componenets with the  retro paid element
  Following parameter are passed:
   a) Business Group id
   b) Legislation code
   c) Retro Componenet id - Retro Componenet id of seeded Retro Component
   d) Creater id Element Type Id of retro element
   e) Retro Component Usage id Out prarmeter
*/
 PROCEDURE insert_retro_comp_usages
                  (p_business_group_id    in        number,
                   p_legislation_code     in        varchar2,
                   p_retro_component_id   in        number,
                   p_creator_id           in        number,
                   p_retro_comp_usage_id out nocopy number)
 IS

   ln_retro_component_usage_id NUMBER;
   lv_procedure_name           VARCHAR2(100);


   CURSOR c_retro_comp_exists
   is
   SELECT retro_component_usage_id
   FROM pay_retro_component_usages
   WHERE creator_id = p_creator_id
   AND p_business_group_id = business_group_id
   AND retro_component_id = p_retro_component_id;


 BEGIN
   g_debug := hr_utility.debug_enabled;
   lv_procedure_name := '.insert_retro_comp_usages';

   IF g_debug THEN
      hr_utility.trace('Entering ' || gv_package_name || lv_procedure_name);
   End if;
    /* Checks whether retro compnoned already exist */
   OPEN c_retro_comp_exists;
   FETCH c_retro_comp_exists INTO ln_retro_component_usage_id;
   IF c_retro_comp_exists%NOTFOUND THEN

      select pay_retro_component_usages_s.nextval
        into ln_retro_component_usage_id
        from dual;

      insert into pay_retro_component_usages
      (retro_component_usage_id, retro_component_id, creator_id, creator_type,
       default_component, reprocess_type, business_group_id, legislation_code,
       creation_date, created_by, last_update_date, last_updated_by,
       last_update_login, object_version_number)
      values
      (ln_retro_component_usage_id, p_retro_component_id, p_creator_id,
       'ET', 'Y', 'R', p_business_group_id, p_legislation_code,
       sysdate, 2, sysdate, 2, 2, 1);

      p_retro_comp_usage_id := ln_retro_component_usage_id;

     IF g_debug THEN
      hr_utility.trace('p_retro_comp_usage_id= ' || p_retro_comp_usage_id);
      hr_utility.trace('Leaving ' || gv_package_name || lv_procedure_name);
     End if;
   ELSE
     p_retro_comp_usage_id := ln_retro_component_usage_id;
   END IF;

   exception
     when others then
      IF g_debug THEN
       hr_utility.set_location(gv_package_name || lv_procedure_name, 200);
       hr_utility.trace('ERROR:' || sqlcode ||'-'|| substr(sqlerrm,1,80));
      End if;

       raise;
 END insert_retro_comp_usages;

/*
  Procedure attaches the Time Span with the retro paid element
  Following parameter are passed:
   a) Business Group id
   b) Retro Element Type Id - Element Type id of retro element
   c) Legislation Code
   d) Time Span Id
   e) Retro Component Usage id of Retro component attached with the retro element
*/
 PROCEDURE insert_element_span_usages
                  (p_business_group_id     in number,
                   p_retro_element_type_id in number,
                   p_legislation_code      in varchar2,
                   p_time_span_id          in number,
                   p_retro_comp_usage_id   in  number)
 IS

   lv_procedure_name           VARCHAR2(100);

 BEGIN
   g_debug := hr_utility.debug_enabled;
   lv_procedure_name := '.insert_element_span_usages';

   IF g_debug THEN
    hr_utility.trace('Entering ' || gv_package_name || lv_procedure_name);
    hr_utility.trace('p_business_group_id     ='|| p_business_group_id);
    hr_utility.trace('p_time_span_id     ='|| p_time_span_id);
    hr_utility.trace('p_retro_comp_usage_id     ='|| p_retro_comp_usage_id);
    hr_utility.trace('p_retro_element_type_id     ='|| p_retro_element_type_id);
   End if;

   insert into pay_element_span_usages
   (element_span_usage_id, business_group_id, time_span_id,
    retro_component_usage_id, retro_element_type_id,
    creation_date, created_by, last_update_date, last_updated_by,
    last_update_login, object_version_number)
   values
   (pay_element_span_usages_s.nextval, p_business_group_id, p_time_span_id,
    p_retro_comp_usage_id, p_retro_element_type_id,
    sysdate, 2, sysdate, 2, 2, 1);

    IF g_debug THEN
      hr_utility.trace('Leaving ' || gv_package_name || lv_procedure_name);
    End if;

   exception
     when others then
      IF g_debug THEN
       hr_utility.set_location(gv_package_name || lv_procedure_name, 200);
       hr_utility.trace('ERROR:' || sqlcode ||'-'|| substr(sqlerrm,1,80));
      End if;
       raise;
 END insert_element_span_usages;

-- Bug#5583165
--This procedure checks whether any GT12, LT12 element exist for an element and if GT12
-- or LT12 exist whether these elements were created by upgrade process.
-- Procedure sets p_user_element_exist to 'Y' if GT12,LT12 elements were created by user
-- and sets p_upgrade_element_exis to 'Y' if GT12,LT12 elements were created by upgrade process

Procedure element_exist_check( p_element_type_id in pay_element_types_f.element_type_id%type
                              ,p_business_group_id in number
                              ,p_upgrade_element_exist out NOCOPY  VARCHAR2
                              ,p_user_element_exist out NOCOPY  VARCHAR2)
 is
  CURSOR c_element_exists  IS
  SELECT pet2.element_type_id,pet1.element_name,pet2.element_name
  FROM  pay_element_types_f pet1,
        pay_element_types_f pet2
  WHERE pet2.element_name in (pet1.element_name || ' '||'GT12' ,
                               pet1.element_name || ' '||'LT12 Prev',
                                pet1.element_name || ' '||'LT12 Curr' )
    AND pet1.business_group_id = p_business_group_id
    and pet1.business_group_id= pet2.business_group_id
    and pet1.element_type_id=p_element_type_id;


  CURSOR upgraded_element_check(cp_element_type_id pay_element_types_f.element_type_id%type) IS
  select 'Y'
  from pay_element_type_extra_info
  where element_type_id= cp_element_type_id
  and information_type='AU_RETRO_UPGRADE_INFO' ;

  l_element_type_id pay_element_types_f.element_type_id%type;
  l_upg_element_name pay_element_types_f.element_name%type;
  l_retro_element_name pay_element_types_f.element_name%type;
  l_upgraded_element char(1);
  l_user_element_exist char(1);
  l_upgrade_element_exist char(1);
  lv_procedure_name varchar2(30);
Begin
  g_debug := hr_utility.debug_enabled;

 lv_procedure_name := '.element_exist_check';
 l_upgraded_element:='N';
 l_user_element_exist :='N';
 l_upgrade_element_exist := 'N';

-- Checking whether GT12,LT12 elements exist for the retro element
open c_element_exists;
loop
FETCH c_element_exists  into l_element_type_id,l_upg_element_name,l_retro_element_name;
    IF c_element_exists%NOTFOUND THEN
       exit;
      END IF;
    -- Checking whether GT12,LT12 elements were created by upgrade process
    OPEN  upgraded_element_check(l_element_type_id);
    FETCH upgraded_element_check INTO l_upgraded_element;
    CLOSE upgraded_element_check;
    -- GT12,LT12 elements were not created by upgrade process
    if l_upgraded_element <> 'Y' then
      fnd_file.put_line( FND_FILE.LOG,'WARNING: User Defined Element ' ||l_retro_element_name || ' already exist, cannot upgrade '||  l_upg_element_name || ' (Element Type ID: ' || p_element_type_id || ').'); /* 5461629 */
      l_user_element_exist :='Y';
      l_upgrade_element_exist := 'N';
      exit;
    else
      l_user_element_exist :='N';
      l_upgrade_element_exist := 'Y';
    end if;

 end loop;
close c_element_exists;
 p_upgrade_element_exist :=  l_upgrade_element_exist;
 p_user_element_exist :=  l_user_element_exist;

exception
     when others then
      IF g_debug THEN
       hr_utility.set_location(gv_package_name || lv_procedure_name, 200);
       hr_utility.trace('ERROR:' || sqlcode ||'-'|| substr(sqlerrm,1,80));
      End if;
       raise;
end element_exist_check;


 /****************************************************************************
 ** Name       : qualify_element
 **
 ** Description: This is the qualifying procedure which determines whether
 **              the element passed in as a parameter needs to be migrated.
 **                The conditions that are checked here are
 **                1. Element is part of a Retro Set used for Retro
 **                2. Element is of type "Pre Tax Deductions" and "Earnings Standard"
 **
 ****************************************************************************/
 PROCEDURE qualify_element(p_object_id  in        varchar2
                          ,p_qualified out nocopy varchar2)
 IS

/* This cursor fetches the element information for element if element is of classification
   'Earnings' or  'Pre Tax Deduction' */
/*  Bug 5731490 - If the element has a retro summary element defined, the element
    must be upgraded
    Bug 5749509 - Added NOT Exists clause to prevent elements created by UPGRADE to get
    upgraded again if process is re-run.
                - Added NOT Exists clause to prevent any User defined Retro elements to
                  get upgraded.
*/

   cursor c_element_class(cp_element_type_id in number) is
   select  distinct
            pet.classification_id,
            pet.element_name,
            pet.legislation_code,
            pet.business_group_id,
            pec.classification_name,
            pet.retro_summ_ele_id,    /* Bug 5731490 */
            decode(instr(pec.classification_name,  'Earnings'),  0,  null,pec2.classification_name)  ||
            decode(instr(pec.classification_name,  'Deductions'),  0,  null, pec.classification_name ) label
   from      pay_element_types_f pet
            ,pay_element_classifications pec
            ,pay_element_classifications pec2
            ,pay_sub_classification_rules_f pscr
  where  pet.element_type_id = cp_element_type_id
  AND    pet.classification_id    = pec.classification_id
  and   pec.legislation_code = 'AU'
  and    (instr(pec.classification_name, 'Earnings') > 0
  or     instr(pec.classification_name, 'Pre Tax Deductions') > 0
  OR     pet.retro_summ_ele_id IS NOT NULL )                        /*  Bug 5731490 */
  and    pet.element_type_id = pscr.element_type_id (+)
  and    pscr.classification_id = pec2.classification_id(+)
  and    pec2.legislation_code (+)= 'AU'
  AND   NOT EXISTS
         (SELECT '1'
          FROM pay_element_type_extra_info etei
          WHERE etei.element_type_id = pet.element_type_id
          AND   etei.information_type = 'AU_RETRO_UPGRADE_INFO')
  AND NOT EXISTS
         ( SELECT '1'
           FROM pay_balance_feeds_f pbf,
                pay_balance_types pbt,
                pay_input_values_f pivf
           WHERE pbt.balance_type_id = pbf.balance_type_id
           AND   pbt.balance_name in ('Retro LT 12 Mths Curr Yr Amount',
                                      'Retro LT 12 Mths Prev Yr Amount',
                                      'Lump Sum E Payments',
                                      'Retro Earnings Spread LT 12 Mths Curr Amount',  /*Added for bug 7665727*/
                                      'Retro Earnings Spread LT 12 Mths Prev Yr Amount',
                                      'Retro Earnings Spread GT 12 Mths Amount',
                                      'Retro Earnings Leave Loading LT 12 Mths Curr Yr Amount', /* Bug 8765082 */
                                      'Retro Earnings Leave Loading LT 12 Mths Prev Yr Amount',
                                      'Retro Earnings Leave Loading GT 12 Mths Amount')
           AND   pbf.input_value_id = pivf.input_value_id
           AND   pivf.name = 'Pay Value'
           AND   pivf.element_type_id = pet.element_type_id
        ) ;

   cursor c_legislation_code(cp_business_group_id in number) is
     select legislation_code
     from per_business_groups
     where business_group_id = cp_business_group_id;

/* Gets all the element sets in which the element is included.*/

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
        and petr.include_or_exclude = 'E'
         ;

/* Chechk whether Element set is used for retropayment */

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
   lv_classification_name VARCHAR2(100);
   lv_label VARCHAR2(100);
   lv_procedure_name    VARCHAR2(100);
   lv_legislation_code         VARCHAR2(150);
   ln_exists            VARCHAR2(1);

   TYPE character_data_table IS TABLE OF VARCHAR2(280)
                               INDEX BY BINARY_INTEGER;

   ltt_rule_type       character_data_table;
   ltt_rule_mode       character_data_table;

   ln_retro_summ_ele_id NUMBER; /* Bug 5731490 */
   ln_element_set_exist boolean;  /* Bug 5731490 */

 BEGIN
   g_debug := hr_utility.debug_enabled;

    lv_procedure_name := '.qualify_element';

    IF g_debug THEN
     hr_utility.trace('Entering ' || gv_package_name || lv_procedure_name);
    End if;

   lv_qualified := 'N';
   lv_legislation_code  := null;
   ln_business_group_id := null;
   ln_classification_id := null;
   lv_element_name      := null;
   ln_element_set_exist := FALSE; /* 5731490 */
/* Fetches the element information for element if element is of classification
   'Earnings' or  'Pre Tax Deduction' */
   open c_element_class(p_object_id);
   fetch c_element_class into ln_classification_id,
                              lv_element_name,
                              lv_legislation_code,
                              ln_business_group_id,
                              lv_classification_name,
                              ln_retro_summ_ele_id,   /* Bug 5731490 */
                              lv_label;
   close c_element_class;

   IF ln_classification_id IS NOT NULL THEN
     IF g_debug THEN
       hr_utility.trace('ln_classification_id: ' || ln_classification_id);
       hr_utility.trace('lv_element_name: ' || lv_element_name);
       hr_utility.trace('ln_business_group_id: ' || ln_business_group_id);
       hr_utility.trace('lv_classification_name: ' || lv_classification_name);
       hr_utility.trace('lv_label: ' || lv_label);
       hr_utility.trace('lv_retro_summ_ele_id:  '||ln_retro_summ_ele_id);
     End if;

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
      /* Checks whether Legislation rules are enabled */
      FOR i in 1 ..2 LOOP
          OPEN c_retro_rule_check(ltt_rule_type(i),lv_legislation_code) ;
          FETCH c_retro_rule_check into ln_exists;
          IF c_retro_rule_check%NOTFOUND THEN
             INSERT INTO pay_legislation_rules
             (legislation_code, rule_type, rule_mode) VALUES
             (lv_legislation_code, ltt_rule_type(i), ltt_rule_mode(i));
          END IF;
          CLOSE c_retro_rule_check;
      END LOOP;
       /* Gets all the element sets in which the element is included.*/
      open c_element_set(p_object_id
                     ,ln_classification_id
                     ,lv_legislation_code);
      loop
         fetch c_element_set into ln_element_set_id;
         if c_element_set%notfound then
            exit;
         end if;
           ln_element_set_exist := TRUE; /* 5731490 */
         IF g_debug THEN
           hr_utility.trace('Element Set ID ' || ln_element_set_id);
          End if;
          /* Chechk whether Element set is used for retropayment */
          /* Bug 5731490 - Check Added for summary element */
         open c_element_check(ln_element_set_id);
         fetch c_element_check into ln_element_used;
         if c_element_check%found AND ((lv_classification_name = 'Earnings' AND (lv_label = 'Standard' OR lv_label = 'Spread' OR lv_label = 'Leave Loading'))  /* 7665727,8765082 Spread, Leave Loading Added */
                                        OR lv_classification_name = 'Pre Tax Deductions'
                                        OR  ln_retro_summ_ele_id IS NOT NULL) then

            lv_qualified := 'Y';

            IF g_debug THEN
             hr_utility.trace('UPGRADE Element ' || lv_element_name ||
                             '(' || p_object_id || ')');
            End if;
            exit;
         else
              lv_qualified := 'N';
              IF g_debug THEN
               hr_utility.trace('Element ' || lv_element_name ||
                                 '(' || p_object_id || ') does not need to be upgraded');
              End if;

         end if;
         close c_element_check;
      end loop;
      close c_element_set;
   END IF;

  /* Bug 5749509 - Moved statement outside IF Block */
       p_qualified := lv_qualified;

  /* Bug 5731490 - Moved statement outside IF Block */
    if ((lv_classification_name = 'Earnings' AND (lv_label = 'Standard' OR lv_label = 'Spread' OR lv_label = 'Leave Loading'))  /* 7665727,8765082 Spread, Leave Loading */
                                        OR lv_classification_name = 'Pre Tax Deductions'
                                        OR  ln_retro_summ_ele_id IS NOT NULL) and lv_qualified ='N' and ln_element_set_exist = TRUE then
       fnd_file.put_line(FND_FILE.LOG,'MESSAGE: Element ' || lv_element_name || ' (Element Type ID: ' || p_object_id|| ')'|| ' does not require upgrade as not included in a Retro Element set.');
    elsif NOT ((lv_classification_name = 'Earnings' AND (lv_label = 'Standard' OR lv_label = 'Spread' OR lv_label = 'Leave Loading'))  /* 7665727,8765082 Spread, Leave Loading */
                                        OR lv_classification_name = 'Pre Tax Deductions'
                                        OR  ln_retro_summ_ele_id IS NOT NULL) and ln_element_set_exist = TRUE  then
        fnd_file.put_line(FND_FILE.LOG,'MESSAGE: Element ' || lv_element_name || ' (Element Type ID: ' || p_object_id|| ')'|| ' with classification ' ||lv_classification_name||' '||lv_label||' does not require upgrade.');
     end if;

      IF g_debug THEN
       hr_utility.trace('Leaving ' || gv_package_name || lv_procedure_name);
      End if;

   exception
     when others then
       IF g_debug THEN
        hr_utility.set_location(gv_package_name || lv_procedure_name, 200);
        hr_utility.trace('ERROR:' || sqlcode ||'-'|| substr(sqlerrm,1,80));
       End if;

       raise;
 END qualify_element;

/* All those elements, which are passed by the qualify_element procedure comes to the upgrade procedure */

 PROCEDURE upgrade_element(p_element_type_id in number)
 IS

/* Gets the details of element */
/* Bug 5731490 - Changed Cursor to include elements with Retro summary element set
       8765082 - Removed commented code */
   cursor c_element_dtl(cp_element_type_id in number) is
     SELECT pet.business_group_id, pet.legislation_code, pet.classification_id,
            nvl(pet.retro_summ_ele_id, pet.element_type_id),
            pet.element_name, pec.classification_name
           ,pet.retro_summ_ele_id
           ,decode(instr(pec.classification_name,  'Earnings'),  0,  null,pec2.classification_name) label
       FROM pay_element_types_f pet,
            pay_element_classifications pec
           ,pay_element_classifications pec2
           ,pay_sub_classification_rules_f pscr
      WHERE pet.element_type_id = cp_element_type_id
      AND pet.classification_id = pec.classification_id
      AND pec.legislation_code = 'AU'
      AND pet.element_type_id = pscr.element_type_id (+)
      AND pscr.classification_id = pec2.classification_id(+)
      AND  pec2.legislation_code (+)= 'AU'
    ORDER BY pet.effective_start_date DESC;


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
/* cursor is used to get retro component info for AU legislation. */
   cursor c_retro_info(cp_legislation_code in varchar2) is
     select retro_component_id, pts.time_span_id, ptd.short_name, ptd2.short_name
       from pay_retro_components prc,
            pay_time_spans pts,
            pay_time_definitions ptd,
            pay_time_definitions ptd2
      where pts.creator_id = prc.retro_component_id
        and prc.legislation_code = 'AU'
        and ptd.legislation_code = 'AU'
        and ptd.time_definition_id = pts.start_time_def_id
        and ptd2.legislation_code = 'AU'
        and ptd2.time_definition_id = pts.end_time_def_id;

   /* Checks whether retro component exist for the element */
   CURSOR c_get_retro_components
   IS
   select count(*)
   from pay_retro_component_usages prcu,
        pay_retro_components prc
   where prc.legislation_code = 'AU'
   and prc.retro_component_id = prcu.retro_component_id
   AND prcu.creator_id = p_element_type_id
   order by prcu.creator_id;

   CURSOR c_get_balance_type_id(c_name pay_balance_types.balance_name%type)
   IS
   SELECT balance_type_id
   FROM pay_balance_types
   WHERE legislation_code = 'AU'
   AND balance_name = c_name;

   /* Gets the name of the attached retro element */
    cursor c_retro_element_name(cp_element_type_id in number) is  /* 5461629 */
    select pet2.element_name
    from  pay_element_types_f pet1,
          pay_element_types_f pet2
    where pet1.element_type_id = cp_element_type_id
    AND   nvl(pet1.retro_summ_ele_id, pet1.element_type_id) = pet2.element_type_id;


   ln_retro_comp_exists NUMBER;
   ln_ele_business_group_id NUMBER;
   ln_business_group_id     NUMBER;
   ln_classification_id     NUMBER;
   ln_legislation_code      VARCHAR2(10);
   lv_legislation_code      VARCHAR2(10);
   ln_element_set_id        NUMBER;
   ln_retro_element_type_id NUMBER;
   lv_retro_element_name    VARCHAR2(100);
   ln_retro_comp_usage_id   NUMBER;
   retro_element_type_id    NUMBER;
   ln_count                 NUMBER;
   lv_element_name          VARCHAR2(100);
   lv_procedure_name        VARCHAR2(100);
   ln_retro_component_id    NUMBER;
   ln_time_span_id          NUMBER;
   lv_start_time_name       VARCHAR2(100);
   lv_end_time_name       VARCHAR2(100);
   lv_classification_name VARCHAR2(100);
   ln_balance_type_id NUMBER;
   l_scale NUMBER;
   ln_event_group_id NUMBER;
   l_warning_flag NUMBER;
   l_retro_element_name VARCHAR2(100);
   l_upgraded_element_flag CHAR(1); /* Flag to check whether element was created by Upgrade process */
   TYPE numeric_data_table IS TABLE OF NUMBER
                   INDEX BY BINARY_INTEGER;

   ltt_business_group numeric_data_table;
   l_user_element_exist char(1);
   l_upgrade_element_exist char(1);

   /* Bug 5731490 - Added variables */
   ln_retro_summ_ele_id pay_element_types_f.retro_summ_ele_id%TYPE;
   lv_class_label varchar2(100);

   l_migrator_mode_status VARCHAR2(2);

   /* Bug 6455303 - Added variable */
      l_retro_balance_name VARCHAR2(80);

   l_bal_type NUMBER;  --bug 7665727 to check if retro Earnings Spread balance is

 BEGIN
   g_debug := hr_utility.debug_enabled;
   lv_procedure_name := '.upgrade_element';
   l_warning_flag := -1;

    /* Bug 5749509 - Set the data migrator Mode */
   l_migrator_mode_status := hr_general.g_data_migrator_mode;
   hr_general.g_data_migrator_mode := 'Y';

   IF g_debug THEN
    hr_utility.trace('Entering ' || gv_package_name || lv_procedure_name);
   End if;
   /* Gets the details of element */
   open c_element_dtl(p_element_type_id);
   fetch c_element_dtl into ln_ele_business_group_id, ln_legislation_code,
                            ln_classification_id, ln_retro_element_type_id,
                            lv_element_name, lv_classification_name,ln_retro_summ_ele_id,lv_class_label; /* Bug 5731490 */
   close c_element_dtl;

   IF g_debug THEN
    hr_utility.trace('p_element_type_id     ='|| p_element_type_id);
    hr_utility.trace('lv_element_name       ='|| lv_element_name);
    hr_utility.trace('ln_ele_business_group_id ='|| ln_ele_business_group_id);
    hr_utility.trace('ln_retro_element_type_id ='|| ln_retro_element_type_id);
    hr_utility.trace('lv_classification_name ='|| lv_classification_name);
    hr_utility.trace('l_retro_summ_ele_id ='|| ln_retro_summ_ele_id); /* Bug 5731490 */
    hr_utility.trace('lv_class_label ='|| lv_class_label); /* Bug 5731490 */
   END IF;

   if ln_legislation_code is null and
      ln_ele_business_group_id is not null then
      open c_legislation_code(ln_ele_business_group_id);
      FETCH c_legislation_code into lv_legislation_code;
      close c_legislation_code;
   else
    lv_legislation_code := ln_legislation_code;
   end if;

   IF g_debug THEN
    hr_utility.trace('lv_legislation_code      ='|| lv_legislation_code);
   End if;
    /* Checks whether retro component exist for the element */
   OPEN c_get_retro_components;
   FETCH c_get_retro_components INTO ln_retro_comp_exists;
   CLOSE c_get_retro_components;

   if ln_retro_comp_exists <> 0 then  /* 5461629 */
    fnd_file.put_line(FND_FILE.LOG,'MESSAGE: Retro Component already exist for Element ' || lv_element_name || ' (Element Type ID: ' || p_element_type_id || ').' );
    end if;
 /*    Bug#5583165 */
    if ln_retro_comp_exists = 0 then
      -- Procedure sets p_user_element_exist to 'Y' if GT12,LT12 elements of retro element were created by user
      -- and sets p_upgrade_element_exis to 'Y' if GT12,LT12 elements of retro element were created by upgrade process
      element_exist_check(nvl(ln_retro_element_type_id,p_element_type_id),ln_ele_business_group_id,l_upgrade_element_exist,l_user_element_exist);
     end if;

   if ln_retro_comp_exists = 0 and l_user_element_exist='N'
   AND ( (lv_classification_name = 'Earnings' AND (lv_class_label ='Standard' OR lv_class_label ='Spread' OR lv_class_label = 'Leave Loading'))  /* 7665727, 8765082  Spread, Leave Loading */
            OR (lv_classification_name = 'Pre Tax Deductions'))
            /* Bug 5731490 -  Enter Loop to create Retro components only for Earnings Standard and Pre Tax Deductions
               Bug 7665727 - Earnings Spread */
   THEN   /*    Bug#5583165 */
      /* Get retro component info for AU legislation. */
      open c_retro_info(lv_legislation_code);
      LOOP
      fetch c_retro_info into ln_retro_component_id
                             ,ln_time_span_id
                             ,lv_start_time_name
                             ,lv_end_time_name;

      IF c_retro_info%NOTFOUND THEN
       exit;
      END IF;

      IF g_debug THEN
       hr_utility.trace('ln_retro_component_id ='|| ln_retro_component_id);
       hr_utility.trace('ln_time_span_id       ='|| ln_time_span_id);
       hr_utility.trace('lv_start_time_name       ='|| lv_start_time_name);
       hr_utility.trace('lv_end_time_name       ='|| lv_end_time_name);
      End if;
       /* Time spans define retropayment types for greater than 12 months case*/
      IF lv_start_time_name = 'START_OF_TIME' AND lv_end_time_name = 'END_OF_12_MONTHS' THEN

            create_element(ln_ele_business_group_id,
                           nvl(ln_retro_element_type_id,p_element_type_id),
                           'GT12',
                           lv_class_label,
                           retro_element_type_id
                           );
            /* If element <Retro Element> GT12 already exist then
               no need to create input value and balance feed
                */
            IF l_upgrade_element_exist='N' THEN    /*    Bug#5583165 */

               create_input_value(ln_ele_business_group_id,
                           nvl(ln_retro_element_type_id,p_element_type_id),
                           'GT12',
                           retro_element_type_id);

                /* Bug 6455303 - Added Check to set Balance name and Scale based on Classfication name */
                /* Bug 7665727 - Added Earnings Spread clause and l_bal_type) */
                /* Bug 8765082 - Added Earnings Leave Loading clause.
                                 Altered l_bal_type for Pre Tax to create appropriate formula results */
                IF lv_classification_name = 'Pre Tax Deductions'
                THEN
                        l_retro_balance_name := 'Retro Pre Tax GT 12 Mths Amount';
                        l_scale := 1;
                        l_bal_type := 2;
                ELSIF (lv_classification_name = 'Earnings' AND lv_class_label ='Spread') THEN
                        l_retro_balance_name := 'Retro Earnings Spread GT 12 Mths Amount';
                        l_scale := 1;
                        l_bal_type := 1;
                ELSIF (lv_classification_name = 'Earnings' AND lv_class_label ='Leave Loading') THEN
                        l_retro_balance_name := 'Retro Earnings Leave Loading GT 12 Mths Amount';
                        l_scale := 1;
                        l_bal_type := 3;
                ELSE
                        l_retro_balance_name := 'Lump Sum E Payments';
                        l_scale := 1;
                        l_bal_type := 0;
                END IF;
                /* End Bug 6455303 */

               OPEN c_get_balance_type_id(l_retro_balance_name);
               FETCH c_get_balance_type_id INTO ln_balance_type_id;
               CLOSE c_get_balance_type_id;

               create_balance_feeds(ln_ele_business_group_id,
                           nvl(ln_retro_element_type_id,p_element_type_id),
                           'GT12',
                           retro_element_type_id,
                           ln_balance_type_id,
                           l_scale,
                           l_bal_type);

                /* Bug 8765082 - Removed Check for Pre Tax Deductions, FF Results need to be created for it as well */
               create_ff_results(ln_ele_business_group_id,
                                 'GT12',
                                  retro_element_type_id,
                                  l_bal_type);

            END IF;
        /* Time spans define retropayment types for Less then 12 monthe Previous Year case*/
      ELSIF lv_start_time_name = 'START_OF_PREV_LT12' AND lv_end_time_name = 'END_OF_PREV_YEAR' THEN

            create_element(ln_ele_business_group_id,
                           nvl(ln_retro_element_type_id,p_element_type_id),
                           'LT12 Prev',
                           lv_class_label,
                           retro_element_type_id
                            );
             /* If element <Retro Element> LT12 Prev already exist then
               no need to create input value and balance feed
              */
             IF l_upgrade_element_exist='N' THEN  /*    Bug#5583165 */
               create_input_value(ln_ele_business_group_id,
                           nvl(ln_retro_element_type_id,p_element_type_id),
                           'LT12 Prev',
                           retro_element_type_id);

                /* Bug 6455303 - Added Check to set Balance name and Scale based on Classfication name */
                /* Bug 7665727 - Added Earnings Spread clause and l_bal_type) */
                /* Bug 8765082 - Added Earnings Leave Loading clause.
                                 Altered l_bal_type for Pre Tax to create appropriate formula results */
                IF lv_classification_name = 'Pre Tax Deductions'
                THEN
                        l_retro_balance_name := 'Retro Pre Tax LT 12 Mths Prev Yr Amount';
                        l_scale := 1;
                        l_bal_type := 2;
                ELSIF (lv_classification_name = 'Earnings' AND lv_class_label ='Spread')  THEN
                        l_retro_balance_name := 'Retro Earnings Spread LT 12 Mths Prev Yr Amount';
                        l_scale := 1;
                        l_bal_type := 1;
                ELSIF (lv_classification_name = 'Earnings' AND lv_class_label ='Leave Loading')  THEN
                        l_retro_balance_name := 'Retro Earnings Leave Loading LT 12 Mths Prev Yr Amount';
                        l_scale := 1;
                        l_bal_type := 3;
                ELSE
                        l_retro_balance_name := 'Retro LT 12 Mths Prev Yr Amount';
                        l_scale := 1;
                        l_bal_type := 0;
                END IF;
                /* End Bug 6455303 */

               OPEN c_get_balance_type_id(l_retro_balance_name);
               FETCH c_get_balance_type_id INTO ln_balance_type_id;
               CLOSE c_get_balance_type_id;

               create_balance_feeds(ln_ele_business_group_id,
                           nvl(ln_retro_element_type_id,p_element_type_id),
                           'LT12 Prev',
                           retro_element_type_id,
                           ln_balance_type_id,
                           l_scale,
                           l_bal_type);
            /* Bug 8765082 - Removed check for Pre Tax */
                  create_ff_results(ln_ele_business_group_id,
                           'LT12 Prev',
                           retro_element_type_id,
                           l_bal_type);
            END IF;
       /* Time spans define retropayment types for Less then 12 monthe Current Year case*/
      ELSIF lv_start_time_name = 'START_OF_CURRENT_YEAR' AND lv_end_time_name = 'END_OF_TIME' THEN

            create_element(ln_ele_business_group_id,
                           nvl(ln_retro_element_type_id,p_element_type_id),
                           'LT12 Curr',
                           lv_class_label,
                           retro_element_type_id
                            );

            /* If element <Retro Element> LT12 Curr already exist then
               no need to create input value and balance feed
              */
            IF l_upgrade_element_exist='N' THEN   /*    Bug#5583165 */
               create_input_value(ln_ele_business_group_id,
                           nvl(ln_retro_element_type_id,p_element_type_id),
                           'LT12 Curr',
                           retro_element_type_id);

                /* Bug 7665727 - Added Earnings Spread clause and l_bal_type) */
                /* Bug 8765082 - Added Earnings Leave Loading clause.
                                 Re-arranged Balance names in IF/ELSIF block */
                IF (lv_classification_name = 'Earnings' AND lv_class_label ='Spread')  THEN
                        l_retro_balance_name := 'Retro Earnings Spread LT 12 Mths Curr Amount';
                        l_scale := 1;
                        l_bal_type := 1;
                ELSIF (lv_classification_name = 'Earnings' AND lv_class_label ='Leave Loading') THEN
                        l_retro_balance_name := 'Retro Earnings Leave Loading LT 12 Mths Curr Yr Amount';
                        l_scale := 1;
                        l_bal_type := 3;
                ELSIF (lv_classification_name = 'Pre Tax Deductions') THEN
                        l_retro_balance_name := 'Retro LT 12 Mths Curr Yr Amount';
                        l_scale := -1;
                        l_bal_type := 2;
                ELSE
                        l_retro_balance_name := 'Retro LT 12 Mths Curr Yr Amount';
                        l_scale := 1;
                        l_bal_type := 0;
                END IF;

               OPEN c_get_balance_type_id(l_retro_balance_name);
               FETCH c_get_balance_type_id INTO ln_balance_type_id;
               CLOSE c_get_balance_type_id;

               create_balance_feeds(ln_ele_business_group_id,
                           nvl(ln_retro_element_type_id,p_element_type_id),
                           'LT12 Curr',
                           retro_element_type_id,
                           ln_balance_type_id,
                           l_scale,
                           l_bal_type);
               /* Bug 8765082 - No results for leave loading as well */
               IF ( lv_classification_name <> 'Pre Tax Deductions'
                    AND ( lv_classification_name = 'Earnings' AND lv_class_label <> 'Leave Loading' ))
               THEN
                  create_ff_results(ln_ele_business_group_id,
                           'LT12 Curr',
                           retro_element_type_id,
                           l_bal_type);

               END IF;
            END IF;
      END IF;
  --
  -- Bug#5556042 Skiped Time Span Start of Time - End of Time as this
  --             time span should not be attached to Earning Elements.
  --
    IF lv_start_time_name = 'START_OF_TIME' AND lv_end_time_name = 'END_OF_TIME' THEN
        Null;
    Else
       if ln_legislation_code is null and ln_ele_business_group_id is not null then

         IF g_debug THEN
           hr_utility.trace('Custom Element');
          hr_utility.set_location(gv_package_name || lv_procedure_name, 110);
         End if;
        /*Creates the retro component usages for the element if its not exist */
         insert_retro_comp_usages
                  (p_business_group_id   => ln_ele_business_group_id
                  ,p_legislation_code    => null
                  ,p_retro_component_id  => ln_retro_component_id
                  ,p_creator_id          => p_element_type_id
                  ,p_retro_comp_usage_id => ln_retro_comp_usage_id);
         IF g_debug THEN
          hr_utility.set_location(gv_package_name || lv_procedure_name, 120);
         End if;
         /*Creates the element span usages for the element */
         insert_element_span_usages
                  (p_business_group_id   => ln_ele_business_group_id
                  ,p_retro_element_type_id => retro_element_type_id
                  ,p_legislation_code    => null
                  ,p_time_span_id        => ln_time_span_id
                  ,p_retro_comp_usage_id => ln_retro_comp_usage_id);

        end if;
       End if;
          l_warning_flag := 0;
      END LOOP;

      IF l_warning_flag = 0 THEN

         create_event_group(ln_ele_business_group_id,
                            ln_event_group_id);

         insert_event_group(ln_ele_business_group_id
                           ,p_element_type_id
                           ,ln_event_group_id);

         fnd_file.put_line(FND_FILE.LOG,'MESSAGE: Successfully upgraded Element ' || lv_element_name || ' (Element Type ID: ' || p_element_type_id || ').');

      END IF;

     close c_retro_info;
     /* Bug 65731490 - Added ELSIF Section */
     ELSIF  (ln_retro_comp_exists = 0 AND l_user_element_exist='N'
           AND ln_retro_summ_ele_id IS NOT NULL)
   THEN
        /* Bug 5731490 -
           Cases where other classification Elements have a summary element defined,
           Set the Summary element as retro component */

       OPEN c_retro_info(lv_legislation_code);
       LOOP
       FETCH c_retro_info INTO ln_retro_component_id
                               ,ln_time_span_id
                               ,lv_start_time_name
                               ,lv_end_time_name;

       IF c_retro_info%NOTFOUND THEN
               EXIT;
       END IF;

          IF (lv_start_time_name ='START_OF_TIME'  AND lv_end_time_name = 'END_OF_TIME')
          THEN

              IF ln_legislation_code IS NULL AND ln_ele_business_group_id IS NOT NULL THEN

                 IF g_debug THEN
                   hr_utility.trace('Custom Element');
                   hr_utility.set_location(gv_package_name || lv_procedure_name, 110);
                 END IF;
                /*Creates the retro component usages for the element if its not exist */
                 insert_retro_comp_usages
                          (p_business_group_id   => ln_ele_business_group_id
                          ,p_legislation_code    => null
                          ,p_retro_component_id  => ln_retro_component_id
                          ,p_creator_id          => p_element_type_id
                          ,p_retro_comp_usage_id => ln_retro_comp_usage_id);
                 IF g_debug THEN
                  hr_utility.set_location(gv_package_name || lv_procedure_name, 120);
                 End if;
         /*Creates the element span usages for the element */
                 insert_element_span_usages
                          (p_business_group_id   => ln_ele_business_group_id
                          ,p_retro_element_type_id => ln_retro_summ_ele_id      /* Bug 5731490 - retro element is summary element */
                          ,p_legislation_code    => null
                          ,p_time_span_id        => ln_time_span_id
                          ,p_retro_comp_usage_id => ln_retro_comp_usage_id);

                 l_warning_flag := 0;
            END IF;
          END IF;
        END LOOP;
        IF l_warning_flag = 0 THEN

             create_event_group(ln_ele_business_group_id,
                                ln_event_group_id);

             insert_event_group(ln_ele_business_group_id
                               ,p_element_type_id
                               ,ln_event_group_id);

             fnd_file.put_line(FND_FILE.LOG,'MESSAGE: Successfully upgraded Element ' || lv_element_name || ' (Element Type ID: ' || p_element_type_id || ').');

        END IF;
       CLOSE c_retro_info;

     END IF; /*End of Check for Earnings Standard and Pre Tax Deductions */

   IF g_debug THEN
    hr_utility.trace('Leaving ' || gv_package_name || lv_procedure_name);
   End if;

    /* Bug 5749509 - Reset the data migrator Mode */
      hr_general.g_data_migrator_mode := l_migrator_mode_status;

   EXCEPTION
     WHEN OTHERS THEN
         /* Bug 5749509 - Reset the data migrator Mode */
          hr_general.g_data_migrator_mode := l_migrator_mode_status;
      IF g_debug THEN
        hr_utility.set_location(gv_package_name || lv_procedure_name, 200);
        hr_utility.trace('ERROR:' || sqlcode ||'-'|| substr(sqlerrm,1,80));
       END IF;
       raise;
 END upgrade_element;

 /*--------------------------------------------------------------------------------
    Bug 5731490 - Changes for 11i Enhanced Retropay
    The following set of Functions/Procedures is used by
    Concurrent Program - "Enable Enhanced Retropay for All Australia Business Groups"
   --------------------------------------------------------------------------------
 */

/*
    Function    : set_retro_leg_rule
    Description : This function is to be used to enable Enhanced Retropay Legislation
                  Rule.The function will do the following,
                  (A) If Called from Upgrade process, set the Legislation Rule
                  (B) If Called from HRGLOBAL, return the Legislation Rule status
    Inputs      : p_calling_form         - Values : UPGRADE/HRGLOBAL
                                           Indicates where the function is called from
    Returns     : 'Y' - Rule is set
                  'N' - Rule is not set
*/


FUNCTION set_retro_leg_rule(p_calling_form varchar2)
RETURN varchar2
IS

CURSOR get_leg_rule
IS
SELECT rule_mode
FROM   pay_legislation_rules
WHERE  rule_type = 'ADVANCED_RETRO'
AND    legislation_code = 'AU';

CURSOR csr_exists
IS
SELECT count(*)
FROM   pay_legislation_rules
WHERE  rule_type = 'ADVANCED_RETRO'
AND    legislation_code = 'AU';


l_return_flag       VARCHAR2(10);
l_adv_retro_rule    VARCHAR2(10);
l_exists            NUMBER;
l_procedure_name         VARCHAR2(80);


BEGIN

    g_debug := hr_utility.debug_enabled;

    IF g_debug THEN
        l_procedure_name := '.set_retro_leg_rule';
        hr_utility.set_location('Entering Procedure '||gv_package_name||l_procedure_name,10);
        hr_utility.set_location('IN  p_calling_form '||p_calling_form,10);
    END IF;


    l_return_flag := 'N'; /* Default - Rule not enabled */

    IF (p_calling_form = 'HRGLOBAL')
    THEN
        OPEN get_leg_rule;
        FETCH get_leg_rule INTO l_adv_retro_rule;
        CLOSE get_leg_rule ;

        IF NVL(l_adv_retro_rule,'N') = 'Y'
        THEN
           l_return_flag := 'Y';
        ELSE
           l_return_flag := 'N';
        END IF;
    ELSE /* p_calling_form = 'UPGRADE' */

        OPEN get_leg_rule;
        FETCH get_leg_rule INTO l_adv_retro_rule;
        CLOSE get_leg_rule ;

        IF NVL(l_adv_retro_rule,'N') = 'Y'
        THEN
           l_return_flag := 'Y';
        ELSE
            /* Insert the legislation rule */
            OPEN  csr_exists;
            FETCH csr_exists INTO l_exists;
            CLOSE csr_exists;

            IF l_exists = 0 THEN
                INSERT INTO pay_legislation_rules
                            (rule_type
                            ,rule_mode
                            ,legislation_code)
                            VALUES
                            ('ADVANCED_RETRO'
                            ,'Y'
                            ,'AU');
                l_return_flag := 'Y';
           ELSE
                UPDATE pay_legislation_rules
                SET    rule_mode = 'Y'
                WHERE  rule_type = 'ADVANCED_RETRO'
                AND    legislation_code = 'AU' ;
                l_return_flag := 'Y';
          END IF;
        END IF;
    END IF;

  RETURN l_return_flag;
END set_retro_leg_rule;

 --------------------------------------------------------------------------
  -- Private Function to create retro definitions
  -- If the retro shortname already exists for this legislation
  -- then it will not be inserted or updated.
  --------------------------------------------------------------------------


  FUNCTION create_retro_definitions
     (p_short_name in pay_retro_definitions.short_name%TYPE
     ,p_definition_name in pay_retro_definitions.definition_name%TYPE)
  RETURN NUMBER
  IS
    --
    l_retro_definition_id pay_retro_definitions.retro_definition_id%TYPE;
    --
    CURSOR csr_defn_exists
    IS
    SELECT retro_definition_id
    FROM   pay_retro_definitions
    WHERE  short_name = p_short_name
    AND    legislation_code = g_legislation_code;
    --
    CURSOR csr_get_defn_id
    IS
    SELECT pay_retro_definitions_s.nextval
    FROM dual;
    --
  BEGIN
    --
    OPEN csr_defn_exists;
    FETCH csr_defn_exists INTO l_retro_definition_id;
    CLOSE csr_defn_exists;
    --
    IF l_retro_definition_id IS NULL THEN
      --
      OPEN csr_get_defn_id;
      FETCH csr_get_defn_id INTO l_retro_definition_id;
      CLOSE csr_get_defn_id;
      --
      INSERT INTO pay_retro_definitions
        (retro_definition_id
        ,short_name
        ,definition_name
        ,legislation_code)
      VALUES
        (l_retro_definition_id
        ,p_short_name
        ,p_definition_name
        ,g_legislation_code);
      --
    END IF;
    --
    RETURN l_retro_definition_id;
    --
  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.trace('Error: ' || sqlerrm);
      rollback;
      hr_utility.raise_error;
  END create_retro_definitions;
  --
  --------------------------------------------------------------------------
  -- Private Function to create retro components
  -- If the component shortname already exists for this legislation
  -- then the details will be updated.
  -- else a new retro component will be created.
  --------------------------------------------------------------------------
  FUNCTION create_retro_components
     (p_short_name in pay_retro_components.short_name%TYPE
     ,p_component_name in pay_retro_components.component_name%TYPE
     ,p_retro_type in pay_retro_components.retro_type%TYPE
     ,p_recalc_style in pay_retro_components.recalculation_style%TYPE
     ,p_date_override_proc in pay_retro_components.date_override_procedure%TYPE
      )
  RETURN NUMBER
  IS
    --
    l_retro_component_id pay_retro_components.retro_component_id%TYPE;
    --
    CURSOR csr_component_exists
    IS
    SELECT retro_component_id
    FROM   pay_retro_components
    WHERE  short_name = p_short_name
    AND    legislation_code = g_legislation_code;
    --
    CURSOR csr_get_comp_id
    IS
    SELECT pay_retro_components_s.nextval
    FROM dual;
    --
  BEGIN
    --
    OPEN csr_component_exists;
    FETCH csr_component_exists INTO l_retro_component_id;
    CLOSE csr_component_exists;
    --
    IF l_retro_component_id IS NULL THEN
      --
      OPEN csr_get_comp_id;
      FETCH csr_get_comp_id INTO l_retro_component_id;
      CLOSE csr_get_comp_id;
      --
      INSERT INTO pay_retro_components
        (retro_component_id
        ,short_name
        ,component_name
        ,retro_type
        ,legislation_code
        ,recalculation_style
        ,date_override_procedure)
      VALUES
        (l_retro_component_id
        ,p_short_name
        ,p_component_name
        ,p_retro_type
        ,g_legislation_code
        ,p_recalc_style
        ,p_date_override_proc);
      --
    ELSE
      --
      UPDATE pay_retro_components
      SET component_name = p_component_name
        , retro_type     = p_retro_type
        , recalculation_style = p_recalc_style
        , date_override_procedure = p_date_override_proc
       WHERE retro_component_id = l_retro_component_id;
       --
    END IF;
    --
    RETURN l_retro_component_id;
    --
  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.trace('Error: ' || sqlerrm);
      rollback;
      hr_utility.raise_error;
  END create_retro_components;
  --
  --------------------------------------------------------------------------
  -- Private Function to create retro definition components
  -- If the definition and component combination already exists
  -- then the priority will be updated.
  -- else a new retro definition component will be created.
  --------------------------------------------------------------------------
  FUNCTION create_retro_defn_components
     (p_retro_definition_id pay_retro_defn_components.retro_definition_id%TYPE
     ,p_retro_component_id  pay_retro_defn_components.retro_component_id%TYPE
     ,p_priority in pay_retro_defn_components.priority%TYPE)
  RETURN NUMBER
  IS
    --
    l_definition_component_id pay_retro_defn_components.definition_component_id%TYPE;
    --
    CURSOR csr_defn_comp_exists
    IS
    SELECT definition_component_id
    FROM   pay_retro_defn_components
    WHERE  retro_definition_id = p_retro_definition_id
    AND    retro_component_id = p_retro_component_id;
    --
    CURSOR csr_get_defn_comp_id IS
    SELECT pay_retro_defn_components_s.nextval
    from dual;
    --
  BEGIN
    --
    OPEN csr_defn_comp_exists;
    FETCH csr_defn_comp_exists INTO l_definition_component_id;
    CLOSE csr_defn_comp_exists;
    --
    IF l_definition_component_id IS NULL THEN
      --
      OPEN csr_get_defn_comp_id;
      FETCH csr_get_defn_comp_id INTO l_definition_component_id;
      CLOSE csr_get_defn_comp_id;
      --
      INSERT INTO pay_retro_defn_components
        (definition_component_id
        ,retro_definition_id
        ,retro_component_id
        ,priority)
      VALUES
        (l_definition_component_id
        ,p_retro_definition_id
        ,p_retro_component_id
        ,p_priority);
      --
    ELSE
      --
      UPDATE pay_retro_defn_components
      SET priority = p_priority
      WHERE definition_component_id = l_definition_component_id
      AND retro_definition_id = p_retro_definition_id
      AND retro_component_id = p_retro_component_id;
      --
    END IF;
    --
    RETURN l_definition_component_id;
    --
  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.trace('Error: ' || sqlerrm);
      rollback;
      hr_utility.raise_error;
  END create_retro_defn_components;

  --
  --------------------------------------------------------------------------
  -- Private Function to create time definitions
  -- If the short_name and period_type combination already exists
  -- then the other fields will be updated.
  -- else a new time definition will be created.
  --------------------------------------------------------------------------
  FUNCTION create_time_definitions
    (p_short_name pay_time_definitions.short_name%TYPE
    ,p_definition_name pay_time_definitions.definition_name%TYPE
    ,p_period_type pay_time_definitions.period_type%TYPE
    ,p_period_unit pay_time_definitions.period_unit%TYPE
    ,p_day_adjustment pay_time_definitions.day_adjustment%TYPE
    ,p_dynamic_code pay_time_definitions.dynamic_code%TYPE)
  RETURN NUMBER
  IS
    --
    l_time_definition_id pay_time_definitions.time_definition_id%TYPE;
    --
    CURSOR csr_time_definition_exists
    IS
    SELECT time_definition_id
    FROM   pay_time_definitions
    WHERE  short_name = p_short_name
    AND    period_type = p_period_type
    AND    legislation_code = g_legislation_code;
    --
    CURSOR csr_get_time_definition
    IS
    SELECT pay_time_definitions_s.nextval
    from dual;
    --
  BEGIN
    --
    OPEN csr_time_definition_exists;
    FETCH csr_time_definition_exists INTO l_time_definition_id;
    CLOSE csr_time_definition_exists;
    --
    IF l_time_definition_id IS NULL THEN
      --
      OPEN csr_get_time_definition;
      FETCH csr_get_time_definition INTO l_time_definition_id;
      CLOSE csr_get_time_definition;
      --
      INSERT INTO pay_time_definitions
        (time_definition_id
        ,short_name
        ,definition_name
        ,period_type
        ,period_unit
        ,day_adjustment
        ,dynamic_code
        ,business_group_id
        ,legislation_code)
      VALUES
        (l_time_definition_id
        ,p_short_name
        ,p_definition_name
        ,p_period_type
        ,p_period_unit
        ,p_day_adjustment
        ,p_dynamic_code
        ,null
        ,g_legislation_code);
      --
    ELSE
      --
      UPDATE pay_time_definitions
      SET    definition_name = p_definition_name
        ,    period_unit = p_period_unit
        ,    day_adjustment = p_day_adjustment
        ,    dynamic_code = p_dynamic_code
      WHERE  time_definition_id = l_time_definition_id;
      --
    END IF;
    --
    RETURN l_time_definition_id;
    --
  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.trace('Error: ' || sqlerrm);
      rollback;
      hr_utility.raise_error;
  END create_time_definitions;

  --------------------------------------------------------------------------
  -- Private Function to create time spans
  -- If the creator_id and creator_type combination already exists
  -- then the start and end time definition ids will be updated.
  -- else a new time span will be created.
  --------------------------------------------------------------------------
  FUNCTION create_time_spans
     (p_creator_id pay_time_spans.creator_id%TYPE
     ,p_creator_type pay_time_spans.creator_type%TYPE
     ,p_start_time_def_id pay_time_spans.start_time_def_id%TYPE
     ,p_end_time_def_id pay_time_spans.end_time_def_id%TYPE)
  RETURN NUMBER
  IS
    --
    l_time_span_id pay_time_spans.time_span_id%TYPE;
    --
    CURSOR csr_time_span_exists
    IS
    SELECT time_span_id
    FROM   pay_time_spans
    WHERE  creator_id = p_creator_id
    AND    creator_type = p_creator_type
    AND    start_time_def_id = p_start_time_def_id
    AND    end_time_def_id   = p_end_time_def_id;

    CURSOR csr_get_time_span
    IS
    select pay_time_spans_s.nextval
    from dual;
    --
  BEGIN
    --
    OPEN csr_time_span_exists;
    FETCH csr_time_span_exists INTO l_time_span_id;
    CLOSE csr_time_span_exists;
    --
    IF l_time_span_id IS NULL THEN
      --
          open csr_get_time_span;
          fetch csr_get_time_span into l_time_span_id;
          close csr_get_time_span;

          INSERT INTO pay_time_spans
            (time_span_id
            ,creator_id
            ,creator_type
            ,start_time_def_id
            ,end_time_def_id)
          VALUES(l_time_span_id
               , p_creator_id
               , p_creator_type
               , p_start_time_def_id
               , p_end_time_def_id);
      --
    ELSE
      --
      UPDATE pay_time_spans
      SET    start_time_def_id = p_start_time_def_id
        ,    end_time_def_id = p_end_time_def_id
      WHERE  time_span_id = l_time_span_id;
      --
    END IF;

    RETURN l_time_span_id;
    --
  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.trace('Error: While inserting time spans : ' || sqlerrm);
      rollback;
      hr_utility.raise_error;
      --
  END create_time_spans;

  --------------------------------------------------------------------------
  -- Private Function to create element spans
  -- If the creator_id and creator_type combination already exists
  -- then the details will not be updated.
  --------------------------------------------------------------------------
  PROCEDURE create_element_spans
    (p_retro_component_usage_id IN pay_retro_component_usages.retro_component_usage_id%TYPE
    ,p_retro_component_id IN pay_retro_components.retro_component_id%TYPE
    ,p_retro_element_name IN pay_element_types_f.element_name%TYPE
    ,p_time_span_id IN pay_element_span_usages.time_span_id%TYPE
    )
  IS
  --
    l_time_span_id  pay_time_spans.time_span_id%TYPE;
    l_element_type_id pay_element_types_f.element_type_id%TYPE;
    l_element_span_usage_id pay_element_span_usages.element_span_usage_id%TYPE;
  --
    CURSOR csr_get_element_type_id IS
    SELECT element_type_id
    FROM   pay_element_types_f
    WHERE  element_name = p_retro_element_name
    AND    legislation_code = g_legislation_code;
  --
    CURSOR csr_exists IS
    SELECT element_span_usage_id
    FROM   pay_element_span_usages pesu
    WHERE  pesu.retro_component_usage_id = p_retro_component_usage_id
    AND    pesu.time_span_id = p_time_span_id
    AND    pesu.adjustment_type IS NULL;
  --
  BEGIN
  --
    hr_utility.trace('Fetch the required details');
    --
    hr_utility.trace('Checking... if it already exists');
    --
    OPEN csr_exists;
    FETCH csr_exists INTO l_element_span_usage_id;
    CLOSE csr_exists;
    --
    IF l_element_span_usage_id is null THEN
    --
      OPEN csr_get_element_type_id;
      FETCH csr_get_element_type_id INTO l_element_type_id;
      CLOSE csr_get_element_type_id;
    --
      INSERT INTO pay_element_span_usages
        (ELEMENT_SPAN_USAGE_ID
        ,LEGISLATION_CODE
        ,TIME_SPAN_ID
        ,RETRO_COMPONENT_USAGE_ID
        ,RETRO_ELEMENT_TYPE_ID
        ,CREATION_DATE
        ,CREATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_LOGIN
        ,OBJECT_VERSION_NUMBER)
       SELECT pay_element_span_usages_s.nextval
            , g_legislation_code
            , p_time_span_id
            , p_retro_component_usage_id
            , l_element_type_id
            , sysdate
            , 1
            , sysdate
            , 1
            , -1
            , 1
         FROM dual;
       --
       hr_utility.trace('Inserted the required element');
     END IF;
  --
  END create_element_spans;

  --
  --------------------------------------------------------------------------
  -- Private Function to create component usages and element spans
  -- Uses the supporint procedure create_element_spans
  --------------------------------------------------------------------------
  PROCEDURE create_comp_usages (p_creator_name       IN VARCHAR2
                               ,p_retro_element_name IN VARCHAR2
                               ,p_component_name     IN VARCHAR2
                               ,p_reprocess_type     IN VARCHAR2
                               ,p_default_component  IN VARCHAR2
                               ,p_time_span_id IN pay_element_span_usages.time_span_id%TYPE
                               )
  IS
  --
    l_retro_component_usage_id pay_retro_component_usages.retro_component_usage_id%TYPE;
    l_retro_component_id pay_retro_components.retro_component_id%TYPE;
    l_element_type_id pay_element_types_f.element_type_id%TYPE;
  --
    CURSOR csr_get_details IS
    SELECT c.retro_component_id
         , e.element_type_id
    FROM   pay_retro_components c
        ,  pay_element_types_f  e
    WHERE c.component_name = p_component_name
    AND   e.element_name   = p_creator_name
    AND   e.legislation_code = g_legislation_code
    AND   c.legislation_code = g_legislation_code;
  --
    CURSOR csr_exists IS
    SELECT retro_component_usage_id
    FROM   pay_retro_component_usages prcu
    WHERE  prcu.retro_component_id = l_retro_component_id
    AND    prcu.creator_id         = l_element_type_id
    AND    prcu.creator_type       ='ET';
  --
  BEGIN
  --
    OPEN csr_get_details;
    FETCH csr_get_details INTO l_retro_component_id, l_element_type_id;
    IF csr_get_details%NOTFOUND THEN
       hr_utility.trace('Invalid component or element type');
       hr_utility.raise_error;
    END IF;
    CLOSE csr_get_details;
  --
    hr_utility.trace('Valid component and element type');
  --
    OPEN csr_exists;
    FETCH csr_exists into l_retro_component_usage_id;
    CLOSE csr_exists;
  --
    IF l_retro_component_usage_id is null THEN
    --
      hr_utility.trace('Before inserting data into component usages');
      --
      INSERT INTO pay_retro_component_usages
        (RETRO_COMPONENT_USAGE_ID
        ,RETRO_COMPONENT_ID
        ,CREATOR_ID
        ,CREATOR_TYPE
        ,DEFAULT_COMPONENT
        ,REPROCESS_TYPE
        ,LEGISLATION_CODE
        ,CREATION_DATE
        ,CREATED_BY
        ,LAST_UPDATE_DATE
        ,LAST_UPDATED_BY
        ,LAST_UPDATE_LOGIN
        ,OBJECT_VERSION_NUMBER)
      SELECT
         pay_retro_component_usages_s.nextval
        ,l_retro_component_id
        ,l_element_type_id
        ,'ET'
        ,p_default_component
        ,p_reprocess_type
        ,g_legislation_code
        ,sysdate
        ,1
        ,sysdate
        ,1
        ,-1
        ,1
         FROM  dual;
      --
      SELECT pay_retro_component_usages_s.currval
      INTO l_retro_component_usage_id
      from dual;
      --
      hr_utility.trace('Inserted retro component usage: ' || l_retro_component_usage_id);
      --
      create_element_spans(l_retro_component_usage_id
                          ,l_retro_component_id
                          ,p_retro_element_name
                          ,p_time_span_id);
       --
      END IF;
      --
      hr_utility.trace('Inserted retro component: ' || p_retro_element_name);
      --
  END create_comp_usages;

  --------------------------------------------------------------------------
  --
  -- Private Function to get time definitions
  -- Bug#5556042
  --------------------------------------------------------------------------
  FUNCTION get_time_definitions
    (p_short_name pay_time_definitions.short_name%TYPE
     )
  RETURN NUMBER
  IS
    --
    l_time_definition_id pay_time_definitions.time_definition_id%TYPE;
    --
    CURSOR csr_get_time_definition
    IS
    SELECT time_definition_id
    FROM   pay_time_definitions
    WHERE  short_name = p_short_name
    AND    legislation_code = 'AU';
    --
    --
  BEGIN
    --
    OPEN csr_get_time_definition;
    FETCH csr_get_time_definition INTO l_time_definition_id;
    CLOSE csr_get_time_definition;
    --
    RETURN l_time_definition_id;
    --
  EXCEPTION
    WHEN OTHERS THEN
      hr_utility.trace('Error: ' || sqlerrm);
      rollback;
      hr_utility.raise_error;
  END get_time_definitions;


  --------------------------------------------------------------------------
  --
  -- Private Function to set the Retropay Status Update rule
  -- Bug#5889919
  --------------------------------------------------------------------------

PROCEDURE set_retro_status_rule
IS

CURSOR csr_exists
IS
SELECT count(*)
FROM   pay_legislation_rules
WHERE  rule_type = 'RETRO_STATUS_USER_UPD'
AND    legislation_code = 'AU';


l_adv_retro_rule    VARCHAR2(10);
l_exists            NUMBER;
l_procedure_name         VARCHAR2(80);


BEGIN

    g_debug := hr_utility.debug_enabled;

    IF g_debug THEN
        l_procedure_name := '.set_retro_status_rule';
        hr_utility.set_location('Entering Procedure '||gv_package_name||l_procedure_name,10);
    END IF;

    /* Insert the legislation rule */
    OPEN  csr_exists;
    FETCH csr_exists INTO l_exists;
    CLOSE csr_exists;

    IF l_exists = 0 THEN
        INSERT INTO pay_legislation_rules
                    (rule_type
                    ,rule_mode
                    ,legislation_code)
                    VALUES
                    ('RETRO_STATUS_USER_UPD'
                    ,'Y'
                    ,'AU');
    ELSE
        UPDATE pay_legislation_rules
        SET    rule_mode = 'Y'
        WHERE  rule_type = 'RETRO_STATUS_USER_UPD'
        AND    legislation_code = 'AU' ;
    END IF;

    IF g_debug THEN
        hr_utility.set_location('Leagvin Procedure '||gv_package_name||l_procedure_name,10);
    END IF;

END set_retro_status_rule;



/*
    Procedure   : create_enhanced_retro_defn
    Description : This procedure should be used to insert/update the Retro Definitions
                  and Retro components for using Enhanced Retropay.
*/


PROCEDURE create_enhanced_retro_defn
IS

    l_retro_defn_id  pay_retro_definitions.retro_definition_id%TYPE;
    l_corr_up_comp   pay_retro_components.retro_component_id%TYPE;
    l_back_up_comp   pay_retro_components.retro_component_id%TYPE;
    l_db_lumpsum_comp pay_retro_components.retro_component_id%TYPE;
    l_defn_comp_id   pay_retro_defn_components.definition_component_id%TYPE;
    l_start_time_id  pay_time_definitions.time_definition_id%TYPE;
    l_end_time_id    pay_time_definitions.time_definition_id%TYPE;
    l_time_span_id   pay_time_spans.time_span_id%TYPE;

BEGIN

  -- Initialize global variables
  g_legislation_code := 'AU';


/* Bug 5889919
    Insert the Retropay Status Update Legislation Rule
*/
    set_retro_status_rule;
  --
  -- Insert a new retro definition for Australia
  ------------------------------------------------
  --
  l_retro_defn_id := create_retro_definitions
     (p_short_name => 'AU_RETROPAY'
     ,p_definition_name => 'Retropay (Australia)');

  --
  -- Populate the retro components table with the
  -- components required for Australia
  -----------------------------------------------
  --
  l_back_up_comp := create_retro_components
     (p_short_name => 'AU_BACKDATES'
     ,p_component_name => 'Backdated Changes'
     ,p_retro_type => 'F'
     ,p_recalc_style => null
     ,p_date_override_proc => null);
  --
  --
  -- Populate retro_defn_components for the components
  -- required for Australia
  ----------------------------------------------------
  --
  l_defn_comp_id := create_retro_defn_components
     (l_retro_defn_id
     ,l_back_up_comp
     ,20);
  --
  /*
   Insert new time definitions and time spans required for Australia
*/
--
--   1. Retro Payments Greater than 12 Months
---------------------------------------------------------
  l_start_time_id := create_time_definitions
     (p_short_name => 'START_OF_TIME'
     ,p_definition_name => 'Start of Time'
     ,p_period_type => 'START_OF_TIME'
     ,p_period_unit => '0'
     ,p_day_adjustment => 'CURRENT'
     ,p_dynamic_code => null);
  --
  l_end_time_id := create_time_definitions
     (p_short_name => 'END_OF_12_MONTHS'
     ,p_definition_name => '1 Year Prior To Current Date'  /* Bug 5522733 Modified Defn name */
     ,p_period_type => 'MONTH'
     ,p_period_unit => '-12'
     ,p_day_adjustment => 'PRIOR'
     ,p_dynamic_code => null);

  l_time_span_id := create_time_spans
     (p_creator_id => l_back_up_comp
     ,p_creator_type => 'RC'
     ,p_start_time_def_id => l_start_time_id
     ,p_end_time_def_id => l_end_time_id);
  --
--
--   2. Retro Payments Less than 12 Months Previous Year
---------------------------------------------------------
  l_start_time_id := create_time_definitions
     (p_short_name => 'START_OF_PREV_LT12'
     ,p_definition_name => '1 Year Prior To Current Date '    /* Bug 5522733 Modified Defn name */
     ,p_period_type => 'MONTH'
     ,p_period_unit => '-12'
     ,p_day_adjustment => 'CURRENT'
     ,p_dynamic_code => null);
  --
  l_end_time_id := create_time_definitions
     (p_short_name => 'END_OF_PREV_YEAR'
     ,p_definition_name => 'End of Previous Year'
     ,p_period_type => 'TYEAR'
     ,p_period_unit => '0'
     ,p_day_adjustment => 'PRIOR'
     ,p_dynamic_code => null);

  l_time_span_id := create_time_spans
     (p_creator_id => l_back_up_comp
     ,p_creator_type => 'RC'
     ,p_start_time_def_id => l_start_time_id
     ,p_end_time_def_id => l_end_time_id);
--
--
--   3. Retro Payments in Current Financial Year
---------------------------------------------------------
  l_start_time_id := create_time_definitions
     (p_short_name => 'START_OF_CURRENT_YEAR'
     ,p_definition_name => 'Start of Current Year'
     ,p_period_type => 'TYEAR'
     ,p_period_unit => '0'
     ,p_day_adjustment => 'CURRENT'
     ,p_dynamic_code => null);
  --
  l_end_time_id := create_time_definitions
     (p_short_name => 'END_OF_TIME'
     ,p_definition_name => 'End of Time'
     ,p_period_type => 'END_OF_TIME'
     ,p_period_unit => '0'
     ,p_day_adjustment => 'CURRENT'
     ,p_dynamic_code => null);

  l_time_span_id := create_time_spans
     (p_creator_id => l_back_up_comp
     ,p_creator_type => 'RC'
     ,p_start_time_def_id => l_start_time_id
     ,p_end_time_def_id => l_end_time_id);

  --

  -- Create component usages for Tax deductions
  ---------------------------------------------
  --
  create_comp_usages( 'Tax Deduction'
                    , 'Tax Deduction'
                    , 'Backdated Changes'
                    , 'R'
                    , 'Y'
                    ,l_time_span_id);

/* bug 7665727 - Component usages for retro HECS/SFSS Deduction */
  create_comp_usages( 'HECS Deduction'
                    , 'HECS Deduction'
                    , 'Backdated Changes'
                    , 'R'
                    , 'Y'
                    ,l_time_span_id);

  create_comp_usages( 'SFSS Deduction'
                    , 'SFSS Deduction'
                    , 'Backdated Changes'
                    , 'R'
                    , 'Y'
                    ,l_time_span_id);

  create_comp_usages( 'HECS Spread Deduction'
                    , 'HECS Deduction'
                    , 'Backdated Changes'
                    , 'R'
                    , 'Y'
                    ,l_time_span_id);

  create_comp_usages( 'SFSS Spread Deduction'
                    , 'SFSS Deduction'
                    , 'Backdated Changes'
                    , 'R'
                    , 'Y'
                    ,l_time_span_id);

  /*bug 8406009*/
  create_comp_usages( 'Spread Deduction'
                    , 'Spread Deduction'
                    , 'Backdated Changes'
                    , 'R'
                    , 'Y'
                    ,l_time_span_id);

---------------------------------------------------------------------------
--  Creating Time span Start Of Time - End Of Time for non earning elements
-----------------------------------------------------------------------------
--
    l_start_time_id := get_time_definitions(p_short_name => 'START_OF_TIME');
    l_end_time_id := get_time_definitions(p_short_name => 'END_OF_TIME');

    l_time_span_id := create_time_spans
      (p_creator_id => l_back_up_comp
      ,p_creator_type => 'RC'
      ,p_start_time_def_id => l_start_time_id
      ,p_end_time_def_id => l_end_time_id);


END create_enhanced_retro_defn;

/*
    Procedure   : set_enh_retro_request_group
    Description : This procedure sets up the Request Group for Australia
                  customers using Enhanced Retropay. It does the following
                  (A) Add Programs
                     - Retropay (Enhanced) (RETROENH)
                     - Retro-Notifications Report (Enhanced) (PAYRPRNP2)
                     - Retro-Notifications Report (Enhanced) - PDF (PYXMLRNP2)
                  (B) Remove Programs
                     - RetroPay By Element (RETROELE)
                     - Retro-Notifications Report (PAYRPRNP)
*/

PROCEDURE set_enh_retro_request_group
IS

TYPE char_tab_type is TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;

l_req_grp_name varchar2(80);
l_grp_app_name varchar2(10);

l_add_prog_name char_tab_type;
l_add_prog_app_name varchar2(10);

l_del_prog_name char_tab_type;
l_del_prog_app_name varchar2(10);

l_proc_name varchar2(80);
l_exists  boolean;

BEGIN
g_debug := hr_utility.debug_enabled;

IF g_debug
THEN
        l_proc_name := '.set_enh_retro_request_group';
        hr_utility.trace('Entering '||gv_package_name||l_proc_name);
END IF;

l_req_grp_name := 'AU HRMS Reports and Processes';
l_grp_app_name := 'PER';

/*  Add Concurrent Programs */
l_add_prog_app_name := 'PAY' ;

l_add_prog_name(1)     := 'RETROENH';  /* Program: Retropay (Enhanced) */
l_add_prog_name(2)     := 'PAYRPRNP2'; /* Program: Retro-Notifications Report (Enhanced) */
l_add_prog_name(3)     := 'PYXMLRNP2'; /* Program: Retro-Notifications Report (Enhanced) - PDF */


    FOR i IN l_add_prog_name.FIRST..l_add_prog_name.LAST
    LOOP

        l_exists := fnd_program.program_in_group(
                             program_short_name  => l_add_prog_name(i),
                             program_application => l_add_prog_app_name,
                             request_group       => l_req_grp_name,
                             group_application   => l_grp_app_name);

        IF (NOT l_exists)
        THEN

                   fnd_program.add_to_group(
                           program_short_name  => l_add_prog_name(i),
                           program_application => l_add_prog_app_name,
                           request_group       => l_req_grp_name,
                           group_application   => l_grp_app_name);

            IF g_debug
            THEN
                hr_utility.trace('Program Added to Request Group '||l_add_prog_name(i));
            END IF;
        END IF;
    END LOOP;

/* Delete Concurrent programs */
l_del_prog_app_name := 'PAY';

l_del_prog_name(1)      := 'RETROELE';  /* Program: Retropay by element */
l_del_prog_name(2)      := 'PAYRPRNP';  /* Program: Retro-Notifications Report (PAYRPRNP) */

    FOR i IN l_del_prog_name.FIRST..l_del_prog_name.LAST
    LOOP

        l_exists := fnd_program.program_in_group(
                             program_short_name  => l_del_prog_name(i),
                             program_application => l_add_prog_app_name,
                             request_group       => l_req_grp_name,
                             group_application   => l_grp_app_name);

        IF (l_exists)
        THEN

                   fnd_program.remove_from_group(
                           program_short_name  => l_del_prog_name(i),
                           program_application => l_add_prog_app_name,
                           request_group       => l_req_grp_name,
                           group_application   => l_grp_app_name);

            IF g_debug
            THEN
                hr_utility.trace('Program Removed from Request Group '||l_del_prog_name(i));
            END IF;
        END IF;
    END LOOP;

IF g_debug
THEN
        l_proc_name := '.set_enh_retro_request_group';
        hr_utility.trace('Leaving '||gv_package_name||l_proc_name);
END IF;
END set_enh_retro_request_group;

/*
    Procedure   : enable_au_enhanced_retro
    Description : This stored procedure is registered as concurrent program executable.
                  Procedure Enables Enhanced Retropay for Australia.
                  (A) Enh Retro Legislation Rule is defined
                  (B) Retro Defintions/Components/Time Spans are defined for Australia
                  (C) Australia Request Group set up to reflect Enh retro
                      Concurrent programs
    Inputs      : p_business_group_id   - Business Group ID
    Outputs     : errbuf                - Return Error Messages
                  retcode               - Return Completion Status
*/

PROCEDURE enable_au_enhanced_retro(
                               errbuf      OUT NOCOPY VARCHAR2
                              ,retcode     OUT NOCOPY NUMBER
                                )
IS

/*Bug 5879422 */
CURSOR csr_get_business_group_name IS
SELECT rownum ROW_NUM,pbg.name BUS_GROUP_NAME
FROM   per_business_groups pbg
WHERE  pbg.legislation_code = g_legislation_code;

l_leg_rule          VARCHAR2(20);

l_procedure_name    VARCHAR2(80);

l_bg_leg_code       VARCHAR2(10);

BEGIN

    g_debug := hr_utility.debug_enabled;
    g_legislation_code := 'AU';

    IF g_debug THEN
        l_procedure_name := '.enable_au_enhanced_retro';
        hr_utility.trace('Entering '||gv_package_name||l_procedure_name);
    END IF;

    l_leg_rule := pay_au_retro_upgrade.set_retro_leg_rule(p_calling_form => 'UPGRADE');

    IF ( l_leg_rule = 'Y')
    THEN
           fnd_file.put_line(FND_FILE.LOG,' MESSAGE: Enhanced Retropay Rule Enabled ');
           pay_au_retro_upgrade.create_enhanced_retro_defn;
           fnd_file.put_line(FND_FILE.LOG,' MESSAGE: Enhanced Retropay Retro Definitions Created ');
           pay_au_retro_upgrade.set_enh_retro_request_group;
           fnd_file.put_line(FND_FILE.LOG,' MESSAGE: Request Group - programs for Enhanced Retropay added ');
           fnd_file.put_line(FND_FILE.LOG,' MESSAGE: Enhanced Retropay is enabled for the following Australian Business Groups :');

           FOR i IN csr_get_business_group_name /*Bug 5879422 */
           LOOP
               fnd_file.put_line(FND_FILE.LOG,'   '||to_char(i.ROW_NUM)||') '||i.BUS_GROUP_NAME);
           END LOOP; /*Bug 5879422 */

           fnd_file.put_line(FND_FILE.LOG,' WARNING: Customers who have enabled Enhanced Retro Pay should note that Retro Pay by Element should no longer be used and should be removed from all customer menus.');/*Bug 5879422 */
    ELSE
           fnd_file.put_line(fnd_file.output,' MESSAGE: Enhanced Retropay Rule NOT Enabled ');
    END IF;

END enable_au_enhanced_retro;

/*
    Bug No      : 9299082
    Procedure   : enable_au_retro_overlap
    Description : This stored procedure is registered as concurrent program executable.
                  Procedure enables Retro Overlap for Enhanced Retropay functionality for Australia.
                  (A) Checks whether the Enh Retro Legislation Rule is enabled.
                  (B) If the Enh Retro rule is enabled,then Retro Overlap Legislation Rule will be defined.

    Outputs     : errbuf                - Return Error Messages
                  retcode               - Return Completion Status
*/

PROCEDURE enable_au_retro_overlap(
                                errbuf      OUT NOCOPY VARCHAR2
                               ,retcode     OUT NOCOPY NUMBER
                                 )
IS
   CURSOR c_retro_rule_check( cp_rule_type IN varchar2 )
   IS
   SELECT rule_mode
   FROM   pay_legislation_rules
   WHERE  legislation_code = g_legislation_code
   AND    rule_type = cp_rule_type;

   CURSOR csr_exists
   IS
   SELECT count(*)
   FROM   pay_legislation_rules
   WHERE  rule_type = 'RETRO_OVERLAP'
   AND    legislation_code = 'AU';

   CURSOR csr_get_business_group_name IS
   SELECT rownum ROW_NUM,pbg.name BG_NAME
   FROM   per_business_groups pbg
   WHERE  pbg.legislation_code = g_legislation_code;

   lv_procedure_name        VARCHAR2(100);
   l_retro_overlap_rule     VARCHAR2(1);
   l_adv_retro_rule         VARCHAR2(1);
   l_exists                 NUMBER;

 BEGIN

   g_debug := hr_utility.debug_enabled;
   g_legislation_code := 'AU';

   IF g_debug THEN
     lv_procedure_name := '.enable_au_retro_overlap';
     hr_utility.trace('Entering '||gv_package_name||lv_procedure_name);
   END IF;

     OPEN c_retro_rule_check('ADVANCED_RETRO') ;
     FETCH c_retro_rule_check into l_adv_retro_rule;
     CLOSE c_retro_rule_check;

                IF NVL(l_adv_retro_rule,'N') = 'Y' THEN

                    OPEN c_retro_rule_check('RETRO_OVERLAP');
                    FETCH c_retro_rule_check into l_retro_overlap_rule;
                    CLOSE c_retro_rule_check;

                    IF NVL(l_retro_overlap_rule,'Y') = 'N' THEN
                         fnd_file.put_line(FND_FILE.LOG,'MESSAGE: Retro Overlap Rule is enabled.');
                    ELSE
                        OPEN  csr_exists;
                        FETCH csr_exists INTO l_exists;
                        CLOSE csr_exists;

                        IF l_exists = 0 THEN
                            INSERT INTO pay_legislation_rules
                                        ( rule_type
                                         ,rule_mode
                                         ,legislation_code)
                                        VALUES
                                        ('RETRO_OVERLAP'
                                         ,'N'
                                         ,'AU');
                        ELSE
                            UPDATE  pay_legislation_rules
                            SET     RULE_MODE = 'N'
                            WHERE   legislation_code = g_legislation_code
                            AND     rule_type = 'RETRO_OVERLAP';
                        END IF;
                        fnd_file.put_line(FND_FILE.LOG,'MESSAGE: Retro Overlap Rule is enabled.');
                    END IF;

                        fnd_file.put_line(FND_FILE.LOG,'MESSAGE: Retro Overlap Rule is enabled for all AU Business Groups.');
                        FOR i IN csr_get_business_group_name LOOP
                             fnd_file.put_line(FND_FILE.LOG,'   '||to_char(i.ROW_NUM)||') '||i.BG_NAME);
                        END LOOP;
                ELSE
                  fnd_file.put_line(FND_FILE.LOG,'MESSAGE: Retro Overlap Rule is NOT enabled. Enhanced Retropay rule must be enabled before Retro Overlap upgrade.');
                END IF;

   IF g_debug THEN
     hr_utility.trace('Leaving '||gv_package_name||lv_procedure_name);
   END IF;

   EXCEPTION WHEN others THEN
       fnd_file.put_line(FND_FILE.LOG,gv_package_name||lv_procedure_name);
       fnd_file.put_line(FND_FILE.LOG,'ERROR:' || sqlcode ||'-'|| substr(sqlerrm,1,80));
       RAISE;

END enable_au_retro_overlap;

BEGIN

 gv_package_name := 'pay_au_retro_upgrade';
 g_legislation_code := 'AU';

END pay_au_retro_upgrade;

/
