--------------------------------------------------------
--  DDL for Package Body GMD_ROUTING_STEPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_ROUTING_STEPS_PVT" AS
/* $Header: GMDVRTSB.pls 120.1 2006/06/12 06:38:45 rkrishan noship $ */


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
  /* Raju    31-OCT-02    Changed the code to add default values.    */
  /* Raju    18-NOV-02    Tested in opm115qa db and fixed the issues */
  /* =============================================================== */
  PROCEDURE insert_routing_steps
  ( p_routing_id             IN   gmd_routings.routing_id%TYPE
  , p_routing_step_rec       IN   fm_rout_dtl%ROWTYPE
  , x_return_status          OUT NOCOPY  VARCHAR2
  ) IS

  /* Local variable section */
  l_api_name              CONSTANT VARCHAR2(30)  := 'INSERT_ROUTING_STEPS';
  l_return_status                  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_routingStep_id                 fm_rout_dtl.routingStep_id%TYPE;
  l_steprelease_type               fm_rout_dtl.steprelease_type%TYPE;

  /*define cursor */
  /* get routing step id sequence */
  CURSOR Get_routingstep_id_seq IS
     SELECT gem5_routingstep_id_s.NEXTVAL
     FROM   sys.dual;

  /* Exception section */
  routing_step_creation_failure      EXCEPTION;
  invalid_version                    EXCEPTION;
  setup_failure                      EXCEPTION;

  l_dummy number;

  BEGIN

    /* Intialize the setup fields */
    IF NOT gmd_api_grp.setup_done THEN
      gmd_api_grp.setup_done := gmd_api_grp.setup;
    END IF;
    IF NOT gmd_api_grp.setup_done THEN
      RAISE setup_failure;
    END IF;
    /* Set the return status to success initially */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* Get the routingStep_id from sequence generator */
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Get the routingstep id value :  ');
    END IF;

    IF p_routing_step_rec.routingstep_id IS NULL THEN
      OPEN  Get_routingstep_id_seq;
      FETCH Get_routingstep_id_seq INTO l_routingStep_id;
        IF Get_routingStep_id_seq%NOTFOUND then
          FND_MESSAGE.SET_NAME('GMD', 'GMD_INVALID_ROUT_SEQ');
          FND_MSG_PUB.ADD;
          CLOSE Get_routingstep_id_seq;
          RAISE routing_step_creation_failure;
        END IF;
      CLOSE Get_routingstep_id_seq;
    END IF;

    /* Step 1 : Create Routing steps  */
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Insert the routing steps for routing with routingstep id = '||l_routingstep_id);
    END IF;

    INSERT INTO fm_rout_dtl
       ( routing_id, routingstep_no, routingstep_id , oprn_id ,step_qty, steprelease_type, text_code
        ,last_updated_by, created_by, last_update_date, creation_date, last_update_login
        ,attribute1, attribute2, attribute3, attribute4, attribute5 , attribute6 , attribute7
        ,attribute8 , attribute9 , attribute10 , attribute11 , attribute12, attribute13
        ,attribute14 , attribute15, attribute16, attribute17, attribute18, attribute19
        ,attribute20 , attribute21, attribute22, attribute23 , attribute24,attribute25
        ,attribute26, attribute27 , attribute28, attribute29 , attribute30, attribute_category
        ,x_coordinate, y_coordinate,minimum_transfer_qty)
    VALUES
       ( p_routing_id , p_routing_step_rec.routingstep_no, NVL(p_routing_step_rec.routingstep_id,l_routingStep_id)
        ,p_routing_step_rec.oprn_id, p_routing_step_rec.step_qty, p_routing_step_rec.steprelease_type
        ,p_routing_step_rec.text_code, gmd_api_grp.user_id
        ,gmd_api_grp.user_id, NVL(p_routing_step_rec.last_update_date,SYSDATE)
        ,NVL(p_routing_step_rec.creation_date,SYSDATE), p_routing_step_rec.last_update_login
        ,p_routing_step_rec.attribute1, p_routing_step_rec.attribute2
        ,p_routing_step_rec.attribute3, p_routing_step_rec.attribute4
        ,p_routing_step_rec.attribute5, p_routing_step_rec.attribute6
        ,p_routing_step_rec.attribute7, p_routing_step_rec.attribute8
        ,p_routing_step_rec.attribute9, p_routing_step_rec.attribute10
        ,p_routing_step_rec.attribute11, p_routing_step_rec.attribute12
        ,p_routing_step_rec.attribute13, p_routing_step_rec.attribute14
        ,p_routing_step_rec.attribute15, p_routing_step_rec.attribute16
        ,p_routing_step_rec.attribute17, p_routing_step_rec.attribute18
        ,p_routing_step_rec.attribute19, p_routing_step_rec.attribute20
        ,p_routing_step_rec.attribute21, p_routing_step_rec.attribute22
        ,p_routing_step_rec.attribute23, p_routing_step_rec.attribute24
        ,p_routing_step_rec.attribute25, p_routing_step_rec.attribute26
        ,p_routing_step_rec.attribute27, p_routing_step_rec.attribute28
        ,p_routing_step_rec.attribute29, p_routing_step_rec.attribute30
        ,p_routing_step_rec.attribute_category, p_routing_step_rec.x_coordinate
        ,p_routing_step_rec.y_coordinate,p_routing_step_rec.minimum_transfer_qty);

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Completed '||l_api_name ||' at '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
    END IF;
  EXCEPTION
    WHEN routing_step_creation_failure OR invalid_version THEN
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'API not complete '||SQLERRM);
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN setup_failure THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg (gmd_routing_steps_PUB.m_pkg_name, l_api_name);
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'When others exception:'||SQLERRM);
         END IF;
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
  /* S.Dulyk 8/24/03 remove NVL and ,0 from max_delay line in        */
  /*   insert to fm_rout_Dep                                         */
  /* =============================================================== */
  PROCEDURE insert_step_dependencies
  ( p_routing_id             IN   gmd_routings.routing_id%TYPE
  , p_routingstep_no         IN   fm_rout_dtl.routingstep_no%TYPE
  , p_routings_step_dep_tbl  IN   GMD_ROUTINGS_PUB.gmd_routings_step_dep_tab
  , x_return_status          OUT NOCOPY  VARCHAR2
  ) IS

  /* Cursor section */
  CURSOR get_step_qty (vRouting_id NUMBER,vroutingstep_no NUMBER) IS
    Select step_qty
    From   fm_rout_dtl
    Where  routing_id = vRouting_id
           AND routingstep_no = vroutingstep_no;

  /* Local variable section */
  l_api_name              CONSTANT   VARCHAR2(30)  := 'INSERT_STEP_DEPENDENCIES';
  l_return_status                    VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_step_qty                         NUMBER;
  l_transfer_qty                     NUMBER;

  /* Exception section */
  routing_step_dep_failure           EXCEPTION;
  routing_cir_ref_failure            EXCEPTION;
  invalid_version                    EXCEPTION;
  setup_failure                      EXCEPTION;


  BEGIN
    IF (l_debug = 'Y') THEN
       gmd_debug.log_initialize('Crsdpvt');
    END IF;

    /* Intialize the setup fields */
    IF NOT gmd_api_grp.setup_done THEN
      gmd_api_grp.setup_done := gmd_api_grp.setup;
    END IF;
    IF NOT gmd_api_grp.setup_done THEN
      RAISE setup_failure;
    END IF;

    /* Set the return status to success initially */
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    /* Insert made into the step dependency table */
    FOR i IN 1 .. p_routings_step_dep_tbl.count LOOP
    /* get the step qty for tranfer qty calculation */
      OPEN get_step_qty(p_routing_id,p_routingstep_no);
      FETCH get_step_qty INTO l_step_qty;
      CLOSE get_step_qty;
      l_transfer_qty := l_step_qty * p_routings_step_dep_tbl(i).transfer_pct * .01;


    /* S.Dulyk - 12/27/02 Bug 2669986 Added validation for max_delay */
     IF (p_routings_step_dep_tbl(i).max_delay < p_routings_step_dep_tbl(i).standard_delay AND
        p_routings_step_dep_tbl(i).max_delay IS NOT NULL) THEN
           FND_MESSAGE.SET_NAME('GMD','GMD_MAX_DELAY_VALIDATION');
           FND_MSG_PUB.ADD;
           x_return_status := FND_API.g_ret_sts_error;
     END IF;


        INSERT INTO fm_rout_dep
        (routingstep_no ,dep_routingstep_no ,routing_id ,dep_type ,rework_code
        ,standard_delay ,minimum_delay ,max_delay ,transfer_qty ,routingstep_no_uom
        ,text_code ,last_updated_by ,created_by ,last_update_date ,creation_date
        ,last_update_login ,transfer_pct ) VALUES
        (p_routingstep_no
        ,p_routings_step_dep_tbl(i).dep_routingstep_no
        ,p_routing_id
        ,NVL(p_routings_step_dep_tbl(i).dep_type,0)
        ,p_routings_step_dep_tbl(i).rework_code
        ,NVL(p_routings_step_dep_tbl(i).standard_delay,0)
        ,NVL(p_routings_step_dep_tbl(i).minimum_delay,0)
        ,p_routings_step_dep_tbl(i).max_delay
        ,NVL(l_transfer_qty,0)
        ,p_routings_step_dep_tbl(i).routingstep_no_uom
        ,p_routings_step_dep_tbl(i).text_code
        ,gmd_api_grp.user_id
        ,gmd_api_grp.user_id
        ,NVL(p_routings_step_dep_tbl(i).last_update_date,SYSDATE)
        ,NVL(p_routings_step_dep_tbl(i).creation_date,SYSDATE)
        ,p_routings_step_dep_tbl(i).last_update_login
        ,NVL(p_routings_step_dep_tbl(i).transfer_pct,100)
        );

        -- Check if routing step dependencies were created
        IF (l_debug = 'Y') THEN
           gmd_debug.put_line('After inserting routing step dependencies');
        END IF;

        IF SQL%ROWCOUNT = 0 THEN
           RAISE routing_step_dep_failure;
        END IF;
    END LOOP; /* End loop for p_routings_step_dep_tbl.count  */
    /* Validation after step dependenices creation */
    /* Validation : Check for circular step dependencies */
    IF GMDRTVAL_PUB.circular_dependencies_exist (p_routing_id) THEN
       RAISE routing_cir_ref_failure;
    END IF;

    /* Check if work was done */
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE routing_step_dep_failure;
    END IF;  /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Completed '||l_api_name ||' at '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
    END IF;

  EXCEPTION
    WHEN routing_step_dep_failure OR invalid_version THEN
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'API not complete');
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;

    WHEN routing_cir_ref_failure THEN
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'API not complete due circular reference');
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN setup_failure THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg (gmd_routing_steps_PUB.m_pkg_name, l_api_name);
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'When others exception:'||SQLERRM);
         END IF;
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
  ( p_routingstep_id	IN	fm_rout_dtl.routingstep_id%TYPE
  , p_update_table	IN	GMD_ROUTINGS_PUB.update_tbl_type
  , x_return_status	OUT NOCOPY 	VARCHAR2
  ) IS

  /* Local variable section */
  l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_ROUTING_STEPS';
  l_routingstep_id                 fm_rout_dtl.routingStep_id%TYPE;
  l_return_status                  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_db_date                        DATE;

  /* Define record type that hold the routing data */
  l_old_routingStep_rec            fm_rout_dtl%ROWTYPE;

  /* Define Exceptions */
  last_update_date_failure         EXCEPTION;
  routing_update_step_failure      EXCEPTION;
  invalid_version                  EXCEPTION;
  setup_failure                    EXCEPTION;

  CURSOR get_old_routingStep_rec(vRoutingStep_id  fm_rout_dtl.routingStep_id%TYPE)  IS
     Select *
     From   fm_rout_dtl
     Where  RoutingStep_id = vRoutingStep_id;

  BEGIN
    /* Set the return status to success initially */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* Get the old routing rec value */
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Fetch : Populate the old routing step record ');
    END IF;

    /* Intialize the setup fields */
    IF NOT gmd_api_grp.setup_done THEN
      gmd_api_grp.setup_done := gmd_api_grp.setup;
    END IF;
    IF NOT gmd_api_grp.setup_done THEN
      RAISE setup_failure;
    END IF;

    OPEN  get_old_routingStep_rec(p_routingStep_id);
    FETCH get_old_routingStep_rec INTO l_old_routingStep_rec;
       IF get_old_routingStep_rec%NOTFOUND THEN
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTINGSTEP_INVALID');
          FND_MSG_PUB.ADD;
          CLOSE get_old_routingStep_rec;
          RAISE routing_update_step_failure;
       END IF;
    CLOSE get_old_routingStep_rec;

    /* Get the last update date from database */
    l_db_date := l_old_routingStep_rec.LAST_UPDATE_DATE;

    /* Actual update in fm_rout_dtl table */
    /* Loop thro' every column in p_update_table table and for each column name
       assign or replace the old value with the table value */
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Seting the update column value  ');
    END IF;
    FOR i IN 1 .. p_update_table.count  LOOP
       IF (UPPER(p_update_table(i).p_col_to_update) = 'STEP_QTY') THEN
           l_old_routingStep_rec.STEP_QTY := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'STEPRELEASE_TYPE') THEN
           l_old_routingStep_rec.STEPRELEASE_TYPE := TO_NUMBER(p_update_table(i).p_value);
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'TEXT_CODE') THEN
           l_old_routingStep_rec.TEXT_CODE := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'LAST_UPDATED_BY') THEN
           l_old_routingStep_rec.LAST_UPDATED_BY := gmd_api_grp.user_id;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'LAST_UPDATE_DATE') THEN
           l_old_routingstep_rec.LAST_UPDATE_DATE :=
                           FND_DATE.CANONICAL_TO_DATE(p_update_table(i).p_value);
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'LAST_UPDATE_LOGIN') THEN
           l_old_routingStep_rec.LAST_UPDATE_LOGIN := gmd_api_grp.user_id;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE1') THEN
           l_old_routingStep_rec.ATTRIBUTE1 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE2') THEN
           l_old_routingStep_rec.ATTRIBUTE2 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE3') THEN
           l_old_routingStep_rec.ATTRIBUTE3 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE4') THEN
           l_old_routingStep_rec.ATTRIBUTE4 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE5') THEN
           l_old_routingStep_rec.ATTRIBUTE5 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE6') THEN
           l_old_routingStep_rec.ATTRIBUTE6 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE7') THEN
           l_old_routingStep_rec.ATTRIBUTE7 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE8') THEN
           l_old_routingStep_rec.ATTRIBUTE8 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE9') THEN
           l_old_routingStep_rec.ATTRIBUTE9 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE10') THEN
           l_old_routingStep_rec.ATTRIBUTE10 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE11') THEN
           l_old_routingStep_rec.ATTRIBUTE11 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE12') THEN
           l_old_routingStep_rec.ATTRIBUTE12 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE13') THEN
           l_old_routingStep_rec.ATTRIBUTE13 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE14') THEN
           l_old_routingStep_rec.ATTRIBUTE14 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE15') THEN
           l_old_routingStep_rec.ATTRIBUTE15 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE16') THEN
           l_old_routingStep_rec.ATTRIBUTE16 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE17') THEN
           l_old_routingStep_rec.ATTRIBUTE17 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE18') THEN
           l_old_routingStep_rec.ATTRIBUTE18 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE19') THEN
           l_old_routingStep_rec.ATTRIBUTE19 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE20') THEN
           l_old_routingStep_rec.ATTRIBUTE20 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE21') THEN
           l_old_routingStep_rec.ATTRIBUTE21 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE22') THEN
           l_old_routingStep_rec.ATTRIBUTE22 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE23') THEN
           l_old_routingStep_rec.ATTRIBUTE23 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE24') THEN
           l_old_routingStep_rec.ATTRIBUTE24 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE25') THEN
           l_old_routingStep_rec.ATTRIBUTE25 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE26') THEN
           l_old_routingStep_rec.ATTRIBUTE26 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE27') THEN
           l_old_routingStep_rec.ATTRIBUTE27 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE28') THEN
           l_old_routingStep_rec.ATTRIBUTE28 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE29') THEN
           l_old_routingStep_rec.ATTRIBUTE29 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE30') THEN
           l_old_routingStep_rec.ATTRIBUTE30 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE_CATEGORY') THEN
           l_old_routingStep_rec.ATTRIBUTE_CATEGORY := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'X_COORDINATE') THEN
           l_old_routingStep_rec.X_COORDINATE := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'Y_COORDINATE') THEN
           l_old_routingStep_rec.Y_COORDINATE := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'MINIMUM_TRANSFER_QTY') THEN
           l_old_routingStep_rec.MINIMUM_TRANSFER_QTY := p_update_table(i).p_value;
       -- Added for MSNR replace
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'OPRN_ID') THEN
           l_old_routingStep_rec.OPRN_ID := p_update_table(i).p_value;
       END IF;

       /* Compare Dates - if the last update date passed in via the API is less than
          the last update in the db - it indicates someelse has updated this row after this
          row was selected */
       IF l_old_routingStep_rec.last_update_date < l_db_date THEN
       	  RAISE last_update_date_failure;
       END IF;

       IF (l_debug = 'Y') THEN
          gmd_debug.put_line('Before routing step table update  ');
       END IF;
       UPDATE fm_rout_dtl
       SET     oprn_id                =  l_old_routingStep_rec.oprn_id
              ,step_qty               =  l_old_routingStep_rec.step_qty
              ,steprelease_type       =  l_old_routingStep_rec.steprelease_type
              ,text_code              =  l_old_routingStep_rec.text_code
              ,last_updated_by        =  l_old_routingStep_rec.last_updated_by
              ,last_update_date       =  NVL(l_old_routingStep_rec.last_update_date,SYSDATE)
              ,last_update_login      =  l_old_routingStep_rec.last_update_login
              ,attribute1             =  l_old_routingStep_rec.attribute1
              ,attribute2             =  l_old_routingStep_rec.attribute2
              ,attribute3             =  l_old_routingStep_rec.attribute3
              ,attribute4             =  l_old_routingStep_rec.attribute4
              ,attribute5             =  l_old_routingStep_rec.attribute5
              ,attribute6             =  l_old_routingStep_rec.attribute6
              ,attribute7             =  l_old_routingStep_rec.attribute7
              ,attribute8             =  l_old_routingStep_rec.attribute8
              ,attribute9             =  l_old_routingStep_rec.attribute9
              ,attribute10            =  l_old_routingStep_rec.attribute10
              ,attribute11            =  l_old_routingStep_rec.attribute11
              ,attribute12            =  l_old_routingStep_rec.attribute12
              ,attribute13            =  l_old_routingStep_rec.attribute13
              ,attribute14            =  l_old_routingStep_rec.attribute14
              ,attribute15            =  l_old_routingStep_rec.attribute15
              ,attribute16            =  l_old_routingStep_rec.attribute16
              ,attribute17            =  l_old_routingStep_rec.attribute17
              ,attribute18            =  l_old_routingStep_rec.attribute18
              ,attribute19            =  l_old_routingStep_rec.attribute19
              ,attribute20            =  l_old_routingStep_rec.attribute20
              ,attribute21            =  l_old_routingStep_rec.attribute21
              ,attribute22            =  l_old_routingStep_rec.attribute22
              ,attribute23            =  l_old_routingStep_rec.attribute23
              ,attribute24            =  l_old_routingStep_rec.attribute24
              ,attribute25            =  l_old_routingStep_rec.attribute25
              ,attribute26            =  l_old_routingStep_rec.attribute26
              ,attribute27            =  l_old_routingStep_rec.attribute27
              ,attribute28            =  l_old_routingStep_rec.attribute28
              ,attribute29            =  l_old_routingStep_rec.attribute29
              ,attribute30            =  l_old_routingStep_rec.attribute30
              ,attribute_category     =  l_old_routingStep_rec.attribute_category
              ,minimum_transfer_qty   =  l_old_routingStep_rec.minimum_transfer_qty
              ,x_coordinate           =  l_old_routingStep_rec.x_coordinate
              ,y_coordinate           =  l_old_routingStep_rec.y_coordinate
       WHERE  routingStep_id          =  p_routingstep_id;

       IF (l_debug = 'Y') THEN
          gmd_debug.put_line('After routing step table update ');
       END IF;
       IF SQL%ROWCOUNT = 0 THEN
         RAISE routing_update_step_failure;
       END IF;
    END LOOP;

     /* Check if work was done */
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE routing_update_step_failure;
     END IF;  /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */
     IF (l_debug = 'Y') THEN
        gmd_debug.put_line('Completed '||m_pkg_name||'.'||l_api_name ||' at '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
     END IF;

  EXCEPTION
    WHEN routing_update_step_failure OR invalid_version THEN
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'API not complete');
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN last_update_date_failure THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('FND', 'FND_RECORD_CHANGED_ERROR');
         FND_MSG_PUB.ADD;
    WHEN setup_failure THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg (gmd_routing_steps_PUB.m_pkg_name, l_api_name);
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'When others exception:'||SQLERRM);
         END IF;
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
  ( p_routingstep_no	 IN	fm_rout_dep.routingstep_no%TYPE
  , p_dep_routingstep_no IN	fm_rout_dep.routingstep_no%TYPE
  , p_routing_id 	 IN	fm_rout_dep.routing_id%TYPE
  , p_update_table	 IN	GMD_ROUTINGS_PUB.update_tbl_type
  , x_return_status	 OUT NOCOPY 	VARCHAR2
  ) IS

  /* Local variable section */
  l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_STEP_DEPENDENCIES';
  l_return_status                  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
  l_db_date               DATE;

  /* Define record type that hold the routing data */
  l_old_stepDep_rec               fm_rout_dep%ROWTYPE;

  /* Define Exceptions */
  last_update_date_failure         EXCEPTION;
  routing_update_dep_failure       EXCEPTION;
  invalid_version                  EXCEPTION;
  setup_failure                    EXCEPTION;

  CURSOR get_old_stepDep_rec( vRoutingStep_no      fm_rout_dep.routingStep_no%TYPE
                             ,vdep_RoutingStep_no  fm_rout_dep.dep_routingStep_no%TYPE
                             ,vRouting_id          fm_rout_dep.routing_id%TYPE)  IS
     Select *
     From   fm_rout_dep
     Where  RoutingStep_no     = vRoutingStep_no
     And    dep_RoutingStep_no = vdep_RoutingStep_no
     And    Routing_id         = vRouting_id;

  BEGIN
    IF (l_debug = 'Y') THEN
       gmd_debug.log_initialize('Updsdpvt');
    END IF;

    /* Intialize the setup fields */
    IF NOT gmd_api_grp.setup_done THEN
      gmd_api_grp.setup_done := gmd_api_grp.setup;
    END IF;
    IF NOT gmd_api_grp.setup_done THEN
      RAISE setup_failure;
    END IF;

    /* Set the return status to success initially */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* The old routing step dependency record */
    OPEN  get_old_stepDep_rec(p_routingstep_no,p_dep_routingstep_no,p_routing_id);
    FETCH get_old_stepDep_rec INTO l_old_stepDep_rec;
       IF get_old_stepDep_rec%NOTFOUND THEN
          FND_MESSAGE.SET_NAME('GMD', 'GMD_STEPDEP_INVALID');
          FND_MSG_PUB.ADD;
          CLOSE get_old_stepDep_rec;
          RAISE routing_update_dep_failure;
       END IF;
    CLOSE get_old_stepDep_rec;

    /* Get the last update date in database */
    l_db_date := l_old_stepDep_rec.LAST_UPDATE_DATE;

    /* Actual update in fm_rout_dep table */
    /* Loop thro' every column in p_update_table table and for each column name
       assign or replace the old value with the table value */
    FOR i IN 1 .. p_update_table.count  LOOP
       IF (UPPER(p_update_table(i).p_col_to_update) = 'DEP_TYPE') THEN
           l_old_stepDep_rec.DEP_TYPE := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'REWORK_CODE') THEN
           l_old_stepDep_rec.REWORK_CODE := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'STANDARD_DELAY') THEN
           l_old_stepDep_rec.STANDARD_DELAY := p_update_table(i).p_value;
/* S.Dulyk - 12/27/02 Bug 2669986 Added max_delay */
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'MAX_DELAY') THEN
           l_old_stepDep_rec.MAX_DELAY := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'TRANSFER_PCT') THEN
           l_old_stepDep_rec.TRANSFER_PCT := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'TEXT_CODE') THEN
           l_old_stepDep_rec.TEXT_CODE := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'LAST_UPDATED_BY') THEN
           l_old_stepDep_rec.LAST_UPDATED_BY := gmd_api_grp.user_id;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'LAST_UPDATE_DATE') THEN
           l_old_stepdep_rec.LAST_UPDATE_DATE := FND_DATE.CANONICAL_TO_DATE(p_update_table(i).p_value);
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'LAST_UPDATE_LOGIN') THEN
           l_old_stepDep_rec.LAST_UPDATE_LOGIN := gmd_api_grp.user_id;
       END IF;

       /* Compare Dates - if the last update date passed in via the API is less than
          the last update in the db - it indicates someelse has updated this row after this
          row was selected */
       IF l_old_stepDep_rec.last_update_date < l_db_date THEN
       	  RAISE last_update_date_failure;
       END IF;

/* S.Dulyk - 12/27/02 Bug 2669986 Added validation for max_delay */
     IF (l_old_stepDep_rec.max_delay < l_old_stepDep_rec.standard_delay AND
        l_old_stepDep_rec.max_delay IS NOT NULL) THEN
           FND_MESSAGE.SET_NAME('GMD','GMD_MAX_DELAY_VALIDATION');
           FND_MSG_PUB.ADD;
           x_return_status := FND_API.g_ret_sts_error;
     END IF;

/* S.Dulyk - 12/27/02 Bug 2669986 Added max_delay */
       UPDATE   fm_rout_dep
       SET      dep_type             =  l_old_stepDep_rec.dep_type
               ,rework_code          =  l_old_stepDep_rec.rework_code
               ,standard_delay       =  l_old_stepDep_rec.standard_delay
               ,max_delay         = l_old_stepDep_rec.max_delay
               ,text_code            =  l_old_stepDep_rec.text_code
               ,last_updated_by      =  l_old_stepDep_rec.last_updated_by
               ,last_update_date     =  NVL(l_old_stepDep_rec.last_update_date,SYSDATE)
               ,last_update_login    =  l_old_stepDep_rec.last_update_login
               ,transfer_pct         =  l_old_stepDep_rec.transfer_pct
        WHERE   routingstep_no       =  p_routingstep_no
        AND     dep_routingstep_no   =  p_dep_routingstep_no
        AND     routing_id           =  p_routing_id;

        IF SQL%ROWCOUNT = 0 THEN
           RAISE routing_update_dep_failure;
        END IF;
     END LOOP;

     /* Check if work was done */
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE routing_update_dep_failure;
     END IF;  /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */
     IF (l_debug = 'Y') THEN
        gmd_debug.put_line('Completed '||l_api_name ||' at '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
     END IF;

  EXCEPTION
    WHEN routing_update_dep_failure OR invalid_version THEN
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'API not complete');
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN last_update_date_failure THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('FND', 'FND_RECORD_CHANGED_ERROR');
         FND_MSG_PUB.ADD;
    WHEN setup_failure THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg (gmd_routing_steps_PUB.m_pkg_name, l_api_name);
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'When others exception:'||SQLERRM);
         END IF;
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
  ( p_routingstep_id	IN	fm_rout_dtl.routingstep_id%TYPE
  , p_routing_id 	IN	gmd_routings.routing_id%TYPE 	:=  NULL
  , x_return_status	OUT NOCOPY 	VARCHAR2
  )  IS

  /* Local variable section */
  l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_ROUTING_STEP';
  l_return_status                  VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
  l_return_from_routing_step_dep   VARCHAR2(1)  := FND_API.G_RET_STS_SUCCESS;
  l_routingStep_id                 fm_rout_dtl.routingStep_id%TYPE;
  l_routingstep_no                 fm_rout_dep.routingStep_no%TYPE;
  l_stepdep_count                  NUMBER := 0;
  l_exists                         PLS_INTEGER;

  /* Define Cursors */
  /* Cursor that check if there any row in the step dependency table that
     needs to be deleted */
  Cursor Check_Step_dep_rec(vRoutingstep_no fm_rout_dep.routingStep_no%TYPE
                           ,vRouting_id     gmd_routings.Routing_id%TYPE)  IS
     Select count(*)
     From   fm_rout_dep
     Where  (routingStep_no = vRoutingStep_no OR dep_routingStep_no = vRoutingStep_no)
     And    routing_id     = vrouting_id;


  CURSOR Cur_check_step IS
    SELECT 1
    FROM   SYS.DUAL
    WHERE  EXISTS (SELECT 1
                   FROM gmd_recipe_routing_steps
                   WHERE routingstep_id = p_routingstep_id);

  CURSOR Cur_check_step2 IS
    SELECT 1
    FROM sys.dual
    WHERE EXISTS (SELECT 1
                  FROM gmd_recipe_step_materials
                  WHERE routingstep_id = p_routingstep_id);

  CURSOR Cur_check_orgn_act IS
    SELECT 1
    FROM   sys.dual
    WHERE EXISTS (SELECT 1
                  FROM gmd_recipe_orgn_activities
                  WHERE routingstep_id = p_routingstep_id);

  CURSOR Cur_check_orgn_res IS
    SELECT 1
    FROM   sys.dual
    WHERE EXISTS (SELECT 1
                  FROM gmd_recipe_orgn_resources
                  WHERE routingstep_id = p_routingstep_id);


  /* Define Exceptions */
  routing_delete_step_failure         EXCEPTION;
  routing_delete_stepdep_failure      EXCEPTION;
  step_used_in_recipe                 EXCEPTION;
  invalid_version                     EXCEPTION;
  setup_failure                       EXCEPTION;

  BEGIN
    IF (l_debug = 'Y') THEN
       gmd_debug.log_initialize('Derspvt');
    END IF;

    /* Intialize the setup fields */
    IF NOT gmd_api_grp.setup_done THEN
      gmd_api_grp.setup_done := gmd_api_grp.setup;
    END IF;
    IF NOT gmd_api_grp.setup_done THEN
      RAISE setup_failure;
    END IF;

    /* Set the return status to success initially */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* Get the routingstep_no (routingstep_no is used for the routing step dep delete )  */
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line(' get the RoutingStep_id - if it is not passed as a parameter ');
    END IF;
    IF p_routingStep_id IS NOT NULL THEN
       l_routingstep_id := p_routingstep_id;
       GMDRTVAL_PUB.get_routingstep_info(pxRoutingStep_no  => l_routingstep_no
                                        ,pxRoutingStep_id  => l_routingstep_id
                                        ,x_return_status   => l_return_status );
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          /* it indicates that this routing does'ntexists */
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTINGSTEP_INVALID');
          FND_MSG_PUB.ADD;
          RAISE routing_delete_step_failure;
       END IF;
    END IF;

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('RoutingStep_no = '||l_routingStep_no );
    END IF;

    /* Check if work was done */
    IF SQL%ROWCOUNT = 0 THEN
       RAISE routing_delete_step_failure;
    END IF;  /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */

    /* Bug#5211932 - Check if the routing step is used in the recipe */

    /* Check for any overrides at recipe routing steps */
    OPEN Cur_check_step;
    FETCH Cur_check_step INTO l_exists;
    IF (Cur_check_step%FOUND) THEN
      CLOSE Cur_check_step;
      RAISE step_used_in_recipe;
    END IF;
    CLOSE Cur_check_step;

    /* Check for any overrides at recipe step material */
    OPEN Cur_check_step2;
    FETCH Cur_check_step2 INTO l_exists;
    IF (Cur_check_step2%FOUND) THEN
      CLOSE Cur_check_step2;
      RAISE step_used_in_recipe;
    END IF;
    CLOSE Cur_check_step2;

    /* Check for any overrides at recipe organization activity level */
    OPEN Cur_check_orgn_act;
    FETCH Cur_check_orgn_act INTO l_exists;
    IF (Cur_check_orgn_act%FOUND) THEN
      CLOSE Cur_check_orgn_act;
      RAISE step_used_in_recipe;
    END IF;
    CLOSE Cur_check_orgn_act;

    /* Check for any overrides at recipe organization resource level */
    OPEN Cur_check_orgn_res;
    FETCH Cur_check_orgn_res INTO l_exists;
    IF (Cur_check_orgn_res%FOUND) THEN
      CLOSE Cur_check_orgn_res;
      RAISE step_used_in_recipe;
    END IF;
    CLOSE Cur_check_orgn_res;

    /* Check if any rows from fm_rout_dep needs to be deleted */
    IF p_routing_id IS NOT NULL THEN
       OPEN  Check_Step_dep_rec(vRoutingstep_no  => l_routingstep_no
                               ,vRouting_id      => p_routing_id   ) ;
       FETCH Check_Step_dep_rec INTO l_stepdep_count;
       CLOSE Check_Step_dep_rec;
    END IF;

    IF l_stepdep_count > 0 THEN
      /* Delete rows in the step dependency table specific to this
         routing_id and routingstep_no */
      GMD_ROUTING_STEPS_PVT.delete_step_dependencies
      (p_routingstep_no    =>   l_routingstep_no
      , p_routing_id 	   =>   p_routing_id
      , x_return_status	   =>   l_return_from_routing_step_dep
      );

      /* Check if insert of step dependency was done */
      IF l_return_from_routing_step_dep <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE routing_delete_stepdep_failure;
      END IF;  /* IF l_return_from_routing_step_dep <> FND_API.G_RET_STS_SUCCESS */
    END IF;  /* l_stepdep_count > 0 */

    /* Actual delete is performed */
    DELETE FROM fm_rout_dtl
    WHERE  routingStep_id = p_routingStep_id;

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Completed '||l_api_name ||' at '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
    END IF;

  EXCEPTION
    WHEN routing_delete_step_failure OR invalid_version THEN
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'API not complete');
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN step_used_in_recipe THEN
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'routing step '||l_routingstep_no||' has override data ');
         END IF;
         FND_MESSAGE.SET_NAME('GMD', 'GMD_STEP_USED_IN_RECIPE');
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN routing_delete_stepdep_failure THEN
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'delete step dep API not complete');
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN setup_failure THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg (gmd_routing_steps_PUB.m_pkg_name, l_api_name);
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'When others exception:'||SQLERRM);
         END IF;
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
  ( p_routingstep_no	 IN	fm_rout_dep.routingstep_no%TYPE
  , p_dep_routingstep_no IN	fm_rout_dep.routingstep_no%TYPE := NULL
  , p_routing_id 	 IN	fm_rout_dep.routing_id%TYPE
  , x_return_status	 OUT NOCOPY 	VARCHAR2
  ) IS

  /* Local variable section */
  l_api_name              CONSTANT VARCHAR2(30) := 'DELETE_STEP_DEPENDENCIES';
  l_return_status                  VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

  /* Define Exceptions */
  routing_delete_dep_failure       EXCEPTION;
  invalid_version                  EXCEPTION;
  setup_failure                    EXCEPTION;

  BEGIN
    IF (l_debug = 'Y') THEN
       gmd_debug.log_initialize('Desdpvt');
    END IF;

    /* Set the return status to success initially */
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    /* Actual delete in  fm_rout_dep table */
    /* This delete can be specific to a dep_routingstep_no or a
       Routingstep_no */
    IF (l_debug = 'Y') THEN
       gmd_Debug.put_line('About to delete from step dep table - the routingstep no = '||p_routingstep_no ||' and routing id = '||p_routing_id);
    END IF;

    /* Intialize the setup fields */
    IF NOT gmd_api_grp.setup_done THEN
      gmd_api_grp.setup_done := gmd_api_grp.setup;
    END IF;
    IF NOT gmd_api_grp.setup_done THEN
      RAISE setup_failure;
    END IF;

    IF p_dep_routingstep_no IS NOT NULL THEN
       DELETE FROM fm_rout_dep
       WHERE   routingstep_no       =  p_routingstep_no
       AND     dep_routingstep_no   =  p_dep_routingstep_no
       AND     routing_id           =  p_routing_id;
    ELSE /* this would all dep steps for this step */
       DELETE FROM fm_rout_dep
       WHERE   routingstep_no       =  p_routingstep_no
       AND     routing_id           =  p_routing_id;
       DELETE FROM fm_rout_dep
       WHERE   dep_routingstep_no       =  p_routingstep_no
       AND     routing_id               =  p_routing_id;
    END IF;

    /* Check if work was done */
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Completed '||l_api_name ||' at '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
    END IF;

  EXCEPTION
    WHEN routing_delete_dep_failure OR invalid_version THEN
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'API not complete');
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN setup_failure THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
         fnd_msg_pub.add_exc_msg (gmd_routing_steps_PUB.m_pkg_name, l_api_name);
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'When others exception:'||SQLERRM);
         END IF;
         x_return_status := FND_API.g_ret_sts_unexp_error;

  END delete_step_dependencies;

END GMD_ROUTING_STEPS_PVT;

/
