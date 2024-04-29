--------------------------------------------------------
--  DDL for Package PA_MASS_ADDITIONS_CREATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_MASS_ADDITIONS_CREATE_PKG" AUTHID CURRENT_USER AS
/* $Header: PAMASSAS.pls 120.2 2005/09/02 15:18:24 aaggarwa noship $ */

    -- Start of comments
    -- -----------------
    -- API Name		: update_mass
    -- Purpose		: update the si_assets_addition_flag on CDLS
    -- Pre Reqs		: None
    -- Function		: This API tieback assets generated transactions.
    -- Calling API      : Ap_Mass_Additions_Create_Pkg
    -- End of comments
    -- ----------------

   PROCEDURE update_mass ( p_api_version      IN number,
                           p_init_msg_list    IN varchar2 default FND_API.G_FALSE,
                           p_commit           IN varchar2 default FND_API.G_FALSE,
                           p_validation_level IN number   default FND_API.G_VALID_LEVEL_FULL,
                           x_return_status    OUT nocopy  varchar2,
                           x_msg_count        OUT nocopy  number,
                           x_msg_data         OUT nocopy  varchar2,
                           p_request_id       IN number  ) ;

    -- Start of comments
    -- -----------------
    -- API Name		: Insert_Mass
    -- Purpose		: Create records in FA_MASS_ADDITIONS_GT to create assets
    --                    lines for non capital projects.
    -- Pre Reqs		: None
    -- Calling API      : Ap_Mass_Additions_Create_Pkg
    -- End of comments
    -- ----------------

   PROCEDURE  Insert_Mass( p_api_version               IN  number,
                           p_init_msg_list	       IN  varchar2 default FND_API.G_FALSE,
			   p_commit	    	       IN  varchar2 default FND_API.G_FALSE,
			   p_validation_level	       IN  number   default FND_API.G_VALID_LEVEL_FULL,
                           x_return_status	       OUT nocopy varchar2,
	                   x_msg_count		       OUT nocopy number,
	                   x_msg_data		       OUT nocopy varchar2,
			   x_count                     OUT nocopy number,
                           P_acctg_date                IN  DATE,
                           P_ledger_id                 IN  number,
                           P_user_id                   IN  number,
                           P_request_id                IN  number,
                           P_bt_code                   IN  varchar2,
                           P_primary_accounting_method IN  varchar2,
                           P_calling_sequence          IN  varchar2 DEFAULT NULL) ;
    --
    -- Start of comments
    -- -----------------
    -- API Name		: Insert_Discounts
    -- Purpose		: Create records for discounts in FA_MASS_ADDITIONS_GT to create assets
    --                    lines for non capital projects.
    -- Pre Reqs		: None
    -- Calling API      : Ap_Mass_Additions_Create_Pkg
    -- End of comments
    -- ----------------

    PROCEDURE  Insert_Discounts(p_api_version          IN    number,
                           p_init_msg_list	       IN    varchar2 default FND_API.G_FALSE,
			   p_commit	    	       IN    varchar2 default FND_API.G_FALSE,
			   p_validation_level	       IN    number   default FND_API.G_VALID_LEVEL_FULL,
                           x_return_status	       OUT   nocopy varchar2,
	                   x_msg_count		       OUT   nocopy number,
	                   x_msg_data		       OUT   nocopy varchar2,
			   x_count                     OUT   nocopy number,
                           P_acctg_date                IN    DATE,
                           P_ledger_id                 IN    number,
                           P_user_id                   IN    number,
                           P_request_id                IN    number,
                           P_bt_code                   IN    varchar2,
                           P_primary_accounting_method IN    varchar2,
                           P_calling_sequence          IN    varchar2 DEFAULT NULL) ;
    --
END PA_Mass_Additions_Create_Pkg;

 

/
