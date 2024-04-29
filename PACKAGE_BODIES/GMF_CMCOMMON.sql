--------------------------------------------------------
--  DDL for Package Body GMF_CMCOMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_CMCOMMON" AS
/* $Header: gmfcmcob.pls 120.15.12010000.2 2008/10/21 20:52:33 rpatangy ship $ */

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
*     Manish Gupta               02-MAR-99      Bug 841019
*					     Commented Package DBMS_OUTPUT.
*	14-Dec-1999 Rajesh Seshadri Bug 1111582 - Get cost returns cost even if cost
*		does not exist for the date passed in.  Apparently the query did not
*		use the trans_date or whse_code.  Modified the query.
*		Also removed the usage_ind condition from the queries when retrieve_ind
*		is 4 or 5 [PPV calculations use retrieve_ind of 4 or 5].  Refer B1019295
*		Introduced cmcommon_log for printing trace messages
*	20-Feb-2002 Uday Moogala  Bug# 2231928
*		Added a new function to get_sort_sequence to return sort_sequence for
*		the cost_cmpntcls_id from cm_cmpt_mst table. Used in CMCSDED forms
*		This Level and Lower Level detail blocks ORDER BY property.
*       30/Oct/2002  R.Sharath Kumar    Bug# 2641405
*               Added NOCOPY hint
*     28-Sep-2001 Venkat Chukkapalli Bug 1926529 - Modified code to use cost
*	warehouse org in retrieving cost when cost warehouse association exists.
**************************************************************************************  */

   /*********************************************************
   * Added by Anand Thiyagarajan ANTHIYAG 15-DEC-2004 Start *
   *********************************************************/

   G_PKG_NAME      CONSTANT 	VARCHAR2(30):=    'GMF_CMCOMMON';
   G_DEBUG_LEVEL			        NUMBER	:=    FND_MSG_PUB.G_Msg_Level_Threshold;

   /*******************************************************
   * Added by Anand Thiyagarajan ANTHIYAG 15-DEC-2004 End *
   *******************************************************/

   PROCEDURE cmcommon_log( pmsg IN VARCHAR2 );

   FUNCTION cmcommon_get_cost(item_id    IN              NUMBER,
	                       whse_code      IN              VARCHAR2,
	                       orgn_code      IN              VARCHAR2,
	                       trans_date     IN              DATE,
		                    cost_mthd      IN   OUT NOCOPY VARCHAR2,
		                    cmpntcls_id    IN   OUT NOCOPY NUMBER,
		                    analysis_code  IN   OUT NOCOPY VARCHAR2,
		                    retreive_ind   IN              NUMBER,
		                    total_cost     OUT      NOCOPY NUMBER,
		                    no_of_rows     OUT      NOCOPY NUMBER)
      RETURN NUMBER IS
-- PK Eliminated obsolete code  Get_Process_Item_Cost is proper 12.0 procedure.

  BEGIN
	RETURN(1);
 END cmcommon_get_cost;


 /***************************************************************************************************************
  *  PROCEDURE
  *      get_multiple_cmpts_cost
  *
  *  DESCRIPTION
  *    Helps in retrieving the values of cost_cmpntcls id and analysis_code
  *    cmpnt_amt when retrieve_ind is 4 and retrieves the cmpnt_amt when retrieved
  *    ind is  2 or 3. The retrieve ind is introduced in this procedure for the reason
  *    that the arrays such as P_cost_cmpntcls_id and P_cost_analysis_code and P_cmpntcost_amt
  *    gets populated only when retrieve ind is 4 and would not get populated when retrieve ind
  *    is 2 or 3 except for P_cmpntcost_amt.As a result we end up accessing junk memory array
  *    cells which does not hold any data. Ensure that you pass same indicator value used for
  *    get_cost routine before invoking this routine.
  *
  *
  *  AUTHOR
  *    sukarna Reddy  			09/26/98
  *
  *  ASSUMPTION
  *    Before calling this procedure it is assumed that cmcommon_get_cost routine is called.
  *
  *  INPUT PARAMETERS
  *  v_index                 =  Index of the array cell for P_cost_analysis_code() or
  *		        			    or P_cost_cmpntcls_id(),P_cmpntcost_amt().
  *	 v_retrieve_ind          =
  *                  	        2 Retreive acctg_cost  all cmptcost_amts for itemcost
  * 		          			3 Retreive acctg_cost  cmptcost_amt for itemcost_id,
  *                      	      cost_cmpntcls_id  cost_analysis
  *                     	    4 retrieve array of PPV/Matl CC costs, Cls Id/AnCd
  *                       	      in P_cmpntcost_amt,P_cost_cmpntcls_id, P_cost_analysis_code
  *    OUTPUT PARAMETERS
  *      v_cost_cmpntcls_id     = refer to this value only when retrieve_ind is 4
  *      v_cost_analysis_code   = refer to this value only when retrieve_ind is 4
  *      v_cmpnt_amt            = refer to this value only when retrieve_ind is 2,3,4
  *      v_status 	            = 0  sucessfull
  *	                             -1  no cost compoments exist or if v_index value
  *			    		    	     is 0 or if it exceeds the value more than
  *			    		    	     P_no_of_rows variable.
  *
  *
  *    USAGE
  *       The procedure below should be used only after calling cmcommon_get_cost
  *       function to retrieve the multiple cost.Use this procedure in a LOOP
  *       to retrive the values row by row by specifying the v_index.
  *
  *     HISTORY
  *
  *
  ****************************************************************************************************************/

  PROCEDURE get_multiple_cmpts_cost(v_index IN NUMBER,
 		                    v_cost_cmpntcls_id   OUT NOCOPY NUMBER,
				    v_cost_analysis_code OUT NOCOPY VARCHAR2,
                                    v_cmpnt_amt          OUT NOCOPY NUMBER,
                                    v_retrieve_ind       IN         NUMBER,
			            v_status 		 OUT NOCOPY NUMBER) IS
  BEGIN
    /*The variable P_no_of_rows is populated by get_cost routine when retrieve_ind is 2,3,4
      to notify how many array cell rows are populated with values. */

    IF ( v_index <= P_no_of_rows AND v_index > 0) THEN
      IF (v_retrieve_ind IN (2,3)) THEN
        v_cmpnt_amt          := P_cmpntcost_amt(v_index);
        v_status := 0;
      ELSIF(v_retrieve_ind = 4) THEN
        v_cost_cmpntcls_id   := P_cost_cmpntcls_id(v_index);
        v_cost_analysis_code := P_cost_analysis_code1(v_index);
        v_cmpnt_amt          := P_cmpntcost_amt(v_index);
        v_status := 0;
      END IF;
    ELSE
      v_status := -1;
    END IF;
  END get_multiple_cmpts_cost;

/**
* Output log messages
*/

 PROCEDURE cmcommon_log( pmsg IN VARCHAR2 )
 IS
	l_dt VARCHAR2(64);

 BEGIN
	l_dt := TO_CHAR(SYSDATE, 'yyyy-mm-dd hh24:mi:ss');
   fnd_file.put_line(fnd_file.log,pmsg||''||l_dt);
 END cmcommon_log;

 /************************************************************************************
  *  PROCEDURE
  *      get_sort_sequence
  *
  *  DESCRIPTION
  *	This function will return sort_sequence for incomming
  *	the cost_cmpntcls_id from cm_cmpt_mst table. Used in CMCSDED forms
  *	This Level and Lower Level detail blocks ORDER BY property.
  *
  *  AUTHOR
  *    Uday Moogala  20-Feb-2002  Bug 2231928
  *
  *  INPUT PARAMETERS
  *   	v_cost_cmpntcls_id	Cost Component Class Id comming from form CMCSDED.fmb
  *
  *  OUTPUT PARAMETERS
  *	Returns sort sequence
  *
  *  HISTORY
  *
  **************************************************************************************/

 FUNCTION get_sort_sequence(v_cost_cmpntcls_id  IN NUMBER) RETURN NUMBER
 IS
   CURSOR sort_seq(p_ccc_id NUMBER)
   IS
     SELECT DECODE(sort_sequence, 0, NULL, sort_sequence) sort_sequence
       FROM cm_cmpt_mst
      WHERE cost_cmpntcls_id = p_ccc_id ;

   l_sort_sequence	cm_cmpt_mst.sort_sequence%TYPE;

 BEGIN

   OPEN sort_seq(v_cost_cmpntcls_id) ;
   FETCH sort_seq INTO l_sort_sequence;
   CLOSE sort_seq ;

   RETURN l_sort_sequence;

 EXCEPTION
   WHEN OTHERS THEN
     RETURN 0 ;
 END get_sort_sequence;

 /************************************************************************************
  *  FUNCTION
  *     unit_cost
  *
  *  DESCRIPTION
  *	This is a wrapper function which calls cmcommon_get_cost to return
  *     the cost.This function is called from PPV report(POXRCPPV.rdf)
  *
  *  AUTHOR
  *    Mahesh Chandak 6-MAR-2002  Bug 2245477
  *
  *  INPUT PARAMETERS
  *   v_item_id
  *   v_whse_code
  *   v_orgn_code
  *   v_trans_date
  *
  *  OUTPUT PARAMETERS
  *	Returns cost of an item.
  *
  *  HISTORY
  *
  **************************************************************************************/

FUNCTION unit_cost(v_item_id     IN NUMBER,
                   v_whse_code   IN VARCHAR2,
                   v_orgn_code   IN VARCHAR2,
                   v_trans_date  IN DATE )   RETURN NUMBER IS
x_unitcost  	NUMBER;
x_ret       	NUMBER;
x_cmpntclsid   	NUMBER;
x_analysiscode  VARCHAR2(100);
x_costmthd      VARCHAR2(100);
x_norows        NUMBER;

-- PK Eliminated obsolete code

BEGIN

          RETURN(null);


EXCEPTION
WHEN OTHERS THEN
     RETURN(null) ;
END unit_cost;



/* **************************************************************************************************
*  FUNCTION
*       cmcommon_get_cost
*  DESCRIPTION
*
*	This function is an overloaded function of get cost routine. This function
*	can be used to get costs for non lot cost method or lot cost method.
*
*	For non lot cost method this function retrieves item cost, cost type
*	and fmeff_id from gl_item_cst  and cmptcost_amt from gl_item_dtl
*	get_cost should return the cost of the item for the cost warehouse
*	if there is a cost warehouse associated with the given warehouse else
*	it should return the cost of the item for the given warehouse
*
*  AUTHOR
* 	Sukarna Reddy 		Dt 20-OCT-2003  Bug 3196846
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
*	                2 retreive acctg_cost  all cmptcost_amts for itemcost
*                       3 retreive acctg_cost  cmptcost_amt for itemcost_id,
*                         cost_cmpntcls_id  cost_analysis
*	                4 retrieve array of PPV/Matl CC costs, Cls Id/AnCd
*                         in P_cmpntcost_amt,P_cost_cmpntcls_id, P_cost_analysis_code
*	                5 retrieve total of PPV/Matl CC costs in total_cost
	lot_id	      = Lot id. Should be passed to retrieve specific lot cost.
	trans_id      = Lot cost transaction id.
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
**************************************************************************************  */


  FUNCTION cmcommon_get_cost  ( p_item_id 	 IN              NUMBER
  	                       ,p_whse_code      IN              VARCHAR2
	                       ,p_orgn_code      IN              VARCHAR2
	                       ,p_trans_date     IN              DATE
		               ,p_cost_mthd      IN   OUT NOCOPY VARCHAR2
		               ,p_cmpntcls_id    IN   OUT NOCOPY NUMBER
		               ,p_analysis_code  IN   OUT NOCOPY VARCHAR2
		               ,p_retrieve_ind   IN              NUMBER
		               ,x_total_cost    OUT	 NOCOPY  NUMBER
		               ,x_no_of_rows    OUT      NOCOPY  NUMBER
		               ,p_lot_id	IN 	 NUMBER
		               ,p_trans_id	IN 	 NUMBER)
  RETURN NUMBER IS

  -- PK Eliminated obsolete code  Get_Process_Item_Cost is proper 12.0 procedure.


  BEGIN

    RETURN(1);

  END;

   /*********************************************************
   * Added by Anand Thiyagarajan ANTHIYAG 15-DEC-2004 Start *
   *********************************************************/

   /***********************************************************************************************
   *    FUNCTION                                                                                  *
   *       Get_Process_Item_Cost                                                                  *
   *                                                                                              *
   *    DESCRIPTION                                                                               *
   *       This function is an overloaded function of get cost routine. This function             *
   *       can be used to get costs for non lot cost method or lot cost method.                   *
   *                                                                                              *
   *       For non lot cost method this function retrieves item cost, cost type                   *
   *       and fmeff_id from gl_item_cst  and cmptcost_amt from gl_item_dtl                       *
   *       get_cost should return the cost of the item for the cost warehouse                     *
   *       if there is a cost warehouse associated with the given warehouse else                  *
   *       it should return the cost of the item for the given warehouse                          *
   *                                                                                              *
   *    AUTHOR                                                                                    *
   *       Anand Thiyagarajan      01-JUN-2005                                                    *
   *                                                                                              *
   *    INPUT PARAMETERS                                                                          *
   *       inventory_item_id       =     Item id                                                  *
   *       Organization_id         =     Organization                                             *
   *       transaction_date        =     Date of item cost                                        *
   *       cost_mthd               =     cost method used                                         *
   *       cost_component_class_id =     component class id                                       *
   *       analysis_code           =     analysis code                                            *
   *       detail_flag             =     1  => retreive just acctg_cost                           *
   *                                     2  => retreive acctg_cost all cmptcost_amts for itemcost *
   *                                     3  => retreive acctg_cost  cmptcost_amt for itemcost_id, *
   *                                           cost_cmpntcls_id  cost_analysis Code               *
   *                                                                                              *
   *    OUTPUT PARAMETERS                                                                         *
   *       total_cost              =     This out parameter should be reffered only in the        *
   *                                     case when retrieve_ind value is passed as 1              *
   *                                                                                              *
   *    RETURNS (choose one set)                                                                  *
   *        0  - success                                                                          *
   *        1 - could not get transfer_price                                                      *
   *        2 - could not get item unit cost                                                      *
   *        3 - uom conversion error                                                              *
   *                                                                                              *
   *    HISTORY                                                                                   *
   *                                                                                              *
   ***********************************************************************************************/
   FUNCTION Get_Process_Item_Cost
   (
   p_api_version                 IN             NUMBER
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
   RETURN NUMBER
   IS

      /******************
      * Local Variables *
      ******************/

      l_api_name		   CONSTANT 		VARCHAR2(30)	:= 'Get_Process_Item_Cost' ;
      l_api_version		CONSTANT 		NUMBER		:= 1.0 ;

      X_itemcost_id                    gl_item_cst.itemcost_id%TYPE;
	   X_cost_organization_id           cm_whse_asc.cost_organization_id%TYPE;
      X_no_recs                        NUMBER(10);
	   i                                INTEGER;
	   p_cost_type_id                   cm_mthd_mst.cost_type_id%type;
      l_cost_type		                  cm_mthd_mst.cost_type%type;

      /********************************************
      * Change this only when absolutely required *
      ********************************************/

      l_debug_flag NUMBER := 0;

      /**********
      * Cursors *
      **********/

      /*******************************************************************
      * Retrieves the cost Organizations for the specified Organizations *
      *******************************************************************/

      CURSOR      Cur_cmwhse_asc
      (
      V_ORGANIZATION_ID          IN                NUMBER,
      v_trans_date               IN                DATE
      )
      IS
		SELECT	   cost_ORGANIZATION_ID
		FROM	      cm_whse_asc
		WHERE	      ORGANIZATION_ID = V_ORGANIZATION_ID
		AND	      eff_start_date <= v_trans_date
		AND	      eff_end_date   >= v_trans_date
		AND	      delete_mark = 0;

      /**********************************************************************
      *    Retrieves the fiscal policy for warehouse organization's company *
      **********************************************************************/

      CURSOR      Cur_whse_orgn_plcy_mst
      (
      v_ORGANIZATION_ID          IN                NUMBER
      )
      IS
      SELECT      o.organization_id,
                  f.legal_entity_id,
                  f.cost_type_id,
                  f.cost_basis
      FROM        hr_organization_information o,
                  gmf_fiscal_policies f
      WHERE       o.organization_id  = v_organization_id
      AND         o.org_information_context = 'Accounting Information'
      AND         o.org_information2 = f.LEGAL_ENTITY_ID
      AND         f.delete_mark  = 0;

	    Cur_whse_orgn_plcy_temp  Cur_whse_orgn_plcy_mst%ROWTYPE;

      /***********************************************************************************
      * Retrieves the previous calendar,period and end_date for the specified trans_date *
      ***********************************************************************************/

      CURSOR      Cur_get_calprd
      (
      v_legal_entity_id          IN                NUMBER,
		v_trans_date               IN                DATE,
	   v_cost_type_id             IN                NUMBER
      )
      IS
		SELECT	   mst.calendar_code,
			         mst.period_code,
			         mst.end_date,
			         mst.period_id
		FROM	      cm_cldr_mst_v mst
		WHERE	      mst.delete_mark = 0
      AND	      mst.end_date < v_trans_date
		AND	      mst.cost_type_id = v_cost_type_id
		AND	      mst.legal_entity_id = v_legal_entity_id
		ORDER BY    3 desc;

	   Cur_get_calprd_tmp  Cur_get_calprd%ROWTYPE;

      /********************************************************************
      * Retrieves cost for a cost warehouse, organization and cost method *
      ********************************************************************/

      CURSOR      Cur_get_pr_cost
      (
      v_ORGANIZATION_ID          IN                NUMBER,
		v_item_id                  IN                NUMBER,
		v_cost_type_id             IN                NUMBER,
      v_period_id                IN                NUMBER
      )
      IS
		SELECT	   acctg_cost,
			         cost_type,
			         fmeff_id,
			         itemcost_id
		FROM	      gl_item_cst
		WHERE	      organization_id	= v_organization_id
      AND	      inventory_item_id		= v_item_id
		AND	      cost_type_id	= v_cost_type_id
      AND	      period_id	= v_period_id;

	   Cur_get_pr_cost_tmp Cur_get_pr_cost%ROWTYPE;

      /**************************************************
      * Retrieves the cost directly if cost basis is 1. *
      **************************************************/

      CURSOR      Cur_get_cost_direct
      (
      v_organization_id          IN                NUMBER,
		v_item_id                  IN                NUMBER,
		v_cost_type_id             IN                VARCHAR2,
		v_trans_date               IN                DATE
      )
      IS
		SELECT	   acctg_cost,
			         cost_type,
			         fmeff_id,
			         itemcost_id
		FROM 	      gl_item_cst
		WHERE 	   organization_id	= v_organization_id
      AND 	      inventory_item_id		= v_item_id
		AND 	      cost_type_id	= v_cost_type_id
		AND	      end_date	>= v_trans_date
		AND	      start_date	<= v_trans_date;

	   Cur_get_cost_direct_tmp  Cur_get_cost_direct%ROWTYPE;

      /**********************************************************************************
      * Retrieves the component cost for a pariticular cost component and analysis code *
      **********************************************************************************/

      CURSOR      Cur_item_dtl
      (
      v_itemcost_id              IN                NUMBER,
	   v_cmpntcls_id              IN                NUMBER,
	   v_analysis_code            IN                VARCHAR2
      )
      IS
		SELECT	   cmptcost_amt
		FROM 	      gl_item_dtl
		WHERE 	   itemcost_id		= v_itemcost_id
		AND	      cost_cmpntcls_id	= v_cmpntcls_id
		AND	      cost_analysis_code	= v_analysis_code;

	   Cur_item_dtl_tmp  Cur_item_dtl%ROWTYPE;

      /**************************************************************************
      * Retrieves all the cost components for a component class and itemcost_id *
      * There could be many analysis codes for a given component class          *
      **************************************************************************/

      CURSOR      Cur_item_cost
      (
      v_itemcost_id              IN                NUMBER
      )
      IS
		SELECT	   cmptcost_amt,
			         i.cost_cmpntcls_id,
			         i.cost_analysis_code
		FROM        gl_item_dtl i,
                  cm_cmpt_mst c
		WHERE       i.itemcost_id		= v_itemcost_id
		AND	      i.cost_cmpntcls_id	= c.cost_cmpntcls_id
		AND	      c.ppv_ind 		= 1;

      /*****************************************************************************
      * Retrieves Total cost of the specified cost componentcls id and itemcost_id *
      *****************************************************************************/

      CURSOR      Cur_glitmdtl
      (
      v_itemcost_id              IN                NUMBER
      )
      IS
		SELECT	   SUM(cmptcost_amt)
		FROM 	      gl_item_dtl i,
			         cm_cmpt_mst c
		WHERE 	   i.itemcost_id		= v_itemcost_id
		AND	      i.cost_cmpntcls_id	= c.cost_cmpntcls_id
		AND	      c.ppv_ind		= 1;

      /***************************************************
      * Retrieves Cost Tpe FOR the Cost TYPE Id Selected *
      ***************************************************/

      CURSOR      Cur_Get_mthd_type
      (
      v_cost_type_id             IN                NUMBER
      )
      IS
      SELECT      cost_type
      FROM        cm_mthd_mst
      WHERE       cost_type_id = v_cost_type_id;



   BEGIN



      l_debug_flag := G_DEBUG_LEVEL;

      /*************************************************************
      * Initialize message list if p_init_msg_list is set to TRUE. *
      *************************************************************/
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
         FND_MSG_PUB.initialize;
      END IF;

      /*************************************************
      * Standard call to check for call compatibility. *
      *************************************************/

      IF NOT FND_API.Compatible_API_Call
      (
      l_api_version,
      p_api_version,
      l_api_name,
      G_PKG_NAME
      )  THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      /******************************************
      * Initialize API return status to success *
      ******************************************/
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_msg_count := 0;
      x_msg_data := NULL;

	   IF (l_debug_flag > 0) THEN
         cmcommon_log( 'Input parameters: Inventory Item Id: ' || p_inventory_item_id || ' Org: ' || p_Organization_id ||' Cost Date: ' || to_char(p_transaction_date, 'yyyy-mm-dd hh24:mi:ss') );
		   cmcommon_log( 'Input cost type: ' || nvl(to_char(p_cost_type_id),'null-cost-type') );
	   END IF;

      IF (p_inventory_item_id IS NULL OR p_organization_id IS NULL  OR p_transaction_date IS NULL) THEN
         IF( l_debug_flag > 0 ) THEN
	         cmcommon_log( 'Insufficient input parameters; exit status: -2' );
	      END IF;
         RETURN(-2);
      END IF;

      /********************************************************************************
      * The loop below is used to initialize the array if populated by previous call. *
      ********************************************************************************/
      IF (P_no_of_rows > 0) THEN
         FOR i IN 1..P_no_of_rows LOOP
            P_cmpntcost_amt(i) := NULL;
            P_cost_cmpntcls_id(i) := NULL;
            P_cost_analysis_code1(i)  := NULL;
         END LOOP;
      END IF;

      P_no_of_rows := 0;
      P_acctg_cost := NULL;

      /***********************************
      * Get the Costing Whse Association *
      ***********************************/
	   OPEN Cur_cmwhse_asc  (
                           p_organization_id,
                           p_transaction_date
                           );
	   FETCH Cur_cmwhse_asc INTO X_cost_organization_id;

      /*************************************************************************
      * In Case there is no Organizations association for a given Organization *
      * it should go ahead and return the cost for the given organization.     *
      *************************************************************************/
      IF Cur_cmwhse_asc%NOTFOUND THEN
	      X_cost_organization_id := p_organization_id;
	      IF l_debug_flag > 0 THEN
		      cmcommon_log('Using Inv org ' || X_cost_organization_id || ' to retrieve cost' );
	      END IF;
      ELSE
         NULL;
         IF l_debug_flag > 0 THEN
	         cmcommon_log('Cost organization retrieved '||X_cost_organization_id);
         END IF;
      END IF;
      CLOSE Cur_cmwhse_asc;

      /***********************************************************************
      * Cache Cost_Type_Id, cost_basis and co_code for whse's orgn's company *
      ***********************************************************************/
	   IF (X_cost_organization_id <> P_cached_cost_organization_id OR P_cached_cost_organization_id IS NULL) THEN
		   OPEN Cur_whse_orgn_plcy_mst   (
                                       X_cost_organization_id
                                       );
		   FETCH Cur_whse_orgn_plcy_mst INTO Cur_whse_orgn_plcy_temp;
		   IF (Cur_whse_orgn_plcy_mst%FOUND) THEN
			   CLOSE Cur_whse_orgn_plcy_mst;
			   P_cached_cost_organization_id := Cur_whse_orgn_plcy_temp.organization_id;
            P_cached_cost_type_id :=   Cur_whse_orgn_plcy_temp.cost_type_id;
			   P_cached_cost_basis   :=   Cur_whse_orgn_plcy_temp.cost_basis;
			   P_cached_legal_entity_id :=   Cur_whse_orgn_plcy_temp.legal_entity_id;
         ELSE
            /*************************
            * No fiscal plcy defined *
            *************************/
			   CLOSE Cur_whse_orgn_plcy_mst;
			   IF l_debug_flag > 0 THEN
				   cmcommon_log( 'No fiscal policy defined for the Legal Entity of Org: ' || p_organization_id || '; exit status: -3 ' );
			   END IF;
			   RETURN(-3);
		   END IF;
	   END IF;

	   IF l_debug_flag > 0 THEN
	      cmcommon_log( ' Legal Entity: ' || P_cached_legal_entity_id || ' GL Cost Type: ' || P_cached_cost_type_id ||' Cost Basis: ' || P_cached_cost_basis );
	   END IF;

      /**********************************************************
      * If this variable hold NULL assign Cached variable to it *
      **********************************************************/
	   IF (p_cost_method IS NULL) THEN
		   p_cost_type_id := P_cached_cost_type_id;
         SELECT       cost_mthd_code
         INTO         p_cost_method
         FROM         cm_mthd_mst
         WHERE        cost_type_id = P_cached_cost_type_id;
	   ELSE
         SELECT       cost_type_id
         INTO         p_cost_type_id
         FROM         cm_mthd_mst
         WHERE        cost_mthd_code = p_cost_method;
      END IF;

	   IF l_debug_flag > 0 THEN
	      cmcommon_log( ' Cost_Type_Id: ' || P_cost_type_id||' Cost Method: '||p_cost_method);
	   END IF;

      /************************************************************************
      * Check if cost method is lot cost method if it is then return an error *
      ************************************************************************/
      IF p_cost_type_id IS NOT NULL THEN
		   OPEN Cur_Get_mthd_type(p_cost_type_id);
		   FETCH Cur_Get_mthd_type INTO l_cost_type;
		   CLOSE Cur_get_mthd_type;

         IF l_debug_flag > 0 THEN
            cmcommon_log( ' Cost Type: ' || l_cost_type);
         END IF;

		   IF l_cost_type = 6 THEN
		      x_return_status :=   Get_Process_Item_Cost   (
                                                         p_api_version              =>       p_api_version
                                                         ,p_init_msg_list           =>       p_init_msg_list
                                                         ,x_return_status           =>       x_return_status
                                                         ,x_msg_count               =>       x_msg_count
                                                         ,x_msg_data                =>       x_msg_data
                                                         ,p_inventory_item_id 	   =>       p_inventory_item_id
                                                         ,p_organization_id         =>       p_organization_id
                                          	            ,p_transaction_date        =>       p_transaction_date
                                          		         ,p_detail_flag             =>       p_detail_flag
                                          		         ,p_cost_method             =>       p_cost_method
                                          		         ,p_cost_component_class_id =>       p_cost_component_class_id
                                          		         ,p_cost_analysis_code      =>       p_cost_analysis_code
                                          		         ,X_total_cost              =>       x_total_cost
                                          		         ,X_no_of_rows              =>       x_no_of_rows
                                          		         ,p_lot_number	            =>       null
                                          		         ,p_transaction_id	         =>       null
                                                         );
			   RETURN(x_return_status);
		   END IF;
	   END IF;
      P_acctg_cost := 0;
      P_fmeff_id   := 0;
      P_cost_type  := NULL;

      /***************************************************************************************************
      * The variable below is initialized to 0 instead of null to avoid NULL comaprison IN where clause. *
      ***************************************************************************************************/
      x_itemcost_id := 0;

      /****************************************************************************************
      * Try to get the cost using the item_id, whse_code and orgn_code from calling PROCEDURE *
      ****************************************************************************************/
      IF (P_cached_cost_basis = 0) THEN
         /****************************************************
         * get prior period cost.                            *
         * first get calendar, period codes for prior period *
         ****************************************************/
         OPEN Cur_get_calprd  (
                              P_cached_legal_entity_id,
                              p_transaction_date,
                              p_cost_type_id
                              );
		   FETCH Cur_get_calprd INTO Cur_get_calprd_tmp;
		   IF Cur_get_calprd%NOTFOUND THEN
			   CLOSE Cur_get_calprd;
            /***********************************************************************
            * No  prior period and calendar found for specified p_transaction_date *
            ***********************************************************************/
			   RETURN(-1);
		   END IF;
		   CLOSE Cur_get_calprd;

         IF( l_debug_flag > 0 ) THEN
            cmcommon_log( ' Calendar Details:Calendar Code: ' || Cur_get_calprd_tmp.calendar_code ||' Period Code: '||Cur_get_calprd_tmp.period_code||' End Date: '||to_char(Cur_get_calprd_tmp.end_date)||' Period_id: '||Cur_get_calprd_tmp.period_id);
         END IF;

         /****************************************************************************
         * Now select the cost based on the prior calendar and period selected above *
         ****************************************************************************/
		   OPEN Cur_get_pr_cost (
                              P_cached_cost_organization_id,
			                     p_inventory_item_id,
			                     p_cost_type_id,
                              Cur_get_calprd_tmp.period_id
                              );
		   FETCH Cur_get_pr_cost INTO Cur_get_pr_cost_tmp;
		   IF Cur_get_pr_cost%FOUND THEN
			   x_no_recs  := 1;
			   P_acctg_cost := cur_get_pr_cost_tmp.acctg_cost;
			   P_cost_type :=  cur_get_pr_cost_tmp.cost_type;
			   P_fmeff_id  :=  cur_get_pr_cost_tmp.fmeff_id;
			   x_itemcost_id := cur_get_pr_cost_tmp.itemcost_id;
		   ELSE
			   x_no_recs  := 0;
		   END IF;
		   CLOSE Cur_get_pr_cost;
      ELSE

         IF l_debug_flag > 0 THEN
            cmcommon_log( ' Cost Organization: ' || P_cached_cost_organization_id || ' Inventory Item Id: ' || p_inventory_item_id ||' Cost Type Id: ' || p_cost_type_id ||' Transaction Date: '||p_transaction_date);
         END IF;

         /******************************************
         * cost_basis = 1. get current period cost *
         ******************************************/
         OPEN Cur_get_cost_direct   (
                                    P_cached_cost_organization_id,
                           			p_inventory_item_id,
                           			p_cost_type_id,
                           			p_transaction_date
                                    );
		   FETCH Cur_get_cost_direct INTO Cur_get_cost_direct_tmp;
		   IF Cur_get_cost_direct%FOUND THEN
			   x_no_recs  := 1;
			   P_acctg_cost  := Cur_get_cost_direct_tmp.acctg_cost;
			   P_cost_type   := Cur_get_cost_direct_tmp.cost_type;
			   P_fmeff_id    := Cur_get_cost_direct_tmp.fmeff_id;
			   x_itemcost_id := Cur_get_cost_direct_tmp.itemcost_id;
		   ELSE
   			x_no_recs  := 0;
		   END IF;
		   CLOSE Cur_get_cost_direct;
	   END IF;

      IF( l_debug_flag > 0 ) THEN
		   cmcommon_log( ' Number of cost rows: ' || x_no_recs );
	   END IF;

      IF (x_no_recs = 0) THEN
         RETURN(-1);
	   END IF;

      IF( l_debug_flag > 0 ) THEN
		   cmcommon_log( ' Acctg Cost: ' || P_acctg_cost || ' Cost Type: ' || P_cost_type ||' Fmeff_id: ' || P_fmeff_id || ' Itemcost_id: ' || x_itemcost_id );
	   END IF;

      /****************************************************************
      * The variable below is initialized to 0 in order to avoid NULL *
      * comparison in the where clause                                *
      ****************************************************************/

	   IF p_cost_component_class_id IS NULL THEN
		   p_cost_component_class_id := 0;
	   END IF;

      /******************************************
      * select co cmptcost_amt from gl_item_dtl *
      ******************************************/
	   x_no_recs := 0;
	   P_no_of_rows := 0;

	   IF p_detail_flag = 1 THEN
		   x_no_of_rows := 1; -- PK B 7213143
		   x_total_cost := P_acctg_cost;
		   x_no_recs := 1;
      ELSIF(p_detail_flag = 2 OR p_detail_flag = 3) THEN
		   i:= 0;
		   FOR cur_item_dtl_tmp IN cur_item_dtl   (
                                                X_itemcost_id,
                                                p_cost_component_class_id,
                                                p_cost_analysis_code
                                                ) LOOP
			   i:= i + 1;
			   P_cmpntcost_amt(i) := cur_item_dtl_tmp.cmptcost_amt;
			   x_no_recs := i;
		   END LOOP;
		   P_no_of_rows := i;
		   x_no_of_rows := i;

         /****************************************************************
         * Get item detail cmponent class ids/analysis codes             *
         * This loop retrieves the multiple compnt_cost,cost_cmpntcls_id *
         * and analysis code and populates the array P_cmpntcost_amt,    *
         * P_cost_cmpntcls_id,P_cost_analysis_code                       *
         ****************************************************************/

	   ELSIF p_detail_flag = 4 THEN
		   i:= 0;
		   FOR cur_item_cost_tmp IN cur_item_cost(X_itemcost_id) LOOP
			   i:= i + 1;
			   P_cmpntcost_amt(i)      := cur_item_cost_tmp.cmptcost_amt;
			   P_cost_cmpntcls_id(i)   := cur_item_cost_tmp.cost_cmpntcls_id;
			   P_cost_analysis_code1(i) := cur_item_cost_tmp.cost_analysis_code;
			   x_no_recs := i;
		   END LOOP;
		   P_no_of_rows := i;

         /*****************************************************************************
         * This out parameter is introduced in order to access the value of it        *
         * in the forms. The reason behind is, one cannot access directly the package *
         * spec variables such as P_no_of_rows                                        *
         *****************************************************************************/
		   x_no_of_rows := i;

         /****************************************************************
         * get total cost of item ppv/matl comp class ids/analysis codes *
         ****************************************************************/
      ELSIF p_detail_flag = 5 THEN
		   OPEN Cur_glitmdtl(X_itemcost_id);
		   FETCH Cur_glitmdtl INTO x_total_cost;
		   IF Cur_glitmdtl%NOTFOUND THEN
			   x_total_cost := 0;
			   x_no_recs  := 0;
		   ELSE
			   x_no_recs  := 1;
		   END IF;
		   CLOSE Cur_glitmdtl;
	   END IF;
	   IF (x_no_recs = 0) THEN
		   RETURN (-1);
	   ELSE
		   RETURN(1);
	   END IF;
	   RETURN(1);

      /**************************************************************************
      * Standard call to get message count and if count is 1, get message info. *
      **************************************************************************/
      FND_MSG_PUB.Count_And_Get  (
                                 p_count     =>       x_msg_count,
                                 p_data		=>       x_msg_data
                                 );
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get  (
                                    p_count     =>       x_msg_count,
                                    p_data		=>       x_msg_data
                                    );
         RETURN -1;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get  (
                                    p_count     =>       x_msg_count,
                                    p_data		=>       x_msg_data
                                    );
         RETURN -1;
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg	(
                                    G_PKG_NAME,
                                    l_api_name
                                    );
         END IF;
         FND_MSG_PUB.Count_And_Get  (
                                    p_count     =>       x_msg_count,
                                    p_data		=>       x_msg_data
                                    );
         RETURN -1;
   END Get_Process_Item_Cost;

   /***********************************************************************************************
   *    FUNCTION                                                                                  *
   *       Get_Process_Item_Cost                                                                  *
   *                                                                                              *
   *    DESCRIPTION                                                                               *
   *       This function is an overloaded function of get cost routine. This function             *
   *       can be used to get costs for non lot cost method or lot cost method.                   *
   *                                                                                              *
   *       For non lot cost method this function retrieves item cost, cost type                   *
   *       and fmeff_id from gl_item_cst  and cmptcost_amt from gl_item_dtl                       *
   *       get_cost should return the cost of the item for the cost warehouse                     *
   *       if there is a cost warehouse associated with the given warehouse else                  *
   *       it should return the cost of the item for the given warehouse                          *
   *                                                                                              *
   *    AUTHOR                                                                                    *
   *       Anand Thiyagarajan      01-JUN-2005                                                    *
   *                                                                                              *
   *    INPUT PARAMETERS                                                                          *
   *       inventory_item_id       =     Item id                                                  *
   *       Organization_id         =     Organization                                             *
   *       transaction_date        =     Date of item cost                                        *
   *       cost_mthd               =     cost method used                                         *
   *       cost_component_class_id =     component class id                                       *
   *       analysis_code           =     analysis code                                            *
   *       detail_flag             =     1  => retreive just acctg_cost                           *
   *                                     2  => retreive acctg_cost all cmptcost_amts for itemcost *
   *                                     3  => retreive acctg_cost  cmptcost_amt for itemcost_id, *
   *                                           cost_cmpntcls_id  cost_analysis Code               *
   *       lot_number              =     Lot Number                                               *
   *       Transaction_id          =     Transaction Identifier                                   *
   *                                                                                              *
   *    OUTPUT PARAMETERS                                                                         *
   *       total_cost              =     This out parameter should be reffered only in the        *
   *                                     case when retrieve_ind value is passed as 1              *
   *                                                                                              *
   *    RETURNS (choose one set)                                                                  *
   *        0  - success                                                                          *
   *        1 - could not get transfer_price                                                      *
   *        2 - could not get item unit cost                                                      *
   *        3 - uom conversion error                                                              *
   *                                                                                              *
   *    HISTORY
   *      Sukarna Reddy Dt 26-Oct-2005   removed lot_id and replaced it with lot number in        *
   *     PARTITION BY CLAUSE.                                                                     *
   *      Added delete mark in the where clause while fetching default cost method                *
   *     Added RAISE exception to avoid circular calls to get_process_item_cost. if alternate     *
   *     cost method is marked for purge.                                                         *
   ***********************************************************************************************/
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
   RETURN NUMBER
   IS

      /******************
      * Local Variables *
      ******************/
      l_api_name		   CONSTANT 		VARCHAR2(30)	:= 'Get_Process_Item_Cost' ;
      l_api_version		CONSTANT 		NUMBER		:= 1.0 ;
      l_cost_type_id                   NUMBER;
      l_status 		                  NUMBER;
      i 			                        NUMBER;
      l_header_id 		               NUMBER;
      l_lot_actual_cost 	            NUMBER;
      l_avg_cost 		                  NUMBER;
      l_cost_type_id1		               cm_mthd_mst.cost_type_id%type;
      l_cost_type		                  cm_mthd_mst.cost_type%type;
      l_default_lot_cost_type_id       cm_mthd_mst.default_lot_cost_type_id%type;
      l_default_cost_mthd_code    cm_mthd_mst.cost_mthd_code%TYPE;

      ERROR_RETURN_STATUS EXCEPTION;

      /**********
      * Cursors *
      **********/

      CURSOR      Cur_get_cmthd_type
      (
      v_cost_type_id             IN             NUMBER
      )
      IS
	   SELECT
       cost_type,
       default_lot_cost_type_id
     FROM cm_mthd_mst
     WHERE cost_type_id = v_cost_type_id;

  	 CURSOR Cur_get_cost_mthd ( v_organization_id IN NUMBER ) IS
     SELECT         m.cost_type_id,
                    m.default_lot_cost_type_id
      FROM          cm_mthd_mst m,
                    gmf_fiscal_policies plc,
                    hr_organization_information o
      WHERE         o.organization_id = v_organization_id
      AND           o.org_information_context = 'Accounting Information'
      AND           plc.legal_entity_id   = o.org_information2
      AND           plc.cost_type_id  = m.cost_type_id
      AND           m.delete_mark     = 0
      AND           plc.delete_mark   = 0 ;

  	   CURSOR      Cur_get_cmpnts
      (
      v_header_id                IN             NUMBER,
  	   v_cost_cmpntcls_id         IN             NUMBER,
  	   v_cost_analysis_code       IN             VARCHAR2
      )
      IS
  	   SELECT      cost_cmpntcls_id,
                  cost_analysis_code,
                  component_cost
  	   FROM 	      gmf_lot_cost_details
  	   WHERE       header_id = v_header_id
  	   AND         cost_cmpntcls_id = NVL(v_cost_cmpntcls_id,cost_cmpntcls_id)
  	   AND         cost_analysis_code = NVL(v_cost_analysis_code,cost_analysis_code);

  	   CURSOR      Cur_Get_total_cost
      (
      v_header_id                IN             NUMBER,
  	   v_lot_number               IN             VARCHAR2
      )
      IS
  	   SELECT      sum(component_cost)
  	   FROM        gmf_lot_cost_details d,
                  gmf_lot_costs h
  	   WHERE       h.header_id = v_header_id
  	   AND         h.header_id = d.header_id
  	   AND         h.lot_number = nvl(v_lot_number ,h.lot_number);

  	   CURSOR      Cur_Get_header
      (
      v_trans_id                 IN             NUMBER,
      v_cost_type_id             IN             NUMBER
      )
      IS
  	   SELECT      cost_header_id
  	   FROM        gmf_material_lot_cost_txns
  	   WHERE       transaction_id = v_trans_id
  	   AND         cost_type_id = v_cost_type_id;

  	   CURSOR      Cur_Get_recent_hdr
      (
      v_item_id                  IN             NUMBER,
  	   v_lot_number               IN             VARCHAR2,
  	   v_cost_type_id             IN             NUMBER,
  		v_trans_date               IN             DATE,
  	   v_organization_id          IN             VARCHAR2
      )
      IS
  	   SELECT      MAX(header_id)
  	   FROM 	      gmf_lot_costs
  	   WHERE       inventory_item_id = p_inventory_item_id
  		AND         cost_type_id = v_cost_type_id
  		AND         lot_number = v_lot_number
  		AND         cost_date <= v_trans_date
  		AND         organization_id = v_organization_id;

      CURSOR      Cur_get_cost
      (
      v_item_id                  IN             NUMBER,
      v_organization_id          IN             NUMBER,
      v_cost_type_id             IN             NUMBER,
      v_trans_date               IN             DATE
      )
      IS
  	   SELECT      SUM(onhand_qty*unit_cost)/SUM(onhand_qty)
		FROM        (
                  SELECT      onhand_qty,
			                     unit_cost,
			                     RANK() OVER (
                                          PARTITION BY   lot_number
                                          ORDER BY       cost_date desc,
                                                         header_id desc
                                          ) as rank
   			      FROM 	      gmf_lot_costs
 		       	   WHERE 	   cost_date <= v_trans_date
 			         AND 	      inventory_item_id = v_item_id
 			         AND 	      organization_id = v_organization_id
 			         AND 	      cost_type_id = v_cost_type_id
 		            )
 		WHERE       rank = 1;

   BEGIN



      IF (p_cost_method IS NOT NULL) THEN
         SELECT    cost_type_id
         INTO      l_cost_type_id
         FROM      cm_mthd_mst
         WHERE     cost_mthd_code = p_cost_method
                   AND  delete_mark = 0;
      END IF;

      /*************************************************************
      * Initialize message list if p_init_msg_list is set to TRUE. *
      *************************************************************/
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
   	   FND_MSG_PUB.initialize;
      END IF;

      /*************************************************
      * Standard call to check for call compatibility. *
      *************************************************/
      IF NOT FND_API.Compatible_API_Call  (
                                          l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          G_PKG_NAME
                                          ) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      /******************************************
      * Initialize API return status to success *
      ******************************************/
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_msg_count := 0;
      x_msg_data := NULL;

  	   IF (p_inventory_item_id IS NULL OR p_organization_id IS NULL OR p_transaction_date IS NULL) THEN
         /******************************************
         * No required input parameters specified. *
         ******************************************/
    		cmcommon_log( 'Insufficient input parameters; exit status: -2' );
     		RETURN(-2);
    	END IF;

      /*******************************************************
      * If cost method is not passed get gl cost method from *
      * fiscal policy                                        *
      *******************************************************/
      IF (l_cost_type_id IS NULL) THEN
    	   OPEN Cur_get_cost_mthd  (
                                 p_organization_id
                                 );
		   FETCH Cur_get_cost_mthd INTO		l_cost_type_id1,
				                              l_default_lot_cost_type_id;
	 	   CLOSE Cur_get_cost_mthd;
         IF l_cost_type_id1 IS NULL THEN
		      cmcommon_log( 'No Cost type defined in fiscal policy or specify a cost type; exit status: -2' );
			   RETURN(-2);
		   ELSE
			   l_cost_type_id := l_cost_type_id1;
	 	   END IF;
	   END IF;

      /***************************************************************************
      * if cost method is passed or retrieved from previous step check to see if *
      * its a lot cost method or not lot cost method                             *
      ***************************************************************************/
	   IF l_cost_type_id IS NOT NULL THEN
		   OPEN Cur_get_cmthd_type (
                                 l_cost_type_id
                                 );
  		   FETCH Cur_get_cmthd_type INTO l_cost_type,
                                       l_default_lot_cost_type_id;
  		   CLOSE Cur_get_cmthd_type;
    	END IF;

      /**************************************************************
      * If not lot cost method then call original get cost FUNCTION *
      **************************************************************/

  	   IF l_cost_type <> 6 THEN
         l_status := Get_Process_Item_Cost   (
                                             p_api_version              =>       p_api_version,
                                             p_init_msg_list            =>       p_init_msg_list,
                                             x_return_status            =>       x_return_status,
                                             x_msg_count                =>       x_msg_count,
                                             x_msg_data                 =>       x_msg_data,
                                             p_inventory_item_id        =>       p_inventory_item_id,
                                             p_organization_id          =>       p_organization_id,
                                             p_transaction_date         =>       p_transaction_date,
                                             p_cost_method              =>       p_cost_method,
                                             p_cost_component_class_id  =>       p_cost_component_class_id,
                                             p_cost_analysis_code       =>       p_cost_analysis_code,
                                             p_detail_flag              =>       p_detail_flag,
                                             x_total_cost               =>       x_total_cost,
                                             x_no_of_rows               =>       x_no_of_rows
                                             );
	      RETURN(l_status);
	   ELSE
         /*******************************************************
         * Give trans id an highest priority compared to lot id *
         *******************************************************/
         IF nvl(p_transaction_id,0) > 0 THEN
  			   OPEN Cur_Get_header  (
                                 p_transaction_id,
                                 l_cost_type_id
                                 );
  			   FETCH Cur_Get_header INTO l_header_id;
  			   CLOSE Cur_Get_header;

  			   OPEN Cur_get_total_cost(l_header_id,p_lot_number);
  			   FETCH Cur_Get_total_cost INTO x_total_cost;
			   CLOSE Cur_get_total_cost;

            /************************************************************
            * if no trans id is passed then get cost header id based on *
            * recent transaction.                                       *
            ************************************************************/
  		   ELSIF (nvl(p_transaction_id,0) = 0 OR p_transaction_id < 0) THEN
  			   IF (p_lot_number IS NOT NULL) THEN
  				   OPEN Cur_get_recent_hdr (
                                       p_inventory_item_id,
                                       p_lot_number,
                                       l_cost_type_id,
                                       p_transaction_date,
                                       p_organization_id
                                       );
  				   FETCH Cur_get_recent_hdr INTO l_header_id;
  				   CLOSE Cur_get_recent_hdr;

  				   IF (nvl(l_header_id,0) > 0) THEN
  					   OPEN Cur_get_total_cost (
                                          l_header_id,
                                          p_lot_number
                                          );
  					   FETCH Cur_Get_total_cost INTO x_total_cost;
					   CLOSE Cur_get_total_cost;
  				   END IF;

               /*****************************************************************
               * If there is not lot or transaction ID then get cost            *
               * by applying weighted average of all most recent lots belonging *
               * to an item,whse,cost method,cost date                          *
               *****************************************************************/

            ELSIF (p_lot_number IS NULL) THEN
  				   OPEN Cur_get_cost (
                                 p_inventory_item_id,
                                 p_organization_id,
                                 l_cost_type_id,
                                 p_transaction_date
                                 );
  			      FETCH Cur_Get_cost INTO l_avg_cost;
  			    	CLOSE Cur_Get_cost;
			   END IF;
            IF l_avg_cost IS NOT NULL THEN
				   x_no_of_rows := 1;
				   x_total_cost := l_avg_cost;
			   END IF;
  		   END IF;

         -- PK code fix NVL B7213143
         IF (l_cost_type = 6 AND l_default_lot_cost_type_id IS NOT NULL AND NVL(x_total_cost, 0) = 0  AND NVL(l_avg_cost, 0) = 0) THEN
            BEGIN
            SELECT cost_mthd_code INTO l_default_cost_mthd_code
               FROM cm_mthd_mst
               WHERE cost_type_id = l_default_lot_cost_type_id AND
                     delete_mark = 0;
            EXCEPTION
               WHEN OTHERS THEN
               l_default_cost_mthd_code := NULL;
                /* INVCONV sschinch */
                -- if we are here then we should return from here to avoid circular calls to get_process_item_cost.
               RAISE error_return_status;
            END;
            l_status := Get_Process_Item_Cost   (
                                                p_api_version              =>    p_api_version,
                                                p_init_msg_list            =>    p_init_msg_list,
                                                x_return_status            =>    x_return_status,
                                                x_msg_count                =>    x_msg_count,
                                                x_msg_data                 =>    x_msg_data,
                                                p_inventory_item_id        =>    p_inventory_item_id,
                                                p_organization_id          =>    p_organization_id,
                                                p_transaction_date         =>    p_transaction_date,
                                                p_cost_method              =>    l_default_cost_mthd_code,
                                                p_cost_component_class_id  =>    p_cost_component_class_id,
                                                p_cost_analysis_code       =>    p_cost_analysis_code,
                                                p_detail_flag              =>    p_detail_flag,
                                                x_total_cost               =>    x_total_cost,
                                                x_no_of_rows               =>    x_no_of_rows
                                                );
            IF l_status < 0 THEN
		    	   RAISE error_return_status;
            END IF;
         END IF;

         /***************************************************
         * Honor retrieve ind to get some additional info   *
         * for lot cost method only when lot id or trans id *
         * is passed.                                       *
         ***************************************************/
         IF (p_lot_number IS NOT NULL OR NVL(p_transaction_id,0) > 0) THEN
  			   IF (p_detail_flag = 2 OR p_detail_flag = 3) THEN
	  			   i:= 0;
  				   IF (l_header_id > 0 AND p_cost_component_class_id > 0 AND p_cost_analysis_code IS NOT NULL) THEN
                  FOR Cur_temp IN Cur_Get_cmpnts   (
                                                   l_header_id,
  									                        p_cost_component_class_id,
  									                        p_cost_analysis_code
                                                   ) LOOP
		  				   i:= i + 1;
  					 	   P_cmpntcost_amt(i)      := cur_temp.component_cost;
  					   END LOOP;
					   x_no_of_rows := i;
					   p_no_of_rows := i;
				   END IF;
		 	   ELSIF (p_detail_flag = 4) THEN
				   IF (l_header_id > 0) THEN
					   i := 0;
					   FOR Cur_temp IN Cur_Get_cmpnts   (
                                                   l_header_id,
                                                   NULL,
                                                   NULL
                                                   ) LOOP
			 			   i:= i + 1;
  					 	   P_cmpntcost_amt(i)      := cur_temp.component_cost;
  				 		   P_cost_cmpntcls_id(i)   := cur_temp.cost_cmpntcls_id;
     						P_cost_analysis_code1(i) := cur_temp.cost_analysis_code;
  					   END LOOP;
					   x_no_of_rows := i;
					   p_no_of_rows := i;
				   END IF;
			   END IF;
		   END IF;

         IF (x_no_of_rows = 0) THEN
	 		   RAISE ERROR_RETURN_STATUS;
	 	   ELSE
	 		   RETURN(1);
	 	   END IF;
  	   END IF;

      /**************************************************************************
      * Standard call to get message count and if count is 1, get message info. *
      **************************************************************************/
      FND_MSG_PUB.Count_And_Get  (
                                 p_count			=>      x_msg_count,
                                 p_data		   =>      x_msg_data
                                 );

   EXCEPTION
      WHEN ERROR_RETURN_STATUS THEN
     	   x_no_of_rows := 0;
   	   x_total_cost := 0;
   	   p_no_of_rows := 0;
   	   RETURN(-1);
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get  (
                                    p_count			=>      x_msg_count,
                                    p_data		   =>      x_msg_data
                                    );
         RETURN -1;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get  (
                                    p_count			=>      x_msg_count,
                                    p_data		   =>      x_msg_data
                                    );
         RETURN -1;
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg	(
                                    G_PKG_NAME,
                                    l_api_name
                                    );
         END IF;
         FND_MSG_PUB.Count_And_Get  (
                                    p_count			=>      x_msg_count,
                                    p_data		   =>      x_msg_data
                                    );
         RETURN -1;
  END Get_Process_Item_Cost;


   /***************************************************************************************
   *   FUNCTION                                                                           *
   *      Is_Batch_Cost_Frozen                                                            *
   *                                                                                      *
   *   DESCRIPTION                                                                        *
   *      This function is used to get the status whether the costs Fora particular batch *
   *      has been closed ore not                                                         *
   *                                                                                      *
   *   AUTHOR                                                                             *
   *      Anand Thiyagarajan       01-JUN-2005                                            *
   *                                                                                      *
   *   INPUT PARAMETERS                                                                   *
   *      batch_id     =     Batch id                                                     *
   *                                                                                      *
   *   OUTPUT PARAMETERS                                                                  *
   *                                                                                      *
   *   RETURNS                                                                            *
   *      TRUE   =>    Period Costs are Frozen                                            *
   *      FALSE  =>    Period Costs are Opn                                               *
   *                                                                                      *
   *   HISTORY                                                                            *
   *                                                                                      *
   ***************************************************************************************/
   FUNCTION is_batch_cost_frozen
   (
   p_api_version        IN             NUMBER
   , p_init_msg_list    IN             VARCHAR2 := FND_API.G_FALSE
   , p_commit           IN             VARCHAR2 := FND_API.G_FALSE
   , x_return_status    OUT   NOCOPY   VARCHAR2
   , x_msg_count        OUT   NOCOPY   NUMBER
   , x_msg_data         OUT   NOCOPY   VARCHAR2
   , p_batch_id         IN             gme_batch_header.batch_id%TYPE
   )
   RETURN BOOLEAN
   IS

      /******************
      * Local Variables *
      ******************/
      l_api_name		   CONSTANT 		VARCHAR2(30) := 'Is_Batch_Cost_Frozen' ;
	   l_api_version		CONSTANT 		NUMBER := 1.0 ;
      l_cnt_frozen_matls               NUMBER := 0;

      /**********
      * Cursors *
      **********/

      CURSOR            c_get_period_info
      (
      l_batch_id                 IN             gme_batch_header.batch_id%TYPE
      )
      IS
      SELECT            count(1)
      FROM              cm_cmpt_dtl cst,
                        cm_acst_led aled,
                        gme_material_details md,
                        gme_batch_header bh
      WHERE             bh.batch_id = l_batch_id
      AND               bh.batch_id = md.batch_id
      AND               md.material_detail_id = aled.transline_id
      AND               aled.source_ind = 0
      AND               aled.cmpntcost_id = cst.cmpntcost_id
      AND               cst.rollover_ind = 1;

   BEGIN



      /*************************************************************
      * Initialize message list if p_init_msg_list is set to TRUE. *
      *************************************************************/
      IF FND_API.to_Boolean( p_init_msg_list ) THEN

   	   FND_MSG_PUB.initialize;

      END IF;

      /*************************************************
      * Standard call to check for call compatibility. *
      *************************************************/
      IF NOT FND_API.Compatible_API_Call
      (
      l_api_version,
      p_api_version,
      l_api_name,
      G_PKG_NAME
      ) THEN

         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END IF;

      /******************************************
      * Initialize API return status to success *
      ******************************************/
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_msg_count := 0;
      x_msg_data := NULL;

      OPEN c_get_period_info( p_batch_id);
      FETCH c_get_period_info INTO l_cnt_frozen_matls;
      IF c_get_period_info%NOTFOUND THEN

         CLOSE c_get_period_info;
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END IF;
      CLOSE c_get_period_info;

      /**************************************************************************
      * Standard call to get message count and if count is 1, get message info. *
      **************************************************************************/
      FND_MSG_PUB.Count_And_Get  (
                                 p_count     =>      x_msg_count,
                                 p_data		=>      x_msg_data
                                 );
      /*************************************************************
      * Initialize message list if p_init_msg_list is set to TRUE. *
      *************************************************************/
      IF FND_API.to_Boolean( p_commit ) THEN
   	   COMMIT;
      END IF;

      IF nvl(l_cnt_frozen_matls,0) > 0 THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;

   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get  (
                                    p_count           =>      x_msg_count,
                                    p_data            =>      x_msg_data
                                    );
		   RETURN NULL;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get  (
                                    p_count           =>      x_msg_count,
                                    p_data            =>      x_msg_data
                                    );
		   RETURN NULL;
      WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg	(
                                    G_PKG_NAME,
                                    l_api_name
                                    );
         END IF;
         FND_MSG_PUB.Count_And_Get  (
                                    p_count           =>      x_msg_count,
                                    p_data            =>      x_msg_data
                                    );
				 RETURN NULL;
   END Is_Batch_Cost_Frozen;

 /************************************************************************************
  *  FUNCTION
  *     get_process_item_price
  *
  *  DESCRIPTION
  *	This is a wrapper function which calls get_process_item_unit_price
  *     or transfer price API to get the cost.
  *
  *     - For process/discrete transfers, get transfer_price.
  *     - For process/process transfers, get item unit cost.
  *
  *     This function is called from PO Req's POXRQLNS.pld
  *
  *  AUTHOR
  *    umoogala	 10-Feb-2005  genesis
  *                           OPM INVCONV
  *
  *  INPUT PARAMETERS
  *     p_inventory_item_id          IN  NUMBER
  *     p_src_organization_id        IN  NUMBER
  *     p_src_process_enabled_flag   IN  VARCHAR2
  *     p_dest_organization_id       IN  NUMBER
  *     p_dest_process_enabled_flag  IN  VARCHAR2
  *     p_trans_uom                  IN  VARCHAR2
  *     p_trans_date                 IN  DATE
  *
  *     x_unit_price                 OUT NOCOPY  NUMBER
  *     x_currency_code              OUT NOCOPY  VARCHAR2
  *     x_incr_transfer_price        OUT NOCOPY  NUMBER
  *     x_incr_currency_code         OUT NOCOPY  VARCHAR2
  *
  *  OUTPUT PARAMETERS
  *	Returns cost of an item.
  *	Return Status
  *      0  - success
  *      -1 - could not get transfer_price
  *      -2 - could not get item unit cost
  *      -3 - uom conversion error
  *
  *  HISTORY
  *
  **************************************************************************************/

  PROCEDURE get_process_item_price (
        p_inventory_item_id          IN  NUMBER
      , p_trans_qty                  IN  NUMBER
      , p_trans_uom                  IN  VARCHAR2
      , p_trans_date                 IN  DATE

      , p_src_organization_id        IN  NUMBER
      , p_src_process_enabled_flag   IN  VARCHAR2

      , p_dest_organization_id       IN  NUMBER
      , p_dest_process_enabled_flag  IN  VARCHAR2

      , p_source                     IN  VARCHAR2

      , x_unit_price                 OUT NOCOPY  NUMBER
      , x_unit_price_priuom          OUT NOCOPY  NUMBER
      , x_currency_code              OUT NOCOPY  VARCHAR2
      , x_incr_transfer_price        OUT NOCOPY  NUMBER
      , x_incr_currency_code         OUT NOCOPY  VARCHAR2
      , x_return_status              OUT NOCOPY  NUMBER
      )
  IS

    l_return_status     VARCHAR2(1);
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(2000);
    x_no_of_rows        NUMBER;

    l_transfer_type     VARCHAR2(6);
    l_from_ou           NUMBER;
    l_to_ou             NUMBER;

    l_conversion_rate   NUMBER;
    l_primary_uom_code  mtl_units_of_measure.uom_code%TYPE;
    l_trans_uom_code    mtl_units_of_measure.uom_code%TYPE;
    l_primary_uom       mtl_units_of_measure.unit_of_measure%TYPE;

  BEGIN

    l_return_status := FND_API.G_RET_STS_SUCCESS;
    l_transfer_type := 'INTORG';

    IF (p_src_process_enabled_flag <> p_dest_process_enabled_flag)
    THEN
      -- process/discrete internal orders. Get transfer_price
      -- For INTCOM xfers, get transfer_price using INV API.
      -- For INTORG xfers, get transfer_price using Pricelist

      /*
      IF l_from_ou <> l_to_ou
      THEN
        IF fnd_profile.value('INV_INTERCOMPANY_INVOICE_INTERNAL_ORDER') = 1
        THEN
          l_transfer_type := 'INTCOM';
        ELSE
          l_transfer_type := 'INTORD';
        END IF;
      ELSE
        l_transfer_type := 'INTORD';
      END IF;
      */

      SELECT to_number(src.org_information2) src_ou, to_number(dest.org_information2) dest_ou
        INTO l_from_ou, l_to_ou
        FROM hr_organization_information src, hr_organization_information dest
       WHERE src.organization_id = p_src_organization_id
         AND src.org_information_context = 'Accounting Information'
         AND dest.organization_id = p_dest_organization_id
         AND dest.org_information_context = 'Accounting Information'
      ;

      GMF_get_transfer_price_PUB.get_transfer_price (
          p_api_version             => 1.0
        , p_init_msg_list           => 'F'

        , p_inventory_item_id       => p_inventory_item_id
        , p_transaction_qty         => p_trans_qty
        , p_transaction_uom         => p_trans_uom

        , p_transaction_id          => NULL
        , p_global_procurement_flag => 'N'
        , p_drop_ship_flag          => 'N'

        , p_from_organization_id    => p_src_organization_id
        , p_from_ou                 => l_from_ou
        , p_to_organization_id      => p_dest_organization_id
        , p_to_ou                   => l_to_ou

        , p_transfer_type           => l_transfer_type
        , p_transfer_source         => p_source

        , x_return_status           => l_return_status
        , x_msg_data                => x_msg_data
        , x_msg_count               => x_msg_count

        , x_transfer_price          => x_unit_price
        , x_transfer_price_priuom   => x_unit_price_priuom
        , x_currency_code           => x_currency_code
        , x_incr_transfer_price     => x_incr_transfer_price  /* not used */
        , x_incr_currency_code      => x_incr_currency_code  /* not used */
        );

      IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR
         x_unit_price IS NULL
      THEN
        x_unit_price    := 0;
        x_return_status := -1; -- since pld cannot read db package variables
      END IF;

    ELSIF p_src_process_enabled_flag = 'Y' AND p_dest_process_enabled_flag = 'Y'
    THEN
        -- process to process orders

        GMF_cmcommon.get_process_item_unit_price (
            p_inventory_item_id     => p_inventory_item_id
          , p_organization_id       => p_src_organization_id
          , p_trans_date            => p_trans_date
          , x_unit_price            => x_unit_price
          , x_return_status         => l_return_status
          );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
          x_unit_price    := 0;
          x_return_status := -2; -- since pld cannot read db package variables
        END IF;


      IF l_return_status = FND_API.G_RET_STS_SUCCESS
      THEN
        ------------------------------------------------------------
        -- If the trans UOM and the item's primary UOM are same then
        -- the unit price is same else we need to calculate (derive)
        -- the unit price for the requisiton uom
        ------------------------------------------------------------

        SELECT primary_unit_of_measure
          INTO l_primary_uom
          FROM mtl_system_items
         WHERE inventory_item_id = p_inventory_item_id
           AND organization_id   = p_src_organization_id;


        IF l_primary_uom <> p_trans_uom
        THEN

          SELECT uom_code
            INTO l_primary_uom_code
            FROM mtl_units_of_measure_vl
           WHERE unit_of_measure_tl = l_primary_uom;

          SELECT uom_code
            INTO l_trans_uom_code
            FROM mtl_units_of_measure_vl
           WHERE unit_of_measure_tl = p_trans_uom;

          inv_convert.inv_um_conversion(
              from_unit       => l_primary_uom_code
            , to_unit         => l_trans_uom_code
            , item_id         => p_inventory_item_id
            , lot_number      => NULL
            , organization_id => p_src_organization_id
            , uom_rate        => l_conversion_rate
            );

          IF l_conversion_rate = -99999
          THEN
            x_unit_price := 0;
            x_return_status := -3;
          ELSE
            x_unit_price := round((x_unit_price/l_conversion_rate), 5);
          END IF;

        END IF;  -- IF l_primary_uom <> p_trans_uom

      END IF;  -- IF x_return_status = FND_API.G_RET_STS_SUCCESS

    END IF;  -- ELSIF p_src_process_enabled_flag = 'Y' AND p_dest_process_enabled_flag = 'Y'

    x_return_status := 0;

  END get_process_item_price;


 /************************************************************************************
  *  FUNCTION
  *     get_process_item_unit_price
  *
  *  DESCRIPTION
  *	This is a wrapper function which calls Get_Process_Item_Cost to return
  *     the cost. This function is called from PO Req's POXRQLNS.pld
  *     -- PPV report(POXRCPPV.rdf)
  *
  *  AUTHOR
  *    umoogala	 10-Feb-2005  genesis
  *                           OPM INVCONV
  *
  *  INPUT PARAMETERS
  *   p_inventory_item_id
  *   p_organization_id
  *   p_trans_uom
  *   p_trans_date
  *
  *  OUTPUT PARAMETERS
  *	Returns cost of an item.
  *	Status -1 or 0
  *
  *  HISTORY
  *
  **************************************************************************************/

  PROCEDURE get_process_item_unit_price (
      p_inventory_item_id     IN         NUMBER
    , p_organization_id       IN         NUMBER
    , p_trans_date            IN         DATE
    , x_unit_price            OUT NOCOPY NUMBER
    , x_return_status         OUT NOCOPY VARCHAR2
    )
  IS

    l_return_status     VARCHAR2(1);
    l_ret_val           NUMBER;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(2000);
    x_no_of_rows        NUMBER;

    x_cost_method	             cm_mthd_mst.cost_mthd_code%TYPE;
    x_cost_component_class_id  cm_cmpt_mst.cost_cmpntcls_id%TYPE;
    x_cost_analysis_code       cm_alys_mst.cost_analysis_code%TYPE;

  BEGIN

    l_return_status := FND_API.G_RET_STS_SUCCESS;

    l_ret_val := GMF_CMCOMMON.Get_Process_Item_Cost (
                     1.0
                   , fnd_api.g_true
                   , l_return_status
                   , x_msg_count
                   , x_msg_data
                   , p_inventory_item_id
                   , p_organization_id
                   , p_trans_date
                   , 1 -- return unit_price
                   , x_cost_method
                   , x_cost_component_class_id
                   , x_cost_analysis_code
                   , x_unit_price
                   , x_no_of_rows
                   );

    IF l_ret_val <> 1 OR l_return_status <> FND_API.G_RET_STS_SUCCESS
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    x_unit_price    := 1;

  END get_process_item_unit_price;


   /*************************************************************************
   *    FUNCTION                                                            *
   *       process_item_unit_cost                                           *
   *                                                                        *
   *    DESCRIPTION                                                         *
   *       Unit cost of a process item (R12 version of unit cost function)  *
   *                                                                        *
   *    HISTORY                                                             *
   *       11-Jul-2005       Rajesh Seshadri         created stub version   *
   *       23-AUG-2005       Anand Thiyagarajan      Implementation Details *
   *                                                                        *
   *************************************************************************/
   FUNCTION process_item_unit_cost
   (
   p_inventory_item_id     IN NUMBER,
   p_organization_id       IN NUMBER,
   p_transaction_date      IN DATE
   ) RETURN NUMBER
   IS

      /******************
      * Local Variables *
      ******************/

      l_ret_val                                 NUMBER;
      l_return_status                           VARCHAR2(5);
      l_msg_count                               NUMBER(10);
      l_msg_data                                VARCHAR2(2000);
      l_total_cost                              NUMBER;
      l_no_of_rows                              NUMBER(10);
      l_cost_method                             CM_MTHD_MST.COST_MTHD_CODE%TYPE;
      l_cost_component_class_id                 CM_CMPT_DTL.COST_CMPNTCLS_ID%TYPE;
      l_cost_analysis_code                      CM_CMPT_DTL.COST_ANALYSIS_CODE%TYPE;
      l_api_name		            CONSTANT 		VARCHAR2(30) := 'Process_Item_Unit_Cost' ;
      l_api_version		         CONSTANT 		NUMBER := 1.0 ;

      /********************************************
      * Change this only when absolutely required *
      ********************************************/

      l_debug_flag NUMBER := 0;

   BEGIN

      l_debug_flag := G_DEBUG_LEVEL;

      /******************************************
      * Initialize API return status to success *
      ******************************************/
      l_return_status := FND_API.G_RET_STS_SUCCESS;
      l_msg_count := 0;
      l_msg_data := NULL;

	   IF (l_debug_flag > 0) THEN
         cmcommon_log( 'Input parameters: Inventory Item Id: ' || p_inventory_item_id || ' Org: ' || p_Organization_id ||' Cost Date: ' || to_char(p_transaction_date, 'yyyy-mm-dd hh24:mi:ss') );
	   END IF;

      IF (p_inventory_item_id IS NULL OR p_organization_id IS NULL  OR p_transaction_date IS NULL) THEN
         IF( l_debug_flag > 0 ) THEN
	         cmcommon_log( 'Insufficient input parameters; exit status: -2' );
	      END IF;
         RETURN(0);
      END IF;

      l_ret_val := Get_Process_Item_Cost
                                          (
                                          p_api_version                 =>             l_api_version
                                          , p_init_msg_list             =>             FND_API.G_TRUE
                                          , x_return_status             =>             l_return_status
                                          , x_msg_count                 =>             l_msg_count
                                          , x_msg_data                  =>             l_msg_data
                                          , p_inventory_item_id         =>             p_inventory_item_id
                                          , p_organization_id           =>             p_organization_id
                                          , p_transaction_date          =>             p_transaction_date
                                          , p_detail_flag               =>             1
                                          , p_cost_method               =>             l_cost_method
                                          , p_cost_component_class_id   =>             l_cost_component_class_id
                                          , p_cost_analysis_code        =>             l_cost_analysis_code
                                          , x_total_cost                =>             l_total_cost
                                          , x_no_of_rows                =>             l_no_of_rows
                                          );
      IF (l_debug_flag > 0) THEN
         cmcommon_log( 'Return Status => '|| l_return_status || ' Message => '|| l_msg_data ||' Cost => '||l_total_cost);
      END IF;

      /**************************************************************************
      * Standard call to get message count and if count is 1, get message info. *
      **************************************************************************/
      FND_MSG_PUB.Count_And_Get  (
                                 p_count     =>       l_msg_count,
                                 p_data		=>       l_msg_data
                                 );

      RETURN (nvl(l_total_cost,0));

   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         l_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get  (
                                    p_count     =>       l_msg_count,
                                    p_data		=>       l_msg_data
                                    );
         RETURN 0;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         l_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get  (
                                    p_count     =>       l_msg_count,
                                    p_data		=>       l_msg_data
                                    );
         RETURN 0;
      WHEN OTHERS THEN
         l_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg	(
                                    G_PKG_NAME,
                                    l_api_name
                                    );
         END IF;
         FND_MSG_PUB.Count_And_Get  (
                                    p_count     =>       l_msg_count,
                                    p_data		=>       l_msg_data
                                    );
         RETURN 0;

  END process_item_unit_cost;

   /*************************************************************************
   *    FUNCTION                                                            *
   *       process_item_unit_cost                                           *
   *                                                                        *
   *    DESCRIPTION                                                         *
   *       Unit cost of a process item (R12 version of unit cost function)  *
   *       Overloaded for Lot Specific Costs                                *
   *                                                                        *
   *    HISTORY                                                             *
   *       11-Jul-2005       Rajesh Seshadri         created stub version   *
   *       23-AUG-2005       Anand Thiyagarajan      Implementation Details *
   *                                                                        *
   *************************************************************************/
   FUNCTION process_item_unit_cost
   (
   p_inventory_item_id              IN                NUMBER,
   p_organization_id                IN                NUMBER,
   p_transaction_date               IN                DATE,
   p_lot_number                     IN                VARCHAR2,
   p_transaction_id                 IN                NUMBER
   )
   RETURN NUMBER
   IS
      /******************
      * Local Variables *
      ******************/

      l_ret_val                                 NUMBER;
      l_return_status                           VARCHAR2(5);
      l_msg_count                               NUMBER(10);
      l_msg_data                                VARCHAR2(2000);
      l_total_cost                              NUMBER;
      l_no_of_rows                              NUMBER(10);
      l_cost_method                             CM_MTHD_MST.COST_MTHD_CODE%TYPE;
      l_cost_component_class_id                 CM_CMPT_DTL.COST_CMPNTCLS_ID%TYPE;
      l_cost_analysis_code                      CM_CMPT_DTL.COST_ANALYSIS_CODE%TYPE;
      l_api_name		            CONSTANT 		VARCHAR2(30) := 'Process_Item_Unit_Cost' ;
      l_api_version		         CONSTANT 		NUMBER := 1.0 ;

      /********************************************
      * Change this only when absolutely required *
      ********************************************/

      l_debug_flag NUMBER := 0;

   BEGIN


      l_debug_flag := G_DEBUG_LEVEL;

      /******************************************
      * Initialize API return status to success *
      ******************************************/
      l_return_status := FND_API.G_RET_STS_SUCCESS;
      l_msg_count := 0;
      l_msg_data := NULL;

	   IF (l_debug_flag > 0) THEN
         cmcommon_log( 'Input parameters: Inventory Item Id: ' || p_inventory_item_id || ' Org: ' || p_Organization_id);
         cmcommon_log( 'Input Parameters: Cost Date: ' || to_char(p_transaction_date, 'yyyy-mm-dd hh24:mi:ss'));
         cmcommon_log( 'Input Parameters: Lot Number: '|| p_lot_number || ' Transaction Id: '|| p_transaction_id);
	   END IF;

      IF (p_inventory_item_id IS NULL OR p_organization_id IS NULL  OR p_transaction_date IS NULL OR p_organization_id IS NULL) THEN
         IF( l_debug_flag > 0 ) THEN
	         cmcommon_log( 'Insufficient input parameters; exit status: -2' );
	      END IF;
         RETURN(0);
      END IF;

      l_ret_val := Get_Process_Item_Cost
                                          (
                                          p_api_version                 =>             l_api_version
                                          , p_init_msg_list             =>             FND_API.G_TRUE
                                          , x_return_status             =>             l_return_status
                                          , x_msg_count                 =>             l_msg_count
                                          , x_msg_data                  =>             l_msg_data
                                          , p_inventory_item_id         =>             p_inventory_item_id
                                          , p_organization_id           =>             p_organization_id
                                          , p_transaction_date          =>             p_transaction_date
                                          , p_detail_flag               =>             1
                                          , p_cost_method               =>             l_cost_method
                                          , p_cost_component_class_id   =>             l_cost_component_class_id
                                          , p_cost_analysis_code        =>             l_cost_analysis_code
                                          , x_total_cost                =>             l_total_cost
                                          , x_no_of_rows                =>             l_no_of_rows
                                          , p_lot_number                =>             p_lot_number
                                          , p_transaction_id            =>             p_transaction_id
                                          );

      IF (l_debug_flag > 0) THEN
         cmcommon_log( 'Return Status => '|| l_return_status || ' Message => '|| l_msg_data ||' Cost => '||l_total_cost);
      END IF;

      /**************************************************************************
      * Standard call to get message count and if count is 1, get message info. *
      **************************************************************************/
      FND_MSG_PUB.Count_And_Get  (
                                 p_count     =>       l_msg_count,
                                 p_data		=>       l_msg_data
                                 );

      RETURN (nvl(l_total_cost,0));

   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         l_return_status := FND_API.G_RET_STS_ERROR ;
         FND_MSG_PUB.Count_And_Get  (
                                    p_count     =>       l_msg_count,
                                    p_data		=>       l_msg_data
                                    );
         RETURN 0;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         l_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Count_And_Get  (
                                    p_count     =>       l_msg_count,
                                    p_data		=>       l_msg_data
                                    );
         RETURN 0;
      WHEN OTHERS THEN
         l_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg	(
                                    G_PKG_NAME,
                                    l_api_name
                                    );
         END IF;
         FND_MSG_PUB.Count_And_Get  (
                                    p_count     =>       l_msg_count,
                                    p_data		=>       l_msg_data
                                    );
         RETURN 0;

  END process_item_unit_cost;

  /* ***********************************************************************************
  *  FUNCTION
  *       get_cmpt_cost
  *  DESCRIPTION
  *
  *	This function gets item unit cost from cm_cmpt_dtl, NOT from gl_item_cst/dtl.
  *	This is being use in OPM Batch Cost Detail Report.
  *
  *  AUTHOR
  * 	Anand Thiyagarajan  20-Feb-2007  Bug#5436964 Batches Across Periods FP
  *
  *  INPUT PARAMETERS
  *       inventory_item_id       = Item id
  *       Organization_id         = Organization Id
  *       transaction_date        = Date of item cost
  *       cost_type_id            = Cost Type Used
  *       Prior Ind               = Prior period cost indicator
  *
  *  OUTPUT PARAMETERS
  *        None.
  *
  *  RETURNS
  *        total unit cost
  *
  *  HISTORY
  *       Anand Thiyagarajan  20-Feb-2007 Bug#5436964: Batches Across Periods FP
  ***************************************************************************************/
  FUNCTION get_cmpt_cost
  (
  p_inventory_item_id              IN                NUMBER,
  p_organization_id                IN                NUMBER,
  p_transaction_date               IN                DATE,
  p_cost_type_id                   IN                NUMBER,
  p_prior_period_cost              IN                NUMBER
  )
  RETURN NUMBER
  IS
    CURSOR              get_item_cost
    (
    v_inventory_item_id NUMBER,
    v_organization_id   NUMBER,
    v_transaction_date  DATE,
    v_cost_type_id      NUMBER
    )
    IS
    SELECT              nvl(sum(cst.cmpnt_cost), 0)
    FROM                cm_cmpt_dtl cst,
                        gmf_organization_definitions god,
                        gmf_fiscal_policies f,
                        gmf_period_statuses gps,
                        (
                        select  nvl (
                                    (
                                    SELECT        x.cost_organization_id
                                    FROM          cm_whse_asc x
                                    WHERE         x.organization_id = v_organization_id
                                    AND           x.eff_start_date  <= v_transaction_date
                                    AND           x.eff_end_date    >= v_transaction_date
                                    AND           x.delete_mark     = 0
                                    ), v_organization_id) organization_id
                        from dual
                        ) oasc
    WHERE               god.organization_id     = nvl(oasc.organization_id, v_organization_id)
    AND                 f.legal_entity_id       = god.legal_entity_id
    AND                 f.delete_mark           = 0
    AND                 gps.delete_mark         = 0
    AND                 gps.legal_entity_id     = f.legal_entity_id
    AND                 gps.cost_type_id        = nvl(v_cost_type_id, f.cost_type_id)
    AND                 v_transaction_date      BETWEEN gps.START_DATE AND gps.end_date
    AND                 cst.inventory_item_id   = v_inventory_item_id
    AND                 cst.organization_id     = NVL(oasc.organization_id, v_organization_id)
    AND                 cst.period_id           = gps.period_id
    AND                 cst.cost_type_id        = nvl(v_cost_type_id, f.cost_type_id);

    CURSOR              get_prior_period_end_date
    (
    v_organization_id   NUMBER,
    v_transaction_date  DATE,
    v_cost_type_id      NUMBER
    )
    IS
    SELECT              gps.end_date
    FROM                gmf_organization_definitions god,
                        gmf_fiscal_policies f,
                        gmf_period_statuses gps,
                        (
                        select  nvl (
                                    (
                                    SELECT        x.cost_organization_id
                                    FROM          cm_whse_asc x
                                    WHERE         x.organization_id = v_organization_id
                                    AND           x.eff_start_date  <= v_transaction_date
                                    AND           x.eff_end_date    >= v_transaction_date
                                    AND           x.delete_mark     = 0
                                    ), v_organization_id) organization_id
                        from dual
                        ) oasc
    WHERE               god.organization_id     = nvl(oasc.organization_id, v_organization_id)
    AND                 f.legal_entity_id       = god.legal_entity_id
    AND                 f.delete_mark           = 0
    AND                 gps.delete_mark         = 0
    AND                 gps.legal_entity_id     = f.legal_entity_id
    AND                 gps.cost_type_id        = nvl(v_cost_type_id, f.cost_type_id)
    AND                 gps.end_date            < v_transaction_date
    ORDER BY            gps.end_date desc;

    l_cost              NUMBER;
    l_transaction_date  DATE;
  BEGIN
    IF p_prior_period_cost = 1 THEN
      OPEN get_prior_period_end_date(p_organization_id, p_transaction_date, p_cost_type_id);
      FETCH get_prior_period_end_date INTO l_transaction_date;
      CLOSE get_prior_period_end_date ;
    ELSE
      l_transaction_date := p_transaction_date;
    END IF;

    OPEN  get_item_cost(p_inventory_item_id, p_organization_id, l_transaction_date, p_cost_type_id);
    FETCH get_item_cost INTO l_cost;
    CLOSE get_item_cost;

    RETURN l_cost;

  END get_cmpt_cost;

  /* ***********************************************************************************
  *  FUNCTION
  *       get_rsrc_cost
  *  DESCRIPTION
  *
  *	This function gets resource cost from cm_rsrc_dtl.
  *	This is being use in OPM Batch Cost Detail Report.
  *
  *  AUTHOR
  * 	Anand Thiyagarajan  20-Feb-2007  Bug#5436964 Batches Across Periods FP
  *
  *  INPUT PARAMETERS
  *       Resources               = Resource
  *       Organization_id         = Organization Id
  *       transaction_date        = Date of item cost
  *       cost_type_id            = Cost Type Used
  *       Prior Ind               = Prior period cost indicator
  *
  *  OUTPUT PARAMETERS
  *        None.
  *
  *  RETURNS
  *        Resource cost
  *
  *  HISTORY
  *       Anand Thiyagarajan  20-Feb-2007 Bug#5436964: Batches Across Periods FP
  ***************************************************************************************/
  FUNCTION get_rsrc_cost
  (
  p_resources                      IN                VARCHAR2,
  p_organization_id                IN                NUMBER,
  p_transaction_date               IN                DATE,
  p_cost_type_id                   IN                NUMBER,
  p_prior_period_cost              IN                NUMBER
  )
  RETURN NUMBER
  IS
    CURSOR              get_prior_period_end_date
    (
    v_organization_id   NUMBER,
    v_transaction_date  DATE,
    v_cost_type_id      NUMBER
    )
    IS
    SELECT              gps.end_date
    FROM                gmf_organization_definitions god,
                        gmf_fiscal_policies f,
                        gmf_period_statuses gps
    WHERE               god.organization_id   = v_organization_id
    AND                 f.legal_entity_id     = god.legal_entity_id
    AND                 f.delete_mark         = 0
    AND                 gps.delete_mark       = 0
    AND                 gps.legal_entity_id   = f.legal_entity_id
    AND                 gps.cost_type_id      = nvl(v_cost_type_id, f.cost_type_id)
    AND                 gps.end_date          < v_transaction_date
    ORDER BY            gps.end_date desc;

    CURSOR              get_rsrc_cost
    (
    v_resources         VARCHAR2,
    v_organization_id   NUMBER,
    v_transaction_date  DATE,
    v_cost_type_id      NUMBER
    )
    IS
    SELECT              nvl(sum(cst.nominal_cost), 0)
    FROM                cm_rsrc_dtl cst,
                        gmf_organization_definitions god,
                        gmf_fiscal_policies f,
                        gmf_period_statuses gps
    WHERE               god.organization_id   = v_organization_id
    AND                 f.legal_entity_id     = god.legal_entity_id
    AND                 f.delete_mark         = 0
    AND                 gps.delete_mark       = 0
    AND                 gps.legal_entity_id   = f.legal_entity_id
    AND                 gps.cost_type_id      = nvl(v_cost_type_id, f.cost_type_id)
    AND                 v_transaction_date    BETWEEN gps.START_DATE AND gps.end_date
    AND                 cst.resources         = v_resources
    AND                 (cst.organization_id  = v_organization_id OR cst.organization_id IS NULL)
    AND                 cst.period_id         = gps.period_id
    AND                 cst.cost_type_id      = nvl(v_cost_type_id, f.cost_type_id);

    l_cost              NUMBER;
    l_transaction_date  DATE;

  BEGIN
    IF p_prior_period_cost = 1 THEN
      OPEN get_prior_period_end_date(p_organization_id, p_transaction_date, p_cost_type_id);
      FETCH get_prior_period_end_date INTO l_transaction_date;
      CLOSE get_prior_period_end_date ;
 	  ELSE
 	    l_transaction_date := p_transaction_date;
 	  END IF;

    OPEN  get_rsrc_cost(p_resources, p_organization_id, l_transaction_date, p_cost_type_id);
    FETCH get_rsrc_cost INTO l_cost;
    CLOSE get_rsrc_cost;

    RETURN l_cost;

  END get_rsrc_cost;

END GMF_CMCOMMON ;

/
