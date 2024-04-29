--------------------------------------------------------
--  DDL for Package Body HXC_US_TIME_DEFINITIONS_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_US_TIME_DEFINITIONS_HOOK" AS
/* $Header: hxcusottd.pkb 120.2 2006/10/05 20:18:55 asasthan noship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : HXC_US_TIME_DEFINITIONS_HOOK
    File Name   : hxcusottd.pkb

    Description : The package is called from the following places:
                  1. After Insert Row Handler User Hook Call on
                     HXC_PREF_HIERARCHIES
                  2. After Update Row Handler User Hook Call on
                     HXC_PREF_HIERARCHIES
                  3. After Update Row Handler User Hook Call on
                     HXC_RECURRING_PERIODS
                  4. Before Process Business Process User Hook Call
                     on UPDATE_TIME_DEFINITION

                  I.  The package Creates/Updates rows in pay_time_definitions
                      and per_time_periods as and when rows are created/updated
                      in HXC_PREF_HIERARCHIES
                  II. The package Updates a row in pay_time_definitions as and
                      when a row is updated in HXC_RECURRING_PERIODS

    Change List
    -----------
    Name           Date          Version Bug      Text
    -------------- -----------   ------- -------  -----------------------------
    rdhingra       24-Jan-2006   115.0   FLSA     Created
    asasthan       05-OCT-2006   120.1   5560111  Start date of OT period
                                                  is used to
                                                  create row in pay_time_def


  *****************************************************************************/

   /******************************************************************************
   Name        : INSERT_TIME_DEF_HIERARCHY
   Scope       : LOCAL
   Description : This procedure calls core api to insert a row in
                 pay_time_ definitions which inturn inserts rows in
                 per_time_periods too.
      ******************************************************************************/

TABLE_DOES_NOT_EXIST EXCEPTION;
PRAGMA EXCEPTION_INIT(TABLE_DOES_NOT_EXIST, -942);


   PROCEDURE insert_time_def_hierarchy (
      p_business_group_id   IN   NUMBER,
      p_attribute2          IN   VARCHAR2 DEFAULT NULL,
      p_attribute3          IN   VARCHAR2 DEFAULT NULL
   ) IS

      lv_td_exist                     VARCHAR2 (1);
      lv_payroll                      VARCHAR2(1);
      lv_name                         hxc_recurring_periods.NAME%TYPE;
      lv_period_type                  hxc_recurring_periods.period_type%TYPE;
      ld_start_date                   hxc_recurring_periods.start_date%TYPE;
      ld_period_start                 hxc_recurring_periods.start_date%TYPE;
      ld_period_end                   hxc_recurring_periods.end_date%TYPE;
      ln_duration_in_days             hxc_recurring_periods.DURATION_IN_DAYS%TYPE;
      ln_tot_years                    NUMBER := 5;
      ln_time_definition_id           NUMBER;
      ln_ovn                          NUMBER;

      TYPE RefCurType IS REF CURSOR;
      c_check_retrieval_payroll       RefCurType;
      c_recurring_period_name         RefCurType;
      c_check_recurring_id            RefCurType;

      c_check_retrieval_payroll_sql   VARCHAR2(10000);
      c_recurring_period_name_sql     VARCHAR2(10000);
      c_check_recurring_id_sql        VARCHAR2(10000);


   BEGIN
      hr_utility.TRACE('Entering INSERT_TIME_DEF_HIERARCHY');

      lv_payroll := NULL;
      c_check_retrieval_payroll_sql :=
                              'SELECT ''Y''
                                 FROM hxc_retrieval_rule_comps_v hrrc,
                                      hxc_retrieval_rules_v hrr
                                WHERE hrrc.time_recipient = ''Payroll''
                                  AND hrr.retrieval_rule_id = hrrc.retrieval_rule_id
                                  AND hrr.retrieval_rule_id = '|| p_attribute2 ;

      -- Cursor to check whether application is 'Payroll' or not.
      OPEN c_check_retrieval_payroll FOR c_check_retrieval_payroll_sql;
      FETCH c_check_retrieval_payroll INTO lv_payroll;

      IF c_check_retrieval_payroll%FOUND THEN

         c_recurring_period_name_sql :=
                                'SELECT NAME,
                                        period_type,
                                        start_date,
                                        duration_in_days
                                   FROM hxc_recurring_periods
                                  WHERE recurring_period_id = '|| p_attribute3;

         BEGIN
            -- Cursor which is used to fetch the recurring period related info
            OPEN c_recurring_period_name FOR c_recurring_period_name_sql;
            FETCH c_recurring_period_name INTO lv_name,
                                               lv_period_type,
                                               ld_start_date,
                                               ln_duration_in_days;
            CLOSE c_recurring_period_name;
         EXCEPTION WHEN TABLE_DOES_NOT_EXIST THEN
            hr_utility.TRACE ('Inside Exception TABLE_DOES_NOT_EXIST in '||
                              'hxc_us_time_definitions_hook.insert_time_def_hierarchy');
            hr_utility.set_message(801, 'PAY_US_MISSING_TABLES');
    	    hr_utility.set_message_token(801,
                                         'ERROR_TEXT',
                                         'Error while inserting a row in pay_time_definitions'
                                         );
            hr_utility.set_message_token(801, 'TABLE_NAME', 'HXC_RECURRING_PERIODS');
            hr_utility.raise_error;
         END;


        /* Get the OT Start Date and OT End Date of the week containing
           sysdate by calling OTL function and assign to ld_start_date */

           hxc_timecard_utilities.find_current_period
                         (p_rec_period_start_date      => ld_start_date,
                          p_period_type                => lv_period_type,
                          p_duration_in_days           => ln_duration_in_days,
                          p_current_date               => sysdate,
                          p_period_start               => ld_period_start,
                          p_period_end                 => ld_period_end
                         );


         c_check_recurring_id_sql :=
                              'SELECT /*+ INDEX (ptd PAY_TIME_DEFINITIONS_N1) */
                                     ''Y''
                                FROM pay_time_definitions ptd
                               WHERE ptd.creator_type = ''OTL_W''
                                 and ptd.creator_id = '|| p_attribute3;

         BEGIN
            -- Cursor to check if a row exists in pay_time_definitions
            OPEN c_check_recurring_id FOR c_check_recurring_id_sql;
            FETCH c_check_recurring_id INTO lv_td_exist;

            IF c_check_recurring_id%NOTFOUND THEN
               pay_time_definition_api.create_time_definition
                               (p_effective_date             => SYSDATE,
                                p_short_name                 => lv_name,
                                p_definition_name            => lv_name,
                                p_period_type                => lv_period_type,
                                p_business_group_id          => p_business_group_id,
                                p_definition_type            => 'S',/*Only Weekly from OTL*/
                                p_number_of_years            => ln_tot_years,
                                p_start_date                 => ld_period_start,
                                p_creator_id                 => p_attribute3,
                                p_creator_type               => 'OTL_W',
                                p_time_definition_id         => ln_time_definition_id,
                                p_object_version_number      => ln_ovn
                               );
            END IF;
            CLOSE c_check_recurring_id;
         EXCEPTION WHEN TABLE_DOES_NOT_EXIST THEN
            hr_utility.TRACE ('Inside Exception TABLE_DOES_NOT_EXIST in '||
                              'hxc_us_time_definitions_hook.insert_time_def_hierarchy');
            hr_utility.set_message(801, 'PAY_US_MISSING_TABLES');
    	    hr_utility.set_message_token(801,
                                         'ERROR_TEXT',
                                         'Error while inserting a row in pay_time_definitions'
                                         );
            hr_utility.set_message_token(801, 'TABLE_NAME', 'PAY_TIME_DEFINITIONS');
            hr_utility.raise_error;
         END;
      END IF;

     CLOSE c_check_retrieval_payroll;
     hr_utility.TRACE ('Leaving INSERT_TIME_DEF_HIERARCHY');


     EXCEPTION WHEN TABLE_DOES_NOT_EXIST THEN
        hr_utility.TRACE ('Inside Exception TABLE_DOES_NOT_EXIST in '||
                          'hxc_us_time_definitions_hook.insert_time_def_hierarchy');
        hr_utility.set_message(801, 'PAY_US_MISSING_TABLES');
        hr_utility.set_message_token(801,
                                     'ERROR_TEXT',
                                     'Error while inserting a row in pay_time_definitions'
                                     );
    	hr_utility.set_message_token(801, 'TABLE_NAME', 'HXC_RETRIEVAL_RULE_COMPS_V, '||
                                                        'HXC_RETRIEVAL_RULES_V'
                                    );
        hr_utility.raise_error;

   END insert_time_def_hierarchy;

   /******************************************************************************
   Name        : UPDATE_TIME_DEF_RECURRING
   Scope       : LOCAL
   Description : This procedure calls core api to update the time definition
                 name if it already exists
      ******************************************************************************/
   PROCEDURE update_time_def_recurring (
     p_recurring_period_id  IN NUMBER
    ,p_name                 IN VARCHAR2
   ) IS

      ld_start_date                   pay_time_definitions.start_date%TYPE;
      ln_time_definition_id           NUMBER;
      ln_ovn                          NUMBER;

      TYPE RefCurType IS REF CURSOR;
      c_check_recurring_id            RefCurType;

      c_check_recurring_id_sql        VARCHAR2(10000);


   BEGIN
      hr_utility.TRACE('Entering UPDATE_TIME_DEF_RECURRING');

      c_check_recurring_id_sql :=
                           'SELECT  /*+ INDEX (ptd PAY_TIME_DEFINITIONS_N1) */
                                    ptd.time_definition_id,
                                    ptd.start_date,
                                    ptd.object_version_number
                               FROM pay_time_definitions ptd
                              WHERE ptd.creator_type = ''OTL_W''
                                AND ptd.creator_id = '|| p_recurring_period_id;

      -- Cursor to check if a row exists in pay_time_definitions
      OPEN c_check_recurring_id FOR c_check_recurring_id_sql;
      FETCH c_check_recurring_id INTO ln_time_definition_id,
                                      ld_start_date,
                                      ln_ovn;
      IF (c_check_recurring_id%NOTFOUND OR
          ln_time_definition_id IS NULL) THEN
                NULL;
      ELSE
                pay_time_definition_api.update_time_definition
                /*This table is not date_tracked as of now*/
                  (p_validate                      => FALSE
                  ,p_effective_date                => ld_start_date
                  ,p_time_definition_id            => ln_time_definition_id
                  ,p_definition_name               => p_name
                  ,p_object_version_number         => ln_ovn
                 );

      END IF;
      CLOSE c_check_recurring_id;

      hr_utility.TRACE ('Leaving UPDATE_TIME_DEF_RECURRING');

      EXCEPTION WHEN TABLE_DOES_NOT_EXIST THEN
        hr_utility.TRACE ('Inside Exception TABLE_DOES_NOT_EXIST in '||
                          'hxc_us_time_definitions_hook.update_time_def_recurring');
        hr_utility.set_message(801, 'PAY_US_MISSING_TABLES');
        hr_utility.set_message_token(801,
                                     'ERROR_TEXT',
                                     'Error while updating a row in pay_time_definitions'
                                     );
    	hr_utility.set_message_token(801, 'TABLE_NAME', 'PAY_TIME_DEFINITIONS');
        hr_utility.raise_error;
   END update_time_def_recurring;

   /******************************************************************************
   Name        : STATUS_OTL_TIME_DEF
   Scope       : LOCAL
   Description : This procedure verifies that apart from no of years nothing else
                 is getting updated in the time_definition created by OTL
      ******************************************************************************/
   PROCEDURE status_otl_time_def (
      p_time_definition_id         IN  NUMBER
     ,p_definition_name            IN  VARCHAR2
     ,p_period_type                IN  VARCHAR2
     ,p_start_date                 IN  DATE
     ,p_period_time_definition_id  IN  NUMBER
   ) IS



      ln_is_error               NUMBER;
      lv_def_name               pay_time_definitions.definition_name%TYPE;
      lv_period_type            pay_time_definitions.period_type%TYPE;
      ld_start_date             pay_time_definitions.start_date%TYPE;
      ld_pd_td_id               pay_time_definitions.period_time_definition_id%TYPE;

      TYPE RefCurType is REF CURSOR;
      c_get_timedef_detail      RefCurType;

      c_get_timedef_detail_sql  VARCHAR2(10000);



   BEGIN
      hr_utility.TRACE('Entering STATUS_OTL_TIME_DEF');



      c_get_timedef_detail_sql :=
                          'SELECT  definition_name
                                  ,period_type
                                  ,start_date
                                  ,period_time_definition_id
                              FROM pay_time_definitions
                             WHERE time_definition_id = ' || p_time_definition_id;

      -- Cursor to get time_definition details
      OPEN c_get_timedef_detail FOR c_get_timedef_detail_sql;
      FETCH c_get_timedef_detail INTO lv_def_name,
                                      lv_period_type,
                                      ld_start_date,
                                      ld_pd_td_id;
      CLOSE c_get_timedef_detail;

      hr_utility.trace('p_time_definition_id :'|| p_time_definition_id);
      hr_utility.trace('p_definition_name :'|| p_definition_name);
      hr_utility.trace('p_period_type :'|| p_period_type);
      hr_utility.trace('p_start_date :'|| p_start_date);
      hr_utility.trace('p_period_time_definition_id :'|| p_period_time_definition_id);
      hr_utility.trace('lv_def_name :'|| lv_def_name);
      hr_utility.trace('lv_period_type :'|| lv_period_type);
      hr_utility.trace('ld_start_date :'|| ld_start_date);
      hr_utility.trace('ld_pd_td_id :'|| ld_pd_td_id);

      ln_is_error := 0;

      IF (p_definition_name IS NULL AND lv_def_name IS NULL) THEN
         NULL;
      ELSIF ((ln_is_error = 0) AND
             ((p_definition_name IS NULL AND lv_def_name IS NOT NULL) OR
              (p_definition_name IS NOT NULL AND lv_def_name IS NULL) OR
              (p_definition_name <> lv_def_name)
             )
            )THEN
           ln_is_error := 1;
      END IF;

      IF ((ln_is_error = 0) AND
          (p_period_type IS NULL) AND
          (lv_period_type IS NULL)
         ) THEN
         NULL;
      ELSIF ((ln_is_error = 0) AND
             ((p_period_type IS NULL AND lv_period_type IS NOT NULL) OR
              (p_period_type IS NOT NULL AND lv_period_type IS NULL) OR
              (p_period_type <> lv_period_type)
             )
            )THEN
           ln_is_error := 1;
      END IF;

      IF ((ln_is_error = 0) AND
          (p_start_date IS NULL) AND
          (ld_start_date IS NULL)
         ) THEN
         NULL;
      ELSIF ((ln_is_error = 0) AND
             ((p_start_date IS NULL AND ld_start_date IS NOT NULL) OR
              (p_start_date IS NOT NULL AND ld_start_date IS NULL) OR
              (p_start_date <> ld_start_date)
             )
            )THEN
           ln_is_error := 1;
      END IF;

      IF ((ln_is_error = 0) AND
          (p_period_time_definition_id IS NULL) AND
          (ld_pd_td_id IS NULL)
         )THEN
         NULL;
      ELSIF ((ln_is_error = 0) AND
             ((p_period_time_definition_id IS NULL AND ld_pd_td_id IS NOT NULL) OR
              (p_period_time_definition_id IS NOT NULL AND ld_pd_td_id IS NULL) OR
              (p_period_time_definition_id <> ld_pd_td_id)
             )
            )THEN
           ln_is_error := 1;
      END IF;

      IF (ln_is_error = 1) THEN
         hr_utility.set_message(801, 'PAY_US_INVALID_UPDATE');
         hr_utility.set_message_token(801,
                                      'ERROR_TEXT',
                                      'You are only allowed to increased the number '||
                                      'of years'
                                      );
         hr_utility.raise_error;
      END IF;


      hr_utility.TRACE ('Leaving STATUS_OTL_TIME_DEF');

      EXCEPTION WHEN TABLE_DOES_NOT_EXIST THEN
         hr_utility.TRACE ('Inside Exception TABLE_DOES_NOT_EXIST in '||
                           'hxc_us_time_definitions_hook.status_otl_time_def');
         hr_utility.set_message(801, 'PAY_US_MISSING_TABLES');
         hr_utility.set_message_token(801,
                                      'ERROR_TEXT',
                                      'Error while updating a row in pay_time_definitions'
                                      );
         hr_utility.set_message_token(801, 'TABLE_NAME', 'PAY_TIME_DEFINITIONS');
         hr_utility.raise_error;

   END status_otl_time_def;


/******************************************************************************
   Name        : INSERT_USER_HOOK_HIERARCHY
   Scope       : GLOBAL
   Description : This procedure is called by AFTER INSERT Row Level handler
                 User Hook of HXC_PREF_HIERARCHIES to insert a row in
                 pay_time_definitions if it does not already exist.
******************************************************************************/
   PROCEDURE insert_user_hook_hierarchy (
      p_business_group_id    IN   NUMBER,
      p_legislation_code     IN   VARCHAR2 DEFAULT NULL,
      p_attribute_category   IN   VARCHAR2 DEFAULT NULL,
      p_attribute1           IN   VARCHAR2 DEFAULT NULL,
      p_attribute2           IN   VARCHAR2 DEFAULT NULL,
      p_attribute3           IN   VARCHAR2 DEFAULT NULL
   ) IS
   BEGIN
      hr_utility.TRACE('Entering HXC_US_TIME_DEFINITIONS_HOOK.INSERT_USER_HOOK_HIERARCHY');

      IF ( p_attribute_category = 'TC_W_RULES_EVALUATION' AND
           p_attribute2 IS NOT NULL AND
           p_attribute3 IS NOT NULL
         ) THEN
         insert_time_def_hierarchy ( p_business_group_id => p_business_group_id
                                    ,p_attribute2        => p_attribute2
                                    ,p_attribute3        => p_attribute3
                                   );
      ELSE
         NULL;
      END IF;

      hr_utility.TRACE ('Leaving HXC_US_TIME_DEFINITIONS_HOOK.INSERT_USER_HOOK_HIERARCHY');
   END insert_user_hook_hierarchy;

------------------------INSERT_USER_HOOK_HIERARCHY ENDS HERE-------------------

/******************************************************************************
   Name        : UPDATE_USER_HOOK_HIERARCHY
   Scope       : GLOBAL
   Description : This procedure is called by AFTER UPDATE Row Level handler
                 User Hook of HXC_PREF_HIERARCHIES to insert a row in
                 pay_time_definitions if it does not already exist.
******************************************************************************/
   PROCEDURE update_user_hook_hierarchy (
      p_business_group_id    IN   NUMBER,
      p_legislation_code     IN   VARCHAR2 DEFAULT NULL,
      p_attribute_category   IN   VARCHAR2 DEFAULT NULL,
      p_attribute1           IN   VARCHAR2 DEFAULT NULL,
      p_attribute2           IN   VARCHAR2 DEFAULT NULL,
      p_attribute3           IN   VARCHAR2 DEFAULT NULL
   ) IS

   BEGIN
      hr_utility.TRACE('Entering HXC_US_TIME_DEFINITIONS_HOOK.UPDATE_USER_HOOK_HIERARCHY');

      IF ( p_attribute_category = 'TC_W_RULES_EVALUATION' AND
           p_attribute2 IS NOT NULL AND
           p_attribute3 IS NOT NULL
         ) THEN
         insert_time_def_hierarchy ( p_business_group_id => p_business_group_id
                                    ,p_attribute2        => p_attribute2
                                    ,p_attribute3        => p_attribute3
                                   );
      ELSE
         NULL;
      END IF;

      hr_utility.TRACE ('Leaving HXC_US_TIME_DEFINITIONS_HOOK.UPDATE_USER_HOOK_HIERARCHY');
   END update_user_hook_hierarchy;

-------------------------UPDATE_USER_HOOK_HIERARCHY ENDS HERE------------------

   /***************************************************************************
      Name        : UPDATE_USER_HOOK_RECURRING
      Scope       : GLOBAL
      Description : This procedure is called by AFTER UPDATE Row Level handler
                    User Hook of HXC_RECURRING_PERIODS_API.
   ******************************************************************************/
   PROCEDURE update_user_hook_recurring (
     p_recurring_period_id  IN NUMBER
    ,p_name                 IN VARCHAR2
  ) IS
   BEGIN
      hr_utility.TRACE('Entering HXC_US_TIME_DEFINITIONS_HOOK.UPDATE_USER_HOOK_RECURRING');

      g_from_otl := 'Y';
      update_time_def_recurring ( p_recurring_period_id => p_recurring_period_id
                                 ,p_name                => p_name
                                );

       hr_utility.TRACE ('Leaving HXC_US_TIME_DEFINITIONS_HOOK.UPDATE_USER_HOOK_RECURRING');
   END update_user_hook_recurring;

-----------------------UPDATE_USER_HOOK_RECURRING SECTION ENDS HERE------------

   /***************************************************************************
      Name        : UPDATE_USER_HOOK_TIMEDEF
      Scope       : GLOBAL
      Description : This procedure is called by Before Process
                    Business Process User Hook of PAY_TIME_DEFINITION_API.
   ******************************************************************************/
   PROCEDURE update_user_hook_timedef (
     p_time_definition_id         IN  NUMBER
    ,p_definition_name            IN  VARCHAR2
    ,p_period_type                IN  VARCHAR2
    ,p_start_date                 IN  DATE
    ,p_period_time_definition_id  IN  NUMBER
    ,p_creator_id                 IN  NUMBER
    ,p_creator_type               IN  VARCHAR2
   ) IS


      lv_rec_pd_exist        VARCHAR2(1);

      TYPE RefCurType is REF CURSOR;
      c_check_recurring      RefCurType;

      c_check_recurring_sql  VARCHAR2(10000);

   BEGIN
      hr_utility.TRACE('Entering HXC_US_TIME_DEFINITIONS_HOOK.UPDATE_USER_HOOK_TIMEDEF');

      IF g_from_otl IS NULL THEN
         g_from_otl := 'N';
      END IF;

      hr_utility.trace('g_from_otl :'|| g_from_otl);
      IF (g_from_otl = 'Y') THEN
          g_from_otl := 'N';
      ELSIF (p_creator_id IS NOT NULL AND
             p_creator_type = 'OTL_W') THEN
         BEGIN

            c_check_recurring_sql :=
                              'SELECT ''Y''
                                 FROM hxc_recurring_periods
                                WHERE recurring_period_id = ' || p_creator_id;

            -- Cursor to check whether a recurring period exist
            OPEN c_check_recurring FOR c_check_recurring_sql;
            FETCH c_check_recurring INTO lv_rec_pd_exist;

            IF (c_check_recurring%NOTFOUND) THEN
                   /*Call has not come for updation of a time_definition which
                     was created through OTL. Hence do nothing*/
                   NULL;
            ELSE
                     hr_utility.trace('p_time_definition_id :'|| p_time_definition_id);
                     hr_utility.trace('p_definition_name :'|| p_definition_name);
                     hr_utility.trace('p_period_type :'|| p_period_type);
                     hr_utility.trace('p_start_date :'|| p_start_date);
                     hr_utility.trace('p_period_time_definition_id :'|| p_period_time_definition_id);
                   /*Need to verify that leaving number_of_years nothing else
                     is getting updated*/
                   status_otl_time_def(
                       p_time_definition_id        =>  p_time_definition_id
                      ,p_definition_name           =>  p_definition_name
                      ,p_period_type               =>  p_period_type
                      ,p_start_date                =>  p_start_date
                      ,p_period_time_definition_id =>  p_period_time_definition_id
                      );
            END IF;
            CLOSE c_check_recurring;
         EXCEPTION WHEN TABLE_DOES_NOT_EXIST THEN
            hr_utility.TRACE ('Inside Exception TABLE_DOES_NOT_EXIST in '||
                              'hxc_us_time_definitions_hook.status_otl_time_def');
            hr_utility.set_message(801, 'PAY_US_MISSING_TABLES');
            hr_utility.set_message_token(801,
                                         'ERROR_TEXT',
                                         'Error while updating a row in pay_time_definitions'
                                         );
      	    hr_utility.set_message_token(801, 'TABLE_NAME', 'HXC_RECURRING_PERIODS');
            hr_utility.raise_error;
         END;
      END IF;
      hr_utility.TRACE ('Leaving HXC_US_TIME_DEFINITIONS_HOOK.UPDATE_USER_HOOK_TIMEDEF');
   END update_user_hook_timedef;

-----------------------------UPDATE_USER_HOOK_TIMEDEF ENDS HERE----------------

--BEGIN
--hr_utility.trace_on(NULL,'rd_hxcusottd');

END hxc_us_time_definitions_hook;

/
