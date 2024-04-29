--------------------------------------------------------
--  DDL for Package Body PO_ASL_API_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ASL_API_GRP" AS
/* $Header: PO_ASL_API_GRP.plb 120.3.12010000.3 2014/04/28 07:35:21 vpeddi noship $ */

g_session_key   NUMBER;

PROCEDURE validate_asl_gt(
  x_return_status   OUT NOCOPY VARCHAR2
, x_return_msg      OUT NOCOPY VARCHAR2
);

PROCEDURE validate_asl_attr_gt(
  x_return_status   OUT NOCOPY VARCHAR2
, x_return_msg      OUT NOCOPY VARCHAR2
);

PROCEDURE validate_asl_doc_gt(
  x_return_status   OUT NOCOPY VARCHAR2
, x_return_msg      OUT NOCOPY VARCHAR2
);

PROCEDURE validate_chv_auth_gt(
  x_return_status   OUT NOCOPY VARCHAR2
, x_return_msg      OUT NOCOPY VARCHAR2
);

PROCEDURE validate_supp_item_cap_gt(
  x_return_status   OUT NOCOPY VARCHAR2
, x_return_msg      OUT NOCOPY VARCHAR2
);

PROCEDURE validate_supp_item_tol_gt(
  x_return_status   OUT NOCOPY VARCHAR2
, x_return_msg      OUT NOCOPY VARCHAR2
);

--------------------------------------------------------------------------------
  --Start of Comments

  --Name: process

  --Function:
  --  This will determine whether to do insert or update.
  --  Create will throw error if you are passing duplicate asl.
  --  Update will throw error if asl does not exists.
  --  Call Validation interface to perform field validations
  --  Call PO_ASL_API_PVT.reject_asl_record for the records in case any
  --  validation error.

  --Parameters:

  --IN:
  --  p_session_key     NUMBER

  --OUT:
  --  x_return_status   VARCHAR2
  --  x_return_msg      VARCHAR2

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE process(
  p_session_key     IN         NUMBER
, x_return_status   OUT NOCOPY VARCHAR2
, x_return_msg      OUT NOCOPY VARCHAR2
)
IS
  l_progress          NUMBER := 0;

  l_user_key_tbl      po_tbl_number;
  l_entity_name       po_tbl_varchar30;
  l_reject_reason     po_tbl_varchar2000;

  l_user_key_tbl1     po_tbl_number;
  l_entity_name1      po_tbl_varchar30;
  l_reject_reason1    po_tbl_varchar2000;

BEGIN
  po_asl_api_pvt.log('START ::: po_asl_api_grp.process');
  po_asl_api_pvt.log('p_session_key:' || p_session_key);
  g_session_key  := p_session_key;
  --Determine Create/Update when mode is Sync
  UPDATE po_approved_supplier_list_gt GT
  SET GT.process_action =
      determine_action(
        GT.item_id              ,
        GT.category_id          ,
        GT.using_organization_id,
        GT.vendor_id            ,
        GT.vendor_site_id
      )
  WHERE GT.process_action = PO_ASL_API_PUB.g_ACTION_SYNC;
  l_progress := 5;
  po_asl_api_pvt.log('count at prg ' || l_progress || ':' ||  SQL%ROWCOUNT);

  --Populate asl ids in case of update
  /* RR: Review Perf */
  UPDATE po_approved_supplier_list_gt GT
  SET asl_id =
     (SELECT  asl_id
        FROM  po_approved_supplier_list PASL
        WHERE (GT.item_id                  = PASL.item_id
               OR GT.category_id           = PASL.category_id)
              AND GT.using_organization_id = PASL.using_organization_id
              AND (GT.vendor_id            = PASL.vendor_id
                   OR GT.manufacturer_id   = PASL.manufacturer_id)
              AND Nvl(GT.vendor_site_id,-1)= Nvl(PASL.vendor_site_id,-1)
              AND ROWNUM < 2)
  WHERE GT.process_action = PO_ASL_API_PUB.g_ACTION_UPDATE;
  l_progress := 10;
  po_asl_api_pvt.log('count at prg ' || l_progress || ':' ||  SQL%ROWCOUNT);

  --Populate asl ids in case of create
  UPDATE po_approved_supplier_list_gt GT
  SET asl_id = po_approved_supplier_list_s.NEXTVAL
  WHERE GT.process_action = PO_ASL_API_PUB.g_ACTION_CREATE;

  l_progress := 15;
  po_asl_api_pvt.log('count at prg ' || l_progress || ':' ||  SQL%ROWCOUNT);

  UPDATE po_asl_attributes_gt PAA
  SET asl_id = (SELECT  asl_id
                  FROM  po_approved_supplier_list_gt PASL
                  WHERE PASL.user_key = PAA.user_key
                        AND ROWNUM < 2);

  l_progress := 20;
  po_asl_api_pvt.log('count at prg ' || l_progress || ':' ||  SQL%ROWCOUNT);

  UPDATE po_asl_documents_gt PAD
  SET asl_id = (SELECT  asl_id
                  FROM  po_approved_supplier_list_gt PASL
                  WHERE PASL.user_key = PAD.user_key
                        AND ROWNUM < 2);

  l_progress := 25;
  po_asl_api_pvt.log('count at prg ' || l_progress || ':' ||  SQL%ROWCOUNT);

  UPDATE chv_authorizations_gt CHV
  SET reference_id = (SELECT  asl_id
                        FROM  po_approved_supplier_list_gt PASL
                        WHERE PASL.user_key = CHV.user_key
                              AND ROWNUM < 2);

  l_progress := 30;
  po_asl_api_pvt.log('count at prg ' || l_progress || ':' ||  SQL%ROWCOUNT);

  UPDATE po_supplier_item_capacity_gt PSIC
  SET asl_id = (SELECT  asl_id
                  FROM  po_approved_supplier_list_gt PASL
                  WHERE PASL.user_key = PSIC.user_key
                        AND ROWNUM < 2);

  l_progress := 35;
  po_asl_api_pvt.log('count at prg ' || l_progress || ':' ||  SQL%ROWCOUNT);

  UPDATE po_supplier_item_tolerance_gt PSIT
  SET asl_id = (SELECT  asl_id
                  FROM  po_approved_supplier_list_gt PASL
                  WHERE PASL.user_key = PSIT.user_key
                        AND ROWNUM < 2);

  l_progress := 40;
  po_asl_api_pvt.log('count at prg ' || l_progress || ':' ||  SQL%ROWCOUNT);

  /*--Populate capacity id in case of update and
  --Capacity's process action is ADD
  UPDATE po_supplier_item_capacity_gt PSIC
  SET    capacity_id    = po_supplier_item_capacity_s.NEXTVAL
  WHERE  process_action = PO_ASL_API_PUB.g_ACTION_ADD;
  l_progress := 42;
  po_asl_api_pvt.log('count at prg ' || l_progress || ':' ||  SQL%ROWCOUNT);*/

  --Reject records if asl exist when mode is Create
  SELECT  user_key                               ,
          'po_approved_supplier_list_gt'         ,
          fnd_message.get_string('PO','DUPLICATE_ASL')
    BULK  COLLECT INTO
          l_user_key_tbl                         ,
          l_entity_name                          ,
          l_reject_reason
    FROM  po_approved_supplier_list_gt GT
    WHERE EXISTS
         (SELECT  asl_id
            FROM  po_approved_supplier_list PASL
            WHERE (GT.item_id                   = PASL.item_id
                   OR GT.category_id            = PASL.category_id)
                  AND GT.using_organization_id  = PASL.using_organization_id
                  AND (GT.vendor_id             = PASL.vendor_id
                       OR GT.manufacturer_id    = PASL.manufacturer_id)
                  AND Nvl(GT.vendor_site_id,-1) = Nvl(PASL.vendor_site_id,-1))
         AND GT.process_action = PO_ASL_API_PUB.g_ACTION_CREATE;

  l_progress := 45;
  l_user_key_tbl1  := l_user_key_tbl;
  l_entity_name1   := l_entity_name;
  l_reject_reason1 := l_reject_reason;
  --Reject records if asl doesn't exist when mode is update.
  SELECT  user_key                               ,
          'po_approved_supplier_list_gt'         ,
          fnd_message.get_string('PO','ASL_DOES_NOT_EXIST')
    BULK  COLLECT INTO
          l_user_key_tbl                         ,
          l_entity_name                          ,
          l_reject_reason
    FROM  po_approved_supplier_list_gt GT
    WHERE NOT EXISTS
          (SELECT  asl_id
             FROM  po_approved_supplier_list PASL
             WHERE (GT.item_id                  = PASL.item_id
                    OR GT.category_id           = PASL.category_id)
                   AND GT.using_organization_id = PASL.using_organization_id
                   AND (GT.vendor_id            = PASL.vendor_id
                        OR GT.manufacturer_id   = PASL.manufacturer_id)
                   AND Nvl(GT.vendor_site_id,-1) = Nvl(PASL.vendor_site_id,-1))
          AND GT.process_action = PO_ASL_API_PUB.g_ACTION_UPDATE;

  l_progress := 50;
  l_user_key_tbl1  := l_user_key_tbl1  MULTISET UNION ALL l_user_key_tbl ;
  l_entity_name1   := l_entity_name1   MULTISET UNION ALL l_entity_name  ;
  l_reject_reason1 := l_reject_reason1 MULTISET UNION ALL l_reject_reason;

  --Reject records if attributes mode is add, asl mode is update/delete and
  --attributes already exists for that org
  SELECT  PAAGT.user_key                         ,
          'po_asl_attributes_gt'                 ,
          fnd_message.get_string('PO','DUPLICATE_ATTRIBUTES')
    BULK  COLLECT INTO
          l_user_key_tbl                         ,
          l_entity_name                          ,
          l_reject_reason
    FROM  po_asl_attributes_gt PAAGT,
          po_approved_supplier_list_gt ASLGT
    WHERE EXISTS
          (SELECT  1
             FROM  po_asl_attributes PAA
             WHERE PAAGT.asl_id                    = PAA.asl_id
                   AND PAAGT.using_organization_id = PAA.using_organization_id)
          AND ASLGT.user_key       = PAAGT.user_key
          AND ASLGT.process_action = PO_ASL_API_PUB.g_ACTION_UPDATE
          AND PAAGT.process_action = PO_ASL_API_PUB.g_ACTION_ADD;

  l_progress := 55;
  l_user_key_tbl1  := l_user_key_tbl1  MULTISET UNION ALL l_user_key_tbl ;
  l_entity_name1   := l_entity_name1   MULTISET UNION ALL l_entity_name  ;
  l_reject_reason1 := l_reject_reason1 MULTISET UNION ALL l_reject_reason;

  --Reject records if attributes mode is add, asl mode is create and
  --attributes already exists for that org, i.e., duplicate input
  SELECT  PAAGT.user_key                         ,
          'po_asl_attributes_gt'                 ,
          fnd_message.get_string('PO','DUPLICATE_ATTRIBUTES')
    BULK  COLLECT INTO
          l_user_key_tbl                         ,
          l_entity_name                          ,
          l_reject_reason
    FROM  po_asl_attributes_gt PAAGT,
          po_approved_supplier_list_gt ASLGT
    WHERE 2 <=
          (SELECT  Count(user_key)
             FROM  po_asl_attributes_gt PAA
             WHERE PAAGT.asl_id                    = PAA.asl_id
                   AND PAAGT.using_organization_id = PAA.using_organization_id)
          AND ASLGT.user_key       = PAAGT.user_key
          AND ASLGT.process_action = PO_ASL_API_PUB.g_ACTION_CREATE
          AND PAAGT.process_action = PO_ASL_API_PUB.g_ACTION_ADD;

  l_progress := 57;
  l_user_key_tbl1  := l_user_key_tbl1  MULTISET UNION ALL l_user_key_tbl ;
  l_entity_name1   := l_entity_name1   MULTISET UNION ALL l_entity_name  ;
  l_reject_reason1 := l_reject_reason1 MULTISET UNION ALL l_reject_reason;

  --Reject records if attributes mode is delete, asl mode is update and
  --attributes doesn't exists for that org
  SELECT  PAAGT.user_key                         ,
          'po_asl_attributes_gt'                 ,
          fnd_message.get_string('PO','ATTRIBUTES_NOT_EXIST')
    BULK  COLLECT INTO
          l_user_key_tbl                         ,
          l_entity_name                          ,
          l_reject_reason
    FROM  po_asl_attributes_gt PAAGT,
          po_approved_supplier_list_gt ASLGT
    WHERE NOT EXISTS
          (SELECT  1
             FROM  po_asl_attributes PAA
             WHERE PAAGT.asl_id                    = PAA.asl_id
                   AND PAAGT.using_organization_id = PAA.using_organization_id)
          AND ASLGT.user_key       = PAAGT.user_key
          AND ASLGT.process_action = PO_ASL_API_PUB.g_ACTION_UPDATE
          AND PAAGT.process_action IN
              (PO_ASL_API_PUB.g_ACTION_DELETE, PO_ASL_API_PUB.g_ACTION_UPDATE);

  l_progress := 60;
  l_user_key_tbl1  := l_user_key_tbl1  MULTISET UNION ALL l_user_key_tbl ;
  l_entity_name1   := l_entity_name1   MULTISET UNION ALL l_entity_name  ;
  l_reject_reason1 := l_reject_reason1 MULTISET UNION ALL l_reject_reason;
    --Reject records if document mode is add, asl mode is update and
    --document already exists for that org
  SELECT  DOCGT.user_key                         ,
          'po_asl_documents_gt'                  ,
          fnd_message.get_string('PO','DUPLICATE_DOCUMENT')
    BULK  COLLECT INTO
          l_user_key_tbl                         ,
          l_entity_name                          ,
          l_reject_reason
    FROM  po_asl_documents_gt DOCGT,
          po_approved_supplier_list_gt ASLGT
    WHERE EXISTS
          (SELECT  1
             FROM  po_asl_documents PAD
             WHERE DOCGT.document_header_id        = PAD.document_header_id
                   AND DOCGT.asl_id                = PAD.asl_id
                   AND DOCGT.using_organization_id = PAD.using_organization_id)
          AND ASLGT.user_key       = DOCGT.user_key
          AND ASLGT.process_action = PO_ASL_API_PUB.g_ACTION_UPDATE
          AND DOCGT.process_action = PO_ASL_API_PUB.g_ACTION_ADD;

  l_progress := 62;
  l_user_key_tbl1  := l_user_key_tbl1  MULTISET UNION ALL l_user_key_tbl ;
  l_entity_name1   := l_entity_name1   MULTISET UNION ALL l_entity_name  ;
  l_reject_reason1 := l_reject_reason1 MULTISET UNION ALL l_reject_reason;
    --Reject records if document mode is delete, asl mode is update and
    --document doesn't exists for that org
  SELECT  DOCGT.user_key                         ,
          'po_asl_documents_gt'                  ,
          fnd_message.get_string('PO','DOCUMENT_NOT_EXIST')
    BULK  COLLECT INTO
          l_user_key_tbl                         ,
          l_entity_name                          ,
          l_reject_reason
    FROM  po_asl_documents_gt DOCGT,
          po_approved_supplier_list_gt ASLGT
    WHERE NOT EXISTS
          (SELECT  1
             FROM  po_asl_documents PAD
             WHERE DOCGT.document_header_id        = PAD.document_header_id
                   AND DOCGT.asl_id                = PAD.asl_id
                   AND DOCGT.using_organization_id = PAD.using_organization_id)
          AND ASLGT.user_key       = DOCGT.user_key
          AND ASLGT.process_action = PO_ASL_API_PUB.g_ACTION_UPDATE
          AND DOCGT.process_action IN
              (PO_ASL_API_PUB.g_ACTION_DELETE, PO_ASL_API_PUB.g_ACTION_UPDATE);

  l_progress := 65;
  l_user_key_tbl1  := l_user_key_tbl1  MULTISET UNION ALL l_user_key_tbl ;
  l_entity_name1   := l_entity_name1   MULTISET UNION ALL l_entity_name  ;
  l_reject_reason1 := l_reject_reason1 MULTISET UNION ALL l_reject_reason;
  --Reject records if document mode is add, asl mode is create and
  --document already exists for that org
  SELECT  DOCGT.user_key                         ,
          'po_asl_documents_gt'                  ,
          fnd_message.get_string('PO','DUPLICATE_DOCUMENT')
    BULK  COLLECT INTO
          l_user_key_tbl                         ,
          l_entity_name                          ,
          l_reject_reason
    FROM  po_asl_documents_gt DOCGT,
          po_approved_supplier_list_gt ASLGT
    WHERE 2 <=
          (SELECT  Count(user_key)
             FROM  po_asl_documents_gt PAD
             WHERE DOCGT.document_header_id        = PAD.document_header_id
                   AND DOCGT.asl_id                = PAD.asl_id
                   AND DOCGT.using_organization_id = PAD.using_organization_id)
          AND ASLGT.user_key       = DOCGT.user_key
          AND ASLGT.process_action = PO_ASL_API_PUB.g_ACTION_CREATE
          AND DOCGT.process_action = PO_ASL_API_PUB.g_ACTION_ADD;

  l_progress := 70;
  l_user_key_tbl1  := l_user_key_tbl1  MULTISET UNION ALL l_user_key_tbl ;
  l_entity_name1   := l_entity_name1   MULTISET UNION ALL l_entity_name  ;
  l_reject_reason1 := l_reject_reason1 MULTISET UNION ALL l_reject_reason;
  --Reject records if authorization process mode is add, asl mode is update
  --and authorization code or sequence already exists for that org
  SELECT  CHVGT.user_key                         ,
          'chv_authorizations_gt'                ,
          fnd_message.get_string('PO','DUPLICATE_AUTHORIZATION')
    BULK  COLLECT INTO
          l_user_key_tbl                         ,
          l_entity_name                          ,
          l_reject_reason
    FROM  chv_authorizations_gt CHVGT,
          po_approved_supplier_list_gt ASLGT
    WHERE EXISTS
          (SELECT  1
             FROM  chv_authorizations CHV
             WHERE CHVGT.reference_id              = CHV.reference_id
                   AND CHVGT.using_organization_id = CHV.using_organization_id
                   AND (CHVGT.authorization_code   = CHV.authorization_code
                        OR
                    CHVGT.authorization_sequence_dsp=CHV.authorization_sequence)
          )
          AND CHVGT.user_key       = ASLGT.user_key
          AND ASLGT.process_action = PO_ASL_API_PUB.g_ACTION_UPDATE
          AND CHVGT.process_action = PO_ASL_API_PUB.g_ACTION_ADD;

  l_progress := 72;
  l_user_key_tbl1  := l_user_key_tbl1  MULTISET UNION ALL l_user_key_tbl ;
  l_entity_name1   := l_entity_name1   MULTISET UNION ALL l_entity_name  ;
  l_reject_reason1 := l_reject_reason1 MULTISET UNION ALL l_reject_reason;
  --Reject records if authorization process mode is delete, asl mode is update
  --and authorization code and sequence not exists for that org
  SELECT  CHVGT.user_key                         ,
          'chv_authorizations_gt'                ,
          fnd_message.get_string('PO','AUTHORIZATION_NOT_EXIST')
    BULK  COLLECT INTO
          l_user_key_tbl                         ,
          l_entity_name                          ,
          l_reject_reason
    FROM  chv_authorizations_gt CHVGT,
          po_approved_supplier_list_gt ASLGT
    WHERE NOT EXISTS
          (SELECT  1
             FROM  chv_authorizations CHV
             WHERE CHVGT.reference_id              = CHV.reference_id
                   AND CHVGT.using_organization_id = CHV.using_organization_id
                   AND CHVGT.authorization_code    = CHV.authorization_code
                   AND CHVGT.authorization_sequence_dsp=CHV.authorization_sequence
          )
          AND CHVGT.user_key       = ASLGT.user_key
          AND ASLGT.process_action = PO_ASL_API_PUB.g_ACTION_UPDATE
          AND CHVGT.process_action IN
              (PO_ASL_API_PUB.g_ACTION_DELETE, PO_ASL_API_PUB.g_ACTION_UPDATE);

  l_progress := 75;
  l_user_key_tbl1  := l_user_key_tbl1  MULTISET UNION ALL l_user_key_tbl ;
  l_entity_name1   := l_entity_name1   MULTISET UNION ALL l_entity_name  ;
  l_reject_reason1 := l_reject_reason1 MULTISET UNION ALL l_reject_reason;
  --Reject records if authorization process mode is add, asl mode is create
  --and authorization code or sequence already exists for that org
  SELECT  CHVGT.user_key                         ,
          'chv_authorizations_gt'                ,
          fnd_message.get_string('PO','DUPLICATE_AUTHORIZATION')
    BULK  COLLECT INTO
          l_user_key_tbl                         ,
          l_entity_name                          ,
          l_reject_reason
    FROM  chv_authorizations_gt CHVGT            ,
          po_approved_supplier_list_gt ASLGT
    WHERE 2 <=
          (SELECT  Count(user_key)
             FROM  chv_authorizations_gt CHV
             WHERE CHVGT.reference_id              = CHV.reference_id
                   AND CHVGT.using_organization_id = CHV.using_organization_id
                   AND (CHVGT.authorization_code   = CHV.authorization_code
                        OR CHVGT.authorization_sequence_dsp =
                           CHV.authorization_sequence_dsp)
           )
          AND CHVGT.user_key       = ASLGT.user_key
          AND ASLGT.process_action = PO_ASL_API_PUB.g_ACTION_CREATE
          AND CHVGT.process_action = PO_ASL_API_PUB.g_ACTION_ADD;

  --*************************************************************************
  --Duplicate check is not required for po_supplier_item_capacity_gt
  --as there is a check in the validation for dates overlapping. That check
  --covers the duplication as well
  --*************************************************************************

  l_progress := 78;
  l_user_key_tbl1  := l_user_key_tbl1  MULTISET UNION ALL l_user_key_tbl ;
  l_entity_name1   := l_entity_name1   MULTISET UNION ALL l_entity_name  ;
  l_reject_reason1 := l_reject_reason1 MULTISET UNION ALL l_reject_reason;
  --Reject records if capacity process mode is delete, asl mode is update
  --and record does not exist for that org
  SELECT  CAPGT.user_key                         ,
          'po_supplier_item_capacity_gt'        ,
          fnd_message.get_string('PO','CAPACITY_NOT_EXIST')
    BULK  COLLECT INTO
          l_user_key_tbl                         ,
          l_entity_name                          ,
          l_reject_reason
    FROM  po_supplier_item_capacity_gt CAPGT     ,
          po_approved_supplier_list_gt ASLGT
    WHERE NOT EXISTS
          (SELECT  1
             FROM  po_supplier_item_capacity CAP
             WHERE CAPGT.asl_id                    = CAP.asl_id
                   AND CAPGT.using_organization_id = CAP.using_organization_id
                   AND Nvl(CAPGT.to_date_dsp, SYSDATE) =
                       Nvl(CAP.to_date, SYSDATE)
                   AND CAPGT.from_date_dsp         = CAP.from_date
                   AND CAPGT.capacity_per_day_dsp  = CAP.capacity_per_day
          )
          AND CAPGT.user_key       = ASLGT.user_key
          AND ASLGT.process_action = PO_ASL_API_PUB.g_ACTION_UPDATE
          AND CAPGT.process_action IN
              (PO_ASL_API_PUB.g_ACTION_DELETE, PO_ASL_API_PUB.g_ACTION_UPDATE);

  l_progress := 80;
  l_user_key_tbl1  := l_user_key_tbl1  MULTISET UNION ALL l_user_key_tbl ;
  l_entity_name1   := l_entity_name1   MULTISET UNION ALL l_entity_name  ;
  l_reject_reason1 := l_reject_reason1 MULTISET UNION ALL l_reject_reason;
  --Reject records if tolerance process mode is add, asl mode is update
  --and record already exists for that org
  SELECT  TOLGT.user_key                         ,
          'po_supplier_item_tolerance_gt'        ,
          fnd_message.get_string('PO','DUPLICATE_TOLERANCE')
    BULK  COLLECT INTO
          l_user_key_tbl                         ,
          l_entity_name                          ,
          l_reject_reason
    FROM  po_supplier_item_tolerance_gt TOLGT,
          po_approved_supplier_list_gt ASLGT
    WHERE EXISTS
          (SELECT  1
             FROM  po_supplier_item_tolerance TOL
             WHERE TOLGT.asl_id                    = TOL.asl_id
                   AND TOLGT.using_organization_id = TOL.using_organization_id
                   AND TOLGT.number_of_days_dsp    = TOL.number_of_days
          )
          AND TOLGT.user_key       = ASLGT.user_key
          AND ASLGT.process_action = PO_ASL_API_PUB.g_ACTION_UPDATE
          AND TOLGT.process_action = PO_ASL_API_PUB.g_ACTION_ADD;

  l_progress := 82;
  l_user_key_tbl1  := l_user_key_tbl1  MULTISET UNION ALL l_user_key_tbl ;
  l_entity_name1   := l_entity_name1   MULTISET UNION ALL l_entity_name  ;
  l_reject_reason1 := l_reject_reason1 MULTISET UNION ALL l_reject_reason;
  --Reject records if tolerance process mode is delete, asl mode is update
  --and record does not exist for that org
  SELECT  TOLGT.user_key                         ,
          'po_supplier_item_tolerance_gt'        ,
          fnd_message.get_string('PO','TOLERANCE_NOT_EXIST')
    BULK  COLLECT INTO
          l_user_key_tbl                         ,
          l_entity_name                          ,
          l_reject_reason
    FROM  po_supplier_item_tolerance_gt TOLGT,
          po_approved_supplier_list_gt ASLGT
    WHERE NOT EXISTS
          (SELECT  1
             FROM  po_supplier_item_tolerance TOL
             WHERE TOLGT.asl_id                    = TOL.asl_id
                   AND TOLGT.using_organization_id = TOL.using_organization_id
                   AND TOLGT.number_of_days_dsp    = TOL.number_of_days
          )
          AND TOLGT.user_key       = ASLGT.user_key
          AND ASLGT.process_action = PO_ASL_API_PUB.g_ACTION_UPDATE
          AND TOLGT.process_action IN
              (PO_ASL_API_PUB.g_ACTION_DELETE, PO_ASL_API_PUB.g_ACTION_UPDATE);

  l_progress := 85;
  l_user_key_tbl1  := l_user_key_tbl1  MULTISET UNION ALL l_user_key_tbl ;
  l_entity_name1   := l_entity_name1   MULTISET UNION ALL l_entity_name  ;
  l_reject_reason1 := l_reject_reason1 MULTISET UNION ALL l_reject_reason;
  --Reject records if tolerance process mode is add, asl mode is create
  --and authorization code or sequence already exists for that org
  SELECT  TOLGT.user_key                         ,
          'po_supplier_item_tolerance_gt'        ,
          fnd_message.get_string('PO','DUPLICATE_TOLERANCE')
    BULK  COLLECT INTO
          l_user_key_tbl                         ,
          l_entity_name                          ,
          l_reject_reason
    FROM  po_supplier_item_tolerance_gt TOLGT,
          po_approved_supplier_list_gt ASLGT
    WHERE 2 <=
          (SELECT  Count(user_key)
             FROM  po_supplier_item_tolerance_gt TOL
             WHERE TOLGT.asl_id                    = TOL.asl_id
                   AND TOLGT.using_organization_id = TOL.using_organization_id
                   AND TOLGT.number_of_days_dsp    = TOL.number_of_days_dsp
          )
          AND TOLGT.user_key       = ASLGT.user_key
          AND ASLGT.process_action = PO_ASL_API_PUB.g_ACTION_CREATE
          AND TOLGT.process_action = PO_ASL_API_PUB.g_ACTION_ADD;

  l_progress := 90;
  l_user_key_tbl1  := l_user_key_tbl1  MULTISET UNION ALL l_user_key_tbl ;
  l_entity_name1   := l_entity_name1   MULTISET UNION ALL l_entity_name  ;
  l_reject_reason1 := l_reject_reason1 MULTISET UNION ALL l_reject_reason;

  po_asl_api_pvt.log('PO_ASL_API_GRP Rejected Rec count:'
                      || l_user_key_tbl1.count);

  --call po_asl_api_pvt.reject_asl_record for above rejected records
  IF l_user_key_tbl1.Count > 0
  THEN
    po_asl_api_pvt.reject_asl_record(
      p_user_key_tbl       =>  l_user_key_tbl1,
      p_rejection_reason   =>  l_reject_reason1,
      p_entity_name        =>  l_entity_name1,
      p_session_key        =>  g_session_key,
      x_return_status      =>  x_return_status,
      x_return_msg         =>  x_return_msg
    );
  END IF;
  l_progress := 91;
  --Peform validation on fields data
  validate_asl_gt(
    x_return_status      =>  x_return_status,
    x_return_msg         =>  x_return_msg
  );
  l_progress := 92;
  validate_asl_attr_gt(
    x_return_status      =>  x_return_status,
    x_return_msg         =>  x_return_msg
  );
  l_progress := 95;
  validate_asl_doc_gt(
    x_return_status      =>  x_return_status,
    x_return_msg         =>  x_return_msg
  );
  l_progress := 96;
  validate_chv_auth_gt(
    x_return_status      =>  x_return_status,
    x_return_msg         =>  x_return_msg
  );
  l_progress := 97;
  validate_supp_item_cap_gt(
    x_return_status      =>  x_return_status,
    x_return_msg         =>  x_return_msg
  );
  l_progress := 98;
  validate_supp_item_tol_gt(
    x_return_status      =>  x_return_status,
    x_return_msg         =>  x_return_msg
  );
  l_progress := 99;
  --call the po_asl_api_pub.process for the next steps.
  po_asl_api_pvt.process(
    p_session_key        => p_session_key,
    x_return_status      => x_return_status,
    x_return_msg         => x_return_msg
  );
  l_progress := 100;
  po_asl_api_pvt.log('END ::: po_asl_api_grp.process');

EXCEPTION

  WHEN OTHERS THEN

    po_asl_api_pvt.log('po_asl_api_grp.process : when others exception at '
                       || l_progress || ';' || SQLERRM );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_return_msg := SQLERRM;

END process;

--------------------------------------------------------------------------------
  --Start of Comments

  --Name: validate_asl_gt

  --Function:
  --  This will validate data in po_approved_supplier_list_gt table

  --Parameters:

  --OUT:
  --  x_return_status   VARCHAR2
  --  x_return_msg      VARCHAR2

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE validate_asl_gt(
  x_return_status   OUT NOCOPY VARCHAR2
, x_return_msg      OUT NOCOPY VARCHAR2
)
IS
  l_progress          NUMBER := 0;

  l_user_key_tbl      po_tbl_number;
  l_entity_name       po_tbl_varchar30;
  l_reject_reason  po_tbl_varchar2000;
  l_user_key_tbl1     po_tbl_number;
  l_entity_name1      po_tbl_varchar30;
  l_reject_reason1 po_tbl_varchar2000;

BEGIN
  po_asl_api_pvt.log('START ::: po_asl_api_grp.validate_asl_gt');
  SELECT user_key                                    ,
         entity                                      ,
         msg
  BULK   COLLECT INTO
         l_user_key_tbl                              ,
         l_entity_name                               ,
         l_reject_reason
  FROM (
    --Reject records if item and category both exists for the same ASL
    SELECT  user_key                                 ,
            'po_approved_supplier_list_gt' AS entity ,
            fnd_message.get_string('PO','ITEM_CATEGORY_BOTH_EXIST') AS msg
      FROM  po_approved_supplier_list_gt ASLGT
      WHERE ASLGT.item_id         IS NOT NULL
            AND ASLGT.category_id IS NOT NULL

    UNION ALL
    --Reject records if item and category both empty
    SELECT  user_key                                 ,
            'po_approved_supplier_list_gt' AS entity ,
            fnd_message.get_string('PO','ITEM_CATEGORY_BOTH_EMPTY') AS msg
      FROM  po_approved_supplier_list_gt ASLGT
      WHERE (ASLGT.item_id         IS NULL
             AND ASLGT.category_id IS NULL)
            OR (Trim(ASLGT.item_id)      IS NULL
             AND Trim(ASLGT.category_id) IS NULL)

    UNION ALL
    --Reject records if vendor business type is empty or null
    SELECT  user_key                                 ,
            'po_approved_supplier_list_gt' AS entity ,
            fnd_message.get_string('PO','INVALID_BUSINESS_TYPE') AS msg
      FROM  po_approved_supplier_list_gt ASLGT
      WHERE ASLGT.vendor_business_type IS NULL
            OR Upper(ASLGT.vendor_business_type) NOT IN
            (SELECT  lookup_code
               FROM  po_lookup_codes
               WHERE lookup_type  = 'ASL_VENDOR_BUSINESS_TYPE')

    UNION ALL
    --Reject records if vendor_id is empty
    SELECT  user_key                                 ,
           'po_approved_supplier_list_gt' AS entity  ,
           fnd_message.get_string('PO','VENDOR_EMPTY') AS msg
     FROM  po_approved_supplier_list_gt ASLGT
     WHERE ASLGT.vendor_id IS NULL
           AND  Upper(vendor_business_type) <> 'MANUFACTURER'

    UNION ALL
    --Reject records if status_id is empty
    SELECT  user_key                                 ,
           'po_approved_supplier_list_gt' AS entity  ,
           fnd_message.get_string('PO','STATUS_EMPTY') AS msg
     FROM  po_approved_supplier_list_gt ASLGT
     WHERE ASLGT.asl_status_id IS NULL
  );

  l_progress := 30;

  SELECT user_key                                    ,
         entity                                      ,
         msg
  BULK   COLLECT INTO
         l_user_key_tbl1                             ,
         l_entity_name1                              ,
         l_reject_reason1
  FROM (
    --Reject records if manufacturer_asl_id is empty when business type is
    --'DISTRIBUTOR'
    SELECT  user_key                                 ,
           'po_approved_supplier_list_gt' AS entity  ,
           fnd_message.get_string('PO','MANUFACTURER_ASL_MANDATORY') AS msg
     FROM  po_approved_supplier_list_gt ASLGT
     WHERE ASLGT.manufacturer_asl_id IS NULL
           AND Upper(ASLGT.vendor_business_type) = 'DISTRIBUTOR'

    UNION ALL
    --Reject records if review date entered and is past date
    SELECT  user_key                                 ,
           'po_approved_supplier_list_gt' AS entity  ,
           fnd_message.get_string('PO','INVALID_REVIEW_DATE') AS msg
     FROM  po_approved_supplier_list_gt ASLGT
     WHERE ASLGT.review_by_date     IS NOT NULL
           AND ASLGT.review_by_date < SYSDATE

    UNION ALL
    --During update ASL, business type can't be editable if the value is DB is
    --'MANUFACTURER'
    SELECT  user_key                                 ,
           'po_approved_supplier_list_gt' AS entity  ,
           fnd_message.get_string('PO','BUSINESS_TYPE_NOT_EDITABLE') AS msg
     FROM  po_approved_supplier_list_gt ASLGT
     WHERE ASLGT.process_action = PO_ASL_API_PUB.g_ACTION_UPDATE
           AND
           EXISTS (SELECT  asl_id
                     FROM  po_approved_supplier_list ASL
                     WHERE ASL.asl_id                      = ASLGT.asl_id
                           AND Upper(ASL.vendor_business_type) = 'MANUFACTURER')
           AND Upper(ASLGT.vendor_business_type)  <> 'MANUFACTURER'

    UNION ALL
    --Reject records if business type is MANUFACTURER and manufacter id doesn't
    --exist also reject if vendor exists for the same case
    SELECT  user_key                                 ,
           'po_approved_supplier_list_gt' AS entity  ,
           fnd_message.get_string('PO','VENDOR_INVALID_EXP_MANUFACTUR') AS msg
     FROM  po_approved_supplier_list_gt ASLGT
     WHERE Upper(ASLGT.vendor_business_type) = 'MANUFACTURER'
           AND (ASLGT.manufacturer_id IS NULL
             OR ASLGT.vendor_id       IS NOT NULL)
  );

  l_progress := 80;

  l_user_key_tbl1  := l_user_key_tbl1  MULTISET UNION ALL l_user_key_tbl ;
  l_entity_name1   := l_entity_name1   MULTISET UNION ALL l_entity_name  ;
  l_reject_reason1 := l_reject_reason1 MULTISET UNION ALL l_reject_reason;

  SELECT user_key                                    ,
         entity                                      ,
         msg
  BULK   COLLECT INTO
         l_user_key_tbl                              ,
         l_entity_name                               ,
         l_reject_reason
  FROM (
    --Reject records when business type is MANUFACTURER and if there are any
    --child records exist
    SELECT  user_key                                 ,
            'po_approved_supplier_list_gt' AS entity ,
            fnd_message.get_string('PO','MANUFAC_INVALID_AUTH_ENTRY') AS msg
      FROM  po_approved_supplier_list_gt ASLGT
      WHERE Upper(ASLGT.vendor_business_type) = 'MANUFACTURER'
            AND
            (EXISTS
             (SELECT  1
                FROM  po_asl_attributes_gt PAA
                WHERE PAA.asl_id                = ASLGT.asl_id
                      AND PAA.user_key          = ASLGT.user_key)
            OR
             EXISTS
             (SELECT  1
                FROM  chv_authorizations_gt CHV
                WHERE CHV.reference_id          = ASLGT.asl_id
                      AND CHV.user_key          = ASLGT.user_key)
            OR
             EXISTS
             (SELECT  1
                FROM  po_asl_documents_gt PAD
                WHERE PAD.asl_id                = ASLGT.asl_id
                      AND PAD.user_key          = ASLGT.user_key)
            OR
             EXISTS
             (SELECT  1
                FROM  po_supplier_item_capacity_gt PSIC
                WHERE PSIC.asl_id               = ASLGT.asl_id
                      AND PSIC.user_key         = ASLGT.user_key)
            OR
             EXISTS
             (SELECT  1
                FROM  po_supplier_item_tolerance_gt PSIT
                WHERE PSIT.asl_id               = ASLGT.asl_id
                      AND PSIT.user_key         = ASLGT.user_key)));

  l_progress := 90;

  l_user_key_tbl1  := l_user_key_tbl1  MULTISET UNION ALL l_user_key_tbl ;
  l_entity_name1   := l_entity_name1   MULTISET UNION ALL l_entity_name  ;
  l_reject_reason1 := l_reject_reason1 MULTISET UNION ALL l_reject_reason;
  --call po_asl_api_pvt.reject_asl_record for above rejected records
  po_asl_api_pvt.log('validate_asl_gt: reject count:' || l_user_key_tbl1.Count);
  IF l_user_key_tbl1.Count > 0
  THEN
    po_asl_api_pvt.reject_asl_record(
      p_user_key_tbl    => l_user_key_tbl1 ,
      p_rejection_reason=> l_reject_reason1,
      p_entity_name     => l_entity_name1  ,
      p_session_key     => g_session_key   ,
      x_return_status   => x_return_status ,
      x_return_msg      => x_return_msg
    );
  END IF;

  l_progress := 100;
  po_asl_api_pvt.log('END ::: po_asl_api_grp.validate_asl_gt');

EXCEPTION

  WHEN OTHERS THEN

    po_asl_api_pvt.log('validate_asl_gt : when others exception at '
                       || l_progress || ';' || SQLERRM );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_return_msg := SQLERRM;

END validate_asl_gt;


--------------------------------------------------------------------------------
  --Start of Comments

  --Name: validate_asl_attr_gt

  --Function:
  --  This will validate data in po_asl_attributes_gt table

  --Parameters:

  --OUT:
  --  x_return_status   VARCHAR2
  --  x_return_msg      VARCHAR2

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE validate_asl_attr_gt(
  x_return_status   OUT NOCOPY VARCHAR2
, x_return_msg      OUT NOCOPY VARCHAR2
)
IS
  l_progress          NUMBER := 0;
  l_msg_count         NUMBER;
  l_msg_data          VARCHAR2(2000);
  l_validation_error_name  VARCHAR2(30) ;

  l_user_key_tbl      po_tbl_number;
  l_entity_name       po_tbl_varchar30;
  l_reject_reason     po_tbl_varchar2000;
  l_user_key_tbl1     po_tbl_number;
  l_entity_name1      po_tbl_varchar30;
  l_reject_reason1    po_tbl_varchar2000;

BEGIN
  po_asl_api_pvt.log('START ::: po_asl_api_grp.validate_asl_attr_gt');
  SELECT user_key                                ,
         entity                                  ,
         msg
  BULK   COLLECT INTO
         l_user_key_tbl                          ,
         l_entity_name                           ,
         l_reject_reason
  FROM (
    --Reject records if item or site is null and country code is not null
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','COUNTRY_CODE_NOT_EMPTY') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE (PAAGT.item_id           IS NULL
             OR PAAGT.vendor_site_id IS NULL)
            AND PAAGT.country_of_origin_code_dsp IS NOT NULL

    UNION ALL
    --Reject records if Purchasing UOM empty and enable_plan_schedule_flag or
    --enable_ship_schedule_flag is checked
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','PURCHASING_UOM_MANDATORY') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE (PAAGT.enable_plan_schedule_flag_dsp    = 'Y'
             OR PAAGT.enable_ship_schedule_flag_dsp = 'Y')
            AND (PAAGT.purchasing_unit_of_measure_dsp IS NULL
                 OR Trim(PAAGT.purchasing_unit_of_measure_dsp) = '')

    UNION ALL
    --Reject records if enable_autoschedule_flag is Y when
    --enable_plan_schedule_flag_dsp and enable_ship_schedule_flag_dsp
    --are unchecked.
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','INVALID_AUTOSCHEDULE_FLAG') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE Nvl(PAAGT.enable_plan_schedule_flag_dsp,'N')     <> 'Y'
            AND Nvl(PAAGT.enable_ship_schedule_flag_dsp,'N') <> 'Y'
            AND PAAGT.enable_autoschedule_flag_dsp = 'Y'

    UNION ALL
    --Reject records if plan bucket pattern empty if enable_autoschedule_flag
    --and enable_plan_schedule_flag enabled
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','PLAN_BUCKET_MANDATORY') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE PAAGT.enable_plan_schedule_flag_dsp     = 'Y'
            AND PAAGT.enable_autoschedule_flag_dsp  = 'Y'
            AND PAAGT.plan_bucket_pattern_id IS NULL

    UNION ALL
    --Reject records if plan schedule type empty if enable_autoschedule_flag
    --and enable_plan_schedule_flag enabled
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','PLAN_SCHEDULE_MANDATORY') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE PAAGT.enable_plan_schedule_flag_dsp     = 'Y'
            AND PAAGT.enable_autoschedule_flag_dsp  = 'Y'
            AND (PAAGT.plan_schedule_type IS NULL
                OR Trim(PAAGT.plan_schedule_type) = ''));

  l_progress := 10;
  l_user_key_tbl1  := l_user_key_tbl;
  l_entity_name1   := l_entity_name;
  l_reject_reason1 := l_reject_reason;

  SELECT user_key                                ,
         entity                                  ,
         msg
  BULK   COLLECT INTO
         l_user_key_tbl                          ,
         l_entity_name                           ,
         l_reject_reason
  FROM (
    --Reject records if ship bucket pattern empty if enable_autoschedule_flag
    --and enable_ship_schedule_flag enabled
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','SHIP_BUCKET_MANDATORY') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE  PAAGT.enable_ship_schedule_flag_dsp    = 'Y'
             AND PAAGT.enable_autoschedule_flag_dsp = 'Y'
             AND PAAGT.ship_bucket_pattern_id IS NULL

    UNION ALL
    --Reject records if ship schedule type empty if enable_autoschedule_flag
    --and enable_ship_schedule_flag enabled
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','SHIP_SCHEDULE_MANDATORY') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE  PAAGT.enable_ship_schedule_flag_dsp    = 'Y'
             AND PAAGT.enable_autoschedule_flag_dsp = 'Y'
             AND (PAAGT.ship_schedule_type IS NULL
                 OR Trim(PAAGT.ship_schedule_type) = '')

    UNION ALL
    --Reject records if there is an entry in po_supplier_item_capacity_gt
    -- when global_flag is N and VMI flag is not checked
    SELECT  PAAGT.user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','INVALID_SUPP_ITEM_CAP_ENTRY') AS msg
      FROM  po_asl_attributes_gt PAAGT,
            po_approved_supplier_list_gt ASLGT
      WHERE PAAGT.user_key                         = ASLGT.user_key
            AND Nvl(ASLGT.using_organization_id,0) <> -1
            AND Nvl(PAAGT.enable_vmi_flag_dsp,'N') <> 'Y'
            AND EXISTS
            (SELECT  1
               FROM  po_supplier_item_capacity_gt PSIC
               WHERE PSIC.asl_id                   = PAAGT.asl_id
                     AND PSIC.using_organization_id= PAAGT.using_organization_id
                     AND PSIC.user_key             = PAAGT.user_key
                     AND PSIC.process_action       = PO_ASL_API_PUB.g_ACTION_ADD)

  );

  l_progress := 20;
  l_user_key_tbl1  := l_user_key_tbl1  MULTISET UNION ALL l_user_key_tbl ;
  l_entity_name1   := l_entity_name1   MULTISET UNION ALL l_entity_name  ;
  l_reject_reason1 := l_reject_reason1 MULTISET UNION ALL l_reject_reason;

  SELECT user_key                                ,
         entity                                  ,
         msg
  BULK   COLLECT INTO
         l_user_key_tbl                          ,
         l_entity_name                           ,
         l_reject_reason
  FROM (
    --Reject records if plan bucket pattern is not empty if
    --enable_autoschedule_flag or enable_plan_schedule_flag disabled
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','INVALID_PLAN_BUCKET') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE (Nvl(PAAGT.enable_plan_schedule_flag_dsp,   'N')  <> 'Y'
             OR Nvl(PAAGT.enable_autoschedule_flag_dsp, 'N')  <> 'Y')
            AND PAAGT.plan_bucket_pattern_id IS NOT NULL

    UNION ALL
    --Reject records if plan schedule type not empty if
    --enable_autoschedule_flag or enable_plan_schedule_flag disabled
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','INVALID_PLAN_SCHEDULE') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE (Nvl(PAAGT.enable_plan_schedule_flag_dsp,   'N')  <> 'Y'
             OR Nvl(PAAGT.enable_autoschedule_flag_dsp, 'N')  <> 'Y')
            AND PAAGT.plan_schedule_type IS NOT NULL

    UNION ALL
    --Reject records if ship bucket pattern not empty if
    --enable_autoschedule_flag or enable_ship_schedule_flag disabled
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','INVALID_SHIP_BUCKET') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE (Nvl(PAAGT.enable_ship_schedule_flag_dsp,   'N')  <> 'Y'
             OR Nvl(PAAGT.enable_autoschedule_flag_dsp, 'N')  <> 'Y')
            AND PAAGT.ship_bucket_pattern_id IS NOT NULL

    UNION ALL
    --Reject records if ship schedule type not empty if
    --enable_autoschedule_flag or enable_ship_schedule_flag disabled
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','INVALID_SHIP_SCHEDULE') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE (Nvl(PAAGT.enable_ship_schedule_flag_dsp,   'N')  <> 'Y'
             OR Nvl(PAAGT.enable_autoschedule_flag_dsp, 'N')  <> 'Y')
            AND PAAGT.ship_schedule_type IS NOT NULL
  );

  l_progress := 30;
  l_user_key_tbl1  := l_user_key_tbl1  MULTISET UNION ALL l_user_key_tbl ;
  l_entity_name1   := l_entity_name1   MULTISET UNION ALL l_entity_name  ;
  l_reject_reason1 := l_reject_reason1 MULTISET UNION ALL l_reject_reason;

  SELECT user_key                                ,
         entity                                  ,
         msg
  BULK   COLLECT INTO
         l_user_key_tbl                          ,
         l_entity_name                           ,
         l_reject_reason
  FROM (
    --Reject records if authorization flag is not checked and
    --there is an entry for chv_authorizations  in case of CREATE
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','INVALID_AUTHORIZATION_ENTRY') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE NVL(PAAGT.enable_authorizations_flag_dsp,'N') <> 'Y'
            AND EXISTS
            (SELECT  1
               FROM  chv_authorizations_gt CHV
               WHERE CHV.reference_id              = PAAGT.asl_id
                     AND CHV.using_organization_id = PAAGT.using_organization_id
                     AND CHV.user_key              = PAAGT.user_key
                     AND CHV.process_action        = PO_ASL_API_PUB.g_ACTION_ADD)
            AND PAAGT.process_action     <> PO_ASL_API_PUB.g_ACTION_DELETE
    UNION ALL
    --Reject records if there is an entry in po_supplier_item_tolerance_gt
    -- when global_flag is N and VMI flag is not checked
    SELECT  PAAGT.user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','INVALID_SUPP_ITEM_TOL_ENTRY') AS msg
      FROM  po_asl_attributes_gt PAAGT,
            po_approved_supplier_list_gt ASLGT
      WHERE PAAGT.user_key                         =  ASLGT.user_key
            AND Nvl(ASLGT.using_organization_id,0) <> -1
            AND Nvl(PAAGT.enable_vmi_flag_dsp,'N') <> 'Y'
            AND EXISTS
            (SELECT  1
               FROM  po_supplier_item_tolerance_gt PSIT
               WHERE PSIT.asl_id                   = PAAGT.asl_id
                     AND PSIT.using_organization_id= PAAGT.using_organization_id
                     AND PSIT.user_key             = PAAGT.user_key
                     AND PSIT.process_action      = PO_ASL_API_PUB.g_ACTION_ADD)

    UNION ALL
    --Reject records if Price Update tolerance is -ve number
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','INVALID_PRICE_UPDATE_TOLERANCE') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE PAAGT.price_update_tolerance_dsp < 0);

  l_progress := 40;
  l_user_key_tbl1  := l_user_key_tbl1  MULTISET UNION ALL l_user_key_tbl ;
  l_entity_name1   := l_entity_name1   MULTISET UNION ALL l_entity_name  ;
  l_reject_reason1 := l_reject_reason1 MULTISET UNION ALL l_reject_reason;

  SELECT user_key                                ,
         entity                                  ,
         msg
  BULK   COLLECT INTO
         l_user_key_tbl                          ,
         l_entity_name                           ,
         l_reject_reason
  FROM (
    --Reject records if delivery calendar code is entered when global_flag is N
    --or VMI flag is not checked
    SELECT  PAAGT.user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','DELIVERY_CALENDAR_NOT_NULL') AS msg
      FROM  po_asl_attributes_gt PAAGT,
            po_approved_supplier_list_gt ASLGT
      WHERE PAAGT.user_key                         =  ASLGT.user_key
            AND PAAGT.delivery_calendar_dsp     IS NOT NULL
            AND Nvl(ASLGT.using_organization_id,0) <> -1
            AND Nvl(PAAGT.enable_vmi_flag_dsp,'N') <> 'Y'

    UNION ALL
    --Reject records if delivery calendar code is entered and not valid
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','INVALID_DELIVERY_CALENDAR_CODE') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE PAAGT.delivery_calendar_dsp IS NOT NULL
            AND NOT EXISTS
            (SELECT  1
               FROM  bom_calendars BOM
               WHERE Nvl(BOM.calendar_end_date, SYSDATE+1) > SYSDATE
                     AND BOM.calendar_code = PAAGT.delivery_calendar_dsp)

    UNION ALL
    --Reject records if delivery calendar code is entered when global_flag is N
    --or VMI flag is not checked
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','PROCESSING_LEAD_TIME_NOT_NULL') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE PAAGT.processing_lead_time_dsp IS NOT NULL
            AND PAAGT.using_organization_id        <> -1
            AND Nvl(PAAGT.enable_vmi_flag_dsp,'N') <> 'Y'

    UNION ALL
    --Reject records if Processing lead time is -ve number or zero
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','INVALID_PROCESSING_LEAD_TIME') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE PAAGT.processing_lead_time_dsp <= 0);

  l_progress := 50;
  l_user_key_tbl1  := l_user_key_tbl1  MULTISET UNION ALL l_user_key_tbl ;
  l_entity_name1   := l_entity_name1   MULTISET UNION ALL l_entity_name  ;
  l_reject_reason1 := l_reject_reason1 MULTISET UNION ALL l_reject_reason;

  SELECT user_key                                ,
         entity                                  ,
         msg
  BULK   COLLECT INTO
         l_user_key_tbl                          ,
         l_entity_name                           ,
         l_reject_reason
  FROM (
    --Reject records if Min Order Qty is -ve number or zero
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','INVALID_MIN_ORDER_QTY') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE PAAGT.min_order_qty_dsp <= 0

    UNION ALL
    --Reject records if fixed lot multiple is -ve number or zero
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','INVALID_FIXED_LOT_MULTIPLE') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE PAAGT.fixed_lot_multiple_dsp <= 0

    UNION ALL
    --Reject records if enable_vmi_flag is checked when site is null or
    --ASL created for commodity or PO_THIRD_PARTY_STOCK_GRP.validate_local_asl
    --retunrs false
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','INVALID_VMI_FLAG') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE PAAGT.enable_vmi_flag_dsp = 'Y'
            AND (PAAGT.vendor_site_id IS NULL
                 OR PAAGT.item_id     IS NULL
             OR validate_vmi(
                 PAAGT.item_id
                ,PAAGT.vendor_site_id
                ,PAAGT.using_organization_id) = 'F'));

  l_progress := 60;
  l_user_key_tbl1  := l_user_key_tbl1  MULTISET UNION ALL l_user_key_tbl ;
  l_entity_name1   := l_entity_name1   MULTISET UNION ALL l_entity_name  ;
  l_reject_reason1 := l_reject_reason1 MULTISET UNION ALL l_reject_reason;

  SELECT user_key                                ,
         entity                                  ,
         msg
  BULK   COLLECT INTO
         l_user_key_tbl                          ,
         l_entity_name                           ,
         l_reject_reason
  FROM (
    --Reject records if vmi_flag is not checked and automatic allowed is checked
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','INVALID_AUTO_REPLENISH_FLAG') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE Nvl(PAAGT.enable_vmi_flag_dsp,'N')      <> 'Y'
            AND PAAGT.enable_vmi_auto_replenish_flag = 'Y'

    UNION ALL
    --Reject records if vmi_flag is not checked and replenishment
    --method is entered
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','INVALID_REPLENISH_METHOD') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE Nvl(PAAGT.enable_vmi_flag_dsp,'N')  <> 'Y'
            AND PAAGT.replenishment_method      IS NOT NULL

    UNION ALL
    --Reject records if automatic allowed is not checked and replenishment
    --approval is not 'SUPPLIER_OR_BUYER'
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','INVALID_REPLENISH_APPROVAL') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE Nvl(PAAGT.enable_vmi_auto_replenish_flag,'N') <> 'Y'
            AND PAAGT.vmi_replenishment_approval <>'SUPPLIER_OR_BUYER'
            AND PAAGT.vmi_replenishment_approval IS NOT NULL

    UNION ALL
    --Reject records if vmi_flag, automatic allowed is checked and
    --replenishment approval is empty
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','REPLENISH_APPROVAL_REQUIRED') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE PAAGT.enable_vmi_flag_dsp                = 'Y'
            AND PAAGT.enable_vmi_auto_replenish_flag = 'Y'
            AND PAAGT.vmi_replenishment_approval     IS NULL


    UNION ALL
    --Reject records if vmi_flag is checked and replenishment method is empty
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','REPLENISH_METHOD_REQUIRED') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE PAAGT.enable_vmi_flag_dsp            = 'Y'
            AND PAAGT.replenishment_method       IS NULL

    UNION ALL
    --Reject records if forecast horizon is not +ve integer or zero
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','INVALID_FORECAST_HORIZON') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE PAAGT.forecast_horizon_dsp <= 0
            OR Round(PAAGT.forecast_horizon_dsp) <> PAAGT.forecast_horizon_dsp
            OR (PAAGT.forecast_horizon_dsp IS NOT NULL
                AND Nvl(PAAGT.enable_vmi_flag_dsp,'N') <> 'Y'));

  l_progress := 70;
  l_user_key_tbl1  := l_user_key_tbl1  MULTISET UNION ALL l_user_key_tbl ;
  l_entity_name1   := l_entity_name1   MULTISET UNION ALL l_entity_name  ;
  l_reject_reason1 := l_reject_reason1 MULTISET UNION ALL l_reject_reason;

  SELECT user_key                                ,
         entity                                  ,
         msg
  BULK   COLLECT INTO
         l_user_key_tbl                          ,
         l_entity_name                           ,
         l_reject_reason
  FROM (
    --Reject records if VMI Min Qty is -ve number  or is entered when
    --vmi_flag is not checked or replenishment method is 2/4
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','INVALID_VIM_MIN_QTY') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE PAAGT.vmi_min_qty_dsp < 0
            OR (PAAGT.vmi_min_qty_dsp                  <> 0
                AND Nvl(PAAGT.enable_vmi_flag_dsp,'N') <> 'Y')
            OR (PAAGT.vmi_min_qty_dsp          <> 0
                AND PAAGT.replenishment_method IN (2,4))

    UNION ALL
    --Reject records if VMI Max Qty is -ve number or is entered when
    --vmi flag is not checked or replenishment method is 2/3/4  or
    --this qty is less than vmi min qty
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','INVALID_VIM_MAX_QTY') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE PAAGT.vmi_max_qty_dsp     < 0
            OR (PAAGT.vmi_max_qty_dsp < PAAGT.vmi_min_qty_dsp)
            OR (PAAGT.vmi_max_qty_dsp                  <> 0
                AND Nvl(PAAGT.enable_vmi_flag_dsp,'N') <> 'Y')
            OR (PAAGT.vmi_max_qty_dsp <> 0 AND PAAGT.replenishment_method
                IN (2,3,4))

    UNION ALL
    --Reject records if VMI Min Days is not +ve integer or is entered when
    --vmi flag is not checked or replenishment method is 1/3
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','INVALID_VIM_MIN_DAYS') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE PAAGT.vmi_min_days_dsp < 0
            OR Round(PAAGT.vmi_min_days_dsp) <> PAAGT.vmi_min_days_dsp
            OR (PAAGT.vmi_min_days_dsp                 <>  0
                AND Nvl(PAAGT.enable_vmi_flag_dsp,'N') <> 'Y')
            OR (PAAGT.vmi_min_days_dsp         <>  0
                AND PAAGT.replenishment_method IN (1,3))

    UNION ALL
    --Reject records if VMI Max Days is not +ve integer or is entered when
    --vmi flag is not checked or replenishment method is 1/3/4
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','INVALID_VIM_MAXS_DAYS') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE PAAGT.vmi_max_days_dsp < 0
            OR Round(PAAGT.vmi_max_days_dsp) <> PAAGT.vmi_max_days_dsp
            OR (PAAGT.vmi_max_days_dsp < PAAGT.vmi_min_days_dsp)
            OR (PAAGT.vmi_max_days_dsp                 <>  0
                AND Nvl(PAAGT.enable_vmi_flag_dsp,'N') <> 'Y')
            OR (PAAGT.vmi_max_days_dsp         <>  0
                AND PAAGT.replenishment_method IN (1,3,4))

    UNION ALL
    --Reject records if Fixed Order Quantity is -ve number or is entered when
    --vmi flag is not checked or replenishment method is 1/2
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','INVALID_FIXED_ORDER_QTY') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE PAAGT.fixed_order_quantity_dsp       <  0
            OR (PAAGT.fixed_order_quantity_dsp         <>  0
                AND Nvl(PAAGT.enable_vmi_flag_dsp,'N') <> 'Y')
            OR (PAAGT.fixed_order_quantity_dsp    <> 0
                AND PAAGT.replenishment_method IN (1,2)));

  l_progress := 80;
  l_user_key_tbl1  := l_user_key_tbl1  MULTISET UNION ALL l_user_key_tbl ;
  l_entity_name1   := l_entity_name1   MULTISET UNION ALL l_entity_name  ;
  l_reject_reason1 := l_reject_reason1 MULTISET UNION ALL l_reject_reason;
  SELECT user_key                                ,
         entity                                  ,
         msg
  BULK   COLLECT INTO
         l_user_key_tbl                          ,
         l_entity_name                           ,
         l_reject_reason
  FROM (
    --Reject records if consigned from supplier is checked when site is null or
    --ASL created for commodity or PO_THIRD_PARTY_STOCK_GRP.validate_local_asl
    --retunrs false
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','INVALID_CONSIGNED_FLAG') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE PAAGT.consigned_from_supp_flag_dsp = 'Y'
            AND (PAAGT.vendor_site_id IS NULL
                 OR PAAGT.item_id     IS NULL
                 OR validate_vmi(
                      PAAGT.item_id
                     ,PAAGT.vendor_site_id
                     ,PAAGT.using_organization_id)='F')

    UNION ALL
    --Reject records if Consigned billing cycle is -ve number
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','INVALID_CONSIGN_BILL_CYCLE') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE PAAGT.consigned_billing_cycle_dsp < 0
            OR (PAAGT.consigned_billing_cycle_dsp IS NOT NULL
                AND Nvl(PAAGT.consigned_from_supp_flag_dsp,'N') <> 'Y')

    UNION ALL
    --Reject records if Consume on Aging flag is checked when Consigned flag
    --is not checked
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','INVALID_CONSUME_AGING_FLAG') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE PAAGT.consume_on_aging_flag_dsp = 'Y'
            AND Nvl(PAAGT.consigned_from_supp_flag_dsp,'N') <> 'Y'

    UNION ALL
    --Reject records if ageing period is not +ve number or zero or is entered
    --when consume of ageing flag is not checked
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','INVALID_AGEING_PERIOD') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE PAAGT.aging_period_dsp <= 0
            OR Round(PAAGT.aging_period_dsp) <> PAAGT.aging_period_dsp
            OR (Nvl(PAAGT.consume_on_aging_flag_dsp,'N') <> 'Y'
                AND PAAGT.aging_period_dsp IS NOT NULL)

    UNION ALL
    --Reject records if vendor site is null and supplier scheduling tab details
    --are given
    SELECT  user_key                             ,
            'po_asl_attributes_gt' AS entity     ,
            fnd_message.get_string('PO','SUPPLIER_SCHEDULING_DISABLED') AS msg
      FROM  po_asl_attributes_gt PAAGT
      WHERE PAAGT.vendor_site_id     IS NULL
            AND PAAGT.process_action <> PO_ASL_API_PUB.g_ACTION_DELETE
            AND (PAAGT.enable_plan_schedule_flag_dsp    = 'Y'
                 OR PAAGT.enable_ship_schedule_flag_dsp = 'Y'
                 OR PAAGT.enable_autoschedule_flag_dsp  = 'Y'
                 OR PAAGT.scheduler_id IS NOT NULL
                 OR PAAGT.enable_authorizations_flag_dsp = 'Y'
                 OR EXISTS
            (SELECT  1
               FROM  chv_authorizations_gt CHV
               WHERE CHV.reference_id              = PAAGT.asl_id
                     AND CHV.using_organization_id = PAAGT.using_organization_id
                     AND CHV.user_key              = PAAGT.user_key))

  );

  l_progress := 90;
  l_user_key_tbl1  := l_user_key_tbl1  MULTISET UNION ALL l_user_key_tbl ;
  l_entity_name1   := l_entity_name1   MULTISET UNION ALL l_entity_name  ;
  l_reject_reason1 := l_reject_reason1 MULTISET UNION ALL l_reject_reason;

  --call po_asl_api_pvt.reject_asl_record for above rejected records
  po_asl_api_pvt.log('validate_asl_attr_gt: reject count:' ||
                      l_user_key_tbl1.Count);
  IF l_user_key_tbl1.Count > 0
  THEN
    po_asl_api_pvt.reject_asl_record(
      p_user_key_tbl       =>  l_user_key_tbl1,
      p_rejection_reason   =>  l_reject_reason1,
      p_entity_name        =>  l_entity_name1,
      p_session_key        =>  g_session_key,
      x_return_status      =>  x_return_status,
      x_return_msg         =>  x_return_msg
    );
  END IF;

  l_progress := 100;
  po_asl_api_pvt.log('END ::: po_asl_api_grp.validate_asl_attr_gt');

EXCEPTION

  WHEN OTHERS THEN

    po_asl_api_pvt.log('validate_asl_attr_gt : when others exception at '
                       || l_progress || ';' || SQLERRM );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_return_msg := SQLERRM;

END validate_asl_attr_gt;

--------------------------------------------------------------------------------
  --Start of Comments

  --Name: validate_asl_doc_gt

  --Function:
  --  This will validate data in po_asl_documents_gt table

  --Parameters:

  --OUT:
  --  x_return_status   VARCHAR2
  --  x_return_msg      VARCHAR2

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE validate_asl_doc_gt(
  x_return_status   OUT NOCOPY VARCHAR2
, x_return_msg      OUT NOCOPY VARCHAR2
)
IS
  l_progress         NUMBER := 0;

  l_user_key_tbl     po_tbl_number;
  l_entity_name      po_tbl_varchar30;
  l_reject_reason    po_tbl_varchar2000;

BEGIN
  po_asl_api_pvt.log('START ::: po_asl_api_grp.validate_asl_doc_gt');
  SELECT user_key                                ,
         entity                                  ,
         msg
  BULK   COLLECT INTO
         l_user_key_tbl                          ,
         l_entity_name                           ,
         l_reject_reason
  FROM (
    --Reject records if sequence number is empty or lessthan 1
    SELECT  user_key                             ,
            'po_asl_documents_gt' AS entity      ,
            fnd_message.get_string('PO','INVALID_DOC_SEQUENCE') AS msg
      FROM  po_asl_documents_gt DOCGT
      WHERE DOCGT.sequence_num    IS NULL
            OR DOCGT.sequence_num < 1
    UNION ALL

    --Reject records if seq is duplicated for same asl, 'using org' combination
    SELECT  user_key                             ,
            'po_asl_documents_gt' AS entity      ,
            fnd_message.get_string('PO','DUPLICATE_DOC_SEQUENCE') AS msg
      FROM  po_asl_documents_gt DOCGT
    WHERE EXISTS (SELECT   sequence_num
                    FROM   po_asl_documents_gt
                  GROUP BY asl_id,
                           using_organization_id,
                           sequence_num
                  HAVING COUNT(sequence_num) >1
                 )
    UNION ALL

    --Additional validation on seq is required in case of asl mode is update
    --Reject records if seq is duplicated for same asl, 'using org' combination
    SELECT  DOCGT.user_key                       ,
            'po_asl_documents_gt' AS entity      ,
            fnd_message.get_string('PO','DUPLICATE_DOC_SEQUENCE') AS msg
      FROM  po_asl_documents_gt DOCGT,
            po_approved_supplier_list_gt ASLGT
    WHERE EXISTS (SELECT  sequence_num
                    FROM  po_asl_documents  DOC
                   WHERE DOC.asl_id = DOCGT.asl_id
                     AND DOC.using_organization_id = DOCGT.using_organization_id
                     AND DOC.sequence_num = DOCGT.sequence_num
                 )
      AND DOCGT.user_key       = ASLGT.user_key
      AND ASLGT.process_action = PO_ASL_API_PUB.g_ACTION_UPDATE

    UNION ALL
    --Reject records if document type is null
    SELECT  user_key                             ,
            'po_asl_documents_gt' AS entity      ,
            fnd_message.get_string('PO','DOC_TYPE_MANDATORY') AS msg
      FROM  po_asl_documents_gt DOCGT
      WHERE DOCGT.document_type_code IS NULL

    UNION ALL
    --Reject records if header id is null
    SELECT  user_key                             ,
            'po_asl_documents_gt' AS entity      ,
            fnd_message.get_string('PO','DOC_HEADER_MANDATORY') AS msg
      FROM  po_asl_documents_gt DOCGT
      WHERE DOCGT.document_header_id IS NULL

    UNION ALL
    --Reject records if document type is Not CONTRACT, 'LINE_NUM' is null
    SELECT  user_key                             ,
            'po_asl_documents_gt' AS entity      ,
            fnd_message.get_string('PO','LINE_NUM_MANDATORY') AS msg
      FROM  po_asl_documents_gt DOCGT
      WHERE DOCGT.document_type_code     <> 'CONTRACT'
            AND DOCGT.document_line_id   IS NULL
            AND DOCGT.process_action     <> PO_ASL_API_PUB.g_ACTION_DELETE
  );

  l_progress := 50;
  --call po_asl_api_pvt.reject_asl_record for above rejected records
  po_asl_api_pvt.log('validate_asl_doc_gt: reject count:' ||
                      l_user_key_tbl.Count);
  IF l_user_key_tbl.Count > 0
  THEN
    po_asl_api_pvt.reject_asl_record(
      p_user_key_tbl       =>  l_user_key_tbl,
      p_rejection_reason   =>  l_reject_reason,
      p_entity_name        =>  l_entity_name,
      p_session_key        =>  g_session_key,
      x_return_status      =>  x_return_status,
      x_return_msg         =>  x_return_msg
    );
   END if;

  l_progress := 100;
  po_asl_api_pvt.log('END ::: po_asl_api_grp.validate_asl_doc_gt');

EXCEPTION

  WHEN OTHERS THEN

    po_asl_api_pvt.log('validate_asl_doc_gt : when others exception at '
                       || l_progress || ';' || SQLERRM );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_return_msg := SQLERRM;

END validate_asl_doc_gt;

--------------------------------------------------------------------------------
  --Start of Comments

  --Name: validate_chv_auth_gt

  --Function:
  --  This will validate data in chv_authorizations_gt table

  --Parameters:

  --OUT:
  --  x_return_status   VARCHAR2
  --  x_return_msg      VARCHAR2

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE validate_chv_auth_gt(
  x_return_status   OUT NOCOPY VARCHAR2
, x_return_msg      OUT NOCOPY VARCHAR2
)
IS
  l_progress         NUMBER := 0;

  l_user_key_tbl     po_tbl_number;
  l_entity_name      po_tbl_varchar30;
  l_reject_reason    po_tbl_varchar2000;

BEGIN
  po_asl_api_pvt.log('START ::: po_asl_api_grp.validate_chv_auth_gt');
  SELECT user_key                                ,
         entity                                  ,
         msg
  BULK   COLLECT INTO
         l_user_key_tbl                          ,
         l_entity_name                           ,
         l_reject_reason
  FROM (
    --Reject records if sequence number is empty or not in 1,2,3,4
    SELECT  user_key                             ,
            'chv_authorizations_gt' AS entity    ,
            fnd_message.get_string('PO','INVALID_AUTH_SEQUENCE') AS msg
      FROM  chv_authorizations_gt CHVGT
      WHERE CHVGT.authorization_sequence_dsp    IS NULL
            OR CHVGT.authorization_sequence_dsp NOT IN (1,2,3,4)

    UNION ALL
     --Reject records if timefence days is less than 1
     SELECT user_key                             ,
            'chv_authorizations_gt' AS entity    ,
            fnd_message.get_string('PO','INVALID_TIMEFENCE_DAYS') AS msg
      FROM  chv_authorizations_gt CHVGT
      WHERE CHVGT.timefence_days_dsp IS NULL
            OR CHVGT.timefence_days_dsp <= 0

  );


  l_progress := 50;
  --call po_asl_api_pvt.reject_asl_record for above rejected records
  po_asl_api_pvt.log('validate_chv_auth_gt: reject count:' ||
                      l_user_key_tbl.Count);
  IF l_user_key_tbl.Count > 0
  THEN
    po_asl_api_pvt.reject_asl_record(
      p_user_key_tbl       =>  l_user_key_tbl,
      p_rejection_reason   =>  l_reject_reason,
      p_entity_name        =>  l_entity_name,
      p_session_key        =>  g_session_key,
      x_return_status      =>  x_return_status,
      x_return_msg         =>  x_return_msg
    );
  END IF;

  l_progress := 100;
  po_asl_api_pvt.log('END ::: po_asl_api_grp.validate_chv_auth_gt');

EXCEPTION

  WHEN OTHERS THEN

    po_asl_api_pvt.log('validate_chv_auth_gt : when others exception at '
                       || l_progress || ';' || SQLERRM );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_return_msg := SQLERRM;

END validate_chv_auth_gt;

--------------------------------------------------------------------------------
  --Start of Comments

  --Name: validate_supp_item_cap_gt

  --Function:
  --  This will validate data in po_supplier_item_capacity_gt table

  --Parameters:

  --OUT:
  --  x_return_status   VARCHAR2
  --  x_return_msg      VARCHAR2

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE validate_supp_item_cap_gt(
  x_return_status   OUT NOCOPY VARCHAR2
, x_return_msg      OUT NOCOPY VARCHAR2
)
IS
  l_progress         NUMBER := 0;

  l_user_key_tbl     po_tbl_number;
  l_entity_name      po_tbl_varchar30;
  l_reject_reason    po_tbl_varchar2000;
  l_user_key_tbl1    po_tbl_number;
  l_entity_name1     po_tbl_varchar30;
  l_reject_reason1   po_tbl_varchar2000;

BEGIN
  po_asl_api_pvt.log('START ::: po_asl_api_grp.validate_supp_item_cap_gt');
  SELECT user_key                                    ,
         entity                                      ,
         msg
  BULK   COLLECT INTO
         l_user_key_tbl                              ,
         l_entity_name                               ,
         l_reject_reason
  FROM (
    --Reject records if from_date is less than current date
    SELECT  user_key                                 ,
            'po_supplier_item_capacity_gt' AS entity ,
            fnd_message.get_string('PO','INVALID_FROM_DATE') AS msg
      FROM  po_supplier_item_capacity_gt PSICGT
      WHERE (PSICGT.from_date_dsp    IS NULL
             OR PSICGT.from_date_dsp < SYSDATE)
            AND PSICGT.process_action <> PO_ASL_API_PUB.g_ACTION_DELETE

    UNION ALL
     --Reject records if to_date is less than current date or from_date
    SELECT  user_key                                 ,
            'po_supplier_item_capacity_gt' AS entity ,
            fnd_message.get_string('PO','INVALID_TO_DATE') AS msg
      FROM  po_supplier_item_capacity_gt PSICGT
      WHERE PSICGT.to_date_dsp    < SYSDATE
            OR PSICGT.to_date_dsp < PSICGT.from_date_dsp

    UNION ALL
     --Reject records if capacity is less than 1
     SELECT user_key                             ,
            'po_supplier_item_capacity_gt'       ,
            fnd_message.get_string('PO','INVALID_CAPACITY_PER_DAY') AS msg
      FROM  po_supplier_item_capacity_gt PSICGT
      WHERE PSICGT.capacity_per_day_dsp IS NULL
            OR PSICGT.capacity_per_day_dsp <= 0);

  l_progress := 20;
  l_user_key_tbl1  := l_user_key_tbl;
  l_entity_name1   := l_entity_name;
  l_reject_reason1 := l_reject_reason;

  SELECT PSICGT.user_key                             ,
         'po_supplier_item_capacity_gt' AS entity    ,
         fnd_message.get_string('PO','DATES_OVERLAPPED') AS msg
    BULK COLLECT INTO
         l_user_key_tbl                              ,
         l_entity_name                               ,
         l_reject_reason
    FROM  po_supplier_item_capacity_gt PSICGT        ,
          po_approved_supplier_list_gt ASLGT
    WHERE 2 <= (SELECT  Count(user_key)
                 FROM  po_supplier_item_capacity_gt PSIC
                 WHERE (PSICGT.from_date_dsp
                       BETWEEN PSIC.from_date_dsp AND PSIC.to_date_dsp
                       OR PSICGT.to_date_dsp
                       BETWEEN PSIC.from_date_dsp AND PSIC.to_date_dsp)
                       AND PSICGT.user_key              = PSIC.user_key
                       AND PSICGT.using_organization_id = PSIC.using_organization_id)
          AND PSICGT.user_key       = ASLGT.user_key
          AND ASLGT.process_action  = PO_ASL_API_PUB.g_ACTION_CREATE
          AND PSICGT.process_action = PO_ASL_API_PUB.g_ACTION_ADD;

  l_progress := 40;
  l_user_key_tbl1  := l_user_key_tbl1  MULTISET UNION ALL l_user_key_tbl ;
  l_entity_name1   := l_entity_name1   MULTISET UNION ALL l_entity_name  ;
  l_reject_reason1 := l_reject_reason1 MULTISET UNION ALL l_reject_reason;
     --Reject records if dates overlapped when update
  SELECT  PSICGT.user_key                            ,
          'po_supplier_item_capacity_gt' AS entity   ,
          fnd_message.get_string('PO','DATES_OVERLAPPED') AS msg
    BULK COLLECT INTO
         l_user_key_tbl                              ,
         l_entity_name                               ,
         l_reject_reason
    FROM  po_supplier_item_capacity_gt PSICGT        ,
          po_approved_supplier_list_gt ASLGT
    WHERE EXISTS
          (SELECT  1
             FROM  po_supplier_item_capacity PSIC
             WHERE (PSICGT.from_date_dsp
                   BETWEEN PSIC.from_date AND PSIC.To_Date
                   OR PSICGT.to_date_dsp
                   BETWEEN PSIC.from_date AND PSIC.To_Date)
                   AND PSICGT.asl_id               =PSIC.asl_id
                   AND PSICGT.using_organization_id=PSIC.using_organization_id)
          AND PSICGT.user_key       = ASLGT.user_key
          AND ASLGT.process_action  = PO_ASL_API_PUB.g_ACTION_UPDATE
          AND PSICGT.process_action = PO_ASL_API_PUB.g_ACTION_ADD;

  l_progress := 60;
  l_user_key_tbl1  := l_user_key_tbl1  MULTISET UNION ALL l_user_key_tbl ;
  l_entity_name1   := l_entity_name1   MULTISET UNION ALL l_entity_name  ;
  l_reject_reason1 := l_reject_reason1 MULTISET UNION ALL l_reject_reason;

  --call po_asl_api_pvt.reject_asl_record for above rejected records
  po_asl_api_pvt.log('validate_supp_item_cap_gt: reject count:' ||
                      l_user_key_tbl1.Count);
  IF l_user_key_tbl1.Count > 0
  THEN
    po_asl_api_pvt.reject_asl_record(
      p_user_key_tbl       =>  l_user_key_tbl1,
      p_rejection_reason   =>  l_reject_reason1,
      p_entity_name        =>  l_entity_name1,
      p_session_key        =>  g_session_key,
      x_return_status      =>  x_return_status,
      x_return_msg         =>  x_return_msg
    );
  END IF;

  l_progress := 100;
  po_asl_api_pvt.log('END ::: po_asl_api_grp.validate_supp_item_cap_gt');

EXCEPTION

  WHEN OTHERS THEN

    po_asl_api_pvt.log('validate_supp_item_cap_gt : when others exception at '
                       || l_progress || ';' || SQLERRM );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_return_msg := SQLERRM;

END validate_supp_item_cap_gt;

--------------------------------------------------------------------------------
  --Start of Comments

  --Name: validate_supp_item_tol_gt

  --Function:
  --  This will validate data in po_supplier_item_tolerance_gt table

  --Parameters:

  --OUT:
  --  x_return_status   VARCHAR2
  --  x_return_msg      VARCHAR2

  --End of Comments
--------------------------------------------------------------------------------

PROCEDURE validate_supp_item_tol_gt(
  x_return_status   OUT NOCOPY VARCHAR2
, x_return_msg      OUT NOCOPY VARCHAR2
)
IS
  l_progress         NUMBER := 0;

  l_user_key_tbl     po_tbl_number;
  l_entity_name      po_tbl_varchar30;
  l_reject_reason po_tbl_varchar2000;

BEGIN
  po_asl_api_pvt.log('START ::: po_asl_api_grp.validate_supp_item_tol_gt');
  SELECT user_key                                    ,
         entity                                      ,
         msg
  BULK   COLLECT INTO
         l_user_key_tbl                              ,
         l_entity_name                               ,
         l_reject_reason
  FROM (
    --Reject records if number_of_days_dsp is less than 1
    SELECT  user_key                                 ,
            'po_supplier_item_tolerance_gt' AS entity,
            fnd_message.get_string('PO','INVALID_NUM_OF_DAYS') AS msg
      FROM  po_supplier_item_tolerance_gt PSITGT
      WHERE PSITGT.number_of_days_dsp    IS NULL
            OR PSITGT.number_of_days_dsp <= 0

    UNION ALL
    --Reject records if tolerance_dsp is less than 1
    SELECT  user_key                                 ,
            'po_supplier_item_tolerance_gt' AS entity,
            fnd_message.get_string('PO','INVALID_TOLERANCE') AS msg
      FROM  po_supplier_item_tolerance_gt PSITGT
      WHERE PSITGT.tolerance_dsp    IS NULL
            OR PSITGT.tolerance_dsp <= 0
  );

  l_progress := 50;
  --call po_asl_api_pvt.reject_asl_record for above rejected records
  po_asl_api_pvt.log('validate_supp_item_tol_gt: reject count:' ||
                      l_user_key_tbl.Count);
  IF l_user_key_tbl.Count > 0
  THEN
    po_asl_api_pvt.reject_asl_record(
      p_user_key_tbl       =>  l_user_key_tbl,
      p_rejection_reason   =>  l_reject_reason,
      p_entity_name        =>  l_entity_name,
      p_session_key        =>  g_session_key,
      x_return_status      =>  x_return_status,
      x_return_msg         =>  x_return_msg
    );
  END IF;

  l_progress := 100;
  po_asl_api_pvt.log('END ::: po_asl_api_grp.validate_supp_item_tol_gt');

EXCEPTION

  WHEN OTHERS THEN

    po_asl_api_pvt.log('validate_supp_item_tol_gt : when others exception at '
                       || l_progress || ';' || SQLERRM );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_return_msg := SQLERRM;

END validate_supp_item_tol_gt;


--------------------------------------------------------------------------------
  --Start of Comments

  --Name: determine_action

  --Function:
  --  This will determine the process action based on item/category, orgId,
  --  vendor, site.

  --Parameters:

  --IN:
  --  p_item_id                NUMBER
  --  p_category_id            NUMBER
  --  p_using_organization_id  NUMBER
  --  p_vendor_id              NUMBER
  --  p_vendor_site_id         NUMBER

  --OUT:
  --  x_return_status          VARCHAR2
  --  x_return_msg             VARCHAR2

  --RETURN
  -- varchar2(20)

  --End of Comments
--------------------------------------------------------------------------------

FUNCTION determine_action(
  p_item_id                IN  NUMBER
, p_category_id            IN  NUMBER
, p_using_organization_id  IN  NUMBER
, p_vendor_id              IN  NUMBER
, p_vendor_site_id         IN  NUMBER
)
RETURN VARCHAR2
IS
  l_process_action VARCHAR2(20);
  l_found          NUMBER;

BEGIN
  po_asl_api_pvt.log('START ::: determine_action');
  po_asl_api_pvt.log('p_item_id'               || p_item_id);
  po_asl_api_pvt.log('p_category_id'           || p_category_id);
  po_asl_api_pvt.log('p_using_organization_id' || p_using_organization_id);
  po_asl_api_pvt.log('p_vendor_id'             || p_vendor_id);
  po_asl_api_pvt.log('p_vendor_site_id'        || p_vendor_site_id);
  l_found := 0;
  l_process_action := PO_ASL_API_PUB.g_ACTION_CREATE;

  SELECT 1 INTO l_found
  FROM dual
  WHERE EXISTS
  (SELECT  asl_id
     FROM  po_approved_supplier_list PASL
     WHERE (PASL.item_id                   = p_item_id
            OR PASL.category_id            = p_category_id)
           AND PASL.using_organization_id  = p_using_organization_id
           AND PASL.vendor_id              = p_vendor_id
           AND Nvl(PASL.vendor_site_id,-1) = Nvl(p_vendor_site_id,-1));

  IF l_found = 1
  THEN
     l_process_action := PO_ASL_API_PUB.g_ACTION_UPDATE;
  END IF;

  po_asl_api_pvt.log('process_action:' || l_process_action);
  po_asl_api_pvt.log('END ::: determine_action');

  RETURN(l_process_action);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    po_asl_api_pvt.log('determine_action : when NO_DATA_FOUND at '
                       || SQLERRM );
    RETURN(l_process_action);

  WHEN OTHERS THEN

    po_asl_api_pvt.log('determine_action : when others exception at '
                       || SQLERRM );
    RETURN(l_process_action);

END determine_action;

--------------------------------------------------------------------------------
  --Start of Comments

  --Name: validate_vmi

  --Function:
  --  This will validate the vmi flag based on item, orgId, vendor site.

  --Parameters:

  --IN:
  --  p_item_id                NUMBER
  --  p_using_organization_id  NUMBER
  --  p_vendor_site_id         NUMBER

  --OUT:
  --  x_return_status          VARCHAR2
  --  x_return_msg             VARCHAR2

  --RETURN
  -- varchar2(20)

  --End of Comments
--------------------------------------------------------------------------------

FUNCTION validate_vmi(
  p_item_id                IN  NUMBER
, p_using_organization_id  IN  NUMBER
, p_vendor_site_id         IN  NUMBER
)
RETURN VARCHAR2
IS
  l_result                 BOOLEAN;
  l_msg_count              NUMBER;
  l_msg_data               VARCHAR2(2000);
  l_validation_error_name  VARCHAR2(30);
  l_return_status          VARCHAR2(10);


BEGIN
  po_asl_api_pvt.log('START ::: validate_vmi');
  po_asl_api_pvt.log('p_item_id:'               || p_item_id);
  po_asl_api_pvt.log('p_using_organization_id:' || p_using_organization_id);
  po_asl_api_pvt.log('p_vendor_site_id:'        || p_vendor_site_id);

  IF  p_using_organization_id <> -1
  THEN
    l_result := PO_THIRD_PARTY_STOCK_GRP.validate_local_asl(
                   p_api_version           => 1.0
                 , p_init_msg_list         => NULL
                 , p_commit                => NULL
                 , p_validation_level      => NULL
                 , x_return_status         => l_return_status
                 , x_msg_count             => l_msg_count
                 , x_msg_data              => l_msg_data
                 , p_inventory_item_id     => p_item_id
                 , p_supplier_site_id      => p_vendor_site_id
                 , p_inventory_org_id      => p_using_organization_id
                 , p_validation_type       => 'VMI'
                 , x_validation_error_name => l_validation_error_name);
   ELSE
     l_result := PO_THIRD_PARTY_STOCK_GRP.validate_global_asl(
                   p_api_version           => 1.0
                 , p_init_msg_list         => NULL
                 , p_commit                => NULL
                 , p_validation_level      => NULL
                 , x_return_status         => l_return_status
                 , x_msg_count             => l_msg_count
                 , x_msg_data              => l_msg_data
                 , p_inventory_item_id     => p_item_id
                 , p_supplier_site_id      => p_vendor_site_id
                 , p_validation_type       => 'VMI'
                 , x_validation_error_name => l_validation_error_name) ;

   END IF;

  IF l_result = TRUE
  THEN
     po_asl_api_pvt.log('END ::: validate_vmi -> Result:' || 'T');
     RETURN 'T';
  ELSE
     po_asl_api_pvt.log('END ::: validate_vmi -> Result:' || 'F');
     RETURN 'F';
  END IF;

EXCEPTION

  WHEN OTHERS THEN
    po_asl_api_pvt.log('validate_vmi : when others exception at ' || SQLERRM );
    RETURN 'F';

END validate_vmi;

END PO_ASL_API_GRP;

/
