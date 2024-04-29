--------------------------------------------------------
--  DDL for Package Body GMD_ROUTINGS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_ROUTINGS_PVT" AS
/* $Header: GMDVROUB.pls 120.4.12010000.2 2008/11/12 18:12:46 rnalla ship $ */


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
  /*   insert_routing                                                */
  /*                                                                 */
  /* DESCRIPTION:                                                    */
  /*                                                                 */
  /* API returns (x_return_code) = 'S' if the insert into routing    */
  /* header  (fm_rout_hdr or gmd_routings) table is successfully.    */
  /*                                                                 */
  /* History :                                                       */
  /* Shyam   07/29/2002   Initial implementation                     */
  /* =============================================================== */
  PROCEDURE insert_routing
  ( p_routings               IN   gmd_routings%ROWTYPE
  , x_message_count 	     OUT NOCOPY  NUMBER
  , x_message_list 	     OUT NOCOPY  VARCHAR2
  , x_return_status          OUT NOCOPY  VARCHAR2
  ) IS

  /* Local variable section */
  l_row_id                         ROWID;
  l_routing_id                     NUMBER;
  l_api_name              CONSTANT VARCHAR2(30) := 'INSERT_ROUTING';

  /* get routing id sequence */
  CURSOR Get_routing_id_seq IS
     SELECT gem5_routing_id_s.NEXTVAL
     FROM   sys.dual;

  /* Define Exceptions */
  routing_creation_failure           EXCEPTION;
  invalid_version                    EXCEPTION;
  setup_failure                      EXCEPTION;

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


    IF p_routings.routing_id IS NOT NULL THEN

       /* Step : Create Routing header */
       IF (l_debug = 'Y') THEN
          gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'
          ||'Inserting the routing header with routing id '||l_routing_id);
       END IF;

       GMD_ROUTINGS_PKG.insert_row(
         x_rowid                   => l_row_id,
         x_routing_id              => p_routings.routing_id,
         x_routing_no              => p_routings.routing_no,
         x_routing_vers            => p_routings.routing_vers,
         x_routing_status          => '100',
         x_routing_desc            => p_routings.routing_desc,
         x_routing_class           => p_routings.routing_class,
         x_routing_qty             => p_routings.routing_qty,
         x_routing_uom             => p_routings.routing_uom,
         x_owner_organization_id   => p_routings.owner_organization_id,
         x_delete_mark             => 0,
         x_text_code               => p_routings.text_code,
         x_inactive_ind            => 0,
         x_enforce_step_dependency => p_routings.enforce_step_dependency,
         x_contiguous_ind          => p_routings.contiguous_ind,
         x_in_use                  => p_routings.in_use,
         x_attribute1              => p_routings.attribute1,
         x_attribute2              => p_routings.attribute2,
         x_attribute3              => p_routings.attribute3,
         x_attribute4              => p_routings.attribute4,
         x_attribute5              => p_routings.attribute5,
         x_attribute6              => p_routings.attribute6,
         x_attribute7              => p_routings.attribute7,
         x_attribute8              => p_routings.attribute8,
         x_attribute9              => p_routings.attribute9,
         x_attribute10             => p_routings.attribute10,
         x_attribute11             => p_routings.attribute11,
         x_attribute12             => p_routings.attribute12,
         x_attribute13             => p_routings.attribute13,
         x_attribute14             => p_routings.attribute14,
         x_attribute15             => p_routings.attribute15,
         x_attribute16             => p_routings.attribute16,
         x_attribute17             => p_routings.attribute17,
         x_attribute18             => p_routings.attribute18,
         x_attribute19             => p_routings.attribute19,
         x_attribute20             => p_routings.attribute20,
         x_attribute21             => p_routings.attribute21,
         x_attribute22             => p_routings.attribute22,
         x_attribute23             => p_routings.attribute23,
         x_attribute24             => p_routings.attribute24,
         x_attribute25             => p_routings.attribute25,
         x_attribute26             => p_routings.attribute26,
         x_attribute27             => p_routings.attribute27,
         x_attribute28             => p_routings.attribute28,
         x_attribute29             => p_routings.attribute29,
         x_attribute30             => p_routings.attribute30,
         x_attribute_category      => p_routings.attribute_category,
         x_effective_start_date    => p_routings.effective_start_date,
         x_effective_end_date      => p_routings.effective_end_date,
         x_owner_id                => p_routings.owner_id,
         x_project_id              => p_routings.project_id,
         x_process_loss            => p_routings.process_loss,
         x_creation_date           => NVL(p_routings.creation_date,SYSDATE),
         x_created_by              => gmd_api_grp.user_id,
         x_last_update_date        => NVL(p_routings.last_update_date,SYSDATE),
         x_last_updated_by         => gmd_api_grp.user_id,
         x_last_update_login       => p_routings.last_update_login,
	 x_fixed_process_loss      => p_routings.fixed_process_loss,     /* RLNAGARA B6997624*/
         x_fixed_process_loss_uom  => p_routings.fixed_process_loss_uom  /* RLNAGARA B6997624*/
         );

    END IF; /* l_routing_id IS NOT NULL  */

    -- Check if routing header was created
    IF (l_debug = 'Y') THEN
       gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'||
       'Row id value after inserting routing is '||l_row_id);
    END IF;
    IF l_row_id IS NULL THEN
       RAISE routing_creation_failure;
    END IF;
    /* Get the messgae list and count generated by this API */
    fnd_msg_pub.count_and_get (
       p_count   => x_message_count
      ,p_encoded => FND_API.g_false
      ,p_data    => x_message_list);

    IF (l_debug = 'Y') THEN
       gmd_debug.put_line('Completed '||l_api_name ||' at '
       ||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
    END IF;
  EXCEPTION
    WHEN routing_creation_failure OR invalid_version THEN
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'API not complete');
         END IF;
         FND_MESSAGE.SET_NAME('GMD', 'GMD_UNEXPECTED_ERROR');
         FND_MESSAGE.SET_TOKEN('ERROR', sqlerrm);
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get (
            p_count   => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_message_list);
    WHEN setup_failure THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get (
            p_count   => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_message_list);
    WHEN OTHERS THEN
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'When others exception:'||SQLERRM);
         END IF;
         fnd_msg_pub.add_exc_msg (gmd_routings_PUB.m_pkg_name, l_api_name);
         x_return_status := FND_API.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count   => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_message_list);
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
  /* Kalyani 06/06/2006   BUG 5197863 Moved existing code to new     */
  /*                      function validate dates                    */
  /* RLNAGARA 25-Apr-2008 B6997624 Added Fixed Process Loss and UOM  */
  /* =============================================================== */
  PROCEDURE update_routing
  ( p_routing_id	IN	gmd_routings.routing_id%TYPE    := NULL
  , p_update_table	IN	gmd_routings_pub.update_tbl_type
  , x_message_count 	OUT NOCOPY     NUMBER
  , x_message_list 	OUT NOCOPY     VARCHAR2
  , x_return_status	OUT NOCOPY 	VARCHAR2
  ) IS

  /* Local variable section */
  l_api_name              CONSTANT VARCHAR2(30) := 'UPDATE_ROUTING';
  l_routingStep_id                 fm_rout_dtl.routingStep_id%TYPE;
  l_steprow                        NUMBER       := 0;
  l_db_date                        DATE;

  l_oprn_start_date                DATE;
  l_oprn_end_date                  DATE;
  l_vr_start_date                  DATE;
  l_vr_end_date                    DATE;

  /* Define record type that hold the routing data */
  l_old_routing_rec       gmd_routings%ROWTYPE;

  /* Table type defn */
  l_stepupdate_table      gmd_routings_pub.update_tbl_type;

  /* BUG 5197863 Added l_ret */
  l_ret  NUMBER;

  /* Define Exceptions */
  routing_update_failure           EXCEPTION;
  last_update_date_failure         EXCEPTION;
  invalid_version                  EXCEPTION;
  setup_failure                    EXCEPTION;

  /* Define cursor section */
  CURSOR get_old_routing_rec(vRouting_id  gmd_routings.routing_id%TYPE)  IS
     Select *
     From   gmd_routings
     Where  Routing_id = vRouting_id;

  CURSOR get_nonmanual_step_release(vRouting_id  gmd_routings.routing_id%TYPE)  IS
     Select routingstep_id
     From   fm_rout_dtl
     Where  Routing_id = vRouting_id
     And    steprelease_type <> 1;

  CURSOR Get_db_last_update_date(vRouting_id  gmd_routings.routing_id%TYPE)  IS
     Select last_update_date
     From   gmd_routings_b
     Where  Routing_id = vRouting_id;

  CURSOR Get_oprn_start_end_dates(vRouting_id NUMBER) IS
    SELECT max(effective_start_date) effective_start_date
         , min(effective_end_date) effective_end_date
    FROM   gmd_operations_b o, fm_rout_dtl d
    WHERE  o.oprn_id = d.oprn_id
    AND    d.routing_id = vRouting_id
    AND    o.delete_mark = 0;

  CURSOR Get_vr_start_end_dates(vRouting_id NUMBER) IS
    Select min(vr.Start_Date) Start_Date ,
           max(NVL(vr.End_Date, trunc(SYSDATE + 999999) ) ) End_Date
    From   gmd_routings_b rt, gmd_recipes_b rc,
           gmd_recipe_validity_rules vr
    Where  vr.recipe_id = rc.recipe_id AND
           ((rc.routing_id IS NOT NULL) AND (rc.routing_id = rt.routing_id)) AND
           rt.routing_id = vRouting_id AND
           vr.delete_mark = 0;

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
    /* Get the old routing rec value */
    OPEN  get_old_routing_rec(p_routing_id);
    FETCH get_old_routing_rec INTO l_old_routing_rec;
       IF get_old_routing_rec%NOTFOUND THEN
          FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTING_INVALID');
          FND_MSG_PUB.ADD;
          CLOSE get_old_routing_rec;
          RAISE routing_update_failure;
       END IF;
    CLOSE get_old_routing_rec;

    /* Loop thro' every column in p_update_table table and for each column name
       assign or replace the old value with the table value */
    FOR i IN 1 .. p_update_table.count  LOOP
       IF (UPPER(p_update_table(i).p_col_to_update) = 'OWNER_ORGANIZATION_ID') THEN
           l_old_routing_rec.owner_organization_id := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'OWNER_ID') THEN
           l_old_routing_rec.OWNER_ID := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ROUTING_CLASS') THEN
           l_old_routing_rec.ROUTING_CLASS := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ROUTING_QTY') THEN
           l_old_routing_rec.ROUTING_QTY := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ROUTING_UOM') THEN
           l_old_routing_rec.routing_uom := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'TEXT_CODE') THEN
           l_old_routing_rec.TEXT_CODE := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'INACTIVE_IND') THEN
           l_old_routing_rec.INACTIVE_IND := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'CONTIGUOUS_IND') THEN
           l_old_routing_rec.CONTIGUOUS_IND := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ENFORCE_STEP_DEPENDENCY') THEN
           l_old_routing_rec.ENFORCE_STEP_DEPENDENCY := p_update_table(i).p_value;
           /* Validation: If the updated value for Enforce Step Dependency is 1,
           and if the step release is not set to manual then we need to call
           the update routing step API to update the step release type for
           all its routing steps */
           IF l_old_routing_rec.ENFORCE_STEP_DEPENDENCY = 1 THEN
              FOR step_release_rec IN get_nonmanual_step_release(p_routing_id)  LOOP
                  l_steprow := l_steprow + 1;
                  l_routingStep_id := step_release_rec.routingstep_id;
                  l_stepupdate_table(l_steprow).P_COL_TO_UPDATE := 'STEPRELEASE_TYPE';
                  l_stepupdate_table(l_steprow).P_VALUE := '1';
              END LOOP;
              IF l_steprow > 0 THEN
                 GMD_ROUTING_STEPS_PVT.update_routing_steps
                 ( p_routingstep_id	=> l_routingStep_id
                 , p_update_table	=> l_stepupdate_table
                 , x_return_status	=> x_return_status
                 );
              END IF; /* l_steprow > 0 */
           END IF; /* l_old_routing_rec.ENFORCE_STEP_DEPENDENCY := 1 */
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'IN_USE') THEN
           l_old_routing_rec.IN_USE := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) like '%START_DATE%') THEN
           IF (l_debug = 'Y') THEN
              gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'
              ||'The eff_start_date for Routing prior to update = '||
                    p_update_table(i).p_value);
           END IF;
           l_old_routing_rec.EFFECTIVE_START_DATE
                            := FND_DATE.canonical_to_date(p_update_table(i).p_value);
       ELSIF (UPPER(p_update_table(i).p_col_to_update) like '%END_DATE%') THEN
           IF (l_debug = 'Y') THEN
              gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'
              ||'The eff_end_date for Routing prior to update = '||
                    p_update_table(i).p_value);
           END IF;

           l_old_routing_rec.EFFECTIVE_END_DATE
                            := FND_DATE.canonical_to_date(p_update_table(i).p_value);
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'PROCESS_LOSS') THEN
           l_old_routing_rec.PROCESS_LOSS := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'FIXED_PROCESS_LOSS') THEN        --RLNAGARA B6997624
           l_old_routing_rec.FIXED_PROCESS_LOSS := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'FIXED_PROCESS_LOSS_UOM') THEN   --RLNAGARA B6997624
           l_old_routing_rec.FIXED_PROCESS_LOSS_UOM := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ROUTING_DESC') THEN
           l_old_routing_rec.ROUTING_DESC := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'DELETE_MARK') THEN
           l_old_routing_rec.DELETE_MARK := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'LAST_UPDATED_BY') THEN
           l_old_routing_rec.LAST_UPDATED_BY := gmd_api_grp.user_id;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'LAST_UPDATE_DATE') THEN
           l_old_routing_rec.LAST_UPDATE_DATE := FND_DATE.canonical_to_date(p_update_table(i).p_value);
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'LAST_UPDATE_LOGIN') THEN
           l_old_routing_rec.LAST_UPDATE_LOGIN := gmd_api_grp.user_id;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE1') THEN
           l_old_routing_rec.ATTRIBUTE1 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE2') THEN
           l_old_routing_rec.ATTRIBUTE2 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE3') THEN
           l_old_routing_rec.ATTRIBUTE3 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE4') THEN
           l_old_routing_rec.ATTRIBUTE4 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE5') THEN
           l_old_routing_rec.ATTRIBUTE5 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE6') THEN
           l_old_routing_rec.ATTRIBUTE6 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE7') THEN
           l_old_routing_rec.ATTRIBUTE7 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE8') THEN
           l_old_routing_rec.ATTRIBUTE8 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE9') THEN
           l_old_routing_rec.ATTRIBUTE9 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE10') THEN
           l_old_routing_rec.ATTRIBUTE10 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE11') THEN
           l_old_routing_rec.ATTRIBUTE11 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE12') THEN
           l_old_routing_rec.ATTRIBUTE12 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE13') THEN
           l_old_routing_rec.ATTRIBUTE13 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE14') THEN
           l_old_routing_rec.ATTRIBUTE14 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE15') THEN
           l_old_routing_rec.ATTRIBUTE15 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE16') THEN
           l_old_routing_rec.ATTRIBUTE16 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE17') THEN
           l_old_routing_rec.ATTRIBUTE17 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE18') THEN
           l_old_routing_rec.ATTRIBUTE18 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE19') THEN
           l_old_routing_rec.ATTRIBUTE19 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE20') THEN
           l_old_routing_rec.ATTRIBUTE20 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE21') THEN
           l_old_routing_rec.ATTRIBUTE21 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE22') THEN
           l_old_routing_rec.ATTRIBUTE22 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE23') THEN
           l_old_routing_rec.ATTRIBUTE23 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE24') THEN
           l_old_routing_rec.ATTRIBUTE24 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE25') THEN
           l_old_routing_rec.ATTRIBUTE25 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE26') THEN
           l_old_routing_rec.ATTRIBUTE26 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE27') THEN
           l_old_routing_rec.ATTRIBUTE27 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE28') THEN
           l_old_routing_rec.ATTRIBUTE28 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE29') THEN
           l_old_routing_rec.ATTRIBUTE29 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE30') THEN
           l_old_routing_rec.ATTRIBUTE30 := p_update_table(i).p_value;
       ELSIF (UPPER(p_update_table(i).p_col_to_update) = 'ATTRIBUTE_CATEGORY') THEN
           l_old_routing_rec.ATTRIBUTE_CATEGORY := p_update_table(i).p_value;
       END IF;

       /* Compare Dates - if the last update date passed in via the API is less than
          the last update in the db - it indicates someelse has updated this row after this
          row was selected */
       OPEN  Get_db_last_update_date(p_Routing_id);
       FETCH Get_db_last_update_date INTO l_db_date;
         IF Get_db_last_update_date%NOTFOUND THEN
            CLOSE Get_db_last_update_date;
            RAISE routing_update_failure;
         END IF;
       CLOSE Get_db_last_update_date;

       IF l_old_routing_rec.LAST_UPDATE_DATE < l_db_date THEN
       	  RAISE last_update_date_failure;
       END IF;

     -- BUG 5197863 Moved the existing code to new function validate_dates
     l_ret := Validate_dates(p_routing_id,l_old_routing_rec.effective_start_date,l_old_routing_rec.effective_end_date);
     IF l_ret < 0 THEN
       RAISE routing_update_failure;
     END IF;
      -- Comaring Routing and VAlidity Rules Dates
      OPEN Get_vr_start_end_dates(p_routing_id);
      FETCH Get_vr_start_end_dates INTO l_vr_start_date, l_vr_end_date;
        IF l_vr_start_date IS NOT NULL  THEN
            IF (l_debug = 'Y') THEN
                gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'
                                 ||'Comparing VR and Routing Start Dates  '||
                                   'Routing Start Date = '||l_old_routing_rec.effective_start_date||
                                   ' VR Start Date  = '||l_vr_start_date);
            END IF;

            IF l_vr_start_date < l_old_routing_rec.effective_start_date THEN
                FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTING_DATE_IN_VR_DATE');
                FND_MSG_PUB.ADD;
                RAISE routing_update_failure;
            END IF;

            IF (l_vr_end_date = trunc(SYSDATE + 999999) ) THEN
              l_vr_end_date := Null;
            END IF;

            IF (l_debug = 'Y') THEN
                gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'
                                  ||'Comparing VR and Routing End Dates  '||
                                   'Routing end Date = '||l_old_routing_rec.effective_end_date||
                                   ' VR end Date  = '||l_vr_end_date);
            END IF;

            IF (l_vr_end_date IS NULL) AND
               (l_old_routing_rec.effective_end_date IS NOT NULL) THEN
                FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTING_DATE_IN_VR_DATE');
                FND_MSG_PUB.ADD;
                RAISE routing_update_failure;
            END IF;

            IF l_vr_end_date > l_old_routing_rec.effective_end_date THEN
                FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTING_DATE_IN_VR_DATE');
                FND_MSG_PUB.ADD;
                RAISE routing_update_failure;
            END IF;
         END IF;
      CLOSE Get_vr_start_end_dates;

       /* Number of times this routine is equal to number of rows in the p_update_table */
       GMD_ROUTINGS_PKG.update_row(
           x_routing_id              => p_routing_id,
           x_owner_organization_id   => l_old_routing_rec.owner_organization_id,
           x_routing_no              => l_old_routing_rec.routing_no,
           x_routing_vers            => l_old_routing_rec.routing_vers,
           x_routing_class           => l_old_routing_rec.routing_class,
           x_routing_qty             => l_old_routing_rec.routing_qty,
           x_routing_uom             => l_old_routing_rec.routing_uom,
           x_delete_mark             => l_old_routing_rec.delete_mark,
           x_text_code               => l_old_routing_rec.text_code,
           x_inactive_ind            => l_old_routing_rec.inactive_ind,
           x_enforce_step_dependency => l_old_routing_rec.enforce_step_dependency,
           /* Bug 4603035 - Added the contiguous ind to be passed to the update */
           x_contiguous_ind          => l_old_routing_rec.contiguous_ind,
           x_in_use                  => l_old_routing_rec.in_use,
           x_attribute1              => l_old_routing_rec.attribute1,
           x_attribute2              => l_old_routing_rec.attribute2,
           x_attribute3              => l_old_routing_rec.attribute3,
           x_attribute4              => l_old_routing_rec.attribute4,
           x_attribute5              => l_old_routing_rec.attribute5,
           x_attribute6              => l_old_routing_rec.attribute6,
           x_attribute7              => l_old_routing_rec.attribute7,
           x_attribute8              => l_old_routing_rec.attribute8,
           x_attribute9              => l_old_routing_rec.attribute9,
           x_attribute10             => l_old_routing_rec.attribute10,
           x_attribute11             => l_old_routing_rec.attribute11,
           x_attribute12             => l_old_routing_rec.attribute12,
           x_attribute13             => l_old_routing_rec.attribute13,
           x_attribute14             => l_old_routing_rec.attribute14,
           x_attribute15             => l_old_routing_rec.attribute15,
           x_attribute16             => l_old_routing_rec.attribute16,
           x_attribute17             => l_old_routing_rec.attribute17,
           x_attribute18             => l_old_routing_rec.attribute18,
           x_attribute19             => l_old_routing_rec.attribute19,
           x_attribute20             => l_old_routing_rec.attribute20,
           x_attribute21             => l_old_routing_rec.attribute21,
           x_attribute22             => l_old_routing_rec.attribute22,
           x_attribute23             => l_old_routing_rec.attribute23,
           x_attribute24             => l_old_routing_rec.attribute24,
           x_attribute25             => l_old_routing_rec.attribute25,
           x_attribute26             => l_old_routing_rec.attribute26,
           x_attribute27             => l_old_routing_rec.attribute27,
           x_attribute28             => l_old_routing_rec.attribute28,
           x_attribute29             => l_old_routing_rec.attribute29,
           x_attribute30             => l_old_routing_rec.attribute30,
           x_attribute_category      => l_old_routing_rec.attribute_category,
           x_effective_start_date    => l_old_routing_rec.effective_start_date,
           x_effective_end_date      => l_old_routing_rec.effective_end_date,
           x_owner_id                => l_old_routing_rec.owner_id,
           x_project_id              => l_old_routing_rec.project_id,
           x_process_loss            => l_old_routing_rec.process_loss,
           x_routing_status          => l_old_routing_rec.routing_status,
           x_routing_desc            => l_old_routing_rec.routing_desc,
           x_last_update_date        => NVL(l_old_routing_rec.last_update_date,SYSDATE),
           x_last_updated_by         => gmd_api_grp.user_id,
           x_last_update_login       => l_old_routing_rec.last_update_login,
           x_fixed_process_loss      => l_old_routing_rec.fixed_process_loss,      --RLNAGARA B6997624
           x_fixed_process_loss_uom  => l_old_routing_rec.fixed_process_loss_uom   --RLNAGARA B6997624
	   );
     END LOOP;

     /* Check if work was done */
     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE routing_update_failure;
     END IF;  /* IF x_return_status <> FND_API.G_RET_STS_SUCCESS */

    /* Get the messgae list and count generated by this API */
    fnd_msg_pub.count_and_get (
       p_count   => x_message_count
      ,p_encoded => FND_API.g_false
      ,p_data    => x_message_list);

     IF (l_debug = 'Y') THEN
        gmd_debug.put_line('Completed '||l_api_name ||' at '
        ||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS'));
     END IF;
  EXCEPTION
    WHEN routing_update_failure OR invalid_version THEN
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'API not complete');
         END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get (
            p_count   => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_message_list);
    WHEN last_update_date_failure THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('FND', 'FND_RECORD_CHANGED_ERROR');
         FND_MSG_PUB.ADD;
         fnd_msg_pub.count_and_get (
            p_count   => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_message_list);
    WHEN setup_failure THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         fnd_msg_pub.count_and_get (
            p_count   => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_message_list);
    WHEN OTHERS THEN
         IF (l_debug = 'Y') THEN
            gmd_debug.put_line (m_pkg_name||'.'||l_api_name||':'||'When others exception:'||SQLERRM);
         END IF;
         fnd_msg_pub.add_exc_msg (gmd_routings_PUB.m_pkg_name, l_api_name);
         x_return_status := FND_API.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count   => x_message_count
           ,p_encoded => FND_API.g_false
           ,p_data    => x_message_list);
  END update_routing;
 /* =============================================================== */
 /* Procedure:                                                      */
 /*   Validate_dates                                                */
 /*                                                                 */
 /* DESCRIPTION:                                                    */
 /*                                                                 */
 /*  Returns -1 if the validation fails                             */
 /*                                                                 */
 /*                                                                 */
 /* History :                                                       */
 /* Kalyani 06/06/2006   BUG 5197863 Added                          */
 /* =============================================================== */
 FUNCTION Validate_dates(
   p_routing_id  IN gmd_routings.routing_id%TYPE
  ,p_effective_start_date IN DATE
  ,p_effective_end_date  IN  DATE ) RETURN NUMBER is

   l_api_name              CONSTANT VARCHAR2(30) := 'Validate_dates';
   l_oprn_start_date                DATE;
   l_oprn_end_date                  DATE;

   CURSOR Get_oprn_start_end_dates(vRouting_id NUMBER) IS
     SELECT max(effective_start_date) effective_start_date
         , min(effective_end_date) effective_end_date
     FROM   gmd_operations_b o, fm_rout_dtl d
     WHERE  o.oprn_id = d.oprn_id
     AND    d.routing_id = vRouting_id
     AND    o.delete_mark = 0;
 BEGIN
   -- Validating Routing dates
   /* Effective end date must be greater than start date, otherwise give error */
   IF p_effective_start_date
                         > p_effective_end_date THEN
     IF (l_debug = 'Y') THEN
        gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'
                               ||'Effective start date ('||
                               p_effective_start_date||' ) '||
                                'must be less then end date ( '||
                               p_effective_end_date||' ) ');
     END IF;
     FND_MESSAGE.SET_NAME('GMD', 'QC_MIN_MAX_DATE');
     FND_MSG_PUB.ADD;
     RETURN -1;
   END IF;

   -- Comparing Routing and Operation Dates
   OPEN Get_oprn_start_end_dates(p_routing_id);
   FETCH Get_oprn_start_end_dates INTO l_oprn_start_date, l_oprn_end_date;
   IF l_oprn_start_date IS NOT NULL THEN
     IF (l_debug = 'Y') THEN
        gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'
                                 ||'Comparing Oprn and Routing Start Dates  '||
                                   'Routing Start Date = '||p_effective_start_date||
                                   ' Oprn Start Date  = '||l_oprn_start_date);
     END IF;
     IF l_oprn_start_date > p_effective_start_date THEN
       FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTING_DATE_IN_OPRN_DATE');
       FND_MSG_PUB.ADD;
       RETURN -1;
     END IF;

     IF (l_debug = 'Y') THEN
        gmd_debug.put_line(m_pkg_name||'.'||l_api_name||':'
                                ||'Comparing Oprn and Routing End Dates  '||
                                   'Routing end Date = '||
                                   p_effective_end_date||
                                   ' Oprn end Date  = '||l_oprn_end_date);
     END IF;
     IF (l_oprn_end_date IS NOT NULL) AND
               (p_effective_end_date IS NULL) THEN
       FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUT_EFF_END_DATE');
       FND_MSG_PUB.ADD;
       RETURN -1;
     END IF;

     IF l_oprn_end_date < p_effective_end_date THEN
       FND_MESSAGE.SET_NAME('GMD', 'GMD_ROUTING_DATE_IN_OPRN_DATE');
       FND_MSG_PUB.ADD;
       RETURN -1;
     END IF;
   END IF;
   CLOSE Get_oprn_start_end_dates;
   RETURN 1;
 END validate_dates;


END GMD_ROUTINGS_PVT;

/
