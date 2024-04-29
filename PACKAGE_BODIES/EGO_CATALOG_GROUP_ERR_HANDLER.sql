--------------------------------------------------------
--  DDL for Package Body EGO_CATALOG_GROUP_ERR_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_CATALOG_GROUP_ERR_HANDLER" AS
/* $Header: EGOCGEHB.pls 115.1 2002/12/12 19:21:16 rfarook noship $ */
/*************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EGOCGEHB.pls
--
--  DESCRIPTION
--
--      Body of package EGO_Catalog_Group_Err_Handler
--
--  NOTES
--
--  HISTORY
--
--  21-SEP-2002 Rahul Chitko        Initial Creation
--
*************************************************************************/


        /******************************************************************
        * Procedure     : Log_Error
        * Parameters IN : Message Token Table
        *                 Other Message Table
        *                 Other Status
        *                 Entity Index
        *                 Error Level
        *                 Error Scope
        *                 Error Status
        * Parameters OUT:
        * Purpose       : Log Error will take the Message Token Table and
        *                 seperate the message and their tokens, get the
        *                 token substitute messages from the message dictionary
        *                 and put in the error stack.
        *                 Log Error will also make sure that the error
        *                 propogates to the right level's of the business object
        *                 and that the rest of the entities get the appropriate
        *                 status and message.
        ******************************************************************/

        PROCEDURE Log_Error
	(  p_Mesg_Token_tbl          IN  Error_Handler.Mesg_Token_Tbl_Type
                                          := Error_Handler.G_MISS_MESG_TOKEN_TBL
         , p_error_status            IN  VARCHAR2
         , p_error_scope             IN  VARCHAR2 := NULL
         , p_other_message           IN  VARCHAR2 := NULL
         , p_other_mesg_appid        IN  VARCHAR2 := 'EGO'
         , p_other_status            IN  VARCHAR2 := NULL
         , p_other_token_tbl         IN  Error_Handler.Token_Tbl_Type
                                          := Error_Handler.G_MISS_TOKEN_TBL
         , p_error_level             IN  NUMBER
         , p_entity_index            IN  NUMBER := 1 -- := NULL
         )
        IS
                l_message_name          VARCHAR2(30);
                l_other_message         VARCHAR2(2000);
                l_message_text          VARCHAR2(2000);
                l_LoopIndex             NUMBER;
                l_Error_Level           NUMBER      := p_Error_Level;
                l_error_scope           VARCHAR2(1) := p_error_scope;
                l_error_status          VARCHAR2(1) := p_error_status;
                l_application_id        VARCHAR2(3);
        BEGIN

                l_application_id :=  p_other_mesg_appid;


                /*************************************************
                --
                -- Seperate message and their tokens, get the
                -- token substituted messages and put it in the
                -- Error Table.
                --
                **************************************************/

		Error_Handler.Write_Debug('Within the Log Error Procedure . . .');
		Error_Handler.Write_Debug('Scope: ' || l_error_scope);
		Error_Handler.Write_Debug('Entity Index: ' || to_char(p_entity_index));
		Error_Handler.Write_Debug('Error Level: ' || to_char(p_error_level));
		Error_Handler.Write_Debug('Error Status: ' || l_error_status);
		Error_Handler.Write_Debug('Other Status: ' || p_other_status);
		Error_Handler.Write_Debug('Other Message: ' || p_other_message);

                Error_Handler.Translate_And_Insert_Messages
                (  p_mesg_token_Tbl     => p_mesg_token_tbl
                 , p_error_level        => p_error_level
                 , p_entity_index       => p_entity_index
                );

		Error_Handler.Write_Debug('Finished logging messages . . . ');

                /**********************************************************
                --
                -- Get the other message text and token and retrieve the
                -- token substituted message.
                --
                ***********************************************************/

                IF p_other_token_tbl.COUNT <> 0
                THEN
                        fnd_message.set_name
                        (  application  => l_application_id
                         , name         => p_other_message
                         );

                        FOR l_LoopIndex IN 1 .. p_other_token_tbl.COUNT
                        LOOP
                                IF p_other_token_tbl(l_LoopIndex).token_name IS
                                   NOT NULL
                                THEN
                                   fnd_message.set_token
                                   ( token  =>
                                      p_other_token_tbl(l_LoopIndex).token_name
                                    , value =>
                                      p_other_token_tbl(l_LoopIndex).token_value
                                    , translate   =>
                                      p_other_token_tbl(l_LoopIndex).translate
                                    );
                                END IF;
                        END LOOP;

                        l_other_message := fnd_message.get;

                ELSE
                        fnd_message.set_name
                        (  application  => l_application_id
                         , name         => p_other_message
                         );

                        l_other_message := fnd_message.get;

                END IF; -- Other Token Tbl Count <> 0 Ends

		Error_Handler.Write_Debug('Finished extracting other message . . . ');
		Error_Handler.Write_Debug('Other Message generated: ' || l_other_message);


                /**********************************************************
                --
                -- If the Error Level is Business Object
                -- then set the Error Level = Catalog Group
                --
                ************************************************************/
                IF l_error_level = Error_Handler.G_BO_LEVEL
                THEN
                        l_error_level := EGO_Globals.G_ITEM_CATALOG_GROUP_LEVEL;

			Error_Handler.Write_Debug('Error Level is Business Object . . . ');

                END IF;
                /**********************************************************
                --
                -- If the error_status is UNEXPECTED then set the error scope
                -- to ALL, if WARNING then set the scope to RECORD.
                --
                ************************************************************/
                IF l_error_status = Error_Handler.G_STATUS_UNEXPECTED
                THEN
			Error_Handler.Write_Debug('Status unexpected and scope is All . . .');
                        l_error_scope := Error_Handler.G_SCOPE_ALL;
                ELSIF l_error_status = Error_Handler.G_STATUS_WARNING
                THEN
                        l_error_scope := Error_Handler.G_SCOPE_RECORD;
                        l_error_status := FND_API.G_RET_STS_SUCCESS;
                        Error_Handler.Write_Debug('Status is warning . . .');

                END IF;

                --
                -- If the Error Level is Bill Header, then the scope can be
                -- ALL/CHILDREN OR RECORD.
                --
                /*************************************************************
                --
                -- If the Error Level is CATALOG_GROUP
                --
                *************************************************************/
                IF l_error_level = EGO_Globals.G_ITEM_CATALOG_GROUP_LEVEL
                THEN

                       Error_Handler.Write_Debug('Error Level is Catalog Group. . .');

                        --
                        -- Set the Bill Header record status to p_error_status
                        -- This will also take care of the scope RECORD.
                        --

			EGO_Globals.G_Catalog_Group_Rec.return_status := l_error_status;

                        IF l_error_scope = error_handler.G_SCOPE_ALL OR
                           l_error_scope = error_handler.G_SCOPE_CHILDREN OR
			   l_error_scope = error_handler.G_SCOPE_SIBLINGS
                        THEN
                                --
                                -- Since catalog group entity does not have children all error scopes will
				-- affect only the current record.
				--
				null;
                        END IF;
		END IF;

		Error_Handler.Write_To_DebugFile;

        END Log_Error;


END EGO_Catalog_Group_Err_Handler;

/
