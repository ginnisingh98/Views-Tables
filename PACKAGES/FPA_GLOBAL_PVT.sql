--------------------------------------------------------
--  DDL for Package FPA_GLOBAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FPA_GLOBAL_PVT" AUTHID CURRENT_USER AS
/* $Header: FPAVGLBS.pls 120.1 2005/08/18 11:49:32 appldev noship $ */

	-- The AW used by FPA
--	fpa_aw VARCHAR2(30);

function aw_space_name return varchar2;

-- Determines if the AW workspace is attached in the
-- current session
FUNCTION is_aw_attached RETURN BOOLEAN;

END fpa_global_pvt;

 

/
