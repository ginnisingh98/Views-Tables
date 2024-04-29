--------------------------------------------------------
--  DDL for Package Body OKL_ACCOUNT_GENERATOR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACCOUNT_GENERATOR_PUB" AS
/* $Header: OKLPAGTB.pls 120.3 2005/10/30 04:20:54 appldev noship $ */

-- Changed by Santonyr on 22-Sep-2004 to fix bug 3901209.
-- Added a new parameter 'p_ae_tmpt_line_id'.
-- If Account Generator fails due to lack of sources, it picks up the
-- default account code for the passed account template line and returns.

-- Changed the signature for bug 4157521

FUNCTION GET_CCID
(
  p_api_version          	IN  NUMBER,
  p_init_msg_list        	IN  VARCHAR2,
  x_return_status        	OUT NOCOPY VARCHAR2,
  x_msg_count            	OUT NOCOPY NUMBER,
  x_msg_data             	OUT NOCOPY VARCHAR2,
  p_acc_gen_wf_sources_rec       IN  acc_gen_wf_sources_rec,
  p_ae_line_type		IN  okl_acc_gen_rules.ae_line_type%TYPE,
  p_primary_key_tbl    		IN  primary_key_tbl,
  p_ae_tmpt_line_id		IN NUMBER DEFAULT NULL
)
RETURN NUMBER
AS
  l_api_version   NUMBER := 1.0;
  l_api_name          CONSTANT VARCHAR2(30)  := 'OKL_ACCOUNT_GENERATOR';
  l_return_status     VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
  l_Code_Combination_Id		NUMBER := -1;

BEGIN
  SAVEPOINT ACCOUNT_GENERATOR;
  x_return_status    := FND_API.G_RET_STS_SUCCESS;
  -- customer pre-processing



-- Execute the Main Procedure

-- Changed the signature for bug 4157521

      l_Code_Combination_id := OKL_ACCOUNT_GENERATOR_PVT.GET_CCID(p_api_version 	  	  => l_api_version,
                                         p_init_msg_list 	  => p_init_msg_list,
                                         x_return_status 	  => x_return_status,
					 x_msg_count 		  => x_msg_count,
   	   	                         x_msg_data 		  => x_msg_data,
					 p_acc_gen_wf_sources_rec      => p_acc_gen_wf_sources_rec,
  	   	                         p_ae_line_type      	  => p_ae_line_type,
  	   	                         p_primary_key_tbl 	  => p_primary_key_tbl,
  	   	                         p_ae_tmpt_line_id	  => p_ae_tmpt_line_id);


  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;




  RETURN l_Code_Combination_id;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO ACCOUNT_GENERATOR;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      RETURN l_Code_Combination_id;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO ACCOUNT_GENERATOR;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      RETURN l_Code_Combination_id;
  WHEN OTHERS THEN
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCOUNT_GENERATOR_PUB','GET_CCID');
      FND_MSG_PUB.Count_and_get(p_encoded => OKL_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RETURN l_Code_Combination_id;
END GET_CCID;


END OKL_ACCOUNT_GENERATOR_PUB;

/
