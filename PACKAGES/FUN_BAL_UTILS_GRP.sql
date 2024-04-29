--------------------------------------------------------
--  DDL for Package FUN_BAL_UTILS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_BAL_UTILS_GRP" AUTHID CURRENT_USER AS
/* $Header: fungbalutils.pls 120.1.12010000.2 2009/07/13 08:12:28 srampure ship $ */
/* ----------------------------------------------------------------------------
--	API name 	: FUN_BAL_UTILS_GRP.get_inter_intra_account
--	Type		: Group
--	Pre-reqs	: None.
--	Function	: Given a transacting and trading Balancing segment value, the
--                        the procedure determines what type of account is required
--                        ie inter or intra company accounts and returns the same
--	Parameters	:
--	IN		:
--              p_api_version               IN NUMBER   Required
--              p_init_msg_list	            IN VARCHAR2 Optional
--              p_ledger_id                 IN NUMBER   Required
--              p_to_ledger_id               IN NUMBER   Required
--              p_from_bsv                  IN VARCHAR2 Required
--              p_to_bsv                    IN VARCHAR2 Required
--              p_source                    IN VARCHAR2 Optional
--              p_category                  IN VARCHAR2 Optional
--              p_gl_date                   IN DATE     Required
--              p_acct_type                 IN VARCHAR2 Required
--                   Account type would be 'D'ebit(Receivables)
--                   Or                    'C'redit' (Payables)
--
--	OUT		:
--              x_status                    VARCHAR2
--              x_msg_count                 NUMBER
--              x_msg_data                  VARCHAR2
--              x_ccid                      VARCHAR2   CCID requested
--              x_reciprocal_ccid           VARCHAR2   Reciprocal CCID
--                   Eg. If receivable account ccid is requested for BSV1 => BSV2
--                   x_reciprocal_ccid will contain the payable account for
--                   BSV2 => BSV1
--
--	Version	: Current version	1.0
--		  Previous version 	1.0
--		  Initial version 	1.0
------------------------------------------------------------------------------*/
PROCEDURE get_inter_intra_account (p_api_version       IN     NUMBER,
                                    p_init_msg_list     IN     VARCHAR2 default FND_API.G_FALSE,
                                    p_ledger_id         IN     NUMBER,
                                    p_to_ledger_id      IN     NUMBER,
                                    p_from_bsv          IN     VARCHAR2,
                                    p_to_bsv            IN     VARCHAR2,
                                    p_source            IN     VARCHAR2,
                                    p_category          IN     VARCHAR2,
                                    p_gl_date           IN     DATE,
                                    p_acct_type         IN     VARCHAR2,
                                    x_status            IN OUT NOCOPY VARCHAR2,
                                    x_msg_count         IN OUT NOCOPY NUMBER,
                                    x_msg_data          IN OUT NOCOPY VARCHAR2,
                                    x_ccid              IN OUT NOCOPY NUMBER ,
                                    x_reciprocal_ccid   IN OUT NOCOPY NUMBER);

/* ----------------------------------------------------------------------------
--	API name 	: FUN_BAL_UTILS_GRP.get_intercompany_account
--	Type		: Group
--	Pre-reqs	: None.
--	Function	: Given a transacting and trading Balancing segment value, the
--                the procedure returns the intercompany receivables and
--                payables account
--	Parameters	:
--	IN		:
--              p_api_version               IN NUMBER   Required
--              p_init_msg_list	            IN VARCHAR2 Optional
--              p_ledger_id                 IN NUMBER   Required
--              p_from_le                   IN NUMBER   Required
--              p_source                    IN VARCHAR2 Required
--              p_category                  IN VARCHAR2 Required
--              p_from_bsv                  IN VARCHAR2 Required
--              p_to_le                     IN NUMBER   Required
--              p_to_bsv                    IN VARCHAR2 Required
--              p_gl_date                   IN DATE     Required
--              p_acct_type                 IN VARCHAR2 Required
--                   Account type would be 'R'eceivables or 'P'ayables
--
--	OUT		:
--              x_status                    VARCHAR2
--              x_msg_count                 NUMBER
--              x_msg_data                  VARCHAR2
--              x_ccid                      VARCHAR2   CCID requested
--              x_reciprocal_ccid           VARCHAR2   Reciprocal CCID
--                   Eg. If receivable account ccid is requested for BSV1 => BSV2
--                   x_reciprocal_ccid will contain the payable account for
--                   BSV2 => BSV1
--
--	Version	: Current version	1.0
--		  Previous version 	1.0
--		  Initial version 	1.0
------------------------------------------------------------------------------*/
PROCEDURE get_intercompany_account (p_api_version       IN     NUMBER,
                                    p_init_msg_list     IN     VARCHAR2 default FND_API.G_FALSE,
                                    p_ledger_id         IN     NUMBER,
                                    p_from_le           IN     NUMBER,
                                    p_source            IN     VARCHAR2,
                                    p_category          IN     VARCHAR2,
                                    p_from_bsv          IN     VARCHAR2,
                                    p_to_ledger_id      IN     NUMBER,
                                    p_to_le             IN     NUMBER,
                                    p_to_bsv            IN     VARCHAR2,
                                    p_gl_date           IN     DATE,
                                    p_acct_type         IN     VARCHAR2,
                                    x_status            IN OUT NOCOPY VARCHAR2,
                                    x_msg_count         IN OUT NOCOPY NUMBER,
                                    x_msg_data          IN OUT NOCOPY VARCHAR2,
                                    x_ccid              IN OUT NOCOPY NUMBER ,
                                    x_reciprocal_ccid   IN OUT NOCOPY NUMBER);

/* ----------------------------------------------------------------------------
--	API name 	: FUN_BAL_UTILS_GRP.get_intracompany_account
--	Type		: Group
--	Pre-reqs	: None.
--	Function	: Given a transacting and trading Balancing segment value, the
--                the procedure returns the intracompany credit and debit
--                account
--	Parameters	:
--	IN		:
--              p_api_version               IN NUMBER	Required
--              p_init_msg_list	            IN VARCHAR2 Optional
--              p_ledger_id                 IN NUMBER   Required
--              p_from_le                   IN NUMBER   Optional
--              p_source                    IN VARCHAR2 Optional
--                  If not provided, source of 'Other' will be used to derive
--                  the account
--              p_category                  IN VARCHAR2 Optional
--                  If not provided, category of 'Other' will be used to derive
--                  the account
--              p_dr_bsv                    IN VARCHAR2 Required
--              p_cr_bsv                    IN VARCHAR2 Required
--              p_gl_date                   IN DATE     Required
--              p_acct_type                 IN VARCHAR2 Required
--                  Account type would be 'D'ebit or 'C'redit
--
--	OUT		:
--              x_status                    VARCHAR2
--              x_msg_count                 NUMBER
--              x_msg_data                  VARCHAR2
--              x_ccid                      VARCHAR2   CCID requested
--              x_reciprocal_ccid           VARCHAR2   Reciprocal CCID
--                   Eg. If debit account ccid is requested for BSV1 => BSV2
--                   x_reciprocal_ccid will contain the credit account for
--                   BSV2 => BSV1
--
--	Version	: Current version	1.0
--		  Previous version 	1.0
--		  Initial version 	1.0
------------------------------------------------------------------------------*/
PROCEDURE get_intracompany_account (p_api_version       IN     NUMBER,
                                    p_init_msg_list     IN     VARCHAR2 default FND_API.G_FALSE,
                                    p_ledger_id         IN     NUMBER,
                                    p_from_le           IN     NUMBER,
                                    p_source            IN     VARCHAR2,
                                    p_category          IN     VARCHAR2,
                                    p_dr_bsv            IN     VARCHAR2,
                                    p_cr_bsv            IN     VARCHAR2,
                                    p_gl_date           IN     DATE,
                                    p_acct_type         IN     VARCHAR2,
                                    x_status            IN OUT NOCOPY VARCHAR2,
                                    x_msg_count         IN OUT NOCOPY NUMBER,
                                    x_msg_data          IN OUT NOCOPY VARCHAR2,
                                    x_ccid              IN OUT NOCOPY NUMBER ,
                                    x_reciprocal_ccid   IN OUT NOCOPY NUMBER);


END FUN_BAL_UTILS_GRP;

/
