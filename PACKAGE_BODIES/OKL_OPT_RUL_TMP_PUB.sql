--------------------------------------------------------
--  DDL for Package Body OKL_OPT_RUL_TMP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_OPT_RUL_TMP_PUB" AS
/* $Header: OKLPRTMB.pls 115.5 2004/04/13 11:03:27 rnaik noship $ */

PROCEDURE insert_Opt_Rul_Tmp(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT Fnd_Api.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_ovd_id                IN  NUMBER
    ,p_rgrv_rec              IN  rgrv_rec_type
    ,x_rgrv_rec              OUT  NOCOPY rgrv_rec_type) IS


l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
lp_rgrv_rec  rgrv_rec_type;
lx_rgrv_rec  rgrv_rec_type;

BEGIN

SAVEPOINT Opt_Rul_Tmp_insert;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_rgrv_rec :=  p_rgrv_rec;
lx_rgrv_rec :=  x_rgrv_rec;






		   Okl_Opt_Rul_Tmp_Pvt.insert_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
						 ,p_ovd_id
                         ,lp_rgrv_rec
                         ,lx_rgrv_rec);

IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	RAISE Fnd_Api.G_EXC_ERROR;
ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_rgrv_rec := lx_rgrv_rec;





--Assign value to OUT variables
x_rgrv_rec  := lx_rgrv_rec;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO Opt_Rul_Tmp_insert;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Opt_Rul_Tmp_insert;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO Opt_Rul_Tmp_insert;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_Opt_Rul_Tmp_PUB','insert_Opt_Rul_Tmp');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END insert_Opt_Rul_Tmp;

PROCEDURE insert_Opt_Rul_Tmp(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_ovd_id                IN  NUMBER
    ,p_rgrv_tbl              IN  rgrv_tbl_type
    ,x_rgrv_tbl              OUT  NOCOPY rgrv_tbl_type) IS

l_api_version NUMBER;
l_init_msg_list VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
l_return_status VARCHAR2(1);
lp_rgrv_tbl  rgrv_tbl_type;
lx_rgrv_tbl  rgrv_tbl_type;

BEGIN
SAVEPOINT Opt_Rul_Tmp_insert;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_rgrv_tbl :=  p_rgrv_tbl;
lx_rgrv_tbl :=  x_rgrv_tbl;





		   Okl_Opt_Rul_Tmp_Pvt.insert_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
						 ,p_ovd_id
                         ,lp_rgrv_tbl
                         ,lx_rgrv_tbl);

IF ( l_return_status = Fnd_Api.G_RET_STS_ERROR )  THEN
	RAISE Fnd_Api.G_EXC_ERROR;
ELSIF (l_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_rgrv_tbl := lx_rgrv_tbl;





--Assign value to OUT variables
x_rgrv_tbl  := lx_rgrv_tbl;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN Fnd_Api.G_EXC_ERROR THEN
      ROLLBACK TO Opt_Rul_Tmp_insert;
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Opt_Rul_Tmp_insert;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO Opt_Rul_Tmp_insert;
      x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('Okl_Opt_Rul_Tmp_Pub','insert_Opt_Rul_Tmp');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END insert_Opt_Rul_Tmp;

PROCEDURE lock_Opt_Rul_Tmp(
     p_api_version           IN NUMBER
    ,p_init_msg_list         IN VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_rgrv_rec              IN rgrv_rec_type) IS

BEGIN
	 NULL;
END lock_Opt_Rul_Tmp;

PROCEDURE lock_Opt_Rul_Tmp(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_rgrv_tbl              IN  rgrv_tbl_type) IS

BEGIN
	 NULL;
END lock_Opt_Rul_Tmp;

PROCEDURE update_Opt_Rul_Tmp(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_rgrv_rec              IN  rgrv_rec_type
    ,x_rgrv_rec              OUT  NOCOPY rgrv_rec_type) IS

BEGIN
	 NULL;
END update_Opt_Rul_Tmp;

PROCEDURE update_Opt_Rul_Tmp(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_rgrv_tbl              IN  rgrv_tbl_type
    ,x_rgrv_tbl              OUT  NOCOPY rgrv_tbl_type) IS

BEGIN
	 NULL;
END update_Opt_Rul_Tmp;

--Put custom code for cascade delete by developer
PROCEDURE delete_Opt_Rul_Tmp(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_rgrv_rec              IN rgrv_rec_type) IS
BEGIN
	 NULL;
END delete_Opt_Rul_Tmp;

PROCEDURE delete_Opt_Rul_Tmp(
     p_api_version        IN NUMBER
    ,p_init_msg_list      IN VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status      OUT NOCOPY VARCHAR2
    ,x_msg_count          OUT NOCOPY NUMBER
    ,x_msg_data           OUT NOCOPY VARCHAR2
    ,p_rgrv_tbl           IN rgrv_tbl_type) IS

BEGIN
	 NULL;
END delete_Opt_Rul_Tmp;

PROCEDURE validate_Opt_Rul_Tmp(
     p_api_version      IN  NUMBER
    ,p_init_msg_list    IN  VARCHAR2 DEFAULT FND_API.G_FALSE
    ,x_return_status    OUT  NOCOPY VARCHAR2
    ,x_msg_count        OUT  NOCOPY NUMBER
    ,x_msg_data         OUT  NOCOPY VARCHAR2
    ,p_rgrv_rec         IN  rgrv_rec_type) IS

BEGIN
	 NULL;
END validate_Opt_Rul_Tmp;

PROCEDURE validate_Opt_Rul_Tmp(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_return_status     OUT  NOCOPY VARCHAR2,
    x_msg_count         OUT  NOCOPY NUMBER,
    x_msg_data          OUT  NOCOPY VARCHAR2,
    p_rgrv_tbl          IN  rgrv_tbl_type) IS

BEGIN
	 NULL;
END validate_Opt_Rul_Tmp;

END Okl_Opt_Rul_Tmp_Pub;

/
