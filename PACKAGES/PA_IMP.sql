--------------------------------------------------------
--  DDL for Package PA_IMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_IMP" AUTHID CURRENT_USER AS
/* $Header: PAIMPS.pls 115.0 99/07/16 15:07:14 porting ship $ */
  FUNCTION pa_implemented RETURN BOOLEAN;
  FUNCTION pa_implemented_all RETURN BOOLEAN;
--
END pa_imp;

 

/
