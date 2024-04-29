--------------------------------------------------------
--  DDL for Package PA_REV_INTERFACE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_REV_INTERFACE_UTIL" AUTHID CURRENT_USER AS
/* $Header: PAXFRVUS.pls 115.1 99/07/16 15:24:19 porting shi $ */

  g_interface_unreleased_revenue   VARCHAR2(3);

  PROCEDURE set_xfc_unrel_rev_flag;

  FUNCTION allow_unreleased_rev
              ( released_date   IN DATE
              ) return VARCHAR2;

  PRAGMA RESTRICT_REFERENCES ( allow_unreleased_rev,WNPS, WNDS);

END PA_REV_INTERFACE_UTIL;

 

/
