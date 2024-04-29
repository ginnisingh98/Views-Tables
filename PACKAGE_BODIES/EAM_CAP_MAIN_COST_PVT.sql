--------------------------------------------------------
--  DDL for Package Body EAM_CAP_MAIN_COST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_CAP_MAIN_COST_PVT" as
/* $Header: EAMCOMCB.pls 120.7.12010000.8 2009/12/15 23:04:35 jvittes ship $ */

  PROCEDURE initiate_capitalization (p_eam_wo_bills_tbl     IN eam_cap_main_cost_pvt.eam_wo_bills_tbl,
       x_return_status        OUT NOCOPY VARCHAR2,
       x_msg_data             OUT NOCOPY VARCHAR2,
       x_msg_count            OUT NOCOPY NUMBER) IS

    l_fa_asset_id            NUMBER       := NULL;
    l_cost                   NUMBER       := NULL;
    l_book_type_code         VARCHAR2(15) := NULL;
    l_asset_category_id      NUMBER       := NULL;
    l_asset_number           VARCHAR2(15) := NULL;
    l_mass_addition_id       NUMBER       := NULL;
    l_in_use_flag            VARCHAR2(3)  := NULL;
    l_deprn_calendar 	   VARCHAR2(15);
    l_dep_date 		   DATE;
    l_last_dep_run_date 	   DATE;
    l_period_name 	   VARCHAR2(15);
    l_transaction_type_code  VARCHAR2(15) := NULL;
    l_transaction_date	   DATE		:= NULL;
    l_add_to_asset   BOOLEAN   := TRUE;
    l_post_asset_category_id NUMBER := NULL;
    l_merged_code VARCHAR2(3) := NULL;
    l_merge_parent_id NUMBER := NULL;
    l_posting_status VARCHAR2(6) := NULL;
    l_queue_name VARCHAR2(6) := NULL;
    l_asset_type	     VARCHAR2(16) := NULL;
    csi_asset_rec_not_found  EXCEPTION;
    fa_not_found             EXCEPTION;
    cost_not_defined         EXCEPTION;
    book_type_not_defined    EXCEPTION;

    CURSOR c_inst_asset_info(pc_asset_group_id IN NUMBER,
      pc_rebuild_item_id IN NUMBER,
      pc_asset_number IN VARCHAR2,
      pc_rebuild_serial_number IN VARCHAR2,
      pc_org_id IN NUMBER,
      pc_inventory_item_id IN NUMBER) IS
    SELECT cia.fa_asset_id,
      cia.fa_book_type_code
    FROM csi_item_instances cii,
      csi_i_assets cia
    WHERE cii.instance_id = cia.instance_id
      AND cii.inventory_item_id = NVL(pc_asset_group_id,pc_rebuild_item_id)
      AND cii.instance_number  = NVL(pc_asset_number, pc_rebuild_serial_number)
      AND cia.asset_quantity > 0
      AND cia.update_status = 'IN_SERVICE';

    r_inst_asset_info     c_inst_asset_info%rowtype;

    CURSOR c_fa_asset_number (pc_fixed_asset_id IN NUMBER) IS
    SELECT fa.asset_category_id,
      fa.asset_number,
      fa.in_use_flag,
      fa.asset_type
    FROM fa_additions_b fa
    WHERE asset_id = pc_fixed_asset_id;

    r_fa_asset_number     c_fa_asset_number%rowtype;


    --Bug 6640036 Add function to retrieve the open FA period and its end date

    CURSOR c_dep_date (c_calendar_type in varchar,  c_book_type_code IN varchar, c_period_name in varchar) IS
    SELECT END_DATE
    FROM FA_CALENDAR_PERIODS FAP,
      fa_book_controls FAC
    WHERE FAP.calendar_type=c_calendar_type
      AND FAC.BOOk_TYPE_CODE =c_book_type_code
      AND FAP.PERIOD_NAME=c_period_name;

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


    BEGIN

    SAVEPOINT initiate_capitalization;

    x_return_status := fnd_api.G_RET_STS_SUCCESS ;

    -- Insert into the FA_MASS_ADDITIONS and EAM_WORK_ORER_BILLS tables

    IF p_eam_wo_bills_tbl.count > 0 THEN

        FOR i IN p_eam_wo_bills_tbl.first .. p_eam_wo_bills_tbl.last LOOP

          l_fa_asset_id       := NULL;
          l_cost              := NULL;
          l_book_type_code    := NULL;
          l_asset_category_id := NULL;
          l_asset_number      := NULL;
          l_in_use_flag       := NULL;
          l_add_to_asset      := TRUE;
          l_post_asset_category_id := NULL;
          -- Get the asset information from CSI_I_ASSETS
          OPEN c_inst_asset_info(p_eam_wo_bills_tbl(i).asset_group_id,
            p_eam_wo_bills_tbl(i).rebuild_item_id,
            p_eam_wo_bills_tbl(i).asset_number,
            p_eam_wo_bills_tbl(i).rebuild_serial_number,
            p_eam_wo_bills_tbl(i).organization_id,
            p_eam_wo_bills_tbl(i).billed_inventory_item_id);
          FETCH c_inst_asset_info INTO r_inst_asset_info;
          IF c_inst_asset_info%FOUND then
            l_fa_asset_id    := r_inst_asset_info.fa_asset_id;
            l_book_type_code := r_inst_asset_info.fa_book_type_code;
            CLOSE c_inst_asset_info;
          ELSE
            CLOSE c_inst_asset_info;
            l_add_to_asset := FALSE;
            l_book_type_code := get_book_type(p_eam_wo_bills_tbl(i).organization_id);
            IF l_book_type_code IS NULL THEN
              RAISE book_type_not_defined;
            END IF ;
          END IF;-- Added CU Project

          IF l_add_to_asset = TRUE then
          -- Get the FA Asset Number from FA_ADDITIONS_B
            OPEN c_fa_asset_number (l_fa_asset_id);
            FETCH c_fa_asset_number INTO r_fa_asset_number;
            IF c_fa_asset_number%FOUND THEN
              l_asset_category_id := r_fa_asset_number.asset_category_id;
              l_asset_number      := r_fa_asset_number.asset_number;
              l_in_use_flag       := r_fa_asset_number.in_use_flag;
	      l_asset_type	  := r_fa_asset_number.asset_type;
              CLOSE c_fa_asset_number;
            ELSE
              CLOSE c_fa_asset_number;
              RAISE fa_not_found;
            END IF;

          -- Get the FA Cost
            l_cost := get_fa_book_cost (l_fa_asset_id,
               l_book_type_code);
            IF l_cost IS NULL THEN
              Raise cost_not_defined;
            END IF;
         ELSE
            l_post_asset_category_id := get_asset_category_id (nvl(p_eam_wo_bills_tbl(i).asset_group_id,p_eam_wo_bills_tbl(i).rebuild_item_id),
                                                             p_eam_wo_bills_tbl(i).organization_id);
          END IF; --Added for CU Project

          --Bug 6640036 Get the current open period and its end date
          BEGIN
            OPEN   c_curr_dep_prd(l_book_type_code);
            FETCH  c_curr_dep_prd INTO l_period_name,  l_last_dep_run_date,l_deprn_calendar ;
            CLOSE  c_curr_dep_prd ;
          EXCEPTION
            WHEN others then
            NULL;
          END;

          IF (l_period_name is not  null) THEN
            BEGIN
            OPEN  c_dep_date(l_deprn_calendar,l_book_type_code,l_period_name);
            FETCH c_dep_date INTO l_dep_date ;
            CLOSE c_dep_date ;
            EXCEPTION
              WHEN others then
              NULL;
            END;
          END IF;

          --Bug 6640036 Check the date against the current open period date
          IF TRUNC(sysdate) > TRUNC(l_dep_date) THEN
            IF l_add_to_asset = TRUE then
              l_transaction_type_code := 'FUTURE ADJ';
              l_transaction_date := sysdate;
              /*Added for CU Project*/
            ELSE
              l_transaction_type_code := 'FUTURE ADD';
              l_transaction_date := sysdate;
            END IF;

          END IF;

          SELECT fa_mass_additions_s.nextval
          INTO l_mass_addition_id
          FROM SYS.DUAL ;

          IF p_eam_wo_bills_tbl.count > 0 AND l_add_to_asset = FALSE THEN
            IF i = p_eam_wo_bills_tbl.first THEN
                l_merged_code := 'MP';
                l_posting_status := 'NEW';
                l_queue_name := 'NEW';
            ELSE
                l_merged_code := 'MC';
                l_posting_status := 'MERGED';
                l_queue_name := 'POST';
            END IF;
          END IF;

          INSERT INTO fa_mass_additions
            (mass_addition_id,
            add_to_asset_id,
            asset_category_id,
            book_type_code,
            fixed_assets_cost,
            feeder_system_name,
            posting_status,
            queue_name,
            transaction_date, -- Bug 6640036
            transaction_type_code,
	    asset_type, -- Bug 9095320
            in_use_flag,
            reviewer_comments,
            payables_code_combination_id,
            payables_cost,
            merged_code,
            MERGE_PARENT_MASS_ADDITIONS_ID,  -- Bug 7678186
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
            )
          VALUES
            (l_mass_addition_id,
            l_fa_asset_id,
            l_post_asset_category_id,
            l_book_type_code,
            p_eam_wo_bills_tbl(i).billed_amount, -- Add to table will be passed in from form
            'ENTERPRISE ASSET MANAGEMENT',
            decode(l_fa_asset_id, null, l_posting_status,'POST'),
            decode(l_fa_asset_id, null, l_queue_name,'ADD TO ASSET'), --Added decode for CU Project
            l_transaction_date, -- Bug 6640036
            l_transaction_type_code, --Bug 6640036
	    l_asset_type, -- Bug 9095320
            nvl(l_in_use_flag,'N'),
            p_eam_wo_bills_tbl(i).comments,
            p_eam_wo_bills_tbl(i).offset_account_ccid,  -- Offset/Clearance Account
            p_eam_wo_bills_tbl(i).billed_amount, -- To credit Clearance A/C with this amount
            l_merged_code,
            l_merge_parent_id,
            fnd_global.user_id,
            sysdate,
            fnd_global.user_id,
            sysdate,
            fnd_global.user_id);


          INSERT INTO eam_work_order_bills(
            organization_id,
            wip_entity_id,
            operation_seq_num,
            inventory_item_id,
            resource_id,
            billed_inventory_item_id,
            billed_uom_code,
            billed_quantity,
            cost_or_listprice,
            costplus_percentage,
            billed_amount,
            billing_method,
            fixed_asset_number,
            mass_addition_id,
            capitalization_date,
            comments,
            offset_account_ccid,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN )
          VALUES (
            p_eam_wo_bills_tbl(i).organization_id,
            p_eam_wo_bills_tbl(i).wip_entity_id,
            p_eam_wo_bills_tbl(i).operation_seq_num,
            p_eam_wo_bills_tbl(i).billed_inventory_item_id,
            p_eam_wo_bills_tbl(i).resource_id,
            nvl(p_eam_wo_bills_tbl(i).billed_inventory_item_id,-123456),
            p_eam_wo_bills_tbl(i).billed_uom_code,
            p_eam_wo_bills_tbl(i).billed_quantity,
            l_cost,
            p_eam_wo_bills_tbl(i).COSTPLUS_PERCENTAGE, -- = as entered by the user
            p_eam_wo_bills_tbl(i).billed_amount,       -- = Calculated Amount
            3,                                         -- (Capitalzation)
            l_fa_asset_id,
            l_mass_addition_id,
            sysdate,
            p_eam_wo_bills_tbl(i).comments,
            p_eam_wo_bills_tbl(i).offset_account_ccid,
            fnd_global.user_id,
            sysdate,
            fnd_global.user_id,
            sysdate,
            fnd_global.user_id);

          -- Added Bug 7678186

          IF i = p_eam_wo_bills_tbl.first AND l_add_to_asset = FALSE THEN
            l_merge_parent_id := l_mass_addition_id;
          END IF;

        END LOOP;
    END IF;

    EXCEPTION

      WHEN csi_asset_rec_not_found THEN
        ROLLBACK TO initiate_capitalization;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        fnd_message.set_name('EAM','EAM_CSI_REC_NOT_FOUND');
        x_msg_data := fnd_message.get;
        x_msg_count := 1;

      WHEN cost_not_defined THEN
        ROLLBACK TO initiate_capitalization;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        fnd_message.set_name('EAM','EAM_COST_NOT_DEFINED');
        x_msg_data := fnd_message.get;
        x_msg_count := 1;

     WHEN book_type_not_defined THEN
        ROLLBACK TO initiate_capitalization;
        x_return_status := FND_API.G_RET_STS_ERROR ;
        fnd_message.set_name('EAM','EAM_BOOK_TYPE_NOT_DEFINED');
        x_msg_data := fnd_message.get;
        x_msg_count := 1;

      WHEN others THEN
        ROLLBACK TO initiate_capitalization;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        fnd_message.set_name('EAM','EAM_ATP_SYSTEM_ERROR');
        x_msg_data :=  fnd_message.get;
        x_msg_count := 1;

  END initiate_capitalization;

  FUNCTION  get_fa_book_cost (l_asset_id IN NUMBER,
    l_book_type_code IN VARCHAR2) RETURN NUMBER IS

    l_cost NUMBER := NULL;

    BEGIN
      SELECT cost
      INTO l_cost
      FROM fa_books
      WHERE transaction_header_id_out IS NULL
        AND asset_id = l_asset_id
        AND book_type_code = l_book_type_code;

      RETURN l_cost;

    EXCEPTION
      when NO_DATA_FOUND then
        l_cost := NULL;
        RETURN l_cost;
  END get_fa_book_cost;

  FUNCTION get_book_type (l_org_id IN NUMBER) RETURN VARCHAR2 IS
    l_txn_ou_context NUMBER := NULL;
    l_book_type_code VARCHAR2(15) := NULL;
    BEGIN
      SELECT   ood.operating_unit
      INTO     l_txn_ou_context
      FROM     org_organization_definitions  ood
      WHERE    ood.organization_id = l_org_id
        AND      ROWNUM = 1;

      l_book_type_code := fnd_profile.VALUE_SPECIFIC(
        name => 'eam_fa_book_type_code',
        ORG_ID => l_txn_ou_context
      );
      RETURN l_book_type_code;
    EXCEPTION
      when NO_DATA_FOUND then
        l_book_type_code := NULL;
        RETURN l_book_type_code;



  END get_book_type;

  FUNCTION  get_asset_category_id (l_inventory_item_id IN NUMBER,
    l_org_id IN NUMBER) RETURN NUMBER IS

    l_post_asset_category_id NUMBER := NULL;

    BEGIN
      select asset_category_id
      into l_post_asset_category_id
      from mtl_system_items_b
      where inventory_item_id = l_inventory_item_id
      and organization_id = l_org_id;

      RETURN l_post_asset_category_id;

    EXCEPTION
      when NO_DATA_FOUND then
        l_post_asset_category_id := NULL;
        RETURN l_post_asset_category_id;
  END get_asset_category_id;

END EAM_CAP_MAIN_COST_PVT;

/
