--------------------------------------------------------
--  DDL for Package Body OKL_LOSS_PROV_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LOSS_PROV_PUB" as
/* $Header: OKLPLPVB.pls 120.2 2005/10/30 04:25:51 appldev noship $ */

  -- this function is used to calculate capital balance for a contract and deal type
  FUNCTION calculate_capital_balance (
        p_cntrct_id       IN  NUMBER
       ,p_deal_type       IN  VARCHAR2) RETURN NUMBER
  IS
  l_capital_balance        NUMBER;

  BEGIN

    l_capital_balance := okl_loss_prov_pvt.calculate_capital_balance (p_cntrct_id, p_deal_type);

    /* return the calculated net book value */
    RETURN(l_capital_balance);

  EXCEPTION
     WHEN OTHERS THEN
      /* return null because of error */
      RETURN(NULL);

  END calculate_capital_balance;

  -- this function is used to calculate total reserve amt for a contract
  FUNCTION calculate_cntrct_rsrv_amt (
        p_cntrct_id       IN  NUMBER) RETURN NUMBER
  IS
  l_rsrv_amt               NUMBER;

  BEGIN

    l_rsrv_amt := okl_loss_prov_pvt.calculate_cntrct_rsrv_amt(p_cntrct_id);

    /* return the calculated net book value */
    RETURN(l_rsrv_amt);

  EXCEPTION
     WHEN OTHERS THEN

      /* return null because of error */
      RETURN(NULL);

  END calculate_cntrct_rsrv_amt;


   -- this function is used to calculate general loss provision and create a transaction
  FUNCTION SUBMIT_GENERAL_LOSS(
    p_api_version IN NUMBER,
    p_init_msg_list IN VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count OUT NOCOPY NUMBER,
    x_msg_data OUT NOCOPY VARCHAR2,
    p_glpv_rec IN glpv_rec_type) RETURN NUMBER
  IS

    l_request_id        NUMBER;
    l_return_status     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_api_name          CONSTANT VARCHAR2(30)  := 'SUBMIT_GENERAL_LOSS';
    l_glpv_rec          glpv_rec_type := p_glpv_rec;
  BEGIN
    x_return_status    := FND_API.G_RET_STS_SUCCESS;
       -- customer pre-processing



         -- CALL THE MAIN PROCEDURE
         l_request_id := okl_loss_prov_pvt.SUBMIT_GENERAL_LOSS(
	           x_return_status => l_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => x_msg_data,
               p_api_version => p_api_version,
               p_init_msg_list => p_init_msg_list,
               p_glpv_rec => p_glpv_rec);

            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              RAISE FND_API.G_EXC_ERROR;
            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

       -- customer post-processing


     RETURN l_request_id;

  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      RETURN l_request_id;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      RETURN l_request_id;

  WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_LOSS_PROV_PUB','SUBMIT_GENERAL_LOSS');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN l_request_id;

  END SUBMIT_GENERAL_LOSS;


   -- this procedure is used create a specific loss provision
  PROCEDURE SPECIFIC_LOSS_PROVISION (
              p_api_version          IN  NUMBER
             ,p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
             ,x_msg_count            OUT NOCOPY NUMBER
             ,x_msg_data             OUT NOCOPY VARCHAR2
             ,x_return_status        OUT NOCOPY VARCHAR2
             ,p_slpv_rec             IN slpv_rec_type)
  IS

    l_return_status     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_api_name          CONSTANT VARCHAR2(30)  := 'SPECIFIC_LOSS_PROVISION';
    l_slpv_rec          slpv_rec_type := p_slpv_rec;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

       -- customer pre-processing



         -- CALL THE MAIN PROCEDURE

          okl_loss_prov_pvt.SPECIFIC_LOSS_PROVISION(
              p_api_version          => p_api_version
             ,p_init_msg_list        => p_init_msg_list
             ,x_msg_count            => x_msg_count
             ,x_msg_data             => x_msg_data
             ,x_return_status        => x_return_status
             ,p_slpv_rec             => p_slpv_rec);

          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

       -- customer post-processing


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
      FND_MSG_PUB.ADD_EXC_MSG('OKL_LOSS_PROV_PUB','SPECIFIC_LOSS_PROVISION');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END SPECIFIC_LOSS_PROVISION;

  PROCEDURE SPECIFIC_LOSS_PROVISION (
              p_api_version          IN  NUMBER
             ,p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
             ,x_msg_count            OUT NOCOPY NUMBER
             ,x_msg_data             OUT NOCOPY VARCHAR2
             ,x_return_status        OUT NOCOPY VARCHAR2
             ,p_khr_id               IN  NUMBER
             ,p_reverse_flag         IN  VARCHAR2
             ,p_slpv_tbl             IN  slpv_tbl_type)
  IS

    l_return_status     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_api_name          CONSTANT VARCHAR2(30)  := 'SPECIFIC_LOSS_PROVISION';
    l_slpv_rec          slpv_rec_type;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    FOR x IN p_slpv_tbl.FIRST..p_slpv_tbl.LAST
    LOOP
      l_slpv_rec := NULL;

      l_slpv_rec.khr_id := p_khr_id;
      l_slpv_rec.sty_id := p_slpv_tbl(x).sty_id;
      l_slpv_rec.amount := p_slpv_tbl(x).amount;
      l_slpv_rec.description := p_slpv_tbl(x).description;
      l_slpv_rec.tax_deductible_local := p_slpv_tbl(x).tax_deductible_local;
      l_slpv_rec.tax_deductible_corporate := p_slpv_tbl(x).tax_deductible_corporate;
      l_slpv_rec.provision_date := p_slpv_tbl(x).provision_date;
      IF x = 1 THEN
        l_slpv_rec.reverse_flag := p_reverse_flag;
      ELSE
        l_slpv_rec.reverse_flag := NULL;
      END IF;

          okl_loss_prov_pvt.SPECIFIC_LOSS_PROVISION(
              p_api_version          => p_api_version
             ,p_init_msg_list        => p_init_msg_list
             ,x_msg_count            => x_msg_count
             ,x_msg_data             => x_msg_data
             ,x_return_status        => x_return_status
             ,p_slpv_rec             => l_slpv_rec);

          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

    END LOOP;


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
      FND_MSG_PUB.ADD_EXC_MSG('OKL_LOSS_PROV_PUB','SPECIFIC_LOSS_PROVISION');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END SPECIFIC_LOSS_PROVISION;

END OKL_LOSS_PROV_PUB;

/
