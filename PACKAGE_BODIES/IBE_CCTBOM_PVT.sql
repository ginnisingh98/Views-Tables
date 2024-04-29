--------------------------------------------------------
--  DDL for Package Body IBE_CCTBOM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_CCTBOM_PVT" AS
/* $Header: IBEVCBMB.pls 120.1 2005/12/21 20:32:36 ssekar noship $ */

FUNCTION Validate_Model_Bundle(p_model_id IN NUMBER, p_organization_id IN NUMBER)
RETURN VARCHAR2
IS
     l_item_id 			NUMBER;
     l_optional 		NUMBER;
     l_component_code 		VARCHAR2(1000);
     l_total_component_items  	NUMBER;
     l_isModelBundle 		VARCHAR2(1);
     l_isEmptyModelItem 	VARCHAR2(1); --gzhang 12/12/02, #2709735

     cursor l_option_class_csr IS
	SELECT component_item_id,optional,bom_item_type	FROM BOM_EXPLOSIONS
	WHERE  top_bill_sequence_id =
	                (SELECT bill_sequence_id FROM bom_structures_b
                         WHERE assembly_item_id = p_model_id
                           AND organization_id = p_organization_id
                           AND alternate_bom_designator IS NULL)
	AND EXPLOSION_TYPE = 'ALL'
	AND organization_id = p_organization_id
	AND plan_level=1
	AND NVL(disable_date,sysdate) >=sysdate
	AND NVL(effectivity_date,sysdate) <= sysdate;

BEGIN
     IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
     IBE_UTIL.DEBUG(G_PKG_NAME||'.Validate_Model_Bundle: Validating model bundle, item_id='||p_model_id||',organization_id='||p_organization_id);
     END IF;

     l_isModelBundle := FND_API.G_TRUE;
     l_isEmptyModelItem := FND_API.G_TRUE; --gzhang 12/12/02, #2709735

     FOR option_class_rec IN l_option_class_csr LOOP

     IF option_class_rec.optional <> 2 OR option_class_rec.bom_item_type <> 2 THEN

     	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
     	IBE_UTIL.DEBUG(G_PKG_NAME||'.Validate_Model_Bundle:'
     	    ||option_class_rec.component_item_id||' is not a required optional class, optional='||option_class_rec.optional
     	    ||',bom_item_type='||option_class_rec.bom_item_type);
     	END IF;

     	l_isModelBundle := FND_API.G_FALSE;

     ELSE
     	l_component_code := p_model_id || '-' || option_class_rec.component_item_id || '-%';
     	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
     	IBE_UTIL.DEBUG(G_PKG_NAME||'.Validate_Model_Bundle: Looking for items with component code like '||l_component_code);
     	END IF;

        SELECT count(component_item_id) into l_total_component_items
        FROM BOM_EXPLOSIONS
     	WHERE top_bill_sequence_id =
     	                     (SELECT bill_sequence_id
     	                      FROM bom_structures_b
                              WHERE assembly_item_id = p_model_id
                                AND organization_id = p_organization_id
                                AND alternate_bom_designator IS NULL)
	  AND EXPLOSION_TYPE = 'ALL'
     	  AND plan_level = 2
     	  AND organization_id = p_organization_id
     	  AND component_code like l_component_code
	  AND NVL(disable_date,sysdate) >=sysdate
	  AND NVL(effectivity_date,sysdate) <= sysdate;

     	IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
     	IBE_UTIL.DEBUG(G_PKG_NAME||'.Validate_Model_Bundle: Found '||l_total_component_items||' component item(s)');
     	END IF;
     	IF l_total_component_items = 1 THEN
            SELECT component_item_id, optional into l_item_id,l_optional
            FROM BOM_EXPLOSIONS
     	    WHERE top_bill_sequence_id =
     	                       (SELECT bill_sequence_id
     	                        FROM bom_structures_b
                                WHERE assembly_item_id = p_model_id
                                  AND organization_id = p_organization_id
                                  AND alternate_bom_designator IS NULL)
     	       AND EXPLOSION_TYPE = 'ALL'
     	       AND plan_level = 2
     	       AND organization_id = p_organization_id
     	       AND component_code like l_component_code
	       AND NVL(disable_date,sysdate) >=sysdate
	       AND NVL(effectivity_date,sysdate) <= sysdate;
     	    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
     	    IBE_UTIL.DEBUG(G_PKG_NAME||'.Validate_Model_Bundle: item_id='||l_item_id||', optional='||l_optional);
     	    END IF;
     	    IF l_optional <> 1 THEN
     	        l_isModelBundle := FND_API.G_FALSE;
     	        IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
     	        IBE_UTIL.DEBUG(G_PKG_NAME||'.Validate_Model_Bundle: component item(item_id='||l_item_id||') not optional, optional='||l_optional);
     	        END IF;
     	    END IF;
     	ELSE
     	    l_isModelBundle := FND_API.G_FALSE;
     	    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
     	    IBE_UTIL.DEBUG(G_PKG_NAME||'.Validate_Model_Bundle: optional class (item_id='||option_class_rec.component_item_id||') contains '||l_total_component_items||'(more than one or ZERO) items');
     	    END IF;
     	END IF;
     END IF;
     l_isEmptyModelItem := FND_API.G_FALSE; --gzhang 12/12/02, #2709735
     EXIT WHEN l_isModelBundle = FND_API.G_FALSE;
     END LOOP;

     IF l_option_class_csr%ISOPEN THEN
         CLOSE l_option_class_csr;
     END IF;

     --gzhang 12/16/02, #2709735
     IF l_isEmptyModelItem = FND_API.G_TRUE THEN
     l_isModelBundle := FND_API.G_FALSE;
      IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
     	IBE_UTIL.DEBUG(G_PKG_NAME||'.Validate_Model_Bundle: No child items found');
      END IF;
     END IF;

     IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
     IBE_UTIL.DEBUG(G_PKG_NAME||'.Validate_Model_Bundle: return '||l_isModelBundle);
     END IF;
     --gzhang 08/08/2002, bug#2488246
     --IBE_UTIL.DISABLE_DEBUG;
     RETURN l_isModelBundle;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
     	     IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
     	     IBE_UTIL.DEBUG(G_PKG_NAME||'.Validate_Model_Bundle: NO_DATA_FOUND Exception, return F');
     	     END IF;
     	     --gzhang 08/08/2002, bug#2488246
             --IBE_UTIL.DISABLE_DEBUG;
     	     RETURN FND_API.G_FALSE;
     	WHEN OTHERS THEN
     	     IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
     	     IBE_UTIL.DEBUG(G_PKG_NAME||'.Validate_Model_Bundle: OTHERS Exception, return F');
     	     END IF;
     	     --gzhang 08/08/2002, bug#2488246
             --IBE_UTIL.DISABLE_DEBUG;
     	     RETURN FND_API.G_FALSE;
END Validate_Model_Bundle;


-- Start of comments
--    API name   : Is_Model_Bundle
--    Type       : Private.
--    Function   : Given a model item id, returns 'T' if this is a model bundle,
--                 otherwise returns 'F'
--
--    Pre-reqs   : None.
--    Parameters :
--    IN         : p_api_version                IN  NUMBER   Required
--                 p_init_msg_list              IN  VARCHAR2 Optional
--                     Default = FND_API.G_FALSE
--                 p_validation_level           IN  NUMBER   Optional
--                     Default = FND_API.G_VALID_LEVEL_FULL
--
--                 p_model_id                   IN NUMBER Required
--                 p_orgnization_id             IN  NUMBER, Required
--
--
--
--
--
--    Version    : Current version      1.0
--
--                 previous version     None
--
--
--                 Initial version      1.0
--
--    Notes      : Note text
--
-- End of comments

Function Is_Model_Bundle
                (p_api_version                  IN  NUMBER,
                 p_init_msg_list                IN  VARCHAR2 := FND_API.G_FALSE,
                 p_validation_level             IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                 p_model_id                     IN  NUMBER,
                 p_organization_id               IN  NUMBER
                )

RETURN VARCHAR2

IS

    l_bundle       VARCHAR2(1) := FND_API.G_FALSE;


    l_api_version       CONSTANT NUMBER       := 1.0;
    l_explosion_date            DATE := sysdate;
    l_error_code                NUMBER;
    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

    l_count                     NUMBER := 0;
    l_validate			VARCHAR2(1);

    l_bom_item_type		NUMBER;
    l_resp_id 			NUMBER;
    l_resp_appl_id		NUMBER;

    cursor l_bom_item_type_csr IS
      SELECT MSIV.bom_item_type
      FROM mtl_system_items_vl MSIV
      WHERE MSIV.inventory_item_id = p_model_id
        AND MSIV.organization_id = p_organization_id;

BEGIN
   --gzhang 08/08/2002, bug#2488246
   --ibe_util.enable_debug;

   -- begin API body
   l_return_status := FND_API.G_RET_STS_SUCCESS;
   IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
   IBE_UTIL.debug(G_PKG_NAME||'.Is_Model_Bundle : p_model_id ='||p_model_id||', p_organization_id='||p_organization_id);
   END IF;

   OPEN l_bom_item_type_csr;
   FETCH l_bom_item_type_csr INTO l_bom_item_type;
   CLOSE l_bom_item_type_csr;

   l_resp_id := FND_PROFILE.value('RESP_ID');
   l_resp_appl_id := FND_PROFILE.value('RESP_APPL_ID');

   IF l_bom_item_type = 1 AND CZ_CF_API.UI_FOR_ITEM(p_model_id, p_organization_id, SYSDATE, 'DHTML', FND_API.G_MISS_NUM, l_resp_id, l_resp_appl_id) IS NULL THEN
       -- Call BOM Explosion API
       IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
       IBE_UTIL.debug(G_PKG_NAME||'.Is_Model_Bundle :Calling BOMPNORD.Bmxporder_Explode_For_Order()');
       END IF;
       Explode(p_validation_org => p_organization_id,
          p_levels         => 6, --??
          p_stdcompflag    => 'ALL',
          p_top_item_id    => p_model_id,
          p_revdate        => l_explosion_date,
          x_msg_data       => l_msg_data,
          x_error_code     => l_error_code,
          x_return_status  => l_return_status);
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
          IBE_UTIL.debug(G_PKG_NAME||'.Is_Model_Bundle : RAISE FND_API.G_RET_STS_UNEXP_ERROR');
          END IF;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
          IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
          IBE_UTIL.debug(G_PKG_NAME||'.Is_Model_Bundle : RAISE FND_API.G_RET_STS_ERROR');
          END IF;
          RAISE FND_API.G_EXC_ERROR;
      ELSE
          l_bundle := Validate_Model_Bundle(p_model_id,p_organization_id);
          IF l_bundle = FND_API.G_FALSE THEN
              IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
              IBE_UTIL.debug(G_PKG_NAME||'.Is_Model_Bundle : Model bundle ( item_id='||p_model_id||') is invalid. Incorrect BOM setup.');
              END IF;
          ELSE
              IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
              IBE_UTIL.debug(G_PKG_NAME||'.Is_Model_Bundle : valid model bundle, item_id='||p_model_id);
              END IF;
          END IF;
          IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
          IBE_UTIL.debug(G_PKG_NAME||'.Is_Model_Bundle : Validate_Model_Bundle('||p_model_id||','||p_organization_id||') returns '||l_bundle);
          END IF;
      END IF;
  ELSE
      l_bundle := FND_API.G_FALSE;
      IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
      IBE_UTIL.debug(G_PKG_NAME||'.Is_Model_Bundle : Item( item_id='||p_model_id||') is not a model bundle.');
      END IF;
  END IF;
  return l_bundle;
END Is_Model_Bundle;


-- Start of comments
--    API name   : Load_Components
--    Type       : Private.
--    Function   : Given a model item id, retrieve all the component item ids of
--                 this model item.
--    Pre-reqs   : None.
--    Parameters :
--    IN         : p_api_version        IN  NUMBER   Required
--                 p_init_msg_list      IN  VARCHAR2 Optional
--                                          Default = FND_API.G_FALSE
--                 p_validation_level   IN  NUMBER   Optional
--                                          Default = FND_API.G_VALID_LEVEL_FULL
--
--                 p_model_id           IN NUMBER Required
--                 p_organization_id    IN NUMBER Required
--
--    OUT        : x_return_status      OUT NOCOPY VARCHAR2(1)
--                 x_msg_count          OUT NOCOPY NUMBER
--                 x_msg_data           OUT NOCOPY VARCHAR2(2000)
--                 x_item_csr           OUT NOCOPY IBE_CCTBOM_REF_CSR_TYPE
--                 Record type = IBE_BOM_EXPLOSION_REC
--
--
--
--
--    Version    : Current version 1.0
--
--
--                 previous version     None
--
--                 Initial version      1.0
--
--    Notes      : Note text
--
-- End of comments

  procedure Load_Components
          (p_api_version             IN  NUMBER,
           p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
           p_validation_level        IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
           x_return_status           OUT NOCOPY VARCHAR2,
           x_msg_count               OUT NOCOPY NUMBER,
           x_msg_data                OUT NOCOPY VARCHAR2,
           p_model_id                IN  NUMBER,
           p_organization_id         IN  NUMBER ,
           x_item_csr                OUT NOCOPY IBE_CCTBOM_REF_CSR_TYPE) IS

    l_api_name          CONSTANT VARCHAR2(30) := 'Load_Components';
    l_api_version       CONSTANT NUMBER       := 1.0;

    l_explosion_date            DATE := sysdate;
    l_error_code                NUMBER;
    l_return_status             VARCHAR2(1);
    l_msg_count                 NUMBER;
    l_msg_data                  VARCHAR2(2000);

 BEGIN
   --dbms_output.put_line('INSIDE LOAD COMPONENTS');
   --gzhang 08/08/2002, bug#2488246
   --ibe_util.enable_debug;
   --  standard call to check for call compatibility
   l_return_status := FND_API.G_RET_STS_SUCCESS;
   IF NOT FND_API.Compatible_API_Call (l_api_version,
                           p_api_version,
                           l_api_name,
                           G_PKG_NAME   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- initialize message list if p_init_msg_list is set to TRUE
   IF FND_API.to_Boolean(p_init_msg_list) THEN
     FND_MSG_PUB.initialize;
   END IF;

   -- initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
   IBE_UTIL.debug(G_PKG_NAME||'.Load_Components');
   -- begin API body
   -- Call BOM Explosion API
   IBE_UTIL.debug(G_PKG_NAME||'.Load_Components: Calling BOMPNORD.Bmxporder_Explode_For_Order()');
   IBE_UTIL.debug(G_PKG_NAME||'.Load_Components: BEFORE EXPLODE in LOAD');
   END IF;

   Explode(p_validation_org => p_organization_id,
          p_levels         => 6, --??
          p_stdcompflag    => 'ALL',
          p_top_item_id    => p_model_id,
          p_revdate        => l_explosion_date,
          x_msg_data       => l_msg_data,
          x_error_code     => l_error_code,
          x_return_status  => l_return_status);
  IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
  IBE_UTIL.debug(G_PKG_NAME||'.Load_Components: AFTER Explode reture status = '||l_return_status); --gzhang 05/24/2002 typo error
  END IF;

  IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
  END IF;

  OPEN x_item_csr FOR
  SELECT COMPONENT_ITEM_ID,
         PLAN_LEVEL,
         OPTIONAL,
         PARENT_BOM_ITEM_TYPE,
         BOM_ITEM_TYPE,
         PRIMARY_UOM_CODE,
         COMPONENT_QUANTITY,
         COMPONENT_CODE
  FROM   BOM_EXPLOSIONS
  WHERE  top_bill_sequence_id =
               (SELECT bill_sequence_id FROM bom_structures_b
                WHERE assembly_item_id = p_model_id
                  AND organization_id = p_organization_id
                  AND alternate_bom_designator IS NULL)
  AND    ORGANIZATION_ID = p_organization_id  --gzhang 01/16/2003, bug#2750492
  AND    EXPLOSION_TYPE = 'ALL'
  AND    PARENT_BOM_ITEM_TYPE < 3
  AND    COMPONENT_ITEM_ID <> TOP_ITEM_ID
  --AND    OPTIONAL = 2
  AND    DISABLE_DATE >= sysdate;

   -- end API body
   --dbms_output.put_line('After select in load ');
   IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
   IBE_UTIL.debug(G_PKG_NAME||'.Load_Components: After select in load');
   END IF;

   -- standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (    p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
        );
   --gzhang 08/08/2002, bug#2488246
   --ibe_util.disable_debug;
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MSG_PUB.Count_And_Get
          (    p_encoded => FND_API.G_FALSE,
               p_count => x_msg_count,
               p_data  => x_msg_data
                );
        --gzhang 08/08/2002, bug#2488246
        --ibe_util.disable_debug;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.Count_And_Get
          (    p_encoded => FND_API.G_FALSE,
               p_count => x_msg_count,
               p_data  => x_msg_data
                );
        --gzhang 08/08/2002, bug#2488246
        --ibe_util.disable_debug;
      WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.Set_Name('FND', 'SQL_PLSQL_ERROR');
          FND_MESSAGE.Set_Token('ROUTINE', l_api_name);
          FND_MESSAGE.Set_Token('ERRNO', SQLCODE);
          FND_MESSAGE.Set_Token('REASON', SQLERRM);
          FND_MSG_PUB.Add;
     IF   FND_MSG_PUB.Check_Msg_Level
          (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN FND_MSG_PUB.Add_Exc_Msg
               (    G_PKG_NAME,
                    l_api_name
               );
     END IF;
     FND_MSG_PUB.Count_And_Get
          (    p_encoded => FND_API.G_FALSE,
               p_count => x_msg_count,
               p_data  => x_msg_data
          );
        --gzhang 08/08/2002, bug#2488246
        --ibe_util.disable_debug;
END Load_Components;

/*----------------------------------------------------------------------
Procedure Name : Explode
Description    :
-----------------------------------------------------------------------*/
Procedure Explode
( p_validation_org IN  NUMBER
, p_group_id       IN  NUMBER := NULL
, p_session_id     IN  NUMBER := NULL
, p_levels         IN  NUMBER := 60
, p_stdcompflag    IN  VARCHAR2 := 'ALL'
, p_exp_quantity   IN  NUMBER := NULL
, p_top_item_id    IN  NUMBER
, p_revdate        IN  DATE
, p_component_code IN  VARCHAR2 := NULL
, x_msg_data       OUT NOCOPY VARCHAR2
, x_error_code     OUT NOCOPY NUMBER
, x_return_status  OUT NOCOPY VARCHAR2)
IS
  l_group_id   NUMBER; -- bom out param
BEGIN

    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
    IBE_UTIL.debug(G_PKG_NAME||'.Explode: Inside EXPLODE before call itemid = '||p_top_item_id);
    END IF;

    BOMPNORD.Bmxporder_Explode_For_Order(
          org_id             => p_validation_org,
          copy_flag          => 2,
          expl_type          => p_stdcompflag,
          order_by           => 2,
          grp_id             => l_group_id,
          session_id         => p_session_id,
          levels_to_explode  => 60,
          item_id            => p_top_item_id,
          rev_date           => to_char(p_revdate,'YYYY/MM/DD HH24:MI'),
          user_id            => 0,
          commit_flag        => 'Y',
          err_msg            => x_msg_data,
          error_code         => x_error_code);
    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
    IBE_UTIL.debug(G_PKG_NAME||'.Explode: Error Msg = '||x_msg_data);
    IBE_UTIL.debug(G_PKG_NAME||'.Explode: Error_code = '|| x_error_code);
    IBE_UTIL.debug(G_PKG_NAME||'.Explode: grp_id = '|| l_group_id);

    IBE_UTIL.debug(G_PKG_NAME||'.Explode: After calling bom Explode api');
    END IF;

    IF x_error_code <> 0 THEN
	  --dbms_output.put_line('Error in BOM Explosion');
	  IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
	  IBE_UTIL.debug('Error in BOM Explosion');
	  END IF;
	  IF x_msg_data is not null THEN
	    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
        	IBE_UTIL.debug(G_PKG_NAME||'.Explode: BOM msg name= ' || substr(x_msg_data, 1, 250));
            END IF;

          -- girish from bom team told err_msg is msg name, track bug 1623728
          FND_MESSAGE.Set_Name('BOM', x_msg_data);

          END IF;

      RAISE FND_API.G_EXC_ERROR;
    END IF;


    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF (IBE_UTIL.G_DEBUGON = FND_API.G_TRUE) THEN
    IBE_UTIL.debug(G_PKG_NAME||'.Explode: Exiting Ibe_CctBom_Pvt.Explode');
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
END Explode;

end IBE_CCTBOM_PVT;

/
