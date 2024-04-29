--------------------------------------------------------
--  DDL for Package Body GMS_MULTI_FUNDING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_MULTI_FUNDING" AS
/* $Header: gmsmfapb.pls 120.2.12010000.2 2008/10/30 12:30:33 rrambati ship $ */

--Variables will help debugging when exception occurs
G_PKG_NAME      CONSTANT VARCHAR2(30)  := 'GMS_MULTI_FUNDING';
G_Stage                  VARCHAR2(500) := NULL;

FUNCTION  AWARD_PROJECT_NOT_EXISTS(X_Award_Id     IN NUMBER,
                                   X_Err_Code     OUT NOCOPY VARCHAR2,
                                   X_Err_Stage    OUT NOCOPY VARCHAR2)  RETURN BOOLEAN  IS
        Award_Id_Check NUMBER(15) := 0;
        --p_msg_count    NUMBER;
BEGIN
    BEGIN
        SELECT a.project_id --Award_Project_Id
        INTO   Award_Id_Check
        FROM   gms_awards b,
               pa_projects a
        WHERE  b.award_id = X_Award_Id
        AND    a.project_id = b.award_project_id;

        X_Err_Code := 'E';
        X_Err_Stage := 'There is already an Award Project existing for the Award '||to_char(X_Award_Id);

        X_Err_Stage := 'GMS_AWD_PRJ_EXISTS_FOR_AWARD';
        FND_MESSAGE.SET_NAME('GMS','GMS_AWD_PRJ_EXISTS_FOR_AWARD');
        FND_MESSAGE.SET_TOKEN('AWARD_ID',to_char(X_Award_Id));
        FND_MSG_PUB.add;
        FND_MSG_PUB.Count_And_Get
               (p_count  =>  p_msg_count,
                p_data   =>  X_Err_Stage );

        RETURN FALSE;
       EXCEPTION
           WHEN NO_DATA_FOUND THEN
                X_Err_Code := 'S';
                RETURN TRUE;
           WHEN TOO_MANY_ROWS THEN
                X_Err_Code := 'U';
                X_Err_Stage := 'There is more than one Award Project for the Award Id '||to_char(X_Award_Id);

                X_Err_Stage := 'GMS_MANY_AWD_PRJ_FOR_AWARD';
                FND_MESSAGE.SET_NAME('GMS','GMS_MANY_AWD_PRJ_FOR_AWARD');
                FND_MESSAGE.SET_TOKEN('AWARD_ID',to_char(X_Award_Id));
                FND_MSG_PUB.add;
                FND_MSG_PUB.Count_And_Get
                   (p_count  =>  p_msg_count,
                    p_data   =>  X_Err_Stage );
                RETURN FALSE;
    END;

END AWARD_PROJECT_NOT_EXISTS;

FUNCTION PROJ_NAME_NUM_UNIQUE(X_Award_Project_Number   IN VARCHAR2,
                              X_Award_Project_Name     IN VARCHAR2,
                              X_Err_Code               OUT NOCOPY VARCHAR2,
                              X_Err_Stage              OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS
        Project_Check  NUMBER(2) := 0;
        --p_msg_count    NUMBER;
BEGIN
  BEGIN
     SELECT 1
     INTO   Project_Check
     FROM   PA_PROJECTS
     WHERE  NAME = X_Award_Project_Name;

           IF Project_Check = 1 THEN
              X_Err_Code := 'E';
              X_Err_Stage := 'There is already an Award Project existing by the name '||X_Award_Project_Name;

              X_Err_Stage := 'GMS_AWD_PRJNAME_EXISTS';
              FND_MESSAGE.SET_NAME('GMS','GMS_AWD_PRJNAME_EXISTS');
              FND_MESSAGE.SET_TOKEN('AWARD_PROJECT_NAME',X_Award_Project_Name);
              FND_MSG_PUB.add;
              FND_MSG_PUB.Count_And_Get
               (p_count  =>  p_msg_count,
                p_data   =>  X_Err_Stage );

              RETURN FALSE;
           END IF;
      EXCEPTION
 	     WHEN TOO_MANY_ROWS THEN
             X_Err_Code := 'U';
             X_Err_Stage := 'There is more than one Project already existing by the Name '||X_Award_Project_Name;

             X_Err_Stage := 'GMS_AWD_PRJNAME_NOT_UNIQUE';
             FND_MESSAGE.SET_NAME('GMS','GMS_AWD_PRJNAME_NOT_UNIQUE');
             FND_MESSAGE.SET_TOKEN('AWARD_PROJECT_NAME',X_Award_Project_Name);
             FND_MSG_PUB.add;
              FND_MSG_PUB.Count_And_Get
               (p_count  =>  p_msg_count,
                p_data   =>  X_Err_Stage );

             RETURN FALSE;
           WHEN NO_DATA_FOUND THEN
            BEGIN
              SELECT 1
              INTO   Project_Check
              FROM   PA_PROJECTS
              WHERE  SEGMENT1 = X_Award_Project_Number;

              IF Project_Check = 1 THEN
                 X_Err_Code := 'E';
                 X_Err_Stage := 'There is already an Award Project existing by the number'||X_Award_Project_Number;

                 X_Err_Stage := 'GMS_AWD_PRJNUM_EXISTS';
                 FND_MESSAGE.SET_NAME('GMS','GMS_AWD_PRJNUM_EXISTS');
                 FND_MESSAGE.SET_TOKEN('AWARD_PROJECT_NUMBER',X_Award_Project_Number);
                 FND_MSG_PUB.add;
                 FND_MSG_PUB.Count_And_Get
                   (p_count  =>  p_msg_count,
                    p_data   =>  X_Err_Stage );

                 RETURN FALSE;
              END IF;
             EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                       X_Err_Code := 'S';
                       RETURN TRUE;
                  WHEN TOO_MANY_ROWS THEN
                       X_Err_Code := 'U';
                       X_Err_Stage := 'There is more than one Project already existing by the Number'||X_Award_Project_Number;

                       X_Err_Stage := 'GMS_AWD_PRJNUM_NOT_UNIQUE';
                       FND_MESSAGE.SET_NAME('GMS','GMS_AWD_PRJNUM_NOT_UNIQUE');
                       FND_MESSAGE.SET_TOKEN('AWARD_PROJECT_NUMBER',X_Award_Project_Number);
                       FND_MSG_PUB.add;
                       FND_MSG_PUB.Count_And_Get
                         (p_count  =>  p_msg_count,
                          p_data   =>  X_Err_Stage );
                       RETURN FALSE;
            END;
  END;

END PROJ_NAME_NUM_UNIQUE;

PROCEDURE UPDATE_GMS_AWARDS(X_Award_Id         IN NUMBER
                           ,X_Agreement_Id     IN NUMBER
                           ,X_Award_Project_Id IN NUMBER) IS
BEGIN
  UPDATE GMS_AWARDS
  SET    (AWARD_PROJECT_ID,
          AGREEMENT_ID,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN) =
     (SELECT X_Award_Project_Id,
             X_Agreement_Id,
             SYSDATE,
             fnd_global.user_id,
             fnd_global.login_id
      FROM   dual)
      WHERE  AWARD_ID = X_Award_Id;

END UPDATE_GMS_AWARDS;

PROCEDURE UPDATE_PROJECT_ADD_INFO(X_Project_Id                  IN NUMBER,
                                  X_IDC_Schedule_Id             IN NUMBER,
                                  X_IDC_Schedule_Fixed_Date     IN DATE,
                                  X_Labor_Invoice_Format_Id     IN NUMBER,
                                  X_Non_Labor_Invoice_Format_Id IN NUMBER,
                                  X_Billing_Cycle_Id            IN NUMBER,
                                  X_Billing_Offset              IN NUMBER,
                                  X_Err_Code                    OUT NOCOPY VARCHAR2,
                                  X_Err_Stage  			OUT NOCOPY VARCHAR2) IS
BEGIN
   --dbms_output.put_line('Inside UPDATE Project Info');
 UPDATE PA_PROJECTS_ALL
 SET    cost_ind_rate_sch_id         = X_IDC_Schedule_Id,
        cost_ind_sch_fixed_date      = X_IDC_Schedule_Fixed_Date,
        labor_invoice_format_id      = X_Labor_Invoice_Format_Id,
        non_labor_invoice_format_Id  = X_Non_Labor_Invoice_Format_Id,
        billing_cycle_id             = X_Billing_Cycle_Id,
        billing_offset	             = X_Billing_Offset,
        last_UPDATE_date             = sysdate,
        last_UPDATEd_by              = fnd_global.user_id,
        last_UPDATE_login            = fnd_global.login_id
 WHERE  project_id = X_Project_Id;

       X_Err_Code := 'S';

     IF SQL%NOTFOUND THEN
       X_Err_Code := 'E';
       FND_MESSAGE.SET_NAME('GMS','GMS_NO_PROJECT_UPDATED');
       FND_MSG_PUB.add;
       FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
			 	         p_data  => X_Err_Stage);
     END IF;


   -- Bug 3319191 : UPDATE Indirect schedule on task corresponding to
   --               Award Project when Indirect schedule is changed
   --               at award level.

   UPDATE pa_tasks pt
   SET    cost_ind_rate_sch_id= X_IDC_Schedule_Id,
          cost_ind_sch_fixed_date=X_IDC_Schedule_Fixed_Date
   WHERE  project_id = X_project_id;

   --dbms_output.put_line('After  UPDATE Project Info');
  EXCEPTION
       WHEN OTHERS THEN
            FND_MSG_PUB.add_exc_msg
	      ( p_pkg_name        => 'GMS_MULTI_FUNDING'
	       ,p_procedure_name  => 'UPDATE_PROJECT_ADD_INFO'
                   );
            x_err_stage  := SQLERRM||' at stage='||g_stage||' '||X_Err_Stage;
            RAISE;

END UPDATE_PROJECT_ADD_INFO;

-- Bug Fix for Bug 3002270
-- The following procedure verifies the existence of a structure
-- for the award project template. IF it exists, the same project structure is
-- used to copy to the newly created award project, IF not the following procedure
-- creates a structure for the award project template.

-- The structure for the award project template is mandatory FROM PA.K onwards
-- as project creates structure for every project template and uses the same
-- to create a structure while creating a new project, which is copied FROM
-- the template.

PROCEDURE CREATE_AWD_PROJ_TEMPLATE_STRUC(x_award_project_id  IN Number
                                        ,X_Err_Code          OUT NOCOPY VARCHAR2
                                        ,X_Err_Stage         OUT NOCOPY VARCHAR2) IS

l_struct_exists varchar2(1) := 'N';
l_awd_proj_temp pa_projects_all%rowtype;
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
l_return_status VARCHAR2(1);


CURSOR c_awd_proj_temp is
    Select * FROM pa_projects_all
    WHERE project_id = x_award_project_id;

CURSOR c_struc_exists is
    Select 'Y' FROM pa_proj_elements
    WHERE project_id = x_award_project_id;

BEGIN
 --Verify whether a structure is already existing for the award project template.

 OPEN  c_struc_exists;
 FETCH c_struc_exists INTO l_struct_exists;
 CLOSE c_struc_exists;

 IF l_struct_exists = 'N' THEN

   -- Fetch the award project record.
   OPEN  c_awd_proj_temp;
   FETCH c_awd_proj_temp INTO l_awd_proj_temp;
   CLOSE c_awd_proj_temp;

   -- Create structure for the award project template.
   PA_PROJ_TASK_STRUC_PUB.CREATE_DEFAULT_STRUCTURE(
         p_dest_project_id         => x_award_project_id
        ,p_dest_project_name       => l_awd_proj_temp.name
        ,p_dest_project_number     => l_awd_proj_temp.segment1
        ,p_dest_description        => l_awd_proj_temp.description
        ,p_struc_type              => 'FINANCIAL' --creating only financial structure
        ,x_msg_count               => l_msg_count
        ,x_msg_data                => l_msg_data
        ,x_return_status           => l_return_status  );

         IF l_Return_Status <> 'S' THEN
            X_Err_Stage    :=   l_Msg_Data;
            X_Err_Code     :=   l_Return_Status;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

      -- Create Options for the award project template.
      /* bug 5282308 - commented the insert */
      /*
      INSERT INTO pa_project_options
            (project_id,
             option_code,
             last_UPDATE_date,
             last_UPDATEd_by,
             creation_date,
             created_by,
             last_UPDATE_login)
      SELECT x_award_project_id,
             option_code,
             SYSDATE,
             fnd_global.user_id,
             SYSDATE ,
             fnd_global.user_id,
             fnd_global.login_id
      FROM   pa_options
      WHERE  option_code NOT IN ( 'STRUCTURES', 'STRUCTURES_SS' );
      */

      --Create structure for the award project template's task.
      PA_PROJ_TASK_STRUC_PUB.CREATE_DEFAULT_TASK_STRUCTURE(
             p_project_id         => x_award_project_id
            ,p_struc_type         => 'FINANCIAL'
            ,x_msg_count          => l_msg_count
            ,x_msg_data           => l_msg_data
            ,x_return_status      => l_return_status  );

 END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    X_ERR_CODE := l_return_status;
    X_ERR_STAGE  := l_msg_data;

  WHEN OTHERS THEN
    X_ERR_CODE   := l_return_status;
    x_err_stage  := SQLERRM||' at stage='||g_stage||' '||X_Err_Stage;
    X_ERR_STAGE  := l_msg_data;
    Raise;

END CREATE_AWD_PROJ_TEMPLATE_STRUC;

-- END of Bug Fix for Bug 3002270

-- Bug FIx 3049266
-- For the PA.K rollup patch certification we started making use of the customer account relationship feature.
-- From now on we will store the bill_to_customer_id i.e LOC customer id of an award in the bill_to_customer_id
-- column of the pa_project_customers.
-- We will not UPDATE teh record with the latest, by overriding the existing customer_id.
-- For this the columns bill_to_customer_id and ship_to_customer_id need to be defined as overridable.
-- This change can be done in the implementaitons form, but that forces us to come up with a data fix
-- for the existing implementations. So adding that check before creating an award. Thus we dont need any
-- data fix script and all the changes will be centralized in the multi funding package.

PROCEDURE MARK_FIELDS_AS_OVERRIDABLE(x_award_project_id IN NUMBER,
                                     x_field_name IN VARCHAR2,
				     x_err_code OUT NOCOPY VARCHAR2,
                                     x_err_stage OUT NOCOPY VARCHAR2) IS

CURSOR c_bill_to_customer_overridable IS
   SELECT project_id
    FROM  pa_project_copy_overrides
   WHERE  project_id = x_award_project_id
     AND  field_name = x_field_name;

l_project_id NUMBER;
x_msg_count NUMBER;
x_msg_data VARCHAR2(2000);
x_return_status VARCHAR2(1);

BEGIN

   OPEN c_bill_to_customer_overridable;
   FETCH c_bill_to_customer_overridable INTO l_project_id;
   CLOSE c_bill_to_customer_overridable;
   X_err_code := 'S';

   IF l_project_id IS NULL AND x_field_name = 'BILL_TO_CUSTOMER' THEN
      PA_PROJ_TEMPLATE_SETUP_PUB.ADD_QUICK_ENTRY_FIELD( p_api_version       => 1.0,
 							p_init_msg_list	    => FND_API.G_TRUE,
 							p_commit	    => FND_API.G_FALSE,
 							p_validate_only	    => FND_API.G_FALSE,
 							p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
 							p_calling_module    => 'FORM',
 							p_debug_mode	    => 'N',
 							p_max_msg_count	    => PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
 							p_project_id	    => x_award_project_id,
 							p_sort_order	    => 70,
 							p_field_name	    => 'BILL_TO_CUSTOMER',
 							p_field_meaning	    => 'Bill To Customer Name',
 							p_specification	    => 'Primary',
 							p_limiting_value    => 'Primary',
 							p_prompt	    => 'Bill To Customer Name',
 							p_required_flag	    => 'N',
 							x_return_status	    =>  x_return_status,
 							x_msg_count	    =>  x_msg_count,
 							x_msg_data	    =>  x_msg_data);

         --To be more precise, call appropriate exception handler
         IF x_Return_Status <> 'S' THEN
            X_Err_Code     :=   x_Return_Status;
            X_Err_Stage    :=   x_Msg_Data;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

   END IF;

   IF l_project_id IS NULL AND x_field_name = 'SHIP_TO_CUSTOMER' THEN
      PA_PROJ_TEMPLATE_SETUP_PUB.ADD_QUICK_ENTRY_FIELD( p_api_version       => 1.0,
                                                        p_init_msg_list     => FND_API.G_TRUE,
                                                        p_commit            => FND_API.G_FALSE,
                                                        p_validate_only     => FND_API.G_FALSE,
                                                        p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                                                        p_calling_module    => 'FORM',
                                                        p_debug_mode        => 'N',
                                                        p_max_msg_count     => PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,
                                                        p_project_id        => x_award_project_id,
                                                        p_sort_order        => 80,
                                                        p_field_name        => 'SHIP_TO_CUSTOMER',
                                                        p_field_meaning     => 'Ship To Customer Name',
                                                        p_specification     => 'Primary',
                                                        p_limiting_value    => 'Primary',
                                                        p_prompt            => 'Ship To Customer Name',
                                                        p_required_flag     => 'N',
                                                        x_return_status     =>  x_return_status,
                                                        x_msg_count         =>  x_msg_count,
                                                        x_msg_data          =>  x_msg_data);

         --To be more precise, call appropriate exception handler
         IF x_Return_Status <> 'S' THEN
            X_Err_Code      :=    x_Return_Status;
            X_Err_Stage     :=    x_Msg_Data;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

  END IF;
END;

PROCEDURE INSERT_AWARD_PROJECT(X_Customer_Id IN NUMBER,
		               X_Bill_to_customer_id IN NUMBER,
                               X_Award_Project_Name IN VARCHAR2,
			       X_Award_Project_Number IN VARCHAR2,
                               X_Award_Id IN NUMBER,
                               X_Carrying_Out_Organization_Id IN NUMBER,
                               X_IDC_Schedule_Id IN NUMBER,
                               X_IDC_Schedule_Fixed_Date IN DATE,
                               X_Labor_Invoice_Format_Id IN NUMBER,
                               X_Non_Labor_Invoice_Format_Id IN NUMBER,
                               X_Start_Date IN DATE,
                               X_End_Date IN DATE,
			       X_Close_Date IN DATE,
                               X_Person_Id IN NUMBER,
  			       X_Billing_Frequency IN VARCHAR2,
                               X_Billing_cycle_id  IN NUMBER,
                               X_Billing_offset    IN NUMBER,
                               X_Award_Project_Id OUT NOCOPY NUMBER,
			       X_Bill_To_Address_Id OUT NOCOPY NUMBER,
			       X_Ship_To_Address_Id OUT NOCOPY NUMBER,
                               X_App_Short_Name OUT NOCOPY VARCHAR2,
                               X_Err_Code  OUT NOCOPY VARCHAR2,
                               X_Err_Stage OUT NOCOPY VARCHAR2)  IS

  X_Product_Code             VARCHAR2(30)    ;
  X_Msg_Data                 VARCHAR2(2000)  ;
  X_Index                    NUMBER(15)      ;
  X_Text                     VARCHAR2(2000)  := NULL;
  --X_App_Short_Name         VARCHAR2(30)    ;

  l_bill_to_address_id       NUMBER(15)      ;
  l_ship_to_address_id       NUMBER(15)      ;
  l_bill_to_contact_id       NUMBER(15)      ;
  l_ship_to_contact_id       NUMBER(15)      ;
  l_err_code                 NUMBER          ;
  l_err_stage                VARCHAR2(200)   ;
  l_err_stack                VARCHAR2(200)   ;
  P_Return_Status            VARCHAR2(1)     ;
  X_Created_From_Project_Id  NUMBER(15)      := 1045;
  l_output_tax_code          VARCHAR2(300)   ;
  l_retention_tax_code       VARCHAR2(300)   ;
  St_Award_Project_Id        NUMBER(15)      ;

-- Bug fix 1563183
--Changes done inv_currency_code as suggested by sakthi
l_project_currency_code varchar2(10) :=  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR;

St_Billing_Cycle    NUMBER(15);
St_Billing_Offset   NUMBER(15);

X_Project_IN_REC          PA_PROJECT_PUB.PROJECT_IN_REC_TYPE;
X_Project_OUT_REC         PA_PROJECT_PUB.PROJECT_OUT_REC_TYPE;
X_Key_Members_IN_REC      PA_PROJECT_PUB.PROJECT_ROLE_REC_TYPE;
X_Key_Members_IN_TBL      PA_PROJECT_PUB.PROJECT_ROLE_TBL_TYPE;
X_Class_Categories_IN_TBL PA_PROJECT_PUB.CLASS_CATEGORY_TBL_TYPE;
X_Tasks_IN_REC            PA_PROJECT_PUB.TASK_IN_REC_TYPE;
X_Tasks_In_TBL            PA_PROJECT_PUB.TASK_IN_TBL_TYPE;
X_Tasks_Out_TBL           PA_PROJECT_PUB.TASK_OUT_TBL_TYPE;

X_Workflow_Started VARCHAR2(1);

/*** Bug 3576717 **/
X_Deliverable_IN_TBL          PA_PROJECT_PUB.DELIVERABLE_IN_TBL_TYPE;

-- Bug 3650374
--X_Deliverable_OUT_TBL         PA_PROJECT_PUB.DELIVERABLE_OUT_TBL_TYPE;
--X_Deliverable_Action_OUT_TBL  PA_PROJECT_PUB.ACTION_OUT_TBL_TYPE;

X_Deliverable_Action_IN_TBL   PA_PROJECT_PUB.ACTION_IN_TBL_TYPE;

x_default_org_id  VARCHAR2(15);
--Start Bug Fix 1656812
X_Manager_Start_Date DATE;
X_Manager_End_Date  DATE;

-- Bug Fix 2994625
-- PA.K roll up has additional parameters in get_customer_info
-- declaring local variables for the same.
--
-- Need to pass NULL for the ship to customer as we did not mark it overridable
-- in the award project tempalte. Because of this Bug 3049266 is happening.
-- So passing NULL value to skip the error causing validation in the create_project procedure
-- in the pa_project_pub API.

l_bill_to_customer_id PA_PROJECT_CUSTOMERS.BILL_TO_CUSTOMER_ID%TYPE := X_BILL_TO_CUSTOMER_ID ;
l_ship_to_customer_id PA_PROJECT_CUSTOMERS.SHIP_TO_CUSTOMER_ID%TYPE := X_BILL_TO_CUSTOMER_ID ;

l_api_name     CONSTANT VARCHAR2(30) := 'INSERT_AWARD_PROJECT';

Cursor manager_active IS
         SELECT START_DATE_ACTIVE,
                END_DATE_ACTIVE
         FROM   gms_personnel
         WHERE  award_id = X_Award_Id
         AND    award_role ='AM'; --For Bug 3229539

--For Bug 3229539 : Commented the below check as it does not eturn any rows for  future award start date
       --  AND    SYSDATE
      --          BETWEEN NVL (Start_Date_Active, SYSDATE-1)
     --    AND     NVL (End_Date_Active, SYSDATE+1);
--END Bug fix 1656812


BEGIN
  G_Stage := '(500:Select from gms_implementations)';
---------------------------------------------------
/* Getting Org Id */

  /* Getting the Default Organization Id */

  select
  to_char(nvl(org_id,-999))
  INTO
  x_default_org_id
  FROM
  gms_implementations;

  --Shared Service Enhancement :
  --Setting Org Context
  MO_GLOBAL.SET_POLICY_CONTEXT('S',x_default_org_id);
  --End of Shared Service Enhancement

-------------------------------------------------

--Start Bug fix 1656812
open    manager_active;
fetch   manager_active
INTO   X_Manager_Start_Date, X_Manager_End_Date;
close  manager_active;
--END Bug Fix 1656812


  --dbms_output.put_line('Inside Insert Award Project ');
  /* Get Billing Cycle FROM Billing Frequency
    BEGIN
       St_Billing_Offset := 0;
       SELECT decode(X_Billing_Frequency,'ANNUALLY',365,'DAILY',1,'MONTHLY',30,'QUARTERLY',91,'WEEKLY',7)
       INTO   St_Billing_Cycle
       FROM   dual;
       --dbms_output.put_line('B Cycle '||St_Billing_Cycle);
       --dbms_output.put_line('B Offset '||St_Billing_Offset);
    END;
 */

    G_Stage := '(510:Select from pa_projects)';
    St_Billing_Offset := nvl(X_billing_offset,0)  ;
 /* Get X_Created_From_Project_Id */

    BEGIN

     /* Bug Fix 2447491:
     ** After upgrading to multi org FROM non multi org, the award project
     ** template will still have segment1 'AWD_PROJ_-999. To use the template
     ** the code is modified.
     **/
     SELECT project_id
     INTO   X_Created_From_Project_Id
     FROM   PA_PROJECTS
     WHERE  project_type = 'AWARD_PROJECT'
     AND    template_flag = 'Y'
     AND   (segment1 = 'AWD_PROJ_'||x_default_org_id
     OR     segment1 = 'AWD_PROJ_-999');

     X_Err_Code := 'S';
     EXCEPTION
          WHEN OTHERS THEN
            X_Err_Code  := 'U';
            X_App_Short_Name := 'GMS';
            FND_MESSAGE.SET_NAME('GMS','GMS_UNEXPECTED_ERROR');
            FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_MULTI_FUNDING: INSERT_AWARD_PROJECT');
            FND_MESSAGE.SET_TOKEN('OERRNO',SQLCODE);
            FND_MESSAGE.SET_TOKEN('OERRM',SQLERRM);
            FND_MSG_PUB.add;
            FND_MSG_PUB.Count_And_Get(p_count  => p_msg_count,
                                      p_data   => X_Err_Stage);
            RAISE FND_API.G_EXC_ERROR;
    END;

   G_Stage := '(520:Calling create_awd_proj_template_struc)';

-- Bug Fix for Bug 3002270
-- Need to verify and create a structure for the award project template.
-- by calling the CREATE_AWD_PROJ_TEMPLATE_STRUC.

   CREATE_AWD_PROJ_TEMPLATE_STRUC
                      (x_award_project_id => X_Created_From_Project_Id
                      ,X_Err_Code         => p_Return_Status
                      ,X_Err_Stage        => x_err_stage);

         IF p_Return_Status <> 'S' THEN
            X_Err_Code  := p_return_status;
            X_Err_Stage := X_Err_Stage;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

-- END of Bug Fix for Bug 3002270

-- Bug Fix for Bug 3049266
-- Need to mark the columns BILL_TO_CUSTOMER and SHIP_TO_CUSTOMER as overridable
-- The following procedure will check if these columns are overridable or not.
-- IF not THEN the corresponding record will be inserted INTO pa_project_copy_overrides
-- table.

   G_Stage := '(530:Calling mark_fields_as_overridable)';
   MARK_FIELDS_AS_OVERRIDABLE
                  (x_award_project_id => x_created_FROM_project_id
                  ,x_field_name       => 'BILL_TO_CUSTOMER'
		  ,x_err_code         => x_err_code
		  ,x_err_stage        => x_err_stage);

         IF x_err_code <> 'S' THEN
            X_Err_Code  := X_err_code;
            X_Err_Stage := X_Err_Stage;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         G_Stage := '(540:Calling mark_fields_as_overridable)';
         MARK_FIELDS_AS_OVERRIDABLE
                 (x_award_project_id => x_created_FROM_project_id
                 ,x_field_name       => 'SHIP_TO_CUSTOMER'
                 ,x_err_code         => x_err_code
                 ,x_err_stage        => x_err_stage);

         --To be more precise, call appropriate exception handler
         IF x_err_code <> 'S' THEN
            X_Err_Code  := X_err_code;
            X_Err_Stage := X_Err_Stage;
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         G_Stage := '(550:Before Initializing the Tables)';
      /* Initializing the Tables */
         X_Product_Code                                := 'GMS';
         X_Project_IN_REC.PM_PROJECT_REFERENCE         := X_Award_Project_Number;
         X_Project_IN_REC.PA_PROJECT_NUMBER            := X_Award_Project_Number;
         X_Project_IN_REC.PROJECT_NAME                 := X_Award_Project_Name;
         X_Project_IN_REC.CREATED_FROM_PROJECT_ID      := X_Created_From_Project_Id;
         X_Project_IN_REC.CARRYING_OUT_ORGANIZATION_ID := X_Carrying_Out_Organization_Id;
         X_Project_IN_REC.CUSTOMER_ID                  := X_Customer_Id;
         X_Project_IN_REC.START_DATE                   := X_Start_Date;
         X_Project_IN_REC.COMPLETION_DATE              := X_End_Date;
         X_Project_IN_REC.DISTRIBUTION_RULE            := 'EVENT/EVENT';
         X_Project_IN_REC.PROJECT_RELATIONSHIP_CODE    := 'PRIMARY';
         X_Project_IN_REC.OUTPUT_TAX_CODE              := l_output_tax_code;
         X_Project_IN_REC.RETENTION_TAX_CODE           := l_retention_tax_code;
         X_Project_IN_REC.LONG_NAME 		       := X_Award_Project_Name; -- added Bug 2716865
         X_Project_IN_REC.DESCRIPTION 	               := null;                 -- added Bug 2716865

     --Bug fix 1563183
     --Changes done inv_currency_code as suggested by sakthi
         X_Project_IN_REC.PROJECT_CURRENCY_CODE        := l_project_currency_code;

         X_Key_Members_IN_REC.PERSON_ID                := X_Person_Id;
         X_Key_Members_IN_REC.PROJECT_ROLE_TYPE        := 'PROJECT MANAGER';
         X_Key_Members_IN_REC.START_DATE               := X_Manager_Start_Date;        --Bug fix 1656812
         X_Key_Members_IN_REC.END_DATE                 := X_Manager_End_Date;          --Bug fix 1656812

         X_Key_Members_IN_TBL(1)                       := X_Key_Members_IN_REC;

         X_Tasks_IN_REC.task_name                      := X_Award_Project_Number||'-'||'Tsk1'; --X_Task_Name;
         X_Tasks_IN_REC.TASK_START_DATE                := X_Start_Date;
         X_Tasks_IN_REC.TASK_COMPLETION_DATE           := X_End_Date;
         X_Tasks_IN_REC.pa_task_number                 := X_Award_Project_Number||'-'||'T1';    --X_Task_Number;
         X_Tasks_IN_REC.cost_ind_rate_sch_id           := X_IDC_Schedule_Id;
         X_Tasks_IN_REC.pm_task_reference              := X_Award_Project_Number;
         X_Tasks_IN_REC.chargeable_flag                := 'N';
         X_Tasks_In_TBL(1)                             := X_Tasks_IN_REC;

 ---------------------------------------------------------------------------------------

 /* API To get customer info */

 -- Bug 1672982
-- Bug Fix 2994625. PA.K roll up patch has get_customer_info with additional parameters.
-- Adding these additional parameters to the call.

    G_Stage := '(560:Calling pa_customer_info.get_customer_info)';
    PA_CUSTOMER_INFO.GET_CUSTOMER_INFO(
         X_PROJECT_ID           =>      NULL,
	 X_CUSTOMER_ID          =>      X_Customer_Id,
 	 X_BILL_TO_CUSTOMER_ID  => 	l_bill_to_customer_id,
 	 X_SHIP_TO_CUSTOMER_ID  => 	l_ship_to_customer_id,
	 X_BILL_TO_ADDRESS_ID 	=>	l_bill_to_address_id,
	 X_SHIP_TO_ADDRESS_ID 	=>	l_ship_to_address_id,
	 X_BILL_TO_CONTACT_ID 	=>	l_bill_to_contact_id,
	 X_SHIP_TO_CONTACT_ID 	=>	l_ship_to_contact_id,
	 X_ERR_CODE           	=>	l_err_code,
	 X_ERR_STAGE          	=>	l_err_stage,
	 X_ERR_STACK          	=>	l_err_stack );

         --dbms_output.put_line('err code '||l_err_code||' err stage '||l_err_stage);
         --dbms_output.put_line('Got here !!!!!!!!!!!!!');
      /* Call PROJECT API to create Award Project and One Top Task */

      /* Passing out NOCOPY Bill_To_Address_Id and Ship_To_Address_Id */
        X_Bill_To_Address_Id := l_bill_to_address_id;
        X_Ship_To_Address_Id := l_ship_to_address_id;

        -- Bug Fix 2994625. Load the Table
        X_PROJECT_IN_REC.BILL_TO_CUSTOMER_ID := X_BILL_TO_CUSTOMER_ID;
        X_PROJECT_IN_REC.SHIP_TO_CUSTOMER_ID := X_BILL_TO_CUSTOMER_ID;

           G_Stage := '(570:Calling pa_project_pub.create_project)';
           PA_PROJECT_PUB.CREATE_PROJECT(p_api_version_number      => 1.0,
                                         p_init_msg_list           => 'T',
                                         p_msg_count               => p_msg_count,
                                         p_msg_data                => X_Msg_Data,
                                         p_return_status           => P_Return_Status,
                                         p_project_in              => X_Project_IN_REC,
                                         p_project_out             => X_Project_OUT_REC,
                                         p_pm_product_code         => X_Product_Code,
                                         p_key_members             => X_Key_Members_IN_TBL,
                                         p_class_categories        => X_Class_Categories_IN_TBL,
                                         p_tasks_in                => X_Tasks_IN_TBL,
                                         p_tasks_out               => X_Tasks_OUT_TBL,
					 p_workflow_started        => X_Workflow_Started,
					 p_commit                  => FND_API.G_FALSE,
                                     /** Bug 3576717 **/
                                         P_deliverables_in         => X_Deliverable_IN_TBL,
                                         --P_deliverables_out        => X_Deliverable_OUT_TBL, (3650374)
                                         P_deliverable_actions_in  => X_Deliverable_Action_IN_TBL
                                         --P_deliverable_actions_out => X_Deliverable_Action_OUT_TBL (3650374)
                                         );
    --dbms_output.put_line('AJ03 - PA Project PUB after ');
    --dbms_output.put_line('Return Status '||P_Return_Status);

         G_Stage := '(580:After pa_project_pub.create_project call)';

         X_Err_Code             := P_Return_Status;

         IF P_Return_Status <> 'S' THEN
            X_Err_Stage         := X_Msg_Data;
            RAISE FND_API.G_EXC_ERROR;
         ELSE
            X_Award_Project_Id  := X_Project_OUT_REC.PA_PROJECT_ID;
         END IF;

  --dbms_output.put_line('Project Id '||X_Project_OUT_REC.pa_project_id);

  St_Award_Project_Id := X_Project_OUT_REC.pa_project_id;

  --dbms_output.put_line('Project Id is '||St_Award_Project_Id);
  --dbms_output.put_line('Schedule Id is '||X_IDC_Schedule_Id);
  --dbms_output.put_line('Date is '||to_char(X_IDC_Schedule_Fixed_Date));
  --dbms_output.put_line('Labor Inv Fmt Id '||X_Labor_Invoice_Format_Id);
  --dbms_output.put_line('Non LAbor Inv Fmt Id '||X_Non_Labor_INvoice_Format_Id);
  --dbms_output.put_line('St_Billing Cycle '||X_Billing_Cycle_Id);
  --dbms_output.put_line('St_Billing Offset '||X_Billing_Offset);

      G_Stage := '(590:Calling update_project_add_info)';
      update_project_add_info(St_Award_Project_Id,
                              X_IDC_Schedule_Id,
                              X_IDC_Schedule_Fixed_Date,
                              X_Labor_Invoice_Format_Id,
                              X_Non_Labor_Invoice_Format_Id,
                              X_Billing_Cycle_id,
                              X_Billing_Offset,
		              P_Return_Status,
                              X_Msg_Data);

            X_Err_Code      := P_Return_Status;
            IF P_Return_Status <> 'S' THEN
               X_Err_Stage  := X_Msg_Data;
               RAISE FND_API.G_EXC_ERROR;
            END IF;

           --dbms_output.put_line('Project_Id is '||to_char(X_Project_OUT_REC.PA_PROJECT_ID) );
           --dbms_output.put_line('Return Code is '||P_Return_Status);


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
         X_Award_Project_Id  := -1;
        --dbms_output.put_line('The Count From API is '||X_Msg_Count);
        --dbms_output.put_line('Message Name is '||X_Text);
                     -- X_Err_Code      := P_Return_Status;
                     -- X_Err_Stage     := X_Text;
                     -- X_Err_Stage     := X_Msg_Data;
       RETURN;

-- Added when OTHERS exception for Bug:2662848
  WHEN OTHERS THEN
         x_err_code := 'U';
	 FND_MSG_PUB.add_exc_msg
	  (  p_pkg_name		=> G_PKG_NAME
	    ,p_procedure_name	=> l_api_name
            ,p_error_text       => substrb(SQLERRM||' at stage='||g_stage||' ',1,240)
           );
         FND_MSG_PUB.Count_And_Get
          ( p_count             => p_msg_count
           ,p_data              => X_Err_Stage
          );
         x_err_stage := SQLERRM||' at stage='||g_stage;
  	 RAISE; --keeping as is

END INSERT_AWARD_PROJECT;

PROCEDURE GET_PROJ_START_AND_END_DATE(X_Installment_Id IN NUMBER,
                                      X_Award_Id OUT NOCOPY NUMBER,
                                      X_Award_Project_Id  OUT NOCOPY NUMBER,
                                      X_Project_Start_Date OUT NOCOPY DATE,
                                      X_Project_End_Date OUT NOCOPY DATE,
                                      X_Agreement_Id OUT NOCOPY NUMBER,
                                      X_Err_Code OUT NOCOPY VARCHAR2,
                                      X_Err_Stage OUT NOCOPY VARCHAR2)  IS
Store_Project_Id         NUMBER(15);
Store_Project_Start_Date DATE;
Store_Project_End_Date   DATE;
Store_Award_Id           NUMBER(15);
Store_Agreement_Id       NUMBER(15);

--p_msg_count  NUMBER;
BEGIN
          SELECT
          a.project_id, --Award Project Id for which funding is to be created
          a.start_date,
          nvl(a.completion_date,sysdate),
          b.award_id,
          b.agreement_id
          INTO
          Store_Project_Id,
          Store_Project_Start_Date,
          Store_Project_End_Date,
          Store_Award_Id,
          Store_Agreement_Id
          FROM
          PA_PROJECTS a,
          GMS_AWARDS b,
          GMS_INSTALLMENTS c
          WHERE
            c.installment_id = X_Installment_Id and
            b.Award_Id       = c.Award_Id and
            a.project_id     = b.award_project_id;

               X_Err_Code := 'S';
               X_Award_Id             := Store_Award_Id;
               X_Award_Project_Id     := Store_Project_Id;
               X_Project_Start_Date   := Store_Project_Start_Date;
               X_Project_End_Date     := Store_Project_End_Date ;
               X_Agreement_Id         := Store_Agreement_Id;

              EXCEPTION
                 WHEN NO_DATA_FOUND THEN
                       X_Err_Code := 'E';
                       X_Err_Stage := 'No Award Project Id found for the Installment '||to_char(X_Installment_Id);

                       X_Err_Stage := 'GMS_NO_AWDPRJ_ID_FOR_INST_ID';
                       FND_MESSAGE.SET_NAME('GMS','GMS_NO_AWDPRJ_ID_FOR_INST_ID');
                       FND_MESSAGE.SET_TOKEN('INSTALLMENT_ID',to_char(X_Installment_Id));
                       FND_MSG_PUB.add;
                       FND_MSG_PUB.Count_And_Get
                                   ( p_count  =>  p_msg_count,
                                     p_data   =>  X_Err_Stage);

                 WHEN OTHERS THEN
                       X_Err_Code := 'U';
                       X_Err_Stage := SQLERRM;

                       X_Err_Stage := 'GMS_UNEXPECTED_ERROR';
                       FND_MESSAGE.SET_NAME('GMS','GMS_UNEXPECTED_ERROR');
                       FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_MULTI_FUNDING: PROJ_START_AND_END_DATE');
                       FND_MESSAGE.SET_TOKEN('OERRNO',SQLCODE);
                       FND_MESSAGE.SET_TOKEN('OERRM',SQLERRM);
                       FND_MSG_PUB.add;
                       FND_MSG_PUB.Count_And_Get
                                   ( p_count   =>   p_msg_count,
                                     p_data    =>   X_Err_Stage );

END GET_PROJ_START_AND_END_DATE;

PROCEDURE INSERT_DETAIL_PROJECT_FUNDING(X_Project_Funding_Id IN NUMBER,
                                        X_Agreement_Id IN NUMBER,
              		                X_Award_Project_Id IN NUMBER,
              		                X_Allocated_Amount IN NUMBER,
               		                X_Date_Allocated IN DATE,
               		                X_Err_Code OUT NOCOPY VARCHAR2,
               		                X_Err_Stage OUT NOCOPY VARCHAR2) IS

--p_msg_count NUMBER;

x_currency_code pa_project_fundings.funding_currency_code%type := pa_currency.get_currency_code;  -- Bug 2475640 : Added for 11.5 PA-J certification.

BEGIN
  INSERT INTO PA_PROJECT_FUNDINGS(PROJECT_FUNDING_ID,
                                  AGREEMENT_ID,
                                  PROJECT_ID,
                                  BUDGET_TYPE_CODE,
                                  ALLOCATED_AMOUNT,
                                  DATE_ALLOCATED,
				  -- Bug 2475640 : Added for 11.5 PA-J certification.
				  FUNDING_CURRENCY_CODE,
		                  PROJECT_CURRENCY_CODE,
		                  PROJFUNC_CURRENCY_CODE,
		                  INVPROC_CURRENCY_CODE,
		                  REVPROC_CURRENCY_CODE,
			          PROJECT_ALLOCATED_AMOUNT,
		                  PROJFUNC_ALLOCATED_AMOUNT,
		                  INVPROC_ALLOCATED_AMOUNT,
		                  REVPROC_ALLOCATED_AMOUNT,
				  -- Bug 2475640 changes End
 				  LAST_UPDATE_DATE,
                                  LAST_UPDATED_BY,
                                  CREATION_DATE,
                                  CREATED_BY,
                                  LAST_UPDATE_LOGIN)
                       VALUES(X_Project_Funding_Id,
                              X_Agreement_Id,
                              X_Award_Project_Id,
                              'DRAFT',
                              X_Allocated_Amount,
                              X_Date_Allocated,
			     -- Bug 2475640 : Added for 11.5 PA-J certification.
			      x_currency_code,
			      x_currency_code,
			      x_currency_code,
			      x_currency_code,
			      x_currency_code,
                              X_Allocated_Amount,
                              X_Allocated_Amount,
                              X_Allocated_Amount,
                              X_Allocated_Amount,
			      -- Bug 2475640 Changes End
			      SYSDATE,
         		      fnd_global.user_id,
         		      SYSDATE ,
         		      fnd_global.user_id,
        		      fnd_global.login_id);

	 -- Bug 2475640 : Added Following UPDATE statement to UPDATE funding_category

	UPDATE pa_project_fundings proj
	   SET funding_category = 'ORIGINAL'
	 WHERE proj.project_funding_id IN (SELECT min(project_funding_id)
		                             FROM pa_project_fundings
					    WHERE project_id = X_award_project_id
					      AND agreement_id = X_agreement_id
				         GROUP BY agreement_id,project_id,NVL(task_id,0))
	   AND proj.project_funding_id = X_Project_Funding_Id
	   AND funding_category is null;


	UPDATE pa_project_fundings
	   SET funding_category='ADDITIONAL'
	 WHERE funding_category is null
  	   AND project_funding_id = X_Project_Funding_Id;


              X_Err_Code :=  'S';
                  EXCEPTION
                   WHEN DUP_VAL_ON_INDEX  THEN
                        X_Err_Code := 'U';
                        X_Err_Stage := SQLERRM;

                        X_Err_Stage := 'GMS_UNEXPECTED_ERROR';
                        FND_MESSAGE.SET_NAME('GMS','GMS_UNEXPECTED_ERROR');
                        FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_MULTI_FUNDING: INSERT_DETAIL_PROJECT_FUNDING - 1');
                        FND_MESSAGE.SET_TOKEN('OERRNO',SQLCODE);
                        FND_MESSAGE.SET_TOKEN('OERRM',SQLERRM);
                        FND_MSG_PUB.add;
                        FND_MSG_PUB.Count_And_Get
                                (   p_count             =>      p_msg_count     ,
                                    p_data              =>      X_Err_Stage      );
                   WHEN OTHERS THEN
                        X_Err_Code := 'U';
                        X_Err_Stage := SQLERRM;
                        X_Err_Stage := 'GMS_UNEXPECTED_ERROR';
                        FND_MESSAGE.SET_NAME('GMS','GMS_UNEXPECTED_ERROR');
                        FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_MULTI_FUNDING: INSERT_DETAIL_PROJECT_FUNDING - 2');
                        FND_MESSAGE.SET_TOKEN('OERRNO',SQLCODE);
                        FND_MESSAGE.SET_TOKEN('OERRM',SQLERRM);
                        FND_MSG_PUB.add;
                        FND_MSG_PUB.Count_And_Get
                                (   p_count             =>      p_msg_count     ,
                                    p_data              =>      X_Err_Stage      );

END INSERT_DETAIL_PROJECT_FUNDING;

FUNCTION  ROW_EXISTS_IN_PA_SUMM_FUNDING(X_Agreement_Id IN NUMBER,
                        X_Award_Project_Id     IN NUMBER,
                        X_Err_Code            OUT NOCOPY VARCHAR2,
                        X_Err_Stage           OUT NOCOPY VARCHAR2) RETURN BOOLEAN
                                        IS
        Summary_Funding_Check NUMBER(15) := 0;
        --p_msg_count   NUMBER;
BEGIN
    BEGIN
     SELECT 1
       INTO Summary_Funding_Check
       FROM PA_SUMMARY_PROJECT_FUNDINGS
      WHERE Agreement_Id  = X_Agreement_Id
        AND Project_Id = X_Award_Project_Id;

            X_Err_Code := 'S';
            RETURN TRUE;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
               X_Err_Code := 'S';
               RETURN FALSE;
          WHEN TOO_MANY_ROWS THEN
               X_Err_Code := 'E';
               X_Err_Stage := 'There is more than one row for the Agreement '||to_char(X_Agreement_Id)||' and the Award Project '||to_char(X_Award_Project_Id);
               X_Err_Stage := 'GMS_SUMM_FUNDING_NOT_UNIQUE';
               FND_MESSAGE.SET_NAME('GMS','GMS_SUMM_FUNDING_NOT_UNIQUE');
               FND_MESSAGE.SET_TOKEN('AGREEMENT_ID',X_Agreement_Id);
               FND_MESSAGE.SET_TOKEN('AWARD_PROJECT_ID',X_Award_Project_Id);
               FND_MSG_PUB.add;
               FND_MSG_PUB.Count_And_Get
                       (   p_count             =>      p_msg_count     ,
                           p_data              =>      X_Err_Stage      );
               RETURN FALSE;
          WHEN OTHERS THEN
               X_Err_Code := 'U';
               X_Err_Stage := (SQLCODE||' '||SQLERRM);

               X_Err_Stage := 'GMS_UNEXPECTED_ERROR';
               FND_MESSAGE.SET_NAME('GMS','GMS_UNEXPECTED_ERROR');
               FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_MULTI_FUNDING: ROW_EXISTS_IN_PA_SUMM_FUNDING');
               FND_MESSAGE.SET_TOKEN('OERRNO',SQLCODE);
               FND_MESSAGE.SET_TOKEN('OERRM',SQLERRM);
               FND_MSG_PUB.add;
               FND_MSG_PUB.Count_And_Get
                       (   p_count             =>      p_msg_count     ,
                           p_data              =>      X_Err_Stage      );
               RETURN FALSE;
    END;
END ROW_EXISTS_IN_PA_SUMM_FUNDING;

PROCEDURE GET_TOTAL_FUNDING_BUDGET(X_Award_Project_Id IN NUMBER,
                                   X_Total_Funding_Budget OUT NOCOPY NUMBER,
                                   X_Err_Code OUT NOCOPY VARCHAR2,
                                   X_Err_Stage OUT NOCOPY VARCHAR2) IS

St_Total_Baselined_Amount NUMBER(22,5) := 0;
St_Total_Unbaselined_Amount NUMBER(22,5) := 0;
--p_msg_count   NUMBER;

BEGIN
       BEGIN
          SELECT
          nvl(sum(nvl(total_unbaselined_amount,0)),0),
          nvl(sum(nvl(total_baselined_amount,0)),0)
          INTO
          St_Total_Unbaselined_Amount ,
          St_Total_Baselined_Amount
          FROM
          PA_SUMMARY_PROJECT_FUNDINGS
          WHERE
          Project_Id = X_Award_Project_Id;
       END;
             X_Err_Code := 'S';
             X_Total_Funding_Budget := St_Total_Unbaselined_Amount + St_Total_Baselined_Amount;
         EXCEPTION
             WHEN NO_DATA_FOUND THEN
                   X_Err_Code := 'S';
             WHEN OTHERS THEN
                   X_Err_Code := 'U';
                   X_Err_Stage := 'GMS_UNEXPECTED_ERROR';
                   FND_MSG_PUB.add;
                   FND_MESSAGE.SET_NAME('GMS','GMS_UNEXPECTED_ERROR');
                   FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_MULTI_FUNDING: GET_TOTAL_FUNDING_BUDGET');
                   FND_MESSAGE.SET_TOKEN('OERRNO',SQLCODE);
                   FND_MESSAGE.SET_TOKEN('OERRM',SQLERRM);
                   FND_MSG_PUB.add;
                   FND_MSG_PUB.Count_And_Get
                        (   p_count             =>      p_msg_count     ,
                            p_data              =>      X_Err_Stage      );
END GET_TOTAL_FUNDING_BUDGET;

PROCEDURE  GET_TOTAL_FUNDING_AMOUNT(X_Agreement_Id IN NUMBER,
                                    X_Award_Project_Id IN NUMBER,
                                    X_Total_Unbaselined_Amount OUT NOCOPY NUMBER,
                                    X_Total_Baselined_Amount OUT NOCOPY NUMBER,
                                    X_Err_Code OUT NOCOPY VARCHAR2,
                                    X_Err_Stage OUT NOCOPY VARCHAR2) IS
        St_Total_Unbaselined_Amount NUMBER(22,5) := 0;
        St_Total_Baselined_Amount NUMBER(22,5) := 0;
       -- p_msg_count    NUMBER;
       BEGIN
           SELECT nvl(total_unbaselined_amount,0),
                  nvl(total_baselined_amount,0)
             INTO St_Total_Unbaselined_Amount ,
                  St_Total_Baselined_Amount
             FROM PA_SUMMARY_PROJECT_FUNDINGS
            WHERE Agreement_id = X_Agreement_Id
              AND Project_Id = X_Award_Project_Id;

                X_Err_Code := 'S';
                X_Total_Unbaselined_Amount := St_Total_Unbaselined_Amount;
                X_Total_Baselined_Amount := St_Total_Baselined_Amount;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   X_Err_Code := 'E';
                   X_Err_Stage := 'No row found in PA_SUMMARY_PROJECT_FUNDING for Project '||to_char(X_Award_Project_Id)||' and Agreement '||to_char(X_Agreement_Id);

                   FND_MESSAGE.SET_NAME('GMS','GMS_NO_PA_SUMM_FUNDING');
                   FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_MULTI_FUNDING: GET_TOTAL_FUNDING_AMOUNT');
                   FND_MESSAGE.SET_TOKEN('AGREEMENT_ID',X_Agreement_Id);
                   FND_MESSAGE.SET_TOKEN('AWARD_PROJECT_ID',X_Award_Project_Id);
                   FND_MSG_PUB.add;
                   FND_MSG_PUB.Count_And_Get
                           ( p_count     =>  p_msg_count,
                             p_data      =>  X_Err_Stage  );

              WHEN OTHERS THEN

                  X_Err_Code  := 'U';
                  X_Err_Stage := 'GMS_UNEXPECTED_ERROR';
                 -- FND_MSG_PUB.add;
                  FND_MESSAGE.SET_NAME('GMS','GMS_UNEXPECTED_ERROR');
                  FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_MULTI_FUNDING: GET_TOTAL_FUNDING_BUDGET');
                  FND_MESSAGE.SET_TOKEN('OERRNO',SQLCODE);
                  FND_MESSAGE.SET_TOKEN('OERRM',SQLERRM);
                  FND_MSG_PUB.add;
                  FND_MSG_PUB.Count_And_Get
                          (   p_count             =>      p_msg_count     ,
                              p_data              =>      X_Err_Stage      );

END GET_TOTAL_FUNDING_AMOUNT;

PROCEDURE UPDATE_PA_SUMM_PROJECT_FUNDING(X_Agreement_Id IN NUMBER,
                                         X_Award_Project_Id IN NUMBER,
                                         X_Total_Unbaselined_Amount IN NUMBER,
                                         X_Err_Code OUT NOCOPY VARCHAR2,
                                         X_Err_Stage OUT NOCOPY VARCHAR2) IS
--p_msg_count NUMBER;
BEGIN
      UPDATE PA_SUMMARY_PROJECT_FUNDINGS
         SET TOTAL_UNBASELINED_AMOUNT = X_Total_Unbaselined_Amount,
	    -- Bug 2475640 : Added for 11.5 PA-J certification.
            PROJECT_UNBASELINED_AMOUNT = X_Total_Unbaselined_Amount,
            PROJFUNC_UNBASELINED_AMOUNT = X_Total_Unbaselined_Amount,
	    INVPROC_UNBASELINED_AMOUNT = X_Total_Unbaselined_Amount,
            REVPROC_UNBASELINED_AMOUNT = X_Total_Unbaselined_Amount,
    	    -- Bug 2475640 changes End
            LAST_UPDATE_DATE = SYSDATE,
            LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
            LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
      WHERE AGREEMENT_ID = X_Agreement_Id
        AND PROJECT_ID = X_Award_Project_Id;

            X_Err_Code := 'S';

            IF SQL%NOTFOUND THEN
               X_Err_Code := 'E';
               X_Err_Stage := 'Could not find a row to UPDATE for Agreement ' ||to_char(X_Agreement_Id)||' and Project '||to_char(X_Award_Project_Id);
             X_Err_Stage := 'GMS_NO_PA_SUMM_FUNDING';
             --FND_MSG_PUB.add;
             FND_MESSAGE.SET_NAME('GMS','GMS_NO_PA_SUMM_FUNDING');
             FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_MULTI_FUNDING: UPDATE_PA_SUMM_PROJECT_FUNDING');
             FND_MESSAGE.SET_TOKEN('AGREEMENT_ID',X_Agreement_Id);
             FND_MESSAGE.SET_TOKEN('AWARD_PROJECT_ID',X_Award_Project_Id);
             FND_MSG_PUB.add;
             FND_MSG_PUB.Count_And_Get
                     (   p_count             =>      p_msg_count     ,
                         p_data              =>      X_Err_Stage      );
            END IF;

END UPDATE_PA_SUMM_PROJECT_FUNDING;

PROCEDURE INSERT_SUMMARY_PROJECT_FUNDING(X_Agreement_Id IN NUMBER,
                                         X_Award_Project_Id IN NUMBER,
                                         X_Total_Unbaselined_Amount IN NUMBER,
                                         X_Err_Code OUT NOCOPY VARCHAR2,
                                         X_Err_Stage OUT NOCOPY VARCHAR2) IS
--p_msg_count NUMBER;


x_currency_code pa_summary_project_fundings.funding_currency_code%type := pa_currency.get_currency_code;	-- Bug 2475640 : Added for 11.5 PA-J certification.

BEGIN
INSERT INTO
PA_SUMMARY_PROJECT_FUNDINGS(AGREEMENT_ID,
                            PROJECT_ID,
                            TOTAL_UNBASELINED_AMOUNT,
			    -- Bug 2475640 : Added for 11.5 PA-J certification.
			    FUNDING_CURRENCY_CODE,
		            PROJECT_CURRENCY_CODE,
	                    PROJFUNC_CURRENCY_CODE,
			    INVPROC_CURRENCY_CODE,
			    REVPROC_CURRENCY_CODE,
                            PROJECT_UNBASELINED_AMOUNT,
	                    PROJFUNC_UNBASELINED_AMOUNT,
			    INVPROC_UNBASELINED_AMOUNT,
                            REVPROC_UNBASELINED_AMOUNT,
			    -- Bug 2475640 Changes END
 			    LAST_UPDATE_DATE,
                            LAST_UPDATED_BY,
                            CREATION_DATE,
                            CREATED_BY,
                            LAST_UPDATE_LOGIN)
                     VALUES(X_Agreement_Id,
                            X_Award_Project_Id,
                            X_Total_Unbaselined_Amount,
			    -- Bug 2475640 : Added for 11.5 PA-J certification.
			    x_currency_code,
			    x_currency_code,
			    x_currency_code,
			    x_currency_code,
			    x_currency_code,
                            X_Total_Unbaselined_Amount,
                            X_Total_Unbaselined_Amount,
                            X_Total_Unbaselined_Amount,
                            X_Total_Unbaselined_Amount,
			    -- Bug 2475640 Changes END
 			    SYSDATE,
         	            fnd_global.user_id,
         	            SYSDATE ,
         	            fnd_global.user_id,
        		    fnd_global.login_id);
			X_Err_Code :=  'S';
        EXCEPTION
             WHEN OTHERS  THEN
                   X_Err_Code := 'U';
                   X_Err_Stage := 'GMS_UNEXPECTED_ERROR';
                   FND_MESSAGE.SET_NAME('GMS','GMS_UNEXPECTED_ERROR');
                   FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_MULTI_FUNDING: INSERT_SUMMARY_PROJECT_FUNDING ');
                   FND_MESSAGE.SET_TOKEN('OERRNO',SQLCODE);  -- OERRNO should be SQLCODE
                   FND_MESSAGE.SET_TOKEN('OERRM',SQLERRM);   -- OERRM  should have been SQLERRM
                   FND_MSG_PUB.add;
                   FND_MSG_PUB.Count_And_Get
                          (   p_count             =>      p_msg_count     ,
                              p_data              =>      X_Err_Stage      );

END INSERT_SUMMARY_PROJECT_FUNDING;

FUNCTION  DRAFT_BUDGET_EXISTS(X_Award_Project_Id IN NUMBER,
                              X_Err_Code OUT NOCOPY VARCHAR2,
                              X_Err_Stage OUT NOCOPY VARCHAR2)  RETURN BOOLEAN  IS
        Draft_Budget_Check NUMBER(15) := 0;
        --p_msg_count NUMBER;
BEGIN
 BEGIN
     SELECT 1
     INTO
     Draft_Budget_Check
     FROM PA_BUDGET_VERSIONS
     WHERE
     Project_Id = X_Award_Project_Id and
     budget_type_code = 'AR' and
     budget_status_code in ('W' , 'S');

             X_Err_Code := 'S';
                RETURN TRUE;
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
              X_Err_Code := 'S';
              RETURN FALSE;
           WHEN TOO_MANY_ROWS THEN
              X_Err_Code := 'E';
              X_Err_Stage := 'There is more than one draft Budget for the Project '||to_char(X_Award_Project_Id);
              --dbms_output.put_line(X_Err_Stage);
              FND_MESSAGE.SET_NAME('GMS','GMS_DRAFT_REV_BDGT_EXISTS');
              FND_MESSAGE.SET_TOKEN('AWARD_PROJECT_ID',X_Award_Project_Id);
              FND_MSG_PUB.add;
              FND_MSG_PUB.Count_And_Get
                      (  p_count             =>      p_msg_count     ,
                         p_data              =>      X_Err_Stage      );

              RETURN FALSE;
           WHEN OTHERS THEN
              X_Err_Code := 'U';
              X_Err_Stage := (SQLCODE||' '||SQLERRM) ;
              --dbms_output.put_line('Others :'||X_Err_Stage);
              X_Err_Stage := 'GMS_UNEXPECTED_ERROR';
              FND_MESSAGE.SET_NAME('GMS','GMS_UNEXPECTED_ERROR');
              FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_MULTI_FUNDING: DRAFT_BUDGET_EXISTS ');
              FND_MESSAGE.SET_TOKEN('OERRNO',SQLCODE);
              FND_MESSAGE.SET_TOKEN('OERRM',SQLERRM);
              FND_MSG_PUB.add;
              FND_MSG_PUB.Count_And_Get
                      (   p_count             =>      p_msg_count     ,
                          p_data              =>      X_Err_Stage      );
              RETURN FALSE;
 END;
END DRAFT_BUDGET_EXISTS;


PROCEDURE UPDATE_DETAIL_PROJECT_FUNDING(X_Project_Funding_Id IN NUMBER,
                                        X_Old_Allocated_Amount IN NUMBER,
             		                X_New_Allocated_Amount IN NUMBER,
                                        X_Old_Date_Allocated IN DATE,
                                        X_New_Date_Allocated IN DATE,
		                        X_Err_Code OUT NOCOPY VARCHAR2,
               				X_Err_Stage OUT NOCOPY VARCHAR2) IS
St_Budget_Type_Code VARCHAR2(30);

 --p_msg_count NUMBER;
BEGIN
 BEGIN
 Select
 BUDGET_TYPE_CODE
 INTO
 St_Budget_Type_Code
 FROM
 PA_PROJECT_FUNDINGS
 WHERE
 PROJECT_FUNDING_ID = X_Project_Funding_Id;
       X_Err_Code := 'S';
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         X_Err_Code := 'E';
         X_Err_Stage := ('No row Found for Project_funding_id '||X_Project_Funding_Id);
           X_Err_Stage := 'GMS_NO_ROW_FOR_PA_FUNDING_ID';
           FND_MESSAGE.SET_NAME('GMS','GMS_NO_ROW_FOR_PA_FUNDING');
           FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_MULTI_FUNDING: UPDATE_DETAIL_PROJECT_FUNDING - 1');
           FND_MESSAGE.SET_TOKEN('PROJECT_FUNDING_ID',to_char(X_Project_Funding_Id));
           FND_MSG_PUB.add;
           FND_MSG_PUB.Count_And_Get
                                   (   p_count             =>      p_msg_count     ,
                                       p_data              =>      X_Err_Stage      );
           RETURN;
  END ;

     --IF  St_Budget_Type_Code = 'DRAFT' THEN
       IF X_Old_Allocated_Amount <> X_New_Allocated_Amount THEN

         UPDATE PA_PROJECT_FUNDINGS
            SET ALLOCATED_AMOUNT          = X_New_Allocated_Amount,
             -- Bug 2475640 : Added for 11.5 PA-J certification.
	        PROJECT_ALLOCATED_AMOUNT  = X_New_Allocated_Amount,
                PROJFUNC_ALLOCATED_AMOUNT = X_New_Allocated_Amount,
                INVPROC_ALLOCATED_AMOUNT  = X_New_Allocated_Amount,
                REVPROC_ALLOCATED_AMOUNT  = X_New_Allocated_Amount,
     	     -- Bug 2475640 Changes End
                LAST_UPDATE_DATE          = SYSDATE ,
                LAST_UPDATED_BY           = FND_GLOBAL.USER_ID,
                LAST_UPDATE_LOGIN         = FND_GLOBAL.LOGIN_ID
          WHERE PROJECT_FUNDING_ID        = X_Project_Funding_Id;

                X_Err_Code := 'S';

                IF SQL%NOTFOUND THEN
                   X_Err_Code := 'E';
                   X_Err_Stage := 'Could not find a row to UPDATE for Project Funding '||to_char(X_Project_Funding_Id) ;
                   X_Err_Stage := 'GMS_NO_ROW_FOR_PA_FUNDING_ID';
                   FND_MESSAGE.SET_NAME('GMS','GMS_NO_ROW_FOR_PA_FUNDING');
                   FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_MULTI_FUNDING: UPDATE_DETAIL_PROJECT_FUNDING - 2');
                   FND_MESSAGE.SET_TOKEN('PROJECT_FUNDING_ID',to_char(X_Project_Funding_Id));
                   FND_MSG_PUB.add;
                   FND_MSG_PUB.Count_And_Get
                               (   p_count             =>      p_msg_count     ,
                                   p_data              =>      X_Err_Stage      );
                   RETURN;
                END IF;
       END IF;
       IF X_Old_Date_Allocated <> X_New_Date_Allocated THEN

         UPDATE PA_PROJECT_FUNDINGS
            SET DATE_ALLOCATED = X_New_Date_Allocated,
                LAST_UPDATE_DATE = SYSDATE ,
                LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
          WHERE PROJECT_FUNDING_ID = X_Project_Funding_Id;

            X_Err_Code := 'S';

            IF SQL%NOTFOUND THEN
              X_Err_Code := 'E';
              X_Err_Stage := 'Could not find a row to UPDATE for Project Funding '||to_char(X_Project_Funding_Id) ;
              X_Err_Stage := 'GMS_NO_ROW_FOR_PA_FUNDING_ID';
              FND_MESSAGE.SET_NAME('GMS','GMS_NO_ROW_FOR_PA_FUNDING');
              FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_MULTI_FUNDING: UPDATE_DETAIL_PROJECT_FUNDING - 3');
              FND_MESSAGE.SET_TOKEN('PROJECT_FUNDING_ID',to_char(X_Project_Funding_Id));
              FND_MSG_PUB.add;
              FND_MSG_PUB.Count_And_Get
                        (   p_count             =>      p_msg_count     ,
                            p_data              =>      X_Err_Stage      );
            END IF;
       END IF;
     --ELSE
     --  X_Err_Code := 'E';
     --   X_Err_Stage := 'The corresponding PA_PROJECT_FUNDING row no longer has a BUDGET TYPE of Draft';
     --END IF;

-- Added Exception for Bug:2662848
Exception
WHEN OTHERS THEN
         X_Err_Code := 'U';
         X_Err_Stage := SQLERRM||' at stage='||g_stage||' '||X_Err_Stage;

         FND_MSG_PUB.add_exc_msg
  	    (  p_pkg_name	   => 'GMS_MULTI_FUNDING'
	      ,p_procedure_name	   => 'UPDATE_DETAIL_PROJECT_FUNDING'
            );
         FND_MSG_PUB.Count_And_Get
            ( p_count             => p_msg_count
             ,p_data              => X_Err_Stage
             );
         RAISE;
END UPDATE_DETAIL_PROJECT_FUNDING;

PROCEDURE  DELETE_DETAIL_PROJECT_FUNDING(X_Project_Funding_Id IN NUMBER,
                                         X_Err_Code OUT NOCOPY VARCHAR2,
                                         X_Err_Stage OUT NOCOPY VARCHAR2)  IS
--p_msg_count  NUMBER;
BEGIN
     delete
     FROM
     PA_PROJECT_FUNDINGS
     WHERE
     PROJECT_FUNDING_ID = X_Project_Funding_Id;
    -- and BUDGET_TYPE_CODE = 'DRAFT';
IF SQL%ROWCOUNT = 0 THEN
          X_Err_Code := 'E';
           X_Err_Stage := 'GMS_NO_ROW_FOR_PA_FUNDING_ID';
           FND_MESSAGE.SET_NAME('GMS','GMS_NO_ROW_FOR_PA_FUNDING');
           FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_MULTI_FUNDING: DELETE_DETAIL_PROJECT_FUNDING');
           FND_MESSAGE.SET_TOKEN('PROJECT_FUNDING_ID',to_char(X_Project_Funding_Id));
           FND_MSG_PUB.add;
           FND_MSG_PUB.Count_And_Get
                                   (   p_count             =>      p_msg_count     ,
                                       p_data              =>      X_Err_Stage      );
END IF;
EXCEPTION
WHEN OTHERS THEN
         FND_MSG_PUB.add_exc_msg
  	    (  p_pkg_name            => 'GMS_MULTI_FUNDING'
	      ,p_procedure_name      => 'DELETE_DETAIL_PROJECT_FUNDING'
           );
         FND_MSG_PUB.Count_And_Get
            ( p_count                => p_msg_count
             ,p_data                 => X_Err_Stage
             );
         RAISE;

END DELETE_DETAIL_PROJECT_FUNDING;

PROCEDURE DELETE_SUMMARY_PROJECT_FUNDING(X_Agreement_Id IN NUMBER,
                                        X_Award_Project_Id IN NUMBER,
                                        X_Err_Code OUT NOCOPY VARCHAR2,
                                        X_Err_Stage OUT NOCOPY VARCHAR2)  IS
--p_msg_count  NUMBER;
BEGIN
     delete
     FROM
     PA_SUMMARY_PROJECT_FUNDINGS
     WHERE
     AGREEMENT_ID = X_Agreement_Id and
     PROJECT_ID = X_Award_Project_Id;
IF SQL%ROWCOUNT = 0 THEN
  X_Err_Code := 'E';
  X_Err_Stage := 'There were no rows deleted FROM PA_SUMMARY_PROJECT_FUNDINGS';
           X_Err_Stage := 'GMS_NO_SUMM_FUNDING_DELETED';
           FND_MESSAGE.SET_NAME('GMS','GMS_NO_SUMM_FUNDING_DELETED');
           FND_MSG_PUB.add;
           FND_MSG_PUB.Count_And_Get
                                   (   p_count             =>      p_msg_count     ,
                                       p_data              =>      X_Err_Stage  );
END IF;
END DELETE_SUMMARY_PROJECT_FUNDING;

PROCEDURE DELETE_BASELINED_VERSIONS(X_Award_Project_Id IN NUMBER,
                                    X_Err_Code OUT NOCOPY VARCHAR2,
                                    X_Err_Stage OUT NOCOPY VARCHAR2) IS
--p_msg_count NUMBER;

CURSOR GET_BUDGET_VERSION_CSR(X_Award_Project_Id NUMBER) IS
SELECT
BUDGET_VERSION_ID
FROM
PA_BUDGET_VERSIONS
WHERE
PROJECT_ID = X_Award_Project_Id and
BUDGET_TYPE_CODE = 'AR';

X_Budget_Version_Id NUMBER;

CURSOR GET_RESOURCE_ASSIGNMENT_CSR(X_Budget_Version_Id NUMBER) IS
SELECT
RESOURCE_ASSIGNMENT_ID
FROM
PA_RESOURCE_ASSIGNMENTS
WHERE
BUDGET_VERSION_ID = X_Budget_Version_Id;

X_Resource_Assignment_Id NUMBER;
/* BUG NO.1545351 Start */
CURSOR GET_RESOURCE_LIST_ASSIGN_CSR(X_Award_Project_Id NUMBER ) IS
SELECT
RESOURCE_LIST_ASSIGNMENT_ID
FROM
pa_resource_list_assignments
WHERE
project_id = X_Award_Project_Id ;
/* BUG NO.1545351 END */


BEGIN
   FOR GBV_RECORD IN GET_BUDGET_VERSION_CSR(X_Award_Project_Id) LOOP
    	FOR GRA_RECORD IN GET_RESOURCE_ASSIGNMENT_CSR(GBV_RECORD.BUDGET_VERSION_ID) LOOP
      	BEGIN
        	Delete FROM PA_BUDGET_LINES
        	WHERE
        	RESOURCE_ASSIGNMENT_ID = GRA_RECORD.RESOURCE_ASSIGNMENT_ID;
      	END;
    	END LOOP;
          DELETE FROM PA_RESOURCE_ASSIGNMENTS
          WHERE
          BUDGET_VERSION_ID = GBV_RECORD.BUDGET_VERSION_ID;
  END LOOP;
  /* BUG NO.1545351 Start */
  FOR RESOURCE_LIST_RECORD IN GET_RESOURCE_LIST_ASSIGN_CSR(X_Award_Project_Id )
  LOOP

		DELETE FROM pa_resource_list_uses
		WHERE
		resource_list_assignment_id =RESOURCE_LIST_RECORD.resource_list_assignment_id;

   END LOOP;

	DELETE FROM pa_resource_list_assignments
        WHERE PROJECT_ID=X_Award_Project_Id ;
 /* BUG NO.1545351 END */
         DELETE
         FROM
         PA_BUDGET_VERSIONS
         WHERE
         PROJECT_ID = X_Award_Project_Id and
         BUDGET_TYPE_CODE = 'AR';
              IF SQL%ROWCOUNT = 0 THEN
                  X_Err_Code := 'E';
                  X_Err_Stage := ('No rows delete FROM PA_BUDGET_VERSIONS for Project Id '||X_Award_Project_Id);
           X_Err_Stage := 'GMS_NO_BUD_VERS_DELETED';
           FND_MESSAGE.SET_NAME('GMS','GMS_NO_BUD_VERS_DELETED');
           FND_MESSAGE.SET_TOKEN('AWARD_PROJECT_ID',to_char(X_Award_Project_Id) );
           FND_MSG_PUB.add;
           FND_MSG_PUB.Count_And_Get
                                   (   p_count             =>      p_msg_count     ,
                                       p_data              =>      X_Err_Stage  );
              END IF;
EXCEPTION
WHEN OTHERS THEN
         FND_MSG_PUB.add_exc_msg
  	    (  p_pkg_name               => 'GMS_MULTI_FUNDING'
              ,p_procedure_name         => 'DELETE_BASELINED_VERSIONS'
           );
         RAISE;
END DELETE_BASELINED_VERSIONS;

PROCEDURE CREATE_AGREEMENT(X_Row_Id OUT NOCOPY VARCHAR2,
                           X_Agreement_Id OUT NOCOPY NUMBER,
                           X_Customer_Id IN NUMBER,
                           X_Agreement_Num IN VARCHAR2,
                           X_Agreement_Type IN VARCHAR2,
			         X_Revenue_Limit_Flag IN VARCHAR2 DEFAULT  'N',-- Bug 1841288 : Changed 'Y' to 'N'
			         X_Invoice_Limit_Flag IN VARCHAR2 DEFAULT 'N', /*Bug 6642901*/
                           X_Owned_By_Person_Id IN NUMBER,
                           X_Term_Id IN NUMBER,
                           X_Close_Date IN DATE,
                           X_Org_Id	IN NUMBER, --Shared Service Enhancement
                           RETCODE OUT NOCOPY VARCHAR2,
                           ERRBUF OUT NOCOPY VARCHAR2) IS
St_Agreement_Id NUMBER(15);
St_Row_Id       VARCHAR2(30);
--p_msg_count     NUMBER;
l_org_id NUMBER  := X_Org_Id; -- Shared Service Enhancement
BEGIN

	-- Bug 1672982

   PA_AGREEMENTS_PKG.INSERT_ROW(

		 X_ROWID          		=>	St_Row_Id,
		 X_AGREEMENT_ID		    	=>	St_Agreement_Id,
		 X_CUSTOMER_ID     		=>	X_Customer_Id,
		 X_AGREEMENT_NUM   		=>	X_Agreement_Num,
		 X_AGREEMENT_TYPE  		=>	X_Agreement_Type,
		 X_LAST_UPDATE_DATE		=>	sysdate,
		 X_LAST_UPDATED_BY  		=>	fnd_global.user_id,
		 X_CREATION_DATE    		=>	sysdate,
		 X_CREATED_BY       		=>	fnd_global.user_id,
		 X_LAST_UPDATE_LOGIN		=>	fnd_global.login_id,
		 X_OWNED_BY_PERSON_ID		=>	X_Owned_By_Person_Id,
		 X_TERM_ID          		=> 	X_Term_Id,
		 X_REVENUE_LIMIT_FLAG		=>	nvl(X_Revenue_Limit_Flag,  'N'),-- Bug 1841288 : Changed 'Y'to'N'
		 X_AMOUNT            		=>	0,
		 X_DESCRIPTION       		=>	NULL,
		 X_EXPIRATION_DATE   		=>	X_Close_Date,
		 X_ATTRIBUTE_CATEGORY		=>	NULL,
		 X_ATTRIBUTE1        		=>	NULL,
		 X_ATTRIBUTE2        		=>	NULL,
		 X_ATTRIBUTE3        		=>	NULL,
		 X_ATTRIBUTE4        		=>	NULL,
		 X_ATTRIBUTE5       		=>	NULL,
		 X_ATTRIBUTE6       		=>	NULL,
		 X_ATTRIBUTE7       		=>	NULL,
		 X_ATTRIBUTE8       		=>	NULL,
		 X_ATTRIBUTE9       		=>    NULL,
		 X_ATTRIBUTE10    	  	=>    NULL,
		 X_TEMPLATE_FLAG    		=>    NULL,
		 X_PM_AGREEMENT_REFERENCE 	=>    NULL,
		 X_PM_PRODUCT_CODE  		=>    NULL,
		-- Bug 2475640 : Added parameters for 11.5 PA-J certification.
		 X_OWNING_ORGANIZATION_ID	=>    NULL,
		 X_AGREEMENT_CURRENCY_CODE    =>    pa_currency.get_currency_code,
             X_INVOICE_LIMIT_FLAG         =>    nvl(X_Invoice_Limit_Flag,  'N'),
/*Passed value of X_Invoice_Limit_flag rather than X_Revenue_Limit_Flag for bug 6642901 */
             	X_ORG_ID		=> l_org_id
		 );

         X_Row_Id := St_Row_Id;
         X_Agreement_Id := St_Agreement_Id;
         RETCODE := 'S';

         EXCEPTION
             WHEN OTHERS THEN

               X_Agreement_Id := -1;
               RETCODE := 'U';
               ERRBUF  := SQLERRM;
               FND_MESSAGE.SET_NAME('GMS','GMS_UNEXPECTED_ERROR');
               FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_MULTI_FUNDING: CREATE_AGREEMENT');
               FND_MESSAGE.SET_TOKEN('OERRNO',SQLCODE);
               FND_MESSAGE.SET_TOKEN('OERRM',SQLERRM);
               FND_MSG_PUB.add;
               FND_MSG_PUB.Count_And_Get
                            (   p_count    =>      p_msg_count     ,
                                p_data     =>      ERRBUF      );

               RETURN;
END CREATE_AGREEMENT;

PROCEDURE DELETE_AGREEMENT(X_Agreement_Id IN NUMBER,
                           RETCODE OUT NOCOPY VARCHAR2,
                           ERRBUF OUT NOCOPY VARCHAR2) IS
X_Row_Id VARCHAR2(30);
Check_Funding_Exists NUMBER := 0;
--p_msg_count  NUMBER;

BEGIN
 BEGIN
   SELECT
   rowid
   INTO
   X_Row_Id
   FROM
   PA_AGREEMENTS
   WHERE
   AGREEMENT_ID = X_Agreement_Id;
     EXCEPTION
             WHEN NO_DATA_FOUND THEN
               RETCODE := 'E';
               ERRBUF  := 'No Agreement Found with Id '||to_char(X_Agreement_Id) ;
           FND_MESSAGE.SET_NAME('GMS','GMS_AGREEMENT_NOT_FOUND');
           FND_MESSAGE.SET_TOKEN('AGREEMENT_ID',to_char(X_Agreement_Id) );
           FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_MULTI_FUNDING : DELETE_AGREEMENT');
           FND_MSG_PUB.add;
           FND_MSG_PUB.Count_And_Get
                                   (   p_count             =>      p_msg_count     ,
                                       p_data              =>      ERRBUF      );

             WHEN OTHERS THEN
               RETCODE := 'U';
               ERRBUF  := SQLCODE||' '||SQLERRM;
               FND_MESSAGE.SET_NAME('GMS','GMS_UNEXPECTED_ERROR');
               FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_MULTI_FUNDING: DELETE_AGREEMENT');
               FND_MESSAGE.SET_TOKEN('OERRNO',SQLCODE);
               FND_MESSAGE.SET_TOKEN('OERRM',SQLERRM);
               FND_MSG_PUB.add;
               FND_MSG_PUB.Count_And_Get
                                   (   p_count             =>      p_msg_count     ,
                                       p_data              =>      ERRBUF      );
 END;

 BEGIN
   SELECT COUNT(X_Agreement_Id)
   INTO
   Check_Funding_Exists
   FROM PA_SUMMARY_PROJECT_FUNDINGS
   WHERE AGREEMENT_ID = X_Agreement_Id;
          IF Check_Funding_Exists >= 1 THEN
               RETCODE := 'E';
               ERRBUF := 'Cannot delete Agreement while Funding Exists ';

               FND_MESSAGE.SET_NAME('GMS','GMS_FUND_EXISTS_FOR_AGMT');
               FND_MSG_PUB.add;
               FND_MSG_PUB.Count_And_Get
                                       (   p_count             =>      p_msg_count     ,
                                           p_data              =>      ERRBUF      );

          Elsif  Check_Funding_Exists = 0 THEN
               RETCODE := 'S';
               PA_AGREEMENTS_PKG.DELETE_ROW( X_ROWID => X_Row_Id);  -- Bug 1672982
          END IF;
 END;
-- Added Exception for Bug:2662848
EXCEPTION
 WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.add_exc_msg
  	    (  p_pkg_name               => 'GMS_MULTI_FUNDING'
              ,p_procedure_name         => 'DELETE_AGREEMENT'
           );
	END IF;
  	RAISE;
END DELETE_AGREEMENT;


FUNCTION ALLOW_REV_LIMIT_FLAG_UPDATE(X_Agreement_Id IN NUMBER,
				     X_Err_Code     OUT NOCOPY VARCHAR2,
				     X_Err_Stage    OUT NOCOPY VARCHAR2) RETURN BOOLEAN IS
St_Award_Project_Id  NUMBER;
St_Invoice_Num_Count NUMBER;
St_Revenue_Num_Count NUMBER;
St_award_id          NUMBER;
x_total_funding_amount NUMBER;
x_total_revenue_amount NUMBER;
x_total_billed_amount NUMBER;
x_bill_amount        NUMBER;
x_revenue_amount     NUMBER;

St_revenue_distribution_rule VARCHAR2(10);
St_billing_distribution_rule VARCHAR2(10);

BEGIN
 BEGIN
  Select
  Award_Project_Id,
  award_id,
  revenue_distribution_rule,
  billing_distribution_rule
  INTO
  St_Award_Project_Id,
  St_award_id,
  St_revenue_distribution_rule,
  St_billing_distribution_rule
  FROM
  GMS_AWARDS_ALL
  WHERE
     AGREEMENT_ID = X_Agreement_Id
and  award_template_flag = 'DEFERRED';

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
            X_Err_Code  := 'E';
            X_Err_Stage := 'GMS_AWARD_FOR_AGR_NOT_FOUND';
           FND_MESSAGE.SET_NAME('GMS','GMS_AWARD_FOR_AGR_NOT_FOUND');
           FND_MSG_PUB.add;
           FND_MSG_PUB.Count_And_Get
                                   (   p_count             =>      p_msg_count     ,
                                       p_data              =>      X_Err_Stage      );
                      RETURN FALSE;
 END;
 BEGIN
 /***************Commented out NOCOPY for bug 1393568  ***********************

  Select
  count(draft_invoice_num)
  INTO
  St_Invoice_Num_Count
  FROM
  PA_DRAFT_INVOICES
  WHERE
      project_id   = St_Award_Project_Id
  and agreement_id = X_Agreement_Id;

  Select
  count(draft_revenue_num)
  INTO
  St_Revenue_Num_Count
  FROM
  PA_DRAFT_REVENUES
  WHERE
      project_id   = St_Award_Project_Id
  and agreement_id = X_Agreement_Id;
 END;

   IF (St_Invoice_Num_Count > 0 OR St_Revenue_Num_Count > 0) THEN
          X_Err_Code := 'E';
          X_Err_Stage := 'GMS_REVENUE_OR_INVOICES_EXIST';
           FND_MESSAGE.SET_NAME('GMS','GMS_REVENUE_OR_INVOICES_EXIST');
           FND_MSG_PUB.add;
           FND_MSG_PUB.Count_And_Get
                                   (   p_count             =>      p_msg_count     ,
                                       p_data              =>      X_Err_Stage      );

          RETURN FALSE;
   ELSE
          X_Err_Code := 'S';
          RETURN TRUE;
   END IF;
***************END of comment for bug 1393568 *****************************/

    SELECT  sum(nvl(total_funding_amount,0)),
            sum(nvl(total_revenue_amount,0)),
            sum(nvl(total_billed_amount,0))
    INTO    x_total_funding_amount,
            x_total_revenue_amount,
            x_total_billed_amount
    FROM gms_summary_project_fundings gspf,
         gms_installments ins
    WHERE ins.installment_id = gspf.installment_id
    and      ins.award_id = St_award_id;

 IF St_revenue_distribution_rule = 'COST' and St_billing_distribution_rule = 'COST' THEN
    if ((x_total_revenue_amount > x_total_funding_amount) or (x_total_billed_amount > x_total_funding_amount)) THEN
    X_Err_Code := 'E';
    X_Err_Stage := 'GMS_REVENUE_OR_INVOICES_EXIST';
    FND_MESSAGE.SET_NAME('GMS','GMS_REVENUE_OR_INVOICES_EXIST');
    FND_MSG_PUB.add;
    FND_MSG_PUB.Count_And_Get
                                   (   p_count             =>      p_msg_count     ,
                                       p_data              =>      X_Err_Stage      );

            return false;
     else
            return true;
    end if;
 Elsif (St_revenue_distribution_rule = 'COST' and St_billing_distribution_rule = 'EVENT') or
       (St_revenue_distribution_rule = 'EVENT' and St_billing_distribution_rule = 'EVENT') THEN
    SELECT sum(bill_amount),
           sum(revenue_amount)
    INTO   x_bill_amount, x_revenue_amount
    FROM   pa_events a,gms_awards_all b
    WHERE  a.project_id = b.award_project_id
    and    b.award_id = St_award_id;
     if ((x_revenue_amount > x_total_funding_amount)/* or (x_bill_amount > x_total_funding_amount)*/) THEN
    X_Err_Code := 'E';
    /* Bug 1711701 */
    /* Changed the Message Name FROM 'GMS_REVENUE_OR_INVOICES_EXIST' to 'GMS_CANNOT_UPDATE_FLAG'
    as message Text of previous message got changed in 11i */

    /*    X_Err_Stage := 'GMS_CANNOT_UPDATE_FLAG';
    FND_MESSAGE.SET_NAME('GMS','GMS_CANNOT_UPDATE_FLAG'); Commented for bug 6642901 and replaced with 2 new messages specific to revenue and invoice.*/
    X_Err_Stage := 'GMS_CANNOT_UPD_REV_FLAG';
    FND_MESSAGE.SET_NAME('GMS','GMS_CANNOT_UPD_REV_FLAG');
    FND_MSG_PUB.add;
    FND_MSG_PUB.Count_And_Get
                                   (   p_count             =>      p_msg_count     ,
                                       p_data              =>      X_Err_Stage      );

          return false;
    elsif (x_bill_amount > x_total_funding_amount) THEN
    X_Err_Code := 'E';
    X_Err_Stage := 'GMS_CANNOT_UPD_INV_FLAG';
    FND_MESSAGE.SET_NAME('GMS','GMS_CANNOT_UPD_INV_FLAG');
    FND_MSG_PUB.add;
    FND_MSG_PUB.Count_And_Get
                                   (   p_count             =>      p_msg_count ,
                                       p_data              =>      X_Err_Stage);
          return false;
   else
          return true;

   end if;
 END if;
-- --dbms_output.put_line('At end of ALLOW_REV_LIMIT_FLAG_UPDATE');
END;
Exception
             WHEN OTHERS THEN
               X_Err_Code  := 'U';
               FND_MESSAGE.SET_NAME('GMS','GMS_UNEXPECTED_ERROR');
               FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_MULTI_FUNDING: ALLOW_REV_LIMIT_FLAG_UPDATE');
               FND_MESSAGE.SET_TOKEN('OERRNO',SQLCODE);
               FND_MESSAGE.SET_TOKEN('OERRM',SQLERRM);
               FND_MSG_PUB.add;
               FND_MSG_PUB.Count_And_Get(p_count  => p_msg_count,
                                         p_data   => X_Err_Stage);
                     RAISE FND_API.G_EXC_ERROR;

END ALLOW_REV_LIMIT_FLAG_UPDATE;

PROCEDURE UPDATE_AGREEMENT(X_Agreement_Id IN NUMBER,
                           X_Agreement_Num IN VARCHAR2 DEFAULT NULL,
                           X_Agreement_Type IN VARCHAR2 DEFAULT NULL,
			   X_Revenue_Limit_Flag IN VARCHAR2 DEFAULT NULL,
			   X_Invoice_Limit_Flag IN VARCHAR2 DEFAULT NULL, /*Bug 6642901*/
                           X_Customer_Id IN NUMBER DEFAULT NULL,
                           X_Owned_By_Person_Id IN NUMBER DEFAULT NULL,
                           X_Term_Id IN NUMBER DEFAULT NULL,
                           X_Amount IN NUMBER DEFAULT 0,
                           X_Close_Date IN DATE DEFAULT NULL,
                           RETCODE OUT NOCOPY VARCHAR2,
                           ERRBUF  OUT NOCOPY VARCHAR2) IS
Store_Row_Id VARCHAR2(30);
Store_Term_Id NUMBER(15);
Store_Customer_Id NUMBER(15);
Store_Owned_By_Person_Id NUMBER(15);
Store_Agreement_Num VARCHAR2(30);
Store_Expiration_Date DATE;
Store_Agreement_Type VARCHAR2(30);
Store_Revenue_Limit_Flag VARCHAR2(1);
Store_Invoice_Limit_Flag VARCHAR2(1); /*Bug 6642901*/
Store_Amount NUMBER(22,5);
Store_agreement_currency_code PA_AGREEMENTS.agreement_currency_code%type; -- Bug 2475640

 --p_msg_count NUMBER;

BEGIN
   BEGIN
    SELECT
     ROWID,
     NVL(X_Term_Id,TERM_ID),
     NVL(X_Customer_Id,CUSTOMER_ID),
     NVL(X_Owned_By_Person_Id,OWNED_BY_PERSON_ID),
     NVL(X_Agreement_Num,AGREEMENT_NUM),
     NVL(X_Close_Date,EXPIRATION_DATE),
     NVL(X_Agreement_Type,AGREEMENT_TYPE),
     NVL(X_Revenue_Limit_Flag, REVENUE_LIMIT_FLAG),
     NVL(X_Invoice_Limit_Flag, INVOICE_LIMIT_FLAG), /*Bug 6642901*/
     nvl(AMOUNT,0),
     agreement_currency_code	-- Bug 2475640 : Added for 11.5 PA-J certification.
    INTO
     	Store_Row_Id,
        Store_Term_Id,
        Store_Customer_Id,
	Store_Owned_By_Person_Id,
	Store_Agreement_Num,
        Store_Expiration_Date,
	Store_Agreement_Type,
        Store_Revenue_Limit_Flag,
        Store_Invoice_Limit_Flag, /*Bug 6642901*/
        Store_Amount,
	Store_agreement_currency_code	-- Bug 2475640 : Added for 11.5 PA-J certification.
    FROM
    PA_AGREEMENTS
    WHERE
     AGREEMENT_ID = X_Agreement_Id;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               RETCODE := 'E';
               ERRBUF  := 'No Agreement Found with Id '||to_char(X_Agreement_Id) ;

               FND_MESSAGE.SET_NAME('GMS','GMS_AGREEMENT_NOT_FOUND');
               FND_MESSAGE.SET_TOKEN('AGREEMENT_ID',to_char(X_Agreement_Id) );
               FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_MULTI_FUNDING : UPDATE_AGREEMENT');
               FND_MSG_PUB.add;
               FND_MSG_PUB.Count_And_Get
                                   (   p_count             =>      p_msg_count     ,
                                       p_data              =>      ERRBUF      );
               RAISE FND_API.G_EXC_ERROR;
           WHEN OTHERS THEN
               RETCODE := 'U';
               FND_MESSAGE.SET_NAME('GMS','GMS_UNEXPECTED_ERROR');
               FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_MULTI_FUNDING: UPDATE_AGREEMENT');
               FND_MESSAGE.SET_TOKEN('OERRNO',SQLCODE);
               FND_MESSAGE.SET_TOKEN('OERRM',SQLERRM);
               FND_MSG_PUB.add;
               FND_MSG_PUB.Count_And_Get
                                   (   p_count             =>      p_msg_count     ,
                                       p_data              =>      ERRBUF      );
               RAISE FND_API.G_EXC_ERROR;
   END;


        Store_Amount := (Store_Amount + X_Amount);

-- Bug 1672982

   PA_AGREEMENTS_PKG.UPDATE_ROW (
		 X_ROWID			=>	Store_Row_Id,
		 X_AGREEMENT_ID       		=>      X_AGREEMENT_ID,
		 X_CUSTOMER_ID        		=>	Store_Customer_Id,
		 X_AGREEMENT_NUM      		=>	Store_Agreement_Num,
		 X_AGREEMENT_TYPE     		=>	Store_Agreement_Type,
		 X_LAST_UPDATE_DATE   		=>	SYSDATE,
		 X_LAST_UPDATED_BY    		=>	fnd_global.user_id,
		 X_LAST_UPDATE_LOGIN  		=>	fnd_global.login_id,
		 X_OWNED_BY_PERSON_ID 		=>	Store_Owned_By_Person_Id,
		 X_TERM_ID            		=>	Store_Term_Id,
		 X_REVENUE_LIMIT_FLAG 		=>	Store_Revenue_Limit_Flag,
		 X_AMOUNT             		=>	Store_Amount,
		 X_DESCRIPTION        		=>	NULL,
		 X_EXPIRATION_DATE    		=>	Store_Expiration_Date,
		 X_ATTRIBUTE_CATEGORY 		=>	NULL,
		 X_ATTRIBUTE1         		=>	NULL,
		 X_ATTRIBUTE2         		=>	NULL,
		 X_ATTRIBUTE3         		=>	NULL,
		 X_ATTRIBUTE4         		=>	NULL,
		 X_ATTRIBUTE5         		=>	NULL,
		 X_ATTRIBUTE6         		=>	NULL,
		 X_ATTRIBUTE7         		=>	NULL,
		 X_ATTRIBUTE8         		=>	NULL,
		 X_ATTRIBUTE9         		=>	NULL,
		 X_ATTRIBUTE10        		=>	NULL,
		 X_TEMPLATE_FLAG      		=>	NULL,
		 X_PM_AGREEMENT_REFERENCE 	=>	NULL,
		 X_PM_PRODUCT_CODE        	=>	NULL,
		-- Bug 2475640 : Added parameters for 11.5 PA-J certification.
		 X_OWNING_ORGANIZATION_ID	=>	NULL,
		 X_AGREEMENT_CURRENCY_CODE      =>      Store_agreement_currency_code,
                 X_INVOICE_LIMIT_FLAG		=>	Store_Invoice_Limit_Flag
/*Replaced Store_Revenue_Limit_Flag with Store_Invoice_Limit_Flag for bug 6642901*/

		 );


             RETCODE := 'S';
    EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
         RETURN;

     -- Added when others exception for Bug:2662848
     WHEN OTHERS THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.add_exc_msg
  	    (  p_pkg_name               => 'GMS_MULTI_FUNDING'
              ,p_procedure_name         => 'UPDATE_AGREEMENT'
           );
	  END IF;
  	  RAISE;
END UPDATE_AGREEMENT;

--This Procedure creates a Budget Type for the Award whenever the Award is created
-- this procedure is not used in 11i as there is no award_budget_type -- Suresh
PROCEDURE INSERT_AWARD_BUDGET_TYPE(X_Budget_Type_Code  IN VARCHAR2,
                                   X_Budget_Type       IN VARCHAR2,
                                   X_Start_Date        IN DATE,
                                   X_End_Date          IN DATE,
                                   X_Predefined_Flag   IN VARCHAR2,
                                   X_Accumulation_Flag IN VARCHAR2,
                                   X_Award_Flag        IN VARCHAR2,
                                   X_Err_Code          OUT NOCOPY VARCHAR2,
                                   X_Err_Stage         OUT NOCOPY VARCHAR2) IS
BEGIN
  INSERT INTO PA_BUDGET_TYPES(BUDGET_TYPE_CODE,
			      LAST_UPDATE_DATE,
                              LAST_UPDATED_BY,
                              CREATION_DATE,
                              CREATED_BY,
                              LAST_UPDATE_LOGIN ,
                              BUDGET_TYPE,
                              START_DATE_ACTIVE,
                              BUDGET_AMOUNT_CODE,
                              PREDEFINED_FLAG,
                              ACCUMULATION_FLAG,
                              END_DATE_ACTIVE)
                              --AWARD_FLAG )--11i change
  VALUES(X_Budget_Type_Code,
         SYSDATE,
         fnd_global.user_id,
         SYSDATE,
         fnd_global.user_id,
         fnd_global.login_id,
         X_Budget_Type,
         X_Start_Date,
         'C',
         X_Predefined_Flag,
         X_Accumulation_Flag,
         X_End_Date);
         --X_Award_Flag); --11i CHANGE
                   X_Err_Code := 'S';
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
             X_Err_Code := 'E';
             X_Err_Stage := 'Budget Type already exists ';
           FND_MESSAGE.SET_NAME('GMS','GMS_BUD_TYP_EXISTS');
           FND_MSG_PUB.add;
           FND_MSG_PUB.Count_And_Get (p_count => p_msg_count,
                                      p_data  => X_Err_Stage  );
        WHEN OTHERS THEN
             X_Err_Code := 'U';
             X_Err_Stage := SQLCODE||' '||SQLERRM;
           FND_MESSAGE.SET_NAME('GMS','GMS_UNEXPECTED_ERROR');
           FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_MULTI_FUNDING: INSERT_AWARD_BUDGET_TYPE');
           FND_MESSAGE.SET_TOKEN('OERRNO',SQLCODE);
           FND_MESSAGE.SET_TOKEN('OERRM',SQLERRM);
           FND_MSG_PUB.add;
           FND_MSG_PUB.Count_And_Get(p_count =>p_msg_count,
                                     p_data  =>X_Err_Stage );

END INSERT_AWARD_BUDGET_TYPE;

-- this procedure is not used in 11i as there is no award_budget_type -- Suresh
PROCEDURE UPDATE_AWARD_BUDGET_TYPE(X_Budget_Type_Code  IN VARCHAR2,
                                   X_Budget_Type       IN VARCHAR2,
                                   X_Start_Date        IN DATE,
                                   X_End_Date          IN DATE,
                                   X_Err_Code          OUT NOCOPY VARCHAR2,
                                   X_Err_Stage         OUT NOCOPY VARCHAR2) IS
BEGIN
   UPDATE PA_BUDGET_TYPES
   SET  Budget_Type         = X_Budget_Type
       /* Start_Date_Active   = X_Start_Date,
        End_Date_Active     = X_End_Date */
   WHERE
   Budget_Type_Code = X_Budget_Type_Code;
                 X_Err_Code := 'S';
        IF SQL%NOTFOUND THEN
             X_Err_Code := 'E';
             X_Err_Stage := 'UPDATE FAILED: No Budget_Type found with Budget Type Code '||X_Budget_Type_Code;
           FND_MESSAGE.SET_NAME('GMS','GMS_BUD_TYP_NOT_FOUND');
           FND_MESSAGE.SET_TOKEN('BUDGET_TYPE_CODE',X_Budget_Type_Code);
           FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_MULTI_FUNDING: UPDATE_AWARD_BUDGET_TYPE');
           FND_MSG_PUB.add;
           FND_MSG_PUB.Count_And_Get(p_count =>p_msg_count,
                                     p_data  =>X_Err_Stage );

        END IF;

END UPDATE_AWARD_BUDGET_TYPE;

-- this procedure is not used in 11i as there is no award_budget_type -- Suresh
PROCEDURE DELETE_AWARD_BUDGET_TYPE(X_Budget_Type_Code IN  VARCHAR2,
                                   X_Err_Code         OUT NOCOPY VARCHAR2,
                                   X_Err_Stage        OUT NOCOPY VARCHAR2) IS
BEGIN
  DELETE FROM PA_BUDGET_TYPES
  WHERE
  BUDGET_TYPE_CODE = X_Budget_Type_Code;
                X_Err_Code := 'S';
    IF SQL%ROWCOUNT = 0 THEN
        X_Err_Code := 'E'   ;
        X_Err_Stage := 'DELETE of BUDGET_TYPE Failed: No Budget Type found with Budget Type Code '||X_Budget_Type_Code;
           FND_MESSAGE.SET_NAME('GMS','GMS_BUD_TYP_NOT_FOUND');
           FND_MESSAGE.SET_TOKEN('BUDGET_TYPE_CODE',X_Budget_Type_Code);
           FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_MULTI_FUNDING: DELETE_AWARD_BUDGET_TYPE');
           FND_MSG_PUB.add;
           FND_MSG_PUB.Count_And_Get(p_count =>p_msg_count,
                                     p_data  =>X_Err_Stage );
    END IF;

END DELETE_AWARD_BUDGET_TYPE;


PROCEDURE GET_CUSTOMER_INFO(X_Customer_Id           IN NUMBER,
                            X_Bill_To_Address_Id    OUT NOCOPY NUMBER,
                            X_Ship_To_Address_Id    OUT NOCOPY NUMBER,
			    X_Bill_To_Contact_Id    OUT NOCOPY NUMBER,
			    X_Ship_To_Contact_Id    OUT NOCOPY NUMBER,
                            X_Err_Code              OUT NOCOPY VARCHAR2,
			    X_Err_Stage             OUT NOCOPY VARCHAR2) IS

    St_Bill_To_Address_Id     Number;
    St_Ship_To_Address_Id     Number;
    St_Bill_To_Contact_Id     NUMBER;
    St_Ship_To_Contact_Id     NUMBER;

BEGIN

    BEGIN
    --Shared Service Enhancement
    /********
    Replacing the Ra_addresseses and RA_Site_uses with HZ Tables
       Select  a.Address_id
            Into  St_Bill_To_Address_Id
            From  Ra_Addresses a,
                  Ra_Site_Uses su
           Where  a.Address_Id        = su.Address_id
             And  a.Customer_Id       = X_Customer_Id
             And  Nvl(su.Status, 'A') = 'A'
             And  su.Site_Use_Code    = 'BILL_TO'
             And  su.primary_flag     = 'Y' ;
   ****************/
	SELECT  su.cust_acct_site_id
	INTO  St_Bill_To_Address_Id
	FROM  HZ_CUST_ACCT_SITES ACCT_SITE,
	      HZ_CUST_SITE_USES SU
	WHERE  acct_site.cust_acct_site_id = su.cust_acct_site_id
	AND  acct_site.cust_account_id  = X_Customer_Id
	AND  Nvl(su.Status, 'A') = 'A'
	AND  su.Site_Use_Code    = 'BILL_TO'
	AND  su.primary_flag     = 'Y' ;

            X_Err_Code := 'S';

     EXCEPTION
        WHEN NO_DATA_FOUND THEN
            X_Err_Code  := 'E';
            X_Err_Stage := 'PA_NO_BILL_TO_ADDRESS' ;
            FND_MESSAGE.SET_NAME('PA','PA_NO_BILL_TO_ADDRESS');
            FND_MSG_PUB.add;
            FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
                                      p_data => X_Err_Stage);
            return;
        WHEN OTHERS THEN
            X_Err_Code := 'U';
            X_Err_Stage := SQLERRM;

           X_Err_Stage := 'GMS_UNEXPECTED_ERROR';
           FND_MESSAGE.SET_NAME('GMS','GMS_UNEXPECTED_ERROR');
           FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_MULTI_FUNDING: PROJ_START_AND_END_DATE');
           FND_MESSAGE.SET_TOKEN('OERRNO',SQLCODE);
           FND_MESSAGE.SET_TOKEN('OERRM',SQLERRM);
           FND_MSG_PUB.add;
           FND_MSG_PUB.Count_And_Get
                                   (   p_count             =>      p_msg_count     ,
                                       p_data              =>      X_Err_Stage      );

    END ;

    BEGIN

--Shared Service Enhancement
/************
Replacing the RA tables with HZ tables
Select a.Address_id
            Into St_Ship_To_Address_Id
           From  Ra_Addresses a,
                 Ra_Site_Uses su
          Where  a.Address_Id        = su.Address_id
            And  a.Customer_Id       = X_Customer_Id
            And  Nvl(su.Status, 'A') = 'A'
            And  su.Site_Use_Code    = 'SHIP_TO'
            And  su.primary_flag     = 'Y' ;
****************/
        SELECT su.cust_acct_site_id
        INTO St_Ship_To_Address_Id
        FROM  hz_cust_acct_sites acct_site,
              Hz_cust_site_Uses su
        WHERE  acct_site.cust_acct_site_id = su.cust_acct_site_id
	AND  acct_site.cust_account_id  = X_Customer_Id
        AND  Nvl(su.Status, 'A') = 'A'
        AND  su.Site_Use_Code    = 'SHIP_TO'
        AND  su.primary_flag     = 'Y' ;


          X_Err_Code := 'S';

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            X_Err_Code  := 'E';
            X_Err_Stage := 'PA_NO_SHIP_TO_ADDRESS' ;
            FND_MESSAGE.SET_NAME('PA','PA_NO_SHIP_TO_ADDRESS');
            FND_MSG_PUB.add;
            FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
                                      p_data => X_Err_Stage);
            return ;
        WHEN OTHERS THEN
           X_Err_Code := 'U';
           X_Err_Stage := SQLERRM;

           X_Err_Stage := 'GMS_UNEXPECTED_ERROR';
           FND_MESSAGE.SET_NAME('GMS','GMS_UNEXPECTED_ERROR');
           FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_MULTI_FUNDING: PROJ_START_AND_END_DATE');
           FND_MESSAGE.SET_TOKEN('OERRNO',SQLCODE);
           FND_MESSAGE.SET_TOKEN('OERRM',SQLERRM);
           FND_MSG_PUB.add;
           FND_MSG_PUB.Count_And_Get
                                   (   p_count             =>      p_msg_count     ,
                                       p_data              =>      X_Err_Stage      );
    END ;

             X_Bill_To_Address_Id   :=  St_Bill_To_Address_Id  ;
             X_Ship_To_Address_Id   :=  St_Ship_To_Address_Id  ;


   /* Getting the Ship_To_Contact for the Customer */

    BEGIN
    --Shared Service Enhancement : Replaced ra_contacts with HZ Table
	 Select su.Contact_Id
 	 Into X_Ship_To_Contact_Id
 	 From  hz_cust_acct_sites acct_site,
               Hz_cust_site_Uses su
 	 Where  acct_site.cust_acct_site_id = su.cust_acct_site_id
 	 And  acct_site.cust_account_id  = X_Customer_Id
 	 And  Nvl(su.Status, 'A') = 'A'
 	 And  su.Site_Use_Code    = 'SHIP_TO'
 	 And  su.primary_flag     = 'Y' ;

               X_Err_Code := 'S';

       EXCEPTION
        WHEN NO_DATA_FOUND THEN
            X_Err_Code  := 'E';
            X_Err_Stage := 'PA_NO_SHIP_TO_CONTACT' ;
            FND_MESSAGE.SET_NAME('PA','PA_NO_SHIP_TO_CONTACT');
            FND_MSG_PUB.add;
            FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
                                      p_data => X_Err_Stage);
               return;
        WHEN OTHERS THEN
            X_Err_Code := 'U';
            X_Err_Stage := 'GMS_UNEXPECTED_ERROR';
            FND_MESSAGE.SET_NAME('GMS','GMS_UNEXPECTED_ERROR');
           FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_MULTI_FUNDING : GET_CUSTOMER_INFO');
           FND_MESSAGE.SET_TOKEN('OERRNO',SQLCODE);
           FND_MESSAGE.SET_TOKEN('OERRM',SQLERRM);
           FND_MSG_PUB.add;
           FND_MSG_PUB.Count_And_Get
                                   (   p_count             =>      p_msg_count                          ,
                                       p_data              =>      X_Err_Stage                           );
                      return;

     END;

  /* Get Bill To Contact Id for the Customer */

      BEGIN
      --Shared Service Enhancement :Replaced the RA_Contacts with HZ tables.
    	   Select su.Contact_Id
	   Into X_Ship_To_Contact_Id
	   From  hz_cust_acct_sites acct_site,
	          Hz_cust_site_Uses su
	   Where  acct_site.cust_acct_site_id = su.cust_acct_site_id
	   And  acct_site.cust_account_id  = X_Customer_Id
	   And  Nvl(su.Status, 'A') = 'A'
	   And  su.Site_Use_Code    = 'BILL_TO'
	   And  su.primary_flag     = 'Y' ;
                 X_Err_Code := 'S';
    EXCEPTION
        When NO_DATA_FOUND THEN
            X_Err_Code  := 'E';
            X_Err_Stage := 'PA_NO_BILL_TO_CONTACT' ;
            FND_MESSAGE.SET_NAME('PA','PA_NO_BILL_TO_CONTACT');
            FND_MSG_PUB.add;
            FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
                                      p_data => X_Err_Stage);
             return;
        WHEN OTHERS THEN
           X_Err_Code := 'U';
           X_Err_Stage := SQLERRM;

           X_Err_Stage := 'GMS_UNEXPECTED_ERROR';
           FND_MESSAGE.SET_NAME('GMS','GMS_UNEXPECTED_ERROR');
           FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_MULTI_FUNDING : GET_CUSTOMER_INFO');
           FND_MESSAGE.SET_TOKEN('OERRNO',SQLCODE);
           FND_MESSAGE.SET_TOKEN('OERRM',SQLERRM);
           FND_MSG_PUB.add;
           FND_MSG_PUB.Count_And_Get
                                   (   p_count             =>      p_msg_count                          ,
                                       p_data              =>      X_Err_Stage                           );
            return;

    END ;
-- Added Exception for Bug:2662848
EXCEPTION
WHEN OTHERS THEN
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.add_exc_msg
  	    (  p_pkg_name               => 'GMS_MULTI_FUNDING'
              ,p_procedure_name         => 'GET_CUSTOMER_INFO'
           );
	END IF;
  	RAISE;
END GET_CUSTOMER_INFO;

-- Bug Fix 2994625
-- Added a new parameter bill_to_customer_id to create contacts for LOC customer.

PROCEDURE MODIFY_GMS_CONTACTS(X_Award_Id            IN NUMBER,
			      X_Award_Project_Id    IN NUMBER,
                              X_Customer_Id         IN NUMBER,
                              X_Bill_to_customer_id         IN NUMBER,
			      X_Awd_Templ_Bill_Cont_Id IN NUMBER DEFAULT NULL,
			      X_Awd_Templ_Ship_Cont_Id IN NUMBER DEFAULT NULL,
                              X_Err_Code            OUT NOCOPY VARCHAR2,
                              X_Err_Stage           OUT NOCOPY VARCHAR2) IS
  St_Bill_To_Contact_Id NUMBER;
  St_Ship_To_Contact_Id NUMBER;
  X_Cust_Bill_Cont_Exists  NUMBER    := -99;
  X_Cust_Ship_Cont_Exists  NUMBER    := -99;
BEGIN

  BEGIN
     Select
     contact_id
     INTO
     St_Bill_To_Contact_Id
     FROM
     PA_PROJECT_CONTACTS
     WHERE project_id = X_Award_Project_Id
   and customer_id = X_Customer_Id
   and project_contact_type_code = 'BILLING';
            X_Err_Code := 'S';

           EXCEPTION
                WHEN NO_DATA_FOUND THEN
                      X_Err_Code := 'E';
                      X_Err_Stage := 'GMS_NO_AWARD_CONTACTS';
                  FND_MESSAGE.SET_NAME('GMS','GMS_NO_AWARD_CONTACTS');
                  FND_MSG_PUB.add;
                  FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
                                            p_data => X_Err_Stage);
                        return;
  END;

  BEGIN
     Select
     contact_id
     INTO
     St_Ship_To_Contact_Id
     FROM
     PA_PROJECT_CONTACTS
     WHERE project_id = X_Award_Project_Id
   and customer_id = X_Customer_Id
   and project_contact_type_code = 'SHIPPING';
            X_Err_Code := 'S';

         EXCEPTION
             WHEN NO_DATA_FOUND THEN
                   X_Err_Code := 'S';
                 NULL;

  END;

    --Updating the Rows for the Existing Customer's Primary BILL_TO and SHIP_TO  contacts
    --setting the Primary Flag = 'N'. Changed it to actually delete the primary BILLTO
    --SHIP TO contacts
  BEGIN

    delete FROM GMS_AWARDS_CONTACTS
    WHERE
      award_id  = X_Award_Id
    and usage_code in ('BILL_TO','SHIP_TO')
    and primary_flag = 'Y';

/*    UPDATE GMS_AWARDS_CONTACTS
    set primary_flag = 'N'
    WHERE
      award_id      = X_Award_Id
  and usage_code    in ('BILL_TO','SHIP_TO')
  and primary_flag  = 'Y';
*/

  END;

--===========================================================================
/* Inserting Bill_To_Contact */
BEGIN

--------------------------------------------------------------------------------
/* Overriding the Ship_To_Contact_Id obtained FROM PA_PROJECT_CONTACTS with the one obtained FROM Award Template */

 IF X_Awd_Templ_Bill_Cont_Id IS NOT NULL THEN
    ST_Bill_To_Contact_Id := X_Awd_Templ_Bill_Cont_Id;
 END IF;
--------------------------------------------------------------------------------


IF St_Bill_To_Contact_Id is NOT NULL THEN

  BEGIN
   SELECT 1
   INTO
   X_Cust_Bill_Cont_Exists
   FROM
   GMS_AWARDS_CONTACTS
   WHERE
      award_id    = X_Award_id
  and customer_id = X_Customer_Id
  and contact_id  = St_Bill_To_Contact_Id
  and usage_code  = 'BILL_TO';
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
                  NULL;
  END;


  IF X_Cust_Bill_Cont_Exists = -99 THEN
   INSERT INTO GMS_AWARDS_CONTACTS(AWARD_ID
                                  ,CONTACT_ID
                                  ,CUSTOMER_ID
                                  ,USAGE_CODE
                                  ,PRIMARY_FLAG
                                  ,CREATION_DATE
                                  ,CREATED_BY
                                  ,LAST_UPDATE_DATE
                                  ,LAST_UPDATED_BY
                                  ,LAST_UPDATE_LOGIN)
                  VALUES(X_Award_Id
                        ,St_Bill_To_Contact_Id
                        ,NVL(X_Bill_to_Customer_id,X_Customer_Id)
                        ,'BILL_TO'
                        ,'Y'
                        ,SYSDATE
                        ,fnd_global.user_id
                        ,SYSDATE
                        ,fnd_global.user_id
                        ,fnd_global.login_id);

  Elsif X_Cust_Bill_Cont_Exists = 1 THEN
          UPDATE GMS_AWARDS_CONTACTS
          set
          PRIMARY_FLAG = 'Y'
          WHERE
              award_id     = X_Award_Id
          and customer_id  = NVL(X_Bill_to_Customer_id,X_Customer_Id)
          and contact_id   = St_Bill_To_Contact_Id
          and usage_code   = 'BILL_TO';
  END IF;

END IF;
                 X_Err_Code := 'S';

--------------------------------------------------------------------------------
/* Overriding the Ship_To_Contact_Id obtained FROM PA_PROJECT_CONTACTS with the one obtained FROM Award Template */

IF X_Awd_Templ_Ship_Cont_Id IS NOT NULL THEN
  St_Ship_To_Contact_Id := X_Awd_Templ_Ship_Cont_Id;
END IF;
--------------------------------------------------------------------------------

IF St_Ship_To_Contact_Id is NOT NULL THEN

  BEGIN
   SELECT 1
   INTO
   X_Cust_Ship_Cont_Exists
   FROM
   GMS_AWARDS_CONTACTS
   WHERE
      award_id    = X_Award_id
  and customer_id = X_Customer_Id
  and contact_id  = St_Ship_To_Contact_Id
  and usage_code  = 'SHIP_TO';
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
                  NULL;
  END;

  IF X_Cust_Ship_Cont_Exists = -99 THEN
   INSERT INTO GMS_AWARDS_CONTACTS(AWARD_ID
                                  ,CONTACT_ID
                                  ,CUSTOMER_ID
                                  ,USAGE_CODE
                                  ,PRIMARY_FLAG
                                  ,CREATION_DATE
                                  ,CREATED_BY
                                  ,LAST_UPDATE_DATE
                                  ,LAST_UPDATED_BY
                                  ,LAST_UPDATE_LOGIN)
                  VALUES(X_Award_Id
                        ,St_Ship_To_Contact_Id
                        ,NVL(X_Bill_to_customer_id,X_Customer_Id)
                        ,'SHIP_TO'
                        ,'Y'
                        ,SYSDATE
                        ,fnd_global.user_id
                        ,SYSDATE
                        ,fnd_global.user_id
                        ,fnd_global.login_id);
  Elsif X_Cust_Bill_Cont_Exists = 1 THEN

          UPDATE GMS_AWARDS_CONTACTS
          set
          PRIMARY_FLAG = 'Y'
          WHERE
              award_id     = X_Award_Id
          and customer_id  = X_Customer_Id
          and contact_id   = St_Ship_To_Contact_Id
          and usage_code   = 'SHIP_TO';
  END IF;

END IF;

                X_Err_Code := 'S';

          EXCEPTION
          WHEN TOO_MANY_ROWS THEN
                 X_Err_Code := 'E';
                  FND_MESSAGE.SET_NAME('GMS','GMS_MULTI_AWD_CONTACTS_FOUND');
                  FND_MSG_PUB.add;
                  FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
                                            p_data => X_Err_Stage);
                      RETURN;
END;

  EXCEPTION
     WHEN OTHERS THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
             FND_MSG_PUB.add_exc_msg
             (  p_pkg_name              => 'GMS_MULTI_FUNDING'
	       ,p_procedure_name        => 'MODIFY_GMS_CONTACTS'
              );
	  END IF;
          RAISE;
--=======================================================
END MODIFY_GMS_CONTACTS;

PROCEDURE CREATE_AWARD_PROJECT( X_Project_Name                 IN VARCHAR2,
                                X_Project_Number               IN VARCHAR2,
                                X_Customer_Id                  IN NUMBER,
                                X_Bill_to_Customer_Id          IN NUMBER,
                                X_Carrying_Out_Organization_Id IN NUMBER,
                                X_Award_Id                     IN NUMBER,
                                X_IDC_Schedule_Id              IN NUMBER,
                                X_IDC_Schedule_Fixed_Date      IN DATE,
                                X_Labor_Invoice_Format_Id      IN NUMBER,
                                X_Non_Labor_Invoice_Format_Id  IN NUMBER,
                                X_Person_Id                    IN NUMBER,
                                X_Term_Id                      IN NUMBER,
                                X_Start_Date                   IN DATE,
                                X_End_Date                     IN DATE,
                                X_Close_Date                   IN DATE,
                                X_Agreement_Type               IN VARCHAR2,
				X_Revenue_Limit_Flag	       IN VARCHAR2,
								X_Invoice_Limit_Flag           IN VARCHAR2, /*Bug 6642901*/
				X_Billing_Frequency	       IN VARCHAR2,
                                X_billing_cycle_id             IN NUMBER,
                                X_Billing_offset               IN NUMBER,
				X_Bill_To_Address_Id_IN        IN NUMBER,
				X_Ship_To_Address_Id_IN        IN NUMBER,
				X_Bill_To_Contact_Id_IN        IN NUMBER,
				X_Ship_To_Contact_Id_IN        IN NUMBER,
				X_output_tax_code              IN VARCHAR2,
                                X_retention_tax_code           IN VARCHAR2,
                                X_ORG_ID		       IN  NUMBER, --Shared Service Enhancement
                                X_Award_Project_Id             OUT NOCOPY NUMBER,
                                X_Agreement_Id                 OUT NOCOPY NUMBER,
                                X_Bill_To_Address_Id_OUT       OUT NOCOPY NUMBER,
                                X_Ship_To_Address_Id_OUT       OUT NOCOPY NUMBER,
                                X_App_Short_Name               OUT NOCOPY VARCHAR2,
                                X_Msg_Count                    OUT NOCOPY NUMBER,
                                RETCODE                        OUT NOCOPY VARCHAR2,
                                ERRBUF                         OUT NOCOPY VARCHAR2)IS

X_Row_Id                VARCHAR2(30) := '';

X_Awd_Proj_Name         VARCHAR2(30);
X_Awd_Proj_Number       VARCHAR2(25) ;

X_Err_Code              VARCHAR2(1) := NULL;
X_Err_Stage             VARCHAR2(2000) := NULL;

Store_Project_Id        NUMBER := NULL;
Store_Bill_To_Addr_Id   NUMBER := NULL;
Store_Ship_To_Addr_Id   NUMBER := NULL;
Store_Agreement_Id      NUMBER(15) := NULL;

--This variable will help debugging when exception occurs
l_api_name     CONSTANT VARCHAR2(30) := 'CREATE_AWARD_PROJECT';

BEGIN

  G_stage := '(100:Initialize)';

--dbms_output.put_line('AJ01:just after begin');
  FND_MSG_PUB.Initialize;

--dbms_output.put_line('AJ02:just after FND_MSG_PUB');

  X_Awd_Proj_Name    := X_Project_Name;   --||'-A';
  X_Awd_Proj_Number  := X_Project_Number; --||'-A';

  G_stage := '(110:Calling award_project_not_exists)';

---Shared Service Enhancement
--Initialising the context
MO_GLOBAL.SET_POLICY_CONTEXT('S',X_ORG_ID);
--End of Shared Service
  -- Check to see if Award Project already exists for Agreement specified -
  IF AWARD_PROJECT_NOT_EXISTS(X_Award_Id,
                             X_Err_Code,
                             X_Err_Stage) THEN

   G_Stage := '(120:Calling proj_name_num_unique)';

   --dbms_output.put_line('After Award Project Exists Check'||X_Err_Stage);
   --Check to see if Name of Award Project is Unique
   IF PROJ_NAME_NUM_UNIQUE(X_Awd_Proj_Number,
                           X_Awd_Proj_Name,
                           X_Err_Code,
                           X_Err_Stage) THEN

             G_Stage := '(130:Calling insert_award_project)';
             --dbms_output.put_line('After Project Name Number Unique Check'||X_Err_Stage);
             --dbms_output.put_line('AJ03:b4 INSERT_AWARD_PROJECT');
             INSERT_AWARD_PROJECT(X_Customer_Id,
			       X_Bill_to_customer_id,
         	               X_Awd_Proj_Name,
			       X_Awd_Proj_Number,
                               X_Award_Id,
                               X_Carrying_Out_Organization_Id,
                               X_IDC_Schedule_Id,
                               X_IDC_Schedule_Fixed_Date,
                               X_Labor_Invoice_Format_Id,
                               X_Non_Labor_Invoice_Format_Id,
                               X_Start_Date,
                               X_End_Date,
			       X_Close_Date,
                               X_Person_Id,
			       X_Billing_Frequency,
                               X_Billing_Cycle_Id,
                               X_Billing_Offset,
                               Store_Project_Id,
                               Store_Bill_To_Addr_Id,
			       Store_Ship_To_Addr_Id,
                               X_App_Short_Name,
                               X_Err_Code,
                               X_Err_Stage);
                  --dbms_output.put_line('AJ03:b4 INSERT_AWARD_PROJECT');
                  --dbms_output.put_line('After Insert Project'||X_Err_Stage);
                     IF X_Err_Code <> 'S' THEN
                         X_Award_Project_Id := -1;
                         RAISE FND_API.G_EXC_ERROR;
                     ELSE
                         RETCODE := X_Err_Code;
                         X_Award_Project_Id := Store_Project_Id;
                         IF X_Bill_To_Address_Id_IN is NULL THEN
	                     X_Bill_To_Address_Id_OUT := Store_Bill_To_Addr_Id;
                         ELSE
                           X_Bill_To_Address_Id_OUT := NULL;
                         END IF;

                         IF X_Ship_To_Address_Id_IN is NULL THEN
	                     X_Ship_To_Address_Id_OUT := Store_Ship_To_Addr_Id;
                         ELSE
                           X_Ship_To_Address_Id_OUT := NULL;
                         END IF;

                     END IF;

   ELSE
       IF X_Err_Code <> 'S' THEN
                        X_App_Short_Name := 'GMS';
                        RAISE FND_API.G_EXC_ERROR;
       ELSE
          RETCODE := X_Err_Code;
       END IF;
   END IF;
 ELSE
     IF X_Err_Code <> 'S' THEN
                        X_App_Short_Name := 'GMS';
                        RAISE FND_API.G_EXC_ERROR;
     ELSE
        RETCODE := X_Err_Code;
     END IF;
 END IF;

---------------------------------------------------------------------------
/* Updating PA_PROJECT_CUSTOMERS with the Bill_To_Address_Id and Ship_To_Address_Id being used in Award Template */

  G_Stage := '(140:Updating pa_project_customers)';
  IF X_Bill_To_Address_Id_IN IS NOT NULL THEN
    UPDATE PA_PROJECT_CUSTOMERS
    set BILL_TO_ADDRESS_ID = X_Bill_To_Address_Id_IN
       ,LAST_UPDATE_DATE = SYSDATE
       ,LAST_UPDATED_BY  = fnd_global.user_id
       ,LAST_UPDATE_LOGIN = fnd_global.login_id
    WHERE project_id = Store_Project_Id
    and customer_id  = X_Customer_Id;
  END IF;

  G_Stage := '(150:Updating pa_project_customers)';
  IF X_Ship_To_Address_Id_IN IS NOT NULL THEN
   UPDATE PA_PROJECT_CUSTOMERS
   set SHIP_TO_ADDRESS_ID = X_Ship_To_Address_Id_IN
      ,LAST_UPDATE_DATE = SYSDATE
      ,LAST_UPDATED_BY  = fnd_global.user_id
      ,LAST_UPDATE_LOGIN = fnd_global.login_id
   WHERE project_id = Store_Project_Id
   and customer_id = X_Customer_Id;
  END IF;
---------------------------------------------------------------------------

---------------------------------------------------------------------------
  G_Stage := '(160:Updating pa_project_contacts)';
  /* Updating PA_PROJECT_CONTACTS with the contacts got FROM Award Template */
  IF X_Bill_To_Contact_Id_IN IS NOT NULL THEN

    UPDATE PA_PROJECT_CONTACTS
    set contact_id = X_Bill_To_Contact_Id_IN
   ,LAST_UPDATE_DATE = SYSDATE
   ,LAST_UPDATED_BY  = fnd_global.user_id
   ,LAST_UPDATE_LOGIN = fnd_global.login_id
    WHERE project_id = Store_Project_Id
   and customer_id = X_Customer_Id
   and project_contact_type_code = 'BILLING';

  END IF;

  G_Stage := '(170:Updating pa_project_contacts)';
  IF X_Ship_To_Contact_Id_IN IS NOT NULL THEN

    UPDATE PA_PROJECT_CONTACTS
    set contact_id = X_Ship_To_Contact_Id_IN
   ,LAST_UPDATE_DATE = SYSDATE
   ,LAST_UPDATED_BY  = fnd_global.user_id
   ,LAST_UPDATE_LOGIN = fnd_global.login_id
    WHERE project_id = Store_Project_Id
   and customer_id = X_Customer_Id
   and project_contact_type_code = 'SHIPPING';

  END IF;
------------------------------------------------------------------------

------------------------------------------------------------------------
      G_Stage := '(180:Calling modify_gms_contacts)';
     /* Create GMS Contacts */
      MODIFY_GMS_CONTACTS(X_Award_Id,
                          Store_Project_Id,
                          X_Customer_Id,
                          X_Bill_to_Customer_id,
			  X_Bill_To_Contact_Id_IN,
			  X_Ship_To_Contact_Id_IN,
                          X_Err_Code,
                          X_Err_Stage);
                 IF X_Err_Code <> 'S' THEN
                        X_App_Short_Name := 'GMS';
                        RAISE FND_API.G_EXC_ERROR;
                  ELSE
                        RETCODE := X_Err_Code;
                  END IF;

---------------------------------------


 /* Create Award Budget Type */
-- this procedure is not used in 11i as there is no award_budget_type -- Suresh
/*
   INSERT_AWARD_BUDGET_TYPE(X_Budget_Type_Code   => to_char(X_Award_Id),
                            X_Budget_Type        => X_Project_Name,
                            X_Start_Date         => to_date('01011951','DDMMYYYY'),
                            X_End_Date           => NULL,
                            X_Predefined_Flag    => 'N',
                            X_Accumulation_Flag  => 'N',
                            X_Award_Flag         => 'Y',
                            X_Err_Code           => X_Err_Code,
                            X_Err_Stage          => X_Err_Stage) ;

                IF X_Err_Code <> 'S' THEN
                        X_App_Short_Name := 'GMS';
                        RAISE FND_API.G_EXC_ERROR;
                ELSE
                        RETCODE := X_Err_Code;
                END IF;
*/

   G_Stage := '(190:Calling gms_multi_funding.create_agreement)';
   /* Create an Agreement for the Award */
   GMS_MULTI_FUNDING.CREATE_AGREEMENT(X_Row_Id,
                                      Store_Agreement_Id,
                                      X_Customer_Id,
                                      X_Awd_Proj_Number,
                                      X_Agreement_Type,
				      X_Revenue_Limit_Flag,
				      				      X_Invoice_Limit_Flag,  /*Bug 6642901*/
                                      X_Person_Id,
                                      X_Term_Id,
                                      X_Close_Date,
                                      X_ORG_ID, --Shared Service Enhancement
                                      X_Err_Code,
                                      X_Err_Stage) ;
         IF X_Err_Code <> 'S' THEN
            X_Agreement_Id := -1;
            RAISE FND_API.G_EXC_ERROR;
         ELSE
            RETCODE := X_Err_Code;
            X_Agreement_Id := Store_Agreement_Id;
         END IF;


    G_Stage := '(200:Calling update_gms_awards)';
 /* UPDATE GMS_AWARDS with the Agreement_Id and Award_Project_Id */
    UPDATE_GMS_AWARDS(X_Award_Id,
                      Store_Agreement_Id,
                      Store_Project_Id);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    --dbms_output.put_line('P MSG COUNT '||p_msg_count);
    X_Msg_Count := p_msg_count;
    RETCODE := X_Err_Code;
    ERRBUF  := X_Err_Stage;
     --dbms_output.put_line('Returning after Exception');
     --dbms_output.put_line('projID:' || Store_Project_Id);
     --dbms_output.put_line('agreementiD:' || Store_Agreement_Id);
     --dbms_output.put_line('ret:' || X_Err_Code);
     --dbms_output.put_line('error:' || X_Err_Stage);

  -- Added When OTHERS exception for Bug:2662848
  WHEN OTHERS THEN
    RETCODE                  := FND_API.G_RET_STS_UNEXP_ERROR;
    X_Award_Project_Id       := -1;
    X_Agreement_Id           := -1;
    X_Bill_To_Address_Id_OUT := null;
    X_Ship_To_Address_Id_OUT := null;

    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.add_exc_msg
        ( p_pkg_name            => G_PKG_NAME
	 ,p_procedure_name      => l_api_name
         ,p_error_text          => substrb(SQLERRM||G_Stage,1,240)
        );
    END IF;
    FND_MSG_PUB.Count_And_Get
     ( p_count             => x_msg_count
      ,p_data              => X_Err_Stage
     );
    ERRBUF  := 'At stage='||g_stage||' '||X_Err_Stage;

    --Please do not "RAISE" here
    --Instead make sure by checkng RETCODE after the call

END CREATE_AWARD_PROJECT;

PROCEDURE  UPDATE_KEY_MEMBERS(X_Award_Project_Id IN NUMBER,
                              X_Person_Id_Old    IN NUMBER,
                              X_Person_Id_New    IN NUMBER,
                              X_Start_Date       IN DATE,
                              X_End_Date         IN DATE,
                              X_Err_Code         OUT NOCOPY VARCHAR2,
                              X_Err_Stage        OUT NOCOPY VARCHAR2) IS
St_Start_Date  DATE;
St_End_Date    DATE;
BEGIN

 BEGIN
   Select
   start_date_active,
   end_date_active
   INTO
   St_Start_Date,
   St_End_Date
   FROM PA_PROJECT_PLAYERS
   WHERE PROJECT_ID = X_Award_Project_Id
   and   PERSON_ID  = X_Person_Id_Old
   and   PROJECT_ROLE_TYPE = 'PROJECT MANAGER';

           X_Err_Code := 'S';

       EXCEPTION
         WHEN NO_DATA_FOUND THEN
                         X_Err_Code := 'E';
          FND_MESSAGE.SET_NAME('GMS','GMS_PROJ_MANAGER_NOT_FOUND');
          FND_MSG_PUB.add;
          FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
                                    p_data => X_Err_Stage);
                      RETURN;
         WHEN TOO_MANY_ROWS THEN
                         X_Err_Code := 'E';
          FND_MESSAGE.SET_NAME('GMS','GMS_MULTI_PROJ_MANAGER_FOUND');
          FND_MSG_PUB.add;
          FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
                                    p_data => X_Err_Stage);
                      RETURN;

 END;

  IF ((X_Person_Id_Old <> X_Person_Id_New) OR
      (St_Start_Date <> X_Start_Date)      OR
      (St_End_Date <> X_End_Date)          OR
      (St_End_Date IS NULL )
      ) THEN
/* Commented out NOCOPY for bug fix 1533504 as this a view now in 11i
      UPDATE pa_project_players
      set person_id         = X_Person_Id_New,
          start_date_active = X_Start_Date,
          end_date_active   = X_End_Date
      WHERE
       project_id         = X_Award_Project_Id
   and person_id          = X_Person_Id_Old
   and project_role_type  = 'PROJECT MANAGER';
   */

    UPDATE pa_project_parties
         set resource_source_id = X_Person_Id_New,
          start_date_active = X_Start_Date,
          end_date_active   = X_End_Date
      WHERE
       project_id         = X_Award_Project_Id
   and resource_source_id = X_Person_Id_Old
   and project_role_id in (SELECT project_role_id FROM pa_project_role_types
                             WHERE project_role_type = 'PROJECT MANAGER');

         X_Err_Code := 'S';

     IF SQL%NOTFOUND THEN
       X_Err_Code := 'E';
       FND_MESSAGE.SET_NAME('GMS','GMS_PROJ_MANAGER_NOT_FOUND');
       FND_MSG_PUB.add;
       FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
				 p_data  => X_Err_Stage);
               RETURN;
     END IF;


  ELSE

        X_Err_Code := 'S';

  END IF;

  -- Added Exception for Bug:2662848
Exception
When OTHERS THEN
  RAISE;
END UPDATE_KEY_MEMBERS;


PROCEDURE update_award_project
( x_award_id                       IN NUMBER
 ,x_award_project_id               IN NUMBER
 ,x_agreement_id                   IN NUMBER
 ,x_project_number                 IN VARCHAR2
 ,x_project_name                   IN VARCHAR2
 ,X_Customer_Id                    IN NUMBER
 ,X_Bill_to_Customer_Id            IN NUMBER
 ,X_Carrying_Out_Organization_Id   IN NUMBER
 ,X_IDC_Schedule_Id                IN NUMBER
 ,X_IDC_Schedule_Fixed_Date        IN DATE
 ,X_Labor_Invoice_Format_Id        IN NUMBER
 ,X_Non_Labor_Invoice_Format_Id    IN NUMBER
 ,X_Person_Id_Old                  IN NUMBER
 ,X_Person_Id_New                  IN NUMBER
 ,X_Term_Id                        IN NUMBER
 ,X_Start_Date                     IN DATE
 ,X_End_Date                       IN DATE
 ,X_Close_Date                     IN DATE
 ,X_Agreement_Type                 IN VARCHAR2
 ,X_Revenue_Limit_Flag             IN VARCHAR2
  ,X_Invoice_Limit_Flag             IN VARCHAR2 /*Bug 6642901*/
 ,X_Billing_Frequency              IN VARCHAR2
 ,X_Billing_cycle_Id               IN NUMBER
 ,X_Billing_Offset                 IN NUMBER
 ,X_Bill_To_Address_Id_IN          IN NUMBER
 ,X_Ship_To_Address_Id_IN          IN NUMBER
 ,X_output_tax_code                IN VARCHAR2
 ,X_retention_tax_code             IN VARCHAR2
 ,X_Bill_To_Address_Id_OUT        OUT NOCOPY NUMBER
 ,X_Ship_To_Address_Id_OUT        OUT NOCOPY NUMBER
 ,X_App_Short_Name                OUT NOCOPY VARCHAR2
 ,X_Msg_Count                     OUT NOCOPY NUMBER
 ,retcode                         OUT NOCOPY VARCHAR2
 ,errbuf                          OUT NOCOPY VARCHAR2
) IS

  X_Product_Code                  VARCHAR2(30);

  X_Err_Code                      VARCHAR2(1);
  X_Err_Stage                     VARCHAR2(2000);
  X_Text                          VARCHAR2(200);
  x_err_stack                     VARCHAR2(2000);
  x_return_status                 VARCHAR2(1);
  x_msg_data                      VARCHAR2(2000);

  X_Index                         NUMBER(15);

  X_Created_From_Project_Id       NUMBER;

  X_Project_IN_REC                PA_PROJECT_PUB.PROJECT_IN_REC_TYPE;
  X_Project_OUT_REC               PA_PROJECT_PUB.PROJECT_OUT_REC_TYPE;
  X_Key_Members_IN_REC            PA_PROJECT_PUB.PROJECT_ROLE_REC_TYPE;
  X_Key_Members_IN_TBL            PA_PROJECT_PUB.PROJECT_ROLE_TBL_TYPE;
  X_Class_Categories_IN_TBL       PA_PROJECT_PUB.CLASS_CATEGORY_TBL_TYPE;
  X_Tasks_IN_REC                  PA_PROJECT_PUB.TASK_IN_REC_TYPE;
  X_Tasks_In_TBL                  PA_PROJECT_PUB.TASK_IN_TBL_TYPE;
  X_Tasks_Out_TBL                 PA_PROJECT_PUB.TASK_OUT_TBL_TYPE;

  --Bug 3576717
  X_Deliverable_IN_TBL            PA_PROJECT_PUB.DELIVERABLE_IN_TBL_TYPE;

  -- Bug 3650374
  --X_Deliverable_OUT_TBL         PA_PROJECT_PUB.DELIVERABLE_OUT_TBL_TYPE;
  --X_Deliverable_Action_OUT_TBL  PA_PROJECT_PUB.ACTION_OUT_TBL_TYPE;

  X_Deliverable_Action_IN_TBL     PA_PROJECT_PUB.ACTION_IN_TBL_TYPE;

  X_Awd_Proj_Name                 VARCHAR2(240);
  X_Awd_Proj_Number               VARCHAR2(30);

  --St_Award_Project_Id           NUMBER(15);
  St_Billing_Offset               NUMBER(15);
  St_Billing_Cycle                NUMBER(15);
  St_Revenue_Limit_Flag           VARCHAR2(1);
 St_Invoice_Limit_Flag           VARCHAR2(1); /*Bug 6642901*/
  X_Task_ID_To_UPDATE             NUMBER(15);
  X_Task_Proj_Compl_Date          DATE;
  X_Task_Proj_Start_Date          DATE;

  X_Task_ID_OUT                   NUMBER(15);
  X_Task_PM_Reference_OUT         VARCHAR2(30);

  St_Bill_To_Address_Id           NUMBER(15);
  St_Ship_To_Address_Id           NUMBER(15);
  X_Bill_To_Contact_Id            NUMBER(15);
  X_Ship_To_Contact_Id            NUMBER(15);

  X_Bill_To_Address_PASSED        NUMBER(15);
  X_Ship_To_Address_PASSED        NUMBER(15);

  X_Workflow_Started              VARCHAR2(1);  -- R11 Changes
  x_default_org_id                VARCHAR2(15);

  --Bug Fix 2994625

  -- Bug Fix 3062140
  -- The declaration of l_ship_to_customer_id is causing ora 6502
  -- The issue is it is declared as %type that means it is number 15 and it is
  -- initialized with g_pa_miss_num which is initialized to a really big number
  -- so stopped initializing to the g_pa_miss_num.

  l_bill_to_customer_id pa_project_customers.bill_to_customer_id%TYPE := X_bill_to_customer_id;
  l_ship_to_customer_id pa_project_customers.ship_to_customer_id%TYPE := X_bill_to_customer_id ;

  --END Of fix 3062140

  l_err_code NUMBER;
  bill_to_contact_exists number;
  ship_to_contact_exists number;

  --This will help debugging when exception occurs
  l_api_name  CONSTANT VARCHAR2(30) := 'UPDATE_AWARD_PROJECT';

  l_org_id  NUMBER; --Shared Service Enhancement

  BEGIN

    G_Stage := '(300:Calling fnd_msg_pub.initialize)';
    FND_MSG_PUB.Initialize;
---Shared Service Enhancement
--Get the org_id from award_project_id being passed
--Set the ORg context
SELECT org_id
INTO   l_org_id
FROM   gms_awards_all
WHERE  award_id = X_award_id;

MO_GLOBAL.SET_POLICY_CONTEXT('S',l_org_id);
--End of Shared Service enhancement

    --Getting Org Id
    SELECT TO_CHAR(NVL(org_id,-999))
      INTO x_default_org_id
      FROM gms_implementations;

    G_Stage := '(310:select from pa_projects)';

    --Get X_Created_From_Project_Id
    --Bug Fix 2447491:
    --After upgrading to multi org FROM non multi org, the award project
    --template will still have segment1 'AWD_PROJ_-999. To use the template
    --the code is modified.

    BEGIN

      SELECT project_id
        INTO X_Created_From_Project_Id
        FROM PA_PROJECTS
       WHERE project_type  = 'AWARD_PROJECT'
         AND template_flag = 'Y'
         AND (segment1     = 'AWD_PROJ_'||x_default_org_id
              OR
              segment1     = 'AWD_PROJ_-999'
             );

      X_Err_Code    :=   'S';
    EXCEPTION
       WHEN OTHERS THEN

         X_Err_Code       := FND_API.G_RET_STS_UNEXP_ERROR; --'U';
         X_Err_Stage      := SQLERRM;
         X_App_Short_Name := 'GMS';
         FND_MESSAGE.SET_NAME('GMS','GMS_UNEXPECTED_ERROR');
         FND_MESSAGE.SET_TOKEN('PROGRAM_NAME','GMS_MULTI_FUNDING: UPDATE_AWARD_PROJECT');
         FND_MESSAGE.SET_TOKEN('OERRNO',SQLCODE);
         FND_MESSAGE.SET_TOKEN('OERRRM',SQLERRM);
         FND_MSG_PUB.add;
         FND_MSG_PUB.Count_And_Get(p_count  => p_msg_count,
                              p_data   => X_Err_Stage);
         RAISE FND_API.G_EXC_ERROR;
    END;

    X_Awd_Proj_Name    := X_Project_Name;
    X_Awd_Proj_Number  := X_Project_Number;

    G_Stage := '(320:Select from pa_tasks)';

    --Getting the Only Task ID and its Completion Date (also the Project Completion Date)
    --of this Award Project to UPDATE Task Information

    BEGIN

     SELECT task_id, trunc(start_date), trunc(completion_date)
       INTO X_Task_ID_To_UPDATE, X_Task_Proj_Start_Date, X_Task_Proj_Compl_Date
       FROM pa_tasks
      WHERE project_id = X_Award_Project_Id;

     EXCEPTION
        WHEN OTHERS THEN

          X_Err_Code       := 'U';
          X_Err_Stage      := SQLERRM;
          X_App_Short_Name := 'GMS';

          RAISE;
    END;
    -- For Bug 3061336 : Moved the get_customer_info up to get the correct values of bill_to_customer_id
    -- and ship_to_customer_id
    -- Commented for Bug 1656812
    -- Bug Fix 2994625
    -- This will blindly returns all the details for one customer.
    -- Where as we need the billing address and contact FROM LOC if it exists
    -- and rest of the details FROM the funding source.
    -- We can use pa_project_customer_get_customer_info which exactly does that.

    G_Stage := '(330:Calling pa_customer_info.get_customer_info)';
    pa_customer_info.get_customer_info
    ( x_project_id              =>      null
     ,x_customer_id             =>      x_customer_id
     ,x_bill_to_customer_id     =>      l_bill_to_customer_id
     ,x_ship_to_customer_id     =>      l_ship_to_customer_id
     ,x_bill_to_address_id 	=>      st_bill_to_address_id
     ,x_ship_to_address_id 	=>      st_ship_to_address_id
     ,x_bill_to_contact_id 	=>	X_bill_to_contact_id
     ,x_ship_to_contact_id 	=>	X_ship_to_contact_id
     ,x_err_code           	=>	l_err_code
     ,x_err_stage          	=>	X_err_stage
     ,x_err_stack          	=>	X_err_stack
    );

   --Initializing the Tables
   X_Product_Code                                := 'GMS';
   X_Project_IN_REC.PA_PROJECT_ID                := X_Award_Project_Id;
   X_Project_IN_REC.PM_PROJECT_REFERENCE         := X_Awd_Proj_Number;

   --dbms_output.put_line('Project Number before for UPDATE is '||X_Awd_Proj_Number);

   X_Project_IN_REC.PA_PROJECT_NUMBER            := X_Awd_Proj_Number;

   --dbms_output.put_line('Project Number after for UPDATE is '||X_Project_IN_REC.PA_PROJECT_NUMBER);

   X_Project_IN_REC.PROJECT_NAME                 := X_Awd_Proj_Name;
   X_Project_IN_REC.CREATED_FROM_PROJECT_ID      := X_Created_From_Project_Id;
   X_Project_IN_REC.CARRYING_OUT_ORGANIZATION_ID := X_Carrying_Out_Organization_Id;
   X_Project_IN_REC.CUSTOMER_ID                  := X_Customer_Id;
   X_Project_IN_REC.DISTRIBUTION_RULE            := 'EVENT/EVENT';
   X_Project_IN_REC.PROJECT_RELATIONSHIP_CODE    := 'PRIMARY';
   X_Project_IN_REC.OUTPUT_TAX_CODE              := x_output_tax_code;
   X_Project_IN_REC.RETENTION_TAX_CODE           := x_retention_tax_code;

/*=======================================================================================================
 The Key Member information will be UPDATEd separately inorder to prevent Multiple Project Managers FROM
   being created.

   X_Key_Members_IN_REC.PERSON_ID           := X_Person_Id;
   X_Key_Members_IN_REC.PROJECT_ROLE_TYPE   := 'PROJECT MANAGER';
   X_Key_Members_IN_REC.START_DATE          := X_Start_Date;
   X_Key_Members_IN_REC.END_DATE            := X_End_Date;


   X_Key_Members_IN_TBL(1) := X_Key_Members_IN_REC;
=========================================================================================================
*/

    --NOTE: Column requires change should be passed to these APIs.
         -- e.g. With respect to Task changes, task_name, number or
         -- references always remain the same. Only passing task_id
         -- and other information requested for a change.

      --Bug 3598343
      --introduced by sanbaner
      X_Tasks_IN_REC.pa_task_id                  := X_Task_ID_To_UPDATE ;

    --commented by sanbaner
    --X_Tasks_IN_REC.task_name                   := X_Awd_Proj_Number||'-'||'Tsk1'; --X_Task_Name;
    --X_Tasks_IN_REC.pa_task_number              := X_Awd_Proj_Number||'-'||'T1';    --X_Task_Number;
    --X_Tasks_IN_REC.pm_task_reference           := X_Awd_Proj_Number;

      X_Tasks_IN_REC.cost_ind_rate_sch_id        := X_IDC_Schedule_Id;
      X_Tasks_IN_REC.TASK_START_DATE             := X_Start_Date;
      X_Tasks_IN_REC.TASK_COMPLETION_DATE        := X_End_Date;


     --dbms_output.put_line('First I got here !!!');

     /*-------- First Call to UPDATE_PROJECT ----------*/
     X_Project_IN_REC.START_DATE          := LEAST(X_Start_Date,X_Task_Proj_Start_Date);
     X_Project_IN_REC.COMPLETION_DATE     := GREATEST(X_End_Date,X_Task_Proj_Compl_Date);

    --dbms_output.put_line('Project+++++ Number '||X_Project_IN_REC.PA_PROJECT_NUMBER);

    /** Bug 3547727 : Start
     ** Task was not passed. PA_PROJECT_PUB.UPDATE_PROJECT will raise an error PA_TASK_REF_AND_ID_MISSING
     ** when task_id and task_reference both are NULL
     **/
        X_Tasks_IN_TBL(1) := X_Tasks_IN_REC;

    /** Bug 3547727 : End
     **/

          x_project_in_rec.bill_to_customer_id      := l_bill_to_customer_id;
          x_project_in_rec.ship_to_customer_id      := l_ship_to_customer_id; --Modified for bug 3061336

	  x_project_in_rec.bill_to_address_id := X_Bill_To_Address_Id_IN; --Added for bug 3977859
          x_project_in_rec.ship_to_address_id := X_Ship_To_Address_Id_IN; --Added for bug 3977859

          G_Stage := '(340:Calling pa_project_pub.update_project)';
          PA_PROJECT_PUB.UPDATE_PROJECT
          ( p_api_version_number      => 1.0
           ,p_init_msg_list           => 'T'
           ,p_msg_count               => p_msg_count
           ,p_msg_data                => X_Err_Stage
           ,p_return_status           => X_Err_Code
           ,p_project_in              => X_Project_IN_REC
           ,p_project_out             => X_Project_OUT_REC
           ,p_pm_product_code         => X_Product_Code
           ,p_key_members             => X_Key_Members_IN_TBL  --Key Members will be UPDATEd separately
           ,p_class_categories        => X_Class_Categories_IN_TBL
           ,p_tasks_in                => X_Tasks_IN_TBL
           ,p_tasks_out               => X_Tasks_OUT_TBL
           ,p_workflow_started        => X_Workflow_Started
          --Bug 3576717
           ,p_deliverables_in         => X_Deliverable_IN_TBL
           --,p_deliverables_out        => X_Deliverable_OUT_TBL (3650374)
           ,p_deliverable_actions_in  => X_Deliverable_Action_IN_TBL
           --,p_deliverable_actions_out => X_Deliverable_Action_OUT_TBL (3650374)
           );

            --dbms_output.put_line('THEN I got here !!!');
              IF X_Err_Code <> 'S' THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSE
                 RETCODE := X_Err_Code;
              END IF;
          --Bug 3598343  : Commented
          --Not required as pa_project_pub.update_project is already doing.
          /******

                G_Stage := '(350:calling pa_project_pub.update_task)';
                -- UPDATE Task Information to take care of any Project Incompatibility
                   PA_PROJECT_PUB.UPDATE_TASK
                          (p_api_version_number      => 1.0,
                           p_pa_project_id           => X_Award_Project_Id,
	                   p_pa_task_id              => X_Task_Id_To_UPDATE,
                           p_init_msg_list           => 'T',
			   p_msg_count               => p_msg_count,
                           p_msg_data                => X_Err_Stage,
			   p_return_status    	     => X_Err_Code,
                           p_pm_project_reference    => X_Awd_Proj_Number,
                           p_pm_task_reference       => X_Awd_Proj_Number,
                           p_pm_product_code         => X_Product_Code,
			   p_task_number       	     => X_Awd_Proj_Number||'-'||'T1',
			   p_task_name	     	     => X_Awd_Proj_Number||'-'||'Tsk1',
			   p_task_start_date   	     => X_Start_Date,
			   p_task_completion_date    => X_End_Date,
			   p_out_pa_task_id          => X_Task_ID_OUT,
			   p_out_pm_task_reference   => X_Task_PM_Reference_OUT);

                           IF X_Err_Code <> 'S' THEN
                              FND_MESSAGE.PARSE_ENCODED
                                   ( encoded_message => X_Err_Stage,
                                     APP_SHORT_NAME  => X_App_Short_Name,
                                     MESSAGE_NAME    => X_Text
                                   );

                              RAISE FND_API.G_EXC_ERROR;
                           ELSE
                              RETCODE := X_Err_Code;
                           END IF;
           *****/

/* ----------------Second Call to UPDATE_PROJECT-----------------------*/

   X_Project_IN_REC.START_DATE                   := X_Start_Date;
   X_Project_IN_REC.COMPLETION_DATE              := X_End_Date;

          --      commented by syb
          --
          --      G_Stage := '(360:Calling pa_project_pub.update_project)';
          --      PA_PROJECT_PUB.UPDATE_PROJECT
          --      ( p_api_version_number => 1.0,
          --        p_init_msg_list => 'T',
          --        p_msg_count => p_msg_count,
          --        p_msg_data => X_Err_Stage,
          --        p_return_status => X_Err_Code,
          --        p_project_in => X_Project_IN_REC,
          --        p_project_out => X_Project_OUT_REC,
          --        p_pm_product_code => X_Product_Code,
          --        p_key_members => X_Key_Members_IN_TBL, --Key Members will be UPDATEd separately
          --        p_class_categories => X_Class_Categories_IN_TBL,
          --        p_tasks_in => X_Tasks_IN_TBL,
          --        p_tasks_out => X_Tasks_OUT_TBL,
          --	    p_workflow_started => X_Workflow_Started,
          --      --Bug 3576717
          --        p_deliverables_in        => X_Deliverable_IN_TBL,
          --        p_deliverables_out       => X_Deliverable_OUT_TBL,
          --        p_deliverable_actions_in => X_Deliverable_Action_IN_TBL,
          --        p_deliverable_actions_out=> X_Deliverable_Action_OUT_TBL
          --      );

                   --dbms_output.put_line('THEN I got here !!!');
                   IF X_Err_Code <> 'S' THEN
                      RAISE FND_API.G_EXC_ERROR;
                   ELSE
                      RETCODE := X_Err_Code;
                   END IF;
-----------------------------------------------------------------------------------------------


        --dbms_output.put_line('The Project that got created is 1 '||to_char(X_Project_OUT_REC.pa_project_id));
        --dbms_output.put_line('The Project that got created is 2'||to_char(X_Award_Project_Id));

        --St_Award_Project_Id := X_Award_Project_Id;

                  G_Stage := '(370:Calling update_project_add_info)';
                  UPDATE_PROJECT_ADD_INFO
                  (  X_Award_Project_Id,
                     X_IDC_Schedule_Id,
                     X_IDC_Schedule_Fixed_Date,
                     X_Labor_Invoice_Format_Id,
                     X_Non_Labor_Invoice_Format_Id,
                     X_Billing_Cycle_Id,
                     X_Billing_Offset,
                     X_Err_Code,
                     X_Err_Stage
                   );
                   IF X_Err_Code <> 'S' THEN
                      X_App_Short_Name := 'GMS';
                      RAISE FND_API.G_EXC_ERROR;
                   ELSE
                      RETCODE := X_Err_Code;
                   END IF;

             -- Commented for Bug 1656812
             /* UPDATE_KEY_MEMBERS
                        (X_Award_Project_Id,
                         X_Person_Id_Old,
                         X_Person_Id_New,
                         X_Start_Date,
                         X_End_Date,
                         X_Err_Code,
                         X_Err_Stage);
                  IF X_Err_Code <> 'S' THEN
                        X_App_Short_Name := 'GMS';
                        RAISE FND_API.G_EXC_ERROR;
                  ELSE
                        RETCODE := X_Err_Code;
                  END IF;
                  --dbms_output.put_line('Successfully UPDATEd Key Members ');
               */
               /*****************
                For bug 3061336 :Commenting the code . Moved the code up
              -- Commented for Bug 1656812
              -- Bug Fix 2994625
              -- This will blindly returns all the details for one customer.
              -- Where as we need the billing address and contact FROM LOC if it exists
              -- and rest of the details FROM the funding source.
              -- We can use pa_project_customer_get_customer_info which exactly does that.

              pa_customer_info.get_customer_info
              ( X_PROJECT_ID            =>      NULL,
	        X_CUSTOMER_ID   	=>      X_Customer_Id,
 	        X_BILL_TO_CUSTOMER_ID   =>      l_bill_to_customer_id,
 	        X_SHIP_TO_CUSTOMER_ID   =>      l_ship_to_customer_id,
	        X_BILL_TO_ADDRESS_ID 	=>	St_Bill_To_Address_Id,
	        X_SHIP_TO_ADDRESS_ID 	=>	St_Bill_To_Address_Id,
	        X_BILL_TO_CONTACT_ID 	=>	X_bill_to_contact_id,
	        X_SHIP_TO_CONTACT_ID 	=>	X_ship_to_contact_id,
	        X_ERR_CODE           	=>	l_err_code,
	        X_ERR_STAGE          	=>	X_err_stage,
	        X_ERR_STACK          	=>      X_err_stack );
                ***/
                /*
                 GET_CUSTOMER_INFO(X_Customer_Id,
		       St_Bill_To_Address_Id,
		       St_Ship_To_Address_Id,
		       X_Bill_To_Contact_Id,
		       X_Ship_To_Contact_Id,
                       X_Err_Code,
 		       X_Err_Stage);
                 IF X_Err_Code <> 'S' THEN
                        X_App_Short_Name := 'GMS';
                        RAISE FND_API.G_EXC_ERROR;
                 ELSE
                        RETCODE := X_Err_Code;
                 END IF;

                 IF X_Bill_To_Address_Id_IN IS NULL THEN
                     X_Bill_To_Address_Id_OUT := St_Bill_To_Address_Id;
                 ELSE
                     X_Bill_To_Address_Id_OUT := NULL;
                 END IF;

                 IF X_Ship_To_Address_Id_IN IS NULL THEN
                     X_Ship_To_Address_Id_OUT := St_Ship_To_Address_Id;
                 ELSE
                     X_Ship_To_Address_Id_OUT := NULL;
                 END IF;

                 IF X_Bill_To_Address_Id_IN IS NOT NULL THEN
                    X_Bill_To_Address_PASSED := X_Bill_To_Address_Id_IN;
                 ELSE
                    X_Bill_To_Address_PASSED := St_Bill_To_Address_Id;
                 END IF;

                 IF X_Ship_To_Address_Id_IN IS NOT NULL THEN
                    X_Ship_To_Address_PASSED := X_Ship_To_Address_Id_IN;
                 ELSE
                    X_Ship_To_Address_PASSED := St_Ship_To_Address_Id;
                 END IF;
                 */

                 /* Namburi
                    UPDATE_PROJ_CUST_CONTACTS(X_Award_Project_Id,
			       X_Customer_Id,
			       X_Bill_To_Address_PASSED,
			       X_Ship_To_Address_PASSED,
			       X_Bill_To_Contact_Id,
			       X_Ship_To_Contact_Id,
			       X_Err_Code,
			       X_Err_Stage);
                  IF X_Err_Code <> 'S' THEN
                        X_App_Short_Name := 'GMS';
                        RAISE FND_API.G_EXC_ERROR;
                  ELSE
                        RETCODE := X_Err_Code;
                  END IF;
                  */
-- Bug Fix 2994625
-- Create contacts in the pa_project_contacts by calling pa_customer_info.create_customer_contacts
-- instead of inserting directly INTO the tables
  G_Stage := '(380:select from pa_project_contacts)';
  BEGIN
     Select
     contact_id
     INTO
     Bill_To_Contact_exists
     FROM
     PA_PROJECT_CONTACTS
     WHERE project_id = X_Award_Project_Id
   and customer_id = X_Customer_Id
   and project_contact_type_code = 'BILLING';
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
        NULL;
  END;

   G_Stage := '(390:Calling pa_customers_contacts_pub.create_customer_contact)';
   IF bill_to_contact_exists IS NULL THEN

    pa_customers_contacts_pub.create_customer_contact
(  p_api_version                   => 1.0
  ,p_init_msg_list                 => FND_API.G_TRUE
  ,p_commit                        => FND_API.G_FALSE
  ,p_validate_only                 => FND_API.G_FALSE
  ,p_validation_level              => FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module                => 'FORM'
  ,p_debug_mode                    => 'N'
  ,p_max_msg_count                 => FND_API.G_MISS_NUM
  ,p_project_id                    => X_AWARD_PROJECT_ID
  ,p_customer_id                   => X_CUSTOMER_ID
  ,p_bill_ship_customer_id         => l_BILL_TO_CUSTOMER_ID
  ,p_contact_id                    => X_bill_to_contact_id
  ,p_contact_name                  => FND_API.G_MISS_CHAR
  ,p_project_contact_type_code     => 'BILLING'
  ,p_project_contact_type_name     =>  FND_API.G_MISS_CHAR
  ,x_return_status                 =>  X_return_status
  ,x_msg_count                     =>  x_msg_count
  ,x_msg_data                      =>  x_msg_data);
   END IF;

  BEGIN
    G_Stage := '(400:Select from pa_project_contacts)';
    Select contact_id
      INTO Ship_To_Contact_exists
      FROM PA_PROJECT_CONTACTS
     WHERE project_id = X_Award_Project_Id
       and customer_id = X_Customer_Id
       and project_contact_type_code = 'SHIPPING';
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
             NULL;
  END;

  G_Stage := '(410:calling pa_customers_contacts_pub.create_customer_contact)';
  IF ship_to_contact_exists is NULL THEN

    pa_customers_contacts_pub.create_customer_contact
  (p_api_version                   => 1.0
  ,p_init_msg_list                 => FND_API.G_TRUE
  ,p_commit                        => FND_API.G_FALSE
  ,p_validate_only                 => FND_API.G_FALSE
  ,p_validation_level              => FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module                => 'FORM'
  ,p_debug_mode                    => 'N'
  ,p_max_msg_count                 => FND_API.G_MISS_NUM
  ,p_project_id                    => X_AWARD_PROJECT_ID
  ,p_customer_id                   => X_CUSTOMER_ID
  ,p_bill_ship_customer_id         => l_SHIP_TO_CUSTOMER_ID
  ,p_contact_id                    => X_ship_to_contact_id
  ,p_contact_name                  => FND_API.G_MISS_CHAR
  ,p_project_contact_type_code     => 'SHIPPING'
  ,p_project_contact_type_name     =>  FND_API.G_MISS_CHAR
  ,x_return_status                 =>  X_return_status
  ,x_msg_count                     =>  x_msg_count
  ,x_msg_data                      =>  x_msg_data);

  END IF;

    G_Stage := '(420:Calling modify_gms_contacts)';
    modify_gms_contacts(X_Award_Id,
			X_Award_Project_Id,
			X_Customer_Id,
			X_Bill_to_customer_id,
                        NULL,
                        NULL,
			X_Err_Code,
			X_Err_Stage);

                  IF X_Err_Code <> 'S' THEN
                        X_App_Short_Name := 'GMS';
                        RAISE FND_API.G_EXC_ERROR;
                  ELSE
                        RETCODE := X_Err_Code;
                  END IF;

      -- Award budget type not used in 11i. Hence the following call is commented
/*
      UPDATE_AWARD_BUDGET_TYPE(X_Budget_Type_Code => to_char(X_Award_Id),
                               X_Budget_Type      => X_Project_Name,
                               X_Start_Date       => X_Start_Date, -- Start Date and
                               X_End_Date         => X_End_Date,   -- END Date are no longer being used in
                               X_Err_Code         => X_Err_Code,   -- UPDATE of Budget Type
                               X_Err_Stage        => X_Err_Stage) ;
                  IF X_Err_Code <> 'S' THEN
                        X_App_Short_Name := 'GMS';
                        RAISE FND_API.G_EXC_ERROR;
                  ELSE
                        RETCODE := X_Err_Code;
                  END IF;
*/

         --dbms_output.put_line('Successfully UPDATEd AWARD BUDGET TYPE ');

/*-------------------------Check for Revenue Limit Flag UPDATE Allowability---------------*/
/* Bug 1841288  : Commenting out NOCOPY below code as all the hard_limit_flag validation is already been done
                 in check_funding_limit procedure of GMSAWEAW.fmb.


   BEGIN
    select
    revenue_limit_flag
    INTO
    St_Revenue_Limit_Flag
    FROM
    PA_AGREEMENTS
    WHERE
    agreement_id = X_Agreement_Id;
   END ;
    --dbms_output.put_line('Got after SELECT of Revenue Limit Flag ');

 IF ALLOW_REV_LIMIT_FLAG_UPDATE(X_Agreement_Id,
                                X_Err_Code,
				X_Err_Stage) THEN

   IF ((X_Revenue_Limit_Flag IS NOT NULL) AND (St_Revenue_Limit_Flag <> X_Revenue_Limit_Flag)) THEN
            RETCODE := X_Err_Code;
   END IF;

 ELSE

   IF (( X_Revenue_Limit_Flag IS NOT NULL) AND (St_Revenue_Limit_Flag <> X_Revenue_Limit_Flag)) THEN
                 RAISE FND_API.G_EXC_ERROR;
   ELSE
                 RETCODE := X_Err_Code;
   END IF;

 END IF;
*/
-- END of modifications for bug 1841288
/*-----------------------------------------------------------------------------------------*/
      G_Stage := '(430:CALLING GMS_MULTI_FUNDING.UPDATE_AGREEMENT)';
      GMS_MULTI_FUNDING.UPDATE_AGREEMENT(X_Agreement_Id => X_Agreement_Id,
                                         X_Agreement_Num => X_Awd_Proj_Number,
                                         X_Agreement_Type => X_Agreement_Type,
	                                 X_Revenue_Limit_Flag => X_Revenue_Limit_Flag,
	                                 X_Invoice_Limit_Flag => X_Invoice_Limit_Flag, /*Bug 6642901*/
                                         X_Customer_Id => X_Customer_Id,
                                         X_Owned_By_Person_Id => X_Person_Id_New,
                                         X_Term_Id => X_Term_Id,
                                         X_Amount => 0,
                                         X_Close_Date => X_Close_Date,
                                         RETCODE => X_Err_Code,
                                         ERRBUF => X_Err_Stage);

                 --dbms_output.put_line('After UPDATE Agreement - Code '||X_Err_Code);

                IF X_Err_Code <> 'S' THEN
                       X_App_Short_Name := 'GMS';
                       RAISE FND_API.G_EXC_ERROR;
                ELSE
                       RETCODE := X_Err_Code;
                END IF;

EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
      X_Msg_Count := p_msg_count;
      RETCODE := X_Err_Code;
      ERRBUF  := X_Err_Stage||' at '||g_stage;
 -- Added when others exception for Bug:2662848
 WHEN OTHERS THEN
        RETCODE                 := 'U';
        FND_MSG_PUB.add_exc_msg
	  (  p_pkg_name		=> G_PKG_NAME
	    ,p_procedure_name	=> l_api_name
            ,p_error_text       => substrb(SQLERRM||' at stage='||g_stage||' ',1,240)
        );
        FND_MSG_PUB.Count_And_Get
          ( p_count             => p_msg_count,
            p_data              => X_Err_Stage);
        ERRBUF                  := 'At stage='||g_stage||' '||X_Err_Stage;

    --Calling program should make sure by checkng RETCODE after the call
END update_award_project;

PROCEDURE DELETE_AWARD_PROJECT(X_Award_Id         IN NUMBER,
                               X_Award_Project_Id IN NUMBER,
                               X_Agreement_Id     IN NUMBER,
                               X_App_Short_Name   OUT NOCOPY VARCHAR2,
                               X_Msg_Count        OUT NOCOPY NUMBER,
                               RETCODE            OUT NOCOPY VARCHAR2,
                               ERRBUF             OUT NOCOPY VARCHAR2) IS
X_Awd_Proj_Number VARCHAR2(30);

X_Product_Code VARCHAR2(30);

X_Err_Code  VARCHAR2(1);
X_Err_Stage VARCHAR2(2000);
X_Text      VARCHAR2(200);
--X_Msg_Count NUMBER;

--This variable will help debugging when exception occurs

BEGIN
 G_Stage := '(600:SELECT PA_PROJECTS)';
 BEGIN
   SELECT
   segment1
   INTO
   X_Awd_Proj_Number
   FROM
   PA_PROJECTS
   WHERE
   PROJECT_ID = X_Award_Project_Id;
 END;
   X_Product_Code := 'GMS';

 G_Stage := '(610:CALLING PA_PROJECT_PUB.DELETE_PROJECT)';
 PA_PROJECT_PUB.DELETE_PROJECT( P_API_VERSION_NUMBER   => 1.0,
                                p_init_msg_list => 'T',
                                P_MSG_COUNT            => p_msg_count,
                                P_MSG_DATA             => X_Err_Stage,
                                P_RETURN_STATUS        => X_Err_Code,
                                P_PM_PRODUCT_CODE      => X_Product_Code,
                                P_PM_PROJECT_REFERENCE => X_Awd_Proj_Number,
                                P_PA_PROJECT_ID        => X_Award_Project_Id );

                    IF X_Err_Code <> 'S' THEN
                         /* FND_MESSAGE.PARSE_ENCODED (encoded_message => X_Err_Stage,
                                                     APP_SHORT_NAME  => X_App_Short_Name,
                                                     MESSAGE_NAME    => X_Text );

                                                 X_Err_Stage := X_Text;
                          */
                                            RAISE FND_API.G_EXC_ERROR;
                    ELSE
        		RETCODE := X_Err_Code;
     		    END IF;


/* Delete AWARD_BUDGET_TYPE */
-- this procedure is not used in 11i as there is no award_budget_type -- Suresh
/*
          DELETE_AWARD_BUDGET_TYPE(to_char(X_Award_Id),
                                   X_Err_Code ,
                                   X_Err_Stage);

                  IF X_Err_Code <> 'S' THEN
                        X_App_Short_Name := 'GMS';
                        RAISE FND_API.G_EXC_ERROR;
                  ELSE
                        RETCODE := X_Err_Code;
                  END IF;
*/


                  G_Stage := '(620:CALLING GMS_MULTI_FUNDING.DELETE_AGREEMENT)';
                  /* Deleting Agreement associated with Award Project */
                  GMS_MULTI_FUNDING.DELETE_AGREEMENT
                                    (X_Agreement_Id,
                                     X_Err_Code,
                                     X_Err_Stage);

                  IF X_Err_Code <> 'S' THEN
                        X_App_Short_Name := 'GMS';
                        RAISE FND_API.G_EXC_ERROR;
                  ELSE
                        RETCODE := X_Err_Code;
                  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
       X_Msg_Count := p_msg_count;
       RETCODE := X_Err_Code;
       ERRBUF  := 'At stage='||g_stage||' '||X_Err_Stage;
  WHEN OTHERS THEN
       RETCODE                 := 'U';
       FND_MSG_PUB.add_exc_msg
	    (  p_pkg_name	=> 'GMS_MULTI_FUNDING'
	      ,p_procedure_name	=> 'DELETE_AWARD_PROJECT'
              ,p_error_text     =>  substrb(SQLERRM||' (stage='||g_stage||')',1,240)
            );
       FND_MSG_PUB.Count_And_Get
           ( p_count            => p_msg_count,
             p_data             => X_Err_Stage);
       ERRBUF  := 'At stage='||g_stage||' '||X_Err_Stage;
END DELETE_AWARD_PROJECT;

PROCEDURE CREATE_AWARD_PROJECT_BUDGET( X_Award_Project_Id IN NUMBER,
                                       X_Budget_Amount IN NUMBER,
                                       X_Start_Date IN DATE,
                                       X_End_Date IN DATE,
                                       X_App_Short_Name OUT NOCOPY VARCHAR2,
                                       RETCODE OUT NOCOPY VARCHAR2,
                                       ERRBUF  OUT NOCOPY VARCHAR2) IS
X_Err_Code  VARCHAR2(1) := NULL;
X_Err_Stage VARCHAR2(200) := NULL;

X_Award_Id NUMBER(15);
X_Budget_Version_Id   NUMBER(15);
X_Resource_Assignment_Id NUMBER(15);
X_Resource_List_Id NUMBER(15);
X_Resource_List_Member_Id NUMBER(15);

X_Msg_data VARCHAR2(2000);
X_Msg_Count NUMBER;
X_Text VARCHAR2(30);
X_Index NUMBER(15);

X_Budget_Lines_IN_REC     PA_BUDGET_PUB.BUDGET_LINE_IN_REC_TYPE;
X_Budget_Lines_IN_TBL     PA_BUDGET_PUB.BUDGET_LINE_IN_TBL_TYPE;
X_Budget_Lines_OUT_TBL    PA_BUDGET_PUB.BUDGET_LINE_OUT_TBL_TYPE;
X_Product_Code            VARCHAR2(30);

X_Workflow_Started VARCHAR2(1);

--Added these variables to track when an API fails
l_api_name  CONSTANT VARCHAR2(30) := 'CREATE_AWARD_PROJECT_BUDGET';

BEGIN
     G_Stage := '(650:SELECT FROM GMS_AWARDS)';
     --Get Award Id (PM_PROJECT_REFERENCE) of the Award Project //
     BEGIN
         SELECT Award_Id
         INTO   X_Award_Id
         FROM   gms_awards
         WHERE  award_project_id = X_Award_Project_Id;

         G_Stage := '(660:SELECT FROM RESOURCE_LIST)';
         --Get Resource List Id, Resource_List_Member_Id for Resource = 'Uncategorized' //
         SELECT A.RESOURCE_LIST_MEMBER_ID, B.RESOURCE_LIST_ID
         INTO   X_Resource_List_Member_Id, X_Resource_List_Id
         FROM   PA_RESOURCE_LIST_MEMBERS A,
                PA_RESOURCE_LISTS B,
                PA_IMPLEMENTATIONS PI	-- Bug 2108191
         WHERE  B.uncategorized_flag = 'Y'
         AND    B.resource_list_id = a.resource_list_id
         AND    B.business_group_id = PI.business_group_id
         AND    NVL(A.migration_code,'M') ='M'
         AND    NVL(B.migration_code,'M') ='M' ; -- Bug 2108191
         --     rownum = 1;

         X_Err_Code := 'S';
        EXCEPTION
             WHEN NO_DATA_FOUND THEN
                  X_Err_Code := 'E';
                  X_Err_Stage := 'Award, Resource_List_Member_Id or Resource_List_Id Not Found ';
                  FND_MESSAGE.SET_NAME('GMS','GMS_AWD_RESL_RESLM_NOT_FOUND');
                  FND_MSG_PUB.add;
                  FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
                                            p_data  => X_Err_Stage);
                  RAISE FND_API.G_EXC_ERROR;
     END;

  --dbms_output.put_line('After Resource List and List Member Select');
  --dbms_output.put_line('The Resource List ID is : '||to_char(X_Resource_List_Id));
  --dbms_output.put_line('The Resource List Member ID is : '||to_char(X_Resource_List_Member_Id));

     BEGIN
       G_Stage := '(670:CALLING DRAFT_BUDGET_EXISTS)';
       IF DRAFT_BUDGET_EXISTS(X_Award_Project_Id,
                              X_Err_Code,
                              X_Err_Stage) THEN

                      G_Stage := '(680:CALLING PA_BUDGET_PUB.DELETE_DRAFT_BUDGET)';
                      --dbms_output.put_line('Before Delete Draft Budget API');
                         PA_BUDGET_PUB.DELETE_DRAFT_BUDGET
                                       (p_api_version_number   => 1.0,
                                        p_init_msg_list        => 'T',
                                        p_pa_project_id        => X_Award_Project_Id,
                                        p_pm_project_reference => to_char(X_Award_Id),
                                        p_pm_product_code      => 'GMS',
                                        p_budget_type_code     => 'AR',
                                        p_msg_count            => p_msg_count,
                                        p_msg_data             => X_Err_Stage,
                                        p_return_status        => X_Err_Code);

                      G_Stage := '(690:AFTER PA_BUDGET_PUB.DELETE_DRAFT_BUDGET CALL)';
                      IF X_Err_Code <> 'S' THEN
                         /* FND_MESSAGE.PARSE_ENCODED (encoded_message => X_Err_Stage,
                                                       APP_SHORT_NAME  => X_App_Short_Name,
                                                       MESSAGE_NAME    => X_Text );
                               X_Err_Stage := X_Text;
                          */
                            RAISE FND_API.G_EXC_ERROR;
                      ELSE
                            RETCODE := X_Err_Code;
                      END IF;

              --dbms_output.put_line('Return Status After Delete is '||X_Err_Code);
       ELSE
            IF X_Err_Code <> 'S' THEN
             RAISE FND_API.G_EXC_ERROR;
            ELSE
                RETCODE := X_Err_Code;
            END IF;

       END IF;

----------------------------------------------------------------------------------------------
/* Call Budget API to create Draft Budget */
 X_Product_Code := 'GMS';
 X_Budget_Lines_IN_REC.resource_list_member_id := X_Resource_List_Member_Id;
 X_Budget_Lines_IN_REC.budget_start_date       := X_Start_Date;
 X_Budget_Lines_IN_REC.budget_end_date         := X_End_Date;
 X_Budget_Lines_IN_REC.revenue                 := X_Budget_Amount;
 X_Budget_Lines_IN_REC.quantity                := NULL;

 -- Bug 3174375 : Cannot create award ...
 X_Budget_Lines_IN_REC.pm_product_code         := 'GMS';

 X_Budget_Lines_IN_TBL(1) := X_Budget_Lines_IN_REC;
       --dbms_output.put_line('Before Create Budget API inside Create_Award_Project_Budget');
     --dbms_output.put_line('Awd Proj Id '||to_char(X_Award_Project_Id)||' Product Code '||X_Product_Code
                          --||'Award Id '||to_char(X_Award_Id)
                          --||'Revenue Bud Amount '||to_char(X_Budget_Lines_IN_REC.revenue)
                          --||'Start_Date'||to_char(X_Budget_Lines_IN_REC.budget_start_date)
			  --||'Resource List ID '||X_Resource_List_Id
                          --||'End_Date '||to_char(X_Budget_Lines_IN_REC.budget_end_date));

           G_Stage := '(700:CALLING PA_BUDGET_PUB.CREATE_DRAFT_BUDGET)';
         --dbms_output.put_line('Getting INTO THE PA API');
                           PA_BUDGET_PUB.CREATE_DRAFT_BUDGET
                                        (p_api_version_number        => 1.0,
                                         p_init_msg_list             => 'T',
                                         p_msg_count                 => p_msg_count,
                                         p_msg_data                  => X_Err_Stage,
                                         p_return_status             => X_Err_Code,
                                         p_pm_product_code           => X_Product_Code,
                                         p_pa_project_id             => X_Award_Project_Id,
                                         p_pm_project_reference      => to_char(X_Award_Id),
                                         p_budget_type_code          => 'AR',
                                         p_entry_method_code         => 'AWARD_PROJECT_REVENUE',
                                         p_resource_list_id          => X_Resource_List_Id,
                                     /*  p_change_reason_code        => 'Scope Change',       */
                                         p_budget_lines_in           => X_Budget_Lines_IN_TBL,
                                         p_budget_lines_out          => X_Budget_Lines_OUT_TBL
                                         );
                            IF X_Err_Code <> 'S' THEN
                                   /* FND_MESSAGE.PARSE_ENCODED (encoded_message => X_Err_Stage,
                                                                 APP_SHORT_NAME  => X_App_Short_Name,
                                                                 MESSAGE_NAME    => X_Text );

                                            X_Err_Stage := X_Text;
                                    */

                               RAISE FND_API.G_EXC_ERROR;
                            ELSE
                               RETCODE := X_Err_Code;
                            END IF;

                        --dbms_output.put_line('After BUDGET API : '||X_Msg_data);
                        --dbms_output.put_line('After BUDGET API : '||X_Err_Stage);

                          G_Stage := '(710:CALLING PA_BUDGET_PUB.BASELINE_BUDGET)';
                          /* Call API to Baseline Budget */
                          PA_BUDGET_PUB.BASELINE_BUDGET
                                    (p_api_version_number    => 1.0,
                                     p_init_msg_list         => 'T',
                                     p_msg_count             => p_msg_count,
                                     p_msg_data              => X_Err_Stage,
                                     p_return_status         => X_Err_Code,
                                     p_pm_product_code       => X_Product_Code,
                                     p_pa_project_id         => X_Award_Project_Id,
                                     p_pm_project_reference  => to_char(X_Award_Id),
                                     p_budget_type_code      => 'AR',
			             p_workflow_started      => X_Workflow_Started
                                     );

                        IF X_Err_Code <> 'S' THEN
                            /*  FND_MESSAGE.PARSE_ENCODED (encoded_message => X_Err_Stage,
                                                           APP_SHORT_NAME  => X_App_Short_Name,
                                                           MESSAGE_NAME    => X_Text );

                                  X_Err_Stage := X_Text;
 			      */
                            RAISE FND_API.G_EXC_ERROR;
                        ELSE
                            RETCODE := X_Err_Code;
                        END IF;

     --dbms_output.put_line('After Baseline');
  --dbms_output.put_line('After Baseline GET : '||X_Err_Stage);

--------------------------------------------------------------------------------------------------

--dbms_output.put_line('At the Very END of CREATE AWARD BUDGET');
     END;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      RETCODE := X_Err_Code;
      ERRBUF  := X_Err_Stage;

  -- Added when OTHERS exception for Bug:2662848
    WHEN OTHERS THEN
       RETCODE                 := 'U';
       FND_MSG_PUB.add_exc_msg
	    ( p_pkg_name        => G_PKG_NAME
	     ,p_procedure_name  => l_api_name
             ,p_error_text      => substrb(SQLERRM||' at stage='||g_stage||' ',1,240)
           );
       FND_MSG_PUB.Count_And_Get
           ( p_count  => p_msg_count,
             p_data   => X_Err_Stage);
       ERRBUF  := SQLERRM||' at stage='||g_stage||' '||X_Err_Stage;
       RAISE;  --not required but keeping for now
END CREATE_AWARD_PROJECT_BUDGET;

PROCEDURE CREATE_AWARD_FUNDING( X_Installment_Id IN NUMBER,
                                X_Allocated_Amount IN NUMBER,
                                X_Date_Allocated IN DATE,
                                X_GMS_Project_Funding_Id IN NUMBER,
                                X_Project_Funding_Id  OUT NOCOPY NUMBER,
                                X_App_Short_Name OUT NOCOPY VARCHAR2,
				X_Msg_Count OUT NOCOPY NUMBER,
                                RETCODE OUT NOCOPY VARCHAR2,
                                ERRBUF OUT NOCOPY VARCHAR2) IS
X_Err_Code VARCHAR2(1);
X_Err_Stage VARCHAR2(200);
X_Text VARCHAR2(200);

St_Project_Funding_Id  NUMBER(15);

X_Award_Id    NUMBER(15);
X_Award_Project_Id  NUMBER(15);
X_Agreement_Id      NUMBER(15);
X_Project_Start_Date DATE;
X_Project_End_Date DATE;
X_Total_Unbaselined_Amount NUMBER(22,5) := 0;
X_Total_Baselined_Amount NUMBER(22,5) := 0;
X_Total_Funding_Budget NUMBER(22,5) := 0;

--Added these variables to track when an API fails
l_api_name  CONSTANT VARCHAR2(30) := 'CREATE_AWARD_FUNDING';

BEGIN
   G_Stage := '(1000:CALLING FND_MSG_PUB.INITIALIZE)';
   FND_MSG_PUB.Initialize;
   --Get next sequence for PA_PROJECT_FUNDING//
     BEGIN
       Select
       PA_PROJECT_FUNDINGS_S.NEXTVAL
       INTO
       St_Project_Funding_Id
       FROM
       DUAL;
     END ;

     BEGIN
     --Get Award Project Id for the Award of which this Agreement is part of
  --dbms_output.put_line('Before Get Project Start END Date');

     G_Stage := '(1010:CALLING GET_PROJ_START_AND_END_DATE)';
     GET_PROJ_START_AND_END_DATE(X_Installment_Id,
                                 X_Award_Id,
                                 X_Award_Project_Id,
                                 X_Project_Start_Date,
                                 X_Project_End_Date,
                                 X_Agreement_Id,
                                 X_Err_Code,
                                 X_Err_Stage);

                    IF X_Err_Code <> 'S' THEN
                             RAISE FND_API.G_EXC_ERROR;
                    ELSE
                       RETCODE := X_Err_Code ;
                    END IF;
      END;

      BEGIN
/* UPDATE Award Project's Agreement with the new Amount */
       --dbms_output.put_line('Amount before UPDATE agreement '||X_Allocated_Amount);

         G_Stage := '(1020:CALLING GMS_MULTI_FUNDING.UPDATE_AGREEMENT)';
         GMS_MULTI_FUNDING.UPDATE_AGREEMENT(X_Agreement_Id   => X_Agreement_Id,
                                            X_Agreement_Num  => NULL,
                                            X_Agreement_Type => NULL,
					    X_Revenue_Limit_Flag => NULL,
					    X_Invoice_Limit_Flag => NULL, /*Bug 6642901*/
                                            X_Customer_Id    => NULL,
                                            X_Owned_By_Person_Id => NULL,
                                            X_Term_Id => NULL,
                                            X_Amount => X_Allocated_Amount,
                                            X_Close_Date => NULL,
                                            RETCODE => X_Err_Code,
                                            ERRBUF  => X_Err_Stage);

                    IF X_Err_Code <> 'S' THEN
                             RAISE FND_API.G_EXC_ERROR;
                    ELSE
                             RETCODE := X_Err_Code ;
                    END IF;
      END;

      G_Stage := '(1030:CALLING INSERT_DETAIL_PROJECT_FUNDING)';
--Insert row INTO PA_PROJECT_FUNDING for Award Project //
--dbms_output.put_line('Before Insert INTO PA Project Fundings');
      BEGIN
            INSERT_DETAIL_PROJECT_FUNDING(St_Project_Funding_Id,
                                          X_Agreement_Id,
             		                  X_Award_Project_Id,
             		                  X_Allocated_Amount,
             		                  X_Date_Allocated,
             		                  X_Err_Code,
               				  X_Err_Stage);

                    IF X_Err_Code <> 'S' THEN
                             RAISE FND_API.G_EXC_ERROR;
                    ELSE
                             RETCODE := X_Err_Code ;
                    END IF;
      END;

--dbms_output.put_line('Before UPDATE GMS PROJECT FUNDINGS');
      BEGIN
        --UPDATE GMS_PROJECT_FUNDING with X_Project_Funding_Id and PASS IT OUT NOCOPY
            	BEGIN
                 UPDATE GMS_PROJECT_FUNDINGS
                 SET    PROJECT_FUNDING_ID = St_Project_Funding_Id
                 WHERE  GMS_PROJECT_FUNDING_ID = X_GMS_Project_Funding_Id;
            	END;
         X_Project_Funding_Id := St_Project_Funding_Id;

--dbms_output.put_line('Before Row Exists');
      END;

      G_Stage := '(1040:CALLING ROW_EXISTS_IN_PA_SUMM_FUNDING)';
  BEGIN
           IF ROW_EXISTS_IN_PA_SUMM_FUNDING
                               (X_Agreement_Id,
                                X_Award_Project_Id,
                                X_Err_Code,
                                X_Err_Stage)  THEN
              BEGIN
                --dbms_output.put_line('Before Get Total Funding Amt');
                G_Stage := '(1040:CALLING GET_TOTAL_FUNDING_AMOUNT)';
                GET_TOTAL_FUNDING_AMOUNT
                               (X_Agreement_Id,
                                X_Award_Project_Id,
                                X_Total_Unbaselined_Amount,
                                X_Total_Baselined_Amount,
                                X_Err_Code,
                                X_Err_Stage) ;
                  IF X_Err_Code <> 'S' THEN
                     RAISE FND_API.G_EXC_ERROR;
                  ELSE
                     RETCODE := X_Err_Code ;
                  END IF;
                  X_Total_Unbaselined_Amount := X_Total_Unbaselined_Amount + X_Allocated_Amount;


                  G_Stage := '(1050:CALLING UPDATE_PA_SUMM_PROJECT_FUNDING)';
                  --dbms_output.put_line('The Total Summary Funding Amount is : '||to_char(X_Total_Unbaselined_Amount));
                  --dbms_output.put_line('Before UPDATE Summary Funding');
                  UPDATE_PA_SUMM_PROJECT_FUNDING
                               (X_Agreement_Id,
                                X_Award_Project_Id,
                                X_Total_Unbaselined_Amount,
                                X_Err_Code,
                                X_Err_Stage);
                             IF X_Err_Code <> 'S' THEN
                                RAISE FND_API.G_EXC_ERROR;
                             ELSE
                       	        RETCODE := X_Err_Code ;
                             END IF;
              END;
           ELSE

            G_Stage := '(1060:CALLING INSERT_SUMMARY_PROJECT_FUNDING)';
            IF X_Err_Code = 'S' THEN

               X_Total_Unbaselined_Amount := X_Allocated_Amount;
              --dbms_output.put_line('The Total Summary Funding Amount is : '||to_char(X_Total_Unbaselined_Amount));
              --dbms_output.put_line('Before Insert Summary Funding');
              INSERT_SUMMARY_PROJECT_FUNDING
                              (X_Agreement_Id,
                               X_Award_Project_Id,
                               X_Total_Unbaselined_Amount,
                               X_Err_Code,
                               X_Err_Stage);

                            IF X_Err_Code <> 'S' THEN
                               RAISE FND_API.G_EXC_ERROR;
                            ELSE
                       	       RETCODE := X_Err_Code ;
                            END IF;
            ELSE
              RAISE FND_API.G_EXC_ERROR;
            END IF;

          END IF;
 END;
 G_Stage := '(1070:CALLING GET_TOTAL_FUNDING_BUDGET)';
 BEGIN
       /* Getting the total summary funding for the Award Project (Baselined+Unbaselined) */
        GET_TOTAL_FUNDING_BUDGET(X_Award_Project_Id,
                                X_Total_Funding_Budget,
                                X_Err_Code,
                                X_Err_Stage);
                    IF X_Err_Code <> 'S' THEN
                             RAISE FND_API.G_EXC_ERROR;
                    ELSE
                       RETCODE := X_Err_Code ;
                    END IF;

         /* Deletes any existing Draft Revenue Budget and Creates a new Draft Revenue Budget */

      G_Stage := '(1080:CALLING CREATE_AWARD_PROJECT_BUDGET)';
      --dbms_output.put_line('The Total Revenue Budget Amount is : '||to_char(X_Total_Funding_Budget));
      --dbms_output.put_line('Before Creation of  Award Project Budget ');
      CREATE_AWARD_PROJECT_BUDGET(X_Award_Project_Id,
                                  X_Total_Funding_Budget,
                                  X_Project_Start_Date,
                                  X_Project_End_Date,
                                  X_App_Short_Name,
                                  X_Err_Code,
                                  X_Err_Stage);

 		    IF X_Err_Code <> 'S' THEN
                             RAISE FND_API.G_EXC_ERROR;
                    ELSE
                       RETCODE := X_Err_Code ;
                    END IF;


 END;

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
      X_Msg_Count := p_msg_count;
      RETCODE := X_Err_Code;
      ERRBUF  := X_Err_Stage;
     WHEN OTHERS THEN
          RETCODE                 := 'U';
          FND_MSG_PUB.add_exc_msg
	    ( p_pkg_name        => G_PKG_NAME
	     ,p_procedure_name  => l_api_name
             ,p_error_text      => substrb(SQLERRM||' at stage='||g_stage||' ',1,240)
           );
          FND_MSG_PUB.Count_And_Get
           ( p_count  => p_msg_count,
             p_data   => X_Err_Stage);
          ERRBUF  := SQLERRM||' at stage='||g_stage||' '||X_Err_Stage;

END CREATE_AWARD_FUNDING;

PROCEDURE UPDATE_AWARD_FUNDING(X_Project_Funding_Id IN NUMBER,
                               X_Installment_Id IN NUMBER,
                               X_Old_Allocated_Amount IN NUMBER,
                               X_New_Allocated_Amount IN NUMBER,
                               X_Old_Date_Allocated IN DATE,
                               X_New_Date_Allocated IN DATE,
                               X_App_Short_Name OUT NOCOPY VARCHAR2,
			       X_Msg_Count OUT NOCOPY NUMBER,
                               RETCODE OUT NOCOPY VARCHAR2,
                               ERRBUF OUT NOCOPY VARCHAR2) IS
X_Err_Code  VARCHAR2(1);
X_Err_Stage VARCHAR2(300);
X_Text      VARCHAR2(30);


X_Award_Id  NUMBER(15);
X_Award_Project_Id  NUMBER(15);
X_Agreement_Id NUMBER(15);
X_Project_Start_Date DATE;
X_Project_End_Date DATE;
X_Total_Unbaselined_Amount NUMBER(22,5) := 0;
X_Total_Baselined_Amount NUMBER(22,5) := 0;
X_Total_Funding_Budget NUMBER(22,5) := 0;
X_Agreement_Amt NUMBER(22,5) := 0;

--Added these variables to track when an API fails
l_api_name  CONSTANT VARCHAR2(30) := 'UPDATE_AWARD_FUNDING';

BEGIN
     G_Stage := '(1100:CALLING GET_PROJ_START_AND_END_DATE)';
     BEGIN
--Get Award Project Id and Award Start Date for the Award of which this Agreement is part of .//
--The Award Project Id is used to UPDATE the correct row in PA_SUMMARY_FUNDINGS table //
 GET_PROJ_START_AND_END_DATE(X_Installment_Id,
                             X_Award_Id,
                             X_Award_Project_Id,
                             X_Project_Start_Date,
                             X_Project_End_Date,
                             X_Agreement_Id,
                             X_Err_Code,
                             X_Err_Stage);
                            IF X_Err_Code <> 'S' THEN
                                RAISE FND_API.G_EXC_ERROR;
                            END IF;
      END;

      G_Stage := '(1110:CALLING GMS_MULTI_FUNDING.UPDATE_AGREEMENT)';
      BEGIN
/* UPDATE Award Project's Agreement with the new Amount */
       X_Agreement_Amt := (X_New_Allocated_Amount - X_Old_Allocated_Amount);
         GMS_MULTI_FUNDING.UPDATE_AGREEMENT(X_Agreement_Id => X_Agreement_Id,
                                            X_Agreement_Num => NULL,
                                            X_Agreement_Type => NULL,
					    X_Revenue_Limit_Flag => NULL,
					                         X_Invoice_Limit_Flag => NULL, /*Bug 6642901*/
                                            X_Customer_Id => NULL,
                                            X_Owned_By_Person_Id => NULL,
                                            X_Term_Id => NULL,
                                            X_Amount => X_Agreement_Amt,
                                            X_Close_Date => NULL,
                                            RETCODE => X_Err_Code,
                                            ERRBUF => X_Err_Stage);

                    IF X_Err_Code <> 'S' THEN
                             RAISE FND_API.G_EXC_ERROR;
                    END IF;
      END;

      G_Stage := '(1120:CALLING UPDATE_DETAIL_PROJECT_FUNDING)';
      BEGIN

--UPDATEs row INTO PA_PROJECT_FUNDING with the new Allocated Amount if the status is still DRAFT //
          UPDATE_DETAIL_PROJECT_FUNDING(X_Project_Funding_Id,
                                        X_Old_Allocated_Amount,
             		                X_New_Allocated_Amount,
                                        X_Old_Date_Allocated,
                                        X_New_Date_Allocated,
		                        X_Err_Code,
               				X_Err_Stage);
 			 IF X_Err_Code <> 'S' THEN
                             RAISE FND_API.G_EXC_ERROR;
                         END IF;

                 G_Stage := '(1130:CALLING GET_TOTAL_FUNDING_AMOUNT)';
                 GET_TOTAL_FUNDING_AMOUNT(X_Agreement_Id,
                                          X_Award_Project_Id,
                                          X_Total_Unbaselined_Amount,
                                          X_Total_Baselined_Amount,
                                          X_Err_Code,
                                          X_Err_Stage) ;
                         IF X_Err_Code <> 'S' THEN
                             RAISE FND_API.G_EXC_ERROR;
                         END IF;

        X_Total_Unbaselined_Amount := X_Total_Unbaselined_Amount + (X_New_Allocated_Amount -
                                                                    X_Old_Allocated_Amount);

                 G_Stage := '(1140:CALLING UPDATE_PA_SUMM_PROJECT_FUNDING)';
    --dbms_output.put_line('TOtal UNbaselined Amt Before UPDATE_PA_SUMM_FUNDING '||X_Total_Unbaselined_Amount);
                 UPDATE_PA_SUMM_PROJECT_FUNDING(X_Agreement_Id,
                                                X_Award_Project_Id,
                                                X_Total_Unbaselined_Amount,
                                                X_Err_Code,
                                                X_Err_Stage);
                         IF X_Err_Code <> 'S' THEN
                             RAISE FND_API.G_EXC_ERROR;
                         END IF;

                  G_Stage := '(1150:CALLING GET_TOTAL_FUNDING_BUDGET)';
                  /* Getting the total Funding(Baselined + Unbaselined) for the Project */
                  GET_TOTAL_FUNDING_BUDGET(X_Award_Project_Id,
                                           X_Total_Funding_Budget,
                                           X_Err_Code,
                                           X_Err_Stage);
                         IF X_Err_Code <> 'S' THEN
                             RAISE FND_API.G_EXC_ERROR;
                         END IF;
      --dbms_output.put_line('Total FUNDING BUDGET BEFORE CREATE_AWARD_PROJECT_BUDGET '||X_Total_Funding_Budget);


                 G_Stage := '(1160:CALLING CREATE_AWARD_PROJECT_BUDGET)';
	 -- Deletes any existing draft revenue budget and creates new draft Revenue Budget
                 CREATE_AWARD_PROJECT_BUDGET( X_Award_Project_Id,
                                              X_Total_Funding_Budget,
                                              X_Project_Start_Date,
                                              X_Project_End_Date,
                                              X_App_Short_Name,
                                              X_Err_Code,
                                              X_Err_Stage);

                   --dbms_output.put_line('Got OUT NOCOPY of the CREATE_AWARD_PROJECT_BUDGET');

 			IF X_Err_Code <> 'S' THEN
                             RAISE FND_API.G_EXC_ERROR;
                        END IF;

  END;
    EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
            X_Msg_Count := p_msg_count;
            ERRBUF := X_Err_Stage;
            RETCODE := X_Err_Code;

-- Added when others exception for Bug:2662848
       WHEN OTHERS THEN
          RETCODE                 := 'U';
          FND_MSG_PUB.add_exc_msg
	    ( p_pkg_name        => G_PKG_NAME
	     ,p_procedure_name  => l_api_name
             ,p_error_text      => substrb(SQLERRM||' at stage='||g_stage||' ',1,240)
           );
          FND_MSG_PUB.Count_And_Get
           ( p_count  => p_msg_count,
             p_data   => X_Err_Stage);
          ERRBUF  := SQLERRM||' at stage='||g_stage||' '||X_Err_Stage;
END UPDATE_AWARD_FUNDING;

PROCEDURE DELETE_AWARD_FUNDING(X_Project_Funding_Id IN NUMBER,
                               X_Installment_Id IN NUMBER,
                               X_Allocated_Amount IN NUMBER,
                               X_App_Short_Name OUT NOCOPY VARCHAR2,
                               X_Msg_Count OUT NOCOPY NUMBER,
                               RETCODE OUT NOCOPY  VARCHAR2,
                               ERRBUF OUT NOCOPY VARCHAR2)IS
X_Err_Code VARCHAR2(1);
X_Err_Stage VARCHAR2(200);
X_Text VARCHAR2(200);
--X_Msg_Count NUMBER;

X_Award_Id NUMBER(15);
X_Award_Project_Id  NUMBER(15);
X_Project_Start_Date DATE;
X_Project_End_Date DATE;
X_Agreement_Id NUMBER(15);
X_Total_Unbaselined_Amount NUMBER(22,5) := 0;
X_Total_Baselined_Amount NUMBER(22,5) := 0;
X_Total_Funding_Budget NUMBER(22,5) := 0;

-- Bug 2270436 : Added function pa_funding_exists
-- This function checks for existence of any record in pa_project_fundings before
-- deleting records FROM pa_summary_project_fundings

FUNCTION pa_funding_exists (p_agreement_id NUMBER, p_award_project_id NUMBER)
   RETURN BOOLEAN
IS
   CURSOR c_funding_exists
   IS
      SELECT 1
      FROM DUAL
      WHERE EXISTS (SELECT 1
                    FROM pa_project_fundings
                    WHERE agreement_id = p_agreement_id
                    AND project_id = p_award_project_id);

   x_dummy                       NUMBER := 0;
BEGIN
   OPEN c_funding_exists;
   FETCH c_funding_exists INTO x_dummy;
   CLOSE c_funding_exists;

   IF x_dummy <> 0
   THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;
END;



BEGIN
      G_Stage := '(800:CALLING GET_PROJ_START_AND_END_DATE)';
      BEGIN
--Get Award Project Id for the Award of which this Agreement is part of // -
        GET_PROJ_START_AND_END_DATE(X_Installment_Id,
                                    X_Award_Id,
                                    X_Award_Project_Id,
                                    X_Project_Start_Date,
                                    X_Project_End_Date,
                                    X_Agreement_Id,
                                    X_Err_Code,
                                    X_Err_Stage);
                               IF X_Err_Code <> 'S' THEN
                                    RAISE FND_API.G_EXC_ERROR;
                               END IF;
      END;

      G_Stage := '(810:CALLING GMS_MULTI_FUNDING.UPDATE_AGREEMENT)';
      BEGIN
/* UPDATE Award Project's Agreement with the new Amount */

         GMS_MULTI_FUNDING.UPDATE_AGREEMENT(X_Agreement_Id => X_Agreement_Id,
                                            X_Agreement_Num => NULL,
                                            X_Agreement_Type => NULL,
					    X_Revenue_Limit_Flag => NULL,
					    X_Invoice_Limit_Flag => NULL, /*Bug 6642901*/
                                            X_Customer_Id => NULL,
                                            X_Owned_By_Person_Id => NULL,
                                            X_Term_Id => NULL,
                                            X_Amount => (-1*X_Allocated_Amount),
                                            X_Close_Date => NULL,
                                            RETCODE => X_Err_Code,
                                            ERRBUF => X_Err_Stage);

                    IF X_Err_Code <> 'S' THEN
                             RAISE FND_API.G_EXC_ERROR;
                    END IF;
     END;
     G_Stage := '(820:CALLING DELETE_DETAIL_PROJECT_FUNDING)';
     BEGIN
            --Delete row FROM PA_PROJECT_FUNDING for Award Project //
            DELETE_DETAIL_PROJECT_FUNDING(X_Project_Funding_Id,
                                          X_Err_Code,
               				  X_Err_Stage);
 			 IF X_Err_Code <> 'S' THEN
                      RAISE FND_API.G_EXC_ERROR;
                   END IF;

                   G_Stage := '(830:CALLING GET_TOTAL_FUNDING_AMOUNT)';
                   GET_TOTAL_FUNDING_AMOUNT(X_Agreement_Id,
                                            X_Award_Project_Id,
                                            X_Total_Unbaselined_Amount,
                                            X_Total_Baselined_Amount,
                                            X_Err_Code,
                                            X_Err_Stage) ;
                        IF X_Err_Code <> 'S' THEN
                           RAISE FND_API.G_EXC_ERROR;
                        END IF;

           X_Total_Unbaselined_Amount := X_Total_Unbaselined_Amount - X_Allocated_Amount;

           G_Stage := '(840:CALLING DELETE_SUMMARY_PROJECT_FUNDING)';
           IF ((X_Total_Baselined_Amount + X_Total_Unbaselined_Amount = 0)
              and not pa_funding_exists(X_Agreement_Id,X_Award_Project_Id)	-- Bug 2270436
              )
           THEN
                   G_Stage := '(850:CALLING DELETE_SUMMARY_PROJECT_FUNDING)';
                   DELETE_SUMMARY_PROJECT_FUNDING(X_Agreement_Id,
                                                  X_Award_Project_Id,
                                                  X_Err_Code,
                                                  X_Err_Stage);
                             IF X_Err_Code <> 'S' THEN
                                 RAISE FND_API.G_EXC_ERROR;
                             END IF;

                   G_Stage := '(860:CALLING GET_TOTAL_FUNDING_BUDGET)';
                   /* Getting the total Funding(Baselined + Unbaselined) for the Project */
                   GET_TOTAL_FUNDING_BUDGET(X_Award_Project_Id,
                                            X_Total_Funding_Budget,
                                            X_Err_Code,
                                            X_Err_Stage);
                              IF X_Err_Code <> 'S' THEN
                                 RAISE FND_API.G_EXC_ERROR;
                              END IF;

                        G_Stage := '(870:CALLING DRAFT_BUDGET_EXISTS)';
                        IF X_Total_Funding_Budget = 0 THEN

                                  IF DRAFT_BUDGET_EXISTS(X_Award_Project_Id,
                                                         X_Err_Code,
                                                         X_Err_Stage) THEN

                                       G_Stage := '(880:CALLING PA_BUDGET_PUB.DELETE_DRAFT_BUDGET)';
                                       PA_BUDGET_PUB.DELETE_DRAFT_BUDGET
                                                       (p_api_version_number   => 1.0,
                                                        p_pa_project_id        => X_Award_Project_Id,
                                                        p_pm_project_reference => to_char(X_Award_Id),
                                                        p_pm_product_code      => 'GMS',
                                                        p_budget_type_code     => 'AR',
                                                        p_msg_count            => X_Msg_Count,
                                                        p_msg_data             => X_Err_Stage,
                                                        p_return_status        => X_Err_Code);
                                              IF X_Err_Code <> 'S' THEN
                                           /*  FND_MESSAGE.PARSE_ENCODED (encoded_message => X_Err_Stage,
                                                                APP_SHORT_NAME  => X_App_Short_Name,
                                                                MESSAGE_NAME    => X_Text );
                                                          X_Err_Stage := X_Text;
                                           */
                                                     RAISE FND_API.G_EXC_ERROR;
                                              END IF;
                                  END IF;

                             G_Stage := '(890:CALLING DELETE_BASELINED_VERSIONS)';
                          /* Delete all the Existing Baselined Budgets also */
                             DELETE_BASELINED_VERSIONS
                                                  (X_Award_Project_Id,
                                                   X_Err_Code,
                                                   X_Err_Stage);
                                          IF X_Err_Code <> 'S' THEN
                                               RAISE FND_API.G_EXC_ERROR;
                                          END IF;

                        END IF;

          ELSE
             G_Stage := '(900:CALLING UPDATE_PA_SUMM_PROJECT_FUNDING)';
             UPDATE_PA_SUMM_PROJECT_FUNDING(X_Agreement_Id,
                                            X_Award_Project_Id,
                                            X_Total_Unbaselined_Amount,
                                            X_Err_Code,
                                            X_Err_Stage);
                                IF X_Err_Code <> 'S' THEN
                                   RAISE FND_API.G_EXC_ERROR;
                                END IF;
              G_Stage := '(910:CALLING UPDATE_PA_SUMM_PROJECT_FUNDING)';
              GET_TOTAL_FUNDING_BUDGET(X_Award_Project_Id,
                                       X_Total_Funding_Budget,
                                       X_Err_Code,
                                       X_Err_Stage);
                                IF X_Err_Code <> 'S' THEN
                                   RAISE FND_API.G_EXC_ERROR;
                                END IF;
              G_Stage := '(920:CALLING CREATE_AWARD_PROJECT_BUDGET)';
              CREATE_AWARD_PROJECT_BUDGET(X_Award_Project_Id,
                                          X_Total_Funding_Budget,
                                          X_Project_Start_Date,
                                          X_Project_End_Date,
                                          X_App_Short_Name,
                                          X_Err_Code,
                                          X_Err_Stage);
 		                  IF X_Err_Code <> 'S' THEN
                                    RAISE FND_API.G_EXC_ERROR;
                                  END IF;
          END IF;
   END;
 EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
	  X_Msg_Count := p_msg_count;
          ERRBUF  := 'At stage='||g_stage||' '||X_Err_Stage;
          RETCODE := X_Err_Code;
-- Added when OTHERS exception for Bug:2662848
     WHEN OTHERS THEN
           RETCODE                 := 'U';
           FND_MSG_PUB.add_exc_msg
		(  p_pkg_name		=> 'GMS_MULTI_FUNDING'
		,  p_procedure_name	=> 'DELETE_AWARD_FUNDING');
           FND_MSG_PUB.Count_And_Get
                (  p_count              => p_msg_count,
                   p_data               => X_Err_Stage);
           ERRBUF  := 'At stage='||g_stage||' '||X_Err_Stage;

 	   RAISE; --This raise is not required but keeing as is for now.

END DELETE_AWARD_FUNDING;

END GMS_MULTI_FUNDING;

/
