--------------------------------------------------------
--  DDL for Package Body IEX_REPOS_OBJECTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_REPOS_OBJECTS_PUB" AS
/* $Header: iexprepb.pls 120.0 2004/01/24 03:19:38 appldev noship $ */

PROCEDURE insert_repos_objects(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_repv_rec              IN  repv_rec_type
    ,x_repv_rec              OUT  NOCOPY repv_rec_type) AS


l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
lp_repv_rec  repv_rec_type;
lx_repv_rec  repv_rec_type;

BEGIN

SAVEPOINT repos_objects_insert;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_repv_rec :=  p_repv_rec;
lx_repv_rec :=  x_repv_rec;


--Customer pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_repos_objects', 'B', 'C')) THEN
	iex_repos_objects_cuhk.insert_repos_objects_pre (
	                                            p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_repv_rec => lp_repv_rec
	                                           ,x_repv_rec => lx_repv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT record type variable in the IN record type
	lp_repv_rec := lx_repv_rec;

END IF;
--Customer pre-processing user hook call end



--Vertical pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_repos_objects', 'B', 'V')) THEN
	iex_repos_objects_vuhk.insert_repos_objects_pre (
	                                              p_init_msg_list => l_init_msg_list
	                                             ,x_msg_data => l_msg_data
	                                             ,x_msg_count => l_msg_count
	                                             ,x_return_status => l_return_status
	                                             ,p_repv_rec => lp_repv_rec
	                                             ,x_repv_rec => lx_repv_rec );
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_repv_rec := lx_repv_rec;

END IF;
--Vertical pre-processing user hook call end

iex_rep_pvt.insert_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_repv_rec
                         ,lx_repv_rec);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_repv_rec := lx_repv_rec;

--Vertical post processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_repos_objects', 'A', 'V')) THEN
	iex_repos_objects_vuhk.insert_repos_objects_post(
	                                               p_init_msg_list => l_init_msg_list
	                                              ,x_msg_data => l_msg_data
	                                              ,x_msg_count => l_msg_count
	                                              ,x_return_status => l_return_status
	                                              ,p_repv_rec => lp_repv_rec);
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Vertical post processing user hook call end


--Customer post processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_repos_objects', 'A', 'C')) THEN
	iex_repos_objects_cuhk.insert_repos_objects_post(
	                                               p_init_msg_list => l_init_msg_list
	                                              ,x_msg_data => l_msg_data
	                                              ,x_msg_count => l_msg_count
	                                              ,x_return_status => l_return_status
	                                              ,p_repv_rec => lp_repv_rec);
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Customer post processing user hook call end


--Assign value to OUT variables
x_repv_rec  := lx_repv_rec;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO repos_objects_insert;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO repos_objects_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO repos_objects_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_REPOS_OBJECTS_PUB','insert_repos_objects');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END insert_repos_objects;

PROCEDURE insert_repos_objects(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_repv_tbl              IN  repv_tbl_type
    ,x_repv_tbl              OUT  NOCOPY repv_tbl_type) AS

l_api_version NUMBER;
l_init_msg_list VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
l_return_status VARCHAR2(1);
lp_repv_tbl  repv_tbl_type;
lx_repv_tbl  repv_tbl_type;

BEGIN

SAVEPOINT repos_objects_insert;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_repv_tbl :=  p_repv_tbl;
lx_repv_tbl :=  x_repv_tbl;

--Customer pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_repos_objects', 'B', 'C')) THEN
	iex_repos_objects_cuhk.insert_repos_objects_pre(
	                                            p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_repv_tbl => lp_repv_tbl
	                                           ,x_repv_tbl => lx_repv_tbl);
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_repv_tbl := lx_repv_tbl;

END IF;
--Customer pre-processing user hook call end

--Vertical pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_repos_objects', 'B', 'V')) THEN
	iex_repos_objects_vuhk.insert_repos_objects_pre(
	                                            p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_repv_tbl => lp_repv_tbl
	                                           ,x_repv_tbl => lx_repv_tbl);
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_repv_tbl := lx_repv_tbl;

END IF;
--Vertical pre-processing user hook call end

iex_rep_pvt.insert_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_repv_tbl
                         ,lx_repv_tbl);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_repv_tbl := lx_repv_tbl;

--Vertical post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_repos_objects', 'A', 'V')) THEN
	iex_repos_objects_vuhk.insert_repos_objects_post (
	                                            p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_repv_tbl => lp_repv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Vertical post-processing user hook call end

--Customer post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'insert_repos_objects', 'A', 'C')) THEN
	iex_repos_objects_cuhk.insert_repos_objects_post (
	                                            p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_repv_tbl  => lp_repv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Customer post-processing user hook call end

--Assign value to OUT variables
x_repv_tbl  := lx_repv_tbl;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO repos_objects_insert;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO repos_objects_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO repos_objects_insert;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_REPOS_OBJECTS_PUB','insert_repos_objects');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END insert_repos_objects;

PROCEDURE lock_repos_objects(
     p_api_version           IN NUMBER
    ,p_init_msg_list         IN VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,p_repv_rec              IN repv_rec_type) AS

BEGIN
    iex_rep_pvt.lock_row(
		    p_api_version,
		    p_init_msg_list,
		    x_return_status,
		    x_msg_count,
		    x_msg_data,
		    p_repv_rec);

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
      FND_MSG_PUB.ADD_EXC_MSG('IEX_REPOS_OBJECTS_PUB','lock_repos_objects');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END lock_repos_objects;

PROCEDURE lock_repos_objects(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_repv_tbl              IN  repv_tbl_type) AS

BEGIN
    iex_rep_pvt.lock_row(
		    p_api_version,
		    p_init_msg_list,
		    x_return_status,
		    x_msg_count,
		    x_msg_data,
		    p_repv_tbl);

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
      FND_MSG_PUB.ADD_EXC_MSG('IEX_REPOS_OBJECTS_PUB','lock_repos_objects');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END lock_repos_objects;

PROCEDURE update_repos_objects(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_repv_rec              IN  repv_rec_type
    ,x_repv_rec              OUT  NOCOPY repv_rec_type) AS

l_api_version NUMBER ;
l_init_msg_list VARCHAR2(1) ;
l_return_status VARCHAR2(1);
l_msg_count NUMBER ;
l_msg_data VARCHAR2(2000);
lp_repv_rec  repv_rec_type;
lx_repv_rec  repv_rec_type;

BEGIN

SAVEPOINT repos_objects_update;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_repv_rec :=  p_repv_rec;
lx_repv_rec :=  x_repv_rec;


--Customer pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_repos_objects', 'B', 'C')) THEN
	iex_repos_objects_cuhk.update_repos_objects_pre (
	                                            p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_repv_rec => lp_repv_rec
	                                           ,x_repv_rec => lx_repv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_repv_rec := lx_repv_rec;

END IF;
--Customer pre-processing user hook call end


--Vertical pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_repos_objects', 'B', 'V')) THEN
	iex_repos_objects_vuhk.update_repos_objects_pre (
	                                           p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_repv_rec => lp_repv_rec
	                                           ,x_repv_rec => lx_repv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_repv_rec := lx_repv_rec;

END IF;
--Vertical pre-processing user hook call end

    iex_rep_pvt.update_row(
                              l_api_version
                             ,l_init_msg_list
                             ,l_return_status
                             ,l_msg_count
                             ,l_msg_data
                             ,lp_repv_rec
                             ,lx_repv_rec);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_repv_rec := lx_repv_rec;

--Vertical post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_repos_objects', 'A', 'V')) THEN
	iex_repos_objects_vuhk.update_repos_objects_post (
	                                           p_init_msg_list => l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_repv_rec => lp_repv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Vertical post-processing user hook call end


--Customer post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_repos_objects', 'A', 'C')) THEN
	iex_repos_objects_cuhk.update_repos_objects_post (
	                                           p_init_msg_list=>l_init_msg_list
	                                           ,x_msg_data => l_msg_data
	                                           ,x_msg_count => l_msg_count
	                                           ,x_return_status => l_return_status
	                                           ,p_repv_rec => lp_repv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Customer post-processing user hook call end

--Assign value to OUT variables
x_repv_rec  := lx_repv_rec;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO repos_objects_update;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO repos_objects_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO repos_objects_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_REPOS_OBJECTS_PUB','update_repos_objects');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END update_repos_objects;

PROCEDURE update_repos_objects(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_repv_tbl              IN  repv_tbl_type
    ,x_repv_tbl              OUT  NOCOPY repv_tbl_type) AS

l_api_version NUMBER;
l_init_msg_list VARCHAR2(200);
l_msg_data VARCHAR2(100);
l_msg_count NUMBER ;
l_return_status VARCHAR2(1);
lp_repv_tbl  repv_tbl_type;
lx_repv_tbl  repv_tbl_type;

BEGIN

SAVEPOINT repos_objects_update;


lp_repv_tbl :=  p_repv_tbl;
lx_repv_tbl :=  x_repv_tbl;
l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data := x_msg_data ;
l_msg_count := x_msg_count ;


--Customer pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_repos_objects', 'B', 'C')) THEN
	iex_repos_objects_cuhk.update_repos_objects_pre (
	                                              p_init_msg_list => l_init_msg_list
	                                             ,x_msg_data => l_msg_data
	                                             ,x_msg_count => l_msg_count
	                                             ,x_return_status => l_return_status
	                                             ,p_repv_tbl => lp_repv_tbl
	                                             ,x_repv_tbl => lx_repv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_repv_tbl := lx_repv_tbl;

END IF;
--Customer pre-processing user hook call end


--Vertical pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_repos_objects', 'B', 'V')) THEN
	iex_repos_objects_vuhk.update_repos_objects_pre (
	                                              p_init_msg_list => l_init_msg_list
	                                             ,x_msg_data => l_msg_data
	                                             ,x_msg_count => l_msg_count
	                                             ,x_return_status => l_return_status
	                                             ,p_repv_tbl => lp_repv_tbl
	                                             ,x_repv_tbl => lx_repv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_repv_tbl := lx_repv_tbl;

END IF;
--Vertical pre-processing user hook call end

    iex_rep_pvt.update_row(
                              l_api_version
                             ,l_init_msg_list
                             ,l_return_status
                             ,l_msg_count
                             ,l_msg_data
                             ,lp_repv_tbl
                             ,lx_repv_tbl);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_repv_tbl := lx_repv_tbl;

--Vertical post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_repos_objects', 'A', 'V')) THEN
	iex_repos_objects_vuhk.update_repos_objects_post (
	                                              p_init_msg_list => l_init_msg_list
	                                             ,x_msg_data => l_msg_data
	                                             ,x_msg_count => l_msg_count
	                                             ,x_return_status => l_return_status
	                                             ,p_repv_tbl => lp_repv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Vertical post-processing user hook call end

--Customer post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'update_repos_objects', 'A', 'C')) THEN
	iex_repos_objects_cuhk.update_repos_objects_post (
	                                              p_init_msg_list => l_init_msg_list
	                                             ,x_msg_data => l_msg_data
	                                             ,x_msg_count => l_msg_count
	                                             ,x_return_status => l_return_status
	                                             ,p_repv_tbl => lp_repv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Customer post-processing user hook call end

--Assign value to OUT variables
x_repv_tbl  := lx_repv_tbl;
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;


EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO repos_objects_update;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO repos_objects_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO repos_objects_update;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_REPOS_OBJECTS_PUB','update_repos_objects');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END update_repos_objects;

--Put custom code for cascade delete by developer
PROCEDURE delete_repos_objects(
     p_api_version           IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_return_status         OUT  NOCOPY VARCHAR2
    ,x_msg_count             OUT  NOCOPY NUMBER
    ,x_msg_data              OUT  NOCOPY VARCHAR2
    ,p_repv_rec              IN repv_rec_type) AS

i	                    NUMBER :=0;
l_return_status 	    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_repv_rec  repv_rec_type;
lx_repv_rec  repv_rec_type;

BEGIN

SAVEPOINT repos_objects_delete_rec;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_repv_rec :=  p_repv_rec;
lx_repv_rec :=  p_repv_rec;

--Customer pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_repos_objects', 'B', 'C')) THEN
	iex_repos_objects_cuhk.delete_repos_objects_pre (
	                                              p_init_msg_list => l_init_msg_list
	                                             ,x_msg_data => l_msg_data
	                                             ,x_msg_count => l_msg_count
	                                             ,x_return_status => l_return_status
	                                             ,p_repv_rec => lp_repv_rec
	                                             ,x_repv_rec => lx_repv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_repv_rec := lx_repv_rec;

END IF;
--Customer pre-processing user hook call end


--Vertical pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_repos_objects', 'B', 'V')) THEN
	iex_repos_objects_vuhk.delete_repos_objects_pre (
	                                              p_init_msg_list => l_init_msg_list
	                                             ,x_msg_data => l_msg_data
	                                             ,x_msg_count => l_msg_count
	                                             ,x_return_status => l_return_status
	                                             ,p_repv_rec => lp_repv_rec
	                                             ,x_repv_rec => lx_repv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_repv_rec := lx_repv_rec;

END IF;
--Vertical pre-processing user hook call end

--Delete the Master
iex_rep_pvt.delete_row(
                          l_api_version
                         ,l_init_msg_list
                         ,l_return_status
                         ,l_msg_count
                         ,l_msg_data
                         ,lp_repv_rec);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;


--Vertical post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_repos_objects', 'A', 'V')) THEN
iex_repos_objects_vuhk.delete_repos_objects_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_repv_rec => lp_repv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Vertical post-processing user hook call end


--Customer post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_repos_objects', 'A', 'C')) THEN
iex_repos_objects_cuhk.delete_repos_objects_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_repv_rec => lp_repv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Customer post-processing user hook call end

--Assign value to OUT variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO repos_objects_delete_rec;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO repos_objects_delete_rec;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO repos_objects_delete_rec;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_REPOS_OBJECTS_PUB','delete_repos_objects');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END delete_repos_objects;

PROCEDURE delete_repos_objects(
     p_api_version        IN NUMBER
    ,p_init_msg_list      IN VARCHAR2
    ,x_return_status      OUT NOCOPY VARCHAR2
    ,x_msg_count          OUT NOCOPY NUMBER
    ,x_msg_data           OUT NOCOPY VARCHAR2
    ,p_repv_tbl           IN repv_tbl_type) AS

i NUMBER := 0;
l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
l_api_version NUMBER := p_api_version ;
l_init_msg_list VARCHAR2(1) := p_init_msg_list  ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_repv_tbl  repv_tbl_type;
lx_repv_tbl  repv_tbl_type;

BEGIN

SAVEPOINT repos_objects_delete_tbl;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_repv_tbl :=  p_repv_tbl;
lx_repv_tbl :=  p_repv_tbl;

--Customer pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_repos_objects', 'B', 'C')) THEN
iex_repos_objects_cuhk.delete_repos_objects_pre (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_repv_tbl => lp_repv_tbl
                                             ,x_repv_tbl => lx_repv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_repv_tbl := lx_repv_tbl;

END IF;
--Customer pre-processing user hook call end


--Vertical pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_repos_objects', 'B', 'V')) THEN
iex_repos_objects_vuhk.delete_repos_objects_pre (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_repv_tbl => lp_repv_tbl
                                             ,x_repv_tbl => lx_repv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_repv_tbl := lx_repv_tbl;

END IF;
--Vertical pre-processing user hook call end

BEGIN
      --Initialize the return status
      l_return_status := OKL_API.G_RET_STS_SUCCESS;

      IF (lp_repv_tbl.COUNT > 0) THEN
       	  i := p_repv_tbl.FIRST;
       LOOP
          delete_repos_objects(
                               l_api_version
                              ,l_init_msg_list
                              ,l_return_status
                              ,l_msg_count
                              ,l_msg_data
                              ,lp_repv_tbl(i));
          EXIT WHEN (i = lp_repv_tbl.LAST);
          i := p_repv_tbl.NEXT(i);
       END LOOP;
      END IF;
IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

END;


--Vertical post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_repos_objects', 'A', 'V')) THEN
iex_repos_objects_vuhk.delete_repos_objects_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_repv_tbl => lp_repv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Vertical post-processing user hook call end


--Customer post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'delete_repos_objects', 'A', 'C')) THEN
iex_repos_objects_cuhk.delete_repos_objects_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_repv_tbl => lp_repv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Customer post-processing user hook call end

--Assign value to OUT variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO repos_objects_delete_tbl;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO repos_objects_delete_tbl;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO repos_objects_delete_tbl;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_REPOS_OBJECTS_PUB','delete_repos_objects');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END delete_repos_objects;

PROCEDURE validate_repos_objects(
     p_api_version      IN  NUMBER
    ,p_init_msg_list    IN  VARCHAR2
    ,x_return_status    OUT  NOCOPY VARCHAR2
    ,x_msg_count        OUT  NOCOPY NUMBER
    ,x_msg_data         OUT  NOCOPY VARCHAR2
    ,p_repv_rec         IN  repv_rec_type) AS

l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_repv_rec  repv_rec_type;
lx_repv_rec  repv_rec_type;
l_return_status VARCHAR2(1);

BEGIN

SAVEPOINT repos_objects_validate;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_repv_rec :=  p_repv_rec;
lx_repv_rec :=  p_repv_rec;

--Customer pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_repos_objects', 'B', 'C')) THEN
iex_repos_objects_cuhk.validate_repos_objects_pre (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_repv_rec => lp_repv_rec
                                             ,x_repv_rec => lx_repv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_repv_rec := lx_repv_rec;

END IF;
--Customer pre-processing user hook call end


--Vertical pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_repos_objects', 'B', 'V')) THEN
iex_repos_objects_vuhk.validate_repos_objects_pre (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_repv_rec => lp_repv_rec
                                             ,x_repv_rec => lx_repv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_repv_rec := lx_repv_rec;

END IF;
--Vertical pre-processing user hook call end

iex_rep_pvt.validate_row(
                            l_api_version
                           ,l_init_msg_list
                           ,l_return_status
                           ,l_msg_count
                           ,l_msg_data
                           ,lp_repv_rec);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_repv_rec := lx_repv_rec;


--Vertical post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_repos_objects', 'A', 'V')) THEN
iex_repos_objects_vuhk.validate_repos_objects_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_repv_rec => lp_repv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;



--Vertical post-processing user hook call end


--Customer post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_repos_objects', 'A', 'C')) THEN
iex_repos_objects_cuhk.validate_repos_objects_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_repv_rec => lp_repv_rec) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Customer post-processing user hook call end

--Assign value to OUT variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO repos_objects_validate;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO repos_objects_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO repos_objects_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_REPOS_OBJECTS_PUB','validate_repos_objects');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END validate_repos_objects;

PROCEDURE validate_repos_objects(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2,
    x_return_status     OUT  NOCOPY VARCHAR2,
    x_msg_count         OUT  NOCOPY NUMBER,
    x_msg_data          OUT  NOCOPY VARCHAR2,
    p_repv_tbl          IN  repv_tbl_type) AS
l_api_version NUMBER ;
l_init_msg_list    VARCHAR2(1) ;
l_msg_data VARCHAR2(2000);
l_msg_count NUMBER ;
lp_repv_tbl  repv_tbl_type;
lx_repv_tbl  repv_tbl_type;
l_return_status VARCHAR2(1);

BEGIN

SAVEPOINT repos_objects_validate;


l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_msg_data :=  x_msg_data;
l_msg_count := x_msg_count ;
lp_repv_tbl :=  p_repv_tbl;
lx_repv_tbl :=  p_repv_tbl;

--Customer pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_repos_objects', 'B', 'C')) THEN
iex_repos_objects_cuhk.validate_repos_objects_pre (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_repv_tbl => lp_repv_tbl
                                             ,x_repv_tbl => lx_repv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_repv_tbl := lx_repv_tbl;

END IF;
--Customer pre-processing user hook call end

--Vertical pre-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_repos_objects', 'B', 'V')) THEN
iex_repos_objects_vuhk.validate_repos_objects_pre (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_repv_tbl => lp_repv_tbl
                                             ,x_repv_tbl => lx_repv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	--Copy value of OUT variable in the IN record type
	lp_repv_tbl := lx_repv_tbl;

END IF;
--Vertical pre-processing user hook call end

iex_rep_pvt.validate_row(
                            p_api_version
                           ,p_init_msg_list
                           ,x_return_status
                           ,x_msg_count
                           ,x_msg_data
                           ,lp_repv_tbl);

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

--Copy value of OUT variable in the IN record type
lp_repv_tbl := lx_repv_tbl;

--Vertical post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_repos_objects', 'A', 'V')) THEN
iex_repos_objects_vuhk.validate_repos_objects_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_repv_tbl => lp_repv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;
--Vertical post-processing user hook call end
--Customer post-processing user hook call start
IF (JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, 'validate_repos_objects', 'A', 'C')) THEN
iex_repos_objects_cuhk.validate_repos_objects_post (
                                              p_init_msg_list => l_init_msg_list
                                             ,x_msg_data => l_msg_data
                                             ,x_msg_count => l_msg_count
                                             ,x_return_status => l_return_status
                                             ,p_repv_tbl => lp_repv_tbl) ;
	IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
		RAISE FND_API.G_EXC_ERROR;
	ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;
END IF;



--Customer post-processing user hook call end

--Assign value to OUT variables
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

x_return_status := l_return_status ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO repos_objects_validate;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO repos_objects_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO repos_objects_validate;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('IEX_REPOS_OBJECTS_PUB','validate_repos_objects');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END validate_repos_objects;

END IEX_REPOS_OBJECTS_PUB;

/
