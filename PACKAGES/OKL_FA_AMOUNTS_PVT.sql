--------------------------------------------------------
--  DDL for Package OKL_FA_AMOUNTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_FA_AMOUNTS_PVT" AUTHID CURRENT_USER AS
/* $Header: OKLRAAMS.pls 115.1 2002/12/23 07:32:58 avsingh noship $ */
G_PKG_NAME    VARCHAR2(30) := 'OKL_FA_AMOUNTS_PVT';
--------------------------------------------------------------------------------
--start of comments
-- Description : This api takes the asset id and book type code as inputs and
--               returns the Oracle fixed asset amounts in contract currency
-- IN Parameters : p_asset_id - asset id
--                 p_book_type_code - book_type code
-- OUT Parameters :
--                 x_cost                 FA current cost
--                 x_adj_cost             FA adjusted cost
--                 x_original_cost        FA original cost
--                 x_salvage_value        FA salvage value
--                 x_recoverable_cost     FA recoverable cost
--                 x_adj_recoverable_cost FA adjusted recoverable cost
--End of comments
--------------------------------------------------------------------------------
Procedure convert_fa_amounts
                  (p_api_version          IN  NUMBER,
                   p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                   x_return_status        OUT NOCOPY VARCHAR2,
                   x_msg_count            OUT NOCOPY NUMBER,
                   x_msg_data             OUT NOCOPY VARCHAR2,
                   p_asset_id             IN  NUMBER,
                   p_book_type_code       IN  VARCHAR2,
                   x_cost                 OUT NOCOPY NUMBER,
                   x_adj_cost             OUT NOCOPY NUMBER,
                   x_original_cost        OUT NOCOPY NUMBER,
                   x_salvage_value        OUT NOCOPY NUMBER,
                   x_recoverable_cost     OUT NOCOPY NUMBER,
                   x_adj_recoverable_cost OUT NOCOPY NUMBER);
--------------------------------------------------------------------------------
--start of comments
-- Description : This api takes the OKL finacial asset line id as input and
--               returns the Oracle fixed asset CORP BOOK amounts in contract currency
-- IN Parameters : p_fin_asset_id - Financial asset line id. (OKL fin asset top
--                                  line id
-- OUT Parameters :
--                 x_cost                 FA current cost
--                 x_adj_cost             FA adjusted cost
--                 x_original_cost        FA original cost
--                 x_salvage_value        FA salvage value
--                 x_recoverable_cost     FA recoverable cost
--                 x_adj_recoverable_cost FA adjusted recoverable cost
--End of comments
--------------------------------------------------------------------------------
Procedure convert_fa_amounts
                  (p_api_version          IN  NUMBER,
                   p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                   x_return_status        OUT NOCOPY VARCHAR2,
                   x_msg_count            OUT NOCOPY NUMBER,
                   x_msg_data             OUT NOCOPY VARCHAR2,
                   p_fin_ast_id           IN  NUMBER,
                   x_cost                 OUT NOCOPY NUMBER,
                   x_adj_cost             OUT NOCOPY NUMBER,
                   x_original_cost        OUT NOCOPY NUMBER,
                   x_salvage_value        OUT NOCOPY NUMBER,
                   x_recoverable_cost     OUT NOCOPY NUMBER,
                   x_adj_recoverable_cost OUT NOCOPY NUMBER);
--------------------------------------------------------------------------------
--start of comments
-- Description : This api takes the OKL finacial asset line id, asset cost and salvage value in
--               contract currency as input and
--               returns cost and salvage value amounts in functional currency
-- IN Parameters : p_fin_asset_id    - Financial asset line id. (OKL fin asset top
--                                     line id
--                 p_k_cost          - contract cost in contract currency
--                 p_k_salvage_value - contract salvage value in contract currency
-- OUT Parameters :
--                 x_fa_cost                 FA current cost in functional currency
--                 x_fa_salvage_value        FA salvage value in functional currency
--End of comments
--------------------------------------------------------------------------------
Procedure convert_okl_amounts
                   (p_api_version          IN  NUMBER,
                    p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                    x_return_status        OUT NOCOPY VARCHAR2,
                    x_msg_count            OUT NOCOPY NUMBER,
                    x_msg_data             OUT NOCOPY VARCHAR2,
                    p_fin_ast_id           IN  NUMBER,
                    p_okl_cost               IN  NUMBER Default Null,
                    p_okl_salvage_value      IN  NUMBER Default Null,
                    x_fa_cost              OUT NOCOPY NUMBER,
                    x_fa_salvage_value     OUT NOCOPY NUMBER);
end okl_fa_amounts_pvt;

 

/
