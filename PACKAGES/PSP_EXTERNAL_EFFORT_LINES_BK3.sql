--------------------------------------------------------
--  DDL for Package PSP_EXTERNAL_EFFORT_LINES_BK3
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_EXTERNAL_EFFORT_LINES_BK3" AUTHID CURRENT_USER AS
/* $Header: PSPEEAIS.pls 120.3 2006/07/06 13:25:21 tbalacha noship $ */

--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_external_effort_line_b >--------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_external_effort_line_b
( p_external_effort_line_id      in             number
, p_object_version_number        in             number
);
--
-- ----------------------------------------------------------------------------
-- |-------------------------< delete_external_effort_line_a >--------------------------|
-- ----------------------------------------------------------------------------
--
PROCEDURE delete_external_effort_line_a
( p_external_effort_line_id      in             number
, p_object_version_number        in             number
);
END psp_external_effort_lines_bk3;

/
