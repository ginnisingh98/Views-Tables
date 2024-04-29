--------------------------------------------------------
--  DDL for Package Body OKL_TXD_QTE_ANTCPT_BILL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TXD_QTE_ANTCPT_BILL_PUB" AS
/* $Header: OKLPQABB.pls 120.1 2005/10/30 04:01:48 appldev noship $ */

 PROCEDURE create_txd_qte_ant_bill(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_qabv_rec                     IN  qabv_rec_type
    ,x_qabv_rec                     OUT  NOCOPY qabv_rec_type) IS

    l_api_version            NUMBER ;
    l_init_msg_list          VARCHAR2(3);
    l_return_status          VARCHAR2(3) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    lp_qabv_rec              qabv_rec_type;
    lx_qabv_rec              qabv_rec_type;

  BEGIN
    SAVEPOINT create_txd_qte_ant_bill;

    l_api_version   := p_api_version;
    l_init_msg_list := p_init_msg_list;
    l_msg_count     := x_msg_count;
    l_msg_data      := x_msg_data;
    lp_qabv_rec     := p_qabv_rec;
    lx_qabv_rec     := x_qabv_rec;

    okl_qab_pvt.insert_row( p_api_version    => l_api_version
                           ,p_init_msg_list  => l_init_msg_list
                           ,x_return_status  => l_return_status
                           ,x_msg_count      => l_msg_count
                           ,x_msg_data       => l_msg_data
                           ,p_qabv_rec       => lp_qabv_rec
                           ,x_qabv_rec       => lx_qabv_rec);

    IF (l_return_status = FND_API.G_RET_STS_ERROR)  THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Assign value to OUT variables
    x_qabv_rec      := lx_qabv_rec;
    x_return_status := l_return_status ;
    x_msg_count     := l_msg_count ;
    x_msg_data      := l_msg_data ;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_txd_qte_ant_bill;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_txd_qte_ant_bill;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_txd_qte_ant_bill;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TXD_QTE_ANTCPT_BILL_PUB','create_txd_qte_ant_bill');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END create_txd_qte_ant_bill;

 PROCEDURE create_txd_qte_ant_bill(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_qabv_tbl                     IN  qabv_tbl_type
    ,x_qabv_tbl                     OUT  NOCOPY qabv_tbl_type) IS

    l_api_version            NUMBER ;
    l_init_msg_list          VARCHAR2(3);
    l_return_status          VARCHAR2(3) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    lp_qabv_tbl              qabv_tbl_type;
    lx_qabv_tbl              qabv_tbl_type;

  BEGIN
    SAVEPOINT create_txd_qte_ant_bill;

    l_api_version   := p_api_version;
    l_init_msg_list := p_init_msg_list;
    l_msg_count     := x_msg_count;
    l_msg_data      := x_msg_data;
    lp_qabv_tbl     := p_qabv_tbl;
    lx_qabv_tbl     := x_qabv_tbl;

    okl_qab_pvt.insert_row( p_api_version    => l_api_version
                           ,p_init_msg_list  => l_init_msg_list
                           ,x_return_status  => l_return_status
                           ,x_msg_count      => l_msg_count
                           ,x_msg_data       => l_msg_data
                           ,p_qabv_tbl       => lp_qabv_tbl
                           ,x_qabv_tbl       => lx_qabv_tbl);

    IF (l_return_status = FND_API.G_RET_STS_ERROR)  THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Assign value to OUT variables
    x_qabv_tbl      := lx_qabv_tbl;
    x_return_status := l_return_status ;
    x_msg_count     := l_msg_count ;
    x_msg_data      := l_msg_data ;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_txd_qte_ant_bill;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_txd_qte_ant_bill;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_txd_qte_ant_bill;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TXD_QTE_ANTCPT_BILL_PUB','create_txd_qte_ant_bill');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END create_txd_qte_ant_bill;

 PROCEDURE update_txd_qte_ant_bill(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_qabv_rec                     IN  qabv_rec_type
    ,x_qabv_rec                     OUT  NOCOPY qabv_rec_type) IS

    l_api_version            NUMBER ;
    l_init_msg_list          VARCHAR2(3);
    l_return_status          VARCHAR2(3) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    lp_qabv_rec              qabv_rec_type;
    lx_qabv_rec              qabv_rec_type;

  BEGIN
    SAVEPOINT update_txd_qte_ant_bill;

    l_api_version   := p_api_version;
    l_init_msg_list := p_init_msg_list;
    l_msg_count     := x_msg_count;
    l_msg_data      := x_msg_data;
    lp_qabv_rec     := p_qabv_rec;
    lx_qabv_rec     := x_qabv_rec;

    okl_qab_pvt.update_row( p_api_version    => l_api_version
                           ,p_init_msg_list  => l_init_msg_list
                           ,x_return_status  => l_return_status
                           ,x_msg_count      => l_msg_count
                           ,x_msg_data       => l_msg_data
                           ,p_qabv_rec       => lp_qabv_rec
                           ,x_qabv_rec       => lx_qabv_rec);

    IF (l_return_status = FND_API.G_RET_STS_ERROR)  THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Assign value to OUT variables
    x_qabv_rec      := lx_qabv_rec;
    x_return_status := l_return_status ;
    x_msg_count     := l_msg_count ;
    x_msg_data      := l_msg_data ;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_txd_qte_ant_bill;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_txd_qte_ant_bill;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO update_txd_qte_ant_bill;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TXD_QTE_ANTCPT_BILL_PUB','update_txd_qte_ant_bill');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END update_txd_qte_ant_bill;

 PROCEDURE update_txd_qte_ant_bill(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_qabv_tbl                     IN  qabv_tbl_type
    ,x_qabv_tbl                     OUT  NOCOPY qabv_tbl_type) IS

    l_api_version            NUMBER ;
    l_init_msg_list          VARCHAR2(3);
    l_return_status          VARCHAR2(3) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    lp_qabv_tbl              qabv_tbl_type;
    lx_qabv_tbl              qabv_tbl_type;

  BEGIN
    SAVEPOINT update_txd_qte_ant_bill;

    l_api_version   := p_api_version;
    l_init_msg_list := p_init_msg_list;
    l_msg_count     := x_msg_count;
    l_msg_data      := x_msg_data;
    lp_qabv_tbl     := p_qabv_tbl;
    lx_qabv_tbl     := x_qabv_tbl;

    okl_qab_pvt.update_row( p_api_version    => l_api_version
                           ,p_init_msg_list  => l_init_msg_list
                           ,x_return_status  => l_return_status
                           ,x_msg_count      => l_msg_count
                           ,x_msg_data       => l_msg_data
                           ,p_qabv_tbl       => lp_qabv_tbl
                           ,x_qabv_tbl       => lx_qabv_tbl);

    IF (l_return_status = FND_API.G_RET_STS_ERROR)  THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Assign value to OUT variables
    x_qabv_tbl      := lx_qabv_tbl;
    x_return_status := l_return_status ;
    x_msg_count     := l_msg_count ;
    x_msg_data      := l_msg_data ;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_txd_qte_ant_bill;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_txd_qte_ant_bill;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO update_txd_qte_ant_bill;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TXD_QTE_ANTCPT_BILL_PUB','update_txd_qte_ant_bill');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END update_txd_qte_ant_bill;

 PROCEDURE lock_txd_qte_ant_bill(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_qabv_rec                     IN  qabv_rec_type) IS

    l_api_version            NUMBER ;
    l_init_msg_list          VARCHAR2(3);
    l_return_status          VARCHAR2(3) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    lp_qabv_rec              qabv_rec_type;


  BEGIN
    SAVEPOINT lock_txd_qte_ant_bill;

    l_api_version   := p_api_version;
    l_init_msg_list := p_init_msg_list;
    l_msg_count     := x_msg_count;
    l_msg_data      := x_msg_data;
    lp_qabv_rec     := p_qabv_rec;

    okl_qab_pvt.lock_row( p_api_version    => l_api_version
                           ,p_init_msg_list  => l_init_msg_list
                           ,x_return_status  => l_return_status
                           ,x_msg_count      => l_msg_count
                           ,x_msg_data       => l_msg_data
                           ,p_qabv_rec       => lp_qabv_rec);

    IF (l_return_status = FND_API.G_RET_STS_ERROR)  THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Assign value to OUT variables
    x_return_status := l_return_status ;
    x_msg_count     := l_msg_count ;
    x_msg_data      := l_msg_data ;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO lock_txd_qte_ant_bill;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_txd_qte_ant_bill;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO lock_txd_qte_ant_bill;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TXD_QTE_ANTCPT_BILL_PUB','lock_txd_qte_ant_bill');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END lock_txd_qte_ant_bill;

 PROCEDURE lock_txd_qte_ant_bill(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_qabv_tbl                     IN  qabv_tbl_type) IS

    l_api_version            NUMBER ;
    l_init_msg_list          VARCHAR2(3);
    l_return_status          VARCHAR2(3) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    lp_qabv_tbl              qabv_tbl_type;


  BEGIN
    SAVEPOINT lock_txd_qte_ant_bill;

    l_api_version   := p_api_version;
    l_init_msg_list := p_init_msg_list;
    l_msg_count     := x_msg_count;
    l_msg_data      := x_msg_data;
    lp_qabv_tbl     := p_qabv_tbl;

    okl_qab_pvt.lock_row( p_api_version    => l_api_version
                           ,p_init_msg_list  => l_init_msg_list
                           ,x_return_status  => l_return_status
                           ,x_msg_count      => l_msg_count
                           ,x_msg_data       => l_msg_data
                           ,p_qabv_tbl       => lp_qabv_tbl);

    IF (l_return_status = FND_API.G_RET_STS_ERROR)  THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Assign value to OUT variables
    x_return_status := l_return_status ;
    x_msg_count     := l_msg_count ;
    x_msg_data      := l_msg_data ;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO lock_txd_qte_ant_bill;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_txd_qte_ant_bill;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO lock_txd_qte_ant_bill;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TXD_QTE_ANTCPT_BILL_PUB','lock_txd_qte_ant_bill');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END lock_txd_qte_ant_bill;

 PROCEDURE delete_txd_qte_ant_bill(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_qabv_rec                     IN  qabv_rec_type) IS

    l_api_version            NUMBER ;
    l_init_msg_list          VARCHAR2(3);
    l_return_status          VARCHAR2(3) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    lp_qabv_rec              qabv_rec_type;


  BEGIN
    SAVEPOINT delete_txd_qte_ant_bill;

    l_api_version   := p_api_version;
    l_init_msg_list := p_init_msg_list;
    l_msg_count     := x_msg_count;
    l_msg_data      := x_msg_data;
    lp_qabv_rec     := p_qabv_rec;

    okl_qab_pvt.delete_row( p_api_version    => l_api_version
                           ,p_init_msg_list  => l_init_msg_list
                           ,x_return_status  => l_return_status
                           ,x_msg_count      => l_msg_count
                           ,x_msg_data       => l_msg_data
                           ,p_qabv_rec       => lp_qabv_rec);

    IF (l_return_status = FND_API.G_RET_STS_ERROR)  THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Assign value to OUT variables
    x_return_status := l_return_status ;
    x_msg_count     := l_msg_count ;
    x_msg_data      := l_msg_data ;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_txd_qte_ant_bill;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_txd_qte_ant_bill;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO delete_txd_qte_ant_bill;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TXD_QTE_ANTCPT_BILL_PUB','delete_txd_qte_ant_bill');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END delete_txd_qte_ant_bill;

 PROCEDURE delete_txd_qte_ant_bill(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_qabv_tbl                     IN  qabv_tbl_type) IS

    l_api_version            NUMBER ;
    l_init_msg_list          VARCHAR2(3);
    l_return_status          VARCHAR2(3) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    lp_qabv_tbl              qabv_tbl_type;


  BEGIN
    SAVEPOINT delete_txd_qte_ant_bill;

    l_api_version   := p_api_version;
    l_init_msg_list := p_init_msg_list;
    l_msg_count     := x_msg_count;
    l_msg_data      := x_msg_data;
    lp_qabv_tbl     := p_qabv_tbl;

    okl_qab_pvt.delete_row( p_api_version    => l_api_version
                           ,p_init_msg_list  => l_init_msg_list
                           ,x_return_status  => l_return_status
                           ,x_msg_count      => l_msg_count
                           ,x_msg_data       => l_msg_data
                           ,p_qabv_tbl       => lp_qabv_tbl);

    IF (l_return_status = FND_API.G_RET_STS_ERROR)  THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Assign value to OUT variables
    x_return_status := l_return_status ;
    x_msg_count     := l_msg_count ;
    x_msg_data      := l_msg_data ;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_txd_qte_ant_bill;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_txd_qte_ant_bill;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO delete_txd_qte_ant_bill;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TXD_QTE_ANTCPT_BILL_PUB','delete_txd_qte_ant_bill');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END delete_txd_qte_ant_bill;

 PROCEDURE validate_txd_qte_ant_bill(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_qabv_rec                     IN  qabv_rec_type) IS

    l_api_version            NUMBER ;
    l_init_msg_list          VARCHAR2(3);
    l_return_status          VARCHAR2(3) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    lp_qabv_rec              qabv_rec_type;


  BEGIN
    SAVEPOINT validate_txd_qte_ant_bill;

    l_api_version   := p_api_version;
    l_init_msg_list := p_init_msg_list;
    l_msg_count     := x_msg_count;
    l_msg_data      := x_msg_data;
    lp_qabv_rec     := p_qabv_rec;

    okl_qab_pvt.validate_row( p_api_version    => l_api_version
                           ,p_init_msg_list  => l_init_msg_list
                           ,x_return_status  => l_return_status
                           ,x_msg_count      => l_msg_count
                           ,x_msg_data       => l_msg_data
                           ,p_qabv_rec       => lp_qabv_rec);

    IF (l_return_status = FND_API.G_RET_STS_ERROR)  THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Assign value to OUT variables
    x_return_status := l_return_status ;
    x_msg_count     := l_msg_count ;
    x_msg_data      := l_msg_data ;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO validate_txd_qte_ant_bill;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_txd_qte_ant_bill;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO validate_txd_qte_ant_bill;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TXD_QTE_ANTCPT_BILL_PUB','validate_txd_qte_ant_bill');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END validate_txd_qte_ant_bill;

 PROCEDURE validate_txd_qte_ant_bill(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_qabv_tbl                     IN  qabv_tbl_type) IS

    l_api_version            NUMBER ;
    l_init_msg_list          VARCHAR2(3);
    l_return_status          VARCHAR2(3) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    lp_qabv_tbl              qabv_tbl_type;


  BEGIN
    SAVEPOINT validate_txd_qte_ant_bill;

    l_api_version   := p_api_version;
    l_init_msg_list := p_init_msg_list;
    l_msg_count     := x_msg_count;
    l_msg_data      := x_msg_data;
    lp_qabv_tbl     := p_qabv_tbl;

    okl_qab_pvt.validate_row( p_api_version    => l_api_version
                           ,p_init_msg_list  => l_init_msg_list
                           ,x_return_status  => l_return_status
                           ,x_msg_count      => l_msg_count
                           ,x_msg_data       => l_msg_data
                           ,p_qabv_tbl       => lp_qabv_tbl);

    IF (l_return_status = FND_API.G_RET_STS_ERROR)  THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    --Assign value to OUT variables
    x_return_status := l_return_status ;
    x_msg_count     := l_msg_count ;
    x_msg_data      := l_msg_data ;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO validate_txd_qte_ant_bill;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_txd_qte_ant_bill;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO validate_txd_qte_ant_bill;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TXD_QTE_ANTCPT_BILL_PUB','validate_txd_qte_ant_bill');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END validate_txd_qte_ant_bill;

END OKL_TXD_QTE_ANTCPT_BILL_PUB;

/
