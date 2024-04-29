--------------------------------------------------------
--  DDL for Package GR_PROCESS_DOCUMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_PROCESS_DOCUMENTS" AUTHID CURRENT_USER AS
/*$Header: GRPDOCUS.pls 115.67 2003/08/20 20:43:54 methomas ship $*/

/*		Global definitions used when defining the print sequence for
**		ingredient, toxic and exposure information.
*/
   TYPE g_toxic_line IS TABLE OF VARCHAR2(5)
      INDEX BY BINARY_INTEGER;

   TYPE g_ingred_line IS TABLE OF VARCHAR2(5)
      INDEX BY BINARY_INTEGER;

   TYPE g_exposure_line IS TABLE OF VARCHAR2(5)
      INDEX BY BINARY_INTEGER;

   TYPE g_ingred_size IS TABLE OF NUMBER(5)
      INDEX BY BINARY_INTEGER;


T_INGRED_LINE			GR_PROCESS_DOCUMENTS.G_Ingred_Line;
T_TOXIC_LINE			GR_PROCESS_DOCUMENTS.G_Toxic_Line;
T_EXPOSURE_LINE			GR_PROCESS_DOCUMENTS.G_Exposure_Line;
T_INGRED_SIZE			GR_PROCESS_DOCUMENTS.G_ingred_size;

/*
**		PL/SQL table defined for global use with the package procedures
**		to record the print ingredient section data to consolidate based
**          on the item group.
*/

TYPE print_ingredient IS RECORD
	  (item_group_code	gr_item_general.item_group_code%TYPE,
	   line_text		VARCHAR2(2000),
	   concentration		NUMBER,
         print_size           NUMBER);

TYPE t_print_ingredient IS TABLE OF print_ingredient
      INDEX BY BINARY_INTEGER;

/*
**	Datastructures
*/
L_PRINT_INGREDIENT        GR_PROCESS_DOCUMENTS.t_print_ingredient;
L_TEMP_INGREDIENT         GR_PROCESS_DOCUMENTS.t_print_ingredient;

/*
**		Global alpha variable definitions
*/
G_PKG_NAME					   CONSTANT VARCHAR2(255) := 'GR_PROCESS_DOCUMENTS';

G_DOCUMENT_CODE				GR_DOCUMENT_CODES.document_code%TYPE;
G_DISCLOSURE_CODE			GR_DISCLOSURES.disclosure_code%TYPE;
G_ING_DISCLOSURE			   GR_DISCLOSURES.disclosure_code%TYPE;

G_START_ITEM				   GR_ITEM_GENERAL.item_code%TYPE;
G_END_ITEM					   GR_ITEM_GENERAL.item_code%TYPE;

G_CURRENT_PHRASE			   GR_PHRASES_B.phrase_code%TYPE;
G_CURRENT_ITEM			   GR_ITEM_GENERAL.item_code%TYPE;
G_ML_ITEM			         GR_ITEM_GENERAL.item_code%TYPE;
G_CURRENT_LABEL				GR_LABELS_B.label_code%TYPE;
G_OPM_VERSION				   FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE;
G_MAIN_HEADING				GR_MAIN_HEADINGS_B.main_heading_code%TYPE;
G_SUB_HEADING				   GR_SUB_HEADINGS_B.sub_heading_code%TYPE;
G_LABEL_CODE				   GR_LABELS_B.label_code%TYPE;
G_LANGUAGE_CODE				FND_LANGUAGES.language_code%TYPE;
G_RECIP_PRINTED				VARCHAR2(2) := 'NO';
G_VENDOR_PRINTED			   VARCHAR2(2) := 'NO';
G_GENERIC_STATUS          VARCHAR2(7) := 'UNKNOWN';
G_GENERIC_ITEM            GR_ITEM_GENERAL.item_code%TYPE;
G_ITEMS_TO_PRINT          VARCHAR2(1);
G_MASTER_ITEM             GR_ITEM_GENERAL.item_code%TYPE;
G_DOCUMENT_ITEM           GR_ITEM_GENERAL.item_code%TYPE;
G_START_GENERIC           GR_ITEM_GENERAL.item_code%TYPE;
G_END_GENERIC             GR_ITEM_GENERAL.item_code%TYPE;

G_CURRENT_DATE				DATE := sysdate;
G_SUPERCEDE_DATE				DATE := sysdate;


/* 06-May-2002 M. Grosser BUG 9999999 - Added for XML/HTML Implementation */
G_OUTPUT_TYPE             VARCHAR2(8) := 'PDF';
/* 06-Dec-2002 M. Thomas BUG 2349126 - Added to check if the Process Documents Procedures are called from Process Orders */
G_CALLED_FROM             NUMBER := 0;
G_ORDERS_FLAG             VARCHAR2(2) := 'N';

/*  27-Jan-2003   Mercy Thomas  BUG 2685842 - Added the following Global Variable to check for the rebuild indicator flag forthe Linked inventory Item */
G_DOC_REBUILD_FLAG        VARCHAR2(2) := 'N';
/*  27-Jan-2003   Mercy Thomas  BUG 2685842 - End of the Changes */

/*  17-Jun-2003   Mercy Thomas  BUG 2932007 - Added the following Global Variable to populate the Formula and Recipe information */
G_FORMULA_NO              VARCHAR2(32);
G_FORMULA_VERS            NUMBER;
G_RECIPE_NO               VARCHAR2(32);
G_RECIPE_VERS             NUMBER;
G_DOC_INV_REBUILD_FLAG    VARCHAR2(2) := 'N';
/*  17-Jun-2003   Mercy Thomas  BUG 2932007 - End of the Changes */

/*  07-Jun-2001   Melanie Grosser  BUG 1772096 - Modified code to print column headings for Ingredient,
                                                 Exposure and Toxic sections. Added new procedure
                                                 GET_COLUMN_HEADINGS.
*/
/*
**      Global Column Headings
*/
G_INGCASNUM_HDG      GR_SUB_HEADINGS_TL.sub_heading_desc%TYPE;
G_INGMSDS_HDG        GR_SUB_HEADINGS_TL.sub_heading_desc%TYPE;
G_INGCONC_HDG        GR_SUB_HEADINGS_TL.sub_heading_desc%TYPE;
G_INGUSER_HDG        GR_SUB_HEADINGS_TL.sub_heading_desc%TYPE;
G_INGEEC_HDG         GR_SUB_HEADINGS_TL.sub_heading_desc%TYPE;
G_INGHAZARD_HDG      GR_SUB_HEADINGS_TL.sub_heading_desc%TYPE;
G_INGNFPA_HDG        GR_SUB_HEADINGS_TL.sub_heading_desc%TYPE;
G_INGHMIS_HDG        GR_SUB_HEADINGS_TL.sub_heading_desc%TYPE;
G_INGRISK_HDG        GR_SUB_HEADINGS_TL.sub_heading_desc%TYPE;
G_INGSAFETY_HDG      GR_SUB_HEADINGS_TL.sub_heading_desc%TYPE;
G_EXPCASNUM_HDG      GR_SUB_HEADINGS_TL.sub_heading_desc%TYPE;
G_EXPMSDS_HDG        GR_SUB_HEADINGS_TL.sub_heading_desc%TYPE;
G_EXPAUTH_HDG        GR_SUB_HEADINGS_TL.sub_heading_desc%TYPE;
G_EXPTYPE_HDG        GR_SUB_HEADINGS_TL.sub_heading_desc%TYPE;
G_EXPDOSE_HDG        GR_SUB_HEADINGS_TL.sub_heading_desc%TYPE;
G_EXPNOTE_HDG        GR_SUB_HEADINGS_TL.sub_heading_desc%TYPE;
G_TOXCASNUM_HDG      GR_SUB_HEADINGS_TL.sub_heading_desc%TYPE;
G_TOXMSDS_HDG        GR_SUB_HEADINGS_TL.sub_heading_desc%TYPE;
G_TOXSPECIES_HDG     GR_SUB_HEADINGS_TL.sub_heading_desc%TYPE;
G_TOXEXPOSE_HDG      GR_SUB_HEADINGS_TL.sub_heading_desc%TYPE;
G_TOXROUTE_HDG       GR_SUB_HEADINGS_TL.sub_heading_desc%TYPE;
G_TOXDOSE_HDG        GR_SUB_HEADINGS_TL.sub_heading_desc%TYPE;
G_TOXNOTE_HDG        GR_SUB_HEADINGS_TL.sub_heading_desc%TYPE;
G_PRINT_COL_HDG      VARCHAR2(1);

/*
**		Global numeric variable definitions
*/
G_RECORD_COUNT				NUMBER;
G_LINE_NUMBER				NUMBER;
G_SESSION_ID				NUMBER;
G_MAXIMUM_RECORDS			NUMBER;
G_DOCUMENT_TEXT_ID			NUMBER;
G_USER_ID				NUMBER;
G_ITEM_PRINT_COUNT			NUMBER(5)	DEFAULT 0;
G_LOW_PRECISION			NUMBER;
G_HIGH_PRECISION			NUMBER;
G_ROW					NUMBER(5) DEFAULT 0;

/*
**		Concurrent request return values
*/
G_PRINT_STATUS				BOOLEAN;
G_CONCURRENT_ID				NUMBER;


/*
**		Constant Declarations
*/
  GR_HIGH_ROLLUP		CONSTANT INTEGER := 1;
  GR_LOW_ROLLUP		CONSTANT INTEGER := 2;
  GR_AVERAGE_ROLLUP	CONSTANT INTEGER := 3;
  GR_SUM_ROLLUP		CONSTANT INTEGER := 4;
  GR_COUNT_ROLLUP		CONSTANT INTEGER := 5;
  GR_COUNTRY_ROLLUP	CONSTANT INTEGER := 6;
/*
** M Thomas 05-Feb-2002 Bug 1323951 Added the new rollup types
*/
  GR_LC50_IHL_ROLLUP    CONSTANT INTEGER := 7;
  GR_LD50_ORAL_ROLLUP   CONSTANT INTEGER := 8;
  GR_LD50_SKIN_ROLLUP   CONSTANT INTEGER := 9;

/*
** M Thomas 05-Feb-2002 Bug 1323951 End of the changes
*/


/*
**		Global cursor definitions
**
**		Document Codes
*/
CURSOR g_get_document_code
IS
   SELECT	dc.document_code,
			dc.document_description,
            dc.document_date_format,
			dc.print_ingredients_flag,
			dc.ingredient_header_label,
			dc.ingredient_conc_ind,
			dc.print_toxic_info_flag,
			dc.toxic_header_label,
			dc.print_exposure_flag,
			dc.exposure_header_label,
			dc.prop_65_conc_ind,
			dc.sara_312_conc_ind,
			dc.print_rtk_on_document,
			dc.rtk_header,
			dc.print_all_state_indicator
   FROM		gr_document_codes dc
   WHERE	dc.document_code = g_document_code;
GlobalDocumentMaster		g_get_document_code%ROWTYPE;
/*
**		Disclosure Codes
*/
CURSOR g_get_disclosure_code
 IS
   SELECT	di.disclosure_code
   FROM		gr_disclosures di
   WHERE	di.disclosure_code = g_disclosure_code;
GlobalDisclosureRecord		g_get_disclosure_code%ROWTYPE;
/*
**		Language Codes
*/
CURSOR g_get_language_code
 IS
   SELECT	lng.language_code
   FROM		fnd_languages lng
   WHERE	lng.language_code = g_language_code;
GlobalLanguageRecord		g_get_language_code%ROWTYPE;
/*
**		Count the number of item explosion records
*/
CURSOR g_get_explosion_count
 IS
   SELECT	COUNT(*) count
   FROM		gr_item_concentrations ic
   WHERE	ic.item_code = g_current_item;
/*
**		Get the document work structure
*/
CURSOR g_get_work_structure
 IS
   SELECT	wbd.main_heading_code,
            wbd.sub_heading_code,
			wbd.record_type,
			wbd.label_or_phrase_code,
			wbd.concentration_percent,
			wbd.label_class,
			wbd.phrase_type,
			wbd.phrase_hierarchy,
			wbd.print_flag,
			wbd.source_itemcode
   FROM		gr_work_build_docs wbd
   WHERE	wbd.session_id = g_session_id
   AND		wbd.document_code = g_document_code
   ORDER BY wbd.sequence_number;
GlobalStructureRecord		g_get_work_structure%ROWTYPE;
/*
**		Get the main heading description
*/
CURSOR g_get_main_heading
 IS
   SELECT	mhb.main_heading_print_font,
    		mhb.main_heading_print_size,
			mht.main_heading_description
   FROM		gr_main_headings_tl mht,
            gr_main_headings_b mhb
   WHERE	mhb.main_heading_code = g_main_heading
   AND		mht.main_heading_code = g_main_heading
   AND 		mht.language = g_language_code;
GlobalMainHeading			g_get_main_heading%ROWTYPE;
/*
**		Get the sub heading description
*/
CURSOR g_get_sub_heading
 IS
   SELECT	shb.sub_heading_print_font,
    		shb.sub_heading_print_size,
			sht.sub_heading_desc
   FROM		gr_sub_headings_tl sht,
            gr_sub_headings_b shb
   WHERE	shb.sub_heading_code = g_sub_heading
   AND		sht.sub_heading_code = g_sub_heading
   AND 		sht.language = g_language_code;
GlobalSubHeading			g_get_sub_heading%ROWTYPE;
/*
**	Get the item codes in the selection range
*/
CURSOR g_get_item_range
 IS
   SELECT	ig1.item_code,
            ig1.primary_cas_number,
			ig1.ingredient_flag,
			ig1.formula_source_indicator,
			ig1.print_ingredient_phrases_flag,
			ig1.explode_ingredient_flag,
			ig1.product_class,
			ig1.internal_reference_number,
			ig1.version_code,
			em.european_index_number,
			em.eec_number,
			em.consolidated_risk_phrase,
			em.consolidated_safety_phrase,
			fnu.user_name,
			pc.product_class_desc
   FROM		gr_emea em,
            gr_product_classes pc,
            fnd_user fnu,
			gr_item_general ig1
   WHERE	ig1.item_code >= g_start_item
   AND		ig1.item_code <= g_end_item
   AND		ig1.user_id = fnu.user_id
   AND      ig1.product_class = pc.product_class (+)
   AND      ig1.item_code = em.item_code (+)
   ORDER BY ig1.item_code;
GlobalItemRecord		g_get_item_range%ROWTYPE;
/*
**	Item ingredient concentrations
*/
CURSOR g_get_ingredients
 IS
   SELECT	ic.ingredient_item_code,
            ic.concentration_percentage,
			ig1.print_ingredient_phrases_flag,
            ig1.item_group_code,
			em.eec_number,
			em.consolidated_risk_phrase,
			em.consolidated_safety_phrase
   FROM		gr_emea	em,
            gr_item_general ig1,
            gr_item_concentrations ic
   WHERE	ic.item_code = GlobalItemRecord.item_code
   AND      ic.ingredient_item_code = em.item_code (+)
   AND      ic.ingredient_item_code = ig1.item_code
   ORDER BY 2 desc;
GlobalIngredientRecord		g_get_ingredients%ROWTYPE;
/*
**	Item multilingual name
*/
CURSOR g_get_ml_name
 IS
   SELECT	mln.name_description
   FROM		gr_multilingual_name_tl mln
   WHERE	mln.item_code = g_ml_item
   AND		mln.language = g_language_code
   AND		mln.label_code = g_label_code;
GlobalMLName				g_get_ml_name%ROWTYPE;
/*
**	Phrase description
*/
CURSOR g_get_phrase_desc
 IS
   SELECT	pd.phrase_text,
    		pd.print_font,
			pd.print_size,
			pd.image_pathname,
			pd.image_print_location
   FROM		gr_phrases_tl pd
   WHERE	pd.phrase_code = g_current_phrase
   AND		pd.language = g_language_code;
GlobalPhraseRecord		g_get_phrase_desc%ROWTYPE;
/*
**	Get the product classes associated with a label code
*/
CURSOR g_get_label_prod_cls
 IS
   SELECT	COUNT(*)
   FROM		gr_label_prod_classes lpc
   WHERE	lpc.label_code = g_current_label
   AND		lpc.product_class = GlobalItemRecord.product_class;
/*
**	Get the label code information
*/
CURSOR g_get_label_info
 IS
   SELECT	lc.data_position_indicator,
			   lc.print_font,
			   lc.print_size,
			   lc.label_class_code,
			   lc.label_properties_flag,
			   lc.ingredient_value_flag,
			   lc.print_ingredient_indicator,
			   lc.ingredient_label_code,
 			   ld.label_description,
                     cl.rollup_type,
                     cl.rollup_label,
                     cl.rollup_property
   FROM		gr_labels_tl ld,
			   gr_labels_b	lc, gr_label_classes_b cl
   WHERE	lc.label_code = g_label_code
   AND		ld.label_code = lc.label_code
   AND		ld.language = g_language_code
   AND            cl.label_class_code = lc.label_class_code;
GlobalLabelRecord		g_get_label_info%ROWTYPE;

/*
**	Get the precision for the property value
*/
CURSOR g_get_property_precision (V_property VARCHAR2)
IS
  SELECT precision
  FROM   gr_properties_b
  WHERE  property_id = V_property;
GlobalPropertyRecord	g_get_property_precision%ROWTYPE;

/*
**  Get the item disclosure information
*/
CURSOR g_get_ing_disclosure
 IS
   SELECT   id.print_on_document_flag,
            id.minimum_reporting_level,
            id.exposure_reporting_level,
            id.toxicity_reporting_level
   FROM     gr_item_disclosures id
   WHERE    id.item_code = GlobalIngredientRecord.ingredient_item_code
   AND      id.disclosure_code = g_ing_disclosure;
GlobalDiscRecord    g_get_ing_disclosure%ROWTYPE;
/*
**   Get the inventory items for a specified master item
*/
CURSOR g_get_master_list
 IS
   SELECT   gib.ROWID,
	          gib.item_code,
	          gib.item_no,
	          gib.default_document_name_flag,
				 gib.document_rebuild_indicator,
				 gib.attribute_category,
				 gib.attribute1,
				 gib.attribute2,
				 gib.attribute3,
				 gib.attribute4,
				 gib.attribute5,
				 gib.attribute6,
				 gib.attribute7,
				 gib.attribute8,
				 gib.attribute9,
				 gib.attribute10,
				 gib.attribute11,
				 gib.attribute12,
				 gib.attribute13,
				 gib.attribute14,
				 gib.attribute15,
				 gib.attribute16,
				 gib.attribute17,
				 gib.attribute18,
				 gib.attribute19,
				 gib.attribute20,
				 gib.attribute21,
				 gib.attribute22,
				 gib.attribute23,
				 gib.attribute24,
				 gib.attribute25,
				 gib.attribute26,
				 gib.attribute27,
				 gib.attribute28,
				 gib.attribute29,
				 gib.attribute30,
				 gib.created_by,
				 gib.creation_date,
				 gib.last_updated_by,
				 gib.last_update_date,
				 gib.last_update_login,
				 ids.rebuild_item_doc_flag
	 FROM     gr_generic_items_b gib,
	          gr_item_doc_statuses ids
	 WHERE    gib.item_code = g_master_item
	 AND      ids.item_code = g_master_item
	 AND      ids.document_code = g_document_code
         ORDER BY gib.item_no;
/* MGROSSER */
/*
**   Get the master item for a specified inventory item
*/
CURSOR g_get_invent_items
 IS
   SELECT   gib.ROWID,
	          gib.item_code,
	          gib.item_no,
				 gib.default_document_name_flag,
				 gib.document_rebuild_indicator,
			    gib.attribute_category,
				 gib.attribute1,
				 gib.attribute2,
				 gib.attribute3,
				 gib.attribute4,
				 gib.attribute5,
				 gib.attribute6,
				 gib.attribute7,
				 gib.attribute8,
				 gib.attribute9,
				 gib.attribute10,
				 gib.attribute11,
				 gib.attribute12,
				 gib.attribute13,
				 gib.attribute14,
				 gib.attribute15,
				 gib.attribute16,
				 gib.attribute17,
				 gib.attribute18,
				 gib.attribute19,
				 gib.attribute20,
				 gib.attribute21,
				 gib.attribute22,
				 gib.attribute23,
				 gib.attribute24,
				 gib.attribute25,
				 gib.attribute26,
				 gib.attribute27,
				 gib.attribute28,
				 gib.attribute29,
				 gib.attribute30,
				 gib.created_by,
				 gib.creation_date,
				 gib.last_updated_by,
				 gib.last_update_date,
				 gib.last_update_login,
				 ids.rebuild_item_doc_flag
	 FROM     gr_generic_items_b gib,
	          gr_item_doc_statuses ids
	 WHERE    gib.item_no >= g_start_generic
	 AND      gib.item_no <= g_end_generic
	 AND      ids.item_code = gib.item_code
	 AND      ids.document_code = g_document_code;
GlobalInventList    g_get_invent_items%ROWTYPE;
/*
**	Get the toxic and exposure uom descriptions
*/
CURSOR g_get_uom_desc (V_code VARCHAR2) IS
  SELECT DECODE (V_code, '%', 'GR_PERCENT',
  		         'P', 'GR_PPM',
			 'B', 'GR_PPB',
			 'T', 'GR_PPT',
 			 'M', 'GR_MG_M3',
			 'D', 'GR_MP_F3',
			 'N', 'GR_NG_M3',
			 'I', 'GR_PG_M3',
			 'K', 'GR_MG_KG',
			 'L', 'GR_MG_L',
			 'X', 'GR_NOT_ESTABLISHED',
			 'O', 'GR_OTHER')
  FROM dual;

   PROCEDURE Build_Document_Details
   				(p_commit IN VARCHAR2,
				 p_init_msg_list IN VARCHAR2,
				 p_validation_level IN NUMBER,
				 p_api_version IN NUMBER,
				 p_item_code IN VARCHAR2,
				 p_document_code IN VARCHAR2,
				 p_session_id IN NUMBER,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2);
   PROCEDURE Resolve_Phrase_Conflicts
				(p_commit IN VARCHAR2,
				 p_init_msg_list IN VARCHAR2,
				 p_validation_level IN NUMBER,
				 p_api_version IN NUMBER,
				 p_session_id IN NUMBER,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2);
   PROCEDURE Build_Item_Document
				(p_commit IN VARCHAR2,
				 p_init_msg_list IN VARCHAR2,
				 p_validation_level IN NUMBER,
				 p_api_version IN NUMBER,
				 p_build_item IN VARCHAR2,
				 p_document_code IN VARCHAR2,
				 p_disclosure_code IN VARCHAR2,
				 p_language_code IN VARCHAR2,
				 p_session_id IN NUMBER,
				 x_document_text_id OUT NOCOPY NUMBER,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2);

   PROCEDURE Print_Document
				(errbuf OUT NOCOPY VARCHAR2,
				 retcode OUT NOCOPY VARCHAR2,
				 p_commit IN VARCHAR2,
				 p_init_msg_list IN VARCHAR2,
				 p_validation_level IN NUMBER,
				 p_api_version IN NUMBER,
				 p_start_item IN VARCHAR2,
				 p_end_item IN VARCHAR2,
				 p_document_code IN VARCHAR2,
				 p_disclosure_code IN VARCHAR2,
				 p_language_code IN VARCHAR2,
				 p_session_id IN NUMBER,
				 p_printer IN VARCHAR2,
				 p_user_print_style IN VARCHAR2,
				 p_number_of_copies IN NUMBER,
				 p_items_to_print IN VARCHAR2,
				 p_return_status OUT NOCOPY VARCHAR2,
				 p_msg_count OUT NOCOPY NUMBER,
				 p_msg_data OUT NOCOPY VARCHAR2
-- /* 09-Jan-2003   Mercy Thomas	   B2741212 -  Commented out for SICO
                                 ,p_output_type IN VARCHAR2
--    09-Jan-2003   Mercy Thomas	   B2741212 -  Commented out for SICO */
                                 );

   PROCEDURE Print_Worksheet
				(errbuf OUT NOCOPY VARCHAR2,
				 retcode OUT NOCOPY VARCHAR2,
				 p_commit IN VARCHAR2,
				 p_init_msg_list IN VARCHAR2,
				 p_validation_level IN NUMBER,
				 p_api_version IN NUMBER,
				 p_start_item IN VARCHAR2,
				 p_end_item IN VARCHAR2,
				 p_document_code IN VARCHAR2,
				 p_disclosure_code IN VARCHAR2,
				 p_language_code IN VARCHAR2,
				 p_session_id IN NUMBER,
				 p_printer IN VARCHAR2,
				 p_user_print_style IN VARCHAR2,
				 p_number_of_copies IN NUMBER,
				 p_items_to_print IN VARCHAR2,
				 p_return_status OUT NOCOPY VARCHAR2,
				 p_msg_count OUT NOCOPY NUMBER,
				 p_msg_data OUT NOCOPY VARCHAR2
-- /* 09-Jan-2003   Mercy Thomas	   B2741212 -  Commented out for SICO
                                 ,p_output_type IN VARCHAR2
--    09-Jan-2003   Mercy Thomas	   B2741212 -  Commented out for SICO */
                                );

   PROCEDURE Process_Document_Structure
				(p_commit IN VARCHAR2,
				 p_session_id IN NUMBER,
				 p_source_action IN VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2);
	PROCEDURE Get_Phrase_Type
				(p_phrase_code IN VARCHAR2,
				 p_conc_value IN NUMBER,
				 x_phrase_type OUT NOCOPY VARCHAR2,
			 	 x_hierarchy OUT NOCOPY NUMBER);
	PROCEDURE Third_Phrase_Insert_Row
		 		(p_session_id IN NUMBER,
		 	         p_sequence_number IN NUMBER,
				 p_source_itemcode IN VARCHAR2,
				 p_document_code IN VARCHAR2,
				 p_main_heading_code IN VARCHAR2,
				 p_main_display_order IN NUMBER,
				 p_sub_heading_code IN VARCHAR2,
				 p_sub_display_order IN NUMBER,
				 p_structure_display_order IN NUMBER,
				 p_third_phrase IN VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2);
    PROCEDURE Sort_Line_Data
				(p_document_code IN VARCHAR2,
				 x_ingred_line IN OUT NOCOPY g_ingred_line,
				 x_toxic_line IN OUT NOCOPY g_toxic_line,
				 x_exposure_line IN OUT	NOCOPY g_exposure_line,
				 x_msg_data OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER,
				 x_return_status OUT NOCOPY VARCHAR2);
   PROCEDURE Print_Ingredient_Data
				(p_item_code IN VARCHAR2,
				 p_language_code IN VARCHAR2,
				 p_label_code IN VARCHAR2,
				 p_source_procedure IN VARCHAR2,
				 p_source_action IN VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2);
   PROCEDURE Insert_Worksheet_Message
				(p_message_name IN VARCHAR2,
				 p_token_name IN VARCHAR2,
				 p_token_value IN VARCHAR2,
				 p_item_code IN VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2,
				 p_token_name2 IN VARCHAR2,
				 p_token_value2 IN VARCHAR2);
   PROCEDURE Print_Toxic_Data
			    (p_item_code IN VARCHAR2,
				 p_language_code IN VARCHAR2,
				 p_label_code IN VARCHAR2,
				 p_source_action IN VARCHAR2,
                         p_consolidate IN VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2);
   PROCEDURE Print_Exposure_Data
			    (p_item_code IN VARCHAR2,
				 p_language_code IN VARCHAR2,
				 p_label_code IN VARCHAR2,
				 p_source_action IN VARCHAR2,
                         p_consolidate IN VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2);
   PROCEDURE Print_Phrase_lines
                (p_phrase_text IN VARCHAR2,
				 p_source_action IN VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2);
   PROCEDURE Print_Label_Lines
				(p_label_code IN VARCHAR2,
				 p_source_action IN VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2);
   PROCEDURE Clear_Worksheet_Session
			    (p_commit IN VARCHAR2,
			     p_session_id IN NUMBER,
			     x_return_status OUT NOCOPY VARCHAR2,
			     x_oracle_error OUT NOCOPY NUMBER,
			     x_msg_data OUT NOCOPY VARCHAR2);
   PROCEDURE Update_Phrase_Groups
				(p_commit IN VARCHAR2,
				 p_api_version IN NUMBER,
				 p_init_msg_list IN VARCHAR2,
				 p_validation_level IN NUMBER,
				 p_called_by_form IN VARCHAR2,
				 p_update_option IN VARCHAR2,
				 p_rebuild_document_flag IN VARCHAR2,
				 p_phrase_group_code IN VARCHAR2,
				 p_phrase_code IN VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2);
   FUNCTION Conflict_Action
		        (p_work_phrase IN VARCHAR2,
			     p_phrase_code IN VARCHAR2)
			RETURN VARCHAR2;
   FUNCTION Product_Toxic_Data
		        (p_item_code IN VARCHAR2)
            RETURN NUMBER;
   FUNCTION Product_Exposure_Data
		        (p_item_code IN VARCHAR2)
            RETURN NUMBER;
   FUNCTION Read_Multilingual_Name
				(p_label_code IN VARCHAR2,
				 p_language_code IN VARCHAR2)
	        RETURN VARCHAR2;
   FUNCTION Print_Concentration
				(p_concentration_ind IN VARCHAR2,
				 p_concentration IN NUMBER)
   			RETURN VARCHAR2;
   FUNCTION Get_Hazard_Info
                (p_item_code IN VARCHAR2,
		         p_hazard_code IN VARCHAR2,
		         p_source_procedure IN VARCHAR2)
            RETURN VARCHAR2;
   FUNCTION Calc_OSHA_Flam
                (p_source_action IN VARCHAR2,
					   p_item_code IN VARCHAR2)
            RETURN VARCHAR2;
   PROCEDURE Handle_Error_Messages
				(p_message_code IN VARCHAR2,
				 p_token_name IN VARCHAR2,
				 p_token_value IN VARCHAR2,
				 x_msg_count IN OUT NOCOPY NUMBER,
				 x_msg_data IN OUT NOCOPY VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2);

   FUNCTION Convert_Temperature_Values
				(p_low_val IN NUMBER,
				 p_high_val IN NUMBER,
				 p_scale IN VARCHAR2)
   RETURN VARCHAR2;

   FUNCTION Convert_To_Scale
				(p_value IN NUMBER,
				 p_from_scale IN VARCHAR2,
				 p_to_scale IN VARCHAR2,
                         p_precision IN NUMBER)
   RETURN NUMBER;

   PROCEDURE consolidate_ingredient_data (p_count IN OUT NOCOPY NUMBER);

   PROCEDURE print_array_data (p_source_action IN VARCHAR2,
                            p_source_procedure IN VARCHAR2,
				    p_row IN NUMBER,
                            p_msds_count IN NUMBER,
                            p_conc_count IN NUMBER,
                            x_return_status IN OUT NOCOPY VARCHAR2);

  FUNCTION GET_INGREDIENT_ROLLUP_VALUE (p_item_code IN VARCHAR2, p_label_code IN VARCHAR2,
                         p_property_id IN VARCHAR2, p_scale IN OUT NOCOPY VARCHAR2, x_return_status IN OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

  /* 24-Sep-2001   Melanie Grosser  BUG 1323963 - Implementation of field name masking
                                                  Added new procedure PRINT_MASKED_VALUE
  */
  PROCEDURE  print_masked_value (p_item_code IN VARCHAR2,
                                 p_label_code IN VARCHAR2,
                                 p_value IN VARCHAR2,
				 p_source_action IN VARCHAR2,
                                 p_mask OUT NOCOPY VARCHAR2,
                                 x_return_status OUT NOCOPY VARCHAR2);


  /*  22-Oct-2001   Melanie Grosser  BUG 1985685,1839807  - Print only one line worth of characters at a time
                                                          to avoid problems due to word wrapping in report.
                                                          Also added subheadings of F H R to HMIS, NFPA and
                                                          User code columns.
                                                          Added new procedure CHECK_HEADING_LENGTH.
  */
  PROCEDURE check_heading_length (p_text_line IN OUT NOCOPY VARCHAR2,
                               p_text_line2 IN OUT NOCOPY VARCHAR2,
                               p_column_length IN NUMBER,
                               p_source IN VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2);

-- Jeff Baird  05-Nov-2001   Bug #2062036 Set all languages to rebuild if
--                           one is rebuilt.

PROCEDURE invalidate_languages
          (p_document_code IN VARCHAR2,
           p_language_code IN VARCHAR2,
           p_disclosure_code IN VARCHAR2,
           p_commit IN VARCHAR2,
           p_called_by_form IN VARCHAR2,
           p_return_status OUT NOCOPY VARCHAR2);


/* 20-Jun-2002   Melanie Grosser BUG 2381697 - Modified code to allow printing of documents in XML and HTML
                                Created new procedure Submit_Print
*/
PROCEDURE Submit_Print
          (p_document_code IN VARCHAR2,
           p_language_code IN VARCHAR2,
           p_source IN VARCHAR2,
           x_return_status OUT NOCOPY VARCHAR2);

   /*  18-Feb-2003   Melanie Grosser BUG 2800429 - Patchset version of Sico Bug 2789546
                                     Added new function Get_Print_ID to retrieve a value from the new
                                     sequence GR_PRINT_ID_S
   */
   FUNCTION Get_Print_ID
      RETURN NUMBER;

  /* 26-Feb-2003   Melanie Grosser BUG 2718956 - Fixed data alignment issues
                                   Added new function Get_Field_Name_Phrase
  */
  FUNCTION Get_Field_Name_Phrase (p_phrase_code IN VARCHAR2,
                                  x_return_status OUT NOCOPY VARCHAR2) RETURN VARCHAR2;


  /* 26-Feb-2003   Melanie Grosser BUG 2718956 - Fixed data alignment issues
                                   Added new procedure Print_Field_Name_Data
  */
  PROCEDURE Print_Field_Name_Data (p_line_length IN NUMBER,
				   p_text_line_1 IN OUT NOCOPY VARCHAR2,
				   p_text_line_2 IN OUT NOCOPY VARCHAR2,
				   p_source_action IN VARCHAR2,
                                   x_return_status OUT NOCOPY VARCHAR2);
  /* 17-Jun-2003   Mercy Thomas   BUG 2932007 - Added the new Procedure Upload_Doc_File.
  */

  PROCEDURE Upload_Doc_File
                           (errbuf                 OUT NOCOPY VARCHAR2,
                            retcode                OUT NOCOPY VARCHAR2,
                            p_document_management   IN  VARCHAR2,
                            p_source_lang           IN  VARCHAR2,
                            p_category              IN  VARCHAR2,
                            p_request_id            IN  NUMBER,
                            p_output_type           IN  VARCHAR2,
                            p_attribute1            IN  VARCHAR2,
                            p_attribute2            IN  VARCHAR2,
                            p_attribute3            IN  VARCHAR2,
                            p_attribute4            IN  VARCHAR2,
                            p_attribute5            IN  VARCHAR2,
                            p_attribute6            IN  VARCHAR2,
                            p_attribute7            IN  VARCHAR2,
                            p_attribute8            IN  VARCHAR2,
                            p_attribute9            IN  VARCHAR2,
                            p_attribute10           IN  VARCHAR2,
                            p_created_by            IN  NUMBER,
                            p_creation_date         IN  DATE,
                            p_last_updated_by       IN  NUMBER,
                            p_last_update_login     IN  NUMBER,
                            p_last_update_date      IN  DATE,
                            x_return_status        OUT  NOCOPY  VARCHAR2,
                            x_msg_data             OUT  NOCOPY  VARCHAR2);

END GR_PROCESS_DOCUMENTS;

 

/
