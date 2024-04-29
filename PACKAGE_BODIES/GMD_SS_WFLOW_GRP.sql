--------------------------------------------------------
--  DDL for Package Body GMD_SS_WFLOW_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_SS_WFLOW_GRP" AS
/* $Header: GMDSWFGB.pls 120.2 2006/04/12 12:17:44 mgrosser noship $ */

/*
--  Start of comments
--
--              Copyright (c) 2003 Oracle Corporation
--                 Redwood Shores, CA, USA
--                 All Rights Reserved
--
----------------------------------------------------------
--
--   File Name:         GMDSWFGB.pls
--   Package Name:      GMD_SS_WFLOW_GRP
--   Type:              Group
--   History     :
--
--  Saikiran Vankadari 19-May-04   Bug# 3583257. In the 'events_for_status_change' procedure,
--                                 sublot_no is assigned to p_sample before inserting the sample.
--                                 Also, Code is changed in such a way that for a particular variant,
--                                 retained samples are inserted after the timepoint samples
--                                 for that particular variant are inserted.
-- Saikiran Vankadari  29-Jun-04   Bug# 3729234. Assigning '0RT' to all dispositions instead of '1P' in the
--                                 'events_for_status_change' procedure
-- Saikiran Vankadari  16-Aug-05   Convergence Changes
-- M. Grosser 12-Apr-2006   BUG 4695552 - Modified procedures variant_retianed_sample  and events_for_status_change
--                          to pass revision for creation of samples and sampling events
-------------------------------------------------------- */

  FUNCTION  get_spec_vr_id
     ( p_spec_id        IN  number,
       p_created_by     IN  number)
      RETURN   number
    IS
    x_spec_vr_id        number;
    l_spec_vr_id        number;

   CURSOR c_get_spec_vr IS
   SELECT spec_vr_id
   FROM GMD_STABILITY_SPEC_VRS
   WHERE spec_id = p_spec_id;
   tp_vr        c_get_spec_vr%ROWTYPE;

   BEGIN
    OPEN c_get_spec_vr;
    FETCH c_get_spec_vr into x_spec_vr_id;
    IF c_get_spec_vr%NOTFOUND THEN
       select gmd.gmd_qc_spec_vr_id_s.NEXTVAL
       into x_spec_vr_id
       from dual;
  /*   insert into bfs_msg
       values
        ( 'NEW: spec_vr_id =  ' || x_spec_vr_id );
       commit;                 */
       INSERT INTO GMD_STABILITY_SPEC_VRS
       (
         SPEC_VR_ID
         ,SPEC_ID
         ,SPEC_VR_STATUS
         ,START_DATE
         ,DELETE_MARK
         ,CREATION_DATE
         ,CREATED_BY
         ,LAST_UPDATE_DATE
         ,LAST_UPDATED_BY )
         values (
          x_spec_vr_id
         ,p_spec_id
         ,700
         ,sysdate
         ,0
         ,sysdate
         ,p_created_by
         ,sysdate
         ,p_created_by
                             );
     END IF;


     RETURN x_spec_vr_id;
    END ;

   PROCEDURE variant_retained_sample
     ( p_variant_id        IN number,
       p_time_point_id     IN number,
       p_spec_id           IN number,
       x_sampling_event_id OUT NOCOPY number,
       x_return_status     OUT NOCOPY varchar2)
  IS
    p_sampling_event   GMD_SAMPLING_EVENTS%ROWTYPE;
    x_sampling_event   GMD_SAMPLING_EVENTS%ROWTYPE;
    p_event_spec_disp  GMD_EVENT_SPEC_DISP%ROWTYPE;
    x_event_spec_disp  GMD_EVENT_SPEC_DISP%ROWTYPE;

   CURSOR c_get_variant IS
   SELECT ss_id,
          sample_qty,
          sample_quantity_uom  --INVCONV
   FROM   GMD_SS_VARIANTS v
   WHERE  v.variant_id = p_variant_id;
   var_rec  c_get_variant%ROWTYPE;

   -- M. Grosser 12-Apr-2006   BUG 4695552 - Modified procedures variant_retianed_sample  and events_for_status_change
   --                          to pass revision for creation of samples and sampling events
   CURSOR c_get_ss IS
   SELECT inventory_item_id,
          revision,
          organization_id,
          created_by
   FROM   gmd_stability_studies ss
   WHERE  ss_id = var_rec.ss_id;
   ss_rec   c_get_ss%ROWTYPE;

   BEGIN
      x_return_status := 'S';
      OPEN c_get_variant;
      FETCH c_get_variant into var_rec;
      IF c_get_variant%FOUND THEN
         OPEN c_get_ss;
         FETCH c_get_ss into ss_rec;
         IF c_get_ss%FOUND THEN
            p_sampling_event.original_spec_vr_id :=
                get_spec_vr_id (p_spec_id,
                                ss_rec.created_by);
            p_sampling_event.disposition        := '1P';
        /*            p_sampling_event.event_type_code    := '';        */
       /*             p_sampling_event.event_id           :=  ;         */
            p_sampling_event.source             := 'T';
            p_sampling_event.inventory_item_id            := ss_rec.inventory_item_id; --INVCONV

            -- M. Grosser 12-Apr-2006   BUG 4695552 - Modified procedures variant_retianed_sample  and events_for_status_change
            --                          to pass revision for creation of samples and sampling events
            --
            p_sampling_event.revision            := ss_rec.revision;

            p_sampling_event.organization_id          := ss_rec.organization_id;   --INVCONV
            p_sampling_event.sample_type        := 'I';
            p_sampling_event.variant_id         := p_variant_id;

           /* magupta 2949364, time_point_id set to passed time point id */
            p_sampling_event.time_point_id         := p_time_point_id;
            --p_sampling_event.time_point_id      := NULL;
           /* magupta 2949364, time_point_id set to passed time point id */

            p_sampling_event.creation_date      := sysdate;
            p_sampling_event.created_by         := ss_rec.created_by;
            p_sampling_event.last_updated_by    := ss_rec.created_by;
            p_sampling_event.last_update_date   := sysdate;
            p_sampling_event.sample_taken_cnt   := 1;
            p_sampling_event.sample_req_cnt     := 1;
            --p_sampling_event.sample_active_cnt  := 1;
            p_sampling_event.sample_active_cnt  := 0;
            p_event_spec_disp.disposition       := '1P';
            p_event_spec_disp.spec_used_for_lot_attrib_ind  := 'Y';
            p_event_spec_disp.spec_id           := p_spec_id;
            p_event_spec_disp.spec_vr_id        :=
                    p_sampling_event.original_spec_vr_id;
            p_event_spec_disp.delete_mark   := 0;
            p_event_spec_disp.creation_date := sysdate;
            p_event_spec_disp.created_by    := ss_rec.created_by;
            p_event_spec_disp.last_update_date  := sysdate;
            p_event_spec_disp.last_updated_by   := ss_rec.created_by;
            IF not GMD_SAMPLING_EVENTS_PVT.insert_row (
                       p_sampling_event,
                       x_sampling_event ) THEN
                       raise fnd_api.g_exc_error;
            END IF;
            /*   insert into bfs_msg
                       values
                        ( 'sampling_event_id =  '||
                                x_sampling_event.sampling_event_id );
             commit;                                   */
             p_event_spec_disp.sampling_event_id  :=
                    x_sampling_event.sampling_event_id;
             x_sampling_event_id := x_sampling_event.sampling_event_id;
             IF not GMD_EVENT_SPEC_DISP_PVT.insert_row (
                       p_event_spec_disp,
                       x_event_spec_disp    ) THEN
                raise fnd_api.g_exc_error;
             END IF;
             /*   insert into bfs_msg
                       values
                      ( 'event_spec_disp_id =  '||
                        x_event_spec_disp.event_spec_disp_id );
             commit;        */
         END IF;
         CLOSE c_get_ss;
      END IF;
      CLOSE c_get_variant;
      RETURN;
  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := 'E';
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := 'U';
  WHEN OTHERS THEN
    x_return_status := 'E';
   END variant_retained_sample;








  PROCEDURE events_for_status_change
     ( p_ss_id          IN  number,
       x_return_status  OUT NOCOPY varchar2)
    IS
     l_status           number;
     l_spec_vr_id       number;
     l_msg              varchar2(100);
     p_sample           GMD_SAMPLES%ROWTYPE;
     x_sample           GMD_SAMPLES%ROWTYPE;
     p_sampling_event   GMD_SAMPLING_EVENTS%ROWTYPE;
     x_sampling_event   GMD_SAMPLING_EVENTS%ROWTYPE;
     p_event_spec_disp  GMD_EVENT_SPEC_DISP%ROWTYPE;
     x_event_spec_disp  GMD_EVENT_SPEC_DISP%ROWTYPE;
     p_sample_spec_disp  GMD_SAMPLE_SPEC_DISP%ROWTYPE;
     x_sample_spec_disp  GMD_SAMPLE_SPEC_DISP%ROWTYPE;

    -- M. Grosser 12-Apr-2006   BUG 4695552 - Modified procedures variant_retianed_sample and events_for_status_change
    --                          to pass revision for creation of samples and sampling events
    --
    --modified for INVCONV
   CURSOR c_get_ss   IS
      SELECT inventory_item_id,
             status,
             organization_id,
             lab_organization_id,
             created_by,
             last_updated_by,
             revision
      FROM  GMD_STABILITY_STUDIES_B
      WHERE ss_id = p_ss_id;
   ss_rec       c_get_ss%ROWTYPE;

   --modified for INVCONV
   CURSOR c_get_ms IS
      SELECT a.source_id,
             a.source_organization_id,
             a.batch_id,
             a.recipe_id,
             a.recipe_no,
             a.lot_number,
             a.sampling_event_id
      FROM  GMD_SS_MATERIAL_SOURCES a
      WHERE ss_id = p_ss_id;


   --modified for INVCONV
   mat_rec   c_get_ms%ROWTYPE;
   CURSOR c_get_var IS
      SELECT variant_id,
             variant_no,
             samples_per_time_point,
             retained_samples,
             default_spec_id,
/*            default_spec_vr_id,       */
             sample_qty,
             sample_quantity_uom
      FROM   GMD_SS_VARIANTS
      WHERE  material_source_id = mat_rec.source_id;

   var_rec  c_get_var%ROWTYPE;
   CURSOR c_get_tp IS
   SELECT time_point_id,
          spec_id,
          scheduled_date,
          samples_per_time_point
   FROM   GMD_SS_TIME_POINTS tp
   WHERE  tp.variant_id = var_rec.variant_id ;
   tp_rec   c_get_tp%ROWTYPE;

   CURSOR cr_sampling_event_created IS
       SELECT 'X' FROM gmd_ss_variants gsv
       where gsv.ss_id = p_ss_id
       and exists
       ( select 'x' from gmd_sampling_events gse
         where gse.variant_id = gsv.variant_id ) ;

   l_temp   VARCHAR2(1);

   BEGIN
      x_return_status := 'S';

-- Mahesh.
-- If samples are created , don't create it again.
-- this API is called from lot of places ( workflow , stability study form , eres workflow )
-- just making sure in case it is called twice, samples are not created again.

     OPEN  cr_sampling_event_created ;
     FETCH cr_sampling_event_created into l_temp ;
     IF cr_sampling_event_created%FOUND THEN
         CLOSE cr_sampling_event_created;
         RETURN ;
     END IF;
     CLOSE cr_sampling_event_created ;

      OPEN c_get_ss ;
      FETCH c_get_ss into ss_rec;
      /*   insert into bfs_msg
      values
      ( 'p_ss_id = ' || p_ss_id);   */
      /*   insert into bfs_msg
      values
      ( 'ss_rec.item_id = '|| ss_rec.item_id );
      commit;       */
  /* need to change to status = 400         */
      IF ss_rec.status > 0
      THEN
         OPEN c_get_ms;
         FETCH c_get_ms into mat_rec;
         WHILE c_get_ms%FOUND LOOP

            p_sample.lot_number         := mat_rec.lot_number; --INVCONV


            IF mat_rec.sampling_event_id is null THEN
                IF mat_rec.lot_number is not null THEN
/*
--   Material source has a lot number therefore, a
--   Create Sample workflow notification is generated */
                    gmd_api_pub.RAISE (
                       'oracle.apps.gmd.qm.ss.lot',
                       to_char(mat_rec.source_id,9999999999 ));
                   /*   insert into bfs_msg
                   values
                      ( 'Create Sample workflow notification=  ' ||
                       to_char(mat_rec.source_id,9999999999) );
                   commit;          */
                ELSE
/*
--   Material source needs to be produced, a Create Batch
--   workflow notification is generated             */
                   gmd_api_pub.RAISE (
                       'oracle.apps.gmd.qm.ss.batch.cr',
                       mat_rec.source_id );
                   /*   insert into bfs_msg
                   values
                      ( 'Create Batch workflow notification=  '||
                       mat_rec.source_id);
                   commit;                      */
                END IF;
            END IF;
/*            ELSE                  this is for status not correct */
/*
--   The material source has a lot and corresponding
--   sampling event.  Therefore, the time point samples
--   can be created.                                    */
                /*   insert into bfs_msg
                values
                    ('creating time point samples');
                commit;             */
/*
--   Retrieve the material source's corresponding variants  */
                OPEN c_get_var;
                FETCH c_get_var into var_rec;
                WHILE c_get_var%FOUND LOOP
                   /*   insert into bfs_msg
                    values
                    ('Varint_id = '|| var_rec.variant_id);
                    commit;                 */
                    p_sampling_event.original_spec_vr_id := l_spec_vr_id;
                    --Bug# 3729234. Assigning '0RT' to p_sampling_event.disposition instead of '1P'
		    --p_sampling_event.disposition        := '1P';
		    p_sampling_event.disposition        := '0RT';
        /*            p_sampling_event.event_type_code    := '';        */
       /*             p_sampling_event.event_id           :=  ;         */
                    p_sampling_event.source             := 'T';
                    p_sampling_event.inventory_item_id            := ss_rec.inventory_item_id;  --INVCONV

                    -- M. Grosser 12-Apr-2006   BUG 4695552 - Modified procedures variant_retianed_sample  and events_for_status_change
                    --                          to pass revision for creation of samples and sampling events
                    --
                    p_sampling_event.revision          := ss_rec.revision;

                    p_sampling_event.organization_id          := ss_rec.organization_id;  --INVCONV
                    p_sampling_event.sample_type        := 'I';
                    p_sampling_event.variant_id         := var_rec.variant_id;
                    p_sampling_event.time_point_id      := NULL;
                    p_sampling_event.creation_date      := sysdate;
                    p_sampling_event.created_by         := ss_rec.created_by;
                    p_sampling_event.last_updated_by    := ss_rec.created_by;
                    p_sampling_event.last_update_date   := sysdate;
                    p_sample.sample_type        := 'I';
                    p_sample.lab_organization_id   := ss_rec.lab_organization_id;  --INVCONV
                    p_sample.inventory_item_id            := ss_rec.inventory_item_id; --INVCONV

                    -- M. Grosser 12-Apr-2006   BUG 4695552 - Modified procedures variant_retianed_sample and events_for_status_change
                    --                          to pass revision for creation of samples and sampling events
                    --
                    p_sample.revision          := ss_rec.revision;

                    p_sample.sample_qty         := var_rec.sample_qty;
                    p_sample.sample_qty_uom         := var_rec.sample_quantity_uom; --INVCONV
                    p_sample.source             := 'T';
                    p_sample.date_drawn         := sysdate;
                    p_sample.priority           := '5N';
                    p_sample.delete_mark        := 0;
                    p_sample.sampler_id         := ss_rec.created_by;
                    p_sample.creation_date      := sysdate;
                    p_sample.created_by         := ss_rec.created_by;
                    p_sample.last_update_date   := sysdate;
                    p_sample.last_updated_by    := ss_rec.created_by;
                    p_sample.organization_id    := ss_rec.organization_id; --INVCONV
                    p_sample.variant_id         := var_rec.variant_id;
                    p_sample.time_point_id      := NULL;
                    --Bug# 3729234. Assigning '0RT' to p_sample.sample_disposition instead of '1P'
		    --p_sample.sample_disposition := '1P';
		    p_sample.sample_disposition := '0RT';
                    --Bug# 3729234. Assigning '0RT' to p_event_spec_disp.disposition instead of '1P'
		    --p_event_spec_disp.disposition   := '1P';
		    p_event_spec_disp.disposition   := '0RT';
                    p_event_spec_disp.spec_used_for_lot_attrib_ind  := 'Y';
                    p_event_spec_disp.delete_mark   := 0;
                    p_event_spec_disp.creation_date := sysdate;
                    p_event_spec_disp.created_by    := ss_rec.created_by;
                    p_event_spec_disp.last_update_date  := sysdate;
                    p_event_spec_disp.last_updated_by   := ss_rec.created_by;
                    p_sample_spec_disp.delete_mark   := 0;
                    p_sample_spec_disp.creation_date := sysdate;
                    p_sample_spec_disp.created_by    := ss_rec.created_by;
                    p_sample_spec_disp.last_update_date  := sysdate;
                    p_sample_spec_disp.last_updated_by   := ss_rec.created_by;
------------------------------------------------------------------------------------------------------------------
--Bug#3583257. moved the piece of code (to insert retained samples) to a different place
/*
--create variant Reserved samples
                    IF var_rec.retained_samples > 0 THEN
                       p_sampling_event.sample_taken_cnt  :=
                                 var_rec.retained_samples;
                       p_sampling_event.sample_req_cnt    :=
                                 var_rec.retained_samples;
                       --p_sampling_event.sample_active_cnt := var_rec.retained_samples;
                       p_sampling_event.sample_active_cnt := 0;
                       IF not GMD_SAMPLING_EVENTS_PVT.insert_row (
                       p_sampling_event,
                       x_sampling_event ) THEN
                       raise fnd_api.g_exc_error;
                       END IF;
                       --   insert into bfs_msg
                       --values
                       -- ( 'Var: sampling_event_id =  '||
                       --         x_sampling_event.sampling_event_id );
                       --commit;
   --    GMD_SS_VARIANTS is updated with the sampling_event_id for the
   --    Variant's retained samples.  The variant's retained samples are
   --    associated with the same sampling event.
                       UPDATE gmd_ss_variants
                       set sampling_event_id =
                                x_sampling_event.sampling_event_id
                       WHERE variant_id = var_rec.variant_id;
                       p_event_spec_disp.sampling_event_id   :=
                                x_sampling_event.sampling_event_id;
                       p_sample.sampling_event_id   :=
                                x_sampling_event.sampling_event_id;
                       IF not GMD_EVENT_SPEC_DISP_PVT.insert_row (
                           p_event_spec_disp,
                           x_event_spec_disp    ) THEN
                       raise fnd_api.g_exc_error;
                       END IF;
                       --   insert into bfs_msg
                       --values
                       --( 'Var: event_spec_disp_id =  '||
                       -- x_event_spec_disp.event_spec_disp_id );
                       --commit;
                       p_sample_spec_disp.event_spec_disp_id :=
                                x_event_spec_disp.event_spec_disp_id;
                       p_sample_spec_disp.disposition        := '1P';
                       FOR smp_cnt in 1..var_rec.retained_samples LOOP
                           p_sample.sample_no          :=
                            GMA_GLOBAL_GRP.Get_Doc_No('SMPL', ss_rec.orgn_code);
                           --   insert into bfs_msg
                           --values
                           --(' sample_no  = ' || p_sample.sample_no );
                          --commit;

                          l_msg := NULL;
                          fnd_message.set_name('GMD','GMD_SS_VARIANT_SAMPLE_DESC');
                          fnd_message.set_token('VARIANT', var_rec.variant_no);
                          fnd_message.set_token('INST', smp_cnt);
                          l_msg := fnd_message.get;

                          p_sample.sample_desc        := l_msg;
                          p_sample.sample_instance    := smp_cnt;
                          IF not GMD_SAMPLES_PVT.insert_row (
                                 p_sample,
                                 x_sample )      THEN
                            raise fnd_api.g_exc_error;
                          END IF;
                          p_sample_spec_disp.sample_id  := x_sample.sample_id;
                          --   insert into bfs_msg
                          -- values
                          -- (' sample_id  = ' || x_sample.sample_id );
                          --commit;
                          IF not GMD_SAMPLE_SPEC_DISP_PVT.insert_row  (
                            p_sample_spec_disp  )    THEN
                          raise fnd_api.g_exc_error;
                          END IF;
                        --   insert into bfs_msg
                       --values
                       --(' Sample Spec: sample_id  = ' || x_sample.sample_id );
                       --commit;
                    END LOOP; --  Loop to create sample for number of s-per-
                    END IF;   --  Loop var_rec.retained_samples > 0

                    */

--------------------------------------------------------------------------------------------------------------------
 /*  Get Time Point data and create a sampling event for each Time Point */
                    OPEN c_get_tp;
                    FETCH c_get_tp into tp_rec;
                    WHILE c_get_tp%FOUND LOOP
                       /*   insert into bfs_msg
                       values
                        ( ' time_point_id =  ' ||
                            tp_rec.time_point_id  );
                       commit;              */
                       l_spec_vr_id := get_spec_vr_id (tp_rec.spec_id,
                                        ss_rec.created_by);
                       p_sampling_event.sample_taken_cnt  :=
                                 tp_rec.samples_per_time_point;
                       p_sampling_event.sample_req_cnt    :=
                                 tp_rec.samples_per_time_point;
                       --p_sampling_event.sample_active_cnt    := tp_rec.samples_per_time_point;
                       p_sampling_event.sample_active_cnt    := 0;
                       p_sampling_event.time_point_id      :=
                                 tp_rec.time_point_id;
                       p_sample.time_point_id      := tp_rec.time_point_id;

                    IF not GMD_SAMPLING_EVENTS_PVT.insert_row (
                       p_sampling_event,
                       x_sampling_event ) THEN
                       raise fnd_api.g_exc_error;
                    END IF;
                    /*   insert into bfs_msg
                    values
                        ( 'sampling_event_id =  '||
                                x_sampling_event.sampling_event_id );
                    commit;                         */
 /*    GMD_SS_VARIANTS is updated with the sampling_event_id for the
   --    Variant's retained samples.  The variant's retained samples are
   --    associated with the same sampling event.                        */
                    UPDATE gmd_ss_time_points
                    set sampling_event_id =
                                x_sampling_event.sampling_event_id
                    WHERE time_point_id = tp_rec.time_point_id;
                    p_sample.sampling_event_id  :=
                                            x_sampling_event.sampling_event_id;
                    p_event_spec_disp.sampling_event_id  :=
                                            x_sampling_event.sampling_event_id;
                    p_event_spec_disp.spec_id       :=  tp_rec.spec_id;
                    p_event_spec_disp.spec_vr_id    :=  l_spec_vr_id;

                    IF not GMD_EVENT_SPEC_DISP_PVT.insert_row (
                       p_event_spec_disp,
                       x_event_spec_disp    ) THEN
                       raise fnd_api.g_exc_error;
                    END IF;
                    /*   insert into bfs_msg
                    values
                    ( 'event_spec_disp_id =  '||
                        x_event_spec_disp.event_spec_disp_id );
                    commit;                         */
                    p_sample_spec_disp.event_spec_disp_id :=
                                x_event_spec_disp.event_spec_disp_id;
                    --Bug# 3729234. Assigning '0RT' to p_sample_spec_disp.disposition instead of '1P'
		    --p_sample_spec_disp.disposition        := '1P';
		    p_sample_spec_disp.disposition        := '0RT';
                    FOR tp_cnt in 1..tp_rec.samples_per_time_point LOOP
                       /*   insert into bfs_msg
                        values
                        ('time_point_id = '|| tp_rec.time_point_id ||
                        '  tp_cnt=  '||tp_cnt);
                        commit;                     */
/*   Check if spec vr exists for TP for ss_id, variant_id, time_point_id,
--  if not, create the spec vr                                          */
                       p_sample.sample_no :=
                       GMD_QUALITY_PARAMETERS_GRP.get_next_sample_no(p_organization_id => ss_rec.organization_id); --INVCONV
                       /*   insert into bfs_msg
                       values
                       (' sample_no  = ' || p_sample.sample_no );
                       commit;                      */
                       l_msg := NULL;
                       fnd_message.set_name('GMD','GMD_SS_TP_SAMPLE_DESC');
                       fnd_message.set_token('VARIANT', var_rec.variant_no);
                       fnd_message.set_token('TIMEPOINT', tp_cnt);
                       l_msg := fnd_message.get;
                       p_sample.sample_desc        := l_msg;
                       p_sample.sample_instance    := tp_cnt;
                    IF not GMD_SAMPLES_PVT.insert_row (
                            p_sample,
                            x_sample )      THEN
                       raise fnd_api.g_exc_error;
                    END IF;
                     /*   insert into bfs_msg
                       values
                       (' sample_id  = ' || x_sample.sample_id );
                       commit;                      */
                    p_sample_spec_disp.sample_id  := x_sample.sample_id;
                    IF not GMD_SAMPLE_SPEC_DISP_PVT.insert_row  (
                            p_sample_spec_disp  )    THEN
                       raise fnd_api.g_exc_error;

                    END IF;
                    /*   insert into bfs_msg
                       values
                       (' sample_id  = ' || x_sample.sample_id );
                       commit;                      */
                    END LOOP;
                    FETCH c_get_tp into tp_rec;
       /*           CLOSE c_get_tp_spec_vr; */
                    END LOOP;
                 CLOSE c_get_tp;
--------------------------------------------------------------------------------------------------------------------
--Bug#3583257. moved the piece of code (to insert retained samples) from a different place to here
/* create variant Reserved samples */
                    IF var_rec.retained_samples > 0 THEN
                       p_sampling_event.sample_taken_cnt  :=
                                 var_rec.retained_samples;
                       p_sampling_event.sample_req_cnt    :=
                                 var_rec.retained_samples;
                       --p_sampling_event.sample_active_cnt := var_rec.retained_samples;
                       p_sampling_event.sample_active_cnt := 0;

		       --Bug#3583257
		       p_sampling_event.time_point_id      := NULL;

                       IF not GMD_SAMPLING_EVENTS_PVT.insert_row (
                       p_sampling_event,
                       x_sampling_event ) THEN
                       raise fnd_api.g_exc_error;
                       END IF;
                       /*   insert into bfs_msg
                       values
                        ( 'Var: sampling_event_id =  '||
                                x_sampling_event.sampling_event_id );
                       commit;                  */
   /*    GMD_SS_VARIANTS is updated with the sampling_event_id for the
   --    Variant's retained samples.  The variant's retained samples are
   --    associated with the same sampling event.                        */
                       UPDATE gmd_ss_variants
                       set sampling_event_id =
                                x_sampling_event.sampling_event_id
                       WHERE variant_id = var_rec.variant_id;
                       p_event_spec_disp.sampling_event_id   :=
                                x_sampling_event.sampling_event_id;
                       p_sample.sampling_event_id   :=
                                x_sampling_event.sampling_event_id;
                       IF not GMD_EVENT_SPEC_DISP_PVT.insert_row (
                           p_event_spec_disp,
                           x_event_spec_disp    ) THEN
                       raise fnd_api.g_exc_error;
                       END IF;
                       /*   insert into bfs_msg
                       values
                      ( 'Var: event_spec_disp_id =  '||
                        x_event_spec_disp.event_spec_disp_id );
                       commit;                  */
                       p_sample_spec_disp.event_spec_disp_id :=
                                x_event_spec_disp.event_spec_disp_id;
                       --Bug# 3729234. Assigning '0RT' to p_sample_spec_disp.disposition instead of '1P'
		       --p_sample_spec_disp.disposition        := '1P';
                       p_sample_spec_disp.disposition        := '0RT';
                       FOR smp_cnt in 1..var_rec.retained_samples LOOP
                           p_sample.sample_no  :=
                           GMD_QUALITY_PARAMETERS_GRP.get_next_sample_no(p_organization_id => ss_rec.organization_id); --INVCONV

                           /*   insert into bfs_msg
                           values
                           (' sample_no  = ' || p_sample.sample_no );
                          commit;                   */

                          l_msg := NULL;
                          fnd_message.set_name('GMD','GMD_SS_VARIANT_SAMPLE_DESC');
                          fnd_message.set_token('VARIANT', var_rec.variant_no);
                          fnd_message.set_token('INST', smp_cnt);
                          l_msg := fnd_message.get;

                          p_sample.sample_desc        := l_msg;
                          p_sample.sample_instance    := smp_cnt;

                          p_sample.time_point_id      := NULL; --Bug#3583257

                          IF not GMD_SAMPLES_PVT.insert_row (
                                 p_sample,
                                 x_sample )      THEN
                            raise fnd_api.g_exc_error;
                          END IF;
                          p_sample_spec_disp.sample_id  := x_sample.sample_id;
                          /*   insert into bfs_msg
                           values
                           (' sample_id  = ' || x_sample.sample_id );
                          commit;                       */
                          IF not GMD_SAMPLE_SPEC_DISP_PVT.insert_row  (
                            p_sample_spec_disp  )    THEN
                          raise fnd_api.g_exc_error;
                          END IF;
                        /*   insert into bfs_msg
                       values
                       (' Sample Spec: sample_id  = ' || x_sample.sample_id );
                       commit;                              */
                    END LOOP; /*  Loop to create sample for number of s-per- */
                    END IF;   /*  Loop var_rec.retained_samples > 0          */


----------------------------------------------------------------------------------------------------------------------

                   FETCH c_get_var into var_rec;
               END LOOP;
               CLOSE c_get_var;
            FETCH c_get_ms into mat_rec;
         END LOOP;
         CLOSE c_get_ms;
      CLOSE c_get_ss;
      COMMIT;
    END IF;
  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := 'E';
    gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE',
        'GMD_SS_WFLOW_GRP.events_for_status_change',
        'ERROR', SUBSTR(SQLERRM,1,100),
        'POSITION',null);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := 'U';
    gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE',
        'GMD_SS_WFLOW_GRP.events_for_status_change',
        'ERROR',
        SUBSTR(SQLERRM,1,100),'POSITION',null);
  WHEN OTHERS THEN
    x_return_status := 'E';
    gmd_api_pub.log_message('GMD_API_ERROR','PACKAGE',
        'GMD_SS_WFLOW_GRP.events_for_status_change',
        'ERROR',
        SUBSTR(SQLERRM,1,100),'POSITION',null);
   END events_for_status_change;
END GMD_SS_WFLOW_GRP;



/
