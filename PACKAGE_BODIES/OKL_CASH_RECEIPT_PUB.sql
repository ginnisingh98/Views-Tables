--------------------------------------------------------
--  DDL for Package Body OKL_CASH_RECEIPT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CASH_RECEIPT_PUB" AS
/* $Header: OKLPRTCB.pls 115.8 2004/04/13 11:03:09 rnaik noship $ */

  PROCEDURE CASH_RECEIPT_PUB( p_api_version      IN  NUMBER   := 1.0
                             ,p_init_msg_list    IN  VARCHAR2 := OKC_API.G_FALSE
                             ,x_return_status    OUT NOCOPY  VARCHAR2
                             ,x_msg_count        OUT NOCOPY  NUMBER
                             ,x_msg_data         OUT NOCOPY  VARCHAR2
                             ,p_over_pay         IN  VARCHAR2
                             ,p_conc_proc        IN  VARCHAR2
                             ,p_xcrv_rec         IN  xcrv_rec_type
                             ,p_xcav_tbl         IN  xcav_tbl_type
                             ,x_cash_receipt_id  OUT NOCOPY NUMBER
                            ) IS

    lp_over_pay              VARCHAR2(1);
    lp_conc_proc             VARCHAR2(2);
    lp_xcrv_rec              xcrv_rec_type;
    lp_xcav_tbl              xcav_tbl_type;

    lx_over_pay              VARCHAR2(1);
    lx_conc_proc             VARCHAR2(2);
    lx_xcrv_rec              xcrv_rec_type;
    lx_xcav_tbl              xcav_tbl_type;

    l_cash_receipt_id       NUMBER;

    l_data                  VARCHAR2(100);
    l_api_name              CONSTANT VARCHAR2(30)  := 'okl_cash_receipt_pub';
    l_count                 NUMBER ;
    l_return_status         VARCHAR2(1)    := FND_API.G_RET_STS_SUCCESS;

    l_api_version 			NUMBER ;
    l_init_msg_list 		VARCHAR2(1) ;
    l_msg_count 			NUMBER ;
    l_msg_data 				VARCHAR2(2000);

  BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SAVEPOINT cash_receipt_pub;

    lp_over_pay  := p_over_pay;
    lp_conc_proc := p_conc_proc;
    lp_xcrv_rec  := p_xcrv_rec;
    lp_xcav_tbl  := p_xcav_tbl;



    lp_over_pay  := lx_over_pay;
    lp_conc_proc := lx_conc_proc;
    lp_xcrv_rec  := lx_xcrv_rec;
    lp_xcav_tbl  := lx_xcav_tbl;


    lp_over_pay := lx_over_pay;
    lp_xcrv_rec := lx_xcrv_rec;
    lp_xcav_tbl := lx_xcav_tbl;

    okl_cash_receipt.CASH_RECEIPT (p_api_version      => l_api_version
                                     ,p_init_msg_list    => l_init_msg_list
                                     ,x_return_status    => l_return_status
                                     ,x_msg_count        => l_msg_count
                                     ,x_msg_data         => l_msg_data
                                     ,p_over_pay         => lp_over_pay
                                     ,p_conc_proc        => lp_conc_proc
                                     ,p_xcrv_rec         => lp_xcrv_rec
                                     ,p_xcav_tbl         => lp_xcav_tbl
                                     ,x_cash_receipt_id  => l_cash_receipt_id
                                     );

   IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
   ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   EXCEPTION

   WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      ROLLBACK TO cash_receipt_pub;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
--      Fnd_Msg_Pub.count_and_get(
--             p_count   => x_msg_count
--            ,p_data    => x_msg_data);

    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      ROLLBACK TO cash_receipt_pub;
      x_return_status :=  Okl_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
--      Fnd_Msg_Pub.count_and_get(
--             p_count   => x_msg_count
--            ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO cash_receipt_pub;
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_CASH_RECEIPT_PUB','unknown exception');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

  END cash_receipt_pub;

END OKL_CASH_RECEIPT_PUB;

/
