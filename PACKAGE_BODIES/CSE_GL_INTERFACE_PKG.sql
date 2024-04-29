--------------------------------------------------------
--  DDL for Package Body CSE_GL_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_GL_INTERFACE_PKG" AS
-- $Header: CSEGLINB.pls 120.15.12010000.2 2009/04/17 17:22:31 dsingire ship $

-------------------------------------------------------------------------------------
--  Following procedure derives:
--  If GL A/c entires needs to be reversed for this MTL transaction if
--  there are any FA Items in Inventory
-------------------------------------------------------------------------------------

PROCEDURE debug( p_message_text   IN VARCHAR2) IS
BEGIN
   cse_debug_pub.add( p_message_text );
EXCEPTION
  WHEN OTHERS THEN
       NULL;
END debug;

PROCEDURE get_gl_interface_code(
             p_mtl_txn_id        IN NUMBER
            ,p_csi_txn_id        IN NUMBER
            ,x_gl_interface_code OUT NOCOPY NUMBER
            ,x_return_status     OUT NOCOPY VARCHAR2
            ,x_error_message     OUT NOCOPY VARCHAR2)
IS
l_depreciate_flag                VARCHAR2(1) ;
l_inv_item_id                    NUMBER ;
l_eam_item_type                  NUMBER ;
l_srl_flag                       VARCHAR2(1);
l_entity_code                    VARCHAR2(100) ;
l_application_id                 NUMBER ; --CST;
l_need_to_post                   VARCHAR2(1);
l_return_status                  VARCHAR2(1);
l_error_message                  VARCHAR2(500);
l_serial_num_control_cd          NUMBER;
l_trf_txn_id                     NUMBER ;

CURSOR mtl_cur IS
SELECT mmt.inventory_item_id
      ,msi.eam_item_type
      ,DECODE(msi.asset_creation_code,'1', 'Y','Y','Y','N') depreciate_flag
      ,serial_number_control_code
      ,decode(mmt.transaction_action_id ,
              '2' , mmt.transfer_transaction_id ,
              '3' , mmt.transfer_transaction_id ,
              '28', mmt.transfer_transaction_id , mmt.transaction_id ) trf_txn_id
FROM   mtl_material_transactions mmt
      ,mtl_system_items msi
WHERE  mmt.transaction_id    = p_mtl_txn_id
AND    mmt.inventory_item_id = msi.inventory_item_id
AND    mmt.organization_id   = msi.organization_id ;

-- Assets expired as of txn date or less would not be reversed
Cursor mtl_srl_cur IS
SELECT 'Y'
FROM   mtl_unit_transactions mut
      ,csi_item_instances cii
      ,csi_i_assets cia
      ,csi_transactions ct
WHERE  mut.transaction_id    = p_mtl_txn_id
AND    cii.inventory_item_id = mut.inventory_item_id
AND    cii.instance_id       = cia.instance_id
AND    ct.transaction_id     = p_csi_txn_id
AND    cia.creation_date    <= ct.transaction_date
AND    nvl(cia.active_end_date, ct.transaction_date + 1) >=  ct.transaction_date ;

-- Assumption , If primary ledger is NT (non transferable) then
-- all secondary ledgers are NT and shld be marked with
-- gl_interface_code 3

CURSOR  need_to_post_cur (c_mtl_transaction_id IN NUMBER
                         ,c_gl_transfer_status_code IN VARCHAR2)
IS
SELECT  'N' --no need to post to gl
FROM    xla_transaction_entities xlte,
        xla_ae_headers xlaeh
WHERE   nvl(xlte.source_id_int_1 , '-99') =  c_mtl_transaction_id
AND     xlte.entity_code      		  =  'MTL_ACCOUNTING_EVENTS'
AND     xlte.application_id  		  =  707
and     xlte.ledger_id in (select distinct caiv.ledger_id
                           from   cst_acct_info_v caiv, mtl_transaction_accounts mta
                           where  mta.transaction_id  = c_mtl_transaction_id
                           and    mta.organization_id = caiv.organization_id )
AND   	xlaeh.entity_id       		  =  xlte.entity_id
AND   	xlaeh.gl_transfer_status_code 	  = 'NT' ;


BEGIN
 --Init to No need to interface to GL

 x_gl_interface_code 	:=  3 ; ---None
 l_srl_flag 		:= 'N' ;
 l_entity_code 		:= 'MTL_ACCOUNTING_EVENTS';
 l_application_id  	:=  707;
 l_need_to_post 	:= 'Y' ;

-- Setting the application context to CST Costing.
  xla_security_pkg.set_security_context(p_application_id => l_application_id );

 OPEN  mtl_cur ;
 FETCH mtl_cur INTO l_inv_item_id , l_eam_item_type, l_depreciate_flag,
                    l_serial_num_control_cd , l_trf_txn_id;
 CLOSE mtl_cur ;

 IF l_depreciate_flag = 'Y' OR l_eam_item_type = 1
 THEN
    x_gl_interface_code := 1 ; ---Pending

-- NT is upgraded data from MTA from prior release before R12
-- In prior release we had IB cost hook so we need not wory abt 'NT' data

    OPEN  need_to_post_cur (p_mtl_txn_id , 'NT');
    FETCH need_to_post_cur INTO l_need_to_post ;
    CLOSE need_to_post_cur ;

-- For sub trf , direct org and staging trf , if rcv side is NT then
-- sending is NT .

    IF    l_need_to_post = 'Y'
    THEN
--      For subtrf , receipt is not in xla table
        If (p_mtl_txn_id <> l_trf_txn_id)  THEN
           OPEN  need_to_post_cur (l_trf_txn_id , 'NT');
    	   FETCH need_to_post_cur INTO l_need_to_post ;
           CLOSE need_to_post_cur ;
        END IF;
    END IF ;

    IF  l_need_to_post = 'N'
    THEN
--      upgrade data
        x_gl_interface_code := 3 ;
    END if ;

 ELSE
-- MUT record only for serialized item
   OPEN  mtl_srl_cur ;
   FETCH mtl_srl_cur INTO l_srl_flag ;
   CLOSE mtl_srl_cur ;

   IF l_srl_flag = 'N'
   THEN
--    non srl ,non depreciable,  regular item OR no active CIA
      x_gl_interface_code := 3 ; --None , no need to interface to GL
   ELSE
--    srl , regular item with ATLEAST one active CIA  record  ias of txn dt
      x_gl_interface_code := 1 ; ---Pending

      OPEN  need_to_post_cur (p_mtl_txn_id, 'NT') ;
      FETCH need_to_post_cur INTO l_need_to_post ;
      CLOSE need_to_post_cur ;

      IF    l_need_to_post = 'Y'
      THEN
--      For subtrf , receipt is not in xla table
        If p_mtl_txn_id <> l_trf_txn_id THEN
           OPEN  need_to_post_cur (l_trf_txn_id , 'NT');
    	   FETCH need_to_post_cur INTO l_need_to_post ;
           CLOSE need_to_post_cur ;
        END IF;
      END IF ;

      IF l_need_to_post = 'N'
      THEN
         x_gl_interface_code := 3 ;
      END IF ;

   END IF ; --l_srl_flag = 'N'
 END IF ; ---l_depreciate_flag = 'Y'

EXCEPTION
     WHEN OTHERS
     THEN
          CSE_UTIL_PKG.write_log('Error in GET_GL_INTERF_CD : ' ||  SQLERRM);
END get_gl_interface_code ;

PROCEDURE CREATE_GL_ENTRIES (
   x_return_status                           OUT NOCOPY VARCHAR2,
   x_error_msg                     	     OUT NOCOPY VARCHAR2,
   p_conc_request_id                         IN  NUMBER )
IS
l_entity_code                                VARCHAR2(100) ;
l_application_id                             NUMBER ; -- CST;
l_cii_inventory_item_id                      NUMBER ;
l_depreciable                                VARCHAR2(1);
l_reversal_required                          BOOLEAN ;
l_txn_type                                   VARCHAR2(100);
l_transaction_type_id                        NUMBER ;
l_gl_interface_code                          NUMBER ;
l_gl_interface_tbl                           cse_gl_interface_pkg.gl_interface_tbl;
l_total_txn_qty                              NUMBER ;
l_no_of_fa_items                             NUMBER ;
l_gl_ccid                                    NUMBER ;
l_gl_amount_cr                               NUMBER ;
l_gl_amount_dr                               NUMBER ;
l_gl_amount_entered_cr                       NUMBER ;
l_gl_amount_entered_dr                       NUMBER ;
l_category_name                              VARCHAR2(30) ;
l_return_status                              VARCHAR2(1) ;
l_error_message                              VARCHAR2(2000) ;
l_asset_attrib_rec                           CSE_DATASTRUCTURES_PUB.asset_attrib_rec;
l_gl_group_id                                NUMBER ;
l_mmt_inventory_item_id                      NUMBER ;
l_mta_gl_sl_link_id                          NUMBER ;
l_mta_ussgl_transaction_code                 VARCHAR2(30) ;
l_mta_encumbrance_type_id                    NUMBER;
l_mta_actual_flag                            VARCHAR2(1) ;
l_mta_organization_id                        NUMBER;
l_mmt_transaction_date                       DATE ;
l_ciih_old_quantity                          NUMBER ;
l_ciih_new_quantity                          NUMBER ;
l_redeploy_qty                               NUMBER;
l_expired_qty                                NUMBER;
l_stmt_id                                    NUMBER ;
--l_gl_transfer_status_code                  VARCHAR2(30);
gl_idx                                       PLS_INTEGER;
i                                            NUMBER ;
e_error                                      EXCEPTION ;
e_redeploy_error                             EXCEPTION ;
l_fnd_success                                VARCHAR2(1);
l_fnd_error                                  VARCHAR2(1);
l_accounting_entry_status_code               VARCHAR2(30) ;
l_debug                                      VARCHAR2(1);
l_file                                       VARCHAR2(500);
l_sysdate                                    DATE ;
l_gl_insrt_success                           BOOLEAN;
l_redeploy_flag                  	     VARCHAR(1);
l_serial_num_control_cd                      NUMBER;
l_srl_flag                                   VARCHAR2(1);
l_trf_txn_id                     	     NUMBER ;
l_mmt_txn_action_id                          NUMBER ;
l_mmt_txn_id                     	     NUMBER ;

CURSOR csi_gl_interface_code_cur
IS
SELECT ct.transaction_id,
       ct.transaction_date,
       ct.inv_material_transaction_id ,
       ct.gl_interface_status_code
FROM   csi_transactions ct
WHERE  ct.gl_interface_status_code       = 1  --'PENDING'
AND    ct.transaction_status_code        = 'COMPLETE'  ; --only those txn, which are already interfaced to FA

-- nvl on gl_interf_status_cd not reqd as t wld have a value when the below cur is opened
CURSOR csi_pending_txn_cur
IS
SELECT ct.inv_material_transaction_id,
       ct.transaction_type_id,
       ct.transaction_id
FROM   csi_transactions ct
WHERE  ct.gl_interface_status_code       = 1  ---'PENDING'
AND    ct.transaction_status_code        = 'COMPLETE' ;

-- Cursor will be used to get redeployment status of nonexpired assets

CURSOR csi_srl_cur(c_csi_transaction_id  IN NUMBER)
IS
SELECT citd.serial_number,
       citd.inventory_item_id ,
       citd.transaction_date
FROM   csi_inst_txn_details_v citd
      ,csi_i_assets cia
WHERE  citd.transaction_id      = c_csi_transaction_id
AND    citd.instance_id         = cia.instance_id
AND    cia.creation_date       <= citd.transaction_date
AND    nvl(cia.active_end_date, citd.transaction_date + 1) >  citd.transaction_date ;

-- l_csi_srl_rec                    csi_srl_cur%ROWTYPE;

/*
CURSOR c_expired_cia_cur IS
SELECT 'N'
FROM   csi_inst_txn_details_v csitd
      ,csi_i_assets cia
WHERE  csitd.transaction_id = csi_pending_txn_rec.transaction_id
AND    csitd.instance_id    = cia.instance_id
AND    nvl(cia.active_end_date, sysdate) <= sysdate ;
*/

-- Added performance issue
-- Before opening cursor , we have flipped txn with trf_txn_id for staging/sub trf
CURSOR  cst_acct_info_cur(c_mtl_transaction_id  IN NUMBER ,
                          c_trf_txn_id          IN NUMBER )
IS
SELECT  distinct caiv.ledger_id , mmt.transaction_id
FROM    cst_acct_info_v  caiv,
        mtl_transaction_accounts mta,
        mtl_material_transactions mmt
WHERE   mta.transaction_id  = c_mtl_transaction_id
AND     mta.organization_id = caiv.organization_id
AND     mmt.transaction_id  = c_mtl_transaction_id
AND     mmt.transaction_action_id <> 3
UNION
SELECT  distinct caiv.ledger_id , mmt.transaction_id
FROM    cst_acct_info_v  caiv,
        mtl_transaction_accounts mta ,
        mtl_material_transactions mmt
WHERE   mta.transaction_id  in ( c_mtl_transaction_id , c_trf_txn_id )
AND     mta.organization_id = caiv.organization_id
AND     mmt.transaction_id  in ( c_mtl_transaction_id , c_trf_txn_id )
AND     mmt.transaction_action_id = 3 ;

CURSOR category_name_cur
IS
SELECT user_je_category_name
FROM   gl_je_categories
WHERE  je_category_name                 = 'MTL';

/*
CURSOR xla_lookup_cur
IS
SELECT lookup_code
FROM   fnd_lookups
WHERE  lookup_type         = 'XLA_ACCOUNTING_CLASS'
AND    meaning             = 'INVENTORY VALUATION';
*/

-- ledger_id join ion xlte is only for performance reason.
-- xlte is only created for primary ledger but
-- We need to reverse all ledger's in xla_ae_headers
-- in final mode .

CURSOR  xla_header_cur( c_ledger_id           IN NUMBER
                      , c_mtl_transaction_id  IN NUMBER)
IS
SELECT  xlaeh.ledger_id,
        xlaeh.je_category_name,
        xlaeh.ae_header_id,
        xlaeh.application_id,
        xlte.source_id_int_1,
        xlte.source_id_int_2
FROM    xla_transaction_entities xlte,
        xla_ae_headers xlaeh
WHERE   xlte.application_id            	=  707
AND     xlte.entity_code                =  'MTL_ACCOUNTING_EVENTS'
AND     xlte.ledger_id                  =  c_ledger_id
AND     nvl(xlte.source_id_int_1, '-99') = c_mtl_transaction_id
AND     xlte.application_id             =  xlaeh.application_id
AND     xlte.entity_id                  =  xlaeh.entity_id
AND     xlaeh.accounting_entry_status_code = 'F' ;

CURSOR  xla_ae_lines_cur( c_application_id IN NUMBER,
                          c_header_id      IN NUMBER)
IS
SELECT  xlael.code_combination_id ,
        xlael.accounted_dr         tot_accounted_dr,
        xlael.accounted_cr         tot_accounted_cr,
        xlael.entered_dr           tot_entered_dr,
        xlael.entered_cr           tot_entered_cr,
        xlael.currency_code ,
        xlael.accounting_class_code
FROM    xla_ae_lines xlael
WHERE   xlael.application_id      	= c_application_id
AND     xlael.ae_header_id              = c_header_id ;
-- AND  xlael.accounting_class_code     = 'INVENTORY_VALUATION'
--GROUP BY xlael.accounting_class_code , xlael.code_combination_id, xlael.currency_code ;

BEGIN

  --Initialize local variables
  l_entity_code                   := 'MTL_ACCOUNTING_EVENTS';
  l_application_id                := 707;
  l_cii_inventory_item_id         := 0;
--l_gl_transfer_status_code       := 'Y';
  l_reversal_required             := FALSE;
  l_total_txn_qty                 := 0;
  l_gl_ccid                       := NULL;
  l_gl_amount_cr                  := 0;
  l_gl_amount_dr                  := 0;
  l_gl_amount_entered_cr          := 0;
  l_gl_amount_entered_dr          := 0;
  l_stmt_id                       := 0;
  i                               := 1;
  gl_idx                          := 1;
  l_fnd_success                   := fnd_api.g_ret_sts_success ;
  l_fnd_error                     := fnd_api.g_ret_sts_error ;
  x_return_status                 := l_fnd_success ;

--  Setting the application context to CST Costing.
  xla_security_pkg.set_security_context(p_application_id => l_application_id );

  l_debug := NVL(fnd_profile.value('CSE_DEBUG_OPTION'),'N');

  SELECT SYSDATE INTO l_sysdate FROM DUAL ;

  BEGIN
--  IF (l_debug = 'Y') THEN
     cse_debug_pub.g_dir  := nvl(FND_PROFILE.VALUE('CSE_DEBUG_LOG_DIRECTORY'), '/tmp');
     cse_debug_pub.g_file := NULL;
     l_file               := cse_debug_pub.set_debug_file('cse' || to_char(sysdate, 'DD-MON-YYYY') || '.log');
     cse_debug_pub.debug_on;
     debug('************************************************************');
     debug(' CSEGLINB : Start date : '||to_char(sysdate,'dd-mon-yyyy hh24:mi:ss')
                           ||' Request id : '||fnd_global.conc_request_ID);
--  END IF;
  EXCEPTION
    WHEN OTHERS THEN
    NULL;
  END;

  FOR   CSI_GL_INTERFACE_CODE_REC in CSI_GL_INTERFACE_CODE_CUR
  LOOP
        IF (l_debug = 'Y')
        THEN
            debug('Before Util Pkg CSI_TXN_ID: '
                        || to_char(csi_gl_interface_code_rec.transaction_id)
                        || ' CSI_MMT_TXN_ID: '
                        || to_char(csi_gl_interface_code_rec.inv_material_transaction_id)
                        || ' GL_INTERF_CD: ' || to_char(csi_gl_interface_code_rec.gl_interface_status_code)
                 );
        END IF;
--
        get_gl_interface_code (
               p_mtl_txn_id        => csi_gl_interface_code_rec.inv_material_transaction_id,
	       p_csi_txn_id        => csi_gl_interface_code_rec.transaction_id,
               x_gl_interface_code => l_gl_interface_code,
               x_return_status     => l_return_status,
               x_error_message     => l_error_message);

        IF l_return_status <> fnd_api.g_ret_sts_success
        THEN
           RAISE	e_error ;
        END IF ;

        IF (l_debug = 'Y')
        THEN
            debug('After Util Pkg CSI_TXN_ID: '
                            || to_char(csi_gl_interface_code_rec.transaction_id)
                            || ' CSI_MMT_TXN_ID: '
                            || to_char(csi_gl_interface_code_rec.inv_material_transaction_id)
                            || ' GL_INTERF_CD: ' || to_char(l_gl_interface_code)
                  ) ;
        END IF;

        UPDATE csi_transactions
        SET    gl_interface_status_code      =	l_gl_interface_code
        WHERE  transaction_id                =  csi_gl_interface_code_rec.transaction_id;

  END LOOP; --csi_gl_interface_code_rec

  OPEN   CATEGORY_NAME_CUR;
  FETCH  category_name_cur INTO l_category_name; --cursor to get je category name
  CLOSE  CATEGORY_NAME_CUR;

  IF (l_debug = 'Y')
  THEN
    debug('Before Csi_Pending_Txn_Cur') ;
  END IF;

  FOR CSI_PENDING_TXN_REC IN CSI_PENDING_TXN_CUR
  LOOP
        BEGIN
          SELECT  mmt.inventory_item_id , mmt.transaction_date ,
                  msi.serial_number_control_code ,
                  DECODE(msi.asset_creation_code,'1', 'Y','Y','Y','N'),
                  DECODE(mmt.transaction_action_id ,
              		'2' , mmt.transfer_transaction_id ,
              		'3' , mmt.transfer_transaction_id ,
              		'28', mmt.transfer_transaction_id , mmt.transaction_id ),
                  transaction_action_id,
                  transaction_id
          INTO    l_mmt_inventory_item_id , l_mmt_transaction_date ,
                  l_serial_num_control_cd ,
                  l_depreciable ,
                  l_trf_txn_id ,
                  l_mmt_txn_action_id ,
                  l_mmt_txn_id
          FROM    mtl_material_transactions mmt , mtl_system_items msi
          WHERE   mmt.transaction_id    = csi_pending_txn_rec.inv_material_transaction_id
            AND   mmt.inventory_item_id = msi.inventory_item_id
            AND   mmt.organization_id   = msi.organization_id ;

	  IF (l_debug = 'Y')
          THEN
               debug('Inside Csi_Pending_Txn_Cur CSI_MMT_TXN_ID: '
                         || to_char(csi_pending_txn_rec.inv_material_transaction_id)
                         || ' MMT_TRF_TXN_ID: ' || to_char(l_trf_txn_id)
                         || ' MMT_TXN_ACTN_ID: '    || to_char(l_mmt_txn_action_id)
                    ) ;
          END IF;

-- We use below st. to get txn qty , issues if qty is read qty from MMT
-- Do we need any date chk for expired here ??

          SELECT sum(nvl(ciih.old_quantity, 0) ),
                 sum(nvl(ciih.new_quantity ,0) ),
                 cii.inventory_item_id
          INTO
                 l_ciih_old_quantity ,
                 l_ciih_new_quantity ,
                 l_cii_inventory_item_id
          FROM   csi_item_instances_h ciih ,
                 csi_item_instances  cii
          WHERE  ciih.transaction_id      = csi_pending_txn_rec.transaction_id
          AND    ciih.instance_id         = cii.instance_id
          AND    cii.inventory_item_id    = l_mmt_inventory_item_id
          GROUP  BY cii.inventory_item_id , ciih.transaction_id  ;

          l_total_txn_qty:= ABS(l_ciih_old_quantity - l_ciih_new_quantity );

          If  l_total_txn_qty  = 0 then
              l_total_txn_qty := 1;
          END IF;

--        CSE_UTIL_PKG.CHECK_DEPRECIABLE(     p_inventory_item_id => l_cii_inventory_item_id,
--                                            p_depreciable       => l_depreciable );

--        IF (l_debug = 'Y')
--        THEN
               debug(' Item Id     : '  ||to_char(l_cii_inventory_item_id) ||
                     ' Depreciable : '  ||l_depreciable ||
                     ' Tot Txn Qty   : ' ||to_char(l_total_txn_qty) ) ;
--        END IF;

          l_redeploy_qty := 0 ;
          IF  l_depreciable  = 'Y' -- Item is depreciable
          THEN

-- ??? We can be here only for deprec srl/non srl or regular srl items as we do
--     not reverse regular non-srl

 	    IF l_serial_num_control_cd IN (2,5) THEN
 -- 		   l_srl_flag     := 'Y';
 --  for redeploy , already cursor csi_srl_rec filters for expired CIA
    		   FOR  csi_srl_rec in csi_srl_cur(csi_pending_txn_rec.transaction_id)
                   LOOP
    		       cse_util_pkg.get_redeploy_flag (
              		 p_inventory_item_id  => csi_srl_rec.inventory_item_id
             		,p_serial_number      => csi_srl_rec.serial_number
             		,p_transaction_date   => csi_srl_rec.transaction_date
             		,x_redeploy_flag      => l_redeploy_flag
             		,x_return_status      => l_return_status
             		,x_error_message      => l_error_message);

           		IF     l_return_status <> fnd_api.g_ret_sts_success
           		THEN
               		RAISE  e_redeploy_error ;
           		END IF ;

                        If l_redeploy_flag = 'Y' THEN
                           l_redeploy_qty  := l_redeploy_qty + 1 ;
                        End If ;
                   END LOOP ;
 	    END IF;

            l_expired_qty := 0 ;

 -- get tot expired qty before the current txn date , note the <
	   SELECT  sum(nvl(cia.asset_quantity, 0)) into l_expired_qty
	     FROM  csi_inst_txn_details_v citd
      		  ,csi_i_assets cia
	    WHERE  citd.transaction_id      = csi_pending_txn_rec.transaction_id
              AND  citd.instance_id         = cia.instance_id
              AND  cia.creation_date       <= citd.transaction_date
              AND  nvl(cia.active_end_date, citd.transaction_date+ 1) <  citd.transaction_date ;

--          Any asset creating txn other than a redeploy part of it  shld be reversed
--          For redeploy , asset has been created previously , so reverse
            l_no_of_fa_items     := 0 ;
            IF  csi_pending_txn_rec.transaction_type_id IN (105,112,117,128,129)
              --105 : 'PO_RECEIPT_INTO_PROJECT' -- Not possible as no associated Inv txn
              --112 : 'PO_RECEIPT_INTO_INVENTORY'
              --117 : 'MISC_RECEIPT'
              --128 : 'ACCT_RECEIPT'
              --129 : 'ACCT_ALIAS_RECEIPT'
            THEN
                If l_redeploy_qty 	= 0 then
                   l_reversal_required  := FALSE;
                   l_no_of_fa_items     := 0 ; -- adding so below if does not fail
                                               -- rev_rqd OR # of fa_items
                Else
                   l_no_of_fa_items     := l_redeploy_qty ;
                   l_reversal_required  := TRUE;
                End if ;
            ELSE
              -- for depr itm, all txns other than above list
                l_no_of_fa_items     := nvl(l_total_txn_qty ,0)  - nvl(l_expired_qty , 0);
                If l_no_of_fa_items 	= 0 then
                   l_reversal_required  := FALSE;
                Else
                   l_reversal_required  := TRUE;
                End if;
            END IF ; -- txn_type_id in condn
          END IF ; --l_depreciable='Y'

--        below for regular srl items ONLY
--        Get the number of FA Items for normal items in inventory
          IF l_depreciable = 'N'
          THEN
--          active_end_date can't be future dated , chk for performance
--          # of active assets at the time of txn date
	     SELECT  sum(cia.asset_quantity)
               INTO  l_no_of_fa_items
	       FROM  csi_inst_txn_details_v citd
      		    ,csi_i_assets cia
	      WHERE  citd.transaction_id      = csi_pending_txn_rec.transaction_id
              AND    citd.instance_id         = cia.instance_id
              --AND    cia.creation_date        <= citd.transaction_date  --Commented for bug 8435411
              AND    nvl(cia.active_end_date, citd.transaction_date+ 1) >=  citd.transaction_date ;
/*
             SELECT   sum(cia.asset_quantity)
             INTO     l_no_of_fa_items
             FROM     csi_item_instances cii,
                      csi_transactions ct ,
                      csi_item_instances_h ciih ,
                      csi_i_assets cia
             WHERE    cii.instance_id   = ciih.instance_id
             AND      ct.transaction_id = ciih.transaction_id
             AND      ct.transaction_id = csi_pending_txn_rec.transaction_id
             AND      cia.instance_id   = cii.instance_id
             AND      cia.creation_date < ct.transaction_date
             AND      cia.active_end_date is null ;
*/
          END IF ; --l_depreciable='N'

          debug ( ' Redeploy Qty: '   || to_char(l_redeploy_qty) ||
                  '       Expired  Qty: '   || to_char(nvl(l_expired_qty, 0))  ||
                  ' Num_Of_FA_Itms: ' || to_char(l_no_of_fa_items)
                ) ;

          IF l_reversal_required OR NVL(l_no_of_fa_items,0) > 0
          THEN
--
           l_gl_insrt_success := FALSE;

           IF    l_mmt_txn_action_id in (2  , 28)
           THEN
                 l_mmt_txn_id := l_trf_txn_id ;
           END IF ;

           IF (l_debug = 'Y')
           THEN
              debug('Before Cst_Acct_Info_Cur' ) ;
           END IF;

           FOR  cst_acct_info_rec IN cst_acct_info_cur( l_mmt_txn_id  , l_trf_txn_id)
           LOOP
                IF (l_debug = 'Y')
                THEN
                    debug('Before Xla_Header_Cur'
                               || ' CST_LEDG_ID: '     || to_char(cst_acct_info_rec.ledger_id)
                               || '  CST_MMT_TXN_ID: ' || to_char(cst_acct_info_rec.transaction_id) );
                END IF;
--
                FOR xla_header_rec IN xla_header_cur(  cst_acct_info_rec.ledger_id
                                                     , cst_acct_info_rec.transaction_id )
                LOOP
--
                 IF (l_debug = 'Y')
                 THEN
                    debug('Inside Xla_Header_Cur'
                               || ' XLA_ORG_ID: '     || to_char(xla_header_rec.source_id_int_2)
                               || ' XLA_MMT_TXN_ID: ' || to_char(xla_header_rec.source_id_int_1) ) ;
                 END IF;

                 SELECT
                      mta.gl_sl_link_id,
                      mta.ussgl_transaction_code,
                      mta.encumbrance_type_id,
                      mta.organization_id,
                      DECODE(mta.encumbrance_type_id, NULL, 'A', 'E')
                 INTO
                      l_mta_gl_sl_link_id,
                      l_mta_ussgl_transaction_code,
                      l_mta_encumbrance_type_id,
                      l_mta_organization_id,
                      l_mta_actual_flag
                 FROM
                      mtl_transaction_accounts mta
                 WHERE
                      mta.transaction_id  = xla_header_rec.source_id_int_1
                 AND  mta.organization_id = xla_header_rec.source_id_int_2
                 AND  rownum  = 1 ;

                 IF  i = 1
                 THEN
                     SELECT GL_INTERFACE_CONTROL_S.NEXTVAL INTO l_gl_group_id FROM DUAL ;
                 END IF ;


                 IF (l_debug = 'Y')
                 THEN
                    debug('Before Xla_Ae_Lines_Cur'
                                       || ' XLA_APPN_ID: ' || to_char(xla_header_rec.application_id)
                                       || ' XLA_HDR_ID: ' || to_char(xla_header_rec.ae_header_id)
                         ) ;
                 END IF;

               FOR xla_ae_lines_rec IN  xla_ae_lines_cur (
                        xla_header_rec.application_id ,
                        xla_header_rec.ae_header_id )
               LOOP
                   l_gl_ccid                      := NULL;
                   l_gl_amount_cr                 := 0;
                   l_gl_amount_dr                 := 0;
                   l_gl_amount_entered_cr         := 0;
                   l_gl_amount_entered_dr         := 0;

--                    IF (l_debug = 'Y')
--                    THEN
                        debug( 'Inside Xla_Ae_Lines_Cur '
                        || '  Gl_Idx: '   || to_char(gl_idx)
                        || '  I: '        || to_char(i) ) ;
--                    END IF;

                    IF  xla_ae_lines_rec.tot_accounted_dr > 0
                    THEN
                        l_gl_ccid        := xla_ae_lines_rec.code_combination_id;
                        l_gl_amount_cr   := (xla_ae_lines_rec.tot_accounted_dr/l_total_txn_qty) * l_no_of_fa_items;
                        l_gl_amount_entered_cr := (xla_ae_lines_rec.tot_entered_dr/l_total_txn_qty) * l_no_of_fa_items;
--
--                        IF (l_debug = 'Y')
--                        THEN
                             debug('  Credit Gl_Ccid :' || to_char(l_gl_ccid)
                                      || '  Amt: ' || to_char(l_gl_amount_cr)
                                      || '  Ent_Amt: ' || to_char(l_gl_amount_entered_cr) );
--                        END IF;

                    ELSIF xla_ae_lines_rec.tot_accounted_cr > 0
                    THEN
                        l_gl_ccid        := xla_ae_lines_rec.code_combination_id;
                        l_gl_amount_dr   := (xla_ae_lines_rec.tot_accounted_cr/l_total_txn_qty) * l_no_of_fa_items;
                        l_gl_amount_entered_dr := (xla_ae_lines_rec.tot_entered_cr/l_total_txn_qty)   * l_no_of_fa_items;
--
--                        IF (l_debug = 'Y')
--                        THEN
                            debug('  Debit Gl_Ccid: ' || to_char(l_gl_ccid)
                                    || '  Amt: ' || to_char(l_gl_amount_dr)
                                    || '  Ent_Amt: ' || to_char(l_gl_amount_entered_dr) );
--                        END IF;
                    END IF;

--                   IF (l_debug = 'Y')
--                   THEN
                    debug('  Currency: '   || xla_ae_lines_rec.currency_code ||
                          '  Actual: '     || l_mta_actual_flag ||
                          '  Encum_Type_Id: ' || l_mta_encumbrance_type_id ||
                          '  Category: '   || l_category_name   ||
                          '  SOB: '        || to_char(xla_header_rec.ledger_id) ) ;
--                   END IF;


        -- Check if we need to pass xlael.accounting_class_code to gl_interface

          l_gl_interface_tbl(gl_idx).STATUS                := 'NEW';
          l_gl_interface_tbl(gl_idx).ACCOUNTING_DATE       :=  l_mmt_transaction_date;
          l_gl_interface_tbl(gl_idx).DATE_CREATED          :=  SYSDATE;
          l_gl_interface_tbl(gl_idx).CREATED_BY            :=  fnd_global.user_id ;
          l_gl_interface_tbl(gl_idx).ACTUAL_FLAG           :=  l_mta_actual_flag;
          l_gl_interface_tbl(gl_idx).USER_JE_CATEGORY_NAME :=  l_category_name  ;
          l_gl_interface_tbl(gl_idx).USER_JE_SOURCE_NAME   := 'Inventory'    ;
          l_gl_interface_tbl(gl_idx).ENCUMBRANCE_TYPE_ID   :=  l_mta_encumbrance_type_id;
          l_gl_interface_tbl(gl_idx).SET_OF_BOOKS_ID       :=  xla_header_rec.ledger_id;
          l_gl_interface_tbl(gl_idx).CODE_COMBINATION_ID   :=  l_gl_ccid;
          l_gl_interface_tbl(gl_idx).CURRENCY_CODE         :=  xla_ae_lines_rec.currency_code;
          l_gl_interface_tbl(gl_idx).ENTERED_DR            :=  l_gl_amount_entered_dr;
          l_gl_interface_tbl(gl_idx).ENTERED_CR            :=  l_gl_amount_entered_cr;
          l_gl_interface_tbl(gl_idx).ACCOUNTED_DR          :=  l_gl_amount_dr;
          l_gl_interface_tbl(gl_idx).ACCOUNTED_CR          :=  l_gl_amount_cr;
          l_gl_interface_tbl(gl_idx).TRANSACTION_DATE      :=  l_mmt_transaction_date;
          l_gl_interface_tbl(gl_idx).REFERENCE1            :=  'Oracle Asset Tracking Reversal' ;
          l_gl_interface_tbl(gl_idx).REFERENCE2            :=  NULL;--open issue
          l_gl_interface_tbl(gl_idx).REFERENCE5            :=  NULL;--open issue
          l_gl_interface_tbl(gl_idx).REFERENCE10           :=  NULL;--open issue
          l_gl_interface_tbl(gl_idx).REFERENCE22           :=  xla_header_rec.source_id_int_2;
          l_gl_interface_tbl(gl_idx).REFERENCE23           :=  xla_header_rec.source_id_int_1;
          l_gl_interface_tbl(gl_idx).USSGL_TRANSACTION_CODE := l_mta_ussgl_transaction_code;
          l_gl_interface_tbl(gl_idx).GROUP_ID              :=  l_gl_group_id ;
          l_gl_interface_tbl(gl_idx).GL_SL_LINK_ID         :=  l_mta_gl_sl_link_id ;
          l_gl_interface_tbl(gl_idx).GL_SL_LINK_TABlE      := 'MTA';
          l_gl_interface_tbl(gl_idx).request_id            :=  fnd_global.conc_request_ID ;

           IF (l_debug = 'Y')
           THEN
                 debug('Before Inserting Into Gl_Interface ' ) ;
           END IF;
                INSERT  INTO   GL_INTERFACE(
                            GROUP_ID,
                            STATUS,
                            SET_OF_BOOKS_ID,
                            USER_JE_SOURCE_NAME,
                            USER_JE_CATEGORY_NAME,
                            ACCOUNTING_DATE,
                            CURRENCY_CODE,
                            ACTUAL_FLAG,
                            ENCUMBRANCE_TYPE_ID,
                            DATE_CREATED,
                            CREATED_BY,
                            ENTERED_DR,
                            ENTERED_CR,
                            REFERENCE1,
                            REFERENCE2,
                            REFERENCE5,
                            REFERENCE10,
                            REFERENCE21,
                            REFERENCE22,
                            REFERENCE23,
                            CODE_COMBINATION_ID,
                            USSGL_TRANSACTION_CODE,
                            ACCOUNTED_DR,
                            ACCOUNTED_CR,
                            GL_SL_LINK_ID,
                            GL_SL_LINK_TABLE,
                            REQUEST_ID,
                            SEGMENT1,  SEGMENT2,   SEGMENT3,   SEGMENT4,   SEGMENT5,
                            SEGMENT6,  SEGMENT7,   SEGMENT8,   SEGMENT9,   SEGMENT10,
                            SEGMENT11, SEGMENT12,  SEGMENT13,  SEGMENT14,  SEGMENT15,
                            SEGMENT16, SEGMENT17,  SEGMENT18,  SEGMENT19,  SEGMENT20,
                            SEGMENT21, SEGMENT22,  SEGMENT23,  SEGMENT24,  SEGMENT25,
                            SEGMENT26, SEGMENT27,  SEGMENT28,  SEGMENT29,  SEGMENT30)
        VALUES (  l_gl_group_id
         ,DECODE( l_gl_interface_tbl(i).status ,
                                        FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).status )
         ,DECODE( l_gl_interface_tbl(i).set_of_books_id,
                                        FND_API.G_MISS_NUM,  NULL,  l_gl_interface_tbl(i).set_of_books_id)
         ,DECODE( l_gl_interface_tbl(i).user_je_source_name,
                                        FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).user_je_source_name)
         ,DECODE( l_gl_interface_tbl(i).user_je_category_name,
                                        FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).user_je_category_name)
         ,DECODE( l_gl_interface_tbl(i).accounting_date,
                                        FND_API.G_MISS_DATE, NULL, l_gl_interface_tbl(i).accounting_date)
         ,DECODE( l_gl_interface_tbl(i).currency_code ,
                                        FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).currency_code)
         ,DECODE( l_gl_interface_tbl(i).actual_flag   ,
                                        FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).actual_flag)
         ,DECODE( l_gl_interface_tbl(i).encumbrance_type_id ,
                                        FND_API.G_MISS_NUM,  NULL, l_gl_interface_tbl(i).encumbrance_type_id)
         ,DECODE( l_gl_interface_tbl(i).date_created,
                                        FND_API.G_MISS_DATE, NULL, l_gl_interface_tbl(i).date_created)
         ,DECODE( l_gl_interface_tbl(i).created_by  ,
                                        FND_API.G_MISS_NUM, NULL,  l_gl_interface_tbl(i).created_by)
         ,DECODE( l_gl_interface_tbl(i).entered_dr  ,
                                        FND_API.G_MISS_NUM, NULL,  l_gl_interface_tbl(i).entered_dr)
         ,DECODE( l_gl_interface_tbl(i).entered_cr  ,
                                        FND_API.G_MISS_NUM, NULL,  l_gl_interface_tbl(i).entered_cr)
         ,DECODE( l_gl_interface_tbl(i).reference1  ,
                                        FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).reference1)
         ,DECODE( l_gl_interface_tbl(i).reference2  ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).reference2)
         ,DECODE( l_gl_interface_tbl(i).reference5  ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).reference5)
         ,DECODE( l_gl_interface_tbl(i).reference10 ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).reference10)
         ,DECODE( l_gl_interface_tbl(i).reference21 ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).reference21)
         ,DECODE( l_gl_interface_tbl(i).reference22 ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).reference22)
         ,DECODE( l_gl_interface_tbl(i).reference23 ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).reference23)
         ,DECODE( l_gl_interface_tbl(i).code_combination_id ,
                                        FND_API.G_MISS_NUM, NULL, l_gl_interface_tbl(i).code_combination_id)
         ,DECODE( l_gl_interface_tbl(i).ussgl_transaction_code,
                                        FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).ussgl_transaction_code)
         ,DECODE( l_gl_interface_tbl(i).accounted_dr ,
					FND_API.G_MISS_NUM, NULL,  l_gl_interface_tbl(i).accounted_dr)
         ,DECODE( l_gl_interface_tbl(i).accounted_cr ,
					FND_API.G_MISS_NUM, NULL,  l_gl_interface_tbl(i).accounted_cr)
         ,DECODE( l_gl_interface_tbl(i).gl_sl_link_id ,
					FND_API.G_MISS_NUM, NULL,  l_gl_interface_tbl(i).gl_sl_link_id)
         ,DECODE( l_gl_interface_tbl(i).gl_sl_link_table,
                                        FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).gl_sl_link_table)
         ,DECODE( l_gl_interface_tbl(i).request_id ,
					FND_API.G_MISS_NUM, NULL, l_gl_interface_tbl(i).request_id)
         ,DECODE( l_gl_interface_tbl(i).segment1   ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).segment1 )
         ,DECODE( l_gl_interface_tbl(i).segment2   ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).segment2 )
         ,DECODE( l_gl_interface_tbl(i).segment3   ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).segment3 )
         ,DECODE( l_gl_interface_tbl(i).segment4   ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).segment4 )
         ,DECODE( l_gl_interface_tbl(i).segment5   ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).segment5 )
         ,DECODE( l_gl_interface_tbl(i).segment6   ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).segment6 )
         ,DECODE( l_gl_interface_tbl(i).segment7   ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).segment7 )
         ,DECODE( l_gl_interface_tbl(i).segment8   ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).segment8 )
         ,DECODE( l_gl_interface_tbl(i).segment9   ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).segment9 )
         ,DECODE( l_gl_interface_tbl(i).segment10  ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).segment10 )
         ,DECODE( l_gl_interface_tbl(i).segment11  ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).segment11 )
         ,DECODE( l_gl_interface_tbl(i).segment12  ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).segment12 )
         ,DECODE( l_gl_interface_tbl(i).segment13  ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).segment13 )
         ,DECODE( l_gl_interface_tbl(i).segment14  ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).segment14 )
         ,DECODE( l_gl_interface_tbl(i).segment15  ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).segment15 )
         ,DECODE( l_gl_interface_tbl(i).segment16  ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).segment16 )
         ,DECODE( l_gl_interface_tbl(i).segment17  ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).segment17 )
         ,DECODE( l_gl_interface_tbl(i).segment18  ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).segment18 )
         ,DECODE( l_gl_interface_tbl(i).segment19  ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).segment19 )
         ,DECODE( l_gl_interface_tbl(i).segment20  ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).segment20 )
         ,DECODE( l_gl_interface_tbl(i).segment21  ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).segment21 )
         ,DECODE( l_gl_interface_tbl(i).segment22  ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).segment22 )
         ,DECODE( l_gl_interface_tbl(i).segment23  ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).segment23 )
         ,DECODE( l_gl_interface_tbl(i).segment24  ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).segment24 )
         ,DECODE( l_gl_interface_tbl(i).segment25  ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).segment25 )
         ,DECODE( l_gl_interface_tbl(i).segment26  ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).segment26 )
         ,DECODE( l_gl_interface_tbl(i).segment27  ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).segment27 )
         ,DECODE( l_gl_interface_tbl(i).segment28  ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).segment28 )
         ,DECODE( l_gl_interface_tbl(i).segment29  ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).segment29 )
         ,DECODE( l_gl_interface_tbl(i).segment30  ,
					FND_API.G_MISS_CHAR, NULL, l_gl_interface_tbl(i).segment30 )
         ) ;

	 IF SQL%FOUND THEN
            l_gl_insrt_success := TRUE;
         END IF;
--
         gl_idx        :=  gl_idx + 1; --increment the gl index
         i             :=  i + 1;
--
        END LOOP;  --- xla_ae_lines_curser
      END LOOP;     --- xla_header_cur
     END LOOP;  --- cst_acct_info_cur

      IF  l_gl_insrt_success THEN
--
--      IF (l_debug = 'Y')
--      THEN
         debug('Before Upd Csi_Txn_Status To 2 for Csi_Mmt_Txn_Id: '
                                || to_char(csi_pending_txn_rec.inv_material_transaction_id) ) ;
--      END IF;
         UPDATE csi_transactions
         SET    gl_interface_status_code      = 2 ---'POSTED'
         WHERE  inv_material_transaction_id   = csi_pending_txn_rec.inv_material_transaction_id;
      END IF;
   ELSE
--
--       IF (l_debug = 'Y')
--       THEN
               debug('Before Upd Csi_Txn_Status To 3 for Csi_Mmt_Txn_Id: '
                                || to_char(csi_pending_txn_rec.inv_material_transaction_id) ) ;
--         END IF;

         UPDATE csi_transactions
            SET gl_interface_status_code    = 3 ---'NONE'
          WHERE inv_material_transaction_id = csi_pending_txn_rec.inv_material_transaction_id;
--
   END IF ; -- reversal_required or regular item with CIA
--
   EXCEPTION
-- This exception would catch no_data_found on MMT and other tables and skip
-- to next cursor record.
      WHEN no_data_found
      THEN
           CSE_UTIL_PKG.write_log('Error in CREATE_GL_ENTRIES CSI_TXN_ID: '
                         ||to_char(csi_pending_txn_rec.transaction_id)
                         || ' CSI_MMT_TXN_ID: '
                         || to_char(csi_pending_txn_rec.inv_material_transaction_id)
                         || l_error_message ) ;
      WHEN e_redeploy_error
      THEN
           CSE_UTIL_PKG.write_log('Error in CREATE_GL_ENTRIES Redeploy CSI_TXN_ID: '
                         || to_char(csi_pending_txn_rec.transaction_id)
                         || ' CSI_MMT_TXN_ID: '
                         || to_char(csi_pending_txn_rec.inv_material_transaction_id)
		         || l_error_message);
   End ;
END LOOP; --- csi_pending_txn_cur

debug(' End date : '||to_char(sysdate,'dd-mon-yyyy hh24:mi:ss'));
EXCEPTION
     WHEN e_error
     THEN
          CSE_UTIL_PKG.write_log('Error in CREATE_GL_ENTRIES :' || l_error_message);
     WHEN OTHERS
     THEN
          CSE_UTIL_PKG.write_log('Error in CREATE_GL_ENTRIES : ' ||  SQLERRM);
END CREATE_GL_ENTRIES ;

END CSE_GL_INTERFACE_PKG ;

/
