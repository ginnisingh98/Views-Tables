--------------------------------------------------------
--  DDL for Package Body ECO_ERROR_HANDLER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECO_ERROR_HANDLER" AS
/* $Header: ENGBOEHB.pls 120.1 2006/06/05 06:49:31 prgopala noship $ */
        g_eco_rec               ENG_Eco_Pub.Eco_Rec_Type;
        g_eco_revision_tbl      Eng_Eco_Pub.Eco_Revision_tbl_Type;
        g_revised_item_tbl      Eng_Eco_Pub.Revised_Item_Tbl_Type;
        g_rev_component_tbl     Bom_Bo_Pub.Rev_Component_Tbl_Type;
        g_ref_designator_tbl    Bom_Bo_Pub.Ref_Designator_Tbl_Type;
        g_sub_component_tbl     Bom_Bo_Pub.Sub_Component_Tbl_Type;

        /*******************************************************
        -- Followings are for ECO Routing
        ********************************************************/
        g_rev_operation_tbl          Bom_Rtg_Pub.Rev_Operation_Tbl_Type ;
        g_rev_op_resource_tbl        Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type ;
        g_rev_sub_resource_tbl       Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type ;
        -- Added by MK on 08/23/2000



        /*******************************************************
        -- Followings are for Eng Change
        ********************************************************/
        g_change_line_tbl            Eng_Eco_Pub.Change_Line_Tbl_Type ;
        -- Added by MK on 08/13/2002


        G_ERROR_TABLE           Error_Handler.Error_Tbl_Type;
        G_Msg_Index             NUMBER := 0;
        G_Msg_Count             NUMBER := 0;

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
        PROCEDURE setSubComponents
        (  p_error_scope        IN  VARCHAR2
         , p_other_mesg_text    IN  VARCHAR2
         , p_other_status       IN  VARCHAR2
         , p_ri_idx             IN  NUMBER := 0
         , p_rc_idx             IN  NUMBER := 0
         , p_rd_idx             IN  NUMBER := 0
         , p_entity_index       IN  NUMBER := 0
	 , p_other_mesg_name    IN  VARCHAR2 := NULL -- bug 5174203
        )
        IS
                l_idx   NUMBER;
        BEGIN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Setting substitute component records to ' ||
                       p_other_status);
END IF;

             IF p_error_scope = G_SCOPE_ALL
             THEN
                FOR l_idx IN 1..g_sub_component_tbl.COUNT
                LOOP
                        g_sub_component_tbl(l_idx).return_status :=
                                        p_other_status;
                        /* Put in fix in response to bug 851387
                        -- Added IF condition
                        -- Fix made by AS on 03/17/99
                        */
                        IF p_other_mesg_text IS NOT NULL
                        THEN
                                Error_Handler.Add_Message
                                (  p_mesg_text  => p_other_mesg_text
                                , p_entity_id   => G_SC_LEVEL
                                , p_entity_index=> l_idx
                                , p_message_type=> 'E'
				, p_mesg_name   => p_other_mesg_name);--bug 5174203
                        END IF;
                END LOOP;

             ELSIF p_error_scope = G_SCOPE_CHILDREN AND
                   p_ri_idx <> 0
             THEN
                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Scope=Children in Substitute Component'); END IF;
                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Revised Item index <> 0'); END IF;

                FOR l_idx IN 1..g_sub_component_tbl.COUNT
                LOOP
                   IF NVL(g_sub_component_tbl(l_idx).revised_item_name, ' ') =
                      NVL(g_revised_item_tbl(p_ri_idx).revised_item_name, ' ')
                      AND
                      NVL(g_sub_component_tbl(l_idx).organization_code,' ') =
                      NVL(g_revised_item_tbl(p_ri_idx).organization_code,' ') AND
                      NVL(g_sub_component_tbl(l_idx).eco_name,' ') =
                      NVL(g_revised_item_tbl(p_ri_idx).eco_name,' ') AND
                      NVL(g_sub_component_tbl(l_idx).start_effective_date, SYSDATE) =
                      NVL(g_revised_item_tbl(p_ri_idx).start_effective_date, SYSDATE) AND
                      NVL(g_sub_component_tbl(l_idx).new_revised_item_revision, 'X') =
                      NVL(g_revised_item_tbl(p_ri_idx).new_revised_item_revision, 'X')
                    THEN
                        g_sub_component_tbl(l_idx).return_status :=
                                        p_other_status;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Substitute Component at ' || to_char(l_idx) || ' set to status ' ||
                p_other_status);
END IF;

                        Error_Handler.Add_Message
                        (  p_mesg_text     => p_other_mesg_text
                         , p_entity_id     => G_SC_LEVEL
                         , p_entity_index  => l_idx
                         , p_message_type  => 'E'
            		 , p_mesg_name     => p_other_mesg_name);--bug 5174203
                     END IF;
                END LOOP;
             ELSIF p_error_scope = G_SCOPE_CHILDREN AND
                   p_rc_idx <> 0
             THEN

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Scope=Children in Substitute Component'); END IF;
                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Revised Component index <> 0'); END IF;

                FOR l_idx IN 1..g_sub_component_tbl.COUNT
                LOOP
                    IF NVL(g_sub_component_tbl(l_idx).component_item_name, ' ')=
                       NVL(g_rev_component_tbl(p_rc_idx).component_item_name,' '
                          ) AND
                       NVL(g_sub_component_tbl(l_idx).start_effective_date,
                           SYSDATE ) =
                       NVL(g_rev_component_tbl(p_rc_idx).start_effective_date,
                           SYSDATE )
                       AND
                       NVL(g_sub_component_tbl(l_idx).operation_sequence_number, 0) =
                       NVL(g_rev_component_tbl(p_rc_idx).operation_sequence_number, 0)
                       AND
                       NVL(g_sub_component_tbl(l_idx).revised_item_name, ' ') =
                       NVL(g_rev_component_tbl(p_rc_idx).revised_item_name, ' ')
                       AND
                       NVL(g_sub_component_tbl(l_idx).new_revised_item_revision, 'X') =
                       NVL(g_rev_component_tbl(p_rc_idx).new_revised_item_revision, 'X')
                       AND
                       NVL(g_sub_component_tbl(l_idx).eco_name, ' ') =
                       NVL(g_rev_component_tbl(p_rc_idx).eco_name, ' ') AND
                       NVL(g_sub_component_tbl(l_idx).organization_code, ' ') =
                       NVL(g_rev_component_tbl(p_rc_idx).organization_code, ' ')
                    THEN
                        --
                        -- Since bill sequence id is not available
                        -- match the revised item information also.
                        --
                        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
                       ('Substitute Comp. at ' || to_char(l_idx) || ' set to '
                                || p_other_status);
                        END IF;

                        g_sub_component_tbl(l_idx).return_status :=
                                                p_other_status;
                        Error_Handler.Add_Message
                        (  p_mesg_text          => p_other_mesg_text
                         , p_entity_id          => G_SC_LEVEL
                         , p_entity_index       => l_idx
                         , p_message_type       => 'E'
			 , p_mesg_name          => p_other_mesg_name);--bug 5174203
                    END IF;
                END LOOP;  -- Ref. Desg Children of Rev Comps Ends.

             ELSIF p_error_scope = G_SCOPE_SIBLINGS AND
                   p_rd_idx <> 0
             THEN

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Scope = Siblings in Sub. Components'); END IF;
                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Reference Desg Index <> 0'); END IF;

                FOR l_idx IN 1..g_sub_component_tbl.COUNT
                LOOP
                    IF NVL(g_sub_component_tbl(l_idx).component_item_name,' ') =
                       NVL(g_ref_designator_tbl(p_rd_idx).component_item_name, ' ') AND
                       NVL(g_sub_component_tbl(l_idx).start_effective_date, SYSDATE) =
                       NVL(g_ref_designator_tbl(p_rd_idx).start_effective_date, SYSDATE)
                       AND
                       NVL(g_sub_component_tbl(l_idx).operation_sequence_number, 0) =
                       NVL(g_ref_designator_tbl(p_rd_idx).operation_sequence_number, 0)
                       AND
                       NVL(g_sub_component_tbl(l_idx).revised_item_name, ' ') =
                       NVL(g_ref_designator_tbl(p_rd_idx).revised_item_name, ' ')
                       AND
                       NVL(g_sub_component_tbl(l_idx).new_revised_item_revision, 'X') =
                       NVL(g_ref_designator_tbl(p_rd_idx).new_revised_item_revision, 'X')
                       AND
                       NVL(g_sub_component_tbl(l_idx).eco_name, ' ') =
                       NVL(g_ref_designator_tbl(p_rd_idx).eco_name, ' ') AND
                       NVL(g_sub_component_tbl(l_idx).organization_code, ' ') =
                       NVL(g_ref_designator_tbl(p_rd_idx).organization_code, ' ')
                    THEN
                        --
                        -- Since bill sequence id is not available
                        -- match the revised item information also.
                        --
                        g_sub_component_tbl(l_idx).return_status :=
                                                p_other_status;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Substitute Component at ' || to_char(l_idx) || ' set to status ' ||
                       p_other_status);
END IF;
                        Error_Handler.Add_Message
                        (  p_mesg_text          => p_other_mesg_text
                         , p_entity_id          => G_SC_LEVEL
                         , p_entity_index       => l_idx
                         , p_message_type       => 'E'
			 , p_mesg_name          => p_other_mesg_name);--bug 5174203
                    END IF;

                END LOOP; -- Scope = Siblings with rd_idx <> 0 Ends

             ELSIF p_error_scope = G_SCOPE_SIBLINGS AND
                   p_ri_idx = 0 AND
                   p_rc_idx = 0 AND
                   p_rd_idx = 0
             THEN
                --
                -- This situation will arise when rev. item and rev comp and
                -- reference designator are not part of the business object
                -- input data.
                -- Match the component key information at the entity index
                -- location with rest of the records, all those that are found
                -- will be siblings and should get an error.
                --
                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Scope=Siblings in Substitute Component'); END IF;
                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('All entity indexes = 0'); END IF;


                FOR l_idx IN (p_entity_index+1)..g_sub_component_tbl.COUNT
                LOOP
                    IF NVL(g_sub_component_tbl(l_idx).component_item_name, ' ') =
                       NVL(g_sub_component_tbl(p_entity_index).component_item_name, ' ')
                       AND
                       NVL(g_sub_component_tbl(l_idx).start_effective_date, SYSDATE) =
                       NVL(g_sub_component_tbl(p_entity_index).start_effective_date, SYSDATE)
                       AND
                       NVL(g_sub_component_tbl(l_idx).operation_sequence_number, 0) =
                       NVL(g_sub_component_tbl(p_entity_index).operation_sequence_number, 0)
                       AND
                       NVL(g_sub_component_tbl(l_idx).revised_item_name, ' ') =
                       NVL(g_sub_component_tbl(p_entity_index).revised_item_name, ' ')
                       AND
                       NVL(g_sub_component_tbl(l_idx).new_revised_item_revision, 'X') =
                       NVL(g_sub_component_tbl(p_entity_index).new_revised_item_revision, 'X')
                       AND
                       NVL(g_sub_component_tbl(l_idx).eco_name, ' ') =
                       NVL(g_sub_component_tbl(p_entity_index).eco_name, ' ') AND
                       NVL(g_sub_component_tbl(l_idx).organization_code, ' ') =
                       NVL(g_sub_component_tbl(p_entity_index).organization_code, ' ')
                    THEN
                        --
                        -- Since bill sequence id is not available
                        -- match the revised item information also.
                        --
                        g_sub_component_tbl(l_idx).return_status :=
                                                p_other_status;
                        Error_Handler.Add_Message
                        (  p_mesg_text          => p_other_mesg_text
                         , p_entity_id          => G_SC_LEVEL
                         , p_entity_index       => l_idx
                         , p_message_type       => 'E'
			 , p_mesg_name          => p_other_mesg_name);--bug 5174203
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
        PROCEDURE setRefDesignators
        (  p_error_scope        IN  VARCHAR2
         , p_other_mesg_text    IN  VARCHAR2
         , p_other_status       IN  VARCHAR2
         , p_ri_idx             IN  NUMBER := 0
         , p_rc_idx             IN  NUMBER := 0
         , p_entity_index       IN  NUMBER := 0
	 , p_other_mesg_name    IN  VARCHAR2 := NULL -- bug 5174203
        )
        IS
                l_idx   NUMBER;
        BEGIN

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Setting reference designator records to '
                     ||  p_other_status);
END IF;

             IF p_error_scope = G_SCOPE_ALL
             THEN
                FOR l_idx IN (p_entity_index+1)..g_ref_designator_tbl.COUNT
                LOOP
                        g_ref_designator_tbl(l_idx).return_status :=
                                        p_other_status;
                        /* Put in fix in response to bug 851387
                        -- Added IF condition
                        -- Fix made by AS on 03/17/99
                        */
                        IF p_other_mesg_text IS NOT NULL
                        THEN
                                Error_Handler.Add_Message
                                (  p_mesg_text  => p_other_mesg_text
                                , p_entity_id   => G_RD_LEVEL
                                , p_entity_index=> l_idx
                                , p_message_type=> 'E'
				, p_mesg_name   => p_other_mesg_name);--bug 5174203
                        END IF;
                END LOOP;
                --
                -- Set the Substitute Components Record Status too
                --
                setSubComponents
                (  p_other_status       => p_other_status
                 , p_other_mesg_text    => p_other_mesg_text
                 , p_error_scope        => p_error_scope
		 , p_other_mesg_name    => p_other_mesg_name --bug 5174203
                 );
             ELSIF p_error_scope = G_SCOPE_CHILDREN AND
                   p_ri_idx <> 0
             THEN

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Scope=Children in Reference Designator'); END IF;
                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Revised Item index <> 0'); END IF;


                FOR l_idx IN 1..g_ref_designator_tbl.COUNT
                LOOP
                   IF NVL(g_ref_designator_tbl(l_idx).revised_item_name, ' ') =
                      NVL(g_revised_item_tbl(p_ri_idx).revised_item_name, ' ') AND
                      NVL(g_Ref_Designator_tbl(l_idx).organization_code, ' ') =
                      NVL(g_revised_item_tbl(p_ri_idx).organization_code, ' ') AND
                      NVL(g_Ref_Designator_tbl(l_idx).eco_name, ' ') =
                      NVL(g_revised_item_tbl(p_ri_idx).eco_name, ' ') AND
                      NVL(g_Ref_Designator_tbl(l_idx).start_effective_date, SYSDATE) =
                      NVL(g_revised_item_tbl(p_ri_idx).start_effective_date, SYSDATE) AND
                      NVL(g_Ref_Designator_tbl(l_idx).new_revised_item_revision, 'X') =
                      NVL(g_revised_item_tbl(p_ri_idx).new_revised_item_revision, 'X')
                    THEN
                        g_ref_designator_tbl(l_idx).return_status :=
                                        p_other_status;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Ref. Designator at ' || to_char(l_idx) || ' set to status ' ||
                      p_other_status);
END IF;

                        Error_Handler.Add_Message
                        (  p_mesg_text     => p_other_mesg_text
                         , p_entity_id     => G_RD_LEVEL
                         , p_entity_index  => l_idx
                         , p_message_type  => 'E'
			 , p_mesg_name     => p_other_mesg_name);--bug 5174203
                     END IF;
                END LOOP;

             ELSIF p_error_scope = G_SCOPE_CHILDREN AND
                   p_rc_idx <> 0
             THEN

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Scope=Children in Reference Designator'); END IF;
                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Revised Component index <> 0'); END IF;

                FOR l_idx IN 1..g_ref_designator_tbl.COUNT
                LOOP
                    IF NVL(g_ref_designator_tbl(l_idx).component_item_name, ' ') =
                       NVL(g_rev_component_tbl(p_rc_idx).component_item_name, ' ') AND
                       NVL(g_ref_designator_tbl(l_idx).start_effective_date, SYSDATE) =
                       NVL(g_rev_component_tbl(p_rc_idx).start_effective_date, SYSDATE) AND
                       NVL(g_ref_designator_tbl(l_idx).operation_sequence_number, 0) =
                       NVL(g_rev_component_tbl(p_rc_idx).operation_sequence_number, 0)
                       AND
                       NVL(g_ref_designator_tbl(l_idx).revised_item_name, ' ') =
                       NVL(g_rev_component_tbl(p_rc_idx).revised_item_name, ' ') AND
                       NVL(g_ref_designator_tbl(l_idx).new_revised_item_revision , 'X') =
                       NVL(g_rev_component_tbl(p_rc_idx).new_revised_item_revision, 'X')
                       AND
                       NVL(g_ref_designator_tbl(l_idx).eco_name, ' ') =
                       NVL(g_rev_component_tbl(p_rc_idx).eco_name, ' ') AND
                       NVL(g_ref_designator_tbl(l_idx).organization_code, ' ')=
                       NVL(g_rev_component_tbl(p_rc_idx).organization_code, ' ')
                    THEN
                        --
                        -- Since bill sequence id is not available
                        -- match the revised item information also.
                        --
                        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
                        ('Refernce Desg. at ' || to_char(l_idx) || ' set to '
                                || p_other_status);
                        END IF;

                        g_ref_designator_tbl(l_idx).return_status :=
                                                p_other_status;
                        Error_Handler.Add_Message
                        (  p_mesg_text          => p_other_mesg_text
                         , p_entity_id          => G_RD_LEVEL
                         , p_entity_index       => l_idx
                         , p_message_type       => 'E'
			 , p_mesg_name          => p_other_mesg_name);--bug 5174203
                    END IF;
                END LOOP;  -- Ref. Desg Children of Rev Comps Ends.

             ELSIF p_error_scope = G_SCOPE_SIBLINGS AND
                   p_ri_idx = 0 AND
                   p_rc_idx = 0
             THEN
                --
                -- This situation will arise when rev. item and rev comp are
                -- not part of the business object input data.
                -- Match the component key information at the entity index
                -- location with rest of the records, all those that are found
                -- will be siblings and should get an error.
                --

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Scope=Siblings in Reference Designator'); END IF;
                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('All Indexes = 0'); END IF;

                FOR l_idx IN (p_entity_index+1)..g_ref_designator_tbl.COUNT
                LOOP
                    IF NVL(g_ref_designator_tbl(l_idx).component_item_name, ' ') =
                       NVL(g_ref_designator_tbl(p_entity_index).component_item_name, ' ')
                       AND
                       NVL(g_ref_designator_tbl(l_idx).start_effective_date, SYSDATE) =
                       NVL(g_ref_designator_tbl(p_entity_index).start_effective_date, SYSDATE)
                       AND
                       NVL(g_ref_designator_tbl(l_idx).operation_sequence_number, 0) =
                       NVL(g_ref_designator_tbl(p_entity_index).operation_sequence_number, 0)
                       AND
                       NVL(g_ref_designator_tbl(l_idx).revised_item_name, ' ') =
                       NVL(g_ref_designator_tbl(p_entity_index).revised_item_name, ' ')
                       AND
                       NVL(g_ref_designator_tbl(l_idx).new_revised_item_revision, 'X') =
                       NVL(g_ref_designator_tbl(p_entity_index).new_revised_item_revision, 'X')
                       AND
                       NVL(g_ref_designator_tbl(l_idx).eco_name, ' ') =
                       NVL(g_ref_designator_tbl(p_entity_index).eco_name, ' ') AND
                       NVL(g_ref_designator_tbl(l_idx).organization_code, ' ') =
                       NVL(g_ref_designator_tbl(p_entity_index).organization_code, ' ')
                    THEN
                        --
                        -- Since bill sequence id is not available
                        -- match the revised item information also.
                        --
                        g_ref_designator_tbl(l_idx).return_status :=
                                                p_other_status;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Ref. Designator at ' || to_char(l_idx) || ' set to status ' ||
                       p_other_status);
END IF;

                        Error_Handler.Add_Message
                        (  p_mesg_text          => p_other_mesg_text
                         , p_entity_id          => G_RD_LEVEL
                         , p_entity_index       => l_idx
                         , p_message_type       => 'E'
		   	 , p_mesg_name          => p_other_mesg_name);--bug 5174203
                    END IF;
                END LOOP;

                --
                -- Substitute Components will also be considered as siblings
                -- of reference designators, they should get an error when
                -- error level is reference designator with scope of Siblings
                --
                setSubComponents
                (  p_other_status       => p_other_status
                 , p_other_mesg_text    => p_other_mesg_text
                 , p_error_scope        => p_error_scope
                 , p_rd_idx             => p_entity_index
		 , p_other_mesg_name    => p_other_mesg_name --bug 5174203
                 );
             END IF; -- If error scope Ends

        END setRefDesignators;

        /*****************************************************************
        * Procedure     : setRevisedComponents (unexposed)
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
        PROCEDURE setRevisedComponents
        (  p_error_scope        IN  VARCHAR2
         , p_other_mesg_text    IN  VARCHAR2
         , p_other_status       IN  VARCHAR2
         , p_entity_index       IN  NUMBER := 0
         , p_ri_idx             IN  NUMBER := 0
	 , p_other_mesg_name    IN  VARCHAR2 := NULL -- bug 5174203
         )
        IS
                l_Idx           NUMBER;
        BEGIN

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Setting Revised component records to '
                                || p_other_status);
                END IF;

                IF p_error_scope = G_SCOPE_CHILDREN AND
                   p_ri_idx <> 0
                THEN

                    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Scope=Children in Revised Component'); END IF;
                    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Revised Item index <> 0'); END IF;

                    FOR l_idx IN 1..g_rev_component_tbl.COUNT
                    LOOP
                        IF NVL(g_rev_component_tbl(l_Idx).eco_name, ' ') =
                           NVL(g_revised_item_tbl(p_ri_idx).eco_name, ' ') AND
                           NVL(g_rev_component_tbl(l_Idx).revised_item_name, ' ') =
                           NVL(g_revised_item_tbl(p_ri_idx).revised_item_name, ' ') AND
                           NVL(g_rev_component_tbl(l_Idx).organization_code, ' ') =
                           NVL(g_revised_item_tbl(p_ri_idx).organization_code, ' ') AND
                           NVL(g_rev_component_tbl(l_Idx).new_revised_item_revision, 'X') =
                           NVL(g_revised_item_tbl(p_ri_idx).new_revised_item_revision, 'X')
                           AND
                           NVL(g_rev_component_tbl(l_Idx).start_effective_date, SYSDATE) =
                           NVL(g_revised_item_tbl(p_ri_idx).start_effective_date, SYSDATE)
                        THEN

                                --
                                -- If the revised item key of the component
                                -- matches that of the revised item then
                                -- error that revised component too.
                                --

                                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
                                ('Comp. errored at index: '||to_char(l_idx));
                                END IF;

                                g_rev_component_tbl(l_Idx).return_status :=
                                        p_other_status;

                               Error_Handler.Add_Message
                               (  p_mesg_text  => p_other_mesg_text
                               , p_entity_id   => G_RC_LEVEL
                               , p_entity_index=> l_Idx
                               , p_message_type=> 'E'
			       , p_mesg_name   => p_other_mesg_name);--bug 5174203
                        END IF;

                END LOOP;
                                --
                                -- For each of the component child
                                -- set the reference designator and
                                -- substitute component childrens
                                --
                                SetRefDesignators
                                (  p_error_scope        => p_error_scope
                                 , p_other_mesg_text    => p_other_mesg_text
                                 , p_other_status       => p_other_status
                                 , p_ri_idx             => p_ri_idx
				 , p_other_mesg_name    => p_other_mesg_name --bug 5174203
                                 );

                                SetSubComponents
                                (  p_error_scope        => p_error_scope
                                 , p_other_mesg_text    => p_other_mesg_text
                                 , p_other_status       => p_other_status
                                 , p_ri_idx             => p_ri_idx
				 , p_other_mesg_name    => p_other_mesg_name --bug 5174203
                                 );
                ELSIF p_error_scope = G_SCOPE_SIBLINGS THEN

                   IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Scope=Siblings in Revised Component'); END IF;
                   IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity Index: ' ||
                                to_char(p_entity_index));
                   END IF;

                      FOR l_idx IN 1..g_rev_component_tbl.COUNT
                      LOOP
                                --
                                -- If there are any other components that
                                -- belong to the same revised item then error
                                -- those records too.
                                --
                              IF NVL(g_rev_component_tbl(l_Idx).eco_name, ' ') =
                                 NVL(g_rev_component_tbl(p_entity_index).eco_name, ' ')
                                 AND
                                 NVL(g_rev_component_tbl(l_Idx).revised_item_name, ' ') =
                                 NVL(g_rev_component_tbl(p_entity_index).revised_item_name,
                                 ' ')
                                 AND
                                 NVL(g_rev_component_tbl(l_Idx).organization_code, ' ')=
                                 NVL(g_rev_component_tbl(p_entity_index).organization_code, ' ') AND
                                 NVL(g_rev_component_tbl(l_Idx).new_revised_item_revision, 'X') =
                                 NVL(g_rev_component_tbl(p_entity_index).new_revised_item_revision, 'X')
                                 AND
                                 NVL(g_rev_component_tbl(l_Idx).start_effective_date, SYSDATE)
                                 =
                                 NVL(g_rev_component_tbl(p_entity_index).start_effective_date,
                                 SYSDATE)
                              THEN
                                        --
                                        -- Set the Component error status
                                        --
                                 g_rev_component_tbl(l_idx).return_status :=
                                                p_other_status;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Revised Component at ' || to_char(l_idx) || ' set to status ' ||
                      p_other_status);
END IF;

                                 Error_Handler.Add_Message
                                 (  p_mesg_text    => p_other_mesg_text
                                  , p_entity_id    => G_RC_LEVEL
                                  , p_entity_index => l_idx
                                  , p_message_type => 'E'
 				  , p_mesg_name    => p_other_mesg_name);--bug 5174203

                                 --
                                 -- Set an child records of the revised
                                 -- component to other status too.
                                 --
                                 setRefDesignators
                                 (  p_other_status    => p_other_status
                                  , p_error_scope     => G_SCOPE_CHILDREN
                                  , p_rc_idx          => l_idx
                                  , p_other_mesg_text => p_other_mesg_text
				  , p_other_mesg_name => p_other_mesg_name --bug 5174203
                                  );

                                 setSubComponents
                                 (  p_other_status    => p_other_status
                                  , p_error_scope     => G_SCOPE_CHILDREN
                                  , p_rc_idx          => l_idx
                                  , p_other_mesg_text => p_other_mesg_text
				  , p_other_mesg_name => p_other_mesg_name --bug 5174203
                                  );

                              END IF; -- Component Siblings Found Ends
                        END LOOP;
                ELSIF p_error_scope = G_SCOPE_ALL
                THEN

                    IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Scope=All in Revised Component'); END IF;

                    FOR l_idx IN 1..g_rev_component_tbl.COUNT
                    LOOP
                        g_rev_component_tbl(l_idx).return_status :=
                                                p_other_status;
                        /* Put in fix in response to bug 851387
                        -- Added IF condition
                        -- Fix made by AS on 03/17/99
                        */
                        IF p_other_mesg_text IS NOT NULL
                        THEN
                                Error_Handler.Add_Message
                                (  p_mesg_text  => p_other_mesg_text
                                , p_entity_id   => G_RC_LEVEL
                                , p_entity_index=> l_Idx
                                , p_message_type=> 'E'
				, p_mesg_name   => p_other_mesg_name);--bug 5174203
                        END IF;

                    END LOOP;

                        --
                        -- Set the reference designator and substitute
                        -- component record status too.
                        --
                    setRefDesignators
                    (  p_other_status    => p_other_status
                     , p_error_scope     => p_error_scope
                     , p_other_mesg_text => p_other_mesg_text
		     , p_other_mesg_name => p_other_mesg_name --bug 5174203
                     );

                     /*** Substitute Component called from Reference designator
                     setSubComponents
                     (  p_other_status    => p_other_status
                      , p_error_scope     => p_error_scope
                      , p_other_mesg_text => p_other_mesg_text
		      , p_other_mesg_name       => p_other_mesg_name --bug 5174203
                      );
                     ***/

                END IF; -- Error Scope Ends

        END setRevisedComponents;



        /*****************************************************************
        * Procedure     : setChangeLines(unexposed)
        * Parameters IN : Other Message Text
        *                 Other status
        *                 Entity Index
        * Parameters OUT: None
        * Purpose       : This procedure will set the Eng Change Line record
        *                 status to other status and for each errored record
        *                 it will log the other message indicating what caused
        *                 the other records to fail.
        ******************************************************************/
        PROCEDURE setChangeLines
        (  p_other_mesg_text    IN  VARCHAR2
         , p_other_status       IN  VARCHAR2
	 , p_other_mesg_name    IN  VARCHAR2 := NULL -- bug 5174203
        )
        IS
                l_CurrentIndex  NUMBER;
        BEGIN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Setting Change Line records to ' || p_other_status); END IF;

                FOR l_CurrentIndex IN  1..g_change_line_tbl.COUNT
                LOOP
                        g_change_line_tbl(l_CurrentIndex).return_status := p_other_status;

                        IF p_other_mesg_text IS NOT NULL
                        THEN
                                Error_Handler.Add_Message
                                (  p_mesg_text          => p_other_mesg_text
                                 , p_entity_id          => G_CL_LEVEL
                                 , p_entity_index       => l_CurrentIndex
                                 , p_message_type       => 'E'
				 , p_mesg_name          => p_other_mesg_name);--bug 5174203
                        END IF;
                END LOOP;

        END setChangeLines ;

        /*****************************************************************
        * Procedure     : setRevisions (unexposed)
        * Parameters IN : Other Message Text
        *                 Other status
        *                 Entity Index
        * Parameters OUT: None
        * Purpose       : This procedure will set the ECO Revisions record
        *                 status to other status and for each errored record
        *                 it will log the other message indicating what caused
        *                 the other records to fail.
        ******************************************************************/
        PROCEDURE setRevisions
        (  p_other_mesg_text    IN  VARCHAR2
         , p_other_status       IN  VARCHAR2
	 , p_other_mesg_name    IN  VARCHAR2 := NULL -- bug 5174203
        )
        IS
                l_CurrentIndex  NUMBER;
        BEGIN

                IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Setting ECO Revision records to ' || p_other_status); END IF;

                FOR l_CurrentIndex IN  1..g_eco_revision_tbl.COUNT
                LOOP
                        g_eco_revision_tbl(l_CurrentIndex).return_status :=
                                                p_other_status;
                        /* Put in fix in response to bug 851387
                        -- Added IF condition
                        -- Fix made by AS on 03/17/99
                        */
                        IF p_other_mesg_text IS NOT NULL
                        THEN
                                Error_Handler.Add_Message
                                (  p_mesg_text          => p_other_mesg_text
                                 , p_entity_id          => G_REV_LEVEL
                                 , p_entity_index       => l_CurrentIndex
                                 , p_message_type       => 'E'
  				 , p_mesg_name          => p_other_mesg_name);--bug 5174203
                        END IF;
                END LOOP;

        END setRevisions;


    /*****************************************************************
    *
    *     Followings are enhacements for ECO Routing
    *
    ******************************************************************/

    /******************************************************************
    * Enhancement for ECO Routing
    * Added by Masanori Kimizka on 08/23/00
    *
    * Procedure     : setRevSubResources (Unexposed)
    * Parameters    : Other Message
    *                 Other Status
    *                 Error Scope
    *                 Entity Index
    *                 Operation Index
    *                 Operation Resource Index
    * Purpose       : This procedure will set the reference designator
    *                 record status to other status by looking at the
    *                 revised item key or the revised component key or
    *                 else setting all the record status to other status
    ********************************************************************/
    PROCEDURE setRevSubResources
    (  p_error_scope        IN  VARCHAR2
     , p_other_mesg_text    IN  VARCHAR2
     , p_other_status       IN  VARCHAR2
     , p_ri_idx             IN  NUMBER := 0
     , p_op_idx             IN  NUMBER := 0
     , p_res_idx            IN  NUMBER := 0
     , p_entity_index       IN  NUMBER := 0
     , p_other_mesg_name    IN  VARCHAR2 := NULL -- bug 5174203
    )
    IS
        l_idx   NUMBER;
    BEGIN

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Setting sub operation resources records to ' || p_other_status); END IF ;

        IF p_error_scope = G_SCOPE_ALL
        THEN
            FOR l_idx IN 1..g_rev_sub_resource_tbl.COUNT
            LOOP
                g_rev_sub_resource_tbl(l_idx).return_status := p_other_status;

                IF p_other_mesg_text IS NOT NULL
                THEN
                       Error_Handler.Add_Message
                       (  p_mesg_text  => p_other_mesg_text
                        , p_entity_id   => G_SR_LEVEL
                        , p_entity_index=> l_idx
                        , p_message_type=> 'E'
			, p_mesg_name   => p_other_mesg_name);--bug 5174203
                END IF;
            END LOOP;

        ELSIF p_error_scope = G_SCOPE_CHILDREN AND
              p_ri_idx <> 0
        THEN

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Scope=Children in Sub Op Resource'); END IF;
IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Revised Item index <> 0'); END IF;

            FOR l_idx IN 1..g_rev_sub_resource_tbl.COUNT
            LOOP
                   IF NVL(g_rev_sub_resource_tbl(l_idx).revised_item_name, ' ') =
                      NVL(g_revised_item_tbl(p_ri_idx).revised_item_name, ' ')
                      AND
                      NVL(g_rev_sub_resource_tbl(l_idx).organization_code,' ') =
                      NVL(g_revised_item_tbl(p_ri_idx).organization_code,' ')
                      AND
                      NVL(g_rev_sub_resource_tbl(l_idx).eco_name,' ') =
                      NVL(g_revised_item_tbl(p_ri_idx).eco_name,' ')
                      AND
                      NVL(g_rev_sub_resource_tbl(l_idx).op_start_effective_date, SYSDATE) =
                      NVL(g_revised_item_tbl(p_ri_idx).start_effective_date, SYSDATE)
                      AND
                      NVL(g_rev_sub_resource_tbl(l_idx).new_revised_item_revision, 'X') =
                      NVL(g_revised_item_tbl(p_ri_idx).new_revised_item_revision, 'X')
                    THEN
                        g_rev_sub_resource_tbl(l_idx).return_status := p_other_status;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Sub Op Resource at ' || to_char(l_idx) || ' set to status ' ||  p_other_status);
END IF;

                        Error_Handler.Add_Message
                        (  p_mesg_text     => p_other_mesg_text
                         , p_entity_id     => G_SR_LEVEL
                         , p_entity_index  => l_idx
                         , p_message_type  => 'E'
			 , p_mesg_name     => p_other_mesg_name);--bug 5174203
                    END IF;
              END LOOP;

         ELSIF p_error_scope = G_SCOPE_CHILDREN AND
               p_op_idx <> 0
         THEN

             IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Scope=Children in Sub Op Resources'); END IF;
             IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Operation Sequence index <> 0'); END IF;

             FOR l_idx IN 1..g_rev_sub_resource_tbl.COUNT
             LOOP
                   IF NVL(g_rev_sub_resource_tbl(l_idx).operation_sequence_number, 0 ) =
                      NVL(g_rev_operation_tbl(p_op_idx).operation_sequence_number, 0 )
                   AND
                      NVL(g_rev_sub_resource_tbl(l_idx).op_start_effective_date, SYSDATE) =
                      NVL(g_rev_operation_tbl(p_op_idx).start_effective_date, SYSDATE)
                   AND
                      NVL(g_rev_sub_resource_tbl(l_idx).operation_type, 0) =
                      NVL(g_rev_operation_tbl(p_op_idx).operation_type, 0)
                   AND
                      NVL(g_rev_sub_resource_tbl(l_idx).revised_item_name, ' ') =
                      NVL(g_rev_operation_tbl(p_op_idx).revised_item_name, ' ')
                   AND
                      NVL(g_rev_sub_resource_tbl(l_idx).new_revised_item_revision , 'X') =
                      NVL(g_rev_operation_tbl(p_op_idx).new_revised_item_revision, 'X')
                   AND
                      NVL(g_rev_sub_resource_tbl(l_idx).eco_name, ' ') =
                      NVL(g_rev_operation_tbl(p_op_idx).eco_name, ' ')
                   THEN
                        g_rev_sub_resource_tbl(l_idx).return_status := p_other_status ;
                        Error_Handler.Add_Message
                        (  p_mesg_text          => p_other_mesg_text
                         , p_entity_id          => G_SR_LEVEL
                         , p_entity_index       => l_idx
                         , p_message_type       => 'E'
			 , p_mesg_name          => p_other_mesg_name);--bug 5174203
                    END IF;
                END LOOP;  -- Sub Res Children of Op Seq Ends.

         ELSIF p_error_scope = G_SCOPE_SIBLINGS AND p_res_idx <> 0
         THEN

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Scope = Siblings in Sub Op Resources'); END IF;
IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Operation Resource Index <> 0'); END IF ;

                FOR l_idx IN 1..g_rev_sub_resource_tbl.COUNT
                LOOP
                   IF NVL(g_rev_sub_resource_tbl(l_idx).operation_sequence_number, 0) =
                      NVL(g_rev_op_resource_tbl(p_res_idx).operation_sequence_number, 0)
                   AND
                      NVL(g_rev_sub_resource_tbl(l_idx).op_start_effective_date, SYSDATE) =
                      NVL(g_rev_op_resource_tbl(p_res_idx).op_start_effective_date,SYSDATE)
                   AND
                      NVL(g_rev_sub_resource_tbl(l_idx).operation_type, 0) =
                      NVL(g_rev_op_resource_tbl(p_res_idx).operation_type, 0)
                   AND
                      NVL(g_rev_sub_resource_tbl(l_idx).revised_item_name, ' ') =
                      NVL(g_rev_op_resource_tbl(p_res_idx).revised_item_name, ' ')
                   AND
                      NVL(g_rev_sub_resource_tbl(l_idx).new_revised_item_revision, 'X') =
                      NVL(g_rev_op_resource_tbl(p_res_idx).new_revised_item_revision, 'X')
                   AND
                      NVL(g_rev_sub_resource_tbl(l_idx).eco_name, ' ') =
                      NVL(g_rev_op_resource_tbl(p_res_idx).eco_name, ' ')
                   THEN
                        --
                        -- Since routing sequence id is not available
                        -- match the revised item information also.
                        --
                        g_rev_sub_resource_tbl(l_idx).return_status :=
                                                p_other_status;

                        Error_Handler.Add_Message
                        (  p_mesg_text          => p_other_mesg_text
                         , p_entity_id          => G_SR_LEVEL
                         , p_entity_index       => l_idx
                         , p_message_type       => 'E'
			 , p_mesg_name          => p_other_mesg_name);--bug 5174203
                    END IF;

                END LOOP; -- Scope = Siblings with res_idx <> 0 Ends

             ELSIF p_error_scope = G_SCOPE_SIBLINGS AND
                   p_ri_idx = 0 AND
                   p_op_idx = 0 AND
                   p_res_idx = 0
             THEN
                --
                -- This situation will arise when operation sequence and
                -- operation resource are not part of the business object
                -- input data.
                -- Match the operation key information at the entity index
                -- location with rest of the records, all those that are found
                -- will be siblings and should get an error.
                --
IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Scope=Siblings in Sub Op Resources'); END IF;
IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('All entity indexes = 0'); END IF;

                FOR l_idx IN (p_entity_index+1)..g_rev_sub_resource_tbl.COUNT
                LOOP
                    IF NVL(g_rev_sub_resource_tbl(l_idx).operation_sequence_number, 0) =
                       NVL(g_rev_sub_resource_tbl(p_entity_index).operation_sequence_number, 0)
                       AND
                       NVL(g_rev_sub_resource_tbl(l_idx).op_start_effective_date, SYSDATE) =
                       NVL(g_rev_sub_resource_tbl(p_entity_index).op_start_effective_date, SYSDATE)
                       AND
                       NVL(g_rev_sub_resource_tbl(l_idx).operation_type, 0) =
                       NVL(g_rev_sub_resource_tbl(p_entity_index).operation_type, 0)
                       AND
                       NVL(g_rev_sub_resource_tbl(l_idx).revised_item_name, ' ') =
                       NVL(g_rev_sub_resource_tbl(p_entity_index).revised_item_name, ' ')
                       AND
                       NVL(g_rev_sub_resource_tbl(l_idx).new_revised_item_revision, 'X') =
                       NVL(g_rev_sub_resource_tbl(p_entity_index).new_revised_item_revision, 'X')
                       AND
                       NVL(g_rev_sub_resource_tbl(l_idx).eco_name, ' ') =
                       NVL(g_rev_sub_resource_tbl(p_entity_index).eco_name, ' ')
                   THEN
                        g_rev_sub_resource_tbl(l_idx).return_status := p_other_status;
                        Error_Handler.Add_Message
                        (  p_mesg_text          => p_other_mesg_text
                         , p_entity_id          => G_SR_LEVEL
                         , p_entity_index       => l_idx
                         , p_message_type       => 'E'
			 , p_mesg_name          => p_other_mesg_name);--bug 5174203
                    END IF;
                END LOOP;
         END IF; -- If Scope = Ends.

    END setRevSubResources;
    -- Added by MK on 08/23/00


    /******************************************************************
    * Enhancement for ECO Routing
    * Added by Masanori Kimizka on 08/23/00
    *
    * Procedure : setRevOperationResources (Unexposed)
    * Parameters    : Other Message
    *                 Other Status
    *                 Error Scope
    *                 Entity Index
    *                 Operation Index
    * Purpose   : This procedure will set the operation resource
    *             record status to other status by looking at the
    *             operation sequence key or else setting all the record
    *             status to other status
    ********************************************************************/

    PROCEDURE setRevOperationResources
    (  p_error_scope        IN  VARCHAR2
     , p_other_mesg_text    IN  VARCHAR2
     , p_other_status       IN  VARCHAR2
     , p_ri_idx             IN  NUMBER := 0
     , p_op_idx             IN  NUMBER := 0
     , p_entity_index       IN  NUMBER := 0
     , p_other_mesg_name    IN  VARCHAR2 := NULL -- bug 5174203
    )
    IS
        l_idx   NUMBER;
    BEGIN

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Setting Opration Rsource records to ' ||  p_other_status);
END IF;


        IF p_error_scope = G_SCOPE_ALL
        THEN



           FOR l_idx IN (p_entity_index+1)..g_rev_op_resource_tbl.COUNT
           LOOP
           g_rev_op_resource_tbl(l_idx).return_status := p_other_status;

               IF p_other_mesg_text IS NOT NULL
               THEN
                  Error_Handler.Add_Message
                  ( p_mesg_text     => p_other_mesg_text
                  , p_entity_id     => G_RES_LEVEL
                  , p_entity_index  => l_idx
                  , p_message_type  => 'E'
		  , p_mesg_name     => p_other_mesg_name);--bug 5174203
               END IF;
           END LOOP;

            --
            -- Set the Substitute Operation Resources Record Status too
            --
            setRevSubResources
            (  p_other_status       => p_other_status
             , p_other_mesg_text    => p_other_mesg_text
             , p_error_scope        => p_error_scope
             );

         ELSIF p_error_scope = G_SCOPE_CHILDREN AND
               p_ri_idx <> 0
         THEN

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Scope=Children in Operation Resource'); END IF;
IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Revised Item index <> 0'); END IF;


                FOR l_idx IN 1..g_rev_op_resource_tbl.COUNT
                LOOP
                   IF NVL(g_rev_op_resource_tbl(l_idx).revised_item_name, ' ') =
                      NVL(g_revised_item_tbl(p_ri_idx).revised_item_name, ' ')
                      AND
                      NVL(g_rev_op_resource_tbl(l_idx).organization_code, ' ') =
                      NVL(g_revised_item_tbl(p_ri_idx).organization_code, ' ')
                      AND
                      NVL(g_rev_op_resource_tbl(l_idx).eco_name, ' ') =
                      NVL(g_revised_item_tbl(p_ri_idx).eco_name, ' ')
                      AND
                      NVL(g_rev_op_resource_tbl(l_idx).op_start_effective_date, SYSDATE) =
                      NVL(g_revised_item_tbl(p_ri_idx).start_effective_date, SYSDATE)
                      AND
                      NVL(g_rev_op_resource_tbl(l_idx).new_revised_item_revision, 'X') =
                      NVL(g_revised_item_tbl(p_ri_idx).new_revised_item_revision, 'X')
                    THEN
                        g_rev_op_resource_tbl(l_idx).return_status := p_other_status;

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Op Resource at ' || to_char(l_idx) || ' set to status ' || p_other_status);
END IF;

                        Error_Handler.Add_Message
                        (  p_mesg_text     => p_other_mesg_text
                         , p_entity_id     => G_RES_LEVEL
                         , p_entity_index  => l_idx
                         , p_message_type  => 'E'
			 , p_mesg_name     => p_other_mesg_name);--bug 5174203
                     END IF;
                END LOOP;

        ELSIF p_error_scope = G_SCOPE_CHILDREN AND
              p_op_idx <> 0
        THEN

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Scope=Children in Operation Resource'); END IF;
IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Operation Sequence index <> 0'); END IF;

            FOR l_idx IN 1..g_rev_op_resource_tbl.COUNT
            LOOP
                IF NVL(g_rev_op_resource_tbl(l_idx).operation_sequence_number, 0)=
                   NVL(g_rev_operation_tbl(p_op_idx).operation_sequence_number, 0)
                   AND
                   NVL(g_rev_op_resource_tbl(l_idx).op_start_effective_date, SYSDATE) =
                   NVL(g_rev_operation_tbl(p_op_idx).start_effective_date, SYSDATE)
                   AND
                   NVL(g_rev_op_resource_tbl(l_idx).operation_type, 0) =
                   NVL(g_rev_operation_tbl(p_op_idx).operation_type, 0)
                   AND
                   NVL(g_rev_op_resource_tbl(l_idx).revised_item_name, ' ') =
                   NVL(g_rev_operation_tbl(p_op_idx).revised_item_name, ' ')
                   AND
                   NVL(g_rev_op_resource_tbl(l_idx).new_revised_item_revision , 'X') =
                   NVL(g_rev_operation_tbl(p_op_idx).new_revised_item_revision, 'X')
                   AND
                   NVL(g_rev_op_resource_tbl(l_idx).eco_name, ' ') =
                   NVL(g_rev_operation_tbl(p_op_idx).eco_name, ' ')
                THEN

                    g_rev_op_resource_tbl(l_idx).return_status := p_other_status;
                    Error_Handler.Add_Message
                    (  p_mesg_text      => p_other_mesg_text
                     , p_entity_id      => G_RES_LEVEL
                     , p_entity_index   => l_idx
                     , p_message_type   => 'E'
		     , p_mesg_name      => p_other_mesg_name);--bug 5174203
                END IF;
            END LOOP;  -- Op Resource Children of Op Seq Ends.

        ELSIF p_error_scope = G_SCOPE_SIBLINGS AND
              p_ri_idx = 0 AND p_op_idx = 0
        THEN
        --
        -- This situation will arise when Rev Item and Op Seq is
        -- not part of the business object input data.
        -- Match the operation key information at the entity index
        -- location with rest of the records, all those that are found
        -- will be siblings and should get an error.
        --

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Scope=Siblings in Operation Resource'); END IF;
IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('All Indexes = 0'); END IF;

            FOR  l_idx IN (p_entity_index+1)..g_rev_op_resource_tbl.COUNT
            LOOP
                IF NVL(g_rev_op_resource_tbl(l_idx).operation_sequence_number, 0) =
                   NVL(g_rev_op_resource_tbl(p_entity_index).operation_sequence_number,0)
                   AND
                   NVL(g_rev_op_resource_tbl(l_idx).op_start_effective_date, SYSDATE) =
                   NVL(g_rev_op_resource_tbl(p_entity_index).op_start_effective_date, SYSDATE)
                   AND
                   NVL(g_rev_op_resource_tbl(l_idx).operation_type, 0) =
                   NVL(g_rev_op_resource_tbl(p_entity_index).operation_type, 0)
                   AND
                   NVL(g_rev_op_resource_tbl(l_idx).revised_item_name, ' ') =
                   NVL(g_rev_op_resource_tbl(p_entity_index).revised_item_name, ' ')
                   AND
                   NVL(g_rev_op_resource_tbl(l_idx).new_revised_item_revision , 'X') =
                   NVL(g_rev_op_resource_tbl(p_entity_index).new_revised_item_revision, 'X')
                   AND
                   NVL(g_rev_op_resource_tbl(l_idx).eco_name, ' ') =
                   NVL(g_rev_op_resource_tbl(p_entity_index).eco_name, ' ')
                THEN

                g_rev_op_resource_tbl(l_idx).return_status := p_other_status;
                Error_Handler.Add_Message
                (  p_mesg_text      => p_other_mesg_text
                 , p_entity_id      => G_RES_LEVEL
                 , p_entity_index   => l_idx
                 , p_message_type   => 'E'
		 , p_mesg_name      => p_other_mesg_name);--bug 5174203
                END IF;
            END LOOP;

        --
        -- Substitute Operation Resources will also be considered as siblings
        -- of operation resource, they should get an error when
        -- error level is operation resource with scope of Siblings
                --
            setRevSubResources
            (  p_other_status       => p_other_status
             , p_other_mesg_text    => p_other_mesg_text
             , p_error_scope        => p_error_scope
             , p_res_idx            => p_entity_index
            );
       END IF; -- If error scope Ends

    END setRevOperationResources ;


    /*****************************************************************
    * Enhancement for ECO Routing
    * Added by Masanori Kimizka on 08/23/00
    *
    * Procedure     : setRevOperationSequences (Unexposed)
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
    PROCEDURE setRevOperationSequences
    (  p_error_scope        IN  VARCHAR2
     , p_other_mesg_text    IN  VARCHAR2
     , p_other_status       IN  VARCHAR2
     , p_entity_index       IN  NUMBER := 0
     , p_ri_idx             IN  NUMBER := 0
     , p_other_mesg_name    IN  VARCHAR2 := NULL -- bug 5174203
     )
    IS
        l_Idx       NUMBER;
    BEGIN

       IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Setting Revised operation records to '
       || p_other_status);
       END IF;

       IF p_error_scope = G_SCOPE_CHILDREN AND
          p_ri_idx <> 0
       THEN

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Scope=Children in Revised Operation'); END IF;
IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Revised Item index <> 0'); END IF;

           FOR l_idx IN 1..g_rev_operation_tbl.COUNT
           LOOP
               IF NVL(g_rev_operation_tbl(l_Idx).eco_name, ' ') =
                  NVL(g_revised_item_tbl(p_ri_idx).eco_name, ' ')
                  AND
                  NVL(g_rev_operation_tbl(l_Idx).revised_item_name, ' ') =
                  NVL(g_revised_item_tbl(p_ri_idx).revised_item_name, ' ')
                  AND
                  NVL(g_rev_operation_tbl(l_Idx).organization_code, ' ') =
                  NVL(g_revised_item_tbl(p_ri_idx).organization_code, ' ')
                  AND
                  NVL(g_rev_operation_tbl(l_Idx).new_revised_item_revision, 'X') =
                  NVL(g_revised_item_tbl(p_ri_idx).new_revised_item_revision, 'X')
                  AND
                  NVL(g_rev_operation_tbl(l_Idx).start_effective_date, SYSDATE) =
                  NVL(g_revised_item_tbl(p_ri_idx).start_effective_date, SYSDATE)
               THEN

                    --
                    -- If the revised item key of the operation
                    -- matches that of the revised item then
                    -- error that revised operation too.
                    --

                    IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug
                    ('Comp. errored at index: '||to_char(l_idx));
                    END IF;

                        g_rev_operation_tbl(l_Idx).return_status := p_other_status;

                        Error_Handler.Add_Message
                        (  p_mesg_text  => p_other_mesg_text
                        , p_entity_id   => G_OP_LEVEL
                        , p_entity_index=> l_Idx
                        , p_message_type=> 'E'
			, p_mesg_name   => p_other_mesg_name);--bug 5174203
               END IF;

           END LOOP;

           --
           -- For each of the operation child
           -- set the operation resources and
           -- substitute op resources childrens
           --
           --

           setRevOperationResources
           (  p_error_scope       => p_error_scope
            , p_other_mesg_text    => p_other_mesg_text
            , p_other_status       => p_other_status
            , p_ri_idx             => p_ri_idx
            );

           setRevSubResources
           (  p_error_scope        => p_error_scope
            , p_other_mesg_text    => p_other_mesg_text
            , p_other_status       => p_other_status
            , p_ri_idx             => p_ri_idx
            );

        ELSIF p_error_scope = G_SCOPE_SIBLINGS THEN

        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Scope=Siblings in Revised Operation'); END IF;
        IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity Index: ' ||
        to_char(p_entity_index));
        END IF;

            FOR l_idx IN 1..g_rev_component_tbl.COUNT
            LOOP
                --
                -- If there are any other components that
                -- belong to the same revised item then error
                -- those records too.
                --
                IF NVL(g_rev_operation_tbl(l_Idx).eco_name, ' ') =
                NVL(g_rev_operation_tbl(p_entity_index).eco_name, ' ')
                AND
                NVL(g_rev_operation_tbl(l_Idx).revised_item_name, ' ') =
                NVL(g_rev_operation_tbl(p_entity_index).revised_item_name, ' ')
                AND
                NVL(g_rev_operation_tbl(l_Idx).organization_code, ' ')=
                NVL(g_rev_operation_tbl(p_entity_index).organization_code, ' ')
                AND
                NVL(g_rev_operation_tbl(l_Idx).new_revised_item_revision, 'X') =
                NVL(g_rev_operation_tbl(p_entity_index).new_revised_item_revision, 'X')
                AND
                NVL(g_rev_operation_tbl(l_Idx).start_effective_date, SYSDATE)=
                NVL(g_rev_operation_tbl(p_entity_index).start_effective_date,SYSDATE)
                THEN
                    --
                    -- Set the operation error status
                    --
                    g_rev_operation_tbl(l_idx).return_status :=  p_other_status;

IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Revised Operation at ' || to_char(l_idx) || ' set to status ' ||p_other_status);
END IF;
                    Error_Handler.Add_Message
                    (  p_mesg_text    => p_other_mesg_text
                     , p_entity_id    => G_RC_LEVEL
                     , p_entity_index => l_idx
                     , p_message_type => 'E'
 		     , p_mesg_name    => p_other_mesg_name);--bug 5174203

                     --
                     -- Set an child records of the revised
                     -- operation to other status too.
                     --
                     setRevOperationResources
                     (  p_other_status    => p_other_status
                      , p_error_scope     => G_SCOPE_CHILDREN
                      , p_op_idx          => l_idx
                      , p_other_mesg_text => p_other_mesg_text
                      );

                      setRevSubResources
                      (  p_other_status    => p_other_status
                       , p_error_scope     => G_SCOPE_CHILDREN
                       , p_op_idx          => l_idx
                       , p_other_mesg_text => p_other_mesg_text
                      );

                END IF; -- Operation Siblings Found Ends
            END LOOP;

        ELSIF p_error_scope = G_SCOPE_ALL
        THEN

            IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Scope=All in Operation Sequences'); END IF;

            FOR l_idx IN 1..g_rev_operation_tbl.COUNT
            LOOP
               g_rev_operation_tbl(l_idx).return_status := p_other_status;

               IF p_other_mesg_text IS NOT NULL
               THEN
                  Error_Handler.Add_Message
                  ( p_mesg_text    => p_other_mesg_text
                  , p_entity_id    => G_OP_LEVEL
                  , p_entity_index => l_Idx
                  , p_message_type => 'E'
		  , p_mesg_name    => p_other_mesg_name);--bug 5174203
               END IF;

            END LOOP;

            --
            -- Set the operation resource and substitute
            -- operation resource record status too.
            --
            setRevOperationResources
                    (  p_other_status    => p_other_status
                     , p_error_scope     => p_error_scope
                     , p_other_mesg_text => p_other_mesg_text
                     );

        END IF; -- Error Scope Ends

    END setRevOperationSequences ;
    -- Added by MK 08/23/2000



        /*****************************************************************
        * Procedure     : setRevisedItems (unexposed)
        * Parameters IN : Other Message Text
        *                 Other status
        *                 Entity Index
        *                 Error Scope
        *                 Error Status
        * Parameters OUT: None
        * Purpose       : This procedure will set the Revised Items record
        *                 status to other status and for each errored record
        *                 it will log the other message indicating what caused
        *                 the other records to fail.
        ******************************************************************/
        PROCEDURE setRevisedItems
        (  p_error_status       IN  VARCHAR2 := NULL
         , p_error_scope        IN  VARCHAR2
         , p_other_mesg_text    IN  VARCHAR2
         , p_other_status       IN  VARCHAR2
         , p_entity_index       IN  NUMBER := 0
	 , p_other_mesg_name    IN  VARCHAR2 := NULL -- bug 5174203
        )
        IS
                l_CurrentIndex  NUMBER;
        BEGIN
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Setting Revised Item  records to ' || p_other_status); END IF;

                FOR l_CurrentIndex IN 1..g_revised_item_tbl.COUNT
                LOOP
                        g_revised_item_tbl(l_CurrentIndex).return_status :=
                                p_other_status;

                /* Put in fix in response to bug 851387
                -- Added IF condition
                -- Fix made by AS on 03/17/99
                */
                IF p_other_mesg_text IS NOT NULL
                        THEN
                                Error_Handler.Add_Message
                                (  p_mesg_text          => p_other_mesg_text
                                 , p_entity_id          => G_RI_LEVEL
                                 , p_entity_index       => l_CurrentIndex
                                 , p_message_type       => 'E'
				 , p_mesg_name          => p_other_mesg_name);--bug 5174203
                        END IF;
                END LOOP;

        END setRevisedItems;

        /******************************************************************
        * Procedure     : Log_Error
        * Parameters IN : ECO Header record and rest of the Entity Tables
        *                 Message Token Table
        *                 Other Message Table
        *                 Other Status
        *                 Entity Index
        *                 Error Level
        *                 Error Scope
        *                 Error Status
        * Parameters OUT: ECO Header record and rest of the Entity Tables
        * Purpose       : Log Error will take the Message Token Table and
        *                 seperate the message and their tokens, get the
        *                 token substitute messages from the message dictionary
        *                 and put in the error stack.
        *                 Log Error will also make sure that the error
        *                 propogates to the right level's of the business object
        *                 and that the rest of the entities get the appropriate
        *                 status and message.
        ******************************************************************/


        /* Comment out by MK on 08/23/2000 ***********************************
        PROCEDURE Log_Error
        (  p_eco_rec            IN  ENG_Eco_Pub.Eco_Rec_Type :=
                                               Eng_Eco_Pub.G_MISS_ECO_REC
         , p_eco_revision_tbl   IN  Eng_Eco_Pub.Eco_Revision_tbl_Type
                                    := Eng_Eco_Pub.G_MISS_ECO_REVISION_TBL
         , p_revised_item_tbl   IN  Eng_Eco_Pub.Revised_Item_Tbl_Type
                                          := Eng_Eco_Pub.G_MISS_REVISED_ITEM_TBL
         , p_rev_component_tbl  IN  Bom_Bo_Pub.Rev_Component_Tbl_Type
                                       := Bom_Bo_Pub.G_MISS_REV_COMPONENT_TBL
         , p_ref_designator_tbl IN  Bom_Bo_Pub.Ref_Designator_Tbl_Type
                                      := Bom_Bo_Pub.G_MISS_REF_DESIGNATOR_TBL
         , p_sub_component_tbl  IN  Bom_Bo_Pub.Sub_Component_Tbl_Type
                                       := Bom_Bo_Pub.G_MISS_SUB_COMPONENT_TBL
         , p_Mesg_Token_tbl     IN  Error_Handler.Mesg_Token_Tbl_Type
                                          := Error_Handler.G_MISS_MESG_TOKEN_TBL
         , p_error_status       IN  VARCHAR2
         , p_error_scope        IN  VARCHAR2 := NULL
         , p_other_message      IN  VARCHAR2 := NULL
         , p_other_status       IN  VARCHAR2 := NULL
         , p_other_token_tbl    IN  Error_Handler.Token_Tbl_Type
                                          := Error_Handler.G_MISS_TOKEN_TBL
         , p_error_level        IN  NUMBER
         , p_entity_index       IN  NUMBER := NULL
         , x_eco_rec            OUT ENG_Eco_Pub.Eco_Rec_Type
         , x_eco_revision_tbl   OUT Eng_Eco_Pub.Eco_Revision_tbl_Type
         , x_revised_item_tbl   OUT Eng_Eco_Pub.Revised_Item_Tbl_Type
         , x_rev_component_tbl  OUT Bom_Bo_Pub.Rev_Component_Tbl_Type
         , x_ref_designator_tbl OUT Bom_Bo_Pub.Ref_Designator_Tbl_Type
         , x_sub_component_tbl  OUT Bom_Bo_Pub.Sub_Component_Tbl_Type
         )
        ***********************************************************************/



        /*******************************************************
        -- Log_Error prodedure used for ECO Routing enhancement
        --
        -- Added rev op, rev op res and rev sub res error handling
        -- to existed Log_Error procedure
        --
        -- Modified by MK on 08/23/2000
        ********************************************************/
        PROCEDURE Log_Error
        (  p_eco_rec            IN  ENG_Eco_Pub.Eco_Rec_Type :=
                                               Eng_Eco_Pub.G_MISS_ECO_REC
         , p_eco_revision_tbl   IN  Eng_Eco_Pub.Eco_Revision_tbl_Type
                                    := Eng_Eco_Pub.G_MISS_ECO_REVISION_TBL
         , p_revised_item_tbl   IN  Eng_Eco_Pub.Revised_Item_Tbl_Type
                                    := Eng_Eco_Pub.G_MISS_REVISED_ITEM_TBL

         -- Followings are for Routing BO
         , p_rev_operation_tbl    IN  Bom_Rtg_Pub.Rev_Operation_Tbl_Type
                                      := Bom_Rtg_Pub.G_MISS_REV_OPERATION_TBL
         , p_rev_op_resource_tbl  IN  Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type
                                      := Bom_Rtg_Pub.G_MISS_REV_OP_RESOURCE_TBL
         , p_rev_sub_resource_tbl IN  Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type
                                      := Bom_Rtg_Pub.G_MISS_REV_SUB_RESOURCE_TBL
         -- Added by MK on 08/23/2000

         , p_rev_component_tbl  IN  Bom_Bo_Pub.Rev_Component_Tbl_Type
                                       := Eng_Eco_Pub.G_MISS_REV_COMPONENT_TBL
         , p_ref_designator_tbl IN  Bom_Bo_Pub.Ref_Designator_Tbl_Type
                                      := Eng_Eco_Pub.G_MISS_REF_DESIGNATOR_TBL
         , p_sub_component_tbl  IN  Bom_Bo_Pub.Sub_Component_Tbl_Type
                                       := Eng_Eco_Pub.G_MISS_SUB_COMPONENT_TBL
         , p_Mesg_Token_tbl     IN  Error_Handler.Mesg_Token_Tbl_Type
                                    := Error_Handler.G_MISS_MESG_TOKEN_TBL
         , p_error_status       IN  VARCHAR2
         , p_error_scope        IN  VARCHAR2 := NULL
         , p_other_message      IN  VARCHAR2 := NULL
         , p_other_status       IN  VARCHAR2 := NULL
         , p_other_token_tbl    IN  Error_Handler.Token_Tbl_Type
                                          := Error_Handler.G_MISS_TOKEN_TBL
         , p_error_level        IN  NUMBER
         , p_entity_index       IN  NUMBER := 1 -- := NULL
         , x_eco_rec            IN OUT NOCOPY ENG_Eco_Pub.Eco_Rec_Type
         , x_eco_revision_tbl   IN OUT NOCOPY Eng_Eco_Pub.Eco_Revision_tbl_Type
         , x_revised_item_tbl   IN OUT NOCOPY Eng_Eco_Pub.Revised_Item_Tbl_Type
         , x_rev_component_tbl  IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Tbl_Type
         , x_ref_designator_tbl IN OUT NOCOPY Bom_Bo_Pub.Ref_Designator_Tbl_Type
         , x_sub_component_tbl  IN OUT NOCOPY Bom_Bo_Pub.Sub_Component_Tbl_Type

         -- Followings are for Routing BO
         , x_rev_operation_tbl    IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Tbl_Type
         , x_rev_op_resource_tbl  IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type
         , x_rev_sub_resource_tbl IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type
         -- Added by MK on 08/23/2000

        )
        IS

            l_change_line_tbl       Eng_Eco_Pub.Change_Line_Tbl_Type;

        BEGIN

             -- Overloading Log_Error for Eng Change Mgmt Enhancement
             Log_Error
             (  p_eco_rec                   => p_eco_rec
              , p_eco_revision_tbl          => p_eco_revision_tbl
              , p_change_line_tbl           => l_change_line_tbl -- Eng Change
              , p_revised_item_tbl          => p_revised_item_tbl
              , p_rev_operation_tbl         => p_rev_operation_tbl
              , p_rev_op_resource_tbl       => p_rev_op_resource_tbl
              , p_rev_sub_resource_tbl      => p_rev_sub_resource_tbl
              , p_rev_component_tbl         => p_rev_component_tbl
              , p_ref_designator_tbl        => p_ref_designator_tbl
              , p_sub_component_tbl         => p_sub_component_tbl
              , p_Mesg_Token_tbl            => p_Mesg_Token_tbl
              , p_error_status              => p_error_status
              , p_error_scope               => p_error_scope
              , p_other_message             => p_other_message
              , p_other_status              => p_other_status
              , p_other_token_tbl           => p_other_token_tbl
              , p_error_level               => p_error_level
              , p_entity_index              => p_entity_index
              , x_eco_rec                   => x_eco_rec
              , x_eco_revision_tbl          => x_eco_revision_tbl
              , x_change_line_tbl           => l_change_line_tbl  -- Eng Change
              , x_revised_item_tbl          => x_revised_item_tbl
              , x_rev_component_tbl         => x_rev_component_tbl
              , x_ref_designator_tbl        => x_ref_designator_tbl
              , x_sub_component_tbl         => x_sub_component_tbl
              , x_rev_operation_tbl         => x_rev_operation_tbl
              , x_rev_op_resource_tbl       => x_rev_op_resource_tbl
              , x_rev_sub_resource_tbl      => x_rev_sub_resource_tbl
              );


         END Log_Error ;



        /*******************************************************
        -- Log_Error prodedure used for Eng Change Managmet
        -- enhancement
        --
        -- Added people and change Line error handling
        -- to existed Log_Error procedure
        --
        -- Added by MK on 08/13/2002
        ********************************************************/
        PROCEDURE Log_Error
        (  p_eco_rec              IN  Eng_Eco_Pub.Eco_Rec_Type
                                      := Eng_Eco_Pub.G_MISS_ECO_REC
         , p_eco_revision_tbl     IN  Eng_Eco_Pub.Eco_Revision_tbl_Type
                                      := Eng_Eco_Pub.G_MISS_ECO_REVISION_TBL
         , p_change_line_tbl      IN  Eng_Eco_Pub.Change_Line_Tbl_Type -- Eng Change
                                      := Eng_Eco_Pub.G_MISS_CHANGE_LINE_TBL
         , p_revised_item_tbl     IN  Eng_Eco_Pub.Revised_Item_Tbl_Type
                                      := Eng_Eco_Pub.G_MISS_REVISED_ITEM_TBL
         , p_rev_operation_tbl    IN  Bom_Rtg_Pub.Rev_Operation_Tbl_Type
                                      := Bom_Rtg_Pub.G_MISS_REV_OPERATION_TBL
         , p_rev_op_resource_tbl  IN  Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type
                                      := Bom_Rtg_Pub.G_MISS_REV_OP_RESOURCE_TBL
         , p_rev_sub_resource_tbl IN  Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type
                                      := Bom_Rtg_Pub.G_MISS_REV_SUB_RESOURCE_TBL
         , p_rev_component_tbl    IN  Bom_Bo_Pub.Rev_Component_Tbl_Type
                                       := Eng_Eco_Pub.G_MISS_REV_COMPONENT_TBL
         , p_ref_designator_tbl   IN  Bom_Bo_Pub.Ref_Designator_Tbl_Type
                                      := Eng_Eco_Pub.G_MISS_REF_DESIGNATOR_TBL
         , p_sub_component_tbl    IN  Bom_Bo_Pub.Sub_Component_Tbl_Type
                                      := Eng_Eco_Pub.G_MISS_SUB_COMPONENT_TBL
         , p_Mesg_Token_tbl       IN  Error_Handler.Mesg_Token_Tbl_Type
                                      := Error_Handler.G_MISS_MESG_TOKEN_TBL
         , p_error_status         IN  VARCHAR2
         , p_error_scope          IN  VARCHAR2 := NULL
         , p_other_message        IN  VARCHAR2 := NULL
         , p_other_status         IN  VARCHAR2 := NULL
         , p_other_token_tbl      IN  Error_Handler.Token_Tbl_Type
                                      := Error_Handler.G_MISS_TOKEN_TBL
         , p_error_level          IN  NUMBER
         , p_entity_index         IN  NUMBER := 1 -- := NULL
         , x_eco_rec              IN OUT NOCOPY Eng_Eco_Pub.Eco_Rec_Type
         , x_eco_revision_tbl     IN OUT NOCOPY Eng_Eco_Pub.Eco_Revision_tbl_Type
         , x_change_line_tbl      IN OUT NOCOPY Eng_Eco_Pub.Change_Line_Tbl_Type      -- Eng Change
         , x_revised_item_tbl     IN OUT NOCOPY Eng_Eco_Pub.Revised_Item_Tbl_Type
         , x_rev_component_tbl    IN OUT NOCOPY Bom_Bo_Pub.Rev_Component_Tbl_Type
         , x_ref_designator_tbl   IN OUT NOCOPY Bom_Bo_Pub.Ref_Designator_Tbl_Type
         , x_sub_component_tbl    IN OUT NOCOPY Bom_Bo_Pub.Sub_Component_Tbl_Type
         , x_rev_operation_tbl    IN OUT NOCOPY Bom_Rtg_Pub.Rev_Operation_Tbl_Type
         , x_rev_op_resource_tbl  IN OUT NOCOPY Bom_Rtg_Pub.Rev_Op_Resource_Tbl_Type
         , x_rev_sub_resource_tbl IN OUT NOCOPY Bom_Rtg_Pub.Rev_Sub_Resource_Tbl_Type
         )
        IS
                l_message_name          VARCHAR2(30);
                l_other_message         VARCHAR2(2000);
                l_message_text          VARCHAR2(2000);
                l_LoopIndex             NUMBER;
                l_Error_Level           NUMBER      := p_Error_Level;
                l_error_scope           VARCHAR2(1) := p_error_scope;
                l_error_status          VARCHAR2(1) := p_error_status;
        BEGIN

                g_eco_rec               := p_eco_rec;
                g_eco_revision_tbl      := p_eco_revision_tbl;
                g_revised_item_tbl      := p_revised_item_tbl;
                g_rev_component_tbl     := p_rev_component_tbl;
                g_ref_designator_tbl    := p_ref_designator_tbl;
                g_sub_component_tbl     := p_sub_component_tbl;

                /*******************************************************
                -- Followings are for ECO Routing
                ********************************************************/
                g_rev_operation_tbl     := p_rev_operation_tbl ;
                g_rev_op_resource_tbl   := p_rev_op_resource_tbl ;
                g_rev_sub_resource_tbl  := p_rev_sub_resource_tbl ;
                -- Added by MK on 08/23/2000

                /*******************************************************
                -- Followings are for Eng Change
                ********************************************************/
                g_change_line_tbl       := p_change_line_tbl ;
                -- Added by MK on 08/13/2002



                /*************************************************
                --
                -- Seperate message and their tokens, get the
                -- token substituted messages and put it in the
                -- Error Table.
                --
                **************************************************/

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Within the Log Error Procedure . . .'); END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Scope: ' || l_error_scope); END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Entity Index: ' || to_char(p_entity_index)); END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Error Level: ' || to_char(p_error_level)); END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Error Status: ' || l_error_status); END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Other Status: ' || p_other_status); END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Other Message: ' || p_other_message); END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Business Object: ' || Bom_Globals.Get_Bo_Identifier); END IF;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Translating and Inserting Messages . . . '); END IF;

                Error_Handler.Translate_And_Insert_Messages
                (  p_Mesg_Token_Tbl     => p_Mesg_Token_Tbl
                 , p_error_level        => p_error_level
                 , p_entity_index       => p_entity_index
                );

                /**********************************************************
                --
                -- Get the other message text and token and retrieve the
                -- token substituted message.
                --
                ***********************************************************/

                IF p_other_token_tbl.COUNT <> 0
                THEN
                        fnd_message.set_name
                        (  application  => SUBSTR(p_other_message, 1, 3)
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
                        (  application  =>  SUBSTR(p_other_message, 1, 3)
                         , name         => p_other_message
                         );

                        l_other_message := fnd_message.get;

                END IF; -- Other Token Tbl Count <> 0 Ends

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Finished extracting other message . . . '); END IF;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Other Message generated: ' || l_other_message); END IF;


                /**********************************************************
                --
                -- If the Error Level is Business Object
                -- then set the Error Level = ECO
                --
                ************************************************************/
                IF l_error_level = G_BO_LEVEL
                THEN
                        l_error_level := G_ECO_LEVEL;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Error Level is Business Object . . . '); END IF;

                END IF;
                /**********************************************************
                --
                -- If the error_status is UNEXPECTED then set the error scope
                -- to ALL, if WARNING then set the scope to RECORD.
                --
                ************************************************************/
                IF l_error_status = G_STATUS_UNEXPECTED
                THEN
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Status unexpected and scope is All . . .'); END IF;
                        l_error_scope := G_SCOPE_ALL;
                ELSIF l_error_status = G_STATUS_WARNING
                THEN
                        l_error_scope := G_SCOPE_RECORD;
                        l_error_status := FND_API.G_RET_STS_SUCCESS;
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Status is warning . . .'); END IF;

                END IF;

                --
                -- If the Error Level is ECO, then the scope can be
                -- ALL/CHILDREN OR RECORD.
                --
                /*************************************************************
                --
                -- If the Error Level is ECO.
                --
                *************************************************************/
                IF l_error_level = G_ECO_LEVEL
                THEN

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Error Level is ECO . . .'); END IF;
                        --
                        -- Set the ECO Header record status to p_error_status
                        -- This will also take care of the scope RECORD.
                        --
                        g_eco_rec.return_status := l_error_status;

                        IF p_other_message IS NOT NULL AND
                           p_error_level = G_BO_LEVEL
                        THEN
                                /* Changed l_error_level to p_error_level
                                -- so that BO is the entity that the message
                                -- is logged for, and not ECO.
                                -- Changed by AS on 03/17/99 for bug 851387
                                */
                                Error_Handler.Add_Message
                                (  p_mesg_text          => l_other_message
                                 , p_entity_id          => p_error_level
                                 , p_entity_index       => p_entity_index
                                 , p_message_type       => 'E'
				 , p_mesg_name          => p_other_message);--bug 5174203
                                l_other_message := NULL;
                        END IF;


                        IF l_error_scope = G_SCOPE_ALL OR
                           l_error_scope = G_SCOPE_CHILDREN
                        THEN
                                IF g_eco_revision_tbl.COUNT <> 0
                                THEN
                                        --
                                        -- Set all the revision record status
                                        --
                                        setRevisions
                                        (  p_other_mesg_text => l_other_message
                                         , p_other_status    => p_other_status
				 	 , p_other_mesg_name => p_other_message --bug 5174203
                                         );
                                END IF;


                                /***************************************
                                -- Added by MK on 08/13/2002
                                -- Following is for Eng Change Mgmt
                                -- Set all the change line's status.
                                ****************************************/
                                IF g_change_line_tbl.COUNT <> 0
                                THEN
                                        --
                                        -- Set all the change line record status
                                        --
                                        setChangeLines
                                        (  p_other_mesg_text => l_other_message
                                         , p_other_status    => p_other_status
				 	 , p_other_mesg_name => p_other_message --bug 5174203
                                         );
                                END IF;

                                IF g_revised_item_tbl.COUNT <> 0
                                THEN
                                        --
                                        -- Set all the revised item's status
                                        --
                                        setRevisedItems
                                        (  p_other_mesg_text => l_other_message
                                         , p_other_status    => p_other_status
                                         , p_error_scope     => G_SCOPE_ALL
				 	 , p_other_mesg_name => p_other_message --bug 5174203
                                         );
                                END IF;

                                --
                                -- Set all the revised component's
                                -- status, this will then set the
                                -- status of the reference designators
                                -- and substitute components
                                --

                                setRevisedComponents
                                (  p_other_mesg_text => l_other_message
                                 , p_other_status    => p_other_status
                                 , p_error_scope     => G_SCOPE_ALL
				 , p_other_mesg_name => p_other_message --bug 5174203
                                 );


                                /***************************************
                                -- Followings are for ECO Routing
                                -- Added by MK on 08/23/2000
                                -- Set all the revised operation's
                                -- status, this will then set the status
                                -- of the operation resources and
                                -- substitute op resources.
                                ****************************************/
                                setRevOperationSequences
                                (  p_other_mesg_text => l_other_message
                                 , p_other_status    => p_other_status
                                 , p_error_scope     => G_SCOPE_ALL
				 , p_other_mesg_name => p_other_message --bug 5174203
                                ) ;
                                -- Added by MK on 08/23/2000



                        END IF; -- ECO Scope = ALL or Children Ends

                /******************************************
                --
                -- If the Error Level is ECO REVISIONS.
                --
                *******************************************/
                ELSIF l_error_level = G_REV_LEVEL
                THEN
                        --
                        -- Set the Revision record at the current entity_index
                        -- This will take care of scope = RECORD
                        --
                        g_eco_revision_tbl(p_entity_index).return_status :=
                                                        l_error_status;

                        IF l_error_scope = G_SCOPE_ALL
                        THEN
                                IF g_eco_revision_tbl.COUNT <> 0
                                THEN
                                        --
                                        -- Set all the revision record status
                                        --
                                        setRevisions
                                        (  p_other_mesg_text => l_other_message
                                         , p_other_status    => p_other_status
				 	 , p_other_mesg_name => p_other_message --bug 5174203
                                         );
                                END IF;


                                /***************************************
                                -- Added by MK on 08/13/2002
                                -- Following is for Eng Change Mgmt
                                -- Set all the change line's status.
                                ****************************************/
                                IF g_change_line_tbl.COUNT <> 0
                                THEN
                                        --
                                        -- Set all the change line record status
                                        --
                                        setChangeLines
                                        (  p_other_mesg_text => l_other_message
                                         , p_other_status    => p_other_status
				 	 , p_other_mesg_name => p_other_message --bug 5174203
                                         );
                                END IF;


                                IF g_revised_item_tbl.COUNT <> 0
                                THEN
                                        --
                                        -- Set all the revised item's status
                                        --
                                        setRevisedItems
                                        (  p_other_mesg_text => l_other_message
                                         , p_other_status    => p_other_status
                                         , p_error_scope     => l_error_scope
				 	 , p_other_mesg_name => p_other_message --bug 5174203
                                         );
                                END IF;


                                /***************************************
                                -- Followings are for ECO Routing
                                -- Added by MK on 08/23/2000
                                -- Set all the revised operation's
                                -- status, this will then set the status
                                -- of the operation resources and
                                -- substitute op resources.
                                ****************************************/
                                setRevOperationSequences
                                (  p_other_mesg_text => l_other_message
                                 , p_other_status    => p_other_status
                                 , p_error_scope     => l_error_scope
				 , p_other_mesg_name => p_other_message --bug 5174203
                                ) ;
                                -- Added by MK on 08/23/2000

                                --
                                -- Set all the revised component's
                                -- status, this will then set the
                                -- status of the reference designators
                                -- and substitute components
                                --
                                setRevisedComponents
                                (  p_other_mesg_text => l_other_message
                                 , p_other_status    => p_other_status
                                 , p_error_scope     => l_error_scope
				 , p_other_mesg_name => p_other_message --bug 5174203
                                 );

                        END IF;

                /******************************************
                --
                -- If the Error Level is Change Lines.
                --
                *******************************************/
                ELSIF l_error_level = G_CL_LEVEL
                THEN
                        --
                        -- Set the Change Line record at the current entity_index
                        -- This will take care of scope = RECORD
                        --
                        g_change_line_tbl(p_entity_index).return_status :=
                                                        l_error_status;

                        IF l_error_scope = G_SCOPE_ALL
                        THEN
                                IF g_eco_revision_tbl.COUNT <> 0
                                THEN
                                        --
                                        -- Set all the revision record status
                                        --
                                        setRevisions
                                        (  p_other_mesg_text => l_other_message
                                         , p_other_status    => p_other_status
				 	 , p_other_mesg_name => p_other_message --bug 5174203
                                         );
                                END IF;


                                /***************************************
                                -- Added by MK on 08/13/2002
                                -- Following is for Eng Change Mgmt
                                -- Set all the change line's status.
                                ****************************************/
                                IF g_change_line_tbl.COUNT <> 0
                                THEN
                                        --
                                        -- Set all the change line record status
                                        --
                                        setChangeLines
                                        (  p_other_mesg_text => l_other_message
                                         , p_other_status    => p_other_status
				 	 , p_other_mesg_name => p_other_message --bug 5174203
                                         );
                                END IF;


                                IF g_revised_item_tbl.COUNT <> 0
                                THEN
                                        --
                                        -- Set all the revised item's status
                                        --
                                        setRevisedItems
                                        (  p_other_mesg_text => l_other_message
                                         , p_other_status    => p_other_status
                                         , p_error_scope     => l_error_scope
				 	 , p_other_mesg_name => p_other_message --bug 5174203
                                         );
                                END IF;


                                /***************************************
                                -- Followings are for ECO Routing
                                -- Added by MK on 08/23/2000
                                -- Set all the revised operation's
                                -- status, this will then set the status
                                -- of the operation resources and
                                -- substitute op resources.
                                ****************************************/
                                setRevOperationSequences
                                (  p_other_mesg_text => l_other_message
                                 , p_other_status    => p_other_status
                                 , p_error_scope     => l_error_scope
				 , p_other_mesg_name => p_other_message --bug 5174203
                                ) ;
                                -- Added by MK on 08/23/2000

                                --
                                -- Set all the revised component's
                                -- status, this will then set the
                                -- status of the reference designators
                                -- and substitute components
                                --
                                setRevisedComponents
                                (  p_other_mesg_text => l_other_message
                                 , p_other_status    => p_other_status
                                 , p_error_scope     => l_error_scope
				 , p_other_mesg_name => p_other_message --bug 5174203
                                 );

                        END IF;


                /******************************************
                --
                -- If the Error Level is REVISED ITEM.
                --
                *******************************************/
                ELSIF l_error_level = G_RI_LEVEL
                THEN
                        --
                        -- Set the revised item status at the entity_index
                        -- This will take care of scope RECORD
                        --
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Error Level = Revised Items . . .'); END IF;

                        g_revised_item_tbl(p_entity_index).return_status :=
                                                l_error_status;

                        IF l_error_scope = G_SCOPE_CHILDREN OR
                           l_error_scope = G_SCOPE_ALL
                        THEN


                                /***************************************
                                -- Followings are for ECO Routing
                                -- Added by MK on 08/23/2000
                                --
                                -- Call revised operation procedure without
                                -- checking for count since it is possible to
                                -- have op resourcces and sub. op resources
                                -- without having the revised operation as part
                                -- of the business object
                                --
                                ****************************************/
                                setRevOperationSequences
                                (  p_other_mesg_text => l_other_message
                                 , p_other_status    => p_other_status
                                 , p_error_scope     => l_error_scope
                                 , p_ri_idx          => p_entity_index
				 , p_other_mesg_name => p_other_message --bug 5174203
                                ) ;
                                -- Added by MK on 08/23/2000

                                --
                                -- Call revised component procedure without
                                -- Checking for count since it is possible to
                                -- have ref. designators and sub. components
                                -- without having the revised component as part
                                -- of the business object
                                --
                                setRevisedComponents
                                (  p_other_mesg_text => l_other_message
                                 , p_other_status    => p_other_status
                                 , p_error_scope     => l_error_scope
                                 , p_ri_idx          => p_entity_index
				 , p_other_mesg_name => p_other_message --bug 5174203
                                );

                                IF l_error_scope = G_SCOPE_ALL
                                THEN
                                        setRevisedItems
                                        (  p_other_mesg_text => l_other_message
                                         , p_other_status    => p_other_status
                                         , p_entity_index    => p_entity_index
                                         , p_error_scope     => l_error_scope
				 	 , p_other_mesg_name => p_other_message --bug 5174203
                                        );
                                END IF;

                        END IF;  -- SCOPE = Children or ALL Ends
                /********************************************
                --
                -- If the Error Level is REVISED COMPONENTS
                --
                *********************************************/
                ELSIF l_error_level = G_RC_LEVEL
                THEN
                        --
                        -- Set revised component record at the entity_index
                        -- to error_status
                        -- This will take care of Scope = RECORD.
                        --
                        g_rev_component_tbl(p_entity_index).return_status :=
                                                l_error_status;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Error Level = Revised components . . .'); END IF;

                        IF l_error_scope = G_SCOPE_SIBLINGS OR
                           l_error_scope = G_SCOPE_ALL
                        THEN
                                 setRevisedComponents
                                (  p_other_mesg_text => l_other_message
                                 , p_other_status    => p_other_status
                                 , p_error_scope     => l_error_scope
                                 , p_entity_index    => p_entity_index
				 , p_other_mesg_name => p_other_message --bug 5174203
                                );
                        ELSIF l_error_scope = G_SCOPE_CHILDREN
                        THEN
                                IF g_ref_designator_tbl.COUNT <> 0
                                THEN
                                        setRefDesignators
                                        (  p_error_scope     => l_error_scope
                                         , p_other_status    => p_other_status
                                         , p_other_mesg_text => l_other_message
                                         , p_rc_idx          => p_entity_index
				 	 , p_other_mesg_name => p_other_message --bug 5174203
                                         );
                                END IF;

                                IF g_sub_component_tbl.COUNT <> 0
                                THEN
                                        setSubComponents
                                        (  p_error_scope     => l_error_scope
                                         , p_other_status    => p_other_status
                                         , p_other_mesg_text => l_other_message
                                         , p_rc_idx          => p_entity_index
 					 , p_other_mesg_name => p_other_message --bug 5174203
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
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Error Level = Reference Designators . . .'); END IF;

                        g_ref_designator_tbl(p_entity_index).return_status :=
                                                l_error_status;
                        IF l_error_scope <> G_SCOPE_RECORD
                        THEN
                                setRefDesignators
                                (  p_error_scope     => l_error_scope
                                 , p_other_status    => p_other_status
                                 , p_other_mesg_text => l_other_message
                                 , p_entity_index    => p_entity_index
				 , p_other_mesg_name => p_other_message --bug 5174203
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
IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Error Level = Substitute Components . . .'); END IF;

                        g_sub_component_tbl(p_entity_index).return_status :=
                                                l_error_status;
                        IF l_error_scope <> G_SCOPE_RECORD
                        THEN
                                setSubComponents
                                (  p_error_scope     => l_error_scope
                                 , p_other_status    => p_other_status
                                 , p_other_mesg_text => l_other_message
                                 , p_entity_index    => p_entity_index
				 , p_other_mesg_name => p_other_message --bug 5174203
                                 );
                        END IF;



                /********************************************
                -- Enhancement for ECO Routing
                -- Added by MK on 08/23/00
                --
                -- If the Error Level is REVISED OPERATIONS
                --
                *********************************************/
                ELSIF l_error_level = G_OP_LEVEL
                THEN
                        --
                        -- Set revised operation record at the entity_index
                        -- to error_status
                        -- This will take care of Scope = RECORD.
                        --
                        g_rev_operation_tbl(p_entity_index).return_status :=
                                                l_error_status;

IF Bom_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Error Level = Revised operations . . .'); END IF;

                        IF l_error_scope = G_SCOPE_SIBLINGS OR
                           l_error_scope = G_SCOPE_ALL
                        THEN
                                 setRevOperationSequences
                                (  p_other_mesg_text => l_other_message
                                 , p_other_status    => p_other_status
                                 , p_error_scope     => l_error_scope
                                 , p_entity_index    => p_entity_index
				 , p_other_mesg_name => p_other_message --bug 5174203
                                );
                        ELSIF l_error_scope = G_SCOPE_CHILDREN
                        THEN
                             IF g_rev_op_resource_tbl.COUNT <> 0
                             THEN
                                 setRevOperationResources
                               (  p_error_scope     => l_error_scope
                                , p_other_status    => p_other_status
                                , p_other_mesg_text => l_other_message
                                , p_op_idx          => p_entity_index
				, p_other_mesg_name => p_other_message --bug 5174203
                                );
                             END IF;

                             IF g_rev_sub_resource_tbl.COUNT <> 0
                             THEN
                                 setRevSubResources
                                 (  p_error_scope     => l_error_scope
                                  , p_other_status    => p_other_status
                                  , p_other_mesg_text => l_other_message
                                  , p_op_idx          => p_entity_index
				  , p_other_mesg_name => p_other_message --bug 5174203
                                 );
                             END IF;

                        END IF; -- scope = Siblings or All Ends



                /***********************************************
                -- Enhancement for ECO Routing
                -- Added by MK on 08/23/00
                --
                -- If the Error Level is REV OPERATION RESOURCES
                --
                ************************************************/
                ELSIF l_error_level = G_RES_LEVEL
                THEN

                        --
                        -- Set operation resource record status at entity_idx
                        -- This will take care of Scope = RECORD.
                        --
IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Error Level = Ope ration Resource . . .'); END IF;

                        g_rev_op_resource_tbl(p_entity_index).return_status := l_error_status;
                        IF l_error_scope <> G_SCOPE_RECORD
                        THEN
                            setRevOperationResources
                            (  p_error_scope     => l_error_scope
                             , p_other_status    => p_other_status
                             , p_other_mesg_text => l_other_message
                             , p_entity_index    => p_entity_index
			     , p_other_mesg_name => p_other_message --bug 5174203
                            ) ;
                        END IF;

                /***********************************************
                -- Enhancement for ECO Routing
                -- Added by MK on 08/23/00
                --
                -- If the Error Level is REV SUB OP RESOURCES
                --
                ************************************************/
                ELSIF l_error_level = G_SR_LEVEL
                THEN
                        -- Set substitute resource record status at entity_idx
                        -- This will take care of Scope = RECORD.
                        --
IF Bom_Rtg_Globals.Get_Debug = 'Y' THEN Error_Handler.Write_Debug('Error Level = Sub
stitute Op Resources . . .'); END IF;

                        g_rev_sub_resource_tbl(p_entity_index).return_status := l_error_status;


                        IF l_error_scope <> G_SCOPE_RECORD
                        THEN
                           setRevSubResources
                           (  p_error_scope     => l_error_scope
                            , p_other_status    => p_other_status
                            , p_other_mesg_text => l_other_message
                            , p_entity_index    => p_entity_index
			    , p_other_mesg_name => p_other_message --bug 5174203
                           ) ;
                        END IF ;

                END IF; -- Error Level  If Ends.

                --
                -- Copy the changed record/Tables to the out parameters for
                -- returing to the calling program.
                --
                x_eco_rec               := g_eco_rec;
                x_eco_revision_tbl      := g_eco_revision_tbl;
                x_revised_item_tbl      := g_revised_item_tbl;
                x_rev_component_tbl     := g_rev_component_tbl;
                x_ref_designator_tbl    := g_ref_designator_tbl;
                x_sub_component_tbl     := g_sub_component_tbl;


                /*******************************************************
                -- Followings are for ECO Routing
                ********************************************************/
                x_rev_operation_tbl     := g_rev_operation_tbl ;
                x_rev_op_resource_tbl   := g_rev_op_resource_tbl ;
                x_rev_sub_resource_tbl  := g_rev_sub_resource_tbl ;
                -- Added by MK on 08/23/2000

                /*******************************************************
                -- Followings are for Eng Change
                ********************************************************/
                x_change_line_tbl       := g_change_line_tbl ;
                -- Added by MK on 08/13/2002


        END Log_Error;



END Eco_Error_Handler;

/
