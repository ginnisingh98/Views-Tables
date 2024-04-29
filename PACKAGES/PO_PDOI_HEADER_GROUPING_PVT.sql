--------------------------------------------------------
--  DDL for Package PO_PDOI_HEADER_GROUPING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PDOI_HEADER_GROUPING_PVT" AUTHID CURRENT_USER AS
/* $Header: PO_PDOI_HEADER_GROUPING_PVT.pls 120.0 2005/07/20 10:51 bao noship $ */


PROCEDURE process
( x_all_headers_processed OUT NOCOPY VARCHAR2
);

END PO_PDOI_HEADER_GROUPING_PVT;

 

/
