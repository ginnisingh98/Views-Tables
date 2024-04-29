--------------------------------------------------------
--  DDL for Package Body GR_PROCESS_DOCUMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GR_PROCESS_DOCUMENTS" AS
/*$Header: GRPDOCUB.pls 120.1 2005/09/06 14:37:10 pbamb noship $*/
/*
**
**
**
*/
PROCEDURE Build_Document_Details
				(p_commit IN VARCHAR2,
				 p_init_msg_list IN VARCHAR2,
				 p_validation_level IN NUMBER,
				 p_api_version IN NUMBER,
				 p_item_code IN VARCHAR2,
				 p_document_code IN VARCHAR2,
				 p_session_id IN NUMBER,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2)
	IS
BEGIN

 NULL;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;


END Build_Document_Details;
/*
**
**
**
*/
PROCEDURE Resolve_Phrase_Conflicts
				(p_commit IN VARCHAR2,
				 p_init_msg_list IN VARCHAR2,
				 p_validation_level IN NUMBER,
				 p_api_version IN NUMBER,
				 p_session_id IN NUMBER,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2)
	IS
BEGIN

 NULL;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;


END Resolve_Phrase_Conflicts;
/*
**
**
**
*/
PROCEDURE Build_Item_Document
				(p_commit IN VARCHAR2,
				 p_init_msg_list IN VARCHAR2,
				 p_validation_level IN NUMBER,
				 p_api_version IN NUMBER,
				 p_build_item IN VARCHAR2,
				 p_document_code IN VARCHAR2,
				 p_disclosure_code IN VARCHAR2,
				 p_language_code IN VARCHAR2,
				 p_session_id IN NUMBER,
				 x_document_text_id OUT NOCOPY NUMBER,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2)
	IS
BEGIN

 NULL;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;


END Build_Item_Document;
/*
**
**
**
*/

/*  20-Jun-2002   Melanie Grosser BUG 2381697 - Modified code to allow printing of documents in XML */
/*  18-Feb-2003   Melanie Grosser BUG 2800429 - Patchset version of Sico BUG 2789546
                                   Modified code to use new sequence GR_PRINT_ID_S as the value for g_session_id.
                                   The use of the profile value DB_SESSION_ID was causing various problems with
                                   the same session id being used for more than one document.
*/
PROCEDURE Print_Document
            (errbuf OUT NOCOPY VARCHAR2,
             retcode OUT NOCOPY VARCHAR2,
             p_commit IN VARCHAR2,
             p_init_msg_list IN VARCHAR2,
             p_validation_level IN NUMBER,
             p_api_version IN NUMBER,
             p_start_item IN VARCHAR2,
             p_end_item IN VARCHAR2,
             p_document_code IN VARCHAR2,
             p_disclosure_code IN VARCHAR2,
             p_language_code IN VARCHAR2,
             p_session_id IN NUMBER,
             p_printer IN VARCHAR2,
             p_user_print_style IN VARCHAR2,
             p_number_of_copies IN NUMBER,
             p_items_to_print IN VARCHAR2,
             p_return_status OUT NOCOPY VARCHAR2,
             p_msg_count OUT NOCOPY NUMBER,
             p_msg_data OUT NOCOPY VARCHAR2,
             p_output_type IN VARCHAR2)
	IS
BEGIN

 NULL;
 p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_SUCCESS;


END Print_Document;
/*
**
**
**
*/


/*  20-Jun-2002   Melanie Grosser BUG 2381697 - Modified code to allow printing of documents in XML */
/*  18-Feb-2003   Melanie Grosser BUG 2800429 - Patchset version of Sico BUG 2789546
                                   Modified code to use new sequence GR_PRINT_ID_S as the value for g_session_id.
                                   The use of the profile value DB_SESSION_ID was causing various problems with
                                   the same session id being used for more than one document.
*/
PROCEDURE Print_Worksheet
            (errbuf OUT NOCOPY VARCHAR2,
             retcode OUT NOCOPY VARCHAR2,
             p_commit IN VARCHAR2,
             p_init_msg_list IN VARCHAR2,
             p_validation_level IN NUMBER,
             p_api_version IN NUMBER,
             p_start_item IN VARCHAR2,
             p_end_item IN VARCHAR2,
             p_document_code IN VARCHAR2,
             p_disclosure_code IN VARCHAR2,
             p_language_code IN VARCHAR2,
             p_session_id IN NUMBER,
             p_printer IN VARCHAR2,
             p_user_print_style IN VARCHAR2,
             p_number_of_copies IN NUMBER,
             p_items_to_print IN VARCHAR2,
             p_return_status OUT NOCOPY VARCHAR2,
             p_msg_count OUT NOCOPY NUMBER,
             p_msg_data OUT NOCOPY VARCHAR2,
             p_output_type IN VARCHAR2)
 	IS
BEGIN

 NULL;
 p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_SUCCESS;
END Print_Worksheet;
/*
**
**
**
*/
PROCEDURE Process_Document_Structure
					(p_commit IN VARCHAR2,
					 p_session_id IN NUMBER,
					 p_source_action IN VARCHAR2,
					 x_return_status OUT NOCOPY VARCHAR2,
					 x_msg_count OUT NOCOPY NUMBER,
					 x_msg_data OUT NOCOPY VARCHAR2)
	IS
BEGIN

 NULL;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
END Process_Document_Structure;

/*
**
**
**
*/
PROCEDURE Get_Phrase_Type
			(p_phrase_code IN VARCHAR2,
			 p_conc_value IN NUMBER,
			 x_phrase_type OUT NOCOPY VARCHAR2,
			 x_hierarchy OUT NOCOPY NUMBER)
	IS
BEGIN

 NULL;

END Get_Phrase_Type;

PROCEDURE Third_Phrase_Insert_Row
			                           (p_session_id IN NUMBER,
                                 p_sequence_number IN NUMBER,
                                 p_source_itemcode IN VARCHAR2,
                                 p_document_code IN VARCHAR2,
                                 p_main_heading_code IN VARCHAR2,
                                 p_main_display_order IN NUMBER,
                                 p_sub_heading_code IN VARCHAR2,
                                 p_sub_display_order IN NUMBER,
                                 p_structure_display_order IN NUMBER,
                                 p_third_phrase IN VARCHAR2,
                                 x_return_status OUT NOCOPY VARCHAR2)
	IS
BEGIN

 NULL;

END Third_Phrase_Insert_Row;

/*
**
**
**
*/

/*  07-Jun-2001   Melanie Grosser  BUG 1772096 - Modified code to print column headings for Ingredient,
                                   Exposure and Toxic sections. Added code to this procedure to retrieve
				   the headings that will be printed.
*/
PROCEDURE Sort_Line_Data
				(p_document_code IN VARCHAR2,
				 x_ingred_line IN OUT NOCOPY g_ingred_line,
				 x_toxic_line IN OUT NOCOPY g_toxic_line,
				 x_exposure_line IN OUT	NOCOPY g_exposure_line,
				 x_msg_data OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER,
				 x_return_status OUT NOCOPY VARCHAR2)
	IS
BEGIN

 NULL;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

END Sort_Line_Data;

PROCEDURE Print_Ingredient_Data
				(p_item_code IN VARCHAR2,
				 p_language_code IN VARCHAR2,
				 p_label_code IN VARCHAR2,
				 p_source_procedure IN VARCHAR2,
				 p_source_action IN VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2)
	IS
BEGIN

 NULL;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;


END Print_Ingredient_Data;



/*
**		This procedure will write an informational message into the
**		work sheet print table to give the user more information about
**		how the document is built.
*/
PROCEDURE Insert_Worksheet_Message
						(p_message_name IN VARCHAR2,
						 p_token_name IN VARCHAR2,
						 p_token_value IN VARCHAR2,
						 p_item_code IN VARCHAR2,
						 x_return_status OUT NOCOPY VARCHAR2,
						 p_token_name2 IN VARCHAR2,
						 p_token_value2 IN VARCHAR2)
	IS
BEGIN

 NULL;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;


END Insert_Worksheet_Message;

PROCEDURE Print_Toxic_Data
               (p_item_code IN VARCHAR2,
                p_language_code IN VARCHAR2,
                p_label_code IN VARCHAR2,
                p_source_action IN VARCHAR2,
                p_consolidate IN VARCHAR2,
                x_return_status OUT NOCOPY VARCHAR2)
	IS
BEGIN

 NULL;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;


END Print_Toxic_Data;


/*
**
**
**
*/
/*  07-Jun-2001   Melanie Grosser  BUG 1772096 - Modified code to print column headings for Ingredient,
                                                 Exposure and Toxic sections. Added code to procedure
                                                 Sort_Line_data to retrieve the column headings. Greatly re-worked
                                                 Print_Ingredient_Data, Print_Toxic_Data and Print_Exposure_Data
                                                 procedures in order to correctly align the columns. Removed some
                                                 formatting code from Print_Array_Data.
*/
/*  03-Jul-2001   Melanie Grosser  BUG 1862284 - Modified code take disclosure codes into consideration when
                                                 determining the max length of fields.  Also modified code to account
                                                 for uom of 'Not Available' in toxic and exposure sections.
                                                 Re-worked most of the procedure.
*/
/*  22-Oct-2001   Melanie Grosser  BUGs 1985685,1839807 - Break printed line into
                                                          multiple lines no longer than 80 characters if
                                                          text to be pinted is greater than 80
*/
/*  20-Jun-2002   Melanie Grosser BUG 2381697 - Modified code to allow printing of documents in XML and HTML */

/* MGEXP*/
PROCEDURE Print_Exposure_Data
               (p_item_code IN VARCHAR2,
                p_language_code IN VARCHAR2,
                p_label_code IN VARCHAR2,
                p_source_action IN VARCHAR2,
                p_consolidate IN VARCHAR2,
                x_return_status OUT NOCOPY VARCHAR2)
	IS
BEGIN

 NULL;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;


END Print_Exposure_Data;

/*
**
**
**
*/
PROCEDURE Print_Phrase_Lines
				(p_phrase_text IN VARCHAR2,
				 p_source_action IN VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2)
 	IS
BEGIN

 NULL;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

END Print_Phrase_Lines;

/*
**
**
**
*/
/*    24-Sep-2001   Melanie Grosser  BUG 1323963 - Implementation of field name masking
                                                   Added new procedure PRINT_MASKED_VALUE
*/
/*  10-Dec-2001   Melanie Grosser  BUG 1323963 - Implementation of field name masking
                                                 If this is a user defined field name and there is data, check for a mask
*/
/*  20-Jun-2002   Melanie Grosser BUG 2381697 - Modified code to allow printing of documents in XML and HTML */

/*  12-May-2003  Geraldine Kelly  Bug 2948796 - Modified code to check for the document version label 00006 and that it selects from the
				   Item_Doc_Statuses table in procedure Print_Label_Lines.*/

PROCEDURE Print_Label_Lines
				(p_label_code IN VARCHAR2,
				 p_source_action IN VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2)
 	IS
BEGIN

 NULL;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

END Print_Label_Lines;

/*
**
**
*/
PROCEDURE Clear_Worksheet_Session
			(p_commit IN VARCHAR2,
			 p_session_id IN NUMBER,
			 x_return_status OUT NOCOPY VARCHAR2,
			 x_oracle_error OUT NOCOPY NUMBER,
			 x_msg_data OUT NOCOPY VARCHAR2)
 	IS
BEGIN

 NULL;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;


END Clear_Worksheet_Session;
/*
**
**
**
*/
PROCEDURE Update_Phrase_Groups
				(p_commit IN VARCHAR2,
				 p_api_version IN NUMBER,
				 p_init_msg_list IN VARCHAR2,
				 p_validation_level IN NUMBER,
				 p_called_by_form IN VARCHAR2,
				 p_update_option IN VARCHAR2,
				 p_rebuild_document_flag IN VARCHAR2,
				 p_phrase_group_code IN VARCHAR2,
				 p_phrase_code IN VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2,
				 x_msg_count OUT NOCOPY NUMBER,
				 x_msg_data OUT NOCOPY VARCHAR2)
	IS
BEGIN

 NULL;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

END Update_Phrase_Groups;
/*
**
**
**
*/
FUNCTION Conflict_Action
		       (p_work_phrase IN VARCHAR2,
			    p_phrase_code IN VARCHAR2)

 RETURN VARCHAR2 IS

 BEGIN
   NULL;
   RETURN NULL;

END Conflict_Action;

FUNCTION Product_Toxic_Data
		       (p_item_code IN VARCHAR2)

 RETURN NUMBER IS

BEGIN


      RETURN 0;


END Product_Toxic_Data;
/*
**
**
*/
FUNCTION Product_Exposure_Data
		       (p_item_code IN VARCHAR2)

 RETURN NUMBER IS

BEGIN

      RETURN 0;

END Product_Exposure_Data;
/*
**		Read for the multilingual name using the label code
**		and language code passed in. If the MSDS name is not
**		found for the language, substitute with the user's
**		environment language. IF still not found then return
**		a description with an error
**
*/
FUNCTION Read_Multilingual_Name
				(p_label_code IN VARCHAR2,
				 p_language_code IN VARCHAR2)
	RETURN VARCHAR2 IS

BEGIN


   RETURN NULL;

EXCEPTION

   WHEN OTHERS THEN

	    RETURN NULL;

END Read_Multilingual_Name;
/*
**
**
*/
/*
-- HISTORY
--   22-Apr-2002   Melanie Grosser BUG 2300466 - Increased mask on approximate concentration to accommodate a value
--                                 of 100.
*/
FUNCTION Print_Concentration
				(p_concentration_ind IN VARCHAR2,
				 p_concentration IN NUMBER)
   RETURN VARCHAR2 IS

BEGIN


   RETURN NULL;

EXCEPTION

   WHEN OTHERS THEN

	    RETURN NULL;

END Print_Concentration;
/*
**		This function is called to obtain the character string
**      that holds the HMIS, NFPA or USER defined hazard codes
**      for the ingredient.
**      HMIS will return fire, health and reactivity
**      NFPA will return fire, health and reactivity
**      USER will return fire, health and reactivity
**
*/
FUNCTION Get_Hazard_Info
                (p_item_code IN VARCHAR2,
		 p_hazard_code IN VARCHAR2,
		 p_source_procedure IN VARCHAR2)
   RETURN VARCHAR2 IS

BEGIN


   RETURN NULL;

EXCEPTION

   WHEN OTHERS THEN

	    RETURN NULL;

END Get_Hazard_Info;
/*
**
**
**
**
*/

/*======================================================================
--  FUNCTION :
--   Calc_OSHA_Flam
--
--  DESCRIPTION:
--    This PL/SQL function is used to return a value for OSHA Flammability
--    Class.  It will try to use Flash Point data and if none can be
--    retrieved it will try to use Boiling Point data.  It will first try to
--    retrieve a value from the properties table and if no value is found,
--    it will try to rollup the data.
--
--  PARAMETERS:
--    p_source_action IN VARCHAR2    - The source action for this call
--                                     (e.g. WORKSHEET)
--    p_item_code IN VARCHAR2      - The phrase code to be printed.
--
--  SYNOPSIS:
--    l_osha_flam_class := Calc_OSHA_Flam(p_source_action,
--                                        g_current_item);
--
--  HISTORY
--  14-Aug-2001   Melanie Grosser  BUG 1778234 - Modified OSHA Flammability
--                                 calculation code to try to rollup values
--                                 if the property value has not been entered.
--                                 Completely re-worked this procedure
--===================================================================== */
/* MGFLAM */
FUNCTION Calc_OSHA_Flam
                (p_source_action IN VARCHAR2,
                 p_item_code IN VARCHAR2)
   RETURN VARCHAR2 IS

BEGIN


   RETURN NULL;

EXCEPTION

   WHEN OTHERS THEN

	    RETURN NULL;
END Calc_OSHA_Flam;

/*
**		This procedure is called from the EXCEPTION handlers
**		in other procedures. It is passed the message code,
**		token name and token value.
**
**		The procedure will then process the error message into
**		the message stack and then return to the calling routine.
**		The procedure assumes all messages used are in the
**		application id 'GR'.
**
*/
PROCEDURE Handle_Error_Messages
				(p_message_code IN VARCHAR2,
				 p_token_name IN VARCHAR2,
				 p_token_value IN VARCHAR2,
				 x_msg_count IN OUT NOCOPY NUMBER,
				 x_msg_data IN OUT NOCOPY VARCHAR2,
				 x_return_status OUT NOCOPY VARCHAR2)
 IS
BEGIN

 NULL;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

END Handle_Error_Messages;

/*          - Fix for B1307058
**		This function is called to convert the temperature
**		values for boiling point and flash range from
**		celsius to farhenheit and vice versa.
**
**		This function returns the converted value and the
**          scale concatenated as a string.
*/
FUNCTION Convert_Temperature_Values
				(p_low_val IN NUMBER,
				 p_high_val IN NUMBER,
				 p_scale IN VARCHAR2)
RETURN VARCHAR2 IS

BEGIN


   RETURN NULL;

EXCEPTION

   WHEN OTHERS THEN

	    RETURN NULL;
END Convert_Temperature_Values;

/*          - Fix for B1307058
**		This function is called to convert the temperature value
**		from P_FROM_SCALE to P_TO_SCALE.
*/
FUNCTION Convert_To_Scale
				(p_value IN NUMBER,
				 p_from_scale IN VARCHAR2,
				 p_to_scale IN VARCHAR2,
                         p_precision IN NUMBER)
RETURN NUMBER IS

BEGIN


   RETURN 0;

EXCEPTION

   WHEN OTHERS THEN

	    RETURN 0;
END Convert_To_Scale;

/*
**		This procedure is used to consolidate the concentrations percentages
**		for similar group of ingredients.
*/
PROCEDURE consolidate_ingredient_data (p_count IN OUT NOCOPY NUMBER) IS

BEGIN
NULL;
END consolidate_ingredient_data;

/*  07-Jun-2001   Melanie Grosser  BUG 1772096 - Modified code to print column headings for Ingredient,
                                                 Exposure and Toxic sections. Added code to procedure
                                                 Sort_Line_data to retrieve the column headings. Greatly re-worked
                                                 Print_Ingredient_Data, Print_Toxic_Data and Print_Exposure_Data
                                                 procedures in order to correctly align the columns. Removed some
                                                 formatting code from Print_Array_Data.
*/
/*  22-Oct-2001   Melanie Grosser  BUGs 1985685,1839807 - Break printed line into
                                                          multiple lines no longer than 80 characters if
                                                          text to be pinted is greater than 80
*/
/*  20-Jun-2002   Melanie Grosser BUG 2381697 - Modified code to allow printing of documents in XML and HTML */

PROCEDURE Print_Array_Data (p_source_action IN VARCHAR2,
                            p_source_procedure IN VARCHAR2,
	  	            p_row IN NUMBER,
                            p_msds_count IN NUMBER,
                            p_conc_count IN NUMBER,
                            x_return_status IN OUT NOCOPY VARCHAR2)
IS
BEGIN

 NULL;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

END Print_Array_Data;


FUNCTION Get_Ingredient_Rollup_Value (p_item_code IN VARCHAR2, p_label_code IN VARCHAR2,
                           p_property_id IN VARCHAR2, p_scale IN OUT NOCOPY VARCHAR2,
                           x_return_status IN OUT NOCOPY VARCHAR2) RETURN VARCHAR2 IS

BEGIN


   RETURN NULL;

EXCEPTION

   WHEN OTHERS THEN

	    RETURN NULL;
END GET_INGREDIENT_ROLLUP_VALUE;


/*======================================================================
--  PROCEDURE :
--   print_masked_value
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to print the value of the
--    field name that is being masked and the value of the mask.
--    This will only be printed if a Worksheet is being printed.
--
--  PARAMETERS:
--    p_item_code IN VARCHAR2  - The regulatory item code to be used
--    p_label_code IN VARCHAR2 - The field name (label_code) to be used
--    p_value IN VARCHAR2      - The actual value of the field name
--    p_source_action IN VARCHAR2    - The source action for this call
--                                     (e.g. WORKSHEET)
--    p_mask OUT NOCOPY VARCHAR2       - The mask to be used
--    x_return_status OUT NOCOPY VARCHAR2   - Return status for procedure.
--
--  SYNOPSIS:
--    print_masked_value(g_current_item,g_current_label,LocalItemRecord.alpha_value,
--                    p_source_action,l_mask,x_return_status);
--
--  HISTORY
--    24-Sep-2001   Melanie Grosser  BUG 1323963 - Implementation of field name masking
--                                                 Added new procedure PRINT_MASKED_VALUE
--===================================================================== */
PROCEDURE print_masked_value
          (p_item_code IN VARCHAR2,
           p_label_code IN VARCHAR2,
           p_value IN VARCHAR2,
           p_source_action IN VARCHAR2,
           p_mask OUT NOCOPY VARCHAR2,
    	   x_return_status OUT NOCOPY VARCHAR2)
 IS
BEGIN

 NULL;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

END PRINT_MASKED_VALUE;


/*======================================================================
--  PROCEDURE :
--    check_heading_length
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to check to see if line text line
--    line should be wrapped.  If so, it will print the current text line
--    and clear the line.
--
--  PARAMETERS:
--    p_text_line     IN OUT NOCOPY VARCHAR2  -  Line of text to be printed
--    p_text_line2    IN OUT NOCOPY VARCHAR2  -  Used to print HMIS headings
--    p_column_length IN NUMBER        - The max length of the column
--    p_source        IN VARCHAR2      - 'WORKSHEET' or 'DOCUMENT'
--    x_return_status OUT NOCOPY VARCHAR2     - Return status for procedure.
--
--  SYNOPSIS:
--    check_heading_length(l_text_line, l_text_line2, max_msds,x_return_status);
--
--  HISTORY
--    M. Grosser 22-Oct-2001  BUG 1985685,1839807 - Break printed line into
--                            multiple lines no longer than 80 characters if
--                            text to be pinted is greater than 80
--    M. Grosse  20-Jun-2002  BUG 2381697 - Allow printing of documents in XML
--                            Only run this code if NOT printing XML or HTML
--===================================================================== */
PROCEDURE check_heading_length
          (p_text_line IN OUT NOCOPY VARCHAR2,
           p_text_line2 IN OUT NOCOPY VARCHAR2,
           p_column_length IN NUMBER,
		   p_source IN VARCHAR2,
    	   x_return_status OUT NOCOPY VARCHAR2)
 IS
BEGIN

 NULL;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;

END check_heading_length;



/*======================================================================
--  PROCEDURE :
--    invalidate_languages
--
--  DESCRIPTION:
--    Set all languages to rebuild if one is rebuilt.  This is done by
--    looping through and setting the end date to yesterday.
--
--  PARAMETERS:
--    p_document_code      IN  VARCHAR2
--    p_language_code      IN  VARCHAR2
--    p_disclosure_code    IN  VARCHAR2
--    p_commit             IN  VARCHAR2
--    p_called_by_form     IN  VARCHAR2(1)
--    p_return_status      OUT NOCOPY VARCHAR2
--
--  HISTORY
--    Jeff Baird    06-Nov-2001  Create procedure.
--===================================================================== */

PROCEDURE invalidate_languages
          (p_document_code IN VARCHAR2,
           p_language_code IN VARCHAR2,
           p_disclosure_code IN VARCHAR2,
           p_commit IN VARCHAR2,
           p_called_by_form IN VARCHAR2,
           p_return_status OUT NOCOPY VARCHAR2)
IS
BEGIN

 NULL;
 p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_SUCCESS;

END invalidate_languages;


/*===========================================================================
--  PROCEDURE:
--    Submit_Print
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to  submit the concurrent request to print
--    a document or a worksheet in PDF, XML or HTML.
--
--  PARAMETERS:
--    p_document_code  IN VARCHAR2   - Document code being printed
--    p_language_code  IN VARCHAR2   - Language that document is being printed in
--    p_source         IN VARCHAR2   - 'WORKSHEET' or 'DOCUMENT'
--    x_return_status OUT NOCOPY VARCHAR2   - 'S'uccess, 'E'rror, 'U'nexpected Error
--
--  SYNOPSIS:
--    Submit_Print(p_document_code,p_language_code,p_source,l_return_status);
--
--  HISTORY
--    20-Jun-2002   Melanie Grosser BUG 2381697 - Modified code to allow printing of documents in XML and HTML
--                                  Created new procedure Submit_Print.
--    15-Aug-2002   Melanie Grosser BUG 2381697 - Modified wait statement and concurrent program name.
--    01-Oct-2002   Melanie Grosser BUG 2381697 - Removed printing of HTML
--    22-Nov-2002   Melanie Grosser BUG 2381697 - Corrected procedure Submit_Print to call the proper concurrent
--                                  program (with the proper display title) when printing a worksheet.
--    17-Jun-2003   Mercy Thomas    BUG 2932007 - Added parameter to the Concurrent Report to incorporate Document Management
--=========================================================================== */
PROCEDURE Submit_Print
          (p_document_code IN VARCHAR2,
           p_language_code IN VARCHAR2,
           p_source IN VARCHAR2,
           x_return_status OUT NOCOPY VARCHAR2)
 IS
BEGIN

 NULL;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
END Submit_Print;


/*===========================================================================
--  FUNCTION:
--    Get_Print_ID
--
--  DESCRIPTION:
--    This PL/SQL function is used to retrieve a value from the sequence
--    GR_PRINT_ID_S, which will be used for the value of g_session_id
--
--  PARAMETERS:
--    NONE
--
--  SYNOPSIS:
--    g_session_id := Get_Print_ID;
--
--  HISTORY
--    18-Feb-2003   Melanie Grosser BUG 2800429 - Patchset version of Sico BUG 2789546
--                                  Modified code to use new sequence GR_PRINT_ID_S as the value for g_session_id.
--                                  The use of the profile value DB_SESSION_ID was causing various problems with
--                                  the same session id being used for more than one document.
--                                  Created new procedure Get_Print_ID to handle the retrieval/incrementation of
--                                  retrieval/incrementation of GR_PRINT_ID_S.
--                                  GR_PRINT_ID_S.  Replaced the setting of g_session_id = g_session_id + 1 with
--                                  a call to Get_Print_ID.
--=========================================================================== */
FUNCTION Get_Print_ID
 RETURN NUMBER IS

BEGIN


   RETURN 0;

EXCEPTION

   WHEN OTHERS THEN

	    RETURN 0;
END Get_Print_ID;


/*======================================================================
--  FUNCTION :
--   Get_Field_Name_Phrase
--
--  DESCRIPTION:
--    This PL/SQL function is used to retrieve phrases associated with
--    field name properties.
--
--  PARAMETERS:
--    p_phrase_code IN VARCHAR2      - The phrase code to be used for text retrieval
--    x_return_status OUT NOCOPY VARCHAR2   - Return status for function
--
--  SYNOPSIS:
--    Get_Field_Name_Phrase(l_phrase_code,x_return_status);
--
--  HISTORY
--    26-Feb-2003   Melanie Grosser BUG 2718956 - Fixed data alignment issues
--                                  Added new function Get_Field_Name_Phrase
--===================================================================== */
FUNCTION  Get_Field_Name_Phrase
          (p_phrase_code IN VARCHAR2,
    	   x_return_status OUT NOCOPY VARCHAR2) RETURN VARCHAR2
  IS
BEGIN


   RETURN NULL;

EXCEPTION

   WHEN OTHERS THEN

	    RETURN NULL;

END GET_FIELD_NAME_PHRASE;


/*======================================================================
--  PROCEDURE :
--   print_field_name_data
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to print data associated with
--    field name properties.  It will format the data apropriately.
--
--  PARAMETERS:
--    p_line_length IN NUMBER        - The maximum number of characters
--                                     that can be printed on a line
--    p_text_line_2 IN OUT NOCOPY VARCHAR2  - Any text that should have more
--                                     text appended to the end.
--    p_source_action IN VARCHAR2    - The source action for this call
--                                     (e.g. WORKSHEET)
--    x_return_status OUT NOCOPY VARCHAR2   - Return status for procedure.
--
--  SYNOPSIS:
--    print_field_name_data( l_line_length,l_text_line2,l_text_line_2,p_source_action,x_return_status);
--
--  HISTORY
--  26-Feb-2003   Melanie Grosser BUG 2718956 - Fixed data alignment issues
--                                 Added new procedure Print_Field_Name_Data
--===================================================================== */
PROCEDURE print_field_name_data
          (p_line_length IN NUMBER,
           p_text_line_1 IN OUT NOCOPY VARCHAR2,
           p_text_line_2 IN OUT NOCOPY VARCHAR2,
           p_source_action IN VARCHAR2,
    	   x_return_status OUT NOCOPY VARCHAR2)
   IS
BEGIN

 NULL;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
END PRINT_FIELD_NAME_DATA;

/*===========================================================================
--  PROCEDURE:
--    Upload_Doc_File
--
--  DESCRIPTION:
--    This PL/SQL procedure is used to Upload the document file into FND Tables
--
--  PARAMETERS:
--    p_document_management  IN        VARCHAR2   - Document Management is enbled or not.
--    p_source_lang          IN        VARCHAR2   - Source Lanaguage
--    p_category             IN        VARCHAR2   - Category code for the document
--    p_request_id           IN        NUMBER     - Request ID for the generated Document
--    p_output_type          IN        VARCHAR2   - Output Type
--    p_attribute1           IN        VARCHAR2   - Attribute1
--    p_attribute2           IN        VARCHAR2   - Attribute2
--    p_attribute3           IN        VARCHAR2   - Attribute3
--    p_attribute4           IN        VARCHAR2   - Attribute4
--    p_attribute5           IN        VARCHAR2   - Attribute5
--    p_attribute6           IN        VARCHAR2   - Attribute6
--    p_attribute7           IN        VARCHAR2   - Attribute7
--    p_attribute8           IN        VARCHAR2   - Attribute8
--    p_attribute9           IN        VARCHAR2   - Attribute9
--    p_attribute10          IN        VARCHAR2   - Attribute10
--    p_created_by           IN        NUMBER     - WHO Column for Created By
--    p_creation_date        IN        DATE       - WHO Column for Creation Date
--    p_last_updated_by      IN        NUMBER     - WHO Column for Last Updated By
--    p_last_updated_login   IN        NUMBER     - WHO Column for Last Updated Login
--    p_last_updated_date    IN        DATE       - WHO Column for Last Updated Date
--    x_return_status       OUT NOCOPY VARCHAR2   - 'S'uccess, 'E'rror, 'U'nexpected Error
--    x_msg_data            OUT NOCOPY VARCHAR2   - Message Data for the return status
--
--  SYNOPSIS:
--    Upload_Doc_File(p_document_management,
--                    p_source_lang,
--                    p_category,
--                    p_request_id,
--                    p_output_type,
--                    p_attribute1,
--                    p_attribute2,
--                    p_attribute3,
--                    p_attribute4,
--                    p_attribute5,
--                    p_attribute6,
--                    p_attribute7,
--                    p_attribute8,
--                    p_attribute9,
--                    p_attribute10,
--                    p_created_by,
--                    p_creation_date,
--                    p_last_updated_by,
--                    p_last_updated_login,
--                    p_last_updated_date,
--                    l_return_status,
--                    l_msg_data);
--
--  HISTORY
--    17-Jun-2003   Mercy Thomas    BUG 2932007 - Created new procedure Upload_Doc_File
--                                  to Upload the Document into FND Tables
--    01-Dec-2003   Mercy Thomas    BUG 3289104 - Added new local variables l_return_Status and l_msg_data
--                                  Modified the code which calls EDR API to call using call by reference
--                                  Replace the x_return_status with l_return_status and x_msg_data with l_msg_data.
--=========================================================================== */


PROCEDURE Upload_Doc_File
                           (errbuf                 OUT NOCOPY VARCHAR2,
                            retcode                OUT NOCOPY VARCHAR2,
                            p_document_management   IN  VARCHAR2,
                            p_source_lang           IN  VARCHAR2,
                            p_category              IN  VARCHAR2,
                            p_request_id            IN  NUMBER,
                            p_output_type           IN  VARCHAR2,
                            p_attribute1            IN  VARCHAR2,
                            p_attribute2            IN  VARCHAR2,
                            p_attribute3            IN  VARCHAR2,
                            p_attribute4            IN  VARCHAR2,
                            p_attribute5            IN  VARCHAR2,
                            p_attribute6            IN  VARCHAR2,
                            p_attribute7            IN  VARCHAR2,
                            p_attribute8            IN  VARCHAR2,
                            p_attribute9            IN  VARCHAR2,
                            p_attribute10           IN  VARCHAR2,
                            p_created_by            IN  NUMBER,
                            p_creation_date         IN  DATE,
                            p_last_updated_by       IN  NUMBER,
                            p_last_update_login     IN  NUMBER,
                            p_last_update_date      IN  DATE,
                            x_return_status        OUT  NOCOPY  VARCHAR2,
                            x_msg_data             OUT  NOCOPY  VARCHAR2)  IS
BEGIN

 NULL;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
END Upload_Doc_File;


END GR_PROCESS_DOCUMENTS;

/
