--------------------------------------------------------
--  DDL for Package Body OKL_REVERSE_CONTRACT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_REVERSE_CONTRACT_PUB" AS
/* $Header: OKLPRVKB.pls 115.4 2002/12/02 04:49:51 arajagop noship $ */

PROCEDURE Reverse_Contract (p_api_version         IN   NUMBER,
                            p_init_msg_list       IN   VARCHAR2,
                            x_return_status       OUT  NOCOPY VARCHAR2,
                            x_msg_count           OUT  NOCOPY NUMBER,
                            x_msg_data            OUT  NOCOPY VARCHAR2,
                            p_contract_id         IN   NUMBER,
                            p_transaction_date    IN   DATE )

IS
  l_api_version       CONSTANT NUMBER        := 1.0;
  l_api_name          CONSTANT VARCHAR2(30)  := 'REVERSE_CONTRACT';
  l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;


BEGIN
  SAVEPOINT REVERSE_CONTRACT;
  x_return_status    := G_RET_STS_SUCCESS;

  -- customer pre-processing




-- Run the MAIN Procedure


  OKL_REVERSE_CONTRACT_PVT.REVERSE_CONTRACT(p_api_version      => l_api_version,
                                            p_init_msg_list    => p_init_msg_list,
                                            x_return_status    => x_return_status,
                                            x_msg_count        => x_msg_count,
                                            x_msg_data         => x_msg_data,
					    p_contract_id      => p_contract_id,
				            p_transaction_date => p_transaction_date);



       IF l_return_status = G_RET_STS_ERROR THEN
          RAISE G_EXCEPTION_ERROR;
       ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;






EXCEPTION

  WHEN G_EXCEPTION_ERROR THEN
      ROLLBACK TO REVERSE_CONTRACT;
      x_return_status := G_RET_STS_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      ROLLBACK TO REVERSE_CONTRACT;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN
      ROLLBACK TO REVERSE_CONTRACT;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_REVERSE_CONTRACT_PUB','REVERSE_CONTRACT');
      FND_MSG_PUB.Count_and_get(p_encoded => G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

END Reverse_Contract;


END OKL_REVERSE_CONTRACT_PUB;

/
