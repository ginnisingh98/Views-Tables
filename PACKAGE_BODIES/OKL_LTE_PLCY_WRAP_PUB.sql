--------------------------------------------------------
--  DDL for Package Body OKL_LTE_PLCY_WRAP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LTE_PLCY_WRAP_PUB" AS
/* $Header: OKLPLPWB.pls 115.1 2004/04/13 10:52:30 rnaik noship $ */

PROCEDURE create_late_policies(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_lpov_rec              IN  lpov_rec_type
    ,x_lpov_rec              OUT  NOCOPY lpov_rec_type) IS


l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
lp_lpov_rec  lpov_rec_type;
lx_lpov_rec  lpov_rec_type;

BEGIN

SAVEPOINT late_policies_create;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_lpov_rec :=  p_lpov_rec;
lx_lpov_rec :=  x_lpov_rec;



Okl_Late_Policies_Pub.insert_late_policies(
                           p_api_version => l_api_version
                          ,p_init_msg_list => l_init_msg_list
                          ,x_return_status => l_return_status
                          ,x_msg_count => l_msg_count
                          ,x_msg_data => l_msg_data
                          ,p_lpov_rec => lp_lpov_rec
                          ,x_lpov_rec => lx_lpov_rec);


IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_lpov_rec := lx_lpov_rec;



OKL_LPO_STRM_PUB.create_lpo_streams(
                           p_api_version => l_api_version
                          ,p_init_msg_list => l_init_msg_list
                          ,x_return_status => l_return_status
                          ,x_msg_count => l_msg_count
                          ,x_msg_data => l_msg_data
                          ,p_lpo_id => lp_lpov_rec.id);


IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Assign value to OUT variables
x_lpov_rec  := lx_lpov_rec;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO late_policies_create;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO late_policies_create;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO late_policies_create;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_LTE_PLCY_WRAP_PUB','create_late_policies');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END create_late_policies;

PROCEDURE create_late_policies(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_lpov_tbl              IN  lpov_tbl_type
    ,x_lpov_tbl              OUT  NOCOPY lpov_tbl_type) IS

l_api_version NUMBER;
l_init_msg_list VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
l_return_status VARCHAR2(1);
lp_lpov_tbl  lpov_tbl_type;
lx_lpov_tbl  lpov_tbl_type;

i NUMBER := 0;

BEGIN

SAVEPOINT late_policies_create;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_lpov_tbl :=  p_lpov_tbl;
lx_lpov_tbl :=  x_lpov_tbl;



IF (lp_lpov_tbl.COUNT > 0) THEN
      i := lp_lpov_tbl.FIRST;
      LOOP
        create_late_policies (
           p_api_version                  => l_api_version,
           p_init_msg_list                => l_init_msg_list,
           x_return_status                => l_return_status,
           x_msg_count                    => l_msg_count,
           x_msg_data                     => l_msg_data,
           p_lpov_rec                     => lp_lpov_tbl(i),
           x_lpov_rec                     => lx_lpov_tbl(i));

        IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        EXIT WHEN (i = lp_lpov_tbl.LAST);
        i := lp_lpov_tbl.NEXT(i);
      END LOOP;
END IF;



--Copy value of OUT variable in the IN record type
lp_lpov_tbl := lx_lpov_tbl;



--Assign value to OUT variables
x_lpov_tbl  := lx_lpov_tbl;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO late_policies_create;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO late_policies_create;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO late_policies_create;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      Fnd_Msg_Pub.ADD_EXC_MSG('OKL_LTE_PLCY_WRAP_PUB','create_late_policies');
      Fnd_Msg_Pub.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END create_late_policies;

END OKL_LTE_PLCY_WRAP_PUB;

/
