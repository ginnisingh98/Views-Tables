--------------------------------------------------------
--  DDL for Package Body INV_CONSIGNED_DIAGNOSTICS_PROC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_CONSIGNED_DIAGNOSTICS_PROC" AS
-- $Header: INVRCIDB.pls 115.7 2004/02/05 04:00:23 rajkrish noship $
--+=======================================================================+
--|               Copyright (c) 2002 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVRCIDB.pls
--|INV_CONSIGNED_INV_PREVAL_PROC
--| DESCRIPTION                                                           |
--|     consigned inv Diagnostics/Pre-validation conc pgm
--| HISTORY                                                               |
--|     Sep-16
--+======================================================================--

------------------
--- constants
-------------------
g_debug              NUMBER := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
g_user_id        NUMBER :=
       FND_GLOBAL.user_id ;
g_request_id     NUMBER :=
       TO_NUMBER(FND_PROFILE.Value('CONC_REQUEST_ID'));
g_program_id   NUMBER :=
    fnd_global.conc_program_id ;
g_program_application_id NUMBER :=
      fnd_global.prog_appl_id ;
g_login_id  NUMBER :=
         fnd_global.login_id ;
g_revalidate_error_code VARCHAR2(40) ;

--===================
-- PROCEDURES AND FUNCTIONS
--===================


-------------------
--- Retrieve UOM code
----------------------------
FUNCTION get_UOM_CODE(p_uom IN VARCHAR2)
RETURN VARCHAR2

IS


l_uom_code VARCHAR2(30) ;

BEGIN

  IF g_debug = 1
  THEN
   INV_LOG_UTIL.trace
   ( 'Into  return from get_uom_code ' || p_uom ,null,9);
  END IF;
 l_uom_code := NULL ;

 IF p_uom is not NULL
 THEN
   BEGIN
     SELECT uom_code
     INTO l_uom_code
     FROM   MTL_units_of_measure
     WHERE  unit_of_measure = p_uom ;

     EXCEPTION
     WHEN  NO_DATA_FOUND
      THEN
        l_uom_code := p_uom ;

      WHEN TOO_MANY_ROWS
      THEN
        l_uom_code := p_uom ;
    END ;

  END IF;

  IF g_debug = 1
  THEN
   INV_LOG_UTIL.trace
   ( 'about to return from get_uom_code ' || l_uom_code ,null,9);
  END IF;

RETURN( l_uom_code );


END get_uom_code ;

---------------------------------------------------------
--- Update consumption date
-----------------------------------------------------------
PROCEDURE Update_Consumption_Date
IS


BEGIN

  IF g_debug = 1
  THEN
   INV_LOG_UTIL.trace
   ( '>> Update_Consumption_Date',null,9);
  END IF;

  UPDATE mtl_consigned_diag_errors mcde
  SET   mcde.consumption_date =
      ( select MIN(mmt.transaction_date)
         FROM  mtl_material_transactions mmt
          WHERE mmt.inventory_item_id      = mcde.inventory_item_id
            and NVL(mmt.revision, -980980)  = NVL(mcde.revision,-980980)
            and mmt.organization_id        = mcde.organization_id
            and mmt.owning_organization_id = mcde.owning_organization_id
       )
   WHERE mcde.consumption_date is NULL
     and  mcde.record_type = 2 ;


  IF g_debug = 1
  THEN
   INV_LOG_UTIL.trace
   ( '>> Update_Consumption_Date',null,9);
  END IF;



EXCEPTION

  WHEN OTHERS THEN
   IF g_debug = 1
   THEN
    INV_LOG_UTIL.trace
    ( 'SQLERRM: '|| SQLERRM,9 );

   INV_LOG_UTIL.trace
    ( 'OTHERS exception ',
      'Update_Consumption_Date',9);
   END IF;

  RAISE ;

END Update_Consumption_Date ;


------------------------------------------------------------
---- Purge_diagnostics_passed_rec
------------------------------------------------------------
PROCEDURE Purge_diagnostics_passed_rec
IS

BEGIN

   IF g_debug = 1
   THEN
    INV_LOG_UTIL.trace
    ( '>> Purge_diagnostics_passed_rec' ,9);
   END IF;

 DELETE FROM
 mtl_consigned_diag_errors
 WHERE ( request_id <> g_request_id) OR (
  request_id is NULL ) ;


   IF g_debug = 1
   THEN
     INV_LOG_UTIL.trace
    ( '<<< Purge_diagnostics_passed_rec' ,9);
   END IF;



EXCEPTION

  WHEN OTHERS THEN
   IF g_debug = 1
   THEN
    INV_LOG_UTIL.trace
    ( 'SQLERRM: '|| SQLERRM,9 );

   INV_LOG_UTIL.trace
    ( 'OTHERS exception ',
      'Purge_diagnostics_passed_rec' ,9);
   END IF;

  RAISE ;

END Purge_diagnostics_passed_rec ;


-------------------------------------------------------------
--- Process_Validated_Record
------------------------------------------------------------
PROCEDURE Process_Validated_Record
( p_record_type IN NUMBER )
IS

BEGIN
  IF g_debug = 1
  THEN
    INV_LOG_UTIL.trace
    ( 'Start Move records ','Process_Validated_Record',9);
    INV_LOG_UTIL.trace
    ( 'p_record_type => '|| p_record_type,9);
  END IF;

  BEGIN
   IF p_record_type = 1
   THEN
    INSERT INTO
       mtl_consigned_diag_errors
      ( RECORD_ID
      , ORGANIZATION_ID
      , INVENTORY_ITEM_ID
      , REVISION
      , OWNING_TP_TYPE
      , OWNING_ORGANIZATION_ID
      , PLANNING_TP_TYPE
      , PLANNING_ORGANIZATION_ID
      , PO_HEADER_ID
      , AGENT_ID
      , RECORD_TYPE
      , ERROR_CODE
      , ACTION_CODE
      , LAST_NOTIFICATION_DATE
      , NOTIFICATION_ID
      , CREATION_DATE
      , CREATED_BY
      , LAST_UPDATE_DATE
      , LAST_UPDATED_BY
      , LAST_UPDATE_LOGIN
      , REQUEST_ID
      , PROGRAM_APPLICATION_ID
      , PROGRAM_ID
      , PROGRAM_UPDATE_DATE
      , error_type
      , primary_uom
      , purchasing_uom
      ) SELECT
          mtl_consigned_diag_errors_s.NEXTVAL
        , mcdet.ORGANIZATION_ID
        , mcdet.INVENTORY_ITEM_ID
        , mcdet.REVISION
        , 1
        , mcdet.OWNING_ORGANIZATION_ID
        , null --- PLANNING_ORGANIZATION_TYPE
        , null --- PLANNING_ORGANIZATION_ID
        , mcdet.PO_HEADER_ID
        , mcdet.AGENT_ID
        , mcdet.RECORD_TYPE
        , mcdet.mcde_ERROR_CODE
        , mcdet.mcde_ACTION_CODE
        , null               -- LAST_NOTIFICATION_DATE
        , null               -- NOTIFICATION_ID
        , sysdate            -- CREATION_DATE
        , g_user_id -- Created_by
        , sysdate            -- LAST_UPDATE_DATE
        , g_user_id
        , g_user_id
        , g_request_id
        , g_program_application_id
        , g_program_id
        , sysdate
        , error_type
        , primary_uom
        , purchasing_uom
        FROM mtl_consigned_diag_temp mcdet
        WHERE mcdet.error_code is not null
          AND NOT EXISTS
              ( SELECT 1
                FROM  mtl_consigned_diag_errors mcde
                WHERE mcde.organization_id        =
                      mcdet.organization_id
                  and mcde.owning_organization_id =
                      mcdet.owning_organization_id
                  and mcde.error_code        = mcdet.mcde_error_code
                  and mcde.inventory_item_id = mcdet.inventory_item_id
                  and mcde.record_type       = mcdet.record_type
                  and NVL(mcde.revision,-9876321)
                      = NVL(mcdet.revision,-9876321)
              );

            IF g_debug = 1
            THEN
             INV_LOG_UTIL.trace
              ( 'Phase 2',9);
            END IF;

           UPDATE mtl_consigned_diag_errors mcde
           SET mcde.request_id =
             ( SELECT g_request_id
               FROM mtl_consigned_diag_temp mcdet
               WHERE MCDE.organization_id   = mcdet.organization_id
                 AND MCDE.owning_organization_id   =
                       mcdet.owning_organization_id
                 AND MCDE.error_code        = mcdet.mcde_error_code
                 AND MCDE.inventory_item_id = mcdet.inventory_item_id
                 AND mcde.record_type       = mcdet.record_type
                 AND NVL(mcde.revision,-98763245 )
                    = NVL(mcdet.revision , -98763245 )
             )
       WHERE ( MCDE.request_id <>  g_request_id)  OR
          ( MCDE.request_id IS NULL ) ;


    ELSE
      INSERT INTO
       mtl_consigned_diag_errors
      ( RECORD_ID
      , ORGANIZATION_ID
      , INVENTORY_ITEM_ID
      , REVISION
      , OWNING_TP_TYPE
      , OWNING_ORGANIZATION_ID
      , PLANNING_TP_TYPE
      , PLANNING_ORGANIZATION_ID
      , PO_HEADER_ID
      , AGENT_ID
      , RECORD_TYPE
      , ERROR_CODE
      , ACTION_CODE
      , LAST_NOTIFICATION_DATE
      , NOTIFICATION_ID
      , CREATION_DATE
      , CREATED_BY
      , LAST_UPDATE_DATE
      , LAST_UPDATED_BY
      , LAST_UPDATE_LOGIN
      , REQUEST_ID
      , PROGRAM_APPLICATION_ID
      , PROGRAM_ID
      , PROGRAM_UPDATE_DATE
      , error_type
      , primary_uom
      , purchasing_uom
      ) SELECT
          mtl_consigned_diag_errors_s.NEXTVAL
        , mcdet.ORGANIZATION_ID
        , mcdet.INVENTORY_ITEM_ID
        , mcdet.REVISION
        , 1
        , mcdet.OWNING_ORGANIZATION_ID
        , null --- PLANNING_ORGANIZATION_TYPE
        , null --- PLANNING_ORGANIZATION_ID
        , mcdet.PO_HEADER_ID
        , mcdet.AGENT_ID
        , mcdet.RECORD_TYPE
        , mcdet.mcde_ERROR_CODE
        , mcdet.mcde_ACTION_CODE
        , null               -- LAST_NOTIFICATION_DATE
        , null               -- NOTIFICATION_ID
        , sysdate            -- CREATION_DATE
        , g_user_id -- Created_by
        , sysdate            -- LAST_UPDATE_DATE
        , g_user_id
        , g_user_id
        , g_request_id
        , g_program_application_id
        , g_program_id
        , sysdate
        , error_type
        , primary_uom
        , purchasing_uom
        FROM mtl_consigned_diag_temp mcdet
        WHERE mcdet.error_code is not null
          AND NOT EXISTS
              ( SELECT 1
                FROM  mtl_consigned_diag_errors mcde
                WHERE mcde.organization_id        =
                      mcdet.organization_id
                  and mcde.owning_organization_id =
                      mcdet.owning_organization_id
                  and mcde.error_code        = mcdet.mcde_error_code
                  and mcde.inventory_item_id = mcdet.inventory_item_id
                  and mcde.record_type       = mcdet.record_type
                  and mcde.po_header_id      = mcdet.po_header_id
                  and NVL(mcde.revision,-9876321)
                      = NVL(mcdet.revision,-9876321)
              )
          and mcdet.record_type = 2;

            IF g_debug = 1
            THEN
             INV_LOG_UTIL.trace
              ( 'Phase 2 ',9);
            END IF;


        UPDATE mtl_consigned_diag_errors mcde
           SET mcde.request_id =
             ( SELECT g_request_id
               FROM mtl_consigned_diag_temp mcdet
               WHERE MCDE.organization_id   = mcdet.organization_id
                 AND MCDE.owning_organization_id   =
                       mcdet.owning_organization_id
                 AND MCDE.error_code        = mcdet.mcde_error_code
                 AND MCDE.inventory_item_id = mcdet.inventory_item_id
                 AND mcde.record_type       = mcdet.record_type
                 AND mcde.po_header_id      = mcdet.po_header_id
                 AND NVL(mcde.revision,-98763245 )
                    = NVL(mcdet.revision , -98763245 )
             )
       WHERE ( MCDE.request_id <>  g_request_id)  OR
          ( MCDE.request_id IS NULL ) ;

    END IF;

    EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
       IF g_debug = 1
       THEN
         INV_LOG_UTIL.trace
         ( 'No data Found Exception ','Process_Validated_Record',9);
       END IF;
  END ;

  IF g_debug = 1
  THEN
    INV_LOG_UTIL.trace
    ( '<< OUT Moving records ','Process_Validated_Record',9);
  END IF;

EXCEPTION

  WHEN OTHERS THEN
   IF g_debug = 1
   THEN
    INV_LOG_UTIL.trace
    ( 'SQLERRM: '|| SQLERRM,9 );

   INV_LOG_UTIL.trace
    ( 'OTHERS exception ',
      'Process_Validated_Record' ,9);
   END IF;

  RAISE ;

END Process_Validated_Record ;

---------------------------------------------------------
--PROCEDURE set_error_action_code
----------------------------------------------------------
PROCEDURE set_error_action_code
( p_error_code        IN VARCHAR2
, x_mcde_error_code  OUT NOCOPY VARCHAR2
, x_mcde_action_code OUT NOCOPY VARCHAR2
, x_error_type       OUT NOCOPY VARCHAR2
)

IS

BEGIN

  IF p_error_code = 'INV_CONS_SUP_GL_API_NO_RATE'
  THEN
    x_mcde_error_code  := 'INV_CONS_SUP_E_GL_API_NO_RATE' ;
    x_mcde_action_code := 'INV_CONS_SUP_A_GL_API_NO_RATE' ;
    x_error_type       :=  2;

  ELSIF p_error_code = 'INV_CONS_SUP_NO_TAX_SETUP'
  THEN
    x_mcde_error_code := 'INV_CONS_SUP_E_NO_TAX_SETUP' ;
    x_mcde_action_code := 'INV_CONS_SUP_A_NO_TAX_SETUP' ;
    x_error_type       := 4 ;

  ELSIF p_error_code = 'INV_CONS_SUP_MANUAL_NUM_CODE'
  THEN
    x_mcde_error_code := 'INV_CONS_SUP_E_MAN_NUM_CODE' ;
    x_mcde_action_code := 'INV_CONS_SUP_A_MAN_NUM_CODE' ;
    x_error_type       := 3 ;

  ELSIF p_error_code = 'INV_CONS_SUP_NO_BPO_EXISTS'
  THEN
    x_mcde_error_code := 'INV_CONS_SUP_E_NO_BPO_EXISTS' ;
    x_mcde_action_code := 'INV_CONS_SUP_A_NO_BPO_EXISTS' ;
    x_error_type       := 1;

  ELSIF p_error_code = 'INV_CONS_SUP_NO_UOM_CONV'
  THEN
     x_mcde_error_code := 'INV_CONS_SUP_E_NO_UOM_CONV' ;
     x_mcde_action_code := 'INV_CONS_SUP_A_NO_UOM_CONV' ;
     x_error_type       := 1 ;

  ELSIF p_error_code = 'INV_CONS_SUP_NO_RATE_SETUP'
  THEN
    x_mcde_error_code := 'INV_CONS_SUP_E_NO_RATE_SETUP' ;
    x_mcde_action_code := 'INV_CONS_SUP_A_NO_RATE_SETUP' ;
    x_error_type       :=  2 ;

  ELSIF p_error_code = 'INV_CONS_SUP_AMT_AGREED_FAIL'
  THEN
    x_mcde_error_code := 'INV_CONS_SUP_E_AMT_AGREED_FAIL' ;
    x_mcde_action_code := 'INV_CONS_SUP_A_AMT_AGREED_FAIL' ;
    x_error_type       := 1 ;

  ELSIF p_error_code = 'INV_CONS_SUP_INVALID_BPO'
  THEN
    x_mcde_error_code := 'INV_CONS_SUP_E_INVALID_BPO' ;
    x_mcde_action_code := 'INV_CONS_SUP_A_INVALID_BPO' ;
    x_error_type       := 1 ;

  ELSIF p_error_code = 'INV_CONS_SUP_AMT_AGREED_FAIL'
  THEN
    x_mcde_error_code := 'INV_CONS_SUP_E_AMT_AGREED_FAIL' ;
    x_mcde_action_code := 'INV_CONS_SUP_A_AMT_AGREED_FAIL' ;
    x_error_type       := 1 ;

  ELSIF p_error_code = 'INV_CONS_SUP_GEN_ACCT'
  THEN
    x_mcde_error_code := 'INV_CONS_SUP_E_GEN_ACCT' ;
    x_mcde_action_code := 'INV_CONS_SUP_A_GEN_ACCT' ;
    x_error_type       := 4 ;

  ELSE
    x_mcde_error_code := 'INV_CONS_SUP_E_NO_BPO_EXISTS' ;
    x_mcde_action_code := 'INV_CONS_SUP_A_NO_BPO_EXISTS' ;
    x_error_type       := 1;
  END IF;





END set_error_action_code ;

FUNCTION get_buyer
( p_po_header_id IN NUMBER
, p_inventory_item_id IN NUMBER
, p_vendor_site_id    IN NUMBER
, p_organization_id   IN NUMBER
, p_revision          IN VARCHAR2
)
RETURN NUMBER
IS
l_po_header_id NUMBER;
l_vendor_id NUMBER ;

CURSOR C_buyer IS
      SELECT
         poh.PO_HEADER_ID
      ,  poh.AGENT_ID
      ,  poh.SEGMENT1
      FROM
        po_headers_all poh
      , po_lines_all pol
      , po_line_locations_all poll
     WHERE poh.po_header_id = pol.po_header_id
       AND poh.po_header_id = poll.po_header_id
       AND pol.po_header_id = poll.po_header_id
       AND pol.po_line_id   = poll.PO_LINE_ID
       AND poll.CONSIGNED_FLAG   = 'Y'
       AND pol.ITEM_ID          =   p_inventory_item_id
       AND poh.vendor_id        = l_vendor_id
       AND poh.vendor_site_id   = p_vendor_site_id
       AND ( pol.item_revision = p_revision
               OR pol.item_revision IS NULL ) ;

 l_buyer_rec C_buyer%ROWTYPE ;
 l_buyer_id NUMBER ;
 l_segment1 VARCHAR2(300);

BEGIN

  BEGIN
    IF p_po_header_id IS NOT NULL
    THEN
      SELECT agent_id
      INTO    l_buyer_id
      FROM po_headers_all
      WHERE po_header_id = p_po_header_id ;

    ELSE
       SELECT vendor_id
       INTO l_vendor_id
       FROM  po_vendor_sites_all
       WHERE vendor_site_id = p_vendor_site_id ;

       OPEN C_buyer ;
       FETCH C_buyer INTO
              l_po_header_id
            , l_buyer_id
            , l_segment1 ;

      IF C_buyer%NOTFOUND
      THEN
        l_buyer_id := NULL;
        IF g_debug = 1
        THEN
          INV_LOG_UTIL.trace
          ( 'C_buyer NO result ',null,9);
        END IF;
      END IF ;

      CLOSE C_buyer ;

    END IF;

    EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
     l_buyer_id := NULL ;
  END ;

  IF g_debug = 1
  THEN
    INV_LOG_UTIL.trace
     ( 'l_buyer_id => '|| l_buyer_id ,9);
  END IF;


  RETURN( l_buyer_id );

EXCEPTION

  WHEN OTHERS THEN
   IF g_debug = 1
   THEN

    INV_LOG_UTIL.trace
    ( 'SQLERRM: '|| SQLERRM,9 );

   INV_LOG_UTIL.trace
    ( 'OTHERS exception ',
      'get_buyer',9);
   END IF;

  RAISE ;

END get_buyer ;



--------------------------------------------------------
---    validate_consumption_txn
---------------------------------------------------------
PROCEDURE validate_consumption_txn
( p_organization_id        IN NUMBER
, p_inventory_item_id      IN NUMBER
, p_owning_organization_id IN NUMBER
, p_revision               IN VARCHAR2
, p_po_header_id           IN NUMBER
, x_error_code             OUT NOCOPY VARCHAR2
)

IS

CURSOR C_VALIDATE_PO
IS  SELECT
      Poh.blanket_total_amount
    FROM
      po_headers_all poh
    , po_lines_all pol
    WHERE poh.po_header_id = pol.po_header_id
      AND NVL(poh.approved_flag,'Y')  = 'Y'
      AND (TRUNC(NVL(poh.start_date,sysdate -1)) <= TRUNC(sysdate))
      AND (TRUNC(NVL(poh.end_date,sysdate +1)) >= TRUNC(sysdate))
      AND (TRUNC(NVL(pol.expiration_date,sysdate )) >= TRUNC(sysdate))
      AND (NVL(poh.cancel_flag,'N') = 'N'
           OR NVL(pol.cancel_flag,'N') = 'N')
      AND (NVL(poh.cancel_flag,'N') = 'N'
           OR NVL(pol.cancel_flag,'N') = 'N')
      AND NVL(pol.closed_code,'OPEN') = 'OPEN'
      AND poh.po_header_id     = p_po_header_id
      AND pol.item_id          = p_inventory_item_id
      AND ( pol.item_revision = p_revision
          OR pol.item_revision IS NULL );


l_blanket_total_amount  NUMBER ;

BEGIN

  x_error_code := NULL;
  IF g_debug = 1
  THEN
    INV_LOG_UTIL.trace
     ( '>> IN validate_consumption_txn' ,
       'INV_CONSIGNED_DIAGNOSTICS_PROC',9);

    INV_LOG_UTIL.trace
     ( 'p_organization_id => '|| p_organization_id ,
       'INV_CONSIGNED_DIAGNOSTICS_PROC',9);

    INV_LOG_UTIL.trace
     ( 'p_inventory_item_id => '|| p_inventory_item_id ,
       'INV_CONSIGNED_DIAGNOSTICS_PROC',9);

    INV_LOG_UTIL.trace
     ( 'p_owning_organization_id => '|| p_owning_organization_id ,
       'INV_CONSIGNED_DIAGNOSTICS_PROC',9);

    INV_LOG_UTIL.trace
     ( 'p_revision => '|| p_revision ,
       'INV_CONSIGNED_DIAGNOSTICS_PROC',9);
    INV_LOG_UTIL.trace
     ( 'p_po_header_id => '|| p_po_header_id ,
       'INV_CONSIGNED_DIAGNOSTICS_PROC',9);
  END IF;

  BEGIN
   OPEN C_VALIDATE_PO ;
   FETCH C_VALIDATE_PO
   INTO
     l_blanket_total_amount ;

     IF C_VALIDATE_PO%NOTFOUND
     THEN
        x_error_code := 'INV_CONS_SUP_INVALID_BPO' ;
     END IF;
    CLOSE C_VALIDATE_PO ;

   END ;

   IF x_error_code is NULL
   THEN
     IF NVL(l_blanket_total_amount,0) > 0
     THEN
      x_error_code := 'INV_CONS_SUP_AMT_AGREED_FAIL' ;
     ELSE
      x_error_code := NULL;
     END IF;
   END IF;

   l_blanket_total_amount := NULL;

  IF g_debug = 1
  THEN
    INV_LOG_UTIL.trace
     ( 'x_error_code => '|| x_error_code ,
       'INV_CONSIGNED_DIAGNOSTICS_PROC',9);
    INV_LOG_UTIL.trace
     ( 'l_blanket_total_amount => '|| l_blanket_total_amount ,
       'INV_CONSIGNED_DIAGNOSTICS_PROC',9);
    INV_LOG_UTIL.trace
     ( '<< OUT validate_consumption_txn' ,
       'INV_CONSIGNED_DIAGNOSTICS_PROC',9);
  END IF;


EXCEPTION

  WHEN OTHERS THEN
   IF g_debug = 1
   THEN

    INV_LOG_UTIL.trace
    ( 'SQLERRM: '|| SQLERRM,9 );

   INV_LOG_UTIL.trace
    ( 'OTHERS exception ',
      'get_buyer',9);
   END IF;

  RAISE ;

END validate_consumption_txn ;

---------------------------------------------------
---Consumption_Advice_diagnostics
----------------------------------------------------
PROCEDURE Consumption_Advice_diagnostics
(p_error_record_id IN NUMBER )
IS


CURSOR
C_cad_temp IS
SELECT
    ORGANIZATION_ID
  , INVENTORY_ITEM_ID
  , REVISION
  , OWNING_ORGANIZATION_ID
  , po_header_id
FROM mtl_consigned_diag_temp ;

l_cad_temp_rec C_cad_temp%ROWTYPE ;


l_po_id               NUMBER;
l_error_code          VARCHAR2(40);
l_buyer_id            number;
l_error_type          VARCHAR2(1);

l_cad_error_code     VARCHAR2(40);
l_cad_action_code    VARCHAR2(40);

BEGIN
 IF g_debug = 1
 THEN
  INV_LOG_UTIL.trace
    ( '******************************************** ' ,
      'INV_CONSIGNED_DIAGNOSTICS_PROC',9);
  INV_LOG_UTIL.trace
    ( '>>> IN Consumption_Advice_diagnostics' ,
      'INV_CONSIGNED_DIAGNOSTICS_PROC',9);
  INV_LOG_UTIL.trace
    ( 'p_error_record_id => '|| p_error_record_id ,
      'Consumption_Advice_diagnostics ',9);
  END IF;

   DELETE FROM mtl_consigned_diag_temp ;

   IF p_error_record_id IS NULL
   THEN
     IF g_debug = 1
     THEN
       INV_LOG_UTIL.trace
       ( 'REGULAR - Before Insert into mtl_consigned_diag_temp' ,
        'Consumption_Advice_diagnostics',9);
      END IF;

     INSERT into mtl_consigned_diag_temp (
        PO_header_id
      , INVENTORY_ITEM_ID
      , REVISION
      , organization_id
      , OWNING_ORGANIZATION_ID
      , RECORD_TYPE )
      SELECT
       DISTINCT
         mmt.transaction_source_id
        , mmt.inventory_item_id
        , mmt.revision
        , mmt.organization_id
        , mmt.owning_organization_id
        , 2
      FROM
        mtl_consumption_transactions mct
      , mtl_material_transactions mmt
      WHERE mct.transaction_id = mmt.transaction_id
        AND mct.consumption_processed_flag <> 'Y'
        AND mmt.transaction_type_id = 74 ;

    ELSE
      IF g_debug = 1
      THEN
        INV_LOG_UTIL.trace
        ( 'REVALIDATE - Before Insert into mtl_consigned_diag_temp' ,
           'Consumption_Advice_diagnostics',9);
       END IF;

     INSERT into mtl_consigned_diag_temp (
        PO_header_id
      , INVENTORY_ITEM_ID
      , REVISION
      , organization_id
      , OWNING_ORGANIZATION_ID
      , RECORD_TYPE )
      SELECT
         PO_header_id
        , inventory_item_id
        , revision
        , organization_id
        , owning_organization_id
        , 2
      FROM
        MTL_CONSIGNED_DIAG_ERRORS
      WHERE record_id = p_error_record_id ;

    END IF;

   IF g_debug = 1
   THEN
     INV_LOG_UTIL.trace
     ( 'after Insert into mtl_consigned_diag_temp' ,
      'Consumption_Advice_diagnostics',9);
    END IF;


   FOR l_cad_temp_rec IN  C_cad_temp
   LOOP
     IF g_debug = 1
     THEN
       INV_LOG_UTIL.trace
       ( 'ORGANIZATION_ID => '|| l_cad_temp_rec.ORGANIZATION_ID ,null
       ,9);
       INV_LOG_UTIL.trace
       ( 'INVENTORY_ITEM_ID => '|| l_cad_temp_rec.INVENTORY_ITEM_ID
       ,null
       ,9);
       INV_LOG_UTIL.trace
       ( 'OWNING_ORGANIZATION_ID => '|| l_cad_temp_rec.OWNING_ORGANIZATION_ID
         ,null
        ,9);

       INV_LOG_UTIL.trace
       ( 'po_header_id => '|| l_cad_temp_rec.po_header_id
         ,null
        ,9);

       INV_LOG_UTIL.trace
       ( 'Calling validate_consumption_txn ' ,
       'Consumption_Advice_diagnostics',9);
     END IF;

    l_error_code       := NULL;
    l_cad_error_code   := NULL;
    l_cad_action_code  := NULL;
    l_po_id            := NULL;
    l_error_type       := NULL ;
    l_buyer_id         := NULL;

   validate_consumption_txn
   ( p_organization_id         => l_cad_temp_rec.ORGANIZATION_ID
    , p_inventory_item_id      => l_cad_temp_rec.INVENTORY_ITEM_ID
    , p_owning_organization_id => l_cad_temp_rec.OWNING_ORGANIZATION_ID
    , p_revision               => l_cad_temp_rec.revision
    , p_po_header_id           => l_cad_temp_rec.po_header_id
    , x_error_code             => l_error_code
    );

   IF (g_debug = 1)
   THEN
     INV_LOG_UTIL.trace
     ( 'Out validate_consumption_txn ',
             'Consumption_Advice_diagnostics'
      , 9
      );

      INV_LOG_UTIL.trace
      ( 'l_error_code => '|| l_error_code
       ,'Consumption_Advice_diagnostics'
     , 9);
   END IF;

   IF l_error_code IS NOT NULL
   THEN
    l_buyer_id :=  get_buyer
     ( p_po_header_id      => l_cad_temp_rec.po_header_id
     , p_inventory_item_id => l_cad_temp_rec.INVENTORY_ITEM_ID
     , p_vendor_site_id    => l_cad_temp_rec.OWNING_ORGANIZATION_ID
     , p_organization_id   => l_cad_temp_rec.ORGANIZATION_ID
     , p_revision         => l_cad_temp_rec.revision
     );

     set_error_action_code
     ( p_error_code        => l_error_code
     , x_mcde_error_code   => l_cad_error_code
     , x_mcde_action_code  => l_cad_action_code
    ,  x_error_type        => l_error_type
     );


     UPDATE mtl_consigned_diag_temp
     SET    error_code       = l_error_code
     ,    mcde_error_code    = l_cad_error_code
     ,    mcde_action_code   = l_cad_action_code
     , agent_id              = l_buyer_id
     , error_type            = l_error_type
     WHERE ORGANIZATION_ID         = l_cad_temp_rec.ORGANIZATION_ID
       AND  INVENTORY_ITEM_ID      = l_cad_temp_rec.INVENTORY_ITEM_ID
       AND  OWNING_ORGANIZATION_ID = l_cad_temp_rec.OWNING_ORGANIZATION_ID
       AND  nvl(revision,-98765432) = nvl(l_cad_temp_rec.revision, -98765432 )
       AND  po_header_id            = l_cad_temp_rec.po_header_id ;

       g_revalidate_error_code := l_cad_error_code ;

       l_error_code      := NULL;
       l_cad_error_code := NULL;
       l_cad_action_code := NULL;
       l_po_id            := NULL;
       l_error_type       := NULL ;

       IF (g_debug = 1)
       THEN
         INV_LOG_UTIL.trace
         ( 'after  UPDATE mtl_consigned_diag_temp '
            ,'Consumption_Advice_diagnostics'
        , 9
        );
       END IF;
     ELSE
       g_revalidate_error_code := NULL ;
     END IF;
   END LOOP;

  IF (g_debug = 1)
  THEN
         INV_LOG_UTIL.trace
         ( 'after the temp table LOOP',
             'Consumption_Advice_diagnostics'
        , 9
        );
  END IF;

  l_error_code       := NULL;
  l_cad_error_code   := NULL;
  l_cad_action_code  := NULL;
  l_po_id            := NULL;
  l_error_type       := NULL ;
  l_buyer_id         := NULL;


  Process_Validated_Record
  (p_record_type => 2 );



   IF g_debug = 1
   THEN
  INV_LOG_UTIL.trace
    ( '******************************************** ' ,
      'INV_CONSIGNED_DIAGNOSTICS_PROC',9);
     INV_LOG_UTIL.trace
     ( '<<< OUT Consumption_Advice_diagnostics' ,
      'INV_CONSIGNED_DIAGNOSTICS_PROC',9);
   END IF;

EXCEPTION

  WHEN OTHERS THEN
   IF g_debug = 1
   THEN

    INV_LOG_UTIL.trace
    ( 'SQLERRM: '|| SQLERRM,9 );

   INV_LOG_UTIL.trace
    ( 'Error in Consumption_Advice_diagnostics' ,
      'INV_CONSIGNED_DIAGNOSTICS_PROC',9);
   END IF;

  RAISE ;

END Consumption_Advice_diagnostics ;

------------------------------------------------------------
--- Ownership_transfer_diagnostics
------------------------------------------------------------
PROCEDURE Ownership_transfer_diagnostics
(p_error_record_id IN NUMBER )
IS

CURSOR
C_moqd_temp IS
SELECT
    ORGANIZATION_ID
  , INVENTORY_ITEM_ID
  , REVISION
  , OWNING_ORGANIZATION_ID
FROM mtl_consigned_diag_temp ;

l_moqd_temp_rec C_moqd_temp%ROWTYPE ;


l_po_id               NUMBER;
l_return_status       VARCHAR2(10);
l_error_code          VARCHAR2(40);

l_mcde_error_code     VARCHAR2(40);
l_mcde_action_code    VARCHAR2(40);

l_po_price            NUMBER;
l_account_id          NUMBER;
l_rate                NUMBER;
l_rate_type           VARCHAR2(30);
l_rate_date           date;
l_currency_code       VARCHAR2(30);
l_msg_count           number;
l_msg_data            VARCHAR2(300);
l_buyer_id            number;
l_error_type          VARCHAR2(2);
l_error_po_id         number ;
l_primary_uom         VARCHAR2(30) ;
l_purchasing_uom      VARCHAR2(30) ;

l_primary_uom_code         VARCHAR2(30) ;
l_purchasing_uom_code      VARCHAR2(30) ;

BEGIN
 IF g_debug = 1
 THEN
  INV_LOG_UTIL.trace
    ( '++++++++++++++++++++++++++++++++++++++++' ,
      'INV_CONSIGNED_DIAGNOSTICS_PROC',9);
  INV_LOG_UTIL.trace
    ( '>>> IN Ownership_transfer_diagnostics',
      'INV_CONSIGNED_DIAGNOSTICS_PROC',9);
  INV_LOG_UTIL.trace
    ( 'p_error_record_id => '|| p_error_record_id ,
      'Ownership_transfer_diagnostics' ,9);
  END IF;


  DELETE FROM mtl_consigned_diag_temp ;

  IF p_error_record_id is NULL
  THEN
    IF g_debug = 1
    THEN
      INV_LOG_UTIL.trace
      ( ' REgular - Before Insert into Temp ',
      'Ownership_transfer_diagnostics' ,9);
    END IF;

    INSERT INTO mtl_consigned_diag_temp (
      ORGANIZATION_ID
    , INVENTORY_ITEM_ID
    , REVISION
    , OWNING_ORGANIZATION_ID
    , RECORD_TYPE
    ) SELECT DISTINCT
      ORGANIZATION_ID
    , INVENTORY_ITEM_ID
    , REVISION
    , OWNING_ORGANIZATION_ID
    , 1
    FROM MTL_ONHAND_QUANTITIES_DETAIL
    WHERE OWNING_TP_TYPE = 1 ;

  ELSE
   IF g_debug = 1
    THEN
      INV_LOG_UTIL.trace
      ( ' REvalidate - Before Insert into Temp ',
      'Ownership_transfer_diagnostics' ,9);
    END IF;

    INSERT INTO mtl_consigned_diag_temp (
      ORGANIZATION_ID
    , INVENTORY_ITEM_ID
    , REVISION
    , OWNING_ORGANIZATION_ID
    , RECORD_TYPE
    ) SELECT
      ORGANIZATION_ID
    , INVENTORY_ITEM_ID
    , REVISION
    , OWNING_ORGANIZATION_ID
    , 1
    FROM
      MTL_consigned_diag_errors
    WHERE record_id = p_error_record_id ;

  END IF;

 IF g_debug = 1
 THEN
  INV_LOG_UTIL.trace
    ( 'after Insert into MCDET TEMP table ',
      'Ownership_transfer_diagnostics' ,9);
 END IF;

  FOR l_moqd_temp_rec IN  C_moqd_temp
  LOOP
   IF g_debug = 1
   THEN

     INV_LOG_UTIL.trace
     ( 'ORGANIZATION_ID => '|| l_moqd_temp_rec.ORGANIZATION_ID ,null
       ,9);
     INV_LOG_UTIL.trace
     ( 'INVENTORY_ITEM_ID => '|| l_moqd_temp_rec.INVENTORY_ITEM_ID
       ,null
       ,9);
     INV_LOG_UTIL.trace
     ( 'OWNING_ORGANIZATION_ID => '|| l_moqd_temp_rec.OWNING_ORGANIZATION_ID
         ,null
        ,9);
     INV_LOG_UTIL.trace
     ( 'Calling Process_Financial_Info ' ,
       'Ownership_transfer_diagnostics' ,9);
   END IF;

   l_error_code      := NULL;
   l_mcde_error_code := NULL;
   l_mcde_action_code := NULL;
   l_po_id            := NULL;
   l_error_type       := NULL ;
   l_po_price         := NULL;
   l_account_id       := NULL;
   l_rate             := NULL;
   l_rate_type        := NULL;
   l_rate_date        := NULL;
   l_currency_code    := NULL;
   l_return_status    := NULL;
   l_buyer_id         := NULL;
   l_error_po_id      := NULL ;
   l_primary_uom      := NULL;
   l_purchasing_uom   := NULL ;
   l_primary_uom_code      := NULL;
   l_purchasing_uom_code   := NULL ;


   INV_THIRD_PARTY_STOCK_PVT.Process_Financial_Info
   ( p_mtl_transaction_id         => 99999999
   , p_rct_transaction_id         => 999999991
   , p_transaction_source_type_id => 1
   , p_transaction_action_id      => 6
   , p_inventory_item_id          => l_moqd_temp_rec.INVENTORY_ITEM_ID
   , p_owning_organization_id     => l_moqd_temp_rec.OWNING_ORGANIZATION_ID
   , p_xfr_owning_organization_id => l_moqd_temp_rec.ORGANIZATION_ID
   , p_organization_id            => l_moqd_temp_rec.ORGANIZATION_ID
   , p_transaction_quantity       => 1
   , p_transaction_date           => sysdate
   , p_transaction_source_id      => l_po_id
   , p_item_revision              => l_moqd_temp_rec.revision
   , p_calling_action             => 'D'
   , x_po_price                   => l_po_price
   , x_account_id                 => l_account_id
   , x_rate                       => l_rate
   , x_rate_type                  => l_rate_type
   , x_rate_date                  => l_rate_date
   , x_currency_code              => l_currency_code
   , x_msg_count                  => l_msg_count
   , x_msg_data                   => l_msg_data
   , x_return_status              => l_return_status
   , x_error_code                 => l_error_code
   , x_po_header_id               => l_error_po_id
   , x_primary_uom                => l_primary_uom
   , x_purchasing_uom             => l_purchasing_uom
   );

   l_primary_uom_code := get_uom_code( p_uom => l_primary_uom);
   l_purchasing_uom_code := get_uom_code( p_uom => l_purchasing_uom);

   IF (g_debug = 1)
   THEN
   INV_LOG_UTIL.trace
    ( 'Out of Process_Financial_Info - Diagnostics ',
             'Ownership_transfer_diagnostics'
    , 9
    );
    INV_LOG_UTIL.trace
    ( 'l_error_code =>' || l_error_code ,'INV_THIRD_PARTY_STOCK_PVT'
     , 9);
    INV_LOG_UTIL.trace
    ( 'po_header_id => '|| l_po_id ,null
     , 9);
    INV_LOG_UTIL.trace
    ( 'l_error_po_id => '|| l_error_po_id, null
     , 9);
    INV_LOG_UTIL.trace
    ( 'l_account_id => '|| l_account_id, null
     , 9);
    INV_LOG_UTIL.trace
    ( 'l_return_status => '|| l_return_status ,'INV_THIRD_PARTY_STOCK_PVT'
     , 9);
    INV_LOG_UTIL.trace
    ( 'l_primary_uom =>' || l_primary_uom ,'INV_THIRD_PARTY_STOCK_PVT'
     , 9);

    INV_LOG_UTIL.trace
    ( 'l_purchasing_uom =>' || l_purchasing_uom ,'INV_THIRD_PARTY_STOCK_PVT'
     , 9);
    INV_LOG_UTIL.trace
    ( 'l_primary_uom_code =>' || l_primary_uom_code ,
          'INV_THIRD_PARTY_STOCK_PVT'
     , 9);

    INV_LOG_UTIL.trace
    ( 'l_purchasing_uom_code =>' || l_purchasing_uom_code ,
          'INV_THIRD_PARTY_STOCK_PVT'
     , 9);
   END IF;

   IF l_error_code is NULL
   THEN
     IF l_return_status <>  FND_API.G_RET_STS_SUCCESS
     THEN
       l_error_code := l_return_status ;

     ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS
     THEN
      g_revalidate_error_code := NULL ;
      l_error_code := NULL ;
     END IF;

   END IF;

   IF l_error_code IS NOT NULL
   THEN
    l_buyer_id :=  get_buyer
     ( p_po_header_id      => l_error_po_id
     , p_inventory_item_id => l_moqd_temp_rec.INVENTORY_ITEM_ID
     , p_vendor_site_id    => l_moqd_temp_rec.OWNING_ORGANIZATION_ID
     , p_organization_id   => l_moqd_temp_rec.ORGANIZATION_ID
     , p_revision          => l_moqd_temp_rec.revision
     );

     set_error_action_code
     ( p_error_code        => l_error_code
     , x_mcde_error_code   => l_mcde_error_code
     , x_mcde_action_code  => l_mcde_action_code
     ,  x_error_type       => l_error_type
     );


     UPDATE mtl_consigned_diag_temp
     SET    error_code       = l_error_code
     ,    mcde_error_code    = l_mcde_error_code
     ,    mcde_action_code   = l_mcde_action_code
     , agent_id              = l_buyer_id
     , po_header_id          = l_error_po_id
     , error_type            = l_error_type
     , primary_uom           = l_primary_uom_code
     , purchasing_uom        = l_purchasing_uom_code
     WHERE ORGANIZATION_ID         = l_moqd_temp_rec.ORGANIZATION_ID
       AND  INVENTORY_ITEM_ID      = l_moqd_temp_rec.INVENTORY_ITEM_ID
       AND  OWNING_ORGANIZATION_ID = l_moqd_temp_rec.OWNING_ORGANIZATION_ID
      AND  nvl(revision,-98765439) = nvl(l_moqd_temp_rec.revision, -98765439 );

       g_revalidate_error_code := l_mcde_error_code ;

       l_error_code      := NULL;
       l_mcde_error_code := NULL;
       l_mcde_action_code := NULL;
       l_po_id            := NULL;
       l_error_po_id      := NULL ;
       l_error_type       := NULL ;
       l_primary_uom      := NULL;
       l_purchasing_uom   := NULL ;
       l_primary_uom_code      := NULL;
       l_purchasing_uom_code   := NULL ;

       IF (g_debug = 1)
       THEN
         INV_LOG_UTIL.trace
         ( 'after  UPDATE mtl_consigned_diag_temp '
            ,'Ownership_transfer_diagnostics'
        , 9
        );
       END IF;
    END IF;
  END LOOP;

  IF (g_debug = 1)
  THEN
         INV_LOG_UTIL.trace
         ( 'after the temp table LOOP',
             'Ownership_transfer_diagnostics'
        , 9
        );
  END IF;

   l_error_code      := NULL;
   l_primary_uom      := NULL;
   l_purchasing_uom   := NULL ;
   l_primary_uom_code      := NULL;
   l_purchasing_uom_code   := NULL ;
   l_mcde_error_code := NULL;
   l_mcde_action_code := NULL;
   l_po_id            := NULL;
   l_error_po_id      := NULL ;
   l_error_type       := NULL ;
   l_po_price         := NULL;
   l_account_id       := NULL;
   l_rate             := NULL;
   l_rate_type        := NULL;
   l_rate_date        := NULL;
   l_currency_code    := NULL;
   l_return_status    := NULL;
   l_buyer_id         := NULL;


  Process_Validated_Record
  (p_record_type => 1 );


  IF g_debug = 1
  THEN
  INV_LOG_UTIL.trace
    ( '++++++++++++++++++++++++++++++++++++++++' ,
      'INV_CONSIGNED_DIAGNOSTICS_PROC',9);
    INV_LOG_UTIL.trace
    ( '<<< OUT Ownership_transfer_diagnostics',
      'INV_CONSIGNED_DIAGNOSTICS_PROC',9);
  END IF;



EXCEPTION

  WHEN OTHERS THEN
   IF g_debug = 1
   THEN

    INV_LOG_UTIL.trace
    ( 'SQLERRM: '|| SQLERRM,9 );

   INV_LOG_UTIL.trace
    ( 'Error in Ownership_transfer_diagnostics',
      'INV_CONSIGNED_DIAGNOSTICS_PROC',9);
   END IF;

  RAISE ;

END Ownership_transfer_diagnostics ;



---------------------------------------------------------
--Revalidate Record
-------------------------------------------------------------
PROCEDURE Revalidate_error_record
( p_error_record_id IN NUMBER
, x_result_out  OUT NOCOPY VARCHAR2
)
IS

l_record_type NUMBER ;
l_request_id  NUMBER;
l_error_code  VARCHAR2(40);

BEGIN

   IF g_debug = 1
   THEN
    INV_LOG_UTIL.trace
    ( '>> Revalidate_error_record' ,'INV_CONSIGNED_DIAGNOSTICS_PROC',9);
    INV_LOG_UTIL.trace
    ( 'p_error_record_id => '|| p_error_record_id,null,9);
   END IF;

   g_revalidate_error_code := NULL ;

  BEGIN
   SELECT
    record_type
   , request_id
   , error_code
   INTO
     l_record_type
    , l_request_id
    , l_error_code
   FROM
    mtl_consigned_diag_errors
   WHERE record_id = p_error_record_id ;

   EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
    x_result_out := 'FAIL' ;
    l_record_type := NULL;
    l_request_id  := NULL;

     IF g_debug = 1
     THEN
       INV_LOG_UTIL.trace
       ( '<< out Revalidate_error_record'
        ,'INV_CONSIGNED_DIAGNOSTICS_PROC',9);
     END IF;
    END ;

  IF x_result_out IS NULL
  THEN
    g_request_id := l_request_id ;

    IF g_debug = 1
     THEN
       INV_LOG_UTIL.trace
       ( 'l_record_type => '|| l_record_type,null,9) ;
       INV_LOG_UTIL.trace
       ( 'l_request_id => '|| l_request_id,null,9);
       INV_LOG_UTIL.trace
       ( 'g_request_id => '|| g_request_id,null,9);
     END IF;


    IF l_record_type = 1
    THEN
      INV_CONSIGNED_DIAGNOSTICS_PROC.Ownership_transfer_diagnostics
      (p_error_record_id => p_error_record_id );

    ELSIF l_record_type = 2
    THEN
      INV_CONSIGNED_DIAGNOSTICS_PROC.Consumption_Advice_diagnostics
      (p_error_record_id => p_error_record_id);
    END IF;

    IF g_debug = 1
     THEN
       INV_LOG_UTIL.trace
       ( 'g_revalidate_error_code => '|| g_revalidate_error_code,null,9);
    END IF;

    BEGIN
     IF g_revalidate_error_code IS NULL
     THEN
       x_result_out := 'PASS' ;
       DELETE from mtl_consigned_diag_errors
       WHERE record_id = p_error_record_id ;
     ELSE
       x_result_out := 'FAIL' ;
       IF g_revalidate_error_code <> l_error_code
       THEN
         DELETE from mtl_consigned_diag_errors
         WHERE record_id = p_error_record_id ;

       END IF;
         INV_CONSIGNED_DIAGNOSTICS_PROC.Update_Consumption_Date ;
     END IF;
    END ;

    COMMIT;

    IF g_debug = 1
     THEN
       INV_LOG_UTIL.trace
       ( 'Out of validation ',null,9);
     END IF;
   END IF;

   g_revalidate_error_code := NULL;

   IF g_debug = 1
   THEN
    INV_LOG_UTIL.trace
    ( 'x_result_out => '|| x_result_out ,
       'Revalidate_error_record',9);
    INV_LOG_UTIL.trace
    ( '<< out Revalidate_error_record' ,'INV_CONSIGNED_DIAGNOSTICS_PROC',9);
   END IF;



EXCEPTION

  WHEN OTHERS THEN
   INV_LOG_UTIL.trace
    ( 'SQLERRM: '|| SQLERRM,9 );

   IF g_debug = 1
   THEN
   INV_LOG_UTIL.trace
    ( 'OTHERS exception ',
      'Revalidate_error_record',9);
   END IF;

  RAISE ;

END Revalidate_error_record ;

/*========================================================================
-- PROCEDURE : Consigned_diagnostics
-- PARAMETERS:
--
--             p_send_notification  IN VARCHAR2
--              to indicate if workflow notifications needs to be
--               send to the Buyer
--             p_notification_resend_days IN NUMBER
--              to indicate to send notification only if
--             las_notification sent date for the same combination
--             of org/item/supplier/site/error + p_notification_resend_days
--              >= sysdate
--
-- COMMENT   : This is the main concurrent program procedure
--              that is directly invoked by the conc program
--             " INV Consigned Inventory Diagnostics"
--             This program does not accept any specific ORG
--             as Input as the logic is to validate all
--             eligible consigned transactions
--             1) Ownership transfer to regulat stock and
--             2) Consumption Advice pre-validation
--             and insert into a new errors table
--             The results of the concurrent program can be
--             viewed from a separate HTML UI under INV
--=======================================================================*/

--=======================================================================*/
PROCEDURE Consigned_diagnostics
( p_send_notification        IN VARCHAR2
, p_notification_resend_days IN NUMBER
)
IS

l_return_status VARCHAR2(1) ;
l_msg_data     VARCHAR2(3000) ;
l_msg_count    NUMBER ;
BEGIN

 l_return_status := NULL;
 l_msg_data  := NULL;
 l_msg_count := NULL;

 IF g_debug = 1
 THEN
   INV_LOG_UTIL.trace
   ( '>> INVRCIDB: IN Consigned_diagnostics ',
         'INV_CONSIGNED_DIAGNOSTICS_PROC' , 9);

  END IF;

  INV_CONSIGNED_DIAGNOSTICS_PROC.Ownership_transfer_diagnostics
   (p_error_record_id => NULL );

  INV_CONSIGNED_DIAGNOSTICS_PROC.Consumption_Advice_diagnostics
 (p_error_record_id => NULL);


  INV_CONSIGNED_DIAGNOSTICS_PROC.Purge_diagnostics_passed_rec ;
  INV_CONSIGNED_DIAGNOSTICS_PROC.Update_Consumption_Date ;

  COMMIT;

  IF g_debug = 1
  THEN
    INV_LOG_UTIL.trace
    ( 'Completed the conc program diagnostics ' ,
         'INV_CONSIGNED_DIAGNOSTICS_PROC' , 9);
   INV_LOG_UTIL.trace
   ( 'p_send_notification => '|| p_send_notification ,
         'INV_CONSIGNED_DIAGNOSTICS_PROC' , 9);

   INV_LOG_UTIL.trace
   ( 'p_notification_resend_days => '|| p_notification_resend_days ,
         'INV_CONSIGNED_DIAGNOSTICS_PROC' , 9);
  END IF;

  IF TO_NUMBER(p_send_notification)   = 1
  THEN
    INV_CONSIGN_NOTIF_UTL.Send_Notification
    ( p_api_version        => 1.0
    , p_init_msg_list      => FND_API.G_FALSE
    , p_commit             => FND_API.G_TRUE
    , x_return_status      => l_return_status
    , x_msg_count          => l_msg_count
    , x_msg_data           => l_msg_data
    , p_notification_resend_days =>
            NVL(p_notification_resend_days ,0)
    );

    IF g_debug = 1
    THEN
      INV_LOG_UTIL.trace
      ( 'Completed the Notification process' ,
         'INV_CONSIGNED_DIAGNOSTICS_PROC' , 9);

      INV_LOG_UTIL.trace
      ( 'l_return_status => '|| l_return_status ,
         'INV_CONSIGNED_DIAGNOSTICS_PROC' , 9);

      INV_LOG_UTIL.trace
      ( 'x_msg_count => '|| l_msg_count  ,
         'INV_CONSIGNED_DIAGNOSTICS_PROC' , 9);

      INV_LOG_UTIL.trace( 'Error=> '||
         substrb(FND_MSG_PUB.Get(p_encoded =>
           FND_API.G_FALSE),1,500),
      9 );
    END IF;
  END IF;

  IF g_debug = 1
  THEN
   INV_LOG_UTIL.trace
   ( '<< INVRCIDB: OUT Consigned_diagnostics',
         'INV_CONSIGNED_DIAGNOSTICS_PROC'  ,9);

  END IF;


EXCEPTION

  WHEN OTHERS THEN
   INV_LOG_UTIL.trace
    ( 'SQLERRM: '|| SQLERRM,9 );

   INV_LOG_UTIL.trace
    ( 'Error in Consigned_diagnostics' ,'INVRCIDB', 9);

  INV_LOG_UTIL.trace( 'Error=> '||
         substrb(FND_MSG_PUB.Get(p_encoded =>
           FND_API.G_FALSE),1,500),9 );

   rollback;

RAISE ;

END Consigned_diagnostics ;

END INV_CONSIGNED_DIAGNOSTICS_PROC ;

/
