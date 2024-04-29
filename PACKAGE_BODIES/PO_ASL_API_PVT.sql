--------------------------------------------------------
--  DDL for Package Body PO_ASL_API_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ASL_API_PVT" AS
/* $Header: PO_ASL_API_PVT.plb 120.2.12010000.2 2014/04/01 09:30:57 vpeddi noship $*/

g_session_key   NUMBER;

--------------------------------------------------------------------------------
  --Start of Comments

  --Name: process

  --Function:
  --  It will create / update records in the base tables for the non rejected
  --  records in the gt tables.

  --Parameters:

  --IN:
  --  p_session_key       NUMBER

  --OUT:
  --  x_return_status     VARCHAR2
  --  x_return_msg        VARCHAR2

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE process(
  p_session_key     IN         NUMBER
, x_return_status   OUT NOCOPY VARCHAR2
, x_return_msg      OUT NOCOPY VARCHAR2
)
IS
l_progress NUMBER := 0;

BEGIN
  PO_ASL_API_PVT.Log('START ::: PO_ASL_API_PVT.process ');
  PO_ASL_API_PVT.Log('p_session_key:' || p_session_key);
  g_session_key := p_session_key;
  --create/update/delete records in the base tables for the non rejected
  --records in the gt tables.

  ------------------------------CREATE MODE starts------------------------------
  INSERT INTO po_approved_supplier_list
  (  asl_id                          ,
     using_organization_id           ,
     owning_organization_id          ,
     vendor_business_type            ,
     asl_status_id                   ,
     last_update_date                ,
     last_updated_by                 ,
     creation_date                   ,
     created_by                      ,
     manufacturer_id                 ,
     vendor_id, item_id              ,
     category_id                     ,
     vendor_site_id                  ,
     primary_vendor_item             ,
     manufacturer_asl_id             ,
     review_by_date                  ,
     comments                        ,
     attribute_category              ,
     attribute1                      ,
     attribute2                      ,
     attribute3                      ,
     attribute4                      ,
     attribute5                      ,
     attribute6                      ,
     attribute7                      ,
     attribute8                      ,
     attribute9                      ,
     attribute10                     ,
     attribute11                     ,
     attribute12                     ,
     attribute13                     ,
     attribute14                     ,
     attribute15                     ,
     last_update_login               ,
     request_id                      ,
     program_application_id          ,
     program_id                      ,
     program_update_date             ,
     disable_flag
  )
  (SELECT
     asl_id                          ,
     using_organization_id           ,
     owning_organization_id          ,
     Upper(vendor_business_type)     ,
     asl_status_id                   ,
     SYSDATE                         ,
     fnd_global.USER_ID              ,
     SYSDATE                         ,
     fnd_global.USER_ID              ,
     manufacturer_id                 ,
     vendor_id, item_id              ,
     category_id                     ,
     vendor_site_id                  ,
     primary_vendor_item             ,
     manufacturer_asl_id             ,
     review_by_date                  ,
     comments                        ,
     attribute_category              ,
     attribute1                      ,
     attribute2                      ,
     attribute3                      ,
     attribute4                      ,
     attribute5                      ,
     attribute6                      ,
     attribute7                      ,
     attribute8                      ,
     attribute9                      ,
     attribute10                     ,
     attribute11                     ,
     attribute12                     ,
     attribute13                     ,
     attribute14                     ,
     attribute15                     ,
     fnd_global.LOGIN_ID             ,
     request_id                      ,
     program_application_id          ,
     program_id                      ,
     program_update_date             ,
     Decode(disable_flag,'Y','Y','N')
     FROM  po_approved_supplier_list_gt
     WHERE process_action = PO_ASL_API_PUB.g_ACTION_CREATE AND
           process_status <> PO_ASL_API_PVT.g_STATUS_REJECTED
  );
  po_asl_api_pvt.log('number of rows inserted into po_approved_supplier_list:'
                      || SQL%ROWCOUNT);
  l_progress := 10;

  INSERT INTO po_asl_attributes
  (  asl_id                          ,
     using_organization_id           ,
     last_update_date                ,
     last_updated_by                 ,
     creation_date                   ,
     created_by                      ,
     document_sourcing_method        ,
     release_generation_method       ,
     purchasing_unit_of_measure      ,
     enable_plan_schedule_flag       ,
     enable_ship_schedule_flag       ,
     plan_schedule_type              ,
     ship_schedule_type              ,
     plan_bucket_pattern_id          ,
     ship_bucket_pattern_id          ,
     enable_autoschedule_flag        ,
     scheduler_id                    ,
     enable_authorizations_flag      ,
     vendor_id                       ,
     vendor_site_id                  ,
     item_id                         ,
     category_id                     ,
     attribute_category              ,
     attribute1                      ,
     attribute2                      ,
     attribute3                      ,
     attribute4                      ,
     attribute5                      ,
     attribute6                      ,
     attribute7                      ,
     attribute8                      ,
     attribute9                      ,
     attribute10                     ,
     attribute11                     ,
     attribute12                     ,
     attribute13                     ,
     attribute14                     ,
     attribute15                     ,
     last_update_login               ,
     request_id                      ,
     program_application_id          ,
     program_id                      ,
     program_update_date             ,
     price_update_tolerance          ,
     processing_lead_time            ,
     min_order_qty                   ,
     fixed_lot_multiple              ,
     delivery_calendar               ,
     country_of_origin_code          ,
     enable_vmi_flag                 ,
     vmi_min_qty                     ,
     vmi_max_qty                     ,
     enable_vmi_auto_replenish_flag  ,
     vmi_replenishment_approval      ,
     consigned_from_supplier_flag    ,
     last_billing_date               ,
     consigned_billing_cycle         ,
     consume_on_aging_flag           ,
     aging_period                    ,
     replenishment_method            ,
     vmi_min_days                    ,
     vmi_max_days                    ,
     fixed_order_quantity            ,
     forecast_horizon
  )
  (SELECT
     asl_id                          ,
     using_organization_id           ,
     SYSDATE                         ,
     fnd_global.USER_ID              ,
     SYSDATE                         ,
     fnd_global.USER_ID              ,
     document_sourcing_method        ,
     release_generation_method       ,
     purchasing_unit_of_measure_dsp  ,
     Decode(enable_plan_schedule_flag_dsp,'Y','Y','N')   ,
     Decode(enable_ship_schedule_flag_dsp,'Y','Y','N')   ,
     plan_schedule_type              ,
     ship_schedule_type              ,
     plan_bucket_pattern_id          ,
     ship_bucket_pattern_id          ,
     Decode(enable_autoschedule_flag_dsp,'Y','Y','N')    ,
     scheduler_id                    ,
     Decode(enable_authorizations_flag_dsp,'Y','Y','N')  ,
     vendor_id                       ,
     vendor_site_id                  ,
     item_id                         ,
     category_id                     ,
     attribute_category              ,
     attribute1                      ,
     attribute2                      ,
     attribute3                      ,
     attribute4                      ,
     attribute5                      ,
     attribute6                      ,
     attribute7                      ,
     attribute8                      ,
     attribute9                      ,
     attribute10                     ,
     attribute11                     ,
     attribute12                     ,
     attribute13                     ,
     attribute14                     ,
     attribute15                     ,
     fnd_global.LOGIN_ID             ,
     request_id                      ,
     program_application_id          ,
     program_id                      ,
     program_update_date             ,
     price_update_tolerance_dsp      ,
     processing_lead_time_dsp        ,
     min_order_qty_dsp               ,
     fixed_lot_multiple_dsp          ,
     delivery_calendar_dsp           ,
     country_of_origin_code_dsp      ,
     Decode(enable_vmi_flag_dsp,'Y','Y','N')             ,
     vmi_min_qty_dsp                 ,
     vmi_max_qty_dsp                 ,
     Decode(enable_vmi_auto_replenish_flag,'Y','Y','N')  ,
     vmi_replenishment_approval      ,
     Decode(consigned_from_supp_flag_dsp,'Y','Y','N')    ,
     last_billing_date               ,
     consigned_billing_cycle_dsp     ,
     Decode(consume_on_aging_flag_dsp,'Y','Y','N')       ,
     aging_period_dsp                ,
     replenishment_method            ,
     vmi_min_days_dsp                ,
     vmi_max_days_dsp                ,
     fixed_order_quantity_dsp        ,
     forecast_horizon_dsp
     FROM  po_asl_attributes_gt
     WHERE user_key IN
           (SELECT  user_key
              FROM  po_approved_supplier_list_gt
              WHERE process_status <> PO_ASL_API_PVT.g_STATUS_REJECTED) AND
           process_action          = PO_ASL_API_PUB.g_ACTION_ADD
  );
  po_asl_api_pvt.log('number of rows inserted into po_asl_attributes:'
                      || SQL%ROWCOUNT);
  l_progress := 15;

  INSERT INTO po_asl_attributes
  (  asl_id                          ,
     using_organization_id           ,
     last_update_date                ,
     last_updated_by                 ,
     creation_date                   ,
     created_by                      ,
     document_sourcing_method        ,
     release_generation_method       ,
     purchasing_unit_of_measure      ,
     enable_plan_schedule_flag       ,
     enable_ship_schedule_flag       ,
     plan_schedule_type              ,
     ship_schedule_type              ,
     plan_bucket_pattern_id          ,
     ship_bucket_pattern_id          ,
     enable_autoschedule_flag        ,
     scheduler_id                    ,
     enable_authorizations_flag      ,
     vendor_id                       ,
     vendor_site_id                  ,
     item_id                         ,
     category_id                     ,
     attribute_category              ,
     attribute1                      ,
     attribute2                      ,
     attribute3                      ,
     attribute4                      ,
     attribute5                      ,
     attribute6                      ,
     attribute7                      ,
     attribute8                      ,
     attribute9                      ,
     attribute10                     ,
     attribute11                     ,
     attribute12                     ,
     attribute13                     ,
     attribute14                     ,
     attribute15                     ,
     last_update_login               ,
     request_id                      ,
     program_application_id          ,
     program_id                      ,
     program_update_date             ,
     price_update_tolerance          ,
     processing_lead_time            ,
     min_order_qty                   ,
     fixed_lot_multiple              ,
     delivery_calendar               ,
     country_of_origin_code          ,
     enable_vmi_flag                 ,
     vmi_min_qty                     ,
     vmi_max_qty                     ,
     enable_vmi_auto_replenish_flag  ,
     vmi_replenishment_approval      ,
     consigned_from_supplier_flag    ,
     last_billing_date               ,
     consigned_billing_cycle         ,
     consume_on_aging_flag           ,
     aging_period                    ,
     replenishment_method            ,
     vmi_min_days                    ,
     vmi_max_days                    ,
     fixed_order_quantity            ,
     forecast_horizon
  )
  (SELECT
     asl_id                          ,
     using_organization_id           ,
     SYSDATE                         ,
     fnd_global.USER_ID              ,
     SYSDATE                         ,
     fnd_global.USER_ID              ,
     'ASL'                           ,
     NULL                            ,
     NULL                            ,
     'N'                             ,
     'N'                             ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     'N'                             ,
     NULL                            ,
     'N'                             ,
     NULL                            ,
     NULL                            ,
     item_id                         ,
     category_id                     ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     fnd_global.LOGIN_ID             ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL                            ,
     NULL
     FROM  po_approved_supplier_list_gt PASL
     WHERE PASL.process_status        <> PO_ASL_API_PVT.g_STATUS_REJECTED    AND
           PASL.process_action         = PO_ASL_API_PUB.g_ACTION_CREATE      AND
           (Upper(PASL.vendor_business_type) = 'MANUFACTURER'  OR
            NOT EXISTS
            (SELECT  PAA.user_key
               FROM  po_asl_attributes_gt PAA
               WHERE PAA.user_key  = PASL.user_key))
  );
  po_asl_api_pvt.log('number of DEFAULT rows inserted into po_asl_attributes:'
                      || SQL%ROWCOUNT);
  l_progress := 18;

  INSERT INTO po_asl_documents
  (  asl_id                          ,
     using_organization_id           ,
     sequence_num                    ,
     document_type_code              ,
     document_header_id              ,
     document_line_id                ,
     last_update_date                ,
     last_updated_by                 ,
     creation_date                   ,
     created_by                      ,
     attribute_category              ,
     attribute1                      ,
     attribute2                      ,
     attribute3                      ,
     attribute4                      ,
     attribute5                      ,
     attribute6                      ,
     attribute7                      ,
     attribute8                      ,
     attribute9                      ,
     attribute10                     ,
     attribute11                     ,
     attribute12                     ,
     attribute13                     ,
     attribute14                     ,
     attribute15                     ,
     last_update_login               ,
     request_id                      ,
     program_application_id          ,
     program_id                      ,
     program_update_date             ,
     org_id
  )
  (SELECT
     asl_id                          ,
     using_organization_id           ,
     sequence_num                    ,
     document_type_code              ,
     document_header_id              ,
     document_line_id                ,
     SYSDATE                         ,
     fnd_global.USER_ID              ,
     SYSDATE                         ,
     fnd_global.USER_ID              ,
     attribute_category              ,
     attribute1                      ,
     attribute2                      ,
     attribute3                      ,
     attribute4                      ,
     attribute5                      ,
     attribute6                      ,
     attribute7                      ,
     attribute8                      ,
     attribute9                      ,
     attribute10                     ,
     attribute11                     ,
     attribute12                     ,
     attribute13                     ,
     attribute14                     ,
     attribute15                     ,
     fnd_global.LOGIN_ID             ,
     request_id                      ,
     program_application_id          ,
     program_id                      ,
     program_update_date             ,
     org_id
     FROM po_asl_documents_gt
     WHERE user_key IN
           (SELECT  user_key
              FROM  po_approved_supplier_list_gt
              WHERE process_status     <> PO_ASL_API_PVT.g_STATUS_REJECTED)
                    AND process_action =  PO_ASL_API_PUB.g_ACTION_ADD
  );
  po_asl_api_pvt.log('number of rows inserted into po_asl_documents:'
                      || SQL%ROWCOUNT);
  l_progress := 20;

  INSERT INTO chv_authorizations
  (  reference_id                    ,
     reference_type                  ,
     authorization_code              ,
     authorization_sequence          ,
     last_update_date                ,
     last_updated_by                 ,
     creation_date                   ,
     created_by                      ,
     timefence_days                  ,
     attribute_category              ,
     attribute1                      ,
     attribute2                      ,
     attribute3                      ,
     attribute4                      ,
     attribute5                      ,
     attribute6                      ,
     attribute7                      ,
     attribute8                      ,
     attribute9                      ,
     attribute10                     ,
     attribute11                     ,
     attribute12                     ,
     attribute13                     ,
     attribute14                     ,
     attribute15                     ,
     last_update_login               ,
     request_id                      ,
     program_application_id          ,
     program_id                      ,
     program_update_date             ,
     using_organization_id
  )
  (SELECT
     reference_id                    ,
     reference_type                  ,
     authorization_code              ,
     authorization_sequence_dsp      ,
     SYSDATE                         ,
     fnd_global.USER_ID              ,
     SYSDATE                         ,
     fnd_global.USER_ID              ,
     timefence_days_dsp              ,
     attribute_category              ,
     attribute1                      ,
     attribute2                      ,
     attribute3                      ,
     attribute4                      ,
     attribute5                      ,
     attribute6                      ,
     attribute7                      ,
     attribute8                      ,
     attribute9                      ,
     attribute10                     ,
     attribute11                     ,
     attribute12                     ,
     attribute13                     ,
     attribute14                     ,
     attribute15                     ,
     fnd_global.LOGIN_ID             ,
     request_id                      ,
     program_application_id          ,
     program_id                      ,
     program_update_date             ,
     using_organization_id
     FROM  chv_authorizations_gt
     WHERE user_key IN
           (SELECT  user_key
              FROM  po_approved_supplier_list_gt
              WHERE process_status     <> PO_ASL_API_PVT.g_STATUS_REJECTED)
                    AND process_action =  PO_ASL_API_PUB.g_ACTION_ADD
  );
  po_asl_api_pvt.log('number of rows inserted into chv_authorizations:'
                      || SQL%ROWCOUNT);
  l_progress := 25;

  INSERT INTO po_supplier_item_capacity
  (  capacity_id                     ,
     asl_id                          ,
     using_organization_id           ,
     from_date                       ,
     To_Date                         ,
     capacity_per_day                ,
     last_update_date                ,
     last_updated_by                 ,
     creation_date                   ,
     created_by                      ,
     attribute_category              ,
     attribute1                      ,
     attribute2                      ,
     attribute3                      ,
     attribute4                      ,
     attribute5                      ,
     attribute6                      ,
     attribute7                      ,
     attribute8                      ,
     attribute9                      ,
     attribute10                     ,
     attribute11                     ,
     attribute12                     ,
     attribute13                     ,
     attribute14                     ,
     attribute15                     ,
     last_update_login               ,
     request_id                      ,
     program_application_id          ,
     program_id                      ,
     program_update_date
  )
  (SELECT
     capacity_id                     ,
     asl_id                          ,
     using_organization_id           ,
     from_date_dsp                   ,
     to_Date_dsp                     ,
     capacity_per_day_dsp            ,
     SYSDATE                         ,
     fnd_global.USER_ID              ,
     SYSDATE                         ,
     fnd_global.USER_ID              ,
     attribute_category              ,
     attribute1                      ,
     attribute2                      ,
     attribute3                      ,
     attribute4                      ,
     attribute5                      ,
     attribute6                      ,
     attribute7                      ,
     attribute8                      ,
     attribute9                      ,
     attribute10                     ,
     attribute11                     ,
     attribute12                     ,
     attribute13                     ,
     attribute14                     ,
     attribute15                     ,
     fnd_global.LOGIN_ID             ,
     request_id                      ,
     program_application_id          ,
     program_id                      ,
     program_update_date
     FROM  po_supplier_item_capacity_gt PSIC
     WHERE user_key IN
           (SELECT  user_key
              FROM  po_approved_supplier_list_gt
              WHERE process_status     <> PO_ASL_API_PVT.g_STATUS_REJECTED)
                    AND process_action =  PO_ASL_API_PUB.g_ACTION_ADD
  );
  po_asl_api_pvt.log('number of rows inserted into po_supplier_item_capacity:'
                      || SQL%ROWCOUNT);
  l_progress := 30;

  INSERT INTO po_supplier_item_tolerance
  (  asl_id                          ,
     using_organization_id           ,
     number_of_days                  ,
     tolerance                       ,
     last_update_date                ,
     last_updated_by                 ,
     creation_date                   ,
     created_by                      ,
     attribute_category              ,
     attribute1                      ,
     attribute2                      ,
     attribute3                      ,
     attribute4                      ,
     attribute5                      ,
     attribute6                      ,
     attribute7                      ,
     attribute8                      ,
     attribute9                      ,
     attribute10                     ,
     attribute11                     ,
     attribute12                     ,
     attribute13                     ,
     attribute14                     ,
     attribute15                     ,
     last_update_login               ,
     request_id                      ,
     program_application_id          ,
     program_id                      ,
     program_update_date
  )
  (SELECT
     asl_id                          ,
     using_organization_id           ,
     number_of_days_dsp              ,
     tolerance_dsp                   ,
     SYSDATE                         ,
     fnd_global.USER_ID              ,
     SYSDATE                         ,
     fnd_global.USER_ID              ,
     attribute_category              ,
     attribute1                      ,
     attribute2                      ,
     attribute3                      ,
     attribute4                      ,
     attribute5                      ,
     attribute6                      ,
     attribute7                      ,
     attribute8                      ,
     attribute9                      ,
     attribute10                     ,
     attribute11                     ,
     attribute12                     ,
     attribute13                     ,
     attribute14                     ,
     attribute15                     ,
     fnd_global.LOGIN_ID             ,
     request_id                      ,
     program_application_id          ,
     program_id                      ,
     program_update_date
     FROM  po_supplier_item_tolerance_gt
     WHERE user_key IN
           (SELECT  user_key
              FROM  po_approved_supplier_list_gt
              WHERE process_status     <> PO_ASL_API_PVT.g_STATUS_REJECTED)
                    AND process_action =  PO_ASL_API_PUB.g_ACTION_ADD
  );
  po_asl_api_pvt.log('Num of rows inserted into po_supplier_item_tolerance:'
                      || SQL%ROWCOUNT);
  l_progress := 35;
  ------------------------------CREATE MODE END---------------------------------

  ------------------------------UPDATE MODE STARTS------------------------------
  UPDATE po_approved_supplier_list PASL
  SET
  (PASL.vendor_business_type             ,
   PASL.asl_status_id                    ,
   PASL.last_update_date                 ,
   PASL.last_updated_by                  ,
   PASL.manufacturer_asl_id              ,
   PASL.review_by_date                   ,
   PASL.comments                         ,
   PASL.attribute_category               ,
   PASL.attribute1                       ,
   PASL.attribute2                       ,
   PASL.attribute3                       ,
   PASL.attribute4                       ,
   PASL.attribute5                       ,
   PASL.attribute6                       ,
   PASL.attribute7                       ,
   PASL.attribute8                       ,
   PASL.attribute9                       ,
   PASL.attribute10                      ,
   PASL.attribute11                      ,
   PASL.attribute12                      ,
   PASL.attribute13                      ,
   PASL.attribute14                      ,
   PASL.attribute15                      ,
   PASL.request_id                       ,
   PASL.program_application_id           ,
   PASL.program_id                       ,
   PASL.program_update_date              ,
   PASL.disable_flag                     ,
   PASL.last_update_login    )
  = (SELECT  Upper(ASLGT.vendor_business_type) ,
             ASLGT.asl_status_id         ,
             SYSDATE                     ,
             fnd_global.USER_ID          ,
             ASLGT.manufacturer_id       ,
             ASLGT.review_by_date        ,
             ASLGT.comments              ,
             ASLGT.attribute_category    ,
             ASLGT.attribute1            ,
             ASLGT.attribute2            ,
             ASLGT.attribute3            ,
             ASLGT.attribute4            ,
             ASLGT.attribute5            ,
             ASLGT.attribute6            ,
             ASLGT.attribute7            ,
             ASLGT.attribute8            ,
             ASLGT.attribute9            ,
             ASLGT.attribute10           ,
             ASLGT.attribute11           ,
             ASLGT.attribute12           ,
             ASLGT.attribute13           ,
             ASLGT.attribute14           ,
             ASLGT.attribute15           ,
             ASLGT.request_id            ,
             ASLGT.program_application_id,
             ASLGT.program_id            ,
             ASLGT.program_update_date   ,
             Decode(ASLGT.disable_flag,'Y','Y','N')          ,
             fnd_global.LOGIN_ID
       FROM  po_approved_supplier_list_gt ASLGT
       WHERE PASL.asl_id              = ASLGT.asl_id
             AND ASLGT.process_action = PO_ASL_API_PUB.g_ACTION_UPDATE
             AND ASLGT.process_status <> PO_ASL_API_PVT.g_STATUS_REJECTED)
  WHERE PASL.asl_id IN
  (SELECT  ASLGT.asl_id
     FROM  po_approved_supplier_list_gt ASLGT
     WHERE PASL.asl_id              =  ASLGT.asl_id
           AND ASLGT.process_action =  PO_ASL_API_PUB.g_ACTION_UPDATE
           AND ASLGT.process_status <> PO_ASL_API_PVT.g_STATUS_REJECTED);

  po_asl_api_pvt.log('number of rows updated in po_approved_supplier_list:'
                      || SQL%ROWCOUNT);
  l_progress := 40;

  UPDATE po_asl_attributes  PAA
  SET
  (PAA.last_update_date                 ,
   PAA.last_updated_by                  ,
   PAA.purchasing_unit_of_measure       ,
   PAA.release_generation_method        ,
   PAA.enable_plan_schedule_flag        ,
   PAA.enable_ship_schedule_flag        ,
   PAA.plan_schedule_type               ,
   PAA.ship_schedule_type               ,
   PAA.plan_bucket_pattern_id           ,
   PAA.ship_bucket_pattern_id           ,
   PAA.enable_autoschedule_flag         ,
   PAA.scheduler_id                     ,
   PAA.attribute_category               ,
   PAA.attribute1                       ,
   PAA.attribute2                       ,
   PAA.attribute3                       ,
   PAA.attribute4                       ,
   PAA.attribute5                       ,
   PAA.attribute6                       ,
   PAA.attribute7                       ,
   PAA.attribute8                       ,
   PAA.attribute9                       ,
   PAA.attribute10                      ,
   PAA.attribute11                      ,
   PAA.attribute12                      ,
   PAA.attribute13                      ,
   PAA.attribute14                      ,
   PAA.attribute15                      ,
   PAA.request_id                       ,
   PAA.program_application_id           ,
   PAA.program_id                       ,
   PAA.program_update_date              ,
   PAA.enable_authorizations_flag       ,
   PAA.last_update_login                ,
   PAA.price_update_tolerance           ,
   PAA.processing_lead_time             ,
   PAA.min_order_qty                    ,
   PAA.fixed_lot_multiple               ,
   PAA.delivery_calendar                ,
   PAA.country_of_origin_code           ,
   PAA.enable_vmi_flag                  ,
   PAA.vmi_min_qty                      ,
   PAA.vmi_max_qty                      ,
   PAA.enable_vmi_auto_replenish_flag   ,
   PAA.vmi_replenishment_approval       ,
   PAA.consigned_from_supplier_flag     ,
   PAA.consigned_billing_cycle          ,
   PAA.consume_on_aging_flag            ,
   PAA.aging_period                     ,
   PAA.replenishment_method             ,
   PAA.vmi_min_days                     ,
   PAA.vmi_max_days                     ,
   PAA.fixed_order_quantity             ,
   PAA.forecast_horizon)
  = (SELECT  SYSDATE                                  ,
             fnd_global.USER_ID                       ,
             PAAGT.purchasing_unit_of_measure_dsp     ,
             PAAGT.release_generation_method          ,
             Decode(PAAGT.enable_plan_schedule_flag_dsp,'Y','Y','N')      ,
             Decode(PAAGT.enable_ship_schedule_flag_dsp,'Y','Y','N')      ,
             PAAGT.plan_schedule_type                 ,
             PAAGT.ship_schedule_type                 ,
             PAAGT.plan_bucket_pattern_id             ,
             PAAGT.ship_bucket_pattern_id             ,
             Decode(PAAGT.enable_autoschedule_flag_dsp,'Y','Y','N')       ,
             PAAGT.scheduler_id                       ,
             PAAGT.attribute_category                 ,
             PAAGT.attribute1                         ,
             PAAGT.attribute2                         ,
             PAAGT.attribute3                         ,
             PAAGT.attribute4                         ,
             PAAGT.attribute5                         ,
             PAAGT.attribute6                         ,
             PAAGT.attribute7                         ,
             PAAGT.attribute8                         ,
             PAAGT.attribute9                         ,
             PAAGT.attribute10                        ,
             PAAGT.attribute11                        ,
             PAAGT.attribute12                        ,
             PAAGT.attribute13                        ,
             PAAGT.attribute14                        ,
             PAAGT.attribute15                        ,
             PAAGT.request_id                         ,
             PAAGT.program_application_id             ,
             PAAGT.program_id                         ,
             PAAGT.program_update_date                ,
             Decode(PAAGT.enable_authorizations_flag_dsp,'Y','Y','N')     ,
             fnd_global.LOGIN_ID                      ,
             PAAGT.price_update_tolerance_dsp         ,
             PAAGT.processing_lead_time_dsp           ,
             PAAGT.min_order_qty_dsp                  ,
             PAAGT.fixed_lot_multiple_dsp             ,
             PAAGT.delivery_calendar_dsp              ,
             PAAGT.country_of_origin_code_dsp         ,
             Decode(PAAGT.enable_vmi_flag_dsp,'Y','Y','N')                ,
             PAAGT.vmi_min_qty_dsp                    ,
             PAAGT.vmi_max_qty_dsp                    ,
             Decode(PAAGT.enable_vmi_auto_replenish_flag,'Y','Y','N')     ,
             PAAGT.vmi_replenishment_approval         ,
             Decode(PAAGT.consigned_from_supp_flag_dsp,'Y','Y','N')       ,
             PAAGT.consigned_billing_cycle_dsp        ,
             Decode(PAAGT.consume_on_aging_flag_dsp,'Y','Y','N')          ,
             PAAGT.aging_period_dsp                   ,
             PAAGT.replenishment_method               ,
             PAAGT.vmi_min_days_dsp                   ,
             PAAGT.vmi_max_days_dsp                   ,
             PAAGT.fixed_order_quantity_dsp           ,
             PAAGT.forecast_horizon_dsp
       FROM  po_asl_attributes_gt PAAGT               ,
             po_approved_supplier_list_gt ASLGT
       WHERE PAAGT.user_key                  = ASLGT.user_key
             AND PAAGT.asl_id                = PAA.asl_id
             AND PAAGT.using_organization_id = PAA.using_organization_id
             AND ASLGT.process_action        = PO_ASL_API_PUB.g_ACTION_UPDATE
             AND PAAGT.process_action        = PO_ASL_API_PUB.g_ACTION_UPDATE
             AND ASLGT.process_status       <> PO_ASL_API_PVT.g_STATUS_REJECTED)
  WHERE (PAA.asl_id, PAA.using_organization_id) IN
  (SELECT  PAAGT.asl_id, PAAGT.using_organization_id
     FROM  po_asl_attributes_gt PAAGT,
           po_approved_supplier_list_gt ASLGT
     WHERE ASLGT.user_key                  = PAAGT.user_key
           AND ASLGT.process_action        = PO_ASL_API_PUB.g_ACTION_UPDATE
           AND PAAGT.process_action        = PO_ASL_API_PUB.g_ACTION_UPDATE
           AND PAAGT.asl_id                = PAA.asl_id
           AND PAAGT.using_organization_id = PAA.using_organization_id
           AND ASLGT.process_status       <> PO_ASL_API_PVT.g_STATUS_REJECTED);

  po_asl_api_pvt.log('number of rows updated in po_asl_attributes:'
                      || SQL%ROWCOUNT);
  l_progress := 45;

  UPDATE po_asl_documents PAD
  SET
  (PAD.document_line_id                    ,
   PAD.last_update_date                    ,
   PAD.last_updated_by                     ,
   PAD.attribute_category                  ,
   PAD.attribute1                          ,
   PAD.attribute2                          ,
   PAD.attribute3                          ,
   PAD.attribute4                          ,
   PAD.attribute5                          ,
   PAD.attribute6                          ,
   PAD.attribute7                          ,
   PAD.attribute8                          ,
   PAD.attribute9                          ,
   PAD.attribute10                         ,
   PAD.attribute11                         ,
   PAD.attribute12                         ,
   PAD.attribute13                         ,
   PAD.attribute14                         ,
   PAD.attribute15                         ,
   PAD.last_update_login                   ,
   PAD.request_id                          ,
   PAD.program_application_id              ,
   PAD.program_id                          ,
   PAD.program_update_date)
  = (SELECT  PADGT.document_line_id        ,
             SYSDATE                       ,
             fnd_global.USER_ID            ,
             PAD.attribute_category        ,
             PADGT.attribute1              ,
             PADGT.attribute2              ,
             PADGT.attribute3              ,
             PADGT.attribute4              ,
             PADGT.attribute5              ,
             PADGT.attribute6              ,
             PADGT.attribute7              ,
             PADGT.attribute8              ,
             PADGT.attribute9              ,
             PADGT.attribute10             ,
             PADGT.attribute11             ,
             PADGT.attribute12             ,
             PADGT.attribute13             ,
             PADGT.attribute14             ,
             PADGT.attribute15             ,
             fnd_global.LOGIN_ID           ,
             PADGT.request_id              ,
             PADGT.program_application_id  ,
             PADGT.program_id              ,
             PADGT.program_update_date
       FROM  po_asl_documents_gt PADGT,
             po_approved_supplier_list_gt ASLGT
       WHERE PADGT.user_key                  = ASLGT.user_key
             AND PADGT.asl_id                = PAD.asl_id
             AND PADGT.using_organization_id = PAD.using_organization_id
             AND PADGT.document_header_id    = PAD.document_header_id
             AND ASLGT.process_action        = PO_ASL_API_PUB.g_ACTION_UPDATE
             AND PADGT.process_action        = PO_ASL_API_PUB.g_ACTION_UPDATE
             AND ASLGT.process_status       <> PO_ASL_API_PVT.g_STATUS_REJECTED)
  WHERE (PAD.asl_id, PAD.using_organization_id, PAD.document_header_id) IN
  (SELECT  PADGT.asl_id, PADGT.using_organization_id, PADGT.document_header_id
     FROM  po_asl_documents_gt PADGT,
             po_approved_supplier_list_gt ASLGT
       WHERE PADGT.user_key                  = ASLGT.user_key
             AND PADGT.asl_id                = PAD.asl_id
             AND PADGT.using_organization_id = PAD.using_organization_id
             AND PADGT.document_header_id    = PAD.document_header_id
             AND ASLGT.process_action        = PO_ASL_API_PUB.g_ACTION_UPDATE
             AND PADGT.process_action        = PO_ASL_API_PUB.g_ACTION_UPDATE
             AND ASLGT.process_status       <> PO_ASL_API_PVT.g_STATUS_REJECTED);

  po_asl_api_pvt.log('number of rows updated in po_asl_documents:'
                      || SQL%ROWCOUNT);
  l_progress := 50;

  UPDATE chv_authorizations CHV
  SET
  (CHV.last_update_date                       ,
   CHV.last_updated_by                        ,
   CHV.timefence_days                         ,
   CHV.attribute_category                     ,
   CHV.attribute1                             ,
   CHV.attribute2                             ,
   CHV.attribute3                             ,
   CHV.attribute4                             ,
   CHV.attribute5                             ,
   CHV.attribute6                             ,
   CHV.attribute7                             ,
   CHV.attribute8                             ,
   CHV.attribute9                             ,
   CHV.attribute10                            ,
   CHV.attribute11                            ,
   CHV.attribute12                            ,
   CHV.attribute13                            ,
   CHV.attribute14                            ,
   CHV.attribute15                            ,
   CHV.last_update_login                      ,
   CHV.request_id                             ,
   CHV.program_application_id                 ,
   CHV.program_id                             ,
   CHV.program_update_date)
  = (SELECT  SYSDATE                          ,
             fnd_global.USER_ID               ,
             CHVGT.timefence_days_dsp         ,
             CHVGT.attribute_category         ,
             CHVGT.attribute1                 ,
             CHVGT.attribute2                 ,
             CHVGT.attribute3                 ,
             CHVGT.attribute4                 ,
             CHVGT.attribute5                 ,
             CHVGT.attribute6                 ,
             CHVGT.attribute7                 ,
             CHVGT.attribute8                 ,
             CHVGT.attribute9                 ,
             CHVGT.attribute10                ,
             CHVGT.attribute11                ,
             CHVGT.attribute12                ,
             CHVGT.attribute13                ,
             CHVGT.attribute14                ,
             CHVGT.attribute15                ,
             fnd_global.LOGIN_ID              ,
             CHVGT.request_id                 ,
             CHVGT.program_application_id     ,
             CHVGT.program_id                 ,
             CHVGT.program_update_date
       FROM  chv_authorizations_gt CHVGT,
             po_approved_supplier_list_gt ASLGT
       WHERE CHVGT.user_key                   = ASLGT.user_key
             AND CHVGT.reference_id           = CHV.reference_id
             AND CHVGT.using_organization_id  = CHV.using_organization_id
             AND CHVGT.authorization_code     = CHV.authorization_code
             AND CHVGT.authorization_sequence_dsp = CHV.authorization_sequence
             AND ASLGT.process_action       = PO_ASL_API_PUB.g_ACTION_UPDATE
             AND CHVGT.process_action       = PO_ASL_API_PUB.g_ACTION_UPDATE
             AND ASLGT.process_status       <> PO_ASL_API_PVT.g_STATUS_REJECTED)
  WHERE (CHV.reference_id, CHV.using_organization_id,
         CHV.authorization_code, CHV.authorization_sequence) IN
  (SELECT  CHVGT.reference_id            ,
           CHVGT.using_organization_id   ,
           CHVGT.authorization_code      ,
           CHVGT.authorization_sequence_dsp
     FROM  chv_authorizations_gt CHVGT,
           po_approved_supplier_list_gt ASLGT
     WHERE CHVGT.user_key                       = ASLGT.user_key
           AND CHVGT.reference_id               = CHV.reference_id
           AND CHVGT.using_organization_id      = CHV.using_organization_id
           AND CHVGT.authorization_code         = CHV.authorization_code
           AND CHVGT.authorization_sequence_dsp = CHV.authorization_sequence
           AND ASLGT.process_action             = PO_ASL_API_PUB.g_ACTION_UPDATE
           AND CHVGT.process_action             = PO_ASL_API_PUB.g_ACTION_UPDATE
           AND ASLGT.process_status            <> PO_ASL_API_PVT.g_STATUS_REJECTED);

  po_asl_api_pvt.log('number of rows updated in chv_authorizations:'
                      || SQL%ROWCOUNT);
  l_progress := 55;

  UPDATE po_supplier_item_capacity PSIC
  SET
  (PSIC.capacity_per_day                 ,
   PSIC.last_update_date                 ,
   PSIC.last_updated_by                  ,
   PSIC.attribute_category               ,
   PSIC.attribute1                       ,
   PSIC.attribute2                       ,
   PSIC.attribute3                       ,
   PSIC.attribute4                       ,
   PSIC.attribute5                       ,
   PSIC.attribute6                       ,
   PSIC.attribute7                       ,
   PSIC.attribute8                       ,
   PSIC.attribute9                       ,
   PSIC.attribute10                      ,
   PSIC.attribute11                      ,
   PSIC.attribute12                      ,
   PSIC.attribute13                      ,
   PSIC.attribute14                      ,
   PSIC.attribute15                      ,
   PSIC.last_update_login                ,
   PSIC.request_id                       ,
   PSIC.program_application_id           ,
   PSIC.program_id                       ,
   PSIC.program_update_date)
  = (SELECT  GT.capacity_per_day_dsp     ,
             SYSDATE                     ,
             fnd_global.USER_ID          ,
             GT.attribute_category       ,
             GT.attribute1               ,
             GT.attribute2               ,
             GT.attribute3               ,
             GT.attribute4               ,
             GT.attribute5               ,
             GT.attribute6               ,
             GT.attribute7               ,
             GT.attribute8               ,
             GT.attribute9               ,
             GT.attribute10              ,
             GT.attribute11              ,
             GT.attribute12              ,
             GT.attribute13              ,
             GT.attribute14              ,
             GT.attribute15              ,
             fnd_global.LOGIN_ID         ,
             GT.request_id               ,
             GT.program_application_id   ,
             GT.program_id               ,
             GT.program_update_date
       FROM  po_supplier_item_capacity_gt GT,
             po_approved_supplier_list_gt ASLGT
       WHERE GT.user_key                      = ASLGT.user_key
             AND GT.asl_id                    = PSIC.asl_id
             AND GT.using_organization_id     = PSIC.using_organization_id
             AND GT.from_date_dsp             = PSIC.from_date
             AND Nvl(GT.to_date_dsp, SYSDATE) = Nvl(PSIC.To_Date, SYSDATE)
             AND ASLGT.process_action         = PO_ASL_API_PUB.g_ACTION_UPDATE
             AND GT.process_action            = PO_ASL_API_PUB.g_ACTION_UPDATE
             AND ASLGT.process_status        <> PO_ASL_API_PVT.g_STATUS_REJECTED)
  WHERE (PSIC.asl_id, PSIC.using_organization_id,
         PSIC.from_date, PSIC.To_Date) IN
  (SELECT  GT.asl_id                ,
           GT.using_organization_id ,
           GT.from_date_dsp         ,
           GT.to_date_dsp
     FROM  po_supplier_item_capacity_gt GT,
           po_approved_supplier_list_gt ASLGT
     WHERE GT.user_key                      = ASLGT.user_key
           AND GT.asl_id                    = PSIC.asl_id
           AND GT.using_organization_id     = PSIC.using_organization_id
           AND GT.from_date_dsp             = PSIC.from_date
           AND Nvl(GT.to_date_dsp, SYSDATE) = Nvl(PSIC.To_Date, SYSDATE)
           AND ASLGT.process_action         = PO_ASL_API_PUB.g_ACTION_UPDATE
           AND GT.process_action            = PO_ASL_API_PUB.g_ACTION_UPDATE
           AND ASLGT.process_status        <> PO_ASL_API_PVT.g_STATUS_REJECTED);

  po_asl_api_pvt.log('number of rows updated in po_supplier_item_capacity:'
                      || SQL%ROWCOUNT);
  l_progress := 60;

  UPDATE po_supplier_item_tolerance PSIT
  SET
  (PSIT.last_update_date              ,
   PSIT.last_updated_by               ,
   PSIT.attribute_category            ,
   PSIT.attribute1                    ,
   PSIT.attribute2                    ,
   PSIT.attribute3                    ,
   PSIT.attribute4                    ,
   PSIT.attribute5                    ,
   PSIT.attribute6                    ,
   PSIT.attribute7                    ,
   PSIT.attribute8                    ,
   PSIT.attribute9                    ,
   PSIT.attribute10                   ,
   PSIT.attribute11                   ,
   PSIT.attribute12                   ,
   PSIT.attribute13                   ,
   PSIT.attribute14                   ,
   PSIT.attribute15                   ,
   PSIT.last_update_login             ,
   PSIT.request_id                    ,
   PSIT.program_application_id        ,
   PSIT.program_id                    ,
   PSIT.program_update_date)
  = (SELECT  SYSDATE                  ,
             fnd_global.USER_ID       ,
             GT.attribute_category    ,
             GT.attribute1            ,
             GT.attribute2            ,
             GT.attribute3            ,
             GT.attribute4            ,
             GT.attribute5            ,
             GT.attribute6            ,
             GT.attribute7            ,
             GT.attribute8            ,
             GT.attribute9            ,
             GT.attribute10           ,
             GT.attribute11           ,
             GT.attribute12           ,
             GT.attribute13           ,
             GT.attribute14           ,
             GT.attribute15           ,
             fnd_global.LOGIN_ID      ,
             GT.request_id            ,
             GT.program_application_id,
             GT.program_id            ,
             GT.program_update_date
       FROM  po_supplier_item_tolerance_gt GT,
             po_approved_supplier_list_gt ASLGT
       WHERE GT.user_key                  = ASLGT.user_key
             AND GT.asl_id                = PSIT.asl_id
             AND GT.using_organization_id = PSIT.using_organization_id
             AND GT.tolerance_dsp         = PSIT.tolerance
             AND GT.number_of_days_dsp    = PSIT.number_of_days
             AND ASLGT.process_action     = PO_ASL_API_PUB.g_ACTION_UPDATE
             AND GT.process_action        = PO_ASL_API_PUB.g_ACTION_UPDATE
             AND ASLGT.process_status    <> PO_ASL_API_PVT.g_STATUS_REJECTED)
  WHERE (PSIT.asl_id, PSIT.using_organization_id,
         PSIT.tolerance, PSIT.number_of_days) IN
  (SELECT  GT.asl_id                ,
           GT.using_organization_id ,
           GT.tolerance_dsp         ,
           GT.number_of_days_dsp
     FROM  po_supplier_item_tolerance_gt GT,
           po_approved_supplier_list_gt ASLGT
     WHERE GT.user_key                  = ASLGT.user_key
           AND GT.asl_id                = PSIT.asl_id
           AND GT.using_organization_id = PSIT.using_organization_id
           AND GT.tolerance_dsp         = PSIT.tolerance
           AND GT.number_of_days_dsp    = PSIT.number_of_days
           AND ASLGT.process_action     = PO_ASL_API_PUB.g_ACTION_UPDATE
           AND GT.process_action        = PO_ASL_API_PUB.g_ACTION_UPDATE
           AND ASLGT.process_status    <> PO_ASL_API_PVT.g_STATUS_REJECTED);

  po_asl_api_pvt.log('number of rows updated in po_supplier_item_tolerance:'
                      || SQL%ROWCOUNT);
  l_progress := 65;
  ------------------------------UPDATE MODE ENDS--------------------------------

  ------------------------------DELETE MODE START-------------------------------
  DELETE FROM po_asl_attributes PAA
  WHERE (asl_id, using_organization_id) IN
  (SELECT  PAAGT.asl_id,
           PAAGT.using_organization_id
     FROM  po_asl_attributes_gt PAAGT,
           po_approved_supplier_list_gt ASLGT
     WHERE ASLGT.user_key                  = PAAGT.user_key
           AND PAAGT.process_action        = PO_ASL_API_PUB.g_ACTION_DELETE
           AND PAAGT.asl_id                = PAA.asl_id
           AND PAAGT.using_organization_id = PAA.using_organization_id
           AND ASLGT.process_status       <> PO_ASL_API_PVT.g_STATUS_REJECTED);

  po_asl_api_pvt.log('number of rows deleted from po_asl_attributes:'
                      || SQL%ROWCOUNT);
  l_progress := 70;

  DELETE FROM po_asl_documents PAD
  WHERE (asl_id,using_organization_id,document_header_id) IN
  (SELECT  PADGT.asl_id                ,
           PADGT.using_organization_id ,
           PADGT.document_header_id
     FROM  po_asl_documents_gt PADGT,
           po_approved_supplier_list_gt ASLGT
     WHERE ASLGT.user_key                  = PADGT.user_key
           AND PADGT.process_action        = PO_ASL_API_PUB.g_ACTION_DELETE
           AND PADGT.asl_id                = PAD.asl_id
           AND PADGT.using_organization_id = PAD.using_organization_id
           AND PADGT.document_header_id    = PAD.document_header_id
           AND ASLGT.process_status       <> PO_ASL_API_PVT.g_STATUS_REJECTED);

  po_asl_api_pvt.log('1.number of rows deleted from po_asl_documents:'
                      || SQL%ROWCOUNT);
  l_progress := 73;
  --Delete documents, if asl_attributes doesn't exist
  DELETE FROM po_asl_documents PAD
  WHERE  NOT EXISTS
  (SELECT  1
     FROM  po_asl_attributes PAA
     WHERE PAA.asl_id                    = PAD.asl_id
           AND PAA.using_organization_id = PAD.using_organization_id)
  AND EXISTS
  (SELECT  1,
           ASLGT.using_organization_id
     FROM  po_approved_supplier_list_gt ASLGT
     WHERE ASLGT.asl_id                    = PAD.asl_id
           AND ASLGT.using_organization_id = PAD.using_organization_id);

  po_asl_api_pvt.log('2.number of rows deleted from po_asl_documents:'
                      || SQL%ROWCOUNT);

  l_progress := 75;

  DELETE FROM chv_authorizations CHV
  WHERE  (reference_id, using_organization_id, authorization_code) IN
  (SELECT  CHVGT.reference_id          ,
           CHVGT.using_organization_id ,
           CHVGT.authorization_code
     FROM  chv_authorizations_gt CHVGT,
           po_approved_supplier_list_gt ASLGT
     WHERE ASLGT.user_key                  = CHVGT.user_key
           AND CHVGT.process_action        = PO_ASL_API_PUB.g_ACTION_DELETE
           AND CHVGT.reference_id          = CHV.reference_id
           AND CHVGT.using_organization_id = CHV.using_organization_id
           AND CHVGT.authorization_code    = CHV.authorization_code
           AND ASLGT.process_status       <> PO_ASL_API_PVT.g_STATUS_REJECTED);

  po_asl_api_pvt.log('1.number of rows deleted from chv_authorizations:'
                      || SQL%ROWCOUNT);
  l_progress := 77;

  --Delete authorizations, if asl_attributes modified with
  --authorizations_flag unchekced or plan schedule flag unchecked
  DELETE FROM chv_authorizations CHV
  WHERE  (reference_id, using_organization_id) IN
  (SELECT  PAA.asl_id,
           PAA.using_organization_id
     FROM  po_asl_attributes PAA
     WHERE PAA.asl_id                      = CHV.reference_id
           AND PAA.using_organization_id   = CHV.using_organization_id
           AND (Nvl(PAA.enable_authorizations_flag, 'N') <> 'Y'
                OR Nvl(PAA.enable_plan_schedule_flag , 'N') <> 'Y'))
  AND EXISTS
  (SELECT  1,
           ASLGT.using_organization_id
     FROM  po_approved_supplier_list_gt ASLGT
     WHERE aslgt.asl_id                    = CHV.reference_id
           AND ASLGT.using_organization_id = CHV.using_organization_id);

  po_asl_api_pvt.log('2.number of rows deleted from chv_authorizations:'
                      || SQL%ROWCOUNT);
  l_progress := 79;

  --Delete authorizations, if asl_attributes doesn't exist
  DELETE FROM chv_authorizations CHV
  WHERE  NOT EXISTS
  (SELECT  1
     FROM  po_asl_attributes PAA
     WHERE PAA.asl_id                      = CHV.reference_id
           AND PAA.using_organization_id   = CHV.using_organization_id)
  AND EXISTS
  (SELECT  1,
           ASLGT.using_organization_id
     FROM  po_approved_supplier_list_gt ASLGT
     WHERE ASLGT.asl_id                    = CHV.reference_id
           AND ASLGT.using_organization_id = CHV.using_organization_id);

  po_asl_api_pvt.log('3.number of rows deleted from chv_authorizations:'
                      || SQL%ROWCOUNT);
  l_progress := 80;

  DELETE FROM po_supplier_item_capacity PSIC
  WHERE (asl_id, using_organization_id, from_date, To_Date) IN
  (SELECT  GT.asl_id                 ,
           GT.using_organization_id  ,
           GT.from_date_dsp          ,
           GT.to_date_dsp
     FROM  po_supplier_item_capacity_gt GT,
           po_approved_supplier_list_gt ASLGT
     WHERE ASLGT.user_key                  = GT.user_key
           AND GT.process_action           = PO_ASL_API_PUB.g_ACTION_DELETE
           AND GT.asl_id                   = PSIC.asl_id
           AND GT.from_date_dsp            = PSIC.from_date
           AND Nvl(GT.to_date_dsp, SYSDATE)= Nvl(PSIC.To_Date, SYSDATE)
           AND GT.capacity_per_day_dsp     = PSIC.capacity_per_day
           AND GT.using_organization_id    = PSIC.using_organization_id
           AND ASLGT.process_status       <> PO_ASL_API_PVT.g_STATUS_REJECTED);

  po_asl_api_pvt.log('1.number of rows deleted from po_supplier_item_capacity:'
                      || SQL%ROWCOUNT);
  l_progress := 85;

  --Delete capacity, if asl_attributes modified with enable_vmi_flag unchekced
  DELETE FROM po_supplier_item_capacity PSIC
  WHERE  (asl_id, using_organization_id) IN
  (SELECT  PAA.asl_id,
           PAA.using_organization_id
     FROM  po_asl_attributes PAA
     WHERE PAA.asl_id                      = PSIC.asl_id
           AND PAA.using_organization_id   = PSIC.using_organization_id
           AND PAA.using_organization_id        <> -1
           AND Nvl(PAA.enable_vmi_flag   , 'N') <> 'Y')
  AND EXISTS
  (SELECT  1,
           ASLGT.using_organization_id
     FROM  po_approved_supplier_list_gt ASLGT
     WHERE ASLGT.asl_id                    = PSIC.asl_id
           AND ASLGT.using_organization_id = PSIC.using_organization_id);

  l_progress := 88;
  po_asl_api_pvt.log('2.number of rows deleted from po_supplier_item_capacity:'
                      || SQL%ROWCOUNT);

  --Delete capacities, if asl_attributes doesn't exist
  DELETE FROM po_supplier_item_capacity PSIC
  WHERE  NOT EXISTS
  (SELECT  1
     FROM  po_asl_attributes PAA
     WHERE PAA.asl_id                      = PSIC.asl_id
           AND PAA.using_organization_id   = PSIC.using_organization_id)
  AND EXISTS
  (SELECT  1,
           ASLGT.using_organization_id
     FROM  po_approved_supplier_list_gt ASLGT
     WHERE ASLGT.asl_id                    = PSIC.asl_id
           AND ASLGT.using_organization_id = PSIC.using_organization_id);

  po_asl_api_pvt.log('3.number of rows deleted from po_supplier_item_capacity:'
                      || SQL%ROWCOUNT);
  l_progress := 90;

  DELETE FROM po_supplier_item_tolerance PSIT
  WHERE (asl_id, using_organization_id, number_of_days, tolerance) IN
  (SELECT  GT.asl_id                ,
           GT.using_organization_id  ,
           GT.number_of_days_dsp     ,
           GT.tolerance_dsp
     FROM  po_supplier_item_tolerance_gt GT,
           po_approved_supplier_list_gt ASLGT
     WHERE ASLGT.user_key                  = GT.user_key
           AND GT.process_action           = PO_ASL_API_PUB.g_ACTION_DELETE
           AND GT.asl_id                   = PSIT.asl_id
           AND GT.using_organization_id    = PSIT.using_organization_id
           AND GT.number_of_days_dsp       = PSIT.number_of_days
           AND GT.tolerance_dsp            = PSIT.tolerance
          AND  ASLGT.process_status       <> PO_ASL_API_PVT.g_STATUS_REJECTED);

  po_asl_api_pvt.log('1.number of rows deleted from po_supplier_item_tolerance:'
                      || SQL%ROWCOUNT);
  l_progress := 95;

  --Delete tolerance, if asl_attributes modified with enable_vmi_flag unchekced
  DELETE FROM po_supplier_item_tolerance PSIT
  WHERE  (asl_id, using_organization_id) IN
  (SELECT  PAA.asl_id,
           PAA.using_organization_id
     FROM  po_asl_attributes PAA
     WHERE PAA.asl_id                      = PSIT.asl_id
           AND PAA.using_organization_id   = PSIT.using_organization_id
           AND PAA.using_organization_id        <> -1
           AND Nvl(PAA.enable_vmi_flag   , 'N') <> 'Y')
  AND EXISTS
  (SELECT  1,
           ASLGT.using_organization_id
     FROM  po_approved_supplier_list_gt ASLGT
     WHERE ASLGT.asl_id                    = PSIT.asl_id
           AND ASLGT.using_organization_id = PSIT.using_organization_id);

  l_progress := 97;
  po_asl_api_pvt.log('2.number of rows deleted from po_supplier_item_tolerance:'
                      || SQL%ROWCOUNT);

  --Delete tolerance, if asl_attributes doesn't exist
  DELETE FROM po_supplier_item_tolerance PSIT
  WHERE  NOT EXISTS
  (SELECT  1
     FROM  po_asl_attributes PAA
     WHERE PAA.asl_id                      = PSIT.asl_id
           AND PAA.using_organization_id   = PSIT.using_organization_id)
  AND EXISTS
  (SELECT  1,
           ASLGT.using_organization_id
     FROM  po_approved_supplier_list_gt ASLGT
     WHERE ASLGT.asl_id                    = PSIT.asl_id
           AND ASLGT.using_organization_id = PSIT.using_organization_id);

  po_asl_api_pvt.log('3.number of rows deleted from po_supplier_item_tolerance:'
                      || SQL%ROWCOUNT);
  l_progress := 98;
  ------------------------------DELETE MODE END---------------------------------

  --Update process_status column to 'Processed' in GT table
  UPDATE po_approved_supplier_list_gt
  SET    process_status = PO_ASL_API_PVT.g_STATUS_SUCCESS
  WHERE  process_status = PO_ASL_API_PVT.g_STATUS_PENDING;

  po_asl_api_pvt.log('status count of success from pending:' || SQL%ROWCOUNT);
  l_progress := 100;
  PO_ASL_API_PVT.Log('END ::: PO_ASL_API_PVT.process ');

EXCEPTION

  WHEN OTHERS THEN

    PO_ASL_API_PVT.Log('PO_ASL_API_PVT.process : when others exception at '
                       || l_progress || ';' || SQLERRM );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_return_msg := SQLERRM;
END process;


--------------------------------------------------------------------------------
  --Start of Comments

  --Name: reject_asl_record

  --Function:
  --  Reject the record by mariking the column 'PROCESS_STATUS' to 'REJECT'.
  --  bulk insert into po_asl_api_errors with the rejection_reason, user_key
  --  and session_key

  --Parameters:

  --IN:
  --  p_user_key_tbl      po_tbl_number,
  --  p_rejection_reason  po_tbl_varchar2000,
  --  p_entity_name       po_tbl_varchar30

  --OUT:
  --  x_return_status     VARCHAR2
  --  x_return_msg        VARCHAR2

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE reject_asl_record(
  p_user_key_tbl      IN         po_tbl_number
, p_rejection_reason  IN         po_tbl_varchar2000
, p_entity_name       IN         po_tbl_varchar30
, p_session_key       IN         NUMBER
, x_return_status     OUT NOCOPY VARCHAR2
, x_return_msg        OUT NOCOPY VARCHAR2
)
IS
l_progress NUMBER := 0;

BEGIN
  x_return_msg := NULL;
  PO_ASL_API_PVT.Log('START ::: reject_asl_record ');
  PO_ASL_API_PVT.Log(p_user_key_tbl);
  PO_ASL_API_PVT.Log(p_rejection_reason);
  PO_ASL_API_PVT.Log(p_entity_name);

  --Reject the records in po_approved_supplier_list_gt
  FORALL l_index IN 1 .. p_user_key_tbl.Count
  UPDATE po_approved_supplier_list_gt PAST
  SET PAST.process_status = PO_ASL_API_PVT.g_STATUS_REJECTED
  WHERE PAST.user_key = p_user_key_tbl(l_index);

  PO_ASL_API_PVT.Log('reject_asl_record update rowcount:' || SQL%ROWCOUNT);
  l_progress := 50;

  --Dump all the errors into po_asl_api_errors
  FORALL l_index IN 1 .. p_user_key_tbl.Count
  INSERT INTO po_asl_api_errors (
    user_key                       ,
    session_key                    ,
    entity_name                    ,
    rejection_reason
  ) VALUES (
    p_user_key_tbl(l_index)        ,
    p_session_key                  ,
    p_entity_name(l_index)         ,
    p_rejection_reason(l_index)
  );

  PO_ASL_API_PVT.Log('reject_asl_record insert rowcount:' || SQL%ROWCOUNT);
  l_progress := 100;

  PO_ASL_API_PVT.Log('END ::: reject_asl_record ');

EXCEPTION

  WHEN OTHERS THEN

    PO_ASL_API_PVT.Log('reject_asl_record : WHEN OTHERS EXCEPTION at '
                       || l_progress || ';' || SQLERRM );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_return_msg := SQLERRM;

END reject_asl_record;

--------------------------------------------------------------------------------
  --Start of Comments

  --Name: log

  --Function:
  --  For logging messages

  --Parameters:

  --IN:
  --p_log_message         varchar2

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE log(
  p_log_message       IN        VARCHAR2
)
AS
PRAGMA AUTONOMOUS_TRANSACTION;

l_results  PO_VALIDATION_RESULTS_TYPE;

BEGIN
  --INSERT
  --INTO test_fnd_messages
  --VALUES (test_sequence.NEXTVAL , p_log_message);
  PO_LOG.stmt(p_module_base    => 'ASL API',
              p_position       => NULL ,
              p_message_text   => p_log_message);

  COMMIT;
END log;

--------------------------------------------------------------------------------
  --Start of Comments

  --Name: log

  --Function:
  --  For logging po_approved_supplier_list_rec records

  --Parameters:

  --IN:
  --p_asl_rec             po_approved_supplier_list_rec

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE log(
  p_asl_rec           IN        po_approved_supplier_list_rec
)
AS

BEGIN
  IF p_asl_rec.user_key IS NOT NULL THEN
  FOR l_index IN 1 .. p_asl_rec.user_key.Count
  LOOP
     Log(''  || p_asl_rec.user_key(l_index)                         ||
         ',' || p_asl_rec.process_action(l_index)                   ||
         ',' || p_asl_rec.global_flag(l_index)                      ||
         ',' || p_asl_rec.owning_organization_id(l_index)           ||
         ',' || p_asl_rec.owning_organization_dsp(l_index)          ||
         ',' || p_asl_rec.vendor_business_type(l_index)             ||
         ',' || p_asl_rec.asl_status_id(l_index)                    ||
         ',' || p_asl_rec.asl_status_dsp(l_index)                   ||
         ',' || p_asl_rec.manufacturer_id(l_index)                  ||
         ',' || p_asl_rec.manufacturer_dsp(l_index)                 ||
         ',' || p_asl_rec.vendor_id(l_index)                        ||
         ',' || p_asl_rec.vendor_dsp(l_index)                       ||
         ',' || p_asl_rec.item_id(l_index)                          ||
         ',' || p_asl_rec.item_dsp(l_index)                         ||
         ',' || p_asl_rec.category_id(l_index)                      ||
         ',' || p_asl_rec.category_dsp(l_index)                     ||
         ',' || p_asl_rec.vendor_site_id(l_index)                   ||
         ',' || p_asl_rec.vendor_site_dsp(l_index)                  ||
         ',' || p_asl_rec.primary_vendor_item(l_index)              ||
         ',' || p_asl_rec.manufacturer_asl_id(l_index)              ||
         ',' || p_asl_rec.manufacturer_asl_dsp(l_index)             ||
         ',' || p_asl_rec.review_by_date(l_index)                   ||
         ',' || p_asl_rec.comments(l_index)                         ||
         ',' || p_asl_rec.attribute_category(l_index)               ||
         ',' || p_asl_rec.attribute1(l_index)                       ||
         ',' || p_asl_rec.attribute2(l_index)                       ||
         ',' || p_asl_rec.attribute3(l_index)                       ||
         ',' || p_asl_rec.attribute4(l_index)                       ||
         ',' || p_asl_rec.attribute5(l_index)                       ||
         ',' || p_asl_rec.attribute6(l_index)                       ||
         ',' || p_asl_rec.attribute7(l_index)                       ||
         ',' || p_asl_rec.attribute8(l_index)                       ||
         ',' || p_asl_rec.attribute9(l_index)                       ||
         ',' || p_asl_rec.attribute10(l_index)                      ||
         ',' || p_asl_rec.attribute11(l_index)                      ||
         ',' || p_asl_rec.attribute12(l_index)                      ||
         ',' || p_asl_rec.attribute13(l_index)                      ||
         ',' || p_asl_rec.attribute14(l_index)                      ||
         ',' || p_asl_rec.attribute15(l_index)                      ||
         ',' || p_asl_rec.request_id(l_index)                       ||
         ',' || p_asl_rec.program_application_id(l_index)           ||
         ',' || p_asl_rec.program_id(l_index)                       ||
         ',' || p_asl_rec.program_update_date(l_index)              ||
         ',' || p_asl_rec.disable_flag(l_index) );
  END LOOP;
  END IF;
END log;

--------------------------------------------------------------------------------
  --Start of Comments

  --Name: log

  --Function:
  --  For logging po_asl_attributes_rec records

  --Parameters:

  --IN:
  --p_attr_rec            po_asl_attributes_rec

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE log(
  p_attr_rec          IN        po_asl_attributes_rec
)
AS

BEGIN
  IF p_attr_rec.user_key IS NOT NULL THEN
  FOR l_index IN 1 .. p_attr_rec.user_key.Count
  LOOP
     log(''  || p_attr_rec.user_key(l_index)                        ||
         ',' || p_attr_rec.using_organization_id(l_index)           ||
         ',' || p_attr_rec.using_organization_dsp(l_index)          ||
         ',' || p_attr_rec.release_generation_method(l_index)       ||
         ',' || p_attr_rec.release_generation_method_dsp(l_index)   ||
         ',' || p_attr_rec.purchasing_unit_of_measure_dsp(l_index)  ||
         ',' || p_attr_rec.enable_plan_schedule_flag_dsp(l_index)   ||
         ',' || p_attr_rec.enable_ship_schedule_flag_dsp(l_index)   ||
         ',' || p_attr_rec.plan_schedule_type(l_index)              ||
         ',' || p_attr_rec.plan_schedule_type_dsp(l_index)          ||
         ',' || p_attr_rec.ship_schedule_type(l_index)              ||
         ',' || p_attr_rec.ship_schedule_type_dsp(l_index)          ||
         ',' || p_attr_rec.plan_bucket_pattern_id(l_index)          ||
         ',' || p_attr_rec.plan_bucket_pattern_dsp(l_index)         ||
         ',' || p_attr_rec.ship_bucket_pattern_id(l_index)          ||
         ',' || p_attr_rec.ship_bucket_pattern_dsp(l_index)         ||
         ',' || p_attr_rec.enable_autoschedule_flag_dsp(l_index)    ||
         ',' || p_attr_rec.scheduler_id(l_index)                    ||
         ',' || p_attr_rec.scheduler_dsp(l_index)                   ||
         ',' || p_attr_rec.enable_authorizations_flag_dsp(l_index)  ||
         ',' || p_attr_rec.vendor_id(l_index)                       ||
         ',' || p_attr_rec.vendor_dsp(l_index)                      ||
         ',' || p_attr_rec.vendor_site_id(l_index)                  ||
         ',' || p_attr_rec.vendor_site_dsp(l_index)                 ||
         ',' || p_attr_rec.item_id(l_index)                         ||
         ',' || p_attr_rec.item_dsp(l_index)                        ||
         ',' || p_attr_rec.category_id(l_index)                     ||
         ',' || p_attr_rec.category_dsp(l_index)                    ||
         ',' || p_attr_rec.attribute_category(l_index)              ||
         ',' || p_attr_rec.attribute1(l_index)                      ||
         ',' || p_attr_rec.attribute2(l_index)                      ||
         ',' || p_attr_rec.attribute3(l_index)                      ||
         ',' || p_attr_rec.attribute4(l_index)                      ||
         ',' || p_attr_rec.attribute5(l_index)                      ||
         ',' || p_attr_rec.attribute6(l_index)                      ||
         ',' || p_attr_rec.attribute7(l_index)                      ||
         ',' || p_attr_rec.attribute8(l_index)                      ||
         ',' || p_attr_rec.attribute9(l_index)                      ||
         ',' || p_attr_rec.attribute10(l_index)                     ||
         ',' || p_attr_rec.attribute11(l_index)                     ||
         ',' || p_attr_rec.attribute12(l_index)                     ||
         ',' || p_attr_rec.attribute13(l_index)                     ||
         ',' || p_attr_rec.attribute14(l_index)                     ||
         ',' || p_attr_rec.attribute15(l_index)                     ||
         ',' || p_attr_rec.request_id(l_index)                      ||
         ',' || p_attr_rec.program_application_id(l_index)          ||
         ',' || p_attr_rec.program_id(l_index)                      ||
         ',' || p_attr_rec.program_update_date(l_index)             ||
         ',' || p_attr_rec.price_update_tolerance_dsp(l_index)      ||
         ',' || p_attr_rec.processing_lead_time_dsp(l_index)        ||
         ',' || p_attr_rec.min_order_qty_dsp(l_index)               ||
         ',' || p_attr_rec.fixed_lot_multiple_dsp(l_index)          ||
         ',' || p_attr_rec.delivery_calendar_dsp(l_index)           ||
         ',' || p_attr_rec.country_of_origin_code_dsp(l_index)      ||
         ',' || p_attr_rec.enable_vmi_flag_dsp(l_index)             ||
         ',' || p_attr_rec.vmi_min_qty_dsp(l_index)                 ||
         ',' || p_attr_rec.vmi_max_qty_dsp(l_index)                 ||
         ',' || p_attr_rec.enable_vmi_auto_replenish_flag(l_index)  ||
         ',' || p_attr_rec.vmi_replenishment_approval(l_index)      ||
         ',' || p_attr_rec.vmi_replenishment_approval_dsp(l_index)  ||
         ',' || p_attr_rec.consigned_from_supp_flag_dsp(l_index)    ||
         ',' || p_attr_rec.last_billing_date(l_index)               ||
         ',' || p_attr_rec.consigned_billing_cycle_dsp(l_index)     ||
         ',' || p_attr_rec.consume_on_aging_flag_dsp(l_index)       ||
         ',' || p_attr_rec.aging_period_dsp(l_index)                ||
         ',' || p_attr_rec.replenishment_method(l_index)            ||
         ',' || p_attr_rec.replenishment_method_dsp(l_index)        ||
         ',' || p_attr_rec.vmi_min_days_dsp(l_index)                ||
         ',' || p_attr_rec.vmi_max_days_dsp(l_index)                ||
         ',' || p_attr_rec.fixed_order_quantity_dsp(l_index)        ||
         ',' || p_attr_rec.forecast_horizon_dsp(l_index));
  END LOOP;
  END IF;
END log;

--------------------------------------------------------------------------------
  --Start of Comments

  --Name: log

  --Function:
  --  For logging po_asl_documents_rec records

  --Parameters:

  --IN:
  --p_doc_rec             po_asl_documents_rec

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE log(
  p_doc_rec          IN        po_asl_documents_rec
)
AS

BEGIN
  IF p_doc_rec.user_key IS NOT NULL THEN
  FOR l_index IN 1 .. p_doc_rec.user_key.Count
  LOOP
     log(''  || p_doc_rec.USER_KEY(l_index)                        ||
         ',' || p_doc_rec.PROCESS_ACTION(l_index)                  ||
         ',' || p_doc_rec.using_organization_id(l_index)           ||
         ',' || p_doc_rec.using_organization_dsp(l_index)          ||
         ',' || p_doc_rec.SEQUENCE_NUM(l_index)                    ||
         ',' || p_doc_rec.DOCUMENT_TYPE_CODE(l_index)              ||
         ',' || p_doc_rec.DOCUMENT_TYPE_DSP(l_index)               ||
         ',' || p_doc_rec.DOCUMENT_HEADER_ID(l_index)              ||
         ',' || p_doc_rec.DOCUMENT_HEADER_DSP(l_index)             ||
         ',' || p_doc_rec.DOCUMENT_LINE_ID(l_index)                ||
         ',' || p_doc_rec.DOCUMENT_LINE_NUM_DSP(l_index)           ||
         ',' || p_doc_rec.ATTRIBUTE_CATEGORY(l_index)              ||
         ',' || p_doc_rec.ATTRIBUTE1(l_index)                      ||
         ',' || p_doc_rec.ATTRIBUTE2(l_index)                      ||
         ',' || p_doc_rec.ATTRIBUTE3(l_index)                      ||
         ',' || p_doc_rec.ATTRIBUTE4(l_index)                      ||
         ',' || p_doc_rec.ATTRIBUTE5(l_index)                      ||
         ',' || p_doc_rec.ATTRIBUTE6(l_index)                      ||
         ',' || p_doc_rec.ATTRIBUTE7(l_index)                      ||
         ',' || p_doc_rec.ATTRIBUTE8(l_index)                      ||
         ',' || p_doc_rec.ATTRIBUTE9(l_index)                      ||
         ',' || p_doc_rec.ATTRIBUTE10(l_index)                     ||
         ',' || p_doc_rec.ATTRIBUTE11(l_index)                     ||
         ',' || p_doc_rec.ATTRIBUTE12(l_index)                     ||
         ',' || p_doc_rec.ATTRIBUTE13(l_index)                     ||
         ',' || p_doc_rec.ATTRIBUTE14(l_index)                     ||
         ',' || p_doc_rec.ATTRIBUTE15(l_index)                     ||
         ',' || p_doc_rec.REQUEST_ID(l_index)                      ||
         ',' || p_doc_rec.PROGRAM_APPLICATION_ID(l_index)          ||
         ',' || p_doc_rec.PROGRAM_ID(l_index)                      ||
         ',' || p_doc_rec.PROGRAM_UPDATE_DATE(l_index)             ||
         ',' || p_doc_rec.ORG_ID(l_index));

  END LOOP;
  END IF;
END log;

--------------------------------------------------------------------------------
  --Start of Comments

  --Name: log

  --Function:
  --  For logging chv_authorizations_rec records

  --Parameters:

  --IN:
  --p_chv_rec             chv_authorizations_rec

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE log(
  p_chv_rec          IN        chv_authorizations_rec
)
AS

BEGIN
  IF p_chv_rec.user_key IS NOT NULL THEN
  FOR l_index IN 1 .. p_chv_rec.user_key.Count
  LOOP
     log(''  || p_chv_rec.USER_KEY(l_index)                         ||
         ',' || p_chv_rec.PROCESS_ACTION(l_index)                   ||
         ',' || p_chv_rec.using_organization_id(l_index)            ||
         ',' || p_chv_rec.using_organization_dsp(l_index)           ||
         ',' || p_chv_rec.AUTHORIZATION_CODE(l_index)               ||
         ',' || p_chv_rec.AUTHORIZATION_CODE_DSP(l_index)           ||
         ',' || p_chv_rec.AUTHORIZATION_SEQUENCE_DSP(l_index)       ||
         ',' || p_chv_rec.TIMEFENCE_DAYS_DSP(l_index)               ||
         ',' || p_chv_rec.ATTRIBUTE_CATEGORY(l_index)               ||
         ',' || p_chv_rec.ATTRIBUTE1(l_index)                       ||
         ',' || p_chv_rec.ATTRIBUTE2(l_index)                       ||
         ',' || p_chv_rec.ATTRIBUTE3(l_index)                       ||
         ',' || p_chv_rec.ATTRIBUTE4(l_index)                       ||
         ',' || p_chv_rec.ATTRIBUTE5(l_index)                       ||
         ',' || p_chv_rec.ATTRIBUTE6(l_index)                       ||
         ',' || p_chv_rec.ATTRIBUTE7(l_index)                       ||
         ',' || p_chv_rec.ATTRIBUTE8(l_index)                       ||
         ',' || p_chv_rec.ATTRIBUTE9(l_index)                       ||
         ',' || p_chv_rec.ATTRIBUTE10(l_index)                      ||
         ',' || p_chv_rec.ATTRIBUTE11(l_index)                      ||
         ',' || p_chv_rec.ATTRIBUTE12(l_index)                      ||
         ',' || p_chv_rec.ATTRIBUTE13(l_index)                      ||
         ',' || p_chv_rec.ATTRIBUTE14(l_index)                      ||
         ',' || p_chv_rec.ATTRIBUTE15(l_index)                      ||
         ',' || p_chv_rec.REQUEST_ID(l_index)                       ||
         ',' || p_chv_rec.PROGRAM_APPLICATION_ID(l_index)           ||
         ',' || p_chv_rec.PROGRAM_ID(l_index)                       ||
         ',' || p_chv_rec.PROGRAM_UPDATE_DATE(l_index));
  END LOOP;
  END IF;
END log;

--------------------------------------------------------------------------------
  --Start of Comments

  --Name: log

  --Function:
  --  For logging po_supplier_item_capacity_rec records

  --Parameters:

  --IN:
  --p_cap_rec             po_supplier_item_capacity_rec

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE log(
  p_cap_rec          IN        po_supplier_item_capacity_rec
)
AS

BEGIN
  IF p_cap_rec.user_key IS NOT NULL THEN
  FOR l_index IN 1 .. p_cap_rec.user_key.Count
  LOOP
     log(''  || p_cap_rec.USER_KEY(l_index)                         ||
         ',' || p_cap_rec.PROCESS_ACTION(l_index)                   ||
         ',' || p_cap_rec.using_organization_id(l_index)            ||
         ',' || p_cap_rec.using_organization_dsp(l_index)           ||
         ',' || p_cap_rec.FROM_DATE_DSP(l_index)                    ||
         ',' || p_cap_rec.TO_DATE_DSP(l_index)                      ||
         ',' || p_cap_rec.CAPACITY_PER_DAY_DSP(l_index)             ||
         ',' || p_cap_rec.ATTRIBUTE_CATEGORY(l_index)               ||
         ',' || p_cap_rec.ATTRIBUTE1(l_index)                       ||
         ',' || p_cap_rec.ATTRIBUTE2(l_index)                       ||
         ',' || p_cap_rec.ATTRIBUTE3(l_index)                       ||
         ',' || p_cap_rec.ATTRIBUTE4(l_index)                       ||
         ',' || p_cap_rec.ATTRIBUTE5(l_index)                       ||
         ',' || p_cap_rec.ATTRIBUTE6(l_index)                       ||
         ',' || p_cap_rec.ATTRIBUTE7(l_index)                       ||
         ',' || p_cap_rec.ATTRIBUTE8(l_index)                       ||
         ',' || p_cap_rec.ATTRIBUTE9(l_index)                       ||
         ',' || p_cap_rec.ATTRIBUTE10(l_index)                      ||
         ',' || p_cap_rec.ATTRIBUTE11(l_index)                      ||
         ',' || p_cap_rec.ATTRIBUTE12(l_index)                      ||
         ',' || p_cap_rec.ATTRIBUTE13(l_index)                      ||
         ',' || p_cap_rec.ATTRIBUTE14(l_index)                      ||
         ',' || p_cap_rec.ATTRIBUTE15(l_index)                      ||
         ',' || p_cap_rec.REQUEST_ID(l_index)                       ||
         ',' || p_cap_rec.PROGRAM_APPLICATION_ID(l_index)           ||
         ',' || p_cap_rec.PROGRAM_ID(l_index)                       ||
         ',' || p_cap_rec.PROGRAM_UPDATE_DATE(l_index));
  END LOOP;
  END IF;
END log;

--------------------------------------------------------------------------------
  --Start of Comments

  --Name: log

  --Function:
  --  For logging po_supplier_item_tolerance_rec records

  --Parameters:

  --IN:
  --p_tol_rec             po_supplier_item_tolerance_rec

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE log(
  p_tol_rec          IN        po_supplier_item_tolerance_rec
)
AS

BEGIN
  IF p_tol_rec.user_key IS NOT NULL THEN
  FOR l_index IN 1 .. p_tol_rec.user_key.Count
  LOOP
     log( ''  || p_tol_rec.USER_KEY(l_index)                         ||
          ',' || p_tol_rec.PROCESS_ACTION(l_index)                   ||
          ',' || p_tol_rec.using_organization_id(l_index)            ||
          ',' || p_tol_rec.using_organization_dsp(l_index)           ||
          ',' || p_tol_rec.NUMBER_OF_DAYS_DSP(l_index)               ||
          ',' || p_tol_rec.TOLERANCE_DSP(l_index)                    ||
          ',' || p_tol_rec.ATTRIBUTE_CATEGORY(l_index)               ||
          ',' || p_tol_rec.ATTRIBUTE1(l_index)                       ||
          ',' || p_tol_rec.ATTRIBUTE2(l_index)                       ||
          ',' || p_tol_rec.ATTRIBUTE3(l_index)                       ||
          ',' || p_tol_rec.ATTRIBUTE4(l_index)                       ||
          ',' || p_tol_rec.ATTRIBUTE5(l_index)                       ||
          ',' || p_tol_rec.ATTRIBUTE6(l_index)                       ||
          ',' || p_tol_rec.ATTRIBUTE7(l_index)                       ||
          ',' || p_tol_rec.ATTRIBUTE8(l_index)                       ||
          ',' || p_tol_rec.ATTRIBUTE9(l_index)                       ||
          ',' || p_tol_rec.ATTRIBUTE10(l_index)                      ||
          ',' || p_tol_rec.ATTRIBUTE11(l_index)                      ||
          ',' || p_tol_rec.ATTRIBUTE12(l_index)                      ||
          ',' || p_tol_rec.ATTRIBUTE13(l_index)                      ||
          ',' || p_tol_rec.ATTRIBUTE14(l_index)                      ||
          ',' || p_tol_rec.ATTRIBUTE15(l_index)                      ||
          ',' || p_tol_rec.REQUEST_ID(l_index)                       ||
          ',' || p_tol_rec.PROGRAM_APPLICATION_ID(l_index)           ||
          ',' || p_tol_rec.PROGRAM_ID(l_index)                       ||
          ',' || p_tol_rec.PROGRAM_UPDATE_DATE(l_index));
  END LOOP;
  END IF;
END log;

--------------------------------------------------------------------------------
  --Start of Comments

  --Name: log

  --Function:
  --  For logging po_tbl_number records

  --Parameters:

  --IN:
  --tbl_number            po_tbl_number

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE log(
  tbl_number         IN        po_tbl_number
)
AS
  l_string                VARCHAR2(4000);
BEGIN
  l_string := '';
  IF tbl_number IS NOT NULL THEN
  FOR l_index IN 1 .. tbl_number.Count
  LOOP
     l_string := l_string || tbl_number(l_index) || ',';
  END LOOP;
  END IF;
  Log(l_string);
END log;

--------------------------------------------------------------------------------
  --Start of Comments

  --Name: log

  --Function:
  --  For logging po_tbl_varchar2000 records

  --Parameters:

  --IN:
  --tbl_varchar           po_tbl_varchar2000

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE log(
  tbl_varchar        IN        po_tbl_varchar2000
)
AS

BEGIN
  IF tbl_varchar IS NOT NULL THEN
  FOR l_index IN 1 .. tbl_varchar.Count
  LOOP
     Log(tbl_varchar(l_index));
  END LOOP;
  END IF;
END log;

--------------------------------------------------------------------------------
  --Start of Comments

  --Name: log

  --Function:
  --  For logging po_tbl_varchar30 records

  --Parameters:

  --IN:
  --tbl_varchar           po_tbl_varchar30

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE log(
  tbl_varchar        IN        po_tbl_varchar30
)
AS

BEGIN
  IF tbl_varchar IS NOT NULL THEN
  FOR l_index IN 1 .. tbl_varchar.Count
  LOOP
     Log(tbl_varchar(l_index));
  END LOOP;
  END IF;
END log;

END PO_ASL_API_PVT;

/
