--------------------------------------------------------
--  DDL for Package Body AP_WEB_DFLEX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_DFLEX_PKG" AS
/* $Header: apwdflxb.pls 120.14.12010000.5 2009/05/05 08:05:27 dsadipir ship $ */

--
-- Record definition for ap_expense_report_params.
-- Used locally to this file.
--

TYPE ParameterRec IS RECORD (
  parameter_id          NUMBER,
  prompt                AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_webFriendlyPrompt,
  prompt_code		AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_prompt,
  calculate_amount_flag VARCHAR2(1),
  pa_expenditure_type   VARCHAR2(30),
  amount_includes_tax   VARCHAR2(1));

TYPE ParameterRec_A IS TABLE OF ParameterRec
  INDEX BY BINARY_INTEGER;

--
-- Constants
--


C_FuncCode              CONSTANT VARCHAR2(50) := 'AP_WEB_EXPENSES';
C_AppShortName          CONSTANT VARCHAR2(10) := 'SQLAP';
C_LinesDescFlexName     CONSTANT VARCHAR2(50) := 'AP_EXPENSE_REPORT_LINES';
C_SpecialCheckboxValueSet CONSTANT VARCHAR2(100) := 'AP_SRS_YES_NO_MAND';

C_DefaultTextSize       CONSTANT NUMBER := 15;
C_MaxTextSize           CONSTANT NUMBER := 20;
C_DefaultTextMaxLength  CONSTANT NUMBER := 0;
C_ProjectNumberMaxLength  CONSTANT NUMBER := 30;
c_taskNumberMaxLength      CONSTANT NUMBER := 25;

C_InputObjectPrefix     CONSTANT VARCHAR2(10) := 'FLEX';
C_InputPseudoObjectPrefix
                        CONSTANT VARCHAR2(10) := 'PFLEX';

C_ValidIndependent      CONSTANT VARCHAR2(50) := 'I';
C_ValidNone             CONSTANT VARCHAR2(50) := 'N';
C_ValidTable            CONSTANT VARCHAR2(50) := 'F';

C_DefaultTypeConstant   CONSTANT VARCHAR2(50) := 'C';

C_ValidFormatTypeNum    CONSTANT VARCHAR2(50) := 'N';
C_ValidFormatTypeChar   CONSTANT VARCHAR2(50) := 'C';


C_CheckboxInputObject   CONSTANT VARCHAR2(20) := 'CHECKBOX';
C_HiddenInputObject     CONSTANT VARCHAR2(20) := 'HIDDEN';
C_SelectInputObject     CONSTANT VARCHAR2(20) := 'SELECT';
C_TextInputObject       CONSTANT VARCHAR2(20) := 'TEXT';

C_Yes                   CONSTANT VARCHAR2(1) := 'Y';
C_No                    CONSTANT VARCHAR2(1) := 'N';


C_AttributeColSize      CONSTANT NUMBER := 150;

C_GLOBAL CONSTANT varchar2(6):='GLOBAL';

C_CalcAmount_Prompt     CONSTANT NUMBER := 30;
C_TaxName_Prompt        CONSTANT NUMBER := 32;
C_TaxNameIncl_Prompt    CONSTANT NUMBER := 33;
C_TaxNameExcl_Prompt    CONSTANT NUMBER := 34;
C_ProjectNumber_Prompt  CONSTANT NUMBER := 35;
C_TaskNumber_Prompt     CONSTANT NUMBER := 36;

-- Number of pseudo context flexfields (amount includes tax, tax name)
C_PseudoSegProjectNumberOffset CONSTANT NUMBER := 1;
C_PseudoSegTaskNumberOffset    CONSTANT NUMBER := 2;
C_PseudoSegAmtInclTaxOffset    CONSTANT NUMBER := 1;
C_PseudoSegTaxNameOffset       CONSTANT NUMBER := 2;
C_NumMaxPseudoFlexField        CONSTANT NUMBER := 4;
C_NumTaxPseudoFlexField        CONSTANT NUMBER := 2;
C_NumProjectPseudoFlexField    CONSTANT NUMBER := 2;

FUNCTION BOOL2STRING(p_bBool IN BOOLEAN)
RETURN VARCHAR2
IS
BEGIN
  IF p_bBool THEN
    RETURN('true');
  ELSE
    RETURN('false');
  END IF;
  RETURN ('""');
END Bool2String;


-------------------------------------------------------------------------------
FUNCTION Minimum(A IN NUMBER, B IN NUMBER) RETURN NUMBER
-------------------------------------------------------------------------------
IS
BEGIN
  IF A < B THEN
    RETURN A;
  ELSE
    RETURN B;
  END IF;
END Minimum;

------------------------------------------------------------------------------
FUNCTION ParameterRecAContains(
                       P_Prompt          IN VARCHAR2,
                       P_PromptArray     IN ParameterRec_A,
                       P_PromptArraySize IN NUMBER)
RETURN BOOLEAN
------------------------------------------------------------------------------
IS
  I NUMBER;
BEGIN
  FOR I IN 1 .. P_PromptArraySize LOOP
    IF P_Prompt = P_PromptArray(I).prompt THEN
      RETURN TRUE;
    END IF;
  END LOOP;
  RETURN FALSE;
END ParameterRecAContains;

-------------------------------------------------------------------------------
FUNCTION IsSegmentWebEnabled(P_Segments IN FND_DFLEX.SEGMENTS_DR,
                            P_Index IN NUMBER)
RETURN BOOLEAN
-------------------------------------------------------------------------------
IS
BEGIN
  RETURN(P_Segments.description(P_Index) IS NOT NULL);
END IsSegmentWebEnabled;

-------------------------------------------------------------------------------
FUNCTION IsSegmentValidType(P_ValueSetInfo IN FND_VSET.VALUESET_R)
RETURN BOOLEAN
-------------------------------------------------------------------------------
IS
BEGIN
  RETURN P_ValueSetInfo.validation_type = C_ValidIndependent OR
         P_ValueSetInfo.validation_type = C_ValidNone OR
         P_ValueSetInfo.validation_type = C_ValidTable;
END IsSegmentValidType;

-------------------------------------------------------------------------------
FUNCTION IsSegmentRendered(P_Segments IN FND_DFLEX.SEGMENTS_DR,
                           P_SegIndex IN NUMBER,
                           P_ValueSetInfo IN FND_VSET.VALUESET_R)
RETURN BOOLEAN
-------------------------------------------------------------------------------
IS
BEGIN
  RETURN P_Segments.is_displayed(P_SegIndex) AND
           IsSegmentWebEnabled(P_Segments, P_SegIndex) AND
           IsSegmentValidType(P_ValueSetInfo);
END IsSegmentRendered;


-------------------------------------------------------------------------------
PROCEDURE GetEnabledSegments(P_Segments FND_DFLEX.SEGMENTS_DR,
                             Map_Array OUT NOCOPY AP_WEB_PARENT_PKG.Number_Array,
                             P_NumOfEnabledSegments OUT NOCOPY NUMBER)
-------------------------------------------------------------------------------
IS
  --
  -- Returns the indexes of the enabled segments from P_Segments in Map_Array
  -- and the number of enabled segments are returned in P_NumOfEnabledSegments.
  --

  I NUMBER;
  V_NumElem NUMBER;
BEGIN

  V_NumElem := 0;
  FOR I IN 1..P_Segments.nsegments LOOP
    IF P_Segments.is_enabled(I) THEN
      V_NumElem := V_NumElem + 1;
      Map_Array(V_NumElem) := I;
    END IF;
  END LOOP;
  P_NumOfEnabledSegments := V_NumElem;

END GetEnabledSegments;

-------------------------------------------------------------------------------
PROCEDURE GetIndepSegmentEnabledValues(P_ValueSetInfo   IN FND_VSET.VALUESET_R,
                                       P_NumOfTableElem IN OUT NOCOPY NUMBER,
                                       P_PoplistArray   IN OUT NOCOPY PoplistValues_A)
-------------------------------------------------------------------------------
IS
  --
  -- Returns the enabled independent validation values for the given
  -- valueset in the P_PoplistArray.
  --

  V_ValueInfo        FND_VSET.VALUE_DR;
  V_NumValueSetValue NUMBER;
  V_Found            BOOLEAN;
  V_CurrentCallingSequence VARCHAR2(100);
  V_DebugInfo        VARCHAR2(100);
BEGIN

  V_CurrentCallingSequence := 'AP_WEB_FLEX_PKG.GetIndepSegmentEnabledValues';

  P_NumOfTableElem := 0;
  FND_VSET.get_value_init(P_ValueSetInfo, TRUE);

  FND_VSET.get_value(P_ValueSetInfo, V_NumValueSetValue, V_Found, V_ValueInfo);
  WHILE V_Found LOOP

    IF (trunc(nvl(V_ValueInfo.start_date_active,sysdate)) <= trunc(sysdate)
	AND trunc(nvl(V_ValueInfo.end_date_active,sysdate)) >= trunc(sysdate))
    THEN
	P_NumOfTableElem := P_NumOfTableElem + 1;

    	P_PoplistArray(P_NumOfTableElem).InternalValue := V_ValueInfo.value;
    	P_PoplistArray(P_NumOfTableElem).DisplayText := V_ValueInfo.value;
    END IF;

    FND_VSET.get_value(P_ValueSetInfo, V_NumValueSetValue, V_Found, V_ValueInfo);

  END LOOP;

  FND_VSET.get_value_end(P_ValueSetInfo);
EXCEPTION
  WHEN OTHERS THEN
    BEGIN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', V_CurrentCallingSequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS','');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',V_DebugInfo);
      AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
    END;

END GetIndepSegmentEnabledValues;

-------------------------------------------------------------------------------
PROCEDURE GetValueSet(P_ValueSetID IN NUMBER,
                      P_ValueSetInfo OUT NOCOPY FND_VSET.VALUESET_R,
                      P_ValueSetFormat OUT NOCOPY FND_VSET.VALUESET_DR)
-------------------------------------------------------------------------------
IS
  -- Since segments without value sets are allowed, we're setting the
  -- values in P_ValueSetInfo and P_ValueSetFormat used throughout the
  -- dflex code.
BEGIN

  IF (P_ValueSetID IS NOT NULL) THEN

    -- If value set assigned to segment, then get appropriate information
    -- from Get_valueset output.  The V_ValueSetInfo will only be referenced
    -- if it is an independent-validated type value set.

    FND_VSET.Get_valueset(P_ValueSetID, P_ValueSetInfo, P_ValueSetFormat);

  ELSE

    -- If no value set assigned to segment, treat it as a none-validated
    -- value set.

    P_ValueSetInfo.validation_type := C_ValidNone;
--    P_ValueSetFormat.longlist_enabled := FALSE;
    P_ValueSetFormat.max_size := C_AttributeColSize;
    P_ValueSetInfo.name := NULL;
    P_ValueSetFormat.alphanumeric_allowed_flag := C_Yes;
    P_ValueSetFormat.uppercase_only_flag := C_No;
    P_ValueSetFormat.format_type := NULL;

  END IF;

END GetValueSet;

-------------------------------------------------------------------------------
FUNCTION GenFlexSegmentPrompt(P_Segments IN FND_DFLEX.SEGMENTS_DR,
                                   P_SegIndex IN NUMBER) RETURN VARCHAR2
-------------------------------------------------------------------------------
IS
  --
  -- Returns the prompt for the given segment.
  --

BEGIN
  RETURN P_Segments.row_prompt(P_SegIndex);
END GenFlexSegmentPrompt;

-------------------------------------------------------------------------------
FUNCTION GenFlexSegWizText(P_Segments IN FND_DFLEX.SEGMENTS_DR,
                               P_SegIndex IN NUMBER) RETURN VARCHAR2
-------------------------------------------------------------------------------
IS
  --
  -- Returns the prompt for the given segment.
  --

BEGIN
  RETURN P_Segments.description(P_SegIndex);
END GenFlexSegWizText;


-------------------------------------------------------------------------------
PROCEDURE GetTaxPseudoSegmentDefaults(
             P_ExpTypeID                IN  AP_EXPENSE_REPORT_PARAMS.parameter_id%TYPE,
             P_ExpTypeTaxCodeUpdateable IN OUT NOCOPY VARCHAR2,
             P_ExpTypeDefaultTaxCode    IN OUT NOCOPY AP_TAX_CODES.name%TYPE,
             P_OrgId                    IN  NUMBER)
-------------------------------------------------------------------------------
IS

  V_ExpTypeRec			AP_WEB_DB_EXPTEMPLATE_PKG.ExpTypeInfoRec;

  V_DefaultTaxID           	NUMBER(15);
  V_DefaultTaxType         	VARCHAR2(25);
  V_DefaultTaxDesc         	VARCHAR2(240);

  V_DefaultTaxCode         	VARCHAR2(30);


BEGIN

  IF P_ExpTypeID IS NULL THEN
    P_ExpTypeTaxCodeUpdateable := C_No;
    P_ExpTypeDefaultTaxCode := NULL;
    RETURN;
  END IF;

  -- Get information about the expense type
  IF (NOT AP_WEB_DB_EXPTEMPLATE_PKG.GetExpTypeInfo(P_ExpTypeID, V_ExpTypeRec)) THEN
	NULL;
  END IF;


  -- Get tax code information
  BEGIN
     ZX_AP_TAX_CLASSIFICATN_DEF_PKG.get_default_tax_classification
            (--p_line_location_id         => null,
             p_ref_doc_application_id   => null,
             p_ref_doc_entity_code      => null,
             p_ref_doc_event_class_code => null,
             p_ref_doc_trx_id           => null,
             p_ref_doc_line_id          => null,
             p_ref_doc_trx_level_type   => null,
             p_vendor_id	        => null,
             p_vendor_site_id 		=> null,
             p_code_combination_id	=> null,
             p_concatenated_segments	=> V_ExpTypeRec.flex_concat,
             p_templ_tax_classification_cd	=> V_ExpTypeRec.vat_code,
             p_ship_to_location_id	=> null,
             p_ship_to_loc_org_id	=> null,
             p_inventory_item_id   	=> null,
             p_item_org_id	   	=> null,
             p_tax_classification_code	=> P_ExpTypeDefaultTaxCode,
             p_allow_tax_code_override_flag => P_ExpTypeTaxCodeUpdateable,
             APPL_SHORT_NAME		=> 'SQLAP',
             FUNC_SHORT_NAME		=> 'NONE',
             p_calling_sequence		=> 'APXXXEER',
             p_event_class_code	        => 'EXPENSE REPORTS',
             p_entity_code              => 'AP_INVOICES',
             p_application_id		=> 200,
             p_internal_organization_id	=> P_OrgId);

  EXCEPTION
  WHEN NO_DATA_FOUND THEN
      BEGIN
         P_ExpTypeDefaultTaxCode := NULL;
      END;
  END;

  -- Clear out the default tax if it is not web enabled.  This is a setup
  -- error.
  IF (NOT AP_WEB_DB_ETAX_INT_PKG.IsTaxCodeWebEnabled(P_ExpTypeDefaultTaxCode)) THEN
      P_ExpTypeDefaultTaxCode := NULL;
  END IF;

  -- If TaxCodeUpdateable is NULL then set to Yes by default.
  P_ExpTypeTaxCodeUpdateable := NVL(P_ExpTypeTaxCodeUpdateable, C_Yes);


END GetTaxPseudoSegmentDefaults;

-------------------------------------------------------------------------------
FUNCTION GetSegmentDefault(P_ContextValue          IN VARCHAR2,
                           P_Segments              IN FND_DFLEX.SEGMENTS_DR,
                           P_SegIndex              IN NUMBER)
RETURN VARCHAR2
-------------------------------------------------------------------------------
IS
  --
  -- Returns the default value for the segment as determined by the default
  -- specified in the 10SC form and the custom default procedure.
  --

  V_DefaultValue           VARCHAR2(240);
  V_DefaultValueSet        BOOLEAN;

  V_CurrentCallingSequence VARCHAR2(100);
  V_DebugInfo              VARCHAR2(100);

BEGIN

  V_CurrentCallingSequence := 'AP_WEB_FLEX_PKG.GetSegmentDefault';

  IF (P_SegIndex > P_Segments.nsegments) THEN
    RETURN '';
  END IF;

  -- Get custom values here
  V_DebugInfo := 'Get custom values here';
  AP_WEB_CUST_DFLEX_PKG.CustomPopulateDefault(
    P_ContextValue,
    P_Segments.segment_name(P_SegIndex), V_DefaultValue);

  -- If no custom values set, then use defaults
  V_DebugInfo := 'Get default value';
  IF V_DefaultValue IS NULL THEN

--    htp.p('P_Segments.default_value(P_SegIndex)=' || P_Segments.default_value(P_SegIndex) || 'P_SegIndex=' || to_char(P_SegIndex));
    IF P_Segments.default_type(P_SegIndex) = C_DefaultTypeConstant THEN
      V_DefaultValue := P_Segments.default_value(P_SegIndex);
    END IF;
  END IF;

  RETURN V_DefaultValue;
EXCEPTION
  WHEN OTHERS THEN
    BEGIN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', V_CurrentCallingSequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS','');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',V_DebugInfo);
      AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
    END;

END GetSegmentDefault;

-------------------------------------------------------------------------------
FUNCTION GenInputObjectName(P_ObjectIndex IN NUMBER) RETURN VARCHAR2
-------------------------------------------------------------------------------
IS
  --
  -- Returns the name of the input objects used in the flex frame.
  --
BEGIN
  RETURN C_InputObjectPrefix || TO_CHAR(P_ObjectIndex);
END GenInputObjectName;

-------------------------------------------------------------------------------
FUNCTION GenInputPseudoObjectName(P_ObjectIndex IN NUMBER) RETURN VARCHAR2
-------------------------------------------------------------------------------
IS
  --
  -- Returns the name of the input objects used in the flex frame.
  --
BEGIN
  RETURN C_InputPseudoObjectPrefix || TO_CHAR(P_ObjectIndex);
END GenInputPseudoObjectName;

-------------------------------------------------------------------------------
FUNCTION GenHiddenInput(P_InputName IN VARCHAR2,
                        P_Value     IN VARCHAR2)
RETURN VARCHAR2
-------------------------------------------------------------------------------
IS
BEGIN
  RETURN '<INPUT TYPE=\"hidden\" NAME=\"' || P_InputName || '\" VALUE=\"' || P_Value || '\">';
END GenHiddenInput;

-------------------------------------------------------------------------------
FUNCTION GenTextInput(P_InputName IN VARCHAR2,
                      P_Value     IN VARCHAR2,
                      P_Size      IN NUMBER,
                      P_MaxLength IN NUMBER) RETURN VARCHAR2
-------------------------------------------------------------------------------
IS
  V_ValidSize      VARCHAR2(100);
  V_ValidMaxLength VARCHAR2(100);
BEGIN
  V_ValidSize := TO_CHAR(NVL(P_Size, C_DefaultTextSize));
  -- to fix bug#1079905, we do not limit the size of the flexfield
  /*
  IF V_ValidSize > C_MaxTextSize THEN
    V_ValidSize := C_MaxTextSize;
  END IF;
  */
  V_ValidMaxLength := TO_CHAR(NVL(P_MaxLength, C_DefaultTextMaxLength));

  RETURN '<FONT class=promptblack><INPUT TYPE=\"text\" NAME=\"' || P_InputName || '\" VALUE=\"' || P_Value ||
    '\" SIZE=' || V_ValidSize || ' MAXLENGTH=' || V_ValidMaxLength || '></FONT>';
END GenTextInput;

-------------------------------------------------------------------------------
FUNCTION GenCheckboxInput(P_InputName IN VARCHAR2,
                          P_Checked   IN VARCHAR2)
RETURN VARCHAR2
-------------------------------------------------------------------------------
IS
  V_Value VARCHAR2(10);
  C_CheckboxChecked       CONSTANT VARCHAR2(50) := 'CHECKED';
BEGIN
  V_Value := '';
  IF P_Checked = C_Yes THEN
    V_Value := C_CheckboxChecked;
  END IF;
  RETURN '<INPUT TYPE=\"checkbox\" NAME=\"' || P_InputName || '\" ' || V_Value || '>';
END GenCheckboxInput;



-------------------------------------------------------------------------------
function LOVButton (c_attribute_app_id in number,
                    c_attribute_code in varchar2,
                    c_region_app_id in number,
                    c_region_code in varchar2,
                    c_form_name in varchar2,
                    c_frame_name in varchar2 default null,
                    c_where_clause in varchar2 default null,
                    c_js_where_clause in varchar2 default null,
		    c_image_align in varchar2 default 'CENTER')
                    return varchar2  is
-------------------------------------------------------------------------------
temp varchar2(2000);
temp1 varchar2(2000);
c_language varchar2(30);
l_prompts          AP_WEB_UTILITIES_PKG.prompts_table;
l_title            AK_REGIONS_VL.NAME%TYPE;
l_where_clause varchar2(2000);

begin
    c_language := icx_sec.getID(icx_sec.PV_LANGUAGE_CODE);
    AP_WEB_DISC_PKG.getPrompts(601,'ICX_LOV',l_title,l_prompts);
    l_where_clause := icx_call.encrypt2(c_where_clause);
    temp1 := 'javascript:top.opener.top.framMain.lines.setProjectNumberBindValue();';
    temp := htf.anchor(temp1||'LOV('''||c_attribute_app_id||''','''||c_attribute_code||''','''||c_region_app_id||''','''||c_region_code||''','''||c_form_name||''','''||c_frame_name||''','''||l_where_clause||''','''||c_js_where_clause||''')',

	htf.img(AP_WEB_INFRASTRUCTURE_PKG.getImagePath||'FNDILOV.gif',c_image_align,icx_util.replace_alt_quotes(l_title),'','BORDER=0 WIDTH=23 HEIGHT=21'),'','');
    return temp;
end;



-------------------------------------------------------------------------------
PROCEDURE GetSegmentType(  P_ContextValue        IN  VARCHAR2,
                           P_Segments            IN  FND_DFLEX.SEGMENTS_DR,
                           P_SegIndex            IN  NUMBER,
                           P_InputObjectType     OUT NOCOPY VARCHAR2
                           )
-------------------------------------------------------------------------------
IS
  --
  -- Generates the HTML input objects (SELECT, TEXT, HIDDEN, CHECKBOX) for the
  -- particular flexfield segment.
  --

  V_ValueSetInfo        FND_VSET.VALUESET_R;
  V_ValueSetFormat      FND_VSET.VALUESET_DR;
  V_PoplistArray        PoplistValues_A;
  V_SegDefaultValue     VARCHAR2(240);
  V_NumOfTableElem      NUMBER;
  V_CheckboxChecked     VARCHAR2(100);

  V_CurrentCallingSequence VARCHAR2(100);
  V_DebugInfo        VARCHAR2(100);

BEGIN

  V_CurrentCallingSequence := 'AP_WEB_FLEX_PKG.GetSegmentType';

  -- Just define an input object stub only
  V_DebugInfo := 'Generate segment stub';


  -- Get Value Set
  GetValueSet(P_Segments.value_set(P_SegIndex),V_ValueSetInfo, V_ValueSetFormat);


  IF NOT IsSegmentRendered(P_Segments, P_SegIndex, V_ValueSetInfo) THEN
    -- Segment is hidden
    P_InputObjectType := C_HiddenInputObject;

  ELSE

    -- If long list is enabled, then the segment is always rendered as a
    -- text box
    IF (NOT AP_WEB_WRAPPER_PKG.isPopList(V_ValueSetFormat)) THEN
      -- Text input
      P_InputObjectType := C_TextInputObject;
    ELSIF (V_ValueSetInfo.validation_type = C_ValidIndependent) THEN

      -- try to populate with custom routines
      V_DebugInfo := 'Get poplist input values';
      AP_WEB_CUST_DFLEX_PKG.CustomPopulatePoplist(
        P_ContextValue,
        P_Segments.segment_name(P_SegIndex), V_NumOfTableElem,
        V_PoplistArray);

      IF V_NumOfTableElem = 0 THEN
        -- Poplist input
        V_DebugInfo := 'Generate poplist input';
        GetIndepSegmentEnabledValues(V_ValueSetInfo, V_NumOfTableElem,
          V_PoplistArray);
      END IF;


      -- If there are poplist values then create a poplist item, otherwise
      -- create a textfield.
      IF V_NumOfTableElem <> 0 THEN
        P_InputObjectType := C_SelectInputObject;

      ELSE

        P_InputObjectType := C_TextInputObject;

      END IF;

    ELSIF (V_ValueSetInfo.validation_type = C_ValidNone) THEN

      -- Text input
      P_InputObjectType := C_TextInputObject;

    ELSIF (V_ValueSetInfo.validation_type = C_ValidTable) THEN

      IF (V_ValueSetInfo.name = C_SpecialCheckboxValueSet) THEN

        -- Checkbox input


        P_InputObjectType := C_CheckboxInputObject;

      ELSE

        -- Bug Fix 1790945, added AP_WEB_CUST_DFLEX_PKG.CustomPopulatePoplist
        -- and if condition below
        AP_WEB_CUST_DFLEX_PKG.CustomPopulatePoplist(
          P_ContextValue,
          P_Segments.segment_name(P_SegIndex), V_NumOfTableElem,
          V_PoplistArray);

        IF V_NumOfTableElem = 0 THEN
           -- Poplist input
           V_DebugInfo := 'Generate poplist input';
           GetIndepSegmentEnabledValues(V_ValueSetInfo, V_NumOfTableElem,
              V_PoplistArray);
        END IF;

        IF V_NumOfTableElem <> 0 THEN

          -- Poplist input

          P_InputObjectType := C_SelectInputObject;

        ELSE

          -- Text input

          P_InputObjectType := C_TextInputObject;

        END IF;

      END IF;

    END IF;

  END IF;
EXCEPTION
  WHEN OTHERS THEN
    BEGIN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', V_CurrentCallingSequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS','');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',V_DebugInfo);
      AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
    END;

END GetSegmentType;



FUNCTION GetContextSensitiveOffset(P_Contexts IN FND_DFLEX.CONTEXTS_DR,
                                   P_Prompt IN VARCHAR2)
RETURN NUMBER
IS
  I NUMBER;
BEGIN

  -- For each ENABLED context, not including the global data elements
  FOR I IN 1..P_Contexts.ncontexts LOOP
    IF (P_Contexts.context_code(I) = P_Prompt) AND
       (P_Contexts.global_context <> I) AND
       (P_Contexts.is_enabled(I)) THEN
      RETURN I;
    END IF;

  END LOOP;

  RETURN -1;
END GetContextSensitiveOffset;



-------------------------------------------------------------------------------
FUNCTION GenSegmentDefaultValue(SegmentDefaultValue_A IN AP_WEB_PARENT_PKG.MedString_Array,
                                P_InputObjectPrefix  IN VARCHAR2,
                                P_NumOfFlexField     IN NUMBER)
-------------------------------------------------------------------------------
RETURN VARCHAR2
IS
  I         NUMBER;
  RetString VARCHAR2(2000);

  V_CurrentCallingSequence VARCHAR2(100);
  V_DebugInfo            VARCHAR2(100);
BEGIN

  V_CurrentCallingSequence := 'GenSegmentDefaultValue';

  RetString := 'var ' || P_InputObjectPrefix || 'DefaultValue = new Array(' || TO_CHAR(P_NumOfFlexField+1) || ');';

  FOR I IN 1..P_NumOfFlexField LOOP

    RetString := RetString ||
      P_InputObjectPrefix || 'DefaultValue[' || TO_CHAR(I) || ']=\"' || SegmentDefaultValue_A(I) || '\";';
  END LOOP;

  RETURN RetString;

EXCEPTION
  WHEN OTHERS THEN
    BEGIN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', V_CurrentCallingSequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS','');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',V_DebugInfo);
      AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
    END;

END GenSegmentDefaultValue;



------------------------------------------------------------------------
FUNCTION GetMaxNumSegmentsUsed (p_user_id IN NUMBER DEFAULT NULL) -- added argument for 2242176
RETURN NUMBER
-------------------------------------------------------------------------------
IS
  V_DFlexField       FND_DFLEX.DFLEX_R;
  V_DFlexInfo        FND_DFLEX.DFLEX_DR;
  V_Contexts         FND_DFLEX.CONTEXTS_DR;
  V_Context              FND_DFLEX.CONTEXT_R;
  V_Segments             FND_DFLEX.SEGMENTS_DR;
  V_IsFlexFieldUsed  BOOLEAN;

  V_CurrentCallingSequence VARCHAR2(100);
  V_DebugInfo        VARCHAR2(100);

  V_NumOfGlobalSegments NUMBER ;
  V_NumOfContextSegments NUMBER;
  V_NumOfMaxContextSegments NUMBER := 0;

BEGIN
  -- Get descriptive flexfield info
  V_DebugInfo := 'Get descriptive flexfield info';
  GetExpenseLineDFlexInfo(p_user_id,
                          V_DFlexField,
                          V_DFlexInfo,
                          V_Contexts,
                          V_IsFlexFieldUsed);
  IF V_IsFlexFieldUsed THEN
    -- Get information about the global context
    V_Context.flexfield := V_DFlexField;
    V_Context.context_code :=  V_Contexts.context_code(V_Contexts.global_context);
    FND_DFLEX.Get_Segments(V_Context, V_Segments, TRUE);
    V_NumOfGlobalSegments := GetNumOfEnabledSegments(V_Segments);

    V_NumOfMaxContextSegments := 0;
    -- For each ENABLED context, not including the global data elements
    FOR I IN 1..V_Contexts.ncontexts LOOP

      IF (V_Contexts.global_context <> I) AND (V_Contexts.is_enabled(I)) THEN

        -- Get segment information
        V_Context.flexfield := V_DFlexField;
        V_Context.context_code :=  V_Contexts.context_code(I);
        FND_DFLEX.Get_Segments(V_Context, V_Segments, TRUE);
        V_NumOfContextSegments := GetNumOfEnabledSegments(V_Segments);
        IF (V_NumOfContextSegments > V_NumOfMaxContextSegments) THEN
          V_NumOfMaxContextSegments := V_NumOfContextSegments;
        END IF;

      END IF;
    END LOOP;

    RETURN MINIMUM(V_NumOfGlobalSegments + V_NumOfMaxContextSegments, C_AbsoluteMaxFlexField);

  ELSE

    RETURN 0;

  END IF;
END GetMaxNumSegmentsUsed;

PROCEDURE IsSessionTaxEnabled(P_Result OUT NOCOPY VARCHAR2,
                              P_User_Id IN NUMBER DEFAULT NULL)

 -- Sets P_Result = 'Y' if tax is enabled otherwise sets P_Result = 'N'
IS
BEGIN

  P_Result := AP_WEB_UTILITIES_PKG.VALUE_SPECIFIC(
					p_name    => 'AP_WEB_TAX_ENABLE',
					p_user_id => P_User_Id,
					p_resp_id => null,
					p_apps_id => null);
  P_Result := NVL(P_Result, 'N');

END IsSessionTaxEnabled;

------------------------------------------------------------------------
FUNCTION GetMaxNumPseudoSegmentsUsed(
  P_IsSessionProjectEnabled IN VARCHAR2)
RETURN NUMBER
-------------------------------------------------------------------------------
IS
  V_NumPseudoFlexField INTEGER := 0;
BEGIN


  IF P_IsSessionProjectEnabled = C_Yes THEN
    V_NumPseudoFlexField := V_NumPseudoFlexField + C_NumProjectPseudoFlexField;
  END IF;

  RETURN V_NumPseudoFlexField;
END GetMaxNumPseudoSegmentsUsed;

------------------------------------------------------------------------
FUNCTION IsFlexFieldUsed(
        P_CustomField IN CustomFieldRec)
RETURN BOOLEAN
------------------------------------------------------------------------
IS
BEGIN
  RETURN (P_CustomField.column_mapping IS NOT NULL);
END IsFlexFieldUsed;

------------------------------------------------------------------------
FUNCTION IsFlexFieldPopulated(
        P_CustomField IN CustomFieldRec)
RETURN BOOLEAN
------------------------------------------------------------------------
IS
BEGIN
  RETURN (P_CustomField.value IS NOT NULL);
END IsFlexFieldPopulated;

------------------------------------------------------------------------
PROCEDURE ClearCustomFieldRec(
  P_CustomField OUT NOCOPY CustomFieldRec)
------------------------------------------------------------------------
IS
BEGIN
  P_CustomField.prompt := NULL;
  P_CustomField.value := NULL;
  P_CustomField.column_mapping := NULL;
  P_CustomField.displayed_flag := NULL;
  P_CustomField.required_flag := NULL;
  P_CustomField.display_size := NULL;
  P_CustomField.value_set := NULL;
END ClearCustomFieldRec;

------------------------------------------------------------------------
FUNCTION IsCustomFieldPopulated(P_ReceiptIndex IN NUMBER,
                                Custom1_Array  IN CustomFields_A,
                                Custom2_Array  IN CustomFields_A,
                                Custom3_Array  IN CustomFields_A,
                                Custom4_Array  IN CustomFields_A,
                                Custom5_Array  IN CustomFields_A,
                                Custom6_Array  IN CustomFields_A,
                                Custom7_Array  IN CustomFields_A,
                                Custom8_Array  IN CustomFields_A,
                                Custom9_Array  IN CustomFields_A,
                                Custom10_Array IN CustomFields_A,
                                Custom11_Array IN CustomFields_A,
                                Custom12_Array IN CustomFields_A,
                                Custom13_Array IN CustomFields_A,
                                Custom14_Array IN CustomFields_A,
                                Custom15_Array IN CustomFields_A)
RETURN BOOLEAN
------------------------------------------------------------------------
IS
BEGIN
  RETURN IsFlexFieldPopulated(Custom1_Array(P_ReceiptIndex)) OR
    IsFlexFieldPopulated(Custom2_Array(P_ReceiptIndex)) OR
    IsFlexFieldPopulated(Custom3_Array(P_ReceiptIndex)) OR
    IsFlexFieldPopulated(Custom4_Array(P_ReceiptIndex)) OR
    IsFlexFieldPopulated(Custom5_Array(P_ReceiptIndex)) OR
    IsFlexFieldPopulated(Custom6_Array(P_ReceiptIndex)) OR
    IsFlexFieldPopulated(Custom7_Array(P_ReceiptIndex)) OR
    IsFlexFieldPopulated(Custom8_Array(P_ReceiptIndex)) OR
    IsFlexFieldPopulated(Custom9_Array(P_ReceiptIndex)) OR
    IsFlexFieldPopulated(Custom10_Array(P_ReceiptIndex)) OR
    IsFlexFieldPopulated(Custom11_Array(P_ReceiptIndex)) OR
    IsFlexFieldPopulated(Custom12_Array(P_ReceiptIndex)) OR
    IsFlexFieldPopulated(Custom13_Array(P_ReceiptIndex)) OR
    IsFlexFieldPopulated(Custom14_Array(P_ReceiptIndex)) OR
    IsFlexFieldPopulated(Custom15_Array(P_ReceiptIndex));
END IsCustomFieldPopulated;

------------------------------------------------------------------------
PROCEDURE PopulateCustomDefaultValues(
                               P_User_Id      IN NUMBER,
                               P_ExpReportHeaderInfo IN ExpReportHeaderRec,
                               ExpReportLinesInfo IN OUT NOCOPY ExpReportLines_A,
                               P_ReceiptCount IN NUMBER,
                               Custom1_Array  IN OUT NOCOPY CustomFields_A,
                               Custom2_Array  IN OUT NOCOPY CustomFields_A,
                               Custom3_Array  IN OUT NOCOPY CustomFields_A,
                               Custom4_Array  IN OUT NOCOPY CustomFields_A,
                               Custom5_Array  IN OUT NOCOPY CustomFields_A,
                               Custom6_Array  IN OUT NOCOPY CustomFields_A,
                               Custom7_Array  IN OUT NOCOPY CustomFields_A,
                               Custom8_Array  IN OUT NOCOPY CustomFields_A,
                               Custom9_Array  IN OUT NOCOPY CustomFields_A,
                               Custom10_Array IN OUT NOCOPY CustomFields_A,
                               Custom11_Array IN OUT NOCOPY CustomFields_A,
                               Custom12_Array IN OUT NOCOPY CustomFields_A,
                               Custom13_Array IN OUT NOCOPY CustomFields_A,
                               Custom14_Array IN OUT NOCOPY CustomFields_A,
                               Custom15_Array IN OUT NOCOPY CustomFields_A,
                               P_NumMaxFlexField  IN NUMBER,
                               P_DataDefaultedUpdateable IN OUT NOCOPY BOOLEAN)
------------------------------------------------------------------------
IS
  CustomForOneReceipt CustomFields_A;
  V_ContextIndex      NUMBER;
  I                   NUMBER;
  CustomIndex         NUMBER;
  V_SegMapIndex       NUMBER;
  V_SegIndex          NUMBER;
  V_NumOfEnabledContSeg NUMBER;
  V_NumOfGlobalFlexField NUMBER;
  V_SegDefaultValue      VARCHAR2(240);
  Map_Array              AP_WEB_PARENT_PKG.Number_Array;
  V_ContextValue     VARCHAR2(100);

  V_DFlexField           FND_DFLEX.DFLEX_R;
  V_DFlexInfo        FND_DFLEX.DFLEX_DR;
  V_Contexts         FND_DFLEX.CONTEXTS_DR;
  V_Context              FND_DFLEX.CONTEXT_R;
  V_Segments             FND_DFLEX.SEGMENTS_DR;
  V_IsFlexFieldUsed      BOOLEAN;

  V_ValueSetInfo	 FND_VSET.VALUESET_R;
  V_ValueSetFormat       FND_VSET.VALUESET_DR;

  V_CurrentCallingSequence VARCHAR2(100) := 'PopulateCustomDefaultValues';
  V_DebugInfo        VARCHAR2(100);
  TEST               EXCEPTION;

  b                 varchar2(100);
BEGIN

  -- Initialize
  FOR I IN 1..15 LOOP
    CustomForOneReceipt(I).value := NULL;
  END LOOP;
  P_DataDefaultedUpdateable := FALSE;

  -- Don't do anything if flexfields are not used
  IF P_NumMaxFlexField > 0 THEN

    -- Get flexfield info and contexts for the flexfield
    V_DebugInfo := 'Get descriptive flexfield info and contexts for the flexfield';
    GetExpenseLineDFlexInfo(P_User_Id,
                            V_DFlexField,
                            V_DFlexInfo,
                            V_Contexts,
                            V_IsFlexFieldUsed);

    -- Get information about the global context
    V_DebugInfo := 'Get information about the global context';
    V_Context.flexfield := V_DFlexField;
    V_Context.context_code :=  V_Contexts.context_code(V_Contexts.global_context);
    FND_DFLEX.Get_Segments(V_Context, V_Segments, TRUE);
    V_NumOfGlobalFlexField := GetNumOfEnabledSegments(V_Segments);

    -- Map segments so that only enabled ones are sorted
    GetEnabledSegments(V_Segments, Map_Array, V_NumOfEnabledContSeg);

    -- Fill in the global data element info which will be used by each receipt
    -- These values will be copied into each receipt
    CustomIndex := 1;
    FOR V_SegMapIndex IN 1..MINIMUM(V_NumOfEnabledContSeg, C_AbsoluteMaxFlexField) LOOP

      -- Map segments here
      V_SegIndex := Map_Array(V_SegMapIndex);

      -- Get segment default
      CustomForOneReceipt(CustomIndex).value :=
        GetSegmentDefault(V_Context.context_code,
          V_Segments, V_SegIndex);

      -- Determine whether a value has been defaulted and can be overwritten
      -- by the user.  Getting the value set can be expensive, so only do that
      -- when we know that there are still no defaulted/modifiable values.
      IF CustomForOneReceipt(CustomIndex).value IS NOT NULL AND
         NOT P_DataDefaultedUpdateable THEN

        -- Get value set
        V_DebugInfo := 'Get value set';
        GetValueSet(V_Segments.value_set(V_SegIndex),
          V_ValueSetInfo, V_ValueSetFormat);

        -- Check if segment is enabled, but not displayed
        V_DebugInfo := 'Check if segment is enabled, but not displayed';
        IF IsSegmentRendered(V_Segments, V_SegIndex, V_ValueSetInfo) THEN
          P_DataDefaultedUpdateable := TRUE;
        END IF;

      END IF;

      CustomIndex := CustomIndex + 1;

    END LOOP;

    -- Get expense type prompts and codes

    -- For each receipt, we will get the context value and fill in the default context
    -- values appropriately.
    V_DebugInfo := 'Fill in receipt custom default values info';
    FOR I IN 1..P_ReceiptCount LOOP

      IF ExpReportLinesInfo(I).parameter_id IS NOT NULL THEN

        CustomIndex := V_NumOfGlobalFlexField + 1;
--        This should already be set
--        PopulateExpTypeInLineRec(ExpReportLinesInfo(I));

        V_DebugInfo := 'GetDFlexContextIndex "'
          || ExpReportLinesInfo(I).expense_type || '"';
        GetDFlexContextIndex(ExpReportLinesInfo(I).expense_type,
    		          V_Contexts,
    		          V_ContextIndex);
        V_DebugInfo := 'ContextIndex = ' || V_ContextIndex ;

        -- Check whether there are context sensitive fields for the expense type
        IF (V_ContextIndex IS NOT NULL) THEN

          V_Context.context_code := V_Contexts.context_code(V_ContextIndex);
          V_DebugInfo := 'context_code = ' || V_Context.context_code ;
          FND_DFLEX.Get_Segments(V_Context, V_Segments, TRUE);

          -- Map segments so that only enabled ones are sorted
          V_DebugInfo := 'Map segments so that only enabled ones are sorted';
          GetEnabledSegments(V_Segments, Map_Array, V_NumOfEnabledContSeg);

          V_DebugInfo := 'Set context sensitive segments';
          FOR V_SegMapIndex IN 1..MINIMUM(V_NumOfEnabledContSeg, C_AbsoluteMaxFlexField) LOOP

            -- Map segments here
            V_SegIndex := Map_Array(V_SegMapIndex);

            -- Get segment default
            CustomForOneReceipt(CustomIndex).value :=
              GetSegmentDefault(V_Context.context_code, V_Segments, V_SegIndex);

            -- Determine whether a value has been defaulted and can be
            -- overwritten by the user.  Getting the value set can be
            -- expensive, so only do that when we know that there are still
            -- no defaulted/modifiable values.
            IF CustomForOneReceipt(CustomIndex).value IS NOT NULL AND
               NOT P_DataDefaultedUpdateable THEN

              -- Get value set
              V_DebugInfo := 'Get value set';
              GetValueSet(V_Segments.value_set(V_SegIndex),
                V_ValueSetInfo, V_ValueSetFormat);

              -- Check if segment is enabled, but not displayed
              V_DebugInfo := 'Check if segment is enabled, but not displayed';
              IF IsSegmentRendered(V_Segments, V_SegIndex, V_ValueSetInfo) THEN
                P_DataDefaultedUpdateable := TRUE;
              END IF;

            END IF;

            CustomIndex := CustomIndex + 1;

          END LOOP;

        END IF;

        V_DebugInfo := 'Clear out nocopy unused segments';
        FOR V_SegIndex IN CustomIndex..C_AbsoluteMaxFlexField LOOP

          -- Get segment default
          CustomForOneReceipt(V_SegIndex).value := NULL;

        END LOOP;

        -- Copy CustomForOneReceipt contents into the customN_arrays
        PropogateReceiptCustFldsInfo(CustomForOneReceipt,
                                                        I,
                                                        Custom1_Array,
                                                        Custom2_Array,
                                                        Custom3_Array,
                                                        Custom4_Array,
                                                        Custom5_Array,
                                                        Custom6_Array,
                                                        Custom7_Array,
                                                        Custom8_Array,
                                                        Custom9_Array,
                                                        Custom10_Array,
                                                        Custom11_Array,
                                                        Custom12_Array,
                                                        Custom13_Array,
                                                        Custom14_Array,
                                                        Custom15_Array);

      END IF;
    END LOOP;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    BEGIN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', V_CurrentCallingSequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS','');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',V_DebugInfo);
      AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
    END;

END PopulateCustomDefaultValues;

------------------------------------------------------------------------
PROCEDURE PopulatePseudoDefaultValues(
                               P_ExpReportHeaderInfo IN ExpReportHeaderRec,
                               ExpReportLinesInfo IN OUT NOCOPY ExpReportLines_A,
                               P_ReceiptCount IN NUMBER,
                               P_DataDefaultedUpdateable IN OUT NOCOPY BOOLEAN)
------------------------------------------------------------------------
IS

  V_DefaultTaxCodeUpdateable VARCHAR2(1);
  V_DefaultTaxCode       AP_WEB_DB_AP_INT_PKG.taxCodes_name;
  V_ValueSetInfo         FND_VSET.VALUESET_R;
  V_ValueSetFormat       FND_VSET.VALUESET_DR;

  V_CurrentCallingSequence VARCHAR2(100) := 'PopulatePseudoDefaultValues';
  V_DebugInfo        VARCHAR2(100);
  l_OrgId            ap_expense_report_headers_all.org_id%TYPE;

BEGIN

  P_DataDefaultedUpdateable := FALSE;

  --Bug#7172212 - vat_code field not being populated for Spread-Sheet Import.
  l_OrgId :=  nvl(TO_NUMBER(rtrim(substrb(USERENV('CLIENT_INFO'), 1, 10))),-99);

  AP_WEB_UTILITIES_PKG.logProcedure('AP_WEB_DFLEX_PKG','Org_id used to default the tax codes'||To_Char(l_OrgId));

  FOR I IN 1..P_ReceiptCount LOOP

    /* Bug 2844544: Initializing the variables before calling the
                    function to retrieve the tax values. */
    V_DefaultTaxCodeUpdateable := NULL;
    V_DefaultTaxCode := NULL;

    GetTaxPseudoSegmentDefaults(ExpReportLinesInfo(I).parameter_id,
                                V_DefaultTaxCodeUpdateable,
                                V_DefaultTaxCode,
                                l_OrgId);

    -- Set default and mark whether it is defaulted and modifiable

    P_DataDefaultedUpdateable := TRUE;

    -- vat code
    ExpReportLinesInfo(I).tax_code := V_DefaultTaxCode;
    IF V_DefaultTaxCode IS NOT NULL AND V_DefaultTaxCodeUpdateable = C_Yes THEN
      P_DataDefaultedUpdateable := TRUE;
    END IF;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    BEGIN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE', V_CurrentCallingSequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS','');
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',V_DebugInfo);
      AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
    END;

END PopulatePseudoDefaultValues;

-----------------------------------------------------------------------------
FUNCTION IsCustomFieldsFeatureUsed
RETURN BOOLEAN
-----------------------------------------------------------------------------
IS
  l_dflex_name		VARCHAR2(30) := NULL;
BEGIN

  FND_PROFILE.GET('AP_WEB_DESC_FLEX_NAME', l_dflex_name);

  RETURN (l_dflex_name IS NOT NULL);

END IsCustomFieldsFeatureUsed;

-----------------------------------------------------------------------------
PROCEDURE GetExpenseLineDFlexInfo(p_user_id     IN NUMBER,
                                  p_flexfield	IN OUT NOCOPY FND_DFLEX.DFLEX_R,
				  p_flexinfo	IN OUT NOCOPY FND_DFLEX.DFLEX_DR,
				  p_contexts	IN OUT NOCOPY FND_DFLEX.CONTEXTS_DR,
                                  p_is_custom_fields_feat_used IN OUT NOCOPY BOOLEAN)
-----------------------------------------------------------------------------
IS
  l_debug_info			VARCHAR2(2000);
  l_curr_calling_sequence	VARCHAR2(200) := 'GetExpenseLineDFlexInfo';
  l_is_dflex_enabled    VARCHAR2(1) := NULL;
BEGIN
    l_debug_info := 'Get profile option';
    l_is_dflex_enabled := AP_WEB_UTILITIES_PKG.VALUE_SPECIFIC(
					p_name    => 'AP_WEB_DESC_FLEX_NAME',
					p_user_id => p_user_id,
					p_resp_id => null,
					p_apps_id => null);

    -- is web descriptive flexfields enabled
    -- Bug 3985122 Y-Lines Only, B - Both Header and Lines
    -- p_is_custom_fields_feat_used := (NVL(l_is_dflex_enabled, 'N') = 'Y');
    p_is_custom_fields_feat_used := ((NVL(l_is_dflex_enabled, 'N') = 'Y') OR (NVL(l_is_dflex_enabled, 'N') = 'B'));

    IF p_is_custom_fields_feat_used THEN

      l_debug_info := 'Get flexfield info';
      FND_DFLEX.Get_Flexfield('SQLAP',
                                    C_LinesDescFlexname,
				    p_flexfield,
				    p_flexinfo);

      l_debug_info := 'Get context info';
      FND_DFLEX.Get_Contexts(p_flexfield,
				   p_contexts);

    END IF;

EXCEPTION
  WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
END GetExpenseLineDFlexInfo;

-----------------------------------------------------------------------------
PROCEDURE GetDFlexContextSegments(p_flexfield	IN FND_DFLEX.DFLEX_R,
			     	  p_contexts    IN FND_DFLEX.CONTEXTS_DR,
			     	  p_context_index  IN BINARY_INTEGER,
			     	  p_segments	IN OUT NOCOPY FND_DFLEX.SEGMENTS_DR)
-----------------------------------------------------------------------------
IS
  l_context		FND_DFLEX.CONTEXT_R;
  l_debug_info			VARCHAR2(2000);
  l_curr_calling_sequence	VARCHAR2(200) := 'GetDFlexContextSegments';
BEGIN

  l_context.flexfield := p_flexfield;
  l_context.context_code := p_contexts.context_code(p_context_index);

  FND_DFLEX.Get_Segments(l_context,
                                 p_segments, TRUE);

EXCEPTION
  WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
END GetDFlexContextSegments;


-----------------------------------------------------------------------------
PROCEDURE GetDFlexContextIndex(p_context_value	    IN VARCHAR2,
		               p_dflex_contexts	    IN FND_DFLEX.CONTEXTS_DR,
		               p_index		    IN OUT NOCOPY BINARY_INTEGER) IS
-----------------------------------------------------------------------------
 i	BINARY_INTEGER 	:= NULL;
  l_debug_info			VARCHAR2(2000);
  l_curr_calling_sequence	VARCHAR2(200) := 'GetDFlexContextIndex';
BEGIN

  FOR i IN 1..p_dflex_contexts.ncontexts LOOP

    IF (p_context_value = p_dflex_contexts.context_code(i)) THEN

      p_index := i;
      RETURN;

    END IF;

  END LOOP;

  p_index := NULL;

EXCEPTION
  WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
END GetDFlexContextIndex;

-----------------------------------------------------------------------------
PROCEDURE GetIndexRefOrderedArray(p_sequence_array  IN  FND_DFLEX.SEQUENCE_A,
				  p_nelements	    IN	NUMBER,
			p_index_ref_ordered_array   OUT NOCOPY BINARY_INTEGER_A) IS
-----------------------------------------------------------------------------
  l_sequence_a		FND_DFLEX.SEQUENCE_A := p_sequence_array;
  l_lowest_value        NUMBER := NULL;
  l_lowest_index	BINARY_INTEGER	:= NULL;
  i			BINARY_INTEGER 	:= NULL;
  j			BINARY_INTEGER	:= NULL;
  l_debug_info			VARCHAR2(2000);
  l_curr_calling_sequence	VARCHAR2(200) := 'GetIndexRefOrderedArray';
BEGIN

  FOR i in 1..p_nelements LOOP
    FOR j in 1..p_nelements LOOP

      IF ((l_lowest_value IS NULL) OR (l_lowest_value > l_sequence_a(j))) THEN
        l_lowest_value := l_sequence_a(j);
        l_lowest_index := j;
      END IF;

    END LOOP;

    p_index_ref_ordered_array(i) := l_lowest_index;
    l_sequence_a(l_lowest_index) := NULL;
    l_lowest_value := NULL;
    l_lowest_index := NULL;
  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
END GetIndexRefOrderedArray;

-----------------------------------------------------------------------------
FUNCTION GetNumOfEnabledSegments(P_Segments IN FND_DFLEX.SEGMENTS_DR) RETURN NUMBER
-----------------------------------------------------------------------------
IS

  I                      NUMBER;
  V_NumOfEnabledSegments NUMBER;
  l_debug_info			VARCHAR2(2000);
  l_curr_calling_sequence	VARCHAR2(200) := 'GetNumOfEnabledSegments';
BEGIN

  V_NumOfEnabledSegments := 0;

  FOR I IN 1..P_Segments.nsegments LOOP
    IF P_Segments.is_enabled(I) THEN
      V_NumOfEnabledSegments := V_NumOfEnabledSegments + 1;
    END IF;
  END LOOP;

  RETURN V_NumOfEnabledSegments;

EXCEPTION
  WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
END GetNumOfEnabledSegments;

---------------------------------------------------------------------------
PROCEDURE GetReceiptCustomFields(
		p_receipt_custom_fields_array	IN OUT NOCOPY CustomFields_A,
		p_receipt_index			IN BINARY_INTEGER,
		p_custom1_array			IN CustomFields_A,
		p_custom2_array			IN CustomFields_A,
		p_custom3_array			IN CustomFields_A,
		p_custom4_array			IN CustomFields_A,
		p_custom5_array			IN CustomFields_A,
		p_custom6_array			IN CustomFields_A,
		p_custom7_array			IN CustomFields_A,
		p_custom8_array			IN CustomFields_A,
		p_custom9_array			IN CustomFields_A,
		p_custom10_array		IN CustomFields_A,
		p_custom11_array		IN CustomFields_A,
		p_custom12_array		IN CustomFields_A,
		p_custom13_array		IN CustomFields_A,
		p_custom14_array		IN CustomFields_A,
		p_custom15_array		IN CustomFields_A)
---------------------------------------------------------------------------
IS
  l_debug_info			VARCHAR2(2000);
  l_curr_calling_sequence	VARCHAR2(200) := 'GetReceiptCustomFields';
BEGIN

  BEGIN
  p_receipt_custom_fields_array(1) := p_custom1_array(p_receipt_index);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     null;
  END;
  BEGIN
  p_receipt_custom_fields_array(2) := p_custom2_array(p_receipt_index);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     null;
  END;
  BEGIN
  p_receipt_custom_fields_array(3) := p_custom3_array(p_receipt_index);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     null;
  END;
  BEGIN
  p_receipt_custom_fields_array(4) := p_custom4_array(p_receipt_index);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     null;
  END;
  BEGIN
  p_receipt_custom_fields_array(5) := p_custom5_array(p_receipt_index);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     null;
  END;
  BEGIN
  p_receipt_custom_fields_array(6) := p_custom6_array(p_receipt_index);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     null;
  END;
  BEGIN
  p_receipt_custom_fields_array(7) := p_custom7_array(p_receipt_index);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     null;
  END;
  BEGIN
  p_receipt_custom_fields_array(8) := p_custom8_array(p_receipt_index);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     null;
  END;
  BEGIN
  p_receipt_custom_fields_array(9) := p_custom9_array(p_receipt_index);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     null;
  END;
  BEGIN
  p_receipt_custom_fields_array(10) := p_custom10_array(p_receipt_index);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     null;
  END;
  BEGIN
  p_receipt_custom_fields_array(11) := p_custom11_array(p_receipt_index);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     null;
  END;
  BEGIN
  p_receipt_custom_fields_array(12) := p_custom12_array(p_receipt_index);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     null;
  END;
  BEGIN
  p_receipt_custom_fields_array(13) := p_custom13_array(p_receipt_index);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     null;
  END;
  BEGIN
  p_receipt_custom_fields_array(14) := p_custom14_array(p_receipt_index);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     null;
  END;
  BEGIN
  p_receipt_custom_fields_array(15) := p_custom15_array(p_receipt_index);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     null;
  END;

EXCEPTION
  WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
END GetReceiptCustomFields;

---------------------------------------------------------------------------
PROCEDURE PropogateReceiptCustFldsInfo(
		p_receipt_custom_fields_array	IN CustomFields_A,
		p_receipt_index			IN BINARY_INTEGER,
		p_custom1_array			IN OUT NOCOPY CustomFields_A,
		p_custom2_array			IN OUT NOCOPY CustomFields_A,
		p_custom3_array			IN OUT NOCOPY CustomFields_A,
		p_custom4_array			IN OUT NOCOPY CustomFields_A,
		p_custom5_array			IN OUT NOCOPY CustomFields_A,
		p_custom6_array			IN OUT NOCOPY CustomFields_A,
		p_custom7_array			IN OUT NOCOPY CustomFields_A,
		p_custom8_array			IN OUT NOCOPY CustomFields_A,
		p_custom9_array			IN OUT NOCOPY CustomFields_A,
		p_custom10_array		IN OUT NOCOPY CustomFields_A,
		p_custom11_array		IN OUT NOCOPY CustomFields_A,
		p_custom12_array		IN OUT NOCOPY CustomFields_A,
		p_custom13_array		IN OUT NOCOPY CustomFields_A,
		p_custom14_array		IN OUT NOCOPY CustomFields_A,
		p_custom15_array		IN OUT NOCOPY CustomFields_A)
---------------------------------------------------------------------------
IS
  l_debug_info			VARCHAR2(2000);
  l_curr_calling_sequence	VARCHAR2(200) := 'PropogateReceiptCustFldsInfo';
BEGIN

  BEGIN
  p_custom1_array(p_receipt_index) := p_receipt_custom_fields_array(1);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     null;
  END;
  BEGIN
  p_custom2_array(p_receipt_index) := p_receipt_custom_fields_array(2);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     null;
  END;
  BEGIN
  p_custom3_array(p_receipt_index) := p_receipt_custom_fields_array(3);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     null;
  END;
  BEGIN
  p_custom4_array(p_receipt_index) := p_receipt_custom_fields_array(4);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     null;
  END;
  BEGIN
  p_custom5_array(p_receipt_index) := p_receipt_custom_fields_array(5);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     null;
  END;
  BEGIN
  p_custom6_array(p_receipt_index) := p_receipt_custom_fields_array(6);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     null;
  END;
  BEGIN
  p_custom7_array(p_receipt_index) := p_receipt_custom_fields_array(7);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     null;
  END;
  BEGIN
  p_custom8_array(p_receipt_index) := p_receipt_custom_fields_array(8);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     null;
  END;
  BEGIN
  p_custom9_array(p_receipt_index) := p_receipt_custom_fields_array(9);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     null;
  END;
  BEGIN
  p_custom10_array(p_receipt_index) := p_receipt_custom_fields_array(10);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     null;
  END;
  BEGIN
  p_custom11_array(p_receipt_index) := p_receipt_custom_fields_array(11);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     null;
  END;
  BEGIN
  p_custom12_array(p_receipt_index) := p_receipt_custom_fields_array(12);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     null;
  END;
  BEGIN
  p_custom13_array(p_receipt_index) := p_receipt_custom_fields_array(13);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     null;
  END;
  BEGIN
  p_custom14_array(p_receipt_index) := p_receipt_custom_fields_array(14);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     null;
  END;
  BEGIN
  p_custom15_array(p_receipt_index) := p_receipt_custom_fields_array(15);
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
     null;
  END;

EXCEPTION
  WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
END PropogateReceiptCustFldsInfo;

---------------------------------------------------------------------------
PROCEDURE AssocCustFieldPromptsToValues(
			p_dflex_segs		IN FND_DFLEX.SEGMENTS_DR,
                        p_starting_index	IN BINARY_INTEGER,
                        p_ending_index		IN BINARY_INTEGER,
			p_custom_fields_array   IN OUT NOCOPY CustomFields_A)
---------------------------------------------------------------------------
IS
  l_index_ref_ordered_array	BINARY_INTEGER_A;
  l_debug_info			VARCHAR2(2000);
  cf_ind			BINARY_INTEGER := NULL;
  next_seg			BINARY_INTEGER := 1;
  l_curr_calling_sequence	VARCHAR2(200) := 'AssocCustFieldPromptToValues';
TEST EXCEPTION;
BEGIN

  FOR cf_ind IN p_starting_index..p_ending_index LOOP

    FOR seg_ind IN next_seg..p_dflex_segs.nsegments LOOP

      next_seg := next_seg + 1;

      IF (p_dflex_segs.is_enabled(seg_ind)) THEN

        p_custom_fields_array(cf_ind).prompt :=
			    p_dflex_segs.segment_name(seg_ind);
        p_custom_fields_array(cf_ind).user_prompt :=
                            p_dflex_segs.row_prompt(seg_ind);
        p_custom_fields_array(cf_ind).column_mapping :=
			    p_dflex_segs.application_column_name(seg_ind);

        IF (p_dflex_segs.is_displayed(seg_ind)) THEN
          p_custom_fields_array(cf_ind).displayed_flag := 'Y';
	ELSE
          p_custom_fields_array(cf_ind).displayed_flag := 'N';
        END IF;

        IF (p_dflex_segs.is_required(seg_ind)) THEN
          p_custom_fields_array(cf_ind).required_flag  := 'Y';
	ELSE
          p_custom_fields_array(cf_ind).required_flag := 'N';
        END IF;

        p_custom_fields_array(cf_ind).display_size :=
			    to_number(p_dflex_segs.display_size(seg_ind));
        p_custom_fields_array(cf_ind).value_set :=
					p_dflex_segs.value_set(seg_ind);

        EXIT;

      END IF;
    END LOOP;

  END LOOP;
EXCEPTION
  WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
END AssocCustFieldPromptsToValues;

---------------------------------------------------------------------------
FUNCTION GetCustomFieldValue(p_prompt			IN VARCHAR2,
	      p_custom_fields_array	IN CustomFields_A) RETURN VARCHAR2
---------------------------------------------------------------------------
IS
l_nfields			BINARY_INTEGER := p_custom_fields_array.count;
l_curr_calling_sequence		VARCHAR2(200) := 'GetCustomFieldValue';
l_debug_info			VARCHAR2(2000);
BEGIN
  l_debug_info := l_nfields;
  FOR i in 1..l_nfields LOOP
     IF (upper(p_custom_fields_array(i).prompt) = upper(p_prompt)) THEN
      return(p_custom_fields_array(i).value);
    END IF;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
END GetCustomFieldValue;

------------------------------------------------------------------------------
PROCEDURE ProcessDFlexError(
	p_custom_fields_array	IN CustomFields_A,
	p_num_of_global_fields	IN BINARY_INTEGER,
	p_num_of_context_fields	IN BINARY_INTEGER,
        p_error                 IN OUT NOCOPY AP_WEB_UTILITIES_PKG.expError,
	p_receipt_index		IN BINARY_INTEGER DEFAULT NULL
)
------------------------------------------------------------------------------
IS
  l_error_seg			NUMBER := FND_FLEX_DESCVAL.error_segment;
  l_debug_info			VARCHAR2(2000);
  l_curr_calling_sequence	VARCHAR2(2000)  := 'ProcessDFlexError';
  V_MessageText                 VARCHAR2(2000);

BEGIN

  IF (NOT FND_FLEX_DESCVAL.is_valid) THEN

    IF (l_error_seg IS NOT NULL) THEN

    IF (l_error_seg > (p_num_of_global_fields + 1)) THEN
      l_error_seg := l_error_seg - 1;
     END IF;



      -- !!! Set message with segment num and error_messag
    V_MessageText := p_custom_fields_array(l_error_seg).user_prompt ||'-'|| FND_FLEX_DESCVAL.error_Message ;


    ELSE

      V_MessageText := FND_FLEX_DESCVAL.error_message;


    END IF;

    AP_WEB_UTILITIES_PKG.AddExpErrorNotEncoded(p_error,v_MessageText,AP_WEB_UTILITIES_PKG.C_ErrorMessageType,'FlexField', p_receipt_index,AP_WEB_UTILITIES_PKG.C_DFFMessageCategory);



  END IF;

EXCEPTION
  WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
END ProcessDFlexError;

------------------------------------------------------------------------------
PROCEDURE CoreValidateDFlexValues(
	p_dflex_name	      	IN VARCHAR2,
	p_dflex_contexts	IN FND_DFLEX.CONTEXTS_DR,
	p_context_index	      	IN BINARY_INTEGER,
	p_custom_fields_array   IN CustomFields_A,
	p_num_of_global_fields	IN BINARY_INTEGER,
	p_num_of_context_fields	IN BINARY_INTEGER,
	p_receipt_errors	IN OUT NOCOPY AP_WEB_UTILITIES_PKG.Receipt_Error_Stack,
	p_receipt_index		IN BINARY_INTEGER,
        p_error                 IN OUT NOCOPY  AP_WEB_UTILITIES_PKG.expError       )
------------------------------------------------------------------------------
IS
  l_resp_appl_id		NUMBER;
  l_resp_id			NUMBER;
  l_debug_info			VARCHAR2(2000);
  l_num_of_cust_fields		BINARY_INTEGER := p_num_of_global_fields +
                                                   nvl(p_num_of_context_fields, 0);
  l_curr_calling_sequence	VARCHAR2(200) := 'CoreValidateDflexValues';
  TEST				EXCEPTION;

BEGIN

  IF ((p_num_of_context_fields IS NULL) or (p_num_of_context_fields=0)) THEN

    FND_FLEX_DESCVAL.Set_Context_Value(null);

  ELSE
  --------------------------------------------
  l_debug_info := 'Setting the Context Value';
  --------------------------------------------
    FND_FLEX_DESCVAL.Set_Context_Value(p_dflex_contexts.context_code(p_context_index));
  END IF;

  FOR i in 1..l_num_of_cust_fields LOOP

      -----------------------------------------------------------
      l_debug_info := 'Inside for loop for index ' || p_custom_fields_array(i).column_mapping || ' ' || p_custom_fields_array(i).value;
      -----------------------------------------------------------


    FND_FLEX_DESCVAL.Set_Column_Value(p_custom_fields_array(i).column_mapping,
				      p_custom_fields_array(i).value);

  END LOOP;

  ------------------------------------------------
  l_debug_info := 'Calling FND Validate_Desccols';
  ------------------------------------------------
  IF (NOT FND_FLEX_DESCVAL.Validate_Desccols('SQLAP',
				    p_dflex_name,
				    'I',
				    sysdate,
				    TRUE,
                                    l_resp_appl_id,
				    l_resp_id)) THEN
    -------------------------------------------
    l_debug_info := 'Calling ProcessDflexError';
    -------------------------------------------

    ProcessDflexError(p_custom_fields_array,
		      p_num_of_global_fields,
		      p_num_of_context_fields,
                      p_error,
		      p_receipt_index );

  END IF;



EXCEPTION
  WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('SQLAemacs P','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
END CoreValidateDFlexValues;

------------------------------------------------------------------------------
PROCEDURE ValidateDFlexValues(
	p_exp_header_info	IN ExpReportHeaderRec,
	p_exp_line_info		IN ExpReportLineRec,
	p_custom_fields_array	IN CustomFields_A,
	p_num_of_global_fields	IN BINARY_INTEGER
,	p_num_of_context_fields	IN BINARY_INTEGER,
        p_dflex_name		IN VARCHAR2,
	p_dflex_contexts	IN FND_DFLEX.CONTEXTS_DR,
	p_context_index		IN BINARY_INTEGER,
	p_receipt_errors	IN OUT NOCOPY AP_WEB_UTILITIES_PKG.Receipt_Error_Stack,
	p_receipt_index		IN BINARY_INTEGER,
        p_error                 IN OUT NOCOPY AP_WEB_UTILITIES_PKG.expError)
------------------------------------------------------------------------------
IS
  l_dummy_field_rec		CustomFieldRec;
  l_result_message		VARCHAR2(2000) := NULL;
  l_message_type		VARCHAR2(2000) := NULL;
  l_num_of_cust_fields		BINARY_INTEGER := p_num_of_global_fields +
                                                  nvl(p_num_of_context_fields,0);
  l_debug_info			VARCHAR2(2000);
  l_curr_calling_sequence	VARCHAR2(200) := 'ValidateDflexValues';
  l_error                       AP_WEB_UTILITIES_PKG.expError;

BEGIN


  --------------------------------------------------
  l_debug_info := 'Calling CoreValidateDFlexValues';
  --------------------------------------------------
  CoreValidateDFlexValues(p_dflex_name,
			  p_dflex_contexts,
			  p_context_index,
			  p_custom_fields_array,
			  p_num_of_global_fields,
                          p_num_of_context_fields,
			  p_receipt_errors,
			  p_receipt_index,
                          l_error   );

  --------------------------------------------------
  l_debug_info := 'Calling CustomValidateDFlexValues';
  --------------------------------------------------
  AP_WEB_CUST_DFLEX_PKG.CustomValidateDFlexValues(p_exp_header_info,
			    p_exp_line_info,
			    p_custom_fields_array,
			    l_dummy_field_rec,
			    'LINE',
			    l_result_message,
                            l_message_type,
			    p_receipt_index);


  IF (UPPER(l_message_type) = C_CustValidResMsgTypeError) AND
     (l_result_message IS NOT NULL) THEN

    ---------------------------------------------------------------
    l_debug_info := 'Appending Line Custom Validate Error Message';
    ---------------------------------------------------------------


    AP_WEB_UTILITIES_PKG.AddExpErrorNotEncoded(p_error,l_result_message,
			AP_WEB_UTILITIES_PKG.C_ErrorMessageType,'CustomValidate', p_receipt_index,AP_WEB_UTILITIES_PKG.C_DFFMessageCategory);

  END IF;

  FOR i IN 1..l_num_of_cust_fields LOOP

  ---------------------------------------------------------------------------
  l_debug_info := 'Calling CustomValidateDFlexValues for field ' || to_char(i);
  --------------------------------------------------------------------------
    l_result_message := NULL;
    l_message_type := NULL;
    AP_WEB_CUST_DFLEX_PKG.CustomValidateDFlexValues(p_exp_header_info,
			      p_exp_line_info,
			      p_custom_fields_array,
			      p_custom_fields_array(i),
			      'FIELD',
			      l_result_message,
			      l_message_type,
			      p_receipt_index);

  IF (UPPER(l_message_type) = C_CustValidResMsgTypeError) AND
     (l_result_message IS NOT NULL) THEN

    ---------------------------------------------------
    l_debug_info := 'Appending Custom Validate errors';
    ---------------------------------------------------

  AP_WEB_UTILITIES_PKG.AddExpErrorNotEncoded(p_error,l_result_message,AP_WEB_UTILITIES_PKG.C_ErrorMessageType,'AppendingCustomValidate', p_receipt_index,AP_WEB_UTILITIES_PKG.C_DFFMessageCategory);


/*  To avoid duplicate messages in the New UI
  AP_WEB_UTILITIES_PKG.AddMessage(p_receipt_errors,
        p_receipt_index,
        AP_WEB_UTILITIES_PKG.C_ErrorMessageType,
        l_result_message,
        31);
*/

   END IF;

  END LOOP;

--Priyai
  AP_WEB_UTILITIES_PKG.MergeExpErrors(p_error,l_error);


EXCEPTION
  WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                     l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
END ValidateDFlexValues;

-----------------------------------------------------------------------------
PROCEDURE PopulateExpTypeInLineRec(p_exp_line_info  IN OUT NOCOPY ExpReportLineRec)
-----------------------------------------------------------------------------
IS
  l_debug_info			VARCHAR2(2000);
  l_curr_calling_sequence	VARCHAR2(200) := 'PopulateExpTypeInLineRec';
  l_exp_prompt			AP_WEB_DB_EXPTEMPLATE_PKG.expTempl_webFriendlyPrompt;
BEGIN
      IF (AP_WEB_DB_EXPTEMPLATE_PKG.GetExpTypePrompt(
		to_number(p_exp_line_info.parameter_id), l_exp_prompt)) THEN
          p_exp_line_info.expense_type := l_exp_prompt;
      END IF;
EXCEPTION
  WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
END PopulateExpTypeInLineRec;

------------------------------------------------------------------------------
PROCEDURE PopulateCustomFieldsInfo(
        p_userId                   IN NUMBER,
	p_exp_line_info	 	   IN OUT NOCOPY ExpReportLineRec,
	p_custom_fields_array 	   IN OUT NOCOPY CustomFields_A,
        p_num_global_enabled_segs  IN OUT NOCOPY NUMBER,
        p_num_context_enabled_segs IN OUT NOCOPY NUMBER,
        p_dflexfield               IN OUT NOCOPY FND_DFLEX.DFLEX_R,
        p_dflexinfo                IN OUT NOCOPY FND_DFLEX.DFLEX_DR,
        p_dflexfield_contexts      IN OUT NOCOPY FND_DFLEX.CONTEXTS_DR,
        p_context_index            IN OUT NOCOPY NUMBER)
-------------------------------------------------------------------------------
IS
  l_dflexfield_name		FND_DESCRIPTIVE_FLEXS.Descriptive_Flexfield_Name%TYPE;
  l_dflex_context		FND_DFLEX.CONTEXT_R;
  l_dflex_global_segs		FND_DFLEX.SEGMENTS_DR;
  l_dflex_context_segs		FND_DFLEX.SEGMENTS_DR;
  l_is_dflexfield_used          BOOLEAN;

  l_debug_info			VARCHAR2(2000);
  l_curr_calling_sequence	VARCHAR2(200) := 'PopulateCustomFieldsInfo';
BEGIN

     -------------------------------------------------------
     l_debug_info := 'Check whether any expense type is specified';
     -------------------------------------------------------
     IF p_exp_line_info.parameter_id IS NULL THEN
       RETURN;
     END IF;

     -------------------------------------------------------
     l_debug_info := 'Retrieving FND Descriptive Flex Info';
     -------------------------------------------------------
     GetExpenseLineDFlexInfo(p_userId, -- 2377002
                             p_dflexfield,
		       	     p_dflexinfo,
		       	     p_dflexfield_contexts,
                             l_is_dflexfield_used);

     -- No need to populate custom fields with defaults since descriptive
     -- flexfield used.
     IF NOT l_is_dflexfield_used THEN
       RETURN;
     END IF;

     -------------------------------------------------------------------
     l_debug_info := 'Retrieving FND Descriptive Flex Context Segments';
     -------------------------------------------------------------------
     GetDFlexContextSegments(p_dflexfield,
		             p_dflexfield_contexts,
		             p_dflexfield_contexts.global_context,
		             l_dflex_global_segs);

     ----------------------------------------------------------
     l_debug_info := 'Retrieve Num of Global Enabled Segments';
     ----------------------------------------------------------
     p_num_global_enabled_segs :=
           GetNumOFEnabledSegments(l_dflex_global_segs);

     IF (p_num_global_enabled_segs > 0) THEN

       -----------------------------------------------------------------
       l_debug_info := 'Associating Global Custom Fields Info to Value';
       -----------------------------------------------------------------
       AssocCustFieldPromptsToValues(l_dflex_global_segs,
				     1,
				     p_num_global_enabled_segs,
				     p_custom_fields_array);

     END IF;

     ---------------------------------------------------
     l_debug_info := 'Calling PopulateExpTypeInLineRec';
     ---------------------------------------------------
     PopulateExpTypeInLineRec(p_exp_line_info);

     ------------------------------------------------------------
     l_debug_info := 'Retrieving Index for DFlex Context Value';
     ------------------------------------------------------------
     GetDFlexContextIndex(p_exp_line_info.expense_type,
		          p_dflexfield_contexts,
		          p_context_index);

     IF (p_context_index IS NOT NULL) THEN

       -- bug 3597789 - Check if context is Enabled prior to verifying if
       -- context segments are enabled.
       IF p_dflexfield_contexts.is_enabled(p_context_index) THEN

          ----------------------------------------------------
          l_debug_info := 'Retrieve FND Dflex Context Values';
          ----------------------------------------------------
          GetDFlexContextSegments(p_dflexfield,
		               p_dflexfield_contexts,
		               p_context_index,
		               l_dflex_context_segs);

          ----------------------------------------------------------
          l_debug_info := 'Retrieve Num of Context Enabled Segments';
          ----------------------------------------------------------
          p_num_context_enabled_segs :=
           GetNumOFEnabledSegments(l_dflex_context_segs);

          IF (p_num_context_enabled_segs > 0) THEN

            -----------------------------------------------------------------
            l_debug_info := 'Associating Context Custom Fields Info to Value';
            -----------------------------------------------------------------
            AssocCustFieldPromptsToValues(l_dflex_context_segs,
				      p_num_global_enabled_segs+1,
				      p_num_global_enabled_segs + p_num_context_enabled_segs,
				      p_custom_fields_array);

          END IF; -- l_context_dflex_segs.nsegments > 0
      ELSE
        p_num_context_enabled_segs := NULL;
      END IF;
    ELSE

      -- p_num_context_enabled_segs equaling NULL means this context is not
      -- defined to distinguish the case that context is defined but no segs
      -- have been defined.
      p_num_context_enabled_segs := NULL;
    END IF;  -- l_context_index IS NOT NULL

EXCEPTION
  WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
END PopulateCustomFieldsInfo;




------------------------------------------------------------------------------
PROCEDURE ValidateReceiptCustomFields(
    	p_userId		      	        IN 	NUMBER,
	p_exp_header_info	IN ExpReportHeaderRec,
	p_exp_line_info	 	IN OUT NOCOPY ExpReportLineRec,
	p_custom_fields_array 	IN OUT NOCOPY CustomFields_A,
	p_receipt_errors	IN OUT NOCOPY AP_WEB_UTILITIES_PKG.Receipt_Error_Stack,
	p_receipt_index		IN BINARY_INTEGER,
        p_error                 IN OUT NOCOPY AP_WEB_UTILITIES_PKG.expError)
-------------------------------------------------------------------------------
IS
  l_dflexfield		FND_DFLEX.DFLEX_R;
  l_dflexinfo		FND_DFLEX.DFLEX_DR;
  l_dflexfield_name	FND_DESCRIPTIVE_FLEXS.Descriptive_Flexfield_Name%TYPE;
  l_dflex_context	FND_DFLEX.CONTEXT_R;
  l_dflex_contexts	FND_DFLEX.CONTEXTS_DR;
  l_dflex_global_segs	FND_DFLEX.SEGMENTS_DR;
  l_dflex_context_segs		FND_DFLEX.SEGMENTS_DR;
  l_num_global_enabled_segs	NUMBER;
  l_num_context_enabled_segs	NUMBER;
  l_context_index		BINARY_INTEGER := NULL;
  l_debug_info			VARCHAR2(2000);
  l_curr_calling_sequence	VARCHAR2(200) := 'ValidateReceiptCustomFields';
  l_dflex_enabled    VARCHAR2(1) := NULL;
  l_num_of_cust_fields		BINARY_INTEGER := NULL;
  V_ValueSetInfo        FND_VSET.VALUESET_R;
  V_ValueSetFormat      FND_VSET.VALUESET_DR;
  V_Date		DATE;
  V_Date_Format                 VARCHAR2(30);
  p_format_type		VARCHAR2(1);
  p_number_precision	NUMBER(2);


BEGIN
    -- Bug 2188747 we need to able to user the profile option of the employee instead of the preparer
    l_debug_info := 'Get AP_WEB_DESC_FLEX_NAME profile option';
    if (p_userId is null) then -- user loggon
        l_dflex_enabled := FND_PROFILE.VALUE('AP_WEB_DESC_FLEX_NAME');
    else
        l_dflex_enabled := AP_WEB_UTILITIES_PKG.VALUE_SPECIFIC(
					p_name    => 'AP_WEB_DESC_FLEX_NAME',
					p_user_id => p_userId,
					p_resp_id => null,
					p_apps_id => null);
    end if;

    -- if (l_dflex_enabled <> 'Y') then
    -- Bug 3985122 Y-Lines Only, B - Both Header and Lines, H - Header Only
    if ((nvl(l_dflex_enabled,'N') = 'N') OR (nvl(l_dflex_enabled,'N') = 'H')) then
        return;
    end if;

    -----------------------------------------------
    l_debug_info := 'populate custom field array';
    -----------------------------------------------
    PopulateCustomFieldsInfo(p_userId,
                             p_exp_line_info,
                             p_custom_fields_array,
                             l_num_global_enabled_segs,
                             l_num_context_enabled_segs,
                             l_dflexfield,
                             l_dflexinfo,
                             l_dflex_contexts,
                             l_context_index);

    -- If there are no segments to validate we will not call the validation
    -- routine.  There is a bug in validate_desccols that produces a numeric
    -- or value error if a context value is defined but no segments are
    -- defined.  It should produce a warning not cause an error.
    IF (l_num_global_enabled_segs + nvl(l_num_context_enabled_segs,0) > 0) THEN

      -- Bug# 7650153 - Converting date into canonical date format for dff segments
      l_num_of_cust_fields := l_num_global_enabled_segs + nvl(l_num_context_enabled_segs,0);
      FOR i in 1..l_num_of_cust_fields LOOP

    	GetValueSet(p_custom_fields_array(i).value_set,V_ValueSetInfo,V_ValueSetFormat);
    	IF (V_ValueSetInfo.name = 'FND_STANDARD_DATE') AND (p_custom_fields_array(i).value IS NOT NULL) THEN
    	   V_Date_Format := nvl(icx_sec.g_date_format,icx_sec.getNLS_PARAMETER('NLS_DATE_FORMAT'));
	   V_Date := FND_DATE.string_to_date(p_custom_fields_array(i).value,V_Date_Format);
	   IF (V_Date IS NOT NULL) THEN
	     p_custom_fields_array(i).value := FND_DATE.date_to_canonical(V_Date);
	   END IF;
	-- Bug# 8444154 - Decimal digits of the segment value should be equal to the number precision defined for the value set
	ELSIF (p_custom_fields_array(i).value_set IS NOT NULL) THEN
	   begin
		select format_type, number_precision into p_format_type, p_number_precision
		from fnd_flex_value_sets where flex_value_set_id = p_custom_fields_array(i).value_set;
	   exception
	   when others then
		p_format_type := null;
		p_number_precision := 0;
	   end;
	   IF ((p_format_type = 'N' AND p_number_precision > 0) AND (p_custom_fields_array(i).value IS NOT NULL)) THEN
	      p_custom_fields_array(i).value := Rtrim(Ltrim(p_custom_fields_array(i).value));
	      p_custom_fields_array(i).value := Rpad(p_custom_fields_array(i).value, p_number_precision + instr(p_custom_fields_array(i).value,'.'), '0');
	   END IF;
    	END IF;

      END LOOP;

      -----------------------------------------------
      l_debug_info := 'Calling ValidateDFlexValues';
      -----------------------------------------------
      ValidateDFlexValues(p_exp_header_info,
                        p_exp_line_info,
                        p_custom_fields_array,
                        l_num_global_enabled_segs,
                        l_num_context_enabled_segs,
                        l_dflexfield.flexfield_name,
                        l_dflex_contexts,
                        l_context_index,
                        p_receipt_errors,
                        p_receipt_index,
                        p_error);


     END IF;

EXCEPTION
  WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
END ValidateReceiptCustomFields;

----------------------------------------------------------------------------
PROCEDURE PopulateCustomFieldsInfoAll(
        p_report_lines_info   IN OUT NOCOPY ExpReportLines_A,
        p_custom1_array       IN OUT NOCOPY CustomFields_A,
        p_custom2_array       IN OUT NOCOPY CustomFields_A,
        p_custom3_array       IN OUT NOCOPY CustomFields_A,
        p_custom4_array       IN OUT NOCOPY CustomFields_A,
        p_custom5_array       IN OUT NOCOPY CustomFields_A,
        p_custom6_array       IN OUT NOCOPY CustomFields_A,
        p_custom7_array       IN OUT NOCOPY CustomFields_A,
        p_custom8_array       IN OUT NOCOPY CustomFields_A,
        p_custom9_array       IN OUT NOCOPY CustomFields_A,
        p_custom10_array      IN OUT NOCOPY CustomFields_A,
        p_custom11_array      IN OUT NOCOPY CustomFields_A,
        p_custom12_array      IN OUT NOCOPY CustomFields_A,
        p_custom13_array      IN OUT NOCOPY CustomFields_A,
        p_custom14_array      IN OUT NOCOPY CustomFields_A,
        p_custom15_array      IN OUT NOCOPY CustomFields_A,
	p_receipts_count      IN     BINARY_INTEGER)
----------------------------------------------------------------------------
IS

  l_receipt_custom_fields_array  CustomFields_A;
  l_receipt_index		       BINARY_INTEGER := 1;
  l_unexp_err		       	VARCHAR2(2000);

  l_dflexfield			FND_DFLEX.DFLEX_R;
  l_dflexinfo			FND_DFLEX.DFLEX_DR;
  l_dflex_contexts		FND_DFLEX.CONTEXTS_DR;
  l_num_global_enabled_segs	NUMBER;
  l_num_context_enabled_segs	NUMBER;
  l_context_index		BINARY_INTEGER := NULL;

  l_curr_calling_sequence	VARCHAR2(200) := 'PopulateCustomFieldsInfoAll';
  l_debug_info		       	VARCHAR2(2000);


BEGIN

  FOR l_receipt_index in 1 .. p_receipts_count LOOP

     -----------------------------------------------------
     l_debug_info := 'GetReceiptCustomFields';
     -----------------------------------------------------

     AP_WEB_DFLEX_PKG.GetReceiptCustomFields(l_receipt_custom_fields_array,
					     l_receipt_index,
					     p_custom1_array,
					     p_custom2_array,
					     p_custom3_array,
					     p_custom4_array,
					     p_custom5_array,
					     p_custom6_array,
					     p_custom7_array,
					     p_custom8_array,
					     p_custom9_array,
					     p_custom10_array,
					     p_custom11_array,
					     p_custom12_array,
					     p_custom13_array,
					     p_custom14_array,
					     p_custom15_array);

     -----------------------------------------------------
     l_debug_info := 'ValidateReceiptCustomFields';
     -----------------------------------------------------
     PopulateCustomFieldsInfo(null,
                              p_report_lines_info(l_receipt_index),
                              l_receipt_custom_fields_array,
                              l_num_global_enabled_segs,
                              l_num_context_enabled_segs,
                              l_dflexfield,
                              l_dflexinfo,
                              l_dflex_contexts,
                              l_context_index);

     -----------------------------------------------------
     l_debug_info := 'PropogateReceiptCustFldsInfo';
     -----------------------------------------------------
     AP_WEB_DFLEX_PKG.PropogateReceiptCustFldsInfo(
					     l_receipt_custom_fields_array,
					     l_receipt_index,
					     p_custom1_array,
					     p_custom2_array,
					     p_custom3_array,
					     p_custom4_array,
					     p_custom5_array,
					     p_custom6_array,
					     p_custom7_array,
					     p_custom8_array,
					     p_custom9_array,
					     p_custom10_array,
					     p_custom11_array,
					     p_custom12_array,
					     p_custom13_array,
					     p_custom14_array,
					     p_custom15_array);

   END LOOP;

EXCEPTION
  WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
        FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
        FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                    l_curr_calling_sequence);
        FND_MESSAGE.SET_TOKEN('DEBUG_INFO',l_debug_info);
        AP_WEB_UTILITIES_PKG.DisplayException(fnd_message.get);
END PopulateCustomFieldsInfoAll;


PROCEDURE SetExpReportLineInfo(P_ExpReportLineInfo          OUT NOCOPY ExpReportLineRec,
                               P_receipt_index                  IN      NUMBER,
                               P_start_date			IN	DATE,
                               P_end_date			IN	DATE,
                               P_days				IN	VARCHAR2,
                               P_daily_amount			IN	VARCHAR2,
                               P_receipt_amount			IN	VARCHAR2,
                               P_rate				IN	VARCHAR2,
                               P_amount				IN	VARCHAR2,
                               P_parameter_id			IN	VARCHAR2,
                               P_expense_type			IN	VARCHAR2,
                               P_currency_code			IN	VARCHAR2,
                               P_group_value			IN	VARCHAR2,
                               P_justification			IN	VARCHAR2,
                               P_receipt_missing_flag		IN	VARCHAR2,
                               P_validation_required		IN	VARCHAR2,
                               P_calculate_flag			IN	VARCHAR2,
                               P_calculated_amount		IN	VARCHAR2,
                               P_copy_calc_amt_into_receipt	IN	VARCHAR2,
                               P_AmtInclTax                     IN      VARCHAR2,
                               P_TaxCode                        IN      VARCHAR2,
			       P_TaxOverrideFlag		IN	VARCHAR2,
			       P_TaxId				IN	VARCHAR2,
                               P_ProjectID                      IN      VARCHAR2,
                               P_ProjectNumber                  IN      VARCHAR2,
                               P_TaskID                         IN      VARCHAR2,
                               P_TaskNumber                     IN      VARCHAR2,
                               P_ExpenditureType                IN      VARCHAR2)

IS
	current_calling_sequence varchar2(255) := 'SetExpReportLineInfo';
	debug_info varchar2(255) := '';

BEGIN
  debug_info := 'Begin SetExpReportLineInfo';
  P_ExpReportLineInfo.receipt_index := P_receipt_index;
  P_ExpReportLineInfo.start_date := P_start_date;
  P_ExpReportLineInfo.end_date := P_end_date;
  P_ExpReportLineInfo.days := P_days;
  P_ExpReportLineInfo.daily_amount := P_daily_amount;
  P_ExpReportLineInfo.receipt_amount := P_receipt_amount;

  P_ExpReportLineInfo.rate := P_rate;
  P_ExpReportLineInfo.amount := P_amount;
  P_ExpReportLineInfo.parameter_id := P_parameter_id;
  P_ExpReportLineInfo.expense_type := P_expense_type;
  P_ExpReportLineInfo.currency_code := P_currency_code;
  P_ExpReportLineInfo.group_value := P_group_value;
  P_ExpReportLineInfo.justification := P_justification;
  P_ExpReportLineInfo.receipt_missing_flag := P_receipt_missing_flag;
  P_ExpReportLineInfo.validation_required := P_validation_required;
  P_ExpReportLineInfo.calculate_flag := P_calculate_flag;
  P_ExpReportLineInfo.calculated_amount := P_calculated_amount;
  P_ExpReportLineInfo.copy_calc_amt_into_receipt_amt := P_copy_calc_amt_into_receipt;
  P_ExpReportLineInfo.amount_includes_tax := P_AmtInclTax;
  P_ExpReportLineInfo.tax_code := P_TaxCode;
  P_ExpReportLineInfo.taxOverrideFlag := P_TaxOverrideFlag;
  P_ExpReportLineInfo.taxId := P_TaxId;
  P_ExpReportLineInfo.project_id := P_ProjectID;
  P_ExpReportLineInfo.project_number := P_ProjectNumber;
  P_ExpReportLineInfo.task_id := P_TaskID;
  P_ExpReportLineInfo.task_number := P_TaskNumber;
  P_ExpReportLineInfo.expenditure_type := P_ExpenditureType;

EXCEPTION
  WHEN OTHERS THEN
    BEGIN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                   current_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
               'amount = ' || P_amount ||
		'currency_code = ' || P_currency_code ||
		'receipt_amount = ' || P_receipt_amount ||
		'rate = ' || P_rate ||
		'parameter_id = ' || P_parameter_id
			);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      APP_EXCEPTION.RAISE_EXCEPTION;
    END;

END SetExpReportLineInfo;

PROCEDURE SetExpReportHeaderInfo(P_ExpReportHeaderInfo    OUT NOCOPY ExpReportHeaderRec,
                                 P_employee_id		      	IN	VARCHAR2,
                                 P_cost_center		      	IN	VARCHAR2,
                                 P_expense_report_id	      	IN	VARCHAR2,
                                 P_template_name		IN	VARCHAR2,
                                 P_purpose		      	IN	VARCHAR2,
                                 P_last_receipt_date		IN	VARCHAR2,
                                 P_receipt_count		IN	VARCHAR2,
                                 P_transaction_currency_type	IN	VARCHAR2,
                                 P_reimbursement_currency_code	IN	VARCHAR2,
                                 P_reimbursement_currency_name	IN	VARCHAR2,
                                 P_multi_currency_flag		IN	VARCHAR2,
                                 P_inverse_rate_flag		IN	VARCHAR2,
                                 P_approver_id			IN	VARCHAR2,
                                 P_approver_name		IN	VARCHAR2,
                                 P_expenditure_organization_id  IN      VARCHAR2 DEFAULT NULL)
IS
 	current_calling_sequence varchar2(255) := 'SetExpReportHeaderInfo';
	debug_info varchar2(255) := '';
BEGIN
  debug_info := 'Begin SetExpReportHeaderInfo';

  P_ExpReportHeaderInfo.receipt_count := P_receipt_count;
  P_ExpReportHeaderInfo.last_receipt_date := P_last_receipt_date;
  P_ExpReportHeaderInfo.override_approver_id := P_approver_id;
  P_ExpReportHeaderInfo.override_approver_name := P_approver_name;
  P_ExpReportHeaderInfo.cost_center := P_cost_center;
  P_ExpReportHeaderInfo.employee_id := P_employee_id;
  P_ExpReportHeaderInfo.template_id := P_expense_report_id;
  P_ExpReportHeaderInfo.template_name := P_template_name;
  P_ExpReportHeaderInfo.reimbursement_currency_code := P_reimbursement_currency_code;
  P_ExpReportHeaderInfo.reimbursement_currency_name := P_reimbursement_currency_name;
  P_ExpReportHeaderInfo.transaction_currency_type := P_transaction_currency_type;
  P_ExpReportHeaderInfo.multi_currency_flag := P_multi_currency_flag;
  P_ExpReportHeaderInfo.inverse_rate_flag := P_inverse_rate_flag;
  P_ExpReportHeaderInfo.purpose := P_purpose;
  P_ExpReportHeaderInfo.expenditure_organization_id := P_expenditure_organization_id;

EXCEPTION
  WHEN OTHERS THEN
    BEGIN
      FND_MESSAGE.SET_NAME('SQLAP','AP_DEBUG');
      FND_MESSAGE.SET_TOKEN('ERROR',SQLERRM);
      FND_MESSAGE.SET_TOKEN('CALLING_SEQUENCE',
                   current_calling_sequence);
      FND_MESSAGE.SET_TOKEN('PARAMETERS',
               'employee_id = ' || P_employee_id
			);
      FND_MESSAGE.SET_TOKEN('DEBUG_INFO',debug_info);
      APP_EXCEPTION.RAISE_EXCEPTION;
    END;


END SetExpReportHeaderInfo;



END AP_WEB_DFLEX_PKG;

/
