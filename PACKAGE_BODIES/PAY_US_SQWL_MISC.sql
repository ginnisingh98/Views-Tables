--------------------------------------------------------
--  DDL for Package Body PAY_US_SQWL_MISC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_SQWL_MISC" AS
/* $Header: pyussqmn.pkb 115.0 2002/03/16 08:21:56 pkm ship        $ */
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

    Name        : pay_us_sqwl_misc

    Description :

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  --------------------------
    14-MAR-2002 asasthan    115.0  735180   Created.
*/


  FUNCTION get_old_month3_count(
                p_asact_ctx_id      in number
                 )
  RETURN VARCHAR2
  IS

  ln_user_entity_id   number;
  lv_value     varchar2(80) := '0';


  cursor c_old_month3(p_asact_ctx_id in number) is
  select value
    from ff_archive_items fai,
         ff_user_entities fue
   where context1 = p_asact_ctx_id
     and fue.user_entity_id = fai.user_entity_id
     and fue.user_entity_name = 'A_SIT_GROSS_PER_JD_GRE_MON_3';


  BEGIN
      hr_utility.trace('opened  c_old_month3 for month 3');

      open c_old_month3(p_asact_ctx_id);

      fetch c_old_month3 into lv_value;

      IF c_old_month3%NOTFOUND THEN
           close  c_old_month3;
           RETURN  '0';
      END IF;

      close  c_old_month3;

      return (lv_value);

  END get_old_month3_count;



  FUNCTION get_old_month2_count(
                p_asact_ctx_id      in number
                 )
  RETURN VARCHAR2
  IS

  ln_user_entity_id   number;
  lv_value     varchar2(80) := '0';


  cursor c_old_month2(p_asact_ctx_id in number) is
  select value
    from ff_archive_items fai,
         ff_user_entities fue
   where context1 = p_asact_ctx_id
     and fue.user_entity_id = fai.user_entity_id
     and fue.user_entity_name = 'A_SIT_GROSS_PER_JD_GRE_MON_2';


  BEGIN
      hr_utility.trace('opened  c_old_month2 for month 2');

      open c_old_month2(p_asact_ctx_id);

      fetch c_old_month2 into lv_value;

      IF c_old_month2%NOTFOUND THEN
           close  c_old_month2;
           RETURN  '0';
      END IF;

      close  c_old_month2;

      return (lv_value);

  END get_old_month2_count;



  FUNCTION get_old_month1_count(
                p_asact_ctx_id      in number
                 )
  RETURN VARCHAR2
  IS

  ln_user_entity_id   number;
  lv_value     varchar2(80) := '0';


  cursor c_old_month1(p_asact_ctx_id in number) is
  select value
    from ff_archive_items fai,
         ff_user_entities fue
   where context1 = p_asact_ctx_id
     and fue.user_entity_id = fai.user_entity_id
     and fue.user_entity_name = 'A_SIT_GROSS_PER_JD_GRE_MON_1';


  BEGIN
      hr_utility.trace('opened  c_old_month1 for month 1');

      open c_old_month1(p_asact_ctx_id);

      fetch c_old_month1 into lv_value;

      IF c_old_month1%NOTFOUND THEN
           close  c_old_month1;
           RETURN  '0';
      END IF;

      close  c_old_month1;

      return (lv_value);

  END get_old_month1_count;

END pay_us_sqwl_misc;

/
