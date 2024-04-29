--------------------------------------------------------
--  DDL for Package FA_LEASE_PITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_LEASE_PITEMS_PKG" AUTHID CURRENT_USER AS
/* $Header: FAXLPIES.pls 120.1.12010000.2 2009/07/19 14:15:47 glchen ship $ */

/* This is a wrapper procedure for inserting a row into table
   FA_LEASE_PAYMENT_ITEMS.*/
PROCEDURE  Insert_Row(

	X_Lease_ID			IN	NUMBER,
	X_Payment_Schedule_ID		IN	NUMBER,
	X_Schedule_Amort_Line_Num	IN	NUMBER,
	X_Export_Status			IN	VARCHAR2,
	X_Lessor_ID			IN	NUMBER,
	X_Lessor_Site_ID		IN	NUMBER,
	X_Dist_Code_Combination_ID	IN	NUMBER,
        X_Invoice_Number		IN	VARCHAR2,
	X_Invoice_ID			IN	NUMBER,
	X_Invoice_Line_ID		IN	NUMBER,
        X_Terms_ID                      IN      NUMBER,
	X_Last_Updated_by		IN	NUMBER,
	X_Last_Update_Date		IN	DATE,
	X_Last_Update_Login		IN	NUMBER,
	X_Created_by			IN	NUMBER,
	X_Creation_Date			IN	DATE,
	X_Request_ID			IN	NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

/* This is a wrapper procedure for updating a row of table
   FA_LEASE_PAYMENT_ITEMS.*/
PROCEDURE  Update_Row(

        X_Rowid				IN	VARCHAR2,
	X_Lease_ID			IN	NUMBER,
	X_Payment_Schedule_ID		IN	NUMBER,
	X_Schedule_Amort_Line_Num	IN	NUMBER,
	X_Export_Status			IN	VARCHAR2,
	X_Lessor_ID			IN	NUMBER,
	X_Lessor_Site_ID		IN	NUMBER,
	X_Dist_Code_Combination_ID	IN	NUMBER,
        X_Invoice_Number		IN	VARCHAR2,
	X_Invoice_ID			IN	NUMBER,
	X_Invoice_Line_ID		IN	NUMBER,
        X_Terms_ID                      IN      NUMBER,
	X_Last_Updated_by		IN	NUMBER,
	X_Last_Update_Date		IN	DATE,
	X_Last_Update_Login		IN	NUMBER,
	X_Created_by			IN	NUMBER,
	X_Creation_Date			IN	DATE,
	X_Request_ID			IN	NUMBER := NULL, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

/* Procedure Lock_Rows() locks all rows in FA_LEASE_PAYMENT_ITEMS
   associated with the specified lease.*/
PROCEDURE   Lock_Rows(
        X_Lease_ID              IN      NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

/* Procedure Delete_Rows() deletes all rows in FA_LEASE_PAYMENT_ITEMS
   associated with the specified lease.*/
PROCEDURE Delete_Rows(
	X_Lease_ID		IN	NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type);

/* Function Payments_Itemize() will create payment items for a lease.
   New rows will be inserted into table FA_LEASE_PAYMENT_ITEMS. It will
   be called after a user associates a schedule with a lease. A user
   can also sumbit a concurrent program to run it to create payment
   items for existing leases. */
FUNCTION  Payments_Itemize (

	P_Lease_ID     	            IN      NUMBER,
	P_Payment_Schedule_ID	    IN      NUMBER,
        P_Lessor_ID                 IN      NUMBER,
        P_Lessor_Site_ID            IN      NUMBER := NULL,
        P_Dist_Code_Combination_ID  IN      NUMBER := NULL,
        P_Terms_ID                  IN      NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)

RETURN  BOOLEAN;

END FA_LEASE_PITEMS_PKG;

/
