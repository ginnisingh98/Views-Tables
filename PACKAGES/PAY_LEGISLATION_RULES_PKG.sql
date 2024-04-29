--------------------------------------------------------
--  DDL for Package PAY_LEGISLATION_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_LEGISLATION_RULES_PKG" AUTHID CURRENT_USER as
/* $Header: pylegrul.pkh 120.0.12010000.1 2008/07/27 23:08:23 appldev ship $*/
--
/*
 Copyright (c) Oracle Corporation 1993,1994,1995.  All rights reserved

/*

 Name          : pylegrul.pkh
 Description   : procedures required fofor check to pay_olegislation_rules
 Author        : T.Battoo
 Date Created  : 19-May-1999

 Change List
 -----------
 Date        Name           Vers     Bug No    Description
 +-----------+--------------+--------+---------+-----------------------+
 14-MAR-2001 T.Battoo        115.0              created
 21-DEC-2001 RThirlby        115.2              Added dbdrv lines
*/


 function check_leg_rule(rule_type varchar2) return boolean;
end;

/
