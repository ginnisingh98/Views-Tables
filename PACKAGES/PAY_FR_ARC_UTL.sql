--------------------------------------------------------
--  DDL for Package PAY_FR_ARC_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FR_ARC_UTL" AUTHID CURRENT_USER as
/* $Header: pyfrarcu.pkh 120.0 2005/05/29 04:58:30 appldev noship $ */
--
---------------------------------------------------------------------------
-- Function: range_person_enh_enabled.
-- Description: Returns true if the range_person performance enhancement
--              3628032 is enabled for the system and specified archive.
---------------------------------------------------------------------------
FUNCTION range_person_enh_enabled(p_payroll_action_id number) RETURN BOOLEAN;
--
END pay_fr_arc_utl;

 

/
