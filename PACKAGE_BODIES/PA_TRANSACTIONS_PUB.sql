--------------------------------------------------------
--  DDL for Package Body PA_TRANSACTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TRANSACTIONS_PUB" AS
/* $Header: PAXTTCPB.pls 120.5.12010000.5 2009/10/21 12:51:23 jravisha ship $ */

	INVALID_DATA EXCEPTION;
----------------------------------------------------------------------
-- Please refer to package spec for detailed description of the
-- procedure.
----------------------------------------------------------------------

PROCEDURE validate_transaction(
	      X_project_id               IN NUMBER
            , X_task_id                  IN NUMBER
            , X_ei_date  	         IN DATE
            , X_expenditure_type         IN VARCHAR2
            , X_non_labor_resource       IN VARCHAR2
            , X_person_id                IN NUMBER
            , X_quantity                 IN NUMBER   DEFAULT NULL
            , X_denom_currency_code      IN VARCHAR2 DEFAULT NULL
            , X_acct_currency_code       IN VARCHAR2 DEFAULT NULL
            , X_denom_raw_cost           IN NUMBER   DEFAULT NULL
            , X_acct_raw_cost            IN NUMBER   DEFAULT NULL
            , X_acct_rate_type           IN VARCHAR2 DEFAULT NULL
            , X_acct_rate_date           IN DATE     DEFAULT NULL
            , X_acct_exchange_rate       IN NUMBER   DEFAULT NULL
            , X_transfer_ei              IN NUMBER   DEFAULT NULL
            , X_incurred_by_org_id       IN NUMBER   DEFAULT NULL
            , X_nl_resource_org_id       IN NUMBER   DEFAULT NULL
            , X_transaction_source       IN VARCHAR2 DEFAULT NULL
            , X_calling_module           IN VARCHAR2 DEFAULT NULL
	    , X_vendor_id	         IN NUMBER   DEFAULT NULL
            , X_entered_by_user_id       IN NUMBER   DEFAULT NULL
            , X_attribute_category       IN VARCHAR2 DEFAULT NULL
            , X_attribute1               IN VARCHAR2 DEFAULT NULL
            , X_attribute2               IN VARCHAR2 DEFAULT NULL
            , X_attribute3               IN VARCHAR2 DEFAULT NULL
            , X_attribute4               IN VARCHAR2 DEFAULT NULL
            , X_attribute5               IN VARCHAR2 DEFAULT NULL
            , X_attribute6               IN VARCHAR2 DEFAULT NULL
            , X_attribute7               IN VARCHAR2 DEFAULT NULL
            , X_attribute8               IN VARCHAR2 DEFAULT NULL
            , X_attribute9               IN VARCHAR2 DEFAULT NULL
            , X_attribute10              IN VARCHAR2 DEFAULT NULL
	    , X_attribute11              IN VARCHAR2 DEFAULT NULL
            , X_attribute12              IN VARCHAR2 DEFAULT NULL
            , X_attribute13              IN VARCHAR2 DEFAULT NULL
            , X_attribute14              IN VARCHAR2 DEFAULT NULL
            , X_attribute15              IN VARCHAR2 DEFAULT NULL
            , X_msg_application      IN OUT NOCOPY VARCHAR2
            , X_msg_type                OUT NOCOPY VARCHAR2
            , X_msg_token1              OUT NOCOPY VARCHAR2
            , X_msg_token2              OUT NOCOPY VARCHAR2
            , X_msg_token3              OUT NOCOPY VARCHAR2
            , X_msg_count               OUT NOCOPY NUMBER
            , X_msg_data                OUT NOCOPY VARCHAR2
            , X_billable_flag           OUT NOCOPY VARCHAR2
            , p_projfunc_currency_code   IN VARCHAR2 default null
            , p_projfunc_cost_rate_type  IN VARCHAR2 default null
            , p_projfunc_cost_rate_date  IN DATE     default null
            , p_projfunc_cost_exchg_rate IN NUMBER   default null
            , p_assignment_id            IN NUMBER   default null
            , p_work_type_id             IN NUMBER   default null
	    , p_sys_link_function        IN VARCHAR2 default null
	    , P_Po_Header_Id             IN NUMBER   default null
	    , P_Po_Line_Id               IN NUMBER   default null
	    , P_Person_Type              IN VARCHAR2 default null
	    , P_Po_Price_Type            IN VARCHAR2 default null
	    , P_Document_Type            IN VARCHAR2 default null
	    , P_Document_Line_Type       IN VARCHAR2 default null
	    , P_Document_Dist_Type       IN VARCHAR2 default null
	    , P_pa_ref_num1              IN NUMBER   default null
	    , P_pa_ref_num2              IN NUMBER   default null
	    , P_pa_ref_num3              IN NUMBER   default null
	    , P_pa_ref_num4              IN NUMBER   default null
	    , P_pa_ref_num5              IN NUMBER   default null
	    , P_pa_ref_num6              IN NUMBER   default null
	    , P_pa_ref_num7              IN NUMBER   default null
	    , P_pa_ref_num8              IN NUMBER   default null
	    , P_pa_ref_num9              IN NUMBER   default null
	    , P_pa_ref_num10             IN NUMBER   default null
	    , P_pa_ref_var1              IN VARCHAR2 default null
	    , P_pa_ref_var2              IN VARCHAR2 default null
	    , P_pa_ref_var3              IN VARCHAR2 default null
	    , P_pa_ref_var4              IN VARCHAR2 default null
	    , P_pa_ref_var5              IN VARCHAR2 default null
	    , P_pa_ref_var6              IN VARCHAR2 default null
	    , P_pa_ref_var7              IN VARCHAR2 default null
	    , P_pa_ref_var8              IN VARCHAR2 default null
	    , P_pa_ref_var9              IN VARCHAR2 default null
	    , P_pa_ref_var10             IN VARCHAR2 default null) IS


	l_sys_link_function VARCHAR2(3) default NULL;	-- bug 2991182
    INVALID_TASK EXCEPTION; /*8574986*/
   BEGIN

      X_msg_count := 1;

      -- set default message type to Error.
      X_msg_type := 'E';


      -- set default message application to Oracle Projects
      X_msg_application := 'PA';

	/* Added for bug 2991182 */
	If (X_calling_module in ('APXINENT','apiindib.pls','apiimptb.pls','APXIIMPT')
	  and X_transaction_source is NOT NULL)
	Then
		l_sys_link_function := X_transaction_source;
         /* Added ElsIf for Bug#3155151 */
        ElsIf (X_calling_module IN ('PSPLDTRF','PAXVSSTS')) Then  /* OIT */  -- removed PAXVOTCB from if clause bug 3406396
               l_sys_link_function := nvl(p_sys_link_function, 'ST');  /* Added nvl() for Bug#3844346 */
        ElsIf (X_calling_module = 'SelfService') Then  /* OIE */
               l_sys_link_function := 'ER';
        ElsIf (X_calling_module in ('POXPOEPO','POXPOERL','POXRQERQ','POWEBREQ','REQIMPORT','IGCCENTR')) Then /*Bug 3428967,3581050*/ /* Added IGCCENTR for 6523746 */
               l_sys_link_function := 'VI';
	Else
		l_sys_link_function := p_sys_link_function;
	End If;
	/* bug 2991182 */
	/*Bug 8574986 begin*/

	PA_TRANSACTIONS_PUB.validate_task(X_project_id=>X_project_id
									, X_task_id=> X_task_id
									, X_msg_data=> X_msg_data
									, X_msg_type=> X_msg_type
									, X_msg_token1=>X_msg_token1
									, X_msg_count=> X_msg_count);




    If (x_msg_count>0) then
	RAISE INVALID_TASK;
	end if;

    /*Bug 8574986 end*/


      PATC.get_status(
		  X_project_id 			=> X_project_id
		, X_task_id 			=> X_task_id
                , X_ei_date 			=> X_ei_date
                , X_expenditure_type 		=> X_expenditure_type
                , X_non_labor_resource 		=> X_non_labor_resource
                , X_person_id 			=> X_person_id
                , X_quantity 			=> X_quantity
                , X_denom_currency_code 	=> X_denom_currency_code
                , X_acct_currency_code 		=> X_acct_currency_code
                , X_denom_raw_cost 		=> X_denom_raw_cost
                , X_acct_raw_cost 		=> X_acct_raw_cost
                , X_acct_rate_type 		=> X_acct_rate_type
                , X_acct_rate_date 		=> X_acct_rate_date
                , X_acct_exchange_rate 		=> X_acct_exchange_rate
                , X_transfer_ei 		=> X_transfer_ei
                , X_incurred_by_org_id 		=> X_incurred_by_org_id
                , X_nl_resource_org_id 		=> X_nl_resource_org_id
                , X_transaction_source 		=> X_transaction_source
                , X_calling_module 		=> X_calling_module
                , X_vendor_id 			=> X_vendor_id
                , X_entered_by_user_id 		=> X_entered_by_user_id
	        , X_attribute_category 		=> X_attribute_category
                , X_attribute1 			=> X_attribute1
                , X_attribute2 			=> X_attribute2
                , X_attribute3 			=> X_attribute3
                , X_attribute4 			=> X_attribute4
                , X_attribute5 			=> X_attribute5
                , X_attribute6 			=> X_attribute6
                , X_attribute7 			=> X_attribute7
                , X_attribute8 			=> X_attribute8
                , X_attribute9 			=> X_attribute9
                , X_attribute10 		=> X_attribute10
                , X_attribute11 		=> X_attribute11
                , X_attribute12 		=> X_attribute12
                , X_attribute13 		=> X_attribute13
                , X_attribute14 		=> X_attribute14
                , X_attribute15 		=> X_attribute15
                , X_msg_application 		=> X_msg_application
                , X_msg_type 			=> X_msg_type
                , X_msg_token1 			=> X_msg_token1
                , X_msg_token2 			=> X_msg_token2
                , X_msg_token3 			=> X_msg_token3
                , X_msg_count 			=> X_msg_count
                , X_status 			=> X_msg_data
	        , X_billable_flag 		=> X_billable_flag
                , p_projfunc_currency_code      => p_projfunc_currency_code
                , p_projfunc_cost_rate_type     => p_projfunc_cost_rate_type
                , p_projfunc_cost_rate_date     => p_projfunc_cost_rate_date
                , p_projfunc_cost_exchg_rate    => p_projfunc_cost_exchg_rate
                , p_assignment_id               => p_assignment_id
                , p_work_type_id                => p_work_type_id
		, p_sys_link_function           => l_sys_link_function
	        , P_Po_Header_Id                => P_Po_Header_Id
	        , P_Po_Line_Id                  => P_Po_Line_Id
	        , P_Person_Type                 => P_Person_Type
	        , P_Po_Price_Type               => P_Po_Price_Type  -- bug 2991182
	        , P_Document_Type               => P_Document_Type
	        , P_Document_Line_Type          => P_Document_Line_Type
	        , P_Document_Dist_Type          => P_Document_Dist_Type
	        , P_pa_ref_num1                 => P_pa_ref_num1
	        , P_pa_ref_num2                 => P_pa_ref_num2
	        , P_pa_ref_num3                 => P_pa_ref_num3
	        , P_pa_ref_num4                 => P_pa_ref_num4
	        , P_pa_ref_num5                 => P_pa_ref_num5
	        , P_pa_ref_num6                 => P_pa_ref_num6
	        , P_pa_ref_num7                 => P_pa_ref_num7
	        , P_pa_ref_num8                 => P_pa_ref_num8
	        , P_pa_ref_num9                 => P_pa_ref_num9
	        , P_pa_ref_num10                => P_pa_ref_num10
	        , P_pa_ref_var1                 => P_pa_ref_var1
	        , P_pa_ref_var2                 => P_pa_ref_var2
	        , P_pa_ref_var3                 => P_pa_ref_var3
	        , P_pa_ref_var4                 => P_pa_ref_var4
	        , P_pa_ref_var5                 => P_pa_ref_var5
	        , P_pa_ref_var6                 => P_pa_ref_var6
	        , P_pa_ref_var7                 => P_pa_ref_var7
	        , P_pa_ref_var8                 => P_pa_ref_var8
	        , P_pa_ref_var9                 => P_pa_ref_var9
	        , P_pa_ref_var10                => P_pa_ref_var10);

   EXCEPTION
   /*Bug 8574986 begin*/
    WHEN INVALID_TASK THEN
	null;
	/*Bug 8574986 end*/
   WHEN OTHERS THEN
      X_msg_data := SQLCODE;
      X_billable_flag := null;
   END validate_transaction;



--  =====================================================================
--  DFF Upgrade ---------------------------------------------------------

-- API: pop_dff_segments_enabled_table
-- Purpose: This procedure is called by validate_dff API to populate the
--          global variable G_dff_segments_enabled_table.
--          G_dff_segments_enabled_table is a variable which keeps track
--          of which context code has which segments enabled.  We are keeping
--          these information in a table in order to avoid calling ATG's
--          DFF API's extraneously.

   PROCEDURE pop_dff_segments_enabled_table IS
  		flex              fnd_dflex.dflex_r;
      flex_detail       fnd_dflex.dflex_dr;
      context_detail    fnd_dflex.contexts_dr;
      context           fnd_dflex.context_r;
      segment_detail    fnd_dflex.segments_dr;
      i NUMBER;
   BEGIN

   	-- Need to get flexfield token before getting context token
      fnd_dflex.get_flexfield('PA', 'PA_EXPENDITURE_ITEMS_DESC_FLEX', flex, flex_detail);

      -- Need to get context token before getting segment token
      fnd_dflex.get_contexts(flex, context_detail);

      context.flexfield := flex;
      i := 1;
      -- After getting the information for this descriptive flexfield, we will
      -- loop through each context codes to find out which segments are enabled
      -- for each context code
      WHILE i <= context_detail.ncontexts LOOP
      	IF context_detail.is_enabled(i) THEN
         	context.context_code := context_detail.context_code(i);
            fnd_dflex.get_segments(context, segment_detail);

				-- Store the context code
            G_dff_segments_enabled_table(i).context_code := context_detail.context_code(i);
            G_dff_segments_enabled_table(i).context_name := context_detail.context_name(i);

            -- Store whether this context code is GLOBAL context code or not
		      G_dff_segments_enabled_table(i).is_global    := context_detail.is_global(i);

				-- Call populate_segments to store the enabled segments for this context code
            populate_segments(
                     p_segment_detail              => segment_detail,
                     p_dff_segments_enabled_record => G_dff_segments_enabled_table(i));
          ELSE
              G_dff_segments_enabled_table(i).context_code := null;          -- Added for bug 1457298
          END IF;
          i := i + 1;
      END LOOP;
   END pop_dff_segments_enabled_table;


-- API: populate_segments
-- Purpose: This procedure is called by pop_dff_segments_enabled_table.
--          It is called once for each context code in the descriptive flexfield
--          definition.  For a particular context code, this API populate
--          one record of G_dff_segments_enabled_table table to store the enabled
--          segments of this context code

   PROCEDURE populate_segments (
   	p_segment_detail IN fnd_dflex.segments_dr,
/* Start of bug#  2672653 */
--      p_dff_segments_enabled_record IN OUT dff_segments_enabled_record) IS
        p_dff_segments_enabled_record IN OUT NOCOPY dff_segments_enabled_record) IS   /* added NOCOPY */
/* End of bug#  2672653 */
      counter      NUMBER;
   BEGIN
      counter := 1;

	   -- Loop through each segment of the context code to see what is the database
      -- table column name of this segment.  It must be ATTRIBUTE1-10.  If yes and the
      -- segment is enabled, it will set the attributex_enabled field of the
      -- G_dff_segments_enabled_table record to TRUE, otherwise to FALSE
      WHILE (counter <= p_segment_detail.nsegments) LOOP
      	IF p_segment_detail.application_column_name(counter) = 'ATTRIBUTE1' THEN
         	IF p_segment_detail.is_enabled(counter) THEN
            	p_dff_segments_enabled_record.attribute1_enabled := TRUE;
            ELSE
               p_dff_segments_enabled_record.attribute1_enabled := FALSE;
            END IF;
         ELSIF p_segment_detail.application_column_name(counter) = 'ATTRIBUTE2' THEN
            IF p_segment_detail.is_enabled(counter) THEN
               p_dff_segments_enabled_record.attribute2_enabled := TRUE;
            ELSE
               p_dff_segments_enabled_record.attribute2_enabled := FALSE;
            END IF;
         ELSIF p_segment_detail.application_column_name(counter) = 'ATTRIBUTE3' THEN
            IF p_segment_detail.is_enabled(counter) THEN
               p_dff_segments_enabled_record.attribute3_enabled := TRUE;
            ELSE
               p_dff_segments_enabled_record.attribute3_enabled := FALSE;
            END IF;
         ELSIF p_segment_detail.application_column_name(counter) = 'ATTRIBUTE4' THEN
            IF p_segment_detail.is_enabled(counter) THEN
               p_dff_segments_enabled_record.attribute4_enabled := TRUE;
            ELSE
               p_dff_segments_enabled_record.attribute4_enabled := FALSE;
            END IF;
         ELSIF p_segment_detail.application_column_name(counter) = 'ATTRIBUTE5' THEN
            IF p_segment_detail.is_enabled(counter) THEN
               p_dff_segments_enabled_record.attribute5_enabled := TRUE;
            ELSE
               p_dff_segments_enabled_record.attribute5_enabled := FALSE;
            END IF;
         ELSIF p_segment_detail.application_column_name(counter) = 'ATTRIBUTE6' THEN
            IF p_segment_detail.is_enabled(counter) THEN
               p_dff_segments_enabled_record.attribute6_enabled := TRUE;
            ELSE
               p_dff_segments_enabled_record.attribute6_enabled := FALSE;
            END IF;
         ELSIF p_segment_detail.application_column_name(counter) = 'ATTRIBUTE7' THEN
            IF p_segment_detail.is_enabled(counter) THEN
               p_dff_segments_enabled_record.attribute7_enabled := TRUE;
            ELSE
               p_dff_segments_enabled_record.attribute7_enabled := FALSE;
            END IF;
         ELSIF p_segment_detail.application_column_name(counter) = 'ATTRIBUTE8' THEN
            IF p_segment_detail.is_enabled(counter) THEN
               p_dff_segments_enabled_record.attribute8_enabled := TRUE;
            ELSE
               p_dff_segments_enabled_record.attribute8_enabled := FALSE;
            END IF;
         ELSIF p_segment_detail.application_column_name(counter) = 'ATTRIBUTE9' THEN
            IF p_segment_detail.is_enabled(counter) THEN
               p_dff_segments_enabled_record.attribute9_enabled := TRUE;
            ELSE
               p_dff_segments_enabled_record.attribute9_enabled := FALSE;
            END IF;
         ELSIF p_segment_detail.application_column_name(counter) = 'ATTRIBUTE10' THEN
            IF p_segment_detail.is_enabled(counter) THEN
               p_dff_segments_enabled_record.attribute10_enabled := TRUE;
            ELSE
               p_dff_segments_enabled_record.attribute10_enabled := FALSE;
            END IF;
         END IF;
         counter := counter + 1;
      END LOOP;
   END populate_segments;


-- API: validate_dff
-- Purpose: This is the main API for validating DFF.  Given all ten segment fields,
--          this API will validate them against descriptive flexfield definition.
--          Underneath, the real validation is done by API's provided by ATG.
--          Once passed validation, this API also makes sure only the enabled segments
--          are passed back through the IN/OUT p_attributex parameters
   PROCEDURE validate_dff (
         p_dff_name        IN fnd_descriptive_flexs_vl.descriptive_flexfield_name%TYPE,
         p_attribute_category IN pa_expenditure_items_all.attribute_category%TYPE,
         p_attribute1      IN OUT NOCOPY pa_expenditure_items_all.attribute1%TYPE,
         p_attribute2      IN OUT NOCOPY pa_expenditure_items_all.attribute2%TYPE,
         p_attribute3      IN OUT NOCOPY pa_expenditure_items_all.attribute3%TYPE,
         p_attribute4      IN OUT NOCOPY pa_expenditure_items_all.attribute4%TYPE,
         p_attribute5      IN OUT NOCOPY pa_expenditure_items_all.attribute5%TYPE,
         p_attribute6      IN OUT NOCOPY pa_expenditure_items_all.attribute6%TYPE,
         p_attribute7      IN OUT NOCOPY pa_expenditure_items_all.attribute7%TYPE,
         p_attribute8      IN OUT NOCOPY pa_expenditure_items_all.attribute8%TYPE,
         p_attribute9      IN OUT NOCOPY pa_expenditure_items_all.attribute9%TYPE,
         p_attribute10     IN OUT NOCOPY pa_expenditure_items_all.attribute10%TYPE,
         x_status_code     OUT NOCOPY VARCHAR2,
		   x_error_message   OUT NOCOPY VARCHAR2)

   IS
         v_attribute1      pa_expenditure_items_all.attribute1%TYPE;
         v_attribute2      pa_expenditure_items_all.attribute2%TYPE;
         v_attribute3      pa_expenditure_items_all.attribute3%TYPE;
         v_attribute4      pa_expenditure_items_all.attribute4%TYPE;
         v_attribute5      pa_expenditure_items_all.attribute5%TYPE;
         v_attribute6      pa_expenditure_items_all.attribute6%TYPE;
         v_attribute7      pa_expenditure_items_all.attribute7%TYPE;
         v_attribute8      pa_expenditure_items_all.attribute8%TYPE;
         v_attribute9      pa_expenditure_items_all.attribute9%TYPE;
         v_attribute10     pa_expenditure_items_all.attribute10%TYPE;
         v_desc_flex_context_name fnd_descriptive_flexs_vl.descriptive_flexfield_name%TYPE;
         i                 NUMBER;
	/* Start of Bug 3064318 */
	TYPE seg_col_name is TABLE of varchar2(150)
	Index by binary_integer;

	p_segment_column_name   seg_col_name;
	l_attribute             seg_col_name;
        j                 	NUMBER;
	/* End of Bug 3064318 */

-- API:  populate_v_attributes
-- Purpose: This procedure is part of the body of populate_dff.  It is called by
--          validate_dff to check against the global table G_dff_segments_enabled_table
--          to see, for the given context code, what segments are enabled.  If
--          a segment is enabled for this context code, it will then populate the
--          v_attributex variable with the IN/OUT parameter p_attributex.  If the segment
--          is not enabled, then v_attributex will be left as NULL.  This is the API
--          which filters out all the extra attributes the user has passed in for segments
--          which are not enabled. v_attributex variables are later used in the DFF validation
--          process

			PROCEDURE populate_v_attributes IS
				c			NUMBER;
			BEGIN
				c := 1;
            -- Loop through each record of the G_dff_segments_enabled_table table.
            -- Check the attribute_category passed in as parameter against the context code
            -- of each record.  If equals, then we have found the record we want to retrieve.
            -- We also always retrive the 'Global Data Elements' context code because it stores
            -- the global segments
				WHILE c <= G_dff_segments_enabled_table.count LOOP
					IF (G_dff_segments_enabled_table(c).is_global OR
						 G_dff_segments_enabled_table(c).context_code = p_attribute_category) THEN
                  IF (G_dff_segments_enabled_table(c).context_code =
                                                   p_attribute_category) THEN
/* Commented for Bug # 1982950 -- gjain
                     v_desc_flex_context_name :=
                                 G_dff_segments_enabled_table(c).context_name;
*/
                     v_desc_flex_context_name :=
                                 G_dff_segments_enabled_table(c).context_code;
                  END IF;

						IF G_dff_segments_enabled_table(c).attribute1_enabled THEN
							v_attribute1 := p_attribute1;
						END IF;
                  IF G_dff_segments_enabled_table(c).attribute2_enabled THEN
                     v_attribute2 := p_attribute2;
                  END IF;
                  IF G_dff_segments_enabled_table(c).attribute3_enabled THEN
                     v_attribute3 := p_attribute3;
                  END IF;
                  IF G_dff_segments_enabled_table(c).attribute4_enabled THEN
                     v_attribute4 := p_attribute4;
                  END IF;
                  IF G_dff_segments_enabled_table(c).attribute5_enabled THEN
                     v_attribute5 := p_attribute5;
                  END IF;
                  IF G_dff_segments_enabled_table(c).attribute6_enabled THEN
                     v_attribute6 := p_attribute6;
                  END IF;
                  IF G_dff_segments_enabled_table(c).attribute7_enabled THEN
                     v_attribute7 := p_attribute7;
                  END IF;
                  IF G_dff_segments_enabled_table(c).attribute8_enabled THEN
                     v_attribute8 := p_attribute8;
                  END IF;
                  IF G_dff_segments_enabled_table(c).attribute9_enabled THEN
                     v_attribute9 := p_attribute9;
                  END IF;
                  IF G_dff_segments_enabled_table(c).attribute10_enabled THEN
                     v_attribute10 := p_attribute10;
                  END IF;
					END IF;
					c := c + 1;
				END LOOP;
			END populate_v_attributes;

   -- Validate_dff logic begins
   BEGIN
		   x_error_message := NULL;
         x_status_code := NULL;
         v_attribute1 := NULL;
         v_attribute2 := NULL;
         v_attribute3 := NULL;
         v_attribute4 := NULL;
         v_attribute5 := NULL;
         v_attribute6 := NULL;
         v_attribute7 := NULL;
         v_attribute8 := NULL;
         v_attribute9 := NULL;
         v_attribute10 := NULL;
			i            := 1;

			--Initialize G_dff_segments_enabled_table if it hasn't been initialized
			IF (G_dff_segments_enabled_table.count = 0) THEN
				pop_dff_segments_enabled_table();
			END IF;

			-- Populate the v_attributex variables to get ready to do validation
			populate_v_attributes();

			-- Validate the DFF
         fnd_flex_descval.set_context_value(v_desc_flex_context_name);
         fnd_flex_descval.set_column_value('ATTRIBUTE1', v_attribute1);
         fnd_flex_descval.set_column_value('ATTRIBUTE2', v_attribute2);
         fnd_flex_descval.set_column_value('ATTRIBUTE3', v_attribute3);
         fnd_flex_descval.set_column_value('ATTRIBUTE4', v_attribute4);
         fnd_flex_descval.set_column_value('ATTRIBUTE5', v_attribute5);
         fnd_flex_descval.set_column_value('ATTRIBUTE6', v_attribute6);
         fnd_flex_descval.set_column_value('ATTRIBUTE7', v_attribute7);
         fnd_flex_descval.set_column_value('ATTRIBUTE8', v_attribute8);
         fnd_flex_descval.set_column_value('ATTRIBUTE9', v_attribute9);
         fnd_flex_descval.set_column_value('ATTRIBUTE10', v_attribute10);

                /* Start of Bug 3064318 */
         IF (FND_FLEX_DESCVAL.validate_desccols('PA', 'PA_EXPENDITURE_ITEMS_DESC_FLEX', 'D', sysdate)) THEN

        for j in 1 ..10 Loop
                p_segment_column_name(j) := ltrim(rtrim(FND_FLEX_DESCVAL.segment_column_name(j)));
                l_attribute(j)           := rtrim(FND_FLEX_DESCVAL.segment_id(j));  --Bug#6506638: Removed ltrim()

                If p_segment_column_name(j) = 'ATTRIBUTE1' Then
                        p_attribute1 := l_attribute(j);
                ElsIf p_segment_column_name(j) = 'ATTRIBUTE2' Then
                        p_attribute2 := l_attribute(j);
                ElsIf p_segment_column_name(j) = 'ATTRIBUTE3' Then
                        p_attribute3 := l_attribute(j);
                ElsIf p_segment_column_name(j) = 'ATTRIBUTE4' Then
                        p_attribute4 := l_attribute(j);
                ElsIf p_segment_column_name(j) = 'ATTRIBUTE5' Then
                        p_attribute5 := l_attribute(j);
                ElsIf p_segment_column_name(j) = 'ATTRIBUTE6' Then
                        p_attribute6 := l_attribute(j);
                ElsIf p_segment_column_name(j) = 'ATTRIBUTE7' Then
                        p_attribute7 := l_attribute(j);
                ElsIf p_segment_column_name(j) = 'ATTRIBUTE8' Then
                        p_attribute8 := l_attribute(j);
                ElsIf p_segment_column_name(j) = 'ATTRIBUTE9' Then
                        p_attribute9 := l_attribute(j);
                ElsIf p_segment_column_name(j) = 'ATTRIBUTE10' Then
                        p_attribute10 := l_attribute(j);
                End If;
        End Loop;

	    /* p_attribute1 := v_attribute1;
               p_attribute2 := v_attribute2;
               p_attribute3 := v_attribute3;
               p_attribute4 := v_attribute4;
               p_attribute5 := v_attribute5;
               p_attribute6 := v_attribute6;
               p_attribute7 := v_attribute7;
               p_attribute8 := v_attribute8;
               p_attribute9 := v_attribute9;
               p_attribute10 := v_attribute10;  Commented for Bug 3064318 */
	/* End of Bug 3064318 */
	ELSE
		  X_error_message := FND_FLEX_DESCVAL.error_message;
              X_status_code := 'PA_DFF_VALIDATION_FAILED';
              RAISE INVALID_DATA;
         END IF;

	EXCEPTION
   WHEN  INVALID_DATA  THEN
      null;
   WHEN OTHERS THEN
      raise;

   END validate_dff;

----------------------------------------------------------------------
-- Please refer to package spec for detailed description of the
-- procedure.
----------------------------------------------------------------------

PROCEDURE Check_Adjustment_of_Proj_Txn(
                             x_transaction_source                   IN VARCHAR2,
                             x_orig_transaction_reference           IN VARCHAR2,
                             x_expenditure_type_class               IN VARCHAR2,
                             x_expenditure_type                     IN VARCHAR2,
                             x_expenditure_item_id                  IN NUMBER DEFAULT NULL,
                             x_expenditure_item_date                IN DATE,
                             x_employee_number                      IN VARCHAR2 DEFAULT NULL,
                             x_expenditure_org_name                 IN VARCHAR2 DEFAULT NULL,
                             x_project_number                       IN VARCHAR2,
                             x_task_number                          IN VARCHAR2,
                             x_non_labor_resource                   IN VARCHAR2 DEFAULT NULL,
                             x_non_labor_resource_org_name          IN VARCHAR2 DEFAULT NULL,
                             x_quantity                             IN NUMBER,
                             x_raw_cost                             IN NUMBER DEFAULT NULL,
                             x_attribute_category                   IN VARCHAR2 DEFAULT NULL,
                             x_attribute1                           IN VARCHAR2 DEFAULT NULL,
                             x_attribute2                           IN VARCHAR2 DEFAULT NULL,
                             x_attribute3                           IN VARCHAR2 DEFAULT NULL,
                             x_attribute4                           IN VARCHAR2 DEFAULT NULL,
                             x_attribute5                           IN VARCHAR2 DEFAULT NULL,
                             x_attribute6                           IN VARCHAR2 DEFAULT NULL,
                             x_attribute7                           IN VARCHAR2 DEFAULT NULL,
                             x_attribute8                           IN VARCHAR2 DEFAULT NULL,
                             x_attribute9                           IN VARCHAR2 DEFAULT NULL,
                             x_attribute10                          IN VARCHAR2 DEFAULT NULL,
                             x_org_id                               IN NUMBER DEFAULT NULL,
                             x_adjustment_status                    OUT NOCOPY VARCHAR2,
                             x_adjustment_status_code               OUT NOCOPY VARCHAR2,
                             x_return_status                        OUT NOCOPY VARCHAR2,
                             x_message_data                         OUT NOCOPY VARCHAR2)
IS

--The following Cursor will select the item in Projects based upon the parameters passed
--to the API.  It is a UNION because
-- 1) pa_expenditure_items_all.non_labor_resource and pa_expenditure_items_all.organization_id
--    (non labor resource owning organization) only exist for Usages (expenditure_type_class = 'USG')
-- 2) pa_expenditures_all.incurred_by_person_id may or may not exist for Usages, and
--    does not exist for Supplier Invoices.

CURSOR item_in_projects IS
--The first part of the UNION handles all expenditure_type_classes EXCEPT
--Usages (USG) and Supplier Invoices (VI).
SELECT net_zero_adjustment_flag
FROM   pa_expenditure_items_all ei,
       pa_expenditures_all exp,
       per_all_people_f per,
       pa_projects_all proj,
       pa_tasks task,
       hr_all_organization_units hr1
WHERE  ei.transaction_source = x_transaction_source AND
       ei.orig_transaction_reference = x_orig_transaction_reference AND
       ei.system_linkage_function = x_expenditure_type_class AND
       ei.expenditure_type = x_expenditure_type AND
       ei.expenditure_item_id = nvl(x_expenditure_item_id, ei.expenditure_item_id) AND
       ei.expenditure_item_date = x_expenditure_item_date AND
       NVL(per.employee_number,per.npw_number) = nvl(x_employee_number, nvl(per.employee_number,per.npw_number) ) AND /* FP.M / CWK Changes */
       ei.expenditure_item_date BETWEEN per.effective_start_date AND per.effective_end_date AND
       per.person_id = exp.incurred_by_person_id AND
       exp.expenditure_id = ei.expenditure_id AND
       hr1.name = nvl(x_expenditure_org_name,hr1.name) AND
       hr1.organization_id = exp.incurred_by_organization_id AND
       proj.segment1 = x_project_number AND
       task.project_id = proj.project_id AND
       task.task_number = x_task_number AND
       ei.task_id = task.task_id AND
       ei.quantity = x_quantity AND
       nvl(ei.raw_cost,'-99') = nvl(x_raw_cost,nvl(ei.raw_cost,'-99')) AND
       nvl(ei.attribute_category,'-99') = nvl(x_attribute_category,nvl(ei.attribute_category,'-99')) AND
       nvl(ei.attribute1,'-99') = nvl(x_attribute1, nvl(ei.attribute1,'-99')) AND
       nvl(ei.attribute2,'-99') = nvl(x_attribute2, nvl(ei.attribute2,'-99')) AND
       nvl(ei.attribute3,'-99') = nvl(x_attribute3, nvl(ei.attribute3,'-99')) AND
       nvl(ei.attribute4,'-99') = nvl(x_attribute4, nvl(ei.attribute4,'-99')) AND
       nvl(ei.attribute5,'-99') = nvl(x_attribute5, nvl(ei.attribute5,'-99')) AND
       nvl(ei.attribute6,'-99') = nvl(x_attribute6, nvl(ei.attribute6,'-99')) AND
       nvl(ei.attribute7,'-99') = nvl(x_attribute7, nvl(ei.attribute7,'-99')) AND
       nvl(ei.attribute8,'-99') = nvl(x_attribute8, nvl(ei.attribute8,'-99')) AND
       nvl(ei.attribute9,'-99') = nvl(x_attribute9, nvl(ei.attribute9,'-99')) AND
       nvl(ei.attribute10,'-99') = nvl(x_attribute10, nvl(ei.attribute10,'-99')) AND
       nvl(ei.org_id,'-99') = nvl(x_org_id,nvl(ei.org_id,'-99')) AND
       x_expenditure_type_class <> 'USG' AND
       x_expenditure_type_class <> 'VI'
UNION ALL
--The second part of the UNION handles Usages (expenditure_type_class='USG')
--when IN parameter x_employee_number is NOT NULL.  The additional join to
--hr_all_organization_units hr2 is required.
SELECT net_zero_adjustment_flag
FROM   pa_expenditure_items_all ei,
       pa_expenditures_all exp,
       per_all_people_f per,
       pa_projects_all proj,
       pa_tasks task,
       hr_all_organization_units hr1,
       hr_all_organization_units hr2
WHERE  ei.transaction_source = x_transaction_source AND
       ei.orig_transaction_reference = x_orig_transaction_reference AND
       ei.system_linkage_function = x_expenditure_type_class AND
       ei.expenditure_type = x_expenditure_type AND
       ei.expenditure_item_id = nvl(x_expenditure_item_id, ei.expenditure_item_id) AND
       ei.expenditure_item_date = x_expenditure_item_date AND
       nvl(per.employee_number,per.npw_number) = x_employee_number AND /* FP.M / CWK Changes */
       ei.expenditure_item_date BETWEEN per.effective_start_date AND per.effective_end_date AND
       per.person_id = exp.incurred_by_person_id AND
       exp.expenditure_id = ei.expenditure_id AND
       hr1.name = nvl(x_expenditure_org_name,hr1.name) AND
       hr1.organization_id = exp.incurred_by_organization_id AND
       proj.segment1 = x_project_number AND
       task.project_id = proj.project_id AND
       task.task_number = x_task_number AND
       ei.task_id = task.task_id AND
       nvl(ei.non_labor_resource,'-99') = nvl(x_non_labor_resource,nvl(ei.non_labor_resource,'-99')) AND
       hr2.name = nvl(x_non_labor_resource_org_name,hr2.name) AND
       hr2.organization_id = ei.organization_id AND
       ei.quantity = x_quantity AND
       nvl(ei.raw_cost,'-99') = nvl(x_raw_cost,nvl(ei.raw_cost,'-99')) AND
       nvl(ei.attribute_category,'-99') = nvl(x_attribute_category,nvl(ei.attribute_category,'-99')) AND
       nvl(ei.attribute1,'-99') = nvl(x_attribute1, nvl(ei.attribute1,'-99')) AND
       nvl(ei.attribute2,'-99') = nvl(x_attribute2, nvl(ei.attribute2,'-99')) AND
       nvl(ei.attribute3,'-99') = nvl(x_attribute3, nvl(ei.attribute3,'-99')) AND
       nvl(ei.attribute4,'-99') = nvl(x_attribute4, nvl(ei.attribute4,'-99')) AND
       nvl(ei.attribute5,'-99') = nvl(x_attribute5, nvl(ei.attribute5,'-99')) AND
       nvl(ei.attribute6,'-99') = nvl(x_attribute6, nvl(ei.attribute6,'-99')) AND
       nvl(ei.attribute7,'-99') = nvl(x_attribute7, nvl(ei.attribute7,'-99')) AND
       nvl(ei.attribute8,'-99') = nvl(x_attribute8, nvl(ei.attribute8,'-99')) AND
       nvl(ei.attribute9,'-99') = nvl(x_attribute9, nvl(ei.attribute9,'-99')) AND
       nvl(ei.attribute10,'-99') = nvl(x_attribute10, nvl(ei.attribute10,'-99')) AND
       nvl(ei.org_id,'-99') = nvl(x_org_id,nvl(ei.org_id,'-99')) AND
       x_expenditure_type_class = 'USG' AND
       x_employee_number IS NOT NULL
UNION ALL
--The third part of the UNION handles Usages (expenditure_type_class='USG')
--when IN PARAMETER x_exployee_number IS NULL.  The additional join to
--hr_all_organization_units hr2 is required and the join to per_all_people_f is not required.
SELECT net_zero_adjustment_flag
FROM   pa_expenditure_items_all ei,
       pa_expenditures_all exp,
       pa_projects_all proj,
       pa_tasks task,
       hr_all_organization_units hr1,
       hr_all_organization_units hr2
WHERE  ei.transaction_source = x_transaction_source AND
       ei.orig_transaction_reference = x_orig_transaction_reference AND
       ei.system_linkage_function = x_expenditure_type_class AND
       ei.expenditure_type = x_expenditure_type AND
       ei.expenditure_item_id = nvl(x_expenditure_item_id, ei.expenditure_item_id) AND
       ei.expenditure_item_date = x_expenditure_item_date AND
       exp.expenditure_id = ei.expenditure_id AND
       hr1.name = nvl(x_expenditure_org_name,hr1.name) AND
       hr1.organization_id = exp.incurred_by_organization_id AND
       proj.segment1 = x_project_number AND
       task.project_id = proj.project_id AND
       task.task_number = x_task_number AND
       ei.task_id = task.task_id AND
       nvl(ei.non_labor_resource,'-99') = nvl(x_non_labor_resource,nvl(ei.non_labor_resource,'-99')) AND
       hr2.name = nvl(x_non_labor_resource_org_name,hr2.name) AND
       hr2.organization_id = ei.organization_id AND
       ei.quantity = x_quantity AND
       nvl(ei.raw_cost,'-99') = nvl(x_raw_cost,nvl(ei.raw_cost,'-99')) AND
       nvl(ei.attribute_category,'-99') = nvl(x_attribute_category,nvl(ei.attribute_category,'-99')) AND
       nvl(ei.attribute1,'-99') = nvl(x_attribute1, nvl(ei.attribute1,'-99')) AND
       nvl(ei.attribute2,'-99') = nvl(x_attribute2, nvl(ei.attribute2,'-99')) AND
       nvl(ei.attribute3,'-99') = nvl(x_attribute3, nvl(ei.attribute3,'-99')) AND
       nvl(ei.attribute4,'-99') = nvl(x_attribute4, nvl(ei.attribute4,'-99')) AND
       nvl(ei.attribute5,'-99') = nvl(x_attribute5, nvl(ei.attribute5,'-99')) AND
       nvl(ei.attribute6,'-99') = nvl(x_attribute6, nvl(ei.attribute6,'-99')) AND
       nvl(ei.attribute7,'-99') = nvl(x_attribute7, nvl(ei.attribute7,'-99')) AND
       nvl(ei.attribute8,'-99') = nvl(x_attribute8, nvl(ei.attribute8,'-99')) AND
       nvl(ei.attribute9,'-99') = nvl(x_attribute9, nvl(ei.attribute9,'-99')) AND
       nvl(ei.attribute10,'-99') = nvl(x_attribute10, nvl(ei.attribute10,'-99')) AND
       nvl(ei.org_id,'-99') = nvl(x_org_id,nvl(ei.org_id,'-99')) AND
       x_expenditure_type_class = 'USG' AND
       x_employee_number IS NULL
UNION ALL
--The fourth part of the UNION handles Supplier Invoices (expenditure_type_class='VI').
--The join to per_all_people_f is not required as pa_expenditures_all.incurred_by_person_id
--is NULL for Supplier Invoices.
SELECT net_zero_adjustment_flag
FROM   pa_expenditure_items_all ei,
       pa_expenditures_all exp,
       pa_projects_all proj,
       pa_tasks task,
       hr_all_organization_units hr1
WHERE  ei.transaction_source = x_transaction_source AND
       ei.orig_transaction_reference = x_orig_transaction_reference AND
       ei.system_linkage_function = x_expenditure_type_class AND
       ei.expenditure_type = x_expenditure_type AND
       ei.expenditure_item_id = nvl(x_expenditure_item_id, ei.expenditure_item_id) AND
       ei.expenditure_item_date = x_expenditure_item_date AND
       exp.expenditure_id = ei.expenditure_id AND
       hr1.name = nvl(x_expenditure_org_name,hr1.name) AND
       hr1.organization_id = ei.override_to_organization_id AND
       proj.segment1 = x_project_number AND
       task.project_id = proj.project_id AND
       task.task_number = x_task_number AND
       ei.task_id = task.task_id AND
       ei.quantity = x_quantity AND
       nvl(ei.raw_cost,'-99') = nvl(x_raw_cost,nvl(ei.raw_cost,'-99')) AND
       nvl(ei.attribute_category,'-99') = nvl(x_attribute_category,nvl(ei.attribute_category,'-99')) AND
       nvl(ei.attribute1,'-99') = nvl(x_attribute1, nvl(ei.attribute1,'-99')) AND
       nvl(ei.attribute2,'-99') = nvl(x_attribute2, nvl(ei.attribute2,'-99')) AND
       nvl(ei.attribute3,'-99') = nvl(x_attribute3, nvl(ei.attribute3,'-99')) AND
       nvl(ei.attribute4,'-99') = nvl(x_attribute4, nvl(ei.attribute4,'-99')) AND
       nvl(ei.attribute5,'-99') = nvl(x_attribute5, nvl(ei.attribute5,'-99')) AND
       nvl(ei.attribute6,'-99') = nvl(x_attribute6, nvl(ei.attribute6,'-99')) AND
       nvl(ei.attribute7,'-99') = nvl(x_attribute7, nvl(ei.attribute7,'-99')) AND
       nvl(ei.attribute8,'-99') = nvl(x_attribute8, nvl(ei.attribute8,'-99')) AND
       nvl(ei.attribute9,'-99') = nvl(x_attribute9, nvl(ei.attribute9,'-99')) AND
       nvl(ei.attribute10,'-99') = nvl(x_attribute10, nvl(ei.attribute10,'-99')) AND
       nvl(ei.org_id,'-99') = nvl(x_org_id,nvl(ei.org_id,'-99')) AND
       x_expenditure_type_class = 'VI';

--The following Cursor selects the meaning for the adjustment_status_code
--from pa_lookups.

CURSOR adjustment_status_meaning IS
SELECT meaning
FROM   pa_lookups
WHERE  lookup_type = 'PA_ADJUSTMENT_STATUS'
AND    lookup_code = x_adjustment_status_code;

l_net_zero_adjustment_flag     pa_expenditure_items_all.net_zero_adjustment_flag%TYPE;
e_no_unique_transaction        exception;


BEGIN

OPEN item_in_projects;

LOOP

     FETCH item_in_projects INTO l_net_zero_adjustment_flag;

     --If no rows are selected by the cursor then the item cannot be found in Projects.

     IF item_in_projects%ROWCOUNT = 0 THEN

          x_adjustment_status_code := 'NF';

          x_return_status := 'S';

          OPEN adjustment_status_meaning;

          FETCH adjustment_status_meaning INTO x_adjustment_status;

          CLOSE adjustment_status_meaning;

          RETURN;

      END IF;

      --Exit the loop when there are no more records in the cursor.

      EXIT WHEN item_in_projects%NOTFOUND;

      --If more than one record in the cursor then the transaction was not
      --uniquely identified in Projects based on the parameters passed to the API.

      IF item_in_projects%ROWCOUNT > 1 THEN

           RAISE e_no_unique_transaction;

      END IF;

      --If the net_zero_adjustment_flag of the item in Projects = 'Y' then
      --the item has been adjusted in Projects.

      IF (l_net_zero_adjustment_flag = 'Y') THEN

           x_adjustment_status_code := 'A';

           x_return_status := 'S';

           OPEN adjustment_status_meaning;

           FETCH adjustment_status_meaning INTO x_adjustment_status;

           CLOSE adjustment_status_meaning;

      END IF;

      --If the net_zero_adjustment_flag of the item in Projects = 'N' or NULL then
      --the item has not been adjusted in Projects.

      IF (nvl(l_net_zero_adjustment_flag,'N') = 'N') THEN

           x_adjustment_status_code := 'NA';

           x_return_status := 'S';

           OPEN adjustment_status_meaning;

           FETCH adjustment_status_meaning INTO x_adjustment_status;

           CLOSE adjustment_status_meaning;

      END IF;

END LOOP;

EXCEPTION

     WHEN e_no_unique_transaction THEN

          x_adjustment_status := NULL;

          x_adjustment_status_code := NULL;

          x_return_status := 'E';

          FND_MSG_PUB.initialize;

          FND_MESSAGE.SET_NAME('PA','PA_NO_UNIQUE_TRANSACTION');

          x_message_data := FND_MESSAGE.GET;

     WHEN others THEN

          x_adjustment_status := NULL;

          x_adjustment_status_code := NULL;

          x_return_status := 'U';

          x_message_data := substrb(SQLERRM,1,2000);

END Check_Adjustment_of_Proj_Txn;


PROCEDURE Allow_Adjustment_Extn(
                             p_transaction_source                   IN  VARCHAR2,
                             p_allow_adjustment_flag                IN  VARCHAR2,
                             p_orig_transaction_reference           IN  VARCHAR2,
                             p_expenditure_type_class               IN  VARCHAR2,
                             p_expenditure_type                     IN  VARCHAR2,
                             p_expenditure_item_id                  IN  NUMBER,
                             p_expenditure_item_date                IN  DATE,
                             p_employee_number                      IN  VARCHAR2,
                             p_expenditure_org_name                 IN  VARCHAR2,
                             p_project_number                       IN  VARCHAR2,
                             p_task_number                          IN  VARCHAR2,
                             p_non_labor_resource                   IN  VARCHAR2,
                             p_non_labor_resource_org_name          IN  VARCHAR2,
                             p_quantity                             IN  NUMBER,
                             p_raw_cost                             IN  NUMBER,
                             p_attribute_category                   IN  VARCHAR2,
                             p_attribute1                           IN  VARCHAR2,
                             p_attribute2                           IN  VARCHAR2,
                             p_attribute3                           IN  VARCHAR2,
                             p_attribute4                           IN  VARCHAR2,
                             p_attribute5                           IN  VARCHAR2,
                             p_attribute6                           IN  VARCHAR2,
                             p_attribute7                           IN  VARCHAR2,
                             p_attribute8                           IN  VARCHAR2,
                             p_attribute9                           IN  VARCHAR2,
                             p_attribute10                          IN  VARCHAR2,
                             p_org_id                               IN  NUMBER,
                             x_allow_adjustment_code                OUT NOCOPY VARCHAR2,
                             x_return_status                        OUT NOCOPY VARCHAR2,
                             x_application_code                     OUT NOCOPY VARCHAR2,
                             x_message_code                         OUT NOCOPY VARCHAR2,
                             x_token_name1                          OUT NOCOPY VARCHAR2,
                             x_token_val1                           OUT NOCOPY VARCHAR2,
                             x_token_name2                          OUT NOCOPY VARCHAR2,
                             x_token_val2                           OUT NOCOPY VARCHAR2,
                             x_token_name3                          OUT NOCOPY VARCHAR2,
                             x_token_val3                           OUT NOCOPY VARCHAR2)

IS

BEGIN

--The default logic of this client extension will return the
--pa_transaction_sources.allow_adjustment_flag for p_transaction_source.

x_allow_adjustment_code := p_allow_adjustment_flag;

x_return_status := 'S';


EXCEPTION

     WHEN others THEN

          x_return_status := 'U';

          x_message_code := to_char(SQLCODE);

END Allow_Adjustment_Extn;


/*Bug 8574986 begin*/

PROCEDURE validate_task(
              X_project_id             IN NUMBER
            , X_task_id                IN NUMBER
            , X_msg_type               OUT NOCOPY VARCHAR2
			, X_msg_token1             OUT NOCOPY VARCHAR2
			, X_msg_count              OUT NOCOPY NUMBER
            , X_msg_data               OUT NOCOPY VARCHAR2
            ) IS

INVALID_DATA	EXCEPTION;
l_cm_subt_count number ;


BEGIN
X_msg_count:=0;

select count(*)
into l_cm_subt_count
from pa_proj_elements ppe
where ppe.proj_element_id= X_task_id
and ppe.project_id=X_project_id
/*and link_task_flag='Y'*/ /*bug 8916805*/ /*commented for bug 8996313*/
and exists (select por.* from /*modified logic for bug 8996313*/
pa_proj_element_versions ppev,
pa_proj_element_versions ppev1,
pa_proj_elements ppe1,
pa_object_relationships por
where
ppev.element_version_id = por.object_id_from1
and  ppev.proj_element_id =ppe.proj_element_id
and ppev1.element_version_id = por.object_id_to1
and ppe1.proj_element_id = ppev1.proj_element_id
and ppe1.link_task_flag = 'Y'
and ppe1.task_status is not null /*Bug 8916805*/
and por.relationship_type = 'S'
and ppev.financial_task_flag = 'Y'
and por.object_type_from='PA_TASKS')
and not exists (select 1 from pa_tasks where parent_task_id=X_task_id);

 IF (nvl(l_cm_subt_count,0)>0) Then
	    X_msg_data :='PA_CM_SUB_TASK';
		select task_number into  X_msg_token1 from pa_tasks where task_id=X_task_id;

		raise INVALID_DATA;
 END IF;

EXCEPTION
	WHEN INVALID_DATA THEN
	X_msg_count:= X_msg_count+1;
	X_msg_type:='E';
	WHEN OTHERS THEN
	X_msg_data :=SQLERRM;
	X_msg_count:= X_msg_count+1;
	X_msg_type:='E';
END validate_task;

/*Bug 8574986 end*/


END  PA_TRANSACTIONS_PUB;

/
