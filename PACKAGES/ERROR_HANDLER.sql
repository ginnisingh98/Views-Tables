--------------------------------------------------------
--  DDL for Package ERROR_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ERROR_HANDLER" AUTHID CURRENT_USER AS
/* $Header: BOMBOEHS.pls 120.4 2006/09/14 16:09:06 pdutta ship $ */
/*#
 * You can use this API for  logging/retrieving Error or Warning messages.This API should be used along with
 * the other business object APIs like the BOM Business Object API for retrieving of errors
 * or warning logged during processing.This API also retrieves the translated error/warning messages
 * for a business object. The sequence in which the user needs to use the Error Handler is described below.
 *
 * <li>1.Initialize the Error Handler through Initialize procedure.</li>
 * <li>2.If the debug flag is set to Y then valid values should be given for Output Directory and Output File otherwise it turns off the
 *   debug and logs the error to Error Handler.</li>
 * <li>3.Open a Debug Session using the Open_Debug_Session procedure</li>
 * <li>4.If the return status is Success then set the debug to Y otherwise set it to N</li>
 * <li>5.If the debug status is Y then write to the error handler the entities as they are passed.</li>
 * <li>6.After all the validation and processing of business entities,if the return status is not sucesss
 *   then Log error to the Error handler and write the error to Interface Table or Concurrent Log or Debug File
 *   based on the values of their respective flags.</li>
 * The different record types used in this packages are given below.<BR>
 *
 *
 * --------------------
 *    Error Record
 * --------------------
 *
 *<code><pre>
 * TYPE Error_Rec_Type IS RECORD
 *   (   organization_id               NUMBER
 *   ,   entity_id                     VARCHAR2(30)
 *   ,   table_name                    VARCHAR2(30)
 *   ,   message_name		       VARCHAR2(30)
 *   ,   message_text                  VARCHAR2(2000)
 *   ,   entity_index                  NUMBER
 *   ,   message_type                  VARCHAR2(1)
 *   ,   row_identifier                NUMBER
 *   ,   bo_identifier                 VARCHAR2(30) := 'ECO'
 *   );
 *</pre></code>
 *
 * ------------------
 *   Parameters
 * ------------------
 *<pre>
 * organization_id           -- Organization Id
 * entity_id                 -- A constant which indicates the entity for which the error is logged
 *                              The possible values are
 *                              1.G_BO_LEVEL  - Business Object      - 0
 *                              2.G_ECO_LEVEL - Eng Change Order     - 1
 *                              3.G_REV_LEVEL - Revision Level       - 2
 *                              4.G_RI_LEVEL  - Revised Item         - 3
 *                              5.G_RC_LEVEL  - Revised Component    - 4
 *                              6.G_RD_LEVEL  - Reference Designator - 5
 *                              7.G_SC_LEVEL  - Substitute Component - 6
 *                              8.G_BH_LEVEL  - Bill Header          - 7
 * table_name                -- Production table name where the data goes in. This is useful when the same logical entity deals
 *                              with multiple tables.A typical example would be extensible attributes for an
 *                              entity. Logically, the entity is same but the data is going into two tables (ex: BOM_BILL_OF_MATERIALS and
 *                              BOM_BILL_OF_MATERIALS_EXT)
 * message_text              -- Free Text in case of Unexpected Errors
 * entity_index              -- The order of the entity record within the entity table
 * message_type              -- W -> Warning  E -> Error
 * row_identifier            -- Any unique identifier value for the entity record.In case of bulk load from interface table this can
 *                              be used to store the transaction_id
 * bo_identifier             -- Business Object Identifier
 *</pre>
 *
 * ---------------------------
 *   Message Token Record
 * ---------------------------
 *<code><pre>
 * TYPE Mesg_Token_Rec_Type IS RECORD
 *   (  message_name VARCHAR2(30)   := NULL
 *    , application_id VARCHAR2(3)  := NULL
 *    , message_text VARCHAR2(2000) := NULL
 *    , token_name   VARCHAR2(30)   := NULL
 *    , token_value  VARCHAR2(700)   := NULL
 *    , translate    BOOLEAN        := FALSE
 *    , message_type VARCHAR2(1)    := NULL
 *   )
 *</pre></code>
 *
 * --------------------
 *    Parameters
 * --------------------
 *
 *<pre>
 * message_name             -- FND Message Name
 * application_id           -- Application Short Name under which message is defined
 * message_text             -- Free Text in case off unexpected records
 * token_name               -- Token name for messages need to be translated
 * token_value              -- Token value for messages need to be translated
 * translate                -- Flag to decide whether message needs to be translated
 * message_type             -- E -> Error W -> Warning
 *</pre>
 *
 * @rep:scope public
 * @rep:product BOM
 * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
 * @rep:displayname Error Handler
 * @rep:lifecycle active
 * @rep:compatibility S
 */
    G_PKG_NAME      CONSTANT VARCHAR2(30)   := 'Error_Handler';
    G_BO_LEVEL      CONSTANT NUMBER         := 0;
    G_ECO_LEVEL     CONSTANT NUMBER         := 1;
    G_REV_LEVEL     CONSTANT NUMBER         := 2;
    G_RI_LEVEL      CONSTANT NUMBER         := 3;
    G_RC_LEVEL      CONSTANT NUMBER         := 4;
    G_RD_LEVEL      CONSTANT NUMBER         := 5;
    G_SC_LEVEL      CONSTANT NUMBER         := 6;
    G_BH_LEVEL      CONSTANT NUMBER         := 7;
    G_CL_LEVEL      CONSTANT NUMBER         := 21;
    G_ATCH_LEVEL    CONSTANT NUMBER         := 22;

    /* One to many operations support */
    G_COP_LEVEL     CONSTANT NUMBER         := 13;
    /*******************************************************
    -- Followings are for Routing BO
    ********************************************************/
    G_RTG_LEVEL     CONSTANT NUMBER         := 8;
    G_OP_LEVEL      CONSTANT NUMBER         := 9;
    G_RES_LEVEL     CONSTANT NUMBER         := 10;
    G_SR_LEVEL      CONSTANT NUMBER         := 11;
    G_NWK_LEVEL     CONSTANT NUMBER         := 12;
    -- Added by MK on 08/23/2000

    G_STATUS_WARNING    CONSTANT VARCHAR2(1)    := 'W';
    G_STATUS_UNEXPECTED CONSTANT VARCHAR2(1)    := 'U';
    G_STATUS_ERROR      CONSTANT VARCHAR2(1)    := 'E';
    G_STATUS_FATAL      CONSTANT VARCHAR2(1)    := 'F';
    G_STATUS_NOT_PICKED CONSTANT VARCHAR2(1)    := 'N';

    G_SCOPE_ALL         CONSTANT VARCHAR2(1)    := 'A';
    G_SCOPE_RECORD      CONSTANT VARCHAR2(1)    := 'R';
    G_SCOPE_SIBLINGS    CONSTANT VARCHAR2(1)    := 'S';
    G_SCOPE_CHILDREN    CONSTANT VARCHAR2(1)    := 'C';
    G_IS_BOM_OI                   BOOLEAN       := FALSE;
    Debug_File      UTL_FILE.FILE_TYPE;

    --  Error record type
    TYPE Error_Rec_Type IS RECORD
    (   organization_id               NUMBER
    ,   entity_id                     VARCHAR2(30)
    ,   table_name                    VARCHAR2(30)
    ,   message_name		      VARCHAR2(30)
    ,   message_text                  VARCHAR2(2000)
    ,   entity_index                  NUMBER
    ,   message_type                  VARCHAR2(1)
    ,   row_identifier                NUMBER
    ,   bo_identifier                 VARCHAR2(30) := 'ECO'
    );

   /* Fix for bug 4661753  - Added message_name to Error_Rec_Type record above */

    TYPE Error_Tbl_Type IS TABLE OF Error_Rec_Type
            INDEX BY BINARY_INTEGER;

    TYPE Mesg_Token_Rec_Type IS RECORD
    (  message_name VARCHAR2(30)   := NULL
     , application_id VARCHAR2(3)  := NULL
     , message_text VARCHAR2(2000) := NULL
     , token_name   VARCHAR2(30)   := NULL
     , token_value  VARCHAR2(700)   := NULL
     , translate    BOOLEAN        := FALSE
     , message_type VARCHAR2(1)    := NULL
    );

    TYPE Mesg_Token_Tbl_Type IS TABLE OF Mesg_Token_Rec_Type
            INDEX BY BINARY_INTEGER;

    /*******************************************************
     -- Increased token_value length to VARCHAR2(100) from
     -- VARCHAR2(30). This is because revised item and
     -- revised component names can be as long as 81
     -- characters.
     -- By AS on 10/22/99
    ********************************************************/
    TYPE Token_Rec_Type IS RECORD
    (  token_value VARCHAR2(700) := NULL
    ,  token_name  VARCHAR2(30)  := NULL
    ,  translate   BOOLEAN       := FALSE
    );

    TYPE Token_Tbl_Type IS TABLE OF Token_Rec_Type INDEX BY BINARY_INTEGER;

    G_MISS_TOKEN_TBL             Token_Tbl_Type;
    G_MISS_MESG_TOKEN_TBL        Mesg_Token_Tbl_Type;


     /*#
      * You can use this method to initialize the global message list and reset the index variables to 0.
      * User must initialize the message list before using it.
      * @rep:scope public
      * @rep:lifecycle active
      * @rep:compatibility S
      * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
      * @rep:displayname Initialize
      */
    PROCEDURE Initialize;

	 /*#
	 * You can use this method to reset the message index to the start of the list,as well as begin reading the
         * messages again from the start.
         * @rep:scope public
         * @rep:lifecycle active
         * @rep:compatibility S
         * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
         * @rep:displayname Reset
         */
    PROCEDURE Reset;

  /* Get procedures to access the errors in the PL/SQL stack*/
   /*#
    * You can use this method to retrieve individual messages from the message list.The method returns a
    * copy of the message list. The procedure will return a
    * the message list for the entire Business Object with the error status of the Business Object as well as
    * the error status of the Business Object for each record in the table.
    * @param x_message_list IN OUT NOCOPY  processed Message List
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:compatibility S
    * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
    * @rep:displayname Get Message List
    */
    PROCEDURE Get_Message_List
    ( x_message_list    IN OUT NOCOPY Error_Handler.Error_Tbl_Type);

   /*#
    * You can use this method to return all the messages for a specific Entity and retrieve the error
    * or warning messages,the error type,scope of the error and Other Messages which will give the
    * error status of other records due to the error in the current record.The user can get the message for
    * Bill Header,Component,Reference Desigantor or Substitute Components based on the value of entity_id
    * @param p_entity_id IN Entity for which the message to be returned
    * @param x_message_list IN OUT NOCOPY Error Message List for the Entity
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:compatibility S
    * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
    * @rep:displayname Get Entity Message
    */
    PROCEDURE Get_Entity_Message
    (  p_entity_id      IN  VARCHAR2
     , x_message_list   IN OUT NOCOPY Error_Handler.Error_Tbl_Type
    );

	/*#
     * This method will return the messages for an entity and the mesages can be specified through the
     * entity index which gives the location of the messsage in the entity array. This will give the error or warning
     * text,the error type,Other Message and the scope of the error.The user can get the messsages at any specific index
     * as specified for Bill Header,Component,Reference Designator or Substitute Component.
     * @param p_entity_id IN  Entity for which the message to be returned
     * @param p_entity_index IN Index of the Message to be returned
     * @param x_message_list IN OUT NOCOPY Error Message List for the Entity at the index
     * @rep:scope public
     * @rep:lifecycle active
     * @rep:compatibility S
     * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
     * @rep:displayname Get Message List
     */
    PROCEDURE Get_Entity_Message
    (  p_entity_id      IN  VARCHAR2
     , p_entity_index   IN  NUMBER
     , x_message_list   IN OUT NOCOPY Error_Handler.Error_Tbl_Type
     );

	 /*#
     * This method will return all the  messages for an entity and its row identifier.
     * Row Identifier is any unique identifier value for the entity record.
     * In case of bulk load from interface table this can
     * be used to store the transaction_id.
     * @param p_entity_id IN Entity for which the message to be returned
     * @param p_row_identifier IN Row Identifier for the entity
     * @param x_message_list IN OUT NOCOPY Error Message List for the Entity identified by the Row Id
     * @rep:scope public
     * @rep:lifecycle active
     * @rep:compatibility S
     * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
     * @rep:displayname Get Entity Message
     */
    PROCEDURE Get_Entity_Message
    (  p_entity_id      IN  VARCHAR2
     , p_row_identifier IN  NUMBER
     , x_message_list   IN OUT NOCOPY Error_Handler.Error_Tbl_Type
     );

	/*#
     * This method will return all the  messages for  an entity and its row identifier.
     * Row Identifier is any unique identifier value for the entity record.
     * In case of bulk load from interface table this can
     * be used to store the transaction_id.
     * @param p_entity_id IN  Entity for which the message to be returned
     * @param p_row_identifier IN Row Identifier for the entity
     * @param p_table_name IN Table Name
     * @param x_message_list IN OUT NOCOPY Error Message List for the Entity identified by the Row Id
     * @rep:scope public
     * @rep:lifecycle active
     * @rep:compatibility S
     * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
     * @rep:displayname Get Entity Message
     */
    PROCEDURE Get_Entity_Message
    (  p_entity_id      IN  VARCHAR2
     , p_table_name     IN  VARCHAR2
     , p_row_identifier IN  NUMBER
     , x_message_list   IN OUT NOCOPY Error_Handler.Error_Tbl_Type
     );


  /*#
    * You can use this method to  return the message at the current message index and  advance the pointer to the
    * next number. On retrieving the messages beyond the size of the message list,the message index
    * will be reset to the start position irrespective of the message type(like Warning,Error).
    * @param x_message_text IN OUT NOCOPY processed Message Text
    * @param x_entity_index IN OUT NOCOPY Entity Index of the message retrieved
    * @param x_entity_id IN OUT NOCOPY Entity for which the Message was retrieved
    * @param x_message_type IN OUT NOCOPY Type of the Message W-Warning/Debug,E-Standard Error/Severe Error,F-Fatal Error,U-Unexpected Error
    * @rep:scope public
    * @rep:lifecycle active
    * @rep:compatibility S
    * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
    * @rep:displayname Get Message
    */
    PROCEDURE Get_Message
    (  x_message_text   IN OUT NOCOPY VARCHAR2
     , x_entity_index   IN OUT NOCOPY NUMBER
     , x_entity_id      IN OUT NOCOPY VARCHAR2
     , x_message_type   IN OUT NOCOPY VARCHAR2
     );

	 /*#
     * This function returns the current number of records in the message list.The user can
     * use this function to get the current size of the message list.
     * @return Number of messages in the List
     * @rep:scope public
     * @rep:lifecycle active
     * @rep:compatibility S
     * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
     * @rep:displayname Get Message Count
     */

    FUNCTION Get_Message_Count RETURN NUMBER;

	   /*#
     * This method will delete a message for the particular entity specified.The entity index
     * gives the location of entity array list and the entity id will provide the specific entity object.
     * @param p_entity_id IN Entity of which the message is to be deleted
     * @param p_entity_index IN Index of the message to be deleted
     * @rep:scope public
     * @rep:lifecycle active
     * @rep:compatibility S
     * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
     * @rep:displayname Delete Message
     */

    PROCEDURE Delete_Message
    (  p_entity_id          IN  VARCHAR2
      , p_entity_index       IN  NUMBER
    );

    /*#
     * This method will delete  all the messages for the particular entity.The
     * entity is specified by the entity id.
     * @param p_entity_id IN Entity of which the message is to be deleted
     * @rep:scope public
     * @rep:lifecycle active
     * @rep:compatibility S
     * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
     * @rep:displayname Delete Message
     */

    PROCEDURE Delete_Message
    (  p_entity_id          IN  VARCHAR2 );

    /*#
     * This method will generate a dump of the message list using dbms_output.This in
     * turn calls the Write_Debug method to write the Message for an entity
     * @rep:scope public
     * @rep:displayname Dump Message List
     * @rep:compatibility S
     * @rep:lifecycle active
     * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
     */

    PROCEDURE Dump_Message_List;

     /*#
      * This method will open a debug session with the debug file name in the supplied output directory as destination.
      * It will also check the validity of the output directory and the debug file name given as input.
      * @param p_debug_filename IN Name of the file to write the debug message
      * @param p_output_dir IN Output Directory
      * @param x_return_status IN OUT NOCOPY Return Status of the Business Object
      * @param x_error_mesg IN OUT NOCOPY Error Message
      * @rep:displayname Open Debug Session
      * @rep:compatibility S
      * @rep:lifecycle active
      * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
      */
    PROCEDURE Open_Debug_Session
        (  p_debug_filename     IN  VARCHAR2
         , p_output_dir         IN  VARCHAR2
         , x_return_status      IN OUT NOCOPY VARCHAR2
         , x_error_mesg         IN OUT NOCOPY VARCHAR2
         );

     /*#
      * This method will open a debug session with the debug file name in the supplied output directory as destination.
      * It will also check the validity of the output directory and the debug file name given as input
      * @param p_debug_filename IN Name of the file to write the debug message
      * @param p_output_dir IN Output Directory
      * @param x_return_status IN OUT NOCOPY Return Status of the Business Object
      * @param p_mesg_token_tbl IN Message Token Table as input
      * @param x_mesg_token_tbl IN OUT NOCOPY processed Message Token Table
      * @rep:scope public
      * @rep:displayname Open Debug Session
      * @rep:compatibility S
      * @rep:lifecycle active
      * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
      */

    PROCEDURE Open_Debug_Session
    (  p_debug_filename IN  VARCHAR2
     , p_output_dir     IN  VARCHAR2
     , x_return_status  IN OUT NOCOPY VARCHAR2
     , p_mesg_token_tbl IN  Error_Handler.Mesg_Token_Tbl_Type
     , x_mesg_token_tbl IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
     );

     /*#
      * This method will close the debug session currently in the open state
      * @rep:scope public
      * @rep:displayname Close Debug Session
      * @rep:compatibility S
      * @rep:lifecycle active
      * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
      */
    PROCEDURE Close_Debug_Session;
    /*#
     * This method is used by the error handler to put appropriate debug comments
     * @param p_debug_message IN Debug Message to be added
     * @rep:scope public
     * @rep:displayname Write Debug
     * @rep:compatibility S
     * @rep:lifecycle active
     * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
     */

    PROCEDURE Write_Debug
    (  p_debug_message  IN  VARCHAR2
     );

	/*#
     * This method will write the errors to the Interface Table
     * This  will be effective only if the write to concurrent_log flag is properly set.
     * @rep:scope public
     * @rep:displayname Write to Interface Table
     * @rep:compatibility S
     * @rep:lifecycle active
     * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
     */
    PROCEDURE Write_To_InterfaceTable;


    /*#
     * This method will write the errors to the Concurrent Log.This
     * will be effective only if the write to concurrent_log flag is properly set.
     * @rep:scope public
     * @rep:displayname Write to Concurrent Log
     * @rep:compatibility S
     * @rep:lifecycle active
     * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
     */
    PROCEDURE Write_To_ConcurrentLog;


     /*#
     * This method will write the errors to the Debug File.This
     * will be effective only if the write to dbug_file flag is properly set.
     * @rep:scope public
     * @rep:displayname Write to Debug File
     * @rep:compatibility S
     * @rep:lifecycle active
     * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
     */
    PROCEDURE Write_To_DebugFile;


    /*#
     * This method will write the errors to Interface table or Concurrent Log or Debug File based on the Flag for each of these.
     * This will take the messages already written to the Error Handler and then will log that based on the value of the
     * flags passed.This method is useful when the user wants to Log all the errors irrespective of any particular entity.
     * @param p_write_err_to_inttable IN Flag to write error to Interface Table
     * @param p_write_err_to_conclog IN Flag to write error to Concurrent Log
     * @param p_write_err_to_debugfile IN Flag to write error to Debug File
     * @rep:scope public
     * @rep:displayname Log Error
     * @rep:compatibility S
     * @rep:lifecycle active
     * @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
     */
    PROCEDURE Log_Error(p_write_err_to_inttable   IN  VARCHAR2 := 'N'
         		,p_write_err_to_conclog   IN  VARCHAR2 := 'N'
         		,p_write_err_to_debugfile IN  VARCHAR2 := 'N');

	      /*#
	* This method takes the Message Token Table and seperates the message and their tokens, gets the
        * token substitute messages from the message dictionary and puts in the error stack.
        * Log Error will also make sure that the error propogates to the right levels of the business object
        * and that the rest of the entities get the appropriate status and message.This will log the error based on the
        * error level whether its Bill Header,Revision,Revised Components,Reference Designator,Substitute Components etc.
	* @param p_bom_header_rec IN BOM Header Exposed Column Record
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Head_Rec_Type}
	* @param p_bom_revision_tbl IN Revision Exposed Column Table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Revision_Tbl_Type}
	* @param p_bom_component_tbl IN Components Exposed Column Table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Tbl_Type}
	* @param p_bom_ref_Designator_tbl IN Reference Designator Exposed Column Table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type}
	* @param p_bom_sub_component_tbl IN Substitute Components Exposed Column Table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type}
	* @param p_Mesg_Token_tbl IN Message Token Table
	* @rep:paraminfo {@rep:innertype Error_Handler.Mesg_Token_Tbl_Type}
	* @param p_error_status IN S-Success,E-Error,F-Fatal Error,U-Enexpected Error
	* @param p_error_scope 	IN R-error affects Current Record,S-error affects Sibling and Child Records,C-error affects
	* 			Child Records,A-error affects All reords in the Business Object
	* @param p_other_message IN An Other Message is a message that is logged for all records that are affected by an
	* 			 error in a particular record.This message essentially mentions:
	*			 1. How the error has affected this record, that is, it has been errored out to
	*    			 with a severe or fatal error status, or that it has not been processed.
	* 			 2. Which record caused this record to be affected.
	* 			 3. What process flow step in the offending record caused this record to be affected.
	* 			 4. What transaction type in the offending record caused this record to be affected
	* @param p_other_mesg_appid IN Other Message Application Id
	* @param p_other_status IN Status the other affected records should be set to.
	* @param p_other_token_tbl IN Other Message Token table
	* @param p_error_level IN Business Object hierarchy level that current record is an instance of.
	* 		       That is, the entity that the record in error belongs to
	* @param p_entity_index IN The index of the entity array this record belongs to.
	* @param p_row_identifier IN Any unique identifier value for the entity record.
        * 			  In case of bulk load from interface table this can
        * 			  be used to store the transaction_id
	* @param x_bom_header_rec IN OUT NOCOPY processed BOM Header Exposed Column Record
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Bo_Pub.Bom_Head_Rec_Type}
	* @param x_bom_revision_tbl IN OUT NOCOPY processed Revision Exposed Column Table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Revision_Tbl_Type}
	* @param x_bom_component_tbl IN OUT NOCOPY processed Components Exposed Column Table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Comps_Tbl_Type}
	* @param x_bom_ref_Designator_tbl IN OUT NOCOPY processed Reference Designator Exposed Column Table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type}
	* @param x_bom_sub_component_tbl IN OUT NOCOPY processed Substitute Components Exposed Column Table
	* @rep:paraminfo {@rep:innertype Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type}
	* @rep:scope public
	* @rep:lifecycle active
	* @rep:compatibility S
	* @rep:category BUSINESS_ENTITY BOM_BILL_OF_MATERIAL
	* @rep:displayname Log Error Message
	 */


        PROCEDURE Log_Error
    (  p_bom_header_rec          IN  Bom_Bo_Pub.Bom_Head_Rec_Type :=
                                         Bom_Bo_Pub.G_MISS_BOM_HEADER_REC
     , p_bom_revision_tbl        IN  Bom_Bo_Pub.Bom_Revision_Tbl_Type :=
                                         Bom_Bo_Pub.G_MISS_BOM_REVISION_TBL
     , p_bom_component_tbl       IN  Bom_Bo_Pub.Bom_Comps_Tbl_Type :=
                                         Bom_Bo_Pub.G_MISS_BOM_COMPONENT_TBL
     , p_bom_ref_Designator_tbl  IN  Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
                                     :=  Bom_Bo_Pub.G_MISS_BOM_REF_DESIGNATOR_TBL
     , p_bom_sub_component_tbl   IN  Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
                                     :=  Bom_Bo_Pub.G_MISS_BOM_SUB_COMPONENT_TBL

     , p_Mesg_Token_tbl          IN  Error_Handler.Mesg_Token_Tbl_Type
                                     := Error_Handler.G_MISS_MESG_TOKEN_TBL
     , p_error_status            IN  VARCHAR2
     , p_error_scope             IN  VARCHAR2 := NULL
     , p_other_message           IN  VARCHAR2 := NULL
     , p_other_mesg_appid        IN  VARCHAR2 := 'BOM'
     , p_other_status            IN  VARCHAR2 := NULL
     , p_other_token_tbl         IN  Error_Handler.Token_Tbl_Type
                                     := Error_Handler.G_MISS_TOKEN_TBL
     , p_error_level             IN  NUMBER
     , p_entity_index            IN  NUMBER := 1  -- := NULL
     , x_bom_header_rec          IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Rec_Type
     , x_bom_revision_tbl        IN OUT NOCOPY Bom_Bo_Pub.Bom_Revision_Tbl_Type
     , x_bom_component_tbl       IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Tbl_Type
     , x_bom_ref_Designator_tbl  IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
     , x_bom_sub_component_tbl   IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
     , p_row_identifier           IN NUMBER := NULL
    );





        /****************************************************************
        * Procedure     : Add_Message
        *
        * Paramaters IN : Message Text
        *                 For explanation on entity id, entity index,
        *                 message type,row identifier, table name,
        *                 entity code parameters please refer to
        *                 Add_Error_Message API
        *
        * Parameters OUT: None
        * Purpose       : Add_Message will push a message on the message
        *                 stack and will convert the numeric entity id to
        *                 character which will be easier for the user to
        *                 understand. eg. Entity Id = 1 which will be ECO
        *****************************************************************/

    PROCEDURE Add_Message
        (  p_mesg_text          IN  VARCHAR2
         , p_entity_id          IN  NUMBER
         , p_entity_index       IN  NUMBER
         , p_message_type       IN  VARCHAR2
         , p_row_identifier     IN  NUMBER := NULL
         , p_table_name         IN  VARCHAR2 := NULL
         , p_entity_code        IN  VARCHAR2 := NULL
         , p_mesg_name		IN  VARCHAR2 := NULL
    );

   /* Fix for bug 4661753 - Added a new parameter p_mesg_name to both the Add_message procedure declarations above and below.*/

  -- Bug 3458584  added new method


    PROCEDURE Add_Message
        (  p_mesg_text          IN  VARCHAR2
         , p_entity_id          IN  NUMBER
         , p_entity_index       IN  NUMBER
         , p_message_type       IN  VARCHAR2
         , p_row_identifier     IN  NUMBER := NULL
         , p_table_name         IN  VARCHAR2 := NULL
         , p_entity_code        IN  VARCHAR2 := NULL
         , p_mesg_name		IN  VARCHAR2 := NULL
         , p_bom_header_rec          IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Rec_Type
         , p_bom_revision_tbl        IN OUT NOCOPY Bom_Bo_Pub.Bom_Revision_Tbl_Type
         , p_bom_component_tbl       IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Tbl_Type
         , p_bom_ref_Designator_tbl  IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
         , p_bom_sub_component_tbl   IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
         , p_bom_comp_ops_tbl   IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_ops_Tbl_Type
    );



        /*********************************************************************
        * Procedure     : Translate_And_Insert_Messages
        * Returns       : None
        * Parameters IN : Message Token Table
        *                 Error Level
        *                       The entity level at which the error has
        *                       occured.This is same as entity id in the
        *                       other procedures (Add_Message, Add_Error_Message)
        *                 For explanation on entity id, entity index,
        *                 message type,row identifier, table name,
        *                 entity code parameters please refer to
        *                 Add_Error_Message API
        * Parameters OUT: Non
        * Purpose       : This procedure will read through the message token
        *                 table and insert them into the message table with
        *                 the proper business object context.
        **********************************************************************/

    PROCEDURE Translate_And_Insert_Messages
    (  p_mesg_token_tbl IN Error_Handler.Mesg_Token_Tbl_Type
     , p_error_level    IN NUMBER := NULL
     , p_entity_index   IN NUMBER := NULL
     , p_application_id IN VARCHAR2 := 'ENG'
     , p_row_identifier IN NUMBER := NULL
     , p_table_name     IN VARCHAR2 := NULL
     , p_entity_code    IN VARCHAR2 := NULL
    );

 -- Bug 3458584  added new method

    PROCEDURE Translate_And_Insert_Messages
    (  p_mesg_token_tbl IN Error_Handler.Mesg_Token_Tbl_Type
     , p_error_level    IN NUMBER := NULL
     , p_entity_index   IN NUMBER := NULL
     , p_application_id IN VARCHAR2 := 'ENG'
     , p_row_identifier IN NUMBER := NULL
     , p_table_name     IN VARCHAR2 := NULL
     , p_entity_code    IN VARCHAR2 := NULL
     , p_bom_header_rec          IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Rec_Type
     , p_bom_revision_tbl        IN OUT NOCOPY Bom_Bo_Pub.Bom_Revision_Tbl_Type
     , p_bom_component_tbl       IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Tbl_Type
     , p_bom_ref_Designator_tbl  IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
     , p_bom_sub_component_tbl   IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
     , p_bom_comp_ops_tbl        IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type
    );



        /*********************************************************************
        * Function      : Translate_Message
        * Returns       : VARCHAR2 (Translated Message)
        * Parameters IN : Application id
        *                 Message Name
        *                 Token Table
        * Parameters OUT: Translated Message
        **********************************************************************/

    FUNCTION Translate_Message (p_application_id  IN VARCHAR2
                               ,p_message_name    IN VARCHAR2
                               ,p_token_tbl       IN Error_Handler.Token_Tbl_Type :=
							Error_Handler.G_MISS_TOKEN_TBL)
    RETURN VARCHAR2;

        /**********************************************************************
        * Procedure     : Add_Error_Token
        * Parameters IN : Message Text (in case of unexpected errors)
        *                 Message Name
        *                 Mesg Token Tbl
        *                 Token Table
        * Parameters OUT: Mesg Token Table
        * Purpose       : This procedure will add the message to the
        *                 message token table.
        **********************************************************************/

    PROCEDURE Add_Error_Token
        (  p_message_name      IN  VARCHAR2 := NULL
         , p_application_id    IN  VARCHAR2 := 'ENG'
         , p_message_text      IN  VARCHAR2 := NULL
         , x_Mesg_Token_tbl    IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , p_Mesg_Token_Tbl    IN  Error_Handler.Mesg_Token_Tbl_Type :=
                   Error_Handler.G_MISS_MESG_TOKEN_TBL
         , p_token_tbl         IN  Error_Handler.Token_Tbl_Type :=
                   Error_Handler.G_MISS_TOKEN_TBL
         , p_message_type      IN  VARCHAR2 := 'E'
    );

        /**********************************************************************
        * Procedure     : Add_Error_Message
        * Parameters IN : Message Text (in case of unexpected errors)
        *                       Free text
        *                 Message Name
        *                       FND message name
        *                 Application Id
        *                       Applicaion short name under which the
        *                       message is defined
        *                 Token Table
        *                       Token Table of type TOKEN_TBL_TYPE
        *                 Message Type
        *                       W -> Warning
        *                       E -> Error
        *                 Entity Id
        *                       Entity identifier which is defined as a
        *                       constant in the error handler
        *                 Entity Index
        *                       The order of the entity record within
        *                       the entity table
        *                 Entity Code
        *                       Replacement for entity id. This can be
        *                       used when there is no constant defined
        *                       in the error handler for the entity.
        *                       When both are passed entity code will be
        *                       used as entity identifier.
        *                 Row Identifier
        *                       Any unique identifier value for the entity record.
        *                       In case of bulk load from interface table this can
        *                       be used to store the transaction_id
        *                 Table Name
        *                       Production table name where the data goes in.
        *                       This is useful when the same logical entity deals
        *                       with multiple tables.
        *                       A typical example would be extensible attributes for an
        *                       entity. Logically, the entity is same but the data is
        *                       going into two tables (ex: BOM_BILL_OF_MATERIALS and
        *                       BOM_BILL_OF_MATERIALS_EXT)
        *
        * Parameters OUT: None
        * Purpose       : This procedure will translate and add the message directly into
        *                 the error stack with all the context information.
        **********************************************************************/

    PROCEDURE Add_Error_Message
        (  p_message_name      IN  VARCHAR2 := NULL
         , p_application_id    IN  VARCHAR2 := 'BOM'
         , p_message_text      IN  VARCHAR2 := NULL
         , p_token_tbl         IN  Error_Handler.Token_Tbl_Type :=
                   Error_Handler.G_MISS_TOKEN_TBL
         , p_message_type      IN  VARCHAR2 := 'E'
	 , p_row_identifier    IN  NUMBER := NULL
	 , p_entity_id         IN  NUMBER := NULL
 	 , p_entity_index      IN  NUMBER := NULL
	 , p_table_name        IN  VARCHAR2 := NULL
	 , p_entity_code       IN  VARCHAR2 := NULL
	 , p_addto_fnd_stack   IN  VARCHAR2 := 'N'
    );

 -- Bug 3458584  added new method


 PROCEDURE Add_Error_Message
        (  p_message_name      IN  VARCHAR2 := NULL
         , p_application_id    IN  VARCHAR2 := 'BOM'
         , p_message_text      IN  VARCHAR2 := NULL
         , p_token_tbl         IN  Error_Handler.Token_Tbl_Type :=
                   Error_Handler.G_MISS_TOKEN_TBL
         , p_message_type      IN  VARCHAR2 := 'E'
         , p_row_identifier    IN  NUMBER := NULL
         , p_entity_id         IN  NUMBER := NULL
         , p_entity_index      IN  NUMBER := NULL
         , p_table_name        IN  VARCHAR2 := NULL
         , p_entity_code       IN  VARCHAR2 := NULL
         , p_addto_fnd_stack   IN  VARCHAR2 := 'N'
         , p_bom_header_rec          IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Rec_Type
         , p_bom_revision_tbl        IN OUT NOCOPY Bom_Bo_Pub.Bom_Revision_Tbl_Type
         , p_bom_component_tbl       IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Tbl_Type
         , p_bom_ref_Designator_tbl  IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
         , p_bom_sub_component_tbl   IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
         , p_bom_comp_ops_tbl         IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type
       );






    PROCEDURE Get_Entity_Message
    (  p_entity_id      IN  VARCHAR2
     , p_entity_index   IN  NUMBER
     , x_message_text   IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2
     );

    PROCEDURE Set_Bo_Identifier(p_bo_identifier	IN VARCHAR2);
    FUNCTION  Get_Bo_Identifier RETURN VARCHAR2;

    /* One to many operations support */

    PROCEDURE Set_Bom_Specific( p_bom_comp_ops_tbl IN  Bom_Bo_Pub.Bom_Comp_Ops_Tbl_type);

    PROCEDURE Get_Bom_Specific( x_bom_comp_ops_tbl IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Tbl_type);


    PROCEDURE Set_Debug (p_debug_flag IN VARCHAR2 := 'N');

   FUNCTION Get_Debug RETURN VARCHAR2;

   PROCEDURE Set_BOM_OI;
   PROCEDURE UnSet_BOM_OI;

END Error_Handler;

 

/
