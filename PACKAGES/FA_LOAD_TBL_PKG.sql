--------------------------------------------------------
--  DDL for Package FA_LOAD_TBL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_LOAD_TBL_PKG" AUTHID CURRENT_USER as
/* $Header: FAXVTBLS.pls 120.4.12010000.2 2009/07/19 14:07:56 glchen ship $ */

-- GLOBAL VARIABLES

-- dist_line_rec  : Record to store one distribution

TYPE  dist_line_rec IS RECORD
( 	row_id		VARCHAR2(18),
	dist_id		NUMBER(15),
  	asset_id	NUMBER(15) DEFAULT NULL,
	units		NUMBER,		-- units assigned
	date_effective	DATE,
	ccid		NUMBER(15),
	location_id	NUMBER(15),
	th_id_in	NUMBER(15),
	assigned_to	NUMBER(15),
	trans_units	NUMBER,
	-- record_status = 'UPDATE', 'INSERT' or 'DELETE'.  Informs what
	-- SQL transaction has to be performed on this distribution line
	-- (non-database field, added for Transfer transaction.)
	record_status	VARCHAR2(6)
);

-- dist_line_tbl  : A global table to store distribution lines

TYPE dist_line_tbl IS TABLE OF dist_line_rec
 INDEX BY BINARY_INTEGER;

dist_table		dist_line_tbl;
-- Global variable holding the number of dist lines count
g_dist_count		NUMBER	:= 0;

/* removing this, since PL/SQL still does not allow table of nested
   records.
TYPE inv_descflex_rec is RECORD (
			attribute1	varchar2(150),
			attribute2	varchar2(150),
			attribute3	varchar2(150),
			attribute4	varchar2(150),
			attribute5	varchar2(150),
			attribute6	varchar2(150),
			attribute7	varchar2(150),
			attribute8	varchar2(150),
			attribute9	varchar2(150),
			attribute10	varchar2(150),
			attribute11	varchar2(150),
			attribute12	varchar2(150),
			attribute13	varchar2(150),
			attribute14	varchar2(150),
			attribute15	varchar2(150),
			attribute_cat_code varchar2(30));
*/

TYPE inv_line_rec is RECORD (
			rowid		 varchar2(18),
                        source_line_id   number default null,
			asset_id         number default null,
			po_vendor_id     number default null,
			asset_invoice_id number default null,
			fixed_assets_cost number,
			po_number	varchar2(20) default null,
			invoice_number  varchar2(50) default null,
			payables_batch_name varchar2(50) default null,
			payables_ccid	number,
			feeder_system_name	varchar2(40),
			create_batch_date	date,
			create_batch_id		number,
			invoice_date		date,
			payables_cost		number,
			post_batch_id		number,
			invoice_id		number,
         invoice_distribution_id number,
         invoice_line_number     number,
         po_distribution_id      number,
			ap_dist_line_num	number,
			payables_units		number,
			description		varchar2(80),
			project_asset_line_id	number,
			project_id		number,
			task_id			number,
                        material_indicator_flag varchar2(1),
			deleted_flag		varchar2(3),
			inv_transfer_cost	number,
			inv_update_only		varchar2(4),
			inv_new_cost		number,
                        depreciate_in_group_flag varchar2(1),
			attribute1	varchar2(150),
			attribute2	varchar2(150),
			attribute3	varchar2(150),
			attribute4	varchar2(150),
			attribute5	varchar2(150),
			attribute6	varchar2(150),
			attribute7	varchar2(150),
			attribute8	varchar2(150),
			attribute9	varchar2(150),
			attribute10	varchar2(150),
			attribute11	varchar2(150),
			attribute12	varchar2(150),
			attribute13	varchar2(150),
			attribute14	varchar2(150),
			attribute15	varchar2(150),
			attribute_cat_code varchar2(30));

TYPE inv_line_tbl is TABLE of inv_line_rec
     INDEX BY BINARY_INTEGER;

inv_table		inv_line_tbl;
-- Global variable holding the number of invoice lines count
g_inv_count		NUMBER	:= 0;

TYPE asset_deprn_info is RECORD (
			book_type_code		varchar2(15) default null, -- for reclass
			-- start and end dpis in category books form.
			-- start_dpis and/or end_dpis can also be used to store
			-- the asset's date placed in service at user's choice.
			start_dpis		date default null, -- for reclass
		        end_dpis		date default null, -- for reclass
		        prorate_conv_code       varchar2(10),
	                deprn_method	        varchar2(12),
	                life_in_months          number,
			basic_rate		number,
			adjusted_rate		number,
			production_capacity     number,
			unit_of_measure		varchar2(25),
		        bonus_rule		varchar2(30),
		        itc_amount		number,
			ceiling_name		varchar2(30),
			depreciate_flag		varchar2(3),
			allow_deprn_limit	number,
			deprn_limit_amount	number,
			percent_salvage_value   number);

-- table of asset depreciation rules for each book -- this table is
-- needed for mass reclass(preview report and program) to avoid
-- redundant select statements for new depreciation rules.  It will
-- store default depreciation rules for the corporate book and its
-- corresponding tax books in a specific category.

TYPE asset_deprn_info_tbl is TABLE of asset_deprn_info
        INDEX BY BINARY_INTEGER;

deprn_table     asset_deprn_info_tbl;
g_deprn_count   NUMBER := 0;

TYPE asset_descflex_rec is RECORD (
			attribute1		varchar2(150),
			attribute2		varchar2(150),
			attribute3		varchar2(150),
			attribute4		varchar2(150),
			attribute5		varchar2(150),
			attribute6		varchar2(150),
			attribute7		varchar2(150),
			attribute8		varchar2(150),
			attribute9		varchar2(150),
			attribute10		varchar2(150),
			attribute11		varchar2(150),
			attribute12		varchar2(150),
			attribute13		varchar2(150),
			attribute14		varchar2(150),
			attribute15		varchar2(150),
			attribute16		varchar2(150),
			attribute17		varchar2(150),
			attribute18		varchar2(150),
			attribute19		varchar2(150),
			attribute20		varchar2(150),
			attribute21		varchar2(150),
			attribute22		varchar2(150),
			attribute23		varchar2(150),
			attribute24		varchar2(150),
			attribute25		varchar2(150),
			attribute26		varchar2(150),
			attribute27		varchar2(150),
			attribute28		varchar2(150),
			attribute29		varchar2(150),
			attribute30		varchar2(150),
			attribute_cat_code	varchar2(210));

TYPE asset_globaldesc_rec is RECORD (
			attribute1		varchar2(150),
			attribute2		varchar2(150),
			attribute3		varchar2(150),
			attribute4		varchar2(150),
			attribute5		varchar2(150),
			attribute6		varchar2(150),
			attribute7		varchar2(150),
			attribute8		varchar2(150),
			attribute9		varchar2(150),
			attribute10		varchar2(150),
			attribute11		varchar2(150),
			attribute12		varchar2(150),
			attribute13		varchar2(150),
			attribute14		varchar2(150),
			attribute15		varchar2(150),
			attribute16		varchar2(150),
			attribute17		varchar2(150),
			attribute18		varchar2(150),
			attribute19		varchar2(150),
			attribute20		varchar2(150),
			attribute21		varchar2(150),
			attribute22		varchar2(150),
			attribute23		varchar2(150),
			attribute24		varchar2(150),
			attribute25		varchar2(150),
			attribute26		varchar2(150),
			attribute27		varchar2(150),
			attribute28		varchar2(150),
			attribute29		varchar2(150),
			attribute30		varchar2(150),
			global_attribute_cat	varchar2(210));

--
-- Procedure  	load_dist_table
--
--       Usage	Called by client to load all distributions in the
--		global table dist_line_tbl before calling the API
--
--

PROCEDURE load_dist_table
	   (p_row_id		varchar2 default null,
	    p_dist_id		number default null,
	    p_asset_id		number default null,
	    p_units		number,
	    p_date_effective	date,
	    p_ccid		number,
	    p_location_id 	number,
	    p_th_id_in		number,
	    p_assigned_to 	number,
	    p_trans_units	number,
	    p_record_status	varchar2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);


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
        p_invoice_distribution_id number default null,
        p_invoice_line_number     number default null,
        p_po_distribution_id      number default null,
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
	     p_attribute_cat_code 		varchar2 default null, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

-- procedure to reset global variable g_dist_count
FUNCTION     reset_g_dist_count RETURN BOOLEAN;

-- procedure to reset global variable g_inv_count
PROCEDURE    reset_g_inv_count;


-- Procedure to load default depreciation rules for the specified
-- corporate book and its associated tax books in a specific category
-- into a global table(deprn_table.)  This procedure should be
-- called by a mass reclass program wrapper procedure, before calling
-- the Reclass Public API for each asset.

PROCEDURE Load_Deprn_Rules_Tbl(
        p_corp_book             VARCHAR2,
        p_category_id           NUMBER,
	x_return_status	 OUT NOCOPY BOOLEAN, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

-- Procedure that fetches a record of new depreciation rules for the
-- given book and date placed in service.  x_found indicates whether the record was
-- found or not.

PROCEDURE Get_Deprn_Rules(
        p_book_type_code        VARCHAR2,
	p_date_placed_in_service DATE,
        x_deprn_rules_rec       OUT NOCOPY asset_deprn_info,
	x_found		 OUT NOCOPY BOOLEAN, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

-- Procedure to find the index position of a specific depreciation
-- rules record in the table, deprn_table, based on the book and
-- date placed in service, which uniquely identifies one record in the table.
-- If the record is not found, NULL is returned.

PROCEDURE Find_Position_Deprn_Rules(
        p_book_type_code         VARCHAR2,
        p_date_placed_in_service DATE,
        x_pos                    OUT NOCOPY NUMBER
        , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);


END FA_LOAD_TBL_PKG;

/
