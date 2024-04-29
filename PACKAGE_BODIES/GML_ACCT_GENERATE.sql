--------------------------------------------------------
--  DDL for Package Body GML_ACCT_GENERATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GML_ACCT_GENERATE" AS
/* $Header: GMLACTGB.pls 115.6 2003/12/09 18:01:10 uphadtar noship $ */

   -- global variables
   g_location   VARCHAR2(255) := NULL;
   g_debug      VARCHAR2(10)  := NVL(fnd_profile.value('GML_PO_LOG'),'0');

--  /*************************************************************************
--  # PROC
--  #     PrintLine
--  #
--  # INPUT PARAMETERS
--  #     string
--  # DESCRIPTION
--  #   Procedure to write the debug log.
--  #
--  #
--  #**************************************************************************/
  PROCEDURE PrintLn( p_msg  IN  VARCHAR2 ) IS

        CURSOR get_log_file_location IS
        SELECT NVL( SUBSTR( value, 1, instr( value, ',')-1), value)
        FROM   v$parameter
        WHERE  name = 'utl_file_dir';


        l_log                UTL_FILE.file_type;
        l_file_name          VARCHAR2(80);

  BEGIN

        /* always write to GMLPOLOG */
        l_file_name := 'GMLPOLOG';

        IF (g_debug <> '1') THEN
           RETURN;
        ELSE
           -- file name is GMLPOLOG.userid
           l_file_name := l_file_name||'.'||FND_GLOBAL.user_id;

          IF g_location  is NULL THEN
            OPEN   get_log_file_location;
            FETCH  get_log_file_location into g_location;
            CLOSE  get_log_file_location;
          END IF;

           l_log := UTL_FILE.fopen(g_location, l_file_name, 'a');
           IF UTL_FILE.IS_OPEN(l_log) THEN
              UTL_FILE.put_line(l_log, p_msg);
              UTL_FILE.fflush(l_log);
              UTL_FILE.fclose(l_log);
           END IF;
        END IF;

    EXCEPTION

            WHEN OTHERS THEN
                NULL;

  END PrintLn;

--  /*************************************************************************
--  # PROC
--  #     initialize_variables
--  #
--  # INPUT PARAMETERS
--  #
--  # DESCRIPTION
--  #   Initialize Package variables
--  #
--  #
--  #**************************************************************************/
  PROCEDURE  initialize_variables as
  BEGIN

  /* Initialize Package Variables.*/
  P_itemglclass                 := NULL;
  P_acctg_unit_id               := NULL;
  P_base_currency               := NULL;
  P_vend_gl_class               := NULL;
  P_whse_co_code                := NULL;
  P_whse_orgn_code              := NULL;
  P_cust_id                     := NULL;
  P_reason_code                 := NULL;
  P_cust_gl_class               := NULL;
  P_routing_id                  := NULL;
  P_charge_id                   := NULL;
  P_taxauth_id                  := NULL;
  P_aqui_cost_id                := NULL;
  P_resources                   := NULL;
  P_order_type                  := NULL;
  P_shipvend_id                 := NULL;
  P_to_whse                     := NULL;
  P_item_no                     := NULL;
  P_gl_item_id                  := NULL;
  P_acct_id                     := NULL;
  P_acctg_unit_no               := NULL;
  P_acct_no                     := NULL;
  P_acct_desc                   := NULL;
  P_acct_ttl_num                := NULL;
  P_cc_id                       := NULL;
  P_gl_business_class_cat_id    := NULL; /* B2312653 RVK */
  P_gl_product_line_cat_id      := NULL; /* B2312653 RVK */

  END;

--/*************************************************************************
--# PROC
--#     generate_opm_acct
--#
--# INPUT PARAMETERS
--#   v_destination_type VARCHAR2 . It can be 'INVENTORY', 'EXPENSE', 'ACCRUAL'
--#   v_inv_item_type VARCHAR2. For Inventory destination type values can be
--#     either 'ASSET' or 'EXPENSE'. NULL for other destination types.
--#   v_subinv_type VARCHAR2. For Inventory destination type values can be
--#     either 'ASSET' or 'EXPENSE'. NULL for other destination types.
--#   v_dest_org_id VARCHAR2. Apps organization id which is shipment org. id.
--#   v_apps_item_id NUMBER. Application Item Id.
--#   v_vendor_site_id NUMBER. Vendor site id on the Purchase order
--#
--# IN OUT PARAMETERS
--#   v_cc_id NUMBER. Code combination id returned for OPM account.
--#
--# DESCRIPTION
--#   This procedure is called from the workflow functions to retrive the code
--#   combination id for the OPM account. This is a wrapper procedure for main
--#   procedure get_opm_account.
--#
--#**************************************************************************/
PROCEDURE  generate_opm_acct(v_destination_type  VARCHAR2,
                                v_inv_item_type VARCHAR2, v_subinv_type VARCHAR2
,
                                v_dest_org_id NUMBER, v_apps_item_id NUMBER,
                                v_vendor_site_id NUMBER,
                                v_cc_id IN OUT NOCOPY NUMBER) AS
        x_opm_account_type      VARCHAR2(10) := NULL;
        x_retcode               NUMBER := 0;
BEGIN

        PrintLn('/**************************************/');
        PrintLn('begin of generate_opm_acct');
        PrintLn('v_destination_type = '||v_destination_type);
        PrintLn('v_inv_item_type = '||v_inv_item_type);
        PrintLn('v_subinv_type = '||v_subinv_type);
        PrintLn('v_dest_org_id = '||v_dest_org_id);
        PrintLn('v_apps_item_id = '||v_apps_item_id);
        PrintLn('v_vendor_site_id = '||v_vendor_site_id);

        PrintLn('calling get_opm_account_type');

        /* Get OPM Account type. 'INVENTORY','EXPENSE' or 'ACCRUAL' */
        GML_ACCT_GENERATE.get_opm_account_type(v_destination_type, v_inv_item_type,v_subinv_type,
                                x_opm_account_type);

        PrintLn('finished calling get_opm_account_type, x_opm_account_type = '||x_opm_account_type);

        If (x_opm_account_type is null ) then
                v_cc_id := NULL;
                return;
        end if;

        /* Initialize global variables */
        initialize_variables;

        PrintLn('calling get_opm_account');

        /* Get code combination id for OPM account */
        GML_ACCT_GENERATE.get_opm_account(v_dest_org_id, v_apps_item_id, v_vendor_site_id,
                        x_opm_account_type, x_retcode);

        PrintLn('finished calling get_opm_account');
        PrintLn('x_retcode = '||to_char(x_retcode));

        If x_retcode = 0
        then
                v_cc_id := P_cc_id;
        else
                v_cc_id := NULL;
        end if;

        PrintLn('v_cc_id = '||to_char(v_cc_id));
        PrintLn('end of generate_opm_acct');

END generate_opm_acct;


--/*************************************************************************
--# PROC
--#     get_opm_account
--#
--# INPUT PARAMETERS
--#   v_dest_org_id VARCHAR2. Apps organization id which is shipment org. id.
--#   v_apps_item_id NUMBER. Application Item Id.
--#   v_vendor_site_id NUMBER. Vendor site id on the Purchase order
--#   v_opm_account_type VARCHAR2 . It can be 'INVENTORY', 'EXPENSE', 'ACCRUAL'
--#
--# IN OUT PARAMETERS
--#   retcode NUMBER. SUCCESS = 0 ; ERROR otherwise.
--#
--# DESCRIPTION
--#   Main routine for getting code combination id. Called from generate_opm_acct
--#
--#**************************************************************************/
PROCEDURE get_opm_account(v_dest_org_id NUMBER, v_apps_item_id NUMBER,
                          v_vendor_site_id NUMBER, v_opm_account_type VARCHAR2,
                          retcode IN OUT NOCOPY NUMBER) AS
  x_base_currency           gl_curr_mst.CURRENCY_CODE%TYPE;
  x_item_gl_class                ic_item_mst.GL_CLASS%TYPE;
  x_vend_gl_class           po_vend_mst.VENDGL_CLASS%TYPE;
  x_whse_co_code            sy_orgn_mst.co_code%TYPE;
  x_whse_orgn_code          sy_orgn_mst.orgn_code%TYPE;
  x_shipvend_id             NUMBER;
  x_item_no                 ic_item_mst.item_no%TYPE;
  x_gl_item_id              ic_item_mst.item_id%TYPE;
  x_to_whse                 ic_whse_mst.whse_code%TYPE;

Cursor cur_opm_item IS
 Select mst.item_no , mst.item_id, mst.gl_class
 from ic_item_mst mst, mtl_system_items mtl
 where mtl.inventory_item_id = v_apps_item_id and
        mtl.organization_id = v_dest_org_id and
        mtl.segment1 = mst.item_no;

Cursor cur_opm_orgn IS
 Select mst.co_code, whse.orgn_code, whse.whse_code
 from sy_orgn_mst mst, ic_whse_mst whse
 where whse.MTL_ORGANIZATION_ID = v_dest_org_id and
        whse.orgn_code = mst.orgn_code  ;

Cursor cur_base_curr is
 Select plcy.base_currency_code
 from sy_orgn_mst orgn, gl_plcy_mst plcy
 where orgn.orgn_code = x_whse_orgn_code and orgn.co_code = plcy.co_code;

Cursor cur_opm_vend is
 Select vendor_id, vendgl_class from po_vend_mst
 where of_vendor_site_id = v_vendor_site_id;

/* Bug 2312653 RVK */
Cursor category_ids(p_item_id ic_item_mst.item_id%TYPE)
        IS
                SELECT gic.item_id, gcs.opm_class, gic.category_id
                  FROM gmi_category_sets gcs, gmi_item_categories gic
                 WHERE gic.item_id = p_item_id
                   AND gic.category_set_id = gcs.category_set_id
                   AND gcs.category_set_id IS NOT NULL
                   AND gcs.opm_class in ('GL_BUSINESS_CLASS', 'GL_PRODUCT_LINE');

x_gltitles number ;

BEGIN

        PrintLn('begin of get_opm_account');

        Open cur_opm_item;
        Fetch cur_opm_item into x_item_no, x_gl_item_id, x_item_gl_class;
        Close cur_opm_item;

        Open cur_opm_orgn;
        Fetch cur_opm_orgn into x_whse_co_code, x_whse_orgn_code, x_to_whse;
        Close cur_opm_orgn;

        Open cur_base_curr;
        Fetch cur_base_curr into x_base_currency;
        Close cur_base_curr;

        Open cur_opm_vend;
        Fetch cur_opm_vend into x_shipvend_id, x_vend_gl_class;
        Close cur_opm_vend;

        P_item_no       := x_item_no;
        P_gl_item_id    := x_gl_item_id;
        P_itemglclass   := x_item_gl_class;
        P_whse_co_code  := x_whse_co_code;
        P_whse_orgn_code := x_whse_orgn_code;
        P_to_whse       := x_to_whse;
        P_base_currency := x_base_currency;
        P_shipvend_id   := x_shipvend_id;
        P_vend_gl_class := x_vend_gl_class;

        /* Bug 2312653  RVK */
        IF x_gl_item_id > 0 THEN
                FOR cur_category_ids in category_ids(x_gl_item_id)
                LOOP
                        IF cur_category_ids.opm_class = 'GL_BUSINESS_CLASS' THEN
                               P_gl_business_class_cat_id := cur_category_ids.category_id;
                        ELSIF cur_category_ids.opm_class = 'GL_PRODUCT_LINE' THEN
                               P_gl_product_line_cat_id := cur_category_ids.category_id;
                        END IF;
                END LOOP;
        ELSE
                P_gl_business_class_cat_id := NULL;
                P_gl_product_line_cat_id   := NULL;
        END IF;
        /* End Bug 2312653 */

        PrintLn('calling get_acct_title');

        /* Get account title number for the OPM account type */
        GML_ACCT_GENERATE.get_acct_title (v_opm_account_type,
                        x_gltitles);

        PrintLn('finished calling get_acct_title');
        PrintLn('account title number(X_gltitles) = '||to_char(X_gltitles));

        P_acct_ttl_num        := X_gltitles;
        P_cost_cmpntcls_id    := NULL;
        P_cost_analysis_code  := NULL;

        PrintLn('calling process_trans');

        /* Process for the OPM account */
        GML_ACCT_GENERATE.process_trans (retcode);

        PrintLn('finished calling process_trans');
        PrintLn('end of get_opm_account');

EXCEPTION
        WHEN OTHERS THEN
                retcode := 1;
END get_opm_account;


--/*************************************************************************
--# PROC
--#     get_opm_account_type
--#
--# INPUT PARAMETERS
--#   v_destination_type VARCHAR2 . It can be 'INVENTORY', 'EXPENSE', 'ACCRUAL'
--#   v_inv_item_type VARCHAR2. For Inventory destination type values can be
--#     either 'ASSET' or 'EXPENSE'. NULL for other destination types.
--#   v_subinv_type VARCHAR2. For Inventory destination type values can be
--#     either 'ASSET' or 'EXPENSE'. NULL for other destination types.
--#
--# OUT PARAMETERS
--#   v_opm_account_type VARCHAR2 . It can be 'INVENTORY', 'EXPENSE', 'ACCRUAL'
--#
--# DESCRIPTION
--#   Determines OPM account type for the inputs from the workflow destination types.
--#
--#**************************************************************************/
PROCEDURE get_opm_account_type(v_destination_type VARCHAR2,
                                v_inv_item_type VARCHAR2, v_subinv_type VARCHAR2,
                                v_opm_account_type OUT NOCOPY VARCHAR2) AS
BEGIN
        if (v_destination_type = 'INVENTORY')
        then
                if (v_inv_item_type = 'EXPENSE') then
                        v_opm_account_type := 'EXPENSE';
                elsif (v_inv_item_type = 'ASSET') then
                        if (v_subinv_type = 'ASSET' or v_subinv_type is null)
                        then
                                v_opm_account_type := 'INVENTORY';
                        elsif (v_subinv_type = 'EXPENSE') then
                                v_opm_account_type := 'EXPENSE';
                        end if;
                end if;
        elsif (v_destination_type = 'EXPENSE') then
                v_opm_account_type := 'EXPENSE';
        elsif (v_destination_type = 'ACCRUAL') then
                v_opm_account_type := 'ACCRUAL';
        end if;

END get_opm_account_type;

--  /*************************************************************************
--  # PROC
--  #     process_trans
--  #
--  # INPUT PARAMETERS
--  #
--  # IN OUT PARAMETERS
--  #   retcode NUMBER. SUCCESS = 0 , ERROR otherwise
--  # DESCRIPTION
--  #   Calls the functions to get Account and Accounting Unit. Also calls set_data
--  #   procedure which calls a routine to get a code combination id fro this account.
--  #
--  #**************************************************************************/

  PROCEDURE  process_trans (retcode IN OUT NOCOPY NUMBER) AS
  BEGIN
    P_acct_id        :=  GML_ACCT_GENERATE.default_mapping               ;
    P_acctg_unit_no  :=  GML_ACCT_GENERATE.get_acctg_unit_no             ;
    GML_ACCT_GENERATE.get_acct_no (P_acct_no, P_acct_desc );

    PrintLn('P_acct_id = '||to_char(P_acct_id));
    PrintLn('P_acctg_unit_no = '||P_acctg_unit_no);
    PrintLn('P_acct_no = '||P_acct_no);
    PrintLn('P_acct_desc = '||P_acct_desc);
    PrintLn('calling set_data');

    GML_ACCT_GENERATE.set_data (retcode);

    PrintLn('finished calling set_data');
  END process_trans;

--  /*##########################################################################
--  # PROC
--  #  default_mapping
--  #
--  # INPUT PARAMETERS
--  #   Package Variables are passed to the fuction
--  # RETURNS
--  #   < 0 - Mapping failed
--  #   > 0 - Mapping Successful. Account id.
--  # DESCRIPTION
--  #  This function calls central account mapping routine to determine the account
--  #  based on the Account mapping for Company, Account Title and other set of
--  #  attributes.
--  #
--  #########################################################################*/

  FUNCTION default_mapping RETURN NUMBER AS
  BEGIN
    gmf_get_mappings.get_account_mappings (
                V_CO_CODE                =>   P_whse_co_code,
                V_ORGN_CODE              =>   P_whse_orgn_code,
                V_WHSE_CODE              =>   P_to_whse,
                V_ITEM_ID                =>   P_gl_item_id,
                V_VENDOR_ID              =>   P_shipvend_id,
                V_CUST_ID                =>   P_cust_id,
                V_REASON_CODE            =>   P_reason_code,
                V_ICGL_CLASS             =>   P_itemglclass,
                V_VENDGL_CLASS           =>   P_vend_gl_class,
                V_CUSTGL_CLASS           =>   P_cust_gl_class,
                V_CURRENCY_CODE          =>   P_base_currency,
                V_ROUTING_ID             =>   P_routing_id,
                V_CHARGE_ID              =>   P_charge_id,
                V_TAXAUTH_ID             =>   P_taxauth_id,
                V_AQUI_COST_ID           =>   P_aqui_cost_id,
                V_RESOURCES              =>   P_resources,
                V_COST_CMPNTCLS_ID       =>   P_cost_cmpntcls_id,
                V_COST_ANALYSIS_CODE     =>   P_cost_analysis_code,
                V_ORDER_TYPE             =>   P_order_type,
                V_SUB_EVENT_TYPE         =>   P_sub_event_type,
                V_SOURCE                 =>   0,
                V_BUSINESS_CLASS_CAT_ID  =>   P_gl_business_class_cat_id,
                V_PRODUCT_LINE_CAT_ID    =>   P_gl_product_line_cat_id  );
     P_acct_id  :=  gmf_get_mappings.get_account_value (P_acct_ttl_num );
     RETURN (P_acct_id );

  END default_mapping;

--  /*##########################################################################
--  # PROC
--  #   get_acctg_unit_no
--  #
--  # INPUT PARAMETERS
--  #   Package Variables are passed to the Function
--  # RETURNS
--  #   If success, returns acctg_unit_no ELSE null.
--  # DESCRIPTION
--  #  This function determines the accounting unit
--  #  based on the Accounting Unit mapping for Company, Organization , Warehouse
--  #  attributes.
--  ############################################################################*/
--
  FUNCTION get_acctg_unit_no  RETURN VARCHAR2 AS

    CURSOR Cur_acctg_unit_id (vc_orgn_code VARCHAR2) IS
      SELECT  acctg_unit_id
        FROM  gl_accu_map
       WHERE  co_code = P_whse_co_code and
                         (orgn_code = vc_orgn_code or orgn_code IS NULL) and
             (whse_code = P_to_whse or whse_code IS NULL) and
             delete_mark = 0
             order by nvl(orgn_code, ' ') desc, nvl(whse_code, ' ') desc;

    CURSOR Cur_acctg_unit_no  IS
      SELECT  acctg_unit_no
          FROM  gl_accu_mst
       WHERE  acctg_unit_id = P_acctg_unit_id;

  BEGIN

    OPEN    Cur_acctg_unit_id (P_whse_orgn_code);
    FETCH  Cur_acctg_unit_id  INTO  P_acctg_unit_id;
    CLOSE Cur_acctg_unit_id;

    OPEN    Cur_acctg_unit_no;
    FETCH  Cur_acctg_unit_no  INTO  P_acctg_unit_no;
    CLOSE  Cur_acctg_unit_no;
    RETURN ( P_acctg_unit_no );

  END get_acctg_unit_no;

--  /*##########################################################################
--  # PROC
--  #  get_acct_no
--  #
--  # INPUT PARAMETERS
--  #   Package variables are passed to the procedure
--  # DESCRIPTION
--  #   This procedure returns the corresponding Account no. and Account desc
--  #   based on the P_acct_id
--  ##########################################################################*/

  PROCEDURE get_acct_no(V_acct_no OUT NOCOPY VARCHAR2, V_acct_desc OUT NOCOPY VARCHAR2) AS

    CURSOR Cur_acct_no  IS
      SELECT  acct_no, acct_desc
        FROM  gl_acct_mst
       WHERE  acct_id= P_acct_id;

  BEGIN
    OPEN   Cur_acct_no;
    FETCH  Cur_acct_no INTO V_acct_no, V_acct_desc;
    CLOSE  Cur_acct_no;

  END get_acct_no;

--  /*############################################################################
--  #
--  #  PROC
--  #    set_data
--  #  IN OUT PARAMETERS
--  #    retcode NUMBER. 0 for SUCCESS, ERROR otherwiese
--  #
--  # DESCRIPTION
--  #     This procedure would set data for getting the code combination id. It returns
--  #     to process trans procedure if P_acct_id or P_acctg_unit_id is null with
--  #     retcode other than 0. Calls gen_combination_id routine.
--  ##############################################################################*/

  PROCEDURE set_data(retcode IN OUT NOCOPY NUMBER) AS

    X_combination_id    NUMBER;

  BEGIN
    PrintLn('begin of set_data');

    IF (GML_ACCT_GENERATE.P_acct_id IS NULL OR GML_ACCT_GENERATE.P_acct_id = -1) THEN
      retcode := 1;
    ELSIF GML_ACCT_GENERATE.P_acctg_unit_id IS NULL THEN
      retcode := 2;
    END IF;

  IF retcode >0 THEN
     RETURN;
  END IF;

  PrintLn('calling gen_combination_id');

  GML_ACCT_GENERATE.gen_combination_id( GML_ACCT_GENERATE.P_whse_co_code,
                                GML_ACCT_GENERATE.P_acct_id,
                                GML_ACCT_GENERATE.P_acctg_unit_id,
                                X_combination_id);

  PrintLn('finished calling gen_combination_id');
  PrintLn('X_combination_id = '||to_char(X_combination_id));

  P_cc_id := X_combination_id;

  PrintLn('end of set_data');

  EXCEPTION
      WHEN OTHERS THEN
        retcode := 1;

  END set_data;

--  /*############################################################################
--  #
--  #  PROC
--  #  get_acct_title
--  #
--  # INPUT PARAMETERS
--  #   v_opm_account_type   VARCHAR2
--  # OUTPUT PARAMETERS
--  #   v_gltitle
--  #
--  # DESCRIPTION:           Determine which acct_ttl to be derived based on the
--  #                        v_opm_account_type passed to it.
--  ##############################################################################  */
 PROCEDURE get_acct_title(
                        v_opm_account_type VARCHAR2,
                        v_gltitles OUT NOCOPY NUMBER
                        ) AS

    x_at_inv          NUMBER :=  1500;
    x_at_aap          NUMBER :=  3100;
    x_at_ppv          NUMBER :=  6100;
    x_at_exp          NUMBER :=  5100;

  BEGIN

      IF v_opm_account_type = 'EXPENSE' THEN
        v_gltitles := x_at_exp;
      ELSIF (v_opm_account_type = 'INVENTORY') THEN
        v_gltitles := x_at_inv;
      ELSIF (v_opm_account_type = 'ACCRUAL') THEN
        v_gltitles := x_at_aap;
      END IF;

  END get_acct_title;



 PROCEDURE gen_combination_id(  v_co_code               IN VARCHAR2,
                                v_acct_id               IN NUMBER,
                                v_acctg_unit_id         IN NUMBER,
                                v_combination_id        IN OUT NOCOPY NUMBER) AS

 x_acctg_unit_no                gl_accu_mst.acctg_unit_no%TYPE  := NULL;
 x_acct_no                      gl_acct_mst.acct_no%TYPE        := NULL;
 x_application_short_name       VARCHAR2(50);
 x_key_flex_code                VARCHAR2(50);
 x_chart_of_account_id          NUMBER;
 x_validation_date              DATE;
 x_segment_count                NUMBER;
 x_of_seg                       fnd_flex_ext.SegmentArray;
 x_ret                          BOOLEAN;
 x_segment_delimiter            gl_plcy_mst.segment_delimiter%TYPE;


 Cursor get_chart_id is
  select chart_of_accounts_id
  from gl_plcy_mst,gl_sets_of_books
  where         co_code = v_co_code
  and   name like set_of_books_name
  and   set_of_books_id = sob_id;

 BEGIN

        PrintLn('begin of gen_combination_id');

        SELECT acctg_unit_no INTO x_acctg_unit_no
        FROM gl_accu_mst WHERE acctg_unit_id = p_acctg_unit_id;

        SELECT acct_no INTO x_acct_no
        FROM gl_acct_mst
        WHERE acct_id = p_acct_id;

        SELECT segment_delimiter INTO x_segment_delimiter
        FROM  gl_plcy_mst
        WHERE co_code = v_co_code
          AND delete_mark = 0;

        PrintLn('calling parse_account');

        /* Parse the OPM account to set the of segments based on the segment
           mapping of OPM and Oracle Financials */
        GML_ACCT_GENERATE.parse_account(        v_co_code ,
                        x_acctg_unit_no ||x_segment_delimiter|| x_acct_no,
                        2,0, x_of_seg, x_segment_count ) ;

        PrintLn('finished calling parse_account');

                                /* structure_no */
        Open get_chart_id;
        Fetch   get_chart_id into x_chart_of_account_id;
        Close get_chart_id;

        x_application_short_name        := 'SQLGL';
        x_key_flex_code                 := 'GL#';
        x_validation_date               := SYSDATE;

        PrintLn('calling get_combination_id');

        /* Call the apps routine to get the CC id */
        x_ret := fnd_flex_ext.get_combination_id(x_application_short_name,
                                                x_key_flex_code,
                                                x_chart_of_account_id,
                                                x_validation_date,
                                                x_segment_count,
                                                x_of_seg,
                                                v_combination_id );

        PrintLn('finished calling get_combination_id');
        IF  x_ret = TRUE THEN
            PrintLn('fnd_flex_ext.get_combination_id returns TRUE');
        ELSE
            PrintLn('fnd_flex_ext.get_combination_id returns FALSE');
        END IF;

        PrintLn('v_combination_id = '||to_char(v_combination_id));
        PrintLn('end of gen_combination_id');

 END gen_combination_id;



-- /*############################################################################
-- #  FUNCTION
-- #    parse_account
-- #  DESCRIPTION
-- #    Parses the gemms account string and sorts the segment according
-- #    to the order defined in Oracle financials.
-- #
-- #   INPUT PARAMETERS
-- #      v_co_code     OPM Company
-- #      v_account    = Account string to be parsed
-- #      v_type       = 0 Parses Account unit segments
-- #                   = 1 Parses Account Segments
-- #                   = 2 Parses both Account unit and Account segments
-- #      v_offset     = Offset value.
-- #      v_segment     Segment array of type fnd_flex_ext.SegmentArray.
-- #      V_no_of_seg   Total no. of segments.
-- #
-- #    OUTPUT PARAMETERS
-- #     GLOBAL
-- #
-- #  RETURNS
-- #
-- #
-- #  Uday Phadtare 12/08/2003 Bug 3299321. Cursor cur_plcy_seg modified.
-- ############################################################################  */

  PROCEDURE parse_account(      v_co_code IN VARCHAR2,
                                v_account IN VARCHAR2,
                                v_type IN NUMBER,
                                v_offset IN NUMBER,
                                v_segment IN OUT NOCOPY fnd_flex_ext.SegmentArray,
                                V_no_of_seg IN OUT NOCOPY NUMBER )
  AS
   /** MC BUG# 2395971**/
-- change the select column segment_ref from
-- nvl(substrb(f.application_column_name,8),0) to f.segment_num

    CURSOR cur_plcy_seg IS
      SELECT p.type, p.length,
             --nvl(substrb(f.application_column_name,8),0) segment_ref,
             --f.segment_num segment_ref,      Bug 3299321
             p.segment_no segment_ref,
                pm.segment_delimiter
        FROM    gl_plcy_seg p,
                gl_plcy_mst pm,
                fnd_id_flex_segments f,
                gl_sets_of_books s
       WHERE p.co_code = v_co_code
          AND   p.delete_mark = 0
          AND   p.co_code = pm.co_code
          AND   pm.sob_id = s.set_of_books_id
          AND   s.chart_of_accounts_id = f.id_flex_num
          AND   f.application_id = 101
          AND   f.id_flex_code = 'GL#'
          AND   LOWER(f.segment_name)  = LOWER(p.short_name)
          AND   f.enabled_flag         = 'Y'
        --ORDER BY  p.segment_no ;     Bug 3299321
        ORDER BY  f.segment_num;

    x_segment_index    NUMBER(10) DEFAULT 0;
    x_value            NUMBER(10);
    x_index            NUMBER(10);
    x_position         NUMBER(10) DEFAULT 1;
    x_length           NUMBER(10);
    x_result           VARCHAR2(255);
    x_gemms_acct       VARCHAR2(255);
    x_description      VARCHAR2(1000) default '';
    source_accounts    gmf_get_mappings.my_opm_seg_values;
  BEGIN

    PrintLn('begin of parse_account');

    source_accounts := gmf_get_mappings.get_opm_segment_values(v_account,v_co_code,2);

    FOR cur_plcy_seg_tmp IN cur_plcy_seg LOOP
      x_segment_index := x_segment_index + 1;
      IF (cur_plcy_seg_tmp.type = v_type or v_type = 2) THEN
        IF (cur_plcy_seg_tmp.segment_ref = 0) THEN
          x_value := x_segment_index;
        ELSE
          x_value := cur_plcy_seg_tmp.segment_ref;
        END IF;
        x_index  := x_value + v_offset;
        -- v_segment(x_index) := source_accounts(x_position);   Bug 3299321
        v_segment(x_position) := source_accounts(x_index);

        PrintLn('v_segment['||to_char(x_position)||']' ||v_segment(x_position));

        x_position := x_position + 1;
      END IF;
    END LOOP;

    v_no_of_seg := x_segment_index;

    PrintLn('end of parse_account');

  END parse_account;

END GML_ACCT_GENERATE;

/
