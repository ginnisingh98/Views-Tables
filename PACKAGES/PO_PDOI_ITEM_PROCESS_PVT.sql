--------------------------------------------------------
--  DDL for Package PO_PDOI_ITEM_PROCESS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PDOI_ITEM_PROCESS_PVT" AUTHID CURRENT_USER AS
/* $Header: PO_PDOI_ITEM_PROCESS_PVT.pls 120.1 2005/07/26 15:29 jinwang noship $ */

PROCEDURE create_items
(
  x_lines       IN OUT NOCOPY PO_PDOI_TYPES.lines_rec_type
);

END PO_PDOI_ITEM_PROCESS_PVT;

 

/
