--------------------------------------------------------
--  DDL for Package MSC_CL_RPO_PRE_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_RPO_PRE_PROCESS" AUTHID CURRENT_USER AS
/* $Header: MSCRPOLS.pls 120.3 2008/01/26 09:33:31 abhikuma noship $*/
PROCEDURE  LOAD_IRO_SUPPLY;
PROCEDURE  LOAD_IRO_DEMAND;
PROCEDURE  LOAD_ERO_SUPPLY;
PROCEDURE  LOAD_ERO_DEMAND;
END MSC_CL_RPO_PRE_PROCESS;

/
