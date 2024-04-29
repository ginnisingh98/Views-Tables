--------------------------------------------------------
--  DDL for Package PAY_NEGBAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NEGBAL_PKG" AUTHID CURRENT_USER as
/* $Header: pynegbal.pkh 115.4 2003/02/14 11:00:57 alogue ship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1999 Oracle Corporation UK Ltd.,                *
   *                   Reading,  England.                           *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   ******************************************************************

   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   28-JUL-1999  P.Davies    40.0            Created.
   05-DEC-2002  N.Bristow   115.2           Made nocopy changes.
   06-FEB-2003  D.Saxby     115.3           GSCC error fixes.
   14-FEB-2003  A.Logue     115.4           Move dbdrv lines.
--
*/
procedure range_cursor ( pactid in         number,
                         sqlstr out nocopy varchar2
                       );
procedure action_creation ( pactid in number,
                            stperson in number,
                            endperson in number,
                            chunk in number
                          );
procedure sort_action ( payactid   in            varchar2,
                        sqlstr     in out nocopy varchar2,
                        len        out    nocopy number
                      );

FUNCTION check_residence_state (
        p_assignment_id NUMBER,
        p_period_start  DATE,
        p_period_end    DATE,
        p_state         VARCHAR2,
        p_effective_end_date DATE
 ) RETURN BOOLEAN;

function get_parameter(name in varchar2,
                       parameter_list varchar2) return varchar2;
pragma restrict_references(get_parameter, WNDS, WNPS);
--
end pay_negbal_pkg;

 

/
