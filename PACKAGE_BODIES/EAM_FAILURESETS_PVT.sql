--------------------------------------------------------
--  DDL for Package Body EAM_FAILURESETS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_FAILURESETS_PVT" AS
/* $Header: EAMVFSPB.pls 120.0 2006/03/08 07:16:28 sshahid noship $ */
G_PKG_NAME CONSTANT VARCHAR2(30):='EAM_FailureSets_PVT';

G_LOCKROW_EXCEPTION EXCEPTION;
PRAGMA EXCEPTION_INIT (G_LOCKROW_EXCEPTION,-54);

-- Procedure for raising errors
PROCEDURE Raise_Error (p_error VARCHAR2, p_token VARCHAR2, p_token_value VARCHAR2)
IS
BEGIN
  FND_MESSAGE.SET_NAME ('EAM', p_error);
  IF (p_token IS NOT NULL) THEN
     FND_MESSAGE.SET_TOKEN (p_token, p_token_value);
  END IF;
  FND_MSG_PUB.ADD;
  RAISE FND_API.G_EXC_ERROR;
END Raise_Error;

-- Procedure to Validate FailureSet Info passed in various modes
-- to Setup_FailureSet API
PROCEDURE Validate_FailureSet
          (p_mode             IN VARCHAR2,
           p_validation_level IN NUMBER   := FND_API.G_VALID_LEVEL_FULL   ,
           p_failureset_rec   IN EAM_FailureSets_PUB.eam_failureset_rec_type,
           x_set_id           OUT NOCOPY NUMBER)
IS
l_set_count         NUMBER;
l_old_description   VARCHAR2(240);
l_old_eff_end_date  DATE;
l_old_last_upd_date DATE;
l_set_id            NUMBER;
l_inventory_item_id NUMBER;
l_item              VARCHAR2(240);

BEGIN

     -- Initialize
     l_set_count     := 0;

     IF (p_mode = 'C') THEN

        IF (p_failureset_rec.set_name IS NULL OR
            p_failureset_rec.set_name = FND_API.G_MISS_CHAR) THEN
              Raise_Error ('EAM_FAILURESET_INVALID', 'FAILURE_SET', NULL);
        END IF;

        SELECT count(1)
          INTO l_set_count
          FROM eam_failure_sets
         WHERE set_name = p_failureset_rec.set_name;

        IF (l_set_count > 0) THEN
           Raise_Error ('EAM_FAILURESET_EXISTS', 'FAILURE_SET', p_failureset_rec.set_name);
        END IF;

     ELSIF (p_mode = 'U') THEN
        IF (p_failureset_rec.set_id IS NOT NULL) THEN
            l_set_id := p_failureset_rec.set_id ;
        ELSIF (p_failureset_rec.set_name IS NOT NULL) THEN
           SELECT set_id
             INTO l_set_id
             FROM eam_failure_sets
            WHERE set_name = p_failureset_rec.set_name;
        ELSE
            Raise_Error ('EAM_FAILURESET_INVALID', 'FAILURE_SET', l_set_id || ' - ' || p_failureset_rec.set_name);
        END IF;
        x_set_id := l_set_id;
        SELECT description, effective_end_date, last_update_date
	  INTO l_old_description, l_old_eff_end_date, l_old_last_upd_date
	  FROM eam_failure_sets
         WHERE set_id = l_set_id;

        /*
         IF (l_old_eff_end_date IS NOT NULL AND
             trunc(SYSDATE) > trunc(l_old_eff_end_date)) THEN
            Raise_Error ('EAM_FAILURESET_INACTIVE');
         END IF;
        */

         IF (p_failureset_rec.stored_last_upd_date IS NOT NULL AND
             to_char(p_failureset_rec.stored_last_upd_date,'dd-mon-rrrr hh24:mi:ss') <>
             to_char(l_old_last_upd_date,'dd-mon-rrrr hh24:mi:ss')) THEN
               Raise_Error ('EAM_FAILURESET_CHANGED', 'FAILURE_SET', l_set_id || ' - ' || p_failureset_rec.set_name);
         END IF;


         IF ((p_failureset_rec.effective_end_date IS NOT NULL AND l_old_eff_end_date IS NULL) OR
             (p_failureset_rec.effective_end_date = FND_API.G_MISS_DATE AND l_old_eff_end_date IS NOT NULL) OR
             (p_failureset_rec.effective_end_date IS NOT NULL AND l_old_eff_end_date IS NOT NULL AND
              p_failureset_rec.effective_end_date <> l_old_eff_end_date)) THEN
             BEGIN
                SELECT efsa.inventory_item_id, msik.concatenated_segments
                  INTO l_inventory_item_id, l_item
                  FROM eam_failure_set_associations efsa,
                       mtl_system_items_kfv msik
                 WHERE efsa.set_id = l_set_id
                   AND msik.inventory_item_id = efsa.inventory_item_id
                   AND EXISTS
                       (SELECT 1
                          FROM eam_failure_set_associations efsa1,
                               eam_failure_sets efs
                         WHERE efsa1.inventory_item_id = efsa.inventory_item_id
                           AND efsa1.set_id <> efsa.set_id
                           AND efs.set_id = efsa1.set_id
                           AND (efs.effective_end_date IS NULL OR
                                efs.effective_end_date > NVL(p_failureset_rec.effective_end_date, efs.effective_end_date - 1)))
                   AND rownum < 2;

                 Raise_Error ('EAM_SET_ASSOCIATION_EXISTS', 'ITEM', l_inventory_item_id || ' - ' || l_item);
             EXCEPTION
                   WHEN NO_DATA_FOUND THEN
                        l_item := NULL;
             END;
         END IF;
     ELSE
           Raise_Error ('Invalid Mode - Valid values are ''C'' and ''D''',NULL,NULL);
     END IF;
EXCEPTION
     WHEN NO_DATA_FOUND THEN
          Raise_Error ('EAM_FAILURESET_INVALID', 'FAILURE_SET', l_set_id || ' - ' || p_failureset_rec.set_name);
END Validate_FailureSet;

-- Procedure to Validate SetAssociation Info passed in various modes
-- to Setup_SetAssociation API
PROCEDURE Validate_SetAssociation
          (p_mode             IN  VARCHAR2,
           p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL     ,
           p_association_rec  IN  EAM_FailureSets_PUB.eam_set_association_rec_type,
           x_set_id           OUT NOCOPY NUMBER)
IS

l_set_end_date         DATE;
l_item_exists          NUMBER;
l_association_exists   NUMBER;
l_open_wo_exists       NUMBER;
l_set_id               NUMBER;
l_maintained_group     VARCHAR2(800);

BEGIN
      l_maintained_group := NULL;
      -- Validate Failure Set
      BEGIN
         IF (p_association_rec.set_id IS NOT NULL) THEN
            l_set_id := p_association_rec.set_id ;
         ELSIF (p_association_rec.set_name IS NOT NULL) THEN
            SELECT set_id
              INTO l_set_id
              FROM eam_failure_sets
             WHERE set_name = p_association_rec.set_name;
         END IF;

         SELECT effective_end_date
           INTO l_set_end_date
           FROM eam_failure_sets
          WHERE set_id = l_set_id;

         IF (l_set_end_date IS NOT NULL AND
             trunc(l_set_end_date) < trunc(sysdate)) THEN
            Raise_Error ('EAM_FAILURESET_INACTIVE', 'FAILURE_SET', l_set_id || ' - ' || p_association_rec.set_name);
         END IF;
         x_set_id := l_set_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
              Raise_Error ('EAM_FAILURESET_INVALID', 'FAILURE_SET', l_set_id || ' - ' || p_association_rec.set_name);
      END;

      -- Validate asset group/rebuildable
      SELECT count(1)
        INTO l_item_exists
        FROM mtl_system_items
       WHERE inventory_item_id = p_association_rec.inventory_item_id
         AND eam_item_type IN (1,3)
         AND rownum < 2;

      BEGIN
        SELECT concatenated_segments
	  INTO l_maintained_group
	  FROM mtl_system_items_kfv
	 WHERE inventory_item_id = p_association_rec.inventory_item_id
           AND ROWNUM < 2;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          l_maintained_group := NULL;
      END;

       IF (l_item_exists = 0) THEN
           IF l_maintained_group IS NULL THEN
              Raise_Error ('EAM_INVALID_ITEM', 'ITEM_ID',p_association_rec.inventory_item_id );
           ELSE
              Raise_Error ('EAM_INVALID_ITEM', 'ITEM_ID',l_maintained_group );
           END IF;
       END IF;

       -- check for existing set association
           SELECT count(1)
             INTO l_association_exists
             FROM eam_failure_set_associations
            WHERE set_id = l_set_id
              AND inventory_item_id = p_association_rec.inventory_item_id
              AND effective_end_date IS NULL;

       IF (p_mode = 'C') THEN

           IF (l_association_exists > 0) THEN
              Raise_Error ('EAM_SET_ASSOCIATION_EXISTS','ASSOCIATION',  l_set_id || ' - ' || p_association_rec.set_name
                                                                                 || ' - ' || p_association_rec.inventory_item_id);
           END IF;

           l_association_exists := 0;
           SELECT count(1)
             INTO l_association_exists
             FROM eam_failure_set_associations efsa,
                  eam_failure_sets efs
            WHERE efsa.inventory_item_id = p_association_rec.inventory_item_id
              AND efsa.set_id <> l_set_id
              AND efs.set_id = efsa.set_id
              AND (efs.effective_end_date IS NULL OR
                   efs.effective_end_date >= SYSDATE)
              AND (efsa.effective_end_date IS NULL OR
                    efsa.effective_end_date >= SYSDATE);

           IF (l_association_exists > 0) THEN
              IF l_maintained_group IS NULL THEN
	         Raise_Error ('EAM_ANOTHER_ASSOCIATION_EXISTS', 'ASSOCIATION',p_association_rec.inventory_item_id );
	      ELSE
	         Raise_Error ('EAM_ANOTHER_ASSOCIATION_EXISTS', 'ASSOCIATION',l_maintained_group );
              END IF;
           END IF;

       ELSIF (p_mode IN ('U','D') ) THEN

           IF (l_association_exists = 0) THEN
               Raise_Error ('EAM_SET_ASSOCIATION_INVALID', 'ASSOCIATION',  l_set_id || ' - ' || p_association_rec.set_name
                                                                                    || ' - ' || p_association_rec.inventory_item_id);
           END IF;
           -- Check if the failure set is used in any work order with mandatory flag
	     -- checked and status other than Complete, Complete No charges,
	     -- Cancelled, Closed, Failed close and Pending close else throw
	     -- a message EAM_SET_ASSOCIATION_USED
           -- This exception would not result in an error, rather it would throw a
           -- message.
           l_open_wo_exists := 0;
           IF (p_mode = 'D') THEN
              SELECT count(1)
                INTO l_open_wo_exists
                FROM wip_discrete_jobs wdj,
                     eam_work_order_details ewod
               WHERE (wdj.asset_group_id = p_association_rec.inventory_item_id
                      OR
                      wdj.rebuild_item_id = p_association_rec.inventory_item_id)
                 AND wdj.status_type NOT IN (4,5,7,12,14,15)
                 AND ewod.organization_id = wdj.organization_id
                 AND ewod.wip_entity_id = wdj.wip_entity_id
                 AND ewod.failure_code_required = 'Y'
                 AND rownum < 2;

              IF (l_open_wo_exists = 1) THEN
                  FND_MESSAGE.SET_NAME ('EAM', 'EAM_SET_ASSOCIATION_USED');
                  FND_MSG_PUB.ADD;
              END IF;

           END IF;
       END IF;
END Validate_SetAssociation;

PROCEDURE Setup_FailureSet
       (p_api_version      IN  NUMBER                                     ,
        p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE                ,
        p_commit           IN  VARCHAR2 := FND_API.G_FALSE                ,
        p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL     ,
        p_mode             IN  VARCHAR2                                   ,
        p_failureset_rec   IN  EAM_FailureSets_PUB.eam_failureset_rec_type,
        x_return_status    OUT NOCOPY VARCHAR2                            ,
        x_msg_count        OUT NOCOPY NUMBER                              ,
        x_msg_data         OUT NOCOPY VARCHAR2                            ,
        x_failureset_id    OUT NOCOPY NUMBER
       )
IS
l_api_name      CONSTANT VARCHAR2(30) := 'Setup_FailureSet';
l_api_version   CONSTANT NUMBER       := 1.0;
l_failureset_id NUMBER;

CURSOR lock_set IS
SELECT description, effective_end_date
  FROM eam_failure_sets
 WHERE set_id = l_failureset_id
   FOR UPDATE NOWAIT;

BEGIN
    -- API savepoint
    SAVEPOINT Setup_FailureSet_PVT;

    -- check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
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

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate Failure Set Info passed
    Validate_FailureSet(p_mode, p_validation_level, p_failureset_rec, l_failureset_id);

    IF (p_mode = 'C') THEN
	-- Insert into eam failure sets
	INSERT INTO eam_failure_sets
	              (set_id           ,
                      set_name          ,
                      description       ,
                      effective_end_date,
                      created_by        ,
                      creation_date     ,
                      last_update_date  ,
                      last_updated_by   ,
                      last_update_login)
              VALUES (eam_failuresets_s.nextval          ,
                      p_failureset_rec.set_name          ,
                      p_failureset_rec.description       ,
                      p_failureset_rec.effective_end_date,
                      fnd_global.user_id,
                      SYSDATE,
                      SYSDATE,
                      fnd_global.user_id,
                      NULL)
            RETURNING set_id INTO l_failureset_id ;

    ELSIF (p_mode = 'U') THEN
        -- update eam failure sets
       BEGIN
         OPEN lock_set;
         UPDATE eam_failure_sets
            SET description = decode(p_failureset_rec.description,
                                     NULL, description,
                                     FND_API.G_MISS_CHAR, NULL,
                                     p_failureset_rec.description),
                effective_end_date = decode(p_failureset_rec.effective_end_date,
                                     NULL, effective_end_date,
                                     FND_API.G_MISS_DATE, NULL,
                                     p_failureset_rec.effective_end_date),
                last_update_date = SYSDATE,
                last_updated_by = fnd_global.user_id,
                last_update_login = NULL
          WHERE set_id = l_failureset_id;
          CLOSE lock_set;
       EXCEPTION
          WHEN G_LOCKROW_EXCEPTION THEN
                FND_MESSAGE.SET_NAME ('FND', 'FND_LOCK_RECORD_ERROR');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
       END;
    END IF;

    x_failureset_id := l_failureset_id;
    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
          COMMIT WORK;
    END IF;

    -- call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
    	(p_count  =>  x_msg_count,
         p_data   =>  x_msg_data
    	);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Setup_FailureSet_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(p_count => x_msg_count     	,
                 p_data  => x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Setup_FailureSet_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(p_count => x_msg_count,
                 p_data  => x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO Setup_FailureSet_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF FND_MSG_PUB.Check_Msg_Level
		  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        	   FND_MSG_PUB.Add_Exc_Msg
    	    	     (G_PKG_NAME,
    	    	      l_api_name
	    	      );
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(p_count => x_msg_count,
        	 p_data  => x_msg_data
    		);
END Setup_FailureSet;

PROCEDURE Setup_SetAssociation
       (p_api_version      IN  NUMBER                                         ,
        p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE                    ,
        p_commit           IN  VARCHAR2 := FND_API.G_FALSE                    ,
        p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL         ,
        p_mode             IN  VARCHAR2                                       ,
        p_association_rec  IN  EAM_FailureSets_PUB.eam_set_association_rec_type,
        x_return_status    OUT NOCOPY VARCHAR2                            ,
        x_msg_count        OUT NOCOPY NUMBER                              ,
        x_msg_data         OUT NOCOPY VARCHAR2
       )
IS
l_api_name      CONSTANT VARCHAR2(30) := 'Setup_SetAssociation';
l_api_version   CONSTANT NUMBER       := 1.0;
l_set_id        NUMBER;
l_created_by             NUMBER;
l_creation_date          DATE;
l_last_update_date       DATE;
l_last_updated_by        NUMBER;
l_last_update_login      NUMBER;

CURSOR lock_association(p_set_id NUMBER, p_item_id NUMBER) IS
SELECT failure_code_required, effective_end_date
  FROM eam_failure_set_associations
 WHERE set_id = p_set_id
   AND inventory_item_id = p_item_id
   AND effective_end_date IS NULL
   FOR UPDATE NOWAIT;

BEGIN
    -- API savepoint
    SAVEPOINT Setup_SetAssociation_PVT;

    -- check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (l_api_version,
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

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Validate Failure Set Association Info passed
    Validate_SetAssociation(p_mode, p_validation_level, p_association_rec, l_set_id);

    IF (p_association_rec.last_update_date is null) THEN
          l_created_by             := fnd_global.user_id;
          l_creation_date          := SYSDATE;
          l_last_update_date       := SYSDATE;
          l_last_updated_by        := fnd_global.user_id;
          l_last_update_login      := NULL;
    ELSE
          l_created_by             := p_association_rec.created_by;
          l_creation_date          := p_association_rec.creation_date;
          l_last_update_date       := p_association_rec.last_update_date;
          l_last_updated_by        := p_association_rec.last_updated_by;
          l_last_update_login      := p_association_rec.last_update_login;
    END IF;

    IF (p_mode = 'C') THEN

        UPDATE eam_failure_set_associations
           SET effective_end_date = NULL,
               last_update_date = l_last_update_date,
               last_updated_by = l_last_updated_by,
               last_update_login = l_last_update_login
         WHERE set_id = l_set_id
           AND inventory_item_id = p_association_rec.inventory_item_id;

        IF (SQL%ROWCOUNT = 0) THEN
	-- Insert into eam failure set associations
	INSERT INTO eam_failure_set_associations
                    (set_id               ,
                     inventory_item_id    ,
                     failure_code_required,
	             created_by           ,
	             creation_date        ,
	             last_update_date     ,
	             last_updated_by      ,
	             last_update_login)
	       VALUES (l_set_id            ,
	               p_association_rec.inventory_item_id ,
	               NVL(p_association_rec.failure_code_required,'N'),
                      l_created_by        ,
                      l_creation_date     ,
                      l_last_update_date  ,
                      l_last_updated_by   ,
                      l_last_update_login);
        END IF;
    ELSIF (p_mode IN ('U','D')) THEN
        -- update eam failure set associations
      BEGIN
         OPEN lock_association(l_set_id, p_association_rec.inventory_item_id);
         IF (p_mode = 'U') THEN

            UPDATE eam_failure_set_associations
               SET failure_code_required = decode(
                             p_association_rec.failure_code_required,
                             'Y','Y',
                             NULL, failure_code_required,
                              'N'),
                   last_update_date = l_last_update_date,
                   last_updated_by = l_last_updated_by,
                   last_update_login = l_last_update_login
             WHERE set_id = l_set_id
               AND inventory_item_id = p_association_rec.inventory_item_id
 	       AND effective_end_date IS NULL;

         ELSIF (p_mode = 'D') THEN

            UPDATE eam_failure_set_associations
               SET effective_end_date = SYSDATE,
                   last_update_date = l_last_update_date,
                   last_updated_by = l_last_updated_by,
                   last_update_login = l_last_update_login
             WHERE set_id = l_set_id
               AND inventory_item_id = p_association_rec.inventory_item_id;

          END IF;
          CLOSE lock_association;
       EXCEPTION
          WHEN G_LOCKROW_EXCEPTION THEN
                FND_MESSAGE.SET_NAME ('FND', 'FND_LOCK_RECORD_ERROR');
                FND_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
       END;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
          COMMIT WORK;
    END IF;

    -- call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
    	(p_count  =>  x_msg_count,
         p_data   =>  x_msg_data
    	);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
		ROLLBACK TO Setup_SetAssociation_PVT;
		x_return_status := FND_API.G_RET_STS_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(p_count => x_msg_count     	,
                 p_data  => x_msg_data
    		);
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ROLLBACK TO Setup_SetAssociation_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		FND_MSG_PUB.Count_And_Get
    		(p_count => x_msg_count,
                 p_data  => x_msg_data
    		);
	WHEN OTHERS THEN
		ROLLBACK TO Setup_SetAssociation_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF FND_MSG_PUB.Check_Msg_Level
		  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        	   FND_MSG_PUB.Add_Exc_Msg
    	    	     (G_PKG_NAME,
    	    	      l_api_name
	    	      );
		END IF;
		FND_MSG_PUB.Count_And_Get
    		(p_count => x_msg_count,
        	 p_data  => x_msg_data
    		);
END Setup_SetAssociation;

PROCEDURE Setup_FailureSet_JSP
         (p_mode                 IN  VARCHAR2       ,
          p_set_name             IN  VARCHAR2       ,
          p_description          IN  VARCHAR2       ,
          p_effective_end_date   IN  DATE           ,
          p_set_id               IN  NUMBER         ,
          p_stored_last_upd_date IN  DATE           ,
          x_return_status    OUT NOCOPY VARCHAR2,
          x_msg_count        OUT NOCOPY NUMBER  ,
          x_msg_data         OUT NOCOPY VARCHAR2,
          x_failureset_id    OUT NOCOPY NUMBER
         )
IS
l_failureset_rec EAM_FailureSets_PUB.eam_failureset_rec_type;
BEGIN
        l_failureset_rec.set_name 		:=  p_set_name;
	l_failureset_rec.set_id 		:=  p_set_id;
	l_failureset_rec.stored_last_upd_date   :=  p_stored_last_upd_date;

        IF (p_mode = 'U' AND p_effective_end_date IS NULL) THEN
             l_failureset_rec.effective_end_date := FND_API.G_MISS_DATE;
        ELSE
             l_failureset_rec.effective_end_date     :=  p_effective_end_date;
        END IF;
        IF (p_mode = 'U' AND p_description IS NULL) THEN
             l_failureset_rec.description := FND_API.G_MISS_CHAR;
        ELSE
             l_failureset_rec.description :=  p_description;
        END IF;

	Setup_FailureSet
           (p_api_version     => 1.0,
            p_init_msg_list   => FND_API.G_TRUE,
            p_commit          => FND_API.G_FALSE,
            p_validation_level=> FND_API.G_VALID_LEVEL_FULL,
            p_mode            => p_mode ,
            p_failureset_rec  => l_failureset_rec,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            x_failureset_id  => x_failureset_id
            );

        /* For updating the set_id for the copied rows from a failureset */
        IF (p_mode = 'C')
        THEN
          UPDATE eam_failure_combinations
             SET set_id = x_failureset_id
           WHERE set_id = p_set_id;
        END IF;

END Setup_FailureSet_JSP;

PROCEDURE Setup_SetAssociation_JSP
    (p_mode                  IN VARCHAR2   ,
     p_set_id                IN NUMBER     ,
     p_set_name              IN VARCHAR2   ,
     p_inventory_item_id     IN NUMBER     ,
     p_failure_code_required IN VARCHAR2   ,
     p_effective_end_date    IN DATE       ,
     p_stored_last_upd_date  IN DATE       ,
     p_created_by             IN NUMBER    ,
     p_creation_date          IN DATE      ,
     p_last_update_date       IN DATE      ,
     p_last_updated_by        IN NUMBER    ,
     p_last_update_login      IN NUMBER    ,
     x_return_status    OUT NOCOPY VARCHAR2,
     x_msg_count        OUT NOCOPY NUMBER  ,
     x_msg_data         OUT NOCOPY VARCHAR2
    )
IS
l_association_rec   EAM_FailureSets_PUB.eam_set_association_rec_type;
BEGIN
	l_association_rec.set_id 		  :=  p_set_id;
        l_association_rec.set_name 		  :=  p_set_name;
	l_association_rec.inventory_item_id	  :=  p_inventory_item_id;
	l_association_rec.failure_code_required :=  p_failure_code_required;
	l_association_rec.effective_end_date :=  p_effective_end_date;
	l_association_rec.stored_last_upd_date:=  p_stored_last_upd_date;
	l_association_rec.created_by             := p_created_by;
        l_association_rec.creation_date          := p_creation_date;
        l_association_rec.last_update_date       := p_last_update_date;
        l_association_rec.last_updated_by        := p_last_updated_by;
        l_association_rec.last_update_login      := p_last_update_login;

	Setup_SetAssociation
           (p_api_version     => 1.0,
            p_init_msg_list   => FND_API.G_TRUE,
            p_commit          => FND_API.G_FALSE,
            p_validation_level=> FND_API.G_VALID_LEVEL_FULL,
            p_mode            => p_mode ,
            p_association_rec  => l_association_rec,
            x_return_status   => x_return_status,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data
            );
END Setup_SetAssociation_JSP;

PROCEDURE Lock_SetAssociation_JSP
    (p_set_id		IN	NUMBER,
     p_item_id		IN	NUMBER,
     p_last_update_date	IN	DATE  ,
     x_return_status    OUT NOCOPY VARCHAR2,
     x_msg_count        OUT NOCOPY NUMBER  ,
     x_msg_data         OUT NOCOPY VARCHAR2
     )
IS
CURSOR lock_association(c_set_id NUMBER, c_item_id NUMBER) IS
SELECT failure_code_required, effective_end_date, last_update_date
  FROM eam_failure_set_associations
 WHERE set_id = c_set_id
   AND inventory_item_id = c_item_id
   AND effective_end_date IS NULL
   FOR UPDATE NOWAIT;
l_fcr VARCHAR2(1);
l_end_date DATE;
l_last_update_date DATE;
l_rowcount NUMBER;
BEGIN
	FND_MSG_PUB.initialize;

	--  Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;
	BEGIN
		OPEN lock_association(p_set_id, p_item_id);
			FETCH lock_association
                         INTO l_fcr, l_end_date, l_last_update_date;
                         l_rowcount := lock_association%ROWCOUNT;
		CLOSE lock_association;
                IF (p_last_update_date <> l_last_update_date) THEN
                        FND_MESSAGE.SET_NAME ('FND', 'FND_RECORD_CHANGED_ERROR');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
                IF (l_rowcount = 0) THEN
                        FND_MESSAGE.SET_NAME ('FND', 'FND_RECORD_DELETED_ERROR');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
	EXCEPTION
		WHEN G_LOCKROW_EXCEPTION THEN
			FND_MESSAGE.SET_NAME ('FND', 'FND_LOCK_RECORD_ERROR');
                        FND_MSG_PUB.ADD;
                        RAISE FND_API.G_EXC_ERROR;
	END;
EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                x_return_status := FND_API.G_RET_STS_ERROR ;
        WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		IF FND_MSG_PUB.Check_Msg_Level
		  (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		THEN
        	   FND_MSG_PUB.Add_Exc_Msg
    	    	     (G_PKG_NAME,
                      'Lock_SetAssociation_JSP'
	    	      );
		END IF;
END Lock_SetAssociation_JSP;
END EAM_FailureSets_PVT;

/
