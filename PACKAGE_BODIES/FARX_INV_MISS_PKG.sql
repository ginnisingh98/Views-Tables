--------------------------------------------------------
--  DDL for Package Body FARX_INV_MISS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FARX_INV_MISS_PKG" as
/* $Header: farximb.pls 120.5.12010000.3 2009/07/19 13:39:40 glchen ship $ */

procedure miss_asset(
        inventory_name     in   varchar2,
        request_id         in   number,
        user_id            in   number,
        retcode            out nocopy  number,
        errbuf             out nocopy varchar2) is

  h_login_id            number;
  h_asset_number        varchar2(25);
  h_description         varchar2(80);

  h_concat_key                varchar2(500);
  h_key_segs                  fa_rx_shared_pkg.Seg_Array;
  h_key_structure             number;

  h_cat_structure             number;
  h_concat_cat                varchar2(500);
  h_cat_segs                  fa_rx_shared_pkg.Seg_Array;

  h_concat_loc          varchar2(500);
  h_loc_segs            fa_rx_shared_pkg.Seg_Array;

  h_loc_structure       number;

  h_inventory_name      varchar2(80);
  h_request_id          number;
  h_segment_num         number;

  h_mesg_name           varchar2(50);
  h_mesg_str            varchar2(2000);
  h_flex_error          varchar2(5);
  h_ccid_error          number;


Cursor c_main is
SELECT inv.inventory_name,
       ad.asset_number,
       ad.description,
       dh.units_assigned,
       dh.location_id,
       ad.tag_number,
       bk.date_placed_in_service,
       ad.serial_number,
       ad.manufacturer_name,
       ad.model_number,
       ad.asset_category_id,
       ad.asset_key_ccid
FROM   fa_books bk,
       fa_distribution_history dh,
       fa_inventory inv,
       fa_additions ad,
       fa_book_controls_sec bc --Bug#3503643
WHERE  ad.inventorial   = 'YES'
AND    ad.asset_id      = bk.asset_id
AND    bk.date_ineffective is null
AND    bk.period_counter_fully_retired is null
AND    bk.book_type_code  = bc.book_type_code
AND    inv.inventory_name = h_inventory_name
AND    inv.start_date  > bk.date_placed_in_service
AND    bc.book_class    = 'CORPORATE'
AND    bc.book_type_code  = dh.book_type_code
AND    dh.asset_id      = ad.asset_id
AND    dh.date_ineffective is null
AND    ad.asset_id not in
(
 select itf.asset_id
 from   fa_inv_interface itf
 where  itf.inventory_name = inv.inventory_name
 and    itf.asset_id = ad.asset_id
);

c_mainrec c_main%rowtype;

begin
--raise no_data_found;
  h_inventory_name := inventory_name;
  h_request_id := request_id;

  h_mesg_name := 'FA_FA_LOOKUP_IN_SYSTEM_CTLS';

  select location_flex_structure,
         asset_key_flex_structure,
         category_flex_structure
  into   h_loc_structure,
         h_key_structure,
         h_cat_structure
  from   fa_system_controls;

  select fcr.last_update_login
  into   h_login_id
  from fnd_concurrent_requests fcr
  where fcr.request_id = h_request_id;

  h_mesg_name := 'FA_DEPRN_SQL_DCUR';

  open c_main;
  loop

    h_mesg_name := 'FA_DEPRN_SQL_FCUR';

    fetch c_main into c_mainrec;

    if (c_main%NOTFOUND) then exit;  end if;

        h_mesg_name := 'FA_RX_CONCAT_SEGS';
        h_flex_error := 'LOC#';
        h_ccid_error := c_mainrec.location_id;

        fa_rx_shared_pkg.concat_location (
           struct_id => h_loc_structure,
           ccid => c_mainrec.location_id,
           concat_string => h_concat_loc,
           segarray => h_loc_segs);

        h_flex_error := 'CAT#';
        h_ccid_error := c_mainrec.asset_category_id;

        fa_rx_shared_pkg.concat_category (
        struct_id => h_cat_structure,
        ccid => c_mainrec.asset_category_id,
        concat_string => h_concat_cat,
        segarray => h_cat_segs);

    if (c_mainrec.asset_key_ccid is not null) then

        h_flex_error := 'KEY#';
        h_ccid_error := c_mainrec.asset_key_ccid;

        fa_rx_shared_pkg.concat_asset_key (
        struct_id => h_key_structure,
        ccid => c_mainrec.asset_key_ccid,
        concat_string => h_concat_key,
        segarray => h_key_segs);

    end if;

        h_mesg_name := 'FA_SHARED_INSERT_FAILED';

        insert into fa_invmiss_rep_itf  (
        request_id,
        location,
        category,
        asset_key,
        inventory_name,
        asset_number,
        description,
        units_assigned,
        serial_number,
        tag_number,
        manufacturer_name,
        model_number,
        created_by, creation_date, last_updated_by, last_update_date,
        last_update_login)
        values (
        h_request_id,
        h_concat_loc,
        h_concat_cat,
        h_concat_key,
        c_mainrec.inventory_name,
        c_mainrec.asset_number,
        c_mainrec.description,
        c_mainrec.units_assigned,
        c_mainrec.serial_number,
        c_mainrec.tag_number,
        c_mainrec.manufacturer_name,
        c_mainrec.model_number,
        user_id, sysdate, user_id , sysdate, h_login_id);

  end loop;

  h_mesg_name := 'FA_DEPRN_SQL_CCUR';

  close c_main;

exception when others then
  if SQLCODE <> 0 then
    fa_Rx_conc_mesg_pkg.log(SQLERRM);
  end if;
  fnd_message.set_name('OFA',h_mesg_name);
  if h_mesg_name = 'FA_SHARED_INSERT_FAIL' then
        fnd_message.set_token('TABLE','FA_INVMISS_REP_ITF',FALSE);
  end if;
  if h_mesg_name = 'FA_RX_CONCAT_SEGS' then
        fnd_message.set_token('CCID',to_char(h_ccid_error),FALSE);
        fnd_message.set_token('FLEX_CODE',h_flex_error,FALSE);
  end if;

  h_mesg_str := fnd_message.get;
  fa_rx_conc_mesg_pkg.log(h_mesg_str);
  retcode := 2;

end miss_asset;


  procedure comparison (
        inventory_name  in      varchar2,
        location        in      varchar2,
        category        in      varchar2,
        request_id      in      number,
        user_id         in      number,
        retcode  out nocopy number,
        errbuf   out nocopy varchar2) is

  h_login_id            number;
  h_asset_number        varchar2(25);
  h_description         varchar2(80);

  h_concat_key                varchar2(500);
  h_key_segs                  fa_rx_shared_pkg.Seg_Array;
  h_key_structure             number;
  h_key_ccid                    number;

  h_cat_structure             number;
  h_concat_cat                varchar2(500);
  h_cat_segs                  fa_rx_shared_pkg.Seg_Array;
  h_cat_ccid                    number;

  h_concat_loc          varchar2(500);
  h_loc_segs            fa_rx_shared_pkg.Seg_Array;
  h_loc_structure       number;
  h_loc_ccid            number;

  h_inventory_name      varchar2(80);
  h_request_id          number;
  h_segment_num         number;

  h_mesg_name           varchar2(50);
  h_mesg_str            varchar2(2000);
  h_flex_error          varchar2(5);
  h_ccid_error          number;
  h_value_error         varchar2(240);
  h_param_error         varchar2(240);

  cursor c_compare is
  select inv.inventory_name, inv.asset_number, inv.asset_key_ccid,
        inv.tag_number, inv.description, inv.model_number, inv.serial_number,
        inv.manufacturer_name, inv.asset_category_id, inv.units,
        inv.location_id, lu1.meaning status,
        lu2.meaning unit_reconcile_mth_mean,
        lu3.meaning loc_reconcile_mth_mean
  from fa_inv_interface inv, fa_lookups lu1, fa_lookups lu2, fa_lookups lu3
  where nvl(inv.inventory_name,'X') = nvl(h_inventory_name,
                                nvl(inv.inventory_name,'X'))
  and nvl(inv.asset_category_id,-9999) = nvl(h_cat_ccid,
                                nvl(inv.asset_category_id,-9999))
  and nvl(inv.location_id,-9999) = nvl(h_loc_ccid,
                                nvl(inv.location_id,-9999))
  and inv.status = lu1.lookup_code(+)
  and lu1.lookup_type(+) = 'INVENTORY STATUS'
  and inv.unit_reconcile_mth = lu2.lookup_code(+)
  and lu2.lookup_type(+) like 'INVENTORY UNIT METHOD%'
  and inv.loc_reconcile_mth = lu3.lookup_code(+)
  and lu3.lookup_type(+) like 'INVENTORY LOCATION METHOD%'
  -- Bug# 7377673
  and nvl(nvl(inv.asset_number, inv.tag_number), inv.serial_number) in
                           (select nvl(nvl(inv1.asset_number, inv1.tag_number), inv1.serial_number)
  -- End Bug# 7377673
                             from   fa_inv_interface inv1,
                                    fa_additions_b ad,
                                    fa_books bks,
                                    fa_book_controls_sec bc
                            -- Bug# 7377673
                            where (   (inv1.asset_number = ad.asset_number)
                                   or (    inv1.asset_number is null
                                       and inv1.tag_number   = ad.tag_number)
                                   or (    inv1.asset_number is null
                                       and inv1.tag_number   is null
                                       and inv1.serial_number = ad.serial_number)
                                   )
                            -- End Bug# 7377673
                            and    ad.asset_id = bks.asset_id
                            and    bks.transaction_header_id_out is null
                            and    bks.book_type_code = bc.book_type_code
                            union
                            -- Bug# 7377673
                            select nvl(nvl(inv2.asset_number, inv2.tag_number), inv2.serial_number)
                            -- End Bug# 7377673
                            from   fa_inv_interface inv2
                            where not exists
                                           (select 'x'
                                            from  fa_additions_b ad
                                            -- Bug# 7377673
                                            where (   ad.asset_number  = inv2.asset_number
                                                   or ad.tag_number    = inv2.tag_number
                                                   or ad.serial_number = inv2.serial_number)
                                            -- End Bug# 7377673
                                            )); --Bug#3503643

  c_comparerec  c_compare%rowtype;
begin

  h_loc_ccid := null;
  h_cat_ccid := null;
  h_inventory_name := inventory_name;
  h_request_id := request_id;
  h_concat_cat := category;
  h_concat_loc := location;

  h_mesg_name := 'FA_FE_LOOKUP_IN_SYSTEM_CTLS';

  select location_flex_structure,
         asset_key_flex_structure,
         category_flex_structure
  into   h_loc_structure,
         h_key_structure,
         h_cat_structure
  from   fa_system_controls;

  select fcr.last_update_login
  into   h_login_id
  from fnd_concurrent_requests fcr
  where fcr.request_id = h_request_id;


/* Commenting out validation for cathory and location.
   When submitted from SRS location and category already have
   location_ccid and category_ccid

  h_mesg_name := 'FA_WHATIF_PARAM_ERROR';

  if category is not null then
    h_value_error := category;
    h_param_error := 'CATEGORY';
    if fnd_flex_keyval.validate_segs (
        operation => 'CHECK_COMBINATION',
        appl_short_name => 'OFA',
        key_flex_code => 'CAT#',
        structure_number => h_cat_structure,
        concat_segments => category,
        values_or_ids  => 'V',
        validation_date  =>SYSDATE,
        displayable  => 'ALL',
        data_set => NULL,
        vrule => NULL,
        where_clause => NULL,
        get_columns => NULL,
        allow_nulls => FALSE,
        allow_orphans => FALSE,
        resp_appl_id => NULL,
        resp_id => NULL,
        user_id => NULL) = FALSE then

        fnd_message.set_name('OFA','FA_WHATIF_NO_CAT');
        fnd_message.set_token('CAT',category,FALSE);
        h_mesg_str := fnd_message.get;
        fa_rx_conc_mesg_pkg.log(h_mesg_str);

        retcode := 2;
        return;
    end if;
    h_cat_ccid := fnd_flex_keyval.combination_id;
  end if;

  if location is not null then
    h_value_error := location;
    h_param_error := 'LOCATION';

    if fnd_flex_keyval.validate_segs (
        operation => 'CHECK_COMBINATION',
        appl_short_name => 'OFA',
        key_flex_code => 'LOC#',
        structure_number => h_loc_structure,
        concat_segments => location,
        values_or_ids  => 'V',
        validation_date  =>SYSDATE,
        displayable  => 'ALL',
        data_set => NULL,
        vrule => NULL,
        where_clause => NULL,
        get_columns => NULL,
        allow_nulls => FALSE,
        allow_orphans => FALSE,
        resp_appl_id => NULL,
        resp_id => NULL,
        user_id => NULL) = FALSE then

        fnd_message.set_name('OFA','FA_PI_NO_LOCATION');
        fnd_message.set_token('LOC',location,FALSE);
        h_mesg_str := fnd_message.get;
        fa_rx_conc_mesg_pkg.log(h_mesg_str);

        retcode := 2;
        return;
    end if;
    h_loc_ccid := fnd_flex_keyval.combination_id;
  end if;
*/

  h_cat_ccid := to_number(category);
  h_loc_ccid := to_number(location);

  h_mesg_name := 'FA_DEPRN_SQL_DCUR';

  open c_compare;
  loop

    h_mesg_name := 'FA_DEPRN_SQL_FCUR';

    fetch c_compare into c_comparerec;

    if (c_compare%NOTFOUND) then exit;  end if;

    h_mesg_name := 'FA_RX_CONCAT_SEGS';
    if (c_comparerec.asset_category_id is not null
        and category is null) then

        h_flex_error := 'CAT#';
        h_ccid_error := c_comparerec.asset_category_id;

        fa_rx_shared_pkg.concat_category (
        struct_id => h_cat_structure,
        ccid => c_comparerec.asset_category_id,
        concat_string => h_concat_cat,
        segarray => h_cat_segs);

    elsif (category is not null ) then    -- fix bug 3252216.

        fa_rx_shared_pkg.concat_category (
        struct_id => h_cat_structure,
        ccid => h_cat_ccid,
        concat_string => h_concat_cat,
        segarray => h_cat_segs);
    else
        h_concat_cat := '';
    end if;

    if (c_comparerec.location_id is not null
        and location is null) then

        h_flex_error := 'LOC#';
        h_ccid_error := c_comparerec.location_id;

        fa_rx_shared_pkg.concat_location (
           struct_id => h_loc_structure,
           ccid => c_comparerec.location_id,
           concat_string => h_concat_loc,
           segarray => h_loc_segs);

    elsif (location is not null) then   -- fix bug 3252216.

        fa_rx_shared_pkg.concat_location (
           struct_id => h_loc_structure,
           ccid => h_loc_ccid,
           concat_string => h_concat_loc,
           segarray => h_loc_segs);

    else
        h_concat_loc := '';
    end if;

    if (c_comparerec.asset_key_ccid is not null) then

        h_flex_error := 'KEY#';
        h_ccid_error := c_comparerec.asset_key_ccid;

        fa_rx_shared_pkg.concat_asset_key (
        struct_id => h_key_structure,
        ccid => c_comparerec.asset_key_ccid,
        concat_string => h_concat_key,
        segarray => h_key_segs);
    else
        h_concat_key := '';
    end if;


    h_mesg_name := 'FA_SHARED_INSERT_FAILED';

    insert into fa_inv_compare_rep_itf (
         REQUEST_ID, INVENTORY_NAME, ASSET_NUMBER, ASSET_KEY, TAG_NUMBER,
         DESCRIPTION, MODEL_NUMBER, SERIAL_NUMBER, MANUFACTURER_NAME,
         ASSET_CATEGORY, UNITS, LOCATION, STATUS, UNIT_RECONCILE_MTH_MEAN,
         LOC_RECONCILE_MTH_MEAN, LAST_UPDATE_DATE, LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN, CREATED_BY, CREATION_DATE ) values (
        h_request_id, c_comparerec.inventory_name,
        c_comparerec.asset_number, h_concat_key, c_comparerec.tag_number,
        c_comparerec.description, c_comparerec.model_number,
        c_comparerec.serial_number, c_comparerec.manufacturer_name,
        h_concat_cat, c_comparerec.units, h_concat_loc, c_comparerec.status,
        c_comparerec.unit_reconcile_mth_mean,
        c_comparerec.loc_reconcile_mth_mean, sysdate, user_id, h_login_id,
        user_id, sysdate);




  end loop;

  h_mesg_name := 'FA_DEPRN_SQL_CCUR';

  close c_compare;

exception when others then
  if SQLCODE <> 0 then
    fa_Rx_conc_mesg_pkg.log(SQLERRM);
  end if;
  fnd_message.set_name('OFA',h_mesg_name);
  if h_mesg_name = 'FA_SHARED_INSERT_FAIL' then
        fnd_message.set_token('TABLE','FA_INV_COMPARE_REP_ITF',FALSE);
  end if;
  if h_mesg_name = 'FA_RX_CONCAT_SEGS' then
        fnd_message.set_token('CCID',to_char(h_ccid_error),FALSE);
        fnd_message.set_token('FLEX_CODE',h_flex_error,FALSE);
  end if;

  h_mesg_str := fnd_message.get;
  fa_rx_conc_mesg_pkg.log(h_mesg_str);
  retcode := 2;


end comparison;

END FARX_INV_MISS_PKG;

/
