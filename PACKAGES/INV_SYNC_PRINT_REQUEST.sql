--------------------------------------------------------
--  DDL for Package INV_SYNC_PRINT_REQUEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_SYNC_PRINT_REQUEST" AUTHID CURRENT_USER AS
/* $Header: INVSPRQS.pls 120.2 2005/06/22 05:32:07 appldev ship $ */
G_PKG_NAME	CONSTANT VARCHAR2(50) := 'INV_SYNC_PRINT_REQUEST';

PROCEDURE SYNC_PRINT_REQUEST
(
	p_xml_content 		IN LONG
,	x_job_status 		OUT NOCOPY VARCHAR2    -- NOCOPY added as a part of Bug# 4380449
,	x_printer_status	OUT NOCOPY VARCHAR2    -- NOCOPY added as a part of Bug# 4380449
,	x_status_type		OUT NOCOPY NUMBER  -- NOCOPY added as a part of Bug# 4380449
);
END INV_SYNC_PRINT_REQUEST;

 

/
