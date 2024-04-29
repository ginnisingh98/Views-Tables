--------------------------------------------------------
--  DDL for Package Body OKL_CSH_ALLCT_SRCHS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CSH_ALLCT_SRCHS_PUB" AS
/* $Header: OKLPCAHB.pls 120.3 2006/07/07 09:55:31 adagur noship $ */

PROCEDURE insert_csh_allct_srchs(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_cahv_rec              IN  cahv_rec_type
    ,x_cahv_rec              OUT  NOCOPY cahv_rec_type) IS


l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
lp_cahv_rec  cahv_rec_type;
lx_cahv_rec  cahv_rec_type;

BEGIN

SAVEPOINT csh_allct_srchs_insert;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_cahv_rec :=  p_cahv_rec;
lx_cahv_rec :=  x_cahv_rec;



lp_cahv_rec.org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();



Okl_Cah_Pvt.insert_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_cahv_rec
                         ,lx_cahv_rec);

IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	RAISE Fnd_Api.G_EXC_ERROR;
ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_cahv_rec := lx_cahv_rec;





--Assign value to OUT variables
x_cahv_rec  := lx_cahv_rec;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO csh_allct_srchs_insert;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO csh_allct_srchs_insert;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO csh_allct_srchs_insert;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_CSH_ALLCT_SRCHS_PUB','insert_csh_allct_srchs');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END insert_csh_allct_srchs;

PROCEDURE insert_csh_allct_srchs(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_cahv_tbl              IN  cahv_tbl_type
    ,x_cahv_tbl              OUT  NOCOPY cahv_tbl_type) IS

l_api_version NUMBER;
l_init_msg_list VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
l_return_status VARCHAR2(1);
lp_cahv_tbl  cahv_tbl_type;
lx_cahv_tbl  cahv_tbl_type;

BEGIN

SAVEPOINT csh_allct_srchs_insert;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_cahv_tbl :=  p_cahv_tbl;
lx_cahv_tbl :=  x_cahv_tbl;

for i in 1..lp_cahv_tbl.count
LOOP
  lp_cahv_tbl(i).org_id  := MO_GLOBAL.GET_CURRENT_ORG_ID();
END LOOP;



Okl_Cah_Pvt.insert_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_cahv_tbl
                         ,lx_cahv_tbl);

IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	RAISE Fnd_Api.G_EXC_ERROR;
ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_cahv_tbl := lx_cahv_tbl;



--Assign value to OUT variables
x_cahv_tbl  := lx_cahv_tbl;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO csh_allct_srchs_insert;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO csh_allct_srchs_insert;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO csh_allct_srchs_insert;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_CSH_ALLCT_SRCHS_PUB','insert_csh_allct_srchs');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END insert_csh_allct_srchs;

PROCEDURE lock_csh_allct_srchs(
     p_api_version           IN NUMBER
    ,p_init_msg_list         IN VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_cahv_rec              IN cahv_rec_type) IS

BEGIN
    Okl_Cah_Pvt.lock_row(
		    p_api_version,
		    p_init_msg_list,
		    x_return_status,
		    x_msg_count,
		    x_msg_data,
		    p_cahv_rec);

IF ( x_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	RAISE Fnd_Api.G_EXC_ERROR;
ELSIF (x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
END IF;


EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_CSH_ALLCT_SRCHS_PUB','lock_csh_allct_srchs');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END lock_csh_allct_srchs;

PROCEDURE lock_csh_allct_srchs(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_cahv_tbl              IN  cahv_tbl_type) IS

BEGIN
    Okl_Cah_Pvt.lock_row(
		    p_api_version,
		    p_init_msg_list,
		    x_return_status,
		    x_msg_count,
		    x_msg_data,
		    p_cahv_tbl);

IF ( x_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	RAISE Fnd_Api.G_EXC_ERROR;
ELSIF (x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
END IF;


EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_CSH_ALLCT_SRCHS_PUB','lock_csh_allct_srchs');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END lock_csh_allct_srchs;

PROCEDURE update_csh_allct_srchs(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_cahv_rec              IN  cahv_rec_type
    ,x_cahv_rec              OUT  NOCOPY cahv_rec_type) IS

l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
lp_cahv_rec  cahv_rec_type;
lx_cahv_rec  cahv_rec_type;

BEGIN

SAVEPOINT csh_allct_srchs_update;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_cahv_rec :=  p_cahv_rec;
lx_cahv_rec :=  x_cahv_rec;



lp_cahv_rec.org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();




    Okl_Cah_Pvt.update_row(
                              l_api_version
                             ,l_init_msg_list
                             ,l_return_status
                             ,l_msg_count
                             ,l_msg_data
                             ,lp_cahv_rec
                             ,lx_cahv_rec);

IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	RAISE Fnd_Api.G_EXC_ERROR;
ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_cahv_rec := lx_cahv_rec;




--Assign value to OUT variables
x_cahv_rec  := lx_cahv_rec;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO csh_allct_srchs_update;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO csh_allct_srchs_update;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO csh_allct_srchs_update;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_CSH_ALLCT_SRCHS_PUB','update_csh_allct_srchs');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END update_csh_allct_srchs;

PROCEDURE update_csh_allct_srchs(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_cahv_tbl              IN  cahv_tbl_type
    ,x_cahv_tbl              OUT  NOCOPY cahv_tbl_type) IS

l_api_version NUMBER;
l_init_msg_list VARCHAR2(200);
l_msg_data VARCHAR2(100);
l_msg_count NUMBER ;
l_return_status VARCHAR2(1);
lp_cahv_tbl  cahv_tbl_type;
lx_cahv_tbl  cahv_tbl_type;

BEGIN

SAVEPOINT csh_allct_srchs_update;


lp_cahv_tbl :=  p_cahv_tbl;
lx_cahv_tbl :=  x_cahv_tbl;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data := x_msg_data ;
l_msg_count := x_msg_count ;

for i in 1..lp_cahv_tbl.count
LOOP
lp_cahv_tbl(i).org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();
END LOOP;




    Okl_Cah_Pvt.update_row(
                              l_api_version
                             ,l_init_msg_list
                             ,l_return_status
                             ,l_msg_count
                             ,l_msg_data
                             ,lp_cahv_tbl
                             ,lx_cahv_tbl);

IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	RAISE Fnd_Api.G_EXC_ERROR;
ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_cahv_tbl := lx_cahv_tbl;



--Assign value to OUT variables
x_cahv_tbl  := lx_cahv_tbl;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO csh_allct_srchs_update;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO csh_allct_srchs_update;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO csh_allct_srchs_update;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_CSH_ALLCT_SRCHS_PUB','update_csh_allct_srchs');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END update_csh_allct_srchs;

--Put custom code for cascade delete by developer
PROCEDURE delete_csh_allct_srchs(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_cahv_rec              IN cahv_rec_type) IS

i	                    NUMBER :=0;
l_return_status 	    VARCHAR2(1) := Fnd_Api.G_RET_STS_SUCCESS;
l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_cahv_rec  cahv_rec_type;
lx_cahv_rec  cahv_rec_type;

BEGIN

SAVEPOINT csh_allct_srchs_delete_rec;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_cahv_rec :=  p_cahv_rec;
lx_cahv_rec :=  p_cahv_rec;




--Delete the Master
Okl_Cah_Pvt.delete_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_cahv_rec);

IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	RAISE Fnd_Api.G_EXC_ERROR;
ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
END IF;





--Assign value to OUT variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
x_return_status := l_return_status ;

EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO csh_allct_srchs_delete_rec;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO csh_allct_srchs_delete_rec;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO csh_allct_srchs_delete_rec;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_CSH_ALLCT_SRCHS_PUB','delete_csh_allct_srchs');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END delete_csh_allct_srchs;

PROCEDURE delete_csh_allct_srchs(
     p_api_version        IN NUMBER
    ,p_init_msg_list      IN VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status      OUT NOCOPY VARCHAR2
    ,x_msg_count          OUT NOCOPY NUMBER
    ,x_msg_data           OUT NOCOPY VARCHAR2
    ,p_cahv_tbl           IN cahv_tbl_type) IS

i NUMBER := 0;
l_return_status VARCHAR2(1) := Fnd_Api.G_RET_STS_SUCCESS;
l_api_version NUMBER := p_api_version ;
l_init_msg_list VARCHAR2(1) := p_init_msg_list  ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_cahv_tbl  cahv_tbl_type;
lx_cahv_tbl  cahv_tbl_type;

BEGIN

SAVEPOINT csh_allct_srchs_delete_tbl;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_cahv_tbl :=  p_cahv_tbl;
lx_cahv_tbl :=  p_cahv_tbl;




BEGIN
      --Initialize the return status
      l_return_status := Fnd_Api.G_RET_STS_SUCCESS;

      IF (lp_cahv_tbl.COUNT > 0) THEN
       	  i := p_cahv_tbl.FIRST;
       LOOP
          delete_csh_allct_srchs(
                               l_api_version
                              ,l_init_msg_list
                              ,l_return_status
                              ,l_msg_count
                              ,l_msg_data
                              ,lp_cahv_tbl(i));
          EXIT WHEN (i = lp_cahv_tbl.LAST);
          i := p_cahv_tbl.NEXT(i);
       END LOOP;
      END IF;
IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	RAISE Fnd_Api.G_EXC_ERROR;
ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
END IF;

END;





--Assign value to OUT variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

x_return_status := l_return_status ;

EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO csh_allct_srchs_delete_tbl;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO csh_allct_srchs_delete_tbl;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO csh_allct_srchs_delete_tbl;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_CSH_ALLCT_SRCHS_PUB','delete_csh_allct_srchs');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END delete_csh_allct_srchs;

PROCEDURE validate_csh_allct_srchs(
     p_api_version      IN  NUMBER
    ,p_init_msg_list    IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status    OUT  NOCOPY VARCHAR2
    ,x_msg_count        OUT  NOCOPY NUMBER
    ,x_msg_data         OUT  NOCOPY VARCHAR2
    ,p_cahv_rec         IN  cahv_rec_type) IS

l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_cahv_rec  cahv_rec_type;
lx_cahv_rec  cahv_rec_type;
l_return_status VARCHAR2(1);

BEGIN

SAVEPOINT csh_allct_srchs_validate;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_cahv_rec :=  p_cahv_rec;
lx_cahv_rec :=  p_cahv_rec;




Okl_Cah_Pvt.validate_row(
                            l_api_version
                           ,l_init_msg_list
                           ,l_return_status
                           ,l_msg_count
                           ,l_msg_data
                           ,lp_cahv_rec);

IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	RAISE Fnd_Api.G_EXC_ERROR;
ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_cahv_rec := lx_cahv_rec;








--Assign value to OUT variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

x_return_status := l_return_status ;

EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO csh_allct_srchs_validate;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO csh_allct_srchs_validate;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO csh_allct_srchs_validate;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_CSH_ALLCT_SRCHS_PUB','validate_csh_allct_srchs');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END validate_csh_allct_srchs;

PROCEDURE validate_csh_allct_srchs(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE,
    x_return_status     OUT  NOCOPY VARCHAR2,
    x_msg_count         OUT  NOCOPY NUMBER,
    x_msg_data          OUT  NOCOPY VARCHAR2,
    p_cahv_tbl          IN  cahv_tbl_type) IS
l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_cahv_tbl  cahv_tbl_type;
lx_cahv_tbl  cahv_tbl_type;
l_return_status VARCHAR2(1);

BEGIN

SAVEPOINT csh_allct_srchs_validate;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_cahv_tbl :=  p_cahv_tbl;
lx_cahv_tbl :=  p_cahv_tbl;



Okl_Cah_Pvt.validate_row(
                            p_api_version
                           ,p_init_msg_list
                           ,x_return_status
                           ,x_msg_count
                           ,x_msg_data
                           ,lp_cahv_tbl);

IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	RAISE Fnd_Api.G_EXC_ERROR;
ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_cahv_tbl := lx_cahv_tbl;





--Assign value to OUT variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

x_return_status := l_return_status ;

EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO csh_allct_srchs_validate;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO csh_allct_srchs_validate;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO csh_allct_srchs_validate;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_CSH_ALLCT_SRCHS_PUB','validate_csh_allct_srchs');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END validate_csh_allct_srchs;

END Okl_Csh_Allct_Srchs_Pub;

/
