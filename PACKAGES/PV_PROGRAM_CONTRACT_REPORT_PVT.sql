--------------------------------------------------------
--  DDL for Package PV_PROGRAM_CONTRACT_REPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PROGRAM_CONTRACT_REPORT_PVT" AUTHID CURRENT_USER as
/* $Header: pvxtpcrs.pls 115.1 2002/12/25 00:56:34 ktsao ship $*/
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_PROGRAM_CONTRACT_REPORT_PVT
-- Purpose
--
-- History
--         02-AUG-2002    Karen.Tsao      Created
--
-- NOTE
--
-- Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA
--                          All rights reserved.
--
-- End of Comments
-- ===============================================================
--
--    prerun
--
--    'OKC_REPORT_PVT.prerun' used as default value
--    for profile option OKC_WEB_PRERUN
--    performs some validation tasks
--    like sections should be defined for the contract
--    let/not let to run report
--
  procedure prerun(
    -- standard parameters
	p_api_version in NUMBER default 1,
	p_init_msg_list	in VARCHAR2 default OKC_API.G_TRUE,
	x_return_status	out nocopy VARCHAR2,
	x_msg_count out nocopy NUMBER,
	x_msg_data out nocopy VARCHAR2,
    -- input parameters
	p_chr_id in NUMBER,
	p_major_version NUMBER default NULL,
	p_scn_id in NUMBER default NULL
  );
END PV_PROGRAM_CONTRACT_REPORT_PVT;

 

/
