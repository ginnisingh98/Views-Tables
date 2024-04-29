--------------------------------------------------------
--  DDL for Package Body GMD_ROUT_MIGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_ROUT_MIGRATION" AS
/* $Header: GMDRTMGB.pls 120.3 2005/10/13 12:54:54 kshukla noship $  pxkumar*/

  PROCEDURE  INSERT_ROUT_STATUS IS
    /*Cursor to get all the routing information */
    CURSOR Cur_routing IS
      SELECT *
      FROM   gmd_routings_b r
      WHERE  EXISTS (Select 1
                     from   gmd_routings_b
                     Where  routing_id = r.routing_id AND
                            routing_status  IS NULL)
      ORDER BY routing_id;

    CURSOR Cur_formula_Id(prouting_id NUMBER) IS
      SELECT formula_Id
      FROM   fm_form_eff_bak
      WHERE  routing_Id = prouting_id;

      l_orgn_code       VARCHAR2(6);
      l_routing_status  GMD_STATUS.status_code%TYPE;
      l_formula_id      NUMBER;
      l_return_val      NUMBER;
      error_msg         VARCHAR2(240);

  BEGIN
   FOR rout_rec IN Cur_routing LOOP
     BEGIN
      l_orgn_code :=  fnd_profile.value_specific
                                 ('GEMMS_DEFAULT_ORGN',rout_rec.created_by);

      /* Function to get routing status */
      OPEN  Cur_formula_id(rout_rec.routing_id);
      FETCH Cur_formula_Id INTO l_formula_id;
         IF Cur_formula_ID%NOTFOUND THEN
            l_Formula_Id := 0;
            CLOSE Cur_formula_id;
         END IF;
         l_return_val := GMDFMVAL_PUB.locked_effectivity_val(l_formula_id);
         IF (l_return_val <> 0) THEN
            l_routing_status := '900';
         ELSE
            l_routing_status := '700';
         END IF;
      CLOSE Cur_formula_id;

      /* If the routing is inactive or it is marked for purge
         then we make it obsoleted */
      IF ((rout_rec.inactive_ind = 1) OR (rout_rec.delete_mark = 1)) THEN
         l_routing_status := '1000';
      END IF;

      UPDATE  gmd_routings_b
         SET  process_loss            = 0,
              effective_start_date    = rout_rec.creation_date ,
              effective_end_date      = NULL,
              owner_id                = rout_rec.created_by,
              project_id              = null,
              routing_status          = l_routing_status,
              owner_orgn_code         = l_orgn_code
       WHERE  routing_id = rout_rec.routing_id ;
      EXCEPTION
        WHEN OTHERS THEN
          error_msg := SQLERRM;
          GMD_RECIPE_MIGRATION.insert_message (p_source_table => 'FM_ROUT_HDR'
                                   ,p_target_table => 'GMD_ROUTINGS_B'
                                   ,p_source_id    => rout_rec.routing_id
                                   ,p_target_id    => rout_rec.routing_id
                                   ,p_message      => error_msg
                                   ,p_error_type   => 'U');

       END; /* Prior to end loop */
    END LOOP ;
  END INSERT_ROUT_STATUS;

  --BEGIN Bug#2200539 P.Raghu
  PROCEDURE  INSERT_TRANSFER_PERCENT IS
  /* Procedure to update transfer_percent column to 100% in fm_rout_dep table */
  BEGIN
    UPDATE Fm_Rout_Dep
    SET Transfer_Pct = 100
    WHERE transfer_pct IS NULL;

    update fm_rout_dep
    set max_delay = NULL
    where max_delay = 0;
  END INSERT_TRANSFER_PERCENT;
  --END Bug#2200539

END GMD_ROUT_MIGRATION;

/
