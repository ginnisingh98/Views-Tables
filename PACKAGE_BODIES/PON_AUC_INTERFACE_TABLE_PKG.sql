--------------------------------------------------------
--  DDL for Package Body PON_AUC_INTERFACE_TABLE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_AUC_INTERFACE_TABLE_PKG" as
/* $Header: PONAITB.pls 120.13.12010000.8 2015/07/09 11:12:13 vinnaray ship $ */

PROCEDURE add_ip_descs_on_new_lines(p_batch_id               IN VARCHAR2,
                                    p_default_attr_group     IN VARCHAR2,
                                    p_ip_attr_default_option IN VARCHAR2);

PROCEDURE add_ip_descs_on_updated_lines(p_batch_id               IN VARCHAR2,
                                        p_default_attr_group     IN VARCHAR2,
                                        p_ip_attr_default_option IN VARCHAR2);

FUNCTION get_max_attr_seq_num(p_batch_id          IN NUMBER,
                              p_interface_line_id IN NUMBER) RETURN NUMBER;

FUNCTION get_attr_group_seq_num(p_batch_id          IN NUMBER,
                                p_interface_line_id IN NUMBER,
                                p_attr_group        IN VARCHAR2) RETURN NUMBER;

FUNCTION get_attr_max_disp_seq_num(p_batch_id          IN NUMBER,
                                   p_interface_line_id IN NUMBER,
                                   p_attr_group        IN VARCHAR2) RETURN NUMBER;

PROCEDURE validate_price_elements(
  p_source 			VARCHAR2,
  p_batch_id 			NUMBER,
  p_fnd_currency_precision	NUMBER,
  p_num_price_decimals		NUMBER
) AS
  l_auction_header_id	NUMBER;
  l_message_suffix	VARCHAR2(2);
BEGIN
  -- init vars
  BEGIN
    select max(pape.auction_header_id)
    into l_auction_header_id
    from pon_auc_price_elements_int pape
    where pape.batch_id = p_batch_id;

    select pon_auction_pkg.get_message_suffix(doc.internal_name)
    into l_message_suffix
    from pon_auction_headers_all pah,
	 pon_auc_doctypes doc
    where pah.auction_header_id = l_auction_header_id
      and pah.doctype_id = doc.doctype_id;
  EXCEPTION
    WHEN no_data_found THEN
      l_message_suffix := NULL;
      l_auction_header_id := NULL;
  END;

  -- Perform data population
  -- populate PRICE_ELEMENT_TYPE_ID and DESCRIPTION
  update pon_auc_price_elements_int pape
  set (pape.price_element_type_id, pape.description) = (
    select pet.price_element_type_id,
           pet.description
    from pon_price_element_types_tl pet
    where pet.name = pape.price_element_type_name
      and pet.language = userenv('LANG')
  )
  where pape.batch_id = p_batch_id
    and pape.price_element_type_name is not null;

  -- populate PRICING_BASIS
  update pon_auc_price_elements_int pape
  set pape.pricing_basis = (
    select lookup_code
    from fnd_lookups
    where lookup_type = 'PON_PRICING_BASIS'
      and meaning = pape.pricing_basis_name
  )
  where pape.batch_id = p_batch_id
    and pape.pricing_basis_name is not null;

  -- if null, default from price_element_type
  update pon_auc_price_elements_int pape
  set pape.pricing_basis = (
    select pricing_basis
    from pon_price_element_types pet
    where pet.price_element_type_id = pape.price_element_type_id
  )
  where pape.batch_id = p_batch_id
    and pape.pricing_basis_name is null;

  -------------- Validations start here ------------------------

  INSERT ALL

  -- validate that Line Price cannot be added as a price factor

  WHEN
  (
    selected_price_element_type_id = -10
  )

  THEN INTO pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )

  VALUES
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_PRICE_ELEMENTS_INT',
    fnd_message.get_string('PON', 'PON_AUC_PRICE_ELEMENT_NAME'),
    'PON_AUC_CANNOT_UPLOAD_LP_PF',
    sel_price_element_type_name
  )

  -- PRICE_ELEMENT_TYPE_ID

  WHEN
  (
    selected_price_element_type_id is null
  )
  THEN into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  VALUES
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_PRICE_ELEMENTS_INT',
    fnd_message.get_string('PON','PON_AUC_PRICE_ELEMENT_NAME'),
    'PON_AUC_PE_INVALID_VALUE',
    sel_price_element_type_name
  )

  -- PRICING_BASIS

  WHEN
  (
    selected_pricing_basis is null
  )
  THEN into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  VALUES
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_PRICE_ELEMENTS_INT',
    fnd_message.get_string('PON','PON_AUC_PRICING_BASIS'),
    'PON_AUC_BASIS_INVAID_VALUE',
    selected_pricing_basis_name
  )

  SELECT

    pape.batch_id selected_batch_id,
    pape.interface_line_id selected_interface_line_id,
    pape.price_element_type_name sel_price_element_type_name,
    pape.price_element_type_id selected_price_element_type_id,
    pape.pricing_basis selected_pricing_basis,
    pape.pricing_basis_name selected_pricing_basis_name

  FROM
    pon_auc_price_elements_int pape

  WHERE
    pape.batch_id = p_batch_id;


  INSERT ALL

  -- Consider moving isRequired checks here... [doctype reqd?]
  -- SEQUENCE_NUMBER -- should never be displayed to user

  WHEN
  (
    selected_sequence_number is null
  )
  THEN into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  VALUES
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_PRICE_ELEMENTS_INT',
    'SEQUENCE_NUMBER',
    'PON_CAT_DISP_SEQ_M',
    selected_sequence_number
  )

  -- validate precision (if PRICING_BASIS not null)
  --  use p_fnd_currency_precision = if PRICING_BASIS is FIXED_AMOUNT

  WHEN
  (
    selected_pricing_basis = 'FIXED_AMOUNT'
    and selected_precision > p_fnd_currency_precision
  )
  THEN into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  VALUES
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_PRICE_ELEMENTS_INT',
    fnd_message.get_string('PON','PON_AUC_TARGET_VALUE'),
    'PON_AUC_INVALID_PRECISION',
    selected_value
  )

  --  use p_num_price_decimals = if PRICING_BASIS is PER_UNIT

  WHEN
  (
    selected_pricing_basis = 'PER_UNIT'
    and selected_precision > p_num_price_decimals
  )
  THEN into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  VALUES
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_PRICE_ELEMENTS_INT',
    fnd_message.get_string('PON','PON_AUC_TARGET_VALUE'),
    'PON_AUC_INVALID_PRECISION_AU'||l_message_suffix,
    selected_value
  )

  -- validate value is positive (if given)

  WHEN
  (
    selected_value < 0
  )
  THEN into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  VALUES
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_PRICE_ELEMENTS_INT',
    fnd_message.get_string('PON','PON_AUC_TARGET_VALUE'),
    'PON_AUC_POSITIVE_OR_ZERO',
    selected_value
  )

  -- validate display target flag is Y/N

  WHEN
  (
    nvl(selected_display_target_flag,'N') not in ('Y','N')
  )
  THEN into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  VALUES
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_PRICE_ELEMENTS_INT',
    fnd_message.get_string('PON','PON_AUCTS_ATTR_D_TARGET'),
    'PON_AUCTS_INV_PR_QT_VAL',
    selected_display_target_flag
  )

  -- value must be given if display target flag = Y

  WHEN
  (
    selected_value is null and
    selected_display_target_flag = 'Y'
  )

  THEN into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  VALUES
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_PRICE_ELEMENTS_INT',
    fnd_message.get_string('PON','PON_AUC_TARGET_VALUE'),
    'PON_AUC_POSITIVE_OR_ZERO',
    selected_value
  )

  -- the only allowed pricing bases are FIXED_AMOUNT and PERCENTAGE
  -- if the line type of the line is fixed price

  WHEN
  (
    selected_pricing_basis <> 'FIXED_AMOUNT'
    and selected_pricing_basis <> 'PERCENTAGE'
    and sel_order_type_lookup_code = 'FIXED PRICE'
  )
  THEN into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  VALUES
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_PRICE_ELEMENTS_INT',
    fnd_message.get_string('PON','PON_AUC_PRICING_BASIS'),
    'PON_AUC_CANNOT_UPLOAD_PF_2',
    selected_pricing_basis_name
  )

  -- validate price element type is active

  WHEN
  (
    selected_enabled_flag = 'N'
  )
  THEN into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  VALUES
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_PRICE_ELEMENTS_INT',
    fnd_message.get_string('PON','PON_AUC_PRICE_ELEMENT_NAME'),
    'PON_AUC_AUCTION_INA_PES_SP',
    sel_price_element_type_name
  )

  SELECT

    pape.batch_id selected_batch_id,
    pape.interface_line_id selected_interface_line_id,
    pape.price_element_type_name sel_price_element_type_name,
    pape.value selected_value,
    pape.display_target_flag selected_display_target_flag,
    pape.precision selected_precision,
    pape.pricing_basis selected_pricing_basis,
    pape.pricing_basis_name selected_pricing_basis_name,
    pape.sequence_number selected_sequence_number,
    ip.order_type_lookup_code sel_order_type_lookup_code,
    pet.enabled_flag selected_enabled_flag

  FROM
    pon_auc_price_elements_int pape,
    pon_item_prices_interface ip,
    pon_price_element_types pet

  WHERE
    pape.batch_id = p_batch_id
    and pape.price_element_type_id = pet.price_element_type_id
    and pape.batch_id = ip.batch_id
    AND pape.auction_header_id = ip.auction_header_id
    AND pape.interface_line_id = ip.interface_line_id;

  -- perform duplicate checks (using price element type id)
  insert into pon_interface_errors (
	BATCH_ID,
	INTERFACE_LINE_ID,
	TABLE_NAME,
	COLUMN_NAME,
	ERROR_MESSAGE_NAME,
	ERROR_VALUE
  )
  select
	pape1.batch_id,
	pape1.interface_line_id,
	'PON_AUC_PRICE_ELEMENTS_INT',
	fnd_message.get_string('PON','PON_AUC_PRICE_ELEMENT_NAME'),
	'PON_DUPLICATE_WARNING_PRICE',
	pape1.price_element_type_name
  from pon_auc_price_elements_int pape1,
       pon_auc_price_elements_int pape2
  where pape1.batch_id = p_batch_id
    and pape1.batch_id = pape2.batch_id
    and pape1.interface_line_id = pape2.interface_line_id
    and pape1.price_element_type_id = pape2.price_element_type_id
    and pape1.sequence_number <> pape2.sequence_number;

  -- validate that in the amendment creation flow or new negotiation round creation flow
  -- an uploaded supplier price factor cannot replace an existing buyer price factor with the same name
  -- if the buyer price factor already has supplier values defined
  insert into pon_interface_errors (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  select
    int_pe.batch_id,
    int_pe.interface_line_id,
    'PON_AUC_PRICE_ELEMENTS_INT',
    fnd_message.get_string('PON','PON_AUC_PRICE_ELEMENT_NAME'),
    'PON_AUC_CANNOT_UPLOAD_PF_1',
    int_pe.price_element_type_name
  from
    pon_price_elements auction_pe,
    pon_auc_price_elements_int int_pe
  where
        int_pe.batch_id = p_batch_id
    and auction_pe.auction_header_id = int_pe.auction_header_id
    and auction_pe.line_number = int_pe.auction_line_number
    and auction_pe.price_element_type_id = int_pe.price_element_type_id
    and auction_pe.pf_type = 'BUYER'
    and int_pe.pf_type = 'SUPPLIER'
    and exists (select 1
                from pon_pf_supplier_values pf_values
                where
                      pf_values.auction_header_id = auction_pe.auction_header_id
                  and pf_values.line_number = auction_pe.line_number
                  and pf_values.pf_seq_number = auction_pe.sequence_number);

  RETURN ;
END;


PROCEDURE validate_header_attributes(
  p_source		VARCHAR2,
  p_batch_id		NUMBER,
  p_party_id		NUMBER
) AS
  l_auction_header_id	pon_auc_attributes_interface.auction_header_id%TYPE;
  l_message_suffix	VARCHAR2(2);
  l_hdr_attr_enable_weights VARCHAR2(1);

  --SLM UI Enhancement
  l_is_slm VARCHAR2(1);

BEGIN
  -- init vars
  BEGIN
    select max(pai.auction_header_id)
    into l_auction_header_id
    from pon_auc_attributes_interface pai
    where pai.batch_id = p_batch_id;

    select hdr_attr_enable_weights
    into l_hdr_attr_enable_weights
    from pon_auction_headers_all pah
    where pah.auction_header_id = l_auction_header_id;

    select pon_auction_pkg.get_message_suffix(doc.internal_name)
    into l_message_suffix
    from pon_auction_headers_all pah,
	 pon_auc_doctypes doc
    where pah.auction_header_id = l_auction_header_id
      and pah.doctype_id = doc.doctype_id;
  EXCEPTION
    WHEN no_data_found THEN
      l_message_suffix := NULL;
      l_auction_header_id := NULL;
      l_hdr_attr_enable_weights := NULL;
  END;

  --SLM UI Enhancement
    BEGIN
    if (l_auction_header_id IS NOT NULL) then
       l_is_slm := PON_SLM_UTIL_PKG.IS_SLM_DOCUMENT(l_auction_header_id);
    else
       l_is_slm := 'N';
    end if;
    EXCEPTION
       WHEN others THEN
       l_is_slm := 'N';
    END;

  -- This is a call to common validate Attributes.last var indicates header attr.
  validate_attributes(p_source,p_batch_id,p_party_id,true);

  INSERT ALL

  -- validate that the weight is between 0 and 100.
  when
  (
    l_hdr_attr_enable_weights = 'Y'
    and selected_auction_line_number = -1
    and  selected_weight is not null
    and (selected_weight > 100
        or selected_weight < 0 )
  )
  then into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  values
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_ATTRIBUTES_INTERFACE',
    fnd_message.get_string('PON','PON_AUCTS_ATTR_WEIGHT'),
    'PON_AUC_WEIGHT_RANGE',
    selected_weight
  )

  --validate that the score is not entered for Display only attributes.

  when
  (
    selected_auction_line_number = -1
    and  (selected_aTTR_MAX_SCORE is not null and selected_ATTR_MAX_SCORE <> 0)
    and selected_DISPLAY_ONLY_FLAG = 'Y'
  )
  then into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  values
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_ATTRIBUTES_INTERFACE',
    fnd_message.get_string('PON','PON_AUC_SCORE'),
    Decode(l_is_slm, 'Y','PON_SLM_DISP_ATTR_NO_SCORES', 'PON_AUCTS_DISP_ATTR_NO_SCORES'), --SLM UI Enhancement
    selected_ATTR_MAX_SCORE
  )

  -- validate that the score is  greater than zero.
  when
  (
    selected_auction_line_number = -1
    and  selected_ATTR_MAX_SCORE is not null
    and selected_ATTR_MAX_SCORE < 0
  )
  then into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  values
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_ATTRIBUTES_INTERFACE',
    fnd_message.get_string('PON','PON_AUC_SCORE'),
    Decode(l_is_slm, 'Y','PON_SLM_INVALID_MAXSCORE_RANGE','PON_AUC_INVALID_MAXSCORE_RANGE'),  --SLM UI Enhancement
    selected_ATTR_MAX_SCORE
  )

  SELECT
    pai.batch_id selected_batch_id,
    pai.interface_line_id selected_interface_line_id,
    pai.weight selected_weight,
    pai.auction_line_number selected_auction_line_number,
    pai.attr_max_score selected_attr_max_score,
    pai.display_only_flag selected_display_only_flag

  from
    pon_auc_attributes_interface pai

  where
    pai.batch_id = p_batch_id;


END validate_header_attributes;

-- for line attributes.
PROCEDURE validate_attributes(
  p_source		VARCHAR2,
  p_batch_id		NUMBER,
  p_party_id		NUMBER
) AS
BEGIN
  -- This is a call to common validate Attributes.last var indicates header attr.
  validate_attributes(p_source,p_batch_id,p_party_id,false);
END validate_attributes;

PROCEDURE validate_attributes(
  p_source		VARCHAR2,
  p_batch_id		NUMBER,
  p_party_id		NUMBER,
  p_attr_type_header    BOOLEAN
) AS
  l_auction_header_id	pon_auc_attributes_interface.auction_header_id%TYPE;
  l_message_suffix	VARCHAR2(2);
  l_group_pref_name VARCHAR2(40);
  l_group_lookup_type VARCHAR2(40);
  l_attr_type_header VARCHAR2(1);
  l_spm_Ext_Enabled VARCHAR2(1);
  l_Supp_Eval_Flag  VARCHAR2(1);
  l_Internal_Eval_Flag  VARCHAR2(1);
  l_Internal_Only_Flag   VARCHAR2(1);
  l_is_copy VARCHAR2(1):='Y';

  --SLM UI Enhancement
  l_is_slm VARCHAR2(1);
BEGIN

  IF (p_attr_type_header) THEN

    l_attr_type_header := 'Y';
  ELSE

    l_attr_type_header := 'N';
  END IF;

  -- init vars

  BEGIN
    select max(pai.auction_header_id)
    into l_auction_header_id
    from pon_auc_attributes_interface pai
    where pai.batch_id = p_batch_id;
	-- Bug#17276867: SLM refactoring changes.
	l_spm_Ext_Enabled:= fnd_profile.value('POS_SM_ENABLE_SPM_EXTENSION');
SELECT nvl(SUPP_EVAL_FLAG,'N'), nvl(INTERNAL_EVAL_FLAG,'N'), nvl(INTERNAL_ONLY_FLAG,'N') INTO  l_Supp_Eval_Flag,l_Internal_Eval_Flag, l_Internal_Only_Flag
FROM pon_auction_headers_all WHERE auction_header_id = l_auction_header_id;
IF(l_spm_Ext_Enabled = 'Y' AND l_Supp_Eval_Flag ='Y' AND (l_Internal_Eval_Flag='Y' OR l_Internal_Only_Flag='Y')) THEN
l_is_copy:='N';
  END IF;

    select pon_auction_pkg.get_message_suffix(doc.internal_name)
    into l_message_suffix
    from pon_auction_headers_all pah,
	 pon_auc_doctypes doc
    where pah.auction_header_id = l_auction_header_id
      and pah.doctype_id = doc.doctype_id;
  EXCEPTION
    WHEN no_data_found THEN
      l_message_suffix := NULL;
      l_auction_header_id := NULL;
      l_group_pref_name := NULL;
      l_group_lookup_type := NULL;
  END;

  --SLM UI Enhancement
    BEGIN
    if (l_auction_header_id IS NOT NULL) then
       l_is_slm := PON_SLM_UTIL_PKG.IS_SLM_DOCUMENT(l_auction_header_id);
    else
       l_is_slm := 'N';
    end if;
    EXCEPTION
       WHEN others THEN
       l_is_slm := 'N';
    END;


  -- GROUP Check Starts.
  -- default GROUP_CODE as General for lines with group_name as null.
  IF ( not p_attr_type_header ) THEN
      l_group_pref_name := 'LINE_ATTR_DEFAULT_GROUP';
      l_group_lookup_type := 'PON_LINE_ATTRIBUTE_GROUPS';
  END IF;


  -- Populate data
  -- RESPONSE_TYPE
  -- bug 3373002
  -- need to compare apple with apple, response type values are from fnd messages
  -- so also validate against messages, not lookups.
  -- bug#16233503: Mandating Internal Requirement Enhancement.
  IF ( p_attr_type_header ) THEN
   update pon_auc_attributes_interface pai
   set response_type = decode(response_type_name,
           fnd_message.get_string('PON','PON_AUCTS_REQUIRED'), 'REQUIRED',
           fnd_message.get_string('PON','PON_AUCTS_OPTIONAL'), 'OPTIONAL',
           fnd_message.get_string('PON','PON_AUCTS_SUPP_REQ'), 'REQUIRED',
           fnd_message.get_string('PON','PON_AUCTS_SUPP_OPT'), 'OPTIONAL',
           fnd_message.get_string('PON','PON_AUCTS_DISPLAY_ONLY'), 'DISPLAY_ONLY',
           fnd_message.get_string('PON','PON_AUCTS_INTERNAL'), 'INTERNAL',
           fnd_message.get_string('PON','PON_AUCTS_INTERNAL_OPT'), 'INTERNAL',
           fnd_message.get_string('PON','PON_AUCTS_INTERNAL_REQ'), 'INTERNAL_REQ',
           null)
   where pai.batch_id = p_batch_id
    and pai.response_type_name is not null;
  ELSE
   update pon_auc_attributes_interface pai
   set response_type = decode(response_type_name,
           fnd_message.get_string('PON','PON_AUCTS_REQUIRED'), 'REQUIRED',
           fnd_message.get_string('PON','PON_AUCTS_OPTIONAL'), 'OPTIONAL',
           fnd_message.get_string('PON','PON_AUCTS_DISPLAY_ONLY'), 'DISPLAY_ONLY',
           null)
   where pai.batch_id = p_batch_id
    and pai.response_type_name is not null;
  END IF;

  -- MANDATORY_FLAG
  -- DISPLAY_ONLY_FLAG
  -- INTERNAL_ATTR_FLAG
  -- bug#16233503: Mandating Internal Requirement Enhancement.
  update
    pon_auc_attributes_interface
  set
    mandatory_flag = decode(response_type,'REQUIRED','Y',(decode(response_type,'INTERNAL_REQ','Y','N'))),
    display_only_flag = decode(response_type,'DISPLAY_ONLY','Y','N'),
    internal_attr_flag  = decode(response_type,'INTERNAL','Y',(decode(response_type,'INTERNAL_REQ','Y','N')))
  where
    batch_id = p_batch_id;


  -- Not to be Done for Header Section.
  IF ( not p_attr_type_header ) THEN
    update pon_auc_attributes_interface paai
    set paai.GROUP_CODE = (select nvl(ppp.preference_value,'GENERAL')
                              from pon_party_preferences ppp
                              where ppp.app_short_name = 'PON'
                              and ppp.preference_name = l_group_pref_name
                              and ppp.party_id = p_party_id)
    where paai.batch_id = p_batch_id
    and paai.GROUP_NAME is NULL
    AND paai.auction_line_number <> -1;


-- populate GROUP_CODE. Note that the comparison is case sensitive.

  update pon_auc_attributes_interface paai
  set paai.GROUP_CODE = (
    select lookup_code
    from fnd_lookup_values attrGrpFlv
    where lookup_type = l_group_lookup_type
    --where lookup_type = 'PON_HEADER_ATTRIBUTE_GROUPS'
    and meaning = paai.GROUP_NAME
    and attrGrpFlv.LANGUAGE = userenv('LANG')
    and attrGrpFlv.view_application_id = 0
    and attrGrpFlv.security_group_id = 0
    and attrGrpFlv.enabled_flag = 'Y'
    and nvl(attrGrpFlv.start_date_active,SYSDATE) <= SYSDATE
    and nvl(attrGrpFlv.end_date_active,SYSDATE) > SYSDATE-1
  )
  where paai.batch_id = p_batch_id
  and paai.GROUP_NAME is not NULL
  AND paai.auction_line_number <> -1;

  ELSE
    -- For Header Case, if the Group Name is null, default General.
  update pon_auc_attributes_interface paai
  set paai.GROUP_NAME = (
    select meaning
    from fnd_lookup_values attrGrpFlv
    where attrGrpFlv.lookup_type = 'PON_HEADER_ATTRIBUTE_GROUPS'
    and attrGrpFlv.lookup_code = 'GENERAL'
    and attrGrpFlv.LANGUAGE = userenv('LANG')
    and attrGrpFlv.view_application_id = 0
    and attrGrpFlv.security_group_id = 0
    and attrGrpFlv.enabled_flag = 'Y'
    and nvl(attrGrpFlv.start_date_active,SYSDATE) <= SYSDATE
    and nvl(attrGrpFlv.end_date_active,SYSDATE) > SYSDATE-1
  )
  where paai.batch_id = p_batch_id
  and paai.GROUP_NAME is NULL
  AND paai.auction_line_number <> -1;

  END IF;

  ----------------  Validations start here ------------

  INSERT ALL

  -- Datatype
  WHEN
  (
    selected_datatype is null
  )
  THEN into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  VALUES
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_ATTRIBUTES_INTERFACE',
    fnd_message.get_string('PON','PON_AUCTS_ATTR_DATATYPE'),
    decode(l_group_pref_name, 'LINE_ATTR_DEFAULT_GROUP', 'PON_AUCTS_ATTR_INVALID_TYPE',
            Decode(l_is_slm, 'Y','PON_SLM_AUC_REQ_INVALID_TYPE','PON_AUCTS_REQ_INVALID_TYPE')),   --SLM UI Enhancement
    selected_datatype
  )

  -- Response Type

  WHEN
  (
    selected_response_type is null
  )
  THEN into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  VALUES
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_ATTRIBUTES_INTERFACE',
    decode(l_group_pref_name,'LINE_ATTR_DEFAULT_GROUP',pon_auction_pkg.getMessage('PON_AUCTS_BID_RESPONSE',l_message_suffix),pon_auction_pkg.getMessage('PON_AUCTS_TYPE')),
    'PON_CAT_INVALID_VALUE',
    selected_response_type_name
  )

  -- Display Target Flag

  WHEN
  (
    nvl(selected_display_target_flag,'N') not in ('Y','N')
  )

  THEN into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  values
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_ATTRIBUTES_INTERFACE',
    fnd_message.get_string('PON','PON_AUCTS_ATTR_D_TARGET'),
    'PON_AUCTS_INV_PR_QT_VAL',
    selected_display_target_flag
  )

  -- validate datatype [lookup_type = PON_AUCTION_ATTRIBUTE_TYPE]

  when
  (
    selected_datatype not in (
	  select lookup_code
	  from fnd_lookups
	  where lookup_type = 'PON_AUCTION_ATTRIBUTE_TYPE'
    	)
  )
  then into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  values
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_ATTRIBUTES_INTERFACE',
    fnd_message.get_string('PON','PON_AUCTS_ATTR_DATATYPE'),
    decode(l_group_pref_name, 'LINE_ATTR_DEFAULT_GROUP', 'PON_AUCTS_ATTR_INVALID_TYPE',
           Decode(l_is_slm, 'Y','PON_SLM_AUC_REQ_INVALID_TYPE','PON_AUCTS_REQ_INVALID_TYPE')), --SLM UI Enhancement
    selected_datatype
  )

  -- validate display target flag is Y/N
  when
  (
    nvl(selected_display_target_flag,'N') not in ('Y','N')
  )
  then into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  values
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_ATTRIBUTES_INTERFACE',
    fnd_message.get_string('PON','PON_AUCTS_ATTR_D_TARGET'),
    'PON_AUCTS_INV_PR_QT_VAL',
    selected_display_target_flag
  )

  when
  (
    selected_display_target_flag = 'Y'
    and selected_value is null
  )
  then into pon_interface_errors
  (
	BATCH_ID,
	INTERFACE_LINE_ID,
	TABLE_NAME,
	COLUMN_NAME,
	ERROR_MESSAGE_NAME,
	ERROR_VALUE
  )
  values
  (
	selected_batch_id,
	selected_interface_line_id,
	'PON_AUC_ATTRIBUTES_INTERFACE',
    fnd_message.get_string('PON','PON_AUCTS_TARGET_VALUE'),
	'PON_AUCTS_ATTR_SHOW_TARGET',
	selected_value
  )

  -- validate value given if display_only = Y
  when
  (
    selected_display_only_flag = 'Y'
    and selected_value is null
  -- Bug 6957765
  and  nvl(selected_display_target_flag,'N') = 'Y'
  )
  then into pon_interface_errors
  (
	BATCH_ID,
	INTERFACE_LINE_ID,
	TABLE_NAME,
	COLUMN_NAME,
	ERROR_MESSAGE_NAME,
	ERROR_VALUE
  )
  values
  (
	selected_batch_id,
	selected_interface_line_id,
	'PON_AUC_ATTRIBUTES_INTERFACE',
	pon_auction_pkg.getMessage('PON_AUCTS_ATTR_TARGET', Decode(l_is_slm, 'Y', PON_SLM_UTIL_PKG.SLM_MESSAGE_SUFFIX_UNDERSCORE ,l_message_suffix)),  --SLM UI Enhancement
	decode(l_group_pref_name, 'LINE_ATTR_DEFAULT_GROUP','PON_AUCTS_ATTR_DISPLAY_TARGET',
         Decode(l_is_slm, 'Y','PON_SLM_REQ_DISPLAY_TARGET','PON_AUCTS_REQ_DISPLAY_TARGET')), --SLM UI Enhancement
	selected_value
  )

  -- Attribute Name

  when
  (
    selected_attribute_name is null
  )
  then into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  values
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_ATTRIBUTES_INTERFACE',
    decode(l_group_pref_name, 'LINE_ATTR_DEFAULT_GROUP', fnd_message.get_string('PON','PON_AUCTS_ATTR'),
           Decode(l_is_slm, 'Y',fnd_message.get_string('PON', 'PON_SLM_QUESTION') ,fnd_message.get_string('PON', 'PON_AUC_REQUIREMENT'))), --SLM UI Enhancement
    'PON_FIELD_MUST_BE_ENTERED',
    selected_attribute_name
  )

  -- required field checks
  -- SEQUENCE_NUMBER -- should never be displayed to user
  -- Do not do this check for Header attributes. We will populate the sequence
  -- when we copy them over to the AuctionAttributesVO
  when
  (
    l_attr_type_header = 'N' AND
    selected_sequence_number is null
  )
  then into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  values
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_ATTRIBUTES_INTERFACE',
    'SEQUENCE_NUMBER',
    'PON_CAT_DISP_SEQ_M',
    selected_sequence_number
  )

-- To insert errors for the group which are invalid.
  when
  (
    selected_group_code is null
    AND l_attr_type_header = 'N'
    AND selected_auction_line_num <> -1
  )
  then into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  values
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_ATTRIBUTES_INTERFACE',
    fnd_message.get_string('PON','PON_AUCTS_GROUP'),
    'PON_AUCTS_INVALID_GROUP',
    selected_group_name
  )

  -- validate display target == N if attribute type is Internal
  when
  (
    nvl(selected_display_target_flag,'N') = 'Y'
    and selected_internal_attr_flag = 'Y'
    and l_attr_type_header = 'Y'
  )
  then into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  values
  (
    selected_batch_id,
    selected_interface_line_id,
   'PON_AUC_ATTRIBUTES_INTERFACE',
    fnd_message.get_string('PON','PON_AUCTS_ATTR_D_TARGET'),
    Decode(l_is_slm, 'Y', 'PON_SLM_INTERNAL_ATT_ERROR', 'PON_AUC_INTERNAL_ATT_ERROR'), --SLM UI Enhancement
    fnd_message.get_string('PON','PON_CORE_NO')
  )
  when
  (
    l_attr_type_header = 'Y'
    AND l_is_copy ='N'
    and  selected_response_type IN ('REQUIRED', 'OPTIONAL')
  )
  then into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  values
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_ATTRIBUTES_INTERFACE',
    Decode(l_is_slm, 'Y', fnd_message.get_string('PON','PON_SLM_QUESTION'), fnd_message.get_string('PON','PON_AUC_REQUIREMENT')), --SLM UI Enhancement
    Decode(l_is_slm, 'Y','PON_SLM_SUPP_INT_QUE_ERR','PON_SUPP_INT_REQ_ERR'), --SLM UI Enhancement
    selected_response_type_name
  )

  SELECT
    pai.batch_id selected_batch_id,
    pai.interface_line_id selected_interface_line_id,
    pai.datatype selected_datatype,
    pai.value selected_value,
    pai.display_target_flag selected_display_target_flag,
    pai.display_only_flag selected_display_only_flag,
    pai.response_type_name selected_response_type_name,
    pai.response_type selected_response_type,
    pai.attribute_name selected_attribute_name,
    pai.sequence_number selected_sequence_number,
    pai.group_name selected_group_name,
    pai.group_code selected_group_code,
    pai.internal_attr_flag selected_internal_attr_flag,
    pai.auction_line_number selected_auction_line_num

  from
    pon_auc_attributes_interface pai
  where
    pai.batch_id = p_batch_id;

  -- perform duplicate checks
  IF ( p_attr_type_header ) THEN
    insert into pon_interface_errors (
	BATCH_ID,
	INTERFACE_LINE_ID,
	TABLE_NAME,
	COLUMN_NAME,
	ERROR_MESSAGE_NAME,
	ERROR_VALUE
    )
    select
	pai1.batch_id,
	pai1.interface_line_id,
	'PON_AUC_ATTRIBUTES_INTERFACE',
	fnd_message.get_string('PON','PON_AUC_REQUIREMENT'),
	'PON_REQUIREMENT_DUPLICATE_ATT',
	pai1.attribute_name
    from pon_auc_attributes_interface pai1,
       pon_auc_attributes_interface pai2
    where pai1.batch_id = p_batch_id
    and pai1.batch_id = pai2.batch_id
    and pai1.auction_line_number = pai2.auction_line_number
    and upper(pai1.attribute_name) = upper(pai2.attribute_name)
    and pai1.interface_line_id <> pai2.interface_line_id;
  ELSE
    insert into pon_interface_errors (
	BATCH_ID,
	INTERFACE_LINE_ID,
	TABLE_NAME,
	COLUMN_NAME,
	ERROR_MESSAGE_NAME,
	ERROR_VALUE
    )
    select
	pai1.batch_id,
	pai1.interface_line_id,
	'PON_AUC_ATTRIBUTES_INTERFACE',
	fnd_message.get_string('PON','PON_AUCTS_ATTR'),
	'PON_DUPLICATE_WARNING_ATTR',
	pai1.attribute_name
    from pon_auc_attributes_interface pai1,
       pon_auc_attributes_interface pai2
    where pai1.batch_id = p_batch_id
    and pai1.batch_id = pai2.batch_id
    and pai1.interface_line_id = pai2.interface_line_id
    and upper(pai1.attribute_name) = upper(pai2.attribute_name)
    and pai1.sequence_number <> pai2.sequence_number;
  END IF;

  -- duplicate check against the allready saved header attributes.
  IF ( p_attr_type_header ) THEN
    insert into pon_interface_errors (
	BATCH_ID,
	INTERFACE_LINE_ID,
	TABLE_NAME,
	COLUMN_NAME,
	ERROR_MESSAGE_NAME,
	ERROR_VALUE
    )
    select
	pai1.batch_id,
	pai1.interface_line_id,
	'PON_AUC_ATTRIBUTES_INTERFACE',
	fnd_message.get_string('PON','PON_AUC_REQUIREMENT'),
	'PON_REQUIREMENT_DUPLICATE_ATT',
	pai1.attribute_name
    from pon_auc_attributes_interface pai1,
       pon_auction_attributes paa
    where pai1.batch_id = p_batch_id
    and paa.auction_header_id = pai1.auction_header_id
    and pai1.auction_line_number = -1
    and paa.line_number = pai1.auction_line_number
    and upper(pai1.attribute_name) = upper(paa.attribute_name);
  END IF;

END validate_attributes;


PROCEDURE add_template_price_elements(
  p_batch_id		NUMBER,
  p_auction_template_id NUMBER,
  p_auction_header_id   NUMBER
) AS
  l_sequence_start	NUMBER;
  l_auction_pf_type_allowed VARCHAR2(30);
BEGIN
  -- select max sequence number (across all lines)
  select nvl(max(sequence_number), 0)
  into l_sequence_start
  from pon_auc_price_elements_int
  where batch_id = p_batch_id
    and sequence_number >= 0;

  l_sequence_start := l_sequence_start + 10;

  -- determine which price factor types are allowed by the negotiation
  SELECT pf_type_allowed
  INTO l_auction_pf_type_allowed
  FROM pon_auction_headers_all
  WHERE auction_header_id = p_auction_header_id;

  -- insert template price elements for all lines
  insert into pon_auc_price_elements_int (
    BATCH_ID,
    INTERFACE_LINE_ID,
    AUCTION_HEADER_ID,
    AUCTION_LINE_NUMBER,
    SEQUENCE_NUMBER,
    PRICE_ELEMENT_TYPE_NAME,
    PRICE_ELEMENT_TYPE_ID,
    DESCRIPTION,
    PRICING_BASIS_NAME,
    PRICING_BASIS,
    VALUE,
    PRECISION,
    DISPLAY_TARGET_FLAG,
    PF_TYPE,
    DISPLAY_TO_SUPPLIERS_FLAG
  )
  select
	ip.batch_id,
	ip.interface_line_id,
	ip.auction_header_id,
    ip.auction_line_number,
	l_sequence_start + pe.sequence_number,
	petl.name,
	pe.price_element_type_id,
	petl.description,
	fl.meaning,
	pe.pricing_basis,
	pe.value,
	-1,
	pe.display_target_flag,
  pe.pf_type,
  pe.display_to_suppliers_flag
  from
	pon_price_elements pe,
	pon_price_element_types pet,
	pon_price_element_types_tl petl,
	fnd_lookups fl,
	pon_item_prices_interface ip
  where
	ip.batch_id = p_batch_id
	and pe.auction_header_id = p_auction_template_id
	and pe.price_element_type_id = pet.price_element_type_id
	and pe.price_element_type_id = petl.price_element_type_id
	and pe.price_element_type_id <> -10  -- why copy Item Price?
	and pet.enabled_flag = 'Y'
	and petl.language = userenv('LANG')
	and fl.lookup_type = 'PON_PRICING_BASIS'
	and fl.lookup_code = pe.pricing_basis
    and ip.group_type <> 'GROUP'
  and pe.pf_type = DECODE(l_auction_pf_type_allowed,
                          'BOTH', pe.pf_type,
                          'BUYER', 'BUYER',
                          'SUPPLIER', 'SUPPLIER',
                          'NONE');

  -- resolve duplicate price elements by removing the Template price element
  delete from pon_auc_price_elements_int pape1
  where rowid in (
    select pape1.rowid
    from pon_auc_price_elements_int pape2
    where pape1.batch_id = p_batch_id
      and pape1.batch_id = pape2.batch_id
      and pape1.interface_line_id = pape2.interface_line_id
      and pape1.price_element_type_id = pape2.price_element_type_id
      and pape1.precision = -1
      and (pape2.precision is null or pape2.precision <> -1)
  );
END add_template_price_elements;


PROCEDURE add_template_attributes(
  p_batch_id		NUMBER,
  p_auction_template_id NUMBER
) AS
  l_sequence_start	NUMBER;
BEGIN
  -- select max sequence number (across all lines)
  BEGIN
    select nvl(max(sequence_number),0)
    into l_sequence_start
    from pon_auc_attributes_interface
    where batch_id = p_batch_id
      and sequence_number >= 0;
    l_sequence_start := l_sequence_start + 10;
  EXCEPTION
    WHEN no_data_found THEN
      l_sequence_start := 0;
  END;

  -- insert template attributes for all lines
  insert into pon_auc_attributes_interface (
    BATCH_ID,
    INTERFACE_LINE_ID,
    AUCTION_LINE_NUMBER,
    AUCTION_HEADER_ID,
    SEQUENCE_NUMBER,
    ATTRIBUTE_NAME,
    GROUP_CODE,
    DATATYPE,
    VALUE,
    RESPONSE_TYPE_NAME,
    RESPONSE_TYPE,
    MANDATORY_FLAG,
    DISPLAY_ONLY_FLAG,
    DISPLAY_TARGET_FLAG,
    SCORING_TYPE,
    ATTR_GROUP_SEQ_NUMBER,
    ATTR_DISP_SEQ_NUMBER
  )
  select
	ip.batch_id,
	ip.interface_line_id,
    ip.auction_line_number,
	ip.auction_header_id,
	l_sequence_start + att.sequence_number,
	att.attribute_name,
        att.ATTR_GROUP,
	att.datatype,
	att.value,
	'PON_FROM_TEMPLATE',
	decode(att.mandatory_flag,'Y','REQUIRED',
          decode(att.display_only_flag,'Y','DISPLAY_ONLY','OPTIONAL') ),
	att.mandatory_flag,
	att.display_only_flag,
        att.display_target_flag,
        att.scoring_type,
    att.attr_group_seq_number,
    att.attr_disp_seq_number
  from
	pon_auction_attributes att,
	pon_item_prices_interface ip
  where
	ip.batch_id = p_batch_id
        and att.line_number <> -1
        and ip.group_type <> 'GROUP'
	and att.auction_header_id = p_auction_template_id;

  -- resolve duplicate attributes by removing the Template attribute
  delete from pon_auc_attributes_interface pai1
  where rowid in (
    select pai1.rowid
    from pon_auc_attributes_interface pai2
    where pai1.batch_id = p_batch_id
      and pai1.batch_id = pai2.batch_id
      and pai1.interface_line_id = pai2.interface_line_id
      and pai1.attribute_name = pai2.attribute_name
      and pai1.response_type_name = 'PON_FROM_TEMPLATE'
      and pai2.response_type_name <> 'PON_FROM_TEMPLATE'
  );
END add_template_attributes;


PROCEDURE validate_price_differentials(
				       p_source VARCHAR2,
				       p_batch_id NUMBER
				       )AS

l_auction_header_id pon_auc_price_differ_int.auction_header_id%TYPE;
l_message_suffix VARCHAR2(2);
l_contract_type pon_auction_headers_all.contract_type%TYPE;
l_global_agreement pon_auction_headers_all.global_agreement_flag%TYPE;

BEGIN

   -- init vars
BEGIN


   SELECT max(papd.auction_header_id)
     INTO  l_auction_header_id
     FROM  pon_auc_price_differ_int papd
     WHERE  papd.batch_id = p_batch_id;

   SELECT pon_auction_pkg.get_message_suffix(doc.internal_name)
     INTO  l_message_suffix
     FROM  pon_auction_headers_all pah,pon_auc_doctypes doc
     WHERE  pah.auction_header_id = l_auction_header_id
     AND  pah.doctype_id = doc.doctype_id;

   --Don't do any validation if its not a global blanket agreement
   -- And if there are any rows in the interface table delete them
   SELECT pah.contract_type, pah.global_agreement_flag
     INTO l_contract_type, l_global_agreement
     FROM pon_auction_headers_all pah
     WHERE pah.auction_header_id = l_auction_header_id;

   IF ((l_contract_type <> 'BLANKET' AND l_contract_type <> 'CONTRACT') OR  l_global_agreement <> 'Y') THEN
      DELETE FROM pon_auc_price_differ_int
	WHERE batch_id = p_batch_id;
      RETURN;
   END IF ;

EXCEPTION

   WHEN no_data_found THEN
      l_message_suffix := NULL;
      l_auction_header_id := NULL;
END;

  -- update the interface table with the price_type values
  -- from the po_price_diff_lookups_v values
  UPDATE pon_auc_price_differ_int papdi
    SET price_type =  (SELECT Nvl(MAX(ppdl.price_differential_type),'PRICE_TYPE_INVALID')
		       FROM po_price_diff_lookups_v ppdl
		       WHERE papdi.price_type_name = ppdl.price_differential_dsp(+)),

    price_type_desc = (SELECT Nvl(MAX(ppdl.price_differential_desc),'PRICE_DESC_INVALID')
		       FROM po_price_diff_lookups_v ppdl
		       WHERE papdi.price_type_name = ppdl.price_differential_dsp(+))
    WHERE batch_id = p_batch_id
    AND price_type_name <> 'EMPTY_PRICE_TYPE_NAME';

  --------------- Validations start here --------------
  INSERT ALL

  -- Price Type errors will go into the interface table
  -- Check for Price type being null for those

  WHEN
  (
    selected_multiplier <> -9999
    AND selected_price_type_name = 'EMPTY_PRICE_TYPE_NAME'
  )
  THEN INTO pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  VALUES
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_PRICE_DIFFER_INT',
    fnd_message.get_string('PON','PON_AUCTS_PRICE_TYPE'),
    'PON_FIELD_MUST_BE_ENTERED',
    null
  )

  -- Price Type errors will go into the interface table
  -- Check for invalid price type values

  WHEN
  (
    selected_price_type_name =  'PRICE_TYPE_INVALID'
    AND selected_price_type_name <> 'EMPTY_PRICE_TYPE_NAME'
  )
  THEN INTO pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  values
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_PRICE_DIFFER_INT',
    fnd_message.get_string('PON','PON_AUCTS_PRICE_TYPE'),
    'PON_TYPE_VALUE_INVALID',
    selected_price_type_name
  )

  SELECT
    papd.batch_id selected_batch_id,
    papd.interface_line_id selected_interface_line_id,
    papd.multiplier selected_multiplier,
    papd.price_type_name selected_price_type_name
  FROM
    pon_auc_price_differ_int papd
  WHERE
    papd.batch_id = p_batch_id;

    -- Price Type errors will go into the interface table
    -- Check if there are any duplicate values
    INSERT  INTO
      pon_interface_errors (
			    BATCH_ID,
			    INTERFACE_LINE_ID,
			    TABLE_NAME,
			    COLUMN_NAME,
			    ERROR_MESSAGE_NAME,
			    ERROR_VALUE
			    )

      SELECT
      papd.batch_id,
      papd.interface_line_id,
      'PON_AUC_PRICE_DIFFER_INT',
      fnd_message.get_string('PON','PON_AUCTS_PRICE_TYPE'),
      'PON_DUPLICATE_WARN_PRICE_TYPE',
      papd.price_type_name
      FROM  pon_auc_price_differ_int papd,
       pon_auc_price_differ_int papd2
      WHERE  papd.batch_id = p_batch_id
      AND papd.batch_id = papd2.batch_id
      AND  papd.interface_line_id = papd2.interface_line_id
      AND  papd.price_type = papd2.price_type
      AND  papd.sequence_number <> papd2.sequence_number;

END validate_price_differentials;

PROCEDURE add_ip_descriptors(p_batch_id            IN NUMBER,
                             p_auction_header_id   IN NUMBER) IS

l_tp_id NUMBER;
l_auction_round_number NUMBER;
l_amendment_number NUMBER;
l_default_attr_group  pon_auction_attributes.attr_group%TYPE;
l_ip_attr_default_option VARCHAR2(10);

BEGIN

  select trading_partner_id, nvl(auction_round_number, 1), nvl(amendment_number, 0)
  into   l_tp_id, l_auction_round_number, l_amendment_number
  from   pon_auction_headers_all
  where  auction_header_id = p_auction_header_id;

  select nvl(ppp.preference_value,'GENERAL')
  into   l_default_attr_group
  from pon_party_preferences ppp
  where ppp.app_short_name = 'PON' and
        ppp.preference_name = 'LINE_ATTR_DEFAULT_GROUP' and
        ppp.party_id = l_tp_id;


  l_ip_attr_default_option := fnd_profile.value('PON_IP_ATTR_DEFAULT_OPTION');
  IF (nvl(l_ip_attr_default_option, 'NONE') = 'NONE') THEN
    RETURN;
  END IF;

  add_ip_descs_on_new_lines(p_batch_id, l_default_attr_group, l_ip_attr_default_option);

  IF (l_auction_round_number > 1 or l_amendment_number > 0) THEN
    add_ip_descs_on_updated_lines(p_batch_id, l_default_attr_group, l_ip_attr_default_option);
  END IF;

END add_ip_descriptors;

PROCEDURE add_ip_descs_on_new_lines(p_batch_id               IN VARCHAR2,
                                    p_default_attr_group     IN VARCHAR2,
                                    p_ip_attr_default_option IN VARCHAR2) IS


l_max_attr_seq_num NUMBER;
l_def_attr_group_seq_num NUMBER;
l_def_attr_max_disp_seq_num NUMBER;
l_max_ip_seq_num NUMBER;

CURSOR lines IS
   SELECT interface_line_id, auction_header_id, auction_line_number, ip_category_id
   FROM   pon_item_prices_interface
   WHERE  batch_id = p_batch_id and
          nvl(action, '+') = '+';


BEGIN

  l_max_ip_seq_num := 9999999999999;

  FOR line in lines
  LOOP

    l_max_attr_seq_num := get_max_attr_seq_num(p_batch_id, line.interface_line_id);

    l_def_attr_group_seq_num := get_attr_group_seq_num(p_batch_id, line.interface_line_id,
                                                           p_default_attr_group);

    l_def_attr_max_disp_seq_num := get_attr_max_disp_seq_num(p_batch_id, line.interface_line_id,
                                                                 p_default_attr_group);

    -- bring over ip descriptors (base and catalog) for new lines

    INSERT INTO PON_AUC_ATTRIBUTES_INTERFACE (
     BATCH_ID,
     INTERFACE_LINE_ID,
     AUCTION_HEADER_ID,
     AUCTION_LINE_NUMBER,
     SEQUENCE_NUMBER,
     ATTRIBUTE_NAME,
     GROUP_CODE,
     DATATYPE,
     RESPONSE_TYPE,
     MANDATORY_FLAG,
     DISPLAY_ONLY_FLAG,
     INTERNAL_ATTR_FLAG,
     DISPLAY_TARGET_FLAG,
     VALUE,
     SCORING_TYPE,
     ATTR_GROUP_SEQ_NUMBER,
     ATTR_DISP_SEQ_NUMBER,
     IP_CATEGORY_ID,
     IP_DESCRIPTOR_ID
   )
   SELECT

     p_batch_id,                                       -- BATCH_ID
     line.interface_line_id,                           -- INTERFACE_LINE_ID
     line.auction_header_id,                           -- AUCTION_HEADER_ID
     line.auction_line_number,                         -- AUCTION_LINE_NUMBER
     l_max_attr_seq_num + (rownum*10),                 -- SEQUENCE_NUMBER
     attribute_name,                                   -- ATTRIBUTE_NAME
     p_default_attr_group,                             -- GROUP_CODE
     datatype,                                         -- DATATYPE
     'OPTIONAL',                                       -- RESPONSE_TYPE
     'N',                                              -- MANDATORY_FLAG
     'N',                                              -- DISPLAY_ONLY_FLAG
     'N',                                              -- INTERNAL_ATTR_FLAG
     'N',                                              -- DISPLAY_TARGET_FLAG
     null,                                             -- VALUE
     'NONE',                                           -- SCORING_TYPE
     l_def_attr_group_seq_num,                         -- ATTR_GROUP_SEQ_NUMBER
     l_def_attr_max_disp_seq_num + (rownum * 10),      -- ATTR_DISP_SEQ_NUMBER
     ip_category_id,                                   -- IP_CATEGORY_ID
     ip_descriptor_id                                  -- IP_DESCRIPTOR_ID
   FROM
        (SELECT attribute_name, decode(type, 1, 'NUM', 'TXT') datatype,
                rt_category_id ip_category_id, attribute_id ip_descriptor_id
         FROM   icx_cat_agreement_attrs_v
         WHERE  ((rt_category_id = 0 and p_ip_attr_default_option in ('ALL', 'BASE')) or
                (rt_category_id = line.ip_category_id and p_ip_attr_default_option in ('ALL', 'CATEGORY'))) and language = userenv('LANG') and
                upper(attribute_name) not in (select upper(attribute_name)
                                               from   pon_auc_attributes_interface
                                               where  batch_id = p_batch_id and
                                                      interface_line_id = line.interface_line_id)
          ORDER BY nvl(sequence, l_max_ip_seq_num) asc);

  END LOOP;

END add_ip_descs_on_new_lines;

PROCEDURE add_ip_descs_on_updated_lines(p_batch_id               IN VARCHAR2,
                                        p_default_attr_group     IN VARCHAR2,
                                        p_ip_attr_default_option IN VARCHAR2) IS

l_max_attr_seq_num NUMBER;
l_def_attr_group_seq_num NUMBER;
l_def_attr_max_disp_seq_num NUMBER;
l_max_ip_seq_num NUMBER;
l_ip_attr_default_option VARCHAR2(10);

-- updated lines where the ip category has changed and is not null;

CURSOR lines IS
   SELECT interface_line_id, auction_header_id, auction_line_number, ip_category_id
   FROM   pon_item_prices_interface
   WHERE  batch_id = p_batch_id and
          nvl(action, '+') = '#' and
          auction_line_number in (select paip.line_number
                                  from   pon_item_prices_interface p1,
                                         pon_auction_item_prices_all paip
                                  where  p1.batch_id = p_batch_id and
                                         nvl(p1.action, '+') = '#' and
                                         p1.auction_header_id = paip.auction_header_id and
                                         p1.auction_line_number = paip.line_number and
                                         p1.ip_category_id is not null and
                                         nvl(p1.ip_category_id, -1) <> nvl(paip.ip_category_id, -1));


BEGIN

  delete from
  (select *
   from   pon_auc_attributes_interface
   where  auction_line_number in (select paip.line_number
                                  from   pon_item_prices_interface p1,
                                         pon_auction_item_prices_all paip
                                  where  p1.batch_id = p_batch_id and
                                         nvl(p1.action, '+') = '#' and
                                         p1.auction_header_id = paip.auction_header_id and
                                         p1.auction_line_number = paip.line_number and
                                         paip.ip_category_id is not null and
                                         nvl(p1.ip_category_id, -1) <> nvl(paip.ip_category_id, -1))) paai
  where batch_id = p_batch_id and
        exists (select null
                from   pon_auction_attributes paa
                where  paa.auction_header_id = paai.auction_header_id and
                       paa.line_number = paai.auction_line_number and
                       upper(paa.attribute_name) = upper(paai.attribute_name) and
                       paa.ip_category_id is not null and
                       paa.ip_category_id <> 0);

  l_ip_attr_default_option := nvl(fnd_profile.value('PON_IP_ATTR_DEFAULT_OPTION'), 'NONE');

  IF (l_ip_attr_default_option in ('NONE', 'BASE')) THEN
    RETURN;
  END IF;

  l_max_ip_seq_num := 9999999999999;

  FOR line in lines
  LOOP

    l_max_attr_seq_num := get_max_attr_seq_num(p_batch_id, line.interface_line_id);

    l_def_attr_group_seq_num := get_attr_group_seq_num(p_batch_id, line.interface_line_id,
                                                           p_default_attr_group);

    l_def_attr_max_disp_seq_num := get_attr_max_disp_seq_num(p_batch_id, line.interface_line_id,
                                                                 p_default_attr_group);

    -- bring over ip catalog descriptors for updated lines

    INSERT INTO PON_AUC_ATTRIBUTES_INTERFACE (
     BATCH_ID,
     INTERFACE_LINE_ID,
     AUCTION_HEADER_ID,
     AUCTION_LINE_NUMBER,
     SEQUENCE_NUMBER,
     ATTRIBUTE_NAME,
     GROUP_CODE,
     DATATYPE,
     RESPONSE_TYPE,
     MANDATORY_FLAG,
     DISPLAY_ONLY_FLAG,
     INTERNAL_ATTR_FLAG,
     DISPLAY_TARGET_FLAG,
     VALUE,
     SCORING_TYPE,
     ATTR_GROUP_SEQ_NUMBER,
     ATTR_DISP_SEQ_NUMBER,
     IP_CATEGORY_ID,
     IP_DESCRIPTOR_ID
   )
   SELECT

     p_batch_id,                                       -- BATCH_ID
     line.interface_line_id,                           -- INTERFACE_LINE_ID
     line.auction_header_id,                           -- AUCTION_HEADER_ID
     line.auction_line_number,                         -- AUCTION_LINE_NUMBER
     l_max_attr_seq_num + (rownum*10),                 -- SEQUENCE_NUMBER
     attribute_name,                                   -- ATTRIBUTE_NAME
     p_default_attr_group,                             -- GROUP_CODE
     datatype,                                         -- DATATYPE
     'OPTIONAL',                                       -- RESPONSE_TYPE
     'N',                                              -- MANDATORY_FLAG
     'N',                                              -- DISPLAY_ONLY_FLAG
     'N',                                              -- INTERNAL_ATTR_FLAG
     'N',                                              -- DISPLAY_TARGET_FLAG
     null,                                             -- VALUE
     'NONE',                                           -- SCORING_TYPE
     l_def_attr_group_seq_num,                         -- ATTR_GROUP_SEQ_NUMBER
     l_def_attr_max_disp_seq_num + (rownum * 10),      -- ATTR_DISP_SEQ_NUMBER
     ip_category_id,                                   -- IP_CATEGORY_ID
     ip_descriptor_id                                  -- IP_DESCRIPTOR_ID
   FROM
        (SELECT attribute_name, decode(type, 1, 'NUM', 'TXT') datatype,
                rt_category_id ip_category_id, attribute_id ip_descriptor_id
         FROM   icx_cat_agreement_attrs_v
         WHERE  rt_category_id = line.ip_category_id and
                language = userenv('LANG') and
                upper(attribute_name) not in (select upper(attribute_name)
                                               from   pon_auc_attributes_interface
                                               where  batch_id = p_batch_id and
                                                      interface_line_id = line.interface_line_id)
          ORDER BY nvl(sequence, l_max_ip_seq_num) asc);

  END LOOP;

END add_ip_descs_on_updated_lines;

FUNCTION get_max_attr_seq_num(p_batch_id          IN NUMBER,
                              p_interface_line_id IN NUMBER) RETURN NUMBER

IS

l_max_attr_seq_num NUMBER;

BEGIN

  select nvl(max(sequence_number), 0)
  into   l_max_attr_seq_num
  from   pon_auc_attributes_interface
  where  batch_id = p_batch_id and
         interface_line_id = p_interface_line_id;

  RETURN l_max_attr_seq_num;

END get_max_attr_seq_num;

FUNCTION get_attr_group_seq_num(p_batch_id          IN NUMBER,
                                p_interface_line_id IN NUMBER,
                                p_attr_group        IN VARCHAR2) RETURN NUMBER
IS

l_attr_group_seq_num NUMBER;

BEGIN

  select attr_group_seq_number
  into   l_attr_group_seq_num
  from   pon_auc_attributes_interface
  where  batch_id = p_batch_id and
         interface_line_id = p_interface_line_id and
         group_code = p_attr_group and
         rownum = 1;

  RETURN l_attr_group_seq_num;

EXCEPTION

  when others then

      -- since group is not on the line yet,
      -- find max group seq number and add 10

      select nvl(max(attr_group_seq_number), 0) + 10
      into   l_attr_group_seq_num
      from   pon_auc_attributes_interface
      where  batch_id = p_batch_id and
             interface_line_id = p_interface_line_id;

     RETURN l_attr_group_seq_num;

END get_attr_group_seq_num;

FUNCTION get_attr_max_disp_seq_num(p_batch_id          IN NUMBER,
                                   p_interface_line_id IN NUMBER,
                                   p_attr_group        IN VARCHAR2) RETURN NUMBER
IS

l_attr_max_disp_seq_num NUMBER;

BEGIN

  select nvl(max(attr_disp_seq_number), 0)
  into   l_attr_max_disp_seq_num
  from   pon_auc_attributes_interface
  where  batch_id = p_batch_id and
         interface_line_id = p_interface_line_id and
         group_code = p_attr_group;

  RETURN l_attr_max_disp_seq_num;

END get_attr_max_disp_seq_num;

PROCEDURE validate_header_attributes_api(
  p_source		VARCHAR2,
  p_batch_id		NUMBER,
  p_party_id		NUMBER
) AS
  l_auction_header_id	pon_auc_attributes_interface.auction_header_id%TYPE;
  l_message_suffix	VARCHAR2(2);
  l_hdr_attr_enable_weights VARCHAR2(1);
BEGIN
  -- init vars
  BEGIN
    select max(pai.auction_header_id)
    into l_auction_header_id
    from pon_auc_attributes_interface pai
    where pai.batch_id = p_batch_id;

    select hdr_attr_enable_weights
    into l_hdr_attr_enable_weights
    from pon_auction_headers_all pah
    where pah.auction_header_id = l_auction_header_id;

    select pon_auction_pkg.get_message_suffix(doc.internal_name)
    into l_message_suffix
    from pon_auction_headers_all pah,
	 pon_auc_doctypes doc
    where pah.auction_header_id = l_auction_header_id
      and pah.doctype_id = doc.doctype_id;
  EXCEPTION
    WHEN no_data_found THEN
      l_message_suffix := NULL;
      l_auction_header_id := NULL;
      l_hdr_attr_enable_weights := NULL;
  END;

  -- This is a call to common validate Attributes.last var indicates header attr.
  validate_attributes_api(p_source,p_batch_id,p_party_id,true);

  INSERT ALL

  -- validate that the weight is between 0 and 100.
  when
  (
    l_hdr_attr_enable_weights = 'Y'
    and selected_auction_line_number = -1
    and  selected_weight is not null
    and (selected_weight > 100
        or selected_weight < 0 )
    AND Nvl(selected_action,'INSERT') = 'INSERT'
  )
  then into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  values
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_ATTRIBUTES_INTERFACE',
    fnd_message.get_string('PON','PON_AUCTS_ATTR_WEIGHT'),
    'PON_AUC_WEIGHT_RANGE',
    selected_weight
  )

  --validate that the score is not entered for Display only attributes.

  when
  (
    selected_auction_line_number = -1
    and  (selected_aTTR_MAX_SCORE is not null and selected_ATTR_MAX_SCORE <> 0)
    and selected_DISPLAY_ONLY_FLAG = 'Y'
    AND Nvl(selected_action,'INSERT') = 'INSERT'
  )
  then into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  values
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_ATTRIBUTES_INTERFACE',
    fnd_message.get_string('PON','PON_AUC_SCORE'),
    'PON_AUCTS_DISP_ATTR_NO_SCORES',
    selected_ATTR_MAX_SCORE
  )

  -- validate that the score is  greater than zero.
  when
  (
    selected_auction_line_number = -1
    and  selected_ATTR_MAX_SCORE is not null
    and selected_ATTR_MAX_SCORE < 0
    AND Nvl(selected_action,'INSERT') = 'INSERT'
  )
  then into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  values
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_ATTRIBUTES_INTERFACE',
    fnd_message.get_string('PON','PON_AUC_SCORE'),
    'PON_AUC_INVALID_MAXSCORE_RANGE',
    selected_ATTR_MAX_SCORE
  )

  SELECT
    pai.batch_id selected_batch_id,
    pai.interface_line_id selected_interface_line_id,
    pai.weight selected_weight,
    pai.auction_line_number selected_auction_line_number,
    pai.attr_max_score selected_attr_max_score,
    pai.display_only_flag selected_display_only_flag,
    pai.action selected_action

  from
    pon_auc_attributes_interface pai

  where
    pai.batch_id = p_batch_id;

EXCEPTION
WHEN OTHERS THEN
NULL;

END validate_header_attributes_api;

PROCEDURE validate_attributes_api(
  p_source		VARCHAR2,
  p_batch_id		NUMBER,
  p_party_id		NUMBER,
  p_attr_type_header    BOOLEAN
) AS
  l_auction_header_id	pon_auc_attributes_interface.auction_header_id%TYPE;
  l_message_suffix	VARCHAR2(2);
  l_group_pref_name VARCHAR2(40);
  l_group_lookup_type VARCHAR2(40);
  l_attr_type_header VARCHAR2(1);
BEGIN

  IF (p_attr_type_header) THEN

    l_attr_type_header := 'Y';
  ELSE

    l_attr_type_header := 'N';
  END IF;

  -- init vars

  BEGIN
    select max(pai.auction_header_id)
    into l_auction_header_id
    from pon_auc_attributes_interface pai
    where pai.batch_id = p_batch_id;

    select pon_auction_pkg.get_message_suffix(doc.internal_name)
    into l_message_suffix
    from pon_auction_headers_all pah,
	 pon_auc_doctypes doc
    where pah.auction_header_id = l_auction_header_id
      and pah.doctype_id = doc.doctype_id;
  EXCEPTION
    WHEN no_data_found THEN
      l_message_suffix := NULL;
      l_auction_header_id := NULL;
      l_group_pref_name := NULL;
      l_group_lookup_type := NULL;
  END;

  -- GROUP Check Starts.
  -- default GROUP_CODE as General for lines with group_name as null.
  IF ( not p_attr_type_header ) THEN
      l_group_pref_name := 'LINE_ATTR_DEFAULT_GROUP';
      l_group_lookup_type := 'PON_LINE_ATTRIBUTE_GROUPS';
  END IF;


  -- Populate data
  -- RESPONSE_TYPE
  -- bug 3373002
  -- need to compare apple with apple, response type values are from fnd messages
  -- so also validate against messages, not lookups.
  IF ( p_attr_type_header ) THEN
   update pon_auc_attributes_interface pai
   set response_type = decode(response_type_name,
           fnd_message.get_string('PON','PON_AUCTS_REQUIRED'), 'REQUIRED',
           fnd_message.get_string('PON','PON_AUCTS_OPTIONAL'), 'OPTIONAL',
           fnd_message.get_string('PON','PON_AUCTS_DISPLAY_ONLY'), 'DISPLAY_ONLY',
           fnd_message.get_string('PON','PON_AUCTS_INTERNAL'), 'INTERNAL',
           null)
   where pai.batch_id = p_batch_id
    and pai.response_type_name is not null;
  ELSE
   update pon_auc_attributes_interface pai
   set response_type = decode(response_type_name,
           fnd_message.get_string('PON','PON_AUCTS_REQUIRED'), 'REQUIRED',
           fnd_message.get_string('PON','PON_AUCTS_OPTIONAL'), 'OPTIONAL',
           fnd_message.get_string('PON','PON_AUCTS_DISPLAY_ONLY'), 'DISPLAY_ONLY',
           null)
   where pai.batch_id = p_batch_id
    and pai.response_type_name is not null;
  END IF;

  -- MANDATORY_FLAG
  -- DISPLAY_ONLY_FLAG
  -- INTERNAL_ATTR_FLAG
  update
    pon_auc_attributes_interface
  set
    mandatory_flag = decode(response_type,'REQUIRED','Y','N'),
    display_only_flag = decode(response_type,'DISPLAY_ONLY','Y','N'),
    internal_attr_flag  = decode(response_type,'INTERNAL','Y','N')
  where
    batch_id = p_batch_id;


  -- Not to be Done for Header Section.
  IF ( not p_attr_type_header ) THEN
    update pon_auc_attributes_interface paai
    set paai.GROUP_CODE = (select nvl(ppp.preference_value,'GENERAL')
                              from pon_party_preferences ppp
                              where ppp.app_short_name = 'PON'
                              and ppp.preference_name = l_group_pref_name
                              and ppp.party_id = p_party_id)
    where paai.batch_id = p_batch_id
    and paai.GROUP_NAME is NULL
    AND paai.auction_line_number <> -1;


-- populate GROUP_CODE. Note that the comparison is case sensitive.

  update pon_auc_attributes_interface paai
  set paai.GROUP_CODE = (
    select lookup_code
    from fnd_lookup_values attrGrpFlv
    where lookup_type = l_group_lookup_type
    --where lookup_type = 'PON_HEADER_ATTRIBUTE_GROUPS'
    and meaning = paai.GROUP_NAME
    and attrGrpFlv.LANGUAGE = userenv('LANG')
    and attrGrpFlv.view_application_id = 0
    and attrGrpFlv.security_group_id = 0
    and attrGrpFlv.enabled_flag = 'Y'
    and nvl(attrGrpFlv.start_date_active,SYSDATE) <= SYSDATE
    and nvl(attrGrpFlv.end_date_active,SYSDATE) > SYSDATE-1
  )
  where paai.batch_id = p_batch_id
  and paai.GROUP_NAME is not NULL
  AND paai.auction_line_number <> -1;

  ELSE
    -- For Header Case, if the Group Name is null, default General.
  update pon_auc_attributes_interface paai
  set paai.GROUP_NAME = (
    select meaning
    from fnd_lookup_values attrGrpFlv
    where attrGrpFlv.lookup_type = 'PON_HEADER_ATTRIBUTE_GROUPS'
    and attrGrpFlv.lookup_code = 'GENERAL'
    and attrGrpFlv.LANGUAGE = userenv('LANG')
    and attrGrpFlv.view_application_id = 0
    and attrGrpFlv.security_group_id = 0
    and attrGrpFlv.enabled_flag = 'Y'
    and nvl(attrGrpFlv.start_date_active,SYSDATE) <= SYSDATE
    and nvl(attrGrpFlv.end_date_active,SYSDATE) > SYSDATE-1
  )
  where paai.batch_id = p_batch_id
  and paai.GROUP_NAME is NULL
  AND paai.auction_line_number = -1;

  END IF;

  ----------------  Validations start here ------------

  INSERT ALL

  -- Datatype
  WHEN
  (
    selected_datatype is NULL
    AND Nvl(selected_action,'INSERT') = 'INSERT'
  )
  THEN into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  VALUES
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_ATTRIBUTES_INTERFACE',
    fnd_message.get_string('PON','PON_AUCTS_ATTR_DATATYPE'),
    decode(l_group_pref_name, 'LINE_ATTR_DEFAULT_GROUP',
      'PON_AUCTS_ATTR_INVALID_TYPE', 'PON_AUCTS_REQ_INVALID_TYPE'),
    selected_datatype
  )

  -- Response Type

  WHEN
  (
    selected_response_type is NULL
    AND Nvl(selected_action,'INSERT')='INSERT'
  )
  THEN into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  VALUES
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_ATTRIBUTES_INTERFACE',
    decode(l_group_pref_name,'LINE_ATTR_DEFAULT_GROUP',pon_auction_pkg.getMessage('PON_AUCTS_BID_RESPONSE',l_message_suffix),pon_auction_pkg.getMessage('PON_AUCTS_TYPE')),
    'PON_CAT_INVALID_VALUE',
    selected_response_type_name
  )

  -- Display Target Flag

  WHEN
  (
    nvl(selected_display_target_flag,'N') not in ('Y','N')
    AND Nvl(selected_action,'INSERT') = 'INSERT'
  )

  THEN into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  values
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_ATTRIBUTES_INTERFACE',
    fnd_message.get_string('PON','PON_AUCTS_ATTR_D_TARGET'),
    'PON_AUCTS_INV_PR_QT_VAL',
    selected_display_target_flag
  )

  -- validate datatype [lookup_type = PON_AUCTION_ATTRIBUTE_TYPE]

  when
  (
    selected_datatype not in (
	  select lookup_code
	  from fnd_lookups
	  where lookup_type = 'PON_AUCTION_ATTRIBUTE_TYPE'
    	)
    AND Nvl(selected_action,'INSERT') = 'INSERT'
  )
  then into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  values
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_ATTRIBUTES_INTERFACE',
    fnd_message.get_string('PON','PON_AUCTS_ATTR_DATATYPE'),
    decode(l_group_pref_name, 'LINE_ATTR_DEFAULT_GROUP',
      'PON_AUCTS_ATTR_INVALID_TYPE', 'PON_AUCTS_REQ_INVALID_TYPE'),
    selected_datatype
  )

  -- validate display target flag is Y/N
  when
  (
    nvl(selected_display_target_flag,'N') not in ('Y','N')
    AND Nvl(selected_action,'INSERT')='INSERT'
  )
  then into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  values
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_ATTRIBUTES_INTERFACE',
    fnd_message.get_string('PON','PON_AUCTS_ATTR_D_TARGET'),
    'PON_AUCTS_INV_PR_QT_VAL',
    selected_display_target_flag
  )

  when
  (
    selected_display_target_flag = 'Y'
    and selected_value is NULL
    AND Nvl(selected_action,'INSERT') = 'INSERT'
  )
  then into pon_interface_errors
  (
	BATCH_ID,
	INTERFACE_LINE_ID,
	TABLE_NAME,
	COLUMN_NAME,
	ERROR_MESSAGE_NAME,
	ERROR_VALUE
  )
  values
  (
	selected_batch_id,
	selected_interface_line_id,
	'PON_AUC_ATTRIBUTES_INTERFACE',
    fnd_message.get_string('PON','PON_AUCTS_TARGET_VALUE'),
	'PON_AUCTS_ATTR_SHOW_TARGET',
	selected_value
  )

  -- validate value given if display_only = Y
  when
  (
    selected_display_only_flag = 'Y'
    and selected_value is null
  -- Bug 6957765
  and  nvl(selected_display_target_flag,'N') = 'Y'
  AND Nvl(selected_action,'INSERT') = 'INSERT'
  )
  then into pon_interface_errors
  (
	BATCH_ID,
	INTERFACE_LINE_ID,
	TABLE_NAME,
	COLUMN_NAME,
	ERROR_MESSAGE_NAME,
	ERROR_VALUE
  )
  values
  (
	selected_batch_id,
	selected_interface_line_id,
	'PON_AUC_ATTRIBUTES_INTERFACE',
	pon_auction_pkg.getMessage('PON_AUCTS_ATTR_TARGET',l_message_suffix),
	decode(l_group_pref_name, 'LINE_ATTR_DEFAULT_GROUP',
      'PON_AUCTS_ATTR_DISPLAY_TARGET', 'PON_AUCTS_REQ_DISPLAY_TARGET'),
	selected_value
  )

  -- Attribute Name

  when
  (
    selected_attribute_name is NULL
    AND Nvl(selected_action,'INSERT') = 'INSERT'
  )
  then into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  values
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_ATTRIBUTES_INTERFACE',
    decode(l_group_pref_name, 'LINE_ATTR_DEFAULT_GROUP', fnd_message.get_string('PON','PON_AUCTS_ATTR'), fnd_message.get_string('PON', 'PON_AUC_REQUIREMENT')),
    'PON_FIELD_MUST_BE_ENTERED',
    selected_attribute_name
  )

  -- required field checks
  -- SEQUENCE_NUMBER -- should never be displayed to user
  -- Do not do this check for Header attributes. We will populate the sequence
  -- when we copy them over to the AuctionAttributesVO
  when
  (
    l_attr_type_header = 'N' AND
    selected_sequence_number is NULL
    AND Nvl(selected_action,'INSERT') = 'INSERT'
  )
  then into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  values
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_ATTRIBUTES_INTERFACE',
    'SEQUENCE_NUMBER',
    'PON_CAT_DISP_SEQ_M',
    selected_sequence_number
  )

-- To insert errors for the group which are invalid.
  when
  (
    selected_group_code is null
    AND l_attr_type_header = 'N'
    AND Nvl(selected_action,'INSERT') = 'INSERT'
    AND selected_auction_line_num <> -1  -- bug 16801086
  )
  then into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  values
  (
    selected_batch_id,
    selected_interface_line_id,
    'PON_AUC_ATTRIBUTES_INTERFACE',
    fnd_message.get_string('PON','PON_AUCTS_GROUP'),
    'PON_AUCTS_INVALID_GROUP',
    selected_group_name
  )

  -- validate display target == N if attribute type is Internal
  when
  (
    nvl(selected_display_target_flag,'N') = 'Y'
    and selected_internal_attr_flag = 'Y'
    and l_attr_type_header = 'Y'
    AND Nvl(selected_action,'INSERT') = 'INSERT'
  )
  then into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  values
  (
    selected_batch_id,
    selected_interface_line_id,
   'PON_AUC_ATTRIBUTES_INTERFACE',
    fnd_message.get_string('PON','PON_AUCTS_ATTR_D_TARGET'),
    'PON_AUC_INTERNAL_ATT_ERROR',
    fnd_message.get_string('PON','PON_CORE_NO')
  )
  -- Bug 16801089
  -- Adding New Validation for Weight
  when
  (
    selected_scoring_type='NONE'
    AND ((selected_interface_line_id>0 AND Nvl(selected_weight,0)>0) OR (selected_interface_line_id=-1 AND selected_weight IS NOT null))
    AND Nvl(selected_action,'INSERT') = 'INSERT'
  )
  then into pon_interface_errors
  (
    BATCH_ID,
    INTERFACE_LINE_ID,
    TABLE_NAME,
    COLUMN_NAME,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE
  )
  values
  (
    selected_batch_id,
    selected_interface_line_id,
   'PON_AUC_ATTRIBUTES_INTERFACE',
    fnd_message.get_string('PON','PON_AUCTS_ATTR_WEIGHT'),
    'PON_AUC_INVALID_WEIGHT',
    fnd_message.get_string('PON','PON_CORE_NO')
  )

  SELECT
    pai.batch_id selected_batch_id,
    pai.interface_line_id selected_interface_line_id,
    pai.datatype selected_datatype,
    pai.value selected_value,
    pai.display_target_flag selected_display_target_flag,
    pai.display_only_flag selected_display_only_flag,
    pai.response_type_name selected_response_type_name,
    pai.response_type selected_response_type,
    pai.attribute_name selected_attribute_name,
    pai.sequence_number selected_sequence_number,
    pai.group_name selected_group_name,
    pai.scoring_type selected_scoring_type,
    pai.weight selected_weight,
    pai.group_code selected_group_code,
    pai.internal_attr_flag selected_internal_attr_flag,
    pai.action selected_action,
    pai.auction_line_number selected_auction_line_num

  from
    pon_auc_attributes_interface pai
  where
    pai.batch_id = p_batch_id;

  -- perform duplicate checks
  IF ( p_attr_type_header ) THEN
    insert into pon_interface_errors (
	BATCH_ID,
	INTERFACE_LINE_ID,
	TABLE_NAME,
	COLUMN_NAME,
	ERROR_MESSAGE_NAME,
	ERROR_VALUE
    )
    select
	pai1.batch_id,
	pai1.interface_line_id,
	'PON_AUC_ATTRIBUTES_INTERFACE',
	fnd_message.get_string('PON','PON_AUC_REQUIREMENT'),
	'PON_REQUIREMENT_DUPLICATE_ATT',
	pai1.attribute_name
    from pon_auc_attributes_interface pai1,
       pon_auc_attributes_interface pai2
    where pai1.batch_id = p_batch_id
    and pai1.batch_id = pai2.batch_id
    and pai1.auction_line_number = pai2.auction_line_number
    and upper(pai1.attribute_name) = upper(pai2.attribute_name)
    and pai1.interface_line_id <> pai2.interface_line_id
    AND Nvl(pai1.action,'INSERT')='INSERT';
  ELSE
    insert into pon_interface_errors (
	BATCH_ID,
	INTERFACE_LINE_ID,
	TABLE_NAME,
	COLUMN_NAME,
	ERROR_MESSAGE_NAME,
	ERROR_VALUE
    )
    select
	pai1.batch_id,
	pai1.interface_line_id,
	'PON_AUC_ATTRIBUTES_INTERFACE',
	fnd_message.get_string('PON','PON_AUCTS_ATTR'),
	'PON_DUPLICATE_WARNING_ATTR',
	pai1.attribute_name
    from pon_auc_attributes_interface pai1,
       pon_auc_attributes_interface pai2
    where pai1.batch_id = p_batch_id
    and pai1.batch_id = pai2.batch_id
    and pai1.interface_line_id = pai2.interface_line_id
    and upper(pai1.attribute_name) = upper(pai2.attribute_name)
    and pai1.sequence_number <> pai2.sequence_number
    AND Nvl(pai1.action,'INSERT')='INSERT';
  END IF;

  -- duplicate check against the allready saved header attributes.
  IF ( p_attr_type_header ) THEN
    insert into pon_interface_errors (
	BATCH_ID,
	INTERFACE_LINE_ID,
	TABLE_NAME,
	COLUMN_NAME,
	ERROR_MESSAGE_NAME,
	ERROR_VALUE
    )
    select
	pai1.batch_id,
	pai1.interface_line_id,
	'PON_AUC_ATTRIBUTES_INTERFACE',
	fnd_message.get_string('PON','PON_AUC_REQUIREMENT'),
	'PON_REQUIREMENT_DUPLICATE_ATT',
	pai1.attribute_name
    from pon_auc_attributes_interface pai1,
       pon_auction_attributes paa
    where pai1.batch_id = p_batch_id
    and paa.auction_header_id = pai1.auction_header_id
    and pai1.auction_line_number = -1
    and paa.line_number = pai1.auction_line_number
    and upper(pai1.attribute_name) = upper(paa.attribute_name)
    AND Nvl(pai1.action,'INSERT')='INSERT';
  END IF;

END validate_attributes_api;
  -----------------------------------------------------------------------
  --Start of Comments
  --Name: insert_error_interface
  --Description : insert a record in pon_interface_errors table for validation failures
  --Parameters:
  --IN:
  --  l_BATCH_ID
  --  l_INTERFACE_LINE_ID
  --  l_TABLE_NAME
  --  l_COLUMN_NAME
  -- l_ERROR_MESSAGE_NAME
  -- l_ERROR_VALUE
  --OUT:
  --Returns:
  --Notes:
  --Testing:
  --End of Comments
  ------------------------------------------------------------------------
PROCEDURE INSERT_ERROR_INTERFACE
  (
    l_BATCH_ID           IN PON_INTERFACE_ERRORS.BATCH_ID%TYPE,
    l_INTERFACE_LINE_ID  IN PON_INTERFACE_ERRORS.INTERFACE_LINE_ID%TYPE,
    l_TABLE_NAME         IN PON_INTERFACE_ERRORS.TABLE_NAME%TYPE,
    l_COLUMN_NAME        IN PON_INTERFACE_ERRORS.COLUMN_NAME%TYPE,
    l_ERROR_MESSAGE_NAME IN PON_INTERFACE_ERRORS.ERROR_MESSAGE_NAME%TYPE,
    l_ERROR_VALUE        IN PON_INTERFACE_ERRORS.ERROR_VALUE%TYPE)
                         IS
  l_status NUMBER;
BEGIN
   INSERT
     INTO pon_interface_errors
    (
      BATCH_ID          ,
      INTERFACE_LINE_ID ,
      TABLE_NAME        ,
      COLUMN_NAME       ,
      ERROR_MESSAGE_NAME,
      ERROR_VALUE
    )
    VALUES
    (
      l_BATCH_ID          ,
      l_INTERFACE_LINE_ID ,
      l_TABLE_NAME        ,
      l_COLUMN_NAME       ,
      l_ERROR_MESSAGE_NAME,
      l_ERROR_VALUE
    ) ;
END INSERT_ERROR_INTERFACE;
-----------------------------------------------------------------------
--Start of Comments
--Name: create_emd_receipt_and_apply
--Description : Validate the requirement before inserting
--Parameters:
--IN:
--  p_source
--  p_batch_id
--  p_commit
--  p_party_id
-- p_in_rec
-- p_in_rec.l_SCORING_METHOD
--OUT:
--  x_return_status      Return status SUCCESS /ERROR
--Returns:
--Notes:
--Testing:
--End of Comments
------------------------------------------------------------------------
PROCEDURE VALIDATE_REQUIREMENT
  (
    p_source   VARCHAR2,
    p_batch_id NUMBER,
    p_party_id NUMBER,
    p_in_rec IN ATTRIBUTES_VALUES_VALIDATION,
    --p_in_rec.l_SCORING_METHOD PON_AUCTION_ATTRIBUTES.SCORING_METHOD%TYPE,
    x_return_status OUT NOCOPY VARCHAR
  )
                                                             IS
  l_TABLE_NAME PON_INTERFACE_ERRORS.TABLE_NAME%TYPE          :='PON_AUC_ATTRIBUTES_INTERFACE';
  --p_in_rec.l_KNOCKOUT_SCORE PON_AUCTION_ATTRIBUTES.KNOCKOUT_SCORE%TYPE:=NULL;
  l_status NUMBER;
BEGIN
  x_return_status := 'Y';
  /* If response type is optional we can allow only Manual or None scoring methods */
  IF(p_in_rec.l_RESPONSE_TYPE = 'OPTIONAL')THEN
    IF(p_in_rec.l_SCORING_METHOD ='AUTOMATIC')THEN
      insert_error_interface
      (
        p_in_rec.l_BATCH_ID,p_in_rec.l_INTERFACE_LINE_ID,l_TABLE_NAME,pon_auction_pkg.getMessage('PON_AUCTS_TYPE'),'PON_REQUIREMENT_ERR_15',p_in_rec.l_RESPONSE_TYPE
      );
      x_return_status := 'N';
    END IF;
  END IF;
  /* If scoring method is null then the weight, knockout score, max score must be null*/
  IF(p_in_rec.l_SCORING_METHOD IS NULL)THEN
    IF(p_in_rec.l_WEIGHT IS NOT NULL) THEN
      insert_error_interface
      (
        p_in_rec.l_BATCH_ID,p_in_rec.l_INTERFACE_LINE_ID,l_TABLE_NAME,pon_auction_pkg.getMessage('PON_AUCTS_TYPE'),'PON_REQUIREMENT_ERR_2',p_in_rec.l_SCORING_METHOD
      );
      x_return_status := 'N';
    END IF;
    IF(p_in_rec.l_KNOCKOUT_SCORE IS NOT NULL) THEN
      insert_error_interface
      (
        p_in_rec.l_BATCH_ID,p_in_rec.l_INTERFACE_LINE_ID,l_TABLE_NAME,pon_auction_pkg.getMessage('PON_AUCTS_TYPE'),'PON_REQUIREMENT_ERR_3',p_in_rec.l_SCORING_METHOD
      );
      x_return_status := 'N';
    END IF;
    IF(p_in_rec.l_ATTR_MAX_SCORE IS NOT NULL) THEN
      insert_error_interface
      (
        p_in_rec.l_BATCH_ID,p_in_rec.l_INTERFACE_LINE_ID,l_TABLE_NAME,pon_auction_pkg.getMessage('PON_AUCTS_TYPE'),'PON_REQUIREMENT_ERR_4',p_in_rec.l_SCORING_METHOD
      );
      x_return_status := 'N';
    END IF;
  END IF;
  /* If response type is internal then scoring method cann't be automatic*/
  IF(p_in_rec.l_RESPONSE_TYPE = 'INTERNAL')  THEN
    IF(p_in_rec.l_SCORING_METHOD ='AUTOMATIC') THEN
      insert_error_interface
      (
        p_in_rec.l_BATCH_ID,p_in_rec.l_INTERFACE_LINE_ID,l_TABLE_NAME,pon_auction_pkg.getMessage('PON_AUCTS_TYPE'),'PON_REQUIREMENT_ERR_5',p_in_rec.l_RESPONSE_TYPE
      );
      x_return_status := 'N';
    END IF;
  END IF;
  /* If response type is diaplay only or internal then scoring type cann't be LOV/RANGE */
  IF(p_in_rec.l_RESPONSE_TYPE = 'DISPLAY_ONLY' OR p_in_rec.l_RESPONSE_TYPE = 'INTERNAL') THEN
    IF(p_in_rec.l_SCORING_TYPE='LOV' OR p_in_rec.l_SCORING_TYPE='RANGE')  THEN
      insert_error_interface
      (
        p_in_rec.l_BATCH_ID,p_in_rec.l_INTERFACE_LINE_ID,l_TABLE_NAME,pon_auction_pkg.getMessage('PON_AUCTS_TYPE'),'PON_REQUIREMENT_ERR_6',p_in_rec.l_RESPONSE_TYPE
      );
      x_return_status := 'N';
    END IF;
  END IF;
  /* If DATATYPE is URL then scoring type cannot be LOV/RANGE and also scoring method cannot be automatic */
  IF(p_in_rec.l_DATATYPE = 'URL') THEN
    IF(p_in_rec.l_SCORING_TYPE='LOV' OR p_in_rec.l_SCORING_TYPE='RANGE') THEN
      insert_error_interface
      (
        p_in_rec.l_BATCH_ID,p_in_rec.l_INTERFACE_LINE_ID,l_TABLE_NAME,fnd_message.get_string('PON','PON_AUCTS_ATTR_DATATYPE'),'PON_REQUIREMENT_ERR_7',p_in_rec.l_DATATYPE
      );
      x_return_status := 'N';
    END IF;
    IF(p_in_rec.l_SCORING_METHOD='AUTOMATIC') THEN
      insert_error_interface
      (
        p_in_rec.l_BATCH_ID,p_in_rec.l_INTERFACE_LINE_ID,l_TABLE_NAME,fnd_message.get_string('PON','PON_AUCTS_ATTR_DATATYPE'),'PON_REQUIREMENT_ERR_8',p_in_rec.l_DATATYPE
      );
      x_return_status := 'N';
    END IF;
  END IF;
  /* Automatic scoring will only have for Required type */
  IF(p_in_rec.l_RESPONSE_TYPE <> 'REQUIRED' AND p_in_rec.l_SCORING_METHOD='AUTOMATIC') THEN
    insert_error_interface
    (
      p_in_rec.l_BATCH_ID,p_in_rec.l_INTERFACE_LINE_ID,l_TABLE_NAME,pon_auction_pkg.getMessage('PON_AUCTS_TYPE'),'PON_REQUIREMENT_ERR_9',p_in_rec.l_RESPONSE_TYPE
    );
    x_return_status := 'N';
  END IF;
  /* Manual scoring method cannot have scoring type LOV/RANGE and ATTR_MAX_SCORE is must*/
  IF(p_in_rec.l_SCORING_METHOD ='MANUAL') THEN
    IF(p_in_rec.l_SCORING_TYPE='LOV' OR p_in_rec.l_SCORING_TYPE='RANGE') THEN
      insert_error_interface
      (
        p_in_rec.l_BATCH_ID,p_in_rec.l_INTERFACE_LINE_ID,l_TABLE_NAME,pon_auction_pkg.getMessage('PON_AUCTS_TYPE'),'PON_REQUIREMENT_ERR_10',p_in_rec.l_SCORING_METHOD
      );
      x_return_status := 'N';
    END IF;
    IF(p_in_rec.l_ATTR_MAX_SCORE IS NULL OR p_in_rec.l_ATTR_MAX_SCORE = 0) THEN
      insert_error_interface
      (
        p_in_rec.l_BATCH_ID,p_in_rec.l_INTERFACE_LINE_ID,l_TABLE_NAME,fnd_message.get_string('PON','PON_AUC_SCORE'),'PON_REQUIREMENT_ERR_14',p_in_rec.l_SCORING_METHOD
      );
      x_return_status := 'N';
    END IF;
  END IF;
  /* If scoring method is automatic then the score need to be exsist*/
  IF(p_in_rec.l_SCORING_METHOD='AUTOMATIC') THEN
    BEGIN
        SELECT DISTINCT 'Y' INTO x_return_status FROM pon_attribute_scores WHERE auction_header_id=p_in_rec.l_auction_header_id AND attribute_sequence_number=p_in_rec.l_sequence_number;
        EXCEPTION
        WHEN No_Data_Found THEN
       insert_error_interface
      (
        p_in_rec.l_BATCH_ID,p_in_rec.l_INTERFACE_LINE_ID,l_TABLE_NAME,fnd_message.get_string('PON','PON_AUC_SCORE'),'PON_REQUIREMENT_ERR_11',p_in_rec.l_SCORING_METHOD
      );
      x_return_status := 'N';
    END;
  /* Text datatype cannot have range scoring type and date/num datatype cannot have LOV scoring type */
  IF((p_in_rec.l_SCORING_TYPE <>'LOV' AND p_in_rec.l_DATATYPE = 'TXT') OR (p_in_rec.l_SCORING_TYPE<>'RANGE' AND (p_in_rec.l_DATATYPE = 'NUM' OR p_in_rec.l_DATATYPE = 'DAT'))) THEN
    insert_error_interface
    (
      p_in_rec.l_BATCH_ID,p_in_rec.l_INTERFACE_LINE_ID,l_TABLE_NAME,fnd_message.get_string('PON','PON_AUC_SCORE'),'PON_DATA_SCORE_MISMATCH',p_in_rec.l_SCORING_TYPE
    );
    x_return_status := 'N';
  END IF;
  END IF;

  /* If knockout score is not null then max score cannot be null and knockout score cannot be greater than max score and cannot be less than 0*/
  IF(p_in_rec.l_KNOCKOUT_SCORE IS NOT NULL) THEN
    IF(p_in_rec.l_ATTR_MAX_SCORE IS NULL OR p_in_rec.l_KNOCKOUT_SCORE > p_in_rec.l_ATTR_MAX_SCORE OR p_in_rec.l_KNOCKOUT_SCORE< 0) THEN
      insert_error_interface
      (
        p_in_rec.l_BATCH_ID,p_in_rec.l_INTERFACE_LINE_ID,l_TABLE_NAME,fnd_message.get_string('PON','PON_AUC_SCORE'),'PON_REQUIREMENT_ERR_12',p_in_rec.l_KNOCKOUT_SCORE
      );
      x_return_status := 'N';
    END IF;
  END IF;

END VALIDATE_REQUIREMENT;

END pon_auc_interface_table_pkg;

/
