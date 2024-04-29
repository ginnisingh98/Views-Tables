--------------------------------------------------------
--  DDL for Package BIX_CALLS_HANDLED_BIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_CALLS_HANDLED_BIN_PKG" AUTHID CURRENT_USER AS
/*$Header: bixxbchs.pls 115.6 2003/01/10 00:14:50 achanda ship $*/

PROCEDURE populate(p_context IN VARCHAR2 DEFAULT NULL);

END BIX_CALLS_HANDLED_BIN_PKG;

 

/
