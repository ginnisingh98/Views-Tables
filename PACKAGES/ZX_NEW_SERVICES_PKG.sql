--------------------------------------------------------
--  DDL for Package ZX_NEW_SERVICES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_NEW_SERVICES_PKG" AUTHID CURRENT_USER AS
/* $Header: zxifnewsrvcspubs.pls 120.0.12010000.4 2010/08/27 06:17:02 prigovin noship $ */

-- Bug 7117340 -- DFF ER
TYPE id_tbl_type is TABLE OF ZX_REC_NREC_DIST.REC_NREC_TAX_DIST_ID%TYPE
INDEX BY BINARY_INTEGER;

TYPE attribute_tbl_type is TABLE OF ZX_REC_NREC_DIST.ATTRIBUTE1%TYPE
INDEX BY BINARY_INTEGER;

TYPE attribute_category_tbl_type is TABLE OF ZX_REC_NREC_DIST.ATTRIBUTE_CATEGORY%TYPE
INDEX BY BINARY_INTEGER;

TYPE tax_dist_dff_rec_type IS RECORD
( rec_nrec_tax_dist_id       id_tbl_type,
  attribute1                 attribute_tbl_type,
  attribute2                 attribute_tbl_type,
  attribute3                 attribute_tbl_type,
  attribute4                 attribute_tbl_type,
  attribute5                 attribute_tbl_type,
  attribute6                 attribute_tbl_type,
  attribute7                 attribute_tbl_type,
  attribute8                 attribute_tbl_type,
  attribute9                 attribute_tbl_type,
  attribute10                attribute_tbl_type,
  attribute11                attribute_tbl_type,
  attribute12                attribute_tbl_type,
  attribute13                attribute_tbl_type,
  attribute14                attribute_tbl_type,
  attribute15                attribute_tbl_type,
  attribute_category         attribute_category_tbl_type
);

tax_dist_dff_type tax_dist_dff_rec_type;
-- End Bug 7117340 -- DFF ER

 /* =======================================================================*
 | PROCEDURE  freeze_tax_dists_for_items :                                  |
 * =======================================================================*/

        PROCEDURE freeze_tax_dists_for_items
        (
          p_api_version           IN             NUMBER,
          p_init_msg_list         IN             VARCHAR2,
          p_commit                IN             VARCHAR2,
          p_validation_level      IN             NUMBER,
          x_return_status            OUT NOCOPY  VARCHAR2,
          x_msg_count                OUT NOCOPY  NUMBER,
          x_msg_data                 OUT NOCOPY  VARCHAR2,
          p_transaction_rec       IN OUT NOCOPY  ZX_API_PUB.transaction_rec_type,
          p_trx_line_dist_id_tbl  IN             ZX_API_PUB.number_tbl_type
        );

 /* =======================================================================*
 | PROCEDURE  cancel_tax_lines :                                           |
 * =======================================================================*/

        PROCEDURE CANCEL_TAX_LINES
        (
          p_api_version           IN             NUMBER,
          p_init_msg_list         IN             VARCHAR2,
          p_commit                IN             VARCHAR2,
          p_validation_level      IN             NUMBER,
          x_return_status             OUT NOCOPY VARCHAR2,
          x_msg_count                 OUT NOCOPY NUMBER,
          x_msg_data                  OUT NOCOPY VARCHAR2,
          p_transaction_rec       IN  OUT NOCOPY ZX_API_PUB.transaction_rec_type,
          p_tax_only_line_flag    IN             VARCHAR2,
          p_trx_line_id           IN             NUMBER,
          p_trx_level_type        IN             VARCHAR2,
          p_line_level_action     IN             VARCHAR2
        );

 /* ======================================================================*
 | PROCEDURE delete_tax_dists:                                           |
 * ======================================================================*/

        PROCEDURE delete_tax_dists
        (
    	     p_api_version           IN            NUMBER,
           p_init_msg_list         IN            VARCHAR2,
           p_commit                IN            VARCHAR2,
           p_validation_level      IN            NUMBER,
           x_return_status         OUT    NOCOPY VARCHAR2,
           x_msg_count             OUT    NOCOPY NUMBER,
           x_msg_data              OUT    NOCOPY VARCHAR2,
           p_transaction_line_rec  IN OUT NOCOPY ZX_API_PUB.transaction_line_rec_type
    	);

 /* =======================================================================*
 | PROCEDURE  SYNC_TAX_DIST_DFF :                                           |
 * =======================================================================*/
 -- Bug 7117340 -- DFF ER
        PROCEDURE SYNC_TAX_DIST_DFF
        (
          p_api_version           IN             NUMBER,
          p_init_msg_list         IN             VARCHAR2,
          p_commit                IN             VARCHAR2,
          p_validation_level      IN             NUMBER,
          x_return_status            OUT NOCOPY  VARCHAR2,
          x_msg_count                OUT NOCOPY  NUMBER,
          x_msg_data                 OUT NOCOPY  VARCHAR2,
          p_tax_dist_dff_tbl      IN             tax_dist_dff_type%TYPE
        );

END ZX_NEW_SERVICES_PKG;



/
