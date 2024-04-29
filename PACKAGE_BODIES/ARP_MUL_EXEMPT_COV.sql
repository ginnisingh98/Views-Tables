--------------------------------------------------------
--  DDL for Package Body ARP_MUL_EXEMPT_COV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_MUL_EXEMPT_COV" as
/* $Header: ARXEMECB.pls 120.5 2006/05/10 00:08:49 sachandr ship $ */
/* Purpose: This package contains the cover routines used to create Multiple */
/*	    tax rate exemptions. The routines are called from the 10SC forms */
/*	    RAXSTDTE(Item Tax Rate Exceptions) and RAXSUDTE(Tax Exemptions). */

/*----------------------------------------------------------------------------*
 |   PRIVATE GLOBAL VARIABLES     					      |
 *----------------------------------------------------------------------------*/
  pg_Date_Format	CONSTANT VARCHAR2(20) := 'DD-MM-RR HH24:MI:SS';
  --PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('TAX_DEBUG_FLAG'), 'N');
  PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

/*----------------------------------------------------------------------------*
 |   PUBLIC FUNCTIONS/PROCEDURES  					      |
 *----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*
 | PROCEDURE                                                                  |
 |    exceptions                           			      	      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This procedure will update exceptions given an Item Range. Item Range   |
 |    could be specified using Item Flex Range, Item Category Set, Category   |
 |    and Item type.An existing exception must have the same effectivity date |
 |    to be updated.                                                          |
 |									      |
 |    Since the PL/SQL concurrent pgm parameters have to be of type VARCHAR2, |
 |    this procedure will also convert the parameters to the appropriate      |
 |    datatype before invoking the entity handler in ARP_MULTI_EXEMPTIONS.    |
 |									      |
 | PARAMETERS                                                                 |
 |   INPUT                                                 		      |
 |      p_Conc_Req_Flag		VARCHAR2 -- 'Y' if called thru a conc pgm.    |
 |      p_Insert_Flag  		VARCHAR2 -- 'Y' if INSERT, 'N' if UPDATE.     |
 |      Item Flex Range, Item Category Set, Item Category, Item Type and      |
 |      Old/New Exception details.                         		      |
 |   OUTPUT                                                		      |
 |      Errbuf          	VARCHAR2 -- Conc Pgm Error mesgs.             |
 |      RetCode         	VARCHAR2 -- Conc Pgm Error Code.              |
 |                                          0 - Success, 2 - Failure. 	      |
 |                                                                            |
 |      Note: The Date parameters format must be as in pg_Date_Format.	      |
 |                                                                            |
 | HISTORY                                                                    |
 |    28-Feb-96  Mahesh Sabapathy  Created.                                   |
 *----------------------------------------------------------------------------*/
  PROCEDURE exceptions (
			Errbuf			OUT NOCOPY	VARCHAR2,
			Retcode			OUT NOCOPY	VARCHAR2,
			p_Conc_Req_Flag			VARCHAR2 default 'Y',
			p_Insert_Flag			VARCHAR2 default 'Y',
			p_Org_ID			VARCHAR2,
			p_Item_Segment1_Low		VARCHAR2,
			p_Item_Segment1_High		VARCHAR2,
			p_Item_Segment2_Low		VARCHAR2,
			p_Item_Segment2_High		VARCHAR2,
			p_Item_Segment3_Low		VARCHAR2,
			p_Item_Segment3_High		VARCHAR2,
			p_Item_Segment4_Low		VARCHAR2,
			p_Item_Segment4_High		VARCHAR2,
			p_Item_Segment5_Low		VARCHAR2,
			p_Item_Segment5_High		VARCHAR2,
			p_Item_Segment6_Low		VARCHAR2,
			p_Item_Segment6_High		VARCHAR2,
			p_Item_Segment7_Low		VARCHAR2,
			p_Item_Segment7_High		VARCHAR2,
			p_Item_Segment8_Low		VARCHAR2,
			p_Item_Segment8_High		VARCHAR2,
			p_Item_Segment9_Low		VARCHAR2,
			p_Item_Segment9_High		VARCHAR2,
			p_Item_Segment10_Low		VARCHAR2,
			p_Item_Segment10_High		VARCHAR2,
			p_Category_Set_Id		VARCHAR2,
			p_Category_Id			VARCHAR2,
			p_Item_Type			VARCHAR2,
	                p_Old_Location_Id_Segment_1  	VARCHAR2,
	                p_Old_Location_Id_Segment_2     VARCHAR2,
	                p_Old_Location_Id_Segment_3     VARCHAR2,
	                p_Old_Location_Id_Segment_4     VARCHAR2,
	                p_Old_Location_Id_Segment_5     VARCHAR2,
	                p_Old_Location_Id_Segment_6     VARCHAR2,
	                p_Old_Location_Id_Segment_7     VARCHAR2,
	                p_Old_Location_Id_Segment_8     VARCHAR2,
	                p_Old_Location_Id_Segment_9     VARCHAR2,
	                p_Old_Location_Id_Segment_10    VARCHAR2,
	                p_Old_Start_Date                VARCHAR2,
	                p_Old_End_Date                  VARCHAR2,
                       	p_Creation_Date                 VARCHAR2,
                       	p_Created_By                    VARCHAR2,
	                p_Last_Update_Login             VARCHAR2,
	                p_Last_Updated_By               VARCHAR2,
	                p_Last_Update_Date              VARCHAR2,
	                p_Location_Context              VARCHAR2,
	                p_Location_Id_Segment_1         VARCHAR2,
	                p_Location_Id_Segment_2         VARCHAR2,
	                p_Location_Id_Segment_3         VARCHAR2,
	                p_Location_Id_Segment_4         VARCHAR2,
	                p_Location_Id_Segment_5         VARCHAR2,
	                p_Location_Id_Segment_6         VARCHAR2,
	                p_Location_Id_Segment_7         VARCHAR2,
	                p_Location_Id_Segment_8         VARCHAR2,
	                p_Location_Id_Segment_9         VARCHAR2,
	                p_Location_Id_Segment_10        VARCHAR2,
	                p_Rate_Context                  VARCHAR2,
	                p_Location1_Rate                VARCHAR2,
	                p_Location2_Rate                VARCHAR2,
	                p_Location3_Rate                VARCHAR2,
	                p_Location4_Rate                VARCHAR2,
	                p_Location5_Rate                VARCHAR2,
	                p_Location6_Rate                VARCHAR2,
	                p_Location7_Rate                VARCHAR2,
	                p_Location8_Rate                VARCHAR2,
	                p_Location9_Rate                VARCHAR2,
	                p_Location10_Rate               VARCHAR2,
	                p_Start_Date                    VARCHAR2,
	                p_End_Date                      VARCHAR2,
	                p_Reason_Code                   VARCHAR2,
	                p_Attribute_Category            VARCHAR2,
	                p_Attribute1                    VARCHAR2,
	                p_Attribute2                    VARCHAR2,
	                p_Attribute3                    VARCHAR2,
	                p_Attribute4                    VARCHAR2,
	                p_Attribute5                    VARCHAR2,
	                p_Attribute6                    VARCHAR2,
	                p_Attribute7                    VARCHAR2,
	                p_Attribute8                    VARCHAR2,
	                p_Attribute9                    VARCHAR2,
	                p_Attribute10                   VARCHAR2,
	                p_Attribute11                   VARCHAR2,
	                p_Attribute12                   VARCHAR2,
	                p_Attribute13                   VARCHAR2,
	                p_Attribute14                   VARCHAR2,
	                p_Attribute15                   VARCHAR2
		) IS
  BEGIN
    null;
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END exceptions;

/*----------------------------------------------------------------------------*
 | PROCEDURE                                                                  |
 |    exemptions                           			      	      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This procedure will update exemptions given an Item Range. Item Range   |
 |    could be specified using Item Flex Range, Item Category Set, Category   |
 |    and Item type.An existing exemption must have the same effectivity date |
 |    to be updated.                                                          |
 |									      |
 |    Since the PL/SQL concurrent pgm parameters have to be of type VARCHAR2, |
 |    this procedure will also convert the parameters to the appropriate      |
 |    datatype before invoking the entity handler in ARP_MULTI_EXEMPTIONS.    |
 |									      |
 | PARAMETERS                                                                 |
 |   INPUT                                                 		      |
 |      p_Conc_Req_Flag		VARCHAR2 -- 'Y' if called thru a conc pgm.    |
 |      p_Insert_Flag  		VARCHAR2 -- 'Y' if INSERT, 'N' if UPDATE.     |
 |      Item Flex Range, Item Category Set, Item Category, Item Type and      |
 |      Old/New Exemption details.                         		      |
 |   OUTPUT                                                		      |
 |      Errbuf          	VARCHAR2 -- Conc Pgm Error mesgs.             |
 |      RetCode         	VARCHAR2 -- Conc Pgm Error Code.              |
 |                                          0 - Success, 2 - Failure. 	      |
 |                                                                            |
 | HISTORY                                                                    |
 |    20-Mar-96  Mahesh Sabapathy  Created.                                   |
 |   	09-Mar-99   Nilesh Patel  - added parameters exempt_context and       |
 |                    exempt percent1-10 in procedure exemptions              |
 *----------------------------------------------------------------------------*/
  PROCEDURE exemptions (
			Errbuf			OUT NOCOPY	VARCHAR2,
			Retcode			OUT NOCOPY	VARCHAR2,
			p_Conc_Req_Flag			VARCHAR2 default 'Y',
			p_Insert_Flag			VARCHAR2 default 'Y',
			p_Org_ID			VARCHAR2,
		       	p_Item_Segment1_Low		VARCHAR2,
		       	p_Item_Segment1_High		VARCHAR2,
		       	p_Item_Segment2_Low		VARCHAR2,
		       	p_Item_Segment2_High		VARCHAR2,
		       	p_Item_Segment3_Low		VARCHAR2,
		       	p_Item_Segment3_High		VARCHAR2,
		       	p_Item_Segment4_Low		VARCHAR2,
		       	p_Item_Segment4_High		VARCHAR2,
		       	p_Item_Segment5_Low		VARCHAR2,
		       	p_Item_Segment5_High		VARCHAR2,
		       	p_Item_Segment6_Low		VARCHAR2,
		       	p_Item_Segment6_High		VARCHAR2,
		       	p_Item_Segment7_Low		VARCHAR2,
		       	p_Item_Segment7_High		VARCHAR2,
		       	p_Item_Segment8_Low		VARCHAR2,
		       	p_Item_Segment8_High		VARCHAR2,
		       	p_Item_Segment9_Low		VARCHAR2,
		       	p_Item_Segment9_High		VARCHAR2,
		       	p_Item_Segment10_Low		VARCHAR2,
		       	p_Item_Segment10_High		VARCHAR2,
		       	p_Category_Set_Id   		VARCHAR2,
			p_Category_Id   		VARCHAR2,
			p_Item_Type   			VARCHAR2,
                       	p_Old_Tax_Code    		VARCHAR2,
                       	p_Old_Start_Date                VARCHAR2,
                       	p_Old_End_Date                  VARCHAR2,
			p_Last_updated_by		VARCHAR2,
			p_Last_update_date		VARCHAR2,
			p_Created_by			VARCHAR2,
			p_Creation_date			VARCHAR2,
			p_Status			VARCHAR2,
			p_Customer_id			VARCHAR2,
			p_Site_use_id			VARCHAR2,
			p_Exemption_type		VARCHAR2,
			p_Tax_code			VARCHAR2,
			p_Percent_exempt		VARCHAR2,
			p_Customer_exemption_number	VARCHAR2,
			p_Start_date			VARCHAR2,
			p_End_date			VARCHAR2,
			p_Location_context		VARCHAR2,
			p_Location_id_segment_1		VARCHAR2,
			p_Location_id_segment_2		VARCHAR2,
			p_Location_id_segment_3		VARCHAR2,
			p_Location_id_segment_4		VARCHAR2,
			p_Location_id_segment_5		VARCHAR2,
			p_Location_id_segment_6		VARCHAR2,
			p_Location_id_segment_7		VARCHAR2,
			p_Location_id_segment_8		VARCHAR2,
			p_Location_id_segment_9		VARCHAR2,
			p_Location_id_segment_10	VARCHAR2,
			p_Attribute_category		VARCHAR2,
			p_Attribute1			VARCHAR2,
			p_Attribute2			VARCHAR2,
			p_Attribute3			VARCHAR2,
			p_Attribute4			VARCHAR2,
			p_Attribute5			VARCHAR2,
			p_Attribute6			VARCHAR2,
			p_Attribute7			VARCHAR2,
			p_Attribute8			VARCHAR2,
			p_Attribute9			VARCHAR2,
			p_Attribute10			VARCHAR2,
			p_Attribute11			VARCHAR2,
			p_Attribute12			VARCHAR2,
			p_Attribute13			VARCHAR2,
			p_Attribute14			VARCHAR2,
			p_Attribute15			VARCHAR2,
			p_In_use_flag			VARCHAR2,
			p_Program_id			VARCHAR2,
			p_Program_update_date		VARCHAR2,
			p_Request_id			VARCHAR2,
			p_Program_application_id	VARCHAR2,
			p_Reason_code			VARCHAR2,
                        p_Exempt_Context                VARCHAR2,
                        p_Exempt_Percent1               VARCHAR2,
                        p_Exempt_Percent2               VARCHAR2,
                        p_Exempt_Percent3               VARCHAR2,
                        p_Exempt_Percent4               VARCHAR2,
                        p_Exempt_Percent5               VARCHAR2,
                        p_Exempt_Percent6               VARCHAR2,
                        p_Exempt_Percent7               VARCHAR2,
                        p_Exempt_Percent8               VARCHAR2,
                        p_Exempt_Percent9               VARCHAR2,
                        p_Exempt_Percent10              VARCHAR2


		) IS


  BEGIN

    null;
  EXCEPTION
    WHEN OTHERS THEN
      null;
  END exemptions;


END ARP_MUL_EXEMPT_COV;

/
