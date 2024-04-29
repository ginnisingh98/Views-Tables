--------------------------------------------------------
--  DDL for Package INV_TRANSACTION_FLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_TRANSACTION_FLOW_PVT" AUTHID CURRENT_USER AS
/* $Header: INVICTFS.pls 115.5 2003/10/09 12:23:32 viberry noship $ */

TYPE TABLE_OF_NUMBERS IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;


TYPE TRX_FLOW_LINE_REC IS RECORD (
                                HEADER_ID               NUMBER,
                                LINE_NUMBER             NUMBER,
                                FROM_ORG_ID             NUMBER,
                                FROM_ORGANIZATION_ID    NUMBER,
                                TO_ORG_ID               NUMBER,
                                TO_ORGANIZATION_ID      NUMBER,
                                ATTRIBUTE_CATEGORY      VARCHAR2(30),
                                ATTRIBUTE1              VARCHAR2(150),
                                ATTRIBUTE2              VARCHAR2(150),
                                ATTRIBUTE3              VARCHAR2(150),
                                ATTRIBUTE4              VARCHAR2(150),
                                ATTRIBUTE5              VARCHAR2(150),
                                ATTRIBUTE6              VARCHAR2(150),
                                ATTRIBUTE7              VARCHAR2(150),
                                ATTRIBUTE8              VARCHAR2(150),
                                ATTRIBUTE9              VARCHAR2(150),
                                ATTRIBUTE10             VARCHAR2(150),
                                ATTRIBUTE11             VARCHAR2(150),
                                ATTRIBUTE12             VARCHAR2(150),
                                ATTRIBUTE13             VARCHAR2(150),
                                ATTRIBUTE14             VARCHAR2(150),
                                ATTRIBUTE15             VARCHAR2(150)
                                 );
TYPE TRX_FLOW_LINES_TAB IS TABLE OF TRX_FLOW_LINE_REC INDEX BY BINARY_INTEGER;


/** Inserts the data into thr header table:mtl_transaction_flow_header.<br>
* @param p_header_id                       unique identifier for header table
* @param p_start_org_id                    organization_id of the start operating unit
* @param p_end_org_id                      organization_id of the end operating unit
* @param p_last_update_date                Who column
* @param p_last_updated_by                 Who Column
* @param p_creation_date                   Who Column
* @param p_created_by                      Who Column
* @param p_last update login               Who Column
* @param p_flow_type                       Indicated whether flow type is shipping or procuring
* @param p_organization_id                 The ship From/To Organization Id
* @param p_qualifier_code                  This indicates the qualifier code for the flow type.At present it can be null or Category
* @param p_qualifier_value_id              This is the value of the qualifier code if selected as Category
* @param p_asset_item_pricing_option       This gives the Asset pricing option as either PO or Transfer if flow type is procuring
* @param p_expense_item_pricing_option     This gives the Expense pricing option as either PO or Transfer if flow type is procuring
* @param p_start_date                      The start date with time when the  trx flow becomes active
* @param p_end_date                        The end date with time when the  trx flow ceases to be active
* @param p_new_accounting_flag             Indicates whether the user is going for the new accounting or old accounting.
                                          <br>If flow is procuring then it should be new.
                                           <br> FOR shipping if number of lines greater than 1 then new
* @param p_attribute_category              Attribute context column
* @param p_attribute1                      Attribute column
* @param p_attribute2                      Attribute column
* @param p_attribute3                      Attribute column
* @param p_attribute4                      Attribute column
* @param p_attribute5                      Attribute column
* @param p_attribute6                      Attribute column
* @param p_attribute7                      Attribute column
* @param p_attribute8                      Attribute column
* @param p_attribute9                      Attribute column
* @param p_attribute10                     Attribute column
* @param p_attribute11                     Attribute column
* @param p_attribute12                     Attribute column
* @param p_attribute13                     Attribute column
* @param p_attribute14                     Attribute column
* @param p_attribute15                     Attribute column
*/
 PROCEDURE Insert_Trx_Flow_Header (
                                   P_Header_Id                          IN              NUMBER,
                                   P_Start_Org_Id                       IN              NUMBER,
                                   P_End_Org_Id                         IN              NUMBER,
                                   P_Last_Update_Date                   IN              DATE,
                                   P_Last_Updated_By                    IN              NUMBER,
                                   P_Creation_Date                      IN              DATE,
                                   P_Created_By                         IN              NUMBER,
                                   P_Last_Update_Login                  IN              NUMBER,
                                   P_Flow_Type                          IN              NUMBER,
                                   P_Organization_Id                    IN              NUMBER,
                                   P_Qualifier_Code                     IN              NUMBER,
                                   P_Qualifier_Value_Id                 IN              NUMBER,
                                   P_Asset_Item_Pricing_Option          IN              NUMBER,
                                   P_Expense_Item_Pricing_Option        IN              NUMBER,
                                   P_Start_Date                         IN              DATE,
                                   P_End_Date                           IN              DATE,
                                   P_New_Accounting_Flag                IN              VARCHAR2,
                                   P_Attribute_Category                 IN              VARCHAR2,
                                   P_Attribute1                         IN              VARCHAR2,
                                   P_Attribute2                         IN              VARCHAR2,
                                   P_Attribute3                         IN              VARCHAR2,
                                   P_Attribute4                         IN              VARCHAR2,
                                   P_Attribute5                         IN              VARCHAR2,
                                   P_Attribute6                         IN              VARCHAR2,
                                   P_Attribute7                         IN              VARCHAR2,
                                   P_Attribute8                         IN              VARCHAR2,
                                   P_Attribute9                         IN              VARCHAR2,
                                   P_Attribute10                        IN              VARCHAR2,
                                   P_Attribute11                        IN              VARCHAR2,
                                   P_Attribute12                        IN              VARCHAR2,
                                   P_Attribute13                        IN              VARCHAR2,
                                   P_Attribute14                        IN              VARCHAR2,
                                   P_Attribute15                        IN              VARCHAR2
                                 );




/**   This is a Table Handler for the header block.<br>
       <br>It will lock a row for update for the mtl_transaction_flow_headers.<br>
* @param x_row_id                          rowid for the table
* @param p_header_id                       unique identifier for header table
* @param p_start_org_id                    organization_id of the start operating unit
* @param p_end_org_id                      organization_id of the end operating unit
* @param p_last_update_date                Who column
* @param p_last_updated_by                 Who Column
* @param p_creation_date                   Who Column
* @param p_created_by                      Who Column
* @param p_last update login               Who Column
* @param p_flow_type                       Indicated whether flow type is shipping or procuring
* @param p_organization_id                 The ship From/To Organization Id
* @param p_qualifier_code                  This indicates the qualifier code for the flow type.At present it can be null or Category
* @param p_qualifier_value_id              This is the value of the qualifier code if selected as Category
* @param p_asset_item_pricing_option       This gives the Asset pricing option as either PO or Transfer if flow type is procuring
* @param p_expense_item_pricing_option     This gives the Expense pricing option as either PO or Transfer if flow type is procuring
* @param p_start_date                      The start date with time when the  trx flow becomes active
* @param p_end_date                        The end date with time when the  trx flow ceases to be active
* @param p_new_accounting_flag             Indicates whether the user is going for the new accounting or old accounting.
                                           <br>If flow is procuring then it should be new.
                                           <br> FOR shipping if number of lines greater than 1 then new
* @param p_attribute_category              Attribute context column
* @param p_attribute1                      Attribute column
* @param p_attribute2                      Attribute column
* @param p_attribute3                      Attribute column
* @param p_attribute4                      Attribute column
* @param p_attribute5                      Attribute column
* @param p_attribute6                      Attribute column
* @param p_attribute7                      Attribute column
* @param p_attribute8                      Attribute column
* @param p_attribute9                      Attribute column
* @param p_attribute10                     Attribute column
* @param p_attribute11                     Attribute column
* @param p_attribute12                     Attribute column
* @param p_attribute13                     Attribute column
* @param p_attribute14                     Attribute column
* @param p_attribute15                     Attribute column
*/

  PROCEDURE Lock_Trx_Flow_Header (
                                   P_Header_Id                    IN            NUMBER,
                                   P_Start_Org_Id                 IN            NUMBER,
                                   P_End_Org_Id                   IN            NUMBER,
                                   P_Last_Update_Date             IN            DATE,
                                   P_Last_Updated_By              IN            NUMBER,
                                   P_Creation_Date                IN            DATE,
                                   P_Created_By                   IN            NUMBER,
                                   P_Last_Update_Login            IN            NUMBER,
                                   P_Flow_Type                    IN            NUMBER,
                                   P_Organization_Id              IN            NUMBER,
                                   P_Qualifier_Code               IN            NUMBER,
                                   P_Qualifier_Value_Id           IN            NUMBER,
                                   P_Asset_Item_Pricing_Option    IN            NUMBER,
                                   P_Expense_Item_Pricing_Option  IN            NUMBER,
                                   P_Start_Date                   IN            DATE,
                                   P_End_Date                     IN            DATE,
                                   P_New_Accounting_Flag          IN            VARCHAR2,
                                   P_Attribute_Category           IN            VARCHAR2,
                                   P_Attribute1                   IN            VARCHAR2,
                                   P_Attribute2                   IN            VARCHAR2,
                                   P_Attribute3                   IN            VARCHAR2,
                                   P_Attribute4                   IN            VARCHAR2,
                                   P_Attribute5                   IN            VARCHAR2,
                                   P_Attribute6                   IN            VARCHAR2,
                                   P_Attribute7                   IN            VARCHAR2,
                                   P_Attribute8                   IN            VARCHAR2,
                                   P_Attribute9                   IN            VARCHAR2,
                                   P_Attribute10                  IN            VARCHAR2,
                                   P_Attribute11                  IN            VARCHAR2,
                                   P_Attribute12                  IN            VARCHAR2,
                                   P_Attribute13                  IN            VARCHAR2,
                                   P_Attribute14                  IN            VARCHAR2,
                                   P_Attribute15                  IN            VARCHAR2
                                  );

/**   This is a Table Handler for the header block.<br>
       <br>It is for update of the mtl_transaction_flow_headers.only start,end dates and
       <br> dff columns are updateable<br>
* @param p_header_id                       unique identifier for header table
* @param p_start_date                      The start date with time when the  trx flow becomes active
* @param p_end_date                        The end date with time when the  trx flow ceases to be active
* @param p_last_update_date                Who column
* @param p_last_updated_by                 Who Column
* @param p_last update login               Who Column
* @param p_attribute_category              Attribute context column
* @param p_attribute1                      Attribute column
* @param p_attribute2                      Attribute column
* @param p_attribute3                      Attribute column
* @param p_attribute4                      Attribute column
* @param p_attribute5                      Attribute column
* @param p_attribute6                      Attribute column
* @param p_attribute7                      Attribute column
* @param p_attribute8                      Attribute column
* @param p_attribute9                      Attribute column
* @param p_attribute10                     Attribute column
* @param p_attribute11                     Attribute column
* @param p_attribute12                     Attribute column
* @param p_attribute13                     Attribute column
* @param p_attribute14                     Attribute column
* @param p_attribute15                     Attribute column
*/

PROCEDURE Update_Trx_Flow_Header(
                                 P_Header_Id                   IN          NUMBER,
                                 P_Last_Update_Date            IN          DATE,
                                 P_Last_Updated_By             IN          NUMBER,
                                 P_Last_Update_Login           IN          NUMBER,
                                 P_Start_Date                  IN          DATE,
                                 P_End_Date                    IN          DATE,
                                 P_Attribute_Category          IN          VARCHAR2,
                                 P_Attribute1                  IN          VARCHAR2,
                                 P_Attribute2                  IN          VARCHAR2,
                                 P_Attribute3                  IN          VARCHAR2,
                                 P_Attribute4                  IN          VARCHAR2,
                                 P_Attribute5                  IN          VARCHAR2,
                                 P_Attribute6                  IN          VARCHAR2,
                                 P_Attribute7                  IN          VARCHAR2,
                                 P_Attribute8                  IN          VARCHAR2,
                                 P_Attribute9                  IN          VARCHAR2,
                                 P_Attribute10                 IN          VARCHAR2,
                                 P_Attribute11                 IN          VARCHAR2,
                                 P_Attribute12                 IN          VARCHAR2,
                                 P_Attribute13                 IN          VARCHAR2,
                                 P_Attribute14                 IN          VARCHAR2,
                                 P_Attribute15                 IN          VARCHAR2
                                );

/**  This is a Table Handler for the lines block
     <br>It will insert a row into the mtl_transaction_flow_lines.<br>
* @param p_header_id                       identifier for lines table that gives the join condition for the
                                           <br>lines table to join to header table
* @param p_line_number                     The line number
* @param p_from_org_id                     Organization id for the from operating unit
* @param p_from_organization_id            Organization Id for the from organization that is under the from operating unit.
* @param p_to_org_id                       Organization id for the to operating unit
* @param p_to_organization_id              Organization Id for the to organization that is under the to operating unit.
* @param p_last_update_date                Who column
* @param p_last_updated_by                 Who Column
* @param p_creation_date                   Who Column
* @param p_created_by                      Who Column
* @param p_last update login               Who Column
* @param p_attribute_category              Attribute context column
* @param p_attribute1                      Attribute column
* @param p_attribute2                      Attribute column
* @param p_attribute3                      Attribute column
* @param p_attribute4                      Attribute column
* @param p_attribute5                      Attribute column
* @param p_attribute6                      Attribute column
* @param p_attribute7                      Attribute column
* @param p_attribute8                      Attribute column
* @param p_attribute9                      Attribute column
* @param p_attribute10                     Attribute column
* @param p_attribute11                     Attribute column
* @param p_attribute12                     Attribute column
* @param p_attribute13                     Attribute column
* @param p_attribute14                     Attribute column
* @param p_attribute15                     Attribute column
*/
PROCEDURE Insert_Trx_Flow_Lines (
                                   P_Header_Id                IN                NUMBER,
                                   P_Line_Number              IN                NUMBER,
                                   P_From_Org_Id              IN                NUMBER,
                                   P_From_Organization_Id     IN                NUMBER,
                                   P_To_Org_Id                IN                NUMBER,
                                   P_To_Organization_Id       IN                NUMBER,
                                   P_Last_Updated_By          IN                NUMBER,
                                   P_Last_Update_Date         IN                DATE,
                                   P_Creation_Date            IN                DATE,
                                   P_Created_By               IN                NUMBER,
                                   P_Last_Update_Login        IN                NUMBER,
                                   P_Attribute_Category       IN                VARCHAR2,
                                   P_Attribute1               IN                VARCHAR2,
                                   P_Attribute2               IN                VARCHAR2,
                                   P_Attribute3               IN                VARCHAR2,
                                   P_Attribute4               IN                VARCHAR2,
                                   P_Attribute5               IN                VARCHAR2,
                                   P_Attribute6               IN                VARCHAR2,
                                   P_Attribute7               IN                VARCHAR2,
                                   P_Attribute8               IN                VARCHAR2,
                                   P_Attribute9               IN                VARCHAR2,
                                   P_Attribute10              IN                VARCHAR2,
                                   P_Attribute11              IN                VARCHAR2,
                                   P_Attribute12              IN                VARCHAR2,
                                   P_Attribute13              IN                VARCHAR2,
                                   P_Attribute14              IN                VARCHAR2,
                                   P_Attribute15              IN                VARCHAR2
                                 );


/**  This is a Table Handler for the lines block
     <br>It will lock a row for the mtl_transaction_flow_lines.<br>
* @param x_row_id                          rowid for the table
* @param p_header_id                       identifier for lines table that gives the join condition for the
                                           <br>lines table to join to header table
* @param p_line_number                     The line number
* @param p_from_org_id                     Organization id for the from operating unit
* @param p_from_organization_id            Organization Id for the from organization that is under the from operating unit.
* @param p_to_org_id                       Organization id for the to operating unit
* @param p_to_organization_id              Organization Id for the to organization that is under the to operating unit.
* @param p_last_update_date                Who column
* @param p_last_updated_by                 Who Column
* @param p_creation_date                   Who Column
* @param p_created_by                      Who Column
* @param p_last update login               Who Column
* @param p_attribute_category              Attribute context column
* @param p_attribute1                      Attribute column
* @param p_attribute2                      Attribute column
* @param p_attribute3                      Attribute column
* @param p_attribute4                      Attribute column
* @param p_attribute5                      Attribute column
* @param p_attribute6                      Attribute column
* @param p_attribute7                      Attribute column
* @param p_attribute8                      Attribute column
* @param p_attribute9                      Attribute column
* @param p_attribute10                     Attribute column
* @param p_attribute11                     Attribute column
* @param p_attribute12                     Attribute column
* @param p_attribute13                     Attribute column
* @param p_attribute14                     Attribute column
* @param p_attribute15                     Attribute column
*/

PROCEDURE Lock_Trx_Flow_Lines  (
                                   P_Header_Id               IN            NUMBER,
                                   P_Line_Number             IN            NUMBER,
                                   P_From_Org_Id             IN            NUMBER,
                                   P_From_Organization_Id    IN            NUMBER,
                                   P_To_Org_Id               IN            NUMBER,
                                   P_To_Organization_Id      IN            NUMBER,
                                   P_Last_Updated_By         IN            NUMBER,
                                   P_Last_Update_Date        IN            DATE,
                                   P_Creation_Date           IN            DATE,
                                   P_Created_By              IN            NUMBER,
                                   P_Last_Update_Login       IN            NUMBER,
                                   P_Attribute_Category      IN            VARCHAR2,
                                   P_Attribute1              IN            VARCHAR2,
                                   P_Attribute2              IN            VARCHAR2,
                                   P_Attribute3              IN            VARCHAR2,
                                   P_Attribute4              IN            VARCHAR2,
                                   P_Attribute5              IN            VARCHAR2,
                                   P_Attribute6              IN            VARCHAR2,
                                   P_Attribute7              IN            VARCHAR2,
                                   P_Attribute8              IN            VARCHAR2,
                                   P_Attribute9              IN            VARCHAR2,
                                   P_Attribute10             IN            VARCHAR2,
                                   P_Attribute11             IN            VARCHAR2,
                                   P_Attribute12             IN            VARCHAR2,
                                   P_Attribute13             IN            VARCHAR2,
                                   P_Attribute14             IN            VARCHAR2,
                                   P_Attribute15             IN            VARCHAR2
                               );


/**  This is a Table Handler for the lines block
     <br>It is for the update of mtl_transaction_flow_lines.Only Dff columns are updateable <br>
* @param p_header_id                       identifier for lines table that gives the join condition for the
                                           <br>lines table to join to header table
* @param p_line_number                     The line number
* @param p_last_update_date                Who column
* @param p_last_updated_by                 Who Column
* @param p_last update login               Who Column
* @param p_attribute_category              Attribute context column
* @param p_attribute1                      Attribute column
* @param p_attribute2                      Attribute column
* @param p_attribute3                      Attribute column
* @param p_attribute4                      Attribute column
* @param p_attribute5                      Attribute column
* @param p_attribute6                      Attribute column
* @param p_attribute7                      Attribute column
* @param p_attribute8                      Attribute column
* @param p_attribute9                      Attribute column
* @param p_attribute10                     Attribute column
* @param p_attribute11                     Attribute column
* @param p_attribute12                     Attribute column
* @param p_attribute13                     Attribute column
* @param p_attribute14                     Attribute column
* @param p_attribute15                     Attribute column
*/

PROCEDURE Update_Trx_Flow_Lines (
                                 P_Header_Id                   IN          NUMBER,
				 P_Line_Number                 IN          NUMBER,
                                 P_Last_Update_Date            IN          DATE,
                                 P_Last_Updated_By             IN          NUMBER,
                                 P_Last_Update_Login           IN          NUMBER,
                                 P_Attribute_Category          IN          VARCHAR2,
                                 P_Attribute1                  IN          VARCHAR2,
                                 P_Attribute2                  IN          VARCHAR2,
                                 P_Attribute3                  IN          VARCHAR2,
                                 P_Attribute4                  IN          VARCHAR2,
                                 P_Attribute5                  IN          VARCHAR2,
                                 P_Attribute6                  IN          VARCHAR2,
                                 P_Attribute7                  IN          VARCHAR2,
                                 P_Attribute8                  IN          VARCHAR2,
                                 P_Attribute9                  IN          VARCHAR2,
                                 P_Attribute10                 IN          VARCHAR2,
                                 P_Attribute11                 IN          VARCHAR2,
                                 P_Attribute12                 IN          VARCHAR2,
                                 P_Attribute13                 IN          VARCHAR2,
                                 P_Attribute14                 IN          VARCHAR2,
                                 P_Attribute15                 IN          VARCHAR2
                               ) ;


/** This functions takes the following parameters and checks if a
   <br> trx flow with same attributes alraedy exists.
   <br> Retuns true if the duplicate flow is not found. else returns false.
   <br> Here the idea is to prevent the user from creating a duplicate flow.<br>
* @param p_header_id                       header id of transaction flow to be validate
* @param p_start_org_id                    organization_id of the start operating unit
* @param p_end_org_id                      organization_id of the end operating unit
* @param p_flow_type                       Indicated whether flow type is shipping or procuring
* @param p_organization_id                 The ship From/To Organization Id
* @param p_qualifier_code                  This indicates the qualifier code for the flow type.At present it can be null or Category
* @param p_qualifier_value_id              This is the value of the qualifier code if selected as Category
* @param p_start_date                      The start date with time when the  trx flow becomes active
* @param p_end_date                        The end date with time when the  trx flow ceases to be active
*/
/*FUNCTION Validate_Header      (
                                 P_HEADER_ID            IN      NUMBER,
				 P_START_ORG_ID         IN      NUMBER,
                                 P_END_ORG_ID           IN      NUMBER,
                                 P_FLOW_TYPE            IN      NUMBER,
                                 P_ORGANIZATION_ID      IN      NUMBER,
                                 P_QUALIFIER_CODE       IN      NUMBER,
                                 P_QUALIFIER_VALUE_ID   IN      NUMBER,
                                 P_START_DATE           IN      DATE,
                                 P_END_DATE             IN      DATE

                              ) RETURN BOOLEAN;*/


/** This functions takes the following parameters and checks for the validity
   <br>of the start date. Following cases are checked as part of the validation.
   <br>1.The start date cannot be before the system date. For this the parameter
   <br> p_ref_date is passed . this p_ref_date carries the value of the sysdate.
   <br>The value of sysdate has to be stored  in this parameter because there
   <br>will always be some time lag beween the user entering the sysdate and
   <br>validation taking place.
   <br>2.It is seen that user is not able to create a overlapping  flow that is he
   <br> does not fill start date which lies between a present start date and end date.
   <br>3.Also if a transaction for a null end date and strat date prior to the current date
   <br>exists then the user should not be able to create the flow.
   <br>If all validation pass then it returns true else returns false <br>

* @param p_header_id                       unique identifier for header table
* @param p_start_org_id                    organization_id of the start operating unit
* @param p_end_org_id                      organization_id of the end operating unit
* @param p_flow_type                       Indicated whether flow type is shipping or procuring
* @param p_organization_id                 The ship From/To Organization Id
* @param p_qualifier_code                  This indicates the qualifier code for the flow type.At present it can be null or Category
* @param p_qualifier_value_id              This is the value of the qualifier code if selected as Category
* @param p_start_date                      The start date with time when the  trx flow becomes active
* @param p_ref_date                        The ref date which carries the system date
*/



FUNCTION Validate_Start_Date  (
                               P_HEADER_ID              IN      NUMBER,
                               P_START_ORG_ID           IN      NUMBER,
                               P_END_ORG_ID             IN      NUMBER,
                               P_FLOW_TYPE              IN      NUMBER,
                               P_ORGANIZATION_ID        IN      NUMBER,
                               P_QUALIFIER_CODE         IN      NUMBER,
                               P_QUALIFIER_VALUE_ID     IN      NUMBER,
                               P_START_DATE             IN      DATE,
                               P_REF_DATE               IN      DATE
                              ) RETURN BOOLEAN;



/** This functions takes the following parameters and checks the validity of the end date
   <br>It does the following checks.
   <br>1. Firstly it checks that the end date should not be less than the start date
   <br>2.It checks that the end date should not cause a overlapping transaction
   <br>that is it should not lie between the start date and end date of a existing transaction
   <br>3.If it is to be null then no other transaction with start date greater than the
   <br>  start date of the current flow should exist
   <br>4.If a Inter-company Transaction Flow with same attributes and NULL End Date exists
   <br>  Then new Inter-company Transaction Flow can only be defined for End Date less then
   <br>  the Start Date of existing Inter-company Transaction Flow.
   <br>5.This functions also checks if a
   <br> trx flow with same attributes alraedy exists.
   <br> Here the idea is to prevent the user from creating a duplicate flow.<br>

* @param p_header_id                       unique identifier for header table
* @param p_start_org_id                    organization_id of the start operating unit
* @param p_end_org_id                      organization_id of the end operating unit
* @param p_flow_type                       Indicated whether flow type is shipping or procuring
* @param p_organization_id                 The ship From/To Organization Id
* @param p_qualifier_code                  This indicates the qualifier code for the flow type.At present it can be null or Category
* @param p_qualifier_value_id              This is the value of the qualifier code if selected as Category
* @param p_start_date                      The start date with time when the  trx flow becomes active
* @param p_end_date                        The end date with time when the  trx flow ceases to be active
* @param p_ref_date                        The ref date with time when the  trx  is created or updated
*/


FUNCTION Validate_End_Date   (
                               P_HEADER_ID              IN      NUMBER,
                               P_START_ORG_ID           IN      NUMBER,
                               P_END_ORG_ID             IN      NUMBER,
                               P_FLOW_TYPE              IN      NUMBER,
                               P_ORGANIZATION_ID        IN      NUMBER,
                               P_QUALIFIER_CODE         IN      NUMBER,
                               P_QUALIFIER_VALUE_ID     IN      NUMBER,
                               P_START_DATE             IN      DATE,
                               P_END_DATE               IN      DATE,
                               P_REF_DATE               IN      DATE
                             )   RETURN BOOLEAN;



/** This procedure takes the  parameters and checks for the gap in the existing
<br> transaction flows with the same attributes. It has certain OUT parameters like
<br> x_gap_exists which is boolean in nature and its value is true if the gap exists and
<br> false when value is false. Besides this the other out parameters carry the start
<br> and the end dates of the first gap found. These values are used to default the dates
<br> when the user tries to enter a new header record. This is done to make sure that no gaps are
<br> created by the user. <br>

* @param x_start_date                      This is the out parameter giving the start Date for the first gap
* @param x_end_date                        This is the out parameter giving the end date of the first gap
* @param x_ref_date                        This is the out parameter which carries the system date
* @param x_gap_exists                      This is a boolean out parameter that retuns true if gap exists false otherwise
* @param x_return_status                   This is a out variable carrying the status whether future trxns with null
                                           <br> end date exist
* @param p_start_org_id                    organization_id of the start operating unit
* @param p_end_org_id                      organization_id of the end operating unit
* @param p_flow_type                       Indicated whether flow type is shipping or procuring
* @param p_organization_id                 The ship From/To Organization Id
* @param p_qualifier_code                  This indicates the qualifier code for the flow type.At present it can be null or Category
* @param p_qualifier_value_id              This is the value of the qualifier code if selected as Category
*/




 PROCEDURE Gap_Exists        ( X_START_DATE             OUT NOCOPY      DATE,
                               X_END_DATE               OUT NOCOPY      DATE,
                               X_REF_DATE               OUT NOCOPY      DATE,
                               X_GAP_EXISTS             OUT NOCOPY      BOOLEAN,
			       X_RETURN_STATUS          OUT NOCOPY      NUMBER,
                               P_START_ORG_ID           IN              NUMBER,
                               P_END_ORG_ID             IN              NUMBER,
                               P_FLOW_TYPE              IN              NUMBER,
                               P_ORGANIZATION_ID        IN              NUMBER,
                               P_QUALIFIER_CODE         IN              NUMBER,
                               P_QUALIFIER_VALUE_ID     IN              NUMBER
                             );



/** This procedure takes the  parameters and is used for defaultin the dates for the user when
    <br> the user creates a new transaction flow. This is done to avoid the gaps being craeted.
    <br> This procedure internally calls the Gap_Exists procedure to get the first gap and the
    <br> start and the end date.For different cases X_return code is used for which the
    <br> description is given as below.<br>

* @param x_start_date                      This is the out parameter giving the start Date for the first gap
* @param x_end_date                        This is the out parameter giving the end date of the first gap
* @param x_ref_date                        This is the out parameter which carries the system date
* @param x_return_code                     This is a out paramter which signifies different scenarios that are used for
                                           <br> defaulting the dates.When its value is 0 the
                                           <br> either no Trx flows with same attributes exists.So the start date is
                                           <br> defaulted with sysdate or no gaps exists for the existing Trx flows.
                                           <br> so the start date is defaulted to Max of end dates of existing transactions.
                                           <br> If vbalue is 1 then a existing transaction with NULL end date exists so
                                           <br> no new transaction can be created.
                                           <br> If the value is 2 Then gap exists and the stsrt date and end date out
                                           <br> parameters are defaulted with the first gap.
* @param p_start_org_id                    organization_id of the start operating unit
* @param p_end_org_id                      organization_id of the end operating unit
* @param p_flow_type                       Indicated whether flow type is shipping or procuring
* @param p_organization_id                 The ship From/To Organization Id
* @param p_qualifier_code                  This indicates the qualifier code for the flow type.At present it can be null or Category
* @param p_qualifier_value_id              This is the value of the qualifier code if selected as Category
*/

PROCEDURE Get_Default_Dates  ( X_START_DATE             OUT   NOCOPY    DATE,
                               X_END_DATE               OUT   NOCOPY    DATE,
                               X_REF_DATE               OUT   NOCOPY    DATE,
                               X_RETURN_CODE            OUT   NOCOPY    NUMBER,
                               P_START_ORG_ID           IN              NUMBER,
                               P_END_ORG_ID             IN              NUMBER,
                               P_FLOW_TYPE              IN              NUMBER,
                               P_ORGANIZATION_ID        IN              NUMBER,
                               P_QUALIFIER_CODE         IN              NUMBER,
                               P_QUALIFIER_VALUE_ID     IN              NUMBER
                             );


/** This functions takes the following parameters and checks for for a new gap that
 <br> has been created. It returns the value true whenever user creates a gap
 <br> and false when gap is not created. The return boolean value is checked
 <br> to issue a warning to the user whenever the gap is created.<br>

* @param p_start_org_id                    organization_id of the start operating unit
* @param p_end_org_id                      organization_id of the end operating unit
* @param p_flow_type                       Indicated whether flow type is shipping or procuring
* @param p_organization_id                 The ship From/To Organization Id
* @param p_qualifier_code                  This indicates the qualifier code for the flow type.At present it can be null or Category
* @param p_qualifier_value_id              This is the value of the qualifier code if selected as Category
* @param p_start_date                      The start date with time when the  trx flow becomes active
* @param p_end_date                        The end date with time when the  trx flow ceases to be active
* @param p_ref_date                        The ref date which carries the system date
*/


FUNCTION New_Gap_Created     (
                               P_START_ORG_ID       IN     NUMBER,
                               P_END_ORG_ID         IN     NUMBER,
                               P_FLOW_TYPE          IN     NUMBER,
                               P_ORGANIZATION_ID    IN     NUMBER,
                               P_QUALIFIER_CODE     IN     NUMBER,
                               P_QUALIFIER_VALUE_ID IN     NUMBER,
                               P_START_DATE         IN     DATE,
                               P_END_DATE           IN     DATE,
                               P_REF_DATE           IN     DATE

                            ) RETURN BOOLEAN;

/** This procedure takes in the context and the flex name as the parameters and returns
 <br> a table containing enabled segments for that flex field and context. <br>

* @param x_return_status                   return_status(OUT Parameter)
* @param x_msg_count                       Count of the recent message(OUT Parameter)
* @param x_msg_data                        Data of the message(OUT Parameter)
* @param x_enabled_segs                    A table containing enabled segments for that flex field and context.
* @param p_context
* @param p_flex_name                       Name of the flex field for which the validation is to be done


PROCEDURE Txn_Flow_Dff   (  X_RETURN_STATUS  OUT NOCOPY   VARCHAR2
                           ,X_MSG_COUNT      OUT NOCOPY   NUMBER
                           ,X_MSG_DATA       OUT NOCOPY   VARCHAR2
                           ,X_ENABLED_SEGS   OUT NOCOPY    inv_lot_sel_attr.lot_sel_attributes_tbl_type
                           ,P_CONTEXT        IN           VARCHAR2
			   ,P_FLEX_NAME      IN            VARCHAR2
                          );


/** This function takes the following parameters and checks that the attribute columns
  <br> are valid or not. The check is done bote for global context as well as the user
   <br> defined context. The validation is done for the required segments in the DFF,
   <br> for the value set and also if any wrong columns not part of DFF are passed.<br>

* @param p_flex_name                       name of the flex field for which the validation is to be done
* @param p_attribute_category              Attribute context column
* @param p_attribute1                      Attribute column
* @param p_attribute2                      Attribute column
* @param p_attribute3                      Attribute column
* @param p_attribute4                      Attribute column
* @param p_attribute5                      Attribute column
* @param p_attribute6                      Attribute column
* @param p_attribute7                      Attribute column
* @param p_attribute8                      Attribute column
* @param p_attribute9                      Attribute column
* @param p_attribute10                     Attribute column
* @param p_attribute11                     Attribute column
* @param p_attribute12                     Attribute column
* @param p_attribute13                     Attribute column
* @param p_attribute14                     Attribute column
* @param p_attribute15                     Attribute column
*/
FUNCTION Validate_Dff(P_FLEX_NAME          IN   VARCHAR2,
                      P_ATTRIBUTE1         IN   VARCHAR2,
		      P_ATTRIBUTE2         IN   VARCHAR2,
		      P_ATTRIBUTE3         IN   VARCHAR2,
		      P_ATTRIBUTE4         IN   VARCHAR2,
		      P_ATTRIBUTE5         IN   VARCHAR2,
		      P_ATTRIBUTE6         IN   VARCHAR2,
		      P_ATTRIBUTE7         IN   VARCHAR2,
		      P_ATTRIBUTE8         IN   VARCHAR2,
		      P_ATTRIBUTE9         IN   VARCHAR2,
		      P_ATTRIBUTE10        IN   VARCHAR2,
		      P_ATTRIBUTE11        IN   VARCHAR2,
		      P_ATTRIBUTE12        IN   VARCHAR2,
		      P_ATTRIBUTE13        IN   VARCHAR2,
		      P_ATTRIBUTE14        IN   VARCHAR2,
		      P_ATTRIBUTE15        IN   VARCHAR2,
		      P_ATTRIBUTE_CATEGORY IN   VARCHAR2
		      ) RETURN BOOLEAN;


/** This is the API that will be used by third parties to create a transaction flow.
<br>This procedure does the following
<br>It first validates all the parameters such as start_org_id,end_org_id,flow_type,
<br>qualifier_value,qualifier_value_id for their validity i.e. all the are valid id's for
<br> that org.Then it calls the pvt procedures such as validate_header,validate_start_date,
<br> validate_end_date,validate_lines to check the validity of all these values.
<br> Finally if all validations are true it inserts a row into the header table and
<br> the required number of rows in the lines table.<br>

* @param x_return_status                   return_status(OUT Parameter)
* @param x_msg_count                       Count of the recent message(OUT Parameter)
* @param x_msg_data                        Data of the message(OUT Parameter)
* @param p_header_id                       unique identifier for header table
* @param p_commit                          Used for getting the savepoints
* @param p_validation_level                Used to signify whether the procedure is used by a third party
* @param p_start_org_id                    organization_id of the start operating unit
* @param p_end_org_id                      organization_id of the end operating unit
* @param p_last_update_date                Who column
* @param p_last_updated_by                 Who Column
* @param p_creation_date                   Who Column
* @param p_created_by                      Who Column
* @param p_last update login               Who Column
* @param p_flow_type                       Indicated whether flow type is shipping or procuring
* @param p_organization_id                 The ship From/To Organization Id
* @param p_qualifier_code                  This indicates the qualifier code for the flow type.At present it can be null or Category
* @param p_qualifier_value_id              This is the value of the qualifier code if selected as Category
* @param p_asset_item_pricing_option       This gives the Asset pricing option as either PO or Transfer if flow type is procuring
* @param p_expense_item_pricing_option     This gives the Expense pricing option as either PO or Transfer if flow type is procuring
* @param p_start_date                      The start date with time when the  trx flow becomes active
* @param p_end_date                        The end date with time when the  trx flow ceases to be active
* @param p_new_accounting_flag             Indicates whether the user is going for the new accounting or old accounting.
                                           <br>If flow is procuring then it should be new.
                                           <br> FOR shipping if number of lines greater than 1 then new
* @param p_attribute_category              Attribute context column
* @param p_attribute1                      Attribute column
* @param p_attribute2                      Attribute column
* @param p_attribute3                      Attribute column
* @param p_attribute4                      Attribute column
* @param p_attribute5                      Attribute column
* @param p_attribute6                      Attribute column
* @param p_attribute7                      Attribute column
* @param p_attribute8                      Attribute column
* @param p_attribute9                      Attribute column
* @param p_attribute10                     Attribute column
* @param p_attribute11                     Attribute column
* @param p_attribute12                     Attribute column
* @param p_attribute13                     Attribute column
* @param p_attribute14                     Attribute column
* @param p_attribute15                     Attribute column
* @param p_ref_date                        The date type variable which carries the date when user creating the trx flow.
                                           <br> It should be the latest value of sysdate.
* @param p_lines_tab                       Table of lines
*/

PROCEDURE Create_IC_Transaction_Flow(
                                     X_RETURN_STATUS               OUT     NOCOPY     VARCHAR2,
                                     X_MSG_COUNT                   OUT     NOCOPY     NUMBER,
                                     X_MSG_DATA                    OUT     NOCOPY     VARCHAR2,
                                     P_HEADER_ID                   IN                 NUMBER,
                                     P_COMMIT                      IN                 BOOLEAN DEFAULT FALSE,
                                     P_VALIDATION_LEVEL            IN                 NUMBER,--0=>No Validation,1=>Flow Validation
                                     P_START_ORG_ID                IN                 NUMBER,
                                     P_END_ORG_ID                  IN                 NUMBER,
                                     P_FLOW_TYPE                   IN                 NUMBER,
                                     P_ORGANIZATION_ID             IN                 NUMBER,
                                     P_QUALIFIER_CODE              IN                 NUMBER,
                                     P_QUALIFIER_VALUE_ID          IN                 NUMBER,
                                     P_ASSET_ITEM_PRICING_OPTION   IN                 NUMBER,
                                     P_EXPENSE_ITEM_PRICING_OPTION IN                 NUMBER,
                                     P_START_DATE                  IN                 DATE,
                                     P_END_DATE                    IN                 DATE,
                                     P_NEW_ACCOUNTING_FLAG         IN                 VARCHAR2,
                                     P_ATTRIBUTE_CATEGORY          IN                 VARCHAR2,
                                     P_ATTRIBUTE1                  IN                 VARCHAR2,
                                     P_ATTRIBUTE2                  IN                 VARCHAR2,
                                     P_ATTRIBUTE3                  IN                 VARCHAR2,
                                     P_ATTRIBUTE4                  IN                 VARCHAR2,
                                     P_ATTRIBUTE5                  IN                 VARCHAR2,
                                     P_ATTRIBUTE6                  IN                 VARCHAR2,
                                     P_ATTRIBUTE7                  IN                 VARCHAR2,
                                     P_ATTRIBUTE8                  IN                 VARCHAR2,
                                     P_ATTRIBUTE9                  IN                 VARCHAR2,
                                     P_ATTRIBUTE10                 IN                 VARCHAR2,
                                     P_ATTRIBUTE11                 IN                 VARCHAR2,
                                     P_ATTRIBUTE12                 IN                 VARCHAR2,
                                     P_ATTRIBUTE13                 IN                 VARCHAR2,
                                     P_ATTRIBUTE14                 IN                 VARCHAR2,
                                     P_ATTRIBUTE15                 IN                 VARCHAR2,
                                     P_REF_DATE                    IN                 DATE,
                                     P_LINES_TAB                   IN                 INV_TRANSACTION_FLOW_PVT.TRX_FLOW_LINES_TAB
                                  ) ;



/** This functions takes the following parameters and checks if a
   <br> for the validity of the lines block.
   <br> Retuns true if the all validations are passed. else returns false.
   <br> Here the idea is to prevent the user from creating non valid.
   <br> The check is done for the validity of the from_org_id, from_organization_id,
   <br> to_org_id,to_organization_id.Then it is checked that user completes the flow.
   <br> that is the end_org_id(header block) should be equal to the to_org_id to finish the flow.
   <br> Also checks that for all lines the intercompany relations has been set up before saving the data.
   <br> Also checks the validity of the new accounting flag that is it should be
   <br> yes always if it is a procuring flow. Else if shipping flow then it
   <br> should be yes if number of lines is graeter than one.
   <br> Also checks like no org should come twice in the lines is done.<br>

* @param p_lines_tab                       This is a table type of a in paramter wghich carries
                                           <br> the value for all the lines that are going to be
                                           <br> inserted. For each line the value of from_org_id,
                                           <br> from_organization_id, to_org_id, to_orgaization_id,etc
                                           <br> are populated in the table and table is passed as a parameter.
* @param p_start_org_id                    organization_id of the start operating unit
* @param p_end_org_id                      organization_id of the end operating unit
* @param p_flow_type                       Indicated whether flow type is shipping or procuring
* @param p_ship_from_to_organization_id    The ship From/To Organization Id
* @param p_new_accounting_flag             Indicates whether the user is going for the new accounting or old accounting.
                                           <br>If flow is procuring then it should be new.
                                           <br> FOR shipping if number of lines greater than 1 then new
*/
FUNCTION Validate_Trx_Flow_Lines(
                                 P_LINES_TAB                    IN INV_TRANSACTION_FLOW_PVT.TRX_FLOW_LINES_TAB,
                                 P_SHIP_FROM_TO_ORGANIZATION_ID IN NUMBER,
                                 P_FLOW_TYPE                    IN NUMBER,
                                 P_START_ORG_ID                 IN NUMBER,
                                 P_END_ORG_ID                   IN NUMBER,
                                 P_NEW_ACCOUNTING_FLAG          IN VARCHAR2
                                ) RETURN BOOLEAN;





/** This procedure is used for updating of a IC transaction flow.Since only the
<br>start_date and the end_date are updateable so only the statrt datr and end date
<br> along with the attribute columns are passed.<br>
* @param x_return_status                   return_status(OUT Parameter)
* @param x_msg_count                       Count of the recent message(OUT Parameter)
* @param x_msg_data                        Data of the message(OUT Parameter)
* @param p_header_id                       unique identifier for header table
* @param p_commit                          Used for getting the savepoints
* @param p_start_date                      The start date with time when the  trx flow becomes active
* @param p_end_date                        The end date with time when the  trx flow ceases to be active
* @param p_ref_date                        The date type variable which carries the date when user creating the trx flow.
                                           <br> It should be the latest value of sysdate.
* @param p_attribute_category              Attribute context column
* @param p_attribute1                      Attribute column
* @param p_attribute2                      Attribute column
* @param p_attribute3                      Attribute column
* @param p_attribute4                      Attribute column
* @param p_attribute5                      Attribute column
* @param p_attribute6                      Attribute column
* @param p_attribute7                      Attribute column
* @param p_attribute8                      Attribute column
* @param p_attribute9                      Attribute column
* @param p_attribute10                     Attribute column
* @param p_attribute11                     Attribute column
* @param p_attribute12                     Attribute column
* @param p_attribute13                     Attribute column
* @param p_attribute14                     Attribute column
* @param p_attribute15                     Attribute column
*/
PROCEDURE Update_IC_Transaction_Flow(
                                    X_RETURN_STATUS        OUT NOCOPY      VARCHAR2,
                                    X_MSG_COUNT            OUT NOCOPY      NUMBER,
                                    X_MSG_DATA             OUT NOCOPY      VARCHAR2,
                                    P_COMMIT               IN              BOOLEAN DEFAULT FALSE,
                                    P_HEADER_ID            IN              NUMBER,
                                    P_START_DATE           IN              DATE,
                                    P_END_DATE             IN              DATE,
                                    P_REF_DATE             IN              DATE,
                                    P_ATTRIBUTE_CATEGORY   IN		   VARCHAR2,
				    P_ATTRIBUTE1	   IN		   VARCHAR2,
                                    P_ATTRIBUTE2	   IN		   VARCHAR2,
				    P_ATTRIBUTE3	   IN		   VARCHAR2,
                                    P_ATTRIBUTE4	   IN		   VARCHAR2,
				    P_ATTRIBUTE5	   IN		   VARCHAR2,
                                    P_ATTRIBUTE6	   IN		   VARCHAR2,
				    P_ATTRIBUTE7	   IN		   VARCHAR2,
                                    P_ATTRIBUTE8	   IN		   VARCHAR2,
				    P_ATTRIBUTE9	   IN		   VARCHAR2,
                                    P_ATTRIBUTE10	   IN		   VARCHAR2,
				    P_ATTRIBUTE11	   IN		   VARCHAR2,
                                    P_ATTRIBUTE12          IN		   VARCHAR2,
				    P_ATTRIBUTE13	   IN		   VARCHAR2,
				    P_ATTRIBUTE14	   IN		   VARCHAR2,
                                    P_ATTRIBUTE15          IN		   VARCHAR2,
                                    P_LINES_TAB            IN              INV_TRANSACTION_FLOW_PVT.TRX_FLOW_LINES_TAB
				    ) ;


PROCEDURE update_ic_txn_flow_hdr
  (X_RETURN_STATUS	   OUT NOCOPY	VARCHAR2,
   X_MSG_COUNT		   OUT NOCOPY	NUMBER,
   X_MSG_DATA		   OUT NOCOPY	VARCHAR2,
   P_COMMIT		   IN		BOOLEAN DEFAULT FALSE,
   P_HEADER_ID		   IN		NUMBER,
   P_START_DATE	           IN		DATE,
   P_END_DATE		   IN		DATE,
   P_REF_DATE		   IN		DATE,
   P_ATTRIBUTE_CATEGORY    IN		VARCHAR2,
   P_ATTRIBUTE1	           IN		VARCHAR2,
   P_ATTRIBUTE2	           IN		VARCHAR2,
   P_ATTRIBUTE3	           IN		VARCHAR2,
   P_ATTRIBUTE4	           IN		VARCHAR2,
   P_ATTRIBUTE5	           IN		VARCHAR2,
   P_ATTRIBUTE6	           IN		VARCHAR2,
   P_ATTRIBUTE7	           IN		VARCHAR2,
   P_ATTRIBUTE8	           IN		VARCHAR2,
   P_ATTRIBUTE9	           IN		VARCHAR2,
   P_ATTRIBUTE10	   IN		VARCHAR2,
   P_ATTRIBUTE11	   IN		VARCHAR2,
   P_ATTRIBUTE12           IN		VARCHAR2,
   P_ATTRIBUTE13	   IN		VARCHAR2,
   P_ATTRIBUTE14	   IN		VARCHAR2,
   P_ATTRIBUTE15           IN		VARCHAR2
   );

PROCEDURE Update_IC_Txn_Flow_line(
				    X_RETURN_STATUS	   OUT NOCOPY	VARCHAR2,
				    X_MSG_COUNT		   OUT NOCOPY	NUMBER,
				    X_MSG_DATA		   OUT NOCOPY	VARCHAR2,
				    P_COMMIT		   IN		BOOLEAN DEFAULT FALSE,
				    P_HEADER_ID		   IN		NUMBER,
				    P_LINE_NUMBER          IN           NUMBER,
				    P_ATTRIBUTE_CATEGORY   IN		VARCHAR2,
				    P_ATTRIBUTE1	   IN		VARCHAR2,
                                    P_ATTRIBUTE2	   IN		VARCHAR2,
				    P_ATTRIBUTE3	   IN		VARCHAR2,
                                    P_ATTRIBUTE4	   IN		VARCHAR2,
				    P_ATTRIBUTE5	   IN		VARCHAR2,
                                    P_ATTRIBUTE6	   IN		VARCHAR2,
				    P_ATTRIBUTE7	   IN		VARCHAR2,
                                    P_ATTRIBUTE8	   IN		VARCHAR2,
				    P_ATTRIBUTE9	   IN		VARCHAR2,
                                    P_ATTRIBUTE10	   IN		VARCHAR2,
				    P_ATTRIBUTE11	   IN		VARCHAR2,
                                    P_ATTRIBUTE12          IN		VARCHAR2,
				    P_ATTRIBUTE13	   IN		VARCHAR2,
				    P_ATTRIBUTE14	   IN		VARCHAR2,
                                    P_ATTRIBUTE15          IN		VARCHAR2
				    );
END;-- INV_TRANSACTION_FLOW_PVT



 

/
