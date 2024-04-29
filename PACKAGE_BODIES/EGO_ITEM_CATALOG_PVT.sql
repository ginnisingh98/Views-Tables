--------------------------------------------------------
--  DDL for Package Body EGO_ITEM_CATALOG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_ITEM_CATALOG_PVT" AS
/* $Header: EGOVCAGB.pls 120.1.12010000.3 2009/08/03 17:13:53 chechand ship $ */

/* Private API for processing catalog groups
** Applications should not call this catalog group api directly.
** return_status: this is returned by the api to indicate the success/failure of the call
** msg_count: this is returned by the api to indicate the number of message logged for this
** call.
**
*/

	Procedure Process_Catalog_Groups
	(  x_return_status           OUT NOCOPY VARCHAR2
	 , x_msg_count               OUT NOCOPY NUMBER
	 )
	IS
		l_Table_Index NUMBER;
		l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
		l_other_token_tbl       Error_Handler.Token_Tbl_Type;
		l_other_message         VARCHAR2(2000);
		l_err_text              VARCHAR2(2000);
		l_valid                 BOOLEAN := TRUE;
		l_Return_Status         VARCHAR2(1);
		l_bo_return_status      VARCHAR2(1);

	    profile_value varchar2(1) := fnd_profile.value('EGO_ENABLE_P4T');
	    version_count           NUMBER;

	BEGIN

		-- Business Object starts with a status of Success

		l_bo_return_status := 'S';

		Error_Handler.Write_Debug('Starting PVT processing in Process_Catalog_Groups ');
		-- dbms_output.put_line('Starting PVT processing in Process_Catalog_Groups ');

		-- begin processing the catalog group table

		--
		-- all references to the input data must be made from the global reference.
		-- That must be maintained as the source of truth for all data.
		--

		-- Every catalog group record is a business object.

		-- dbms_output.Put_Line('Records to Process: ' || EGO_Globals.G_Catalog_Group_Tbl.COUNT);

		FOR l_Table_Index IN 1..EGO_Globals.G_Catalog_Group_Tbl.COUNT
		LOOP
		BEGIN

			l_return_status	   := 'S';

			EGO_Globals.G_Catalog_Group_Rec := EGO_Globals.G_Catalog_Group_Tbl(l_Table_Index);

		      -- CHECHAND - changes for pim for telco - bug # 8471604 - START
		      if profile_value = 'Y' AND EGO_Globals.G_Catalog_Group_Rec.transaction_type =	Ego_Globals.G_OPR_UPDATE THEN
			  SELECT Count(*) INTO version_count FROM EGO_MTL_CATALOG_GRP_VERS_B
			  WHERE
			    item_catalog_group_id = (SELECT item_catalog_group_id FROM mtl_item_catalog_groups_b WHERE segment1=EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Name)
			    AND version_seq_id>0;
			  --dbms_output.put_line('Processing catalog group id: '||EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Name ||' version count: ' || version_count);
			  if VERSION_COUNT <> 0 THEN
			    x_return_status	   := 'U';
			    RETURN;
			  END IF;
		      end if;
		      -- CHECHAND - changes for pim for telco - bug # 8471604 - END


			EGO_Item_Catalog_Pub.G_KF_Segment_Values(1) :=
							EGO_Globals.G_Catalog_Group_Rec.Segment1;
                	EGO_Item_Catalog_Pub.G_KF_Segment_Values(2) :=
							EGO_Globals.G_Catalog_Group_Rec.Segment2;
                	EGO_Item_Catalog_Pub.G_KF_Segment_Values(3) :=
							EGO_Globals.G_Catalog_Group_Rec.Segment3;
                	EGO_Item_Catalog_Pub.G_KF_Segment_Values(4) :=
							EGO_Globals.G_Catalog_Group_Rec.Segment4;
                	EGO_Item_Catalog_Pub.G_KF_Segment_Values(5) :=
							EGO_Globals.G_Catalog_Group_Rec.Segment5;
                	EGO_Item_Catalog_Pub.G_KF_Segment_Values(6) :=
							EGO_Globals.G_Catalog_Group_Rec.Segment6;
                	EGO_Item_Catalog_Pub.G_KF_Segment_Values(7) :=
							EGO_Globals.G_Catalog_Group_Rec.Segment7;
                	EGO_Item_Catalog_Pub.G_KF_Segment_Values(8) :=
							EGO_Globals.G_Catalog_Group_Rec.Segment8;
                	EGO_Item_Catalog_Pub.G_KF_Segment_Values(9) :=
							EGO_Globals.G_Catalog_Group_Rec.Segment9;
                	EGO_Item_Catalog_Pub.G_KF_Segment_Values(10) :=
							EGO_Globals.G_Catalog_Group_Rec.Segment10;
                	EGO_Item_Catalog_Pub.G_KF_Segment_Values(11) :=
							EGO_Globals.G_Catalog_Group_Rec.Segment11;
                	EGO_Item_Catalog_Pub.G_KF_Segment_Values(12) :=
							EGO_Globals.G_Catalog_Group_Rec.Segment12;
                	EGO_Item_Catalog_Pub.G_KF_Segment_Values(13) :=
							EGO_Globals.G_Catalog_Group_Rec.Segment13;
                	EGO_Item_Catalog_Pub.G_KF_Segment_Values(14) :=
							EGO_Globals.G_Catalog_Group_Rec.Segment14;
                	EGO_Item_Catalog_Pub.G_KF_Segment_Values(15) :=
							EGO_Globals.G_Catalog_Group_Rec.Segment15;
                	EGO_Item_Catalog_Pub.G_KF_Segment_Values(16) :=
							EGO_Globals.G_Catalog_Group_Rec.Segment16;
                	EGO_Item_Catalog_Pub.G_KF_Segment_Values(17) :=
							EGO_Globals.G_Catalog_Group_Rec.Segment17;
                	EGO_Item_Catalog_Pub.G_KF_Segment_Values(18) :=
							EGO_Globals.G_Catalog_Group_Rec.Segment18;
                	EGO_Item_Catalog_Pub.G_KF_Segment_Values(19) :=
							EGO_Globals.G_Catalog_Group_Rec.Segment19;
                	EGO_Item_Catalog_Pub.G_KF_Segment_Values(20) :=
							EGO_Globals.G_Catalog_Group_Rec.Segment20;



			/* Assign null to the segments that are not used */

                	FOR i in 1..20
                	LOOP
				IF EGO_Item_Catalog_Pub.G_KF_Segment_Values(i) = FND_API.G_MISS_CHAR
				THEN
                    			EGO_Item_Catalog_Pub.G_KF_Segment_Values(i) := null;
				END IF;
                	END LOOP;

			--
			-- Transaction Type Validity
			--

			Error_Handler.Write_Debug('Performing trasaction type validity ');
			-- dbms_output.put_line('Performing trasaction type validity ');

			EGO_Globals.Transaction_Type_Validity
			(   p_Entity_Id		=> EGO_Globals.G_ITEM_CATALOG_GROUP
			  , p_Entity	        => EGO_Globals.G_ITEM_CATALOG_GROUP
			  , p_transaction_type	=> EGO_Globals.G_Catalog_Group_Rec.Transaction_Type
			  , x_valid		=> l_valid
			  , x_mesg_token_tbl	=> l_mesg_token_tbl
			 );


			IF l_valid <> true
           		THEN
			    -- quit since the record does not have a valid transaction type.
			    l_return_status := FND_API.G_RET_STS_ERROR;
                	    RAISE EGO_Globals.G_EXC_SEV_QUIT_RECORD;
           		END IF;


			--
			-- Process Flow step 4.a - User Unique Index to Unique index conversion - I
			--
			Error_Handler.Write_Debug('Performing UUI-UI conversion ');
			-- dbms_output.put_line('Performing UUI-UI conversion ');
			EGO_ItemCat_Val_To_Id.EGO_ItemCatalog_UUI_To_UI
			(  x_return_status	=> l_return_status
			 , x_mesg_token_tbl	=> l_mesg_token_tbl
			);

			Error_Handler.Write_Debug('UUI conversion returned . . .');
			IF l_return_status = Error_Handler.G_STATUS_ERROR
			THEN
				Error_Handler.Write_Debug('Raising exception . . .QUIT_RECORD');
				-- dbms_output.put_line('Raising exception . . .QUIT_RECORD');
                		RAISE EGO_Globals.G_EXC_SEV_QUIT_RECORD;
           		ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           		THEN
                		l_other_message := 'EGO_CATG_UUI_UNEXP_SKIP';
                		l_other_token_tbl(1).token_name := 'CATALOG_GROUP_NAME';
                		l_other_token_tbl(1).token_value :=
                        		EGO_Globals.G_Catalog_Group_Rec.catalog_group_name;
                		RAISE EGO_Globals.G_EXC_UNEXP_SKIP_OBJECT;
           		END IF;

			--
			-- Process Flow step 4.b - User Unique index to Unique Index conversion II
			--

			-- This is not required for catalog groups

			--
           		-- Process Flow step 5: Verify existence
           		--
			Error_Handler.Write_Debug('Performing check existence ');
			-- dbms_output.put_line('Performing check existence ');
           		Ego_Validate_Catalog_Group.Check_Existence
                	(  x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                	,  x_return_status              => l_Return_Status
                	 );

			IF l_return_status = Error_Handler.G_STATUS_ERROR
           		THEN
                		RAISE EGO_Globals.G_EXC_SEV_QUIT_RECORD;
           		ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           		THEN
                		l_other_message := 'EGO_CATGRP_EXS_UNEXP_SKIP';
                		l_other_token_tbl(1).token_name := 'CATALOG_GROUP_NAME';
                		l_other_token_tbl(1).token_value :=
                        		Ego_globals.G_Catalog_Group_Rec.Catalog_Group_Name;
                		RAISE EGO_Globals.G_EXC_UNEXP_SKIP_OBJECT;
           		END IF;

			--
			-- To support SYNC, copy the transaction type from the old record which will
			-- be set in check existence
			--
			IF Ego_Globals.G_Catalog_Group_Rec.transaction_type = 'SYNC'
			THEN
             			Ego_Globals.G_Catalog_Group_Rec.transaction_type :=
                 		Ego_Globals.G_Old_Catalog_Group_Rec.transaction_type;
           		END IF;

			--
			-- Process Flow Step 7: Check Lineage not required for Catalog Groups
			--

			--
			-- Process Flow Step 8: Check Access.
			-- Check if the user has access to create the catalog group.
			--

			Error_Handler.Write_Debug('Performing check access');
			-- dbms_output.put_line('Performing check access');

			Ego_Validate_Catalog_Group.Check_Access
			(  x_return_status	=> l_return_status
			 , x_mesg_token_tbl	=> l_mesg_token_tbl
			 );

			IF l_return_status = Error_Handler.G_STATUS_ERROR
                	THEN
                        	l_other_message := 'EGO_CATGRP_ACC_FAT_FATAL';
                        	l_other_token_tbl(1).token_name := 'CATALOG_GROUP_NAME';
                        	l_other_token_tbl(1).token_value :=
                                	Ego_Globals.G_Catalog_Group_rec.Catalog_Group_Name;
                        	l_return_status := 'F';
                        	RAISE EGO_Globals.G_EXC_FAT_QUIT_SIBLINGS;
                	ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                	THEN
                        	l_other_message := 'BOM_CATGRP_ACC_UNEXP_SKIP';
				l_other_token_tbl(1).token_name := 'CATALOG_GROUP_NAME';
                        	l_other_token_tbl(1).token_value :=
                                	Ego_Globals.G_Catalog_Group_rec.Catalog_Group_Name;

                        	RAISE EGO_Globals.G_EXC_UNEXP_SKIP_OBJECT;
                	END IF;

			--
			-- Process Flow step 9: Check Attributes
			--

			IF EGO_Globals.G_Catalog_Group_Rec.transaction_type IN
                		(Ego_Globals.G_OPR_UPDATE, Ego_Globals.G_OPR_CREATE)
        		THEN
				Error_Handler.Write_Debug('Performing check attributes');
				-- dbms_output.put_line('Performing check attributes');
				EGO_Validate_Catalog_Group.Check_Attributes
				(  x_return_status	=> l_return_status
				 , x_mesg_token_tbl	=> l_mesg_token_tbl
				 );

				IF l_return_status = Error_Handler.G_STATUS_ERROR
                		THEN
                        		RAISE EGO_Globals.G_EXC_SEV_QUIT_RECORD;
                		ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                		THEN
                        		RAISE EGO_Globals.G_EXC_UNEXP_SKIP_OBJECT;
                		END IF;

			END IF;

			--
			-- Process Flow step 10: Populate null columns for UPDATE
			-- OR Perform attribute defaulting for CREATE
			--

			IF EGO_Globals.G_Catalog_Group_Rec.transaction_type IN
                		(EGO_Globals.G_OPR_UPDATE, EGO_Globals.G_OPR_DELETE)
            		THEN
                    		Error_Handler.Write_Debug('Populate NULL columns . . .');

                    		Ego_Default_Catalog_Group.Populate_Null_Columns;

-- Bug 3324531
-- changed the global Bom_Globals.G_OPR_CREATE to EGO_Globals.G_OPR_CREATE
			ELSIF EGO_Globals.G_Catalog_Group_Rec.transaction_type = EGO_Globals.G_OPR_CREATE
			THEN
                    		Error_Handler.Write_Debug('Attribute Defaulting . . .');

				Ego_Default_Catalog_Group.Attribute_Defaulting
				(  x_return_status	=> l_return_status
				 , x_mesg_token_tbl	=> l_mesg_token_tbl
				 );

				IF l_return_status = Error_Handler.G_STATUS_ERROR
                		THEN
                        		l_other_message := 'EGO_CATGRP_ATTDEF_CSEV_SKIP';
                        		l_other_token_tbl(1).token_name := 'CATALOG_GROUP_NAME';
                        		l_other_token_tbl(1).token_value :=
                                		EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Name;
                        		RAISE EGO_Globals.G_EXC_SEV_SKIP_BRANCH;
                		ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                		THEN
                        		l_other_message := 'EGO_CATGRP_ATTDEF_UNEXP_SKIP';
                        		l_other_token_tbl(1).token_name := 'CATALOG_GROUP_NAME';
                        		l_other_token_tbl(1).token_value :=
                                		EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Name;
                        		RAISE EGO_Globals.G_EXC_UNEXP_SKIP_OBJECT;
                		END IF;
			END IF;

			Error_Handler.write_debug('Finished with attribute defaulting . . .');
			Error_Handler.write_debug('Proceeding with entity validations . . .');
			-- dbms_output.put_line('Proceeding with entity validations . . .');

			IF EGO_Globals.G_Catalog_Group_Rec.transaction_type <> EGO_Globals.G_OPR_DELETE
           		THEN
                		Ego_Validate_Catalog_Group.Check_Entity
                		(  x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                		,  x_return_status              => l_Return_Status
                		);

				IF l_return_status = Error_Handler.G_STATUS_ERROR
           			THEN
                			RAISE EGO_Globals.G_EXC_SEV_QUIT_RECORD;
           			ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
           			THEN
                			l_other_message := 'EGO_CATGRP_ENTVAL_UNEXP_SKIP';
                			l_other_token_tbl(1).token_name := 'CATALOG_GROUP_NAME';
                			l_other_token_tbl(1).token_value :=
                        			EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Name;
                			RAISE EGO_Globals.G_EXC_UNEXP_SKIP_OBJECT;
           			END IF;
			ELSIF EGO_Globals.G_Catalog_Group_Rec.transaction_type = EGO_Globals.G_OPR_DELETE
                        THEN
                                Ego_Validate_Catalog_Group.Check_Entity_Delete
                                (  x_Mesg_Token_Tbl             => l_Mesg_Token_Tbl
                                ,  x_return_status              => l_Return_Status
                                );

				-- dbms_output.put_line('Return Status is . . .'||l_return_status);

                                IF l_return_status = Error_Handler.G_STATUS_ERROR
                                THEN
					-- dbms_output.put_line('Raising exception in delete');
                                        RAISE EGO_Globals.G_EXC_SEV_QUIT_RECORD;
                                ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                                THEN
                                        l_other_message := 'EGO_CATGRP_ENTVAL_UNEXP_SKIP';
                                        l_other_token_tbl(1).token_name := 'CATALOG_GROUP_NAME';
                                        l_other_token_tbl(1).token_value :=
                                                EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Name;
                                        RAISE EGO_Globals.G_EXC_UNEXP_SKIP_OBJECT;
                                END IF;

           		END IF ;


			--
           		-- Process Flow step 13 : Database Writes
           		--

           		Error_Handler.Write_Debug('Writing to the database');
           		-- dbms_output.put_line('Writing to the database');

           		Ego_Catalog_Group_Util.Perform_Writes
                	(  x_Mesg_Token_Tbl         => l_Mesg_Token_Tbl
                	 , x_return_status          => l_return_status
                	);

			IF l_return_status = Error_Handler.G_STATUS_ERROR
                        THEN
                                RAISE EGO_Globals.G_EXC_SEV_QUIT_RECORD;
                        ELSIF l_return_status = Error_Handler.G_STATUS_UNEXPECTED
                        THEN
                                l_other_message := 'EGO_CATGRP_ENTVAL_UNEXP_SKIP';
                                l_other_token_tbl(1).token_name := 'CATALOG_GROUP_NAME';
                                l_other_token_tbl(1).token_value :=
                                      EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Name;
                                RAISE EGO_Globals.G_EXC_UNEXP_SKIP_OBJECT;
                        END IF;

			-- return the record back to the table after processing

			EGO_Globals.G_Catalog_Group_Tbl(l_Table_Index) := EGO_Globals.G_Catalog_Group_Rec;

			x_return_status  := l_bo_return_status;

			Error_Handler.Write_Debug('Process Completed');

		    EXCEPTION
				WHEN EGO_Globals.G_EXC_SEV_QUIT_RECORD THEN
					Error_Handler.Write_Debug('Handling exception G_EXC_SEV_QUIT_RECORD');
					-- dbms_output.put_line('Handling exception G_EXC_SEV_QUIT_RECORD');
					EGO_Catalog_Group_Err_Handler.Log_Error
                			(  p_mesg_token_tbl     => l_mesg_token_tbl
                			,  p_error_status       => Error_Handler.G_STATUS_ERROR
                			,  p_error_scope        => Error_Handler.G_SCOPE_RECORD
                			,  p_error_level        => EGO_Globals.G_ITEM_CATALOG_GROUP_LEVEL
                			,  p_entity_index       => l_Table_Index
                			);

					IF l_bo_return_status = 'S'
					THEN
						l_bo_return_status     := l_return_status;
					END IF;

					x_return_status := l_bo_return_status;

				WHEN EGO_Globals.G_EXC_SEV_QUIT_BRANCH THEN
					EGO_Catalog_Group_Err_Handler.Log_Error
                                        (  p_mesg_token_tbl     => l_mesg_token_tbl
                                        ,  p_error_status       => Error_Handler.G_STATUS_ERROR
                                        ,  p_error_scope        => Error_Handler.G_SCOPE_CHILDREN
                                        ,  p_error_level        => EGO_Globals.G_ITEM_CATALOG_GROUP_LEVEL
                                        ,  p_entity_index       => l_Table_Index
                                        );

					IF l_bo_return_status = 'S'
					THEN
						l_bo_return_status     := l_return_status;
					END IF;

					x_return_status := l_bo_return_status;

				WHEN EGO_Globals.G_EXC_SEV_QUIT_SIBLINGS THEN
					EGO_Catalog_Group_Err_Handler.Log_Error
                                        (  p_mesg_token_tbl     => l_mesg_token_tbl
                                        ,  p_error_status       => Error_Handler.G_STATUS_ERROR
                                        ,  p_error_scope        => Error_Handler.G_SCOPE_SIBLINGS
                                        ,  p_error_level        => EGO_Globals.G_ITEM_CATALOG_GROUP_LEVEL
                                        ,  p_entity_index       => l_Table_Index
                                        );

					IF l_bo_return_status = 'S'
					THEN
						l_bo_return_status     := l_return_status;
					END IF;

					x_return_status := l_bo_return_status;

				WHEN EGO_Globals.G_EXC_FAT_QUIT_SIBLINGS THEN
					EGO_Catalog_Group_Err_Handler.Log_Error
                                        (  p_mesg_token_tbl     => l_mesg_token_tbl
                                        ,  p_error_status       => Error_Handler.G_STATUS_FATAL
                                        ,  p_error_scope        => Error_Handler.G_SCOPE_SIBLINGS
                                        ,  p_error_level        => EGO_Globals.G_ITEM_CATALOG_GROUP_LEVEL
                                        ,  p_entity_index       => l_Table_Index
                                        );

					IF l_bo_return_status = 'S'
					THEN
						l_bo_return_status     := l_return_status;
					END IF;

					x_return_status := l_bo_return_status;

				WHEN EGO_Globals.G_EXC_FAT_QUIT_OBJECT THEN
					EGO_Catalog_Group_Err_Handler.Log_Error
                                        (  p_mesg_token_tbl     => l_mesg_token_tbl
                                        ,  p_error_status       => Error_Handler.G_STATUS_FATAL
                                        ,  p_error_scope        => Error_Handler.G_SCOPE_ALL
                                        ,  p_error_level        => EGO_Globals.G_ITEM_CATALOG_GROUP_LEVEL
                                        ,  p_entity_index       => l_Table_Index
                                        );

					IF l_bo_return_status = 'S'
					THEN
						l_bo_return_status     := l_return_status;
					END IF;

					x_return_status := l_bo_return_status;

				WHEN EGO_Globals.G_EXC_UNEXP_SKIP_OBJECT THEN
					EGO_Catalog_Group_Err_Handler.Log_Error
                                        (  p_mesg_token_tbl     => l_mesg_token_tbl
                                        ,  p_error_status       => Error_Handler.G_STATUS_UNEXPECTED
					,  p_other_status	=> Error_Handler.G_STATUS_NOT_PICKED
					,  p_other_message      => l_other_message
                			,  p_other_token_tbl    => l_other_token_tbl
                                        ,  p_error_scope        => Error_Handler.G_SCOPE_ALL
                                        ,  p_error_level        => EGO_Globals.G_ITEM_CATALOG_GROUP_LEVEL
                                        ,  p_entity_index       => l_Table_Index
                                        );

					IF l_bo_return_status = 'S'
					THEN
						l_bo_return_status     := l_return_status;
					END IF;

					x_return_status := l_bo_return_status;
		END;

		   /* End of the loop block */

		IF l_return_status in ('Q', 'U')
        	THEN
                	x_return_status := l_return_status;
                	RETURN;
        	END IF;
	     END LOOP; /* End For Loop - processing of catalog group tbl */

		/* End Processing all the catalog groups */
	     -- dbms_output.put_line('End of Private API');
	END;

END EGO_ITEM_CATALOG_PVT;

/
