--------------------------------------------------------
--  DDL for Package FV_AP_CASH_POS_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_AP_CASH_POS_DTL_PKG" AUTHID CURRENT_USER AS
/* $Header: FVAPCPDS.pls 120.4 2005/11/25 11:30:48 bnarang ship $*/

PROCEDURE MAIN (errbuf OUT NOCOPY varchar2,
		retcode out NOCOPY NUMBER,
                p_payment_batch in NUMBER,
                p_org_id In number) ;

PROCEDURE Initialize_Process;

PROCEDURE Create_Cash_Position_Record;
Procedure get_segment_num ;

End  FV_AP_CASH_POS_DTL_PKG;

 

/
