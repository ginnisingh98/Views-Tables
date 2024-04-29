--------------------------------------------------------
--  DDL for Package Body QP_LOCK_PRICELIST_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_LOCK_PRICELIST_GRP" AS
/* $Header: QPXGLKPB.pls 120.2 2005/10/13 16:02:26 rchellam noship $ */

PROCEDURE Lock_Price (p_source_list_line_id	   IN	NUMBER,
                      p_list_source_code           IN   VARCHAR2,
                      p_orig_system_header_ref     IN   VARCHAR2,
                      --added for MOAC
                      p_org_id                     IN   NUMBER DEFAULT NULL,
                      p_commit                     IN   VARCHAR2 DEFAULT 'F',
                      --added for OKS bug 4504825
                      x_locked_price_list_id       OUT  NOCOPY 	NUMBER,
                      x_locked_list_line_id        OUT 	NOCOPY 	NUMBER,
                      x_return_status              OUT 	NOCOPY 	VARCHAR2,
 		      x_msg_count                  OUT 	NOCOPY 	NUMBER,
		      x_msg_data                   OUT 	NOCOPY 	VARCHAR2)
IS

l_source_price_list_id   NUMBER;

BEGIN

  --Check if required parameters have been passed.
  IF  p_source_list_line_id IS NULL THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE','p_source_list_line_id');
    fnd_msg_pub.Add;
  END IF;

  IF  p_list_source_code IS NULL THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE','p_list_source_code');
    fnd_msg_pub.Add;
  END IF;

  IF  p_orig_system_header_ref IS NULL THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    FND_MESSAGE.SET_NAME('QP','QP_ATTRIBUTE_REQUIRED');
    FND_MESSAGE.SET_TOKEN('ATTRIBUTE','p_orig_system_header_ref');
    fnd_msg_pub.Add;
  END IF;

  --Fetch source price list id for given p_source_list_line_id
  BEGIN
    SELECT list_header_id
    INTO   l_source_price_list_id
    FROM   qp_list_lines
    WHERE  list_line_id = p_source_list_line_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('QP','QP_INVALID_LIST_HEADER_ID');
      FND_MESSAGE.SET_TOKEN('ATTRIBUTE','p_source_list_line_id');
      FND_MSG_PUB.Add;
  END;

  --Raise Error if error status is set.
  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --Call Private Lock_Price API
  QP_LOCK_PRICELIST_PVT.Lock_Price (
                p_source_price_list_id       => l_source_price_list_id,
                p_source_list_line_id        => p_source_list_line_id,
                p_startup_mode               => p_list_source_code,
                p_orig_system_header_ref     => p_orig_system_header_ref,
                --added for MOAC
                p_org_id                     => p_org_id,
                p_commit                     => p_commit,
                --added for OKS bug 4504825
                x_locked_price_list_id       => x_locked_price_list_id,
                x_locked_list_line_id        => x_locked_list_line_id,
                x_return_status              => x_return_status,
                x_msg_count                  => x_msg_count,
                x_msg_data                   => x_msg_data);

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

        --  Get message count and data
        fnd_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

 WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        fnd_msg_pub.Add_Exc_Msg
        (   G_PKG_NAME
        ,   'Process_Price_List'
        ,   substr(sqlerrm, 1, 240)
        );

        --  Get message count and data
        fnd_msg_pub.Count_And_Get
        (   p_count                       => x_msg_count
        ,   p_data                        => x_msg_data
        );

END Lock_Price;

END QP_LOCK_PRICELIST_GRP;

/
