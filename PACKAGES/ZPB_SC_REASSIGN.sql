--------------------------------------------------------
--  DDL for Package ZPB_SC_REASSIGN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_SC_REASSIGN" AUTHID CURRENT_USER AS
/* $Header: zpbscreassign.pls 120.0.12010.2 2005/12/23 08:57:38 appldev noship $  */

MAX_LENGTH CONSTANT NUMBER := 1000;

PROCEDURE reassign_all_objects (
  p_owner_id           IN zpb_analysis_cycles.owner_id%TYPE,
  p_new_owner_id           IN zpb_analysis_cycles.owner_id%TYPE,
  p_business_area_id       IN zpb_analysis_cycles.business_area_id%TYPE);


PROCEDURE reassign_bus_proc_objs (
  p_owner_id               IN zpb_analysis_cycles.owner_id%TYPE,
  p_new_owner_id           IN zpb_analysis_cycles.owner_id%TYPE,
  p_business_area_id       IN zpb_analysis_cycles.business_area_id%TYPE);

FUNCTION get_active_business_procs (
  p_owner_id           IN zpb_analysis_cycles.owner_id%TYPE,
  p_business_area_id   IN zpb_analysis_cycles.business_area_id%TYPE)
  return varchar2;

FUNCTION get_worksheets (
  p_owner_id           IN zpb_analysis_cycles.owner_id%TYPE,
  p_business_area_id   IN zpb_analysis_cycles.business_area_id%TYPE)
  return varchar2;

PROCEDURE reassign_exception_objs (
  p_owner_id              IN zpb_analysis_cycles.owner_id%TYPE,
  p_new_owner_id              IN zpb_analysis_cycles.owner_id%TYPE,
  p_business_area_id          IN zpb_analysis_cycles.business_area_id%TYPE);

END ZPB_SC_REASSIGN;

 

/
