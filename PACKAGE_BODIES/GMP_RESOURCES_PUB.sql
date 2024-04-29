--------------------------------------------------------
--  DDL for Package Body GMP_RESOURCES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMP_RESOURCES_PUB" AS
/* $Header: GMPGRESB.pls 120.0.12010000.3 2010/01/06 10:05:02 vpedarla ship $ */

  /* =============================================================== */
  /* Procedure:                                                      */
  /*   insert_resources                                              */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /* API returns (x_return_code) = 'S' if the insert into resources  */
  /* header  (cr_rsrc_mst ) table is successfully.                   */
  /*                                                                 */
  /* History :                                                       */
  /* Sridhar 03-SEP-2002  Initial implementation                     */
  /* =============================================================== */
  PROCEDURE insert_resources
  ( p_api_version            IN   NUMBER                           :=  1
  , p_init_msg_list          IN   BOOLEAN                          :=  TRUE
  , p_commit                 IN   BOOLEAN                          :=  FALSE
  , p_resources              IN   cr_rsrc_mst%ROWTYPE
  , x_message_count          OUT  NOCOPY NUMBER
  , x_message_list           OUT  NOCOPY VARCHAR2
  , x_return_status          IN OUT  NOCOPY VARCHAR2
  ) IS

  /* Local variable section */
  l_api_name              CONSTANT VARCHAR2(30) := 'INSERT_RESOURCES';
  l_row_id                         ROWID;
  l_return_status                  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;


  /* get a record type */
  l_resources_rec   cr_rsrc_mst%ROWTYPE;

  /* Define Exceptions */
  resource_creation_failure          EXCEPTION;
  RESOURCE_REQUIRED                  EXCEPTION;
  invalid_version                    EXCEPTION;
  X_msg    varchar2(2000) := '';

  BEGIN
    SAVEPOINT create_resources;
    gmd_debug.log_initialize('CreateResourcesPub');

    /* Set the return status to success initially */
    x_return_status  := FND_API.G_RET_STS_SUCCESS;
    l_resources_rec  := p_resources;

    /* Initialize message list and count if needed */
    IF p_init_msg_list THEN
       fnd_msg_pub.initialize;
    END IF;

    /* Make sure we are call compatible */
    IF NOT FND_API.compatible_api_call ( GMP_RESOURCES_PUB.m_api_version
                                        ,p_api_version
                                        ,'INSERT_RESOURCES'
                                        ,GMP_RESOURCES_PUB.m_pkg_name) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE invalid_version;
    END IF;

    v_insert_flag := 'Y';

    IF l_resources_rec.resources IS NOT NULL THEN
       /* Validation 1.  Check if this resources that is created does not exists
         in the database.
       */
       check_data(l_resources_rec.resources,
                  l_resources_rec.resource_desc,
                  l_resources_rec.std_usage_uom,
                  l_resources_rec.resource_class,
                  l_resources_rec.cost_cmpntcls_id,
                  l_resources_rec.min_capacity,
                  l_resources_rec.max_capacity,
                  l_resources_rec.capacity_uom,
                  l_resources_rec.capacity_constraint,
                  l_resources_rec.capacity_tolerance,
                  x_message_count,
                  x_message_list,
                  l_return_status);
       IF l_return_status = 'E' THEN
          RAISE resource_creation_failure;
       ELSE
       /* Insert the Resource Data now */
       /* Making the Capacity Tolerance field NULL if
          Capacity Constraint field has value = 0
       */
         IF l_resources_rec.capacity_constraint = 0
         THEN
            l_resources_rec.capacity_tolerance := NULL;
         END IF;
--
       CR_RSRC_MST_PKG.insert_row
                 (  l_row_id,
                    l_resources_rec.resources,
                    l_resources_rec.resource_class,
                    l_resources_rec.trans_cnt,
                    l_resources_rec.delete_mark,
                    l_resources_rec.text_code,
                    l_resources_rec.min_capacity,
                    l_resources_rec.max_capacity,
                    l_resources_rec.capacity_constraint,
                    l_resources_rec.capacity_uom,
                    l_resources_rec.std_usage_uom,
                    l_resources_rec.cost_cmpntcls_id,
                    l_resources_rec.resource_desc,
                    l_resources_rec.creation_date,
                    l_resources_rec.created_by,
                    l_resources_rec.last_update_date,
                    l_resources_rec.last_updated_by,
                    l_resources_rec.last_update_login,
                    l_resources_rec.capacity_tolerance,
                    l_resources_rec.utilization,
                    l_resources_rec.efficiency
                  );
            v_insert_flag := 'N';
       END IF;
    ELSE
       x_return_status := 'E';
       X_msg := 'Resources';
       RAISE RESOURCE_REQUIRED;
       FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
       FND_MSG_PUB.ADD;
    END IF; /* p_resources.resources IS NOT NULL */

    fnd_msg_pub.count_and_get (
       p_count   => x_message_count
      ,p_encoded => FND_API.g_false
      ,p_data    => x_message_list);

    IF x_message_count = 0 THEN
       gmd_debug.put_line('Resource Header was created successfully');
    END IF;

    gmd_debug.put_line('Completed '||l_api_name ||' at '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
   commit;

  EXCEPTION
    WHEN resource_creation_failure OR invalid_version THEN
         ROLLBACK TO SAVEPOINT create_resources;
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN RESOURCE_REQUIRED THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMP','GMP_VALUE_REQUIRED');
     FND_MESSAGE.SET_TOKEN('VALUE_REQUIRED',X_msg);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count=>x_message_count, p_data=>x_message_list);

    WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT create_resources;
         FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
         FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
         FND_MSG_PUB.ADD;
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         x_return_status := FND_API.g_ret_sts_unexp_error;
  END insert_resources;

  /* =============================================================== */
  /* Procedure:                                                      */
  /*   check_data                                                    */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /* The following Procedure checks the Record and then Inserts      */
  /* the row into cr_rsrc_mst table and Returns S code if inserted   */
  /* Successfully                                                    */
  /*                                                                 */
  /* History :                                                       */
  /* Sgidugu 09/03/2002   Initial implementation                     */
  /* =============================================================== */
   PROCEDURE  check_data(p_resources        IN VARCHAR2,
                        p_resource_desc      IN VARCHAR2,
                        p_std_usage_um       IN VARCHAR2,
                        p_resource_class     IN VARCHAR2,
                        p_cost_cmpntcls_id   IN NUMBER,
                        p_min_capacity       IN NUMBER,
                        p_max_capacity       IN NUMBER,
                        p_capacity_uom       IN   VARCHAR2,
                        p_capacity_constraint  IN   NUMBER,
                        p_capacity_tolerance   IN   NUMBER,
                        x_message_count          OUT  NOCOPY NUMBER,
                        x_message_list           OUT  NOCOPY VARCHAR2,
                        x_return_status      OUT  NOCOPY VARCHAR2) IS
   CURSOR Cur_resources IS
   SELECT COUNT(1)
   FROM   cr_rsrc_mst
   where  resources = p_resources
   and    delete_mark = 0;

   CURSOR Cur_std_usage_um IS
   SELECT COUNT(1)
   FROM   sy_uoms_mst
   WHERE  uom_code = p_std_usage_um
   AND    delete_mark = 0;

   CURSOR Cur_resource_class IS
   SELECT COUNT(1)
   FROM   cr_rsrc_cls
   WHERE  resource_class = p_resource_class
   AND    delete_mark = 0;

   CURSOR Cur_cost_cmpntcls_code IS
   SELECT COUNT(1)
   FROM   cm_cmpt_mst
   WHERE  cost_cmpntcls_id = p_cost_cmpntcls_id
   AND delete_mark     = 0;

   l_return_val varchar2(16);
   l_count1      number := 0;
   l_count2      number := 0;
   l_count3      number := 0;
   l_count4      number := 0;

   INVALID_MIN_MAX  EXCEPTION;
   INVALID_USAGE_UM  EXCEPTION;
   PS_DUP_REC  EXCEPTION;
   INVALID_RSRC_CLASS EXCEPTION;
   INVALID_VALUE EXCEPTION;
   RESOURCE_DESC_REQUIRED  EXCEPTION;
   MIN_MAX_CAPACITY_REQUIRED  EXCEPTION;
   STD_USAGE_UM_REQUIRED  EXCEPTION;  -- Vpedarla Bug: 7015717
   x_temp number;
   X_field  varchar2(2000) := '';
   X_value  varchar2(2000) := '';
   X_msg  varchar2(2000) := '';

   BEGIN
        /* Check Resources if they already exist */

       IF v_insert_flag = 'Y' then
          x_return_status := 'S';
             OPEN Cur_resources;
             FETCH Cur_resources INTO l_count1;
             CLOSE Cur_resources;
             IF l_count1 > 0  then
                x_return_status := 'E';
                RAISE PS_DUP_REC;
             END IF;     /* End if for Duplicate Record */
       END IF;          /* End if for Insert flag = 'Y' */

        /* Check Usage_um  if they already exist */

      -- Vpedarla Bug: 7015717 Added below condition
        IF p_std_usage_um is NULL
        THEN
            x_return_status := 'E';
            X_msg := 'Standard Usage UOM';
            RAISE STD_USAGE_UM_REQUIRED;
        END IF;

        IF p_std_usage_um is NOT NULL then
           x_return_status := 'S';
           OPEN Cur_std_usage_um;
           FETCH Cur_std_usage_um INTO l_count2;
           CLOSE Cur_std_usage_um;
--
           IF l_count2 = 0 then
             x_return_status := 'E';
             RAISE INVALID_USAGE_UM;
           END IF;
        END IF; /* End if for std_usage_um */

        /* Check Resource Class  if they already exist and
           if it is a valid entry */

        IF p_resource_class is NOT NULL then
           x_return_status := 'S';
           OPEN Cur_resource_class;
           FETCH Cur_resource_class INTO l_count3;
           CLOSE Cur_resource_class;
--
           IF l_count3 = 0 then
             x_return_status := 'E';
             RAISE INVALID_RSRC_CLASS;
           END IF;
        END IF; /* End if for resource_class */

        /* Check Cost Component Id  if they already exist
           and if it is a valid entry */

        IF p_cost_cmpntcls_id is NOT NULL then
           x_return_status := 'S';
           OPEN Cur_cost_cmpntcls_code;
           FETCH Cur_cost_cmpntcls_code INTO l_count4;
           CLOSE Cur_cost_cmpntcls_code;
--
           IF l_count4 = 0 then
             x_return_status := 'E';
           END IF;
        END IF; /* End if for cost_cmpntcls_id */
--
        IF p_resource_desc is NULL
        THEN
            x_return_status := 'E';
            X_msg := 'Resource Description';
            RAISE RESOURCE_DESC_REQUIRED;
        END IF;
       /* Check if Min Capacity is greater than Max Capacity */

       x_return_status := 'S';
       IF nvl(p_min_capacity,0) > nvl(p_max_capacity,999999.99) THEN
         x_return_status := 'E';
         RAISE INVALID_MIN_MAX;
       END IF ;
--
       /* Check if Max Capacity is lesser than Min Capacity */
       x_return_status := 'S';
       IF nvl(p_min_capacity,0) > nvl(p_max_capacity,999999.99) THEN
         x_return_status := 'E';
         RAISE INVALID_MIN_MAX;
       END IF ;
--
      IF p_capacity_constraint NOT IN (0,1)
      THEN
             x_return_status := 'E';
             X_field := 'Capacity Constraint';
             X_value := p_capacity_constraint;
             RAISE INVALID_VALUE;
      END IF ;
--
      IF (p_capacity_constraint = 1)
      THEN
         IF (p_min_capacity IS NULL) OR
            (p_max_capacity IS NULL) OR (p_capacity_uom is NULL)
         THEN
             x_return_status := 'E';
             X_msg := 'Min/Max/Capacity Uom';
             RAISE MIN_MAX_CAPACITY_REQUIRED;
         END IF ;
      END IF ;
--
   EXCEPTION
    WHEN INVALID_MIN_MAX THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMP','GMP_MIN_MAX_CAPACITY');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count=>x_message_count, p_data=>x_message_list);
--
    WHEN MIN_MAX_CAPACITY_REQUIRED THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMP','GMP_VALUE_REQUIRED');
     FND_MESSAGE.SET_TOKEN('VALUE_REQUIRED',X_msg);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count=>x_message_count, p_data=>x_message_list);
--
   /* Bug: 7015717 Vpedarla */
    WHEN STD_USAGE_UM_REQUIRED THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMP','GMP_VALUE_REQUIRED');
     FND_MESSAGE.SET_TOKEN('VALUE_REQUIRED',X_msg);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count=>x_message_count, p_data=>x_message_list);
--
    WHEN PS_DUP_REC THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMP','PS_DUP_REC');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count=>x_message_count, p_data=>x_message_list);
--
    WHEN INVALID_VALUE THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMP','GMP_INVALID_VALUE');
     FND_MESSAGE.SET_TOKEN('FIELD',X_field);
     FND_MESSAGE.SET_TOKEN('VALUE',X_value);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count=>x_message_count, p_data=>x_message_list);
--
    WHEN RESOURCE_DESC_REQUIRED THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMP','GMP_VALUE_REQUIRED');
     FND_MESSAGE.SET_TOKEN('VALUE_REQUIRED',X_msg);
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count=>x_message_count, p_data=>x_message_list);
--
    WHEN INVALID_USAGE_UM THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMA','SY_INVALID_UM_CODE');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count=>x_message_count, p_data=>x_message_list);
--
    WHEN INVALID_RSRC_CLASS THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('GMP','CR_INVALID_RSRC_CLASS');
     FND_MSG_PUB.ADD;
     FND_MSG_PUB.Count_And_Get(p_count=>x_message_count, p_data=>x_message_list);

   END check_data; /* End of Procedure check_resources */

  /* =============================================================== */
  /* Procedure:                                                      */
  /*   update_resources                                              */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /* API returns (x_return_code) = 'S' if the update into Generic    */
  /* Resource Table                                                  */
  /*                                                                 */
  /* History :                                                       */
  /* Sgidugu 09/04/2002   Initial implementation                     */
  /* =============================================================== */
  PROCEDURE update_resources
  ( p_api_version            IN   NUMBER                           :=  1
  , p_init_msg_list          IN   BOOLEAN                          :=  TRUE
  , p_commit                 IN   BOOLEAN                          :=  FALSE
  , p_resources              IN   cr_rsrc_mst%ROWTYPE
  , x_message_count          OUT  NOCOPY NUMBER
  , x_message_list           OUT  NOCOPY VARCHAR2
  , x_return_status          OUT  NOCOPY VARCHAR2
  ) IS

  /* Local variable section */
  l_api_name              CONSTANT VARCHAR2(30) := 'INSERT_RESOURCES';
  l_row_id                         ROWID;
  l_return_status                  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

  /* Define Exceptions */
  resource_update_failure          EXCEPTION;
  invalid_version                  EXCEPTION;

  BEGIN
    SAVEPOINT update_resources;
    gmd_debug.log_initialize('UpdateResourcePub');

    /* Set the return status to success initially */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* Initialize message list and count if needed */
    IF p_init_msg_list THEN
       fnd_msg_pub.initialize;
    END IF;

    /* Make sure we are call compatible */
    IF NOT FND_API.compatible_api_call ( GMP_RESOURCES_PUB.m_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,GMP_RESOURCES_PUB.m_pkg_name) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE invalid_version;
    END IF;

    IF p_resources.resources IS NOT NULL THEN
       /* Validation 1.  Check if this resources that is created does not exists
         in the the database.
       */
       check_data(p_resources.resources,
                  p_resources.resource_desc,
                  p_resources.std_usage_uom,
                  p_resources.resource_class,
                  p_resources.cost_cmpntcls_id,
                  p_resources.min_capacity,
                  p_resources.max_capacity,
                  p_resources.capacity_uom,
                  p_resources.capacity_constraint,
                  p_resources.capacity_tolerance,
                  x_message_count,
                  x_message_list,
                  l_return_status);

       IF l_return_status = 'E' THEN
          FND_MESSAGE.SET_NAME('GMA', 'SY_INVALID_DUPLICATION');
          FND_MSG_PUB.ADD;
          RAISE resource_update_failure;
       ELSE
           /* Update the Resource Data now */
           CR_RSRC_MST_PKG.update_row(
                                     p_resources.resources,
                                     p_resources.resource_class,
                                     p_resources.trans_cnt,
                                     p_resources.delete_mark,
                                     p_resources.text_code,
                                     p_resources.min_capacity,
                                     p_resources.max_capacity,
                                     p_resources.capacity_constraint,
                                     p_resources.capacity_uom,
                                     p_resources.std_usage_uom,
                                     p_resources.cost_cmpntcls_id,
                                     p_resources.resource_desc,
                                     p_resources.last_update_date,
                                     p_resources.last_updated_by,
                                     p_resources.last_update_login,
                                     p_resources.capacity_tolerance,
                                     p_resources.utilization,
                                     p_resources.efficiency
                                     );
       END IF;
    END IF;

    /* Check if work was done */
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE resource_update_failure;
    END IF;  /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */

    fnd_msg_pub.count_and_get (
       p_count => x_message_count
      ,p_encoded => FND_API.g_false
      ,p_data => x_message_list);

    IF x_message_count = 0 THEN
       gmd_debug.put_line('Resource was Updated successfullly');
    END IF;

    gmd_debug.put_line('Completed '||l_api_name ||' at '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));

  EXCEPTION
    WHEN resource_update_failure OR invalid_version THEN
         ROLLBACK TO SAVEPOINT update_resources;
         gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'API not complete');
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT update_resources;
         gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'When others exception:'||SQLERRM);
         FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
         FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
         FND_MSG_PUB.ADD;
         fnd_msg_pub.count_and_get (
            p_count   => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_message_list);
         x_return_status := FND_API.g_ret_sts_unexp_error;
  END update_resources;

  /* =============================================================== */
  /* Procedure:                                                      */
  /*   delete_resources                                              */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /* API returns (x_return_code) = 'S' if the delete Resources       */
  /* was Successful                                                  */
  /*                                                                 */
  /* History :                                                       */
  /* Sgidugu 09/04/2002   Initial implementation                     */
  /* =============================================================== */
  PROCEDURE delete_resources
  ( p_api_version 	IN 	NUMBER 			        := 1
  , p_init_msg_list 	IN 	BOOLEAN 			:= TRUE
  , p_commit		IN 	BOOLEAN 			:= FALSE
  , p_resources 	IN	cr_rsrc_mst.resources%TYPE
  , x_message_count 	OUT 	NOCOPY NUMBER
  , x_message_list 	OUT 	NOCOPY VARCHAR2
  , x_return_status	OUT 	NOCOPY VARCHAR2
  ) IS
  CURSOR Cur_resources IS
  SELECT count(1)
  FROM cr_rsrc_mst
  where resources = p_resources;

  l_counter number;

  /* Local variable section */
  l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_RESOURCES';
  l_return_status                  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

  /* Define Exceptions */
  resource_delete_failure           EXCEPTION;
  invalid_version                  EXCEPTION;
  BEGIN
    SAVEPOINT delete_resources;
    gmd_debug.log_initialize('DeleteResourcePub');

    /* Set the return status to success initially */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* Initialize message list and count if needed */
    IF p_init_msg_list THEN
       fnd_msg_pub.initialize;
    END IF;

    /* Make sure we are call compatible */
    IF NOT FND_API.compatible_api_call ( GMP_RESOURCES_PUB.m_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,GMP_RESOURCES_PUB.m_pkg_name) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE invalid_version;
    END IF;

    OPEN Cur_resources;
    FETCH Cur_resources INTO l_counter;
    CLOSE Cur_resources;

    IF (l_counter = 0 ) then
        l_return_status := 'E';
        GMD_DEBUG.PUT_LINE('Resource to be deleted Does Not Exist ');
        FND_MSG_PUB.ADD;
        RAISE resource_delete_failure;
    ELSE
        delete from cr_rsrc_mst_tl
        where resources = p_resources;
--
        delete from cr_rsrc_mst_b
        where resources = p_resources;
        l_return_status := 'S';
    END IF;
--
    fnd_msg_pub.count_and_get (
       p_count   => x_message_count
      ,p_encoded => FND_API.g_false
      ,p_data    => x_message_list);

    IF x_message_count = 0 THEN
       gmd_debug.put_line('Resource was deleted successfully');
    END IF;

    gmd_debug.put_line('Completed '||l_api_name ||' at '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));

  EXCEPTION
    WHEN resource_delete_failure OR invalid_version THEN
         ROLLBACK TO SAVEPOINT delete_resources;
         gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'API not complete');
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT delete_resources;
         gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'When others exception:'||SQLERRM);
         FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
         FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
         FND_MSG_PUB.ADD;
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         x_return_status := FND_API.g_ret_sts_unexp_error;
  END delete_resources;

END GMP_RESOURCES_PUB;

/
