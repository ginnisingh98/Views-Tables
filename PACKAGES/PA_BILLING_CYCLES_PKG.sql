--------------------------------------------------------
--  DDL for Package PA_BILLING_CYCLES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BILLING_CYCLES_PKG" AUTHID CURRENT_USER AS
-- $Header: PAXIBCLS.pls 115.2 2002/03/04 04:52:21 pkm ship     $
function    Get_Billing_Date (
                        X_Project_ID            IN  Number,
                        X_Project_Start_Date    IN  Date,
                        X_Billing_Cycle_ID      IN  Number,
                        X_Bill_Thru_Date        IN  Date,
                        X_Last_Bill_Thru_Date   IN  Date
                                )   RETURN Date;

        pragma RESTRICT_REFERENCES ( Get_Billing_Date, WNDS, WNPS );
	function	Get_Next_Billing_Date (
						X_Project_ID			IN	Number,
						X_Project_Start_Date	IN	Date	default NULL,
						X_Billing_Cycle_ID		IN	Number	default NULL,
						X_Billing_Offset_Days	IN	Number	default NULL,
						X_Bill_Thru_Date		IN	Date	default NULL,
						X_Last_Bill_Thru_Date	IN	Date	default NULL
								)	RETURN Date;
	pragma RESTRICT_REFERENCES ( Get_Next_Billing_Date, WNDS, WNPS );

--

	function	Get_Last_Bill_Thru_Date (
						X_Project_ID			IN	Number
								)	RETURN Date;
	pragma RESTRICT_REFERENCES ( Get_Last_Bill_Thru_Date, WNDS, WNPS );

--

	function	Get_Last_Released_Invoice_Num (
                        X_Project_ID            IN  Number
                                )   RETURN Number;
	pragma RESTRICT_REFERENCES ( Get_Last_Released_Invoice_Num, WNDS, WNPS );

--

END PA_Billing_Cycles_Pkg;


 

/
