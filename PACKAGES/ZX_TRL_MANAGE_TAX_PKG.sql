--------------------------------------------------------
--  DDL for Package ZX_TRL_MANAGE_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TRL_MANAGE_TAX_PKG" AUTHID CURRENT_USER AS
/* $Header: zxrilnrepsrvpvts.pls 120.24 2005/08/24 21:22:58 lxzhang ship $ */


-- Start of comments
-- API name  : Create_Detail_Lines
-- Type  : Private
-- Pre-reqs : None.
-- Function : Insert tax lines into tax repository.
-- Parameters :
-- OUT  : x_return_status          OUT VARCHAR2
-- Version         : Current version    1.0
-- WHO  WHEN  WHAT
-- prgoyal  22-Nov-2002 1. Removed In parameter for lines pl/sql table
-- prgoyal  6-Dec-2002 Changed reference from pl/sql table to global temporary table
--     and added no copy in parameters
-- Notes  : None
-- End of comments

  PROCEDURE  Create_Detail_Lines (
        p_event_class_rec   IN          ZX_API_PUB.EVENT_CLASS_REC_TYPE,
        x_return_status        OUT NOCOPY VARCHAR2
  );

-- Start of comments
-- API name  : Delete_Detail_Lines
-- Type  : Private
-- Pre-reqs : None.
-- Function : Deletes the transaction from ZX_LINES for given transaction details
-- Parameters :
--      IN              : p_event_class_rec IN  ZX_API_PUB.EVENT_CLASS_REC_TYPE
-- OUT  : x_return_status          OUT  VARCHAR2
--      Version  : Current version 1.0
-- WHO  WHEN  WHAT
-- prgoyal  22-Nov-2002 1. Removed IN parameter for lines pl/sql table
-- Notes  : None
-- End of comments

  PROCEDURE Delete_Detail_Lines
       (x_return_status      OUT NOCOPY VARCHAR2,
        p_event_class_rec IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE);

-- Start of comments
-- API name  : Delete_Summary_Lines
-- Type  : Private
-- Pre-reqs : None.
-- Function : Deletes the transaction from ZX_LINES_SUMMARY for given transaction details
-- Parameters :
-- OUT  : x_return_status          OUT VARCHAR2
-- Version  : Current version 1.0
-- WHO  WHEN  WHAT
-- prgoyal  22-Nov-2002 1. Removed IN parameter for lines pl/sql table
-- Notes  : None
-- End of comments

  PROCEDURE Delete_Summary_Lines
       (x_return_status      OUT NOCOPY VARCHAR2,
        p_event_class_rec IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE);

-- Start of comments
--      API name        : Delete_Loose_Tax_Distributions
--      Type            : Private
--      Pre-reqs        : None.
--      Function        : Deletes tax distributions from ZX_REC_NREC_DIST for given tax line
--      Parameters      :
--      IN              : p_event_class_rec IN  ZX_API_PUB.EVENT_CLASS_REC_TYPE
--      OUT             : x_return_status          OUT  VARCHAR2
--      Version         : Current version       1.0
--      Notes           : None
-- End of comments

  PROCEDURE Delete_Loose_Tax_Distributions
       (x_return_status      OUT NOCOPY VARCHAR2,
        p_event_class_rec IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE);

-- Start of comments
--      API name        : Delete_Tax_Distributions
--      Type            : Private
--      Pre-reqs        : None.
--      Function        : Delete old tax distributions from ZX_REC_NREC_DIST when
--                        new tax distributions are created in ZX_REC_NREC_DIST_GT
--                        Deletes old tax distributions from ZX_REC_NREC_DIST,
--
--      Parameters      :
--      IN              : p_event_class_rec IN  ZX_API_PUB.EVENT_CLASS_REC_TYPE
--      OUT             : x_return_status          OUT  VARCHAR2
--      Version         : Current version       1.0
--      Notes           : None
-- End of comments

  PROCEDURE Delete_Tax_Distributions
       (x_return_status      OUT NOCOPY VARCHAR2,
        p_event_class_rec IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE);

-- Start of comments
-- API name  : Delete_Transaction
-- Type  : Private.
-- Function :
-- Pre-reqs : None.
-- Parameters :
-- IN  :  p_event_class_rec IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE
-- OUT  : x_return_status      OUT VARCHAR2(1)
-- Version  : Current version      1.0
-- Notes  : None
--
-- End of comments

  PROCEDURE Delete_Transaction
       (x_return_status      OUT NOCOPY VARCHAR2,
        p_event_class_rec IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE);

-- Start of comments
-- API name  : Cancel_Transaction
-- Type  : Private.
-- Function :
-- Pre-reqs : None.
-- Parameters :
-- IN  :  p_event_class_rec IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE
-- OUT  : x_return_status      OUT VARCHAR2(1)
-- Version  : Current version      1.0
-- Notes  : None
--
-- End of comments

  PROCEDURE Cancel_Transaction
       (x_return_status      OUT NOCOPY VARCHAR2,
        p_event_class_rec IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE);
-- Start of comments
-- API name  : Purge_Transaction
-- Type  : Private.
-- Function :
-- Pre-reqs : None.
-- Parameters :
-- IN  :  p_event_class_rec IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE
-- OUT  : x_return_status      OUT VARCHAR2(1)
-- Version  : Current version      1.0
-- Notes  : None.
--
-- End of comments

  PROCEDURE Purge_Transaction
       (x_return_status      OUT NOCOPY VARCHAR2,
        p_event_class_rec IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE);

-- Start of comments
--      API name        : Mark_Detail_Tax_Lines_Delete
--      Type            : Private.
--      Function        : Marks tax lines for delete in ZX_LINES for a given transaction line
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_transaction_line_rec     IN  ZX_API_PUB.TRANSACTION_LINE_REC_TYPE
--      OUT             : x_return_status            OUT VARCHAR2(1)
--      Version         : Current version            1.0
--      Notes           : None
--
-- End of comments

  PROCEDURE Mark_Detail_Tax_Lines_Delete
       (x_return_status           OUT NOCOPY VARCHAR2,
        p_transaction_line_rec IN            ZX_API_PUB.TRANSACTION_LINE_REC_TYPE);

-- Start of comments
--      API name        : Create_Tax_Distributions
--      Type            : Public.
--      Function        : Inserts tax distributions into ZX_REC_NREC_DIST
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : None.
--      OUT             : x_return_status            OUT VARCHAR2(1)
--      Version         : Current version            1.0
--      Notes           : None.
--
-- End of comments

  PROCEDURE Create_Tax_Distributions
       (x_return_status OUT NOCOPY VARCHAR2);

-- Start of comments
--      API name        : Delete_Dist_Marked_For_Delete
--      Type            : Public.
--      Function        : This procedure is used to delete all the  tax distributions
--                        from ZX_REC_NREC_DIST that are associated with tax lines
--                        whose Process_For_Recovery_Flag is 'Y' or Item_Dist_Changed_Flag is 'Y.
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_event_class_rec   IN  ZX_API_PUB.EVENT_CLASS_REC_TYPE
--      OUT             : x_return_status     OUT VARCHAR2(1)
--      Version         : Current version            1.0
--      Notes           : None.
--
-- End of comments

  PROCEDURE Delete_Dist_Marked_For_Delete
       (x_return_status      OUT NOCOPY VARCHAR2,
        p_event_class_rec IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE);

-- Start of comments
--      API name        : Update_TaxLine_Rec_Nrec_Amt
--      Type            : Public.
--      Function        : This procedure updates the  total recoverable and  non-recoverable
--                        tax amounts for each detail tax line and summary tax line.
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_event_class_rec   IN  ZX_API_PUB.EVENT_CLASS_REC_TYPE
--      OUT             : x_return_status     OUT VARCHAR2(1)
--      Version         : Current version            1.0
--      Notes           : None.
--
-- End of comments
  PROCEDURE Update_TaxLine_Rec_Nrec_Amt
       (x_return_status      OUT NOCOPY VARCHAR2,
        p_event_class_rec IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE);

-- Start of comments
--      API name        : Update_Freeze_Flag
--      Type            : Public.
--      Function        : This procedure is used to  freeze distributions and update the
--                        records in ZX_LINES to indicate that the associated children are frozen
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_event_class_rec IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE
--      OUT             : x_return_status            OUT VARCHAR2(1)
--      Version         : Current version            1.0
--      Notes           : None.
--
-- End of comments

  PROCEDURE Update_Freeze_Flag
       (x_return_status      OUT NOCOPY VARCHAR2,
        p_event_class_rec IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE);

-- Start of comments
--      API name        : Update_Item_Dist_Changed_Flag
--      Type            : Public.
--      Function        : This procedure is used to update tax lines (ZX_LINES) with changed
--                        status for given transaction line distribution
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_event_class_rec   IN  ZX_API_PUB.EVENT_CLASS_REC_TYPE
--      OUT             : x_return_status     OUT VARCHAR2(1)
--      Version         : Current version           1.0
--      Notes           : None.
--
-- End of comments

  PROCEDURE Update_Item_Dist_Changed_Flag
       (x_return_status      OUT NOCOPY VARCHAR2,
        p_event_class_rec IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE);


-- Start of comments
--      API name        : Discard_Tax_Only_Lines
--      Type            : Public.
--      Function        : This recording service is used to discard tax lines and
--                        tax distributions, marked with tax_only  status. This  service will be called by TSRM.
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : x_event_class_rec_type    IN ZX_API_PUB.EVENT_CLASS_REC_TYPE
--      OUT             : x_return_status           OUT VARCHAR2(1)
--      Version         : Current version           1.0
--      Notes           : None.
--
-- End of comments

  PROCEDURE Discard_Tax_Only_Lines
       (x_return_status      OUT NOCOPY VARCHAR2,
        p_event_class_rec IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE);

-- Start of comments
--      API name        : Update_GL_Date
--      Type            : Public.
--      Function        : This recording service is used to obtain the GL Date
--                        for the tax distributions. This service will be called
--                        by TSRM.
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : GL_DATE              IN DATE
--      OUT             : x_return_status      OUT NOCOPY      VARCHAR2(30)
--      Version         : Current version           1.0
--      Notes           : None.
--
-- End of comments

  PROCEDURE Update_GL_Date
       (p_gl_date       IN            DATE,
        x_return_status    OUT NOCOPY VARCHAR2);

-- Start of comments
--      API name        : Update_Exchange_Rate
--      Type            : Public.
--      Function        : This recordin service is used to modify the tax amounts
--                        needed to be calculated in functional currency using
--                        the exchange rate and rounding needs to be done too.
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_event_class_rec IN ZX_API_PUB.EVENT_CLASS_REC_TYPE
--                        p_functional_currency_flg IN VARCHAR2
--      OUT             : x_return_status      OUT NOCOPY      VARCHAR2(30)
--      Version         : Current version           1.0
--      Notes           : None.
--
-- End of comments

  PROCEDURE Update_Exchange_Rate
       (p_event_class_rec         IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE,
        x_return_status              OUT NOCOPY VARCHAR2);

-- Start of comments
--      API name        : update_exist_summary_line_id
--      Type            : Public.
--      Function        : This recording service is used to preserve old
--                        summary_tax_line_id in g_detail_tax_lines_gt(for
--                        UPDATE case) if the same summarization criteria
--                        exist in zx_lines_summary
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : p_event_class_rec IN ZX_API_PUB.EVENT_CLASS_REC_TYPE
--      OUT             : x_return_status      OUT NOCOPY      VARCHAR2(30)
--      Version         : Current version           1.0
--      Notes           : None.
--
-- End of comments

  PROCEDURE update_exist_summary_line_id
       ( p_event_class_rec   IN         ZX_API_PUB.EVENT_CLASS_REC_TYPE,
         x_return_status     OUT NOCOPY VARCHAR2);


-- Start of comments
--      API name        : RELEASE_DOCUMENT_TAX_HOLD
--      Type            : Public.
--      Function        : public API to release the tax hold at the document level
--                        by updating TAX_HOLD_RELEASED_CODE in zx_lines based on
--                        the input tax hold release code table.
--      Pre-reqs        : None.
--      Version         : Current version           1.0
--      Notes           : None.
--      Created By      : Ling Zhang
-- End of comments

PROCEDURE RELEASE_DOCUMENT_TAX_HOLD
       (x_return_status             OUT NOCOPY VARCHAR2,
        p_event_class_rec IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE,
        p_tax_hold_released_code IN     ZX_API_PUB.VALIDATION_STATUS_TBL_TYPE);

------------------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  create_summary_lines_crt_evnt
--
--  DESCRIPTION
--  Public procedure to create zx_lines_summary from zx_detail_tax_lines_gt
--  for CREATE tax_event_type
------------------------------------------------------------------------------

PROCEDURE create_summary_lines_crt_evnt(
  p_event_class_rec   IN          ZX_API_PUB.EVENT_CLASS_REC_TYPE,
  x_return_status     OUT NOCOPY  VARCHAR2
);

------------------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  create_summary_lines_upd_evnt
--
--  DESCRIPTION
--  Public procedure to create zx_lines_summary from zx_lines for
--  UPDATE tax_event_type
------------------------------------------------------------------------------
PROCEDURE create_summary_lines_upd_evnt(
  p_event_class_rec   IN          ZX_API_PUB.EVENT_CLASS_REC_TYPE,
  x_return_status     OUT NOCOPY  VARCHAR2
);

------------------------------------------------------------------------------
--  PUBLIC PROCEDURE
--  create_summary_lines_del_evnt
--
--  DESCRIPTION
--  Public procedure called from UI to recreate zx_lines_summary from zx_lines
--  After deleting the transaction item lines.
------------------------------------------------------------------------------
PROCEDURE create_summary_lines_del_evnt(
  p_application_id                IN          NUMBER,
  p_entity_code                   IN          VARCHAR2,
  p_event_class_code              IN          VARCHAR2,
  p_trx_id                        IN          NUMBER,
  p_trx_line_id                   IN          NUMBER,
  p_trx_level_type                IN          VARCHAR2,
  p_retain_summ_tax_line_id_flag  IN          VARCHAR2,
  x_return_status                 OUT NOCOPY  VARCHAR2
);

END ZX_TRL_MANAGE_TAX_PKG;

 

/
