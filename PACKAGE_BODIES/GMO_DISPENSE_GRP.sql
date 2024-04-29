--------------------------------------------------------
--  DDL for Package Body GMO_DISPENSE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_DISPENSE_GRP" AS
/* $Header: GMOGDSPB.pls 120.10 2007/12/13 18:18:12 srpuri ship $ */

PROCEDURE MAINTAIN_RESERVATION(p_api_version        NUMBER,
                               p_init_msg_list IN VARCHAR2,
                               p_commit	       IN VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count OUT NOCOPY NUMBER,
                               x_msg_data  OUT NOCOPY VARCHAR2,
                               p_batch_id           NUMBER,
                               p_old_reservation_id NUMBER,
                               p_new_reservation_id NUMBER,
                               p_batchstep_id       NUMBER,
                               p_item_id            NUMBER,
                               p_material_detail_id NUMBER
                               )
IS
l_api_name        CONSTANT VARCHAR2(30) := 'MAINTAIN_RESERVATION';
l_api_version     CONSTANT NUMBER       := 1.0;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT	MAINTAIN_RESERVATION;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version ,
          	    	    	    	 	  p_api_version,
     	       	    	 			     l_api_name,
  		    	    	    	    	G_PKG_NAME )
      THEN
  		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
      END IF;

       -- check if GMO is enabled
      IF (GMO_SETUP_GRP.IS_GMO_ENABLED = GMO_CONSTANTS_GRP.NO) THEN
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         FND_MESSAGE.SET_NAME('GMO','GMO_DISABLED_ERR');
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
         if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
             FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_dispense_grp.maintain_reservation', FALSE);
         end if;
         RETURN;
      END IF;


      -- Maintain Reservation starts now
      -- first update the material dispense table
      UPDATE GMO_MATERIAL_DISPENSES
          SET reservation_id = p_new_reservation_id
        WHERE batch_id = p_batch_id
          and inventory_item_id = p_item_id
          and material_detail_id = p_material_detail_id
          and reservation_id = p_old_reservation_id
          and nvl(batch_step_id,1) = nvl(p_batchstep_id,1);

      UPDATE GMO_MATERIAL_UNDISPENSES
	   SET reservation_id = p_new_reservation_id
	 WHERE batch_id = p_batch_id
	   and inventory_item_id = p_item_id
	   and material_detail_id = p_material_detail_id
	   and reservation_id = p_old_reservation_id
          and nvl(batch_step_id,1) = nvl(p_batchstep_id,1);

      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

       IF FND_API.To_Boolean( p_commit ) THEN
      		COMMIT;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count=>      x_msg_count,
         p_data =>      x_msg_data
      );
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
                ROLLBACK TO MAINTAIN_RESERVATION;
		x_return_status := FND_API.G_RET_STS_ERROR ;
            FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count=>      x_msg_count     	,
        		p_data=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	        ROLLBACK TO MAINTAIN_RESERVATION;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count=>      x_msg_count     	,
        		p_data=>      x_msg_data
    		);
	WHEN OTHERS THEN
	        ROLLBACK TO MAINTAIN_RESERVATION;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count=>      x_msg_count     	,
        		p_data=>      x_msg_data
    		);

END MAINTAIN_RESERVATION;


PROCEDURE CHANGE_DISPENSE_STATUS(p_api_version    NUMBER,
                                 p_init_msg_list IN VARCHAR2,
                                 p_commit	 IN VARCHAR2,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count OUT NOCOPY     NUMBER,
                                 x_msg_data  OUT NOCOPY     VARCHAR2,
                                 p_dispense_id    NUMBER,
                                 p_status_code    VARCHAR2,
                                 p_transaction_id NUMBER
)
IS
l_api_name        CONSTANT VARCHAR2(30) := 'CHANGE_DISPENSE_STATUS';
l_api_version     CONSTANT NUMBER       := 1.0;
WRONG_STATUS_ERROR EXCEPTION;
l_status_code_exists NUMBER;
BEGIN

  -- Standard Start of API savepoint
      SAVEPOINT	CHANGE_DISPENSE_STATUS;
       -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( 	l_api_version        	,
          	    	    	    	 	p_api_version        	,
     	       	    	 			l_api_name 	    	,
  		    	    	    	    	G_PKG_NAME )
      THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END IF;
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
      END IF;
       -- check if GMO is enabled
      IF (GMO_SETUP_GRP.IS_GMO_ENABLED = GMO_CONSTANTS_GRP.NO) THEN
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         FND_MESSAGE.SET_NAME('GMO','GMO_DISABLED_ERR');
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
         if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
             FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_dispense_grp.change_dispense_status', FALSE);

         end if;
         RETURN;
      END IF;

      -- Change status Reservation starts now
      select count(*) into l_status_code_exists
      from fnd_lookups
      where lookup_type = 'GMO_DISP_MTL_STATUS'
       and lookup_code <> 'DISPENSD'
       and  lookup_code = p_status_code;

       if(l_status_code_exists = 0) then

        raise WRONG_STATUS_ERROR;
       end if;

       UPDATE GMO_MATERIAL_DISPENSES
         SET material_status = p_status_code,
             DISPENSE_SOURCE_TRANSACTION_ID = nvl(DISPENSE_SOURCE_TRANSACTION_ID, p_transaction_id)
        WHERE dispense_id = p_dispense_id;

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        IF FND_API.To_Boolean( p_commit ) THEN
      		COMMIT;
      	END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count=>      x_msg_count,
         p_data =>      x_msg_data
      );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO CHANGE_DISPENSE_STATUS;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count=>      x_msg_count     	,
        		p_data=>      x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO CHANGE_DISPENSE_STATUS;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.ADD;
  		FND_MSG_PUB.Count_And_Get
    		(  	p_count=>      x_msg_count     	,
        		p_data=>      x_msg_data
    		);
    WHEN WRONG_STATUS_ERROR THEN
            ROLLBACK TO CHANGE_DISPENSE_STATUS;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.ADD;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count=>      x_msg_count     	,
        		p_data=>      x_msg_data
    		);
	WHEN OTHERS THEN
                ROLLBACK TO CHANGE_DISPENSE_STATUS;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF 	FND_MSG_PUB.Check_Msg_Level
			(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        		FND_MSG_PUB.Add_Exc_Msg
    	    		(	G_PKG_NAME  	    ,
    	    			l_api_name
	    		);
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(  	p_count=>      x_msg_count     	,
        		p_data=>      x_msg_data
    		);

END CHANGE_DISPENSE_STATUS;

PROCEDURE IS_DISPENSE_ITEM (p_api_version     NUMBER,
                            p_init_msg_list   IN      VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            p_inventory_item_id    NUMBER,
                            p_organization_id      NUMBER,
                            p_recipe_id            NUMBER,
                            x_dispense_required   OUT NOCOPY VARCHAR2,
			    x_dispense_config_id  OUT NOCOPY NUMBER)
IS
l_api_name        CONSTANT VARCHAR2(30) := 'IS_DISPENSE_ITEM';
l_api_version     CONSTANT NUMBER       := 1.0;
l_is_dispense_required varchar2(1);
l_plan_qty NUMBER;
l_plan_uom VARCHAR2(10);
l_reserved_qty NUMBER;
l_reservation_uom VARCHAR2(10);

--This variable is a sand box variable.
L_COUNT NUMBER;

GMO_MISSING_SRCH_EXCEPTION EXCEPTION;
GMO_DISP_NOCONFIG_EXCEPTION EXCEPTION;
GMO_ITEM_NOT_RESERVABLE_ERR EXCEPTION;


BEGIN
    IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME )
    THEN        RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

      -- Initialize message list if the caller asks me to do so
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
       -- check if GMO is enabled
      IF (GMO_SETUP_GRP.IS_GMO_ENABLED = GMO_CONSTANTS_GRP.NO) THEN
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         FND_MESSAGE.SET_NAME('GMO','GMO_DISABLED_ERR');
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
         if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
             FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_dispense_grp.IS_DISPENSE_ITEM', FALSE);
         end if;
         x_dispense_required := 'N';
         RETURN ;
      END IF;


    GMO_DISPENSE_SETUP_PVT.IS_DISPENSE_ITEM(p_inventory_item_id => p_inventory_item_id,
                                            p_organization_id => p_organization_id,
                                            p_recipe_id => p_recipe_id,
					    x_is_dispense_required => x_dispense_required,
					    x_dispense_config_id => x_dispense_config_id);
    --Check if item requires dispensing.
    IF X_DISPENSE_REQUIRED = 'Y' THEN

      --Check if the specified item is non-reservable.
      SELECT COUNT(*) INTO L_COUNT
      FROM MTL_SYSTEM_ITEMS_VL
      WHERE INVENTORY_ITEM_ID = P_INVENTORY_ITEM_ID
      AND   ORGANIZATION_ID = P_ORGANIZATION_ID
      AND RESERVABLE_TYPE = 2;

      IF L_COUNT > 0 THEN

        --The specified item is not reservable. Hence raise an exception.
        RAISE GMO_ITEM_NOT_RESERVABLE_ERR;
      END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
      FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
    END IF;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

  WHEN GMO_ITEM_NOT_RESERVABLE_ERR THEN
    x_return_status := 'W';
    x_dispense_required := 'N';
    FND_MESSAGE.SET_NAME('GMO','GMO_ITEM_NOT_RESERVABLE_ERR');
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.COUNT_AND_GET ( P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA );

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
     IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
       FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
     END IF;
     FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );

END IS_DISPENSE_ITEM;

PROCEDURE GET_MATERIAL_DISPENSE_DATA (p_api_version     IN NUMBER,
                                      p_init_msg_list   IN      VARCHAR2,
                                      x_return_status OUT NOCOPY VARCHAR2,
                                      x_msg_count OUT NOCOPY NUMBER,
                                      x_msg_data  OUT NOCOPY VARCHAR2,
                                      p_material_detail_id  IN  NUMBER,
                                      x_dispense_data     OUT NOCOPY GME_COMMON_PVT.reservations_tab
)
IS
l_api_name        CONSTANT VARCHAR2(30) := 'GET_MATERIAL_DISPENSE_DATA';
l_api_version     CONSTANT NUMBER       := 1.0;
BEGIN

  IF NOT fnd_api.Compatible_API_Call ( l_api_version, p_api_version, l_api_name, G_PKG_NAME )
    THEN        RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    END IF;

	IF FND_API.to_Boolean( p_init_msg_list ) THEN
        FND_MSG_PUB.initialize;
    END IF;
       -- check if GMO is enabled
      IF (GMO_SETUP_GRP.IS_GMO_ENABLED = GMO_CONSTANTS_GRP.NO) THEN
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         FND_MESSAGE.SET_NAME('GMO','GMO_DISABLED_ERR');
         FND_MSG_PUB.ADD;
         FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
         if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
             FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_dispense_grp.GET_MATERIAL_DISPENSE_DATA', FALSE);
         end if;
         RETURN ;
      END IF;

    GMO_DISPENSE_PVT.GET_MATERIAL_DISPENSE_DATA( p_material_detail_id,
                                                     x_dispense_data);
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    FND_MSG_PUB.Add;
	FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
 WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.ADD;
        IF  FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )  THEN
                FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
        END IF;
        FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count, p_data => x_msg_data );
END GET_MATERIAL_DISPENSE_DATA;


--This procedure is used to instantiate the dispense setup identified by the specified
--dispense config ID, entity name and entity key.
PROCEDURE INSTANTIATE_DISPENSE_SETUP
(P_API_VERSION        IN  NUMBER,
 P_DISPENSE_CONFIG_ID IN  NUMBER,
 P_ENTITY_NAME        IN  VARCHAR2,
 P_ENTITY_KEY         IN  VARCHAR2,
 P_INIT_MSG_LIST      IN  VARCHAR2,
 P_AUTO_COMMIT        IN  VARCHAR2,
 X_RETURN_STATUS      OUT NOCOPY VARCHAR2,
 X_MSG_COUNT          OUT NOCOPY NUMBER,
 X_MSG_DATA           OUT NOCOPY VARCHAR2)

IS

L_API_NAME    CONSTANT VARCHAR2(40) := 'INSTANTIATE_DISPENSE_SETUP';

L_API_VERSION CONSTANT NUMBER   := 1.0;

BEGIN

  --Validate the API versions.
  IF NOT FND_API.COMPATIBLE_API_CALL(L_API_VERSION,
                                     P_API_VERSION,
                                     L_API_NAME,
                                     G_PKG_NAME)
  THEN

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

  END IF;

  --Initialized the message list if specified so.
  IF FND_API.TO_BOOLEAN(P_INIT_MSG_LIST) THEN

    FND_MSG_PUB.INITIALIZE;

  END IF;


  IF (GMO_SETUP_GRP.IS_GMO_ENABLED = GMO_CONSTANTS_GRP.NO) THEN
      X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
      FND_MESSAGE.SET_NAME('GMO','GMO_DISABLED_ERR');
      FND_MSG_PUB.ADD;
      FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
      if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,'gmo.plsql.gmo_dispense_grp.maintain_reservation', FALSE);
      END IF;

      RETURN;
  END IF;


  --Call a private API to obtain the next value of the document number associated with
  --the specified organization ID and transaction type.
  GMO_DISPENSE_SETUP_PVT.INSTANTIATE_DISPENSE_SETUP
  (P_DISPENSE_CONFIG_ID   => P_DISPENSE_CONFIG_ID,
   P_ENTITY_NAME          => P_ENTITY_NAME,
   P_ENTITY_KEY           => P_ENTITY_KEY,
   P_INIT_MSG_LIST        => P_INIT_MSG_LIST,
   P_AUTO_COMMIT          => P_AUTO_COMMIT,
   X_RETURN_STATUS        => X_RETURN_STATUS,
   X_MSG_COUNT            => X_MSG_COUNT,
   X_MSG_DATA             => X_MSG_DATA);

  --Get the message count.
  --If count is 1, then get the message data.
  FND_MSG_PUB.COUNT_AND_GET
  (P_COUNT => X_MSG_COUNT,
   P_DATA  => X_MSG_DATA);


EXCEPTION

  WHEN OTHERS THEN

    X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR ;

    FND_MESSAGE.SET_NAME('FND','FND_AS_UNEXPECTED_ERROR');
    FND_MESSAGE.SET_TOKEN('ERROR_TEXT',SQLERRM);
    FND_MESSAGE.SET_TOKEN('PKG_NAME','GMO_DISPENSE_GRP');
    FND_MESSAGE.SET_TOKEN('PROCEDURE_NAME','INSTANTIATE_DISPENSE_SETUP');
    IF  FND_MSG_PUB.CHECK_MSG_LEVEL( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)  THEN

      FND_MSG_PUB.ADD_EXC_MSG (G_PKG_NAME,
                               L_API_NAME );

    END IF;

    FND_MSG_PUB.COUNT_AND_GET
    (P_COUNT => X_MSG_COUNT,
     P_DATA  => X_MSG_DATA);

    IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED,
                      'gmo.plsql.GMO_DISPENSE_GRP.INSTANTIATE_DISPENSE_SETUP',
                      FALSE);
    END IF;


END INSTANTIATE_DISPENSE_SETUP;

Function isDispenseOccuredAtDispBooth(disp_booth_id number) return varchar2
as
begin
return GMO_DISPENSE_pvt.isDispenseOccuredAtDispBooth(disp_booth_id);
end;
Function isDispenseOccuredAtDispArea(disp_area_id number) return varchar2
as
begin
return gmo_dispense_pvt.isDispenseOccuredAtDispArea(disp_area_id);
end;



END GMO_DISPENSE_GRP;

/
