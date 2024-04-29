--------------------------------------------------------
--  DDL for Package PER_QP_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_QP_REPORTS" AUTHID CURRENT_USER as
/* $Header: ffqpr01t.pkh 115.0 99/07/16 02:03:22 porting ship $ */
/*===========================================================================+
 |               Copyright (c) 1993 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +===========================================================================+


Description
-----------
Package Header for procedures supporting FFXWSBQR - Define QP Report

History
-------
Date      Version  Description
----      -------  -----------
13-Apr-94 4.0      Created Initial Version
----------------------------------------------------------------------------*/
--
function get_formula_type return NUMBER;
function get_sequence_id return NUMBER;
procedure check_unique_name(p_qp_report_name varchar2
                           ,p_formula_type_id number
                           ,p_business_group_id number
                           ,p_legislation_code varchar2);
--
END PER_QP_REPORTS;

 

/
