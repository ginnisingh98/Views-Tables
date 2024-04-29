--------------------------------------------------------
--  DDL for Package Body PON_CP_INTRFAC_TO_TRANSACTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_CP_INTRFAC_TO_TRANSACTION" as
/* $Header: PONCPITB.pls 120.26.12010000.3 2013/08/16 05:57:24 irasoolm ship $ */


/** =============Start declaration of global variables =========*/
g_update_action CONSTANT VARCHAR2(1) := '#';
g_add_action CONSTANT VARCHAR2(1) :='+';
g_delete_action CONSTANT VARCHAR2(1) := '-';

-- batch id for which the copy needs to take place
g_batch_id                      NUMBER;
-- auction heder id corresponding to the batch id for which the copy needs to take place
g_auction_header_id             NUMBER;
--User id of the person who uploaded the spreadsheet.
g_user_id                       NUMBER;

--the following are used in the function GET_NEXT_PE_SEQUENCE_NUMBER
g_price_element_line_number     NUMBER;
g_price_element_seq_number      NUMBER;
g_price_element_seq_increment   CONSTANT NUMBER  := 10;

-- These will be used by the procedure INITIALIZE_LINE_ATTR_GROUP
g_default_attribute_group                 VARCHAR2(30);
g_default_section_name                    VARCHAR2(240);
g_default_appl_attribute_group            CONSTANT VARCHAR2(7) := 'GENERAL';
g_default_appl_section_name               CONSTANT VARCHAR2(7) := 'General';

-- These determine if attribute, price differentials or price elements data is to be captured.
g_line_attribute_enabled        VARCHAR2(1);
g_price_differentials_flag      VARCHAR2(1);
g_price_element_enabled_flag    VARCHAR2(1);
g_attribute_score_enabled_flag  VARCHAR2(1);

--This will be used by GET_SEQUENCE_NUMBER
g_cur_internal_line_num         NUMBER;
g_max_attribute_seq_num         NUMBER;

--Global varibales that are computed once and is required in UPDATE_PRICE_FACTORS
g_is_amendment                  VARCHAR2(1);
 -- This is the max previous round line plus one.
g_max_prev_line_num_plus_one       number;

-- These will be used for debugging the code
g_fnd_debug             CONSTANT VARCHAR2(1)  := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
g_pkg_name              CONSTANT VARCHAR2(30) := 'PON_CP_INTRFAC_TO_TRANSACTION';
g_module_prefix         CONSTANT VARCHAR2(50) := 'pon.plsql.' || g_pkg_name || '.';
/** ============= End declaration of global variables =========*/



/** =============Start declaration of private functions and procedures =========*/
PROCEDURE print_debug_log(p_module   IN    VARCHAR2,
                          p_message  IN    VARCHAR2);

PROCEDURE print_error_log(p_module   IN    VARCHAR2,
                          p_message  IN    VARCHAR2);


PROCEDURE INITIALIZE_LINE_ATTR_GROUP(p_party_id IN NUMBER);


-- Procedures for deleteing lines and their children that have been
-- marked as  deleted by the spread
PROCEDURE DELETE_LINES_WITH_CHILDREN;

-- Procedures for inserting data for lines that have been added.
PROCEDURE ADD_LINES;
PROCEDURE ADD_PRICE_FACTORS;
PROCEDURE ADD_PRICE_DIFFERENTIALS;
PROCEDURE ADD_ATTRIBUTES;
PROCEDURE ADD_ATTRIBUTE_SCORES;
PROCEDURE ADD_NEW_LINE_WITH_CHILDREN;


-- Procedures for updating/inserting data for lines that have been updated.
PROCEDURE UPDATE_LINES;
PROCEDURE UPDATE_PRICE_DIFFERNTIALS;
PROCEDURE UPDATE_PRICE_FACTORS;
PROCEDURE UPDATE_LINE_ATTRIBUTES;
PROCEDURE UPDATE_LINES_WITH_CHILDREN;
/** =============End declaration of private functions and procedures =========*/



/*======================================================================
 PROCEDURE:  DEFAULT_PREV_ROUND_AMEND_LINES    PUBLIC
 PARAMETERS:
    IN : p_auction_header_id     NUMBER  auction header id
    IN : p_batch_id              NUMBER batch id for which the defaulting will be done.

 COMMENT   :  This procedure will default various field in pon_item_prices_interface,
              pon_auc_attributes_interface and pon_auc_price_elements_int
              for lines being updated based on various conditions.
======================================================================*/
procedure DEFAULT_PREV_ROUND_AMEND_LINES(
  p_auction_header_id IN NUMBER,
  p_batch_id IN NUMBER) IS

l_prev_max_line_number number;
l_contract_type pon_auction_headers_all.contract_type%type;
l_is_blanket_agreement VARCHAR2(1);
l_is_amendment VARCHAR2(1);

l_module CONSTANT  VARCHAR2(30) := 'DEFAULT_PREV_ROUND_AMEND_LINES';

begin
--{
    ----IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'DEFAULT_PREV_ROUND_AMEND_LINES START p_auction_header_id = '||p_auction_header_id||
                                 ' p_batch_id = '||p_batch_id);
    END IF;

    select
    max_line_number,
    contract_type,
    decode(nvl(amendment_number,0),0,'N','Y')
    into
     l_prev_max_line_number,
     l_contract_type,
     l_is_amendment
    from
    pon_auction_headers_all
    where auction_header_id = p_auction_header_id;

    IF (l_contract_type = 'BLANKET' or l_contract_type = 'CONTRACT') THEN
       l_is_blanket_agreement := 'Y' ;
    ELSE
       l_is_blanket_agreement := 'N' ;
    END IF;

    -- Update all lines that have line number less than or
    -- equal to the max line number and have action as update.
    update pon_item_prices_interface p1
    set p1.price_and_quantity_apply = 'Y'
    where
        p1.batch_id = p_batch_id
        and p1.action = g_update_action
        and exists
            (select 'x'
            from
            pon_auction_item_prices_all prev_round_item
            where
            prev_round_item.line_number <= l_prev_max_line_number
            and prev_round_item.auction_header_id = p_auction_header_id
            and nvl(prev_round_item.quantity_disabled_flag,'N') = 'Y'
            and nvl(prev_round_item.price_disabled_flag,'N') = 'Y');


    -- For blanket lines or items with description null
    -- the description will be set from the Item as it is
    -- stored in the database.
    -- TBD CONSIDER THIS FOR UPDATE STATEMENT.
    -- TBD ANY VALIDATIONS
    update pon_item_prices_interface p1
    set item_description =
        (select item_description
         from pon_auction_item_prices_all pal
         where p1.batch_id = p_batch_id
         and p1.action = g_update_action
         and p1.auction_header_id = pal.auction_header_id
         and p1.auction_line_number = pal.line_number)
    where
    p1.batch_id = p_batch_id
    and p1.action = g_update_action
    and exists
         (select 'x'
          from pon_auction_item_prices_all pal1
          where
          p1.auction_header_id = pal1.auction_header_id
          and p1.auction_line_number = pal1.line_number
          and (pal1.line_origination_code ='BLANKET' or p1.item_id is not null));


    -- Update the line type and the line number of existing
    -- lines if they are from blanket or requisition.
    update pon_item_prices_interface p1
    set line_type = (select tl.line_type
             from po_line_types_tl tl,
             pon_auction_item_prices_all pal
             where p1.batch_id = p_batch_id
             and p1.action = g_update_action
             and pal.auction_header_id = p1.auction_header_id
             and p1.auction_line_number = pal.line_number
             and pal.line_type_id = tl.line_type_id
             AND tl.LANGUAGE = UserEnv('Lang')),
    item_number = (select pal.item_number
             from
             pon_auction_item_prices_all pal
             where p1.batch_id = p_batch_id
             and p1.action = g_update_action
             and p1.auction_header_id = pal.auction_header_id
             and p1.auction_line_number = pal.line_number)
    where
    p1.batch_id = p_batch_id
    and p1.action = g_update_action
    and exists
         (select 'x'
          from pon_auction_item_prices_all pal1
          where
          p1.auction_header_id = pal1.auction_header_id
          and p1.auction_line_number = pal1.line_number
          and pal1.line_origination_code in ('BLANKET','REQUISITION'));

/*
    -- Update the Item revision and Unit Of Measure if the
    -- line is coming from a requisition from
    update pon_item_prices_interface p1
    set (item_revision,unit_of_measure) =
        (select pal.item_revision,pal.unit_of_measure
         from
         pon_auction_item_prices_all pal
         where p1.batch_id = p_batch_id
         and p1.action=g_update_action
         and p1.auction_header_id = pal.auction_header_id
         and p1.auction_line_number = pal.line_number)
    where
    p1.batch_id = p_batch_id
    and p1.action = g_update_action
    and exists
         (select 'x'
           from pon_auction_item_prices_all pal1
          where
          p1.auction_header_id = pal1.auction_header_id
          and p1.auction_line_number = pal1.line_number
          and pal1.line_origination_code = 'REQUISITION');

    --  If the line order type look up code = 'AMOUNT' and the
    --  line is from a backing requisition from the then update the quantity
    update pon_item_prices_interface p1
    set quantity = (select pal.quantity
            from
            pon_auction_item_prices_all pal
            where p1.batch_id = p_batch_id
            and p1.action = g_update_action
            and pal.auction_header_id = p1.auction_header_id
            and pal.line_number = p1.auction_line_number)
    where
    p1.batch_id = p_batch_id
    and p1.action = g_update_action
    and exists
        (select 'x'
        from pon_auction_item_prices_all pal1
        where
        p1.auction_header_id = pal1.auction_header_id
        and p1.auction_line_number = pal1.line_number
        and pal1.order_type_lookup_code = 'AMOUNT'
        and pal1.line_origination_code ='REQUISITION');

 TBD verify Combine above 2 statements as shown below */


    -- Update the Item revision and Unit Of Measure if the
    -- line is coming from a requisition from
    --  If the line order type look up code = 'AMOUNT' and the
    --  line is from a backing requisition from the then update the quantity
    update pon_item_prices_interface p1
    set (item_revision,
        unit_of_measure,
        quantity) =
        (select pal.item_revision,
            pal.unit_of_measure,
            decode(pal.order_type_lookup_code,'AMOUNT',pal.quantity,p1.quantity)
         from
         pon_auction_item_prices_all pal
         where p1.batch_id = p_batch_id
         and p1.action=g_update_action
         and p1.auction_header_id = pal.auction_header_id
         and p1.auction_line_number = pal.line_number)
    where
    p1.batch_id = p_batch_id
    and p1.action = g_update_action
    and exists
        (select 'x'
        from pon_auction_item_prices_all pal1
        where
        p1.auction_header_id = pal1.auction_header_id
        and p1.auction_line_number = pal1.line_number
        and pal1.line_origination_code ='REQUISITION');

 -- TBD : Lets se if we can ignore this while copying. VERY DIRTY
    -- Update Ship to location id from the if the negotiation
    -- outcome is BPA or CPA.
    if l_is_blanket_agreement <> 'Y' then

        update pon_item_prices_interface p1
        set ship_to_location = (select st.location_code
             from po_ship_to_loc_org_v st,
             financials_system_params_all fsp,
             pon_auction_item_prices_all pal
             where p1.batch_id = p_batch_id
             and p1.action = g_update_action
             and p1.auction_header_id = pal.auction_header_id
             and p1.auction_line_number = pal.line_number
             and (st.SET_OF_BOOKS_ID IS NULL
              OR st.SET_OF_BOOKS_ID = fsp.set_of_books_id)
             AND st.organization_id = fsp.org_id
             AND st.location_id = fsp.SHIP_TO_LOCATION_ID
             AND nvl(fsp.org_id,-9999) = nvl(pal.org_id,-9999))
        where
        p1.batch_id = p_batch_id
        and p1.action = g_update_action
        and exists
             (select 'x'
               from pon_auction_item_prices_all pal1
              where
              p1.auction_header_id = pal1.auction_header_id
              and p1.auction_line_number = pal1.line_number
              and pal1.line_origination_code in ('BLANKET','REQUISITION'));

    end if;

    -- If this is an amendment then the display target flag and display target
    -- unit flag will be updated from the last amendment.
    if l_is_amendment = 'Y' then
        update pon_item_prices_interface p1
        set (display_target_flag,unit_display_target_flag) = (select
                    pal.display_target_price_flag,
                    pal.unit_display_target_flag
                     from
                     pon_auction_item_prices_all pal
                     where p1.batch_id = p_batch_id
                     and p1.action = g_update_action
                     and p1.auction_line_number = pal.line_number
                     and pal.auction_header_id = p1.auction_header_id)
        where
        p1.batch_id = p_batch_id
        and p1.action = g_update_action;
    END if;

    -- Update display_target_flag in pon_auc_attributes_interface for existing attributes
    -- in lines being updated for attributes that have sequence number -10 and -20
    update pon_auc_attributes_interface interface_attribute
    set display_target_flag =
     (select display_target_flag
      from
      pon_auction_attributes auction_attributes
      where
      auction_attributes.auction_header_id  = interface_attribute.auction_header_id
      and auction_attributes.line_number  = interface_attribute.auction_line_number
      and auction_attributes.attribute_name = interface_attribute.attribute_name
      and auction_attributes.sequence_number in (-10,-20))
    where
    interface_attribute.batch_id = p_batch_id
    and exists
    (select 'x'
    from
    pon_item_prices_interface item_interface,
    pon_auction_attributes auction_attributes
    where
    item_interface.batch_id  = p_batch_id
    and item_interface.action = g_update_action
    and item_interface.auction_line_number = interface_attribute.auction_line_number
    and auction_attributes.auction_header_id  = interface_attribute.auction_header_id
    and auction_attributes.line_number  = interface_attribute.auction_line_number
    and auction_attributes.attribute_name = interface_attribute.attribute_name
    and auction_attributes.sequence_number in (-10,-20));

    -- Update display_target_flag in pon_auc_price_elements_int for existing price elements
    -- for lines that were present in the previous amendment.
    if l_is_amendment = 'Y' then

        update pon_auc_price_elements_int pe_int
        set pe_int.DISPLAY_TARGET_FLAG = (select pe1.display_target_flag
            from pon_price_elements pe1
            where
            pe_int.auction_line_number = pe1.line_number
            and pe_int.auction_header_id = pe1.auction_header_id
            and pe1.PRICE_ELEMENT_TYPE_ID = pe_int.PRICE_ELEMENT_TYPE_ID)
        where pe_int.batch_id = p_batch_id
        and exists
        (select
        'x'
        from
        pon_price_elements pe,
        pon_item_prices_interface paip_int,
        pon_auction_headers_all pah
        where
        paip_int.batch_id = p_batch_id
        and pe_int.auction_line_number = pe.line_number
        and pe_int.auction_header_id = pe.auction_header_id
        and pah.auction_header_id = pe.auction_header_id
        and paip_int.batch_id = pe_int.batch_id
        and paip_int.auction_line_number = pe_int.auction_line_number
        and pe.PRICE_ELEMENT_TYPE_ID = pe_int.PRICE_ELEMENT_TYPE_ID
        and pah.max_internal_line_num >= paip_int.auction_line_number
        and paip_int.action = g_update_action);

    END IF;
    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'DEFAULT_PREV_ROUND_AMEND_LINES END p_auction_header_id = '||p_auction_header_id||
                                 ' p_batch_id = '||p_batch_id);
    END IF;

--}
END DEFAULT_PREV_ROUND_AMEND_LINES;


/*======================================================================
 PROCEDURE:  GET_NEXT_PE_SEQUENCE_NUMBER    PUBLIC
 PARAMETERS:
    IN : p_auction_header     NUMBER  auction header id
    IN : p_line_number        NUMBER  line number

 COMMENT   :  This function will return the next line Price element sequence number
              for the new price elements being inserted for existing and new lines.
======================================================================*/
FUNCTION GET_NEXT_PE_SEQUENCE_NUMBER(p_auction_header IN NUMBER,
                                     p_line_number IN NUMBER)
RETURN NUMBER IS

l_module CONSTANT VARCHAR2(27) := 'GET_NEXT_PE_SEQUENCE_NUMBER';
l_next_sequence_number number;

BEGIN
--{
    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'GET_NEXT_PE_SEQUENCE_NUMBER START');
    END IF;

    l_next_sequence_number := g_price_element_seq_number + 10;
/*
    --If the g_price_element_line_number = p_line_number then simple increment
    --g_price_element_seq_number by 10 (g_price_element_seq_increment) else
    --get the max price element sequence_number for the line and increment it by
    --10

    if p_line_number <> nvl(g_price_element_line_number,-1) then
    --{
        select nvl(max(sequence_number),0) + g_price_element_seq_increment
        into
        l_next_sequence_number
        from
        pon_price_elements
        where
        auction_header_id = p_auction_header
        and line_number = p_line_number;

        IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            print_debug_log(l_module,'GET_NEXT_PE_SEQUENCE_NUMBER LINE Number is not same '||
                                     ' p_line_number = '||p_line_number||
                                     ' g_price_element_line_number = '||g_price_element_line_number);
        END IF;

        g_price_element_line_number := p_line_number;

    --}
    else
    --{
        l_next_sequence_number := g_price_element_seq_number + g_price_element_seq_increment;
    --}
    end if;
*/
    g_price_element_seq_number := l_next_sequence_number;

    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'GET_NEXT_PE_SEQUENCE_NUMBER END l_next_sequence_number = '||l_next_sequence_number);
    END IF;

    return l_next_sequence_number;
--}
END GET_NEXT_PE_SEQUENCE_NUMBER;



/*======================================================================
 PROCEDURE:  INITIALIZE_LINE_ATTR_GROUP    PRIVATE
 PARAMETERS:
    IN : p_party_id     NUMBER  party id for which the defualt attribute
                                group is to be set.

 COMMENT   :  This function will set the default line attribute group
              in the global variable g_default_attribute_group for the
              party id passed as a parameter. The global variable
              g_default_attribute_group will be set to 'GENERAL' if the
              party prefrence LINE_ATTR_DEFAULT_GROUP does not exist.
======================================================================*/
PROCEDURE INITIALIZE_LINE_ATTR_GROUP(p_party_id IN NUMBER) is

l_module CONSTANT VARCHAR2(26) := 'INITIALIZE_LINE_ATTR_GROUP';
l_default_pary_group VARCHAR2(30);
l_pref_value      VARCHAR2(30);
l_pref_meaning    VARCHAR2(80);
l_status          VARCHAR2(1);
l_exception_msg   VARCHAR2(100);

BEGIN
--{
    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'INITIALIZE_LINE_ATTR_GROUP START p_party_id = '||p_party_id);
    END IF;

    pon_profile_util_pkg.retrieve_party_pref_cover(
     p_party_id         => p_party_id,
     p_app_short_name   => 'PON',
     p_pref_name        => 'LINE_ATTR_DEFAULT_GROUP',
     x_pref_value       => l_default_pary_group,
     x_pref_meaning     => l_pref_meaning,
     x_status           => l_status,
     x_exception_msg    => l_exception_msg
    );

    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'INITIALIZE_LINE_ATTR_GROUP END p_party_id = '||p_party_id||
                'l_default_pary_group = '||l_default_pary_group||
                'l_pref_meaning = '||l_pref_meaning||
                'l_status = '||l_status||
                'l_exception_msg = '||l_exception_msg);
    END IF;

    IF (l_status = 'S' and l_default_pary_group is not null and l_default_pary_group <>'') THEN
       g_default_attribute_group := l_default_pary_group;
       g_default_section_name := l_default_pary_group;
    ELSE
       g_default_attribute_group := g_default_appl_attribute_group;
       g_default_section_name := g_default_appl_section_name;
    END IF;

    SELECT nvl(max(sequence_number),10)
    INTO g_price_element_seq_number
    FROM pon_price_elements
    WHERE auction_header_id = g_auction_header_id;

    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'INITIALIZE_LINE_ATTR_GROUP END p_party_id = '||p_party_id||
                        'g_default_attribute_group = '|| g_default_attribute_group ||
                        'g_price_element_seq_number = '|| g_price_element_seq_number);
    END IF;

--}
END INITIALIZE_LINE_ATTR_GROUP;


/*======================================================================
 FUNCTION:  GET_SEQUENCE_NUMBER    PRIVATE
 PARAMETERS:
    IN : p_batch_id                 NUMBER  batch id
    IN : p_interface_line_id        NUMBER  interface_line_id for the line
                                            whose attribute is being copied.
    IN : p_template_sequence_number NUMBER  Sequence number of the attribute
                                            in the template

 COMMENT   :  This procedure determines the sequence number of the attributes
              being copied. We need this special handling for templates.
======================================================================*/
FUNCTION GET_SEQUENCE_NUMBER(p_batch_id          IN NUMBER,
                             p_interface_line_id IN NUMBER,
                             p_template_sequence_number IN NUMBER) RETURN NUMBER
IS

l_sequence_number   NUMBER;

BEGIN
--{
    if g_cur_internal_line_num = p_interface_line_id then
    --{
        l_sequence_number := g_max_attribute_seq_num + p_template_sequence_number;
    --}
    else
    --{
        g_cur_internal_line_num := p_interface_line_id;

        select nvl(max(SEQUENCE_NUMBER), 0) + p_template_sequence_number
        into   l_sequence_number
        from   pon_auc_attributes_interface
        where  batch_id = p_batch_id
               and interface_line_id = p_interface_line_id
               and response_type_name <> 'PON_FROM_TEMPLATE';
    --}
    end if;

    g_max_attribute_seq_num := l_sequence_number;

    RETURN l_sequence_number;
--}
END get_sequence_number;


/*======================================================================
 FUNCTION:  GET_ATTR_GROUP_SEQ_NUMBER    PRIVATE
 PARAMETERS:
    IN : p_batch_id                 NUMBER  batch id
    IN : p_interface_line_id        NUMBER  interface_line_id for the line
                                            whose attribute is being copied.
    IN : p_attr_group               NUMBER  attribute group being copied.
    IN : p_template_sequence_number NUMBER  Sequence number of the attribute
                                            in the template

 COMMENT   :  Determines the grooup sequence number of the attributes being
              copied from templates.
======================================================================*/
FUNCTION get_attr_group_seq_number(p_batch_id          IN NUMBER,
                                   p_interface_line_id IN NUMBER,
                                   p_attr_group        IN VARCHAR2,
                                   p_template_group_seq_number IN NUMBER) RETURN NUMBER

IS

l_attr_group_seq_number     NUMBER;

BEGIN

    select ATTR_GROUP_SEQ_NUMBER
    into   l_attr_group_seq_number
    from   pon_auc_attributes_interface
    where  batch_id = p_batch_id
           and interface_line_id = p_interface_line_id
           and group_code = p_attr_group
           and response_type_name <> 'PON_FROM_TEMPLATE'
           and rownum = 1;

    RETURN l_attr_group_seq_number;

EXCEPTION

     WHEN NO_DATA_FOUND THEN
           -- If the attribute group code does not exist in the attributes interface table
           -- then the attribute group sequence number will be the max attribute group sequence
           -- number for the attributes in the line + the attribute group sequence number of
           -- the attribute in the template
          select nvl(max(ATTR_GROUP_SEQ_NUMBER), 0) + p_template_group_seq_number
          into   l_attr_group_seq_number
          from   pon_auc_attributes_interface
          where  batch_id = p_batch_id
                 and interface_line_id = p_interface_line_id
                 and response_type_name <> 'PON_FROM_TEMPLATE';

     RETURN l_attr_group_seq_number;

END get_attr_group_seq_number;


/*======================================================================
 FUNCTION:  GET_ATTR_DISP_SEQ_NUMBER    PRIVATE
 PARAMETERS:
    IN : p_batch_id                 NUMBER  batch id
    IN : p_interface_line_id        NUMBER  interface_line_id for the line
                                            whose attribute is being copied.
    IN : p_attr_group               NUMBER  attribute group being copied.
    IN : p_template_sequence_number NUMBER  Sequence number of the attribute
                                            in the template

 COMMENT   :  Determines the attribute display sequence for the attribute
              based on the line number and the position of the attribute
              within the template.
              *	If attributes do not exist for the line then the display
                sequence number of the attribute is same as the display
                sequence number of the attribute within the template.
              * If attributes exist for the line then the display sequence
                number of the attribute is max attribute sequence number +
                the display sequence number of the attribute within the
                template
======================================================================*/
FUNCTION get_attr_disp_seq_number(p_batch_id          IN NUMBER,
                                  p_interface_line_id IN NUMBER,
                                  p_attr_group        IN VARCHAR2,
                                  p_template_disp_seq_number IN NUMBER) RETURN NUMBER

IS

l_attr_disp_seq_number  NUMBER;

BEGIN

    select nvl(max(ATTR_DISP_SEQ_NUMBER), 0) + p_template_disp_seq_number
    into   l_attr_disp_seq_number
    from   pon_auc_attributes_interface
    where  batch_id = p_batch_id and
           interface_line_id = p_interface_line_id
           and response_type_name <> 'PON_FROM_TEMPLATE'
           and group_code = p_attr_group;

    RETURN l_attr_disp_seq_number;

END get_attr_disp_seq_number;




/*======================================================================
 PROCEDURE:  DELETE_LINES_WITH_CHILDREN    PRIVATE

 PARAMETERS: NONE

 COMMENT   :  The procedure delete_lines_with_children will delete those lines
              that were marked as deleted in the spreadsheet. The records will
              be deleted from the tables in the following order. For LOTS and
              GROUP marked as deleted the corresponding children are also deleted.
                PON_ATTRIBUTE_SCORES
                PON_AUCTION_ATTRIBUTES
                PON_PF_SUPPLIER_VALUES
                PON_PRICE_ELEMENTS
                PON_PRICE_DIFFERENTIALS
                PON_AUCTION_SHIPMENTS_ALL
                PON_PARTY_LINE_EXCLUSIONS
                PON_AUC_PAYMENTS_SHIPMENTS
                Attachments
                Update backing requisitions for lines being deleted.
                PON_AUCTION_ITEM_PRICES_ALL
======================================================================*/
PROCEDURE DELETE_LINES_WITH_CHILDREN is

l_module CONSTANT VARCHAR2(26) := 'DELETE_LINES_WITH_CHILDREN';
l_error_code    VARCHAR2(100);

CURSOR delete_line_cursor IS
	SELECT
        auction_item.line_number,
        auction_item.line_origination_code,
        auction_item.org_id
    FROM pon_item_prices_interface interface_line,
        pon_auction_item_prices_all auction_item
    WHERE interface_line.BATCH_ID = g_batch_id
    and interface_line.action = g_delete_action
    and interface_line.auction_header_id = auction_item.auction_header_id
    and interface_line.auction_line_number = auction_item.line_number
	and (auction_item.line_number  = interface_line.auction_line_number or
		(auction_item.parent_line_number  = interface_line.auction_line_number
		and auction_item.group_type in ('LOT_LINE','GROUP_LINE')));

--Added for deleting payments attachments
CURSOR delete_pymt_attachments_cursor IS
        SELECT paps.payment_id,
               paps.auction_header_id,
               paps.line_number
    FROM   pon_item_prices_interface p1,
               pon_auction_item_prices paip,
               pon_auc_payments_shipments paps,
               FND_ATTACHED_DOCUMENTS fnd
    WHERE  p1.batch_id = g_batch_id
    AND    p1.action = g_delete_action
    AND    paip.auction_header_id  = p1.auction_header_id
    AND    ((paip.line_number  = p1.auction_line_number
                    AND paip.group_type in ('LINE','LOT')
            AND paps.line_number = paip.line_number)
            OR
                    (paip.parent_line_number  = p1.auction_line_number
                    AND paip.group_type = 'GROUP_LINE'
            AND paps.line_number = paip.line_number))
    AND    paps.auction_header_id = paip.auction_header_id
    AND    fnd.pk1_value = paps.auction_header_id
    AND    fnd.pk2_value = paps.line_number
    AND    fnd.pk3_value = paps.payment_id
    AND    fnd.entity_name = 'PON_AUC_PAYMENTS_SHIPMENTS'
    AND    paip.group_type <> 'LOT_LINE';


BEGIN
--{
    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'DELETE_LINES_WITH_CHILDREN START g_batch_id = '||g_batch_id ||' g_auction_header_id '||g_auction_header_id);
    END IF;

    --delete  from PON_AUCTION_ATTRIBUTES
    if(g_line_attribute_enabled = 'Y') then

        --delete  from PON_ATTRIBUTE_SCORES
        if(g_attribute_score_enabled_flag = 'Y') then
            delete from pon_attribute_scores auction_scores
            where
            auction_header_id = g_auction_header_id
            and exists
            (select
            'x'
            from
            pon_item_prices_interface p1,
            pon_auction_item_prices paip
            where
            p1.batch_id = g_batch_id
            and p1.action = g_delete_action
            and paip.auction_header_id  = p1.auction_header_id
            and (paip.line_number  = p1.auction_line_number or
                (paip.parent_line_number  = p1.auction_line_number
                and paip.group_type in ('LOT_LINE','GROUP_LINE')))
            and auction_scores.line_number = p1.auction_line_number);
        END IF;


        --delete  from PON_AUCTION_ATTRIBUTES
        delete from pon_auction_attributes auction_attributes
        where
        auction_header_id = g_auction_header_id
        and exists
        (select
        'x'
        from
        pon_item_prices_interface p1,
        pon_auction_item_prices paip
        where
        p1.batch_id = g_batch_id
        and p1.action = g_delete_action
        and paip.auction_header_id  = p1.auction_header_id
        and (paip.line_number  = p1.auction_line_number or
            (paip.parent_line_number  = p1.auction_line_number
            and paip.group_type in ('LOT_LINE','GROUP_LINE')))
        and auction_attributes.line_number = p1.auction_line_number);
     END IF;

    --delete  from PON_PF_SUPPLIER_VALUES
    if(g_price_element_enabled_flag = 'Y') then
        delete from pon_pf_supplier_values auction_pf_values
        where
        auction_pf_values.auction_header_id = g_auction_header_id
        and exists
        (select
        'x'
        from
        pon_item_prices_interface p1,
        pon_auction_item_prices paip
        where
        p1.batch_id = g_batch_id
        and p1.action = g_delete_action
        and paip.auction_header_id  = p1.auction_header_id
        and (paip.line_number  = p1.auction_line_number or
            (paip.parent_line_number  = p1.auction_line_number
            and paip.group_type in ('LOT_LINE','GROUP_LINE')))
        and auction_pf_values.line_number = p1.auction_line_number);


        --delete  from PON_PRICE_ELEMENTS
        delete from pon_price_elements price_elements
        where
        auction_header_id = g_auction_header_id
        and exists
        (select
        'x'
        from
        pon_item_prices_interface p1,
        pon_auction_item_prices paip
        where
        p1.batch_id = g_batch_id
        and p1.action = g_delete_action
        and paip.auction_header_id  = p1.auction_header_id
        and (paip.line_number  = p1.auction_line_number or
            (paip.parent_line_number  = p1.auction_line_number
            and paip.group_type in ('LOT_LINE','GROUP_LINE')))
        and price_elements.line_number = p1.auction_line_number);
     END IF;


    --delete  from PON_PRICE_DIFFERENTIALS
    if(g_price_differentials_flag = 'Y') then
        delete from pon_price_differentials price_differentials
        where
        auction_header_id = g_auction_header_id
        and exists
        (select
        'x'
        from
        pon_item_prices_interface p1,
        pon_auction_item_prices paip
        where
        p1.batch_id = g_batch_id
        and p1.action = g_delete_action
        and paip.auction_header_id  = p1.auction_header_id
        and (paip.line_number  = p1.auction_line_number or
            (paip.parent_line_number  = p1.auction_line_number
            and paip.group_type in ('LOT_LINE','GROUP_LINE')))
        and price_differentials.line_number = p1.auction_line_number);
     END IF;

    --delete  from PON_AUCTION_SHIPMENTS_ALL
    delete from pon_auction_shipments_all auction_shipments
    where
    auction_header_id = g_auction_header_id
    and exists
    (select
    'x'
    from
    pon_item_prices_interface p1,
	pon_auction_item_prices paip
    where
    p1.batch_id = g_batch_id
    and p1.action = g_delete_action
	and paip.auction_header_id  = p1.auction_header_id
	and (paip.line_number  = p1.auction_line_number or
		(paip.parent_line_number  = p1.auction_line_number
		and paip.group_type in ('LOT_LINE','GROUP_LINE')))
    and auction_shipments.line_number = p1.auction_line_number);

    --delete  from PON_PARTY_LINE_EXCLUSIONS
    delete from pon_party_line_exclusions supplier_line_exclusions
    where
    auction_header_id = g_auction_header_id
    and exists
    (select
    'x'
    from
    pon_item_prices_interface p1,
	pon_auction_item_prices paip
    where
    p1.batch_id = g_batch_id
    and p1.action = g_delete_action
	and paip.auction_header_id  = p1.auction_header_id
	and (paip.line_number  = p1.auction_line_number or
		(paip.parent_line_number  = p1.auction_line_number
		and paip.group_type in ('LOT_LINE','GROUP_LINE')))
    and supplier_line_exclusions.line_number = p1.auction_line_number);


    -- To delete attachments of pon_auc_payments_shipments
    FOR delete_pymt_attachments_record IN delete_pymt_attachments_cursor LOOP
        FND_ATTACHED_DOCUMENTS2_PKG.DELETE_ATTACHMENTS
        (x_entity_name  => 'PON_AUC_PAYMENTS_SHIPMENTS',
         x_pk1_value => delete_pymt_attachments_record.auction_header_id,
		 x_pk2_value => delete_pymt_attachments_record.line_number,
		 x_pk3_value => delete_pymt_attachments_record.payment_id);
    END LOOP;

    --delete  from PON_AUC_PAYMENTS_SHIPMENTS
    delete from pon_auc_payments_shipments auc_payments
    where
    auction_header_id = g_auction_header_id
    and line_number IN
    (select
    paip.line_number
    from
    pon_item_prices_interface p1,
        pon_auction_item_prices paip
    where
    p1.batch_id = g_batch_id
    and p1.action = g_delete_action
        and paip.auction_header_id  = p1.auction_header_id
        and ((paip.line_number  = p1.auction_line_number) or
                (paip.parent_line_number  = p1.auction_line_number
                and paip.group_type = 'GROUP_LINE')));


    --Delete all attachments and update backing requisitions if they exist.
    FOR delete_line_record IN delete_line_cursor LOOP

        FND_ATTACHED_DOCUMENTS2_PKG.DELETE_ATTACHMENTS
        (x_entity_name  => 'PON_AUCTION_ITEM_PRICES_ALL',
         x_pk1_value => g_auction_header_id,
         x_pk2_value => delete_line_record.line_number);

        if delete_line_record.line_origination_code is not null then
               PON_AUCTION_PKG.DELETE_NEGOTIATION_LINE_REF(x_negotiation_id  => g_auction_header_id,
                        x_negotiation_line_num  => delete_line_record.line_number,
                        x_org_id => delete_line_record.org_id,
                        x_error_code => l_error_code);

        end if;

    end loop;


    delete from pon_auction_item_prices_all item_prices
    where
    auction_header_id = g_auction_header_id
    and exists
    (select
    'x'
    from
    pon_item_prices_interface p1
    where
    p1.batch_id = g_batch_id
    and p1.action = g_delete_action
	and item_prices.parent_line_number  = p1.auction_line_number
	and item_prices.group_type in ('LOT_LINE','GROUP_LINE'));


    delete from pon_auction_item_prices_all item_prices
    where
    auction_header_id = g_auction_header_id
    and exists
    (select
    'x'
    from
    pon_item_prices_interface p1
    where
    p1.batch_id = g_batch_id
    and p1.action = g_delete_action
	and item_prices.line_number  = p1.auction_line_number);


    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'DELETE_LINES_WITH_CHILDREN END g_batch_id = '|| g_batch_id ||' g_auction_header_id '||g_auction_header_id);
    END IF;

--}
END DELETE_LINES_WITH_CHILDREN;


/*======================================================================
 PROCEDURE:  ADD_LINES  PRIVATE

 PARAMETERS: NONE

 COMMENT   :  This procedure will add the new lines from the pon_item_prices_interface
              interface table to the pon_auction_item_prices_all transaction table.
              The following sql will be used for the same. This procedure will
              contain the logic of copying the lines as is present in the
              copyItemData method of NegItemSpreadsheetAMImpl.
======================================================================*/
PROCEDURE ADD_LINES is

l_module CONSTANT VARCHAR2(9) := 'ADD_LINES';

l_price_break_type           pon_auction_item_prices_all.price_break_type%type;
l_price_break_neg_flag       pon_auction_item_prices_all.price_break_neg_flag%type;

BEGIN
--{
    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'ADD_LINES START g_batch_id = '||g_batch_id ||' g_auction_header_id '||g_auction_header_id);
    END IF;

    -- price break line setting
    PON_AUCTION_PKG.get_default_pb_settings (g_auction_header_id,
                                             l_price_break_type,
                                             l_price_break_neg_flag);



    insert into pon_auction_item_prices_all
    fields
    (AUCTION_HEADER_ID,
    LINE_NUMBER,
    SUB_LINE_SEQUENCE_NUMBER,
    DOCUMENT_DISP_LINE_NUMBER,
    DISP_LINE_NUMBER,
    PARENT_LINE_NUMBER,
    GROUP_TYPE,
    ITEM_DESCRIPTION,
    CATEGORY_ID,
    CATEGORY_NAME,
    IP_CATEGORY_ID,
    QUANTITY,
    UOM_CODE,
    UNIT_OF_MEASURE,
    NEED_BY_START_DATE,
    NEED_BY_DATE,
    TARGET_PRICE,
    BID_START_PRICE,
    NOTE_TO_BIDDERS,
    SHIP_TO_LOCATION_ID,
    CURRENT_PRICE,
    RESERVE_PRICE,
    DISPLAY_TARGET_PRICE_FLAG,
    PO_MIN_REL_AMOUNT,
    LINE_TYPE_ID,
    ORDER_TYPE_LOOKUP_CODE,
    ITEM_ID,
    ITEM_NUMBER,
    ITEM_REVISION,
    JOB_ID,
    ADDITIONAL_JOB_DETAILS,
    PO_AGREED_AMOUNT,
    UNIT_TARGET_PRICE,
    UNIT_DISPLAY_TARGET_FLAG,
    DIFFERENTIAL_RESPONSE_TYPE,
    PURCHASE_BASIS,
    PRICE_DISABLED_FLAG,
    QUANTITY_DISABLED_FLAG,
    LAST_AMENDMENT_UPDATE,
    MODIFIED_DATE,
    ORG_ID,
    PRICE_BREAK_TYPE,
    PRICE_BREAK_NEG_FLAG,
    PRICE_DIFF_SHIPMENT_NUMBER,
    --R12 - Complex work
    ADVANCE_AMOUNT,
    RECOUPMENT_RATE_PERCENT,
    PROGRESS_PYMT_RATE_PERCENT,
    RETAINAGE_RATE_PERCENT,
    MAX_RETAINAGE_AMOUNT,
    PROJECT_ID,
    PROJECT_TASK_ID,
    PROJECT_AWARD_ID,
    PROJECT_EXPENDITURE_TYPE,
    PROJECT_EXP_ORGANIZATION_ID,
    PROJECT_EXPENDITURE_ITEM_DATE,
    WORK_APPROVER_USER_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN)
    select
    p1.AUCTION_HEADER_ID,
    p1.AUCTION_LINE_NUMBER,
    p1.SUB_LINE_SEQUENCE_NUMBER,
    p1.DOCUMENT_DISP_LINE_NUMBER,
    p1.DISP_LINE_NUMBER,
    p1.PARENT_LINE_NUMBER,
    p1.GROUP_TYPE,
    p1.ITEM_DESCRIPTION,
    p1.CATEGORY_ID,
    p1.CATEGORY_NAME,
    p1.IP_CATEGORY_ID,
    p1.QUANTITY,
    decode(nvl(p1.PRICE_AND_QUANTITY_APPLY,'Y'),'N','',UOM_CODE),
    decode(nvl(p1.PRICE_AND_QUANTITY_APPLY,'Y'),'N','',UNIT_OF_MEASURE),
    p1.NEED_BY_START_DATE,
    p1.NEED_BY_DATE,
    p1.TARGET_PRICE,
    p1.BID_START_PRICE,
    p1.NOTE_TO_BIDDERS,
    p1.SHIP_TO_LOCATION_ID,
    p1.CURRENT_PRICE,
    p1.RESERVE_PRICE,
    p1.DISPLAY_TARGET_PRICE_FLAG,
    p1.PO_MIN_REL_AMOUNT,
    p1.LINE_TYPE_ID,
    p1.ORDER_TYPE_LOOKUP_CODE,
    p1.ITEM_ID,
    p1.ITEM_NUMBER,
    p1.ITEM_REVISION,
    p1.JOB_ID,
    p1.ADDITIONAL_JOB_DETAILS,
    p1.PO_AGREED_AMOUNT,
    p1.UNIT_TARGET_PRICE,
    p1.UNIT_DISPLAY_TARGET_FLAG,
    decode(p1.DIFFERENTIAL_RESPONSE_TYPE,
        PON_AUCTION_PKG.getMessage('PON_AUCTS_REQUIRED'),'REQUIRED',
        PON_AUCTION_PKG.getMessage('PON_AUCTS_OPTIONAL'),'OPTIONAL',
        PON_AUCTION_PKG.getMessage('PON_AUCTS_DISPLAY_ONLY'),'DISPLAY_ONLY',
        null),
    p1.PURCHASE_BASIS,
    decode(NVL(p1.PRICE_AND_QUANTITY_APPLY,'Y'),'N','Y','N'),
    decode(NVL(p1.PRICE_AND_QUANTITY_APPLY,'Y'),'N','Y','N'),
    pah.AMENDMENT_NUMBER,
    sysdate,
    pah.ORG_ID,
    decode(p1.ORDER_TYPE_LOOKUP_CODE,'AMOUNT', 'NONE',  'FIXED PRICE', 'NONE', l_price_break_type),
    l_price_break_neg_flag,
    -1,
    --R12 - Complex work
    decode(p1.group_type,'GROUP',NULL,'LOT_LINE',NULL,p1.ADVANCE_AMOUNT),
    decode(p1.group_type,'GROUP',NULL,'LOT_LINE',NULL,p1.RECOUPMENT_RATE_PERCENT),
    decode(p1.group_type,'GROUP',NULL,'LOT_LINE',NULL,p1.PROGRESS_PYMT_RATE_PERCENT),
    decode(p1.group_type,'GROUP',NULL,'LOT_LINE',NULL,p1.RETAINAGE_RATE_PERCENT),
    decode(p1.group_type,'GROUP',NULL,'LOT_LINE',NULL,p1.MAX_RETAINAGE_AMOUNT),
    decode(p1.group_type,'GROUP',NULL,'LOT_LINE',NULL,p1.PROJECT_ID),
    decode(p1.group_type,'GROUP',NULL,'LOT_LINE',NULL,p1.PROJECT_TASK_ID),
    decode(p1.group_type,'GROUP',NULL,'LOT_LINE',NULL,p1.PROJECT_AWARD_ID),
    decode(p1.group_type,'GROUP',NULL,'LOT_LINE',NULL,p1.PROJECT_EXPENDITURE_TYPE),
    decode(p1.group_type,'GROUP',NULL,'LOT_LINE',NULL,p1.PROJECT_EXP_ORGANIZATION_ID),
    decode(p1.group_type,'GROUP',NULL,'LOT_LINE',NULL,p1.PROJECT_EXPENDITURE_ITEM_DATE),
    decode(p1.group_type,'GROUP',NULL,'LOT_LINE',NULL,p1.WORK_APPROVER_USER_ID),
    sysdate,
    g_user_id,
    sysdate,
    g_user_id,
    fnd_global.login_id
    from
    pon_item_prices_interface p1,
    pon_auction_headers_all pah
    where
    p1.batch_id = g_batch_id
    and p1.auction_header_id = pah.auction_header_id
    and nvl(p1.action,'+') = g_add_action;

    /*
    The following column will be updated for all the records modified
    HAS_ATTRIBUTES_FLAG,
    HAS_SHIPMENTS_FLAG
    HAS_PRICE_ELEMENTS_FLAG
    HAS_BUYER_PFS_FLAG
    HAS_PRICE_DIFFERENTIALS_FLAG
    HAS_QUANTITY_TIERS

    The procedure PON_NEGOTIATION_PUBLISH_PVT.SET_ITEM_HAS_CHILDREN_FLAGS
    will be used for this. This would be called after lined have been updated
    added or deleted.
    */


    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'ADD_LINES END g_batch_id = '||g_batch_id ||' g_auction_header_id '||g_auction_header_id);
    END IF;

--}
END ADD_LINES;


/*======================================================================
 PROCEDURE:  ADD_PRICE_FACTORS  PRIVATE

 PARAMETERS: NONE

 COMMENT   :  This procedure will add the supplier price factors in
              PON_AUC_PRICE_ELEMENTS_INT corresponding to the new lines
              from the PON_ITEM_PRICES_INTERFACE interface table to the
              PON_PRICE_ELEMENTS transaction tables. The following sql
              will be used for the same. The logic for this is present
              in copyPriceElement method in NegItemSpreadsheetAMImpl.
======================================================================*/
PROCEDURE ADD_PRICE_FACTORS  is

l_module CONSTANT VARCHAR2(17) := 'ADD_PRICE_FACTORS';

BEGIN
--{
    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'ADD_PRICE_FACTORS  START g_batch_id = '||g_batch_id ||' g_auction_header_id '||g_auction_header_id);
    END IF;

    insert into PON_PRICE_ELEMENTS
    fields
    (AUCTION_HEADER_ID,
    LINE_NUMBER,
    SEQUENCE_NUMBER,
    PRICE_ELEMENT_TYPE_ID,
    PRICING_BASIS,
    VALUE,
    DISPLAY_TARGET_FLAG,
    PF_TYPE,
    DISPLAY_TO_SUPPLIERS_FLAG,
    LIST_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY)
    select
    pe_int.AUCTION_HEADER_ID,
    pe_int.AUCTION_LINE_NUMBER,
    sequence_number+10,
    pe_int.PRICE_ELEMENT_TYPE_ID,
    pe_int.pricing_basis,
    pe_int.VALUE,
    pe_int.DISPLAY_TARGET_FLAG,
    pe_int.PF_TYPE,
    pe_int.DISPLAY_TO_SUPPLIERS_FLAG,
    -1,
    sysdate,
    g_user_id,
    sysdate,
    g_user_id
    from
    pon_auc_price_elements_int pe_int,
    pon_item_prices_interface p1
    where
    pe_int.batch_id = g_batch_id
    and p1.batch_id = pe_int.batch_id
    and p1.auction_line_number = pe_int.auction_line_number
    and nvl(p1.action,g_add_action) = g_add_action
    order by sequence_number;

    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'ADD_PRICE_FACTORS END g_batch_id = '||g_batch_id ||' g_auction_header_id '||g_auction_header_id);
    END IF;

--}
END ADD_PRICE_FACTORS ;


/*======================================================================
 PROCEDURE:  ADD_PRICE_DIFFERENTIALS  PRIVATE

 PARAMETERS: NONE

 COMMENT   :  This procedure will add the price differentials corresponding
              to the new lines from the PON_AUC_PRICE_DIFFER_INT interface table
              to the PON_PRICE_DIFFERENTIALS transaction tables.
======================================================================*/
PROCEDURE ADD_PRICE_DIFFERENTIALS  is

l_module CONSTANT VARCHAR2(23) := 'ADD_PRICE_DIFFERENTIALS';

BEGIN
--{
    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'ADD_PRICE_DIFFERENTIALS  START g_batch_id = '||g_batch_id ||' g_auction_header_id '||g_auction_header_id);
    END IF;

    insert into PON_PRICE_DIFFERENTIALS
    fields
    (AUCTION_HEADER_ID,
    LINE_NUMBER,
    SHIPMENT_NUMBER,
    PRICE_DIFFERENTIAL_NUMBER,
    PRICE_TYPE,
    MULTIPLIER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN)
    select
    pdf_int.AUCTION_HEADER_ID,
    pdf_int.AUCTION_LINE_NUMBER,
    -1,
    pdf_int.SEQUENCE_NUMBER,
    pdf_int.PRICE_TYPE,
    pdf_int.MULTIPLIER,
    sysdate,
    g_user_id,
    sysdate,
    g_user_id,
    fnd_global.login_id
    from
    pon_auc_price_differ_int pdf_int,
    pon_item_prices_interface p1
    where
    pdf_int.batch_id = g_batch_id
    and p1.batch_id = pdf_int.batch_id
    and p1.auction_line_number = pdf_int.auction_line_number
    and nvl(p1.action,'+') = g_add_action;


    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'ADD_PRICE_DIFFERENTIALS END g_batch_id = '||g_batch_id ||' g_auction_header_id '||g_auction_header_id);
    END IF;

--}
END ADD_PRICE_DIFFERENTIALS ;


/*======================================================================
 PROCEDURE:  ADD_ATTRIBUTES  PRIVATE

 PARAMETERS: NONE

 COMMENT   :  This procedure will add the attributes corresponding to the new
            lines from the PON_AUC_ATTRIBUTES_INTERFACE interface table to the
            PON_AUCTION_ATTRIBUTES transaction tables. The following sql will
            be used for the same. The logic for this is present in copyAttributes
            method in NegItemSpreadsheetAMImpl.
======================================================================*/
PROCEDURE ADD_ATTRIBUTES  is

l_module CONSTANT VARCHAR2(14) := 'ADD_ATTRIBUTES';

BEGIN
--{
    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'ADD_ATTRIBUTES  START g_batch_id = '||g_batch_id ||' g_auction_header_id '||g_auction_header_id);
    END IF;

    insert into pon_auction_attributes
    fields
    (AUCTION_HEADER_ID,
    LINE_NUMBER,
    SEQUENCE_NUMBER,
    ATTR_GROUP,
    MANDATORY_FLAG,
    DISPLAY_ONLY_FLAG,
    INTERNAL_ATTR_FLAG,
    ATTRIBUTE_NAME,
    DATATYPE,
    DISPLAY_TARGET_FLAG,
    VALUE,
    SCORING_TYPE,
    ATTR_LEVEL,
    ATTR_GROUP_SEQ_NUMBER,
    ATTR_DISP_SEQ_NUMBER,
    ATTRIBUTE_LIST_ID,
    WEIGHT,
    ATTR_MAX_SCORE,
    IP_CATEGORY_ID,
    IP_DESCRIPTOR_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    SECTION_NAME)
    select
    paa_int.AUCTION_HEADER_ID,
    paa_int.AUCTION_LINE_NUMBER,
    paa_int.SEQUENCE_NUMBER,
    nvl(paa_int.GROUP_CODE, g_default_attribute_group),
    decode(paa_int.RESPONSE_TYPE,'REQUIRED','Y','DISPLAY_ONLY', 'N','OPTIONAL', 'N','INTERNAL', 'N'),
    decode(paa_int.RESPONSE_TYPE,'REQUIRED','N','DISPLAY_ONLY', 'Y','OPTIONAL', 'N','INTERNAL', 'N'),
    decode(paa_int.RESPONSE_TYPE,'REQUIRED','N','DISPLAY_ONLY', 'N','OPTIONAL', 'N','INTERNAL', 'Y'),
    paa_int.ATTRIBUTE_NAME,
    paa_int.DATATYPE,
    paa_int.DISPLAY_TARGET_FLAG,
    paa_int.VALUE,
    paa_int.SCORING_TYPE,
    'LINE',
    decode(nvl(paa_int.response_type_name,''),'PON_FROM_TEMPLATE',
                PON_CP_INTRFAC_TO_TRANSACTION.get_attr_group_seq_number(g_batch_id,paa_int.interface_line_id,
                                          nvl(paa_int.GROUP_CODE, g_default_attribute_group),
                                          paa_int.ATTR_GROUP_SEQ_NUMBER),
                paa_int.ATTR_GROUP_SEQ_NUMBER),
    decode(nvl(paa_int.response_type_name,''),'PON_FROM_TEMPLATE',
                PON_CP_INTRFAC_TO_TRANSACTION.get_attr_disp_seq_number(g_batch_id,paa_int.interface_line_id,
                                          nvl(paa_int.GROUP_CODE, g_default_attribute_group),
                                          paa_int.attr_disp_seq_number),
                paa_int.ATTR_DISP_SEQ_NUMBER),
    -1,
    0,
    0,
    paa_int.IP_CATEGORY_ID,
    paa_int.IP_DESCRIPTOR_ID,
    sysdate,
    g_user_id,
    sysdate,
    g_user_id,
    nvl(paa_int.group_name,g_default_section_name)
    from
     pon_auc_attributes_interface paa_int,
     pon_item_prices_interface p1
    where
     paa_int.batch_id= g_batch_id
     and p1.batch_id = paa_int.batch_id
     and p1.auction_line_number = paa_int.auction_line_number
     and nvl(p1.action,'+') = g_add_action;

    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'ADD_ATTRIBUTES END g_batch_id = '||g_batch_id ||' g_auction_header_id '||g_auction_header_id);
    END IF;

--}
END ADD_ATTRIBUTES ;


/*======================================================================
 PROCEDURE:  ADD_ATTRIBUTE_SCORES  PRIVATE

 PARAMETERS: NONE

 COMMENT   :  This procedure will add the attributes scores for the new
              attributes added incase the negotiation was created from
              a template. The following logic is used

              i. Get  all the attributes and the corresponding scores related to
               the template. The following where condition takes care of this

              ii. Get the lines that have the attributes present in the
              template. We only require those attributes that have not been copied
              as part of the spreadsheet. These attributes can be identified using
              the field response_type_name in pon_auc_attributes_interface. The
              value of this field for all the attributes added will be 'PON_FROM_TEMPLATE"
======================================================================*/
PROCEDURE ADD_ATTRIBUTE_SCORES  is

l_module CONSTANT VARCHAR2(20) := 'ADD_ATTRIBUTE_SCORES';

BEGIN
--{
    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'ADD_ATTRIBUTE_SCORES  START g_batch_id = '||g_batch_id ||' g_auction_header_id '||g_auction_header_id);
    END IF;

    insert into pon_attribute_scores
    fields
    (AUCTION_HEADER_ID,
    LINE_NUMBER,
    ATTRIBUTE_SEQUENCE_NUMBER,
    ATTRIBUTE_LIST_ID,
    FROM_RANGE,
    TO_RANGE,
    SCORE,
    VALUE,
    SEQUENCE_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY
    )
    SELECT
     auction_attributes.auction_header_id,
     auction_attributes.line_number,
     auction_attributes.sequence_number,
     -1,
     template_attribute_score.from_range,
     template_attribute_score.to_range,
     template_attribute_score.score,
     template_attribute_score.value,
     template_attribute_score.sequence_number,
     sysdate,
     g_user_id,
     sysdate,
     g_user_id
    FROM
     pon_auction_headers_all pah1,
     pon_auction_headers_all template,
     pon_attribute_scores template_attribute_score,
     pon_auction_attributes template_attribute,
     pon_auction_attributes auction_attributes,
     pon_auc_attributes_interface interface_attributes
    WHERE
    pah1.auction_header_id = g_auction_header_id
    and template.auction_header_id = pah1.template_id
    and template_attribute.auction_header_id = template.auction_header_id
    and template_attribute_score.attribute_sequence_number = template_attribute.sequence_number
    and template_attribute_score.auction_header_id = template_attribute.auction_header_id
    and template_attribute_score.line_number = template_attribute.line_number
    and auction_attributes.auction_header_id = pah1.auction_header_id
    and auction_attributes.attribute_name = template_attribute.attribute_name
    and interface_attributes.batch_id = g_batch_id
    and interface_attributes.auction_header_id = auction_attributes.auction_header_id
    and interface_attributes.auction_line_number = auction_attributes.line_number
    and interface_attributes.attribute_name = auction_attributes.attribute_name
    and interface_attributes.response_type_name = 'PON_FROM_TEMPLATE' ;


    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'ADD_ATTRIBUTE_SCORES END g_batch_id = '||g_batch_id ||' g_auction_header_id '||g_auction_header_id);
    END IF;

--}
END ADD_ATTRIBUTE_SCORES ;


/*======================================================================
 PROCEDURE:  ADD_NEW_LINE_WITH_CHILDREN  PRIVATE

 PARAMETERS: NONE

 COMMENT   :  This procedure will add the copy the new created in the
            spreadsheet lines with their children.
======================================================================*/
PROCEDURE ADD_NEW_LINE_WITH_CHILDREN  is

l_module CONSTANT VARCHAR2(26) := 'ADD_NEW_LINE_WITH_CHILDREN';
l_bid_ranking pon_auction_headers_all.bid_ranking%type;
l_template_id pon_auction_headers_all.template_id%type;

BEGIN
--{
    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'ADD_NEW_LINE_WITH_CHILDREN  START g_batch_id = '||g_batch_id ||' g_auction_header_id '||g_auction_header_id);
    END IF;

    SELECT
    pah.bid_ranking,
    pah.template_id
    INTO
    l_bid_ranking,
    l_template_id
    FROM
    pon_auction_headers_all pah
    WHERE
    pah.auction_header_id  = g_auction_header_id;

    add_lines;

    if(g_price_differentials_flag = 'Y') then

        add_price_differentials ;

    end if;

    if(g_price_element_enabled_flag = 'Y') then

        add_price_factors;

    end if;

    if(g_line_attribute_enabled = 'Y') then

        add_attributes;

        if ( g_attribute_score_enabled_flag = 'Y' and l_template_id is not null) then

            add_attribute_scores;

        END if;

    end if;

    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'ADD_NEW_LINE_WITH_CHILDREN END g_batch_id = '||g_batch_id ||' g_auction_header_id '||g_auction_header_id);
    END IF;

--}
END ADD_NEW_LINE_WITH_CHILDREN ;



/*======================================================================
 PROCEDURE:  UPDATE_LINES  PRIVATE

 PARAMETERS: NONE

 COMMENT   :  This will copy all the lines that are to be updated
======================================================================*/
PROCEDURE UPDATE_LINES  is

l_module CONSTANT VARCHAR2(12) := 'UPDATE_LINES';
l_contract_type           pon_auction_headers_all.contract_type%TYPE;
l_last_amendment_update   pon_auction_headers_all.amendment_number%TYPE;
l_max_internal_line_num   pon_auction_headers_all.max_internal_line_num%TYPE;

l_line_number                    PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_group_type                     PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
l_item_description               PON_NEG_COPY_DATATYPES_GRP.VARCHAR2500_TYPE;
l_category_id                    PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_category_name                  PON_NEG_COPY_DATATYPES_GRP.VARCHAR300_TYPE;
l_ip_category_id                 PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_quantity                       PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_uom_code                       PON_NEG_COPY_DATATYPES_GRP.VARCHAR20_TYPE;
l_unit_of_measure                PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
l_need_by_start_date             PON_NEG_COPY_DATATYPES_GRP.SIMPLE_DATE_TYPE;
l_need_by_date                   PON_NEG_COPY_DATATYPES_GRP.SIMPLE_DATE_TYPE;
l_target_price                   PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_bid_start_price                PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_note_to_bidders                PON_NEG_COPY_DATATYPES_GRP.VARCHAR4000_TYPE;
l_ship_to_location_id            PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_current_price                  PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_reserve_price                  PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_display_target_price_flag      PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
l_po_min_rel_amount              PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_line_type_id                   PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_order_type_lookup_code         PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
l_item_id                        PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_item_number                    PON_NEG_COPY_DATATYPES_GRP.VARCHAR1000_TYPE;
l_item_revision                  PON_NEG_COPY_DATATYPES_GRP.VARCHAR20_TYPE;
l_job_id                         PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_additional_job_details         PON_NEG_COPY_DATATYPES_GRP.VARCHAR2000_TYPE;
l_po_agreed_amount               PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_unit_target_price              PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_unit_display_target_flag       PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
l_differential_response_type     PON_NEG_COPY_DATATYPES_GRP.VARCHAR20_TYPE;
l_purchase_basis                 PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
l_price_disabled_flag            PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
l_quantity_disabled_flag         PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
--R12 - Complex work
l_advance_amount                 PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_recoupment_rate_percent        PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_progress_pymt_rate_percent     PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_retainage_rate_percent         PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_max_retainage_amount           PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_project_id                     PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_project_task_id                PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_project_award_id               PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_project_expenditure_type       PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
l_project_exp_organization_id    PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_project_expenditure_item_dt    PON_NEG_COPY_DATATYPES_GRP.SIMPLE_DATE_TYPE;
l_work_approver_user_id          PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;

BEGIN
--{
    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'UPDATE_LINES  START g_batch_id = '||g_batch_id ||' g_auction_header_id '||g_auction_header_id);
    END IF;

    SELECT
    contract_type,
    nvl(amendment_number,0),
    max_internal_line_num
    INTO
    l_contract_type,
    l_last_amendment_update,
    l_max_internal_line_num
    FROM
    pon_auction_headers_all
    WHERE
    auction_header_id  = g_auction_header_id;

    -- delete category descriptors if ip category has changed

    IF (l_contract_type in ('BLANKET', 'CONTRACT')) THEN

      -- 1) delete scores first

      delete from
      (select *
       from   pon_attribute_scores
       where  auction_header_id = g_auction_header_id and
              line_number in (select paip.line_number
                              from   pon_item_prices_interface p1,
                                     pon_auction_item_prices_all paip
                              where  p1.batch_id = g_batch_id and
                                     p1.auction_header_id = paip.auction_header_id and
                                     p1.auction_line_number = paip.line_number and
                                     paip.ip_category_id is not null and
                                     nvl(p1.ip_category_id, -1) <> nvl(paip.ip_category_id, -1))) pas
       where auction_header_id = g_auction_header_id and
             exists (select null
                     from   pon_auction_attributes paa
                     where  paa.auction_header_id = pas.auction_header_id and
                            paa.line_number =  pas.line_number and
                            paa.sequence_number = pas.attribute_sequence_number and
                            paa.ip_category_id is not null and
                            paa.ip_category_id <> 0);

      -- 2) then delete attributes
      delete from pon_auction_attributes paa
      where  paa.auction_header_id = g_auction_header_id and
             paa.ip_category_id is not null and
             paa.ip_category_id <> 0 and
             paa.line_number in (select paip.line_number
                                 from   pon_item_prices_interface p1,
                                        pon_auction_item_prices_all paip
                                 where  p1.batch_id = g_batch_id and
                                        p1.auction_header_id = paip.auction_header_id and
                                        p1.auction_line_number = paip.line_number and
                                        paip.ip_category_id is not null and
                                        nvl(p1.ip_category_id, -1) <> nvl(paip.ip_category_id, -1));

    END IF;

    SELECT
    p1.AUCTION_LINE_NUMBER,
    p1.GROUP_TYPE,
    p1.ITEM_DESCRIPTION,
    p1.CATEGORY_ID,
    p1.CATEGORY_NAME,
    p1.IP_CATEGORY_ID,
    p1.QUANTITY,
    decode(nvl(p1.PRICE_AND_QUANTITY_APPLY,'Y'),'N','',p1.UOM_CODE),
    decode(nvl(p1.PRICE_AND_QUANTITY_APPLY,'Y'),'N','',p1.UNIT_OF_MEASURE),
    p1.NEED_BY_START_DATE,
    p1.NEED_BY_DATE,
    p1.TARGET_PRICE,
    p1.BID_START_PRICE,
    p1.NOTE_TO_BIDDERS,
    p1.SHIP_TO_LOCATION_ID,
    p1.CURRENT_PRICE,
    p1.RESERVE_PRICE,
    p1.DISPLAY_TARGET_PRICE_FLAG,
    p1.PO_MIN_REL_AMOUNT,
    p1.LINE_TYPE_ID,
    p1.ORDER_TYPE_LOOKUP_CODE,
    p1.ITEM_ID,
    p1.ITEM_NUMBER,
    p1.ITEM_REVISION,
    p1.JOB_ID,
    p1.ADDITIONAL_JOB_DETAILS,
    p1.PO_AGREED_AMOUNT,
    p1.UNIT_TARGET_PRICE,
    p1.UNIT_DISPLAY_TARGET_FLAG,
    decode(p1.DIFFERENTIAL_RESPONSE_TYPE, PON_AUCTION_PKG.getMessage('PON_AUCTS_REQUIRED'),'REQUIRED', PON_AUCTION_PKG.getMessage('PON_AUCTS_OPTIONAL'),'OPTIONAL', PON_AUCTION_PKG.getMessage('PON_AUCTS_DISPLAY_ONLY'),'DISPLAY_ONLY',
    null),
    p1.PURCHASE_BASIS,
    decode(NVL(p1.PRICE_AND_QUANTITY_APPLY,'Y'),'N','Y','N'),
    decode(NVL(p1.PRICE_AND_QUANTITY_APPLY,'Y'),'N','Y','N'),
    --R12 - Complex work
    decode(p1.group_type,'GROUP',NULL,'LOT_LINE',NULL,p1.ADVANCE_AMOUNT),
    decode(p1.group_type,'GROUP',NULL,'LOT_LINE',NULL,p1.RECOUPMENT_RATE_PERCENT),
    decode(p1.group_type,'GROUP',NULL,'LOT_LINE',NULL,p1.PROGRESS_PYMT_RATE_PERCENT),
    decode(p1.group_type,'GROUP',NULL,'LOT_LINE',NULL,p1.RETAINAGE_RATE_PERCENT),
    decode(p1.group_type,'GROUP',NULL,'LOT_LINE',NULL,p1.MAX_RETAINAGE_AMOUNT),
    decode(p1.group_type,'GROUP',NULL,'LOT_LINE',NULL,p1.PROJECT_ID),
    decode(p1.group_type,'GROUP',NULL,'LOT_LINE',NULL,p1.PROJECT_TASK_ID),
    decode(p1.group_type,'GROUP',NULL,'LOT_LINE',NULL,p1.PROJECT_AWARD_ID),
    decode(p1.group_type,'GROUP',NULL,'LOT_LINE',NULL,p1.PROJECT_EXPENDITURE_TYPE),
    decode(p1.group_type,'GROUP',NULL,'LOT_LINE',NULL,p1.PROJECT_EXP_ORGANIZATION_ID),
    decode(p1.group_type,'GROUP',NULL,'LOT_LINE',NULL,p1.PROJECT_EXPENDITURE_ITEM_DATE),
    decode(p1.group_type,'GROUP',NULL,'LOT_LINE',NULL,p1.WORK_APPROVER_USER_ID)
    BULK COLLECT INTO
    l_line_number,
    l_group_type,
    l_item_description,
    l_category_id,
    l_category_name,
    l_ip_category_id,
    l_quantity,
    l_uom_code,
    l_unit_of_measure,
    l_need_by_start_date,
    l_need_by_date,
    l_target_price,
    l_bid_start_price,
    l_note_to_bidders,
    l_ship_to_location_id,
    l_current_price,
    l_reserve_price,
    l_display_target_price_flag,
    l_po_min_rel_amount,
    l_line_type_id,
    l_order_type_lookup_code,
    l_item_id,
    l_item_number,
    l_item_revision,
    l_job_id,
    l_additional_job_details,
    l_po_agreed_amount,
    l_unit_target_price,
    l_unit_display_target_flag,
    l_differential_response_type,
    l_purchase_basis,
    l_price_disabled_flag,
    l_quantity_disabled_flag,
    --R12 - Complex work
    l_advance_amount,
    l_recoupment_rate_percent,
    l_progress_pymt_rate_percent,
    l_retainage_rate_percent,
    l_max_retainage_amount,
    l_project_id,
    l_project_task_id,
    l_project_award_id,
    l_project_expenditure_type,
    l_project_exp_organization_id,
    l_project_expenditure_item_dt,
    l_work_approver_user_id
    from
    pon_item_prices_interface p1
    where
    p1.batch_id = g_batch_id
    and p1.action = g_update_action;

    FORALL x in 1..l_line_number.COUNT
    UPDATE PON_AUCTION_ITEM_PRICES_ALL
    SET
        GROUP_TYPE                      = l_group_type(x),
        ITEM_DESCRIPTION                = l_item_description(x),
        CATEGORY_ID                     = l_category_id(x),
        CATEGORY_NAME                   = l_category_name(x),
        IP_CATEGORY_ID                  = l_ip_category_id(x),
        QUANTITY                        = l_quantity(x),
        UOM_CODE                        = l_uom_code(x),
        UNIT_OF_MEASURE                 = l_unit_of_measure(x),
        NEED_BY_START_DATE              = l_need_by_start_date(x),
        NEED_BY_DATE                    = l_need_by_date(x),
        TARGET_PRICE                    = l_target_price(x),
        BID_START_PRICE                 = l_bid_start_price(x),
        NOTE_TO_BIDDERS                 = l_note_to_bidders(x),
        SHIP_TO_LOCATION_ID             = l_ship_to_location_id(x),
        CURRENT_PRICE                   = l_current_price(x),
        RESERVE_PRICE                   = l_reserve_price(x),
        DISPLAY_TARGET_PRICE_FLAG       = l_display_target_price_flag(x),
        PO_MIN_REL_AMOUNT               = l_po_min_rel_amount(x),
        LINE_TYPE_ID                    = l_line_type_id(x),
        ORDER_TYPE_LOOKUP_CODE          = l_order_type_lookup_code(x),
        ITEM_ID                         = l_item_id(x),
        ITEM_NUMBER                     = l_item_number(x),
        ITEM_REVISION                   = l_item_revision(x),
        JOB_ID                          = l_job_id(x),
        ADDITIONAL_JOB_DETAILS          = l_additional_job_details(x),
        PO_AGREED_AMOUNT                = l_po_agreed_amount(x),
        UNIT_TARGET_PRICE               = l_unit_target_price(x),
        UNIT_DISPLAY_TARGET_FLAG        = l_unit_display_target_flag(x),
        DIFFERENTIAL_RESPONSE_TYPE      = l_differential_response_type(x),
        PURCHASE_BASIS                  = l_purchase_basis(x),
        PRICE_DISABLED_FLAG             = l_price_disabled_flag(x),
        QUANTITY_DISABLED_FLAG          = l_quantity_disabled_flag(x),
        --R12-Complexworkl_--R12 - Complex work
        ADVANCE_AMOUNT                  = l_advance_amount(x),
        RECOUPMENT_RATE_PERCENT         = l_recoupment_rate_percent(x),
        PROGRESS_PYMT_RATE_PERCENT      = l_progress_pymt_rate_percent(x),
        RETAINAGE_RATE_PERCENT          = l_retainage_rate_percent(x),
        MAX_RETAINAGE_AMOUNT            = l_max_retainage_amount(x),
        PROJECT_ID                      = l_project_id(x),
        PROJECT_TASK_ID                 = l_project_task_id(x),
        PROJECT_AWARD_ID                = l_project_award_id(x),
        PROJECT_EXPENDITURE_TYPE        = l_project_expenditure_type(x),
        PROJECT_EXP_ORGANIZATION_ID     = l_project_exp_organization_id(x),
        PROJECT_EXPENDITURE_ITEM_DATE   = l_project_expenditure_item_dt(x),
        WORK_APPROVER_USER_ID           = l_work_approver_user_id(x),
        LAST_UPDATE_DATE                = sysdate,
        LAST_UPDATED_BY                 = g_user_id,
        LAST_UPDATE_LOGIN               = fnd_global.login_id
    WHERE
      AUCTION_HEADER_ID = g_auction_header_id AND
      LINE_NUMBER = l_line_number (x);

      -- identify parent of children that have been updated/ added or modified
      -- or parents that have been updated

      -- Identify any parent from the previous round whose child exists in the
      -- interface table. If a child exists in the interfacetable it indicates
      -- that the child was added , modified or deleted. In all these cases we
      -- need to mark the parent modified.
      SELECT
        DISTINCT INTERFACE.parent_line_number
      BULK COLLECT INTO
        l_line_number
      FROM
        pon_item_prices_interface INTERFACE
      WHERE
        INTERFACE.batch_id = g_batch_id
  	    AND INTERFACE.parent_line_number <= l_max_internal_line_num
			  AND INTERFACE.group_type IN ('LOT_LINE','GROUP_LINE');


      FORALL x in 1..l_line_number.COUNT
        UPDATE PON_AUCTION_ITEM_PRICES_ALL
      SET
        LAST_AMENDMENT_UPDATE = decode(l_last_amendment_update,0,LAST_AMENDMENT_UPDATE,l_last_amendment_update),
        MODIFIED_DATE = sysdate,
        MODIFIED_FLAG = 'Y'
      where
      AUCTION_HEADER_ID = g_auction_header_id AND
      LINE_NUMBER = l_line_number (x);

     -- Not combining this with the above sql for performance reasons
      SELECT
        interface.auction_line_number
      BULK COLLECT INTO
        l_line_number
      FROM
        pon_item_prices_interface INTERFACE
      WHERE
        INTERFACE.batch_id = g_batch_id
  	    AND INTERFACE.auction_line_number <= l_max_internal_line_num;

      FORALL x in 1..l_line_number.COUNT
        UPDATE PON_AUCTION_ITEM_PRICES_ALL
      SET
        LAST_AMENDMENT_UPDATE = decode(l_last_amendment_update,0,LAST_AMENDMENT_UPDATE,l_last_amendment_update),
        MODIFIED_DATE = sysdate,
        MODIFIED_FLAG = 'Y'
      where
      AUCTION_HEADER_ID = g_auction_header_id AND
      LINE_NUMBER = l_line_number (x);


    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'UPDATE_LINES END g_batch_id = '||g_batch_id ||' g_auction_header_id '||g_auction_header_id);
    END IF;

--}
END UPDATE_LINES ;


/*======================================================================
 PROCEDURE:  UPDATE_PRICE_DIFFERNTIALS  PRIVATE

 PARAMETERS: NONE

 COMMENT   :  This will perform the following actions for price differntials
            for lines that have updated by the spread sheet.
            i.	Delete existing price differentials for updated lines
            ii.	Add price differentials from the spreadsheet.
======================================================================*/
PROCEDURE UPDATE_PRICE_DIFFERNTIALS  is

l_module CONSTANT VARCHAR2(25) := 'UPDATE_PRICE_DIFFERNTIALS';

BEGIN
--{
    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'UPDATE_PRICE_DIFFERNTIALS  START g_batch_id = '||g_batch_id ||' g_auction_header_id '||g_auction_header_id);
    END IF;

    -- Delete existing price differentials for updated lines
    delete from PON_PRICE_DIFFERENTIALS price_differentials
    where
    auction_header_id = g_auction_header_id
    and
    LINE_NUMBER =
    (select
    LINE_NUMBER
    from
     pon_item_prices_interface paip_int
     where
     paip_int.batch_id = g_batch_id
     and price_differentials.line_number = paip_int.auction_line_number
     and paip_int.action = g_update_action);

    -- Add price differentials from the spreadsheet.
    insert into pon_price_differentials
    fields
    (auction_header_id,
    line_number,
    shipment_number,
    price_differential_number,
    price_type,
    multiplier,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login
    )
    select
    price_diff_int.auction_header_id,
    price_diff_int.auction_line_number,
    -1,
    price_diff_int.sequence_number,
    price_diff_int.price_type,
    price_diff_int.multiplier,
    sysdate,
    g_user_id,
    sysdate,
    g_user_id,
    fnd_global.login_id
    FROM
     pon_item_prices_interface paip_int,
     pon_auc_price_differ_int price_diff_int
    WHERE
     paip_int.batch_id = g_batch_id
     and price_diff_int.batch_id = paip_int.batch_id
     and price_diff_int.auction_line_number = paip_int.auction_line_number
     and paip_int.action = g_update_action;



    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'UPDATE_PRICE_DIFFERNTIALS END g_batch_id = '||g_batch_id ||' g_auction_header_id '||g_auction_header_id);
    END IF;

--}
END UPDATE_PRICE_DIFFERNTIALS ;


/*======================================================================
 PROCEDURE:  UPDATE_PRICE_FACTORS  PRIVATE

 PARAMETERS: NONE

 COMMENT   :  This will perform the following actions for price differntials
            for lines that have updated by the spread sheet.
            i.	Delete supplier price factors from auction tables that are
                not in interface tables
            ii.	Update Price Elements that exist in the spreadsheet and the lines
            iii.Insert price Elements that do not exist in the PON_PRICE_ELEMENTS
                but are present in the spreadsheet.
======================================================================*/
PROCEDURE UPDATE_PRICE_FACTORS  is

l_module CONSTANT VARCHAR2(20) := 'UPDATE_PRICE_FACTORS';

l_line_number                    PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_price_element_type_id          PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_pricing_basis                  PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
l_value                          PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_display_target_flag            PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
l_display_to_suppliers_flag      VARCHAR2(1) := 'Y';
BEGIN
--{
    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'UPDATE_PRICE_FACTORS  START g_batch_id = '||g_batch_id ||' g_auction_header_id '||g_auction_header_id);
    END IF;

    -- Delete supplier price factors from auction tables that are
    -- not in interface tables
    delete from PON_PRICE_ELEMENTS pe
    where
    pe.auction_header_id = g_auction_header_id
    and pe.pf_type = 'SUPPLIER'
    and exists (select
        1
    from
     PON_ITEM_PRICES_INTERFACE line_interface
    where
     line_interface.action = g_update_action
     and line_interface.batch_id = g_batch_id
     and line_interface.auction_header_id = pe.auction_header_id
     and line_interface.auction_line_number = pe.line_number)
    and not exists
    (select 1
    from
     PON_ITEM_PRICES_INTERFACE paip_int,
     PON_AUC_PRICE_ELEMENTS_INT pe_int
     where
     paip_int.action = g_update_action
     and paip_int.batch_id = g_batch_id
     and paip_int.batch_id = pe_int.batch_id
     and paip_int.auction_line_number = pe_int.auction_line_number
     and paip_int.auction_header_id = pe_int.auction_header_id
     and pe_int.auction_header_id = pe.auction_header_id
     and pe_int.auction_line_number = pe.line_number
     and pe_int.price_element_type_id = pe.price_element_type_id
     and pe_int.PF_TYPE = 'SUPPLIER');

    --Update Price Elements that exist in the spreadsheet and the lines
    select
     pe_int.AUCTION_LINE_NUMBER,
     pe_int.PRICE_ELEMENT_TYPE_ID,
     pe_int.PRICING_BASIS,
     pe_int.VALUE,
     decode(g_is_amendment,'N',pe_int.DISPLAY_TARGET_FLAG,
                               decode(greatest(pe_int.AUCTION_LINE_NUMBER,g_max_prev_line_num_plus_one),
                                      pe_int.AUCTION_LINE_NUMBER,pe_int.DISPLAY_TARGET_FLAG,'X'))
     BULK COLLECT INTO
     l_line_number,
     l_price_element_type_id,
     l_pricing_basis,
     l_value,
     l_display_target_flag
     from
     PON_AUC_PRICE_ELEMENTS_INT pe_int,
     PON_ITEM_PRICES_INTERFACE paip_int
     where
     paip_int.action = g_update_action
     and paip_int.batch_id = g_batch_id
     and paip_int.batch_id = pe_int.batch_id
     and paip_int.auction_line_number = pe_int.auction_line_number
     and paip_int.auction_header_id = pe_int.auction_header_id
     and pe_int.PF_TYPE = 'SUPPLIER';

    FORALL x in 1..l_line_number.COUNT
    UPDATE PON_PRICE_ELEMENTS
    SET
     PRICING_BASIS        = l_pricing_basis(x),
     VALUE                = l_value(x),
     DISPLAY_TARGET_FLAG  = decode(l_display_target_flag(x),'X',DISPLAY_TARGET_FLAG,l_display_target_flag(x))
    WHERE
      AUCTION_HEADER_ID = g_auction_header_id
      and LINE_NUMBER = l_line_number (x)
      and PRICE_ELEMENT_TYPE_ID = l_price_element_type_id(x);


     --Insert price Elements that do not exist in the PON_PRICE_ELEMENTS
     --but are present in the spreadsheet.

    insert into PON_PRICE_ELEMENTS
    fields
    (AUCTION_HEADER_ID,
    LINE_NUMBER,
    SEQUENCE_NUMBER,
    PRICE_ELEMENT_TYPE_ID,
    PRICING_BASIS,
    VALUE,
    DISPLAY_TARGET_FLAG,
    PF_TYPE,
    DISPLAY_TO_SUPPLIERS_FLAG,
    LIST_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY)
    select
    pe_int.AUCTION_HEADER_ID,
    pe_int.AUCTION_LINE_NUMBER,
    PON_CP_INTRFAC_TO_TRANSACTION.get_next_pe_sequence_number(pe_int.auction_header_id,pe_int.AUCTION_LINE_NUMBER),
    pe_int.PRICE_ELEMENT_TYPE_ID,
    pe_int.PRICING_BASIS,
    pe_int.VALUE,
    pe_int.DISPLAY_TARGET_FLAG,
    pe_int.PF_TYPE,
    pe_int.DISPLAY_TO_SUPPLIERS_FLAG,
    -1,
    sysdate,
    g_user_id,
    sysdate,
    g_user_id
    from
    pon_auc_price_elements_int pe_int,
    pon_item_prices_interface paip_int
    where
    paip_int.action = g_update_action
    and paip_int.batch_id = g_batch_id
    and pe_int.batch_id = paip_int.batch_id
    and paip_int. auction_line_number = pe_int.auction_line_number
    and pe_int.price_element_type_id not in
    (select
      pe1.price_element_type_id
      from
      PON_PRICE_ELEMENTS pe1
      where
      pe_int.auction_header_id = pe1.auction_header_id
      and pe_int.auction_line_number = pe1.line_number
      and pe_int.price_element_type_id = pe1.price_element_type_id)
    order by pe_int.sequence_number;

    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'UPDATE_PRICE_FACTORS END g_batch_id = '||g_batch_id ||' g_auction_header_id '||g_auction_header_id);
    END IF;

--}
END UPDATE_PRICE_FACTORS ;


/*======================================================================
 PROCEDURE:  UPDATE_LINE_ATTRIBUTES  PRIVATE

 PARAMETERS: NONE

 COMMENT   :  The following logic is used for attributes for lines that are
              updated by the spreadsheet.
            i.	Remove Attributes and their scores for attributes that are
                not present in the interface tables.
            ii.	If the attribute name exists previously
                a.	Clear Scores if the attribute data type has changed
                b.	Update attributes that have been updated.
            iii.	Insert Attributes that do not exist.
======================================================================*/
PROCEDURE UPDATE_LINE_ATTRIBUTES  is

l_module CONSTANT VARCHAR2(22) := 'UPDATE_LINE_ATTRIBUTES';
l_bid_ranking pon_auction_headers_all.bid_ranking%type;
l_max_neg_line_attr_seq_num number;
l_attribute_seq_number  PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_attribute_name        PON_NEG_COPY_DATATYPES_GRP.VARCHAR4000_TYPE;
l_line_number           PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_attr_group            PON_NEG_COPY_DATATYPES_GRP.VARCHAR300_TYPE;
l_mandatory_flag        PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
l_display_only_flag     PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
l_internal_attr_flag    PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
l_datatype              PON_NEG_COPY_DATATYPES_GRP.VARCHAR20_TYPE;
l_display_target_flag   PON_NEG_COPY_DATATYPES_GRP.VARCHAR1_TYPE;
l_value                 PON_NEG_COPY_DATATYPES_GRP.VARCHAR4000_TYPE;
l_scoring_type          PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
l_attr_level            PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
l_attr_group_seq_number PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_attr_disp_seq_number  PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;


BEGIN
--{
    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'UPDATE_LINE_ATTRIBUTES  START g_batch_id = '||g_batch_id ||' g_auction_header_id '||g_auction_header_id);
    END IF;


    SELECT
    pah.bid_ranking
    INTO
    l_bid_ranking
    FROM
    pon_auction_headers_all pah
    WHERE
    pah.auction_header_id  = g_auction_header_id;

    if ( g_attribute_score_enabled_flag = 'Y' ) then

        -- The sql below clears data from the scores table for
        --     Attributes that have been deleted
        --     Attribute data type of an existing attribute has changed
        select
        sequence_number,
        line_number
        bulk collect into
        l_attribute_seq_number,
        l_line_number
        from
        pon_auction_attributes auction_attributes,
        pon_item_prices_interface line_interface
        where
        line_interface.action = g_update_action
        and line_interface.batch_id = g_batch_id
        and line_interface.auction_header_id = g_auction_header_id
        and auction_attributes.auction_header_id =  line_interface.auction_header_id
        and auction_attributes.line_number = line_interface.auction_line_number
        and not exists
        (select
          1
        from
          pon_auc_attributes_interface interface_attributes
        where
        line_interface.batch_id = interface_attributes.batch_id
        and line_interface.auction_line_number = interface_attributes.auction_line_number
        and interface_attributes.auction_header_id = auction_attributes.auction_header_id
        and interface_attributes.attribute_name = auction_attributes.attribute_name
        and interface_attributes.datatype = auction_attributes.datatype);


        FORALL x in 1..l_line_number.COUNT
        delete from pon_attribute_scores attribute_scores
        where
        attribute_scores.auction_header_id = g_auction_header_id
        and attribute_scores.line_number = l_line_number(x)
        and attribute_scores.attribute_sequence_number = l_attribute_seq_number(x);


    end if ;

    -- The sql below clears data from the attributes table for attributes that have been deleted
    select
    attribute_name,
    line_number
    bulk collect into
    l_attribute_name,
    l_line_number
    from
    pon_auction_attributes auction_attributes,
    pon_item_prices_interface line_interface
    where
    line_interface.action = g_update_action
    and line_interface.batch_id = g_batch_id
    and line_interface.auction_header_id = g_auction_header_id
    and auction_attributes.auction_header_id =  line_interface.auction_header_id
    and auction_attributes.line_number = line_interface.auction_line_number
    and not exists
    (select
      1
    from
      pon_auc_attributes_interface interface_attributes
    where
    line_interface.batch_id = interface_attributes.batch_id
    and line_interface.auction_line_number = interface_attributes.auction_line_number
    and interface_attributes.auction_header_id = auction_attributes.auction_header_id
    and interface_attributes.attribute_name = auction_attributes.attribute_name);

    FORALL x in 1..l_line_number.COUNT
    delete from pon_auction_attributes auction_attributes
    where
    auction_attributes.auction_header_id = g_auction_header_id
    and auction_attributes.line_number = l_line_number(x)
    and auction_attributes.attribute_name = l_attribute_name(x);

    --	Update attributes that have been updated.
    select
    interface_attributes.auction_line_number,
    interface_attributes.attribute_name,
    nvl(interface_attributes.GROUP_CODE, g_default_attribute_group),
    decode(interface_attributes.RESPONSE_TYPE,'REQUIRED','Y','DISPLAY_ONLY', 'N','OPTIONAL', 'N','INTERNAL', 'N'),
    decode(interface_attributes.RESPONSE_TYPE,'REQUIRED','N','DISPLAY_ONLY', 'Y','OPTIONAL', 'N','INTERNAL', 'N'),
    decode(interface_attributes.RESPONSE_TYPE,'REQUIRED','N','DISPLAY_ONLY', 'N','OPTIONAL', 'N','INTERNAL', 'Y'),
    interface_attributes.DATATYPE,
    decode(g_is_amendment,'N',interface_attributes.DISPLAY_TARGET_FLAG,
                             decode(greatest(line_interface.AUCTION_LINE_NUMBER,g_max_prev_line_num_plus_one),
                                    line_interface.AUCTION_LINE_NUMBER,interface_attributes.DISPLAY_TARGET_FLAG,'X')),
    interface_attributes.VALUE,
    interface_attributes.SCORING_TYPE,
    'LINE',
    interface_attributes.ATTR_GROUP_SEQ_NUMBER,
    interface_attributes.ATTR_DISP_SEQ_NUMBER
    bulk collect into
    l_line_number,
    l_attribute_name,
    l_attr_group,
    l_mandatory_flag,
    l_display_only_flag,
    l_internal_attr_flag,
    l_datatype,
    l_display_target_flag,
    l_value,
    l_scoring_type,
    l_attr_level,
    l_attr_group_seq_number,
    l_attr_disp_seq_number
    from
     pon_item_prices_interface line_interface,
     pon_auc_attributes_interface interface_attributes,
     pon_auction_attributes auction_attributes
    where
    interface_attributes.batch_id = g_batch_id
    and interface_attributes.auction_header_id = auction_attributes.auction_header_id
    and interface_attributes.auction_line_number = auction_attributes.line_number
    and interface_attributes.attribute_name = auction_attributes.attribute_name
    and line_interface.auction_line_number = interface_attributes.auction_line_number
    and line_interface.batch_id = interface_attributes.batch_id
    and line_interface.action = g_update_action;

    FORALL x in 1..l_line_number.COUNT
    update pon_auction_attributes auction_attributes
    set
    attr_group             =   l_attr_group(x),
    mandatory_flag         =   l_mandatory_flag(x),
    display_only_flag      =   l_display_only_flag(x),
    internal_attr_flag     =   l_internal_attr_flag(x),
    datatype               =   l_datatype(x),
    display_target_flag    =   decode(l_display_target_flag(x),'X',display_target_flag,l_display_target_flag(x)),
    value                  =   l_value(x),
    scoring_type           =   l_scoring_type(x),
    attr_level             =   l_attr_level(x),
    attr_group_seq_number  =   l_attr_group_seq_number(x),
    attr_disp_seq_number   =   l_attr_disp_seq_number(x),
    last_update_date       =   sysdate,
    last_updated_by        =   g_user_id
    where
    auction_attributes.auction_header_id = g_auction_header_id
    and auction_attributes.line_number = l_line_number(x)
    and auction_attributes.attribute_name = l_attribute_name(x);


    -- Insert Attributes that do not exist.
    SELECT nvl(max(SEQUENCE_NUMBER),10)
    into
    l_max_neg_line_attr_seq_num
    FROM
    pon_auction_attributes
    WHERE
    AUCTION_HEADER_ID = g_auction_header_id;

    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'UPDATE_LINE_ATTRIBUTES END g_batch_id = '||g_batch_id ||
                                ' g_auction_header_id '||g_auction_header_id ||
                                ' l_max_neg_line_attr_seq_num = '||l_max_neg_line_attr_seq_num);
    END IF;

    insert into pon_auction_attributes
    fields
    (AUCTION_HEADER_ID,
    LINE_NUMBER,
    SEQUENCE_NUMBER,
    ATTR_GROUP,
    MANDATORY_FLAG,
    DISPLAY_ONLY_FLAG,
    INTERNAL_ATTR_FLAG,
    ATTRIBUTE_NAME,
    DATATYPE,
    DISPLAY_TARGET_FLAG,
    VALUE,
    SCORING_TYPE,
    ATTR_LEVEL,
    ATTR_GROUP_SEQ_NUMBER,
    ATTR_DISP_SEQ_NUMBER,
    ATTRIBUTE_LIST_ID,
    WEIGHT,
    ATTR_MAX_SCORE,
    IP_CATEGORY_ID,
    IP_DESCRIPTOR_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY)
    select
    paa_int.AUCTION_HEADER_ID,
    paa_int.AUCTION_LINE_NUMBER,
    l_max_neg_line_attr_seq_num + (rownum*10),
    nvl(paa_int.GROUP_CODE, g_default_attribute_group),
    decode(paa_int.RESPONSE_TYPE,'REQUIRED','Y','DISPLAY_ONLY', 'N','OPTIONAL', 'N','INTERNAL', 'N'),
    decode(paa_int.RESPONSE_TYPE,'REQUIRED','N','DISPLAY_ONLY', 'Y','OPTIONAL', 'N','INTERNAL', 'N'),
    decode(paa_int.RESPONSE_TYPE,'REQUIRED','N','DISPLAY_ONLY', 'N','OPTIONAL', 'N','INTERNAL', 'Y'),
    paa_int.ATTRIBUTE_NAME,
    paa_int.DATATYPE,
    paa_int.DISPLAY_TARGET_FLAG,
    paa_int.VALUE,
    paa_int.SCORING_TYPE,
    'LINE',
    paa_int.ATTR_GROUP_SEQ_NUMBER,
    paa_int.ATTR_DISP_SEQ_NUMBER,
    -1,
    0,
    0,
    paa_int.IP_CATEGORY_ID,
    paa_int.IP_DESCRIPTOR_ID,
    sysdate,
    g_user_id,
    sysdate,
    g_user_id
    from
     pon_auc_attributes_interface paa_int,
     pon_item_prices_interface p1
    where
     paa_int.batch_id= g_batch_id
     and p1.batch_id = paa_int.batch_id
     and p1.action = g_update_action
     and paa_int.auction_line_number = p1.auction_line_number
    and not exists (select 'x'
    from
        pon_auction_attributes auction_attributes
    where
        paa_int.auction_header_id = auction_attributes.auction_header_id
        and paa_int.auction_line_number = auction_attributes.line_number
        and paa_int.attribute_name = auction_attributes.attribute_name)
    order by paa_int.auction_line_number,paa_int.sequence_number;

    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'UPDATE_LINE_ATTRIBUTES END g_batch_id = '||g_batch_id ||' g_auction_header_id '||g_auction_header_id);
    END IF;

--}
END UPDATE_LINE_ATTRIBUTES ;



/*======================================================================
 PROCEDURE:  UPDATE_LINES_WITH_CHILDREN  PRIVATE

 PARAMETERS: NONE

 COMMENT   :  This procedure will add the update lines and their children
            for lines that are marked as updated in the interface tables.
======================================================================*/
PROCEDURE UPDATE_LINES_WITH_CHILDREN  is

l_module CONSTANT VARCHAR2(26) := 'UPDATE_LINES_WITH_CHILDREN';

BEGIN
--{
    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'UPDATE_LINES_WITH_CHILDREN  START g_batch_id = '||g_batch_id ||' g_auction_header_id '||g_auction_header_id);
    END IF;

    UPDATE_LINES;

    if(g_price_differentials_flag = 'Y') then

      UPDATE_PRICE_DIFFERNTIALS;

    end if;

    if(g_price_element_enabled_flag = 'Y') then

        UPDATE_PRICE_FACTORS;

    end if;

    if(g_line_attribute_enabled = 'Y') then

        UPDATE_LINE_ATTRIBUTES;

    end if;

    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'UPDATE_LINES_WITH_CHILDREN END g_batch_id = '||g_batch_id ||' g_auction_header_id '||g_auction_header_id);
    END IF;

--}
END UPDATE_LINES_WITH_CHILDREN ;


/*======================================================================
 PROCEDURE:  SYNCH_FROM_INTERFACE  PUBLIC

 PARAMETERS:

 COMMENT   : This procedure will synch up the large neg pf values table
             for the items uploaded.
======================================================================*/
PROCEDURE SYNCH_PF_VALUES_FOR_UPLOAD is

l_module CONSTANT VARCHAR2(27) := 'SYNCH_PF_VALUES_FOR_UPLOAD';

l_PRICE_ELEMENT_TYPE_ID    PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_PRICING_BASIS            PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;

begin
--{

    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'SYNCH_PF_VALUES_FOR_UPLOAD  START g_batch_id = '||g_batch_id ||' g_auction_header_id '||g_auction_header_id);
    END IF;

    -- Get distinct price factor and pricing basis by scanning the pon_price_elements
    -- once. Scanning pon_price_elements might be huge for large auctions.
    SELECT distinct
     PRICE_ELEMENT_TYPE_ID,
     PRICING_BASIS
    BULK COLLECT INTO
     l_PRICE_ELEMENT_TYPE_ID,
     l_PRICING_BASIS
    FROM
     pon_price_elements
    WHERE
     auction_header_id = g_auction_header_id
     and PF_TYPE = 'BUYER';

    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'SYNCH_PF_VALUES_FOR_UPLOAD  START g_batch_id = '||g_batch_id ||' g_auction_header_id '||g_auction_header_id|| ' : Got Pf Values');
    END IF;

    -- Delete values that do not exist
    FORALL x IN 1..l_PRICE_ELEMENT_TYPE_ID.COUNT
    DELETE
    FROM PON_LARGE_NEG_PF_VALUES
    WHERE
    auction_header_id = g_auction_header_id
    and PRICE_ELEMENT_TYPE_ID <> l_PRICE_ELEMENT_TYPE_ID(x)
    and PRICING_BASIS <> l_PRICING_BASIS(x);

    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'SYNCH_PF_VALUES_FOR_UPLOAD  START g_batch_id = '||g_batch_id ||' g_auction_header_id '||g_auction_header_id|| ' : Deleted unused Pf Values');
    END IF;

    -- Insert new values
    FORALL x IN 1..l_PRICE_ELEMENT_TYPE_ID.COUNT
    insert into
    PON_LARGE_NEG_PF_VALUES
    (auction_header_id,
    price_element_type_id,
    pricing_basis,
    supplier_seq_number,
    value,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login)
    select
    g_auction_header_id,
    l_PRICE_ELEMENT_TYPE_ID(x),
    l_PRICING_BASIS(x),
    PBP.sequence,
    null,
    sysdate,
    g_user_id,
    sysdate,
    g_user_id,
    fnd_global.login_id
    from
    PON_BIDDING_PARTIES PBP
    where
    PBP.auction_header_id = g_auction_header_id and
    not exists (
    select 1
    from
    PON_LARGE_NEG_PF_VALUES pf_values
    where pf_values.auction_header_id = PBP.auction_header_id
    and pf_values.supplier_seq_number = PBP.sequence
    and pf_values.price_element_type_id = l_PRICE_ELEMENT_TYPE_ID(x)
    and pf_values.pricing_basis = l_PRICING_BASIS(x));

    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'SYNCH_PF_VALUES_FOR_UPLOAD END g_batch_id = '||g_batch_id ||' g_auction_header_id '||g_auction_header_id);
    END IF;

--}
END SYNCH_PF_VALUES_FOR_UPLOAD;



/*======================================================================
 PROCEDURE:  SYNCH_FROM_INTERFACE  PUBLIC

 PARAMETERS:
  IN : p_batch_id            NUMBER batch id for which the data needs to be
                                    copied, deleted or added from the interface
                                    tables in the transaction tables.

  IN : p_auction_header_id   NUMBER  auction header id for which the data needs
                                     to be copied, deleted or added from the interface
                                     tables in the transaction tables.

  IN : p_user_id             NUMBER  User id of the person who uploaded the spreadsheet
                                    This will be used to update the standard who columns.
                                    We will not use the fnd_global.user_id as this will also
                                    be called from the concurrent program.

  IN : p_party_id            NUMBER  party id of the person who uploaded the spreadsheet.

 COMMENT   :    This procedure will update/add or the lines and their children
                based on the records in the transaction tables for the batch id
                and auction header id passed as a parameter to the procedure.
                This will also set the global variables g_batch_id and
                g_auction_header_id.
                This will also  re-number all the lines and set flags in
                pon_auction_item_prices_all.
======================================================================*/
PROCEDURE SYNCH_FROM_INTERFACE(
    p_batch_id              IN NUMBER,
    p_auction_header_id     IN NUMBER,
    p_user_id               IN NUMBER,
    p_party_id              IN NUMBER,
    p_commit                IN VARCHAR2,
    x_number_of_lines       OUT NOCOPY NUMBER,
    x_max_disp_line         OUT NOCOPY NUMBER,
    x_last_line_close_date  OUT NOCOPY DATE,
    x_result                OUT NOCOPY VARCHAR2, -- S: Success, F: failure
    x_error_code            OUT NOCOPY VARCHAR2,
    x_error_message         OUT NOCOPY VARCHAR2
)is

CURSOR l_attachment_cursor
IS
  SELECT paip.attachment_desc,
         paip.attachment_url,
         paip.auction_line_number
  FROM   pon_item_prices_interface paip
  WHERE  paip.auction_header_id = g_auction_header_id
  AND    nvl(paip.action,g_add_action) <> g_delete_action
  AND    paip.attachment_url IS NOT NULL
  AND    paip.attachment_desc IS NOT NULL;

l_module CONSTANT VARCHAR2(32) := 'SYNCH_FROM_INTERFACE';
l_number_of_lines       pon_auction_headers_all.number_of_lines%TYPE;
l_max_display_number    pon_auction_headers_all.last_line_number%TYPE;
l_progress              varchar2(200);

-- for attachments
l_sequence              NUMBER :=0;

l_line_attribute_enabled_flag      pon_auction_headers_all.line_attribute_enabled_flag%TYPE;
l_contract_type                    pon_auction_headers_all.contract_type%TYPE;
l_internal_name                    pon_auc_doctypes.internal_name%TYPE;
l_is_global_agreement              pon_auction_headers_all.global_agreement_flag%TYPE;
l_price_element_enabled_flag       pon_auction_headers_all.price_element_enabled_flag%TYPE;
l_pf_type_allowed                  pon_auction_headers_all.pf_type_allowed%TYPE;
l_bid_ranking                      pon_auction_headers_all.bid_ranking%type;
l_auction_round_number             pon_auction_headers_all.auction_round_number%type;
l_amendment_number                 pon_auction_headers_all.amendment_number%type;
l_large_neg_enabled_flag           pon_auction_headers_all.large_neg_enabled_flag%type;
l_template_id                      pon_auction_headers_all.template_id%type;
l_supplier_view_type               pon_auction_headers_all.supplier_view_type%type;
l_full_quantity_bid_code           pon_auction_headers_all.full_quantity_bid_code%type;
l_max_internal_line_num            pon_auction_headers_all.max_internal_line_num%type;
l_first_line_close_date            pon_auction_headers_all.first_line_close_date%TYPE;
l_staggered_closing_interval       pon_auction_headers_all.staggered_closing_interval%TYPE;

BEGIN
--{
    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'SYNCH_FROM_INTERFACE  START g_batch_id = '||g_batch_id ||' g_auction_header_id '||g_auction_header_id);
    END IF;

	-- Update Global variables
    g_batch_id := p_batch_id;
    g_auction_header_id := p_auction_header_id;
    g_user_id := p_user_id;
    INITIALIZE_LINE_ATTR_GROUP(p_party_id);

    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        l_progress := 'INITIALIZE_LINE_ATTR_GROUP completed for p_auction_header_id = '||p_auction_header_id;
    END if;

    select
    NVL(pah.line_attribute_enabled_flag,'Y'),
    pah.contract_type,
    doctypes.internal_name,
    NVL(pah.global_agreement_flag,'N'),
    nvl (pah.price_element_enabled_flag, 'Y'),
    pah.pf_type_allowed,
    bid_ranking,
    nvl(auction_round_number,0),
    nvl(amendment_number,0),
    large_neg_enabled_flag,
    nvl(template_id,0),
    supplier_view_type,
    full_quantity_bid_code,
    nvl(max_internal_line_num,0),
    first_line_close_date,
    staggered_closing_interval
    into
    l_line_attribute_enabled_flag,
    l_contract_type,
    l_internal_name,
    l_is_global_agreement,
    l_price_element_enabled_flag,
    l_pf_type_allowed,
    l_bid_ranking,
    l_auction_round_number,
    l_amendment_number,
    l_large_neg_enabled_flag,
    l_template_id,
    l_supplier_view_type,
    l_full_quantity_bid_code,
    l_max_internal_line_num,
    l_first_line_close_date,
    l_staggered_closing_interval
    from
    pon_auction_headers_all pah,
    pon_auc_doctypes doctypes
    where
    auction_header_id = p_auction_header_id
    and doctypes.doctype_id = pah.doctype_id;


    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'SYNCH_FROM_INTERFACE  START g_batch_id = '||g_batch_id ||' g_auction_header_id '||g_auction_header_id ||
                      ' l_line_attribute_enabled_flag = '|| l_line_attribute_enabled_flag ||
                      ' l_contract_type = '|| l_contract_type ||
                      ' l_internal_name = '|| l_internal_name ||
                      ' l_is_global_agreement = '|| l_is_global_agreement ||
                      ' l_pf_type_allowed = '|| l_pf_type_allowed ||
                      ' l_bid_ranking = '|| l_bid_ranking ||
                      ' l_auction_round_number = '|| l_auction_round_number ||
                      ' l_amendment_number = '|| l_amendment_number ||
                      ' l_large_neg_enabled_flag = '|| l_large_neg_enabled_flag ||
                      ' l_template_id = '|| l_template_id ||
                      ' l_supplier_view_type = '|| l_supplier_view_type ||
                      ' l_full_quantity_bid_code = '|| l_full_quantity_bid_code ||
                      ' l_max_internal_line_num = '|| l_max_internal_line_num);
    END if;

    g_line_attribute_enabled := 'N';
    g_price_differentials_flag  := 'N';
    g_price_element_enabled_flag := 'N';
    g_attribute_score_enabled_flag := 'N';
    g_is_amendment := 'N';
    g_max_prev_line_num_plus_one := l_max_internal_line_num + 1;


    -- Determine if Line Attribute and Scores are applicable for this negotiation
    IF (l_line_attribute_enabled_flag = 'Y') THEN

        g_line_attribute_enabled := 'Y';

        IF (l_bid_ranking = 'MULTI_ATTRIBUTE_SCORING') THEN
           g_attribute_score_enabled_flag := 'Y';
        END IF;

    END if;

    -- Determine if Price Differentials are applicable for this negotiation
    IF ((l_internal_name = 'REQUEST_FOR_INFORMATION' OR
         l_is_global_agreement = 'Y')) --AND NVL (l_price_differentials_flag, 'Y') = 'Y')
        THEN

        g_price_differentials_flag  := 'Y';

    END IF;

    -- Determine if Price Elements/Factors are applicable for this negotiation
    IF (NVL (l_pf_type_allowed, 'NONE') <> 'NONE' AND
        l_price_element_enabled_flag = 'Y') THEN

        g_price_element_enabled_flag := 'Y';

    END IF;

    IF (l_amendment_number > 0) THEN
       g_is_amendment := 'Y';
    END IF;


    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'SYNCH_FROM_INTERFACE  g_batch_id = '||g_batch_id ||' g_auction_header_id '||g_auction_header_id ||
                      ' g_line_attribute_enabled = '|| g_line_attribute_enabled ||
                      ' g_attribute_score_enabled_flag = '|| g_attribute_score_enabled_flag ||
                      ' g_price_differentials_flag = '|| g_price_differentials_flag ||
                      ' g_price_element_enabled_flag = '|| g_price_element_enabled_flag );
    END if;

    -- Delete update and add lines with their children based on the
    -- transaction table data.
    IF (l_auction_round_number > 0 or l_amendment_number > 0) THEN
      delete_lines_with_children;
      update_lines_with_children;
    END IF;

    add_new_line_with_children;

    --create URL Attachments

    FOR l_attachment_record IN l_attachment_cursor LOOP

       PON_OA_UTIL_PKG.create_url_attachment(
        p_seq_num                 => l_sequence,
        p_category_name           => 'Vendor',
        p_document_description    => l_attachment_record.attachment_desc,
        p_datatype_id             => 5,
        p_url                     => l_attachment_record.attachment_url,
        p_entity_name             => 'PON_AUCTION_ITEM_PRICES_ALL',
        p_pk1_value               => g_auction_header_id,
        p_pk2_value               => l_attachment_record.auction_line_number,
        p_pk3_value               => NULL,
        p_pk4_value               => NULL,
        p_pk5_value               => NULL);
    END LOOP;

    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        l_progress := 'Data copied for p_auction_header_id = '||p_auction_header_id;
    END if;

    /* Set the following fields for all records in pon_auction_item_prices all
        HAS_ATTRIBUTES_FLAG,
        HAS_SHIPMENTS_FLAG
        HAS_PRICE_ELEMENTS_FLAG
        HAS_BUYER_PFS_FLAG
        HAS_PRICE_DIFFERENTIALS_FLAG
        HAS_QUANTITY_TIERS
    */
    PON_NEGOTIATION_PUBLISH_PVT.SET_ITEM_HAS_CHILDREN_FLAGS
                                (p_auction_header_id => p_auction_header_id,
                                p_close_bidding_date => null);

    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        l_progress := 'PON_NEGOTIATION_PUBLISH_PVT.SET_ITEM_HAS_CHILDREN_FLAGS p_auction_header_id = '||p_auction_header_id;
    END if;

    /*
     * In case of staggered auctions we need to set the close date on all the lines.
     * Before a negotiation is published the only way to determine if the
     * auction is staggered or not is by ensuring that both
     * first_line_close_date and staggered_closing_interval are not null.
     */
    if (l_first_line_close_date is not null and l_staggered_closing_interval is not null) then
      PON_NEGOTIATION_HELPER_PVT.UPDATE_STAG_LINES_CLOSE_DATES (
        x_result => x_result,
        x_error_code => x_error_code,
        x_error_message => x_error_message,
        p_auction_header_id => p_auction_header_id,
        p_first_line_close_date => l_first_line_close_date,
        p_staggered_closing_interval => l_staggered_closing_interval,
        p_start_disp_line_number => 0,
        x_last_line_close_date => x_last_line_close_date);
    end if;

    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        l_progress := 'PON_NEGOTIATION_PUBLISH_PVT.UPDATE_STAG_LINES_CLOSE_DATES' ||
                      'l_first_line_close_date = ' || to_char(l_first_line_close_date, 'dd-mon-yyyy hh24:mi:ss') ||
                      'l_staggered_closing_interval = ' || l_staggered_closing_interval ||
                      'x_last_line_close_date = ' || to_char(x_last_line_close_date, 'dd-mon-yyyy hh24:mi:ss');
    END if;

    IF (l_auction_round_number > 0 or l_amendment_number > 0) THEN

        -- Call the renumber API
        PON_NEGOTIATION_HELPER_PVT.RENUMBER_LINES (
          x_result                      => x_result,
          x_error_code                  => x_error_message,
          x_error_message               => x_error_code,
          p_auction_header_id           => p_auction_header_id,
          p_min_disp_line_number_parent => 0,
          p_min_disp_line_number_child  => 0,
          p_min_child_parent_line_num   => 0,
          x_last_line_number            => l_max_display_number);

        -- Determine total number of lines
        SELECT count(line_number)
        INTO l_number_of_lines
        FROM pon_auction_item_prices_all
        WHERE auction_header_id = g_auction_header_id;

    else

        -- If this is not an amendment or new round then we need to synch the PON_LARGE_NEG_PF_VALUES
        -- If a template is applied
        IF (g_price_element_enabled_flag = 'Y' and
            l_large_neg_enabled_flag = 'Y' and
            l_template_id <> 0) THEN

           SYNCH_PF_VALUES_FOR_UPLOAD;

        END IF;


        select
          COUNT(line_number),
          MAX (DECODE (paip.group_type, 'LOT_LINE', 0, 'GROUP_LINE', 0, paip.sub_line_sequence_number))
        into
          l_number_of_lines,
          l_max_display_number
          FROM
             pon_auction_item_prices_all paip
          where
            paip.auction_header_id = p_auction_header_id;
    end if;


    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        l_progress := 'PON_NEGOTIATION_PUBLISH_PVT.RENUMBER_LINES p_auction_header_id = '||p_auction_header_id||' l_max_display_number = '||l_max_display_number;
    END if;


    -- Clear the interface tables
    -- What is there is an error? need to clear these always
    IF(Nvl(p_commit,'Y') = 'Y') then
      delete from pon_item_prices_interface where batch_id = g_batch_id;
      delete from pon_auc_attributes_interface where batch_id = g_batch_id;
      delete from pon_auc_payments_interface where batch_id = g_batch_id;
      delete from pon_auc_price_differ_int where batch_id = g_batch_id;
      delete from pon_auc_price_elements_int where batch_id = g_batch_id;

      IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
          l_progress := 'delete completed p_auction_header_id = '||p_auction_header_id;
      END if;
    END IF;

    SELECT count(line_number)
    INTO l_number_of_lines
    FROM pon_auction_item_prices_all
    WHERE auction_header_id = g_auction_header_id;

    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        l_progress := 'delete completed  g_batch_id = '||g_batch_id ||
                                 ' g_auction_header_id ='||g_auction_header_id;
    END if;

    x_number_of_lines := l_number_of_lines;
    x_max_disp_line := l_max_display_number;

    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        l_progress := 'delete completed  g_batch_id = '||g_batch_id ||
                                 ' g_auction_header_id ='||g_auction_header_id;

        IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            print_debug_log(l_module,'SYNCH_FROM_INTERFACE  END g_batch_id = '||g_batch_id ||
                                 ' g_auction_header_id ='||g_auction_header_id);
        END IF;

    END if;


    x_result := 'S';

EXCEPTION
    WHEN OTHERS THEN
        x_result := 'F';
        x_error_code := SQLCODE;
        x_error_message := SUBSTR(SQLERRM, 1, 100);
        IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
            print_error_log(l_module, 'EXCEPTION -  l_progress='||l_progress||' x_result=' || x_result || ' x_error_code=' || x_error_code || ' x_error_message=' || x_error_message || ' SQLERRM=' || SQLERRM);
        END if;

--}
END SYNCH_FROM_INTERFACE ;

/* Wrappr around SYNCH_FROM_INTERFACE
* Created for Solicitation api project
* From usual normal flows p_commit will be used as 'Y'
* From solicitation api p_commit will be used as 'N'
* so that data in interface tables will not be deleted
*/
PROCEDURE SYNCH_FROM_INTERFACE(
    p_batch_id              IN NUMBER,
    p_auction_header_id     IN NUMBER,
    p_user_id               IN NUMBER,
    p_party_id              IN NUMBER,
    x_number_of_lines       OUT NOCOPY NUMBER,
    x_max_disp_line         OUT NOCOPY NUMBER,
    x_last_line_close_date  OUT NOCOPY DATE,
    x_result                OUT NOCOPY VARCHAR2, -- S: Success, F: failure
    x_error_code            OUT NOCOPY VARCHAR2,
    x_error_message         OUT NOCOPY VARCHAR2
)is
BEGIN
    SYNCH_FROM_INTERFACE(p_batch_id,
                         p_auction_header_id,
                         p_user_id,
                         p_party_id,
                         'Y',
                         x_number_of_lines,
                         x_max_disp_line,
                         x_last_line_close_date,
                         x_result,
                         x_error_code,
                         x_error_message);

END;



/*======================================================================
 PROCEDURE:  SYNCH_PAYMENTS_FROM_INTERFACE  PUBLIC

 PARAMETERS:
  IN : p_batch_id            NUMBER batch id for which the data needs to
                                    be copied, deleted or added from the
                                    interface tables in the transaction
                                    tables.

  IN : p_auction_header_id   NUMBER  auction header id for which the data
                                     needs to be copied, deleted or added
                                     from the interface tables in the
                                     transaction tables.

 COMMENT   :    This procedure will update/add the payments based on the records
                in the transaction tables for the batch id
                and auction header id passed as a parameter to the procedure.
======================================================================*/
PROCEDURE SYNCH_PAYMENTS_FROM_INTERFACE(
    p_batch_id              IN NUMBER,
    p_auction_header_id     IN NUMBER,
    x_result                OUT NOCOPY VARCHAR2, -- S: Success, E: failure
    x_error_code            OUT NOCOPY VARCHAR2,
    x_error_message         OUT NOCOPY VARCHAR2
)is

l_module CONSTANT VARCHAR2(32) := 'SYNCH_PAYMENTS_FROM_INTERFACE';
l_progress              varchar2(200);
l_sequence              NUMBER :=0;
l_previous_line_number  pon_auction_item_prices_all.document_disp_line_number%TYPE;
l_prev_amend_auc_id     pon_auction_headers_all.auction_header_id_prev_amend%TYPE;
l_supplier_modify_flag  pon_auction_headers_all.supplier_enterable_pymt_flag%TYPE;


CURSOR l_attachment_cursor
IS
  SELECT papi.attachment_desc,
         papi.attachment_url,
         paps.payment_id,
         paps.auction_header_id,
         paps.line_number,
         papi.document_disp_line_number
  FROM   pon_auc_payments_interface papi,
         pon_auction_item_prices_all pai,
         pon_auc_payments_shipments paps
  WHERE  papi.auction_header_id = pai.auction_header_id
  AND    papi.document_disp_line_number = pai.document_disp_line_number
  AND    paps.auction_header_id = pai.auction_header_id
  AND    paps.line_number = pai.line_number
  AND    paps.payment_display_number = papi.payment_display_number
  AND    papi.batch_id = p_batch_id
  AND    papi.attachment_desc IS NOT NULL;

BEGIN
--{
    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'SYNCH_PAYMENTS_FROM_INTERFACE  START p_batch_id = '||p_batch_id ||' p_auction_header_id '||p_auction_header_id);
    END IF;

    -- If the payment_display_number and line_number combination already exists
	-- in the transaction table update the record

    -- If the payment_display_number and line_number combination does not exist
	-- in the transaction table insert the record

	MERGE INTO PON_AUC_PAYMENTS_SHIPMENTS paps
	  USING (SELECT ppi.BATCH_ID,
	                ppi.INTERFACE_LINE_ID,
	                ppi.AUCTION_HEADER_ID,
	                pai.line_number,
	                ppi.PAYMENT_DISPLAY_NUMBER,
	                ppi.PAYMENT_DESCRIPTION,
	                fl.lookup_code PAYMENT_TYPE_CODE,
	                ppi.DOCUMENT_DISP_LINE_NUMBER,
	                DECODE(fl.lookup_code, 'RATE', ppi.QUANTITY, NULL) QUANTITY,
	                DECODE(fl.lookup_code, 'RATE', uom.uom_code, NULL) UOM_CODE,
	                ppi.TARGET_PRICE,
	                ppi.NEED_BY_DATE,
	                DECODE(pah.SUPPLIER_ENTERABLE_PYMT_FLAG,'Y', NULL, hrl.location_id) SHIP_TO_LOCATION_ID,
	                DECODE(pah.SUPPLIER_ENTERABLE_PYMT_FLAG,'Y', NULL, fu.user_id)   WORK_APPROVER_USER_ID,
	                ppi.NOTE_TO_BIDDERS,
	                DECODE(pai.LINE_ORIGINATION_CODE, 'REQUISITION', NULL, DECODE(pah.SUPPLIER_ENTERABLE_PYMT_FLAG,'Y', NULL, pro.project_id)) PROJECT_ID,
	                DECODE(pai.LINE_ORIGINATION_CODE, 'REQUISITION', NULL, DECODE(pah.SUPPLIER_ENTERABLE_PYMT_FLAG,'Y', NULL,
                     (SELECT task_id FROM PA_TASKS_EXPEND_V task WHERE task.task_number = ppi.project_task_number AND task.project_number=ppi.project_number))) PROJECT_TASK_ID,
	                DECODE(pai.LINE_ORIGINATION_CODE, 'REQUISITION', NULL, DECODE(pah.SUPPLIER_ENTERABLE_PYMT_FLAG,'Y', NULL, (SELECT award_id FROM GMS_AWARDS_BASIC_V award WHERE award.award_number = ppi.project_award_number))) PROJECT_AWARD_ID,
	                DECODE(pai.LINE_ORIGINATION_CODE, 'REQUISITION', NULL, DECODE(pah.SUPPLIER_ENTERABLE_PYMT_FLAG,'Y', NULL, ppi.PROJECT_EXPENDITURE_TYPE)) PROJECT_EXPENDITURE_TYPE,
	                DECODE(pai.LINE_ORIGINATION_CODE, 'REQUISITION', NULL, DECODE(pah.SUPPLIER_ENTERABLE_PYMT_FLAG,'Y', NULL, porg.organization_id)) PROJECT_EXP_ORGANIZATION_ID,
	                DECODE(pai.LINE_ORIGINATION_CODE, 'REQUISITION', NULL, DECODE(pah.SUPPLIER_ENTERABLE_PYMT_FLAG,'Y', NULL, ppi.PROJECT_EXPENDITURE_ITEM_DATE)) PROJECT_EXPENDITURE_ITEM_DATE
	           FROM PON_AUC_PAYMENTS_INTERFACE ppi,
	                PON_AUCTION_ITEM_PRICES_ALL pai,
	                PON_AUCTION_HEADERS_ALL pah,
	                FND_USER fu,
	                HR_LOCATIONS_ALL hrl,
	          	    MTL_UNITS_OF_MEASURE uom,
	                PO_LOOKUP_CODES fl,
	            	PA_PROJECTS_EXPEND_V pro,
	            	PA_ORGANIZATIONS_EXPEND_V porg
	          WHERE ppi.auction_header_id = pai.auction_header_id
	          AND   ppi.batch_id = p_batch_id
	          AND   ppi.document_disp_line_number = pai.document_disp_line_number
	          AND   ppi.auction_header_id = p_auction_header_id
	          AND   pah.auction_header_id = pai.auction_header_id
	          AND   pai.group_type NOT IN ('GROUP', 'LOT_LINE')
	          AND   ppi.ship_to_location_code = hrl.location_code(+)
	          AND   ppi.work_approver_user_name = fu.user_name(+)
	          AND   ppi.project_number = pro.project_number(+)
	          AND   ppi.project_exp_organization_name = porg.name(+)
	          AND   ppi.unit_of_measure = uom.unit_of_measure_tl(+)
	          AND   uom.language (+) = userenv('LANG')
	          AND   ppi.payment_type = fl.displayed_field (+)
	          AND   fl.lookup_type(+) = 'PAYMENT TYPE') papi
	   ON( paps.payment_display_number = papi.payment_display_number
	       AND  paps.line_number = papi.line_number
	       AND  paps.auction_header_id = papi.auction_header_id)
	   WHEN MATCHED THEN
	     UPDATE SET paps.payment_description = papi.payment_description,
	                paps.payment_type_code = papi.payment_type_code,
	                paps.quantity = papi.quantity,
	                paps.uom_code = papi.uom_code,
	                paps.target_price = papi.target_price,
	                paps.need_by_date = papi.need_by_date,
	                paps.ship_to_location_id = papi.ship_to_location_id,
	                paps.work_approver_user_id = papi.work_approver_user_id,
	                paps.note_to_bidders = papi.note_to_bidders,
	                paps.project_id = papi.project_id,
	                paps.project_task_id = papi.project_task_id,
	                paps.project_award_id = papi.project_award_id,
	                paps.project_exp_organization_id = papi.project_exp_organization_id,
	                paps.project_expenditure_type = papi.project_expenditure_type,
	                paps.project_expenditure_item_date = papi.project_expenditure_item_date,
	                paps.last_update_date = sysdate,
	                paps.last_updated_by = fnd_global.user_id,
	                paps.last_update_login = fnd_global.login_id
	   WHEN NOT MATCHED THEN
	     INSERT (
	            PAYMENT_ID                        ,
	            AUCTION_HEADER_ID                 ,
	            LINE_NUMBER                       ,
	            PAYMENT_DISPLAY_NUMBER            ,
	            PAYMENT_DESCRIPTION               ,
	            PAYMENT_TYPE_CODE                 ,
	            SHIP_TO_LOCATION_ID               ,
	            QUANTITY                          ,
	            UOM_CODE                          ,
	            TARGET_PRICE                      ,
	            NEED_BY_DATE                      ,
	            WORK_APPROVER_USER_ID             ,
	            NOTE_TO_BIDDERS                   ,
	            PROJECT_ID                        ,
	            PROJECT_TASK_ID                   ,
	            PROJECT_AWARD_ID                  ,
	            PROJECT_EXPENDITURE_TYPE          ,
	            PROJECT_EXP_ORGANIZATION_ID       ,
	            PROJECT_EXPENDITURE_ITEM_DATE     ,
	            CREATION_DATE                     ,
	            CREATED_BY                        ,
	            LAST_UPDATE_DATE                  ,
	            LAST_UPDATED_BY                   ,
	            LAST_UPDATE_LOGIN
	            )
	     VALUES (
	            PON_AUC_PAYMENTS_SHIPMENTS_S1.nextval   ,
	            papi.AUCTION_HEADER_ID                 ,
	            papi.LINE_NUMBER                       ,
	            papi.PAYMENT_DISPLAY_NUMBER            ,
	            papi.PAYMENT_DESCRIPTION               ,
	            papi.PAYMENT_TYPE_CODE                 ,
	            papi.SHIP_TO_LOCATION_ID               ,
	            papi.QUANTITY                          ,
	            papi.UOM_CODE                          ,
	            papi.TARGET_PRICE                      ,
	            papi.NEED_BY_DATE                      ,
	            papi.WORK_APPROVER_USER_ID             ,
	            papi.NOTE_TO_BIDDERS                   ,
	            papi.PROJECT_ID                        ,
	            papi.PROJECT_TASK_ID                   ,
	            papi.PROJECT_AWARD_ID                  ,
	            papi.PROJECT_EXPENDITURE_TYPE          ,
	            papi.PROJECT_EXP_ORGANIZATION_ID       ,
	            papi.PROJECT_EXPENDITURE_ITEM_DATE     ,
	            SYSDATE                                ,
	            fnd_global.user_id                     ,
	            SYSDATE                                ,
	            fnd_global.user_id                     ,
	            fnd_global.login_id
	            ) ;


    IF (g_fnd_debug = 'Y' and FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        l_progress := 'Merge into pon_auc_payments_shipments is successful for auction_header_id = '||p_auction_header_id;
    END if;

    --create URL Attachments
    FOR l_attachment_record IN l_attachment_cursor LOOP

       IF l_previous_line_number IS NULL OR l_attachment_record.document_disp_line_number <> l_previous_line_number THEN
          l_sequence := 1;
          l_previous_line_number := l_attachment_record.document_disp_line_number;
       ELSE
          l_sequence := l_sequence+1;

       END IF;

       PON_OA_UTIL_PKG.create_url_attachment(
        p_seq_num                 => l_sequence,
        p_category_name           => 'Vendor',
        p_document_description    => l_attachment_record.attachment_desc,
        p_datatype_id             => 5,
        p_url                     => l_attachment_record.attachment_url,
        p_entity_name             => 'PON_AUC_PAYMENTS_SHIPMENTS',
        p_pk1_value               => l_attachment_record.auction_header_id,
        p_pk2_value               => l_attachment_record.line_number,
        p_pk3_value               => l_attachment_record.payment_id,
        p_pk4_value               => NULL,
        p_pk5_value               => NULL);
    END LOOP;

    -- Clear the interface tables
    -- What is there is an error? need to clear these always
    delete from pon_auc_payments_interface where batch_id = p_batch_id;

    IF (g_fnd_debug = 'Y' and FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        l_progress := 'delete from pon_auc_payments_interface completed for p_batch_id = '||p_batch_id||'p_auction_header_id = '||p_auction_header_id;
    END if;

    --Mark which lines are changed during amendment
    BEGIN
      SELECT pah.auction_header_id_prev_amend,
             pah.supplier_enterable_pymt_flag
      INTO   l_prev_amend_auc_id,
             l_supplier_modify_flag
      FROM  PON_AUCTION_HEADERS_ALL pah
      WHERE auction_header_id = p_auction_header_id;

      IF l_prev_amend_auc_id IS NOT NULL THEN
        --Update pon_auction_item_prices_all to set lastupdatedate
        -- for changed payments
        UPDATE pon_auction_item_prices_all al
        SET modified_flag = 'Y'
        , modified_date = SYSDATE
        , last_update_date = SYSDATE
        , last_updated_by = fnd_global.user_id
        , last_update_login = fnd_global.login_id
        WHERE al.auction_header_id = p_auction_header_id
        AND (EXISTS (
            SELECT 1
            FROM pon_auc_payments_shipments pap1,
                 pon_auc_payments_shipments pap2
            WHERE pap1.auction_header_id = al.auction_header_id
            AND pap1.line_number       = al.line_number
            AND pap1.payment_display_number    = pap2.payment_display_number
            AND pap2.auction_header_id = l_prev_amend_auc_id
            AND pap1.line_number       = pap2.line_number
            AND (nvl(pap1.payment_description,FND_API.G_NULL_CHAR) <> NVL(pap2.payment_description, FND_API.G_NULL_CHAR)
            OR  nvl(pap1.payment_type_code,FND_API.G_NULL_CHAR) <> nvl(pap2.payment_type_code,FND_API.G_NULL_CHAR)
            OR  DECODE(l_supplier_modify_flag, 'Y',1,nvl(pap1.ship_to_location_id,fnd_api.G_NULL_NUM))
                <> DECODE(l_supplier_modify_flag, 'Y',1,nvl(pap2.ship_to_location_id,fnd_api.G_NULL_NUM))
            OR  nvl(pap1.quantity,fnd_api.G_NULL_NUM) <> nvl(pap2.quantity,fnd_api.G_NULL_NUM)
            OR  nvl(pap1.uom_code,FND_API.G_NULL_CHAR) <> nvl(pap2.uom_code,FND_API.G_NULL_CHAR)
            OR  nvl(pap1.target_price,fnd_api.G_NULL_NUM) <> nvl(pap2.target_price,fnd_api.G_NULL_NUM)
            OR  nvl(pap1.need_by_date,fnd_api.G_NULL_DATE) <> nvl(pap2.need_by_date,fnd_api.G_NULL_DATE)
            OR  DECODE(l_supplier_modify_flag, 'Y',1,nvl(pap1.work_approver_user_id,fnd_api.G_NULL_NUM))
             <> DECODE(l_supplier_modify_flag, 'Y',1,nvl(pap2.work_approver_user_id,fnd_api.G_NULL_NUM))
            OR  DECODE(l_supplier_modify_flag, 'Y','Y',nvl(pap1.note_to_bidders,FND_API.G_NULL_CHAR))
             <> DECODE(l_supplier_modify_flag, 'Y','Y',nvl(pap2.note_to_bidders,FND_API.G_NULL_CHAR))
            OR  DECODE(l_supplier_modify_flag, 'Y',1,nvl(pap1.project_id,fnd_api.G_NULL_NUM))
             <> DECODE(l_supplier_modify_flag, 'Y',1,nvl(pap2.project_id,fnd_api.G_NULL_NUM))
            OR  DECODE(l_supplier_modify_flag, 'Y',1,nvl(pap1.project_task_id,fnd_api.G_NULL_NUM))
             <> DECODE(l_supplier_modify_flag, 'Y',1,nvl(pap2.project_task_id,fnd_api.G_NULL_NUM))
            OR  DECODE(l_supplier_modify_flag, 'Y',1,nvl(pap1.project_award_id,fnd_api.G_NULL_NUM))
             <> DECODE(l_supplier_modify_flag, 'Y',1,nvl(pap2.project_award_id,fnd_api.G_NULL_NUM))
            OR  DECODE(l_supplier_modify_flag, 'Y','Y',nvl(pap1.project_expenditure_type,FND_API.G_NULL_CHAR))
             <> DECODE(l_supplier_modify_flag, 'Y','Y',nvl(pap2.project_expenditure_type,FND_API.G_NULL_CHAR))
            OR  DECODE(l_supplier_modify_flag, 'Y',1,nvl(pap1.project_exp_organization_id,fnd_api.G_NULL_NUM))
             <> DECODE(l_supplier_modify_flag, 'Y',1,nvl(pap2.project_exp_organization_id,fnd_api.G_NULL_NUM))
            OR  DECODE(l_supplier_modify_flag, 'Y',sysdate,nvl(pap1.project_expenditure_item_date,fnd_api.G_NULL_DATE))
             <> DECODE(l_supplier_modify_flag, 'Y',sysdate,nvl(pap2.project_expenditure_item_date,fnd_api.G_NULL_DATE)))

        OR
           EXISTS (
            SELECT 1
            FROM pon_auc_payments_shipments pap1
            WHERE pap1.auction_header_id = al.auction_header_id
            AND pap1.line_number       = al.line_number
            AND NOT EXISTS (
              SELECT 1
              FROM  pon_auc_payments_shipments pap2
              WHERE pap2.auction_header_id = l_prev_amend_auc_id
              AND pap2.line_number       = pap1.line_number
              AND pap2.payment_display_number = pap1.payment_display_number
        )))

       );

      END IF;
    EXCEPTION
      WHEN OTHERS THEN

        x_result := 'E';
        x_error_code := SQLCODE;
        x_error_message := SUBSTR(SQLERRM, 1, 100);
        IF (g_fnd_debug = 'Y' and FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            print_error_log(l_module, 'EXCEPTION -  l_progress='||l_progress||' x_result=' || x_result || ' x_error_code=' || x_error_code || ' x_error_message=' || x_error_message || ' SQLERRM=' || SQLERRM);
        END if;
    END;

    --End of mark lines as changed

    x_result := 'S';

EXCEPTION
    WHEN OTHERS THEN
        x_result := 'E';
        x_error_code := SQLCODE;
        x_error_message := SUBSTR(SQLERRM, 1, 100);
        IF (g_fnd_debug = 'Y' and FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            print_error_log(l_module, 'EXCEPTION -  l_progress='||l_progress||' x_result=' || x_result || ' x_error_code=' || x_error_code || ' x_error_message=' || x_error_message || ' SQLERRM=' || SQLERRM);
        END if;

--}
END SYNCH_PAYMENTS_FROM_INTERFACE ;


/*======================================================================
 PROCEDURE:  UPDATE_CONCURRENT_ERRORS  PUBLIC

 PARAMETERS:
  IN : p_batch_id            NUMBER batch id for which the errors are to
                                    be copied

  IN : p_auction_header_id   NUMBER  auction_header_id for which the file
                                     was uploaded

  IN : p_request_id          NUMBER  Request id of the cocurrent program

 COMMENT   :    This procedure will copy all the errors into pl/sql tables,
    ROLLBACK the transaction and then copy the errors back to the database.
    This is ONLY CALLED FROM THE CONCURRENT PROGRAM.
======================================================================*/
PROCEDURE UPDATE_CONCURRENT_ERRORS (
    p_batch_id              IN NUMBER,
    p_auction_header_id     IN NUMBER,
    x_result                OUT NOCOPY VARCHAR2, -- S: Success, E: failure
    x_error_code            OUT NOCOPY VARCHAR2,
    x_error_message         OUT NOCOPY VARCHAR2
) is

    l_INTERFACE_TYPE                PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
    l_COLUMN_NAME                   PON_NEG_COPY_DATATYPES_GRP.VARCHAR2000_TYPE;
    l_TABLE_NAME                    PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
    l_INTERFACE_LINE_ID             PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
    l_ERROR_MESSAGE_NAME            PON_NEG_COPY_DATATYPES_GRP.VARCHAR2000_TYPE;
    l_ERROR_VALUE                   PON_NEG_COPY_DATATYPES_GRP.VARCHAR100_TYPE;
    l_CREATED_BY                    PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
    l_CREATION_DATE                 PON_NEG_COPY_DATATYPES_GRP.SIMPLE_DATE_TYPE;
    l_LAST_UPDATED_BY               PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
    l_LAST_UPDATE_DATE              PON_NEG_COPY_DATATYPES_GRP.SIMPLE_DATE_TYPE;
    l_LAST_UPDATE_LOGIN             PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
    l_ENTITY_TYPE                   PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
    l_ENTITY_ATTR_NAME              PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
    l_ERROR_VALUE_DATE              PON_NEG_COPY_DATATYPES_GRP.SIMPLE_DATE_TYPE;
    l_ERROR_VALUE_NUMBER            PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
    l_ERROR_VALUE_DATATYPE          PON_NEG_COPY_DATATYPES_GRP.VARCHAR20_TYPE;
    l_BID_NUMBER                    PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
    l_LINE_NUMBER                   PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
    l_ATTRIBUTE_NAME                PON_NEG_COPY_DATATYPES_GRP.VARCHAR300_TYPE;
    l_PRICE_ELEMENT_TYPE_ID         PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
    l_SHIPMENT_NUMBER               PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
    l_PRICE_DIFFERENTIAL_NUMBER     PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
    l_TOKEN1_NAME                   PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
    l_TOKEN1_VALUE                  PON_NEG_COPY_DATATYPES_GRP.VARCHAR2000_TYPE;
    l_TOKEN2_NAME                   PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
    l_TOKEN2_VALUE                  PON_NEG_COPY_DATATYPES_GRP.VARCHAR2000_TYPE;
    l_TOKEN3_NAME                   PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
    l_TOKEN3_VALUE                  PON_NEG_COPY_DATATYPES_GRP.VARCHAR2000_TYPE;
    l_TOKEN4_NAME                   PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
    l_TOKEN4_VALUE                  PON_NEG_COPY_DATATYPES_GRP.VARCHAR2000_TYPE;
    l_TOKEN5_NAME                   PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
    l_TOKEN5_VALUE                  PON_NEG_COPY_DATATYPES_GRP.VARCHAR2000_TYPE;

    l_progress              varchar2(200);
    l_module CONSTANT VARCHAR2(30) := 'SYNCH_PAYMENTS_FROM_INTERFACE';

BEGIN

    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'UPDATE_CONCURRENT_ERRORS  Start g_batch_id = '||g_batch_id ||
                                 ' g_auction_header_id ='||g_auction_header_id);
    END if;

    SELECT
    NVL(INTERFACE_TYPE,'ITEMUPLOAD'),
    COLUMN_NAME,
    TABLE_NAME,
    INTERFACE_LINE_ID+1,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    nvl(ENTITY_TYPE,'TXT'),
    ENTITY_ATTR_NAME,
    ERROR_VALUE_DATE,
    ERROR_VALUE_NUMBER,
    ERROR_VALUE_DATATYPE,
    BID_NUMBER,
    LINE_NUMBER,
    ATTRIBUTE_NAME,
    PRICE_ELEMENT_TYPE_ID,
    SHIPMENT_NUMBER,
    PRICE_DIFFERENTIAL_NUMBER,
    TOKEN1_NAME,
    TOKEN1_VALUE,
    TOKEN2_NAME,
    TOKEN2_VALUE,
    TOKEN3_NAME,
    TOKEN3_VALUE,
    TOKEN4_NAME,
    TOKEN4_VALUE,
    TOKEN5_NAME,
    TOKEN5_VALUE
    BULK COLLECT INTO
    l_INTERFACE_TYPE,
    l_COLUMN_NAME,
    l_TABLE_NAME,
    l_INTERFACE_LINE_ID,
    l_ERROR_MESSAGE_NAME,
    l_ERROR_VALUE,
    l_CREATED_BY,
    l_CREATION_DATE,
    l_LAST_UPDATED_BY,
    l_LAST_UPDATE_DATE,
    l_LAST_UPDATE_LOGIN,
    l_ENTITY_TYPE,
    l_ENTITY_ATTR_NAME,
    l_ERROR_VALUE_DATE,
    l_ERROR_VALUE_NUMBER,
    l_ERROR_VALUE_DATATYPE,
    l_BID_NUMBER,
    l_LINE_NUMBER,
    l_ATTRIBUTE_NAME,
    l_PRICE_ELEMENT_TYPE_ID,
    l_SHIPMENT_NUMBER,
    l_PRICE_DIFFERENTIAL_NUMBER,
    l_TOKEN1_NAME,
    l_TOKEN1_VALUE,
    l_TOKEN2_NAME,
    l_TOKEN2_VALUE,
    l_TOKEN3_NAME,
    l_TOKEN3_VALUE,
    l_TOKEN4_NAME,
    l_TOKEN4_VALUE,
    l_TOKEN5_NAME,
    l_TOKEN5_VALUE
    FROM PON_INTERFACE_ERRORS
    WHERE BATCH_ID = p_batch_id
    order by interface_line_id;

    l_progress := 'PL/SQL Table of Records fetched';

    rollback;

    l_progress := 'Rollback completed';

    FORALL x IN 1..l_INTERFACE_TYPE.COUNT
    INSERT INTO PON_INTERFACE_ERRORS (
    INTERFACE_TYPE,
    COLUMN_NAME,
    TABLE_NAME,
    BATCH_ID,
    INTERFACE_LINE_ID,
    ERROR_MESSAGE_NAME,
    ERROR_VALUE,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    ENTITY_TYPE,
    ENTITY_ATTR_NAME,
    ERROR_VALUE_DATE,
    ERROR_VALUE_NUMBER,
    ERROR_VALUE_DATATYPE,
    AUCTION_HEADER_ID,
    BID_NUMBER,
    LINE_NUMBER,
    ATTRIBUTE_NAME,
    PRICE_ELEMENT_TYPE_ID,
    SHIPMENT_NUMBER,
    PRICE_DIFFERENTIAL_NUMBER,
    EXPIRATION_DATE,
    TOKEN1_NAME,
    TOKEN1_VALUE,
    TOKEN2_NAME,
    TOKEN2_VALUE,
    TOKEN3_NAME,
    TOKEN3_VALUE,
    TOKEN4_NAME,
    TOKEN4_VALUE,
    TOKEN5_NAME,
    TOKEN5_VALUE)
    VALUES
    (
    l_INTERFACE_TYPE(x),
    l_COLUMN_NAME(x),
    l_TABLE_NAME(x),
    p_batch_id,
    l_INTERFACE_LINE_ID(x),
    l_ERROR_MESSAGE_NAME(x),
    l_ERROR_VALUE(x),
    l_CREATED_BY(x),
    l_CREATION_DATE(x),
    l_LAST_UPDATED_BY(x),
    l_LAST_UPDATE_DATE(x),
    l_LAST_UPDATE_LOGIN(x),
    fnd_global.conc_request_id,
    l_ENTITY_TYPE(x),
    l_ENTITY_ATTR_NAME(x),
    l_ERROR_VALUE_DATE(x),
    l_ERROR_VALUE_NUMBER(x),
    l_ERROR_VALUE_DATATYPE(x),
    p_auction_header_id,
    l_BID_NUMBER(x),
    l_LINE_NUMBER(x),
    l_ATTRIBUTE_NAME(x),
    l_PRICE_ELEMENT_TYPE_ID(x),
    l_SHIPMENT_NUMBER(x),
    l_PRICE_DIFFERENTIAL_NUMBER(x),
    sysdate+7,
    l_TOKEN1_NAME(x),
    l_TOKEN1_VALUE(x),
    l_TOKEN2_NAME(x),
    l_TOKEN2_VALUE(x),
    l_TOKEN3_NAME(x),
    l_TOKEN3_VALUE(x),
    l_TOKEN4_NAME(x),
    l_TOKEN4_VALUE(x),
    l_TOKEN5_NAME(x),
    l_TOKEN5_VALUE(x)
    );

    l_progress := 'Records inserted';


    IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        print_debug_log(l_module,'UPDATE_CONCURRENT_ERRORS  END g_batch_id = '||g_batch_id ||
                                 ' g_auction_header_id ='||g_auction_header_id);
    END if;

    x_result := 'S';

EXCEPTION
    WHEN OTHERS THEN
        x_result := 'F';
        x_error_code := SQLCODE;
        x_error_message := SUBSTR(SQLERRM, 1, 100);
        IF (g_fnd_debug = 'Y' and FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
            print_error_log(l_module, 'EXCEPTION -  l_progress='|| l_progress ||' x_result=' || x_result || ' x_error_code=' || x_error_code || ' x_error_message=' || x_error_message || ' SQLERRM=' || SQLERRM);
        END if;


END UPDATE_CONCURRENT_ERRORS;

/*======================================================================
 PROCEDURE:  PRINT_DEBUG_LOG    PRIVATE
   PARAMETERS:
   COMMENT   :  This procedure is used to print debug messages into
                FND logs
======================================================================*/
PROCEDURE print_debug_log(p_module   IN    VARCHAR2,
                          p_message  IN    VARCHAR2)
IS

BEGIN

IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
         FND_LOG.string(log_level => FND_LOG.level_statement,
                        module  =>  g_module_prefix || p_module,
                        message  => p_message);
END if;

END;

/*======================================================================
 PROCEDURE:  PRINT_ERROR_LOG    PRIVATE
   PARAMETERS:
   COMMENT   :  This procedure is used to print unexpected exceptions or
                error  messages into FND logs
======================================================================*/

PROCEDURE print_error_log(p_module   IN    VARCHAR2,
                          p_message  IN    VARCHAR2)
IS
BEGIN

IF (g_fnd_debug = 'Y' and FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
     FND_LOG.string(log_level => FND_LOG.level_procedure,
                     module    =>  g_module_prefix || p_module,
                     message   => p_message);
END if;

END;


END PON_CP_INTRFAC_TO_TRANSACTION;

/
