--------------------------------------------------------
--  DDL for Package Body POS_SECURITY_PROFILE_UTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_SECURITY_PROFILE_UTL_PKG" AS
/*$Header: POSSPUTB.pls 120.4.12010000.2 2009/03/11 09:11:30 vchiranj ship $ */

PROCEDURE get_current_ous
  (x_ou_ids OUT nocopy number_table,
   x_count  OUT nocopy NUMBER
   )
  IS
     -- Bug 8257278. Modified the cursor to fetch only active Operating Units.
     CURSOR l_cur IS
        SELECT organization_id
          FROM hr_operating_units
          WHERE mo_global.check_access(organization_id) = 'Y'
          AND Nvl(DATE_TO,SYSDATE) >= SYSDATE;

     -- note: we are not checking financial options, payable options, purchasing options here.
     -- need to think about whether we should

     l_numbers  number_table;
     l_index    NUMBER;
BEGIN
   l_index := 0;
   FOR l_rec IN l_cur LOOP
      l_index := l_index + 1;
      l_numbers(l_index) := l_rec.organization_id;
   END LOOP;

   x_ou_ids := l_numbers;
   x_count := l_index;

END get_current_ous;

END pos_security_profile_utl_pkg;

/
