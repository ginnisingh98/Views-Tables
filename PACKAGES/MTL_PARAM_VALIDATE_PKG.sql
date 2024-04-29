--------------------------------------------------------
--  DDL for Package MTL_PARAM_VALIDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_PARAM_VALIDATE_PKG" AUTHID CURRENT_USER as
/* $Header: INVSDO2S.pls 115.1 2004/04/26 07:11:29 gbhagra ship $ */

  function master_has_items(curr_org_id in NUMBER,
		master_org_id in NUMBER)
	return integer;
  function org_has_children(org_id in number)
	return integer;
  function lot_control_validate(
		curr_lot_control in NUMBER,
		org_id in NUMBER)
	return integer;
  function serial_control_validate(
		curr_serial_control in NUMBER,
		org_id in NUMBER)
	return integer;

END MTL_PARAM_VALIDATE_PKG;

 

/
