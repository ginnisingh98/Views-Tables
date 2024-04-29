--------------------------------------------------------
--  DDL for Package GMF_CMCOMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_CMCOMMON" AUTHID CURRENT_USER AS
/* $Header: gmfcmcos.pls 120.6.12010000.1 2008/07/30 05:37:06 appldev ship $ */

/* **************************************************************************************************
*  FUNCTION
*       cmcommon_get_cost
*  DESCRIPTION
*       Retrieves item cost, cost type and fmeff_id from gl_item_cst
*       and cmptcost_amt from gl_item_dtl get_cost should return the cost of the item
*       for the cost warehouse if there is a cost warehouse associated with the given
*        warehouse else it should return the cost of the item for the given warehouse
*
*  AUTHOR
*    Tapas Banerjee    			04/30/1992
*
*  INPUT PARAMETERS
*       item_id       = Item id
*       whse_code     = Warehouse code
*       orgn_code     = Organization Code
*       trans_date    = Date of item cost
*       cost_mthd     = cost method used
*       cmpntcls_id   = component class id
*       analysis_code = analysis code
*       retreive_ind  = 1  or  retreive just acctg_cost
*	                    2 retreive acctg_cost  all cmptcost_amts for itemcost
*                       3 retreive acctg_cost  cmptcost_amt for itemcost_id,
*                         cost_cmpntcls_id  cost_analysis
*	                    4 retrieve array of PPV/Matl CC costs, Cls Id/AnCd
*                         in P_cmpntcost_amt,P_cost_cmpntcls_id, P_cost_analysis_code
*	                    5 retrieve total of PPV/Matl CC costs in total_cost
*
*  OUTPUT PARAMETERS
*        P_acctg_cost         = used to receive acctg_cost
*        P_cost_type          = used to receive cost_type
*        P_fmeff_id              = used to receive fmeff_id
*        P_cmntcost_amt()     = used to receive cmptcost_amt from gl_item_dtl
*        P_cost_cmpntcls_id() = for retrieve mode 4 Component Class Ids
*        P_cost_analysis_code = for retrieve mode 4 Analysis Codes
*
*        total_cost           = This out parameter should be reffered only in the
*                               case when retrieve_ind value is passed as 1 or 5.
*        cost_mthd            = used to return gl_cost_mthd.
*
*            declare Global cached orgn_code and cost_mthd_code vars.
*            If repeated calls are made to this routine for same organization
*            and no cost method is passed as a parameter than it will make
*            use of these global cached orgn code and cached cost method and
*            will not try to get cost method from the GL Fiscal policy. The
*            Package variable P_cached_cost_whse_code is used to hold the cost
*            warehouse value if retrieved otherwise it will hold the value of
*            the warehouse passed to this routine. The package variable
*            P_cached_cost_basis is used to hold cost_basis retrieved from
*            fiscal Policy.
*
*        P_cached_orgn_code       = Caches orgn_Code
*        P_cached_gl_cost_mthd    = Caches cost_mthd_code
*        P_cached_cost_basis      = Caches cost_basis
*        P_cached_cost_whse_code  = Caches cost_whse_code
*
*       The variable P_no_of_rows is populated by get_cost routine when retrieve_ind is 2,3,4
*       to notify how many array cell rows are populated with values.
*
*       P_no_of rows   = Caches the no of rows, retrieved and stored in array.
*
*      RETURNS (choose one set)
*            1  success
*           -1  No cost found.
*           -2  Error in parameters passed
*           -3  No GL Fiscal policy ( Unable to get the cost method from Fiscal plcy)
*    HISTORY
*      Sukarna Reddy  Programmer         09/26/98		Converted JPL to PLSQL.
*
*	20-Feb-2002 Uday Moogala  Bug# 2231928
*	Added a new function to get_sort_sequence to return sort_sequence for
*	the cost_cmpntcls_id from cm_cmpt_mst table. Used in CMCSDED forms
*	This Level and Lower Level detail blocks ORDER BY property.
*       30/Oct/2002  R.Sharath Kumar    Bug# 2641405
*                                       Added NOCOPY hint
**************************************************************************************  */

   TYPE cmpnt_cost IS TABLE OF gl_item_dtl.cmptcost_amt%TYPE
   INDEX BY BINARY_INTEGER;

   TYPE cmpnt_id IS TABLE OF cm_cmpt_mst.cost_cmpntcls_id%TYPE
   INDEX BY BINARY_INTEGER;

   TYPE analysis_code IS TABLE OF cm_alys_mst.cost_analysis_code%TYPE
   INDEX BY BINARY_INTEGER;

   TYPE gmf_lot_cost_cmpnts IS TABLE OF GMF_LOT_COST_DETAILS%ROWTYPE
   INDEX BY BINARY_INTEGER;


   P_cmpntcost_amt               cmpnt_cost;
   P_cost_cmpntcls_id            cmpnt_id;
   P_cost_analysis_code1         analysis_code;

   P_acctg_cost 		            gl_item_cst.acctg_cost%TYPE;     /* used to receive acctg_cost*/
   P_cost_type  		            gl_item_cst.cost_type%TYPE;      /* used to receive cost_type*/
   P_fmeff_id   		            gl_item_cst.fmeff_id%TYPE;       /* used to receive fmeff_id*/
   P_cached_gl_cost_mthd         gmf_fiscal_policies.cost_type_id%TYPE;
   P_cached_cost_whse_code       cm_whse_asc.organization_id%TYPE;
   P_cached_orgn_code            sy_orgn_mst.orgn_code%TYPE;
   P_cached_co_code              sy_orgn_mst.co_code%TYPE;

   P_cached_legal_entity_id      gmf_fiscal_policies.legal_entity_id%TYPE;
   P_cached_cost_organization_id cm_whse_asc.cost_organization_id%TYPE;
   P_cached_cost_basis           gmf_fiscal_policies.cost_basis%TYPE;
   P_cached_cost_type_id         gmf_fiscal_policies.cost_type_id%TYPE;

   /****************************************************************************************
   * The variable P_no_of_rows is populated by get_cost routine when retrieve_ind is 2,3,4 *
   * to notify how many array cell rows are populated with values.                         *
   ****************************************************************************************/

   P_no_of_rows               NUMBER DEFAULT 0;

   FUNCTION cmcommon_get_cost
   (
   item_id              IN            NUMBER,
   whse_code            IN            VARCHAR2,
   orgn_code            IN            VARCHAR2,
   trans_date           IN            DATE,
   cost_mthd            IN OUT NOCOPY VARCHAR2,
   cmpntcls_id          IN OUT NOCOPY NUMBER,
   analysis_code        IN OUT NOCOPY VARCHAR2,
   retreive_ind         IN            NUMBER,
   total_cost              OUT NOCOPY NUMBER,
   no_of_rows              OUT NOCOPY NUMBER
   )
   RETURN NUMBER;

   /**********************************************************************************************
   *    The procedure below should be used only after calling cmcommon_get_cost                  *
   *    function to retrieve the multiple cost . This procedure should be invoked                *
   *    when retrive_ind value is 2,3 or 4.                                                      *
   *                                                                                             *
   *    The procedure below returns a value in v_status                                          *
   *    -1 - no cost compoments exist or if v_index value                                        *
   *    is 0 or if it exceeds the value more than P_no_of_rows variable.                         *
   *    0 - successful                                                                           *
   * USAGE                                                                                       *
   *    Use this procedure in a LOOP to retrive the values row by row by specifying              *
   *    the v_index                                                                              *
   * DESCRIPTION                                                                                 *
   *    Helps in retrieving the values of cost_cmpntcls id and analysis_code                     *
   *    cmpnt_amt when retrieve_ind is 4 and retrieves the cmpnt_amt when retrieved              *
   *    ind is  2 or 3. The retrieve ind is introduced in this procedure for the reason          *
   *    that the arrays such as P_cost_cmpntcls_id and P_cost_analysis_code and P_cmpntcost_amt  *
   *    gets populated only when retrieve ind is 4 and would not get populated when retrieve ind *
   *    is 2 or 3 except for P_cmpntcost_amt as a result we end up accessing junk memory array   *
   *    cells which does not hold any data. Ensure that you pass same indicator value used for   *
   *    get_cost routine before invoking this routine                                            *
   **********************************************************************************************/

   PROCEDURE get_multiple_cmpts_cost
   (
   v_index              IN             NUMBER,
   v_cost_cmpntcls_id      OUT NOCOPY  NUMBER,
   v_cost_analysis_code    OUT NOCOPY  VARCHAR2,
   v_cmpnt_amt             OUT NOCOPY  NUMBER,
   v_retrieve_ind       IN             NUMBER,
   v_status                OUT NOCOPY  NUMBER
   );

   FUNCTION get_sort_sequence
   (
   v_cost_cmpntcls_id   IN             NUMBER
   )
   RETURN NUMBER;

   FUNCTION unit_cost
   (
   v_item_id            IN             NUMBER,
   v_whse_code          IN             VARCHAR2,
   v_orgn_code          IN             VARCHAR2,
   v_trans_date         IN             DATE
   )
   RETURN NUMBER;

   FUNCTION cmcommon_get_cost
   (
   p_item_id 	         IN             NUMBER,
   p_whse_code          IN             VARCHAR2,
   p_orgn_code          IN             VARCHAR2,
   p_trans_date         IN             DATE,
   p_cost_mthd          IN OUT NOCOPY  VARCHAR2,
   p_cmpntcls_id        IN OUT NOCOPY  NUMBER,
   p_analysis_code      IN OUT NOCOPY  VARCHAR2,
   p_retrieve_ind       IN             NUMBER,
   x_total_cost            OUT NOCOPY  NUMBER,
   x_no_of_rows            OUT NOCOPY  NUMBER,
   p_lot_id	 	         IN 	         NUMBER,
   p_trans_id	         IN 	         NUMBER
   )
   RETURN NUMBER;

   /*********************************************************
   * Added by Anand Thiyagarajan ANTHIYAG 15-DEC-2004 start *
   *********************************************************/

   FUNCTION Get_Process_Item_Cost
   (
     p_api_version               IN             NUMBER
   , p_init_msg_list             IN             VARCHAR2 := FND_API.G_FALSE
   , x_return_status                OUT NOCOPY  VARCHAR2
   , x_msg_count                    OUT NOCOPY  NUMBER
   , x_msg_data                     OUT NOCOPY  VARCHAR2
   , p_inventory_item_id         IN             NUMBER         /* Item_Id */
   , p_organization_id           IN             NUMBER         /* Inventory Organization Id */
   , p_transaction_date          IN             DATE           /* Cost as on date */
   , p_detail_flag               IN             NUMBER         /* same as retrieve indicator: */ /*  1 = total cost, 2 = details; */ /* 3 = cost for a specific component class/analysis code, etc. */
   , p_cost_method               IN OUT NOCOPY  VARCHAR2       /* OPM Cost Method */
   , p_cost_component_class_id   IN OUT NOCOPY  NUMBER
   , p_cost_analysis_code        IN OUT NOCOPY  VARCHAR2
   , x_total_cost                   OUT NOCOPY  NUMBER         /* total cost */
   , x_no_of_rows                   OUT NOCOPY  NUMBER         /* number of detail rows retrieved */
   )
   RETURN NUMBER ;

   FUNCTION Get_Process_Item_Cost
   (
     p_api_version               IN             NUMBER
   , p_init_msg_list             IN             VARCHAR2 := FND_API.G_FALSE
   , x_return_status                OUT NOCOPY  VARCHAR2
   , x_msg_count                    OUT NOCOPY  NUMBER
   , x_msg_data                     OUT NOCOPY  VARCHAR2
   , p_inventory_item_id         IN             NUMBER                       /* Item_Id */
   , p_organization_id           IN             NUMBER                       /* Inventory Organization Id */
   , p_transaction_date          IN             DATE                         /* Cost as on date */
   , p_detail_flag               IN             NUMBER                       /* same as retrieve indicator: */ /*  1 = total cost, 2 = details; */ /* 3 = cost for a specific component class/analysis code, etc. */
   , p_cost_method               IN OUT NOCOPY  VARCHAR2                     /* OPM Cost Method */
   , p_cost_component_class_id   IN OUT NOCOPY  NUMBER
   , p_cost_analysis_code        IN OUT NOCOPY  VARCHAR2
   , x_total_cost                   OUT NOCOPY  NUMBER                        /* total cost */
   , x_no_of_rows                   OUT NOCOPY  NUMBER                        /* number of detail rows retrieved */
   , p_lot_number                IN             VARCHAR2                      /* Lot Number for the Item/Lot */
   , p_transaction_id            IN             NUMBER                        /* Transaction_id from MMT */
   )
   RETURN NUMBER ;

   FUNCTION is_batch_cost_frozen
   (
   p_api_version        IN             NUMBER
   , p_init_msg_list    IN             VARCHAR2 := FND_API.G_FALSE
   , p_commit           IN             VARCHAR2 := FND_API.G_FALSE
   , x_return_status       OUT NOCOPY  VARCHAR2
   , x_msg_count           OUT NOCOPY  NUMBER
   , x_msg_data            OUT NOCOPY  VARCHAR2
   , p_batch_id         IN             gme_batch_header.batch_id%TYPE
   )
   RETURN BOOLEAN;

   /*******************************************************
   * Added by Anand Thiyagarajan ANTHIYAG 15-DEC-2004 End *
   *******************************************************/

   /**************************************
   *   OPM INVCONV umoogala  10-Feb-2004 *
   **************************************/

   PROCEDURE get_process_item_unit_price
   (
   p_inventory_item_id        IN             NUMBER
   , p_organization_id        IN             NUMBER
   , p_trans_date             IN             DATE
   , x_unit_price                OUT NOCOPY  NUMBER
   , x_return_status             OUT NOCOPY  VARCHAR2
   );

   PROCEDURE get_process_item_price
   (
   p_inventory_item_id              IN             NUMBER
   , p_trans_qty                    IN             NUMBER
   , p_trans_uom                    IN             VARCHAR2
   , p_trans_date                   IN             DATE
   , p_src_organization_id          IN             NUMBER
   , p_src_process_enabled_flag     IN             VARCHAR2
   , p_dest_organization_id         IN             NUMBER
   , p_dest_process_enabled_flag    IN             VARCHAR2
   , p_source                       IN             VARCHAR2
   , x_unit_price                      OUT NOCOPY  NUMBER
   , x_unit_price_priuom               OUT NOCOPY  NUMBER
   , x_currency_code                   OUT NOCOPY  VARCHAR2
   , x_incr_transfer_price             OUT NOCOPY  NUMBER
   , x_incr_currency_code              OUT NOCOPY  VARCHAR2
   , x_return_status                   OUT NOCOPY  NUMBER
   );

   /******************************************
   *   End OPM INVCONV umoogala  10-Feb-2004 *
   ******************************************/

   FUNCTION process_item_unit_cost
   (
   p_inventory_item_id              IN                NUMBER,
   p_organization_id                IN                NUMBER,
   p_transaction_date               IN                DATE
   )
   RETURN NUMBER;

   FUNCTION process_item_unit_cost
   (
   p_inventory_item_id              IN                NUMBER,
   p_organization_id                IN                NUMBER,
   p_transaction_date               IN                DATE,
   p_lot_number                     IN                VARCHAR2,
   p_transaction_id                 IN                NUMBER
   )
   RETURN NUMBER ;

  /***************************************************
  * Bug#5436964 ANTHIYAG BatchesXPeriods 20-Feb-2007 *
  ***************************************************/

   FUNCTION get_cmpt_cost
   (
   p_inventory_item_id              IN                NUMBER,
   p_organization_id                IN                NUMBER,
   p_transaction_date               IN                DATE,
   p_cost_type_id                   IN                NUMBER,
   p_prior_period_cost              IN                NUMBER
   )
   RETURN NUMBER;

   FUNCTION get_rsrc_cost
   (
   p_resources                      IN                VARCHAR2,
   p_organization_id                IN                NUMBER,
   p_transaction_date               IN                DATE,
   p_cost_type_id                   IN                NUMBER,
   p_prior_period_cost              IN                NUMBER
   )
   RETURN NUMBER;

  /***************************************************
  * Bug#5436964 ANTHIYAG BatchesXPeriods 20-Feb-2007 *
  ***************************************************/

END GMF_CMCOMMON ;

/
