--------------------------------------------------------
--  DDL for Package AR_ADJVALIDATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ADJVALIDATE_PUB" AUTHID CURRENT_USER AS
/* $Header: ARTAADVS.pls 115.3 2002/11/15 03:15:05 anukumar ship $ */

PROCEDURE Init_Context_Rec(
                p_validation_level    IN  VARCHAR2,
                p_return_status       IN OUT NOCOPY varchar2
                ) ;

PROCEDURE aapi_message (
	p_application_name IN varchar2,
        p_message_name IN varchar2,
	p_token1_name  IN varchar2 default NULL,
	p_token1_value IN varchar2 default NULL,
	p_token2_name IN varchar2 default NULL,
	p_token2_value IN varchar2 default NULL,
	p_token3_name IN varchar2 default NULL,
	p_token3_value IN varchar2 default NULL,
	p_msg_level IN number default FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH
       ) ;

PROCEDURE Cache_Details (
                p_return_status IN OUT NOCOPY varchar2
                )  ;


PROCEDURE Within_approval_limits(
        p_adj_amount	IN 	ar_adjustments.amount%type,
        p_inv_curr_code IN	ar_payment_schedules.invoice_currency_code%type,
        p_approved_flag	IN OUT NOCOPY	varchar2,
        p_return_status	IN OUT NOCOPY	varchar2
	        ) ;

PROCEDURE Validate_Type (
		p_adj_rec	IN 	ar_adjustments%rowtype,
		p_return_status	IN OUT NOCOPY	varchar2
	        ) ;

PROCEDURE Validate_Payschd (
		p_adj_rec	IN OUT NOCOPY	ar_adjustments%rowtype,
		p_ps_rec	IN OUT NOCOPY	ar_payment_schedules%rowtype,
		p_return_status	OUT NOCOPY	Varchar2
                ) ;

PROCEDURE Validate_amount (
               	p_adj_rec	IN OUT NOCOPY	ar_adjustments%rowtype,
		p_ps_rec	IN	ar_payment_schedules%rowtype,
		p_return_status	IN OUT NOCOPY	varchar2
	        );

PROCEDURE Validate_Rcvtrxccid (
		p_adj_rec	IN OUT NOCOPY 	ar_adjustments%rowtype,
                p_return_status	IN OUT NOCOPY	varchar2
	        ) ;

PROCEDURE Validate_dates (
		p_apply_date	IN 	ar_adjustments.apply_date%type,
                p_gl_date	IN	ar_adjustments.gl_date%type,
                p_ps_rec        IN	ar_payment_schedules%rowtype,
		p_return_status	IN OUT NOCOPY	varchar2
	        )  ;

PROCEDURE Validate_Reason_code (
		p_adj_rec	IN OUT NOCOPY	ar_adjustments%rowtype,
		p_return_status	IN OUT NOCOPY	varchar2
	        ) ;

PROCEDURE Validate_doc_seq (
		p_adj_rec	IN OUT NOCOPY	ar_adjustments%rowtype,
		p_return_status	IN OUT NOCOPY	varchar2
	        ) ;

PROCEDURE Validate_Associated_Receipt (
		p_adj_rec	IN 	ar_adjustments%rowtype,
		p_return_status	IN OUT NOCOPY	varchar2
	        ) ;

PROCEDURE Validate_Ussgl_code (
		p_adj_rec	IN OUT NOCOPY	ar_adjustments%rowtype,
		p_return_status	IN OUT NOCOPY	varchar2
	        ) ;

PROCEDURE Validate_Desc_Flexfield(
                p_adj_rec	IN OUT NOCOPY	ar_adjustments%rowtype,
                p_return_status	IN OUT NOCOPY	varchar2
	        ) ;

PROCEDURE Validate_Created_From (
		p_adj_rec	IN 	ar_adjustments%rowtype,
		p_return_status	IN OUT NOCOPY	varchar2
	        ) ;

END ar_adjvalidate_pub;


 

/
