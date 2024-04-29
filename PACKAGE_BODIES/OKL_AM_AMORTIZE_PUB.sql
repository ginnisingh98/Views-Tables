--------------------------------------------------------
--  DDL for Package Body OKL_AM_AMORTIZE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_AMORTIZE_PUB" AS
/* $Header: OKLPTATB.pls 120.4 2005/10/30 03:36:17 appldev noship $ */

PROCEDURE create_offlease_asset_trx(    p_api_version           IN   NUMBER,
                             p_init_msg_list         IN   VARCHAR2 DEFAULT OKC_API.G_FALSE,
                             x_return_status         OUT  NOCOPY VARCHAR2,
                             x_msg_count             OUT  NOCOPY NUMBER,
                             x_msg_data              OUT  NOCOPY VARCHAR2,
                             p_kle_id                IN   NUMBER DEFAULT OKL_API.G_MISS_NUM,
                             p_early_termination_yn  IN   VARCHAR2,
                             p_quote_eff_date        IN   DATE DEFAULT NULL,  -- rmunjulu EDAT Added parameter
                             p_quote_accpt_date      IN   DATE DEFAULT NULL)  -- rmunjulu EDAT Added parameter
                             IS

    l_api_version           NUMBER ;
    l_init_msg_list         VARCHAR2(1) ;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER ;
    l_msg_data              VARCHAR2(2000);
    lp_early_termination_yn VARCHAR2(1);
    lp_kle_id               NUMBER;

    -- rmunjulu EDAT
    l_quote_eff_date DATE;
    l_quote_accpt_date DATE;

BEGIN
SAVEPOINT trx_create_offlease_asset_trx;

l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_kle_id := p_kle_id;
lp_early_termination_yn := p_early_termination_yn;

-- rmunjulu EDAT Initialize
l_quote_eff_date := p_quote_eff_date;
l_quote_accpt_date := p_quote_accpt_date;



-- call the insert of pvt

	OKL_AM_AMORTIZE_PVT.create_offlease_asset_trx(    p_api_version => l_api_version
	                                              ,p_init_msg_list => l_init_msg_list
	                                              ,x_msg_data => l_msg_data
	                                              ,x_msg_count => l_msg_count
	                                              ,x_return_status => l_return_status
	                                              ,p_kle_id => lp_kle_id
                                                  ,p_early_termination_yn   => lp_early_termination_yn
                                                  ,p_quote_eff_date    =>  l_quote_eff_date      -- rmunjulu EDAT Pass additional parameters
                                                  ,p_quote_accpt_date  =>  l_quote_accpt_date) ; -- rmunjulu EDAT Pass additional parameters

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;





--Assign value to OUT variables

x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_create_offlease_asset_trx;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_create_offlease_asset_trx;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_create_offlease_asset_trx;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_AMORTIZE_PUB','create_offlease_asset_trx');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END create_offlease_asset_trx;


PROCEDURE create_offlease_asset_trx(    p_api_version           IN   NUMBER,
                             p_init_msg_list         IN   VARCHAR2 DEFAULT OKC_API.G_FALSE,
                             x_return_status         OUT  NOCOPY VARCHAR2,
                             x_msg_count             OUT  NOCOPY NUMBER,
                             x_msg_data              OUT  NOCOPY VARCHAR2,
                             p_contract_id           IN   NUMBER DEFAULT OKL_API.G_MISS_NUM,
                             p_early_termination_yn  IN   VARCHAR2,
                             p_quote_eff_date        IN   DATE DEFAULT NULL,  -- rmunjulu EDAT Added parameter
                             p_quote_accpt_date      IN   DATE DEFAULT NULL)  -- rmunjulu EDAT Added parameter
                             IS

    l_api_version           NUMBER ;
    l_init_msg_list         VARCHAR2(1) ;
    l_return_status         VARCHAR2(1);
    l_msg_count             NUMBER ;
    l_msg_data              VARCHAR2(2000);
    lp_early_termination_yn VARCHAR2(1);
    lp_contract_id          NUMBER;

    -- rmunjulu EDAT
    l_quote_eff_date DATE;
    l_quote_accpt_date DATE;

BEGIN
SAVEPOINT trx_create_offlease_asset_trx;

l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_contract_id := p_contract_id;
lp_early_termination_yn := p_early_termination_yn;

-- rmunjulu EDAT Initialize
l_quote_eff_date := p_quote_eff_date;
l_quote_accpt_date := p_quote_accpt_date;


-- call the insert of pvt

	OKL_AM_AMORTIZE_PVT.create_offlease_asset_trx(    p_api_version => l_api_version
	                                              ,p_init_msg_list => l_init_msg_list
	                                              ,x_msg_data => l_msg_data
	                                              ,x_msg_count => l_msg_count
	                                              ,x_return_status => l_return_status
	                                              ,p_contract_id => lp_contract_id
                                                  ,p_early_termination_yn   => lp_early_termination_yn
                                                  ,p_quote_eff_date    =>  l_quote_eff_date      -- rmunjulu EDAT Pass additional parameters
                                                  ,p_quote_accpt_date  =>  l_quote_accpt_date) ; -- rmunjulu EDAT Pass additional parameters


IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;





--Assign value to OUT variables

x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_create_offlease_asset_trx;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_create_offlease_asset_trx;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_create_offlease_asset_trx;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_AMORTIZE_PUB','create_offlease_asset_trx');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END create_offlease_asset_trx;

PROCEDURE update_offlease_asset_trx( p_api_version           IN   NUMBER,
                             p_init_msg_list         IN   VARCHAR2 DEFAULT OKC_API.G_FALSE,
                             x_return_status         OUT  NOCOPY VARCHAR2,
                             x_msg_count             OUT  NOCOPY NUMBER,
                             x_msg_data              OUT  NOCOPY VARCHAR2,
                             p_header_rec            IN   thpv_rec_type,
                             p_lines_rec             IN   tlpv_rec_type) AS

    l_api_version             NUMBER ;
    l_init_msg_list           VARCHAR2(1) ;
    l_return_status           VARCHAR2(1);
    l_msg_count               NUMBER ;
    l_msg_data                VARCHAR2(2000);
    lp_header_rec             thpv_rec_type;
    lp_lines_rec              tlpv_rec_type;

BEGIN
SAVEPOINT trx_update_offlease_asset_trx;

l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_header_rec := p_header_rec;
lp_lines_rec  := p_lines_rec;




-- call the insert of pvt

	OKL_AM_AMORTIZE_PVT.update_offlease_asset_trx(    p_api_version => l_api_version
	                                              ,p_init_msg_list => l_init_msg_list
	                                              ,x_msg_data => l_msg_data
	                                              ,x_msg_count => l_msg_count
	                                              ,x_return_status => l_return_status
	                                               ,p_header_rec => lp_header_rec,
                                                   p_lines_rec => lp_lines_rec) ;

IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;





--Assign value to OUT variables

x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_update_offlease_asset_trx;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_update_offlease_asset_trx;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_update_offlease_asset_trx;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_AMORTIZE_PUB','update_offlease_asset_trx');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END update_offlease_asset_trx;



PROCEDURE update_offlease_asset_trx( p_api_version           IN   NUMBER,
                             p_init_msg_list         IN   VARCHAR2 DEFAULT OKC_API.G_FALSE,
                             x_return_status         OUT  NOCOPY VARCHAR2,
                             x_msg_count             OUT  NOCOPY NUMBER,
                             x_msg_data              OUT  NOCOPY VARCHAR2,
                             p_header_tbl            IN   thpv_tbl_type,
                             p_lines_tbl             IN   tlpv_tbl_type,
                             x_record_status         OUT  NOCOPY VARCHAR2) AS

    l_api_version NUMBER ;
    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_record_status varchar2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);
    lp_lines_tbl                tlpv_tbl_type;
    lp_header_tbl               thpv_tbl_type ;
    lx_record_status            VARCHAR2(1);

BEGIN
SAVEPOINT trx_update_offlease_asset_trx;

l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_record_status := x_record_status;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_header_tbl  := p_header_tbl;
lp_lines_tbl   := p_lines_tbl;
lx_record_status   := x_record_status;



-- call the insert of pvt

	OKL_AM_AMORTIZE_PVT.update_offlease_asset_trx( p_api_version        => l_api_version
	                                              ,p_init_msg_list      => l_init_msg_list
	                                              ,x_msg_data           => l_msg_data
	                                              ,x_msg_count          => l_msg_count
	                                              ,x_return_status      => l_return_status
	                                              ,p_header_tbl        => lp_header_tbl,
                                                   p_lines_tbl         => lp_lines_tbl,
                                                   x_record_status      => lx_record_status) ;

IF (l_return_status =  FND_API.G_RET_STS_SUCCESS ) THEN
   IF   (l_record_status <> FND_API.G_RET_STS_SUCCESS) THEN
      -- assign the overall status to l_return_status
      l_return_status :=   l_record_status;
   END IF;
ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
	RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;





--Assign value to OUT variables

x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
x_record_status  := lx_record_status;
EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_update_offlease_asset_trx;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_update_offlease_asset_trx;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_update_offlease_asset_trx;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_AMORTIZE_PUB','update_offlease_asset_trx');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END update_offlease_asset_trx;


  -- Start of comments
  --
  -- Procedure Name  : update_depreciation
  -- Description     : Published API for update of Depreciation method and Salvage value
  -- Business Rules  : This API will do validations which are done from screen and then call the
  --                   screen level api for additional validations and updates
  -- Parameters      :
  -- Version         : 1.0
  -- History         : RMUNJULU 3608615 Added
  -- End of comments
  PROCEDURE update_depreciation(
                             p_api_version           IN   NUMBER,
                             p_init_msg_list         IN   VARCHAR2 DEFAULT OKC_API.G_FALSE,
                             x_return_status         OUT  NOCOPY VARCHAR2,
                             x_msg_count             OUT  NOCOPY NUMBER,
                             x_msg_data              OUT  NOCOPY VARCHAR2,
                             p_deprn_rec             IN   deprn_rec_type) IS

    l_api_version NUMBER ;
    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_record_status varchar2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);
    lp_deprn_rec  deprn_rec_type;


  BEGIN

     SAVEPOINT trx_update_deprn;

     l_api_version := p_api_version ;
     l_init_msg_list := p_init_msg_list ;
     l_return_status := x_return_status ;
     l_msg_count := x_msg_count ;
     l_msg_data := x_msg_data ;
     lp_deprn_rec  := p_deprn_rec;

     -- Call PVT proc
     OKL_AM_AMORTIZE_PVT.update_depreciation(
             p_api_version       => l_api_version,
             p_init_msg_list     => l_init_msg_list,
             x_return_status     => l_return_status,
             x_msg_count         => l_msg_count,
             x_msg_data          => l_msg_data,
             p_deprn_rec         => lp_deprn_rec);

     IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
    	RAISE FND_API.G_EXC_ERROR;
     ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     x_return_status := l_return_status ;
     x_msg_count := l_msg_count ;
     x_msg_data := l_msg_data ;

  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_update_deprn;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_update_deprn;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_update_deprn;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_AMORTIZE_PUB','update_depreciation');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

  END  update_depreciation;


END OKL_AM_AMORTIZE_PUB;

/
