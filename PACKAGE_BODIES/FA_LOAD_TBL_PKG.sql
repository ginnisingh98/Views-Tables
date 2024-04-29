--------------------------------------------------------
--  DDL for Package Body FA_LOAD_TBL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_LOAD_TBL_PKG" as
/* $Header: FAXVTBLB.pls 120.5.12010000.2 2009/07/19 14:07:29 glchen ship $ */

/* Procedure  	load_dist_table

       Usage	Called by client to load all distributions in the
		global table dist_line_tbl before calling the API
*/

PROCEDURE load_dist_table
	   (p_row_id            varchar2 default null,
            p_dist_id           number default null,
            p_asset_id          number default null,
            p_units             number,
            p_date_effective    date,
            p_ccid              number,
            p_location_id       number,
            p_th_id_in          number,
            p_assigned_to       number,
            p_trans_units       number,
            p_record_status     varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
IS
BEGIN
      if (g_dist_count=0) then   /* initialize the table */
         dist_table.delete;
      end if;
         g_dist_count := g_dist_count + 1;
	 dist_table(g_dist_count).row_id := p_row_id;
	 dist_table(g_dist_count).dist_id := p_dist_id;
	 dist_table(g_dist_count).asset_id := p_asset_id;
	 dist_table(g_dist_count).units := p_units;
	 dist_table(g_dist_count).ccid := p_ccid;
	 dist_table(g_dist_count).location_id := p_location_id;
	 dist_table(g_dist_count).th_id_in := p_th_id_in;
	 dist_table(g_dist_count).assigned_to := p_assigned_to;
	 dist_table(g_dist_count).trans_units := p_trans_units;
	 dist_table(g_dist_count).record_status := p_record_status;

END load_dist_table;

PROCEDURE load_inv_table (
	     p_rowid				varchar2,
             p_source_line_id                   number default null,
     	     p_asset_id         		number default null,
  	     p_po_vendor_id     		number default null,
    	     p_asset_invoice_id 		number default null,
	     p_fixed_assets_cost 		number,
	     p_po_number			varchar2 default null,
	     p_invoice_number  			varchar2 default null,
    	     p_payables_batch_name 		varchar2 default null,
   	     p_payables_ccid			number default null,
	     p_feeder_system_name 		varchar2 default null,
	     p_create_batch_date		date default null,
  	     p_create_batch_id			number default null,
	     p_invoice_date			date default null,
	     p_payables_cost			number default null,
	     p_post_batch_id			number default null,
	     p_invoice_id			number default null,
        p_invoice_distribution_id number   default null,
        p_invoice_line_number     number   default null,
        p_po_distribution_id      number   default null,
	     p_ap_dist_line_num			number default null,
	     p_payables_units			number default null,
	     p_description			varchar2 default null,
	     p_project_asset_line_id		number default null,
	     p_project_id			number default null,
	     p_task_id				number default null,
             p_material_indicator_flag          varchar2 default null,
	     p_deleted_flag			varchar2,
	     p_inv_transfer_cost		number,
	     p_inv_update_only			varchar2,
	     p_inv_new_cost			number,
             p_depreciate_in_group_flag         varchar2,
	     p_attribute1			varchar2 default null,
	     p_attribute2			varchar2 default null,
	     p_attribute3			varchar2 default null,
	     p_attribute4			varchar2 default null,
	     p_attribute5			varchar2 default null,
	     p_attribute6			varchar2 default null,
	     p_attribute7			varchar2 default null,
	     p_attribute8			varchar2 default null,
	     p_attribute9			varchar2 default null,
	     p_attribute10			varchar2 default null,
	     p_attribute11			varchar2 default null,
	     p_attribute12			varchar2 default null,
	     p_attribute13			varchar2 default null,
	     p_attribute14			varchar2 default null,
	     p_attribute15			varchar2 default null,
	     p_attribute_cat_code 		varchar2 default null, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
IS
BEGIN
  if (g_inv_count=0) then  /* initialize inv_line_tbl  */
	   inv_table.delete;
  end if;
     g_inv_count := g_inv_count + 1;

     inv_table(g_inv_count).rowid := p_rowid;
     inv_table(g_inv_count).source_line_id := p_source_line_id;
     inv_table(g_inv_count).asset_id := p_asset_id;
     inv_table(g_inv_count).po_vendor_id
				:= p_po_vendor_id;
     inv_table(g_inv_count).asset_invoice_id
				:= p_asset_invoice_id;
     inv_table(g_inv_count).fixed_assets_cost
				:= p_fixed_assets_cost;
     inv_table(g_inv_count).po_number
				:=  p_po_number;
     inv_table(g_inv_count).invoice_number
			    := p_invoice_number;
     inv_table(g_inv_count).payables_batch_name
				:= p_payables_batch_name;
     inv_table(g_inv_count).payables_ccid
				:= p_payables_ccid;
     inv_table(g_inv_count).feeder_system_name
				:= p_feeder_system_name;
     inv_table(g_inv_count).create_batch_date
				:= p_create_batch_date;
     inv_table(g_inv_count).create_batch_id
				:= p_create_batch_id;
     inv_table(g_inv_count).invoice_date
				:= p_invoice_date;
     inv_table(g_inv_count).payables_cost
				:= p_payables_cost;
     inv_table(g_inv_count).post_batch_id
				:= p_post_batch_id;
     inv_table(g_inv_count).invoice_id
				:= p_invoice_id;
     inv_table(g_inv_count).invoice_distribution_id
				:= p_invoice_distribution_id;
     inv_table(g_inv_count).invoice_line_number
				:= p_invoice_line_number;
     inv_table(g_inv_count).po_distribution_id
				:= p_po_distribution_id;
     inv_table(g_inv_count).ap_dist_line_num
				:= p_ap_dist_line_num;
     inv_table(g_inv_count).payables_units
				:= p_payables_units;
     inv_table(g_inv_count).description
				:= p_description;
     inv_table(g_inv_count).project_asset_line_id
				:= p_project_asset_line_id;
     inv_table(g_inv_count).project_id
				:= p_project_id;
     inv_table(g_inv_count).task_id
				:= p_task_id;
     inv_table(g_inv_count).material_indicator_flag
                                := p_material_indicator_flag;
     inv_table(g_inv_count).deleted_flag
				:= p_deleted_flag;
     inv_table(g_inv_count).inv_transfer_cost
				:= p_inv_transfer_cost;
     inv_table(g_inv_count).inv_update_only
				:= p_inv_update_only;
     inv_table(g_inv_count).inv_new_cost
				:= p_inv_new_cost;
     inv_table(g_inv_count).depreciate_in_group_flag
                                := p_depreciate_in_group_flag;
     inv_table(g_inv_count).attribute1
				:= p_attribute1;
     inv_table(g_inv_count).attribute2
				:= p_attribute2;
     inv_table(g_inv_count).attribute3
				:= p_attribute3;
     inv_table(g_inv_count).attribute4
				:= p_attribute4;
     inv_table(g_inv_count).attribute5
				:= p_attribute5;
     inv_table(g_inv_count).attribute6
				:= p_attribute6;
     inv_table(g_inv_count).attribute7
				:= p_attribute7;
     inv_table(g_inv_count).attribute8
				:= p_attribute8;
     inv_table(g_inv_count).attribute9
				:= p_attribute9;
     inv_table(g_inv_count).attribute10
				:= p_attribute10;
     inv_table(g_inv_count).attribute11
				:= p_attribute11;
     inv_table(g_inv_count).attribute12
				:= p_attribute12;
     inv_table(g_inv_count).attribute13
				:= p_attribute13;
     inv_table(g_inv_count).attribute14
				:= p_attribute14;
     inv_table(g_inv_count).attribute15
				:= p_attribute15;
     inv_table(g_inv_count).attribute_cat_code
				:= p_attribute_cat_code;
END load_inv_table;


-- function to reset g_dist_count
FUNCTION reset_g_dist_count
RETURN BOOLEAN
IS
BEGIN
	g_dist_count := 0;

        dist_table.delete;

	return (TRUE);

EXCEPTION
    when others then
	fa_srvr_msg.add_message(
		calling_fn => 'FA_LOAD_TBL_PKG.reset_g_dist_count',
                p_log_level_rec => null);
	return(FALSE);
END;


-- procedure to reset g_inv_count
PROCEDURE reset_g_inv_count
IS
BEGIN
	g_inv_count := 0;

        inv_table.delete;
END;


-- Procedure to load default depreciation rules for the specified
-- corporate book and its associated tax books in a specific category
-- into a global table(deprn_table.)  This procedure should be
-- called by a mass reclass program wrapper procedure, before calling
-- the Reclass Public API for each asset.

PROCEDURE Load_Deprn_Rules_Tbl(
        p_corp_book     VARCHAR2,
        p_category_id   NUMBER,
	x_return_status OUT NOCOPY BOOLEAN
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)       IS
        CURSOR BOOK_CR IS
            SELECT bc.book_type_code
            FROM fa_category_books cb, fa_book_controls bc
            WHERE p_corp_book =
                        decode(bc.book_class, 'CORPORATE', bc.book_type_code,
                               'TAX', bc.distribution_source_book, '')
	    AND bc.book_type_code = cb.book_type_code
	    AND cb.category_id = p_category_id
            AND nvl(bc.date_ineffective, sysdate + 1) > sysdate;
        h_book          VARCHAR2(30);
        deprn_rules     asset_deprn_info;
	CURSOR DEFAULT_RULES IS
            SELECT      h_book, cbd.start_dpis, cbd.end_dpis,
			cbd.prorate_convention_code, cbd.deprn_method,
                        cbd.life_in_months,cbd.basic_rate,cbd.adjusted_rate,
                        cbd.production_capacity, cbd.unit_of_measure,
                        cbd.bonus_rule, NULL, cbd.ceiling_name,
                        cbd.depreciate_flag, cbd.allowed_deprn_limit,
                        cbd.special_deprn_limit_amount,cbd.percent_salvage_value
            FROM        FA_CATEGORY_BOOK_DEFAULTS cbd
            WHERE       cbd.book_type_code = h_book
            AND         cbd.category_id = p_category_id;

BEGIN
    -- For each book, select default depreciation rules from
    -- FA_CATEGORY_BOOK_DEFAULTS table and fill the global table(deprn_table.)

    OPEN BOOK_CR;

    LOOP
        FETCH BOOK_CR INTO h_book;
        EXIT WHEN BOOK_CR%NOTFOUND;

        -- select default depreciation rules.
        OPEN DEFAULT_RULES;
	LOOP
            FETCH DEFAULT_RULES INTO deprn_rules;
	    EXIT WHEN DEFAULT_RULES%NOTFOUND;

	    -- load the table.
	    if (g_deprn_count = 0) then  /* initialize the table. */
	        deprn_table.delete;
	    end if;
	    g_deprn_count := g_deprn_count + 1;
	    deprn_table(g_deprn_count) := deprn_rules;

	END LOOP;
        CLOSE DEFAULT_RULES;

    END LOOP;

    CLOSE BOOK_CR;

    x_return_status := TRUE;

EXCEPTION
    WHEN OTHERS THEN
        FA_SRVR_MSG.ADD_SQL_ERROR (
              CALLING_FN => 'FA_LOAD_TBL_PKG.Load_Deprn_Rules_Tbl',  p_log_level_rec => p_log_level_rec);
	x_return_status := FALSE;
END Load_Deprn_Rules_Tbl;


-- Procedure that fetches a record of new depreciation rules for the
-- given book.  x_found indicates whether the record was found or not.

PROCEDURE Get_Deprn_Rules(
        p_book_type_code        VARCHAR2,
	p_date_placed_in_service DATE,
        x_deprn_rules_rec       OUT NOCOPY asset_deprn_info,
	x_found		 OUT NOCOPY BOOLEAN
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) 	IS
	found	BOOLEAN := FALSE;
BEGIN
    FOR i IN deprn_table.FIRST .. deprn_table.LAST LOOP
	if deprn_table.exists(i) then
	    if (deprn_table(i).book_type_code = p_book_type_code and
		p_date_placed_in_service between deprn_table(i).start_dpis
		and nvl(deprn_table(i).end_dpis,
			to_date('31-12-4712', 'DD-MM-YYYY'))) then
	        x_deprn_rules_rec := deprn_table(i);
	        found := TRUE;
	        exit;  -- exit the loop when found.
	    end if;
 	end if;
    END LOOP;

    x_found := found;

EXCEPTION
    WHEN OTHERS THEN
	FA_SRVR_MSG.Add_SQL_Error(
		CALLING_FN => 'FA_LOAD_TBL_PKG.Get_Deprn_Rules',  p_log_level_rec => p_log_level_rec);
	x_found := FALSE;
END Get_Deprn_Rules;

-- Procedure to find the index position of a specific depreciation
-- rules record in the table, deprn_table, based on the book and
-- date placed in service, which uniquely identifies one record in the table.
--  If the record is not found, NULL is returned.

PROCEDURE Find_Position_Deprn_Rules(
        p_book_type_code         VARCHAR2,
        p_date_placed_in_service DATE,
        x_pos                    OUT NOCOPY NUMBER
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
BEGIN
    x_pos := NULL;
    FOR i IN deprn_table.FIRST .. deprn_table.LAST LOOP
        IF deprn_table.exists(i) THEN
            IF (deprn_table(i).book_type_code = p_book_type_code AND
                p_date_placed_in_service between deprn_table(i).start_dpis
                and nvl(deprn_table(i).end_dpis,
                        to_date('31-12-4712', 'DD-MM-YYYY'))) THEN
                x_pos := i;
                exit;  -- exit the loop when found.
            END IF;
        END IF;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
	x_pos := NULL;
	FA_SRVR_MSG.Add_SQL_Error(
                CALLING_FN => 'FA_LOAD_TBL_PKG.Find_Position_Deprn_Rules',  p_log_level_rec => p_log_level_rec);
	raise;
END Find_Position_Deprn_Rules;


END FA_LOAD_TBL_PKG;

/
