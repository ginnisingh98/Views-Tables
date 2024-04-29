--------------------------------------------------------
--  DDL for Package Body OKL_TRX_CSH_BATCH_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TRX_CSH_BATCH_PUB" AS
/* $Header: OKLPBTCB.pls 120.7 2007/11/20 14:37:07 udhenuko noship $ */

PROCEDURE insert_trx_csh_batch(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_btcv_rec              IN  btcv_rec_type
    ,x_btcv_rec              OUT  NOCOPY btcv_rec_type) IS


l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
lp_btcv_rec  btcv_rec_type;
lx_btcv_rec  btcv_rec_type;

BEGIN

SAVEPOINT trx_csh_batch_insert;

l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_btcv_rec :=  p_btcv_rec;
lx_btcv_rec :=  x_btcv_rec;


lp_btcv_rec.org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();
lp_btcv_rec.TRX_STATUS_CODE := NVL(lp_btcv_rec.TRX_STATUS_CODE, 'WORKING');

lp_btcv_rec.DATE_ENTERED := lp_btcv_rec.DATE_DEPOSIT;
--lp_btcv_rec.DATE_GL_REQUESTED := lp_btcv_rec.DATE_DEPOSIT;

okl_btc_pvt.insert_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_btcv_rec
                         ,lx_btcv_rec);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

lp_btcv_rec := lx_btcv_rec;

x_btcv_rec  := lx_btcv_rec;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_csh_batch_insert;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_csh_batch_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_csh_batch_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TRX_CSH_BATCH_PUB','insert_trx_csh_batch');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END insert_trx_csh_batch;

PROCEDURE insert_trx_csh_batch(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_btcv_tbl              IN  btcv_tbl_type
    ,x_btcv_tbl              OUT  NOCOPY btcv_tbl_type) IS

l_api_version NUMBER;
l_init_msg_list VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
l_return_status VARCHAR2(1);
lp_btcv_tbl  btcv_tbl_type;
lx_btcv_tbl  btcv_tbl_type;

BEGIN

SAVEPOINT trx_csh_batch_insert;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_btcv_tbl :=  p_btcv_tbl;
lx_btcv_tbl :=  x_btcv_tbl;

for i in 1..lp_btcv_tbl.count
LOOP

lp_btcv_tbl(i).org_id  := MO_GLOBAL.GET_CURRENT_ORG_ID();
lp_btcv_tbl(i).TRX_STATUS_CODE := NVL(lp_btcv_tbl(i).TRX_STATUS_CODE, 'WORKING');
lp_btcv_tbl(i).DATE_ENTERED := lp_btcv_tbl(i).DATE_DEPOSIT;
--lp_btcv_tbl(i).DATE_GL_REQUESTED := lp_btcv_tbl(i).DATE_DEPOSIT;

END LOOP;

okl_btc_pvt.insert_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_btcv_tbl
                         ,lx_btcv_tbl);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

lp_btcv_tbl := lx_btcv_tbl;

x_btcv_tbl  := lx_btcv_tbl;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_csh_batch_insert;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_csh_batch_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_csh_batch_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TRX_CSH_BATCH_PUB','insert_trx_csh_batch');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END insert_trx_csh_batch;

PROCEDURE lock_trx_csh_batch(
     p_api_version           IN NUMBER
    ,p_init_msg_list         IN VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_btcv_rec              IN btcv_rec_type) IS

BEGIN
    okl_btc_pvt.lock_row(
		    p_api_version,
		    p_init_msg_list,
		    x_return_status,
		    x_msg_count,
		    x_msg_data,
		    p_btcv_rec);

IF ( x_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TRX_CSH_BATCH_PUB','lock_trx_csh_batch');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END lock_trx_csh_batch;

PROCEDURE lock_trx_csh_batch(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_btcv_tbl              IN  btcv_tbl_type) IS

BEGIN
    okl_btc_pvt.lock_row(
		    p_api_version,
		    p_init_msg_list,
		    x_return_status,
		    x_msg_count,
		    x_msg_data,
		    p_btcv_tbl);

IF ( x_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TRX_CSH_BATCH_PUB','lock_trx_csh_batch');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END lock_trx_csh_batch;

PROCEDURE update_trx_csh_batch(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_btcv_rec              IN  btcv_rec_type
    ,x_btcv_rec              OUT  NOCOPY btcv_rec_type) IS

l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
lp_btcv_rec  btcv_rec_type;
lx_btcv_rec  btcv_rec_type;

BEGIN

SAVEPOINT trx_csh_batch_update;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_btcv_rec :=  p_btcv_rec;
lx_btcv_rec :=  x_btcv_rec;

    okl_btc_pvt.update_row(
                              l_api_version
                             ,l_init_msg_list
                             ,l_return_status
                             ,l_msg_count
                             ,l_msg_data
                             ,lp_btcv_rec
                             ,lx_btcv_rec);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

lp_btcv_rec := lx_btcv_rec;

x_btcv_rec  := lx_btcv_rec;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_csh_batch_update;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_csh_batch_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_csh_batch_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TRX_CSH_BATCH_PUB','update_trx_csh_batch');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END update_trx_csh_batch;

PROCEDURE update_trx_csh_batch(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_btcv_tbl              IN  btcv_tbl_type
    ,x_btcv_tbl              OUT  NOCOPY btcv_tbl_type) IS

l_api_version NUMBER;
l_init_msg_list VARCHAR2(200);
l_msg_data VARCHAR2(100);
l_msg_count NUMBER ;
l_return_status VARCHAR2(1);
lp_btcv_tbl  btcv_tbl_type;
lx_btcv_tbl  btcv_tbl_type;

BEGIN

SAVEPOINT trx_csh_batch_update;


lp_btcv_tbl :=  p_btcv_tbl;
lx_btcv_tbl :=  x_btcv_tbl;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data := x_msg_data ;
l_msg_count := x_msg_count ;


    okl_btc_pvt.update_row(
                              l_api_version
                             ,l_init_msg_list
                             ,l_return_status
                             ,l_msg_count
                             ,l_msg_data
                             ,lp_btcv_tbl
                             ,lx_btcv_tbl);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

lp_btcv_tbl := lx_btcv_tbl;

x_btcv_tbl  := lx_btcv_tbl;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_csh_batch_update;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_csh_batch_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_csh_batch_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TRX_CSH_BATCH_PUB','update_trx_csh_batch');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END update_trx_csh_batch;

PROCEDURE delete_trx_csh_batch(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_btcv_rec              IN btcv_rec_type) IS

i	                    NUMBER :=0;
l_return_status 	    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_btcv_rec  btcv_rec_type;
lx_btcv_rec  btcv_rec_type;

BEGIN

SAVEPOINT trx_csh_batch_delete_rec;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_btcv_rec :=  p_btcv_rec;
lx_btcv_rec :=  p_btcv_rec;

okl_btc_pvt.delete_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_btcv_rec);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;


x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_csh_batch_delete_rec;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_csh_batch_delete_rec;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_csh_batch_delete_rec;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TRX_CSH_BATCH_PUB','delete_trx_csh_batch');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END delete_trx_csh_batch;

PROCEDURE delete_trx_csh_batch(
     p_api_version        IN NUMBER
    ,p_init_msg_list      IN VARCHAR2
    ,x_return_status      OUT NOCOPY VARCHAR2
    ,x_msg_count          OUT NOCOPY NUMBER
    ,x_msg_data           OUT NOCOPY VARCHAR2
    ,p_btcv_tbl           IN btcv_tbl_type) IS

i NUMBER := 0;
l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_api_version NUMBER := p_api_version ;
l_init_msg_list VARCHAR2(1) := p_init_msg_list  ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_btcv_tbl  btcv_tbl_type;
lx_btcv_tbl  btcv_tbl_type;

BEGIN

SAVEPOINT trx_csh_batch_delete_tbl;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_btcv_tbl :=  p_btcv_tbl;
lx_btcv_tbl :=  p_btcv_tbl;

BEGIN
      l_return_status := OKC_API.G_RET_STS_SUCCESS;

      IF (lp_btcv_tbl.COUNT > 0) THEN
       	  i := p_btcv_tbl.FIRST;
       LOOP
          delete_trx_csh_batch(
                               l_api_version
                              ,l_init_msg_list
                              ,l_return_status
                              ,l_msg_count
                              ,l_msg_data
                              ,lp_btcv_tbl(i));
          EXIT WHEN (i = lp_btcv_tbl.LAST);
          i := p_btcv_tbl.NEXT(i);
       END LOOP;
      END IF;
IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

END;

x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_csh_batch_delete_tbl;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_csh_batch_delete_tbl;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_csh_batch_delete_tbl;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TRX_CSH_BATCH_PUB','delete_trx_csh_batch');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END delete_trx_csh_batch;

PROCEDURE validate_trx_csh_batch(
     p_api_version      IN  NUMBER
    ,p_init_msg_list    IN  VARCHAR2
    ,x_return_status    OUT  NOCOPY VARCHAR2
    ,x_msg_count        OUT  NOCOPY NUMBER
    ,x_msg_data         OUT  NOCOPY VARCHAR2
    ,p_btcv_rec         IN  btcv_rec_type) IS

l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_btcv_rec  btcv_rec_type;
lx_btcv_rec  btcv_rec_type;
l_return_status VARCHAR2(1);

BEGIN

SAVEPOINT trx_csh_batch_validate;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_btcv_rec :=  p_btcv_rec;
lx_btcv_rec :=  p_btcv_rec;

okl_btc_pvt.validate_row(
                            l_api_version
                           ,l_init_msg_list
                           ,l_return_status
                           ,l_msg_count
                           ,l_msg_data
                           ,lp_btcv_rec);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

lp_btcv_rec := lx_btcv_rec;

x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_csh_batch_validate;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_csh_batch_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_csh_batch_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TRX_CSH_BATCH_PUB','validate_trx_csh_batch');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END validate_trx_csh_batch;

PROCEDURE validate_trx_csh_batch(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2,
    x_return_status     OUT  NOCOPY VARCHAR2,
    x_msg_count         OUT  NOCOPY NUMBER,
    x_msg_data          OUT  NOCOPY VARCHAR2,
    p_btcv_tbl          IN  btcv_tbl_type) IS
l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_btcv_tbl  btcv_tbl_type;
lx_btcv_tbl  btcv_tbl_type;
l_return_status VARCHAR2(1);

BEGIN

SAVEPOINT trx_csh_batch_validate;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_btcv_tbl :=  p_btcv_tbl;
lx_btcv_tbl :=  p_btcv_tbl;

okl_btc_pvt.validate_row(
                            p_api_version
                           ,p_init_msg_list
                           ,x_return_status
                           ,x_msg_count
                           ,x_msg_data
                           ,lp_btcv_tbl);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

lp_btcv_tbl := lx_btcv_tbl;

x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_csh_batch_validate;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_csh_batch_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_csh_batch_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TRX_CSH_BATCH_PUB','validate_trx_csh_batch');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END validate_trx_csh_batch;

PROCEDURE handle_batch_receipt(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_btcv_rec              IN  btcv_rec_type
    ,x_btcv_rec              OUT  NOCOPY btcv_rec_type
    ,p_btch_lines_tbl        IN  okl_btch_dtls_tbl_type
    ,x_btch_lines_tbl        OUT NOCOPY okl_btch_dtls_tbl_type) IS

l_init_msg_list     VARCHAR2(1);
i                   PLS_INTEGER;
lp_btch_lines_tbl   okl_btch_dtls_tbl_type;

BEGIN

SAVEPOINT handle_batch_receipt;

lp_btch_lines_tbl := p_btch_lines_tbl;

-- Check for the value of ID. If it is null then call insert procedure else
-- call update procedure for header
IF(p_btcv_rec.id IS NULL) THEN
    insert_trx_csh_batch(p_api_version           => p_api_version
                        ,p_init_msg_list         => p_init_msg_list
                        ,x_return_status         => x_return_status
                        ,x_msg_count             => x_msg_count
                        ,x_msg_data              => x_msg_data
                        ,p_btcv_rec              => p_btcv_rec
                        ,x_btcv_rec              => x_btcv_rec);
ELSE
    update_trx_csh_batch(p_api_version           => p_api_version
                        ,p_init_msg_list         => p_init_msg_list
                        ,x_return_status         => x_return_status
                        ,x_msg_count             => x_msg_count
                        ,x_msg_data              => x_msg_data
                        ,p_btcv_rec              => p_btcv_rec
                        ,x_btcv_rec              => x_btcv_rec);
END IF;

--Check for return status and raise appropriate exception
IF ( x_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

l_init_msg_list := FND_API.G_FALSE;

-- Check whether there are any records in lines table or not
IF(lp_btch_lines_tbl.COUNT > 0) THEN

    -- populate the foreign key value in lines table
    i := lp_btch_lines_tbl.FIRST;
    LOOP
      lp_btch_lines_tbl(i).btc_id := x_btcv_rec.id;
      EXIT WHEN (i = lp_btch_lines_tbl.LAST);
      i := lp_btch_lines_tbl.NEXT(i);
    END LOOP;

    -- call the procedure for create and update of Lines
    okl_btch_cash_applic.handle_batch_pay(p_api_version           => p_api_version
                                         ,p_init_msg_list         => l_init_msg_list
                                         ,x_return_status         => x_return_status
                                         ,x_msg_count             => x_msg_count
                                         ,x_msg_data              => x_msg_data
                                         ,p_btch_tbl              => lp_btch_lines_tbl
                                         ,x_btch_tbl              => x_btch_lines_tbl);
END IF;

--Check for return status and raise appropriate exception
IF ( x_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO handle_batch_receipt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO handle_batch_receipt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO handle_batch_receipt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_TRX_CSH_BATCH_PUB','handle_batch_receipt');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END handle_batch_receipt;

END OKL_TRX_CSH_BATCH_PUB;

/
