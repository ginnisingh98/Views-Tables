--------------------------------------------------------
--  DDL for Package Body CSE_IPA_TRANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_IPA_TRANS_PKG" AS
/*  $Header: CSEIPATB.pls 120.9 2006/06/09 00:45:25 brmanesh noship $ */

  l_debug varchar2(1) := nvl(fnd_profile.value('cse_debug_option'),'N');

  PROCEDURE debug(
    p_message IN varchar2)
  IS
  BEGIN
    IF l_debug = 'Y' THEN
      cse_debug_pub.add(p_message);
    END IF;
  EXCEPTION
    WHEN others THEN
      null;
  END debug;

  PROCEDURE populate_pa_interface(
    p_nl_pa_interface_tbl  IN  nl_pa_interface_tbl_type,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_error_message        OUT NOCOPY VARCHAR2)
  IS
    l_error_message        VARCHAR2(2000);
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    x_error_message := null;

    IF NOT p_nl_pa_interface_tbl.COUNT = 0 THEN
      FOR i IN p_nl_pa_interface_tbl.FIRST .. p_nl_pa_interface_tbl.LAST
      LOOP
        INSERT INTO pa_transaction_interface_all(
          transaction_source,
          batch_name,
          expenditure_ending_date,
          employee_number,
          organization_name,
          expenditure_item_date,
          project_number,
          task_number,
          expenditure_type,
          non_labor_resource,
          non_labor_resource_org_name,
          quantity,
          raw_cost,
          expenditure_comment,
          transaction_status_code,
          transaction_rejection_code,
          expenditure_id,
          orig_transaction_reference,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          raw_cost_rate,
          interface_id,
          unmatched_negative_txn_flag,
          expenditure_item_id,
          org_id,
          dr_code_combination_id,
          cr_code_combination_id,
          cdl_system_reference1,
          cdl_system_reference2,
          cdl_system_reference3,
          cdl_system_reference4,
          cdl_system_reference5,
          gl_date,
          burdened_cost,
          burdened_cost_rate,
          system_linkage,
          txn_interface_id,
          user_transaction_source,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          receipt_currency_amount,
          receipt_currency_code,
          receipt_exchange_rate,
          denom_currency_code,
          denom_raw_cost,
          denom_burdened_cost,
          acct_rate_date,
          acct_rate_type,
          acct_exchange_rate,
          acct_raw_cost,
          acct_burdened_cost,
          acct_exchange_rounding_limit,
          project_currency_code,
          project_rate_date,
          project_rate_type,
          project_exchange_rate,
          orig_exp_txn_reference1,
          orig_exp_txn_reference2,
          orig_exp_txn_reference3,
          orig_user_exp_txn_reference,
          vendor_number,
          override_to_organization_name,
          reversed_orig_txn_reference,
          billable_flag,
          person_business_group_name,
          net_zero_adjustment_flag,
          adjusted_expenditure_item_id,
          organization_id,
          inventory_item_id,
          po_number,
          po_header_id,
          po_line_num,
          po_line_id,
          vendor_id,
          project_id,
          task_id,
          document_type,
          document_distribution_type)
        VALUES(
          p_nl_pa_interface_tbl(i).transaction_source,
          p_nl_pa_interface_tbl(i).batch_name,
          p_nl_pa_interface_tbl(i).expenditure_ending_date,
          p_nl_pa_interface_tbl(i).employee_number,
          p_nl_pa_interface_tbl(i).organization_name,
          p_nl_pa_interface_tbl(i).expenditure_item_date,
          p_nl_pa_interface_tbl(i).project_number,
          p_nl_pa_interface_tbl(i).task_number,
          p_nl_pa_interface_tbl(i).expenditure_type,
          p_nl_pa_interface_tbl(i).non_labor_resource,
          p_nl_pa_interface_tbl(i).non_labor_resource_org_name,
          p_nl_pa_interface_tbl(i).quantity,
          p_nl_pa_interface_tbl(i).raw_cost,
          p_nl_pa_interface_tbl(i).expenditure_comment,
          p_nl_pa_interface_tbl(i).transaction_status_code,
          p_nl_pa_interface_tbl(i).transaction_rejection_code,
          p_nl_pa_interface_tbl(i).expenditure_id,
          p_nl_pa_interface_tbl(i).orig_transaction_reference,
          p_nl_pa_interface_tbl(i).attribute_category,
          p_nl_pa_interface_tbl(i).attribute1,
          p_nl_pa_interface_tbl(i).attribute2,
          p_nl_pa_interface_tbl(i).attribute3,
          p_nl_pa_interface_tbl(i).attribute4,
          p_nl_pa_interface_tbl(i).attribute5,
          p_nl_pa_interface_tbl(i).attribute6,
          p_nl_pa_interface_tbl(i).attribute7,
          p_nl_pa_interface_tbl(i).attribute8,
          p_nl_pa_interface_tbl(i).attribute9,
          p_nl_pa_interface_tbl(i).attribute10,
          p_nl_pa_interface_tbl(i).raw_cost_rate,
          p_nl_pa_interface_tbl(i).interface_id,
          p_nl_pa_interface_tbl(i).unmatched_negative_txn_flag,
          p_nl_pa_interface_tbl(i).expenditure_item_id,
          p_nl_pa_interface_tbl(i).org_id,
          p_nl_pa_interface_tbl(i).dr_code_combination_id,
          p_nl_pa_interface_tbl(i).cr_code_combination_id,
          p_nl_pa_interface_tbl(i).cdl_system_reference1,
          p_nl_pa_interface_tbl(i).cdl_system_reference2,
          p_nl_pa_interface_tbl(i).cdl_system_reference3,
          p_nl_pa_interface_tbl(i).cdl_system_reference4,
          p_nl_pa_interface_tbl(i).cdl_system_reference5,
          p_nl_pa_interface_tbl(i).gl_date,
          p_nl_pa_interface_tbl(i).burdened_cost,
          p_nl_pa_interface_tbl(i).burdened_cost_rate,
          p_nl_pa_interface_tbl(i).system_linkage,
          p_nl_pa_interface_tbl(i).txn_interface_id,
          p_nl_pa_interface_tbl(i).user_transaction_source,
          p_nl_pa_interface_tbl(i).created_by,
          p_nl_pa_interface_tbl(i).creation_date,
          p_nl_pa_interface_tbl(i).last_updated_by,
          p_nl_pa_interface_tbl(i).last_update_date,
          p_nl_pa_interface_tbl(i).receipt_currency_amount,
          p_nl_pa_interface_tbl(i).receipt_currency_code,
          p_nl_pa_interface_tbl(i).receipt_exchange_rate,
          p_nl_pa_interface_tbl(i).denom_currency_code,
          p_nl_pa_interface_tbl(i).denom_raw_cost,
          p_nl_pa_interface_tbl(i).denom_burdened_cost,
          p_nl_pa_interface_tbl(i).acct_rate_date,
          p_nl_pa_interface_tbl(i).acct_rate_type,
          p_nl_pa_interface_tbl(i).acct_exchange_rate,
          p_nl_pa_interface_tbl(i).acct_raw_cost,
          p_nl_pa_interface_tbl(i).acct_burdened_cost,
          p_nl_pa_interface_tbl(i).acct_exchange_rounding_limit,
          p_nl_pa_interface_tbl(i).project_currency_code,
          p_nl_pa_interface_tbl(i).project_rate_date,
          p_nl_pa_interface_tbl(i).project_rate_type,
          p_nl_pa_interface_tbl(i).project_exchange_rate,
          p_nl_pa_interface_tbl(i).orig_exp_txn_reference1,
          p_nl_pa_interface_tbl(i).orig_exp_txn_reference2,
          p_nl_pa_interface_tbl(i).orig_exp_txn_reference3,
          p_nl_pa_interface_tbl(i).orig_user_exp_txn_reference,
          p_nl_pa_interface_tbl(i).vendor_number,
          p_nl_pa_interface_tbl(i).override_to_organization_name,
          p_nl_pa_interface_tbl(i).reversed_orig_txn_reference,
          p_nl_pa_interface_tbl(i).billable_flag,
          p_nl_pa_interface_tbl(i).person_business_group_name,
          p_nl_pa_interface_tbl(i).net_zero_adjustment_flag,
          p_nl_pa_interface_tbl(i).adjusted_expenditure_item_id,
          p_nl_pa_interface_tbl(i).organization_id,
          p_nl_pa_interface_tbl(i).inventory_item_id,
          p_nl_pa_interface_tbl(i).po_number,
          p_nl_pa_interface_tbl(i).po_header_id,
          p_nl_pa_interface_tbl(i).po_line_num,
          p_nl_pa_interface_tbl(i).po_line_id,
          p_nl_pa_interface_tbl(i).vendor_id,
          p_nl_pa_interface_tbl(i).project_id,
          p_nl_pa_interface_tbl(i).task_id,
          p_nl_pa_interface_tbl(i).document_type,
          p_nl_pa_interface_tbl(i).document_distribution_type);

      END LOOP;
    END IF;

  EXCEPTION
    WHEN others THEN
      fnd_message.set_name('CSE','CSE_OTHERS_EXCEPTION');
      fnd_message.set_token('ERR_MSG', sqlerrm);
      l_error_message := fnd_message.get;
      x_error_message := l_error_message;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END populate_pa_interface;

  PROCEDURE get_fa_asset_category (
    p_item_id              IN     NUMBER,
    p_inv_master_org_id    IN     NUMBER,
    p_transaction_id       IN     NUMBER,
    x_asset_category_id    OUT NOCOPY    NUMBER,
    x_asset_category       OUT NOCOPY    VARCHAR2,
    x_return_status        OUT NOCOPY    VARCHAR2,
    x_error_message        OUT NOCOPY    VARCHAR2)
  IS
    l_asset_category_id    number;
    l_asset_attrib_rec     cse_datastructures_pub.asset_attrib_rec ;
    l_con_asset_category   varchar2(150);
    l_asset_category       varchar2(150);
    l_cat_book_assigned    varchar2(1);
    l_book_type_code       varchar2(80);
    l_hook_used            number;

    l_return_status        varchar2(1);
    l_error_message        varchar2(2000);


  BEGIN

    x_return_status     := fnd_api.g_ret_sts_success;
    x_error_message     := null;
    x_asset_category_id := null;

    l_asset_attrib_rec.transaction_id    := p_transaction_id ;
    l_asset_attrib_rec.inventory_item_id := p_item_id ;

    cse_asset_client_ext_stub.get_asset_category(
      p_asset_attrib_rec => l_asset_attrib_rec,
      x_hook_used        => l_hook_used,
      x_error_msg        => l_error_message);

    l_asset_category_id :=  l_asset_attrib_rec.asset_category_id ;

    IF l_hook_used <> 1 THEN

      SELECT asset_category_id
      INTO   l_asset_category_id
      FROM   mtl_system_items
      WHERE  inventory_item_id = p_item_id
      AND    organization_id   = p_inv_master_org_id;

    END IF;

    IF l_asset_category_id is null THEN
      fnd_message.set_name('CSE', 'CSE_ASSET_CAT_ERROR');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error ;
    END IF;

    debug('  asset_category_id      : '||l_asset_category_id);

    cse_util_pkg.get_concat_segments(
      p_short_name      => 'OFA',
      p_flex_code       => 'CAT#',
      p_combination_id  => l_asset_category_id,
      x_concat_segments => l_con_asset_category,
      x_return_status   => l_return_status,
      x_error_message   => l_error_message);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error ;
    END IF;

    debug('  asset_category         : '||l_con_asset_category);

    l_book_type_code := fnd_profile.value('CSE_FA_BOOK_TYPE_CODE');

    debug('  book_type_code         : '||l_book_type_code);

    BEGIN
      SELECT 'Y' INTO l_cat_book_assigned
      FROM   sys.dual
      WHERE  EXISTS (
       SELECT 1 FROM fa_category_books
       WHERE  category_id     = l_asset_category_id
       AND    book_type_code  = l_book_type_code);
    EXCEPTION
      WHEN no_data_found THEN
        fnd_message.set_name('CSE', 'CSE_ASSET_BOOK_CAT_UNDEFINED');
        fnd_message.set_token('ASSET_CAT', l_con_asset_category);
        fnd_message.set_token('BOOK_TYPE_CODE', l_book_type_code);
        fnd_msg_pub.add;
    END;

    -- removes the delimiter
    cse_util_pkg.get_combine_segments(
      p_short_name        => 'OFA',
      p_flex_code         => 'CAT#',
      p_concat_segments   => l_con_asset_category,
      x_combine_segments  => l_asset_category,
      x_return_status     => l_return_status,
      x_error_message     => l_error_message);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error ;
    END IF;

    x_asset_category_id := l_asset_category_id;
    x_asset_category    := l_asset_category;

  EXCEPTION

    WHEN fnd_api.g_exc_error THEN
      x_error_message  := nvl(l_error_message, cse_util_pkg.dump_error_stack);
      x_return_status  := l_return_status;

    WHEN OTHERS THEN
      fnd_message.set_name('CSE','CSE_OTHERS_EXCEPTION');
      fnd_message.set_token('ERR_MSG', sqlerrm);
      fnd_msg_pub.add;
      x_error_message := cse_util_pkg.dump_error_stack;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END get_fa_asset_category;

  PROCEDURE get_fa_location_segment (
    p_fa_location_id     IN  NUMBER,
    p_transaction_id     IN  NUMBER,
    x_fa_location        OUT NOCOPY VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_error_message      OUT NOCOPY VARCHAR2)
  IS
    l_Hook_Used            NUMBER;
    l_con_fa_location      VARCHAR2(150);
    l_return_status        VARCHAR2(1);
    l_Error_Message        VARCHAR2(2000);
    l_location_id          NUMBER;
    asset_loc_exp          EXCEPTION;
    l_asset_attrib_rec cse_datastructures_pub.asset_attrib_rec ;
  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    x_error_message := null;

    l_location_id := NULL;
    l_asset_attrib_rec.transaction_id  := p_transaction_id ;

    --call client extension
    cse_asset_client_ext_stub.get_asset_location(
      p_asset_attrib_rec      => l_asset_attrib_rec,
      x_hook_used             => l_hook_used,
      x_error_msg             => l_error_message ) ;

    l_location_id := l_asset_attrib_rec.location_id ;

    IF l_hook_used <> 1  THEN
      l_location_id:=p_fa_location_id ;
    END IF;

    --get the concatenated segments from fa_location_id
    cse_util_pkg.get_concat_segments(
      p_short_name      => 'OFA',
      p_flex_code       => 'LOC#',
      p_combination_id  => l_location_id,
      X_concat_segments => l_con_fa_location,
      x_return_status   => l_return_status,
      x_error_message   => l_error_message);

    IF NOT(l_return_status = fnd_api.g_ret_sts_success) THEN
      RAISE asset_loc_exp;
    END IF;

    debug('  location_segment     : '||l_con_fa_location);

    -- remove the delimeter
    CSE_UTIL_PKG.get_combine_segments(
      p_short_name      => 'OFA',
      p_flex_code       => 'LOC#',
      p_concat_segments => l_con_fa_location,
      x_combine_segments=> x_fa_location,
      x_return_status   => l_return_status,
      x_error_message   => l_error_message);

    IF NOT(l_return_status = fnd_api.g_ret_sts_success) THEN
      RAISE asset_loc_exp;
    END IF;

  EXCEPTION
   WHEN asset_loc_exp THEN
     x_error_message  := l_error_message;
     x_return_status  := l_return_status;
   WHEN OTHERS THEN
    fnd_message.set_name('CSE','CSE_OTHERS_EXCEPTION');
    fnd_message.set_token('ERR_MSG', sqlerrm);
    l_error_message := fnd_message.get;
    x_error_message :=l_error_message;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END get_fa_location_segment;

  PROCEDURE get_product_name (
    p_project_id       IN  NUMBER,
    p_transaction_id   IN  NUMBER,
    x_product_name     OUT NOCOPY VARCHAR2,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_error_message    OUT NOCOPY VARCHAR2)
  IS
    CURSOR Product_Cur IS
      SELECT class_code
      FROM   pa_project_classes
      WHERE  project_id = p_project_id
      AND    class_category = 'Product';

    l_product_name     varchar2(150);
    l_hook_used        number;
    l_return_status    varchar2(1);
    l_error_message    varchar2(2000);
    l_asset_attrib_rec cse_datastructures_pub.asset_attrib_rec ;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    x_error_message := null;
    l_product_name  := null;

    l_asset_attrib_rec.transaction_id := p_transaction_id ;

    cse_asset_client_ext_stub.get_product_code(
      p_asset_attrib_rec    => l_asset_attrib_rec,
      x_product_code        => l_product_name,
      x_hook_used           => l_hook_used,
      x_error_msg           => l_error_message ) ;

    IF l_hook_used <> 1 THEN
      OPEN  product_cur;
      FETCH product_cur INTO l_product_name;
      CLOSE product_cur;
    END IF;

    debug('  product_name         : '||l_product_name);

    x_product_name := l_product_name;

  EXCEPTION
    WHEN OTHERS THEN
      fnd_message.set_name('CSE','CSE_OTHERS_EXCEPTION');
      fnd_message.set_token('ERR_MSG', sqlerrm);
      l_error_message := fnd_message.get;
      x_error_message :=l_error_message;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  END get_product_name;

  PROCEDURE get_grouping_attribute(
    p_item_id          IN   NUMBER,
    p_organization_id  IN   NUMBER,
    p_project_id       IN   NUMBER,
    p_fa_location_id   IN   NUMBER,
    p_transaction_id   IN   NUMBER,
    p_org_id           IN   NUMBER,
    x_attribute8        OUT NOCOPY VARCHAR2,
    x_attribute9        OUT NOCOPY VARCHAR2,
    x_attribute10       OUT NOCOPY VARCHAR2,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_error_message     OUT NOCOPY VARCHAR2)
  IS

     l_asset_category_id   NUMBER;
     l_asset_category      VARCHAR2(150);
     l_fa_location         VARCHAR2(150);
     l_grp_asset_location  VARCHAR2(150);
     l_grp_asset_category  VARCHAR2(150);
     l_product_name        VARCHAR2(150);
     grouping_attr_exp     EXCEPTION;
     l_return_status       VARCHAR2(1) := fnd_api.g_ret_sts_success;
     l_Error_Message       VARCHAR2(2000);

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;

    get_fa_asset_category(
      p_item_id            => p_item_id,
      p_inv_master_org_id  => p_organization_id,
      p_transaction_id     => p_transaction_id,
      x_asset_category_id  => l_asset_category_id,
      x_asset_category     => l_asset_category,
      x_return_status      => l_return_status,
      x_error_message      => l_error_message);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE fnd_api.g_exc_error ;
    END IF;

    get_fa_location_segment (
      p_fa_location_id     => p_fa_location_id,
      p_transaction_id     => p_transaction_id,
      x_fa_location        => l_fa_location,
      x_return_status      => l_return_status,
      x_error_message      => l_error_message);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE grouping_attr_exp;
    END IF;

    get_product_name (
      p_project_id         => p_project_id,
      p_transaction_id     => p_transaction_id,
      x_product_name       => l_product_name,
      x_return_status      => l_return_status,
      x_error_message      => l_error_message);

    IF l_return_status <> fnd_api.g_ret_sts_success THEN
      RAISE grouping_attr_exp;
    END IF;

    --get attribute 8,9,10
    BEGIN

      SELECT asset_location, asset_category
      INTO   l_grp_asset_location, l_grp_asset_category
      FROM   ipa_asset_naming_convents_all
      WHERE  org_id = p_org_id;

      debug('  crl_asset_loc_attrib : '||l_grp_asset_location);
      debug('  crl_asset_cat_attrib : '||l_grp_asset_category);

      x_attribute8  := NULL;
      x_attribute9  := NULL;
      x_attribute10 := NULL;

      IF l_grp_asset_location = 'ALGE1' THEN
        x_attribute8 := l_fa_location;
      ELSIF l_grp_asset_location = 'ALGE2' THEN
        x_attribute9 := l_fa_location;
      ELSIF l_grp_asset_location = 'ALGE3' THEN
        x_attribute10 := l_fa_location;

      END IF;

      IF l_grp_asset_category = 'ACGE1' THEN
        x_attribute8 := l_asset_category;
      ELSIF l_grp_asset_category = 'ACGE2' THEN
        x_attribute9 := l_asset_category;
      ELSIF l_grp_asset_category = 'ACGE3' THEN
        x_attribute10 := l_asset_category;
      END IF;

      IF x_attribute8 IS NULL THEN
         x_attribute8 := l_product_name;
      ELSIF  x_attribute9 IS NULL THEN
         x_attribute9 := l_product_name;
      ELSIF  x_attribute10 IS NULL THEN
         x_attribute10 := l_product_name;
      END IF;

    EXCEPTION
      WHEN no_data_found THEN
        fnd_message.set_name('CSE', 'CSE_CRL_GRP_NOT_FOUND');
        fnd_message.set_token('ORG_ID', p_org_id);
        fnd_msg_pub.add;
        l_error_message := cse_util_pkg.dump_error_stack;
        RAISE fnd_api.g_exc_error;
    END;

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_error_message  := l_error_message;
      x_return_status  := l_return_status;
    WHEN OTHERS THEN
      fnd_message.set_name('CSE','CSE_OTHERS_EXCEPTION');
      fnd_message.set_token('ERR_MSG', sqlerrm);
      l_error_message := fnd_message.get;
      x_error_message := l_error_message;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
  END get_grouping_attribute;

END cse_ipa_trans_pkg;

/
