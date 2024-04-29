--------------------------------------------------------
--  DDL for Package Body OKL_CNTR_GRP_BILLING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CNTR_GRP_BILLING_PUB" AS
/* $Header: OKLPCLBB.pls 115.6 2004/04/13 10:37:58 rnaik noship $ */
-- Start of wraper code generated automatically by Debug code generator
  L_MODULE VARCHAR2(40) := 'LEASE.RECEIVABLES.COUNTER';
  L_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  L_LEVEL_PROCEDURE NUMBER;
  IS_DEBUG_PROCEDURE_ON BOOLEAN;
-- End of wraper code generated automatically by Debug code generator


  PROCEDURE calculate_cntgrp_bill_amt(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_cntr_bill_tbl                     IN  cntr_bill_tbl_type
    ,x_cntr_bill_tbl                     OUT  NOCOPY cntr_bill_tbl_type
    ) IS

l_return_status      VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
l_api_version        NUMBER ;
l_init_msg_list      VARCHAR2(1) ;
l_msg_data           VARCHAR2(2000);
l_msg_count          NUMBER ;
lp_cntr_bill_tbl          cntr_bill_tbl_type;
lx_cntr_bill_tbl          cntr_bill_tbl_type;

  BEGIN






SAVEPOINT calculate_cntgrp_bill_amt_rec;

    l_api_version := p_api_version ;
    l_init_msg_list := p_init_msg_list ;
    l_msg_data :=  x_msg_data;
    l_msg_count := x_msg_count ;
    lp_cntr_bill_tbl :=  p_cntr_bill_tbl;
    lx_cntr_bill_tbl :=  p_cntr_bill_tbl;


-- Start of wraper code generated automatically by Debug code generator for OKL_CNTR_GRP_BILLING_PVT.counter_grp_billing_calc
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPCLBB.pls call OKL_CNTR_GRP_BILLING_PVT.counter_grp_billing_calc ');
    END;
  END IF;
    OKL_CNTR_GRP_BILLING_PVT.counter_grp_billing_calc(
     p_api_version                  => l_api_version
    ,p_init_msg_list                => l_init_msg_list
    ,x_return_status                => l_return_status
    ,x_msg_count                    => l_msg_count
    ,x_msg_data                     => l_msg_data
	,p_cntr_bill_tbl                => lp_cntr_bill_tbl
    ,x_cntr_bill_tbl                => lx_cntr_bill_tbl);
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPCLBB.pls call OKL_CNTR_GRP_BILLING_PVT.counter_grp_billing_calc ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_CNTR_GRP_BILLING_PVT.counter_grp_billing_calc

x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
x_cntr_bill_tbl :=  lx_cntr_bill_tbl;




EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO calculate_cntgrp_bill_amt_rec;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO calculate_cntgrp_bill_amt_rec;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
    WHEN OTHERS THEN
      ROLLBACK TO calculate_cntgrp_bill_amt_rec;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;


  END;

  PROCEDURE calculate_cntgrp_bill_amt(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_cntr_bill_rec                     IN  cntr_bill_rec_type
    ,x_cntr_bill_rec                     OUT  NOCOPY cntr_bill_rec_type) IS
  BEGIN
    NULL ;
  END;

 PROCEDURE insert_cntr_grp_bill(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_cntr_bill_tbl                     IN  cntr_bill_tbl_type
    ,x_cntr_bill_tbl                     OUT  NOCOPY cntr_bill_tbl_type
    ) IS

    l_return_status      VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_api_version        NUMBER ;
    l_init_msg_list      VARCHAR2(1) ;
    l_msg_data           VARCHAR2(2000);
    l_msg_count          NUMBER ;
    lp_cntr_bill_tbl          cntr_bill_tbl_type;
    lx_cntr_bill_tbl          cntr_bill_tbl_type;

  BEGIN






SAVEPOINT insert_cntr_grp_bill_rec;

    l_api_version := p_api_version ;
    l_init_msg_list := p_init_msg_list ;
    l_msg_data :=  x_msg_data;
    l_msg_count := x_msg_count ;
    lp_cntr_bill_tbl :=  p_cntr_bill_tbl;
    lx_cntr_bill_tbl :=  p_cntr_bill_tbl;

-- Start of wraper code generated automatically by Debug code generator for OKL_CNTR_GRP_BILLING_PVT.counter_grp_billing_insert
  IF(L_DEBUG_ENABLED='Y') THEN
    L_LEVEL_PROCEDURE :=FND_LOG.LEVEL_PROCEDURE;
    IS_DEBUG_PROCEDURE_ON := OKL_DEBUG_PUB.Check_Log_On(L_MODULE, L_LEVEL_PROCEDURE);
  END IF;
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'Begin Debug OKLPCLBB.pls call OKL_CNTR_GRP_BILLING_PVT.counter_grp_billing_insert ');
    END;
  END IF;
    OKL_CNTR_GRP_BILLING_PVT.counter_grp_billing_insert(
        p_api_version         =>  l_api_version
       ,p_init_msg_list       =>  l_init_msg_list
       ,x_return_status       =>  l_return_status
       ,x_msg_count           =>  l_msg_count
       ,x_msg_data            =>  l_msg_data
	   ,p_cntr_bill_tbl       =>  lp_cntr_bill_tbl
       ,x_cntr_bill_tbl       =>  lx_cntr_bill_tbl
     );
  IF(IS_DEBUG_PROCEDURE_ON) THEN
    BEGIN
        OKL_DEBUG_PUB.LOG_DEBUG(L_LEVEL_PROCEDURE,L_MODULE,'End Debug OKLPCLBB.pls call OKL_CNTR_GRP_BILLING_PVT.counter_grp_billing_insert ');
    END;
  END IF;
-- End of wraper code generated automatically by Debug code generator for OKL_CNTR_GRP_BILLING_PVT.counter_grp_billing_insert

    x_return_status := l_return_status ;
    x_msg_count := l_msg_count ;
    x_msg_data := l_msg_data ;
    x_cntr_bill_tbl :=  lx_cntr_bill_tbl;




 EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO insert_cntr_grp_bill_rec;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO insert_cntr_grp_bill_rec;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
    WHEN OTHERS THEN
      ROLLBACK TO insert_cntr_grp_bill_rec;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;

  END insert_cntr_grp_bill;

 PROCEDURE insert_cntr_grp_bill(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_cntr_bill_rec                     IN  cntr_bill_rec_type
    ,x_cntr_bill_rec                     OUT  NOCOPY cntr_bill_rec_type)IS
  BEGIN
    NULL ;
  END;

end OKL_CNTR_GRP_BILLING_PUB;

/
