--------------------------------------------------------
--  DDL for Package PO_R12_CAT_UPG_DEF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_R12_CAT_UPG_DEF_PVT" AUTHID CURRENT_USER AS
/* $Header: PO_R12_CAT_UPG_DEF_PVT.pls 120.1 2006/01/30 23:23:02 pthapliy noship $ */

PROCEDURE default_headers
(
  p_headers_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_headers_type
);

PROCEDURE default_lines
(
  p_lines_rec IN OUT NOCOPY PO_R12_CAT_UPG_PVT.record_of_lines_type
);

END PO_R12_CAT_UPG_DEF_PVT;

 

/
