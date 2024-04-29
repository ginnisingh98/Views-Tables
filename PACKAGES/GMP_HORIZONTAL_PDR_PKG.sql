--------------------------------------------------------
--  DDL for Package GMP_HORIZONTAL_PDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMP_HORIZONTAL_PDR_PKG" AUTHID CURRENT_USER AS
/* $Header: GMPHPDRS.pls 120.1.12010000.4 2010/02/11 09:46:29 vpedarla ship $ */

PROCEDURE populate_horizontal_plan (
   p_inst_id                    NUMBER,
   p_org_id                     NUMBER,
   p_plan_id                    NUMBER,
   p_day_bckt_cutoff_dt         DATE,
   p_week_bckt_cutoff_dt        DATE,
   p_period_bucket              NUMBER,
   p_incl_items_no_activity     NUMBER --  Bug: 8486531 Vpedarla
);

PROCEDURE gmp_debug_message(pBUFF IN VARCHAR2);  -- Bug: 9366921 Vpedarla

END GMP_HORIZONTAL_PDR_PKG;

/
