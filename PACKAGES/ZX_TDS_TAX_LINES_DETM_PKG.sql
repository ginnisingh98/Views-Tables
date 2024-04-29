--------------------------------------------------------
--  DDL for Package ZX_TDS_TAX_LINES_DETM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TDS_TAX_LINES_DETM_PKG" AUTHID CURRENT_USER as
/* $Header: zxditaxlndetpkgs.pls 120.12 2003/12/19 03:51:16 ssekuri ship $ */


PROCEDURE determine_tax_lines(
           p_event_class_rec       IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
           p_return_status         OUT NOCOPY VARCHAR2,
           p_error_buffer          OUT NOCOPY VARCHAR2);


end ZX_TDS_TAX_LINES_DETM_PKG;

 

/
