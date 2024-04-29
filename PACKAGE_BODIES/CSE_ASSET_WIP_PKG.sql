--------------------------------------------------------
--  DDL for Package Body CSE_ASSET_WIP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSE_ASSET_WIP_PKG" AS
-- $Header: CSEFAWPB.pls 115.5 2003/01/10 21:02:48 nnewadka noship $

l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('CSE_DEBUG_OPTION'),'N');

--------------------------------------------------------------------------------
---Finds the immediate children from Installed Base configuration
---For each depreciable component, perfroms unit and cost adjustment
--------------------------------------------------------------------------------
PROCEDURE update_comp_assets(
  p_top_instance_id       IN        NUMBER
, x_return_status         OUT NOCOPY       VARCHAR2
, x_error_msg             OUT NOCOPY       VARCHAR2
  )
IS
l_relationship_tbl         csi_datastructures_pub.ii_relationship_tbl ;
l_relationship_query_rec   csi_datastructures_pub.relationship_query_rec ;
l_return_status   VARCHAR2(10);
l_msg_count       NUMBER ;
l_msg_data        VARCHAR2(2000);
l_error_message   VARCHAR2(2000);
l_msg_index       NUMBER ;
l_depreciable     VARCHAR2(1);
l_sysdate         DATE ;
l_unit_asset_cost  NUMBER ;
l_total_asset_cost       NUMBER ;
l_total_asset_units      NUMBER ;
l_inst_units_to_be_adjusted  NUMBER ;
l_adjust_units     NUMBER ;
l_cost_to_adjust NUMBER ;
l_wip_txn_id     NUMBER ;

e_error_exception    EXCEPTION ;
CURSOR get_item_instance_cur (c_comp_instance_id IN NUMBER)
IS
SELECT instance_id,
       instance_usage_code,
       inventory_item_id,
       quantity,
       serial_number
FROM   csi_item_instances
WHERE  instance_id = c_comp_instance_id ;

CURSOR get_wip_txn_id_cur(c_instance_id IN NUMBER)
IS
SELECT transaction_id,
       ABS(quantity)
FROM   csi_inst_txn_details_v
WHERE  instance_id = c_instance_id
AND    source_transaction_type = 'WIP_ISSUE' ;

CURSOR get_instance_assets_cur (c_instance_id IN NUMBER)
IS
SELECT cia.fa_asset_id,
       cia.fa_book_type_code,
       cia.fa_location_id,
       fdh.units_assigned,
       cia.update_status,
       fdh.code_combination_id,
       fdh.assigned_to
FROM  csi_i_assets cia,
      fa_distribution_history fdh
WHERE instance_id = c_instance_id
AND   update_status = 'IN_SERVICE'
AND   asset_quantity > 0
AND   TRUNC(active_start_date) <= l_sysdate
AND   NVL(TRUNC(active_end_date), l_sysdate) >= l_sysdate
AND   fdh.asset_id = cia.fa_asset_id
AND   fdh.book_type_code = cia.fa_book_type_code
AND   fdh.location_id = cia.fa_location_id
AND   fdh.date_ineffective IS NULL
ORDER BY cia.fa_asset_id ;

CURSOR get_asset_unit_cost_cur (c_book_type_code IN VARCHAR2,
                                c_asset_id IN NUMBER)
IS
SELECT fab.cost,
       faa.current_units
FROM   fa_additions faa,
       fa_books fab
WHERE  fab.book_type_code = c_book_type_code
AND    fab.asset_id = c_asset_id
AND    faa.asset_id = fab.asset_id ;

BEGIN
     cse_util_pkg.write_log('Begin  update_comp_assets for top instance :'
        || p_top_instance_id);
     SELECT TRUNC(SYSDATE) INTO l_sysdate FROM DUAL ;
   ---get all the immediate children of p_top_instance_id
     l_relationship_query_rec.object_id := p_top_instance_id ;
     l_relationship_query_rec.relationship_type_code := 'COMPONENT-OF' ;

     csi_ii_relationships_pub.get_relationships(
     p_api_version               => 1.0,
     p_commit                    => fnd_api.g_false,
     p_init_msg_list             => fnd_api.g_true,
     p_validation_level          => fnd_api.g_valid_level_full,
     p_relationship_query_rec    => l_relationship_query_rec,
     p_depth                     => 1,
     p_time_stamp                => null ,
     p_active_relationship_only  => fnd_api.g_true,
     x_relationship_tbl          => l_relationship_tbl,
     x_return_status             => l_return_status,
     x_msg_count                 => l_msg_count,
     x_msg_data                  => l_msg_data );

     cse_util_pkg.write_log('l_return_status After calling get_relationships :'||l_return_status);
    IF l_return_status <> FND_API.G_Ret_Sts_Success
    THEN
       l_msg_index := 1;
       l_error_message := l_msg_data;
     WHILE l_msg_count > 0
     LOOP
       l_error_message := FND_MSG_PUB.GET(l_msg_index,FND_API.G_FALSE)||l_error_message;
      l_msg_index := l_msg_index + 1;
      l_Msg_Count := l_Msg_Count - 1;
     END LOOP;
    END IF;

   IF l_relationship_tbl.COUNT > 0
   THEN
     FOR i IN 1..l_relationship_tbl.COUNT
     LOOP
        cse_util_pkg.write_log('This is IN_RELATIONSHIP Instance ID :'||
                                       l_relationship_tbl(i).subject_id);

        OPEN get_wip_txn_id_cur(l_relationship_tbl(i).subject_id) ;
        FETCH get_wip_txn_id_cur INTO l_wip_txn_id ,l_inst_units_to_be_adjusted ;
        CLOSE get_wip_txn_id_cur ;
        cse_util_pkg.write_log('CSI-WIP Transaction ID:'|| l_wip_txn_id);

        FOR get_item_instance_rec IN
                  get_item_instance_cur(l_relationship_tbl(i).subject_id)
        LOOP
          --is item depreciable?
          cse_util_pkg.write_log('This is component : '||l_relationship_tbl(i).subject_id);
          cse_util_pkg.check_depreciable(get_item_instance_rec.inventory_item_id
                        ,l_depreciable);
          cse_util_pkg.write_log('After checking item depreciable :'|| l_depreciable);
          IF l_depreciable = 'Y'
          THEN
              cse_util_pkg.write_log('Total asset units to be adjusted :'||
                      l_inst_units_to_be_adjusted);
             ---get asset associated with this instance
             FOR get_instance_assets_rec IN
                    get_instance_assets_cur (get_item_instance_rec.instance_id)
             LOOP
                IF l_inst_units_to_be_adjusted > 0
                THEN

                   --Get, how many asset units to adjust
                   IF l_inst_units_to_be_adjusted <= get_instance_assets_rec.units_assigned
                   THEN
                      l_adjust_units := l_inst_units_to_be_adjusted ;
                      l_inst_units_to_be_adjusted := 0;
                   ELSE
                     l_adjust_units := get_instance_assets_rec.units_assigned ;
                     l_inst_units_to_be_adjusted :=
                                  l_inst_units_to_be_adjusted- l_adjust_units ;
                   END IF ;

                   cse_util_pkg.write_log('l_adjust_units: '|| l_adjust_units);
                   OPEN get_asset_unit_cost_cur (get_instance_assets_rec.fa_book_type_code ,
                           get_instance_assets_rec.fa_asset_id );
                   FETCH get_asset_unit_cost_cur INTO l_total_asset_cost,
                                          l_total_asset_units ;
                   CLOSE get_asset_unit_cost_cur ;

                   cse_util_pkg.write_log('l_total_asset_cost: '|| l_total_asset_cost);
                   cse_util_pkg.write_log('l_total_asset_units: '|| l_total_asset_units);
                   l_cost_to_adjust := ROUND((l_total_asset_cost/l_total_asset_units)
                                       *l_adjust_units ,2);

                    l_adjust_units  := (-1)*l_adjust_units ;
                    l_cost_to_adjust  := (-1)*l_cost_to_adjust ;

                    IF get_item_instance_rec.serial_number is NOT NULL
                    THEN
                       l_adjust_units := NULL ;
                    END IF ;

                   adjust_fa_cost_n_unit(
                      p_asset_id       => get_instance_assets_rec.fa_asset_id
                     ,p_book_type_code => get_instance_assets_rec.fa_book_type_code
                     ,p_location_id    => get_instance_assets_rec.fa_location_id
                     ,p_expense_ccid   => get_instance_assets_rec.code_combination_id
                     ,p_employee_id    => get_instance_assets_rec.assigned_to
                     ,p_unit_to_adjust => l_adjust_units
                     ,p_cost_to_adjust => l_cost_to_adjust
                     ,p_reviewer_comments => get_item_instance_rec.instance_id
                     ,x_error_msg      => l_error_message
                     ,x_return_status  => l_return_status );

                   IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                   THEN
                      RAISE e_error_exception ;
                   END IF ;
                ELSE
                   EXIT ;
                END IF ; ---l_inst_units_to_be_adjusted
             END LOOP ; --get_instance_assets_rec
          END IF ;
        END LOOP ; --get_item_instance_rec
     END LOOP ; --1..l_relationship_tbl.COUNT
   END IF ; --l_relationship_tbl.COUNT > 0

END update_comp_assets ;

--------------------------------------------------------------------------------
---Insert records into FA_MASS_ADDITIONS for COST
---and UNIT adjustment
--------------------------------------------------------------------------------
PROCEDURE adjust_fa_cost_n_unit(
  p_asset_id              IN        NUMBER
, p_book_type_code        IN        VARCHAR2
, p_location_id           IN        NUMBER
, p_expense_ccid          IN        NUMBER
, p_employee_id           IN        NUMBER
, p_unit_to_adjust        IN        NUMBER
, p_cost_to_adjust        IN        NUMBER
, p_reviewer_comments      IN        VARCHAR2
, x_return_status         OUT NOCOPY       VARCHAR2
, x_error_msg             OUT NOCOPY       VARCHAR2
  )
IS
l_mass_add_rec     fa_mass_additions%ROWTYPE := NULL ;
l_sysdate          DATE ;
l_return_status   VARCHAR2(1) ;
l_msg_count       NUMBER ;
l_msg_data        VARCHAR2(2000);
l_error_msg       VARCHAR2(2000);
l_new_dist_id     NUMBER ;

CURSOR fa_book_cur
IS
SELECT  fab.date_placed_in_service ,
        faa.description,
        faa.asset_category_id,
        faa.asset_key_ccid
FROM   fa_books fab ,
       fa_additions faa
WHERE fab.book_type_code = p_book_type_code
AND   fab.asset_id = p_asset_id
AND   faa.asset_id = fab.asset_id
AND   fab.date_ineffective IS NULL ;

e_error    EXCEPTION ;
BEGIN
    x_return_status := fnd_api.G_RET_STS_SUCCESS ;
    cse_util_pkg.write_log ('Asset ID : '||p_asset_id);
    cse_util_pkg.write_log ('Book Type: '||p_book_type_code);
    cse_util_pkg.write_log ('FA Location : '||p_location_id);
    cse_util_pkg.write_log ('Expense CCID :'|| p_expense_ccid);
    cse_util_pkg.write_log ('Employee ID:'|| p_employee_id);
    cse_util_pkg.write_log ('Unit to adjust :'|| p_unit_to_adjust);
    cse_util_pkg.write_log ('Cost to adjust :'|| p_cost_to_adjust);
    cse_util_pkg.write_log ('p_reviewer_comments : '|| p_reviewer_comments);

    FOR fa_book_rec IN fa_book_cur
    LOOP
       l_mass_add_rec.date_placed_in_service := fa_book_rec.date_placed_in_service ;
       l_mass_add_rec.description := fa_book_rec.description ;
       l_mass_add_rec.asset_category_id := fa_book_rec.asset_category_id ;
       l_mass_add_rec.asset_key_ccid := fa_book_rec.asset_key_ccid ;
    END LOOP ;

    SELECT SYSDATE INTO l_sysdate FROM DUAL ;

    l_mass_add_rec.payables_cost := p_cost_to_adjust ;
    l_mass_add_rec.fixed_assets_cost := p_cost_to_adjust ;
    l_mass_add_rec.payables_units := p_unit_to_adjust ;
    l_mass_add_rec.fixed_assets_units := p_unit_to_adjust ;
    l_mass_add_rec.reviewer_comments := p_reviewer_comments ;
    l_mass_add_rec.book_type_code := p_book_type_code ;
    l_mass_add_rec.location_id := p_location_id ;
    l_mass_add_rec.expense_code_combination_id := p_expense_ccid ;
    l_mass_add_rec.assigned_to := p_employee_id ;
    l_mass_add_rec.add_to_asset_id := p_asset_id ;
    ----l_mass_add_rec.units_to_adjust := p_unit_to_adjust ;
    l_mass_add_rec.feeder_system_name := cse_asset_util_pkg.G_FA_FEEDER_NAME;

    l_mass_add_rec.queue_name := 'ADD TO ASSET' ;
    l_mass_add_rec.posting_status := 'POST' ;
    l_mass_add_rec.asset_type := 'CAPITALIZED' ;
    l_mass_add_rec.depreciate_flag := 'YES' ;
    l_mass_add_rec.creation_date := l_sysdate;
    l_mass_add_rec.last_update_date := l_sysdate;
    l_mass_add_rec.created_by := fnd_global.user_id ;
    l_mass_add_rec.last_updated_by := fnd_global.user_id ;
    l_mass_add_rec.last_update_login := fnd_global.login_id ;
    l_mass_add_rec.last_update_login := fnd_global.login_id ;

    cse_asset_util_pkg.insert_mass_add(
         p_api_version => 1.0
        ,p_commit => FND_API.G_FALSE
        ,p_init_msg_list => FND_API.G_TRUE
        ,p_mass_add_rec => l_mass_add_rec
        ,x_return_status => l_return_status
        ,x_msg_count => l_msg_count
        ,x_msg_data => l_msg_data );

     IF l_return_status <> fnd_api.G_RET_STS_SUCCESS
     THEN
        l_error_msg := l_msg_data ;
        RAISE e_error ;
     END IF ;

  IF p_unit_to_adjust IS NOT NULL
  THEN
   --Now call adjust_fa_distribution for UNIT adjustment
    cse_ifa_trans_pkg.adjust_fa_distribution
    (p_asset_id              => p_asset_id,
     p_book_type_code        => p_book_type_code,
     p_units                 => p_unit_to_adjust,
     p_location_id           => p_location_id,
     p_expense_ccid          => p_expense_ccid,
     p_employee_id           => p_employee_id,
     x_new_dist_id           => l_new_dist_id,
     x_return_status         => l_return_status,
     x_error_msg             => l_error_msg);

     IF l_return_status <> fnd_api.G_RET_STS_SUCCESS
     THEN
        RAISE e_error ;
     END IF ;
   END IF ;

EXCEPTION
WHEN e_error THEN
x_return_status := fnd_api.G_RET_STS_ERROR ;
x_error_msg := l_error_msg ;
cse_util_pkg.write_log('Error in adjust_fa_cost_n_unit :'|| x_error_msg);
WHEN OTHERS THEN
x_return_status := fnd_api.G_RET_STS_ERROR ;
x_error_msg := SQLERRM ;
cse_util_pkg.write_log('Error in adjust_fa_cost_n_unit :'|| x_error_msg);
END adjust_fa_cost_n_unit ;

END CSE_ASSET_WIP_PKG ;

/
