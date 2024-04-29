--------------------------------------------------------
--  DDL for Package PAY_US_ELEM_ENT_CHK_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_ELEM_ENT_CHK_LEG_HOOK" AUTHID CURRENT_USER AS
/* $Header: pyuschee.pkh 120.0 2005/05/29 09:19:24 appldev noship $ */

/*******************************************************************************
    Name    : CHK_ELEM_ENTRY
    Purpose : This procedure is used to make sure that in the element entry
              screen Involuntary deduction elements of same architecture are
              entered. Element of two different architectures are not allowed.

*******************************************************************************/

PROCEDURE CHK_ELEM_ENTRY(
    p_assignment_id number,
    p_effective_start_date date,
    p_element_link_id number
    );

END PAY_US_ELEM_ENT_CHK_LEG_HOOK;

 

/
