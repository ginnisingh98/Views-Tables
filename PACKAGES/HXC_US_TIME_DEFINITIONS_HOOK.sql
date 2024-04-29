--------------------------------------------------------
--  DDL for Package HXC_US_TIME_DEFINITIONS_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HXC_US_TIME_DEFINITIONS_HOOK" AUTHID CURRENT_USER AS
/* $Header: hxcusottd.pkh 120.1 2006/09/20 17:48:35 asasthan noship $ */
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
    File Name   : hxcusottd.pkh

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
    rdhingra       25-Jan-2006   115.1   FLSA     Updated dbdrv: checkfile to
                                                  refer to correct sql
    rdhingra       25-Jan-2006   115.2   FLSA     Changing dbdrv lines as per
                                                  the recommendations of the
                                                  release team

    asasthan       20-Sep-2006   115.3   FLSA     Changed associated filename


******************************************************************************/
/*Global Variables*/
g_from_otl VARCHAR2(1);

/******************************************************************************
   Name           : INSERT_USER_HOOK_HIERARCHY (After Update User Hook Call)
   User Hook Type : This is an AFTER INSERT Row Level handler User Hook
                    and is called from user hook provided in
                    HXC_PREF_HIERARCHIES_API.
   Description    : This USER HOOK will only be called from OTL to insert a
                    row in pay_time_definitions
******************************************************************************/
PROCEDURE INSERT_USER_HOOK_HIERARCHY(
       p_business_group_id    IN   NUMBER
      ,p_legislation_code     IN   VARCHAR2 DEFAULT NULL
      ,p_attribute_category   IN   VARCHAR2 DEFAULT NULL
      ,p_attribute1           IN   VARCHAR2 DEFAULT NULL
      ,p_attribute2           IN   VARCHAR2 DEFAULT NULL
      ,p_attribute3           IN   VARCHAR2 DEFAULT NULL
      );

/******************************************************************************
   Name           : UPDATE_USER_HOOK_HIERARCHY (After Update User Hook Call)
   User Hook Type : This is an AFTER UPDATE Row Level handler User Hook and is
                    called from user hook provided in
                    HXC_PREF_HIERARCHIES_API.
   Description    : This USER HOOK will only be called from OTL to insert a
                    row in pay_time_definitions
******************************************************************************/
PROCEDURE UPDATE_USER_HOOK_HIERARCHY(
       p_business_group_id    IN   NUMBER
      ,p_legislation_code     IN   VARCHAR2 DEFAULT NULL
      ,p_attribute_category   IN   VARCHAR2 DEFAULT NULL
      ,p_attribute1           IN   VARCHAR2 DEFAULT NULL
      ,p_attribute2           IN   VARCHAR2 DEFAULT NULL
      ,p_attribute3           IN   VARCHAR2 DEFAULT NULL
      );

/******************************************************************************
   Name           : UPDATE_USER_HOOK_RECURRING (After Update User Hook Call)
   User Hook Type : This is an AFTER UPDATE Row Level handler User Hook and is
                    called from user hook provided in
                    HXC_RECURRING_PERIODS_API.
   Description    : This USER HOOK will only be called from OTL to update
                    the name in pay_time_definitions
******************************************************************************/
PROCEDURE UPDATE_USER_HOOK_RECURRING(
     p_recurring_period_id  IN NUMBER
    ,p_name                 IN VARCHAR2
    );

/******************************************************************************
   Name           : UPDATE_USER_HOOK_TIMEDEF (Before Process User Hook Call)
   User Hook Type : This is an Before Process Business Process User Hook and is
                    called from user hook provided in
                    PAY_TIME_DEFINITION_API.
   Description    : This USER HOOK will be called from when a row is getting
                    updated in pay_time_definitions
******************************************************************************/
PROCEDURE UPDATE_USER_HOOK_TIMEDEF(
     p_time_definition_id         IN  NUMBER
    ,p_definition_name            IN  VARCHAR2
    ,p_period_type                IN  VARCHAR2
    ,p_start_date                 IN  DATE
    ,p_period_time_definition_id  IN  NUMBER
    ,p_creator_id                 IN  NUMBER
    ,p_creator_type               IN  VARCHAR2
    );


END HXC_US_TIME_DEFINITIONS_HOOK;

 

/
