--------------------------------------------------------
--  DDL for Package ZX_TCM_PTP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TCM_PTP_PKG" AUTHID CURRENT_USER AS
/* $Header: zxcptps.pls 120.13 2006/10/05 20:56:43 nipatel ship $ */

PROCEDURE GET_PTP(
            p_party_id          IN  NUMBER,
            p_party_type_code   IN  VARCHAR2,
            p_le_id             IN  NUMBER,
            p_inventory_loc     IN  NUMBER,
            p_ptp_id            OUT NOCOPY NUMBER,
            p_return_status     OUT NOCOPY VARCHAR2);

/* ======================================================================
   Procedure: GET_PTP_HQ
   Objective: Retrieve the Party Tax Profile for the HQ Establishment
              of a given Legal Entity.
   Assumption: Any Legal Entity will have only one HQ Establishment
   In Parameters: p_le_id - Legal Entity ID
   OUTPUT Parameters: p_ptp_id - Party Tax Profile ID
                      p_return_status - Success is p_ptp_id is not null
   ====================================================================== */
PROCEDURE GET_PTP_HQ(
            p_le_id             IN  xle_entity_profiles.legal_entity_id%TYPE,
            p_ptp_id            OUT NOCOPY zx_party_tax_profile.party_tax_profile_id%TYPE,
            p_return_status     OUT NOCOPY VARCHAR2);

PROCEDURE GET_TAX_SUBSCRIBER(
            p_le_id             IN  NUMBER,
            p_org_id            IN  NUMBER,
            p_ptp_id            OUT NOCOPY NUMBER,
            p_return_status     OUT NOCOPY VARCHAR2);

PROCEDURE GET_LOCATION_ID(
            p_org_id            IN  NUMBER,
            p_location_id       OUT NOCOPY NUMBER,
            p_return_status     OUT NOCOPY VARCHAR2);

Procedure CHECK_TAX_REGISTRATIONS(
            p_api_version       IN  NUMBER,
            p_le_reg_id         IN  NUMBER,
            x_return_status     OUT NOCOPY  VARCHAR2);

Procedure SYNC_TAX_REGISTRATIONS(
            p_api_version       IN  NUMBER,
            p_le_old_reg_id     IN  NUMBER,
            p_le_old_end_date   IN  DATE,
            p_le_new_reg_id     IN  NUMBER,
            p_le_new_reg_num    IN  VARCHAR2,
            x_return_status     OUT NOCOPY  VARCHAR2);

Procedure GET_PARTY_TAX_PROF_INFO(
     p_party_tax_profile_id 	IN NUMBER,
     x_tbl_index                OUT NOCOPY BINARY_INTEGER,
     x_return_status  		OUT NOCOPY VARCHAR2);

Procedure GET_PARTY_TAX_PROF_INFO(
     p_party_id 		IN NUMBER,
     p_party_type_code 		IN ZX_PARTY_TAX_PROFILE.PARTY_TYPE_CODE%TYPE,
     x_tbl_index                OUT NOCOPY BINARY_INTEGER,
     X_RETURN_STATUS  		OUT NOCOPY VARCHAR2);

END ZX_TCM_PTP_PKG;


 

/
