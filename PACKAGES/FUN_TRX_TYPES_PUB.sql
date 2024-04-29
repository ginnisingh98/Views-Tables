--------------------------------------------------------
--  DDL for Package FUN_TRX_TYPES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_TRX_TYPES_PUB" AUTHID CURRENT_USER AS
--  $Header: funtrxutils.pls 120.8.12010000.3 2009/10/22 11:28:30 srampure ship $

/****************************************************************
* PROCEDURE  get_trx_type_by_id					*
*								*
*	This procedure returns status of a transaction and the 	*
*	invoicing option for a given trx_type_id		*
****************************************************************/

	PROCEDURE get_trx_type_by_id (
	  p_trx_type_id in number,
	  x_trx_type_code out NOCOPY varchar2,
	  x_need_invoice out NOCOPY varchar2,
	  x_enabled out NOCOPY varchar2
	) ;


/****************************************************************
* PROCEDURE  :get_trx_type_code					*
*								*
*	This procedure returns the status of a transaction and 	*
*	invoicing option for a given transaction type code	*
****************************************************************/

	PROCEDURE get_trx_type_by_code (
	  p_trx_type_code in varchar2,
	  x_trx_type_id out NOCOPY number,
	  x_need_invoice out NOCOPY varchar2,
	  x_enabled out NOCOPY varchar2
	);

/****************************************************************
* FUNCTION  : is_trx_type_manual_approve			*
*								*
*	This function returns the manual approval option for a 	*
*	transaction type name given trx_type_id			*
****************************************************************/

	FUNCTION is_trx_type_manual_approve
	(
	  p_trx_type_id in number
	) RETURN VARCHAR2;


/****************************************************************
* PROCEDURE  : get_trx_type_map					*
* 								*
*	This procedure returns the mapping details of transation*
*	type name given the org it is associated with and the id*
****************************************************************/

	PROCEDURE get_trx_type_map (
	  p_org_id in number,
	  p_trx_type_id in number,
          p_trx_date    in date,
	  p_trx_id in number,
	  x_memo_line_id   out NOCOPY Number,
	  x_memo_line_name out NOCOPY varchar2,
	  x_ar_trx_type_id out NOCOPY Number,
	  x_ar_trx_type_name out NOCOPY varchar2,
	  x_default_term_id  out NOCOPY NUMBER
	);

/****************************************************************
* FUNCTION  : get_ar_trx_creation_sign    			*
*								*
*	For a given intercompany transaction type, this function*
*       returns the transaction creation sign of the associated *
*	AR transaction type. The input to the function is the   *
*	intercompany transaction type, organization id and the  *
*	transaction batch date                                  *
*								*
****************************************************************/

       FUNCTION get_ar_trx_creation_sign (
	  p_org_id in number,
	  p_trx_type_id in number,
          p_trx_date    in date,
	  p_trx_type in varchar2
       ) RETURN NUMBER;


END FUN_TRX_TYPES_PUB;

/
