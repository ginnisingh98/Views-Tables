--------------------------------------------------------
--  DDL for Package Body OKE_DELIVERABLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_DELIVERABLE_PVT" AS
/* $Header: OKEVDELB.pls 120.2 2005/11/23 14:37:29 ausmani noship $ */

  FUNCTION validate_attributes( p_del_rec IN  del_rec_type)
		RETURN VARCHAR2;

  G_NO_PARENT_RECORD CONSTANT	VARCHAR2(200) := 'OKE_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR CONSTANT	VARCHAR2(200) := 'OKE_CONTRACTS_UNEXPECTED_ERROR';
  g_module          CONSTANT VARCHAR2(250) := 'oke.plsql.oke_deliverable_pvt.';
  G_SQLERRM_TOKEN	 CONSTANT	VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN	 CONSTANT	VARCHAR2(200) := 'SQLcode';
  G_VIEW		 CONSTANT	VARCHAR2(200) := 'OKE_K_DELIVERABLES_VL';
  G_EXCEPTION_HALT_VALIDATION	exception;
  l_return_status	VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;

-- validation code goes here


  PROCEDURE Validate_Header_ID (X_Return_Status OUT NOCOPY VARCHAR2,
                                 	P_Del_Rec      IN    Del_Rec_Type) IS

    L_Value VARCHAR2(1) := 'N';

    CURSOR C (P_ID NUMBER) IS
    SELECT 'X'
    FROM okc_k_headers_b
    WHERE ID = P_ID;

  Begin

    X_Return_Status := OKE_API.G_RET_STS_SUCCESS;

    IF P_DEL_REC.K_Header_ID IS NOT NULL THEN



      OPEN C ( P_DEL_REC.K_Header_ID);
      FETCH C INTO L_Value;
      CLOSE C;

      IF L_Value <> 'X' THEN

  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'K_Header_ID');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;

    ELSE

  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_required_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'K_Header_ID');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

    End If;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      NULL; -- Even failed, continue validate other attributes

    WHEN OTHERS THEN

	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					  p_msg_name	=> g_unexpected_error,
					  p_token1	=> g_sqlcode_token,
					  p_token1_value=> sqlcode,
					  p_token2	=> g_sqlerrm_token,
					  p_token2_value=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        X_Return_Status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End Validate_Header_ID;

  PROCEDURE Validate_Line_ID (X_Return_Status OUT NOCOPY   VARCHAR2,
                                 	P_Del_Rec      IN    Del_Rec_Type) IS

    L_Value VARCHAR2(1) := 'N';

    CURSOR C (P_ID NUMBER) IS
    SELECT 'X'
    FROM okc_k_lines_b
    WHERE ID = P_ID
    AND NOT EXISTS(SELECT 'X' FROM okc_ancestrys
       WHERE Cle_ID_Ascendant = P_ID);

  Begin

    X_Return_Status := OKE_API.G_RET_STS_SUCCESS;

    IF P_DEL_REC.K_Line_ID IS NOT NULL THEN

      -- Only the lowest level line should carrry deliverables

      OPEN C ( P_DEL_REC.K_Line_ID);
      FETCH C INTO L_Value;
      CLOSE C;



      IF L_Value <> 'X' THEN

  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'K_Line_ID');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

       END IF;

    ELSE

  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_required_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'K_Line_ID');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

    End If;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      NULL; -- Even failed, continue validate other attributes

    WHEN OTHERS THEN

	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					  p_msg_name	=> g_unexpected_error,
					  p_token1	=> g_sqlcode_token,
					  p_token1_value=> sqlcode,
					  p_token2	=> g_sqlerrm_token,
					  p_token2_value=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        X_Return_Status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End Validate_Line_ID;



  PROCEDURE Validate_Deliverable_Number(X_Return_Status OUT NOCOPY   VARCHAR2,
                                 	P_Del_Rec      IN    Del_Rec_Type) IS
    L_Value VARCHAR2(1) := 'N';

    CURSOR C (P_ID NUMBER, P_Num VARCHAR2 ) IS
    SELECT 'X'
    FROM oke_k_deliverables_b
    WHERE Deliverable_Num = P_Num
    AND K_Line_ID = P_ID;

  Begin

    X_Return_Status := OKE_API.G_RET_STS_SUCCESS;

    IF P_DEL_REC.Deliverable_Num IS NOT NULL AND P_DEL_REC.Deliverable_ID IS NULL THEN

      OPEN C ( P_DEL_REC.K_Line_ID, P_DEL_REC.Deliverable_Num );
      FETCH C INTO L_Value;
      CLOSE C;



      IF L_Value = 'X' THEN

  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Deliverable_Num');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

      END IF;
    END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      NULL; -- Even failed, continue validate other attributes

    WHEN OTHERS THEN

	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					  p_msg_name	=> g_unexpected_error,
					  p_token1	=> g_sqlcode_token,
					  p_token1_value=> sqlcode,
					  p_token2	=> g_sqlerrm_token,
					  p_token2_value=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        X_Return_Status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End Validate_Deliverable_Number;

  PROCEDURE Validate_Project_ID (X_Return_Status OUT NOCOPY   VARCHAR2,
                                 	P_Del_Rec      IN    Del_Rec_Type) IS

    L_Line_Id Number;
    L_Sequence Number := 1;
    L_Max_Sequence Number;
    L_Project_Id NUMBER;
    L_Task_Id NUMBER;
    L_Parent_Id NUMBER;
    L_Value VARCHAR2(1) := 'N';

    CURSOR Header_C ( P_Header_Id Number ) IS
    SELECT Project_ID
    FROM oke_k_headers
    WHERE K_Header_Id = P_Header_Id;

    CURSOR Top_C IS
    SELECT PROJECT_ID, TASK_ID, PARENT_LINE_ID
    FROM oke_k_lines
    WHERE K_Line_Id = L_Line_Id;

    CURSOR Sub_C (P_Line_Id NUMBER, P_Sequence NUMBER) IS
    SELECT PROJECT_ID, TASK_ID
    FROM OKE_K_LINES
    WHERE K_LINE_ID = (SELECT CLE_ID_ASCENDANT FROM OKC_ANCESTRYS WHERE CLE_ID = P_LINE_ID AND LEVEL_SEQUENCE = P_SEQUENCE)
    AND PROJECT_ID IS NOT NULL;

    CURSOR C (P_ID NUMBER, P_ID1 NUMBER, P_ID2 NUMBER) IS
    SELECT 'X'
    FROM DUAL
    WHERE P_ID IN (
    SELECT P.Project_ID
    FROM pa_projects_all p
    WHERE p.Project_ID IN (SELECT To_Number(sub_project_id)
		FROM  pa_fin_structures_links_v
		START WITH parent_project_id = P_ID1 AND (parent_task_id IN (SELECT Task_ID FROM pa_tasks WHERE Top_Task_ID = P_ID2) or P_ID2 IS NULL)
		CONNECT BY parent_project_id = PRIOR sub_project_id)
		UNION
		SELECT Project_ID
		FROM pa_projects_all
		WHERE Project_ID = P_ID1);

    CURSOR Seq_C (P_ID NUMBER ) IS
    SELECT MAX(LEVEL_SEQUENCE)
    FROM OKC_ANCESTRYS
    WHERE CLE_ID = P_ID;

  Begin

    X_Return_Status := OKE_API.G_RET_STS_SUCCESS;

    IF P_DEL_REC.Project_ID IS NOT NULL THEN

    L_Line_Id := P_DEL_REC.K_Line_ID;

    OPEN Top_C;
    FETCH Top_C INTO L_Project_Id, L_Task_Id, L_Parent_Id;
    CLOSE Top_C;

    IF L_Project_Id IS NULL THEN
      IF L_Parent_Id IS NULL THEN

        OPEN Header_C (P_DEL_REC.K_Header_ID);
        FETCH Header_C INTO L_Project_Id;
        CLOSE Header_C;

      ELSE

	OPEN Seq_C ( L_Line_ID );
 	FETCH Seq_C INTO L_Max_Sequence;
	CLOSE Seq_C;

        FOR L_Sequence IN 1 ..L_Max_Sequence LOOP
          OPEN Sub_C( L_Line_Id, L_Sequence);
          Fetch Sub_C INTO L_Project_Id, L_Task_Id;
          CLOSE Sub_C;

          EXIT WHEN L_Project_Id IS NOT NULL;

        END LOOP;



        IF L_Project_Id IS NULL THEN
          OPEN Header_C ( P_DEL_REC.K_Header_ID );
          FETCH Header_C INTO L_Project_Id;
          CLOSE Header_C;
        END IF;


      END IF;

    END IF;

    OPEN C ( P_DEL_REC.Project_ID, L_Project_ID, L_Task_ID);
    FETCH C INTO L_Value;
    CLOSE C;



    IF L_Value <> 'X' THEN

  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Project_ID');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      NULL; -- Even failed, continue validate other attributes

    WHEN OTHERS THEN

	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					  p_msg_name	=> g_unexpected_error,
					  p_token1	=> g_sqlcode_token,
					  p_token1_value=> sqlcode,
					  p_token2	=> g_sqlerrm_token,
					  p_token2_value=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        X_Return_Status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End Validate_Project_ID;

  PROCEDURE Validate_Task_ID (X_Return_Status OUT NOCOPY   VARCHAR2,
                                 	P_Del_Rec      IN    Del_Rec_Type) IS
    L_Value VARCHAR2(1) := 'N';

    CURSOR C (P_ID1 NUMBER, P_ID2 NUMBER) IS
    SELECT 'X'
    FROM pa_tasks
    WHERE  Task_ID = P_ID1
    AND Project_ID = P_ID2;

  Begin

    X_Return_Status := OKE_API.G_RET_STS_SUCCESS;

    IF P_DEL_REC.Task_ID IS NOT NULL THEN

      IF P_DEL_REC.Project_ID IS NULL THEN

  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_required_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Project_ID');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

      ELSE

	OPEN C ( P_DEL_REC.Task_ID, P_DEL_REC.Project_ID );
        FETCH C INTO L_Value;
        CLOSE C;

        IF L_Value <> 'X' THEN

  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Task_ID');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

         END IF;

       END IF;

     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      NULL; -- Even failed, continue validate other attributes

    WHEN OTHERS THEN

	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					  p_msg_name	=> g_unexpected_error,
					  p_token1	=> g_sqlcode_token,
					  p_token1_value=> sqlcode,
					  p_token2	=> g_sqlerrm_token,
					  p_token2_value=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        X_Return_Status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End Validate_Task_ID;

  PROCEDURE Validate_Inventory_Org_ID (X_Return_Status OUT NOCOPY   VARCHAR2,
                                 	P_Del_Rec      IN    Del_Rec_Type) IS
    L_Value VARCHAR2(1) := 'N';

    CURSOR C (P_ID NUMBER ) IS
    SELECT 'X'
    FROM okx_organization_defs_v
    WHERE  ID1 = P_ID;

  Begin

    X_Return_Status := OKE_API.G_RET_STS_SUCCESS;

    IF P_DEL_REC.Inventory_Org_ID IS NOT NULL THEN

	OPEN C ( P_DEL_REC.Inventory_Org_ID );
        FETCH C INTO L_Value;
        CLOSE C;

        IF L_Value <> 'X' THEN

  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Inventory_Org_ID');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

         END IF;

     ELSE

  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_required_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Inventory_Org_ID');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;


     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      NULL; -- Even failed, continue validate other attributes

    WHEN OTHERS THEN

	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					  p_msg_name	=> g_unexpected_error,
					  p_token1	=> g_sqlcode_token,
					  p_token1_value=> sqlcode,
					  p_token2	=> g_sqlerrm_token,
					  p_token2_value=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        X_Return_Status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End Validate_Inventory_Org_ID;

  PROCEDURE Validate_Item_ID (X_Return_Status OUT NOCOPY   VARCHAR2,
                                 	P_Del_Rec      IN    Del_Rec_Type) IS
    L_Value VARCHAR2(1) := 'N';
    L_ID NUMBER;

    CURSOR C (P_ID1 NUMBER, P_ID2 NUMBER) IS
    SELECT 'X'
    FROM oke_system_items_v
    WHERE  ID1 = P_ID1
    AND ID2 = P_ID2;

  Begin

    X_Return_Status := OKE_API.G_RET_STS_SUCCESS;

    IF P_DEL_REC.Item_ID IS NOT NULL THEN

      IF P_DEL_REC.Direction = 'OUT' THEN

	IF P_DEL_REC.Ship_From_Org_ID IS NOT NULL THEN

	  L_ID := P_DEL_REC.Ship_From_Org_ID;

	ELSE

	  L_ID := P_DEL_REC.Inventory_Org_ID;

	END IF;

      ELSE

	IF P_DEL_REC.Ship_To_Org_ID IS NOT NULL THEN

	  L_ID := P_DEL_REC.Ship_To_Org_ID;

	ELSE

	  L_ID := P_DEL_REC.Inventory_Org_ID;

	END IF;

      END IF;

      IF P_DEL_REC.Inventory_Org_ID IS NULL THEN

  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_required_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Inventory_Org_ID');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

      ELSE

	OPEN C ( P_DEL_REC.Item_ID, L_ID );
        FETCH C INTO L_Value;
        CLOSE C;

        IF L_Value <> 'X' THEN

  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Item_ID');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

         END IF;

       END IF;

     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      NULL; -- Even failed, continue validate other attributes

    WHEN OTHERS THEN

	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					  p_msg_name	=> g_unexpected_error,
					  p_token1	=> g_sqlcode_token,
					  p_token1_value=> sqlcode,
					  p_token2	=> g_sqlerrm_token,
					  p_token2_value=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        X_Return_Status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End Validate_Item_ID;

  PROCEDURE Validate_Delivery_Date (X_Return_Status OUT NOCOPY   VARCHAR2,
                                 	P_Del_Rec      IN    Del_Rec_Type) IS
    L_Value VARCHAR2(1) := 'N';

    CURSOR C IS
    SELECT 'X'
    FROM okc_k_lines_b
    WHERE  P_DEL_REC.Delivery_Date >= NVL(P_DEL_REC.Start_Date, P_DEL_REC.Delivery_Date)
    AND P_DEL_REC.Delivery_Date <= NVL(P_DEL_REC.End_Date, P_DEL_REC.Delivery_Date)
    AND P_DEL_REC.Delivery_Date >= NVL(Start_Date, P_DEL_REC.Delivery_Date)
    AND P_DEL_REC.Delivery_Date <= NVL(End_Date, P_DEL_REC.Delivery_Date)
    AND ID = P_DEL_REC.K_Line_ID;

  Begin

    X_Return_Status := OKE_API.G_RET_STS_SUCCESS;

    IF P_DEL_REC.Delivery_Date IS NOT NULL THEN

	OPEN C ;
        FETCH C INTO L_Value;
        CLOSE C;

        IF L_Value <> 'X' THEN

  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Delivery_Date');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

         END IF;

     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      NULL; -- Even failed, continue validate other attributes

    WHEN OTHERS THEN

	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					  p_msg_name	=> g_unexpected_error,
					  p_token1	=> g_sqlcode_token,
					  p_token1_value=> sqlcode,
					  p_token2	=> g_sqlerrm_token,
					  p_token2_value=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        X_Return_Status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End Validate_Delivery_Date;

  PROCEDURE Validate_Direction (X_Return_Status OUT NOCOPY   VARCHAR2,
                                 	P_Del_Rec      IN    Del_Rec_Type) IS
  Begin

    X_Return_Status := OKE_API.G_RET_STS_SUCCESS;

    IF P_DEL_REC.Direction IS NOT NULL THEN

      IF P_DEL_REC.Direction NOT IN ('IN', 'OUT') THEN

  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Direction');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;


       END IF;

    ELSE

  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_required_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Direction');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      NULL; -- Even failed, continue validate other attributes

    WHEN OTHERS THEN

	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					  p_msg_name	=> g_unexpected_error,
					  p_token1	=> g_sqlcode_token,
					  p_token1_value=> sqlcode,
					  p_token2	=> g_sqlerrm_token,
					  p_token2_value=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        X_Return_Status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End Validate_Direction;

  PROCEDURE Validate_Ship_To_Org_ID (X_Return_Status OUT NOCOPY   VARCHAR2,
                                 	P_Del_Rec      IN    Del_Rec_Type) IS

    L_Value VARCHAR2(1) := 'N';
    L_Intent VARCHAR2(1);

    CURSOR C1 ( P_ID NUMBER ) IS
    SELECT 'X'
    FROM okx_organization_defs_v
    WHERE ID1 = P_ID;

    CURSOR C2 ( P_ID NUMBER ) IS
    SELECT 'X'
    FROM oke_customer_accounts_v
    WHERE ID1 = P_ID;

  Begin

    X_Return_Status := OKE_API.G_RET_STS_SUCCESS;

    IF P_DEL_REC.Ship_To_Org_ID > 0 THEN

      IF P_DEL_REC.Direction = 'IN' THEN

	OPEN C1 ( P_DEL_REC.Ship_To_Org_ID );
        FETCH C1 INTO L_Value;
        CLOSE C1;

      ELSIF P_DEL_REC.Direction = 'OUT' THEN

	OPEN C2 ( P_DEL_REC.Ship_To_Org_ID );
        FETCH C2 INTO L_Value;
        CLOSE C2;


      END IF;

      IF L_Value <>  'X' THEN

        OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Ship_To_Org_ID');
	-- notify caller of an error
        X_Return_Status := OKE_API.G_RET_STS_ERROR;

	-- halt validation
	RAISE G_EXCEPTION_HALT_VALIDATION;


       END IF;

     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      NULL; -- Even failed, continue validate other attributes

    WHEN OTHERS THEN

	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					  p_msg_name	=> g_unexpected_error,
					  p_token1	=> g_sqlcode_token,
					  p_token1_value=> sqlcode,
					  p_token2	=> g_sqlerrm_token,
					  p_token2_value=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        X_Return_Status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End Validate_Ship_To_Org_ID;

  PROCEDURE Validate_Ship_From_Org_ID (X_Return_Status OUT NOCOPY   VARCHAR2,
                                 	P_Del_Rec      IN    Del_Rec_Type) IS

    L_Value VARCHAR2(1) := 'N';
    L_Intent VARCHAR2(1);

    CURSOR C ( P_ID NUMBER ) IS
    SELECT Buy_Or_Sell
    FROM okc_k_headers_b
    WHERE ID = P_ID;

    CURSOR C1 ( P_ID NUMBER ) IS
    SELECT 'X'
    FROM okx_vendors_v
    WHERE ID1 = P_ID;

    CURSOR C2 ( P_ID NUMBER ) IS
    SELECT 'X'
    FROM oke_customer_accounts_v
    WHERE ID1 = P_ID;

    CURSOR C3 ( P_ID NUMBER ) IS
    SELECT 'X'
    FROM okx_organization_defs_v
    WHERE ID1 = P_ID;


  Begin

    X_Return_Status := OKE_API.G_RET_STS_SUCCESS;

    IF P_DEL_REC.Ship_From_Org_ID > 0 THEN

      IF P_DEL_REC.Direction = 'IN' THEN

        OPEN C ( P_DEL_REC.K_Header_ID );
        FETCH C INTO L_Intent;
        CLOSE C;

        IF L_Intent = 'B' THEN

	  OPEN C1 ( P_DEL_REC.Ship_From_Org_ID );
	  FETCH C1 INTO L_Value;
	  CLOSE C1;

      	ELSIF L_Intent = 'S' THEN

	  OPEN C2 ( P_DEL_REC.Ship_From_Org_ID );
	  FETCH C2 INTO L_Value;
	  CLOSE C2;

	END IF;

      ELSIF P_DEL_REC.Direction = 'OUT' THEN

	OPEN C3 ( P_DEL_REC.Ship_From_Org_ID );
       	FETCH C3 INTO L_Value;
	CLOSE C3;

      END IF;


      IF L_Value <>  'X' THEN

        OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Ship_From_Org_ID');
	-- notify caller of an error
        X_Return_Status := OKE_API.G_RET_STS_ERROR;

	-- halt validation
	RAISE G_EXCEPTION_HALT_VALIDATION;


       END IF;

     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      NULL; -- Even failed, continue validate other attributes

    WHEN OTHERS THEN

	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					  p_msg_name	=> g_unexpected_error,
					  p_token1	=> g_sqlcode_token,
					  p_token1_value=> sqlcode,
					  p_token2	=> g_sqlerrm_token,
					  p_token2_value=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        X_Return_Status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End Validate_Ship_From_Org_ID;

  PROCEDURE Validate_Ship_To_Location_ID (X_Return_Status OUT NOCOPY   VARCHAR2,
                                 	P_Del_Rec      IN    Del_Rec_Type) IS
    L_Value VARCHAR2(1) := 'N';

    CURSOR C1 ( P_ID1 NUMBER, P_ID2 NUMBER ) IS
    SELECT 'X'
    FROM oke_cust_site_uses_v
    WHERE  Cust_Account_ID = P_ID2
    AND ID1 = P_ID1;

    CURSOR C2 ( P_ID1 NUMBER, P_ID2 NUMBER ) IS
    SELECT 'X'
    FROM okx_locations_v
    WHERE ID1 = P_ID1
    AND Organization_ID = P_ID2;



  Begin

    X_Return_Status := OKE_API.G_RET_STS_SUCCESS;

    IF P_DEL_REC.Ship_To_Location_ID > 0 THEN

      IF P_DEL_REC.Ship_To_Org_ID IS NULL THEN

  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_required_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Ship_to_org_ID if ship_to_location_ID is present');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

      ELSE

	IF NVL(P_DEL_REC.Direction, 'OUT') = 'OUT' THEN

	  OPEN C1 ( P_DEL_REC.Ship_To_Location_ID, P_DEL_REC.Ship_To_Org_ID );
	  FETCH C1 INTO L_Value;
	  CLOSE C1;

	ELSE

	  OPEN C2 ( P_DEL_REC.Ship_To_Location_ID, P_DEL_REC.Ship_To_Org_ID );
	  FETCH C2 INTO L_Value;
	  CLOSE C2;

	END IF;

        IF L_Value <> 'X' THEN

  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Ship_To_Location_ID');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

         END IF;

       END IF;

     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      NULL; -- Even failed, continue validate other attributes

    WHEN OTHERS THEN

	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					  p_msg_name	=> g_unexpected_error,
					  p_token1	=> g_sqlcode_token,
					  p_token1_value=> sqlcode,
					  p_token2	=> g_sqlerrm_token,
					  p_token2_value=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        X_Return_Status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End Validate_Ship_To_location_ID;

  PROCEDURE Validate_Ship_From_Location_ID (X_Return_Status OUT NOCOPY   VARCHAR2,
                                 	P_Del_Rec      IN    Del_Rec_Type) IS
    L_Value VARCHAR2(1) := 'N';
    L_Intent VARCHAR2(1);

    CURSOR C1 ( P_ID1 NUMBER, P_ID2 NUMBER ) IS
    SELECT 'X'
    FROM okx_vendor_sites_v
    WHERE  Vendor_ID = P_ID2
    AND ID1 = P_ID1;

    CURSOR C2 ( P_ID1 NUMBER, P_ID2 NUMBER ) IS
    SELECT 'X'
    FROM okx_locations_v
    WHERE ID1 = P_ID1
    AND Organization_ID = P_ID2;

    CURSOR C3 ( P_ID1 NUMBER, P_ID2 NUMBER ) IS
    SELECT 'X'
    FROM oke_cust_site_uses_v
    WHERE ID1 = P_ID1
    AND Cust_Account_ID = P_ID2;

    CURSOR Header_C ( P_ID NUMBER ) IS
    SELECT Buy_Or_Sell
    FROM okc_k_headers_b
    WHERE ID = P_ID;



  Begin

    X_Return_Status := OKE_API.G_RET_STS_SUCCESS;

    IF P_DEL_REC.Ship_From_Location_ID > 0 THEN

      IF P_DEL_REC.Ship_From_Org_ID IS NULL THEN

  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_required_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Ship_From_org_ID if ship_from_location_ID is present');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

      ELSE

	IF NVL(P_DEL_REC.Direction, 'OUT') = 'OUT' THEN

	  OPEN C2 ( P_DEL_REC.Ship_From_Location_ID, P_DEL_REC.Ship_From_Org_ID );
	  FETCH C2 INTO L_Value;
	  CLOSE C2;

	ELSE

	  OPEN Header_C ( P_DEL_REC.K_Header_ID );
	  FETCH Header_C INTO L_Intent;
	  CLOSE Header_C;

	  IF L_Intent = 'B' THEN

	    OPEN C1 ( P_DEL_REC.Ship_From_Location_ID, P_DEL_REC.Ship_From_Org_ID );
	    FETCH C1 INTO L_Value;
	    CLOSE C1;

	  ELSE

	    OPEN C3 ( P_DEL_REC.Ship_From_Location_ID, P_DEL_REC.Ship_From_Org_ID );
	    FETCH C3 INTO L_Value;
	    CLOSE C3;

	  END IF;

	END IF;

        IF L_Value <> 'X' THEN

  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Ship_From_Location_ID');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

         END IF;

       END IF;

     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      NULL; -- Even failed, continue validate other attributes

    WHEN OTHERS THEN

	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					  p_msg_name	=> g_unexpected_error,
					  p_token1	=> g_sqlcode_token,
					  p_token1_value=> sqlcode,
					  p_token2	=> g_sqlerrm_token,
					  p_token2_value=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        X_Return_Status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End Validate_Ship_From_location_ID;


  PROCEDURE Validate_In_Process_Flag (X_Return_Status OUT NOCOPY   VARCHAR2,
                                 	P_Del_Rec      IN    Del_Rec_Type) IS
    L_Value VARCHAR2(1) := 'N';


  Begin

    X_Return_Status := OKE_API.G_RET_STS_SUCCESS;

    IF P_DEL_REC.In_Process_Flag = 'Y' THEN

      IF P_DEL_REC.Po_Ref_1 IS NULL AND P_DEL_REC.Mps_Transaction_ID IS NULL AND P_DEL_REC.Shipping_Request_ID IS NULL THEN


  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'In_Process_Flag');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

       END IF;

     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      NULL; -- Even failed, continue validate other attributes

    WHEN OTHERS THEN

	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					  p_msg_name	=> g_unexpected_error,
					  p_token1	=> g_sqlcode_token,
					  p_token1_value=> sqlcode,
					  p_token2	=> g_sqlerrm_token,
					  p_token2_value=> sqlerrm);
	   -- notify caller of an error as UNEXPETED error
        X_Return_Status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End Validate_In_Process_Flag;


  PROCEDURE Validate_Start_Date (X_Return_Status OUT NOCOPY   VARCHAR2,
                                 	P_Del_Rec      IN    Del_Rec_Type) IS
    L_Value VARCHAR2(1) := 'N';
    L_Start_Date DATE;
    L_End_Date DATE;

    CURSOR C ( P_ID NUMBER ) IS
    SELECT Start_Date, End_Date
    FROM okc_k_lines_b
    WHERE ID = P_ID;


  Begin

    X_Return_Status := OKE_API.G_RET_STS_SUCCESS;


    IF P_DEL_REC.Start_Date IS NOT NULL THEN

      OPEN C (P_DEL_REC.K_Line_ID);
      FETCH C INTO L_Start_Date, L_End_Date;
      CLOSE C;

      IF P_DEL_REC.Start_Date < NVL(L_Start_Date, P_DEL_REC.Start_Date + 1) OR P_DEL_REC.Start_Date > NVL( L_End_Date, P_DEL_REC.Start_Date) OR P_DEL_REC.Start_Date > P_DEL_REC.End_Date THEN

  	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Start_Date');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

       END IF;

     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      NULL; -- Even failed, continue validate other attributes

    WHEN OTHERS THEN

	  -- store SQL error message on message stack
      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					  p_msg_name	=> g_unexpected_error,
					  p_token1	=> g_sqlcode_token,
					  p_token1_value=> sqlcode,
					  p_token2	=> g_sqlerrm_token,
					  p_token2_value=> sqlerrm);
       -- notify caller of an error as UNEXPETED error
      X_Return_Status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End Validate_Start_Date;


  PROCEDURE Validate_End_Date (X_Return_Status OUT NOCOPY   VARCHAR2,
                                 	P_Del_Rec      IN    Del_Rec_Type) IS
    L_Value VARCHAR2(1) := 'N';
    L_Start_Date DATE;
    L_End_Date DATE;

    CURSOR C ( P_ID NUMBER ) IS
    SELECT Start_Date, End_Date
    FROM okc_k_lines_b
    WHERE ID = P_ID;


  Begin

    X_Return_Status := OKE_API.G_RET_STS_SUCCESS;

    IF P_DEL_REC.End_Date IS NOT NULL THEN

      OPEN C ( P_DEL_REC.K_Line_ID );
      FETCH C INTO L_Start_Date, L_End_Date;
      CLOSE C;

      IF P_DEL_REC.End_Date < NVL(L_Start_Date, P_DEL_REC.End_Date + 1) OR P_DEL_REC.End_Date > NVL( L_End_Date, P_DEL_REC.End_Date) OR P_DEL_REC.End_Date < P_DEL_REC.Start_Date THEN

	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'End_Date');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

       END IF;

     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      NULL; -- Even failed, continue validate other attributes

    WHEN OTHERS THEN

	  -- store SQL error message on message stack
      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					  p_msg_name	=> g_unexpected_error,
					  p_token1	=> g_sqlcode_token,
					  p_token1_value=> sqlcode,
					  p_token2	=> g_sqlerrm_token,
					  p_token2_value=> sqlerrm);
       -- notify caller of an error as UNEXPETED error
      X_Return_Status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End Validate_End_Date;

  PROCEDURE Validate_Need_By_Date (X_Return_Status OUT NOCOPY   VARCHAR2,
                                 	P_Del_Rec      IN    Del_Rec_Type) IS
    L_Value VARCHAR2(1) := 'N';
    L_Start_Date DATE;
    L_End_Date DATE;

    CURSOR C ( P_ID NUMBER ) IS
    SELECT Start_Date, End_Date
    FROM okc_k_lines_b
    WHERE ID = P_ID;


  Begin

    X_Return_Status := OKE_API.G_RET_STS_SUCCESS;

    IF P_DEL_REC.Need_By_Date IS NOT NULL THEN

      OPEN C ( P_DEL_REC.K_Line_ID );
      FETCH C INTO L_Start_Date, L_End_Date;
      CLOSE C;

      IF P_DEL_REC.Need_By_Date < NVL(L_Start_Date, P_DEL_REC.Need_By_Date + 1)
	OR P_DEL_REC.Need_By_Date > NVL( L_End_Date, P_DEL_REC.Need_By_Date)
	OR P_DEL_REC.Need_By_Date < NVL(P_DEL_REC.Start_Date, P_DEL_REC.Need_By_Date + 1)
	OR P_DEL_REC.Need_By_Date > NVL(P_DEL_REC.End_Date, P_DEL_REC.Need_By_Date) THEN

	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Need_By_Date');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

       END IF;

     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      NULL; -- Even failed, continue validate other attributes

    WHEN OTHERS THEN

	  -- store SQL error message on message stack
      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					  p_msg_name	=> g_unexpected_error,
					  p_token1	=> g_sqlcode_token,
					  p_token1_value=> sqlcode,
					  p_token2	=> g_sqlerrm_token,
					  p_token2_value=> sqlerrm);
       -- notify caller of an error as UNEXPETED error
      X_Return_Status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End Validate_Need_By_Date;

  PROCEDURE Validate_Currency_Code (X_Return_Status OUT NOCOPY   VARCHAR2,
                                 	P_Del_Rec      IN    Del_Rec_Type) IS
    L_Value VARCHAR2(1) := 'N';

    CURSOR C ( P_CODE VARCHAR2 ) IS
    SELECT 'X'
    FROM fnd_currencies_vl
    WHERE Enabled_Flag = 'Y'
    AND Sysdate BETWEEN NVL(Start_Date_Active, Sysdate)
    AND NVL(End_Date_Active, Sysdate)
    AND Currency_Code = P_CODE;


  Begin

    X_Return_Status := OKE_API.G_RET_STS_SUCCESS;

    IF P_DEL_REC.Currency_Code IS NOT NULL THEN

      OPEN C ( P_DEL_REC.Currency_Code );
      FETCH C INTO L_Value;
      CLOSE C;

      IF L_Value <> 'X' THEN

	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Currency_Code');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

       END IF;

     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      NULL; -- Even failed, continue validate other attributes

    WHEN OTHERS THEN

	  -- store SQL error message on message stack
      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					  p_msg_name	=> g_unexpected_error,
					  p_token1	=> g_sqlcode_token,
					  p_token1_value=> sqlcode,
					  p_token2	=> g_sqlerrm_token,
					  p_token2_value=> sqlerrm);
       -- notify caller of an error as UNEXPETED error
      X_Return_Status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End Validate_Currency_Code;

  PROCEDURE Validate_UOM_Code (X_Return_Status OUT NOCOPY   VARCHAR2,
                                 	P_Del_Rec      IN    Del_Rec_Type) IS
    L_Value VARCHAR2(1) := 'N';

    CURSOR C1 ( P_CODE VARCHAR2, P_ID NUMBER ) IS
    SELECT 'X'
    FROM mtl_item_uoms_view
    WHERE UOM_Code = P_Code
    AND Inventory_Item_ID = P_ID;

    CURSOR C2 ( P_CODE VARCHAR2 ) IS
    SELECT 'X'
    FROM mtl_units_of_measure
    WHERE Sysdate < NVL(Disable_Date, Sysdate + 1)
    AND UOM_Code = P_Code;

  Begin

    X_Return_Status := OKE_API.G_RET_STS_SUCCESS;

    IF P_DEL_REC.UOM_Code IS NOT NULL THEN

      IF P_DEL_REC.Item_ID IS NOT NULL THEN


        OPEN C1 ( P_DEL_REC.UOM_Code, P_DEL_REC.Item_ID );
        FETCH C1 INTO L_Value;
        CLOSE C1;

      ELSE

	OPEN C2 ( P_DEL_REC.UOM_Code );
	FETCH C2 INTO L_Value;
        CLOSE C2;

      END IF;

      IF L_Value <> 'X' THEN

	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'UOM_Code');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

       END IF;

     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      NULL; -- Even failed, continue validate other attributes

    WHEN OTHERS THEN

	  -- store SQL error message on message stack
      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					  p_msg_name	=> g_unexpected_error,
					  p_token1	=> g_sqlcode_token,
					  p_token1_value=> sqlcode,
					  p_token2	=> g_sqlerrm_token,
					  p_token2_value=> sqlerrm);
       -- notify caller of an error as UNEXPETED error
      X_Return_Status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End Validate_UOM_Code;

  PROCEDURE Validate_Shipping_Request_ID (X_Return_Status OUT NOCOPY   VARCHAR2,
                                 	P_Del_Rec      IN    Del_Rec_Type) IS
    L_Value VARCHAR2(1) := 'N';

    CURSOR C ( P_ID NUMBER ) IS
    SELECT 'X'
    FROM wsh_delivery_details
    WHERE Delivery_Detail_ID = P_ID;

  Begin

    X_Return_Status := OKE_API.G_RET_STS_SUCCESS;

    IF P_DEL_REC.Shipping_Request_ID IS NOT NULL THEN


	OPEN C ( P_DEL_REC.Shipping_Request_ID );
	FETCH C INTO L_Value;
        CLOSE C;



      IF L_Value <> 'X' THEN

	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Shipping_Request_ID');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

       END IF;

     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      NULL; -- Even failed, continue validate other attributes

    WHEN OTHERS THEN

	  -- store SQL error message on message stack
      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					  p_msg_name	=> g_unexpected_error,
					  p_token1	=> g_sqlcode_token,
					  p_token1_value=> sqlcode,
					  p_token2	=> g_sqlerrm_token,
					  p_token2_value=> sqlerrm);
       -- notify caller of an error as UNEXPETED error
      X_Return_Status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End Validate_Shipping_Request_ID;


  PROCEDURE Validate_Mps_Transaction_ID (X_Return_Status OUT NOCOPY   VARCHAR2,
                                 	P_Del_Rec      IN    Del_Rec_Type) IS
    L_Value VARCHAR2(1) := 'N';

    CURSOR C ( P_ID NUMBER ) IS
    SELECT 'X'
    FROM mrp_schedule_dates
    WHERE Mps_Transaction_ID = P_ID;

  Begin

    X_Return_Status := OKE_API.G_RET_STS_SUCCESS;

    IF P_DEL_REC.Shipping_Request_ID IS NOT NULL THEN


	OPEN C ( P_DEL_REC.Mps_Transaction_ID );
	FETCH C INTO L_Value;
        CLOSE C;



      IF L_Value <> 'X' THEN

	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Mps_Transaction_ID');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

       END IF;

     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      NULL; -- Even failed, continue validate other attributes

    WHEN OTHERS THEN

	  -- store SQL error message on message stack
      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					  p_msg_name	=> g_unexpected_error,
					  p_token1	=> g_sqlcode_token,
					  p_token1_value=> sqlcode,
					  p_token2	=> g_sqlerrm_token,
					  p_token2_value=> sqlerrm);
       -- notify caller of an error as UNEXPETED error
      X_Return_Status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End Validate_Mps_Transaction_ID;


  PROCEDURE Validate_Unit_Number (X_Return_Status OUT NOCOPY   VARCHAR2,
                                 	P_Del_Rec      IN    Del_Rec_Type) IS
    L_Value VARCHAR2(1) := 'N';

    CURSOR C ( P_Number VARCHAR2 ) IS
    SELECT 'X'
    FROM pjm_unit_numbers_lov_v
    WHERE Unit_Number = P_Number;



  Begin

    X_Return_Status := OKE_API.G_RET_STS_SUCCESS;

    IF P_DEL_REC.Unit_Number IS NOT NULL THEN

	OPEN C ( P_DEL_REC.Unit_Number );
	FETCH C INTO L_Value;
        CLOSE C;



      IF L_Value <> 'X' THEN

	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Unit_Number');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

       END IF;

     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      NULL; -- Even failed, continue validate other attributes

    WHEN OTHERS THEN

	  -- store SQL error message on message stack
      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					  p_msg_name	=> g_unexpected_error,
					  p_token1	=> g_sqlcode_token,
					  p_token1_value=> sqlcode,
					  p_token2	=> g_sqlerrm_token,
					  p_token2_value=> sqlerrm);
       -- notify caller of an error as UNEXPETED error
      X_Return_Status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End Validate_Unit_Number;



  PROCEDURE Validate_Plan_Name (X_Return_Status OUT NOCOPY   VARCHAR2,
                                 	P_Del_Rec      IN    Del_Rec_Type) IS
    L_Value VARCHAR2(1) := 'N';
    L_ID NUMBER;

    CURSOR C ( P_Designator VARCHAR2, P_ID NUMBER ) IS
    SELECT 'X'
    FROM mrp_designators_view
    WHERE Designator_Type = 1
    AND NVL(Disable_Date, TRUNC(Sysdate) + 1) > TRUNC(Sysdate)
    AND Organization_ID = P_ID
    AND Designator = P_Designator;

  Begin

    X_Return_Status := OKE_API.G_RET_STS_SUCCESS;

    IF P_DEL_REC.Ndb_Schedule_Designator IS NOT NULL THEN

      IF P_DEL_REC.Direction = 'OUT' THEN

	IF P_DEL_REC.Ship_From_Org_ID IS NOT NULL THEN

	  L_ID := P_DEL_REC.Ship_From_Org_ID;

	ELSE

	  L_ID := P_DEL_REC.Inventory_Org_ID;

	END IF;

      ELSE

	IF P_DEL_REC.Ship_From_Org_ID IS NOT NULL THEN

	  L_ID := P_DEL_REC.Ship_From_Org_ID;

	ELSE

	  L_ID := P_DEL_REC.Inventory_Org_ID;

	END IF;

      END IF;

      OPEN C ( P_DEL_REC.Ndb_Schedule_Designator, L_ID );
      FETCH C INTO L_Value;
      CLOSE C;



      IF L_Value <> 'X' THEN

	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Ndb_Schedule_Designator');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

       END IF;

     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      NULL; -- Even failed, continue validate other attributes

    WHEN OTHERS THEN

	  -- store SQL error message on message stack
      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					  p_msg_name	=> g_unexpected_error,
					  p_token1	=> g_sqlcode_token,
					  p_token1_value=> sqlcode,
					  p_token2	=> g_sqlerrm_token,
					  p_token2_value=> sqlerrm);
       -- notify caller of an error as UNEXPETED error
      X_Return_Status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End Validate_Plan_Name;

  PROCEDURE Validate_Volume_UOM_Code (X_Return_Status OUT NOCOPY   VARCHAR2,
                                 	P_Del_Rec      IN    Del_Rec_Type) IS
    L_Value VARCHAR2(1) := 'N';
    L_ID NUMBER;

    CURSOR C ( P_Code VARCHAR2, P_ID NUMBER ) IS
    SELECT 'X'
    FROM mtl_units_of_measure uom, wsh_shipping_parameters wsp
    WHERE uom.uom_class = wsp.volume_uom_class
    AND wsp.organization_ID = P_ID
    AND Sysdate < NVL(Disable_Date, Sysdate + 1)
    AND uom.Uom_Code = P_Code;

  Begin

    X_Return_Status := OKE_API.G_RET_STS_SUCCESS;

    IF P_DEL_REC.Volume_UOM_Code IS NOT NULL THEN

      IF P_DEL_REC.Direction = 'OUT' THEN

	IF P_DEL_REC.Ship_From_Org_ID IS NOT NULL THEN

	  L_ID := P_DEL_REC.Ship_From_Org_ID;

	ELSE

	  L_ID := P_DEL_REC.Inventory_Org_ID;

	END IF;

      ELSE

	IF P_DEL_REC.Ship_To_Org_ID IS NOT NULL THEN

	  L_ID := P_DEL_REC.Ship_To_Org_ID;

	ELSE

	  L_ID := P_DEL_REC.Inventory_Org_ID;

	END IF;

      END IF;

	OPEN C ( P_DEL_REC.Volume_UOM_Code, L_ID );
	FETCH C INTO L_Value;
        CLOSE C;



      IF L_Value <> 'X' THEN

	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Volume_Uom_Code');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

       END IF;

     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      NULL; -- Even failed, continue validate other attributes

    WHEN OTHERS THEN

	  -- store SQL error message on message stack
      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					  p_msg_name	=> g_unexpected_error,
					  p_token1	=> g_sqlcode_token,
					  p_token1_value=> sqlcode,
					  p_token2	=> g_sqlerrm_token,
					  p_token2_value=> sqlerrm);
       -- notify caller of an error as UNEXPETED error
      X_Return_Status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End Validate_Volume_UOM_Code;

  PROCEDURE Validate_Weight_UOM_Code (X_Return_Status OUT NOCOPY   VARCHAR2,
                                 	P_Del_Rec      IN    Del_Rec_Type) IS
    L_Value VARCHAR2(1) := 'N';
    L_ID NUMBER;

    CURSOR C ( P_Code VARCHAR2, P_ID NUMBER ) IS
    SELECT 'X'
    FROM mtl_units_of_measure uom, wsh_shipping_parameters wsp
    WHERE uom.uom_class = wsp.weight_uom_class
    AND wsp.organization_ID = P_ID
    AND Sysdate < NVL(Disable_Date, Sysdate + 1)
    AND uom.Uom_Code = P_Code;

  Begin

    X_Return_Status := OKE_API.G_RET_STS_SUCCESS;

    IF P_DEL_REC.Weight_UOM_Code IS NOT NULL THEN

      IF P_DEL_REC.Direction = 'OUT' THEN

	IF P_DEL_REC.Ship_From_Org_ID IS NOT NULL THEN

	  L_ID := P_DEL_REC.Ship_From_Org_ID;

	ELSE

	  L_ID := P_DEL_REC.Inventory_Org_ID;

	END IF;

      ELSE

	IF P_DEL_REC.Ship_To_Org_ID IS NOT NULL THEN

	  L_ID := P_DEL_REC.Ship_To_Org_ID;

	ELSE

	  L_ID := P_DEL_REC.Inventory_Org_ID;

	END IF;

      END IF;

	OPEN C ( P_DEL_REC.Volume_UOM_Code, L_ID );
	FETCH C INTO L_Value;
        CLOSE C;



      IF L_Value <> 'X' THEN

	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Weight_Uom_Code');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

       END IF;

     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      NULL; -- Even failed, continue validate other attributes

    WHEN OTHERS THEN

	  -- store SQL error message on message stack
      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					  p_msg_name	=> g_unexpected_error,
					  p_token1	=> g_sqlcode_token,
					  p_token1_value=> sqlcode,
					  p_token2	=> g_sqlerrm_token,
					  p_token2_value=> sqlerrm);
       -- notify caller of an error as UNEXPETED error
      X_Return_Status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End Validate_Weight_UOM_Code;

  PROCEDURE Validate_Exp_Organization_ID (X_Return_Status OUT NOCOPY   VARCHAR2,
                                 	P_Del_Rec      IN    Del_Rec_Type) IS
    L_Value VARCHAR2(1) := 'N';

    CURSOR C ( P_ID NUMBER ) IS
    SELECT 'X'
    FROM pa_organizations_all_expend_v
    WHERE Active_Flag = 'Y'
    AND TRUNC(Sysdate) BETWEEN Date_From AND NVL(Date_To, TRUNC(Sysdate))
    AND Organization_ID = P_ID;

  Begin

    X_Return_Status := OKE_API.G_RET_STS_SUCCESS;

    IF P_DEL_REC.Expenditure_Organization_ID IS NOT NULL THEN

 	OPEN C ( P_DEL_REC.Expenditure_Organization_ID );
	FETCH C INTO L_Value;
        CLOSE C;



        IF L_Value <> 'X' THEN

	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Expenditure_Organization_ID');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

         END IF;

     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      NULL; -- Even failed, continue validate other attributes

    WHEN OTHERS THEN

	  -- store SQL error message on message stack
      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					  p_msg_name	=> g_unexpected_error,
					  p_token1	=> g_sqlcode_token,
					  p_token1_value=> sqlcode,
					  p_token2	=> g_sqlerrm_token,
					  p_token2_value=> sqlerrm);
       -- notify caller of an error as UNEXPETED error
      X_Return_Status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End Validate_Exp_Organization_ID;

  PROCEDURE Validate_Destination_Type_Code (X_Return_Status OUT NOCOPY   VARCHAR2,
                                 	P_Del_Rec      IN    Del_Rec_Type) IS
    L_Value VARCHAR2(1) := 'N';

    CURSOR C ( P_Code VARCHAR2 ) IS
    SELECT 'X'
    FROM po_lookup_codes
    WHERE Lookup_Type = 'DESTINATION TYPE'
    AND Lookup_Code <> 'SHIP FLOOR'
    AND Lookup_Code = P_Code;

  Begin

    X_Return_Status := OKE_API.G_RET_STS_SUCCESS;

    IF P_DEL_REC.Destination_Type_Code IS NOT NULL THEN

 	OPEN C ( P_DEL_REC.Destination_Type_Code );
	FETCH C INTO L_Value;
        CLOSE C;



        IF L_Value <> 'X' THEN

	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Destination_Type_Code');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

         END IF;

     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      NULL; -- Even failed, continue validate other attributes

    WHEN OTHERS THEN

	  -- store SQL error message on message stack
      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					  p_msg_name	=> g_unexpected_error,
					  p_token1	=> g_sqlcode_token,
					  p_token1_value=> sqlcode,
					  p_token2	=> g_sqlerrm_token,
					  p_token2_value=> sqlerrm);
       -- notify caller of an error as UNEXPETED error
      X_Return_Status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End Validate_Destination_Type_Code;

  PROCEDURE Validate_Exp_Type (X_Return_Status OUT NOCOPY   VARCHAR2,
                                 	P_Del_Rec      IN    Del_Rec_Type) IS
    L_Value VARCHAR2(1) := 'N';

    CURSOR C ( P_ID NUMBER , P_Type VARCHAR2 ) IS
    SELECT 'X'
    FROM pa_expenditure_types_expend_v
    WHERE System_Linkage_Function = 'VI'
    AND ( Project_ID = P_ID OR Project_ID IS NULL )
    AND Expenditure_Type = P_Type;

  Begin

    X_Return_Status := OKE_API.G_RET_STS_SUCCESS;

    IF P_DEL_REC.Expenditure_Type IS NOT NULL THEN

 	OPEN C ( P_DEL_REC.Project_ID, P_DEL_REC.Expenditure_Type );
	FETCH C INTO L_Value;
        CLOSE C;


        IF L_Value <> 'X' THEN

	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Expenditure_Type');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

         END IF;

     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      NULL; -- Even failed, continue validate other attributes

    WHEN OTHERS THEN

	  -- store SQL error message on message stack
      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					  p_msg_name	=> g_unexpected_error,
					  p_token1	=> g_sqlcode_token,
					  p_token1_value=> sqlcode,
					  p_token2	=> g_sqlerrm_token,
					  p_token2_value=> sqlerrm);
       -- notify caller of an error as UNEXPETED error
      X_Return_Status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End Validate_Exp_Type;

  PROCEDURE Validate_Rate_Type (X_Return_Status OUT NOCOPY   VARCHAR2,
                                 	P_Del_Rec      IN    Del_Rec_Type) IS
    L_Value VARCHAR2(1) := 'N';

    CURSOR C ( P_Type VARCHAR2 ) IS
    SELECT 'X'
    FROM gl_daily_conversion_types
    WHERE Conversion_Type = P_Type;

  Begin

    X_Return_Status := OKE_API.G_RET_STS_SUCCESS;

    IF P_DEL_REC.Rate_Type IS NOT NULL THEN

 	OPEN C ( P_DEL_REC.Rate_Type );
	FETCH C INTO L_Value;
        CLOSE C;


        IF L_Value <> 'X' THEN

	  OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Rate_Type');
	   -- notify caller of an error
           X_Return_Status := OKE_API.G_RET_STS_ERROR;

	   -- halt validation
	   RAISE G_EXCEPTION_HALT_VALIDATION;

         END IF;

     END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      NULL; -- Even failed, continue validate other attributes

    WHEN OTHERS THEN

	  -- store SQL error message on message stack
      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					  p_msg_name	=> g_unexpected_error,
					  p_token1	=> g_sqlcode_token,
					  p_token1_value=> sqlcode,
					  p_token2	=> g_sqlerrm_token,
					  p_token2_value=> sqlerrm);
       -- notify caller of an error as UNEXPETED error
      X_Return_Status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End Validate_Rate_Type;

  PROCEDURE Validate_Flag_Values (X_Return_Status OUT NOCOPY   VARCHAR2,
                                 	P_Del_Rec      IN    Del_Rec_Type) IS
  Begin

    X_Return_Status := OKE_API.G_RET_STS_SUCCESS;

    IF P_DEL_REC.Defaulted_Flag IS NOT NULL AND P_DEL_REC.Defaulted_Flag NOT IN ('Y', 'N') THEN

      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Defaulted_Flag');
      -- notify caller of an error
      X_Return_Status := OKE_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    IF P_DEL_REC.In_Process_Flag IS NOT NULL AND P_DEL_REC.In_Process_Flag NOT IN ('Y', 'N') THEN

      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'In_Process_Flag');
      -- notify caller of an error
      X_Return_Status := OKE_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    IF P_DEL_REC.Subcontracted_Flag IS NOT NULL AND P_DEL_REC.Subcontracted_Flag NOT IN ('Y', 'N') THEN

      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Subcontracted_Flag');
      -- notify caller of an error
      X_Return_Status := OKE_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    IF P_DEL_REC.Dependency_Flag IS NOT NULL AND P_DEL_REC.Dependency_Flag NOT IN ('Y', 'N') THEN

      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Dependency_Flag');
      -- notify caller of an error
      X_Return_Status := OKE_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    IF P_DEL_REC.Billable_Flag IS NOT NULL AND P_DEL_REC.Billable_Flag NOT IN ('Y', 'N') THEN

      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Billable_Flag');
      -- notify caller of an error
      X_Return_Status := OKE_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    IF P_DEL_REC.Drop_Shipped_Flag IS NOT NULL AND P_DEL_REC.Drop_Shipped_Flag NOT IN ('Y', 'N') THEN

      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Drop_Shipped_Flag');
      -- notify caller of an error
      X_Return_Status := OKE_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    IF P_DEL_REC.Completed_Flag IS NOT NULL AND P_DEL_REC.Completed_Flag NOT IN ('Y', 'N') THEN

      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Completed_Flag');
      -- notify caller of an error
      X_Return_Status := OKE_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    IF P_DEL_REC.Available_For_Ship_Flag IS NOT NULL AND P_DEL_REC.Available_For_Ship_Flag NOT IN ('Y', 'N') THEN

      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Available_For_Ship_Flag');
      -- notify caller of an error
      X_Return_Status := OKE_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    IF P_DEL_REC.Create_Demand IS NOT NULL AND P_DEL_REC.Create_Demand NOT IN ('Y', 'N') THEN

      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Create_Demand');
      -- notify caller of an error
      X_Return_Status := OKE_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    IF P_DEL_REC.Ready_To_Procure IS NOT NULL AND P_DEL_REC.Ready_To_Procure NOT IN ('Y', 'N') THEN

      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Ready_To_Procure');
      -- notify caller of an error
      X_Return_Status := OKE_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    IF P_DEL_REC.Ready_To_Bill IS NOT NULL AND P_DEL_REC.Ready_To_Bill NOT IN ('Y', 'N') THEN

      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Ready_To_Bill');
      -- notify caller of an error
      X_Return_Status := OKE_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    IF P_DEL_REC.Shippable_Flag IS NOT NULL AND P_DEL_REC.Shippable_Flag NOT IN ('Y', 'N') THEN

      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Shippable_Flag');
      -- notify caller of an error
      X_Return_Status := OKE_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    IF P_DEL_REC.Cfe_Req_Flag IS NOT NULL AND P_DEL_REC.Cfe_Req_Flag NOT IN ('Y', 'N') THEN

      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Cfe_Req_Flag');
      -- notify caller of an error
      X_Return_Status := OKE_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    IF P_DEL_REC.Inspection_Req_Flag IS NOT NULL AND P_DEL_REC.Inspection_Req_Flag NOT IN ('Y', 'N') THEN

      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Inspection_Req_Flag');
      -- notify caller of an error
      X_Return_Status := OKE_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    IF P_DEL_REC.Interim_Rpt_Req_flag IS NOT NULL AND P_DEL_REC.Interim_Rpt_Req_Flag NOT IN ('Y', 'N') THEN

      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Interim_Rpt_Req_Flag');
      -- notify caller of an error
      X_Return_Status := OKE_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    IF P_DEL_REC.Customer_Approval_Req_Flag IS NOT NULL AND P_DEL_REC.Customer_Approval_Req_Flag NOT IN ('Y', 'N') THEN

      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Customer_Approval_Req_Flag');
      -- notify caller of an error
      X_Return_Status := OKE_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

    IF P_DEL_REC.Export_Flag IS NOT NULL AND P_DEL_REC.Export_Flag NOT IN ('Y', 'N') THEN

      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
			p_msg_name	=> g_invalid_value,
                        p_token1	=> g_col_name_token,
		        p_token1_value  => 'Export_Flag');
      -- notify caller of an error
      X_Return_Status := OKE_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;

    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

      NULL; -- Even failed, continue validate other attributes

    WHEN OTHERS THEN

	  -- store SQL error message on message stack
      OKE_API.SET_MESSAGE(p_app_name	=> g_app_name,
					  p_msg_name	=> g_unexpected_error,
					  p_token1	=> g_sqlcode_token,
					  p_token1_value=> sqlcode,
					  p_token2	=> g_sqlerrm_token,
					  p_token2_value=> sqlerrm);
       -- notify caller of an error as UNEXPETED error
      X_Return_Status := OKE_API.G_RET_STS_UNEXP_ERROR;

  End Validate_Flag_Values;

  FUNCTION check_dependency( p_deliverable_id IN Number) RETURN BOOLEAN IS

    CURSOR c IS
    select 'x' from oke_dependencies
    where dependent_id = p_deliverable_id;

    l_result Varchar2(1);
    l_found Boolean := FALSE;

  BEGIN

    open c;
    fetch c into l_result;
    close c;

    if l_result = 'x' then
      l_found := TRUE;
    else
      l_found := FALSE;
    end if;

    return l_found;

  END check_dependency;



  FUNCTION get_rec (
    p_del_rec                      IN del_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN del_rec_type IS

    CURSOR del_pk_csr (p_id                 IN NUMBER) IS
      select b.deliverable_id,
	b.deliverable_num,
	b.project_id,
	b.task_id,
	b.item_id,
	b.k_header_id,
	b.k_line_id,
	b.delivery_date,
	b.status_code,
	b.parent_deliverable_id,
	b.ship_to_org_id,
	b.ship_to_location_id,
        b.ship_from_org_id,
        b.ship_from_location_id,
	b.inventory_org_id,
	b.direction,
	b.defaulted_flag,
	b.in_process_flag,
	b.wf_item_key,
	b.sub_ref_id,
	b.start_date,
	b.end_date,
	b.priority_code,
	b.currency_code,
	b.unit_price,
	b.uom_code,
	b.quantity,
	b.country_of_origin_code,
	b.subcontracted_flag,
	b.dependency_flag,
	b.billable_flag,
	b.billing_event_id,
	b.drop_shipped_flag,
	b.completed_flag,
	b.available_for_ship_flag,
	b.create_demand,
	b.ready_to_bill,
	b.need_by_date,
	b.ready_to_procure,
	b.mps_transaction_id,
	b.po_ref_1,
	b.po_ref_2,
	b.po_ref_3,
	b.shipping_request_id,
	b.unit_number,
	b.ndb_schedule_designator,
	b.shippable_flag,
	b.cfe_req_flag,
	b.inspection_req_flag,
	b.interim_rpt_req_flag,
        b.lot_applies_flag,
	b.customer_approval_req_flag,
	b.expected_shipment_date,
	b.initiate_shipment_date,
        b.promised_shipment_date,
    	b.as_of_date,
 	b.date_of_first_submission,
	b.frequency,
	b.acq_doc_number,
	b.submission_flag,
	b.data_item_subtitle,
	b.total_num_of_copies,
	b.cdrl_category,
	b.data_item_name,
	b.export_flag,
	b.export_license_num,
        b.export_license_res,
        b.created_by,
	b.creation_date,
	b.last_updated_by,
 	b.last_update_login,
	b.last_update_date,
	b.attribute_category,
	b.attribute1,
	b.attribute2,
	b.attribute3,
	b.attribute4,
	b.attribute5,
	b.attribute6,
	b.attribute7,
	b.attribute8,
	b.attribute9,
	b.attribute10,
	b.attribute11,
	b.attribute12,
	b.attribute13,
	b.attribute14,
	b.attribute15,
	t.description,
	t.comments,
	t.sfwt_flag,
        b.weight,
        b.weight_uom_code,
	b.volume,
	b.volume_uom_code,
	b.expenditure_organization_id,
 	b.expenditure_type,
	b.expenditure_item_date,
	b.destination_type_code,
	b.rate_type,
	b.rate_date,
	b.exchange_rate,
	b.requisition_line_type_id,
	b.po_category_id
from oke_k_deliverables_b b, oke_k_deliverables_tl t
where b.deliverable_id = p_id
and t.deliverable_id = p_id
and t.language = userenv('LANG');

    l_del_pk	del_pk_csr%ROWTYPE;
    l_del_rec   del_rec_type;

  BEGIN
    x_no_data_found := TRUE;

    -- get current database value

    OPEN del_pk_csr(p_del_rec.deliverable_id);
    FETCH del_pk_csr INTO  l_del_rec.deliverable_id,
	l_del_rec.deliverable_num,
	l_del_rec.project_id,
	l_del_rec.task_id,
	l_del_rec.item_id,
	l_del_rec.k_header_id,
	l_del_rec.k_line_id,
	l_del_rec.delivery_date,
	l_del_rec.status_code,
	l_del_rec.parent_deliverable_id,
	l_del_rec.ship_to_org_id,
	l_del_rec.ship_to_location_id,
        l_del_rec.ship_from_org_id,
	l_del_rec.ship_from_location_id,
	l_del_rec.inventory_org_id,
	l_del_rec.direction,
	l_del_rec.defaulted_flag,
	l_del_rec.in_process_flag,
	l_del_rec.wf_item_key,
	l_del_rec.sub_ref_id,
	l_del_rec.start_date,
	l_del_rec.end_date,
	l_del_rec.priority_code,
	l_del_rec.currency_code,
	l_del_rec.unit_price,
	l_del_rec.uom_code,
	l_del_rec.quantity,
	l_del_rec.country_of_origin_code,
	l_del_rec.subcontracted_flag,
	l_del_rec.dependency_flag,
	l_del_rec.billable_flag,
	l_del_rec.billing_event_id,
	l_del_rec.drop_shipped_flag,
	l_del_rec.completed_flag,
	l_del_rec.available_for_ship_flag,
	l_del_rec.create_demand,
	l_del_rec.ready_to_bill,
	l_del_rec.need_by_date,
	l_del_rec.ready_to_procure,
	l_del_rec.mps_transaction_id,
	l_del_rec.po_ref_1,
	l_del_rec.po_ref_2,
	l_del_rec.po_ref_3,
	l_del_rec.shipping_request_id,
	l_del_rec.unit_number,
	l_del_rec.ndb_schedule_designator,
	l_del_rec.shippable_flag,
	l_del_rec.cfe_req_flag,
	l_del_rec.inspection_req_flag,
	l_del_rec.interim_rpt_req_flag,
        l_del_rec.lot_applies_flag,
	l_del_rec.customer_approval_req_flag,
	l_del_rec.expected_shipment_date,
	l_del_rec.initiate_shipment_date,
        l_del_rec.promised_shipment_date,
    	l_del_rec.as_of_date,
 	l_del_rec.date_of_first_submission,
	l_del_rec.frequency,
	l_del_rec.acq_doc_number,
	l_del_rec.submission_flag,
	l_del_rec.data_item_subtitle,
	l_del_rec.total_num_of_copies,
	l_del_rec.cdrl_category,
	l_del_rec.data_item_name,
	l_del_rec.export_flag,
	l_del_rec.export_license_num,
        l_del_rec.export_license_res,
        l_del_rec.created_by,
	l_del_rec.creation_date,
	l_del_rec.last_updated_by,
 	l_del_rec.last_update_login,
	l_del_rec.last_update_date,
	l_del_rec.attribute_category,
	l_del_rec.attribute1,
	l_del_rec.attribute2,
	l_del_rec.attribute3,
	l_del_rec.attribute4,
	l_del_rec.attribute5,
	l_del_rec.attribute6,
	l_del_rec.attribute7,
	l_del_rec.attribute8,
	l_del_rec.attribute9,
	l_del_rec.attribute10,
	l_del_rec.attribute11,
	l_del_rec.attribute12,
	l_del_rec.attribute13,
	l_del_rec.attribute14,
	l_del_rec.attribute15,
	l_del_rec.description,
	l_del_rec.comments,
	l_del_rec.sfwt_flag,
        l_del_rec.weight,
	l_del_rec.weight_uom_code,
	l_del_rec.volume,
	l_del_rec.volume_uom_code,
	l_del_rec.expenditure_organization_id,
	l_del_rec.expenditure_type,
	l_del_rec.expenditure_item_date,
	l_del_rec.destination_type_code,
	l_del_rec.rate_type,
	l_del_rec.rate_date,
	l_del_rec.exchange_rate,
	l_del_rec.requisition_line_type_id,
	l_del_rec.po_category_id;

    x_no_data_found := del_pk_csr%NOTFOUND;

    CLOSE del_pk_csr;

    RETURN(l_del_rec);

  END get_rec;

  FUNCTION get_rec (
    p_del_rec	IN del_rec_type)RETURN del_rec_type IS
    l_row_notfound		BOOLEAN := TRUE;

  BEGIN
    RETURN(get_rec(p_del_rec, l_row_notfound));
  END get_rec;

  FUNCTION null_out_defaults(
	 p_del_rec	IN del_rec_type) RETURN del_rec_type IS

  l_del_rec del_rec_type := p_del_rec;

  BEGIN



    IF  l_del_rec.DELIVERABLE_ID = OKE_API.G_MISS_NUM THEN
        l_del_rec.DELIVERABLE_ID := NULL;
    END IF;

    IF  l_del_rec.DELIVERABLE_NUM = OKE_API.G_MISS_CHAR THEN
	l_del_rec.DELIVERABLE_NUM := NULL;
    END IF;

    IF  l_del_rec.PROJECT_ID = OKE_API.G_MISS_NUM THEN
	l_del_rec.PROJECT_ID := NULL;
    END IF;

    IF  l_del_rec.TASK_ID = OKE_API.G_MISS_NUM THEN
      	l_del_rec.TASK_ID := NULL;
    END IF;

    IF	l_del_rec.ITEM_ID = OKE_API.G_MISS_NUM THEN
        l_del_rec.ITEM_ID := NULL;
    END IF;

    IF	l_del_rec.K_HEADER_ID = OKE_API.G_MISS_NUM THEN
        l_del_rec.K_HEADER_ID := NULL;
    END IF;

    IF	l_del_rec.K_LINE_ID = OKE_API.G_MISS_NUM THEN
	l_del_rec.K_LINE_ID := NULL;
    END IF;

    IF	l_del_rec.DELIVERY_DATE = OKE_API.G_MISS_DATE THEN
	l_del_rec.DELIVERY_DATE := NULL;
    END IF;

    IF  l_del_rec.STATUS_CODE = OKE_API.G_MISS_CHAR THEN
	l_del_rec.STATUS_CODE	:= NULL;
    END IF;

    IF	l_del_rec.PARENT_DELIVERABLE_ID = OKE_API.G_MISS_NUM THEN
	l_del_rec.PARENT_DELIVERABLE_ID := NULL;
    END IF;

    IF	l_del_rec.SHIP_TO_ORG_ID = OKE_API.G_MISS_NUM THEN
	l_del_rec.SHIP_TO_ORG_ID := NULL;
    END IF;

    IF	l_del_rec.SHIP_TO_LOCATION_ID = OKE_API.G_MISS_NUM THEN
	l_del_rec.SHIP_TO_LOCATION_ID := NULL;
    END IF;

    IF	l_del_rec.SHIP_FROM_ORG_ID = OKE_API.G_MISS_NUM THEN
	l_del_rec.SHIP_FROM_ORG_ID := NULL;
    END IF;

    IF	l_del_rec.SHIP_FROM_LOCATION_ID = OKE_API.G_MISS_NUM THEN
	l_del_rec.SHIP_FROM_LOCATION_ID := NULL;
    END IF;

    IF	l_del_rec.INVENTORY_ORG_ID = OKE_API.G_MISS_NUM THEN
	l_del_rec.INVENTORY_ORG_ID := NULL;
    END IF;

    IF	l_del_rec.DIRECTION = OKE_API.G_MISS_CHAR THEN
	l_del_rec.DIRECTION := NULL;
    END IF;

    IF	l_del_rec.DEFAULTED_FLAG = OKE_API.G_MISS_CHAR THEN
	l_del_rec.DEFAULTED_FLAG := NULL;
    END IF;

    IF	l_del_rec.IN_PROCESS_FLAG = OKE_API.G_MISS_CHAR THEN
	l_del_rec.IN_PROCESS_FLAG := NULL;
    END IF;

    IF	l_del_rec.WF_ITEM_KEY = OKE_API.G_MISS_CHAR THEN
	l_del_rec.WF_ITEM_KEY := NULL;
    END IF;

    IF	l_del_rec.SUB_REF_ID = OKE_API.G_MISS_NUM THEN
        l_del_rec.SUB_REF_ID := NULL;
    END IF;

    IF	l_del_rec.START_DATE	= OKE_API.G_MISS_DATE THEN
        l_del_rec.START_DATE	:= NULL;
    END IF;

    IF	l_del_rec.END_DATE	= OKE_API.G_MISS_DATE THEN
        l_del_rec.END_DATE	:= NULL;
    END IF;

    IF	l_del_rec.PRIORITY_CODE	= OKE_API.G_MISS_CHAR THEN
        l_del_rec.PRIORITY_CODE := NULL;
    END IF;

    IF	l_del_rec.CURRENCY_CODE	= OKE_API.G_MISS_CHAR THEN
        l_del_rec.CURRENCY_CODE	:= NULL;
    END IF;

    IF	l_del_rec.UNIT_PRICE = OKE_API.G_MISS_NUM THEN
	l_del_rec.UNIT_PRICE := NULL;
    END IF;

    IF	l_del_rec.UOM_CODE = OKE_API.G_MISS_CHAR THEN
	l_del_rec.UOM_CODE := NULL;
    END IF;

    IF	l_del_rec.QUANTITY = OKE_API.G_MISS_NUM THEN
	l_del_rec.QUANTITY := NULL;
    END IF;

    IF  l_del_rec.COUNTRY_OF_ORIGIN_CODE = OKE_API.G_MISS_CHAR THEN
	l_del_rec.COUNTRY_OF_ORIGIN_CODE := NULL;
    END IF;

    IF	l_del_rec.SUBCONTRACTED_FLAG = OKE_API.G_MISS_CHAR THEN
	l_del_rec.SUBCONTRACTED_FLAG := NULL;
    END IF;

    IF	l_del_rec.DEPENDENCY_FLAG = OKE_API.G_MISS_CHAR THEN
	l_del_rec.DEPENDENCY_FLAG := NULL;
    END IF;



    IF	l_del_rec.BILLABLE_FLAG	= OKE_API.G_MISS_CHAR THEN
	l_del_rec.BILLABLE_FLAG	:= NULL;
    END IF;

    IF	l_del_rec.BILLING_EVENT_ID = OKE_API.G_MISS_NUM THEN
	l_del_rec.BILLING_EVENT_ID := NULL;
    END IF;

    IF	l_del_rec.DROP_SHIPPED_FLAG = OKE_API.G_MISS_CHAR THEN
        l_del_rec.DROP_SHIPPED_FLAG := NULL;
    END IF;

    IF	l_del_rec.COMPLETED_FLAG = OKE_API.G_MISS_CHAR THEN
	l_del_rec.COMPLETED_FLAG := NULL;
    END IF;

    IF	l_del_rec.AVAILABLE_FOR_SHIP_FLAG = OKE_API.G_MISS_CHAR THEN
	l_del_rec.AVAILABLE_FOR_SHIP_FLAG := NULL;
    END IF;

    IF	l_del_rec.CREATE_DEMAND = OKE_API.G_MISS_CHAR THEN
	l_del_rec.CREATE_DEMAND := NULL;
    END IF;

    IF	l_del_rec.READY_TO_BILL = OKE_API.G_MISS_CHAR THEN
	l_del_rec.READY_TO_BILL := NULL;
    END IF;

    IF	l_del_rec.NEED_BY_DATE = OKE_API.G_MISS_DATE THEN
	l_del_rec.NEED_BY_DATE := NULL;
    END IF;

    IF	l_del_rec.READY_TO_PROCURE = OKE_API.G_MISS_CHAR THEN
	l_del_rec.READY_TO_PROCURE := NULL;
    END IF;

    IF	l_del_rec.MPS_TRANSACTION_ID = OKE_API.G_MISS_NUM THEN
	l_del_rec.MPS_TRANSACTION_ID := NULL;
    END IF;

    IF	l_del_rec.PO_REF_1 = OKE_API.G_MISS_NUM THEN
	l_del_rec.PO_REF_1 := NULL;
    END IF;

    IF	l_del_rec.PO_REF_2 = OKE_API.G_MISS_NUM THEN
	l_del_rec.PO_REF_2 := NULL;
    END IF;

    IF	l_del_rec.PO_REF_3 = OKE_API.G_MISS_NUM THEN
	l_del_rec.PO_REF_3 := NULL;
    END IF;

    IF	l_del_rec.SHIPPING_REQUEST_ID = OKE_API.G_MISS_NUM THEN
	l_del_rec.SHIPPING_REQUEST_ID := NULL;
    END IF;

    IF	l_del_rec.UNIT_NUMBER = OKE_API.G_MISS_CHAR THEN
	l_del_rec.UNIT_NUMBER := NULL;
    END IF;

    IF	l_del_rec.NDB_SCHEDULE_DESIGNATOR = OKE_API.G_MISS_CHAR THEN
	l_del_rec.NDB_SCHEDULE_DESIGNATOR := NULL;
    END IF;

    IF	l_del_rec.SHIPPABLE_FLAG = OKE_API.G_MISS_CHAR THEN
	l_del_rec.SHIPPABLE_FLAG := NULL;
    END IF;

    IF	l_del_rec.CFE_REQ_FLAG = OKE_API.G_MISS_CHAR THEN
	l_del_rec.CFE_REQ_FLAG := NULL;
    END IF;

    IF	l_del_rec.INSPECTION_REQ_FLAG = OKE_API.G_MISS_CHAR THEN
	l_del_rec.INSPECTION_REQ_FLAG := NULL;
    END IF;

    IF	l_del_rec.INTERIM_RPT_REQ_FLAG = OKE_API.G_MISS_CHAR THEN
	l_del_rec.INTERIM_RPT_REQ_FLAG := NULL;
    END IF;

    IF	l_del_rec.LOT_APPLIES_FLAG = OKE_API.G_MISS_CHAR THEN
	l_del_rec.LOT_APPLIES_FLAG := NULL;
    END IF;

    IF	l_del_rec.CUSTOMER_APPROVAL_REQ_FLAG = OKE_API.G_MISS_CHAR THEN
	l_del_rec.CUSTOMER_APPROVAL_REQ_FLAG := NULL;
    END IF;

    IF	l_del_rec.EXPECTED_SHIPMENT_DATE = OKE_API.G_MISS_DATE THEN
	l_del_rec.EXPECTED_SHIPMENT_DATE := NULL;
    END IF;

    IF	l_del_rec.INITIATE_SHIPMENT_DATE = OKE_API.G_MISS_DATE THEN
	l_del_rec.INITIATE_SHIPMENT_DATE := NULL;
    END IF;

    IF	l_del_rec.PROMISED_SHIPMENT_DATE = OKE_API.G_MISS_DATE THEN
	l_del_rec.PROMISED_SHIPMENT_DATE := NULL;
    END IF;

    IF	l_del_rec.AS_OF_DATE = OKE_API.G_MISS_DATE THEN
	l_del_rec.AS_OF_DATE := NULL;
    END IF;

    IF	l_del_rec.DATE_OF_FIRST_SUBMISSION = OKE_API.G_MISS_DATE THEN
	l_del_rec.DATE_OF_FIRST_SUBMISSION := NULL;
    END IF;

    IF	l_del_rec.FREQUENCY = OKE_API.G_MISS_CHAR THEN
	l_del_rec.FREQUENCY := NULL;
    END IF;

    IF	l_del_rec.ACQ_DOC_NUMBER = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ACQ_DOC_NUMBER := NULL;
    END IF;

    IF	l_del_rec.SUBMISSION_FLAG = OKE_API.G_MISS_CHAR THEN
	l_del_rec.SUBMISSION_FLAG := NULL;
    END IF;

    IF	l_del_rec.DATA_ITEM_NAME = OKE_API.G_MISS_CHAR THEN
	l_del_rec.DATA_ITEM_NAME := NULL;
    END IF;

    IF	l_del_rec.DATA_ITEM_SUBTITLE = OKE_API.G_MISS_CHAR THEN
	l_del_rec.DATA_ITEM_SUBTITLE := NULL;
    END IF;

    IF	l_del_rec.TOTAL_NUM_OF_COPIES = OKE_API.G_MISS_NUM THEN
	l_del_rec.TOTAL_NUM_OF_COPIES := NULL;
    END IF;

    IF	l_del_rec.CDRL_CATEGORY = OKE_API.G_MISS_CHAR THEN
	l_del_rec.CDRL_CATEGORY := NULL;
    END IF;

    IF	l_del_rec.EXPORT_LICENSE_NUM = OKE_API.G_MISS_CHAR THEN
   	l_del_rec.EXPORT_LICENSE_NUM := NULL;
    END IF;

    IF	l_del_rec.EXPORT_LICENSE_RES = OKE_API.G_MISS_CHAR THEN
	l_del_rec.EXPORT_LICENSE_RES := NULL;
    END IF;

    IF	l_del_rec.EXPORT_FLAG = OKE_API.G_MISS_CHAR THEN
	l_del_rec.EXPORT_FLAG := NULL;
    END IF;

    IF	l_del_rec.CREATED_BY = OKE_API.G_MISS_NUM THEN
	l_del_rec.CREATED_BY := NULL;
    END IF;

    IF	l_del_rec.CREATION_DATE = OKE_API.G_MISS_DATE THEN
	l_del_rec.CREATION_DATE := NULL;
    END IF;

    IF	l_del_rec.LAST_UPDATED_BY = OKE_API.G_MISS_NUM THEN
	l_del_rec.LAST_UPDATED_BY := NULL;
    END IF;

    IF	l_del_rec.LAST_UPDATE_LOGIN = OKE_API.G_MISS_NUM THEN
	l_del_rec.LAST_UPDATE_LOGIN := NULL;
    END IF;

    IF	l_del_rec.LAST_UPDATE_DATE = OKE_API.G_MISS_DATE THEN
	l_del_rec.LAST_UPDATE_DATE := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE_CATEGORY = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE_CATEGORY := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE1 = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE1 := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE2 = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE2 := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE3 = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE3 := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE4 = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE4 := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE5 = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE5 := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE6 = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE6 := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE7 = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE7 := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE8 = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE8 := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE9 = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE9 := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE10 = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE10 := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE11 = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE11 := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE12 = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE12 := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE13 = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE13 := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE14 = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE14 := NULL;
    END IF;

    IF	l_del_rec.ATTRIBUTE15 = OKE_API.G_MISS_CHAR THEN
	l_del_rec.ATTRIBUTE15 := NULL;
    END IF;



    IF l_del_rec.comments = OKE_API.G_MISS_CHAR THEN

       l_del_rec.comments := NULL;
    END IF;

    IF l_del_rec.weight = OKE_API.G_MISS_NUM THEN
       l_del_rec.weight := NULL;
    END IF;

    IF l_del_rec.weight_uom_code = OKE_API.G_MISS_CHAR THEN
       l_del_rec.weight_uom_code := NULL;
    END IF;

    IF l_del_rec.volume = OKE_API.G_MISS_NUM THEN
       l_del_rec.volume := NULL;
    END IF;

    IF l_del_rec.volume_uom_code = OKE_API.G_MISS_CHAR THEN
       l_del_rec.volume_uom_code := NULL;
    END IF;

    IF l_del_rec.expenditure_organization_id = OKE_API.G_MISS_NUM THEN
       l_del_rec.expenditure_organization_id := NULL;
    END IF;

    IF l_del_rec.expenditure_type = OKE_API.G_MISS_CHAR THEN
       l_del_rec.expenditure_type := NULL;
    END IF;

    IF l_del_rec.expenditure_item_date = OKE_API.G_MISS_DATE THEN
       l_del_rec.expenditure_item_date := NULL;
    END IF;

    IF l_del_rec.destination_type_code = OKE_API.G_MISS_CHAR THEN
       l_del_rec.destination_type_code := NULL;
    END IF;

    IF l_del_rec.rate_type = OKE_API.G_MISS_CHAR THEN
       l_del_rec.rate_type := NULL;
    END IF;

    IF l_del_rec.rate_date = OKE_API.G_MISS_DATE THEN
       l_del_rec.rate_date := NULL;
    END IF;

    IF l_del_rec.exchange_rate = OKE_API.G_MISS_NUM THEN
       l_del_rec.exchange_rate := NULL;
    END IF;

    IF l_del_rec.description = OKE_API.G_MISS_CHAR THEN
       l_del_rec.description := NULL;
    END IF;

    IF l_del_rec.requisition_line_type_id = OKE_API.G_MISS_NUM THEN
       l_del_rec.requisition_line_type_id := NULL;
    END IF;

   IF l_del_rec.po_category_id = OKE_API.G_MISS_NUM THEN
       l_del_rec.po_category_id := NULL;
    END IF;

    RETURN(l_del_rec);

  END null_out_defaults;

-- validate attributes

  FUNCTION validate_attributes(
    p_del_rec IN  del_rec_type                                                  ) RETURN VARCHAR2 IS

    l_return_status	VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    x_return_status VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;

  BEGIN
    /* call individual validation procedure */


    Validate_Header_ID(
        x_return_status	=> l_return_status,
     	p_del_rec 	=> p_del_rec);



    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
      If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
      End If;
    End If;


    Validate_Line_ID(
        x_return_status	=> l_return_status,
     	p_del_rec 	=> p_del_rec);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
      If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
      End If;
    End If;

    Validate_Deliverable_Number(
        x_return_status	=> l_return_status,
     	p_del_rec 	=> p_del_rec);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
      If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
      End If;
    End If;



    Validate_Project_ID(
        x_return_status	=> l_return_status,
     	p_del_rec 	=> p_del_rec);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
      If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
      End If;
    End If;

    Validate_Task_ID(
        x_return_status	=> l_return_status,
     	p_del_rec 	=> p_del_rec);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
      If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
      End If;
    End If;

    Validate_Inventory_Org_ID(
        x_return_status	=> l_return_status,
     	p_del_rec 	=> p_del_rec);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
      If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
      End If;
    End If;

    Validate_Item_ID(
        x_return_status	=> l_return_status,
     	p_del_rec 	=> p_del_rec);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
      If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
      End If;
    End If;

    Validate_Delivery_Date(
        x_return_status	=> l_return_status,
     	p_del_rec 	=> p_del_rec);


    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
      If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
      End If;
    End If;

    Validate_Direction(
        x_return_status	=> l_return_status,
     	p_del_rec 	=> p_del_rec);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
      If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
      End If;
    End If;

    Validate_Ship_To_Org_ID(
        x_return_status	=> l_return_status,
     	p_del_rec 	=> p_del_rec);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
      If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
      End If;
    End If;

    Validate_Ship_From_Org_ID(
        x_return_status	=> l_return_status,
     	p_del_rec 	=> p_del_rec);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
      If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
      End If;
    End If;

    Validate_Ship_To_Location_ID(
        x_return_status	=> l_return_status,
     	p_del_rec 	=> p_del_rec);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
      If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
      End If;
    End If;

    Validate_Ship_From_Location_ID(
        x_return_status	=> l_return_status,
     	p_del_rec 	=> p_del_rec);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
      If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
      End If;
    End If;

    Validate_In_Process_Flag(
        x_return_status	=> l_return_status,
     	p_del_rec 	=> p_del_rec);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
      If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
      End If;
    End If;

    Validate_Start_Date(
        x_return_status	=> l_return_status,
     	p_del_rec 	=> p_del_rec);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
      If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
      End If;
    End If;

    Validate_End_Date(
        x_return_status	=> l_return_status,
     	p_del_rec 	=> p_del_rec);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
      If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
      End If;
    End If;

    Validate_Need_By_Date(
        x_return_status	=> l_return_status,
     	p_del_rec 	=> p_del_rec);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
      If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
      End If;
    End If;

    Validate_Currency_Code(
        x_return_status	=> l_return_status,
     	p_del_rec 	=> p_del_rec);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
      If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
      End If;
    End If;

    Validate_UOM_Code(
        x_return_status	=> l_return_status,
     	p_del_rec 	=> p_del_rec);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
      If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
      End If;
    End If;

    Validate_Shipping_Request_ID(
        x_return_status	=> l_return_status,
     	p_del_rec 	=> p_del_rec);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
      If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
      End If;
    End If;

    Validate_Mps_Transaction_ID(
        x_return_status	=> l_return_status,
     	p_del_rec 	=> p_del_rec);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
      If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
      End If;
    End If;

    Validate_Unit_Number(
        x_return_status	=> l_return_status,
     	p_del_rec 	=> p_del_rec);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
      If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
      End If;
    End If;

    Validate_Plan_Name(
        x_return_status	=> l_return_status,
     	p_del_rec 	=> p_del_rec);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
      If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
      End If;
    End If;

    Validate_Volume_UOM_Code(
        x_return_status	=> l_return_status,
     	p_del_rec 	=> p_del_rec);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
      If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
      End If;
    End If;

    Validate_Weight_UOM_Code(
        x_return_status	=> l_return_status,
     	p_del_rec 	=> p_del_rec);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
      If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
      End If;
    End If;

    Validate_Exp_Organization_ID(
        x_return_status	=> l_return_status,
     	p_del_rec 	=> p_del_rec);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
      If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
      End If;
    End If;

    Validate_Destination_Type_Code(
        x_return_status	=> l_return_status,
     	p_del_rec 	=> p_del_rec);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
      If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
      End If;
    End If;

    Validate_Exp_Type(
        x_return_status	=> l_return_status,
     	p_del_rec 	=> p_del_rec);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
      If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
      End If;
    End If;

    Validate_Rate_Type(
        x_return_status	=> l_return_status,
     	p_del_rec 	=> p_del_rec);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
      If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
      End If;
    End If;

    Validate_Flag_Values(
        x_return_status	=> l_return_status,
     	p_del_rec 	=> p_del_rec);

    If l_return_status <> OKE_API.G_RET_STS_SUCCESS Then
      If x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
  	     x_return_status := l_return_status;
      End If;
    End If;

    return (x_return_status);

  exception
    when OTHERS then
	  -- store SQL error message on message stack
  	  OKE_API.SET_MESSAGE(p_app_name		=> g_app_name,
			      p_msg_name		=> g_unexpected_error,
			      p_token1		=> g_sqlcode_token,
			      p_token1_value	=> sqlcode,
			      p_token2		=> g_sqlerrm_token,
			      p_token2_value	=> sqlerrm);

	   -- notify caller of an UNEXPETED error
	   x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

	   -- return status to caller
        RETURN(x_return_status);

  END Validate_Attributes;

-- validate record

  FUNCTION validate_record (
    p_del_rec IN del_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
  BEGIN

    RETURN(l_return_status);

  END validate_record;

-- validate row

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_rec                      IN del_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_validate_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_del_rec                      del_rec_type := p_del_rec;

  BEGIN
    l_return_status := OKE_API.START_ACTIVITY(l_api_name,
					      G_PKG_NAME,
					      p_init_msg_list,
					      l_api_version,
					      p_api_version,
					      '_PVT',
					      x_return_status);
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_del_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_del_rec);

    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;
    OKE_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2  ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_tbl                      IN del_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TBL_validate_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKE_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_del_tbl.COUNT > 0) THEN
      i := p_del_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_del_rec                     => p_del_tbl(i));

		-- store the highest degree of error
	If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	  If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
	     l_overall_status := x_return_status;
	  End If;
	End If;

        EXIT WHEN (i = p_del_tbl.LAST);
        i := p_del_tbl.NEXT(i);
      END LOOP;
	 -- return overall status
	 x_return_status := l_overall_status;
    END IF;

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;

-- insert data into oke_k_deliverables_b/tl

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2  ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_rec                      IN del_rec_type,
    x_del_rec                      OUT NOCOPY del_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_del_rec                      del_rec_type;
    l_def_del_rec                  del_rec_type;
    lx_del_rec                     del_rec_type;

    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_del_rec	IN del_rec_type
    ) RETURN del_rec_type IS

      l_del_rec	del_rec_type := p_del_rec;

    BEGIN

      l_del_rec.CREATION_DATE := SYSDATE;
      l_del_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_del_rec.LAST_UPDATE_DATE := SYSDATE;
      l_del_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_del_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_del_rec);

    END fill_who_columns;

    -- Set_Attributes for:OKE_K_DELIVERABLES_B

    FUNCTION Set_Attributes (
      p_del_rec IN  del_rec_type,
      x_del_rec OUT NOCOPY del_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
      cursor l_csr is
      select oke_k_deliverables_s.nextval from dual;

    BEGIN

      x_del_rec := p_del_rec;

      -- get id
      open l_csr;
      fetch l_csr into x_del_rec.deliverable_id;
      close l_csr;

      x_del_rec.BILLABLE_FLAG		:= UPPER(x_del_rec.BILLABLE_FLAG);
      x_del_rec.SHIPPABLE_FLAG		:= UPPER(x_del_rec.SHIPPABLE_FLAG);
      x_del_rec.SUBCONTRACTED_FLAG	 := UPPER(x_del_rec.SUBCONTRACTED_FLAG);

      x_del_rec.COMPLETED_FLAG		:= UPPER(x_del_rec.COMPLETED_FLAG);

      x_del_rec.DROP_SHIPPED_FLAG	:= UPPER(x_del_rec.DROP_SHIPPED_FLAG);

      x_del_rec.CUSTOMER_APPROVAL_REQ_FLAG := UPPER(x_del_rec.CUSTOMER_APPROVAL_REQ_FLAG);

      x_del_rec.INSPECTION_REQ_FLAG	:= UPPER(x_del_rec.INSPECTION_REQ_FLAG);

      x_del_rec.INTERIM_RPT_REQ_FLAG	:= UPPER(x_del_rec.INTERIM_RPT_REQ_FLAG);

      x_del_rec.EXPORT_FLAG	:= UPPER(x_del_rec.EXPORT_FLAG);

      x_del_rec.CFE_REQ_FLAG	:= UPPER(x_del_rec.CFE_REQ_FLAG);

      x_del_rec.DEFAULTED_FLAG := UPPER(x_del_rec.DEFAULTED_FLAG);

      x_del_rec.IN_PROCESS_FLAG := UPPER(x_del_rec.IN_PROCESS_FLAG);

      RETURN(l_return_status);

    END Set_Attributes;

  BEGIN


    l_return_status := OKE_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);

    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;


    l_del_rec := null_out_defaults(p_del_rec);



    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_del_rec,                        -- IN
      l_def_del_rec);                   -- OUT

    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;



    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    l_def_del_rec := fill_who_columns(l_def_del_rec);



/*    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_del_rec);

    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;



    l_return_status := Validate_Record(l_def_del_rec);

    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;  */

    -- get deliverable number

    if l_def_del_rec.deliverable_num is null then

       l_def_del_rec.deliverable_num := OKE_NUMBER_SEQUENCES_PKG.Next_Deliverable_Number(
							l_def_del_rec.k_header_id
							, l_def_del_rec.k_line_id);

    end if;


    INSERT INTO OKE_K_DELIVERABLES_B(
 	deliverable_id,
	deliverable_num,
	project_id,
	task_id,
	item_id,
	k_header_id,
	k_line_id,
	delivery_date,
	status_code,
	status_date,
	parent_deliverable_id,
	ship_to_org_id,
	ship_to_location_id,
	ship_from_org_id,
	ship_from_location_id,
	inventory_org_id,
	direction,
	defaulted_flag,
	in_process_flag,
	wf_item_key,
	sub_ref_id,
	start_date,
	end_date,
	priority_code,
	currency_code,
	unit_price,
	uom_code,
	quantity,
	country_of_origin_code,
	subcontracted_flag,
	dependency_flag,
	billable_flag,
	billing_event_id,
	drop_shipped_flag,
	completed_flag,
	available_for_ship_flag,
	create_demand,
	ready_to_bill,
	need_by_date,
	ready_to_procure,
	mps_transaction_id,
	po_ref_1,
	po_ref_2,
	po_ref_3,
	shipping_request_id,
	unit_number,
	ndb_schedule_designator,
	shippable_flag,
	cfe_req_flag,
	inspection_req_flag,
	interim_rpt_req_flag,
        lot_applies_flag,
	customer_approval_req_flag,
	expected_shipment_date,
	initiate_shipment_date,
        promised_shipment_date,
    	as_of_date,
 	date_of_first_submission,
	frequency,
	acq_doc_number,
	submission_flag,
	data_item_subtitle,
	total_num_of_copies,
	cdrl_category,
	data_item_name,
	export_flag,
	export_license_num,
        export_license_res,
        created_by,
	creation_date,
	last_updated_by,
 	last_update_login,
	last_update_date,
	attribute_category,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15,
        weight,
 	weight_uom_code,
	volume,
	volume_uom_code,
	expenditure_organization_id,
	expenditure_type,
	expenditure_item_date,
	destination_type_code,
	rate_type,
	rate_date,
	exchange_rate,
	requisition_line_type_id,
	po_category_id)
    VALUES(
        l_def_del_rec.deliverable_id,
	l_def_del_rec.deliverable_num,
	l_def_del_rec.project_id,
	l_def_del_rec.task_id,
	l_def_del_rec.item_id,
	l_def_del_rec.k_header_id,
	l_def_del_rec.k_line_id,
	l_def_del_rec.delivery_date,
	l_def_del_rec.status_code,
	sysdate,
	l_def_del_rec.parent_deliverable_id,
	l_def_del_rec.ship_to_org_id,
	l_def_del_rec.ship_to_location_id,
	l_def_del_rec.ship_from_org_id,
	l_def_del_rec.ship_from_location_id,
	l_def_del_rec.inventory_org_id,
	l_def_del_rec.direction,
	l_def_del_rec.defaulted_flag,
	l_def_del_rec.in_process_flag,
	l_def_del_rec.wf_item_key,
	l_def_del_rec.sub_ref_id,
	l_def_del_rec.start_date,
	l_def_del_rec.end_date,
	l_def_del_rec.priority_code,
	l_def_del_rec.currency_code,
	l_def_del_rec.unit_price,
	l_def_del_rec.uom_code,
	l_def_del_rec.quantity,
	l_def_del_rec.country_of_origin_code,
	l_def_del_rec.subcontracted_flag,
	l_def_del_rec.dependency_flag,
	l_def_del_rec.billable_flag,
	l_def_del_rec.billing_event_id,
	l_def_del_rec.drop_shipped_flag,
	l_def_del_rec.completed_flag,
	l_def_del_rec.available_for_ship_flag,
	l_def_del_rec.create_demand,
	l_def_del_rec.ready_to_bill,
	l_def_del_rec.need_by_date,
	l_def_del_rec.ready_to_procure,
	l_def_del_rec.mps_transaction_id,
	l_def_del_rec.po_ref_1,
	l_def_del_rec.po_ref_2,
	l_def_del_rec.po_ref_3,
	l_def_del_rec.shipping_request_id,
	l_def_del_rec.unit_number,
	l_def_del_rec.ndb_schedule_designator,
	l_def_del_rec.shippable_flag,
	l_def_del_rec.cfe_req_flag,
	l_def_del_rec.inspection_req_flag,
	l_def_del_rec.interim_rpt_req_flag,
        l_def_del_rec.lot_applies_flag,
	l_def_del_rec.customer_approval_req_flag,
	l_def_del_rec.expected_shipment_date,
	l_def_del_rec.initiate_shipment_date,
        l_def_del_rec.promised_shipment_date,
    	l_def_del_rec.as_of_date,
 	l_def_del_rec.date_of_first_submission,
	l_def_del_rec.frequency,
	l_def_del_rec.acq_doc_number,
	l_def_del_rec.submission_flag,
	l_def_del_rec.data_item_subtitle,
	l_def_del_rec.total_num_of_copies,
	l_def_del_rec.cdrl_category,
	l_def_del_rec.data_item_name,
	l_def_del_rec.export_flag,
	l_def_del_rec.export_license_num,
        l_def_del_rec.export_license_res,
        l_def_del_rec.created_by,
	l_def_del_rec.creation_date,
	l_def_del_rec.last_updated_by,
 	l_def_del_rec.last_update_login,
	l_def_del_rec.last_update_date,
	l_def_del_rec.attribute_category,
	l_def_del_rec.attribute1,
	l_def_del_rec.attribute2,
	l_def_del_rec.attribute3,
	l_def_del_rec.attribute4,
	l_def_del_rec.attribute5,
	l_def_del_rec.attribute6,
	l_def_del_rec.attribute7,
	l_def_del_rec.attribute8,
	l_def_del_rec.attribute9,
	l_def_del_rec.attribute10,
	l_def_del_rec.attribute11,
	l_def_del_rec.attribute12,
	l_def_del_rec.attribute13,
	l_def_del_rec.attribute14,
	l_def_del_rec.attribute15,
	l_def_del_rec.weight,
	l_def_del_rec.weight_uom_code,
	l_def_del_rec.volume,
	l_def_del_rec.volume_uom_code,
	l_def_del_rec.expenditure_organization_id,
	l_def_del_rec.expenditure_type,
	l_def_del_rec.expenditure_item_date,
	l_def_del_rec.destination_type_code,
	l_def_del_rec.rate_type,
	l_def_del_rec.rate_date,
	l_def_del_rec.exchange_rate,
	l_def_del_rec.requisition_line_type_id,
	l_def_del_rec.po_category_id);

    -- insert into TL table

    insert into OKE_K_DELIVERABLES_TL(
	deliverable_id,
	language,
	creation_date,
	created_by,
	last_updated_by,
	last_update_login,
	last_update_date,
	k_header_id,
	k_line_id,
	source_lang,
	sfwt_flag,
	description,
	comments)
    select
	l_def_del_rec.deliverable_id,
	l.language_code,
	l_def_del_rec.creation_date,
        l_def_del_rec.created_by,
	l_def_del_rec.last_updated_by,
 	l_def_del_rec.last_update_login,
	l_def_del_rec.last_update_date,
        l_def_del_rec.k_header_id,
	l_def_del_rec.k_line_id,
	okc_util.get_userenv_lang,
	'NO',
	l_def_del_rec.description,
	l_def_del_rec.comments
    from FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I', 'B')
    and not exists
      (select NULL
      from OKE_K_DELIVERABLES_TL T
      where T.DELIVERABLE_ID = l_def_del_rec.deliverable_id
      and T.LANGUAGE = L.LANGUAGE_CODE);



    -- Set OUT values
    x_del_rec := l_def_del_rec;
    OKE_API.END_ACTIVITY(x_msg_count, x_msg_data);


  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2  ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_tbl                      IN del_tbl_type,
    x_del_tbl                      OUT NOCOPY del_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TBL_insert_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    OKE_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'called pvt insert_row');
 END IF;
    IF (p_del_tbl.COUNT > 0) THEN
      i := p_del_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,

          p_del_rec                      => p_del_tbl(i),
          x_del_rec                      => x_del_tbl(i));

		-- store the highest degree of error
	 If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	   If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
	     l_overall_status := x_return_status;
	   End If;
	 End If;

        EXIT WHEN (i = p_del_tbl.LAST);

        i := p_del_tbl.NEXT(i);
      END LOOP;
	 -- return overall status
	 x_return_status := l_overall_status;
    END IF;

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;

-- update oke_k_lines

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2  ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_rec                      IN del_rec_type,
    x_del_rec                      OUT NOCOPY del_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1.0;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_del_rec                      del_rec_type := p_del_rec;
    l_def_del_rec                  del_rec_type;
    lx_del_rec                     del_rec_type;

    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_del_rec	IN del_rec_type
    ) RETURN del_rec_type IS

      l_del_rec	del_rec_type := p_del_rec;

    BEGIN
      l_del_rec.LAST_UPDATE_DATE := SYSDATE;
      l_del_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_del_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_del_rec);
    END fill_who_columns;

    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_del_rec	IN del_rec_type,
      x_del_rec	OUT NOCOPY del_rec_type
    ) RETURN VARCHAR2 IS

      l_del_rec                     del_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;

    BEGIN


      x_del_rec := p_del_rec;


      -- Get current database values
      l_del_rec := get_rec(p_del_rec, l_row_notfound);

      IF (l_row_notfound) THEN
        l_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
      END IF;


    IF  x_del_rec.DELIVERABLE_NUM = OKE_API.G_MISS_CHAR THEN
	x_del_rec.DELIVERABLE_NUM := l_del_rec.DELIVERABLE_NUM;
    END IF;

    IF  x_del_rec.PROJECT_ID = OKE_API.G_MISS_NUM THEN
	x_del_rec.PROJECT_ID := l_del_rec.PROJECT_ID;
    END IF;

    IF  x_del_rec.TASK_ID = OKE_API.G_MISS_NUM THEN
      	x_del_rec.TASK_ID := l_del_rec.TASK_ID;
    END IF;

    IF	x_del_rec.ITEM_ID = OKE_API.G_MISS_NUM THEN
        x_del_rec.ITEM_ID := l_del_rec.ITEM_ID;
    END IF;

    IF	x_del_rec.K_HEADER_ID = OKE_API.G_MISS_NUM THEN
        x_del_rec.K_HEADER_ID := l_del_rec.K_HEADER_ID;
    END IF;

    IF	x_del_rec.K_LINE_ID = OKE_API.G_MISS_NUM THEN
	x_del_rec.K_LINE_ID := l_del_rec.K_LINE_ID;
    END IF;

    IF	x_del_rec.DELIVERY_DATE = OKE_API.G_MISS_DATE THEN
	x_del_rec.DELIVERY_DATE := l_del_rec.DELIVERY_DATE;
    END IF;

    IF  x_del_rec.STATUS_CODE = OKE_API.G_MISS_CHAR THEN
	x_del_rec.STATUS_CODE	:= l_del_rec.STATUS_CODE;
    END IF;

    IF	x_del_rec.PARENT_DELIVERABLE_ID = OKE_API.G_MISS_NUM THEN
	x_del_rec.PARENT_DELIVERABLE_ID := l_del_rec.PARENT_DELIVERABLE_ID;
    END IF;

    IF	x_del_rec.SHIP_TO_ORG_ID = OKE_API.G_MISS_NUM THEN
	x_del_rec.SHIP_TO_ORG_ID := l_del_rec.SHIP_TO_ORG_ID;
    END IF;

    IF	x_del_rec.SHIP_TO_LOCATION_ID = OKE_API.G_MISS_NUM THEN
	x_del_rec.SHIP_TO_LOCATION_ID := l_del_rec.SHIP_TO_LOCATION_ID;
    END IF;

    IF	x_del_rec.SHIP_FROM_ORG_ID = OKE_API.G_MISS_NUM THEN
	x_del_rec.SHIP_FROM_ORG_ID := l_del_rec.SHIP_FROM_ORG_ID;
    END IF;

    IF	x_del_rec.SHIP_FROM_LOCATION_ID = OKE_API.G_MISS_NUM THEN
	x_del_rec.SHIP_FROM_LOCATION_ID := l_del_rec.SHIP_FROM_LOCATION_ID;
    END IF;

    IF	x_del_rec.INVENTORY_ORG_ID = OKE_API.G_MISS_NUM THEN
	x_del_rec.INVENTORY_ORG_ID := l_del_rec.INVENTORY_ORG_ID;
    END IF;

    IF  x_del_rec.DIRECTION = OKE_API.G_MISS_CHAR THEN
	x_del_rec.DIRECTION := l_del_rec.DIRECTION;
    END IF;

    IF	x_del_rec.DEFAULTED_FLAG = OKE_API.G_MISS_CHAR THEN
	x_del_rec.DEFAULTED_FLAG := l_del_rec.DEFAULTED_FLAG;
    END IF;

    IF	x_del_rec.IN_PROCESS_FLAG = OKE_API.G_MISS_CHAR THEN
	x_del_rec.IN_PROCESS_FLAG := l_del_rec.IN_PROCESS_FLAG;
    END IF;

    IF	x_del_rec.WF_ITEM_KEY = OKE_API.G_MISS_CHAR THEN
	x_del_rec.WF_ITEM_KEY := l_del_rec.WF_ITEM_KEY;
    END IF;

    IF	x_del_rec.SUB_REF_ID = OKE_API.G_MISS_NUM THEN
        x_del_rec.SUB_REF_ID := l_del_rec.SUB_REF_ID;
    END IF;

    IF	x_del_rec.START_DATE	= OKE_API.G_MISS_DATE THEN
        x_del_rec.START_DATE	:= l_del_rec.START_DATE;
    END IF;

    IF	x_del_rec.END_DATE	= OKE_API.G_MISS_DATE THEN
        x_del_rec.END_DATE	:= l_del_rec.END_DATE;
    END IF;

    IF	x_del_rec.PRIORITY_CODE	= OKE_API.G_MISS_CHAR THEN
        x_del_rec.PRIORITY_CODE := l_del_rec.PRIORITY_CODE;
    END IF;

    IF	x_del_rec.CURRENCY_CODE	= OKE_API.G_MISS_CHAR THEN
        x_del_rec.CURRENCY_CODE	:= l_del_rec.CURRENCY_CODE;
    END IF;

    IF	x_del_rec.UNIT_PRICE = OKE_API.G_MISS_NUM THEN
	x_del_rec.UNIT_PRICE := l_del_rec.UNIT_PRICE;
    END IF;

    IF	x_del_rec.UOM_CODE = OKE_API.G_MISS_CHAR THEN
	x_del_rec.UOM_CODE := l_del_rec.UOM_CODE;
    END IF;

    IF	x_del_rec.QUANTITY = OKE_API.G_MISS_NUM THEN
	x_del_rec.QUANTITY := l_del_rec.QUANTITY;
    END IF;

    IF  x_del_rec.COUNTRY_OF_ORIGIN_CODE = OKE_API.G_MISS_CHAR THEN
	x_del_rec.COUNTRY_OF_ORIGIN_CODE := l_del_rec.COUNTRY_OF_ORIGIN_CODE;
    END IF;

    IF	x_del_rec.SUBCONTRACTED_FLAG = OKE_API.G_MISS_CHAR THEN
	x_del_rec.SUBCONTRACTED_FLAG := l_del_rec.SUBCONTRACTED_FLAG;
    END IF;

    IF	x_del_rec.DEPENDENCY_FLAG = OKE_API.G_MISS_CHAR THEN
	x_del_rec.DEPENDENCY_FLAG := l_del_rec.DEPENDENCY_FLAG;
    END IF;



    IF	x_del_rec.BILLABLE_FLAG	= OKE_API.G_MISS_CHAR THEN
	x_del_rec.BILLABLE_FLAG	:= l_del_rec.BILLABLE_FLAG;
    END IF;

    IF	x_del_rec.BILLING_EVENT_ID = OKE_API.G_MISS_NUM THEN
	x_del_rec.BILLING_EVENT_ID := l_del_rec.BILLING_EVENT_ID;
    END IF;

    IF	x_del_rec.DROP_SHIPPED_FLAG = OKE_API.G_MISS_CHAR THEN
        x_del_rec.DROP_SHIPPED_FLAG := l_del_rec.DROP_SHIPPED_FLAG;
    END IF;

    IF	x_del_rec.COMPLETED_FLAG = OKE_API.G_MISS_CHAR THEN
	x_del_rec.COMPLETED_FLAG := l_del_rec.COMPLETED_FLAG;
    END IF;

    IF	x_del_rec.AVAILABLE_FOR_SHIP_FLAG = OKE_API.G_MISS_CHAR THEN
	x_del_rec.AVAILABLE_FOR_SHIP_FLAG := l_del_rec.AVAILABLE_FOR_SHIP_FLAG;
    END IF;

    IF	x_del_rec.CREATE_DEMAND = OKE_API.G_MISS_CHAR THEN
	x_del_rec.CREATE_DEMAND := l_del_rec.CREATE_DEMAND;
    END IF;

    IF	x_del_rec.READY_TO_BILL = OKE_API.G_MISS_CHAR THEN
	x_del_rec.READY_TO_BILL := l_del_rec.READY_TO_BILL;
    END IF;

    IF	x_del_rec.NEED_BY_DATE = OKE_API.G_MISS_DATE THEN
	x_del_rec.NEED_BY_DATE := l_del_rec.NEED_BY_DATE;
    END IF;

    IF	x_del_rec.READY_TO_PROCURE = OKE_API.G_MISS_CHAR THEN
	x_del_rec.READY_TO_PROCURE := l_del_rec.READY_TO_PROCURE;
    END IF;

    IF	x_del_rec.MPS_TRANSACTION_ID = OKE_API.G_MISS_NUM THEN
	x_del_rec.MPS_TRANSACTION_ID := l_del_rec.MPS_TRANSACTION_ID;
    END IF;

    IF	x_del_rec.PO_REF_1 = OKE_API.G_MISS_NUM THEN
	x_del_rec.PO_REF_1 := l_del_rec.PO_REF_1;
    END IF;

    IF	x_del_rec.PO_REF_2 = OKE_API.G_MISS_NUM THEN
	x_del_rec.PO_REF_2 := l_del_rec.PO_REF_2;
    END IF;

    IF	x_del_rec.PO_REF_3 = OKE_API.G_MISS_NUM THEN
	x_del_rec.PO_REF_3 := l_del_rec.PO_REF_3;
    END IF;

    IF	x_del_rec.SHIPPING_REQUEST_ID = OKE_API.G_MISS_NUM THEN
	x_del_rec.SHIPPING_REQUEST_ID := l_del_rec.SHIPPING_REQUEST_ID;
    END IF;

    IF	x_del_rec.UNIT_NUMBER = OKE_API.G_MISS_CHAR THEN
	x_del_rec.UNIT_NUMBER := l_del_rec.UNIT_NUMBER;
    END IF;

    IF	x_del_rec.NDB_SCHEDULE_DESIGNATOR = OKE_API.G_MISS_CHAR THEN
	x_del_rec.NDB_SCHEDULE_DESIGNATOR := l_del_rec.NDB_SCHEDULE_DESIGNATOR;
    END IF;

    IF	x_del_rec.SHIPPABLE_FLAG = OKE_API.G_MISS_CHAR THEN
	x_del_rec.SHIPPABLE_FLAG := l_del_rec.SHIPPABLE_FLAG;
    END IF;

    IF	x_del_rec.CFE_REQ_FLAG = OKE_API.G_MISS_CHAR THEN
	x_del_rec.CFE_REQ_FLAG := l_del_rec.CFE_REQ_FLAG;
    END IF;

    IF	x_del_rec.INSPECTION_REQ_FLAG = OKE_API.G_MISS_CHAR THEN
	x_del_rec.INSPECTION_REQ_FLAG := l_del_rec.INSPECTION_REQ_FLAG;
    END IF;

    IF	x_del_rec.INTERIM_RPT_REQ_FLAG = OKE_API.G_MISS_CHAR THEN
	x_del_rec.INTERIM_RPT_REQ_FLAG := l_del_rec.INTERIM_RPT_REQ_FLAG;
    END IF;

    IF	x_del_rec.LOT_APPLIES_FLAG = OKE_API.G_MISS_CHAR THEN
	x_del_rec.LOT_APPLIES_FLAG := l_del_rec.LOT_APPLIES_FLAG;
    END IF;

    IF	x_del_rec.CUSTOMER_APPROVAL_REQ_FLAG = OKE_API.G_MISS_CHAR THEN
	x_del_rec.CUSTOMER_APPROVAL_REQ_FLAG := l_del_rec.CUSTOMER_APPROVAL_REQ_FLAG;
    END IF;

    IF	x_del_rec.EXPECTED_SHIPMENT_DATE = OKE_API.G_MISS_DATE THEN
	x_del_rec.EXPECTED_SHIPMENT_DATE := l_del_rec.EXPECTED_SHIPMENT_DATE;
    END IF;

    IF	x_del_rec.INITIATE_SHIPMENT_DATE = OKE_API.G_MISS_DATE THEN
	x_del_rec.INITIATE_SHIPMENT_DATE := l_del_rec.INITIATE_SHIPMENT_DATE;
    END IF;

    IF	x_del_rec.PROMISED_SHIPMENT_DATE = OKE_API.G_MISS_DATE THEN
	x_del_rec.PROMISED_SHIPMENT_DATE := l_del_rec.PROMISED_SHIPMENT_DATE;
    END IF;

    IF	x_del_rec.AS_OF_DATE = OKE_API.G_MISS_DATE THEN
	x_del_rec.AS_OF_DATE := l_del_rec.AS_OF_DATE;
    END IF;

    IF	x_del_rec.DATE_OF_FIRST_SUBMISSION = OKE_API.G_MISS_DATE THEN
	x_del_rec.DATE_OF_FIRST_SUBMISSION := l_del_rec.DATE_OF_FIRST_SUBMISSION;
    END IF;

    IF	x_del_rec.FREQUENCY = OKE_API.G_MISS_CHAR THEN
	x_del_rec.FREQUENCY := l_del_rec.FREQUENCY;
    END IF;

    IF	x_del_rec.ACQ_DOC_NUMBER = OKE_API.G_MISS_CHAR THEN
	x_del_rec.ACQ_DOC_NUMBER := l_del_rec.ACQ_DOC_NUMBER;
    END IF;

    IF	x_del_rec.SUBMISSION_FLAG = OKE_API.G_MISS_CHAR THEN
	x_del_rec.SUBMISSION_FLAG := l_del_rec.SUBMISSION_FLAG;
    END IF;

    IF	x_del_rec.DATA_ITEM_NAME = OKE_API.G_MISS_CHAR THEN
	x_del_rec.DATA_ITEM_NAME := l_del_rec.DATA_ITEM_NAME;
    END IF;

    IF	x_del_rec.DATA_ITEM_SUBTITLE = OKE_API.G_MISS_CHAR THEN
	x_del_rec.DATA_ITEM_SUBTITLE := l_del_rec.DATA_ITEM_SUBTITLE;
    END IF;

    IF	x_del_rec.TOTAL_NUM_OF_COPIES = OKE_API.G_MISS_NUM THEN
	x_del_rec.TOTAL_NUM_OF_COPIES := l_del_rec.TOTAL_NUM_OF_COPIES;
    END IF;

    IF	x_del_rec.CDRL_CATEGORY = OKE_API.G_MISS_CHAR THEN
	x_del_rec.CDRL_CATEGORY := l_del_rec.CDRL_CATEGORY;
    END IF;

    IF	x_del_rec.EXPORT_LICENSE_NUM = OKE_API.G_MISS_CHAR THEN
   	x_del_rec.EXPORT_LICENSE_NUM := l_del_rec.EXPORT_LICENSE_NUM;
    END IF;

    IF	x_del_rec.EXPORT_LICENSE_RES = OKE_API.G_MISS_CHAR THEN
	x_del_rec.EXPORT_LICENSE_RES := l_del_rec.EXPORT_LICENSE_RES;
    END IF;

    IF	x_del_rec.EXPORT_FLAG = OKE_API.G_MISS_CHAR THEN
	x_del_rec.EXPORT_FLAG := l_del_rec.EXPORT_FLAG;
    END IF;

    IF	x_del_rec.CREATED_BY = OKE_API.G_MISS_NUM THEN
	x_del_rec.CREATED_BY := l_del_rec.CREATED_BY;
    END IF;

    IF	x_del_rec.CREATION_DATE = OKE_API.G_MISS_DATE THEN
	x_del_rec.CREATION_DATE := l_del_rec.CREATION_DATE;
    END IF;

    IF	x_del_rec.LAST_UPDATED_BY = OKE_API.G_MISS_NUM THEN
	x_del_rec.LAST_UPDATED_BY := l_del_rec.LAST_UPDATED_BY;
    END IF;

    IF	x_del_rec.LAST_UPDATE_LOGIN = OKE_API.G_MISS_NUM THEN
	x_del_rec.LAST_UPDATE_LOGIN := l_del_rec.LAST_UPDATE_LOGIN;
    END IF;

    IF	x_del_rec.LAST_UPDATE_DATE = OKE_API.G_MISS_DATE THEN
	x_del_rec.LAST_UPDATE_DATE := l_del_rec.LAST_UPDATE_DATE;
    END IF;

    IF	x_del_rec.ATTRIBUTE_CATEGORY = OKE_API.G_MISS_CHAR THEN
	x_del_rec.ATTRIBUTE_CATEGORY := l_del_rec.ATTRIBUTE_CATEGORY;
    END IF;

    IF	x_del_rec.ATTRIBUTE1 = OKE_API.G_MISS_CHAR THEN
	x_del_rec.ATTRIBUTE1 := l_del_rec.ATTRIBUTE1;
    END IF;

    IF	x_del_rec.ATTRIBUTE2 = OKE_API.G_MISS_CHAR THEN
	x_del_rec.ATTRIBUTE2 := l_del_rec.ATTRIBUTE2;
    END IF;

    IF	x_del_rec.ATTRIBUTE3 = OKE_API.G_MISS_CHAR THEN
	x_del_rec.ATTRIBUTE3 := l_del_rec.ATTRIBUTE3;
    END IF;

    IF	x_del_rec.ATTRIBUTE4 = OKE_API.G_MISS_CHAR THEN
	x_del_rec.ATTRIBUTE4 := l_del_rec.ATTRIBUTE4;
    END IF;

    IF	x_del_rec.ATTRIBUTE5 = OKE_API.G_MISS_CHAR THEN
	x_del_rec.ATTRIBUTE5 := l_del_rec.ATTRIBUTE5;
    END IF;

    IF	x_del_rec.ATTRIBUTE6 = OKE_API.G_MISS_CHAR THEN
	x_del_rec.ATTRIBUTE6 := l_del_rec.ATTRIBUTE6;
    END IF;

    IF	x_del_rec.ATTRIBUTE7 = OKE_API.G_MISS_CHAR THEN
	x_del_rec.ATTRIBUTE7 := l_del_rec.ATTRIBUTE7;
    END IF;

    IF	x_del_rec.ATTRIBUTE8 = OKE_API.G_MISS_CHAR THEN
	x_del_rec.ATTRIBUTE8 := l_del_rec.ATTRIBUTE8;
    END IF;

    IF	x_del_rec.ATTRIBUTE9 = OKE_API.G_MISS_CHAR THEN
	x_del_rec.ATTRIBUTE9 := l_del_rec.ATTRIBUTE9;
    END IF;

    IF	x_del_rec.ATTRIBUTE10 = OKE_API.G_MISS_CHAR THEN
	x_del_rec.ATTRIBUTE10 := l_del_rec.ATTRIBUTE10;
    END IF;

    IF	x_del_rec.ATTRIBUTE11 = OKE_API.G_MISS_CHAR THEN
	x_del_rec.ATTRIBUTE11 := l_del_rec.ATTRIBUTE11;
    END IF;

    IF	x_del_rec.ATTRIBUTE12 = OKE_API.G_MISS_CHAR THEN
	x_del_rec.ATTRIBUTE12 := l_del_rec.ATTRIBUTE12;
    END IF;

    IF	x_del_rec.ATTRIBUTE13 = OKE_API.G_MISS_CHAR THEN
	x_del_rec.ATTRIBUTE13 := l_del_rec.ATTRIBUTE13;
    END IF;

    IF	x_del_rec.ATTRIBUTE14 = OKE_API.G_MISS_CHAR THEN
	x_del_rec.ATTRIBUTE14 := l_del_rec.ATTRIBUTE14;
    END IF;

    IF	x_del_rec.ATTRIBUTE15 = OKE_API.G_MISS_CHAR THEN
	x_del_rec.ATTRIBUTE15 := l_del_rec.ATTRIBUTE15;
    END IF;

    IF  x_del_rec.WEIGHT = OKE_API.G_MISS_NUM THEN
        x_del_rec.WEIGHT := l_del_rec.WEIGHT;
    END IF;

    IF  x_del_rec.WEIGHT_UOM_CODE = OKE_API.G_MISS_CHAR THEN
        x_del_rec.WEIGHT_UOM_CODE := l_del_rec.WEIGHT_UOM_CODE;
    END IF;

    IF  x_del_rec.VOLUME = OKE_API.G_MISS_NUM THEN
        x_del_rec.VOLUME := l_del_rec.VOLUME;
    END IF;

    IF  x_del_rec.VOLUME_UOM_CODE = OKE_API.G_MISS_CHAR THEN
        x_del_rec.VOLUME_UOM_CODE := l_del_rec.VOLUME_UOM_CODE;
    END IF;

    IF  x_del_rec.EXPENDITURE_ORGANIZATION_ID = OKE_API.G_MISS_NUM THEN
        x_del_rec.EXPENDITURE_ORGANIZATION_ID := l_del_rec.EXPENDITURE_ORGANIZATION_ID;
    END IF;

    IF  x_del_rec.EXPENDITURE_TYPE = OKE_API.G_MISS_CHAR THEN
        x_del_rec.EXPENDITURE_TYPE := l_del_rec.EXPENDITURE_TYPE;
    END IF;

    IF  x_del_rec.DESTINATION_TYPE_CODE = OKE_API.G_MISS_CHAR THEN
        x_del_rec.DESTINATION_TYPE_CODE := l_del_rec.DESTINATION_TYPE_CODE;
    END IF;

    IF  x_del_rec.EXPENDITURE_ITEM_DATE = OKE_API.G_MISS_DATE THEN
        x_del_rec.EXPENDITURE_ITEM_DATE := l_del_rec.EXPENDITURE_ITEM_DATE;
    END IF;

    IF  x_del_rec.RATE_DATE = OKE_API.G_MISS_DATE THEN
        x_del_rec.RATE_DATE := l_del_rec.RATE_DATE;
    END IF;

    IF  x_del_rec.RATE_TYPE = OKE_API.G_MISS_CHAR THEN
        x_del_rec.RATE_TYPE := l_del_rec.RATE_TYPE;
    END IF;

    IF  x_del_rec.EXCHANGE_RATE = OKE_API.G_MISS_NUM THEN
        x_del_rec.EXCHANGE_RATE := l_del_rec.EXCHANGE_RATE;
    END IF;

    IF  x_del_rec.DESCRIPTION = OKE_API.G_MISS_CHAR THEN
	x_del_rec.DESCRIPTION := l_del_rec.DESCRIPTION;
    END IF;

    IF  x_del_rec.COMMENTS = OKE_API.G_MISS_CHAR THEN
	x_del_rec.COMMENTS := l_del_rec.COMMENTS;
    END IF;

   IF  x_del_rec.REQUISITION_LINE_TYPE_ID = OKE_API.G_MISS_NUM THEN
        x_del_rec.REQUISITION_LINE_TYPE_ID := l_del_rec.REQUISITION_LINE_TYPE_ID;
    END IF;

   IF  x_del_rec.PO_CATEGORY_ID = OKE_API.G_MISS_NUM THEN
        x_del_rec.PO_CATEGORY_ID := l_del_rec.PO_CATEGORY_ID;
    END IF;

    RETURN(l_return_status);



  END populate_new_record;

  -- set attributes for oke_k_lines

  FUNCTION set_attributes(
	 p_del_rec IN  del_rec_type,
	 x_del_rec OUT NOCOPY del_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    BEGIN

      x_del_rec := p_del_rec;
      x_del_rec.BILLABLE_FLAG		:= UPPER(x_del_rec.BILLABLE_FLAG);
      x_del_rec.SHIPPABLE_FLAG		:= UPPER(x_del_rec.SHIPPABLE_FLAG);
      x_del_rec.SUBCONTRACTED_FLAG	 := UPPER(x_del_rec.SUBCONTRACTED_FLAG);
      x_del_rec.COMPLETED_FLAG		:= UPPER(x_del_rec.COMPLETED_FLAG);

      x_del_rec.DROP_SHIPPED_FLAG	:= UPPER(x_del_rec.DROP_SHIPPED_FLAG);

      x_del_rec.CUSTOMER_APPROVAL_REQ_FLAG := UPPER(x_del_rec.CUSTOMER_APPROVAL_REQ_FLAG);

      x_del_rec.INSPECTION_REQ_FLAG	:= UPPER(x_del_rec.INSPECTION_REQ_FLAG);

      x_del_rec.INTERIM_RPT_REQ_FLAG	:= UPPER(x_del_rec.INTERIM_RPT_REQ_FLAG);

      x_del_rec.EXPORT_FLAG	:= UPPER(x_del_rec.EXPORT_FLAG);

      x_del_rec.CFE_REQ_FLAG	:= UPPER(x_del_rec.CFE_REQ_FLAG);

      x_del_rec.DEFAULTED_FLAG	:= UPPER(x_del_rec.DEFAULTED_FLAG);

      x_del_rec.IN_PROCESS_FLAG	:= UPPER(x_del_rec.IN_PROCESS_FLAG);

      RETURN(l_return_status);

    END Set_Attributes;

  BEGIN



    l_return_status := OKE_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);

    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;



    l_return_status := Set_Attributes(
      p_del_rec,                        -- IN
      l_del_rec);                       -- OUT

    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;



    l_return_status := populate_new_record(l_del_rec, l_def_del_rec);

    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;



    l_def_del_rec := fill_who_columns(l_def_del_rec);



    -- validate attributes when update is not necessory, since the control logic is at the
    -- client side

/*  --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_del_rec);



    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;



    l_return_status := Validate_Record(l_def_del_rec);
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;  */

    UPDATE oke_k_deliverables_b
    SET
	deliverable_num = l_def_del_rec.deliverable_num,
	project_id = l_def_del_rec.project_id,
	task_id = l_def_del_rec.task_id,
	item_id = l_def_del_rec.item_id,
	k_header_id = l_def_del_rec.k_header_id,
	k_line_id = l_def_del_rec.k_line_id,
	delivery_date = l_def_del_rec.delivery_date,
	status_code = l_def_del_rec.status_code,
	parent_deliverable_id = l_def_del_rec.parent_deliverable_id,
	ship_to_org_id = l_def_del_rec.ship_to_org_id,
	ship_to_location_id = l_def_del_rec.ship_to_location_id,
	ship_from_org_id = l_def_del_rec.ship_from_org_id,
	ship_from_location_id = l_def_del_rec.ship_from_location_id,
	inventory_org_id = l_def_del_rec.inventory_org_id,
	direction = l_def_del_rec.direction,
	defaulted_flag = l_def_del_rec.defaulted_flag,
	in_process_flag = l_def_del_rec.in_process_flag,
	wf_item_key = l_def_del_rec.wf_item_key,
	sub_ref_id = l_def_del_rec.sub_ref_id,
	start_date = l_def_del_rec.start_date,
	end_date = l_def_del_rec.end_date,
	priority_code = l_def_del_rec.priority_code,
	currency_code = l_def_del_rec.currency_code,
	unit_price = l_def_del_rec.unit_price,
	uom_code = l_def_del_rec.uom_code,
	quantity = l_def_del_rec.quantity,
	country_of_origin_code = l_def_del_rec.country_of_origin_code,
	subcontracted_flag = l_def_del_rec.subcontracted_flag,
	dependency_flag = l_def_del_rec.dependency_flag,
	billable_flag = l_def_del_rec.billable_flag,
	billing_event_id = l_def_del_rec.billing_event_id,
	drop_shipped_flag = l_def_del_rec.drop_shipped_flag,
	completed_flag = l_def_del_rec.completed_flag,
	available_for_ship_flag = l_def_del_rec.available_for_ship_flag,
	create_demand = l_def_del_rec.create_demand,
	ready_to_bill = l_def_del_rec.ready_to_bill,
	need_by_date = l_def_del_rec.need_by_date,
	ready_to_procure = l_def_del_rec.ready_to_procure,
	mps_transaction_id = l_def_del_rec.mps_transaction_id,
	po_ref_1 = l_def_del_rec.po_ref_1,
	po_ref_2 = l_def_del_rec.po_ref_2,
	po_ref_3 = l_def_del_rec.po_ref_3,
	shipping_request_id = l_def_del_rec.shipping_request_id,
	unit_number = l_def_del_rec.unit_number,
	ndb_schedule_designator = l_def_del_rec.ndb_schedule_designator,
	shippable_flag = l_def_del_rec.shippable_flag,
	cfe_req_flag = l_def_del_rec.cfe_req_flag,
	inspection_req_flag = l_def_del_rec.inspection_req_flag,
	interim_rpt_req_flag = l_def_del_rec.interim_rpt_req_flag,
        lot_applies_flag = l_def_del_rec.lot_applies_flag,
	customer_approval_req_flag = l_def_del_rec.customer_approval_req_flag,
	expected_shipment_date = l_def_del_rec.expected_shipment_date,
	initiate_shipment_date = l_def_del_rec.initiate_shipment_date,
        promised_shipment_date = l_def_del_rec.promised_shipment_date,
    	as_of_date = l_def_del_rec.as_of_date,
 	date_of_first_submission = l_def_del_rec.date_of_first_submission,
	frequency = l_def_del_rec.frequency,
	acq_doc_number = l_def_del_rec.acq_doc_number,
	submission_flag = l_def_del_rec.submission_flag,
	data_item_subtitle = l_def_del_rec.data_item_subtitle,
	total_num_of_copies = l_def_del_rec.total_num_of_copies,
	cdrl_category = l_def_del_rec.cdrl_category,
	data_item_name = l_def_del_rec.data_item_name,
	export_flag = l_def_del_rec.export_flag,
	export_license_num = l_def_del_rec.export_license_num,
        export_license_res = l_def_del_rec.export_license_res,
        created_by = l_def_del_rec.created_by,
	creation_date = l_def_del_rec.creation_date,
	last_updated_by = l_def_del_rec.last_updated_by,
 	last_update_login = l_def_del_rec.last_update_login,
	last_update_date = l_def_del_rec.last_update_date,
	attribute_category = l_def_del_rec.attribute_category,
	attribute1 = l_def_del_rec.attribute1,
	attribute2 = l_def_del_rec.attribute2,
	attribute3 = l_def_del_rec.attribute3,
	attribute4 = l_def_del_rec.attribute4,
	attribute5 = l_def_del_rec.attribute5,
	attribute6 = l_def_del_rec.attribute6,
	attribute7 = l_def_del_rec.attribute7,
	attribute8 = l_def_del_rec.attribute8,
	attribute9 = l_def_del_rec.attribute9,
	attribute10 = l_def_del_rec.attribute10,
	attribute11 = l_def_del_rec.attribute11,
	attribute12 = l_def_del_rec.attribute12,
	attribute13 = l_def_del_rec.attribute13,
	attribute14 = l_def_del_rec.attribute14,
	attribute15 = l_def_del_rec.attribute15,
    	weight      = l_def_del_rec.weight,
	weight_uom_code = l_def_del_rec.weight_uom_code,
	volume		= l_def_del_rec.volume,
	volume_uom_code = l_def_del_rec.volume_uom_code,
	expenditure_organization_id = l_def_del_rec.expenditure_organization_id,
	expenditure_type = l_def_del_rec.expenditure_type,
	expenditure_item_date = l_def_del_rec.expenditure_item_date,
	destination_type_code = l_def_del_rec.destination_type_code,
    	rate_type = l_def_del_rec.rate_type,
	rate_date = l_def_del_rec.rate_date,
	exchange_rate = l_def_del_rec.exchange_rate,
	requisition_line_type_id = l_def_del_rec.requisition_line_type_id,
	po_category_id = l_def_del_rec.po_category_id
    where deliverable_id = l_def_del_rec.deliverable_id;

    -- update the TL table

    update oke_k_deliverables_tl
    set
      description = l_def_del_rec.description,
      comments    = l_def_del_rec.comments,
      sfwt_flag   = l_def_del_rec.sfwt_flag,
      source_lang = userenv('LANG')
    where deliverable_id = l_def_del_rec.deliverable_id
    and userenv('LANG') in (language , source_lang);

    x_del_rec := l_def_del_rec;

    OKE_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2  ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_tbl                     IN del_tbl_type,
    x_del_tbl                     OUT NOCOPY del_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1.0;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TBL_update_row';

    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKE_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_del_tbl.COUNT > 0) THEN
      i := p_del_tbl.FIRST;
      LOOP
        update_row (
          p_api_version     => p_api_version,
          p_init_msg_list   => G_FALSE,
          x_return_status   => x_return_status,
          x_msg_count       => x_msg_count,
          x_msg_data        => x_msg_data,
          p_del_rec         => p_del_tbl(i),
          x_del_rec         => x_del_tbl(i));

		-- store the highest degree of error
	If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	  If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
	    l_overall_status := x_return_status;
	  End If;
	End If;

        EXIT WHEN (i = p_del_tbl.LAST);
        i := p_del_tbl.NEXT(i);
      END LOOP;
	 -- return overall status
	 x_return_status := l_overall_status;
    END IF;

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2  ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_rec                     IN del_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_del_rec                     del_rec_type := p_del_rec;

  BEGIN

    l_return_status := OKE_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);

    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;

    DELETE FROM oke_k_deliverables_b
    WHERE deliverable_id = l_del_rec.deliverable_id;

    OKE_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2  ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_tbl                     IN del_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TBL_delete_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKE_API.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing
    IF (p_del_tbl.COUNT > 0) THEN
      i := p_del_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_del_rec                      => p_del_tbl(i));

	-- store the highest degree of error
	If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	  If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
	    l_overall_status := x_return_status;
          End If;
	End If;

        EXIT WHEN (i = p_del_tbl.LAST);
        i := p_del_tbl.NEXT(i);
      END LOOP;

	 -- return overall status
	 x_return_status := l_overall_status;
    END IF;

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

  PROCEDURE lock_row(
    p_api_version		   IN NUMBER,
    p_init_msg_list                IN VARCHAR2  ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_rec                      IN del_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_del_rec IN del_rec_type) IS
    SELECT deliverable_num
      FROM oke_k_deliverables_b
     WHERE deliverable_id = p_del_rec.deliverable_id

    FOR UPDATE OF deliverable_id NOWAIT;

    CURSOR  lchk_csr (p_del_rec IN del_rec_type) IS
    SELECT deliverable_num
      FROM oke_k_deliverables_b
    WHERE deliverable_id = p_del_rec.deliverable_id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_deliverable_num	          OKE_K_DELIVERABLES_B.DELIVERABLE_NUM%TYPE;
    lc_deliverable_num	          OKE_K_DELIVERABLES_B.DELIVERABLE_NUM%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKE_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_del_rec);
      FETCH lock_csr INTO l_deliverable_num;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKE_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_del_rec);
      FETCH lchk_csr INTO lc_deliverable_num;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKE_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKE_API.G_EXCEPTION_ERROR;
    ELSIF lc_deliverable_num > p_del_rec.deliverable_num THEN
      OKE_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKE_API.G_EXCEPTION_ERROR;
    ELSIF lc_deliverable_num <> p_del_rec.deliverable_num THEN
      OKE_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKE_API.G_EXCEPTION_ERROR;
    ELSIF lc_deliverable_num = -1 THEN
      OKE_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;
    OKE_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;

  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_tbl                     IN del_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKE_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_del_tbl.COUNT > 0) THEN
      i := p_del_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_del_rec                     => p_del_tbl(i));

		-- store the highest degree of error
		If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
		   If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
			 l_overall_status := x_return_status;
		   End If;
		End If;

        EXIT WHEN (i = p_del_tbl.LAST);
        i := p_del_tbl.NEXT(i);
      END LOOP;
	 -- return overall status
	 x_return_status := l_overall_status;
    END IF;
  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;

  PROCEDURE add_language
  is
  begin
    delete from OKE_K_DELIVERABLES_TL T
    where not exists
      (select NULL
      from OKE_K_DELIVERABLES_B B
      where B.DELIVERABLE_ID = T.DELIVERABLE_ID
      );

    update OKE_K_DELIVERABLES_TL T set (
        DESCRIPTION,
        COMMENTS
      ) = (select
        B.DESCRIPTION,
        B.COMMENTS
      from OKE_K_DELIVERABLES_TL B
      where B.DELIVERABLE_ID = T.DELIVERABLE_ID
      and B.LANGUAGE = T.SOURCE_LANG)
    where (
        T.DELIVERABLE_ID,
        T.LANGUAGE
    ) in (select
        SUBT.DELIVERABLE_ID,
        SUBT.LANGUAGE
      from OKE_K_DELIVERABLES_TL SUBB, OKE_K_DELIVERABLES_TL SUBT
      where SUBB.DELIVERABLE_ID = SUBT.DELIVERABLE_ID
      and SUBB.LANGUAGE = SUBT.SOURCE_LANG
      and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
        or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
        or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
        or SUBB.COMMENTS <> SUBT.COMMENTS
        or (SUBB.COMMENTS is null and SUBT.COMMENTS is not null)
        or (SUBB.COMMENTS is not null and SUBT.COMMENTS is null)
    ));

    insert into OKE_K_DELIVERABLES_TL (
      DELIVERABLE_ID,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      K_HEADER_ID,
      K_LINE_ID,
      SFWT_FLAG,
      DESCRIPTION,
      COMMENTS,
      LANGUAGE,
      SOURCE_LANG
    ) select
      B.DELIVERABLE_ID,
      B.CREATION_DATE,
      B.CREATED_BY,
      B.LAST_UPDATE_DATE,
      B.LAST_UPDATED_BY,
      B.LAST_UPDATE_LOGIN,
      B.K_HEADER_ID,
      B.K_LINE_ID,
      B.SFWT_FLAG,
      B.DESCRIPTION,
      B.COMMENTS,
      L.LANGUAGE_CODE,
      B.SOURCE_LANG
    from OKE_K_DELIVERABLES_TL B, FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I', 'B')
    and B.LANGUAGE = userenv('LANG')
    and not exists
      (select NULL
      from OKE_K_DELIVERABLES_TL T
      where T.DELIVERABLE_ID = B.DELIVERABLE_ID
      and T.LANGUAGE = L.LANGUAGE_CODE);

    --
    -- History table
    --
    delete from OKE_K_DELIVERABLES_TLH T
    where not exists
      (select NULL
      from OKE_K_DELIVERABLES_BH B
      where B.DELIVERABLE_ID = T.DELIVERABLE_ID
      and T.MAJOR_VERSION = B.MAJOR_VERSION
      );

    update OKE_K_DELIVERABLES_TLH T set (
        DESCRIPTION,
        COMMENTS
      ) = (select
        B.DESCRIPTION,
        B.COMMENTS
      from OKE_K_DELIVERABLES_TLH B
      where B.DELIVERABLE_ID = T.DELIVERABLE_ID
      and B.LANGUAGE = T.SOURCE_LANG
      and T.MAJOR_VERSION = B.MAJOR_VERSION)
    where (
        T.DELIVERABLE_ID,
 	T.MAJOR_VERSION,
        T.LANGUAGE
    ) in (select
        SUBT.DELIVERABLE_ID,
	SUBT.MAJOR_VERSION,
        SUBT.LANGUAGE
      from OKE_K_DELIVERABLES_TLH SUBB, OKE_K_DELIVERABLES_TLH SUBT
      where SUBB.DELIVERABLE_ID = SUBT.DELIVERABLE_ID
      and SUBB.LANGUAGE = SUBT.SOURCE_LANG
      and SUBB.MAJOR_VERSION = SUBT.MAJOR_VERSION
      and (SUBB.DESCRIPTION <> SUBT.DESCRIPTION
        or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
        or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
        or SUBB.COMMENTS <> SUBT.COMMENTS
        or (SUBB.COMMENTS is null and SUBT.COMMENTS is not null)
        or (SUBB.COMMENTS is not null and SUBT.COMMENTS is null)
    ));

    insert into OKE_K_DELIVERABLES_TLH (
      DELIVERABLE_ID,
      MAJOR_VERSION,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      K_HEADER_ID,
      K_LINE_ID,
      SFWT_FLAG,
      DESCRIPTION,
      COMMENTS,
      LANGUAGE,
      SOURCE_LANG
    ) select
      B.DELIVERABLE_ID,
      B.MAJOR_VERSION,
      B.CREATION_DATE,
      B.CREATED_BY,
      B.LAST_UPDATE_DATE,
      B.LAST_UPDATED_BY,
      B.LAST_UPDATE_LOGIN,
      B.K_HEADER_ID,
      B.K_LINE_ID,
      B.SFWT_FLAG,
      B.DESCRIPTION,
      B.COMMENTS,
      L.LANGUAGE_CODE,
      B.SOURCE_LANG
    from OKE_K_DELIVERABLES_TLH B, FND_LANGUAGES L
    where L.INSTALLED_FLAG in ('I', 'B')
    and B.LANGUAGE = userenv('LANG')
    and not exists
      (select NULL
      from OKE_K_DELIVERABLES_TLH T
      where T.DELIVERABLE_ID = B.DELIVERABLE_ID
      and T.LANGUAGE = L.LANGUAGE_CODE
      and T.MAJOR_VERSION = B.MAJOR_VERSION);

  END add_language;

END OKE_DELIVERABLE_PVT;

/
