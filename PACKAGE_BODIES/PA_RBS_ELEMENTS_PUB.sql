--------------------------------------------------------
--  DDL for Package Body PA_RBS_ELEMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RBS_ELEMENTS_PUB" AS
/* $Header: PARELEPB.pls 120.0 2005/05/30 20:47:47 appldev noship $*/

/* -------------------------------------------------------------------------------
 * Procedure: Process_RBS_Elements
 * Function: Overall Point of entry to insert/update/delete elements/nodes
 *           This procedure is used by SS clients.
 * ------------------------------------------------------------------------------- */

Procedure Process_Rbs_Elements (
	P_Calling_Page		   IN         Varchar2,
	P_Commit		   IN	      Varchar2 Default Fnd_Api.G_False,
	P_Init_Msg_List		   IN	      Varchar2 Default Fnd_Api.G_True,
	P_API_Version_Number	   IN	      Number,
	P_RBS_Version_Id	   IN	      Number,
	P_Rbs_Version_Rec_Num	   IN	      Number,
	P_Parent_Element_Id_Tbl	   IN	      System.Pa_Num_Tbl_Type,
	P_Element_Id_Tbl	   IN	      System.Pa_Num_Tbl_Type,
	P_Resource_Type_Id_Tbl	   IN	      System.Pa_Num_Tbl_Type,
	P_Resource_Source_Id_Tbl   IN	      System.Pa_Num_Tbl_Type,
	P_Resource_Source_Code_Tbl IN	      System.Pa_Varchar2_240_Tbl_Type,
	P_Order_Number_Tbl	   IN	      System.Pa_Num_Tbl_Type,
	P_Process_Type_Tbl	   IN	      System.Pa_Varchar2_1_Tbl_Type,
	X_Return_Status		   OUT NOCOPY Varchar2,
	X_Msg_Count		   OUT NOCOPY Number,
	X_Error_Msg_Data           OUT NOCOPY Varchar2)

Is

	i                    Number                          := Null;
	l_Api_Name           Varchar2(30)                    := 'Process_Rbs_Elements';
	l_Outline_Number_Tbl System.Pa_Varchar2_240_Tbl_Type := Null;
	l_Error_Msg_Data_Tbl System.Pa_Varchar2_30_Tbl_Type  := Null;
	l_Resource_Source_Id Number                          := Null;
	l_Dummy		     Varchar2(30)		     := Null;
        l_rbs_element_id     NUMBER;

	locked_version_rec   Exception;

	Cursor cLockVersionRec(P_Id IN Number) is
	Select
		Status_Code
	From
		Pa_Rbs_Versions_B
	Where
		Status_Code = 'WORKING'
	And	Rbs_Version_Id = P_Id
	For Update Of Status_code NoWait;

Begin

	Pa_Debug.G_Path := ' ';

        Pa_Debug.G_Stage := 'Entering Process_Rbs_Elements() Pub.';
        Pa_Debug.TrackPath('ADD','Process_Rbs_Elements Pub');

	Pa_Debug.G_Stage := 'Call Compatibility API.';
        If Not Fnd_Api.Compatible_API_Call (
                        Pa_Rbs_Elements_Pub.G_Api_Version_Number,
                        P_Api_Version_Number,
                        l_Api_Name,
                        Pa_Rbs_Elements_Pub.G_Pkg_Name) Then

                Raise Fnd_Api.G_Exc_Unexpected_Error;

        End If;

	Pa_Debug.G_Stage := 'Check if need to initialize the message stack(T-True,F-False) - ' || P_Init_Msg_List;
        If Fnd_Api.To_Boolean(nvl(P_Init_Msg_List,Fnd_Api.G_True)) Then

                Fnd_Msg_Pub.Initialize;

        End If;

	Pa_Debug.G_Stage := 'Initialize error handling variables.';
	X_Msg_Count := 0;
	X_Error_Msg_Data := Null;
	X_Return_Status := Fnd_Api.G_Ret_Sts_Success;

	-- Lock the rbs_version record.
	Pa_Debug.G_Stage := 'Opening cursor which locks the Rbs Version.';
	Open cLockVersionRec(P_Id => P_RBS_Version_Id);
	Fetch cLockVersionRec Into l_dummy;

	If cLockVersionRec%NotFound Then
		Close cLockVersionRec;
		Raise locked_version_rec;
	End If;

	-- first time thru the loop for deleted records.
	Pa_Debug.G_Stage := 'Beginning Loop thru to process DELETED records.';
	For i in P_Process_Type_Tbl.First .. P_Process_Type_Tbl.Last
	Loop

           IF P_Process_Type_Tbl(i) = 'D'
           THEN

              Pa_Debug.G_Stage := 'Call Process_Rbs_Elements() Pvt - 1.';
              -- When it is a delete, the resource source ID is not passed in
              -- Need to get it for the error message token
              Select Resource_Source_Id
                Into l_Resource_Source_Id
                From pa_rbs_elements
               Where rbs_element_id = P_Element_Id_Tbl(i);

              Pa_Rbs_Elements_Pvt.Process_Rbs_Element(
				P_RBS_Version_Id	=> P_RBS_Version_Id,
				P_Parent_Element_Id	=> P_Parent_Element_Id_Tbl(i),
				P_Element_Id		=> P_Element_Id_Tbl(i),
				P_Resource_Type_Id	=> P_Resource_Type_Id_Tbl(i),
				P_Resource_Source_Id	=> l_Resource_Source_Id,
				P_Order_Number		=> P_Order_Number_Tbl(i),
				P_Process_Type		=> P_Process_Type_Tbl(i),
                                X_RBS_Element_id        => l_rbs_element_id,
				X_Error_Msg_Data	=> X_Error_Msg_Data );

              If X_Error_Msg_Data is not null Then

                   Pa_Debug.G_Stage := 'Assign error message - 1.';
                   Pa_Rbs_Elements_Pub.PopulateErrorStack(
                                P_Calling_Page       => P_Calling_Page,
                                P_Element_Id         => P_Element_Id_Tbl(i),
                                P_Resource_Type_Id   => P_Resource_Type_Id_Tbl(i),
                                P_Resource_Source_Id => l_Resource_Source_Id,
                                P_Error_Msg_Data     => X_Error_Msg_Data);

                   X_Msg_Count                       := X_Msg_Count + 1;
                   X_Return_Status                   := Fnd_Api.G_Ret_Sts_Error;

              End If;

          END IF; -- process type is DELETE

        END LOOP; -- first time thru the loop for deleted records.

	-- Second run thru the loop for updated records.
	Pa_Debug.G_Stage := 'Beginning Loop thru to process UPDATE records.';
        For i in P_Process_Type_Tbl.First .. P_Process_Type_Tbl.Last
        Loop

           If P_Process_Type_Tbl(i) = 'U'
           Then

              If P_Resource_Source_Id_Tbl(i) is Null Then

                 Pa_Debug.G_Stage := 'Get Resource Source Id using code - 2.';
                                Pa_Rbs_Elements_Utils.GetResSourceId(
                                        P_Resource_Type_Id     => P_Resource_Type_Id_Tbl(i),
                                        P_Resource_Source_Code => P_Resource_Source_Code_Tbl(i),
                                        X_Resource_Source_Id   => l_Resource_Source_Id);

              Else

                 Pa_Debug.G_Stage := 'Assign resource source id - 2.';
                 l_Resource_Source_Id := P_Resource_Source_Id_Tbl(i);

              End If;

              Pa_Debug.G_Stage := 'Call Process_Rbs_Elements() Pvt - 2.';

              Pa_Rbs_Elements_Pvt.Process_Rbs_Element(
                        	P_RBS_Version_Id        => P_RBS_Version_Id,
                               	P_Parent_Element_Id     => P_Parent_Element_Id_Tbl(i),
                               	P_Element_Id            => P_Element_Id_Tbl(i),
                               	P_Resource_Type_Id      => P_Resource_Type_Id_Tbl(i),
                               	P_Resource_Source_Id    => l_Resource_Source_Id,
                               	P_Order_Number          => P_Order_Number_Tbl(i),
                               	P_Process_Type          => P_Process_Type_Tbl(i),
                                X_RBS_Element_id        => l_rbs_element_id,
                               	X_Error_Msg_Data        => X_Error_Msg_Data );

              If X_Error_Msg_Data is not null Then

                   Pa_Debug.G_Stage := 'Assign error message - 2.';
                   Pa_Rbs_Elements_Pub.PopulateErrorStack(
                                P_Calling_Page       => P_Calling_Page,
                                P_Element_Id         => P_Element_Id_Tbl(i),
                                P_Resource_Type_Id   => P_Resource_Type_Id_Tbl(i),
                                P_Resource_Source_Id => l_Resource_Source_Id,
                                P_Error_Msg_Data     => X_Error_Msg_Data);

                   X_Msg_Count                       := X_Msg_Count + 1;
                   X_Return_Status                   := Fnd_Api.G_Ret_Sts_Error;

              End If;

           End If;  -- process type is UPDATE

        End Loop; -- Second run thru the loop for updated records.

	-- third time thru the the loop for added records.
	Pa_Debug.G_Stage := 'Beginning Loop thru to process ADD records.';
        For i in P_Process_Type_Tbl.First .. P_Process_Type_Tbl.Last
        Loop

          If P_Process_Type_Tbl(i) = 'A' Then

               If P_Resource_Source_Id_Tbl(i) is Null Then

                     Pa_Debug.G_Stage := 'Get Resource Source Id using code - 3.';

                     Pa_Rbs_Elements_Utils.GetResSourceId(
                     P_Resource_Type_Id     => P_Resource_Type_Id_Tbl(i),
                     P_Resource_Source_Code => P_Resource_Source_Code_Tbl(i),
                     X_Resource_Source_Id   => l_Resource_Source_Id);

               Else

                     Pa_Debug.G_Stage := 'Assign resource source id - 3.';
                     l_Resource_Source_Id := P_Resource_Source_Id_Tbl(i);

               End If;

                    Pa_Debug.G_Stage := 'Call Process_Rbs_Elements() Pvt - 3.';
                    Pa_Rbs_Elements_Pvt.Process_Rbs_Element(
                        	P_RBS_Version_Id        => P_RBS_Version_Id,
                               	P_Parent_Element_Id     => P_Parent_Element_Id_Tbl(i),
                               	P_Element_Id            => P_Element_Id_Tbl(i),
                               	P_Resource_Type_Id      => P_Resource_Type_Id_Tbl(i),
                               	P_Resource_Source_Id    => l_Resource_Source_Id,
                               	P_Order_Number          => P_Order_Number_Tbl(i),
                               	P_Process_Type          => P_Process_Type_Tbl(i),
                                X_RBS_Element_id        => l_rbs_element_id,
                               	X_Error_Msg_Data        => X_Error_Msg_Data );

                    If X_Error_Msg_Data is not null Then

                         Pa_Debug.G_Stage := 'Assign error message - 3.';
                         Pa_Rbs_Elements_Pub.PopulateErrorStack(
                                P_Calling_Page       => P_Calling_Page,
                                P_Element_Id         => P_Element_Id_Tbl(i),
                                P_Resource_Type_Id   => P_Resource_Type_Id_Tbl(i),
                                P_Resource_Source_Id => l_Resource_Source_Id,
                                P_Error_Msg_Data     => X_Error_Msg_Data);

                         X_Msg_Count                       := X_Msg_Count + 1;
                         X_Return_Status                   := Fnd_Api.G_Ret_Sts_Error;
                         return;

                     End If;

               	End If; -- process type is ADD

        End Loop; -- third time thru the the loop for added records.

	-- A Few assumptions are being made here.
	-- 1) The order number of a parent can't have changed at the same time as it's child.
	-- 2) There will always be a parent id
	-- 3) During the update/add loops what values exist will be stamped in because the outline number
	--    and the order number columns are not null columns in the table.
	-- 4) If there is no value for the order number the assigned -1
	-- 5) If there is no value for the outline number already then assigned 'NONE'

        If X_Error_Msg_Data is not null Then

		Pa_Debug.G_Stage := 'Assign error message - 4.';
		Pa_Rbs_Elements_Pub.PopulateErrorStack(
			P_Calling_Page       => P_Calling_Page,
			P_Element_Id         => P_Element_Id_Tbl(i),
			P_Resource_Type_Id   => P_Resource_Type_Id_Tbl(i),
			P_Resource_Source_Id => l_Resource_Source_Id,
			P_Error_Msg_Data     => X_Error_Msg_Data);
	        X_Msg_Count                       := X_Msg_Count + 1;
                X_Return_Status                   := Fnd_Api.G_Ret_Sts_UnExp_Error;

        End If;

	Pa_Debug.G_Stage := 'Check to do commit(T-True,F-False) - ' || P_Commit;
        If Fnd_Api.To_Boolean(Nvl(P_Commit,Fnd_Api.G_False)) Then

                Commit;

        End If;

	Pa_Debug.G_Stage := 'Closing cursor which locked the Rbs Version.';
	Close cLockVersionRec;

        Pa_Debug.G_Stage := 'Leaving Process_Rbs_Elements() Pub procedure.';
        Pa_Debug.TrackPath('STRIP','Process_Rbs_Elements Pub');

Exception
	When locked_version_rec Then
		X_Return_Status := 'E';
		X_Msg_Count := 1;
		X_Error_Msg_Data := 'Unable to lock the Rbs Version to process its elements.  This means that the ' ||
				    'Rbs Version has been frozen by someone else, an incorrect values has been passed in, ' ||
				    'or is currently locked by someone else.';
        When Others Then
                X_Return_Status := 'E';
                X_Msg_Count := 1;
                X_Error_Msg_Data := Pa_Debug.G_Path || '::' || Pa_Debug.G_Stage || ':' || SqlErrm;
                Rollback;

End Process_Rbs_Elements;

/* -------------------------------------------------------------------------------
 * Procedure: Process_RBS_Elements
 * Function: Overall Point of entry to insert/update/delete elements/nodes
 *           This procedure is used by AMG.
 * ------------------------------------------------------------------------------- */

Procedure Process_Rbs_Elements(
	P_Commit		IN	   Varchar2 Default Fnd_Api.G_False,
	P_Init_Msg_List		IN	   Varchar2 Default Fnd_Api.G_True,
	P_API_Version_Number 	IN	   Number,
	P_RBS_Version_Id     	IN	   Number,
	P_Rbs_Version_Rec_Num   IN	   Number,
	P_Rbs_Elements_Tbl	IN	   Pa_Rbs_Elements_Pub.Rbs_Elements_Tbl_Typ,
	X_Return_Status		OUT NOCOPY Varchar2,
	X_Msg_Count		OUT NOCOPY Number,
	X_Error_Msg_Data	OUT NOCOPY Varchar2 )

Is

	i                       Number                          := Null;
	l_Api_Name              Varchar2(30)                    := 'Process_Rbs_Elements';
	l_Parent_Element_Id_Tbl System.Pa_Num_Tbl_Type          := Null;
        l_Outline_Number_Tbl    System.Pa_Varchar2_240_Tbl_Type := Null;
        l_Error_Msg_Data_Tbl    System.Pa_Varchar2_30_Tbl_Type  := Null;
	l_Resource_Source_Id    Number                          := Null;
	l_Dummy			Varchar2(1)			:= Null;
        l_rbs_element_id        Number;

        locked_version_rec   Exception;

        Cursor cLockVersionRec(P_Id IN Number) is
        Select
                'Y'
        From
                Pa_Rbs_Versions_B
        Where
                Status_Code = 'WORKING'
        And     Rbs_Version_Id = P_Id
        For Update of Status_code NoWait;

Begin

     Pa_Debug.G_Path := ' ';

     Pa_Debug.G_Stage := 'Entering Process_Rbs_Elements() Pub.';
     Pa_Debug.TrackPath('ADD','Process_Rbs_Elements Pub-AMG');

     Pa_Debug.G_Stage := 'Call Compatibility API.';

     If Not Fnd_Api.Compatible_API_Call (
                        Pa_Rbs_Elements_Pub.G_Api_Version_Number,
                        P_Api_Version_Number,
                        l_Api_Name,
                        Pa_Rbs_Elements_Pub.G_Pkg_Name)
     THEN
        Raise Fnd_Api.G_Exc_Unexpected_Error;
     END IF;

     IF Fnd_Api.To_Boolean(nvl(P_Init_Msg_List,Fnd_Api.G_True))
     THEN
        Fnd_Msg_Pub.Initialize;
     END IF;

     Pa_Debug.G_Stage := 'Initialize error handling variables.';
     X_Msg_Count := 0;
     X_Error_Msg_Data := Null;
     X_Return_Status := Fnd_Api.G_Ret_Sts_Success;

     -- Lock the rbs_version record.
     Pa_Debug.G_Stage := 'Opening cursor which locks the Rbs Version.';
     Open cLockVersionRec(P_Id => P_RBS_Version_Id);
     Fetch cLockVersionRec Into l_dummy;

     If cLockVersionRec%NotFound Then
          Close cLockVersionRec;
          Raise locked_version_rec;
     End If;

     -- first time thru the loop for deleted records.
     Pa_Debug.G_Stage := 'Beginning Loop thru to process DELETED records.';
     For i in P_Rbs_Elements_Tbl.First .. P_Rbs_Elements_Tbl.Last
     Loop

        If P_Rbs_Elements_Tbl(i).Process_Type = 'D' Then

           If P_Rbs_Elements_Tbl(i).Resource_Source_Id is Null Then

				Pa_Debug.G_Stage := 'Get Resource Source Id using code - 1.';
                                Pa_Rbs_Elements_Utils.GetResSourceId(
                                        P_Resource_Type_Id     => P_Rbs_Elements_Tbl(i).Resource_Type_Id,
                                        P_Resource_Source_Code => P_Rbs_Elements_Tbl(i).Resource_Source_Code,
                                        X_Resource_Source_Id   => l_Resource_Source_Id);

                        Else

				Pa_Debug.G_Stage := 'Assign resource source id 1.';
                                l_Resource_Source_Id := P_Rbs_Elements_Tbl(i).Resource_Source_Id;

                        End If;

			Pa_Debug.G_Stage := 'Call Process_Rbs_Elements() Pvt - 1.';
                        Pa_Rbs_Elements_Pvt.Process_Rbs_Element(
                        	P_RBS_Version_Id        => P_RBS_Version_Id,
                                P_Parent_Element_Id     => P_Rbs_Elements_Tbl(i).Parent_Element_Id,
                                P_Element_Id            => P_Rbs_Elements_Tbl(i).Rbs_Element_Id,
                                P_Resource_Type_Id      => P_Rbs_Elements_Tbl(i).Resource_Type_Id,
                                P_Resource_Source_Id    => l_Resource_Source_Id,
                                P_Order_Number          => P_Rbs_Elements_Tbl(i).Order_Number,
                                P_Process_Type          => P_Rbs_Elements_Tbl(i).Process_Type,
                                X_RBS_Element_id        => l_rbs_element_id,
                                X_Error_Msg_Data        => X_Error_Msg_Data );

                        If X_Error_Msg_Data is not null Then

				Pa_Debug.G_Stage := 'Assign error message - 1.';
                                Pa_Rbs_Elements_Pub.PopulateErrorStack(
                                        P_Element_Id         => P_Rbs_Elements_Tbl(i).Rbs_Element_Id,
                                        P_Resource_Type_Id   => P_Rbs_Elements_Tbl(i).Resource_Type_Id,
                                        P_Resource_Source_Id => l_Resource_Source_Id,
					P_Error_Msg_Data     => X_Error_Msg_Data);
				X_Msg_Count                       := X_Msg_Count + 1;
				X_Return_Status                   := Fnd_Api.G_Ret_Sts_UnExp_Error;

			End If;

                End If; -- procedure type id DELETE

        End Loop; -- first time thru the loop for deleted records.

	-- second time thru the loop for updated records.
	Pa_Debug.G_Stage := 'Beginning Loop thru to process UPDATE records.';
        For i in P_Rbs_Elements_Tbl.First .. P_Rbs_Elements_Tbl.Last
        Loop

               	If P_Rbs_Elements_Tbl(i).Process_Type = 'U' Then

                        If P_Rbs_Elements_Tbl(i).Resource_Source_Id is Null Then

				Pa_Debug.G_Stage := 'Get Resource Source Id using code - 2.';
                                Pa_Rbs_Elements_Utils.GetResSourceId(
                                        P_Resource_Type_Id     => P_Rbs_Elements_Tbl(i).Resource_Type_Id,
                                        P_Resource_Source_Code => P_Rbs_Elements_Tbl(i).Resource_Source_Code,
                                        X_Resource_Source_Id   => l_Resource_Source_Id);

                        Else

				Pa_Debug.G_Stage := 'Assign resource source id 2.';
                                l_Resource_Source_Id := P_Rbs_Elements_Tbl(i).Resource_Source_Id;

                        End If;

			Pa_Debug.G_Stage := 'Call Process_Rbs_Element() Pvt - 2.';
                       	Pa_Rbs_Elements_Pvt.Process_Rbs_Element(
                        	P_RBS_Version_Id        => P_RBS_Version_Id,
                        	P_Parent_Element_Id     => P_Rbs_Elements_Tbl(i).Parent_Element_Id,
                        	P_Element_Id            => P_Rbs_Elements_Tbl(i).Rbs_Element_Id,
                        	P_Resource_Type_Id      => P_Rbs_Elements_Tbl(i).Resource_Type_Id,
                       		P_Resource_Source_Id    => l_Resource_Source_Id,
                        	P_Order_Number          => P_Rbs_Elements_Tbl(i).Order_Number,
                        	P_Process_Type          => P_Rbs_Elements_Tbl(i).Process_Type,
                                X_RBS_Element_id        => l_rbs_element_id,
                        	X_Error_Msg_Data        => X_Error_Msg_Data );

                       	If X_Error_Msg_Data is not null Then

                                Pa_Debug.G_Stage := 'Assign error message - 2.';
                                Pa_Rbs_Elements_Pub.PopulateErrorStack(
                                        P_Element_Id         => P_Rbs_Elements_Tbl(i).Rbs_Element_Id,
                                        P_Resource_Type_Id   => P_Rbs_Elements_Tbl(i).Resource_Type_Id,
                                        P_Resource_Source_Id => l_Resource_Source_Id,
					P_Error_Msg_Data     => X_Error_Msg_Data);
                                X_Msg_Count                       := X_Msg_Count + 1;
                                X_Return_Status                   := Fnd_Api.G_Ret_Sts_UnExp_Error;

                	End If;

               	End If; -- process type is UPDATE

        End Loop; -- second time thru the loop for updated records.

	-- third time thru the loop for add records.
	Pa_Debug.G_Stage := 'Beginning Loop thru to process ADD records.';
        For i in P_Rbs_Elements_Tbl.First .. P_Rbs_Elements_Tbl.Last
        Loop

                If P_Rbs_Elements_Tbl(i).Process_Type = 'A' Then

                        If P_Rbs_Elements_Tbl(i).Resource_Source_Id is Null Then

				Pa_Debug.G_Stage := 'Get Resource Source Id using code - 3.';
                                Pa_Rbs_Elements_Utils.GetResSourceId(
                                        P_Resource_Type_Id     => P_Rbs_Elements_Tbl(i).Resource_Type_Id,
                                        P_Resource_Source_Code => P_Rbs_Elements_Tbl(i).Resource_Source_Code,
                                        X_Resource_Source_Id   => l_Resource_Source_Id);

                        Else

				Pa_Debug.G_Stage := 'Assign resource source id 3.';
                                l_Resource_Source_Id := P_Rbs_Elements_Tbl(i).Resource_Source_Id;

                        End If;

			Pa_Debug.G_Stage := 'Call Process_Rbs_Element() Pvt - 3.';
                       	Pa_Rbs_Elements_Pvt.Process_Rbs_Element(
                        	P_RBS_Version_Id        => P_RBS_Version_Id,
                        	P_Parent_Element_Id     => P_Rbs_Elements_Tbl(i).Parent_Element_Id,
                        	P_Element_Id            => P_Rbs_Elements_Tbl(i).Rbs_Element_Id,
                        	P_Resource_Type_Id      => P_Rbs_Elements_Tbl(i).Resource_Type_Id,
                        	P_Resource_Source_Id    => l_Resource_Source_Id,
                        	P_Order_Number          => P_Rbs_Elements_Tbl(i).Order_Number,
                        	P_Process_Type          => P_Rbs_Elements_Tbl(i).Process_Type,
                                X_RBS_Element_id        => l_rbs_element_id,
                        	X_Error_Msg_Data        => X_Error_Msg_Data );

                        If X_Error_Msg_Data is not null Then

                                Pa_Debug.G_Stage := 'Assign error message - 3.';
                                Pa_Rbs_Elements_Pub.PopulateErrorStack(
                                        P_Element_Id         => P_Rbs_Elements_Tbl(i).Rbs_Element_Id,
                                        P_Resource_Type_Id   => P_Rbs_Elements_Tbl(i).Resource_Type_Id,
                                        P_Resource_Source_Id => l_Resource_Source_Id,
					P_Error_Msg_Data     => X_Error_Msg_Data);
                                X_Msg_Count                       := X_Msg_Count + 1;
                                X_Return_Status                   := Fnd_Api.G_Ret_Sts_UnExp_Error;

                        End If;

                End If; -- process type is ADD

		l_Parent_Element_Id_Tbl(i) := P_Rbs_Elements_Tbl(i).Parent_Element_Id;

        End Loop; -- third time thru the loop for add records.

	Pa_Debug.G_Stage := 'Check to do commit(T-True,F-False) - '|| P_Commit;
        If Fnd_Api.To_Boolean(Nvl(P_Commit,Fnd_Api.G_False)) Then

                Commit;

        End If;

        Pa_Debug.G_Stage := 'Closing cursor which locked the Rbs Version.';
        Close cLockVersionRec;

        Pa_Debug.G_Stage := 'Leaving Process_Rbs_Elements() Pub procedure.';
        Pa_Debug.TrackPath('STRIP','Process_Rbs_Elements Pub-AMG');

Exception
        When locked_version_rec Then
                X_Return_Status := 'E';
                X_Msg_Count := 1;
                X_Error_Msg_Data := 'Unable to lock the Rbs Version to process its elements.';
        When Others Then
                X_Return_Status := 'E';
		X_Msg_Count := 1;
		X_Error_Msg_Data := Pa_Debug.G_Path || '::' || Pa_Debug.G_Stage || ':' || SqlErrm;
		Rollback;

End Process_Rbs_Elements;

-- =======================================================================
-- Start of Comments
-- API Name      : PopulateErrorStack
-- Type          : Private
-- Pre-Reqs      : None
-- Type          : Procedure
-- Function      : This procedure is used to build the error message.
--                 This means determining the token value that will
--                 will be passed in with the message.  The token
--                 value is dynamic and must consider translation.
--                 Need traslated values for parent,child, resource type, and resource
--
--  Parameters:
--
--  IN
--    P_Calling_Page       - VARCHAR2(10) Values: VERSION_ELEMENTS or CHILD_ELEMENTS
--    P_Element_Id         - Number
--    P_Resource_Type_Id   - Number
--    P_Resource_Source_Id - Number
--    P_Error_Msg_Data     - VARACHAR2(30)
--
/*-------------------------------------------------------------------------*/

Procedure PopulateErrorStack(
        P_Calling_Page       IN Varchar2 Default 'VERSION_ELEMENTS',
        P_Element_Id         IN Number,
        P_Resource_Type_Id   IN Number,
        P_Resource_Source_Id IN Number,
        P_Error_Msg_Data     IN Varchar2)

Is
	l_Outline_Number  Varchar2(240)  := Null;
	l_Outline         Varchar2(80)   := Null;
	l_Resource_Type   Varchar2(240)  := Null;
	l_Resource        Varchar2(240)  := Null;
	l_Msg_Token_Value Varchar2(1000) := Null;
	l_temp_res_type   Varchar2(80)   := Null;
	l_temp_res        Varchar2(80)   := Null;
	l_res_type_name   Varchar2(240)  := Null;
	l_res_name        Varchar2(240)  := Null;

	Cursor c1(P_Lookup_Code IN Varchar2) Is
	Select
		Meaning
	From
		Pa_Lookups
	Where
		Lookup_Type = 'PA_RBS_API_ERR_TOKENS'
	And	Lookup_code = P_Lookup_Code;

	Cursor c2(P_Id IN Number) Is
	Select
		Outline_Number
	From
		Pa_Rbs_Elements
	Where
		Rbs_Element_Id = P_Id;

	Cursor c3(P_Id IN Number) Is
	Select
		Name
	From
		Pa_Res_Types_TL
	Where
		Res_Type_Id = P_Id
	And	Language = UserEnv('LANG');

Begin

        Pa_Debug.G_Stage := 'Entering PopulateErrorStack() procedure.';
        Pa_Debug.TrackPath('ADD','PopulateErrorStack');

	Pa_Debug.G_Stage := 'Get translated meaning for Resource Type.';
	Open c1('RESOURCE_TYPE');
	Fetch c1 Into l_Temp_Res_Type;
	Close c1;

	Pa_Debug.G_Stage := 'Get translated meaning for Resource.';
	Open c1('RESOURCE');
	Fetch c1 Into l_Temp_Res;
	Close c1;

	-- Get the Resource Type Name
	Open c3(P_Resource_Type_Id);
	Fetch c3 Into l_Res_Type_Name;
	Close c3;

--hr_utility.trace_on(null, 'RMDEL');
--hr_utility.trace('START');
--hr_utility.trace('P_Resource_Source_Id IS : ' || P_Resource_Source_Id);
	If P_Resource_Source_Id <> -1 Then

		l_res_name := Pa_Rbs_Utils.Get_Element_Name(
					P_Resource_Source_Id => P_Resource_Source_Id,
					P_Resource_Type_Code => Pa_Rbs_Elements_Utils.GetResTypeCode(P_Resource_Type_Id));
--hr_utility.trace('In If l_res_name IS : ' || l_res_name);

	Else

		-- Get the Resource Type Name
		Open c1('ANY_USED_RESOURCE');
		Fetch c1 Into l_Res_Name;
		Close c1;

	End If;

	If P_Calling_Page = 'VERSION_ELEMENTS' Then

        	Pa_Debug.G_Stage := 'Get translated meaning for Parent.';
        	Open c1('OUTLINE_NUMBER');
        	Fetch c1 Into l_Outline;
        	Close c1;

		Pa_Debug.G_Stage := 'Get element outline number.';
                Open c2(P_Element_Id);
                Fetch c2 Into l_Outline_Number;
                Close c2;

		Pa_Debug.G_Stage := 'Building token for Version Elements format.';
		-- Format for messages:
		-- Outline: <outline number>: Message Text
		-- Build string with translated values for outline

		l_Msg_Token_Value := l_Outline || ': ' || l_Outline_Number ||  ': ';

	Else

		Pa_Debug.G_Stage := 'Building token for Child Elements format.';
		-- Format for messages:
		-- Resource Type: <RT>  Resource : <res>: Message Text
		-- Build string with translated values for resource type, resource
                l_Msg_Token_Value := l_temp_res_type || ': ' || l_res_type_name || ' ' || l_temp_res || ': ' ||
                                     l_res_name || ': ';

	End If;

	Pa_Debug.G_Stage := 'Calling Pa_Utils.Add_Message() procedure.';
	Pa_Utils.Add_Message
		(P_App_Short_Name => 'PA',
		 P_Msg_Name       => P_Error_Msg_Data,
		 P_Token1         => 'MSG_TOKEN',
		 P_Value1         => l_Msg_Token_value);

        Pa_Debug.G_Stage := 'Leaving PopulateErrorStack() procedure.';
        Pa_Debug.TrackPath('STRIP','PopulateErrorStack');

Exception
	When Others Then
		Raise;

End PopulateErrorStack;

End Pa_Rbs_Elements_Pub;

/
