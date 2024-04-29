--------------------------------------------------------
--  DDL for Package CS_SR_SECURITY_CONTEXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_SECURITY_CONTEXT" AUTHID CURRENT_USER AS
/* $Header: cssrsecs.pls 115.0 2003/08/19 12:03:33 anmukher noship $*/


PROCEDURE Set_SR_Security_Context (P_context_attribute       IN    VARCHAR2,
                                   P_context_attribute_value IN    NUMBER ) ;

END CS_SR_SECURITY_CONTEXT;

 

/
