--------------------------------------------------------
--  DDL for Package Body INV_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_WORKFLOW" AS
  /* $Header: INVFBWFB.pls 120.3.12010000.4 2009/10/14 08:37:21 jianxzhu ship $ */

  --
  --  Global Variables
  --
  g_version_printed   BOOLEAN      := FALSE;
  g_pkg_name CONSTANT VARCHAR2(50) := 'INV_WORKFLOW';

  PROCEDURE print_debug(p_message IN VARCHAR2, p_module IN VARCHAR2) IS
  BEGIN
    IF NOT g_version_printed THEN
      inv_log_util.TRACE('$Header: INVFBWFB.pls 120.3.12010000.4 2009/10/14 08:37:21 jianxzhu ship $', g_pkg_name, 9);
      g_version_printed  := TRUE;
    END IF;

    inv_log_util.TRACE(p_message, g_pkg_name || '.' || p_module);
  END;

  FUNCTION call_generate_cogs(
    c_fb_flex_num               IN            NUMBER DEFAULT 101
  , c_ic_customer_id            IN            NUMBER DEFAULT NULL
  , c_ic_item_id                IN            NUMBER DEFAULT NULL
  , c_ic_order_header_id        IN            NUMBER DEFAULT NULL
  , c_ic_order_line_id          IN            NUMBER DEFAULT NULL
  , c_ic_order_type_id          IN            NUMBER DEFAULT NULL
  , c_ic_sell_oper_unit         IN            NUMBER DEFAULT NULL
  , c_v_ccid                    IN OUT NOCOPY NUMBER
  , c_fb_flex_seg               IN OUT NOCOPY VARCHAR2
  , c_fb_error_msg              IN OUT NOCOPY VARCHAR2
  , c_ic_to_inv_organization_id IN            NUMBER DEFAULT NULL  -- Bug: 4474976.
  )
    RETURN BOOLEAN IS
    l_success BOOLEAN := TRUE;
  BEGIN
    l_success  :=
      inv_workflow.generate_cogs(
        fb_flex_num                  => c_fb_flex_num
      , ic_customer_id               => TO_CHAR(c_ic_customer_id)
      , ic_item_id                   => TO_CHAR(c_ic_item_id)
      , ic_order_header_id           => TO_CHAR(c_ic_order_header_id)
      , ic_order_line_id             => TO_CHAR(c_ic_order_line_id)
      , ic_order_type_id             => TO_CHAR(c_ic_order_type_id)
      , ic_sell_oper_unit            => TO_CHAR(c_ic_sell_oper_unit)
      , v_ccid                       => c_v_ccid
      , fb_flex_seg                  => c_fb_flex_seg
      , fb_error_msg                 => c_fb_error_msg
      , ic_to_inv_organization_id    => TO_CHAR(c_ic_to_inv_organization_id)  -- Bug: 4474976.
      );
    RETURN l_success;
  END call_generate_cogs;

  FUNCTION generate_cogs(
    fb_flex_num               IN            NUMBER DEFAULT 101
  , ic_customer_id            IN            VARCHAR2 DEFAULT NULL
  , ic_item_id                IN            VARCHAR2 DEFAULT NULL
  , ic_order_header_id        IN            VARCHAR2 DEFAULT NULL
  , ic_order_line_id          IN            VARCHAR2 DEFAULT NULL
  , ic_order_type_id          IN            VARCHAR2 DEFAULT NULL
  , ic_sell_oper_unit         IN            VARCHAR2 DEFAULT NULL
  , v_ccid                    IN OUT NOCOPY NUMBER
  , fb_flex_seg               IN OUT NOCOPY VARCHAR2
  , fb_error_msg              IN OUT NOCOPY VARCHAR2
  , ic_to_inv_organization_id IN            NUMBER DEFAULT NULL  -- Bug: 4474976.
  )
    RETURN BOOLEAN IS
    v_item_cogs          NUMBER         := NULL;
    v_organization_cogs  NUMBER         := NULL;
    v_order_type_cogs    NUMBER;
    v_concat_ids         VARCHAR2(2000);
    v_concat_segs        VARCHAR2(2000);
    v_concat_descrs      VARCHAR2(2000);
    error_message        VARCHAR2(500);
    v_generate_success   BOOLEAN        := TRUE;
    v_itemkey            VARCHAR2(100);
    ic_items_cogs        NUMBER         := NULL;
    ic_organization_cogs NUMBER         := NULL;
    ic_order_type_cogs   NUMBER         := NULL;
    translated_mesg      VARCHAR2(1500) := NULL;
    v_buffer             VARCHAR2(1000) := NULL;
    l_err_pt             VARCHAR2(10)   := NULL;
    v_doc_type_id        NUMBER         := NULL;
    l_debug              NUMBER         := NVL(fnd_profile.VALUE('INV_DEBUG_TRACE'), 0);
    l_function_name      VARCHAR2(20)   := 'GENERATE_COGS';
    --
    -- Bug 6065114 added following variables for OPM purposes.
    --
    v_process_enabled_flag mtl_parameters.process_enabled_flag%TYPE := NULL;
    v_requisition_line_id  NUMBER       := NULL;

    -- Bug 8896018
    l_chart_of_accounts_id NUMBER       := NULL;
    l_ship_ou_id           NUMBER       := NULL;
    l_order_src_id         NUMBER       := NULL;
    -- End of Bug 8896018
  BEGIN
    l_err_pt            := '10';

    -- fnd_flex_workflow.debug_on; -- To print the FND Account Generator debug messages.

    IF (l_debug = 1) THEN
      print_debug('FB_FLEX_NUM: ' || TO_CHAR(fb_flex_num), l_function_name);
      print_debug('IC_CUSTOMER_ID: ' || ic_customer_id, l_function_name);
      print_debug('IC_ITEM_ID: ' || ic_item_id, l_function_name);
      print_debug('IC_ORDER_HEADER_ID: ' || ic_order_header_id, l_function_name);
      print_debug('IC_ORDER_LINE_ID: ' || ic_order_line_id, l_function_name);
      print_debug('IC_ORDER_TYPE_ID: ' || ic_order_type_id, l_function_name);
      print_debug('IC_SELL_OPER_UNIT: ' || ic_sell_oper_unit, l_function_name);
      print_debug('IC_TO_INV_ORGANIZATION_ID: ' || ic_to_inv_organization_id, l_function_name);
      print_debug('V_CCID: ' || TO_CHAR(v_ccid), l_function_name);
      print_debug('FB_FLEX_SEG: ' || fb_flex_seg, l_function_name);
      print_debug('FB_ERROR_MSG: ' || fb_error_msg, l_function_name);
      print_debug('Calling Workflow Initialize', l_function_name);
    END IF;

    wf_item.clearcache;
    v_itemkey           :=
                         fnd_flex_workflow.initialize(appl_short_name => 'SQLGL', code => 'GL#', num => fb_flex_num, itemtype => 'INVFLXWF');
    print_debug('Created itemkey :' || v_itemkey, l_function_name);

    IF (ic_items_cogs IS NULL AND (ic_item_id IS NOT NULL AND ic_to_inv_organization_id IS NOT NULL)) THEN
      BEGIN
        -- Bug: 4474976
        -- Replaced the local variable ic_sell_oper_unit with ic_to_inv_organization_id
        -- in the WHERE clause of the following SELECT Statment.
        -- Removed NVL function from the SELECT statement.
        SELECT cost_of_sales_account
          INTO v_item_cogs
          FROM mtl_system_items
         WHERE inventory_item_id = ic_item_id
           AND organization_id = ic_to_inv_organization_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          NULL;
      /*
            FND_MESSAGE.SET_NAME('FND', 'FLEX-BUILD INVALID VALUE');
            FND_MESSAGE.SET_TOKEN('VALUE', IC_ITEM_ID);
            FND_MESSAGE.SET_TOKEN('VSET_ID', '103099');
            FB_ERROR_MSG := FND_MESSAGE.GET_ENCODED;
            return FALSE; */
      END;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('IC_ITEMS_COGS: ' || v_item_cogs, l_function_name);
    END IF;

    l_err_pt            := '10.5';

    /* Bug3393516 : When the profile Tax: Invoice Freight as Revenue = 'Yes', then there will be atleast 2 lines in
    ra_customer_trx_lines_all (After Autoinoice Import) and the order line_id corresponding to the freight line will be 0.
    As a result the following code (without the if statement) fails and INCIAP ends up giving a warning */
    IF (ic_order_line_id <> 0) THEN
      BEGIN
        SELECT source_document_type_id
          INTO v_doc_type_id
          FROM oe_order_lines_all
         WHERE line_id = TO_NUMBER(ic_order_line_id);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('FND', 'FLEX-BUILD INVALID VALUE');
          fnd_message.set_token('VALUE', ic_order_line_id);
          fnd_message.set_token('VSET_ID', '000000');
          fb_error_msg  := fnd_message.get_encoded;
          RETURN FALSE;
      END;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('Found v_doc_type_id: ' || v_doc_type_id, l_function_name);
    END IF;

    l_err_pt            := '20';

    /* Derive Source parameter IC_ORDER_TYPE_COGS */
    /* If source document type ID = 10, the order is from an internal requisition.
    Use receiving organization's purchasing accrual account instead of order type
    COGS. */
    IF (v_doc_type_id = 10) THEN
      BEGIN
        SELECT mp.ap_accrual_account, mp.process_enabled_flag, prl.requisition_line_id
          INTO v_order_type_cogs, v_process_enabled_flag, v_requisition_line_id
          FROM mtl_parameters mp, po_requisition_lines_all prl, oe_order_lines_all ool
         WHERE ool.line_id = TO_NUMBER(ic_order_line_id)
           AND prl.requisition_line_id = ool.source_document_line_id
           AND mp.organization_id = prl.destination_organization_id;

        print_debug('Found v_acrual_acct: ' || v_order_type_cogs, l_function_name);
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          fnd_message.set_name('FND', 'FLEX-BUILD INVALID VALUE');
          fnd_message.set_token('VALUE', ic_order_type_id);
          fnd_message.set_token('VSET_ID', '103100');
          fb_error_msg  := fnd_message.get_encoded;
          RETURN FALSE;
      END;

      --
      -- Bug 6065114 added following for OPM purposes.
      --
      IF (NVL(v_process_enabled_flag,'N') = 'Y' AND v_requisition_line_id IS NOT NULL) THEN
         -- for process enabled organization get AAP from po_req_distributions_all
         BEGIN
           SELECT accrual_account_id
             INTO v_order_type_cogs
             FROM po_req_distributions_all
            WHERE requisition_line_id = v_requisition_line_id
              AND rownum < 2;
            print_debug('for OPM Found v_acrual_acct: ' || v_order_type_cogs, l_function_name);
         EXCEPTION
            WHEN OTHERS THEN -- possible no_data_found or multiple_rows
              fnd_message.set_name('FND', 'FLEX-BUILD INVALID VALUE');
              fnd_message.set_token('VALUE', ic_order_type_id||'-OPM');
              fnd_message.set_token('VSET_ID', '103100');
              fb_error_msg  := fnd_message.get_encoded;
              RETURN FALSE;
          END;
       END IF;
       -- End bug 6065114
    ELSE
      l_err_pt  := '20.5';
       -- Bug 8896018, comment the following statements

     /* IF (ic_order_type_cogs IS NULL) THEN
        BEGIN
          SELECT NVL(cost_of_goods_sold_account, 0)
            INTO v_order_type_cogs
            FROM oe_transaction_types_all
           WHERE transaction_type_id = TO_NUMBER(ic_order_type_id)a
             AND 1 = 1;

          print_debug('Found v_order_type_cogs: ' || v_order_type_cogs, l_function_name);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            fnd_message.set_name('FND', 'FLEX-BUILD INVALID VALUE');
            fnd_message.set_token('VALUE', ic_order_type_id);
            fnd_message.set_token('VSET_ID', '103100');
            fb_error_msg  := fnd_message.get_encoded;
            RETURN FALSE;
        END;
      END IF;*/
      -- End of bug 8896018

      -- Bug 8896018
       IF (ic_order_type_cogs IS NULL) AND (nvl(ic_order_line_id,0) <> 0) THEN
        BEGIN
          SELECT NVL(cost_of_goods_sold_account, 0)
            INTO v_order_type_cogs
            FROM oe_transaction_types_all
           WHERE transaction_type_id = TO_NUMBER(ic_order_type_id)
             AND 1 = 1;

          print_debug('Found v_order_type_cogs: ' || v_order_type_cogs, l_function_name);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            fnd_message.set_name('FND', 'FLEX-BUILD INVALID VALUE');
            fnd_message.set_token('VALUE', ic_order_type_id);
            fnd_message.set_token('VSET_ID', '103100');
            fb_error_msg  := fnd_message.get_encoded;
            RETURN FALSE;
        END;
      END IF;

      IF (ic_order_type_cogs IS NULL) AND (nvl(ic_order_line_id,0) = 0) THEN
        BEGIN
          SELECT NVL(cost_of_goods_sold_account, 0)
            INTO v_order_type_cogs
            FROM oe_transaction_types_all
           WHERE transaction_type_id = TO_NUMBER(ic_order_type_id)
             AND 1 = 1;

          SELECT org_id, order_source_id
            INTO l_ship_ou_id, l_order_src_id
            FROM oe_order_headers_all
           WHERE header_id = to_number(ic_order_header_id);

           IF (nvl(l_order_src_id,0) = 10) AND (v_order_type_cogs <> 0 )  THEN
              SELECT chart_of_accounts_id
                INTO l_chart_of_accounts_id
                FROM gl_code_combinations
               WHERE code_combination_id = v_order_type_cogs;

              IF (l_chart_of_accounts_id <> nvl(fb_flex_num, -1)) AND (l_ship_ou_id is NOT NULL) THEN
               SELECT NVL(freight_code_combination_id, 0)
                 INTO v_order_type_cogs
                 FROM mtl_intercompany_parameters
                WHERE ship_organization_id = l_ship_ou_id
                  AND sell_organization_id = to_number(ic_sell_oper_unit)
                  AND flow_type = 1;
              END IF;
            END IF;

               print_debug('Found v_order_type_cogs: ' || v_order_type_cogs, l_function_name);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            fnd_message.set_name('FND', 'FLEX-BUILD INVALID VALUE');
            fnd_message.set_token('VALUE', ic_order_type_id);
            fnd_message.set_token('VSET_ID', '103100');
            fb_error_msg  := fnd_message.get_encoded;
            RETURN FALSE;
        END;
      END IF;
      -- End of bug 8896018

    END IF;

    l_err_pt            := '30';

    IF (ic_organization_cogs IS NULL AND ic_to_inv_organization_id IS NOT NULL) THEN
      BEGIN
        -- Bug: 4474976
        -- Replaced the local variable ic_sell_oper_unit with ic_to_inv_organization_id
        -- in the WHERE clause of the following SQL Statment.
        -- Removed NVL function from the SELECT statement.
        SELECT cost_of_sales_account
          INTO v_organization_cogs
          FROM mtl_parameters
         WHERE organization_id = ic_to_inv_organization_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
           NULL;
      /* FND_MESSAGE.SET_NAME('FND', 'FLEX-BUILD INVALID VALUE');
         FND_MESSAGE.SET_TOKEN('VALUE', IC_SELL_OPER_UNIT);
         FND_MESSAGE.SET_TOKEN('VSET_ID', '103101');
         FB_ERROR_MSG := FND_MESSAGE.GET_ENCODED;
         return FALSE;*/
      END;
    END IF;

    IF (l_debug = 1) THEN
      print_debug('V_ORGANIZATION_COGS: ' || TO_CHAR(v_organization_cogs), l_function_name);
    END IF;

    l_err_pt            := '40';

    /*
    +-------------------------------------------------------
    | Now set atributes for all raw and derived parameters  |
    +-------------------------------------------------------+*/
    IF (l_debug = 1) THEN
      print_debug('Initilizing Workflow Item Attributes', l_function_name);
    END IF;

    IF (ic_customer_id IS NOT NULL) THEN
      wf_engine.setitemattrtext(itemtype => 'INVFLXWF', itemkey => v_itemkey, aname => 'IC_CUSTOMER_ID', avalue => ic_customer_id);
    END IF;

    l_err_pt            := '41';

    IF (ic_item_id IS NOT NULL) THEN
      wf_engine.setitemattrtext(itemtype => 'INVFLXWF', itemkey => v_itemkey, aname => 'IC_ITEM_ID', avalue => ic_item_id);
    END IF;

    l_err_pt            := '42';

    IF (ic_order_header_id IS NOT NULL) THEN
      wf_engine.setitemattrtext(itemtype => 'INVFLXWF', itemkey => v_itemkey, aname => 'IC_ORDER_HEADER_ID', avalue => ic_order_header_id);
    END IF;

    l_err_pt            := '43';

    IF (ic_order_line_id IS NOT NULL) THEN
      wf_engine.setitemattrtext(itemtype => 'INVFLXWF', itemkey => v_itemkey, aname => 'IC_ORDER_LINE_ID', avalue => ic_order_line_id);
    END IF;

    l_err_pt            := '44';

    IF (ic_order_type_id IS NOT NULL) THEN
      wf_engine.setitemattrtext(itemtype => 'INVFLXWF', itemkey => v_itemkey, aname => 'IC_ORDER_TYPE_ID', avalue => ic_order_type_id);
    END IF;

    l_err_pt            := '45';

    IF (ic_sell_oper_unit IS NOT NULL) THEN
      wf_engine.setitemattrtext(itemtype => 'INVFLXWF', itemkey => v_itemkey, aname => 'IC_SELL_OPER_UNIT', avalue => ic_sell_oper_unit);
    END IF;

    l_err_pt            := '46';

    IF (v_item_cogs IS NOT NULL) THEN
      wf_engine.setitemattrnumber(itemtype => 'INVFLXWF', itemkey => v_itemkey, aname => 'IC_ITEMS_COGS', avalue => v_item_cogs);
    END IF;

    l_err_pt            := '47';

    IF (v_organization_cogs IS NOT NULL) THEN
      wf_engine.setitemattrnumber(itemtype => 'INVFLXWF', itemkey => v_itemkey, aname => 'IC_ORGANIZATION_COGS', avalue => v_organization_cogs);
    END IF;

    l_err_pt            := '48';

    IF (v_order_type_cogs IS NOT NULL) THEN
      wf_engine.setitemattrnumber(itemtype => 'INVFLXWF', itemkey => v_itemkey, aname => 'IC_ORDER_TYPE_COGS', avalue => v_order_type_cogs);
    END IF;

    l_err_pt            := '49';

    IF (fb_flex_num IS NOT NULL) THEN
      wf_engine.setitemattrnumber(itemtype => 'INVFLXWF', itemkey => v_itemkey, aname => 'CHART_OF_ACCOUNTS_ID', avalue => fb_flex_num);
    END IF;

    l_err_pt            := '50';
    /*+--------------------------------------------------+
    | Now call the generate function which will kickoff  |
    | the workflow.                                      |
    +----------------------------------------------------*/
    v_ccid              := v_order_type_cogs;

    IF (l_debug = 1) THEN
      print_debug('Calling FND_ELEX_WORKFLOW.GENERATE with Parameters:', l_function_name);
      print_debug('Itemtype:' || ' INVFLXWF', l_function_name);
      print_debug('itemkey: ' || v_itemkey, l_function_name);
      print_debug('ccid: ' || TO_CHAR(v_ccid), l_function_name);
    END IF;

    v_generate_success  :=
      fnd_flex_workflow.generate(
        itemtype                     => 'INVFLXWF'
      , itemkey                      => v_itemkey
      , ccid                         => v_ccid
      , concat_segs                  => v_concat_segs
      , concat_ids                   => v_concat_ids
      , concat_descrs                => v_concat_descrs
      , error_message                => fb_error_msg
      );
    print_debug('FND_ELEX_WORKFLOW.GENERATE returned ccid' || TO_CHAR(v_ccid), l_function_name);
    print_debug('FND_ELEX_WORKFLOW.GENERATE returned v_concat_segs' || v_concat_segs, l_function_name);

    --Begin Bug 7518712
    IF ( v_doc_type_id = 10 AND
         NVL(v_process_enabled_flag,'N') = 'Y' AND
         v_requisition_line_id IS NOT NULL ) THEN

        --For process enabled organization ignore ccid returned from fnd_flex_workflow.generate
        IF v_ccid <> v_order_type_cogs THEN
           v_ccid := v_order_type_cogs;
        END IF;

    END IF;
    --End Bug 7518712

    IF (v_generate_success) THEN
      fb_flex_seg  := v_concat_segs;

      IF (v_ccid = -1) THEN
        l_err_pt  := '51';
        v_ccid    :=
          fnd_flex_ext.get_ccid(
            application_short_name       => 'SQLGL'
          , key_flex_code                => 'GL#'
          , structure_number             => fb_flex_num
          , validation_date              => TO_CHAR(SYSDATE, 'YYYY/MM/DD HH24:MI:SS')
          , concatenated_segments        => v_concat_segs
          );
        print_debug('fnd_flex_ext.get_ccid returned' || TO_CHAR(v_ccid), l_function_name);

        IF (v_ccid = 0) THEN
          fb_error_msg  := SUBSTR(fnd_message.get_encoded, 1, 240);
          print_debug('fnd_flex_ext.get_ccid returned no ccid.', l_function_name);
          RETURN FALSE;
        END IF;
      END IF;

      RETURN TRUE;
    ELSE
      l_err_pt      := '52';
      fb_flex_seg   := v_concat_segs;
      fb_error_msg  := SUBSTR(fb_error_msg, 1, 240);
      print_debug('FND_FLEX_WORKFLOW.GENERATE returned FALSE with error: ' || fb_error_msg, l_function_name);
      RETURN FALSE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      l_err_pt      := '53';
      print_debug('Unexpected error at l_err_pt: ' || l_err_pt, l_function_name);
      fnd_message.set_name('INV', 'INV_UNHANDLED_ERR');
      fnd_message.set_token('ENTITY1', l_function_name);
      v_buffer      := TO_CHAR(SQLCODE) || ' ' || SUBSTR(SQLERRM, 1, 150);
      fnd_message.set_token('ENTITY2', v_buffer);
      fb_error_msg  := SUBSTR(fnd_message.get_encoded, 1, 240);
      print_debug('Error message: ' || fb_error_msg, l_function_name);
      RETURN FALSE;
  END generate_cogs;

  PROCEDURE invoke_build(itemtype IN VARCHAR2, itemkey IN VARCHAR2, actid IN NUMBER, funcmode IN VARCHAR2, RESULT OUT NOCOPY VARCHAR2) IS
    build_success          BOOLEAN        := TRUE;
    p_fb_flex_num          NUMBER         DEFAULT 101;
    p_ic_customer_id       VARCHAR2(100)  DEFAULT NULL;
    p_ic_item_id           VARCHAR2(100)  DEFAULT NULL;
    p_ic_order_header_id   VARCHAR2(100)  DEFAULT NULL;
    p_ic_order_line_id     VARCHAR2(100)  DEFAULT NULL;
    p_ic_order_type_id     VARCHAR2(100)  DEFAULT NULL;
    p_ic_sell_oper_unit    VARCHAR2(100)  DEFAULT NULL;
    p_fb_flex_seg          VARCHAR2(2000);
    p_fb_error_msg         VARCHAR2(2000);
    p_ic_organization_cogs NUMBER;
    p_ic_items_cogs        NUMBER;
    p_ic_order_type_cogs   NUMBER;
    p_ic_structure_id      NUMBER;
  BEGIN
    IF (funcmode = 'RUN') THEN
      -- call flexbuilder build here
      -- then load segments and etc

      -- now copy attributes to local variables to pass to build function
      p_ic_customer_id        := wf_engine.getitemattrtext(itemtype => 'INVFLXWF', itemkey => itemkey, aname => 'IC_CUSTOMER_ID');
      p_ic_item_id            := wf_engine.getitemattrtext(itemtype => 'INVFLXWF', itemkey => itemkey, aname => 'IC_ITEM_ID');
      p_ic_order_header_id    := wf_engine.getitemattrtext(itemtype => 'INVFLXWF', itemkey => itemkey, aname => 'IC_ORDER_HEADER_ID');
      p_ic_order_line_id      := wf_engine.getitemattrtext(itemtype => 'INVFLXWF', itemkey => itemkey, aname => 'IC_ORDER_LINE_ID');
      p_ic_order_type_id      := wf_engine.getitemattrtext(itemtype => 'INVFLXWF', itemkey => itemkey, aname => 'IC_ORDER_TYPE_ID');
      p_ic_sell_oper_unit     := wf_engine.getitemattrtext(itemtype => 'INVFLXWF', itemkey => itemkey, aname => 'IC_SELL_OPER_UNIT');
      p_ic_items_cogs         := wf_engine.getitemattrnumber(itemtype => 'INVFLXWF', itemkey => itemkey, aname => 'IC_ITEMS_COGS');
      p_ic_organization_cogs  := wf_engine.getitemattrnumber(itemtype => 'INVFLXWF', itemkey => itemkey, aname => 'IC_ORGANIZATION_COGS');
      p_ic_order_type_cogs    := wf_engine.getitemattrnumber(itemtype => 'INVFLXWF', itemkey => itemkey, aname => 'IC_ORDER_TYPE_COGS');
      p_ic_structure_id       := wf_engine.getitemattrnumber(itemtype => 'INVFLXWF', itemkey => itemkey, aname => 'CHART_OF_ACCOUNTS_ID');
      build_success           :=
        inv_intercompany_cogs.BUILD(
          fb_flex_num                  => p_ic_structure_id
        , ic_customer_id               => p_ic_customer_id
        , ic_item_id                   => p_ic_item_id
        , ic_order_header_id           => p_ic_order_header_id
        , ic_order_line_id             => p_ic_order_line_id
        , ic_order_type_id             => p_ic_order_type_id
        , ic_sell_oper_unit            => p_ic_sell_oper_unit
        , fb_flex_seg                  => p_fb_flex_seg
        , fb_error_msg                 => p_fb_error_msg
        );
      -- Now load segment s into workflow attrubutes
      fnd_flex_workflow.load_concatenated_segments(itemtype => itemtype, itemkey => itemkey, concat_segs => p_fb_flex_seg);

      IF (NOT build_success) THEN
        RESULT  := 'COMPLETE:FAILURE';
        wf_engine.setitemattrtext(itemtype => 'INVFLXWF', itemkey => itemkey, aname => 'ERROR_MESSAGE', avalue => p_fb_error_msg);
        RETURN;
      ELSE
        RESULT  := 'COMPLETE:SUCCESS';
        RETURN;
      END IF;
    END IF;

    IF (funcmode = 'CANCEL') THEN
      RESULT  := 'COMPLETE';
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      wf_core.CONTEXT('INV_WORKFLOW', 'INVOKE_BUILD', itemtype, itemkey, TO_CHAR(actid), funcmode);
      RAISE;
  END invoke_build;
END inv_workflow;

/
