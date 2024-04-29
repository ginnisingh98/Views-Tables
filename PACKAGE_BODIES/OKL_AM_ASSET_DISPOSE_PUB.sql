--------------------------------------------------------
--  DDL for Package Body OKL_AM_ASSET_DISPOSE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_ASSET_DISPOSE_PUB" AS
/* $Header: OKLPADPB.pls 120.5 2006/11/22 18:39:38 rravikir noship $ */

 PROCEDURE dispose_asset (	p_api_version           IN  	NUMBER,
           			p_init_msg_list         IN  	VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                x_return_status         OUT 	NOCOPY VARCHAR2,
                                x_msg_count             OUT 	NOCOPY NUMBER,
           			x_msg_data              OUT 	NOCOPY VARCHAR2,
				p_financial_asset_id    IN      NUMBER,
                                p_quantity              IN      NUMBER,
                                p_proceeds_of_sale      IN      NUMBER,
                                p_quote_eff_date        IN      DATE DEFAULT NULL, -- rmunjulu EDAT
                                p_quote_accpt_date      IN      DATE DEFAULT NULL, -- rmunjulu EDAT
                                p_legal_entity_id       IN      NUMBER)      -- RRAVIKIR Legal Entity Changes
                                IS

    l_api_version               NUMBER ;
    l_init_msg_list             VARCHAR2(1) ;
    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER ;
    l_msg_data                  VARCHAR2(2000);

    lp_financial_asset_id       NUMBER;
    lp_quantity                 NUMBER;
    lp_proceeds_of_sale         NUMBER;

    -- rmunjulu EDAT
    lp_quote_eff_date DATE;
    lp_quote_accpt_date DATE;

BEGIN
SAVEPOINT trx_dispose_asset;

l_api_version   := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count     := x_msg_count ;
l_msg_data      := x_msg_data ;

lp_financial_asset_id       := p_financial_asset_id;
lp_quantity                 := p_quantity;
lp_proceeds_of_sale         := p_proceeds_of_sale;

    -- rmunjulu EDAT
lp_quote_eff_date           := p_quote_eff_date;
lp_quote_accpt_date         := p_quote_accpt_date;


-- call the insert of pvt

	OKL_AM_ASSET_DISPOSE_PVT.dispose_asset(
                                    p_api_version            =>  l_api_version,
           			    p_init_msg_list          => l_init_msg_list,
                                    x_return_status          => l_return_status,
                                    x_msg_count              => l_msg_count,
           			    x_msg_data               => l_msg_data,
				    p_financial_asset_id     => lp_financial_asset_id,
                                    p_quantity               => lp_quantity,
                                    p_proceeds_of_sale       => lp_proceeds_of_sale,
                                    p_quote_eff_date         => lp_quote_eff_date,     -- rmunjulu EDAT
                                    p_quote_accpt_date       => lp_quote_accpt_date,   -- rmunjulu EDAT
                                    p_legal_entity_id        => p_legal_entity_id);  -- RRAVIKIR Legal Entity Changes



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
      ROLLBACK TO trx_dispose_asset;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_dispose_asset;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_dispose_asset;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_ASSET_DISPOSE_PUB','dispose_asset');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END dispose_asset;


--  SECHAWLA 21-OCT-04 3924244   : changed p_order_header_id to p_order_line_id
PROCEDURE dispose_asset (	    p_api_version           IN  	NUMBER,
           			            p_init_msg_list         IN  	VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                x_return_status         OUT 	NOCOPY VARCHAR2,
                                x_msg_count             OUT 	NOCOPY NUMBER,
           			            x_msg_data              OUT 	NOCOPY VARCHAR2,
				                p_order_line_id         IN      NUMBER) IS

    l_api_version               NUMBER ;
    l_init_msg_list             VARCHAR2(1) ;
    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER ;
    l_msg_data                  VARCHAR2(2000);

    lp_order_line_id            NUMBER; --  SECHAWLA 21-OCT-04 3924244



BEGIN
SAVEPOINT trx_dispose_asset;

l_api_version   := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count     := x_msg_count ;
l_msg_data      := x_msg_data ;

lp_order_line_id    := p_order_line_id;   --  SECHAWLA 21-OCT-04 3924244





-- call the insert of pvt

	OKL_AM_ASSET_DISPOSE_PVT.dispose_asset(
                                    p_api_version            =>  l_api_version,
           			    p_init_msg_list          => l_init_msg_list,
                                    x_return_status          => l_return_status,
                                    x_msg_count              => l_msg_count,
           			    x_msg_data               => l_msg_data,
				    p_order_line_id          => lp_order_line_id);



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
      ROLLBACK TO trx_dispose_asset;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_dispose_asset;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_dispose_asset;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_ASSET_DISPOSE_PUB','dispose_asset');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END dispose_asset;


PROCEDURE undo_retirement(	   p_api_version            IN  	NUMBER,
           			                p_init_msg_list         IN  	VARCHAR2 DEFAULT OKC_API.G_FALSE,
                                    x_return_status         OUT 	NOCOPY VARCHAR2,
                                    x_msg_count             OUT 	NOCOPY NUMBER,
           			                x_msg_data              OUT 	NOCOPY VARCHAR2,
				                    p_retirement_id         IN      NUMBER) IS


    l_api_version   NUMBER ;
    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER ;
    l_msg_data      VARCHAR2(2000);
    lp_retirement_id  NUMBER;

BEGIN
SAVEPOINT trx_undo_retirement;

l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;
lp_retirement_id := p_retirement_id;




-- call the insert of pvt

	OKL_AM_ASSET_DISPOSE_PVT.undo_retirement(
                                    p_api_version            =>  l_api_version,
           			                p_init_msg_list          => l_init_msg_list,
                                    x_return_status          => l_return_status,
                                    x_msg_count              => l_msg_count,
           			                x_msg_data               => l_msg_data,
				                    p_retirement_id          => lp_retirement_id
                                    );


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
      ROLLBACK TO trx_undo_retirement;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_undo_retirement;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_undo_retirement;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_ASSET_DISPOSE_PUB','undo_retirement');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END undo_retirement;


PROCEDURE expire_item (
		p_api_version		IN  NUMBER,
		p_init_msg_list		IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
		x_msg_count	    	OUT NOCOPY NUMBER,
		x_msg_data		    OUT NOCOPY VARCHAR2,
		x_return_status		OUT NOCOPY VARCHAR2,
		p_instance_id		IN  NUMBER,
		p_end_date		    IN  DATE)
 IS

    l_api_version   NUMBER ;
    l_init_msg_list VARCHAR2(1) ;
    l_return_status VARCHAR2(1);
    l_msg_count     NUMBER ;
    l_msg_data      VARCHAR2(2000);
    lp_instance_id  NUMBER;
    lp_end_date     DATE;
BEGIN
SAVEPOINT trx_expire_item;

l_api_version := p_api_version ;
l_init_msg_list := p_init_msg_list ;
l_return_status := x_return_status ;
l_msg_count := x_msg_count ;
l_msg_data := x_msg_data ;

lp_instance_id := p_instance_id;
lp_end_date := p_end_date;





-- call the insert of pvt

	OKL_AM_ASSET_DISPOSE_PVT.expire_item(
                                    p_api_version            =>  l_api_version,
                                    p_init_msg_list          => l_init_msg_list,
                                    x_msg_count              => l_msg_count,
           			                x_msg_data               => l_msg_data,
                                    x_return_status          => l_return_status,
				                    p_instance_id            => lp_instance_id,
                                    p_end_date               => lp_end_date );

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
      ROLLBACK TO trx_expire_item;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO trx_expire_item;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO trx_expire_item;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := l_msg_count ;
      x_msg_data := l_msg_data ;
      FND_MSG_PUB.ADD_EXC_MSG('OKL_AM_ASSET_DISPOSE_PUB','expire_item');
      FND_MSG_PUB.count_and_get(
             p_count   => x_msg_count
            ,p_data    => x_msg_data);
END expire_item;


END OKL_AM_ASSET_DISPOSE_PUB;

/
