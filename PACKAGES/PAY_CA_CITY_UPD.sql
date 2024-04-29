--------------------------------------------------------
--  DDL for Package PAY_CA_CITY_UPD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_CITY_UPD" AUTHID CURRENT_USER AS
/* $Header: pycactup.pkh 115.2 2003/03/12 19:12:48 ssouresr noship $ */
--
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1996 Oracle Corporation.                        *
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

    Name        : pay_ca_city_upd

    Description : Package that is used to update Canadian city names
                  to their correct French Canadian spelling.

    Change List
    -----------
     Date        Name      Vers    Bug No    Description
     ----        ----      ------  -------   -----------
    23-DEC-02    ssouresr  115.0   2428688   Created.
    15-JAN-03    ssouresr  115.1             Modified to make compatible
                                             with Oracle 8i
    11-MAR-03    ssouresr  115.2             Added primary_flag_list to remove
                                             duplicates from pay_us_city_names
*/

TYPE prov_list          IS TABLE OF pay_us_counties.county_abbrev%type INDEX BY BINARY_INTEGER;
TYPE county_code_list   IS TABLE OF pay_ca_display_cities.county_code%type INDEX BY BINARY_INTEGER;
TYPE city_code_list     IS TABLE OF pay_ca_display_cities.city_code%type INDEX BY BINARY_INTEGER;
TYPE old_city_name_list IS TABLE OF pay_ca_display_cities.city_name%type INDEX BY BINARY_INTEGER;
TYPE new_city_name_list IS TABLE OF pay_ca_display_cities.display_city_name%type INDEX BY BINARY_INTEGER;
TYPE primary_flag_list  IS TABLE OF pay_us_city_names.primary_flag%type INDEX BY BINARY_INTEGER;

FUNCTION  get_derived_locale(p_town_or_city   in  varchar2,
                             p_country        in  varchar2)
RETURN varchar2;

PROCEDURE cityname_bulk_upd (errbuf     out nocopy varchar2,
                             retcode    out nocopy number);

END pay_ca_city_upd;

 

/
