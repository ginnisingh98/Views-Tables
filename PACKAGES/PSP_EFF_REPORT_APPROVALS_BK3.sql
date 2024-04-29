--------------------------------------------------------
--  DDL for Package PSP_EFF_REPORT_APPROVALS_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_EFF_REPORT_APPROVALS_BK3" AUTHID CURRENT_USER AS
/* $Header: PSPEAAIS.pls 120.5 2006/07/21 13:04:05 tbalacha noship $ */

--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_eff_report_approvals_b >--------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_eff_report_approvals_b
( p_effort_report_approval_id    in             number
, p_object_version_number        in             number
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_eff_report_approvals_a >--------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_eff_report_approvals_a
( p_effort_report_approval_id    in             number
, p_object_version_number        in             number
, p_return_status                in             boolean
);
END psp_eff_report_approvals_bk3;

/
