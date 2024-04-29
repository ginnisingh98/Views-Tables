--------------------------------------------------------
--  DDL for Package Body IEX_EXCLUSION_HIST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_EXCLUSION_HIST_PUB" AS
/* $Header: IEXPIEHB.pls 120.7 2005/11/17 20:38:43 jsanju ship $ */

PROCEDURE insert_exclusion_hist(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_iehv_rec              IN  iehv_rec_type
    ,x_iehv_rec              OUT  NOCOPY iehv_rec_type) IS


l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
lp_iehv_rec  iehv_rec_type;
lx_iehv_rec  iehv_rec_type;

BEGIN

SAVEPOINT exclusion_hist_insert;


l_api_version := p_api_version ;
l_init_msg_list := FND_API.G_FALSE ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_iehv_rec :=  p_iehv_rec;
lx_iehv_rec :=  x_iehv_rec;

/*
--Customer pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_exclusion_hist', 'B', 'C')) THEN
	iex_exclusion_hist_cuhk.insert_exclusion_hist_pre (
	                                            p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_iehv_rec => lp_iehv_rec
	                                           ,x_iehv_rec => lx_iehv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT record type variable in the IN record type
	lp_iehv_rec := lx_iehv_rec;

END IF;
--Customer pre-processing user hook call end



--Vertical pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_exclusion_hist', 'B', 'V')) THEN
	iex_exclusion_hist_vuhk.insert_exclusion_hist_pre (
	                                              p_init_msg_list => l_init_msg_list
	                                             ,x_msg_data => l_msg_data
	                                             ,x_msg_count => l_msg_count
	                                             ,x_return_status => l_return_status
	                                             ,p_iehv_rec => lp_iehv_rec
	                                             ,x_iehv_rec => lx_iehv_rec );
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_iehv_rec := lx_iehv_rec;

END IF;
--Vertical pre-processing user hook call end
*/
iex_ieh_pvt.insert_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_iehv_rec
                         ,lx_iehv_rec);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_iehv_rec := lx_iehv_rec;

/*
--Vertical post processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_exclusion_hist', 'A', 'V')) THEN
	iex_exclusion_hist_vuhk.insert_exclusion_hist_post(
	                                               p_init_msg_list => l_init_msg_list
	                                              ,x_msg_data => l_msg_data
	                                              ,x_msg_count => l_msg_count
	                                              ,x_return_status => l_return_status
	                                              ,p_iehv_rec => lp_iehv_rec);
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Vertical post processing user hook call end


--Customer post processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_exclusion_hist', 'A', 'C')) THEN
	iex_exclusion_hist_cuhk.insert_exclusion_hist_post(
	                                               p_init_msg_list => l_init_msg_list
	                                              ,x_msg_data => l_msg_data
	                                              ,x_msg_count => l_msg_count
	                                              ,x_return_status => l_return_status
	                                              ,p_iehv_rec => lp_iehv_rec);
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Customer post processing user hook call end
*/

--Assign value to OUT variables
x_iehv_rec  := lx_iehv_rec;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO exclusion_hist_insert;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO exclusion_hist_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO exclusion_hist_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_EXCLUSION_HIST_PUB','insert_exclusion_hist');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END insert_exclusion_hist;

PROCEDURE insert_exclusion_hist(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_iehv_tbl              IN  iehv_tbl_type
    ,x_iehv_tbl              OUT  NOCOPY iehv_tbl_type) IS

l_api_version NUMBER;
l_init_msg_list VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
l_return_status VARCHAR2(1);
lp_iehv_tbl  iehv_tbl_type;
lx_iehv_tbl  iehv_tbl_type;

BEGIN

SAVEPOINT exclusion_hist_insert;


l_api_version := p_api_version ;
l_init_msg_list := FND_API.G_FALSE ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_iehv_tbl :=  p_iehv_tbl;
lx_iehv_tbl :=  x_iehv_tbl;

/*
--Customer pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_exclusion_hist', 'B', 'C')) THEN
	iex_exclusion_hist_cuhk.insert_exclusion_hist_pre(
	                                            p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_iehv_tbl => lp_iehv_tbl
	                                           ,x_iehv_tbl => lx_iehv_tbl);
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_iehv_tbl := lx_iehv_tbl;

END IF;
--Customer pre-processing user hook call end

--Vertical pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_exclusion_hist', 'B', 'V')) THEN
	iex_exclusion_hist_vuhk.insert_exclusion_hist_pre(
	                                            p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_iehv_tbl => lp_iehv_tbl
	                                           ,x_iehv_tbl => lx_iehv_tbl);
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_iehv_tbl := lx_iehv_tbl;

END IF;
--Vertical pre-processing user hook call end
*/
iex_ieh_pvt.insert_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_iehv_tbl
                         ,lx_iehv_tbl);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_iehv_tbl := lx_iehv_tbl;

/*
--Vertical post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_exclusion_hist', 'A', 'V')) THEN
	iex_exclusion_hist_vuhk.insert_exclusion_hist_post (
	                                            p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_iehv_tbl => lp_iehv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Vertical post-processing user hook call end

--Customer post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_exclusion_hist', 'A', 'C')) THEN
	iex_exclusion_hist_cuhk.insert_exclusion_hist_post (
	                                            p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_iehv_tbl  => lp_iehv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Customer post-processing user hook call end
*/

--Assign value to OUT variables
x_iehv_tbl  := lx_iehv_tbl;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO exclusion_hist_insert;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO exclusion_hist_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO exclusion_hist_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_EXCLUSION_HIST_PUB','insert_exclusion_hist');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END insert_exclusion_hist;

PROCEDURE lock_exclusion_hist(
     p_api_version           IN NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_iehv_rec              IN iehv_rec_type) IS

BEGIN
    iex_ieh_pvt.lock_row(
		    p_api_version,
		    p_init_msg_list,
		    x_return_status,
		    x_msg_count,
		    x_msg_data,
		    p_iehv_rec);

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
      FND_MSG_PUB.ADD_EXC_MSG('IEX_EXCLUSION_HIST_PUB','lock_exclusion_hist');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END lock_exclusion_hist;

PROCEDURE lock_exclusion_hist(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_iehv_tbl              IN  iehv_tbl_type) IS

BEGIN
    iex_ieh_pvt.lock_row(
		    p_api_version,
		    p_init_msg_list,
		    x_return_status,
		    x_msg_count,
		    x_msg_data,
		    p_iehv_tbl);

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
      FND_MSG_PUB.ADD_EXC_MSG('IEX_EXCLUSION_HIST_PUB','lock_exclusion_hist');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END lock_exclusion_hist;

PROCEDURE update_exclusion_hist(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_iehv_rec              IN  iehv_rec_type
    ,x_iehv_rec              OUT  NOCOPY iehv_rec_type) IS

l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
lp_iehv_rec  iehv_rec_type;
lx_iehv_rec  iehv_rec_type;

BEGIN

SAVEPOINT exclusion_hist_update;


l_api_version := p_api_version ;
l_init_msg_list := FND_API.G_FALSE ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_iehv_rec :=  p_iehv_rec;
lx_iehv_rec :=  x_iehv_rec;

/*
--Customer pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_exclusion_hist', 'B', 'C')) THEN
	iex_exclusion_hist_cuhk.update_exclusion_hist_pre (
	                                            p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_iehv_rec => lp_iehv_rec
	                                           ,x_iehv_rec => lx_iehv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_iehv_rec := lx_iehv_rec;

END IF;
--Customer pre-processing user hook call end


--Vertical pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_exclusion_hist', 'B', 'V')) THEN
	iex_exclusion_hist_vuhk.update_exclusion_hist_pre (
	                                           p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_iehv_rec => lp_iehv_rec
	                                           ,x_iehv_rec => lx_iehv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_iehv_rec := lx_iehv_rec;

END IF;
--Vertical pre-processing user hook call end
*/
    iex_ieh_pvt.update_row(
                              l_api_version
                             ,l_init_msg_list
                             ,l_return_status
                             ,l_msg_count
                             ,l_msg_data
                             ,lp_iehv_rec
                             ,lx_iehv_rec);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_iehv_rec := lx_iehv_rec;
/*
--Vertical post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_exclusion_hist', 'A', 'V')) THEN
	iex_exclusion_hist_vuhk.update_exclusion_hist_post (
	                                           p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_iehv_rec => lp_iehv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Vertical post-processing user hook call end


--Customer post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_exclusion_hist', 'A', 'C')) THEN
	iex_exclusion_hist_cuhk.update_exclusion_hist_post (
	                                           p_init_msg_list=>l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_iehv_rec => lp_iehv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Customer post-processing user hook call end
*/
--Assign value to OUT variables
x_iehv_rec  := lx_iehv_rec;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO exclusion_hist_update;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO exclusion_hist_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO exclusion_hist_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_EXCLUSION_HIST_PUB','update_exclusion_hist');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END update_exclusion_hist;

PROCEDURE update_exclusion_hist(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_iehv_tbl              IN  iehv_tbl_type
    ,x_iehv_tbl              OUT  NOCOPY iehv_tbl_type) IS

l_api_version NUMBER;
l_init_msg_list VARCHAR2(200);
l_msg_data VARCHAR2(100);
l_msg_count NUMBER ;
l_return_status VARCHAR2(1);
lp_iehv_tbl  iehv_tbl_type;
lx_iehv_tbl  iehv_tbl_type;

BEGIN

SAVEPOINT exclusion_hist_update;


lp_iehv_tbl :=  p_iehv_tbl;
lx_iehv_tbl :=  x_iehv_tbl;
l_api_version := p_api_version ;
l_init_msg_list := FND_API.G_FALSE ;
l_msg_data := x_msg_data ;
l_msg_count := x_msg_count ;

/*
--Customer pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_exclusion_hist', 'B', 'C')) THEN
	iex_exclusion_hist_cuhk.update_exclusion_hist_pre (
	                                              p_init_msg_list => l_init_msg_list
	                                             ,x_msg_data => l_msg_data
	                                             ,x_msg_count => l_msg_count
	                                             ,x_return_status => l_return_status
	                                             ,p_iehv_tbl => lp_iehv_tbl
	                                             ,x_iehv_tbl => lx_iehv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_iehv_tbl := lx_iehv_tbl;

END IF;
--Customer pre-processing user hook call end


--Vertical pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_exclusion_hist', 'B', 'V')) THEN
	iex_exclusion_hist_vuhk.update_exclusion_hist_pre (
	                                              p_init_msg_list => l_init_msg_list
	                                             ,x_msg_data => l_msg_data
	                                             ,x_msg_count => l_msg_count
	                                             ,x_return_status => l_return_status
	                                             ,p_iehv_tbl => lp_iehv_tbl
	                                             ,x_iehv_tbl => lx_iehv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_iehv_tbl := lx_iehv_tbl;

END IF;
--Vertical pre-processing user hook call end
*/
    iex_ieh_pvt.update_row(
                              l_api_version
                             ,l_init_msg_list
                             ,l_return_status
                             ,l_msg_count
                             ,l_msg_data
                             ,lp_iehv_tbl
                             ,lx_iehv_tbl);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_iehv_tbl := lx_iehv_tbl;

/*
--Vertical post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_exclusion_hist', 'A', 'V')) THEN
	iex_exclusion_hist_vuhk.update_exclusion_hist_post (
	                                              p_init_msg_list => l_init_msg_list
	                                             ,x_msg_data => l_msg_data
	                                             ,x_msg_count => l_msg_count
	                                             ,x_return_status => l_return_status
	                                             ,p_iehv_tbl => lp_iehv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Vertical post-processing user hook call end

--Customer post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_exclusion_hist', 'A', 'C')) THEN
	iex_exclusion_hist_cuhk.update_exclusion_hist_post (
	                                              p_init_msg_list => l_init_msg_list
	                                             ,x_msg_data => l_msg_data
	                                             ,x_msg_count => l_msg_count
	                                             ,x_return_status => l_return_status
	                                             ,p_iehv_tbl => lp_iehv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Customer post-processing user hook call end
*/
--Assign value to OUT variables
x_iehv_tbl  := lx_iehv_tbl;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO exclusion_hist_update;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO exclusion_hist_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO exclusion_hist_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_EXCLUSION_HIST_PUB','update_exclusion_hist');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END update_exclusion_hist;

--Put custom code for cascade delete by developer
PROCEDURE delete_exclusion_hist(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_iehv_rec              IN iehv_rec_type) IS

i	                    NUMBER :=0;
l_return_status 	    VARCHAR2(1);
l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_iehv_rec  iehv_rec_type;
lx_iehv_rec  iehv_rec_type;

BEGIN

SAVEPOINT exclusion_hist_delete_rec;


l_return_status 	     := OKC_API.G_RET_STS_SUCCESS;
l_api_version := p_api_version ;
l_init_msg_list := FND_API.G_FALSE ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_iehv_rec :=  p_iehv_rec;
lx_iehv_rec :=  p_iehv_rec;

/*
--Customer pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_exclusion_hist', 'B', 'C')) THEN
	iex_exclusion_hist_cuhk.delete_exclusion_hist_pre (
	                                              p_init_msg_list => l_init_msg_list
	                                             ,x_msg_data => l_msg_data
	                                             ,x_msg_count => l_msg_count
	                                             ,x_return_status => l_return_status
	                                             ,p_iehv_rec => lp_iehv_rec
	                                             ,x_iehv_rec => lx_iehv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_iehv_rec := lx_iehv_rec;

END IF;
--Customer pre-processing user hook call end


--Vertical pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_exclusion_hist', 'B', 'V')) THEN
	iex_exclusion_hist_vuhk.delete_exclusion_hist_pre (
	                                              p_init_msg_list => l_init_msg_list
	                                             ,x_msg_data => l_msg_data
	                                             ,x_msg_count => l_msg_count
	                                             ,x_return_status => l_return_status
	                                             ,p_iehv_rec => lp_iehv_rec
	                                             ,x_iehv_rec => lx_iehv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_iehv_rec := lx_iehv_rec;

END IF;
--Vertical pre-processing user hook call end
*/
--Delete the Master
iex_ieh_pvt.delete_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_iehv_rec);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

/*
--Vertical post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_exclusion_hist', 'A', 'V')) THEN
iex_exclusion_hist_vuhk.delete_exclusion_hist_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_iehv_rec => lp_iehv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Vertical post-processing user hook call end


--Customer post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_exclusion_hist', 'A', 'C')) THEN
iex_exclusion_hist_cuhk.delete_exclusion_hist_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_iehv_rec => lp_iehv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Customer post-processing user hook call end
*/
--Assign value to OUT variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO exclusion_hist_delete_rec;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO exclusion_hist_delete_rec;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO exclusion_hist_delete_rec;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_EXCLUSION_HIST_PUB','delete_exclusion_hist');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END delete_exclusion_hist;

PROCEDURE delete_exclusion_hist(
     p_api_version        IN NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status      OUT NOCOPY VARCHAR2
    ,x_msg_count          OUT NOCOPY NUMBER
    ,x_msg_data           OUT NOCOPY VARCHAR2
    ,p_iehv_tbl           IN iehv_tbl_type) IS

i NUMBER := 0;
l_return_status VARCHAR2(1) ;
l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_iehv_tbl  iehv_tbl_type;
lx_iehv_tbl  iehv_tbl_type;

BEGIN

SAVEPOINT exclusion_hist_delete_tbl;


l_return_status  := OKC_API.G_RET_STS_SUCCESS;
l_api_version := p_api_version ;
l_init_msg_list := FND_API.G_FALSE ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_iehv_tbl :=  p_iehv_tbl;
lx_iehv_tbl :=  p_iehv_tbl;

/*
--Customer pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_exclusion_hist', 'B', 'C')) THEN
iex_exclusion_hist_cuhk.delete_exclusion_hist_pre (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_iehv_tbl => lp_iehv_tbl
                                             ,x_iehv_tbl => lx_iehv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_iehv_tbl := lx_iehv_tbl;

END IF;
--Customer pre-processing user hook call end


--Vertical pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_exclusion_hist', 'B', 'V')) THEN
iex_exclusion_hist_vuhk.delete_exclusion_hist_pre (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_iehv_tbl => lp_iehv_tbl
                                             ,x_iehv_tbl => lx_iehv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_iehv_tbl := lx_iehv_tbl;

END IF;
--Vertical pre-processing user hook call end
*/
BEGIN
      --Initialize the return status
      l_return_status := OKC_API.G_RET_STS_SUCCESS;

      IF (lp_iehv_tbl.COUNT > 0) THEN
       	  i := p_iehv_tbl.FIRST;
       LOOP
          delete_exclusion_hist(
                               l_api_version
                              ,l_init_msg_list
                              ,l_return_status
                              ,l_msg_count
                              ,l_msg_data
                              ,lp_iehv_tbl(i));
          EXIT WHEN (i = lp_iehv_tbl.LAST);
          i := p_iehv_tbl.NEXT(i);
       END LOOP;
      END IF;
IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

END;

/*
--Vertical post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_exclusion_hist', 'A', 'V')) THEN
iex_exclusion_hist_vuhk.delete_exclusion_hist_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_iehv_tbl => lp_iehv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Vertical post-processing user hook call end


--Customer post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_exclusion_hist', 'A', 'C')) THEN
iex_exclusion_hist_cuhk.delete_exclusion_hist_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_iehv_tbl => lp_iehv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Customer post-processing user hook call end
*/
--Assign value to OUT variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO exclusion_hist_delete_tbl;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO exclusion_hist_delete_tbl;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO exclusion_hist_delete_tbl;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_EXCLUSION_HIST_PUB','delete_exclusion_hist');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END delete_exclusion_hist;

PROCEDURE validate_exclusion_hist(
     p_api_version      IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status    OUT  NOCOPY VARCHAR2
    ,x_msg_count        OUT  NOCOPY NUMBER
    ,x_msg_data         OUT  NOCOPY VARCHAR2
    ,p_iehv_rec         IN  iehv_rec_type) IS

l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_iehv_rec  iehv_rec_type;
lx_iehv_rec  iehv_rec_type;
l_return_status VARCHAR2(1);

BEGIN

SAVEPOINT exclusion_hist_validate;


l_api_version := p_api_version ;
l_init_msg_list := FND_API.G_FALSE ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_iehv_rec :=  p_iehv_rec;
lx_iehv_rec :=  p_iehv_rec;

/*
--Customer pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_exclusion_hist', 'B', 'C')) THEN
iex_exclusion_hist_cuhk.validate_exclusion_hist_pre (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_iehv_rec => lp_iehv_rec
                                             ,x_iehv_rec => lx_iehv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_iehv_rec := lx_iehv_rec;

END IF;
--Customer pre-processing user hook call end


--Vertical pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_exclusion_hist', 'B', 'V')) THEN
iex_exclusion_hist_vuhk.validate_exclusion_hist_pre (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_iehv_rec => lp_iehv_rec
                                             ,x_iehv_rec => lx_iehv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_iehv_rec := lx_iehv_rec;

END IF;
--Vertical pre-processing user hook call end
*/
iex_ieh_pvt.validate_row(
                            l_api_version
                           ,l_init_msg_list
                           ,l_return_status
                           ,l_msg_count
                           ,l_msg_data
                           ,lp_iehv_rec);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_iehv_rec := lx_iehv_rec;

/*
--Vertical post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_exclusion_hist', 'A', 'V')) THEN
iex_exclusion_hist_vuhk.validate_exclusion_hist_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_iehv_rec => lp_iehv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;



--Vertical post-processing user hook call end


--Customer post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_exclusion_hist', 'A', 'C')) THEN
iex_exclusion_hist_cuhk.validate_exclusion_hist_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_iehv_rec => lp_iehv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Customer post-processing user hook call end
*/
--Assign value to OUT variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO exclusion_hist_validate;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO exclusion_hist_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO exclusion_hist_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_EXCLUSION_HIST_PUB','validate_exclusion_hist');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END validate_exclusion_hist;

PROCEDURE validate_exclusion_hist(
     p_api_version       IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status     OUT  NOCOPY VARCHAR2,
    x_msg_count         OUT  NOCOPY NUMBER,
    x_msg_data          OUT  NOCOPY VARCHAR2,
    p_iehv_tbl          IN  iehv_tbl_type) IS
l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_iehv_tbl  iehv_tbl_type;
lx_iehv_tbl  iehv_tbl_type;
l_return_status VARCHAR2(1);

BEGIN

SAVEPOINT exclusion_hist_validate;


l_api_version := p_api_version ;
l_init_msg_list := FND_API.G_FALSE ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_iehv_tbl :=  p_iehv_tbl;
lx_iehv_tbl :=  p_iehv_tbl;
/*
--Customer pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_exclusion_hist', 'B', 'C')) THEN
iex_exclusion_hist_cuhk.validate_exclusion_hist_pre (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_iehv_tbl => lp_iehv_tbl
                                             ,x_iehv_tbl => lx_iehv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_iehv_tbl := lx_iehv_tbl;

END IF;
--Customer pre-processing user hook call end

--Vertical pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_exclusion_hist', 'B', 'V')) THEN
iex_exclusion_hist_vuhk.validate_exclusion_hist_pre (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_iehv_tbl => lp_iehv_tbl
                                             ,x_iehv_tbl => lx_iehv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_iehv_tbl := lx_iehv_tbl;

END IF;
--Vertical pre-processing user hook call end
*/

iex_ieh_pvt.validate_row(
                            p_api_version
                           ,p_init_msg_list
                           ,x_return_status
                           ,x_msg_count
                           ,x_msg_data
                           ,lp_iehv_tbl);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_iehv_tbl := lx_iehv_tbl;
/*
--Vertical post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_exclusion_hist', 'A', 'V')) THEN
iex_exclusion_hist_vuhk.validate_exclusion_hist_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_iehv_tbl => lp_iehv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Vertical post-processing user hook call end
--Customer post-processing user hook call start

IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_exclusion_hist', 'A', 'C')) THEN
iex_exclusion_hist_cuhk.validate_exclusion_hist_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_iehv_tbl => lp_iehv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;

*/

--Customer post-processing user hook call end

--Assign value to OUT variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO exclusion_hist_validate;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO exclusion_hist_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO exclusion_hist_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_EXCLUSION_HIST_PUB','validate_exclusion_hist');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END validate_exclusion_hist;

END IEX_EXCLUSION_HIST_PUB;

/
