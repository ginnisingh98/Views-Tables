--------------------------------------------------------
--  DDL for Package Body OKL_POOL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_POOL_PUB" AS
/* $Header: OKLPSZPB.pls 120.0 2007/07/27 14:03:02 ankushar noship $ */

PROCEDURE create_pool(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_polv_rec                     IN polv_rec_type
   ,x_polv_rec                     OUT NOCOPY polv_rec_type
 ) IS

  l_api_name         CONSTANT VARCHAR2(30) := 'create_pool';
  l_api_version NUMBER ;
  l_init_msg_list VARCHAR2(1) ;
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER ;
  l_msg_data VARCHAR2(2000);

  l_polv_rec   polv_rec_type ;
  lx_polv_rec  polv_rec_type ;

BEGIN
  -- Set API savepoint
 SAVEPOINT trx_create_pool;

 x_return_status := OKL_API.G_RET_STS_SUCCESS;

 l_api_version := p_api_version ;
 l_init_msg_list := p_init_msg_list ;
 l_return_status := x_return_status ;
 l_msg_count := x_msg_count ;
 l_msg_data := x_msg_data ;
 l_polv_rec := p_polv_rec;

 Okl_Pool_Pvt.create_pool(
        p_api_version   => l_api_version,
        p_init_msg_list => l_init_msg_list,
        x_return_status => l_return_status,
        x_msg_count     => l_msg_count,
        x_msg_data      => l_msg_data,
        p_polv_rec      => l_polv_rec,
        x_polv_rec      => lx_polv_rec);

 IF ( l_return_status = OKL_API.G_RET_STS_ERROR )  THEN
	RAISE OKL_API.G_EXCEPTION_ERROR;
 ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
 END IF;

x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
x_polv_rec  := lx_polv_rec;


EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
      ROLLBACK TO trx_create_pool;
      x_return_status := OKL_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_create_pool;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_create_pool;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_POOL_PUB','create_pool');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);


END create_pool;

PROCEDURE update_pool(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_polv_rec                     IN polv_rec_type
   ,x_polv_rec                     OUT NOCOPY polv_rec_type
 ) IS

  l_api_version NUMBER ;
  l_init_msg_list VARCHAR2(1) ;
  l_return_status VARCHAR2(1);
  l_msg_count NUMBER ;
  l_msg_data VARCHAR2(2000);

  l_polv_rec   polv_rec_type ;
  lx_polv_rec  polv_rec_type ;
  l_api_name         CONSTANT VARCHAR2(30) := 'update_pool';

BEGIN
 -- Set API savepoint
 SAVEPOINT trx_update_pool;

 l_api_version := p_api_version ;
 l_init_msg_list := p_init_msg_list ;
 l_return_status := x_return_status ;
 l_msg_count := x_msg_count ;
 l_msg_data := x_msg_data ;

 l_polv_rec.id			             :=	   p_polv_rec.id;
 l_polv_rec.description        	     :=	   p_polv_rec.description ;
 l_polv_rec.short_description  	     :=	   p_polv_rec.short_description;
 l_polv_rec.display_in_lease_center   :=   p_polv_rec.display_in_lease_center ;


 OKL_POOL_PVT.validate_pool(
        p_api_version   => l_api_version,
        p_init_msg_list => l_init_msg_list,
        p_api_name      => l_api_name,
        p_polv_rec      => l_polv_rec,
        p_action        => 'update_pool',
        x_return_status => l_return_status,
        x_msg_count     => l_msg_count,
        x_msg_data      => l_msg_data
    );

IF ( l_return_status = OKL_API.G_RET_STS_ERROR )  THEN
	RAISE OKL_API.G_EXCEPTION_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
END IF;

Okl_Pool_Pvt.update_pool(
        p_api_version   => l_api_version,
        p_init_msg_list => l_init_msg_list,
        x_return_status => l_return_status,
        x_msg_count     => l_msg_count,
        x_msg_data      => l_msg_data,
        p_polv_rec      => l_polv_rec,
        x_polv_rec      => lx_polv_rec);

IF ( l_return_status = OKL_API.G_RET_STS_ERROR )  THEN
	RAISE OKL_API.G_EXCEPTION_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
END IF;

--Assign value to OUT variables
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
x_polv_rec  := lx_polv_rec;


EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
      ROLLBACK TO trx_update_pool;
      x_return_status := OKL_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_update_pool;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_update_pool;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_POOL_PUB','update_pool');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END update_pool;


PROCEDURE cleanup_pool_contents(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_pol_id                       IN  NUMBER
   ,p_currency_code                IN VARCHAR2
   ,p_cust_object1_id1             IN NUMBER DEFAULT NULL
   ,p_sic_code                     IN VARCHAR2 DEFAULT NULL
   ,p_khr_id                   IN NUMBER DEFAULT NULL
   ,p_pre_tax_yield_from           IN NUMBER DEFAULT NULL
   ,p_pre_tax_yield_to             IN NUMBER DEFAULT NULL
   ,p_book_classification          IN VARCHAR2 DEFAULT NULL
   ,p_tax_owner                    IN VARCHAR2 DEFAULT NULL
   ,p_pdt_id                       IN NUMBER DEFAULT NULL
   ,p_start_from_date              IN DATE DEFAULT NULL
   ,p_start_to_date                IN DATE DEFAULT NULL
   ,p_end_from_date                IN DATE DEFAULT NULL
   ,p_end_to_date                  IN DATE DEFAULT NULL
   ,p_stream_type_subclass IN VARCHAR2 DEFAULT NULL
   ,p_streams_from_date            IN DATE DEFAULT NULL
   ,p_streams_to_date              IN DATE DEFAULT NULL
   ,x_poc_uv_tbl                   OUT NOCOPY poc_uv_tbl_type) IS


  lx_poc_uv_tbl poc_uv_tbl_type;
  l_api_version      NUMBER      ;
  l_init_msg_list     VARCHAR2(1) ;
  l_return_status     VARCHAR2(1) ;
  l_msg_count         NUMBER;

  l_msg_data          VARCHAR2(2000);
  l_api_name         CONSTANT VARCHAR2(40) := 'cleanup_pool_contents';
  l_polv_rec   polv_rec_type ;
  lx_polv_rec  polv_rec_type ;

BEGIN
  -- Set API savepoint
 SAVEPOINT trx_cleanup_pool_contents;

 l_api_version := p_api_version ;
 l_init_msg_list := p_init_msg_list ;
 l_return_status := x_return_status ;
 l_msg_count := x_msg_count ;
 l_msg_data := x_msg_data ;

 l_polv_rec.id := p_pol_id;

 OKL_POOL_PVT.validate_pool(
        p_api_version   => l_api_version,
        p_init_msg_list => l_init_msg_list,
        p_api_name      => l_api_name,
        p_polv_rec      => l_polv_rec,
        p_action        => 'cleanup_pool_contents',
        x_return_status => l_return_status,
        x_msg_count     => l_msg_count,
        x_msg_data      => l_msg_data
        );

IF ( l_return_status = OKL_API.G_RET_STS_ERROR )  THEN
	RAISE OKL_API.G_EXCEPTION_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
END IF;


 Okl_Pool_Pvt.cleanup_pool_contents(  p_api_version         => l_api_version
                                     ,p_init_msg_list         => l_init_msg_list
                                     ,x_return_status         => l_return_status
                                     ,x_msg_count             => l_msg_count
                                     ,x_msg_data              => l_msg_data
                                     ,p_multi_org             => NULL
                                     ,p_currency_code         => NULL
                                     ,p_pol_id                => p_pol_id
                                     ,p_cust_object1_id1      => p_cust_object1_id1
                                     ,p_sic_code              => p_sic_code
                                     ,p_dnz_chr_id            => p_khr_id
                                     ,p_pre_tax_yield_from    => p_pre_tax_yield_from
                                     ,p_pre_tax_yield_to      => p_pre_tax_yield_to
                                     ,p_book_classification   => p_book_classification
                                     ,p_tax_owner             => p_tax_owner
                                     ,p_pdt_id                => p_pdt_id
                                     ,p_start_from_date       => p_start_from_date
                                     ,p_start_to_date         => p_start_to_date
                                     ,p_end_from_date         => p_end_from_date
                                     ,p_end_to_date           => p_end_to_date
                                     ,p_asset_id              => NULL
                                     ,p_item_id1              => NULL
                                     ,p_model_number          => NULL
                                     ,p_manufacturer_name     => NULL
                                     ,p_vendor_id1            => NULL
                                     ,p_oec_from              => NULL
                                     ,p_oec_to                => NULL
                                     ,p_residual_percentage   => NULL
                                     ,p_sty_id                => NULL
                                     ,p_stream_type_subclass  => p_stream_type_subclass
                                     ,p_streams_from_date     => p_streams_from_date
                                     ,p_streams_to_date       => p_streams_to_date
                                     ,p_action_code           => Okl_Pool_Pvt.G_ACTION_REMOVE
                                     ,x_poc_uv_tbl            => lx_poc_uv_tbl);

IF ( l_return_status = OKL_API.G_RET_STS_ERROR )  THEN
	RAISE OKL_API.G_EXCEPTION_ERROR;
ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
END IF;


--Assign value to OUT variables
x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
x_poc_uv_tbl  := lx_poc_uv_tbl;


EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
      ROLLBACK TO  trx_cleanup_pool_contents;
      x_return_status := OKL_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      ROLLBACK TO  trx_cleanup_pool_contents;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO  trx_cleanup_pool_contents;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_POOL_PUB','cleanup_pool_contents');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END cleanup_pool_contents;


PROCEDURE add_pool_contents(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,x_row_count                    OUT NOCOPY NUMBER
   ,p_pol_id                       IN NUMBER
   ,p_currency_code                IN VARCHAR2
   ,p_cust_object1_id1             IN NUMBER
   ,p_sic_code                     IN VARCHAR2
   ,p_khr_id                       IN NUMBER
   ,p_pre_tax_yield_from           IN NUMBER
   ,p_pre_tax_yield_to             IN NUMBER
   ,p_book_classification          IN VARCHAR2
   ,p_tax_owner                    IN VARCHAR2
   ,p_pdt_id                       IN NUMBER
   ,p_start_from_date              IN DATE
   ,p_start_to_date                IN DATE
   ,p_end_from_date                IN DATE
   ,p_end_to_date                  IN DATE
   ,p_stream_type_subclass         IN VARCHAR2
   ,p_stream_element_from_date     IN DATE
   ,p_stream_element_to_date       IN DATE
   ,p_log_message 	           IN VARCHAR2 DEFAULT 'Y'
   ) IS
   lx_poc_uv_tbl poc_uv_tbl_type;
  --l_api_name         VARCHAR2(40) ;
  l_api_name         CONSTANT VARCHAR2(40) := 'add_pool_contents';
  l_api_version      NUMBER      ;
  l_init_msg_list     VARCHAR2(1) ;
  l_return_status     VARCHAR2(1) ;
  l_msg_count         NUMBER;

  l_msg_data          VARCHAR2(2000);
  l_row_count NUMBER:=0;

 -- l_currency_code okl_pools.currency_code%TYPE;
  l_polv_rec   polv_rec_type ;
  lx_polv_rec  polv_rec_type ;

BEGIN
  -- Set API savepoint
 SAVEPOINT trx_add_pool_contents;

 l_api_version := p_api_version ;
 l_init_msg_list := p_init_msg_list ;
 l_return_status := x_return_status ;
 l_msg_count := x_msg_count ;
 l_msg_data := x_msg_data ;
 l_row_count:=x_row_count;

 l_polv_rec.id := p_pol_id;
 l_polv_rec.currency_code:=p_currency_code;
 OKL_POOL_PVT.validate_pool(
        p_api_version   => l_api_version,
        p_init_msg_list => l_init_msg_list,
        p_api_name      => l_api_name,
        p_polv_rec      => l_polv_rec,
        p_action        => 'add_pool_contents',
        x_return_status => l_return_status,
        x_msg_count     => l_msg_count,
        x_msg_data      => l_msg_data
        );

 IF ( l_return_status = OKL_API.G_RET_STS_ERROR )  THEN
	RAISE OKL_API.G_EXCEPTION_ERROR;
 ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
 END IF;

 OKL_POOL_PVT.add_pool_contents(
    p_api_version                 =>l_api_version
   ,p_init_msg_list                =>l_init_msg_list
   ,x_return_status                =>l_return_status
   ,x_msg_count                    =>l_msg_count
   ,x_msg_data                     =>l_msg_data
   ,x_row_count                    =>l_row_count
   ,p_currency_code                =>p_currency_code
   ,p_pol_id                       => p_pol_id
   ,p_multi_org                    => NULL
   ,p_cust_object1_id1             => p_cust_object1_id1
   ,p_sic_code                     => p_sic_code
   ,p_khr_id                       =>p_khr_id
   ,p_pre_tax_yield_from           =>p_pre_tax_yield_from
   ,p_pre_tax_yield_to             =>p_pre_tax_yield_to
   ,p_book_classification         =>p_book_classification
   ,p_tax_owner                    =>p_tax_owner
   ,p_pdt_id                       =>p_pdt_id
   ,p_start_date_from              =>p_start_from_date
   ,p_start_date_to                =>p_start_to_date
   ,p_end_date_from                =>p_end_from_date
   ,p_end_date_to                  =>p_end_to_date
   ,p_asset_id                     =>NULL
   ,p_item_id1                     =>NULL
   ,p_model_number                 =>NULL
   ,p_manufacturer_name            =>NULL
   ,p_vendor_id1                   =>NULL
   ,p_oec_from                     =>NULL
   ,p_oec_to                       =>NULL
   ,p_residual_percentage          =>NULL
   ,p_sty_id1                      =>NULL
   ,p_sty_id2                      =>NULL
   ,p_stream_type_subclass         =>p_stream_type_subclass
   ,p_stream_element_from_date     =>p_stream_element_from_date
   ,p_stream_element_to_date       =>p_stream_element_to_date
   ,p_stream_element_payment_freq  =>NULL
   ,p_log_message                  =>p_log_message
   );

 IF ( l_return_status = OKL_API.G_RET_STS_ERROR )  THEN
	RAISE OKL_API.G_EXCEPTION_ERROR;
 ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
 END IF;


 --Assign value to OUT variables
 x_return_status := l_return_status ;
 x_msg_count := l_msg_count ;
 x_msg_data := l_msg_data ;
 x_row_count:=l_row_count;


EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
      ROLLBACK TO  trx_add_pool_contents;
      x_return_status := OKL_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      ROLLBACK TO  trx_add_pool_contents;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO  trx_add_pool_contents;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_POOL_PUB','add_pool_contents');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);

END add_pool_contents;

END Okl_Pool_PUB;

/
