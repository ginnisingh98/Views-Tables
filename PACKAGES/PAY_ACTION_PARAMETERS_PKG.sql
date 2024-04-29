--------------------------------------------------------
--  DDL for Package PAY_ACTION_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ACTION_PARAMETERS_PKG" AUTHID CURRENT_USER as
/* $Header: pyactpar.pkh 120.0.12000000.1 2007/01/17 15:14:41 appldev noship $*/
--
/*
 Copyright (c) Oracle Corporation 1993,1994,1995.  All rights reserved

/*

 Name          : pyactpar.pkb
 Description   : procedures required fofor check to pay_olegislation_rules
 Author        : N.Bristow
 Date Created  : 20-NOV-2003

 Change List
 -----------
 Date        Name           Vers     Bug No    Description
 +-----------+--------------+--------+---------+-----------------------+
 24-JUL-2004  n.Bristow      115.1              Changed dbdrv statements.
 24-JUL-2004  N.Bristow      115.0              Created.
*/

function check_act_param(parameter_name varchar2) return boolean;
end;

 

/
