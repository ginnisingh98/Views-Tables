--------------------------------------------------------
--  DDL for Package Body CSE_ASSET_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_ASSET_UTIL_PKG" AS
/*  $Header: CSEFAUTB.pls 120.29.12010000.6 2010/03/30 13:43:38 dsingire ship $ */

  l_debug varchar2(1) := NVL(fnd_profile.value('cse_debug_option'),'N');

  PROCEDURE debug( p_message IN varchar2) IS
  BEGIN
    IF l_debug = 'Y' THEN
      cse_debug_pub.add(p_message);
      IF nvl(fnd_global.conc_request_id, -1) <> -1 THEN
        fnd_file.put_line(fnd_file.log, p_message);
      END IF;
    END IF;
  EXCEPTION
    WHEN others THEN
      null;
  END debug;

  FUNCTION primary_ledger_id(
    p_organization_id     IN number)
  RETURN number IS
    l_ledger_id           number;
  BEGIN
    SELECT ledger_id
    INTO   l_ledger_id
    FROM   cst_acct_info_v
    WHERE  organization_id = p_organization_id;

    RETURN l_ledger_id;
  END primary_ledger_id;


  FUNCTION get_item_cost (
    p_inventory_item_id   IN NUMBER,
    p_organization_id     IN NUMBER)
  RETURN number IS
    l_item_cost               number := NULL;
    l_inventory_asset_flag    varchar2(1);
  BEGIN

    SELECT nvl(inventory_asset_flag, 'N')
    INTO   l_inventory_asset_flag
    FROM   mtl_system_items_b
    WHERE  inventory_item_id = p_inventory_item_id
    AND    organization_id   = p_organization_id;

    IF l_inventory_asset_flag = 'N' THEN
      l_item_cost := 0;
    ELSE
      l_item_cost  := cst_cost_api.get_item_cost (
        p_api_version        => 1.0,
        p_inventory_item_id  => p_inventory_item_id,
        p_organization_id    => p_organization_id);
    END IF;

    RETURN l_item_cost;

  EXCEPTION
    WHEN others THEN
      RETURN null;
  END get_item_cost;


  FUNCTION asset_description(
    p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
    x_error_msg             OUT NOCOPY       VARCHAR2,
    x_return_status         OUT NOCOPY       VARCHAR2) RETURN VARCHAR2
  IS
    x_description      VARCHAR2(80);
    l_description      VARCHAR2(80);
    x_hook_used        PLS_INTEGER;
    i                  NUMBER := 0;
    e_error            EXCEPTION ;
    l_api_name VARCHAR2(100) := 'CSE_ASSET_UTIL_PKG.asset_description';

    -- For Non Serialized items, Asset description is not based on item as we may
    -- have asset for multiple items

    CURSOR asset_description_cur (c_org_id IN NUMBER,c_inv_item_id IN NUMBER) IS
      SELECT substr(msib.description,1,80)   asset_description
      FROM   mtl_system_items_b msib
      WHERE  msib.organization_id   = c_org_id
      AND    msib.inventory_item_id = c_inv_item_id  ;

  BEGIN
    x_return_status := fnd_api.G_RET_STS_SUCCESS ;
    i:= 0;
    cse_asset_client_ext_stub.get_asset_description( p_asset_attrib_rec, x_description, x_hook_used, x_error_msg);
    l_description := x_description ;

    IF x_hook_used = 1 THEN
       RETURN l_description ;
    ELSE
      OPEN  asset_description_cur( p_asset_attrib_rec.organization_id,p_asset_attrib_rec.inventory_item_id);
      FETCH asset_description_cur INTO l_description;
      CLOSE asset_description_cur;
    END IF;

    RETURN l_description ;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_message.set_name('CSE','CSE_FA_CREATION_ATRIB_ERROR');
      fnd_message.set_token('ASSET_ATTRIBUTE','DESCRIPTION');
      fnd_message.set_token('CSI_TRANSACTION_ID',p_asset_attrib_rec.transaction_id);
      x_error_msg := fnd_message.get;
      RETURN NULL ;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_message.set_name('CSE','CSE_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME',l_api_name);
      fnd_message.set_token('SQL_ERROR',SQLERRM);
      x_error_msg := fnd_message.get;
      RETURN NULL ;
  END asset_description ;

  ---------------------------------------------------------------------------+
  --       Procedure/Function  Name : asset_category
  --       Description   : returns asset category ID based on either the
  --                       default logic OR
  --                       the asset category ID  derived by client extension.
  --------------------------------------------------------------------------
  FUNCTION asset_category(
    p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
    x_error_msg             OUT NOCOPY       VARCHAR2,
    x_return_status         OUT NOCOPY       VARCHAR2) RETURN NUMBER
  IS
    l_category_segs     VARCHAr2(2000);
    x_hook_used         PLS_INTEGER;
    l_return_status     VARCHAR2(1);
    e_error             EXCEPTION;
    l_error_msg         VARCHAR2(2000);
    l_txn_class         VARCHAR2(30);

    l_api_name VARCHAR2(100) ;

  BEGIN
    x_return_status := fnd_api.G_RET_STS_SUCCESS ;
    l_api_name := 'CSE_ASSET_UTIL_PKG.asset_category';
    cse_asset_client_ext_stub.get_asset_category
                                   (p_asset_attrib_rec, --modified the signature for R12
                                    x_hook_used,
                                    x_error_msg);

    IF x_hook_used = 1
    THEN
       RETURN p_asset_attrib_rec.Asset_Category_ID ;
    ELSE

       get_txn_class (p_asset_attrib_rec  =>  p_asset_attrib_rec ,
                         x_transaction_class => l_txn_class,
                         x_return_status    => l_return_status ,
                         x_error_msg        => l_error_msg);

       IF l_return_status <> fnd_api.G_RET_STS_SUCCESS
       THEN
          RAISE e_error ;
       END IF ;

       IF l_txn_class <> G_IPV_TXN_CLASS
       THEN
          IF p_asset_attrib_rec.inventory_item_id IS NULL
          THEN
             RAISE e_error ;
          END IF ;
       END IF;

          cse_ipa_trans_pkg.get_fa_asset_category(p_asset_attrib_rec.inventory_item_id,
                          p_asset_attrib_rec.organization_id,
                          p_asset_attrib_rec.transaction_id,
                          p_asset_attrib_rec.Asset_Category_ID,
                          l_category_segs,
                          l_return_status,
                          x_error_msg);

          IF l_return_status <> fnd_api.G_RET_STS_SUCCESS
          THEN
             RAISE e_error ;
          END IF ;
       RETURN p_asset_attrib_rec.Asset_Category_ID;
    END IF;
EXCEPTION
WHEN e_error
THEN
   x_return_status := FND_API.G_RET_STS_ERROR ;
   fnd_message.set_name('CSE','CSE_ASSET_CAT_ERROR');
   x_error_msg := fnd_message.get;
   RETURN NULL ;
WHEN OTHERS
THEN
  x_return_status := FND_API.G_RET_STS_ERROR ;
  fnd_message.set_name('CSE','CSE_UNEXP_SQL_ERROR');
  fnd_message.set_token('API_NAME',l_api_name);
  fnd_message.set_token('SQL_ERROR',SQLERRM);
  x_error_msg := fnd_message.get;
  RETURN NULL;
END asset_category ;

---------------------------------------------------------------------------+
--       Procedure/Function Name : book_type
--       Description : Returns FA Book Type Code based on either the
--                     default logic OR the FA book type code derived
--                     by client extension.
--       Fan Li  August 27, 2007  Support for Multiple FA Book Type
--                                against Projects Flow
--------------------------------------------------------------------------
FUNCTION book_type(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
  x_error_msg             OUT NOCOPY       VARCHAR2,
  x_return_status         OUT NOCOPY       VARCHAR2) RETURN VARCHAR2
IS
x_hook_used        PLS_INTEGER;
l_txn_process_flag   VARCHAR2(1);
l_asset_creation_code  VARCHAR2(1);
e_error             EXCEPTION;
l_api_name VARCHAR2(100) := 'CSE_ASSET_UTIL_PKG.Book_Type';
l_txn_ou_context     NUMBER; -- Bug 6492235, added to support multiple FA book
BEGIN
    x_return_status := fnd_api.G_RET_STS_SUCCESS ;
    cse_asset_client_ext_stub.get_book_type(p_asset_attrib_rec, --modified the signature for R12
                                            x_hook_used,
                                            x_error_msg);

    IF x_hook_used = 1
    THEN
       RETURN p_asset_attrib_rec.book_type_code;
    ELSE
-- Changed for Multiple FA books. Get the OU context for inventory txns
-- If not inventory txn then l_txn_ou_context is null and site level
-- fa book type would be read.
      BEGIN
        DEBUG('inside '|| l_api_name || 'Get INV OU context');
        SELECT 	ood.operating_unit
   	INTO 	l_txn_ou_context
        FROM 	org_organization_definitions  ood,
                mtl_material_transactions     mmt,
                csi_inst_txn_details_v        citdv
	WHERE 	citdv.transaction_id = p_asset_attrib_rec.transaction_id
	AND   	citdv.inv_material_transaction_id = mmt.transaction_id
	AND   	mmt.organization_id = ood.organization_id
	AND   	ROWNUM = 1;
      EXCEPTION
        When no_data_found then
            -- This may be a projects flow. Get the operating unit context
            -- from the project.
            BEGIN
              DEBUG('inside '|| l_api_name || 'Get PA OU context');
              SELECT  pa.ORG_ID
              INTO    l_txn_ou_context
              FROM    csi_item_instances_h  ciih,
                      csi_item_instances    cii,
                      csi_transactions      ct,
                      pa_projects_all       pa
              WHERE   ciih.transaction_id = p_asset_attrib_rec.transaction_id
              AND     ciih.instance_id = p_asset_attrib_rec.instance_id
              AND     cii.instance_id = p_asset_attrib_rec.instance_id
              AND     ct.transaction_id = p_asset_attrib_rec.transaction_id
              AND     (ciih.new_inst_usage_code = 'IN_SERVICE' OR cii.instance_usage_code = 'IN_SERVICE')
              AND     ct.transaction_type_id = 108   -- PROJECT_ITEM_IN_SERVICE
              AND     ct.transaction_status_code = 'INTERFACED_TO_PA'
              AND     ct.source_header_ref_id = nvl(cii.last_pa_project_id, source_header_ref_id)
              AND     ct.source_line_ref_id = nvl(cii.last_pa_task_id, source_line_ref_id)
              AND     pa.project_id = cii.last_pa_project_id;
            EXCEPTION
              When no_data_found then
                  -- This may be a receipt into Projects
                  BEGIN
                    DEBUG('inside '|| l_api_name || 'Receipt item into project');
                    SELECT  cod.operating_unit
                    INTO    l_txn_ou_context
                    FROM    rcv_transactions              rt,
                            csi_inst_txn_details_v        citdv,
                            org_organization_definitions  cod
                    WHERE   citdv.transaction_id = p_asset_attrib_rec.transaction_id
                    AND     citdv.source_transaction_type = 'PO_RECEIPT_INTO_PROJECT'
                    AND     rt.transaction_id = citdv.source_dist_ref_id2
                    AND     rt.organization_id = cod.organization_id;
                  EXCEPTION
                    When no_data_found then
                          l_txn_ou_context := '' ;
                  END;
            END;
      END ;

      DEBUG('inside '|| l_api_name || 'OU context is ' || l_txn_ou_context);

      p_asset_attrib_rec.book_type_code := fnd_profile.VALUE_SPECIFIC(
         			name => 'cse_fa_book_type_code',
         			ORG_ID => l_txn_ou_context
         			);
      DEBUG('inside '|| l_api_name || 'CSE_FA_BOOK_TYPE_CODE: '
            || p_asset_attrib_rec.book_type_code);

       IF p_asset_attrib_rec.book_type_code IS NULL
       THEN
          RAISE e_error ;
       END IF ;

       RETURN p_asset_attrib_rec.book_type_code;

    END IF; --hook used

EXCEPTION
WHEN e_error
THEN
   x_return_status := FND_API.G_RET_STS_ERROR ;
   fnd_message.set_name('CSE','CSE_ASSET_BOOK_ERROR');
   x_error_msg := fnd_message.get;
   RETURN NULL ;
WHEN OTHERS
THEN
  x_return_status := FND_API.G_RET_STS_ERROR ;
  fnd_message.set_name('CSE','CSE_UNEXP_SQL_ERROR');
  fnd_message.set_token('API_NAME',l_api_name);
  fnd_message.set_token('SQL_ERROR',SQLERRM);
  x_error_msg := fnd_message.get;
  RETURN NULL;
END book_type;

  --------------------------------------------------------------------------
  -- Description   : Returns DPIS based on either the default logic
  --                 OR  the DPIS derived by client extension.
  --------------------------------------------------------------------------
  FUNCTION date_place_in_service(
    p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
    x_error_msg             OUT NOCOPY       VARCHAR2,
    x_return_status         OUT NOCOPY       VARCHAR2) RETURN DATE
  IS
    l_date_place_in_service DATE;
    x_date_place_in_service DATE;
    l_asset_creation_code   VARCHAR2(30);
    l_transaction_date      DATE;
    l_book_type_code        VARCHAR2(15) ;
    x_hook_used             PLS_INTEGER;
    l_txn_class             VARCHAR2(30);
    l_return_status         VARCHAR2(1);
    l_serial_control_code   number;
    l_error_message         varchar2(2000);

    CURSOR dpi_cur (p_csi_txn_id IN NUMBER, p_inst_id IN number) IS
      SELECT msib.asset_creation_code,
             msib.serial_number_control_code,
             citdv.source_transaction_date
      FROM   mtl_system_items_b      msib,
             csi_inst_txn_details_v  citdv
      WHERE  msib.organization_id   = citdv.inv_master_organization_id
      AND    msib.inventory_item_id = citdv.inventory_item_id
      AND    citdv.transaction_id   = p_csi_txn_id
      AND    citdv.instance_id      = p_inst_id;


    CURSOR fiscal_period_cur (l_book_type_code IN VARCHAR) IS
      SELECT start_date
      FROM   fa_book_controls    fbc,
             fa_calendar_periods fcp
      WHERE  fbc.book_type_code   = l_book_type_code
      AND    fcp.calendar_type    = fbc.deprn_calendar
      AND    trunc(l_transaction_date) BETWEEN fcp.start_date AND fcp.end_date;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success ;

    debug('inside cse_asset_util_pkg.date_place_in_service');

    cse_asset_client_ext_stub.get_date_place_in_service(
      p_asset_attrib_rec,
      x_date_place_in_service,
      x_hook_used,
      x_error_msg);

    l_date_place_in_service := x_date_place_in_service ;

    IF x_hook_used = 1 THEN
      RETURN l_date_place_in_service ;
    ELSE

      get_txn_class (p_asset_attrib_rec  =>  p_asset_attrib_rec ,
        x_transaction_class => l_txn_class,
        x_return_status     => l_return_status ,
        x_error_msg         => l_error_message);

      IF l_txn_class =  G_IPV_TXN_CLASS OR l_txn_class = G_MOVE_TXN_CLASS THEN
        l_date_place_in_service := to_date(null);
        RETURN l_date_place_in_service ;
      ELSE

        OPEN  dpi_cur(p_asset_attrib_rec.transaction_id, p_asset_attrib_rec.instance_id);
        FETCH dpi_cur INTO l_asset_creation_code, l_serial_control_code, l_transaction_date;
        CLOSE dpi_cur ;

        debug('  transaction_date       : '||l_transaction_date);
        debug('  serial_control_code    : '||l_serial_control_code);

        IF l_serial_control_code in (2, 5) THEN
          l_date_place_in_service := l_transaction_date;
        ELSE

          IF nvl(p_asset_attrib_rec.book_type_code, fnd_api.g_miss_char) = fnd_api.g_miss_char THEN
            l_book_type_code := cse_asset_util_pkg.book_type(p_asset_attrib_rec,
                                x_error_msg,
                                x_return_status);
            IF x_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
              RAISE fnd_api.g_exc_error ;
            END IF ;
          ELSE
            l_book_type_code := p_asset_attrib_rec.book_type_code;
          END IF;

          OPEN  fiscal_period_cur (l_book_type_code);
          FETCH fiscal_period_cur INTO l_date_place_in_service ;
          CLOSE fiscal_period_cur ;

        END IF;

        IF l_date_place_in_service IS NULL THEN
          RAISE fnd_api.g_exc_error ;
        END IF ;

        debug('  date_placed_in_service  : '||l_date_place_in_service);
        RETURN l_date_place_in_service ;

      END IF ; ---IPV/MOVE
    END IF ; --Hook Used

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_message.set_name('CSE','CSE_FA_CREATION_ATRIB_ERROR');
      fnd_message.set_token('ASSET_ATTRIBUTE','DATE_PLACED_IN_SERVICE');
      fnd_message.set_token('CSI_TRANSACTION_ID',p_asset_attrib_rec.transaction_id);
      x_error_msg := fnd_message.get;
      RETURN null ;
  END date_place_in_service ;


  FUNCTION asset_key(
    p_asset_attrib_rec  IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
    x_error_msg            OUT NOCOPY VARCHAR2,
    x_return_status        OUT NOCOPY VARCHAR2) RETURN NUMBER
  IS
    l_asset_key_ccid    NUMBER;
    l_hook_used         PLS_INTEGER;
    l_api_name          VARCHAR2(100) := 'cse_asset_util_pkg.asset_key';
  BEGIN
    x_return_status := fnd_api.g_ret_sts_success;
    cse_asset_client_ext_stub.get_asset_key(p_asset_attrib_rec,
                              l_asset_key_ccid,
                              l_hook_used,
                              x_error_msg);
    IF l_hook_used = 1 THEN
      RETURN l_asset_key_ccid;
    ELSE
      RETURN null;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_message.set_name('CSE','CSE_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME',l_api_name);
      fnd_message.set_token('SQL_ERROR',SQLERRM);
      x_error_msg := fnd_message.get;
      RETURN NULL;
  END asset_key;

  ---------------------------------------------------------------------------+
  -- Description : returns the total wip cost of an asssemebly - comp cost
  --------------------------------------------------------------------------
  PROCEDURE get_wip_assembly_cost(
    p_asset_attrib_rec  IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
    x_wip_assembly_cost    OUT NOCOPY NUMBER,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_error_msg            OUT NOCOPY VARCHAR2)
  IS
    l_fa_comp_cost    NUMBER ;
    l_fa_item_cost    NUMBER ;
    l_wip_entity_id   NUMBER ;
    l_wip_job_cost    NUMBER ;
    l_api_name        VARCHAR2(100) ;

    CURSOR wip_cost_cur(c_wip_entity_id IN NUMBER) IS
      SELECT NVL(tl_overhead_in,0)+
             NVL(tl_resource_in,0)+
             NVL(tl_outside_processing_in,0)+
             NVL(pl_overhead_in,0)+
             NVL(pl_material_in,0)+
             NVL(pl_material_overhead_in,0)+
             NVL(pl_resource_in,0)+
             NVL(pl_outside_processing_in,0)
      FROM   wip_period_balances
      WHERE  wip_entity_id = c_wip_entity_id ;

    CURSOR csi_txn_inst_cur(l_wip_entity_id  IN NUMBER) IS
      SELECT citdv.instance_id,
             citdv.inventory_item_id,
             citdv.inv_organization_id,
             mmt.primary_quantity
      FROM   csi_inst_txn_details_v citdv,
             csi_i_assets  cia,
             mtl_material_transactions mmt
      WHERE  citdv.source_header_ref_id=l_wip_entity_id
      AND    cia.instance_id=citdv.instance_id
      AND    citdv.inv_material_transaction_id=mmt.transaction_id ;

  BEGIN

    x_return_status := fnd_api.G_RET_STS_SUCCESS ;
    l_api_name    := 'CSE_ASSET_UTIL_PKG.get_wip_assembly_cost';

    debug('Begining of Calculation of Wip cost ');

    OPEN  wip_cost_cur(p_asset_attrib_rec.source_header_ref_id);
    FETCH wip_cost_cur into l_wip_job_cost;
    CLOSE wip_cost_cur;

    FOR csi_txn_inst_rec in csi_txn_inst_cur(p_asset_attrib_rec.source_header_ref_id)
    LOOP
      l_fa_item_cost  := get_item_cost (
        p_inventory_item_id  =>csi_txn_inst_rec.inventory_item_id,
        p_organization_id    => csi_txn_inst_rec.inv_organization_id);

      l_fa_comp_cost:=l_fa_comp_cost+l_fa_item_cost*csi_txn_inst_rec.primary_quantity;

    END LOOP;

    x_wip_assembly_cost := NVL(l_wip_job_cost,0) - NVL(l_fa_comp_cost,0);

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_message.set_name('CSE','CSE_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME',l_api_name);
      fnd_message.set_token('SQL_ERROR',SQLERRM);
      x_error_msg := fnd_message.get;
  END get_wip_assembly_cost;

  FUNCTION deprn_expense_ccid(
    p_asset_attrib_rec   IN OUT NOCOPY cse_datastructures_pub.asset_attrib_rec,
    x_error_msg             OUT NOCOPY varchar2,
    x_return_status         OUT NOCOPY varchar2) RETURN number
  IS

    l_deprn_expense_ccid    number;
    l_book_type_code        varchar2(15) ;
    l_category_id           number ;

    l_flex_num              number;
    l_segment_num           number;
    l_temp_ccid             number;
    l_app_short_name        varchar2(50);
    l_num_of_segs           number;
    l_segments              fnd_flex_ext.SegmentArray ;
    l_deprn_expense_acct    varchar2(25);
    l_flex_code             varchar2(4) := 'GL#' ;
    l_hook_used             pls_integer;
    l_category_conc_seg     varchar2(80);

    l_api_name              varchar2(100) := 'cse_asset_util_pkg.deprn_expense_ccod';
    l_return_status         varchar2(1)   := fnd_api.g_ret_sts_success;
    l_error_message         varchar2(2000);

    CURSOR fab_control_cur (c_book_type_code IN VARCHAR2) IS
      SELECT accounting_flex_structure
      FROM   fa_book_controls
      WHERE  book_type_code = c_book_type_code ;

    CURSOR fifs_acct_cur (l_flex_num IN NUMBER) IS
      SELECT fifs.segment_num
      FROM   fnd_id_flex_segments  fifs,
             fnd_segment_attribute_values   fsav
      WHERE  fifs.application_column_name = fsav.application_column_name
      AND    fifs.id_flex_num             = fsav.id_flex_num
      AND    fifs.id_flex_code            = fsav.id_flex_code
      AND    fifs.application_id          = fsav.application_id
      AND    fsav.application_id          = 101  --GL
      AND    fsav.id_flex_code            = 'GL#'
      AND    fsav.id_flex_num             = l_flex_num
      AND    fsav.segment_attribute_type  = 'GL_ACCOUNT'
      AND    fsav.attribute_value         = 'Y';

    CURSOR asset_clearing_acct_cur (p_book_type_code IN VARCHAR2, p_category_id IN NUMBER) IS
      SELECT asset_clearing_account_ccid ,
             deprn_expense_acct
      FROM   fa_category_books
      WHERE  book_type_code = p_book_type_code
      AND    category_id    = p_category_id ;

    CURSOR fnd_application_cur IS
      SELECT  application_short_name
      FROM    fnd_application
      WHERE   application_id = 101 ;  --GL

    CURSOR fa_category_kfv_cur (l_category_id    IN NUMBER) IS
      SELECT concatenated_segments
      FROM   fa_categories_b_kfv
      WHERE  category_id = l_category_id ;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    IF nvl(p_asset_attrib_rec.book_type_code, fnd_api.g_miss_char) <> fnd_api.g_miss_char THEN
      l_book_type_code := p_asset_attrib_rec.book_type_code;
    ELSE

      l_book_type_code := cse_asset_util_pkg.book_type(
                            p_asset_attrib_rec => p_asset_attrib_rec,
                            x_error_msg        => l_error_message,
                            x_return_status    => l_return_status);

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF ;
    END IF;

    cse_asset_client_ext_stub.get_deprn_expense_ccid(
      p_asset_attrib_rec    => p_asset_attrib_rec,
      x_deprn_expense_ccid  => l_deprn_expense_ccid,
      x_hook_used           => l_hook_used,
      x_error_msg           => l_error_message);

    IF l_hook_used = 1 THEN
      RETURN l_deprn_expense_ccid;
    ELSE

      IF nvl(p_asset_attrib_rec.asset_category_id, fnd_api.g_miss_num) <> fnd_api.g_miss_num THEN
        l_category_id := p_asset_attrib_rec.asset_category_id;
      ELSE

        l_category_id :=  cse_asset_util_pkg.asset_category(
                            p_asset_attrib_rec  => p_asset_attrib_rec,
                            x_error_msg         => l_error_message,
                            x_return_status     => l_return_status);

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF ;
      END IF;

      OPEN  fab_control_cur(l_book_type_code) ;
      FETCH fab_control_cur INTO l_flex_num ;
      CLOSE fab_control_cur ;

      OPEN  fifs_acct_cur(l_flex_num);
      FETCH fifs_acct_cur INTO l_segment_num ;
      CLOSE fifs_acct_cur ;

      OPEN  asset_clearing_acct_cur(l_book_type_code, l_category_id) ;
      FETCH asset_clearing_acct_cur INTO l_temp_ccid , l_deprn_expense_acct ;
      CLOSE asset_clearing_acct_cur ;

      IF l_temp_ccid is null THEN
        fnd_message.set_name('CSE','CSE_ASSET_BOOK_CAT_UNDEFINED');
        fnd_message.set_token('BOOK_TYPE_CODE',l_book_type_code);
        OPEN  fa_category_kfv_cur (l_category_id) ;
        FETCH fa_category_kfv_cur into l_category_conc_seg ;
        CLOSE fa_category_kfv_cur ;
        fnd_message.set_token('ASSET_CAT',l_category_conc_seg);
        l_error_message := fnd_message.get;
        RAISE fnd_api.g_exc_error;
      END IF ;

      OPEN  fnd_application_cur ;
      FETCH fnd_application_cur INTO l_app_short_name ;
      CLOSE fnd_application_cur ;

      IF fnd_flex_ext.get_segments(
           application_short_name => l_app_short_name,
           key_flex_code          => l_flex_code,
           structure_number       => l_flex_num,
           combination_id         => l_temp_ccid,
           n_segments             => l_num_of_segs,
           segments               => l_segments)
      THEN

        l_segments(l_segment_num) := l_deprn_expense_acct ;

        IF fnd_flex_ext.get_combination_id(
             application_short_name => l_app_short_name,
             key_flex_code          => l_flex_code,
             structure_number       => l_flex_num,
             validation_date        => sysdate,
             n_segments             => l_num_of_segs,
             segments               => l_segments,
             combination_id         => l_deprn_expense_ccid)
        THEN
          IF l_deprn_expense_ccid IS NULL THEN
            RAISE fnd_api.g_exc_error;
          END IF ;
          RETURN l_deprn_expense_ccid ;
        ELSE
          null ;
        END IF;
      END IF;
    END IF;

    IF l_deprn_expense_ccid IS NULL THEN
      RAISE fnd_api.g_exc_error ;
    END IF;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      IF l_error_message is null THEN
        fnd_message.set_name('CSE','CSE_ASSET_EXPENSE_ACCT_ERROR');
        fnd_message.set_token('BOOK_TYPE_CODE',l_book_type_code);
        l_error_message := fnd_message.get;
      END IF;
      x_error_msg := l_error_message;
      RETURN null ;
  END deprn_expense_ccid ;

---------------------------------------------------------------------------+
--       Procedure/Function  Name : search_method
--       Description   : returns LIFO or FIFO search method based on either the
--                       default logic OR
--                       the LIFO or FIFO derived by client extension.
--------------------------------------------------------------------------
FUNCTION search_method(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
  x_error_msg             OUT NOCOPY       VARCHAR2,
  x_return_status         OUT NOCOPY       VARCHAR2) RETURN VARCHAR2
IS

l_search_method    VARCHAR2(4);
x_search_method    VARCHAR2(4);
x_hook_used        PLS_INTEGER;
e_error            EXCEPTION;
l_api_name VARCHAR2(100) := 'CSE_ASSET_UTIL_PKG.search_method';


BEGIN
    x_return_status := fnd_api.G_RET_STS_SUCCESS ;
   cse_asset_client_ext_stub.get_search_method( p_asset_attrib_rec,
                               x_search_method,
                               x_hook_used,
                               x_error_msg);
   l_search_method := x_search_method ;
   IF x_hook_used = 1
   THEN
      RETURN l_search_method;
   ELSE
      IF p_asset_attrib_rec.Source_Transaction_type  IN
   ( 'PO_RECEIPT_INTO_INVENTORY',
                'PO_RECEIPT_INTO_PROJECT',
                'MISC_RECEIPT',
                 'ACCT_ISSUE' ,
                 'ACCT_ALIAS_ISSUE',
                 'RETURN_TO_VENDOR' ,
                 'ACCT_RECEIPT',
                 'ACCT_ALIAS_RECEIPT',
                 'ISO_ISSUE',
                'MISC_ISSUE',
                'PHYSICAL_INVENTORY',
                'CYCLE_COUNT',
                'IPV_ADJUSTMENT_TO_FA',
                'ASSET_ITEM_MOVE',
                'SUBINVENOTRY_TRANSFER',
                'INTERORG_TRANSFER',
                'ISO_REQUISITION_RECEIPT',
                'ISO_SHIPMENT',
                'PROJECT_ITEM_IN_SERVICE',
  'IPV_ADJUSTMENT_TO_FA')
 THEN

              l_search_method:=G_FIFO_SEARCH;
 ELSE
       l_search_method:=G_LIFO_SEARCH;
 END IF;


      IF l_search_method IS NULL
      THEN
         RAISE e_error ;
      END IF ;

      RETURN l_search_method ;
   END IF;

EXCEPTION
WHEN e_error
THEN
  x_return_status := FND_API.G_RET_STS_ERROR ;
  fnd_message.set_name('CSE','CSE_UNEXP_SQL_ERROR');
  fnd_message.set_token('API_NAME',l_api_name);
  fnd_message.set_token('SQL_ERROR',SQLERRM);
  x_error_msg := fnd_message.get;
  RETURN NULL;
WHEN OTHERS
THEN
  x_return_status := FND_API.G_RET_STS_ERROR ;
  fnd_message.set_name('CSE','CSE_UNEXP_SQL_ERROR');
  fnd_message.set_token('API_NAME',l_api_name);
  fnd_message.set_token('SQL_ERROR',SQLERRM);
  x_error_msg := fnd_message.get;
  RETURN NULL;
END search_method;


  ---------------------------------------------------------------------------+
  --     Procedure/Function  Name : Payables CCID
  --     Description   : returns payables CCID based on either the
  --                       default logic OR
  --                       the Payables CCID derived by client extension.
  --------------------------------------------------------------------------

  FUNCTION payables_ccid(
    p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
    x_error_msg             OUT NOCOPY       VARCHAR2,
    x_return_status         OUT NOCOPY       VARCHAR2) RETURN NUMBER
  IS

    l_hook_used               PLS_INTEGER;
    l_txn_process_flag        VARCHAR2(1);
    l_asset_acct_ccid         NUMBER ;
    l_src_txn_id              NUMBER;
    l_book_type_code          VARCHAR2(15);
    l_category_id             NUMBER ;
    l_entity_code             varchar2(100) :=  'MTL_ACCOUNTING_EVENTS';
    l_application_id          number        := 707; ---BOM/CST;
    l_txn_class               VARCHAR2(30);
    l_return_status           VARCHAR2(1);
    l_error_message           VARCHAR2(2000);

    l_csi_txn_type_id         number;
    l_mtl_txn_id              number;
    l_po_distribution_id      number;
    l_inventory_asset_flag    varchar2(1) := 'Y';
    l_organization_id         number;

    l_acct_line_type          number := 1;
    l_cost_element_id         number := 1;
    l_ledger_id               number;

    l_sla_flag                boolean := FALSE;
    l_exp_subinv_flag         VARCHAR2(1) := 'N'; --Added For bug 9488846
    l_subinventory_code     varchar2(30); --Added For bug 9488846


    CURSOR payables_ccid_cur (c_transaction_id IN NUMBER,c_instance_id IN  NUMBER) IS
      SELECT pda.code_combination_id
      FROM   po_distributions_all pda,
             rcv_transactions rt,
             csi_transactions ct
      WHERE  pda.po_distribution_id = rt.po_distribution_id
      AND    rt.transaction_id      = ct.source_dist_ref_id2
      AND    ct.transaction_id      = c_transaction_id
      AND    ct.transaction_type_id = 105 -- rec in to project
      UNION
      SELECT pda.variance_account_id
      FROM   po_distributions_all pda,
             ap_invoice_distributions_all aida ,
             csi_transactions ct
      WHERE  pda.po_distribution_id       = aida.po_distribution_id
      AND    aida.invoice_distribution_id = ct.source_dist_ref_id2
      AND    ct.transaction_id            = c_transaction_id
      AND    ct.transaction_type_id       = 102; -- ap ipv

    CURSOR sla_ccid_cur(
      p_mtl_txn_id IN number, p_acct_line_type IN number, p_cost_element_id in number, p_ledger_id IN number)
    IS
      SELECT xal.code_combination_id
      FROM   mtl_transaction_accounts mta,
             xla_distribution_links xdl,
             xla_ae_lines xal,
             xla_ae_headers xah
      WHERE  mta.transaction_id               = p_mtl_txn_id
      AND    mta.accounting_line_type         = p_acct_line_type
      AND    nvl(mta.cost_element_id,1)       = p_cost_element_id
      AND    xdl.source_distribution_type     = 'MTL_TRANSACTION_ACCOUNTS'
      AND    xdl.source_distribution_id_num_1 = mta.inv_sub_ledger_id
      AND    xal.ae_header_id                 = xdl.ae_header_id
      AND    xal.ae_line_num                  = xdl.ae_line_num
      AND    xah.ae_header_id                 = xal.ae_header_id
      AND    xah.ledger_id                    = p_ledger_id;

      /*
      SELECT  xlael.code_combination_id
      FROM    xla_transaction_entities xlte,
              xla_ae_headers xlaeh,
              xla_ae_lines xlael,
              xla_distribution_links xdl,
              mtl_transaction_accounts mta
      WHERE   xlte.application_id         = l_application_id
      AND     xlte.entity_code            = l_entity_code
      AND     xlte.source_id_int_1        = p_mtl_txn_id
      AND     xlaeh.ledger_id             = p_ledger_id
      AND     xlaeh.application_id        = xlte.application_id
      AND     xlaeh.entity_id             = xlte.entity_id
      AND     xlael.application_id        = xlte.application_id
      AND     xlael.ae_header_id          = xlaeh.ae_header_id
      AND     xlael.accounting_class_code = p_acct_class_code
      AND     xdl.ae_header_id            = xlael.ae_header_id
      AND     xdl.ae_line_num             = xlael.ae_line_num
      AND     mta.inv_sub_ledger_id       = xdl.source_distribution_id_num_1
      AND     mta.cost_element_id         = 1;
      */

    CURSOR src_mv_txn_cur (c_txn_id IN NUMBER) IS
      SELECT NVL(source_dist_ref_id2,transaction_id)
      FROM   csi_transactions
      WHERE  transaction_id = c_txn_id ;

    CURSOR asset_acct_cur (c_book_type_code VARCHAR2 , c_category_id IN NUMBER) IS
      SELECT asset_clearing_account_ccid
      FROM   fa_category_books
      WHERE  book_type_code = c_book_type_code
      AND    category_id    = c_category_id ;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    debug('inside cse_asset_util_pkg.payables_ccid');

    cse_asset_client_ext_stub.get_payables_ccid(
      p_asset_attrib_rec => p_asset_attrib_rec,
      x_payables_ccid    => l_asset_acct_ccid,
      x_hook_used        => l_hook_used,
      x_error_msg        => l_error_message);

    IF l_hook_used = 1 THEN
      RETURN l_asset_acct_ccid;
    ELSE

      SELECT transaction_type_id,
             inv_material_transaction_id,
             source_dist_ref_id1
      INTO   l_csi_txn_type_id,
             l_mtl_txn_id,
             l_po_distribution_id
      FROM   csi_transactions
      WHERE  transaction_id = p_asset_attrib_rec.transaction_id;

      get_txn_class (
        p_asset_attrib_rec   =>  p_asset_attrib_rec ,
        x_transaction_class  => l_txn_class,
        x_return_status      => l_return_status ,
        x_error_msg          => l_error_message);

      IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
        RAISE fnd_api.g_exc_error;
      END IF ;

      debug('txn class : '||l_txn_class);

      IF l_txn_class = G_MOVE_TXN_CLASS THEN
        OPEN  src_mv_txn_cur(p_asset_attrib_rec.transaction_id);
        FETCH src_mv_txn_cur INTO l_src_txn_id ;
        CLOSE src_mv_txn_cur;

        l_book_type_code := cse_asset_util_pkg.book_type(p_asset_attrib_rec,
                              l_error_message,
                              l_return_status);
        IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
          RAISE fnd_api.g_exc_error;
        END IF ;
        l_category_id := cse_asset_util_pkg.asset_category(p_asset_attrib_rec,
                           l_error_message,
                           l_return_status);
        IF l_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
          RAISE fnd_api.g_exc_error;
        END IF ;

        OPEN asset_acct_cur (l_book_type_code,l_category_id);
        FETCH asset_acct_cur INTO l_asset_acct_ccid ;
        CLOSE asset_acct_cur ;

        IF l_asset_acct_ccid IS NULL THEN
          RAISE fnd_api.g_exc_error;
        END IF ;

        RETURN l_asset_acct_ccid ;
      ELSE


        debug('transaction_type_id  : '||l_csi_txn_type_id);
        debug('mtl_transaction_id   : '||l_mtl_txn_id);

        IF l_mtl_txn_id is null THEN

          OPEN  payables_ccid_cur(p_asset_attrib_rec.transaction_id,p_asset_attrib_rec.instance_id) ;
          FETCH payables_ccid_cur INTO l_asset_acct_ccid ;
          CLOSE payables_ccid_cur ;

        ELSE
					--Modifications  For bug 9488846 - start
          SELECT nvl(msi.inventory_asset_flag, 'N'),
                 mmt.organization_id,
                 subinventory_code
          INTO   l_inventory_asset_flag,
                 l_organization_id,
                 l_subinventory_code
          FROM   mtl_material_transactions mmt,
                 mtl_system_items msi
          WHERE  mmt.transaction_id    = l_mtl_txn_id
          AND    msi.inventory_item_id = mmt.inventory_item_id
          AND    msi.organization_id   = mmt.organization_id;

          SELECT decode(asset_inventory,2,'Y','N') --1=Asset Subinventory 2=Expense subinventory
          INTO   l_exp_subinv_flag
          FROM   mtl_secondary_inventories
          WHERE  organization_id          = l_organization_id
          AND    secondary_inventory_name = l_subinventory_code;

          IF (l_inventory_asset_flag = 'Y' AND l_exp_subinv_flag = 'N') or l_csi_txn_type_id = 112 THEN

            IF l_csi_txn_type_id = 112 THEN
              IF l_inventory_asset_flag = 'N' OR l_exp_subinv_flag = 'Y' THEN --Modifications For bug 9488846 - end
                l_acct_line_type  := 2;
                --l_cost_element_id := 0;
              END IF;
            END IF;

            l_ledger_id := primary_ledger_id(l_organization_id);


            debug('application_id  : '||l_application_id);
            debug('entity_code     : '||l_entity_code);
            debug('mtl_txn_id      : '||l_mtl_txn_id);
            debug('acct_line_type  : '||l_acct_line_type);
            debug('ledger_id       : '||l_ledger_id);

            xla_security_pkg.set_security_context(l_application_id);

            OPEN  sla_ccid_cur(l_mtl_txn_id, l_acct_line_type, l_cost_element_id, l_ledger_id);
            FETCH sla_ccid_cur INTO l_asset_acct_ccid;
            CLOSE sla_ccid_cur;

            l_sla_flag := TRUE;

          ELSE
            cse_asset_client_ext_stub.get_inv_depr_acct(
              p_mtl_transaction_id  => p_asset_attrib_rec.transaction_id,
              x_dummy_acct_id       => l_asset_acct_ccid,
              x_hook_used           => l_hook_used,
              x_error_msg           => l_error_message);

            IF l_hook_used <> 1 THEN
              SELECT material_account
              INTO   l_asset_acct_ccid
              FROM   mtl_parameters mp
              WHERE  mp.organization_id = l_organization_id;
            END IF;

          END IF;

        END IF;

        IF l_asset_acct_ccid IS NULL THEN
          RAISE fnd_api.g_exc_error;
        END IF ;

        RETURN l_asset_acct_ccid ;
      END IF ; --Move Txn
    END IF;  --Hook Used

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;

      IF l_sla_flag THEN
        fnd_message.set_name('CSE','CSE_SLA_PAY_CCID_NOT_FOUND');
        fnd_message.set_token('MTL_TXN_ID', l_mtl_txn_id);
      ELSE
        fnd_message.set_name('CSE','CSE_FA_CREATION_ATRIB_ERROR');
        fnd_message.set_token('ASSET_ATTRIBUTE','PAYABLES_CODE_COMBINATION_ID');
        fnd_message.set_token('CSI_TRANSACTION_ID',p_asset_attrib_rec.transaction_id);
      END IF;
      x_error_msg := fnd_message.get;
      RETURN NULL ;
  END payables_ccid;

---------------------------------------------------------------------------+
--       Procedure/Function  Name : tag_number
--       Description   : returns Tag Number based on either the
--                       default logic OR
--                       the Tag Number derived by client extension.
--------------------------------------------------------------------------
FUNCTION tag_number(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
  x_error_msg             OUT NOCOPY       VARCHAR2,
  x_return_status         OUT NOCOPY       VARCHAR2) RETURN VARCHAR2
IS
x_tag_number      VARCHAR2(15);
l_tag_number      VARCHAR2(15);
x_hook_used        PLS_INTEGER;
l_api_name VARCHAR2(100) := 'CSE_ASSET_UTIL_PKG.tag_number';
BEGIN
    x_return_status := fnd_api.G_RET_STS_SUCCESS ;
   cse_asset_client_ext_stub.get_tag_number(p_asset_attrib_rec,
                              x_tag_number,
                              x_hook_used,
                              x_error_msg);
   l_tag_number    :=  x_tag_number ;
   IF x_hook_used = 1
   THEN
      RETURN l_tag_number;
   ELSE
     RETURN NULL;
   END IF;

EXCEPTION
WHEN OTHERS
THEN
  x_return_status := FND_API.G_RET_STS_ERROR ;
  fnd_message.set_name('CSE','CSE_UNEXP_SQL_ERROR');
  fnd_message.set_token('API_NAME',l_api_name);
  fnd_message.set_token('SQL_ERROR',SQLERRM);
  x_error_msg := fnd_message.get;
  RETURN NULL;
END tag_number;

---------------------------------------------------------------------------+
--       Procedure/Function  Name : model_number
--       Description   : returns Model Number based on either the
--                       default logic OR
--                      the Model Number derived by client extension.
--------------------------------------------------------------------------
FUNCTION model_number(
p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
  x_error_msg             OUT NOCOPY       VARCHAR2,
  x_return_status         OUT NOCOPY       VARCHAR2) RETURN VARCHAR2
IS
x_model_number      VARCHAR2(40);
l_model_number      VARCHAR2(40);
x_hook_used        PLS_INTEGER;
l_api_name    VARCHAR2(100)   := 'CSE_ASSET_UTIL_PKG.model_number';
BEGIN
    x_return_status := fnd_api.G_RET_STS_SUCCESS ;
   cse_asset_client_ext_stub.get_model_number(p_asset_attrib_rec,
                              x_model_number,
                               x_hook_used,
                              x_error_msg);
   l_model_number    :=  x_model_number ;
   IF x_hook_used = 1
   THEN
      RETURN l_model_number;
   ELSE
     RETURN NULL;
   END IF;
EXCEPTION
WHEN OTHERS
THEN
  x_return_status := FND_API.G_RET_STS_ERROR ;
  fnd_message.set_name('CSE','CSE_UNEXP_SQL_ERROR');
  fnd_message.set_token('API_NAME',l_api_name);
  fnd_message.set_token('SQL_ERROR',SQLERRM);
  x_error_msg := fnd_message.get;
  RETURN   NULL;
END model_number;

---------------------------------------------------------------------------+
--       Procedure/Function  Name : manufacturer
--       Description   : returns Manufacturer Name based on either the
--                       default logic OR
--                      the Manufacturer Name derived by client extension.
--------------------------------------------------------------------------
FUNCTION manufacturer(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
  x_error_msg             OUT NOCOPY       VARCHAR2,
  x_return_status         OUT NOCOPY       VARCHAR2) RETURN VARCHAR2
IS
x_manufacturer_name      VARCHAR2(30);
l_manufacturer_name      VARCHAR2(30);
x_hook_used        PLS_INTEGER;
l_api_name       VARCHAR2(100) := 'CSE_ASSET_UTIL_PKG.manufacturer';
BEGIN
    x_return_status := fnd_api.G_RET_STS_SUCCESS ;
   cse_asset_client_ext_stub.get_manufacturer(p_asset_attrib_rec,
                              x_manufacturer_name,
                                    x_hook_used,
                              x_error_msg);
   l_manufacturer_name    :=  x_manufacturer_name ;
   IF x_hook_used = 1
   THEN
      RETURN l_manufacturer_name;
   ELSE
     RETURN NULL;
   END IF;
EXCEPTION
WHEN OTHERS
THEN
   x_return_status := FND_API.G_RET_STS_ERROR ;
  fnd_message.set_token('API_NAME',l_api_name);
  fnd_message.set_token('SQL_ERROR',SQLERRM);
  x_error_msg := fnd_message.get;
  RETURN   NULL;
END manufacturer;

---------------------------------------------------------------------------+
--       Procedure/Function  Name : employee
--       Description   : returns Employee ID based on either the
--                       default logic OR
--                       the Employee Id derived by client extension.
--------------------------------------------------------------------------
FUNCTION employee(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
  x_error_msg             OUT NOCOPY       VARCHAR2,
  x_return_status         OUT NOCOPY       VARCHAR2) RETURN NUMBER
IS
l_api_name       VARCHAR2(100) := 'CSE_ASSET_UTIL_PKG.employee';
x_employee_id      NUMBER;
l_employee_id      NUMBER;
x_hook_used        PLS_INTEGER;
BEGIN
    x_return_status := fnd_api.G_RET_STS_SUCCESS ;
   cse_asset_client_ext_stub.get_employee(p_asset_attrib_rec,
                              x_employee_id,
                                    x_hook_used,
                              x_error_msg);
   l_employee_id    :=  x_employee_id ;
   IF x_hook_used = 1
   THEN
      RETURN l_employee_id;
   ELSE
     RETURN NULL;
   END IF;
EXCEPTION
WHEN OTHERS
THEN
   x_return_status := FND_API.G_RET_STS_ERROR ;
  fnd_message.set_token('API_NAME',l_api_name);
  fnd_message.set_token('SQL_ERROR',SQLERRM);
  x_error_msg := fnd_message.get;
  RETURN NULL;
END employee;

  FUNCTION inventory_item(
    p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec)
  RETURN NUMBER IS
    l_api_name           VARCHAR2(100) := 'CSE_ASSET_UTIL_PKG.inventory_item';
    l_inventory_item_id  NUMBER;
    x_hook_used          PLS_INTEGER;
    x_error_msg          VARCHAR2(2000);
  BEGIN
    cse_asset_client_ext_stub.get_inventory_item(p_asset_attrib_rec, x_hook_used, x_error_msg);
    l_inventory_item_id    :=  p_asset_attrib_rec.inventory_item_id ;
    IF x_hook_used = 1 THEN
      RETURN l_inventory_item_id;
    ELSE
      l_inventory_item_id:=p_asset_attrib_rec.inventory_item_id;
      RETURN l_inventory_item_id;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END inventory_item;

PROCEDURE get_pending_retirements
(p_asset_query_rec IN OUT NOCOPY cse_datastructures_pub.asset_query_rec,
p_distribution_tbl IN OUT NOCOPY cse_datastructures_pub.distribution_tbl,
x_return_status           OUT NOCOPY VARCHAR2,
x_error_msg               OUT NOCOPY VARCHAR2)
IS
l_cost           NUMBER;
l_units          NUMBER;
l_api_name VARCHAR2(100) := 'CSE_ASSET_UTIL_PKG.get_pending_retirements';

CURSOR pending_rets_cur (c_distribution_id IN NUMBER)
IS
SELECT SUM(DECODE(fr.status,'PENDING', NVL(fr.cost_retired,0)*(-1),
                  NVL(fr.cost_retired,0))) cost,
       SUM(DECODE(fr.status,'PENDING', NVL(fr.units,0)*(-1),
                  NVL(fr.units,0))) units
FROM  fa_retirements fr ,
      fa_distribution_history fdh
WHERE fr.status IN ('PENDING','REINSTATE')
AND   fr.retirement_id = fdh.retirement_id
AND   fdh.distribution_id = c_distribution_id ;

CURSOR ext_ret_cur (c_distribution_id IN NUMBER)
IS
SELECT SUM(NVL(cost_retired,0)*(-1)) cost
      ,SUM(NVL(units,0)*(-1)) units
FROM  fa_mass_ext_retirements
WHERE review_status = 'POST'
AND   book_type_code = p_asset_query_rec.book_type_code
AND   asset_id = p_asset_query_rec.asset_id  ;
--AND   distribution_id = c_distribution_id ;

BEGIN
    x_return_status := fnd_api.G_RET_STS_SUCCESS ;
  debug('Begin get_pending_retirements');
  FOR i IN 1..p_distribution_tbl.COUNT
  LOOP
     debug('Distribution ID : '||p_distribution_tbl(i).distribution_id) ;
   OPEN pending_rets_cur(p_distribution_tbl(i).distribution_id) ;
   FETCH pending_rets_cur INTO l_cost, l_units ;
    debug('l_units :'||l_units);
    debug('l_cost :'||l_cost);

   IF NVL(l_units,0) > 0
   THEN
      debug('There are pending retirements ...');
      p_asset_query_rec.pending_ret_mtl_cost :=
            NVL(p_asset_query_rec.pending_ret_mtl_cost,0)+l_cost ;
      p_distribution_tbl(i).pending_ret_units :=
            NVL(p_distribution_tbl(i).pending_ret_units,0)+l_units ;
   END IF;
      x_return_status := FND_API.G_RET_STS_SUCCESS ;
   CLOSE pending_rets_cur ;

   OPEN ext_ret_cur (p_distribution_tbl(i).distribution_id) ;
   FETCH ext_ret_cur INTO l_cost, l_units ;

   IF NVL(l_units,0) > 0
   THEN
      p_asset_query_rec.pending_ret_mtl_cost :=
            NVL(p_asset_query_rec.pending_ret_mtl_cost,0)+l_cost ;
      p_distribution_tbl(i).pending_ret_units :=
            NVL(p_distribution_tbl(i).pending_ret_units,0)+l_units ;
   END IF;
      x_return_status := FND_API.G_RET_STS_SUCCESS ;
   CLOSE ext_ret_cur ;
  END LOOP ;
EXCEPTION
WHEN OTHERS
THEN
  x_return_status := FND_API.G_RET_STS_ERROR ;
  fnd_message.set_name('CSE','CSE_UNEXP_SQL_ERROR');
  fnd_message.set_token('API_NAME',l_api_name);
  fnd_message.set_token('SQL_ERROR',SQLERRM);
  x_error_msg := fnd_message.get;

END get_pending_retirements;

---------------------------------------------------------------------------

PROCEDURE get_pending_adjustments
(p_asset_query_rec IN OUT NOCOPY cse_datastructures_pub.asset_query_rec,
x_return_status           OUT NOCOPY VARCHAR2,
x_error_msg               OUT NOCOPY VARCHAR2)
IS
l_cost    NUMBER := 0;
l_units   NUMBER := 0;
l_total_units    NUMBER  := 0;
l_location_units NUMBER  := 0;
l_unit_ratio     NUMBER  := 1;
l_api_name VARCHAR2(100) := 'CSE_ASSET_UTIL_PKG.get_pending_adjustments';
l_mass_addition_id  NUMBER;
CURSOR pending_adj_cur
IS
SELECT SUM(NVL(fma.fixed_assets_cost,0)) cost ,
       SUM(fma.fixed_assets_units) total_units ,
       fma.mass_addition_id
FROM   fa_mass_additions fma
      ,fa_massadd_distributions fmd
WHERE  fmd.mass_addition_id = fma.mass_addition_id
AND    fma.posting_status = 'POST'
AND    fma.book_type_code = p_asset_query_rec.book_type_code
AND    fma.add_to_asset_id = p_asset_query_rec.asset_id
GROUP  BY fma.mass_addition_id ;

CURSOR adj_units_cur (c_mass_addition_id IN NUMBER)
IS
SELECT units  location_units
FROM   fa_massadd_distributions
WHERE  NVL(deprn_expense_ccid, -1)=
       NVL(p_asset_query_rec.deprn_expense_ccid,NVL(deprn_expense_ccid,-1))
AND    NVL(employee_id, -1)=
       NVL(p_asset_query_rec.employee_id,NVL(employee_id,-1))
AND    location_id = NVL(p_asset_query_rec.location_id,NVL(location_id,-1))
AND    mass_addition_id = c_mass_addition_id ;

BEGIN
    x_return_status := fnd_api.G_RET_STS_SUCCESS ;

       debug('Start of get_pending_adjustment');
FOR pending_adj_rec  IN pending_adj_cur
LOOP
  debug('In pending ad cur');
  IF (pending_adj_rec.cost = 0) OR
     (pending_adj_rec.total_units = 0)
  THEN
     p_asset_query_rec.pending_adj_mtl_cost :=
            NVL(p_asset_query_rec.pending_adj_mtl_cost,0)+0 ;
  ELSE
     l_mass_addition_id := pending_adj_rec.mass_addition_id ;
     l_location_units := 0;

--     FOR adj_units_rec IN adj_units_cur(l_mass_addition_id)
--     LOOP
--       debug('In adj_units cur');
--       l_location_units := l_location_units + adj_units_rec.location_units ;
--     END LOOP ;
--
--     l_unit_ratio := l_location_units/pending_adj_rec.total_units ;
--     l_cost := ROUND(pending_adj_rec.cost*l_unit_ratio,2) ;
--     p_asset_query_rec.pending_adj_mtl_cost :=
--                   NVL(p_asset_query_rec.pending_adj_mtl_cost,0)+l_cost ;

     p_asset_query_rec.pending_adj_mtl_cost :=
                   NVL(p_asset_query_rec.pending_adj_mtl_cost,0)+
                  ROUND(pending_adj_rec.cost,2) ;
       debug('Pending Adj Cost is :'|| p_asset_query_rec.pending_adj_mtl_cost);
  END IF;
END LOOP ;

EXCEPTION
WHEN OTHERS
THEN
  x_return_status := FND_API.G_RET_STS_ERROR ;
  fnd_message.set_name('CSE','CSE_UNEXP_SQL_ERROR');
  fnd_message.set_token('API_NAME',l_api_name);
  fnd_message.set_token('SQL_ERROR',SQLERRM);
  x_error_msg := fnd_message.get;

END get_pending_adjustments ;

-------------------------------------------------------------------------------

PROCEDURE get_catchup_dep_flag  (p_asset_attrib_rec  IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
p_asset_number IN VARCHAR2,
p_instance_asset_id       IN NUMBER,
x_catchup_flag            OUT NOCOPY VARCHAR2,
x_return_status           OUT NOCOPY VARCHAR2,
x_error_msg               OUT NOCOPY VARCHAR2)
IS
x_hook_used               NUMBER := 0;
l_catchup_flag            VARCHAR2(1);
l_api_name VARCHAR2(100) := 'CSE_ASSET_UTIL_PKG.get_catchup_dep_flag';




/*CURSOR catchup_cur (c_instance_asset_id IN NUMBER)
IS
SELECT DECODE(msib.asset_creation_code,'1','N','Y')
FROM   mtl_system_items_b msib
      ,csi_item_instances cii
      ,csi_i_assets cia
WHERE  msib.organization_id = cii.inv_master_organization_id
AND    msib.inventory_item_id = cii.inventory_item_id
AND    cii.instance_id = cia.instance_id
AND    cia.instance_asset_id = c_instance_asset_id;*/


CURSOR catchup_cur (c_instance_asset_id IN NUMBER,c_inv_org_id IN NUMBER,c_inv_item_id IN NUMBER, c_inst_id IN NUMBER)
IS
SELECT DECODE(msib.asset_creation_code,'1','N','Y')
FROM   mtl_system_items_b msib
      ,csi_i_assets cia
WHERE  msib.organization_id = c_inv_org_id
AND    msib.inventory_item_id = c_inv_item_id
AND    cia.instance_id = c_inst_id
AND    cia.instance_asset_id = c_instance_asset_id;

BEGIN
    x_return_status := fnd_api.G_RET_STS_SUCCESS ;
  cse_asset_client_ext_stub.get_catchup_flag(p_asset_number,
                           p_instance_asset_id,
                           l_catchup_flag,
                           x_hook_used,
                           x_error_msg);
  IF x_hook_used = 1
  THEN
     ----x_catchup_flag is already set by client ext.
     x_catchup_flag := l_catchup_flag;
  ELSE
     OPEN catchup_cur (p_instance_asset_id,
                       p_asset_attrib_rec.inv_master_organization_id,
         p_asset_attrib_rec.inventory_item_id,
         p_asset_attrib_rec.instance_id);
     FETCH catchup_cur  INTO l_catchup_flag ;
     CLOSE catchup_cur ;
     x_catchup_flag := l_catchup_flag ;
  END IF ; ---Hook Used

END get_catchup_dep_flag ;

--------------------------------------------------------------------------------


  PROCEDURE get_txn_class (
    p_asset_attrib_rec  IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
    x_transaction_class OUT NOCOPY VARCHAR2,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_error_msg        OUT NOCOPY VARCHAR2)
  IS
    x_hook_used        NUMBER ;
    l_txn_type         VARCHAR2(30);
    e_error            EXCEPTION;
    l_api_name          VARCHAR2(100) ;
    l_asset_creation_code    VARCHAR2(1);
    l_redeploy_flag          VARCHAR2(1);
    l_inventory_item_id      NUMBER ;
    l_serial_number          VARCHAR2(30);
    l_transaction_date       DATE ;
    L_PRIMARY_QTY  NUMBER ;


    CURSOR item_type_cur(c_inv_org_id IN NUMBER,c_inv_item_id IN NUMBER) IS
      SELECT NVL(msib.asset_creation_code,'~')
      FROM   mtl_system_items_b   msib
      WHERE  msib.organization_id = c_inv_org_id
      AND    msib.inventory_item_id = c_inv_item_id;


    CURSOR item_qty_cur(c_mmt_id IN  NUMBER, c_inv_id IN NUMBER) IS
      SELECT mmt.primary_quantity
      FROM   mtl_material_transactions   mmt
      WHERE  mmt.transaction_id = c_mmt_id
      AND    mmt.inventory_item_id = c_inv_id ;

    CURSOR csi_sub_type_cur (c_transaction_id IN NUMBER) IS
      SELECT ctst.src_change_owner
      FROM   csi_t_txn_line_details cttld,
             csi_ib_txn_types ctst
      WHERE  cttld.source_transaction_flag = 'Y'
      AND    cttld.csi_transaction_id = c_transaction_id
      AND    cttld.sub_type_id = ctst.sub_type_id;

    l_change_owner_flag VARCHAR2(1);

  BEGIN
    l_api_name := 'CSE_ASSET_UTIL_PKG.check_txn_class';

    x_return_status := fnd_api.G_RET_STS_SUCCESS ;

    l_txn_type := p_asset_attrib_rec.source_transaction_type ;

    OPEN item_type_cur(p_asset_attrib_rec.inv_master_organization_id, p_asset_attrib_rec.inventory_item_id) ;
    FETCH item_type_cur INTO l_asset_creation_code;

    CLOSE item_type_cur ;

    OPEN item_qty_cur(p_asset_attrib_rec.inv_material_transaction_id, p_asset_attrib_rec.inventory_item_id);
    FETCH item_qty_cur INTO l_primary_qty; /*BNARAYAN FOR R12*/
    CLOSE item_qty_cur;

    l_serial_number := p_asset_attrib_rec.serial_number ;
    l_redeploy_flag := 'N' ;
    IF l_serial_number IS NULL THEN
       -- redeployment is supported only for serialized items
       l_redeploy_flag := 'N' ;
    ELSE
      cse_util_pkg.get_redeploy_flag(
        p_inventory_item_id => p_asset_attrib_rec.inventory_item_id,
        p_serial_number     => p_asset_attrib_rec.serial_number,
        p_transaction_date  => p_asset_attrib_rec.transaction_date,
        x_redeploy_flag     => l_redeploy_flag,
        x_return_status     => x_return_status,
        x_error_message     => x_error_msg);

      IF x_return_status <> fnd_api.G_RET_STS_SUCCESS THEN
        RAISE e_error ;
      END IF ;
    END  IF ; --l_serial_number IS NULL
    ---For Redeployement

    IF l_txn_type IN  ('PO_RECEIPT_INTO_INVENTORY'
                       ,'PO_RECEIPT_INTO_PROJECT'
                       ,'MISC_RECEIPT'
                       ,'PHYSICAL_INVENTORY'
                       ,'CYCLE_COUNT'
                       ,'RMA_RECEIPT'
                       ,'WIP_ASSEMBLY_COMPLETION'
                       ,'ACCT_RECEIPT'
                       ,'ACCT_ALIAS_RECEIPT')
    THEN
      IF l_asset_creation_code = '1' THEN
        IF l_redeploy_flag = 'N' THEN
          IF l_primary_qty < 0 THEN
            x_transaction_class := G_ADJUST_TXN_CLASS ;
          ELSE
            x_transaction_class := G_RECEIPT_TXN_CLASS ;
          END IF ;
        ELSE --l_redelploy='Y'
          x_transaction_class := G_MOVE_TXN_CLASS ;
        END IF ; --l_redeploy_flag
      ELSIF l_redeploy_flag = 'Y' THEN
        x_transaction_class := G_MOVE_TXN_CLASS ;
      END IF ;
    ELSIF l_txn_type IN('ISSUE_TO_HZ_LOC' ,'MISC_ISSUE_HZ_LOC') THEN
      IF l_asset_creation_code = '1' OR l_redeploy_flag = 'Y' THEN
        x_transaction_class := G_MOVE_TXN_CLASS ;
      ELSIF l_asset_creation_code <> '1' THEN
        x_transaction_class := G_RECEIPT_TXN_CLASS ;
      END IF ;
    ELSIF l_txn_type IN ('ITEM_MOVE'
                         ,'SUBINVENTORY_TRANSFER'
                         ,'INTERORG_TRANSFER'
                         ,'INTERORG_TRANS_SHIPMENT'
                         ,'INTERORG_TRANS_RECEIPT'
                         ,'ISO_SHIPMENT'
                         ,'ISO_REQUISITION_RECEIPT'
                         ,'ISSUE_TO_HZ_LOC'
                         ,'MISC_ISSUE_HZ_LOC'
                         ,'RECEIPT_HZ_LOC'
                         ,'MISC_RECEIPT_HZ_LOC'
                         ,'WIP_ISSUE'
                         ,'WIP_RECEIPT'
                         ,'RMA_RECEIPT'
                         ,'PROJECT_BORROW'
                         ,'PROJECT_TRANSFER'
                         ,'PROJECT_PAYBACK'
                         ,'SALES_ORDER_PICK'
                         ,'CYCLE_COUNT_TRANSFER'
                         ,'INTERORG_DIRECT_SHIP'
                         ,'ISO_PICK'
                         ,'PROJECT_ITEM_IN_SERVICE'
                         ,'PROJECT_ITEM_INSTALLED'
                         ,'PROJECT_ITEM_UNINSTALLED'
                         ,'MISC_ISSUE_TO_PROJECT'
                         ,'OM_SHIPMENT'
                         ,'MISC_RECEIPT_FROM_PROJECT'
                         ,'MOVE_ORDER_ISSUE_TO_PROJECT')
    THEN
      IF l_asset_creation_code = '1' OR l_redeploy_flag = 'Y' THEN
        IF l_txn_type = 'OM_SHIPMENT' THEN
          l_change_owner_flag := 'Y' ;
           OPEN csi_sub_type_cur(p_asset_attrib_rec.transaction_id) ;
           FETCH csi_sub_type_cur INTO l_change_owner_flag ;
           CLOSE csi_sub_type_cur ;

          IF l_change_owner_flag = 'N' THEN
            x_transaction_class := G_MOVE_TXN_CLASS ;
          ELSE
            x_transaction_class := G_ADJUST_TXN_CLASS ;
          END IF ;
        ELSE --l_txn_type = 'OM_SHIPMENT'
          x_transaction_class := G_MOVE_TXN_CLASS ;
        END IF ; --l_txn_type = 'OM_SHIPMENT'
      END IF ; --l_asset_creation_code = '1' OR l_redeploy_flag = 'Y'
    ELSIF l_txn_type IN (   'MISC_ISSUE'
                           ,'ACCT_ISSUE'
                           ,'ACCT_ALIAS_ISSUE'
                           ,'RETURN_TO_VENDOR'
                           ,'INT_REQ_RCPT_ADJUSTMENT'
                           ,'SHIPMENT_RCPT_ADJUSTMENT'
                           ,'OKE_SHIPMENT'
                           ,'OM_SHIPMENT'
                           ,'ISO_ISSUE'
                           ,'MISC_RECEIPT_HZ_LOC'
                           ,'RECEIPT_HZ_LOC')
    THEN
      IF l_txn_type NOT IN ('MISC_RECEIPT_HZ_LOC' ,'RECEIPT_HZ_LOC') THEN
        IF (l_asset_creation_code = '1' OR l_redeploy_flag = 'Y') THEN
          IF l_serial_number IS NOT NULL
              AND
             l_txn_type IN ( 'MISC_ISSUE', 'ACCT_ISSUE', 'ACCT_ALIAS_ISSUE')
          THEN
            x_transaction_class := G_MOVE_TXN_CLASS ;
          ELSE
            x_transaction_class := G_ADJUST_TXN_CLASS ;
          END IF ;
        END IF ;
      ELSIF l_txn_type IN ('MISC_RECEIPT_HZ_LOC', 'RECEIPT_HZ_LOC')
            AND
            l_asset_creation_code <> 1 AND l_serial_number IS NULL
      THEN
        x_transaction_class := G_ADJUST_TXN_CLASS ;
      END IF ;

    ELSIF l_txn_type IN ('OUT_OF_SERVICE' ,'IN_SERVICE') THEN
      x_transaction_class := G_MISC_MOVE_TXN_CLASS ;
    ELSIF l_txn_type = 'IPV_ADJUSTMENT_TO_FA' THEN
      x_transaction_class := G_IPV_TXN_CLASS ;
    ELSE
      x_transaction_class := 'NONE' ;
    END IF ;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_message.set_name('CSE','CSE_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME',l_api_name);
      fnd_message.set_token('SQL_ERROR',SQLERRM);
      x_error_msg := fnd_message.get;
  END get_txn_class ;

-------------------------------------------------------------------------------
--       Procedure/Function  Name : validate_inst_asset
--       Description   : validates if the instance is already associated with the Fixed Asset
-------------------------------------------------------------------------

/* bnarayan added for R12 */
PROCEDURE validate_inst_asset (p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
          X_valid        OUT NOCOPY    VARCHAR2,
          X_return_status OUT NOCOPY    VARCHAR2,
          x_error_msg        OUT NOCOPY VARCHAR2)
IS
l_inv_subinventory_name VARCHAR2(10);
l_inv_organization_id   NUMBER ;
l_instance_id NUMBER;
l_api_name VARCHAR2(100) := 'CSE_ASSET_UTIL_PKG.validate_inst_asset' ;
l_valid varchar(1);



 CURSOR c_get_asset_subinventory IS
 SELECT 'N' from mtl_secondary_inventories msi , csi_item_instances cii
 WHERE msi.asset_inventory=1
 AND msi.secondary_inventory_name=l_inv_subinventory_name
 AND msi.organization_id=cii.inv_organization_id
 AND msi.organization_id= l_inv_organization_id
 AND cii.instance_id=l_instance_id;

 CURSOR c_instance_capitalizes IS
 SELECT 'N' from csi_i_assets
 WHERE instance_id=l_instance_id
 AND (active_end_date >SYSDATE OR  active_end_date IS NULL );

 CURSOR c_instance_norm is
 SELECT 'N' from csi_item_instances
 WHERE (pa_project_id IS NOT NULL OR
       last_pa_project_id IS NOT NULL)
 AND    instance_id =l_instance_id
 AND   (active_end_date >SYSDATE OR  active_end_date IS NULL );


BEGIN
l_inv_subinventory_name := p_asset_attrib_rec.subinventory_name ;
l_inv_organization_id   := p_asset_attrib_rec.organization_id;
l_instance_id  := p_asset_attrib_rec.instance_id;
l_valid                 :='E';
X_Valid :='Y';
 x_return_status := fnd_api.G_RET_STS_SUCCESS ;
   OPEN c_get_asset_subinventory ;
   FETCH c_get_asset_subinventory INTO l_valid  ;
   CLOSE c_get_asset_subinventory ;

   IF (nvl(l_valid,'Y') = 'N') THEN
      x_valid :='N';
   ELSE
 OPEN c_instance_capitalizes ;
 FETCH c_instance_capitalizes INTO l_valid  ;
 CLOSE c_instance_capitalizes ;
 IF (nvl(l_valid,'Y') = 'N') THEN
     x_valid :='N';
 ELSE
    OPEN c_instance_norm ;
 FETCH c_instance_norm INTO l_valid  ;
 CLOSE c_instance_norm ;
 IF (nvl(l_valid,'Y') = 'N') THEN
   x_valid :='N';
    END IF;
    END IF;
   END IF;
EXCEPTION
WHEN OTHERS
THEN
  x_return_status := FND_API.G_RET_STS_ERROR ;
  fnd_message.set_name('CSE','CSE_UNEXP_SQL_ERROR');
  fnd_message.set_token('API_NAME',l_api_name);
  fnd_message.set_token('SQL_ERROR',SQLERRM);
  x_error_msg := fnd_message.get;

END validate_inst_asset;


  PROCEDURE insert_mass_add(
    p_api_version          IN          NUMBER,
    p_commit               IN          VARCHAR2,
    p_init_msg_list        IN          VARCHAR2,
    p_mass_add_rec         IN OUT NOCOPY      fa_mass_additions%ROWTYPE,
    x_return_status        OUT NOCOPY         VARCHAR2,
    x_msg_count            OUT NOCOPY         NUMBER,
    x_msg_data             OUT NOCOPY         VARCHAR2 )
  IS
    x_error_msg VARCHAR2(2000);
    l_api_name VARCHAR2(100) := 'CSE_ASSET_UTIL_PKG.insert_mass_add' ;

    l_fixed_assets_cost NUMBER ;
    l_payables_cost     NUMBER ;
    l_unrevalued_cost   NUMBER ;

    l_deprn_calendar VARCHAR2(15);
    l_dep_date DATE;

    l_last_dep_run_date DATE;
    l_period_name VARCHAR2(15);

    CURSOR c_curr_dep_prd (c_book_type_code IN varchar) IS
    Select	dp.period_name,
		bc.last_deprn_run_date,
		bc.deprn_calendar
	from	fa_deprn_periods dp,
		fa_deprn_periods dp2,
		fa_deprn_periods dp3,
		fa_book_controls bc
	where	dp.book_type_code =c_book_type_code
	and	dp.period_close_date is null
	and	dp2.book_type_code(+) = bc.distribution_source_book
	and	dp2.period_counter(+) = bc.last_mass_copy_period_counter
	and	dp3.book_type_code(+) = bc.book_type_code
	and	dp3.period_counter(+) = bc.last_purge_period_counter
	and     bc.book_type_code = c_book_type_code;

      CURSOR c_dep_date (c_calendar_type in varchar,  c_book_type_code IN varchar, c_period_name in varchar) IS
       SELECT END_DATE
       FROM FA_CALENDAR_PERIODS FAP,
            fa_book_controls FAC
       WHERE FAP.calendAr_type=c_calendar_type
       AND FAC.BOOk_TYPE_CODE =c_book_type_code
       AND FAP.PERIOD_NAME=c_period_name;

  BEGIN
    x_return_status := fnd_api.G_RET_STS_SUCCESS ;

    SELECT fa_mass_additions_s.nextval
    INTO p_mass_add_rec.mass_addition_id
    FROM SYS.DUAL ;

    debug('inside api insert_mass_add');

    SELECT ROUND(p_mass_add_rec.fixed_assets_cost,2) ,
           ROUND(p_mass_add_rec.payables_cost,2),
           ROUND(p_mass_add_rec.unrevalued_cost,2)
    INTO   l_fixed_assets_cost,
           l_payables_cost,
           l_unrevalued_cost
    FROM SYS.dual ;

    BEGIN
        OPEN   c_curr_dep_prd(p_mass_add_rec.book_type_code);
        FETCH  c_curr_dep_prd INTO l_period_name,  l_last_dep_run_date,l_deprn_calendar ;
        CLOSE  c_curr_dep_prd ;
     EXCEPTION
     WHEN others then
     NULL;
     END;

     IF (l_period_name is not  null) THEN
	BEGIN
	OPEN  c_dep_date(l_deprn_calendar,p_mass_add_rec.book_type_code,l_period_name);
	FETCH c_dep_date INTO l_dep_date ;
	CLOSE c_dep_date ;
	EXCEPTION
	WHEN others then
	NULL;
	END;
     END IF;

     IF TRUNC(p_mass_add_rec.date_placed_in_service) > TRUNC(l_dep_date) THEN
        p_mass_add_rec.transaction_date :=p_mass_add_rec.date_placed_in_service;
        p_mass_add_rec.TRANSACTION_TYPE_CODE:='FUTURE ADD';
     END IF;

    INSERT INTO fa_mass_additions(
      mass_addition_id,
      asset_number,
      tag_number,
      description,
      asset_category_id,
      manufacturer_name,
      serial_number,
      model_number,
      book_type_code,
      date_placed_in_service,
      fixed_assets_cost,
      payables_units,
      fixed_assets_units,
      payables_code_combination_id,
      expense_code_combination_id,
      location_id,
      assigned_to ,
      feeder_system_name,
      create_batch_date,
      create_batch_id,
      last_update_date,
      last_updated_by,
      reviewer_comments,
      invoice_number,
      vendor_number,
      po_vendor_id,
      po_number,
      posting_status,
      queue_name,
      invoice_date,
      invoice_created_by,
      invoice_updated_by ,
      payables_cost,
      invoice_id,
      payables_batch_name,
      depreciate_flag,
      parent_mass_addition_id ,
      parent_asset_id,
      split_merged_code,
      ap_distribution_line_number,
      post_batch_id,
      add_to_asset_id,
      amortize_flag,
      new_master_flag,
      asset_key_ccid,
      asset_type,
      deprn_reserve,
      ytd_deprn,
      beginning_nbv,
      created_by,
      creation_date,
      last_update_login,
      salvage_value,
      accounting_date,
      unit_of_measure,
      unrevalued_cost,
      ytd_reval_deprn_expense,
      merged_code,
      split_code,
      merge_parent_mass_additions_id,
      split_parent_mass_additions_id,
      project_asset_line_id,
      project_id,
      task_id,
      sum_units,
      dist_name,
      inventorial,
      short_fiscal_year_flag,
      conversion_date,
      original_deprn_start_date,
      group_asset_id,
      cua_parent_hierarchy_id,
      units_to_adjust,
      bonus_ytd_deprn,
      bonus_deprn_reserve,
      amortize_nbv_flag,
      amortization_start_date,
      attribute14,
      TRANSACTION_DATE,
      TRANSACTION_TYPE_CODE,
      po_distribution_id)
    VALUES(
      p_mass_add_rec.mass_addition_id ,
      p_mass_add_rec.asset_number,
      p_mass_add_rec.tag_number,
      p_mass_add_rec.description,
      p_mass_add_rec.asset_category_id,
      p_mass_add_rec.manufacturer_name,
      p_mass_add_rec.serial_number,
      p_mass_add_rec.model_number,
      p_mass_add_rec.book_type_code,
      p_mass_add_rec.date_placed_in_service,
      l_fixed_assets_cost,
      p_mass_add_rec.payables_units,
      p_mass_add_rec.fixed_assets_units,
      p_mass_add_rec.payables_code_combination_id,
      p_mass_add_rec.expense_code_combination_id,
      p_mass_add_rec.location_id,
      p_mass_add_rec.assigned_to ,
      p_mass_add_rec.feeder_system_name,
      p_mass_add_rec.create_batch_date,
      p_mass_add_rec.create_batch_id,
      p_mass_add_rec.last_update_date,
      p_mass_add_rec.last_updated_by,
      p_mass_add_rec.reviewer_comments,
      p_mass_add_rec.invoice_number,
      p_mass_add_rec.vendor_number,
      p_mass_add_rec.po_vendor_id,
      p_mass_add_rec.po_number,
      p_mass_add_rec.posting_status,
      p_mass_add_rec.queue_name,
      p_mass_add_rec.invoice_date,
      p_mass_add_rec.invoice_created_by,
      p_mass_add_rec.invoice_updated_by ,
      l_payables_cost,
      p_mass_add_rec.invoice_id,
      p_mass_add_rec.payables_batch_name,
      p_mass_add_rec.depreciate_flag,
      p_mass_add_rec.parent_mass_addition_id ,
      p_mass_add_rec.parent_asset_id,
      p_mass_add_rec.split_merged_code,
      p_mass_add_rec.ap_distribution_line_number,
      p_mass_add_rec.post_batch_id,
      p_mass_add_rec.add_to_asset_id,
      p_mass_add_rec.amortize_flag,
      p_mass_add_rec.new_master_flag,
      p_mass_add_rec.asset_key_ccid,
      p_mass_add_rec.asset_type,
      p_mass_add_rec.deprn_reserve,
      p_mass_add_rec.ytd_deprn,
      p_mass_add_rec.beginning_nbv,
      p_mass_add_rec.created_by,
      p_mass_add_rec.creation_date,
      p_mass_add_rec.last_update_login,
      p_mass_add_rec.salvage_value,
      p_mass_add_rec.accounting_date,
      p_mass_add_rec.unit_of_measure,
      l_unrevalued_cost,
      p_mass_add_rec.ytd_reval_deprn_expense,
      p_mass_add_rec.merged_code,
      p_mass_add_rec.split_code,
      p_mass_add_rec.merge_parent_mass_additions_id,
      p_mass_add_rec.split_parent_mass_additions_id,
      p_mass_add_rec.project_asset_line_id,
      p_mass_add_rec.project_id,
      p_mass_add_rec.task_id,
      p_mass_add_rec.sum_units,
      p_mass_add_rec.dist_name,
      p_mass_add_rec.inventorial,
      p_mass_add_rec.short_fiscal_year_flag,
      p_mass_add_rec.conversion_date,
      p_mass_add_rec.original_deprn_start_date,
      p_mass_add_rec.group_asset_id,
      p_mass_add_rec.cua_parent_hierarchy_id,
      p_mass_add_rec.units_to_adjust,
      p_mass_add_rec.bonus_ytd_deprn,
      p_mass_add_rec.bonus_deprn_reserve,
      p_mass_add_rec.amortize_nbv_flag,
      p_mass_add_rec.amortization_start_date ,
      p_mass_add_rec.attribute14,
      p_mass_add_rec.TRANSACTION_date,
      p_mass_add_rec.TRANSACTION_TYPE_CODE,
      p_mass_add_rec.po_distribution_id);

    IF p_commit = FND_API.G_TRUE THEN
      COMMIT ;
    END IF ;
  EXCEPTION
    WHEN OTHERS THEN
      x_error_msg := substr(sqlerrm,1,200) ;
      debug('SQL ERRM : '||x_error_msg);
       x_return_status := FND_API.G_RET_STS_ERROR ;
       x_msg_count     := 1;
      fnd_message.set_name('CSE','CSE_UNEXP_SQL_ERROR');
      fnd_message.set_token('API_NAME',l_api_name);
      fnd_message.set_token('SQL_ERROR',SQLERRM);
      x_msg_data := fnd_message.get;
  END insert_mass_add;


FUNCTION retire_non_mtl(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
  p_asset_id              IN        NUMBER,
  x_error_msg             OUT NOCOPY       VARCHAR2,
  x_return_status         OUT NOCOPY       VARCHAR2
) RETURN VARCHAR2
IS
x_retire_non_mtl_flag     VARCHAR2(1) ;
x_hook_used               NUMBER;
BEGIN
   x_return_status := fnd_api.G_RET_STS_SUCCESS ;
   cse_asset_client_ext_stub.get_non_mtl_retire_flag
                 ( p_asset_attrib_rec,
                  p_asset_id,
                  x_retire_non_mtl_flag,
                  x_hook_used,
                  x_error_msg);
   IF x_hook_used = 1
   THEN
      --do nothing as x_process_txn_flag is already set by the client ext.
      RETURN x_retire_non_mtl_flag;
   ELSE
      x_retire_non_mtl_flag := 'N' ;
   END IF ; ---x_hook_used
RETURN x_retire_non_mtl_flag;
EXCEPTION
WHEN OTHERS
THEN
   x_return_status := fnd_api.G_RET_STS_ERROR ;
END retire_non_mtl ;

-------------------------------------------------------------------------------
---           Validates if current transaction is OK to interface to FA
---           Rules : 1. There should NOT be any previous transaction PENDIG
---                      for any of the instances associated with the
---                      current transaction.
-------------------------------------------------------------------------------

PROCEDURE is_valid_to_process(
                  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
                  x_valid_to_process    OUT NOCOPY VARCHAR2,
                  x_return_status       OUT NOCOPY VARCHAR2,
                  x_error_msg           OUT NOCOPY VARCHAR2)
IS

CURSOR pending_txns_cur
IS
SELECT ct1.transaction_id,
       ct1.transaction_date
FROM   csi_item_instances_h  ciih1
      ,csi_transactions ct1
      ,csi_txn_types ctt
WHERE  ct1.transaction_id = ciih1.transaction_id
AND   ct1.transaction_type_id = ctt.transaction_type_id
AND    ct1.transaction_id <> p_asset_attrib_rec.transaction_id
----AS these transactions cannot be processed without the receipts,
---these don't qualify for this validation.
AND   ctt.source_transaction_type NOT IN ('INTERORG_TRANS_SHIPMENT',
'ISO_SHIPMENT')
AND    ciih1.instance_id IN (
         SELECT ciih.instance_id
         FROM   csi_item_instances_h  ciih,
                csi_transactions ct
         WHERE  ct.transaction_id = p_asset_attrib_rec.transaction_id
         AND    ciih.transaction_id = ct.transaction_id)
AND  ct1.transaction_status_code = 'PENDING' ;

/*CURSOR csi_txn_date_cur
IS
SELECT ct.transaction_date
FROM   csi_transactions ct
WHERE ct.transaction_id = p_transaction_id ;*/

l_transaction_id NUMBER ;
l_current_txn_date DATE ;

BEGIN

x_valid_to_process := 'Y' ;

/*OPEN csi_txn_date_cur ;
FETCH csi_txn_date_cur INTO l_current_txn_date ;
CLOSE csi_txn_date_cur ;*/

FOR pending_txns_rec IN pending_txns_cur
LOOP
  IF pending_txns_rec.transaction_date < p_asset_attrib_rec.transaction_date
  THEN
     x_valid_to_process := 'N' ;
     EXIT ;
  END IF ;
END LOOP;

debug('Transaction : '|| p_asset_attrib_rec.transaction_id ||' is valid to process ? :'|| x_valid_to_process);

END is_valid_to_process ;

  -------------------------------------------------------------------------------
  --  Derives Asset location based on
  --    1. Inventory Org and Subinventory OR
  --    2. Location ID and Location Type
  -------------------------------------------------------------------------------

  PROCEDURE get_fa_location(
    p_inst_loc_rec        IN cse_asset_util_pkg.inst_loc_rec,
    x_asset_location_id      OUT NOCOPY NUMBER,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_error_msg              OUT NOCOPY VARCHAR2 )
  IS

    l_sysdate                  DATE  := sysdate;
    l_location_type_code       VARCHAR2(30) ;
    l_location_id              NUMBER ;
    l_inv_subinventory_name    VARCHAR2(10);
    l_inv_organization_id      NUMBER ;

    l_msg_data                 VARCHAR2(2000);
    l_Msg_Count                NUMBER;
    l_Return_Status            VARCHAR2(1);
    l_Error_Message            VARCHAR2(2000);
    l_instance_rec             csi_datastructures_pub.instance_header_rec ;
    l_party_header_tbl         csi_datastructures_pub.party_header_tbl  ;
    l_account_header_tbl       csi_datastructures_pub.party_account_header_tbl ;
    l_org_header_tbl           csi_datastructures_pub.org_units_header_tbl ;
    l_pricing_attrib_tbl       csi_datastructures_pub.pricing_attribs_tbl ;
    l_ext_attrib_tbl           csi_datastructures_pub.extend_attrib_values_tbl ;
    l_ext_attrib_def_tbl       csi_datastructures_pub.extend_attrib_tbl ;
    l_asset_header_tbl         csi_datastructures_pub.instance_asset_header_tbl;
    l_time_stamp               date;

    CURSOR fa_location_cur IS
      SELECT cal.fa_location_id fa_location_id
      FROM   csi_a_locations cal
      WHERE  cal.location_id              = l_location_id
      AND    cal.location_table           = 'HR_LOCATIONS'
      AND    l_location_type_code         = 'INVENTORY'
      AND    NVL(cal.active_start_date,l_sysdate) <= l_sysdate
      AND    NVL(cal.active_end_date , l_sysdate) >= l_sysdate
      UNION
      SELECT cal.fa_location_id fa_location_id
      FROM   csi_a_locations cal
      WHERE  location_id  = l_location_id
      AND    l_location_type_code IN ('HZ_LOCATIONS', 'IN_TRANSIT', 'PROJECT') -- Modified for bug 8651868
      AND    cal.location_table IN ('HZ_LOCATIONS','LOCATION_CODES','HR_LOCATIONS')
      AND    NVL(cal.active_start_date,l_sysdate) <= l_sysdate
      AND    NVL(cal.active_end_date , l_sysdate) >= l_sysdate
      UNION
      SELECT cal.fa_location_id fa_location_id
      FROM   csi_a_locations cal
      WHERE  location_id  = l_location_id
      AND    l_location_type_code IN ('HR_LOCATIONS','INTERNAL_SITE')
      AND    cal.location_table IN ('HR_LOCATIONS')
      AND    NVL(cal.active_start_date,l_sysdate) <= l_sysdate
      AND    NVL(cal.active_end_date , l_sysdate) >= l_sysdate
      UNION
      SELECT cal.fa_location_id fa_location_id
      FROM   csi_a_locations cal,
             hz_party_sites hzps
      WHERE  hzps.location_id     = cal.location_id
      AND    hzps.party_site_id   = l_location_id       -- Modified for bug 4149685
      AND    l_location_type_code = 'HZ_PARTY_SITES'
      AND    cal.location_table IN ('HZ_LOCATIONS','LOCATION_CODES')
      AND    NVL(cal.active_start_date,l_sysdate) <= l_sysdate
      AND    NVL(cal.active_end_date , l_sysdate) >= l_sysdate  ;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success ;
    debug('Inside cse_asset_util_pkg.get_fa_location');

    x_asset_location_id := NULL ;

    debug('  p_rec.transaction_id       : '||p_inst_loc_rec.transaction_id);
    debug('  p_rec.location_type_code   : '||p_inst_loc_rec.location_type_code);
    debug('  p_rec.location_id          : '||p_inst_loc_rec.location_id);
    debug('  p_rec.inv_organization_id  : '||p_inst_loc_rec.inv_organization_id);
    debug('  p_rec.inv_subinv_name      : '||p_inst_loc_rec.inv_subinventory_name);

    l_location_id            := p_inst_loc_rec.location_id ;
    l_location_type_code     := p_inst_loc_rec.location_type_code ;
    l_inv_subinventory_name  := p_inst_loc_rec.inv_subinventory_name ;
    l_inv_organization_id    := p_inst_loc_rec.inv_organization_id ;

    IF l_location_type_code IS NULL OR l_location_id is null THEN

      l_instance_rec.instance_id := p_inst_loc_rec.instance_id ;

      debug('Calling csi_item_instance_pub.get_item_instance_details - '||l_instance_rec.instance_id);

      IF p_inst_loc_rec.transaction_id is not null THEN
        SELECT creation_date
        INTO   l_time_stamp
        FROM   csi_item_instances_h
        WHERE  transaction_id = p_inst_loc_rec.transaction_id
        AND    instance_id    = p_inst_loc_rec.instance_id;
      ELSE
       l_time_stamp := p_inst_loc_rec.transaction_date;
      END IF;

      debug('  time_stamp                 : '||to_char(l_time_stamp, 'dd-mon-yyyy hh24:mi:ss'));

      csi_item_instance_pub.get_item_instance_details(
        p_api_version           => 1.0,
        p_commit                => fnd_api.g_false,
        p_init_msg_list         => fnd_api.g_true,
        p_validation_level      => fnd_api.g_valid_level_full,
        p_instance_rec          => l_instance_rec,
        p_get_parties           => fnd_api.g_false,
        p_party_header_tbl      => l_party_header_tbl,
        p_get_accounts          => fnd_api.g_false,
        p_account_header_tbl    => l_account_header_tbl,
        p_get_org_assignments   => fnd_api.g_false,
        p_org_header_tbl        => l_org_header_tbl,
        p_get_pricing_attribs   => fnd_api.g_false,
        p_pricing_attrib_tbl    => l_pricing_attrib_tbl,
        p_get_ext_attribs       => fnd_api.g_false,
        p_ext_attrib_tbl        => l_ext_attrib_tbl,
        p_ext_attrib_def_tbl    => l_ext_attrib_def_tbl,
        p_get_asset_assignments => fnd_api.g_false,
        p_asset_header_tbl      => l_asset_header_tbl,
        p_resolve_id_columns    => fnd_api.g_false,
        p_time_stamp            => l_time_stamp,
        x_return_status         => l_return_status,
        x_msg_count             => l_msg_count,
        x_msg_data              => l_msg_data );

      IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
        l_error_message := cse_util_pkg.dump_error_stack;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_location_type_code IS NULL THEN
        l_location_type_code := l_instance_rec.location_type_code ;
      END IF ;

      IF l_location_id is NULL THEN
        l_location_id := l_instance_rec.location_id ;
      END IF ;

      IF l_location_type_code = 'INVENTORY' THEN

        IF l_inv_organization_id IS NULL THEN
          l_inv_organization_id := l_instance_rec.inv_organization_id ;
        END IF ;

        IF l_inv_subinventory_name IS NULL THEN
          l_inv_subinventory_name := l_instance_rec.inv_subinventory_name ;
        END IF ;
      END IF ; ---INVENTORY

    END IF ; ---get the missing parameters

    debug('  l_location_id              : '||l_location_id);
    debug('  l_location_type_code       : '||l_location_type_code);

    OPEN fa_location_cur ;
    FETCH fa_location_cur INTO x_asset_location_id ;
    CLOSE fa_location_cur ;

    debug('  x_asset_location_id        : '||x_asset_location_id);

    IF x_asset_location_id IS NULL THEN
      RAISE fnd_api.g_exc_error ;
    END IF ;

  EXCEPTION
    WHEN fnd_api.g_exc_error  THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_message.set_name('CSE','CSE_FA_CREATION_ATRIB_ERROR');
      fnd_message.set_token('ASSET_ATTRIBUTE','LOCATION');
      fnd_message.set_token('CSI_TRANSACTION_ID',p_inst_loc_rec.transaction_id);
      x_error_msg := fnd_message.get;
  END get_fa_location ;

-------------------------------------------------------------------------------
--   PROCEDURE get_unit_cost               ---
--  Derives Unit based on
--    1. Inventory Org and Item for Inventory txns such as Misc Receipt,
--    2. Rcv txns and PO info for PO Receipt transactions.
-------------------------------------------------------------------------------

PROCEDURE   get_unit_cost(
                          p_source_txn_type  IN VARCHAR2
                        , p_source_txn_id    IN NUMBER
                        , p_inventory_item_id IN NUMBER
                        , p_organization_id   IN NUMBER
                        , x_unit_cost        OUT NOCOPY NUMBER
                        , x_error_msg        OUT NOCOPY VARCHAR2
                        , x_return_status    OUT NOCOPY VARCHAR2)
IS
l_inventory_item_id         NUMBER ;
l_organization_id           NUMBER ;
l_primary_qty               NUMBER ;
l_po_unit_price             NUMBER ;
l_pla_uom_code              VARCHAR2(3);
l_primary_uom_code          VARCHAR2(3);

CURSOR rcv_txn_cur
IS
SELECT pla.unit_price    ---Unit Price for ONE UOM
      ,pla_muom.uom_code pla_uom_code
      ,rcv_muom.uom_code primary_uom_code
FROM   rcv_transactions rt
      ,po_lines_all pla
      ,mtl_units_of_measure pla_muom
      ,mtl_units_of_measure rcv_muom
WHERE  rt.transaction_id = p_source_txn_id
AND    rt.po_line_id = pla.po_line_id
AND    pla.unit_meas_lookup_code = pla_muom.unit_of_measure
AND    rt.primary_unit_of_measure = rcv_muom.unit_of_measure ;

BEGIN
   l_inventory_item_id := p_inventory_item_id ;
   l_organization_id := p_organization_id ;

   IF   p_source_txn_type = 'INV'
   THEN
      x_unit_cost := get_item_cost (
                          p_inventory_item_id => l_inventory_item_id
                        , p_organization_id      => l_organization_id );
    debug( ' Unit Price in Primary UOM is :'|| x_unit_cost);
   END IF ;  ---INV

   IF p_source_txn_type = 'PO'
   THEN
      OPEN rcv_txn_cur ;
      FETCH rcv_txn_cur INTO l_po_unit_price, l_pla_uom_code,
                             l_primary_uom_code  ;
      CLOSE rcv_txn_cur ;

      debug('PO Unit Price is :'|| l_po_unit_price ||
       ' In PO Lines UOM :'||l_pla_uom_code);

     l_primary_qty :=
        inv_convert.inv_um_convert(
          item_id       => l_inventory_item_id ,
          precision     => 6,
          from_quantity => 1,
          from_unit     => l_pla_uom_code ,
          to_unit       => l_primary_uom_code,
          from_name     => null,
          to_name       => null);
    debug('ONE :'||l_pla_uom_code ||' is '||
            l_primary_qty || ' in '||l_primary_uom_code);

   x_unit_cost :=  l_po_unit_price/l_primary_qty ;
    debug( ' Unit Price in Primary UOM:'||'('||l_primary_uom_code||') is : '|| x_unit_cost);

   END IF ;---PO

   -- Added error message for bug 4869653
   IF x_unit_cost IS NULL THEN
      debug( 'Unable to derive Cost for item : '||p_inventory_item_id ||' Org : '|| p_organization_id||' Source : '||p_source_txn_type||' ID '||p_source_txn_id);
      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_message.set_name('CSE','CSE_UNABLE_DERIVE_COST_ERROR');
      fnd_message.set_token('SOURCE_TYPE_CODE',p_source_txn_type);
      fnd_message.set_token('SOURCE_TYPE_ID',p_source_txn_id);
      x_error_msg := fnd_message.get;
   END IF;
   -- End error message for bug 4869653
END get_unit_cost ;

-------------------------------------------------------------------------------
----          is_valid_to_retire
----          Reference : FA_MASS_RET_PKG.check_addition_retirement
----          It checks if it is OK to retire the asset.
----          Fixed asset does not allow to retire the Assets , IF
----               1.If you try to retire the asset in the same period,
----                 in which it was created
-------------------------------------------------------------------------------
PROCEDURE is_valid_to_retire (p_asset_id IN NUMBER
                             ,p_book_type_code  IN VARCHAR2
                             ,x_valid_to_retire_flag OUT NOCOPY VARCHAR2
                             ,x_error_msg        OUT NOCOPY VARCHAR2
                             ,x_return_status    OUT NOCOPY VARCHAR2)
IS
l_api_name VARCHAR2(100) := 'CSE_ASSET_UTIL_PKG.is_valid_to_retire';

CURSOR check_current_period_add
IS
SELECT 'N'
FROM   fa_transaction_headers th,
       fa_book_controls bc,
       fa_deprn_periods dp
WHERE  th.asset_id = p_asset_id
  AND  th.book_type_code = p_book_type_code
  AND  bc.book_type_code = th.book_type_code
  AND  th.transaction_type_code||''
          = DECODE(bc.book_class,'CORPORATE','TRANSFER IN', 'ADDITION')
  AND th.date_effective BETWEEN dp.period_open_date
                             AND nvl(dp.period_close_date,sysdate)
  AND dp.book_type_code = th.book_type_code
  AND dp.period_close_date is NULL ;

BEGIN
  x_valid_to_retire_flag := 'Y' ;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  OPEN check_current_period_add ;
  FETCH check_current_period_add INTO x_valid_to_retire_flag ;
  CLOSE check_current_period_add ;

EXCEPTION
WHEN OTHERS
THEN
  x_return_status := FND_API.G_RET_STS_ERROR ;
  fnd_message.set_name('CSE','CSE_UNEXP_SQL_ERROR');
  fnd_message.set_token('API_NAME',l_api_name);
  fnd_message.set_token('SQL_ERROR',SQLERRM);
  x_error_msg := fnd_message.get;
END is_valid_to_retire ;


-------------------------------------------------------------------------------
----            Following process will identify the transaction action as
----            "Sale" or "Move" or "Rect" for Sales Order Transactions/RMA .
-------------------------------------------------------------------------------
PROCEDURE get_so_txn_action ( p_inst_txn_rec      IN  cse_asset_util_pkg.inst_txn_rec
                             ,x_fa_action        OUT NOCOPY VARCHAR2
                             ,x_error_msg        OUT NOCOPY VARCHAR2
                             ,x_return_status    OUT NOCOPY VARCHAR2
)
IS
BEGIN
    NULL ;
    ---get the txn details such as OWNERSHIP chnage for the given instance/txn.
    ---Sales Transaction:
       --- If  OWNERSHIP is Enterprise then it's "Move" transaction.
       --- If its ownership is  Other than Enterprise then it's a "Sale" transaction.
    ---RMA Transaction
       --- If the previous ownsership is Enterprise and New ownership is also Enterprise then it's "M" (Asset Move)
       --- If earlier ownership is customer then treat the ownership as "Enterprise"  it's "R" (Create Asset)
END get_so_txn_action ;

-------------------------------------------------------------------------------

  FUNCTION get_rcv_sub_ledger_id(p_rcv_transaction_id IN number) RETURN number
  IS
    l_entity_code           varchar2(30) := 'RCV_ACCOUNTING_EVENTS';
    l_application_id        number := 707;
    l_entity_id             number;
    l_ae_header_id          number;
    l_charge_account_id     number;
    l_sub_ledger_id         number := null;
  BEGIN
    -- put logic for the accrual at period end where we have to figure out the invoice's account id
    SELECT rcv_sub_ledger_id
    INTO   l_sub_ledger_id
    from   rcv_receiving_sub_ledger
    WHERE  rcv_transaction_id = p_rcv_transaction_id
    AND    accounting_line_type = 'Charge';

    return(l_sub_ledger_id);
  EXCEPTION
    WHEN no_data_found THEN
      return(l_sub_ledger_id);
  END get_rcv_sub_ledger_id;


  FUNCTION get_fa_period_name (
    p_book_type_code IN varchar2,
    p_dpis           IN date)
  RETURN varchar2 IS
    l_period_name varchar2(15);
  BEGIN

    SELECT fcp.period_name
    INTO   l_period_name
    FROM   fa_book_controls    fbc,
           fa_calendar_periods fcp
    WHERE  fbc.book_type_code   = p_book_type_code
    AND    fcp.calendar_type    = fbc.deprn_calendar
    AND    p_dpis BETWEEN fcp.start_date AND fcp.end_date;

    RETURN l_period_name;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN l_period_name;
    WHEN too_many_rows THEN
      RETURN l_period_name;
  END get_fa_period_name;

  FUNCTION get_ap_sla_acct_id(
    p_invoice_id         IN number,
    p_invoice_dist_type  IN varchar2)
  RETURN number
  IS
    l_entity_code        varchar2(30) := 'AP_INVOICES';
    l_application_id     number       := 200;
    l_acct_class_code    varchar2(30) := 'ACCRUAL';
    l_ledger_id          number;
    l_ccid               number := null;

    CURSOR sla_ccid_cur IS
      SELECT  xlael.code_combination_id
      FROM    xla_transaction_entities xlte,
              xla_ae_headers xlaeh,
              xla_ae_lines xlael
      WHERE   xlte.application_id         = l_application_id
      AND     xlte.entity_code            = l_entity_code
      AND     xlte.source_id_int_1        = p_invoice_id
      AND     xlaeh.ledger_id             = l_ledger_id
      AND     xlaeh.application_id        = xlte.application_id
      AND     xlaeh.entity_id             = xlte.entity_id
      and     xlael.application_id        = xlte.application_id
      AND     xlael.ae_header_id          = xlaeh.ae_header_id
      AND     xlael.accounting_class_code = l_acct_class_code;

  BEGIN

    xla_security_pkg.set_security_context(l_application_id);

    SELECT set_of_books_id
    INTO   l_ledger_id
    FROM   ap_system_parameters;

    IF p_invoice_dist_type = 'IPV' THEN
      l_acct_class_code := 'IPV';
    END IF;

    IF p_invoice_dist_type = 'FREIGHT' THEN -- added for bug 8927385
      l_acct_class_code := 'FREIGHT';
    END IF;

    IF p_invoice_dist_type = 'RTAX' THEN -- added for bug 8927385
      l_acct_class_code := 'RTAX';
    END IF;

    IF p_invoice_dist_type = 'NRTAX' THEN -- added for bug 8927385
      l_acct_class_code := 'NRTAX';
    END IF;

    OPEN  sla_ccid_cur;
    FETCH sla_ccid_cur INTO l_ccid;
    CLOSE sla_ccid_cur;

    RETURN l_ccid;

  END get_ap_sla_acct_id;

   PROCEDURE validate_ccid_required (x_asset_key_required out nocopy varchar2) IS

  l_asset_key_flex_struct  number;
  l_flexfield              fnd_flex_key_api.flexfield_type;
  l_structure              fnd_flex_key_api.structure_type;
  l_num_segments           number;
  l_segments               fnd_flex_key_api.segment_list;
  l_segment                fnd_flex_key_api.segment_type;

  l_asset_key_required     varchar2(1) := 'N';

  BEGIN

    SELECT asset_key_flex_structure
    INTO   l_asset_key_flex_struct
    FROM   fa_system_controls;

    fnd_flex_key_api.set_session_mode('seed_data');

    l_flexfield := fnd_flex_key_api.find_flexfield(
                     appl_short_name => 'OFA',
                     flex_code       => 'KEY#');

    l_structure := fnd_flex_key_api.find_structure(
                     flexfield        => l_flexfield,
                     structure_number => l_asset_key_flex_struct);

    fnd_flex_key_api.get_segments(
      flexfield     => l_flexfield,
      structure     => l_structure,
      enabled_only  => TRUE,
      nsegments     => l_num_segments,
      segments      => l_segments);

    l_asset_key_required := 'N';

    IF l_num_segments > 0 THEN
      FOR l_ind IN 1 .. l_num_segments
      LOOP
        l_segment := fnd_flex_key_api.find_segment(l_flexfield,l_structure,l_segments(l_ind));
        IF l_segment.required_flag = 'Y' AND l_segment.enabled_flag = 'Y' THEN
          l_asset_key_required := 'Y';
          exit;
        END IF;
      END LOOP;

    END IF;

    x_asset_key_required := l_asset_key_required;

  END validate_ccid_required;


END cse_asset_util_pkg;

/
