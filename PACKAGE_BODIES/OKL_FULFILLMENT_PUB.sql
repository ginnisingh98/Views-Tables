--------------------------------------------------------
--  DDL for Package Body OKL_FULFILLMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_FULFILLMENT_PUB" AS
/* $Header: OKLPFULB.pls 115.11 2004/04/13 10:46:32 rnaik noship $ */


  PROCEDURE create_fulfillment (p_api_version   IN  NUMBER,
                                p_init_msg_list IN  VARCHAR2,
                                p_agent_id      IN  NUMBER,
                                p_server_id     IN  NUMBER DEFAULT NULL,
                                p_content_id    IN  NUMBER,
                                p_from          IN  VARCHAR2,
                                p_subject       IN  VARCHAR2,
                                p_email         IN  VARCHAR2,
                                p_bind_var      IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
                                p_bind_val      IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
                                p_bind_var_type IN  JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE,
                                p_commit        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                x_request_id    OUT NOCOPY NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_count     OUT NOCOPY NUMBER,
                                x_msg_data      OUT NOCOPY VARCHAR2) IS

    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);

    l_request_id             NUMBER;


  BEGIN

  --  SAVEPOINT create_fulfillment;






  ------------ Call to Private Process API--------------

    okl_fulfillment_pvt.create_fulfillment (p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            p_agent_id      => p_agent_id,
                                            p_server_id     => p_server_id,
                                            p_content_id    => p_content_id,
                                            p_from          => p_from,
                                            p_subject       => p_subject,
                                            p_email         => p_email,
                                            p_bind_var      => p_bind_var,
                                            p_bind_val      => p_bind_val,
                                            p_bind_var_type => p_bind_var_type,
                                            p_commit        => p_commit,
                                            x_request_id    => x_request_id,
                                            x_return_status => l_return_status,
                                            x_msg_count     => l_msg_count,
                                            x_msg_data      => l_msg_data);

    IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

  ------------ End Call to Private Process API--------------







  x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
--      ROLLBACK TO create_fulfillment;
      x_return_status := OKL_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                p_data   => x_msg_data);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
 --     ROLLBACK TO create_fulfillment;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                p_data    => x_msg_data);

    WHEN OTHERS THEN
  --    ROLLBACK TO create_fulfillment;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_FULFILLMENT_PUB','create_fulfillment');
      FND_MSG_PUB.count_and_get(p_count   => x_msg_count,
                                p_data    => x_msg_data);

  END create_fulfillment;

END okl_fulfillment_pub;

/
