--------------------------------------------------------
--  DDL for Package Body OKL_CSH_ALLCTN_RL_HDR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CSH_ALLCTN_RL_HDR_PUB" AS
/* $Header: OKLPCAUB.pls 120.4 2006/07/13 12:21:20 adagur noship $ */

PROCEDURE insert_csh_allctn_rl_hdr(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_cauv_rec              IN  cauv_rec_type
    ,x_cauv_rec              OUT  NOCOPY cauv_rec_type) IS


l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
lp_cauv_rec  cauv_rec_type;
lx_cauv_rec  cauv_rec_type;

BEGIN

SAVEPOINT csh_allctn_rl_hdr_insert;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_cauv_rec :=  p_cauv_rec;
lx_cauv_rec :=  x_cauv_rec;


lp_cauv_rec.org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();




-- Private API Call start
okl_cau_pvt.insert_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_cauv_rec
                         ,lx_cauv_rec);
-- Private API Call start

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_cauv_rec := lx_cauv_rec;





--Assign value to OUT variables
x_cauv_rec  := lx_cauv_rec;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO csh_allctn_rl_hdr_insert;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO csh_allctn_rl_hdr_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO csh_allctn_rl_hdr_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_CSH_ALLCTN_RL_HDR_PUB','insert_csh_allctn_rl_hdr');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END insert_csh_allctn_rl_hdr;

PROCEDURE insert_csh_allctn_rl_hdr(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_cauv_tbl              IN  cauv_tbl_type
    ,x_cauv_tbl              OUT  NOCOPY cauv_tbl_type) IS

l_api_version NUMBER;
l_init_msg_list VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
l_return_status VARCHAR2(1);
lp_cauv_tbl  cauv_tbl_type;
lx_cauv_tbl  cauv_tbl_type;

BEGIN

SAVEPOINT csh_allctn_rl_hdr_insert;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_cauv_tbl :=  p_cauv_tbl;
lx_cauv_tbl :=  x_cauv_tbl;

for i in 1..lp_cauv_tbl.count
LOOP
lp_cauv_tbl(i).org_id := MO_GLOBAL.GET_CURRENT_ORG_ID();

END LOOP;



-- Private API Call start
okl_cau_pvt.insert_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_cauv_tbl
                         ,lx_cauv_tbl);
-- Private API Call end

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_cauv_tbl := lx_cauv_tbl;



--Assign value to OUT variables
x_cauv_tbl  := lx_cauv_tbl;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO csh_allctn_rl_hdr_insert;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO csh_allctn_rl_hdr_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO csh_allctn_rl_hdr_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_CSH_ALLCTN_RL_HDR_PUB','insert_csh_allctn_rl_hdr');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END insert_csh_allctn_rl_hdr;

PROCEDURE lock_csh_allctn_rl_hdr(
     p_api_version           IN NUMBER
    ,p_init_msg_list         IN VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_cauv_rec              IN cauv_rec_type) IS

BEGIN
    okl_cau_pvt.lock_row(
		    p_api_version,
		    p_init_msg_list,
		    x_return_status,
		    x_msg_count,
		    x_msg_data,
		    p_cauv_rec);

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
      FND_MSG_PUB.ADD_EXC_MSG('OKL_CSH_ALLCTN_RL_HDR_PUB','lock_csh_allctn_rl_hdr');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END lock_csh_allctn_rl_hdr;

PROCEDURE lock_csh_allctn_rl_hdr(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_cauv_tbl              IN  cauv_tbl_type) IS

BEGIN
    okl_cau_pvt.lock_row(
		    p_api_version,
		    p_init_msg_list,
		    x_return_status,
		    x_msg_count,
		    x_msg_data,
		    p_cauv_tbl);

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
      FND_MSG_PUB.ADD_EXC_MSG('OKL_CSH_ALLCTN_RL_HDR_PUB','lock_csh_allctn_rl_hdr');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END lock_csh_allctn_rl_hdr;

PROCEDURE update_csh_allctn_rl_hdr(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_cauv_rec              IN  cauv_rec_type
    ,x_cauv_rec              OUT  NOCOPY cauv_rec_type) IS

l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
lp_cauv_rec  cauv_rec_type;
lx_cauv_rec  cauv_rec_type;

BEGIN

SAVEPOINT csh_allctn_rl_hdr_update;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_cauv_rec :=  p_cauv_rec;
lx_cauv_rec :=  x_cauv_rec;





-- Private API Call start
    okl_cau_pvt.update_row(
                              l_api_version
                             ,l_init_msg_list
                             ,l_return_status
                             ,l_msg_count
                             ,l_msg_data
                             ,lp_cauv_rec
                             ,lx_cauv_rec);
-- Private API Call end

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_cauv_rec := lx_cauv_rec;




--Assign value to OUT variables
x_cauv_rec  := lx_cauv_rec;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO csh_allctn_rl_hdr_update;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO csh_allctn_rl_hdr_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO csh_allctn_rl_hdr_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_CSH_ALLCTN_RL_HDR_PUB','update_csh_allctn_rl_hdr');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END update_csh_allctn_rl_hdr;

PROCEDURE update_csh_allctn_rl_hdr(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_cauv_tbl              IN  cauv_tbl_type
    ,x_cauv_tbl              OUT  NOCOPY cauv_tbl_type) IS

l_api_version NUMBER;
l_init_msg_list VARCHAR2(200);
l_msg_data VARCHAR2(100);
l_msg_count NUMBER ;
l_return_status VARCHAR2(1);
lp_cauv_tbl  cauv_tbl_type;
lx_cauv_tbl  cauv_tbl_type;

BEGIN

SAVEPOINT csh_allctn_rl_hdr_update;


lp_cauv_tbl :=  p_cauv_tbl;
lx_cauv_tbl :=  x_cauv_tbl;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data := x_msg_data ;
l_msg_count := x_msg_count ;





-- Private API Call start
    okl_cau_pvt.update_row(
                              l_api_version
                             ,l_init_msg_list
                             ,l_return_status
                             ,l_msg_count
                             ,l_msg_data
                             ,lp_cauv_tbl
                             ,lx_cauv_tbl);
-- Private API Call end

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_cauv_tbl := lx_cauv_tbl;



--Assign value to OUT variables
x_cauv_tbl  := lx_cauv_tbl;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO csh_allctn_rl_hdr_update;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO csh_allctn_rl_hdr_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO csh_allctn_rl_hdr_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_CSH_ALLCTN_RL_HDR_PUB','update_csh_allctn_rl_hdr');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END update_csh_allctn_rl_hdr;

--Put custom code for cascade delete by developer
PROCEDURE delete_csh_allctn_rl_hdr(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_cauv_rec              IN cauv_rec_type) IS

i	                    NUMBER :=0;
l_return_status 	    VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_cauv_rec  cauv_rec_type;
lx_cauv_rec  cauv_rec_type;

BEGIN

SAVEPOINT csh_allctn_rl_hdr_delete_rec;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_cauv_rec :=  p_cauv_rec;
lx_cauv_rec :=  p_cauv_rec;




--Delete the Master
-- Private API Call start
okl_cau_pvt.delete_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_cauv_rec);
-- Private API Call end

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
      ROLLBACK TO csh_allctn_rl_hdr_delete_rec;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO csh_allctn_rl_hdr_delete_rec;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO csh_allctn_rl_hdr_delete_rec;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_CSH_ALLCTN_RL_HDR_PUB','delete_csh_allctn_rl_hdr');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END delete_csh_allctn_rl_hdr;

PROCEDURE delete_csh_allctn_rl_hdr(
     p_api_version        IN NUMBER
    ,p_init_msg_list      IN VARCHAR2
    ,x_return_status      OUT NOCOPY VARCHAR2
    ,x_msg_count          OUT NOCOPY NUMBER
    ,x_msg_data           OUT NOCOPY VARCHAR2
    ,p_cauv_tbl           IN cauv_tbl_type) IS

i NUMBER := 0;
l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_api_version NUMBER := p_api_version ;
l_init_msg_list VARCHAR2(1) := p_init_msg_list  ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_cauv_tbl  cauv_tbl_type;
lx_cauv_tbl  cauv_tbl_type;

BEGIN

SAVEPOINT csh_allctn_rl_hdr_delete_tbl;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_cauv_tbl :=  p_cauv_tbl;
lx_cauv_tbl :=  p_cauv_tbl;




BEGIN
      --Initialize the return status
      l_return_status := OKC_API.G_RET_STS_SUCCESS;

      IF (lp_cauv_tbl.COUNT > 0) THEN
       	  i := p_cauv_tbl.FIRST;
       LOOP
          delete_csh_allctn_rl_hdr(
                               l_api_version
                              ,l_init_msg_list
                              ,l_return_status
                              ,l_msg_count
                              ,l_msg_data
                              ,lp_cauv_tbl(i));
          EXIT WHEN (i = lp_cauv_tbl.LAST);
          i := p_cauv_tbl.NEXT(i);
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
      ROLLBACK TO csh_allctn_rl_hdr_delete_tbl;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO csh_allctn_rl_hdr_delete_tbl;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO csh_allctn_rl_hdr_delete_tbl;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_CSH_ALLCTN_RL_HDR_PUB','delete_csh_allctn_rl_hdr');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END delete_csh_allctn_rl_hdr;

PROCEDURE validate_csh_allctn_rl_hdr(
     p_api_version      IN  NUMBER
    ,p_init_msg_list    IN  VARCHAR2
    ,x_return_status    OUT  NOCOPY VARCHAR2
    ,x_msg_count        OUT  NOCOPY NUMBER
    ,x_msg_data         OUT  NOCOPY VARCHAR2
    ,p_cauv_rec         IN  cauv_rec_type) IS

l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_cauv_rec  cauv_rec_type;
lx_cauv_rec  cauv_rec_type;
l_return_status VARCHAR2(1);

BEGIN

SAVEPOINT csh_allctn_rl_hdr_validate;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_cauv_rec :=  p_cauv_rec;
lx_cauv_rec :=  p_cauv_rec;




-- Private API Call start
okl_cau_pvt.validate_row(
                            l_api_version
                           ,l_init_msg_list
                           ,l_return_status
                           ,l_msg_count
                           ,l_msg_data
                           ,lp_cauv_rec);
-- Private API Call end

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_cauv_rec := lx_cauv_rec;





--Assign value to OUT variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO csh_allctn_rl_hdr_validate;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO csh_allctn_rl_hdr_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO csh_allctn_rl_hdr_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_CSH_ALLCTN_RL_HDR_PUB','validate_csh_allctn_rl_hdr');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END validate_csh_allctn_rl_hdr;

PROCEDURE validate_csh_allctn_rl_hdr(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2 ,
    x_return_status     OUT  NOCOPY VARCHAR2,
    x_msg_count         OUT  NOCOPY NUMBER,
    x_msg_data          OUT  NOCOPY VARCHAR2,
    p_cauv_tbl          IN  cauv_tbl_type) IS
l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_cauv_tbl  cauv_tbl_type;
lx_cauv_tbl  cauv_tbl_type;
l_return_status VARCHAR2(1);

BEGIN

SAVEPOINT csh_allctn_rl_hdr_validate;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_cauv_tbl :=  p_cauv_tbl;
lx_cauv_tbl :=  p_cauv_tbl;



-- Private API Call start
okl_cau_pvt.validate_row(
                            p_api_version
                           ,p_init_msg_list
                           ,x_return_status
                           ,x_msg_count
                           ,x_msg_data
                           ,lp_cauv_tbl);
-- Private API Call end

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_cauv_tbl := lx_cauv_tbl;



--Assign value to OUT variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO csh_allctn_rl_hdr_validate;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO csh_allctn_rl_hdr_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO csh_allctn_rl_hdr_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_CSH_ALLCTN_RL_HDR_PUB','validate_csh_allctn_rl_hdr');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END validate_csh_allctn_rl_hdr;

END OKL_CSH_ALLCTN_RL_HDR_PUB;

/
