--------------------------------------------------------
--  DDL for Package PAY_EOSY_AC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_EOSY_AC_PKG" AUTHID CURRENT_USER AS
/* $Header: pyuseoac.pkh 120.1.12000000.1 2007/01/18 02:24:31 appldev noship $ */
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
   *  ma    for EO Survey report.
   *  26-Apr-2001  fusman      115.0

   Name:    This package defines the cursors needed to run
            Payroll Register Multi-Threaded
 Change List
   -----------
   Date         Name        Vers   Description
   -----------  ----------  -----  -----------------------------------
   28-Jun-2004  vbanner     115.1  GSCC changes, dbdrv etc.
   02-Sep-2005  ynegoro     115.2  GSCC changes, nocopy hint
*/

 --------------------------- range_cursor ---------------------------------
 PROCEDURE range_cursor (pactid in number,
                         sqlstr out nocopy varchar2);

 ----------------------------- action_creation --------------------------------
 PROCEDURE action_creation( pactid    in number,
                            stperson  in number,
                            endperson in number,
                            chunk     in number);
 PROCEDURE sort_action(
               payactid   in     varchar2, /* payroll action id */
               sqlstr     in out nocopy varchar2, /* string holding the sql statement */
               len        out nocopy    number    /* length of the sql string */
               );

  FUNCTION get_parameter(name in varchar2,
                          parameter_list varchar2)
                          return varchar2;
pragma restrict_references(get_parameter, WNDS, WNPS);

 end pay_eosy_ac_pkg;

 

/
