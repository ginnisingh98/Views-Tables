--------------------------------------------------------
--  DDL for Package Body OKL_AM_REMARKET_ASSET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_REMARKET_ASSET_PUB" AS
/* $Header: OKLPRMKB.pls 120.3 2005/10/30 03:34:17 appldev noship $ */

    -- create item for remarketing
PROCEDURE create_rmk_item
(    p_api_version           IN  	NUMBER,
     p_init_msg_list         IN  	VARCHAR2 DEFAULT OKL_API.G_FALSE,
     p_item_number           IN     VARCHAR2, -- 04-OCT-04 SECHAWLA  3924244 : added new parameter
     p_Item_Description      IN     VARCHAR2,
     p_Item_Price            IN     NUMBER DEFAULT OKL_API.G_MISS_NUM,
     p_quantity              IN     NUMBER DEFAULT 1,
     x_return_status         OUT 	NOCOPY VARCHAR2,
     x_msg_count             OUT 	NOCOPY NUMBER,
     x_msg_data              OUT 	NOCOPY VARCHAR2,
     x_new_item_number       OUT    NOCOPY VARCHAR2,
     x_new_item_id           OUT    NOCOPY NUMBER
) IS



    l_api_version NUMBER ;
    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count NUMBER ;
    l_msg_data VARCHAR2(2000);

    lp_item_description VARCHAR2(240);
    lp_item_price       NUMBER;
    lp_quantity         NUMBER;
    lx_new_item_number  VARCHAR2(2000);
    lx_new_item_id      NUMBER;

    -- 04-OCT-04 SECHAWLA 3924244 :
    lp_item_number      VARCHAR2(40);

BEGIN
SAVEPOINT trx_create_rmk_item;

l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;

lp_item_number := p_item_number; -- 04-OCT-04 SECHAWLA 3924244 : added new parameter

lp_item_description := p_item_description;
lp_item_price := p_item_price;
lp_quantity := p_quantity;

lx_new_item_number := x_new_item_number;
lx_new_item_id := x_new_item_id;

l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;





-- call the insert of pvt

	OKL_AM_REMARKET_ASSET_PVT.create_rmk_item(  p_api_version            => l_api_version,
                                                p_init_msg_list          => l_init_msg_list ,
                                                p_item_number            => lp_item_number,
                                                p_Item_Description       => lp_item_description,
                                                p_Item_Price             => lp_item_price,
                                                p_quantity               => lp_quantity,
                                                x_return_status          => l_return_status,
                                                x_msg_count              => l_msg_count,
                                                x_msg_data               => l_msg_data,
                                                x_new_item_number        => lx_new_item_number,
                                                x_new_item_id            => lx_new_item_id
                                                ) ;



IF ( l_return_status = FND_API.G_RET_STS_ERROR )  THEN
  	 RAISE FND_API.G_EXC_ERROR;
ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;





--Assign value to OUT variables

x_return_status := l_return_status ;
x_msg_count := l_msg_count ;
x_msg_data := l_msg_data ;
x_new_item_number := lx_new_item_number;
x_new_item_id := lx_new_item_id;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO trx_create_rmk_item;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_create_rmk_item;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_create_rmk_item;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_REMARKET_ASSET_PUB','create_rmk_item');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END create_rmk_item;


    -- Remove item for remarketing
PROCEDURE remove_rmk_item
(    p_api_version           IN  	NUMBER,
     p_init_msg_list         IN  	VARCHAR2 DEFAULT OKL_API.G_FALSE,
     --  SECHAWLA 21-OCT-04 3924244   : changed p_order_header_id to p_order_line_id
     p_order_line_Id         IN     NUMBER ,
     x_return_status         OUT 	NOCOPY VARCHAR2,
     x_msg_count             OUT 	NOCOPY NUMBER,
     x_msg_data              OUT 	NOCOPY VARCHAR2

) IS



    lp_order_line_id    NUMBER; --  SECHAWLA 21-OCT-04 3924244   : changed p_order_header_id to p_order_line_id

    l_api_version       NUMBER ;
    l_init_msg_list     VARCHAR2(1) ;
    l_return_status     VARCHAR2(1);
    l_msg_count         NUMBER ;
    l_msg_data          VARCHAR2(2000);


BEGIN
SAVEPOINT trx_remove_rmk_item;

l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;


l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;

lp_order_line_id := p_order_line_id;  --  SECHAWLA 21-OCT-04 3924244   : changed p_order_header_id to p_order_line_id



-- call the insert of pvt

	OKL_AM_REMARKET_ASSET_PVT.remove_rmk_item(  p_api_version            => l_api_version,
                                                p_init_msg_list          => l_init_msg_list ,
                                                --  SECHAWLA 21-OCT-04 3924244   : changed p_order_header_id to p_order_line_id
                                                p_order_line_Id          => lp_order_line_id,
                                                x_return_status          => l_return_status,
                                                x_msg_count              => l_msg_count,
                                                x_msg_data               => l_msg_data
                                                ) ;



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
      ROLLBACK TO trx_remove_rmk_item;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_remove_rmk_item;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_remove_rmk_item;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_REMARKET_ASSET_PUB','remove_rmk_item');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END remove_rmk_item;


END OKL_AM_REMARKET_ASSET_PUB;

/
