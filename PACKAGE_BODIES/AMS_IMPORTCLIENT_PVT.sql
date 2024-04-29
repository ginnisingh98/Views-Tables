--------------------------------------------------------
--  DDL for Package Body AMS_IMPORTCLIENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IMPORTCLIENT_PVT" AS
/* $Header: amsvmicb.pls 115.47 2004/03/17 18:53:46 huili ship $ */
--------------------------------------------------------------------------------
--
-- NAME
--    AMS_ImportClient_PVT
--
-- HISTORY
-- 12-Apr-2001    huili           Created
-- 13-May-2001    huili           Added the "Insert_Lead_Data" module
-- 04-June-2001   huili           Added writing to log file
-- 16-June-2001   huili           Added checking the "DEDUPE_FLAG" of the
--                                "ams_imp_list_headers_all" table in the
--                                "Insert_List_Data" procedure
-- 18-June-2001   huili           Added Updating status_id in the
--                                "ams_imp_list_headers_all" table
-- 18-June-2001   huili           Took out the checking for "p_row_count"
--                                in both lead import and list import
--                                stored procedure.
-- 23-July-2001   huili           Changed the "SOURCE_SYSTEM" to "NEW".
-- 01-Oct-2001   huili            Changed the alter sequence statement to
--                                use a loop to pick up sequences.
-- 19-Oct-2001   huili            Added code to handle more that 40 columns.
-- 19-Oct-2001   huili            Replace single quote with two single quotes in constructing
--                                the dynamic insertion command.
-- 24-JAN-2002   huili            Comment out the "SOURCE_SYSTEM" default data for lead import.
-- 01-MAR-2002   huili            Remove populating error for trancated columns.
-- 07-MAR-2002   huili            Remove the update for number of rows for both list
--                                and lead import.
-- 07-MAR-2002   huili            Always insert one row into the "AMS_LIST_IMPORT_ERRORS" table
--                                for all kinds of errors in the "as_import_interface".
-- 10-April-2002 huili            Added one more column "marketing_score" to the "c_lead_recs"
--                                cursor.
-- 26-April-2002 huili            Change all tables to varchar2(2000) table for bug #2345334.
-- 26-April-2002 huili            Remove the "batch_id" checking for the cursor c_lead_error_txt.
-- 30-April-2002 huili				 Parse the cursor once to improve efficiency.
-- 17-May-2002   huili				 Add trim to the "Load_Lead_Data_To_Interface" stored procedure.
-- 08-July-2002  huili				 Populate "batch_id" into the source line table.
------------------------------------------------------------------------------

--
-- Global variables and constants.
G_PKG_NAME        CONSTANT VARCHAR2(30) := 'AMS_IMPORTCLIENT_PVT'; -- Name of the current package.
G_DEBUG_FLAG      CONSTANT VARCHAR2(1)  := 'N';
G_COL_NUM         CONSTANT NUMBER := 40;
G_ARC_IMPORT_HEADER  CONSTANT VARCHAR2(30) := 'IMPH';
G_ROW_PARSE_NO_ERROR CONSTANT NUMBER := 0;
G_ROW_PARSE_TOO_LARGE CONSTANT NUMBER := 1;

G_ROW_PARSE_TOO_LARGE_MSG CONSTANT VARCHAR2(2000) := 'This field is too large!';
G_ROW_PARSE_OTHER_MSG CONSTANT VARCHAR2(2000) := 'Other error';

AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Append_More_Data (
  p_str_col_names                IN      char_data_set_type_w,
  p_str_data                     IN      char_data_set_type_w,
  p_num_col_names                IN      char_data_set_type_w,
  p_num_data                     IN      num_data_set_type_w,
  p_col_clause                   IN OUT NOCOPY  VARCHAR2,
  p_val_clause                   IN OUT NOCOPY  VARCHAR2
);

PROCEDURE Insert_Data (

  p_api_version                 IN    NUMBER,
  p_init_msg_list               IN    VARCHAR2 := FND_API.G_TRUE,
  p_commit                      IN    VARCHAR2 := FND_API.G_FALSE,

  p_table_name                  IN    VARCHAR2,
  p_prim_key_name               IN    VARCHAR2,
  p_seq_name                    IN    VARCHAR2,

  p_str_col_names               IN    char_data_set_type_w,
  p_num_col_names               IN    char_data_set_type_w,
  p_str_data                    IN    char_data_set_type_w,
  p_num_data                    IN    num_data_set_type_w,
  p_obj_version_num             IN    NUMBER := NULL,  -- if NULL, do not insert this column
  p_last_update_date_flag       IN    VARCHAR2 := FND_API.G_TRUE,-- need this column?
  p_last_update_by_flag         IN    VARCHAR2 := FND_API.G_TRUE,-- need this column?
  p_creation_date_flag          IN    VARCHAR2 := FND_API.G_TRUE,-- need this column?
  p_created_by_flag             IN    VARCHAR2 := FND_API.G_TRUE,-- need this column?
  p_ls_update_log_flag          IN    VARCHAR2 := FND_API.G_TRUE,-- need this column?

  p_col_names                   IN    char_data_set_type_w,
  p_data                        IN    char_data_set_type_w,
  p_error_rows                  IN    num_data_set_type_w,
  p_row_count                   IN    NUMBER,

  x_return_status               OUT NOCOPY   VARCHAR2,
  x_msg_count                   OUT NOCOPY   NUMBER,
  x_msg_data                    OUT NOCOPY   VARCHAR2
);

PROCEDURE Create_List_import_Error (
   p_api_version                IN 	NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_TRUE,
   p_commit                     IN  VARCHAR2 := FND_API.G_TRUE,
   p_list_imp_error_rec         IN  AMS_LIST_IMPORT_ERRORS%ROWTYPE,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_imp_err_id                 OUT NOCOPY NUMBER
);
--- End forward modules

-- Start of comments
-- API Name       Mark_Insert_Lead_Errors
-- Type           Private
-- Pre-reqs       None.
-- Function       Mark lead errors to the "ams_imp_source_lines"
--                table and insert error records into the
--                "ams_list_import_errors" table.
-- Parameters
--    IN
--                p_import_list_header_id  NUMBER               Required
--    OUT         x_return_status          VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
--
--
--
--
PROCEDURE Mark_Insert_Lead_Errors (
	p_import_list_header_id       IN    NUMBER,
	x_return_status               OUT NOCOPY   VARCHAR2
)
IS
	L_API_NAME							CONSTANT VARCHAR2(30) := 'Mark_Insert_Lead_Errors';
	L_FULL_NAME							CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;
	L_MAX_ERROR_TXT_LENGTH        CONSTANT NUMBER := 250;

	CURSOR c_batch_id (p_import_list_header_id NUMBER) IS
	SELECT batch_id
	FROM ams_imp_list_headers_all
	WHERE import_list_header_id = p_import_list_header_id;

	CURSOR c_import_interface_data (p_batch_id NUMBER) IS
	SELECT imp_list_header_number, import_interface_id,
			 DECODE (load_status,
						'SUCCESS', 'SUCCESS',
						'DUPLICATE', 'DUPLICATE',
						'ERROR') load_status
	FROM as_import_interface
	WHERE batch_id = p_batch_id
	AND load_status IN ('ERROR', 'SUCCESS', 'T-ERROR', 'UNEXP_ERROR', 'DUPLICATE');

	CURSOR c_lead_error_txt (p_batch_id NUMBER, p_imp_interface_id NUMBER) IS
	SELECT SUBSTR (error_text, 0, L_MAX_ERROR_TXT_LENGTH) error_text
	FROM as_lead_import_errors
	WHERE -- batch_id = p_batch_id AND
	     import_interface_id = p_imp_interface_id
	ORDER BY LEAD_IMPORT_ERROR_ID DESC;

	l_lead_error_rec c_lead_error_txt%ROWTYPE;
	l_batch_id NUMBER;
	l_list_imp_error_rec ams_list_import_errors%ROWTYPE;
	l_imp_err_id NUMBER;
	l_error_msg VARCHAR2(2000);

BEGIN
	--
	-- Initialize API return status to success.
	--
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF p_import_list_header_id IS NULL THEN
		l_error_msg := 'Expected error in ' || L_FULL_NAME
											|| ' list import header is null';
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	OPEN c_batch_id (p_import_list_header_id);
	FETCH c_batch_id INTO l_batch_id;

	IF c_batch_id%FOUND THEN
		FOR import_interface_data_rec IN c_import_interface_data (l_batch_id)
		LOOP
			BEGIN
				UPDATE ams_imp_source_lines
				SET load_status = import_interface_data_rec.load_status
				WHERE import_source_line_id = import_interface_data_rec.imp_list_header_number;

				--need to insert one row to the error table
				IF import_interface_data_rec.load_status <> 'SUCCESS' THEN
					OPEN c_lead_error_txt (l_batch_id,
						import_interface_data_rec.import_interface_id);
					FETCH c_lead_error_txt INTO l_lead_error_rec;

					IF c_lead_error_txt%FOUND THEN
						l_list_imp_error_rec.col1 := l_lead_error_rec.error_text;
					ELSE
					    IF import_interface_data_rec.load_status = 'ERROR' then
						l_list_imp_error_rec.col1 := 'Unexpected error reported from lead import.';
					    End IF;
					    IF import_interface_data_rec.load_status = 'DUPLICATE' then
						l_list_imp_error_rec.col1 := 'This is a duplicate lead.';
					    End IF;
					END IF;
					CLOSE c_lead_error_txt;
					l_list_imp_error_rec.import_list_header_id := p_import_list_header_id;
					l_list_imp_error_rec.import_source_line_id
						:= import_interface_data_rec.imp_list_header_number;
					l_list_imp_error_rec.import_type := 'LEAD';

					l_list_imp_error_rec.error_type := 'E';
					l_list_imp_error_rec.batch_id := l_batch_id;

					Create_List_import_Error (
						p_api_version => 1.0,
						x_return_status => x_return_status,
						p_list_imp_error_rec => l_list_imp_error_rec,
						x_imp_err_id => l_imp_err_id);
					IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
						l_error_msg := 'Expected error in ' || L_FULL_NAME
											|| ' can not create error record';
											RAISE FND_API.G_EXC_ERROR;
					END IF;

				END IF;

				EXCEPTION
					WHEN FND_API.G_EXC_ERROR THEN
						IF c_import_interface_data%ISOPEN THEN
							CLOSE c_import_interface_data;
						END IF;
						IF c_batch_id%ISOPEN THEN
							CLOSE c_batch_id;
						END IF;
						IF c_lead_error_txt%ISOPEN THEN
							CLOSE c_lead_error_txt;
						END IF;
						RAISE FND_API.G_EXC_ERROR;
					WHEN OTHERS THEN
						IF c_import_interface_data%ISOPEN THEN
							CLOSE c_import_interface_data;
						END IF;
						IF c_batch_id%ISOPEN THEN
							CLOSE c_batch_id;
						END IF;
						IF c_lead_error_txt%ISOPEN THEN
							CLOSE c_lead_error_txt;
						END IF;
						l_error_msg := 'Expected error in ' || L_FULL_NAME
											|| ' ' || SQLERRM;
						RAISE FND_API.G_EXC_ERROR;
			END;
		END LOOP;
	END IF;
	CLOSE c_batch_id;

	EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
			AMS_Utility_PVT.Create_Log (
				x_return_status   => x_return_status,
				p_arc_log_used_by => G_ARC_IMPORT_HEADER,
				p_log_used_by_id  => p_import_list_header_id,
				p_msg_data        => 'Expected error in ' || L_FULL_NAME,
				p_msg_type        => 'DEBUG'
			);
			x_return_status := FND_API.G_RET_STS_ERROR;
		WHEN OTHERS THEN
			l_error_msg := 'Unexpected error in '
										|| L_FULL_NAME || ': '|| SQLERRM;
			AMS_Utility_PVT.Create_Log (
				x_return_status   => x_return_status,
				p_arc_log_used_by => G_ARC_IMPORT_HEADER,
				p_log_used_by_id  => p_import_list_header_id,
				p_msg_data        => l_error_msg,
				p_msg_type        => 'DEBUG'
			);
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Mark_Insert_Lead_Errors;

-- Start of comments
-- API Name       Load_Lead_Data_To_Interface
-- Type           Private
-- Pre-reqs       None.
-- Function       Transfer data from the "ams_lead_mapping_v" to
--                the "as_import_interface" table.
-- Parameters
--    IN
--                p_import_list_header_id  NUMBER               Required
--    OUT         x_return_status          VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
PROCEDURE Load_Lead_Data_To_Interface (
	p_import_list_header_id       IN    NUMBER,
	x_return_status               OUT NOCOPY   VARCHAR2
)
IS
	L_MAX_ROW_COUNT					CONSTANT NUMBER := 10;

	L_API_NAME							CONSTANT VARCHAR2(30) := 'Load_Lead_Data_To_Interface';
	L_FULL_NAME							CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;
	L_LOAD_TYPE                   VARCHAR2(20) := 'LEAD_LOAD';
	l_current_date                DATE := SYSDATE;
	L_LOAD_DATE							DATE := l_current_date;
	L_LOAD_STATUS                 VARCHAR2(20) := 'NEW';
	L_STATUS_CODE						VARCHAR2(3) := 'NEW';

	l_user_id                     NUMBER := FND_GLOBAL.User_ID;
	l_login_id                    NUMBER := FND_GLOBAL.Conc_Login_ID;
	l_interface_id                num_data_set_type_w;

	l_import_source_line_id			num_data_set_type_w;
	l_import_list_header_id			num_data_set_type_w;
	l_source_system					varchar2_4000_set_type;
	l_lead_note							varchar2_4000_set_type;
	l_promotion_code					varchar2_4000_set_type;
	l_customer_name					varchar2_4000_set_type;
	l_sic_code							varchar2_4000_set_type;
	l_analysis_fy						varchar2_4000_set_type;
	l_customer_category_code		varchar2_4000_set_type;
	l_fiscal_yearend_month			varchar2_4000_set_type;
	l_num_of_employees				varchar2_4000_set_type;
	l_potential_revenue_curr_fy	varchar2_4000_set_type;
	l_potential_revenue_next_fy	varchar2_4000_set_type;
	l_customer_rank					varchar2_4000_set_type;
	l_tax_reference					varchar2_4000_set_type;
	l_year_established				varchar2_4000_set_type;
	l_addr_do_not_mail_flag			varchar2_4000_set_type;
	l_url									varchar2_4000_set_type;
	l_cont_do_not_mail_flag			varchar2_4000_set_type;
	l_country							varchar2_4000_set_type;
	l_address1							varchar2_4000_set_type;
	l_address2							varchar2_4000_set_type;
	l_address3							varchar2_4000_set_type;
	l_address4							varchar2_4000_set_type;
	l_city								varchar2_4000_set_type;
	l_postal_code						varchar2_4000_set_type;
	l_state								varchar2_4000_set_type;
	l_province							varchar2_4000_set_type;
	l_county								varchar2_4000_set_type;
	l_email_address					varchar2_4000_set_type;
	l_sex_code							varchar2_4000_set_type;
	l_salutation						varchar2_4000_set_type;
	l_last_name							varchar2_4000_set_type;
	l_title								varchar2_4000_set_type;
	l_first_name						varchar2_4000_set_type;
	l_job_title							varchar2_4000_set_type;
	l_phone_number						varchar2_4000_set_type;
	l_phone_status						varchar2_4000_set_type;
	l_phone_type						varchar2_4000_set_type;
	l_area_code							varchar2_4000_set_type;
	l_extension							varchar2_4000_set_type;
	l_middle_initial					varchar2_4000_set_type;
	l_job_title_code					varchar2_4000_set_type;
	l_mail_stop							varchar2_4000_set_type;
	l_fax_number						varchar2_4000_set_type;
	l_fax_area_code					varchar2_4000_set_type;
	l_do_not_email_flag				varchar2_4000_set_type;
	l_do_not_fax_flag					varchar2_4000_set_type;
	l_do_not_phone_flag				varchar2_4000_set_type;
	l_contact_role_code				varchar2_4000_set_type;
	l_channel_code						varchar2_4000_set_type;
	l_budget_amount					varchar2_4000_set_type;
	l_budget_status_code				varchar2_4000_set_type;
	l_currency_code					varchar2_4000_set_type;
	l_decision_timeframe_code		varchar2_4000_set_type;
	l_close_reason						varchar2_4000_set_type;
	l_parent_project					varchar2_4000_set_type;
	l_description						varchar2_4000_set_type;
	l_vehicle_response_code			varchar2_4000_set_type;
	l_interest_type_id_1				varchar2_4000_set_type;
	l_primary_interest_code_id_1	varchar2_4000_set_type;
	l_secondary_interest_code_id_1	varchar2_4000_set_type;
	l_inventory_item_id_1			varchar2_4000_set_type;
	l_organization_id_1				varchar2_4000_set_type;
	l_uom_code_1						varchar2_4000_set_type;
	l_quantity_1						varchar2_4000_set_type;
	l_budget_amount_1					varchar2_4000_set_type;
	l_source_promotion_id_1			varchar2_4000_set_type;
	l_offer_id_1						varchar2_4000_set_type;
	l_interest_type_id_2				varchar2_4000_set_type;
	l_primary_interest_code_id_2	varchar2_4000_set_type;
	l_secondary_interest_code_id_2 varchar2_4000_set_type;
	l_inventory_item_id_2			varchar2_4000_set_type;
	l_organization_id_2				varchar2_4000_set_type;
	l_uom_code_2						varchar2_4000_set_type;
	l_quantity_2						varchar2_4000_set_type;
	l_budget_amount_2					varchar2_4000_set_type;
	l_source_promotion_id_2			varchar2_4000_set_type;
	l_offer_id_2						varchar2_4000_set_type;
	l_interest_type_id_3				varchar2_4000_set_type;
	l_primary_interest_code_id_3	varchar2_4000_set_type;
	l_secondary_interest_code_id_3 varchar2_4000_set_type;
	l_inventory_item_id_3			varchar2_4000_set_type;
	l_organization_id_3				varchar2_4000_set_type;
	l_uom_code_3						varchar2_4000_set_type;
	l_quantity_3						varchar2_4000_set_type;
	l_budget_amount_3					varchar2_4000_set_type;
	l_source_promotion_id_3			varchar2_4000_set_type;
	l_offer_id_3						varchar2_4000_set_type;
	l_interest_type_id_4				varchar2_4000_set_type;
	l_primary_interest_code_id_4	varchar2_4000_set_type;
	l_secondary_interest_code_id_4 varchar2_4000_set_type;
	l_inventory_item_id_4			varchar2_4000_set_type;
	l_organization_id_4				varchar2_4000_set_type;
	l_uom_code_4						varchar2_4000_set_type;
	l_quantity_4						varchar2_4000_set_type;
	l_budget_amount_4					varchar2_4000_set_type;
	l_source_promotion_id_4			varchar2_4000_set_type;
	l_offer_id_4						varchar2_4000_set_type;
	l_interest_type_id_5				varchar2_4000_set_type;
	l_primary_interest_code_id_5	varchar2_4000_set_type;
	l_secondary_interest_code_id_5 varchar2_4000_set_type;
	l_inventory_item_id_5			varchar2_4000_set_type;
	l_organization_id_5				varchar2_4000_set_type;
	l_uom_code_5						varchar2_4000_set_type;
	l_quantity_5						varchar2_4000_set_type;
	l_budget_amount_5					varchar2_4000_set_type;
	l_source_promotion_id_5			varchar2_4000_set_type;
	l_offer_id_5						varchar2_4000_set_type;
	l_orig_system_reference			varchar2_4000_set_type;
	l_orig_system_code				varchar2_4000_set_type;
	l_urgent_flag						varchar2_4000_set_type;
	l_accept_flag						varchar2_4000_set_type;
	l_assign_date						varchar2_4000_set_type;
	l_assign_sales_group_id			varchar2_4000_set_type;
	l_assign_to_person_id			varchar2_4000_set_type;
	l_assign_to_salesforce_id		varchar2_4000_set_type;
	l_auto_assignment_type			varchar2_4000_set_type;
	l_deleted_flag						varchar2_4000_set_type;
	l_import_flag						varchar2_4000_set_type;
	l_keep_flag							varchar2_4000_set_type;
	l_prm_assignment_type			varchar2_4000_set_type;
	l_qualified_flag					varchar2_4000_set_type;
	l_reject_reason_code				varchar2_4000_set_type;
	l_scorecard_id						varchar2_4000_set_type;
	l_primary_contact_flag			varchar2_4000_set_type;
	l_address_effective_date		varchar2_4000_set_type;
	l_address_lines_phonetic		varchar2_4000_set_type;
	l_address_style					varchar2_4000_set_type;
	l_content_source_type			varchar2_4000_set_type;
	l_loc_description					varchar2_4000_set_type;
	l_loc_hierarchy_id				varchar2_4000_set_type;
	l_fa_location_id					varchar2_4000_set_type;
	l_floor								varchar2_4000_set_type;
	l_house_number						varchar2_4000_set_type;
	l_language							varchar2_4000_set_type;
	l_location_directions			varchar2_4000_set_type;
	l_po_box_number					varchar2_4000_set_type;
	l_location_position				varchar2_4000_set_type;
	l_postal_plus4_code				varchar2_4000_set_type;
	l_sales_tax_geocode				varchar2_4000_set_type;
	l_sales_tax_inside_city_limits varchar2_4000_set_type;
	l_short_description				varchar2_4000_set_type;
	l_street								varchar2_4000_set_type;
	l_street_number					varchar2_4000_set_type;
	l_street_suffix					varchar2_4000_set_type;
	l_suite								varchar2_4000_set_type;
	l_time_zone							varchar2_4000_set_type;
	l_loc_validated_flag				varchar2_4000_set_type;
	l_duns_number						varchar2_4000_set_type;
	l_group_type						varchar2_4000_set_type;
	l_gsa_indicator_flag				varchar2_4000_set_type;
	l_hq_branch_ind					varchar2_4000_set_type;
	l_jgzz_fiscal_code				varchar2_4000_set_type;
	l_known_as							varchar2_4000_set_type;
	l_known_as2							varchar2_4000_set_type;
	l_known_as3							varchar2_4000_set_type;
	l_known_as4							varchar2_4000_set_type;
	l_known_as5							varchar2_4000_set_type;
	l_language_name					varchar2_4000_set_type;
	l_last_ordered_date				varchar2_4000_set_type;
	l_mission_statement				varchar2_4000_set_type;
	l_organization_name_phonetic	varchar2_4000_set_type;
	l_party_number						varchar2_4000_set_type;
	l_person_first_name_phonetic	varchar2_4000_set_type;
	l_person_iden_type				varchar2_4000_set_type;
	l_person_identifier				varchar2_4000_set_type;
	l_person_last_name_phonetic	varchar2_4000_set_type;
	l_person_name_suffix				varchar2_4000_set_type;
	l_person_previous_last_name	varchar2_4000_set_type;
	l_party_reference_use_flag		varchar2_4000_set_type;
	l_sic_code_type					varchar2_4000_set_type;
	l_tax_name							varchar2_4000_set_type;
	l_total_num_of_orders			varchar2_4000_set_type;
	l_total_ordered_amount			varchar2_4000_set_type;
	l_parties_validated_flag		varchar2_4000_set_type;
	l_ps_uses_comments				varchar2_4000_set_type;
	l_primary_per_type				varchar2_4000_set_type;
	l_site_use_type					varchar2_4000_set_type;
	l_addressee							varchar2_4000_set_type;
	l_mailstop							varchar2_4000_set_type;
	l_party_site_name					varchar2_4000_set_type;
	l_party_site_number				varchar2_4000_set_type;
	l_org_cnt_comments				varchar2_4000_set_type;
	l_contact_number					varchar2_4000_set_type;
	l_decision_maker_flag			varchar2_4000_set_type;
	l_department						varchar2_4000_set_type;
	l_department_code					varchar2_4000_set_type;
	l_rank								varchar2_4000_set_type;
	l_promotion_id						varchar2_4000_set_type;
	l_role_level						varchar2_4000_set_type;
	primary_contact_per_role_type varchar2_4000_set_type;
	l_cnt_pnt_content_source_type	varchar2_4000_set_type;
	l_phone_country_code				varchar2_4000_set_type;
	l_fax_country_code				varchar2_4000_set_type;
	l_phone_calling_calendar		varchar2_4000_set_type;
	l_cnt_pnt_time_zone				varchar2_4000_set_type;
	l_raw_phone_number				varchar2_4000_set_type;
	l_email_format						varchar2_4000_set_type;
	l_fax_extension					varchar2_4000_set_type;
	l_org_cnt_title					varchar2_4000_set_type;
	l_offer_id							varchar2_4000_set_type;
	l_request_id						varchar2_4000_set_type;
	l_program_application_id		varchar2_4000_set_type;
	l_program_id						varchar2_4000_set_type;
	l_program_update_date			varchar2_4000_set_type;
	l_load_error_message				varchar2_4000_set_type;
	l_phone_id							varchar2_4000_set_type;
	l_contact_party_id				varchar2_4000_set_type;
	l_security_group_id				varchar2_4000_set_type;
	l_net_worth							varchar2_4000_set_type;
	l_lead_number						varchar2_4000_set_type;
	l_prm_sales_lead_type			varchar2_4000_set_type;
	l_prm_exec_sponsor_flag			varchar2_4000_set_type;
	l_prm_prj_lead_in_place_flag	varchar2_4000_set_type;
	l_incumbent_partner_party_id	varchar2_4000_set_type;
	lincumbent_partner_resource_id varchar2_4000_set_type;
	l_prm_ind_classification_code	varchar2_4000_set_type;
	l_party_type						varchar2_4000_set_type;
	l_party_id							varchar2_4000_set_type;
	l_party_site_id					varchar2_4000_set_type;
	l_location_id						varchar2_4000_set_type;
	l_rel_party_id						varchar2_4000_set_type;
	l_sales_lead_id					varchar2_4000_set_type;
	l_customer_key						varchar2_4000_set_type;
	l_address_key						varchar2_4000_set_type;
	l_contact_key						varchar2_4000_set_type;
	l_new_party_flag					varchar2_4000_set_type;
	l_new_loc_flag						varchar2_4000_set_type;
	l_new_ps_flag						varchar2_4000_set_type;
	l_new_rel_flag						varchar2_4000_set_type;
	l_new_con_flag						varchar2_4000_set_type;
	l_lead_rank_id						varchar2_4000_set_type;
	l_marketing_score             varchar2_4000_set_type;
	l_PERSON_INITIALS             varchar2_4000_set_type;
	l_LEAD_DATE							varchar2_4000_set_type;

  l_CATEGORY_ID_1                varchar2_4000_set_type; --NUMBER
  l_CATEGORY_ID_2                varchar2_4000_set_type; --NUMBER
  l_CATEGORY_ID_3                varchar2_4000_set_type; --NUMBER
  l_CATEGORY_ID_4                varchar2_4000_set_type; --NUMBER
  l_CATEGORY_ID_5                varchar2_4000_set_type; --NUMBER
  l_SALES_METHODOLOGY_ID         varchar2_4000_set_type; --NUMBER
  l_DUNS_NUMBER_C                varchar2_4000_set_type; --VARCHAR2(30)
  --l_SOURCE_PRIMARY_REFERENCE     varchar2_4000_set_type; --VARCHAR2(30)
  l_SOURCE_SECONDARY_REFERENCE   varchar2_4000_set_type; --VARCHAR2(30)
  l_NOTE_TYPE                    varchar2_4000_set_type; --VARCHAR2(30)

	l_batch_id                    NUMBER;

	CURSOR c_get_batch_id (p_list_header_id NUMBER)
	IS SELECT batch_id
		FROM ams_imp_list_headers_all
		WHERE import_list_header_id = p_list_header_id;

	CURSOR c_lead_recs (p_list_header_id NUMBER)
	IS SELECT import_source_line_id, import_list_header_id,source_system,
				 lead_note, promotion_code,customer_name, sic_code, analysis_fy, customer_category_code,
				 fiscal_yearend_month, num_of_employees,potential_revenue_curr_fy,
				 potential_revenue_next_fy,customer_rank,tax_reference,
				 year_established,addr_do_not_mail_flag,url,cont_do_not_mail_flag,
				 country,address1,address2,address3,address4,city,postal_code,
				 state,province,county,email_address,sex_code,salutation,last_name,
				 title,first_name,job_title,phone_number,phone_status,phone_type,
             area_code,extension,middle_initial,job_title_code,mail_stop,
				 fax_number,fax_area_code,do_not_email_flag,do_not_fax_flag,do_not_phone_flag,
				 contact_role_code,channel_code,budget_amount,budget_status_code,currency_code,
				 decision_timeframe_code,close_reason,parent_project,description,vehicle_response_code,
				 interest_type_id_1,primary_interest_code_id_1,secondary_interest_code_id_1,
				 inventory_item_id_1,organization_id_1,uom_code_1,quantity_1,budget_amount_1,
				 source_promotion_id_1,offer_id_1,interest_type_id_2,primary_interest_code_id_2,
				 secondary_interest_code_id_2,inventory_item_id_2,organization_id_2,
				 uom_code_2,quantity_2,budget_amount_2,source_promotion_id_2,offer_id_2,interest_type_id_3,
				 primary_interest_code_id_3,secondary_interest_code_id_3,inventory_item_id_3,
				 organization_id_3,uom_code_3,quantity_3,budget_amount_3,source_promotion_id_3,
				 offer_id_3,interest_type_id_4,primary_interest_code_id_4,secondary_interest_code_id_4,
				 inventory_item_id_4,organization_id_4,uom_code_4,quantity_4,budget_amount_4,
				 source_promotion_id_4,offer_id_4,interest_type_id_5,primary_interest_code_id_5,
				 secondary_interest_code_id_5,inventory_item_id_5,organization_id_5,uom_code_5,
				 quantity_5,budget_amount_5,source_promotion_id_5,offer_id_5,orig_system_reference,
				 orig_system_code,urgent_flag,accept_flag,assign_date,assign_sales_group_id,
				 assign_to_person_id,assign_to_salesforce_id,auto_assignment_type,deleted_flag,
				 import_flag,keep_flag,prm_assignment_type,qualified_flag,reject_reason_code,
				 scorecard_id,primary_contact_flag,address_effective_date,address_lines_phonetic,
				 address_style,content_source_type,loc_description,loc_hierarchy_id,fa_location_id,
				 FLOOR,house_number,LANGUAGE,location_directions,po_box_number,
				 --location_position,
				 postal_plus4_code,sales_tax_geocode,sales_tax_inside_city_limits,short_description,
				 street,street_number,street_suffix,suite,time_zone,loc_validated_flag,duns_number,
				 group_type,gsa_indicator_flag,hq_branch_ind,jgzz_fiscal_code,known_as,known_as2,
				 known_as3,known_as4,known_as5,language_name,last_ordered_date,mission_statement,
				 organization_name_phonetic,party_number,person_first_name_phonetic,person_iden_type,
				 person_identifier,person_last_name_phonetic,person_name_suffix,person_previous_last_name,
				 party_reference_use_flag,sic_code_type,tax_name,total_num_of_orders,total_ordered_amount,
				 parties_validated_flag,ps_uses_comments,primary_per_type,site_use_type,addressee,
				 mailstop,party_site_name,party_site_number,org_cnt_comments,contact_number,
				 decision_maker_flag,department,department_code,rank,promotion_id,role_level,
				 primary_contact_per_role_type,cnt_pnt_content_source_type,phone_country_code,
				 fax_country_code,phone_calling_calendar,cnt_pnt_time_zone,
				 raw_phone_number,email_format,fax_extension,org_cnt_title,offer_id,request_id,
				 program_application_id,program_id,program_update_date,load_error_message,
				 phone_id,contact_party_id,security_group_id,net_worth,lead_number,prm_sales_lead_type,
				 prm_exec_sponsor_flag,prm_prj_lead_in_place_flag,incumbent_partner_party_id,
				 incumbent_partner_resource_id,prm_ind_classification_code,party_type,
				 party_id,party_site_id,location_id,rel_party_id,sales_lead_id,customer_key,
				 address_key,contact_key,new_party_flag,new_loc_flag,new_ps_flag,new_rel_flag,
				 new_con_flag,lead_rank_id, marketing_score, PERSON_INITIALS, LEAD_DATE,
         CATEGORY_ID_1, CATEGORY_ID_2, CATEGORY_ID_3, CATEGORY_ID_4,
         CATEGORY_ID_5, SALES_METHODOLOGY_ID, DUNS_NUMBER_C,
         SOURCE_SECONDARY_REFERENCE,
         NOTE_TYPE
         FROM ams_lead_mapping_v
				 WHERE import_list_header_id = p_list_header_id
				 AND load_status IN ('ACTIVE', 'RELOAD');
BEGIN
	--
	-- Initialize API return status to success.
	--
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF p_import_list_header_id IS NULL THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

	OPEN c_get_batch_id (p_import_list_header_id);
	FETCH c_get_batch_id INTO l_batch_id;
	CLOSE c_get_batch_id;

	OPEN c_lead_recs (p_import_list_header_id);
		LOOP
			FETCH c_lead_recs BULK COLLECT INTO
				l_import_source_line_id,
				l_import_list_header_id,
				l_source_system,
				l_lead_note,
				l_promotion_code,
				l_customer_name,
				l_sic_code,
				l_analysis_fy,
				l_customer_category_code,
				l_fiscal_yearend_month,
				l_num_of_employees,
				l_potential_revenue_curr_fy,
				l_potential_revenue_next_fy,
				l_customer_rank,
				l_tax_reference,
				l_year_established,
				l_addr_do_not_mail_flag,
				l_url,
				l_cont_do_not_mail_flag,
				l_country,
				l_address1,
				l_address2,
				l_address3,
				l_address4,
				l_city,
				l_postal_code,
				l_state,
				l_province,
				l_county,
				l_email_address,
				l_sex_code,
				l_salutation,
				l_last_name,
				l_title,
				l_first_name,
				l_job_title,
				l_phone_number,
				l_phone_status,
				l_phone_type,
				l_area_code,
				l_extension,
				l_middle_initial,
				l_job_title_code,
				l_mail_stop,
				l_fax_number,
				l_fax_area_code,
				l_do_not_email_flag,
				l_do_not_fax_flag,
				l_do_not_phone_flag,
				l_contact_role_code,
				l_channel_code,
				l_budget_amount,
				l_budget_status_code,
				l_currency_code,
				l_decision_timeframe_code,
				l_close_reason,
				l_parent_project,
				l_description,
				l_vehicle_response_code,
				l_interest_type_id_1,
				l_primary_interest_code_id_1,
				l_secondary_interest_code_id_1,
				l_inventory_item_id_1,
				l_organization_id_1,
				l_uom_code_1,
				l_quantity_1,
				l_budget_amount_1,
				l_source_promotion_id_1,
				l_offer_id_1,
				l_interest_type_id_2,
				l_primary_interest_code_id_2,
				l_secondary_interest_code_id_2 ,
				l_inventory_item_id_2,
				l_organization_id_2,
				l_uom_code_2,
				l_quantity_2,
				l_budget_amount_2,
				l_source_promotion_id_2,
				l_offer_id_2,
				l_interest_type_id_3,
				l_primary_interest_code_id_3,
				l_secondary_interest_code_id_3 ,
				l_inventory_item_id_3,
				l_organization_id_3,
				l_uom_code_3,
				l_quantity_3,
				l_budget_amount_3,
				l_source_promotion_id_3,
				l_offer_id_3,
				l_interest_type_id_4,
				l_primary_interest_code_id_4,
				l_secondary_interest_code_id_4 ,
				l_inventory_item_id_4,
				l_organization_id_4,
				l_uom_code_4,
				l_quantity_4,
				l_budget_amount_4,
				l_source_promotion_id_4,
				l_offer_id_4,
				l_interest_type_id_5,
				l_primary_interest_code_id_5,
				l_secondary_interest_code_id_5 ,
				l_inventory_item_id_5,
				l_organization_id_5,
				l_uom_code_5,
				l_quantity_5,
				l_budget_amount_5,
				l_source_promotion_id_5,
				l_offer_id_5,
				l_orig_system_reference,
				l_orig_system_code,
				l_urgent_flag,
				l_accept_flag,
				l_assign_date,
				l_assign_sales_group_id,
				l_assign_to_person_id,
				l_assign_to_salesforce_id,
				l_auto_assignment_type,
				l_deleted_flag,
				l_import_flag,
				l_keep_flag,
				l_prm_assignment_type,
				l_qualified_flag,
				l_reject_reason_code,
				l_scorecard_id,
				l_primary_contact_flag,
				l_address_effective_date,
				l_address_lines_phonetic,
				l_address_style,
				l_content_source_type,
				l_loc_description,
				l_loc_hierarchy_id,
				l_fa_location_id,
				l_floor,
				l_house_number,
				l_language,
				l_location_directions,
				l_po_box_number,
				--l_location_position,
				l_postal_plus4_code,
				l_sales_tax_geocode,
				l_sales_tax_inside_city_limits ,
				l_short_description,
				l_street,
				l_street_number,
				l_street_suffix,
				l_suite,
				l_time_zone,
				l_loc_validated_flag,
				l_duns_number,
				l_group_type,
				l_gsa_indicator_flag,
				l_hq_branch_ind,
				l_jgzz_fiscal_code,
				l_known_as,
				l_known_as2,
				l_known_as3,
				l_known_as4,
				l_known_as5,
				l_language_name,
				l_last_ordered_date,
				l_mission_statement,
				l_organization_name_phonetic,
				l_party_number,
				l_person_first_name_phonetic,
				l_person_iden_type,
				l_person_identifier,
				l_person_last_name_phonetic,
				l_person_name_suffix,
				l_person_previous_last_name,
				l_party_reference_use_flag,
				l_sic_code_type,
				l_tax_name,
				l_total_num_of_orders,
				l_total_ordered_amount,
				l_parties_validated_flag,
				l_ps_uses_comments,
				l_primary_per_type,
				l_site_use_type,
				l_addressee,
				l_mailstop,
				l_party_site_name,
				l_party_site_number,
				l_org_cnt_comments,
				l_contact_number,
				l_decision_maker_flag,
				l_department,
				l_department_code,
				l_rank,
				l_promotion_id,
				l_role_level,
				primary_contact_per_role_type ,
				l_cnt_pnt_content_source_type,
				l_phone_country_code,
				l_fax_country_code,
				l_phone_calling_calendar,
				l_cnt_pnt_time_zone,
				l_raw_phone_number,
				l_email_format,
				l_fax_extension,
				l_org_cnt_title,
				l_offer_id,
				l_request_id,
				l_program_application_id,
				l_program_id,
				l_program_update_date,
				l_load_error_message,
				l_phone_id,
				l_contact_party_id,
				l_security_group_id,
				l_net_worth,
				l_lead_number,
				l_prm_sales_lead_type,
				l_prm_exec_sponsor_flag,
				l_prm_prj_lead_in_place_flag,
				l_incumbent_partner_party_id,
				lincumbent_partner_resource_id ,
				l_prm_ind_classification_code,
				l_party_type,
				l_party_id,
				l_party_site_id,
				l_location_id,
				l_rel_party_id,
				l_sales_lead_id,
				l_customer_key,
				l_address_key,
				l_contact_key,
				l_new_party_flag,
				l_new_loc_flag,
				l_new_ps_flag,
				l_new_rel_flag,
				l_new_con_flag,
				l_lead_rank_id,
				l_marketing_score,
				l_PERSON_INITIALS,
				l_LEAD_DATE,
        l_CATEGORY_ID_1,
        l_CATEGORY_ID_2,
        l_CATEGORY_ID_3,
        l_CATEGORY_ID_4,
        l_CATEGORY_ID_5,
        l_SALES_METHODOLOGY_ID,
        l_DUNS_NUMBER_C,
        l_SOURCE_SECONDARY_REFERENCE,
        l_NOTE_TYPE
            LIMIT L_MAX_ROW_COUNT;

				FOR i IN 1 .. l_import_source_line_id.COUNT
					LOOP
						SELECT as_import_interface_s.NEXTVAL INTO l_interface_id(i)
						FROM dual;
					END LOOP;

				FORALL i IN 1 .. l_import_source_line_id.COUNT
					INSERT INTO as_import_interface
						(import_interface_id,
						last_update_date,
						last_updated_by,
						creation_date,
						created_by,
						last_update_login,
						imp_list_header_number,
						source_system,
						lead_note,
						promotion_code,
						customer_name,
						sic_code,
						analysis_fy,
						customer_category_code,
						fiscal_yearend_month,
						num_of_employees,
						potential_revenue_curr_fy,
						potential_revenue_next_fy,
						customer_rank,
						tax_reference,
						year_established,
						addr_do_not_mail_flag,
						url,
						cont_do_not_mail_flag,
						country,
						address1,
						address2,
						address3,
						address4,
						city,
						postal_code,
						state,
						province,
						county,
						email_address,
						sex_code,
						salutation,
						last_name,
						title,
						first_name,
						job_title,
						phone_number,
						phone_status,
						phone_type,
						area_code,
						extension,
						middle_initial,
						job_title_code,
						mail_stop,
						fax_number,
						fax_area_code,
						do_not_email_flag,
						do_not_fax_flag,
						do_not_phone_flag,
						contact_role_code,
						channel_code,
						budget_amount,
						budget_status_code,
						currency_code,
						decision_timeframe_code,
						close_reason,
						parent_project,
						description,
						vehicle_response_code,
						interest_type_id_1,
						primary_interest_code_id_1,
						secondary_interest_code_id_1,
						inventory_item_id_1,
						organization_id_1,
						uom_code_1,
						quantity_1,
						budget_amount_1,
						source_promotion_id_1,
						offer_id_1,
						interest_type_id_2,
						primary_interest_code_id_2,
						secondary_interest_code_id_2,
						inventory_item_id_2,
						organization_id_2,
						uom_code_2,
						quantity_2,
						budget_amount_2,
						source_promotion_id_2,
						offer_id_2,
						interest_type_id_3,
						primary_interest_code_id_3,
						secondary_interest_code_id_3,
						inventory_item_id_3,
						organization_id_3,
						uom_code_3,
						quantity_3,
						budget_amount_3,
						source_promotion_id_3,
						offer_id_3,
						interest_type_id_4,
						primary_interest_code_id_4,
						secondary_interest_code_id_4,
						inventory_item_id_4,
						organization_id_4,
						uom_code_4,
						quantity_4,
						budget_amount_4,
						source_promotion_id_4,
						offer_id_4,
						interest_type_id_5,
						primary_interest_code_id_5,
						secondary_interest_code_id_5,
						inventory_item_id_5,
						organization_id_5,uom_code_5,
						quantity_5,
						budget_amount_5,
						source_promotion_id_5,
						offer_id_5,
						orig_system_reference,
						orig_system_code,
						urgent_flag,
						accept_flag,
						assign_date, -- date
						assign_sales_group_id,
						assign_to_person_id,
						assign_to_salesforce_id,
						auto_assignment_type,
						deleted_flag,
						import_flag,
						keep_flag,
						prm_assignment_type,
						qualified_flag,
						reject_reason_code,
						scorecard_id,
						primary_contact_flag,
						address_effective_date, -- date
						address_lines_phonetic,
						address_style,
						content_source_type,
						loc_description,
						loc_hierarchy_id,
						fa_location_id,
						FLOOR,
						house_number,
						LANGUAGE,
						location_directions,
						po_box_number,
						--location_position,
						postal_plus4_code,
						sales_tax_geocode,
						sales_tax_inside_city_limits,
						short_description,
						street,
						street_number,
						street_suffix,
						suite,
						time_zone,
						loc_validated_flag,
						duns_number,
						group_type,
						gsa_indicator_flag,
						hq_branch_ind,
						jgzz_fiscal_code,
						known_as,
						known_as2,
						known_as3,
						known_as4,
						known_as5,
						language_name,
						last_ordered_date, -- date
						mission_statement,
						organization_name_phonetic,
						party_number,
						person_first_name_phonetic,
						person_iden_type,
						person_identifier,
						person_last_name_phonetic,
						person_name_suffix,
						person_previous_last_name,
						party_reference_use_flag,
						sic_code_type,
						tax_name,
						total_num_of_orders,
						total_ordered_amount,
						parties_validated_flag,
						ps_uses_comments,
						primary_per_type,
						site_use_type,
						addressee,
						mailstop,
						party_site_name,
						party_site_number,
						org_cnt_comments,
						contact_number,
						decision_maker_flag,
						department,
						department_code,
						rank,
						promotion_id,
						role_level,
						primary_contact_per_role_type,
						cnt_pnt_content_source_type,
						phone_country_code,
						fax_country_code,
						phone_calling_calendar,
						cnt_pnt_time_zone,
						raw_phone_number,
						email_format,
						fax_extension,
						org_cnt_title,
						offer_id,
						request_id,
						program_application_id,
						program_id,
						program_update_date, -- date
						load_error_message,
						phone_id,
						contact_party_id,
						security_group_id,
						net_worth,
						lead_number,
						prm_sales_lead_type,
						prm_exec_sponsor_flag,
						prm_prj_lead_in_place_flag,
						incumbent_partner_party_id,
						incumbent_partner_resource_id,
						prm_ind_classification_code,
						party_type,
						party_id,
						party_site_id,
						location_id,
						rel_party_id,
						sales_lead_id,
						customer_key,
						address_key,
						contact_key,
						new_party_flag,
						new_loc_flag,
						new_ps_flag,
						new_rel_flag,
						new_con_flag,
						lead_rank_id,
						marketing_score,
						PERSON_INITIALS,
						LEAD_DATE,
						load_type,
						load_date,
						load_status,
						status_code,
						batch_id,
            SOURCE_PRIMARY_REFERENCE,
            CATEGORY_ID_1,
            CATEGORY_ID_2,
            CATEGORY_ID_3,
            CATEGORY_ID_4,
            CATEGORY_ID_5,
            SALES_METHODOLOGY_ID,
            DUNS_NUMBER_C,
            SOURCE_SECONDARY_REFERENCE,
            NOTE_TYPE)

					VALUES
						(l_interface_id(i),
						l_current_date,
						l_user_id,
						l_current_date,
						l_user_id,
						l_login_id,
						l_import_source_line_id(i),
						LTRIM(RTRIM(l_source_system(i))),
						LTRIM(RTRIM(l_lead_note(i))),
						LTRIM(RTRIM(l_promotion_code(i))),
						LTRIM(RTRIM(l_customer_name(i))),
						LTRIM(RTRIM(l_sic_code(i))),
						LTRIM(RTRIM(l_analysis_fy(i))),
						LTRIM(RTRIM(l_customer_category_code(i))),
						LTRIM(RTRIM(l_fiscal_yearend_month(i))),
						LTRIM(RTRIM(l_num_of_employees(i))),
						LTRIM(RTRIM(l_potential_revenue_curr_fy(i))),
						LTRIM(RTRIM(l_potential_revenue_next_fy(i))),
						LTRIM(RTRIM(l_customer_rank(i))),
						LTRIM(RTRIM(l_tax_reference(i))),
						LTRIM(RTRIM(l_year_established(i))),
						LTRIM(RTRIM(l_addr_do_not_mail_flag(i))),
						LTRIM(RTRIM(l_url(i))),
						LTRIM(RTRIM(l_cont_do_not_mail_flag(i))),
						LTRIM(RTRIM(l_country(i))),
						LTRIM(RTRIM(l_address1(i))),
						LTRIM(RTRIM(l_address2(i))),
						LTRIM(RTRIM(l_address3(i))),
						LTRIM(RTRIM(l_address4(i))),
						LTRIM(RTRIM(l_city(i))),
						LTRIM(RTRIM(l_postal_code(i))),
						LTRIM(RTRIM(l_state(i))),
						LTRIM(RTRIM(l_province(i))),
						LTRIM(RTRIM(l_county(i))),
						LTRIM(RTRIM(l_email_address(i))),
						LTRIM(RTRIM(l_sex_code(i))),
						LTRIM(RTRIM(l_salutation(i))),
						LTRIM(RTRIM(l_last_name(i))),
						LTRIM(RTRIM(l_title(i))),
						LTRIM(RTRIM(l_first_name(i))),
						LTRIM(RTRIM(l_job_title(i))),
						LTRIM(RTRIM(l_phone_number(i))),
						LTRIM(RTRIM(l_phone_status(i))),
						LTRIM(RTRIM(l_phone_type(i))),
						LTRIM(RTRIM(l_area_code(i))),
						LTRIM(RTRIM(l_extension(i))),
						LTRIM(RTRIM(l_middle_initial(i))),
						LTRIM(RTRIM(l_job_title_code(i))),
						LTRIM(RTRIM(l_mail_stop(i))),
						LTRIM(RTRIM(l_fax_number(i))),
						LTRIM(RTRIM(l_fax_area_code(i))),
						LTRIM(RTRIM(l_do_not_email_flag(i))),
						LTRIM(RTRIM(l_do_not_fax_flag(i))),
						LTRIM(RTRIM(l_do_not_phone_flag(i))),
						LTRIM(RTRIM(l_contact_role_code(i))),
						LTRIM(RTRIM(l_channel_code(i))),
						LTRIM(RTRIM(l_budget_amount(i))),
						LTRIM(RTRIM(l_budget_status_code(i))),
						LTRIM(RTRIM(l_currency_code(i))),
						LTRIM(RTRIM(l_decision_timeframe_code(i))),
						LTRIM(RTRIM(l_close_reason(i))),
						LTRIM(RTRIM(l_parent_project(i))),
						LTRIM(RTRIM(l_description(i))),
						LTRIM(RTRIM(l_vehicle_response_code(i))),
						LTRIM(RTRIM(l_interest_type_id_1(i))),
						LTRIM(RTRIM(l_primary_interest_code_id_1(i))),
						LTRIM(RTRIM(l_secondary_interest_code_id_1(i))),
						LTRIM(RTRIM(l_inventory_item_id_1(i))),
						LTRIM(RTRIM(l_organization_id_1(i))),
						LTRIM(RTRIM(l_uom_code_1(i))),
						LTRIM(RTRIM(l_quantity_1(i))),
						LTRIM(RTRIM(l_budget_amount_1(i))),
						LTRIM(RTRIM(l_source_promotion_id_1(i))),
						LTRIM(RTRIM(l_offer_id_1(i))),
						LTRIM(RTRIM(l_interest_type_id_2(i))),
						LTRIM(RTRIM(l_primary_interest_code_id_2(i))),
						LTRIM(RTRIM(l_secondary_interest_code_id_2(i))),
						LTRIM(RTRIM(l_inventory_item_id_2(i))),
						LTRIM(RTRIM(l_organization_id_2(i))),
						LTRIM(RTRIM(l_uom_code_2(i))),
						LTRIM(RTRIM(l_quantity_2(i))),
						LTRIM(RTRIM(l_budget_amount_2(i))),
						LTRIM(RTRIM(l_source_promotion_id_2(i))),
						LTRIM(RTRIM(l_offer_id_2(i))),
						LTRIM(RTRIM(l_interest_type_id_3(i))),
						LTRIM(RTRIM(l_primary_interest_code_id_3(i))),
						LTRIM(RTRIM(l_secondary_interest_code_id_3(i))),
						LTRIM(RTRIM(l_inventory_item_id_3(i))),
						LTRIM(RTRIM(l_organization_id_3(i))),
						LTRIM(RTRIM(l_uom_code_3(i))),
						LTRIM(RTRIM(l_quantity_3(i))),
						LTRIM(RTRIM(l_budget_amount_3(i))),
						LTRIM(RTRIM(l_source_promotion_id_3(i))),
						LTRIM(RTRIM(l_offer_id_3(i))),
						LTRIM(RTRIM(l_interest_type_id_4(i))),
						LTRIM(RTRIM(l_primary_interest_code_id_4(i))),
						LTRIM(RTRIM(l_secondary_interest_code_id_4(i))),
						LTRIM(RTRIM(l_inventory_item_id_4(i))),
						LTRIM(RTRIM(l_organization_id_4(i))),
						LTRIM(RTRIM(l_uom_code_4(i))),
						LTRIM(RTRIM(l_quantity_4(i))),
						LTRIM(RTRIM(l_budget_amount_4(i))),
						LTRIM(RTRIM(l_source_promotion_id_4(i))),
						LTRIM(RTRIM(l_offer_id_4(i))),
						LTRIM(RTRIM(l_interest_type_id_5(i))),
						LTRIM(RTRIM(l_primary_interest_code_id_5(i))),
						LTRIM(RTRIM(l_secondary_interest_code_id_5(i))),
						LTRIM(RTRIM(l_inventory_item_id_5(i))),
						LTRIM(RTRIM(l_organization_id_5(i))),
						LTRIM(RTRIM(l_uom_code_5(i))),
						LTRIM(RTRIM(l_quantity_5(i))),
						LTRIM(RTRIM(l_budget_amount_5(i))),
						LTRIM(RTRIM(l_source_promotion_id_5(i))),
						LTRIM(RTRIM(l_offer_id_5(i))),
						LTRIM(RTRIM(l_orig_system_reference(i))),
						LTRIM(RTRIM(l_orig_system_code(i))),
						LTRIM(RTRIM(l_urgent_flag(i))),
						LTRIM(RTRIM(l_accept_flag(i))),
						TO_DATE(l_assign_date(i), 'MM/DD/YYYY'),
						LTRIM(RTRIM(l_assign_sales_group_id(i))),
						LTRIM(RTRIM(l_assign_to_person_id(i))),
						LTRIM(RTRIM(l_assign_to_salesforce_id(i))),
						LTRIM(RTRIM(l_auto_assignment_type(i))),
						LTRIM(RTRIM(l_deleted_flag(i))),
						LTRIM(RTRIM(l_import_flag(i))),
						LTRIM(RTRIM(l_keep_flag(i))),
						LTRIM(RTRIM(l_prm_assignment_type(i))),
						LTRIM(RTRIM(l_qualified_flag(i))),
						LTRIM(RTRIM(l_reject_reason_code(i))),
						LTRIM(RTRIM(l_scorecard_id(i))),
						LTRIM(RTRIM(l_primary_contact_flag(i))),
						TO_DATE(l_address_effective_date(i), 'MM/DD/YYYY'),
						LTRIM(RTRIM(l_address_lines_phonetic(i))),
						LTRIM(RTRIM(l_address_style(i))),
						LTRIM(RTRIM(l_content_source_type(i))),
						LTRIM(RTRIM(l_loc_description(i))),
						LTRIM(RTRIM(l_loc_hierarchy_id(i))),
						LTRIM(RTRIM(l_fa_location_id(i))),
						LTRIM(RTRIM(l_floor(i))),
						LTRIM(RTRIM(l_house_number(i))),
						LTRIM(RTRIM(l_language(i))),
						LTRIM(RTRIM(l_location_directions(i))),
						LTRIM(RTRIM(l_po_box_number(i))),
						--location_position(i))),
						LTRIM(RTRIM(l_postal_plus4_code(i))),
						LTRIM(RTRIM(l_sales_tax_geocode(i))),
						LTRIM(RTRIM(l_sales_tax_inside_city_limits(i))),
						LTRIM(RTRIM(l_short_description(i))),
						LTRIM(RTRIM(l_street(i))),
						LTRIM(RTRIM(l_street_number(i))),
						LTRIM(RTRIM(l_street_suffix(i))),
						LTRIM(RTRIM(l_suite(i))),
						LTRIM(RTRIM(l_time_zone(i))),
						LTRIM(RTRIM(l_loc_validated_flag(i))),
						LTRIM(RTRIM(l_duns_number(i))),
						LTRIM(RTRIM(l_group_type(i))),
						LTRIM(RTRIM(l_gsa_indicator_flag(i))),
						LTRIM(RTRIM(l_hq_branch_ind(i))),
						LTRIM(RTRIM(l_jgzz_fiscal_code(i))),
						LTRIM(RTRIM(l_known_as(i))),
						LTRIM(RTRIM(l_known_as2(i))),
						LTRIM(RTRIM(l_known_as3(i))),
						LTRIM(RTRIM(l_known_as4(i))),
						LTRIM(RTRIM(l_known_as5(i))),
						LTRIM(RTRIM(l_language_name(i))),
						TO_DATE(l_last_ordered_date(i), 'MM/DD/YYYY'),
						LTRIM(RTRIM(l_mission_statement(i))),
						LTRIM(RTRIM(l_organization_name_phonetic(i))),
						LTRIM(RTRIM(l_party_number(i))),
						LTRIM(RTRIM(l_person_first_name_phonetic(i))),
						LTRIM(RTRIM(l_person_iden_type(i))),
						LTRIM(RTRIM(l_person_identifier(i))),
						LTRIM(RTRIM(l_person_last_name_phonetic(i))),
						LTRIM(RTRIM(l_person_name_suffix(i))),
						LTRIM(RTRIM(l_person_previous_last_name(i))),
						LTRIM(RTRIM(l_party_reference_use_flag(i))),
						LTRIM(RTRIM(l_sic_code_type(i))),
						LTRIM(RTRIM(l_tax_name(i))),
						LTRIM(RTRIM(l_total_num_of_orders(i))),
						LTRIM(RTRIM(l_total_ordered_amount(i))),
						LTRIM(RTRIM(l_parties_validated_flag(i))),
						LTRIM(RTRIM(l_ps_uses_comments(i))),
						LTRIM(RTRIM(l_primary_per_type(i))),
						LTRIM(RTRIM(l_site_use_type(i))),
						LTRIM(RTRIM(l_addressee(i))),
						LTRIM(RTRIM(l_mailstop(i))),
						LTRIM(RTRIM(l_party_site_name(i))),
						LTRIM(RTRIM(l_party_site_number(i))),
						LTRIM(RTRIM(l_org_cnt_comments(i))),
						LTRIM(RTRIM(l_contact_number(i))),
						LTRIM(RTRIM(l_decision_maker_flag(i))),
						LTRIM(RTRIM(l_department(i))),
						LTRIM(RTRIM(l_department_code(i))),
						LTRIM(RTRIM(l_rank(i))),
						LTRIM(RTRIM(l_promotion_id(i))),
						LTRIM(RTRIM(l_role_level(i))),
						LTRIM(RTRIM(primary_contact_per_role_type(i))),
						LTRIM(RTRIM(l_cnt_pnt_content_source_type(i))),
						LTRIM(RTRIM(l_phone_country_code(i))),
						LTRIM(RTRIM(l_fax_country_code(i))),
						LTRIM(RTRIM(l_phone_calling_calendar(i))),
						LTRIM(RTRIM(l_cnt_pnt_time_zone(i))),
						LTRIM(RTRIM(l_raw_phone_number(i))),
						LTRIM(RTRIM(l_email_format(i))),
						LTRIM(RTRIM(l_fax_extension(i))),
						LTRIM(RTRIM(l_org_cnt_title(i))),
						LTRIM(RTRIM(l_offer_id(i))),
						LTRIM(RTRIM(l_request_id(i))),
						LTRIM(RTRIM(l_program_application_id(i))),
						LTRIM(RTRIM(l_program_id(i))),
						TO_DATE(l_program_update_date(i), 'MM/DD/YYYY'),
						LTRIM(RTRIM(l_load_error_message(i))),
						LTRIM(RTRIM(l_phone_id(i))),
						LTRIM(RTRIM(l_contact_party_id(i))),
						LTRIM(RTRIM(l_security_group_id(i))),
						LTRIM(RTRIM(l_net_worth(i))),
						LTRIM(RTRIM(l_lead_number(i))),
						LTRIM(RTRIM(l_prm_sales_lead_type(i))),
						LTRIM(RTRIM(l_prm_exec_sponsor_flag(i))),
						LTRIM(RTRIM(l_prm_prj_lead_in_place_flag(i))),
						LTRIM(RTRIM(l_incumbent_partner_party_id(i))),
						LTRIM(RTRIM(lincumbent_partner_resource_id(i))),
						LTRIM(RTRIM(l_prm_ind_classification_code(i))),
						LTRIM(RTRIM(l_party_type(i))),
						LTRIM(RTRIM(l_party_id(i))),
						LTRIM(RTRIM(l_party_site_id(i))),
						LTRIM(RTRIM(l_location_id(i))),
						LTRIM(RTRIM(l_rel_party_id(i))),
						LTRIM(RTRIM(l_sales_lead_id(i))),
						LTRIM(RTRIM(l_customer_key(i))),
						LTRIM(RTRIM(l_address_key(i))),
						LTRIM(RTRIM(l_contact_key(i))),
						LTRIM(RTRIM(l_new_party_flag(i))),
						LTRIM(RTRIM(l_new_loc_flag(i))),
						LTRIM(RTRIM(l_new_ps_flag(i))),
						LTRIM(RTRIM(l_new_rel_flag(i))),
						LTRIM(RTRIM(l_new_con_flag(i))),
						LTRIM(RTRIM(l_lead_rank_id(i))),
						LTRIM(RTRIM(l_marketing_score(i))),
						LTRIM(RTRIM(l_PERSON_INITIALS(i))),
						LTRIM(RTRIM(l_LEAD_DATE(i))),
						l_LOAD_TYPE,
						L_LOAD_DATE,
						L_LOAD_STATUS,
						L_STATUS_CODE,
						l_batch_id,
            l_import_source_line_id(i),
            LTRIM(RTRIM(l_CATEGORY_ID_1(i))),
            LTRIM(RTRIM(l_CATEGORY_ID_2(i))),
            LTRIM(RTRIM(l_CATEGORY_ID_3(i))),
            LTRIM(RTRIM(l_CATEGORY_ID_4(i))),
            LTRIM(RTRIM(l_CATEGORY_ID_5(i))),
            LTRIM(RTRIM(l_SALES_METHODOLOGY_ID(i))),
            LTRIM(RTRIM(l_DUNS_NUMBER_C(i))),
            LTRIM(RTRIM(l_SOURCE_SECONDARY_REFERENCE(i))),
            LTRIM(RTRIM(l_NOTE_TYPE(i))));
			EXIT WHEN c_lead_recs%NOTFOUND;
		END LOOP;
      CLOSE c_lead_recs;

		COMMIT;

	EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
			AMS_Utility_PVT.Create_Log (
				x_return_status   => x_return_status,
				p_arc_log_used_by => G_ARC_IMPORT_HEADER,
				p_log_used_by_id  => p_import_list_header_id,
				p_msg_data        => 'Expected error in ' || L_FULL_NAME,
				p_msg_type        => 'DEBUG'
			);
			x_return_status := FND_API.G_RET_STS_ERROR;
		WHEN OTHERS THEN
			IF c_lead_recs%ISOPEN THEN
				CLOSE c_lead_recs;
			END IF;
			AMS_Utility_PVT.Create_Log (
				x_return_status   => x_return_status,
				p_arc_log_used_by => G_ARC_IMPORT_HEADER,
				p_log_used_by_id  => p_import_list_header_id,
				p_msg_data        => 'Error in ' || L_FULL_NAME || ': '|| SQLERRM||' '||SQLCODE,
				p_msg_type        => 'DEBUG'
			);
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Load_Lead_Data_To_Interface;

-- NAME
--     Insert_Lead_Data
--
-- PURPOSE
--     The procedure insert a collection of data into the "ams_imp_source_lines"
--     The "p_data" contains all data needed to be inserted, assuming all data
--     types are "VARCHAR2". For example, if the data to be inserted are the
--     followings:
--
--     Row Number   1        2        3        4
--     Column1      Frank    Smith    Scott    Marry
--     Column2      Amos     Anderson Baber    Beier
--     Column3      75039    77002    23060    03062
--
--     The data is stored in the "p_data" as: "Frank", "Smith", "Scott", "Marry",
--     "Amos", "Anderson", "Baber", "Beier", "75039", "77002", "23060", "03062".
--
-- NOTES
--
-- HISTORY
-- 05/13/2001   huili      Created.
-- 06/04/2001   huili      Populated the "loaded_no_of_rows" and "loaded_date"
--                         columns in the "ams_imp_list_headers_all" table.
--
--06/08/2001    huili      Changed logic for setting up the "status_code" of
--                         the "ams_imp_list_headers_all" table.
PROCEDURE Insert_Lead_Data (
  p_api_version                 IN    NUMBER,
  p_init_msg_list               IN    VARCHAR2 := FND_API.G_TRUE,
  p_commit                      IN    VARCHAR2 := FND_API.G_TRUE,
  p_import_list_header_id       IN    NUMBER,
  p_data                        IN    char_data_set_type_w,
  p_error_rows                  IN    num_data_set_type_w,
  p_row_count                   IN    NUMBER,
  x_return_status               OUT NOCOPY   VARCHAR2,
  x_msg_count                   OUT NOCOPY   NUMBER,
  x_msg_data                    OUT NOCOPY   VARCHAR2
)
IS
  --
  -- Standard API information constants.
  --
  L_API_VERSION       CONSTANT NUMBER := 1.0;
  L_API_NAME          CONSTANT VARCHAR2(30) := 'Insert_Lead_Data';
  L_FULL_NAME         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;
  l_return_status        VARCHAR(1);

  l_columns           char_data_set_type_w;
  l_index             NUMBER    := 1;
  l_temp_vol_name     VARCHAR2(30);

  l_str_col_names     char_data_set_type_w;
  l_num_col_names     char_data_set_type_w;
  l_str_data          char_data_set_type_w;
  l_num_data          num_data_set_type_w;
  l_row_count         NUMBER;
  l_field_table_name  VARCHAR2(30) := 'AMS_LEAD_MAPPING_V';
  l_batch_id          NUMBER;

  --06/16/2001 huili
  l_dup_flag          VARCHAR2(1);

  --06/18/2001 huili
  l_status_id         NUMBER;

  l_msg_data VARCHAR2(2000);

  --06/18/2001 huili
  CURSOR c_get_status_id IS
    SELECT user_status_id
    FROM ams_user_statuses_vl
    WHERE UPPER(system_status_type) = 'AMS_IMPORT_STATUS'
    AND UPPER(system_status_code) = 'STAGED'
    AND default_flag = 'Y';

  CURSOR c_list_fields (l_import_list_header_id NUMBER) IS
    SELECT A.field_column_name, B.batch_id
    FROM ams_list_src_fields A, ams_imp_list_headers_all b
    WHERE b.IMPORT_LIST_HEADER_ID = l_import_list_header_id
    AND b.LIST_SOURCE_TYPE_ID = A.LIST_SOURCE_TYPE_ID
    ORDER BY LIST_SOURCE_FIELD_ID;

  --06/16/2001 huili added
  CURSOR c_dup_checking (l_import_list_header_id NUMBER) IS
    SELECT dedupe_flag
    FROM ams_imp_list_headers_all
    WHERE import_list_header_id = l_import_list_header_id;

BEGIN

  --
  -- Initialize message list if p_init_msg_list is set to TRUE.
  --
  IF FND_API.To_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  --AMS_Utility_PVT.Create_Log (
  --  x_return_status   => l_return_status,
  --  p_arc_log_used_by => G_ARC_IMPORT_HEADER,
  --  p_log_used_by_id  => p_import_list_header_id,
  --  p_msg_data        => 'Start client lead importing.',
  --  p_msg_type        => 'DEBUG'
  --);

  --
  -- Standard check for API version compatibility.
  --
  IF NOT FND_API.Compatible_API_Call (L_API_VERSION,
                                      p_api_version,
                                      L_API_NAME,
                                      G_PKG_NAME)
  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  --
  -- Initialize API return status to success.
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN c_list_fields(p_import_list_header_id);
  LOOP
    FETCH c_list_fields INTO l_temp_vol_name, l_batch_id;
    EXIT WHEN c_list_fields%NOTFOUND;

    l_columns(l_index) := l_temp_vol_name;
    l_index := l_index + 1;
  END LOOP;
  CLOSE c_list_fields;

  l_row_count := p_data.COUNT / l_columns.COUNT;

  l_str_col_names(1) := 'IMPORT_SUCCESSFUL_FLAG';

  l_str_data(1) := 'N';

  l_num_col_names(1) := 'IMPORT_LIST_HEADER_ID';
  l_num_data(1) := p_import_list_header_id;
  l_num_col_names(2) := 'OBJECT_VERSION_NUMBER';
  l_num_data(2) := 1;

  l_num_col_names(3) := 'BATCH_ID';
  l_num_data(3) := l_batch_id;

  Insert_Data (
    p_api_version                 => 1.0,
    p_table_name                  => l_field_table_name,
    p_prim_key_name               => 'IMPORT_SOURCE_LINE_ID',
    p_seq_name                    => 'AMS_IMP_SOURCE_LINES_S',
    p_str_col_names               => l_str_col_names,
    p_num_col_names               => l_num_col_names,
    p_str_data                    => l_str_data,
    p_num_data                    => l_num_data,
    p_col_names                   => l_columns,
    p_data                        => p_data,
    p_error_rows                  => p_error_rows,
    p_row_count                   => l_row_count,
    x_return_status               => x_return_status,
    x_msg_count                   => x_msg_count,
    x_msg_data                    => l_msg_data);

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    AMS_Utility_PVT.Create_Log (
      x_return_status   => l_return_status,
      p_arc_log_used_by => G_ARC_IMPORT_HEADER,
      p_log_used_by_id  => p_import_list_header_id,
      p_msg_data        => l_msg_data,
      p_msg_type        => 'DEBUG'
    );
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    AMS_Utility_PVT.Create_Log (
      x_return_status   => l_return_status,
      p_arc_log_used_by => G_ARC_IMPORT_HEADER,
      p_log_used_by_id  => p_import_list_header_id,
      p_msg_data        => l_msg_data,
      p_msg_type        => 'DEBUG'
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_status_id := NULL;
  OPEN c_get_status_id;
  FETCH c_get_status_id INTO l_status_id;
  CLOSE c_get_status_id;

  --huili 06/19/2001 added NULL checking for l_status_id
  IF l_status_id IS NOT NULL THEN
    UPDATE ams_imp_list_headers_all
      SET status_code = 'STAGED',
		--loaded_no_of_rows = p_row_count,
          loaded_date = SYSDATE, user_status_id = l_status_id
      WHERE import_list_header_id = p_import_list_header_id;
  ELSE
    UPDATE ams_imp_list_headers_all
      SET status_code = 'STAGED',
		--loaded_no_of_rows = p_row_count,
          loaded_date = SYSDATE
      WHERE import_list_header_id = p_import_list_header_id;
  END IF;
  -- end change
/*
  -- 06/16/2001 huili added
  l_dup_flag := NULL;
  OPEN c_dup_checking (p_import_list_header_id);
  FETCH c_dup_checking INTO l_dup_flag;
  CLOSE c_dup_checking;

  IF l_dup_flag IS NOT NULL AND UPPER(l_dup_flag) = 'Y' THEN
    AMS_ListImport_PVT.dedup_check(
      p_import_list_header_id => p_import_list_header_id);
  END IF;
  -- 06/16/2001
*/
  --
  -- Standard check for commit request.
  --
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  --AMS_Utility_PVT.Create_Log (
  --  x_return_status   => l_return_status,
  --  p_arc_log_used_by => G_ARC_IMPORT_HEADER,
  --  p_log_used_by_id  => p_import_list_header_id,
  --  p_msg_data        => 'Client lead:' || l_time,
  --  p_msg_type        => 'DEBUG'
  --);

  --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT variable.
   --
   FND_MSG_PUB.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    FND_API.G_FALSE
   );
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
      p_count         =>     x_msg_count,
      p_data          =>     x_msg_data
    );
  RAISE FND_API.G_EXC_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get (
      p_count         =>     x_msg_count,
      p_data          =>     x_msg_data
    );
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  WHEN OTHERS THEN
    FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
    FND_MESSAGE.Set_Token('ROW','Error in client lead import program ' || SQLERRM||' '||SQLCODE);
    AMS_Utility_PVT.Create_Log (
      x_return_status   => l_return_status,
      p_arc_log_used_by => G_ARC_IMPORT_HEADER,
      p_log_used_by_id  => p_import_list_header_id,
      p_msg_data        => FND_MESSAGE.get,
      p_msg_type        => 'DEBUG'
   );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
    END IF;
    FND_MSG_PUB.Count_And_Get (
      p_count         =>     x_msg_count,
      p_data          =>     x_msg_data
    );
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Insert_Lead_Data;


-- NAME
--     Insert_List_Data
--
-- PURPOSE
--     The procedure insert a collection of data into the "ams_imp_source_lines"
--     The "p_data" contains all data needed to be inserted, assuming all data
--     types are "VARCHAR2". For example, if the data to be inserted are the
--     followings:
--
--     Row Number   1        2        3        4
--     Column1      Frank    Smith    Scott    Marry
--     Column2      Amos     Anderson Baber    Beier
--     Column3      75039    77002    23060    03062
--
--     The data is stored in the "p_data" as: "Frank", "Smith", "Scott", "Marry",
--     "Amos", "Anderson", "Baber", "Beier", "75039", "77002", "23060", "03062".
--
-- NOTES
--
-- HISTORY
-- 04/16/2001   huili      Created.
-- 04/26/2001   huili      Added table name to the cursor.
-- 05/10/2001   huili      Update "ams_imp_list_headers_all" table.
-- 06/18/2001   huili      Also update status_code for the
--                         "ams_imp_list_headers_all" table
--
PROCEDURE Insert_List_Data (
   p_api_version                 IN    NUMBER,
   p_init_msg_list               IN    VARCHAR2 := FND_API.G_TRUE,
   p_commit                      IN    VARCHAR2 := FND_API.G_TRUE,
   p_import_list_header_id       IN    NUMBER,
   p_data                        IN    char_data_set_type_w,
   p_row_count                   IN    NUMBER,
   p_error_rows                  IN    num_data_set_type_w,
   x_return_status               OUT NOCOPY   VARCHAR2,
   x_msg_count                   OUT NOCOPY   NUMBER,
   x_msg_data                    OUT NOCOPY   VARCHAR2
)
IS
  --
  -- Standard API information constants.
  --
  L_API_VERSION       CONSTANT NUMBER := 1.0;
  L_API_NAME          CONSTANT VARCHAR2(30) := 'Insert_List_Data';
  L_FULL_NAME         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;
  l_return_status        VARCHAR(1);

  l_columns           char_data_set_type_w;
  l_index             NUMBER    := 1;
  l_temp_vol_name     VARCHAR2(30);

  l_str_col_names     char_data_set_type_w;
  l_num_col_names     char_data_set_type_w;
  l_str_data          char_data_set_type_w;
  l_num_data          num_data_set_type_w;
  l_row_count         NUMBER;
  l_field_table_name  VARCHAR2(30);
  l_dup_flag          VARCHAR2(1);
  l_batch_id          NUMBER;

  --06/18/2001 huili
  l_status_id         NUMBER;

  l_msg_data VARCHAR2 (2000);

  --06/18/2001 huili
  CURSOR c_get_status_id IS
    SELECT user_status_id
    FROM ams_user_statuses_vl
    WHERE UPPER(system_status_type) = 'AMS_IMPORT_STATUS'
    AND UPPER(system_status_code) = 'STAGED'
    AND default_flag = 'Y';

  CURSOR c_list_fields (l_import_list_header_id NUMBER) IS
    SELECT A.field_column_name, A.FIELD_TABLE_NAME, B.BATCH_ID
    FROM ams_list_src_fields A, ams_imp_list_headers_all b
    WHERE b.IMPORT_LIST_HEADER_ID = l_import_list_header_id
    AND b.LIST_SOURCE_TYPE_ID = A.LIST_SOURCE_TYPE_ID
    ORDER BY LIST_SOURCE_FIELD_ID;

  --06/16/2001 huili added
  CURSOR c_dup_checking (l_import_list_header_id NUMBER) IS
    SELECT dedupe_flag
    FROM ams_imp_list_headers_all
    WHERE import_list_header_id = l_import_list_header_id;

  l_data_count NUMBER := p_data.COUNT;
BEGIN


  --AMS_Utility_PVT.Create_Log (
  --  x_return_status   => l_return_status,
  --  p_arc_log_used_by => G_ARC_IMPORT_HEADER,
  --  p_log_used_by_id  => p_import_list_header_id,
  --  p_msg_data        => 'Starting client list importing...',
  --  p_msg_type        => 'DEBUG'
  --);

  --
  -- Initialize message list if p_init_msg_list is set to TRUE.
  --
  IF FND_API.To_Boolean (p_init_msg_list) THEN
    FND_MSG_PUB.Initialize;
  END IF;

  --
  -- Standard check for API version compatibility.
  --
  --IF NOT FND_API.Compatible_API_Call (L_API_VERSION,
  --                                    p_api_version,
  --                                    L_API_NAME,
  --                                    G_PKG_NAME)
  --THEN
 --   FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
 --   FND_MESSAGE.Set_Token('ROW','API is not compatible for ' || G_PKG_NAME || '.'|| L_API_NAME);
 --   AMS_Utility_PVT.Create_Log (
 --     x_return_status   => l_return_status,
 --     p_arc_log_used_by => G_ARC_IMPORT_HEADER,
 --     p_log_used_by_id  => p_import_list_header_id,
 --     p_msg_data        => FND_MESSAGE.get,
 --     p_msg_type        => 'DEBUG'
 --   );
 --   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
 -- END IF;

  --
  -- Initialize API return status to success.
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN c_list_fields(p_import_list_header_id);
  LOOP
    FETCH c_list_fields INTO l_temp_vol_name, l_field_table_name, l_batch_id;
    EXIT WHEN c_list_fields%NOTFOUND;

    l_columns(l_index) := l_temp_vol_name;
    l_index := l_index + 1;
  END LOOP;
  CLOSE c_list_fields;

  l_row_count := p_data.COUNT / l_columns.COUNT;

  l_str_col_names(1) := 'IMPORT_SUCCESSFUL_FLAG';
  l_num_col_names(1) := 'IMPORT_LIST_HEADER_ID';
  l_num_col_names(2) := 'OBJECT_VERSION_NUMBER';
  l_num_col_names(3) := 'BATCH_ID';
  l_str_data(1) := 'N';
  l_num_data(1) := p_import_list_header_id;
  l_num_data(2) := 1;
  l_num_data(3) := l_batch_id;

  Insert_Data (
    p_api_version                 => 1.0,
    p_table_name                  => l_field_table_name,
    p_prim_key_name               => 'IMPORT_SOURCE_LINE_ID',
    p_seq_name                    => 'AMS_IMP_SOURCE_LINES_S',
    p_str_col_names               => l_str_col_names,
    p_num_col_names               => l_num_col_names,
    p_str_data                    => l_str_data,
    p_num_data                    => l_num_data,
    p_col_names                   => l_columns,
    p_data                        => p_data,
    p_error_rows                  => p_error_rows,
    p_row_count                   => l_row_count,
    x_return_status               => x_return_status,
    x_msg_count                   => x_msg_count,
    x_msg_data                    => l_msg_data);

  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    AMS_Utility_PVT.Create_Log (
      x_return_status   => l_return_status,
      p_arc_log_used_by => G_ARC_IMPORT_HEADER,
      p_log_used_by_id  => p_import_list_header_id,
      p_msg_data        => l_msg_data,
      p_msg_type        => 'DEBUG'
    );
    RAISE FND_API.G_EXC_ERROR;
  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    AMS_Utility_PVT.Create_Log (
      x_return_status   => l_return_status,
      p_arc_log_used_by => G_ARC_IMPORT_HEADER,
      p_log_used_by_id  => p_import_list_header_id,
      p_msg_data        => l_msg_data,
      p_msg_type        => 'DEBUG'
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  l_status_id := NULL;
  OPEN c_get_status_id;
  FETCH c_get_status_id INTO l_status_id;
  CLOSE c_get_status_id;

  --huili added NULL checking for l_status_id
  IF l_status_id IS NOT NULL THEN
    UPDATE ams_imp_list_headers_all
      SET status_code = 'STAGED',
		--loaded_no_of_rows = p_row_count,
          loaded_date = SYSDATE, user_status_id = l_status_id
      WHERE import_list_header_id = p_import_list_header_id;
  ELSE
    UPDATE ams_imp_list_headers_all
      SET status_code = 'STAGED',
		--loaded_no_of_rows = p_row_count,
          loaded_date = SYSDATE
      WHERE import_list_header_id = p_import_list_header_id;
  END IF;
  -- end change
/*
  -- 06/16/2001 huili added
  l_dup_flag := NULL;
  OPEN c_dup_checking (p_import_list_header_id);
  FETCH c_dup_checking INTO l_dup_flag;
  CLOSE c_dup_checking;

  IF l_dup_flag IS NOT NULL AND UPPER(l_dup_flag) = 'Y' THEN
    AMS_ListImport_PVT.dedup_check(
      p_import_list_header_id => p_import_list_header_id);
  END IF;
  -- 06/16/2001
*/
  --
  -- Standard check for commit request.
  --
  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT WORK;
  END IF;

  --AMS_Utility_PVT.Create_Log (
  --  x_return_status   => l_return_status,
  --  p_arc_log_used_by => G_ARC_IMPORT_HEADER,
  --  p_log_used_by_id  => p_import_list_header_id,
  --  p_msg_data        => 'Client list importing is finished without error...',
  --  p_msg_type        => 'DEBUG'
  --);
  --
   -- Standard API to get message count, and if 1,
   -- set the message data OUT variable.
   --
   FND_MSG_PUB.Count_And_Get (
      p_count           =>    x_msg_count,
      p_data            =>    x_msg_data,
      p_encoded         =>    FND_API.G_FALSE
   );
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
      p_count         =>     x_msg_count,
      p_data          =>     x_msg_data
    );
  RAISE FND_API.G_EXC_ERROR;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get (
      p_count         =>     x_msg_count,
      p_data          =>     x_msg_data
    );
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
  WHEN OTHERS THEN
    FND_MESSAGE.set_name('AMS', 'API_DEBUG_MESSAGE');
    FND_MESSAGE.Set_Token('ROW','Error in client list import program ' || SQLERRM||' '||SQLCODE);
    AMS_Utility_PVT.Create_Log (
      x_return_status   => l_return_status,
      p_arc_log_used_by => G_ARC_IMPORT_HEADER,
      p_log_used_by_id  => p_import_list_header_id,
      p_msg_data        => FND_MESSAGE.get,
      p_msg_type        => 'DEBUG'
   );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, L_API_NAME);
    END IF;
    FND_MSG_PUB.Count_And_Get (
      p_count         =>     x_msg_count,
      p_data          =>     x_msg_data
    );
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Insert_List_Data;

PROCEDURE Write_Message (
   x_return_status   OUT NOCOPY VARCHAR2,
   p_log_used_by_id  IN  VARCHAR2,
   p_msg_data        IN  VARCHAR2,
   p_msg_type         IN  VARCHAR2
)
IS

BEGIN

   AMS_Utility_PVT.Create_Log (
      x_return_status   => x_return_status,
      p_arc_log_used_by => G_ARC_IMPORT_HEADER,
      p_log_used_by_id  => p_log_used_by_id,
      p_msg_data        => p_msg_data,
      p_msg_type        => p_msg_type
   );
EXCEPTION WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END;


-- NAME
--     Insert_Data
--
-- PURPOSE
--     The procedure insert a collection of data into a table whose name is
--     specified by the "p_table_name" field. It uses native dynamic SQL to
--     bulk insert records using binding tables.
--
--     The "p_col_names" field contains a collection of the column names.
--     The "p_data" contains all data needed to be inserted, assuming all data
--     types are "VARCHAR2". For example, if the data to be inserted are the
--     followings:
--
--     Row Number   1        2        3        4
--     Column1      Frank    Smith    Scott    Marry
--     Column2      Amos     Anderson Baber    Beier
--     Column3      75039    77002    23060    03062
--
--     The data is stored in the "p_data" as: "Frank", "Smith", "Scott", "Marry",
--     "Amos", "Anderson", "Baber", "Beier", "75039", "77002", "23060", "03062".
--     Both "p_col_names" and "p_data" are consecutive.
--     The data stored in the "p_prim_key_name" field is the column name of the
--     primary key column. The "p_seq_name" is the name of sequence used to
--     generate the primary keys for all the rows. For example, it must be
--     "AMS.AMS_IMP_SOURCE_LINES_S" instead of "AMS_IMP_SOURCE_LINES_S".
--      The "p_str_col_names" and
--     the "p_num_col_names" contain other "VARCHAR2" field and "NUMBER" field
--     names respectively, while the "p_str_data" and "p_num_data" are
--     corresponding data. The other flag fields are used to indicate whether
--     we need these fields or not. The "p_row_count" field is redundant since
--     we do not want to invoke the "COUNT" on "p_data" since this table is
--     supposed to be huge.
--
-- NOTES
--
-- HISTORY
-- 04/12/2001   huili      Created.
-- 05/13/2001   huili      Modified to handle different owners for sequence
--
PROCEDURE Insert_Data (

	p_api_version                 IN    NUMBER,
	p_init_msg_list               IN    VARCHAR2 := FND_API.G_TRUE,
	p_commit                      IN    VARCHAR2 := FND_API.G_FALSE,

	p_table_name                  IN    VARCHAR2,
	p_prim_key_name               IN    VARCHAR2,
	p_seq_name                    IN    VARCHAR2,

	p_str_col_names               IN    char_data_set_type_w,
	p_num_col_names               IN    char_data_set_type_w,
	p_str_data                    IN    char_data_set_type_w,
	p_num_data                    IN    num_data_set_type_w,
	p_obj_version_num             IN    NUMBER := NULL,  -- if NULL, do not insert this column
	p_last_update_date_flag       IN    VARCHAR2 := FND_API.G_TRUE,-- need this column?
	p_last_update_by_flag         IN    VARCHAR2 := FND_API.G_TRUE,-- need this column?
	p_creation_date_flag          IN    VARCHAR2 := FND_API.G_TRUE,-- need this column?
	p_created_by_flag             IN    VARCHAR2 := FND_API.G_TRUE,-- need this column?
	p_ls_update_log_flag          IN    VARCHAR2 := FND_API.G_TRUE,-- need this column?

	p_col_names                   IN    char_data_set_type_w,
	p_data                        IN    char_data_set_type_w,
	p_error_rows                  IN    num_data_set_type_w,
	p_row_count                   IN    NUMBER,

	x_return_status               OUT NOCOPY   VARCHAR2,
	x_msg_count                   OUT NOCOPY   NUMBER,
	x_msg_data                    OUT NOCOPY   VARCHAR2
)
IS

	--
	-- Standard API information constants.
	--
	L_API_VERSION       CONSTANT NUMBER := 1.0;
	L_API_NAME          CONSTANT VARCHAR2(30) := 'Insert_Data';
	L_FULL_NAME         CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;

	L_PLACE_HOLDER_UNIT CONSTANT NUMBER := 8;

	L_ACTIVE CONSTANT VARCHAR2(30) := 'ACTIVE';
	L_ERROR  CONSTANT VARCHAR2(30) := 'ERROR';

	l_value_clause_unit  VARCHAR2(8000) := '';
	l_num_value_units   NUMBER := 0;
	TYPE char_table IS TABLE OF VARCHAR2(8000);
	place_holder char_table := char_table('');

	l_data_seq NUMBER := 1;

	l_tab_name_clause1     VARCHAR2(8000) := 'INSERT INTO ';
	l_col_clause1        VARCHAR2(8000) := ' (';
	l_col_clause2        VARCHAR2(8000) := '';
	l_col_clause3        VARCHAR2(8000) := '';

	l_value_clause      VARCHAR2(8000) := ' VALUES (';
	--l_value_clause1      VARCHAR2(8000) := ',';

	--l_value_data     VARCHAR2(8000) := '';

	l_date              DATE;
	l_col_count         NUMBER;
	l_orig_col_count    NUMBER;
	l_start_index       NUMBER := 1;
	l_act_col_count     NUMBER; --actual col count for each initialization

	l_start_seq_num     NUMBER;

	l_user_id           NUMBER;
	l_login_id          NUMBER;

	l_seq_owner         VARCHAR2 (30);
	l_seq_name          VARCHAR2 (2000);
	l_dot_pos           NUMBER;
	l_index             NUMBER := 1;
	l_one_item         VARCHAR2(2000);

	l_row_seq          NUMBER := 0;
	l_source_line_keys num_data_set_type_w;

	l_load_status      VARCHAR2(30) := L_ACTIVE;

	l_list_imp_error_rec AMS_LIST_IMPORT_ERRORS%ROWTYPE;
	l_imp_err_id NUMBER;

	l_varchar_col_num NUMBER := 0;
	l_num_col_num NUMBER := 0;
	l_other_col_num NUMBER := 0;
	l_total_col_count NUMBER := 0;
	l_comma VARCHAR2(1) := '';
	g_cursor INT DEFAULT dbms_sql.open_cursor;
	l_status integer;

BEGIN

	--
	-- Initialize API return status to success.
	--
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	l_orig_col_count := p_col_names.COUNT;

	IF l_orig_col_count < 1 THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	l_date := SYSDATE;
	l_user_id := FND_GLOBAL.User_ID;
	l_login_id := FND_GLOBAL.Conc_Login_ID;

	l_tab_name_clause1 := l_tab_name_clause1 || p_table_name;

	l_dot_pos := INSTR (p_seq_name, '.');
	IF l_dot_pos > 0 THEN
		l_seq_name := SUBSTR(p_seq_name, l_dot_pos + 1);
	ELSE
		l_seq_name := p_seq_name;
	END IF;

	l_seq_name := UPPER (l_seq_name);

	SELECT SEQUENCE_OWNER INTO l_seq_owner
	FROM sys.ALL_SEQUENCES WHERE SEQUENCE_NAME = l_seq_name;

	IF l_seq_owner IS NOT NULL
		AND LENGTH(l_seq_owner) > 0 THEN
		l_seq_name := l_seq_owner || '.' || l_seq_name;
	END IF;

	--
	-- Generate the primary key table
	--
	FOR seq_index IN 1 .. p_row_count
	LOOP
		EXECUTE IMMEDIATE
      'SELECT ' || l_seq_name || '.NEXTVAL FROM DUAL' INTO l_start_seq_num;
      l_source_line_keys(seq_index) := l_start_seq_num;
	END LOOP;

	l_col_clause1 := l_col_clause1 || p_prim_key_name || ',';
	l_col_clause1 := l_col_clause1
				  || 'LAST_UPDATE_DATE,LAST_UPDATED_BY,CREATION_DATE,CREATED_BY,LAST_UPDATE_LOGIN,';

	FOR i IN p_str_col_names.FIRST .. p_str_col_names.LAST
	LOOP
		l_col_clause1 := l_col_clause1 || p_str_col_names(i) || ',';
	END LOOP;

	FOR i IN p_num_col_names.FIRST .. p_num_col_names.LAST
	LOOP
		l_col_clause1 := l_col_clause1 || p_num_col_names(i) || ',';
	END LOOP;

	l_comma := '';
	WHILE l_index <= l_orig_col_count
    LOOP
		l_col_clause1 := l_col_clause1 || l_comma || p_col_names(l_index);
		l_index := l_index + 1;
		l_other_col_num := l_other_col_num + 1;
		l_comma := ',';
    END LOOP;

	l_other_col_num := l_other_col_num + 1;
	l_col_clause1 := l_col_clause1 || ',' || 'LOAD_STATUS) ';

	l_varchar_col_num := p_str_col_names.COUNT;
	l_num_col_num := p_num_col_names.COUNT;

	l_comma := '';
	FOR i IN 1 .. 6
	LOOP
		l_value_clause := l_value_clause || l_comma || ':r' || i ;
		l_comma := ',';
	END LOOP;

	FOR i IN 1 .. l_varchar_col_num
	LOOP
		l_value_clause := l_value_clause || l_comma || ':v' || i ;
		l_comma := ',';
	END LOOP;

	FOR i IN 1 .. l_num_col_num
	LOOP
		l_value_clause := l_value_clause || l_comma || ':n' || i ;
		l_comma := ',';
	END LOOP;

	FOR i IN 1 .. l_other_col_num
	LOOP
		l_value_clause := l_value_clause || l_comma || ':o' || i ;
		l_comma := ',';
	END LOOP;

	l_value_clause := l_value_clause || ')';

	dbms_sql.parse (g_cursor, l_tab_name_clause1 || l_col_clause1
				   || l_value_clause, dbms_sql.native);

	FOR i IN 1 .. p_row_count

	LOOP
	BEGIN
		--IF  p_error_rows(i) = G_ROW_PARSE_NO_ERROR THEN
		l_load_status := L_ACTIVE;
		--ELSE
		--	l_load_status := L_ERROR;
		--END IF;

		--dbms_sql.parse (g_cursor, l_tab_name_clause1 || l_col_clause1
		--			   || l_value_clause, dbms_sql.native);

		--primary_key
		dbms_sql.bind_variable (g_cursor, ':r1', l_source_line_keys(i));
		--LAST_UPDATE_DATE
		dbms_sql.bind_variable (g_cursor, ':r2', l_date);
		--LAST_UPDATED_BY
		dbms_sql.bind_variable (g_cursor, ':r3', l_user_id);
		--CREATION_DATE
		dbms_sql.bind_variable (g_cursor, ':r4', l_date);
		--CREATED_BY
		dbms_sql.bind_variable (g_cursor, ':r5', l_user_id);
		--LAST_UPDATE_LOGIN
		dbms_sql.bind_variable (g_cursor, ':r6', l_login_id);

		--string data
		FOR j IN 1 .. l_varchar_col_num
		LOOP
			dbms_sql.bind_variable (g_cursor, ':v' || j, p_str_data(j));
		END LOOP;

		--num data
		FOR k IN 1 .. l_num_col_num
		LOOP
			dbms_sql.bind_variable (g_cursor, ':n' || k, p_num_data(k));
		END LOOP;

		--other data
		FOR l IN 1 .. l_other_col_num -1
		LOOP
			dbms_sql.bind_variable (g_cursor, ':o' || l,
								   RTRIM(LTRIM(p_data (i + (l - 1) * p_row_count))));
		END LOOP;

		--status_code
		dbms_sql.bind_variable (g_cursor, ':o' || l_other_col_num,
								   l_load_status);

		l_status := dbms_sql.EXECUTE(g_cursor);

		EXCEPTION
			WHEN OTHERS THEN
				dbms_sql.close_cursor (g_cursor);
				x_msg_data := 'Error at row ' || i || ' '  || SQLERRM;
				x_msg_data := x_msg_data || ' If you mapped the "party_id" , it should be a number.';
				RAISE FND_API.G_EXC_ERROR;
	END;
	END LOOP;
	dbms_sql.close_cursor (g_cursor);


	--FOR j IN p_error_rows.FIRST .. p_error_rows.LAST
	--LOOP

	--	IF p_error_rows(j) <> G_ROW_PARSE_NO_ERROR THEN

	--		l_list_imp_error_rec.IMPORT_LIST_HEADER_ID := p_num_data(1);
	--		l_list_imp_error_rec.IMPORT_SOURCE_LINE_ID := l_source_line_keys(j);
	--		l_list_imp_error_rec.IMPORT_TYPE := 'LEAD';

	--		IF p_error_rows(j) = G_ROW_PARSE_TOO_LARGE THEN
	--			l_list_imp_error_rec.COL1 := G_ROW_PARSE_TOO_LARGE_MSG;
	--		ELSE
	--			l_list_imp_error_rec.COL1 := G_ROW_PARSE_OTHER_MSG;
	--		END IF;

	--		l_list_imp_error_rec.ERROR_TYPE := 'E';
	--		Create_List_import_Error (
	--			p_api_version => 1.0,
	--			x_return_status => x_return_status,
	--			p_list_imp_error_rec => l_list_imp_error_rec,
	--			x_imp_err_id => l_imp_err_id);
	--
	--	END IF;
	--
   --END LOOP;

	--
	-- Standard check for commit request.
	--
	IF FND_API.To_Boolean (p_commit) THEN
		COMMIT WORK;
	END IF;

	--
	-- Standard API to get message count, and if 1,
	-- set the message data OUT variable.
	--
	FND_MSG_PUB.Count_And_Get (
		p_count           =>    x_msg_count,
		p_data            =>    x_msg_data,
		p_encoded         =>    FND_API.G_FALSE
	);

	EXCEPTION
		WHEN FND_API.G_EXC_ERROR THEN
			x_return_status := FND_API.G_RET_STS_ERROR;
			--x_msg_data := 'Error happens AT ROW ' || l_row_seq
         --         || '. The error message IS '  || SQLERRM;
		WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			x_msg_data := 'Error happens AT ROW ' || l_row_seq
                  || '. The error message IS '  || SQLERRM;

		WHEN OTHERS THEN
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
			x_msg_data := 'Unexpected error ' || SQLERRM;
END Insert_Data;


-- NAME
--     Append_More_Data
--
-- PURPOSE
-- NOTES
--
-- HISTORY
-- 04/12/2001   huili      Created.
--
PROCEDURE Append_More_Data (
  p_str_col_names                IN      char_data_set_type_w,
  p_str_data                     IN      char_data_set_type_w,
  p_num_col_names                IN      char_data_set_type_w,
  p_num_data                     IN      num_data_set_type_w,
  p_col_clause                   IN OUT NOCOPY  VARCHAR2,
  p_val_clause                   IN OUT NOCOPY  VARCHAR2
)
IS
BEGIN
  IF p_str_col_names.COUNT > 0 THEN
    FOR i IN p_str_col_names.FIRST .. p_str_col_names.LAST
    LOOP
      p_col_clause := p_col_clause || p_str_col_names(i) || ', ';
      p_val_clause := p_val_clause || '''' || p_str_data(i) || ''', ';
    END LOOP;
  END IF;

  IF p_num_col_names.COUNT > 0 THEN
    FOR j IN p_num_col_names.FIRST .. p_num_col_names.LAST
    LOOP
      p_col_clause := p_col_clause || p_num_col_names(j) || ', ';
      p_val_clause := p_val_clause || '''' || p_num_data(j) || ''', ';
    END LOOP;
  END IF;
END Append_More_Data;


-- Start of comments
-- NAME
--    Create_Metric
--
-- PURPOSE
--   Creates a metric in AMS_METRICS_ALL_B given the
--   record for the metrics.
--
-- NOTES
--
-- HISTORY
-- 05/26/1999   choang      Created.
-- 10/9/1999    ptendulk    Modified According to new Standards
-- 17-Apr-2000  tdonohoe    Added columns to support 11.5.2 release.
--
-- End of comments

PROCEDURE Create_List_import_Error (
   p_api_version                IN 	NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_TRUE,
   p_commit                     IN  VARCHAR2 := FND_API.G_TRUE,
   p_list_imp_error_rec         IN  AMS_LIST_IMPORT_ERRORS%ROWTYPE,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_imp_err_id                 OUT NOCOPY NUMBER
)
IS
   --
   -- Standard API information constants.
   --
   L_API_VERSION     CONSTANT NUMBER := 1.0;
   L_API_NAME        CONSTANT VARCHAR2(30) := 'CREATE_LIST_IMPORT_ERROR';
   L_FULL_NAME       CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| L_API_NAME;

	l_list_imp_id     NUMBER;
	l_flag            NUMBER;

	l_date            DATE := SYSDATE;

   CURSOR c_list_imp_error (l_list_imp_id IN NUMBER) IS
      SELECT 1
      FROM   AMS_LIST_IMPORT_ERRORS
      WHERE  LIST_IMPORT_ERROR_ID = l_list_imp_id;

BEGIN
   --
   -- Initialize savepoint.
   --
   SAVEPOINT Create_List_import_Error_pvt;

   IF (AMS_DEBUG_HIGH_ON) THEN



   Ams_Utility_Pvt.Debug_Message(l_full_name||': START');

   END IF;

   --
   -- Initialize message list if p_init_msg_list is set to TRUE.
   --
   IF FND_API.To_Boolean (p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
   END IF;

   --
   -- Standard check for API version compatibility.
   --
   IF NOT FND_API.Compatible_API_Call (L_API_VERSION,
                                       p_api_version,
                                       L_API_NAME,
                                       G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

	IF  p_list_imp_error_rec.import_list_header_id IS NULL
		OR p_list_imp_error_rec.import_source_line_id IS NULL THEN
		RAISE FND_API.G_EXC_ERROR;
	END IF;

   --
   -- Initialize API return status to success.
   --
   x_return_status := FND_API.G_RET_STS_SUCCESS;

	LOOP
		SELECT AMS_LIST_IMPORT_ERRORS_S.NEXTVAL INTO l_list_imp_id
		FROM DUAL;

		l_flag := NULL;

		OPEN  c_list_imp_error (l_list_imp_id);
		FETCH c_list_imp_error INTO l_flag;
		CLOSE c_list_imp_error;

		EXIT WHEN l_flag IS NULL;
   END LOOP;

	INSERT INTO AMS_LIST_IMPORT_ERRORS (
		 LIST_IMPORT_ERROR_ID,
		 LAST_UPDATED_BY,
		 LAST_UPDATE_DATE,
		 CREATION_DATE,
		 CREATED_BY,
		 LAST_UPDATE_LOGIN,
		 IMPORT_LIST_HEADER_ID,
		 IMPORT_SOURCE_LINE_ID,
		 IMPORT_TYPE,
		 COL1,
		 ERROR_TYPE,
		 SECURITY_GROUP_ID,
		 REQUEST_ID,
		 PROGRAM_APPLICATION_ID,
		 PROGRAM_ID,
		 PROGRAM_UPDATE_DATE,
		 BATCH_ID
	)
	VALUES (
		l_list_imp_id,
		FND_GLOBAL.User_ID,
		l_date,
		l_date,
		FND_GLOBAL.User_ID,
		FND_GLOBAL.Conc_Login_ID,
		p_list_imp_error_rec.IMPORT_LIST_HEADER_ID,
		p_list_imp_error_rec.IMPORT_SOURCE_LINE_ID,
		p_list_imp_error_rec.IMPORT_TYPE,
		p_list_imp_error_rec.COL1,
		p_list_imp_error_rec.ERROR_TYPE,
		p_list_imp_error_rec.SECURITY_GROUP_ID,
		p_list_imp_error_rec.REQUEST_ID,
		p_list_imp_error_rec.PROGRAM_APPLICATION_ID,
		p_list_imp_error_rec.PROGRAM_ID,
		p_list_imp_error_rec.PROGRAM_UPDATE_DATE,
		p_list_imp_error_rec.BATCH_ID
	);

	x_imp_err_id := l_list_imp_id;

   --
   -- Standard check for commit request.
   --
   IF FND_API.To_Boolean (p_commit) THEN
      COMMIT WORK;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_List_import_Error_pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_List_import_Error_pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   WHEN OTHERS THEN
      ROLLBACK TO Create_List_import_Error_pvt;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Create_List_import_Error;

END AMS_ImportClient_PVT;

/
