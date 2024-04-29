--------------------------------------------------------
--  DDL for Package PER_IE_VEHICLE_ALLOC_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_IE_VEHICLE_ALLOC_RULES" AUTHID CURRENT_USER AS
/* $Header: peievehd.pkh 120.0.12000000.1 2007/01/21 23:24:10 appldev ship $ */

PROCEDURE element_end_date_update (
  p_vehicle_allocation_id   IN  NUMBER,
  p_effective_date          IN  DATE);

END per_ie_vehicle_alloc_rules;


 

/
