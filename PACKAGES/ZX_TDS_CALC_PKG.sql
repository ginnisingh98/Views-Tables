--------------------------------------------------------
--  DDL for Package ZX_TDS_CALC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TDS_CALC_PKG" AUTHID CURRENT_USER AS
 /* $Header: zxdicalctaxspkgs.pls 120.5 2003/12/19 03:51:36 ssekuri ship $ */

           PROCEDURE Get_tax_amount (
            p_begin_index          IN     NUMBER,
            p_end_index            IN     NUMBER,
--            p_detail_tax_line_tbl  IN OUT NOCOPY ZX_API_PUB.detail_tax_line_tbl_type,
            p_event_class_rec      IN     ZX_API_PUB.event_class_rec_type,
            p_structure_name       IN     VARCHAR2,
            p_structure_index      IN     BINARY_INTEGER,
            p_return_status        OUT NOCOPY VARCHAR2,
            p_error_buffer         OUT NOCOPY VARCHAR2);



END ZX_TDS_CALC_PKG;


 

/
