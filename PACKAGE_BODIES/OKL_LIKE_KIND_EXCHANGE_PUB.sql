--------------------------------------------------------
--  DDL for Package Body OKL_LIKE_KIND_EXCHANGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LIKE_KIND_EXCHANGE_PUB" AS
/* $Header: OKLPLKXB.pls 115.2 2002/12/18 12:23:51 kjinger noship $ */

  -- Function to retrieve total match amount
  FUNCTION GET_TOTAL_MATCH_AMT(p_asset_id IN NUMBER,
                               p_tax_book IN VARCHAR2) RETURN NUMBER IS
  l_total_match_amount NUMBER;

  BEGIN

    l_total_match_amount := OKL_LIKE_KIND_EXCHANGE_PVT.GET_TOTAL_MATCH_AMT (p_asset_id, p_tax_book);

    RETURN(l_total_match_amount);

  EXCEPTION
     WHEN OTHERS THEN
      /* return null because of error */
      RETURN(NULL);

  END GET_TOTAL_MATCH_AMT;

  -- Function to retrieve balance sale proceeds
  FUNCTION GET_BALANCE_SALE_PROCEEDS (p_asset_id IN NUMBER,
                                    p_tax_book IN VARCHAR2) RETURN NUMBER
  IS
  l_bal_sale_proceeds               NUMBER;

  BEGIN

    l_bal_sale_proceeds := OKL_LIKE_KIND_EXCHANGE_PVT.GET_BALANCE_SALE_PROCEEDS (p_asset_id, p_tax_book);

    RETURN(l_bal_sale_proceeds);

  EXCEPTION
     WHEN OTHERS THEN

      /* return null because of error */
      RETURN(NULL);

  END GET_BALANCE_SALE_PROCEEDS;


  -- Function to retrieve deferred gain
  FUNCTION GET_DEFERRED_GAIN (p_asset_id IN VARCHAR2,
                            p_tax_book IN VARCHAR2) RETURN NUMBER
  IS
  l_deferred_gain               NUMBER;

  BEGIN

    l_deferred_gain := OKL_LIKE_KIND_EXCHANGE_PVT.GET_DEFERRED_GAIN(p_asset_id, p_tax_book);

    RETURN(l_deferred_gain);

  EXCEPTION
     WHEN OTHERS THEN

      /* return null because of error */
      RETURN(NULL);

  END GET_DEFERRED_GAIN;

 PROCEDURE CREATE_LIKE_KIND_EXCHANGE(
              p_api_version          IN  NUMBER
             ,p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
             ,x_return_status        OUT NOCOPY VARCHAR2
             ,x_msg_count            OUT NOCOPY NUMBER
             ,x_msg_data             OUT NOCOPY VARCHAR2
             ,p_corporate_book       IN  VARCHAR2
             ,p_tax_book             IN  VARCHAR2
             ,p_comments             IN  VARCHAR2
			 ,p_rep_asset_rec        IN  rep_asset_rec_type
             ,p_req_asset_tbl        IN  req_asset_tbl_type)
  IS

    l_return_status     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_api_name          CONSTANT VARCHAR2(30)  := 'CREATE_LIKE_KIND_EXCHANGE';

  BEGIN
    l_return_status    := FND_API.G_RET_STS_SUCCESS;

       -- customer pre-processing



         -- CALL THE MAIN PROCEDURE
         OKL_LIKE_KIND_EXCHANGE_PVT.CREATE_LIKE_KIND_EXCHANGE(
              p_api_version          => p_api_version
             ,p_init_msg_list        => p_init_msg_list
             ,x_return_status        => x_return_status
             ,x_msg_count            => x_msg_count
             ,x_msg_data             => x_msg_data
             ,p_corporate_book       => p_corporate_book
             ,p_tax_book             => p_tax_book
             ,p_comments             => p_comments
			 ,p_rep_asset_rec        => p_rep_asset_rec
             ,p_req_asset_tbl        => p_req_asset_tbl);

            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

       -- customer post-processing


       x_return_status := l_return_status;

  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_LIKE_KIND_EXCHANGE_PUB','CREATE_LIKE_KIND_EXCHANGE');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END CREATE_LIKE_KIND_EXCHANGE;


End OKL_LIKE_KIND_EXCHANGE_PUB;

/
