--------------------------------------------------------
--  DDL for Package Body OKL_CURE_RECON_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CURE_RECON_PUB" AS
/* $Header: OKLPRCOB.pls 120.2 2006/08/11 10:46:51 gboomina noship $ */

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;



PROCEDURE UPDATE_CURE_INVOICE (
                               p_api_version   IN NUMBER,
                               p_init_msg_list IN VARCHAR2 DEFAULT fnd_api.G_FALSE,
                               p_commit        IN VARCHAR2 DEFAULT fnd_api.G_FALSE,
                               p_report_id     IN NUMBER,
                               p_invoice_date  IN DATE,
                               p_cam_tbl       IN cure_amount_tbl,
                               p_operation     IN VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count     OUT NOCOPY NUMBER,
                               x_msg_data      OUT NOCOPY VARCHAR2) IS
  l_return_status      VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_msg_count          NUMBER ;
  l_msg_data           VARCHAR2(2000);

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
        SAVEPOINT UPDATE_CURE_INVOICE;
        OKL_CURE_RECON_PVT.UPDATE_CURE_INVOICE(
                              p_api_version   =>p_api_version,
                              p_init_msg_list =>p_init_msg_list,
                              p_commit        => p_commit,
                              p_report_id     =>p_report_id,
                              p_invoice_date  =>p_invoice_date,
                              p_cam_tbl       =>p_cam_tbl,
                              p_operation     =>p_operation,
                              x_return_status => l_return_status,
                              x_msg_count     => l_msg_count,
                              x_msg_data      => l_msg_data );

           IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
 	            RAISE Fnd_Api.G_EXC_ERROR;
           ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	            RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
           ELSE
                  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL_CURE_RECON_PUB.UPDATE_CURE_INVOICE status is '
                                    ||l_return_status || 'operation was ' ||p_operation);
                  END IF;
                  x_return_status  :=l_return_status;
          END IF;

         FND_MSG_PUB.Count_And_Get
        (  p_count          =>   x_msg_count,
           p_data           =>   x_msg_data
         );

EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO UPDATE_CURE_INVOICE;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_CURE_INVOICE;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO UPDATE_CURE_INVOICE;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_CURE_RECON_PUB','UPDATE_CURE_INVOICE');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

 END UPDATE_CURE_INVOICE;

END OKL_CURE_RECON_PUB;


/
