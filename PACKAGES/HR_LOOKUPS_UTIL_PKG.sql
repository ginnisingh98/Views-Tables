--------------------------------------------------------
--  DDL for Package HR_LOOKUPS_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_LOOKUPS_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: hrlkutil.pkh 115.0 2002/05/29 09:31:48 pkm ship        $ */
/*
 ******************************************************************
 *                                                                *
 *  Copyright (C) 2002 Oracle Corporation UK Ltd.,                *
 *                   Reading, England.                            *
 *                                                                *
 *  All rights reserved.                                          *
 *                                                                *
 *                                                                *
 ****************************************************************** */
/*

 Name        : hr_lookups_util_pkg

 Description : Contains packages that allows quick retreival of
               data that is created in PAY_LEGISLATIVE_FIELD_INFO
               to map local lookups to Global Lookups.

               Format of the mapping in this table is as follows:

 RULE_TYPE    LEG_CODE VALIDATION_TYPE VALIDATION_NAME FIELD_NAME
 -----------  -------- --------------- --------------- ----------
 LOCAL_LOOKUP DE       TITLE           DR              DR_DR
 LOCAL_LOOKUP DE       MAR_STATUS      SP              EX
 LOCAL_LOOKUP UK       TITLE           DR              DOCTOR

 Change List
 -----------

 Version Date      Author     Bug No.   Description of Change
 -------+---------+----------+---------+--------------------------

 115.0   22-apr-02 IHarding             Created
 ================================================================= */
--
-- ----------------------- get_legislative_lookup_code ------------
--
-- This routine returns a legislative lookup code based on the inputs
-- of legislation code, lookup type and the global lookup code for
-- which you wish to find the localized equivalent.
--
-- If there does not exists a localized equivalent, the global lookup
-- is returned.
--
-- In the above example, parameters of DE, TITLE and DR would result
-- in the value DR_DR returning.
--
-- Input parameters of UK, TITLE and MR would result in MR being
-- returned. And so on.
--
FUNCTION get_legislative_lookup_code (p_lookup_type       VARCHAR2
                                     ,p_lookup_code       VARCHAR2
                                     ,p_legislation_code  VARCHAR2)
return varchar2;
--
-- ----------------------- get_global_lookup_code ------------------
--
-- This routine does the opposite of get_legislative_lookup_code.
--
-- Based on legislation_code, lookup_type and a localized
-- lookup_code, the corresponding global code is returned. If there
-- is no global code, then the assumption is made that the supplied
-- localized code is in fact a global value.
--
-- In the above example, parameters of DE, TITLE and DR_DR would
-- result in the value DR returning.
--
-- Input parameters of UK, TITLE and MR would result in MR being
-- returned.
--
FUNCTION  get_global_lookup_code (p_lookup_type       VARCHAR2
                                      ,p_lookup_code       VARCHAR2
                                      ,p_legislation_code  VARCHAR2)
return varchar2;
--
--
------------------------  swap_legislative_lookup_code ---------------
--
-- This routine takes a legislative code and swaps it for the equivalent
-- code in a different legislation. This could be used when moving records
-- between business groups and the data contains one field that has a
-- localized lookup in the source business group as well as the target
-- business group.
--
-- In the above example, passing in a source legislation of DE, a target
-- legislation of UK, a lookup_type of TITLE and a lookup_code of DR_DR
-- would result in the value 'DOCTOR' being returned.
--
-- The function just basically calls the above two functions in order,
-- first transforming the DE lookup to global and then finding out the
-- UK equivalent of the global lookup.
--
FUNCTION  swap_legislative_lookup_code(p_lookup_type           VARCHAR2
                                      ,p_lookup_code           VARCHAR2
                                      ,p_source_leg_code       VARCHAR2
                                      ,p_target_leg_code       VARCHAR2)
return varchar2;
--
--
END hr_lookups_util_pkg;

 

/
