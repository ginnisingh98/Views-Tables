--------------------------------------------------------
--  DDL for Package Body PA_RBS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RBS_PUB" AS
/* $Header: PARBSAPB.pls 120.1 2005/08/19 04:23:04 avaithia noship $*/
/*
* ***************************************************************************************
* API Name: Convert_Missing_Rbs_Header
* Public/Private     : Private
* Procedure/Function : Procedure
* Description:
*     This procedure converts the input values to null if its a G _MISS_VALUE
*      and selects the value from the database if the value being input is null,
*      so that there wouldn't be any change to the data when null is passed as input.
*      The conversions are done for the Rbs_Version_Rec_Typ .
*  Attributes        :
*     INPUT VALUES :
*	    P_Header_Rec	      : The record which hold's the rbs header's record .
*				        This contains the input record.
*           P_Mode                    : The mode in which the procedure is called.Update or create
*                                       1 means update. 0 means create.
*     OUTPUT VALUES :
*
*          X_Header_Rec               : The record which hold's the rbs header record with the
*                                       changed values to the fields of the record.
*          X_Error_Msg	              : The parameter will hold a message if there is an
*                                       error in this API.
* There can be two modes in which this procedure can be called
* Update and create
* P_Mode = 1 means update
* P_Mode = 0 means create
* In Update
* if Update then rbs header id can be present.
* if rbs header id is not present then rbs header name would be present .
* you can retreive the  rbs header id from the rbs header name .
* And then convert all GMiss to the db values.
*
* In create the rbs name would be present
* Convert all missing values to null.
*
* ****************************************************************************************
*/

PROCEDURE Convert_Missing_Rbs_Header
(P_Header_Rec IN 	Rbs_Header_Rec_Typ,
 X_Header_Rec OUT NOCOPY 	Rbs_Header_Rec_Typ, -- 4537865 Added the nocopy hint
 P_Mode       IN        Number,
 X_Error_Msg OUT NOCOPY VARCHAR2)
IS



Cursor C_Rbs_Header_Details(P_Rbs_Header_Id IN Number) IS

Select a.rbs_header_id,
       b.name,
       b.Description,
       a.Effective_From_Date,
       a.Effective_To_Date,
       a.Record_Version_Number
From   pa_rbs_headers_b a,
       pa_rbs_headers_tl b
Where  a.rbs_header_id=P_Rbs_Header_Id
and    b.language = userenv('LANG')
and    a.rbs_header_id=b.rbs_header_id;

Rec_Details C_Rbs_Header_Details%RowType;

l_rbs_header_id NUMBER;
l_rbs_header_name VARCHAR2(200);
l_ERROR    Exception;


BEGIN

      X_Header_Rec :=P_Header_Rec;

       l_rbs_header_id :=P_Header_Rec.Rbs_Header_Id;

       If l_rbs_header_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
          l_rbs_header_id := null;
       End if;

       l_rbs_header_name := P_Header_Rec.Name ;




IF P_Mode = 1 Then
          IF l_rbs_header_id is null Then
          -- Get the header id from the name if the name is not null
             IF  l_rbs_header_name is not null and  l_rbs_header_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              BEGIN
                  Select rbs_header_id
                  into l_rbs_header_id
                  from pa_rbs_headers_tl
                  where name= l_rbs_header_name
                  AND   language = userenv('LANG');
              EXCEPTION
                  WHEN OTHERS THEN
                        Pa_Debug.G_Stage := 'No Rbs Element id was provided.  Add error message to stack.';
                        Pa_Utils.Add_Message(
                                 P_App_Short_Name => 'PA',
                                 P_Msg_Name       => 'PA_RBS_HEADER_NAME_INVALID');

                        Raise l_ERROR;

              END;
             ELSE
              BEGIN
                  Select rbs_header_id
                  into l_rbs_header_id
                  from pa_rbs_headers_b
                  where rbs_header_id = P_Header_Rec.Rbs_Header_Id ;
              EXCEPTION
                  WHEN OTHERS THEN
                        Pa_Debug.G_Stage := 'No Rbs Element id was provided.  Add error message to stack.';
                        Pa_Utils.Add_Message(
                                 P_App_Short_Name => 'PA',
                                 P_Msg_Name       => 'PA_RBS_HEADER_ID_INVALID');

                        Raise l_ERROR;

              END;
             END IF;
          End if;


      IF l_rbs_header_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM and l_rbs_header_id is not null Then
	  OPEN C_Rbs_Header_Details(P_Rbs_Header_Id => l_rbs_header_id);
	  FETCH C_Rbs_Header_Details INTO Rec_Details;
	  CLOSE C_Rbs_Header_Details;

	 If P_Header_Rec.Rbs_Header_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
		X_Header_Rec.Rbs_Header_Id := Rec_Details.Rbs_Header_Id;

	  End If;

	  If P_Header_Rec.Name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
		X_Header_Rec.Name := Rec_Details.Name;

	  End If;

	  If P_Header_Rec.Description = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
		X_Header_Rec.Description := Rec_Details.Description;

	  End If;

	  If P_Header_Rec.Effective_From_Date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE Then
		X_Header_Rec.Effective_From_Date := Rec_Details.Effective_From_Date;

	  End If;

	  If P_Header_Rec.Effective_To_Date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE Then
		X_Header_Rec.Effective_To_Date := Rec_Details.Effective_To_Date;

	  End If;

	  If P_Header_Rec.Record_Version_Number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
		X_Header_Rec.Record_Version_Number := null;

	  End If;


      End If;
 ElsIf P_Mode = 0 Then
          If P_Header_Rec.Rbs_Header_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
		X_Header_Rec.Rbs_Header_Id := null;
	  End If;
	  If P_Header_Rec.Name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
		X_Header_Rec.Name := null;

	  End If;

	  If P_Header_Rec.Description = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
		X_Header_Rec.Description := null;

	  End If;

	  If P_Header_Rec.Effective_From_Date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE Then
		X_Header_Rec.Effective_From_Date := null;

	  End If;

	  If P_Header_Rec.Effective_To_Date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE Then
		X_Header_Rec.Effective_To_Date := null;

	  End If;

	  If P_Header_Rec.Record_Version_Number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
		X_Header_Rec.Record_Version_Number := null;

	  End If;


  End if;

 Exception
    When Others Then
    Null ;
   -- just leave it, let the exception be handled by the table handler.
End Convert_Missing_Rbs_Header;


/*
* ***************************************************************************************
* API Name: Convert_Missing_Rbs_Version
* Public/Private     : Private
* Procedure/Function : Procedure
* Description:
*     This procedure converts the input values to null if its a G _MISS_VALUE
*      and selects the value from the database if the value being input is null,
*      so that there wouldn't be any change to the data when null is passed as input.
*      The conversions are done for the Rbs_Version_Rec_Typ .
*  Attributes        :
*     INPUT VALUES :
*	    P_Version_Rec	      : The record which hold's the rbs version's record .
*				        This contains the input record.
*
*     OUTPUT VALUES :
*
*          X_Version_Rec              : The record which hold's the rbs version record with the
*                                       changed values to the fields of the record.
*          X_Error_Msg	              : The parameter will hold a message if there is an
*                                       error in this API.
*
* There can be two modes in which this procedure can be called
* Update and create
* P_Mode = 1 means update
* P_Mode = 0 means create
* In Update
* if Update then rbs version id can be present.
* if rbs version id is not present then rbs version name would be present .
* you can retreive the  rbs header id from the name .
* And then convert all GMiss to the db values.
*
* In create the rbs name would be present
* Convert all missing values to null.
* ****************************************************************************************
*/
PROCEDURE Convert_Missing_Rbs_Version
(P_Version_Rec IN 	Rbs_Version_Rec_Typ,
 X_Version_Rec OUT NOCOPY	Rbs_Version_Rec_Typ, -- 4537865
 P_Mode       IN        Number,
 X_Error_Msg OUT NOCOPY VARCHAR2)
IS

Cursor C_Rbs_Version_Details(P_Rbs_Version_Id IN Number) IS
 Select a.rbs_version_id, b.name, b.Description,a.Version_Start_Date ,a.Job_Group_Id ,a.Record_Version_Number
 from pa_rbs_versions_b a, pa_rbs_versions_tl b
Where a.rbs_version_id=P_Rbs_version_Id
and a.rbs_version_id=b.rbs_version_id;

Rec_Details C_Rbs_Version_Details%RowType;

l_rbs_version_id NUMBER;
 l_rbs_version_name VARCHAR2(200) ;
BEGIN

 X_Version_Rec :=P_Version_Rec;

l_rbs_version_id :=P_Version_Rec.Rbs_Version_Id;
If l_rbs_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
    l_rbs_version_id := null;
 End if;
 l_rbs_version_name := P_Version_Rec.Name ;




IF P_Mode = 1 Then
          IF l_rbs_version_id is null Then
          -- Get the header id from the name if the name is not null
             IF  l_rbs_version_name is not null and  l_rbs_version_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
              Select rbs_version_id
	      Into l_rbs_version_id
	      From pa_rbs_versions_tl
	      Where name= l_rbs_version_name ;
             End if ;
          End if;

         IF l_rbs_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM and l_rbs_version_id is not null Then
	      OPEN C_Rbs_Version_Details(P_Rbs_Version_Id => l_rbs_version_id);
	      FETCH C_Rbs_Version_Details INTO Rec_Details;
	      CLOSE C_Rbs_Version_Details;

		If P_Version_Rec.Rbs_Version_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
		   X_Version_Rec.Rbs_Version_Id := Rec_Details.Rbs_Version_Id;

	       End If;
	       If P_Version_Rec.Name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
		   X_Version_Rec.Name := Rec_Details.Name;

	       End If;

	         If P_Version_Rec.Description = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
		      X_Version_Rec.Description := Rec_Details.Description;

	        End If;

	          If P_Version_Rec.Version_Start_Date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE Then
		       X_Version_Rec.Version_Start_Date := Rec_Details.Version_Start_Date;

	         End If;

	          If P_Version_Rec.Job_Group_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
		        X_Version_Rec.Job_Group_Id := Rec_Details.Job_Group_Id;

	         End If;

	        If P_Version_Rec.Record_Version_Number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
		      X_Version_Rec.Record_Version_Number := Rec_Details.Record_Version_Number;

	        End If;
        End If;
  Elsif P_Mode = 0 Then
           If P_Version_Rec.Rbs_Version_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
		X_Version_Rec.Rbs_Version_Id := null;
	  End If;

	  If P_Version_Rec.Name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
		X_Version_Rec.Name := null;

	  End If;

	  If P_Version_Rec.Description = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
		X_Version_Rec.Description := null;

	  End If;

	  If P_Version_Rec.Version_Start_Date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE Then
		X_Version_Rec.Version_Start_Date := null;

	  End If;

	  If P_Version_Rec.Job_Group_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
		X_Version_Rec.Job_Group_Id := null;

	  End If;

	  If P_Version_Rec.Record_Version_Number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
		X_Version_Rec.Record_Version_Number := null;

	  End If;


 End if;
  Exception
   When Others  Then
   Null;
   -- just leave it, let the exception be handled by the table handler.

End Convert_Missing_Rbs_Version;


/*
* ***************************************************************************************
* API Name: Convert_Missing_Rbs_Elements
* Public/Private     : Private
* Procedure/Function : Procedure
* Description:
*     This procedure converts the input values to null if its a G _MISS_VALUE
*      and selects the value from the database if the value being input is null,
*      so that there wouldn't be any change to the data when null is passed as input.
*      The conversions are done for the Rbs_Elements_Rec_Typ .
*  Attributes        :
*     INPUT VALUES :
*	    P_Elements_Tbl          : The table which hold's the rbs element's records .
*				        This contains the input records.
*
*     OUTPUT VALUES :
*
*          X_Elements_Tbl           : The table which hold's the rbs element's records with the
*                                     changed values
*          X_Error_Msg	            : The parameter will hold a message if there is an
*                                     error in this API.
*
* ****************************************************************************************
*/
PROCEDURE Convert_Missing_Rbs_Elements
(P_Elements_Tbl IN 	Rbs_Elements_Tbl_Typ,
 X_Elements_Tbl OUT NOCOPY 	Rbs_Elements_Tbl_Typ, -- 4537865
 P_Mode         IN      Number,
 X_Error_Msg OUT NOCOPY VARCHAR2)
IS

Cursor C_Rbs_Elements_Details(P_Rbs_Element_Id IN Number) IS

Select
 a.Rbs_Version_Id,
 a.rbs_Element_Id ,
 a.Parent_Element_Id ,
 a.Resource_Type_Id,
 a.Resource_Source_Id ,
 b.resource_name Resource_Source_Code,
  a.Rbs_Level,
  a.Record_Version_Number,
  a.Order_Number
  From pa_rbs_elements a ,
  pa_rbs_element_map b
Where rbs_element_id=P_Rbs_Element_Id
and a.resource_source_id =b.resource_id(+) ;



/*Rbs_Version_Id		    Number(15)    Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        Rbs_Element_Id              Number(15)    Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        Parent_Element_Id           Number(15)    Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        Resource_Type_Id            Number(15),
        Resource_Source_Id          Number(15)    Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
	Resource_Source_Code        Varchar2(240) Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
        Order_Number                Number(15)    Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        Process_Type     	    Varchar2(1),
	Rbs_Level		    Number(15),
	Record_Version_Number       Number(15)    Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
	Parent_Ref_Element_Id       Number(15)    Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
	Rbs_Ref_Element_Id          Number(15)    Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM);
*/
Rec_Details C_Rbs_Elements_Details%RowType;

l_rbs_version_id NUMBER;
l_rbs_element_id NUMBER;

BEGIN

 X_Elements_Tbl :=P_Elements_Tbl;

/* get the rbs version id from the first record of the table */

IF P_Elements_Tbl.count >0 then

 IF P_Mode = 1 Then

	  For i in P_Elements_Tbl.First .. P_Elements_Tbl.Last
	   Loop
	     l_rbs_element_id := P_Elements_Tbl(i).Rbs_Element_Id ;
              OPEN C_Rbs_Elements_Details(P_Rbs_Element_Id => l_rbs_element_id);

	       IF C_Rbs_Elements_Details%NOTFOUND Then

	          CLOSE C_Rbs_Elements_Details;
	        Else
		   FETCH C_Rbs_Elements_Details INTO Rec_Details;
                   CLOSE C_Rbs_Elements_Details;

		      If P_Elements_Tbl(i).Rbs_Version_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
			X_Elements_Tbl(i).Rbs_Version_Id := Rec_Details.Rbs_Version_Id;

		       End If;

		     If P_Elements_Tbl(i).Parent_Element_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
			X_Elements_Tbl(i).Parent_Element_Id := Rec_Details.Parent_Element_Id;

		      End If;

		      If P_Elements_Tbl(i).Resource_Source_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
			X_Elements_Tbl(i).Resource_Source_Id := Rec_Details.Resource_Source_Id;

		      End If;



                      If P_Elements_Tbl(i).Resource_Source_Code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
			X_Elements_Tbl(i).Resource_Source_Code := Rec_Details.Resource_Source_Code;

		     End If;



		      If P_Elements_Tbl(i).Order_Number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
			X_Elements_Tbl(i).Order_Number := Rec_Details.Order_Number;

		     End If;



		      If P_Elements_Tbl(i).Record_Version_Number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
			X_Elements_Tbl(i).Record_Version_Number := Rec_Details.Record_Version_Number;

		     End If;

	 	     If P_Elements_Tbl(i).Process_Type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
			X_Elements_Tbl(i).Process_Type := null;
		    End if;


		    If P_Elements_Tbl(i).Rbs_Level = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  Then
			X_Elements_Tbl(i).Rbs_Level := Rec_Details.Rbs_Level;

		    End If;

		    If P_Elements_Tbl(i).Resource_Type_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
			X_Elements_Tbl(i).Resource_Type_Id := Rec_Details.Resource_Type_Id;

		   End If;


		    If P_Elements_Tbl(i).Parent_Ref_Element_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
			X_Elements_Tbl(i).Parent_Ref_Element_Id := null;

		    End If;

		    If P_Elements_Tbl(i).Rbs_Ref_Element_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
			X_Elements_Tbl(i).Rbs_Ref_Element_Id := null;

		    End If;
               End if ;
	    End Loop;

     ElsIf P_Mode =0  Then
          For i in P_Elements_Tbl.First .. P_Elements_Tbl.Last
	     Loop
		If P_Elements_Tbl(i).Rbs_Version_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
			X_Elements_Tbl(i).Rbs_Version_Id := null;

		End If;

		If P_Elements_Tbl(i).Rbs_Element_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
			X_Elements_Tbl(i).Rbs_Element_Id := null;

		End If;



		If P_Elements_Tbl(i).Parent_Element_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
			X_Elements_Tbl(i).Parent_Element_Id := null;

		End If;



		If P_Elements_Tbl(i).Resource_Source_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
			X_Elements_Tbl(i).Resource_Source_Id := null;

		End If;



                If P_Elements_Tbl(i).Resource_Source_Code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
			X_Elements_Tbl(i).Resource_Source_Code := null;

		End If;



		If P_Elements_Tbl(i).Order_Number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
			X_Elements_Tbl(i).Order_Number := null;

		End If;



		If P_Elements_Tbl(i).Record_Version_Number = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
			X_Elements_Tbl(i).Record_Version_Number := null;

		End If;

	 	If P_Elements_Tbl(i).Process_Type = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then
			X_Elements_Tbl(i).Process_Type := null;

		End If;


		If P_Elements_Tbl(i).Rbs_Level = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  Then
			X_Elements_Tbl(i).Rbs_Level := null;

		End If;

		If P_Elements_Tbl(i).Resource_Type_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
			X_Elements_Tbl(i).Resource_Type_Id := null;

		End If;

		If P_Elements_Tbl(i).Parent_Ref_Element_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
			X_Elements_Tbl(i).Parent_Ref_Element_Id := null;

		End If;

		If P_Elements_Tbl(i).Rbs_Ref_Element_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
			X_Elements_Tbl(i).Rbs_Ref_Element_Id := null;

		End If;
        End Loop;
     End If;
End If;
End Convert_Missing_Rbs_Elements;

/*
****************************************************************************************
* API Name: Init_Rbs_Processing
* Description:
*     This procedure initialize global pl/sql records and tables and
*     other variables.  It is use solely in conjunction with option 2
*     identified in the package description on how to use.
* ****************************************************************************************
*/
Procedure Init_Rbs_Processing  IS

     l_Api_Name CONSTANT Varchar2(30) := 'Init_Rbs_Processing';

Begin

     Fnd_Msg_Pub.initialize;

     G_Rbs_Hdr_Rec        := G_Empty_Rbs_Hdr_Rec;
     G_Rbs_Hdr_Out_Rec    := G_Empty_Rbs_Hdr_Out_Rec;
     G_Rbs_Ver_Rec        := G_Empty_Rbs_Ver_Rec;
     G_Rbs_Ver_Out_Rec    := G_Empty_Rbs_Ver_Out_Rec;
     G_Rbs_Elements_Tbl.Delete;
     G_Rbs_Elements_Count := 0;

Exception
     When Others Then

        If Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_Msg_Lvl_UnExp_Error) Then
            Fnd_Msg_Pub.Add_Exc_Msg
            (   P_Pkg_Name              =>  G_Pkg_Name  ,
                P_Procedure_Name        =>  l_Api_Name );

        End If;
	 Rollback;
END Init_Rbs_Processing;

/*
********************************************************************************************
* API Name: Create_Rbs()
*  Description:
*     At a minimum this API will create the header, version and root
*     node/element records for the Resource Breakdown Structure.
*     Otherwise, this API will create a complete Resource Breakdown
*     Structure based on the data passed in.
*
*
* *******************************************************************************************
*/
Procedure Create_Rbs (
        P_Commit             IN         Varchar2 Default Fnd_Api.G_False,
        P_Init_Msg_List      IN         Varchar2 Default Fnd_Api.G_True,
        P_API_Version_Number IN         Number,
        P_Header_Rec         IN         Pa_Rbs_Pub.Rbs_Header_Rec_Typ,
        P_Version_Rec        IN         Pa_Rbs_Pub.Rbs_Version_Rec_Typ Default G_Empty_Rbs_Ver_Rec,
        P_Elements_Tbl       IN         Rbs_Elements_Tbl_Typ Default G_Empty_Rbs_Elements_Tbl,
        X_Rbs_Header_Id	     OUT NOCOPY Number,
        X_Rbs_Version_Id     OUT NOCOPY Number,
        X_Elements_Tbl       OUT NOCOPY Rbs_Elements_Tbl_Typ,
        X_Return_Status      OUT NOCOPY Varchar2,
        X_Msg_Count          OUT NOCOPY Number,
        X_Error_Msg_Data     OUT NOCOPY Varchar2)

Is

        i                       Number                          := Null;
        l_Api_Name              Varchar2(30)                    := 'Create_Rbs';
        l_Resource_Source_Id    Number                          := Null;
        l_Dummy		        Varchar2(30)		        := Null;
        l_Record_Version_Number Number                          := Null;

        l_Rbs_Header_Id         Number(15)                      := Null;
        l_Rbs_Version_Id        Number(15)                      := Null;
	l_Rbs_Element_Id        Number(15)                      := Null;
        l_Msg_Count             Number                          := 0;
        l_ERROR                 Exception;

        l_msg_data              Varchar2(2000)                  := Null;
        l_data 	                Varchar2(2000)                  := Null;
        l_msg_index_out         Number;
        l_count                 Number;
        l_Max_Rbs_Level         Number                          := 0;
        l_Root_Count            Number                          := 0;

	l_Header_Rec					Rbs_Header_Rec_Typ;
	l_Version_Rec					Rbs_Version_Rec_Typ;
	l_Elements_Tbl					Rbs_Elements_Tbl_Typ;
        l_Mode                  Number                           := 0;

        Cursor c1 Is
        Select
                Max(Rbs_Level)
        From
                Pa_Rbs_Nodes_Temp;

        Cursor c2 (P_Rbs_Level IN Number) Is
        Select
                Rbs_Version_Id,
                Rbs_Element_Id,
                Parent_Element_Id,
                Resource_Type_Id,
                Resource_Source_Id,
                Resource_Source_Code,
                Order_Number,
                Process_Type,
                Rbs_Level,
                Record_Version_Number,
                Parent_Ref_Element_Id,
                Rbs_Ref_Element_Id,
		Record_Index
        From
                Pa_Rbs_Nodes_Temp
        Where
                Rbs_Level = P_Rbs_Level
        Order By
                Rbs_Ref_Element_Id;

        Element_Rec c2%RowType;

        Cursor c3 Is
        Select
                Count(*)
        From
                Pa_Rbs_Nodes_Temp
        Where
                Rbs_Level = 1;

Begin

        Pa_Debug.G_Path := ' ';

        Pa_Debug.G_Stage := 'Entering Create_Rbs().';
        Pa_Debug.TrackPath('ADD','Create_Rbs');

        Pa_Debug.G_Stage := 'Call Compatibility API.';
        If Not Fnd_Api.Compatible_API_Call (
                        Pa_Rbs_Pub.G_Api_Version_Number,
                        P_Api_Version_Number,
                        l_Api_Name,
                        Pa_Rbs_Pub.G_Pkg_Name) Then

                Raise Fnd_Api.G_Exc_Unexpected_Error;

        End If;

        Pa_Debug.G_Stage := 'Check if need to initialize the message stack(T-True,F-False) - ' || P_Init_Msg_List;
        If Fnd_Api.To_Boolean(nvl(P_Init_Msg_List,Fnd_Api.G_True)) Then

                Pa_Debug.G_Stage := 'Initializing message stack by calling Fnd_Msg_Pub.Initialize().';
                Fnd_Msg_Pub.Initialize;

        End If;

        Pa_Debug.G_Stage := 'Initialize error handling variables.';
        X_Error_Msg_Data := Null;
        X_Msg_Count      := 0;
        X_Return_Status  := Fnd_Api.G_Ret_Sts_Success;

	/***********************************
		call to covert missing
	*************************************/
		Pa_Rbs_Pub.Convert_Missing_Rbs_Header(
				P_Header_Rec => P_Header_Rec,
				X_Header_Rec => l_Header_Rec,
				P_Mode       => l_Mode ,
				X_Error_Msg	    => X_Error_Msg_Data);

		Pa_Rbs_Pub.Convert_Missing_Rbs_Version(
				P_Version_Rec => P_Version_Rec,
				X_Version_Rec => l_Version_Rec,
				P_Mode       => l_Mode ,
				X_Error_Msg	    => X_Error_Msg_Data);

		Pa_Rbs_Pub.Convert_Missing_Rbs_Elements(
				P_Elements_Tbl => P_Elements_Tbl,
				X_Elements_Tbl => l_Elements_Tbl,
				P_Mode       => l_Mode ,
				X_Error_Msg	    => X_Error_Msg_Data);





        /***********************************
          Create Header,Version,Root Element
         ***********************************/

        Pa_Debug.G_Stage := 'Create Header Record by calling Pa_Rbs_Header_Pvt.Insert_Header() procedure.';
        Pa_Rbs_Header_Pub.Insert_Header(
                P_Commit             => Fnd_Api.G_False,
                P_Init_Msg_List      => Fnd_Api.G_False,
                P_API_Version_Number => P_API_Version_Number,
                P_Name               => l_Header_Rec.Name,
                P_Description        => Nvl(l_Header_Rec.Description,l_Header_Rec.Name),
                P_EffectiveFrom      => l_Header_Rec.Effective_From_Date,
                P_EffectiveTo        => l_Header_Rec.Effective_To_Date,
                X_Rbs_Header_Id      => l_Rbs_Header_Id,
                X_Rbs_Version_Id     => l_Rbs_Version_Id,
                X_Rbs_Element_Id     => l_Rbs_Element_Id,
                X_Return_Status      => X_Return_Status,
                X_Msg_Data           => X_Error_Msg_Data,
                X_Msg_Count          => l_Msg_Count);

       If X_Error_Msg_Data is Not Null Then

                Pa_Debug.G_Stage := 'The Pa_Rbs_Header_Pub.Insert_Header() procedure returned errror.';
                Raise l_ERROR;

        Else

                G_Rbs_Hdr_Out_Rec.Rbs_Header_Id := l_Rbs_Header_Id;
                X_Rbs_Header_Id := l_Rbs_Header_Id;
	--	G_Rbs_Hdr_Out_Rec.Return_Status := Fnd_Api.G_Ret_Sts_Success;

                G_Rbs_Ver_Out_Rec.Rbs_Version_Id := l_Rbs_Version_Id;
                X_Rbs_Version_Id := l_Rbs_Version_Id;
               -- G_Rbs_Ver_Out_Rec.Return_Status := Fnd_Api.G_Ret_Sts_Success;

        End If;

        /***************************
           Process the Version Rec
         ***************************/

        -- Since the Version Record is already created we want to check and see if we need to update the record or not.
        -- That is determined by if there is any data passed into the global pl/sql version table.
        Pa_Debug.G_Stage := 'Check if the version record is not null.';
        If l_Version_Rec.Name is Not Null or
           l_Version_Rec.Version_Start_Date is Not Null or
           l_Version_Rec.Job_Group_Id is Not Null or
           l_Version_Rec.Description is Not Null Then

              Pa_Debug.G_Stage := 'Calling Pa_Rbs_Versions_Pub.Update_Working_Version() API.';
              Pa_Rbs_Versions_Pub.Update_Working_Version(
                      P_Commit                => Fnd_Api.G_False,
                      P_Init_Msg_List         => Fnd_Api.G_False,
                      P_API_Version_Number    => P_Api_Version_Number,
                      P_RBS_Version_Id        => l_Rbs_Version_Id,
                      P_Name                  => Nvl(l_Version_Rec.Name,l_Header_Rec.Name),
                      P_Description           => Nvl(l_Version_Rec.Description,Nvl(l_Header_Rec.Description,l_Header_Rec.Name)),
                      P_Version_Start_Date    => Nvl(l_Version_Rec.Version_Start_Date,l_Header_Rec.Effective_From_Date),
                      P_Job_Group_Id          => l_Version_Rec.Job_Group_Id,
                      P_Record_Version_Number => 1,
                      P_Init_Debugging_Flag   => 'N',
                      X_Record_Version_Number => l_Record_Version_Number,
                      X_Return_Status         => X_Return_Status,
                      X_Msg_Count             => l_Msg_Count,
                      X_Error_Msg_Data        => X_Error_Msg_Data);

              If X_Error_Msg_Data is Not Null Then

                      Pa_Debug.G_Stage := 'The Pa_Rbs_Versions_Pub.Update_Working_Version() procedure returned errror.  ' ||
                                            'Add error message to stack.';
                      Raise l_ERROR;

                End If;

        End If;

        /*****************************
           Process the Elements/Nodes
         *****************************/

        Pa_Debug.G_Stage := 'Do we have element/nodes to process.';
        If l_Elements_Tbl.Count > 0 Then

                Pa_Debug.G_Stage := 'Copy elements pl/sql table to out parameter.';
                X_Elements_Tbl := l_Elements_Tbl;

                -- Put the pl/sql table into a temp table, checking for problems before inserting.
                Pa_Debug.G_Stage := 'Start loop thru pl/sql table for elements/nodes processing.';
                For i in l_Elements_Tbl.First .. l_Elements_Tbl.Last
                Loop

                        Pa_Debug.G_Stage := 'Check if we have a rbs reference element id to work with.';
                        If l_Elements_Tbl(i).Rbs_Ref_Element_Id is Null Then

                                Pa_Debug.G_Stage := 'No Rbs Element id was provided.  Add error message to stack.';
                                Pa_Utils.Add_Message(
                                        P_App_Short_Name => 'PA',
                                        P_Msg_Name       => 'PA_RBS_REF_ELEMENT_ID_REQ');

                                Raise l_ERROR;

                        End If;

                        Pa_Debug.G_Stage := 'Check if we have a parent reference element id to work with.';
                        If l_Elements_Tbl(i).Parent_Ref_Element_Id Is Null And
                           l_Elements_Tbl(i).Rbs_Level not in (1,2) Then

                                Pa_Debug.G_Stage := 'No parent reference element id was provided.  Add error message to stack.';
                                Pa_Utils.Add_Message(
                                        P_App_Short_Name => 'PA',
                                        P_Msg_Name       => 'PA_RBS_REF_PARENT_ID_REQ');

                                Raise l_ERROR;

                        End If;

                        Pa_Debug.G_Stage := 'Check if we have a rbs level to work with.';
                        If l_Elements_Tbl(i).Rbs_Level is Null Then

                                Pa_Debug.G_Stage := 'Rbs level is null.  Add error message to stack.';
                                Pa_Utils.Add_Message(
                                        P_App_Short_Name => 'PA',
                                        P_Msg_Name       => 'PA_RBS_RBS_LEVEL_REQ');

                                Raise l_ERROR;

                        End If;

                        Pa_Debug.G_Stage := 'Check if we have a process type that we can work with.';
                        If l_Elements_Tbl(i).Process_Type is Null or
                           l_Elements_Tbl(i).Process_Type <> 'A' Then

                                Pa_Debug.G_Stage := 'Process Type is null or not A.  Add error message to stack.';
                                Pa_Utils.Add_Message(
                                        P_App_Short_Name => 'PA',
                                        P_Msg_Name       => 'PA_RBS_PRC_TYPE_INVALID');

                                Raise l_ERROR;

                        End If;

                        Pa_Debug.G_Stage := 'Insert record into pa_rbs_nodes_temp table for further processing.';
                        Insert into Pa_Rbs_Nodes_Temp (
                                Rbs_Version_Id,
                                Rbs_Element_Id,
                                Parent_Element_Id,
                                Resource_Type_Id,
                                Resource_Source_Id,
                                Resource_Source_Code,
                                Order_Number,
                                Process_Type,
                                Rbs_Level,
                                Record_Version_Number,
                                Parent_Ref_Element_Id,
                                Rbs_Ref_Element_Id,
                                Record_Index )
                        Values (
                                l_Rbs_Version_Id,
                                Decode(l_Elements_Tbl(i).Rbs_Level,1,l_Rbs_Element_Id,Null),
                                Decode(l_Elements_Tbl(i).Rbs_Level,2,l_Rbs_Element_Id,Null),
                                Decode(l_Elements_Tbl(i).Rbs_Level,1,-1,l_Elements_Tbl(i).Resource_Type_Id),
                                Decode(l_Elements_Tbl(i).Rbs_Level,1,l_Rbs_Version_Id,l_Elements_Tbl(i).Resource_Source_Id),
                                l_Elements_Tbl(i).Resource_Source_Code,
                                l_Elements_Tbl(i).Order_Number,
                                Decode(l_Elements_Tbl(i).Rbs_Level,1,'R',l_Elements_Tbl(i).Process_Type),
                                l_Elements_Tbl(i).Rbs_Level,
                                l_Elements_Tbl(i).Record_Version_Number,
                                l_Elements_Tbl(i).Parent_Ref_Element_Id,
                                l_Elements_Tbl(i).Rbs_Ref_Element_Id,
                                i );

                        If l_Elements_Tbl(i).Rbs_Level = 1 Then

                                -- This is needed by the Fetch_Rbs_Element() procedure.
                                -- The root element/node is not process beyond this point.
                                -- It is created once for a RBS and is never touched again.
                                -- Default values are used for the element/node and is already created.
                                G_Rbs_Elements_Out_Tbl(i).Rbs_Element_Id := l_Rbs_Element_Id;
                               -- G_Rbs_Elements_Out_Tbl(i).Return_Status  := Fnd_Api.G_Ret_Sts_Success;

                                X_Elements_Tbl(i).Rbs_Element_Id   := l_Rbs_Element_Id;
                                X_Elements_Tbl(i).Resource_Type_Id := -1;
                                X_Elements_Tbl(i).Resource_Source_Id := l_Rbs_Version_Id;
                                X_Elements_Tbl(i).Resource_Source_Code := Null;

                        End If;

                End Loop;

                -- Check to see if have a root node passed in the pl/sql table.  This is required
                -- even though they have minimul control over it values.
                -- Root element/node is always level one.
                Pa_Debug.G_Stage := 'Open c3 to get count of rbs level 1 records.';
                Open c3;
                Fetch c3 Into l_Root_Count;
                Close c3;

                If l_Root_Count = 0 Then

                        Pa_Debug.G_Stage := 'No root element/node provided.  Add error message to stack.';
                        Pa_Utils.Add_Message(
                                P_App_Short_Name => 'PA',
                                P_Msg_Name       => 'PA_RBS_NO_ROOT_ELEMENT');

                        Raise l_ERROR;

                End If;

                -- Check to see if provide more than a single root element.  This is not allowed.
                If l_Root_Count > 1 Then

                        Pa_Debug.G_Stage := 'Multiple root elements/nodes provided.  Add error message to stack.';
                        Pa_Utils.Add_Message(
                                P_App_Short_Name => 'PA',
                                P_Msg_Name       => 'PA_RBS_MULTI_ROOT_ELEMENTS');

                        Raise l_ERROR;

                End If;

                Pa_Debug.G_Stage := 'Open c1 cursor to get max rbs level.';
                Open c1;
		Fetch c1 Into l_Max_Rbs_Level;
                Close c1;

                Pa_Debug.G_Stage := 'Start rbs level loop.';
                For i in 2 .. l_Max_Rbs_Level
                Loop

                        Pa_Debug.G_Stage := 'Open c2 cursor for current rbs level elements/nodes to process.';
                        Open c2(P_Rbs_Level => i);

                        Pa_Debug.G_Stage := 'Start loop to process the current rbs level elements/nodes.';
                        Loop

                                Pa_Debug.G_Stage := 'Fetch c2 record.';
                                Fetch c2 Into Element_Rec;
                                Exit When c2%NotFound;

                                Pa_Debug.G_Stage := 'Check if resource source id is null.';
                                If Element_Rec.Resource_Source_Id is Null Then

                                        Pa_Debug.G_Stage := 'Get Resource Source Id using source code.';
                                        Pa_Rbs_Elements_Utils.GetResSourceId(
                                                P_Resource_Type_Id     => Element_Rec.Resource_Type_Id,
                                                P_Resource_Source_Code => Element_Rec.Resource_Source_Code,
                                                X_Resource_Source_Id   => l_Resource_Source_Id);

IF l_Resource_Source_Id IS NULL THEN
   Pa_Utils.Add_Message(P_App_Short_Name => 'PA',
                        P_Msg_Name       => 'PA_RBS_NO_RESOURCE_SOURCE_ID');

            Raise l_ERROR;
END IF;
                                Else

                                        Pa_Debug.G_Stage := 'Assign resource source id.';
                                        l_Resource_Source_Id := Element_Rec.Resource_Source_Id;

                                End If;

                                Pa_Debug.G_Stage := 'Call Process_Rbs_Elements() procedure.';
                                Pa_Rbs_Elements_Pvt.Process_Rbs_Element(
                	                P_RBS_Version_Id        => Element_Rec.Rbs_Version_Id,
                	                P_Parent_Element_Id     => Element_Rec.Parent_Element_Id,
                	                P_Element_Id            => Element_Rec.Rbs_Element_Id,
                	                P_Resource_Type_Id      => Element_Rec.Resource_Type_Id,
                	                P_Resource_Source_Id    => l_Resource_Source_Id,
                	                P_Order_Number          => Element_Rec.Order_Number,
                	                P_Process_Type          => Element_Rec.Process_Type,
			                X_Rbs_Element_Id        => l_Rbs_Element_Id,
                                        X_Error_Msg_Data        => X_Error_Msg_Data );

                                If X_Error_Msg_Data is not null Then

                                        Pa_Debug.G_Stage := 'The Process_Rbs_Elements() procedure returned error.  ' ||
                                                              'Assign error message to the stack.';
                                        Pa_Rbs_Pub.PopulateErrorStack(
                                                P_Ref_Element_Id => Element_Rec.Rbs_Ref_Element_Id,
                                                P_Element_Id     => Element_Rec.Rbs_Element_Id,
                                                P_Process_Type   => Element_Rec.Process_Type,
                                                P_Error_Msg_Data => X_Error_Msg_Data);

                                        Raise l_ERROR;

                                End If;

                                -- now need to update the temp recs with the element id just created
                                Pa_Debug.G_Stage := 'Update the rbs_element_id in the pa_rbs_nodes_temp table.';
                                Update Pa_Rbs_Nodes_Temp
                                Set
                                        Rbs_Element_Id = l_Rbs_Element_Id
                                Where
                                        Rbs_Ref_Element_Id = Element_Rec.Rbs_Ref_Element_Id;

                                Pa_Debug.G_Stage := 'Update the parent_element_id in the pa_rbs_nodes_temp table where needed.';
                                Update Pa_Rbs_Nodes_Temp
                                Set
                                        Parent_Element_Id = l_Rbs_Element_Id
                                Where
                                        Parent_Ref_Element_Id = Element_Rec.Rbs_Ref_Element_Id;

				-- The Fetch_Rbs_Element() procedure needs this done.
                                Pa_Debug.G_Stage := 'Assign the rbs_element_id and status to global elements out table.';
                                G_Rbs_Elements_Out_Tbl(Element_Rec.Record_Index).Rbs_Element_Id := l_Rbs_Element_Id;
                              --  G_Rbs_Elements_Out_Tbl(Element_Rec.Record_Index).Return_Status  := Fnd_Api.G_Ret_Sts_Success;

                                Pa_Debug.G_Stage := 'Assign the rbs_element_id and parent_id to the x_element_tbl out parameter.';
                                X_Elements_Tbl(Element_Rec.Record_Index).Rbs_Element_Id    := l_Rbs_Element_Id;
                                X_Elements_Tbl(Element_Rec.Record_Index).Parent_Element_Id := Element_Rec.Parent_Element_Id;

                         End Loop;
                         Close c2;

                 End Loop;

        End If;  -- l_Elements_Tbl.Count > 0

        Pa_Debug.G_Stage := 'Check to do commit(T-True,F-False) - ' || P_Commit;
        If Fnd_Api.To_Boolean(Nvl(P_Commit,Fnd_Api.G_True)) Then

                Commit;

        End If;

        Pa_Debug.G_Stage := 'Leaving Create_Rbs() procedure.';
        Pa_Debug.TrackPath('STRIP','Create_Rbs');

Exception
        When l_ERROR Then
              l_Msg_Count := Fnd_Msg_Pub.Count_Msg;
              If l_Msg_Count = 1 Then
                   Pa_Interface_Utils_Pub.Get_Messages(
                        P_Encoded       => Fnd_Api.G_True,
                        P_Msg_Index     => 1,
                        P_Msg_Count     => l_Msg_Count,
                        P_Msg_Data      => l_Msg_Data,
                        P_Data          => l_Data,
                        P_Msg_Index_Out => l_Msg_Index_Out);
                   X_Error_Msg_Data := l_Data;
                   X_Msg_Count      := l_Msg_Count;
              Else
                   X_Msg_Count := l_Msg_Count;
              End If;
              X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
              G_Rbs_Ver_Out_Rec := G_Empty_Rbs_Ver_Out_Rec;
              G_Rbs_Elements_Out_Tbl.Delete;
              G_Rbs_Hdr_Out_Rec.Rbs_Header_Id := l_Rbs_Header_Id;
           --   G_Rbs_Hdr_Out_Rec.Return_Status := Fnd_Api.G_Ret_Sts_Error;
              G_Rbs_Elements_Count := 0;
              Rollback;
        When Others Then
              X_Return_Status := Fnd_Api.G_Ret_Sts_UnExp_Error;
              X_Msg_Count := 1;
              X_Error_Msg_Data := Pa_Debug.G_Path || '::' || Pa_Debug.G_Stage || ':' || SqlErrm;
              G_Rbs_Ver_Out_Rec := G_Empty_Rbs_Ver_Out_Rec;
              G_Rbs_Elements_Out_Tbl.Delete;
              G_Rbs_Hdr_Out_Rec.Rbs_Header_Id := l_Rbs_Header_Id;
           --   G_Rbs_Hdr_Out_Rec.Return_Status := Fnd_Api.G_Ret_Sts_UnExp_Error;
              G_Rbs_Elements_Count := 0;
              Rollback;

End Create_Rbs;

/*
*********************************************************************************
* API Name: Update_Rbs()
* Description:
*   This API can be used to update the RBS header, RBS Version, or the
*   RBS Element/Node records or a combination of them.
*
* ********************************************************************************
*/
Procedure Update_Rbs(
        P_Commit             IN         Varchar2 Default Fnd_Api.G_False,
        P_Init_Msg_List      IN         Varchar2 Default Fnd_Api.G_True,
        P_API_Version_Number IN         Number,
        P_Header_Rec         IN         Pa_Rbs_Pub.Rbs_Header_Rec_Typ,
        P_Version_Rec        IN         Pa_Rbs_Pub.Rbs_Version_Rec_Typ,
        P_Elements_Tbl       IN         Rbs_Elements_Tbl_Typ,
        X_Elements_Tbl       OUT NOCOPY Rbs_Elements_Tbl_Typ,
        X_Return_Status      OUT NOCOPY Varchar2,
        X_Msg_Count          OUT NOCOPY Number,
        X_Error_Msg_Data     OUT NOCOPY Varchar2)

Is

        i                       Number                          := Null;
        l_Api_Name              Varchar2(30)                    := 'Update_Rbs';
        l_Resource_Source_Id    Number                          := Null;
        l_Dummy		        Varchar2(30)		        := Null;
        l_Record_Version_Number Number                          := Null;

        l_Rbs_Header_Id         Number(15)                      := Null;
	l_Rbs_Element_Id        Number(15)                      := Null;
        l_Msg_Count             Number                          := 0;
        l_ERROR                 Exception;

        l_msg_data              Varchar2(2000)                  := Null;
        l_data 	                Varchar2(2000)                  := Null;
        l_msg_index_out         Number;
        l_count                 Number;
        l_Max_Rbs_Level         Number                          := 0;
	l_process_type_index    Number                          := 0;  -- 1=D delete , 2=U update , 3=A add
        l_Process_Type          Varchar2(1)                     := Null;
        l_Root_Count            Number                          := 0;
	l_Header_Rec					Rbs_Header_Rec_Typ;
	l_Version_Rec					Rbs_Version_Rec_Typ;
	l_Elements_Tbl					Rbs_Elements_Tbl_Typ;
        l_Mode                  Number                           := 1;

        l_status_code           Varchar2(30);
        l_validate              Varchar2(1);

        Cursor c1 Is
        Select
                Max(Rbs_Level)
        From
                Pa_Rbs_Nodes_Temp;

        Cursor c2 (P_Rbs_Level IN Number,
                   P_Process_Type IN Varchar2) Is
        Select
                Rbs_Version_Id,
                Rbs_Element_Id,
                Parent_Element_Id,
                Resource_Type_Id,
                Resource_Source_Id,
                Resource_Source_Code,
                Order_Number,
                Process_Type,
                Rbs_Level,
                Record_Version_Number,
                Parent_Ref_Element_Id,
                Rbs_Ref_Element_Id,
                Record_Index
        From
                Pa_Rbs_Nodes_Temp
        Where
                Rbs_Level = P_Rbs_Level
        And     Process_Type = P_Process_Type
        Order By
                Rbs_Ref_Element_Id;

        Element_Rec c2%RowType;

        Cursor c3 Is
        Select
                Count(*)
        From
                Pa_Rbs_Nodes_Temp
        Where
                Rbs_Level = 1;

        Cursor rbs_header_cursor (P_header_id In Number) Is
        Select
                tl.Name,
                tl.Description,
                b.Effective_From_Date,
                b.Effective_To_Date,
                b.record_version_number
        From
                Pa_Rbs_Headers_B b,
                Pa_Rbs_Headers_TL tl
        Where
                b.Rbs_Header_Id = p_header_id
        And     b.Rbs_Header_Id = tl.Rbs_Header_Id
        AND     tl.language = userenv('LANG');

        l_old_header_rec rbs_header_cursor%RowType;

        Cursor rbs_version_cursor(P_Version_Id IN Number) Is
        Select
                tl.Name,
                tl.Description,
                b.Version_Start_Date,
                b.Version_End_Date,
                b.Job_Group_Id,
                b.status_code,
                b.record_version_number
        From
                Pa_Rbs_Versions_B b,
                Pa_Rbs_Versions_TL tl
        Where
                b.Rbs_Version_Id = p_version_id
        And     b.Rbs_Version_Id = tl.Rbs_Version_Id;

        l_old_version_rec rbs_version_cursor%RowType;

Begin

        Pa_Debug.G_Path := ' ';

        Pa_Debug.G_Stage := 'Entering Update_Rbs().';
        Pa_Debug.TrackPath('ADD','Update_Rbs');

        Pa_Debug.G_Stage := 'Call Compatibility API.';
        If Not Fnd_Api.Compatible_API_Call (
                        Pa_Rbs_Pub.G_Api_Version_Number,
                        P_Api_Version_Number,
                        l_Api_Name,
                        Pa_Rbs_Pub.G_Pkg_Name) Then

                Raise Fnd_Api.G_Exc_Unexpected_Error;

        End If;

        Pa_Debug.G_Stage := 'Check if need to initialize the message stack(T-True,F-False) - ' || P_Init_Msg_List;
        If Fnd_Api.To_Boolean(nvl(P_Init_Msg_List,Fnd_Api.G_True)) Then

                Pa_Debug.G_Stage := 'Initializing message stack by calling Fnd_Msg_Pub.Initialize().';
                Fnd_Msg_Pub.Initialize;

        End If;

        Pa_Debug.G_Stage := 'Initialize error handling variables.';
        X_Error_Msg_Data := Null;
        X_Return_Status := Fnd_Api.G_Ret_Sts_Success;


	/***********************************
		call to covert missing

        *************************************/
		Pa_Rbs_Pub.Convert_Missing_Rbs_Header(
				P_Header_Rec => P_Header_Rec,
				X_Header_Rec => l_Header_Rec,
				P_Mode       =>  l_Mode ,
				X_Error_Msg	    => X_Error_Msg_Data);

		Pa_Rbs_Pub.Convert_Missing_Rbs_Elements(
				P_Elements_Tbl => P_Elements_Tbl,
				X_Elements_Tbl => l_Elements_Tbl,
				P_Mode       =>  l_Mode ,
				X_Error_Msg	    => X_Error_Msg_Data);





        /***************************
          Process the Header Rec
         ***************************/

        -- Query the header from the DB and check if any fields are changed.

        IF l_header_rec.rbs_header_id is not null THEN
             Open rbs_header_cursor(p_header_id => l_header_rec.rbs_header_id);

             Fetch rbs_header_cursor into l_old_header_rec;

             If rbs_header_cursor%NotFound Then

                    Pa_Debug.G_Stage := 'Rbs header Id is invalid.';
                    Close rbs_header_cursor;
                    Pa_Utils.Add_Message(
                              P_App_Short_Name => 'PA',
                              P_Msg_Name       => 'PA_INVALID_RBS_HEADER_ID');

                    Raise l_ERROR;

             Else

                    Close rbs_header_cursor;

             End If;

             IF (nvl(l_header_rec.name,' ')  <> nvl(l_old_header_rec.name,' ') OR
                nvl(l_header_rec.description,' ') <> nvl(l_old_header_rec.description,' ') OR
                nvl(l_header_rec.effective_from_date,sysdate) <> nvl(l_old_header_rec.effective_from_date,sysdate) OR
                nvl(l_header_rec.Effective_To_Date,sysdate) <> nvl(l_old_header_rec.Effective_To_Date,sysdate)) THEN


                     -- One of the header attributes has changed which means, the header record needs to be updated.

                     IF l_header_rec.record_version_number <> l_old_header_rec.record_version_number THEN
                         Pa_Utils.Add_Message(
                                   P_App_Short_Name => 'PA',
                                   P_Msg_Name       => 'PA_RBS_HDR_INCORRECT');

                         Raise l_ERROR;
                     END IF;

                     Pa_Debug.G_Stage := 'Update Header Record by calling Pa_Rbs_Header_Pub.Update_Header() procedure.';
                     Pa_Rbs_Header_Pub.Update_Header(
                            P_Commit              => Fnd_Api.G_False,
                            P_Init_Msg_List       => Fnd_Api.G_False,
                            P_API_Version_Number  => P_Api_Version_Number,
                            P_RbsHeaderId         => l_Header_Rec.Rbs_Header_Id,
                            P_Name                => l_Header_Rec.Name,
                            P_Description         => l_Header_Rec.Description,
		            P_EffectiveFrom       => l_Header_Rec.Effective_From_Date,
                            P_EffectiveTo         => l_Header_Rec.Effective_To_Date,
                            P_RecordVersionNumber => l_Header_Rec.Record_Version_Number,
                            P_Process_Version     => Fnd_Api.G_False,
                            X_Return_Status       => X_Return_Status,
                            X_Msg_Data            => X_Error_Msg_Data,
                            X_Msg_Count           => l_Msg_Count);

                     If X_Error_Msg_Data is Not Null Then

                             Pa_Debug.G_Stage := 'The Pa_Rbs_Header_Pub.Update_Header() procedure returned error.';
                             Raise l_ERROR;

                     Else

                             G_Rbs_Hdr_Out_Rec.Rbs_Header_Id         := l_Header_Rec.Rbs_Header_Id;
                          --   G_Rbs_Hdr_Out_Rec.Return_Status         := Fnd_Api.G_Ret_Sts_Success;

                     End If;

              End If;  -- Has the header record been passed in.
        END IF; -- l_header_rec.rbs_header_id is not null

        /***************************
           Process the Version Rec
         ***************************/

        Pa_Rbs_Pub.Convert_Missing_Rbs_Version(
				P_Version_Rec   => P_Version_Rec,
				X_Version_Rec   => l_Version_Rec,
				P_Mode          =>  l_Mode ,
				X_Error_Msg     => X_Error_Msg_Data);

        IF l_Version_Rec.rbs_version_id is not null THEN
            -- Query the version from the DB and check if any fields are changed.

            Open rbs_version_cursor(p_version_id => l_version_rec.rbs_version_id);

            Fetch rbs_version_cursor into l_old_version_rec;

            If rbs_version_cursor%NotFound Then

                    Pa_Debug.G_Stage := 'Rbs header Id is invalid.';
                    Close rbs_version_cursor;
                    Pa_Utils.Add_Message(
                              P_App_Short_Name => 'PA',
                              P_Msg_Name       => 'PA_INVALID_RBS_VERSION_ID');

                    Raise l_ERROR;

            Else

                    Close rbs_version_cursor;

            End If;

            Pa_Debug.G_Stage := 'Check if need to update the Version Record.';

            IF (nvl(l_Version_Rec.Name, ' ') <>  nvl(l_old_version_rec.Name, ' ') OR
               nvl(l_Version_Rec.Description, ' ') <> nvl(l_old_version_rec.Description, ' ') OR
               nvl(l_Version_Rec.Version_Start_Date,sysdate) <> nvl(l_old_version_rec.Version_Start_Date,sysdate) OR
               nvl(l_Version_Rec.Job_Group_Id,-1) <> nvl(l_old_version_rec.Job_Group_Id,-1)) THEN


                -- Check to see if the Version's record version number matches
                -- the database record version number. If not, error out.

                IF nvl(l_version_rec.record_version_number,-1) <> l_old_version_rec.record_version_number
                THEN
                     Pa_Debug.G_Stage := 'Incorred Record Version number passed in';
                     Pa_Utils.Add_Message(
                              P_App_Short_Name => 'PA',
                              P_Msg_Name       => 'PA_RBS_VERSION_INCORRECT');

                     Raise l_ERROR;
                END IF;

                IF l_old_version_rec.status_code ='FROZEN' THEN
                     Pa_Debug.G_Stage := 'Version is frozen.Cannot update any field.';
                     Pa_Utils.Add_Message(
                              P_App_Short_Name => 'PA',
                              P_Msg_Name       => 'PA_RBS_VERSION_FROZEN');

                     Raise l_ERROR;
                END IF;

                Pa_Debug.G_Stage := 'Update Version Record by calling Pa_Rbs_Versions_Pub.Update_Working_Version() procedure.';
                Pa_Rbs_Versions_Pub.Update_Working_Version(
                        P_Commit                => Fnd_Api.G_False,
                        P_Init_Msg_List         => Fnd_Api.G_False,
                        P_API_Version_Number    => P_Api_Version_Number,
                        P_RBS_Version_Id        => l_Version_Rec.Rbs_Version_Id,
                        P_Name                  => l_Version_Rec.Name,
                        P_Description           => l_Version_Rec.Description,
                        P_Version_Start_Date    => l_Version_Rec.Version_Start_Date,
                        P_Job_Group_Id          => l_Version_Rec.Job_Group_Id,
                        P_Record_Version_Number => l_Version_Rec.Record_Version_Number,
                        P_Init_Debugging_Flag   => 'N',
                        X_Record_Version_Number => l_Record_Version_Number,
                        X_Return_Status         => X_Return_Status,
                        X_Msg_Count             => l_Msg_Count,
                        X_Error_Msg_Data        => X_Error_Msg_Data);

                If X_Return_Status <> Fnd_Api.G_Ret_Sts_Success Then

                        Pa_Debug.G_Stage := 'The Pa_Rbs_Versions_Pub.Update_Working_Version() procedure returned status of error.';
                        Raise l_ERROR;

                Else

                        G_Rbs_Ver_Out_Rec.Rbs_Version_Id        := l_Version_Rec.Rbs_Version_Id;
                       -- G_Rbs_Ver_Out_Rec.Return_Status         := Fnd_Api.G_Ret_Sts_Success;

                End If;

            End If;
        END IF; --  l_Version_Rec.rbs_version_id is not null

        /*****************************
           Process the Elements/Nodes
         *****************************/

	If l_Elements_Tbl.Count > 0 Then

                -- Put the pl/sql table into a temp table, checking for problems before inserting.
                Pa_Debug.G_Stage := 'Start loop thru the element/nodes pl/sql table.';
                For i in l_Elements_Tbl.First .. l_Elements_Tbl.Last
                Loop

                        Pa_Debug.G_Stage := 'Check if missing rbs level id.';
                        If l_Elements_Tbl(i).Rbs_Level is Null Then

                                Pa_Debug.G_Stage := 'The rbs level cannot be null.  Add error message to stack.';
                                Pa_Utils.Add_Message(
                                        P_App_Short_Name => 'PA',
                                        P_Msg_Name       => 'PA_RBS_RBS_LEVEL_REQ');

                                Raise l_ERROR;

                        End If;

                        Pa_Debug.G_Stage := 'Check if we have a process type to work with.';
                        If l_Elements_Tbl(i).Process_Type is Null or
                           l_Elements_Tbl(i).Process_Type Not In ('A','D','U') Then

                                Pa_Debug.G_Stage := 'Process Type is null or invalid.  Add error message to stack.';
                                Pa_Utils.Add_Message(
                                        P_App_Short_Name => 'PA',
                                        P_Msg_Name       => 'PA_RBS_PRC_TYPE_INVALID');

                                Raise l_ERROR;

                        End If;

                        Pa_Debug.G_Stage := 'Check that have rbs element id.';
                        If l_Elements_Tbl(i).Rbs_Ref_Element_Id is Null And
                           l_Elements_Tbl(i).Process_Type = 'A' Then

                                Pa_Debug.G_Stage := 'Missing reference rbs element id.  Add error message to stack.';
                                Pa_Utils.Add_Message(
                                        P_App_Short_Name => 'PA',
                                        P_Msg_Name       => 'PA_RBS_REF_ELEMENT_ID_REQ');

                                Raise l_ERROR;

                        End If;

                        Pa_Debug.G_Stage := 'Check f missing rbs (reference) element id.';
                        If l_Elements_Tbl(i).Rbs_Element_Id is Null And
                           l_Elements_Tbl(i).Process_Type in ('U','D') Then

                                Pa_Debug.G_Stage := 'Missing rbs element id.  Add error message to stack.';
                                Pa_Utils.Add_Message(
                                        P_App_Short_Name => 'PA',
                                        P_Msg_Name       => 'PA_RBS_ELEMENT_ID_REQ');

                                Raise l_ERROR;

                        End If;

                        Pa_Debug.G_Stage := 'Check if missing parent element id.';
                        If ( l_Elements_Tbl(i).Parent_Ref_Element_Id Is Null And
                             l_Elements_Tbl(i).Parent_Element_Id is Null ) And
                           l_Elements_Tbl(i).Process_Type = 'A' And
                           l_Elements_Tbl(i).Rbs_Level <> 1 Then

                                Pa_Debug.G_Stage := 'Missing parent element id.  Add error message to stack.';
                                Pa_Utils.Add_Message(
                                        P_App_Short_Name => 'PA',
                                        P_Msg_Name       => 'PA_RBS_REF_PARENT_ID_REQ');

                                Raise l_ERROR;

                        End If;

                        Pa_Debug.G_Stage := 'Check if missing parent (reference) element id.';
                        If l_Elements_Tbl(i).Parent_Element_Id is Null And
                           l_Elements_Tbl(i).Process_Type in ('U','D') And
                           l_Elements_Tbl(i).Rbs_Level <> 1 Then

                                Pa_Debug.G_Stage := 'Missing parent element id.  Add error message to stack.';
                                Pa_Utils.Add_Message(
                                        P_App_Short_Name => 'PA',
                                        P_Msg_Name       => 'PA_RBS_PARENT_ID_REQ');

                                Raise l_ERROR;

                        End If;

                        -- Validate the RBS Version. Only elements of a working
                        -- version can be updated.

                        IF (l_Elements_Tbl(i).Rbs_Version_Id is null OR
                           l_Elements_Tbl(i).Rbs_Version_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)
                        THEN
                             Pa_Debug.G_Stage := 'Version Identifier Invalid.';
                             Pa_Utils.Add_Message(
                                      P_App_Short_Name => 'PA',
                                      P_Msg_Name       => 'PA_RBS_VERSION_IS_MISSING');

                             Raise l_ERROR;
                        ELSE
                            BEGIN
                               SELECT status_code
                               INTO l_status_code
                               FROM PA_RBS_VERSIONS_B
                               WHERE rbs_version_id = l_Elements_Tbl(i).Rbs_Version_Id;

                               IF l_status_code = 'FROZEN' THEN

                                    Pa_Debug.G_Stage := 'Version Identifier Invalid.';
                                    Pa_Utils.Add_Message(
                                             P_App_Short_Name => 'PA',
                                             P_Msg_Name       => 'PA_RBS_VERSION_FROZEN');

                                    Raise l_ERROR;
                               END IF;
                            EXCEPTION
                               WHEN NO_DATA_FOUND THEN
                                    Pa_Debug.G_Stage := 'Version Identifier Invalid.';
                                    Pa_Utils.Add_Message(
                                             P_App_Short_Name => 'PA',
                                             P_Msg_Name       => 'PA_INVALID_RBS_VERSION_ID');

                                    Raise l_ERROR;
                            END;

                        END IF;

                        --For bug 3964469.
                        --Validate if the Element Id passed belongs to the version being updated.
                        If l_Elements_Tbl(i).Rbs_Element_Id IS NOT NULL THEN

                            BEGIN

                               SELECT 'Y'
                               INTO l_validate
                               FROM pa_rbs_elements
                               WHERE rbs_version_id = l_Elements_Tbl(i).Rbs_Version_Id
                               AND rbs_element_id = l_Elements_Tbl(i).Rbs_Element_Id;

                               If l_validate = 'Y' Then
                                  Pa_Debug.G_Stage := 'Element Identifier in sync with Version Identifier.';
                               END IF;

                            EXCEPTION
                               WHEN NO_DATA_FOUND Then
                                  l_validate := 'N';
                                  Pa_Debug.G_Stage := 'Element Identifier not sync with Version Identifier.';
                                    Pa_Utils.Add_Message(
                                             P_App_Short_Name => 'PA',
                                             P_Msg_Name       => 'PA_RBS_ELE_NSYNC_VER');

                                    Raise l_ERROR;

                            END;

                        END IF;

                        --Also, same validation is done for the parent_element_id:
                        If l_Elements_Tbl(i).Parent_Element_Id IS NOT NULL THEN

                            BEGIN

                               SELECT 'Y'
                               INTO l_validate
                               FROM pa_rbs_elements
                               WHERE rbs_version_id = l_Elements_Tbl(i).Rbs_Version_Id
                               AND rbs_element_id = l_Elements_Tbl(i).Parent_Element_Id;

                               If l_validate = 'Y' Then
                                  Pa_Debug.G_Stage := 'Parent Element Identifier in sync with Element id of the given Version Identifier.';
                               END IF;

                            EXCEPTION
                               WHEN NO_DATA_FOUND Then
                                  l_validate := 'N';
                                  Pa_Debug.G_Stage := 'Parent Element Identifier not sync with Element id of the given Version Identifier.';
                                    Pa_Utils.Add_Message(
                                             P_App_Short_Name => 'PA',
                                             P_Msg_Name       => 'PA_PAR_ELE_ID_INVALID');

                                    Raise l_ERROR;

                            END;

                        END IF;

                        --Validate Parent_element_id. Check whether the parent_element_id is the elements's parent_element_id
                        IF l_Elements_Tbl(i).Rbs_Element_Id IS NOT NULL AND
                           l_Elements_Tbl(i).Parent_Element_Id IS NOT NULL THEN

                           BEGIN

                               SELECT 'Y'
                               INTO l_validate
                               FROM pa_rbs_elements
                               WHERE parent_element_id = l_Elements_Tbl(i).Parent_Element_Id
                               AND rbs_element_id = l_Elements_Tbl(i).Rbs_Element_Id;

                               If l_validate = 'Y' Then
                                  Pa_Debug.G_Stage := 'Parent Element Identifier passed is the correct parent_element_id';
                               END IF;

                            EXCEPTION
                               WHEN NO_DATA_FOUND Then
                                  Pa_Debug.G_Stage := 'Parent Element Identifier passed is not the correct parent_element_id.';
                                    Pa_Utils.Add_Message(
                                             P_App_Short_Name => 'PA',
                                             P_Msg_Name       => 'PA_PAR_ELE_NSYNC_ELE');

                                    Raise l_ERROR;

                            END;

                        END IF;
                        --End of Bug 3964469.

                        Pa_Debug.G_Stage := 'Insert record into pa_rbs_nodes_temp table for further processing.';
                        Insert into Pa_Rbs_Nodes_Temp (
                                Rbs_Version_Id,
                                Rbs_Element_Id,
                                Parent_Element_Id,
                                Resource_Type_Id,
                                Resource_Source_Id,
                                Resource_Source_Code,
                                Order_Number,
                                Process_Type,
                                Rbs_Level,
                                Record_Version_Number,
                                Parent_Ref_Element_Id,
                                Rbs_Ref_Element_Id,
                                Record_Index )
                        Values (
                                l_Elements_Tbl(i).Rbs_Version_Id,
                                l_Elements_Tbl(i).Rbs_Element_Id,
                                l_Elements_Tbl(i).Parent_Element_Id,
                                Decode(l_Elements_Tbl(i).Rbs_Level,1,-1,l_Elements_Tbl(i).Resource_Type_Id),
                                Decode(l_Elements_Tbl(i).Rbs_Level,
                                              1, l_Elements_Tbl(i).Rbs_Version_Id,
                                              l_Elements_Tbl(i).Resource_Source_Id),
                                l_Elements_Tbl(i).Resource_Source_Code,
                                l_Elements_Tbl(i).Order_Number,
                                Decode(l_Elements_Tbl(i).Rbs_Level,1,'R',l_Elements_Tbl(i).Process_Type),
                                l_Elements_Tbl(i).Rbs_Level,
                                l_Elements_Tbl(i).Record_Version_Number,
                                l_Elements_Tbl(i).Parent_Ref_Element_Id,
                                l_Elements_Tbl(i).Rbs_Ref_Element_Id,
                                i );

                        If l_Elements_Tbl(i).Rbs_Level = 1 Then

                                -- The Fetch_Rbs_Element() procedure needs this done.
                                -- Rbs Level 1 is the root element/node for the structure.
                                -- It is not processed but is created with a default structure,
                                -- so it is not looked at further into the process elements part of the proedure.
                                G_Rbs_Elements_Out_Tbl(i).Rbs_Element_Id        := l_Elements_Tbl(i).Rbs_Element_Id;
                                --G_Rbs_Elements_Out_Tbl(i).Return_Status         := Fnd_Api.G_Ret_Sts_Success;

                        End If;

                End Loop;

                -- Check to see if have a root node passed in the pl/sql table.  This is required
                -- even though they have minimul control over it values.
                -- Root element/node is always level one.
                Pa_Debug.G_Stage := 'Open c3 to get count of rbs level 1 records.';
                Open c3;
                Fetch c3 Into l_Root_Count;
                Close c3;

                If l_Root_Count = 0 Then

                        Pa_Debug.G_Stage := 'No root element/node provided.  Add error message to stack.';
                        Pa_Utils.Add_Message(
                                P_App_Short_Name => 'PA',
                                P_Msg_Name       => 'PA_RBS_NO_ROOT_ELEMENT');

                        Raise l_ERROR;

                End If;

                -- Check to see if provide more than a single root element.  This is not allowed.
                If l_Root_Count > 1 Then

                        Pa_Debug.G_Stage := 'Multiple root elements/nodes provided.  Add error message to stack.';
                        Pa_Utils.Add_Message(
                                P_App_Short_Name => 'PA',
                                P_Msg_Name       => 'PA_RBS_MULTI_ROOT_ELEMENTS');

                        Raise l_ERROR;

                End If;

                Pa_Debug.G_Stage := 'Open cursor c1 to get the max rbs level defined.';
                Open c1;
		Fetch c1 Into l_Max_Rbs_Level;
                Close c1;

                -- This for loop is to enforce the business rule of what data is processed in what order
                -- We want to process elements/nodes in the following order: Delete, Update, Add
                Pa_Debug.G_Stage := 'For next loop to restrict by process type.';
                For j in 1 .. 3
                Loop

                     If j = 1 Then

                             l_Process_Type := 'D';

                     ElsIf j = 2 Then

                             l_Process_Type := 'U';

                     ElsIf j = 3 Then

                             l_Process_Type := 'A';

                     End If;

                     -- This loop is to enforce the business rule of processing the elements in order of rbs_level because
                     -- we need to always have the actual parent_element_id determined before its child can be processed
                     -- Level 1 is the root for the RBS structure and is only created and never updated or deleted
                     Pa_Debug.G_Stage := 'For next loop to restrict by rbs_level.';
                     For i in 2 .. l_Max_Rbs_Level
                     Loop

                             Pa_Debug.G_Stage := 'Open c2 cursor to get next set of records to process.';
                             Open c2( P_Rbs_Level    => i,
                                      P_Process_Type => l_Process_Type);

                             -- This is the loop where the needed elements will be process based on the to parent
                             -- loops criteria be applied to
                             -- the cursor c2, that is the process type and the rbs_level we want to work with.
                             Pa_Debug.G_Stage := 'Start loop to process the elements/nodes for the process type/rbs level.';
                             Loop

                                  Pa_Debug.G_Stage := 'Fetch c2 cursor record.';
                                  Fetch c2 Into Element_Rec;
                                  Exit When c2%NotFound;

                                  Pa_Debug.G_Stage := 'Check if resource source id is null.';
                                  If Element_Rec.Resource_Source_Id is Null Then

                                       Pa_Debug.G_Stage := 'Get Resource Source Id using source code.';
                                       Pa_Rbs_Elements_Utils.GetResSourceId(
                                                P_Resource_Type_Id     => Element_Rec.Resource_Type_Id,
                                                P_Resource_Source_Code => Element_Rec.Resource_Source_Code,
                                                X_Resource_Source_Id   => l_Resource_Source_Id);

IF l_Resource_Source_Id IS NULL THEN
   Pa_Utils.Add_Message(P_App_Short_Name => 'PA',
                        P_Msg_Name       => 'PA_RBS_NO_RESOURCE_SOURCE_ID');

            Raise l_ERROR;
END IF;
                                  Else

                                       Pa_Debug.G_Stage := 'Assign resource source id.';
                                       l_Resource_Source_Id := Element_Rec.Resource_Source_Id;

                                  End If;

                                  Pa_Debug.G_Stage := 'Call Process_Rbs_Elements() procedure.';
                                  Pa_Rbs_Elements_Pvt.Process_Rbs_Element(
                	                P_RBS_Version_Id     => Element_Rec.Rbs_Version_Id,
                	                P_Parent_Element_Id  => Element_Rec.Parent_Element_Id,
                	                P_Element_Id         => Element_Rec.Rbs_Element_Id,
                	                P_Resource_Type_Id   => Element_Rec.Resource_Type_Id,
                	                P_Resource_Source_Id => l_Resource_Source_Id,
                	                P_Order_Number       => Element_Rec.Order_Number,
                	                P_Process_Type       => Element_Rec.Process_Type,
			                X_Rbs_Element_Id     => l_Rbs_Element_Id,
                                        X_Error_Msg_Data     => X_Error_Msg_Data );

                                  If X_Error_Msg_Data is not null Then

                                        Pa_Debug.G_Stage := 'The Process_Rbs_Elements() procedure returned error.  ' ||
                                                              'Add error message to stack.';
                                        Pa_Rbs_Pub.PopulateErrorStack(
                                                P_Ref_Element_Id => Element_Rec.Rbs_Ref_Element_Id,
                                                P_Element_Id     => Element_Rec.Rbs_Element_Id,
                                                P_Process_Type   => Element_Rec.Process_Type,
                                                P_Error_Msg_Data => X_Error_Msg_Data);

                                        Raise l_ERROR;

                                  End If;

                                  -- Now need to update the temp recs with the element id just created.
                                  -- This is because we have process one rbs level at a time to populate needed data
                                  -- However, these updates are only needed when adding elements/nodes.
                                  Pa_Debug.G_Stage := 'Check if process type is Add to as to do needed updates on temp table.';
                                  If l_Process_Type = 'A' Then

                                          -- This should always update at least one record
                                          Pa_Debug.G_Stage := 'Update rbs_element_id based on temp rbs element id.';
                                          Update Pa_Rbs_Nodes_Temp
                                          Set
                                                  Rbs_Element_Id = l_Rbs_Element_Id
                                          Where
                                                  Rbs_Ref_Element_Id = Element_Rec.Rbs_Ref_Element_Id;

                                          -- This may or may not update records
                                          Pa_Debug.G_Stage := 'Update parent_element_id based on temp parent id.';
                                          Update Pa_Rbs_Nodes_Temp
                                          Set
                                                   Parent_Element_Id = l_Rbs_Element_Id
                                          Where
                                                   Parent_Ref_Element_Id = Element_Rec.Rbs_Ref_Element_Id
                                          And      Parent_Element_Id is Null;

                                  End If;

                                  Pa_Debug.G_Stage := 'Added parent Id to pl/sql array.';

                                  -- The Fetch_Rbs_Element() procedure needs this done.
                                  Pa_Debug.G_Stage := 'Update the global elements out table with rbs_element_id and status.';
                                  If Element_Rec.Process_Type = 'A' Then
                                       G_Rbs_Elements_Out_Tbl(Element_Rec.Record_Index).Rbs_Element_Id := l_Rbs_Element_Id;
                                  Else
                                       G_Rbs_Elements_Out_Tbl(Element_Rec.Record_Index).Rbs_Element_Id := Element_Rec.Rbs_Element_Id;
                                  End If;
                                 -- G_Rbs_Elements_Out_Tbl(Element_Rec.Record_Index).Return_Status  := Fnd_Api.G_Ret_Sts_Success;

                                  Pa_Debug.G_Stage := 'Update the out parameter x_element_tbl with rbs_element_id and parent id.';
                                  If Element_Rec.Process_Type = 'A' Then

                                       X_Elements_Tbl(Element_Rec.Record_Index).Rbs_Element_Id := l_Rbs_Element_Id;

                                  Else

                                       X_Elements_Tbl(Element_Rec.Record_Index).Rbs_Element_Id := Element_Rec.Rbs_Element_Id;

                                  End If;
                                  X_Elements_Tbl(Element_Rec.Record_Index).Parent_Element_Id := Element_Rec.Parent_Element_Id;

                             End Loop;
                             Close c2;

                      End Loop;  -- to handle the rbs_level order properly

                 End Loop;  -- to handle the process type order properly

        End If; -- l_Elements_Tbl.Count > 0

        Pa_Debug.G_Stage := 'Check to do commit(T-True,F-False) - ' || P_Commit;
        If Fnd_Api.To_Boolean(Nvl(P_Commit,Fnd_Api.G_True)) Then

                Commit;

        End If;

        Pa_Debug.G_Stage := 'Leaving Update_Rbs() procedure.';
        Pa_Debug.TrackPath('STRIP','Update_Rbs');

Exception
        When l_ERROR Then
             l_Msg_Count := Fnd_Msg_Pub.Count_Msg;

             If l_Msg_Count = 1 Then

                  Pa_Interface_Utils_Pub.Get_Messages(
                       P_Encoded       => Fnd_Api.G_True,
                       P_Msg_Index     => 1,
                       P_Msg_Count     => l_Msg_Count,
                       P_Msg_Data      => l_Msg_Data,
                       P_Data          => l_Data,
                       P_Msg_Index_Out => l_Msg_Index_Out);

                  X_Error_Msg_Data := l_Data;
                  X_Msg_Count      := l_Msg_Count;

              Else

                   X_Msg_Count := l_Msg_Count;

              End If;
              X_Return_Status := Fnd_Api.G_Ret_Sts_Error;
              G_Rbs_Ver_Out_Rec := G_Empty_Rbs_Ver_Out_Rec;
              G_Rbs_Elements_Out_Tbl.Delete;
              G_Rbs_Hdr_Out_Rec.Rbs_Header_Id := l_Rbs_Header_Id;
            --  G_Rbs_Hdr_Out_Rec.Return_Status := Fnd_Api.G_Ret_Sts_Error;
              G_Rbs_Elements_Count := 0;
              Rollback;

        When Others Then
              X_Return_Status := Fnd_Api.G_Ret_Sts_UnExp_Error;
              X_Msg_Count := 1;
              X_Error_Msg_Data := Pa_Debug.G_Path || '::' || Pa_Debug.G_Stage || ':' || SqlErrm;
              G_Rbs_Ver_Out_Rec := G_Empty_Rbs_Ver_Out_Rec;
              G_Rbs_Elements_Out_Tbl.Delete;
              G_Rbs_Hdr_Out_Rec.Rbs_Header_Id := l_Rbs_Header_Id;
             -- G_Rbs_Hdr_Out_Rec.Return_Status := Fnd_Api.G_Ret_Sts_UnExp_Error;
              G_Rbs_Elements_Count := 0;
              Rollback;

End Update_Rbs;

/*
*****************************************************************************************
*  API Name: Load_Rbs_Header
*  Description:
*     This API allows the user to load the RBS header record data.
*     It is required to be executed with you want to create a new RBS.
*
*     See package specification of the rbs header table structure to see
 *******************************************************************************************
*/
Procedure Load_Rbs_Header(
        P_Api_Version_Number     IN         Number,
        P_Rbs_Header_Id          IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Name                   IN         Varchar2 Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
        P_Description            IN         Varchar2 Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
        P_Effective_From_Date    IN         Date     Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
        P_Effective_To_Date      IN         Date     Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
        P_Record_Version_Number  IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        X_return_status          OUT NOCOPY Varchar2)

Is

       l_Api_Version_Number      CONSTANT   Number       := G_Api_Version_Number;
       l_Api_Name                CONSTANT   Varchar2(30) := 'Load_Rbs_Header';

BEGIN

       X_Return_Status := Fnd_Api.G_Ret_Sts_Success;

       -- Standard Api compatibility call
       If Not Fnd_Api.Compatible_API_Call ( l_Api_Version_Number   ,
                                            P_Api_Version_Number   ,
                                            l_Api_Name             ,
                                            G_Pkg_Name ) Then

             Raise Fnd_Api.G_Exc_UnExpected_Error;

       End If;

       G_Rbs_Hdr_Rec.Rbs_Header_Id         := P_Rbs_Header_Id;
       G_Rbs_Hdr_Rec.Name                  := P_Name;
       G_Rbs_Hdr_Rec.Description           := P_Description;
       G_Rbs_Hdr_Rec.Effective_From_Date   := P_Effective_From_Date;
       G_Rbs_Hdr_Rec.Effective_To_Date     := P_Effective_To_Date;
       G_Rbs_Hdr_Rec.Record_Version_Number := P_Record_Version_Number;

Exception
       When Fnd_Api.G_Exc_UnExpected_Error Then
            X_Return_Status := Fnd_Api.G_Ret_Sts_UnExp_Error ;
	 Rollback;
       When Others Then
            X_Return_Status := Fnd_Api.G_Ret_Sts_UnExp_Error ;

            If Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_Msg_Lvl_UnExp_Error) Then

                 Fnd_Msg_Pub.Add_Exc_Msg(
                      P_Pkg_Name       =>  G_Pkg_Name,
                      P_Procedure_Name =>  l_api_name);

            END IF;
		 Rollback;
End Load_Rbs_Header;

/*
************************************************************************************
*  API Name: Load_Rbs_Version
*
*  Description:
*     This API allows the user to load the RBS version record data.
*     It is never required to be executed.
*
* **********************************************************************************
*/
Procedure Load_Rbs_Version(
        P_Api_Version_Number     IN         Number,
        P_Rbs_Version_Id         IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Name                   IN         Varchar2 Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
        P_Description            IN         Varchar2 Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
        P_Version_Start_Date     IN         Date     Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE,
        P_Job_Group_Id           IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Record_Version_Number  IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        X_Return_Status          OUT NOCOPY VARCHAR2)

Is

       l_Api_Version_Number CONSTANT   Number       := G_Api_Version_Number;
       l_Api_Name           CONSTANT   Varchar2(30) := 'Load_Rbs_Version';

BEGIN

       X_Return_Status := Fnd_Api.G_Ret_Sts_Success;

       -- Standard Api compatibility call
       If Not Fnd_Api.Compatible_API_Call ( l_Api_Version_Number   ,
                                            P_Api_Version_Number   ,
                                            l_Api_Name             ,
                                            G_Pkg_Name ) Then

             Raise Fnd_Api.G_Exc_UnExpected_Error;

       End If;

       G_Rbs_Ver_Rec.Rbs_Version_Id         := P_Rbs_Version_Id;
       G_Rbs_Ver_Rec.Name                   := P_Name;
       G_Rbs_Ver_Rec.Job_Group_Id           := P_Job_Group_Id;
       G_Rbs_Ver_Rec.Description            := P_Description;
       G_Rbs_Ver_Rec.Version_Start_Date     := P_Version_Start_Date;
       G_Rbs_Ver_Rec.Record_Version_Number  := P_Record_Version_Number;

Exception
       When Fnd_Api.G_Exc_UnExpected_Error Then
            X_Return_Status := Fnd_Api.G_Ret_Sts_UnExp_Error;
	 Rollback;
       When Others Then
            X_Return_Status := Fnd_Api.G_Ret_Sts_UnExp_Error;

            If Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_Msg_Lvl_UnExp_Error) Then

                 Fnd_Msg_Pub.Add_Exc_Msg(
                      P_Pkg_Name       =>  G_Pkg_Name,
                      P_Procedure_Name =>  l_api_name);

            End If;
       Rollback;
End Load_Rbs_Version;

/*
**********************************************************************************************
*  API Name: Load_Rbs_Elements
*  Description:
*     This API allows the user to load the RBS element records data.
*     It is never required to be executed.
*************************************************************************************************
*/
Procedure Load_Rbs_Elements(
        P_Api_Version_Number    IN         Number,
        P_Rbs_Version_Id        IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Rbs_Element_Id        IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Parent_Element_Id     IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Resource_Type_Id      IN         Number,
        P_Resource_Source_Id    IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Resource_Source_Code  IN         Varchar2 Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
        P_Order_Number          IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Process_Type          IN         Varchar2,
        P_Rbs_Level             IN         Number,
        P_Record_Version_Number IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Parent_Ref_Element_Id IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Rbs_Ref_Element_Id    IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        X_Return_Status          OUT NOCOPY Varchar2)

Is

       l_Api_Version_Number CONSTANT Number       := G_Api_Version_Number;
       l_Api_Name           CONSTANT Varchar2(30) := 'Load_Rbs_Elements';

BEGIN

       X_Return_Status := Fnd_Api.G_Ret_Sts_Success;

       -- Standard Api compatibility call
       If Not Fnd_Api.Compatible_API_Call ( l_Api_Version_Number   ,
                                            P_Api_Version_Number   ,
                                            l_Api_Name             ,
                                            G_Pkg_Name ) Then

             Raise Fnd_Api.G_Exc_UnExpected_Error;

       End If;

       G_Rbs_Elements_Count := G_Rbs_Elements_Count + 1;

       G_Rbs_Elements_Tbl(G_Rbs_Elements_Count).Rbs_Version_Id         := P_Rbs_Version_Id;
       G_Rbs_Elements_Tbl(G_Rbs_Elements_Count).Rbs_Element_Id         := P_Rbs_Element_Id;
       G_Rbs_Elements_Tbl(G_Rbs_Elements_Count).Parent_Element_Id      := P_Parent_Element_Id;
       G_Rbs_Elements_Tbl(G_Rbs_Elements_Count).Resource_Type_Id       := P_Resource_Type_Id;
       G_Rbs_Elements_Tbl(G_Rbs_Elements_Count).Resource_Source_Id     := P_Resource_Source_Id;
       G_Rbs_Elements_Tbl(G_Rbs_Elements_Count).Resource_Source_Code   := P_Resource_Source_Code;
       G_Rbs_Elements_Tbl(G_Rbs_Elements_Count).Order_Number           := P_Order_Number;
       G_Rbs_Elements_Tbl(G_Rbs_Elements_Count).Process_Type           := P_Process_Type;
       G_Rbs_Elements_Tbl(G_Rbs_Elements_Count).Rbs_Level              := P_Rbs_Level;
       G_Rbs_Elements_Tbl(G_Rbs_Elements_Count).Parent_Ref_Element_Id  := P_Parent_Ref_Element_Id;
       G_Rbs_Elements_Tbl(G_Rbs_Elements_Count).Rbs_Ref_Element_Id     := P_Rbs_Ref_Element_Id;
       G_Rbs_Elements_Tbl(G_Rbs_Elements_Count).Record_Version_Number  := P_Record_Version_Number;

Exception
       When Fnd_Api.G_Exc_UnExpected_Error Then
            X_Return_Status := Fnd_Api.G_Ret_Sts_UnExp_Error;
	 Rollback;
       When Others Then
            X_Return_Status := Fnd_Api.G_Ret_Sts_UnExp_Error;

            If Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_Msg_Lvl_UnExp_Error) Then

                 Fnd_Msg_Pub.Add_Exc_Msg(
                      P_Pkg_Name       =>  G_Pkg_Name,
                      P_Procedure_Name =>  l_Api_Name);

            End If;
	 Rollback;
End Load_Rbs_Elements;

/*
*****************************************************************************
* API Name: Fetch_Rbs_Header
*  Public/Private: Public
*  Procedure/Function: Procedure
*  Description:
*     This API returns the internal identifier and status of the Rbs Header
*     record.
*
*     There are 3 status that can be returned:
*        S - Success
*        E - Error; caused when fails validation
*       U - Unexpected Error; system error and unhandle issue like ORA errors
****************************************************************************
*/
Procedure Fetch_Rbs_Header(
        P_Api_Version_Number    IN         Number,
        X_Rbs_Header_Id         OUT NOCOPY Number,
        X_Return_Status         OUT NOCOPY Varchar2)

Is

     l_Api_Version_Number CONSTANT Number       := G_Api_Version_Number;
     l_Api_Name           CONSTANT Varchar2(30) := 'Fetch_Rbs_Header';

Begin

     X_Return_Status := Fnd_Api.G_Ret_Sts_Success;

     If Not Fnd_Api.Compatible_Api_Call(
                 l_Api_Version_Number,
                 P_Api_Version_Number,
                 l_Api_Name,
                 G_Pkg_Name) Then

         Raise Fnd_Api.G_Exc_UnExpected_Error;

     End If;

     X_Rbs_Header_Id         := G_Rbs_Hdr_Out_Rec.Rbs_Header_Id;
    -- X_Rbs_Hdr_Return_Status := G_Rbs_Hdr_Out_Rec.Return_Status;

Exception
     When Fnd_Api.G_Exc_UnExpected_Error Then

          X_return_status := Fnd_Api.G_Ret_Sts_UnExp_Error ;
	 Rollback;
     When Others Then
          X_Return_Status := Fnd_Api.G_Ret_Sts_UnExp_Error ;

          If Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_Msg_Lvl_UnExp_Error) Then

               Fnd_Msg_Pub.Add_Exc_Msg(
                    P_Pkg_Name       => G_Pkg_Name,
                    P_Procedure_Name => l_Api_Name);

          End If;
         Rollback;

End Fetch_Rbs_Header;

/*
*****************************************************************************
*  API Name: Fetch_Rbs_Version
*  Public/Private: Public
*  Procedure/Function: Procedure
*  Description:
*     This API returns the internal identifier and status of the Rbs version
*     record.
*
*     There are 3 status that can be returned:
*        S - Success
*       E - Error; caused when fails validation
*       U - Unexpected Error; system error and unhandle issue like ORA errors
* ***************************************************************************
*/
Procedure Fetch_Rbs_Version(
        P_Api_Version_Number    IN         Number,
        X_Rbs_Version_Id        OUT NOCOPY Number,
        X_Return_Status         OUT NOCOPY Varchar2)

Is

     l_Api_Version_Number CONSTANT Number       := G_Api_Version_Number;
     l_Api_Name           CONSTANT Varchar2(30) := 'Fetch_Rbs_Version';

Begin

     X_Return_Status := Fnd_Api.G_Ret_Sts_Success;

     If Not Fnd_Api.Compatible_Api_Call(
                 l_Api_Version_Number,
                 P_Api_Version_Number,
                 l_Api_Name,
                 G_Pkg_Name) Then

         Raise Fnd_Api.G_Exc_UnExpected_Error;

     End If;

     X_Rbs_Version_Id         := G_Rbs_Ver_Out_Rec.Rbs_Version_Id;
 --    X_Rbs_Ver_Return_Status  := G_Rbs_Ver_Out_Rec.Return_Status;

Exception
     When Fnd_Api.G_Exc_UnExpected_Error Then

          X_return_status := Fnd_Api.G_Ret_Sts_UnExp_Error ;
	 Rollback;
     When Others Then
          X_Return_Status := Fnd_Api.G_Ret_Sts_UnExp_Error ;

          If Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_Msg_Lvl_UnExp_Error) Then

               Fnd_Msg_Pub.Add_Exc_Msg(
                    P_Pkg_Name       => G_Pkg_Name,
                    P_Procedure_Name => l_Api_Name);

          End If;
	 Rollback;
End Fetch_Rbs_Version;

/*
*****************************************************************************
*  API Name: Fetch_Rbs_Element
*  Public/Private: Public
*  Procedure/Function: Procedure
*  Description:
*     This API returns the internal identifier and status of the Rbs element/node
*     record.  If no records were loaded using load_rbs_elements then there
*     will no records to fetch.
*
*     There are 3 status that can be returned:
*        S - Success
*        E - Error; caused when fails validation
*        U - Unexpected Error; system error and unhandle issue like ORA errors
*
*    The p_rbs_element_index in parameter is the order in which you called
*    load_rbs_elements() API.  So you will need to track that when
*    when using the load_rbs_elements() API in your calling routine.
****************************************************************************
*/
Procedure Fetch_Rbs_Element(
        P_Api_Version_Number        IN         Number,
        P_Rbs_Element_Index         IN         Number,
        X_Rbs_Element_Id            OUT NOCOPY Number,
        X_Return_Status             OUT NOCOPY Varchar2)

Is

     l_Api_Version_Number CONSTANT Number       := G_Api_Version_Number;
     l_Api_Name           CONSTANT Varchar2(30) := 'Fetch_Rbs_Elements';
     l_Index              NUMBER;

Begin

     X_Return_Status := Fnd_Api.G_Ret_Sts_Success;

     If Not Fnd_Api.Compatible_Api_Call(
                 l_Api_Version_Number,
                 P_Api_Version_Number,
                 l_Api_Name,
                 G_Pkg_Name) Then

         Raise Fnd_Api.G_Exc_UnExpected_Error;

     End If;

     --  Check Line index value
     If P_Rbs_Element_Index Is Null Then

          l_Index := 1;

     Else

          l_Index := P_Rbs_Element_Index;

     End If;

     --  Check whether an entry exists in the G_Rbs_Elements_Tbl or not.
     --  If there is no entry with that index , then do nothing
     If Not G_Rbs_Elements_Tbl.Exists(l_Index) Then

        --  X_Rbs_Element_Return_Status := NULL;
          X_Rbs_Element_Id            := NULL;

     Else

         X_Rbs_Element_Id            := G_Rbs_Elements_Out_Tbl(l_index).Rbs_Element_Id;
        -- X_Rbs_Element_Return_Status := G_Rbs_Elements_Out_Tbl(l_index).Return_Status;

     End If;

Exception
     When Fnd_Api.G_Exc_UnExpected_Error Then

          X_Return_Status := Fnd_Api.G_Ret_Sts_UnExp_Error ;
	   Rollback;
     When Others Then
          X_Return_Status := Fnd_Api.G_Ret_Sts_UnExp_Error ;

          If Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_Msg_Lvl_UnExp_Error) Then

               Fnd_Msg_Pub.Add_Exc_Msg(
                    P_Pkg_Name       => G_Pkg_Name,
                    P_Procedure_Name => l_Api_Name);

          End If;
	  Rollback;
End Fetch_Rbs_Element;

/*
 *****************************************************************************
 * API Name: Exec_Create_Rbs
 * Public/Private: Public
 * Procedure/Function: Procedure
 * Description:
 *   This API uses the data that was loaded via the load_rbs_header(),
 *    load_rbs_version(), and load_rbs_elements() API's to call the
 *    Create_Rbs() API.
 ****************************************************************************
*/
Procedure Exec_Create_Rbs(
        P_Commit             IN         Varchar2 := Fnd_Api.G_False,
        P_Init_Msg_List      IN         Varchar2 := Fnd_Api.G_True,
        P_Api_Version_Number IN         Number,
        X_Return_Status      OUT NOCOPY Varchar2,
        X_Msg_Count          OUT NOCOPY Number,
        X_Msg_Data           OUT NOCOPY Varchar2)

Is

        l_Api_Version_Number   CONSTANT NUMBER       := G_Api_Version_Number;
        l_Api_Name             CONSTANT VARCHAR2(30) := 'Exec_Create_Rbs';
        l_Message_Count        NUMBER;

        l_Rbs_Header_Id        Number(15) := Null;
        l_Rbs_Version_Id       Number(15) := Null;
        l_Dummy_Elements_Tbl   Rbs_Elements_Tbl_Typ;

BEGIN

        X_Return_Status := Fnd_Api.G_Ret_Sts_Success;

        -- Standard Api compatibility call
        If Not Fnd_Api.Compatible_Api_Call(
                           l_Api_Version_Number,
                           P_Api_Version_Number,
                           l_Api_Name,
                           G_Pkg_Name) Then

                Raise Fnd_Api.G_Exc_UnExpected_Error;

        End If;

        Pa_Rbs_Pub.Create_Rbs(
                P_Commit             => P_Commit,
                P_Init_Msg_List      => P_Init_Msg_List,
                P_API_Version_Number => P_Api_Version_Number,
                P_Header_Rec         => G_Rbs_Hdr_Rec,
                P_Version_Rec        => G_Rbs_Ver_Rec,
                P_Elements_Tbl       => G_Rbs_Elements_Tbl,
                X_Elements_Tbl       => l_Dummy_Elements_Tbl,
                X_Rbs_Header_Id      => l_Rbs_Header_Id,
                X_Rbs_Version_Id     => l_Rbs_Version_Id,
                X_Return_Status      => X_Return_Status,
                X_Msg_Count          => X_Msg_Count,
                X_Error_Msg_Data     => X_Msg_Data);

Exception
        When Fnd_Api.G_Exc_UnExpected_Error Then
                X_Return_Status := Fnd_Api.G_Ret_Sts_UnExp_Error;
		 Rollback;
        When Others Then
                X_return_status := Fnd_Api.G_Ret_Sts_UnExp_Error;

                If Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_Msg_Lvl_UnExp_Error) Then
                        Fnd_Msg_Pub.Add_Exc_Msg(
                                P_Pkg_Name       =>  G_Pkg_Name,
                                P_Procedure_Name =>  l_Api_Name);

                End If;

                Fnd_Msg_Pub.Count_And_Get(
                                P_Count => X_Msg_Count,
                                P_Data  => X_Msg_Data );
                 Rollback;

End Exec_Create_Rbs;

/*
************************************************************************************
*  API Name: Exec_Update_Rbs
*  Public/Private: Public
*  Procedure/Function: Procedure
*  Description:
*     This API uses the data that was loaded via the load_rbs_header(),
*     load_rbs_version(), and load_rbs_elements() API's to call the
*     Update_Rbs() API.
* *************************************************************************************
*/
Procedure Exec_Update_Rbs(
        P_Commit             IN         Varchar2 := Fnd_Api.G_False,
        P_Init_Msg_List      IN         Varchar2 := Fnd_Api.G_True,
        P_Api_Version_Number IN         Number,
        X_Return_Status      OUT NOCOPY Varchar2,
        X_Msg_Count          OUT NOCOPY Number,
        X_Msg_Data           OUT NOCOPY Varchar2)

Is

        l_Api_Version_Number   CONSTANT NUMBER       := G_Api_Version_Number;
        l_Api_Name             CONSTANT VARCHAR2(30) := 'Exec_Update_Rbs';
        l_Message_Count        NUMBER;
        l_Dummy_Elements_Tbl   Rbs_Elements_Tbl_Typ;

BEGIN

        X_Return_Status := Fnd_Api.G_Ret_Sts_Success;

        -- Standard Api compatibility call
        If Not Fnd_Api.Compatible_Api_Call(
                           l_Api_Version_Number,
                           P_Api_Version_Number,
                           l_Api_Name,
                           G_Pkg_Name) Then

                Raise Fnd_Api.G_Exc_UnExpected_Error;

        End If;

        Pa_Rbs_Pub.Update_Rbs(
                P_Commit             => P_Commit,
                P_Init_Msg_List      => P_Init_Msg_List,
                P_API_Version_Number => P_Api_Version_Number,
                P_Header_Rec         => G_Rbs_Hdr_Rec,
                P_Version_Rec        => G_Rbs_Ver_Rec,
                P_Elements_Tbl       => G_Rbs_Elements_Tbl,
                X_Elements_Tbl       => l_Dummy_Elements_Tbl,
                X_Return_Status      => X_Return_Status,
                X_Msg_Count          => X_Msg_Count,
                X_Error_Msg_Data     => X_Msg_Data);

Exception
        When Fnd_Api.G_Exc_UnExpected_Error Then
                X_Return_Status := Fnd_Api.G_Ret_Sts_UnExp_Error;

        When Others Then
                X_return_status := Fnd_Api.G_Ret_Sts_UnExp_Error;

                If Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_Msg_Lvl_UnExp_Error) Then
                        Fnd_Msg_Pub.Add_Exc_Msg(
                                P_Pkg_Name       =>  G_Pkg_Name,
                                P_Procedure_Name =>  l_Api_Name);

                End If;

                Fnd_Msg_Pub.Count_And_Get(
                                P_Count => X_Msg_Count,
                                P_Data  => X_Msg_Data );

End Exec_Update_Rbs;

/*
**************************************************************************************************
* API Name: Copy_Rbs_Working_Version
* Description:
*    This API is used to create a working version from an existing frozen version.
*       P_RBS_Version_Id - the frozen version id to copy from
*       P_Rbs_Header_Id  - Header for the frozen and the working version
*       P_Rec_Version_Number - for the current working version
*	 P_Rbs_Header_Name - the rbs header name of version selected to make a copy
*	 P_Rbs_Version_Number - the rbs versions version number
*****************************************************************************************************
*/
Procedure Copy_Rbs_Working_Version(
        P_Commit                IN         Varchar2 Default Fnd_Api.G_False,
        P_Init_Msg_List         IN         Varchar2 Default Fnd_Api.G_True,
        P_Api_Version_Number    IN         Number,
        P_RBS_Version_Id        IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Rbs_Header_Id         IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
	P_Rbs_Header_Name	IN	   Varchar2 Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
	P_Rbs_Version_Number    IN	   Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Rec_Version_Number    IN         Number,
        X_Return_Status         OUT NOCOPY Varchar2,
        X_Msg_Count             OUT NOCOPY Number,
        X_Error_Msg_Data        OUT NOCOPY Varchar2 )

Is

        l_Api_Name Varchar2(30) := 'Copy_Rbs_Working_Version';
        l_Error    Exception;
	l_rbs_header_id Number;
	l_rbs_version_id Number;

	--Retrieves rbs_version_id provided both rbs_header_id and rbs_version_number

	Cursor C_GetVersionId1(P_Header_Id IN Number, P_Version_Number IN Number) Is
	Select
		rbs_version_id
	From
		Pa_Rbs_Versions_b
	Where
		rbs_header_id=P_Header_Id
	And
		version_number=P_Version_Number;

	--Retrieves rbs_version_id provided both rbs name and rbs_version_number

	Cursor C_GetVersionId2(P_Header_Name IN Varchar2, P_Version_Number IN Number) Is
	Select
		rbs_version_id
	From
		Pa_Rbs_Versions_b ver, Pa_Rbs_Headers_tl Hdr
	Where
		hdr.name=P_Header_Name
        And
                hdr.language = userenv('LANG')
	And
		hdr.rbs_header_id=ver.rbs_header_id
	And
		ver.version_number=P_Version_Number;

	--Retrieves rbs_header_id from rbs_version_id

	Cursor C_GetHeaderId Is
	Select
		rbs_header_id
	From
		Pa_Rbs_Versions_b
	Where
		rbs_version_id=P_RBS_Version_Id;

Begin

        Pa_Debug.G_Path := ' ';

        Pa_Debug.G_Stage := 'Entering Copy_Rbs_Working_Version().';
        Pa_Debug.TrackPath('ADD','Copy_Rbs_Working_Version');

        Pa_Debug.G_Stage := 'Call Compatibility API.';
        If Not Fnd_Api.Compatible_API_Call (
                        Pa_Rbs_Pub.G_Api_Version_Number,
                        P_Api_Version_Number,
                        l_Api_Name,
                        Pa_Rbs_Pub.G_Pkg_Name) Then

                Raise Fnd_Api.G_Exc_Unexpected_Error;

        End If;


        Pa_Debug.G_Stage := 'Check if need to initialize the message stack(T-True,F-False) - ' || P_Init_Msg_List;
        If Fnd_Api.To_Boolean(nvl(P_Init_Msg_List,Fnd_Api.G_True)) Then

                Pa_Debug.G_Stage := 'Initializing message stack by calling Fnd_Msg_Pub.Initialize().';
                Fnd_Msg_Pub.Initialize;

        End If;

        Pa_Debug.G_Stage := 'Initialize error handling variables.';
        X_Error_Msg_Data := Null;
        X_Msg_Count      := 0;
        X_Return_Status  := Fnd_Api.G_Ret_Sts_Success;


	l_Rbs_Version_Id:=P_Rbs_Version_Id;

	Pa_Debug.G_Stage := 'Checks if P_Rbs_Version_Id is null';
	If P_Rbs_Version_Id is null or  P_Rbs_Version_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then

		If P_Rbs_Header_Id is not null and  P_Rbs_Header_Id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM and P_Rbs_Version_Number  <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM   and P_Rbs_Version_Number is not null then

			OPEN C_GetVersionId1(P_Header_Id=>P_Rbs_Header_Id,P_Version_Number=>P_Rbs_Version_Number);
			FETCH C_GetVersionId1 INTO l_Rbs_Version_Id;
			CLOSE C_GetVersionId1;

		ElsIf P_Rbs_Header_Name is not null and P_Rbs_Header_Name <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM and  P_Rbs_Version_Number <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM and P_Rbs_Version_Number is not null then

			OPEN C_GetVersionId2(P_Header_Name=>P_Rbs_Header_Name,P_Version_Number=>P_Rbs_Version_Number);
			FETCH C_GetVersionId2 INTO l_Rbs_Version_Id;
			CLOSE C_GetVersionId2;
		Else
			Pa_Debug.G_Stage := 'Raise Error: Not able to derive rbs_version_id';
			X_Error_Msg_Data:='PA_RBS_VERSION_ID_NOT_PASSED_AMG';
                        Pa_Utils.Add_Message
                            (P_App_Short_Name  => 'PA',
                             P_Msg_Name        => 'PA_RBS_VERSION_ID_NOT_PASSED_AMG');
			Raise l_error;
		End If;

	End IF;

	l_Rbs_Header_Id:=P_Rbs_Header_Id;

	Pa_Debug.G_Stage := 'Checks if P_Rbs_Header_Id is null';
	If P_Rbs_Header_Id is null or P_Rbs_Header_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then

		OPEN C_GetHeaderId;
		FETCH C_GetHeaderId Into l_Rbs_Header_Id;
		CLOSE C_GetHeaderId;

	End If;


        Pa_Debug.G_Stage := 'Call Pa_Rbs_Versions_Pvt.Create_New_Working_Version() procedure.';
        Pa_Rbs_Versions_Pub.Create_Working_Version(
                P_Commit              => P_Commit,
                P_Init_Msg_List       => P_Init_Msg_List,
                P_Api_Version_Number  => P_Api_Version_Number,
                P_RBS_Version_Id      => l_Rbs_Version_Id,
                P_Rbs_Header_Id       => l_Rbs_Header_Id,
                P_Rec_Version_Number  => P_Rec_Version_Number,
                P_Init_Debugging_Flag => 'N',
                X_Return_Status       => X_Return_Status,
                X_Msg_Count           => X_Msg_Count,
                X_Error_Msg_Data      => X_Error_Msg_Data );

        Pa_Debug.G_Stage := 'Check if error message data is populated.';
        If X_Error_Msg_Data Is Not Null Then

                Pa_Debug.G_Stage := 'Raise user defined error due to error msg data parameter being populated.';
                Raise l_error;

        End If;

        Pa_Debug.G_Stage := 'Leaving Copy_Rbs_Working_Version() procedure.';
        Pa_Debug.TrackPath('STRIP','Copy_Rbs_Working_Version');

Exception
        When l_Error Then
                X_Return_Status := 'E';
                X_Msg_Count := 1;
		 Rollback;
                 Return;
        When Others Then
                X_Return_Status := 'U';
                X_Msg_Count := 1;
                X_Error_Msg_Data := Pa_Rbs_Pub.G_Pkg_Name || ':::' || Pa_Debug.G_Path || '::' || Pa_Debug.G_Stage || ':' || SqlErrm;

                --For bug 4061935.
                If Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_Msg_Lvl_UnExp_Error) Then
                   Fnd_Msg_Pub.Add_Exc_Msg(
                    P_Pkg_Name       => G_Pkg_Name,
                    P_Procedure_Name => l_Api_Name);
                End If;

                Rollback;
                Return;

End Copy_Rbs_Working_Version;

/*
***************************************************************************************************
* API Name: Freeze_Rbs_Version
* Description:
*    This API to freeze the current working version for the RBS and create and new
*   working version.
 ****************************************************************************************************
*/
PROCEDURE Freeze_Rbs_Version(
        P_Commit                                IN         Varchar2 Default Fnd_Api.G_False,
        P_Init_Msg_List                         IN         Varchar2 Default Fnd_Api.G_True,
        P_API_Version_Number                    IN         Number,
        P_Rbs_Version_Id                        IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
	P_Rbs_Header_Name			IN	   Varchar2 Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
	P_Rbs_Header_Id				IN	   Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Rbs_Version_Record_Ver_Num            IN         Number Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        X_Return_Status                         OUT NOCOPY Varchar2,
        X_Msg_Count                             OUT NOCOPY Number,
        X_Error_Msg_Data                        OUT NOCOPY Varchar2)
IS

        l_Error                         Exception;
        l_Api_Name Varchar2(30) := 'Freeze_Rbs_Version';
	l_rbs_version_id 	Number;

	Cursor C_GetVersionId1(P_Header_Id IN Number) Is
	Select
		Rbs_Version_Id
	From
		Pa_Rbs_Versions_b
	Where
		rbs_header_id=P_Header_Id
	And
		status_code='WORKING';

	Cursor C_GetVersionId2(P_Header_Name IN Varchar2) Is
	Select
		Rbs_Version_Id
	From
		Pa_Rbs_Versions_b ver, Pa_Rbs_Headers_tl Hdr
	Where
		Hdr.name=P_Header_Name
        And
                hdr.language = userenv('LANG')
	And
		Hdr.rbs_header_id=Ver.rbs_header_id
	And
		Ver.status_code='WORKING';

BEGIN

        Pa_Debug.G_Path := ' ';

        Pa_Debug.G_Stage := 'Entering Freeze_Rbs_Version().';
        Pa_Debug.TrackPath('ADD','Freeze_Rbs_Version');

        Pa_Debug.G_Stage := 'Call Compatibility API.';
        If Not Fnd_Api.Compatible_API_Call (
                        Pa_Rbs_Pub.G_Api_Version_Number,
                        P_Api_Version_Number,
                        l_Api_Name,
                        Pa_Rbs_Pub.G_Pkg_Name) Then

                Raise Fnd_Api.G_Exc_Unexpected_Error;

        End If;

        --For bug 4061935.
        Pa_Debug.G_Stage := 'Check if need to initialize the message stack(T-True,F-False) - ' || P_Init_Msg_List;
        If Fnd_Api.To_Boolean(nvl(P_Init_Msg_List,Fnd_Api.G_True)) Then

                Pa_Debug.G_Stage := 'Initializing message stack by calling Fnd_Msg_Pub.Initialize().';
                Fnd_Msg_Pub.Initialize;

        End If;

        Pa_Debug.G_Stage := 'Initialize error handling variables.';
        X_Error_Msg_Data := Null;
        X_Msg_Count      := 0;
        X_Return_Status  := Fnd_Api.G_Ret_Sts_Success;


	l_Rbs_Version_Id:=P_Rbs_Version_Id;

	Pa_Debug.G_Stage := 'Checks if P_Rbs_Version_Id is null';
	If P_Rbs_Version_Id is null or P_Rbs_Version_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  Then

		If P_Rbs_Header_Id is not null and P_Rbs_Header_Id  <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then

				OPEN C_GetVersionId1(P_Header_Id=>P_Rbs_Header_Id);
                                FETCH C_GetVersionId1 INTO l_Rbs_Version_Id;
                                CLOSE C_GetVersionId1;

		ElsIf P_Rbs_Header_Name is not null and P_Rbs_Header_Name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR Then

				OPEN C_GetVersionId2(P_Header_Name=>P_Rbs_Header_Name);
                                FETCH C_GetVersionId2 INTO l_Rbs_Version_Id;
                                CLOSE C_GetVersionId2;
		Else
			Pa_Debug.G_Stage := 'Raise Error:Not able to derive rbs_version_id';
			X_Error_Msg_Data := 'PA_RBS_VERSION_ID_NOT_PASSED_AMG';
                        Pa_Utils.Add_Message
                        (P_App_Short_Name  => 'PA',
                         P_Msg_Name        => 'PA_RBS_VERSION_ID_NOT_PASSED_AMG');
			Raise l_error;
		End If;

	End If;


        Pa_Debug.G_Stage := 'Create a copy of the version being freezed which will be the working version for this header.';
        Pa_Rbs_Versions_Pub.Freeze_Working_Version(
                P_Commit                      => P_Commit,
                P_Init_Msg_List               => P_Init_Msg_List,
                P_Rbs_Version_Id              => l_Rbs_Version_Id,
                P_Rbs_Version_Record_Ver_Num  => P_Rbs_Version_Record_Ver_Num,
                P_Init_Debugging_Flag         => 'N',
                X_Return_Status               => X_Return_Status,
                X_Msg_Count                   => X_Msg_Count,
                X_Error_Msg_Data              => X_Error_Msg_Data);

        Pa_Debug.G_Stage := 'Check if Pa_Rbs_Versions_Pub.Create_Working_Version() procedure return error.';
        If X_Error_Msg_Data Is Not Null Then

                Pa_Debug.G_Stage := 'Check if Pa_Rbs_Versions_Pub.Create_Working_Version() procedure return error.';
                Raise l_error;

        End If;

        Pa_Debug.G_Stage := 'Leaving Freeze_Rbs_Version() procedure.';
        Pa_Debug.TrackPath('STRIP','Freeze_Rbs_Version');

Exception
        When l_Error Then
                X_Return_Status := 'E';
                X_Msg_Count := 1;
		 Rollback;
                 Return;
        When Others Then
                X_Return_Status := 'U';
                X_Msg_Count := 1;
                X_Error_Msg_Data := Pa_Rbs_Pub.G_Pkg_Name || ':::' || Pa_Debug.G_Path || '::' || Pa_Debug.G_Stage || ':' || SqlErrm;

                If Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_Msg_Lvl_UnExp_Error) Then
                   Fnd_Msg_Pub.Add_Exc_Msg(
                    P_Pkg_Name       => G_Pkg_Name,
                    P_Procedure_Name => l_Api_Name);
                End If;

                Rollback;
                Return;

END Freeze_Rbs_Version;

/*
*******************************************************************************
* API Name: Assign_Rbs_To_Project
*
* Description:
*   This API will assign the RBS to a project.
*   You must provide the Rbs Header Id and the Project Id as in parameters
*  The rest have default values.  The RBS will always have a usage of Reporting.
* Note: Parameter P_Rbs_Version_Id is not used in the procedure. It is
*       retained for the time being.

*******************************************************************************
*/
Procedure Assign_Rbs_To_Project(
        P_Commit              IN         Varchar2 Default Fnd_Api.G_False,
        P_Init_Msg_List       IN         Varchar2 Default Fnd_Api.G_True,
        P_API_Version_Number  IN         Number,
        P_Rbs_Header_Id       IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Rbs_Version_Id      IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM, --Not used
        P_Project_Id          IN         Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
	P_Pm_project_Reference IN	 Varchar2 Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
	P_Rbs_Header_Name     IN	 Varchar2 Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR,
	P_Rbs_Version_Number  IN	 Number   Default PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
        P_Prog_Rep_Usage_Flag IN         Varchar2 Default 'N',
        P_Primary_Rep_Flag    IN         Varchar2 Default 'N',
        X_Return_Status       OUT NOCOPY Varchar2,
        X_Msg_Count           OUT NOCOPY Number,
        X_Error_Msg_Data      OUT NOCOPY Varchar2)

Is

        l_Api_Name Varchar2(30) := 'Assign_Rbs_To_Project';
        l_Error    Exception;
	l_rbs_header_id  Number;
        l_rbs_version_id Number;
	l_project_id     Number;

	Cursor C_GetVersionId1(P_Header_Id IN Number)  IS
        Select rbs_version_id
        From   Pa_Rbs_Versions_b
        Where  rbs_header_id = P_Header_Id
        And    current_reporting_flag = 'Y'; -- Added
        --And    version_number=P_Version_Number;

        Cursor C_GetVersionId2(P_Header_Name IN Varchar2) IS
        Select rbs_version_id
        From   Pa_Rbs_Versions_b ver,
               Pa_Rbs_Headers_tl Hdr
        Where  hdr.name = P_Header_Name
        And    hdr.language = userenv('LANG')
        And    hdr.rbs_header_id = ver.rbs_header_id
        And    ver.current_reporting_flag = 'Y'; -- Added
        --And    ver.version_number=P_Version_Number;

        --Cursor C_GetHeaderId Is
        --Select rbs_header_id
        --From   Pa_Rbs_Versions_b
        --Where  rbs_version_id = P_RBS_Version_Id;

l_current_flag VARCHAR2(1);

Begin

        Pa_Debug.G_Path := ' ';

        Pa_Debug.G_Stage := 'Entering Assign_Rbs_To_Project().';
        Pa_Debug.TrackPath('ADD','Assign_Rbs_To_Project');

        Pa_Debug.G_Stage := 'Call Compatibility API.';
        If Not Fnd_Api.Compatible_API_Call (
                        Pa_Rbs_Pub.G_Api_Version_Number,
                        P_Api_Version_Number,
                        l_Api_Name,
                        Pa_Rbs_Pub.G_Pkg_Name) Then

                Raise Fnd_Api.G_Exc_Unexpected_Error;

        End If;

        --For bug 4061935.
        Pa_Debug.G_Stage := 'Check if need to initialize the message stack(T-True,F-False) - ' || P_Init_Msg_List;
        If Fnd_Api.To_Boolean(nvl(P_Init_Msg_List,Fnd_Api.G_True)) Then

                Pa_Debug.G_Stage := 'Initializing message stack by calling Fnd_Msg_Pub.Initialize().';
                Fnd_Msg_Pub.Initialize;

        End If;

        Pa_Debug.G_Stage := 'Initialize error handling variables.';
        X_Error_Msg_Data := Null;
        X_Msg_Count      := 0;
        X_Return_Status  := Fnd_Api.G_Ret_Sts_Success;


	l_project_id := P_Project_Id;

	Pa_Debug.G_Stage := 'Check if P_Project_Id is null';
	If P_Project_Id is null or
           P_Project_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then

		Pa_Debug.G_Stage := 'Get the project id from Pa_Project_Pvt.Convert_Pm_Projref_to_id';

		Pa_Project_Pvt.Convert_Pm_Projref_to_id(
			P_Pm_Project_Reference => P_Pm_Project_Reference,
			P_pa_project_id        => P_Project_Id,
			P_out_project_id       => l_project_id,
			P_Return_Status        => X_Return_Status);

		If X_Return_Status <> 'S' Then
			X_Error_Msg_Data := Pa_Rbs_Pub.G_Pkg_Name || ':::' || Pa_Debug.G_Path || '::' || Pa_Debug.G_Stage || ':' || SqlErrm;
			Raise l_error;
		End If;

	End If;


	-- l_Rbs_Version_Id:=P_Rbs_Version_Id;

	Pa_Debug.G_Stage := 'Check if P_Rbs_Version_Id is null';

        -- If P_Rbs_Version_Id is null or  P_Rbs_Version_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then

        IF P_Rbs_Header_Id is not null AND
           P_Rbs_Header_Id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN

           OPEN  C_GetVersionId1(P_Header_Id => P_Rbs_Header_Id);
           FETCH C_GetVersionId1 INTO l_Rbs_Version_Id;
           CLOSE C_GetVersionId1;

        ELSIF P_Rbs_Header_Name is not null AND
              P_Rbs_Header_Name <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN

           OPEN  C_GetVersionId2(P_Header_Name => P_Rbs_Header_Name);
           FETCH C_GetVersionId2 INTO l_Rbs_Version_Id;
           CLOSE C_GetVersionId2;

        ELSE
           Pa_Debug.G_Stage := 'Raise Error: Not able to derive rbs_version_id';
           X_Error_Msg_Data := 'PA_INVALID_HEADER_ID';
                  Pa_Utils.Add_Message                 --For bug 4061935.
                        (P_App_Short_Name  => 'PA',
                         P_Msg_Name        => 'PA_INVALID_HEADER_ID');
           Raise l_error;
           -- End If;
        END IF;


        l_Rbs_Header_Id := P_Rbs_Header_Id;

/*
	Pa_Debug.G_Stage := 'Check if P_Rbs_Header_Id is null';
        If P_Rbs_Header_Id is null or
           P_Rbs_Header_Id =PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM   Then

                OPEN C_GetHeaderId;
                FETCH C_GetHeaderId Into l_Rbs_Header_Id;
                CLOSE C_GetHeaderId;

        End If;

        -- Add check to ensure that the rbs version ID being passed
        -- to API has current_reporting_flag as yes.
        l_current_flag := 'N';
        BEGIN
        SELECT nvl(current_reporting_flag, 'N')
        INTO   l_current_flag
        FROM   pa_rbs_versions_b
        WHERE  Rbs_Version_Id = l_Rbs_Version_Id;

        EXCEPTION WHEN NO_DATA_FOUND THEN
           l_current_flag := 'N';
        END;

        IF l_current_flag = 'N' THEN
           Pa_Debug.G_Stage := 'Raise Error: RBS version is not the latest';
           X_Error_Msg_Data := 'PA_RBS_VERSION_NOT_CURRENT';
           Raise l_error;
        END IF;
*/

       IF l_Rbs_Version_Id IS NULL THEN
          Pa_Debug.G_Stage := 'Raise Error: RBS version does not exist.';
          X_Error_Msg_Data := 'PA_AMG_VERSION_ID_NOT_PASSED';
                Pa_Utils.Add_Message
                        (P_App_Short_Name  => 'PA',
                         P_Msg_Name        => 'PA_AMG_VERSION_ID_NOT_PASSED');
          Raise l_error;
       END IF;

        Pa_Debug.G_Stage := 'Call Pa_Rbs_Asgmt_Pub.Create_RBS_Assignment() procedure.';
	Pa_Rbs_Asgmt_Pub.Create_RBS_Assignment(
                P_Commit              => Fnd_Api.G_False,
                P_Init_Msg_List       => Fnd_Api.G_False,
                P_Rbs_Header_Id       => l_Rbs_Header_Id,
                P_Rbs_Version_Id      => l_Rbs_Version_Id,
                P_Project_Id          => l_Project_Id,
                P_Prog_Rep_Usage_Flag => P_Prog_Rep_Usage_Flag,
                P_Primary_Rep_Flag    => P_Primary_Rep_Flag,
                X_Return_Status       => X_Return_Status,
                X_Msg_Count           => X_Msg_Count,
                X_Error_Msg_Data      => X_Error_Msg_Data);

        Pa_Debug.G_Stage := 'Check if Pa_Rbs_Asgmt_Pub.Create_RBS_Assignment() procedure return error.';
        If X_Error_Msg_Data Is Not Null Then

                Pa_Debug.G_Stage := 'Check if Pa_Rbs_Asgmt_Pub.Create_RBS_Assignment() procedure return error.';
                Raise l_error;

        End If;

        Pa_Debug.G_Stage := 'Leaving Assign_Rbs_To_Project() procedure.';
        Pa_Debug.TrackPath('STRIP','Assign_Rbs_To_Project');

Exception
        When l_Error Then
                X_Return_Status := 'E';
                X_Msg_Count := 1;
		 Rollback;
                 Return;
        When Others Then
                X_Return_Status := 'U';
                X_Msg_Count := 1;
                X_Error_Msg_Data := Pa_Rbs_Pub.G_Pkg_Name || ':::' || Pa_Debug.G_Path || '::' || Pa_Debug.G_Stage || ':' || SqlErrm;

                If Fnd_Msg_Pub.Check_Msg_Level(Fnd_Msg_Pub.G_Msg_Lvl_UnExp_Error) Then
                   Fnd_Msg_Pub.Add_Exc_Msg(
                    P_Pkg_Name       => G_Pkg_Name,
                    P_Procedure_Name => l_Api_Name);
                End If;

                Rollback;
                Return;

End Assign_Rbs_To_Project;

/*
*****************************************************************************
* API Name: PopulateErrorStack
* Description:
*    This API is used to generate a usable message when processing the
*    rbs elements.  If is for internal use only and should not be called
*    externally.
****************************************************************************
*/
Procedure PopulateErrorStack(
	P_Ref_Element_Id IN Number,
	P_Element_Id     IN Number,
	P_Process_Type   IN Varchar,
	P_Error_Msg_Data IN Varchar2)

Is

	l_Msg_Token_Value Varchar2(2000) := Null;
        l_Prefix_Value    Varchar2(80) := Null;
        l_Outline         Varchar2(240) := Null;

        Cursor c1(P_Lookup_Code IN Varchar2) Is
        Select
                Meaning
        From
                Pa_Lookups
        Where
                Lookup_Type = 'PA_RBS_API_ERR_TOKENS'
        And     Lookup_code = P_Lookup_Code;

        Cursor c2(P_Id IN Number) Is
        Select
                Outline_Number
        From
                Pa_Rbs_Elements
        Where
                Rbs_Element_Id = P_Id;

Begin

        Pa_Debug.G_Stage := 'Entering PopulateErrorStack() procedure.';
        Pa_Debug.TrackPath('ADD','PopulateErrorStack');

	If P_Process_Type = 'A' Then

                Open c1(P_Lookup_Code => 'REFERENCE_ELEMENT_ID');
                Fetch c1 Into l_Prefix_Value;
                Close c1;

		l_Msg_Token_Value := l_Prefix_Value || ': ' || to_char(P_Ref_Element_Id) || ': ' ;

        Else

                Open c1(P_Lookup_Code => 'OUTLINE_NUMBER');
                Fetch c1 Into l_Prefix_Value;
                Close c1;

                Open c2(P_Id => P_Element_Id);
                Fetch c2 Into l_Outline;
                Close c2;

                l_Msg_Token_Value := l_Prefix_Value || ': ' || l_Outline || ': ' ;

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

End Pa_Rbs_Pub;

/
