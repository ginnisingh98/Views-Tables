--------------------------------------------------------
--  DDL for Package AHL_UMP_UTIL_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_UMP_UTIL_GRP" AUTHID CURRENT_USER AS
/* $Header: AHLGUMPS.pls 115.2 2003/09/24 04:56:59 sracha noship $ */

------------------------
-- Declare Procedures --
------------------------

-- Wrapper Procedure to call private API populate_appl_MRs.
-- Used by MR tab in the Service Request Form.

PROCEDURE Populate_Appl_MRs (
    p_api_version            IN            NUMBER,
    p_init_msg_list          IN            VARCHAR2  := FND_API.G_FALSE,
    p_csi_ii_id           IN            NUMBER,
    x_return_status       OUT  NOCOPY   VARCHAR2,
    x_msg_count           OUT  NOCOPY   NUMBER,
    x_msg_data            OUT  NOCOPY   VARCHAR2 ) ;


End AHL_UMP_UTIL_GRP;

 

/
