--------------------------------------------------------
--  DDL for Package AR_ADJVALIDATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ADJVALIDATE_PVT" AUTHID CURRENT_USER AS
/* $Header: ARXVADJS.pls 120.3.12010000.2 2008/11/13 10:18:15 dgaurab ship $*/

PROCEDURE Init_Context_Rec(
                p_validation_level    IN  VARCHAR2  := FND_API.G_VALID_LEVEL_FULL,
                p_return_status       IN OUT NOCOPY varchar2
                ) ;

PROCEDURE Cache_Details (
                p_return_status IN OUT NOCOPY varchar2
                )  ;


PROCEDURE Within_Approval_Limits(
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
		p_return_status	OUT NOCOPY	Varchar2,
		p_from_llca_call    IN  varchar2 DEFAULT 'N'
                ) ;

PROCEDURE Validate_Amount (
               	p_adj_rec	      IN OUT NOCOPY ar_adjustments%rowtype,
		p_ps_rec	      IN     ar_payment_schedules%rowtype,
                p_chk_approval_limits IN     varchar2,
                p_check_amount        IN     varchar2,
		p_return_status	      IN OUT NOCOPY varchar2
	        );

PROCEDURE Validate_Rcvtrxccid (
		p_adj_rec	    IN OUT NOCOPY ar_adjustments%rowtype,
                p_ps_rec              IN     ar_payment_schedules%rowtype,
                p_return_status	    IN OUT NOCOPY varchar2,
		p_from_llca_call    IN  varchar2 DEFAULT 'N'
	        ) ;

PROCEDURE Validate_Dates (
		p_apply_date	IN 	ar_adjustments.apply_date%type,
                p_gl_date	IN	ar_adjustments.gl_date%type,
                p_ps_rec        IN	ar_payment_schedules%rowtype,
		p_return_status	IN OUT NOCOPY	varchar2
	        )  ;

PROCEDURE Validate_Reason_Code (
		p_adj_rec	IN OUT NOCOPY	ar_adjustments%rowtype,
		p_return_status	IN OUT NOCOPY	varchar2
	        ) ;

PROCEDURE Validate_Doc_Seq (
		p_adj_rec	IN OUT NOCOPY	ar_adjustments%rowtype,
		p_return_status	IN OUT NOCOPY	varchar2
	        ) ;

PROCEDURE Validate_Associated_Receipt (
		p_adj_rec	IN 	ar_adjustments%rowtype,
		p_return_status	IN OUT NOCOPY	varchar2
	        ) ;

PROCEDURE Validate_Ussgl_Code (
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

PROCEDURE Validate_Over_Application (
		p_adj_rec	IN 	ar_adjustments%rowtype,
                p_ps_rec        IN	ar_payment_schedules%rowtype,
		p_return_status	IN OUT NOCOPY	varchar2
	        ) ;

-- Added for line level application
PROCEDURE Validate_Over_Application_llca (
		p_adj_rec	IN 	ar_adjustments%rowtype,
		p_ps_rec        IN	ar_payment_schedules%rowtype,
                p_return_status	IN OUT NOCOPY	varchar2
	        );

END AR_ADJVALIDATE_PVT;


/
