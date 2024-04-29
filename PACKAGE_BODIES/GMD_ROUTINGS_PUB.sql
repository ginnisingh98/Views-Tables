--------------------------------------------------------
--  DDL for Package Body GMD_ROUTINGS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_ROUTINGS_PUB" AS
/* $Header: GMDPROUB.pls 120.4.12010000.4 2010/02/03 19:37:49 plowe ship $ */


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

  /* ================================================================= */
  /* Procedure:                                                        */
  /*   insert_routing                                                  */
  /*                                                                   */
  /* DESCRIPTION:                                                      */
  /*                                                                   */
  /* API returns (x_return_code) = 'S' if the insert into routing      */
  /* header  (fm_rout_hdr or gmd_routings) table is successfully.      */
  /*                                                                   */
  /* History :                                                         */
  /* Shyam   07/29/2002   Initial implementation                       */
  /* P.Raghu 08/27/2003  Bug#3068013 K is intialized with 1.           */
  /* kkillams23-03-2004 Added call to modify_status to set routing     */
  /*                    status to default status if default status is  */
  /*                    defined organization level w.r.t. bug 3408799  */
  /* Uday Phadtare 13-MAR-2008 Bug 6871738. Select ROUTING_CLASS_UOM   */
  /*    instead of UOM in Cursor Rout_cls_cur.                         */
  /* Raju -- Bug 9314021 Feb 02 2010 if owner id is passed then it has */
  /*  to be considered else assign gmd_api_grp.user_id.                */
  /* ================================================================= */
  PROCEDURE insert_routing
  (
    p_api_version            IN  NUMBER                     :=  1
  , p_init_msg_list          IN  BOOLEAN	             :=  TRUE
  , p_commit                 IN  BOOLEAN	             :=  FALSE
  , p_routings               IN  gmd_routings%ROWTYPE
  , p_routings_step_tbl      IN  GMD_ROUTINGS_PUB.gmd_routings_step_tab
  , p_routings_step_dep_tbl  IN  GMD_ROUTINGS_PUB.gmd_routings_step_dep_tab
  , x_message_count          OUT NOCOPY  NUMBER
  , x_message_list           OUT NOCOPY  VARCHAR2
  , x_return_status          OUT NOCOPY  VARCHAR2
  ) IS

    /* Local variable section */
    l_api_name              CONSTANT VARCHAR2(30) := 'INSERT_ROUTING';
    l_row_id                         ROWID;
    k                                NUMBER        := 1;
    l_return_from_routing_step_dep   VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_routing_id                     NUMBER;
    l_owner_id                       NUMBER;
    l_oprn_no                        gmd_operations.oprn_no%TYPE;
    l_oprn_vers                      gmd_operations.oprn_vers%TYPE;
    l_return_status                  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_return_from_routing_hdr        VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_return_from_routing_step       VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_routing_qty                    gmd_routings.routing_qty%TYPE := 0;
    l_process_loss                   gmd_routings.process_loss%TYPE := 0;
    l_routing_class_um               fm_rout_cls.uom%TYPE;
    l_stepdep_tbl                    GMD_ROUTINGS_PUB.gmd_routings_step_dep_tab;
    l_step_dep_tab                   GMD_ROUTINGS_PUB.gmd_routings_step_dep_tab;

    --kkillams,bug 3408799
    l_entity_status                  GMD_API_GRP.status_rec_type;

    /* Define cursors */
    /* gets the routing class uom */
    --Bug 6871738. Select ROUTING_CLASS_UOM instead of UOM.
    Cursor Rout_cls_cur(vRouting_class fm_rout_hdr.routing_class%TYPE) IS
       Select ROUTING_CLASS_UOM
       From   fm_rout_cls
       Where  routing_class = vRouting_class
       and    delete_mark = 0;

    /* gets the operation no and version associated to the routing detail/Step */
    Cursor Get_oprn_details(vOprn_id fm_rout_dtl.oprn_id%TYPE)  IS
       Select oprn_no, oprn_vers
       From   gmd_operations_b
       Where  oprn_id = vOprn_id;

    /* get routing id sequence */
    CURSOR Get_routing_id_seq IS
       SELECT gem5_routing_id_s.NEXTVAL
       FROM   sys.dual;

    /* B5609637 UOM cursor to find the routing UOM class and the routing class UOM class */
    CURSOR Cur_uom_class (p_uom_code VARCHAR2) IS
     SELECT uom_class
     FROM   mtl_units_of_measure
     WHERE  uom_code = p_uom_code;

   /* B9314021 user id cursor to check the valid user */
    CURSOR Cur_user_id (p_owner_id NUMBER) IS
     SELECT 1
     FROM   fnd_user
     WHERE  user_id = p_owner_id;

    --rnalla bug 9314021
    l_temp  NUMBER;

    l_routing_class_um_class VARCHAR2(30);
    l_routing_um_class       VARCHAR2(30);
    l_routing_qty_cnv        NUMBER;


    /* get a record type */
    l_routings_rec   gmd_routings%ROWTYPE;

    /* Define Exceptions */
    routing_creation_failure           EXCEPTION;
    routing_step_creation_failure      EXCEPTION;
    routing_step_dep_failure           EXCEPTION;
    invalid_version                    EXCEPTION;
    setup_failure                      EXCEPTION;
    default_status_err                 EXCEPTION;

  BEGIN
    SAVEPOINT create_routing;

    /* Set the return status to success initially */
    x_return_status  := FND_API.G_RET_STS_SUCCESS;
    l_routings_rec   := p_routings;

   /* B5609637 Initialize the routing qty and the process loss with the passed values */
       l_process_loss := p_routings.process_loss;
       l_routing_qty  := p_routings.routing_qty;



    /* Initialize message list and count if needed */
    IF p_init_msg_list THEN
       fnd_msg_pub.initialize;
    END IF;

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'||'Begin of API');
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
                                        ,'INSERT_ROUTING'
                                        ,gmd_routings_PUB.m_pkg_name) THEN
       RAISE invalid_version;
    END IF;

    IF p_routings.routing_no IS NULL THEN
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'||'Routing Number required');
      END IF;
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'ROUTING_NO');
      FND_MSG_PUB.ADD;
      RAISE routing_creation_failure;
    END IF;

    IF p_routings.routing_vers IS NULL THEN
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'||'Routing Version required');
      END IF;
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'ROUTING_VERS');
      FND_MSG_PUB.ADD;
      RAISE routing_creation_failure;
    ELSIF p_routings.routing_vers IS NOT NULL THEN
      IF (p_routings.routing_vers < 0 ) THEN
        FND_MESSAGE.SET_NAME ('GMD', 'GMD_NEGATIVE_FIELDS');
        FND_MSG_PUB.ADD;
        RAISE routing_creation_failure;
      END IF;
    END IF;

    IF p_routings.routing_desc IS NULL THEN
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'||'Routing Description required');
      END IF;
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'ROUTING_DESC');
      FND_MSG_PUB.ADD;
      RAISE routing_creation_failure;
    END IF;

    /* routing_uom must be passed, otherwise give error */
    IF p_routings.routing_uom IS NULL THEN
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'||'Item uom required');
      END IF;
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'ROUTING_UOM');
      FND_MSG_PUB.ADD;
      RAISE routing_creation_failure;
    /* call common function to check if um passed is valid */
    ELSIF (NOT(gmd_api_grp.validate_um(p_routings.routing_uom))) THEN
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'||'Item uom invalid');
      END IF;
      FND_MESSAGE.SET_NAME('GMA', 'SY_INVALID_UM_CODE');
      FND_MSG_PUB.ADD;
      RAISE routing_creation_failure;
    END IF;

    /*
     *  Convergence related fix - Shyam S
     *
     */

    --Check that organization id is not null if raise an error message
    IF (p_routings.owner_organization_id IS NULL) THEN
      FND_MESSAGE.SET_NAME('GMD', 'GMD_MISSING_ORGANIZATION_ID');
      FND_MSG_PUB.Add;
      RAISE routing_creation_failure;
    END IF;

    -- Check if the responsibility has access to the organization
    IF NOT (GMD_API_GRP.OrgnAccessible (powner_orgn_id => p_routings.owner_organization_id) ) THEN
      RAISE routing_creation_failure;
    END IF;

    --Check the organization id passed is process enabled if not raise an error message
    IF NOT (gmd_api_grp.check_orgn_status(p_routings.owner_organization_id)) THEN
      FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_ORGANIZATION_ID');
      FND_MESSAGE.SET_TOKEN('ORGN_ID', p_routings.owner_organization_id);
      FND_MSG_PUB.Add;
      RAISE routing_creation_failure;
    END IF;

    /* Validation :  Validate if the Routing start and end dates */
    l_routings_rec.effective_start_date  := TRUNC(NVL(p_routings.effective_start_date,SYSDATE));
    IF l_routings_rec.effective_start_date IS NOT NULL AND
      p_routings.effective_end_date IS NOT NULL  THEN
      /* Effective end date must be greater than start date, otherwise give error */
      IF l_routings_rec.effective_start_date > p_routings.effective_end_date THEN
        IF (l_debug = 'Y') THEN
          gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'
                   ||'effective start date must be less then end date');
        END IF;
        FND_MESSAGE.SET_NAME('GMD', 'QC_MIN_MAX_DATE');
        FND_MSG_PUB.ADD;
        RAISE routing_creation_failure;
      END IF;
    END IF;

    /* Validation 1.  Check if this routing that is created does not exists
      in the the database. The routing_id is the PK or Routing_no and version is
      the unique key for this table (gmd_routings_b).  */
    GMDRTVAL_PUB.check_routing(pRouting_no    => p_routings.routing_no
                              ,pRouting_vers  => p_routings.routing_vers
                              ,xRouting_id    => l_routing_id
                              ,xReturn_status => l_return_status);

    IF l_return_status <> 'E' THEN /* it indicates that this routing exists */
       FND_MESSAGE.SET_NAME('GMA', 'SY_INVALID_DUPLICATION');
       FND_MSG_PUB.ADD;
       RAISE routing_creation_failure;
    ELSE
       OPEN  Get_routing_id_seq;
       FETCH Get_routing_id_seq INTO l_routing_id;
       IF Get_routing_id_seq%NOTFOUND then
          FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_ROUT_SEQ');
          FND_MSG_PUB.ADD;
          RAISE routing_creation_failure;
       END IF;
       CLOSE Get_routing_id_seq;
    END IF; /* l_return_status <> 'E' */

    /* Validation :  Validate if the Routing dates fall within the associated operation
       start and end dates.  */
    FOR b IN 1 .. p_routings_step_tbl.count LOOP
      OPEN  Get_oprn_details(p_routings_step_tbl(b).oprn_id);
      FETCH Get_oprn_details INTO l_oprn_no, l_oprn_vers;
        IF (Get_oprn_details%NOTFOUND) THEN
           FND_MESSAGE.SET_NAME('GMD', 'GMD_MISSING_OPRN');
           FND_MSG_PUB.ADD;
           CLOSE Get_oprn_details;
           RAISE routing_creation_failure;
        END IF;
      CLOSE Get_oprn_details;
      --Bug 8591276 is fixed by passing
      --(,prouting_end_date => l_routings_rec.effective_end_date) the
      --routing end date to the validation,So that it will compare with operation dates.
      IF GMDRTVAL_PUB.check_oprn(poprn_no =>l_oprn_no
                                ,poprn_vers => l_oprn_vers
                                ,prouting_start_date => l_routings_rec.effective_start_date
                                ,prouting_end_date => l_routings_rec.effective_end_date
                      ) <> 0 THEN
         FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUT_DATES_INVALID');
         FND_MSG_PUB.ADD;
         RAISE routing_creation_failure;
      END IF;
    END LOOP; /* loop to validate routing dates */
    -- rnalla Bug 9314021 add the new cusror to check for valid user id
    IF (p_routings.owner_id IS NOT NULL) THEN
      OPEN Cur_user_id(p_routings.owner_id);
      FETCH Cur_user_id INTO l_temp;
      IF Cur_user_id%NOTFOUND THEN
            FND_MESSAGE.SET_NAME('GMD', 'QC_INVALID_USER');
            FND_MSG_PUB.Add;
            CLOSE Cur_user_id;
            Raise routing_creation_failure;
         END IF;
         CLOSE Cur_user_id;
    END IF;
    /* Assingning the owner_id,enforce_step_dependency if they are not passed */
    l_routings_rec.owner_id  := NVL(p_routings.owner_id, gmd_api_grp.user_id); -- Bug 9314021
    l_routings_rec.enforce_step_dependency := NVL(p_routings.enforce_step_dependency,0);

    /* Validation :  Check if Routing class is valid  */
    IF p_routings.routing_class IS NOT NULL THEN
       IF GMDRTVAL_PUB.check_routing_class(p_routings.routing_class) <> 0 THEN
          FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_ROUT_CLS');
          FND_MSG_PUB.ADD;
          RAISE routing_creation_failure;
       END IF;
    END IF;

    /* Calculations  - Process loss.  Based on the Routing qty, its uom and Routing class
       calculate the planned process loss.
       This is done only if the a NULL value was passed for this field */
    IF (p_routings.process_loss IS NULL) THEN
       /* Get the routing_qty in its routing_class uom */
       IF (p_routings.Routing_class IS NOT NULL) THEN
         OPEN  Rout_cls_cur(p_routings.Routing_class);
         FETCH Rout_cls_cur INTO l_routing_class_um;
         IF Rout_cls_cur%NOTFOUND THEN
            FND_MESSAGE.SET_NAME('GMD', 'GMD_TPL_WO_ROUT_CLS');
            FND_MSG_PUB.Add;
            CLOSE Rout_cls_cur;
            Raise routing_creation_failure;
         END IF;
         CLOSE Rout_cls_cur;

      /*  Bug  5609637 , check for the uom class of routing and the routing class UOM */
       OPEN Cur_uom_class(l_routing_class_um);
       FETCH Cur_uom_class INTO l_routing_class_um_class;
       CLOSE Cur_uom_class;

       OPEN Cur_uom_class(p_routings.routing_uom);
       FETCH Cur_uom_class INTO l_routing_um_class;
       CLOSE Cur_uom_class;

       IF l_routing_um_class = l_routing_class_um_class THEN

                 l_routing_qty_cnv :=  INV_CONVERT.inv_um_convert
                                                        (  item_id        => null
                                                          ,precision      => 5
                                                          ,from_quantity  => p_routings.Routing_qty
                                                          ,from_unit      => p_routings.routing_uom
                                                          ,to_unit        => l_routing_class_um
                                                          ,from_name      => NULL
                                                          ,to_name        => NULL);

                 /* Calculate the process loss */
                 l_process_loss := GMDRTVAL_PUB.get_theoretical_process_loss
                                                (prouting_class => p_routings.Routing_class,
                                                 pquantity      => l_routing_qty_cnv);

       ELSE
	        FND_MESSAGE.SET_NAME('GMD', 'GMD_RTG_CLS_VS_RTG_UM_TYPE');
		FND_MSG_PUB.Add;
                x_return_status := FND_API.G_RET_STS_ERROR;
                Raise routing_creation_failure;

       END IF; /* IF l_routing_um_class = l_routing_class_um_class */

       END IF; /* if routing class is not null */
    ELSE
       l_process_loss := p_routings.process_loss;
       l_routing_qty  := p_routings.routing_qty;
    END IF; /* if process loss is null */

    /* Assign values that were derived in this API */
    l_routings_rec.routing_id   := l_routing_id;
    l_routings_rec.process_loss := l_process_loss;
    l_routings_rec.routing_qty  := NVL(l_routing_qty,0);
    l_routings_rec.contiguous_ind := NVL(p_routings.contiguous_ind,0);

    /* Following steps are followed during creation of a routing
    1. Business Rule : There must be at least one routing step for a
       routing header to be created.
    2. After routing steps are created, routing step dependencies can be
       created for these steps.  However, there need to be more than one routing steps
       to create step dependencies for this routing. Routing details/Steps API
       should take care of this.  */
    IF (p_routings_step_tbl.count > 0) THEN
       /* Step 1 : Create Routing header */
       GMD_ROUTINGS_PVT.insert_routing
       ( p_routings       =>  l_routings_rec
       , x_message_count  =>  x_message_count
       , x_message_list   =>  x_message_list
       , x_return_status  =>  x_return_status
       );
       /* After creating this routing pass the routing id */
       /* to the function that creates the routing steps  */

       /* Step 2 : Create Routing steps  */
       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'
          ||'Insert the routing steps for routing with routing id = '||l_routing_id);
       END IF;

       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         Raise routing_creation_failure;
       END IF;

       /* Looping each routing step detail row */
       /* After creating routing steps pass the routing id       */
       /* and the routing step no to the function that generates */
       /* the step dependencies */
       FOR i IN 1 .. p_routings_step_tbl.count LOOP
          GMD_ROUTING_STEPS_PUB.insert_routing_steps
          (p_routing_id            =>  l_routing_id
          ,p_routing_step_rec      =>  p_routings_step_tbl(i)
          ,p_routings_step_dep_tbl =>  l_stepdep_tbl
          ,p_commit	           =>  FALSE
          ,x_message_count         =>  x_message_count
          ,x_message_list          =>  x_message_list
          ,x_return_status         =>  l_return_from_routing_step
          );
          -- Check if routing detail was created
          IF l_return_from_routing_step <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE routing_step_creation_failure;
          END IF;
       END LOOP; /* End loop for p_routings_step_tbl */

       IF p_routings_step_dep_tbl.count > 0 THEN
          IF (l_debug = 'Y') THEN
            gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'
            ||'Creating Routing Step dependencies ');
          END IF;
          FOR i IN 1 .. p_routings_step_tbl.count LOOP
            -- Call the routing step dep function
            -- For each routingStep_no, routing_id enter all the dependent
            -- routing step nos
            -- Construct a PL/SQL table that is specific only to this
            -- routing step no and routing id.
            l_step_dep_tab.delete;
            /* Begin Bug#3068013  P.Raghu  */
            /* Initializing k */
            k := 1;
            /* End Bug#3068013 */
            FOR j IN 1 .. p_routings_step_dep_tbl.count  LOOP
              IF (p_routings_step_tbl(i).ROUTINGSTEP_NO
                       = p_routings_step_dep_tbl(j).ROUTINGSTEP_NO) THEN
               l_step_dep_tab(k).routingstep_no     := p_routings_step_dep_tbl(j).routingstep_no     ;
               l_step_dep_tab(k).dep_routingstep_no := p_routings_step_dep_tbl(j).dep_routingstep_no ;
               l_step_dep_tab(k).routing_id         := l_routing_id                                  ;
               l_step_dep_tab(k).dep_type           := p_routings_step_dep_tbl(j).dep_type           ;
               l_step_dep_tab(k).rework_code        := p_routings_step_dep_tbl(j).rework_code        ;
               l_step_dep_tab(k).standard_delay     := p_routings_step_dep_tbl(j).standard_delay     ;
               l_step_dep_tab(k).minimum_delay      := p_routings_step_dep_tbl(j).minimum_delay      ;
               l_step_dep_tab(k).max_delay          := p_routings_step_dep_tbl(j).max_delay          ;
               l_step_dep_tab(k).transfer_qty       := p_routings_step_dep_tbl(j).transfer_qty       ;
               l_step_dep_tab(k).RoutingStep_No_uom  := p_routings_step_dep_tbl(j).RoutingStep_No_uom        ;
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
              ,p_routingstep_no         => p_routings_step_tbl(i).routingstep_no
              ,p_routings_step_dep_tbl  => l_step_dep_tab
              ,p_commit	                => FALSE
              ,x_message_count          => x_message_count
              ,x_message_list           => x_message_list
              ,x_return_status          => l_return_from_routing_step_dep
              );

              /* Check if insert of step dependency was done */
              IF l_return_from_routing_step_dep <> FND_API.G_RET_STS_SUCCESS THEN
                 RAISE routing_step_dep_failure;
              END IF;  /* IF l_return_from_routing_step_dep <> FND_API.G_RET_STS_SUCCESS */
         END IF; /* when l_step_dep_tab.count > 0 */
       END LOOP;
      END IF; /* if p_routings_step_dep_tbl.count > 0 */
    ELSE
       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'
          ||'Routing API needs atleast one step to create its header');
       END IF;
       RAISE routing_creation_failure;
    END IF;

    /* Check if work was done */
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE routing_creation_failure;
    END IF;  /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */

    IF (P_commit) THEN
      COMMIT;
      --kkillams,bug 3408799
      SAVEPOINT default_status_sp;
      --Getting the default status for the owner orgn code or null orgn of recipe from parameters table
      gmd_api_grp.get_status_details (V_entity_type   => 'ROUTING',
                                      V_orgn_id       => p_routings.owner_organization_id, --W.r.t. bug 4004501
                                      X_entity_status => l_entity_status);
      --Add this code after the call to gmd_routings_pkg.insert_row.
      IF (l_entity_status.entity_status > 100) THEN
         Gmd_status_pub.modify_status ( p_api_version        => 1
                                      , p_init_msg_list      => TRUE
                                      , p_entity_name        =>'ROUTING'
                                      , p_entity_id          => l_routings_rec.routing_id
                                      , p_entity_no          => NULL
                                      , p_entity_version     => NULL
                                      , p_to_status          => l_entity_status.entity_status
                                      , p_ignore_flag        => FALSE
                                      , x_message_count      => x_message_count
                                      , x_message_list       => x_message_list
                                      , x_return_status      => X_return_status);
         IF x_return_status  NOT IN (FND_API.g_ret_sts_success,'P') THEN
            RAISE default_status_err;
         END IF; --x_return_status  NOT IN (FND_API.g_ret_sts_success,'P')
      END IF; --l_entity_status <> 100
      COMMIT;
    END IF; --P_commit

    fnd_msg_pub.count_and_get (
       p_count   => x_message_count
      ,p_encoded => FND_API.g_false
      ,p_data    => x_message_list);

    IF x_message_count = 0 THEN
       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'
          ||'Routing Header was created successfully');
       END IF;
    END IF;

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Completed '||l_api_name ||' at '
       ||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
    END IF;

  EXCEPTION
    WHEN routing_creation_failure OR invalid_version THEN
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'API not complete');
         END IF;
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
         x_return_status := FND_API.G_RET_STS_ERROR;
         ROLLBACK TO SAVEPOINT create_routing;
    WHEN setup_failure THEN
    	 ROLLBACK TO SAVEPOINT create_routing;
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get (
            p_count   => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_message_list);
    WHEN default_status_err THEN
         ROLLBACK TO default_status_sp;
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get (
            p_count   => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_message_list);
    WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT create_routing;
         x_return_status := FND_API.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (gmd_routings_PUB.m_pkg_name, l_api_name);
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'When others exception:'||SQLERRM);
         END IF;
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
  END insert_routing;

  /* =============================================================== */
  /* Procedure:                                                      */
  /*   update_routing                                                */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /* API returns (x_return_code) = 'S' if the update into routing    */
  /* header  (fm_rout_hdr or gmd_routings) table is successfully.    */
  /*                                                                 */
  /* History :                                                       */
  /* Shyam   07/29/2002   Initial implementation                     */
  /* RLNAGARA 25-Apr-2008 B6997624 Check if the fixed process loss uom is valid*/
  /* Raju -- Bug 9314021 Feb 02 2010 if owner id is passed then it has */
  /*  to be considered for update                                    */
  /* =============================================================== */
  PROCEDURE update_routing
  ( p_api_version 	IN 	NUMBER 			        := 1
  , p_init_msg_list 	IN 	BOOLEAN 			:= TRUE
  , p_commit		IN 	BOOLEAN 			:= FALSE
  , p_routing_id	IN	gmd_routings.routing_id%TYPE    := NULL
  , p_routing_no	IN	gmd_routings.routing_no%TYPE    := NULL
  , p_routing_vers	IN	gmd_routings.routing_vers%TYPE  := NULL
  , p_update_table	IN	update_tbl_type
  , x_message_count 	OUT NOCOPY 	NUMBER
  , x_message_list 	OUT NOCOPY 	VARCHAR2
  , x_return_status	OUT NOCOPY 	VARCHAR2
  ) IS

    /* Local variable section */
    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_ROUTING';
    l_routing_id             gmd_routings.routing_id%TYPE;
    l_return_status          VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_cur_status             gmd_status.status_code%TYPE;
    l_owner_id               gmd_routings.owner_id%TYPE;
    l_owner_orgn_id          NUMBER;

    /* Define record type that hold the routing data */
    l_old_routing_rec        gmd_routings%ROWTYPE;

    /* Cursor section */
    Cursor get_cur_status(vRouting_id gmd_routings.routing_id%TYPE ) IS
      Select routing_status
      From   gmd_routings
      Where  routing_id = vRouting_id;

    CURSOR get_old_routing_rec(vRouting_id  gmd_routings.routing_id%TYPE)  IS
       Select *
       From   gmd_routings
       Where  Routing_id = vRouting_id;

   /* B9314021 user id cursor to check the valid user */
    CURSOR Cur_user_id (p_owner_id NUMBER) IS
     SELECT 1
     FROM   fnd_user
     WHERE  user_id = p_owner_id;

    --rnalla bug 9314021
    l_temp  NUMBER;

    /* Define Exceptions */
    routing_update_failure           EXCEPTION;
    invalid_version                  EXCEPTION;
    setup_failure                    EXCEPTION;

  BEGIN
    SAVEPOINT update_routing;

    /* Set the return status to success initially */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* Initialize message list and count if needed */
    IF p_init_msg_list THEN
       fnd_msg_pub.initialize;
    END IF;

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'
            ||'Begining of Update API ');
    END IF;

    /* Intialize the setup fields */
    IF NOT gmd_api_grp.setup_done THEN
      gmd_api_grp.setup_done := gmd_api_grp.setup;
    END IF;
    IF NOT gmd_api_grp.setup_done THEN
      RAISE setup_failure;
    END IF;

    /* Make sure we are call compatible */
    IF NOT FND_API.compatible_api_call ( GMD_ROUTINGS_PUB.m_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,GMD_ROUTINGS_PUB.m_pkg_name) THEN
       RAISE invalid_version;
    END IF;

    /* Validation 1.  Check if this routing that is updated does exists
       in the the database. The routing_id is the PK or Routing_no and version is
       the unique key for this table (gmd_routings_b). */
    IF p_routing_id IS NOT NULL THEN
       l_routing_id := p_routing_id;
    ELSE
      GMDRTVAL_PUB.check_routing(pRouting_no    => p_routing_no
                                ,pRouting_vers  => p_routing_vers
                                ,xRouting_id    => l_routing_id
                                ,xReturn_status => l_return_status);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          /* it indicates that this routing does'ntexists */
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTING_INVALID');
          FND_MSG_PUB.ADD;
          RAISE routing_update_failure;
       END IF;
    END IF;

    /* Check the routing id is not null */
    IF l_routing_id IS NULL THEN
      IF (l_debug = 'Y') THEN
         gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'||'Routing id is required');
      END IF;
      FND_MESSAGE.SET_NAME ('GMI', 'GMI_MISSING');
      FND_MESSAGE.SET_TOKEN ('MISSING', 'ROUTING_ID');
      FND_MSG_PUB.ADD;
      RAISE routing_update_failure;
    END IF;

    /* Routing Security fix */
    /* Validation:  Check if for given user this routing can be modified */
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'
            ||'Validation of user - owner orgn ocde = '||gmd_api_grp.user_id);
    END IF;

    IF NOT GMD_API_GRP.Check_orgn_access(Entity     => 'ROUTING'
                                        ,Entity_id  => l_routing_id) THEN
       RAISE routing_update_failure;
    END IF;

    /* Validation: Operation status level should be higher or equal
       the routing level status. For instance, if the routing status
       is "Approved for Laboratory Use", operations with a status cannot be "New"
       are not allowed.  Therefore when the routing status is updated check
       all the associated operation status */
    OPEN  get_cur_status(l_routing_id);
    FETCH get_cur_status INTO l_cur_status;
    CLOSE get_cur_status;

    FOR a IN 1 .. p_update_table.count  LOOP
       /* Validation: status dependencies */
       IF UPPER(p_update_table(a).p_col_to_update) = 'STATUS' THEN
          IF NOT GMD_STATUS_CODE.CHECK_DEPENDENT_STATUS
                                 ( P_Entity_Type    => 4,
                                   P_Entity_id      => l_routing_id,
                                   P_Current_Status => l_cur_status,
                                   P_To_Status      => p_update_table(a).p_value) THEN
             FND_MESSAGE.SET_NAME('GMD', 'GMD_STATUS_DEPEND_NOT_APPROVED');
             FND_MSG_PUB.ADD;
             RAISE routing_update_failure;
          END IF;
       /* Validation :  Check if owner_orgn_id is valid */
       /* Routing Security fix */
       ELSIF UPPER(p_update_table(a).p_col_to_update) = 'OWNER_ORGANIZATION_ID' THEN
          l_owner_orgn_id :=  p_update_table(a).p_value;
          IF NOT GMD_API_GRP.OrgnAccessible(l_owner_orgn_id) THEN
            RAISE routing_update_failure;
          END IF;
       /* Validation :  Check if Routing class is valid  */
       ELSIF UPPER(p_update_table(a).p_col_to_update) = 'ROUTING_CLASS' THEN
          IF p_update_table(a).p_value IS NOT NULL THEN
            IF GMDRTVAL_PUB.check_routing_class(p_update_table(a).p_value) <> 0 THEN
               FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_ROUT_CLS');
               FND_MSG_PUB.ADD;
               RAISE routing_update_failure;
            END IF;
          END IF;
       /* Validation :  Check if Routing uom is valid  */
       ELSIF UPPER(p_update_table(a).p_col_to_update) = 'ROUTING_UOM' THEN
          IF p_update_table(a).p_value IS NOT NULL THEN
            IF (NOT(gmd_api_grp.validate_um(p_update_table(a).p_value))) THEN
               FND_MESSAGE.SET_NAME('GMA', 'SY_INVALID_UM_CODE');
               FND_MSG_PUB.ADD;
               RAISE routing_update_failure;
            END IF;
          END IF;
       /* Validation: delete_mark validation */
       ELSIF UPPER(p_update_table(a).p_col_to_update) = 'DELETE_MARK' THEN
          GMDRTVAL_PUB.check_delete_mark ( Pdelete_mark    => p_update_table(a).p_value,
                                           x_return_status => l_return_status);
          IF l_return_status <> 'S' THEN /* it indicates that invalid value has been passed */
              FND_MESSAGE.SET_NAME('GMA', 'SY_BADDELETEMARK');
              FND_MSG_PUB.ADD;
              RAISE routing_update_failure;
          END IF;
       /*RLNAGARA B6997624 Check if the fixed process loss uom is valid*/
       ELSIF UPPER(p_update_table(a).p_col_to_update) = 'FIXED_PROCESS_LOSS_UOM' THEN
          IF p_update_table(a).p_value IS NOT NULL THEN
            IF (NOT(gmd_api_grp.validate_um(p_update_table(a).p_value))) THEN
               FND_MESSAGE.SET_NAME('GMA', 'SY_INVALID_UM_CODE');
               FND_MSG_PUB.ADD;
               RAISE routing_update_failure;
            END IF;
          END IF;
       ELSIF UPPER(p_update_table(a).p_col_to_update) = 'OWNER_ID' THEN
         -- rnalla Bug 9314021 add the new cusror to check for valid user id
         IF p_update_table(a).p_value IS NOT NULL THEN
           OPEN Cur_user_id(p_update_table(a).p_value);
           FETCH Cur_user_id INTO l_temp;
           IF Cur_user_id%NOTFOUND THEN
              FND_MESSAGE.SET_NAME('GMD', 'QC_INVALID_USER');
              FND_MSG_PUB.Add;
              CLOSE Cur_user_id;
              Raise routing_update_failure;
           END IF;
           CLOSE Cur_user_id;
         END IF;
       END IF;


       /* Validation : Routing status is not On Hold nor Obsolete/Archived
          and Routing is not logically deleted */
       IF NOT GMD_COMMON_VAL.UPDATE_ALLOWED
                            (Entity    => 'ROUTING',
                             Entity_id => l_routing_id,
                             Update_Column_Name => p_update_table(a).p_col_to_update ) THEN
         FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUT_NOT_VALID');
         FND_MSG_PUB.ADD;
         RAISE routing_update_failure;
       END IF;
    END LOOP;

    /* Call the Routing Pvt API */
    GMD_ROUTINGS_PVT.update_routing
    ( p_routing_id	=>   l_routing_id
    , p_update_table	=>   p_update_table
    , x_message_count 	=>   x_message_count
    , x_message_list 	=>   x_message_list
    , x_return_status	=>   x_return_status
    );

    /* Check if work was done */
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE routing_update_failure;
    END IF;  /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */

    fnd_msg_pub.count_and_get (
       p_count => x_message_count
      ,p_encoded => FND_API.g_false
      ,p_data => x_message_list);

    IF x_message_count = 0 THEN
       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'||'Routing was updated successfullly');
       END IF;
    END IF;

    IF (P_commit) THEN
      COMMIT;
    END IF;

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Completed '||l_api_name ||' at '
       ||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
    END IF;

  EXCEPTION
    WHEN routing_update_failure OR invalid_version THEN
         ROLLBACK TO SAVEPOINT update_routing;
         x_return_status := FND_API.G_RET_STS_ERROR;
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'API not complete');
         END IF;
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
    WHEN setup_failure THEN
    	 ROLLBACK TO SAVEPOINT update_routing;
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get (
            p_count   => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_message_list);
    WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT update_routing;
         x_return_status := FND_API.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (gmd_routings_PUB.m_pkg_name, l_api_name);
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'When others exception:'||SQLERRM);
         END IF;
         fnd_msg_pub.count_and_get (
            p_count   => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_message_list);
  END update_routing;

  /* =============================================================== */
  /* Procedure:                                                      */
  /*   delete_routing                                                */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /* API returns (x_return_code) = 'S' if the delete into routing    */
  /* header  (fm_rout_hdr or gmd_routings) table is successfully.    */
  /*                                                                 */
  /* History :                                                       */
  /* Shyam    07/29/2002   Initial implementation                    */
  /* kkillams 02/17/2004   Added new validation which checks whether */
  /*                       Routing is associated with any recipe or  */
  /*                       not w.r.t. bug 3355204                    */
  /* =============================================================== */
  PROCEDURE delete_routing
  ( p_api_version 	IN 	NUMBER 			        := 1
  , p_init_msg_list 	IN 	BOOLEAN 			:= TRUE
  , p_commit		IN 	BOOLEAN 			:= FALSE
  , p_routing_id	IN	gmd_routings.routing_id%TYPE    := NULL
  , p_routing_no	IN	gmd_routings.routing_no%TYPE    := NULL
  , p_routing_vers	IN	gmd_routings.routing_vers%TYPE  := NULL
  , x_message_count 	OUT NOCOPY 	NUMBER
  , x_message_list 	OUT NOCOPY 	VARCHAR2
  , x_return_status	OUT NOCOPY 	VARCHAR2
  ) IS

    /*Cursor verifies whether routing associated with any recipe or not*/
    CURSOR Cur_check_rout(cp_routing_id gmd_recipes.routing_id%TYPE)
                                        IS SELECT count(1) FROM   gmd_recipes
                                           WHERE  routing_id = cp_routing_id
                                           AND delete_mark = 0;
    /* Local variable section */
    l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_ROUTING';
    l_routing_id            gmd_routings.routing_id%TYPE;
    l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
    l_count                 NUMBER;

    /* Define a table type */
    l_update_table          GMD_ROUTINGS_PUB.UPDATE_TBL_TYPE;


    /* Define Exceptions */
    routing_delete_failure           EXCEPTION;
    invalid_version                  EXCEPTION;
    setup_failure                    EXCEPTION;
    routing_used                     EXCEPTION;
  BEGIN
    SAVEPOINT delete_routing;
    IF (l_debug = 'Y') THEN
       gmd_debug.log_initialize('Dertpub');
    END IF;

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
    IF NOT FND_API.compatible_api_call ( GMD_ROUTINGS_PUB.m_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,GMD_ROUTINGS_PUB.m_pkg_name) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE invalid_version;
    END IF;

    /* Validation :.  Check if this routing that is deleted does exists
       in the the database. The routing_id is the PK or Routing_no and version is
       the unique key for this table (gmd_routings_b).  */
    IF p_routing_id IS NOT NULL THEN
       l_routing_id := p_routing_id;
    ELSE
      GMDRTVAL_PUB.check_routing(pRouting_no    => p_routing_no
                                ,pRouting_vers  => p_routing_vers
                                ,xRouting_id    => l_routing_id
                                ,xReturn_status => l_return_status);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          /* it indicates that this routing does'ntexists */
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTING_INVALID');
          FND_MSG_PUB.ADD;
          RAISE routing_delete_failure;
       END IF;
    END IF;

    /*Validation: Verifies whether routing associated with any recipe or not.
      If yes, then system raises error and terminates remaining processes w.r.t. bug 3355204*/
    OPEN Cur_check_rout(p_routing_id);
    FETCH Cur_check_rout INTO l_count;
    IF (l_count <> 0) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTING_USED');
         FND_MSG_PUB.ADD;
         RAISE routing_used;
    END IF;

    l_update_table(1).P_COL_TO_UPDATE := 'DELETE_MARK';
    l_update_table(1).P_VALUE := '1';

    GMD_ROUTINGS_PUB.update_routing
    ( p_routing_id	=>   l_routing_id
    , p_update_table	=>   l_update_table
    , p_commit	        =>   FALSE
    , x_message_count 	=>   x_message_count
    , x_message_list 	=>   x_message_list
    , x_return_status	=>   x_return_status
    );

    /* Check if work was done */
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE routing_delete_failure;
    END IF;  /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */

    fnd_msg_pub.count_and_get (
       p_count   => x_message_count
      ,p_encoded => FND_API.g_false
      ,p_data    => x_message_list);

    IF x_message_count = 0 THEN
       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'||'Routing was created successfullly');
       END IF;
    END IF;

    IF (P_commit) THEN
      COMMIT;
    END IF;

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Completed '||l_api_name ||' at '
       ||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
    END IF;

  EXCEPTION
    WHEN routing_delete_failure OR invalid_version or routing_used THEN
         ROLLBACK TO SAVEPOINT delete_routing;
         x_return_status := FND_API.G_RET_STS_ERROR;
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'API not complete');
         END IF;
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
    WHEN setup_failure THEN
    	 ROLLBACK TO SAVEPOINT delete_routing;
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get (
            p_count   => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_message_list);
    WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT delete_routing;
         x_return_status := FND_API.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (gmd_routings_PUB.m_pkg_name, l_api_name);
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'When others exception:'||SQLERRM);
         END IF;
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
  END delete_routing;

  /* =============================================================== */
  /* Procedure:                                                      */
  /*   undelete_routing                                                */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /* API returns (x_return_code) = 'S' if the delete into routing    */
  /* header  (fm_rout_hdr or gmd_routings) table is successfully.    */
  /*                                                                 */
  /* History :                                                       */
  /* Shyam   07/29/2002   Initial implementation                     */
  /* =============================================================== */
  PROCEDURE undelete_routing
  ( p_api_version 	IN 	NUMBER 			        := 1
  , p_init_msg_list 	IN 	BOOLEAN 			:= TRUE
  , p_commit		IN 	BOOLEAN 			:= FALSE
  , p_routing_id	IN	gmd_routings.routing_id%TYPE    := NULL
  , p_routing_no	IN	gmd_routings.routing_no%TYPE    := NULL
  , p_routing_vers	IN	gmd_routings.routing_vers%TYPE  := NULL
  , x_message_count 	OUT NOCOPY 	NUMBER
  , x_message_list 	OUT NOCOPY 	VARCHAR2
  , x_return_status	OUT NOCOPY 	VARCHAR2
  ) IS

    /* Local variable section */
    l_api_name              CONSTANT VARCHAR2(30) := 'UNDELETE_ROUTING';
    l_routing_id            gmd_routings.routing_id%TYPE;
    l_return_status                  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    /* Define a table type */
    l_update_table          GMD_ROUTINGS_PUB.UPDATE_TBL_TYPE;

    /* Define Exceptions */
    routing_undelete_failure         EXCEPTION;
    invalid_version                  EXCEPTION;
    setup_failure                    EXCEPTION;
  BEGIN
    SAVEPOINT undelete_routing;
    IF (l_debug = 'Y') THEN
       gmd_debug.log_initialize('Undrtpub');
    END IF;

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
    IF NOT FND_API.compatible_api_call ( GMD_ROUTINGS_PUB.m_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,GMD_ROUTINGS_PUB.m_pkg_name) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       RAISE invalid_version;
    END IF;

    /* Validation :.  Check if this routing that is deleted does exists
       in the the database. The routing_id is the PK or Routing_no and version is
       the unique key for this table (gmd_routings_b).  */
    IF p_routing_id IS NOT NULL THEN
       l_routing_id := p_routing_id;
    ELSE
      GMDRTVAL_PUB.check_routing(pRouting_no    => p_routing_no
                                ,pRouting_vers  => p_routing_vers
                                ,xRouting_id    => l_routing_id
                                ,xReturn_status => l_return_status);

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          /* it indicates that this routing does'ntexists */
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTING_INVALID');
          FND_MSG_PUB.ADD;
          RAISE routing_undelete_failure;
       END IF;
    END IF;

    UPDATE gmd_routings_b
    SET    delete_mark = 0
    WHERE  routing_id  = l_routing_id;

    fnd_msg_pub.count_and_get (
       p_count   => x_message_count
      ,p_encoded => FND_API.g_false
      ,p_data    => x_message_list);

    IF x_message_count = 0 THEN
       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'||'Routing was undeleted successfullly');
       END IF;
    END IF;

    IF (P_commit) THEN
      COMMIT;
    END IF;

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Completed '||l_api_name ||' at '
       ||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
    END IF;

  EXCEPTION
    WHEN routing_undelete_failure OR invalid_version THEN
         ROLLBACK TO SAVEPOINT undelete_routing;
         x_return_status := FND_API.G_RET_STS_ERROR;
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'API not complete');
         END IF;
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
    WHEN setup_failure THEN
    	 ROLLBACK TO SAVEPOINT undelete_routing;
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get (
            p_count   => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_message_list);
    WHEN OTHERS THEN
         ROLLBACK TO SAVEPOINT undelete_routing;
         x_return_status := FND_API.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg (gmd_routings_PUB.m_pkg_name, l_api_name);
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'When others exception:'||SQLERRM);
         END IF;
         fnd_msg_pub.count_and_get (
            p_count => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data => x_message_list);
  END undelete_routing;


END GMD_ROUTINGS_PUB;

/
