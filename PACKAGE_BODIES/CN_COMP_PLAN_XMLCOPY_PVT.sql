--------------------------------------------------------
--  DDL for Package Body CN_COMP_PLAN_XMLCOPY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_COMP_PLAN_XMLCOPY_PVT" AS
/*$Header: cnvcpxmlb.pls 120.36.12010000.4 2009/09/01 04:14:19 scannane ship $*/

 G_PKG_NAME       CONSTANT VARCHAR2(30) := 'CN_COMP_PLAN_XMLCOPY_PVT';
 G_FILE_NAME      CONSTANT VARCHAR2(15) := 'cnvcpxmlb.pls';

/****************************************************************************/
--  Import_PlanCopy Procedure - This Procedure is just a wrapper around
--  the Parse_XML Procedure. This Procedure does following things
--  1. It validates the XML.
--  2. Gets prefix, start_date and end_date information
--  3. Pass this information to Parse_XML Procedure.
--  4. Gets the status of Import from Parse_XML and updates cn_copy_requests.
/***************************************************************************/
PROCEDURE Import_PlanCopy
  (errbuf               OUT NOCOPY VARCHAR2,
   retcode              OUT NOCOPY NUMBER,
   p_exp_imp_request_id IN cn_copy_requests_all.exp_imp_request_id%TYPE) IS

   CURSOR oic_plan_copy IS
     SELECT extract(value(v),'/OIC_PLAN_COPY') "CP"
       FROM cn_copy_requests_all cr,
            TABLE(XMLSequence(extract(cr.file_content_xmltype,'/OIC_PLAN_COPY'))) v
      WHERE cr.exp_imp_request_id = p_exp_imp_request_id;

   CURSOR oic_object_count IS
     SELECT COUNT(extract(value(v),'/CnCompPlansVO'))
       FROM cn_copy_requests_all cr,
            TABLE(XMLSequence(extract(cr.file_content_xmltype,'/OIC_PLAN_COPY/CnCompPlansVO'))) v
      WHERE cr.exp_imp_request_id = p_exp_imp_request_id;

   v_prefix         cn_copy_requests_all.prefix_info%TYPE;
   v_xml            cn_copy_requests_all.file_content_xmltype%TYPE;
   v_org_id         cn_copy_requests_all.org_id%TYPE;
   v_object_count   NUMBER;
   v_start_date     DATE;
   v_end_date       DATE;
   l_msgs           VARCHAR2(2000);
   l_err_message    VARCHAR2(2000);
   x_import_status  VARCHAR2(30);
   l_api_name       CONSTANT VARCHAR2(30) := 'Import_PlanCopy';
   x_return_status  VARCHAR2(1);
   x_msg_count      NUMBER;
   x_msg_data       VARCHAR2(240);

BEGIN
     fnd_file.put_line(fnd_file.log, '**************************************************************');
     fnd_file.put_line(fnd_file.log, '******************* START - PLAN COPY IMPORT *****************');
     fnd_file.put_line(fnd_file.log, '**************************************************************');

   -- Standard Start of API savepoint
   SAVEPOINT   Import_PlanCopy;
   retcode := 0;

   -- Get Prefix and Date Information
   SELECT prefix_info, change_start_date, change_end_date, org_id INTO v_prefix, v_start_date, v_end_date, v_org_id
     FROM cn_copy_requests_all
    WHERE exp_imp_request_id = p_exp_imp_request_id;

    -- Check if OrgId is not set
    IF v_org_id IS NULL THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

   -- Populating CLOB and XMLType Columns of cn_copy_requests_all
   -- Plan Copy Import Request only populates the BLOB column.
   -- Calling Common Utility Package for conversion to CLOB and XMLType
   cn_plancopy_util_pvt.convert_blob_to_xmltype (
                           p_api_version      =>  1.0,
                           p_init_msg_list    =>  FND_API.G_FALSE,
                           p_commit           =>  FND_API.G_FALSE,
                           p_validation_level =>  FND_API.G_VALID_LEVEL_FULL,
                           p_exp_imp_id	      =>  p_exp_imp_request_id,
                           x_return_status    =>  x_return_status,
                           x_msg_count        =>  x_msg_count,
                           x_msg_data         =>  x_msg_data);
   IF x_return_status = fnd_api.g_ret_sts_success THEN
      COMMIT;
   ELSE
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   -- Fetching XML from XMLType.
   OPEN oic_plan_copy;
   FETCH oic_plan_copy INTO v_xml;
   CLOSE oic_plan_copy;

    -- Count total number of objects to copy
   OPEN oic_object_count;
   FETCH oic_object_count INTO v_object_count;
   CLOSE oic_object_count;

    -- Parse XML
    Parse_XML(p_api_version      =>  1.0,
             p_init_msg_list    =>  FND_API.G_FALSE,
             p_commit           =>  FND_API.G_FALSE,
             p_validation_level =>  FND_API.G_VALID_LEVEL_FULL,
             p_xml              =>  v_xml,
             p_prefix           =>  v_prefix,
             p_start_date       =>  v_start_date,
             p_end_date         =>  v_end_date,
             p_org_id           =>  v_org_id,
             p_object_count     =>  v_object_count,
             x_import_status    =>  x_import_status);

    -- Update the status of Import Process
    IF x_import_status = 'COMPLETED' THEN
       UPDATE cn_copy_requests_all
          SET status_code = 'COMPLETED',
              completion_date = SYSDATE
        WHERE exp_imp_request_id = p_exp_imp_request_id;
        COMMIT;
    ELSE
       UPDATE cn_copy_requests_all
          SET status_code = 'FAILED',
              completion_date = SYSDATE
        WHERE exp_imp_request_id = p_exp_imp_request_id;
       COMMIT;
    END IF;

  EXCEPTION
     WHEN fnd_api.g_exc_unexpected_error THEN
       ROLLBACK TO Import_PlanCopy;
       retcode := 2;
       errbuf := SQLCODE||' '||Sqlerrm;
       UPDATE cn_copy_requests_all
          SET status_code = 'FAILED',
              completion_date = SYSDATE
        WHERE exp_imp_request_id = p_exp_imp_request_id;
       COMMIT;
     WHEN OTHERS THEN
       retcode := 2;
       errbuf := SQLCODE||' '||Sqlerrm;
       UPDATE cn_copy_requests_all
          SET status_code = 'FAILED',
              completion_date = SYSDATE
        WHERE exp_imp_request_id = p_exp_imp_request_id;
       COMMIT;
END Import_PlanCopy;

/***************************************************************************/
-- Parse_XML - This Procedure parses the XML file.This procedure does following
-- 1. Parse each component of the compensation plan in the XML and
--    creates the component in the target system, if successful.
-- 2. Enters the failure and success information / messages in the
--    Log file of the request.
-- 3. Return the import process status back to Import_PlanCopy, which
--    updates cn_copy_requests table.
/***************************************************************************/
PROCEDURE Parse_XML
 (p_api_version                IN            NUMBER   := 1.0,
  p_init_msg_list              IN            VARCHAR2 := FND_API.G_FALSE,
  p_commit                     IN            VARCHAR2 := FND_API.G_FALSE,
  p_validation_level           IN            NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_xml                        IN            cn_copy_requests_all.file_content_xmltype%TYPE,
  p_prefix                     IN            cn_copy_requests_all.prefix_info%TYPE,
  p_start_date                 IN            DATE,
  p_end_date                   IN            DATE,
  p_org_id                     IN            cn_copy_requests_all.org_id%TYPE,
  p_object_count               IN            NUMBER,
  x_import_status              OUT NOCOPY    VARCHAR2)IS

  -- Table Record Declaration
  v_expression_rec             cn_calc_sql_exps%ROWTYPE;
  v_rate_dimension_rec         cn_rate_dimensions%ROWTYPE;
  v_rate_dim_tiers_tbl         cn_rate_dimensions_pvt.tiers_tbl_type := cn_rate_dimensions_pvt.g_miss_tiers_tbl;
  v_rate_table_rec             cn_rate_schedules%ROWTYPE;
  v_rate_sch_dims_tbl          cn_multi_rate_schedules_pvt.dims_tbl_type := cn_multi_rate_schedules_pvt.g_miss_dims_tbl;
  v_rate_tiers_tbl             cn_multi_rate_schedules_pvt.comm_tbl_type;
  v_formula_rec                cn_calc_formulas%ROWTYPE;
  v_input_exp_tbl              cn_calc_formulas_pvt.input_tbl_type := cn_calc_formulas_pvt.g_miss_input_tbl;
  v_rt_assign_tbl              cn_calc_formulas_pvt.rt_assign_tbl_type := cn_calc_formulas_pvt.g_miss_rt_assign_tbl;
  v_plan_element_rec           cn_plan_element_pub.plan_element_rec_type;
  v_revenue_class_tbl          cn_plan_element_pub.revenue_class_rec_tbl_type := cn_plan_element_pub.g_miss_revenue_class_rec_tbl;
  v_rev_uplift_tbl             cn_plan_element_pub.rev_uplift_rec_tbl_type := cn_plan_element_pub.g_miss_rev_uplift_rec_tbl;
  v_trx_factor_tbl             cn_plan_element_pub.trx_factor_rec_tbl_type := cn_plan_element_pub.g_miss_trx_factor_rec_tbl;
  v_rt_quota_asgns_tbl         cn_plan_element_pub.rt_quota_asgns_rec_tbl_type :=  cn_plan_element_pub.g_miss_rt_quota_asgns_rec_tbl;
  v_period_quotas_tbl          cn_plan_element_pub.period_quotas_rec_tbl_type :=  cn_plan_element_pub.g_miss_period_quotas_rec_tbl;
  v_comp_plan_rec              cn_comp_plan_pvt.comp_plan_rec_type;
  v_quota_assign_tbl           cn_quota_assign_pvt.quota_assign_tbl_type := cn_quota_assign_pvt.g_miss_quota_assign_rec_tb;
  TYPE v_rate_dim_exp_rec IS RECORD
  (min_exp_name                cn_calc_sql_exps.name%TYPE,
   max_exp_name                cn_calc_sql_exps.name%TYPE);
  TYPE v_rate_dim_exp_tbl IS TABLE OF v_rate_dim_exp_rec INDEX BY BINARY_INTEGER;
   g_miss_rate_dim_exp_tbl      v_rate_dim_exp_tbl;
  TYPE v_calc_edges_rec IS RECORD(
   calc_edge_id                cn_calc_edges.calc_edge_id%TYPE := NULL,
   edge_type                   cn_calc_edges.edge_type%TYPE,
   parent_id                   cn_calc_edges.parent_id%TYPE,
   child_id                    cn_calc_edges.child_id%TYPE,
   parent_name                 cn_calc_sql_exps.name%TYPE,
   child_name                  cn_calc_formulas.name%TYPE);
  TYPE v_calc_edges_tbl        IS TABLE OF v_calc_edges_rec INDEX BY BINARY_INTEGER;
   g_miss_calc_edges_tbl       v_calc_edges_tbl;
  -- XML Declaration
  v_doc                        dbms_xmldom.DOMDocument;
  v_node                       dbms_xmldom.DOMNode;
  v_parent_node                dbms_xmldom.DOMNode;
  v_parent_node_list           dbms_xmldom.DOMNodeList;
  v_parent_node_length         NUMBER;
  v_child_node                 dbms_xmldom.DOMNode;
  v_child_node_name            VARCHAR2(30);
  v_node_first_child           dbms_xmldom.DOMNode;
  v_child_node_element         dbms_xmldom.DOMElement;
  v_element_cast               dbms_xmldom.DOMElement;
  v_name_node                  dbms_xmldom.DOMNodeList;
  v_name_node_value            VARCHAR2(80);
  v_name_node_value_new        VARCHAR2(80);
  v_node_sibling_Next          dbms_xmldom.DOMNode;
  v_node_sibling_child_Next    dbms_xmldom.DOMNode;
  v_node_sibling_list_Next     dbms_xmldom.DOMNodeList;
  v_node_sibling_name_Next     VARCHAR2(30);
  v_node_sibling_length_Next   NUMBER;
  v_element_sibling_cast_Next  dbms_xmldom.DOMElement;
  v_node_sibling_Previous      dbms_xmldom.DOMNode;
  --Other Declaration
  l_api_version                NUMBER := 1.0;
  l_api_name                   CONSTANT VARCHAR2(30) := 'Parse_XML';
  l_rate_dimension_id          cn_rate_dimensions.rate_dimension_id%TYPE;
  l_rate_dim_tier_id           cn_rate_dim_tiers.rate_dim_tier_id%TYPE;
  l_rate_schedule_id           cn_rate_schedules.rate_schedule_id%TYPE;
  l_calc_formula_id            cn_calc_formulas.calc_formula_id%TYPE;
  l_calc_sql_exp_id            cn_calc_sql_exps.calc_sql_exp_id%TYPE;
  l_output_exp_name            cn_calc_sql_exps.name%TYPE;
  l_f_output_exp_name          cn_calc_sql_exps.name%TYPE;
  l_perf_measure_name          cn_calc_sql_exps.name%TYPE;
  l_comp_plan_id               cn_comp_plans.comp_plan_id%TYPE;
  l_quota_assign_id            cn_quota_assigns.quota_assign_id%TYPE;
  l_pmt_group_code             NUMBER;
  l_rev_class_name             cn_revenue_classes.name%TYPE;
  l_uplift_start_date          DATE;
  l_uplift_end_date            DATE;

  l_reuse_count                NUMBER;
  l_sql_fail_count             NUMBER;
  l_formula_name_count         NUMBER;
  l_exp_name_count             NUMBER;
  l_rev_class_name_count       NUMBER;
  l_crd_type_count             NUMBER;
  l_int_type_count             NUMBER;
  l_rate_schedule_name_count   NUMBER;
  l_rate_dim_name_count        NUMBER;
  l_pe_name_count              NUMBER;
  l_quota_asgn_count           NUMBER;
  l_rev_class_least_count      NUMBER;
  l_rt_fm_notexist_count       NUMBER;

  l_child_id                   cn_calc_formulas.calc_formula_id%TYPE;
  l_child_name                 cn_calc_formulas.name%TYPE;
  l_parent_name                cn_calc_sql_exps.name%TYPE;
  l_formula_pkg_source         VARCHAR2(30);
  l_formula_pkg_target         VARCHAR2(30);
  l_source_org_id              NUMBER;
  l_open                       NUMBER;
  l_close                      NUMBER;
  l_open_sql                   NUMBER;
  l_close_sql                  NUMBER;
  l_pe_mtrc_p_sql              VARCHAR2(30);
  l_pe_p_sql                   VARCHAR2(30);
  l_open_p_sql                 NUMBER;
  l_close_p_sql                NUMBER;
  l_quota_id                   cn_quotas.quota_id%TYPE;
  l_failed_plan_name           VARCHAR2(2000);
  l_formula_name_source        cn_calc_formulas.name%TYPE;
  l_pe_source_name             cn_quotas.name%TYPE;
  l_pe_num                     NUMBER := 0;
  l_pe_count                   NUMBER;
  l_ee_count                   NUMBER;
  l_pe_mtrc                    VARCHAR2(30);
  l_pe                         VARCHAR2(30);
  l_pe_mtrc_sql                VARCHAR2(30);
  l_pe_sql                     VARCHAR2(30);
  l_pe_exist                   BOOLEAN := TRUE;
  l_ee_tab_name                VARCHAR2(100);
  l_ee_tab_name_new            VARCHAr2(100);
  l_ee_alias                   NUMBER;
  l_ee_exist_obj_check         NUMBER;
  x_loading_status             VARCHAR2(30);
  x_object_version_number      NUMBER := 0;
  p_success_obj_count          NUMBER := 0;
  p_reuse_obj_count            NUMBER := 0;
  x_return_status              VARCHAR2(1);
  x_msg_count                  NUMBER;
  x_msg_data                   VARCHAR2(240);
  l_expense_acc_desc           VARCHAR2(100);
  l_liability_acc_desc         VARCHAR2(100);
  l_liab_account_id            NUMBER;
  l_expense_account_id         NUMBER;
  l_ee_piped_sql_from          CLOB;

  l_period_name                cn_period_statuses.period_name%TYPE;
  l_period_exist_count         NUMBER;
  l_period_end_date            DATE;
  l_exp_name_source            cn_calc_sql_exps.name%TYPE;

  TYPE v_pe_exp_rec IS RECORD
    (old_pe_name          cn_quotas.name%TYPE,
     new_pe_name          cn_quotas.name%TYPE,
     old_pe_id            cn_quotas.quota_id%TYPE,
     new_pe_id            cn_quotas.quota_id%TYPE);
  TYPE v_pe_exp_tbl IS TABLE OF v_pe_exp_rec INDEX BY BINARY_INTEGER;
  g_miss_pe_exp_rec       v_pe_exp_rec;
  g_miss_pe_exp_tbl       v_pe_exp_tbl;
  l_new_pe_name           cn_quotas.name%TYPE;
  l_pe_counter            NUMBER;

  CURSOR c_expense_account_id (p_exp_acc_desc VARCHAR2) IS
         SELECT code_combination_id
           FROM gl_sets_of_books glb, cn_repositories r, gl_code_combinations glc
          WHERE account_type = 'E'
            AND glb.chart_of_accounts_id = glc.chart_of_accounts_id
            AND r.set_of_books_id = glb.set_of_books_id
            AND SEGMENT1||'-'||SEGMENT2||'-'||SEGMENT3||'-'||SEGMENT4||'-'||SEGMENT5 = p_exp_acc_desc
            AND r.org_id = p_org_id;

  CURSOR c_liab_account_id (p_liab_acc_desc VARCHAR2) IS
         SELECT code_combination_id
           FROM gl_sets_of_books glb, cn_repositories r, gl_code_combinations glc
          WHERE account_type = 'L'
            AND glb.chart_of_accounts_id = glc.chart_of_accounts_id
            AND r.set_of_books_id = glb.set_of_books_id
            AND SEGMENT1||'-'||SEGMENT2||'-'||SEGMENT3||'-'||SEGMENT4||'-'||SEGMENT5 = p_liab_acc_desc
            AND r.org_id = p_org_id;

BEGIN
  /**********************************************************************/
  /*                      Standard API Checks                           */
  /**********************************************************************/
  -- Standard Start of API savepoint
  -- SAVEPOINT   Parse_XML;
  -- Standard call to check for call compatibility.
  IF NOT fnd_api.Compatible_API_Call(l_api_version,p_api_version,l_api_name,G_PKG_NAME )THEN
     RAISE fnd_api.g_exc_unexpected_error;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF fnd_api.to_Boolean( p_init_msg_list ) THEN
     fnd_msg_pub.initialize;
  END IF;

  -- Initialize the Import Status to 'FAILED'
  x_import_status := 'FAILED';
  /**********************************************************************/
  /*                      API Body - Start                              */
  /**********************************************************************/
  -- Create DOMDocument handle:
  v_doc := dbms_xmldom.newDOMDocument(p_xml);
  -- Create node from DOMDocument handle:
  v_node := dbms_xmldom.makeNode(v_doc);
  -- Get First Child (Parent Node) of the node
  v_parent_node := dbms_xmldom.getFirstChild(v_node);
  -- Get the length of parent node
  v_parent_node_length := dbms_xmldom.getLength(dbms_xmldom.getChildNodes(v_parent_node));
  -- Plan element Counter for Interdependent PE check in Expression
  l_pe_counter := 0;

  IF v_parent_node_length > 0 THEN
     v_parent_node_list := dbms_xmldom.getChildNodes(v_parent_node);
     FOR i IN 0..v_parent_node_length-1 LOOP
        -- All Counters and Checks initialization
        l_sql_fail_count := 0;
        l_reuse_count := 0;
        l_pe_num := 0;
        l_pe_exist := TRUE;

        -- Loop through all the child nodes of OIC_PLAN_COPY Node
        v_child_node := dbms_xmldom.item(v_parent_node_list,i);
        v_child_node_name := dbms_xmldom.getNodeName(dbms_xmldom.item(v_parent_node_list,i));

     /* ****************************** Main Loop Start ************************ */

        --*********************************************************************
        --**********************    Parse Expression    ***********************
        --*********************************************************************
        IF v_child_node_name = 'CnCalcSqlExpsVO' THEN
           -- Rollback SavePoint
           SAVEPOINT   Create_Expression;
           -- Intialising Rate Table record
           v_expression_rec := NULL;
           -- Get the CnCalcSqlExpsVORow
           v_node_first_child := dbms_xmldom.getFirstChild(v_child_node);
           -- Cast Node to Element
           v_element_cast := dbms_xmldom.makeElement(v_node_first_child);
           -- Get the Expression Name
           v_name_node := dbms_xmldom.getChildrenByTagName(v_element_cast,'Name');
           -- Get the Expression Name Value
           v_name_node_value := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(v_name_node,0)));
           -- Attach prefix to the Name Value
           -- v_name_node_value_new := p_prefix || v_name_node_value;

           -- Call common utility package for name length check
           v_name_node_value_new := cn_plancopy_util_pvt.check_name_length(
                                          p_name    => v_name_node_value,
                                          p_org_id  => p_org_id,
                                          p_type    => 'EXPRESSION',
                                          p_prefix  => p_prefix);

           -- Check if Expression already exists in the Target Instance
           SELECT COUNT(name) INTO l_reuse_count
             FROM cn_calc_sql_exps
            WHERE name = v_name_node_value_new
              AND org_id = p_org_id;

           --If Expression exists then do not Insert otherwise insert a new Record.
           IF l_reuse_count > 0 THEN
              fnd_message.set_name ('CN' , 'CN_COPY_EXP_REUSE');
	      fnd_message.set_token('EXPRESSION_NAME',v_name_node_value_new);
	      fnd_file.put_line(fnd_file.log, fnd_message.get);
           END IF;

           IF l_reuse_count = 0 THEN
              -- Get the other Expression values
              l_source_org_id                        := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'OrgId'),0)));
              v_expression_rec.org_id                := p_org_id;
              v_expression_rec.name                  := v_name_node_value_new;
              v_expression_rec.description           := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Description'),0)));
              v_expression_rec.status                := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Status'),0)));
              v_expression_rec.exp_type_code         := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'ExpTypeCode'),0)));
              v_expression_rec.expression_disp       := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'ExpressionDisp'),0)));
              v_expression_rec.sql_select            := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'SqlSelect'),0)));
              v_expression_rec.sql_from              := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'SqlFrom'),0)));
              v_expression_rec.piped_sql_select      := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'PipedSqlSelect'),0)));
              v_expression_rec.piped_sql_from        := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'PipedSqlFrom'),0)));
              v_expression_rec.piped_expression_disp := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'PipedExpressionDisp'),0)));

              --*********************************************************************
              -- Parse Formula or/and Expression in Expression - Calc Edges
              --*********************************************************************
              v_node_sibling_Next := dbms_xmldom.getNextSibling(v_child_node);
              v_node_sibling_name_Next := dbms_xmldom.getNodeNAME(v_node_sibling_Next);
              IF v_node_sibling_name_Next = 'CnCalcEdgesVO' THEN
                 v_node_sibling_length_Next := dbms_xmldom.getLength(dbms_xmldom.getChildNodes(v_node_sibling_Next));
                 IF v_node_sibling_length_Next > 0 THEN
                    v_node_sibling_list_Next := dbms_xmldom.getChildNodes(v_node_sibling_Next);
                    -- Clearing the Temporary Table
                    g_miss_calc_edges_tbl.DELETE;
                    FOR i IN 0..v_node_sibling_length_Next-1 LOOP
                       -- Loop through all the child nodes of CnRateDimTiers Node
                       v_node_sibling_child_Next := dbms_xmldom.item(v_node_sibling_list_Next,i);
                       -- Cast Node to Element
                       v_element_sibling_cast_Next := dbms_xmldom.makeElement(v_node_sibling_child_Next);
                       -- Get Calc Edges Information
                       l_formula_pkg_source  := NULL;
                       l_formula_pkg_target  := NULL;
                       l_formula_name_source := NULL;
                       g_miss_calc_edges_tbl(i).child_name
                             := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'ChildName'),0)));
                       g_miss_calc_edges_tbl(i).edge_type
                             := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'EdgeType'),0)));
                       g_miss_calc_edges_tbl(i).parent_name
                             := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'ParentName'),0)));
                       -- Call common utility package for name length check
                       g_miss_calc_edges_tbl(i).parent_name  := cn_plancopy_util_pvt.check_name_length(
                                                                 p_name    => g_miss_calc_edges_tbl(i).parent_name,
                                                                 p_org_id  => p_org_id,
                                                                 p_type    => 'EXPRESSION',
                                                                 p_prefix  => p_prefix);

                       ----------------------------------------------
                       -- Step1: Check if Expression contains Formula
                       ----------------------------------------------
                       IF g_miss_calc_edges_tbl(i).edge_type = 'FE' THEN
                          -- Storing old name of the formula in source system
                          l_formula_name_source := g_miss_calc_edges_tbl(i).child_name;
                          -- Call common utility package for name length check
                          g_miss_calc_edges_tbl(i).child_name := cn_plancopy_util_pvt.check_name_length(
                                                                    p_name    => g_miss_calc_edges_tbl(i).child_name,
                                                                    p_org_id  => p_org_id,
                                                                    p_type    => 'FORMULA',
                                                                    p_prefix  => p_prefix);

                          g_miss_calc_edges_tbl(i).child_id
                                := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'ChildId'),0)));

                          -- Formula Package Information
                          l_formula_pkg_source := 'cn_formula_'||g_miss_calc_edges_tbl(i).child_id||'_'||l_source_org_id||'_pkg';

                          -- Get Formula Information
                          IF g_miss_calc_edges_tbl(i).parent_name = v_expression_rec.name THEN
                             SELECT COUNT(name) INTO l_formula_name_count
                               FROM cn_calc_formulas
                              WHERE name = g_miss_calc_edges_tbl(i).child_name
                                AND org_id = p_org_id;
                             IF l_formula_name_count = 0 THEN
                                fnd_message.set_name ('CN' , 'CN_COPY_EXP_FM_MISS');
	                        fnd_message.set_token('EXPRESSION_NAME',v_expression_rec.name);
	                        fnd_message.set_token('FORMULA_NAME',g_miss_calc_edges_tbl(i).child_name);
                                fnd_file.put_line(fnd_file.log, fnd_message.get);
                                l_sql_fail_count := 1;
                                EXIT;
                             ELSE
                                SELECT calc_formula_id INTO g_miss_calc_edges_tbl(i).child_id
                                  FROM cn_calc_formulas
                                 WHERE name = g_miss_calc_edges_tbl(i).child_name
                                   AND org_id = p_org_id;
                             END IF;
                             l_formula_pkg_target := 'cn_formula_'||g_miss_calc_edges_tbl(i).child_id||'_'||p_org_id||'_pkg';
                             v_expression_rec.sql_select            := REPLACE(v_expression_rec.sql_select,l_formula_pkg_source,l_formula_pkg_target);
                             v_expression_rec.piped_sql_select      := REPLACE(v_expression_rec.sql_select,l_formula_pkg_source,l_formula_pkg_target);
                             v_expression_rec.expression_disp       := REPLACE(v_expression_rec.expression_disp,l_formula_name_source,g_miss_calc_edges_tbl(i).child_name);
                             v_expression_rec.piped_expression_disp := REPLACE(v_expression_rec.piped_expression_disp,l_formula_name_source,g_miss_calc_edges_tbl(i).child_name);
                          END IF;
                       END IF;
                       ---------------------------------------------------------
                       -- Step2: Check if Expression contains another Expression
                       ---------------------------------------------------------
                       IF g_miss_calc_edges_tbl(i).edge_type = 'EE' THEN
                          -- Storing old name of the formula in source system
                          l_exp_name_source := g_miss_calc_edges_tbl(i).child_name;
                          -- Call common utility package for name length check
                          g_miss_calc_edges_tbl(i).child_name := cn_plancopy_util_pvt.check_name_length(
                                                                    p_name    => g_miss_calc_edges_tbl(i).child_name,
                                                                    p_org_id  => p_org_id,
                                                                    p_type    => 'EXPRESSION',
                                                                    p_prefix  => p_prefix);
                          g_miss_calc_edges_tbl(i).child_id
                                := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'ChildId'),0)));
                          -- Get Formula Information
                          IF g_miss_calc_edges_tbl(i).parent_name = v_expression_rec.name THEN
                             SELECT COUNT(name) INTO l_exp_name_count
                               FROM cn_calc_sql_exps
                              WHERE name = g_miss_calc_edges_tbl(i).child_name
                                AND org_id = p_org_id;
                             IF l_exp_name_count = 0 THEN
                                fnd_message.set_name ('CN' , 'CN_COPY_EXP_EXP_MISS');
	                        fnd_message.set_token('EXPRESSION_NAME_1',v_expression_rec.name);
	                        fnd_message.set_token('EXPRESSION_NAME_2',g_miss_calc_edges_tbl(i).child_name);
                                fnd_file.put_line(fnd_file.log, fnd_message.get);
                                l_sql_fail_count := 1;
                                EXIT;
                             ELSE
                                SELECT calc_sql_exp_id INTO g_miss_calc_edges_tbl(i).child_id
                                  FROM cn_calc_sql_exps
                                 WHERE name = g_miss_calc_edges_tbl(i).child_name
                                   AND org_id = p_org_id;
                             END IF;
                             v_expression_rec.expression_disp       :=  REPLACE(v_expression_rec.expression_disp,l_exp_name_source,g_miss_calc_edges_tbl(i).child_name);
                             v_expression_rec.piped_expression_disp :=  REPLACE(v_expression_rec.piped_expression_disp,l_exp_name_source,g_miss_calc_edges_tbl(i).child_name);
                          END IF;
                       END IF;
                    END LOOP;
                 END IF;
              END IF;

              IF l_sql_fail_count = 0 THEN
                 --*********************************************************************
                 -- Parse Plan Element in Expression
                 --*********************************************************************
                 WHILE l_pe_exist LOOP
                    -- l_pe_count := instr(v_expression_rec.piped_sql_select, 'PE.',1,l_pe_num+1);
                    l_pe_count := instr(v_expression_rec.piped_sql_select, 'PE.',1);
                    IF l_pe_count = 0 THEN
                       l_pe_exist := FALSE;
                    ELSE
                       IF g_miss_pe_exp_tbl.COUNT > 0 THEN
                          FOR i IN g_miss_pe_exp_tbl.FIRST..g_miss_pe_exp_tbl.LAST  LOOP
                            v_expression_rec.sql_select            :=  REPLACE(v_expression_rec.sql_select,g_miss_pe_exp_tbl(i).old_pe_id||'PE.',g_miss_pe_exp_tbl(i).new_pe_id||'PE.');
                            v_expression_rec.piped_sql_select      :=  REPLACE(v_expression_rec.piped_sql_select,g_miss_pe_exp_tbl(i).old_pe_id||'PE.',g_miss_pe_exp_tbl(i).new_pe_id||'PE.');
                            v_expression_rec.expression_disp       :=  REPLACE(v_expression_rec.expression_disp,g_miss_pe_exp_tbl(i).old_pe_name,g_miss_pe_exp_tbl(i).new_pe_name);
                            v_expression_rec.piped_expression_disp :=  REPLACE(v_expression_rec.piped_expression_disp,g_miss_pe_exp_tbl(i).old_pe_name,g_miss_pe_exp_tbl(i).new_pe_name);
                          END LOOP;
                          l_pe_exist := FALSE;
                       ELSE
                          --fnd_message.set_name ('CN' , 'CN_COPY_EXP_PE_MTRC_MISS');
	                  --fnd_message.set_token('EXPRESSION_NAME',v_expression_rec.name);
                          --fnd_message.set_token('PLAN_ELEMENT_NAME', g_miss_pe_exp_tbl(i).name);
                          --fnd_file.put_line(fnd_file.log, fnd_message.get);
                          l_sql_fail_count := 1;
                          l_pe_exist := FALSE;
                          EXIT;
                       END IF;
                    END IF;
                 END LOOP;

                 --*********************************************************************
                 -- Parse External Element in Expression
                 --*********************************************************************
                 l_ee_count := 0;
                 l_ee_piped_sql_from := v_expression_rec.piped_sql_from;
                 IF l_ee_piped_sql_from IS NOT NULL THEN
                    LOOP
                       l_ee_tab_name := SUBSTR(l_ee_piped_sql_from,1,INSTR(l_ee_piped_sql_from, '|')-1);
                       IF l_ee_tab_name <> 'DUAL' THEN
                       -- Check if Alias exists
                          l_ee_alias := instr(l_ee_tab_name, ' ',1);
                          IF l_ee_alias > 0 THEN
                             l_ee_tab_name_new := SUBSTR(l_ee_piped_sql_from,1,INSTR(l_ee_piped_sql_from, ' ')-1);
                          ELSE
                             l_ee_tab_name_new := l_ee_tab_name;
                          END IF;
                          -- Check object exists in Target System
                          SELECT COUNT(name) INTO l_ee_exist_obj_check
                            FROM cn_objects
                           WHERE org_id = p_org_id
                             AND calc_eligible_flag = 'Y'
                             AND object_type = 'TBL'
                             AND name = l_ee_tab_name_new;
                          -- Error Message - If table does not exist in Target System
                          IF l_ee_exist_obj_check = 0 THEN
                             fnd_message.set_name ('CN' , 'CN_COPY_EXP_EXT_MAP_MISS');
                             fnd_message.set_token('EXPRESSION_NAME',v_expression_rec.name);
                             fnd_file.put_line(fnd_file.log, fnd_message.get);
                             l_sql_fail_count := 1;
                             EXIT;
                          END IF;
                       END IF;
                       -- Remove the table name which is checked and pick the next table
                       l_ee_piped_sql_from := REPLACE(l_ee_piped_sql_from,l_ee_tab_name||'|','');
                       l_ee_count := INSTR(l_ee_piped_sql_from, '|');
                       IF l_ee_count = 0 THEN
                          EXIT;
                       END IF;
                    END LOOP;
                 END IF;

                 IF l_sql_fail_count = 0 THEN
                    --*********************************************************************
                    -- Import Expression
                    --*********************************************************************
                    l_calc_sql_exp_id := NULL;
                    cn_calc_sql_exps_pvt.create_expression(
                            p_api_version           => p_api_version,
                            p_init_msg_list         => p_init_msg_list,
                            p_commit                => p_commit,
                            p_validation_level      => p_validation_level,
                            p_org_id                => p_org_id,
                            p_name                  => v_expression_rec.name,
                            p_description           => v_expression_rec.description,
                            p_expression_disp       => v_expression_rec.expression_disp,
                            p_sql_select            => v_expression_rec.sql_select,
                            p_sql_from              => v_expression_rec.sql_from,
                            p_piped_expression_disp => v_expression_rec.piped_expression_disp,
                            p_piped_sql_select      => v_expression_rec.piped_sql_select,
                            p_piped_sql_from        => v_expression_rec.piped_sql_from,
                            x_calc_sql_exp_id       => l_calc_sql_exp_id,
                            x_exp_type_code         => v_expression_rec.exp_type_code,
                            x_status                => v_expression_rec.status,
                            x_return_status         => x_return_status,
                            x_msg_count             => x_msg_count,
                            x_msg_data              => x_msg_data,
                            x_object_version_number => x_object_version_number);
                    IF x_return_status = fnd_api.g_ret_sts_success THEN
                       fnd_message.set_name ('CN' , 'CN_COPY_EXP_CREATE');
                       fnd_message.set_token('EXPRESSION_NAME',v_expression_rec.name);
                       fnd_file.put_line(fnd_file.log, fnd_message.get);
                       COMMIT;
                    ELSE
                       ROLLBACK TO Create_Expression;
                       IF x_return_status = fnd_api.g_ret_sts_error THEN
                          fnd_message.set_name ('CN' , 'CN_COPY_EXP_FAIL_EXPECTED');
                          fnd_message.set_token('EXPRESSION_NAME',v_expression_rec.name);
                          fnd_file.put_line(fnd_file.log, fnd_message.get);
                          fnd_file.put_line(fnd_file.log, '***ERROR: '||x_msg_data);
                       END IF;
                       IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                          fnd_message.set_name ('CN' , 'CN_COPY_EXP_FAIL');
                          fnd_message.set_token('EXPRESSION_NAME',v_expression_rec.name);
                          fnd_file.put_line(fnd_file.log, fnd_message.get);
                          fnd_file.put_line(fnd_file.log, '***ERROR: '||x_msg_data);
                       END IF;
                    END IF;
                 ELSE
                    ROLLBACK TO Create_Expression;
                    fnd_message.set_name ('CN' , 'CN_COPY_EXP_FAIL');
                    fnd_message.set_token('EXPRESSION_NAME',v_expression_rec.name);
                    fnd_file.put_line(fnd_file.log, fnd_message.get);
                 END IF;
              ELSE
                 ROLLBACK TO Create_Expression;
                 fnd_message.set_name ('CN' , 'CN_COPY_EXP_FAIL');
                 fnd_message.set_token('EXPRESSION_NAME',v_expression_rec.name);
                 fnd_file.put_line(fnd_file.log, fnd_message.get);
              END IF;
           END IF;
        END IF;

        --*********************************************************************
        --******************    Parse Rate Dimension    ***********************
        --*********************************************************************
        IF v_child_node_name = 'CnRateDimensionsVO' THEN
           -- Rollback SavePoint
           SAVEPOINT   Create_RateDimension;
           -- Intialising Rate Table record
           v_rate_dimension_rec := NULL;
           -- Get the CnRateDimensionsVORow
           v_node_first_child := dbms_xmldom.getFirstChild(v_child_node);
           -- Cast Node to Element
           v_element_cast := dbms_xmldom.makeElement(v_node_first_child);
           -- Get the Rate Dimension Name
           v_name_node := dbms_xmldom.getChildrenByTagName(v_element_cast,'Name');
           -- Get the Rate Dimension Name Value
           v_name_node_value := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(v_name_node,0)));
           -- Attach prefix to the Name Value
           -- v_name_node_value_new := p_prefix || v_name_node_value;

           -- Call common utility package for name length check
           v_name_node_value_new := cn_plancopy_util_pvt.check_name_length(
                                          p_name    => v_name_node_value,
                                          p_org_id  => p_org_id,
                                          p_type    => 'RATEDIMENSION',
                                          p_prefix  => p_prefix);

           -- Check if Rate Dimension already exists in the Target Instance
           SELECT COUNT(name) INTO l_reuse_count
             FROM cn_rate_dimensions
            WHERE name = v_name_node_value_new
              AND org_id = p_org_id;

           --If Rate Dimension exists then do not Insert, Else insert a new record.
           IF l_reuse_count > 0 THEN
              fnd_message.set_name ('CN' , 'CN_COPY_RD_REUSE');
	      fnd_message.set_token('RATE_DIMENSION_NAME',v_name_node_value_new);
	      fnd_file.put_line(fnd_file.log, fnd_message.get);
           END IF;

           IF l_reuse_count = 0 THEN
              -- Get the other Rate Dimension Values
              v_rate_dimension_rec.org_id            := p_org_id;
              v_rate_dimension_rec.name              := v_name_node_value_new;
              v_rate_dimension_rec.description       := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Description'),0)));
              v_rate_dimension_rec.dim_unit_code     := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'DimUnitCode'),0)));
              v_rate_dimension_rec.number_tier       := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'NumberTier'),0)));

              --*********************************************************************
              -- Parse Rate Dim Tiers
              --*********************************************************************
              v_node_sibling_Next := dbms_xmldom.getNextSibling(v_child_node);
              v_node_sibling_name_Next := dbms_xmldom.getNodeNAME(v_node_sibling_Next);
              IF v_node_sibling_name_Next = 'CnRateDimTiersVO' THEN
                 v_node_sibling_length_Next := dbms_xmldom.getLength(dbms_xmldom.getChildNodes(v_node_sibling_Next));
                 IF v_node_sibling_length_Next > 0 THEN
                    v_node_sibling_list_Next := dbms_xmldom.getChildNodes(v_node_sibling_Next);
                    -- Clearing the Temporary Table
                    v_rate_dim_tiers_tbl.DELETE;
                    g_miss_rate_dim_exp_tbl.DELETE;
                    FOR i IN 0..v_node_sibling_length_Next-1 LOOP
                      -- Loop through all the child nodes of CnRateDimTiers Node
                      v_node_sibling_child_Next := dbms_xmldom.item(v_node_sibling_list_Next,i);
                      -- Cast Node to Element
                      v_element_sibling_cast_Next := dbms_xmldom.makeElement(v_node_sibling_child_Next);
                      -- Get the Rate Dim Tier Values
                      v_rate_dim_tiers_tbl(i).minimum_amount    := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'MinimumAmount'),0)));
                      v_rate_dim_tiers_tbl(i).maximum_amount    := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'MaximumAmount'),0)));
                      v_rate_dim_tiers_tbl(i).tier_sequence     := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'TierSequence'),0)));
                      v_rate_dim_tiers_tbl(i).string_value      := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'StringValue'),0)));
                      g_miss_rate_dim_exp_tbl(i).min_exp_name   := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'MinExpName'),0)));
                      g_miss_rate_dim_exp_tbl(i).max_exp_name   := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'MaxExpName'),0)));

                      IF g_miss_rate_dim_exp_tbl(i).min_exp_name IS NOT NULL THEN
                         -- Call common utility package for name length check
                         g_miss_rate_dim_exp_tbl(i).min_exp_name := cn_plancopy_util_pvt.check_name_length(
                                                 p_name    => g_miss_rate_dim_exp_tbl(i).min_exp_name,
                                                 p_org_id  => p_org_id,
                                                 p_type    => 'EXPRESSION',
                                                 p_prefix  => p_prefix);
                         SELECT COUNT(name) INTO l_exp_name_count
                           FROM cn_calc_sql_exps
                          WHERE name = g_miss_rate_dim_exp_tbl(i).min_exp_name
                            AND  org_id = p_org_id;

                         IF l_exp_name_count = 0 THEN
                            l_sql_fail_count := 1;
                            EXIT;
                         ELSE
                            SELECT calc_sql_exp_id INTO v_rate_dim_tiers_tbl(i).min_exp_id
                              FROM cn_calc_sql_exps
                             WHERE name = g_miss_rate_dim_exp_tbl(i).min_exp_name
                               AND org_id = p_org_id;
                         END IF;
                      END IF;
                      IF g_miss_rate_dim_exp_tbl(i).max_exp_name IS NOT NULL THEN
                         -- Call common utility package for name length check
                         g_miss_rate_dim_exp_tbl(i).max_exp_name := cn_plancopy_util_pvt.check_name_length(
                                                 p_name    => g_miss_rate_dim_exp_tbl(i).max_exp_name,
                                                 p_org_id  => p_org_id,
                                                 p_type    => 'EXPRESSION',
                                                 p_prefix  => p_prefix);

                         SELECT COUNT(name) INTO l_exp_name_count
                           FROM  cn_calc_sql_exps
                          WHERE  name = g_miss_rate_dim_exp_tbl(i).max_exp_name
                            AND  org_id = p_org_id;
                         IF l_exp_name_count = 0 THEN
                            l_sql_fail_count := 1;
                            EXIT;
                         ELSE
                         SELECT calc_sql_exp_id INTO v_rate_dim_tiers_tbl(i).max_exp_id
                           FROM  cn_calc_sql_exps
                          WHERE  name = g_miss_rate_dim_exp_tbl(i).max_exp_name
                            AND  org_id = p_org_id;
                         END IF;
                      END IF;
                    END LOOP;

                    IF l_sql_fail_count = 0 THEN
                       --*********************************************************************
                       -- Import Rate Dimension and Rate Dim Tiers
                       --*********************************************************************
                       l_rate_dimension_id := NULL;
                       cn_rate_dimensions_pvt.create_dimension(
                              p_api_version        => p_api_version,
                              p_init_msg_list      => p_init_msg_list,
                              p_commit             => p_commit,
                              p_validation_level   => p_validation_level,
                              p_name               => v_rate_dimension_rec.name,
                              p_description        => v_rate_dimension_rec.description,
                              p_dim_unit_code      => v_rate_dimension_rec.dim_unit_code,
                              p_number_tier        => v_rate_dimension_rec.number_tier,
                              p_tiers_tbl          => v_rate_dim_tiers_tbl,
                              p_org_id             => p_org_id,
                              x_rate_dimension_id  => l_rate_dimension_id,
                              x_return_status      => x_return_status,
                              x_msg_count          => x_msg_count,
                              x_msg_data           => x_msg_data);
                       IF x_return_status = fnd_api.g_ret_sts_success THEN
                          fnd_message.set_name ('CN' , 'CN_COPY_RD_CREATE');
	                  fnd_message.set_token('RATE_DIMENSION_NAME',v_rate_dimension_rec.name);
	                  fnd_file.put_line(fnd_file.log, fnd_message.get);
                          IF (g_miss_rate_dim_exp_tbl.COUNT > 0 AND v_rate_dimension_rec.dim_unit_code = 'EXPRESSION') THEN
                             FOR i IN g_miss_rate_dim_exp_tbl.FIRST..g_miss_rate_dim_exp_tbl.LAST  LOOP
                               fnd_message.set_name ('CN' , 'CN_COPY_EXP_RD_ASSIGN');
	                       fnd_message.set_token('EXPRESION_NAME',g_miss_rate_dim_exp_tbl(i).min_exp_name);
	                       fnd_message.set_token('RATE_DIMENSION_NAME',v_rate_dimension_rec.name);
	                       fnd_file.put_line(fnd_file.log, fnd_message.get);
                               fnd_message.set_name ('CN' , 'CN_COPY_EXP_RD_ASSIGN');
	                       fnd_message.set_token('EXPRESION_NAME',g_miss_rate_dim_exp_tbl(i).max_exp_name);
	                       fnd_message.set_token('RATE_DIMENSION_NAME',v_rate_dimension_rec.name);
	                       fnd_file.put_line(fnd_file.log, fnd_message.get);
                             END LOOP;
                          END IF;
                          COMMIT;
                       ELSE
                          ROLLBACK TO Create_RateDimension;
                          IF x_return_status = fnd_api.g_ret_sts_error THEN
                             fnd_message.set_name ('CN' , 'CN_COPY_RD_FAIL_EXPECTED');
                             fnd_message.set_token('RATE_DIMENSION_NAME',v_rate_dimension_rec.name);
                             fnd_file.put_line(fnd_file.log, fnd_message.get);
                             fnd_file.put_line(fnd_file.log, '***ERROR: '||x_msg_data);
                          END IF;
                          IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                             fnd_message.set_name ('CN' , 'CN_COPY_RD_FAIL');
                             fnd_message.set_token('RATE_DIMENSION_NAME',v_rate_dimension_rec.name);
                             fnd_file.put_line(fnd_file.log, fnd_message.get);
                             fnd_file.put_line(fnd_file.log, '***ERROR: '||x_msg_data);
                          END IF;
                       END IF;
                    ELSE
                       ROLLBACK TO Create_RateDimension;
                       fnd_message.set_name ('CN' , 'CN_COPY_RD_FAIL');
                       fnd_message.set_token('RATE_DIMENSION_NAME',v_rate_dimension_rec.name);
                       fnd_file.put_line(fnd_file.log, fnd_message.get);
                    END IF;
                 ELSE
                    ROLLBACK TO Create_RateDimension;
                    fnd_message.set_name ('CN' , 'CN_COPY_RD_FAIL');
                    fnd_message.set_token('RATE_DIMENSION_NAME',v_rate_dimension_rec.name);
                    fnd_file.put_line(fnd_file.log, fnd_message.get);
                 END IF;
              ELSE
                 ROLLBACK TO Create_RateDimension;
                 fnd_message.set_name ('CN' , 'CN_COPY_RD_FAIL');
                 fnd_message.set_token('RATE_DIMENSION_NAME',v_rate_dimension_rec.name);
                 fnd_file.put_line(fnd_file.log, fnd_message.get);
              END IF;
           END IF;
        END IF;

        --*********************************************************************
        --***************    Parse Rate Table - Rate Schedule    **************
        --*********************************************************************
        IF v_child_node_name = 'CnRateSchedulesVO' THEN
           -- Rollback SavePoint
           SAVEPOINT   Create_RateSchedule;
           -- Intialising Rate Table record
           v_rate_table_rec := NULL;
           -- Get the CnRateSchedulesVORow
           v_node_first_child := dbms_xmldom.getFirstChild(v_child_node);
           -- Cast Node to Element
           v_element_cast := dbms_xmldom.makeElement(v_node_first_child);
           -- Get the Rate Table Name
           v_name_node := dbms_xmldom.getChildrenByTagName(v_element_cast,'Name');
           -- Get the Rate Table Name Value
           v_name_node_value := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(v_name_node,0)));

           -- Attach prefix to the Name Value
           -- Call common utility package for name length check
           v_name_node_value_new := cn_plancopy_util_pvt.check_name_length(
                                          p_name    => v_name_node_value,
                                          p_org_id  => p_org_id,
                                          p_type    => 'RATETABLE',
                                          p_prefix  => p_prefix);

           -- Check if Rate Table already exists in the Target Instance
           SELECT COUNT(name) INTO l_reuse_count
             FROM cn_rate_schedules
            WHERE name = v_name_node_value_new
              AND org_id = p_org_id;

           --If Rate Table exists then do not Insert otherwise insert a new Record.
           IF l_reuse_count > 0 THEN
              ROLLBACK TO Create_RateSchedule;
              fnd_message.set_name ('CN' , 'CN_COPY_RT_REUSE');
	      fnd_message.set_token('RATE_TABLE_NAME',v_name_node_value_new);
	      fnd_file.put_line(fnd_file.log, fnd_message.get);
           END IF;

           IF l_reuse_count = 0 THEN
              -- Get the other Rate Table values
              v_rate_table_rec.name                 :=  v_name_node_value_new;
              v_rate_table_rec.commission_unit_code :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'CommissionUnitCode'),0)));
              v_rate_table_rec.org_id               :=  p_org_id;
              v_rate_table_rec.number_dim           :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'NumberDim'),0)));
              --*********************************************************************
              -- Parse Rate Schedule Dims
              --*********************************************************************
              v_node_sibling_Next := dbms_xmldom.getNextSibling(v_child_node);
              v_node_sibling_name_Next := dbms_xmldom.getNodeNAME(v_node_sibling_Next);
              IF v_node_sibling_name_Next = 'CnRateSchDimsVO' THEN
                 v_node_sibling_length_Next := dbms_xmldom.getLength(dbms_xmldom.getChildNodes(v_node_sibling_Next));
                 IF v_node_sibling_length_Next > 0 THEN
                    v_node_sibling_list_Next := dbms_xmldom.getChildNodes(v_node_sibling_Next);
                    -- Clearing the Temporary Table
                    v_rate_sch_dims_tbl.DELETE;
                    FOR i IN 0..v_node_sibling_length_Next-1 LOOP
                      -- Loop through all the child nodes of CnRateDimTiers Node
                      v_node_sibling_child_Next := dbms_xmldom.item(v_node_sibling_list_Next,i);
                      -- Cast Node to Element
                      v_element_sibling_cast_Next := dbms_xmldom.makeElement(v_node_sibling_child_Next);
                      -- Get the Rate Dim Tier Values
                      v_rate_sch_dims_tbl(i).rate_dim_name
                             := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'RateDimensionName'),0)));
                      -- Call common utility package for name length check
                      v_rate_sch_dims_tbl(i).rate_dim_name := cn_plancopy_util_pvt.check_name_length(
                                          p_name    => v_rate_sch_dims_tbl(i).rate_dim_name,
                                          p_org_id  => p_org_id,
                                          p_type    => 'RATEDIMENSION',
                                          p_prefix  => p_prefix);
                      v_rate_sch_dims_tbl(i).rate_dim_sequence
                             := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'RateDimSequence'),0)));

                      SELECT COUNT(name) INTO l_rate_dim_name_count
                        FROM  cn_rate_dimensions
                       WHERE  name = v_rate_sch_dims_tbl(i).rate_dim_name
                         AND  org_id = p_org_id;

                      IF l_rate_dim_name_count = 0 THEN
                         l_sql_fail_count := 1;
                         EXIT;
                      ELSE
                      SELECT rate_dimension_id INTO v_rate_sch_dims_tbl(i).rate_dimension_id
                        FROM  cn_rate_dimensions
                       WHERE  name = v_rate_sch_dims_tbl(i).rate_dim_name
                         AND  org_id = p_org_id;
                      END IF;
                    END LOOP;

                    IF l_sql_fail_count = 0 THEN
                       --*********************************************************************
                       -- Parse Rate Tiers
                       --*********************************************************************
                       v_node_sibling_Previous := v_node_sibling_Next;
                       v_node_sibling_Next := dbms_xmldom.getNextSibling(v_node_sibling_Previous);
                       v_node_sibling_name_Next := dbms_xmldom.getNodeNAME(v_node_sibling_Next);
                       IF v_node_sibling_name_Next = 'CnRateTiersVO' THEN
                          v_node_sibling_length_Next := dbms_xmldom.getLength(dbms_xmldom.getChildNodes(v_node_sibling_Next));
                          IF v_node_sibling_length_Next > 0 THEN
                             v_node_sibling_list_Next := dbms_xmldom.getChildNodes(v_node_sibling_Next);
                             -- Clearing the Temporary Table
                             v_rate_tiers_tbl.DELETE;
                             FOR i IN 0..v_node_sibling_length_Next-1 LOOP
                               -- Loop through all the child nodes of CnRateDimTiers Node
                               v_node_sibling_child_Next := dbms_xmldom.item(v_node_sibling_list_Next,i);
                               -- Cast Node to Element
                               v_element_sibling_cast_Next := dbms_xmldom.makeElement(v_node_sibling_child_Next);
                               -- Get the Rate Dim Tier Values
                               v_rate_tiers_tbl(i).p_org_id            := p_org_id;
                               v_rate_tiers_tbl(i).p_commission_amount
                                      := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'CommissionAmount'),0)));
                               v_rate_tiers_tbl(i).p_rate_sequence
                                      := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'RateSequence'),0)));
                             END LOOP;
                          ELSE
                             ROLLBACK TO Create_RateSchedule;
                             fnd_message.set_name ('CN' , 'CN_COPY_RT_FAIL');
                             fnd_message.set_token('RATE_TABLE_NAME',v_rate_table_rec.name);
                             fnd_file.put_line(fnd_file.log, fnd_message.get);
                          END IF;
                       END IF;
                       --*********************************************************************
                       -- Import Rate Table - Rate Schedule
                       --*********************************************************************
                       l_rate_schedule_id := NULL;
                       cn_multi_rate_schedules_pvt.create_schedule(
                             p_api_version          => p_api_version,
                             p_init_msg_list        => p_init_msg_list,
                             p_commit               => p_commit,
                             p_validation_level     => p_validation_level,
                             p_name                 => v_rate_table_rec.name,
                             p_commission_unit_code => v_rate_table_rec.commission_unit_code,
                             p_number_dim           => v_rate_table_rec.number_dim,
                             p_dims_tbl             => v_rate_sch_dims_tbl,
                             p_org_id               => p_org_id,
                             x_rate_schedule_id     => l_rate_schedule_id,
                             x_return_status        => x_return_status,
                             x_msg_count            => x_msg_count,
                             x_msg_data             => x_msg_data);
                       IF x_return_status = fnd_api.g_ret_sts_success THEN
                          --*********************************************************************
                          -- Import Rate Tiers
                          --*********************************************************************
                          IF (v_rate_tiers_tbl.COUNT > 0) THEN
                            FOR i IN v_rate_tiers_tbl.FIRST..v_rate_tiers_tbl.LAST  LOOP
                               cn_multi_rate_schedules_pvt.update_rate(
                                         p_rate_schedule_id      =>  l_rate_schedule_id,
                                         p_rate_sequence         =>  v_rate_tiers_tbl(i).p_rate_sequence,
                                         p_commission_amount     =>  v_rate_tiers_tbl(i).p_commission_amount,
                                         p_object_version_number =>  x_object_version_number,
                                         p_org_id                =>  p_org_id);
                             END LOOP;
                          END IF;
                          fnd_message.set_name ('CN' , 'CN_COPY_RT_CREATE');
                          fnd_message.set_token('RATE_TABLE_NAME',v_name_node_value_new);
                          fnd_file.put_line(fnd_file.log, fnd_message.get);
                          IF (v_rate_sch_dims_tbl.COUNT > 0) THEN
                             FOR i IN v_rate_sch_dims_tbl.FIRST..v_rate_sch_dims_tbl.LAST  LOOP
                               fnd_message.set_name ('CN' , 'CN_COPY_RD_RT_ASSIGN');
                               fnd_message.set_token('RATE_DIMENSION_NAME',v_rate_sch_dims_tbl(i).rate_dim_name);
                               fnd_message.set_token('RATE_TABLE_NAME',v_rate_table_rec.name);
                               fnd_file.put_line(fnd_file.log, fnd_message.get);
                             END LOOP;
                          END IF;
                          COMMIT;
                       ELSE
                          ROLLBACK TO Create_RateDimension;
                          IF x_return_status = fnd_api.g_ret_sts_error THEN
                             fnd_message.set_name ('CN' , 'CN_COPY_RT_FAIL_EXPECTED');
                             fnd_message.set_token('RATE_TABLE_NAME',v_rate_table_rec.name);
                             fnd_file.put_line(fnd_file.log, fnd_message.get);
                             fnd_file.put_line(fnd_file.log, '***ERROR: '||x_msg_data);
                          END IF;
                          IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                             fnd_message.set_name ('CN' , 'CN_COPY_RT_FAIL');
                             fnd_message.set_token('RATE_TABLE_NAME',v_rate_table_rec.name);
                             fnd_file.put_line(fnd_file.log, fnd_message.get);
                             fnd_file.put_line(fnd_file.log, '***ERROR: '||x_msg_data);
                          END IF;
                       END IF;
                    ELSE
                       ROLLBACK TO Create_RateSchedule;
                       fnd_message.set_name ('CN' , 'CN_COPY_RT_FAIL');
                       fnd_message.set_token('RATE_TABLE_NAME',v_rate_table_rec.name);
                       fnd_file.put_line(fnd_file.log, fnd_message.get);
                    END IF;
                 ELSE
                    ROLLBACK TO Create_RateSchedule;
                    fnd_message.set_name ('CN' , 'CN_COPY_RT_FAIL');
                    fnd_message.set_token('RATE_TABLE_NAME',v_rate_table_rec.name);
                    fnd_file.put_line(fnd_file.log, fnd_message.get);
                 END IF;
              ELSE
                 ROLLBACK TO Create_RateSchedule;
                 fnd_message.set_name ('CN' , 'CN_COPY_RT_FAIL');
                 fnd_message.set_token('RATE_TABLE_NAME',v_rate_table_rec.name);
                 fnd_file.put_line(fnd_file.log, fnd_message.get);
              END IF;
           END IF;
        END IF;

        --*********************************************************************
        --************************    Parse Formula    ************************
        --*********************************************************************
        IF v_child_node_name = 'CnCalcFormulasVO' THEN
           -- Rollback SavePoint
           SAVEPOINT   Create_Formula;
           -- Intialising formula record
           v_formula_rec := NULL;
           -- Get the CnCalcFormulasVORow
           v_node_first_child := dbms_xmldom.getFirstChild(v_child_node);
           -- Cast Node to Element
           v_element_cast := dbms_xmldom.makeElement(v_node_first_child);
           -- Get the Formula Name
           v_name_node := dbms_xmldom.getChildrenByTagName(v_element_cast,'Name');
           -- Get the Formula Name Value
           v_name_node_value := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(v_name_node,0)));
           -- Attach prefix to the Name Value
           -- v_name_node_value_new := p_prefix || v_name_node_value;

           -- Call common utility package for name length check
           v_name_node_value_new := cn_plancopy_util_pvt.check_name_length(
                                          p_name    => v_name_node_value,
                                          p_org_id  => p_org_id,
                                          p_type    => 'FORMULA',
                                          p_prefix  => p_prefix);

           -- Check if Formula already exists in the Target Instance
           SELECT COUNT(name) INTO l_reuse_count
             FROM cn_calc_formulas
            WHERE name = v_name_node_value_new
              AND org_id = p_org_id;

           --If Formula exists then do not Insert otherwise insert a new Record.
           IF l_reuse_count > 0 THEN
              fnd_message.set_name ('CN' , 'CN_COPY_FM_REUSE');
	      fnd_message.set_token('FORMULA_NAME',v_name_node_value_new);
	      fnd_file.put_line(fnd_file.log, fnd_message.get);
           END IF;

           IF l_reuse_count = 0 THEN
              -- Get the other Formula values
              v_formula_rec.org_id                  := p_org_id;
              v_formula_rec.name                    := v_name_node_value_new;
              v_formula_rec.description             := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Description'),0)));
              v_formula_rec.formula_status          := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'FormulaStatus'),0)));
              v_formula_rec.split_flag              := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'SplitFlag'),0)));
              v_formula_rec.cumulative_flag         := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'CumulativeFlag'),0)));
              v_formula_rec.itd_flag                := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'ItdFlag'),0)));
              v_formula_rec.trx_group_code          := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'TrxGroupCode'),0)));
              v_formula_rec.threshold_all_tier_flag := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'ThresholdAllTierFlag'),0)));
              v_formula_rec.number_dim              := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'NumberDim'),0)));
              v_formula_rec.formula_type            := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'FormulaType'),0)));
              v_formula_rec.modeling_flag           := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'ModelingFlag'),0)));
              l_output_exp_name                     := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'OutputExpName'),0)));
              l_f_output_exp_name                   := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'FOutputExpName'),0)));
              l_perf_measure_name                   := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'PerfMeasureName'),0)));

              IF l_output_exp_name IS NULL THEN
                 l_sql_fail_count := 1;
              ELSE
                 -- Call common utility package for name length check
                 l_output_exp_name := cn_plancopy_util_pvt.check_name_length(
                                          p_name    => l_output_exp_name,
                                          p_org_id  => p_org_id,
                                          p_type    => 'EXPRESSION',
                                          p_prefix  => p_prefix);

                 SELECT COUNT(name) INTO l_exp_name_count
                   FROM cn_calc_sql_exps
                  WHERE name = l_output_exp_name
                    AND org_id = p_org_id;

                 IF l_exp_name_count = 0 THEN
                    l_sql_fail_count := 1;
                 ELSE
                    SELECT calc_sql_exp_id INTO v_formula_rec.output_exp_id
                      FROM cn_calc_sql_exps
                     WHERE name = l_output_exp_name
                       AND org_id = p_org_id;
                 END IF;

                 IF l_f_output_exp_name IS NOT NULL THEN
                    -- Call common utility package for name length check
                    l_f_output_exp_name := cn_plancopy_util_pvt.check_name_length(
                                                p_name    => l_f_output_exp_name,
                                                p_org_id  => p_org_id,
                                                p_type    => 'EXPRESSION',
                                                p_prefix  => p_prefix);

                    SELECT COUNT(name) INTO l_exp_name_count
                      FROM cn_calc_sql_exps
                     WHERE name = l_f_output_exp_name
                       AND org_id = p_org_id;
                    IF l_exp_name_count = 0 THEN
                       l_sql_fail_count := 1;
                    ELSE
                    SELECT calc_sql_exp_id INTO v_formula_rec.f_output_exp_id
                      FROM cn_calc_sql_exps
                     WHERE name = l_f_output_exp_name
                       AND org_id = p_org_id;
                    END IF;
                 END IF;

                 IF l_perf_measure_name IS NOT NULL THEN
                    -- Call common utility package for name length check
                    l_perf_measure_name := cn_plancopy_util_pvt.check_name_length(
                                                p_name    => l_perf_measure_name,
                                                p_org_id  => p_org_id,
                                                p_type    => 'EXPRESSION',
                                                p_prefix  => p_prefix);

                    SELECT COUNT(name) INTO l_exp_name_count
                      FROM  cn_calc_sql_exps
                     WHERE  name = l_perf_measure_name
                       AND  org_id = p_org_id;

                    IF l_exp_name_count = 0 THEN
                      l_sql_fail_count := 1;
                    ELSE
                     SELECT calc_sql_exp_id INTO v_formula_rec.perf_measure_id
                      FROM  cn_calc_sql_exps
                     WHERE  name = l_perf_measure_name
                       AND  org_id = p_org_id;
                    END IF;
                 END IF;
              END IF;
              IF l_sql_fail_count = 0 THEN
                 --*********************************************************************
                 -- Parse Formula - Input Expression Assignment
                 --*********************************************************************
                 v_node_sibling_Next := dbms_xmldom.getNextSibling(v_child_node);
                 v_node_sibling_name_Next := dbms_xmldom.getNodeNAME(v_node_sibling_Next);
                 IF v_node_sibling_name_Next = 'CnFormulaInputsVO' THEN
                    v_node_sibling_length_Next := dbms_xmldom.getLength(dbms_xmldom.getChildNodes(v_node_sibling_Next));
                    IF v_node_sibling_length_Next > 0 THEN
                       v_node_sibling_list_Next := dbms_xmldom.getChildNodes(v_node_sibling_Next);
                       -- Clearing the Temporary Table
                       v_input_exp_tbl.DELETE;
                       FOR i IN 0..v_node_sibling_length_Next-1 LOOP
                          -- Loop through all the child nodes of CnRateDimTiers Node
                          v_node_sibling_child_Next := dbms_xmldom.item(v_node_sibling_list_Next,i);
                          -- Cast Node to Element
                          v_element_sibling_cast_Next := dbms_xmldom.makeElement(v_node_sibling_child_Next);
                          -- Get the Rate Dim Tier Values
                          v_input_exp_tbl(i).rate_dim_sequence
                                := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'RateDimSequence'),0)));
                          v_input_exp_tbl(i).calc_exp_name
                                := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'CalcSqlExpName'),0)));
                          v_input_exp_tbl(i).calc_exp_status
                                := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'CalcSqlExpStatus'),0)));
                          v_input_exp_tbl(i).f_calc_exp_name
                                := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'FCalcSqlExpName'),0)));
                          v_input_exp_tbl(i).f_calc_exp_status
                                := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'FCalcSqlExpStatus'),0)));
                          v_input_exp_tbl(i).cumulative_flag
                                := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'CumulativeFlag'),0)));
                          v_input_exp_tbl(i).split_flag
                                := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'SplitFlag'),0)));

                          IF v_input_exp_tbl(i).calc_exp_name IS NULL THEN
                             l_sql_fail_count := 1;
                             EXIT;
                          ELSE
                             -- Call common utility package for name length check
                             v_input_exp_tbl(i).calc_exp_name := cn_plancopy_util_pvt.check_name_length(
                                              p_name    => v_input_exp_tbl(i).calc_exp_name,
                                              p_org_id  => p_org_id,
                                              p_type    => 'EXPRESSION',
                                              p_prefix  => p_prefix);

                             SELECT COUNT(name) INTO l_exp_name_count
                               FROM cn_calc_sql_exps
                              WHERE name = v_input_exp_tbl(i).calc_exp_name
                                AND org_id = p_org_id;
                             IF l_exp_name_count = 0 THEN
                                l_sql_fail_count := 1;
                                EXIT;
                             ELSE
                                SELECT calc_sql_exp_id INTO v_input_exp_tbl(i).calc_sql_exp_id
                                  FROM cn_calc_sql_exps
                                 WHERE name = v_input_exp_tbl(i).calc_exp_name
                                   AND org_id = p_org_id;
                             END IF;
                          END IF;

                          IF v_input_exp_tbl(i).f_calc_exp_name IS NOT NULL THEN
                             -- Call common utility package for name length check
                             v_input_exp_tbl(i).f_calc_exp_name := cn_plancopy_util_pvt.check_name_length(
                                              p_name    => v_input_exp_tbl(i).f_calc_exp_name,
                                              p_org_id  => p_org_id,
                                              p_type    => 'EXPRESSION',
                                              p_prefix  => p_prefix);

                             SELECT COUNT(name) INTO l_exp_name_count
                               FROM cn_calc_sql_exps
                              WHERE name = v_input_exp_tbl(i).f_calc_exp_name
                                AND org_id = p_org_id;

                             IF l_exp_name_count = 0 THEN
                                l_sql_fail_count := 1;
                                EXIT;
                             ELSE
                                SELECT calc_sql_exp_id INTO v_input_exp_tbl(i).f_calc_sql_exp_id
                                  FROM cn_calc_sql_exps_all
                                 WHERE name = v_input_exp_tbl(i).f_calc_exp_name
                                   AND org_id = p_org_id;
                             END IF;
                          END IF;
                       END LOOP;

                       IF l_sql_fail_count = 0 THEN
                          --*********************************************************************
                          -- Parse Formula - Rate Table Assignment
                          --*********************************************************************
                          v_node_sibling_Previous := v_node_sibling_Next;
                          v_node_sibling_Next := dbms_xmldom.getNextSibling(v_node_sibling_Previous);
                          v_node_sibling_name_Next := dbms_xmldom.getNodeNAME(v_node_sibling_Next);
                          IF v_node_sibling_name_Next = 'CnRtFormulaAsgnsVO' THEN
                             v_node_sibling_length_Next := dbms_xmldom.getLength(dbms_xmldom.getChildNodes(v_node_sibling_Next));
                             IF v_node_sibling_length_Next > 0 THEN
                                v_node_sibling_list_Next := dbms_xmldom.getChildNodes(v_node_sibling_Next);
                                -- Clearing the Temporary Table
                                v_rt_assign_tbl.DELETE;
                                FOR i IN 0..v_node_sibling_length_Next-1 LOOP
                                   -- Loop through all the child nodes of CnRateDimTiers Node
                                   v_node_sibling_child_Next := dbms_xmldom.item(v_node_sibling_list_Next,i);
                                   -- Cast Node to Element
                                   v_element_sibling_cast_Next := dbms_xmldom.makeElement(v_node_sibling_child_Next);
                                   -- Get the Formula Rate Table Values
                                   v_rt_assign_tbl(i).start_date
                                      := to_date(dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'StartDate'),0))),'YYYY-MM-DD');
                                   v_rt_assign_tbl(i).end_date
                                      := to_date(dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'EndDate'),0))),'YYYY-MM-DD');
                                   v_rt_assign_tbl(i).rate_schedule_name
                                      := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'RateScheduleName'),0)));
                                   v_rt_assign_tbl(i).rate_schedule_type
                                      := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'RateScheduleType'),0)));

                                   IF v_rt_assign_tbl(i).rate_schedule_name IS NULL THEN
                                      l_sql_fail_count := 1;
                                      EXIT;
                                   ELSE
                                      -- Call common utility package for name length check
                                      v_rt_assign_tbl(i).rate_schedule_name := cn_plancopy_util_pvt.check_name_length(
                                                         p_name    => v_rt_assign_tbl(i).rate_schedule_name,
                                                         p_org_id  => p_org_id,
                                                         p_type    => 'RATETABLE',
                                                         p_prefix  => p_prefix);

                                      SELECT COUNT(name) INTO l_rate_schedule_name_count
                                        FROM cn_rate_schedules
                                       WHERE name = v_rt_assign_tbl(i).rate_schedule_name
                                         AND  org_id = p_org_id;

                                      IF l_rate_schedule_name_count = 0 THEN
                                         l_sql_fail_count := 1;
                                         EXIT;
                                      ELSE
                                         SELECT rate_schedule_id INTO v_rt_assign_tbl(i).rate_schedule_id
                                           FROM cn_rate_schedules
                                          WHERE name = v_rt_assign_tbl(i).rate_schedule_name
                                            AND  org_id = p_org_id;
                                      END IF;
                                   END IF;
                                END LOOP;
                             ELSE
                                l_sql_fail_count := 1;
                                --ROLLBACK TO Create_Formula;
                                --fnd_message.set_name ('CN' , 'CN_COPY_FM_FAIL');
                                --fnd_message.set_token('FORMULA_NAME',v_formula_rec.name);
                                --fnd_file.put_line(fnd_file.log, fnd_message.get);
                             END IF;
                          END IF;

                          IF l_sql_fail_count = 0 THEN
                             --**********************************************
                             -- Import Formula
                             --**********************************************
                             l_calc_formula_id := Null;
                             v_formula_rec.calc_formula_id := NULL;
                             cn_calc_formulas_pvt.create_formula(
                                    p_api_version             => p_api_version,
                                    p_init_msg_list           => p_init_msg_list,
                                    p_commit                  => p_commit,
                                    p_validation_level        => p_validation_level,
                                    p_generate_packages       => FND_API.G_TRUE,
                                    p_name                    => v_formula_rec.name,
                                    p_description             => v_formula_rec.description,
                                    p_formula_type            => v_formula_rec.formula_type,
                                    p_trx_group_code          => v_formula_rec.trx_group_code,
                                    p_number_dim              => v_formula_rec.number_dim,
                                    p_cumulative_flag         => v_formula_rec.cumulative_flag,
                                    p_itd_flag                => v_formula_rec.itd_flag,
                                    p_split_flag              => v_formula_rec.split_flag,
                                    p_threshold_all_tier_flag => v_formula_rec.threshold_all_tier_flag,
                                    p_modeling_flag           => v_formula_rec.modeling_flag,
                                    p_perf_measure_id         => v_formula_rec.perf_measure_id,
                                    p_output_exp_id           => v_formula_rec.output_exp_id,
                                    p_f_output_exp_id         => v_formula_rec.f_output_exp_id,
                                    p_input_tbl               => v_input_exp_tbl,
                                    p_rt_assign_tbl           => v_rt_assign_tbl,
                                    p_org_id                  => p_org_id,
                                    x_calc_formula_id         => l_calc_formula_id,
                                    x_formula_status          => v_formula_rec.formula_status,
                                    x_return_status           => x_return_status,
                                    x_msg_count               => x_msg_count,
                                    x_msg_data                => x_msg_data);

                             IF x_return_status = fnd_api.g_ret_sts_success THEN
                                fnd_message.set_name ('CN' , 'CN_COPY_FM_CREATE');
                                fnd_message.set_token('FORMULA_NAME',v_formula_rec.name);
                                fnd_file.put_line(fnd_file.log, fnd_message.get);
                                fnd_message.set_name ('CN' , 'CN_COPY_EXP_FM_ASSIGN');
                                fnd_message.set_token('EXPRESSION_NAME',l_output_exp_name);
                                fnd_message.set_token('FORMULA_NAME',v_formula_rec.name);
                                fnd_file.put_line(fnd_file.log, fnd_message.get);
                                IF l_f_output_exp_name IS NOT NULL THEN
                                   fnd_message.set_name ('CN' , 'CN_COPY_EXP_FM_ASSIGN');
                                   fnd_message.set_token('EXPRESSION_NAME',l_f_output_exp_name);
                                   fnd_message.set_token('FORMULA_NAME',v_formula_rec.name);
                                   fnd_file.put_line(fnd_file.log, fnd_message.get);
                                END IF;
                                IF l_perf_measure_name IS NOT NULL THEN
                                   fnd_message.set_name ('CN' , 'CN_COPY_EXP_FM_ASSIGN');
                                   fnd_message.set_token('EXPRESSION_NAME',l_perf_measure_name);
                                   fnd_message.set_token('FORMULA_NAME',v_formula_rec.name);
                                   fnd_file.put_line(fnd_file.log, fnd_message.get);
                                END IF;
                                IF (v_input_exp_tbl.COUNT > 0) THEN
                                   FOR i IN v_input_exp_tbl.FIRST..v_input_exp_tbl.LAST  LOOP
                                     fnd_message.set_name ('CN' , 'CN_COPY_EXP_FM_ASSIGN');
                                     fnd_message.set_token('EXPRESSION_NAME',v_input_exp_tbl(i).calc_exp_name);
                                     fnd_message.set_token('FORMULA_NAME',v_formula_rec.name);
                                     fnd_file.put_line(fnd_file.log, fnd_message.get);
                                     IF v_input_exp_tbl(i).f_calc_exp_name IS NOT NULL THEN
                                         fnd_message.set_name ('CN' , 'CN_COPY_EXP_FM_ASSIGN');
	                                 fnd_message.set_token('EXPRESSION_NAME',v_input_exp_tbl(i).f_calc_exp_name);
	                                 fnd_message.set_token('FORMULA_NAME',v_formula_rec.name);
	                                 fnd_file.put_line(fnd_file.log, fnd_message.get);
                                     END IF;
                                   END LOOP;
                                END IF;
                                IF (v_rt_assign_tbl.COUNT > 0) THEN
                                   FOR i IN v_rt_assign_tbl.FIRST..v_rt_assign_tbl.LAST  LOOP
                                     fnd_message.set_name ('CN' , 'CN_COPY_RT_FM_ASSIGN');
	                             fnd_message.set_token('RATE_TABLE_NAME',v_rt_assign_tbl(i).rate_schedule_name);
	                             fnd_message.set_token('FORMULA_NAME',v_formula_rec.name);
                                     fnd_message.set_token('ASSIGNMENT_START_DATE', v_rt_assign_tbl(i).start_date);
                                     IF v_rt_assign_tbl(i).end_date IS NOT NULL THEN
                                        fnd_message.set_token('ASSIGNMENT_END_DATE', v_rt_assign_tbl(i).end_date);
                                     ELSE
                                        fnd_message.set_token('ASSIGNMENT_END_DATE', 'NULL');
	                             END IF;
	                             fnd_file.put_line(fnd_file.log, fnd_message.get);
                                   END LOOP;
                                END IF;
                                COMMIT;
                             ELSE
                                -- No ROLLBACK TO Create_Formula - Generate has a separate COMMIT cycle.
                                IF x_return_status = fnd_api.g_ret_sts_error THEN
                                   fnd_message.set_name ('CN' , 'CN_COPY_FM_FAIL_EXPECTED');
                                   fnd_message.set_token('FORMULA_NAME',v_formula_rec.name);
                                   fnd_file.put_line(fnd_file.log, fnd_message.get);
                                   fnd_file.put_line(fnd_file.log, '***ERROR: '||x_msg_data);
                                END IF;
                                IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                                   fnd_message.set_name ('CN' , 'CN_COPY_FM_FAIL');
                                   fnd_message.set_token('FORMULA_NAME',v_formula_rec.name);
                                   fnd_file.put_line(fnd_file.log, fnd_message.get);
                                   fnd_file.put_line(fnd_file.log, '***ERROR: '||x_msg_data);
                                END IF;
                             END IF;
                          ELSE
                             ROLLBACK TO Create_Formula;
                             fnd_message.set_name ('CN' , 'CN_COPY_FM_FAIL');
                             fnd_message.set_token('FORMULA_NAME',v_formula_rec.name);
                             fnd_file.put_line(fnd_file.log, fnd_message.get);
                          END IF;
                       ELSE
                          ROLLBACK TO Create_Formula;
                          fnd_message.set_name ('CN' , 'CN_COPY_FM_FAIL');
                          fnd_message.set_token('FORMULA_NAME',v_formula_rec.name);
                          fnd_file.put_line(fnd_file.log, fnd_message.get);
                       END IF;
                    ELSE
                       ROLLBACK TO Create_Formula;
                       fnd_message.set_name ('CN' , 'CN_COPY_FM_FAIL');
                       fnd_message.set_token('FORMULA_NAME',v_formula_rec.name);
                       fnd_file.put_line(fnd_file.log, fnd_message.get);
                    END IF;
                 ELSE
                    ROLLBACK TO Create_Formula;
                    fnd_message.set_name ('CN' , 'CN_COPY_FM_FAIL');
                    fnd_message.set_token('FORMULA_NAME',v_formula_rec.name);
                    fnd_file.put_line(fnd_file.log, fnd_message.get);
                 END IF;
              ELSE
                 ROLLBACK TO Create_Formula;
                 fnd_message.set_name ('CN' , 'CN_COPY_FM_FAIL');
                 fnd_message.set_token('FORMULA_NAME',v_formula_rec.name);
                 fnd_file.put_line(fnd_file.log, fnd_message.get);
              END IF;
           END IF;
        END IF;

        --*********************************************************************
        --**********************    Parse Plan Element    *********************
        --*********************************************************************
        IF v_child_node_name = 'CnQuotasVO' THEN
           -- Rollback SavePoint
           SAVEPOINT   Create_PlanElement;
           -- Intialising Rate Table record
           v_plan_element_rec := NULL;
           -- Get the CnQuotasVORow
           v_node_first_child := dbms_xmldom.getFirstChild(v_child_node);
           -- Cast Node to Element
           v_element_cast := dbms_xmldom.makeElement(v_node_first_child);
           -- Get the Plan Element Name
           v_name_node := dbms_xmldom.getChildrenByTagName(v_element_cast,'Name');
           -- Get the Plan Element Name Value
           v_name_node_value := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(v_name_node,0)));
           -- Attach prefix to the Name Value
           -- Call common utility package for name length check
           v_name_node_value_new := cn_plancopy_util_pvt.check_name_length(
                                          p_name    => v_name_node_value,
                                          p_org_id  => p_org_id,
                                          p_type    => 'PLANELEMENT',
                                          p_prefix  => p_prefix);

           -- Check if Plan Element already exists in the Target Instance
           SELECT COUNT(name) INTO l_reuse_count
             FROM cn_quotas_v
            WHERE name = v_name_node_value_new
              AND org_id = p_org_id;

           --If Plan Element exists then do not Insert otherwise insert a new Record.
           IF l_reuse_count > 0 THEN
              fnd_message.set_name ('CN' , 'CN_COPY_PE_REUSE');
	      fnd_message.set_token('PLAN_ELEMENT_NAME',v_name_node_value_new);
	      fnd_file.put_line(fnd_file.log, fnd_message.get);
           END IF;

           -- If Plan Element does not exist then proceed further.
           IF l_reuse_count = 0 THEN
              -- Old value of plan element for Interdependent cases
              g_miss_pe_exp_rec.old_pe_name := v_name_node_value;
              g_miss_pe_exp_rec.old_pe_id   := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'QuotaId'),0)));
              -- Get the other Plan Element values
              v_plan_element_rec.quota_id                    :=  NULL;
              v_plan_element_rec.name                        :=  v_name_node_value_new;
              v_plan_element_rec.element_type                :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'QuotaTypeCode'),0)));
              v_plan_element_rec.target                      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Target'),0)));
              v_plan_element_rec.description                 :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Description'),0)));
              v_plan_element_rec.payment_amount              :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'PaymentAmount'),0)));
              v_plan_element_rec.org_id                      :=  p_org_id;
              v_plan_element_rec.incentive_type              :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'IncentiveTypeCode'),0)));
              v_plan_element_rec.payee_assign_flag           :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'PayeeAssignFlag'),0)));
              v_plan_element_rec.performance_goal            :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'PerformanceGoal'),0)));
              v_plan_element_rec.status                      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'QuotaStatus'),0)));
              v_plan_element_rec.addup_from_rev_class_flag   :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'AddupFromRevClassFlag'),0)));
              v_plan_element_rec.quota_group_code            :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'QuotaGroupCode'),0)));
              v_plan_element_rec.payment_group_code          :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'PaymentGroupCode'),0)));
              v_plan_element_rec.indirect_credit             :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'IndirectCredit'),0)));
              v_plan_element_rec.calc_formula_name           :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'FormulaName'),0)));
              v_plan_element_rec.credit_type                 :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'CreditTypeName'),0)));
              v_plan_element_rec.interval_name               :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'IntervalTypeName'),0)));
              -- Other Attributes Start
              v_plan_element_rec.package_name                :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'PackageName'),0)));
              v_plan_element_rec.attribute_category          :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'AttributeCategory'),0)));
              v_plan_element_rec.attribute1                  :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Attribute1'),0)));
              v_plan_element_rec.attribute2                  :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Attribute2'),0)));
              v_plan_element_rec.attribute3                  :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Attribute3'),0)));
              v_plan_element_rec.attribute4                  :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Attribute4'),0)));
              v_plan_element_rec.attribute5                  :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Attribute5'),0)));
              v_plan_element_rec.attribute6                  :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Attribute6'),0)));
              v_plan_element_rec.attribute7                  :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Attribute7'),0)));
              v_plan_element_rec.attribute8                  :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Attribute8'),0)));
              v_plan_element_rec.attribute9                  :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Attribute9'),0)));
              v_plan_element_rec.attribute10                 :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Attribute10'),0)));
              v_plan_element_rec.attribute11                 :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Attribute11'),0)));
              v_plan_element_rec.attribute12                 :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Attribute12'),0)));
              v_plan_element_rec.attribute13                 :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Attribute13'),0)));
              v_plan_element_rec.attribute14                 :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Attribute14'),0)));
              v_plan_element_rec.attribute15                 :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Attribute15'),0)));
              v_plan_element_rec.rt_sched_custom_flag        :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'RtSchedCustomFlag'),0)));
              v_plan_element_rec.vesting_flag                :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'VestingFlag'),0)));
              v_plan_element_rec.period_type                 :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'PeriodType'),0)));
              -- New Column added to cn_quotas table in R12+
              v_plan_element_rec.sreps_enddated_flag         :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'SalesrepsEnddatedFlag'),0)));
              -- Liability and Expense Account Information
              l_expense_acc_desc   := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'ExpenseAccountDesc'),0)));
              l_liability_acc_desc := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'LiabilityAccountDesc'),0)));
              -- Other Attributes End

              -- Find Expense Account information in Target System
              l_expense_account_id := 0;
              IF l_expense_acc_desc IS NOT NULL THEN
                 OPEN c_expense_account_id (l_expense_acc_desc);
                 FETCH c_expense_account_id INTO l_expense_account_id;
                 CLOSE c_expense_account_id;
                 IF l_expense_account_id IS NULL THEN
                    v_plan_element_rec.expense_account_id := NULL;
                 ELSE
                    v_plan_element_rec.expense_account_id := l_expense_account_id;
                 END IF;
              ELSE
                 v_plan_element_rec.expense_account_id :=  NULL;
              END IF;

              -- Find Liability Account information in Target System
              l_liab_account_id := 0;
              IF l_liability_acc_desc IS NOT NULL THEN
                 OPEN c_liab_account_id (l_liability_acc_desc);
                 FETCH c_liab_account_id INTO l_liab_account_id;
                 CLOSE c_liab_account_id;
                 IF l_liab_account_id IS NULL THEN
                    v_plan_element_rec.liability_account_id  :=  NULL;
                 ELSE
                    v_plan_element_rec.liability_account_id  := l_liab_account_id;
                 END IF;
              ELSE
                 v_plan_element_rec.liability_account_id := NULL;
              END IF;

              -- Check for External Formula
              IF v_plan_element_rec.element_type = 'EXTERNAL' AND
                 v_plan_element_rec.package_name IS NULL  THEN
                 fnd_message.set_name ('CN' , 'CN_COPY_PE_EXT_FM_MISS');
	         fnd_message.set_token('PLAN_ELEMENT_NAME',v_name_node_value_new);
	         fnd_file.put_line(fnd_file.log, fnd_message.get);
                 l_sql_fail_count := 1;
              END IF;

              -- Check for Formula Name in Target System.
              IF v_plan_element_rec.element_type = 'FORMULA' THEN
                 -- Call common utility package for name length check
                 v_plan_element_rec.calc_formula_name := cn_plancopy_util_pvt.check_name_length(
                                          p_name    => v_plan_element_rec.calc_formula_name,
                                          p_org_id  => p_org_id,
                                          p_type    => 'FORMULA',
                                          p_prefix  => p_prefix);
                  SELECT COUNT(name) INTO l_formula_name_count
                    FROM cn_calc_formulas
                   WHERE name = v_plan_element_rec.calc_formula_name
                     AND org_id = p_org_id;
                  IF l_formula_name_count = 0 THEN
                     l_sql_fail_count := 1;
                  END IF;
              END IF;

              -- Check Interval Type Name in Target System
              SELECT COUNT(name) INTO l_int_type_count
                FROM cn_interval_types
               WHERE name = v_plan_element_rec.interval_name
                 AND org_id = p_org_id;
              IF l_int_type_count = 0 THEN
                 fnd_message.set_name ('CN' , 'CN_COPY_PE_INT_TYPE_MISS');
	         fnd_message.set_token('PLAN_ELEMENT_NAME',v_name_node_value_new);
                 fnd_message.set_token('INTERVAL_TYPE_NAME',v_plan_element_rec.interval_name);
	         fnd_file.put_line(fnd_file.log, fnd_message.get);
                 l_sql_fail_count := 1;
              END IF;

              -- Check Credit Type Name in Target System
              SELECT COUNT(name) INTO l_crd_type_count
                FROM cn_credit_types
               WHERE name = v_plan_element_rec.credit_type
                 AND org_id = p_org_id;
              IF l_crd_type_count = 0 THEN
                 fnd_message.set_name ('CN' , 'CN_COPY_PE_CRD_TYPE_MISS');
	         fnd_message.set_token('PLAN_ELEMENT_NAME',v_name_node_value_new);
                 fnd_message.set_token('CREDIT_TYPE_NAME',v_plan_element_rec.credit_type);
	         fnd_file.put_line(fnd_file.log, fnd_message.get);
                 l_sql_fail_count := 1;
              END IF;

              -- If all of the above are NOT NULL then proceed further
              IF l_sql_fail_count = 0 THEN
                 -- Check Payment Group Code in Target System
                 SELECT COUNT(lookup_code) INTO l_pmt_group_code
                   FROM cn_lookups
                  WHERE lookup_type = 'PAYMENT_GROUP_CODE'
                    AND lookup_code = v_plan_element_rec.payment_group_code;

                 -- If Payment Group does not exists, Set it to 'STANDARD'
                 IF l_pmt_group_code = 0 THEN
                    fnd_message.set_name ('CN' , 'CN_COPY_PE_PMT_GRP_DFLT');
                    fnd_message.set_token('PLAN_ELEMENT_NAME',v_name_node_value_new);
                    fnd_message.set_token('PAYMENT_GROUP_CODE_NAME',v_plan_element_rec.payment_group_code);
	            fnd_file.put_line(fnd_file.log, fnd_message.get);
                    v_plan_element_rec.payment_group_code := 'STANDARD';
                 END IF;

                 -- Check if Start Date and End Date values are passed for change.
                 IF p_start_date IS NULL THEN
                    v_plan_element_rec.start_date := to_date(dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'StartDate'),0))),'YYYY-MM-DD');
                 ELSE
                    v_plan_element_rec.start_date := p_start_date;
                 END IF;

                 IF p_start_date IS NULL AND p_end_date IS NULL THEN
                    v_plan_element_rec.end_date    := to_date(dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'EndDate'),0))),'YYYY-MM-DD');
                 ELSIF p_start_date IS NOT NULL AND p_end_date IS NOT NULL THEN
                       v_plan_element_rec.end_date := p_end_date;
                 ELSIF p_start_date IS NOT NULL AND p_end_date IS NULL THEN
                       v_plan_element_rec.end_date := NULL;
                 END IF;

                 --*********************************************************************
                 -- Parse Quota Rules - Revenue Class Assignments
                 --*********************************************************************
                 v_node_sibling_Next := dbms_xmldom.getNextSibling(v_child_node);
                 v_node_sibling_name_Next := dbms_xmldom.getNodeNAME(v_node_sibling_Next);

                 IF v_node_sibling_name_Next = 'CnQuotaRulesVO' THEN

                    -- Initializing for at least one rev class count
                    l_rev_class_least_count := 0;
                    v_node_sibling_length_Next := dbms_xmldom.getLength(dbms_xmldom.getChildNodes(v_node_sibling_Next));
                    -- Clearing the Temporary Table
                    v_revenue_class_tbl.DELETE;
                    IF v_node_sibling_length_Next > 0 THEN
                       v_node_sibling_list_Next := dbms_xmldom.getChildNodes(v_node_sibling_Next);
                       FOR i IN 0..v_node_sibling_length_Next-1 LOOP
                          -- Loop through all the child nodes of CnQuotaAssignsVO Node
                          v_node_sibling_child_Next := dbms_xmldom.item(v_node_sibling_list_Next,i);
                          -- Cast Node to Element
                          v_element_sibling_cast_Next := dbms_xmldom.makeElement(v_node_sibling_child_Next);

                          -- Find If Revenue Class exists in the Target System
                          l_rev_class_name := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'RevClsName'),0)));
                          SELECT COUNT(name) into l_rev_class_name_count
                           FROM  cn_revenue_classes
                          WHERE  name = l_rev_class_name
                            AND  org_id = p_org_id;

                          -- Get the Revenue Class Values - Only If Revenue Class exists in the Target System
                          IF l_rev_class_name_count <> 0 THEN
                             v_revenue_class_tbl(i).rev_class_name
                                := l_rev_class_name;
                             v_revenue_class_tbl(i).rev_class_target
                                := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Target'),0)));
                             v_revenue_class_tbl(i).rev_class_payment_amount
                                := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'PaymentAmount'),0)));
                             v_revenue_class_tbl(i).rev_class_performance_goal
                                := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'PerformanceGoal'),0)));
                             v_revenue_class_tbl(i).description
                                := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Description'),0)));
                             v_revenue_class_tbl(i).org_id
                                := p_org_id;
                             -- Other Attributes Start
                             v_revenue_class_tbl(i).attribute_category
                                :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'AttributeCategory'),0)));
                             v_revenue_class_tbl(i).attribute1
                                :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute1'),0)));
                             v_revenue_class_tbl(i).attribute2
                                :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute2'),0)));
                             v_revenue_class_tbl(i).attribute3
                                :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute3'),0)));
                             v_revenue_class_tbl(i).attribute4
                                :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute4'),0)));
                             v_revenue_class_tbl(i).attribute5
                                :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute5'),0)));
                             v_revenue_class_tbl(i).attribute6
                                :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute6'),0)));
                             v_revenue_class_tbl(i).attribute7
                                :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute7'),0)));
                             v_revenue_class_tbl(i).attribute8
                                :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute8'),0)));
                             v_revenue_class_tbl(i).attribute9
                                :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute9'),0)));
                             v_revenue_class_tbl(i).attribute10
                                :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute10'),0)));
                             v_revenue_class_tbl(i).attribute11
                                :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute11'),0)));
                             v_revenue_class_tbl(i).attribute12
                                :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute12'),0)));
                             v_revenue_class_tbl(i).attribute13
                                :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute13'),0)));
                             v_revenue_class_tbl(i).attribute14
                                :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute14'),0)));
                             v_revenue_class_tbl(i).attribute15
                                :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute15'),0)));
                             v_revenue_class_tbl(i).rev_class_name_old
                                :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'RevClassNameOld'),0)));
                             -- Other Attributes End

                             --Check for atleast one revenue class assign to Plan Element
                             l_rev_class_least_count := 1;
                          ELSE
                             fnd_message.set_name ('CN' , 'CN_COPY_PE_REV_CLS_MISS');
                             fnd_message.set_token('PLAN_ELEMENT_NAME',v_name_node_value_new);
                             fnd_message.set_token('PRODUCT_NAME',l_rev_class_name);
                             fnd_file.put_line(fnd_file.log, fnd_message.get);
                          END IF;
                       END LOOP;

                       -- If atleast one revenue class exists then proceed further
					   IF l_rev_class_least_count = 1 THEN
                          --*********************************************************************
                          -- Parse Quota Rule Uplifts
                          --*********************************************************************
						      v_node_sibling_Previous := v_node_sibling_Next;
	                          v_node_sibling_Next := dbms_xmldom.getNextSibling(v_node_sibling_Previous);
	                          v_node_sibling_name_Next := dbms_xmldom.getNodeNAME(v_node_sibling_Next);

                          IF v_node_sibling_name_Next = 'CnQuotaRuleUpliftsVO' THEN
                             v_node_sibling_length_Next := dbms_xmldom.getLength(dbms_xmldom.getChildNodes(v_node_sibling_Next));
                             IF v_node_sibling_length_Next > 0 THEN
                                v_node_sibling_list_Next := dbms_xmldom.getChildNodes(v_node_sibling_Next);
                                -- Clearing the Temporary Table
                                v_rev_uplift_tbl.DELETE;
                                FOR i IN 0..v_node_sibling_length_Next-1 LOOP
                                   -- Loop through all the child nodes of CnQuotaAssignsVO Node
                                   v_node_sibling_child_Next := dbms_xmldom.item(v_node_sibling_list_Next,i);
                                   -- Cast Node to Element
                                   v_element_sibling_cast_Next := dbms_xmldom.makeElement(v_node_sibling_child_Next);

                                   -- Find Revenue Class existing in the Target System
                                   l_uplift_start_date
                                      := to_date(dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'StartDate'),0))),'YYYY-MM-DD');
                                   l_uplift_end_date
                                      := to_date(dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'EndDate'),0))),'YYYY-MM-DD');
                                   l_rev_class_name
                                      := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'RevClsName'),0)));

                                   -- Check for Id
                                   SELECT COUNT(name) INTO l_rev_class_name_count
                                     FROM  cn_revenue_classes
                                    WHERE  name = l_rev_class_name
                                      AND  org_id = p_org_id;

                                   -- Uplift Factors start date and end date should fall inside Plan Element date range.
                                   IF l_uplift_start_date >= v_plan_element_rec.start_date AND
                                      l_uplift_end_date <= NVL(v_plan_element_rec.end_date,l_uplift_end_date) THEN

                                      -- Get the Revenue Class Values - Only If Revenue Class exists in the Target System
                                      IF l_rev_class_name_count <> 0 THEN
                                         -- Get the Quota Assign Values
                                         v_rev_uplift_tbl(i).rev_class_name
                                            := l_rev_class_name;
                                         v_rev_uplift_tbl(i).start_date
                                            := to_date(dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'StartDate'),0))),'YYYY-MM-DD');
                                         v_rev_uplift_tbl(i).end_date
                                            := to_date(dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'EndDate'),0))),'YYYY-MM-DD');
                                         v_rev_uplift_tbl(i).rev_class_payment_uplift
                                            := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'PaymentFactor'),0)));
                                         v_rev_uplift_tbl(i).rev_class_quota_uplift
                                            := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'QuotaFactor'),0)));
                                         v_rev_uplift_tbl(i).org_id
                                            := p_org_id;
                                         -- Other Attributes Start
                                         v_rev_uplift_tbl(i).attribute_category
                                            :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'AttributeCategory'),0)));
                                         v_rev_uplift_tbl(i).attribute1
                                            :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute1'),0)));
                                         v_rev_uplift_tbl(i).attribute2
                                            :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute2'),0)));
                                         v_rev_uplift_tbl(i).attribute3
                                            :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute3'),0)));
                                         v_rev_uplift_tbl(i).attribute4
                                            :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute4'),0)));
                                         v_rev_uplift_tbl(i).attribute5
                                            :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute5'),0)));
                                         v_rev_uplift_tbl(i).attribute6
                                            :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute6'),0)));
                                         v_rev_uplift_tbl(i).attribute7
                                            :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute7'),0)));
                                         v_rev_uplift_tbl(i).attribute8
                                            :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute8'),0)));
                                         v_rev_uplift_tbl(i).attribute9
                                            :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute9'),0)));
                                         v_rev_uplift_tbl(i).attribute10
                                            :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute10'),0)));
                                         v_rev_uplift_tbl(i).attribute11
                                            :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute11'),0)));
                                         v_rev_uplift_tbl(i).attribute12
                                            :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute12'),0)));
                                         v_rev_uplift_tbl(i).attribute13
                                            :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute13'),0)));
                                         v_rev_uplift_tbl(i).attribute14
                                            :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute14'),0)));
                                         v_rev_uplift_tbl(i).attribute15
                                            :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute15'),0)));
                                         v_rev_uplift_tbl(i).rev_class_name_old
                                            :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'RevClassNameOld'),0)));
                                         v_rev_uplift_tbl(i).start_date_old
                                            :=  to_date(dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'StartDateOld'),0))),'YYYY-MM-DD');
                                         v_rev_uplift_tbl(i).end_date_old
                                            :=  to_date(dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'EndDateOld'),0))),'YYYY-MM-DD');
                                         -- Other Attributes End
                                      END IF;
                                   ELSE
                                      fnd_message.set_name ('CN' , 'CN_COPY_PE_FCTRS_OUT_RANGE');
                                      fnd_message.set_token('PLAN_ELEMENT_NAME',v_name_node_value_new);
  	                              fnd_file.put_line(fnd_file.log, fnd_message.get);
                                   END IF;
                                END LOOP;
                             END IF;
                          END IF;
                          --*********************************************************************
                          -- Parse Transaction Factors
                          --*********************************************************************
                          IF v_node_sibling_name_Next = 'CnQuotaRuleUpliftsVO' THEN
                             v_node_sibling_Previous := v_node_sibling_Next;
                             v_node_sibling_Next := dbms_xmldom.getNextSibling(v_node_sibling_Previous);
                             v_node_sibling_name_Next := dbms_xmldom.getNodeNAME(v_node_sibling_Next);
                          END IF;
                          IF v_node_sibling_name_Next = 'CnTrxFactorsVO' THEN
                             v_node_sibling_length_Next := dbms_xmldom.getLength(dbms_xmldom.getChildNodes(v_node_sibling_Next));
                             IF v_node_sibling_length_Next > 0 THEN
                                v_node_sibling_list_Next := dbms_xmldom.getChildNodes(v_node_sibling_Next);
                                -- Clearing the Temporary Table
                                v_trx_factor_tbl.DELETE;
                                FOR i IN 0..v_node_sibling_length_Next-1 LOOP
                                   -- Loop through all the child nodes of CnTrxFactorsVO Node
                                   v_node_sibling_child_Next := dbms_xmldom.item(v_node_sibling_list_Next,i);
                                   -- Cast Node to Element
                                   v_element_sibling_cast_Next := dbms_xmldom.makeElement(v_node_sibling_child_Next);

                                  -- Find Revenue Class existing in the Target System
                                   l_rev_class_name :=
                                      dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'RevClsName'),0)));
                                   SELECT COUNT(name) INTO l_rev_class_name_count
                                     FROM  cn_revenue_classes
                                    WHERE  name = l_rev_class_name
                                      AND  org_id = p_org_id;

                                   -- Get the Revenue Class Values - Only If Revenue Class exists in the Target System
                                   IF l_rev_class_name_count <> 0 THEN
                                      -- Get the Quota Assign Values
                                      v_trx_factor_tbl(i).trx_type
                                         := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'TrxType'),0)));
                                      v_trx_factor_tbl(i).event_factor
                                         := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'EventFactor'),0)));
                                      v_trx_factor_tbl(i).rev_class_name
                                         := l_rev_class_name;
                                      v_trx_factor_tbl(i).org_id
                                         := p_org_id;
                                   END IF;
                                END LOOP;
                             END IF;
                          END IF;
                          --*********************************************************************
                          -- Parse RT Quota Assigns
                          --*********************************************************************
						      v_node_sibling_Previous := v_node_sibling_Next;
	                          v_node_sibling_Next := dbms_xmldom.getNextSibling(v_node_sibling_Previous);
	                          v_node_sibling_name_Next := dbms_xmldom.getNodeNAME(v_node_sibling_Next);
				       ELSE
                          ROLLBACK TO Create_PlanElement;
                          fnd_message.set_name ('CN' , 'CN_COPY_PE_FAIL');
                          fnd_message.set_token('PLAN_ELEMENT_NAME',v_plan_element_rec.name);
                          fnd_file.put_line(fnd_file.log, fnd_message.get);
                       END IF;
                    ELSE
                       ROLLBACK TO Create_PlanElement;
                       fnd_message.set_name ('CN' , 'CN_COPY_PE_FAIL');
                       fnd_message.set_token('PLAN_ELEMENT_NAME',v_plan_element_rec.name);
                       fnd_file.put_line(fnd_file.log, fnd_message.get);
                    END IF;
                 ELSE
				 --Bug 8558744:  The Product is not Mandatory in Plan Element.
					-- Clearing the Temporary Table
                    v_revenue_class_tbl.DELETE;
                    v_trx_factor_tbl.DELETE;
                    v_rev_uplift_tbl.DELETE;
                 END IF;

                          IF v_node_sibling_name_Next = 'CnRtQuotaAsgnsVO' THEN
                             -- Initializing formula and RT count check in PE
                             l_rt_fm_notexist_count := 0;
                             v_node_sibling_length_Next := dbms_xmldom.getLength(dbms_xmldom.getChildNodes(v_node_sibling_Next));
                             IF v_node_sibling_length_Next > 0 THEN
                                v_node_sibling_list_Next := dbms_xmldom.getChildNodes(v_node_sibling_Next);
                                -- Clearing the Temporary Table
                                v_rt_quota_asgns_tbl.DELETE;
                                FOR i IN 0..v_node_sibling_length_Next-1 LOOP
                                   -- Loop through all the child nodes of CnQuotaAssignsVO Node
                                   v_node_sibling_child_Next := dbms_xmldom.item(v_node_sibling_list_Next,i);
                                   -- Cast Node to Element
                                   v_element_sibling_cast_Next := dbms_xmldom.makeElement(v_node_sibling_child_Next);
                                   -- Get the Quota Assign Values
                                   v_rt_quota_asgns_tbl(i).rate_schedule_name
                                      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'RateScheduleName'),0)));
                                   v_rt_quota_asgns_tbl(i).calc_formula_name
                                      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'CalcFormulaName'),0)));
                                   v_rt_quota_asgns_tbl(i).start_date
                                      :=  to_date(dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'StartDate'),0))),'YYYY-MM-DD');
                                   v_rt_quota_asgns_tbl(i).end_date
                                      :=  to_date(dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'EndDate'),0))),'YYYY-MM-DD');
                                   v_rt_quota_asgns_tbl(i).org_id
                                      :=  p_org_id;
                                   -- Other Attributes Start
                                   v_rt_quota_asgns_tbl(i).attribute_category
                                      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'AttributeCategory'),0)));
                                   v_rt_quota_asgns_tbl(i).attribute1
                                      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute1'),0)));
                                   v_rt_quota_asgns_tbl(i).attribute2
                                      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute2'),0)));
                                   v_rt_quota_asgns_tbl(i).attribute3
                                      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute3'),0)));
                                   v_rt_quota_asgns_tbl(i).attribute4
                                      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute4'),0)));
                                   v_rt_quota_asgns_tbl(i).attribute5
                                      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute5'),0)));
                                   v_rt_quota_asgns_tbl(i).attribute6
                                      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute6'),0)));
                                   v_rt_quota_asgns_tbl(i).attribute7
                                      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute7'),0)));
                                   v_rt_quota_asgns_tbl(i).attribute8
                                      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute8'),0)));
                                   v_rt_quota_asgns_tbl(i).attribute9
                                      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute9'),0)));
                                   v_rt_quota_asgns_tbl(i).attribute10
                                      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute10'),0)));
                                   v_rt_quota_asgns_tbl(i).attribute11
                                      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute11'),0)));
                                   v_rt_quota_asgns_tbl(i).attribute12
                                      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute12'),0)));
                                   v_rt_quota_asgns_tbl(i).attribute13
                                      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute13'),0)));
                                   v_rt_quota_asgns_tbl(i).attribute14
                                      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute14'),0)));
                                   v_rt_quota_asgns_tbl(i).attribute15
                                      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute15'),0)));
                                   v_rt_quota_asgns_tbl(i).rate_schedule_name_old
                                      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'RateScheduleNameOld'),0)));
                                   v_rt_quota_asgns_tbl(i).start_date_old
                                      :=  to_date(dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'StartDateOld'),0))),'YYYY-MM-DD');
                                   v_rt_quota_asgns_tbl(i).end_date_old
                                      :=  to_date(dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'EndDateOld'),0))),'YYYY-MM-DD');
                                   -- Other Attributes End

                                   -- Call common utility package for name length check
                                   v_rt_quota_asgns_tbl(i).rate_schedule_name := cn_plancopy_util_pvt.check_name_length(
                                                         p_name    => v_rt_quota_asgns_tbl(i).rate_schedule_name,
                                                         p_org_id  => p_org_id,
                                                         p_type    => 'RATETABLE',
                                                         p_prefix  => p_prefix);
                                   -- Check for Rate Table Name existence in Target System
                                   SELECT COUNT(name) INTO l_rate_schedule_name_count
                                     FROM cn_rate_schedules
                                    WHERE name = v_rt_quota_asgns_tbl(i).rate_schedule_name
                                      AND org_id = p_org_id;

                                   -- Call common utility package for name length check
                                   -- Only if quota type is 'FORMULA'
                                   IF v_plan_element_rec.element_type = 'FORMULA' THEN
                                      v_rt_quota_asgns_tbl(i).calc_formula_name := cn_plancopy_util_pvt.check_name_length(
                                                            p_name    => v_rt_quota_asgns_tbl(i).calc_formula_name,
                                                            p_org_id  => p_org_id,
                                                            p_type    => 'FORMULA',
                                                            p_prefix  => p_prefix);
                                      -- Check for Formula Name existence in Target System
                                      SELECT COUNT(name) INTO l_formula_name_count
                                        FROM cn_calc_formulas
                                       WHERE name = v_rt_quota_asgns_tbl(i).calc_formula_name
                                         AND org_id = p_org_id;
                                   END IF;
                                   -- If Rate Table does not exist, do not create Plan Element
                                   IF l_rate_schedule_name_count = 0 THEN
                                      l_rt_fm_notexist_count := 1;
                                      EXIT;
                                   END IF;
                                   -- If Formula does not exist, do not create Plan Element
                                   IF v_plan_element_rec.element_type = 'FORMULA' AND l_formula_name_count = 0 THEN
                                      l_rt_fm_notexist_count := 1;
                                      EXIT;
                                   END IF;
                                END LOOP;
                             END IF;

                             -- If Rate Table and Formula exists, proceed further
                             IF l_rt_fm_notexist_count = 0 THEN
                                --*********************************************************************
                                -- Parse Period Quotas
                                --*********************************************************************
                                v_node_sibling_Previous := v_node_sibling_Next;
                                v_node_sibling_Next := dbms_xmldom.getNextSibling(v_node_sibling_Previous);
                                v_node_sibling_name_Next := dbms_xmldom.getNodeNAME(v_node_sibling_Next);
                                IF v_node_sibling_name_Next = 'CnPeriodQuotasVO' THEN
                                   v_node_sibling_length_Next := dbms_xmldom.getLength(dbms_xmldom.getChildNodes(v_node_sibling_Next));
                                   IF v_node_sibling_length_Next > 0 THEN
                                      v_node_sibling_list_Next := dbms_xmldom.getChildNodes(v_node_sibling_Next);
                                      -- Clearing the Temporary Table
                                      v_period_quotas_tbl.DELETE;
                                      FOR i IN 0..v_node_sibling_length_Next-1 LOOP
                                         -- Loop through all the child nodes of CnQuotaAssignsVO Node
                                         v_node_sibling_child_Next := dbms_xmldom.item(v_node_sibling_list_Next,i);
                                         -- Cast Node to Element
                                         v_element_sibling_cast_Next := dbms_xmldom.makeElement(v_node_sibling_child_Next);
                                         -- Checking Period Status and Period Range
                                         l_period_name := NULL;
                                         l_period_name :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'PeriodName'),0)));
                                         SELECT count(period_name) INTO l_period_exist_count
                                           FROM cn_period_statuses
                                          WHERE period_name = l_period_name
                                            AND org_id = p_org_id;

                                         IF l_period_exist_count <> 0 THEN
                                            SELECT end_date INTO l_period_end_date
                                              FROM cn_period_statuses
                                             WHERE period_name = l_period_name
                                               AND org_id = p_org_id;

                                            IF p_end_date IS NULL AND NVL(v_plan_element_rec.end_date,l_period_end_date) >= l_period_end_date THEN
                                               -- Get the Quota Assign Values
                                               v_period_quotas_tbl(i).period_name      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'PeriodName'),0)));
                                               v_period_quotas_tbl(i).period_target    :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'PeriodTarget'),0)));
                                               v_period_quotas_tbl(i).period_payment   :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'PeriodPayment'),0)));
                                               v_period_quotas_tbl(i).performance_goal :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'PerformanceGoal'),0)));
                                               v_period_quotas_tbl(i).org_id           :=  p_org_id;
                                               -- Other Attributes Start
                                               v_period_quotas_tbl(i).attribute1       :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute1'),0)));
                                               v_period_quotas_tbl(i).attribute2       :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute2'),0)));
                                               v_period_quotas_tbl(i).attribute3       :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute3'),0)));
                                               v_period_quotas_tbl(i).attribute4       :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute4'),0)));
                                               v_period_quotas_tbl(i).attribute5       :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute5'),0)));
                                               v_period_quotas_tbl(i).attribute6       :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute6'),0)));
                                               v_period_quotas_tbl(i).attribute7       :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute7'),0)));
                                               v_period_quotas_tbl(i).attribute8       :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute8'),0)));
                                               v_period_quotas_tbl(i).attribute9       :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute9'),0)));
                                               v_period_quotas_tbl(i).attribute10      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute10'),0)));
                                               v_period_quotas_tbl(i).attribute11      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute11'),0)));
                                               v_period_quotas_tbl(i).attribute12      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute12'),0)));
                                               v_period_quotas_tbl(i).attribute13      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute13'),0)));
                                               v_period_quotas_tbl(i).attribute14      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute14'),0)));
                                               v_period_quotas_tbl(i).attribute15      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute15'),0)));
                                               v_period_quotas_tbl(i).period_name_old  :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'PeriodNameOld'),0)));
                                               -- Other Attributes End
                                            END IF;
                                            IF p_end_date is NOT NULL AND p_end_date > l_period_end_date THEN
                                               -- Get the Quota Assign Values
                                               v_period_quotas_tbl(i).period_name      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'PeriodName'),0)));
                                               v_period_quotas_tbl(i).period_target    :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'PeriodTarget'),0)));
                                               v_period_quotas_tbl(i).period_payment   :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'PeriodPayment'),0)));
                                               v_period_quotas_tbl(i).performance_goal :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'PerformanceGoal'),0)));
                                               v_period_quotas_tbl(i).org_id           :=  p_org_id;
                                               -- Other Attributes Start
                                               v_period_quotas_tbl(i).attribute1       :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute1'),0)));
                                               v_period_quotas_tbl(i).attribute2       :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute2'),0)));
                                               v_period_quotas_tbl(i).attribute3       :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute3'),0)));
                                               v_period_quotas_tbl(i).attribute4       :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute4'),0)));
                                               v_period_quotas_tbl(i).attribute5       :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute5'),0)));
                                               v_period_quotas_tbl(i).attribute6       :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute6'),0)));
                                               v_period_quotas_tbl(i).attribute7       :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute7'),0)));
                                               v_period_quotas_tbl(i).attribute8       :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute8'),0)));
                                               v_period_quotas_tbl(i).attribute9       :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute9'),0)));
                                               v_period_quotas_tbl(i).attribute10      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute10'),0)));
                                               v_period_quotas_tbl(i).attribute11      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute11'),0)));
                                               v_period_quotas_tbl(i).attribute12      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute12'),0)));
                                               v_period_quotas_tbl(i).attribute13      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute13'),0)));
                                               v_period_quotas_tbl(i).attribute14      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute14'),0)));
                                               v_period_quotas_tbl(i).attribute15      :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Attribute15'),0)));
                                               v_period_quotas_tbl(i).period_name_old  :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'PeriodNameOld'),0)));
                                               -- Other Attributes End
                                            END IF;
                                         END IF;
                                      END LOOP;
                                      -- Clearing the Temporary Table to pass it as Null
                                      -- v_period_quotas_tbl.DELETE;
                                   END IF;
                                END IF;

                                --Call to Plan Element Public API to create Plan Element
                                cn_plan_element_pub.create_plan_element (
                                        p_api_version            =>   p_api_version,
                                        p_init_msg_list          =>   p_init_msg_list,
                                        p_commit                 =>   p_commit,
                                        p_validation_level       =>   p_validation_level,
                                        x_return_status          =>   x_return_status,
                                        x_msg_count              =>   x_msg_count,
                                        x_msg_data               =>   x_msg_data,
                                        p_plan_element_rec       =>   v_plan_element_rec,
                                        p_revenue_class_rec_tbl  =>   v_revenue_class_tbl,
                                        p_rev_uplift_rec_tbl     =>   v_rev_uplift_tbl,
                                        p_trx_factor_rec_tbl     =>   v_trx_factor_tbl,
                                        p_period_quotas_rec_tbl  =>   v_period_quotas_tbl,
                                        p_rt_quota_asgns_rec_tbl =>   v_rt_quota_asgns_tbl,
                                        x_loading_status         =>   x_loading_status,
                                        p_is_duplicate           =>   'N');

                                IF x_return_status = fnd_api.g_ret_sts_success THEN
                                   -- Log Message for Plan Element creation.
                                   fnd_message.set_name ('CN' , 'CN_COPY_PE_CREATE');
                                   fnd_message.set_token('PLAN_ELEMENT_NAME',v_plan_element_rec.name);
                                   fnd_message.set_token('PLAN_ELEMENT_START_DATE',v_plan_element_rec.start_date);
                                   IF v_plan_element_rec.end_date IS NOT NULL THEN
                                      fnd_message.set_token('PLAN_ELEMENT_END_DATE', v_plan_element_rec.end_date);
                                   ELSE
                                      fnd_message.set_token('PLAN_ELEMENT_END_DATE', 'NULL');
	                           END IF;
                                   fnd_file.put_line(fnd_file.log, fnd_message.get);
                                   -- Log Message for Formula to Quota Assignment
                                   fnd_message.set_name ('CN' , 'CN_COPY_FM_PE_ASSIGN');
                                   fnd_message.set_token('PLAN_ELEMENT_NAME',v_plan_element_rec.name);
                                   fnd_message.set_token('FORMULA_NAME',v_plan_element_rec.calc_formula_name);
                                   fnd_file.put_line(fnd_file.log, fnd_message.get);
                                   -- Log Message for Rate Table to Quota Assignment
                                   IF (v_rt_quota_asgns_tbl.COUNT > 0) THEN
                                      FOR i IN v_rt_quota_asgns_tbl.FIRST..v_rt_quota_asgns_tbl.LAST LOOP
                                         fnd_message.set_name ('CN' , 'CN_COPY_RT_PE_ASSIGN');
                                         fnd_message.set_token('PLAN_ELEMENT_NAME',v_plan_element_rec.name);
                                         fnd_message.set_token('RATE_TABLE_NAME',v_rt_quota_asgns_tbl(i).rate_schedule_name);
                                         fnd_message.set_token('ASSIGNMENT_START_DATE',v_rt_quota_asgns_tbl(i).start_date);
                                      IF v_rt_quota_asgns_tbl(i).end_date IS NOT NULL THEN
                                         fnd_message.set_token('ASSIGNMENT_END_DATE', v_rt_quota_asgns_tbl(i).end_date);
                                      ELSE
                                         fnd_message.set_token('ASSIGNMENT_END_DATE', 'NULL');
	                              END IF;
                                         fnd_file.put_line(fnd_file.log, fnd_message.get);
                                      END LOOP;
                                   END IF;
                                   COMMIT;
                                   -- New value of plan element for Interdependent cases
                                   g_miss_pe_exp_rec.new_pe_name := v_plan_element_rec.name;
                                   SELECT COUNT(name) INTO l_new_pe_name
                                     FROM cn_quotas_v
                                    WHERE name = v_plan_element_rec.name;
                                   IF l_new_pe_name > 0 THEN
                                      SELECT quota_id INTO g_miss_pe_exp_rec.new_pe_id
                                        FROM cn_quotas_v
                                       WHERE name = v_plan_element_rec.name;
                                      l_pe_counter := l_pe_counter + 1;
                                      g_miss_pe_exp_tbl(l_pe_counter).old_pe_name := g_miss_pe_exp_rec.old_pe_name;
                                      g_miss_pe_exp_tbl(l_pe_counter).old_pe_id   := g_miss_pe_exp_rec.old_pe_id;
                                      g_miss_pe_exp_tbl(l_pe_counter).new_pe_name := g_miss_pe_exp_rec.new_pe_name;
                                      g_miss_pe_exp_tbl(l_pe_counter).new_pe_id   := g_miss_pe_exp_rec.new_pe_id;
                                   END IF;
                                ELSE
                                   ROLLBACK TO Create_PlanElement;
                                   IF x_return_status = fnd_api.g_ret_sts_error THEN
                                      fnd_message.set_name ('CN' , 'CN_COPY_PE_FAIL_EXPECTED');
                                      fnd_message.set_token('PLAN_ELEMENT_NAME',v_plan_element_rec.name);
                                      fnd_file.put_line(fnd_file.log, fnd_message.get);
                                      fnd_file.put_line(fnd_file.log, '***ERROR: '||x_msg_data);
                                    END IF;
                                   IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                                      fnd_message.set_name ('CN' , 'CN_COPY_PE_FAIL');
                                      fnd_message.set_token('PLAN_ELEMENT_NAME',v_plan_element_rec.name);
                                      fnd_file.put_line(fnd_file.log, fnd_message.get);
                                      fnd_file.put_line(fnd_file.log, '***ERROR: '||x_msg_data);
                                    END IF;
                                END IF;
                             ELSE
                                ROLLBACK TO Create_PlanElement;
                                fnd_message.set_name ('CN' , 'CN_COPY_PE_FAIL');
                                fnd_message.set_token('PLAN_ELEMENT_NAME',v_plan_element_rec.name);
                                fnd_file.put_line(fnd_file.log, fnd_message.get);
                             END IF;
                          ELSE
                             ROLLBACK TO Create_PlanElement;
                             fnd_message.set_name ('CN' , 'CN_COPY_PE_FAIL');
                             fnd_message.set_token('PLAN_ELEMENT_NAME',v_plan_element_rec.name);
                             fnd_file.put_line(fnd_file.log, fnd_message.get);
                          END IF;
              ELSE
                 ROLLBACK TO Create_PlanElement;
                 fnd_message.set_name ('CN' , 'CN_COPY_PE_FAIL');
                 fnd_message.set_token('PLAN_ELEMENT_NAME',v_plan_element_rec.name);
                 fnd_file.put_line(fnd_file.log, fnd_message.get);
              END IF;
           END IF;
        END IF;

        --*********************************************************************
        --******************    Parse Compensation Plan    ********************
        --*********************************************************************
        IF v_child_node_name = 'CnCompPlansVO' THEN
           -- Rollback SavePoint
           SAVEPOINT   Create_CompPlan;
           -- Intialising Rate Table record
           v_comp_plan_rec := NULL;
           -- Get the CnCompPlansVORow
           v_node_first_child := dbms_xmldom.getFirstChild(v_child_node);
           -- Cast Node to Element
           v_element_cast := dbms_xmldom.makeElement(v_node_first_child);
           -- Get the Compensation Plan Name
           v_name_node := dbms_xmldom.getChildrenByTagName(v_element_cast,'Name');
           -- Get the Compensation Plan Name Value
           v_name_node_value := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(v_name_node,0)));
           -- Attach prefix to the Name Value
           -- Call common utility package for name length check
           v_name_node_value_new := cn_plancopy_util_pvt.check_name_length(
                                          p_name    => v_name_node_value,
                                          p_org_id  => p_org_id,
                                          p_type    => 'PLAN',
                                          p_prefix  => p_prefix);

           -- Check if Compensation Plan already exists in the Target Instance
           SELECT COUNT(name) INTO l_reuse_count
             FROM cn_comp_plans
            WHERE name = v_name_node_value_new
              AND org_id = p_org_id;

           --If Compensation Plan exits then do not Insert otherwise insert a new Record.
           IF l_reuse_count > 0 THEN
              fnd_message.set_name ('CN' , 'CN_COPY_CP_REUSE');
	      fnd_message.set_token('PLAN_NAME',v_name_node_value_new);
	      fnd_file.put_line(fnd_file.log, fnd_message.get);
              p_reuse_obj_count := p_reuse_obj_count + 1;
           END IF;

           IF l_reuse_count = 0 THEN
              -- Get other Compensation Plan values
              v_comp_plan_rec.name                    := v_name_node_value_new;
              v_comp_plan_rec.description             := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Description'),0)));
              v_comp_plan_rec.status_code             := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'StatusCode'),0)));
              v_comp_plan_rec.allow_rev_class_overlap := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'AllowRevClassOverlap'),0)));
              v_comp_plan_rec.sum_trx_flag            := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'SumTrxFlag'),0)));
              v_comp_plan_rec.org_id                  := p_org_id;
              -- Start Date parameter Logic
              IF p_start_date IS NULL THEN
                 v_comp_plan_rec.start_date := to_date(dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'StartDate'),0))),'YYYY-MM-DD');
              ELSE
                 v_comp_plan_rec.start_date := p_start_date;
              END IF;
              -- End Date parameter Logic
              IF p_start_date IS NULL AND p_end_date IS NULL THEN
                 v_comp_plan_rec.end_date   := to_date(dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'EndDate'),0))),'YYYY-MM-DD');
              ELSIF p_start_date IS NOT NULL AND p_end_date IS NOT NULL THEN
                    v_comp_plan_rec.end_date   := p_end_date;
              ELSIF p_start_date IS NOT NULL AND p_end_date IS NULL THEN
                    v_comp_plan_rec.end_date   := NULL;
              END IF;

              -- Other Attributes Start
              v_comp_plan_rec.attribute_category :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'AttributeCategory'),0)));
              v_comp_plan_rec.attribute1         :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Attribute1'),0)));
              v_comp_plan_rec.attribute2         :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Attribute2'),0)));
              v_comp_plan_rec.attribute3         :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Attribute3'),0)));
              v_comp_plan_rec.attribute4         :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Attribute4'),0)));
              v_comp_plan_rec.attribute5         :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Attribute5'),0)));
              v_comp_plan_rec.attribute6         :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Attribute6'),0)));
              v_comp_plan_rec.attribute7         :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Attribute7'),0)));
              v_comp_plan_rec.attribute8         :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Attribute8'),0)));
              v_comp_plan_rec.attribute9         :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Attribute9'),0)));
              v_comp_plan_rec.attribute10        :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Attribute10'),0)));
              v_comp_plan_rec.attribute11        :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Attribute11'),0)));
              v_comp_plan_rec.attribute12        :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Attribute12'),0)));
              v_comp_plan_rec.attribute13        :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Attribute13'),0)));
              v_comp_plan_rec.attribute14        :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Attribute14'),0)));
              v_comp_plan_rec.attribute15        :=  dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_cast,'Attribute15'),0)));
              -- Other Attributes End

              --*********************************************************************
              -- Import Compensation Plan
              --*********************************************************************
              l_comp_plan_id := NULL;
              v_comp_plan_rec.comp_plan_id := NULL;
              cn_comp_plan_pvt.create_comp_plan(
                       p_api_version             => p_api_version,
                       p_init_msg_list           => p_init_msg_list,
                       p_commit                  => p_commit,
                       p_validation_level        => p_validation_level,
                       p_comp_plan               => v_comp_plan_rec,
                       x_comp_plan_id            => l_comp_plan_id,
                       x_return_status           => x_return_status,
                       x_msg_count               => x_msg_count,
                       x_msg_data                => x_msg_data);

              IF x_return_status <> fnd_api.g_ret_sts_success THEN
                 l_sql_fail_count := 1;
              END IF;

              IF l_sql_fail_count = 0 THEN
                 --*********************************************************************
                 -- Parse Quota Assignments
                 --*********************************************************************
                 v_node_sibling_Next := dbms_xmldom.getNextSibling(v_child_node);
                 v_node_sibling_name_Next := dbms_xmldom.getNodeNAME(v_node_sibling_Next);
                 IF v_node_sibling_name_Next = 'CnQuotaAssignsVO' THEN
                    v_node_sibling_length_Next := dbms_xmldom.getLength(dbms_xmldom.getChildNodes(v_node_sibling_Next));
                    IF v_node_sibling_length_Next > 0 THEN
                       v_node_sibling_list_Next := dbms_xmldom.getChildNodes(v_node_sibling_Next);
                       -- Clearing the Temporary Table
                       v_quota_assign_tbl.DELETE;
                       FOR i IN 0..v_node_sibling_length_Next-1 LOOP
                          -- Loop through all the child nodes of CnQuotaAssignsVO Node
                          v_node_sibling_child_Next := dbms_xmldom.item(v_node_sibling_list_Next,i);
                          -- Cast Node to Element
                          v_element_sibling_cast_Next := dbms_xmldom.makeElement(v_node_sibling_child_Next);
                          -- Get the Quota Assign Values
                          v_quota_assign_tbl(i).name            := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'PeName'),0)));
                          v_quota_assign_tbl(i).org_id          := p_org_id;
                          v_quota_assign_tbl(i).comp_plan_id    := l_comp_plan_id;
                          v_quota_assign_tbl(i).description     := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'Description'),0)));
                          v_quota_assign_tbl(i).quota_sequence  := dbms_xmldom.getNodeValue(dbms_xmldom.getFirstChild(dbms_xmldom.item(dbms_xmldom.getChildrenByTagName(v_element_sibling_cast_Next,'QuotaSequence'),0)));

                          -- Call common utility package for name length check
                          v_quota_assign_tbl(i).name := cn_plancopy_util_pvt.check_name_length(
                                                   p_name    => v_quota_assign_tbl(i).name,
                                                   p_org_id  => p_org_id,
                                                   p_type    => 'PLANELEMENT',
                                                   p_prefix  => p_prefix);

                          -- Check if PE exists in the Target System
                          l_pe_name_count := 0;
                          SELECT count(name) INTO l_pe_name_count
                            FROM cn_quotas_v
                           WHERE name = v_quota_assign_tbl(i).name;
                          IF l_pe_name_count > 0 THEN
                             SELECT quota_id,start_date,end_date
                               INTO v_quota_assign_tbl(i).quota_id,v_quota_assign_tbl(i).start_date, v_quota_assign_tbl(i).end_date
                               FROM cn_quotas_v
                              WHERE name = v_quota_assign_tbl(i).name
                                AND org_id = p_org_id;
                          ELSE
                             ROLLBACK TO Create_CompPlan;
                             -- Comp Plan Fail Message
                             fnd_message.set_name ('CN' , 'CN_COPY_CP_FAIL');
                             fnd_message.set_token('PLAN_NAME',v_comp_plan_rec.name);
                             fnd_file.put_line(fnd_file.log, fnd_message.get);
                             -- Failed Plan Name collection for Summary Section
                             IF l_failed_plan_name IS NULL THEN
                                l_failed_plan_name := v_comp_plan_rec.name;
                             ELSE
                                l_failed_plan_name := l_failed_plan_name||', '||v_comp_plan_rec.name;
                             END IF;
                             l_sql_fail_count := 1;
                             EXIT;
                          END IF;
                       END LOOP;

                       IF l_sql_fail_count = 0 THEN
                          --*********************************************************************
                          -- Import Quota Assignments
                          --*********************************************************************
                          IF (v_quota_assign_tbl.COUNT > 0) THEN
                             -- Check for at least one PE to be assigned.
                             l_quota_asgn_count := 0;
                             FOR i IN v_quota_assign_tbl.FIRST..v_quota_assign_tbl.LAST LOOP
                                IF (v_quota_assign_tbl(i).start_date <= NVL(v_comp_plan_rec.end_date,v_quota_assign_tbl(i).start_date) AND
                                   NVL(v_quota_assign_tbl(i).end_date,v_comp_plan_rec.start_date) >= v_comp_plan_rec.start_date) THEN
                                   cn_quota_assign_pvt.create_quota_assign(
                                       p_api_version         =>   p_api_version,
                                       p_init_msg_list       =>   p_init_msg_list,
                                       p_commit              =>   p_commit,
                                       p_validation_level    =>   p_validation_level,
                                       p_quota_assign        =>   v_quota_assign_tbl(i),
                                       x_return_status       =>   x_return_status,
                                       x_msg_count           =>   x_msg_count,
                                       x_msg_data            =>   x_msg_data);
                                   IF x_return_status = fnd_api.g_ret_sts_success THEN
                                      -- Validate the CompPlan
                                      v_comp_plan_rec.comp_plan_id := l_comp_plan_id;
                                      cn_comp_plan_pvt.validate_comp_plan(
                                          p_api_version         =>   p_api_version,
                                          p_init_msg_list       =>   p_init_msg_list,
                                          p_commit              =>   p_commit,
                                          p_validation_level    =>   p_validation_level,
                                          p_comp_plan           =>   v_comp_plan_rec,
                                          x_return_status       =>   x_return_status,
                                          x_msg_count           =>   x_msg_count,
                                          x_msg_data            =>   x_msg_data);
                                      IF x_return_status = fnd_api.g_ret_sts_success THEN
                                         fnd_message.set_name ('CN' , 'CN_COPY_PE_ASSIGN');
                                         fnd_message.set_token('PLAN_NAME',v_name_node_value_new);
                                         fnd_message.set_token('PLAN_ELEMENT_NAME',v_quota_assign_tbl(i).name);
  	                                 fnd_file.put_line(fnd_file.log, fnd_message.get);
                                         l_quota_asgn_count := 1;
                                      ELSE
                                         l_sql_fail_count := 1;
                                         EXIT;
                                      END IF;
                                   ELSE
                                     l_sql_fail_count := 1;
                                      EXIT;
                                   END IF;
                                ELSE
                                  fnd_message.set_name ('CN' , 'CN_COPY_PE_OUT_RANGE');
   	                          fnd_message.set_token('PLAN_NAME',v_comp_plan_rec.name);
                                  fnd_message.set_token('PLAN_ELEMENT_NAME',v_quota_assign_tbl(i).name);
  	                          fnd_file.put_line(fnd_file.log, fnd_message.get);
                                END IF;
                             END LOOP;
                             IF l_sql_fail_count = 0 AND l_quota_asgn_count = 1 THEN
                                fnd_message.set_name ('CN' , 'CN_COPY_CP_CREATE');
	                        fnd_message.set_token('PLAN_NAME',v_comp_plan_rec.name);
                                fnd_message.set_token('PLAN_START_DATE',v_comp_plan_rec.start_date);
                                IF v_comp_plan_rec.end_date IS NOT NULL THEN
                                   fnd_message.set_token('PLAN_END_DATE', v_comp_plan_rec.end_date);
                                ELSE
                                   fnd_message.set_token('PLAN_END_DATE', 'NULL');
	                        END IF;
                                fnd_file.put_line(fnd_file.log, fnd_message.get);
                                p_success_obj_count := p_success_obj_count + 1;
                                COMMIT;
                             ELSE
                                ROLLBACK TO Create_CompPlan;
                                -- Comp Plan Fail Message
                                IF x_return_status = fnd_api.g_ret_sts_error THEN
                                  fnd_message.set_name ('CN' , 'CN_COPY_CP_FAIL_EXPECTED');
                                  fnd_message.set_token('PLAN_NAME',v_comp_plan_rec.name);
                                  fnd_file.put_line(fnd_file.log, fnd_message.get);
                                  fnd_file.put_line(fnd_file.log, '***ERROR: '||x_msg_data);
                                END IF;
                                IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                                   fnd_message.set_name ('CN' , 'CN_COPY_CP_FAIL');
                                   fnd_message.set_token('PLAN_NAME',v_comp_plan_rec.name);
                                   fnd_file.put_line(fnd_file.log, fnd_message.get);
                                   fnd_file.put_line(fnd_file.log, '***ERROR: '||x_msg_data);
                                END IF;
                                -- Failed Plan Name collection for Summary Section
                                IF l_failed_plan_name IS NULL THEN
                                   l_failed_plan_name := v_comp_plan_rec.name;
                                ELSE
                                   l_failed_plan_name := l_failed_plan_name||', '||v_comp_plan_rec.name;
                                END IF;
                             END IF;
                          ELSE
                             ROLLBACK TO Create_CompPlan;
                             -- Comp Plan Fail Message
                             fnd_message.set_name ('CN' , 'CN_COPY_CP_FAIL');
                             fnd_message.set_token('PLAN_NAME',v_comp_plan_rec.name);
                             fnd_file.put_line(fnd_file.log, fnd_message.get);
                             -- Failed Plan Name collection for Summary Section
                             IF l_failed_plan_name IS NULL THEN
                                l_failed_plan_name := v_comp_plan_rec.name;
                             ELSE
                                l_failed_plan_name := l_failed_plan_name||', '||v_comp_plan_rec.name;
                             END IF;
                          END IF;
                       END IF;
                    ELSE
                       ROLLBACK TO Create_CompPlan;
                       -- Comp Plan Fail Message
                       fnd_message.set_name ('CN' , 'CN_COPY_CP_FAIL');
                       fnd_message.set_token('PLAN_NAME',v_comp_plan_rec.name);
                       fnd_file.put_line(fnd_file.log, fnd_message.get);
                       -- Failed Plan Name collection for Summary Section
                       IF l_failed_plan_name IS NULL THEN
                          l_failed_plan_name := v_comp_plan_rec.name;
                       ELSE
                          l_failed_plan_name := l_failed_plan_name||', '||v_comp_plan_rec.name;
                       END IF;
                    END IF;
                 ELSE
                    ROLLBACK TO Create_CompPlan;
                    -- Comp Plan Fail Message
                    fnd_message.set_name ('CN' , 'CN_COPY_CP_FAIL');
                    fnd_message.set_token('PLAN_NAME',v_comp_plan_rec.name);
                    fnd_file.put_line(fnd_file.log, fnd_message.get);
                    -- Failed Plan Name collection for Summary Section
                    IF l_failed_plan_name IS NULL THEN
                       l_failed_plan_name := v_comp_plan_rec.name;
                    ELSE
                       l_failed_plan_name := l_failed_plan_name||', '||v_comp_plan_rec.name;
                    END IF;
                 END IF;
              ELSE
                 ROLLBACK TO Create_CompPlan;
                 -- Comp Plan Fail Message
                 IF x_return_status = fnd_api.g_ret_sts_error THEN
                    fnd_message.set_name ('CN' , 'CN_COPY_CP_FAIL_EXPECTED');
                    fnd_message.set_token('PLAN_NAME',v_comp_plan_rec.name);
                    fnd_file.put_line(fnd_file.log, fnd_message.get);
                    fnd_file.put_line(fnd_file.log, '***ERROR: '||x_msg_data);
                 END IF;
                 IF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
                    fnd_message.set_name ('CN' , 'CN_COPY_CP_FAIL');
                    fnd_message.set_token('PLAN_NAME',v_comp_plan_rec.name);
                    fnd_file.put_line(fnd_file.log, fnd_message.get);
                    fnd_file.put_line(fnd_file.log, '***ERROR: '||x_msg_data);
                 END IF;
                 -- Failed Plan Name collection for Summary Section
                 IF l_failed_plan_name IS NULL THEN
                    l_failed_plan_name := v_comp_plan_rec.name;
                 ELSE
                    l_failed_plan_name := l_failed_plan_name||', '||v_comp_plan_rec.name;
                 END IF;
              END IF;
           END IF;
        END IF;

     /* ****************************** Main Loop End ************************** */
     END LOOP;
     fnd_file.put_line(fnd_file.log, '**************************************************************');
     fnd_file.put_line(fnd_file.log, '******************** END - PLAN COPY IMPORT ******************');
     fnd_file.put_line(fnd_file.log, '**************************************************************');

     -- ****************************************************************
     -- ***********  Summary of Import Process Log Messages  ***********
     -- ****************************************************************
     fnd_file.put_line(fnd_file.log, '**************************************************************');
     fnd_file.put_line(fnd_file.log, '***************************** SUMMARY ************************');
     fnd_file.put_line(fnd_file.log, '**************************************************************');
     -- Number of plans to Import
     fnd_message.set_name ('CN' , 'CN_COPY_CP_REQ_COUNT');
     fnd_message.set_token('COUNT',p_object_count);
     fnd_file.put_line(fnd_file.log, fnd_message.get);
     -- Number of Plans successfully created in target
     fnd_message.set_name ('CN' , 'CN_COPY_CP_SUCCESS_COUNT');
     fnd_message.set_token('COUNT',p_success_obj_count);
     fnd_file.put_line(fnd_file.log, fnd_message.get);
     -- Number of Plans reused in tagret
     fnd_message.set_name ('CN' , 'CN_COPY_CP_REUSE_COUNT');
     fnd_message.set_token('COUNT',p_reuse_obj_count);
     fnd_file.put_line(fnd_file.log, fnd_message.get);
     -- Number of Plans which were not imported due to error
     fnd_message.set_name ('CN' , 'CN_COPY_CP_FAILED_COUNT');
     fnd_message.set_token('LIST',l_failed_plan_name);
     fnd_file.put_line(fnd_file.log, fnd_message.get);
     fnd_file.put_line(fnd_file.log, '**************************************************************');
     fnd_file.put_line(fnd_file.log, '***************************** SUMMARY ************************');
     fnd_file.put_line(fnd_file.log, '**************************************************************');

     -- Set the Import Status to 'COMPLETE' OR 'FAILED'
     IF p_object_count = p_success_obj_count + p_reuse_obj_count THEN
        x_import_status := 'COMPLETED';
     ELSE
        x_import_status := 'FAILED';
     END IF;
  END IF;
  -- Standard call to get message count
  FND_MSG_PUB.Count_And_Get(
                   p_count    => x_msg_count,
                   p_data     => x_msg_data,
                   p_encoded  => FND_API.G_FALSE);
  EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_import_status := 'FAILED';
        FND_MSG_PUB.count_and_get(
        	   p_count   =>  x_msg_count,
        	   p_data    =>  x_msg_data,
 	           p_encoded =>  FND_API.G_FALSE);
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        x_import_status := 'FAILED';
        FND_MSG_PUB.count_and_get(
 	           p_count    =>   x_msg_count,
 	           p_data     =>   x_msg_data,
 	           p_encoded  =>   FND_API.G_FALSE);
    WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       x_import_status := 'FAILED';
       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
 	  FND_MSG_PUB.add_exc_msg(G_PKG_NAME,l_api_name);
       END IF;
       FND_MSG_PUB.count_and_get(
                   p_count    =>   x_msg_count,
 	           p_data     =>   x_msg_data,
 	           p_encoded  =>   FND_API.G_FALSE);
END Parse_XML;

    /**********************************************************************/
    /*                      API Body - Finish                             */
    /**********************************************************************/
END CN_COMP_PLAN_XMLCOPY_PVT;

/
