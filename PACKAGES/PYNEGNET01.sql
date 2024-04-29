--------------------------------------------------------
--  DDL for Package PYNEGNET01
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PYNEGNET01" AUTHID CURRENT_USER as
/* $Header: pyusngn1.pkh 115.0 99/07/17 06:45:22 porting ship $*/
/*

 *  Copyright (C) 1989 Oracle Corporation UK Ltd. Richmond, England.  *

 Name        : pynegnet
 Description : Creates new objects for negative net processing.

 Change List
 -----------
  Date      Name         Vers    Bug No   Description
 +---------+------------+-------+--------+------------------------------------+
   14/03/98 M.Lisiceki     40.0             First created
 +---------+------------+-------+--------+------------------------------------+
*/
--
 ------------------------------------------------------------------------------
 -- NAME
 -- pynegnet01.build_new_objects
 --
 -- DESCRIPTION
 -- Builds new pbjects
 ------------------------------------------------------------------------------
--
 procedure build_new_objects;   --(p_bus_name VARCHAR2);
--
end pynegnet01;

 

/
