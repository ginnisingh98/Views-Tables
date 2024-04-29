--------------------------------------------------------
--  DDL for Package Body FA_CUA_HR_RETIREMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CUA_HR_RETIREMENTS_PKG" AS
/* $Header: FACHRMRMB.pls 120.5.12010000.3 2009/08/20 14:18:36 bridgway ship $ */

g_log_level_rec fa_api_types.log_level_rec_type;

-- ----------------------------------------------------------------
-- This function will return TRUE if the asset belongs to any batch
-- in mass_update_batches or retirement_batches with a pending
-- or rejected status. Else it returns FALSE
-- calling_function: ADDITION       to be called from mass_additions
--                                  x_node_id = Parent_node_id
--                                  x_asset_id = asset_id
--                                  x_attribute = NULL
--                   TRANSACTION    to be called from trigger
--                                  APPS.IFA_TRANSACTION_HEADERS_HR_BRI
--                                  x_book_type_code = NEW.book_type_code
--                                  x_asset_id = NEW.asset_id
--                                  x_attribute= NULL
--                   HIERARCHY      to be called from any hierarchy process
--                                  x_asset_id = asset_id
--                                  x_attribute = attribute_name
--                   DEPRECIAITION  to be called from tirgger
--                                  IFA_BOOK_CONTROLS_BRU
--                                  book_type_code is passed
--                                  rest are null
--                   CONCURRENT     to be called when a conc. request
--                                  to create batch_transactions.
--                                  This function is called from forms with
--                                  x_conc_request_id as null OR within conc_request
--                                  with the x_conc_request_id as it request_id
-- -----------------------------------------------------------------

FUNCTION check_pending_batch( x_calling_function IN VARCHAR2,
                              x_book_type_code   IN VARCHAR2,
                              x_event_code       IN VARCHAR2   DEFAULT NULL,
                              x_asset_id         IN NUMBER     DEFAULT NULL,
                              x_node_id          IN NUMBER     DEFAULT NULL,
                              x_category_id      IN NUMBER     DEFAULT NULL,
                              x_attribute        IN VARCHAR2   DEFAULT NULL,
                              x_conc_request_id  IN NUMBER     DEFAULT NULL,
                              x_status    IN OUT NOCOPY VARCHAR2
                              , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null) RETURN BOOLEAN IS

v_dummy NUMBER:=0;
v_node_id NUMBER;
pending_batch varchar2(17):= 'CUA_PENDING_BATCH';
pending_book  varchar2(16):= 'CUA_PENDING_BOOK';
-- check for following batch status
-- 'P'  - Pending
-- 'E'  - Rejected   after submitted as conc_req  -  Create Batch Txns
-- 'R'  - Rejected   after submitted as conc_proc  - Mass Update Batches
-- 'N'  - New        when the batch needs to be created - initial status of the batch
-- 'IP' - In Process when a batch is in process

CURSOR C_check_batch_for_all IS
  select 1
  from dual
  where exists ( select 'x'
                 from fa_mass_update_batch_headers
                 where status_code IN ('P', 'E', 'R', 'N', 'IP')
                 and book_type_code = x_book_type_code
                 and ( x_conc_request_id is null OR
                       nvl(concurrent_request_id,0) <> x_conc_request_id ) );


CURSOR C_check_batch_headers IS
  select 1
  from dual
  where exists ( select 'x'
                 from fa_mass_update_batch_headers hdr
                 where hdr.status_code IN ('P', 'E', 'R', 'N', 'IP')
                 and hdr.book_type_code = x_book_type_code
                 and ( x_conc_request_id is null OR
                       nvl(hdr.concurrent_request_id,0) <> x_conc_request_id )
                 and ( hdr.event_code IN ( 'CHANGE_NODE_PARENT', 'CHANGE_NODE_ATTRIBUTE',
                                         'CHANGE_NODE_RULE_SET', 'CHANGE_CATEGORY_RULE_SET',
                                         'HR_MASS_TRANSFER')
                       OR ( hdr.event_code in ( 'CHANGE_CATEGORY_LIFE', 'CHANGE_CATEGORY_LIFE_END_DATE')
                            and ( x_event_code IN ('CHANGE_CATEGORY_LIFE', 'CHANGE_CATEGORY_LIFE_END_DATE',
                                                   'CHANGE_ASSET_CATEGORY' ) and
                                                    to_number(hdr.source_entity_key_value) = x_category_id )
                            or  (x_event_code IN ( 'CHANGE_NODE_PARENT', 'CHANGE_NODE_ATTRIBUTE',
                                                   'CHANGE_NODE_RULE_SET', 'CHANGE_CATEGORY_RULE_SET',
                                                   'CHANGE_ASSET_PARENT', 'HR_MASS_TRANSFER' ) )
                           )

                        OR ( hdr.event_code IN ( 'CHANGE_ASSET_PARENT','CHANGE_ASSET_LEASE','CHANGE_ASSET_CATEGORY')
                             and (( x_event_code IN ( 'CHANGE_ASSET_PARENT', 'CHANGE_ASSET_LEASE',
                                                   'CHANGE_ASSET_CATEGORY') and
                                                    to_number(hdr.source_entity_key_value) = x_asset_id )
                             OR x_event_code IN ( 'CHANGE_NODE_PARENT', 'CHANGE_NODE_ATTRIBUTE',
                                                  'CHANGE_NODE_RULE_SET', 'CHANGE_CATEGORY_RULE_SET',
                                                  'CHANGE_CATEGORY_LIFE', 'CHANGE_CATEGORY_LIFE_END_DATE',
                                                  'HR_MASS_TRANSFER' )
                            ) )
                       )
                    );

CURSOR C_check_batch_for_addition IS
  select 1
  from dual
  where exists ( select 'x'
                 from fa_mass_update_batch_headers a
                 where a.status_code IN ('P', 'E', 'R', 'N', 'IP')
                 and a.book_type_code = x_book_type_code
                 and a.event_code IN ( 'CHANGE_NODE_PARENT', 'CHANGE_NODE_ATTRIBUTE',
                                       'CHANGE_NODE_RULE_SET', 'CHANGE_CATEGORY_RULE_SET',
                                       'HR_MASS_TRANSFER', 'CHANGE_CATEGORY_LIFE',
                                       'CHANGE_CATEGORY_LIFE_END_DATE') );

CURSOR C_check_batch_for_ata IS
  select 1
  from dual
  where exists ( select 'x'
                 from fa_mass_update_batch_headers a
                 where a.status_code IN ('P', 'E', 'R', 'N', 'IP')
                 and a.book_type_code = x_book_type_code
                 and ( a.event_code IN ( 'CHANGE_NODE_PARENT', 'CHANGE_NODE_ATTRIBUTE',
                                         'CHANGE_NODE_RULE_SET', 'CHANGE_CATEGORY_RULE_SET',
                                         'HR_MASS_TRANSFER') or
                       (a.event_code IN ( 'CHANGE_CATEGORY_LIFE', 'CHANGE_CATEGORY_LIFE_END_DATE') and
                                       to_number(a.source_entity_key_value) = x_category_id ) or
                       (a.event_code IN ( 'CHANGE_ASSET_PARENT','CHANGE_ASSET_LEASE',
                                           'CHANGE_ASSET_CATEGORY') and
                                          to_number(a.source_entity_key_value) = x_asset_id )
                       ) );

CURSOR C_check_batch_for_transfers IS
  select 1
  from dual
  where exists ( select 'x'
                 from fa_mass_update_batch_headers a
                 where a.status_code IN ('P', 'E', 'R', 'N', 'IP')
                 and a.book_type_code = x_book_type_code
                 and ( a.event_code IN ( 'CHANGE_NODE_PARENT', 'CHANGE_NODE_ATTRIBUTE',
                                       'CHANGE_NODE_RULE_SET', 'CHANGE_CATEGORY_RULE_SET',
                                       'HR_MASS_TRANSFER', 'CHANGE_CATEGORY_LIFE',
                                       'CHANGE_CATEGORY_LIFE_END_DATE') or
                       ( a.event_code IN ( 'CHANGE_ASSET_PARENT','CHANGE_ASSET_LEASE',
                                           'CHANGE_ASSET_CATEGORY') and
                                          to_number(a.source_entity_key_value) = x_asset_id )
                       ) );

/*
CURSOR C_check_batch IS
  select 1
  from dual
  where exists ( select 'x'
                 from fa_mass_update_batch_headers a
                 where a.status_code IN ('P', 'R')
                 AND EXISTS ( select 'x'
                              from fa_mass_update_batch_details b
                              where a.batch_id = b.batch_id )
                 AND (   ( (source_entity_key_value = x_node_id AND
                                     event_code = 'CHANGE_NODE_ATTRIBUTE')
                            OR (source_attribute_old_id = x_node_id AND
                                     event_code = 'CHANGE_NODE_PARENT')
                         )
                     OR  ( event_code IN ( 'CHANGE_CATEGORY_LIFE', 'CHANGE_CATEGORY_LIFE_END_DATE') AND
                                   to_number(a.source_entity_key_value) = (select asset_category_id
                                                                           from fa_additions
                                                                           where asset_id = x_asset_id )
                         )
                     )
               );
**/

  CURSOR C_check_hr_retirement IS
    select 1
    from dual
    where exists ( select 'X'
                   from fa_hr_retirement_details
                   -- where status_code = 'P' -- msiddiqu 15-feb-2001
                   where status_code IN ('P', 'IP')
                   and asset_id = nvl(x_asset_id, asset_id)
                   and book_type_code = x_book_type_code
                   and ( x_conc_request_id is null OR
                        nvl(concurrent_request_id,0) <> x_conc_request_id ) );

   -- TRUE if txn allowed - FALSE otherwise
   FUNCTION check_book_stats ( x_book     in     varchar2 ,
                               x_status   in out nocopy varchar2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null) return boolean IS

     l_txn_status boolean:= FALSE;
     l_api_version           number       := 1;
     l_init_msg_list         varchar2(1)  := FND_API.G_FALSE;
     l_commit                varchar2(1)  := FND_API.G_FALSE;
     l_validation_level      number       := FND_API.G_VALID_LEVEL_FULL;
     l_return_status         varchar2(1) := FND_API.G_FALSE;
     l_msg_count             number := 0;
     l_msg_data              varchar2(512);
     l_trans_rec              FA_API_TYPES.trans_rec_type;
     l_asset_hdr_rec          FA_API_TYPES.asset_hdr_rec_type;
     l_asset_retire_rec       FA_API_TYPES.asset_retire_rec_type;
     l_asset_dist_tbl         FA_API_TYPES.asset_dist_tbl_type;
     l_subcomp_tbl            FA_API_TYPES.subcomp_tbl_type;
     l_inv_tbl                FA_API_TYPES.inv_tbl_type;
     BEGIN

    -- bugfix2250373
    if NOT FA_CHK_BOOKSTS_PKG.faxcbs(
                     X_book         => X_book,
                     X_submit       => TRUE,
                     X_start        => FALSE,
                     X_asset_id     => 0,
                     X_trx_type     => 'TRANSFER',
                     X_txn_status   => l_txn_status,
                     X_close_period => 0 , p_log_level_rec => p_log_level_rec) then
          x_status := 'CUA_BOOK_IN_USE';
          return FALSE;
     end if;


/*
    -- commented for bug2250373
     if ( NOT FA_CHK_BOOKSTS_PKG.faxcbsx( x_book , p_log_level_rec => p_log_level_rec)) then
             x_status := 'CUA_BOOK_IN_USE';
          return FALSE;
     end if;
*/
       return TRUE;

    END check_book_stats;

BEGIN
  v_dummy:= 0;
  x_status := null;

  IF x_calling_function = 'MASS_ADDITION' then

        if x_event_code = 'ADDITION' then
            OPEN c_check_batch_for_addition ;
            FETCH c_check_batch_for_addition INTO v_dummy;
            CLOSE c_check_batch_for_addition;

            if(v_dummy = 1) then
               x_status := pending_batch;
               return TRUE;
            end if;

        elsif x_event_code = 'ADD_TO_ASSET' then

            OPEN c_check_batch_for_ata;
            FETCH c_check_batch_for_ata INTO v_dummy;
            CLOSE c_check_batch_for_ata;

            if(v_dummy = 1) then
               x_status := pending_batch;
               return TRUE;
            end if;
       end if;
  ELSIF x_calling_function = 'CUA_EXT_TRANSFER' then

       if ( NOT check_book_stats ( x_book_type_code
                                 , x_status
                                 , p_log_level_rec )) then
         return TRUE;
       end if;

       open c_check_batch_for_transfers;
       fetch c_check_batch_for_transfers into v_dummy;
       close c_check_batch_for_transfers;
       if(v_dummy = 1) then
          x_status := pending_batch;
          return TRUE;
       end if;

  ELSIF x_calling_function IN ( 'CUA_HR_RETIREMENTS') then

       if ( NOT check_book_stats ( x_book_type_code
                                   , x_status
                                   , p_log_level_rec)) then
         return TRUE;
       end if;

       open c_check_batch_for_all;
       fetch c_check_batch_for_all into v_dummy;
       close c_check_batch_for_all;
       if(v_dummy = 1) then
          x_status := pending_batch;
          return TRUE;
       end if;
  ELSIF x_calling_function IN ('CUA_EXT_RETIREMENTS', 'MASS_RETIREMENT') then

       open c_check_batch_for_all;
       fetch c_check_batch_for_all into v_dummy;
       close c_check_batch_for_all;
       if(v_dummy = 1) then
          x_status := pending_batch;
          return TRUE;
       end if;
  ELSIF x_calling_function In ('HIERARCHY', 'TRANSACTION', 'DEPRECIATION' ) then

     -- added headers table to join in the select so that the discarded batch headers
     -- are excluded  -- msiddiqu bugfix 1659510
      v_dummy := 0;

      IF (x_attribute is null) THEN

         select 1
         into   v_dummy
         from   dual
         where  exists
         (
          select 'X'
          from fa_mass_update_batch_headers a,
               fa_mass_update_batch_details b
          where a.status_code <> 'C'
          and a.event_code <> 'HR_REINSTATEMENT' -- bugfix for 891822 msiddiqu 25-APR-2001
          and a.batch_id = b.batch_id
          and b.status_code in ('P','R')  -- uncommented for bugfix 1613882
          -- where x_attribute IS NULL
          -- where status_code = 'P'  -- commented for bugfix 1613882
          and b.asset_id = nvl(x_asset_id, b.asset_id)
          and b.book_type_code = x_book_type_code
           );
     ELSIF (x_attribute = 'ASSET_KEY') THEN

         select 1
         into   v_dummy
         from   dual
         where  exists
         (
          select 'X'
          from fa_mass_update_batch_headers a,
               fa_mass_update_batch_details b
          -- where x_attribute IS NOT NULL
          -- where x_attribute = 'ASSET_KEY'
          where a.status_code <> 'C'
          and a.batch_id = b.batch_id
          and b.attribute_name IN ('ASSET_KEY', 'CATEGORY')
          and b.status_code in ( 'P', 'R') -- bugfix 1613882
          -- and status_code = 'P'
          and b.asset_id = nvl(x_asset_id, b.asset_id)
          and b.book_type_code = x_book_type_code
         );

     ELSIF (x_attribute = 'DISTRIBUTION') THEN

         select 1
         into   v_dummy
         from   dual
         where  exists
         (
          select 'X'
          from fa_mass_update_batch_headers a,
               fa_mass_update_batch_details b
          -- where x_attribute IS NOT NULL
          -- where x_attribute = 'DISTRIBUTION'
          where a.status_code <> 'C'
          and a.batch_id = b.batch_id
          and b.attribute_name IN ('DISTRIBUTION', 'CATEGORY')
          and b.asset_id = nvl(x_asset_id, b.asset_id)
          and b.book_type_code = x_book_type_code
         );

      ELSIF (x_attribute = 'LEASE_NUMBER') THEN

         select 1
         into   v_dummy
         from   dual
         where  exists
         (
          select 'X'
          from fa_mass_update_batch_headers a,
               fa_mass_update_batch_details b
          -- where x_attribute IS NOT NULL
          -- where x_attribute = 'LEASE_NUMBER'
          where a.status_code <> 'C'
          and a.batch_id = b.batch_id
          and b.attribute_name IN ('LEASE_NUMBER', 'CATEGORY')
          -- and status_code = 'P' -- bugfix 1613882
          and b.status_code in ( 'P', 'R')
          and b.asset_id = nvl(x_asset_id, b.asset_id)
          and b.book_type_code = x_book_type_code
         );
      ELSIF (x_attribute = 'LIFE_END_DATE') THEN

         select 1
         into   v_dummy
         from   dual
         where  exists
         (
          select 'X'
          from fa_mass_update_batch_headers a,
               fa_mass_update_batch_details b
          -- where x_attribute IS NOT NULL
          -- where x_attribute = 'LIFE_END_DATE'
          where a.status_code <> 'C'
          and a.batch_id = b.batch_id
          and b.attribute_name IN ('CATEGORY', 'LEASE_NUMBER', 'LIFE_END_DATE')
          -- and status_code = 'P' -- bugfix 1613882
          and b.status_code in ( 'P', 'R')
          and b.asset_id = nvl(x_asset_id, b.asset_id)
          and b.book_type_code = x_book_type_code
         );
      ELSIF (x_attribute = 'CATEGORY') THEN

         select 1
         into   v_dummy
         from   dual
         where  exists
         (
          select 'X'
          from fa_mass_update_batch_headers a,
               fa_mass_update_batch_details b
          -- where x_attribute IS NOT NULL
          -- where x_attribute = 'CATEGORY'
          -- if category check for all attributes
          where -- status_code = 'P' -- bugfix 1613882
          a.status_code <> 'C'
          and a.batch_id = b.batch_id
          and b.status_code in ( 'P', 'R')
          and b.asset_id = nvl(x_asset_id, b.asset_id)
          and b.book_type_code = x_book_type_code
         );

       ELSE
           v_dummy := 0;
       END IF;

           if(v_dummy = 1) then
              x_status := 'CUA_ASSET_IN_USE';
              return TRUE;
           end if;

  ELSIF x_calling_function = 'CONCURRENT' then

         OPEN C_check_batch_headers;
         FETCH c_check_batch_headers INTO v_dummy;
         CLOSE c_check_batch_headers;
           if v_dummy = 1 then
              x_status := pending_batch;
              return TRUE;
           end if;
  END IF;  -- x_calling_function

   -- check for hr_retirements
      if x_calling_function = 'MASS_ADDITION' and x_event_code = 'ADDITION' then
          -- skip check for retirements for a new addition
          null;
      else
         OPEN c_check_hr_retirement;
         FETCH c_check_hr_retirement INTO v_dummy;
         CLOSE c_check_hr_retirement;
           if(v_dummy = 1) then
              x_status := pending_book;
              return TRUE;
           end if;
       end if;

    x_status:= null;
    return FALSE;   -- no pending batch

EXCEPTION
  WHEN OTHERS THEN
    return FALSE;
END check_pending_batch;

-- ---------------------------------------------------
-- This procedure insert passed in information into
-- fa_hr_retirement_headers table
-- and returns a batch_id
-- ----------------------------------------------------
PROCEDURE insert_hr_retirement_hdrs(
             x_event_code               IN     VARCHAR2
           , x_book_type_code           IN     VARCHAR2
           , x_status                   IN     VARCHAR2
           , x_node_entity_id           IN     NUMBER
           , x_rejection_reason_code    IN     VARCHAR2
           , x_retirement_method        IN     VARCHAR2
           , x_retirement_type_code     IN     VARCHAR2
           , x_proceeds_of_sale         IN     NUMBER
           , x_cost_of_removal          IN     NUMBER
           , x_retire_date              IN     DATE
           , x_prorate_by               IN     VARCHAR2
           , x_retire_by                IN     VARCHAR2
           , x_retirement_amount        IN     NUMBER
           , x_retirement_percent       IN     NUMBER
           , x_allow_partial_retire_flg IN     VARCHAR2
           , x_retire_units_flg         IN     VARCHAR2
           , x_created_by               IN     NUMBER
           , x_creation_date            IN     DATE
           , x_last_updated_by          IN     NUMBER
           , x_last_update_date         IN     DATE
           , x_last_update_login        IN     NUMBER
           , x_concurrent_request_id    IN     NUMBER
           , x_batch_id                 IN OUT NOCOPY NUMBER
           , x_transaction_name         IN     VARCHAR2
           , x_attribute_category       IN     VARCHAR2
           , x_attribute1               IN     VARCHAR2
           , x_attribute2               IN     VARCHAR2
           , x_attribute3               IN     VARCHAR2
           , x_attribute4               IN     VARCHAR2
           , x_attribute5               IN     VARCHAR2
           , x_attribute6               IN     VARCHAR2
           , x_attribute7               IN     VARCHAR2
           , x_attribute8               IN     VARCHAR2
           , x_attribute9               IN     VARCHAR2
           , x_attribute10              IN     VARCHAR2
           , x_attribute11              IN     VARCHAR2
           , x_attribute12              IN     VARCHAR2
           , x_attribute13              IN     VARCHAR2
           , x_attribute14              IN     VARCHAR2
           , x_attribute15              IN     VARCHAR2
           , TH_attribute_category      IN     VARCHAR2
           , TH_attribute1              IN     VARCHAR2
           , TH_attribute2              IN     VARCHAR2
           , TH_attribute3              IN     VARCHAR2
           , TH_attribute4              IN     VARCHAR2
           , TH_attribute5              IN     VARCHAR2
           , TH_attribute6              IN     VARCHAR2
           , TH_attribute7              IN     VARCHAR2
           , TH_attribute8              IN     VARCHAR2
           , TH_attribute9              IN     VARCHAR2
           , TH_attribute10             IN     VARCHAR2
           , TH_attribute11             IN     VARCHAR2
           , TH_attribute12             IN     VARCHAR2
           , TH_attribute13             IN     VARCHAR2
           , TH_attribute14             IN     VARCHAR2
           , TH_attribute15             IN     VARCHAR2
           , x_err_code                 IN OUT NOCOPY VARCHAR2
           , x_err_stage                IN OUT NOCOPY VARCHAR2
           , x_err_stack                IN OUT NOCOPY VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null) IS

 CURSOR C1 IS
   select fa_hr_retirement_hdrs_s.nextval
   from dual;
 v_old_err_stack VARCHAR2(640);
BEGIN
  x_err_code:= '0';
  v_old_err_stack := x_err_stack;
  x_err_stack:= x_err_stack||'-> Insert_hr_retirement_hdrs';

  x_err_stage:= 'Cursor C1';
  Open C1;
  fetch C1 into x_batch_id;
  close C1;

  x_err_stage:= 'Inserting retirement_headers';
  Insert into fa_hr_retirement_headers(
     event_code
   , book_type_code
   , status_code
   , asset_hierarchy_id
   , rejection_reason_code
   , retirement_method
   , retirement_type_code
   , retire_date
   , prorate_by
   , retire_by
   , retirement_amount
   , retirement_percent
   , allow_partial_retire_flag
   , retire_units_flag
   , created_by
   , creation_date
   , last_updated_by
   , last_update_date
   , last_update_login
   , concurrent_request_id
   , batch_id
   , transaction_name
   , attribute_category
   , attribute1
   , attribute2
   , attribute3
   , attribute4
   , attribute5
   , attribute6
   , attribute7
   , attribute8
   , attribute9
   , attribute10
   , attribute11
   , attribute12
   , attribute13
   , attribute14
   , attribute15
   , th_attribute_category
   , th_attribute1
   , th_attribute2
   , th_attribute3
   , th_attribute4
   , th_attribute5
   , th_attribute6
   , th_attribute7
   , th_attribute8
   , th_attribute9
   , th_attribute10
   , th_attribute11
   , th_attribute12
   , th_attribute13
   , th_attribute14
   , th_attribute15
   , proceeds_of_sale
   , cost_of_removal
   )
  values(
     x_event_code
   , x_book_type_code
   , x_status
   , x_node_entity_id
   , x_rejection_reason_code
   , x_retirement_method
   , x_retirement_type_code
   , x_retire_date
   , x_prorate_by
   , x_retire_by
   , x_retirement_amount
   , x_retirement_percent
   , x_allow_partial_retire_flg
   , x_retire_units_flg
   , x_created_by
   , x_creation_date
   , x_last_updated_by
   , x_last_update_date
   , x_last_update_login
   , x_concurrent_request_id
   , x_batch_id
   , x_transaction_name
   , x_attribute_category
   , x_attribute1
   , x_attribute2
   , x_attribute3
   , x_attribute4
   , x_attribute5
   , x_attribute6
   , x_attribute7
   , x_attribute8
   , x_attribute9
   , x_attribute10
   , x_attribute11
   , x_attribute12
   , x_attribute13
   , x_attribute14
   , x_attribute15
   , TH_attribute_category
   , TH_attribute1
   , TH_attribute2
   , TH_attribute3
   , TH_attribute4
   , TH_attribute5
   , TH_attribute6
   , TH_attribute7
   , TH_attribute8
   , TH_attribute9
   , TH_attribute10
   , TH_attribute11
   , TH_attribute12
   , TH_attribute13
   , TH_attribute14
   , TH_attribute15
   , x_proceeds_of_sale
   , x_cost_of_removal );

  x_err_stack:= v_old_err_stack;

EXCEPTION
  when others then
  -- x_err_code:= sqlerrm;
  x_err_code:= substrb(sqlerrm,1,240);
END insert_hr_retirement_hdrs;

-- --------------------------------------------------
-- This function insert retirement details
-- into FA_HR_RETIREMENT_DETAILS table
-- --------------------------------------------------
PROCEDURE insert_hr_retirement_dtls(
             x_batch_id                   IN     NUMBER
           , x_book_type_code             IN     VARCHAR2
           , x_asset_id                   IN     NUMBER
           , x_date_placed_in_service     IN     DATE
           , x_current_cost               IN     NUMBER
           , x_cost_retired               IN     NUMBER
           , x_current_units              IN     NUMBER
           , x_units_retired              IN     NUMBER
           , x_prorate_percent            IN     NUMBER
           , x_retirement_convention_code IN     VARCHAR2
           , x_status_code                IN     VARCHAR2
           , x_rejection_reason           IN     VARCHAR2
           , x_proceeds_of_sale           IN     NUMBER
           , x_cost_of_removal            IN     NUMBER
           , x_created_by                 IN     NUMBER
           , x_creation_date              IN     DATE
           , x_last_updated_by            IN     NUMBER
           , x_last_update_date           IN     DATE
           , x_last_update_login          IN     NUMBER
           , x_concurrent_request_id      IN     NUMBER
           , x_err_code                   IN OUT NOCOPY VARCHAR2
           , x_err_stage                  IN OUT NOCOPY VARCHAR2
           , x_err_stack                  IN OUT NOCOPY VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null) IS

v_old_err_stack  VARCHAr2(640);
BEGIN
  x_err_code := '0';
  v_old_err_stack := x_err_stack;
  x_err_stack := x_err_stack||'->'||'insert_fa_hr_retirement_dtls';

  insert into fa_hr_retirement_details(
      batch_id
    , book_type_code
    , asset_id
    , date_placed_in_service
    , current_cost
    , cost_retired
    , current_units
    , units_retired
    , prorate_percent
    , retirement_convention_code
    , status_code
    , rejection_reason
    , proceeds_of_sale
    , cost_of_removal
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    , concurrent_request_id )
  values (
    x_batch_id
    , x_book_type_code
    , x_asset_id
    , x_date_placed_in_service
    , x_current_cost
    , x_cost_retired
    , x_current_units
    , x_units_retired
    , x_prorate_percent
    , x_retirement_convention_code
    , x_status_code
    , x_rejection_reason
    , x_proceeds_of_sale
    , x_cost_of_removal
    , x_created_by
    , x_creation_date
    , x_last_updated_by
    , x_last_update_date
    , x_last_update_login
    , x_concurrent_request_id );

x_err_stack:= v_old_err_stack;
EXCEPTION
  when others then
  x_err_code:= substrb(sqlerrm,1,240);
  -- x_err_code := sqlerrm;
END insert_hr_retirement_dtls;


-- --------------------------------------------------
--
-- --------------------------------------------------
PROCEDURE generate_retirement_batch(
          x_event_code               IN     VARCHAR2
        , x_book_type_code           IN     VARCHAR2
        , x_node_entity_id           IN     NUMBER
        , x_retirement_method        IN     VARCHAR2
        , x_retirement_type_code     IN     VARCHAR2
        , x_proceeds_of_sale         IN     NUMBER
        , x_cost_of_removal          IN     NUMBER
        , x_retire_date              IN     DATE
        , x_prorate_by               IN     VARCHAR2
        , x_retire_by                IN     VARCHAR2
        , x_retirement_amount        IN     NUMBER
        , x_retirement_percent       IN     NUMBER
        , x_allow_partial_retire     IN     VARCHAR2
        , x_retire_units             IN     VARCHAR2
        , x_batch_id                 IN OUT NOCOPY NUMBER
        , x_transaction_name         IN     VARCHAR2 DEFAULT NULL
        , x_attribute_category       IN     VARCHAR2 DEFAULT NULL
        , x_attribute1               IN     VARCHAR2 DEFAULT NULL
        , x_attribute2               IN     VARCHAR2 DEFAULT NULL
        , x_attribute3               IN     VARCHAR2 DEFAULT NULL
        , x_attribute4               IN     VARCHAR2 DEFAULT NULL
        , x_attribute5               IN     VARCHAR2 DEFAULT NULL
        , x_attribute6               IN     VARCHAR2 DEFAULT NULL
        , x_attribute7               IN     VARCHAR2 DEFAULT NULL
        , x_attribute8               IN     VARCHAR2 DEFAULT NULL
        , x_attribute9               IN     VARCHAR2 DEFAULT NULL
        , x_attribute10              IN     VARCHAR2 DEFAULT NULL
        , x_attribute11              IN     VARCHAR2 DEFAULT NULL
        , x_attribute12              IN     VARCHAR2 DEFAULT NULL
        , x_attribute13              IN     VARCHAR2 DEFAULT NULL
        , x_attribute14              IN     VARCHAR2 DEFAULT NULL
        , x_attribute15              IN     VARCHAR2 DEFAULT NULL
        , TH_attribute_category      IN     VARCHAR2 DEFAULT NULL
        , TH_attribute1              IN     VARCHAR2 DEFAULT NULL
        , TH_attribute2              IN     VARCHAR2 DEFAULT NULL
        , TH_attribute3              IN     VARCHAR2 DEFAULT NULL
        , TH_attribute4              IN     VARCHAR2 DEFAULT NULL
        , TH_attribute5              IN     VARCHAR2 DEFAULT NULL
        , TH_attribute6              IN     VARCHAR2 DEFAULT NULL
        , TH_attribute7              IN     VARCHAR2 DEFAULT NULL
        , TH_attribute8              IN     VARCHAR2 DEFAULT NULL
        , TH_attribute9              IN     VARCHAR2 DEFAULT NULL
        , TH_attribute10             IN     VARCHAR2 DEFAULT NULL
        , TH_attribute11             IN     VARCHAR2 DEFAULT NULL
        , TH_attribute12             IN     VARCHAR2 DEFAULT NULL
        , TH_attribute13             IN     VARCHAR2 DEFAULT NULL
        , TH_attribute14             IN     VARCHAR2 DEFAULT NULL
        , TH_attribute15             IN     VARCHAR2 DEFAULT NULL
        , x_err_code                 IN OUT NOCOPY VARCHAR2
        , x_err_stage                IN OUT NOCOPY VARCHAR2
        , x_err_stack                IN OUT NOCOPY VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null) IS

v_old_err_stack     VARCHAR2(630);
v_sysdate           DATE;
v_created_by        NUMBER;
v_last_update_login NUMBER;
v_last_updated_by   NUMBER;
v_conc_request_id   NUMBER:= NULL;
v_rejection_reason_code VARCHAR2(30):= NULL;
i                   binary_integer:=0;
v_asset_attr_tab    FA_CUA_DERIVE_ASSET_ATTR_PKG.asset_tabtype;
v_dummy             NUMBER;
v_stop              BOOLEAN:= FALSE;
v_cost_retired      NUMBER;
v_current_units     NUMBER;
v_units_retired     NUMBER;
v_current_cost      NUMBER;
v_cost_remaining    NUMBER;
v_units_remaining   NUMBER;
v_cost_per_unit     NUMBER;
v_total_cost        NUMBER:= 0;
v_total_units       NUMBER:= 0;
v_tot_cost_retired  NUMBER:=0;
v_tot_units_retired NUMBER:= 0;
v_prorate_percent   NUMBER;
v_precision         NUMBER;
v_asset_id          NUMBER;
v_last_cost_retired NUMBER;
v_retirement_convention_code VARCHAR2(30);

v_asset_pos         NUMBER;
v_asset_cor         NUMBER;

TYPE ret_asset_rec_type IS RECORD (
 asset_id             fa_hr_retirement_details.asset_id%TYPE                default null,
 dpis                 fa_hr_retirement_details.date_placed_in_service%TYPE  default null,
 cost                 fa_hr_retirement_details.current_cost%TYPE            default null,
 cost_retired         fa_hr_retirement_details.cost_retired%TYPE            default null,
 units                fa_hr_retirement_details.current_units%TYPE           default null,
 units_retired        fa_hr_retirement_details.units_retired%TYPE           default null,
 prorate_percent      fa_hr_retirement_details.prorate_percent%TYPE         default null,
 ret_prorate_conv     fa_hr_retirement_details.retirement_convention_code%TYPE  default null,
 proceeds_of_sale     fa_hr_retirement_details.proceeds_of_sale%TYPE        default null,
 cost_of_removal      fa_hr_retirement_details.cost_of_removal%TYPE         default null );


TYPE ret_asset_tbl_type IS TABLE OF ret_asset_rec_type index by binary_integer;


ret_tab ret_asset_tbl_type;

-- cursor to get the total_cost and total_units of the qualified assets
-- NOTE: Any changes to this cursor must also be reflected in C_qualified assets
-- Both the cursors must be same
CURSOR C_get_totals IS
  select sum(fab.cost) total_cost
       , sum(fah.units) total_units
  from ( select asset_id
         from fa_asset_hierarchy
         where asset_id IS NOT NULL
         start with asset_hierarchy_id = x_node_entity_id
         connect by prior asset_hierarchy_id = parent_hierarchy_id ) hr
     , fa_asset_history fah
     , fa_category_book_defaults fcbd
     , fa_books fab
     , fa_additions faa
  where hr.asset_id = faa.asset_id
  AND faa.asset_id = fab.asset_id
  AND fab.book_type_code = x_book_type_code
  --  AND fab.cost > 0
  AND faa.asset_id = fah.asset_id
  AND fah.date_ineffective IS NULL
  AND faa.asset_category_id = fcbd.category_id
  AND fab.book_type_code = fcbd.book_type_code
  AND fab.date_placed_in_service
      BETWEEN fcbd.start_dpis
      AND nvl(TO_DATE(fcbd.end_dpis, 'DD-MM-YYYY'),
              TO_DATE('31-12-4712', 'DD-MM-YYYY'))
  AND EXISTS (SELECT 'X'
              FROM FA_TRANSACTION_HEADERS fth
              WHERE fth.asset_id = fab.asset_id
              AND fth.book_type_code = fab.book_type_code
              AND (fth.transaction_date_entered <= x_Retire_Date
              AND fth.transaction_type_code not in ('FULL RETIREMENT',
			    'REINSTATEMENT')))
  AND EXISTS ( SELECT 'X'
               FROM fa_distribution_history fad
                  , gl_code_combinations gcc
               WHERE fad.asset_id = faa.asset_id
               AND fad.code_combination_id = gcc.code_combination_id
               AND fad.date_ineffective IS NULL )
  AND NOT EXISTS ( select 'X'  --'PROCESSED RETIREMENT'
                   from fa_retirements frt,
                        fa_books fb
                   where frt.asset_id = fab.asset_id
                   AND frt.asset_id = fb.asset_id
                   AND frt.transaction_header_id_out is NULL
                   AND frt.status = 'PROCESSED'
                   AND frt.book_type_code = fb.book_type_code
                   AND fb.period_counter_fully_retired is NOT NULL
                   AND fb.transaction_header_id_in =
                                  frt.transaction_header_id_in
                   AND fb.date_ineffective IS NULL )
 AND faa.asset_type IN ('CIP', 'CAPITALIZED', 'EXPENSED')
 AND fab.date_ineffective IS NULL ;

-- cursor to check that a batch in a pending status does
-- not exist with certain attribute changes, for the asset
-- to be retired. If so do not allow the asset to retire.
-- Also this will list oldest assets first
-- based on date_placed_in_service
-- NOTE: This cursor should be same as c_get_totals
--       Any changes should be reflected in c_get_totals
CURSOR C_qualified_assets IS
  select  faa.asset_id
        , faa.asset_number
        , fab.cost
        , fab.date_placed_in_service
        , fcbd.retirement_prorate_convention ret_conv
        , fah.units
        , fab.itc_amount
        , fab.itc_amount_id
  from  ( select asset_id
         from fa_asset_hierarchy
         where asset_id IS NOT NULL
         start with asset_hierarchy_id = x_node_entity_id
         connect by prior asset_hierarchy_id = parent_hierarchy_id ) hr
       , fa_asset_history fah
       , fa_category_book_defaults fcbd
       , fa_books fab
       , fa_additions faa
  where hr.asset_id = faa.asset_id
   AND faa.asset_id = fab.asset_id
   AND fab.book_type_code = x_book_type_code
 --  AND fab.cost > 0
   AND faa.asset_id = fah.asset_id
   AND fah.date_ineffective IS NULL
   AND faa.asset_category_id = fcbd.category_id
   AND fab.book_type_code = fcbd.book_type_code
   AND fab.date_placed_in_service
       BETWEEN fcbd.start_dpis
               AND nvl(TO_DATE(fcbd.end_dpis, 'DD-MM-YYYY'),
                       TO_DATE('31-12-4712', 'DD-MM-YYYY'))
   AND EXISTS (SELECT 'X'
                   FROM FA_TRANSACTION_HEADERS fth
                   WHERE fth.asset_id = fab.asset_id
                   AND fth.book_type_code = fab.book_type_code
                   AND (fth.transaction_date_entered <= x_Retire_Date
			      AND fth.transaction_type_code not in ('FULL RETIREMENT',
								    'REINSTATEMENT')))
   AND EXISTS ( SELECT 'X'
                FROM fa_distribution_history fad
                   , gl_code_combinations gcc
                WHERE fad.asset_id = faa.asset_id
                AND fad.code_combination_id = gcc.code_combination_id
                AND fad.date_ineffective IS NULL )
   AND NOT EXISTS ( select 'X'  --'PROCESSED RETIREMENT'
                   from fa_retirements frt,
                        fa_books fb
                   where frt.asset_id = fab.asset_id
                   AND frt.asset_id = fb.asset_id
                   AND frt.transaction_header_id_out is NULL
                   AND frt.status = 'PROCESSED'
                   AND frt.book_type_code = fb.book_type_code
                   AND fb.period_counter_fully_retired is NOT NULL
                   AND fb.transaction_header_id_in =
                                  frt.transaction_header_id_in
                   AND fb.date_ineffective IS NULL )
   AND faa.asset_type IN ('CIP', 'CAPITALIZED', 'EXPENSED')
   AND fab.date_ineffective IS NULL
   ORDER BY 4 asc;

 CURSOR c_currency_info IS
    select --sob.currency_code
         fc.precision
         --, fc.extended_precision
         --, fc.minimum_accountable_unit
    from gl_sets_of_books sob,
         fa_book_controls fbc,
         fnd_currencies fc
    where fc.currency_code = sob.currency_code
    and fc.enabled_flag = 'Y'
    and fbc.book_type_code = x_book_type_code
    and fbc.set_of_books_id = sob.set_of_books_id;

BEGIN
  x_err_code := '0';
  v_old_err_stack := x_err_stack;
  x_err_stack := x_err_stack||'->'||'generate_retirement_batch';

  x_err_stage:= 'Initializing Parameters';
  v_sysdate:= sysdate;
  v_conc_request_id := fnd_global.conc_request_id;
  v_created_by:= nvl(TO_NUMBER(fnd_profile.value('USER_ID')),-1);
  v_last_updated_by:= v_created_by;
  v_last_update_login:= nvl(TO_NUMBER(fnd_profile.value('LOGIN_ID')),-1);

  x_err_stack:= x_err_stack||'->'||'Insert_hr_retirement_hdrs';
  insert_hr_retirement_hdrs (
             x_event_code
           , x_book_type_code
           , 'IP'
           , x_node_entity_id
           , v_rejection_reason_code
           , x_retirement_method
           , x_retirement_type_code
           , x_proceeds_of_sale
           , x_cost_of_removal
           , x_retire_date
           , x_prorate_by
           , x_retire_by
           , x_retirement_amount
           , x_retirement_percent
           , x_allow_partial_retire
           , x_retire_units
           , v_created_by
           , v_sysdate         -- creation_date
           , v_last_updated_by
           , v_sysdate         -- last_update_date
           , v_last_update_login
           , v_conc_request_id
           , x_batch_id
           , x_transaction_name
           , x_attribute_category
           , x_attribute1
           , x_attribute2
           , x_attribute3
           , x_attribute4
           , x_attribute5
           , x_attribute6
           , x_attribute7
           , x_attribute8
           , x_attribute9
           , x_attribute10
           , x_attribute11
           , x_attribute12
           , x_attribute13
           , x_attribute14
           , x_attribute15
           , TH_attribute_category
           , TH_attribute1
           , TH_attribute2
           , TH_attribute3
           , TH_attribute4
           , TH_attribute5
           , TH_attribute6
           , TH_attribute7
           , TH_attribute8
           , TH_attribute9
           , TH_attribute10
           , TH_attribute11
           , TH_attribute12
           , TH_attribute13
           , TH_attribute14
           , TH_attribute15
           , x_err_code
           , x_err_stage
           , x_err_stack
           , p_log_level_rec );

  if(x_err_code <> '0') then
    return;
  end if;


  x_err_stack:= x_err_stack||'->'||'c_currency_open';
  open c_currency_info;
  fetch c_currency_info into v_precision;
  close c_currency_info;

  -- store the total_cost and total_units for future use
  x_err_stack:= x_err_stack||'->'||'c_get_totals';
  open c_get_totals;
  fetch c_get_totals into v_total_cost, v_total_units;
  Close c_get_totals;

  if(x_prorate_by = 'COST') then
    v_cost_remaining:= nvl(x_retirement_amount, 0);
  elsif (x_prorate_by = 'UNITS') then
    v_units_remaining:= nvl(x_retirement_amount, 0);
  end if;

  FOR qualified_asset_rec IN C_qualified_assets LOOP
   if x_retirement_method = 'FIFO' then
       if x_prorate_by = 'COST' then
          if x_retire_by = 'AMOUNT' then
                if(qualified_asset_rec.cost <= v_cost_remaining) then
                   -- completely retire asset
                   v_cost_retired:= qualified_asset_rec.cost;
                   v_cost_remaining:= v_cost_remaining - v_cost_retired;
                     if(x_retire_units = 'Y' ) then
                       v_units_retired := qualified_asset_rec.units;
                     else
                       v_units_retired:= 0;
                     end if;
                elsif( x_allow_partial_retire = 'Y' AND
                   qualified_asset_rec.cost > v_cost_remaining ) then
                   -- partially retire an asset
                   v_cost_retired:= v_cost_remaining;
                   v_cost_remaining:= 0;
                   if(x_retire_units = 'Y' ) then
                       v_units_retired := ROUND( ( (v_cost_remaining /qualified_asset_rec.cost)
                                                * qualified_asset_rec.units) , v_precision );
                     else
                       v_units_retired:= 0;
                     end if;
                   --v_current_units:= qualified_asset_rec.units;
                else
                  v_cost_retired:= 0;
                  v_units_retired:= 0;
                end if;
          elsif x_retire_by = 'PERCENT' then
                -- first determine the net cost after applying percentage
                -- this determines the pool to be used for retirement
                -- subtract total_cost retired to keep it running amount
                v_cost_remaining:= ROUND(x_retirement_percent
                                         * v_total_cost/100, v_precision)
                                         - v_tot_cost_retired ;
                if(qualified_asset_rec.cost <= v_cost_remaining) then
                   -- completely retire asset
                   v_cost_retired:= qualified_asset_rec.cost;
                   v_cost_remaining:= v_cost_remaining - v_cost_retired;
                   if(x_retire_units = 'Y' ) then
                     v_units_retired := qualified_asset_rec.units;
                   else
                     v_units_retired:= 0;
                   end if;
                elsif( x_allow_partial_retire = 'Y' AND
                   qualified_asset_rec.cost > v_cost_remaining ) then
                   -- partially retire an asset
                   v_cost_retired:= v_cost_remaining;
                   v_cost_remaining:= 0;
                   if(x_retire_units = 'Y' ) then
                     v_units_retired := ROUND( ( (v_cost_remaining /qualified_asset_rec.cost)
                                                * qualified_asset_rec.units) , v_precision );
                   else
                     v_units_retired:= 0;
                   end if;
                else
                   v_cost_retired:= 0;
                   v_units_retired:= 0;
                end if;
           end if;  -- x_retire_by
       elsif x_prorate_by = 'UNITS' then -- x_retirement_amount= total_units
           if x_retire_by = 'AMOUNT' then
                if( qualified_asset_rec.units <= v_units_remaining ) then
                   -- completely retire asset and units
                   v_cost_retired:= qualified_asset_rec.cost;
                   v_units_retired:= qualified_asset_rec.units;
                   v_units_remaining:= v_units_remaining - v_units_retired;
                elsif( qualified_asset_rec.units > v_units_remaining
                                                 AND x_allow_partial_retire = 'Y' ) then
                   -- partially retire an asset
                   v_units_retired:= v_units_remaining;
                   v_cost_retired:= ROUND( ( (v_units_remaining/qualified_asset_rec.units)
                                              * qualified_asset_rec.cost), v_precision);
                   v_units_remaining:= 0;
               else
                  v_cost_retired:= 0;
                  v_units_retired:= 0;
               end if;
            elsif x_retire_by = 'PERCENT' then
               v_units_remaining:= ROUND( x_retirement_percent
                                         * v_total_units/100, v_precision )
                                         - v_tot_units_retired;
               if(v_units_remaining >= qualified_asset_rec.units ) then
                  v_cost_retired:= qualified_asset_rec.cost;
                  v_units_retired:= qualified_asset_rec.units;
                  v_units_remaining:= v_units_remaining - v_units_retired;
               elsif (x_allow_partial_retire = 'Y' AND
                 qualified_asset_rec.units > v_units_remaining ) then
                 -- partially retire an asset
                 v_units_retired:= v_units_remaining;
                 v_cost_retired:= ROUND( ( (v_units_remaining/qualified_asset_rec.units)
                                              * qualified_asset_rec.cost), v_precision);
                 v_units_remaining:= 0;
               else
                 v_cost_retired:= 0;
                 v_units_retired:= 0;
               end if;
            end if; --x_retire_by
         end if; -- x_prorate_by
   elsif x_retirement_method = 'PRORATE' then
         if x_prorate_by = 'COST'  then
             if x_retire_by = 'PERCENT' then
                -- in this case an asset is always partially retired

                v_cost_retired:= ROUND( qualified_asset_rec.cost *
                                   x_retirement_percent /100, v_precision);
                if( x_retire_units = 'Y') then
                   v_units_retired:= ROUND( qualified_asset_rec.units *
                                   x_retirement_percent /100, v_precision);
                else
                   v_units_retired:= 0;
                end if;
             elsif x_retire_by = 'AMOUNT' then
                v_prorate_percent:= ROUND(qualified_asset_rec.cost * 100
                                          /v_total_cost, v_precision);
                v_cost_retired:= ROUND( x_retirement_amount * v_prorate_percent/100, v_precision );
                if(v_cost_retired > qualified_asset_rec.cost) then
                   v_cost_retired:= qualified_asset_rec.cost;
                end if;
                if( x_retire_units = 'Y') then
                   v_units_retired:= ROUND( ( v_cost_retired * qualified_asset_rec.units
                                              /qualified_asset_rec.cost), v_precision );
                else
                   v_units_retired:= 0;
                end if;

             end if;  --x_retire_by
         elsif x_prorate_by = 'UNITS' then
            if x_retire_by = 'PERCENT' then
               -- in this case an asset is always partially retired
               v_cost_retired:= ROUND( qualified_asset_rec.cost
                                 * nvl(x_retirement_percent, 0)/100, v_precision);
               v_units_retired:= ROUND( qualified_asset_rec.units
                                  * nvl(x_retirement_percent, 0)/100, v_precision);
            elsif x_retire_by = 'AMOUNT' then
               v_prorate_percent:= ROUND( (qualified_asset_rec.units * 100
                                           /v_total_units), v_precision );

               v_units_retired:= ROUND( x_retirement_amount * v_prorate_percent/100, v_precision );
               if(v_units_retired > qualified_asset_rec.units ) then
                  v_units_retired:= qualified_asset_rec.units;
               end if;
               v_cost_retired:= ROUND( qualified_asset_rec.cost * v_units_retired
                                          /qualified_asset_rec.units ,v_precision);
            end if; -- x_retire_by
         end if; -- x_prorate_by
   end if;

  -- if current_cost is zero then allow to insert
  -- if cost_retired is zero and current_cost is not zero, do not insert
  if( qualified_asset_rec.cost <> 0 and v_cost_retired = 0) then
      null;
  else
--  for enhancement 988193
      i := i+1;

      ret_tab(i).asset_id         := qualified_asset_rec.asset_id;
      ret_tab(i).dpis             := qualified_asset_rec.date_placed_in_service;
      ret_tab(i).cost             := nvl(qualified_asset_rec.cost, 0);
      ret_tab(i).cost_retired     := nvl(v_cost_retired, 0);
      ret_tab(i).units            := nvl(qualified_asset_rec.units, 0);
      ret_tab(i).units_retired    := nvl(v_units_retired, 0);
      ret_tab(i).prorate_percent  := nvl(v_prorate_percent, 0);
      ret_tab(i).ret_prorate_conv := qualified_asset_rec.ret_conv;

      v_tot_cost_retired:= v_tot_cost_retired + v_cost_retired;
      v_tot_units_retired:= v_tot_units_retired + v_units_retired;
      v_cost_retired:= 0;
      v_units_retired:= 0;
      v_prorate_percent:= 0;
   end if;

   if(x_prorate_by = 'FIFO') then
     if( ( x_prorate_by = 'COST' AND v_cost_remaining <= 0) OR
           ( x_prorate_by = 'UNITS' AND v_units_remaining <= 0) ) then
         exit;
     end if;
   end if;

END LOOP;

-- get the total_cost being retired to spread the pos and cor amounts
if ( nvl(x_proceeds_of_sale, 0) <> 0  or
     nvl(x_cost_of_removal, 0 ) <> 0 ) then

     v_tot_cost_retired := 0;
     FOR i in 1..ret_tab.count LOOP
         v_tot_cost_retired := v_tot_cost_retired + ret_tab(i).cost_retired;
     END LOOP;
end if;

  i:= 0;
  FOR i in 1..ret_tab.count LOOP
    if ( nvl(x_proceeds_of_sale, 0) <> 0 ) then
       ret_tab(i).proceeds_of_sale :=
                  x_proceeds_of_sale * ( ret_tab(i).cost_retired/v_tot_cost_retired );
    end if;

    if ( nvl(x_cost_of_removal, 0 ) <> 0 ) then
       ret_tab(i).cost_of_removal :=
                  x_cost_of_removal * ( ret_tab(i).cost_retired/v_tot_cost_retired);
    end if;

    x_err_stack:= x_err_stack||'->'||'Insert_hr_retirement_dtls';
    insert_hr_retirement_dtls(
        x_batch_id
      , x_book_type_code
      , ret_tab(i).asset_id
      , ret_tab(i).dpis
      , ret_tab(i).cost
      , ret_tab(i).cost_retired
      , ret_tab(i).units
      , ret_tab(i).units_retired
      , ret_tab(i).prorate_percent
      , ret_tab(i).ret_prorate_conv
      , 'IP' --x_status_code
      , v_rejection_reason_code
      , ret_tab(i).proceeds_of_sale
      , ret_tab(i).cost_of_removal
      , v_created_by
      , v_sysdate  --v_creation_date
      , v_last_updated_by
      , v_sysdate --v_last_update_date
      , v_last_update_login
      , v_conc_request_id
      , x_err_code
      , x_err_stage
      , x_err_stack
      , p_log_level_rec );


/** commneted out for enhancement 988193

    x_err_stack:= x_err_stack||'->'||'Insert_hr_retirement_dtls';
    insert_hr_retirement_dtls(
        x_batch_id
      , x_book_type_code
      , qualified_asset_rec.asset_id
      , qualified_asset_rec.date_placed_in_service
      , nvl(qualified_asset_rec.cost, 0)
      , nvl(v_cost_retired, 0)
      , nvl(qualified_asset_rec.units, 0)
      , nvl(v_units_retired, 0)
      , nvl(v_prorate_percent, 0)
      , qualified_asset_rec.retirement_prorate_convention
      , 'IP' --x_status_code
      , v_rejection_reason_code
      , nvl(v_asset_pos, 0)
      , nvl(v_asset_cor, 0)
      , v_created_by
      , v_sysdate  --v_creation_date
      , v_last_updated_by
      , v_sysdate --v_last_update_date
      , v_last_update_login
      , v_conc_request_id
      , x_err_code
      , x_err_stage
      , x_err_stack );

    end if;
**/

 END LOOP;

commit;

EXCEPTION
  when others then

   x_err_code:= substrb(sqlerrm, 1, 240);
   raise;
END generate_retirement_batch;


PROCEDURE conc_request( ERRBUF OUT NOCOPY VARCHAR2,
                        RETCODE OUT NOCOPY VARCHAR2,
                        x_from_batch_num IN NUMBER,
                        x_to_batch_num IN NUMBER ) IS
  v_conc_request_id NUMBER;
  v_dummy VARCHAR2(1):= 'N';
  v_ret_value NUMBER;

  CURSOR c_hrh IS
  select *
  from fa_hr_retirement_headers
  where batch_id >= nvl(x_from_batch_num, batch_id )
  AND batch_id <= nvl(x_to_batch_num, batch_id)
  AND status_code IN ('IP', 'P', 'RC')
  order by creation_date
  FOR UPDATE NOWAIT;

BEGIN
  RETCODE:= '0';
  BEGIN
    v_conc_request_id := fnd_global.conc_request_id;

    for hrh_rec IN c_hrh LOOP
       update fa_hr_retirement_headers
       set status_code = 'IP'
       where batch_id = hrh_rec.batch_id;

       update fa_hr_retirement_details
       set status_code = 'IP'
       where batch_id = hrh_rec.batch_id;

       commit;

       post_hr_retirements ( hrh_rec.batch_id
                           , hrh_rec.retire_date
                           , hrh_rec.retirement_type_code
                           , hrh_rec.transaction_name
                           , hrh_rec.attribute_category
                           , hrh_rec.attribute1
                           , hrh_rec.attribute2
                           , hrh_rec.attribute3
                           , hrh_rec.attribute4
                           , hrh_rec.attribute5
                           , hrh_rec.attribute6
                           , hrh_rec.attribute7
                           , hrh_rec.attribute8
                           , hrh_rec.attribute9
                           , hrh_rec.attribute10
                           , hrh_rec.attribute11
                           , hrh_rec.attribute12
                           , hrh_rec.attribute13
                           , hrh_rec.attribute14
                           , hrh_rec.attribute15
                           , hrh_rec.TH_attribute_category
                           , hrh_rec.TH_attribute1
                           , hrh_rec.TH_attribute2
                           , hrh_rec.TH_attribute3
                           , hrh_rec.TH_attribute4
                           , hrh_rec.TH_attribute5
                           , hrh_rec.TH_attribute6
                           , hrh_rec.TH_attribute7
                           , hrh_rec.TH_attribute8
                           , hrh_rec.TH_attribute9
                           , hrh_rec.TH_attribute10
                           , hrh_rec.TH_attribute11
                           , hrh_rec.TH_attribute12
                           , hrh_rec.TH_attribute13
                           , hrh_rec.TH_attribute14
                           , hrh_rec.TH_attribute15
                           , v_conc_request_id
                           , g_log_level_rec);

       -- check if there are any line unprocessed or Rejected
          v_dummy := 'N';

      Begin
        select 'Y'
        into v_dummy
        from fa_hr_retirement_details
        where batch_id = hrh_rec.batch_id
        and status_code in ('IP','R')
        and rownum = 1;
      Exception
        When others then
           null;
       End ;

        if v_dummy = 'Y' then
          v_dummy:= 'N';
    	  update fa_hr_retirement_headers
    	  set status_code = 'R' -- Rejected Processed
            , concurrent_request_id = v_conc_request_ID
            , last_updated_by = fnd_global.login_id
            , last_update_date = sysdate
            , last_update_login = fnd_global.login_id
    	  where batch_id = hrh_rec.batch_id;

          Update fa_hr_retirement_details
          set status_code = 'P'
          where status_code <> 'R'
          and batch_id = hrh_rec.batch_id;
        else
          update fa_hr_retirement_headers
          set status_code = 'CP' -- Completetly Processed
            , concurrent_request_id = v_conc_request_ID
            , last_updated_by = fnd_global.login_id
            , last_update_date = sysdate
            , last_update_login = fnd_global.login_id
          where batch_id = hrh_rec.batch_id;
        end if;

        commit;

      END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      RETCODE := '2';
      ERRBUF := substrb(SQLERRM, 1, 240);
  END;

  if RETCODE = '0' then
       commit;
 end if;

END conc_request;



PROCEDURE post_hr_retirements ( x_batch_id             IN NUMBER
                              , x_retire_date          IN DATE
                              , x_retirement_type_code IN VARCHAR2
                              , x_transaction_name     IN VARCHAR2
                              , x_attribute_category   IN VARCHAR2
                              , x_attribute1           IN VARCHAR2
                              , x_attribute2           IN VARCHAR2
                              , x_attribute3           IN VARCHAR2
                              , x_attribute4           IN VARCHAR2
                              , x_attribute5           IN VARCHAR2
                              , x_attribute6           IN VARCHAR2
                              , x_attribute7           IN VARCHAR2
                              , x_attribute8           IN VARCHAR2
                              , x_attribute9           IN VARCHAR2
                              , x_attribute10          IN VARCHAR2
                              , x_attribute11          IN VARCHAR2
                              , x_attribute12          IN VARCHAR2
                              , x_attribute13          IN VARCHAR2
                              , x_attribute14          IN VARCHAR2
                              , x_attribute15          IN VARCHAR2
                              , TH_attribute_category  IN VARCHAR2
                              , TH_attribute1          IN VARCHAR2
                              , TH_attribute2          IN VARCHAR2
                              , TH_attribute3          IN VARCHAR2
                              , TH_attribute4          IN VARCHAR2
                              , TH_attribute5          IN VARCHAR2
                              , TH_attribute6          IN VARCHAR2
                              , TH_attribute7          IN VARCHAR2
                              , TH_attribute8          IN VARCHAR2
                              , TH_attribute9          IN VARCHAR2
                              , TH_attribute10         IN VARCHAR2
                              , TH_attribute11         IN VARCHAR2
                              , TH_attribute12         IN VARCHAR2
                              , TH_attribute13         IN VARCHAR2
                              , TH_attribute14         IN VARCHAR2
                              , TH_attribute15         IN VARCHAR2
                              , x_conc_request_id      IN NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type    default null) IS

CURSOR c_hrd IS
  select batch_id,
  asset_id,
  cost_retired,
  current_cost,
  current_units,
  units_retired,
  book_type_code,
  status_code,
  retirement_convention_code
  from fa_hr_retirement_details
  where batch_id = x_batch_id
  order by date_placed_in_service asc;

CURSOR c_dist_lines(x_book_type_code IN VARCHAR2
                    , x_asset_id IN NUMBER ) IS
  select distribution_id
       , code_combination_id
       , units_assigned
       , location_id
       , assigned_to
       , date_effective
       , transaction_header_id_in
  from fa_distribution_history
  where book_type_code = x_book_type_code
  and   asset_id = x_asset_id
  and   date_ineffective IS NULL;
  --order by date_effective asc;

  lv_it_rowid		rowid;
  lv_ret_id		number;
  lv_sl_cost_retired	number;
  lv_sl_count		number := 0;
  lv_new_inv_txn_id	number;

  -- variables for validation
  lv_cost		        number;
  lv_current_units		number;
  lv_current_period_counter	number;
  lv_asset_added_pc	 	number;
  lv_current_fiscal_year	number;
  lv_stl_life_in_months		number;
  lv_val_count			number;
  lv_asset_id               NUMBER;

  lv_date_retired			date;
  lv_fy_start_date		    date;
  lv_fy_end_date			date;
  lv_cal_per_close_date		date;
  lv_cal_per_open_date      date;
  lv_max_txn_date_entered	date;

  lv_book_class			    varchar2(15);
  lv_asset_type			    varchar2(11);
  lv_ret_prorate_convention	varchar2(10);
  lv_use_stl_ret_flag		varchar2(3);
  lv_stl_method_code		varchar2(4);
  lv_message			    varchar2(50);
  lv_app				    varchar2(3);
  Validation_Error		    exception;
  Duplicate_Req			    exception;

  v_sysdate               DATe;
  v_old_err_stack         VARCHAR2(640);
  v_rejection_reason      VARCHAR2(80);
  v_varchar_dummy         VARCHAR2(80);
  v_error_flag            VARCHAR2(1);
  v_err_code              VARCHAR2(640);
  v_err_stack             VARCHAR2(640);
  v_err_stage             VARCHAR2(640);
  v_message_name          VARCHAR2(240);
  v_retire_flag           VARCHAR2(1);

  v_retirement_id         NUMBER;
  v_conc_request_id       NUMBER;
  v_user                  NUMBER;
  v_last_update_login     NUMBER;
  v_number_dummy          NUMBER(15);
  v_date_dummy            DATE;
  v_units_retired         NUMBER;
  v_transaction_header_id NUMBER;
  v_distribution_id       NUMBER;
  v_book_header_id        NUMBER;
  v_units_remaining       NUMBER;
  v_count number:=0;
  v_no_of_dist_lines number:= 0;
  v_transaction_units number:= NULL;
  v_running_units number:=0;

  l_trans_rec              FA_API_TYPES.trans_rec_type;
  l_dist_trans_rec         FA_API_TYPES.trans_rec_type;
  l_asset_hdr_rec          FA_API_TYPES.asset_hdr_rec_type;
  l_asset_retire_rec       FA_API_TYPES.asset_retire_rec_type;
  l_asset_dist_tbl         FA_API_TYPES.asset_dist_tbl_type;
  l_subcomp_tbl            FA_API_TYPES.subcomp_tbl_type;
  l_inv_tbl                FA_API_TYPES.inv_tbl_type;

  /* misc info */
  l_api_version           number := 1;
  l_init_msg_list         varchar2(1) := FND_API.G_FALSE;
  l_commit                varchar2(1) := FND_API.G_TRUE;
  l_validation_level      number := FND_API.G_VALID_LEVEL_FULL;
  l_return_status         varchar2(1) := FND_API.G_FALSE;
  l_msg_count             number := 0;
  l_msg_data              varchar2(512);


TYPE ErrorRecTyp IS RECORD(
	rejection_reason	VARCHAR2(250) );

TYPE ErrorTabTyp IS TABLE OF ErrorRecTyp
INDEX BY BINARY_INTEGER;

v_Error_Tab  ErrorTabTyp;  -- error table

v_encoded_message varchar2(640);
v_app_short_name varchar2(3);

error_found exception;

BEGIN
  v_err_code := '0';

  -- initializing parameters
  v_sysdate:= sysdate;
  v_user:= nvl(TO_NUMBER(fnd_profile.value('USER_ID')),-1);
  v_last_update_login:= nvl(TO_NUMBER(fnd_profile.value('LOGIN_ID')),-1);

  FOR hrd_rec IN C_hrd LOOP

     --initialize for each loop
     v_varchar_dummy:= null;
     v_retirement_id := NULL;
     v_number_dummy:= null;
     v_date_dummy:= null;
     v_transaction_header_id := null;
     v_book_header_id:= null;
     v_count := 0;


     BEGIN
        /* set required but null parameters to default values */
        if x_retire_date is not null then
 	      lv_date_retired:= x_retire_date;
        end if;

        if hrd_rec.Retirement_Convention_code is not null then
   	      lv_ret_prorate_convention:= hrd_rec.Retirement_Convention_code;
        end if;


        l_asset_hdr_rec.asset_id := hrd_rec.Asset_Id;
        l_asset_hdr_rec.book_type_code := hrd_rec.Book_Type_Code;
        l_asset_retire_rec.date_retired  :=  v_date_dummy;
        l_asset_retire_rec.cost_retired  := hrd_rec.Cost_Retired;
        l_asset_retire_rec.retirement_prorate_convention:= hrd_rec.Retirement_Convention_code;
        l_asset_retire_rec.units_retired := hrd_rec.units_retired;
        l_asset_retire_rec.desc_flex.Attribute1 := x_Attribute1;
        l_asset_retire_rec.desc_flex.Attribute2 := x_Attribute2;
        l_asset_retire_rec.desc_flex.Attribute3 := x_Attribute3;
        l_asset_retire_rec.desc_flex.Attribute4 := x_Attribute4;
        l_asset_retire_rec.retirement_type_code := x_Retirement_Type_Code;
        l_asset_retire_rec.desc_flex.Attribute5 := x_Attribute5;
        l_asset_retire_rec.desc_flex.Attribute6 := x_Attribute6;
        l_asset_retire_rec.desc_flex.Attribute7 := x_Attribute7;
        l_asset_retire_rec.desc_flex.Attribute8 := x_Attribute8;
        l_asset_retire_rec.desc_flex.Attribute9 := x_Attribute9;
        l_asset_retire_rec.desc_flex.Attribute10 := x_Attribute10;
        l_asset_retire_rec.desc_flex.Attribute11 := x_Attribute11;
        l_asset_retire_rec.desc_flex.Attribute12 := x_Attribute12;
        l_asset_retire_rec.desc_flex.Attribute13 := x_Attribute13;
        l_asset_retire_rec.desc_flex.Attribute14 := x_Attribute14;
        l_asset_retire_rec.desc_flex.Attribute15 := x_Attribute15;
        l_asset_retire_rec.desc_flex.attribute_category_code := x_Attribute_Category;
        l_trans_rec.desc_flex.Attribute1 := TH_Attribute1;
        l_trans_rec.desc_flex.Attribute2 := TH_Attribute2;
        l_trans_rec.desc_flex.Attribute3 := TH_Attribute3;
        l_trans_rec.desc_flex.Attribute4 := TH_Attribute4;
        l_trans_rec.desc_flex.Attribute5 := TH_Attribute5;
        l_trans_rec.desc_flex.Attribute6 := TH_Attribute6;
        l_trans_rec.desc_flex.Attribute7 := TH_Attribute7;
        l_trans_rec.desc_flex.Attribute8 := TH_Attribute8;
        l_trans_rec.desc_flex.Attribute9 := TH_Attribute9;
        l_trans_rec.desc_flex.Attribute10 := TH_Attribute10;
        l_trans_rec.desc_flex.Attribute11 := TH_Attribute11;
        l_trans_rec.desc_flex.Attribute12 := TH_Attribute12;
        l_trans_rec.desc_flex.Attribute13 := TH_Attribute13;
        l_trans_rec.desc_flex.Attribute14 := TH_Attribute14;
        l_trans_rec.desc_flex.Attribute15 := TH_Attribute15;
        l_trans_rec.desc_flex.attribute_category_code := TH_Attribute_Category;
        l_trans_rec.transaction_name := x_transaction_name;

        if (nvl( hrd_rec.units_retired, 0) <> 0  AND
            hrd_rec.units_retired < hrd_rec.current_units ) then

            -- partially retire the units
            -- 1. transfer out the dist line
            -- 2. call retire process

            -- then retire the oldest distribution first
            FOR dl_rec in c_dist_lines(hrd_rec.book_type_code,
                                       hrd_rec.asset_id        )  LOOP
                v_count:= v_count +1;
                if (v_no_of_dist_lines  > 0) and (v_count = v_no_of_dist_lines) then
                    -- Last Dist line to Adjust
                    -- Therefore assign it the Remaining Units
                    v_transaction_units := hrd_rec.units_retired - v_running_units;
                else
                    v_transaction_units := (dl_rec.units_assigned/hrd_rec.current_units)*hrd_rec.units_retired;
                    -- v_transaction_units := round(v_transaction_units,2);
                end if;

                v_running_units := v_running_units + v_transaction_units;

                v_varchar_dummy:= NULL;
                v_number_dummy:= NULL;
                if(v_transaction_units <>0 ) then
                   l_asset_dist_tbl(v_count).distribution_id   := dl_rec.distribution_id;
                   l_asset_dist_tbl(v_count).transaction_units := v_transaction_units;
                end if;

            END LOOP;

        elsif (hrd_rec.units_retired = hrd_rec.current_units) OR ( nvl(hrd_rec.units_retired, 0) = 0 ) then
           -- fully retire the asset
           -- call retire package
           null;
        else
          v_error_flag:= 'Y';
          fnd_message.set_name ('OFA','FA_RET_UNITS_TOO_BIG');
          v_error_tab(hrd_rec.asset_id).rejection_reason := substrb(fnd_message.get, 1, 240);
          raise error_found;
        end if;

        FA_RETIREMENT_PUB.do_retirement(
               p_api_version               => l_api_version
              ,p_init_msg_list             => l_init_msg_list
              ,p_commit                    => l_commit
              ,p_validation_level          => l_validation_level
              ,p_calling_fn                => 'FA_CUA_HR_RETIRMENTS_PKG.Partial_Unit_Retire'
              ,x_return_status             => l_return_status
              ,x_msg_count                 => l_msg_count
              ,x_msg_data                  => l_msg_data

              ,px_trans_rec                => l_trans_rec
              ,px_dist_trans_rec           => l_dist_trans_rec
              ,px_asset_hdr_rec            => l_asset_hdr_rec
              ,px_asset_retire_rec         => l_asset_retire_rec
              ,p_asset_dist_tbl            => l_asset_dist_tbl
              ,p_subcomp_tbl               => l_subcomp_tbl
              ,p_inv_tbl                   => l_inv_tbl);


        if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then

           raise error_found;
        end if;

      EXCEPTION
        WHEN ERROR_FOUND THEN
          v_encoded_message:= fnd_message.get_encoded;
          fnd_message.parse_encoded( v_encoded_message
                                   , v_app_short_name
                                   , v_message_name );

          if ( v_app_short_name IS NOT NULL) AND
               (substrb(v_app_short_name, 1, 3) IN ('CUA', 'OFA' )  ) then
               fnd_message.set_encoded(v_encoded_message);
               v_error_tab(hrd_rec.asset_id).rejection_reason := substrb(fnd_message.get, 1, 240);
          else
               v_error_tab(hrd_rec.asset_id).rejection_reason := substrb(sqlerrm,1,240);
          end if;


        WHEN OTHERS THEN
          v_error_flag := 'Y';
          v_encoded_message:= NULL;
          v_app_short_name:= NULL;
          v_message_name:= NULL;

          v_encoded_message:= fnd_message.get_encoded;
          fnd_message.parse_encoded( v_encoded_message
                                   , v_app_short_name
                                   , v_message_name );

          if ( v_app_short_name IS NOT NULL) AND
               (substrb(v_app_short_name, 1, 3) IN ('CUA', 'OFA' )  ) then
               fnd_message.set_encoded(v_encoded_message);
               v_error_tab(hrd_rec.asset_id).rejection_reason := substrb(fnd_message.get, 1, 240);
          else
               v_error_tab(hrd_rec.asset_id).rejection_reason := substrb(sqlerrm,1,240);
          end if;

      END;

      update fa_hr_retirement_details
      set retirement_id = v_retirement_id
      where batch_id = hrd_rec.batch_id
      and asset_id = hrd_rec.asset_id;

END LOOP;

  if(v_error_flag = 'Y') then
    rollback;

      FOR hrd_rec in c_hrd LOOP
        if v_error_tab.exists(hrd_rec.asset_id) then
    	  UPDATE fa_hr_retirement_details
    	  SET status_code = 'R'
            , rejection_reason = v_error_tab(hrd_rec.asset_id).rejection_reason
            , concurrent_request_id = x_conc_request_id
            , last_updated_by = v_user
            , last_update_date = v_sysdate
            , last_update_login = v_last_update_login
          WHERE asset_id = hrd_rec.asset_id
    	  and batch_id = x_batch_id;
        end if;
      END LOOP;
   else
      -- if successfull
      UPDATE fa_hr_retirement_details
    	  SET status_code = 'A'
            , rejection_reason = null
            , concurrent_request_id = x_conc_request_id
           -- , retirement_id = v_retirement_id
            , last_updated_by = v_user
            , last_update_date = v_sysdate
            , last_update_login = v_last_update_login
          WHERE batch_id = x_batch_id;
   end if;

   COMMIT;
Exception
  WHEN OTHERS THEN
    null;
END post_hr_retirements;


END FA_CUA_HR_RETIREMENTS_PKG;

/
