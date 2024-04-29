--------------------------------------------------------
--  DDL for Package PAY_BACKPAY_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_BACKPAY_SETS_PKG" AUTHID CURRENT_USER AS
/* $Header: pybks01t.pkh 115.0 99/07/17 05:45:52 porting ship $ */
-----------------------------------------------------------------------------
--
procedure check_name_uniqueness(
	p_bus_grp_id	number,
	p_set_name	varchar2,
	p_set_id	number);
--
END PAY_BACKPAY_SETS_PKG;

 

/
