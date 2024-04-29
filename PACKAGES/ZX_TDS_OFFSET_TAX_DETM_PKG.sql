--------------------------------------------------------
--  DDL for Package ZX_TDS_OFFSET_TAX_DETM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TDS_OFFSET_TAX_DETM_PKG" AUTHID CURRENT_USER as
/* $Header: zxdioffsettxpkgs.pls 120.10 2004/04/15 20:46:58 pla ship $ */


PROCEDURE process_offset_tax(
            p_offset_tax_line_rec  IN OUT NOCOPY ZX_DETAIL_TAX_LINES_GT%ROWTYPE,
            p_event_class_rec      IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_return_status           OUT NOCOPY VARCHAR2,
            p_error_buffer            OUT NOCOPY VARCHAR2);

end ZX_TDS_OFFSET_TAX_DETM_PKG;

 

/
