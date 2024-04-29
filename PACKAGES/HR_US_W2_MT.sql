--------------------------------------------------------
--  DDL for Package HR_US_W2_MT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_US_W2_MT" AUTHID CURRENT_USER AS
/* $Header: pyusw2mt.pkh 120.0.12010000.1 2008/07/27 23:59:33 appldev ship $ */

/*
 +=====================================================================+
 |              Copyright (c) 1997 Orcale Corporation                  |
 |                 Redwood Shores, California, USA                     |
 |                      All rights reserved.                           |
 +=====================================================================+
Name        : pyusw2mt.pkh
Description : This package declares functions and procedures which are
              used to return values for the W2 US Payroll reports.

Change List
-----------

Version Date      Author          ER/CR No. Description of Change
-------+---------+---------------+---------+--------------------------
40.0              AAsthana                  Created for Multi-threaded report.
115.1             meshah                    set verify off;
115.2             meshah                    dbdrv
115.3             meshah                    dbdrv, checkfile syntax
*/
procedure range_cursor ( pactid in  number,
                         sqlstr out nocopy varchar2
                       );
procedure action_creation ( pactid in number,
                            stperson in number,
                            endperson in number,
                            chunk in number
                          );
procedure sort_action ( payactid   in     varchar2,
                        sqlstr     in out nocopy varchar2,
                        len        out   nocopy number
                      );
function get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2;
pragma restrict_references(get_parameter, WNDS, WNPS);
--
end hr_us_w2_mt;

/
