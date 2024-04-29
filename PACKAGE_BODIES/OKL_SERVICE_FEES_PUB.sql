--------------------------------------------------------
--  DDL for Package Body OKL_SERVICE_FEES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SERVICE_FEES_PUB" AS
/* $Header: OKLPSVFB.pls 115.7 2004/04/13 11:22:33 rnaik noship $ */

PROCEDURE insert_service_fees(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_svfv_rec              IN  svfv_rec_type
    ,x_svfv_rec              OUT  NOCOPY svfv_rec_type) IS


l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
lp_svfv_rec  svfv_rec_type;
lx_svfv_rec  svfv_rec_type;

BEGIN

SAVEPOINT service_fees_insert;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_svfv_rec :=  p_svfv_rec;
lx_svfv_rec :=  x_svfv_rec;






okl_svf_pvt.insert_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_svfv_rec
                         ,lx_svfv_rec);

IF ( l_return_status = OKL_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_svfv_rec := lx_svfv_rec;





--Assign value to OUT variables
x_svfv_rec  := lx_svfv_rec;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO service_fees_insert;
      x_return_status := OKL_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO service_fees_insert;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO service_fees_insert;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SERVICE_FEES_PUB','insert_service_fees');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END insert_service_fees;

PROCEDURE insert_service_fees(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_svfv_tbl              IN  svfv_tbl_type
    ,x_svfv_tbl              OUT  NOCOPY svfv_tbl_type) IS

l_api_version NUMBER;
l_init_msg_list VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
l_return_status VARCHAR2(1);
lp_svfv_tbl  svfv_tbl_type;
lx_svfv_tbl  svfv_tbl_type;

BEGIN

SAVEPOINT service_fees_insert;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_svfv_tbl :=  p_svfv_tbl;
lx_svfv_tbl :=  x_svfv_tbl;



okl_svf_pvt.insert_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_svfv_tbl
                         ,lx_svfv_tbl);

IF ( l_return_status = OKL_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_svfv_tbl := lx_svfv_tbl;



--Assign value to OUT variables
x_svfv_tbl  := lx_svfv_tbl;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO service_fees_insert;
      x_return_status := OKL_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO service_fees_insert;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO service_fees_insert;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SERVICE_FEES_PUB','insert_service_fees');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END insert_service_fees;

PROCEDURE lock_service_fees(
     p_api_version           IN NUMBER
    ,p_init_msg_list         IN VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_svfv_rec              IN svfv_rec_type) IS

BEGIN
    okl_svf_pvt.lock_row(
		    p_api_version,
		    p_init_msg_list,
		    x_return_status,
		    x_msg_count,
		    x_msg_data,
		    p_svfv_rec);

IF ( x_return_status = OKL_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR ) THEN
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
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SERVICE_FEES_PUB','lock_service_fees');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END lock_service_fees;

PROCEDURE lock_service_fees(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_svfv_tbl              IN  svfv_tbl_type) IS

BEGIN
    okl_svf_pvt.lock_row(
		    p_api_version,
		    p_init_msg_list,
		    x_return_status,
		    x_msg_count,
		    x_msg_data,
		    p_svfv_tbl);

IF ( x_return_status = OKL_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR ) THEN
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
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SERVICE_FEES_PUB','lock_service_fees');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END lock_service_fees;

PROCEDURE update_service_fees(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_svfv_rec              IN  svfv_rec_type
    ,x_svfv_rec              OUT  NOCOPY svfv_rec_type) IS

l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
lp_svfv_rec  svfv_rec_type;
lx_svfv_rec  svfv_rec_type;

BEGIN

SAVEPOINT service_fees_update;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_svfv_rec :=  p_svfv_rec;
lx_svfv_rec :=  x_svfv_rec;





    okl_svf_pvt.update_row(
                              l_api_version
                             ,l_init_msg_list
                             ,l_return_status
                             ,l_msg_count
                             ,l_msg_data
                             ,lp_svfv_rec
                             ,lx_svfv_rec);

IF ( l_return_status = OKL_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_svfv_rec := lx_svfv_rec;




--Assign value to OUT variables
x_svfv_rec  := lx_svfv_rec;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO service_fees_update;
      x_return_status := OKL_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO service_fees_update;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO service_fees_update;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SERVICE_FEES_PUB','update_service_fees');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END update_service_fees;

PROCEDURE update_service_fees(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_svfv_tbl              IN  svfv_tbl_type
    ,x_svfv_tbl              OUT  NOCOPY svfv_tbl_type) IS

l_api_version NUMBER;
l_init_msg_list VARCHAR2(200);
l_msg_data VARCHAR2(100);
l_msg_count NUMBER ;
l_return_status VARCHAR2(1);
lp_svfv_tbl  svfv_tbl_type;
lx_svfv_tbl  svfv_tbl_type;

BEGIN

SAVEPOINT service_fees_update;


lp_svfv_tbl :=  p_svfv_tbl;
lx_svfv_tbl :=  x_svfv_tbl;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data := x_msg_data ;
l_msg_count := x_msg_count ;





    okl_svf_pvt.update_row(
                              l_api_version
                             ,l_init_msg_list
                             ,l_return_status
                             ,l_msg_count
                             ,l_msg_data
                             ,lp_svfv_tbl
                             ,lx_svfv_tbl);

IF ( l_return_status = OKL_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_svfv_tbl := lx_svfv_tbl;



--Assign value to OUT variables
x_svfv_tbl  := lx_svfv_tbl;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO service_fees_update;
      x_return_status := OKL_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO service_fees_update;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO service_fees_update;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SERVICE_FEES_PUB','update_service_fees');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END update_service_fees;

--Put custom code for cascade delete by developer
PROCEDURE delete_service_fees(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_svfv_rec              IN svfv_rec_type) IS

i	                    NUMBER :=0;
l_return_status 	    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_svfv_rec  svfv_rec_type;
lx_svfv_rec  svfv_rec_type;

BEGIN

SAVEPOINT service_fees_delete_rec;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_svfv_rec :=  p_svfv_rec;
lx_svfv_rec :=  p_svfv_rec;




--Delete the Master
okl_svf_pvt.delete_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_svfv_rec);

IF ( l_return_status = OKL_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;





--Assign value to OUT variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO service_fees_delete_rec;
      x_return_status := OKL_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO service_fees_delete_rec;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO service_fees_delete_rec;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SERVICE_FEES_PUB','delete_service_fees');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END delete_service_fees;

PROCEDURE delete_service_fees(
     p_api_version        IN NUMBER
    ,p_init_msg_list      IN VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status      OUT NOCOPY VARCHAR2
    ,x_msg_count          OUT NOCOPY NUMBER
    ,x_msg_data           OUT NOCOPY VARCHAR2
    ,p_svfv_tbl           IN svfv_tbl_type) IS

i NUMBER := 0;
l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
l_api_version NUMBER := p_api_version ;
l_init_msg_list VARCHAR2(1) := p_init_msg_list  ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_svfv_tbl  svfv_tbl_type;
lx_svfv_tbl  svfv_tbl_type;

BEGIN

SAVEPOINT service_fees_delete_tbl;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_svfv_tbl :=  p_svfv_tbl;
lx_svfv_tbl :=  p_svfv_tbl;




BEGIN
      --Initialize the return status
      l_return_status := OKL_API.G_RET_STS_SUCCESS;

      IF (lp_svfv_tbl.COUNT > 0) THEN
       	  i := p_svfv_tbl.FIRST;
       LOOP
          delete_service_fees(
                               l_api_version
                              ,l_init_msg_list
                              ,l_return_status
                              ,l_msg_count
                              ,l_msg_data
                              ,lp_svfv_tbl(i));
          EXIT WHEN (i = lp_svfv_tbl.LAST);
          i := p_svfv_tbl.NEXT(i);
       END LOOP;
      END IF;
IF ( l_return_status = OKL_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

END;





--Assign value to OUT variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO service_fees_delete_tbl;
      x_return_status := OKL_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO service_fees_delete_tbl;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO service_fees_delete_tbl;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SERVICE_FEES_PUB','delete_service_fees');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END delete_service_fees;

PROCEDURE validate_service_fees(
     p_api_version      IN  NUMBER
    ,p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE
    ,x_return_status    OUT  NOCOPY VARCHAR2
    ,x_msg_count        OUT  NOCOPY NUMBER
    ,x_msg_data         OUT  NOCOPY VARCHAR2
    ,p_svfv_rec         IN  svfv_rec_type) IS

l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_svfv_rec  svfv_rec_type;
lx_svfv_rec  svfv_rec_type;
l_return_status VARCHAR2(1);

BEGIN

SAVEPOINT service_fees_validate;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_svfv_rec :=  p_svfv_rec;
lx_svfv_rec :=  p_svfv_rec;




okl_svf_pvt.validate_row(
                            l_api_version
                           ,l_init_msg_list
                           ,l_return_status
                           ,l_msg_count
                           ,l_msg_data
                           ,lp_svfv_rec);

IF ( l_return_status = OKL_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_svfv_rec := lx_svfv_rec;








--Assign value to OUT variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO service_fees_validate;
      x_return_status := OKL_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO service_fees_validate;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO service_fees_validate;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SERVICE_FEES_PUB','validate_service_fees');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END validate_service_fees;

PROCEDURE validate_service_fees(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status     OUT  NOCOPY VARCHAR2,
    x_msg_count         OUT  NOCOPY NUMBER,
    x_msg_data          OUT  NOCOPY VARCHAR2,
    p_svfv_tbl          IN  svfv_tbl_type) IS
l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_svfv_tbl  svfv_tbl_type;
lx_svfv_tbl  svfv_tbl_type;
l_return_status VARCHAR2(1);

BEGIN

SAVEPOINT service_fees_validate;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_svfv_tbl :=  p_svfv_tbl;
lx_svfv_tbl :=  p_svfv_tbl;



okl_svf_pvt.validate_row(
                            p_api_version
                           ,p_init_msg_list
                           ,x_return_status
                           ,x_msg_count
                           ,x_msg_data
                           ,lp_svfv_tbl);

IF ( l_return_status = OKL_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_svfv_tbl := lx_svfv_tbl;





--Assign value to OUT variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO service_fees_validate;
      x_return_status := OKL_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO service_fees_validate;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO service_fees_validate;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_SERVICE_FEES_PUB','validate_service_fees');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END validate_service_fees;

END OKL_SERVICE_FEES_PUB;

/
