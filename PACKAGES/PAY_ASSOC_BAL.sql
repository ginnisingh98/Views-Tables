--------------------------------------------------------
--  DDL for Package PAY_ASSOC_BAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_ASSOC_BAL" AUTHID CURRENT_USER as
/* $Header: pyascbal.pkh 120.0 2005/05/29 03:00:53 appldev noship $ */
--
/*
--
-- Copyright (c) Oracle Corporation 1991,1992,1993. All rights reserved
/*
PRODUCT
    Oracle*Payroll
--
NAME
    pyascbal.pkh  - procedures for associating STU balances with STU element
		    types.
--
MODIFED
27-OCT-94	HPARICHA	Created.

DESCRIPTION

This is a post install step to be run when the installation of startup
elements and balances has occurred.
Select installed balance and element type ids BY NAME; associate balances
with elements as approp.
*/
--
PROCEDURE	assoc_bal(	p_element_name	in varchar2,
				p_balance_name	in varchar2,
				p_association	in varchar2);
--
PROCEDURE	create_associated_balances;
--
END pay_assoc_bal;

 

/
