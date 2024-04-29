--------------------------------------------------------
--  DDL for Package MSC_CL_RPO_ODS_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_RPO_ODS_LOAD" AUTHID CURRENT_USER AS -- specification
/* $Header: MSCLRPOS.pls 120.1 2007/04/12 10:27:55 sbyerram noship $ */

 PROCEDURE LOAD_IRO_DEMAND;   -- Changes for Bug 5909379 Srp Additions
 PROCEDURE LOAD_ERO_DEMAND;   -- Changes for Bug 5935273 Srp Additions

END MSC_CL_RPO_ODS_LOAD;

/
