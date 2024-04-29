--------------------------------------------------------
--  DDL for Package Body PA_RBS_ELEMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RBS_ELEMENTS_PVT" As
/* $Header: PARELEVB.pls 120.1 2008/01/16 20:22:11 amehrotr ship $*/

Procedure Process_RBS_Element (
        P_RBS_Version_Id        IN         Number,
        P_Parent_Element_Id     IN         Number,
        P_Element_Id            IN         Number,
        P_Resource_Type_Id      IN         Number,
        P_Resource_Source_Id    IN         Number,
        P_Order_Number          IN         Number,
        P_Process_Type          IN         Varchar2,
        X_RBS_Element_id        OUT NOCOPY Number,
        X_Error_Msg_Data        OUT NOCOPY Varchar2)

Is

        l_rbs_header_id      NUMBER;

Begin

        Pa_Debug.G_Stage := 'Entering Process_Rbs_Elements() Pvt.';
        Pa_Debug.TrackPath('ADD','Process_Rbs_Elements Pvt');

	If P_Process_Type = 'D' Then

		Pa_Debug.G_Stage := 'Call DeleteRbsElement() procedure.';

                -- We can delete an element in an RBS from the working version
                -- only if none of the previous RBS versions are used in any
                -- allocations rules. If the version is used, we prevent the
                -- delete.
                -- IMP :  We do not check at element level to check whether
                -- it's used for allocations. We prevent any and every deletion,
                -- if the any element of the previous RBS version is used.

                SELECT rbs_header_id
                INTO  l_rbs_header_id
                FROM pa_rbs_versions_b
                WHERE rbs_version_id = p_rbs_version_id;

                IF PA_ALLOC_UTILS.IS_RBS_IN_RULES
                            (p_rbs_id => l_rbs_header_id) = 'Y'
                THEN
                   X_Error_Msg_Data := 'PA_RBS_ELE_USED_IN_ALLOC';
                   Return;
                END IF;

		Pa_Rbs_Elements_Pvt.DeleteRbsElement(
				P_RBS_Version_Id     => P_RBS_Version_Id,
				P_Element_Id         => P_Element_Id,
				X_Error_Msg_Data     => X_Error_Msg_Data);

               X_RBS_Element_id := null;

	ElsIf P_Process_Type = 'U' Then

		Pa_Debug.G_Stage := 'Call UpdateExistingRbsElement() procedure.';
		Pa_Rbs_Elements_Pvt.UpdateExisingRbsElement(
				P_Rbs_Version_Id      => P_Rbs_Version_Id,
				P_Parent_Element_Id   => P_Parent_Element_Id,
				P_Rbs_Element_Id      => P_Element_Id,
				P_Resource_Type_Id    => P_Resource_Type_Id,
				P_Resource_Source_Id  => P_Resource_Source_Id,
				P_Order_Number        => P_Order_Number,
				X_Error_Msg_Data      => X_Error_Msg_Data);


               X_RBS_Element_id := P_Parent_Element_Id;

	Else

		Pa_Debug.G_Stage := 'Call CreateNewRbsElement() procedure.';
                Pa_Rbs_Elements_Pvt.CreateNewRbsElement(
				P_Rbs_Version_Id      => P_Rbs_Version_Id,
                                P_Parent_Element_Id   => P_Parent_Element_Id,
                                P_Rbs_Element_Id      => P_Element_Id,
                                P_Resource_Type_Id    => P_Resource_Type_Id,
                                P_Resource_Source_Id  => P_Resource_Source_Id,
                                P_Order_Number        => P_Order_Number,
	                        X_RBS_Element_id      => X_RBS_Element_id,
                                X_Error_Msg_Data      => X_Error_Msg_Data);

	End If;

        Pa_Debug.G_Stage := 'Leaving Process_Rbs_Elements() Pvt procedure.';
        Pa_Debug.TrackPath('STRIP','Process_Rbs_Elements Pvt');

Exception
	When Others Then
		Raise;

End Process_RBS_Element;

PROCEDURE DeleteRbsElement(
	P_RBS_Version_Id     IN         Number,
	P_Element_Id         IN         Number,
	X_Error_Msg_Data     OUT NOCOPY Varchar2)

IS

  CURSOR c1 (P_Rbs_Elem_Id IN Number) IS
  SELECT     rbs_element_id
  FROM       pa_rbs_elements
  START WITH rbs_element_Id    = p_rbs_elem_id
  CONNECT BY prior rbs_element_id = parent_element_Id;

  CURSOR get_later_sibs(p_rbs_version_id     IN NUMBER,
                        p_del_outline_number IN VARCHAR2,
                        p_parent_id          IN NUMBER) IS
  SELECT     rbs_element_id, outline_number
  FROM       pa_rbs_elements
  WHERE      rbs_version_id = p_rbs_version_id
  AND        parent_element_Id = p_parent_id
  AND        to_number(replace(outline_number, '.')) >
             to_number(replace(p_del_outline_number, '.'))
  ORDER BY   to_number(replace(outline_number, '.'));

  CURSOR get_sib_children (P_Rbs_Elem_Id IN Number) IS
  SELECT     rbs_element_id
  FROM       pa_rbs_elements
  START WITH rbs_element_Id    = p_rbs_elem_id
  CONNECT BY prior rbs_element_id = parent_element_Id;

  l_Id    Number := Null;
  -- Bug 4146317 changes - make sure outline number is still in sync
  l_parent_id              NUMBER := NULL;
  l_parent_outline_number  VARCHAR2(240);
  l_upd_rbs_id             NUMBER := NULL;
  l_upd_outline_number     VARCHAR2(240);
  l_del_outline_number     VARCHAR2(240);

  l_new_last               NUMBER := NULL;
  l_new_outline            VARCHAR2(240);
  l_child_id               NUMBER := NULL;

BEGIN

-- Get the parent ID and parent outline number for the element
-- being deleted.
SELECT parent_element_Id, outline_number
INTO   l_parent_id, l_del_outline_number
FROM   pa_rbs_elements
WHERE  rbs_element_id = P_Element_Id;

SELECT outline_number
INTO   l_parent_outline_number
FROM   pa_rbs_elements
WHERE  rbs_element_id = l_parent_id;

     Pa_Debug.G_Stage := 'Entering DeleteRbsElement().';
     Pa_Debug.TrackPath('ADD','DeleteRbsElement');

     Pa_Debug.G_Stage := 'Call DeleteRbsElement() procedure.';
     IF Pa_Rbs_Elements_Utils.RbsElementExists( P_Element_Id => P_Element_Id ) = 'Y' Then

        Pa_Debug.G_Stage := 'Delete the children elements/nodes using cursor and loop.';
        Open c1(P_Element_Id);
        Loop

           Fetch c1 Into l_id;
           Exit When c1%NotFound;

           Pa_Debug.G_Stage := 'Delete child element/node by calling table handler.';
           Pa_Rbs_Elements_Pkg.Delete_Row(P_Rbs_Element_Id => l_id);


        End Loop;

        Close c1;

     Else  -- The element does not exist

       Pa_Debug.G_Stage := 'Could not find the element/node to delete.';
       Raise No_Data_Found;

     END IF;

-- After the element is deleted, update outline numbers which need
-- to be updated.
-- Select all the siblings which have outline number "greater"
-- than the element being deleted.

OPEN get_later_sibs(p_rbs_version_id     => p_rbs_version_id,
                    p_del_outline_number => l_del_outline_number,
                    p_parent_id          => l_parent_id);
LOOP

   FETCH get_later_sibs INTO l_upd_rbs_id, l_upd_outline_number;
   EXIT WHEN get_later_sibs%NOTFOUND;
   -- decrement the last digit of the outline number by 1
   IF l_parent_outline_number <> '0' THEN
      l_new_last := to_number(replace(l_upd_outline_number,
                                      l_parent_outline_number || '.')) - 1;
      -- create the new outline number using the parent's
      l_new_outline := l_parent_outline_number || '.' || to_char(l_new_last);
   ELSE
      l_new_last := to_number(l_upd_outline_number) - 1;
      l_new_outline := to_char(l_new_last);
   END IF;

   -- update sibling outline number
   UPDATE pa_rbs_elements
   SET    outline_number = l_new_outline
   WHERE  rbs_element_id = l_upd_rbs_id;

   -- Update all the children's outline numbers by replacing the prefix
   -- with the new prefix.
   OPEN get_sib_children(P_Rbs_Elem_Id     => l_upd_rbs_id);
   LOOP

      FETCH get_sib_children INTO l_child_id;
      EXIT WHEN get_sib_children%NOTFOUND;

      -- this update is complicated because say you delete outline number 2
      -- then you need to update 3 to 2 and replace 3 in all the children
      -- of the old 3 to 2.  But a straight replace won't work - it will replace
      -- 3.3.1 to 2.2.1 instead of 2.3.1.  Hence just replace the first
      -- part which is the length of the outline number plus 1 for the '.'
      -- and then append the rest - so you get 2. || 3.1
      UPDATE pa_rbs_elements
      SET    outline_number = replace(substr(outline_number, 1,
                                             length(l_upd_outline_number) + 1),
                                      l_upd_outline_number || '.',
                                      l_new_outline || '.') ||
                        substr(outline_number, length(l_upd_outline_number) + 2)
      WHERE rbs_element_Id    = l_child_id;
   END LOOP;
   CLOSE get_sib_children;

END LOOP;

CLOSE get_later_sibs;

     Pa_Debug.G_Stage := 'Leaving DeleteRbsElement() procedure.';
     Pa_Debug.TrackPath('STRIP','DeleteRbsElement');

EXCEPTION
   When Others Then
        Raise;

END DeleteRbsElement;

PROCEDURE UpdateExisingRbsElement(
	P_Rbs_Version_Id      IN         Number,
	P_Parent_Element_Id   IN         Number,
	P_Rbs_Element_Id      IN         Number,
	P_Resource_Type_Id    IN         Number,
	P_Resource_Source_Id  IN         Number,
	P_Order_Number        IN         Number,
	X_Error_Msg_Data      OUT NOCOPY Varchar2)

IS

	l_Person_Id		Number := Null;
	l_Job_Id		Number := Null;
	l_Organization_Id	Number := Null;
	l_Exp_Type_Id		Number := Null;
	l_Event_Type_Id		Number := Null;
	l_Exp_Cat_Id		Number := Null;
	l_Rev_Cat_Id		Number := Null;
	l_Inv_Item_Id		Number := Null;
	l_Item_Cat_Id		Number := Null;
	l_BOM_Labor_Id		Number := Null;
	l_BOM_Equip_Id		Number := Null;
	l_Non_Labor_Res_Id	Number := Null;
	l_Role_Id		Number := Null;
	l_Person_Type_Id	Number := Null;
	l_Res_Class_Id		Number := Null;
	l_Supplier_Id		Number := Null;
	l_Rbs_Level		Number := Null;
	l_Rule_Flag             Varchar2(1) := Null;
	l_Order_Number		Number := Null;
	l_Rbs_Element_Name_Id   Number := Null;
	l_Element_Identifier    Number := Null;
	l_Outline_Number        Varchar2(240) := Null;
	l_User_Def_Custom1_Id   Number := Null;
        l_User_Def_Custom2_Id   Number := Null;
        l_User_Def_Custom3_Id   Number := Null;
        l_User_Def_Custom4_Id   Number := Null;
        l_User_Def_Custom5_Id   Number := Null;
	l_Mode                  Varchar2(1) := 'U';
        l_Element_Id            Number;

        --For bug 4047578:perf fix
        Cursor Read_Element_Id_c IS
               Select Rbs_Element_Id
               From Pa_Rbs_Elements
               Where Rule_Flag = 'Y'
               Start With Parent_Element_Id = P_Rbs_Element_Id
               Connect By Prior Rbs_Element_Id = Parent_Element_Id;
BEGIN

        Pa_Debug.G_Stage := 'Entering UpdateExisingRbsElement().';
        Pa_Debug.TrackPath('ADD','UpdateExisingRbsElement');

	-- Check if the parent element is valid.
	Pa_Debug.G_Stage := 'Check to see if parent element/node exists.';


        If Pa_Rbs_Elements_Utils.RbsElementExists( P_Element_Id => P_Parent_Element_Id ) = 'Y' Then


		Pa_Debug.G_Stage := 'Call ValidateAndBuildElement() procedure.';
		Pa_Rbs_Elements_Pvt.ValidateAndBuildElement(
        		P_Mode                => l_Mode,
		        P_Rbs_Version_Id      => P_Rbs_Version_Id,
		        P_Parent_Element_Id   => P_Parent_Element_Id,
		        P_Rbs_Element_Id      => P_Rbs_Element_Id,
		        P_Resource_Type_Id    => P_Resource_Type_Id,
		        P_Resource_Source_Id  => P_Resource_Source_Id,
		        P_Order_Number        => P_Order_Number,
		        X_Person_Id           => l_Person_Id,
		        X_Job_Id              => l_Job_Id,
		        X_Organization_Id     => l_Organization_Id,
		        X_Exp_Type_Id         => l_Exp_Type_Id,
		        X_Event_Type_Id       => l_Event_Type_Id,
		        X_Exp_Cat_Id          => l_Exp_Cat_Id,
		        X_Rev_Cat_Id          => l_Rev_Cat_Id,
		        X_Inv_Item_Id         => l_Inv_Item_Id,
		        X_Item_Cat_Id         => l_Item_Cat_Id,
		        X_BOM_Labor_Id        => l_BOM_Labor_Id,
		        X_BOM_Equip_Id        => l_BOM_Equip_Id,
		        X_Non_Labor_Res_Id    => l_Non_Labor_Res_Id,
		        X_Role_Id             => l_Role_Id,
		        X_Person_Type_Id      => l_Person_Type_Id,
		        X_User_Def_Custom1_Id => l_User_Def_Custom1_Id,
		        X_User_Def_Custom2_Id => l_User_Def_Custom2_Id,
		        X_User_Def_Custom3_Id => l_User_Def_Custom3_Id,
		        X_User_Def_Custom4_Id => l_User_Def_Custom4_Id,
		        X_User_Def_Custom5_Id => l_User_Def_Custom5_Id,
		        X_Res_Class_Id        => l_Res_Class_Id,
		        X_Supplier_Id         => l_Supplier_Id,
		        X_Rbs_Level           => l_Rbs_Level,
		        X_Rule_Based_Flag     => l_Rule_Flag,
		        X_Rbs_Element_Name_Id => l_Rbs_Element_Name_Id,
		        X_Order_Number        => l_Order_Number,
		        X_Element_Identifier  => l_Element_Identifier,
	                X_Outline_Number      => l_outline_number,
		        X_Error_Msg_Data      => X_Error_Msg_Data);


		If X_Error_Msg_Data is Null Then

			-- call the table handler to update the record.
			Pa_Debug.G_Stage := 'Call Pa_Rbs_Elements_Pkg.Update_Row() procedure.';
			Pa_Rbs_Elements_Pkg.Update_Row(
               			P_Rbs_Element_Id           => P_Rbs_Element_Id,
				P_Rbs_Element_Name_Id      => l_Rbs_Element_Name_Id,
               			P_Rbs_Version_Id           => P_Rbs_Version_Id,
               			P_Outline_Number           => l_outline_number,
               			P_Order_Number             => l_Order_Number,
               			P_Resource_Type_Id         => P_Resource_Type_Id,
				P_Resource_Source_Id       => P_Resource_Source_Id,
               			P_Person_Id                => l_Person_Id,
               			P_Job_Id                   => l_Job_Id,
               			P_Organization_Id          => l_Organization_Id,
               			P_Expenditure_Type_Id      => l_Exp_Type_Id,
               			P_Event_Type_Id            => l_Event_Type_Id,
               			P_Expenditure_Category_Id  => l_Exp_Cat_Id,
               			P_Revenue_Category_Id      => l_Rev_Cat_Id,
               			P_Inventory_Item_Id        => l_Inv_Item_Id,
               			P_Item_Category_Id         => l_Item_Cat_Id,
               			P_BOM_Labor_Id             => l_BOM_Labor_Id,
               			P_BOM_Equipment_Id         => l_BOM_Equip_Id,
               			P_Non_Labor_Resource_Id    => l_Non_Labor_Res_Id,
               			P_Role_Id                  => l_Role_Id,
               			P_Person_Type_ID           => l_Person_Type_Id,
               			P_Resource_Class_Id        => l_Res_Class_Id,
               			P_Supplier_Id              => l_Supplier_Id,
               			P_Rule_Flag                => l_Rule_Flag,
               			P_Parent_Element_Id        => P_Parent_Element_Id,
               			P_Rbs_Level                => l_Rbs_Level,
               			P_Element_Identifier       => l_Element_Identifier,
               			P_User_Created_Flag        => 'Y',
                                P_User_Defined_Custom1_Id  => l_User_Def_Custom1_Id,
                                P_User_Defined_Custom2_Id  => l_User_Def_Custom2_Id,
                                P_User_Defined_Custom3_Id  => l_User_Def_Custom3_Id,
                                P_User_Defined_Custom4_Id  => l_User_Def_Custom4_Id,
                                P_User_Defined_Custom5_Id  => l_User_Def_Custom5_Id,
               			P_Last_Update_Date         => Pa_Rbs_Elements_Pvt.G_Last_Update_Date,
               			P_Last_Updated_By          => Pa_Rbs_Elements_Pvt.G_Last_Updated_By,
               			P_Last_Update_Login        => Pa_Rbs_Elements_Pvt.G_Last_Update_Login,
               			X_Error_Msg_Data           => X_Error_Msg_Data);


                        If X_Error_Msg_Data Is Null Then

				--Added for Bug fix 3736374
				--We need to update the value of rule flag for all Child nodes below the current node.
				--If rule is changed to instance then all child nodes below it should have
				--rule flag = 'N'.
				--If instance is changed to rule and it is not below any other instance in the
				--hierarchy then all rule nodes below it (that are not under any other instance node)
				--should have rule flag = 'Y'.
				If P_Resource_Source_Id <> -1 Then

					--For bug 4047578:perf fix
                                        OPEN Read_Element_Id_c;
                                        LOOP
                                            FETCH Read_Element_Id_c INTO l_Element_Id;
                                            EXIT WHEN Read_Element_Id_c%NOTFOUND;

					    Update Pa_Rbs_Elements
					    Set Rule_Flag = 'N'
					    Where Rbs_Element_Id =l_Element_Id;

                                        END LOOP;
                                        CLOSE Read_Element_Id_c;

				ElsIf l_Rule_Flag = 'Y' Then
					Update Pa_Rbs_Elements
					Set Rule_Flag = 'Y'
					Where Rbs_Element_Id In ( Select Rbs_Element_Id
								  From Pa_Rbs_Elements
								  Start With Rbs_Element_Id = P_Rbs_Element_Id
								  Connect By Prior Rbs_Element_Id = Parent_Element_Id
								  And Resource_Source_Id = -1 );
				End If; --End of Bug fix 3736374

                                -- Bug 3636175
                                -- This call is to update the elements below the one just updated with the changes made
                                -- so that the mapping for the rbs does not become broken.
                                PA_Debug.G_Stage := 'Call Pa_Rbs_Elements_Pvt.Update_Children_Data() procedure.';
                                Pa_Rbs_Elements_Pvt.Update_Children_Data(
                                       P_Rbs_Element_Id      => P_Rbs_Element_Id,
                                       X_Error_Msg_Data      => X_Error_Msg_Data);

                        End If;


		End If; -- error returned from ResourceNameCheck() procedure

        Else  -- The parent element does not exist

		Pa_Debug.G_Stage := 'Parent element/node does not exists.';
		Raise No_Data_Found;

        End If; -- Pa_Rbs_Elements_Utils.RbsElementExists()

        Pa_Debug.G_Stage := 'Leaving UpdateExisingRbsElement() procedure.';
        Pa_Debug.TrackPath('STRIP','UpdateExisingRbsElement');


EXCEPTION
   WHEN OTHERS THEN
        Raise;

END UpdateExisingRbsElement;

Procedure CreateNewRbsElement(
	P_Rbs_Version_Id     IN         Number,
	P_Parent_Element_Id  IN         Number,
	P_Rbs_Element_Id     IN         Number,
	P_Resource_Type_Id   IN         Number,
	P_Resource_Source_Id IN         Number,
	P_Order_Number       IN         Number,
	X_RBS_Element_id     OUT NOCOPY Number,
	X_Error_Msg_Data     OUT NOCOPY Varchar2)

Is

	l_Person_Id		Number := Null;
	l_Job_Id		Number := Null;
	l_Organization_Id	Number := Null;
	l_Exp_Type_Id		Number := Null;
	l_Event_Type_Id		Number := Null;
	l_Exp_Cat_Id		Number := Null;
	l_Rev_Cat_Id		Number := Null;
	l_Inv_Item_Id		Number := Null;
	l_Item_Cat_Id		Number := Null;
	l_BOM_Labor_Id		Number := Null;
	l_BOM_Equip_Id		Number := Null;
	l_Non_Labor_Res_Id	Number := Null;
	l_Role_Id		Number := Null;
	l_Person_Type_Id	Number := Null;
	l_Res_Class_Id		Number := Null;
	l_Supplier_Id		Number := Null;
	l_Rule_Flag             Varchar2(1) := Null;
	l_Order_Number		Number := Null;
	l_Rbs_Element_Name_Id   Number := Null;
	l_Rbs_Element_Id	Number := Null;
	l_Rbs_Level		Number := Null;
	l_Element_Identifier    Number := Null;
	l_Outline_Number        Varchar2(240) := Null;
        l_User_Def_Custom1_Id   Number := Null;
        l_User_Def_Custom2_Id   Number := Null;
        l_User_Def_Custom3_Id   Number := Null;
        l_User_Def_Custom4_Id   Number := Null;
        l_User_Def_Custom5_Id   Number := Null;
	l_Mode			Varchar2(1) := 'A';

Begin

        Pa_Debug.G_Stage := 'Entering CreateNewRbsElement().';
        Pa_Debug.TrackPath('ADD','CreateNewRbsElement');

	-- Check if the parent element is valid.
	Pa_Debug.G_Stage := 'Check to see if parent element/node exists.';
        If Pa_Rbs_Elements_Utils.RbsElementExists( P_Element_Id => P_Parent_Element_Id ) = 'Y' Then

		Pa_Debug.G_Stage := 'Call ValidateAndBuildElement() procedure.';
		Pa_Rbs_Elements_Pvt.ValidateAndBuildElement(
                        P_Mode                => l_Mode,
                        P_Rbs_Version_Id      => P_Rbs_Version_Id,
                        P_Parent_Element_Id   => P_Parent_Element_Id,
                        P_Rbs_Element_Id      => P_Rbs_Element_Id,
                        P_Resource_Type_Id    => P_Resource_Type_Id,
                        P_Resource_Source_Id  => P_Resource_Source_Id,
                        P_Order_Number        => P_Order_Number,
                        X_Person_Id           => l_Person_Id,
                        X_Job_Id              => l_Job_Id,
                        X_Organization_Id     => l_Organization_Id,
                        X_Exp_Type_Id         => l_Exp_Type_Id,
                        X_Event_Type_Id       => l_Event_Type_Id,
                        X_Exp_Cat_Id          => l_Exp_Cat_Id,
                        X_Rev_Cat_Id          => l_Rev_Cat_Id,
                        X_Inv_Item_Id         => l_Inv_Item_Id,
                        X_Item_Cat_Id         => l_Item_Cat_Id,
                        X_BOM_Labor_Id        => l_BOM_Labor_Id,
                        X_BOM_Equip_Id        => l_BOM_Equip_Id,
                        X_Non_Labor_Res_Id    => l_Non_Labor_Res_Id,
                        X_Role_Id             => l_Role_Id,
                        X_Person_Type_Id      => l_Person_Type_Id,
                        X_User_Def_Custom1_Id => l_User_Def_Custom1_Id,
                        X_User_Def_Custom2_Id => l_User_Def_Custom2_Id,
                        X_User_Def_Custom3_Id => l_User_Def_Custom3_Id,
                        X_User_Def_Custom4_Id => l_User_Def_Custom4_Id,
                        X_User_Def_Custom5_Id => l_User_Def_Custom5_Id,
                        X_Res_Class_Id        => l_Res_Class_Id,
                        X_Supplier_Id         => l_Supplier_Id,
                        X_Rbs_Level           => l_Rbs_Level,
                        X_Rule_Based_Flag     => l_Rule_Flag,
                        X_Rbs_Element_Name_Id => l_Rbs_Element_Name_Id,
                        X_Order_Number        => l_Order_Number,
                        X_Element_Identifier  => l_Element_Identifier,
	                X_Outline_Number      => l_Outline_Number,
                        X_Error_Msg_Data      => X_Error_Msg_Data);

		If X_Error_Msg_Data is Null Then

			-- call the table handler to update the record.
			Pa_Debug.G_Stage := 'Call Pa_Rbs_Elements_Pkg.Insert_Row() procedure.';
			Pa_Rbs_Elements_Pkg.Insert_Row(
				P_Rbs_Element_Name_Id      => l_Rbs_Element_Name_Id,
                		P_Rbs_Version_Id           => P_Rbs_Version_Id,
                		P_Outline_Number           => l_outline_number,
                		P_Order_Number             => l_Order_Number,
                		P_Resource_Type_Id         => P_Resource_Type_Id,
				P_Resource_Source_Id       => P_Resource_Source_Id,
                		P_Person_Id                => l_Person_Id,
                		P_Job_Id                   => l_Job_Id,
                		P_Organization_Id          => l_Organization_Id,
                		P_Expenditure_Type_Id      => l_Exp_Type_Id,
                		P_Event_Type_Id            => l_Event_Type_Id,
                		P_Expenditure_Category_Id  => l_Exp_Cat_Id,
                		P_Revenue_Category_Id      => l_Rev_Cat_Id,
                		P_Inventory_Item_Id        => l_Inv_Item_Id,
                		P_Item_Category_Id         => l_Item_Cat_Id,
                		P_BOM_Labor_Id             => l_BOM_Labor_Id,
                		P_BOM_Equipment_Id         => l_BOM_Equip_Id,
                		P_Non_Labor_Resource_Id    => l_Non_Labor_Res_Id,
                		P_Role_Id                  => l_Role_Id,
                		P_Person_Type_Id           => l_Person_Type_Id,
                		P_Resource_Class_Id        => l_Res_Class_Id,
                		P_Supplier_Id              => l_Supplier_Id,
                		P_Rule_Flag                => l_Rule_Flag,
                		P_Parent_Element_Id        => P_Parent_Element_Id,
                		P_Rbs_Level                => l_Rbs_Level,
                		P_Element_Identifier       => l_Element_Identifier,
                		P_User_Created_Flag        => 'Y',
                        	P_User_Defined_Custom1_Id  => l_User_Def_Custom1_Id,
                        	P_User_Defined_Custom2_Id  => l_User_Def_Custom2_Id,
                        	P_User_Defined_Custom3_Id  => l_User_Def_Custom3_Id,
                        	P_User_Defined_Custom4_Id  => l_User_Def_Custom4_Id,
                        	P_User_Defined_Custom5_Id  => l_User_Def_Custom5_Id,
                		P_Last_Update_Date         => Pa_Rbs_Elements_Pvt.G_Last_Update_Date,
                		P_Last_Updated_By          => Pa_Rbs_Elements_Pvt.G_Last_Updated_By,
                		P_Last_Update_Login        => Pa_Rbs_Elements_Pvt.G_Last_Update_Login,
				P_Creation_Date            => Pa_Rbs_Elements_Pvt.G_Creation_Date,
				P_Created_By		   => Pa_Rbs_Elements_Pvt.G_Created_By,
				X_Rbs_Element_Id	   => X_Rbs_Element_Id,
                		X_Error_Msg_Data           => X_Error_Msg_Data);

		End If; -- error returned from ResourceNameCheck() procedure

        Else  -- The parent element does not exist

		Pa_Debug.G_Stage := 'Parent element/node does not exist.';
                Raise No_Data_Found;

        End If; -- Pa_Rbs_Elements_Utils.RbsElementExists()

        Pa_Debug.G_Stage := 'Leaving CreateNewRbsElement() procedure.';
        Pa_Debug.TrackPath('STRIP','CreateNewRbsElement');

Exception
	When Others Then
		Raise;

End CreateNewRbsElement;

Procedure ValidateAndBuildElement(
	P_Mode		      IN         Varchar2,
	P_Rbs_Version_Id      IN         Number,
	P_Parent_Element_Id   IN         Number,
	P_Rbs_Element_Id      IN         Number,
	P_Resource_Type_Id    IN         Number,
	P_Resource_Source_Id  IN         Number,
	P_Order_Number	      IN         Number,
	X_Person_Id           OUT NOCOPY Number,
	X_Job_Id              OUT NOCOPY Number,
	X_Organization_Id     OUT NOCOPY Number,
	X_Exp_Type_Id         OUT NOCOPY Number,
	X_Event_Type_Id       OUT NOCOPY Number,
	X_Exp_Cat_Id          OUT NOCOPY Number,
	X_Rev_Cat_Id          OUT NOCOPY Number,
	X_Inv_Item_Id         OUT NOCOPY Number,
	X_Item_Cat_Id         OUT NOCOPY Number,
	X_BOM_Labor_Id        OUT NOCOPY Number,
	X_BOM_Equip_Id        OUT NOCOPY Number,
	X_Non_Labor_Res_Id    OUT NOCOPY Number,
	X_Role_Id             OUT NOCOPY Number,
	X_Person_Type_Id      OUT NOCOPY Number,
	X_User_Def_Custom1_Id OUT NOCOPY Number,
        X_User_Def_Custom2_Id OUT NOCOPY Number,
        X_User_Def_Custom3_Id OUT NOCOPY Number,
        X_User_Def_Custom4_Id OUT NOCOPY Number,
        X_User_Def_Custom5_Id OUT NOCOPY Number,
	X_Res_Class_Id        OUT NOCOPY Number,
	X_Supplier_Id         OUT NOCOPY Number,
	X_Rbs_Level           OUT NOCOPY Number,
	X_Rule_Based_Flag     OUT NOCOPY Varchar2,
	X_Rbs_Element_Name_Id OUT NOCOPY Number,
	X_Order_Number	      OUT NOCOPY Number,
	X_Element_Identifier  OUT NOCOPY Number,
	X_Outline_Number      OUT NOCOPY Varchar2,
	X_Error_Msg_Data      OUT NOCOPY Varchar2)

Is

  CURSOR chk_element_exists(p_resource_type_id   IN NUMBER,
                            p_resource_source_id IN NUMBER,
                            p_rbs_element_id     IN NUMBER,
                            P_rbs_level          IN NUMBER)
  IS
    SELECT 'Y', rbs_element_id
    FROM   pa_rbs_elements
    WHERE  resource_type_id = p_resource_type_id
    AND    resource_source_id = p_resource_source_id
    AND    Rbs_Version_Id = P_Rbs_Version_Id
    AND    rbs_element_id <> nvl(p_rbs_element_id, -99)
    AND    rbs_level = P_rbs_level;

  CURSOR chk_element_diff_level(p_resource_type_id   IN NUMBER,
                                p_resource_source_id IN NUMBER,
                                p_rbs_element_id     IN NUMBER)
  IS
    SELECT 'Y'
    FROM   pa_rbs_elements
    WHERE  resource_type_id = p_resource_type_id
    AND    resource_source_id = p_resource_source_id
    AND    Rbs_Version_Id = P_Rbs_Version_Id
    AND    rbs_element_id <> nvl(p_rbs_element_id, -99);

   l_ele_exists        VARCHAR2(1) := 'N';
   l_unique_branch     VARCHAR2(1) := 'N';
   l_exists_element_id NUMBER := NULL;

	l_Resource_Type            Varchar2(30) := Null;
	MAX_USER_DEF_RES_IDS       Exception;
	MAX_RBS_LEVELS             Exception;
	NON_UNIQUE_BRANCH          Exception;
	GET_ELEMENT_NAME_ID_FAILED Exception;
	CANNOT_CREATE_RULES 	   Exception;
	l_Dummy_Error_Status       Varchar2(1)  := Null;
	l_Dummy_Error_Count        Number       := Null;
        l_number_of_peers          NUMBER;
        l_o_number                 NUMBER;
        l_old_resource_type_id     NUMBER       := null;
        l_old_resource_source_id   NUMBER       := null;
	l_use_for_alloc_flag	   VARCHAR2(1)  := Null; --Bug 3725965

Begin
-- hr_utility.trace_on(NULL, 'RMRBS');
-- hr_utility.trace('******** START ******* ');
--dbms_output.put_line('******** START *******');

        Pa_Debug.G_Stage := 'Entering ValidateAndBuildElement().';
        Pa_Debug.TrackPath('ADD','ValidateAndBuildElement');

        IF p_mode = 'U' THEN
           -- Get the old Resource Type Id and Resource Source Id for
           -- the element.
           SELECT resource_type_id,
                  resource_source_id
           INTO   l_old_resource_type_id,
                  l_old_resource_source_id
           FROM   PA_RBS_ELEMENTS
           WHERE  rbs_element_id = p_rbs_element_id;
        END IF;

	Pa_Debug.G_Stage := 'Call ValidateRbsElement() procedure.';
--dbms_output.put_line('before ValidateRbsElement');
        Pa_Rbs_Elements_Pvt.ValidateRbsElement(
		P_Mode		          => P_Mode,
                P_Rbs_Version_Id          => P_Rbs_Version_Id,
                P_Parent_Element_Id       => P_Parent_Element_Id,
                P_Rbs_Element_Id          => P_Rbs_Element_Id,
                P_Old_Resource_Type_Id    => l_Old_Resource_Type_Id,
                P_Old_Resource_Source_Id  => l_Old_Resource_Source_Id,
                P_Resource_Type_Id        => P_Resource_Type_Id,
                P_Resource_Source_Id      => P_Resource_Source_Id,
		X_Resource_Type           => l_Resource_Type,
                X_Error_Msg_Data          => X_Error_Msg_Data);

--dbms_output.put_line('after ValidateRbsElement');
        If X_Error_Msg_Data is Null Then

		Pa_Debug.G_Stage := 'Call GetParentRbsData() procedure.';
--dbms_output.put_line('before GetParentRbsData');
		Pa_Rbs_Elements_Pvt.GetParentRbsData(
			P_Parent_Element_Id   => P_Parent_Element_Id,
			X_Person_Id           => X_Person_Id,
			X_Job_Id              => X_Job_Id,
			X_Organization_Id     => X_Organization_Id,
			X_Exp_Type_Id         => X_Exp_Type_Id,
			X_Event_Type_Id       => X_Event_Type_Id,
			X_Exp_Cat_Id          => X_Exp_Cat_Id,
			X_Rev_Cat_Id          => X_Rev_Cat_Id,
			X_Inv_Item_Id         => X_Inv_Item_Id,
			X_Item_Cat_Id         => X_Item_Cat_Id,
			X_BOM_Labor_Id        => X_BOM_Labor_Id,
			X_BOM_Equip_Id        => X_BOM_Equip_Id,
			X_Non_Labor_Res_Id    => X_Non_Labor_Res_Id,
			X_Role_Id             => X_Role_Id,
			X_Person_Type_Id      => X_Person_Type_Id,
        		X_User_Def_Custom1_Id => X_User_Def_Custom1_Id,
        		X_User_Def_Custom2_Id => X_User_Def_Custom2_Id,
        		X_User_Def_Custom3_Id => X_User_Def_Custom3_Id,
        		X_User_Def_Custom4_Id => X_User_Def_Custom4_Id,
        		X_User_Def_Custom5_Id => X_User_Def_Custom5_Id,
			X_Res_Class_Id        => X_Res_Class_Id,
			X_Supplier_Id         => X_Supplier_Id,
			X_Rbs_Level           => X_Rbs_Level,
			X_Outline_Number      => X_Outline_Number);
--dbms_output.put_line('after GetParentRbsData');

		If l_Resource_Type = 'BOM_LABOR' Then

			Pa_Debug.G_Stage := 'Assign the resource source id to BOM Labor.';
			X_BOM_Labor_Id := P_Resource_Source_Id;

		Elsif l_Resource_Type = 'BOM_EQUIPMENT' Then

			Pa_Debug.G_Stage := 'Assign the resource source id to BOM Equipment.';
			X_BOM_Equip_Id := P_Resource_Source_Id;

		Elsif l_Resource_Type = 'NAMED_PERSON' Then

			Pa_Debug.G_Stage := 'Assign the resource source id to Named Person.';
			X_Person_Id := P_Resource_Source_Id;

		Elsif l_Resource_Type = 'EVENT_TYPE' Then

			Pa_Debug.G_Stage := 'Assign the resource source id to Event Type.';
			X_Event_Type_Id := P_Resource_Source_Id;

		Elsif l_Resource_Type = 'EXPENDITURE_CATEGORY' Then

			Pa_Debug.G_Stage := 'Assign the resource source id to Expenditure Category.';
			X_Exp_Cat_Id := P_Resource_Source_Id;

		Elsif l_Resource_Type = 'EXPENDITURE_TYPE' Then

			Pa_Debug.G_Stage := 'Assign the resource source id to Expenditure Type.';
			X_Exp_Type_Id := P_Resource_Source_Id;

		Elsif l_Resource_Type = 'ITEM_CATEGORY' Then

			Pa_Debug.G_Stage := 'Assign the resource source id to Item Category.';
			X_Item_Cat_Id := P_Resource_Source_Id;

		Elsif l_Resource_Type = 'INVENTORY_ITEM' Then

			Pa_Debug.G_Stage := 'Assign the resource source id to Inventory Item.';
			X_Inv_Item_Id := P_Resource_Source_Id;

		Elsif l_Resource_Type = 'JOB' Then

			Pa_Debug.G_Stage := 'Assign the resource source id to Job.';
			X_Job_Id := P_Resource_Source_Id;

		Elsif l_Resource_Type = 'ORGANIZATION' Then

			Pa_Debug.G_Stage := 'Assign the resource source id to Organization.';
			X_Organization_Id := P_Resource_Source_Id;

		Elsif l_Resource_Type = 'PERSON_TYPE' Then

			Pa_Debug.G_Stage := 'Assign the resource source id to Person Type.';
			X_Person_Type_Id := P_Resource_Source_Id;

		Elsif l_Resource_Type = 'NON_LABOR_RESOURCE' Then

			Pa_Debug.G_Stage := 'Assign the resource source id to Non Labor Resource.';
			X_Non_Labor_Res_Id := P_Resource_Source_Id;

		Elsif l_Resource_Type = 'RESOURCE_CLASS' Then

			Pa_Debug.G_Stage := 'Assign the resource source id to Resource Class.';
			X_Res_Class_Id := P_Resource_Source_Id;

		Elsif l_Resource_Type = 'REVENUE_CATEGORY' Then

			Pa_Debug.G_Stage := 'Assign the resource source id to Revenue Category.';
			X_Rev_Cat_Id := P_Resource_Source_Id;

		Elsif l_Resource_Type = 'ROLE' Then

			Pa_Debug.G_Stage := 'Assign the resource source id to Role.';
			X_Role_Id := P_Resource_Source_Id;

		Elsif l_Resource_Type = 'SUPPLIER' Then

			Pa_Debug.G_Stage := 'Assign the resource source id to Supplier.';
			X_Supplier_Id := P_Resource_Source_Id;

		Elsif l_Resource_Type = 'USER_DEFINED' Then

			Pa_Debug.G_Stage := 'Assign the resource source id to User Defined.';
			If X_User_Def_Custom1_Id Is Null Then

				Pa_Debug.G_Stage := 'Assign the resource source id to User Defined 1.';
				X_User_Def_Custom1_Id := P_Resource_Source_Id;

			ElsIf X_User_Def_Custom2_Id Is Null Then

				Pa_Debug.G_Stage := 'Assign the resource source id to User Defined 2.';
				X_User_Def_Custom2_Id := P_Resource_Source_Id;

                	ElsIf X_User_Def_Custom3_Id Is Null Then

				Pa_Debug.G_Stage := 'Assign the resource source id to User Defined 3.';
                		X_User_Def_Custom3_Id := P_Resource_Source_Id;

                	ElsIf X_User_Def_Custom4_Id Is Null Then

				Pa_Debug.G_Stage := 'Assign the resource source id to User Defined 4.';
                        	X_User_Def_Custom4_Id := P_Resource_Source_Id;

                	ElsIf X_User_Def_Custom5_Id Is Null Then

				Pa_Debug.G_Stage := 'Assign the resource source id to User Defined 5.';
               	         	X_User_Def_Custom5_Id := P_Resource_Source_Id;

			Else

				Pa_Debug.G_Stage := 'All user defined resources field populated.';
				Raise MAX_USER_DEF_RES_IDS;

			End If;

		End If;

                -- set the value for the rule flag
		--Modified for bug fix 3736374.
		--Rule flag is set 'N' for an instance based node and all RBS nodes
		--(both rule and instance-based) below it.
		--Top most node of an RBS has rule flag = 'N'.
		Pa_Debug.G_Stage := 'Determine the rule based flag.';
--dbms_output.put_line('get rule based flag');
                Select
                        Decode(r.parent_element_id,null,Decode(P_Resource_Source_Id,-1,'Y','N'),
				Decode(r.rule_flag,'Y',Decode(P_Resource_Source_Id,-1,'Y','N'),'N'))
                Into
                        X_Rule_Based_Flag
                From
                        pa_rbs_elements r
		Where
			r.rbs_element_id = P_Parent_Element_Id; --End of bug fix 3736374.

--dbms_output.put_line('after get rule based flag');
		-- Need to increment the Rbs Level for the child we got
		-- the value from the parent.
		Pa_Debug.G_Stage := 'Increment the rbs level based on the parent level.';
		X_Rbs_level := X_Rbs_Level + 1;

                IF X_Rbs_Level > 10 THEN
                   -- We do not allow more then 10 Levels. So error out.
                   RAISE MAX_RBS_LEVELS;
                END IF;

	PA_DEBUG.G_Stage := 'Check if element is variation of same combination in different combination - Job-Org vs Org-Job.';
        -- Fix bugs 3909551 and 3882731 by checking to see if the new/upd
        -- element already exists in the RBS; if so, then check the entire
        -- branch (except UDR) and ensure they are not the same.  This will
        -- prevent creation of DBA-Cons East and Cons East-DBA, and the
        -- creation of the same element under different UDR nodes.

        -- First, check whether element exists already:
-- hr_utility.trace('P_Resource_Type_Id IS : ' || P_Resource_Type_Id);
-- hr_utility.trace('P_Resource_Source_Id IS : ' || P_Resource_Source_Id);
-- hr_utility.trace('P_Rbs_Element_Id IS : ' || P_Rbs_Element_Id);
--dbms_output.put_line('before  chk_element_exists');
        l_unique_branch := 'Y';
        OPEN chk_element_exists(P_Resource_Type_Id   => P_Resource_Type_Id,
                                P_Resource_Source_Id => P_Resource_Source_Id,
                                P_Rbs_Element_Id     => P_Rbs_Element_Id,
			        P_rbs_level          => X_Rbs_level);

        LOOP
           FETCH chk_element_exists Into l_ele_exists, l_exists_element_id;
-- hr_utility.trace('IN LOOP');
-- hr_utility.trace('l_ele_exists IS : ' || l_ele_exists);
-- hr_utility.trace('l_exists_element_id IS : ' || l_exists_element_id);
           l_unique_branch := 'Y';
           EXIT WHEN chk_element_exists%NOTFOUND OR
                     l_unique_branch = 'N';

        -- If element exists, then check uniqueness on branch:
	PA_DEBUG.G_Stage := 'Check if element is unique combination - validation check 10.';

           IF l_ele_exists = 'Y' THEN
-- hr_utility.trace('ELE EXISTS');
              BEGIN
-- hr_utility.trace('x_organization_id IS : ' || x_organization_id);
-- hr_utility.trace('x_job_id IS : ' || x_job_id);
-- hr_utility.trace('x_person_id IS : ' || x_person_id);
              SELECT 'N'
              INTO   l_unique_branch
              FROM   pa_rbs_elements
              WHERE  rbs_element_id = l_exists_element_id
              AND nvl(person_id, -99)              = nvl(x_person_id, -99)
              AND nvl(organization_id, -99)        = nvl(x_organization_id, -99)
              AND nvl(job_id, -99)                 = nvl(x_job_id, -99)
              AND nvl(supplier_id, -99)            = nvl(x_supplier_id, -99)
              AND nvl(expenditure_type_id, -99)    = nvl(x_exp_type_id, -99)
              AND nvl(event_type_id, -99)          = nvl(x_event_type_id, -99)
              AND nvl(revenue_category_id, -99)    = nvl(x_rev_cat_id, -99)
              AND nvl(inventory_item_id, -99)      = nvl(x_inv_item_id, -99)
              AND nvl(item_category_id, -99)       = nvl(x_item_cat_id, -99)
              AND nvl(bom_labor_id, -99)           = nvl(x_bom_labor_id, -99)
              AND nvl(bom_equipment_id, -99)       = nvl(x_bom_equip_id, -99)
              AND nvl(person_type_id, -99)         = nvl(x_person_type_id, -99)
              AND nvl(resource_class_id, -99)      = nvl(x_res_class_id, -99)
              AND nvl(role_id, -99)                = nvl(x_role_id, -99)
              AND nvl(non_labor_resource_id, -99) = nvl(x_non_labor_res_id, -99)
              AND nvl(expenditure_category_id, -99) = nvl(x_exp_cat_id,-99)
	      AND nvl(User_Defined_Custom1_Id, -99) = nvl(X_User_Def_Custom1_Id, -99)
      	      AND nvl(User_Defined_Custom2_Id, -99) = nvl(X_User_Def_Custom2_Id, -99)
	      AND nvl(User_Defined_Custom3_Id, -99) = nvl(X_User_Def_Custom3_Id, -99)
	      AND nvl(User_Defined_Custom4_Id, -99) = nvl(X_User_Def_Custom4_Id, -99)
	      AND nvl(User_Defined_Custom5_Id, -99) = nvl(X_User_Def_Custom5_Id, -99);
              EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                      l_unique_branch := 'Y';
                 WHEN OTHERS THEN
                      l_unique_branch := 'N';
              END;

-- hr_utility.trace('l_unique_branch IS : ' || l_unique_branch);
              IF l_unique_branch = 'N' THEN
-- hr_utility.trace('RAISE ERROR');
                 RAISE NON_UNIQUE_BRANCH;
              END IF;

           END IF;
        END LOOP;
        CLOSE chk_element_exists;

        -- Bug - Prevent creation of identical branches.
        -- e.g. disallow DBA-CW and CW-DBA - the actual nodes
        -- are different but the branches are the same.
        -- First check if the node being added exists in RBS - then
        -- only does the possiblity of the same branch arise.

--dbms_output.put_line('before  chk_element_diff_level');
        l_unique_branch := 'Y';
        OPEN chk_element_diff_level(P_Resource_Type_Id  => P_Resource_Type_Id,
                                   P_Resource_Source_Id => P_Resource_Source_Id,
                                   P_Rbs_Element_Id     => P_Rbs_Element_Id);

        FETCH chk_element_diff_level Into l_ele_exists;
-- hr_utility.trace('IN Identical branch check flow');
-- hr_utility.trace('l_ele_exists IS : ' || l_ele_exists);
-- hr_utility.trace('l_exists_element_id IS : ' || l_exists_element_id);
        IF chk_element_diff_level%FOUND THEN
           l_ele_exists := 'Y';
        ELSE
           l_ele_exists := 'N';
        END IF;

        CLOSE chk_element_diff_level;

        -- Check whether identical branch exists
--dbms_output.put_line('l_ele_exists IS ' || l_ele_exists);
        IF l_ele_exists = 'Y' THEN
-- hr_utility.trace('identical Branch exists Check');
              BEGIN
-- hr_utility.trace('x_organization_id IS : ' || x_organization_id);
-- hr_utility.trace('x_job_id IS : ' || x_job_id);
-- hr_utility.trace('x_person_id IS : ' || x_person_id);
--dbms_output.put_line('before iden branch check');
--dbms_output.put_line('P_Rbs_Element_Id IS ' || P_Rbs_Element_Id);
--dbms_output.put_line('P_Rbs_Version_Id IS ' || P_Rbs_Version_Id);
              SELECT 'N'
              INTO   l_unique_branch
              FROM   pa_rbs_elements
              WHERE  rbs_element_id <> nvl(P_Rbs_Element_Id,-99)
              AND    rbs_version_id = P_Rbs_Version_Id
              AND    rbs_level = X_Rbs_level
              AND nvl(person_id, -99)              = nvl(x_person_id, -99)
              AND nvl(organization_id, -99)        = nvl(x_organization_id, -99)
              AND nvl(job_id, -99)                 = nvl(x_job_id, -99)
              AND nvl(supplier_id, -99)            = nvl(x_supplier_id, -99)
              AND nvl(expenditure_type_id, -99)    = nvl(x_exp_type_id, -99)
              AND nvl(event_type_id, -99)          = nvl(x_event_type_id, -99)
              AND nvl(revenue_category_id, -99)    = nvl(x_rev_cat_id, -99)
              AND nvl(inventory_item_id, -99)      = nvl(x_inv_item_id, -99)
              AND nvl(item_category_id, -99)       = nvl(x_item_cat_id, -99)
              AND nvl(bom_labor_id, -99)           = nvl(x_bom_labor_id, -99)
              AND nvl(bom_equipment_id, -99)       = nvl(x_bom_equip_id, -99)
              AND nvl(person_type_id, -99)         = nvl(x_person_type_id, -99)
              AND nvl(resource_class_id, -99)      = nvl(x_res_class_id, -99)
              AND nvl(role_id, -99)                = nvl(x_role_id, -99)
              AND nvl(non_labor_resource_id, -99) = nvl(x_non_labor_res_id, -99)
              AND nvl(expenditure_category_id, -99) = nvl(x_exp_cat_id,-99)
	      AND nvl(User_Defined_Custom1_Id, -99) = nvl(X_User_Def_Custom1_Id, -99)
      	      AND nvl(User_Defined_Custom2_Id, -99) = nvl(X_User_Def_Custom2_Id, -99)
	      AND nvl(User_Defined_Custom3_Id, -99) = nvl(X_User_Def_Custom3_Id, -99)
	      AND nvl(User_Defined_Custom4_Id, -99) = nvl(X_User_Def_Custom4_Id, -99)
	      AND nvl(User_Defined_Custom5_Id, -99) = nvl(X_User_Def_Custom5_Id, -99);
              EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                      l_unique_branch := 'Y';
                 WHEN OTHERS THEN
                      l_unique_branch := 'N';
              END;
--dbms_output.put_line('after iden branch check');
--dbms_output.put_line('l_unique_branch IS ' || l_unique_branch);

-- hr_utility.trace('l_unique_branch IS : ' || l_unique_branch);
              IF l_unique_branch = 'N' THEN
-- hr_utility.trace('RAISE ERROR');
                 RAISE NON_UNIQUE_BRANCH;
              END IF;

        END IF;
		--Added for bug fix 3725965.

		Select
			use_for_alloc_flag
		Into
			l_use_for_alloc_flag
		From
			pa_rbs_headers_vl h,
			pa_rbs_versions_vl v
		where
			v.rbs_version_id=P_Rbs_Version_Id
		And
			h.rbs_header_id=v.rbs_header_id;


		If l_use_for_alloc_flag='Y' Then
                        If P_RESOURCE_SOURCE_ID = -1 Then --For bug 3803213.
			--If X_Rule_Based_Flag ='Y' Then --Commented for bug fix 3803213.
				Raise CANNOT_CREATE_RULES;
			End If;
		End If; --End of bug fix 3725965

                IF P_Order_Number = FND_API.G_MISS_NUM
                THEN
                  X_Order_Number := null;
                ELSE
                  X_Order_Number := P_Order_Number;
                END IF;

                IF X_Order_Number = -1 THEN
                   X_Order_Number := null;
                END IF;

		-- The procedure Pa_Rbs_Utils.Populate_RBS_Element_Name() handles
                -- returning the rbs_element_name_id and creating rbs element name
                -- records if needed.
		Pa_Debug.G_Stage := 'Call Pa_Rbs_Utils.Populate_RBS_Element_Name() procedure.';


               Pa_Rbs_Utils.Populate_RBS_Element_Name (
			P_Resource_Source_Id  => P_Resource_Source_Id,
			P_Resource_Type_Id    => P_Resource_Type_Id,
			X_Rbs_Element_Name_Id => X_Rbs_Element_Name_Id,
			X_Return_Status       => l_Dummy_Error_Status);


		If l_Dummy_Error_Status <> FND_API.G_RET_STS_SUCCESS
                Then
                   Pa_Debug.G_Stage := 'Call to Pa_Rbs_Utils.Populate_RBS_Element_Name() procedure failed.';
                   Raise GET_ELEMENT_NAME_ID_FAILED;
		End If;

                -- Get the Element Identifier
                Pa_Debug.G_Stage := 'Check if update or add to determine element identifier value.';
                IF P_Mode = 'A' THEN

                   Pa_Debug.G_Stage := 'Get the next available element identifier sequence value for add.';
                   -- Get the next value in the sequence
                   Select Pa_Rbs_Element_Identifier_S.NextVal
                   Into   X_Element_Identifier
                   From   Dual;

                ELSE

                   Pa_Debug.G_Stage := 'Retrieve the element identifier value from pa_rbs_elements for update.';
                   -- Get the value from the rbs_elements table.
                   Select Element_Identifier
                   Into   X_Element_Identifier
                   From   Pa_Rbs_Elements
                   Where  Rbs_Element_Id = P_Rbs_Element_Id;

                END IF;

                l_number_of_peers := 0;


                IF p_mode = 'A' THEN

                   -- Set the outline number

                   SELECT count(*)
                   INTO l_number_of_peers
                   FROM PA_RBS_ELEMENTS
                   WHERE parent_element_id = p_parent_element_id
                   AND USER_CREATED_FLAG    = 'Y';

                   IF l_number_of_peers = 0 THEN
                      l_o_number := 1;
                   ELSE
                      l_o_number := l_number_of_peers + 1;
                   END IF;

                   IF X_Outline_Number  = '0' THEN
                      X_Outline_Number := l_o_number;
                   ELSE
                      X_Outline_Number := X_Outline_Number || '.' || l_o_number;
                   END IF;
               ELSE
                 -- Mode is update. Get the outline number of the element

                 SELECT outline_number
                 INTO   x_outline_number
                 FROM   PA_RBS_ELEMENTS
                 WHERE  RBS_ELEMENT_ID = P_RBS_ELEMENT_ID;

               END IF;


        END IF;

        Pa_Debug.G_Stage := 'Leaving ValidateAndBuildElement()  procedure.';
        Pa_Debug.TrackPath('STRIP','ValidateAndBuildElement');

Exception
	When MAX_USER_DEF_RES_IDS Then
		X_Error_Msg_Data := 'PA_MAX_USER_DEF_RES_IDS';
	When MAX_RBS_LEVELS Then
		X_Error_Msg_Data := 'PA_MAX_RBS_LEVELS';
	When NON_UNIQUE_BRANCH Then
		X_Error_Msg_Data := 'PA_NON_UNIQUE_BRANCH';
	When CANNOT_CREATE_RULES Then
		X_Error_Msg_Data := 'PA_RBS_CANNOT_CREATE_RULES';
	When Others Then
		Raise;

End ValidateAndBuildElement;


--         A
--       |   |
--      B     C
--     | |     |
--    E   G     F

Procedure ValidateRbsElement(
	P_Mode		          IN         Varchar2,
	P_Rbs_Version_Id          IN         Number,
	P_Parent_Element_Id       IN         Number,
	P_Rbs_Element_Id          IN         Number,
	P_Old_Resource_Type_Id    IN         Number,
	P_Old_Resource_Source_Id  IN         Number,
	P_Resource_Type_Id        IN         Number,
	P_Resource_Source_Id      IN         Number,
	X_Resource_Type           OUT NOCOPY Varchar2,
	X_Error_Msg_Data          OUT NOCOPY Varchar2)

IS

  CURSOR c_CheckDupSiblings
            (P_RbsVersionId IN Number,
             P_ParentId     IN Number,
             P_ResSourceId  IN Number,
             P_ResTypeId    IN Number)
  IS

    SELECT Count(*)
    FROM  PA_RBS_ELEMENTS
    WHERE Rbs_Version_Id    = P_RbsVersionId
    AND	  Resource_Type_Id   = P_ResTypeId
    AND	  Resource_Source_Id = P_ResSourceId
    AND   parent_element_id  = p_parentId;

  l_dummy_count             Number     := 0;

  CURSOR c_CheckExistParentMatch
             (P_Res_Type_Id IN Number,
              P_Res_Srce_Id IN Number,
              P_Parent_Elem_Id IN Number)
  IS

    Select Count(*)
    From Pa_Rbs_Elements
    Where Resource_Type_Id = P_Res_Type_Id
    And	  Resource_Source_Id = P_Res_Srce_Id
    Start With Rbs_Element_Id = P_Parent_Elem_Id
    Connect By  Prior Parent_Element_Id = Rbs_Element_Id;

  CURSOR c_CheckExistChildMatch
              (P_Res_Type_Id IN Number,
               P_Res_Srce_Id IN Number,
               P_Rbs_Elem_Id IN Number)
  IS
    Select Count(*)
    From Pa_Rbs_Elements
    Where Resource_Type_Id = P_Res_Type_Id
    And	Resource_Source_Id = P_Res_Srce_Id
    Start With Parent_Element_Id = P_Rbs_Elem_Id
    Connect By Prior Rbs_Element_Id = Parent_Element_Id;

  DUP_SIBLING_RES_RES_TYPE        Exception;
  INVAL_RES_TYPE                  Exception;
  ELEMENT_USER_DEF_RULE           Exception;
  INVALID_RESOURCE                Exception;
  DUP_PARENT_RES_RES_TYPE         Exception;
  DUP_CHILD_RES_RES_TYPE          Exception;
  RES_TYPE_RES_NOT_CON_LVLS       Exception;
  CONS_RES_TYPES_NOT_INSTANCES    Exception;
  l_Current_level		  Number;
  l_grand_parent_element_id       Number;
  l_parent_resource_type_id       Number;
  l_parent_resource_source_id     Number;


  CURSOR c_GetCurrentLevel(P_Parent_Id IN Number)
  IS
   SELECT rbs_level + 1
   FROM Pa_Rbs_Elements
   WHERE Rbs_Element_Id = P_Parent_Id;

  CURSOR c_CheckResTypeInRbs
          (P_Res_Type_Id IN Number,
           P_Rbs_Level IN Number,
           P_Version_Id IN Number)
  IS
    SELECT Count(*)
    FROM Pa_Rbs_Elements
    WHERE Resource_Type_Id = P_Res_Type_Id
    AND   Rbs_Level not in (P_Rbs_Level, P_Rbs_Level - 1, P_Rbs_Level + 1)
    AND	  Rbs_Version_Id   = P_Version_Id;

  CURSOR children_elements(P_Rbs_Element_Id IN NUMBER)
  IS
    SELECT rbs_element_id , resource_type_id, resource_source_id
    FROM   pa_rbs_elements
    WHERE  parent_element_id = P_Rbs_Element_Id;

BEGIN

        Pa_Debug.G_Stage := 'Entering ValidateRbsElement().';
        Pa_Debug.TrackPath('ADD','ValidateRbsElement');

        -- 1. Validate the resource_type
        -- We need this validation irrespective of whether the resource type is
        -- changed or not. The x_resource_type we get below is used by the
        -- calling API to populate the element record in both update and insert mode.

        X_Resource_Type := Pa_Rbs_Elements_Utils.GetResTypeCode
                                                   (P_Res_Type_Id => P_Resource_Type_Id);


        IF X_Resource_Type is Null or X_Resource_Type = 'NAMED_ROLE'
        THEN

          Pa_Debug.G_Stage := 'Invalid resource type id passed in.';
          RAISE INVAL_RES_TYPE;
        END IF;

        -- If the resource type or the resource source id has not changed from
        -- the old values, we do not need to proceeed further.

        IF p_old_resource_type_id = p_resource_type_id AND
           P_old_Resource_Source_Id = P_Resource_Source_Id THEN
           Return;
        END IF;


	-- 2. If the element is rule based, and resource_type is user-defined, it's an error.
	Pa_Debug.G_Stage := 'Determine if rule and user-defined which is not allowed.';
	If P_Resource_Source_Id = -1 and X_Resource_Type = 'USER_DEFINED' Then

			Pa_Debug.G_Stage := 'Rule and user defined raise user defined error.';
			Raise ELEMENT_USER_DEF_RULE;

	End If;

	-- 3. If the element is not rule based, and resource_type is not user-defined,
	--    validate the resource_source_id.
	Pa_Debug.G_Stage := 'Validate the resource by calling the ValidateResource() procedure.';
	Pa_Rbs_Elements_Pvt.ValidateResource(
		P_Resource_Type_Id   => P_Resource_Type_Id,
		P_Resource_Source_Id => P_Resource_Source_Id,
		P_Resource_Type      => X_Resource_Type,
		X_Error_Msg_Data     => X_Error_Msg_Data);

	If X_Error_Msg_Data is Not Null Then

		Pa_Debug.G_Stage := 'The Resource is invalid.  Raise user defined error.';
		Raise INVALID_RESOURCE;

	End If;

	-- 4. Validate that the element is not the same as it's siblings.
	Pa_Debug.G_Stage := 'Open c_CheckDupSiblings cursor - validation check 4.';
	Open c_CheckDupSiblings(P_Rbs_Version_Id,
                                P_Parent_Element_Id,
                                P_Resource_Source_Id,
                                P_Resource_Type_Id);


	Fetch c_CheckDupSiblings Into l_dummy_count;
	Close c_CheckDupSiblings;

	IF l_dummy_count = 0
        THEN
            Null;
	ELSE
            Pa_Debug.G_Stage := 'Records found!  Close c_CheckDupSiblings cursor.  ' ||
					       'Raise user defined error - validation check 4.';
            RAISE DUP_SIBLING_RES_RES_TYPE;
        END IF;

	-- 5. Validate that the element is not the same as it's one of it's parents.
	Open c_CheckExistParentMatch(P_Resource_Type_Id,
                                     P_Resource_Source_Id,
                                     P_Parent_Element_Id);

	Fetch c_CheckExistParentMatch Into l_Dummy_Count;
	Close c_CheckExistParentMatch;

	IF l_dummy_count = 0 THEN
             Null;
	ELSE
             Pa_Debug.G_Stage := 'Raise user defined error - validation check 5.';
             Raise DUP_PARENT_RES_RES_TYPE;
        END IF;

	-- 6. Validate that the element is not repeated in the branches below it.
	--    This check does not need to be done when adding a element/node.  It won't have children
	--    to worry about.
	Pa_Debug.G_Stage := 'Check if validation is for updating an element - validation check 6.';
	If P_Mode = 'U' THEN

            Open c_CheckExistChildMatch(P_Resource_Type_Id,P_Resource_Source_Id,P_Rbs_Element_Id);

            Fetch c_CheckExistChildMatch Into l_Dummy_Count;
            Close c_CheckExistChildMatch;

            IF l_dummy_count = 0 THEN
                 Null;
            ELSE
                 Pa_Debug.G_Stage := 'Raise user defined error - validation check 6.';
                 Raise DUP_CHILD_RES_RES_TYPE;
            END IF;

	END IF;

	PA_DEBUG.G_Stage := 'Check if element/node is rule based - validation check 7.';

	-- 7. Resources of Same Resource Type can be repeated in a branch only
        --    in consecutive generations and if both the elements are instance
        --    based (not rule based)

/*
        Check the Parent's resource type.
           i. Check if the parent resource type is same as the current element's
              resource type.
              a. If resource types are same, check if the current element is
                 rule based. If yes, error out since when resource type is
                 repeated, the elements must be instances and not rule.
              b. If the resource types are different, check if the current
                 element's resource type is same as any of it's grandparents.
                 If yes, error out, since resource type can be repeated only
                 in consecutive generations.
*/

        -- Get parent's resource type
        BEGIN
           SELECT resource_type_id, resource_source_id
           INTO l_parent_resource_type_id, l_parent_resource_source_id
           FROM  PA_RBS_ELEMENTS
           WHERE rbs_element_id = P_Parent_Element_Id;
        EXCEPTION
           WHEN OTHERS THEN
                null;
        END;

        IF l_parent_resource_type_id = p_resource_type_id
        THEN
            IF p_resource_source_id = -1 OR
               l_parent_resource_source_id = -1 THEN
               RAISE CONS_RES_TYPES_NOT_INSTANCES;
            END IF;

        ELSE

            -- We need to check for grand parent's resource types only if the
            -- parent's resource type is different from the element's resource type.


            l_dummy_count := 0;

            SELECT count(*)
            INTO l_dummy_count
            FROM PA_RBS_ELEMENTS
            WHERE RESOURCE_TYPE_ID = P_Resource_Type_Id
            START WITH rbs_element_id = p_parent_element_id
            CONNECT BY PRIOR parent_element_id = rbs_element_id;

            IF l_dummy_count > 0 THEN
               RAISE RES_TYPE_RES_NOT_CON_LVLS;
            ELSE
               -- There are no grand parents with the same
               -- resource type.
               null;
            END IF;

        END IF;


        -- Check resource type with the children

        IF p_mode = 'U' THEN
            FOR c1 in children_elements(P_Rbs_Element_Id) LOOP

                IF P_Resource_Type_Id = c1.resource_type_id THEN

                   IF p_resource_source_id = -1 OR
                      c1.resource_source_id = -1 THEN
                      RAISE CONS_RES_TYPES_NOT_INSTANCES;
                   END IF;

                ELSE
                   l_dummy_count := 0;

                   SELECT count(*)
                   INTO l_dummy_count
                   FROM PA_RBS_ELEMENTS
                   WHERE RESOURCE_TYPE_ID = P_Resource_Type_Id
                   START WITH parent_element_id = c1.rbs_element_id
                   CONNECT BY PRIOR rbs_element_id = parent_element_id;


                   IF l_dummy_count > 0 THEN
                         RAISE RES_TYPE_RES_NOT_CON_LVLS;
                   ELSE
                       -- There are no grand children with the
                       -- same resource type
                       null;
                   END IF;
                END IF;
              END LOOP;

              -- If the element is updated, and the old resource type happened
              -- to be same as parent resource type, then we need to check if
              -- any child exists with the same resource type. If it does,
              -- then we need to error out, since change the resource type of the
              -- element will create a break in consecutive resource types.

              IF (l_parent_resource_type_id = P_Old_Resource_Type_Id
                 AND p_resource_type_id <> p_old_resource_type_id)
              THEN

                l_dummy_count := 0;

                select count(*)
                INTO l_dummy_count
                FROM PA_RBS_ELEMENTS
                WHERE PARENT_ELEMENT_ID = p_rbs_element_id
                AND RESOURCE_TYPE_ID = p_old_resource_type_id;

                IF l_dummy_count > 0 THEN
                   RAISE RES_TYPE_RES_NOT_CON_LVLS;
                ELSE
                   -- There are no children with the same resource type,
                   -- so changing the resource type will not create
                   -- any discontinuity
                   null;
                END IF;

              END IF;

          END IF; /* p_mode = 'U' */
        Pa_Debug.G_Stage := 'Leaving ValidateRbsElement() procedure.';
        Pa_Debug.TrackPath('STRIP','ValidateRbsElement');

EXCEPTION
    WHEN INVAL_RES_TYPE THEN
         X_Error_Msg_Data := 'PA_RBS_INVAL_RES_TYPE';
    WHEN ELEMENT_USER_DEF_RULE THEN
         X_Error_Msg_Data := 'PA_RBS_ELE_USER_DEF_RULE';
    WHEN INVALID_RESOURCE THEN
         Null;
    WHEN DUP_SIBLING_RES_RES_TYPE THEN
         X_Error_Msg_Data := 'PA_RBS_DUP_SIB_RES_RES_TYPE';
    WHEN DUP_PARENT_RES_RES_TYPE THEN
         X_Error_Msg_Data := 'PA_RBS_DUP_PAR_RES_RES_TYPE';
    WHEN DUP_CHILD_RES_RES_TYPE THEN
         X_Error_Msg_Data := 'PA_RBS_DUP_CHD_RES_RES_TYPE';
    WHEN RES_TYPE_RES_NOT_CON_LVLS THEN
         X_Error_Msg_Data := 'PA_RES_TYPE_RES_NOT_CON_LVLS';
    WHEN CONS_RES_TYPES_NOT_INSTANCES THEN
         X_Error_Msg_Data := 'PA_CONS_RBS_ELE_NOT_INS';
    WHEN Others THEN
         Raise;

END ValidateRbsElement;

Procedure ValidateResource(
	P_Resource_Type_Id   IN Number,
	P_Resource_Source_Id IN Number,
	P_Resource_Type      IN Varchar2,
	X_Error_Msg_Data     OUT NOCOPY Varchar2)

Is

	l_Rev_Code   Varchar2(30) := Null;
	l_Person_Type_Code   Varchar2(30) := Null; --Added for Bug 3780201
	l_Named_Role Varchar2(30) := Null;
	l_dummy      Varchar2(1)  := Null;

	Cursor c_GetResCode(P_Res_Type_Id IN Number,
		            P_Res_Srce_Id IN Number) Is
	Select
		Resource_Name
	From
		Pa_Rbs_Element_Map
	Where
		Resource_Type_Id = P_Res_Type_Id
	And	Resource_Id = P_Res_Srce_Id;

	Cursor c_EventType ( P_Id IN Number ) Is
	Select
		'Y'
  	From
		Pa_Event_Types
 	Where
		Event_Type_Id = P_Id
	And	Event_Type_Classification IN ('AUTOMATIC','MANUAL','WRITE OFF','WRITE ON');

	Cursor c_ExpType ( P_Id IN Number) Is
	Select
		'Y'
  	From
		Pa_Expenditure_Types
 	Where
		Expenditure_Type_Id = P_Id;

	Cursor c_RevCat ( P_Code IN Varchar2) Is
	Select
		'Y'
  	From
		Pa_Lookups
 	Where
		Lookup_Code = P_Code
	And	Lookup_Type = 'REVENUE CATEGORY';

	Cursor c_People (P_Id IN Number) is
	Select
		'Y'
	From
		Per_People_X
	Where
		Person_Id = P_Id
	And     ( (Pa_Cross_Business_Grp.IsCrossBGProfile = 'N' AND
		   Fnd_Profile.Value('PER_BUSINESS_GROUP_ID') = Per_People_X.Business_Group_Id)
		  OR Pa_Cross_Business_Grp.IsCrossBGProfile = 'Y');

	Cursor c_Job (P_Id In Number) Is
	Select
		'Y'
	From
		Per_Jobs
	Where
		Job_Id = P_Id
	And     ( (Pa_Cross_Business_Grp.IsCrossBGProfile = 'N' AND
		   Fnd_Profile.Value('PER_BUSINESS_GROUP_ID') = Per_Jobs.Business_Group_Id )
		  OR Pa_Cross_Business_Grp.IsCrossBGProfile = 'Y');

	Cursor c_BOM (P_BOM_Res_Id IN Number) Is
	Select
		'Y'
	From
		Bom_Resources
	Where
		Resource_Id = P_BOM_Res_Id;

	Cursor c_ItemCat ( P_Id IN Number ) Is
	Select
		'Y'
	From
		Mtl_Categories_tl
	Where
		Language = USERENV('LANG')
	And	Category_Id = P_Id;

	Cursor c_InvenItem (P_Id IN Number ) Is
	Select
		'Y'
	From
		Mtl_System_Items_tl
	Where
		Language = USERENV('LANG')
	And	Inventory_Item_Id = P_Id;

	Cursor c_ResClass (P_Id IN Number) Is
	Select
		'Y'
	From
		Pa_Resource_Classes_Vl
	Where
		Resource_Class_Id = P_Id;

	Cursor c_PrjRoles (P_Id IN Number) Is
	Select
		'Y'
	From
		Pa_Project_Role_Types_B
	Where
		Project_Role_Id = P_Id;

	Cursor c_Org(P_Id IN Number) Is
	Select
		'Y'
	From
		Hr_All_Organization_Units
	Where
		Organization_Id = P_Id;

	Cursor c_Supplier (P_Id IN Number) Is
	Select
		'Y'
	From
		Po_Vendors
	Where
		Vendor_Id = P_Id;

--Commented for Bug 3780201
/*	Cursor c_PerTypes (P_Id IN Number) Is
	Select
		'Y'
	From
		Per_Person_Types
	Where
		Person_Type_Id = P_Id
	And	Business_Group_Id = 0;*/
--Added for Bug 3780201
	Cursor c_PerTypes ( P_Code IN Varchar2) Is
	Select
		'Y'
  	From
		Pa_Lookups
 	Where
		Lookup_Code = P_Code
	And	Lookup_Type = 'PA_PERSON_TYPE';
--Changes for Bug 3780201 end

	Cursor c_NLRs(P_Id IN Number) Is
	Select
		'Y'
	From
		Pa_Non_Labor_Resources
	Where
		Non_Labor_Resource_Id = P_Id;

	Cursor c_ExpCat(P_Id IN Number) Is
	Select
		'Y'
	From
		Pa_Expenditure_Categories
	Where
		Expenditure_Category_Id = P_Id;

Begin


        Pa_Debug.G_Stage := 'Entering ValidateResource().';
        Pa_Debug.TrackPath('ADD','ValidateResource');

	Pa_Debug.G_Stage := 'Check what the resource type is to determine how to validate the resource.';

	If P_Resource_Type IN ('BOM_LABOR','BOM_EQUIPMENT') And
	   P_Resource_Source_Id <> -1 Then

		Pa_Debug.G_Stage := 'Validating BOM Labor or BOM Equipment resource.';
		Open c_BOM(P_Resource_Source_Id);
		Fetch c_BOM Into l_Dummy;

		If c_BOM%NotFound Then

			X_Error_Msg_Data := 'PA_RBS_ELE_INVALID_RESOURCE';

		End If;
		Close c_BOM;

	Elsif P_Resource_Type = 'NAMED_PERSON' And
	      P_Resource_Source_Id <> -1 Then

		Pa_Debug.G_Stage := 'Validating Name Person resource.';
		Open c_People(P_Resource_Source_Id);
		Fetch c_People Into l_Dummy;

		If c_People%NotFound Then

			X_Error_Msg_Data := 'PA_RBS_ELE_NVALID_RESOURCE';

		End If;
		Close c_People;

	Elsif P_Resource_Type = 'EVENT_TYPE' And
	      P_Resource_Source_Id <> -1 Then

		Pa_Debug.G_Stage := 'Validating Event Type resource.';
		Open c_EventType(P_Resource_Source_Id);
		Fetch c_EventType Into l_Dummy;

		If c_EventType%NotFound Then

			X_Error_Msg_Data := 'PA_RBS_ELE_INVALID_RESOURCE';

		End If;
		Close c_EventType;

	Elsif P_Resource_Type = 'EXPENDITURE_CATEGORY' And
	      P_Resource_Source_Id <> -1 Then

		Pa_Debug.G_Stage := 'Validating Expenditure Category resource.';
		Open c_ExpCat(P_Resource_Source_Id);
		Fetch c_ExpCat Into l_Dummy;

		If c_ExpCat%NotFound Then

			X_Error_Msg_Data := 'PA_RBS_ELE_INVALID_RESOURCE';

		End If;
		Close c_ExpCat;

	Elsif P_Resource_Type = 'EXPENDITURE_TYPE' And
	      P_Resource_Source_Id <> -1 Then

		Pa_Debug.G_Stage := 'Validating Expenditure Type resource.';
		Open c_ExpType(P_Resource_Source_Id);
		Fetch c_ExpType Into l_Dummy;

		If c_ExpType%NotFound Then

			X_Error_Msg_Data := 'PA_RBS_ELE_INVALID_RESOURCE';

		End If;
		Close c_ExpType;

	Elsif P_Resource_Type = 'ITEM_CATEGORY' And
	      P_Resource_Source_Id <> -1 Then

		Pa_Debug.G_Stage := 'Validating Item Category resource.';
		Open c_ItemCat(P_Resource_Source_Id);
		Fetch c_ItemCat Into l_Dummy;

		If c_ItemCat%NotFound Then

			X_Error_Msg_Data := 'PA_RBS_ELE_INVALID_RESOURCE';

		End If;
		Close c_ItemCat;

	Elsif P_Resource_Type = 'INVENTORY_ITEM' And
	      P_Resource_Source_Id <> -1 Then

		Pa_Debug.G_Stage := 'Validating Inventory Item resource.';
		Open c_InvenItem(P_Resource_Source_Id);
		Fetch c_InvenItem Into l_Dummy;

		If c_InvenItem%NotFound Then

			X_Error_Msg_Data := 'PA_RBS_ELE_INVALID_RESOURCE';

		End If;
		Close c_InvenItem;

	Elsif P_Resource_Type = 'JOB' And
	      P_Resource_Source_Id <> -1 Then

		Pa_Debug.G_Stage := 'Validating Job resource.';
		Open c_Job(P_Resource_Source_Id);
		Fetch c_Job Into l_Dummy;

		If c_Job%NotFound Then

			X_Error_Msg_Data := 'PA_RBS_ELE_INVALID_RESOURCE';

		End If;
		Close c_Job;

	Elsif P_Resource_Type = 'ORGANIZATION' And
	      P_Resource_Source_Id <> -1 Then

		Pa_Debug.G_Stage := 'Validating Organization resource.';
		Open c_Org(P_Resource_Source_Id);
		Fetch c_Org Into l_Dummy;

		If c_Org%NotFound Then

			X_Error_Msg_Data := 'PA_RBS_ELE_INVALID_RESOURCE';

		End If;
		Close c_Org;

	Elsif P_Resource_Type = 'PERSON_TYPE' And
	      P_Resource_Source_Id <> -1 Then

		Pa_Debug.G_Stage := 'Validating Person Type resource.';
		--Commented for Bug 3780201
/*		Open c_PerTypes(P_Resource_Source_Id);
		Fetch c_PerTypes Into l_Dummy;

		If c_PerTypes%NotFound Then

			X_Error_Msg_Data := 'PA_RBS_ELE_INVALID_RESOURCE';

		End If;
		Close c_PerTypes;*/
		--Added for Bug 3780201
		Open c_GetResCode(P_Resource_Type_Id,P_Resource_Source_Id);
		Fetch c_GetResCode Into l_Person_Type_Code;
		Close c_GetResCode;

		If l_Person_Type_Code Is Not Null Then

			Open c_PerTypes(l_Person_Type_Code);
			Fetch c_PerTypes Into l_Dummy;

			If c_PerTypes%NotFound Then

				X_Error_Msg_Data := 'PA_RBS_ELE_INVALID_RESOURCE';

			End If;
			Close c_PerTypes;

		Else

			X_Error_Msg_Data := 'PA_RBS_ELE_INVALID_RESOURCE';

		End If;
		--Changes for Bug 3780201 end

	Elsif P_Resource_Type = 'NON_LABOR_RESOURCE' And
	      P_Resource_Source_Id <> -1 Then

		Pa_Debug.G_Stage := 'Validating Non Labor Resource resource.';
		Open c_NLRs(P_Resource_Source_Id);
		Fetch c_NLRs Into l_Dummy;

		If c_NLRs%NotFound Then

			X_Error_Msg_Data := 'PA_RBS_ELE_INVALID_RESOURCE';

		End If;
		Close c_NLRs;

	Elsif P_Resource_Type = 'RESOURCE_CLASS' And
	      P_Resource_Source_Id <> -1 Then

		Pa_Debug.G_Stage := 'Validating Resource Class resource.';
		Open c_ResClass(P_Resource_Source_Id);
		Fetch c_ResClass Into l_Dummy;

		If c_ResClass%NotFound Then

			X_Error_Msg_Data := 'PA_RBS_ELE_INVALID_RESOURCE';

		End If;
		Close c_ResClass;

	Elsif P_Resource_Type = 'REVENUE_CATEGORY' And
	      P_Resource_Source_Id <> -1 Then

		Pa_Debug.G_Stage := 'Validating Revenue Category resource.';
		Open c_GetResCode(P_Resource_Type_Id,P_Resource_Source_Id);
		Fetch c_GetResCode Into l_Rev_Code;
		Close c_GetResCode;

		If l_Rev_Code Is Not Null Then

			Open c_RevCat(l_Rev_Code);
			Fetch c_RevCat Into l_Dummy;

			If c_RevCat%NotFound Then

				X_Error_Msg_Data := 'PA_RBS_ELE_INVALID_RESOURCE';

			End If;
			Close c_RevCat;

		Else

			X_Error_Msg_Data := 'PA_RBS_ELE_INVALID_RESOURCE';

		End If;

	Elsif P_Resource_Type = 'ROLE' And
	      P_Resource_Source_Id <> -1 Then

		Pa_Debug.G_Stage := 'Validating Role resource.';
		Open c_PrjRoles(P_Resource_Source_Id);
		Fetch c_PrjRoles Into l_Dummy;

		If c_PrjRoles%NotFound Then

			X_Error_Msg_Data := 'PA_RBS_ELE_INVALID_RESOURCE';

		End If;
		Close c_PrjRoles;

	Elsif P_Resource_Type = 'SUPPLIER' And
	      P_Resource_Source_Id <> -1 Then

		Pa_Debug.G_Stage := 'Validating Supplier resource.';
		Open c_Supplier(P_Resource_Source_Id);
		Fetch c_Supplier Into l_Dummy;
		If c_Supplier%NotFound Then

			X_Error_Msg_Data := 'PA_RBS_ELE_INVALID_RESOURCE';

		End If;
		Close c_Supplier;

	End If;

        Pa_Debug.G_Stage := 'Leaving ValidateResource() procedure.';
        Pa_Debug.TrackPath('STRIP','ValidateResource');

Exception
	When Others Then
		Raise;

End ValidateResource;

Procedure GetParentRbsData(
	P_Parent_Element_Id   IN         Number,
	X_Person_Id           OUT NOCOPY Number,
	X_Job_Id              OUT NOCOPY Number,
	X_Organization_Id     OUT NOCOPY Number,
	X_Exp_Type_Id         OUT NOCOPY Number,
	X_Event_Type_Id       OUT NOCOPY Number,
	X_Exp_Cat_Id          OUT NOCOPY Number,
	X_Rev_Cat_Id          OUT NOCOPY Number,
	X_Inv_Item_Id         OUT NOCOPY Number,
	X_Item_Cat_Id         OUT NOCOPY Number,
	X_BOM_Labor_Id        OUT NOCOPY Number,
	X_BOM_Equip_Id        OUT NOCOPY Number,
	X_Non_Labor_Res_Id    OUT NOCOPY Number,
	X_Role_Id             OUT NOCOPY Number,
	X_Person_Type_Id      OUT NOCOPY Number,
        X_User_Def_Custom1_Id OUT NOCOPY Number,
        X_User_Def_Custom2_Id OUT NOCOPY Number,
        X_User_Def_Custom3_Id OUT NOCOPY Number,
        X_User_Def_Custom4_Id OUT NOCOPY Number,
        X_User_Def_Custom5_Id OUT NOCOPY Number,
	X_Res_Class_Id        OUT NOCOPY Number,
	X_Supplier_Id         OUT NOCOPY Number,
	X_Rbs_Level           OUT NOCOPY Number,
        X_outline_number      OUT NOCOPY VARCHAR2)

Is

Begin

        Pa_Debug.G_Stage := 'Entering GetParentRbsData().';
        Pa_Debug.TrackPath('ADD','GetParentRbsData');

	Pa_Debug.G_Stage := 'Retrieve the parent rbs element data for use in child element/node.';
	Select
		Person_Id,
		Job_Id,
		Organization_Id,
        	Expenditure_Type_Id,
        	Event_Type_Id,
        	Expenditure_Category_Id,
        	Revenue_Category_Id,
        	Inventory_Item_Id,
        	Item_Category_Id,
        	BOM_Labor_Id,
        	BOM_Equipment_Id,
        	Non_Labor_Resource_Id,
        	Role_Id,
        	Person_Type_Id,
		User_Defined_Custom1_Id,
		User_Defined_Custom2_Id,
		User_Defined_Custom3_id,
		User_Defined_Custom4_Id,
		User_Defined_Custom5_Id,
        	Resource_Class_Id,
        	Supplier_Id,
        	Rbs_Level,
        	Outline_number
	Into
		X_Person_Id,
		X_Job_Id,
		X_Organization_Id,
		X_Exp_Type_Id,
		X_Event_Type_Id,
		X_Exp_Cat_Id,
		X_Rev_Cat_Id,
		X_Inv_Item_Id,
		X_Item_Cat_Id,
		X_BOM_Labor_Id,
		X_BOM_Equip_Id,
		X_Non_Labor_Res_Id,
		X_Role_Id,
		X_Person_Type_Id,
		X_User_Def_Custom1_Id,
		X_User_Def_Custom2_Id,
		X_User_Def_Custom3_Id,
		X_User_Def_Custom4_Id,
		X_User_Def_Custom5_Id,
		X_Res_Class_Id,
		X_Supplier_Id,
		X_Rbs_Level,
        	X_Outline_Number
	From
		Pa_Rbs_Elements
	Where
		Rbs_Element_Id = P_Parent_Element_Id;
-- 	And	Rbs_Level <> 0;

        Pa_Debug.G_Stage := 'Leaving GetParentRbsData() procedure.';
        Pa_Debug.TrackPath('STRIP','GetParentRbsData');

Exception
	When No_Data_Found Then
		Null;
	When Others Then
		Raise;

End GetParentRbsData;

-- This procedure is only really neccessary for the Update/Create Child Elements page
-- but will always be called.
-- Since we can't control the order of the records in the pl/sql table it may
-- occur that children are process more than once.
Procedure UpdateOrderOutlineNumber(
        P_Parent_Element_Id_Tbl IN         System.Pa_Num_Tbl_Type,
        X_Error_Msg_Data        OUT NOCOPY Varchar2 )

Is

	i number := null;
	l_par_element_id number := -1;
	l_par_outline_number varchar2(240) := Null;
	l_order_number number := Null;

	-- Gets the max order number for the the level
	Cursor c1(P_Par_Element_Id IN Number) is
	Select
		Max(Order_Number)
	From
		Pa_Rbs_Elements
	Where
		Parent_Element_Id = P_Par_Element_Id;

	-- Gets the parent outline number
	Cursor c2(P_Par_Element_Id IN Number) Is
	Select
		Outline_Number
	From
		Pa_Rbs_Elements
	Where
		Rbs_Element_Id = P_Par_Element_Id;

	-- Gets all the children of the parent for update.
	Cursor c3(P_Par_Element_Id IN Number) Is
	Select
		Rbs_Element_Id,
		Order_Number
	From
		Pa_Rbs_Elements
	Where
		Parent_Element_Id = P_Par_Element_Id
	For Update of Outline_Number NoWait;

	l_rbs_rec c3%RowType;

Begin

        Pa_Debug.G_Stage := 'Entering UpdateOrderOutlineNumber().';
        Pa_Debug.TrackPath('ADD','UpdateOrderOutlineNumber');

	Pa_Debug.G_Stage := 'Begin loop thru the parent array table to process the elements/nodes for the parents.';
	For i in P_Parent_Element_Id_Tbl.First .. P_Parent_Element_Id_Tbl.Last
	Loop

		Pa_Debug.G_Stage := 'Check if working with new parent element/node.';
		If l_par_element_id <> P_Parent_Element_Id_Tbl(i) Then

			Pa_Debug.G_Stage := 'Assign parent element/node id to local variable for if check.';
			l_par_element_id := P_Parent_Element_Id_Tbl(i);

			-- Get the max order number for the children of the current parent
			Pa_Debug.G_Stage := 'Get the max order number for all the children of ' ||
						       'the current parent element id being processed.';
			open c1(P_Parent_Element_Id_Tbl(i));
			Fetch c1 into l_order_number;
			Close c1;

			-- Get the parent outline number
			Pa_Debug.G_Stage := 'Get parent outline number to use to append the child ' ||
						       'order number to for the new child outline number.';
			open c2(P_Parent_Element_Id_Tbl(i));
			Fetch c2 into l_par_outline_number;
			Close c2;

			-- Get all the children for the parent for update
			Pa_Debug.G_Stage := 'Open cursor to get all child elements for the current ' ||
						       'parent element id.';
			Open c3(P_Parent_Element_Id_Tbl(i));
			Loop

				Pa_Debug.G_Stage := 'Fetch record from cursor with all the child ' ||
						 	       'elements of the current parent element being processed.';
				Fetch c3 into l_Rbs_Rec;
				Exit When c3%NotFound;

				Pa_Debug.G_Stage := 'Check if the child element/node has an order number = -1.';
				If l_Rbs_Rec.Order_Number = -1 Then

					Pa_Debug.G_Stage := 'Assign order number to a child that does ' ||
								       'not currently have one.';
					l_order_number := l_order_number + 1;

					Pa_Debug.G_Stage := 'Update the child rbs element record with new ' ||
								       'order number and outline number - update 1.';
					Update pa_rbs_elements
					Set
						Order_Number = l_Order_Number,
					    	Outline_Number = decode(l_Par_Outline_Number,'0',
									to_char(l_Order_Number),
									l_Par_Outline_Number || '.' || to_char(l_Order_Number))
					Where
						Rbs_Element_Id = l_Rbs_Rec.Rbs_Element_id;

				Else

					Pa_Debug.G_Stage := 'Update the child rbs element record with the ' ||
								       'outline number - update 2 .';
					Update Pa_Rbs_Elements
					Set
						Outline_Number =  decode(l_Par_Outline_Number,'0',
								  to_char(l_Rbs_Rec.Order_Number),
								  l_Par_Outline_Number || '.' || to_char(l_Rbs_Rec.Order_Number))
					Where
						Rbs_Element_Id = l_Rbs_Rec.Rbs_Element_id;

				End If;

			End Loop;

		End If;

	End Loop;

        Pa_Debug.G_Stage := 'Leaving UpdateOrderOutlineNumber() procedure.';
        Pa_Debug.TrackPath('STRIP','UpdateOrderOutlineNumber');

Exception
	When Others Then
		Raise;

End UpdateOrderOutlineNumber;

Procedure Update_Children_Data(
        P_Rbs_Element_Id IN         Number,
        X_Error_Msg_Data OUT NOCOPY Varchar2)

Is

     Cursor c1 (P_Rbs_Elem_Id IN Number) IS
     Select
             Rbs_Element_Id,
             Parent_Element_Id,
             Resource_Type_Id,
             Resource_Source_Id
     From
             Pa_Rbs_Elements
     Where
             User_Created_Flag = 'Y'
     Start With
             Parent_Element_Id = P_Rbs_Elem_Id
     Connect By Prior
             Rbs_Element_Id = Parent_Element_Id
     Order by
             Rbs_Level;

     l_Child_Rec c1%RowType;

     l_Person_Id            Number(15) := Null;
     l_Job_Id               Number(15) := Null;
     l_Organization_Id      Number(15) := Null;
     l_Exp_Type_Id          Number(15) := Null;
     l_Event_Type_Id        Number(15) := Null;
     l_Exp_Cat_Id           Number(15) := Null;
     l_Rev_Cat_Id           Number(15) := Null;
     l_Inv_Item_Id          Number(15) := Null;
     l_Item_Cat_Id          Number(15) := Null;
     l_BOM_Labor_Id         Number(15) := Null;
     l_BOM_Equip_Id         Number(15) := Null;
     l_Non_Labor_Res_Id     Number(15) := Null;
     l_Role_Id              Number(15) := Null;
     l_Person_Type_Id       Number(15) := Null;
     l_User_Def_Custom1_Id  Number(15) := Null;
     l_User_Def_Custom2_Id  Number(15) := Null;
     l_User_Def_Custom3_Id  Number(15) := Null;
     l_User_Def_Custom4_Id  Number(15) := Null;
     l_User_Def_Custom5_Id  Number(15) := Null;
     l_Res_Class_Id         Number(15) := Null;
     l_Supplier_Id          Number(15) := Null;
     l_Dummy_Rbs_Level      Number(15) := Null;
     l_Dummy_Outline_Number Varchar2(240) := Null;
     l_Resource_Type        Varchar2(30) := Null;

     MAX_USER_DEF_RES_IDS   Exception;

Begin

     Pa_Debug.G_Stage := 'Entering Update_Children_Data().';
     Pa_Debug.TrackPath('ADD','Update_Children_Data');

     Pa_Debug.G_Stage := 'Open c1 cursor to get rbs elements to update.';
     Open c1(P_Rbs_Elem_Id => P_Rbs_Element_Id);

     Loop

          Pa_Debug.G_Stage := 'Fetch the current child record.';
          Fetch c1 Into l_Child_Rec;
          Exit When c1%NotFound;

          Pa_Debug.G_Stage := 'Call GetParentRbsData() procedure.';
          Pa_Rbs_Elements_Pvt.GetParentRbsData(
               P_Parent_Element_Id   => l_Child_Rec.Parent_Element_Id,
               X_Person_Id           => l_Person_Id,
               X_Job_Id              => l_Job_Id,
               X_Organization_Id     => l_Organization_Id,
               X_Exp_Type_Id         => l_Exp_Type_Id,
               X_Event_Type_Id       => l_Event_Type_Id,
               X_Exp_Cat_Id          => l_Exp_Cat_Id,
               X_Rev_Cat_Id          => l_Rev_Cat_Id,
               X_Inv_Item_Id         => l_Inv_Item_Id,
               X_Item_Cat_Id         => l_Item_Cat_Id,
               X_BOM_Labor_Id        => l_BOM_Labor_Id,
               X_BOM_Equip_Id        => l_BOM_Equip_Id,
               X_Non_Labor_Res_Id    => l_Non_Labor_Res_Id,
               X_Role_Id             => l_Role_Id,
               X_Person_Type_Id      => l_Person_Type_Id,
               X_User_Def_Custom1_Id => l_User_Def_Custom1_Id,
               X_User_Def_Custom2_Id => l_User_Def_Custom2_Id,
               X_User_Def_Custom3_Id => l_User_Def_Custom3_Id,
               X_User_Def_Custom4_Id => l_User_Def_Custom4_Id,
               X_User_Def_Custom5_Id => l_User_Def_Custom5_Id,
               X_Res_Class_Id        => l_Res_Class_Id,
               X_Supplier_Id         => l_Supplier_Id,
               X_Rbs_Level           => l_Dummy_Rbs_Level,
               X_Outline_Number      => l_Dummy_Outline_Number);

          Pa_Debug.G_Stage := 'Get the Resource Type by calling Pa_Rbs_Elements_Utils.GetResTypeCode() function.';
          l_Resource_Type := Pa_Rbs_Elements_Utils.GetResTypeCode(P_Res_Type_Id => l_Child_Rec.Resource_Type_Id);

          Pa_Debug.G_Stage := 'Determine which resource type we have for this element to properly assign the resource source id.';
          If l_Resource_Type = 'BOM_LABOR' Then

               Pa_Debug.G_Stage := 'Assign the resource source id to BOM Labor.';
               l_BOM_Labor_Id := l_Child_Rec.Resource_Source_Id;

          Elsif l_Resource_Type = 'BOM_EQUIPMENT' Then

               Pa_Debug.G_Stage := 'Assign the resource source id to BOM Equipment.';
               l_BOM_Equip_Id := l_Child_Rec.Resource_Source_Id;

          Elsif l_Resource_Type = 'NAMED_PERSON' Then

               Pa_Debug.G_Stage := 'Assign the resource source id to Named Person.';
               l_Person_Id := l_Child_Rec.Resource_Source_Id;

          Elsif l_Resource_Type = 'EVENT_TYPE' Then

               Pa_Debug.G_Stage := 'Assign the resource source id to Event Type.';
               l_Event_Type_Id := l_Child_Rec.Resource_Source_Id;

          Elsif l_Resource_Type = 'EXPENDITURE_CATEGORY' Then

               Pa_Debug.G_Stage := 'Assign the resource source id to Expenditure Category.';
               l_Exp_Cat_Id := l_Child_Rec.Resource_Source_Id;

          Elsif l_Resource_Type = 'EXPENDITURE_TYPE' Then

               Pa_Debug.G_Stage := 'Assign the resource source id to Expenditure Type.';
               l_Exp_Type_Id := l_Child_Rec.Resource_Source_Id;

          Elsif l_Resource_Type = 'ITEM_CATEGORY' Then

               Pa_Debug.G_Stage := 'Assign the resource source id to Item Category.';
               l_Item_Cat_Id := l_Child_Rec.Resource_Source_Id;

          Elsif l_Resource_Type = 'INVENTORY_ITEM' Then

               Pa_Debug.G_Stage := 'Assign the resource source id to Inventory Item.';
               l_Inv_Item_Id := l_Child_Rec.Resource_Source_Id;

          Elsif l_Resource_Type = 'JOB' Then

               Pa_Debug.G_Stage := 'Assign the resource source id to Job.';
               l_Job_Id := l_Child_Rec.Resource_Source_Id;

          Elsif l_Resource_Type = 'ORGANIZATION' Then

               Pa_Debug.G_Stage := 'Assign the resource source id to Organization.';
               l_Organization_Id := l_Child_Rec.Resource_Source_Id;

          Elsif l_Resource_Type = 'PERSON_TYPE' Then

               Pa_Debug.G_Stage := 'Assign the resource source id to Person Type.';
               l_Person_Type_Id := l_Child_Rec.Resource_Source_Id;

          Elsif l_Resource_Type = 'NON_LABOR_RESOURCE' Then

               Pa_Debug.G_Stage := 'Assign the resource source id to Non Labor Resource.';
               l_Non_Labor_Res_Id := l_Child_Rec.Resource_Source_Id;

          Elsif l_Resource_Type = 'RESOURCE_CLASS' Then

               Pa_Debug.G_Stage := 'Assign the resource source id to Resource Class.';
               l_Res_Class_Id := l_Child_Rec.Resource_Source_Id;

          Elsif l_Resource_Type = 'REVENUE_CATEGORY' Then

               Pa_Debug.G_Stage := 'Assign the resource source id to Revenue Category.';
               l_Rev_Cat_Id := l_Child_Rec.Resource_Source_Id;

          Elsif l_Resource_Type = 'ROLE' Then

               Pa_Debug.G_Stage := 'Assign the resource source id to Role.';
               l_Role_Id := l_Child_Rec.Resource_Source_Id;

          Elsif l_Resource_Type = 'SUPPLIER' Then

               Pa_Debug.G_Stage := 'Assign the resource source id to Supplier.';
               l_Supplier_Id := l_Child_Rec.Resource_Source_Id;

          Elsif l_Resource_Type = 'USER_DEFINED' Then

               Pa_Debug.G_Stage := 'Assign the resource source id to User Defined.';
               If l_User_Def_Custom1_Id Is Null Then

                    Pa_Debug.G_Stage := 'Assign the resource source id to User Defined 1.';
                    l_User_Def_Custom1_Id := l_Child_Rec.Resource_Source_Id;

               ElsIf l_User_Def_Custom2_Id Is Null Then

                    Pa_Debug.G_Stage := 'Assign the resource source id to User Defined 2.';
                    l_User_Def_Custom2_Id := l_Child_Rec.Resource_Source_Id;

               ElsIf l_User_Def_Custom3_Id Is Null Then

                    Pa_Debug.G_Stage := 'Assign the resource source id to User Defined 3.';
                    l_User_Def_Custom3_Id := l_Child_Rec.Resource_Source_Id;

               ElsIf l_User_Def_Custom4_Id Is Null Then

                    Pa_Debug.G_Stage := 'Assign the resource source id to User Defined 4.';
                    l_User_Def_Custom4_Id := l_Child_Rec.Resource_Source_Id;

               ElsIf l_User_Def_Custom5_Id Is Null Then

                    Pa_Debug.G_Stage := 'Assign the resource source id to User Defined 5.';
                    l_User_Def_Custom5_Id := l_Child_Rec.Resource_Source_Id;

               Else

                    Pa_Debug.G_Stage := 'All user defined resources field populated.';
                    Raise MAX_USER_DEF_RES_IDS;

               End If;

          End If;

          Pa_Debug.G_Stage := 'Update the child element record.';
          Update Pa_Rbs_Elements
          Set
               Person_Id               = l_Person_Id,
               Job_Id                  = l_Job_Id,
               Organization_Id         = l_Organization_Id,
               Expenditure_Type_Id     = l_Exp_Type_Id,
               Event_Type_Id           = l_Event_Type_Id,
               Expenditure_Category_Id = l_Exp_Cat_Id,
               Revenue_Category_Id     = l_Rev_Cat_Id,
               Inventory_Item_Id       = l_Inv_Item_Id,
               Item_Category_Id        = l_Item_Cat_Id,
               BOM_Labor_Id            = l_BOM_Labor_Id,
               BOM_Equipment_Id        = l_BOM_Equip_Id,
               Non_Labor_Resource_Id   = l_Non_Labor_Res_Id,
               Role_Id                 = l_Role_Id,
               Person_Type_Id          = l_Person_Type_Id,
               User_Defined_Custom1_Id = l_User_Def_Custom1_Id,
               User_Defined_Custom2_Id = l_User_Def_Custom2_Id,
               User_Defined_Custom3_Id = l_User_Def_Custom3_Id,
               User_Defined_Custom4_Id = l_User_Def_Custom4_Id,
               User_Defined_Custom5_Id = l_User_Def_Custom5_Id,
               Resource_Class_Id       = l_Res_Class_Id,
               Supplier_Id             = l_Supplier_Id
          Where Rbs_Element_Id = l_Child_Rec.Rbs_Element_Id;

     End Loop;

     Pa_Debug.G_Stage := 'Close the primary cursor c1.';
     Close c1;

     Pa_Debug.G_Stage := 'Leaving Update_Children_Data() procedure.';
     Pa_Debug.TrackPath('STRIP','Update_Children_Data');

Exception
     When MAX_USER_DEF_RES_IDS Then
          X_Error_Msg_Data := 'PA_MAX_USER_DEF_RES_IDS';
     When Others Then
          Raise;

End Update_Children_Data;

End Pa_Rbs_Elements_Pvt;

/
