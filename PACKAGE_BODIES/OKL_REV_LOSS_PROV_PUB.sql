--------------------------------------------------------
--  DDL for Package Body OKL_REV_LOSS_PROV_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_REV_LOSS_PROV_PUB" AS
/* $Header: OKLPRPVB.pls 120.2 2005/10/30 03:34:26 appldev noship $ */

   -- this procedure reverses loss provision transactions
  PROCEDURE REVERSE_LOSS_PROVISIONS(
              p_api_version          IN  NUMBER
             ,p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
             ,x_msg_count            OUT NOCOPY NUMBER
             ,x_msg_data             OUT NOCOPY VARCHAR2
             ,x_return_status        OUT NOCOPY VARCHAR2
             ,p_lprv_rec             IN  lprv_rec_type)
  IS

    l_return_status     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_api_name          CONSTANT VARCHAR2(30)  := 'REVERSE_LOSS_PROVISIONS';
    l_lpvv_rec          lprv_rec_type := p_lprv_rec;
  BEGIN
    SAVEPOINT rev_loss_prov;

       -- customer pre-processing



         -- CALL THE MAIN PROCEDURE
         okl_rev_loss_prov_pvt.REVERSE_LOSS_PROVISIONS(
              p_api_version          => p_api_version
             ,p_init_msg_list        => p_init_msg_list
             ,x_msg_count            => x_msg_count
             ,x_msg_data             => x_msg_data
             ,x_return_status        => x_return_status
             ,p_lprv_rec              => l_lpvv_rec);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

	        -- customer post-processing


  EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
      ROLLBACK TO rev_loss_prov;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO rev_loss_prov;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

     WHEN OTHERS THEN
      ROLLBACK TO rev_loss_prov;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_REV_LOSS_PROV_PUB','REVERSE_LOSS_PROVISIONS');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END REVERSE_LOSS_PROVISIONS;

  PROCEDURE REVERSE_LOSS_PROVISIONS(
              p_api_version          IN  NUMBER
             ,p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
             ,x_msg_count            OUT NOCOPY NUMBER
             ,x_msg_data             OUT NOCOPY VARCHAR2
             ,x_return_status        OUT NOCOPY VARCHAR2
             ,p_lprv_tbl             IN  lprv_tbl_type)
  IS

    l_return_status     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_api_name          CONSTANT VARCHAR2(30)  := 'REVERSE_LOSS_PROVISIONS';
    l_lprv_tbl          lprv_tbl_type := p_lprv_tbl;
  BEGIN
    SAVEPOINT rev_loss_prov;

       -- customer pre-processing



         -- CALL THE MAIN PROCEDURE
         okl_rev_loss_prov_pvt.REVERSE_LOSS_PROVISIONS(
              p_api_version          => p_api_version
             ,p_init_msg_list        => p_init_msg_list
             ,x_msg_count            => x_msg_count
             ,x_msg_data             => x_msg_data
             ,x_return_status        => x_return_status
             ,p_lprv_tbl             => l_lprv_tbl);

     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

	        -- customer post-processing


  EXCEPTION
     WHEN OKL_API.G_EXCEPTION_ERROR THEN
      ROLLBACK TO rev_loss_prov;
      x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO rev_loss_prov;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

     WHEN OTHERS THEN
      ROLLBACK TO rev_loss_prov;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_REV_LOSS_PROV_PUB','REVERSE_LOSS_PROVISIONS');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END REVERSE_LOSS_PROVISIONS;

End OKL_REV_LOSS_PROV_PUB;

/
