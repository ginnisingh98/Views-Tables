--------------------------------------------------------
--  DDL for Package IGI_EXP_AP_INV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_EXP_AP_INV_PKG" AUTHID CURRENT_USER as
-- $Header: igiexpes.pls 115.6 2002/09/11 14:40:00 mbarrett ship $
--
-- Bug 1347858
-- Variables to be used from triggers on AP_HOLDS_ALL table
--

	TYPE InvoiceTabType is table of number(15)
		index by binary_integer;
	TYPE PRTableType is table of varchar2(1)
		index by binary_integer;
	--
	l_TableRow		NUMBER(15) := 0;
	l_InvoiceIdTable	InvoiceTabType;
	l_UpdatedByTable	InvoiceTabType;

PROCEDURE Update_Row(   x_session               NUMBER,
                        x_third_party_id        NUMBER,
                        x_site_id               NUMBER,
                        x_dial_unit_id          NUMBER);

END IGI_EXP_AP_INV_PKG;

 

/
