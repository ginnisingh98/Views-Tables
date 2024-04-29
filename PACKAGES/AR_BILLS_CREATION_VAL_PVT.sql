--------------------------------------------------------
--  DDL for Package AR_BILLS_CREATION_VAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_BILLS_CREATION_VAL_PVT" AUTHID CURRENT_USER AS
/* $Header: ARBRCRVS.pls 115.2 2002/11/15 01:49:35 anukumar ship $ */


--Validation procedures are contained in this package


PROCEDURE  Validate_Gl_Date
		(	p_gl_date  		IN  	DATE				);


PROCEDURE  Validate_Create_BR_Header
		(	p_trx_rec   		IN	ra_customer_trx%ROWTYPE		,
		  	p_gl_date		IN	DATE				);


PROCEDURE  Validate_Update_BR_Header
		( 	p_trx_rec		IN	ra_customer_trx%ROWTYPE		,
			p_gl_date		IN	DATE				);


PROCEDURE  Validate_BR_Assignment
		(	p_trl_rec    		IN OUT NOCOPY	ra_customer_trx_lines%ROWTYPE	,
			p_ps_rec		IN	ar_payment_schedules%ROWTYPE	,
			p_trx_rec		IN	ra_customer_trx%ROWTYPE		,
			p_BR_rec		IN	ra_customer_trx%ROWTYPE		);


PROCEDURE  Validate_Customer_Trx_ID
		( 	p_customer_trx_id	IN 	NUMBER				);


PROCEDURE  Validate_Customer_Trx_Line_ID
		( 	p_customer_trx_line_id	IN  	NUMBER				);


PROCEDURE Validate_BR_Status
		( 	p_customer_trx_id	IN  	NUMBER				);


FUNCTION  Is_Transaction_BR
		(	p_cust_trx_type_id	IN  	NUMBER				) RETURN BOOLEAN;


PROCEDURE Validate_Assignment_Status
		( 	p_customer_trx_id	IN  	NUMBER				,
			p_trx_number		IN	ar_payment_schedules.trx_number%TYPE);


END AR_BILLS_CREATION_VAL_PVT;

 

/
