--------------------------------------------------------
--  DDL for Package Body CSTPACWB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPACWB" AS
/* $Header: CSTPACBB.pls 115.7 2002/11/08 23:23:45 awwang ship $ */

PROCEDURE cost_in (
 I_TRX_ID                       IN      NUMBER,
 I_LAYER_ID                     IN      NUMBER,
 I_COMM_ISS_FLAG                IN      NUMBER,
 I_COST_TXN_ACTION_ID           IN      NUMBER,
 I_TXN_QTY                      IN      NUMBER,
 I_PERIOD_ID                    IN      NUMBER,
 I_WIP_ENTITY_ID                IN      NUMBER,
 I_ORG_ID                       IN      NUMBER,
 I_USER_ID                      IN      NUMBER,
 I_REQUEST_ID                   IN      NUMBER,
 ERR_NUM                        OUT NOCOPY     NUMBER,
 ERR_CODE                       OUT NOCOPY     VARCHAR2,
 ERR_MSG                        OUT NOCOPY     VARCHAR2) IS

 stmt_num				NUMBER;
 no_row_wpb				EXCEPTION;
 translated_mesg			varchar2(2000) := null;
 l_debug                                varchar2(80);

---------
 l_round_unit 				NUMBER;
 l_precision 				number;
 l_ext_precision			number;
---------
 BEGIN

     l_debug := fnd_profile.value('MRP_DEBUG');

      if (l_debug = 'Y') then
		fnd_file.put_line(fnd_file.log,'ERR_NUM');
      end if;
---------
    CSTPUTIL.CSTPUGCI (i_org_id, l_round_unit, l_precision, l_ext_precision);
---------

	/*----------------------------------------------------
	* This procedure will be called for Component Issue/ *
	* Returns and Negative component issue/returns ...   *
	*---------------------------------------------------*/

	/* -----------------------------------------------------+
	| The join to mcacd needs to be conditional because the
	| COmmon Issue To Wip (CITW) transaction needs to be considered.
	| In a regular WIP transaction there will only be one set of
	| cost rows , having a unique layer_id against a specific
	| transaction_id in MCACD. In the case of a CITW transaction
 	| however, though the transaction in MMT seems like a regular
 	| issue, we actually create 3 rows in MMT because the txn is
	| costed first as a subinc xfr and then as an issue. Therefore,
	| we have 3 sets of cost rows.
	| 2 of these sets of rows are for teh subxfr,1 set for the common
	| issuing layer and  one for the project receiving layer.
	| There will be one  set of rows for the WIP issue and the update
	| to WPB should be done using this row. The comm_iss_flag = 1
	| indicates that the txn is a CITW. Hence the layer_id and the
	| cost_txn_action_id passed in should be joined to in MCACD to
	| obtain the correct set of rows.
	|--------------------------------------------------------------*/

	stmt_num := 20;
       /* initializing err_num */
        err_num := 0;

	UPDATE WIP_PERIOD_BALANCES WPB
	SET
	(LAST_UPDATE_DATE,
	 LAST_UPDATED_BY,
	 LAST_UPDATE_LOGIN,
	 REQUEST_ID,
	 PROGRAM_APPLICATION_ID,
	 PROGRAM_ID,
 	 PROGRAM_UPDATE_DATE,
	 PL_MATERIAL_IN,
	 PL_MATERIAL_OVERHEAD_IN,
	 PL_RESOURCE_IN,
	 PL_OUTSIDE_PROCESSING_IN,
	 PL_OVERHEAD_IN) =
	(SELECT
	 SYSDATE,
	 I_USER_ID,
	 -1,
	 I_REQUEST_ID,
	 -1,
	 -1,
	 SYSDATE,
	 nvl(wpb.pl_material_in,0) +
	 (round((sum(decode(cost_element_id,1,nvl(actual_cost,0),
				    2,0,
				    3,0,
				    4,0,
				    5,0))*(-1*i_txn_qty))/l_round_unit)*l_round_unit),

	 nvl(wpb.pl_material_overhead_in,0) +
	 (round((sum(decode(cost_element_id,2,nvl(actual_cost,0),
                                    1,0,
                                    3,0,
                                    4,0,
                                    5,0))*(-1*i_txn_qty))/l_round_unit)*l_round_unit),

	 nvl(wpb.pl_resource_in,0) +
	 (round((sum(decode(cost_element_id,3,nvl(actual_cost,0),
              		            1,0,
				    2,0,
				    4,0,
				    5,0))*(-1*i_txn_qty))/l_round_unit)*l_round_unit),

	 nvl(wpb.pl_outside_processing_in,0) +
	 (round((sum(decode(cost_element_id,4,nvl(actual_cost,0),
                                    1,0,
                                    2,0,
                                    3,0,
				    5,0))*(-1*i_txn_qty))/l_round_unit)*l_round_unit),

	 nvl(wpb.pl_overhead_in,0) +
	 (round((sum(decode(cost_element_id,5,nvl(actual_cost,0),
                                    1,0,
                                    2,0,
                                    3,0,
                                    4,0))*(-1*i_txn_qty))/l_round_unit)*l_round_unit)

	FROM
	mtl_cst_actual_cost_details
	WHERE
	TRANSACTION_ID		=	I_TRX_ID 	AND
	DECODE(I_COMM_ISS_FLAG,1,I_LAYER_ID,LAYER_ID)
				=	LAYER_ID	AND
        nvl(DECODE(I_COMM_ISS_FLAG,1,
	       I_COST_TXN_ACTION_ID,TRANSACTION_ACTION_ID),-99)
				=	nvl(TRANSACTION_ACTION_ID,-99))
	WHERE
	WIP_ENTITY_ID		=	I_WIP_ENTITY_ID		AND
	ORGANIZATION_ID		=	I_ORG_ID		AND
	ACCT_PERIOD_ID		=	I_PERIOD_ID;


 -- If no rows were updated then, this ,means there are no rows in
 -- wip_period_balances and this condition needs to be an error.

	IF SQL%ROWCOUNT = 0 THEN

	RAISE NO_ROW_WPB;

	END IF;



 EXCEPTION

 WHEN NO_ROW_WPB THEN

 ERR_NUM := -999;
 err_code := 'CST_NO_BALANCE_ROW';
 fnd_message.set_name('BOM','CST_NO_BALANCE_ROW');
 translated_mesg := fnd_message.get ;
 ERR_MSG := substr(translated_mesg,1,240) ;

 -- Appropriate error code needs to be flagged here to indicate no rows
 -- in wip_period_balances.

 WHEN OTHERS THEN

 ERR_NUM := -999;
 ERR_MSG := 'CSTPACBB:cost_in' || to_char(stmt_num) || substr(SQLERRM,1,150);



 END cost_in;


PROCEDURE cost_out (
 I_TRX_ID                       IN      NUMBER,
 I_TXN_QTY                      IN      NUMBER,
 I_PERIOD_ID                    IN      NUMBER,
 I_WIP_ENTITY_ID                IN      NUMBER,
 I_ORG_ID                       IN      NUMBER,
 I_USER_ID                      IN      NUMBER,
 I_REQUEST_ID                   IN      NUMBER,
 ERR_NUM                        OUT NOCOPY     NUMBER,
 ERR_CODE                       OUT NOCOPY     VARCHAR2,
 ERR_MSG                        OUT NOCOPY     VARCHAR2)  IS

 stmt_num                               NUMBER;
 no_row_wpb				EXCEPTION;

---------
 l_round_unit 				NUMBER;
 l_precision 				number;
 l_ext_precision			number;
---------
 BEGIN


        /*------------------------------------------------------
        * This procedure will be called for Assembly completion *
        * , Returns and Scrap transactions ...   	        *
        *-------------------------------------------------------*/

---------
    CSTPUTIL.CSTPUGCI (i_org_id, l_round_unit, l_precision, l_ext_precision);
---------

        stmt_num := 20;
 /* initialize variable err num */                                                         err_num := 0;

        UPDATE WIP_PERIOD_BALANCES WPB
        SET
        (LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,
         REQUEST_ID,
         PROGRAM_APPLICATION_ID,
         PROGRAM_ID,
         PROGRAM_UPDATE_DATE,
         PL_MATERIAL_OUT,
         PL_MATERIAL_OVERHEAD_OUT,
         PL_RESOURCE_OUT,
         PL_OUTSIDE_PROCESSING_OUT,
         PL_OVERHEAD_OUT,
         TL_MATERIAL_OUT,
         TL_MATERIAL_OVERHEAD_OUT,
         TL_RESOURCE_OUT,
         TL_OUTSIDE_PROCESSING_OUT,
         TL_OVERHEAD_OUT) =
	(SELECT
         SYSDATE,
         I_USER_ID,
         -1,
         I_REQUEST_ID,
         -1,
         -1,
         SYSDATE,
	 nvl(wpb.pl_material_out,0) +
	 (round((i_txn_qty* sum(decode(level_type,2, decode(cost_element_id,1,
		nvl(actual_cost,0), 0), 0)))/l_round_unit)*l_round_unit),

	 nvl(wpb.pl_material_overhead_out,0) +
         (round((i_txn_qty* sum(decode(level_type,2, decode(cost_element_id,2,
		nvl(actual_cost,0), 0), 0)))/ l_round_unit)*l_round_unit),

         nvl(wpb.pl_resource_out,0) +
         (round((i_txn_qty* sum(decode(level_type,2, decode(cost_element_id,3,
		nvl(actual_cost,0), 0), 0)))/l_round_unit)*l_round_unit),

	 nvl(wpb.pl_outside_processing_out,0) +
         (round((i_txn_qty* sum(decode(level_type,2, decode(cost_element_id,4,
		nvl(actual_cost,0), 0), 0)))/l_round_unit)*l_round_unit),

         nvl(wpb.pl_overhead_out,0) +
         (round((i_txn_qty* sum(decode(level_type,2, decode(cost_element_id,5,
		nvl(actual_cost,0), 0), 0)))/l_round_unit)*l_round_unit),

         nvl(wpb.tl_material_out,0) +
         (round((i_txn_qty* sum(decode(level_type,1, decode(cost_element_id,1,
		nvl(actual_cost,0), 0), 0)))/l_round_unit)*l_round_unit),

	 nvl(wpb.tl_material_overhead_out,0) + 0,	/* The TL MO never gets Cr to the Job*/

         nvl(wpb.tl_resource_out,0) +
         (round((i_txn_qty* sum(decode(level_type,1, decode(cost_element_id,3,
		nvl(actual_cost,0), 0), 0)))/l_round_unit)*l_round_unit),

         nvl(wpb.tl_outside_processing_out,0) +
         (round((i_txn_qty* sum(decode(level_type,1, decode(cost_element_id,4,
		nvl(actual_cost,0), 0), 0)))/l_round_unit)*l_round_unit),

	 nvl(wpb.tl_overhead_out,0) +
         (round((i_txn_qty* sum(decode(level_type,1, decode(cost_element_id,5,
		nvl(actual_cost,0), 0), 0)))/l_round_unit)*l_round_unit)
        FROM
        mtl_cst_actual_cost_details
        WHERE
        TRANSACTION_ID          =       I_TRX_ID)
        WHERE
        WIP_ENTITY_ID           =       I_WIP_ENTITY_ID         AND
        ORGANIZATION_ID         =       I_ORG_ID                AND
        ACCT_PERIOD_ID          =       I_PERIOD_ID;


 -- If no rows were updated then, this ,means there are no rows in
 -- wip_period_balances and this condition needs to be an error.

        IF SQL%ROWCOUNT = 0 THEN

        RAISE NO_ROW_WPB;

        END IF;



 EXCEPTION

 WHEN NO_ROW_WPB THEN

 ERR_NUM := -999;

 -- Appropriate error code needs to be flagged here to indicate no rows
 -- in wip_period_balances.

 WHEN OTHERS THEN

 ERR_NUM := -999;
 ERR_MSG := 'CSTPACBB:cost_out' || to_char(stmt_num) || substr(SQLERRM,1,150);




 END cost_out;

END CSTPACWB;

/
