--------------------------------------------------------
--  DDL for Package Body QA_SSQR_JRAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_SSQR_JRAD_PKG" AS
/* $Header: qajrmpb.pls 120.26.12010000.6 2010/02/19 11:35:26 skolluku ship $ */

TYPE ParentArray IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
-- 12.1 Device Integration Project
-- Added Suffix parameter to this method.
-- bhsankar Wed Oct 24 04:45:16 PDT 2007
FUNCTION construct_code (p_prefix  IN VARCHAR2, p_id IN VARCHAR2, p_suffix IN VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2 IS

BEGIN

   -- The function is the standard way to compute attribute and
   -- region codes.

   -- 12.1 Device Integration Project
   -- Appending suffix as well.
   -- bhsankar Wed Oct 24 04:45:16 PDT 2007
   RETURN (p_prefix ||p_id ||p_suffix);

END construct_code;

-- 12.1 Inline Project
-- adding debug API's for better debugging
-- saugupta
procedure set_debug_mode(p_mode IN VARCHAR2) IS
begin
        IF (p_mode = 'QA_LOCAL') THEN
                g_debug_mode := p_mode;
        END IF;
end set_debug_mode;

procedure log_local_error( p_module_name IN VARCHAR2, p_error_message IN VARCHAR2, p_comments IN VARCHAR2 DEFAULT NULL)
IS
        pragma autonomous_transaction;
        x_logid number;
        cursor id
        IS
         SELECT qa_skiplot_log_id_s.nextval
         FROM dual;
BEGIN
        open id;
        fetch id into x_logid;
        close id;
        INSERT
        INTO    qa_skiplot_log
                (
                        LOG_ID,
                        MODULE_NAME,
                        ERROR_MESSAGE,
                        COMMENTS,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN
                )
                VALUES
                (
                        x_logid,
                        p_module_name,
                        p_error_message,
                        p_comments,
                        sysdate,
                        fnd_global.user_id,
                        sysdate,
                        fnd_global.user_id,
                        fnd_global.login_id
                )
                ;
        commit;
end log_local_error;

procedure log_error(p_api_name IN varchar2, p_error_message IN varchar2 )
IS
begin

      IF ( g_debug_mode = 'QA_LOCAL' ) THEN
          log_local_error(p_api_name, p_error_message);
      ELSE
          IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.string ( FND_LOG.LEVEL_STATEMENT,
                                 p_api_name,
                                 p_error_message );
          ELSIF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
                FND_LOG.string ( FND_LOG.LEVEL_PROCEDURE,
                                 p_api_name,
                                 p_error_message );
         END IF;
      END IF;  -- g_debug_mode
end log_error;



-- 12.1 Inline Project END

FUNCTION get_prompt (p_plan_id IN NUMBER,
    p_char_id IN NUMBER) RETURN VARCHAR2 IS

    l_prompt qa_plan_chars.prompt%TYPE;
    l_uom_code qa_plan_chars.uom_code%TYPE;
BEGIN
   -- The function is the standard way to compute prompt
   -- taking uom_code into account
    l_prompt := qa_plan_element_api.get_prompt(p_plan_id, p_char_id);
    l_uom_code := qa_plan_element_api.get_uom_code(p_plan_id, p_char_id);

    IF (l_uom_code is not null) THEN
      -- 12.1 QWB Usability Improvements
      -- Encode the HTML special characters
      -- ntungare
      --
      RETURN DBMS_XMLGEN.convert(l_prompt || ' (' || l_uom_code || ')');
    ELSE
      RETURN DBMS_XMLGEN.convert(l_prompt);
    END IF;
END get_prompt;


FUNCTION get_special_item_label (p_prefix IN VARCHAR2)
    RETURN VARCHAR2 IS

    label VARCHAR2(30);

BEGIN

    -- For some hardocded columns such as "Created By", "Colleciton"
    -- and "Last Update Date" we need to retrieve the right label
    -- keeping translation in mind.

    IF (p_prefix = g_qa_created_by_attribute) THEN
        label := fnd_message.get_string('QA','QA_SS_CREATED_BY');
    ELSIF (p_prefix = g_collection_id_attribute) THEN
        label := fnd_message.get_string('QA','QA_SS_COLLECTION');
    ELSIF (p_prefix = g_last_update_date_attribute) THEN
        label := fnd_message.get_string('QA','QA_SS_ENTRY_DATE');
    ELSIF (p_prefix = g_multi_row_attachment) THEN
        label := fnd_message.get_string('QA','QA_SS_JRAD_ATTACHMENT');
    ELSE
        label := null;
    END IF;

    -- 12.1 QWB Usability Improvements
    -- Encode the HTML special characters
    -- ntungare
    --
    RETURN DBMS_XMLGEN.convert(label);

END get_special_item_label;



FUNCTION get_vo_attribute_name (p_plan_id IN NUMBER, p_char_id IN NUMBER)
    RETURN VARCHAR2 IS

    column_name  VARCHAR2(100);

BEGIN

    -- For hardcoded elements, it returns developer name,
    -- For others, it returns results column name in qa plan chars.

    column_name := qa_core_pkg.get_result_column_name (p_char_id, p_plan_id);
    column_name := replace(column_name, 'CHARACTER', 'Character');
    column_name := replace(column_name, 'COMMENT', 'Comment');
    column_name := replace(column_name, 'SEQUENCE', 'Sequence');

    RETURN column_name;

END get_vo_attribute_name;



FUNCTION get_hardcoded_vo_attr_name (p_code IN VARCHAR2)
    RETURN VARCHAR2 IS

    column_name  VARCHAR2(100);

BEGIN

   -- This function retrieves the result column name for
   -- hard coded elements.

   IF (INSTR(p_code, g_org_id_attribute) <> 0) THEN
       column_name := 'ORGANIZATION_ID';
   ELSIF (INSTR(p_code, g_plan_id_attribute) <> 0) THEN
       column_name := 'PLAN_ID';
   ELSIF (INSTR(p_code, g_qa_created_by_attribute) <> 0) THEN
       column_name := 'QA_CREATED_BY_NAME';
   ELSIF (INSTR(p_code, g_collection_id_attribute) <> 0) THEN
       column_name := 'COLLECTION_ID';
   ELSIF (INSTR(p_code, g_last_update_date_attribute) <> 0) THEN
       column_name := 'LAST_UPDATE_DATE';
   ELSIF (INSTR(p_code, g_multi_row_attachment) <> 0) THEN
       column_name := '';
   END IF;

   RETURN column_name;

END get_hardcoded_vo_attr_name;


FUNCTION convert_data_type (p_data_type IN NUMBER)
    RETURN VARCHAR2 IS

BEGIN

    -- In Quality the data type is indicated by a number. whereas,
    -- in ak it a is string that describes what the data type is.
    -- This routine was written to convert the data_type according
    -- to AK.

    IF p_data_type in (g_char_datatype,g_comments_datatype,g_seq_datatype) THEN
        return 'VARCHAR2';
    ELSIF p_data_type = g_num_datatype THEN
        return 'NUMBER';
    ELSIF p_data_type = g_date_datatype THEN
        return 'DATE';
    -- bug 3236302. rkaza. 11/04/2003. Timezone support.
    ELSIF p_data_type = g_datetime_datatype THEN
        return 'DATETIME';
    ELSE --catch all
        return 'VARCHAR2';
    END IF;

END convert_data_type;


FUNCTION convert_yesno_flag (p_flag IN NUMBER)
    RETURN VARCHAR2 IS

BEGIN

    -- In Quality all the flags are numeric, meaning a value of 1 or 2
    -- is used to indicate if the flag is on or off.  In AK however,
    -- it is a character that describes if the flag is on or off.
    -- This routine was written to convert the Quality flags to AK.

    IF p_flag = 1 THEN
        return 'yes';
    ELSE
        return 'no';
    END IF;

END convert_yesno_flag;


FUNCTION convert_boolean_flag (p_flag IN NUMBER)
    RETURN VARCHAR2 IS

BEGIN

    -- In Quality all the flags are numeric, meaning a value of 1 or 2
    -- is used to indicate if the flag is on or off.  In AK however,
    -- it is a character that describes if the flag is on or off.
    -- This routine was written to convert the Quality flags to AK.

    IF p_flag = 1 THEN
        return 'true';
    ELSE
        return 'false';
    END IF;

END convert_boolean_flag;



FUNCTION compute_item_style (p_plan_id IN NUMBER, p_element_id IN NUMBER)
                                RETURN VARCHAR2 IS

BEGIN

    IF qa_plan_element_api.qpc_read_only_flag(p_plan_id, p_element_id) = 1
                or qa_chars_api.datatype(p_element_id) = g_seq_datatype THEN
        return 'messageStyledText';
    ELSIF qa_plan_element_api.qpc_poplist_flag(p_plan_id,
                p_element_id) = 1 then
        return 'messageChoice';
    ELSIF (qa_plan_element_api.values_exist(p_plan_id, p_element_id)
                OR qa_plan_element_api.sql_validation_exists(p_element_id)
                OR qa_chars_api.has_hardcoded_lov(p_element_id)) THEN
        return 'messageLovInput';
    ELSE
        return 'messageTextInput';
    END IF;

END compute_item_style;


 -- Bug 4506400. OA Framework Integration. UT bug fix.
 -- Set maximum length property for items.
 -- srhariha. Mon Aug 29 04:55:57 PDT 2005.

 --
 -- Get maximum length for region item.
 -- Data is fetched from FND_COLUMNS table.
 -- Important : For hardcoded elements following should be same as
 --             developer name.
 --             - VO ATTRIBUTE NAME
 --             - COLUMN NAME IN QA_RESULTS_INTERFACE
 --
 -- Returns -1 for error condition.
 --

FUNCTION get_max_length(p_column_name IN VARCHAR2) RETURN NUMBER IS

cursor c1 is
 select fc.width
 from fnd_columns fc, fnd_tables ft
 where fc.table_id = ft.table_id
 and ft.table_name = 'QA_RESULTS_INTERFACE'
 and ft.application_id = 250
 and fc.user_column_name = p_column_name
 and fc.application_id = 250; -- to use index

 l_width number;
BEGIN

 open c1 ;
 fetch c1 into l_width;
 close c1;

 if(l_width is null) then
   l_width := -1 ;
 end if;

 return l_width;

END get_max_length;




FUNCTION create_jrad_region_item(
    p_item_style IN VARCHAR2) RETURN JDR_DOCBUILDER.ELEMENT IS

BEGIN

    RETURN JDR_DOCBUILDER.createElement(jdr_docbuilder.OA_NS, p_item_style);

END create_jrad_region_item;



PROCEDURE add_child_to_parent(
    parent_element IN JDR_DOCBUILDER.ELEMENT,
    child_element IN JDR_DOCBUILDER.ELEMENT,
    p_tag_name IN VARCHAR2) IS

BEGIN
    -- p_tag_name can be 'contents', 'detail'
    JDR_DOCBUILDER.addChild(parent_element, JDR_DOCBUILDER.UI_NS, p_tag_name,
                                child_element);

END add_child_to_parent;




PROCEDURE get_lov_dependencies (p_char_id IN NUMBER,
                                x_parents OUT NOCOPY ParentArray) IS

BEGIN

    -- This is needed for populating correct lov relations.
    -- Given a element id, this function computes the
    -- ancestors for it and accordingly populates a
    -- OUT table structure.

    x_parents.delete();

    IF p_char_id = qa_ss_const.item THEN
        x_parents(1) := qa_ss_const.production_line;

    ELSIF p_char_id = qa_ss_const.to_op_seq_num THEN
        x_parents(1) := qa_ss_const.job_name;
        x_parents(2) := qa_ss_const.production_line;

    ELSIF p_char_id = qa_ss_const.from_op_seq_num THEN
        x_parents(1) := qa_ss_const.job_name;
        x_parents(2) := qa_ss_const.production_line;

    ELSIF p_char_id = qa_ss_const.to_intraoperation_step THEN
        x_parents(1) := qa_ss_const.to_op_seq_num;

    ELSIF p_char_id = qa_ss_const.from_intraoperation_step THEN
        x_parents(1) := qa_ss_const.from_op_seq_num;

    ELSIF p_char_id = qa_ss_const.uom THEN

        x_parents(1) := qa_ss_const.item;
        x_parents(2) := qa_ss_const.production_line;

    ELSIF p_char_id = qa_ss_const.revision THEN
        x_parents(1) := qa_ss_const.item;
        x_parents(2) := qa_ss_const.production_line;

    ELSIF p_char_id = qa_ss_const.subinventory THEN
        x_parents(1) := qa_ss_const.item;
        x_parents(2) := qa_ss_const.production_line;

    ELSIF p_char_id = qa_ss_const.locator THEN
        x_parents(1) := qa_ss_const.subinventory;
        x_parents(2) := qa_ss_const.item;
        x_parents(3) := qa_ss_const.production_line;

    -- anagarwa Thu Aug 12 15:49:51 PDT 2004
    -- bug 3830258 incorrect LOVs in QWB
    -- synced up the lot number lov with forms
    ELSIF p_char_id = qa_ss_const.lot_number THEN
        x_parents(1) := qa_ss_const.item;
        --x_parents(2) := qa_ss_const.production_line;

    -- anagarwa Thu Aug 12 15:49:51 PDT 2004
    -- bug 3830258 incorrect LOVs in QWB
    -- synced up the serial number lov with forms
    ELSIF p_char_id = qa_ss_const.serial_number THEN
        x_parents(1) := qa_ss_const.lot_number;
        x_parents(2) := qa_ss_const.item;
        --x_parents(3) := qa_ss_const.production_line;
        x_parents(3) := qa_ss_const.revision;

    ELSIF p_char_id = qa_ss_const.comp_uom THEN
        x_parents(1) := qa_ss_const.comp_item;

    ELSIF p_char_id = qa_ss_const.comp_revision THEN
        x_parents(1) := qa_ss_const.comp_item;

    ELSIF p_char_id = qa_ss_const.po_line_num THEN
        x_parents(1) := qa_ss_const.po_number;

    ELSIF p_char_id = qa_ss_const.po_shipment_num THEN
        x_parents(1) := qa_ss_const.po_line_num;
        x_parents(2) := qa_ss_const.po_number;

    ELSIF p_char_id = qa_ss_const.po_release_num THEN
        x_parents(1) := qa_ss_const.po_number;

    ELSIF p_char_id = qa_ss_const.order_line THEN
        x_parents(1) := qa_ss_const.sales_order;

    ELSIF p_char_id = qa_ss_const.task_number THEN
        x_parents(1) := qa_ss_const.project_number;

    --dgupta: Start R12 EAM Integration. Bug 4345492
    ELSIF p_char_id = qa_ss_const.asset_instance_number THEN
        x_parents(1) := qa_ss_const.asset_group;
        x_parents(2) := qa_ss_const.asset_number;

    ELSIF p_char_id = qa_ss_const.asset_number THEN
        x_parents(1) := qa_ss_const.asset_group;
        x_parents(2) := qa_ss_const.asset_instance_number;

    -- rkaza. 12/02/2003. bug 3215372.
    -- Both asset group and asset number were being assigned to x_parents(1)
    ELSIF p_char_id = qa_ss_const.asset_activity THEN
        x_parents(1) := qa_ss_const.asset_group;
        x_parents(2) := qa_ss_const.asset_number;
        x_parents(3) := qa_ss_const.asset_instance_number;

    ELSIF p_char_id = qa_ss_const.followup_activity THEN
        x_parents(1) := qa_ss_const.asset_group;
        x_parents(2) := qa_ss_const.asset_number;
        x_parents(3) := qa_ss_const.asset_instance_number;
    --dgupta: End R12 EAM Integration. Bug 4345492

    -- rkaza. 12/02/2003. bug 3215404.
    -- Added dependency relation for maintenance op seq with maintenance
    -- work order.
    ELSIF p_char_id = qa_ss_const.maintenance_op_seq THEN
        x_parents(1) := qa_ss_const.work_order;

    -- rkaza. 12/02/2003. bug 3280307.
    -- Added dependency relation for component item with item
    ELSIF p_char_id = qa_ss_const.comp_item THEN
        x_parents(1) := qa_ss_const.item;

    -- anagarwa Thu Aug 12 15:49:51 PDT 2004
    -- bug 3830258 incorrect LOVs in QWB
    -- synced up the component lot number and component serial number
    -- lov with forms
    ELSIF p_char_id = qa_ss_const.comp_lot_number THEN
        x_parents(1) := qa_ss_const.comp_item;

    ELSIF p_char_id = qa_ss_const.comp_serial_number THEN
        x_parents(1) := qa_ss_const.comp_lot_number;
        x_parents(2) := qa_ss_const.comp_item;
        x_parents(3) := qa_ss_const.comp_revision;

    -- R12 OPM Deviations. Bug 4345503 Start
    ELSIF p_char_id = qa_ss_const.process_batchstep_num THEN
        x_parents(1) := qa_ss_const.process_batch_num;

    ELSIF p_char_id = qa_ss_const.process_operation THEN
        x_parents(1) := qa_ss_const.process_batch_num;
        x_parents(2) := qa_ss_const.process_batchstep_num;

    ELSIF p_char_id = qa_ss_const.process_activity THEN
        x_parents(1) := qa_ss_const.process_batch_num;
        x_parents(2) := qa_ss_const.process_batchstep_num;

    ELSIF p_char_id = qa_ss_const.process_resource THEN
        x_parents(1) := qa_ss_const.process_batch_num;
        x_parents(2) := qa_ss_const.process_batchstep_num;
        x_parents(3) := qa_ss_const.process_activity;

    ELSIF p_char_id = qa_ss_const.process_parameter THEN
        x_parents(1) := qa_ss_const.process_resource;
    -- R12 OPM Deviations. Bug 4345503 End

    --
    -- Bug 6161802
    -- Added dependency relation for  rma line number with rma number
    -- skolluku Thu Mon Jul 16 22:08:16 PDT 2007
    --
    ELSIF p_char_id = qa_ss_const.rma_line_num THEN
        x_parents(1) := qa_ss_const.rma_number;

    --
    -- Bug 7716875.pdube Mon Apr 13 03:25:19 PDT 2009
    -- Added dependency relation for SO line number with SO number
    --
    ELSIF p_char_id = qa_ss_const.order_line THEN
         x_parents(1) := qa_ss_const.sales_order;

    -- Bug 7588754.pdube Wed Apr 15 07:37:25 PDT 2009
    -- Added dependency on item and srl number
    ELSIF p_char_id = qa_ss_const.serial_status THEN
         x_parents(1) := qa_ss_const.item;
         x_parents(2) := qa_ss_const.serial_number;
    --
    -- Bug 9032151
    -- Added dependency relation for  item instance with item
    -- skolluku
    --
    ELSIF p_char_id = qa_ss_const.item_instance THEN
         x_parents(1) := qa_ss_const.item;
    --
    -- Bug 9359442
    -- Added dependency relation for  item instance serial with item
    -- skolluku
    --
    ELSIF p_char_id = qa_ss_const.item_instance_serial THEN
        x_parents(1) := qa_ss_const.item;
    END IF;

END get_lov_dependencies;



FUNCTION get_region_prompt (p_region_type VARCHAR2)
    RETURN VARCHAR2 IS

    -- Bug 6998253
    -- this can also be an UI label and not just collection
    -- element prompt, so increasing the length
    l_prompt VARCHAR2(250);
    l_message VARCHAR2(30);
    l_api_name VARCHAR2(100) := 'GET_REGION_PROMPT';

BEGIN

    log_error(g_pkg_name || l_api_name, 'Function BEGIN');
    -- Bug 4506769. OA Framework Integation project. UT bug fix.
    -- Getting prompts from FND_NEW_MESSAGES.
    -- srhariha. Fri Aug 26 00:16:30 PDT 2005.

    If p_region_type = 'TOP' then
        l_prompt := null;
    elsif p_region_type = 'DATA' then
        l_message := 'QA_SS_RN_PROMPT_DATA';
    elsif p_region_type = 'COMMENTS' then
        l_message := 'QA_SS_RN_PROMPT_COMMENTS';
    elsif p_region_type = 'ATTACHMENTS' then
        l_message := 'QA_SS_JRAD_ATTACHMENT';
    -- 12.1 Device Integration Project
    -- Get prompt for the device region
    -- bhsankar Wed Oct 24 04:45:16 PDT 2007
    elsif p_region_type = 'DEVICE' then
        l_message := 'QA_SS_RN_PROMPT_DEVICE';
    end if;

    l_prompt := fnd_message.get_string('QA',l_message);

    log_error(g_pkg_name || l_api_name, 'Function END Returning l_prompt as ' || l_prompt);

    -- 12.1 Device Integration
    -- Encode to HTML special Characters.
    -- bhsankar Wed Oct 24 04:45:16 PDT 2007
    RETURN DBMS_XMLGEN.convert(l_prompt);

END get_region_prompt;



/*
  anagarwa Thu Dec  4 11:30:36 PST 2003
  Bug 3297976
  Based upon UI cheat sheet mandatory fixes, we use labeledFieldLayout
  for details regions. This has been done to reduce whitespace in the
  hidden region of eqr table row.

*/

FUNCTION create_jrad_region (
    p_region_code IN VARCHAR2,
    p_region_style IN VARCHAR2,
    p_prompt IN VARCHAR2,
    p_columns IN VARCHAR2,
    p_mode in VARCHAR2 default null) RETURN JDR_DOCBUILDER.ELEMENT IS

    l_element JDR_DOCBUILDER.ELEMENT := NULL;
    l_addText VARCHAR2(1000);

    l_api_name VARCHAR2(100) := 'CREATE_JRAD_REGION';

BEGIN
    -- region style choices:
    -- stackLayout, defaultDoubleColumn, defaultSingleColumn, table
    log_error(g_pkg_name || l_api_name, 'Function BEGIN');

    l_element := JDR_DOCBUILDER.createElement(JDR_DOCBUILDER.OA_NS, p_region_style);

    -- 12.1 Inline Region Project
    -- added advancedTable below
    -- saurabh

    -- 12.1 Device Integration Project
    -- Added header to the in clause
    -- bhsankar Wed Oct 24 04:45:16 PDT 2007
    if p_region_style in ('defaultDoubleColumn', 'defaultSingleColumn', 'table',  'header') then
        jdr_docbuilder.setAttribute(l_element, 'text', p_prompt);
    elsif p_region_style <> 'labeledFieldLayout' then
        jdr_docbuilder.setAttribute(l_element, 'prompt', p_prompt);
    end if;

    if ( p_region_style =  'advancedTable')  then
        jdr_docbuilder.setAttribute(l_element, 'text', '');
    end if;

    jdr_docbuilder.setAttribute(l_element, 'regionName', p_prompt);
    jdr_docbuilder.setAttribute(l_element, 'id', p_region_code);

    -- 12.1 Inline Region Project
    -- added advancedTable below
    -- saurabh
    if (p_region_style = 'table' OR p_region_style = 'advancedTable')  then
      jdr_docbuilder.setAttribute(l_element, 'detailViewAttr', 'HideShowStatus');
      jdr_docbuilder.setAttribute(l_element, 'unvalidated', 'True');
      -- anagarwa Mon Nov 17 15:34:29 PST 2003
      -- bug 3251538
      -- we need to add addtional text for all tables.
      if nvl(p_mode, '@') <> g_vqr_multiple_layout then
          l_addText := fnd_message.get_string('QA','QA_SSQR_E_MULT_TEXT');
      else
          l_addText := fnd_message.get_string('QA','QA_SSQR_V_MULT_TEXT');
      end if;

      -- 12.1 QWB Usability Improvements
      -- Encode the HTML special characters
      -- ntungare
      jdr_docbuilder.setAttribute(l_element, 'shortDesc', DBMS_XMLGEN.convert(l_addText));
    end if;

    if p_region_style = 'labeledFieldLayout' then
      jdr_docbuilder.setAttribute(l_element, 'columns', p_columns);
    end if;

    -- 12.1 Device Integration Project
    -- Setting width to 100% for tablelayout style
    -- bhsankar Wed Oct 24 04:45:16 PDT 2007
    if p_region_style = 'tableLayout' then
      jdr_docbuilder.setAttribute(l_element, 'width', '100%');
    end if;

    log_error(g_pkg_name || l_api_name, 'Function END returns ');

    RETURN l_element;

END create_jrad_region;

    --
    -- MOAC Project. 4637896
    -- New procedure to create base attribute code.
    -- srhariha. Tue Oct 11 04:22:16 PDT 2005.
    --

FUNCTION cons_base_attribute_code (
      p_element_prefix           IN VARCHAR2,
      p_id                       IN VARCHAR2)
        RETURN VARCHAR2  IS

BEGIN
    --
    -- bug 5383667
    -- Added check for Party Name
    -- ntungare
    --
    IF(p_id = qa_ss_const.po_number OR
       p_id = qa_ss_const.party_name) THEN
       return qa_chars_api.hardcoded_column(p_id);
    END IF;

    return construct_code(p_element_prefix,p_id);

END cons_base_attribute_code;

--
-- bug 6884645
-- New procedure to create an array of collection
-- elements that would be displayed in the Header
-- region of a Multirow block
--
PROCEDURE multirow_hdrelements_array(
    p_plan_id      IN NUMBER,
    elements_array OUT NOCOPY ParentArray) IS


BEGIN
    --
    -- Selecting the first 5 elements in the collection
    -- plan ordered on the basis of the mandatory flag
    -- and the prompt sequence as they would be displayed
    -- in the header region of a multirow block.
    --
    SELECT char_id BULK COLLECT INTO elements_array
      FROM (SELECT char_id
             FROM QA_PLAN_CHARS
            WHERE plan_id = p_plan_id
              AND enabled_flag = 1
            ORDER BY mandatory_flag, prompt_sequence)
     WHERE rownum <=5;
END multirow_hdrelements_array;

--
-- bug 6884645
-- Added a new parameter the procesing mode
-- ntungare
--
PROCEDURE add_lov_relations (
    p_plan_id                   IN NUMBER,
    p_char_id                   IN NUMBER,
    p_attribute_code            IN VARCHAR2,
    p_input_elem                IN jdr_docbuilder.Element,
    p_mode                      IN VARCHAR2 DEFAULT NULL) IS


    l_row_id                    VARCHAR2(30);
    l_region_code               VARCHAR2(30);
    l_attribute_code            VARCHAR2(30);
    l_lov_attribute_code        VARCHAR2(30);
    l_base_attribute_code       VARCHAR2(30);
    l_parents                   ParentArray;

    --
    -- bug 6884645
    -- added a new array for the multirow header elements
    -- ntungare
    --
    l_multirow_headers          ParentArray;

    lovMap  jdr_docbuilder.ELEMENT;

    -- bug 6884645
    -- variable to check if the parent attribute
    -- has been processed
    -- ntungare
    --
    parent_element_processed BOOLEAN := FALSE;
BEGIN

    -- This function adds lov relations for a region item.
    -- Here the region item corresponds to a collection plan element.

   --Criteria
   lovMap := jdr_docbuilder.createElement(jdr_docbuilder.JRAD_NS, 'lovMap');
   jdr_docbuilder.setAttribute(lovMap, 'criteriaFrom', p_attribute_code);
   jdr_docbuilder.setAttribute(lovMap, 'lovItem', g_lov_attribute_code);
   jdr_docbuilder.setAttribute(lovMap, 'requiredForLOV', 'true');
   jdr_docbuilder.addChild(p_input_elem, jdr_docbuilder.JRAD_NS, 'lovMappings',
                                        lovMap);
   --Result
   lovMap := jdr_docbuilder.createElement(jdr_docbuilder.JRAD_NS, 'lovMap');
   jdr_docbuilder.setAttribute(lovMap, 'resultTo', p_attribute_code);
   jdr_docbuilder.setAttribute(lovMap, 'lovItem', g_lov_attribute_code);
   jdr_docbuilder.addChild(p_input_elem, jdr_docbuilder.JRAD_NS, 'lovMappings',
                                        lovMap);
  --Org Id
   lovMap := jdr_docbuilder.createElement(jdr_docbuilder.JRAD_NS, 'lovMap');
   jdr_docbuilder.setAttribute(lovMap, 'criteriaFrom', g_org_id_attribute);
   jdr_docbuilder.setAttribute(lovMap, 'lovItem', g_lov_attribute_org_id);
   jdr_docbuilder.setAttribute(lovMap, 'programmaticQuery', 'true');
   jdr_docbuilder.addChild(p_input_elem, jdr_docbuilder.JRAD_NS, 'lovMappings',
                                        lovMap);
  --Plan Id
   lovMap := jdr_docbuilder.createElement(jdr_docbuilder.JRAD_NS, 'lovMap');
   jdr_docbuilder.setAttribute(lovMap, 'criteriaFrom', g_plan_id_attribute);
   jdr_docbuilder.setAttribute(lovMap, 'lovItem', g_lov_attribute_plan_id);
   jdr_docbuilder.setAttribute(lovMap, 'programmaticQuery', 'true');
   jdr_docbuilder.addChild(p_input_elem, jdr_docbuilder.JRAD_NS, 'lovMappings',
                                        lovMap);


    get_lov_dependencies(p_char_id, l_parents);

    FOR i IN 1..l_parents.COUNT LOOP

        -- anagarwa
        -- Bug 2751198
        -- Add dependency to LOV only if the element exists in the plan
        -- This is achieved by adding the following IF statement

        -- rkaza. 10/22/2003. 3280307. shold not use exists_qa_plan_chars
        -- array might not have been initialized. use element_in_plan
      -- IF qa_plan_element_api.exists_qa_plan_chars(p_plan_id, l_parents(i)) THEN
      IF qa_plan_element_api.element_in_plan(p_plan_id, l_parents(i)) THEN
          l_lov_attribute_code := g_lov_attribute_dependency || to_char(i);
          --
          -- MOAC Project. 4637896
          -- Call new procedure to construct base code
          -- srhariha. Tue Oct 11 04:22:16 PDT 2005.
          --
          -- bug 6884645
          -- The multirow prefix should be used if the base element would be
          -- displayed in the details region for a multirow block as
          -- otherwise its value cannot be read
          -- ntungare Sat Mar 22 08:39:05 PDT 2008
          --
          IF (p_mode = g_eqr_advtable_layout OR p_mode = g_eqr_multiple_layout) THEN
             -- Call the procedure to populate an array containing the
             -- collection elements appearing in the header region of
             -- a multirow block
             --
             multirow_hdrelements_array(p_plan_id, l_multirow_headers);

             -- loop through the header elements array and check if the parent element
             -- is a part of it. if yes then the CHARID prefix is to be used else
             -- the DTLCHARID prefix is to be used since the parent element is in the
             -- detail region
             -- ntungare
             --
             FOR cntr in 1..l_multirow_headers.COUNT
                loop
                   -- parent element in header region
                   IF (l_parents(i) = l_multirow_headers(cntr)) THEN
                      l_base_attribute_code := cons_base_attribute_code(g_element_prefix, l_parents(i));

                      -- Set the parent element processed flag as TRUE
                      parent_element_processed := TRUE;
                      EXIT;
                   END If;
                end loop;

             -- If the parent element processed flag is FALSE then it means
             -- that the parent element is not in header
             IF (parent_element_processed = FALSE) THEN
                 l_base_attribute_code := cons_base_attribute_code(g_dtl_element_prefix, l_parents(i));
             END If;

          -- Single row region processing
          ELSE
             l_base_attribute_code := cons_base_attribute_code(g_element_prefix, l_parents(i));
          END IF;

          lovMap := jdr_docbuilder.createElement(jdr_docbuilder.JRAD_NS, 'lovMap');
          jdr_docbuilder.setAttribute(lovMap, 'criteriaFrom', l_base_attribute_code);
          jdr_docbuilder.setAttribute(lovMap, 'lovItem', l_lov_attribute_code);
          jdr_docbuilder.setAttribute(lovMap, 'programmaticQuery', 'true');
          jdr_docbuilder.addChild(p_input_elem, jdr_docbuilder.JRAD_NS,
                                        'lovMappings',lovMap);
      END IF;

      --
      -- bug 6884645
      -- resetting the flag for the next parent element
      --
      parent_element_processed := FALSE;
    END LOOP;


END add_lov_relations;

    --
    -- MOAC Project. 4637896
    -- New procedure to create id item.
    -- srhariha. Tue Oct 11 04:22:16 PDT 2005.
    --


FUNCTION create_id_item_for_eqr (
    p_plan_id                  IN NUMBER,
    p_char_id                  IN NUMBER,
    p_mode IN VARCHAR2 DEFAULT NULL)
        RETURN jdr_docbuilder.ELEMENT  IS

    l_vo_attribute_name         VARCHAR2(30)  DEFAULT NULL;
    l_id_elem jdr_docbuilder.ELEMENT := NULL;

BEGIN

    l_vo_attribute_name := qa_chars_api.hardcoded_column(p_char_id);
    l_id_elem := create_jrad_region_item('formValue');

    -- set properties
    jdr_docbuilder.setAttribute(l_id_elem, 'id', l_vo_attribute_name);
    --if( p_mode <> g_eqr_advtable_layout OR p_mode is NULL) then
        jdr_docbuilder.setAttribute(l_id_elem, 'viewName', g_vo_name);
    --end if;
    jdr_docbuilder.setAttribute(l_id_elem, 'viewAttr', l_vo_attribute_name);
    jdr_docbuilder.setAttribute(l_id_elem, 'dataType', 'NUMBER');

    return l_id_elem;

END create_id_item_for_eqr;



    --
    -- MOAC Project. 4637896
    -- Checks whether its a normalized lov item.
    -- srhariha. Tue Oct 11 04:22:16 PDT 2005.
    --
FUNCTION is_normalized_lov  (
         p_plan_id     IN NUMBER,
         p_char_id     IN NUMBER) RETURN VARCHAR2 IS

BEGIN
    -- currently we are enabling normalized logic
    -- only for  PO NUMBER
    --
    -- bug 5383667
    -- added the party name to the list of normalized vals
    -- ntungare
    --
    if((p_char_id = qa_ss_const.po_number) OR
       (p_char_id = qa_ss_const.party_name))then
      return 'T';
    end if;

    return 'F';
END is_normalized_lov;

    --
    -- MOAC Project. 4637896
    -- Gets external LOV region name
    -- srhariha. Tue Oct 11 04:22:16 PDT 2005.
    --
FUNCTION get_lov_region_name  (
         p_plan_id     IN NUMBER,
         p_char_id     IN NUMBER) RETURN VARCHAR2 IS

BEGIN
    -- currently we are enabling normalized logic
    -- only for  PO NUMBER. So we are hard coding
    -- lov region name. In future, this proc must
    -- be generalized.
    if(p_char_id = qa_ss_const.po_number) then
      return 'PONumberLovRN';
    --
    -- bug 5383667
    -- getting the region LOV region name for
    -- Party Name. We are currently using a separate
    -- region for the Part name, however we should
    -- later use a common region for all the normalized
    -- id elements
    --
    elsif (p_char_id = qa_ss_const.party_name) then
      return 'PartyLovRN';
    end if;

    return 'QaLovRN';

END get_lov_region_name;


    --
    -- MOAC Project. 4637896
    -- New method to process normalized lov item.
    -- srhariha. Tue Oct 11 04:22:16 PDT 2005.
    --

PROCEDURE process_normalized_lov (
    p_plan_id                   IN NUMBER,
    p_char_id                   IN NUMBER,
    p_attribute_code            IN VARCHAR2,
    p_char_item                IN jdr_docbuilder.Element) IS

   lovMap  jdr_docbuilder.ELEMENT;
   l_lov_region  VARCHAR2(100);

BEGIN
   l_lov_region := g_jrad_lov_dir_path ||  get_lov_region_name(p_plan_id,p_char_id);
   jdr_docbuilder.setAttribute(p_char_item,
                               'externalListOfValues',
                               l_lov_region);
    --Criteria
   lovMap := jdr_docbuilder.createElement(jdr_docbuilder.JRAD_NS, 'lovMap');
   jdr_docbuilder.setAttribute(lovMap, 'criteriaFrom', p_attribute_code);
   jdr_docbuilder.setAttribute(lovMap, 'resultTo', p_attribute_code);

   IF(p_char_id = qa_ss_const.po_number) THEN
      jdr_docbuilder.setAttribute(lovMap, 'lovItem', 'Segment1');
      jdr_docbuilder.setAttribute(lovMap, 'requiredForLOV', 'true');
      jdr_docbuilder.addChild(p_char_item, jdr_docbuilder.JRAD_NS, 'lovMappings',
                              lovMap);

      -- po_header_id
      lovMap := jdr_docbuilder.createElement(jdr_docbuilder.JRAD_NS, 'lovMap');
      jdr_docbuilder.setAttribute(lovMap, 'lovItem', 'PoHeaderId');
      jdr_docbuilder.setAttribute(lovMap, 'resultTo', qa_chars_api.hardcoded_column(p_char_id));
      jdr_docbuilder.addChild(p_char_item, jdr_docbuilder.JRAD_NS, 'lovMappings',
                              lovMap);
   --
   -- bug 5383667
   -- Processing for the Party Name element
   -- ntungare
   --
   ELSIF(p_char_id = qa_ss_const.party_name) THEN
      jdr_docbuilder.setAttribute(lovMap, 'lovItem', 'PartyName');
      jdr_docbuilder.setAttribute(lovMap, 'requiredForLOV', 'true');
      jdr_docbuilder.addChild(p_char_item, jdr_docbuilder.JRAD_NS, 'lovMappings',
                              lovMap);

      -- PartyId
      lovMap := jdr_docbuilder.createElement(jdr_docbuilder.JRAD_NS, 'lovMap');
      jdr_docbuilder.setAttribute(lovMap, 'lovItem', 'PartyId');
      jdr_docbuilder.setAttribute(lovMap, 'resultTo', qa_chars_api.hardcoded_column(p_char_id));
      jdr_docbuilder.addChild(p_char_item, jdr_docbuilder.JRAD_NS, 'lovMappings',
                              lovMap);

   END IF; -- PO Number

END process_normalized_lov;

    --
    -- MOAC Project. 4637896
    -- New method to process regular lov item.
    -- srhariha. Tue Oct 11 04:22:16 PDT 2005.
    --
-- bug 6884645
-- added a new parameter the processing mode
-- ntungare
--
PROCEDURE process_regular_lov (
    p_plan_id                   IN NUMBER,
    p_char_id                   IN NUMBER,
    p_attribute_code            IN VARCHAR2,
    p_char_item                 IN jdr_docbuilder.Element,
    p_mode                      IN VARCHAR2 DEFAULT NULL) IS

BEGIN

    jdr_docbuilder.setAttribute(p_char_item, 'externalListOfValues',
                                                g_jrad_lov_path);

    add_lov_relations(p_plan_id, p_char_id, p_attribute_code, p_char_item, p_mode);

END process_regular_lov;

--
-- 12.1 QB Usability Improvements
-- new fuction to check if Online actions
-- have been defined on a collection element
-- ntungare Tue Aug 28 04:34:33 PDT 2007
--
FUNCTION is_online_action_defined(p_plan_id IN NUMBER,
                                  p_char_id IN NUMBER)
   RETURN NUMBER IS

    -- Cursor to check if Online actions
    -- have been defined on a collection
    -- element
    Cursor online_actions_cur is
       (select 1 from
          qa_plan_char_action_triggers pcat,
          qa_plan_char_actions pca
        where pcat.plan_id = p_plan_id
          and pcat.plan_char_action_trigger_id = pca.plan_char_action_trigger_id
          and action_id in (1, 2, 24)
          and pcat.char_id = p_char_id) ;

     cur_val  NUMBER;
BEGIN
    open online_actions_cur ;
    fetch online_actions_cur into cur_val;
    close online_actions_cur;

    RETURN cur_val;
END is_online_action_defined;


    --
    -- MOAC Project. 4637896
    -- New method to process lov item.
    -- srhariha. Tue Oct 11 04:22:16 PDT 2005.
    --
--
-- bug 6884645
-- passing the mode of processing
-- ntungare Sat Mar 22 08:39:05 PDT 2008
--
PROCEDURE process_messageLovInput (
    p_plan_id                   IN NUMBER,
    p_char_id                   IN NUMBER,
    p_attribute_code            IN VARCHAR2,
    p_char_item                 IN jdr_docbuilder.Element,
    p_displayed_flag            IN NUMBER,
    p_read_only_flag            IN NUMBER,
    p_mode                      IN VARCHAR2 DEFAULT NULL) IS

    -- 12.1 QWB Usability Improvements
    -- Flag to cehck if Online actions have been defined
    -- on the collection element
    -- ntungare
    --
    online_act_flg NUMBER := 0;

BEGIN
   -- in the future, this may be changed to be more generic
   -- so that all hardcoded LOVs will go through this
   -- process_normalized_lov procedure.  Currently handle
   -- PO Number only for the immediate MOAC requirement.
    IF is_normalized_lov(p_plan_id,p_char_id) = 'T' THEN
         process_normalized_lov(
             p_plan_id,
             p_char_id,
             p_attribute_code,
             p_char_item);
    ELSE
         --
         -- bug 6884645
         -- passing the processing mode
         -- ntungare
         --
         process_regular_lov(
             p_plan_id,
             p_char_id,
             p_attribute_code,
             p_char_item,
             p_mode);
    END IF;

    -- Common code

    IF (p_displayed_flag <> 1 OR p_read_only_flag = 1) THEN
          jdr_docbuilder.setAttribute(p_char_item, 'unvalidated', 'true');
    ELSE
          jdr_docbuilder.setAttribute(p_char_item, 'unvalidated', 'false');
    END IF;

    --
    -- 12.1 QWB Usability improvements
    -- The user:attribute1 needs to be set which would help in
    -- identifying if the LOV event is for a Quality LOV collection
    -- element or not. We need to do PPR processing for LOV elements
    -- to set the dependent elements and to fire online actions
    -- ntungare Sun Oct 14 03:08:47 PDT 2007
    --
    jdr_docbuilder.setAttribute(p_char_item, 'user:attribute1', 'qapprelement');

    --
    -- 12.1 QWB Usability improvements
    -- If the LOV has online actions defined,
    -- then it should be maked for actions processing
    -- So setting the user:attribute2
    -- ntungare Sun Oct 14 03:08:47 PDT 2007
    --
    online_act_flg := is_online_action_defined(p_plan_id => p_plan_id,
                                               p_char_id => p_char_id);

    If  (online_act_flg = 1) THEN
       jdr_docbuilder.setAttribute(p_char_item, 'user:attribute2', 'qaactionelement');
    End If;

END process_messageLovInput;

FUNCTION create_region_item_for_eqr (
    p_plan_id IN NUMBER,
    p_char_id IN NUMBER,
    p_element_prefix IN VARCHAR2 DEFAULT g_element_prefix,
    p_mode IN VARCHAR2 DEFAULT NULL) RETURN JDR_DOCBUILDER.ELEMENT  IS

    l_attribute_code            VARCHAR2(30);
    l_item_style                VARCHAR2(30);
    l_vo_attribute_name         VARCHAR2(30);
    l_pop_vo_name               VARCHAR2(30);

    c_displayed_flag            VARCHAR2(10);
    c_datatype                  VARCHAR2(30);
    c_mandatory_flag            VARCHAR2(5);
    c_read_only_flag            VARCHAR2(5);

    l_displayed_flag            qa_plan_chars.displayed_flag%TYPE;
    l_read_only_flag            qa_plan_chars.read_only_flag%TYPE;
    l_datatype                  qa_chars.datatype%TYPE;
    l_data_entry_hint           qa_chars.data_entry_hint%TYPE := null;
    l_mandatory_flag            qa_plan_chars.mandatory_flag%TYPE;
    -- Bug 5926317
    -- Changing the length of the local variable l_prompt
    -- to a higher value - 100 and commenting out the existing code
    -- skolluku Mon Apr  9 04:59:34 PDT 2007
    --l_prompt                  qa_plan_chars.prompt%TYPE;
    l_prompt                    VARCHAR2(100);

    -- Bug 4506400. New variable.
    -- srhariha. Mon Aug 29 05:07:41 PDT 2005.
    l_maximum_length  NUMBER;


    l_char_item jdr_docbuilder.ELEMENT;

    l_api_name constant varchar2(50) := 'CREATE_REGION_ITEM_FOR_EQR';

    -- 12.1 QWB Usability Improvements
    -- ntungare Tue Aug 28 04:20:24 PDT 2007
    -- PPRTEST
    ppr_event  jdr_docbuilder.ELEMENT;

    online_act_flg PLS_INTEGER := 0;

    l_show_required_flag       qa_plan_chars.mandatory_flag%TYPE;
    c_show_required_flag       VARCHAR2(5);
BEGIN
    l_displayed_flag := qa_plan_element_api.qpc_displayed_flag(p_plan_id, p_char_id);

    -- 12.1 QWB Usability improvements
    -- The fields are to be made mandatory only in case of a single
    -- row region and not in case of a Multirow region. This is because
    -- in case of a multirow region, the mandatory flag against the
    -- elements would conflict with the Client side validation in case
    -- of inline Txn int. Only the sortable header would be marked as
    -- mandatory so that the * mark is displayed against the mandatory
    -- fields.
    IF (p_mode = g_eqr_advtable_layout OR
        p_mode = g_eqr_multiple_layout) THEN
        l_mandatory_flag := 2; -- Non mandatory

        -- Although the mandatory check would not be enforced on the
        -- collection elements in a Multirow block, yet the show required
        -- property would ensure that the mandatory elements are displayed
        -- with the mandatory sign. This is needed only for details block
        IF (p_element_prefix = g_dtl_element_prefix) THEN
           l_show_required_flag := qa_plan_element_api.qpc_mandatory_flag(p_plan_id, p_char_id);
           c_show_required_flag := convert_boolean_flag(l_show_required_flag);
        END IF;
    ELSE
        l_mandatory_flag := qa_plan_element_api.qpc_mandatory_flag(p_plan_id, p_char_id);
    END IF;

    l_prompt := get_prompt(p_plan_id, p_char_id);
    l_datatype := qa_chars_api.datatype(p_char_id);
    l_data_entry_hint := qa_chars_api.data_entry_hint(p_char_id);
    l_read_only_flag := qa_plan_element_api.qpc_read_only_flag(p_plan_id, p_char_id);

    l_attribute_code := construct_code(p_element_prefix, p_char_id);
    l_item_style := compute_item_style(p_plan_id, p_char_id);
    l_vo_attribute_name := get_vo_attribute_name(p_plan_id, p_char_id);

    c_displayed_flag  := convert_boolean_flag(l_displayed_flag);
    c_mandatory_flag := convert_yesno_flag(l_mandatory_flag);
    c_datatype := convert_data_type(l_datatype);


    if l_datatype = g_seq_datatype then
        c_read_only_flag  := 'true';
    else
        c_read_only_flag  := convert_boolean_flag(l_read_only_flag);
    end if;

    l_char_item := create_jrad_region_item(l_item_style);

    jdr_docbuilder.setAttribute(l_char_item, 'id', l_attribute_code);
    jdr_docbuilder.setAttribute(l_char_item, 'rendered', c_displayed_flag);
    jdr_docbuilder.setAttribute(l_char_item, 'readOnly', c_read_only_flag);
    -- if read only elmeent then set style class
    if c_read_only_flag = 'true' then
       jdr_docbuilder.setAttribute(l_char_item, 'styleClass', g_ora_data_text);
    end if;
    jdr_docbuilder.setAttribute(l_char_item, 'prompt', l_prompt);
    jdr_docbuilder.setAttribute(l_char_item, 'shortDesc', l_prompt);
    jdr_docbuilder.setAttribute(l_char_item, 'required', c_mandatory_flag);

    -- 12.1 QWB Usability
    -- If the element is in a Multirow details block then
    -- although the madatory check would not be enfored yet, the
    -- element must atleast be marked as mandatory.
    IF ((p_mode = g_eqr_advtable_layout OR p_mode = g_eqr_multiple_layout) AND
        (p_element_prefix = g_dtl_element_prefix))THEN
       jdr_docbuilder.setAttribute(l_char_item, 'showRequired', c_show_required_flag);
    END IF;

    jdr_docbuilder.setAttribute(l_char_item, 'dataType', c_datatype);
    -- Advanced Table does not require view name for each item, write code here and other places
    -- jdr_docbuilder.setAttribute(l_char_item, 'viewName', g_vo_name);
    --if( p_mode <> g_eqr_advtable_layout  OR p_mode is NULL) then
        jdr_docbuilder.setAttribute(l_char_item, 'viewName', g_vo_name);
    --end if;
    jdr_docbuilder.setAttribute(l_char_item, 'viewAttr', l_vo_attribute_name);

    -- Bug 4506400. OA Framework Integration. UT Bug fix.
    -- Set maxLength property.
    -- srhariha. Mon Aug 29 05:07:41 PDT 2005.
    IF (l_item_style IN ('messageTextInput','messageLovInput')) THEN
       l_maximum_length := get_max_length(l_vo_attribute_name);
       IF (l_maximum_length is not null AND l_maximum_length <> -1) THEN
            jdr_docbuilder.setAttribute(l_char_item, 'maximumLength', l_maximum_length);
       END IF;
    END IF;

    -- At this point, if the element has lovs then we must determine
    -- what are its dependency and populate lov_relations
    -- with this information.

    --
    -- MOAC Project. 4637896
    -- Call new method to process lov item.
    -- srhariha. Tue Oct 11 04:22:16 PDT 2005.
    --
    -- bug 6884645
    -- passing the procesing mode
    -- ntungare
    --
    IF (l_item_style = 'messageLovInput' ) THEN
        process_messageLovInput(p_plan_id,p_char_id,l_attribute_code,
                                  l_char_item,l_displayed_flag,l_read_only_flag, p_mode);
    END IF;

    -- Set a few pop list specific properties for poplist chars

    IF (l_item_style = 'messageChoice' ) THEN
       -- anagarwa Mon Oct 20 12:47:47 PDT 2003
       -- Bug 3202281 . Poplist vo should have plan name .
       -- This code has run time dependency on QaRenderCO.java changes
        --l_pop_vo_name := construct_code(g_pop_vo_prefix, p_char_id) || 'VO';
        l_pop_vo_name := construct_code(g_pop_vo_prefix, p_char_id) || 'PID' || p_plan_id ||  'VO';
        jdr_docbuilder.setAttribute(l_char_item, 'pickListViewName', l_pop_vo_name);
        jdr_docbuilder.setAttribute(l_char_item, 'pickListDispAttr',
                                        g_pop_display_column);
        jdr_docbuilder.setAttribute(l_char_item, 'pickListValAttr', g_pop_value_column);
    END IF;

    -- Set the text width and height properties for chars of type long comments

    IF (l_datatype = g_comments_datatype) THEN
        jdr_docbuilder.setAttribute(l_char_item, 'columns', g_comments_width);
        jdr_docbuilder.setAttribute(l_char_item, 'rows', g_comments_height);
        -- Bug 4506400. Max length set above. So commenting it out.
        -- srhariha. Mon Aug 29 05:07:41 PDT 2005.

        -- jdr_docbuilder.setAttribute(l_char_item, 'maximumLength', g_comments_max_len);
    END IF;

    -- set data entry hint
    IF (l_data_entry_hint is not null) THEN
        jdr_docbuilder.setAttribute(l_char_item, 'tipType', g_tip_type);
        --jdr_docbuilder.setAttribute(l_char_item, 'tipMessageName', g_tip_message_name);
        --jdr_docbuilder.setAttribute(l_char_item, 'tipMessageAppShortName', g_app_short_name);
          jdr_docbuilder.setAttribute(l_char_item, 'longTipRegion', g_long_tip_region);
    END IF;

    --
    -- 12.1 QWB Usability Improvements
    -- Enabling the MessageTextInput and MessageChoice
    -- type of collection elements for PPR processing
    -- ntungare Tue Aug 28 04:20:24 PDT 2007
    --
    IF (l_item_style = 'messageTextInput' OR
        l_item_style =  'messageChoice') THEN
       -- Disabling the serverside validation to avoid the
       -- entire row being validated
       --
       jdr_docbuilder.setAttribute(l_char_item, 'serverUnvalidated', 'true');

       -- Adding the firePartialAction tag
       --
       ppr_event := JDR_DOCBUILDER.createElement(p_namespace => JDR_DOCBUILDER.UI_NS,
                                                 p_tagName   => 'firePartialAction');

       -- Setting the event name for PPR as qappract_CHARIDXX where XX
       -- represents the collection elements CharId
       --
       jdr_docbuilder.setAttribute(ppr_event, 'event', 'qappract_'||l_attribute_code);

       -- Setting the user:attribute1 to indicate the PPR processing is to be
       -- done for the element
       --
       jdr_docbuilder.setAttribute(l_char_item, 'user:attribute1', 'qapprelement');

       -- Disabling the client side validation
       --
       jdr_docbuilder.setAttribute(ppr_event, 'unvalidated', 'true');

       jdr_docbuilder.addchild (p_parent          => l_char_item,
                                p_groupingNS      => JDR_DOCBUILDER.UI_NS,
                                p_groupingTagName => 'primaryClientAction',
                                p_child           => ppr_event);


       -- Checking if the Online actions have been
       -- defined on the collection element
       --
       online_act_flg := is_online_action_defined(p_plan_id => p_plan_id,
                                                  p_char_id => p_char_id);

       If (online_act_flg =1) then
           -- Setting the user:attribute2 since online actions
           -- have been defined.
           --
           jdr_docbuilder.setAttribute(l_char_item, 'user:attribute2', 'qaactionelement');
           online_act_flg := 0;
       end if; --(online_act_flg =1)
    end if; -- (l_item_style = 'messageTextInput' or l_item_style =  'messageChoice')
    -- End of changes for PPR



    RETURN l_char_item;

END create_region_item_for_eqr;



FUNCTION create_region_item_for_vqr (
    p_plan_id IN NUMBER,
    p_char_id IN NUMBER,
    p_element_prefix IN VARCHAR2 DEFAULT g_element_prefix,
    p_mode IN VARCHAR2 DEFAULT NULL )
      RETURN JDR_DOCBUILDER.ELEMENT  IS

    l_attribute_code            VARCHAR2(30);
    l_item_style                VARCHAR2(30) DEFAULT 'messageStyledText';
    l_vo_attribute_name         VARCHAR2(30);
    l_datatype                  qa_chars.datatype%TYPE;
    -- Bug 5926317
    -- Changing the length of the local variable l_prompt
    -- to a higher value - 100 and commenting out the existing code
    -- skolluku Mon Apr  9 04:59:34 PDT 2007
    --l_prompt                  qa_plan_chars.prompt%TYPE;
    l_prompt                    VARCHAR2(100);

    -- Bug 4509114. OA Framework Integration project. UT bug fix.
    -- "Displayed Flag" not honoured in VQR. Added the following
    -- variables.
    -- srhariha. Thu Aug  4 21:04:49 PDT 2005.
    l_displayed_flag            qa_plan_chars.displayed_flag%TYPE;
    c_displayed_flag            VARCHAR2(10);


    l_char_item jdr_docbuilder.ELEMENT;

BEGIN
    l_prompt := get_prompt(p_plan_id, p_char_id);
    l_attribute_code := construct_code(p_element_prefix, p_char_id);
    l_datatype := qa_chars_api.datatype(p_char_id);

    l_char_item := create_jrad_region_item(l_item_style);
    -- Bug 4509114. OA Framework Integration project. UT bug fix.
    -- "Displayed Flag" not honoured in VQR. Get the displayed flag.
    -- srhariha. Thu Aug  4 21:04:49 PDT 2005.
    jdr_docbuilder.setAttribute(l_char_item, 'id', l_attribute_code);
    --jdr_docbuilder.setAttribute(l_char_item, 'rendered', 'true');
    jdr_docbuilder.setAttribute(l_char_item, 'prompt', l_prompt);
    jdr_docbuilder.setAttribute(l_char_item, 'shortDesc', l_prompt);


    -- bug 3236302. rkaza. timezone support. 11/04/2003
    -- Added datatype to vqr region items
    jdr_docbuilder.setAttribute(l_char_item, 'dataType', convert_data_type(l_datatype));

    -- Bug 4509114. OA Framework Integration project. UT bug fix.
    -- "Displayed Flag" not honoured in VQR. Set rendered property
    -- based on displayed flag.
    -- srhariha. Thu Aug  4 21:04:49 PDT 2005.

    -- 12.1 Usability project
    -- rendered attribute and VO attribute logic is different for export page
    -- abgangul
    if nvl(p_mode, '@') <> g_vqr_multiple_layout then
        l_displayed_flag := qa_plan_element_api.qpc_displayed_flag(p_plan_id, p_char_id);
        c_displayed_flag  := convert_boolean_flag(l_displayed_flag);
        jdr_docbuilder.setAttribute(l_char_item, 'rendered', c_displayed_flag);

        l_vo_attribute_name := get_vo_attribute_name(p_plan_id, p_char_id);
        jdr_docbuilder.setAttribute(l_char_item, 'viewName', g_vo_name);
        jdr_docbuilder.setAttribute(l_char_item, 'viewAttr', l_vo_attribute_name);
        jdr_docbuilder.setAttribute(l_char_item, 'styleClass', g_ora_data_text);

    end if;

    IF (l_datatype = g_comments_datatype) THEN
        -- fix me
        jdr_docbuilder.setAttribute(l_char_item, 'columns', g_comments_width);
        jdr_docbuilder.setAttribute(l_char_item, 'rows', g_comments_height);
    END IF;

    -- for vqr set all text to style OraDataText

    RETURN l_char_item;

END create_region_item_for_vqr;



FUNCTION create_special_region_item (
    p_attribute_code           IN VARCHAR2,
    p_item_style               IN VARCHAR2,
    p_element_prefix           IN VARCHAR2 DEFAULT g_element_prefix,
    p_mode                     IN VARCHAR2 DEFAULT NULL)
    RETURN jdr_docbuilder.ELEMENT  IS

    l_vo_attribute_name         VARCHAR2(30)  DEFAULT NULL;
    l_label_long                VARCHAR2(30)  DEFAULT NULL;
    l_special_elem jdr_docbuilder.ELEMENT := NULL;
    l_data_type                 VARCHAR2(30);
    l_attribute_code            VARCHAR2(30) := p_attribute_code;

    -- for attachments
    l_entity_id                 VARCHAR2(30)  DEFAULT NULL;
    l_entityMap jdr_docbuilder.ELEMENT := NULL;

BEGIN

    -- In EQR we add org_id, org_code, plan_id, plan_code, po_agent_id as special items.
    -- In VQR, we add created_by, collection_id, last_update_date as special items
    -- VQR special items are displayed as message styled text.
    -- EQR special items are not displayed.

    l_label_long := get_special_item_label(p_attribute_code);
    l_special_elem := create_jrad_region_item(p_item_style);

    -- set properties
    -- 12.1 Usability project
    -- VO and VO attribute name is different for export page
    -- abgangul
    if nvl(p_mode, '@') <> g_vqr_multiple_layout then
        l_vo_attribute_name := get_hardcoded_vo_attr_name(p_attribute_code);
        jdr_docbuilder.setAttribute(l_special_elem, 'viewName', g_vo_name);
        jdr_docbuilder.setAttribute(l_special_elem, 'viewAttr', l_vo_attribute_name);
        jdr_docbuilder.setAttribute(l_special_elem, 'styleClass', g_ora_data_text);
    else
        l_attribute_code := p_element_prefix || l_attribute_code;
    end if;

    jdr_docbuilder.setAttribute(l_special_elem, 'id', l_attribute_code);
    jdr_docbuilder.setAttribute(l_special_elem, 'prompt', l_label_long);

    --
    -- Bug 5336860.  Per Coding Standard contextual information needs
    -- this statement to set the font.
    -- bso Thu Jun 15 17:30:55 PDT 2006
    --

    -- bug 3236302. rkaza. timezone support. 11/04/2003
    -- Added datatype datetime to last_update_date
    IF (p_attribute_code = g_last_update_date_attribute) THEN
        -- Assign a datatype of DATETIME to last_update_date.
        l_data_type := convert_data_type(g_datetime_datatype);
        jdr_docbuilder.setAttribute(l_special_elem, 'dataType', l_data_type);
    END IF;

    IF (p_attribute_code = g_collection_id_attribute) THEN
        l_data_type := convert_data_type(g_num_datatype);
        jdr_docbuilder.setAttribute(l_special_elem, 'dataType', l_data_type);
    END IF;

    if p_attribute_code = g_multi_row_attachment then
        l_entity_id := g_attachment_entity;
        jdr_docbuilder.setAttribute(l_special_elem, 'shortDesc', l_label_long);

        l_entityMap := jdr_docbuilder.createElement(jdr_docbuilder.OA_NS, 'entityMap');
        jdr_docbuilder.setAttribute(l_entityMap, 'entityId', l_entity_id);
        jdr_docbuilder.addChild(l_special_elem, jdr_docbuilder.OA_NS,
                                'entityMappings', l_entityMap);
    end if;

    return l_special_elem;

END create_special_region_item;


-- 12.1 Inline Region Project START
-- new method to add columns in advanced table of inline region
-- based on the plan and added elements
FUNCTION create_item_for_advtable(p_plan_id IN NUMBER,
                                  p_char_id IN NUMBER,
                                  p_element_prefix IN VARCHAR2 DEFAULT g_element_prefix)
    RETURN jdr_docbuilder.element IS

l_api_name          CONSTANT VARCHAR2(50) := 'CREATE_ITEM_FOR_ADVTABLE';
l_err_num NUMBER;
l_err_msg VARCHAR2(100);

l_sort_hdr  jdr_docbuilder.element := NULL;
l_col_hdr   jdr_docbuilder.element := NULL;
l_char_item jdr_docbuilder.element := NULL;

l_attr_code            VARCHAR2(30);
l_col_code             VARCHAR2(30);
l_hrd_code             VARCHAR2(30);
l_prompt               VARCHAR2(30);
l_mode                 VARCHAR2(15) := g_eqr_advtable_layout;

l_mandatory_flag       qa_plan_chars.mandatory_flag%TYPE;
c_mandatory_flag       VARCHAR2(5);

l_displayed_flag            qa_plan_chars.displayed_flag%TYPE;
c_displayed_flag            VARCHAR2(10);
BEGIN
  log_error(g_pkg_name || l_api_name, 'BEGIN');
  l_attr_code := construct_code(p_element_prefix, p_char_id);
  l_col_code := 'column' || l_attr_code;
  -- create column for the table
  -- this is an element from the plan
  l_col_hdr := jdr_docbuilder.createElement(jdr_docbuilder.oa_ns,   'column');
  jdr_docbuilder.setattribute(l_col_hdr,   'id', l_col_code);

  -- Setting the rendered property based on the display flag value
  l_displayed_flag := qa_plan_element_api.qpc_displayed_flag(p_plan_id, p_char_id);
  c_displayed_flag  := convert_boolean_flag(l_displayed_flag);

  jdr_docbuilder.setAttribute(l_col_hdr, 'rendered', c_displayed_flag);

  -- add actual element
  log_error(g_pkg_name || l_api_name, 'Creating Element ' || to_char(p_char_id));
  l_char_item := create_region_item_for_eqr(p_plan_id, p_char_id, p_element_prefix, l_mode);
  log_error(g_pkg_name || l_api_name, 'Adding element to column header');
  add_child_to_parent(l_col_hdr,   l_char_item,   'contents');
  log_error(g_pkg_name || l_api_name, 'END');

  l_hrd_code := 'colHdr' || l_attr_code;
  -- add column header
  l_sort_hdr := jdr_docbuilder.createElement(jdr_docbuilder.oa_ns,   'sortableHeader');
  jdr_docbuilder.setAttribute(l_sort_hdr,   'id', l_hrd_code);
  l_prompt := get_prompt(p_plan_id,   p_char_id);
  jdr_docbuilder.setAttribute(l_sort_hdr,   'prompt',   l_prompt);

   -- adding the mandatory sign
  l_mandatory_flag := qa_plan_element_api.qpc_mandatory_flag(p_plan_id, p_char_id);
  c_mandatory_flag := convert_yesno_flag(l_mandatory_flag);
  jdr_docbuilder.setAttribute(l_sort_hdr, 'required', c_mandatory_flag);

  add_child_to_parent(l_col_hdr,   l_sort_hdr,   'columnHeader');


  return l_col_hdr;

END create_item_for_advtable;

-- 12.1 Inline Region Project END


PROCEDURE delete_old_top_document(
    p_full_path IN VARCHAR2) IS

BEGIN
    -- delete the document if it exists.

    If jdr_docbuilder.documentExists(p_full_path) then
        jdr_docbuilder.deleteDocument(p_full_path);
    end if;

END delete_old_top_document;



FUNCTION create_top_document(
    p_full_path IN VARCHAR2) RETURN JDR_DOCBUILDER.DOCUMENT IS

BEGIN

    RETURN JDR_DOCBUILDER.createDocument(p_full_path, 'en-US');

END create_top_document;


FUNCTION create_and_set_top_element(
    p_top_doc IN JDR_DOCBUILDER.DOCUMENT,
    p_top_region_code IN VARCHAR2,
    p_layout IN VARCHAR2) RETURN JDR_DOCBUILDER.ELEMENT IS

    l_api_name constant varchar2(50) := 'CREATE_AND_SET_TOP_ELEMENT';
    l_top_region JDR_DOCBUILDER.ELEMENT := NULL;
    l_prompt VARCHAR2(30);
BEGIN
    -- Creates the top region and sets it as the top level element in the document
    -- p_layout can be stackLayout or table layout for top regions

    -- Bug 4506769. OA Framework Integration. UT bug fix.
    -- Personalization text incorrect.
    -- srhariha. Fri Aug 26 05:13:34 PDT 2005.

    if (p_layout = 'table') then
        l_prompt := get_region_prompt('DATA');
    -- 12.1 Inline region project
    -- saugupta
    elsif ( p_layout = 'advancedTable' ) then
      l_prompt := get_region_prompt('DATA');
    end if;

    l_top_region := create_jrad_region (p_top_region_code, p_layout,l_prompt, null);
    JDR_DOCBUILDER.setTopLevelElement(p_top_doc, l_top_region);

    -- 12.1 Inline region project
    -- saugupta
    if ( p_layout = 'advancedTable' ) then
      -- found code bug, regionName appearing twice in the final XML
      -- saugupta
      -- JDR_DOCBUILDER.setAttribute(l_top_region, 'regionName', l_prompt);
      JDR_DOCBUILDER.setAttribute(l_top_region, 'viewName', g_vo_name);
      -- JDR_DOCBUILDER.setAttribute(l_top_region, 'detailViewAttr', 'HideShowStatus');
    end if;

    RETURN l_top_region;

END create_and_set_top_element;

    --
    -- MOAC Project. 4637896
    -- Rewrote the code for MOAC.
    -- srhariha. Tue Oct 11 04:22:16 PDT 2005.
    --


-- Returns no of plan chars added to the region

FUNCTION add_plan_chars_to_region(
    p_plan_id IN NUMBER,
    p_content_region IN JDR_DOCBUILDER.ELEMENT,
    p_mode IN VARCHAR2,
    p_char_type IN VARCHAR2,
    p_parent_region_prefix IN VARCHAR2 DEFAULT NULL) RETURN NUMBER IS

    char_count NUMBER := 0;
    l_char_item JDR_DOCBUILDER.ELEMENT := NULL;
    -- MOAC
    l_id_item JDR_DOCBUILDER.ELEMENT := NULL;

    l_element_prefix VARCHAR2(15) := g_element_prefix;

    l_api_name          CONSTANT VARCHAR2(50) := 'ADD_PLAN_CHARS_TO_REGION';

    CURSOR c IS
        SELECT   qpc.char_id
        FROM     qa_plan_chars qpc,
                 qa_chars qc
        WHERE    qc.char_id = qpc.char_id
        AND      qpc.enabled_flag = 1
        AND      qpc.plan_id = p_plan_id
        AND      ((p_char_type = 'NonComments' AND qc.datatype <> g_comments_datatype) OR
                  (p_char_type = 'Comments' AND qc.datatype = g_comments_datatype))
        ORDER BY QPC.prompt_sequence;



BEGIN
    IF p_parent_region_prefix = g_eqr_mult_dtl_prefix THEN
      l_element_prefix := g_dtl_element_prefix;
    END IF;


    -- p_mode can be EQR, VQR. Attribute properties are different for the modes
    -- p_char_type can be NonComments and Comments.
    -- 'NonComments' is passed in when processing data region.
    -- 'Comments' is passed in when processing comments region.

    FOR r in c LOOP
        IF p_mode = g_vqr_single_layout THEN
            l_char_item := create_region_item_for_vqr(p_plan_id,r.char_id,
                                                      l_element_prefix);
            add_child_to_parent(p_content_region, l_char_item, 'contents');
        -- 12.1 Inline Region Project
        -- saugupta
        ELSIF p_mode = g_eqr_advtable_layout THEN
            log_error(g_pkg_name || l_api_name,
                       'Creating adv table item for: ' || to_char(r.char_id));
            l_char_item := create_item_for_advtable(p_plan_id, r.char_id, l_element_prefix);
            add_child_to_parent(p_content_region, l_char_item, 'contents');
        ELSE
            l_char_item := create_region_item_for_eqr(p_plan_id, r.char_id,
                                                      l_element_prefix, p_mode);
            add_child_to_parent(p_content_region, l_char_item, 'contents');
             -- Bug 4691416. MOAC project. UT bug fix.
             -- Dont add id field to multi detail region.
             -- srhariha. Thu Oct 20 22:18:41 PDT 2005.

            -- For MOAC : add normalized column.
            --
            -- bug 5383667
            -- Added the conditon for Party name
            -- ntungare
            --
            -- Requires code addition for Adanced Table
            -- todo saugupta
            IF (r.char_id = qa_ss_const.po_number OR
                r.char_id = qa_ss_const.party_name) AND
                     (p_parent_region_prefix <> g_eqr_mult_dtl_prefix OR
                      p_parent_region_prefix IS NULL) THEN
              l_id_item := create_id_item_for_eqr(p_plan_id,r.char_id);
              add_child_to_parent(p_content_region, l_id_item, 'contents');
            END IF;
        END IF;
        char_count := char_count + 1;
    END LOOP;


    RETURN char_count;

END add_plan_chars_to_region;



PROCEDURE add_special_chars_to_region(
    p_plan_id IN NUMBER,
    p_content_region IN JDR_DOCBUILDER.ELEMENT,
    p_mode IN VARCHAR2,
    p_parent_region_prefix IN VARCHAR2 DEFAULT NULL) IS

    l_char_item JDR_DOCBUILDER.ELEMENT := NULL;
    l_item_style VARCHAR2(30) := null;
    l_element_prefix VARCHAR2(15) := g_element_prefix;
BEGIN

    IF p_parent_region_prefix = g_eqr_mult_dtl_prefix THEN
      l_element_prefix := g_dtl_element_prefix;
    END IF;

    -- p_mode can be EQR or VQR.
    -- if EQR
    -- add special chars like org_id, org_code, plan_id, plan_name, po_agent_id
    -- I am not adding process_status, source_code, source_line_id. They were used
    -- in older versions when self service results were processed as in import.
    -- if VQR add created by, collection id, last update date.

    If p_mode = g_eqr_single_layout then

        l_item_style := 'formValue';

        l_char_item := create_special_region_item (
            p_attribute_code           => g_org_id_attribute,
            p_item_style               => l_item_style,
            p_element_prefix           => l_element_prefix);
        add_child_to_parent(p_content_region, l_char_item, 'contents');

        l_char_item := create_special_region_item (
            p_attribute_code           => g_plan_id_attribute,
            p_item_style               => l_item_style,
            p_element_prefix           => l_element_prefix);
        add_child_to_parent(p_content_region, l_char_item, 'contents');

    elsif p_mode = g_eqr_multiple_layout then

        l_item_style := 'formValue';

        l_char_item := create_special_region_item (
            p_attribute_code           => g_org_id_attribute,
            p_item_style               => l_item_style,
            p_element_prefix           => l_element_prefix);
        add_child_to_parent(p_content_region, l_char_item, 'contents');

        l_char_item := create_special_region_item (
            p_attribute_code           => g_plan_id_attribute,
            p_item_style               => l_item_style,
            p_element_prefix           => l_element_prefix);
        add_child_to_parent(p_content_region, l_char_item, 'contents');

        l_item_style := 'attachmentImage';

        l_char_item := create_special_region_item (
            p_attribute_code           => g_multi_row_attachment,
            p_item_style               => l_item_style,
            p_element_prefix           => l_element_prefix);
        add_child_to_parent(p_content_region, l_char_item, 'contents');

    elsif p_mode = g_vqr_single_layout then

        l_item_style := 'messageStyledText';

        l_char_item := create_special_region_item (
            p_attribute_code           => g_qa_created_by_attribute,
            p_item_style               => l_item_style,
            p_element_prefix           => l_element_prefix);
        add_child_to_parent(p_content_region, l_char_item, 'contents');

        l_char_item := create_special_region_item (
            p_attribute_code           => g_collection_id_attribute,
            p_item_style               => l_item_style,
            p_element_prefix           => l_element_prefix);
        add_child_to_parent(p_content_region, l_char_item, 'contents');

        l_char_item := create_special_region_item (
            p_attribute_code           => g_last_update_date_attribute,
            p_item_style               => l_item_style,
            p_element_prefix           => l_element_prefix);
        add_child_to_parent(p_content_region, l_char_item, 'contents');

    end if;

END add_special_chars_to_region;



FUNCTION create_data_region(
    p_plan_id IN NUMBER,
    p_data_region_code IN VARCHAR2,
    p_mode IN VARCHAR2,
    p_parent_region_prefix IN VARCHAR2 DEFAULT NULL) RETURN JDR_DOCBUILDER.ELEMENT IS

    l_data_region JDR_DOCBUILDER.ELEMENT := NULL;
    l_prompt VARCHAR2(30) := null;
    l_char_count NUMBER := null;

BEGIN
    -- create data region
    -- loop thru enabled plan elements that are not of type 'comment'
    -- create element region items and add to data region
    -- add special chars to the data region
    -- return data region
    -- p_mode can be EQR or VQR.


    if p_mode = g_eqr_multiple_layout then
        l_prompt := null;
    else
        l_prompt := get_region_prompt('DATA');
    end if;


/*
    l_data_region := create_jrad_region(p_data_region_code, 'defaultDoubleColumn',
                        l_prompt);
*/
    if p_parent_region_prefix = g_eqr_mult_dtl_prefix then
      l_data_region := create_jrad_region(p_data_region_code, 'labeledFieldLayout',
                        l_prompt, '2');
    else
      l_data_region := create_jrad_region(p_data_region_code, 'defaultDoubleColumn',
                       l_prompt, '-1');
    end if;

     l_char_count := add_plan_chars_to_region(p_plan_id, l_data_region,
                                             p_mode, 'NonComments',
                                             p_parent_region_prefix);
     IF p_parent_region_prefix is null or
         p_parent_region_prefix <> g_eqr_mult_dtl_prefix THEN
      add_special_chars_to_region(p_plan_id, l_data_region, p_mode,
                                p_parent_region_prefix);
    END IF;

    RETURN l_data_region;

END create_data_region;



FUNCTION create_comments_region(
    p_plan_id IN NUMBER,
    p_comments_region_code IN VARCHAR2,
    p_mode IN VARCHAR2,
    p_parent_region_prefix IN VARCHAR2 DEFAULT NULL)
    RETURN JDR_DOCBUILDER.ELEMENT IS

    l_comments_region JDR_DOCBUILDER.ELEMENT := NULL;
    l_prompt VARCHAR2(30) := null;
    l_char_count NUMBER := null;

BEGIN
    -- create comments region
    -- loop thru enabled plan elements that are of type 'comment'
    -- create element region items and add to comments region
    -- return comments region
    -- p_mode can be EQR or VQR.

    if p_mode = g_eqr_multiple_layout then
        l_prompt := null;
    else
        l_prompt := get_region_prompt('COMMENTS');
    end if;

    if p_parent_region_prefix = g_eqr_mult_dtl_prefix then
       l_comments_region := create_jrad_region(p_comments_region_code,
                                'labeledFieldLayout', l_prompt, '1');
    else
       l_comments_region := create_jrad_region(p_comments_region_code,
                                'defaultSingleColumn', l_prompt, '-1');
    end if;

    l_char_count := add_plan_chars_to_region(p_plan_id,
                                l_comments_region, p_mode, 'Comments',
                                 p_parent_region_prefix);

    if l_char_count = 0 then
        l_comments_region.id := null;
    end if;

    RETURN l_comments_region;

END create_comments_region;


FUNCTION create_attachments_region(p_plan_id IN NUMBER,
                                   p_mode  IN VARCHAR2)
    RETURN JDR_DOCBUILDER.ELEMENT IS

    l_comments_region JDR_DOCBUILDER.ELEMENT := NULL;
    l_prompt VARCHAR2(30) := null;
    l_char_count NUMBER := null;

    l_row_id                    VARCHAR2(30);
    l_element_id                NUMBER;
    l_region_code               VARCHAR2(30);
    --l_nested_region_code      VARCHAR2(30)  DEFAULT null;
    l_item_style                VARCHAR2(30)  DEFAULT 'formValue';
    --l_display_sequence                NUMBER;
    --l_display_flag            VARCHAR2(1)   DEFAULT 'Y';
    --l_update_flag             VARCHAR2(1)   DEFAULT 'Y';
    l_view_attribute_name       VARCHAR2(30)  DEFAULT NULL;
    l_view_usage_name           VARCHAR2(30)  DEFAULT NULL;
    l_label_long                VARCHAR2(30)  DEFAULT NULL;
    l_entity_id                 VARCHAR2(30)  DEFAULT NULL;
    l_url                       VARCHAR2(240) DEFAULT NULL;
    l_image_file_name           VARCHAR2(240) DEFAULT NULL;
    l_description               VARCHAR2(240) DEFAULT NULL;
    --l_query_flag              VARCHAR2(1)   DEFAULT 'N';

    special_elem jdr_docbuilder.ELEMENT := NULL;
    l_entityMap jdr_docbuilder.ELEMENT := NULL;

    err_num                     NUMBER;
    err_msg                     VARCHAR2(100);
l_attachments_region JDR_DOCBUILDER.ELEMENT := NULL;


BEGIN
    -- create comments region
    -- loop thru enabled plan elements that are of type 'comment'
    -- create element region items and add to comments region
    -- return comments region
    -- p_mode can be EQR or VQR.

    l_prompt := get_region_prompt('ATTACHMENTS');

    l_attachments_region := create_jrad_region('QA_SSQR_E_ATTACHMENTS',
                                'defaultSingleColumn', l_prompt, '-1');
    -- added for attachments
    l_entity_id := 'QA_RESULTS';

    l_view_attribute_name := '';
    l_label_long := fnd_message.get_string('QA', 'QA_SS_JRAD_ATTACHMENT');
    l_description := l_label_long;

    --l_item_style := 'attachmentImage';
    l_item_style := 'attachmentLink';
    --special handling for attachments
    l_entityMap := jdr_docbuilder.createElement(jdr_docbuilder.OA_NS,
                                        'entityMap');
    jdr_docbuilder.setAttribute(l_entityMap, 'entityId', l_entity_id);
    --
    -- Bug 8671769
    -- Adding 'id' for the entity map so that the personalization works perfectly.
    -- skolluku
    --
    jdr_docbuilder.setAttribute(l_entityMap, 'id', 'qaEntityMap1');

    -- Bug 6718507
    -- in VQR we do not want the user to insert or update Attachements
    -- ntungare Wed Jan 23 04:20:57 PST 2008
    --
    IF (p_mode = g_vqr_single_layout) THEN
       jdr_docbuilder.setAttribute(l_entityMap, 'insertAllowed', 'false' );
       jdr_docbuilder.setAttribute(l_entityMap, 'updateAllowed', 'false' );
       jdr_docbuilder.setAttribute(l_entityMap, 'deleteAllowed', 'false' );
    END IF;

    special_elem := jdr_docbuilder.createElement(jdr_docbuilder.OA_NS,
                                                  l_item_style);
    jdr_docbuilder.setAttribute(special_elem, 'id', 'AK_ATTACHMENT_LINK' );
    jdr_docbuilder.setAttribute(special_elem, 'viewName', 'QualityResultsVO' );

    -- in VQR we do not want to user to insert or update Attachements
    IF (p_mode = g_vqr_single_layout) THEN
       jdr_docbuilder.setAttribute(special_elem, 'insertAllowed', 'false' );
       jdr_docbuilder.setAttribute(special_elem, 'updateAllowed', 'false' );
       jdr_docbuilder.setAttribute(special_elem, 'deleteAllowed', 'false' );


    END IF;


    jdr_docbuilder.addChild(special_elem, jdr_docbuilder.OA_NS,
                                'entityMappings', l_entityMap);

JDR_DOCBUILDER.addChild(l_attachments_region,  JDR_DOCBUILDER.UI_NS,
                                'contents', special_elem);

/*
    IF ( instr(p_prefix, g_vqr_prefix) = 1) THEN
       --l_update_flag := 'N';
       null;
    END IF;
*/

    RETURN l_attachments_region;

END create_attachments_region;

--12.1 Inline Project Start

FUNCTION create_detail_region(
    p_plan_id IN NUMBER,
    p_dtl_region_code IN VARCHAR2,
    p_mode IN VARCHAR2) RETURN JDR_DOCBUILDER.ELEMENT IS

    l_data_region_code VARCHAR2(35);
    l_comments_region_code VARCHAR2(35);

    l_dtl_region JDR_DOCBUILDER.ELEMENT := NULL;
    l_data_region JDR_DOCBUILDER.ELEMENT := NULL;
    l_comments_region JDR_DOCBUILDER.ELEMENT := NULL;

    l_prompt VARCHAR2(30) := null;
    l_char_count NUMBER := null;

BEGIN
    -- create data region
    -- loop thru enabled plan elements that are not of type 'comment'
    -- create element region items and add to data region
    -- add special chars to the data region
    -- return data region
    -- p_mode can be EQR or VQR.

    l_prompt := null;
    l_data_region_code := construct_code(g_eqr_data_prefix, p_plan_id);
    l_comments_region_code := construct_code(g_eqr_comments_prefix, p_plan_id);

    l_dtl_region := create_jrad_region(p_dtl_region_code, 'stackLayout',
                        l_prompt, '-1');

    -- create data and comments regions and add them as children to the detail region

    l_data_region := create_data_region(p_plan_id, l_data_region_code, p_mode, g_eqr_mult_dtl_prefix);
    add_child_to_parent(l_dtl_region, l_data_region, 'contents');

    l_comments_region := create_comments_region(p_plan_id, l_comments_region_code,
                                                p_mode, g_eqr_mult_dtl_prefix);
    if l_comments_region.id is not null then
        add_child_to_parent(l_dtl_region, l_comments_region, 'contents');
    end if;

    RETURN l_dtl_region;

END create_detail_region;

-- create table action region containing buttons like duplicate and delete
FUNCTION create_table_action_region RETURN jdr_docbuilder.element IS

l_row_layout jdr_docbuilder.element := NULL;
l_text       jdr_docbuilder.element := NULL;
l_dup_btn    jdr_docbuilder.element := NULL;
l_del_btn    jdr_docbuilder.element := NULL;

l_attr_code            VARCHAR2(30);

l_api_name          CONSTANT VARCHAR2(50) := 'CREATE_TABLE_ACTION_REGION';
l_label                  VARCHAR2(30);
l_prompt                 VARCHAR2(50);
l_del_attr_set      CONSTANT VARCHAR2(50) := '/oracle/apps/fnd/attributesets/Buttons/Delete';
l_dup_attr_set      CONSTANT VARCHAR2(50) := '/oracle/apps/fnd/attributesets/Buttons/Duplicate';


BEGIN
  -- create tableAction region items
  log_error(g_pkg_name || l_api_name, 'Function BEGIN');
  -- create rowLayout
  l_row_layout := create_jrad_region_item('rowLayout');
  jdr_docbuilder.setattribute(l_row_layout,   'id', 'rowLayoutRN'); -- set proper non static id

  -- create display text item
  l_text := create_jrad_region_item('messageStyledText');
  jdr_docbuilder.setattribute(l_text,   'id',   'displayText');
  l_label := fnd_message.get_string('QA','QA_TABLE_SELECT_MSG');
  jdr_docbuilder.setattribute(l_text,   'prompt', l_label);

  --create button
  l_dup_btn := create_jrad_region_item('submitButton');
  jdr_docbuilder.setattribute(l_dup_btn,   'id',   'dupBtn');

  -- do not set prompt with '&' instead use attribute sets
  -- l_prompt :=  fnd_message.get_string('QA','QA_QWB_DUPLICATE_PROMPT');
  -- jdr_docbuilder.setattribute(l_dup_btn,   'prompt', DBMS_XMLGEN.convert(l_prompt));
  jdr_docbuilder.setattribute(l_dup_btn,   'use', l_dup_attr_set);

  jdr_docbuilder.setattribute(l_dup_btn,  'unvalidated', 'true');

  --create button
  l_del_btn := create_jrad_region_item('submitButton');
  jdr_docbuilder.setattribute(l_del_btn,   'id',   'delBtn');

  -- do not set prompt with '&' instead use attribute sets
  -- l_prompt :=  fnd_message.get_string('QA','QA_QWB_DELETE_PROMPT');
  --  jdr_docbuilder.setattribute(l_del_btn,   'prompt',   DBMS_XMLGEN.convert(l_prompt) );
  jdr_docbuilder.setattribute(l_del_btn,   'use', l_del_attr_set);

  jdr_docbuilder.setattribute(l_del_btn,  'unvalidated', 'true');
  -- Bug 6856743 - Set server side validation to false.
  jdr_docbuilder.setattribute(l_del_btn,  'serverUnvalidated', 'True');

  -- add items to region
  add_child_to_parent(l_row_layout,   l_text,   'contents');
  add_child_to_parent(l_row_layout,   l_dup_btn,   'contents');
  add_child_to_parent(l_row_layout,   l_del_btn,   'contents');

  -- rowLayout should be added as a child to table or advanced table
  log_error(g_pkg_name || l_api_name, 'Function END');
  RETURN l_row_layout;

END create_table_action_region;

-- create table single selection region with radio button
FUNCTION create_table_selection RETURN jdr_docbuilder.element IS

l_sing_select jdr_docbuilder.element := NULL;
l_api_name          CONSTANT VARCHAR2(50) := 'CREATE_TABLE_SELECTION';

-- 12.1 Device Integration Project
-- bhsankar Tue Aug 28 04:20:24 PDT 2007
-- For PPR Event
ppr_event  jdr_docbuilder.ELEMENT;

BEGIN
  -- create tableSelection
  log_error(g_pkg_name || l_api_name, 'Function BEGIN');
  -- create singleSelection
  l_sing_select := create_jrad_region_item('singleSelection');
  jdr_docbuilder.setattribute(l_sing_select,   'id', 'ResultSelection');
  jdr_docbuilder.setattribute(l_sing_select,   'text', ''); -- get it from message
  jdr_docbuilder.setattribute(l_sing_select,   'viewAttr', 'SelectFlag');
  jdr_docbuilder.setAttribute(l_sing_select, 'unvalidated', 'true');
  jdr_docbuilder.setAttribute(l_sing_select, 'serverUnvalidated', 'true');

  -- 12.1 Device Integration Project
  -- bhsankar Tue Aug 28 04:20:24 PDT 2007
  -- For PPR Event
  ppr_event := JDR_DOCBUILDER.createElement(p_namespace => JDR_DOCBUILDER.UI_NS,
                                            p_tagName   => 'firePartialAction');
  jdr_docbuilder.setAttribute(ppr_event, 'event', 'qaselect');
  jdr_docbuilder.setAttribute(ppr_event, 'unvalidated', 'true');
  jdr_docbuilder.addchild(p_parent          => l_sing_select,
                          p_groupingNS      => JDR_DOCBUILDER.UI_NS,
                          p_groupingTagName => 'primaryClientAction',
                          p_child           => ppr_event);
  -- Device Integration Project End.

  -- add items to region
  -- add it in plan mapping procedure
  -- add_child_to_parent(l_sing_select,   l_text,   'tableSelection');

  -- rowLayout should be added as a child to table or advanced table
  log_error(g_pkg_name || l_api_name, 'Function END');
  RETURN l_sing_select;

END create_table_selection;

-- create table single selection region with radio button
FUNCTION create_table_footer RETURN jdr_docbuilder.element IS

l_add_btn jdr_docbuilder.element := NULL;
l_footer  jdr_docbuilder.element := NULL;
l_api_name          CONSTANT VARCHAR2(50) := 'CREATE_TABLE_FOOTER';
l_prompt                 VARCHAR2(50);

BEGIN
  -- create tableSelection
  log_error(g_pkg_name || l_api_name, 'Function BEGIN');
  -- create Button
  l_add_btn := create_jrad_region_item('addTableRow');
  jdr_docbuilder.setattribute(l_add_btn,   'id', 'addResultRow');
  jdr_docbuilder.setattribute(l_add_btn,   'autoInsertion', 'false');

  --  l_prompt :=  fnd_message.get_string('QA','QA_QWB_ADD_PROMPT');
  --  jdr_docbuilder.setattribute(l_add_btn, 'prompt',  DBMS_XMLGEN.convert(l_prompt));

  l_footer := create_jrad_region_item('tableFooter');
  jdr_docbuilder.setattribute(l_footer,   'id', 'resultFooter');

  -- add button to footer
  add_child_to_parent(l_footer,   l_add_btn,   'contents');

  -- rowLayout should be added as a child to table or advanced table
  log_error(g_pkg_name || l_api_name, 'Function END');
  RETURN l_footer;

END create_table_footer;

-- add table action to table or advanced table
PROCEDURE add_table_action(p_prnt_elm IN jdr_docbuilder.element ) IS
  l_tbl_act jdr_docbuilder.element := NULL;
BEGIN
  -- add table actions to table or advanced table
  l_tbl_act     := create_table_action_region;
  add_child_to_parent(p_prnt_elm,   l_tbl_act,   'tableActions');
END add_table_action;


-- add table single selection to table or advanced table
PROCEDURE add_table_selection(p_prnt_elm IN jdr_docbuilder.element )IS
  l_tbl_s_sel  jdr_docbuilder.element := NULL;
BEGIN
  -- add ingle selection  to table or advanced table
  l_tbl_s_sel   := create_table_selection;
  add_child_to_parent(p_prnt_elm,   l_tbl_s_sel,   'tableSelection');
END add_table_selection;


-- add footer to advanced table
PROCEDURE add_table_footer(p_prnt_elm IN jdr_docbuilder.element) IS
l_tbl_footer jdr_docbuilder.element := NULL;
BEGIN
  -- add footer to table or advanced table
  l_tbl_footer  := create_table_footer;
  add_child_to_parent(p_prnt_elm,  l_tbl_footer,   'footer');
END add_table_footer;

--12.1 Inline Project End

--
-- 12.1 Device Integration Project
-- Functions to create the device region
-- bhsankar Wed Oct 24 04:45:16 PDT 2007
--

PROCEDURE add_device_checkbox_to_parent(
    p_plan_id IN NUMBER,
    p_parent_region JDR_DOCBUILDER.ELEMENT) IS

    l_api_name          CONSTANT VARCHAR2(50) := 'ADD_DEVICE_CHECKBOX_TO_PARENT';
    l_messageCompLayout JDR_DOCBUILDER.ELEMENT := NULL;
    l_char_item JDR_DOCBUILDER.ELEMENT := NULL;
    l_prompt VARCHAR2(100);
    l_element_prefix VARCHAR2(15) := g_element_prefix;
    l_element_suffix VARCHAR2(15) := g_device_element_suffix;
    l_attribute_code VARCHAR2(30);

    CURSOR c IS
        SELECT   qpc.char_id
        FROM     qa_plan_chars qpc,
                 qa_chars qc,
                 qa_device_info qdi
        WHERE    qc.char_id = qpc.char_id
        AND      nvl(qpc.enabled_flag, 2) = 1
        AND      nvl(qpc.device_flag, 2) = 1
        AND      nvl(qpc.displayed_flag, 2) = 1
        AND      qdi.device_id = qpc.device_id
        AND      qdi.enabled_flag = 1
        AND      qpc.plan_id = p_plan_id
        ORDER BY qpc.prompt_sequence;

BEGIN
   log_error(g_pkg_name || l_api_name, 'Procedure BEGIN');
   l_messageCompLayout := JDR_DOCBUILDER.createElement(JDR_DOCBUILDER.OA_NS, 'messageComponentLayout');
   jdr_docbuilder.setAttribute(l_messageCompLayout, 'id', 'ChkBoxRN');
   jdr_docbuilder.setAttribute(l_messageCompLayout, 'rows', '1');
   jdr_docbuilder.setAttribute(l_messageCompLayout, 'columns', '4');
   log_error(g_pkg_name || l_api_name, 'message componenet layput created');

   FOR r in c LOOP
      l_char_item := create_jrad_region_item('messageCheckBox');
      l_prompt := get_prompt(p_plan_id, r.char_id);
      l_attribute_code := construct_code(l_element_prefix, r.char_id, l_element_suffix);

      jdr_docbuilder.setAttribute(l_char_item, 'id', l_attribute_code);
      jdr_docbuilder.setAttribute(l_char_item, 'prompt', l_prompt);
      jdr_docbuilder.setAttribute(l_char_item, 'unvalidated', 'true');
      jdr_docbuilder.setAttribute(l_char_item, 'serverUnvalidated', 'true');
      jdr_docbuilder.setAttribute(l_char_item, 'checked', 'true');
      add_child_to_parent(l_messageCompLayout, l_char_item,'contents');
      log_error(g_pkg_name || l_api_name, 'checkbox created for element: ' || l_prompt);
   END LOOP;

   add_child_to_parent(p_parent_region, l_messageCompLayout,'contents');
   log_error(g_pkg_name || l_api_name, 'Procedure END');
END add_device_checkbox_to_parent;

FUNCTION create_device_button_region
            RETURN JDR_DOCBUILDER.ELEMENT IS
    l_api_name          CONSTANT VARCHAR2(50) := 'CREATE_DEVICE_BUTTON_REGION';
    l_button_rowlayout_region JDR_DOCBUILDER.ELEMENT := NULL;
    l_button_cellformat_region JDR_DOCBUILDER.ELEMENT := NULL;
    l_submit_button JDR_DOCBUILDER.ELEMENT := NULL;
    l_prompt VARCHAR2(30);

    --PPRTEST
    ppr_event  jdr_docbuilder.ELEMENT;
BEGIN
    log_error(g_pkg_name || l_api_name, 'Function BEGIN');
    l_button_rowlayout_region := JDR_DOCBUILDER.createElement(JDR_DOCBUILDER.OA_NS, 'rowLayout');
    jdr_docbuilder.setAttribute(l_button_rowlayout_region, 'id', 'ReadButtonRowLayout');
    jdr_docbuilder.setAttribute(l_button_rowlayout_region, 'width', '100%');
    jdr_docbuilder.setAttribute(l_button_rowlayout_region, 'hAlign', 'end');
    jdr_docbuilder.setAttribute(l_button_rowlayout_region, 'vAlign', 'top');

    l_button_cellformat_region := JDR_DOCBUILDER.createElement(JDR_DOCBUILDER.OA_NS, 'cellFormat');
    jdr_docbuilder.setAttribute(l_button_cellformat_region, 'id', 'ReadButtonCellLayout');
    jdr_docbuilder.setAttribute(l_button_cellformat_region, 'width', '100%');
    jdr_docbuilder.setAttribute(l_button_cellformat_region, 'hAlign', 'end');
    jdr_docbuilder.setAttribute(l_button_cellformat_region, 'vAlign', 'top');

    l_submit_button := create_jrad_region_item('submitButton');
    l_prompt := DBMS_XMLGEN.convert(fnd_message.get_string('QA','QA_QWB_READ_DEV_BUTTON_LABEL'));
    jdr_docbuilder.setAttribute(l_submit_button, 'id', 'ReadDeviceButton');
    jdr_docbuilder.setAttribute(l_submit_button, 'prompt', l_prompt);
    jdr_docbuilder.setAttribute(l_submit_button, 'unvalidated', 'true');
    -- bug 6737113
    -- Added accessKey for Read Device as O.
    -- bhsankar Tue Jan 22 04:12:09 PST 2008
    jdr_docbuilder.setAttribute(l_submit_button, 'accessKey', '0');
    jdr_docbuilder.setAttribute(l_submit_button, 'serverUnvalidated', 'true');

    --For PPR
    ppr_event := JDR_DOCBUILDER.createElement(p_namespace => JDR_DOCBUILDER.UI_NS,
                                              p_tagName   => 'firePartialAction');
    jdr_docbuilder.setAttribute(ppr_event, 'event', 'qadevice');
    jdr_docbuilder.setAttribute(ppr_event, 'unvalidated', 'true');

    jdr_docbuilder.addchild(p_parent          => l_submit_button,
                            p_groupingNS      => JDR_DOCBUILDER.UI_NS,
                            p_groupingTagName => 'primaryClientAction',
                            p_child           => ppr_event);

    add_child_to_parent(l_button_cellformat_region,l_submit_button,'contents');
    add_child_to_parent(l_button_rowlayout_region,l_button_cellformat_region,'contents');
    log_error(g_pkg_name || l_api_name, 'Function END');
    return l_button_rowlayout_region;

END create_device_button_region;

FUNCTION create_device_checkbox_region(
    p_plan_id IN NUMBER) RETURN JDR_DOCBUILDER.ELEMENT IS

    l_rowlayout_region JDR_DOCBUILDER.ELEMENT := NULL;
    l_cellformat_region JDR_DOCBUILDER.ELEMENT := NULL;
    l_api_name          CONSTANT VARCHAR2(50) := 'CREATE_DEVICE_CHECKBOX_REGION';
BEGIN
    log_error(g_pkg_name || l_api_name, 'Function BEGIN');
    l_rowlayout_region := JDR_DOCBUILDER.createElement(JDR_DOCBUILDER.OA_NS, 'rowLayout');
    jdr_docbuilder.setAttribute(l_rowlayout_region, 'id', 'ChkBoxRowLayout');
    jdr_docbuilder.setAttribute(l_rowlayout_region, 'width', '100%');

    l_cellformat_region := JDR_DOCBUILDER.createElement(JDR_DOCBUILDER.OA_NS, 'cellFormat');
    jdr_docbuilder.setAttribute(l_cellformat_region, 'id', 'ChkBoxCellFormat');
    jdr_docbuilder.setAttribute(l_cellformat_region, 'width', '100%');

    add_device_checkbox_to_parent(p_plan_id, l_cellformat_region);
    add_child_to_parent(l_rowlayout_region,l_cellformat_region,'contents');
    log_error(g_pkg_name || l_api_name, 'Function END');
    return l_rowlayout_region;

END create_device_checkbox_region;

FUNCTION create_device_region(
    p_plan_id IN NUMBER,
    p_device_region_code IN VARCHAR2 DEFAULT g_eqr_device_prefix,
    p_parent_region_prefix IN VARCHAR2 DEFAULT NULL) RETURN JDR_DOCBUILDER.ELEMENT IS
    l_api_name          CONSTANT VARCHAR2(50) := 'CREATE_DEVICE_REGION';
    l_device_region_hdr JDR_DOCBUILDER.ELEMENT := NULL;
    l_table_layout_region JDR_DOCBUILDER.ELEMENT := NULL;
    l_button_region JDR_DOCBUILDER.ELEMENT := NULL;
    l_checkbox_region JDR_DOCBUILDER.ELEMENT := NULL;

    l_prompt VARCHAR2(100) := null;


BEGIN
    log_error(g_pkg_name || l_api_name, 'Function BEGIN');
    l_prompt := get_region_prompt('DEVICE');
    log_error(g_pkg_name || l_api_name, 'Device prompt: ' || l_prompt );
    l_device_region_hdr := create_jrad_region(p_device_region_code, 'header', l_prompt, '-1');
    log_error(g_pkg_name || l_api_name,'p_device_region_code :' || p_device_region_code );
    l_table_layout_region := create_jrad_region('DeviceTabLayout', 'tableLayout', '', '-1');

    log_error(g_pkg_name || l_api_name, 'Device table layout created');

    l_button_region := create_device_button_region();
    add_child_to_parent(l_table_layout_region,l_button_region,'contents');

    log_error(g_pkg_name || l_api_name, 'Device read button created');

    l_checkbox_region := create_device_checkbox_region(p_plan_id);
    add_child_to_parent(l_table_layout_region,l_checkbox_region,'contents');

    log_error(g_pkg_name || l_api_name, 'Device checkbox region created');

    add_child_to_parent(l_device_region_hdr,l_table_layout_region,'contents');
    log_error(g_pkg_name || l_api_name, 'Function END');
    RETURN l_device_region_hdr;

END create_device_region;

-- 12.1 Device Integration Project End.

PROCEDURE map_plan_eqr_single(
    p_plan_id IN NUMBER,
    p_special_segment VARCHAR2) IS

    l_top_region_code  VARCHAR2(35);
    l_data_region_code VARCHAR2(35);
    l_comments_region_code VARCHAR2(35);

    l_mode      VARCHAR2(15) := g_eqr_single_layout;
    l_saved PLS_INTEGER;
    l_err_num      NUMBER;
    l_err_msg      VARCHAR2(100);

    l_top_doc JDR_DOCBUILDER.DOCUMENT := NULL;
    l_top_region JDR_DOCBUILDER.ELEMENT := NULL;
    l_data_region JDR_DOCBUILDER.ELEMENT := NULL;
    l_comments_region JDR_DOCBUILDER.ELEMENT := NULL;
    l_attachments_region JDR_DOCBUILDER.ELEMENT := NULL;

    --
    -- 12.1 Device Integration Project
    -- Functions to create the device region
    -- bhsankar Wed Oct 24 04:45:16 PDT 2007
    --
    l_device_region_code VARCHAR2(35) := NULL;
    l_device_region JDR_DOCBUILDER.ELEMENT := NULL;
    l_api_name          CONSTANT VARCHAR2(50) := 'map_plan_eqr_single';

BEGIN
    -- this version of map_plan_eqr_single takes in prefix of top region, data region and comment region
    -- The top region contains the data, comment regions. Attachment region is a
    -- static region taken care of at run time. Not adding attachments here.
    -- A document is created with the top region as its top level element
    -- The top region is a stack layout for a single row layout.
    -- Deleting the top document should delete the existing regions for the plan.

    log_error(g_pkg_name || l_api_name, 'Function BEGIN');

    l_top_region_code := construct_code(g_eqr_single_prefix || p_special_segment, p_plan_id);
    l_data_region_code := construct_code(g_eqr_data_prefix || p_special_segment, p_plan_id);
    l_device_region_code := construct_code(g_eqr_device_prefix || p_special_segment, p_plan_id);
    l_comments_region_code := construct_code(g_eqr_comments_prefix || p_special_segment, p_plan_id);

    delete_old_top_document(g_jrad_region_path || l_top_region_code);

    l_top_doc := create_top_document(g_jrad_region_path || l_top_region_code);
    l_top_region := create_and_set_top_element(l_top_doc, l_top_region_code,
                        'stackLayout');
    --
    -- 12.1 Device Integration Project
    -- Functions to create the device region
    -- bhsankar Wed Oct 24 04:45:16 PDT 2007
    --
    -- Creating the device region if MES is uptaken

    log_error(g_pkg_name || l_api_name, ' Creating device region');

    IF FND_PROFILE.VALUE('WIP_MES_OPS_FLAG') = 1 THEN
       l_device_region := create_device_region(p_plan_id, l_device_region_code);
       IF l_device_region.id is not null THEN
          add_child_to_parent(l_top_region, l_device_region, 'contents');
       END IF;
    END IF;

    log_error(g_pkg_name || l_api_name, ' Device region created');

    -- 12.1 Device Integration Project End.

    -- create data and comments regions and add them as children to the top region

    l_data_region := create_data_region(p_plan_id, l_data_region_code, l_mode);
    add_child_to_parent(l_top_region, l_data_region, 'contents');

    l_comments_region := create_comments_region(p_plan_id, l_comments_region_code,
                                                l_mode);
    if l_comments_region.id is not null then
        add_child_to_parent(l_top_region, l_comments_region, 'contents');
    end if;

    l_attachments_region := create_attachments_region(p_plan_id, '');
    IF l_attachments_region.id is not null THEN
        add_child_to_parent(l_top_region, l_attachments_region, 'contents');
    END IF;

    -- save the document
    l_saved := JDR_DOCBUILDER.SAVE;

    log_error(g_pkg_name || l_api_name, ' Function END');

EXCEPTION

    WHEN OTHERS THEN
        l_err_num := SQLCODE;
        l_err_msg := SUBSTR(SQLERRM, 1, 100);
        log_error(g_pkg_name || l_api_name, 'EXCEPTION : ' || l_err_msg);

END map_plan_eqr_single;

PROCEDURE map_plan_eqr_single(
    p_plan_id IN NUMBER) IS

BEGIN
    -- this is a wrapper to map_plan_eqr_single (p_plan_id, <special segment string>)
    -- in this case, special segment is null
    map_plan_eqr_single(p_plan_id, NULL);

END map_plan_eqr_single;


PROCEDURE map_plan_vqr_single(
    p_plan_id IN NUMBER,
    p_special_segment VARCHAR2) IS

    l_top_region_code  VARCHAR2(35);
    l_data_region_code VARCHAR2(35);
    l_comments_region_code VARCHAR2(35);

    l_mode      VARCHAR2(15) := g_vqr_single_layout;
    l_saved PLS_INTEGER;
    l_err_num      NUMBER;
    l_err_msg      VARCHAR2(100);

    l_top_doc JDR_DOCBUILDER.DOCUMENT := NULL;
    l_top_region JDR_DOCBUILDER.ELEMENT := NULL;
    l_data_region JDR_DOCBUILDER.ELEMENT := NULL;
    l_comments_region JDR_DOCBUILDER.ELEMENT := NULL;
    l_attachments_region JDR_DOCBUILDER.ELEMENT := NULL;

BEGIN
    -- Similar to map_plan_eqr_single logic

    -- The top region contains the data, comment regions. Attachment region is a
    -- static region taken care of at run time. Not adding attachments here.
    -- A document is created with the top region as its top level element
    -- The top region is a stack layout for a single row layout.
    -- Deleting the top document should delete the existing regions for the plan.

    l_top_region_code := construct_code(g_vqr_single_prefix || p_special_segment, p_plan_id);
    l_data_region_code := construct_code(g_vqr_data_prefix || p_special_segment, p_plan_id);
    l_comments_region_code := construct_code(g_vqr_comments_prefix || p_special_segment, p_plan_id);

    delete_old_top_document(g_jrad_region_path || l_top_region_code);

    l_top_doc := create_top_document(g_jrad_region_path || l_top_region_code);
    l_top_region := create_and_set_top_element(l_top_doc, l_top_region_code,
                        'stackLayout');

    -- create data and comments regions and add them as children to the top region

    l_data_region := create_data_region(p_plan_id, l_data_region_code, l_mode);
    add_child_to_parent(l_top_region, l_data_region, 'contents');

    l_comments_region := create_comments_region(p_plan_id, l_comments_region_code,
                                                l_mode);
    if l_comments_region.id is not null then
        add_child_to_parent(l_top_region, l_comments_region, 'contents');
    end if;

    l_attachments_region := create_attachments_region(p_plan_id, l_mode);
    IF l_attachments_region.id is not null THEN
        add_child_to_parent(l_top_region, l_attachments_region, 'contents');
    END IF;

    -- save the document
    l_saved := JDR_DOCBUILDER.SAVE;

EXCEPTION

    WHEN OTHERS THEN
        l_err_num := SQLCODE;
        l_err_msg := SUBSTR(SQLERRM, 1, 100);
        -- dbms_output.put_line(err_msg);

END map_plan_vqr_single;

PROCEDURE map_plan_vqr_single(
    p_plan_id IN NUMBER) IS

BEGIN
    -- this is a wrapper to map_plan_vqr_single (p_plan_id, <special segment string>)
    -- in this case, special segment is null
    map_plan_vqr_single(p_plan_id, NULL);

END map_plan_vqr_single;




-- 12.1 Usability project
-- added for export page
-- abgangul
FUNCTION get_export_vo_attribute_name(p_plan_id NUMBER , p_char_id NUMBER)
RETURN VARCHAR2 IS

l_vo_attr_name VARCHAR2(50);
BEGIN
    select upper(translate(qc.name,' ''*{}','_____'))
    into   l_vo_attr_name
    from   qa_chars qc,
           qa_plan_chars qpc
    where  qc.char_id = qpc.char_id
    and    qpc.plan_id = p_plan_id
    and    qpc.char_id = p_char_id;

    return l_vo_attr_name;
END get_export_vo_attribute_name;



FUNCTION get_hc_export_vo_attr_name (p_attribute_name VARCHAR2)
RETURN VARCHAR2 IS

BEGIN
    if p_attribute_name = g_qa_created_by_attribute then
        return 'CREATED_BY';
    elsif p_attribute_name = g_collection_id_attribute then
        return 'COLLECTION_ID';
    elsif p_attribute_name = g_last_update_date_attribute then
        return 'LAST_UPDATE_DATE';
    else
        return null;
    end if;

END get_hc_export_vo_attr_name;


FUNCTION create_item_for_mult_vqr( p_plan_id        IN  NUMBER,
                                   p_char_id        IN  NUMBER,
                                   x_char_item      OUT NOCOPY JDR_DOCBUILDER.ELEMENT,
                                   x_char_dtl_item  OUT NOCOPY JDR_DOCBUILDER.ELEMENT)
RETURN VARCHAR2 IS

l_vo_attribute_name     VARCHAR2(50);
l_attr_code             VARCHAR2(50);
l_col_code              VARCHAR2(50);
l_hrd_code              VARCHAR2(50);
l_prompt                VARCHAR2(50);
c_displayed_flag        VARCHAR2(50);
c_datatype              VARCHAR2(30);

l_displayed_flag        NUMBER;

l_col_hdr               JDR_DOCBUILDER.ELEMENT;
l_char_item             JDR_DOCBUILDER.ELEMENT;
l_char_dtl_item         JDR_DOCBUILDER.ELEMENT;
l_sort_hdr              JDR_DOCBUILDER.ELEMENT;

l_datatype              qa_chars.datatype%TYPE;


BEGIN
        l_attr_code := construct_code(g_element_prefix, p_char_id);
        l_col_code := 'column' || l_attr_code;
        l_col_hdr := jdr_docbuilder.createElement(jdr_docbuilder.oa_ns,   'column');
        jdr_docbuilder.setattribute(l_col_hdr,   'id', l_col_code);


        l_char_item := create_region_item_for_vqr(p_plan_id, p_char_id,
                                                             g_element_prefix, g_vqr_multiple_layout);
        l_char_dtl_item := create_region_item_for_vqr(p_plan_id, p_char_id,
                                                          g_dtl_element_prefix, g_vqr_multiple_layout);

        l_vo_attribute_name := get_export_vo_attribute_name(p_plan_id, p_char_id);
        jdr_docbuilder.setAttribute(l_char_item, 'viewName', g_export_vo_name);
        jdr_docbuilder.setAttribute(l_char_item, 'viewAttr', l_vo_attribute_name);
        jdr_docbuilder.setAttribute(l_char_dtl_item, 'viewName', g_export_vo_name);
        jdr_docbuilder.setAttribute(l_char_dtl_item, 'viewAttr', l_vo_attribute_name);

        jdr_docbuilder.setAttribute(l_char_item, 'sortable', 'true');
        jdr_docbuilder.setAttribute(l_char_dtl_item, 'sortable', 'true');
        jdr_docbuilder.setAttribute(l_col_hdr, 'sortable' , 'true');


        add_child_to_parent(l_col_hdr,   l_char_item,   'contents');

        l_hrd_code := 'colHdr' || l_attr_code;
        l_sort_hdr := jdr_docbuilder.createElement(jdr_docbuilder.oa_ns,   'sortableHeader');
        jdr_docbuilder.setAttribute(l_sort_hdr,   'id', l_hrd_code);
        l_prompt := get_prompt(p_plan_id,   p_char_id);
        jdr_docbuilder.setAttribute(l_sort_hdr,   'prompt',   l_prompt);
        jdr_docbuilder.setAttribute(l_sort_hdr, 'sortable' , 'yes');
        jdr_docbuilder.setAttribute(l_sort_hdr, 'sortState' , 'yes');
        add_child_to_parent(l_col_hdr,   l_sort_hdr,   'columnHeader');

        l_datatype := qa_chars_api.datatype(p_char_id);
        c_datatype := convert_data_type(l_datatype);
        jdr_docbuilder.setAttribute(l_char_dtl_item, 'styleClass', 'OraTableDetail');

--        jdr_docbuilder.setAttribute(l_char_item, 'dataType', c_datatype);
--        jdr_docbuilder.setAttribute(l_char_dtl_item, 'dataType', c_datatype);

        x_char_item := l_col_hdr;
        x_char_dtl_item := l_char_dtl_item;

        l_displayed_flag := qa_plan_element_api.qpc_displayed_flag(p_plan_id, p_char_id);
        c_displayed_flag :=  convert_boolean_flag(l_displayed_flag);

        if c_displayed_flag = 'true' then
            jdr_docbuilder.setAttribute(l_char_item, 'queryable', 'true');
--            jdr_docbuilder.setAttribute(l_char_dtl_item, 'queryable', 'true');
        end if;

        return c_displayed_flag;


END create_item_for_mult_vqr;

PROCEDURE create_special_item_mult_vqr( p_attribute_code           IN VARCHAR2,
                                   x_char_item      OUT NOCOPY JDR_DOCBUILDER.ELEMENT,
                                   x_char_dtl_item  OUT NOCOPY JDR_DOCBUILDER.ELEMENT)
IS

l_vo_attribute_name     VARCHAR2(50);
l_attr_code             VARCHAR2(50);
l_col_code              VARCHAR2(50);
l_hrd_code              VARCHAR2(50);
l_prompt                VARCHAR2(50);

l_col_hdr               JDR_DOCBUILDER.ELEMENT;
l_char_item             JDR_DOCBUILDER.ELEMENT;
l_char_dtl_item         JDR_DOCBUILDER.ELEMENT;
l_sort_hdr              JDR_DOCBUILDER.ELEMENT;

BEGIN

    l_attr_code := construct_code(g_element_prefix, p_attribute_code);
    l_col_code := 'column' || l_attr_code;
    l_col_hdr := jdr_docbuilder.createElement(jdr_docbuilder.oa_ns,   'column');
    jdr_docbuilder.setattribute(l_col_hdr,   'id', l_col_code);

    l_char_item := create_special_region_item (p_attribute_code, 'messageStyledText',
                                                                g_element_prefix, g_vqr_multiple_layout);
    l_char_dtl_item := create_special_region_item (p_attribute_code, 'messageStyledText',
                                                                g_dtl_element_prefix, g_vqr_multiple_layout);

    jdr_docbuilder.setAttribute(l_char_item, 'sortable', 'true');
    jdr_docbuilder.setAttribute(l_char_dtl_item, 'sortable', 'true');
    jdr_docbuilder.setAttribute(l_col_hdr, 'sortable' , 'true');

    add_child_to_parent(l_col_hdr, l_char_item, 'contents');

    l_hrd_code := 'colHdr' || l_attr_code;
    l_sort_hdr := jdr_docbuilder.createElement(jdr_docbuilder.oa_ns,   'sortableHeader');
    jdr_docbuilder.setAttribute(l_sort_hdr,   'id', l_hrd_code);
    l_prompt := get_special_item_label(p_attribute_code);
    jdr_docbuilder.setAttribute(l_sort_hdr,   'prompt',   l_prompt);
    jdr_docbuilder.setAttribute(l_sort_hdr, 'sortable' , 'yes');
    jdr_docbuilder.setAttribute(l_sort_hdr, 'sortState' , 'yes');
    add_child_to_parent(l_col_hdr,   l_sort_hdr,   'columnHeader');


    jdr_docbuilder.setAttribute(l_char_dtl_item, 'styleClass', 'OraTableDetail');

    jdr_docbuilder.setAttribute(l_char_item, 'queryable', 'true');
--    jdr_docbuilder.setAttribute(l_char_dtl_item, 'queryable', 'true');


    l_vo_attribute_name := get_hc_export_vo_attr_name(p_attribute_code);
    jdr_docbuilder.setAttribute(l_char_item, 'viewName', g_export_vo_name);
    jdr_docbuilder.setAttribute(l_char_item, 'viewAttr', l_vo_attribute_name);
    jdr_docbuilder.setAttribute(l_char_dtl_item, 'viewName', g_export_vo_name);
    jdr_docbuilder.setAttribute(l_char_dtl_item, 'viewAttr', l_vo_attribute_name);



    x_char_item := l_col_hdr;
    x_char_dtl_item := l_char_dtl_item;


END create_special_item_mult_vqr;

PROCEDURE map_plan_vqr_multiple(
    p_plan_id IN NUMBER) IS

    l_top_region_code           VARCHAR2(35);
    l_dtl_region_code           VARCHAR2(35);
    l_data_region_code          VARCHAR2(35);
    l_comments_region_code      VARCHAR2(35);
    l_vo_attribute_name         VARCHAR2(35);
    l_prompt                    VARCHAR2(35);
    l_mode                      VARCHAR2(15) := g_vqr_multiple_layout;
    l_saved                     PLS_INTEGER;
    l_err_num                   NUMBER;
    l_err_msg                   VARCHAR2(100);
    l_counter                   NUMBER  := 0;
    l_comments_exist            VARCHAR2(1) := 'N';
    l_displayed_flag            NUMBER;
    c_displayed_flag            VARCHAR2(10);


    l_top_doc           JDR_DOCBUILDER.DOCUMENT := NULL;
    l_top_region        JDR_DOCBUILDER.ELEMENT  := NULL;
    l_data_region       JDR_DOCBUILDER.ELEMENT  := NULL;
    l_dtl_region        JDR_DOCBUILDER.ELEMENT  := NULL;
    l_comments_region   JDR_DOCBUILDER.ELEMENT  := NULL;
    l_char_item         JDR_DOCBUILDER.ELEMENT  := NULL;
    l_char_dtl_item     JDR_DOCBUILDER.ELEMENT  := NULL;


    CURSOR plan_chars (p_char_type VARCHAR2)IS
        SELECT   qpc.char_id
        FROM     qa_plan_chars qpc,
                 qa_chars qc
        WHERE    qc.char_id = qpc.char_id
        AND      qpc.enabled_flag = 1
        AND      qpc.plan_id = p_plan_id
        AND      ((p_char_type = 'NonComments' AND qc.datatype <> g_comments_datatype) OR
                  (p_char_type = 'Comments' AND qc.datatype = g_comments_datatype))
        ORDER BY QPC.mandatory_flag, QPC.prompt_sequence;


BEGIN
    -- The top region contains the data, comment regions.
    -- A document is created with the top region as its top level element
    -- The top region is a stack layout for a single row layout.
    -- Deleting the top document should delete the existing regions for the plan.

    l_top_region_code := construct_code(g_vqr_multiple_prefix, p_plan_id);

    delete_old_top_document(g_jrad_region_path || l_top_region_code);

    l_top_doc := create_top_document(g_jrad_region_path || l_top_region_code);

    l_prompt := get_region_prompt('DATA');
    l_top_region := create_jrad_region (l_top_region_code, 'advancedTable', l_prompt, null, g_vqr_multiple_layout);
    jdr_docbuilder.setAttribute(l_top_region, 'width', '100%');
    JDR_DOCBUILDER.setTopLevelElement(l_top_doc, l_top_region);
    JDR_DOCBUILDER.setAttribute(l_top_region, 'viewName', g_export_vo_name);

    -- create the detail container region
    l_dtl_region_code := construct_code(g_vqr_mult_dtl_prefix, p_plan_id);
    l_dtl_region := create_jrad_region(l_dtl_region_code, 'stackLayout', null, '-1');

    l_data_region_code := construct_code(g_vqr_data_prefix, p_plan_id);
    l_data_region := create_jrad_region(l_data_region_code, 'labeledFieldLayout', null, '2');
    add_child_to_parent(l_dtl_region, l_data_region, 'contents');


    -- Now add the plan items to main and detail regions.
    -- First the mandatory non-comment items, ordered by prompt sequence, followed by non-mandatory
    -- non-comment items ordered by prompt sequence. Only 5 items come in main region, everything
    -- else goes to detail region. Comment items are always in detail region and follw the non-comment
    -- items ordered by prompt sequence. Thereafter we will have the special attributes created_By,
    -- collection_id and last_updated_by. These will usually be in detail region, but will come in
    -- main region if the main region still has less than 5 items.

    l_counter := 0;
    for rec in plan_chars ('NonComments')
    loop
        c_displayed_flag := create_item_for_mult_vqr(p_plan_id, rec.char_id, l_char_item, l_char_dtl_item);
        add_child_to_parent(l_top_region, l_char_item, 'contents');
        add_child_to_parent(l_data_region, l_char_dtl_item, 'contents');

        if c_displayed_flag = 'false' then
            jdr_docbuilder.setAttribute(l_char_item, 'rendered', c_displayed_flag);
            jdr_docbuilder.setAttribute(l_char_dtl_item, 'rendered', c_displayed_flag);
        elsif c_displayed_flag = 'true' then
            if l_counter < 5 then
                jdr_docbuilder.setAttribute(l_char_item, 'rendered', 'true');
                jdr_docbuilder.setAttribute(l_char_dtl_item, 'rendered', 'false');
--                jdr_docbuilder.setAttribute(l_char_item, 'queryable', 'true');
--                jdr_docbuilder.setAttribute(l_char_dtl_item, 'queryable', 'false');
                l_counter := l_counter + 1;
            else
                jdr_docbuilder.setAttribute(l_char_item, 'rendered', 'false');
                jdr_docbuilder.setAttribute(l_char_dtl_item, 'rendered', 'true');
--                jdr_docbuilder.setAttribute(l_char_item, 'queryable', 'false');
--                jdr_docbuilder.setAttribute(l_char_dtl_item, 'queryable', 'true');
            end if;
        end if;

    end loop;


    -- Now add the special region items
    create_special_item_mult_vqr(g_qa_created_by_attribute, l_char_item, l_char_dtl_item);
    add_child_to_parent(l_top_region, l_char_item, 'contents');
    add_child_to_parent(l_data_region, l_char_dtl_item, 'contents');
    if l_counter < 5 then
        jdr_docbuilder.setAttribute(l_char_item, 'rendered', 'true');
        jdr_docbuilder.setAttribute(l_char_dtl_item, 'rendered', 'false');
--        jdr_docbuilder.setAttribute(l_char_item, 'queryable', 'true');
--        jdr_docbuilder.setAttribute(l_char_dtl_item, 'queryable', 'false');
        l_counter := l_counter + 1;
    else
        jdr_docbuilder.setAttribute(l_char_item, 'rendered', 'false');
        jdr_docbuilder.setAttribute(l_char_dtl_item, 'rendered', 'true');
--        jdr_docbuilder.setAttribute(l_char_item, 'queryable', 'false');
--        jdr_docbuilder.setAttribute(l_char_dtl_item, 'queryable', 'true');
    end if;




    create_special_item_mult_vqr(g_collection_id_attribute, l_char_item, l_char_dtl_item);
    add_child_to_parent(l_top_region, l_char_item, 'contents');
    add_child_to_parent(l_data_region, l_char_dtl_item, 'contents');
    if l_counter < 5 then
        jdr_docbuilder.setAttribute(l_char_item, 'rendered', 'true');
        jdr_docbuilder.setAttribute(l_char_dtl_item, 'rendered', 'false');
--        jdr_docbuilder.setAttribute(l_char_item, 'queryable', 'true');
--        jdr_docbuilder.setAttribute(l_char_dtl_item, 'queryable', 'false');
        l_counter := l_counter + 1;
    else
        jdr_docbuilder.setAttribute(l_char_item, 'rendered', 'false');
        jdr_docbuilder.setAttribute(l_char_dtl_item, 'rendered', 'true');
--        jdr_docbuilder.setAttribute(l_char_item, 'queryable', 'false');
--        jdr_docbuilder.setAttribute(l_char_dtl_item, 'queryable', 'true');
    end if;



    create_special_item_mult_vqr(g_last_update_date_attribute, l_char_item, l_char_dtl_item);
    add_child_to_parent(l_top_region, l_char_item, 'contents');
    add_child_to_parent(l_data_region, l_char_dtl_item, 'contents');
    if l_counter < 5 then
        jdr_docbuilder.setAttribute(l_char_item, 'rendered', 'true');
        jdr_docbuilder.setAttribute(l_char_dtl_item, 'rendered', 'false');
--        jdr_docbuilder.setAttribute(l_char_item, 'queryable', 'true');
--        jdr_docbuilder.setAttribute(l_char_dtl_item, 'queryable', 'false');
        l_counter := l_counter + 1;
    else
        jdr_docbuilder.setAttribute(l_char_item, 'rendered', 'false');
        jdr_docbuilder.setAttribute(l_char_dtl_item, 'rendered', 'true');
--        jdr_docbuilder.setAttribute(l_char_item, 'queryable', 'false');
--        jdr_docbuilder.setAttribute(l_char_dtl_item, 'queryable', 'true');
    end if;



    -- add the comment items, if any
    for rec in plan_chars ('Comments')
    loop
        -- create the comments region
        If l_comments_exist = 'N' then
            l_comments_region_code := construct_code(g_vqr_comments_prefix, p_plan_id);
            l_comments_region := create_jrad_region(l_comments_region_code, 'labeledFieldLayout', null, '1');
            l_comments_exist := 'Y';
        end if;
        -- add to comment items to the region
        c_displayed_flag := create_item_for_mult_vqr(p_plan_id, rec.char_id, l_char_item, l_char_dtl_item);
        add_child_to_parent(l_comments_region, l_char_dtl_item, 'contents');
        jdr_docbuilder.setAttribute(l_char_item, 'rendered', c_displayed_flag);
        jdr_docbuilder.setAttribute(l_char_item, 'styleClass', 'OraTableDetail');

--        if c_displayed_flag = 'true' then
--            jdr_docbuilder.setAttribute(l_char_item, 'queryable', 'true');
--        end if;

    end loop;

    -- Now add comments region to detail region
    if l_comments_exist = 'Y' then
        add_child_to_parent(l_dtl_region, l_comments_region, 'contents');
    end if;

    -- now add the detail region to the main region
    add_child_to_parent(l_top_region, l_dtl_region, 'detail');

    -- save the document
    l_saved := JDR_DOCBUILDER.SAVE;

EXCEPTION

    WHEN OTHERS THEN
        l_err_num := SQLCODE;
        l_err_msg := SUBSTR(SQLERRM, 1, 100);
        -- dbms_output.put_line(err_msg);

END map_plan_vqr_multiple;

-- End: 12.1 Usability project changes for export
-- abgangul


PROCEDURE map_plan_eqr_multiple(
    p_plan_id IN NUMBER,
    p_special_segment VARCHAR2) IS

    l_table_region_code  VARCHAR2(35);
    l_dtl_region_code VARCHAR2(35);

    l_mode      VARCHAR2(15) := g_eqr_multiple_layout;
    l_saved PLS_INTEGER;
    l_err_num      NUMBER;
    l_err_msg      VARCHAR2(100);
    l_char_count NUMBER := NULL;

    l_top_doc JDR_DOCBUILDER.DOCUMENT := NULL;
    l_table_region JDR_DOCBUILDER.ELEMENT := NULL;
    l_dtl_region JDR_DOCBUILDER.ELEMENT := NULL;

    --
    -- 12.1 Device Integration Project
    -- Variables for adding device region
    -- to the multi row layout.
    -- bhsankar Wed Oct 24 04:45:16 PDT 2007
    --
    l_stk_region    JDR_DOCBUILDER.ELEMENT := NULL;
    l_device_region JDR_DOCBUILDER.ELEMENT := NULL;
    l_stk_region_code varchar2(35) := NULL;
    l_device_region_code varchar2(35) := NULL;
    l_prompt VARCHAR2(30);
BEGIN
    -- The top region is a table
    -- It contains all the region items and the hide/show detailed region.
    -- Here I add all the plan chars to the table as well as the detailed region
    -- with a different ID. Comments are added only to detailed region.
    -- Adding multi row attachment link too to the table.
    -- At run time, CO decides what to render horizontally in the row and what
    -- to render in the detailed region depending on the number of elements in the
    -- plan and whether an element is a context element or not.

    -- A document is created with the table region as its top level element


    l_stk_region_code := construct_code(g_eqr_multiple_prefix || p_special_segment, p_plan_id);
    l_dtl_region_code := construct_code(g_eqr_mult_dtl_prefix || p_special_segment, p_plan_id);
    l_table_region_code := construct_code(g_eqr_mult_data_prefix || p_special_segment, p_plan_id);
    l_device_region_code := construct_code(g_eqr_device_prefix || p_special_segment, p_plan_id);
    delete_old_top_document(g_jrad_region_path || l_stk_region_code);

    l_top_doc := create_top_document(g_jrad_region_path || l_stk_region_code);
    --
    -- 12.1 Device Integration Project
    -- The top document needs to be a stack layout to
    -- stack the device region instead of table layout.
    -- Hence, commenting.
    -- bhsankar Wed Oct 24 04:45:16 PDT 2007
    --
    -- l_table_region := create_and_set_top_element(l_top_doc, l_table_region_code,
    --                  'table');

    -- Setting the top document as a stacklayout.
    l_stk_region := create_and_set_top_element(l_top_doc, l_stk_region_code,
                        'stackLayout');

    -- Creating the device region if MES is uptaken

    IF FND_PROFILE.VALUE('WIP_MES_OPS_FLAG') = 1 THEN
       l_device_region := create_device_region(p_plan_id, l_device_region_code);

       IF l_device_region.id is not null THEN
          add_child_to_parent(l_stk_region, l_device_region, 'contents');
       END IF;
    END IF;

    -- Adding the table region (data region)
    -- to the stack region (top document) already created.
    l_prompt := get_region_prompt('DATA');

    l_table_region := create_jrad_region (l_table_region_code, 'table', l_prompt, null);
    add_child_to_parent(l_stk_region, l_table_region, 'contents');

    -- 12.1 Device Integration Project End.

    -- Add non comment plan chars and special items as children to the table region
    l_char_count := add_plan_chars_to_region(p_plan_id, l_table_region,
                                                l_mode, 'NonComments');
    add_special_chars_to_region(p_plan_id, l_table_region, l_mode);

    -- Create detail region and add it to the table region.
    l_dtl_region := create_detail_region(p_plan_id, l_dtl_region_code,
                                                g_eqr_multiple_layout);
    add_child_to_parent(l_table_region, l_dtl_region, 'detail');

    -- 12.1 Inline Project
    -- saugupta
    add_table_selection(l_table_region);
    add_table_action(l_table_region);

    -- save the document
    l_saved := JDR_DOCBUILDER.SAVE;

EXCEPTION

    WHEN OTHERS THEN
        l_err_num := SQLCODE;
        l_err_msg := SUBSTR(SQLERRM, 1, 100);
        -- dbms_output.put_line(err_msg);

END map_plan_eqr_multiple;

PROCEDURE map_plan_eqr_multiple(
    p_plan_id IN NUMBER) IS

BEGIN
    -- this is a wrapper to map_plan_eqr_multiple (p_plan_id, <special segment string>)
    -- in this case, special segment is null
    map_plan_eqr_multiple(p_plan_id, NULL);

END map_plan_eqr_multiple;

-- 12.1 Inline Region in MES Transactions
-- Project code start

-- create advanced table of inline region
-- this should be called from the CP
PROCEDURE map_plan_adv_table_eqr(p_plan_id IN NUMBER,   p_special_segment VARCHAR2) IS

l_table_region_code VARCHAR2(35);
l_dtl_region_code VARCHAR2(35);

l_mode VARCHAR2(15) := g_eqr_advtable_layout;
-- change mode for inline region
l_saved pls_integer;
l_err_num NUMBER;
l_err_msg VARCHAR2(100);
l_char_count NUMBER := NULL;

l_top_doc      jdr_docbuilder.DOCUMENT := NULL;
l_table_region jdr_docbuilder.element  := NULL;
l_dtl_region   jdr_docbuilder.element  := NULL;

l_tbl_act      jdr_docbuilder.element  := NULL;
l_tbl_s_sel    jdr_docbuilder.element  := NULL;
l_tbl_footer   jdr_docbuilder.element  := NULL;
l_api_name constant varchar2(50) := 'MAP_PLAN_ADV_TABLE_EQR';

--
-- 12.1 Device Integration Project
-- Variables for adding device region
-- to the multi row layout.
-- bhsankar Wed Oct 24 04:45:16 PDT 2007
--
l_stk_region    JDR_DOCBUILDER.ELEMENT := NULL;
l_device_region JDR_DOCBUILDER.ELEMENT := NULL;
l_stk_region_code varchar2(35) := NULL;
l_device_region_code varchar2(35) := NULL;
l_prompt VARCHAR2(30);


BEGIN
  log_error(g_pkg_name || l_api_name, 'Function BEGIN');
    l_stk_region_code := construct_code(g_eqr_multiple_prefix || p_special_segment, p_plan_id);
    l_dtl_region_code := construct_code(g_eqr_mult_dtl_prefix || p_special_segment, p_plan_id);
    l_table_region_code := construct_code(g_eqr_mult_data_prefix || p_special_segment, p_plan_id);
    l_device_region_code := construct_code(g_eqr_device_prefix || p_special_segment, p_plan_id);
    delete_old_top_document(g_jrad_region_path || l_stk_region_code);

    l_top_doc := create_top_document(g_jrad_region_path || l_stk_region_code);
    --
    -- 12.1 Device Integration Project
    -- The top document needs to be a stack layout to
    -- stack the device region instead of table layout.
    -- Hence, commenting.
    -- bhsankar Wed Oct 24 04:45:16 PDT 2007
    --
    -- l_table_region := create_and_set_top_element(l_top_doc, l_table_region_code,
    --                  'table');

    -- Setting the top document as a stacklayout.
    l_stk_region := create_and_set_top_element(l_top_doc, l_stk_region_code,
                        'stackLayout');

    -- Creating the device region if MES is uptaken

    IF FND_PROFILE.VALUE('WIP_MES_OPS_FLAG') = 1 THEN
       l_device_region := create_device_region(p_plan_id, l_device_region_code);

       IF l_device_region.id is not null THEN
          add_child_to_parent(l_stk_region, l_device_region, 'contents');
       END IF;
    END IF;

    -- Adding the table region (data region)
    -- to the stack region (top document) already created.
    l_prompt := get_region_prompt('DATA');

    l_table_region := create_jrad_region (l_table_region_code, 'advancedTable', l_prompt, null);
    JDR_DOCBUILDER.setAttribute(l_table_region, 'viewName', g_vo_name);
    add_child_to_parent(l_stk_region, l_table_region, 'contents');

    -- 12.1 Device Integration Project End.

--  l_table_region_code := construct_code(g_eqr_adv_table_prefix || p_special_segment,   p_plan_id);
--  l_dtl_region_code := construct_code(g_eqr_mult_dtl_prefix || p_special_segment,   p_plan_id);
  log_error(g_pkg_name || l_api_name, 'Region Info: ' || l_table_region_code);
  -- delete the existing document
--  delete_old_top_document(g_jrad_region_path || l_table_region_code);

--  l_top_doc := create_top_document(g_jrad_region_path || l_table_region_code);
  log_error(g_pkg_name || l_api_name, 'JRAD Doc created');
  -- either change the method or call a diff method for creating the advanced region
  -- l_table_region := create_and_set_top_element(l_top_doc,   l_table_region_code,   'advancedTable');
  log_error(g_pkg_name || l_api_name,'Advanced Table Created ');
  -- Add non comment plan chars and special items as children to the table region
  -- below we neeed to add special colums to advanced table to work
  l_char_count := add_plan_chars_to_region(p_plan_id,   l_table_region,   l_mode,   'NonComments');
  log_error(g_pkg_name || l_api_name,'Elements added to Advanced Table: ' || to_char(l_char_count));
  -- Add attachments and special items like org etc
 add_special_chars_to_region(p_plan_id,   l_table_region,  g_eqr_multiple_layout);

  -- Create detail region and add it to the table region.
  --  TODO -> hide show and detail region
   l_dtl_region := create_detail_region(p_plan_id,   l_dtl_region_code,   g_eqr_multiple_layout);
   add_child_to_parent(l_table_region,   l_dtl_region,   'detail');

  add_table_selection(l_table_region);
  add_table_action(l_table_region);
  add_table_footer(l_table_region);

  -- save the document
  l_saved := jdr_docbuilder.save;
  log_error(g_pkg_name || l_api_name, 'Saved Document. Function END');

EXCEPTION

WHEN others THEN
  l_err_num := SQLCODE;
  l_err_msg := SUBSTR(sqlerrm,   1,   100);
  -- dbms_output.put_line(err_msg);

END map_plan_adv_table_eqr;

-- End 12.1 Inline Region in MES Txn

PROCEDURE map_plan_special(
    p_plan_id IN NUMBER) IS

   PRAGMA AUTONOMOUS_TRANSACTION;

   CURSOR plan IS
        SELECT template_plan_id
        FROM qa_plans
        WHERE plan_id = p_plan_id;

   CURSOR valueLookups(c_char_id NUMBER) IS
        SELECT short_code
        FROM qa_plan_char_value_lookups
        WHERE plan_id = p_plan_id
        AND char_id = c_char_id;

   l_template_plan_id NUMBER;
   l_short_code qa_plan_char_value_lookups.short_code%TYPE;
BEGIN
   OPEN plan;
   FETCH plan INTO l_template_plan_id;
   CLOSE plan;

   -- special logic if template_plan_id matches Nonconformance Master
   -- or Corrective Action Request plan
   -- map one plan per each Nonconformance Source (or Request type)
   -- the region name will embed the Nonconformance Source (or Request type)
   --
   -- this is a workaround to overcome the inability to personalize
   -- region with double default column style at user level
   -- admin will create one personalization per each Nonconformance Source (or Request type)
   --
   -- still map one with normal naming scheme
   IF l_template_plan_id in (18, 35) THEN -- Nonconformance master
      OPEN valueLookups(qa_ss_const.nonconformance_source);
      LOOP
         FETCH valueLookups INTO l_short_code;
         EXIT WHEN valueLookups%NOTFOUND;
         map_plan_eqr_single(p_plan_id, g_ncm || l_short_code || '_');
         map_plan_vqr_single(p_plan_id, g_ncm || l_short_code || '_');
         map_plan_eqr_multiple(p_plan_id, g_ncm || l_short_code || '_');
      END LOOP;
      CLOSE valueLookups;
   ELSIF l_template_plan_id = 65 THEN -- Corrective Action Request
      OPEN valueLookups(2147483607); -- should be qa_ss_const.request_type
      LOOP
         FETCH valueLookups INTO l_short_code;
         EXIT WHEN valueLookups%NOTFOUND;
         map_plan_eqr_single(p_plan_id, g_car || l_short_code || '_');
         map_plan_vqr_single(p_plan_id, g_car || l_short_code || '_');
         map_plan_eqr_multiple(p_plan_id, g_car || l_short_code || '_');
      END LOOP;
      CLOSE valueLookups;
   END IF;

   COMMIT; --commit the autonomous txn.

END map_plan_special;

PROCEDURE map_plan(
    p_plan_id IN NUMBER) IS

-- jrad_doc_version was used to check for a jrad plan region in map on demand.
-- During AK -> Jrad migration, since it would take a lot of installation time to
-- create jrad regions for all the existing plans, mapping on demand was used.
-- jrad_doc_version is also used as a work around for fwk's bug 2837618.
-- Whenever we modify a plan, we needed to create a jrad region with a new name.
-- This is achieved by appending jrad_doc_version to the prefix.

-- Here we assume the bug is fixed (11i10). But we still a boolean to check the
-- existence for map on demand. It seems we can directly qiery fwk tables to find
-- out whether a region exists. Needs further investigation.

-- For now, p_jrad_doc_version is null.
l_err_num NUMBER;
l_err_msg VARCHAR2(100);

   PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
   set_debug_mode('FND');
   -- special logic if template_plan_id matches Nonconformance Master
   -- or Corrective Action Request plan

   map_plan_special(p_plan_id);

   -- map for all plan using normal naming scheme
   map_plan_eqr_single(p_plan_id);
   map_plan_vqr_single(p_plan_id);
   -- 12.1 QWB Usability Improvements
   -- map_plan_eqr_multiple(p_plan_id);


   -- 12.1 Inline Region Project
   -- saugupta
   -- log_error(g_pkg_name || 'Map_plan', 'Start Advanced table');
   map_plan_adv_table_eqr(p_plan_id, NULL);

   -- 12.1 Usability Project
   -- Added for export page
   -- abgangul
   map_plan_vqr_multiple(p_plan_id);

   COMMIT; --commit the autonomous txn.

END map_plan;



PROCEDURE map_on_demand (p_plan_id IN NUMBER) IS

    PRAGMA AUTONOMOUS_TRANSACTION;

    l_eqr_single_doc  VARCHAR2(100);
    l_vqr_single_doc VARCHAR2(100);
    l_eqr_multiple_doc VARCHAR2(100);
    l_vqr_multiple_doc VARCHAR2(100);

    l_jrad_upgrade_ver NUMBER;
    l_seed_ver         NUMBER;

BEGIN

    --
    -- Tracking Bug 4697145
    -- MOAC Upgrade feature to perform on demand mapping
    -- if a special JRad LOV is changed.
    -- Added the two SELECTs.
    -- bso Sun Nov  6 17:07:45 PST 2005
    --

    SELECT jrad_upgrade_ver
    INTO   l_jrad_upgrade_ver
    FROM   qa_plans
    WHERE  plan_id = p_plan_id
    FOR UPDATE;

    SELECT jrad_upgrade_ver
    INTO   l_seed_ver
    FROM   qa_plans
    WHERE  plan_id = qa_ss_const.JRAD_UPGRADE_PLAN;

    fnd_msg_pub.initialize;

    l_eqr_single_doc := g_jrad_region_path || construct_code(
        g_eqr_single_prefix, p_plan_id);
    l_vqr_single_doc := g_jrad_region_path || construct_code(
        g_vqr_single_prefix, p_plan_id);
    l_eqr_multiple_doc := g_jrad_region_path || construct_code(
        g_eqr_multiple_prefix, p_plan_id);


    -- 12.1 Usability project
    -- Added for export page.
    l_vqr_multiple_doc := g_jrad_region_path || construct_code(
        g_vqr_multiple_prefix, p_plan_id);


    --
    -- Tracking Bug 4697145
    -- MOAC Upgrade feature to perform on demand mapping
    -- if a special JRad LOV is changed.
    -- Added the two OR conditions.
    -- bso Sun Nov  6 17:07:45 PST 2005
    --
    -- Reformatted the logical conditions to a form that I
    -- believe is easier to understand.
    -- bso
    --

    IF l_jrad_upgrade_ver IS NULL OR
        l_jrad_upgrade_ver < l_seed_ver OR
        NOT jdr_docbuilder.documentExists(l_eqr_single_doc) OR
            NOT jdr_docbuilder.documentExists(l_vqr_single_doc) OR
            NOT jdr_docbuilder.documentExists(l_vqr_multiple_doc) OR
            NOT jdr_docbuilder.documentExists(l_eqr_multiple_doc) THEN
        -- map plan. documents do not exist,
        -- or of lower version than wanted.
        map_plan(p_plan_id);

        -- Tracking Bug 4697145
        -- Map iSP/eAM etc plans also.
        qa_jrad_pkg.map_plan(p_plan_id);


        -- Tracking Bug 4697145
        -- Now indicate the upgrade is completed.
        jrad_upgraded(p_plan_id);
    END IF;

    --
    -- Bug 5182097
    -- Make a call to refetch the qpc cache in the validation
    -- API otherwise some subtle Setup Collection Plan changes
    -- such as turning mandatory flag on/off will not be
    -- immediately reflected in QWB.
    -- bso Mon May  1 17:43:03 PDT 2006
    --
    qa_plan_element_api.refetch_qa_plan_chars(p_plan_id);

    COMMIT;

END map_on_demand;



--
-- Bug 4697145
-- MOAC upgrade needs to delete JRad region.  But this procedure
-- is generic to be used by other projects.
-- Used by qajrad.sql
--
PROCEDURE delete_plan_jrad_region(p_plan_id IN NUMBER) IS

BEGIN
    delete_old_top_document(g_jrad_region_path ||
        construct_code(g_eqr_single_prefix, p_plan_id));
    delete_old_top_document(g_jrad_region_path ||
        construct_code(g_eqr_multiple_prefix, p_plan_id));
END delete_plan_jrad_region;


--
-- Tracking Bug 4697145
-- MOAC Upgrade feature to indicate this plan has
-- been regenerated and on demand mapping can skip.
-- bso Sun Nov  6 16:52:53 PST 2005
--
PROCEDURE jrad_upgraded(p_plan_id IN NUMBER) IS

BEGIN
    UPDATE qa_plans
    SET    jrad_upgrade_ver =
          (SELECT nvl(jrad_upgrade_ver, 1)
           FROM   qa_plans
           WHERE  plan_id = qa_ss_const.JRAD_UPGRADE_PLAN)
    WHERE  plan_id = p_plan_id;
END jrad_upgraded;


END qa_ssqr_jrad_pkg;

/
