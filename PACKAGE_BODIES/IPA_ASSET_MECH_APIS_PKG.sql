--------------------------------------------------------
--  DDL for Package Body IPA_ASSET_MECH_APIS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IPA_ASSET_MECH_APIS_PKG" AS
/* $Header: IPAAMAPB.pls 120.3 2006/02/14 16:56:58 dlanka noship $ */
/* Original Header: IPAFAXB.pls 41.8 98/02/06 17:01:21 porting ship  */
Procedure IPA_AUTO_ASSET_CREATION (
			  x_project_num_from        IN  VARCHAR2,
			  x_project_num_to          IN  VARCHAR2,
              		  x_pa_date                 IN  OUT NOCOPY DATE,
			  x_err_code                IN OUT NOCOPY varchar2,
			  x_err_stack               IN OUT NOCOPY varchar2,
			  x_err_stage               IN OUT NOCOPY varchar2,
                          x_conc_request_id         IN OUT NOCOPY NUMBER
			) IS

  l_exp_id number;

   -- End added cursor to update attributes 8,9 and 10 for invoice lines.
   -- CRL3.1  5/18/99


  CURSOR get_asset_naming_method IS
  SELECT asset_name ,
	 asset_description1,
	 asset_description2,
	 asset_description3,
	 asset_desc_separator,
	 asset_location,
	 asset_category
  FROM ipa_asset_naming_conventions;

  asset_naming_method_rec    get_asset_naming_method%rowtype;
   v_asset_name        varchar2(30);
   v_asset_description varchar2(80);
   v_row_id            varchar2(80);
   v_row_id2           varchar2(80);
   v_project_asset_id  number;
   v_rejection_code    varchar2(30);
   v_asset_location    varchar2(300);
   v_asset_category    varchar2(300);
   v_location_id       number;
   v_category_id       number;
   v_book_type_code    varchar2(15);
   v_dummy             varchar2(1);
   v_org_id            number;
   v_deprn_expense_ccid number;
   v_err_code           varchar2(640);
   v_err_stage          varchar2(640);
   v_err_stack          varchar2(640);
   v_accounting_flex_structure number;

--  Modified to pull crl inventory_item and serial_number too
--  for crl scm 3.1.  tls 5/9/99

  CURSOR get_expenditure_items IS
  SELECT pei.attribute8,
         pei.attribute9,
         pei.attribute10,
         pei.attribute6, --crl_inventory_item
         pei.attribute7, --crl_serial_number
         pt.task_name,
         pt.attribute10 task_attribute10,
         ppr.name project_name,
         pt.task_id,
         ppr.project_id,
         pei.expenditure_item_id
   FROM  pa_projects_all ppr, -- Changed to _all as part of MOAC changes.
	 pa_project_types ppt,
    --	 pa_cost_distribution_lines_all pcdl,
	 pa_expenditure_items_all pei,
	 pa_tasks pt,
       pa_tasks pt2
   WHERE ppr.segment1 between x_project_num_from and x_project_num_to and
         ppr.template_flag <> 'Y' and
         ppr.project_status_code <> 'CLOSED' and
         ppr.project_type = ppt.project_type and
         ppt.cip_grouping_method_code = 'CIPGCE' and
	 --nvl(ppt.attribute10,'N') = 'Y' and
         ppt.project_type_class_code = 'CAPITAL' and
         nvl(ppr.attribute10,'Y') ='Y' and
         nvl(pt2.attribute9,'Y') ='Y' and
         ppt.interface_asset_cost_code = 'F'
   AND   pt.project_id = ppr.project_id
   AND   ppt.org_id = ppr.org_id -- Fix for bug : 4969694
   --AND pcdl.expenditure_item_id = pei.expenditure_item_id
   --  dcharlto 4/21/99 crl3.1
   AND decode(IPA_ASSET_MECH_APIS_PKG.g_nl_installed,'Y',pei.expenditure_item_id,-99) = decode(IPA_ASSET_MECH_APIS_PKG.g_nl_installed,'Y',nvl(IPA_ASSET_MECH_APIS_PKG.g_expenditure_item_id,pei.expenditure_item_id), -99)
   --  dcharlto 4/21/99 crl3.1
   --AND decode(nvl(IPA_ASSET_MECH_APIS_PKG.g_nl_installed,'N'),'Y','N',pei.revenue_distributed_flag) = 'N'
   --AND pei.revenue_distributed_flag||'' = 'N'
   --AND   pcdl.line_type = DECODE(ppt.capital_cost_type_code,'R','R','B','D','R')
   --AND   pcdl.billable_flag = 'Y'
   AND   pei.billable_flag = 'Y'
   --AND   pcdl.pa_date  <= x_pa_date
   AND   pei.expenditure_item_date  <= x_pa_date
   AND   pei.task_id = pt.task_id
   AND   nvl(pei.CRL_ASSET_CREATION_STATUS_CODE,'N') <>'Y'
   AND   pt.top_task_id = pt2.task_id
   AND   ((pei.attribute8 is not null) OR (pei.attribute9 is not null)
          OR (pei.attribute10 is not null) )
   /* Added for Bug 3574567 */
   AND   (pei.revenue_distributed_flag = 'N' OR
          (pei.revenue_distributed_flag = 'Y'
          AND   NOT EXISTS (SELECT 'This CDL was summarized before'
                            FROM   pa_project_asset_line_details pald,
                                   pa_project_asset_lines pal
                            WHERE  pald.expenditure_item_id = pei.expenditure_item_id
                            AND    pald.project_asset_line_detail_id = pal.project_asset_line_detail_id
                            AND    pal.project_asset_id >= 1)
          )
         )
   for update of CRL_ASSET_CREATION_STATUS_CODE NOWAIT;

--  Modified to check crl inventory_item and serial_number too
--  for crl scm 3.1.  tls 5/9/99

   cursor check_asset_existence (c_project_id in number,
                           c_task_id in number,
                           c_attribute8 in varchar2,
                           c_attribute9 in varchar2,
                           c_attribute10 in varchar2,
                           c_attribute6 in varchar2, --crl_inventory_item
                           c_attribute7 in varchar2 --crl_serial_number
			) IS
   select 'X'
   FROM pa_project_asset_assignments ppaa
   WHERE ppaa.task_id = c_task_id
   AND   ppaa.project_id = c_project_id
   AND   nvl(ppaa.attribute8,'~!@#') = nvl(c_attribute8, '~!@#')
   AND   nvl(ppaa.attribute9,'~!@#') = nvl(c_attribute9, '~!@#')
   AND   nvl(ppaa.attribute10,'~!@#') = nvl(c_attribute10, '~!@#')
   /* Start Bug fix:2956569 : attribute6,7 Should be validated only when the nl_installed flag = Y*/
   AND  ( (NVL(IPA_ASSET_MECH_APIS_PKG.g_nl_installed,'N') = 'Y'
           AND   nvl(ppaa.attribute6,'~!@#') = nvl(c_attribute6, '~!@#') --crl_inventory
           AND   nvl(ppaa.attribute7,'~!@#') = nvl(c_attribute7, '~!@#') --serial_number
	  )
         OR
          NVL(IPA_ASSET_MECH_APIS_PKG.g_nl_installed,'N') = 'N'
	);
   /* End Bug fix:2956569 */


   /* Bug#3043050. Added decode for attributes 6 and 7 based on NL Installed flag */
   cursor get_asset_description(task_name in varchar2,
                                project_name in varchar2,
                                attribute8 in varchar2,
                                attribute9 in varchar2,
                                attribute10 in varchar2,
                                attribute6 in varchar2, -- inventory_item
                                attribute7 in varchar2) IS --serial_number
   select substr(decode(asset_naming_method_rec.asset_description1,
                 'ADT',task_name,
		 'ADP',project_name,
		 'ADGE1',attribute8,
		 'ADGE2',attribute9,
		 'ADGE3',attribute10)
		 ||decode(asset_naming_method_rec.asset_description2,'None',null,asset_naming_method_rec.asset_desc_separator)||
	  decode(asset_naming_method_rec.asset_description2,
                 'ADT',task_name,
		 'ADP',project_name,
		 'ADGE1',attribute8,
		 'ADGE2',attribute9,
		 'ADGE3',attribute10)
		 ||decode(asset_naming_method_rec.asset_description3,'None',null,asset_naming_method_rec.asset_desc_separator)||
	  decode(asset_naming_method_rec.asset_description3,
                 'ADT',task_name,
		 'ADP',project_name,
		 'ADGE1',attribute8,
		 'ADGE2',attribute9,
		 'ADGE3',attribute10)||
          decode(nvl(IPA_ASSET_MECH_APIS_PKG.g_nl_installed, 'N'), 'Y',
               decode(attribute6,null,null,
               asset_naming_method_rec.asset_desc_separator||
                 attribute6||                --Inventory_item
                decode(attribute7,null,null,
                   asset_naming_method_rec.asset_desc_separator||
                     attribute7)), null),1,80)
        asset_description
    from dual;

   cursor get_asset_category_id is
   select category_id
   from fa_categories
   where upper(segment1||segment2||segment3||segment4||segment5||segment6||segment7) = upper(v_asset_category);

   cursor get_asset_location_id is
   select location_id
   from fa_locations
   where upper(segment1||segment2||segment3||segment4||segment5||segment6||segment7) = upper(v_asset_location);

   cursor get_book_type IS
   select bc.book_type_code
   from fa_book_controls bc, fa_category_books cb, pa_implementations pi
   where cb.category_id = v_category_id
   and cb.book_type_code = bc.book_type_code
   and bc.book_class = 'CORPORATE'
   and pi.set_of_books_id = bc.set_of_books_id;

   cursor get_book_info is
    Select accounting_flex_structure
    from fa_book_controls
    where book_type_code = v_book_type_code;
  Begin
   -- added more staging code messages tls crl3.1

   x_err_code := '0';
   x_conc_request_id := x_request_id;

   -- Added to update attributes 8,9 and 10 for invoice lines.
   -- CRL3.1  5/18/99
  /************************** client Extension is being used ***************
  if nvl(fnd_profile.value('CRL: COPY GROUPING ELEMENT INFORMATION'),'N') = 'Y' then
   open get_invoice_8910;
   fetch get_invoice_8910 into l_exp_id;
   while get_invoice_8910%found loop
        update pa_expenditure_items_all pei
        set   (attribute8, attribute9, attribute10) =
              (select aid.attribute8,aid.attribute9, aid.attribute10
               from ap_invoice_distributions aid,
                    pa_cost_distribution_lines_all pcd
               where pei.expenditure_item_id = pcd.expenditure_item_id
               and   pcd.system_reference2 = aid.invoice_id
               and   pcd.system_reference3 = aid.distribution_line_number
               and   pcd.transfer_status_code = 'V')
        where pei.expenditure_item_id = l_exp_id;

        fetch get_invoice_8910 into l_exp_id;
    end loop;
    close get_invoice_8910;
  end if;

   -- End added to update attributes 8,9 and 10 for invoice lines.
   -- CRL3.1  5/18/99
 ***********************************************/
    x_err_stage := 'ipa_get_org';

    select org_id
    into v_org_id
    from pa_implementations;

    x_err_stage := 'ipa_get_name_method';

    open get_asset_naming_method;
    fetch get_asset_naming_method into
      asset_naming_method_rec.asset_name ,
      asset_naming_method_rec.asset_description1,
      asset_naming_method_rec.asset_description2,
      asset_naming_method_rec.asset_description3,
      asset_naming_method_rec.asset_desc_separator,
      asset_naming_method_rec.asset_location,
      asset_naming_method_rec.asset_category ;
    if get_asset_naming_method%notfound then
      x_err_code := '10';
      return;
    end if;
    close get_asset_naming_method;

    x_err_stage := 'ipa_get_expenditure';

    for ei_rec in get_expenditure_items loop
       v_asset_name        := null;
       v_asset_description := null;
       v_row_id            := null;
       v_project_asset_id  := null;
       v_rejection_code    := null;
       v_asset_location    := null;
       v_asset_category    := null;
       v_location_id       := null;
       v_category_id       := null;

     x_err_stage := 'ipa_chk_asset_exist';

--  Modified call to pass crl inventory_item and serial_number
--  for crl scm 3.1.  tls 5/9/99

      open check_asset_existence(ei_rec.project_id,
                                 ei_rec.task_id,
                                 ei_rec.attribute8,
                                 ei_rec.attribute9,
                                 ei_rec.attribute10,
                                 ei_rec.attribute6, --crl_inventory_item
                                 ei_rec.attribute7); --crl_serial_number
      fetch check_asset_existence into v_dummy;
      if check_asset_existence%found then
        close check_asset_existence;
        goto  next_row;
      end if;
      close check_asset_existence;

     x_err_stage := 'ipa_get_asset_name';

  -- Asset Name
      if asset_naming_method_rec.asset_name = 'ANT' then
       v_asset_name := ei_rec.task_name;
      elsif asset_naming_method_rec.asset_name = 'ANP' then
       v_asset_name := ei_rec.project_name;
      elsif asset_naming_method_rec.asset_name = 'ANGE1' then
       v_asset_name := ei_rec.attribute8;
      elsif asset_naming_method_rec.asset_name = 'ANGE2' then
       v_asset_name := ei_rec.attribute9;
      elsif asset_naming_method_rec.asset_name = 'ANGE3' then
       v_asset_name := ei_rec.attribute10;
      end if;

     x_err_stage := 'ipa_get_asset_desc';

--  Modified call to pass crl inventory_item and serial_number
--  for crl scm 3.1.  tls 5/9/99

-- Asset Description
      open get_asset_description(ei_rec.task_name,
                                 ei_rec.project_name,
                                 ei_rec.attribute8,
                                 ei_rec.attribute9,
                                 ei_rec.attribute10,
                                 ei_rec.attribute6, --crl_inventory_item
                                 ei_rec.attribute7); --crl_serial_number
      fetch get_asset_description into v_asset_description;
      close get_asset_description;

     x_err_stage := 'ipa_get_asset_loc';

-- Asset Location
      if asset_naming_method_rec.asset_location = 'ALGE1' then
       v_asset_location := ei_rec.attribute8;
      elsif asset_naming_method_rec.asset_location = 'ALGE2' then
       v_asset_location := ei_rec.attribute9;
      elsif asset_naming_method_rec.asset_location = 'ALGE3' then
       v_asset_location := ei_rec.attribute10;
      end if;

      open get_asset_location_id;
      fetch get_asset_location_id into v_location_id;
      if (get_asset_location_id%notfound) OR (v_asset_location is null) then
        v_rejection_code := 'ASSET_LOC_NOTFOUND';
        close get_asset_location_id;
        goto next_row;
      end if;
      close get_asset_location_id;

     x_err_stage := 'ipa_get_asset_cat';

-- Asset Category
      if asset_naming_method_rec.asset_category = 'ACT' then
       v_asset_category := ei_rec.task_name;
      elsif asset_naming_method_rec.asset_category = 'ACDF' then
       v_asset_category := ei_rec.task_attribute10;
      elsif asset_naming_method_rec.asset_category = 'ACGE1' then
       v_asset_category := ei_rec.attribute8;
      elsif asset_naming_method_rec.asset_category = 'ACGE2' then
       v_asset_category := ei_rec.attribute9;
      elsif asset_naming_method_rec.asset_category = 'ACGE3' then
       v_asset_category := ei_rec.attribute10;
      end if;

      open get_asset_category_id;
      fetch get_asset_category_id into v_category_id;
      if (get_asset_category_id%notfound) OR (v_asset_category is null)then
        v_rejection_code := 'ASSET_CAT_NOTFOUND';
        close get_asset_category_id;
        goto next_row;
      end if;
      close get_asset_category_id;

     x_err_stage := 'ipa_get_book_type';

--Book Type Code

      --Bug 3068204
      --Get Book_Type_Code from Pa_Implementations, If NULL then derive from FA.

      Select Book_Type_Code
      Into   V_Book_Type_Code
      From   Pa_Implementations;

      --Bug 3068204
      If V_Book_Type_Code is NULL Then
         open get_book_type;
         fetch get_book_type into v_book_type_code;
         close get_book_type;
      End If;

--Deprn CCID
      x_err_stage := 'Get Depreciation Expense Account';
      v_err_code := '0';
      v_deprn_expense_ccid := -1;
      ipa_client_Extension_pkg.get_default_deprn_expense(v_book_type_code,
                                     v_category_id,
                                     v_location_id ,
                                     ei_rec.expenditure_item_id ,
                                     v_deprn_expense_ccid,
                                     v_err_stack ,
                                     v_err_stage ,
                                     v_err_code);

      if v_err_code <> '0' then
        v_rejection_code := substr(v_err_code,1,30);
        goto next_row;
      end if;

     if(nvl(v_deprn_expense_ccid,0) > 0 ) then  /* Added for Bug#3571657 */
      open get_book_info;
      fetch get_book_info into v_accounting_flex_structure;
      close get_book_info;

      if not(FND_FLEX_KEYVAL.validate_ccid(
                        appl_short_name    =>'SQLGL',
                        key_flex_code           =>'GL#',
                        structure_number        =>v_accounting_flex_structure,
                        combination_id          => v_deprn_expense_ccid,
                        vrule =>'GL_ACCOUNT\\nGL_ACCOUNT_TYPE\\nI\\n' ||
                                'APPL=''OFA'';NAME=FA_SHARED_NOT_EXPENSE_ACCOUNT\\nE' ||
                                '\\0GL_GLOBAL\\nDETAIL_POSTING_ALLOWED\\nI\\n' ||
                                'APPL=''SQLGL'';NAME=GL Detail Posting Not Allowed\\nY' ||
                                '\\0\\nSUMMARY_FLAG\\nI\\n' ||
                                'APPL=''SQLGL'';NAME=GL summary credit debit\\nN'
                                        )) then
          v_rejection_code := 'IFA_INVALID_DEPR_CCID';
          goto next_row;
       end if;
      end if;   /* v_deprn_expense_ccid check - Added for Bug#3571657 */

       x_err_stage := 'Inserting Into PA_PROJECT_ASSETS_ALL';

      PA_PROJECT_ASSETS_PKG.Insert_Row(
          X_Rowid                       =>v_Row_id
         ,X_Project_Asset_Id            =>v_Project_Asset_ID
         ,X_Project_Id                  =>ei_rec.Project_Id
         ,X_Asset_Number                =>null
         ,X_Asset_Name                  =>'X'
         ,X_Asset_Description           =>v_Asset_Description
         ,X_Location_Id                 =>v_location_id
         ,X_Assigned_To_Person_Id       =>null
         ,X_Date_Placed_In_Service      =>null
         ,X_Asset_Category_Id           =>v_category_id
         ,X_Asset_key_ccid              => null --Added for 11i
         ,X_Book_Type_Code              =>v_book_type_code
         -- dcharlto
         ,X_Asset_Units            =>nvl(IPA_ASSET_MECH_APIS_PKG.g_number_of_units,1)
         -- dcharlto
         ,X_Depreciate_Flag             =>'Y'
         ,X_Amortize_Flag               =>'N'
         ,X_Cost_Adjustment_Flag        => 'N'
         ,X_Reverse_Flag                => 'N'
         ,X_Depreciation_Expense_Ccid   =>v_deprn_expense_ccid
         ,X_Capitalized_Flag            =>'N'
         ,X_Estimated_In_Service_Date   =>to_date(null)
         ,X_Capitalized_Cost            =>0
         ,X_Grouped_CIP_Cost            =>0
         ,X_Last_Update_Date            =>sysdate
         ,X_Last_Updated_By             =>X_Last_Updated_By
         ,X_Creation_Date               =>sysdate
         ,X_Created_By                  =>X_Created_By
         ,X_Last_Update_Login           =>X_Last_Update_Login
         ,X_Attribute_Category          =>null
         ,X_Attribute1                  =>null
         ,X_Attribute2                  =>null
         ,X_Attribute3          =>null
         ,X_Attribute4          =>null
         ,X_Attribute5          =>null
         ,X_Attribute6          =>null
         ,X_Attribute7          =>null
         ,X_Attribute8          =>ei_rec.attribute8
         ,X_Attribute9          =>ei_rec.attribute9
         ,X_Attribute10         =>ei_rec.attribute10
         ,X_Attribute11         =>null
         ,X_Attribute12         =>null
         ,X_Attribute13         =>null
         ,X_Attribute14         =>null
         ,X_Attribute15         =>null
         --Bug 3068204, added the new parameters included in PA.L
         , X_Project_Asset_Type =>'ESTIMATED'
         , X_Estimated_Units    =>1
         , X_Parent_Asset_Id    =>null
         , X_Estimated_Cost     =>null
         , X_Manufacturer_Name  =>null
         , X_Model_Number       =>null
         , X_Serial_Number      =>null
         , X_Tag_Number         =>null
         , X_Capital_Hold_Flag  =>'N'
         , X_Ret_Target_Asset_Id =>null
         , X_ORG_ID => v_org_id -- MOAC changes
         );

          x_err_stage := 'Updating PA_PROJECT_ASSETS_ALL';
          update pa_project_assets
          set asset_name = substr(v_asset_name,1,30-length(asset_naming_method_rec.asset_desc_separator||to_char(v_project_asset_id)))
                              ||asset_naming_method_rec.asset_desc_separator||to_char(v_project_asset_id),
          org_id = v_org_id,
          request_id = x_request_id,
	  program_application_id = x_program_application_id,
	  program_id = x_program_id,
	  program_update_date = sysdate
          where rowid = v_row_id;

      x_err_stage := 'Inserting Into PA_PROJECT_ASSETS_ASSIGNMENTS';
      PA_PROJ_ASSET_ASSIGN_PKG.insert_row(X_Rowid =>v_row_id2
                      ,X_Project_Asset_Id  =>v_project_asset_id
                      ,X_Task_Id           => ei_rec.task_id
                      ,X_Project_Id        => ei_rec.project_id
		      ,X_Last_Update_Date  =>sysdate
		      ,X_Last_Updated_By   =>x_Last_Updated_By
		      ,X_Creation_Date     =>sysdate
		      ,X_Created_By        =>x_Created_By
		      ,X_Last_Update_Login =>x_Last_Update_Login);

      --  Added crl inventory_item and serial_number to assignment
      --  for crl scm 3.1 modification that an item must be its own
      --  asset.  tls  5/9/99

      /* Bug#3043050. Added decode for attributes 6 and 7 based on NL Installed flag */
      x_err_stage := 'Updating PA_PROJECT_ASSETS_ASSIGNMENTS';
      update pa_project_asset_assignments
      set   attribute8 = ei_rec.attribute8
           ,attribute9 = ei_rec.attribute9
           ,attribute10 = ei_rec.attribute10
           ,attribute6 = decode(nvl(IPA_ASSET_MECH_APIS_PKG.g_nl_installed, 'N'), 'Y',
                                ei_rec.attribute6, attribute6) --crl_inventory_item
           ,attribute7 = decode(nvl(IPA_ASSET_MECH_APIS_PKG.g_nl_installed, 'N'), 'Y',
                                ei_rec.attribute7, attribute7) --crl_serial_number
      where rowid = v_row_id2;


 <<next_row>>
  x_err_stage := 'Updating PA_EXPENDITURE_ITEMS_ALL';
  update pa_expenditure_items_all
  set crl_asset_creation_rej_code = v_rejection_code,
      crl_asset_creation_status_code = decode(v_rejection_code,null,'Y','R') ,
      request_id = x_request_id,
      program_application_id = x_program_application_id,
      program_id = x_program_id,
      program_update_date = sysdate,
      last_update_date = sysdate,
      last_updated_by = x_last_updated_by,
      last_update_login = x_last_update_login
  where current of get_expenditure_items;

end loop;

EXCEPTION
  WHEN OTHERS THEN
    x_err_code := (SQLCODE);
    ROLLBACK WORK;
End;

Function check_auto_asset  (x_project_id in number,
                            x_task_id in number) return boolean IS

  cursor check_auto_asset is
  select 'X'
  from pa_tasks pt,
       pa_tasks pt2,
       pa_project_types ppt,
       pa_projects_all pp -- Changed to _ALL as part of MOAC changes
  where pp.project_type = ppt.project_type
  and   ppt.cip_grouping_method_code = 'CIPGCE'
  --and   nvl(ppt.attribute10,'N') = 'Y'
  and   pp.project_id = x_project_id
  and   pt.task_id= x_task_id
  and   pt.project_id = x_project_id
  and   pt2.task_id = pt.top_task_id
  and   nvl(pp.attribute10,'Y') = 'Y'
  and   nvl(pt2.attribute9,'Y') = 'Y';
  v_dummy     varchar2(1);

  Begin

    open check_auto_asset ;
    fetch check_auto_asset into v_dummy;
    if check_auto_asset%found then
      return true;
    else
      return false;
    end if;
    close check_auto_asset ;

 End;

END IPA_ASSET_MECH_APIS_PKG;

/
