--------------------------------------------------------
--  DDL for Package ZX_LINES_DET_FACTORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_LINES_DET_FACTORS_PKG" AUTHID CURRENT_USER AS
/* $Header: zxiflinedetfacts.pls 120.7 2005/08/23 20:47:48 vsidhart ship $ */

/* ============================================================================*
 | PROCEDURE  update_line_det_attribs : Update only the determining applicable |
 | at line level back to zx_lines_det_factors                                  |
 * ===========================================================================*/

       PROCEDURE update_line_det_attribs
       (
         p_trx_biz_category         IN  VARCHAR2,
         p_line_intended_use        IN  VARCHAR2,
         p_prod_fisc_class          IN  VARCHAR2,
         p_prod_category            IN  VARCHAR2,
         p_product_type             IN  VARCHAR2,
         p_user_def_fisc_class      IN  VARCHAR2,
         p_assessable_value         IN  NUMBER,
         p_tax_classification_code  IN  VARCHAR2,
         p_display_tax_classif_flag IN  VARCHAR2,
         p_transaction_line_rec     IN  ZX_API_PUB.transaction_line_rec_type,
         x_return_status            OUT NOCOPY VARCHAR2
       );


/* ============================================================================*
 | PROCEDURE  update_header_det_attribs : Calls the defaulting API to redefault|
 | tax determining attributes since the taxation country has changed           |
 | Also update the lines_det_factors with these values for UI to reflect the   |
 | changes.                                                                    |
 * ===========================================================================*/

       PROCEDURE update_header_det_attribs
       (
        p_taxation_country         IN            VARCHAR2,
        p_document_subtype         IN            VARCHAR2,
        p_tax_invoice_date         IN            DATE,
        p_tax_invoice_number       IN            VARCHAR2,
        p_display_tax_classif_flag IN            VARCHAR2,
        p_transaction_rec          IN            ZX_API_PUB.transaction_rec_type,
        p_event_class_rec          IN OUT NOCOPY ZX_API_PUB.event_class_rec_type,
        x_return_status               OUT NOCOPY VARCHAR2
       );

/* =======================================================================*
 | PROCEDURE  lock_line_det_factors : Lock all the lines of a transaction |
 | in zx_lines_det_factors                                                |
 * =======================================================================*/
       PROCEDURE lock_line_det_factors
       (
        p_transaction_rec    IN  ZX_API_PUB.transaction_rec_type,
        x_return_status      OUT NOCOPY VARCHAR2
       );

 END ZX_LINES_DET_FACTORS_PKG;


 

/
