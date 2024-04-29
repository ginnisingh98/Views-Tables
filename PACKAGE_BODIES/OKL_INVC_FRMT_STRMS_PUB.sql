--------------------------------------------------------
--  DDL for Package Body OKL_INVC_FRMT_STRMS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INVC_FRMT_STRMS_PUB" AS
/* $Header: OKLPILSB.pls 115.7 2004/04/13 10:48:22 rnaik noship $ */

PROCEDURE insert_invc_frmt_strms(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_ilsv_rec              IN  ilsv_rec_type
    ,x_ilsv_rec              OUT  NOCOPY ilsv_rec_type) IS


l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
lp_ilsv_rec  ilsv_rec_type;
lx_ilsv_rec  ilsv_rec_type;

BEGIN

SAVEPOINT invc_frmt_strms_insert;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_ilsv_rec :=  p_ilsv_rec;
lx_ilsv_rec :=  x_ilsv_rec;






okl_ils_pvt.insert_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_ilsv_rec
                         ,lx_ilsv_rec);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_ilsv_rec := lx_ilsv_rec;





--Assign value to OUT variables
x_ilsv_rec  := lx_ilsv_rec;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO invc_frmt_strms_insert;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO invc_frmt_strms_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO invc_frmt_strms_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INVC_FRMT_STRMS_PUB','insert_invc_frmt_strms');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END insert_invc_frmt_strms;

PROCEDURE insert_invc_frmt_strms(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_ilsv_tbl              IN  ilsv_tbl_type
    ,x_ilsv_tbl              OUT  NOCOPY ilsv_tbl_type) IS

l_api_version NUMBER;
l_init_msg_list VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
l_return_status VARCHAR2(1);
lp_ilsv_tbl  ilsv_tbl_type;
lx_ilsv_tbl  ilsv_tbl_type;

BEGIN

SAVEPOINT invc_frmt_strms_insert;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_ilsv_tbl :=  p_ilsv_tbl;
lx_ilsv_tbl :=  x_ilsv_tbl;



okl_ils_pvt.insert_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_ilsv_tbl
                         ,lx_ilsv_tbl);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_ilsv_tbl := lx_ilsv_tbl;



--Assign value to OUT variables
x_ilsv_tbl  := lx_ilsv_tbl;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO invc_frmt_strms_insert;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO invc_frmt_strms_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO invc_frmt_strms_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INVC_FRMT_STRMS_PUB','insert_invc_frmt_strms');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END insert_invc_frmt_strms;

PROCEDURE lock_invc_frmt_strms(
     p_api_version           IN NUMBER
    ,p_init_msg_list         IN VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_ilsv_rec              IN ilsv_rec_type) IS

BEGIN
    okl_ils_pvt.lock_row(
		    p_api_version,
		    p_init_msg_list,
		    x_return_status,
		    x_msg_count,
		    x_msg_data,
		    p_ilsv_rec);

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
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INVC_FRMT_STRMS_PUB','lock_invc_frmt_strms');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END lock_invc_frmt_strms;

PROCEDURE lock_invc_frmt_strms(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_ilsv_tbl              IN  ilsv_tbl_type) IS

BEGIN
    okl_ils_pvt.lock_row(
		    p_api_version,
		    p_init_msg_list,
		    x_return_status,
		    x_msg_count,
		    x_msg_data,
		    p_ilsv_tbl);

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
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INVC_FRMT_STRMS_PUB','lock_invc_frmt_strms');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END lock_invc_frmt_strms;

PROCEDURE update_invc_frmt_strms(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_ilsv_rec              IN  ilsv_rec_type
    ,x_ilsv_rec              OUT  NOCOPY ilsv_rec_type) IS

l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
lp_ilsv_rec  ilsv_rec_type;
lx_ilsv_rec  ilsv_rec_type;

BEGIN

SAVEPOINT invc_frmt_strms_update;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_ilsv_rec :=  p_ilsv_rec;
lx_ilsv_rec :=  x_ilsv_rec;





    okl_ils_pvt.update_row(
                              l_api_version
                             ,l_init_msg_list
                             ,l_return_status
                             ,l_msg_count
                             ,l_msg_data
                             ,lp_ilsv_rec
                             ,lx_ilsv_rec);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_ilsv_rec := lx_ilsv_rec;




--Assign value to OUT variables
x_ilsv_rec  := lx_ilsv_rec;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO invc_frmt_strms_update;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO invc_frmt_strms_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO invc_frmt_strms_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INVC_FRMT_STRMS_PUB','update_invc_frmt_strms');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END update_invc_frmt_strms;

PROCEDURE update_invc_frmt_strms(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_ilsv_tbl              IN  ilsv_tbl_type
    ,x_ilsv_tbl              OUT  NOCOPY ilsv_tbl_type) IS

l_api_version NUMBER;
l_init_msg_list VARCHAR2(200);
l_msg_data VARCHAR2(100);
l_msg_count NUMBER ;
l_return_status VARCHAR2(1);
lp_ilsv_tbl  ilsv_tbl_type;
lx_ilsv_tbl  ilsv_tbl_type;

BEGIN

SAVEPOINT invc_frmt_strms_update;


lp_ilsv_tbl :=  p_ilsv_tbl;
lx_ilsv_tbl :=  x_ilsv_tbl;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data := x_msg_data ;
l_msg_count := x_msg_count ;





    okl_ils_pvt.update_row(
                              l_api_version
                             ,l_init_msg_list
                             ,l_return_status
                             ,l_msg_count
                             ,l_msg_data
                             ,lp_ilsv_tbl
                             ,lx_ilsv_tbl);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_ilsv_tbl := lx_ilsv_tbl;



--Assign value to OUT variables
x_ilsv_tbl  := lx_ilsv_tbl;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO invc_frmt_strms_update;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO invc_frmt_strms_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO invc_frmt_strms_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INVC_FRMT_STRMS_PUB','update_invc_frmt_strms');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END update_invc_frmt_strms;

--Put custom code for cascade delete by developer
PROCEDURE delete_invc_frmt_strms(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_ilsv_rec              IN ilsv_rec_type) IS

i	                    NUMBER :=0;
l_return_status 	    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_ilsv_rec  ilsv_rec_type;
lx_ilsv_rec  ilsv_rec_type;

BEGIN

SAVEPOINT invc_frmt_strms_delete_rec;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_ilsv_rec :=  p_ilsv_rec;
lx_ilsv_rec :=  p_ilsv_rec;




--Delete the Master
okl_ils_pvt.delete_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_ilsv_rec);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;





--Assign value to OUT variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO invc_frmt_strms_delete_rec;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO invc_frmt_strms_delete_rec;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO invc_frmt_strms_delete_rec;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INVC_FRMT_STRMS_PUB','delete_invc_frmt_strms');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END delete_invc_frmt_strms;

PROCEDURE delete_invc_frmt_strms(
     p_api_version        IN NUMBER
    ,p_init_msg_list      IN VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status      OUT NOCOPY VARCHAR2
    ,x_msg_count          OUT NOCOPY NUMBER
    ,x_msg_data           OUT NOCOPY VARCHAR2
    ,p_ilsv_tbl           IN ilsv_tbl_type) IS

i NUMBER := 0;
l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_api_version NUMBER := p_api_version ;
l_init_msg_list VARCHAR2(1) := p_init_msg_list  ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_ilsv_tbl  ilsv_tbl_type;
lx_ilsv_tbl  ilsv_tbl_type;

BEGIN

SAVEPOINT invc_frmt_strms_delete_tbl;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_ilsv_tbl :=  p_ilsv_tbl;
lx_ilsv_tbl :=  p_ilsv_tbl;




BEGIN
      --Initialize the return status
      l_return_status := OKC_API.G_RET_STS_SUCCESS;

      IF (lp_ilsv_tbl.COUNT > 0) THEN
       	  i := p_ilsv_tbl.FIRST;
       LOOP
          delete_invc_frmt_strms(
                               l_api_version
                              ,l_init_msg_list
                              ,l_return_status
                              ,l_msg_count
                              ,l_msg_data
                              ,lp_ilsv_tbl(i));
          EXIT WHEN (i = lp_ilsv_tbl.LAST);
          i := p_ilsv_tbl.NEXT(i);
       END LOOP;
      END IF;
IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

END;





--Assign value to OUT variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO invc_frmt_strms_delete_tbl;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO invc_frmt_strms_delete_tbl;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO invc_frmt_strms_delete_tbl;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INVC_FRMT_STRMS_PUB','delete_invc_frmt_strms');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END delete_invc_frmt_strms;

PROCEDURE validate_invc_frmt_strms(
     p_api_version      IN  NUMBER
    ,p_init_msg_list    IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status    OUT  NOCOPY VARCHAR2
    ,x_msg_count        OUT  NOCOPY NUMBER
    ,x_msg_data         OUT  NOCOPY VARCHAR2
    ,p_ilsv_rec         IN  ilsv_rec_type) IS

l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_ilsv_rec  ilsv_rec_type;
lx_ilsv_rec  ilsv_rec_type;
l_return_status VARCHAR2(1);

BEGIN

SAVEPOINT invc_frmt_strms_validate;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_ilsv_rec :=  p_ilsv_rec;
lx_ilsv_rec :=  p_ilsv_rec;




okl_ils_pvt.validate_row(
                            l_api_version
                           ,l_init_msg_list
                           ,l_return_status
                           ,l_msg_count
                           ,l_msg_data
                           ,lp_ilsv_rec);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_ilsv_rec := lx_ilsv_rec;








--Assign value to OUT variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO invc_frmt_strms_validate;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO invc_frmt_strms_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO invc_frmt_strms_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INVC_FRMT_STRMS_PUB','validate_invc_frmt_strms');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END validate_invc_frmt_strms;

PROCEDURE validate_invc_frmt_strms(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status     OUT  NOCOPY VARCHAR2,
    x_msg_count         OUT  NOCOPY NUMBER,
    x_msg_data          OUT  NOCOPY VARCHAR2,
    p_ilsv_tbl          IN  ilsv_tbl_type) IS
l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_ilsv_tbl  ilsv_tbl_type;
lx_ilsv_tbl  ilsv_tbl_type;
l_return_status VARCHAR2(1);

BEGIN

SAVEPOINT invc_frmt_strms_validate;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_ilsv_tbl :=  p_ilsv_tbl;
lx_ilsv_tbl :=  p_ilsv_tbl;



okl_ils_pvt.validate_row(
                            p_api_version
                           ,p_init_msg_list
                           ,x_return_status
                           ,x_msg_count
                           ,x_msg_data
                           ,lp_ilsv_tbl);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_ilsv_tbl := lx_ilsv_tbl;





--Assign value to OUT variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO invc_frmt_strms_validate;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO invc_frmt_strms_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO invc_frmt_strms_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_INVC_FRMT_STRMS_PUB','validate_invc_frmt_strms');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END validate_invc_frmt_strms;

END OKL_INVC_FRMT_STRMS_PUB;

/
