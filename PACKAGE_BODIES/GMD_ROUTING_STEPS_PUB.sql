--------------------------------------------------------
--  DDL for Package Body GMD_ROUTING_STEPS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_ROUTING_STEPS_PUB" AS
/* $Header: GMDPRTSB.pls 120.3 2006/04/20 22:57:19 kmotupal noship $ */


--Bug 3222090, NSRIVAST 20-FEB-2004, BEGIN
--Forward declaration.
   FUNCTION set_debug_flag RETURN VARCHAR2;
   l_debug VARCHAR2(1) := set_debug_flag;

   FUNCTION set_debug_flag RETURN VARCHAR2 IS
   l_debug VARCHAR2(1):= 'N';
   BEGIN
    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_debug := 'Y';
    END IF;
    RETURN l_debug;
   END set_debug_flag;
--Bug 3222090, NSRIVAST 20-FEB-2004, END

  /* =============================================================== */
  /* Procedure:                                                      */
  /*   insert_routing_steps                                          */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /* API returns (x_return_code) = 'S' if the insert into routing    */
  /* details (fm_rout_dtl) table  is successfully.                   */
  /*                                                                 */
  /* History :                                                       */
  /* Shyam   07/29/2002   Initial implementation                     */
  /* KMOTUPAL 21/4/2006   Bug# 3558478 Commented the code for        */
  /*                      validation of Operation                    */
  /* =============================================================== */
  PROCEDURE insert_routing_steps
  (
    p_api_version            IN   NUMBER	                 :=  1
  , p_init_msg_list          IN   BOOLEAN	                 :=  TRUE
  , p_commit		     IN   BOOLEAN	                 :=  FALSE
  , p_routing_id             IN   gmd_routings.routing_id%TYPE   :=  NULL
  , p_routing_no             IN   gmd_routings.routing_no%TYPE   :=  NULL
  , p_routing_vers           IN   gmd_routings.routing_vers%TYPE :=  NULL
  , p_routing_step_rec       IN   fm_rout_dtl%ROWTYPE
  , p_routings_step_dep_tbl  IN   GMD_ROUTINGS_PUB.gmd_routings_step_dep_tab
  , x_message_count          OUT NOCOPY  NUMBER
  , x_message_list           OUT NOCOPY  VARCHAR2
  , x_return_status          OUT NOCOPY  VARCHAR2
  ) IS

    /* Local variable section */
    l_api_name              CONSTANT VARCHAR2(30)  := 'INSERT_ROUTING_STEPS';
    l_row_id                         ROWID;
    k                                NUMBER        := 1;

    l_return_status                  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_return_from_routing_step_dep   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_routing_id                     gmd_routings.routing_id%TYPE;
    l_routingStep_id                 fm_rout_dtl.routingStep_id%TYPE;
    l_enforce_flag                   GMD_ROUTINGS.enforce_step_dependency%TYPE;
    l_steprelease_type               fm_rout_dtl.steprelease_type%TYPE;
    l_oprn_no                        gmd_operations.oprn_no%TYPE;
    l_oprn_vers                      gmd_operations.oprn_vers%TYPE;
    l_rout_eff_start_date            DATE;
    l_rout_eff_end_date              DATE;

    /* define record type */
    l_routing_step_rec               fm_rout_dtl%ROWTYPE;

    /* define table type */
    l_step_dep_tab                   GMD_ROUTINGS_PUB.gmd_routings_step_dep_tab;

    /* Cursor section */
    CURSOR get_enforce_flag(vRouting_id NUMBER) IS
      Select enforce_step_dependency
      From   gmd_routings_b
      Where  routing_id = vRouting_id;

    /* gets the operation no and version associated to the routing detail/Step */
    Cursor Get_oprn_details(vOprn_id fm_rout_dtl.oprn_id%TYPE)  IS
       Select oprn_no, oprn_vers
       From   gmd_operations_b
       Where  oprn_id = vOprn_id;

    /* get routing start date */
    Cursor get_rout_start_date(vRouting_id NUMBER) IS
      Select effective_start_date, effective_end_date
      From   gmd_routings_b
      Where  routing_id = vRouting_id;

    /* Exception section */
    routing_creation_failure           EXCEPTION;
    routing_step_creation_failure      EXCEPTION;
    routing_step_dep_failure           EXCEPTION;
    invalid_version                    EXCEPTION;
    setup_failure                      EXCEPTION;

  BEGIN
    SAVEPOINT create_routing_steps;

    /* Set the return status to success initially */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* Initialize message list and count if needed */
    IF p_init_msg_list THEN
       fnd_msg_pub.initialize;
    END IF;

    /* Intialize the setup fields */
    IF NOT gmd_api_grp.setup_done THEN
      gmd_api_grp.setup_done := gmd_api_grp.setup;
    END IF;
    IF NOT gmd_api_grp.setup_done THEN
      RAISE setup_failure;
    END IF;

    /* Make sure we are call compatible */
    IF NOT FND_API.compatible_api_call ( gmd_routings_PUB.m_api_version
                                        ,p_api_version
                                        ,'INSERT_ROUTING_STEPS'
                                        ,gmd_routing_steps_PUB.m_pkg_name) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE invalid_version;
    END IF;

    /* Validations done prior to creation of routing steps */
    /* Validation : Check if routing header exists in the database */
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'
            ||'Begin of validations ');
    END IF;

    IF p_routing_id IS NOT NULL THEN
       l_routing_id := p_routing_id;
       GMDRTVAL_PUB.check_routing(pRouting_no    => p_routing_no
                                 ,pRouting_vers  => p_routing_vers
                                 ,xRouting_id    => l_routing_id
                                 ,xReturn_status => l_return_status);
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          /* it indicates that this routing does'ntexists */
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTING_INVALID');
          FND_MSG_PUB.ADD;
          RAISE routing_step_creation_failure;
       END IF;
    ELSE /* usually in this case user must have passed routing_no and version */
       GMDRTVAL_PUB.check_routing(pRouting_no    => p_routing_no
                                 ,pRouting_vers  => p_routing_vers
                                 ,xRouting_id    => l_routing_id
                                 ,xReturn_status => l_return_status);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          /* it indicates that this routing does'ntexists */
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTING_INVALID');
          FND_MSG_PUB.ADD;
          RAISE routing_step_creation_failure;
       END IF;
    END IF;

    /* Check the routing id is not null */
    IF l_routing_id IS NULL THEN
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Routing id is required');
      END IF;
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'ROUTING_ID');
      FND_MSG_PUB.ADD;
      RAISE routing_step_creation_failure;
    END IF;

    /* Routing Security Validation */
    /* Validation:  Check if for given user this routing can be modified */
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'
            ||'Validation of user - owner orgn code = '||gmd_api_grp.user_id);
    END IF;


    IF NOT GMD_API_GRP.Check_orgn_access(Entity     => 'ROUTING'
                                    ,Entity_id  => l_routing_id) THEN
       RAISE routing_step_creation_failure;
    END IF;

    /* Check the routing step number is not null */
    IF p_routing_step_rec.routingstep_no IS NULL THEN
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Routing step number is required');
      END IF;
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'ROUTINGSTEP_NO');
      FND_MSG_PUB.ADD;
      RAISE routing_step_creation_failure;
    END IF;

    /* Check the oprn id is not null */
    IF p_routing_step_rec.oprn_id IS NULL THEN
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'||
         'Operation id is required');
      END IF;
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'OPRN_ID');
      FND_MSG_PUB.ADD;
      RAISE routing_step_creation_failure;
    END IF;

    IF x_return_status <> FND_API.g_ret_sts_success THEN
      RAISE routing_step_creation_failure;
    END IF;

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'||
                          'Validation : Checking for routingStep existence ');
    END IF;
    /* Validation : check if this routing step exists in our system */
    /* If this step exists indicate a duplication not allowed message */
    IF p_routing_step_rec.routingstep_no IS NOT NULL THEN
       IF GMDRTVAL_PUB.check_routingstep_no(proutingstep_no => p_routing_step_rec.routingstep_no
                                           ,prouting_id     => p_routing_id)  <> 0   THEN
          FND_MESSAGE.SET_NAME('GMD', 'FM_RTSTEPERR');
          FND_MSG_PUB.ADD;
          RAISE routing_step_creation_failure;
       END IF;
    END IF;

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'||
                  'Validation : Enforce flag check for routing id =  '||l_routing_id);
    END IF;

    /* Validation : Enforcing step dependency
       If this flag at Routing header level is set to Yes,
       then fm_rout_dtl.steprelease type is set to manual = 1.*/
    IF l_routing_id IS NOT NULL THEN
       OPEN  get_enforce_flag(l_routing_id);
       FETCH get_enforce_flag INTO l_enforce_flag;
         IF get_enforce_flag%NOTFOUND THEN
            l_enforce_flag := 0;
         END IF;
         IF l_enforce_flag = 1 THEN
            l_stepRelease_type := 1;
         ELSE
            l_stepRelease_type := p_routing_step_rec.steprelease_type;
         END IF;
       CLOSE get_enforce_flag;
    END IF;

    /* Validation : Routing status is not On Hold nor Obsolete/Archived
      and Routing is not logically deleted */
    IF NOT GMD_COMMON_VAL.UPDATE_ALLOWED(Entity => 'ROUTING',
                                         Entity_id => l_routing_id ) THEN
       FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUT_NOT_VALID');
       FND_MSG_PUB.ADD;
       RAISE routing_step_creation_failure;
    END IF;
  -- Bug# 3558478 KMOTUPAL
  -- Commented the code for validation of Operation
    /* Validation : Operation status is not On Hold nor Obsolete/Archived
       and Operation is not logically deleted */
   /* IF NOT GMD_COMMON_VAL.UPDATE_ALLOWED(Entity => 'OPERATION',
                                         Entity_id => p_routing_step_rec.oprn_id ) THEN
       FND_MESSAGE.SET_NAME('GMD', 'GMD_OPRN_NOT_VALID');
       FND_MSG_PUB.ADD;
       RAISE routing_step_creation_failure;
    END IF; */

    /* Validation : Operation effective dates fall within the routing effective date range  */
    OPEN get_rout_start_date(l_Routing_id);
    FETCH get_rout_start_date INTO l_rout_eff_start_date, l_rout_eff_end_date;
       IF get_rout_start_date%NOTFOUND THEN
         /* Routing has not been created correctly */
         CLOSE get_rout_start_date;
         FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUT_DATES_INVALID');
         FND_MSG_PUB.ADD;
         RAISE routing_step_creation_failure;
       END IF;
    CLOSE get_rout_start_date;

    OPEN  Get_oprn_details(p_routing_step_rec.oprn_id);
    FETCH Get_oprn_details INTO l_oprn_no, l_oprn_vers;
      IF Get_oprn_details%NOTFOUND THEN
         FND_MESSAGE.SET_NAME('GMD', 'GMD_MISSING_OPRN');
         FND_MSG_PUB.ADD;
         CLOSE Get_oprn_details;
         RAISE routing_step_creation_failure;
      END IF;
    CLOSE Get_oprn_details;
    IF GMDRTVAL_PUB.check_oprn(poprn_no =>l_oprn_no
                              ,poprn_vers => l_oprn_vers
                              ,prouting_start_date => l_rout_eff_start_date
                              ,prouting_end_date => l_rout_eff_end_date
                              ) <> 0 THEN
       RAISE routing_step_creation_failure;
    END IF;

    /* Since values cannot be assigned to p_routing_step_rec
       we create a another rec type to assign the derived values */
    l_routing_step_rec                  := p_routing_step_rec;
    l_routing_step_rec.stepRelease_type := NVL(l_stepRelease_type,1);
    l_routing_step_rec.step_qty         := NVL(p_routing_step_rec.step_qty,0);

    /* Step : Create Routing steps  */
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'||
                      'Insert the routing steps for routing with routing id = '||l_routing_id);
    END IF;

    GMD_ROUTING_STEPS_PVT.insert_routing_steps
    (p_routing_id        =>   l_routing_id
    ,p_routing_step_rec  =>   l_routing_step_rec
    ,x_return_status     =>   x_return_status
    );

    IF x_return_status <> FND_API.g_ret_sts_success THEN
      RAISE routing_step_creation_failure;
    END IF;

    -- Check if routing detail was created
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'
                  ||'After calling the pvt insert step API the return status: '||x_return_status);
    END IF;

    /* After creating routing steps pass the routing id       */
    /* and the routing step no to the function that generates */
    /* the step dependencies                                  */

    /* Create Routing Step dependencies */
    IF p_routings_step_dep_tbl.count > 0 THEN
       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'||
          'Creating Routing Step dependencies ');
       END IF;

       -- Call the routing step dep function
       -- For each routingStep_no, routing_id enter all the dependent
       -- routing step nos
       -- Construct a PL/SQL table that is specific only to this
       -- routing step no and routing id.
       FOR j IN 1 .. p_routings_step_dep_tbl.count  LOOP
         IF (p_routing_step_rec.ROUTINGSTEP_NO = p_routings_step_dep_tbl(j).ROUTINGSTEP_NO) AND
            (P_ROUTING_ID     = l_ROUTING_ID)     THEN
             l_step_dep_tab(k).routingstep_no     := p_routings_step_dep_tbl(j).routingstep_no     ;
             l_step_dep_tab(k).dep_routingstep_no := p_routings_step_dep_tbl(j).dep_routingstep_no ;
             l_step_dep_tab(k).routing_id         := l_routing_id                                  ;
             l_step_dep_tab(k).dep_type           := p_routings_step_dep_tbl(j).dep_type           ;
             l_step_dep_tab(k).rework_code        := p_routings_step_dep_tbl(j).rework_code        ;
             l_step_dep_tab(k).standard_delay     := p_routings_step_dep_tbl(j).standard_delay     ;
             l_step_dep_tab(k).minimum_delay      := p_routings_step_dep_tbl(j).minimum_delay      ;
             l_step_dep_tab(k).max_delay          := p_routings_step_dep_tbl(j).max_delay          ;
             l_step_dep_tab(k).transfer_qty       := p_routings_step_dep_tbl(j).transfer_qty       ;
             l_step_dep_tab(k).routingstep_no_uom
                                                  := p_routings_step_dep_tbl(j).routingstep_no_uom ;
             l_step_dep_tab(k).text_code          := p_routings_step_dep_tbl(j).text_code          ;
             l_step_dep_tab(k).last_updated_by    := p_routings_step_dep_tbl(j).last_updated_by    ;
             l_step_dep_tab(k).created_by         := p_routings_step_dep_tbl(j).created_by         ;
             l_step_dep_tab(k).last_update_date   := p_routings_step_dep_tbl(j).last_update_date   ;
             l_step_dep_tab(k).creation_date      := p_routings_step_dep_tbl(j).creation_date      ;
             l_step_dep_tab(k).last_update_login  := p_routings_step_dep_tbl(j).last_update_login  ;
             l_step_dep_tab(k).transfer_pct       := p_routings_step_dep_tbl(j).transfer_pct       ;

             k := k + 1;
         END IF;
       END LOOP;

       /* Since we call this procedure for each routingStep we dont have to reinitialize K
          value after populating dependency PLSQL table. Call the step dependency function */
       IF l_step_dep_tab.count > 0 THEN
          GMD_ROUTING_STEPS_PUB.insert_step_dependencies
          (
           p_routing_id             => l_routing_id
          ,p_routingstep_no         => p_routing_step_rec.routingstep_no
          ,p_routings_step_dep_tbl  => l_step_dep_tab
          ,p_commit	            => FALSE
          ,x_message_count          => x_message_count
          ,x_message_list           => x_message_list
          ,x_return_status          => l_return_from_routing_step_dep
          );

          /* Check if insert of step dependency was done */
          IF l_return_from_routing_step_dep <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE routing_step_dep_failure;
          END IF;  /* IF l_return_from_routing_step_dep <> FND_API.G_RET_STS_SUCCESS */
        END IF; /* when l_step_dep_tab.count > 0 */
    END IF; /* if p_routings_step_dep_tbl.count > 0 */

    /* Check if work was done */
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE routing_step_creation_failure;
    END IF;  /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */

    fnd_msg_pub.count_and_get (
       p_count   => x_message_count
      ,p_encoded => FND_API.g_false
      ,p_data    => x_message_list);

    IF x_message_count = 0 THEN
       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'||
          'Routing details/steps was created successfullly');
       END IF;
    END IF;

    IF (P_commit) THEN
      COMMIT;
    END IF;

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Completed '||l_api_name ||' at '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
    END IF;

  EXCEPTION
    WHEN routing_step_creation_failure OR invalid_version THEN
         ROLLBACK TO SAVEPOINT create_routing_steps;
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'API not complete '||SQLERRM);
         END IF;
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN setup_failure THEN
         ROLLBACK TO SAVEPOINT create_routing_steps;
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get (
            p_count   => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_message_list);
    WHEN routing_step_dep_failure THEN
         ROLLBACK TO SAVEPOINT create_routing_steps;
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'failure due to insert step dep'||SQLERRM);
         END IF;
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT create_routing_steps;
         fnd_msg_pub.add_exc_msg (gmd_routing_steps_PUB.m_pkg_name, l_api_name);
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'When others exception:'||SQLERRM);
         END IF;
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         x_return_status := FND_API.g_ret_sts_unexp_error;
  END insert_routing_steps;

  /* =============================================================== */
  /* Procedure:                                                      */
  /*   insert_step_dependencies                                      */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /* API returns (x_return_code) = 'S' if the insert into step       */
  /* dependency table is successfully.                               */
  /*                                                                 */
  /* History :                                                       */
  /* Shyam   07/29/2002   Initial implemenation                      */
  /* =============================================================== */
  PROCEDURE insert_step_dependencies
  (
    p_api_version            IN   NUMBER                            :=  1
  , p_init_msg_list          IN   BOOLEAN                           :=  TRUE
  , p_commit		     IN   BOOLEAN                           :=  FALSE
  , p_routing_id             IN   gmd_routings.routing_id%TYPE      :=  NULL
  , p_routing_no             IN   gmd_routings.routing_no%TYPE      :=  NULL
  , p_routing_vers           IN   gmd_routings.routing_vers%TYPE    :=  NULL
  , p_routingstep_id         IN   fm_rout_dtl.routingstep_id%TYPE   :=  NULL
  , p_routingstep_no         IN   fm_rout_dtl.routingstep_no%TYPE   :=  NULL
  , p_routings_step_dep_tbl  IN   GMD_ROUTINGS_PUB.gmd_routings_step_dep_tab
  , x_message_count          OUT NOCOPY  NUMBER
  , x_message_list           OUT NOCOPY  VARCHAR2
  , x_return_status          OUT NOCOPY  VARCHAR2
  ) IS

  /* Local variable section */
  l_api_name              CONSTANT VARCHAR2(30)  := 'INSERT_STEP_DEPENDENCIES';
  l_routing_id                     gmd_routings.routing_id%TYPE;
  l_return_status                  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

  /* Exception section */
  routing_step_dep_failure           EXCEPTION;
  invalid_version                    EXCEPTION;
  setup_failure                      EXCEPTION;

  BEGIN
    SAVEPOINT create_step_dependencies;

    /* Set the return status to success initially */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* Initialize message list and count if needed */
    IF p_init_msg_list THEN
       fnd_msg_pub.initialize;
    END IF;

    /* Intialize the setup fields */
    IF NOT gmd_api_grp.setup_done THEN
      gmd_api_grp.setup_done := gmd_api_grp.setup;
    END IF;
    IF NOT gmd_api_grp.setup_done THEN
      RAISE setup_failure;
    END IF;

    /* Make sure we are call compatible */
    IF NOT FND_API.compatible_api_call ( gmd_routings_PUB.m_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,gmd_routing_steps_PUB.m_pkg_name) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE invalid_version;
    END IF;

    /* Routingstp number must be passed, otherwise give error */
    IF p_routingstep_no IS NULL THEN
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('routing step number required');
      END IF;
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'ROUTINGSTEP_NO');
      FND_MSG_PUB.ADD;
      RAISE routing_step_dep_failure;
    END IF;

    /* Routingstp number must be passed, otherwise give error */
    IF p_routings_step_dep_tbl(1).dep_routingstep_no IS NULL THEN
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('dep routing step number required');
      END IF;
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'DEP_ROUTINGSTEP_NO');
      FND_MSG_PUB.ADD;
      RAISE routing_step_dep_failure;
    END IF;

    /* routingstep_no_uom must be passed, otherwise give error */
    IF p_routings_step_dep_tbl(1).routingstep_no_uom IS NULL THEN
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Item uom required');
      END IF;
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'ROUTINGSTEP_NO_UOM');
      FND_MSG_PUB.ADD;
      RAISE routing_step_dep_failure;
      /* call common function to check if um passed is valid */
    ELSIF (NOT(gmd_api_grp.validate_um(p_routings_step_dep_tbl(1).routingstep_no_uom))) THEN
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Item uom invalid');
      END IF;
      FND_MESSAGE.SET_NAME('GMA', 'SY_INVALID_UM_CODE');
      FND_MSG_PUB.ADD;
      RAISE routing_step_dep_failure;
    END IF;

    /* transfer pct value should be in between 0 and 100 */
    IF p_routings_step_dep_tbl(1).transfer_pct < 0 OR p_routings_step_dep_tbl(1).transfer_pct > 100 THEN
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Transfer percent should be positive value');
      END IF;
      FND_MESSAGE.SET_NAME ('GMD', 'FM_INVALID');
      FND_MSG_PUB.ADD;
      RAISE routing_step_dep_failure;
    END IF;

    /* dep_type value should be either 0 or 1 */
    IF p_routings_step_dep_tbl(1).dep_type NOT IN (0,1) THEN
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Invalid value for dep_type field');
      END IF;
      FND_MESSAGE.SET_NAME ('GMD', 'GMD_DEP_TYPE_INVALID');
      FND_MSG_PUB.ADD;
      RAISE routing_step_dep_failure;
    END IF;

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line(' Validation : Check if the routing id exists in the db ');
    END IF;
    /* Validation  : Check if routing header exists in the database */
    IF p_routing_id IS NOT NULL THEN
       l_routing_id := p_routing_id;
       GMDRTVAL_PUB.check_routing(pRouting_no    => p_routing_no
                                 ,pRouting_vers  => p_routing_vers
                                 ,xRouting_id    => l_routing_id
                                 ,xReturn_status => l_return_status);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          /* it indicates that this routing does'ntexists */
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTING_INVALID');
          FND_MSG_PUB.ADD;
          RAISE routing_step_dep_failure;
       END IF;
    ELSE /* usually in this case use must have passed routing_no and version */
       GMDRTVAL_PUB.check_routing(pRouting_no    => p_routing_no
                                 ,pRouting_vers  => p_routing_vers
                                 ,xRouting_id    => l_routing_id
                                 ,xReturn_status => l_return_status);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          /* it indicates that this routing does'ntexists */
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTING_INVALID');
          FND_MSG_PUB.ADD;
          RAISE routing_step_dep_failure;
       END IF;
    END IF;

    /* Check the routing id is not null */
    IF l_routing_id IS NULL THEN
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Routing id is required');
      END IF;
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'ROUTING_ID');
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.g_ret_sts_error;
    END IF;

    /* Routing Security Validation */
    /* Validation:  Check if for given user this routing can be modified */
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'
            ||'Validation of user - owner orgn code = '||gmd_api_grp.user_id);
    END IF;
    IF NOT GMD_API_GRP.Check_orgn_access(Entity     => 'ROUTING'
                                        ,Entity_id  => l_routing_id) THEN
       RAISE routing_step_dep_failure;
    END IF;

   /* Validation : Routing status is not On Hold nor Obsolete/Archived
      and Routing is not logically deleted */
    IF NOT GMD_COMMON_VAL.UPDATE_ALLOWED(Entity => 'ROUTING',
                                         Entity_id => l_routing_id ) THEN
       FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUT_NOT_VALID');
       FND_MSG_PUB.ADD;
       RAISE routing_step_dep_failure;
    END IF;

    /* Validation : Check if this step dep exist */
    /* The primary key is combination of RoutingStep_no, dep_RoutingStep_no
       and Routing_id */
    /* Validation  : Check if routing header exists in the database */

    FOR i IN 1 .. p_routings_step_dep_tbl.count LOOP
       GMDRTVAL_PUB.check_deprouting(pRouting_id          => l_routing_id
                                    ,pRoutingstep_no      => p_routingstep_no
                                    ,pdeproutingstep_no   => p_routings_step_dep_tbl(i).dep_routingstep_no
                                    ,x_Return_status      => l_return_status);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          /* it indicates that this routing does'ntexists */
          FND_MESSAGE.SET_NAME('GME', 'PC_RECORD_EXISTS');
          FND_MSG_PUB.ADD;
          RAISE routing_step_dep_failure;
       END IF;
    END LOOP; /* End loop for p_routings_step_dep_tbl.count  */

    /* Insert made into the step dependency table */
        GMD_ROUTING_STEPS_PVT.insert_step_dependencies
        ( p_routing_id             =>   l_routing_id
        , p_routingstep_no         =>   p_routingstep_no
        , p_routings_step_dep_tbl  =>   p_routings_step_dep_tbl
        , x_return_status          =>   x_return_status
        );

        -- Check if routing step dependencies were created
        IF (l_debug = 'Y') THEN
           gmd_debug.put_line('After inserting routing step dependencies');
        END IF;

    /* Check if work was done */
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE routing_step_dep_failure;
    END IF;  /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */

    fnd_msg_pub.count_and_get (
       p_count => x_message_count
      ,p_encoded => FND_API.g_false
      ,p_data => x_message_list);

    IF x_message_count = 0 THEN
       IF (l_debug = 'Y') THEN
          gmd_debug.put_line('Routing step dependencies were created successfullly');
       END IF;
    END IF;

    IF (P_commit) THEN
      COMMIT;
    END IF;

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Completed '||l_api_name ||' at '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
    END IF;

  EXCEPTION
    WHEN routing_step_dep_failure OR invalid_version THEN
         ROLLBACK TO SAVEPOINT create_step_dependencies;
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'API not complete');
         END IF;
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN setup_failure THEN
    	 ROLLBACK TO SAVEPOINT create_step_dependencies;
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get (
            p_count   => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_message_list);
    WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT create_step_dependencies;
         fnd_msg_pub.add_exc_msg (gmd_routing_steps_PUB.m_pkg_name, l_api_name);
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'When others exception:'||SQLERRM);
         END IF;
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         x_return_status := FND_API.g_ret_sts_unexp_error;
  END insert_step_dependencies;

  /* =============================================================== */
  /* Procedure:                                                      */
  /*   update_routing_steps                                          */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /* API returns (x_return_code) = 'S' if the update into routing    */
  /* details   (fm_rout_dtl table) is success.                       */
  /*                                                                 */
  /* History :                                                       */
  /* Shyam   07/29/2002   Initial implementation                     */
  /* =============================================================== */
  PROCEDURE update_routing_steps
  ( p_api_version       IN 	NUMBER 			        :=  1
  , p_init_msg_list 	IN 	BOOLEAN 			:=  TRUE
  , p_commit		IN 	BOOLEAN 			:=  FALSE
  , p_routingstep_id	IN	fm_rout_dtl.routingstep_id%TYPE :=  NULL
  , p_routingstep_no	IN	fm_rout_dtl.routingstep_no%TYPE :=  NULL
  , p_routing_id 	IN	gmd_routings.routing_id%TYPE 	:=  NULL
  , p_routing_no	IN	gmd_routings.routing_no%TYPE    :=  NULL
  , p_routing_vers 	IN	gmd_routings.routing_vers%TYPE  :=  NULL
  , p_update_table	IN	GMD_ROUTINGS_PUB.update_tbl_type
  , x_message_count 	OUT NOCOPY 	NUMBER
  , x_message_list 	OUT NOCOPY 	VARCHAR2
  , x_return_status	OUT NOCOPY 	VARCHAR2
  ) IS

  /* Local variable section */
  l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_ROUTING_STEPS';
  l_routing_id                     gmd_routings.routing_id%TYPE;
  l_routingstep_id                 fm_rout_dtl.routingStep_id%TYPE;
  l_routingstep_no                 fm_rout_dtl.routingStep_no%TYPE;
  l_return_status                  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_oprn_id                        gmd_operations.oprn_id%TYPE;

  /* Define record type that hold the routing data */
  l_old_routingStep_rec            fm_rout_dtl%ROWTYPE;

  /* Cursor defn section */
  CURSOR get_oprn_id(vRoutingStep_id  fm_rout_dtl.routingstep_id%TYPE)  IS
    Select oprn_id
    From   fm_rout_dtl
    Where  routingStep_id = vRoutingStep_id;

  Cursor get_routing_owner_orgn_code(vRouting_id Number) IS
    Select owner_orgn_code
    From   gmd_routings_b
    Where  routing_id = vRouting_id;

  /* Define Exceptions */
  routing_update_step_failure      EXCEPTION;
  invalid_version                  EXCEPTION;
  setup_failure                    EXCEPTION;
  -- KSHUKLA updated the api as per as 4376301
  -- Declaration of the variables to be used.
l_opr_start_date  DATE ;
l_opr_end_date    DATE;
l_rout_start_date DATE;
l_rout_end_date   DATE;
VALID_DATE_EXCEPTION EXCEPTION;

  BEGIN
    SAVEPOINT update_routing_details;

    /* Set the return status to success initially */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* Initialize message list and count if needed */
    IF p_init_msg_list THEN
       fnd_msg_pub.initialize;
    END IF;

    /* Intialize the setup fields */
    IF NOT gmd_api_grp.setup_done THEN
      gmd_api_grp.setup_done := gmd_api_grp.setup;
    END IF;
    IF NOT gmd_api_grp.setup_done THEN
      RAISE setup_failure;
    END IF;

    /* Make sure we are call compatible */
    IF NOT FND_API.compatible_api_call ( gmd_routings_PUB.m_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,gmd_routing_steps_PUB.m_pkg_name) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE invalid_version;
    END IF;

    /* Validation prior to Routings Steps update */

    /* Validation : Check if the routing id exists in the db */
    /* Validation  : Check if routing header exists in the database */
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Validation : check if the routing id is valid ');
    END IF;
    IF p_routing_id IS NOT NULL THEN
       l_routing_id := p_routing_id;
       GMDRTVAL_PUB.check_routing(pRouting_no    => p_routing_no
                                 ,pRouting_vers  => p_routing_vers
                                 ,xRouting_id    => l_routing_id
                                 ,xReturn_status => l_return_status);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          /* it indicates that this routing does'ntexists */
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTING_INVALID');
          FND_MSG_PUB.ADD;
          RAISE routing_update_step_failure;
       END IF;
    ELSE /* usually in this case user must have passed routing_no and version */
       GMDRTVAL_PUB.check_routing(pRouting_no    => p_routing_no
                                 ,pRouting_vers  => p_routing_vers
                                 ,xRouting_id    => l_routing_id
                                 ,xReturn_status => l_return_status);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          /* it indicates that this routing does'ntexists */
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTING_INVALID');
          FND_MSG_PUB.ADD;
          RAISE routing_update_step_failure;
       END IF;
    END IF;

    /* Check the routing id is not null */
    IF l_routing_id IS NULL THEN
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Routing id is required');
      END IF;
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'ROUTING_ID');
      FND_MSG_PUB.ADD;
      RAISE routing_update_step_failure;
    END IF;

    /* Routing Security fix */
    /* Validation:  Check if for given user this routing can be modified */
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'
            ||'Validation of user - owner orgn code = '||gmd_api_grp.user_id);
    END IF;
    IF NOT GMD_API_GRP.Check_orgn_access(Entity     => 'ROUTING'
                                    ,Entity_id  => l_routing_id) THEN
       RAISE routing_update_step_failure;
    END IF;

    /* get the RoutingStep_id - if it is not passed as a parameter */
     IF (l_debug = 'Y') THEN
        gmd_debug.put_line('Validation : get the routingstep_id with routing id = '
        ||l_routing_id ||'RoutingStepNo = '||p_routingStep_no);
     END IF;

    IF p_routingStep_id IS NOT NULL THEN
       l_routingstep_id := p_routingstep_id;
       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(' get the RoutingStep_no- for rtstepid = '||l_routingStep_id);
       END IF;
       GMDRTVAL_PUB.get_routingstep_info(pxRoutingStep_no  => l_routingstep_no
                                        ,pxRoutingStep_id  => l_routingstep_id
                                        ,x_return_status   => l_return_status );
       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(' After get_rouingstep_info is called ret status = '||l_return_status);
       END IF;
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          /* it indicates that this routing does'ntexists */
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTINGSTEP_INVALID');
          FND_MSG_PUB.ADD;
          RAISE routing_update_step_failure;
       END IF;
    ELSE
       /* hopefully the Routing step no was passed in .. */
       l_routingstep_no := p_routingstep_no;
       GMDRTVAL_PUB.get_routingstep_info(pRouting_id       => l_routing_id
                                        ,pxRoutingStep_no  => l_routingstep_no
                                        ,pxRoutingStep_id  => l_routingstep_id
                                        ,x_return_status   => l_return_status );
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          -- it indicates that this routing does not exists
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTINGSTEP_INVALID');
          FND_MSG_PUB.ADD;
          RAISE routing_update_step_failure;
       END IF;
    END IF;

    /* Check the routing id is not null */
    IF l_routingstep_id IS NULL THEN
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Routing step id is required');
      END IF;
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'ROUTINGSTEP_ID');
      FND_MSG_PUB.ADD;
      RAISE routing_update_step_failure;
    END IF;

   /* Validation : Routing status is not On Hold nor Obsolete/Archived
      and Routing is not logically deleted */
    IF NOT GMD_COMMON_VAL.UPDATE_ALLOWED(Entity => 'ROUTING',
                                         Entity_id => l_routing_id ) THEN
       FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUT_NOT_VALID');
       FND_MSG_PUB.ADD;
       RAISE routing_update_step_failure;
    END IF;

    /* Validation : Operation status is not On Hold nor Obsolete/Archived
       and Operation is not logically deleted */
    OPEN  get_oprn_id(l_routingStep_id);
    FETCH get_oprn_id INTO l_oprn_id;
       IF get_oprn_id%NOTFOUND THEN
       	  RAISE routing_update_step_failure;
       	  CLOSE get_oprn_id;
       END IF;
    CLOSE get_oprn_id;
    IF NOT GMD_COMMON_VAL.UPDATE_ALLOWED(Entity => 'OPERATION',
                                         Entity_id => l_oprn_id ) THEN
       FND_MESSAGE.SET_NAME('GMD', 'GMD_OPRN_NOT_VALID');
       FND_MSG_PUB.ADD;
       RAISE routing_update_step_failure;
    END IF;

    /*  KSHUKLA added the following validation as per as 4376301
     This validation takes care of in case of an upgrade of an operation
     for a recipe the operation whouls be valid through out the course of
     Recipe. */

    /* Check for the routing date and operation date validity
    */
     FOR a in 1..p_update_table.COUNT LOOP
       if UPPER(p_update_table(a).p_col_to_update) = 'OPRN_ID' THEN

          select effective_start_date,effective_end_date
          into l_rout_start_date,l_rout_end_date
          from fm_rout_hdr
          where routing_id =l_routing_id;

          IF GMDRTVAL_PUB.check_oprn(poprn_id =>p_update_table(a).p_value
                                    ,prouting_start_date => l_rout_start_date
                                    ,prouting_end_date => l_rout_end_date
                                    ) <> 0 THEN
             RAISE VALID_DATE_EXCEPTION;
          END IF;
       END IF;
    END LOOP;

    -- End of KSHUKLA VAlidation for 4376301
    /* Validation: Operation status level should be higher or equal
       the routing level status. For instance, if the routing status
       is "Approved for Laboratory Use", operations with a status cannot be "New"
       are not allowed.  Therefore when the routing status is updated check
       all the associated operation status */

    /* Call the private API that does the actual update */
    GMD_ROUTING_STEPS_PVT.update_routing_steps
    ( p_routingstep_id	=>    l_routingstep_id
    , p_update_table	=>    p_update_table
    , x_return_status   =>    x_return_status
    );

    /* Check if work was done */
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE routing_update_step_failure;
    END IF;  /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */

    fnd_msg_pub.count_and_get (
       p_count => x_message_count
      ,p_encoded => FND_API.g_false
      ,p_data => x_message_list);

    IF x_message_count = 0 THEN
       IF (l_debug = 'Y') THEN
          gmd_debug.put_line('Routing step was updated successfullly');
       END IF;
    END IF;

    IF (P_commit) THEN
      COMMIT;
    END IF;

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Completed '||l_api_name ||' at '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
    END IF;
  EXCEPTION
    WHEN routing_update_step_failure OR invalid_version THEN
         ROLLBACK TO SAVEPOINT update_routing_details;
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'API not complete');
         END IF;
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN setup_failure THEN
    	 ROLLBACK TO SAVEPOINT update_routing_details;
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get (
            p_count   => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_message_list);
    WHEN VALID_DATE_EXCEPTION THEN
       ROLLBACK TO SAVEPOINT update_routing_details;
       x_return_status := FND_API.G_RET_STS_ERROR;
       fnd_msg_pub.count_and_get (
            p_count   => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_message_list);
    WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT update_routing_details;
         fnd_msg_pub.add_exc_msg (gmd_routing_steps_PUB.m_pkg_name, l_api_name);
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'When others exception:'||SQLERRM);
         END IF;
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         x_return_status := FND_API.g_ret_sts_unexp_error;
  END update_routing_steps;

  /* =============================================================== */
  /* Procedure:                                                      */
  /*   update_step_dependencies                                      */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /* API returns (x_return_code) = 'S' if the update into routing    */
  /* step dependency (fm_rout_dep table) is success.                 */
  /*                                                                 */
  /* History :                                                       */
  /* Shyam   07/29/2002   Initial implementation                     */
  /* =============================================================== */
  PROCEDURE update_step_dependencies
  ( p_api_version 	 IN 	NUMBER 			        :=  1
  , p_init_msg_list 	 IN 	BOOLEAN 			:=  TRUE
  , p_commit		 IN 	BOOLEAN 			:=  FALSE
  , p_routingstep_no	 IN	fm_rout_dep.routingstep_no%TYPE :=  NULL
  , p_routingstep_id     IN     fm_rout_dtl.routingstep_id%TYPE :=  NULL
  , p_dep_routingstep_no IN	fm_rout_dep.routingstep_no%TYPE
  , p_routing_id 	 IN	fm_rout_dep.routing_id%TYPE 	:=  NULL
  , p_routing_no	 IN	gmd_routings.routing_no%TYPE    :=  NULL
  , p_routing_vers 	 IN	gmd_routings.routing_vers%TYPE  :=  NULL
  , p_update_table	 IN	GMD_ROUTINGS_PUB.update_tbl_type
  , x_message_count 	 OUT NOCOPY 	NUMBER
  , x_message_list 	 OUT NOCOPY 	VARCHAR2
  , x_return_status	 OUT NOCOPY 	VARCHAR2
  ) IS

  /* Local variable section */
  l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_STEP_DEPENDENCIES';
  l_return_status                  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

  l_routingstep_no                 fm_rout_dtl.routingStep_no%TYPE;
  l_routingstep_id                 fm_rout_dtl.routingStep_id%TYPE;
  l_routing_id                     fm_rout_dep.routing_id%TYPE;
  l_transfer_pct                   NUMBER;
  l_dep_type                       NUMBER;
  l_std_delay                      NUMBER;

  /* Define record type that hold the routing data */
  l_old_stepDep_rec               fm_rout_dep%ROWTYPE;

  /* Define Exceptions */
  routing_update_dep_failure       EXCEPTION;
  invalid_version                  EXCEPTION;
  setup_failure                    EXCEPTION;

  BEGIN
    SAVEPOINT update_step_dependency;

    /* Set the return status to success initially */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* Initialize message list and count if needed */
    IF p_init_msg_list THEN
       fnd_msg_pub.initialize;
    END IF;

    /* Intialize the setup fields */
    IF NOT gmd_api_grp.setup_done THEN
      gmd_api_grp.setup_done := gmd_api_grp.setup;
    END IF;
    IF NOT gmd_api_grp.setup_done THEN
      RAISE setup_failure;
    END IF;

    /* Make sure we are call compatible */
    IF NOT FND_API.compatible_api_call ( gmd_routings_PUB.m_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,gmd_routing_steps_PUB.m_pkg_name) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE invalid_version;
    END IF;

    /* Validation prior to Routings Step dependency update */
    /* Validation : Impact with ASQC ON and change to transfer % */
    /* To be determined */


    FOR a IN 1 .. p_update_table.count  LOOP
       /* Validation :  Check if transfer percent value is valid */
       IF UPPER(p_update_table(a).p_col_to_update) = 'TRANSFER_PCT' THEN
         l_transfer_pct :=  p_update_table(a).p_value;
       /* Validation :  Check if dependency type value is valid */
       ELSIF UPPER(p_update_table(a).p_col_to_update) = 'DEP_TYPE' THEN
         l_dep_type :=  p_update_table(a).p_value;
       ELSIF UPPER(p_update_table(a).p_col_to_update) = 'STANDARD_DELAY' THEN
         l_std_delay :=  p_update_table(a).p_value;
       END IF;  /* UPPER(p_update_table(i).p_col_to_update) = 'TRANSFER_PCT' */
    END LOOP;

    /* transfer pct value should be in between 0 and 100 */
    IF l_transfer_pct < 0 OR l_transfer_pct > 100 THEN
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line ('Transfer pct value should be positive');
      END IF;
      FND_MESSAGE.SET_NAME ('GMD', 'FM_INVALID');
      FND_MSG_PUB.ADD;
      RAISE routing_update_dep_failure;
    END IF;

    /* standard delay value should be in = or > 0 */
    IF l_std_delay < 0  THEN
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line ('Transfer pct value should be positive');
      END IF;
      FND_MESSAGE.SET_NAME ('GMD', 'FM_INVALID');
      FND_MSG_PUB.ADD;
      RAISE routing_update_dep_failure;
    END IF;

    /* dep_type value should be either 0 or 1 */
    IF l_dep_type NOT IN (0,1) THEN
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Invalid value for dep_type field');
      END IF;
      FND_MESSAGE.SET_NAME ('GMD', 'GMD_DEP_TYPE_INVALID');
      FND_MSG_PUB.ADD;
      RAISE routing_update_dep_failure;
    END IF;

    /* Validation : Check if routing header exists in the database */
    IF p_routing_id IS NOT NULL THEN
       l_routing_id := p_routing_id;
       GMDRTVAL_PUB.check_routing(pRouting_no    => p_routing_no
                                 ,pRouting_vers  => p_routing_vers
                                 ,xRouting_id    => l_routing_id
                                 ,xReturn_status => l_return_status);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          /* it indicates that this routing does'ntexists */
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTING_INVALID');
          FND_MSG_PUB.ADD;
          RAISE routing_update_dep_failure;
       END IF;
    ELSE /* usually in this case user must have passed routing_no and version */
       GMDRTVAL_PUB.check_routing(pRouting_no    => p_routing_no
                                 ,pRouting_vers  => p_routing_vers
                                 ,xRouting_id    => l_routing_id
                                 ,xReturn_status => l_return_status);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          /* it indicates that this routing does'ntexists */
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTING_INVALID');
          FND_MSG_PUB.ADD;
          RAISE routing_update_dep_failure;
       END IF;
    END IF;

    /* Check the routing id is not null */
    IF l_routing_id IS NULL THEN
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Routing id is required');
      END IF;
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'ROUTING_ID');
      FND_MSG_PUB.ADD;
      RAISE routing_update_dep_failure;
    END IF;

    /* Routing Security fix */
    /* Validation:  Check if for given user this routing can be modified */
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'
            ||'Validation of user - owner orgn code = '||gmd_api_grp.user_id);
    END IF;
    IF NOT GMD_API_GRP.Check_orgn_access(Entity     => 'ROUTING'
                                    ,Entity_id  => l_routing_id) THEN
       RAISE routing_update_dep_failure;
    END IF;

    /* get the RoutingStep_no - if it is not passed as a parameter */
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Validation : get the routingstep_no with routing step id = '
       ||p_routingstep_id);
    END IF;
    IF p_routingStep_no IS NOT NULL THEN
       l_routingstep_no := p_routingstep_no;
       GMDRTVAL_PUB.get_routingstep_info(pRouting_id       => l_routing_id
       					,pxRoutingStep_no  => l_routingstep_no
                                        ,pxRoutingStep_id  => l_routingstep_id
                                        ,x_return_status   => l_return_status );
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          /* it indicates that this routing does'ntexists */
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTINGSTEP_INVALID');
          FND_MSG_PUB.ADD;
          RAISE routing_update_dep_failure;
       END IF;
    ELSE
       /* hopefully the Routing step id was passed in .. */
       l_routingstep_id := p_routingstep_id;
       GMDRTVAL_PUB.get_routingstep_info(pxRoutingStep_no  => l_routingstep_no
                                        ,pxRoutingStep_id  => l_routingstep_id
                                        ,x_return_status   => l_return_status );
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          /* it indicates that this routing does'ntexists */
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTINGSTEP_INVALID');
          FND_MSG_PUB.ADD;
          RAISE routing_update_dep_failure;
       END IF;
    END IF;

    /* Check the routing step no is not null */
    IF l_routingstep_no IS NULL THEN
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Routing id is required');
      END IF;
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'ROUTINGSTEP_NO');
      FND_MSG_PUB.ADD;
      RAISE routing_update_dep_failure;
    END IF;

    IF x_return_status <> FND_API.g_ret_sts_success THEN
      RAISE routing_update_dep_failure;
    END IF;

   /* Validation : Routing status is not On Hold nor Obsolete/Archived
      and Routing is not logically deleted */
    IF NOT GMD_COMMON_VAL.UPDATE_ALLOWED(Entity => 'ROUTING',
                                         Entity_id => l_routing_id ) THEN
       FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUT_NOT_VALID');
       FND_MSG_PUB.ADD;
       RAISE routing_update_dep_failure;
    END IF;

    GMD_ROUTING_STEPS_PVT.update_step_dependencies
    ( p_routingstep_no	    =>  l_routingstep_no
    , p_dep_routingstep_no  =>  p_dep_routingstep_no
    , p_routing_id 	    =>  l_routing_id
    , p_update_table	    =>  p_update_table
    , x_return_status       =>  x_return_status
    );
     /* Check if work was done */
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE routing_update_dep_failure;
     END IF;  /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */

     fnd_msg_pub.count_and_get (
       p_count   => x_message_count
      ,p_encoded => FND_API.g_false
      ,p_data    => x_message_list);

     IF x_message_count = 0 THEN
       IF (l_debug = 'Y') THEN
          gmd_debug.put_line('Routing was updated successfullly');
       END IF;
     END IF;

    IF (P_commit) THEN
      COMMIT;
    END IF;

     IF (l_debug = 'Y') THEN
        gmd_debug.put_line('Completed '||l_api_name ||' at '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
     END IF;

  EXCEPTION
    WHEN routing_update_dep_failure OR invalid_version THEN
         ROLLBACK TO SAVEPOINT update_step_dependency;
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'API not complete');
         END IF;
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN setup_failure THEN
    	 ROLLBACK TO SAVEPOINT update_step_dependency;
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get (
            p_count   => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_message_list);
    WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT update_routing_details;
         fnd_msg_pub.add_exc_msg (gmd_routing_steps_PUB.m_pkg_name, l_api_name);
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'When others exception:'||SQLERRM);
         END IF;
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         x_return_status := FND_API.g_ret_sts_unexp_error;

  END update_step_dependencies;

  /* =============================================================== */
  /* Procedure:                                                      */
  /*   Delete_Routing_step                                           */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /* API returns (x_return_code) = 'S' if the delete into routing    */
  /* step dependency (fm_rout_dep table) is success.                 */
  /*                                                                 */
  /* History :                                                       */
  /* Shyam   07/29/2002   Initial implementation                     */
  /* =============================================================== */
  PROCEDURE delete_routing_step
  ( p_api_version 	IN 	NUMBER 			        :=  1
  , p_init_msg_list 	IN 	BOOLEAN 			:=  TRUE
  , p_commit		IN 	BOOLEAN 			:=  FALSE
  , p_routingstep_id	IN	fm_rout_dtl.routingstep_id%TYPE :=  NULL
  , p_routingstep_no	IN	fm_rout_dtl.routingstep_no%TYPE :=  NULL
  , p_routing_id	IN	fm_rout_dtl.routing_id%TYPE	:=  NULL
  , p_routing_no	IN	gmd_routings.routing_no%TYPE    :=  NULL
  , p_routing_vers 	IN	gmd_routings.routing_vers%TYPE  :=  NULL
  , x_message_count 	OUT NOCOPY 	NUMBER
  , x_message_list 	OUT NOCOPY 	VARCHAR2
  , x_return_status	OUT NOCOPY 	VARCHAR2
  )  IS

    /* Local variable section */
    l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_ROUTING_STEP';
    l_return_status                  VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
    l_return_from_routing_step_dep   VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
    l_routingstep_no                 fm_rout_dep.routingStep_no%TYPE;
    l_routingStep_id                 fm_rout_dtl.routingStep_id%TYPE;
    l_routing_id                     gmd_routings.routing_id%TYPE;
    l_dep_routingstep_no             fm_rout_dep.dep_routingStep_no%TYPE;

    /* Define Cursors */
    /* Cursor that check if there any row in the step dependency table that
       needs to be deleted */
    Cursor Check_Step_dep_rec(vRoutingstep_no fm_rout_dep.routingStep_no%TYPE
                             ,vRouting_id     gmd_routings.Routing_id%TYPE)  IS
       Select dep_routingstep_no
       From   fm_rout_dep
       Where  routingStep_no = vRoutingStep_no
       And    routing_id     = vrouting_id;

    /* Define Exceptions */
    routing_delete_step_failure         EXCEPTION;
    routing_delete_stepdep_failure      EXCEPTION;
    invalid_version                     EXCEPTION;
    setup_failure                       EXCEPTION;

  BEGIN
    SAVEPOINT delete_routing_step;

    /* Set the return status to success initially */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* Initialize message list and count if needed */
    IF p_init_msg_list THEN
       fnd_msg_pub.initialize;
    END IF;

    /* Intialize the setup fields */
    IF NOT gmd_api_grp.setup_done THEN
      gmd_api_grp.setup_done := gmd_api_grp.setup;
    END IF;
    IF NOT gmd_api_grp.setup_done THEN
      RAISE setup_failure;
    END IF;

    /* Make sure we are call compatible */
    IF NOT FND_API.compatible_api_call ( gmd_routings_PUB.m_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,gmd_routing_steps_PUB.m_pkg_name) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE invalid_version;
    END IF;

    /* Get routing id if it is not passed in as a parameter */
    /* Routing id may be used to get the routingStep_id (PK for fm_rout_dtl) */
    /* Get the routing_id  value */
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Validation : Check if routing header exists in the database ');
    END IF;
    IF p_routing_id IS NOT NULL THEN
       l_routing_id := p_routing_id;
       GMDRTVAL_PUB.check_routing(pRouting_no    => p_routing_no
                                 ,pRouting_vers  => p_routing_vers
                                 ,xRouting_id    => l_routing_id
                                 ,xReturn_status => l_return_status);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          /* it indicates that this routing does'ntexists */
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTING_INVALID');
          FND_MSG_PUB.ADD;
          RAISE routing_delete_step_failure;
       END IF;
    ELSE /* usually in this case user must have passed routing_no and version */
       GMDRTVAL_PUB.check_routing(pRouting_no    => p_routing_no
                                 ,pRouting_vers  => p_routing_vers
                                 ,xRouting_id    => l_routing_id
                                 ,xReturn_status => l_return_status);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          /* it indicates that this routing does'ntexists */
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTING_INVALID');
          FND_MSG_PUB.ADD;
          RAISE routing_delete_step_failure;
       END IF;
    END IF;

    /* Check the routing id is not null */
    IF l_routing_id IS NULL THEN
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Routing id is required');
      END IF;
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'ROUTING_ID');
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.g_ret_sts_error;
    END IF;

    /* Routing Security Validation */
    /* Validation:  Check if for given user this routing can be modified */
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'
            ||'Validation of user - owner orgn code = '||gmd_api_grp.user_id);
    END IF;
    IF NOT GMD_API_GRP.Check_orgn_access(Entity     => 'ROUTING'
                                    ,Entity_id  => l_routing_id) THEN
       RAISE routing_delete_step_failure;
    END IF;


    /* Get the RoutingStep_id and routingstep_no (routingstep_no is used
       for the routing step dep delete   */

    IF p_routingStep_id IS NOT NULL THEN
       l_routingstep_id := p_routingstep_id;
       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(' get the RoutingStep_no- for rtstepid = '||l_routingStep_id);
       END IF;
       GMDRTVAL_PUB.get_routingstep_info(pxRoutingStep_no  => l_routingstep_no
                                        ,pxRoutingStep_id  => l_routingstep_id
                                        ,x_return_status   => l_return_status );
       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(' After get_rouingstep_info is called ret status = '||l_return_status);
       END IF;
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          /* it indicates that this routing does'ntexists */
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTINGSTEP_INVALID');
          FND_MSG_PUB.ADD;
          RAISE routing_delete_step_failure;
       END IF;
    ELSE
       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(' get the RoutingStep_id - if it is not passed as a parameter ');
       END IF;
       l_routingstep_no := p_routingstep_no;
       GMDRTVAL_PUB.get_routingstep_info(pRouting_id       => l_routing_id
                                        ,pxRoutingStep_no  => l_routingstep_no
                                        ,pxRoutingStep_id  => l_routingstep_id
                                        ,x_return_status   => l_return_status );
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          /* it indicates that this routing does'ntexists */
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTINGSTEP_INVALID');
          FND_MSG_PUB.ADD;
          RAISE routing_delete_step_failure;
       END IF;
    END IF;

    /* Check the routing id is not null */
    IF l_routingstep_id IS NULL THEN
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Routing step id is required');
      END IF;
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'ROUTINGSTEP_ID');
      FND_MSG_PUB.ADD;
      RAISE routing_delete_step_failure;
    END IF;

    /* Validation : Check if this step is used in recipe override table and
       step material association table.  If it is then delete is not allowed */
    IF GMDRTVAL_PUB.Check_routing_override_exists(l_routingstep_id) THEN
       FND_MESSAGE.SET_NAME('GMD', 'GMD_STEP_USED_IN_RECIPE');
       FND_MSG_PUB.ADD;
       RAISE routing_delete_step_failure;
    END IF;

   /* Validation : Routing status is not On Hold nor Obsolete/Archived
      and Routing is not logically deleted */
    IF NOT GMD_COMMON_VAL.UPDATE_ALLOWED(Entity => 'ROUTING',
                                         Entity_id => l_routing_id ) THEN
       FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUT_NOT_VALID');
       FND_MSG_PUB.ADD;
       RAISE routing_delete_step_failure;
    END IF;

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('RoutingStep_id = '||l_routingStep_id );
    END IF;
    /* Actual delete is performed */
    GMD_ROUTING_STEPS_PVT.delete_routing_step
    ( p_routingstep_id	=> l_routingstep_id
    , p_routing_id	=> l_routing_id
    , x_return_status   => x_return_status
    );

    fnd_msg_pub.count_and_get (
       p_count   => x_message_count
      ,p_encoded => FND_API.g_false
      ,p_data    => x_message_list);

    IF x_message_count = 0 THEN
       IF (l_debug = 'Y') THEN
          gmd_debug.put_line('Routing step was deleted successfullly');
       END IF;
    END IF;

    IF (P_commit) THEN
      COMMIT;
    END IF;

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Completed '||l_api_name ||' at '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
    END IF;

  EXCEPTION
    WHEN routing_delete_step_failure OR invalid_version THEN
         ROLLBACK TO SAVEPOINT delete_routing_step;
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'API not complete');
         END IF;
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN setup_failure THEN
    	 ROLLBACK TO SAVEPOINT delete_routing_step;
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get (
            p_count   => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_message_list);
    WHEN routing_delete_stepdep_failure THEN
         ROLLBACK TO SAVEPOINT delete_routing_step;
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'delete step dep API not complete');
         END IF;
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT delete_routing_step;
         fnd_msg_pub.add_exc_msg (gmd_routing_steps_PUB.m_pkg_name, l_api_name);
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'When others exception:'||SQLERRM);
         END IF;
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         x_return_status := FND_API.g_ret_sts_unexp_error;

  END delete_routing_step;

  /* =============================================================== */
  /* Procedure:                                                      */
  /*   delete_step_dependencies                                      */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /* API returns (x_return_code) = 'S' if the delete in  routing     */
  /* step dependency (fm_rout_dep table) is success.                 */
  /*                                                                 */
  /* History :                                                       */
  /* Shyam   07/29/2002   Initial implementation                     */
  /* =============================================================== */
  PROCEDURE delete_step_dependencies
  ( p_api_version 	 IN 	NUMBER 			        :=  1
  , p_init_msg_list 	 IN 	BOOLEAN 			:=  TRUE
  , p_commit		 IN 	BOOLEAN 			:=  FALSE
  , p_routingstep_no	 IN	fm_rout_dep.routingstep_no%TYPE
  , p_dep_routingstep_no IN	fm_rout_dep.routingstep_no%TYPE :=  NULL
  , p_routing_id 	 IN	fm_rout_dep.routing_id%TYPE 	:=  NULL
  , p_routing_no	 IN	gmd_routings.routing_no%TYPE    :=  NULL
  , p_routing_vers 	 IN	gmd_routings.routing_vers%TYPE  :=  NULL
  , x_message_count 	 OUT NOCOPY 	NUMBER
  , x_message_list 	 OUT NOCOPY 	VARCHAR2
  , x_return_status	 OUT NOCOPY 	VARCHAR2
  ) IS

  /* Local variable section */
  l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_STEP_DEPENDENCIES';
  l_return_status                  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

  l_routingstep_no                 fm_rout_dep.routingStep_no%TYPE;
  l_routingStep_id                 fm_rout_dtl.routingStep_id%TYPE;
  l_dep_routingstep_no             fm_rout_dep.dep_routingStep_no%TYPE;
  l_routing_id                     fm_rout_dep.routing_id%TYPE;

  /* Define Exceptions */
  routing_delete_dep_failure       EXCEPTION;
  invalid_version                  EXCEPTION;
  setup_failure                    EXCEPTION;

  BEGIN
    SAVEPOINT delete_step_dependency;

    /* Set the return status to success initially */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* Initialize message list and count if needed */
    IF p_init_msg_list THEN
       fnd_msg_pub.initialize;
    END IF;

    /* Intialize the setup fields */
    IF NOT gmd_api_grp.setup_done THEN
      gmd_api_grp.setup_done := gmd_api_grp.setup;
    END IF;
    IF NOT gmd_api_grp.setup_done THEN
      RAISE setup_failure;
    END IF;

    /* Make sure we are call compatible */
    IF NOT FND_API.compatible_api_call ( gmd_routings_PUB.m_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,gmd_routing_steps_PUB.m_pkg_name) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE invalid_version;
    END IF;

    /* Validation prior to Routings Step dependency delete */

    /* Validation 1: Check if this step is being used in other tables */
    /* Tables to be checked are mainly gmd step material association
       and maybe batch table. Prevent delete if these steps are used in these tables */
    /* Get the routing_id  value */
    IF (l_debug = 'Y') THEN
       gmd_Debug.put_line('Validation: In dep step API if routing header exists in the database ');
    END IF;
    IF p_routing_id IS NOT NULL THEN
       l_routing_id := p_routing_id;
       GMDRTVAL_PUB.check_routing(pRouting_no    => p_routing_no
                                 ,pRouting_vers  => p_routing_vers
                                 ,xRouting_id    => l_routing_id
                                 ,xReturn_status => l_return_status);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          /* it indicates that this routing does'ntexists */
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTING_INVALID');
          FND_MSG_PUB.ADD;
          RAISE routing_delete_dep_failure;
       END IF;
    ELSE /* usually in this case user must have passed routing_no and version */
       GMDRTVAL_PUB.check_routing(pRouting_no    => p_routing_no
                                 ,pRouting_vers  => p_routing_vers
                                 ,xRouting_id    => l_routing_id
                                 ,xReturn_status => l_return_status);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          /* it indicates that this routing does'ntexists */
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTING_INVALID');
          FND_MSG_PUB.ADD;
          RAISE routing_delete_dep_failure;
       END IF;
    END IF;

    /* Check the routing id is not null */
    IF l_routing_id IS NULL THEN
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Routing id is required');
      END IF;
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'ROUTING_ID');
      FND_MSG_PUB.ADD;
      RAISE routing_delete_dep_failure;
    END IF;

    /* Routing Security Validation */
    /* Validation:  Check if for given user this routing can be modified */
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'
            ||'Validation of user - owner orgn code = '||gmd_api_grp.user_id);
    END IF;
    IF NOT GMD_API_GRP.Check_orgn_access(Entity     => 'ROUTING'
                                    ,Entity_id  => l_routing_id) THEN
       RAISE routing_delete_dep_failure;
    END IF;

    IF p_routingStep_no IS NOT NULL THEN
       l_routingstep_no := p_routingstep_no;
       GMDRTVAL_PUB.get_routingstep_info(pRouting_id       => l_routing_id
       					,pxRoutingStep_no  => l_routingstep_no
                                        ,pxRoutingStep_id  => l_routingstep_id
                                        ,x_return_status   => l_return_status );
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          /* it indicates that this routing does'ntexists */
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTINGSTEP_INVALID');
          FND_MSG_PUB.ADD;
          RAISE routing_delete_dep_failure;
       END IF;
     END IF;

    /* Check the routingstep no is not null */
    IF p_routingstep_no IS NULL THEN
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Routing step number is required');
      END IF;
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'ROUTINGSTEP_NO');
      FND_MSG_PUB.ADD;
      RAISE routing_delete_dep_failure;
    END IF;

    /* Check the routingstep no is not null */
    IF p_dep_routingstep_no IS NULL THEN
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line('Dep Routing step number is required');
      END IF;
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'DEP_ROUTINGSTEP_NO');
      FND_MSG_PUB.ADD;
      RAISE routing_delete_dep_failure;
    END IF;

    /* Actual delete in  fm_rout_dep table */
    /* This delete can be specific to a dep_routingstep_no or a
       Routingstep_no */
    IF (l_debug = 'Y') THEN
       gmd_Debug.put_line('About to delete from step dep table - the routingstep no = '
       ||p_routingstep_no ||' and routing id = '||l_routing_id);
    END IF;


   /* Validation : Routing status is not On Hold nor Obsolete/Archived
      and Routing is not logically deleted */
    IF NOT GMD_COMMON_VAL.UPDATE_ALLOWED(Entity => 'ROUTING',
                                         Entity_id => l_routing_id ) THEN
       FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUT_NOT_VALID');
       FND_MSG_PUB.ADD;
       RAISE routing_delete_dep_failure;
    END IF;

    GMD_ROUTING_STEPS_PVT.delete_step_dependencies
    ( p_routingstep_no	    => p_routingstep_no
    , p_dep_routingstep_no  => p_dep_routingstep_no
    , p_routing_id          => l_routing_id
    , x_return_status       => x_return_status
    );

    /* Check if work was done */
    IF SQL%ROWCOUNT = 0 THEN
       RAISE routing_delete_dep_failure;
    END IF;  /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */

    fnd_msg_pub.count_and_get (
       p_count   => x_message_count
      ,p_encoded => FND_API.g_false
      ,p_data    => x_message_list);

    IF x_message_count = 0 THEN
       IF (l_debug = 'Y') THEN
          gmd_debug.put_line('Routing was deleted successfullly');
       END IF;
    END IF;

    IF (P_commit) THEN
      COMMIT;
    END IF;

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Completed '||l_api_name ||' at '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
    END IF;

  EXCEPTION
    WHEN routing_delete_dep_failure OR invalid_version THEN
         ROLLBACK TO SAVEPOINT delete_step_dependency;
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'API not complete');
         END IF;
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN setup_failure THEN
    	 ROLLBACK TO SAVEPOINT delete_step_dependency;
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get (
            p_count   => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_message_list);
    WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT delete_step_dependency;
         fnd_msg_pub.add_exc_msg (gmd_routing_steps_PUB.m_pkg_name, l_api_name);
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'When others exception:'||SQLERRM);
         END IF;
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         x_return_status := FND_API.g_ret_sts_unexp_error;

  END delete_step_dependencies;

END GMD_ROUTING_STEPS_PUB;

/
