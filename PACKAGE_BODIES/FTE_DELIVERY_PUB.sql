--------------------------------------------------------
--  DDL for Package Body FTE_DELIVERY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FTE_DELIVERY_PUB" AS
/* $Header: FTEPDELB.pls 120.0 2005/05/26 18:27:20 appldev noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'FTE_DELIVERY_PUB';

--===================
-- PROCEDURES
--===================

PROCEDURE Rate_Delivery (
  p_api_version         IN		NUMBER,
  p_init_msg_list	IN		VARCHAR2,
  p_commit	    	IN  		VARCHAR2,
  x_return_status	OUT NOCOPY	VARCHAR2,
  x_msg_count		OUT NOCOPY	NUMBER,
  x_msg_data		OUT NOCOPY	VARCHAR2,
  p_action_code		IN		VARCHAR2,
  p_delivery_in_rec	IN		delivery_in_rec_type
)
IS
  l_api_name 	CONSTANT VARCHAR2(30) := 'Rate_Delivery';
  l_api_version CONSTANT NUMBER := 1.0;
  l_del_in_rec  FTE_FREIGHT_RATING_DLVY_GRP.delivery_in_rec_type;
BEGIN
  IF NOT FND_API.Compatible_API_Call (
    	   	l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME )
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF p_action_code = 'RATE' THEN

    l_del_in_rec.name := p_delivery_in_rec.name;
    l_del_in_rec.carrier_name := p_delivery_in_rec.carrier_name;
    l_del_in_rec.mode_of_transport := p_delivery_in_rec.mode_of_transport;
    l_del_in_rec.service_level := p_delivery_in_rec.service_level;

    FTE_FREIGHT_RATING_DLVY_GRP.Rate_Delivery2 (
      p_commit			=> p_commit,
      x_return_status		=> x_return_status,
      x_msg_count 		=> x_msg_count,
      x_msg_data		=> x_msg_data,
      p_delivery_in_rec		=> l_del_in_rec
      );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  ELSE
    FND_MESSAGE.SET_NAME('FTE','FTE_PRC_DLV_INV_ACT');
    FND_MSG_PUB.ADD;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

    FND_MSG_PUB.Count_And_Get (
	p_count  => x_msg_count,
	p_data  =>  x_msg_data,
	p_encoded => FND_API.G_FALSE
    );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
	p_count  => x_msg_count,
	p_data  =>  x_msg_data,
	p_encoded => FND_API.G_FALSE
    );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get (
	p_count  => x_msg_count,
	p_data  =>  x_msg_data,
	p_encoded => FND_API.G_FALSE
    );
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level
  	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get (
	p_count  => x_msg_count,
	p_data  =>  x_msg_data,
	p_encoded => FND_API.G_FALSE
    );
END Rate_Delivery;

END FTE_DELIVERY_PUB;

/
