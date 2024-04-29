--------------------------------------------------------
--  DDL for Package DDR_SETUP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DDR_SETUP_UTIL" AUTHID CURRENT_USER AS
/* $Header: ddrstpus.pls 120.1.12010000.3 2010/03/03 04:20:06 vbhave ship $ */

  PROCEDURE setup(p_mfg_org VARCHAR2);
  PROCEDURE setup_mfg_org(p_mfg_org VARCHAR2);
  PROCEDURE setup_lookup_type;
  PROCEDURE setup_lookup(p_mfg_org VARCHAR2);
  PROCEDURE setup_ws_metadata;

END ddr_setup_util;

/
