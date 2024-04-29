--------------------------------------------------------
--  DDL for Package Body INV_SYNC_PRINT_REQUEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_SYNC_PRINT_REQUEST" AS
/* $Header: INVSPRQB.pls 120.2 2005/06/22 05:37:47 appldev ship $ */

PROCEDURE SYNC_PRINT_REQUEST
(
	p_xml_content 		IN LONG
,	x_job_status 		OUT NOCOPY VARCHAR2    -- NOCOPY added as a part of Bug# 4380449
,	x_printer_status	OUT NOCOPY VARCHAR2    -- NOCOPY added as a part of Bug# 4380449
,	x_status_type		OUT NOCOPY NUMBER  -- NOCOPY added as a part of Bug# 4380449
) IS

BEGIN
	null;
END;

END INV_SYNC_PRINT_REQUEST;

/
