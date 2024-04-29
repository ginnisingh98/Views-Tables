--------------------------------------------------------
--  DDL for Package ZX_TDS_IMPORT_DOCUMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TDS_IMPORT_DOCUMENT_PKG" AUTHID CURRENT_USER AS
 /* $Header: zxdiimpdocmtpkgs.pls 120.2 2004/03/04 01:56:01 hongliu ship $ */

PROCEDURE prorate_imported_sum_tax_lines (
 p_event_class_rec        IN             zx_api_pub.event_class_rec_type,
 x_return_status             OUT NOCOPY  VARCHAR2);

PROCEDURE  calculate_tax_for_import (
 p_trx_line_index         IN             BINARY_INTEGER,
 p_event_class_rec        IN             zx_api_pub.event_class_rec_type,
 p_tax_date               IN             DATE,
 p_tax_determine_date     IN             DATE,
 p_tax_point_date         IN             DATE,
 x_return_status             OUT NOCOPY  VARCHAR2);

END ZX_TDS_IMPORT_DOCUMENT_PKG;

 

/
