--------------------------------------------------------
--  DDL for Package Body OKL_TXD_QTE_LN_DTLS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TXD_QTE_LN_DTLS_PUB" AS
/* $Header: OKLPTQDB.pls 115.0 2002/12/03 18:50:40 bakuchib noship $ */

 PROCEDURE create_txd_qte_ln_dtls(
     p_api_version                  IN  NUMBER
    ,p_init_msg_list                IN  VARCHAR2
    ,x_return_status                OUT  NOCOPY VARCHAR2
    ,x_msg_count                    OUT  NOCOPY NUMBER
    ,x_msg_data                     OUT  NOCOPY VARCHAR2
    ,p_tqdv_rec                     IN  tqdv_rec_type
    ,x_tqdv_rec                     OUT  NOCOPY tqdv_rec_type) IS

    l_api_version            NUMBER ;
    l_init_msg_list          VARCHAR2(3);
    l_return_status          VARCHAR2(3) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    lp_tqdv_rec              tqdv_rec_type;
    lx_tqdv_rec              tqdv_rec_type;
  BEGIN
    SAVEPOINT create_txd_qte_ln_dtls;

    l_api_version   := p_api_version;
    l_init_msg_list := p_init_msg_list;
    l_msg_count     := x_msg_count;
    l_msg_data      := x_msg_data;
    lp_tqdv_rec     := p_tqdv_rec;
    lx_tqdv_rec     := x_tqdv_rec;

    okl_tqd_pvt.insert_row(l_api_version
                           ,l_init_msg_list
                           ,l_return_status
                           ,l_msg_count
                           ,l_msg_data
                           ,lp_tqdv_rec
                           ,lx_tqdv_rec);
    IF (l_return_status = FND_API.G_RET_STS_ERROR)  THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Assign value to OUT variables
    x_tqdv_rec      := lx_tqdv_rec;
    x_return_status := l_return_status ;
    x_msg_count     := l_msg_count ;
    x_msg_data      := l_msg_data ;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_txd_qte_ln_dtls;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_txd_qte_ln_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_txd_qte_ln_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TXD_QTE_LN_DTLS_PUB','create_txd_qte_ln_dtls');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END create_txd_qte_ln_dtls;

  PROCEDURE create_txd_qte_ln_dtls(
            p_api_version     IN   NUMBER
            ,p_init_msg_list  IN   VARCHAR2
            ,x_return_status  OUT  NOCOPY VARCHAR2
            ,x_msg_count      OUT  NOCOPY NUMBER
            ,x_msg_data       OUT  NOCOPY VARCHAR2
            ,p_tqdv_tbl       IN   tqdv_tbl_type
            ,x_tqdv_tbl       OUT  NOCOPY tqdv_tbl_type) IS
    l_api_version             NUMBER;
    l_init_msg_list           VARCHAR2(3);
    l_msg_data                VARCHAR2(2000);
    l_msg_count               NUMBER;
    l_return_status           VARCHAR2(3) := FND_API.G_RET_STS_SUCCESS;
    lp_tqdv_tbl               tqdv_tbl_type;
    lx_tqdv_tbl               tqdv_tbl_type;
  BEGIN
    SAVEPOINT create_txd_qte_ln_dtls_tbl;

    l_api_version   := p_api_version ;
    l_init_msg_list := p_init_msg_list ;
    l_msg_count     := x_msg_count ;
    l_msg_data      := x_msg_data ;
    lp_tqdv_tbl     := p_tqdv_tbl;
    lx_tqdv_tbl     := x_tqdv_tbl;

    okl_tqd_pvt.insert_row(l_api_version
                           ,l_init_msg_list
                           ,l_return_status
                           ,l_msg_count
                           ,l_msg_data
                           ,lp_tqdv_tbl
                           ,lx_tqdv_tbl);
    IF (l_return_status = FND_API.G_RET_STS_ERROR)  THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Assign value to OUT variables
    x_tqdv_tbl      := lx_tqdv_tbl;
    x_return_status := l_return_status ;
    x_msg_count     := l_msg_count ;
    x_msg_data      := l_msg_data ;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO create_txd_qte_ln_dtls_tbl;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO create_txd_qte_ln_dtls_tbl;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO create_txd_qte_ln_dtls_tbl;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TXD_QTE_LN_DTLS_PUB','create_txd_qte_ln_dtls_tbl');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END create_txd_qte_ln_dtls;

  PROCEDURE lock_txd_qte_ln_dtls(
            p_api_version     IN  NUMBER
            ,p_init_msg_list  IN  VARCHAR2
            ,x_return_status  OUT NOCOPY VARCHAR2
            ,x_msg_count      OUT NOCOPY NUMBER
            ,x_msg_data       OUT NOCOPY VARCHAR2
            ,p_tqdv_rec       IN  tqdv_rec_type) IS
    l_api_version            NUMBER ;
    l_init_msg_list          VARCHAR2(3);
    l_return_status          VARCHAR2(3) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    lp_tqdv_rec              tqdv_rec_type;
  BEGIN
    SAVEPOINT lock_txd_qte_ln_dtls;

    l_api_version   := p_api_version;
    l_init_msg_list := p_init_msg_list;
    l_msg_count     := x_msg_count;
    l_msg_data      := x_msg_data;
    lp_tqdv_rec     := p_tqdv_rec;
    okl_tqd_pvt.lock_row(
		    l_api_version,
		    l_init_msg_list,
		    l_return_status,
		    l_msg_count,
		    l_msg_data,
		    lp_tqdv_rec);
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
      ROLLBACK TO lock_txd_qte_ln_dtls;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_txd_qte_ln_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO lock_txd_qte_ln_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TXD_QTE_LN_DTLS_PUB','lock_txd_qte_ln_dtls');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END lock_txd_qte_ln_dtls;

  PROCEDURE lock_txd_qte_ln_dtls(
            p_api_version     IN  NUMBER
            ,p_init_msg_list  IN  VARCHAR2
            ,x_return_status  OUT NOCOPY VARCHAR2
            ,x_msg_count      OUT NOCOPY NUMBER
            ,x_msg_data       OUT NOCOPY VARCHAR2
            ,p_tqdv_tbl       IN  tqdv_tbl_type) IS
    l_api_version            NUMBER ;
    l_init_msg_list          VARCHAR2(3);
    l_return_status          VARCHAR2(3) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    lp_tqdv_tbl              tqdv_tbl_type;
  BEGIN
    SAVEPOINT lock_txd_qte_ln_dtls_tbl;

    l_api_version   := p_api_version;
    l_init_msg_list := p_init_msg_list;
    l_msg_count     := x_msg_count;
    l_msg_data      := x_msg_data;
    lp_tqdv_tbl     := p_tqdv_tbl;
    okl_tqd_pvt.lock_row(
		    l_api_version,
		    l_init_msg_list,
		    l_return_status,
		    l_msg_count,
		    l_msg_data,
		    lp_tqdv_tbl);
    IF (l_return_status = FND_API.G_RET_STS_ERROR)  THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Assign value to OUT variables
    x_return_status := l_return_status;
    x_msg_count     := l_msg_count;
    x_msg_data      := l_msg_data;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO lock_txd_qte_ln_dtls_tbl;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO lock_txd_qte_ln_dtls_tbl;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO lock_txd_qte_ln_dtls_tbl;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TXD_QTE_LN_DTLS_PUB','lock_txd_qte_ln_dtls_tbl');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END lock_txd_qte_ln_dtls;

  PROCEDURE update_txd_qte_ln_dtls(
            p_api_version     IN  NUMBER
            ,p_init_msg_list  IN  VARCHAR2
            ,x_return_status  OUT NOCOPY VARCHAR2
            ,x_msg_count      OUT NOCOPY NUMBER
            ,x_msg_data       OUT NOCOPY VARCHAR2
            ,p_tqdv_rec       IN  tqdv_rec_type
            ,x_tqdv_rec       OUT NOCOPY tqdv_rec_type) IS

    l_api_version             NUMBER;
    l_init_msg_list           VARCHAR2(3);
    l_return_status           VARCHAR2(3) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);
    lp_tqdv_rec               tqdv_rec_type;
    lx_tqdv_rec               tqdv_rec_type;
  BEGIN
    SAVEPOINT update_txd_qte_ln_dtls;

    l_api_version   := p_api_version;
    l_init_msg_list := p_init_msg_list;
    l_msg_count     := x_msg_count;
    l_msg_data      := x_msg_data;
    lp_tqdv_rec     := p_tqdv_rec;
    lx_tqdv_rec     := x_tqdv_rec;

    okl_tqd_pvt.update_row(l_api_version
                           ,l_init_msg_list
                           ,l_return_status
                           ,l_msg_count
                           ,l_msg_data
                           ,lp_tqdv_rec
                           ,lx_tqdv_rec);
    IF (l_return_status = FND_API.G_RET_STS_ERROR)  THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Assign value to OUT variables
    x_tqdv_rec       := lx_tqdv_rec;
    x_return_status  := l_return_status ;
    x_msg_count      := l_msg_count ;
    x_msg_data       := l_msg_data ;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_txd_qte_ln_dtls;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_txd_qte_ln_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO update_txd_qte_ln_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TXD_QTE_LN_DTLS_PUB','update_txd_qte_ln_dtls');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END update_txd_qte_ln_dtls;

  PROCEDURE update_txd_qte_ln_dtls(
            p_api_version     IN  NUMBER
            ,p_init_msg_list  IN  VARCHAR2
            ,x_return_status  OUT NOCOPY VARCHAR2
            ,x_msg_count      OUT NOCOPY NUMBER
            ,x_msg_data       OUT NOCOPY VARCHAR2
            ,p_tqdv_tbl       IN  tqdv_tbl_type
            ,x_tqdv_tbl       OUT NOCOPY tqdv_tbl_type) IS

    l_api_version             NUMBER;
    l_init_msg_list           VARCHAR2(3);
    l_return_status           VARCHAR2(3) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count               NUMBER;
    l_msg_data                VARCHAR2(2000);
    lp_tqdv_tbl               tqdv_tbl_type;
    lx_tqdv_tbl               tqdv_tbl_type;
  BEGIN
    SAVEPOINT update_txd_qte_ln_dtls_tbl;

    l_api_version   := p_api_version;
    l_init_msg_list := p_init_msg_list;
    l_msg_data      := x_msg_data;
    l_msg_count     := x_msg_count;
    lp_tqdv_tbl     := p_tqdv_tbl;
    lx_tqdv_tbl     := x_tqdv_tbl;
    okl_tqd_pvt.update_row(l_api_version
                           ,l_init_msg_list
                           ,l_return_status
                           ,l_msg_count
                           ,l_msg_data
                           ,lp_tqdv_tbl
                           ,lx_tqdv_tbl);
    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Assign value to OUT variables
    x_tqdv_tbl      := lx_tqdv_tbl;
    x_return_status := l_return_status ;
    x_msg_count     := l_msg_count ;
    x_msg_data      := l_msg_data ;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_txd_qte_ln_dtls_tbl;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_txd_qte_ln_dtls_tbl;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO update_txd_qte_ln_dtls_tbl;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TXD_QTE_LN_DTLS_PUB','update_txd_qte_ln_dtls_tbl');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END update_txd_qte_ln_dtls;

  PROCEDURE delete_txd_qte_ln_dtls(
            p_api_version     IN  NUMBER
            ,p_init_msg_list  IN  VARCHAR2
            ,x_return_status  OUT NOCOPY VARCHAR2
            ,x_msg_count      OUT NOCOPY NUMBER
            ,x_msg_data       OUT NOCOPY VARCHAR2
            ,p_tqdv_rec       IN  tqdv_rec_type) IS

    l_return_status 	    VARCHAR2(3) := FND_API.G_RET_STS_SUCCESS;
    l_api_version           NUMBER;
    l_init_msg_list         VARCHAR2(3) ;
    l_msg_data              VARCHAR2(2000);
    l_msg_count             NUMBER;
    lp_tqdv_rec             tqdv_rec_type;
  BEGIN
    SAVEPOINT delete_txd_qte_ln_dtls;

    l_api_version   := p_api_version ;
    l_init_msg_list := p_init_msg_list ;
    l_msg_data      := x_msg_data;
    l_msg_count     := x_msg_count ;
    lp_tqdv_rec     := p_tqdv_rec;
    --Delete the Master
    okl_tqd_pvt.delete_row(l_api_version
                           ,l_init_msg_list
                           ,l_return_status
                           ,l_msg_count
                           ,l_msg_data
                           ,lp_tqdv_rec);
    IF (l_return_status = FND_API.G_RET_STS_ERROR)  THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Assign value to OUT variables
    x_msg_count     := l_msg_count ;
    x_msg_data      := l_msg_data ;
    x_return_status := l_return_status ;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO delete_txd_qte_ln_dtls;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_txd_qte_ln_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO delete_txd_qte_ln_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TXD_QTE_LN_DTLS_PUB','delete_txd_qte_ln_dtls');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END delete_txd_qte_ln_dtls;

  PROCEDURE delete_txd_qte_ln_dtls(
            p_api_version     IN   NUMBER
            ,p_init_msg_list  IN   VARCHAR2
            ,x_return_status  OUT  NOCOPY VARCHAR2
            ,x_msg_count      OUT  NOCOPY NUMBER
            ,x_msg_data       OUT  NOCOPY VARCHAR2
            ,p_tqdv_tbl       IN   tqdv_tbl_type) IS
    l_api_version            NUMBER ;
    l_init_msg_list          VARCHAR2(3);
    l_return_status          VARCHAR2(3) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    lp_tqdv_tbl              tqdv_tbl_type;
  BEGIN
    SAVEPOINT delete_txd_qte_ln_dtls_tbl;

    l_api_version   := p_api_version;
    l_init_msg_list := p_init_msg_list;
    l_msg_count     := x_msg_count;
    l_msg_data      := x_msg_data;
    lp_tqdv_tbl     := p_tqdv_tbl;
    okl_tqd_pvt.delete_row(
		    l_api_version,
		    l_init_msg_list,
		    l_return_status,
		    l_msg_count,
		    l_msg_data,
		    lp_tqdv_tbl);
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
      ROLLBACK TO delete_txd_qte_ln_dtls_tbl;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO delete_txd_qte_ln_dtls_tbl;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO delete_txd_qte_ln_dtls_tbl;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TXD_QTE_LN_DTLS_PUB','delete_txd_qte_ln_dtls_tbl');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END delete_txd_qte_ln_dtls;

  PROCEDURE validate_txd_qte_ln_dtls(
            p_api_version     IN  NUMBER
            ,p_init_msg_list  IN  VARCHAR2
            ,x_return_status  OUT NOCOPY VARCHAR2
            ,x_msg_count      OUT NOCOPY NUMBER
            ,x_msg_data       OUT NOCOPY VARCHAR2
            ,p_tqdv_rec       IN  tqdv_rec_type) IS
    l_return_status 	    VARCHAR2(3) := FND_API.G_RET_STS_SUCCESS;
    l_api_version           NUMBER;
    l_init_msg_list         VARCHAR2(3) ;
    l_msg_data              VARCHAR2(2000);
    l_msg_count             NUMBER;
    lp_tqdv_rec             tqdv_rec_type;
  BEGIN
    SAVEPOINT validate_txd_qte_ln_dtls;

    l_api_version   := p_api_version ;
    l_init_msg_list := p_init_msg_list ;
    l_msg_data      := x_msg_data;
    l_msg_count     := x_msg_count ;
    lp_tqdv_rec     := p_tqdv_rec;
    --validate the Master
    okl_tqd_pvt.validate_row(l_api_version
                           ,l_init_msg_list
                           ,l_return_status
                           ,l_msg_count
                           ,l_msg_data
                           ,lp_tqdv_rec);
    IF (l_return_status = FND_API.G_RET_STS_ERROR)  THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    --Assign value to OUT variables
    x_msg_count     := l_msg_count ;
    x_msg_data      := l_msg_data ;
    x_return_status := l_return_status ;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO validate_txd_qte_ln_dtls;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_txd_qte_ln_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO validate_txd_qte_ln_dtls;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TXD_QTE_LN_DTLS_PUB','validate_txd_qte_ln_dtls');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END validate_txd_qte_ln_dtls;

  PROCEDURE validate_txd_qte_ln_dtls(
            p_api_version     IN  NUMBER
            ,p_init_msg_list  IN  VARCHAR2
            ,x_return_status  OUT NOCOPY VARCHAR2
            ,x_msg_count      OUT NOCOPY NUMBER
            ,x_msg_data       OUT NOCOPY VARCHAR2
            ,p_tqdv_tbl       IN  tqdv_tbl_type) IS
    l_api_version            NUMBER ;
    l_init_msg_list          VARCHAR2(3);
    l_return_status          VARCHAR2(3) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    lp_tqdv_tbl              tqdv_tbl_type;
  BEGIN
    SAVEPOINT validate_txd_qte_ln_dtls_tbl;

    l_api_version   := p_api_version;
    l_init_msg_list := p_init_msg_list;
    l_msg_count     := x_msg_count;
    l_msg_data      := x_msg_data;
    lp_tqdv_tbl     := p_tqdv_tbl;
    okl_tqd_pvt.validate_row(
		    l_api_version,
		    l_init_msg_list,
		    l_return_status,
		    l_msg_count,
		    l_msg_data,
		    lp_tqdv_tbl);
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
      ROLLBACK TO validate_txd_qte_ln_dtls_tbl;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_txd_qte_ln_dtls_tbl;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO validate_txd_qte_ln_dtls_tbl;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := l_msg_count ;
      x_msg_data      := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TXD_QTE_LN_DTLS_PUB','validate_txd_qte_ln_dtls_tbl');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
  END validate_txd_qte_ln_dtls;
END OKL_TXD_QTE_LN_DTLS_PUB;

/
