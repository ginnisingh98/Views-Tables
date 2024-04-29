--------------------------------------------------------
--  DDL for Package Body EGO_ITEMCAT_VAL_TO_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_ITEMCAT_VAL_TO_ID" AS
/* $Header: EGOSVIDB.pls 120.1 2005/06/02 05:41:14 lkapoor noship $ */
/****************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EGOSVIDB.pls
--
--  DESCRIPTION
--
--      Body of package EGO_ItemCat_Val_To_Id
--	Shared value-to-Id conversion package.
--  NOTES
--
--  HISTORY
-- --  20-AUG-2002	Rahul Chitko	Initial Creation
-- --  09-OCT-2002      Refai Farook    Modified UUI_TI_UI procedure logic to support
--					different combinations of key input data(group id,
--					name and segments)
****************************************************************************/
	G_Pkg_Name	VARCHAR2(30) := 'EGO_ItemCat_Val_To_Id';
	g_token_tbl	Error_Handler.Token_Tbl_Type;


	G_Error_Msg_Text VARCHAR2(2000);


       /********************************************************************
        ** Procedure: Generate_Catalog_Group_Id (Unexposed)
        ** Purpose  : Generates the next catalog group id
        ** Returns  : Catalog group id
        **********************************************************************/

	FUNCTION Generate_Catalog_Group_Id
	RETURN NUMBER IS
	  l_ccid NUMBER;
	BEGIN

               SELECT mtl_item_catalog_groups_b_s.NEXTVAL
               INTO l_ccid from dual;

	       Return l_ccid;

	END;

       /********************************************************************
        ** Procedure: Check_Catalog_CCID (Unexposed)
        ** Purpose  : Checks the existence of catalog group id
        ** Returns  : TRUE if CCID exists and FALSE if not
        **********************************************************************/


        FUNCTION Check_Catalog_CCID
        RETURN BOOLEAN
        IS
          l_ccid NUMBER;
        BEGIN

                SELECT item_catalog_group_id INTO l_ccid
		FROM mtl_Item_Catalog_Groups_b WHERE
		item_catalog_group_id = EGO_Globals.G_Catalog_Group_Rec.catalog_group_id;

		Return TRUE;

		EXCEPTION WHEN OTHERS
		THEN
		  Return FALSE;
        END;

	/********************************************************************
	** Procedure: Get_Catalog_Group_Id (exposed)
	** Purpose  : Will take the concatenated segments for the catalog
	**	      group name and will return an Id. If the Id is null
	**	      that would mean the concatenated segment does not have
	**	      a corresponding record.
	** Returns  : The procedure will perform primarily 2 operations
	**	      CHECK_COMBINATION AND FIND_COMBINATION
	**	      When invoked with CHECK_COMBINATION it would return 0 for
	**	      invalid and 1 for valid.
	**	      When invoked with FIND_COMBINATION it would return the ccid
	**	      if the find is succeessful or else return a null
	**********************************************************************/

	FUNCTION Get_Catalog_Group_Id
		 (  p_catalog_group_name	IN VARCHAR2
		  , p_operation			IN VARCHAR2
		 )
	RETURN NUMBER
	IS
		l_delimiter varchar2(1) := FND_Flex_Ext.Get_Delimiter
					(  application_short_name	=> 'INV'
			 		 , key_flex_code	  	=> 'MICG'
			 		 , structure_number		=> 101
					 );
		l_segment_values FND_FLEX_EXT.SegmentArray;
		kff        fnd_flex_key_api.flexfield_type;
   		str        fnd_flex_key_api.structure_type;
   		seg        fnd_flex_key_api.segment_type;
   		seg_list   fnd_flex_key_api.segment_list;
   		j          number;
   		i          number;
   		nsegs      number;
   		ccid	   number;
		is_valid  boolean;
		is_found  boolean;
	BEGIN

		-- dbms_output.put_line('validating segments . . .operation -  ' || p_operation );
		-- dbms_output.put_line(' concat. value ' || p_catalog_group_name);

		is_valid := FND_FLEX_KEYVAL.Validate_Segs
        	(  operation         => p_operation
        	,  appl_short_name   => 'INV'
        	,  key_flex_code     => 'MICG'
        	,  structure_number  => 101
        	,  concat_segments   => p_catalog_group_name
        	);
		-- dbms_output.put_line('validate segments finished');

   		IF (is_valid AND p_operation = 'FIND_COMBINATION') THEN

		/*
			--
			-- Get the segment breakup and arrange the segments so that the segments can be
			-- used while insertion or updation.
			--

		-- dbms_output.put_line('before breakup_segments. . . ');

			begin
			nsegs := fnd_flex_ext.breakup_segments
			(  delimiter	=> l_delimiter
			 , concatenated_segs => p_catalog_group_name
			 , segments	=> l_segment_values
			 );
			exception
				when others then
				  -- dbms_output.put_line('error in breakup: ' || substr(sqlerrm,1,220));
			end;

		-- dbms_output.put_line('performed breakup_segments. . . ');

			--
			-- once the segments are received, then order the segments appropriatly so
			-- they can be used anywhere.
			--

			kff := fnd_flex_key_api.find_flexfield('INV','MICG');
   			str := fnd_flex_key_api.find_structure(kff, 101);
   			fnd_flex_key_api.get_segments(kff, str, TRUE, nsegs, seg_list);

   			--
   			-- The segments in the seg_list array are sorted in display order.
   			-- i.e. sorted by segment number.
   			--
   			for i in 1..nsegs loop
      			    seg :=
        		    fnd_flex_key_api.find_segment(kff,
                                      			  str,
                                      			  seg_list(i));
      			    j := to_number(substr(seg.column_name,8));
      			    EGO_Item_Catalog_Pub.G_KF_SEGMENT_VALUES(j) := l_segment_values(i);
   			end loop;

			-- dbms_output.put_line('returning ccid . . . ' || FND_FLEX_KEYVAL.Combination_ID);
		*/

      			return FND_FLEX_KEYVAL.Combination_ID;

		ELSIF (is_valid AND p_operation = 'CHECK_SEGMENTS')
		THEN

			return 1;
		ELSIF ( NOT is_valid AND p_operation = 'CHECK_SEGMENTS')
		THEN
			return 0;

		ELSE
			-- dbms_output.put_line('operation: ' || p_operation || ' returning NULL ' );
			return NULL;

		END IF;

	END Get_Catalog_Group_Id;


	/********************************************************************
	** Procedure: Get_Catalog_Group_Name (Unexposed)
	** Purpose  : Will take the Id and return the concatenated segments
	**	      a.k.a the catalog group name. If a record is not found
	**	      then it means the id is invalid.
	*********************************************************************/
       	FUNCTION Get_Catalog_Group_Name
                 (  p_catalog_group_id        IN  NUMBER)
        RETURN VARCHAR2
        IS
        BEGIN

		-- dbms_output.put_line('validating ID: ' || p_catalog_group_id);

		if FND_Flex_KeyVal.validate_ccid(appl_short_name	=> 'INV',
				 key_flex_code	  	=> 'MICG',
				 structure_number	=> 101,
				 combination_id	  	=> p_catalog_group_id
				 )
                THEN
			-- dbms_output.put_line('returning name ' || FND_FLEX_KEYVAL.concatenated_values);
                        return FND_FLEX_KEYVAL.concatenated_values;
                ELSE
                        return null;
                END IF;

        END Get_Catalog_Group_Name;


	/*******************************************************************
	* Procedure	: Perform Segment break up and return a ccid
	* Purpose	: Performs the a breakup of the semgments are arranges
	*		  the segments sequentially. If the create_new param
	*		  is true then a new ccid will be returned. Else
	*		  It will return 0 to indicate no errors and -1 otherwise
	********************************************************************/
	FUNCTION Perform_Segment_Breakup (p_create_new	BOOLEAN DEFAULT true)
	RETURN NUMBER
	IS
		l_segment_values FND_FLEX_EXT.SegmentArray;
                kff        fnd_flex_key_api.flexfield_type;
                str        fnd_flex_key_api.structure_type;
                seg        fnd_flex_key_api.segment_type;
                seg_list   fnd_flex_key_api.segment_list;
                j          number;
                i          number;
                nsegs      number;
                ccid       number := 0;
                is_valid  boolean;
		l_delimiter varchar2(1) := FND_Flex_Ext.Get_Delimiter
                                        (  application_short_name       => 'INV'
                                         , key_flex_code                => 'MICG'
                                         , structure_number             => 101
                                         );
	BEGIN
		nsegs := fnd_flex_ext.breakup_segments
                         (  delimiter    => l_delimiter
                          , concatenated_segs =>
                          	EGO_Globals.G_Catalog_Group_Rec.catalog_group_name
                          , segments     => l_segment_values
                          );
                kff := fnd_flex_key_api.find_flexfield('INV','MICG');
                str := fnd_flex_key_api.find_structure(kff, 101);
                fnd_flex_key_api.get_segments(kff, str, TRUE, nsegs, seg_list);

                --
                -- The segments in the seg_list array are sorted in display order.
                -- i.e. sorted by segment number.
                --
                -- dbms_output.put_line('starting with segment ordering . . .');

                for i in 1..nsegs
                loop
                     seg := fnd_flex_key_api.find_segment
			      (kff,
                               str,
                               seg_list(i));
                     j := to_number(substr(seg.column_name,8));
                     EGO_Item_Catalog_Pub.G_KF_SEGMENT_VALUES(j) :=
                                                    l_segment_values(i);
		     -- dbms_output.put_line('value at ' || j || ' is: ' || l_segment_values(i));
                 end loop;

		 IF (p_create_new)
		 THEN
                 	SELECT mtl_item_catalog_groups_b_s.nextval
                 	INTO ccid
                 	FROM dual;
		 END IF;

		 return ccid;

	END Perform_Segment_Breakup;

	/********************************************************
	* Function	: Concatenate_Segments
	* Purpose	: Takes the individual segments and
	*		  concatenates them based on the flex
	*		  structure, by arranging the segments in
	*		  display order and then calling the flex api.
	* Returns	: the concatenated segment value.
	*********************************************************/

	FUNCTION concatenate_segments(p_appl_short_name IN VARCHAR2,
                         	      p_key_flex_code IN VARCHAR2,
                         	      p_structure_number IN NUMBER)
  	RETURN VARCHAR2
  	IS

     		l_key_flex_field   fnd_flex_key_api.flexfield_type;
     		l_structure_type   fnd_flex_key_api.structure_type;
     		l_segment_type     fnd_flex_key_api.segment_type;
     		l_segment_list     fnd_flex_key_api.segment_list;
     		l_segment_array    fnd_flex_ext.SegmentArray;
     		l_num_segments     NUMBER;
     		l_flag             BOOLEAN;
     		l_concat           VARCHAR2(2000);
     		j                  NUMBER;
     		i                  NUMBER;
	BEGIN

		-- dbms_output.put_line('Performing segment concatenation . . . ');

   		fnd_flex_key_api.set_session_mode('seed_data');

   		l_key_flex_field :=
     		fnd_flex_key_api.find_flexfield(p_appl_short_name,
                                     p_key_flex_code);

   		l_structure_type :=
     		fnd_flex_key_api.find_structure(l_key_flex_field,
                                     p_structure_number);

   		fnd_flex_key_api.get_segments(l_key_flex_field, l_structure_type,
                                 TRUE, l_num_segments, l_segment_list);


   		--
   		-- The segments in the seg_list array are sorted in display order.
   		-- i.e. sorted by segment number.
   		--
   		for i in 1..l_num_segments
		loop
      			l_segment_type :=
        		fnd_flex_key_api.find_segment(l_key_flex_field,
                                      l_structure_type,
                                      l_segment_list(i));
      			j := to_number(substr(l_segment_type.column_name,8));
      			l_segment_array(i) := Ego_Item_Catalog_Pub.G_KF_SEGMENT_VALUES(j);
   		end loop;

   		--
   		-- Now we have the all segment values in correct order in segarray.
   		--
   		l_concat := fnd_flex_ext.concatenate_segments(l_num_segments,
               		                  l_segment_array,
                       		          l_structure_type.segment_separator);

		-- dbms_output.put_line('Return from concatenate_segments ' || l_concat);

   		RETURN l_concat;

	END concatenate_segments;

	FUNCTION check_segments_populated RETURN BOOLEAN
	IS
	BEGIN
	 	IF ( (EGO_Globals.G_Catalog_Group_Rec.Segment1 IS NOT NULL AND
                      EGO_Globals.G_Catalog_Group_Rec.Segment1 <> FND_API.G_MISS_CHAR
                      ) OR
                     (EGO_Globals.G_Catalog_Group_Rec.Segment2 IS NOT NULL AND
                      EGO_Globals.G_Catalog_Group_Rec.Segment2 <> FND_API.G_MISS_CHAR
                      ) OR
                     (EGO_Globals.G_Catalog_Group_Rec.Segment3 IS NOT NULL AND
                      EGO_Globals.G_Catalog_Group_Rec.Segment3 <> FND_API.G_MISS_CHAR
                      ) OR
                     (EGO_Globals.G_Catalog_Group_Rec.Segment4 IS NOT NULL AND
                      EGO_Globals.G_Catalog_Group_Rec.Segment4 <> FND_API.G_MISS_CHAR
                      ) OR
                     (EGO_Globals.G_Catalog_Group_Rec.Segment5 IS NOT NULL AND
                      EGO_Globals.G_Catalog_Group_Rec.Segment5 <> FND_API.G_MISS_CHAR
                      ) OR
                     (EGO_Globals.G_Catalog_Group_Rec.Segment6 IS NOT NULL AND
                      EGO_Globals.G_Catalog_Group_Rec.Segment6 <> FND_API.G_MISS_CHAR
                      ) OR
                     (EGO_Globals.G_Catalog_Group_Rec.Segment7 IS NOT NULL AND
                      EGO_Globals.G_Catalog_Group_Rec.Segment7 <> FND_API.G_MISS_CHAR
                      ) OR
                     (EGO_Globals.G_Catalog_Group_Rec.Segment8 IS NOT NULL AND
                      EGO_Globals.G_Catalog_Group_Rec.Segment8 <> FND_API.G_MISS_CHAR
                      ) OR
                     (EGO_Globals.G_Catalog_Group_Rec.Segment9 IS NOT NULL AND
                      EGO_Globals.G_Catalog_Group_Rec.Segment9 <> FND_API.G_MISS_CHAR
                      ) OR
                     (EGO_Globals.G_Catalog_Group_Rec.Segment10 IS NOT NULL AND
                      EGO_Globals.G_Catalog_Group_Rec.Segment10 <> FND_API.G_MISS_CHAR
                      ) OR
                     (EGO_Globals.G_Catalog_Group_Rec.Segment11 IS NOT NULL AND
                      EGO_Globals.G_Catalog_Group_Rec.Segment12 <> FND_API.G_MISS_CHAR
                      ) OR
                     (EGO_Globals.G_Catalog_Group_Rec.Segment13 IS NOT NULL AND
                      EGO_Globals.G_Catalog_Group_Rec.Segment13 <> FND_API.G_MISS_CHAR
                      ) OR
                     (EGO_Globals.G_Catalog_Group_Rec.Segment14 IS NOT NULL AND
                      EGO_Globals.G_Catalog_Group_Rec.Segment14 <> FND_API.G_MISS_CHAR
                      ) OR
                     (EGO_Globals.G_Catalog_Group_Rec.Segment15 IS NOT NULL AND
                      EGO_Globals.G_Catalog_Group_Rec.Segment15 <> FND_API.G_MISS_CHAR
                      ) OR
                     (EGO_Globals.G_Catalog_Group_Rec.Segment16 IS NOT NULL AND
                      EGO_Globals.G_Catalog_Group_Rec.Segment16 <> FND_API.G_MISS_CHAR
                      ) OR
                     (EGO_Globals.G_Catalog_Group_Rec.Segment17 IS NOT NULL AND
                      EGO_Globals.G_Catalog_Group_Rec.Segment17 <> FND_API.G_MISS_CHAR
                      ) OR
                     (EGO_Globals.G_Catalog_Group_Rec.Segment18 IS NOT NULL AND
                      EGO_Globals.G_Catalog_Group_Rec.Segment18 <> FND_API.G_MISS_CHAR
                      ) OR
                     (EGO_Globals.G_Catalog_Group_Rec.Segment19 IS NOT NULL AND
                      EGO_Globals.G_Catalog_Group_Rec.Segment19<> FND_API.G_MISS_CHAR
                      ) OR
                     (EGO_Globals.G_Catalog_Group_Rec.Segment20 IS NOT NULL AND
                      EGO_Globals.G_Catalog_Group_Rec.Segment20 <> FND_API.G_MISS_CHAR
                      )
		    )
		 THEN
			return true;
		 ELSE
			return false;
		 END IF;
	END;


        /*********************************************************************
        * Procedure     : EGO_ItemCatalog_UUI_To_UI
        * Returns       : None
        * Parameters IN :
        * Parameters OUT:
        *                 Message Token Table
        *                 Return Status
        * Purpose       :
        *********************************************************************/
	PROCEDURE EGO_ItemCatalog_UUI_To_UI
        (  x_Mesg_Token_Tbl          OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_Return_Status           OUT NOCOPY VARCHAR2
        )
        IS
                l_Mesg_Token_Tbl         Error_Handler.Mesg_Token_Tbl_Type;
                l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
		l_result		VARCHAR2(2000);

                is_valid  boolean;
		is_passed boolean := false;
		check_status number;
		l_catalog_group_name VARCHAR2(1000);
		concat_group_name VARCHAR2(1000);
        BEGIN
                x_return_status := FND_API.G_RET_STS_SUCCESS;

		fnd_flex_key_api.set_session_mode('seed_data');
		--
		-- If the user has specified the name, id and segment then id is first
		-- validated and rest of the values are disregarded
		-- If the Id is not given and name and segments are given then the name
		-- would be validated and segments would be disregarded.
		-- Else segments will be validated.
		--

		IF (EGO_Globals.G_Catalog_Group_Rec.catalog_group_id IS NULL OR
		    EGO_Globals.G_Catalog_Group_Rec.catalog_group_id = FND_API.G_MISS_NUM
		   ) AND
		   ( EGO_Globals.G_Catalog_Group_Rec.catalog_group_name IS NULL OR
		     EGO_Globals.G_Catalog_Group_Rec.catalog_group_name = FND_API.G_MISS_CHAR
		   ) AND Check_Segments_Populated
		THEN
			is_passed := TRUE;

			EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Name :=
			    concatenate_segments(  p_appl_short_name 	=> 'INV'
                                      		 , p_key_flex_code 	=> 'MICG'
                                      		 , p_structure_number	=> 101
						 );
			IF EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Name IS NULL
                        THEN
                                -- dbms_output.put_line('concat group name is NULL  ' );

                                Error_Handler.Add_Error_Token
                                (  x_mesg_token_Tbl     => l_mesg_token_tbl
                                 , p_application_id     => 'EGO'
                                 , p_message_name       => 'EGO_CAT_SEGMENTS_INVALID'
                                 );
                                 l_return_status := FND_API.G_RET_STS_ERROR;
			ELSE
				--
				-- Get the corresponding Catalog group id
				--
			        check_status :=
                        	Get_Catalog_Group_Id(  p_catalog_group_name =>
                                                         EGO_Globals.G_Catalog_Group_Rec.catalog_group_name
                                             	     , p_operation  => 'FIND_COMBINATION'
                                             	     );
				-- dbms_output.put_line('ccid after FIND_COMBINATION . . . ' || check_status );

                        	IF (check_status IS NOT null)
                        	THEN
                               	 	-- if not null then the returned value is the ccid

                               		EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Id := check_status;

					/* It is an error if the CCID exists
					   when the transaction type is CREATE */

					IF EGO_Globals.G_Catalog_Group_Rec.Transaction_Type =
								EGO_Globals.G_OPR_CREATE
					THEN
                                		Error_Handler.Add_Error_Token
                                		(  x_mesg_token_Tbl     => l_mesg_token_tbl
                                 		, p_application_id     => 'EGO'
                                 		, p_message_name       => 'EGO_CATALOG_ALREADY_EXISTS'
                                 		);
                                 		l_return_status := FND_API.G_RET_STS_ERROR;
					END IF;
                        	ELSE

					-- dbms_output.put_line('Error if it is update or delete . . .');

					/* It is an error if the CCID does not exist
					   when the transaction type is DELETE or UPDATE */

					IF EGO_Globals.G_Catalog_Group_Rec.Transaction_Type IN
						(EGO_Globals.G_OPR_UPDATE,EGO_Globals.G_OPR_DELETE)
					THEN
                                		Error_Handler.Add_Error_Token
                                		(  x_mesg_token_Tbl     => l_mesg_token_tbl
                                 		, p_application_id     => 'EGO'
                                 		, p_message_name       => 'EGO_CATALOG_DOESNOT_EXIST'
                                 		);
                                 		l_return_status := FND_API.G_RET_STS_ERROR;
					ELSE

						/* CCID will be generated when it does not exist in the
						   case of SYNC and CREATE */

						-- dbms_output.put_line('CHECK_SEGMENTS from here . . .');

                                		check_status :=
                                		Get_Catalog_Group_Id(  p_catalog_group_name =>
                                       		            EGO_Globals.G_Catalog_Group_Rec.catalog_group_name
                                                 		, p_operation  => 'CHECK_SEGMENTS'
                                                  		);

                                		-- if segments are valid then proceed

                                		IF (check_status = 1)
                                		THEN
                                        		EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Id :=
                                                		Generate_Catalog_Group_Id;

                                        		-- dbms_output.put_line('ccid assigned: ' || EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Id);
						ELSE
                                			Error_Handler.Add_Error_Token
                                			(  x_mesg_token_Tbl     => l_mesg_token_tbl
                                 			, p_application_id     => 'EGO'
                                 			, p_message_name       => 'EGO_CAT_SEGMENTS_INVALID'
                                 			);
                                 			l_return_status := FND_API.G_RET_STS_ERROR;
						END IF;
					END IF;
                                END IF;
			END IF;
                --
                -- Convert Catalog_Group_Id into name
                --
                ELSIF (EGO_Globals.G_Catalog_Group_Rec.catalog_group_id IS NOT NULL AND
                    EGO_Globals.G_Catalog_Group_Rec.catalog_group_id <> FND_API.G_MISS_NUM)
                THEN

			is_passed := TRUE;

			-- If the user has passed catalog_group_id with the transaction_type as 'SYNC'
			-- then we need to derive the intended transaction_type to proceed from here

			IF EGO_Globals.G_Catalog_Group_Rec.Transaction_Type = 'SYNC'
			THEN
				IF Check_Catalog_CCID THEN
			  		EGO_Globals.G_Catalog_Group_Rec.Transaction_Type := EGO_Globals.G_OPR_UPDATE;
				ELSE
			  		EGO_Globals.G_Catalog_Group_Rec.Transaction_Type := EGO_Globals.G_OPR_CREATE;
				END IF;
			END IF;

                        -- dbms_output.put_line('Getting Group Name from ID ... ');

                        l_Catalog_Group_Name :=
                                Get_Catalog_Group_Name(p_catalog_group_id =>
                                                        EGO_Globals.G_Catalog_Group_Rec.catalog_group_id
                                                       );

			/* It is an error if the group name exists
			   when the transaction type is CREATE */

			IF l_Catalog_Group_Name IS NOT NULL AND EGO_Globals.G_Catalog_Group_Rec.Transaction_Type =
						EGO_Globals.G_OPR_CREATE
			THEN
                              		Error_Handler.Add_Error_Token
                              		(  x_mesg_token_Tbl     => l_mesg_token_tbl
                               		, p_application_id     => 'EGO'
                                 	, p_message_name       => 'EGO_CATALOG_ALREADY_EXISTS'
                              		);
                               		l_return_status := FND_API.G_RET_STS_ERROR;

			/* It is an error if the group name does not exist
			   when the transaction type is DELETE or UPDATE */

                        ELSIF l_Catalog_Group_Name IS NULL AND
				EGO_Globals.G_Catalog_Group_Rec.Transaction_Type <> EGO_Globals.G_OPR_CREATE
                        THEN

                                Error_Handler.Add_Error_Token
                                (  x_mesg_token_Tbl     => l_mesg_token_tbl
				 , p_application_id	=> 'EGO'
                                 , p_message_name       => 'EGO_CATALOG_DOESNOT_EXIST'
                                );
                                l_return_status := FND_API.G_RET_STS_ERROR;

			ELSIF EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Name IS NOT NULL AND
			        EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Name <> FND_API.G_MISS_CHAR
			THEN

				-- As long as the group name is passed, it takes precedence over the segments

                               /*   IF EGO_Globals.G_Catalog_Group_Rec.Transaction_Type = EGO_Globals.G_OPR_CREATE OR
			 	     EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Name <> l_Catalog_Group_Name
                                  THEN
                                               -- breakup the segments and store it for use
                                                -- during database writes.
                                                check_status := Perform_Segment_Breakup(p_create_new => false);
                                  END IF;
				*/
                                  check_status := Perform_Segment_Breakup(p_create_new => false);

			ELSIF (Check_Segments_Populated)
		        THEN
				 -- Verify if the concatenated value of any of the segments entered is
				 -- different than what the Id would return. If yes then the user
				 -- is attempting to rename the catalog group.
				 concat_Group_Name := concatenate_segments
							(  p_appl_short_name    => 'INV'
                                                 	 , p_key_flex_code      => 'MICG'
                                                 	 , p_structure_number   => 101
                                                 	 );
				 --
				 -- validate the concatenated segments
				 --
				 IF (Get_Catalog_Group_Id( p_operation		=> 'CHECK_SEGMENTS'
							  ,p_catalog_group_name => concat_Group_Name
							  ) = 1
				     )
				 THEN
				      -- catalog_group_name : that is fetched using the id is not the
				      -- the same as the concatenation of the segments then, the user
				      -- could be renaming the catalog group.

				      IF EGO_Globals.G_Catalog_Group_Rec.Transaction_Type = EGO_Globals.G_OPR_CREATE 						OR concat_Group_Name <> l_Catalog_Group_Name
				      THEN
						-- dbms_output.put_line('concat group name: ' || concat_Group_Name || ' catalog group name from id: ' || l_Catalog_Group_Name);

				      		EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Name :=
									concat_Group_Name;
				      END IF;
				 ELSE
					Error_Handler.Add_Error_Token
                                	(  x_mesg_token_Tbl     => l_mesg_token_tbl
				 	 , p_application_id	=> 'EGO'
                                	 , p_message_name       => 'EGO_CAT_SEGMENTS_INVALID'
                               	 	);
					l_return_status := FND_API.G_RET_STS_ERROR;
				 END IF;

			ELSE
				/* Default the existing segments if the current operation is not CREATE*/

				-- For CREATE this is an error condition since we need either Group name or
				-- the Segments apart from the Id

				IF EGO_Globals.G_Catalog_Group_Rec.Transaction_Type = EGO_Globals.G_OPR_CREATE
				THEN
					Error_Handler.Add_Error_Token
                                	(  x_mesg_token_Tbl     => l_mesg_token_tbl
				 	 , p_application_id	=> 'EGO'
                                	 , p_message_name       => 'EGO_CAT_SEGMENTS_INVALID'
                               	 	);
					l_return_status := FND_API.G_RET_STS_ERROR;
				ELSE
					EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Name := l_Catalog_Group_Name;
					check_status := Perform_Segment_Breakup(p_create_new => false);
				END IF;
		        END IF;

                -- Get Catalog Group Id using Catalog Group Name
                --
                ELSIF (EGO_Globals.G_Catalog_Group_Rec.catalog_group_name IS NOT NULL AND
                    EGO_Globals.G_Catalog_Group_Rec.catalog_group_name <> FND_API.G_MISS_CHAR)
                THEN

			is_passed := TRUE;

			Error_Handler.Write_Debug('getting id for ' ||
						EGO_Globals.G_Catalog_Group_Rec.catalog_group_name);

			-- dbms_output.put_line('getting id for ' || EGO_Globals.G_Catalog_Group_Rec.catalog_group_name);

                        EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_id :=
                            Get_Catalog_Group_Id(  p_catalog_group_name =>
                                                   EGO_Globals.G_Catalog_Group_Rec.catalog_group_name
						 , p_operation	=> 'FIND_COMBINATION'
                                                  );

			IF (EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Id IS NOT NULL)
			THEN

				check_status := Perform_Segment_Breakup(p_create_new => false);

				/* It is an error if the CCID exists
			   	when the transaction type is CREATE */

				IF EGO_Globals.G_Catalog_Group_Rec.Transaction_Type = EGO_Globals.G_OPR_CREATE
				THEN
                              		Error_Handler.Add_Error_Token
                              		(  x_mesg_token_Tbl     => l_mesg_token_tbl
                               		, p_application_id     => 'EGO'
                                 	, p_message_name       => 'EGO_CATALOG_ALREADY_EXISTS'
                              		);
                               		l_return_status := FND_API.G_RET_STS_ERROR;
				END IF;
			ELSE

				/* It is an error if the CCID does not exist
			   	when the transaction type is DELETE or UPDATE */

				IF EGO_Globals.G_Catalog_Group_Rec.Transaction_Type IN
						(EGO_Globals.G_OPR_UPDATE,EGO_Globals.G_OPR_DELETE)
				THEN
                               		Error_Handler.Add_Error_Token
                               		(  x_mesg_token_Tbl     => l_mesg_token_tbl
                               		, p_application_id     => 'EGO'
                                 	, p_message_name       => 'EGO_CATALOG_DOESNOT_EXIST'
                               		);
                               		l_return_status := FND_API.G_RET_STS_ERROR;
				ELSE

					/* Validate the segments and Generate ID if the Transaction type
					   is SYNC or CREATE */

					check_status :=
                            		Get_Catalog_Group_Id(  p_catalog_group_name =>
                                                   EGO_Globals.G_Catalog_Group_Rec.catalog_group_name
                                                 , p_operation  => 'CHECK_SEGMENTS'
                                                  );
					IF (check_status = 1)
			        	THEN
						EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Id :=
							Perform_Segment_Breakup;

                        			-- dbms_output.put_line('ccid assigned: ' || EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Id);
					ELSIF (check_status = 0)
					THEN
						Error_Handler.Add_Error_Token
                              			(  x_mesg_token_Tbl     => l_mesg_token_tbl
					 	, p_application_id     => 'EGO'
                               		 	, p_message_text       => G_Error_Msg_Text
                               			);
                               			l_return_status := FND_API.G_RET_STS_ERROR;
					END IF;
				END IF;
			END IF;
                END IF;

		-- If there are no key values passed for this row, then raise error
		--
		IF NOT is_passed THEN
			Error_Handler.Add_Error_Token
                        (  x_mesg_token_Tbl     => l_mesg_token_tbl
		 	, p_application_id     => 'EGO'
                        , p_message_text       => 'EGO_CAT_KEYCOLS_NOT_PASSED'
                       	);
                       l_return_status := FND_API.G_RET_STS_ERROR;
		END IF;
                --
                -- Get Parent Catalog Group Id using Parent Catalog Group Name
                --
                IF (EGO_Globals.G_Catalog_Group_Rec.parent_catalog_group_name IS NOT NULL AND
                    EGO_Globals.G_Catalog_Group_Rec.parent_catalog_group_name <> FND_API.G_MISS_CHAR
                   )
                THEN
                        EGO_Globals.G_Catalog_Group_Rec.parent_Catalog_Group_Id :=
                            Get_Catalog_Group_Id(p_catalog_group_name =>
                                                   EGO_Globals.G_Catalog_Group_Rec.parent_catalog_group_name
						 , p_operation 	=> 'FIND_COMBINATION'
                                                  );

			Error_Handler.Write_Debug('Parent Catalog Group Id: ' ||
						  EGO_Globals.G_Catalog_Group_Rec.Parent_Catalog_Group_Id);

			-- dbms_output.put_line('Parent Catalog Group Id: ' || EGO_Globals.G_Catalog_Group_Rec.Parent_Catalog_Group_Id);

                        IF EGO_Globals.G_Catalog_Group_Rec.Parent_Catalog_Group_Id IS NULL
                        THEN

			-- dbms_output.put_line('Parent Catalog Group Id NOT FOUND . . . ');
                                Error_Handler.Add_Error_Token
                                (  x_mesg_token_Tbl     => l_mesg_token_tbl
				 , p_application_id     => 'EGO'
                                 , p_message_text       => G_Error_Msg_Text
				);
                                l_return_status := FND_API.G_RET_STS_ERROR;
                        END IF;
                END IF;

		--
		-- Convert Parent_Catalog_Group_Id into Parent_Catalog_Group_name
		--
                IF (EGO_Globals.G_Catalog_Group_Rec.parent_catalog_group_id IS NOT NULL AND
                    EGO_Globals.G_Catalog_Group_Rec.parent_catalog_group_id <> FND_API.G_MISS_NUM
                   )
                THEN
			-- dbms_output.put_line('Getting Parent Group Name from ID ... ' || EGO_Globals.G_Catalog_Group_Rec.parent_catalog_group_id);

                        EGO_Globals.G_Catalog_Group_Rec.parent_Catalog_Group_name :=
                            Get_Catalog_Group_Name(p_catalog_group_id =>
                                                   EGO_Globals.G_Catalog_Group_Rec.parent_catalog_group_id
                                                  );

                        IF EGO_Globals.G_Catalog_Group_Rec.Parent_Catalog_Group_Name IS NULL
                        THEN

                                Error_Handler.Add_Error_Token
                                (  x_mesg_token_Tbl     => l_mesg_token_tbl
				 , p_application_id   => 'EGO'
                                 , p_message_text       => G_Error_Msg_Text
                                );
				l_return_status := FND_API.G_RET_STS_ERROR;
                        END IF;
			-- dbms_output.put_line('Getting Parent Group Name from ID ... ' || EGO_Globals.G_Catalog_Group_Rec.Parent_Catalog_Group_Name);

                END IF;

		-- dbms_output.put_line('UUI Conversion done . . .returning ' || l_return_status);
		Error_Handler.Write_Debug('UUI Conversion done . . . returning ' || l_return_status) ;

		x_return_status := l_return_status;
		x_mesg_token_tbl := l_mesg_token_tbl;

	END EGO_ItemCatalog_UUI_To_UI;


        /*********************************************************************
        * Procedure     : EGO_ItemCatalog_UUI_To_UI2 (Old EGO_ItemCatalog_UUI_To_UI logic)
        * Returns       : None
        * Parameters IN :
        * Parameters OUT:
        *                 Message Token Table
        *                 Return Status
        * Purpose       :
        *********************************************************************/
	PROCEDURE EGO_ItemCatalog_UUI_To_UI2
        (  x_Mesg_Token_Tbl          OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
         , x_Return_Status           OUT NOCOPY VARCHAR2
        )
        IS
                l_Mesg_Token_Tbl         Error_Handler.Mesg_Token_Tbl_Type;
                l_return_status         VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
		l_result		VARCHAR2(2000);

                is_valid  boolean;
		is_new    boolean;
		check_status number;
		l_catalog_group_name VARCHAR2(1000);
		concat_group_name VARCHAR2(1000);
        BEGIN
                x_return_status := FND_API.G_RET_STS_SUCCESS;
		fnd_flex_key_api.set_session_mode('seed_data');


		-- dbms_output.put_line('Performing UUI conversion . . . ');


		--
		--  If the user has specified the name, id and segment then id is first
		-- validated and rest of the values are disregarded
		-- If the Id is not given and name and segments are given then the name
		-- would be validated and segments would be disregarded.
		-- Else segments will be validated.
		--

		IF (EGO_Globals.G_Catalog_Group_Rec.catalog_group_id IS NULL OR
		    EGO_Globals.G_Catalog_Group_Rec.catalog_group_id = FND_API.G_MISS_NUM
		   ) AND
		   ( EGO_Globals.G_Catalog_Group_Rec.catalog_group_name IS NULL OR
		     EGO_Globals.G_Catalog_Group_Rec.catalog_group_name = FND_API.G_MISS_CHAR
		   ) AND check_segments_populated
		THEN
			-- dbms_output.put_line('Segments populated . . . ');
			EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Name :=
			    concatenate_segments(  p_appl_short_name 	=> 'INV'
                                      		 , p_key_flex_code 	=> 'MICG'
                                      		 , p_structure_number	=> 101
						 );
			IF EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Name IS NULL
                        THEN
                                -- dbms_output.put_line('concat group name is NULL  ' );

                                Error_Handler.Add_Error_Token
                                (  x_mesg_token_Tbl     => l_mesg_token_tbl
                                 , p_application_id     => 'EGO'
                                 , p_message_name       => 'EGO_CAT_SEGMENTS_INVALID'
                                 );
                                 l_return_status := FND_API.G_RET_STS_ERROR;
			ELSE
				--
				-- Get the corresponding Catalog group id
				--
			        check_status :=
                        	Get_Catalog_Group_Id(  p_catalog_group_name =>
                                                         EGO_Globals.G_Catalog_Group_Rec.catalog_group_name
                                             	     , p_operation  => 'FIND_COMBINATION'
                                             	     );
				-- dbms_output.put_line('ccid after FIND_COMBINATION . . . ' || check_status );
                        	IF (check_status IS NOT null)
                        	THEN
                               	 -- if not null then the returned value is the ccid

                               	 EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Id := check_status;

                        	ELSE
					-- dbms_output.put_line('CHECK_SEGMENTS from here . . .');

                                	check_status :=
                                	Get_Catalog_Group_Id(  p_catalog_group_name =>
                                       		            EGO_Globals.G_Catalog_Group_Rec.catalog_group_name
                                                 		, p_operation  => 'CHECK_SEGMENTS'
                                                  		);
                                	-- if segments are valid then proceed
                                	IF (check_status = 1)
                                	THEN
                                        	EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Id :=
                                                	Perform_Segment_Breakup;
						is_new := true;

                                        	-- dbms_output.put_line('ccid assigned: ' || EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Id);
					END IF;
                                END IF;
			END IF;

		END IF;

                --
                -- Convert Catalog_Group_Id into name
                --
                IF (EGO_Globals.G_Catalog_Group_Rec.catalog_group_id IS NOT NULL AND
                    EGO_Globals.G_Catalog_Group_Rec.catalog_group_id <> FND_API.G_MISS_NUM
                   ) AND NOT is_new
                THEN
                        -- dbms_output.put_line('Getting Group Name from ID ... ');
                        l_Catalog_Group_Name :=
                                Get_Catalog_Group_Name(p_catalog_group_id =>
                                                        EGO_Globals.G_Catalog_Group_Rec.catalog_group_id
                                                       );

                        IF l_Catalog_Group_Name IS NULL
                        THEN

                                Error_Handler.Add_Error_Token
                                (  x_mesg_token_Tbl     => l_mesg_token_tbl
				 , p_application_id	=> 'EGO'
                                 , p_message_text       => G_Error_Msg_Text
                                );
                                l_return_status := FND_API.G_RET_STS_ERROR;

			ELSE IF (EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Name IS NULL OR
				 EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Name = FND_API.G_MISS_CHAR
				 )
				 AND
				 check_segments_populated
			     THEN
				 -- Verify if the concatenated value of any of the segments entered is
				 -- different than what the Id would return. If yes then the user
				 -- is attempting to rename the catalog group.
				 concat_Group_Name := concatenate_segments
							(  p_appl_short_name    => 'INV'
                                                 	 , p_key_flex_code      => 'MICG'
                                                 	 , p_structure_number   => 101
                                                 	 );
				 --
				 -- validate the concatenated segments
				 --
				 IF (Get_Catalog_Group_Id( p_operation		=> 'CHECK_SEGMENTS'
							  ,p_catalog_group_name => concat_Group_Name
							  ) = 1
				     )
				 THEN
				      -- catalog_group_name : that is fetched using the id is not the
				      -- the same as the concatenation of the segments then, the user
				      -- could be renaming the catalog group.

				      IF concat_Group_Name <> l_Catalog_Group_Name
				      THEN
						-- dbms_output.put_line('concat group name: ' || concat_Group_Name || ' catalog group name from id: ' || l_Catalog_Group_Name);

				      		EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Name :=
									concat_Group_Name;

						-- breakup the segments and store it for use
						-- during database writes.
						check_status := Perform_Segment_Breakup(p_create_new => false);
				      END IF;
				 ELSE
					Error_Handler.Add_Error_Token
                                	(  x_mesg_token_Tbl     => l_mesg_token_tbl
				 	 , p_application_id	=> 'EGO'
                                	 , p_message_name       => 'EGO_CAT_SEGMENTS_INVALID'
                               	 	);
					l_return_status := FND_API.G_RET_STS_ERROR;
				 END IF;
			     END IF;

                        END IF;
                END IF;

                -- Get Catalog Group Id using Catalog Group Name
                --
                IF (EGO_Globals.G_Catalog_Group_Rec.catalog_group_name IS NOT NULL AND
                    EGO_Globals.G_Catalog_Group_Rec.catalog_group_name <> FND_API.G_MISS_CHAR AND
		    EGO_Globals.G_Catalog_Group_Rec.Transaction_Type <> EGO_Globals.G_OPR_CREATE AND
                    ( EGO_Globals.G_Catalog_Group_Rec.catalog_group_id IS NULL  OR
                      EGO_Globals.G_Catalog_Group_Rec.catalog_group_id = FND_API.G_MISS_NUM
                     )
                   )
                THEN
			Error_Handler.Write_Debug('getting id for ' || EGO_Globals.G_Catalog_Group_Rec.catalog_group_name);
			-- dbms_output.put_line('getting id for ' || EGO_Globals.G_Catalog_Group_Rec.catalog_group_name);
                        EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_id :=
                            Get_Catalog_Group_Id(  p_catalog_group_name =>
                                                   EGO_Globals.G_Catalog_Group_Rec.catalog_group_name
						 , p_operation	=> 'FIND_COMBINATION'
                                                  );

			--
			-- If the transaction type was SYNC and the previous opr. did not return
			-- a row then it could be a create operation
			--

			if(EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Id IS NULL)
			THEN
					check_status :=
                            		Get_Catalog_Group_Id(  p_catalog_group_name =>
                                                   EGO_Globals.G_Catalog_Group_Rec.catalog_group_name
                                                 , p_operation  => 'CHECK_SEGMENTS'
                                                  );
				IF (check_status = 1)
			        THEN
					EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Id :=
						Perform_Segment_Breakup;

                        		-- dbms_output.put_line('ccid assigned: ' || EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Id);
				ELSIF (check_status = 0)
				THEN
					Error_Handler.Add_Error_Token
                              		(  x_mesg_token_Tbl     => l_mesg_token_tbl
					 , p_application_id     => 'EGO'
                               		 , p_message_text       => G_Error_Msg_Text
                               		);
                               		l_return_status := FND_API.G_RET_STS_ERROR;
				END IF;
			END IF;
				   /* if the OPERATION IS CREATE rather than SYNC */
		ELSIF (EGO_Globals.G_Catalog_Group_Rec.catalog_group_name IS NOT NULL AND
                       EGO_Globals.G_Catalog_Group_Rec.catalog_group_name <> FND_API.G_MISS_CHAR AND
                       EGO_Globals.G_Catalog_Group_Rec.Transaction_Type = EGO_Globals.G_OPR_CREATE AND
                       ( EGO_Globals.G_Catalog_Group_Rec.catalog_group_id IS NULL  OR
                         EGO_Globals.G_Catalog_Group_Rec.catalog_group_id = FND_API.G_MISS_NUM
                        )
                      )
		THEN
			check_status :=
                        Get_Catalog_Group_Id(  p_catalog_group_name =>
                                                         EGO_Globals.G_Catalog_Group_Rec.catalog_group_name
                                             , p_operation  => 'FIND_COMBINATION'
                                             );
			IF (check_status <> null)
			THEN
				-- if not null then the returned value is the ccid

				EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Id := check_status;
			ELSE
			        check_status :=
                                Get_Catalog_Group_Id(  p_catalog_group_name =>
                                                   EGO_Globals.G_Catalog_Group_Rec.catalog_group_name
                                                 , p_operation  => 'CHECK_SEGMENTS'
                                                  );
				-- if segments are valid then proceed
                                IF (check_status = 1)
                                THEN
                                        EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Id :=
                                                Perform_Segment_Breakup;

                                        -- dbms_output.put_line('ccid assigned: ' || EGO_Globals.G_Catalog_Group_Rec.Catalog_Group_Id);
                                ELSIF (check_status = 0)
				THEN
                                        Error_Handler.Add_Error_Token
                                        (  x_mesg_token_Tbl     => l_mesg_token_tbl
					 , p_application_id   => 'EGO'
                                         , p_message_text       => G_Error_Msg_Text
                                        );
                                        l_return_status := FND_API.G_RET_STS_ERROR;
                                END IF;
                         END IF;
                END IF;


                --
                -- Get Parent Catalog Group Id using Parent Catalog Group Name
                --

                IF (EGO_Globals.G_Catalog_Group_Rec.parent_catalog_group_name IS NOT NULL AND
                    EGO_Globals.G_Catalog_Group_Rec.parent_catalog_group_name <> FND_API.G_MISS_CHAR
                   )
                THEN
                        EGO_Globals.G_Catalog_Group_Rec.parent_Catalog_Group_Id :=
                            Get_Catalog_Group_Id(p_catalog_group_name =>
                                                   EGO_Globals.G_Catalog_Group_Rec.parent_catalog_group_name
						 , p_operation 	=> 'FIND_COMBINATION'
                                                  );

			Error_Handler.Write_Debug('Parent Catalog Group Id: ' ||
						  EGO_Globals.G_Catalog_Group_Rec.Parent_Catalog_Group_Id);

			-- dbms_output.put_line('Parent Catalog Group Id: ' || EGO_Globals.G_Catalog_Group_Rec.Parent_Catalog_Group_Id);

                        IF EGO_Globals.G_Catalog_Group_Rec.Parent_Catalog_Group_Id IS NULL
                        THEN

			-- dbms_output.put_line('Parent Catalog Group Id NOT FOUND . . . ');
                                Error_Handler.Add_Error_Token
                                (  x_mesg_token_Tbl     => l_mesg_token_tbl
				 , p_application_id     => 'EGO'
                                 , p_message_text       => G_Error_Msg_Text
				);
                                l_return_status := FND_API.G_RET_STS_ERROR;
                        END IF;
                END IF;

		--
		-- Convert Parent_Catalog_Group_Id into Parent_Catalog_Group_name
		--
                IF (EGO_Globals.G_Catalog_Group_Rec.parent_catalog_group_id IS NOT NULL AND
                    EGO_Globals.G_Catalog_Group_Rec.parent_catalog_group_id <> FND_API.G_MISS_NUM
                   )
                THEN
			-- dbms_output.put_line('Getting Parent Group Name from ID ... ' || EGO_Globals.G_Catalog_Group_Rec.parent_catalog_group_id);

                        EGO_Globals.G_Catalog_Group_Rec.parent_Catalog_Group_name :=
                            Get_Catalog_Group_Name(p_catalog_group_id =>
                                                   EGO_Globals.G_Catalog_Group_Rec.parent_catalog_group_id
                                                  );

                        IF EGO_Globals.G_Catalog_Group_Rec.Parent_Catalog_Group_Name IS NULL
                        THEN

                                Error_Handler.Add_Error_Token
                                (  x_mesg_token_Tbl     => l_mesg_token_tbl
				 , p_application_id   => 'EGO'
                                 , p_message_text       => G_Error_Msg_Text
                                );
				l_return_status := FND_API.G_RET_STS_ERROR;
                        END IF;
			-- dbms_output.put_line('Getting Parent Group Name from ID ... ' || EGO_Globals.G_Catalog_Group_Rec.Parent_Catalog_Group_Name);
                END IF;

		-- dbms_output.put_line('UUI Conversion done . . .returning ' || l_return_status);
		Error_Handler.Write_Debug('UUI Conversion done . . . returning ' || l_return_status) ;

		x_return_status := l_return_status;
		x_mesg_token_tbl := l_mesg_token_tbl;

	END EGO_ItemCatalog_UUI_To_UI2;

        /*********************************************************************
        * Procedure     : EGO_ItemCatalog_VID
        * Returns       : None
        * Parameters IN :
        * Parameters OUT:
        *                 Return Status
        *                 Message Token Table
        * Purpose       :
        *********************************************************************/
        PROCEDURE EGO_ItemCatalog_VID
        (  x_Return_Status         	OUT NOCOPY VARCHAR2
         , x_Mesg_Token_Tbl        	OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
        )
        IS
                l_return_status         VARCHAR2(1):=FND_API.G_RET_STS_SUCCESS;
                l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
                l_err_text              VARCHAR2(2000);
                l_Token_Tbl             Error_Handler.Token_Tbl_Type;
        BEGIN

                Error_Handler.Write_Debug('VID conversion . . . ');

		x_return_status := l_return_status;
		x_mesg_token_tbl := l_mesg_token_tbl;

	END EGO_ItemCatalog_VID;

END EGO_ItemCat_Val_To_Id;

/
