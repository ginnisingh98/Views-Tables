--------------------------------------------------------
--  DDL for Package ARP_MULTI_COMMON_COVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_MULTI_COMMON_COVER" AUTHID CURRENT_USER as
/*  $Header: ARXEMCCS.pls 115.1 2002/11/15 04:15:30 anukumar ship $  */
/* Purpose: This package provides the support functions used to create        */
/*          Multiple tax rate exceptions/exemptions given a range of items.   */
/*          The package is used by the 10SC forms RAXSTDTE and RAXSUDTE.      */

/*----------------------------------------------------------------------------*
 | PROCEDURE                                                                  |
 |    get_exceptions_count                           			      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This procedure will provide the count of Items selected and the # of    |
 |    exceptions that will be affected by the transaction, given and Item     |
 |    Flex Range, Item Category Set, Item Category, Item Type, Exemption      |
 |    Location and Effective dates.                                           |
 |									      |
 | PARAMETERS                                                                 |
 |      p_Item Count	   OUT NOCOPY  NUMBER	-- Item Count            	      |
 |      p_Exemption_Count  OUT NOCOPY  NUMBER  -- Exemption Count          	      |
 |      p_Trans_Type       IN   NUMBER  -- Transaction Type,I(insert)/U(pdate)|
 |      p_Org Id           IN   NUMBER  -- Organization Id                    |
 |      Item Flex Range, Item Category Set, Item Category, Item Type and      |
 |      Exemption Location and Effective dates.            		      |
 |                                                                            |
 | HISTORY                                                                    |
 |    19-Mar-96  Mahesh Sabapathy  Created.                                   |
 *----------------------------------------------------------------------------*/
  PROCEDURE get_exceptions_count( p_Item_Count	OUT NOCOPY	NUMBER,
			p_Exception_Count	OUT NOCOPY	NUMBER,
			p_Trans_Type			VARCHAR2,
			p_Org_ID			NUMBER,
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
		       	p_Category_Set_Id		NUMBER,
		       	p_Category_Id			NUMBER,
		       	p_Item_Type			VARCHAR2,
                        p_Location_Id_Segment_1         NUMBER,
                        p_Location_Id_Segment_2         NUMBER,
                        p_Location_Id_Segment_3         NUMBER,
                        p_Location_Id_Segment_4         NUMBER,
                        p_Location_Id_Segment_5         NUMBER,
                        p_Location_Id_Segment_6         NUMBER,
                        p_Location_Id_Segment_7         NUMBER,
                        p_Location_Id_Segment_8         NUMBER,
                        p_Location_Id_Segment_9         NUMBER,
                        p_Location_Id_Segment_10        NUMBER,
                        p_Start_Date          		DATE,
                        p_End_Date         		DATE
			);

/*----------------------------------------------------------------------------*
 | PROCEDURE                                                                  |
 |    get_exemptions_count                           			      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |    This procedure will provide the count of Items selected and the # of    |
 |    exemptions that will be affected by the transaction, given and Item     |
 |    Flex Range, Item Category Set, Item Category, Item Type, Exemption      |
 |    Location and Effective dates.                                           |
 |									      |
 | PARAMETERS                                                                 |
 |      p_Item Count	   OUT NOCOPY  NUMBER	-- Item Count            	      |
 |      p_Exemption_Count  OUT NOCOPY  NUMBER  -- Exemption Count          	      |
 |      p_Trans_Type       IN   NUMBER  -- Transaction Type,I(insert)/U(pdate)|
 |      p_Org Id           IN   NUMBER  -- Organization Id                    |
 |      Item Flex Range, Item Category Set, Item Category, Item Type ,        |
 |      Exemption Tax Code and Effective dates.            		      |
 |                                                                            |
 | HISTORY                                                                    |
 |    19-Mar-96  Mahesh Sabapathy  Created.                                   |
 *----------------------------------------------------------------------------*/
  PROCEDURE get_exemptions_count( p_Item_Count	OUT NOCOPY	NUMBER,
			p_Exemption_Count	OUT NOCOPY	NUMBER,
			p_Trans_Type			VARCHAR2,
			p_Org_ID			NUMBER,
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
		       	p_Category_Set_Id		NUMBER,
		       	p_Category_Id			NUMBER,
		       	p_Item_Type			VARCHAR2,
                        p_Tax_Code        		VARCHAR2,
                        p_Start_Date          		DATE,
                        p_End_Date         		DATE
		);

END ARP_MULTI_COMMON_COVER;

 

/
