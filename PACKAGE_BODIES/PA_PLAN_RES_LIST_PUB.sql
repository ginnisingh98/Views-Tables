--------------------------------------------------------
--  DDL for Package Body PA_PLAN_RES_LIST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PLAN_RES_LIST_PUB" AS
/* $Header: PARESLPB.pls 120.3 2006/09/06 23:51:09 ramurthy noship $*/


/*******************************************************************************************
 * API Name: Convert_Missing_List_In_Rec
 * Public/Private     : Private
 * Procedure/Function : Procedure
 * Description:
 *     This procedure converts the input values to null if its a G_MISS_VALUE
 *      and selects the value from the database if the value being input is
 *      null, so that there wouldn't be any change to the data when null is passed
 *      as input.
 *      The conversions are done for the Plan_Res_List_IN_Rec.
 *  Attributes        :
 *     INPUT VALUES :
 *           P_Plan_res_list_Rec       : The record which hold's the resource list details.
 *                                       This contains the input record.
 *           P_Mode                    : The mode in which this procedure is called.
 *                                       It can be called in either Update or create mode
 *                                       1 means update. 0 means create.
 *     OUTPUT VALUES :
 *
 *          X_Plan_res_list_Rec        : The record which hold's the resource list details with the
 *                                       changed values to the fields of the record.
 *          X_Error_Msg                : The parameter will hold a message if there is an
 *                                       error in this API.
 * There can be two modes in which this procedure can be called
 * Update and create
 * P_Mode = 1 means update
 * P_Mode = 0 means create
 * In Update
 * if Update then Resource list id can be present.
 * if Resource lsit id is not present then resource list name would be present .
 * You can retreive the  Resource list id from the resource list name.
 * And then convert all GMISS to the database values.
 *
 * In create mode the Resource list name would be present
 * Convert all missing values to null.
 *
 *
 *******************************************************************************************/
PROCEDURE Convert_Missing_List_IN_Rec
(P_Plan_res_list_Rec IN 	Plan_Res_List_IN_Rec,
 X_Plan_res_list_Rec OUT NOCOPY 	Plan_res_list_IN_Rec, -- 4537865
 P_Mode              IN         NUMBER)
IS

   Cursor C_Res_List_Details(P_Res_List_Id IN Number) IS
   Select *
   From Pa_Resource_Lists_All_Bg
   Where resource_list_id=P_Res_List_Id;

   Rec_Details C_Res_List_Details%RowType;

   l_resource_list_id   NUMBER;
   l_resource_list_name Varchar2(1000);

BEGIN

   X_Plan_res_list_Rec :=P_Plan_res_list_Rec;

   l_resource_list_id:=P_Plan_res_list_Rec.P_Resource_list_id;
   l_resource_list_name := P_Plan_res_list_Rec.P_resource_list_Name;

   IF P_Mode = 1 Then
        IF l_resource_list_id =PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
           l_resource_list_id := Null;
        End If;

        IF l_resource_list_id is Null Then
        -- Get the Resource list id from the Resource list name if the name is not defaulted to null.
           IF l_resource_list_name is not null and l_resource_list_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              SELECT resource_list_id
              INTO   l_resource_list_id
              FROM   pa_resource_lists_all_bg
              WHERE  name=l_resource_list_name;
           END IF;
        END IF;

        IF l_resource_list_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM and
           l_resource_list_id is not null Then

	   X_Plan_res_list_Rec.p_resource_list_ID := l_resource_list_id;

	   OPEN  C_Res_List_Details(P_Res_List_Id => l_resource_list_id);
         If C_Res_List_Details%NOTFOUND Then
           CLOSE C_Res_List_Details;
         Else
	   FETCH C_Res_List_Details INTO Rec_Details;
	   CLOSE C_Res_List_Details;

	   If	P_Plan_res_list_Rec.p_resource_list_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
		X_Plan_res_list_Rec.p_resource_list_name := Rec_Details.name;
	   End If;

	   If P_Plan_res_list_Rec.P_description = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
		X_Plan_res_list_Rec.P_description := Rec_Details.description;
	   End If;


	   If P_Plan_res_list_Rec.P_Start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE Then
		X_Plan_res_list_Rec.P_Start_date := Rec_Details.start_date_active;
	   End If;

	   If P_Plan_res_list_Rec.P_End_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE Then
                X_Plan_res_list_Rec.P_End_date := Rec_Details.end_date_active;
           End If;

	   If P_Plan_res_list_Rec.P_Job_Group_Id= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
                X_Plan_res_list_Rec.P_Job_Group_Id := Rec_Details.job_group_id;
           End If;

	   If P_Plan_res_list_Rec.P_Job_Group_Name= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
                X_Plan_res_list_Rec.P_Job_Group_name:= Null;
           End If;

	   If P_Plan_res_list_Rec.P_Use_For_Wp_Flag= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
                X_Plan_res_list_Rec.P_Use_For_Wp_Flag:= Rec_Details.Use_For_Wp_Flag;
           End If;

	   If P_Plan_res_list_Rec.P_Control_Flag= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
                X_Plan_res_list_Rec.P_Control_Flag := Rec_Details.control_flag;
           End If;

	   If P_Plan_res_list_Rec.P_Record_Version_Number= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
                X_Plan_res_list_Rec.P_Record_Version_Number:= Rec_Details.record_version_number; --For bug 4101579
           End If;

         End If;

      End If;

   End If;

   IF P_Mode=0 Then

        If      P_Plan_res_list_Rec.p_resource_list_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
                X_Plan_res_list_Rec.p_resource_list_id := Null;
	End If;


	If      P_Plan_res_list_Rec.p_resource_list_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
                X_Plan_res_list_Rec.p_resource_list_name := null;
        End If;

        If
                P_Plan_res_list_Rec.P_description = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
                X_Plan_res_list_Rec.P_description := Null;
        End If;


        If
                P_Plan_res_list_Rec.P_Start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE Then
                X_Plan_res_list_Rec.P_Start_date := sysdate;
        End If;

        If
                P_Plan_res_list_Rec.P_End_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE Then
                X_Plan_res_list_Rec.P_End_date := Null;
        End If;

        If
                P_Plan_res_list_Rec.P_Job_Group_Id= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
                X_Plan_res_list_Rec.P_Job_Group_Id := Null;
        End If;


        If
                P_Plan_res_list_Rec.P_Job_Group_Name= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
                X_Plan_res_list_Rec.P_Job_Group_name:= Null;
        End If;

        If
                P_Plan_res_list_Rec.P_Use_For_Wp_Flag= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
                X_Plan_res_list_Rec.P_Use_For_Wp_Flag:= Null;
        End If;

        If
                P_Plan_res_list_Rec.P_Control_Flag= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
                X_Plan_res_list_Rec.P_Control_Flag := Null;
        End If;

        If
                P_Plan_res_list_Rec.P_Record_Version_Number= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
                X_Plan_res_list_Rec.P_Record_Version_Number:= Null;
        End If;

   End If;
-- 4537865 : Havent included EXCEPTION block per mail from Ranjana

End Convert_Missing_List_IN_Rec;


/*******************************************************************************************
 * API Name: Convert_Missing_Format_In_Rec
 * Public/Private     : Private
 * Procedure/Function : Procedure
 * Description:
 *     This procedure converts the input values to null if its a G_MISS_VALUE
 *     The conversions are done for the Plan_RL_Format_In_Tbl.
 *  Attributes        :
 *     INPUT VALUES :
 *           P_Plan_RL_Format_Tbl      : The record which hold's the resource list format details.
 *                                       This contains the format identifier.
 *     OUTPUT VALUES :
 *
 *          X_Plan_RL_Format_Tbl       : The record which hold's the resource list identifiers
 *                                       of the newly created resource formats.
 * In Update
 * This API can be called in both update and create mode. In both the cases
 * the resource format identifier is checked against GMiss value. If it is Gmiss value
 * the then identifier is converted into null.
 *
 *
 *******************************************************************************************/

PROCEDURE Convert_Missing_Format_IN_Rec
(P_Plan_RL_Format_Tbl IN Plan_RL_Format_In_Tbl,
 X_Plan_RL_Format_Tbl OUT NOCOPY Plan_RL_Format_In_Tbl) -- 4537865
IS

l_resource_format_id NUMBER;

BEGIN

X_Plan_RL_Format_Tbl:= P_Plan_RL_Format_Tbl;


IF P_Plan_RL_Format_Tbl.count >0 then

	For i in P_Plan_RL_Format_Tbl.First .. P_Plan_RL_Format_Tbl.Last
 	Loop
		l_resource_format_id := P_Plan_RL_Format_Tbl(i).P_Res_Format_Id;

		If l_resource_format_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then

                  X_Plan_RL_Format_Tbl(i).P_Res_Format_Id:=Null;

        	End If;

	 End Loop;

End If;
-- 4537865 : Havent included EXCEPTION block per mail from Ranjana
End Convert_Missing_Format_IN_Rec;


/*******************************************************************************************
 * API Name: Convert_Missing_Members_In_Rec
 * Public/Private     : Private
 * Procedure/Function : Procedure
 * Description:
 *     This procedure converts the input values to null if its a G_MISS_VALUE
 *      and selects the value from the database if the value being input is
 *      null, so that there wouldn't be any change to the data when null is passed
 *      as input.
 *      The conversions are done for the Planning_Resource_In_Tbl.
 *  Attributes        :
 *     INPUT VALUES :
 *           P_Plan_res_list_Rec       : The record which hold's the resource list
 *                                       members details.
 *                                       This contains the input record.
 *           P_Mode                    : The mode in which this procedure is called.
 *                                       It can be called in either Update or create mode
 *                                       1 means update. 0 means create.
 *     OUTPUT VALUES :
 *
 *          X_Plan_res_list_Rec        : The record which hold's the resource list members
 *                                       details with the
 *                                       changed values to the fields of the record.
 * There can be two modes in which this procedure can be called
 * Update and create
 * P_Mode = 1 means update
 * P_Mode = 0 means create
 * In Update
 * if Update then Resource list member id can be present.
 * Convert all GMISS to the database values.
 *
 * In create mode,
 * Convert all missing values to null.
 *
 *
 *******************************************************************************************/
PROCEDURE Convert_Missing_Member_IN_Rec
(P_planning_resource_in_tbl IN  Planning_Resource_In_Tbl,
 P_Plan_res_list_Rec        IN  Plan_Res_List_IN_Rec,
 X_planning_resource_in_tbl OUT NOCOPY Planning_Resource_In_Tbl, -- 4537865
 P_Mode  IN Number)
IS

  Cursor C_Member_Details(P_Member_Id IN Number) Is
  Select *
  From Pa_resource_list_members
  Where
  resource_list_member_id=P_Member_Id;

  member_rec_details C_Member_Details%RowType;

  l_member_id NUMBER;
  l_object_id NUMBER;
  l_object_type VARCHAR2(30);

BEGIN

  X_planning_resource_in_tbl:= P_planning_resource_in_tbl;


  IF P_Mode = 1 Then

  IF P_planning_resource_in_tbl.count >0 then

     For i in P_planning_resource_in_tbl.First .. P_planning_resource_in_tbl.Last
     Loop

     l_member_id := P_planning_resource_in_tbl(i).p_resource_list_member_id;
     -- try to derive the member id if its null or gmiss from the alias
     --added for bug 3947158
     IF l_member_id IN (PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,Null) Then

        IF  ( P_planning_resource_in_tbl(i).P_resource_alias IS NOT Null)
        and ( P_planning_resource_in_tbl(i).P_resource_alias <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN

            -- For bug 4103909
            IF P_Plan_res_list_Rec.p_control_flag = 'Y' THEN

               BEGIN
                  SELECT resource_list_member_id
                  INTO l_member_id
                  FROM  pa_resource_list_members
                  WHERE alias = p_planning_resource_in_tbl(i).P_resource_alias
                  and resource_list_id = P_Plan_res_list_Rec.p_resource_list_id;
               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                  l_member_id :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ;
               END;

            ELSE

               BEGIN
                  IF p_planning_resource_in_tbl(i).p_project_id is null THEN
                     l_object_type := 'RESOURCE_LIST';
                     l_object_id   := P_Plan_res_list_Rec.p_resource_list_id;
                  ELSE
                     l_object_type := 'PROJECT';
                     l_object_id   := p_planning_resource_in_tbl(i).p_project_id;
                  END IF;

                  SELECT resource_list_member_id
                  INTO l_member_id
                  FROM PA_RESOURCE_LIST_MEMBERS
                  WHERE resource_list_id = P_Plan_res_list_Rec.p_resource_list_id
                  AND ALIAS = p_planning_resource_in_tbl(i).p_resource_alias
                  AND object_type = l_object_type
                  AND object_id = l_object_id;

               EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                     l_member_id :=PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ;
               END;
               --End of bug 4103909

            END IF;

            X_planning_resource_in_tbl(i).p_resource_list_member_id:= l_member_id;

         END IF;

      END IF;
      --For bug 3815348.

      If l_member_id IN (PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,Null) Then

         X_planning_resource_in_tbl(i).p_resource_list_member_id:=Null;


         If P_planning_resource_in_tbl(i).P_resource_alias = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).P_resource_alias := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_person_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            X_planning_resource_in_tbl(i).p_person_id := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_person_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_person_name := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_job_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            X_planning_resource_in_tbl(i).p_job_id := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_job_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_job_name := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_organization_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            X_planning_resource_in_tbl(i).p_organization_id := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_organization_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_organization_name := null;
         End If;

         If P_planning_resource_in_tbl(i).p_vendor_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            X_planning_resource_in_tbl(i).p_vendor_id := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_vendor_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_vendor_name := null;
         End If;

         If P_planning_resource_in_tbl(i).p_fin_category_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_fin_category_name := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_non_labor_resource = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_non_labor_resource:= Null;
         End If;

         If P_planning_resource_in_tbl(i).p_project_role_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            X_planning_resource_in_tbl(i).p_project_role_id:= Null;
         End If;

         If P_planning_resource_in_tbl(i).p_project_role_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_project_role_name:=Null;
         End If;

         If P_planning_resource_in_tbl(i).p_resource_class_id =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            X_planning_resource_in_tbl(i).p_resource_class_id:=Null;
         End If;

         If P_planning_resource_in_tbl(i).p_resource_class_code  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_resource_class_code  :=Null;
         End If;

         If P_planning_resource_in_tbl(i).p_res_format_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            X_planning_resource_in_tbl(i).p_res_format_id := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_spread_curve_id  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            X_planning_resource_in_tbl(i).p_spread_curve_id:= Null;
         End If;

         If P_planning_resource_in_tbl(i).p_etc_method_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_etc_method_code := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_mfc_cost_type_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            X_planning_resource_in_tbl(i).p_mfc_cost_type_id := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_fc_res_type_code  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_fc_res_type_code := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_inventory_item_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            X_planning_resource_in_tbl(i).p_inventory_item_id :=  Null;
         End If;

         If P_planning_resource_in_tbl(i).p_inventory_item_name  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_inventory_item_name := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_item_category_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            X_planning_resource_in_tbl(i).p_item_category_id := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_item_category_name  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_item_category_name := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute_category := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute1 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute1 := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute2 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute2 := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute3 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute3 := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute4 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute4 := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute5 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute5 := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute6 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute6 := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute7 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute7 := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute8 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute8 := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute9 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute9 := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute10 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute10:= Null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute11 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute11:= Null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute12= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute12:= Null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute13= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute13:= Null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute14 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute14 := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute15 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute15 := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute16= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute16:= Null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute17= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute17:= null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute18= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute18:= Null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute19= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute19:= Null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute20= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute20:= Null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute21= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute21:= Null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute22= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute22:= Null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute23= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute23:= null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute24= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute24:= Null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute25= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute25:= Null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute26= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute26:= Null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute27= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute27:= Null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute28= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute28 := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute29= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute29:= Null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute30= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute30:= Null;
         End If;

         If P_planning_resource_in_tbl(i).p_person_type_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_person_type_code := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_bom_resource_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            X_planning_resource_in_tbl(i).p_bom_resource_id := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_bom_resource_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_bom_resource_name := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_team_role = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_team_role := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_incur_by_res_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_incur_by_res_code := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_incur_by_res_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_incur_by_res_type := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_record_version_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            X_planning_resource_in_tbl(i).p_record_version_number := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_project_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            X_planning_resource_in_tbl(i).p_project_id := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_enabled_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_enabled_flag := Null;
         End If;

      End IF; --End of bug 3815348


      If l_member_id is NOT Null and l_member_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then

         OPEN C_Member_Details(P_Member_Id => l_member_id);
            If C_Member_Details%NOTFOUND Then
               CLOSE C_Member_Details;
            Else
               FETCH C_Member_Details INTO Member_Rec_Details;
               CLOSE C_Member_Details;

         If P_planning_resource_in_tbl(i).p_resource_alias = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_resource_alias := Member_Rec_Details.alias;
         End If;

         If P_planning_resource_in_tbl(i).p_person_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            X_planning_resource_in_tbl(i).p_person_id := Member_Rec_Details.person_id;
         End If;

         If P_planning_resource_in_tbl(i).p_person_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_person_name := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_job_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            X_planning_resource_in_tbl(i).p_job_id := Member_Rec_Details.job_id;
         End If;

         If P_planning_resource_in_tbl(i).p_job_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_job_name := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_organization_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            X_planning_resource_in_tbl(i).p_organization_id := Member_Rec_Details.organization_id;
         End If;

         If P_planning_resource_in_tbl(i).p_organization_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_organization_name := null;
         End If;

         If P_planning_resource_in_tbl(i).p_vendor_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            X_planning_resource_in_tbl(i).p_vendor_id :=Member_Rec_Details.vendor_id;
         End If;

         If P_planning_resource_in_tbl(i).p_vendor_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_vendor_name := null;
         End If;

         If P_planning_resource_in_tbl(i).p_fin_category_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_fin_category_name := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_non_labor_resource = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_non_labor_resource:= Member_Rec_Details.non_labor_resource;
         End If;

         If P_planning_resource_in_tbl(i).p_project_role_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            X_planning_resource_in_tbl(i).p_project_role_id:= Member_Rec_Details.project_role_id;
         End If;

         If P_planning_resource_in_tbl(i).p_project_role_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_project_role_name:=Null;
         End If;

         If P_planning_resource_in_tbl(i).p_resource_class_id =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            X_planning_resource_in_tbl(i).p_resource_class_id:=Member_Rec_Details.resource_class_id;
         End If;

         If P_planning_resource_in_tbl(i).p_resource_class_code  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_resource_class_code  :=Member_Rec_Details.resource_class_code;
         End If;

         If P_planning_resource_in_tbl(i).p_res_format_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            X_planning_resource_in_tbl(i).p_res_format_id := Member_Rec_Details.res_format_id;
         End If;

         If P_planning_resource_in_tbl(i).p_spread_curve_id  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            X_planning_resource_in_tbl(i).p_spread_curve_id:= Member_Rec_Details.spread_curve_id;
         End If;

         If P_planning_resource_in_tbl(i).p_etc_method_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_etc_method_code := Member_Rec_Details.etc_method_code;
         End If;

         If P_planning_resource_in_tbl(i).p_mfc_cost_type_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            X_planning_resource_in_tbl(i).p_mfc_cost_type_id := Member_Rec_Details.mfc_cost_type_id;
         End If;

         If P_planning_resource_in_tbl(i).p_fc_res_type_code  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_fc_res_type_code := Member_Rec_Details.fc_res_type_code;
         End If;

         If P_planning_resource_in_tbl(i).p_inventory_item_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            X_planning_resource_in_tbl(i).p_inventory_item_id :=  Member_Rec_Details.inventory_item_id;
         End If;

         If P_planning_resource_in_tbl(i).p_inventory_item_name  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_inventory_item_name := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_item_category_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            X_planning_resource_in_tbl(i).p_item_category_id := Member_Rec_Details.item_category_id;
         End If;

         If P_planning_resource_in_tbl(i).p_item_category_name  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_item_category_name := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute_category := Member_Rec_Details.attribute_category;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute1 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute1 := Member_Rec_Details.attribute1;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute2 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute2 := Member_Rec_Details.attribute2;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute3 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute3 := Member_Rec_Details.attribute3;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute4 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute4 := Member_Rec_Details.attribute4;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute5 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute5 := Member_Rec_Details.attribute5;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute6 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute6 := Member_Rec_Details.attribute6;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute7 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute7 := Member_Rec_Details.attribute7;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute8 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute8 := Member_Rec_Details.attribute8;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute9 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute9 := Member_Rec_Details.attribute9;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute10 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute10:= Member_Rec_Details.attribute10;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute11 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute11:= Member_Rec_Details.attribute11;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute12= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute12:= Member_Rec_Details.attribute12;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute13= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute13:= Member_Rec_Details.attribute13;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute14 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute14 := Member_Rec_Details.attribute14;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute15 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute15 := Member_Rec_Details.attribute15;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute16= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute16:= Member_Rec_Details.attribute16;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute17= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute17:= Member_Rec_Details.attribute17;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute18= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute18:= Member_Rec_Details.attribute18;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute19= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute19:= Member_Rec_Details.attribute19;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute20= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute20:= Member_Rec_Details.attribute20;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute21= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute21:= Member_Rec_Details.attribute21;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute22= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute22:= Member_Rec_Details.attribute22;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute23= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute23:= Member_Rec_Details.attribute23;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute24= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute24:= Member_Rec_Details.attribute24;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute25= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute25:= Member_Rec_Details.attribute25;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute26= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute26:= Member_Rec_Details.attribute26;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute27= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute27:= Member_Rec_Details.attribute27;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute28= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute28 := Member_Rec_Details.attribute28;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute29= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute29:= Member_Rec_Details.attribute29;
         End If;

         If P_planning_resource_in_tbl(i).p_attribute30= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_attribute30:= Member_Rec_Details.attribute30;
         End If;

         If P_planning_resource_in_tbl(i).p_person_type_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_person_type_code := Member_Rec_Details.person_type_code;
         End If;

         If P_planning_resource_in_tbl(i).p_bom_resource_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            X_planning_resource_in_tbl(i).p_bom_resource_id := Member_Rec_Details.bom_resource_id;
         End If;

         If P_planning_resource_in_tbl(i).p_bom_resource_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_bom_resource_name := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_team_role = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_team_role := Member_Rec_Details.team_role;
         End If;

         If P_planning_resource_in_tbl(i).p_incur_by_res_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_incur_by_res_code := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_incur_by_res_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_incur_by_res_type := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_record_version_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            X_planning_resource_in_tbl(i).p_record_version_number := Member_Rec_Details.record_version_number;
         End If;

         If P_planning_resource_in_tbl(i).p_project_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            X_planning_resource_in_tbl(i).p_project_id := Null;
         End If;

         If P_planning_resource_in_tbl(i).p_enabled_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
            X_planning_resource_in_tbl(i).p_enabled_flag := Member_Rec_Details.enabled_flag;
         End If;

        End If;

      End If;

   End Loop;

  End If;

 End IF;

 If P_Mode = 0 Then

   IF P_planning_resource_in_tbl.count >0 then

      For i in P_planning_resource_in_tbl.First .. P_planning_resource_in_tbl.Last
        Loop

           If P_planning_resource_in_tbl(i).P_resource_alias = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).P_resource_alias := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_resource_list_member_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
              X_planning_resource_in_tbl(i).p_resource_list_member_id := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_person_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
              X_planning_resource_in_tbl(i).p_person_id := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_person_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_person_name := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_job_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
              X_planning_resource_in_tbl(i).p_job_id := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_job_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_job_name := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_organization_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
              X_planning_resource_in_tbl(i).p_organization_id := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_organization_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_organization_name := null;
           End If;

           If P_planning_resource_in_tbl(i).p_vendor_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
              X_planning_resource_in_tbl(i).p_vendor_id := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_vendor_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_vendor_name := null;
           End If;

           If P_planning_resource_in_tbl(i).p_fin_category_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_fin_category_name := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_non_labor_resource = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_non_labor_resource:= Null;
           End If;

           If P_planning_resource_in_tbl(i).p_project_role_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
              X_planning_resource_in_tbl(i).p_project_role_id:= Null;
           End If;

           If P_planning_resource_in_tbl(i).p_project_role_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_project_role_name:=Null;
           End If;

           If P_planning_resource_in_tbl(i).p_resource_class_id =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
              X_planning_resource_in_tbl(i).p_resource_class_id:=Null;
           End If;

           If P_planning_resource_in_tbl(i).p_resource_class_code  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_resource_class_code  :=Null;
           End If;

           If P_planning_resource_in_tbl(i).p_res_format_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
              X_planning_resource_in_tbl(i).p_res_format_id := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_spread_curve_id  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
              X_planning_resource_in_tbl(i).p_spread_curve_id:= Null;
           End If;

           If P_planning_resource_in_tbl(i).p_etc_method_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_etc_method_code := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_mfc_cost_type_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
              X_planning_resource_in_tbl(i).p_mfc_cost_type_id := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_fc_res_type_code  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_fc_res_type_code := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_inventory_item_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
              X_planning_resource_in_tbl(i).p_inventory_item_id :=  Null;
           End If;

           If P_planning_resource_in_tbl(i).p_inventory_item_name  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_inventory_item_name := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_item_category_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
              X_planning_resource_in_tbl(i).p_item_category_id := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_item_category_name  = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_item_category_name := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_attribute_category = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_attribute_category := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_attribute1 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_attribute1 := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_attribute2 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_attribute2 := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_attribute3 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_attribute3 := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_attribute4 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_attribute4 := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_attribute5 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_attribute5 := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_attribute6 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_attribute6 := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_attribute7 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_attribute7 := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_attribute8 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_attribute8 := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_attribute9 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_attribute9 := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_attribute10 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_attribute10:= Null;
           End If;

           If P_planning_resource_in_tbl(i).p_attribute11 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_attribute11:= Null;
           End If;

           If P_planning_resource_in_tbl(i).p_attribute12= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_attribute12:= Null;
           End If;

           If P_planning_resource_in_tbl(i).p_attribute13= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_attribute13:= Null;
           End If;

           If P_planning_resource_in_tbl(i).p_attribute14 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_attribute14 := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_attribute15 = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_attribute15 := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_attribute16= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_attribute16:= Null;
           End If;

           If P_planning_resource_in_tbl(i).p_attribute17= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_attribute17:= null;
           End If;

           If P_planning_resource_in_tbl(i).p_attribute18= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_attribute18:= Null;
           End If;

           If P_planning_resource_in_tbl(i).p_attribute19= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_attribute19:= Null;
           End If;

           If P_planning_resource_in_tbl(i).p_attribute20= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_attribute20:= Null;
           End If;

           If P_planning_resource_in_tbl(i).p_attribute21= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_attribute21:= Null;
           End If;

           If P_planning_resource_in_tbl(i).p_attribute22= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_attribute22:= Null;
           End If;

           If P_planning_resource_in_tbl(i).p_attribute23= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_attribute23:= null;
           End If;

           If P_planning_resource_in_tbl(i).p_attribute24= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_attribute24:= Null;
           End If;

           If P_planning_resource_in_tbl(i).p_attribute25= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_attribute25:= Null;
           End If;

           If P_planning_resource_in_tbl(i).p_attribute26= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_attribute26:= Null;
           End If;

           If P_planning_resource_in_tbl(i).p_attribute27= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_attribute27:= Null;
           End If;

           If P_planning_resource_in_tbl(i).p_attribute28= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_attribute28 := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_attribute29= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_attribute29:= Null;
           End If;

           If P_planning_resource_in_tbl(i).p_attribute30= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_attribute30:= Null;
           End If;

           If P_planning_resource_in_tbl(i).p_person_type_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_person_type_code := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_bom_resource_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
              X_planning_resource_in_tbl(i).p_bom_resource_id := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_bom_resource_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_bom_resource_name := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_team_role = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_team_role := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_incur_by_res_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_incur_by_res_code := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_incur_by_res_type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_incur_by_res_type := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_record_version_number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
              X_planning_resource_in_tbl(i).p_record_version_number := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_project_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
              X_planning_resource_in_tbl(i).p_project_id := Null;
           End If;

           If P_planning_resource_in_tbl(i).p_enabled_flag = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              X_planning_resource_in_tbl(i).p_enabled_flag := Null;
           End If;

        End Loop;

     End If;

  End If;--p=0
-- 4537865 : Havent included EXCEPTION block per mail from Ranjana
End Convert_Missing_Member_IN_Rec;


/****************************************************************************************
 * Procedure   : Create_Plan_RL_Format
 * Public/Private    : Public
 * Procedure/Function: Procedure
 * Description : This API adds planning resources to a resource list. Called
 *               from CREATE_RESOURCE_LIST or UPDATE_RESOURCE_LIST API in this
 *               package.
 ****************************************************************************************/

 Procedure Create_Plan_RL_Format(
        p_commit                 IN          VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_init_msg_list          IN          VARCHAR2 DEFAULT FND_API.G_FALSE,
        P_Res_List_id            IN          NUMBER,
        P_Plan_RL_Format_Tbl     IN          Plan_RL_Format_In_Tbl,
        X_Plan_RL_Format_Tbl     OUT NOCOPY  Plan_RL_Format_Out_Tbl,
        X_Return_Status          OUT NOCOPY  VARCHAR2,
        X_Msg_Count              OUT NOCOPY  NUMBER,
        X_Msg_Data               OUT NOCOPY  VARCHAR2);



 /******************************************************************************************
 * Procedure   : Create_Planning_Resource
 * Public/Private    : Public
 * Procedure/Function: Procedure
 * Description : The purpose of this procedure is to Validate
 *               and create new planning resources  for the
 *               given resource list.
 ********************************************************************************************/
PROCEDURE Create_Planning_Resource(
       p_commit                    IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
       p_init_msg_list             IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
       p_resource_list_id          IN         VARCHAR2,
       P_planning_resource_in_tbl  IN         Planning_Resource_In_Tbl,
       X_planning_resource_out_tbl OUT NOCOPY Planning_Resource_Out_Tbl,
       x_return_status             OUT NOCOPY VARCHAR2,
       x_msg_count                 OUT NOCOPY NUMBER,
       x_error_msg_data            OUT NOCOPY VARCHAR2  );

/***********************************************************
 * Procedure : Create_Resource_List
 * Description : AMG API, used to create a resource list
 *               and its corresponding members and formats.
 *               The detailed information is in spec.
**********************************************************/
PROCEDURE Create_Resource_List
(p_commit                    IN           VARCHAR2 := FND_API.G_FALSE,
 p_init_msg_list             IN           VARCHAR2 := FND_API.G_FALSE,
 p_api_version_number        IN           NUMBER,
 P_plan_res_list_Rec         IN           Plan_Res_List_IN_Rec,
 X_plan_res_list_Rec         OUT NOCOPY   Plan_Res_List_OUT_Rec,
 P_Plan_RL_Format_Tbl        IN           Plan_RL_Format_In_Tbl,
 X_Plan_RL_Format_Tbl        OUT NOCOPY   Plan_RL_Format_Out_Tbl,
 P_planning_resource_in_tbl  IN           Planning_Resource_In_Tbl,
 X_planning_resource_out_tbl OUT NOCOPY   Planning_Resource_Out_Tbl,
 X_Return_Status             OUT NOCOPY   VARCHAR2,
 X_Msg_Count                 OUT NOCOPY   NUMBER,
 X_Msg_Data                  OUT NOCOPY   VARCHAR2)
IS
l_api_version_number      CONSTANT     NUMBER := G_API_VERSION_NUMBER;
l_api_name                CONSTANT     VARCHAR2(30) := 'Create_Resource_List';
l_resource_list_id                     Number;
l_error_code                           NUMBER := 0;
l_error_stage                          VARCHAR2(2000);
l_error_stack                          VARCHAR2(2000);
l_return_status                        Varchar2(30);
l_msg_count                            Number;
l_msg_data                             Varchar2(100);
l_business_group_id                    Number := null;
l_Plan_Res_List_Rec			Plan_Res_List_IN_Rec;
L_Plan_RL_Format_Tbl                    Plan_RL_Format_In_Tbl;
L_Planning_resource_in_tbl              Planning_Resource_In_Tbl;
l_mode				       Number;
NAME_NULL_ERR                          Exception;
NOFORMAT_EXISTS_ERR                    Exception;

BEGIN

Pa_Planning_Resource_Pvt.g_amg_flow := 'Y';

   --Initialize the message stack before starting any further processing.
   IF FND_API.to_boolean( p_init_msg_list )
   THEN
           FND_MSG_PUB.initialize;
   END IF;

   --Initialize the Out Variables.
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_msg_count := 0;
   l_mode:=0;

   --Set a Savepoint so that if error occurs at any stage we can
   -- rollback all the changes.
   --SAVEPOINT Create_Resource_List_Pub;

   --Check for the Compatibility of the API Version
   --This is a must for AMG API's
   --Doubt -- does this have to be done for all the api's/the main one??
   IF NOT FND_API.Compatible_API_Call
          ( l_api_version_number   ,
            p_api_version_number   ,
            l_api_name             ,
            G_PKG_NAME             )
    THEN

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
   Convert_Missing_List_IN_Rec(
			P_Plan_res_list_Rec => P_Plan_res_list_Rec,
			X_Plan_res_list_Rec => L_Plan_res_list_Rec,
			P_Mode	            => l_mode);

   Convert_Missing_Format_IN_Rec(
                        P_Plan_RL_Format_Tbl => P_Plan_RL_Format_Tbl,
                        X_Plan_RL_Format_Tbl => L_Plan_RL_Format_Tbl);


   Convert_Missing_Member_IN_Rec(
                        P_Planning_resource_in_tbl => P_Planning_resource_in_tbl,
                        P_Plan_res_list_Rec        => L_Plan_res_list_Rec,
                        X_Planning_resource_in_tbl => L_Planning_resource_in_tbl,
                        P_Mode                     => l_mode);


   -- derive business_group_id to pass to Pa_Create_Resource.create_resource_list()
   -- procedure.  The approach assumes that the user executing this procedure has
   -- already set the operating unit via dbms_application_info.set_client_info().
   -- Otherwise, a value of null will be passed to the called procedure.
   Select
         business_group_id
   Into
         l_business_group_id
   From
         Pa_Implementations;

   -- For bug 3675288.
   If L_plan_res_list_Rec.p_resource_list_name is NULL Then

         RAISE NAME_NULL_ERR;

   End If;


   /***************************************************************
   * Call to the Pa_Create_Resource.Create_Resource_List API
   * which will create a resource list, when we pass the
   * the corr values for resource_list_name, description etc
   * Its all a part of the P_plan_res_list_Rec record structure.
   * It will create a resource list and pass back the resource_list_id
   * value as an out parameter into l_resource_list_id variable.
   * This resource list ID value will then be passed while creating
   * resource formats and resource list members.
   ***************************************************************/
   Pa_Create_Resource.Create_Resource_List
            (p_resource_list_name  => L_plan_res_list_Rec.p_resource_list_name,
             p_description         => L_plan_res_list_Rec.p_description,
             p_public_flag         => 'Y',
             p_group_resource_type => NULL,
             p_start_date          => L_plan_res_list_Rec.p_start_date,
             p_end_date            => L_plan_res_list_Rec.p_end_date,
             p_business_group_id   => l_business_group_id,
             p_job_group_id        => L_plan_res_list_Rec.p_job_group_id,
             p_job_group_name      => L_plan_res_list_Rec.p_job_group_name ,
             p_use_for_wp_flag     => L_plan_res_list_Rec.p_use_for_wp_flag ,
             p_control_flag        => L_plan_res_list_Rec.p_control_flag ,
             p_migration_code      => 'N',
             p_record_version_number =>
                             L_plan_res_list_Rec.p_record_version_number ,
             p_resource_list_id    => x_plan_res_list_rec.x_resource_list_id,
             p_err_code            => l_error_code,
             p_err_stage           => l_error_stage  ,
             p_err_stack           => l_error_stack  );


         IF l_error_code > 0  THEN

             RAISE FND_API.G_EXC_ERROR;
         END IF;
         IF l_error_code < 0  THEN

             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

        /************************************************
        * Check the Commit flag. if it is true then Commit.
        ************************************************/
        IF l_error_code = 0 THEN
          IF FND_API.to_boolean( p_commit )
          THEN
                 COMMIT;
          END IF;
        END IF;
        l_resource_list_id := x_plan_res_list_rec.x_resource_list_id;
         /**************************************************
         * Call to the Pa_Plan_Res_List_Pub.Create_Plan_RL_Format
         * API which will add the resource formats passed in as
         * table of recs. We are also passing the resource list ID
         * which was created.
         **************************************************/

        --For Bug 3675288.
		IF (L_Plan_RL_Format_Tbl.Count = 0 AND L_planning_resource_in_tbl.Count <> 0) THEN

			RAISE NOFORMAT_EXISTS_ERR;

		END IF;

		IF L_Plan_RL_Format_Tbl.Count <> 0 Then
         Pa_Plan_Res_List_Pub.Create_Plan_RL_Format(
              p_commit                 => p_commit,
              p_init_msg_list          => p_init_msg_list,
              P_Res_List_Id            => l_resource_list_id,
              P_Plan_RL_Format_Tbl     => L_Plan_RL_Format_Tbl,
              X_Plan_RL_Format_Tbl     => X_Plan_RL_Format_Tbl,
              X_Return_Status          => l_return_status,
              X_Msg_Count              => l_msg_count,
              X_Msg_Data               => l_msg_data);


        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               x_msg_count := x_msg_count + 1;
               x_msg_data := l_msg_data;
               PA_UTILS.Add_Message ('PA', x_msg_data);
               Rollback;
               Return;
        END IF;

        END IF;

        /**************************************************
        * Call to the Pa_Plan_Res_List_Pub.Create_Planning_Resource
        * API which will add the resource members passed in as
        * table of recs. We are also passing the resource list ID
        * which was created.
        **************************************************/
        --SAVEPOINT Create_Resource_List_Pub_B;

        Pa_Plan_Res_List_Pub.Create_Planning_Resource(
            p_commit                    => p_commit,
            p_init_msg_list             => p_init_msg_list,
            p_resource_list_id          => l_resource_list_id,
            P_planning_resource_in_tbl  => L_planning_resource_in_tbl,
            X_planning_resource_out_tbl => X_planning_resource_out_tbl,
            x_return_status             => l_return_status,
            x_msg_count                 => l_msg_count,
            x_error_msg_data            => l_msg_data  );

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               x_msg_count := x_msg_count + 1;
               x_msg_data := l_msg_data;
               PA_UTILS.Add_Message ('PA', x_msg_data);
               ROLLBACK ;
               Return;
        END IF;

EXCEPTION
WHEN NOFORMAT_EXISTS_ERR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        X_Msg_Data := 'PA_AMG_CANNOT_CRT_MEMBERS';
        x_msg_count := x_msg_count + 1;
        Pa_Utils.Add_Message
                        (P_App_Short_Name  => 'PA',
                         P_Msg_Name        => 'PA_AMG_CANNOT_CRT_MEMBERS');
WHEN NAME_NULL_ERR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        X_Msg_Data := 'PA_AMG_LIST_NAME_NULL';
        x_msg_count := x_msg_count + 1;
        Pa_Utils.Add_Message
                        (P_App_Short_Name  => 'PA',
                         P_Msg_Name        => 'PA_AMG_LIST_NAME_NULL');
        ROLLBACK ;
        Return;
WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        X_Msg_Data := l_error_stack;
        x_msg_count := x_msg_count + 1;
        ROLLBACK ;
        Return;
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        x_msg_count := x_msg_count + 1;
         X_Msg_Data := SUBSTRB(SQLERRM,1,240); -- 4537865
        ROLLBACK ;
	-- 4537865
        FND_MSG_PUB.Add_Exc_Msg
                    (   p_pkg_name              =>  G_PKG_NAME ,
                          p_procedure_name        =>  l_api_name,
			p_error_text => X_Msg_Data
                );
        Return;

WHEN OTHERS  THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := x_msg_count + 1; -- 4537865
	 X_Msg_Data := SUBSTRB(SQLERRM,1,240); -- 4537865
        ROLLBACK;
        FND_MSG_PUB.Add_Exc_Msg
                    (   p_pkg_name              =>  G_PKG_NAME ,
                          p_procedure_name        =>  l_api_name,
			p_error_text => x_msg_data -- 4537865
                );
        Return;
END Create_Resource_List;

/***********************************************************
 * Procedure : Update_Resource_List
 * Description : AMG API, used to Update a resource list
 *               and its corresponding members and formats.
 *		 The detailed information is in the spec.
 *********************************************************/
PROCEDURE Update_Resource_List(
     p_commit                    IN             VARCHAR2 := FND_API.G_FALSE,
     p_init_msg_list             IN             VARCHAR2 := FND_API.G_FALSE,
     p_api_version_number        IN             NUMBER,
     P_plan_res_list_Rec         IN             Plan_Res_List_IN_Rec,
     X_plan_res_list_Rec         OUT    NOCOPY  Plan_Res_List_OUT_Rec,
     P_Plan_RL_Format_Tbl        IN             Plan_RL_Format_In_Tbl,
     X_Plan_RL_Format_Tbl        OUT    NOCOPY  Plan_RL_Format_Out_Tbl,
     P_planning_resource_in_tbl  IN             Planning_Resource_In_Tbl,
     X_planning_resource_out_tbl OUT    NOCOPY  Planning_Resource_Out_Tbl,
     X_Return_Status             OUT    NOCOPY  VARCHAR2,
     X_Msg_Count                 OUT    NOCOPY  NUMBER,
     X_Msg_Data                  OUT    NOCOPY  VARCHAR2)

IS

   l_api_version_number      CONSTANT   NUMBER       := G_API_VERSION_NUMBER;
   l_api_name                CONSTANT   VARCHAR2(30) := 'Update_Resource_List';
   l_return_status                      Varchar2(30);
   l_msg_count                          Number;
   l_msg_data                           Varchar2(100);
   l_check_exist                        Varchar2(1);
   l_rec_ver_number                     Number;
   l_res_class_flag                     Varchar2(1) := Null;
   L_Plan_res_list_Rec                  Plan_Res_List_IN_Rec;
   L_Plan_RL_Format_Tbl                 Plan_RL_Format_In_Tbl;
   L_planning_resource_in_tbl           Planning_Resource_In_Tbl;
   L_one_pln_res_in_tbl                 Planning_Resource_In_Tbl;
   L_one_pln_res_out_tbl                Planning_Resource_Out_Tbl;
   l_mode                               Number := 1;
   l_ERROR                              Exception;
   l_msg_index_out                      Number;
   l_data                               Varchar2(2000) := Null;
   l_exists                             Varchar2(1);
   l_object_type                        Varchar2(30);
   l_object_id                          Number;
   l_rlm_record_version_number          Number;
   l_project_exists                     Varchar2(1);
   l_format_exists                      Varchar2(1);

   CURSOR resource_list_cursor (p_resource_list_id  in number) IS
          SELECT resource_list_id,
                 control_flag,
                 record_version_number,
                 name,
                 description,
                 start_date_active,
                 end_date_active,
                 job_group_id,
                 use_for_wp_flag
          FROM PA_RESOURCE_LISTS_ALL_BG
          WHERE resource_list_id = p_resource_list_id;

   l_old_resource_list_rec resource_list_cursor%RowType;

BEGIN

Pa_Planning_Resource_Pvt.g_amg_flow := 'Y';
     --Initialize the message stack before starting any further processing.
     If Fnd_Api.To_Boolean( P_Init_Msg_List ) Then

           Fnd_Msg_Pub.Initialize;

     End If;

     --Initialize the Out Variables.
     x_return_status := Fnd_Api.G_Ret_Sts_Success;
     x_msg_count := 0;


     --Set a Savepoint so that if error occurs at any stage we can
     -- rollback all the changes.
     -- SAVEPOINT Update_Resource_List_Pub;

     --Check for the Compatibility of the API Version
     --This is a must for AMG API's
     If Not Fnd_Api.Compatible_API_Call
          ( l_api_version_number   ,
            p_api_version_number   ,
            l_api_name             ,
            G_Pkg_Name             ) Then

        Raise Fnd_Api.G_Exc_UnExpected_Error;

     End If;


   Convert_Missing_List_IN_Rec(
                        P_Plan_res_list_Rec => P_Plan_res_list_Rec,
                        X_Plan_res_list_Rec => L_Plan_res_list_Rec,
                        P_Mode              => l_mode);

   Convert_Missing_Format_IN_Rec(
                        P_Plan_RL_Format_Tbl => P_Plan_RL_Format_Tbl,
                        X_Plan_RL_Format_Tbl => L_Plan_RL_Format_Tbl);


   Convert_Missing_Member_IN_Rec(
                        P_Planning_resource_in_tbl => P_Planning_resource_in_tbl,
                        P_Plan_res_list_Rec        => L_Plan_res_list_Rec,
                        X_Planning_resource_in_tbl => L_Planning_resource_in_tbl,
                        P_Mode                     => l_mode);

             IF L_plan_res_list_Rec.p_resource_list_id is not null THEN
                    Open resource_list_cursor(p_resource_list_id => L_plan_res_list_Rec.p_resource_list_id);

             Fetch resource_list_cursor into l_old_resource_list_rec;

             If resource_list_cursor%NotFound Then
                    Pa_Debug.G_Stage := 'Resource List Id is invalid.';
                    Close resource_list_cursor;
                    Pa_Utils.Add_Message(
                              P_App_Short_Name => 'PA',
                              P_Msg_Name       => 'PA_INVALID_RESOURCE_LIST_ID');

                    Raise l_ERROR;

             Else

                    Close resource_list_cursor;

             End If;

             IF (nvl(l_old_resource_list_rec.name,' ')  <> nvl(L_Plan_res_list_Rec.p_resource_list_name,' ') OR
                nvl(l_old_resource_list_rec.description,' ') <> nvl(L_Plan_res_list_Rec.p_description,' ') OR
                nvl(l_old_resource_list_rec.start_date_active,sysdate) <> nvl(L_Plan_res_list_Rec.p_start_date,sysdate) OR
                nvl(l_old_resource_list_rec.end_date_active,sysdate) <> nvl(L_Plan_res_list_Rec.p_end_date,sysdate) OR
                nvl(l_old_resource_list_rec.job_group_id,-1) <> nvl(L_Plan_res_list_Rec.p_job_group_id,-1) OR
                nvl(l_old_resource_list_rec.use_for_wp_flag,' ') <> nvl(L_Plan_res_list_Rec.p_use_for_wp_flag,' ') OR
                nvl(l_old_resource_list_rec.control_flag,' ') <> nvl(L_Plan_res_list_Rec.p_control_flag,' ')
                )
             THEN

                     -- One of the resource_list attributes has changed which means,
                     -- the resource_list record needs to be updated.

                     IF (L_Plan_res_list_Rec.p_record_version_number is null OR
                         L_Plan_res_list_Rec.p_record_version_number <> l_old_resource_list_rec.record_version_number) THEN
                         Pa_Utils.Add_Message(
                                   P_App_Short_Name => 'PA',
                                   P_Msg_Name       => 'PA_PLN_RES_LIST_REC_VER_INVAL');

                         Raise l_ERROR;
                     END IF;


                    /********************************************************
                    * Call to API Pa_Create_Resource.Update_Resource_List to update
                    * the resource_list with the newly passed values. Values are
                    * passed thro the record struc P_plan_res_list_Rec.
                    *********************************************************/

                    Pa_Create_Resource.Update_Resource_List
                         (p_resource_list_name  => L_plan_res_list_Rec.p_resource_list_name,
                          p_description         => L_plan_res_list_Rec.p_description,
                          p_start_date          => L_plan_res_list_Rec.p_start_date,
                          p_end_date            => L_plan_res_list_Rec.p_end_date,
                          p_job_group_id        => L_Plan_Res_List_Rec.p_job_group_id,
                          p_job_group_name      => L_plan_res_list_Rec.p_job_group_name,
                          p_use_for_wp_flag     => L_plan_res_list_Rec.p_use_for_wp_flag,
                          p_control_flag        => L_plan_res_list_Rec.p_control_flag,
                          --p_migration_code      => 'N',
                          p_record_version_number => L_Plan_res_list_Rec.p_record_version_number,
                          p_resource_list_id    => L_plan_res_list_Rec.p_resource_list_id,
                          x_msg_count           => l_msg_count,
                          x_return_status       => l_return_status,
                          x_msg_data            => l_msg_data);

                    If l_Return_Status <> Fnd_Api.G_Ret_Sts_Success Then
                         x_return_status := Fnd_Api.G_Ret_Sts_Error;
                         x_msg_count := x_msg_count + 1;
                         x_msg_data := l_msg_data;
                         Pa_Utils.Add_Message ('PA', x_msg_data);
                         Rollback ;
                         Return;

                    End If;

                    /************************************************
                     * Check the Commit flag. if it is true then Commit.
                     ************************************************/
                    If l_return_status = Fnd_Api.G_Ret_Sts_Success Then

                         If Fnd_Api.To_Boolean( p_commit ) Then

                                Commit;

                         End If;

                    End If;
             END IF; -- If resource list attributes have changed.
       ELSE
           -- You need the resource list Id for any processing.
           Pa_Utils.Add_Message(
                       P_App_Short_Name => 'PA',
                       P_Msg_Name       => 'PA_INVALID_RES_LIST_ID');

            Raise l_ERROR;
       END IF; -- L_plan_res_list_Rec.p_resource_list_id is not null

     /***************************************************
      * In the case of Resource formats updation is not possible.
      * We can either create/delete resource formats.
      * Deletion is taken care thro another api. So here we are
      * going to create_resource_format using the pl/sql tables
      * P_Plan_RL_Format_Tbl and X_Plan_RL_Format_Tbl passed.
      *****************************************************/
     --SAVEPOINT Update_Resource_List_Pub_A;
     IF L_Plan_RL_Format_Tbl.COUNT > 0 THEN
          For i IN L_Plan_RL_Format_Tbl.first..L_Plan_RL_Format_Tbl.last
          Loop

             -- Validate that the P_RES_FORMAT_ID passed in is valid

             BEGIN

               SELECT 'Y'
               INTO l_exists
               FROM  pa_res_formats_b
               WHERE res_format_id = L_Plan_RL_Format_Tbl(i).P_Res_Format_Id;

             EXCEPTION
               WHEN NO_DATA_FOUND THEN
                    Pa_Utils.Add_Message(
                            P_App_Short_Name => 'PA',
                            P_Msg_Name       => 'PA_INVALID_RES_FORMAT_ID');

                    Raise l_ERROR;

             END;

             Pa_Plan_RL_Formats_Pvt.Create_Plan_RL_Format(
                   P_Res_List_Id           => L_plan_res_list_Rec.p_resource_list_id,
                   P_Res_Format_Id         => L_Plan_RL_Format_Tbl(i).P_Res_Format_Id,
                   X_Plan_RL_Format_Id      => X_Plan_RL_Format_Tbl(i).X_Plan_RL_Format_Id,
                   X_Record_Version_Number  => X_Plan_RL_Format_Tbl(i).X_Record_Version_Number,
                   X_Return_Status          => X_Return_Status,
                   X_Msg_Count              => l_msg_count,
                   X_Msg_Data               => l_msg_data);

              If X_Return_Status <> Fnd_Api.G_Ret_Sts_Success Then

                  l_return_status := Fnd_Api.G_Ret_Sts_Error;
                  x_return_status := Fnd_Api.G_Ret_Sts_Error;
                  x_msg_count := x_msg_count + 1;
                  x_msg_data := l_msg_data;
                  Pa_Utils.Add_Message ('PA', x_msg_data);
                  RollbacK ;
                  Return;

              Else

                  l_return_status := Fnd_Api.G_Ret_Sts_Success;

              End If;

          End Loop;

     END IF; -- L_Plan_RL_Format_Tbl.COUNT > 0


     /************************************************
      * Check the Commit flag. if it is true then Commit.
      ************************************************/
     If l_return_status = Fnd_Api.G_Ret_Sts_Success Then

        If Fnd_Api.To_Boolean( p_commit ) Then

               Commit;

        End If;

     End If;


     --SAVEPOINT Update_Resource_List_Pub_B;
     IF L_planning_resource_in_tbl.COUNT > 0 THEN
     For i IN L_planning_resource_in_tbl.first..L_planning_resource_in_tbl.last
     Loop

        /**********************************************************
        * For each of the resource_list_memeber_id in the table.
        * We'll first check if an entry is present in the
        * pa_resource_list_members table or not.
        * If it is present then we'll call the
        * Pa_Planning_resource_pvt.Update_Planning_Resource api,
        * which would just update the corr record in the table.
        * If it is not present then we'll call the
        * pa_planning_resource_pvt.Create_Planning_Resource api,
        * which would take care of creating the corr record in
        * the table. Once a resource list member is succ created/Updated,
        * we'll commit it in the db.
        ************************************************************/
        /*
        --commented out for bug 4103909
        If L_planning_resource_in_tbl(i).p_resource_list_member_id Is Null Then

            IF l_planning_resource_in_tbl(i).p_resource_alias is null THEN

               Pa_Utils.Add_Message(
                       P_App_Short_Name => 'PA',
                       P_Msg_Name       => 'PA_RLM_ALIAS_AND_ID_NULL');

               Raise l_ERROR;

            END IF;

        End If;

            IF l_old_resource_list_rec.control_flag = 'Y' THEN

               BEGIN
                 SELECT resource_list_member_id,
                        record_version_number
                 INTO L_planning_resource_in_tbl(i).p_resource_list_member_id,
                      l_rlm_record_version_number
                 FROM PA_RESOURCE_LIST_MEMBERS
                 WHERE resource_list_id = l_old_resource_list_rec.resource_list_id
                 AND ALIAS = L_planning_resource_in_tbl(i).p_resource_alias;

                 l_check_exist := 'Y';

               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                      l_check_exist := 'N';
               END;

            ELSE
               BEGIN
                 IF l_planning_resource_in_tbl(i).p_project_id is null THEN
                    l_object_type := 'RESOURCE_LIST';
                    l_object_id   := l_old_resource_list_rec.resource_list_id;
                 ELSE
                    l_object_type := 'PROJECT';
                    l_object_id   := l_planning_resource_in_tbl(i).p_project_id;
                 END IF;

                 SELECT resource_list_member_id,
                        record_version_number
                 INTO l_planning_resource_in_tbl(i).p_resource_list_member_id,
                      l_rlm_record_version_number
                 FROM PA_RESOURCE_LIST_MEMBERS
                 WHERE resource_list_id = l_old_resource_list_rec.resource_list_id
                 AND ALIAS = L_planning_resource_in_tbl(i).p_resource_alias
                 AND object_type = l_object_type
                 AND object_id = l_object_id;

                 l_check_exist := 'Y';

               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                      l_check_exist := 'N';
               END;
            END IF;

        Else
        */ --End of changes for bug 4103909

        If L_planning_resource_in_tbl(i).p_resource_list_member_id Is not Null Then
             Begin
                 Select record_version_number
                 Into l_rlm_record_version_number
                 From pa_resource_list_members
                 Where resource_list_member_id = L_planning_resource_in_tbl(i).p_resource_list_member_id;

             Exception
                 When No_Data_Found Then
                      Pa_Utils.Add_Message(
                                P_App_Short_Name => 'PA',
                                P_Msg_Name       => 'PA_RLM_ID_INVALID');

                      Raise l_ERROR;

             End;

        End If;


        If L_planning_resource_in_tbl(i).p_resource_list_member_id is null Then --For bug 4103909

            -- We need to create the planning resource. First validate the reqd
            -- attributes.

            IF L_planning_resource_in_tbl(i).p_res_format_id IS null THEN
               Pa_Utils.Add_Message(
                                P_App_Short_Name => 'PA',
                                P_Msg_Name       => 'PA_RLM_FORMAT_NULL');

               Raise l_ERROR;
            ELSE
               BEGIN
                 -- derive resource_class_flag
                 SELECT resource_class_flag
                 INTO l_res_class_flag
                 FROM pa_res_formats_b
                 WHERE res_format_id = L_planning_resource_in_tbl(i).p_res_format_id;
               EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                      Pa_Utils.Add_Message(
                                P_App_Short_Name => 'PA',
                                P_Msg_Name       => 'PA_RLM_FORMAT_INVALID');

                      Raise l_ERROR;

               END;

            END IF;


            --For bug 4055082.
            --Raise error if invalid project id is passed while creation of planning resource list memeber.
            IF (L_planning_resource_in_tbl(i).p_project_id is not null) Then --For bug 4094047

               BEGIN

                  SELECT 'Y'
                  INTO l_project_exists
                  FROM pa_projects_all
                  WHERE project_id = L_planning_resource_in_tbl(i).p_project_id;

                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                       Pa_Utils.Add_Message(
                              P_App_Short_Name => 'PA',
                              P_Msg_Name       => 'PA_AMG_PROJECT_ID_INVALID',
                              p_token1         => 'PLAN_RES',
                              p_value1         => Pa_Planning_Resource_Pvt.g_token);

                       Raise l_ERROR;

               END;

             END IF;
             --End of bug 4103909.

            IF (L_planning_resource_in_tbl(i).p_res_format_id is not null) Then --For bug 4103909.

               BEGIN

                  SELECT 'Y'
                  INTO l_format_exists
                  FROM pa_plan_rl_formats
                  WHERE resource_list_id = L_Plan_res_list_Rec.p_resource_list_id
                  AND res_format_id = L_planning_resource_in_tbl(i).p_res_format_id;

                  EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                       Pa_Utils.Add_Message(
                              P_App_Short_Name => 'PA',
                              P_Msg_Name       => 'PA_AMG_FORMAT_NOT_EXISTS',
                              p_token1         => 'PLAN_RES',
                              p_value1         => Pa_Planning_Resource_Pvt.g_token);

                       Raise l_ERROR;

               END;

             END IF;
             --End of bug 4103909.

            SELECT meaning || ' ' || to_char(i) || ':'
            INTO   Pa_Planning_Resource_Pvt.g_token
            FROM   pa_lookups
            WHERE  lookup_type = 'PA_PLANNING_RESOURCE'
            AND    lookup_code = 'PLANNING_RESOURCE';

            L_one_pln_res_in_tbl(1) := L_planning_resource_in_tbl(i);
-- dbms_output.put_line('--- in create part of upd');
            Pa_Plan_Res_List_Pub.Create_Planning_Resource(
                p_commit                    => p_commit,
                p_init_msg_list             => p_init_msg_list,
                p_resource_list_id    => L_plan_res_list_Rec.p_resource_list_id,
                P_planning_resource_in_tbl  => L_one_pln_res_in_tbl,
                X_planning_resource_out_tbl => L_one_pln_res_out_tbl,
                x_return_status             => x_return_status,
                x_msg_count                 => l_msg_count,
                x_error_msg_data            => l_msg_data);
-- dbms_output.put_line('--- AFTER in create part of upd');

/*
             Pa_Planning_Resource_Pvt.Create_Planning_Resource(
                  p_resource_list_member_id => L_planning_resource_in_tbl(i).p_resource_list_member_id,
                  p_resource_list_id       => L_plan_res_list_Rec.p_resource_list_id,
                  p_resource_alias         => L_planning_resource_in_tbl(i).p_resource_alias,
                  p_person_id              => L_planning_resource_in_tbl(i).p_person_id,
                  p_person_name            => L_planning_resource_in_tbl(i).p_person_name,
                  p_job_id                 => L_planning_resource_in_tbl(i).p_job_id,
                  p_job_name               => L_planning_resource_in_tbl(i).p_job_name,
                  p_organization_id        => L_planning_resource_in_tbl(i).p_organization_id,
                  p_organization_name      => L_planning_resource_in_tbl(i).p_organization_name,
                  p_vendor_id              => L_planning_resource_in_tbl(i).p_vendor_id,
                  p_vendor_name            => L_planning_resource_in_tbl(i).p_vendor_name,
                  p_fin_category_name      => L_planning_resource_in_tbl(i).p_fin_category_name,
                  p_non_labor_resource     => L_planning_resource_in_tbl(i).p_non_labor_resource,
                  p_project_role_id        => L_planning_resource_in_tbl(i).p_project_role_id,
                  p_project_role_name      => L_planning_resource_in_tbl(i).p_project_role_name,
                  p_resource_class_id      => L_planning_resource_in_tbl(i).p_resource_class_id,
                  p_resource_class_code    => L_planning_resource_in_tbl(i).p_resource_class_code,
                  p_res_format_id          => L_planning_resource_in_tbl(i).p_res_format_id,
                  p_spread_curve_id        => L_planning_resource_in_tbl(i).p_spread_curve_id,
                  p_etc_method_code        => L_planning_resource_in_tbl(i).p_etc_method_code,
                  p_mfc_cost_type_id       => L_planning_resource_in_tbl(i).p_mfc_cost_type_id,
                  p_copy_from_rl_flag      => Null,
                  p_resource_class_flag    => l_res_class_flag,
                  p_fc_res_type_code       => L_planning_resource_in_tbl(i).p_fc_res_type_code,
                  p_inventory_item_id      => L_planning_resource_in_tbl(i).p_inventory_item_id,
                  p_inventory_item_name    => L_planning_resource_in_tbl(i).p_inventory_item_name,
                  p_item_category_id       => L_planning_resource_in_tbl(i).p_item_category_id,
                  p_item_category_name     => L_planning_resource_in_tbl(i).p_item_category_name,
                  p_migration_code         => 'N',
                  p_attribute_category     => L_planning_resource_in_tbl(i).p_attribute_category,
                  p_attribute1             => L_planning_resource_in_tbl(i).p_attribute1,
                  p_attribute2             => L_planning_resource_in_tbl(i).p_attribute2,
                  p_attribute3             => L_planning_resource_in_tbl(i).p_attribute3,
                  p_attribute4             => L_planning_resource_in_tbl(i).p_attribute4,
                  p_attribute5             => L_planning_resource_in_tbl(i).p_attribute5,
                  p_attribute6             => L_planning_resource_in_tbl(i).p_attribute6,
                  p_attribute7             => L_planning_resource_in_tbl(i).p_attribute7,
                  p_attribute8             => L_planning_resource_in_tbl(i).p_attribute8,
                  p_attribute9             => L_planning_resource_in_tbl(i).p_attribute9,
                  p_attribute10            => L_planning_resource_in_tbl(i).p_attribute10,
                  p_attribute11            => L_planning_resource_in_tbl(i).p_attribute11,
                  p_attribute12            => L_planning_resource_in_tbl(i).p_attribute12,
                  p_attribute13            => L_planning_resource_in_tbl(i).p_attribute13,
                  p_attribute14            => L_planning_resource_in_tbl(i).p_attribute14,
                  p_attribute15            => L_planning_resource_in_tbl(i).p_attribute15,
                  p_attribute16            => L_planning_resource_in_tbl(i).p_attribute16,
                  p_attribute17            => L_planning_resource_in_tbl(i).p_attribute17,
                  p_attribute18            => L_planning_resource_in_tbl(i).p_attribute18,
                  p_attribute19            => L_planning_resource_in_tbl(i).p_attribute19,
                  p_attribute20            => L_planning_resource_in_tbl(i).p_attribute20,
                  p_attribute21            => L_planning_resource_in_tbl(i).p_attribute21,
                  p_attribute22            => L_planning_resource_in_tbl(i).p_attribute22,
                  p_attribute23            => L_planning_resource_in_tbl(i).p_attribute23,
                  p_attribute24            => L_planning_resource_in_tbl(i).p_attribute24,
                  p_attribute25            => L_planning_resource_in_tbl(i).p_attribute25,
                  p_attribute26            => L_planning_resource_in_tbl(i).p_attribute26,
                  p_attribute27            => L_planning_resource_in_tbl(i).p_attribute27,
                  p_attribute28            => L_planning_resource_in_tbl(i).p_attribute28,
                  p_attribute29            => L_planning_resource_in_tbl(i).p_attribute29,
                  p_attribute30            => L_planning_resource_in_tbl(i).p_attribute30,
                  p_person_type_code       => L_planning_resource_in_tbl(i).p_person_type_code,
                  p_bom_resource_id        => L_planning_resource_in_tbl(i).p_bom_resource_id,
                  p_bom_resource_name      => L_planning_resource_in_tbl(i).p_bom_resource_name,
                  p_team_role              => L_planning_resource_in_tbl(i).p_team_role,
                  p_incur_by_res_code      => L_planning_resource_in_tbl(i).p_incur_by_res_code,
                  p_incur_by_res_type      => L_planning_resource_in_tbl(i).p_incur_by_res_type,
                  p_project_id             => L_planning_resource_in_tbl(i).p_project_id,
                  x_resource_list_member_id => X_planning_resource_out_tbl(i).x_resource_list_member_id,
                  x_record_version_number => X_planning_resource_out_tbl(i).x_record_version_number,
                  x_return_status          => x_return_status,
                  x_msg_count              => l_msg_count,
                  x_error_msg_data         => l_msg_data);

*/

-- dbms_output.put_line('after X_return_status IS : ' || X_return_status);
-- dbms_output.put_line('after l_msg_data IS : ' || l_msg_data);
             If X_return_status <> Fnd_Api.G_Ret_Sts_Success THEN

                  l_return_status := Fnd_Api.G_Ret_Sts_Error;
                  x_return_status := Fnd_Api.G_Ret_Sts_Error;
                  x_msg_count := x_msg_count + 1;
                  x_msg_data := l_msg_data;
                  Pa_Utils.Add_Message ('PA', x_msg_data);
                  Rollback ;
                  Return;

              Else

                  l_return_status := Fnd_Api.G_Ret_Sts_Success;
                  X_planning_resource_out_tbl(i) := L_one_pln_res_out_tbl(1);

              End If;

        End If;

        If L_planning_resource_in_tbl(i).p_resource_list_member_id is not null Then  --For bug 4103909
            --This means that the resource list member is already existing and is supposed to be updated.

            SELECT meaning || ' ' || to_char(i) || ':'
            INTO   Pa_Planning_Resource_Pvt.g_token
            FROM   pa_lookups
            WHERE  lookup_type = 'PA_PLANNING_RESOURCE'
            AND    lookup_code = 'PLANNING_RESOURCE';

             -- Validate the record version number passed in.
             IF L_planning_resource_in_tbl(i).p_record_version_number is null OR
                L_planning_resource_in_tbl(i).p_record_version_number <> l_rlm_record_version_number
             THEN
                   Pa_Utils.Add_Message(
                        P_App_Short_Name => 'PA',
                        P_Msg_Name       => 'PA_RLM_REC_VER_NOT_VALID',
                        p_token1         => 'PLAN_RES',
                        p_value1         => Pa_Planning_Resource_Pvt.g_token);

                   Raise l_ERROR;
             END IF;

             Pa_Planning_Resource_Pvt.Update_Planning_Resource(
                  p_resource_list_id       => L_plan_res_list_Rec.p_resource_list_id,
                  p_resource_list_member_id => L_planning_resource_in_tbl(i).p_resource_list_member_id,
                  p_enabled_flag           => L_planning_resource_in_tbl(i).p_enabled_flag,
                  p_resource_alias         => L_planning_resource_in_tbl(i).p_resource_alias,
                  p_spread_curve_id        => L_planning_resource_in_tbl(i).p_spread_curve_id,
                  p_etc_method_code        => L_planning_resource_in_tbl(i).p_etc_method_code,
                  p_mfc_cost_type_id       => L_planning_resource_in_tbl(i).p_mfc_cost_type_id,
                  p_attribute_category     => L_planning_resource_in_tbl(i).p_attribute_category,
                  p_attribute1             => L_planning_resource_in_tbl(i).p_attribute1,
                  p_attribute2             => L_planning_resource_in_tbl(i).p_attribute2,
                  p_attribute3             => L_planning_resource_in_tbl(i).p_attribute3,
                  p_attribute4             => L_planning_resource_in_tbl(i).p_attribute4,
                  p_attribute5             => L_planning_resource_in_tbl(i).p_attribute5,
                  p_attribute6             => L_planning_resource_in_tbl(i).p_attribute6,
                  p_attribute7             => L_planning_resource_in_tbl(i).p_attribute7,
                  p_attribute8             => L_planning_resource_in_tbl(i).p_attribute8,
                  p_attribute9             => L_planning_resource_in_tbl(i).p_attribute9,
                  p_attribute10            => L_planning_resource_in_tbl(i).p_attribute10,
                  p_attribute11            => L_planning_resource_in_tbl(i).p_attribute11,
                  p_attribute12            => L_planning_resource_in_tbl(i).p_attribute12,
                  p_attribute13            => L_planning_resource_in_tbl(i).p_attribute13,
                  p_attribute14            => L_planning_resource_in_tbl(i).p_attribute14,
                  p_attribute15            => L_planning_resource_in_tbl(i).p_attribute15,
                  p_attribute16            => L_planning_resource_in_tbl(i).p_attribute16,
                  p_attribute17            => L_planning_resource_in_tbl(i).p_attribute17,
                  p_attribute18            => L_planning_resource_in_tbl(i).p_attribute18,
                  p_attribute19            => L_planning_resource_in_tbl(i).p_attribute19,
                  p_attribute20            => L_planning_resource_in_tbl(i).p_attribute20,
                  p_attribute21            => L_planning_resource_in_tbl(i).p_attribute21,
                  p_attribute22            => L_planning_resource_in_tbl(i).p_attribute22,
                  p_attribute23            => L_planning_resource_in_tbl(i).p_attribute23,
                  p_attribute24            => L_planning_resource_in_tbl(i).p_attribute24,
                  p_attribute25            => L_planning_resource_in_tbl(i).p_attribute25,
                  p_attribute26            => L_planning_resource_in_tbl(i).p_attribute26,
                  p_attribute27            => L_planning_resource_in_tbl(i).p_attribute27,
                  p_attribute28            => L_planning_resource_in_tbl(i).p_attribute28,
                  p_attribute29            => L_planning_resource_in_tbl(i).p_attribute29,
                  p_attribute30            => L_planning_resource_in_tbl(i).p_attribute30,
                  p_record_version_number  => L_planning_resource_in_tbl(i).p_record_version_number,
                  x_record_version_number => x_planning_resource_out_tbl(i).x_record_version_number,
                  x_return_status         => x_return_status,
                  x_msg_count             => l_msg_count,
                  x_error_msg_data        => l_msg_data);

             If x_return_status <> Fnd_Api.G_Ret_Sts_Success Then

                  l_return_status := Fnd_Api.G_Ret_Sts_Error;
                  x_return_status := Fnd_Api.G_Ret_Sts_Error;
                  x_msg_count := x_msg_count + 1;
                  x_msg_data := l_msg_data;
                  Pa_Utils.Add_Message ('PA', x_msg_data);
                  Rollback ;
                  Return;

             Else

                  l_return_status := Fnd_Api.G_Ret_Sts_Success;

             End If;

        End If;
     End Loop;
     END IF;
     -- Commit only if all records are successful.
        /************************************************
         * Check the Commit flag. if it is true then Commit.
         ************************************************/
        If l_return_status = Fnd_Api.G_Ret_Sts_Success Then

             If Fnd_Api.To_Boolean( p_commit ) Then

                 Commit;

             End If;

        End If;


Exception
    When l_ERROR Then
             l_Msg_Count := Fnd_Msg_Pub.Count_Msg;


             If l_Msg_Count = 1 Then

                  Pa_Interface_Utils_Pub.Get_Messages(
                       P_Encoded       => Fnd_Api.G_False,
                       P_Msg_Index     => 1,
                       P_Msg_Count     => l_Msg_Count,
                       P_Msg_Data      => l_Msg_Data,
                       P_Data          => l_Data,
                       P_Msg_Index_Out => l_Msg_Index_Out);

                  X_Msg_Data       := l_Data;
                  X_Msg_Count      := l_Msg_Count;

              Else

                   X_Msg_Count := l_Msg_Count;

              End If;
              X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
              Rollback;
     When Others Then
        x_return_status := Fnd_Api.G_Ret_Sts_UnExp_Error;
	-- 4537865
	X_Msg_Data :=  SUBSTRB(SQLERRM,1,240);
	X_Msg_Count := X_Msg_Count + 1;
	-- 4537865 : End
        Rollback ;
        Fnd_Msg_Pub.Add_Exc_Msg(
             p_pkg_name              =>  G_PKG_NAME ,
             p_procedure_name        =>  l_api_name);
        Return;

End Update_Resource_List;

/***********************************************************
 * Procedure : Delete_Resource_List
 * Description : AMG API, used to Delete a resource list
 *               and its corresponding members and formats.
 * 		 The detailed information is in the sepc.
 *********************************************************/
PROCEDURE Delete_Resource_List(
       p_commit                     IN           VARCHAR2 := FND_API.G_FALSE,
       p_init_msg_list              IN           VARCHAR2 := FND_API.G_FALSE,
       p_api_version_number         IN           NUMBER,
       P_Res_List_Id                IN           NUMBER   ,
       X_Return_Status              OUT NOCOPY   VARCHAR2,
       X_Msg_Count                  OUT NOCOPY   NUMBER,
       X_Msg_Data                   OUT NOCOPY   VARCHAR2)
IS
l_api_version_number      CONSTANT   NUMBER       := G_API_VERSION_NUMBER;
l_api_name                CONSTANT   VARCHAR2(30) := 'Update_Resource_List';
l_return_status                      Varchar2(30);
l_msg_count                          Number := 0;
l_msg_data                           Varchar2(100);
l_check_exists                       Varchar2(1);
l_exist_res_list                     Varchar2(1);
l_err_code                           Number;
l_res_list_member_id_tbl             SYSTEM.PA_NUM_TBL_TYPE :=
                                     SYSTEM.PA_NUM_TBL_TYPE();
l_res_format_id_tbl                      SYSTEM.PA_NUM_TBL_TYPE :=
                                     SYSTEM.PA_NUM_TBL_TYPE();
l_Plan_rl_format_id_tbl                  SYSTEM.PA_NUM_TBL_TYPE :=
                                     SYSTEM.PA_NUM_TBL_TYPE();
API_ERROR Exception;
BEGIN
Pa_Planning_Resource_Pvt.g_amg_flow := 'Y';
   --Initialize the message stack before starting any further processing.
   IF FND_API.to_boolean( p_init_msg_list )
   THEN
           FND_MSG_PUB.initialize;
   END IF;

   --Initialize the Out Variables.
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_msg_count := 0;

   --Set a Savepoint so that if error occurs at any stage we can
   -- rollback all the changes.
   --SAVEPOINT Delete_Resource_List_Pub;

   --Check for the Compatibility of the API Version
   --This is a must for AMG API's
   --Doubt -- does this have to be done for all the api's/the main one??
   IF NOT FND_API.Compatible_API_Call
          ( l_api_version_number   ,
            p_api_version_number   ,
            l_api_name             ,
            G_PKG_NAME             )
   THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   /* Bug 5490759 - first check whether the list is used so that that
    * error message can be shown first, instead of a cryptic downstream
    * error when trying to delete a format */
   l_err_code := 0;

   PA_GET_RESOURCE.delete_resource_list_ok(
          p_res_list_id, 'Y', l_err_code, l_msg_data);
   IF l_err_code <> 0 THEN
      l_return_status := FND_API.G_RET_STS_ERROR;
      l_msg_count := l_msg_count + 1;
      RAISE API_ERROR;
   END IF;

    /**************************************************
    * Call to the Delete_Planning_Resources procedure
    * to Delete all the members from the pa_resource_list_members
    * table. We are passing a table of resource_list_member_id's
    * to the procedure.
    **************************************************/
    /*****************************************************
     * First Retrieve all the resource list member id's
     * belonging to the resource_list_id passed.
     * Bulk collect into a PL/SQL table l_res_list_member_id_tbl.
     * ******************************************************/
    BEGIN
          SELECT resource_list_member_id
          BULK COLLECT INTO l_res_list_member_id_tbl
          FROM Pa_resource_list_members
          WHERE resource_list_id = p_res_list_id;
    EXCEPTION
    WHEN OTHERS THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    IF l_res_list_member_id_tbl.COUNT > 0 THEN
    FOR i IN l_res_list_member_id_tbl.first.. l_res_list_member_id_tbl.last
    LOOP
      /*******************************************************
      * Call to API Pa_Planning_Resource_Pvt.Delete_Planning_Resource
      * passing the pl/sql table od resource_list_member_id's
      * This API would take care of deletion.
      ********************************************************/
      SELECT meaning || ' ' || to_char(i) || ':'
      INTO   Pa_Planning_Resource_Pvt.g_token
      FROM   pa_lookups
      WHERE  lookup_type = 'PA_PLANNING_RESOURCE'
      AND    lookup_code = 'PLANNING_RESOURCE';

      Pa_Planning_Resource_Pvt.Delete_Planning_Resource(
         p_resource_list_member_id  => l_res_list_member_id_tbl(i),
         x_return_status            => l_return_status,
         x_msg_count                => l_msg_count,
         x_error_msg_data           => l_msg_data);
         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              ROLLBACK ;
              Return;
         END IF;
         IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
             IF FND_API.to_boolean( p_commit )
             THEN
                    COMMIT;
             END IF;
         END IF;
    END LOOP;
    END IF;

    /*****************************************************
     * First Retrieve all the res_format_id's and
     * plan_rl_format_id's belonging to the resource_list_id
     * passed. Bulk collect into a PL/SQL table
     * l_res_format_id_tbl and l_plan_rl_format_id_tbl.
     * ******************************************************/
    BEGIN
          SELECT res_format_id,plan_rl_format_id
          BULK COLLECT INTO l_res_format_id_tbl,l_plan_rl_format_id_tbl
          FROM Pa_Plan_rl_formats
          WHERE resource_list_id = p_res_list_id;
    EXCEPTION
    WHEN OTHERS THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    IF l_res_format_id_tbl.COUNT > 0 THEN
    FOR i IN l_res_format_id_tbl.first..l_res_format_id_tbl.last
    LOOP
    /**************************************************
    * Call to the Pa_Plan_RL_Formats_Pvt.Delete_Plan_RL_Format API
    * to Delete all the formats from the pa_plan_rl_formats
    * table. We are passing table elements
    **************************************************/
    Pa_Plan_RL_Formats_Pvt.Delete_Plan_RL_Format (
        P_Res_List_Id           => P_res_list_id,
        P_Res_Format_Id         => l_res_format_id_tbl(i),
        P_Plan_RL_Format_Id     => l_plan_rl_format_id_tbl(i),
        X_Return_Status         => l_return_status,
        X_Msg_Count             => l_msg_count,
        X_Msg_Data              => l_msg_data);
        --For bug 3810204
        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             ROLLBACK ;
             RAISE API_ERROR;

        END IF;--End of bug 3810204

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             ROLLBACK ;
             Return;
        END IF;

        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
             IF FND_API.to_boolean( p_commit )
             THEN
                    COMMIT;
             END IF;
        END IF;
    END LOOP;
    END IF;

    /*****************************************************
     * Check if the resource_list_id passed exists in the
     * pa_resource_list_members table or in the pa_plan_rl_formats
     * table. If it does then ewe cannot delete the record from
     * the pa_resource_lists_all_bg table, as corr child members
     * are present.
     *****************************************************/
    BEGIN
       SELECT 'Y'
       INTO l_exist_res_list
       FROM DUAL
       WHERE EXISTS
            (SELECT 'Y' from pa_resource_list_members
            WHERE resource_list_id = P_res_list_id
            UNION
            SELECT 'Y' from pa_plan_rl_formats
            WHERE resource_list_id = P_res_list_id);
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        l_exist_res_list := 'N';
    END;

    IF l_exist_res_list = 'Y' THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         ROLLBACK ;
         Return;
    END IF;

    IF l_exist_res_list = 'N' THEN
       -- Call procedure to delete from base and TL tables
       PA_CREATE_RESOURCE.Delete_Plan_Res_List (
        p_resource_list_id      => P_res_list_id,
        X_Return_Status         => l_return_status,
        X_Msg_Count             => l_msg_count,
        X_Msg_Data              => l_msg_data);

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             --For bug 3810204
             ROLLBACK ;
             RAISE API_ERROR;
             --End of bug 3810204
        END IF;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
             ROLLBACK ;
             Return;
        END IF;

        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
           IF FND_API.to_boolean( p_commit ) THEN
              COMMIT;
           END IF;
        END IF;
    END IF;


EXCEPTION
WHEN API_ERROR THEN
        x_return_status := l_return_status;
        X_Msg_Data := l_msg_data;
        x_msg_count := l_msg_count;
        Pa_Utils.Add_Message
                        (P_App_Short_Name  => 'PA',
                         P_Msg_Name        => l_msg_data);

WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- 4537865 : Start
     X_Msg_Data :=  SUBSTRB(SQLERRM,1,240);
     x_msg_count := x_msg_count + 1 ;
     -- 4537865 : End
     ROLLBACK ;
     FND_MSG_PUB.Add_Exc_Msg
                 (   p_pkg_name              =>  G_PKG_NAME ,
                       p_procedure_name        =>  l_api_name
             );
     Return;

END Delete_Resource_List;


/************************************************************
 * Procedure : Create_Plan_RL_Format
 * Description : This procedure is used the pass a Table of
 *               Record, and call the
 *               Pa_Plan_RL_Formats_Pvt.Create_Plan_RL_Format
 *               procedure, which would create the res formats.
 *		 The detailed information is in the spec.
 **************************************************************/
 Procedure Create_Plan_RL_Format(
        p_commit                 IN          VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_init_msg_list          IN          VARCHAR2 DEFAULT FND_API.G_FALSE,
        P_Res_List_Id            IN          Number,
        P_Plan_RL_Format_Tbl     IN          Plan_RL_Format_In_Tbl,
        X_Plan_RL_Format_Tbl     OUT NOCOPY  Plan_RL_Format_Out_Tbl,
        X_Return_Status          OUT NOCOPY  Varchar2,
        X_Msg_Count              OUT NOCOPY  Number,
        X_Msg_Data               OUT NOCOPY  Varchar2)
IS

L_Plan_RL_Format_Tbl Plan_RL_Format_In_Tbl;
INVALID_FMT_ERR      Exception;
l_format_exists      VARCHAR2(1);

 BEGIN

   -- First clear the message stack.
   IF FND_API.to_boolean( p_init_msg_list )
   THEN
           FND_MSG_PUB.initialize;
   END IF;

    x_msg_count :=    0;
    x_return_status   :=    FND_API.G_RET_STS_SUCCESS;

   Convert_Missing_Format_IN_Rec(
                        P_Plan_RL_Format_Tbl => P_Plan_RL_Format_Tbl,
                        X_Plan_RL_Format_Tbl => L_Plan_RL_Format_Tbl);

   /***************************************************************
   * For Loop. To loop through the table of records and
   * Validate each one of them and insert accordingly.
   ****************************************************************/
    FOR i IN 1..P_Plan_RL_Format_Tbl.COUNT
    LOOP

     --For bug 3675288.
     BEGIN

       l_format_exists:='N';

       --Checks if the format is valid one or not.
       -- If 'Y' Then format is valid.

       Select 'Y'
       Into l_format_exists
       From pa_res_formats_b
       Where res_format_id=L_Plan_RL_Format_Tbl(i).P_Res_Format_Id;

     EXCEPTION
       WHEN Others THEN
         l_format_exists:='N';

     END;

       If l_format_exists = 'N' Then

               Raise INVALID_FMT_ERR;

       End If;
       --End of bug 3675288.

       Pa_Plan_RL_Formats_Pvt.Create_Plan_RL_Format(
        P_Res_List_Id            =>P_Res_List_Id,
        P_Res_Format_Id          =>L_Plan_RL_Format_Tbl(i).P_Res_Format_Id,
        X_Plan_RL_Format_Id      =>X_Plan_RL_Format_Tbl(i).X_Plan_RL_Format_Id,
        X_Record_Version_Number  =>
                 X_Plan_RL_Format_Tbl(i).X_Record_Version_Number,
        X_Return_Status          =>x_return_status,
        X_Msg_Count              =>X_Msg_Count,
        X_Msg_Data               =>X_Msg_Data);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS
        THEN
            x_return_status   := FND_API.G_RET_STS_ERROR;
            x_msg_count       := x_msg_count + 1;
            x_msg_data        := x_Msg_Data;
            Rollback;
            Return;
       END IF;
    END LOOP;
        /************************************************
         * Check the Commit flag. if it is true then Commit.
         ************************************************/
           IF FND_API.to_boolean( p_commit )
           THEN
                  COMMIT;
           END IF;
EXCEPTION
WHEN INVALID_FMT_ERR THEN

       x_return_status   := FND_API.G_RET_STS_ERROR;
       x_msg_count       := x_msg_count + 1;
       x_msg_data        := 'PA_AMG_INVALID_FMT_ID';
       Pa_Utils.Add_Message
                        (P_App_Short_Name  => 'PA',
                         P_Msg_Name        => 'PA_AMG_INVALID_FMT_ID');
WHEN OTHERS THEN
       x_return_status   := FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count       := x_msg_count + 1;
       -- 4537865
       x_msg_data        := SUBSTRB(SQLERRM,1,240);
       Fnd_Msg_Pub.Add_Exc_Msg(
                        P_Pkg_Name         => 'Pa_Plan_Res_List_Pub',
                        P_Procedure_Name   => 'Create_Plan_RL_Format',
			P_error_text	   => x_msg_data);
END Create_Plan_RL_Format;
/***************************/

/************************************************************
 * Procedure : Delete_Plan_RL_Format
 * Description : This procedure is used the pass a Table of
 *               Record, and call the
 *               Pa_Plan_RL_Formats_Pvt.Delete_Plan_RL_Format
 *               procedure, which would Delete the res formats.
 * 		 The detailed information is in the spec.
 **************************************************************/
 Procedure Delete_Plan_RL_Format (
        p_commit                 IN          VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_init_msg_list          IN          VARCHAR2 DEFAULT FND_API.G_FALSE,
        P_Res_List_Id            IN          NUMBER DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Plan_RL_Format_Tbl     IN          Plan_RL_Format_In_Tbl ,
        X_Return_Status          OUT  NOCOPY VARCHAR2,
        X_Msg_Count              OUT  NOCOPY NUMBER,
        X_Msg_Data               OUT  NOCOPY VARCHAR2)
 IS

 L_Plan_RL_Format_Tbl Plan_RL_Format_In_Tbl;

  BEGIN
   -- First clear the message stack.
   IF FND_API.to_boolean( p_init_msg_list )
   THEN
           FND_MSG_PUB.initialize;
   END IF;

   Convert_Missing_Format_IN_Rec(
                        P_Plan_RL_Format_Tbl => P_Plan_RL_Format_Tbl,
                        X_Plan_RL_Format_Tbl => L_Plan_RL_Format_Tbl);

   /***************************************************************
   * For Loop. To loop through the table of records and
   * Validate each one of them and Update accordingly.
   ****************************************************************/
    FOR i IN 1..P_Plan_RL_Format_Tbl.COUNT
    LOOP

       Pa_Plan_RL_Formats_pvt.Delete_Plan_RL_Format (
           P_Res_List_Id        =>P_Res_List_Id,
           P_Res_Format_Id      =>L_Plan_RL_Format_Tbl(i).P_Res_Format_Id,
           P_Plan_RL_Format_Id  =>Null,
           X_Return_Status      =>X_Return_Status,
           X_Msg_Count          =>X_Msg_Count,
           X_Msg_Data           =>X_Msg_Data);

    END LOOP;
/************************************************
 * Check the Commit flag. if it is true then Commit.
 ************************************************/
   IF FND_API.to_boolean( p_commit )
   THEN
          COMMIT;
   END IF;
 END Delete_Plan_RL_Format;
/***************************/

/**************************************************************
 * Procedure   : Create_Planning_Resource
 * Description : The purpose of this procedure is to Validate
 *               and create a new planning resource  for a
 *               resource list.
 * 		 The detailed information is in the spec.
 ****************************************************************/
Procedure Create_Planning_Resource(
       p_commit                    IN          VARCHAR2 DEFAULT FND_API.G_FALSE,
       p_init_msg_list             IN          VARCHAR2 DEFAULT FND_API.G_FALSE,
       p_resource_list_id          IN          VARCHAR2,
       P_planning_resource_in_tbl  IN          Planning_Resource_In_Tbl,
       X_planning_resource_out_tbl OUT NOCOPY  Planning_Resource_Out_Tbl,
       x_return_status             OUT NOCOPY  VARCHAR2,
       x_msg_count                 OUT NOCOPY  NUMBER,
       x_error_msg_data            OUT NOCOPY  VARCHAR2  )
Is

l_res_class_flag                Varchar2(1) := Null;
L_Planning_resource_in_tbl      Planning_Resource_In_Tbl;
l_mode                          Number :=0;
l_resource                      Varchar2(100);
l_financial                     Varchar2(100);
l_organization                  Varchar2(100);
l_supplier			Varchar2(100);
l_role                          Varchar2(100);
l_incurred                      Varchar2(100);
FMT_NULL_ERR			Exception;
RESOURCE_CLASS_FMT_ERR		Exception;
RES_CLASS_ID_AND_CODE_NULL	Exception;
FIN_NULL_ERR    		Exception;
FIN_NOT_NULL_ERR    		Exception;
BOM_LAB_N_EQUIP_NULL_ERR        Exception;
NAMED_PER_NULL_ERR              Exception;
ITEM_CAT_NULL_ERR               Exception;
INVEN_ITEM_NULL_ERR             Exception;
JOB_NULL_ERR                    Exception;
PERSON_TYPE_NULL_ERR            Exception;
NON_LABOR_RES_NULL_ERR          Exception;
ORG_NULL_ERR                    Exception;
ORG_NOT_NULL_ERR                Exception;
SUPP_NULL_ERR                   Exception;
SUPP_NOT_NULL_ERR               Exception;
ROLE_NULL_ERR                   Exception;
ROLE_NOT_NULL_ERR               Exception;
INC_NULL_ERR                    Exception;
INC_NOT_NULL_ERR                Exception;
RES_NOT_NULL_ERR                Exception;
TOO_MANY_PMT_FOR_INCUR          Exception;
RES_CODE_INVALID_ERR            Exception;
RES_ID_INVALID_ERR              Exception;
INVALID_PROJECT_ID              Exception;
RES_FORMAT_ID_ERR               Exception;
l_project_exists                Varchar2(1);
l_format_exists                 Varchar2(1);
l_validate_resource_id          Number;
l_validate_resource_code        Number;
P_Plan_res_list_Rec             Plan_Res_List_IN_Rec;

l_count Number;
Begin

Pa_Planning_Resource_Pvt.g_amg_flow := 'Y';
 -- First clear the message stack.
 If Fnd_Api.To_Boolean( P_Init_Msg_List ) Then

      Fnd_Msg_Pub.Initialize;

 End If;


 Convert_Missing_Member_IN_Rec(
                        P_Planning_resource_in_tbl => P_Planning_resource_in_tbl,
                        P_Plan_res_list_Rec        => P_Plan_res_list_Rec,
                        X_Planning_resource_in_tbl => L_Planning_resource_in_tbl,
                        P_Mode                     => l_mode);


 /***************************************************************
 * For Loop. To loop through the table of records and
 * Validate each one of them and insert accordingly.
 **************************************************************/
 For i IN 1..L_Planning_Resource_In_Tbl.Count
 Loop

     SELECT meaning || ' ' || to_char(i) || ':'
     INTO   Pa_Planning_Resource_Pvt.g_token
     FROM   pa_lookups
     WHERE  lookup_type = 'PA_PLANNING_RESOURCE'
     AND    lookup_code = 'PLANNING_RESOURCE';

     savepoint planning_resource_create;

     /*************************************************
     * Assigning Initial values for some of the elements.
     *************************************************/
     x_msg_count     := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     --For bug 3675288.
     IF L_Planning_resource_in_tbl(i).P_Res_Format_Id is NULL THEN

         RAISE FMT_NULL_ERR;

     END IF;

     IF L_Planning_resource_in_tbl(i).P_Resource_Class_Code is NULL THEN
         IF L_Planning_resource_in_tbl(i).P_Resource_Class_id is NULL THEN

            RAISE RES_CLASS_ID_AND_CODE_NULL;

         END IF;
     END IF;

     --For bug 3810000
     IF L_Planning_resource_in_tbl(i).P_Resource_Class_Code is not NULL Then
            select count(*) INTO l_validate_resource_code
            FROM pa_resource_classes_b
            WHERE resource_class_code=L_Planning_resource_in_tbl(i).P_Resource_Class_Code;
            IF l_validate_resource_code <> 0 Then
                 Null;
            Else
                 RAISE RES_CODE_INVALID_ERR;
            END IF;
     END IF;

     IF L_Planning_resource_in_tbl(i).P_Resource_Class_id is not NULL Then
            select count(*) INTO l_validate_resource_id
            FROM pa_resource_classes_b
            WHERE resource_class_id=L_Planning_resource_in_tbl(i).P_Resource_Class_id;
            IF l_validate_resource_id <> 0 Then
                 Null;
            Else
                 RAISE RES_ID_INVALID_ERR;
            END IF;
     END IF;
     --End of bug 3810000

     BEGIN

     SELECT decode(f.RES_TYPE_ENABLED_FLAG, 'Y', t.res_type_code, NULL) ,
            decode(f.FIN_CAT_ENABLED_FLAG, 'Y', 'Financial Category', NULL) ,
            decode(f.ORGN_ENABLED_FLAG, 'Y', 'Organization', NULL) ,
            decode(f.SUPPLIER_ENABLED_FLAG, 'Y', 'Supplier', NULL) ,
            decode(f.ROLE_ENABLED_FLAG, 'Y', 'Role', NULL) ,
            decode(f.INCURRED_BY_ENABLED_FLAG, 'Y', 'Incurred By', NULL)
     INTO
            l_resource,
            l_financial,
            l_organization,
            l_supplier,
            l_role,
            l_incurred
     FROM pa_res_formats_b f, pa_res_types_b t
     WHERE f.res_format_id = L_Planning_resource_in_tbl(i).P_Res_Format_Id
     AND f.RES_TYPE_ID = t.res_type_id(+);

     EXCEPTION WHEN OTHERS THEN
     x_return_status := Fnd_Api.G_Ret_Sts_Error;
     x_msg_count:=1;
     x_error_msg_data := 'PA_PLN_RL_FORMAT_BAD_FMT_ID';
     Pa_Utils.Add_Message
             (P_App_Short_Name  => 'PA',
              P_Msg_Name        => 'PA_PLN_RL_FORMAT_BAD_FMT_ID',
              p_token1          => 'PLAN_RES',
              p_value1          => Pa_Planning_Resource_Pvt.g_token);
     RETURN;
     END;

     IF (L_planning_resource_in_tbl(i).p_res_format_id is not null) Then --For bug 4103909.

        BEGIN

           SELECT 'Y'
           INTO l_format_exists
           FROM pa_plan_rl_formats
           WHERE resource_list_id = p_resource_list_id
           AND res_format_id = L_planning_resource_in_tbl(i).p_res_format_id;

           EXCEPTION
             WHEN NO_DATA_FOUND THEN

                Raise RES_FORMAT_ID_ERR;

        END;

      END IF;
      --End of bug 4103909.


     IF l_resource is not null THEN

        IF l_resource IN ('BOM_LABOR' , 'BOM_EQUIPMENT') THEN
             If L_Planning_resource_in_tbl(i).p_bom_resource_id is Null Then
                 IF  L_Planning_resource_in_tbl(i).p_bom_resource_name is Null Then
                    Raise BOM_LAB_N_EQUIP_NULL_ERR;
                 END IF;
             END IF;
        END IF;

        IF l_resource = 'NAMED_PERSON' THEN
              If L_Planning_resource_in_tbl(i).p_person_id is Null Then
                 IF  L_Planning_resource_in_tbl(i).p_person_name is NULL THEN
                    Raise NAMED_PER_NULL_ERR;
                 End IF;
               End IF;
        End IF;


        If l_resource = 'ITEM_CATEGORY' THEN
              If L_Planning_resource_in_tbl(i).p_item_category_id is NULL THEN
                 IF L_Planning_resource_in_tbl(i).p_item_category_name is NULL THEN
                    Raise ITEM_CAT_NULL_ERR;
                 END IF;
              END IF;
        END IF;

        If l_resource = 'INVENTORY_ITEM' Then
              If L_Planning_resource_in_tbl(i).p_inventory_item_id is NULL THEN
                 IF L_Planning_resource_in_tbl(i).p_inventory_item_name is NULL THEN
                    Raise INVEN_ITEM_NULL_ERR;
                 END IF;
              END IF;
        END IF;

        If l_resource = 'JOB' THEN
               If L_Planning_resource_in_tbl(i).p_job_id is NULL THEN
                 IF L_Planning_resource_in_tbl(i).p_job_name is NULL THEN
                    Raise JOB_NULL_ERR;
                 END IF;
              END IF;
        END IF;

        If l_resource = 'PERSON_TYPE' THEN
                If L_Planning_resource_in_tbl(i).p_person_type_code is NULL THEN
                    Raise PERSON_TYPE_NULL_ERR;
                 END IF;
        END IF;

        If l_resource = 'NON_LABOR_RESOURCE' THEN
              If L_Planning_resource_in_tbl(i).p_non_labor_resource is NULL THEN
                    Raise NON_LABOR_RES_NULL_ERR;
              END IF;
        END IF;

        If l_resource = 'RESOURCE_CLASS' THEN
           Raise RESOURCE_CLASS_FMT_ERR;
        END IF;
     ELSE -- If no Resource segment, make sure no value is passed in
          IF (L_Planning_resource_in_tbl(i).p_bom_resource_id is NOT Null OR
              L_Planning_resource_in_tbl(i).p_bom_resource_name is NOT Null OR
              L_Planning_resource_in_tbl(i).p_non_labor_resource is NOT Null OR
              L_Planning_resource_in_tbl(i).p_item_category_id is NOT Null OR
              L_Planning_resource_in_tbl(i).p_item_category_name is NOT Null OR
              L_Planning_resource_in_tbl(i).p_inventory_item_id is NOT Null OR
              L_Planning_resource_in_tbl(i).p_inventory_item_name is NOT Null OR
              L_Planning_resource_in_tbl(i).p_person_id is NOT Null OR
              L_Planning_resource_in_tbl(i).p_person_name is NOT Null OR
              L_Planning_resource_in_tbl(i).p_job_id is NOT Null OR
              L_Planning_resource_in_tbl(i).p_job_name is NOT Null OR
              L_Planning_resource_in_tbl(i).p_person_type_code is NOT Null)
          THEN
             Raise RES_NOT_NULL_ERR;
          END IF;
    END IF;

    -- Check Incurred By
     IF l_incurred is not NULL THEN
          IF (L_Planning_resource_in_tbl(i).p_incur_by_res_code is Null OR
              L_Planning_resource_in_tbl(i).p_incur_by_res_type is Null) THEN
              Raise INC_NULL_ERR;
          END IF;
     ELSE -- If no Inc By segment, make sure no value is passed in
          IF (L_Planning_resource_in_tbl(i).p_incur_by_res_code is NOT Null OR
              L_Planning_resource_in_tbl(i).p_incur_by_res_type is NOT Null)
          THEN
              Raise INC_NOT_NULL_ERR;
          END IF;
     END IF;

     IF l_financial is not null THEN
          IF (L_Planning_resource_in_tbl(i).p_fc_res_type_code is Null OR
              L_Planning_resource_in_tbl(i).p_fin_category_name is Null) Then
              Raise FIN_NULL_ERR;
          END IF;
     ELSE -- If no Fin Cat segment, make sure no value is passed in
          IF (L_Planning_resource_in_tbl(i).p_fc_res_type_code is NOT Null OR
              L_Planning_resource_in_tbl(i).p_fin_category_name is NOT Null)
          THEN
              Raise FIN_NOT_NULL_ERR;
          END IF;
     END IF;

     IF l_organization is not null THEN
          IF L_Planning_resource_in_tbl(i).p_organization_id is Null Then
             IF L_Planning_resource_in_tbl(i).p_organization_name is Null Then
                    Raise ORG_NULL_ERR;
             End IF;
          END IF;
     ELSE -- If no Org segment, make sure no value is passed in
          IF (L_Planning_resource_in_tbl(i).p_organization_id is NOT Null OR
              L_Planning_resource_in_tbl(i).p_organization_name is NOT Null)
          THEN
              Raise ORG_NOT_NULL_ERR;
          END IF;
     END IF;

     IF l_supplier is not null THEN
          IF L_Planning_resource_in_tbl(i).p_vendor_id is null THEN
             IF L_Planning_resource_in_tbl(i).p_vendor_name is null Then
                    Raise SUPP_NULL_ERR;
             End If;
          END IF;
     ELSE -- If no Supplier segment, make sure no value is passed in
          IF (L_Planning_resource_in_tbl(i).p_vendor_id is NOT Null OR
              L_Planning_resource_in_tbl(i).p_vendor_name is NOT Null)
          THEN
              Raise SUPP_NOT_NULL_ERR;
          END IF;
     END IF;

     IF l_role is not null THEN
          IF L_Planning_resource_in_tbl(i).p_project_role_id is NULL THEN
              IF L_Planning_resource_in_tbl(i).p_project_role_name is Null THEN
                    Raise ROLE_NULL_ERR;
              END IF;
          END IF;
     ELSE -- If no Role segment, make sure no value is passed in
          IF (L_Planning_resource_in_tbl(i).p_project_role_id is NOT Null OR
              L_Planning_resource_in_tbl(i).p_project_role_name is NOT Null OR
              L_Planning_resource_in_tbl(i).p_team_role is NOT Null)
          THEN
              Raise ROLE_NOT_NULL_ERR;
          END IF;
     END IF;
     --End of bug 3675288.

     --For bug 4055082.
     --Raise error if invalid project id is passed while creation of planning resource list memeber.

     IF (L_planning_resource_in_tbl(i).p_project_id is not null) Then --For bug 4094047

        BEGIN

            SELECT 'Y'
            INTO l_project_exists
            FROM pa_projects_all
            WHERE project_id = L_planning_resource_in_tbl(i).p_project_id;

           EXCEPTION
              WHEN NO_DATA_FOUND THEN
                RAISE INVALID_PROJECT_ID;

        END;

     END IF;
     --End of bug 4055082.

     /******************************************************
     * Call to pa_planning_resource_pvt.create_planning_resource
     * which would take care of the validation and creation
     * of the resource list members. The table elements are being passed as
     * parameters.
      ******************************************************/


     -- derive resource_class_flag
     Select resource_class_flag
     Into   l_res_class_flag
     From   pa_res_formats_b
     Where  res_format_id = L_planning_resource_in_tbl(i).p_res_format_id;

     Pa_Planning_Resource_Pvt.Create_Planning_Resource(
          p_resource_list_id        => p_resource_list_id,
          p_resource_list_member_id => L_planning_resource_in_tbl(i).p_resource_list_member_id,
          p_resource_alias      => L_planning_resource_in_tbl(i).p_resource_alias,
          p_person_id           => L_planning_resource_in_tbl(i).p_person_id,
          p_person_name         => L_planning_resource_in_tbl(i).p_person_name,
          p_job_id              => L_planning_resource_in_tbl(i).p_job_id,
          p_job_name            => L_planning_resource_in_tbl(i).p_job_name,
          p_organization_id     => L_planning_resource_in_tbl(i).p_organization_id,
          p_organization_name   => L_planning_resource_in_tbl(i).p_organization_name,
          p_vendor_id           => L_planning_resource_in_tbl(i).p_vendor_id,
          p_vendor_name         => L_planning_resource_in_tbl(i).p_vendor_name,
          p_fin_category_name   => L_planning_resource_in_tbl(i).p_fin_category_name,
          p_non_labor_resource  => L_planning_resource_in_tbl(i).p_non_labor_resource,
          p_project_role_id     => L_planning_resource_in_tbl(i).p_project_role_id,
          p_project_role_name   => L_planning_resource_in_tbl(i).p_project_role_name,
          p_resource_class_id   => L_planning_resource_in_tbl(i).p_resource_class_id,
          p_resource_class_code => L_planning_resource_in_tbl(i).p_resource_class_code,
          p_res_format_id       => L_planning_resource_in_tbl(i).p_res_format_id,
          p_spread_curve_id     => L_planning_resource_in_tbl(i).p_spread_curve_id,
          p_etc_method_code     => L_planning_resource_in_tbl(i).p_etc_method_code,
          p_mfc_cost_type_id    => L_planning_resource_in_tbl(i).p_mfc_cost_type_id,
          p_copy_from_rl_flag   => Null,
          p_resource_class_flag => l_res_class_flag,
          p_fc_res_type_code    => L_planning_resource_in_tbl(i).p_fc_res_type_code,
          p_inventory_item_id   => L_planning_resource_in_tbl(i).p_inventory_item_id,
          p_inventory_item_name => L_planning_resource_in_tbl(i).p_inventory_item_name,
          p_item_category_id    => L_planning_resource_in_tbl(i).p_item_category_id,
          p_item_category_name  => L_planning_resource_in_tbl(i).p_item_category_name,
          p_migration_code      => 'N',
          p_attribute_category  => L_planning_resource_in_tbl(i).p_attribute_category,
          p_attribute1          => L_planning_resource_in_tbl(i).p_attribute1,
          p_attribute2          => L_planning_resource_in_tbl(i).p_attribute2,
          p_attribute3          => L_planning_resource_in_tbl(i).p_attribute3,
          p_attribute4          => L_planning_resource_in_tbl(i).p_attribute4,
          p_attribute5          => L_planning_resource_in_tbl(i).p_attribute5,
          p_attribute6          => L_planning_resource_in_tbl(i).p_attribute6,
          p_attribute7          => L_planning_resource_in_tbl(i).p_attribute7,
          p_attribute8          => L_planning_resource_in_tbl(i).p_attribute8,
          p_attribute9          => L_planning_resource_in_tbl(i).p_attribute9,
          p_attribute10         => L_planning_resource_in_tbl(i).p_attribute10,
          p_attribute11         => L_planning_resource_in_tbl(i).p_attribute11,
          p_attribute12         => L_planning_resource_in_tbl(i).p_attribute12,
          p_attribute13         => L_planning_resource_in_tbl(i).p_attribute13,
          p_attribute14         => L_planning_resource_in_tbl(i).p_attribute14,
          p_attribute15         => L_planning_resource_in_tbl(i).p_attribute15,
          p_attribute16         => L_planning_resource_in_tbl(i).p_attribute16,
          p_attribute17         => L_planning_resource_in_tbl(i).p_attribute17,
          p_attribute18         => L_planning_resource_in_tbl(i).p_attribute18,
          p_attribute19         => L_planning_resource_in_tbl(i).p_attribute19,
          p_attribute20         => L_planning_resource_in_tbl(i).p_attribute20,
          p_attribute21         => L_planning_resource_in_tbl(i).p_attribute21,
          p_attribute22         => L_planning_resource_in_tbl(i).p_attribute22,
          p_attribute23         => L_planning_resource_in_tbl(i).p_attribute23,
          p_attribute24         => L_planning_resource_in_tbl(i).p_attribute24,
          p_attribute25         => L_planning_resource_in_tbl(i).p_attribute25,
          p_attribute26         => L_planning_resource_in_tbl(i).p_attribute26,
          p_attribute27         => L_planning_resource_in_tbl(i).p_attribute27,
          p_attribute28         => L_planning_resource_in_tbl(i).p_attribute28,
          p_attribute29         => L_planning_resource_in_tbl(i).p_attribute29,
          p_attribute30         => L_planning_resource_in_tbl(i).p_attribute30,
          p_person_type_code => L_planning_resource_in_tbl(i).p_person_type_code,
          p_bom_resource_id  => L_planning_resource_in_tbl(i).p_bom_resource_id,
          p_bom_resource_name => L_planning_resource_in_tbl(i).p_bom_resource_name,
          p_team_role         => L_planning_resource_in_tbl(i).p_team_role,
          p_incur_by_res_code => L_planning_resource_in_tbl(i).p_incur_by_res_code,
          p_incur_by_res_type => L_planning_resource_in_tbl(i).p_incur_by_res_type,
          p_project_id        => L_planning_resource_in_tbl(i).p_project_id,
          x_resource_list_member_id => x_planning_resource_out_tbl(i).x_resource_list_member_id,
          x_record_version_number => x_planning_resource_out_tbl(i).x_record_version_number,
          x_return_status     => x_return_status,
          x_msg_count         => x_msg_count  ,
          x_error_msg_data    => x_error_msg_data);


     If x_return_status <> Fnd_Api.G_Ret_Sts_Success Then

       RollBack to planning_resource_create;
       RETURN;

     End If;
 End Loop;

 -- Commit only if all records are successful
 /************************************************
  * Check the Commit flag. if it is true then Commit.
 ***********************************************/
 If Fnd_Api.To_Boolean( P_Commit ) Then

    Commit;

 End If;
    x_return_status := Fnd_Api.G_Ret_Sts_Success;
    x_msg_count     := Fnd_Msg_Pub.Count_Msg;


Exception
   When FMT_NULL_ERR Then
     x_return_status := Fnd_Api.G_Ret_Sts_Error;
     x_msg_count:=1;
     x_error_msg_data := 'PA_AMG_FORMAT_ID_NULL';
     Pa_Utils.Add_Message
             (P_App_Short_Name  => 'PA',
              P_Msg_Name        => 'PA_AMG_FORMAT_ID_NULL',
              p_token1          => 'PLAN_RES',
              p_value1          => Pa_Planning_Resource_Pvt.g_token);
   When RES_FORMAT_ID_ERR Then
     x_return_status := Fnd_Api.G_Ret_Sts_Error;
     x_msg_count:=1;
     x_error_msg_data := 'PA_AMG_FORMAT_NOT_EXISTS';
     Pa_Utils.Add_Message(
                       P_App_Short_Name => 'PA',
                       P_Msg_Name       => 'PA_AMG_FORMAT_NOT_EXISTS',
                       p_token1         => 'PLAN_RES',
                       p_value1         => Pa_Planning_Resource_Pvt.g_token);
   When RES_CLASS_ID_AND_CODE_NULL Then
     x_return_status := Fnd_Api.G_Ret_Sts_Error;
     x_msg_count:=1;
     x_error_msg_data := 'PA_AMG_RESCLS_ID_CODE_NULL';
     Pa_Utils.Add_Message
             (P_App_Short_Name  => 'PA',
              P_Msg_Name        => 'PA_AMG_RESCLS_ID_CODE_NULL',
              p_token1          => 'PLAN_RES',
              p_value1          => Pa_Planning_Resource_Pvt.g_token);
   When RES_CODE_INVALID_ERR Then
     x_return_status := Fnd_Api.G_Ret_Sts_Error;
     x_msg_count:=1;
     x_error_msg_data := 'PA_AMG_RESOURCE_CODE_INVALID';
     Pa_Utils.Add_Message
             (P_App_Short_Name  => 'PA',
              P_Msg_Name        => 'PA_AMG_RESOURCE_CODE_INVALID',
              p_token1          => 'PLAN_RES',
              p_value1          => Pa_Planning_Resource_Pvt.g_token);
   When RES_ID_INVALID_ERR Then
     x_return_status := Fnd_Api.G_Ret_Sts_Error;
     x_msg_count:=1;
     x_error_msg_data := 'PA_AMG_RESOURCE_ID_INVALID';
     Pa_Utils.Add_Message
             (P_App_Short_Name  => 'PA',
              P_Msg_Name        => 'PA_AMG_RESOURCE_ID_INVALID',
              p_token1          => 'PLAN_RES',
              p_value1          => Pa_Planning_Resource_Pvt.g_token);
   When INVALID_PROJECT_ID Then
     x_return_status := Fnd_Api.G_Ret_Sts_Error;
     x_msg_count:=1;
     x_error_msg_data := 'PA_AMG_PROJECT_ID_INVALID';
     Pa_Utils.Add_Message
             (P_App_Short_Name  => 'PA',
              P_Msg_Name        => 'PA_AMG_PROJECT_ID_INVALID',
              p_token1          => 'PLAN_RES',
              p_value1          => Pa_Planning_Resource_Pvt.g_token);
   When NAMED_PER_NULL_ERR Then
     x_return_status := Fnd_Api.G_Ret_Sts_Error;
     x_msg_count:=1;
     x_error_msg_data := 'PA_AMG_NAMED_PER_NULL';
     Pa_Utils.Add_Message
             (P_App_Short_Name  => 'PA',
              P_Msg_Name        => 'PA_AMG_NAMED_PER_NULL',
              p_token1          => 'PLAN_RES',
              p_value1          => Pa_Planning_Resource_Pvt.g_token);
   When BOM_LAB_N_EQUIP_NULL_ERR Then
     x_return_status := Fnd_Api.G_Ret_Sts_Error;
     x_msg_count:=1;
     x_error_msg_data := 'PA_AMG_BOM_NULL';
     Pa_Utils.Add_Message
             (P_App_Short_Name  => 'PA',
              P_Msg_Name        => 'PA_AMG_BOM_NULL',
              p_token1          => 'PLAN_RES',
              p_value1          => Pa_Planning_Resource_Pvt.g_token);
   When ITEM_CAT_NULL_ERR Then
     x_return_status := Fnd_Api.G_Ret_Sts_Error;
     x_msg_count:=1;
     x_error_msg_data := 'PA_AMG_ITEM_CAT_NULL';
     Pa_Utils.Add_Message
             (P_App_Short_Name  => 'PA',
              P_Msg_Name        => 'PA_AMG_ITEM_CAT_NULL',
              p_token1          => 'PLAN_RES',
              p_value1          => Pa_Planning_Resource_Pvt.g_token);
    When INVEN_ITEM_NULL_ERR Then
     x_return_status := Fnd_Api.G_Ret_Sts_Error;
     x_msg_count:=1;
     x_error_msg_data := 'PA_AMG_INV_ITEM_NULL';
     Pa_Utils.Add_Message
             (P_App_Short_Name  => 'PA',
              P_Msg_Name        => 'PA_AMG_INV_ITEM_NULL',
              p_token1          => 'PLAN_RES',
              p_value1          => Pa_Planning_Resource_Pvt.g_token);
    When JOB_NULL_ERR Then
     x_return_status := Fnd_Api.G_Ret_Sts_Error;
     x_msg_count:=1;
     x_error_msg_data := 'PA_AMG_JOB_NULL';
     Pa_Utils.Add_Message
             (P_App_Short_Name  => 'PA',
              P_Msg_Name        => 'PA_AMG_JOB_NULL',
              p_token1          => 'PLAN_RES',
              p_value1          => Pa_Planning_Resource_Pvt.g_token);
   When PERSON_TYPE_NULL_ERR Then
     x_return_status := Fnd_Api.G_Ret_Sts_Error;
     x_msg_count:=1;
     x_error_msg_data := 'PA_AMG_PERSON_TYPE_NULL';
     Pa_Utils.Add_Message
             (P_App_Short_Name  => 'PA',
              P_Msg_Name        => 'PA_AMG_PERSON_TYPE_NULL',
              p_token1          => 'PLAN_RES',
              p_value1          => Pa_Planning_Resource_Pvt.g_token);
   When NON_LABOR_RES_NULL_ERR Then
     x_return_status := Fnd_Api.G_Ret_Sts_Error;
     x_msg_count:=1;
     x_error_msg_data := 'PA_AMG_NON_LABOR_NULL';
     Pa_Utils.Add_Message
             (P_App_Short_Name  => 'PA',
              P_Msg_Name        => 'PA_AMG_NON_LABOR_NULL',
              p_token1          => 'PLAN_RES',
              p_value1          => Pa_Planning_Resource_Pvt.g_token);
   When FIN_NULL_ERR Then
     x_return_status := Fnd_Api.G_Ret_Sts_Error;
     x_msg_count:=1;
     x_error_msg_data := 'PA_AMG_FIN_NULL';
     Pa_Utils.Add_Message
             (P_App_Short_Name  => 'PA',
              P_Msg_Name        => 'PA_AMG_FIN_NULL',
              p_token1          => 'PLAN_RES',
              p_value1          => Pa_Planning_Resource_Pvt.g_token);
   When FIN_NOT_NULL_ERR Then
     x_return_status := Fnd_Api.G_Ret_Sts_Error;
     x_msg_count:=1;
     x_error_msg_data := 'PA_AMG_FIN_NOT_NULL';
     Pa_Utils.Add_Message
             (P_App_Short_Name  => 'PA',
              P_Msg_Name        => 'PA_AMG_FIN_NOT_NULL',
              p_token1          => 'PLAN_RES',
              p_value1          => Pa_Planning_Resource_Pvt.g_token);
   When ORG_NULL_ERR Then
     x_return_status := Fnd_Api.G_Ret_Sts_Error;
     x_msg_count:=1;
     x_error_msg_data := 'PA_AMG_ORG_NULL';
     Pa_Utils.Add_Message
             (P_App_Short_Name  => 'PA',
              P_Msg_Name        => 'PA_AMG_ORG_NULL',
              p_token1          => 'PLAN_RES',
              p_value1          => Pa_Planning_Resource_Pvt.g_token);
   When ORG_NOT_NULL_ERR Then
     x_return_status := Fnd_Api.G_Ret_Sts_Error;
     x_msg_count:=1;
     x_error_msg_data := 'PA_AMG_ORG_NOT_NULL';
     Pa_Utils.Add_Message
             (P_App_Short_Name  => 'PA',
              P_Msg_Name        => 'PA_AMG_ORG_NOT_NULL',
              p_token1          => 'PLAN_RES',
              p_value1          => Pa_Planning_Resource_Pvt.g_token);
   When SUPP_NULL_ERR Then
     x_return_status := Fnd_Api.G_Ret_Sts_Error;
     x_msg_count:=1;
     x_error_msg_data := 'PA_AMG_SUPP_NULL';
     Pa_Utils.Add_Message
             (P_App_Short_Name  => 'PA',
              P_Msg_Name        => 'PA_AMG_SUPP_NULL',
              p_token1          => 'PLAN_RES',
              p_value1          => Pa_Planning_Resource_Pvt.g_token);
   When SUPP_NOT_NULL_ERR Then
     x_return_status := Fnd_Api.G_Ret_Sts_Error;
     x_msg_count:=1;
     x_error_msg_data := 'PA_AMG_SUPP_NOT_NULL';
     Pa_Utils.Add_Message
             (P_App_Short_Name  => 'PA',
              P_Msg_Name        => 'PA_AMG_SUPP_NOT_NULL',
              p_token1          => 'PLAN_RES',
              p_value1          => Pa_Planning_Resource_Pvt.g_token);
   When ROLE_NULL_ERR Then
     x_return_status := Fnd_Api.G_Ret_Sts_Error;
     x_msg_count:=1;
     x_error_msg_data := 'PA_AMG_ROLE_NULL';
     Pa_Utils.Add_Message
             (P_App_Short_Name  => 'PA',
              P_Msg_Name        => 'PA_AMG_ROLE_NULL',
              p_token1          => 'PLAN_RES',
              p_value1          => Pa_Planning_Resource_Pvt.g_token);
   When ROLE_NOT_NULL_ERR Then
     x_return_status := Fnd_Api.G_Ret_Sts_Error;
     x_msg_count:=1;
     x_error_msg_data := 'PA_AMG_ROLE_NOT_NULL';
     Pa_Utils.Add_Message
             (P_App_Short_Name  => 'PA',
              P_Msg_Name        => 'PA_AMG_ROLE_NOT_NULL',
              p_token1          => 'PLAN_RES',
              p_value1          => Pa_Planning_Resource_Pvt.g_token);
   When INC_NULL_ERR Then
     x_return_status := Fnd_Api.G_Ret_Sts_Error;
     x_msg_count:=1;
     x_error_msg_data := 'PA_AMG_INC_NULL';
     Pa_Utils.Add_Message
             (P_App_Short_Name  => 'PA',
              P_Msg_Name        => 'PA_AMG_INC_NULL',
              p_token1          => 'PLAN_RES',
              p_value1          => Pa_Planning_Resource_Pvt.g_token);
   When INC_NOT_NULL_ERR Then
     x_return_status := Fnd_Api.G_Ret_Sts_Error;
     x_msg_count:=1;
     x_error_msg_data := 'PA_AMG_INC_NOT_NULL';
     Pa_Utils.Add_Message
             (P_App_Short_Name  => 'PA',
              P_Msg_Name        => 'PA_AMG_INC_NOT_NULL',
              p_token1          => 'PLAN_RES',
              p_value1          => Pa_Planning_Resource_Pvt.g_token);
   When RES_NOT_NULL_ERR Then
     x_return_status := Fnd_Api.G_Ret_Sts_Error;
     x_msg_count:=1;
     x_error_msg_data := 'PA_AMG_RES_NOT_NULL';
     Pa_Utils.Add_Message
             (P_App_Short_Name  => 'PA',
              P_Msg_Name        => 'PA_AMG_RES_NOT_NULL',
              p_token1          => 'PLAN_RES',
              p_value1          => Pa_Planning_Resource_Pvt.g_token);
   When RESOURCE_CLASS_FMT_ERR Then
     x_return_status := Fnd_Api.G_Ret_Sts_Error;
     x_msg_count:=1;
     x_error_msg_data := 'PA_AMG_RES_CLS_FMT';
     Pa_Utils.Add_Message
             (P_App_Short_Name  => 'PA',
              P_Msg_Name        => 'PA_AMG_RES_CLS_FMT',
              p_token1          => 'PLAN_RES',
              p_value1          => Pa_Planning_Resource_Pvt.g_token);
   When Others Then
     Rollback;
     x_return_status := Fnd_Api.G_Ret_Sts_UnExp_Error;

End Create_Planning_Resource;
/*****************************************************/

/***************************************************
 * Procedure : Update_Planning_Resource
 * Description : The purpose of this procedure is to
 *               Validate and update attributes on an existing
 *               planning resource for a resource list.
 *		 The detailed information is in the spec.
 ******************************************************/
PROCEDURE Update_Planning_Resource
    (p_commit                     IN          VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_init_msg_list              IN          VARCHAR2 DEFAULT FND_API.G_FALSE,
     p_resource_list_id           IN          NUMBER,
     p_enabled_flag               IN          VARCHAR2,
     P_planning_resource_in_tbl   IN          Planning_Resource_In_Tbl,
     X_planning_resource_out_tbl  OUT NOCOPY  Planning_Resource_Out_Tbl,
     x_return_status              OUT NOCOPY  VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_error_msg_data             OUT NOCOPY  VARCHAR2  )

IS

   -- If need to get the resource_list_member_id using the alias then
   -- If control_flag <> 'N' from pa_resource_lists_all_bg this means centralized and only need the
   -- predicates to resource_list_id and alias to get the resource_list_member_id
   -- If the control_flag = 'N' then we need to add predicates for object_type and object_id.
   -- The object_type = 'PROJECT' and the object_id is the project_id.
   Cursor c1(P_Alias       IN Varchar2,
             P_Res_List_Id IN Number,
             P_Prj_Id      IN Number) Is
   Select
          rlm.Resource_List_Member_Id
   From
          Pa_Resource_List_Members rlm,
          Pa_Resource_Lists_All_BG rl
   Where
          rlm.Alias = P_Alias
   And    rlm.Resource_List_Id = P_Res_List_Id
   And    rlm.Resource_List_Id = rl.Resource_List_Id
   And    ( rl.Control_Flag <> 'N' Or
            ( rl.Control_Flag = 'N' And
              rlm.Object_Type = 'PROJECT' And
              rlm.Object_Id   = P_Prj_Id) );

   Cursor c2(P_rlm_Id IN Number) Is
   Select
          Record_Version_Number
   From
          Pa_Resource_List_Members
   Where
          Resource_List_Member_Id = P_rlm_Id;

   l_rlm_id Number := Null;
   l_rec_ver_num Number := Null;

   EXC_NULL_INVALID_DATA     EXCEPTION;

BEGIN

Pa_Planning_Resource_Pvt.g_amg_flow := 'Y';
   -- First clear the message stack.
   If Fnd_Api.To_Boolean( p_init_msg_list ) Then

           Fnd_Msg_Pub.Initialize;

   End If;

   /* Eugene
    *    Add code here to check if resource list id
    *    is passed. If it is not passed, thro an error and return status of ERROR
    */
   If p_resource_list_id is Null Then

       X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
       X_Error_Msg_Data := 'PA_PLN_RES_LIST_ID_IS_NULL';
       x_msg_count := x_msg_count + 1;
       Pa_Utils.Add_Message ('PA', X_Error_Msg_Data);
       Rollback;
       Return;

   End If;

   For i IN 1..P_Planning_Resource_In_Tbl.Count
   Loop

     Begin
     SELECT meaning || ' ' || to_char(i) || ':'
     INTO   Pa_Planning_Resource_Pvt.g_token
     FROM   pa_lookups
     WHERE  lookup_type = 'PA_PLANNING_RESOURCE'
     AND    lookup_code = 'PLANNING_RESOURCE';


      savepoint planning_res_list_update;

      x_msg_count := 0;
      x_return_status :=   Fnd_Api.G_Ret_Sts_Success;

      /* Eugene
       *    Add code here to check if resource list member id is passed. If it is not
       *    passed, derive it from the alias, if alias is passed. If both are not
       *    passed, set the record to status of "ERROR and set the message for the
       *    error. Continue with the loop.
       *    To get the resource list member id from the alias, you will need to check
       *    if the resource list is proj specific.
       */

      If p_planning_resource_in_tbl(i).p_resource_list_member_id Is Null Then

           If P_planning_resource_in_tbl(i).p_resource_alias Is Null Then

                x_return_status := Fnd_Api.G_Ret_Sts_Error;
                Pa_Utils.Add_Message ('PA', 'PA_PLN_RES_LIST_ID_ALIAS_NULL',
                               'PLAN_RES', Pa_Planning_Resource_Pvt.g_token);
                Raise EXC_NULL_INVALID_DATA;

           Else  -- P_planning_resource_in_tbl(i).p_resource_alias Is Not Null

                Open c1(P_Alias       => P_Planning_Resource_In_Tbl(i).P_Resource_Alias,
                        P_Res_List_Id => P_Resource_List_Id,
                        P_Prj_Id      => P_Planning_Resource_In_Tbl(i).P_Project_Id);
                Fetch c1 Into l_rlm_Id;

                If c1%NotFound Then

                     Close c1;
                     x_return_status := Fnd_Api.G_Ret_Sts_Error;
                     Pa_Utils.Add_Message ('PA', 'PA_PLN_RES_LIST_ALIAS_INVAL',
                               'PLAN_RES', Pa_Planning_Resource_Pvt.g_token);
                     RAISE EXC_NULL_INVALID_DATA;

                Else

                     Close c1;

                End If;

           End If;

      Else

           l_rlm_Id := p_planning_resource_in_tbl(i).p_resource_list_member_id;

      End If;

      If p_planning_resource_in_tbl(i).p_record_version_number is Null Then

           x_return_status := Fnd_Api.G_Ret_Sts_Error;
           Pa_Utils.Add_Message ('PA', 'PA_PLN_RESLISTMEM_RECVER_NULL',
                               'PLAN_RES', Pa_Planning_Resource_Pvt.g_token);
           RAISE EXC_NULL_INVALID_DATA;


      Else

           Open c2(l_rlm_id);
           Fetch c2 Into l_rec_ver_num;

           If c2%NotFound Then

                Close c2;
                x_return_status := Fnd_Api.G_Ret_Sts_Error;
                Pa_Utils.Add_Message ('PA', 'PA_PLN_RESLISTMEM_ID_INVAL',
                               'PLAN_RES', Pa_Planning_Resource_Pvt.g_token);
                RAISE EXC_NULL_INVALID_DATA;

           Else

                Close c2;
                If l_rec_ver_num <> p_planning_resource_in_tbl(i).p_record_version_number then

                     x_return_status := Fnd_Api.G_Ret_Sts_Error;
                     Pa_Utils.Add_Message('PA', 'PA_PLN_RESLISTMEM_ALREADY_UPD',
                               'PLAN_RES', Pa_Planning_Resource_Pvt.g_token);
                     RAISE EXC_NULL_INVALID_DATA;

                End If;

           End If;

      End If;

      pa_planning_resource_pvt.Update_Planning_Resource(
           p_resource_list_id   => p_resource_list_id,
           p_resource_list_member_id  => l_rlm_id,
           p_enabled_flag       => p_enabled_flag,
           p_resource_alias     => P_planning_resource_in_tbl(i).p_resource_alias,
           p_spread_curve_id    => P_planning_resource_in_tbl(i).p_spread_curve_id,
           p_etc_method_code    => P_planning_resource_in_tbl(i).p_etc_method_code,
           p_mfc_cost_type_id   => P_planning_resource_in_tbl(i).p_mfc_cost_type_id,
           p_attribute_category => P_planning_resource_in_tbl(i).p_attribute_category,
           p_attribute1         => P_planning_resource_in_tbl(i).p_attribute1,
           p_attribute2         => P_planning_resource_in_tbl(i).p_attribute2,
           p_attribute3         => P_planning_resource_in_tbl(i).p_attribute3,
           p_attribute4         => P_planning_resource_in_tbl(i).p_attribute4,
           p_attribute5         => P_planning_resource_in_tbl(i).p_attribute5,
           p_attribute6         => P_planning_resource_in_tbl(i).p_attribute6,
           p_attribute7         => P_planning_resource_in_tbl(i).p_attribute7,
           p_attribute8         => P_planning_resource_in_tbl(i).p_attribute8,
           p_attribute9         => P_planning_resource_in_tbl(i).p_attribute9,
           p_attribute10        => P_planning_resource_in_tbl(i).p_attribute10,
           p_attribute11        => P_planning_resource_in_tbl(i).p_attribute11,
           p_attribute12        => P_planning_resource_in_tbl(i).p_attribute12,
           p_attribute13        => P_planning_resource_in_tbl(i).p_attribute13,
           p_attribute14        => P_planning_resource_in_tbl(i).p_attribute14,
           p_attribute15        => P_planning_resource_in_tbl(i).p_attribute15,
           p_attribute16        => P_planning_resource_in_tbl(i).p_attribute16,
           p_attribute17        => P_planning_resource_in_tbl(i).p_attribute17,
           p_attribute18        => P_planning_resource_in_tbl(i).p_attribute18,
           p_attribute19        => P_planning_resource_in_tbl(i).p_attribute19,
           p_attribute20        => P_planning_resource_in_tbl(i).p_attribute20,
           p_attribute21        => P_planning_resource_in_tbl(i).p_attribute21,
           p_attribute22        => P_planning_resource_in_tbl(i).p_attribute22,
           p_attribute23        => P_planning_resource_in_tbl(i).p_attribute23,
           p_attribute24        => P_planning_resource_in_tbl(i).p_attribute24,
           p_attribute25        => P_planning_resource_in_tbl(i).p_attribute25,
           p_attribute26        => P_planning_resource_in_tbl(i).p_attribute26,
           p_attribute27        => P_planning_resource_in_tbl(i).p_attribute27,
           p_attribute28        => P_planning_resource_in_tbl(i).p_attribute28,
           p_attribute29        => P_planning_resource_in_tbl(i).p_attribute29,
           p_attribute30        => P_planning_resource_in_tbl(i).p_attribute30,
           p_record_version_number => p_planning_resource_in_tbl(i).p_record_version_number,
           x_record_version_number => x_planning_resource_out_tbl(i).x_record_version_number,
           x_return_status      => x_return_status,
           x_msg_count          => x_msg_count  ,
           x_error_msg_data     => x_error_msg_data);

      If x_return_status <> Fnd_Api.G_Ret_Sts_Success Then

           RollBack to planning_res_list_update;
           Return;

      End If;

     Exception
       When EXC_NULL_INVALID_DATA Then
            x_return_status := Fnd_Api.G_Ret_Sts_Error;
            x_msg_count := x_msg_count + 1;
            RollBack to planning_res_list_update;
            Return;
       When Others Then
            Raise; -- stop processing

     End;
   End Loop;
           /************************************************
            * Check the Commit flag. if it is true then Commit.
            ***********************************************/
           If Fnd_Api.To_Boolean( p_commit ) Then

                Commit;

           End If;

   x_return_status := Fnd_Api.G_Ret_Sts_Success;
   x_msg_count     := Fnd_Msg_Pub.Count_Msg;

Exception
   When Others Then
      Rollback;
      x_return_status := Fnd_Api.G_Ret_Sts_UnExp_Error;

End Update_Planning_Resource;
/************************************/

/*************************************************
 * Procedure : Delete_Planning_Resource
 * Description : The purpose of this procedure is to
 *              delete a planning resource if it is not
 *              being used, else disable it.
 *              Further details in the Body.
 * 		The detailed information is in the spec.
 ***************************************************/
PROCEDURE Delete_Planning_Resource(
         p_resource_list_member_id  IN          SYSTEM.PA_NUM_TBL_TYPE,
         p_commit                   IN          VARCHAR2,
         p_init_msg_list            IN          VARCHAR2,
         x_return_status            OUT NOCOPY  VARCHAR2,
         x_msg_count                OUT NOCOPY  NUMBER,
         x_error_msg_data           OUT NOCOPY  VARCHAR2)

IS
BEGIN
Pa_Planning_Resource_Pvt.g_amg_flow := 'Y';
   -- First clear the message stack.
   IF FND_API.to_boolean( p_init_msg_list )
   THEN
           FND_MSG_PUB.initialize;
   END IF;
  /********************************************
  * To Check if resource_list member is currently being
  * used in a planning transaction.
  * We are checking from pa_resource_assignments table.
  *************************************************/
FOR i in 1..p_resource_list_member_id.COUNT
LOOP
  SELECT meaning || ' ' || to_char(i) || ':'
  INTO   Pa_Planning_Resource_Pvt.g_token
  FROM   pa_lookups
  WHERE  lookup_type = 'PA_PLANNING_RESOURCE'
  AND    lookup_code = 'PLANNING_RESOURCE';

  pa_planning_resource_pvt.delete_planning_resource
         (p_resource_list_member_id =>p_resource_list_member_id(i),
         x_return_status            =>x_return_status,
         x_msg_count                =>x_msg_count,
         x_error_msg_data           =>x_error_msg_data);


END LOOP;
/************************************************
 * Check the Commit flag. if it is true then Commit.
 ***********************************************/
   IF FND_API.to_boolean( p_commit )
   THEN
          COMMIT;
   END IF;
/***************/
END Delete_Planning_Resource;

/******************************************************
 * Procedure  : Init_Create_Resource_List
 * Description : This procedure initializes the global
 *               temporary tables for the resource list,
 *		 resource formats and,
 *               resoure list members.
 *		 The detailed information is in the spec.
 ******************************************************/
PROCEDURE Init_Create_Resource_List
IS
l_api_name   CONSTANT   VARCHAR2(30) :=  'Init_Create_Resource_List';
BEGIN
     FND_MSG_PUB.initialize;

     G_Plan_Res_List_IN_Rec     := G_Res_List_empty_rec;
     G_Plan_Res_List_Out_Rec    := G_Res_List_empty_out_rec;

     G_Plan_RL_format_In_Tbl.DELETE;
     G_Plan_RL_format_Out_Tbl.DELETE;

     G_Planning_resource_In_tbl.DELETE;
     G_Planning_resource_Out_tbl.DELETE;


     G_Plan_RL_Format_tbl_count := 0;
     G_Plan_Resource_tbl_count  := 0;

EXCEPTION
WHEN OTHERS THEN
     FND_MSG_PUB.Add_Exc_Msg
               (   p_pkg_name              =>  G_PKG_NAME  ,
                   p_procedure_name        =>  l_api_name
               );

END Init_Create_Resource_List;
/*****************************/

/******************************************************
 * Procedure  : Init_Update_Resource_List
 * Description : This procedure initializes the global
 *               temporary tables for the resource list,
 *		 resource formats and,
 *               resoure list members.
 *		 The detailed information is in the spec.
 ******************************************************/
PROCEDURE Init_Update_Resource_List
IS
  l_api_name   CONSTANT   VARCHAR2(30) :=  'Init_Update_Resource_List';
BEGIN
     FND_MSG_PUB.initialize;

     G_Plan_Res_List_IN_Rec     := G_Res_List_empty_rec;
     G_Plan_Res_List_Out_Rec    := G_Res_List_empty_out_rec;

     G_Plan_RL_format_In_Tbl.DELETE;
     G_Plan_RL_format_Out_Tbl.DELETE;

     G_Planning_resource_In_tbl.DELETE;
     G_Planning_resource_Out_tbl.DELETE;


     G_Plan_RL_Format_tbl_count := 0;
     G_Plan_Resource_tbl_count  := 0;

EXCEPTION
WHEN OTHERS THEN
     FND_MSG_PUB.Add_Exc_Msg
               (   p_pkg_name              =>  G_PKG_NAME  ,
                   p_procedure_name        =>  l_api_name
               );
END Init_Update_Resource_List;
/*****************************/
/*************************************************
 * Procedure   : Load_Resource_List
 * Description : This procedure loads the resource
 *               list globals.
 *		 The detailed information is in the spec.
 ***********************************************/
PROCEDURE Load_Resource_List
        (p_api_version_number    IN         NUMBER,
         p_resource_list_id      IN         NUMBER       DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
         p_resource_list_name    IN         VARCHAR2,
         p_description           IN         VARCHAR2,
         p_start_date            IN         DATE         DEFAULT SYSDATE,
         p_end_date              IN         DATE         DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
         p_job_group_id          IN         NUMBER,
         p_job_group_name        IN         VARCHAR2     DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_use_for_wp_flag       IN         VARCHAR2     DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_control_flag          IN         VARCHAR2     DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
         p_record_version_number IN         NUMBER       DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
         x_return_status         OUT NOCOPY Varchar2)
IS
l_api_version_number      CONSTANT   NUMBER := G_API_VERSION_NUMBER;
l_api_name                CONSTANT   VARCHAR2(30) := 'Load_Resource_List';
BEGIN
       x_return_status := FND_API.g_ret_sts_success;

        --Standard API Compatibility Call.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number   ,
                                             p_api_version_number   ,
                                             l_api_name             ,
                                             G_PKG_NAME             )
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       G_Plan_Res_List_IN_Rec.p_resource_list_id := p_resource_list_id;
       G_Plan_Res_List_IN_Rec.p_resource_list_name := p_resource_list_name;
       G_Plan_Res_List_IN_Rec.p_description := p_description;
       G_Plan_Res_List_IN_Rec.p_start_date := p_start_date;
       G_Plan_Res_List_IN_Rec.p_end_date := p_end_date;
       G_Plan_Res_List_IN_Rec.p_job_group_id := p_job_group_id;
       G_Plan_Res_List_IN_Rec.p_job_group_name := p_job_group_name;
       G_Plan_Res_List_IN_Rec.p_use_for_wp_flag := p_use_for_wp_flag;
       G_Plan_Res_List_IN_Rec.p_record_version_number :=
                              p_record_version_number;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR
THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Add_Exc_Msg
         (   p_pkg_name              =>  G_PKG_NAME  ,
             p_procedure_name        =>  l_api_name
         );
END Load_Resource_List;


/*************************************************
 * Procedure   : Load_Resource_Format
 * Description : This procedure loads the resource
 *               Format globals.
 *		 The detailed information is in the spec.
 ***********************************************/
PROCEDURE Load_Resource_Format
        (p_api_version_number    IN            Number,
         P_Res_Format_Id         IN            NUMBER DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
         x_return_status         OUT NOCOPY    Varchar2)
IS
l_api_version_number      CONSTANT   NUMBER := G_API_VERSION_NUMBER;
l_api_name                CONSTANT   VARCHAR2(30) := 'Load_Resource_Format';
BEGIN
       x_return_status := FND_API.g_ret_sts_success;

        --Standard API Compatibility Call.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number   ,
                                             p_api_version_number   ,
                                             l_api_name             ,
                                             G_PKG_NAME             )
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

       G_Plan_RL_Format_tbl_count := G_Plan_RL_Format_tbl_count + 1;

       G_Plan_RL_format_In_Tbl(G_Plan_RL_Format_tbl_count).P_Res_Format_Id
                     := P_Res_Format_Id;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR
THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Add_Exc_Msg
         (   p_pkg_name              =>  G_PKG_NAME  ,
             p_procedure_name        =>  l_api_name
         );
END Load_Resource_Format;

/*************************************************
 * Procedure   : Load_Planning_Resource
 * Description : This procedure loads the resource
 *               list members globals.
 *		 The detailed information is in the spec.
 ***********************************************/
PROCEDURE Load_Planning_Resource
     (p_api_version_number      IN            Number,
      p_resource_list_member_id IN            NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
      p_resource_alias          IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_person_id               IN            NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
      p_person_name             IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_job_id                  IN            NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
      p_job_name                IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_organization_id         IN            NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
      p_organization_name       IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_vendor_id               IN            NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
      p_vendor_name             IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_fin_category_name       IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_non_labor_resource      IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_project_role_id         IN            NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
      p_project_role_name       IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_resource_class_id       IN            NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
      p_resource_class_code     IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_res_format_id           IN            NUMBER        ,
      p_spread_curve_id         IN            NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
      p_etc_method_code         IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_mfc_cost_type_id        IN            NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
      p_fc_res_type_code        IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_inventory_item_id       IN            NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
      p_inventory_item_name     IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_item_category_id        IN            NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
      p_item_category_name      IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute_category      IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute1              IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute2              IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute3              IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute4              IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute5              IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute6              IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute7              IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute8              IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute9              IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute10             IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute11             IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute12             IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute13             IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute14             IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute15             IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute16             IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute17             IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute18             IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute19             IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute20             IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute21             IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute22             IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute23             IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute24             IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute25             IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute26             IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute27             IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute28             IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute29             IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_attribute30             IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_person_type_code        IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_bom_resource_id         IN            NUMBER        DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
      p_bom_resource_name       IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_team_role              IN             VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_incur_by_res_code       IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_incur_by_res_type       IN            VARCHAR2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      p_record_version_number   IN            NUMBER,
      p_project_id              IN            NUMBER  ,
      p_enabled_flag            IN            Varchar2      DEFAULT PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
      x_return_status           OUT NOCOPY    Varchar2)
IS
l_api_version_number      CONSTANT   NUMBER := G_API_VERSION_NUMBER;
l_api_name                CONSTANT   VARCHAR2(30) := 'Load_Planning_Resource';
BEGIN
       x_return_status := FND_API.g_ret_sts_success;

        --Standard API Compatibility Call.
        IF NOT FND_API.Compatible_API_Call ( l_api_version_number   ,
                                             p_api_version_number   ,
                                             l_api_name             ,
                                             G_PKG_NAME             )
        THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

      G_Plan_Resource_tbl_count := G_Plan_Resource_tbl_count + 1;

 G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_resource_list_member_id := p_resource_list_member_id;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_resource_alias
                := p_resource_alias;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_person_id
                := p_person_id;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_person_name
                := p_person_name;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_job_id
                := p_job_id;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_job_name
                := p_job_name;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_organization_id
                := p_organization_id;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_organization_name
                := p_organization_name;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_vendor_id
                := p_vendor_id;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_vendor_name
                := p_vendor_name;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_fin_category_name
                := p_fin_category_name;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_non_labor_resource
:= p_non_labor_resource;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_project_role_id
                := p_project_role_id;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_project_role_name
                := p_project_role_name;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_resource_class_id
                := p_resource_class_id;
     G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_resource_class_code  := p_resource_class_code;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_res_format_id
                := p_res_format_id;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_spread_curve_id
                := p_spread_curve_id;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_etc_method_code
                := p_etc_method_code;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_mfc_cost_type_id
                := p_mfc_cost_type_id;
    G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_fc_res_type_code
                := p_fc_res_type_code;
    G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_inventory_item_id
                := p_inventory_item_id;
   G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_inventory_item_name
                := p_inventory_item_name;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_item_category_id
                := p_item_category_id;
     G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_item_category_name
                := p_item_category_name;
    G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_attribute_category
                := p_attribute_category;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_attribute1
                := p_attribute1;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_attribute2
                := p_attribute2;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_attribute3
                := p_attribute3;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_attribute4
                := p_attribute4;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_attribute5
                := p_attribute5;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_attribute6
                := p_attribute6;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_attribute7
                := p_attribute7;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_attribute8
                := p_attribute8;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_attribute9
                := p_attribute9;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_attribute10
                := p_attribute10;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_attribute11
                := p_attribute11;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_attribute12
                := p_attribute12;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_attribute13
                := p_attribute13;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_attribute14
                := p_attribute14;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_attribute15
                := p_attribute15;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_attribute16
                := p_attribute16;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_attribute17
                := p_attribute17;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_attribute18
                := p_attribute18;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_attribute19
                := p_attribute19;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_attribute20
                := p_attribute20;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_attribute21
                := p_attribute21;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_attribute22
                := p_attribute22;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_attribute23
                := p_attribute23;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_attribute24
                := p_attribute24;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_attribute25
                := p_attribute25;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_attribute26
                := p_attribute26;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_attribute27
                := p_attribute27;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_attribute28
                := p_attribute28;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_attribute29
                := p_attribute29;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_attribute30
                := p_attribute30;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_person_type_code
                := p_person_type_code;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_bom_resource_id
                := p_bom_resource_id;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_bom_resource_name
                := p_bom_resource_name;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_team_role
                := p_team_role;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_incur_by_res_code
                := p_incur_by_res_code;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_incur_by_res_type
                := p_incur_by_res_type;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_record_version_number
                := p_record_version_number;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_project_id
                := p_project_id;
      G_Planning_resource_in_tbl(G_Plan_Resource_tbl_count).p_enabled_flag
                := p_enabled_flag;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR
THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         FND_MSG_PUB.Add_Exc_Msg
         (   p_pkg_name              =>  G_PKG_NAME  ,
             p_procedure_name        =>  l_api_name
         );
END Load_Planning_Resource;

/**************************************************
 * Procedure   : Exec_Create_Resource_List
 * Description : This procedure passes the PL/SQL
 *               globals to the Create_Resource_List API.
 *               The API is typically used with the
 *               load-execute-fetch model.
 *		 The detailed information is in spec.
 ***************************************************/
PROCEDURE Exec_Create_Resource_List
(p_commit                  IN         VARCHAR2 := FND_API.G_FALSE,
 p_init_msg_list           IN         VARCHAR2 := FND_API.G_FALSE,
 p_api_version_number      IN         NUMBER,
 x_return_status           OUT NOCOPY VARCHAR2,
 x_msg_count               OUT NOCOPY NUMBER,
 x_msg_data                OUT NOCOPY VARCHAR2 )
IS
    l_api_version_number   CONSTANT NUMBER := G_API_VERSION_NUMBER;
    l_api_name             CONSTANT VARCHAR2(30) := 'Exec_Create_Resource_List';
    l_message_count        NUMBER;
BEGIN
    x_return_status := FND_API.g_ret_sts_success;

     IF NOT FND_API.Compatible_API_Call ( l_api_version_number   ,
                                             p_api_version_number   ,
                                             l_api_name             ,
                                             G_PKG_NAME             )
     THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

        Create_Resource_List
          (p_commit                    => p_commit,
           p_init_msg_list             => p_init_msg_list,
           p_api_version_number        => p_api_version_number,
           P_plan_res_list_Rec         => G_Plan_Res_List_IN_Rec,
           X_plan_res_list_Rec         => G_Plan_Res_List_Out_Rec,
           P_Plan_RL_Format_Tbl        => G_Plan_RL_format_In_Tbl,
           X_Plan_RL_Format_Tbl        => G_Plan_RL_format_Out_Tbl,
           P_planning_resource_in_tbl  => G_Planning_resource_in_tbl,
           X_planning_resource_out_tbl => G_Planning_resource_out_tbl,
           X_Return_Status             => x_return_status ,
           X_Msg_Count                 => x_msg_count,
           X_Msg_Data                  => x_msg_data);

EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       -- 4537865
       x_msg_data        := SUBSTRB(SQLERRM,1,240);
       x_msg_count := 1 ;
       -- 4537865
      FND_MSG_PUB.Add_Exc_Msg
      (   p_pkg_name              =>  G_PKG_NAME  ,
          p_procedure_name        =>  l_api_name
      );
END Exec_Create_Resource_List;
/*****************************/
/**************************************************
 * Procedure   : Exec_Update_Resource_List
 * Description : This procedure passes the PL/SQL
 *               globals to the Update_Resource_List API.
 *               The API is typically used with the
 *               load-execute-fetch model.
 *		 The detailed information is in spec.
 ***************************************************/
PROCEDURE Exec_Update_Resource_List
(p_commit                 IN         VARCHAR2 := FND_API.G_FALSE,
 p_init_msg_list          IN         VARCHAR2 := FND_API.G_FALSE,
 p_api_version_number     IN         NUMBER,
 x_return_status          OUT NOCOPY VARCHAR2,
 x_msg_count              OUT NOCOPY NUMBER,
 x_msg_data               OUT NOCOPY VARCHAR2
 )
IS
    l_api_version_number   CONSTANT NUMBER := G_API_VERSION_NUMBER;
    l_api_name             CONSTANT VARCHAR2(30) := 'Exec_Update_Resource_List';
    l_message_count        NUMBER;
BEGIN
    x_return_status := FND_API.g_ret_sts_success;

    IF NOT FND_API.Compatible_API_Call ( l_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

     Update_Resource_List
          (p_commit                    => p_commit,
           p_init_msg_list             => p_init_msg_list,
           p_api_version_number        => p_api_version_number,
           P_plan_res_list_Rec         => G_Plan_Res_List_IN_Rec,
           X_plan_res_list_Rec         => G_Plan_Res_List_Out_Rec,
           P_Plan_RL_Format_Tbl        => G_Plan_RL_format_In_Tbl,
           X_Plan_RL_Format_Tbl        => G_Plan_RL_format_Out_Tbl,
           P_planning_resource_in_tbl  => G_Planning_resource_in_tbl,
           X_planning_resource_out_tbl => G_Planning_resource_out_tbl,
           X_Return_Status             => x_return_status,
           X_Msg_Count                 => x_msg_count,
           X_Msg_Data                  => x_msg_data);
       -- 4537865 : Included Exception Block
EXCEPTION

WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       x_msg_data        := SUBSTRB(SQLERRM,1,240);
       x_msg_count := 1 ;
      FND_MSG_PUB.Add_Exc_Msg
      (   p_pkg_name              =>  G_PKG_NAME  ,
          p_procedure_name        =>  l_api_name ,
	  p_error_text		  => x_msg_data
      );
END Exec_Update_Resource_List;
/*****************************/
/******************************************************
 * Procedure : Fetch_Resource_List
 * Description : This procedure returns the return status
 *               and the newly created resource_list_id
 *               if any, from a load-execute-fetch cycle.
 *		 The detailed information is in the spec.
 *******************************************************/
PROCEDURE Fetch_Resource_List
(
 p_api_version_number      IN         NUMBER,
 x_return_status           OUT NOCOPY VARCHAR2,
 x_resource_list_id        OUT NOCOPY NUMBER)
IS
l_api_version_number    CONSTANT    NUMBER      := G_API_VERSION_NUMBER;
l_api_name              CONSTANT    VARCHAR2(30):=  'Fetch_Resource_List';
l_msg_count                         INTEGER     :=0;
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF NOT FND_API.Compatible_API_Call ( l_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    x_resource_list_id := G_Plan_Res_List_Out_Rec.X_resource_list_id;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	 -- 4537865 : RESETTING x_resource_list_id also
         x_resource_list_id := NULL ;
WHEN OTHERS THEN
	 -- 4537865 : RESETTING x_resource_list_id also
	 x_resource_list_id := NULL ;

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            FND_MSG_PUB.Add_Exc_Msg
            (   p_pkg_name              =>  G_PKG_NAME  ,
                p_procedure_name        =>  l_api_name
            );
END Fetch_Resource_List;

/******************************************************
 * Procedure : Fetch_Plan_Format
 * Description : This procedure returns the return status
 *               and the newly created Plan_rl_format_id
 *               if any, from a load-execute-fetch cycle.
 *		 The detailed information is in the spec.
 *******************************************************/
PROCEDURE Fetch_Plan_Format
 ( p_api_version_number      IN         NUMBER,
   p_format_index            IN         NUMBER
                    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
   x_return_status           OUT NOCOPY VARCHAR2,
   X_Plan_RL_Format_Id       OUT NOCOPY NUMBER)
IS
l_api_version_number    CONSTANT    NUMBER      := G_API_VERSION_NUMBER;
l_api_name              CONSTANT    VARCHAR2(30):=  'Fetch_Plan_Format';
l_index                 NUMBER;
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF p_format_index = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
         l_index := 1;
    ELSE
         l_index := p_format_index ;
    END IF;

    IF NOT G_Plan_RL_format_In_Tbl.EXISTS(l_index) THEN
         X_Plan_RL_Format_Id := Null;
    ELSE
        X_Plan_RL_Format_Id :=
                  G_Plan_RL_format_Out_Tbl(l_index).X_Plan_RL_Format_Id;
    END IF;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	 -- 4537865 : RESETTING X_Plan_RL_Format_Id also
	X_Plan_RL_Format_Id := NULL ;

WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         -- 4537865 : RESETTING X_Plan_RL_Format_Id also
        X_Plan_RL_Format_Id := NULL ;
            FND_MSG_PUB.Add_Exc_Msg
            (   p_pkg_name              =>  G_PKG_NAME  ,
                p_procedure_name        =>  l_api_name
            );
END Fetch_Plan_Format;

/******************************************************
 * Procedure   : Fetch_Resource_List_Member
 * Description : This procedure returns the return status
 *               and the newly created resource_list_id
 *               if any, from a load-execute-fetch cycle.
 *		 The detailed information is in spec.
 *******************************************************/
PROCEDURE Fetch_Resource_List_Member
 ( p_api_version_number      IN         NUMBER,
   p_member_index            IN         NUMBER
                 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
   x_return_status           OUT NOCOPY VARCHAR2,
   x_resource_list_member_id OUT NOCOPY NUMBER)
IS
l_api_version_number    CONSTANT    NUMBER      := G_API_VERSION_NUMBER;
l_api_name              CONSTANT    VARCHAR2(30):= 'Fetch_Resource_List_Member';
l_index                 NUMBER;
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number   ,
                                         p_api_version_number   ,
                                         l_api_name             ,
                                         G_PKG_NAME             )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF p_member_index = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
         l_index := 1;
    ELSE
         l_index := p_member_index ;
    END IF;

     IF NOT G_Planning_resource_in_tbl.EXISTS(l_index) THEN
         x_resource_list_member_id := NULL;
     ELSE
        x_resource_list_member_id :=
          G_Planning_resource_out_tbl(l_index).x_resource_list_member_id;
     END IF;
-- 4537865
EXCEPTION
	WHEN OTHERS THEN
		x_resource_list_member_id := NULL ;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
                FND_MSG_PUB.Add_Exc_Msg
               (   p_pkg_name              =>  G_PKG_NAME  ,
                   p_procedure_name        =>  l_api_name
                );
		-- Not RAISING because other similar APIs dont have RAISE
END Fetch_Resource_List_Member;

END Pa_Plan_Res_List_Pub;

/
