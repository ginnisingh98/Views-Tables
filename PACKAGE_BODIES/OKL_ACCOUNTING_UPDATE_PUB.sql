--------------------------------------------------------
--  DDL for Package Body OKL_ACCOUNTING_UPDATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ACCOUNTING_UPDATE_PUB" AS
/* $Header: OKLPAEUB.pls 115.2 2002/12/18 12:09:15 kjinger noship $ */

PROCEDURE  UPDATE_ACCT_ENTRIES(p_api_version        IN       NUMBER,
                               p_init_msg_list      IN       VARCHAR2,
                               x_return_status      OUT      NOCOPY VARCHAR2,
                               x_msg_count          OUT      NOCOPY NUMBER,
                               x_msg_data           OUT      NOCOPY VARCHAR2,
                               p_aelv_rec           IN       aelv_rec_type,
                               x_aelv_rec           OUT      NOCOPY aelv_rec_type)

IS
  l_api_version       CONSTANT NUMBER        := 1.0;
  l_api_name          CONSTANT VARCHAR2(30)  := 'UPDATE_ACCT_ENTRIES';
  l_return_status     VARCHAR2(1) := G_RET_STS_SUCCESS;
  l_aelv_rec	      aelv_rec_type := p_aelv_rec;


BEGIN
  SAVEPOINT UPDATE_ACCT_ENTRIES;
  x_return_status    := G_RET_STS_SUCCESS;

  -- customer pre-processing




-- Run the MAIN Procedure



  OKL_ACCOUNTING_UPDATE_PVT.UPDATE_ACCT_ENTRIES(p_api_version      => l_api_version,
                                            p_init_msg_list    => p_init_msg_list,
                                            x_return_status    => l_return_status,
                                            x_msg_count        => x_msg_count,
                                            x_msg_data         => x_msg_data,
					   p_aelv_rec         => l_aelv_rec,
				           x_aelv_rec         => x_aelv_rec);



       IF l_return_status = G_RET_STS_ERROR THEN
          RAISE G_EXCEPTION_ERROR;
       ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE G_EXCEPTION_UNEXPECTED_ERROR;
       END IF;






EXCEPTION

  WHEN G_EXCEPTION_ERROR THEN
      ROLLBACK TO UPDATE_ACCT_ENTRIES;
      x_return_status := G_RET_STS_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_ACCT_ENTRIES;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_and_get(p_encoded => G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN
      ROLLBACK TO UPDATE_ACCT_ENTRIES;
      x_return_status := G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_ACCOUNTING_UPDATE_PUB','UPDATE_ACCT_ENTRIES');
      FND_MSG_PUB.Count_and_get(p_encoded => G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

END UPDATE_ACCT_ENTRIES;


END OKL_ACCOUNTING_UPDATE_PUB;

/
