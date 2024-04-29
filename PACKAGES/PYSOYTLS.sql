--------------------------------------------------------
--  DDL for Package PYSOYTLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PYSOYTLS" AUTHID CURRENT_USER as
/* $Header: pysoytls.pkh 115.1 99/07/17 06:33:02 porting ship  $

 Copyright (c) Oracle Corporation 1995. All rights reserved

 Name          : pysoytls
 Description   : Start Of Year Tools Functions
 Author        : Barry Goodsell
 Date Created  : 15-Aug-95

 Change List
 -----------
 Date        Name            Vers     Bug No   Description
 +-----------+---------------+--------+--------+-----------------------+
  15-Aug-95   B.Goodsell      40.0              First Created

  09-Oct-95   B.Goodsell      40.1		Edits required for
						release
 +-----------+---------------+--------+--------+-----------------------+
*/
--
function trim       (p_string   varchar2) return varchar2;
pragma restrict_references (trim,       WNDS, WNPS);
--
function tax_prefix (p_tax_code varchar2) return varchar2;
pragma restrict_references (tax_prefix, WNDS, WNPS);
--
function tax_value  (p_tax_code varchar2) return number;
pragma restrict_references (tax_value,  WNDS, WNPS);
--
function tax_suffix (p_tax_code varchar2) return varchar2;
pragma restrict_references (tax_suffix, WNDS, WNPS);
--
end pysoytls;

 

/
