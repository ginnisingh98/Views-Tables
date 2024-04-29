--------------------------------------------------------
--  DDL for Package Body OKL_BPD_CAP_ADV_MON_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BPD_CAP_ADV_MON_PUB" AS
 /* $Header: OKLPAMSB.pls 120.1 2005/10/30 04:01:19 appldev noship $ */
---------------------------------------------------------------------------
-- PROCEDURE handle_advanced_manual_pay
---------------------------------------------------------------------------
---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : handle_advanced_manual_pay
  -- Description     : procedure for inserting the records in
  --                   table OKL_TRX_CSH_RECEIPT_B and OKL_EXT_CSH_RCPTS_B
  -- Business Rules  :
  -- Parameters      : p_api_version, p_init_msg_list, x_return_status,
  --                   x_msg_count, x_msg_data, p_adv_rcpt_rec, x_adv_rcpt_rec.
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
PROCEDURE handle_advanced_manual_pay ( p_api_version		        IN  NUMBER,
  				                                 p_init_msg_list	       IN  VARCHAR2 DEFAULT Okc_Api.G_FALSE,
					                                  x_return_status	       OUT NOCOPY VARCHAR2,
				                                   x_msg_count		          OUT NOCOPY NUMBER,
				                                   x_msg_data	            OUT NOCOPY VARCHAR2,
                                       p_adv_rcpt_rec	        IN adv_rcpt_rec,
					                                  x_adv_rcpt_rec         OUT NOCOPY adv_rcpt_rec ) IS


   l_return_status  VARCHAR2(1)  DEFAULT FND_API.G_RET_STS_SUCCESS;
   lp_adv_rcpt_rec  adv_rcpt_rec DEFAULT p_adv_rcpt_rec;

BEGIN
  SAVEPOINT save_handle_adv_man_pay;

 -- procedure is used to write the receipt details in the internal and external transaction tables.

 OKL_BPD_CAP_ADV_MON_PVT.handle_advanced_manual_pay ( p_api_version		     => p_api_version,
  				                                                p_init_msg_list     => p_init_msg_list,
					                                                 x_return_status	    => x_return_status,
				                                                  x_msg_count		       => x_msg_count,
				                                                  x_msg_data	         => x_msg_count,
                                                      p_adv_rcpt_rec	     => lp_adv_rcpt_rec,
					                                                 x_adv_rcpt_rec      => x_adv_rcpt_rec
                                                    );

   IF    l_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO save_handle_adv_man_pay;
       x_return_status := FND_API.G_RET_STS_ERROR;

      FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO save_handle_adv_man_pay;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                                ,p_count   => x_msg_count
                                ,p_data    => x_msg_data);

    WHEN OTHERS THEN
       ROLLBACK TO save_handle_adv_man_pay;
       FND_MSG_PUB.ADD_EXC_MSG('OKL_ACC_GROUP_PUB','create_acc_group');
 -- store SQL error message on message stack for caller
       FND_MSG_PUB.Count_and_get(p_encoded => OKC_API.G_FALSE
                                ,p_count   => x_msg_count
                                ,p_data    => x_msg_data);
  -- notify caller of an UNEXPECTED error
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END handle_advanced_manual_pay;
END okl_bpd_cap_adv_mon_pub;

/
