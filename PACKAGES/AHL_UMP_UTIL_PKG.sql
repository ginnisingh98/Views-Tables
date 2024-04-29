--------------------------------------------------------
--  DDL for Package AHL_UMP_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UMP_UTIL_PKG" AUTHID CURRENT_USER AS
/* $Header: AHLUUMPS.pls 120.1 2008/02/11 00:26:56 sracha ship $ */

--Constants used in UMP methods
G_PC_PRIMARY_FLAG       CONSTANT VARCHAR2(1) := 'P';
G_PC_SECONDARY_FLAG     CONSTANT VARCHAR2(1) := 'S';
G_PC_DRAFT_STATUS       CONSTANT VARCHAR2(30) := 'DRAFT';
G_PC_COMPLETE_STATUS    CONSTANT VARCHAR2(30) := 'COMPLETE';
G_PC_ITEM_ASSOCIATION   CONSTANT VARCHAR2(1)  := 'P';
G_PC_UNIT_ASSOCIATION   CONSTANT VARCHAR2(1)  := 'U';

-----------------------------------------------------------
-- Function to get unit configuration name for a given   --
-- item instance.                                        --
-----------------------------------------------------------
FUNCTION get_unitName (p_csi_item_instance_id  IN  NUMBER)
RETURN VARCHAR2;

pragma restrict_references (get_unitName, WNDS,WNPS, RNPS);




-------------------------------------------------------
-- Function to get the children count for a group MR --
-------------------------------------------------------
FUNCTION GetCount_childUE(p_ue_id IN NUMBER)
RETURN NUMBER;

pragma restrict_references (GetCount_childUE, WNDS,WNPS, RNPS);




------------------------------------------------------------------------
-- Procedure to get the last accomplishment of an MR for any given item
-- instance. --
-------------------------------------------------------------------------
PROCEDURE get_last_accomplishment (p_csi_item_instance_id IN         NUMBER,
                                   p_mr_header_id         IN         NUMBER,
                                   x_accomplishment_date  OUT NOCOPY DATE,
                                   x_unit_effectivity_id  OUT NOCOPY NUMBER,
                                   x_deferral_flag        OUT NOCOPY BOOLEAN,
                                   x_status_code          OUT NOCOPY VARCHAR2,
                                   x_return_val           OUT NOCOPY BOOLEAN);



-----------------------------------------------------------
-- Procedure to get Visit details for a unit effectivity --
-----------------------------------------------------------
PROCEDURE get_Visit_Details ( p_unit_effectivity_id  IN         NUMBER,
                              x_visit_Start_date     OUT NOCOPY DATE,
                              x_visit_End_date       OUT NOCOPY DATE,
                              x_visit_Assign_code    OUT NOCOPY VARCHAR2);


-------------------------------------------------------------------------------
-- Function to get the visit status - planning/released/closed/              --
-------------------------------------------------------------------------------
FUNCTION get_Visit_Status ( p_unit_effectivity_id  IN  NUMBER)

RETURN VARCHAR2;


-----------------------------------------------------------------------------
-- Procedure to check if an Unit Effectivity is in execution
-- Uses the get_Visit_Status procedure given above
-----------------------------------------------------------------------------
FUNCTION Is_UE_In_Execution (
  p_ue_id   NUMBER)
RETURN boolean;


---------------------------------------------------------------------
-- Procedure to get Service Request details for a unit effectivity --
-- Used in Preventive Maintenance mode only                        --
---------------------------------------------------------------------
PROCEDURE get_ServiceRequest_Details (p_unit_effectivity_id IN         NUMBER,
                                      x_incident_id         OUT NOCOPY NUMBER,
                                      x_incident_number     OUT NOCOPY VARCHAR2,
                                      x_scheduled_date      OUT NOCOPY DATE);


-----------------------------------------------------------
-- Procedure to populate the AHL_APPLICABLE_MRS temporary --
-- table with the results of AHL_FMP_PUB.GET_APPLICABLE_MRS--
-- API.
-----------------------------------------------------------
PROCEDURE Populate_Appl_MRs (
    p_csi_ii_id           IN            NUMBER,
    p_include_doNotImplmt IN            VARCHAR2 := 'Y',
    x_return_status       OUT  NOCOPY   VARCHAR2,
    x_msg_count           OUT  NOCOPY   NUMBER,
    x_msg_data            OUT  NOCOPY   VARCHAR2 ) ;


-----------------------------------------------------------
-- Procedure to construct all applicable mr relns based  --
-- on values in AHL_APPLICABLE_MRS table.                --
-----------------------------------------------------------
PROCEDURE Process_Group_MRs;

-----------------------------------------------------------
-- Procedure to construct for one mr + item instance     --
-- combination, the set of descendent mr + item instances--
-----------------------------------------------------------
PROCEDURE Process_Group_MR_Instance (
    p_top_mr_id                IN            NUMBER,
    p_top_item_instance_id     IN            NUMBER,
    p_init_temp_table          IN            VARCHAR2  DEFAULT 'N') ;


------------------------------------------------------------------------
-- Procedure to get the first accomplishment of an MR for any given item
-- instance. --
-------------------------------------------------------------------------
PROCEDURE get_first_accomplishment (p_csi_item_instance_id IN         NUMBER,
                                    p_mr_header_id         IN         NUMBER,
                                    x_accomplishment_date  OUT NOCOPY DATE,
                                    x_unit_effectivity_id  OUT NOCOPY NUMBER,
                                    x_deferral_flag        OUT NOCOPY BOOLEAN,
                                    x_status_code          OUT NOCOPY VARCHAR2,
                                    x_return_val           OUT NOCOPY BOOLEAN);

END AHL_UMP_UTIL_PKG;

/
