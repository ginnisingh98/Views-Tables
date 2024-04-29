--------------------------------------------------------
--  DDL for Package ZX_TCM_COMPOUND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TCM_COMPOUND_PKG" AUTHID CURRENT_USER AS
/* $Header: zxtaxgroupmigs.pls 120.0.12010000.2 2008/11/12 12:51:27 spasala ship $ */

Procedure  LOAD_TAX_RELATIONS;
Procedure  LOAD_REGIME_LIST;
Procedure  LOAD_TAX_LIST;
Procedure  SET_PRECEDENCES;
Procedure  MAIN;
END ZX_TCM_COMPOUND_PKG;

/
