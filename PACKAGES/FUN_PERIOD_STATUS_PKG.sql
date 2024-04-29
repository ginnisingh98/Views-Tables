--------------------------------------------------------
--  DDL for Package FUN_PERIOD_STATUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_PERIOD_STATUS_PKG" AUTHID CURRENT_USER AS
/* $Header: funprdstss.pls 120.6.12010000.2 2008/08/06 07:47:55 makansal ship $ */

/***********************************************
* Procedure Close_Period :
*                        This Procedure Closes specified Intercompany Period or    *
*  all the periods. It checks whether there are any Open Intercompany Transactions.*
*  If Yes, then user can sweep the transactions to next open period before closing *
*  the Period.									   *
***************************************************/
	PROCEDURE Close_Period
	(
	 p_api_version 		IN NUMBER,
	 p_init_msg_list 		IN VARCHAR2 default null,
	 p_commit	       	IN VARCHAR2 default null,
	 x_return_status 		OUT NOCOPY VARCHAR2,
	 x_message_count 	OUT NOCOPY NUMBER,
	 x_message_data 	OUT NOCOPY VARCHAR2,
	 p_period_name 		IN VARCHAR2,
	 p_trx_type_id	 	IN NUMBER,
	 p_sweep 		IN VARCHAR2,
	 p_sweep_GL_date 	IN DATE,
	 x_request_id 		OUT NOCOPY NUMBER
	);


/***********************************************
* Procedure Get_Period_Status :
*           This API Checks whether Application Module (AP, AR, GL) can close their *
*  periods. It checks whether Intercompany Period is closed and if yes then whether *
*  any Open Transactions exists for the given Period.				    *
*		                        					    *
***************************************************/
	PROCEDURE Get_Period_Status
	(
	 p_api_version 		IN NUMBER,
	 p_application_id 	IN NUMBER,
	 x_return_status 	OUT NOCOPY VARCHAR2,
	 x_message_count 	OUT NOCOPY NUMBER,
	 x_message_data 	OUT NOCOPY VARCHAR2,
	 p_period_set_name	IN VARCHAR2,
	 p_period_type		IN VARCHAR2,
	 p_period_name 		IN VARCHAR2,
	 p_ledger_id 		IN NUMBER,
	 p_org_id 		IN NUMBER,
	 x_close		OUT NOCOPY VARCHAR2
	);

/**********************************************
* Procedure sweep_partial_batches
*	Bug : 6892783
*	This API Sweeps Partially complete Batches to given period
*
************************************************/

	PROCEDURE sweep_partial_batches
	(
	p_errbuff                       OUT NOCOPY VARCHAR2,
      	p_period_name                   IN VARCHAR2,
      	p_trx_type_id                   IN NUMBER,
      	p_sweep_GL_date                 IN DATE
	);

/***********************************************
* Procedure Sweep_Transactions :
*           This API sweeps transactions from the given period to specified next   *
*    open period. 							           *
*   		                        				           *
***************************************************/


	PROCEDURE sweep_transactions
	 (
	p_errbuff  			OUT NOCOPY VARCHAR2,
	p_retcode 			OUT NOCOPY NUMBER,
  	p_api_version			IN NUMBER,
 	p_period_name			IN VARCHAR2,
  	p_trx_type_id			IN NUMBER,
	p_sweep_GL_date 		IN DATE,
	p_debug				IN VARCHAR2 default null,
	p_close				IN VARCHAR2 default null
);

/***********************************************
* Procedure Sync_calendars :
*           This API sychronises the GL Calendar withthat of the  Intercompany     *
*    Calendar . 							           *
*   		                        				           *
***************************************************/
procedure sync_calendars ;

/***********************************************
* Function get_fun_prd_status :
*          This API accepts date and trx type and returns status in Intercompany   *
*   		                        				           *
***************************************************/
FUNCTION  get_fun_prd_status(p_date Date, p_trx_type_id number)
RETURN VARCHAR2;


END FUN_PERIOD_STATUS_PKG;

/
