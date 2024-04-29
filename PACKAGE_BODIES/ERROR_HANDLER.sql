--------------------------------------------------------
--  DDL for Package Body ERROR_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ERROR_HANDLER" AS
/* $Header: BOMBOEHB.pls 120.5 2006/09/14 16:09:39 pdutta ship $ */
/*************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMBOEHB.pls
--
--  DESCRIPTION
--
--      Body of package Error_Handler
--
--  NOTES
--
--  HISTORY
--
--  21-JUL-1999 Rahul Chitko        Initial Creation
--
--  23-Aug-2000 Masanori Kimizuka   Enhacement for Routing BO.
--                                  Added constant variables and Log_Error
--                                  procedure for Routing BO.
--
--  23-AUG-01   Refai Farook        One To Many operations support changes
--
--  09-SEP-02   Refai Farook        Changes to the Add_Message procedure to default
--                                  the Row_Identifier value for BOM BO

--  24-SEP-02   Refai Farook        Modified the process logic of Add_Error_Token,
--				    Translate_Insert_Message procedures.
--				    Implemented Add_Error_Message procedure.
--				    Added support to write the errors into interface,
--				    conc.log and to debug file.
--
--  22-NOV-2002 Phani Pilli         Enhancement to support BOM Open Interface
*************************************************************************/
      --  g_bom_header_rec         Bom_Bo_Pub.Bom_Head_Rec_Type;
      --  g_bom_revision_tbl       Bom_Bo_Pub.Bom_Revision_Tbl_Type;
      --  g_bom_component_tbl      Bom_Bo_Pub.Bom_Comps_Tbl_Type;
      --  g_bom_ref_designator_tbl Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type;
      --  g_bom_sub_component_tbl  Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type;
        g_bom_comp_ops_tbl       Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type;

        G_ERROR_TABLE           Error_Handler.Error_Tbl_Type;
        G_Msg_Index             NUMBER := 0;
        G_Msg_Count             NUMBER := 0;

	G_BO_IDENTIFIER		VARCHAR2(30) := 'BOM';

	g_debug_flag		VARCHAR2(1) := 'N';

        /****************************************************************
        * Procedure     : Add_Message
	*
        * Paramaters IN : Message Text
	*		  For explanation on entity id, entity index,
	*		  message type,row identifier, table name,
	*		  entity code parameters please refer to
	*		  Add_Error_Message API
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
          , p_mesg_name		       IN  VARCHAR2 := NULL
        ) IS
   Begin
         Add_Message
         (  p_mesg_text
          , p_entity_id
          , p_entity_index
          , p_message_type
          , p_row_identifier
          , p_table_name
          , p_entity_code
          , p_mesg_name
          , Bom_Bo_Pub.G_MISS_BOM_HEADER_REC
          , Bom_Bo_Pub.G_MISS_BOM_REVISION_TBL
          , Bom_Bo_Pub.G_MISS_BOM_COMPONENT_TBL
          , Bom_Bo_Pub.G_MISS_BOM_REF_DESIGNATOR_TBL
          , Bom_Bo_Pub.G_MISS_BOM_SUB_COMPONENT_TBL
          , Bom_Bo_Pub.G_MISS_BOM_COMP_OPS_TBL
         );

        END;



        PROCEDURE Add_Message
        (  p_mesg_text          IN  VARCHAR2
         , p_entity_id          IN  NUMBER
         , p_entity_index       IN  NUMBER
         , p_message_type       IN  VARCHAR2
         , p_row_identifier     IN  NUMBER   := NULL
         , p_table_name         IN  VARCHAR2 := NULL
         , p_entity_code        IN  VARCHAR2 := NULL
         , p_mesg_name		      IN  VARCHAR2 := NULL
         , p_bom_header_rec          IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Rec_Type
         , p_bom_revision_tbl        IN OUT NOCOPY Bom_Bo_Pub.Bom_Revision_Tbl_Type
         , p_bom_component_tbl       IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Tbl_Type
         , p_bom_ref_Designator_tbl  IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
         , p_bom_sub_component_tbl   IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
         , p_bom_comp_ops_tbl        IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type
       )
        IS
                l_Idx                   BINARY_INTEGER;
                l_entity_id_char        VARCHAR2(30) := null;
		l_row_identifier	NUMBER       := null;
    l_table_name		VARCHAR2(30);


        BEGIN

                l_Idx := G_ERROR_TABLE.COUNT;

		IF p_entity_code IS NOT NULL
		THEN

		    /* Add_Error_Message (mainly used by other applications) will always
		       pass the entity code. If entity code is passed, it takes precedence
		       over the entity id */
                    l_entity_id_char := p_entity_code;

                ELSIF p_entity_id = G_BO_LEVEL
                THEN
                        l_entity_id_char := 'BO';
                ELSIF p_entity_id = G_ECO_LEVEL
                THEN
                        l_entity_id_char := 'ECO';
                ELSIF p_entity_id = G_REV_LEVEL
                THEN
                        l_entity_id_char := 'REV';
                ELSIF p_entity_id = G_RI_LEVEL
                THEN
                        l_entity_id_char := 'RI';
                ELSIF p_entity_id = G_RC_LEVEL
                THEN
                        l_entity_id_char := 'RC';
                ELSIF p_entity_id = G_RD_LEVEL
                THEN
                        l_entity_id_char := 'RD';
                ELSIF p_entity_id = G_SC_LEVEL
                THEN
                        l_entity_id_char := 'SC';
                ELSIF p_entity_id = G_BH_LEVEL
                THEN
                        l_entity_id_char := 'BH';
		/* One to many support */
                ELSIF p_entity_id = G_COP_LEVEL
                THEN
                        l_entity_id_char := 'COP';
                /**********************************
                -- Followings are for Routing BO
                ***********************************/
                ELSIF p_entity_id = G_RTG_LEVEL
                THEN
                    l_entity_id_char := 'RTG';
                ELSIF p_entity_id = G_OP_LEVEL
                THEN
                    l_entity_id_char := 'OP';
                ELSIF p_entity_id = G_RES_LEVEL
                THEN
                    l_entity_id_char := 'RES';
                ELSIF p_entity_id = G_SR_LEVEL
                THEN
                    l_entity_id_char := 'SR';
                ELSIF p_entity_id = G_NWK_LEVEL
                THEN
                    l_entity_id_char := 'NWK';
                -- Added by MK on 08/23/2000
                ELSIF p_entity_id = G_ATCH_LEVEL
                THEN
                    l_entity_id_char := 'ATCH';
                END IF;

		IF p_row_identifier IS NOT NULL
		THEN

		  /* if row identifier is passed, use it */
		  l_row_identifier := p_row_identifier;

		ELSE

		  /* if the row identifier is not passed, then do the defaulting (only for BOM BO)*/

		  IF Get_BO_Identifier = 'BOM'
		  THEN
		    IF p_entity_id IN (G_BO_LEVEL,G_BH_LEVEL)
		    THEN
                        l_row_identifier := p_bom_header_rec.row_identifier;
                    ELSIF p_entity_id = G_REV_LEVEL
		    THEN
                        l_row_identifier := p_bom_revision_tbl(p_entity_index).row_identifier;
                    ELSIF p_entity_id = G_RC_LEVEL
		    THEN
                        l_row_identifier := p_bom_component_tbl(p_entity_index).row_identifier;
                    ELSIF p_entity_id = G_RD_LEVEL
		    THEN
                        l_row_identifier := p_bom_ref_designator_tbl(p_entity_index).row_identifier;
                    ELSIF p_entity_id = G_SC_LEVEL
		    THEN
                        l_row_identifier := p_bom_sub_component_tbl(p_entity_index).row_identifier;
                    ELSIF p_entity_id = G_COP_LEVEL
		    THEN
			l_row_identifier := p_bom_comp_ops_tbl(p_entity_index).row_identifier;
		    END IF;
		  END IF;
		END IF;

    	/* Fix for bug 4652785 - If table_name is passed as a parameter then use it.
		   Otherwise populate the table_name based on the entity_id. */

		l_table_name :=null;

		IF p_table_name IS NOT NULL
		THEN
                l_table_name := p_table_name;
                /**********************************
                -- Followings are for Bills BO
                ***********************************/
                ELSIF p_entity_id =G_BH_LEVEL
                THEN
                        l_table_name := 'BOM_BILL_OF_MTLS_INTERFACE';
                ELSIF p_entity_id = G_RC_LEVEL
                THEN
                        l_table_name  := 'BOM_INVENTORY_COMPS_INTERFACE';
                ELSIF p_entity_id = G_RD_LEVEL
                THEN
                        l_table_name  := 'BOM_REF_DESGS_INTERFACE';
                ELSIF p_entity_id = G_SC_LEVEL
                THEN
                        l_table_name  := 'BOM_SUB_COMPS_INTERFACE';
                ELSIF p_entity_id = G_COP_LEVEL
                THEN
                        l_table_name  := 'BOM_COMP_OPS_INTERFACE';
                /**********************************
                -- Followings are for Routing BO
                ***********************************/
                ELSIF p_entity_id = G_RTG_LEVEL
                THEN
                    l_table_name  := 'BOM_OP_ROUTINGS_INTERFACE';
                ELSIF p_entity_id = G_OP_LEVEL
                THEN
                    l_table_name  := 'BOM_OP_SEQUENCES_INTERFACE';
                ELSIF p_entity_id = G_RES_LEVEL
                THEN
                    l_table_name  := 'BOM_OP_RESOURCES_INTERFACE';
                ELSIF p_entity_id = G_SR_LEVEL
                THEN
                    l_table_name  := 'BOM_SUB_OP_RESOURCES_INTERFACE';
                ELSIF p_entity_id = G_NWK_LEVEL
                THEN
                    l_table_name  := 'BOM_OP_NETWORKS_INTERFACE';
                /**************************************
                -- Followings are for common entities
                **************************************/
                ELSIF p_entity_id = G_REV_LEVEL
                THEN
                  IF Get_BO_Identifier = 'BOM' THEN
                                l_table_name  := 'MTL_ITEM_REVISIONS_INTERFACE';
                  ELSIF Get_BO_Identifier = 'RTG' THEN
                                l_table_name  := 'MTL_RTG_ITEM_REVS_INTERFACE';
                  ELSIF Get_BO_Identifier = 'ECO' THEN
                                l_table_name  := 'ENG_ECO_REVISIONS_INTERFACE';
                  END IF;

                /* bug:5260316 Default table names for ECO BO*/
                /**********************************
                -- Following are for ECO BO
                ***********************************/
                ELSIF p_entity_id = G_ECO_LEVEL
                THEN
                  l_table_name  := 'ENG_ENG_CHANGES_INTERFACE';
                ELSIF p_entity_id = G_RI_LEVEL
                THEN
                  l_table_name  := 'ENG_REVISED_ITEMS_INTERFACE';
                ELSIF p_entity_id = G_CL_LEVEL
                THEN
                  l_table_name  := 'ENG_CHANGE_LINES_INTERFACE';

    END IF;
		/* End of fix for bug 4652785*/


		Error_Handler.Write_Debug('Entity Id: ' || l_entity_id_char);

                G_ERROR_TABLE(l_Idx + 1).message_text   := p_mesg_text;
                G_ERROR_TABLE(l_idx + 1).entity_id      := l_entity_id_char;
                G_ERROR_TABLE(l_idx + 1).entity_index   := p_entity_index;
                G_ERROR_TABLE(l_idx + 1).message_type   := p_message_type;
                G_ERROR_TABLE(l_Idx + 1).row_identifier := l_row_identifier;
                G_ERROR_TABLE(l_Idx + 1).table_name     := l_table_name;/*Fix for bug 4652785-Replaced p_table_name with l_table_name*/
                G_ERROR_TABLE(l_Idx + 1).bo_identifier  :=
                                        Error_Handler.Get_Bo_Identifier;
                G_ERROR_TABLE(l_Idx + 1).message_name   := p_mesg_name;
		/* Fix for bug 4620997 - Populate message_name in the G_ERROR_TABLE above. */

                -- Increment the message counter to keep a tally.

                G_Msg_Count := G_Error_Table.Count;

		Error_Handler.Write_Debug('Message Count on this point : ' || to_char(G_Msg_Count));

        END Add_Message;

        /******************************************************************
        * Procedure     : setCompOperations (Unexposed)
        * Parameters    : Other Message
        *                 Other Status
        *                 Error Scope
        *                 Revised Component Index
        *                 Component Operation entity Index
        * Purpose       : This procedure will set the component operation
        *                 record status to other status by looking at the
        *                 revised item key or the revised component key or
        *                 else setting all the record status to other status
        ********************************************************************/
        /*Fix for bug 4661753 - Added a new parameter p_other_mesg_name to the procedure below.*/
        PROCEDURE setCompOperations
        (  p_error_scope        IN  VARCHAR2
         , p_other_mesg_text    IN  VARCHAR2
         , p_other_status       IN  VARCHAR2
         , p_rc_idx             IN  NUMBER := 0
         , p_entity_index       IN  NUMBER := 0
         , p_other_mesg_name	IN  VARCHAR2 := NULL
         , p_bom_header_rec          IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Rec_Type
         , p_bom_revision_tbl        IN OUT NOCOPY Bom_Bo_Pub.Bom_Revision_Tbl_Type
         , p_bom_component_tbl       IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Tbl_Type
         , p_bom_ref_Designator_tbl  IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
         , p_bom_sub_component_tbl   IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
         , p_bom_comp_ops_tbl         IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type
        )
        IS
        BEGIN

	     Error_Handler.Write_Debug('Setting component operation records to ' || p_other_status);

             IF p_error_scope = G_SCOPE_ALL
             THEN
                FOR l_idx IN 1..p_bom_comp_ops_tbl.COUNT
                LOOP
                        p_bom_comp_ops_tbl(l_idx).return_status :=
                                        p_other_status;
                        IF p_other_mesg_text IS NOT NULL
                        THEN
                          /* Fix for bug 4661753 - added p_mesg_name to the call to Add_message procedure below. */
                                Add_Message
                                (  p_mesg_text  => p_other_mesg_text
                                , p_entity_id   => G_COP_LEVEL
                                , p_entity_index=> l_idx
                                , p_message_type=> 'E'
                                , p_mesg_name   => p_other_mesg_name
		                            , p_bom_header_rec         =>p_bom_header_rec
                                , p_bom_revision_tbl  =>p_bom_revision_tbl
                                , p_bom_component_tbl    =>p_bom_component_tbl
                                , p_bom_ref_Designator_tbl =>p_bom_ref_Designator_tbl
                                , p_bom_sub_component_tbl =>p_bom_sub_component_tbl
                                , p_bom_comp_ops_tbl =>p_bom_comp_ops_tbl
                                );
                        END IF;
                END LOOP;
             ELSIF p_error_scope = G_SCOPE_CHILDREN AND
                   p_rc_idx <> 0
             THEN

                Error_Handler.Write_Debug('Scope=Children in Component Operation');
                Error_Handler.Write_Debug('Inventory Component index <> 0');

                FOR l_idx IN 1..p_bom_comp_ops_tbl.COUNT
                LOOP
                    IF NVL(p_bom_comp_ops_tbl(l_idx).component_item_name, ' ')=
                       NVL(p_bom_component_tbl(p_rc_idx).component_item_name,' '
                          ) AND
                       NVL(p_bom_comp_ops_tbl(l_idx).start_effective_date,
                           SYSDATE ) =
                       NVL(p_bom_component_tbl(p_rc_idx).start_effective_date,
                           SYSDATE )
                       AND
                       NVL(p_bom_comp_ops_tbl(l_idx).operation_sequence_number,
                           0) =
                       NVL(p_bom_component_tbl(p_rc_idx).operation_sequence_number, 0)
                       AND
                       NVL(p_bom_comp_ops_tbl(l_idx).organization_code, ' ') =
                       NVL(p_bom_component_tbl(p_rc_idx).organization_code, ' ')
                    THEN

                        p_bom_comp_ops_tbl(l_idx).return_status :=
                                                p_other_status;
                        /* Fix for bug 4661753 - added p_mesg_name to the call to Add_message procedure below. */
                          Add_Message
                          (  p_mesg_text          => p_other_mesg_text
                           , p_entity_id          => G_COP_LEVEL
                           , p_entity_index       => l_idx
                           , p_message_type       => 'E'
                           , p_mesg_name          => p_other_mesg_name
                           , p_bom_header_rec     => p_bom_header_rec
                           , p_bom_revision_tbl  =>p_bom_revision_tbl
                           , p_bom_component_tbl    =>p_bom_component_tbl
                           , p_bom_ref_Designator_tbl =>p_bom_ref_Designator_tbl
                           , p_bom_sub_component_tbl =>p_bom_sub_component_tbl
                           , p_bom_comp_ops_tbl =>p_bom_comp_ops_tbl
                          );
                    END IF;
                END LOOP;  -- Ref. Desg Children of Rev Comps Ends.

             ELSIF p_error_scope = G_SCOPE_SIBLINGS AND
                   p_rc_idx = 0
             THEN
                --
                -- This situation will arise when inventory comp is
                -- not part of the business object input data.
                -- Match the component key information at the entity index
                -- location with rest of the records, all those that are found
                -- will be siblings and should get an error.
                --
                Error_Handler.Write_Debug('Scope=Siblings in Component Operation');
                Error_Handler.Write_Debug('All entity indexes = 0');


                FOR l_idx IN (p_entity_index+1)..p_bom_comp_ops_tbl.COUNT
                LOOP
                    IF NVL(p_bom_comp_ops_tbl(l_idx).component_item_name, ' ') =
                       NVL(p_bom_comp_ops_tbl(p_entity_index).component_item_name, ' ')
                       AND
                       NVL(p_bom_comp_ops_tbl(l_idx).start_effective_date, SYSDATE) =
                       NVL(p_bom_comp_ops_tbl(p_entity_index).start_effective_date, SYSDATE)
                       AND
                       NVL(p_bom_comp_ops_tbl(l_idx).operation_sequence_number, 0) =
                       NVL(p_bom_comp_ops_tbl(p_entity_index).operation_sequence_number, 0)
                       AND
                       NVL(p_bom_comp_ops_tbl(l_idx).organization_code, ' ') =
                       NVL(p_bom_comp_ops_tbl(p_entity_index).organization_code, ' ')
                    THEN
                        p_bom_comp_ops_tbl(l_idx).return_status :=
                                                p_other_status;
                        /* Fix for bug 4661753 - added p_mesg_name to the call to Add_message procedure below. */
                          Add_Message
                          (  p_mesg_text          => p_other_mesg_text
                           , p_entity_id          => G_COP_LEVEL
                           , p_entity_index       => l_idx
                           , p_message_type       => 'E'
                           , p_mesg_name          => p_other_mesg_name
                           , p_bom_header_rec         =>p_bom_header_rec
                           , p_bom_revision_tbl  =>p_bom_revision_tbl
                           , p_bom_component_tbl    =>p_bom_component_tbl
                           , p_bom_ref_Designator_tbl =>p_bom_ref_Designator_tbl
                           , p_bom_sub_component_tbl =>p_bom_sub_component_tbl
                           , p_bom_comp_ops_tbl =>p_bom_comp_ops_tbl
                          );
                    END IF;
                END LOOP;
             END IF; -- If Scope = Ends.

        END setCompOperations;

        /******************************************************************
        * Procedure     : setSubComponents (Unexposed)
        * Parameters    : Other Message
        *                 Other Status
        *                 Error Scope
        *                 Revised Item Index
        *                 Revised Component Index
        *                 Reference Designator Index
        * Purpose       : This procedure will set the reference designator
        *                 record status to other status by looking at the
        *                 revised item key or the revised component key or
        *                 else setting all the record status to other status
        ********************************************************************/
        /* Fix for bug 4661753 - Added a new parameter p_other_mesg_name to the procedure below.*/
        PROCEDURE setSubComponents
        (  p_error_scope        IN  VARCHAR2
         , p_other_mesg_text    IN  VARCHAR2
         , p_other_status       IN  VARCHAR2
         , p_rc_idx             IN  NUMBER := 0
         , p_rd_idx             IN  NUMBER := 0
         , p_entity_index       IN  NUMBER := 0
         , p_other_mesg_name	IN  VARCHAR2 := NULL
          , p_bom_header_rec          IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Rec_Type
          , p_bom_revision_tbl        IN OUT NOCOPY Bom_Bo_Pub.Bom_Revision_Tbl_Type
          , p_bom_component_tbl       IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Tbl_Type
          , p_bom_ref_Designator_tbl  IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
          , p_bom_sub_component_tbl   IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
          , p_bom_comp_ops_tbl         IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type
        )
        IS
                l_idx   NUMBER;
        BEGIN

	     Error_Handler.Write_Debug('Setting substitute component records to ' || p_other_status);


             IF p_error_scope = G_SCOPE_ALL
             THEN
                FOR l_idx IN 1..p_bom_sub_component_tbl.COUNT
                LOOP
                        p_bom_sub_component_tbl(l_idx).return_status :=
                                        p_other_status;
                        /* Put in fix in response to bug 851387
                        -- Added IF condition
                        -- Fix made by AS on 03/17/99
                        */
                        IF p_other_mesg_text IS NOT NULL
                        THEN
                        /* Fix for bug 4661753 - added p_mesg_name to the call to Add_message procedure below. */
                                Add_Message
                                (  p_mesg_text  => p_other_mesg_text
                                , p_entity_id   => G_SC_LEVEL
                                , p_entity_index=> l_idx
                                , p_message_type=> 'E'
                                , p_mesg_name   => p_other_mesg_name
	                   	 , p_bom_header_rec         =>p_bom_header_rec
        	           	 , p_bom_revision_tbl  =>p_bom_revision_tbl
              	 	   	 , p_bom_component_tbl    =>p_bom_component_tbl
               		   	 , p_bom_ref_Designator_tbl =>p_bom_ref_Designator_tbl
            	           	 , p_bom_sub_component_tbl =>p_bom_sub_component_tbl
               		   	 , p_bom_comp_ops_tbl =>p_bom_comp_ops_tbl
                               );
                        END IF;
                END LOOP;
             ELSIF p_error_scope = G_SCOPE_CHILDREN AND
                   p_rc_idx <> 0
             THEN

                Error_Handler.Write_Debug('Scope=Children in Substitute Component');
                Error_Handler.Write_Debug('Inventory Component index <> 0');

                FOR l_idx IN 1..p_bom_sub_component_tbl.COUNT
                LOOP
                    IF NVL(p_bom_sub_component_tbl(l_idx).component_item_name, ' ')=
                       NVL(p_bom_component_tbl(p_rc_idx).component_item_name,' '
                          ) AND
                       NVL(p_bom_sub_component_tbl(l_idx).start_effective_date,
                           SYSDATE ) =
                       NVL(p_bom_component_tbl(p_rc_idx).start_effective_date,
                           SYSDATE )
                       AND
                       NVL(p_bom_sub_component_tbl(l_idx).operation_sequence_number,
                           0) =
                       NVL(p_bom_component_tbl(p_rc_idx).operation_sequence_number, 0)
                       AND
                       NVL(p_bom_sub_component_tbl(l_idx).organization_code, ' ') =
                       NVL(p_bom_component_tbl(p_rc_idx).organization_code, ' ')
                    THEN

                        p_bom_sub_component_tbl(l_idx).return_status :=
                                                p_other_status;
                       /* Fix for bug 4661753 - added p_mesg_name to the call to Add_message procedure below. */
                        Add_Message
                        (  p_mesg_text          => p_other_mesg_text
                         , p_entity_id          => G_SC_LEVEL
                         , p_entity_index       => l_idx
                         , p_message_type       => 'E'
                         , p_mesg_name          => p_other_mesg_name
                         , p_bom_header_rec         =>p_bom_header_rec
                         , p_bom_revision_tbl  =>p_bom_revision_tbl
                         , p_bom_component_tbl    =>p_bom_component_tbl
                         , p_bom_ref_Designator_tbl =>p_bom_ref_Designator_tbl
                         , p_bom_sub_component_tbl =>p_bom_sub_component_tbl
                          , p_bom_comp_ops_tbl =>p_bom_comp_ops_tbl
                        );
                    END IF;
                END LOOP;  -- Ref. Desg Children of Rev Comps Ends.

             ELSIF p_error_scope = G_SCOPE_SIBLINGS AND
                   p_rd_idx <> 0
             THEN

                Error_Handler.Write_Debug('Scope = Siblings in Sub. Components');
                Error_Handler.Write_Debug('Reference Desg Index <> 0');

                FOR l_idx IN 1..p_bom_sub_component_tbl.COUNT
                LOOP
                    IF NVL(p_bom_sub_component_tbl(l_idx).component_item_name,' ') =
                       NVL(p_bom_ref_designator_tbl(p_rd_idx).component_item_name, ' ') AND
                       NVL(p_bom_sub_component_tbl(l_idx).start_effective_date, SYSDATE) =
                       NVL(p_bom_ref_designator_tbl(p_rd_idx).start_effective_date, SYSDATE)
                       AND
                       NVL(p_bom_sub_component_tbl(l_idx).operation_sequence_number, 0) =
                       NVL(p_bom_ref_designator_tbl(p_rd_idx).operation_sequence_number, 0)
                       AND
                       NVL(p_bom_sub_component_tbl(l_idx).organization_code, ' ') =
                       NVL(p_bom_ref_designator_tbl(p_rd_idx).organization_code, ' ')
                    THEN
                        --
                        -- Since bill sequence id is not available
                        -- match the revised item information also.
                        --
                        p_bom_sub_component_tbl(l_idx).return_status :=
                                                p_other_status;
                        /* Fix for bug 4661753 - added p_mesg_name to the call to Add_message procedure below. */
                        Add_Message
                        (  p_mesg_text          => p_other_mesg_text
                         , p_entity_id          => G_SC_LEVEL
                         , p_entity_index       => l_idx
                         , p_message_type       => 'E'
                         , p_mesg_name          => p_other_mesg_name
                         , p_bom_header_rec         =>p_bom_header_rec
                         , p_bom_revision_tbl  =>p_bom_revision_tbl
                         , p_bom_component_tbl    =>p_bom_component_tbl
                         , p_bom_ref_Designator_tbl =>p_bom_ref_Designator_tbl
                         , p_bom_sub_component_tbl =>p_bom_sub_component_tbl
                         , p_bom_comp_ops_tbl =>p_bom_comp_ops_tbl
                        );
                    END IF;

                END LOOP; -- Scope = Siblings with rd_idx <> 0 Ends

             ELSIF p_error_scope = G_SCOPE_SIBLINGS AND
                   p_rc_idx = 0 AND
                   p_rd_idx = 0
             THEN
                --
                -- This situation will arise when inventory comp and
                -- reference designator are not part of the business object
                -- input data.
                -- Match the component key information at the entity index
                -- location with rest of the records, all those that are found
                -- will be siblings and should get an error.
                --
                Error_Handler.Write_Debug('Scope=Siblings in Substitute Component');
                Error_Handler.Write_Debug('All entity indexes = 0');


                FOR l_idx IN (p_entity_index+1)..p_bom_sub_component_tbl.COUNT
                LOOP
                    IF NVL(p_bom_sub_component_tbl(l_idx).component_item_name, ' ') =
                       NVL(p_bom_sub_component_tbl(p_entity_index).component_item_name, ' ')
                       AND
                       NVL(p_bom_sub_component_tbl(l_idx).start_effective_date, SYSDATE) =
                       NVL(p_bom_sub_component_tbl(p_entity_index).start_effective_date, SYSDATE)
                       AND
                       NVL(p_bom_sub_component_tbl(l_idx).operation_sequence_number, 0) =
                       NVL(p_bom_sub_component_tbl(p_entity_index).operation_sequence_number, 0)
                       AND
                       NVL(p_bom_sub_component_tbl(l_idx).organization_code, ' ') =
                       NVL(p_bom_sub_component_tbl(p_entity_index).organization_code, ' ')
                    THEN
                        p_bom_sub_component_tbl(l_idx).return_status :=
                                                p_other_status;
                        /* Fix for bug 4661753 - added p_mesg_name to the call to Add_message procedure below. */
                        Add_Message
                        (  p_mesg_text          => p_other_mesg_text
                         , p_entity_id          => G_SC_LEVEL
                         , p_entity_index       => l_idx
                         , p_message_type       => 'E'
                         , p_mesg_name          => p_other_mesg_name
                         , p_bom_header_rec         =>p_bom_header_rec
                         , p_bom_revision_tbl  =>p_bom_revision_tbl
                         , p_bom_component_tbl    =>p_bom_component_tbl
                         , p_bom_ref_Designator_tbl =>p_bom_ref_Designator_tbl
                         , p_bom_sub_component_tbl =>p_bom_sub_component_tbl
                         , p_bom_comp_ops_tbl =>p_bom_comp_ops_tbl
                        );
                    END IF;
                END LOOP;
             END IF; -- If Scope = Ends.

        END setSubComponents;

        /******************************************************************
        * Procedure     : setRefDesignators (Unexposed)
        * Parameters    : Other Message
        *                 Other Status
        *                 Error Scope
        *                 Revised Item Index
        *                 Revised Component Index
        * Purpose       : This procedure will set the reference designator
        *                 record status to other status by looking at the
        *                 revised item key or the revised component key or
        *                 else setting all the record status to other status
        ********************************************************************/
        /* Fix for bug 4661753 - Added a new parameter p_other_mesg_name to the procedure below.*/
        PROCEDURE setRefDesignators
        (  p_error_scope        IN  VARCHAR2
         , p_other_mesg_text    IN  VARCHAR2
         , p_other_status       IN  VARCHAR2
         , p_rc_idx             IN  NUMBER DEFAULT 0
         , p_entity_index       IN  NUMBER DEFAULT 0
         , p_other_mesg_name	IN  VARCHAR2 := NULL
         , p_bom_header_rec          IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Rec_Type
         , p_bom_revision_tbl        IN OUT NOCOPY Bom_Bo_Pub.Bom_Revision_Tbl_Type
         , p_bom_component_tbl       IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Tbl_Type
         , p_bom_ref_Designator_tbl  IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
         , p_bom_sub_component_tbl   IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
         , p_bom_comp_ops_tbl         IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type
        )
        IS
                l_idx   NUMBER;
        BEGIN

             IF p_error_scope = G_SCOPE_ALL
             THEN
                FOR l_idx IN (p_entity_index+1)..p_bom_ref_designator_tbl.COUNT
                LOOP
                        p_bom_ref_designator_tbl(l_idx).return_status :=
                                        p_other_status;
                        /* Put in fix in response to bug 851387
                        -- Added IF condition
                        -- Fix made by AS on 03/17/99
                        */
                        IF p_other_mesg_text IS NOT NULL
                        THEN
                        /* Fix for bug 4661753 - added p_mesg_name to the call to Add_message procedure below. */
                                Add_Message
                                (  p_mesg_text  => p_other_mesg_text
                                , p_entity_id   => G_RD_LEVEL
                                , p_entity_index=> l_idx
                                , p_message_type=> 'E'
                                , p_mesg_name   => p_other_mesg_name
                         	, p_bom_header_rec         =>p_bom_header_rec
                         	, p_bom_revision_tbl  =>p_bom_revision_tbl
                         	, p_bom_component_tbl    =>p_bom_component_tbl
                         	, p_bom_ref_Designator_tbl =>p_bom_ref_Designator_tbl
                         	, p_bom_sub_component_tbl =>p_bom_sub_component_tbl
                          	, p_bom_comp_ops_tbl =>p_bom_comp_ops_tbl
                                );
                        END IF;
                END LOOP;
                --
                -- Set the Substitute Components Record Status too
                --
                /* Fix for bug 4661753 - added p_other_mesg_name to the call to setSubComponents procedure below. */
                setSubComponents
                (  p_other_status       => p_other_status
                 , p_other_mesg_text    => p_other_mesg_text
                 , p_error_scope        => p_error_scope
                 , p_other_mesg_name    => p_other_mesg_name
                 , p_bom_header_rec         =>p_bom_header_rec
                 , p_bom_revision_tbl  =>p_bom_revision_tbl
                 , p_bom_component_tbl    =>p_bom_component_tbl
                 , p_bom_ref_Designator_tbl =>p_bom_ref_Designator_tbl
                 , p_bom_sub_component_tbl =>p_bom_sub_component_tbl
                 , p_bom_comp_ops_tbl =>p_bom_comp_ops_tbl
                 );
             ELSIF p_error_scope = G_SCOPE_CHILDREN AND
                   p_rc_idx <> 0
             THEN

                Error_Handler.Write_Debug('Scope=Children in Reference Designator');
                Error_Handler.Write_Debug('Inventory Component index <> 0');

                FOR l_idx IN 1..p_bom_ref_designator_tbl.COUNT
                LOOP
                    IF NVL(p_bom_ref_designator_tbl(l_idx).component_item_name,
                           ' ') =
                       NVL(p_bom_component_tbl(p_rc_idx).component_item_name,
                           ' ') AND
                       NVL(p_bom_ref_designator_tbl(l_idx).start_effective_date, SYSDATE) =
                       NVL(p_bom_component_tbl(p_rc_idx).start_effective_date, SYSDATE) AND
                       NVL(p_bom_ref_designator_tbl(l_idx).operation_sequence_number, 0) =
                       NVL(p_bom_component_tbl(p_rc_idx).operation_sequence_number, 0)
                       AND
                       NVL(p_bom_ref_designator_tbl(l_idx).organization_code, ' ')=
                       NVL(p_bom_component_tbl(p_rc_idx).organization_code, ' ')
                    THEN

                        p_bom_ref_designator_tbl(l_idx).return_status :=
                                                p_other_status;
                        /* Fix for bug 4661753 - added p_mesg_name to the call to Add_message procedure below. */
                        Add_Message
                        (  p_mesg_text          => p_other_mesg_text
                         , p_entity_id          => G_RD_LEVEL
                         , p_entity_index       => l_idx
                         , p_message_type       => 'E'
                         , p_mesg_name          => p_other_mesg_name
                         , p_bom_header_rec         =>p_bom_header_rec
                         , p_bom_revision_tbl  =>p_bom_revision_tbl
                         , p_bom_component_tbl    =>p_bom_component_tbl
                         , p_bom_ref_Designator_tbl =>p_bom_ref_Designator_tbl
                         , p_bom_sub_component_tbl =>p_bom_sub_component_tbl
                         , p_bom_comp_ops_tbl =>p_bom_comp_ops_tbl
                        );
                    END IF;
                END LOOP;  -- Ref. Desg Children of Rev Comps Ends.

             ELSIF p_error_scope = G_SCOPE_SIBLINGS AND
                   p_rc_idx = 0
             THEN
                --
                -- This situation will arise when comp is
                -- not part of the business object input data.
                -- Match the component key information at the entity index
                -- location with rest of the records, all those that are found
                -- will be siblings and should get an error.
                --

                Error_Handler.Write_Debug('Scope=Siblings in Reference Designator');
                Error_Handler.Write_Debug('All Indexes = 0');

                FOR l_idx IN (p_entity_index+1)..p_bom_ref_designator_tbl.COUNT
                LOOP
                    IF NVL(p_bom_ref_designator_tbl(l_idx).component_item_name,
                                ' ') =
                       NVL(p_bom_ref_designator_tbl(p_entity_index).component_item_name, ' ')
                       AND
                       NVL(p_bom_ref_designator_tbl(l_idx).start_effective_date, SYSDATE) =
                       NVL(p_bom_ref_designator_tbl(p_entity_index).start_effective_date, SYSDATE)
                       AND
                       NVL(p_bom_ref_designator_tbl(l_idx).operation_sequence_number, 0) =
                       NVL(p_bom_ref_designator_tbl(p_entity_index).operation_sequence_number, 0)
                       AND
                       NVL(p_bom_ref_designator_tbl(l_idx).organization_code, ' ') =
                       NVL(p_bom_ref_designator_tbl(p_entity_index).organization_code, ' ')
                    THEN
                        p_bom_ref_designator_tbl(l_idx).return_status :=
                                                p_other_status;
                        /* Fix for bug 4661753 - added p_mesg_name to the call to Add_message procedure below. */
                        Add_Message
                        (  p_mesg_text          => p_other_mesg_text
                         , p_entity_id          => G_RD_LEVEL
                         , p_entity_index       => l_idx
                         , p_message_type       => 'E'
                         , p_mesg_name          => p_other_mesg_name
                         , p_bom_header_rec         =>p_bom_header_rec
                         , p_bom_revision_tbl  =>p_bom_revision_tbl
                         , p_bom_component_tbl    =>p_bom_component_tbl
                         , p_bom_ref_Designator_tbl =>p_bom_ref_Designator_tbl
                         , p_bom_sub_component_tbl =>p_bom_sub_component_tbl
                         , p_bom_comp_ops_tbl =>p_bom_comp_ops_tbl
                        );
                    END IF;
                END LOOP;

                --
                -- Substitute Components will also be considered as siblings
                -- of reference designators, they should get an error when
                -- error level is reference designator with scope of Siblings
                --
                /* Fix for bug 4661753 - added p_other_mesg_name to the call to procedure  setSubComponents below. */
                setSubComponents
                (  p_other_status       => p_other_status
                 , p_other_mesg_text    => p_other_mesg_text
                 , p_error_scope        => p_error_scope
                 , p_rd_idx             => p_entity_index
                 , p_other_mesg_name    => p_other_mesg_name
                 , p_bom_header_rec         =>p_bom_header_rec
                 , p_bom_revision_tbl  =>p_bom_revision_tbl
                 , p_bom_component_tbl    =>p_bom_component_tbl
                 , p_bom_ref_Designator_tbl =>p_bom_ref_Designator_tbl
                 , p_bom_sub_component_tbl =>p_bom_sub_component_tbl
                 , p_bom_comp_ops_tbl =>p_bom_comp_ops_tbl
                 );
             END IF; -- If error scope Ends

        END setRefDesignators;

        /*****************************************************************
        * Procedure     : setInventory_Components(Unexposed)
        * Parameters IN : Other Message Text
        *                 Other status
        *                 Entity Index
        *                 Error Scope
        *                 Error Status
        *                 Revised Item Index
        * Parameters OUT: None
        * Purpose       : This procedure will set the revised components record
        *                 status to other status and for each errored record
        *                 it will log the other message indicating what caused
        *                 the other records to fail.
        ******************************************************************/
        /* Fix for bug 4661753 - Added a new parameter p_other_mesg_name to the procedure below.*/
        PROCEDURE setInventory_Components
        (  p_error_scope        IN  VARCHAR2
         , p_other_mesg_text    IN  VARCHAR2
         , p_other_status       IN  VARCHAR2
         , p_entity_index       IN  NUMBER := 0
         , p_other_mesg_name	IN  VARCHAR2 := NULL
         , p_bom_header_rec          IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Rec_Type
         , p_bom_revision_tbl        IN OUT NOCOPY Bom_Bo_Pub.Bom_Revision_Tbl_Type
         , p_bom_component_tbl       IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Tbl_Type
         , p_bom_ref_Designator_tbl  IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
         , p_bom_sub_component_tbl   IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
         , p_bom_comp_ops_tbl         IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type
         )
        IS
                l_Idx           NUMBER;
        BEGIN


                IF p_error_scope = G_SCOPE_ALL
                THEN

                    Error_Handler.Write_Debug('Scope=All in Inventory Components');

                    FOR l_idx IN 1..p_bom_component_tbl.COUNT
                    LOOP
                        p_bom_component_tbl(l_idx).return_status :=
                                                p_other_status;
                        /* Put in fix in response to bug 851387
                        -- Added IF condition
                        -- Fix made by AS on 03/17/99
                        */
                        IF p_other_mesg_text IS NOT NULL
                        THEN
                            /* Fix for bug 4661753 - added p_mesg_name to the call to Add_message procedure below. */
                                Add_Message
                                (  p_mesg_text  => p_other_mesg_text
                                , p_entity_id   => G_RC_LEVEL
                                , p_entity_index=> l_Idx
                                , p_message_type=> 'E'
                                , p_mesg_name   => p_other_mesg_name
                         	, p_bom_header_rec         =>p_bom_header_rec
                         	 , p_bom_revision_tbl  =>p_bom_revision_tbl
                        	 , p_bom_component_tbl    =>p_bom_component_tbl
                        	 , p_bom_ref_Designator_tbl =>p_bom_ref_Designator_tbl
                         	, p_bom_sub_component_tbl =>p_bom_sub_component_tbl
                         	, p_bom_comp_ops_tbl =>p_bom_comp_ops_tbl
                                );
                        END IF;

                    END LOOP;

                        --
                        -- Set the reference designator and substitute
                        -- component record status too.
                        --
                        /* Fix for bug 4661753 - added p_other_mesg_name to the call to setRefDesignators procedure below. */
                    setRefDesignators
                    (  p_other_status    => p_other_status
                     , p_error_scope     => p_error_scope
                     , p_other_mesg_text => p_other_mesg_text
                     , p_other_mesg_name => p_other_mesg_name
                     , p_bom_header_rec         =>p_bom_header_rec
                     , p_bom_revision_tbl  =>p_bom_revision_tbl
                     , p_bom_component_tbl    =>p_bom_component_tbl
                     , p_bom_ref_Designator_tbl =>p_bom_ref_Designator_tbl
                     , p_bom_sub_component_tbl =>p_bom_sub_component_tbl
                     , p_bom_comp_ops_tbl =>p_bom_comp_ops_tbl
                     );

                        --
                        -- Set the component operation record status too.
                        --
                    /* Fix for bug 4661753 - added p_other_mesg_name to the call to setRefDesignators procedure below. */
                    setCompOperations
                    (  p_other_status    => p_other_status
                     , p_error_scope     => p_error_scope
                     , p_other_mesg_text => p_other_mesg_text
                     , p_other_mesg_name => p_other_mesg_name
                     , p_bom_header_rec         =>p_bom_header_rec
                     , p_bom_revision_tbl  =>p_bom_revision_tbl
                     , p_bom_component_tbl    =>p_bom_component_tbl
                     , p_bom_ref_Designator_tbl =>p_bom_ref_Designator_tbl
                     , p_bom_sub_component_tbl =>p_bom_sub_component_tbl
                     , p_bom_comp_ops_tbl =>p_bom_comp_ops_tbl
                     );

                END IF; -- Error Scope Ends

        END setInventory_Components;


        /*****************************************************************
        * Procedure     : setRevisions (unexposed)
        * Parameters IN : Other Message Text
        *                 Other status
        *                 Entity Index
        * Parameters OUT: None
        * Purpose       : This procedure will set the Item Revisions record
        *                 status to other status and for each errored record
        *                 it will log the other message indicating what caused
        *                 the other records to fail.
        ******************************************************************/
        /* Fix for bug 4661753 - Added a new parameter p_other_mesg_name to the procedure below.*/
        PROCEDURE setRevisions
        (  p_other_mesg_text    IN  VARCHAR2
         , p_other_status       IN  VARCHAR2
         , p_other_mesg_name	IN  VARCHAR2 := NULL
          , p_bom_header_rec          IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Rec_Type
          , p_bom_revision_tbl        IN OUT NOCOPY Bom_Bo_Pub.Bom_Revision_Tbl_Type
          , p_bom_component_tbl       IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Tbl_Type
         , p_bom_ref_Designator_tbl  IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
          , p_bom_sub_component_tbl   IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
          , p_bom_comp_ops_tbl         IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type
        )
        IS
                l_CurrentIndex  NUMBER;
        BEGIN

                FOR l_CurrentIndex IN  1..p_bom_revision_tbl.COUNT
                LOOP
                        p_bom_revision_tbl(l_CurrentIndex).return_status :=
                                                p_other_status;
                        IF p_other_mesg_text IS NOT NULL
                        THEN
                            /* Fix for bug 4661753 - added p_mesg_name to the call to Add_message procedure below. */
                                Add_Message
                                (  p_mesg_text          => p_other_mesg_text
                                 , p_entity_id          => G_REV_LEVEL
                                 , p_entity_index       => l_CurrentIndex
                                 , p_message_type       => 'E'
                                 , p_mesg_name          => p_other_mesg_name
                     		, p_bom_header_rec         =>p_bom_header_rec
                     		, p_bom_revision_tbl  =>p_bom_revision_tbl
                     		, p_bom_component_tbl    =>p_bom_component_tbl
                     		, p_bom_ref_Designator_tbl =>p_bom_ref_Designator_tbl
                     		, p_bom_sub_component_tbl =>p_bom_sub_component_tbl
                     		, p_bom_comp_ops_tbl =>p_bom_comp_ops_tbl
                                );
                        END IF;
                END LOOP;

        END setRevisions;

        /*********************************************************************
        * Function      : Translate_Message
        * Returns       : VARCHAR2 (Translated Message)
        * Parameters IN : Application id
	*                 Message Name
	*		  Token Table
        * Parameters OUT: Translated Message
        **********************************************************************/

	FUNCTION Translate_Message (p_application_id  IN VARCHAR2
			 	    ,p_message_name   IN VARCHAR2
				    ,p_token_tbl      IN Error_Handler.Token_Tbl_Type
							:= Error_Handler.G_MISS_TOKEN_TBL)
	RETURN VARCHAR2 IS
	BEGIN
          IF p_token_tbl.COUNT IS NOT NULL
          THEN

            Fnd_Message.Set_Name (  application  => p_application_id,
                                    name         => p_message_name
                                 );

            FOR l_LoopIndex IN 1..p_token_tbl.COUNT
            LOOP
              IF p_token_tbl(l_LoopIndex).token_name IS NOT NULL
              THEN
                Fnd_Message.Set_Token ( token  =>
                                        p_token_tbl(l_LoopIndex).token_name
                                        , value =>
                                        p_token_tbl(l_LoopIndex).token_value
                                        , translate   =>
                                        p_token_tbl(l_LoopIndex).translate
                                      );
              END IF;
            END LOOP;
            Return (Fnd_Message.Get);

          ELSE

            Fnd_Message.Set_Name (  application  => p_application_id,
                                    name       => p_message_name
                                 );
            Return (Fnd_Message.Get);

          END IF;

	END;

        /**********************************************************************
        * Procedure     : Add_Error_Token
        * Parameters IN : Message Text (in case of unexpected errors)
        *                 Message Name
        *                 Mesg Token Tbl
        *                 Token Table
        * Parameters OUT: Mesg Token Table
        * Purpose       : This procedure will add the message to the
	*		  message token table.
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
         )
        IS
                l_Index         NUMBER;
                l_TableCount    NUMBER;
                l_Mesg_Token_Tbl Error_Handler.Mesg_Token_Tbl_Type ;
		l_message_text  VARCHAR2(2000);
        BEGIN

          l_Mesg_Token_Tbl := p_Mesg_Token_Tbl;
          l_TableCount := l_Mesg_token_tbl.COUNT;

          IF p_message_name IS NOT NULL
          THEN
            l_message_text  := Translate_Message( p_application_id => substr(p_message_name,1,3),
                                                  p_message_name   => p_message_name,
                                                  p_token_tbl      => p_token_tbl);
          ELSE
            l_message_text := p_message_text;
          END IF;

          l_mesg_token_tbl(l_TableCount+1).message_text :=
                                        l_message_text;
          l_mesg_token_tbl(l_TableCount+1).message_type :=
                                        p_message_type;
          l_mesg_token_tbl(l_TableCount+1).message_name := p_message_name;
          /*Fix for bug 4661753- Added message_name also to the l_Mesg_Token_Tbl above.*/

	  x_mesg_token_tbl := l_mesg_token_tbl;

        END Add_Error_Token;

        /**********************************************************************
        * Procedure     : Add_Error_Message
        * Parameters IN : Message Text (in case of unexpected errors)
	*			Free text
        *                 Message Name
	*			FND message name
	*		  Application Id
	*			Applicaion short name under which the
	*			message is defined
        *                 Token Table
	*		 	Token Table of type TOKEN_TBL_TYPE
	*		  Message Type
	*			W -> Warning
	*			E -> Error
	*		  Entity Id
	*			Entity identifier which is defined as a
	*		 	constant in the error handler
	*		  Entity Index
	*			The order of the entity record within
	*			the entity table
	*		  Entity Code
	*			Replacement for entity id. This can be
	*			used when there is no constant defined
	*			in the error handler for the entity.
	*			When both are passed entity code will be
	*			used as entity identifier
	*		  Row Identifier
	*			Any unique identifier value for the entity record.
	*			In case of bulk load from interface table this can
	*			be used to store the transaction_id
	*		  Table Name
	*			Production table name where the data goes in.
	*			This is useful when the same logical entity deals
	*			with multiple tables.
	*			A typical example would be extensible attributes for an
	*			entity. Logically, the entity is same but the data is
	*			going into two tables (ex: BOM_BILL_OF_MATERIALS and
	*			BOM_BILL_OF_MATERIALS_EXT)
	*
        * Parameters OUT: None
        * Purpose       : This procedure will translate and add the message directly into
	*		  the error stack with all the context information
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
       ) IS

    Begin
       Add_Error_Message
         (  p_message_name
          , p_application_id
          , p_message_text
          , p_token_tbl
          , p_message_type
          , p_row_identifier
          , p_entity_id
          , p_entity_index
          , p_table_name
          , p_entity_code
          , p_addto_fnd_stack
          , Bom_Bo_Pub.G_MISS_BOM_HEADER_REC
          , Bom_Bo_Pub.G_MISS_BOM_REVISION_TBL
          , Bom_Bo_Pub.G_MISS_BOM_COMPONENT_TBL
          , Bom_Bo_Pub.G_MISS_BOM_REF_DESIGNATOR_TBL
          , Bom_Bo_Pub.G_MISS_BOM_SUB_COMPONENT_TBL
          , Bom_Bo_Pub.G_MISS_BOM_COMP_OPS_TBL
        );

      END;



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
        )
	IS

	  l_message_text  VARCHAR2(2000);

	BEGIN

	  IF p_message_name IS NOT NULL
	  THEN

	    IF p_addto_fnd_stack = 'Y' THEN
	      Fnd_Message.Set_Name(p_application_id,p_message_name);
	      IF p_token_tbl.COUNT IS NOT NULL THEN
                FOR l_LoopIndex IN 1..p_token_tbl.COUNT
                LOOP
                  IF p_token_tbl(l_LoopIndex).token_name IS NOT NULL THEN
                    Fnd_Message.Set_Token ( token  =>
                                        p_token_tbl(l_LoopIndex).token_name
                                        , value =>
                                        p_token_tbl(l_LoopIndex).token_value
                                        , translate   =>
                                        p_token_tbl(l_LoopIndex).translate
                                      );
                  END IF;
                END LOOP;
	      END IF;
	      Fnd_Msg_Pub.Add;
	    END IF;

	    l_message_text  := Translate_Message( p_application_id => p_application_id,
		     			          p_message_name   => p_message_name,
			     			  p_token_tbl      => p_token_tbl);

	  ELSE

	    IF p_addto_fnd_stack = 'Y' THEN
              Fnd_Msg_Pub.Add_Exc_Msg
               (p_error_text       =>  p_message_text);
	    END IF;

	    l_message_text := p_message_text;

	  END IF;

          Add_Message (  p_mesg_text       => l_message_text
         		, p_entity_id      => p_entity_id
         		, p_entity_code    => p_entity_code
         		, p_entity_index   => p_entity_index
         		, p_message_type   => p_message_type
      			, p_row_identifier => p_row_identifier
			      , p_table_name     => p_table_name
            , p_mesg_name	   => p_message_name
                        , p_bom_header_rec         =>p_bom_header_rec
                  	, p_bom_revision_tbl  =>p_bom_revision_tbl
                   	, p_bom_component_tbl    =>p_bom_component_tbl
                   	, p_bom_ref_Designator_tbl =>p_bom_ref_Designator_tbl
                   	, p_bom_sub_component_tbl =>p_bom_sub_component_tbl
                   	, p_bom_comp_ops_tbl =>p_bom_comp_ops_tbl
                      );
	END;


        /*********************************************************************
        * Procedure     : Translate_And_Insert_Messages
        * Returns       : None
        * Parameters IN : Message Token Table
	*		  Error Level
	*			The entity level at which the error has
	*			occured.This is same as entity id in the
	*			other procedures (Add_Message, Add_Error_Message)
	*		  For explanation on entity id, entity index,
	*		  message type,row identifier, table name,
	*		  entity code parameters please refer to
	*		  Add_Error_Message API
        * Parameters OUT: Non
        * Purpose       : This procedure will read through the message token
        *                 table and insert them into the message table with
	*		  the proper business object context.
        **********************************************************************/


     PROCEDURE Translate_And_Insert_Messages
     (  p_mesg_token_tbl IN Error_Handler.Mesg_Token_Tbl_Type
      , p_error_level    IN NUMBER := NULL
      , p_entity_index   IN NUMBER := NULL
      , p_application_id IN VARCHAR2 := 'ENG'
      , p_row_identifier IN NUMBER := NULL
      , p_table_name     IN VARCHAR2 := NULL
      , p_entity_code    IN VARCHAR2 := NULL
     ) IS

    Begin
        Translate_And_Insert_Messages
         (  p_mesg_token_tbl
          , p_error_level
          , p_entity_index
          , p_application_id
          , p_row_identifier
          , p_table_name
          , p_entity_code
          , Bom_Bo_Pub.G_MISS_BOM_HEADER_REC
          , Bom_Bo_Pub.G_MISS_BOM_REVISION_TBL
          , Bom_Bo_Pub.G_MISS_BOM_COMPONENT_TBL
          , Bom_Bo_Pub.G_MISS_BOM_REF_DESIGNATOR_TBL
          , Bom_Bo_Pub.G_MISS_BOM_SUB_COMPONENT_TBL
          , Bom_Bo_Pub.G_MISS_BOM_COMP_OPS_TBL
          );
      END;



        PROCEDURE Translate_And_Insert_Messages
        (  p_mesg_token_tbl     IN  Error_Handler.Mesg_Token_Tbl_Type
         , p_error_level        IN  NUMBER   := NULL
         , p_entity_index       IN  NUMBER   := NULL
         , p_application_id     IN  VARCHAR2 := 'ENG'
         , p_row_identifier     IN  NUMBER   := NULL
         , p_table_name         IN  VARCHAR2 := NULL
         , p_entity_code        IN  VARCHAR2 := NULL
         , p_bom_header_rec          IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Rec_Type
         , p_bom_revision_tbl        IN OUT NOCOPY Bom_Bo_Pub.Bom_Revision_Tbl_Type
         , p_bom_component_tbl       IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Tbl_Type
         , p_bom_ref_Designator_tbl  IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
         , p_bom_sub_component_tbl   IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
         , p_bom_comp_ops_tbl        IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type
         )
        IS
                l_message_text  VARCHAR2(2000);
                l_message_name  VARCHAR2(30);
        BEGIN

          FOR l_LoopIndex IN 1..p_mesg_token_tbl.COUNT
          LOOP
            Add_Message
            (  p_mesg_text =>
			p_mesg_token_tbl(l_LoopIndex).message_text
               , p_entity_id      => p_error_level
               , p_entity_index   => p_entity_index
               , p_message_type  =>
				p_mesg_token_tbl(l_LoopIndex).message_type
	       , p_row_identifier => p_row_identifier
	       , p_table_name => p_table_name
               , p_entity_code    => p_entity_code
               , p_mesg_name      => p_mesg_token_tbl(l_LoopIndex).message_name
		, p_bom_header_rec         =>p_bom_header_rec
		, p_bom_revision_tbl  =>p_bom_revision_tbl
		, p_bom_component_tbl    =>p_bom_component_tbl
		, p_bom_ref_Designator_tbl =>p_bom_ref_Designator_tbl
		, p_bom_sub_component_tbl =>p_bom_sub_component_tbl
		, p_bom_comp_ops_tbl =>p_bom_comp_ops_tbl
             );
          END LOOP;

        END Translate_And_Insert_Messages;


        /******************************************************************
        * Procedure     : Log_Error
        * Parameters IN : Bill Header Record and Rest of the Entity Tables
        *                 Message Token Table
        *                 Other Message Table
        *                 Other Status
        *                 Entity Index
        *                 Error Level
        *                 Error Scope
        *                 Error Status
        * Parameters OUT:  Bill Header Record and Rest of the Entity Tables
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
         , p_entity_index            IN  NUMBER := 1 -- := NULL
         , x_bom_header_rec          IN OUT NOCOPY Bom_Bo_Pub.Bom_Head_Rec_Type
         , x_bom_revision_tbl        IN OUT NOCOPY Bom_Bo_Pub.Bom_Revision_Tbl_Type
         , x_bom_component_tbl       IN OUT NOCOPY Bom_Bo_Pub.Bom_Comps_Tbl_Type
         , x_bom_ref_Designator_tbl  IN OUT NOCOPY Bom_Bo_Pub.Bom_Ref_Designator_Tbl_Type
         , x_bom_sub_component_tbl   IN OUT NOCOPY Bom_Bo_Pub.Bom_Sub_Component_Tbl_Type
	 , p_row_identifier	     IN  NUMBER := NULL
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

               -- g_bom_revision_tbl      := p_bom_revision_tbl;
               -- g_bom_component_tbl     := p_bom_component_tbl;
               -- g_bom_ref_designator_tbl    := p_bom_ref_designator_tbl;
               -- g_bom_sub_component_tbl     := p_bom_sub_component_tbl;

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
		Error_Handler.Write_Debug('Business Object: ' || Bom_Globals.Get_Bo_Identifier);

                Error_Handler.Translate_And_Insert_Messages
                (  p_mesg_token_Tbl     => p_mesg_token_tbl
                 , p_error_level        => p_error_level
                 , p_entity_index       => p_entity_index
                 , p_bom_header_rec         =>x_bom_header_rec
                 , p_bom_revision_tbl  =>x_bom_revision_tbl
                 , p_bom_component_tbl    =>x_bom_component_tbl
                 , p_bom_ref_Designator_tbl =>x_bom_ref_Designator_tbl
                 , p_bom_sub_component_tbl =>x_bom_sub_component_tbl
                 , p_bom_comp_ops_tbl =>g_bom_comp_ops_tbl
               );

		Error_Handler.Write_Debug('Finished logging messages . . . ');

                /**********************************************************
                --
                -- Get the other message text and token and retrieve the
                -- token substituted message.
                --
                ***********************************************************/

		/* p_other_message contains the message_name (can be null).*/
		IF p_other_message IS NOT NULL
		THEN
		  l_other_message := Translate_Message(p_application_id => p_other_mesg_appid,
					               p_message_name   => p_other_message,
						       p_token_tbl      => p_other_token_tbl);
		END IF;

		Error_Handler.Write_Debug('Finished extracting other message . . . ');
		Error_Handler.Write_Debug('Other Message generated: ' || l_other_message);


                /**********************************************************
                --
                -- If the Error Level is Business Object
                -- then set the Error Level = ECO
                --
                ************************************************************/
                IF l_error_level = G_BO_LEVEL
                THEN
                        l_error_level := G_BH_LEVEL;

			Error_Handler.Write_Debug('Error Level is Business Object . . . ');

                END IF;
                /**********************************************************
                --
                -- If the error_status is UNEXPECTED then set the error scope
                -- to ALL, if WARNING then set the scope to RECORD.
                --
                ************************************************************/
                IF l_error_status = G_STATUS_UNEXPECTED
                THEN
			Error_Handler.Write_Debug('Status unexpected and scope is All . . .');
                        l_error_scope := G_SCOPE_ALL;
                ELSIF l_error_status = G_STATUS_WARNING
                THEN
                        l_error_scope := G_SCOPE_RECORD;
                        l_error_status := FND_API.G_RET_STS_SUCCESS;
			Error_Handler.Write_Debug('Status is warning . . .');

                END IF;

                --
                -- If the Error Level is Bill Header, then the scope can be
                -- ALL/CHILDREN OR RECORD.
                --
                /*************************************************************
                --
                -- If the Error Level is Bill Header.
                --
                *************************************************************/
                /* Fix for bug 4661753 - added p_other_message to the calls to Add_message,setInventory_Components,
		               setRevisions, setRefDesignators, setSubComponents, setCompOperations procedures below.
		               Note that p_other_message contains message_name (can be null) whereas l_other_message contains message_text.*/
                IF l_error_level = G_BH_LEVEL
                THEN

			Error_Handler.Write_Debug('Error Level is Bill Header . . .');
                        --
                        -- Set the Bill Header record status to p_error_status
                        -- This will also take care of the scope RECORD.
                        --
                        x_bom_header_rec.return_status := l_error_status;

                        IF p_other_message IS NOT NULL AND
                           p_error_level IN (G_BO_LEVEL, G_BH_LEVEL)
                        THEN
                                /* Changed l_error_level to p_error_level
                                -- so that BO is the entity that the message
                                -- is logged for, and not ECO.
                                -- Changed by AS on 03/17/99 for bug 851387
                                */
                                Add_Message
                                (  p_mesg_text          => l_other_message
                                 , p_entity_id          => p_error_level
                                 , p_entity_index       => p_entity_index
                                 , p_message_type       => 'E'
                                 , p_mesg_name          => p_other_message
		                   , p_bom_header_rec         =>x_bom_header_rec
		                   , p_bom_revision_tbl  =>x_bom_revision_tbl
		                   , p_bom_component_tbl    =>x_bom_component_tbl
		                   , p_bom_ref_Designator_tbl =>x_bom_ref_Designator_tbl
		                   , p_bom_sub_component_tbl =>x_bom_sub_component_tbl
		                   , p_bom_comp_ops_tbl =>g_bom_comp_ops_tbl
                                );
                                l_other_message := NULL;
                        END IF;


                        IF l_error_scope = G_SCOPE_ALL OR
                           l_error_scope = G_SCOPE_CHILDREN
                        THEN
                                IF x_bom_revision_tbl.COUNT <> 0
                                THEN
                                  --
                                  -- Set all the revision record status
                                  --
                                  setRevisions
                                  (  p_other_mesg_text   => l_other_message
                                   , p_other_status      => p_other_status
                                   , p_other_mesg_name   => p_other_message
                                   , p_bom_header_rec    => x_bom_header_rec
                                   , p_bom_revision_tbl  => x_bom_revision_tbl
                                   , p_bom_component_tbl => x_bom_component_tbl
                                   , p_bom_ref_Designator_tbl => x_bom_ref_Designator_tbl
                                   , p_bom_sub_component_tbl  => x_bom_sub_component_tbl
                                   , p_bom_comp_ops_tbl  => g_bom_comp_ops_tbl
                                   );
                                END IF;
                                --
                                -- Set all the revised component's
                                -- status, this will then set the
                                -- status of the reference designators
                                -- and substitute components
                                --
                                setInventory_Components
                                (  p_other_mesg_text => l_other_message
                                 , p_other_status    => p_other_status
                                 , p_error_scope     => G_SCOPE_ALL
                                 , p_other_mesg_name => p_other_message
                                 , p_bom_header_rec         =>x_bom_header_rec
                                 , p_bom_revision_tbl  =>x_bom_revision_tbl
                                 , p_bom_component_tbl    =>x_bom_component_tbl
                                 , p_bom_ref_Designator_tbl =>x_bom_ref_Designator_tbl
                                 , p_bom_sub_component_tbl =>x_bom_sub_component_tbl
                                 , p_bom_comp_ops_tbl =>g_bom_comp_ops_tbl
                                 );

                        END IF; -- Bill Header Scope =  ALL or Children Ends

                        /***************************************************
                        --
                        -- Error Level = Item Revision
                        --
                        ***************************************************/

                ELSIF l_error_level = G_REV_LEVEL
                THEN
                        --
                        -- Set the Revision record at the current entity_index
                        -- This will take care of scope = RECORD
                        --
                         x_bom_revision_tbl(p_entity_index).return_status :=
                                                         l_error_status;

                        IF l_error_scope = G_SCOPE_ALL
                        THEN
                                IF x_bom_revision_tbl.COUNT <> 0
                                THEN
                                        --
                                        -- Set all the revision record status
                                        --
                                        setRevisions
                                        (  p_other_mesg_text => l_other_message
                                         , p_other_status    => p_other_status
                                         , p_other_mesg_name => p_other_message
                                 	, p_bom_header_rec         =>x_bom_header_rec
                                 	, p_bom_revision_tbl  =>x_bom_revision_tbl
                                 	, p_bom_component_tbl    =>x_bom_component_tbl
                                 	, p_bom_ref_Designator_tbl =>x_bom_ref_Designator_tbl
                               	  	, p_bom_sub_component_tbl =>x_bom_sub_component_tbl
                         	        , p_bom_comp_ops_tbl =>g_bom_comp_ops_tbl
                                         );
                                END IF;

                                --
                                -- Set all the revised component's
                                -- status, this will then set the
                                -- status of the reference designators
                                -- and substitute components
                                --
                                setInventory_Components
                                (  p_other_mesg_text => l_other_message
                                 , p_other_status    => p_other_status
                                 , p_error_scope     => l_error_scope
                                 , p_other_mesg_name => p_other_message
                                 , p_bom_header_rec         =>x_bom_header_rec
                                 , p_bom_revision_tbl  =>x_bom_revision_tbl
                                 , p_bom_component_tbl    =>x_bom_component_tbl
                                 , p_bom_ref_Designator_tbl =>x_bom_ref_Designator_tbl
                                 , p_bom_sub_component_tbl =>x_bom_sub_component_tbl
                                 , p_bom_comp_ops_tbl =>g_bom_comp_ops_tbl
                                 );

                        END IF;
                        /********************************************
                        --
                        -- If the Error Level is Inventory COMPONENTS
                        --
                        *********************************************/
                ELSIF l_error_level = G_RC_LEVEL
                THEN
                        --
                        -- Set inventory component record at the entity_index
                        -- to error_status
                        -- This will take care of Scope = RECORD.
                        --
                        x_bom_component_tbl(p_entity_index).return_status :=
                                                l_error_status;

			Error_Handler.Write_Debug('Error Level = Inventory components . . .');

                        IF l_error_scope = G_SCOPE_SIBLINGS OR
                           l_error_scope = G_SCOPE_ALL
                        THEN
                                 setInventory_Components
                                (  p_other_mesg_text => l_other_message
                                 , p_other_status    => p_other_status
                                 , p_error_scope     => G_SCOPE_ALL
                                 , p_entity_index    => p_entity_index
                                 , p_other_mesg_name => p_other_message
                                 , p_bom_header_rec         =>x_bom_header_rec
                                 , p_bom_revision_tbl  =>x_bom_revision_tbl
                                 , p_bom_component_tbl    =>x_bom_component_tbl
                                 , p_bom_ref_Designator_tbl =>x_bom_ref_Designator_tbl
                                 , p_bom_sub_component_tbl =>x_bom_sub_component_tbl
                                 , p_bom_comp_ops_tbl =>g_bom_comp_ops_tbl
                                );
                        ELSIF l_error_scope = G_SCOPE_CHILDREN
                        THEN
                                IF x_bom_ref_designator_tbl.COUNT <> 0
                                THEN
                                        setRefDesignators
                                        (  p_error_scope     => l_error_scope
                                         , p_other_status    => p_other_status
                                         , p_other_mesg_text => l_other_message
                                         , p_rc_idx          => p_entity_index
                                         , p_other_mesg_name => p_other_message
                        	         , p_bom_header_rec         =>x_bom_header_rec
                               	  	, p_bom_revision_tbl  =>x_bom_revision_tbl
                                 	, p_bom_component_tbl    =>x_bom_component_tbl
                                 	, p_bom_ref_Designator_tbl =>x_bom_ref_Designator_tbl
                                  	, p_bom_sub_component_tbl =>x_bom_sub_component_tbl
                                	 , p_bom_comp_ops_tbl =>g_bom_comp_ops_tbl
                                         );
                                END IF;

                                IF x_bom_sub_component_tbl.COUNT <> 0
                                THEN
                                        setSubComponents
                                        (  p_error_scope     => l_error_scope
                                         , p_other_status    => p_other_status
                                         , p_other_mesg_text => l_other_message
                                         , p_rc_idx          => p_entity_index
                                         , p_other_mesg_name => p_other_message
                                         , p_bom_header_rec         =>x_bom_header_rec
                                         , p_bom_revision_tbl  =>x_bom_revision_tbl
                                         , p_bom_component_tbl    =>x_bom_component_tbl
                                         , p_bom_ref_Designator_tbl =>x_bom_ref_Designator_tbl
                                         , p_bom_sub_component_tbl =>x_bom_sub_component_tbl
                                         , p_bom_comp_ops_tbl =>g_bom_comp_ops_tbl
                                         );
                                END IF;
                                /* One to many operations suport */
                                IF g_bom_comp_ops_tbl.COUNT <> 0
                                THEN
                                        setCompOperations
                                        (  p_error_scope     => l_error_scope
                                         , p_other_status    => p_other_status
                                         , p_other_mesg_text => l_other_message
                                         , p_rc_idx          => p_entity_index
                                         , p_other_mesg_name => p_other_message
                                 	, p_bom_header_rec         =>x_bom_header_rec
                                 	, p_bom_revision_tbl  =>x_bom_revision_tbl
                                 	, p_bom_component_tbl    =>x_bom_component_tbl
                                 	, p_bom_ref_Designator_tbl =>x_bom_ref_Designator_tbl
                                 	, p_bom_sub_component_tbl =>x_bom_sub_component_tbl
                                 	, p_bom_comp_ops_tbl =>g_bom_comp_ops_tbl
                                         );
                                END IF;

                        END IF; -- scope = Siblings or All Ends
                        /***********************************************
                        --
                        -- If the Error Level is REFERENCE DESIGNATOR.
                        --
                        ************************************************/
                ELSIF l_error_level = G_RD_LEVEL
                THEN
                        --
                        -- Set reference designator record status at entity_idx
                        -- This will take care of Scope = RECORD.
                        --
			Error_Handler.Write_Debug('Error Level = Reference Designators . . .');

                        x_bom_ref_designator_tbl(p_entity_index).return_status
                                                := l_error_status;
                        IF l_error_scope <> G_SCOPE_RECORD
                        THEN
                                setRefDesignators
                                (  p_error_scope     => l_error_scope
                                 , p_other_status    => p_other_status
                                 , p_other_mesg_text => l_other_message
                                 , p_entity_index    => p_entity_index
                                 , p_other_mesg_name => p_other_message
                                 , p_bom_header_rec         =>x_bom_header_rec
                                 , p_bom_revision_tbl  =>x_bom_revision_tbl
                                 , p_bom_component_tbl    =>x_bom_component_tbl
                                 , p_bom_ref_Designator_tbl =>x_bom_ref_Designator_tbl
                                 , p_bom_sub_component_tbl =>x_bom_sub_component_tbl
                                 , p_bom_comp_ops_tbl =>g_bom_comp_ops_tbl
                                 );
                        END IF;
                        /***********************************************
                        --
                        -- If the Error Level is SUBSTITUTE COMPONENTS.
                        --
                        ************************************************/
                ELSIF l_error_level = G_SC_LEVEL
                THEN
                        -- Set substitute component record status at entity_idx
                        -- This will take care of Scope = RECORD.
                        --
			Error_Handler.Write_Debug('Error Level = Substitute Components . . .');

                        x_bom_sub_component_tbl(p_entity_index).return_status :=
                                                l_error_status;
                        IF l_error_scope <> G_SCOPE_RECORD
                        THEN
                                setSubComponents
                                (  p_error_scope     => l_error_scope
                                 , p_other_status    => p_other_status
                                 , p_other_mesg_text => l_other_message
                                 , p_entity_index    => p_entity_index
                                 , p_other_mesg_name => p_other_message
                                 , p_bom_header_rec         =>x_bom_header_rec
                                 , p_bom_revision_tbl  =>x_bom_revision_tbl
                                 , p_bom_component_tbl    =>x_bom_component_tbl
                                 , p_bom_ref_Designator_tbl =>x_bom_ref_Designator_tbl
                                 , p_bom_sub_component_tbl =>x_bom_sub_component_tbl
                                 , p_bom_comp_ops_tbl =>g_bom_comp_ops_tbl
                                 );
                        END IF;
                ELSIF l_error_level = G_COP_LEVEL
                THEN
                        -- Set component operation record status at entity_idx
                        -- This will take care of Scope = RECORD.
                        --
			Error_Handler.Write_Debug('Error Level = Component Operations . . .');

                        g_bom_comp_ops_tbl(p_entity_index).return_status :=
                                                l_error_status;
                        IF l_error_scope <> G_SCOPE_RECORD
                        THEN
                                setCompOperations
                                (  p_error_scope     => l_error_scope
                                 , p_other_status    => p_other_status
                                 , p_other_mesg_text => l_other_message
                                 , p_entity_index    => p_entity_index
                                 , p_other_mesg_name => p_other_message
                                 , p_bom_header_rec         =>x_bom_header_rec
                                 , p_bom_revision_tbl  =>x_bom_revision_tbl
                                 , p_bom_component_tbl    =>x_bom_component_tbl
                                 , p_bom_ref_Designator_tbl =>x_bom_ref_Designator_tbl
                                 , p_bom_sub_component_tbl =>x_bom_sub_component_tbl
                                 , p_bom_comp_ops_tbl =>g_bom_comp_ops_tbl
                                 );
                        END IF;

                END IF; -- Error Level  If Ends.

                --
                -- Copy the changed record/Tables to the out parameters for
                -- returing to the calling program.
                --
       	--         x_bom_header_rec        := g_bom_header_rec;
        --        x_bom_revision_tbl      := g_bom_revision_tbl;
        --        x_bom_component_tbl     := g_bom_component_tbl;
        --        x_bom_ref_designator_tbl:= g_bom_ref_designator_tbl;
        --        x_bom_sub_component_tbl := g_bom_sub_component_tbl;

        END Log_Error;


        /*********************************************************************
        * Procedure     : Initialize
        * Parameters    : None
        * Purpose       : This procedure will initialize the global message
        *                 list and reset the index variables to 0.
        *                 User must initialize the message list before using
        *                 it.
        **********************************************************************/
        PROCEDURE Initialize
        IS
        BEGIN

                G_Error_Table.DELETE;
                G_Msg_Count := 0;
                G_Msg_Index := 0;

        END Initialize;

        /********************************************************************
        * Procedure     : Reset
        * Parameters    : None
        * Purpose       : Reset will reset the message index to the begining
        *                 of the list and the user can start reading the
        *                 messages again.
        *********************************************************************/
        PROCEDURE Reset
        IS
        BEGIN

                g_Msg_Index := 0;

        END Reset;

        /********************************************************************
        * Procedure     : Get_Message_List
        * Parameters    : None
        * Purpose       : This procedure will return the entire message
        *                 table out the user. The returned list will be
        *                 for a particular business object.
        *********************************************************************/
        PROCEDURE Get_Message_List
        ( x_Message_List IN OUT NOCOPY Error_Handler.Error_Tbl_Type)
        IS
                l_bo_identifier VARCHAR2(30) := Error_Handler.Get_Bo_Identifier;
                l_msg_count     NUMBER := 1;

        BEGIN
                FOR l_err_idx IN 1..G_ERROR_TABLE.COUNT
                LOOP
                        IF G_Error_Table(l_err_idx).bo_identifier =
                           l_bo_identifier
                        THEN
                                x_message_list(l_msg_count) :=
                                        G_Error_Table(l_err_idx);
                                l_msg_Count := l_msg_count + 1;
                        END IF;
                END LOOP;

        END Get_Message_List;


        /********************************************************************
        * Procedure     : Get_Entity_Message
        * Parameters IN : Entity Id
        * Parameters OUT: Error List
        * Purpose       : This procedure will return all the messages for
        *                 a specific Entity.
        *********************************************************************/
        PROCEDURE Get_Entity_Message
        (  p_entity_id  IN  VARCHAR2
         , x_Message_List IN OUT NOCOPY Error_Handler.Error_Tbl_Type
        )
        IS
                l_Idx           NUMBER;
                l_Mesg_List     Error_Handler.Error_Tbl_Type;
                l_Count         NUMBER := 1;
                l_bo_identifier VARCHAR2(30) := Error_Handler.Get_Bo_Identifier;
        BEGIN
		Error_Handler.Write_Debug('Get Messages for Entity : ' || p_entity_id);
		Error_Handler.Write_Debug('Table Size = ' || to_char(G_Msg_Count));

                FOR l_Idx IN 1..NVL(G_Msg_Count, 0)
                LOOP
                        IF G_Error_Table(l_idx).entity_id = p_entity_id AND
                           G_Error_Table(l_Idx).bo_identifier = l_bo_identifier
                        THEN
                                l_mesg_list(l_count) := G_Error_Table(l_Idx);
                                l_Count := l_Count + 1;
                        END IF;
                END LOOP;
                x_Message_List := l_Mesg_List;

        END Get_Entity_Message;

        /*********************************************************************
        * Procedure     : Get_Entity_Message
        * Parameters IN : Entity Id
        *                 Entity Index
        * Parameters OUT: Message Text
        * Purpose       : This procedure will return all the  messages for
        *                 an entity and its index
        *********************************************************************/
        PROCEDURE Get_Entity_Message
        (  p_entity_id          IN  VARCHAR2
         , p_entity_index       IN  NUMBER
         , x_Message_List      IN OUT NOCOPY Error_Handler.Error_Tbl_Type
         )
        IS
                l_Mesg_List     Error_Handler.Error_Tbl_Type;
                l_Count         NUMBER := 1;
                l_bo_identifier VARCHAR2(30) := Error_Handler.Get_Bo_Identifier;
        BEGIN
                FOR l_Idx IN 1..NVL(G_Msg_Count, 0)
                LOOP
                        IF G_Error_Table(l_idx).entity_id = p_entity_id AND
                           G_Error_Table(l_idx).entity_index = p_entity_index
                           AND
                           G_Error_Table(l_idx).bo_identifier = l_bo_identifier
                        THEN
                                l_mesg_list(l_count) := G_Error_Table(l_Idx);
                                l_Count := l_Count + 1;
                        END IF;
                END LOOP;
                x_Message_List := l_Mesg_List;

        END Get_Entity_Message;

	/* This is a deprecated procedure */

	PROCEDURE Get_Entity_Message
    	(  p_entity_id      IN  VARCHAR2
    	 , p_entity_index   IN  NUMBER
    	 , x_message_text   IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2
    	 )
	 IS
	 BEGIN
		x_message_text := 'This method is no longer supported. Messages returned from this call could be more than one. Please use the other method which returns a list of messages';

		return;
	 END;

        /*********************************************************************
        * Procedure     : Get_Entity_Message
        * Parameters IN : Entity Id
        *                 Row Identifier
        * Parameters OUT: Message List
        * Purpose       : This procedure will return all the  messages for
        *                 an entity and its row identifier
        *********************************************************************/
        PROCEDURE Get_Entity_Message
        (  p_entity_id          IN  VARCHAR2
         , p_row_identifier     IN  NUMBER
         , x_Message_List      IN OUT NOCOPY Error_Handler.Error_Tbl_Type
         )
        IS
                l_Mesg_List     Error_Handler.Error_Tbl_Type;
                l_Count         NUMBER := 1;
                l_bo_identifier VARCHAR2(30) := Error_Handler.Get_Bo_Identifier;
        BEGIN
                FOR l_Idx IN 1..NVL(G_Msg_Count, 0)
                LOOP
                        IF G_Error_Table(l_idx).entity_id = p_entity_id AND
                           G_Error_Table(l_idx).row_identifier = p_row_identifier
                           AND
                           G_Error_Table(l_idx).bo_identifier = l_bo_identifier
                        THEN
                                l_mesg_list(l_count) := G_Error_Table(l_Idx);
                                l_Count := l_Count + 1;
                        END IF;
                END LOOP;
                x_Message_List := l_Mesg_List;

        END Get_Entity_Message;

        /*********************************************************************
        * Procedure     : Get_Entity_Message
        * Parameters IN : Entity Id
	*		  Table Name
        *                 Row Identifier
        * Parameters OUT: Message List
        * Purpose       : This procedure will return all the  messages for
        *                 an entity and its row identifier
        *********************************************************************/
        PROCEDURE Get_Entity_Message
        (  p_entity_id          IN  VARCHAR2
         , p_table_name         IN  VARCHAR2
         , p_row_identifier     IN  NUMBER
         , x_Message_List      IN OUT NOCOPY Error_Handler.Error_Tbl_Type
         )
        IS
                l_Mesg_List     Error_Handler.Error_Tbl_Type;
                l_Count         NUMBER := 1;
                l_bo_identifier VARCHAR2(30) := Error_Handler.Get_Bo_Identifier;
        BEGIN
                FOR l_Idx IN 1..NVL(G_Msg_Count, 0)
                LOOP
                        IF G_Error_Table(l_idx).entity_id = p_entity_id AND
                           G_Error_Table(l_idx).table_name = p_table_name AND
                           G_Error_Table(l_idx).row_identifier = p_row_identifier
                           AND
                           G_Error_Table(l_idx).bo_identifier = l_bo_identifier
                        THEN
                                l_mesg_list(l_count) := G_Error_Table(l_Idx);
                                l_Count := l_Count + 1;
                        END IF;
                END LOOP;
                x_Message_List := l_Mesg_List;

        END Get_Entity_Message;


        /*********************************************************************
        * Procedure     : Get_Message
        * Parameters    : None
        * Purpose       : This procedure will return the message at the current
        *                 message index and will advance the pointer to the
        *                 next number. If the user tries to retrieve beyond the
        *                 the size of the message list, then the message index
        *                 will be reset to the begining position.
        **********************************************************************/
        PROCEDURE Get_Message
        (  x_message_text        IN OUT NOCOPY VARCHAR2
         , x_entity_index        IN OUT NOCOPY NUMBER
         , x_entity_id           IN OUT NOCOPY VARCHAR2
         , x_message_type        IN OUT NOCOPY VARCHAR2
         )
        IS
        BEGIN
                IF G_Msg_Index = G_Msg_Count
                THEN
                        G_Msg_Index := 0;
                ELSE
                        G_Msg_Index := G_Msg_Index + 1;
                        x_message_text :=
                                G_Error_Table(g_Msg_Index).message_text;
                        x_entity_id :=
                                G_Error_Table(g_Msg_Index).entity_id;
                        x_entity_index :=
                                G_Error_Table(g_Msg_Index).entity_index;
                        x_message_type :=
                                G_Error_Table(g_Msg_Index).message_type;
                END IF;

        END Get_Message;

        /********************************************************************
        * Procedure     : Delete_Message
        * Parameters IN : Entity Id
        *                 Entity Index
        * Purpose       : This procedure will delete a message for an entity
        *                 record.
        **********************************************************************/
        PROCEDURE Delete_Message
        (  p_entity_id          IN  VARCHAR2
         , p_entity_index       IN  NUMBER
        )
        IS
                l_idx   NUMBER;
        BEGIN
                FOR l_Idx IN 1..G_Msg_Count
                LOOP
                        IF G_Error_Table(l_idx).entity_id = p_entity_id AND
                           G_Error_Table(l_idx).entity_index = p_entity_index
                        THEN
                               G_Error_Table.Delete(l_idx);
                               G_Msg_Count := G_Msg_Count - 1;
                        END IF;
                END LOOP;
        END Delete_Message;

        /********************************************************************
        * Procedure     : Delete_Message
        * Parameters IN : Entity Id
        * Purpose       : This procedure will delete all messages for an entity
        **********************************************************************/
        PROCEDURE Delete_Message
        (  p_entity_id          IN  VARCHAR2 )
        IS
                l_idx   NUMBER;
        BEGIN
                FOR l_Idx IN 1..G_Msg_Count
                LOOP
                        IF G_Error_Table(l_idx).entity_id = p_entity_id
                        THEN
                               G_Error_Table.Delete(l_idx);
                               G_Msg_Count := G_Msg_Count - 1;
                        END IF;
                END LOOP;
        END Delete_Message;


        /*********************************************************************
        * Function      : Get_Message_Count
        * Parameters    : None
        * Purpose       : Returns the current number of records in the message
        *                 list
        **********************************************************************/
        FUNCTION Get_Message_Count
        RETURN NUMBER
        IS
        BEGIN
                RETURN G_Msg_Count;
        END Get_Message_Count;

        /*********************************************************************
        * Function      : Dump_Message_List
        * Parameters    : None
        * Purpose       : Will generate a dump of the message list using
        *                 dbms_output.
        **********************************************************************/
        PROCEDURE Dump_Message_List
        IS
                l_idx   NUMBER;
        BEGIN
                Error_Handler.Write_Debug('Dumping Message List :');
                Error_Handler.Write_Debug('Number of Messages = '|| G_Error_Table.COUNT);

                FOR l_idx IN 1..G_Error_Table.COUNT LOOP
			Error_Handler.Write_Debug('Row Identifier : '||G_Error_Table(l_idx).row_identifier||'. Entity : '||G_Error_Table(l_idx).entity_id||'. Entity index : '||G_Error_Table(l_idx).entity_index||'. Table Name : '||G_Error_Table(l_idx).table_name );
                        Error_Handler.Write_Debug('Message: ' || G_Error_Table(l_idx).message_text);
                        Error_Handler.Write_Debug(' ');
                END LOOP;

        END Dump_Message_List;


        PROCEDURE Open_Debug_Session
        (  p_debug_filename     IN  VARCHAR2
         , p_output_dir         IN  VARCHAR2
         , x_return_status      IN OUT NOCOPY VARCHAR2
         , x_error_mesg         IN OUT NOCOPY VARCHAR2
         )
        IS
                l_found NUMBER := 0;
                l_utl_file_dir VARCHAR2(2000);
        BEGIN

                x_return_status := FND_API.G_RET_STS_SUCCESS;

		IF Error_Handler.Get_Debug <> 'Y'
		THEN
			/*
                        x_error_mesg := 'Debug mode is not set';
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        RETURN;
			*/
			-- Issue 3323376. The Get_Debug could be used as an indicator to identify
                        -- if the debug session is opened or not rather than using it as a prereq setup
			Error_Handler.Set_Debug('Y');
		END IF;

                select  value
                  INTO l_utl_file_dir
                  FROM v$parameter
                 WHERE name = 'utl_file_dir';

                l_found := INSTR(l_utl_file_dir, p_output_dir);

                IF l_found = 0
                THEN
                        x_error_mesg := 'Debug Session could not be started because the ' ||
                           ' output directory name is invalid. '             ||
                           ' Output directory must be one of the directory ' ||
                           ' value in v$parameter for name = utl_file_dir ';
                        x_return_status := FND_API.G_RET_STS_ERROR;
			Error_Handler.Set_Debug;
                        RETURN;
                END IF;

                --Changed to the *new* call of FOPEN, where we can pass
                --the MAXLINESIZE value. If we donot pass the default is
                --1023 chars. If we pass, the max value can be 32767 chars.
                Error_Handler.Debug_File := utl_file.fopen(  p_output_dir
                                                           , p_debug_filename
                                                           , 'w'
                                                           , 32767
                                                           );

                EXCEPTION
                        WHEN UTL_FILE.INVALID_PATH THEN
                        	x_error_mesg := 'Error opening Debug file . . . ' || sqlerrm;
                        	x_return_status := FND_API.G_RET_STS_ERROR;
				Error_Handler.Set_Debug;
        END Open_Debug_Session;


        PROCEDURE Open_Debug_Session
        (  p_debug_filename     IN  VARCHAR2
         , p_output_dir         IN  VARCHAR2
         , x_return_status      IN OUT NOCOPY VARCHAR2
         , p_mesg_token_tbl     IN  Error_Handler.Mesg_Token_Tbl_Type
         , x_mesg_Token_tbl     IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         )
        IS
                l_found NUMBER := 0;
                l_mesg_token_tbl Error_Handler.Mesg_Token_Tbl_Type :=
                                p_mesg_token_tbl;
                l_utl_file_dir VARCHAR2(2000);
        BEGIN

-- Enhancement
-- If BO is called by Open interface don't call this code.
   IF G_IS_BOM_OI then
      null;
   else
                select  value
                  INTO l_utl_file_dir
                  FROM v$parameter
                 WHERE name = 'utl_file_dir';

                l_found := INSTR(l_utl_file_dir, p_output_dir);

                IF l_found = 0
                THEN
                        Error_Handler.Add_Error_Token
                        (  p_Message_name       => NULL
                         , p_message_text       =>
                           ' Debug Session could not be started because the ' ||
                           ' output directory name is invalid. '             ||
                           ' Output directory must be one of the directory ' ||
                           ' value in v$parameter for name = utl_file_dir '  ||
                           ' If unsure leave out the value and the log will '||
                           ' be written to /sqlcom/log '
                         , x_mesg_token_tbl     => l_mesg_token_tbl
                         );
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        x_mesg_token_tbl := l_mesg_token_tbl;
                        RETURN;
                END IF;
                Error_Handler.Debug_File := utl_file.fopen(  p_output_dir
                                                           , p_debug_filename
                                                           , 'w');
   end if;
                x_return_status := FND_API.G_RET_STS_SUCCESS;

                EXCEPTION
                        WHEN UTL_FILE.INVALID_PATH THEN
                                Error_Handler.Add_Error_Token
                                (  p_message_name       => NULL
                                 , p_message_text       => 'Error opening Debug file . . . ' || sqlerrm
                                 , x_mesg_token_tbl     => l_mesg_token_tbl
                                 );
                        x_mesg_token_tbl := l_mesg_token_tbl;
        END Open_Debug_Session;

        PROCEDURE Write_Debug
        (  p_debug_message      IN  VARCHAR2 )
        IS
        BEGIN
          IF Error_Handler.Get_Debug = 'Y'
          THEN

            IF G_IS_BOM_OI then
              IF FND_PROFILE.VALUE('MRP_DEBUG') = 'Y' then
                  Fnd_File.Put_Line ( which => Fnd_File.LOG,
                                    buff  => p_debug_message );
                  Fnd_File.New_Line ( which => Fnd_File.LOG );
              END IF;
            ELSE
              utl_file.put_line(Error_Handler.Debug_File,p_debug_message);
            END IF;

          END IF;
        END Write_Debug;

        PROCEDURE Close_Debug_Session
        IS
        BEGIN

          -- Enhancement
          -- If BO is called by Open interface don't call this code.

          IF G_IS_BOM_OI THEN
            null;
          ELSE
            IF Error_Handler.Get_Debug = 'Y' THEN
              utl_file.fclose(Error_Handler.Debug_File);
	      Error_Handler.Set_Debug;
            END IF;
          END IF;

        END Close_Debug_Session;


	PROCEDURE Set_Bo_Identifier(p_bo_identifier        IN VARCHAR2)
	IS
	BEGIN
		G_BO_IDENTIFIER := p_bo_identifier;

	END Set_Bo_Identifier;

	FUNCTION  Get_Bo_Identifier RETURN VARCHAR2
	IS
	BEGIN
		RETURN G_BO_IDENTIFIER;
	END Get_Bo_Identifier;

        /* One to many support */

        PROCEDURE Set_Bom_Specific (p_bom_comp_ops_tbl  IN Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type)
        IS
        BEGIN
          g_bom_comp_ops_tbl := p_bom_comp_ops_tbl;
        END;

        PROCEDURE Get_Bom_Specific (x_bom_comp_ops_tbl IN OUT NOCOPY Bom_Bo_Pub.Bom_Comp_Ops_Tbl_Type)
        IS
        BEGIN
           x_bom_comp_ops_tbl := g_bom_comp_ops_tbl;
        END;

        /*********************************************************************
        * Function      : Write_To_InterfaceTable
        * Parameters    : None
        * Purpose       : To write the errors into the error interface table
        **********************************************************************/

	PROCEDURE Write_To_InterfaceTable
	IS
	  l_user_id           NUMBER   := Fnd_Global.User_Id;
	  l_login_id          NUMBER   := Fnd_Global.Login_Id;
	  l_request_id        NUMBER   := Fnd_Global.Conc_Request_Id;
	  l_program_id        NUMBER   := Null;
	  l_program_appl_id   NUMBER   := Null;
	  l_program_upd_date  DATE     := Null;

        BEGIN

	  Error_Handler.Write_Debug('Writing the messages into MTL_INTERFACE_ERRORS table : ');

	  Error_Handler.Write_Debug('Number of Messages = ' || G_Error_Table.COUNT);

	  IF l_request_id <> - 1
	  THEN
	    l_program_id        := Fnd_Global.Conc_program_Id;
	    l_program_appl_id   := Fnd_Global.prog_appl_id;
	    l_program_upd_date  := sysdate;
	  ELSE
	    l_request_id := Null;
	  END IF;

          FOR l_idx IN 1..G_Error_Table.COUNT
	  LOOP

	    INSERT INTO mtl_interface_errors
	      ( organization_id
		, unique_id
		, last_update_date
		, last_updated_by
		, creation_date
		, created_by
		, last_update_login
		, table_name
		, message_name
		, column_name
		, request_id
		, program_application_id
		, program_id
		, program_update_date
		, error_message
		, transaction_id
		, entity_identifier
		, bo_identifier)
	      VALUES
              ( G_Error_Table(l_idx).organization_id
                , mtl_system_items_interface_s.NEXTVAL
                , sysdate
                , l_user_id
                , sysdate
                , l_user_id
                , l_login_id
                , G_Error_Table(l_idx).table_name
                , G_Error_Table(l_idx).message_name
                , null
                , l_request_id
                , l_program_appl_id
                , l_program_id
                , l_program_upd_date
                , G_Error_Table(l_idx).message_text
		, G_Error_Table(l_idx).row_identifier
		, G_Error_Table(l_idx).entity_id
		, G_Error_Table(l_idx).bo_identifier);

    /* Fix for bug 4661753 - Insert message_name from G_Error_Table into mtl_interface_errors above.
		   Populate unique_id using  mtl_system_items_interface_s sequence. */

          END LOOP;

	END;

        /*********************************************************************
        * Function      : Write_To_ConcurrentLog
        * Parameters    : None
        * Purpose       : To write the errors into the concurrent program log file
        **********************************************************************/


	PROCEDURE Write_To_ConcurrentLog
        IS
          l_idx   NUMBER;
        BEGIN

	  Error_Handler.Write_Debug('Writing the messages into the log file : ');

	  Error_Handler.Write_Debug('Number of Messages = ' || G_Error_Table.COUNT);

          FOR l_idx IN 1..G_Error_Table.COUNT
	  LOOP

	    Fnd_File.Put( which => Fnd_File.LOG,
			  buff  => 'Entity: '||G_Error_Table(l_idx).entity_id||'.  ');

	    IF G_Error_Table(l_idx).row_identifier IS NOT NULL
	    THEN
	      Fnd_File.Put( which => Fnd_File.LOG,
			    buff  => 'Row Identifier: '||G_Error_Table(l_idx).row_identifier||'.  ');
	    END IF;

	    IF G_Error_Table(l_idx).entity_index IS NOT NULL
	    THEN
	      Fnd_File.Put( which => Fnd_File.LOG,
			    buff  => 'Entity index: '||G_Error_Table(l_idx).entity_index||'.  ');
	    END IF;

	    IF G_Error_Table(l_idx).table_name IS NOT NULL
	    THEN
	      Fnd_File.Put( which => Fnd_File.LOG,
			    buff  => 'Table Name: '||G_Error_Table(l_idx).table_name||'.');
	    END IF;

	    Fnd_File.New_Line ( which => Fnd_File.LOG );

	    Fnd_File.Put_Line( which => Fnd_File.LOG,
			       buff  => G_Error_Table(l_idx).message_text );

	    Fnd_File.New_Line ( which => Fnd_File.LOG );

	  END LOOP;

	END;


        /*********************************************************************
        * Function      : Write_To_DebugFile
        * Parameters    : No
        * Purpose       : To write the errors into the debug file
        **********************************************************************/

	PROCEDURE Write_To_DebugFile IS
	BEGIN
	  Dump_Message_List;
	END;

	PROCEDURE Log_Error(p_write_err_to_inttable   IN  VARCHAR2 := 'N'
                            ,p_write_err_to_conclog   IN  VARCHAR2 := 'N'
                            ,p_write_err_to_debugfile IN  VARCHAR2 := 'N')
	IS
	BEGIN

          IF p_write_err_to_inttable = 'Y'
          THEN
            Write_To_InterfaceTable;
          END IF;

          IF p_write_err_to_conclog = 'Y'
          THEN
            Write_To_ConcurrentLog;
          END IF;

          IF p_write_err_to_debugfile = 'Y'
          THEN
            Write_To_DebugFile;
          END IF;

	END;

	PROCEDURE Set_Debug (p_debug_flag IN VARCHAR2 := 'N')
	IS
	BEGIN
	  g_debug_flag := p_debug_flag;
	END;

	FUNCTION Get_Debug RETURN VARCHAR2
	IS
	BEGIN
	  Return g_debug_flag;
	END;

 /***************************************************************************
 * Function      : Set_BOM_OI
 * Returns       : None
 * Parameters IN : None
 * Parameters OUT: None
 * Purpose       : Procedure will set the value of G_IS_BOM_OI to TRUE
 *****************************************************************************/
 Procedure Set_BOM_OI
 IS
 BEGIN
         G_IS_BOM_OI := TRUE;

 End Set_BOM_OI;
 /***************************************************************************
 * Function      : UnSet_BOM_OI
 * Returns       : None
 * Parameters IN : None
 * Parameters OUT: None
 * Purpose       : Procedure will set the value of G_IS_BOM_OI to FALSE
 *****************************************************************************/
 Procedure UnSet_BOM_OI
 IS
 BEGIN
         G_IS_BOM_OI := FALSE;
 END UnSet_BOM_OI;


END Error_Handler;

/
