--------------------------------------------------------
--  DDL for Package ZX_TDS_TAX_STATUS_DETM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TDS_TAX_STATUS_DETM_PKG" AUTHID CURRENT_USER as
/* $Header: zxditaxstsdtpkgs.pls 120.8 2003/12/19 03:51:23 ssekuri ship $ */


PROCEDURE  get_tax_status(
            p_begin_index          IN     BINARY_INTEGER,
            p_end_index            IN     BINARY_INTEGER,
            p_structure_name       IN     VARCHAR2,
            p_structure_index      IN     BINARY_INTEGER,
            p_event_class_rec      IN     ZX_API_PUB.EVENT_CLASS_REC_TYPE,
            p_return_status        OUT NOCOPY VARCHAR2,
            p_error_buffer         OUT NOCOPY VARCHAR2);


end ZX_TDS_TAX_STATUS_DETM_PKG;

 

/
