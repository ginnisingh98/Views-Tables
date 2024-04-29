--------------------------------------------------------
--  DDL for Package ZX_TRL_PUB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_TRL_PUB_PKG" AUTHID CURRENT_USER AS
/* $Header: zxrwlnrepsrvpubs.pls 120.16 2005/05/20 22:35:44 lxzhang ship $ */

-- Start of comments
--	API name 	: Manage_TaxLines
--	Type		: Public
--	Function	: This will create, update, delete and cancel tax lines and summary
--                        tax lines in the tax repository
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_event_class_details IN  ZX_API_PUB.EVENT_CLASS_REC_TYPE
--	OUT		: x_return_status	OUT VARCHAR2(1)
--	Version	        : Current version	1.0
--	WHO		WHEN		WHAT
--	prgoyal		22-Nov-2002	1. Removed IN parameter for lines pl/sql table
--	prgoyal		6-Dec-2002	Addded No COPY in spec and in body changed the code to
--					refer to global temporary tables.
--	Notes		: None.
--
-- End of comments
PROCEDURE Manage_TaxLines
(
	x_return_status 	OUT 	NOCOPY VARCHAR2					,
	p_event_class_rec       IN      ZX_API_PUB.EVENT_CLASS_REC_TYPE
);
-- Start of comments
--	API name 	: Synchronize_TaxLines
--	Type		: Public
--	Function	: Updates Tax Repository
--	Pre-reqs	: None.
--	Parameters	:
--	OUT		: x_return_status     OUT VARCHAR2(1)
--	Version	        : Current version     1.0
--	WHO		WHEN		WHAT
--	prgoyal		6-Dec-2002	Addded No COPY in spec
--	Notes		: None.
--
-- End of comments
PROCEDURE Synchronize_TaxLines
(
	x_return_status 	OUT 	NOCOPY VARCHAR2
);
-- Start of comments
--	API name 	: Document_Level_Changes
--	Type		: Public
--	Function	: Delete / Cancel / Purge tax lines from the tax repository
--	Pre-reqs	: None.
--	Parameters	:
--	IN		: p_transaction_tbl  	IN ZX_API_PUB.TRANSACTION_REC_TYPE
--	OUT		: x_return_status    	OUT	VARCHAR2(1)
--	Version  	: Current version    	1.0
--	WHO		WHEN		WHAT
--	prgoyal		6-Dec-2002	Addded No COPY in spec and in body changed the code to
--					refer to global temporary tables and also changes as per HLD.
--	Notes		: None.
--
-- End of comments
  PROCEDURE Document_Level_Changes
       (x_return_status             OUT NOCOPY VARCHAR2,
        p_event_class_rec       IN      ZX_API_PUB.EVENT_CLASS_REC_TYPE,
        p_tax_hold_released_code IN     ZX_API_PUB.VALIDATION_STATUS_TBL_TYPE);

-- Start of comments
--      API name      : Mark_Tax_Lines_Delete
--      Type          : Public
--      Function      : Mark the tax lines as deleted by updating the delete flag
--      Pre-reqs      : None.
--      Parameters    :
--      IN            : p_transaction_line_rec  IN ZX_API_PUB.TRANSACTION_LINE_REC_TYPE
--      OUT           : x_return_status         OUT     VARCHAR2(1)
--      Version       : Current version          1.0
--	WHO		WHEN		WHAT
--	prgoyal		6-Dec-2002	Created as per HLD TAX RECording Phase1A
--      Notes         : None.
--
-- End of comments
PROCEDURE Mark_Tax_Lines_Delete
(
        x_return_status         OUT    NOCOPY  VARCHAR2 ,
        p_transaction_line_rec 	IN      ZX_API_PUB.TRANSACTION_LINE_REC_TYPE
);

-- Start of comments
--      API name      : Manage_TaxDistributions
--      Type          : Public
--      Function      : This recording service is used to create, update, delete
--                      tax distributions lines and update tax lines  and summary
--                      tax lines in the tax repository
--      Pre-reqs      : None.
--      Parameters    :
--      IN            : p_transaction_rec  IN  ZX_API_PUB.TRANSACTION_REC_TYPE
--      OUT           : x_return_status    OUT VARCHAR2(1)
--      Version       : Current version    1.0
--      Notes         : None.
--
-- End of comments

PROCEDURE Manage_TaxDistributions
(
        x_return_status          OUT NOCOPY VARCHAR2,
	p_event_class_rec        IN  ZX_API_PUB.EVENT_CLASS_REC_TYPE
);

-- Start of comments
--      API name      : Freeze_TaxDistributions
--      Type          : Public
--      Function      :	This recording service is used to freeze tax distributions
--                      whenever user freezes transaction distribution lines
--      Pre-reqs      : None.
--      Parameters    :
--      IN            : p_event_class_details   IN   ZX_API_PUB.EVENT_CLASS_REC_TYPE
--      OUT           : x_return_status         OUT  VARCHAR2(1)
--      Version       : Current version         1.0
--      Notes         : None.
PROCEDURE Freeze_TaxDistributions
(
        x_return_status          OUT NOCOPY VARCHAR2,
         p_event_class_rec       IN      ZX_API_PUB.EVENT_CLASS_REC_TYPE
);


-- Start of comments
--      API name      : Update_Taxlines
--      Type          : Public
--      Function      : This recording service is used to update tax lines (ZX_LINES)
--                      with changed status for given transaction line distributions.
--      Pre-reqs      : None.
--      Parameters    :
--      IN            : p_event_class_details   IN   ZX_API_PUB.EVENT_CLASS_REC_TYPE
--      OUT           : x_return_status         OUT  VARCHAR2(1)
--      Version       : Current version    1.0
--      Notes         : None.

PROCEDURE Update_Taxlines
     (x_return_status      OUT NOCOPY VARCHAR2,
      p_event_class_rec IN            ZX_API_PUB.EVENT_CLASS_REC_TYPE);


-- Start of comments
--      API name        : Discard_Tax_Only_Lines
--      Type            : Public.
--      Function        : This recording service is used to discard tax lines
--                        and tax distributions, marked with tax_only  status.
--                        This service will be called by TSRM.
--      Pre-reqs        : None.
--      Parameters      :
--      IN              : x_event_class_rec_type IN ZX_API_PUB.EVENT_CLASS_REC_TYPE
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

--
--      API name      : delete_tax_lines_and_dists
--      Type          : Public
--      Function      : Delete all the detail tax lines and distributions of the
--                      passed-in transaction line from zx_lines and
--                      zx_rec_nrec_dist.
--

PROCEDURE delete_tax_lines_and_dists
(
    p_application_id       IN           NUMBER,
    p_entity_code          IN           VARCHAR2,
    p_event_class_code     IN           VARCHAR2,
    p_trx_id               IN           NUMBER,
    p_trx_line_id          IN           NUMBER,
    p_trx_level_type       IN           VARCHAR2,
    x_return_status        OUT NOCOPY   VARCHAR2
);

--
--      API name      : delete_tax_dists
--      Type          : Public
--      Function      : Delete all the detail tax distributions of the
--                      passed-in transaction line from zx_rec_nrec_dist.
--

PROCEDURE delete_tax_dists
(
    p_application_id       IN           NUMBER,
    p_entity_code          IN           VARCHAR2,
    p_event_class_code     IN           VARCHAR2,
    p_trx_id               IN           NUMBER,
    p_trx_line_id          IN           NUMBER,
    p_trx_level_type       IN           VARCHAR2,
    x_return_status        OUT NOCOPY   VARCHAR2
);

-- bug fix begin 4381349 end

END ZX_TRL_PUB_PKG;

 

/
