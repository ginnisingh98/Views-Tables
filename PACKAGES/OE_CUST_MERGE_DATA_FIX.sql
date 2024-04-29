--------------------------------------------------------
--  DDL for Package OE_CUST_MERGE_DATA_FIX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CUST_MERGE_DATA_FIX" AUTHID CURRENT_USER AS
/* $Header: OEXCMDFS.pls 120.0 2005/05/31 22:30:10 appldev noship $ */

G_PKG_NAME       CONSTANT VARCHAR2(30) := 'OE_CUST_MERGE_DATA_FIX';

  -----------------------------------------------------------------
  --
  --	MAIN PROCEDURE
  --
  -- Procedure Name: Merge
  -- Parameter:      Req_id, Set_Num, Process_Mode
  --
  -- This is the main procedure to do customer merge for ONT product.
  -- This procedure calls other internal procedures to process
  -- the merging based on the functional areas.  Please see the HLD for
  -- Customer Merge for detail information (cmerge_hld.rtf).
  --
  ------------------------------------------------------------------
  Procedure Merge (Req_Id 			IN NUMBER,
	           		Set_Num 		IN NUMBER,
		   			Process_Mode 	IN VARCHAR2
		   			);


 -----------------------------------------------------------------
 --
 -- INTERNAL PROCEDURES
 --
 -----------------------------------------------------------------

 Procedure OE_Attachment_Merge(Req_Id          IN NUMBER,
			      				 Set_Num       IN NUMBER,
			       				Process_Mode   IN VARCHAR2
			        			);

 Procedure OE_Defaulting_Merge (Req_Id          IN NUMBER,
								Set_Num         IN NUMBER,
								Process_Mode    IN VARCHAR2
								);
 Procedure OE_Constraints_Merge (Req_Id             IN NUMBER,
			         				Set_Num         IN NUMBER,
				 					Process_Mode    IN VARCHAR2
								 );
 Procedure OE_Sets_Merge (Req_Id            IN NUMBER,
			  				Set_Num         IN NUMBER,
			  				Process_Mode    IN VARCHAR2
			  				);
 Procedure OE_Drop_Ship_Merge (Req_Id           IN NUMBER,
			       				Set_Num         IN NUMBER,
			       				Process_Mode    IN VARCHAR2
			      				 );
 Procedure OE_Ship_Tolerance_Merge (Req_Id           IN NUMBER,
				           			Set_Num          IN NUMBER,
			                         Process_Mode    IN VARCHAR2
			             			);

 Procedure OE_Hold_Merge      (Req_Id           IN NUMBER,
								Set_Num         IN NUMBER,
								Process_Mode    IN VARCHAR2
								);

 Procedure OE_Order_Merge     (Req_Id          IN NUMBER,
			       				Set_Num         IN NUMBER,
			       				Process_Mode    IN VARCHAR2
			       				);
 Procedure OE_Workflow_Merge  (Req_Id 		IN NUMBER,
								Set_Num		IN NUMBER,
							Process_Mode    IN VARCHAR2
								);

END OE_CUST_MERGE_DATA_FIX;


 

/
