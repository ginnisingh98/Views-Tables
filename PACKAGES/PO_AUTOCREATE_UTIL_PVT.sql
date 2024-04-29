--------------------------------------------------------
--  DDL for Package PO_AUTOCREATE_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_AUTOCREATE_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: POXVACUS.pls 120.0 2005/06/02 01:47:55 appldev noship $ */

PROCEDURE synchronize_builder_reqs ( p_key      IN NUMBER
                                   , p_req_list IN PO_TBL_NUMBER );

FUNCTION add_req_lines_gt ( p_req_line_id_tbl   IN  PO_TBL_NUMBER )
  RETURN NUMBER;

PROCEDURE clear_builder_reqs_gt ( p_key    IN  NUMBER );

PROCEDURE get_and_lock_req_lines_in_pool
(   p_req_line_id_tbl          IN          PO_TBL_NUMBER
,   p_lock_records             IN          VARCHAR2
,   x_req_line_id_in_pool_tbl  OUT NOCOPY  PO_TBL_NUMBER
,   x_records_locked           OUT NOCOPY  VARCHAR2
);

END PO_AUTOCREATE_UTIL_PVT;

 

/
