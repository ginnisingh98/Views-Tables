--------------------------------------------------------
--  DDL for Package Body CS_SR_SECURITY_CONTEXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_SECURITY_CONTEXT" as
/* $Header: cssrsecb.pls 115.1 2003/09/01 07:52:04 vmuruges noship $*/
PROCEDURE Set_SR_Security_Context (
	p_context_attribute  in VARCHAR2,
	p_context_attribute_value in NUMBER )
IS
BEGIN
	DBMS_SESSION.SET_CONTEXT('CS_SR_SECURITY',p_context_attribute,p_context_attribute_value);
END Set_SR_Security_Context;


end CS_SR_SECURITY_CONTEXT;

/
