--------------------------------------------------------
--  DDL for Package ZX_TDS_MRC_PROCESSING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TDS_MRC_PROCESSING_PKG" AUTHID CURRENT_USER AS
/* $Header: zxdimrcprocspkgs.pls 120.0 2004/06/11 16:54:53 hongliu ship $ */


/* ======================================================================*
 |  Public Procedures create_mrc_det_tax_lines creates detail tax lines  |
 |   for each reporting currency                                         |
 * =====================================================================*/
PROCEDURE  create_mrc_det_tax_lines (
  p_event_class_rec	    IN              zx_api_pub.event_class_rec_type,
  x_return_status	    OUT NOCOPY      VARCHAR2);

END ZX_TDS_MRC_PROCESSING_PKG;

 

/
