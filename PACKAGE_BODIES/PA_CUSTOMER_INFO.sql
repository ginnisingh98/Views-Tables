--------------------------------------------------------
--  DDL for Package Body PA_CUSTOMER_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CUSTOMER_INFO" as
-- $Header: PAXCSINB.pls 120.11.12010000.2 2009/02/23 06:53:49 svivaram ship $


--
--  PROCEDURE
--              Get_Customer_Info
--
--
Procedure Get_Customer_Info
           ( X_project_ID          In  Number :=NULL,
             X_Customer_Id         In  Number,
         X_Bill_To_Customer_Id In Out NOCOPY Number   ,       /* For Bug 2731449 */ --File.Sql.39 bug 4440895
         X_Ship_To_Customer_Id In Out NOCOPY Number   ,       /* For Bug 2731449 */ --File.Sql.39 bug 4440895
         X_Bill_To_Address_Id  In Out NOCOPY Number , -- Changed from 'Out' to 'In Out' parameter for Bug 3911782 --File.Sql.39 bug 4440895
             X_Ship_To_Address_Id  In Out NOCOPY Number , -- Changed from 'Out' to 'In Out' parameter for Bug 3911782 --File.Sql.39 bug 4440895
             X_Bill_To_Contact_Id  In Out NOCOPY Number, --File.Sql.39 bug 4440895   -- Changed from 'Out' to 'In Out' parameter aditi for tracking bug
             X_Ship_To_Contact_Id  In Out NOCOPY Number, --File.Sql.39 bug 4440895   -- Changed from 'Out' to 'In Out' parameter aditi for tracking bug
             X_Err_Code            In Out NOCOPY Number, --File.Sql.39 bug 4440895
             X_Err_Stage           In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
             X_Err_Stack           In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
             p_quick_entry_flag    In Varchar2, -- If customer id is not passed thru QE then this flag is set to N else Y.
             p_calling_module      IN varchar2 := NULL -- Added for Bug#4770535 for contacts validation
             ) is

    Pl_Bill_To_Address_Id     Number :=  X_Bill_To_Address_Id; --Bug 3911782 changed from null to value being passed from pa_project_pub.update_project
    Pl_Ship_To_Address_Id     Number := X_Ship_To_Address_Id; --Bug 3911782 changed from null to value being passed from pa_project_pub.update_project
    Pl_Bill_To_Contact_Id     Number := X_Bill_To_Contact_Id; --for tracking bug by aditi changed from null to value being passed from pa_project_pub.update_project
    Pl_Ship_To_Contact_Id     Number := X_Ship_To_Contact_Id; --for tracking bug by aditi changed from null to value being passed from pa_project_pub.update_project

    -- 4363092 TCA changes, replaced RA views with HZ tables
    --Pl_Status                 Ra_customers.Status%type;
    Pl_Status                 hz_cust_accounts.Status%type;
    -- 4363092 end

    l_address_id              Number;
    l_contact_id              Number;
    l_count                   Number := 0;
    l_site_use_code           VARCHAR2(30);

/* Start For Bug 2731449 */
    l_cust_acc_rel_code       VARCHAR2(1);
    l_valid_bill_id           Number;
    l_valid_ship_id           Number;
    l_bill_to_customer_id     Number;
    l_ship_to_customer_id     Number;
/* End For Bug 2731449 */

   l_return_status                 VARCHAR2(1);
   l_error_msg_code                VARCHAR2(500);
   l_customer_id                Number;
   l_ic_billing                    Varchar2(1);
   l_ov                            Number;
   l_ov1                           Number;
   l_return_value                  VARCHAR2(1); -- Added for Bug 3911782


    -- 4363092 TCA changes, replaced RA views with HZ tables
    /*
    CURSOR C1 IS
    SELECT a.Address_id, su.Contact_id, su.site_use_code
    FROM   Ra_Addresses a,
           Ra_Site_Uses su
    WHERE  a.Address_Id        = su.Address_Id
      AND  Nvl(a.Status,'A')   = 'A'
      AND  a.Customer_id       = X_Customer_Id
      AND  Nvl(su.Status, 'A') = 'A'
      AND  su.primary_flag     = 'Y' ;
    */

    CURSOR C1 IS
    SELECT acct_site.cust_acct_site_id, su.Contact_id, su.site_use_code
    FROM   hz_cust_acct_sites_all acct_site,
           hz_cust_site_uses su
    WHERE
      acct_site.cust_acct_site_id  = su.cust_acct_site_id
      AND  Nvl(acct_site.Status,'A')   = 'A'
      AND  acct_site.cust_account_id  = X_Customer_Id
      AND  Nvl(su.Status, 'A') = 'A'
      AND  su.primary_flag     = 'Y' ;

    -- 4363092 end

 /* Start For Bug 2731449 */
 -- Cursors added to get the valid contact ids for bill to and ship to customers
   -- 4363092 TCA changes, replaced RA views with HZ tables
   /*
   CURSOR C2 IS
    SELECT a.Address_id, su.Contact_id, su.site_use_code
    FROM   Ra_Addresses a,
           Ra_Site_Uses su
    WHERE  a.Address_Id        = su.Address_Id
      AND  Nvl(a.Status,'A')   = 'A'
      AND  a.Customer_id       = X_Bill_To_Customer_Id
      AND  Nvl(su.Status, 'A') = 'A'
      AND  su.primary_flag     = 'Y'
      AND su.site_use_code     = 'BILL_TO';
   */

   CURSOR C2 IS
    SELECT acct_site.cust_acct_site_id, su.Contact_id, su.site_use_code
    FROM
           hz_cust_acct_sites_all acct_site,
           hz_cust_site_uses su
    WHERE
      acct_site.cust_acct_site_id  = su.cust_acct_site_id
      AND  Nvl(acct_site.Status,'A')   = 'A'
      AND  acct_site.cust_account_id = X_Bill_To_Customer_Id
      AND  Nvl(su.Status, 'A') = 'A'
      AND  su.primary_flag     = 'Y'
      AND su.site_use_code     = 'BILL_TO';

   -- 4363092 end

   -- 4363092 TCA changes, replaced RA views with HZ tables
   /*

   CURSOR C3 IS
    SELECT a.Address_id, su.Contact_id, su.site_use_code
    FROM   Ra_Addresses a,
           Ra_Site_Uses su
    WHERE  a.Address_Id        = su.Address_Id
      AND  Nvl(a.Status,'A')   = 'A'
      AND  a.Customer_id       = X_Ship_To_Customer_Id
      AND  Nvl(su.Status, 'A') = 'A'
      AND  su.primary_flag     = 'Y'
      AND su.site_use_code     = 'SHIP_TO';
   */

   CURSOR C3 IS
    SELECT acct_site.cust_acct_site_id, su.Contact_id, su.site_use_code
    FROM
           hz_cust_acct_sites_all acct_site,
           hz_cust_site_uses su
    WHERE
      acct_site.cust_acct_site_id  = su.cust_acct_site_id
      AND  Nvl(acct_site.Status,'A')   = 'A'
      AND  acct_site.cust_account_id       = X_Ship_To_Customer_Id
      AND  Nvl(su.Status, 'A') = 'A'
      AND  su.primary_flag     = 'Y'
      AND su.site_use_code     = 'SHIP_TO';

   -- 4363092 end

   CURSOR C4 IS
   Select cust_acc_rel_code
   From pa_implementations;

 --Commented the cursors C5 and C6 for bug#5478047

   /* CURSOR C5 IS
   SELECT related_cust_account_id
    FROM hz_cust_acct_relate
    WHERE cust_account_id = X_Customer_Id
    AND bill_to_flag = 'Y'
    AND status = 'A'
    AND related_cust_account_id = X_Bill_To_Customer_Id;

   CURSOR C6 IS
   SELECT related_cust_account_id
    FROM hz_cust_acct_relate
    WHERE cust_account_id = X_Customer_Id
    AND ship_to_flag = 'Y'
    AND status = 'A'
    AND related_cust_account_id = X_Ship_To_Customer_Id; */

  --Added the new cursors C5 and C6 for bug#5478047

    CURSOR C5 IS
    SELECT cust_account_id
    FROM hz_cust_acct_relate
    WHERE related_cust_account_id = X_Customer_Id
    AND bill_to_flag = 'Y'
    AND status = 'A'
    AND cust_account_id = X_Bill_To_Customer_Id;	--Bug#5872732

    CURSOR C6 IS
    SELECT cust_account_id
    FROM hz_cust_acct_relate
    WHERE related_cust_account_id = X_Customer_Id
    AND ship_to_flag = 'Y'
    AND status = 'A'
    AND cust_account_id = X_Ship_To_Customer_Id;	--Bug#5872732

   Cursor Ic_billing IS
   Select pt.CC_PRVDR_FLAG
   From pa_project_types pt, pa_projects pa
   where pa.project_type=pt.project_type
   and pa.project_id=x_project_id;

/* End  For Bug 2731449 */

Begin
--dbms_output.put_line('Value of X_Customer_id'||X_Customer_id);
    X_Err_Code  := 0;
    OPEN  Ic_billing;
    Fetch Ic_billing into l_ic_billing;
    If l_ic_billing='Y' Then
       X_Bill_To_Customer_id := X_Customer_id;
       X_Ship_To_Customer_id := X_Customer_id;
/*Changes for 6630834*/
    elsif (X_Customer_id IS NOT NULL) OR (X_Customer_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
       /* Changes for bug 8247716 start here */
       if(NVL(X_Bill_To_Customer_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) Then
       X_Bill_To_Customer_id := X_Customer_id;
       end if;
        if(NVL(X_Ship_To_Customer_id,PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) Then
       X_Ship_To_Customer_id := X_Customer_id;
       end if;
        /* Changes for bug 8247716 end here */
/*Changes for 6630834 end here*/
    End if;
    CLOSE Ic_billing; /*Added by avaithia for Bug 3876207*/

    OPEN c4;
    FETCH C4 into l_cust_acc_rel_code;
    CLOSE C4;


--fix for bug#2045638 starts
    --check whether the customer is active or not
    X_Err_Code  := 0;
    X_Err_Stage := 'Get customer status <' ||to_char(X_Customer_Id) ||'>' ;
    Begin

        -- 4363092 TCA changes, replaced RA views with HZ tables
         /*
         Select Nvl(status,'A')
           into Pl_Status
           from Ra_Customers r
         Where  r.customer_id = X_Customer_Id;
         */
         Select Nvl(cust_acct.status,'A')
           into Pl_Status
           from hz_parties party,
                hz_cust_accounts cust_acct
         Where
                cust_acct.party_id = party.party_id
            and cust_acct.cust_account_id = X_Customer_Id;

        -- 4363092 end

        If Pl_Status = 'I' then
                X_Err_Code  := 20;
                X_Err_Stage := 'PA_CUSTOMER_NOT_ACTIVE' ;
                return;
        end if;
     Exception
        When NO_DATA_FOUND then
            X_Err_Code  := 20;
            X_Err_Stage := 'PA_CUSTOMER_ID_INVALID' ; --Bug#5183150.Changed the error message PA_CUSTOMER_NOT_EXIST to PA_CUSTOMER_ID_INVALID.
            return;
        When OTHERS then
            X_Err_Code  := SQLCODE;
            return;
     End;


    If l_ic_billing='Y' or l_cust_acc_rel_code='N' THEN
       X_Bill_To_Customer_id := X_Customer_id;
       X_Ship_To_Customer_id := X_Customer_id;

       OPEN C1;

       LOOP
         FETCH C1 INTO l_address_id, l_contact_id, l_site_use_code;
         EXIT WHEN C1%NOTFOUND;

         if l_site_use_code = 'SHIP_TO' then
     /*  Code changes begin for BUg 3911782 */

             If Pl_Ship_To_Address_Id IS NULL
	     OR Pl_Ship_To_Address_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
	     Pl_Ship_To_Address_Id := l_address_id;
	      else
	      l_return_value := Is_Address_Valid(l_site_use_code => l_site_use_code ,
                                                 l_Customer_Id => X_Ship_To_Customer_Id,
			                         l_Address_Id => Pl_Ship_To_Address_Id);
              IF l_return_value = 'N' then
                 X_Err_Code  := 20;
                 X_Err_Stage := 'PA_SHIP_TO_ADDR_INVALID';
		 return;
              END IF;
	     End if;
             --  Pl_Ship_To_Address_Id := l_address_id;
	   /*  Code changes end for BUg 3911782 */
	   --  Pl_Ship_To_Contact_Id := l_contact_id; --commented for tracking bug
          /* Changes begin for tracking bug by aditi */
          If Pl_Ship_To_Contact_Id IS NULL
	     OR Pl_Ship_To_Contact_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            Pl_Ship_To_Contact_Id := l_contact_id;
          Else
	    l_return_value := Is_Contact_Valid(l_site_use_code => l_site_use_code ,
                                                 l_Customer_Id => X_Ship_To_Customer_Id,
						 l_Address_Id => Pl_Ship_To_Address_Id,
			                         l_Contact_Id => Pl_Ship_To_Contact_Id);
              IF l_return_value = 'N' then
			IF p_calling_module = 'AMG' then --added this if condition for Bug#4770535.Throw the error only in case of AMG
                                         X_Err_Code  := 20;
                                         X_Err_Stage := 'PA_SHIP_TO_CONTACT_INVALID';
                                         return;
                	ELSE
                                         Pl_Ship_To_Contact_Id := NULL; -- added this for Bug#4770535 so that no contacts are copied if the
                                                               -- contacts are invalid.
                	END IF;          --added this if condition for Bug#4770535

              END IF;
	 End if;
	 /* Changes end for tracking bug by aditi **/
         elsif l_site_use_code = 'BILL_TO' then
	 /*  Code changes begin for BUg 3911782 */

             If Pl_Bill_To_Address_Id IS NULL
	     OR Pl_Bill_To_Address_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
	     Pl_Bill_To_Address_Id := l_address_id;
	      else
	      --dbms_output.put_line('Value of l_site_use_code'  ||l_site_use_code);
	      --dbms_output.put_line('Value of X_Bill_To_Customer_Id'  ||X_Bill_To_Customer_Id);
	      --dbms_output.put_line('Value of Pl_Bill_To_Address_Id'  ||Pl_Bill_To_Address_Id);

	      l_return_value := Is_Address_Valid(l_site_use_code => l_site_use_code ,
                                                 l_Customer_Id => X_Bill_To_Customer_Id,
			                         l_Address_Id => Pl_Bill_To_Address_Id);

              --dbms_output.put_line('is the error from this place');
              IF l_return_value = 'N' then
                 X_Err_Code  := 20;
                 X_Err_Stage := 'PA_BILL_TO_ADDR_INVALID';
                 return;
              END IF;
	     End if;
           -- Pl_Bill_To_Address_Id := l_address_id;
	     /*  Code changes end for BUg 3911782 */
           -- Pl_Bill_To_Contact_Id := l_contact_id; --Commented for tracking bug
	       /* Changes begin for tracking bug by aditi */
          If Pl_Bill_To_Contact_Id IS NULL
	     OR Pl_Bill_To_Contact_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            Pl_Bill_To_Contact_Id := l_contact_id;
          Else
	    l_return_value := Is_Contact_Valid(l_site_use_code => l_site_use_code ,
                                                 l_Customer_Id => X_Bill_To_Customer_Id,
						 l_Address_Id => Pl_Bill_To_Address_Id,
			                         l_Contact_Id  => Pl_Bill_To_Contact_Id);
              IF l_return_value = 'N' then
		IF p_calling_module = 'AMG' then --added this if condition for Bug#4770535.Throw the error only in case of AMG
		        	         X_Err_Code  := 20;
                			 X_Err_Stage := 'PA_BILL_TO_CONTACT_INVALID';
		 			 return;
		ELSE
				 	Pl_Bill_To_Contact_Id := NULL; -- added this for Bug#4770535 so that no contacts are copied if the
					                       -- contacts are invalid.
		END IF;			--added this if condition for Bug#4770535

              END IF;
	 End if;
	 /* Changes end for tracking bug by aditi **/
         end if;

       END LOOP;

       CLOSE C1;

       If Pl_Ship_To_Address_Id is null then
          X_Err_Code  := 20;
          X_Err_Stage := 'PA_NO_SHIP_TO_ADDRESS';
          return;
       end if;

       If Pl_Bill_To_Address_Id is null then
          X_Err_Code  := 20;
          X_Err_Stage := 'PA_NO_BILL_TO_ADDRESS';
          return;
       end if;

--    If Pl_Ship_To_Contact_Id is null then
--       X_Err_Code  := 30;
--       X_Err_Stage := 'PA_NO_SHIP_TO_CONTACT';
--       return;
--  end if;

       /* Commented out the following if condtion for not showing the warning message if there is no active billing contact
	  for the customer for Bug#4995026 */

       /*If Pl_Bill_To_Contact_Id is null and p_quick_entry_flag = 'Y' then */  -- Bug 2984536. Donot show warning otherwise.
       /*   X_Err_Code  := 10; */
       /*   X_Err_Stage := 'PA_NO_BILL_TO_CONTACT';*/
      /* commented the below line for bug 2977546 */
      /* return; */
       /*end if;*/  -- End of commenting for Bug#4995026

       X_Bill_To_Address_Id   :=  Pl_Bill_To_Address_Id  ;
       X_Ship_To_Address_Id   :=  Pl_Ship_To_Address_Id  ;
       X_Bill_To_Contact_Id   :=  Pl_Bill_To_Contact_Id  ;
       X_Ship_To_Contact_Id   :=  Pl_Ship_To_Contact_Id  ;
       X_Bill_To_Customer_Id  :=  X_Customer_Id;
       X_Ship_To_Customer_Id  :=  X_Customer_Id;
       Return;
END IF;

/*If   customer account relationship flag is Yes or all,  validate  the passed bill_to_customer_id and ship_to_customer_id */


  IF l_cust_acc_rel_code = 'Y' or l_cust_acc_rel_code = 'A' Then

     IF X_Bill_To_Customer_Id IS NOT NULL OR X_Bill_To_Customer_Id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN --Changed if Condition for Bug 6630834

          PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CUSTOMER_NAME_OR_ID
          ( p_customer_id    => X_Bill_To_Customer_Id
           ,p_check_id_flag  => 'Y'
           ,x_customer_id    => l_customer_id
           ,x_return_status  => l_return_status
           ,x_error_msg_code => l_error_msg_code);

          if l_return_status <> FND_API.G_RET_STS_SUCCESS then
                X_Err_Code  := 20;
                X_Err_Stage := 'PA_CUSTOMER_ID_INVALID_BILL' ;
                return;
          end if;

/*validate the relation of passed customer_id and bill_to_customer_id */

            l_Bill_To_Customer_id :=  X_Bill_To_Customer_id;
            IF X_Bill_To_Customer_Id <> X_Customer_ID THEN
              OPEN C5;
              FETCH C5 INTO l_valid_bill_id;
              Close C5;
            End if;

       End if;

      IF X_Ship_To_Customer_Id IS NOT NULL OR X_Ship_To_Customer_Id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN --Changed if Condition for Bug 6630834

         PA_CUSTOMERS_CONTACTS_UTILS.CHECK_CUSTOMER_NAME_OR_ID
              ( p_customer_id    => X_Ship_To_Customer_Id
               ,p_check_id_flag  => 'Y'
               ,x_customer_id    => l_customer_id
               ,x_return_status  => l_return_status
               ,x_error_msg_code => l_error_msg_code);

              if l_return_status <> FND_API.G_RET_STS_SUCCESS then
                X_Err_Code  := 20;
                X_Err_Stage := 'PA_CUSTOMER_ID_INVALID_SHIP'  ;
                return;
              end if;

/*validate the relation of passed customer_id and bill_to_customer_id */

          IF X_ship_To_Customer_Id <> X_Customer_ID THEN
            OPEN C6;
            FETCH C6 INTO l_valid_ship_id;
            Close C6;
          End if;

       END IF;

/*If customer account relationship is YES and invalid values are passed for bill to_customer_id and ship_to_customer_id,
  throw an error message and stop processing */

       IF X_customer_id = X_bill_to_customer_id THEN
          l_valid_bill_id := 1;
       END IF;

       IF X_customer_id = X_ship_to_customer_id THEN
          l_valid_ship_id := 1;
       END IF;

       IF l_cust_acc_rel_code = 'Y' THEN
         If X_ship_To_Customer_Id is not null and X_bill_To_Customer_Id is not null then
           If l_valid_ship_id IS  NULL AND l_valid_bill_id is NULL THEN
               If p_quick_entry_flag = 'Y' THEN
                   X_Err_Code  := 20;
                   X_Err_Stage := 'PA_BOTH_CUST_NO_RLTD';
                   return;
               Else
                    X_ship_To_Customer_Id := X_customer_id;
                    X_bill_To_Customer_Id := X_customer_id;
               End if;
            end if;
        End if;

        If X_ship_To_Customer_Id is not null Then
          If l_valid_ship_id IS  NULL THEN
               If p_quick_entry_flag = 'Y' THEN
                    X_Err_Code  := 20;
                    X_Err_Stage := 'PA_SHIP_TO_NOT_VALID' ;
                    return;
               Else
                    X_ship_To_Customer_Id := X_customer_id;
               End if;
          end if;
       end if;

         if  X_bill_To_Customer_Id is not null then
          If l_valid_bill_id IS  NULL THEN
               If p_quick_entry_flag = 'Y' THEN
                    X_Err_Code  := 20;
                    X_Err_Stage := 'PA_BILL_TO_NOT_VALID' ;
                    return;
               Else
                    X_bill_To_Customer_Id := X_customer_id;
               End if;
          end if;
       end if;

       END IF;


          If X_Bill_To_Customer_Id is null and X_Ship_To_Customer_Id is null then
            X_bill_to_customer_id :=X_customer_ID;
            X_ship_to_customer_id :=X_customer_ID;
         /* Commented the below two lines for bug 2987225 */
         /* X_Err_Code  := 10;
            X_Err_Stage := 'PA_BOTH_CUST_UPD_REQ' ;
     */
          End if;

         If  X_Bill_To_Customer_Id Is not null  and X_Ship_To_Customer_Id is null then
            X_ship_to_customer_id :=X_customer_ID;
         /* Commented the below two lines for bug 2987225 */
         /* X_Err_Code  := 10;
            X_Err_Stage := 'PA_STO_CUST_UPD_REQ' ;
         */
         End if;

         If  X_Bill_To_Customer_Id Is  null  and X_Ship_To_Customer_Id is not null then
            X_bill_to_customer_id :=X_customer_ID;
         /* Commented the below two lines for bug 2987225 */
         /* X_Err_Code  := 10;
            X_Err_Stage := 'PA_BTO_CUST_UPD_REQ' ;
     */
      End if;

       OPEN C2;
       LOOP
          FETCH C2 INTO l_address_id, l_contact_id, l_site_use_code;
          EXIT WHEN C2%NOTFOUND;


          if l_site_use_code = 'BILL_TO' then
      /*  Code changes begin for BUg 3911782 */
             If Pl_Bill_To_Address_Id IS NULL
         OR Pl_Bill_To_Address_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
         Pl_Bill_To_Address_Id := l_address_id;
         else

          l_return_value := Is_Address_Valid(l_site_use_code => l_site_use_code ,
                                                 l_Customer_Id => X_Bill_To_Customer_Id,
                                     l_Address_Id => Pl_Bill_To_Address_Id);


              IF l_return_value = 'N' then
                 X_Err_Code  := 20;
                 X_Err_Stage := 'PA_BILL_TO_ADDR_INVALID';
              END IF;
         End if;
           -- Pl_Bill_To_Address_Id := l_address_id;
         /*  Code changes end for BUg 3911782 */
          --   Pl_Bill_To_Contact_Id := l_contact_id;--Commented for tracking bug
	      /* Changes begin for tracking bug by aditi */
          If Pl_Bill_To_Contact_Id IS NULL
	     OR Pl_Bill_To_Contact_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            Pl_Bill_To_Contact_Id := l_contact_id;
          Else
	    l_return_value := Is_Contact_Valid(l_site_use_code => l_site_use_code ,
                                                 l_Customer_Id => X_Bill_To_Customer_Id,
                                                 l_Address_Id => Pl_Bill_To_Address_Id,
			                         l_Contact_Id  => Pl_Bill_To_Contact_Id);
              IF l_return_value = 'N' then
		IF p_calling_module = 'AMG' then --added this if condition for Bug#4770535.Throw the error only in case of AMG
                                         X_Err_Code  := 20;
                                         X_Err_Stage := 'PA_BILL_TO_CONTACT_INVALID';
                                         return;
                ELSE
                                        Pl_Bill_To_Contact_Id := NULL; -- added this for Bug#4770535 so that no contacts are copied if the
                                                               --contacts are invalid.
                END IF;                 --added this if condition for Bug#4770535

              END IF;
	 End if;
	 /* Changes end for tracking bug by aditi **/
	  end if;

        END LOOP;

        CLOSE C2;

       If Pl_Bill_To_Address_Id is null then
          X_Err_Code  := 20;
          X_Err_Stage := 'PA_NO_BILL_TO_ADDRESS';
          return;
       end if;


       OPEN C3;
       LOOP
         FETCH C3 INTO l_address_id, l_contact_id, l_site_use_code;
         EXIT WHEN C3%NOTFOUND;

         if l_site_use_code = 'SHIP_TO' then
     /*  Code changes begin for BUg 3911782 */
             If Pl_Ship_To_Address_Id IS NULL
         OR Pl_Ship_To_Address_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
         Pl_Ship_To_Address_Id := l_address_id;
         else
          l_return_value := Is_Address_Valid(l_site_use_code => l_site_use_code ,
                                                 l_Customer_Id => X_Ship_To_Customer_Id,
                                     l_Address_Id => Pl_Ship_To_Address_Id);
              IF l_return_value = 'N' then
                 X_Err_Code  := 20;
                 X_Err_Stage := 'PA_SHIP_TO_ADDR_INVALID';
              END IF;
         End if;
             --  Pl_Ship_To_Address_Id := l_address_id;
       /*  Code changes end for BUg 3911782 */
         --   Pl_Ship_To_Contact_Id := l_contact_id; --Commented for tracking bug
	  /* Changes begin for tracking bug by aditi */
          If Pl_Ship_To_Contact_Id IS NULL
	     OR Pl_Ship_To_Contact_Id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM Then
            Pl_Ship_To_Contact_Id := l_contact_id;
          Else
	    l_return_value := Is_Contact_Valid(l_site_use_code => l_site_use_code ,
                                                 l_Customer_Id => X_Ship_To_Customer_Id,
						 l_Address_Id => Pl_Ship_To_Address_Id,
			                         l_Contact_Id => Pl_Ship_To_Contact_Id);
             IF l_return_value = 'N' then
		IF p_calling_module = 'AMG' then --added this if condition for Bug#4770535. Throw the error only in case of AMG
                                         X_Err_Code  := 20;
                                         X_Err_Stage := 'PA_SHIP_TO_CONTACT_INVALID';
                                         return;
                ELSE
                                         Pl_Ship_To_Contact_Id := NULL; -- added this for Bug#4770535 so that no contacts are copied if the
                                                               -- contacts are invalid.
                END IF;                 --added this if condition for Bug#4770535

             END IF;
	 End if;
	 /* Changes end for tracking bug by aditi **/
         end if;

         END LOOP;

         CLOSE C3;

       If Pl_Ship_To_Address_Id is null then
          X_Err_Code  := 20;
          X_Err_Stage := 'PA_NO_SHIP_TO_ADDRESS';
          return;
       end if;

    X_Bill_To_Address_Id   :=  Pl_Bill_To_Address_Id  ;
    X_Ship_To_Address_Id   :=  Pl_Ship_To_Address_Id  ;
    X_Bill_To_Contact_Id   :=  Pl_Bill_To_Contact_Id  ;
    X_Ship_To_Contact_Id   :=  Pl_Ship_To_Contact_Id  ;

  End If;

Exception
      When Others Then
      --In case of any unexpected exceptions
          --Close the Cursor if it is open and then return
          --Bug 3876207
          IF Ic_billing%ISOPEN THEN
               CLOSE Ic_billing;
          END IF;
          X_Err_Code     := SQLCODE;
          return ;
End Get_Customer_Info;


--  PROCEDURE
--              Create_Customer_Contacts
--

Procedure Create_Customer_Contacts
                  ( X_Project_Id                  In  Number,
                    X_Customer_Id                 In  Number,
            X_Project_Relation_Code       In  Varchar2,
                    X_Customer_Bill_Split         In  Number,
            X_Bill_To_Customer_Id         In Number := NULL   ,     /* For Bug 2731449 */
            X_Ship_To_Customer_Id         In Number := NULL   ,     /* For Bug 2731449 */
                    X_Bill_To_Address_Id          In  Number,
                    X_Ship_To_Address_Id          In  Number,
                    X_Bill_To_Contact_Id          In  Number,
                    X_Ship_To_Contact_Id          In  Number,
                    X_Inv_Currency_Code           In  Varchar2,
                    X_Inv_Rate_Type       In  Varchar2,
                    X_Inv_Rate_Date       In  Date,
                    X_Inv_Exchange_Rate           In Number,
                    X_Allow_Inv_Rate_Type_Fg      In Varchar2,
                    X_Bill_Another_Project_Fg     In Varchar2,
                    X_Receiver_Task_Id            In Number,
                    P_default_top_task_customer   In pa_project_customers.DEFAULT_TOP_TASK_CUST_FLAG%TYPE  default 'N',
                    X_User                        In  Number,
                    X_Login                       In  Number,
                    X_Err_Code                    In Out NOCOPY Number, --File.Sql.39 bug 4440895
                    X_Err_Stage                   In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                    X_Err_Stack                   In Out NOCOPY Varchar2 ) is --File.Sql.39 bug 4440895

  l_dummy VARCHAR2(1); -- Added for Bug 3110489
  /** Cursor added for Bug 3110489 **/
  CURSOR Cur_Customer_Exists(c_project_id pa_projects_all.project_id%TYPE,
                              c_customer_id  pa_project_customers.customer_id%TYPE)
  IS
  Select 'Y' FROM pa_project_customers
  WHERE project_id = c_project_id
  AND customer_id = c_customer_id;

  --bug 4054587
  l_billing VARCHAR2(10) := 'BILLING';
  l_shipping VARCHAR2(10):= 'SHIPPING';

	l_bill_to_contact_exists VARCHAR2(1); -- Bug 5554475
	l_ship_to_contact_exists VARCHAR2(1); -- Bug 5554475

Begin

     X_Err_Code  := 0 ;

     /** Code change begins for Bug 3110489 **/
     OPEN Cur_Customer_Exists(X_Project_Id,X_Customer_Id);
     FETCH Cur_Customer_Exists INTO l_dummy;
     IF Cur_Customer_Exists%NOTFOUND then
     /** Code change ends for Bug 3110489 **/

     Insert Into Pa_Project_Customers
         ( Project_Id,
           Customer_Id,
           Project_Relationship_Code,
           Customer_Bill_Split,
       bill_to_customer_id,                      /* For Bug 2731449 */
           ship_to_customer_id,                      /* For Bug 2731449 */
           Bill_To_Address_Id,
           Ship_To_Address_Id,
           Inv_Currency_Code,
           Inv_Rate_Type,
           Inv_Rate_Date,
           Inv_Exchange_Rate,
           Allow_Inv_User_Rate_Type_Flag,
           Bill_Another_Project_Flag,
           Receiver_Task_Id,
           Creation_Date,
           Created_By,
           Last_Update_Date,
           Last_Update_Login,
           Last_Updated_By,
           RECORD_VERSION_NUMBER,
           DEFAULT_TOP_TASK_CUST_FLAG )  /*The top tak cust added for FPM Development */
     Values (
           X_Project_Id,
           X_Customer_Id,
           X_Project_Relation_Code,
           X_Customer_Bill_Split,
           X_Bill_To_Customer_Id,                      /* For Bug 2731449 */
           X_Ship_To_Customer_Id,                      /* For Bug 2731449 */
           X_Bill_To_Address_Id,
           X_Ship_To_Address_Id,
           X_Inv_Currency_Code,
           X_Inv_Rate_Type,
           X_Inv_Rate_Date,
           X_Inv_Exchange_Rate,
           X_Allow_Inv_Rate_Type_Fg,
           X_Bill_Another_Project_Fg,
           X_Receiver_Task_Id,
           Sysdate,
           X_User,
           Sysdate,
           X_Login,
           X_User,
           1,
           P_default_top_task_customer) ;
End if; -- Added for Bug 3110489
--dbms_output.put_line('Value of X_Bill_To_Contact_Id'||X_Bill_To_Contact_Id);
--dbms_output.put_line('Value of X_Ship_To_Contact_Id'||X_Ship_To_Contact_Id);
--dbms_output.put_line('Value of X_Project_Id'||X_Project_Id);
--dbms_output.put_line('Value of X_Customer_Id'||X_Customer_Id);
--dbms_output.put_line('Value of X_Bill_To_Customer_Id'||X_Bill_To_Customer_Id);
--dbms_output.put_line('Value of X_Bill_To_Contact_Id'||X_Bill_To_Contact_Id);
--dbms_output.put_line('Value of l_billing'||l_billing);


--start of addition for bug 5554475
               BEGIN
               SELECT 'Y'
               INTO   l_bill_to_contact_exists
               FROM   dual
               WHERE EXISTS (SELECT 'Y'
                             FROM   Pa_Project_Contacts
                             WHERE  Project_Id   = X_Project_Id
                             AND    Customer_Id  = X_Customer_Id
                             AND    Contact_Id   = X_Bill_To_Contact_Id
                             AND    PROJECT_CONTACT_TYPE_CODE = l_billing
                            );
              EXCEPTION WHEN NO_DATA_FOUND THEN
                 l_bill_to_contact_exists := 'N';
              END;

		BEGIN
		SELECT 'Y'
		INTO   l_ship_to_contact_exists
		FROM   dual
		WHERE EXISTS (SELECT 'Y'
			     FROM   Pa_Project_Contacts
			     WHERE  Project_Id   = X_Project_Id
			     AND    Customer_Id  = X_Customer_Id
			     AND    Contact_Id   = X_Ship_To_Contact_Id
			     AND    PROJECT_CONTACT_TYPE_CODE = l_shipping
			   );
		EXCEPTION WHEN NO_DATA_FOUND THEN
                 l_ship_to_contact_exists := 'N';
              END;
   --end of addition for bug 5554475



    If X_Bill_To_Contact_Id is not null then
	If l_bill_to_contact_exists = 'N' then   /* for bug 5554475 */
        Insert Into Pa_Project_Contacts
         ( Project_Id,
           Customer_Id,
           bill_ship_customer_id,             /* For Bug 2731449 */
       Contact_Id,
       Project_Contact_Type_Code,
           Creation_Date,
           Created_By,
           Last_Update_Date,
           Last_Update_Login,
           Last_Updated_By,
           RECORD_VERSION_NUMBER )
         Values (
           X_Project_Id,
           X_Customer_Id,
       X_Bill_To_Customer_Id,          /* For Bug 2731449 */
           X_Bill_To_Contact_Id,
           --'BILLING', --bug 4054587
           l_billing,
           Sysdate,
           X_User,
           Sysdate,
           X_Login,
           X_User,
           1 );
	End If;
   END if;

     If X_Ship_To_Contact_Id is not null then
	If l_ship_to_contact_exists = 'N' then /* for bug 5554475 */
        Insert Into Pa_Project_Contacts
         ( Project_Id,
           Customer_Id,
       bill_ship_customer_id,          /* For Bug 2731449 */
           Contact_Id,
           Project_Contact_Type_Code,
           Creation_Date,
           Created_By,
           Last_Update_Date,
           Last_Update_Login,
           Last_Updated_By,
           RECORD_VERSION_NUMBER )
         Values (
           X_Project_Id,
           X_Customer_Id,
       X_Ship_To_Customer_Id,              /* For Bug 2731449 */
           X_Ship_To_Contact_Id,
           --'SHIPPING', --bug 4054587
       l_shipping,
           Sysdate,
           X_User,
           Sysdate,
           X_Login,
           X_User,
           1 );
	End If ;
     END if;

Exception
   When Others Then
     X_Err_Code       :=  SQLCODE ;
--dbms_output.put_line('please show the SQL Error '||sqlerrm);
End Create_Customer_Contacts ;

-- API name                      : Is_Address_Valid
-- Type                          : Function
-- Pre-reqs                      : None
-- Return Value                  : 'Y', 'N'
-- Prameters
-- l_site_use_code IN VARCHAR2
-- l_Customer_Id IN NUMBER
--  l_Address_Id IN NUMBER
--  History
--
--  12-OCT-2004  adarora             -Created
--
--  Notes: This api is called from GET_CUSTOMER_INFO to validate bill_to_address_id and ship_to_address_id

FUNCTION Is_Address_Valid(l_site_use_code IN VARCHAR2 ,
                          l_Customer_Id IN NUMBER,
              l_Address_Id IN NUMBER) RETURN VARCHAR2 IS
   l_return_value VARCHAR2(1) := 'N';
BEGIN

  BEGIN
   -- 4363092 TCA changes, replaced RA views with HZ tables
   /*
   SELECT 'Y'
   INTO l_return_value
    FROM   Ra_Addresses a,
           Ra_Site_Uses su
    WHERE  a.Address_Id        = su.Address_Id
      AND  Nvl(a.Status,'A')   = 'A'
      AND  a.Customer_id       = l_Customer_Id
      AND  a.Address_Id        = l_Address_Id
      AND  Nvl(su.Status, 'A') = 'A'
      AND su.site_use_code     = l_site_use_code;
    */

   SELECT 'Y'
   INTO l_return_value
    FROM
           hz_cust_acct_sites_all acct_site,
           hz_cust_site_uses su
    WHERE
      acct_site.cust_acct_site_id  = su.cust_acct_site_id
      AND  Nvl(acct_site.Status,'A')   = 'A'
      AND  acct_site.cust_account_id   = l_Customer_Id
      AND  acct_site.cust_acct_site_id = l_Address_Id
      AND  Nvl(su.Status, 'A') = 'A'
      AND su.site_use_code     = l_site_use_code;

    -- 4363092 end
      l_return_value := 'Y';

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
      l_return_value := 'N';

      WHEN OTHERS THEN
      l_return_value := 'N';
   END;

    RETURN l_return_value;
END Is_Address_Valid;

-- API name                      : Is_Contact_Valid
-- Type                          : Function
-- Pre-reqs                      : None
-- Return Value                  : 'Y', 'N'
-- Prameters
-- l_site_use_code IN VARCHAR2
-- l_Customer_Id IN NUMBER
-- l_Address_Id IN NUMBER
-- l_Contact_Id IN NUMBER
--  History
--
--  02-FEB-2004  adarora             -Created
--
--  Notes: This api is called from GET_CUSTOMER_INFO to validate bill_to_contact_id and ship_to_contact_id

FUNCTION Is_Contact_Valid(l_site_use_code IN VARCHAR2 ,
                          l_Customer_Id IN NUMBER,
			  l_Address_Id IN NUMBER,
			  l_Contact_Id IN NUMBER) RETURN VARCHAR2 IS
l_return_value VARCHAR2(1) := 'N';

BEGIN
--dbms_output.put_line('Value of l_site_use_code'||l_site_use_code);
--dbms_output.put_line('Value of l_Customer_Id'||l_Customer_Id);
--dbms_output.put_line('Value of l_Address_Id'||l_Address_Id);
--dbms_output.put_line('Value of l_Contact_Id'||l_Contact_Id);
l_return_value  := 'N';
  BEGIN
  /* SELECT 'Y'
   INTO l_return_value
    FROM   Ra_Addresses a,
           Ra_Site_Uses su
    WHERE  a.Address_Id        = su.Address_Id
      AND  Nvl(a.Status,'A')   = 'A'
      AND  a.Customer_id       = l_Customer_Id
      AND  a.Address_Id        = l_Address_Id
      AND  su.Contact_Id       = l_Contact_Id
      AND  Nvl(su.Status, 'A') = 'A'
      AND su.site_use_code     = l_site_use_code; */

-- 4633405 Start: TCA changes, replaced RA views with HZ tables
/*
 SELECT    'Y'
   INTO l_return_value
FROM
  ra_contacts c,
  ra_contact_roles cr
WHERE  c.customer_id = l_Customer_Id
and   c.contact_id = l_Contact_Id
and  c.contact_id = cr.contact_id
and  cr.usage_code = l_site_use_code
and  nvl(c.status,'A') = 'A'
and  c.address_id is null;
*/
 SELECT    'Y'
   INTO l_return_value
FROM
  hz_cust_account_roles acct_role,
  hz_role_responsibility hrrep
WHERE  acct_role.cust_account_id = l_Customer_Id
and   acct_role.cust_account_role_id = l_Contact_Id
and  acct_role.cust_account_role_id = hrrep.cust_account_role_id
and  hrrep.responsibility_type = l_site_use_code
and  nvl(acct_role.current_role_state,'A') = 'A'
and  acct_role.cust_acct_site_id is null
and  acct_role.role_type = 'CONTACT';
-- 4633405 End: TCA changes, replaced RA views with HZ tables

      l_return_value := 'Y';
--dbms_output.put_line('Value of l_return_value in first loop'||l_return_value);
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
      l_return_value := 'N';

      WHEN OTHERS THEN
      l_return_value := 'N';
   END;

BEGIN

-- 4633405 Start: TCA changes, replaced RA views with HZ tables
/*
  SELECT  'Y'
   INTO l_return_value
FROM
  ra_contacts c ,
  ra_contact_roles cr ,
  ra_addresses a
WHERE c.customer_id = l_Customer_Id
and  c.contact_id = cr.contact_id
and   c.contact_id = l_Contact_Id
and  cr.usage_code = l_site_use_code
and nvl(c.status,'A') = 'A'
and c.address_id = a.address_id
and  c.address_id = l_Address_Id;
*/
  SELECT  'Y'
   INTO l_return_value
FROM
  hz_cust_account_roles acct_role ,
  hz_role_responsibility hrrep ,
  hz_cust_acct_sites_all acct_site
WHERE acct_role.cust_account_id = l_Customer_Id
and  acct_role.cust_account_role_id = hrrep.cust_account_role_id
and  acct_role.cust_account_role_id = l_Contact_Id
and  hrrep.responsibility_type = l_site_use_code
and nvl(acct_role.current_role_state,'A') = 'A'
and acct_role.cust_acct_site_id = acct_site.cust_acct_site_id
and  acct_role.cust_acct_site_id = l_Address_Id
and  acct_role.role_type = 'CONTACT';
-- 4633405 End: TCA changes, replaced RA views with HZ tables

      l_return_value := 'Y';
--dbms_output.put_line('Value of l_return_value in second loop'||l_return_value);

   EXCEPTION
     WHEN NO_DATA_FOUND THEN

      IF l_return_value <> 'Y' Then
      l_return_value := 'N';
--dbms_output.put_line('Value of l_return_value in second loop'||l_return_value);
      End if;
      WHEN OTHERS THEN
      l_return_value := 'N';
   END;

    RETURN l_return_value;
END Is_Contact_Valid;

-- API name                      : revenue_accrued_or_billed
-- Type                          : Function
-- Pre-reqs                      : None
-- Return Value                  : True, False
-- Prameters
-- l_Project_Id In  Number
--  History
--
--  12-JUN-2005  adarora             -Created
--
--  Notes: This api is called from UPDATE_PROJECT to check if customer_bill_split is updateable or nor
--  depending upon whether any invoices or revenues have been chanrged against the passed project.


 Function revenue_accrued_or_billed( p_project_Id In  Number)
 return boolean IS
   CURSOR C IS
	SELECT 'x'
	FROM dual
	  WHERE exists
		(select null
		 from pa_draft_revenues r
		 where r.project_id = p_project_Id
		 )
	   or    exists
		 (select null
		  from pa_draft_invoices i
		  where i.project_id = p_project_Id
		 );
   x_exists	varchar2(1):= NULL;
   Begin
	OPEN C;
	FETCH C into x_exists;
	CLOSE C;
 	IF (x_exists IS NOT NULL) THEN
		return TRUE;
	ELSE
	 	return FALSE;
	END IF;
   End  revenue_accrued_or_billed;

-- API name                      : check_proj_tot_contribution
-- Type                          : Function
-- Pre-reqs                      : None
-- Return Value                  : Number
-- Prameters
-- l_Project_Id In  Number
--  History
--
--  12-JUN-2005  adarora             -Created
--
--  Notes: This api is called from UPDATE_PROJECT to compute the net customer_bill_split
--  for a contract project. It should not exceed 100. if it does, then an error is thrown.

Function check_proj_tot_contribution ( p_project_Id In  Number, x_valid_proj_flag OUT NOCOPY BOOLEAN )
                                                              -- File.sql.39 Bug 4633405 (For new API)
return number is
CURSOR c_prj IS
  select project_type_class_code,project_status_code
    from pa_projects_v
   where project_id = p_project_Id;

   CURSOR C IS
	SELECT sum(pc.customer_bill_split)
	FROM pa_project_customers pc
	WHERE pc.project_id = p_project_Id
	GROUP by pc.project_id;


  x_percentage	NUMBER(15):=0;
  l_proj_type_class       pa_project_types_all.project_type_class_code%TYPE;
  l_project_status_code   pa_projects_all.project_status_code%TYPE;
  Begin
  x_valid_proj_flag := false;
  IF p_project_id IS NOT NULL THEN
  OPEN  c_prj;
  FETCH c_prj INTO l_proj_type_class,l_project_status_code;
  CLOSE c_prj;
  END IF;

  /* The check has to be done only for an Approved Contract Type project. */
  IF nvl(l_proj_type_class,'NONE') = 'CONTRACT' --AND l_project_status_code = 'APPROVED'
   THEN
        x_valid_proj_flag := true;
        OPEN C;
	FETCH C into x_percentage;
	CLOSE C;
	return x_percentage;
   END IF;

   IF (x_valid_proj_flag = FALSE) Then
   RETURN 0;
   END if;

   EXCEPTION
      when OTHERS then
         x_valid_proj_flag := false;

   End check_proj_tot_contribution;

-- API name		: Check_Receiver_Proj_Enterable
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id                    IN NUMBER     Required
-- p_customer_id                   IN NUMBER     Required
-- p_receiver_task_id              IN NUMBER     Optional Default = FND_API.G_MISS_NUM
-- x_bill_another_project_flag     OUT VARCHAR2  Required
-- x_return_status                 OUT VARCHAR2  Required
-- x_error_msg_code                OUT VARCHAR2  Required
--  History
--
--  14-SEP-2005  adarora             -Created
--
--  Notes: This api is called from UPDATE_PROJECT to check if the project and task can be specified
--   as receiver project and task for the customer passed.

PROCEDURE CHECK_RECEIVER_PROJ_ENTERABLE
(  p_project_id                    IN NUMBER
  ,p_customer_id                   IN NUMBER
  ,p_receiver_task_id              IN NUMBER     := FND_API.G_MISS_NUM
  ,x_bill_another_project_flag     IN OUT NOCOPY VARCHAR2  -- File.sql.39 Bug 4633405 (For new API)
  ,x_return_status                 OUT NOCOPY VARCHAR2     -- File.sql.39 Bug 4633405 (For new API)
  ,x_error_msg_code                OUT NOCOPY VARCHAR2     -- File.sql.39 Bug 4633405 (For new API)
)
IS
   l_dummy                         VARCHAR2(1);
   l_bill_another_project_flag     VARCHAR2(1);
   CURSOR C1(c_project_id NUMBER) IS
      SELECT '1'
      FROM
      pa_project_types b
      WHERE b.project_type_class_code = 'CONTRACT' AND
            b.project_type =
               (SELECT project_type
                FROM  pa_projects_all
                WHERE project_id = c_project_id) AND
            (b.cc_prvdr_flag = 'N' OR b.cc_prvdr_flag is NULL);
   CURSOR C2(c_customer_id NUMBER) IS
      SELECT '1'
      FROM pa_implementations_all
      WHERE customer_id = c_customer_id;
   CURSOR C3 IS
      SELECT '1'
      FROM pa_implementations
      WHERE cc_ic_billing_prvdr_flag = 'Y';
BEGIN
   l_bill_another_project_flag  := x_bill_another_project_flag;
   open C1(p_project_id);
   fetch C1 into l_dummy;

   open C2(p_customer_id);
   fetch C2 into l_dummy;

   open C3;
   fetch C3 into l_dummy;

   if (C1%FOUND AND C2%FOUND AND C3%FOUND) then
      /* Doing this check here so that if standard invoice is generated for the project
	then we should not allow to check/uncheck the bill_another_project_flag */
		/* Start for bug 3255704 */
    if pa_invoice_utils.check_draft_invoice_exists(p_project_id,
						     p_customer_id) = 0  then
    		--dbms_output.put_line('No draft invoice');

      if (p_receiver_task_id <> FND_API.G_MISS_NUM) AND (p_receiver_task_id is not NULL) then
          x_bill_another_project_flag := 'Y';
      else
         x_bill_another_project_flag := 'N';
      end if;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    else
         --dbms_output.put_line('draft invoice exists ');

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_REC_PROJ_NOT_ALLOWED';
    END if;
   else


      if (p_receiver_task_id <> FND_API.G_MISS_NUM) AND (p_receiver_task_id is not NULL) then
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_error_msg_code := 'PA_REC_PROJ_NOT_ALLOWED';
      else
         x_bill_another_project_flag := 'N';
         x_return_status := FND_API.G_RET_STS_SUCCESS;
      end if;
   end if;
--dbms_output.put_line('Value of x_bill_another_project_flag'||x_bill_another_project_flag);
   close C1;
   close C2;
   close C3;
EXCEPTION
   when OTHERS then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      raise;
END CHECK_RECEIVER_PROJ_ENTERABLE;

END PA_CUSTOMER_INFO;

/
