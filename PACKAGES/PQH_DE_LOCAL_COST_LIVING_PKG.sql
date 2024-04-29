--------------------------------------------------------
--  DDL for Package PQH_DE_LOCAL_COST_LIVING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_DE_LOCAL_COST_LIVING_PKG" AUTHID CURRENT_USER as
/* $Header: pqhdeloc.pkh 115.0 2002/03/26 04:25:37 pkm ship        $ */
--
/*
+==============================================================================+
|                        Copyright (c) 1997 Oracle Corporation                 |
|                           Redwood Shores, California, USA                    |
|                               All rights reserved.                           |
+==============================================================================+
--
Name
	Local Cost of living  Package
Purpose
        This package is used to calculate the local cost of living.
History
  Version    Date       Who        What?
  ---------  ---------  ---------- --------------------------------------------
  115.0      17-Mar-02  nsinghal     Created
*/
--
 Function LOCAL_COST_OF_LIVING
( p_effective_date                          in      date
  ,p_business_group_id                      in      number
  ,p_ASSIGNMENT_ID                          in      number
  ,p_pay_grade                              in      varchar2
  ,p_Tariff_contract                        in      varchar2
  ,p_tariff_group                           in      varchar2
 )  Return number;
--
--
end PQH_DE_LOCAL_COST_LIVING_PKG;

 

/
