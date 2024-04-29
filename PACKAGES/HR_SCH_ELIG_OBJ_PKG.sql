--------------------------------------------------------
--  DDL for Package HR_SCH_ELIG_OBJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SCH_ELIG_OBJ_PKG" AUTHID CURRENT_USER AS
  -- $Header: peschobj.pkh 120.0 2005/05/31 20:44:45 appldev noship $

  --
  -----------------------------------------------------------------------------
  ---------------------------< create_sch_elig_obj >---------------------------
  -----------------------------------------------------------------------------
  --
  -- This procedure is invoked from the ATG Schedule Repository Schedule
  -- creation business event subscription.
  -- Event Name = oracle.apps.jtf.cac.scheduleRep.createSchedule
  --
  FUNCTION create_sch_elig_obj(p_subscription_guid IN RAW
                              ,p_event             IN OUT NOCOPY wf_event_t
                              ) RETURN VARCHAR2;

  --
  -----------------------------------------------------------------------------
  ---------------------------< delete_sch_elig_obj >---------------------------
  -----------------------------------------------------------------------------
  --
  -- This procedure is invoked from the ATG Schedule Repository Schedule
  -- deletion business event subscription.
  -- Event Name = oracle.apps.jtf.cac.scheduleRep.deleteSchedule
  --
  FUNCTION delete_sch_elig_obj(p_subscription_guid IN RAW
                              ,p_event             IN OUT NOCOPY wf_event_t
                              ) RETURN VARCHAR2;

END hr_sch_elig_obj_pkg;

 

/
