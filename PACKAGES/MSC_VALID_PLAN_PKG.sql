--------------------------------------------------------
--  DDL for Package MSC_VALID_PLAN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_VALID_PLAN_PKG" AUTHID CURRENT_USER AS
/* $Header: MSCPVPDS.pls 120.0 2005/05/25 20:06:19 appldev noship $ */

PROCEDURE msc_valid_plan(
                            arg_plan_id         IN      NUMBER,
                            arg_exploder        IN      CHAR,
                            arg_snapshot        IN      CHAR,
                            arg_planner         IN      CHAR,
                            arg_crp_planner     IN      CHAR );

END msc_valid_plan_pkg;
 

/
