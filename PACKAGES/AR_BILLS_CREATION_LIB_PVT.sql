--------------------------------------------------------
--  DDL for Package AR_BILLS_CREATION_LIB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_BILLS_CREATION_LIB_PVT" AUTHID CURRENT_USER AS
/* $Header: ARBRCRLS.pls 115.2 2002/11/15 01:49:10 anukumar ship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30)   := 'AR_BILLS_CREATION_LIB_PVT';



PROCEDURE  Default_Create_BR_Header
		(   	p_trx_rec		IN OUT NOCOPY		ra_customer_trx%ROWTYPE			,
			p_gl_date		IN OUT NOCOPY		DATE					);


PROCEDURE  Default_Update_BR_Header
		(	p_trx_rec		IN OUT NOCOPY		ra_customer_trx%ROWTYPE			);


PROCEDURE  Default_Create_BR_Assignment
		(	p_trl_rec  		IN OUT NOCOPY  	ra_customer_trx_lines%ROWTYPE		,
			p_ps_rec   		IN     		ar_payment_schedules%ROWTYPE		);


PROCEDURE  Default_GL_date
		(	p_entered_date		IN  		DATE					,
			p_gl_date      		OUT NOCOPY 		DATE					,
	        	p_return_status 	OUT NOCOPY 		VARCHAR2				);

PROCEDURE  DeAssign_BR
		(	p_customer_trx_id   	IN  		ra_customer_trx.customer_trx_id%TYPE	);


PROCEDURE  Get_Payment_Schedule_ID
		(	p_customer_trx_id 	 IN    		ra_customer_trx.customer_trx_id%TYPE	,
			p_payment_schedule_id 	 OUT NOCOPY   		ar_payment_schedules.payment_schedule_id%TYPE);


PROCEDURE  Validate_Desc_Flexfield
		(	p_attribute_category	IN OUT NOCOPY 		VARCHAR2				,
			p_attribute1		IN OUT NOCOPY 		VARCHAR2				,
			p_attribute2		IN OUT NOCOPY 		VARCHAR2				,
			p_attribute3		IN OUT NOCOPY 		VARCHAR2				,
			p_attribute4		IN OUT NOCOPY 		VARCHAR2				,
			p_attribute5		IN OUT NOCOPY 		VARCHAR2				,
			p_attribute6		IN OUT NOCOPY 		VARCHAR2				,
			p_attribute7		IN OUT NOCOPY 		VARCHAR2				,
			p_attribute8		IN OUT NOCOPY 		VARCHAR2				,
			p_attribute9		IN OUT NOCOPY 		VARCHAR2				,
			p_attribute10		IN OUT NOCOPY 		VARCHAR2				,
			p_attribute11		IN OUT NOCOPY 		VARCHAR2				,
			p_attribute12		IN OUT NOCOPY 		VARCHAR2				,
			p_attribute13		IN OUT NOCOPY		VARCHAR2				,
			p_attribute14		IN OUT NOCOPY 		VARCHAR2				,
			p_attribute15		IN OUT NOCOPY 		VARCHAR2				,
               		p_desc_flex_name      	IN 		VARCHAR2				);


END AR_BILLS_CREATION_LIB_PVT ;

 

/
