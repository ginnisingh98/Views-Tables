--------------------------------------------------------
--  DDL for Package Body GMS_RES_MAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMS_RES_MAP" AS
-- $Header: gmsfcrmb.pls 120.2 2006/02/22 21:51:23 rshaik ship $

/*  -----------------------------------------------------------------------
||  ************** NEW CODE FOR RESOURCE MAPPING STARTS HERE **************
    ---------------------------------------------------------------------- */

-- ## This procedure is used to derive : Group Level Unclassified RLMI

Procedure get_grp_unclassified(p_resource_list_id in number,
                               p_resource_list_member_id out NOCOPY number,
			       p_error_code  out NOCOPY number,
			       p_error_buff out NOCOPY varchar2)
is

Begin

         select a.resource_list_member_id
           into p_resource_list_member_id
           from pa_resource_list_members a,
                pa_resources b,
                pa_resource_types c
         where  c.resource_type_code = 'UNCLASSIFIED'
           and  b.resource_type_id = c.resource_type_id
           and  a.resource_id = b.resource_id
           and  a.resource_list_id = p_resource_list_id
           and  a.parent_member_id is null
           and  a.enabled_flag='Y'
	   and  NVL(a.migration_code,'M') ='M'; --Bug 3626671

Exception

   When others then

    p_resource_list_member_id := null;

End get_grp_unclassified;


/* ---------------------------------------------------------------------------
||  Procedure "get_parent_rlmi" is used to derive : RLMI of the Resource Group
||  Resource Group could be :
||  1. Expenditure Category
||  2. Revenue Category
||  3. Organization
   --------------------------------------------------------------------------- */

Procedure get_parent_rlmi(p_group_resource_type_id in number,
			  p_name		   in varchar2,
			  p_resource_list_id	   in number,
			  p_parent_rlmi		   out NOCOPY number,
			  p_error_code 		   out NOCOPY number,
			  p_error_buff		   out NOCOPY varchar2)
is
Begin

          Select  prlm.resource_list_member_id
          into  p_parent_rlmi
          from  pa_resource_list_members prlm,
                pa_resources pr
         where  pr.resource_type_id = p_group_resource_type_id
           and  pr.name = p_name
           and  prlm.resource_id = pr.resource_id
           and  prlm.resource_list_id = p_resource_list_id
           and  prlm.enabled_flag='Y'
	   and  NVL(prlm.migration_code,'M') ='M'; --Bug 3626671

Exception

    When no_data_found then

         p_parent_rlmi := -1;

    When Others then

           p_parent_rlmi := -1;

End get_parent_rlmi;


/* -----------------------------------------------------------------------------------
||  Procedure "MAP_RESOURCES" is the main API to derive RLMI
||  Parameters:
||  A. IN Parameters:
||     ==============
||  1. x_document_type - Document Type : EXP,ENC,AP,PO,REQ,EVT(Event), MANDATORY VALUE
||  2. x_document_header_id - Document Header Id (e.g: Expenditure_item_id for EXP/ENC)
||  3. x_document_distribution_id - Document Distribution Id (relevant for AP/PO/REQ)
||  4. x_expenditure_type - Expenditure Type
||  5. x_expenditure_org_id - Organization Id
||  6. x_categorization_code - Categorization Code : Values 'R' or 'N'
||  7. x_resource_list_id - Resource List Id
||  8. x_event_type - Event Type
||
||  B. IN OUT NOCOPY Parameters:
||  =====================
||  These IN/OUT parameters are helpful in batch mode(i.e. when Resource mapping API
||  is being called in a loop. API passes the next four values. For the subsequent
||  transactions, API will check if  x_prev_list_processed (resource list for previous
||  transaction) same as for current, if so it does not derive the next 3 IN/OUT parameter
||  values.
|| %%% WARNING %%% :
|| =================
||  Programmers using this API should not initialize the values of these
||  IN/OUT parameters within the loop.
||  1. x_prev_list_processed - Resource List Id of the previous transaction
||  2. x_group_resource_type_id - Group Resource Id for the resource list
||     This has a value of zero, if resource list not grouped.
||  3. x_group_resource_type_name - Group Resource name for the resource list
||  4. resource_type_tab - This pl/sql table stores the different resource types
||     in a resource list. Define plsql table resource_type_tab of type
||     "gms_res_map.resource_type_table"
||  C. OUT NOCOPY Parameters:
||  ==================
||  1. x_resource_list_member_id - Derived RLMI
||  2. x_error_code - Has a value other than zero in case of exception
||  3. x_error_buff - Has a value  in case of exception
||
||  K.Biju .. Dated 27-MAR-2001
   ----------------------------------------------------------------------------------- */

Procedure map_resources(x_document_type              IN varchar2,
                        x_document_header_id         IN number default NULL,
                        x_document_distribution_id   IN number default NULL,
                        x_expenditure_type           IN varchar2 default NULL,
                        x_expenditure_org_id         IN number default NULL,
                        x_categorization_code        IN varchar2 default NULL,
                        x_resource_list_id           IN number default NULL,
                        x_event_type                 IN varchar2 default NULL,
                        x_prev_list_processed        IN OUT NOCOPY number,
                        x_group_resource_type_id     IN OUT NOCOPY number,
                        x_group_resource_type_name   IN OUT NOCOPY varchar2,
                        resource_type_tab            IN OUT NOCOPY gms_res_map.resource_type_table,
                        x_resource_list_member_id    OUT NOCOPY number,
                        x_error_code                 OUT NOCOPY number,
                        x_error_buff                 OUT NOCOPY varchar2)
IS

l_stage                     varchar2(50);
l_count                     number(2) := 0;
l_rowcount                  number(2) := 0;
l_vendor_id                 number(30);
l_resource_type             varchar2(100);
l_expenditure_type          varchar2(100);
l_expenditure_category_tmp  varchar2(100);
l_revenue_category_tmp      varchar2(100);
l_expenditure_category      varchar2(100);
l_revenue_category          varchar2(100);
--l_organization_name         varchar2(100);
--The width of the variable is changed for UTF8 changes for HRMS schema. Refer bug 2302839.
l_organization_name         HR_ALL_ORGANIZATION_UNITS_TL.NAME%TYPE;
l_person_name               varchar2(100);
l_job_title                 varchar2(100);
-- The length of l_vendor_name has been changed for utf8 changes for AP schema. Refer bug 2614745.
--l_vendor_name               varchar2(100);
l_vendor_name  PO_VENDORS.VENDOR_NAME%TYPE;
l_event_type                varchar2(100);
l_parent_rlmi               number(30);

-- ## Following Cursor pulls up all the resource types for that resource list
-- This cursor has been modified as part of Bug reference : 3631208

Cursor get_resource_types is
select distinct c.resource_type_code resource_type_code
from  pa_resource_list_members c
where  c.resource_list_id = x_resource_list_id
and    ((x_group_resource_type_id <> 0 and c.parent_member_id is not null)
        or
        (x_group_resource_type_id = 0 and c.parent_member_id is null)
      )
and    c.enabled_flag='Y'
and    c.resource_type_code <> 'UNCLASSIFIED'
and    NVL(c.migration_code,'M') ='M';

/* -------------------------------- Bug reference : 3631208 -------------------+
-- Cursor modified as above
select distinct a.resource_type_code resource_type_code
from   pa_resource_types a,
       pa_resources b,
       pa_resource_list_members c
where  c.resource_list_id = x_resource_list_id
and    b.resource_id = c.resource_id
and    a.resource_type_id = b.resource_type_id
and    ((x_group_resource_type_id <> 0 and c.parent_member_id is not null)
        or
        (x_group_resource_type_id = 0 and c.parent_member_id is null)
       )
and    c.enabled_flag='Y'
and    a.resource_type_code <> 'UNCLASSIFIED'
and    NVL(c.migration_code,'M') ='M'; --Bug 3626671

-- ## Following Cursor pulls up all resource list members, records are sorted
-- ##  so that we get RLMI for the most granular resource
 -- This cursor changed to select statement .. Bug reference : 3631208
Cursor get_rlmis_unclass is
select c.resource_list_member_id,
       b.name,
       a.resource_type_code,
       b.resource_type_id,
       c.parent_member_id
from   pa_resource_types a,
       pa_resources b,
       pa_resource_list_members c
where  c.resource_list_id = x_resource_list_id
and    b.resource_id = c.resource_id
and    a.resource_type_id = b.resource_type_id
and    c.enabled_flag='Y'
and    a.resource_type_code='UNCLASSIFIED'
and    NVL(c.migration_code,'M') ='M'; --Bug 3626671
*/

Cursor get_rlmis_class(p_resource_type_code in varchar2, p_name in varchar2) is
select c.resource_list_member_id,
       b.name,
       a.resource_type_code,
       b.resource_type_id,
       c.parent_member_id
from   pa_resource_types a,
       pa_resources b,
       pa_resource_list_members c
where  c.resource_list_id = x_resource_list_id
and    b.resource_id = c.resource_id
and    a.resource_type_id = b.resource_type_id
and    c.enabled_flag='Y'
and    a.resource_type_code=p_resource_type_code
and    b.name = p_name
and    NVL(c.migration_code,'M') ='M'; -- Bug 3626671

TYPE rlmi_record is RECORD(resource_list_member_id NUMBER(15),
                           name                    VARCHAR2(100),
                           resource_type_code      VARCHAR2(30),
                           resource_type_id        NUMBER(15),
                           parent_member_id        NUMBER(15));

TYPE rlmi_table is TABLE of rlmi_record index by binary_integer;

rlmi_tab rlmi_table;

Begin
x_error_code := 0;
l_stage := 'Starting Resource mapping';

-- dbms_output.put_line('In Mapping');
-- ## DO NOT DELETE THE dbms_output lines from the code
-- ## This has been introduced for debugging purpose only
-- ## The checked in version of the file should have all dbms lines commented..

If x_categorization_code <> 'R' then

   l_stage := 'Deriving Uncategorized RLMI';
   -- dbms_output.put_line('In Mapping UnCategorized');

   select resource_list_member_id
   into   x_resource_list_member_id
   from   pa_resource_list_members
   where  resource_list_id = x_resource_list_id
   and    NVL(migration_code,'M') ='M'; -- Bug 3626671

   x_prev_list_processed := x_resource_list_id;
   RETURN;

 Else -- For Budget by resources

   l_stage := 'Deriving Categorized RLMI';
   --dbms_output.put_line('In Mapping Categorized');

   If (nvl(x_prev_list_processed,-1) <>  x_resource_list_id) then

   --dbms_output.put_line('In Mapping Categorized-New');

         l_stage := 'Delete resource type Table';

      -- ##Clean up resource type table, initialize variables
      resource_type_tab.delete;
      x_group_resource_type_id := null;
      x_group_resource_type_name := null;

      l_stage := 'Get Grouping Info';

      -- # Check whether resource list is grouped
      -- # if list not grouped then Zero (0) is the value for group_resource_type_id
       select prl.group_resource_type_id
         into x_group_resource_type_id
         from pa_resource_lists prl
        where prl.resource_list_id = x_resource_list_id ;

       If x_group_resource_type_id <> 0 then

         select prt.resource_type_code
           into x_group_resource_type_name
           from pa_resource_types prt
          where prt.resource_type_id = x_group_resource_type_id;

       End if;

      -- ## Recreate resource type table with resource types for resource list being processed

      l_stage := 'Recreate resource type Table';

      for records in get_resource_types
      loop

            l_count := l_count + 1;
            resource_type_tab(l_count) := records.resource_type_code;

      end loop;


      x_prev_list_processed :=  x_resource_list_id ;

   End if; -- If x_prev_list_processed <>  x_resource_list_id


/* --------------------------------------------------------------------------
|| Following piece of code derives all the values necessary for
|| carrying out NOCOPY resource mapping
   -------------------------------------------------------------------------- */

       l_stage := 'Deriving values';

       l_rowcount := resource_type_tab.COUNT;

       --dbms_output.put_line('l_rowcount:'||l_rowcount);

       for i in 1..l_rowcount
       loop

           l_resource_type := resource_type_tab(i);

           if  (l_resource_type = 'EXPENDITURE_TYPE')  then

                l_stage := 'Deriving values : EXP TYPE';

                l_expenditure_type := x_expenditure_type;

           elsif  (l_resource_type = 'EXPENDITURE_CATEGORY' or l_resource_type = 'REVENUE_CATEGORY') then

                   l_stage := 'Deriving values : EXP/REV CAT';

                   -- ## NOTE: exp category and rev cateogry are being derived at one shot
                   -- ## so that we do not have query pa_expenditure_types again

                   If  x_expenditure_type is not null then

                   Select expenditure_category,
                          revenue_category_code
                     into l_expenditure_category,
                          l_revenue_category
                     from pa_expenditure_types
                    where expenditure_type = x_expenditure_type;

                    End if;

           elsif  (l_resource_type = 'ORGANIZATION') then

                   l_stage := 'Deriving values : ORG';
		-- -----------
		-- BUG 1773952
		-- -----------
		BEGIN

                   Select  name
                   into    l_organization_name
                   from    hr_all_organization_units -- Bug 4732065
                   where   organization_id = x_expenditure_org_id;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				NULL;
		END;

           elsif  (l_resource_type = 'EMPLOYEE') then

                   If x_document_type = 'EXP' then

                       l_stage := 'Deriving values : PERSON FOR EXP';

			-- -----------
			-- BUG 1773952
			-- -----------
			BEGIN

                       		select substrb(papf.full_name,1,100)
                       		into   l_person_name
                       		from   per_all_people_f papf,
                              		pa_expenditure_items_all peia,
                              		pa_expenditures_all pea
                       		where  peia.expenditure_item_id = x_document_header_id
                       		and    pea.expenditure_id = peia.expenditure_id
                       		and    papf.person_id = pea.incurred_by_person_id
                       		and    trunc(peia.expenditure_item_date) between trunc(papf.effective_start_date) and trunc(nvl(effective_end_Date,sysdate));
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;
			END;

                   Elsif  x_document_type = 'ENC' then

                       l_stage := 'Deriving values : PERSON FOR ENC';
			-- -----------
			-- BUG  2069108
			-- -----------
			BEGIN

                       		select substrb(papf.full_name,1,100)
                       		into   l_person_name
                       		from   per_all_people_f papf,
                              		gms_encumbrance_items_all geia,
                              		gms_encumbrances_all gea
                       		where  geia.encumbrance_item_id = x_document_header_id
                       		and    gea.encumbrance_id = geia.encumbrance_id
                       		and    papf.person_id = gea.incurred_by_person_id
                       		and    trunc(geia.encumbrance_item_date) between trunc(papf.effective_start_date) and trunc(nvl(effective_end_Date,sysdate));
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;
			END;


                   End if;

           elsif  (l_resource_type = 'JOB') then

                   If x_document_type = 'EXP' then

                       l_stage := 'Deriving values : JOB FOR EXP';

			-- -----------
			-- BUG 1773952
			-- -----------
			BEGIN

                       		select substrb(pj.name,1,100)
                       		into   l_job_title
                       		from   per_jobs pj,
                              		pa_expenditure_items_all peia
                       		where  peia.expenditure_item_id = x_document_header_id
                       		and    pj.job_id = peia.job_id;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;
			END;
                   Elsif  x_document_type = 'ENC' then

                       l_stage := 'Deriving values : JOB FOR ENC';

			-- -----------
			-- BUG 2069108
			-- -----------
			BEGIN

                       		select substrb(pj.name,1,100)
                       		into   l_job_title
                       		from   per_jobs pj,
                              		gms_encumbrance_items_all geia
                       		where  geia.encumbrance_item_id = x_document_header_id
                       		and    pj.job_id = geia.job_id;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;
			END;


                   End if;

           elsif  (l_resource_type = 'VENDOR') then

                   l_stage := 'Deriving values : VENDOR ID';

		-- -----------
		-- BUG 1773952
		-- -----------
                 Begin

                   If (x_document_type = 'REQ') then


                       select DISTINCT line.vendor_id
                         into l_vendor_id
                         from po_requisition_lines line,
                              po_requisition_headers_all req
                        where req.requisition_header_id = x_document_header_id
                          and line.requisition_header_id = req.requisition_header_id;


                   Elsif (x_document_type = 'PO') then

                       select head.vendor_id
                         into l_vendor_id
                         from po_headers_all head
                        where head.po_header_id = x_document_header_id;

                   Elsif (x_document_type = 'AP') then

                       select head.vendor_id
                         into l_vendor_id
                         from ap_invoices_all head
                        where head.invoice_id = x_document_header_id;

		   Elsif (x_document_type = 'EXP') then

                        -- ------------------------------------------------------------------
                        -- Bug 2200161. Included the following to calculate vendor_id for EXP
                        -- if it is transferred from AP. This enables the resource map API
                        -- to map the correct resource_list_member_id
                        -- ------------------------------------------------------------------


                        select system_reference1
                          into l_vendor_id
                          from  pa_cost_distribution_lines_all
                         where expenditure_item_id = x_document_header_id
                          and  line_num = x_document_distribution_id
                          and  system_reference1 is not null
                          and  system_reference2 is not null
                          and  system_reference3 is not null;

                   End if;

                Exception

                    when no_data_found then
                         null;
                End;

                   If l_vendor_id is not null then

                    l_stage := 'Deriving values : VENDOR' ;

                   --Select substrb(vendor_name,1,100)
                   -- The select statement has been changed for utf8 changes for AP schema.
                   -- Refer bug 2614745
                     Select vendor_name
                     into l_vendor_name
                     from po_vendors
                    where vendor_id = l_vendor_id;

                  End if;

           elsif  l_resource_type = 'EVENT_TYPE'  then

                  l_stage := 'Deriving values : EVENT';

                  l_event_type := x_event_type;

                  -- ## Event Type also has a revenue_category
                  -- ## In gms, we associate event with expenditure_type
                  -- ## If expenditure_type null, then we calc. revenue_category here

                  If x_expenditure_type is null and x_event_type is not null then

                     l_stage := 'Deriving values : EVENT REV CAT.';

                     Select revenue_category_code
                       into l_revenue_category
                       from pa_event_types
                      where event_type = x_event_type;

                  End if;

           end if; -- if  l_resource_type = .....

          --dbms_output.put_line('l_resource_type:'||l_resource_type);

       end loop; -- for 1..l_rowcount

/* --------------------------------------------------------------------------
|| Following piece of code derives Resource List Member Id (RLMI)
   -------------------------------------------------------------------------- */
l_stage := 'Deriving RLMI';
l_count := 0;


-- 1. get parent_member_id:

If  nvl(x_group_resource_type_name,'NONE') = 'NONE' then

    l_parent_rlmi := null;

ElsIf  nvl(x_group_resource_type_name,'NONE') = 'EXPENDITURE_CATEGORY' then

    If l_expenditure_category is null and x_expenditure_type is not null then

       Select expenditure_category,
              revenue_category_code
         into l_expenditure_category,
              l_revenue_category
         from pa_expenditure_types
        where expenditure_type = x_expenditure_type;

     End if;

     get_parent_rlmi(x_group_resource_type_id,
                     l_expenditure_category,
                     x_resource_list_id,
                     l_parent_rlmi,
                     x_error_code,
                     x_error_buff);

ElsIf  nvl(x_group_resource_type_name,'NONE') = 'REVENUE_CATEGORY' then

    If l_revenue_category is null then

       If x_expenditure_type is not null then

           l_stage := 'Deriving RLMI:UNCLASSIFIED RES - REV - FOR EXP';

           Select expenditure_category,
                  revenue_category_code
             into l_expenditure_category,
                  l_revenue_category
             from pa_expenditure_types
            where expenditure_type = x_expenditure_type;

       Elsif (x_expenditure_type is null and x_event_type is not null) then

            l_stage := 'Deriving RLMI:UNCLASSIFIED RES - REV - FOR EVT';

                     Select revenue_category_code
                       into l_revenue_category
                       from pa_event_types
                      where event_type = x_event_type;

       End if;

     End if;

     get_parent_rlmi(x_group_resource_type_id,
                     l_revenue_category,
                     x_resource_list_id,
                     l_parent_rlmi,
                     x_error_code,
                     x_error_buff);

ElsIf  nvl(x_group_resource_type_name,'NONE') = 'ORGANIZATION' then

                    If l_organization_name is null then

                       Select  name
                         into  l_organization_name
                         from  hr_all_organization_units -- Bug 4732065
                        where  organization_id = x_expenditure_org_id;

                    End If;

     get_parent_rlmi(x_group_resource_type_id,
                     l_organization_name,
                     x_resource_list_id,
                     l_parent_rlmi,
                     x_error_code,
                     x_error_buff);

End if;

If nvl(l_parent_rlmi,0) <> -1 then

-- l_parent_rlmi is -1 when the parent group for the resource does not exist
-- This can happen only for resource list that are grouped..
-- In this case we need to get the Unclassified RLMI at the resource group level
-- For all other combination, RLMI derivation logic continues in this if part...

-- 2. get RLMI for classified:

--2a. If resource group has employee resource_type ...

If l_person_name is not null then

    for rlmi_records in get_rlmis_class('EMPLOYEE',l_person_name)
    loop

        If l_parent_rlmi is null  then

           -- ## RLMI has been derived
           x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

           RETURN;

        ElsIf l_parent_rlmi is not null  then

           If l_parent_rlmi = rlmi_records.parent_member_id then

               -- ## RLMI has been derived
               x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

               RETURN;

           End if;
        End if;-- l_parent_rlmi is not null  then

    end loop;

End If;

--2b. If resource group has job resource_type and RLMI still underived...

If l_job_title is not null then

    for rlmi_records in get_rlmis_class('JOB',l_job_title)
    loop

        If l_parent_rlmi is null  then

           -- ## RLMI has been derived
           x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

           RETURN;

        ElsIf l_parent_rlmi is not null  then

           If l_parent_rlmi = rlmi_records.parent_member_id then

               -- ## RLMI has been derived
               x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

               RETURN;

           End if;
        End if;-- l_parent_rlmi is not null  then

    end loop;

End If;

--2c. If resource group has organization resource_type and RLMI still underived...

If l_organization_name is not null then

    for rlmi_records in get_rlmis_class('ORGANIZATION',l_organization_name)
    loop

        If l_parent_rlmi is null  then

           -- ## RLMI has been derived
           x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

           RETURN;

        ElsIf l_parent_rlmi is not null  then

           If l_parent_rlmi = rlmi_records.parent_member_id then

               -- ## RLMI has been derived
               x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

               RETURN;

           End if;
        End if;-- l_parent_rlmi is not null  then

    end loop;

End If;

--2d. If resource group has vendor resource_type and RLMI still underived...

If l_vendor_name is not null then

    for rlmi_records in get_rlmis_class('VENDOR',l_vendor_name)
    loop

        If l_parent_rlmi is null  then

           -- ## RLMI has been derived
           x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

           RETURN;

        ElsIf l_parent_rlmi is not null  then

           If l_parent_rlmi = rlmi_records.parent_member_id then

               -- ## RLMI has been derived
               x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

               RETURN;

           End if;
        End if;-- l_parent_rlmi is not null  then

    end loop;

End If;

--2e. If resource group has expenditure_type resource_type and RLMI still underived...

If l_expenditure_type is not null then

    for rlmi_records in get_rlmis_class('EXPENDITURE_TYPE',l_expenditure_type)
    loop

        If l_parent_rlmi is null  then

            -- ## RLMI has been derived
           x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

           RETURN;

        ElsIf l_parent_rlmi is not null  then

           If l_parent_rlmi = rlmi_records.parent_member_id then

               -- ## RLMI has been derived
               x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

               RETURN;

           End if;
        End if;-- l_parent_rlmi is not null  then

    end loop;

End If;

--2f. If resource group has event_type resource_type and RLMI still underived...

If l_event_type is not null then

    for rlmi_records in get_rlmis_class('EVENT_TYPE',l_event_type)
    loop

        If l_parent_rlmi is null  then

            -- ## RLMI has been derived
           x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

           RETURN;

        ElsIf l_parent_rlmi is not null  then

           If l_parent_rlmi = rlmi_records.parent_member_id then

               -- ## RLMI has been derived
               x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

               RETURN;

           End if;
        End if;-- l_parent_rlmi is not null  then

    end loop;

End If;

--2g. If resource group has expenditure_category resource_type and RLMI still underived...

If l_expenditure_category is not null then

    for rlmi_records in get_rlmis_class('EXPENDITURE_CATEGORY',l_expenditure_category)
    loop

        If l_parent_rlmi is null  then

            -- ## RLMI has been derived
           x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

           RETURN;

        ElsIf l_parent_rlmi is not null  then

           If l_parent_rlmi = rlmi_records.parent_member_id then

               -- ## RLMI has been derived
               x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

               RETURN;

           End if;
        End if;-- l_parent_rlmi is not null  then

    end loop;

End If;

 --2h. If resource group has revenue_category resource_type and RLMI still underived...

If l_revenue_category is not null then

    for rlmi_records in get_rlmis_class('REVENUE_CATEGORY',l_revenue_category)
    loop

        If l_parent_rlmi is null  then

            -- ## RLMI has been derived
           x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

           RETURN;

        ElsIf l_parent_rlmi is not null  then

           If l_parent_rlmi = rlmi_records.parent_member_id then

               -- ## RLMI has been derived
               x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

               RETURN;

           End if;
        End if;-- l_parent_rlmi is not null  then

    end loop;

End If;

-- If RLMI sill underived, then derive unclassified RLMI
-- 3. get RLMI for unclassified:

   -- New code to derive unclassified start .. Bug reference 3631208
   Begin

      If  l_parent_rlmi is null then

           -- ## Resource list not grouped
           -- ## RLMI has been derived for Ungrouped Resource List
           -- ## RLMI is RLMI for Unclassified resource

           select c.resource_list_member_id
           into   x_resource_list_member_id
           from   pa_resource_list_members c
           where  c.resource_list_id = x_resource_list_id
           and    c.enabled_flag     = 'Y'
           and    c.alias            = 'Unclassified'
           and    c.parent_member_id is NULL
           and    NVL(c.migration_code,'M') ='M'; -- Bug 3626671;

      Else
           -- ## Resource list grouped
           select c.resource_list_member_id
           into   x_resource_list_member_id
           from   pa_resource_list_members c
           where  c.resource_list_id = x_resource_list_id
           and    c.enabled_flag     = 'Y'
           and    c.alias            = 'Unclassified'
           and    c.parent_member_id = l_parent_rlmi
           and    NVL(c.migration_code,'M') ='M'; -- Bug 3626671;

      End If;
           RETURN;
   Exception
      When no_data_found then
           NULL;
   End;
   -- New code to derive unclassified end .. Bug reference 3631208

/*  ---------------------------------------------------------------------------------
    for rlmi_records in get_rlmis_unclass
    loop

       --dbms_output.put_line('UNCLASSIFIED ');

       If  l_parent_rlmi is null then

           -- ## Resource list not grouped
           -- ## RLMI has been derived for Ungrouped Resource List
           -- ## RLMI is RLMI for Unclassified resource
           x_resource_list_member_id := rlmi_records.resource_list_member_id;
           RETURN;

      Else

           -- ## Resource list grouped
           If l_parent_rlmi = rlmi_records.parent_member_id then

               x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

               RETURN;

           End if;

     End if;-- l_parent_rlmi is not null  then

    end loop;
 ----------------------------------------------------------------------------------------- */
 -- 4. If Resource List by Resource Group, but no resources...

 -- 4a. If grouping by organization but no resources..

	If l_organization_name is not null 			   and
   	   nvl(x_group_resource_type_name,'NONE') = 'ORGANIZATION' and
           l_parent_rlmi is not null
        then

            for rlmi_records in get_rlmis_class('ORGANIZATION',l_organization_name)
    	    loop

               If rlmi_records.resource_list_member_id = l_parent_rlmi
               then
                   x_resource_list_member_id :=  rlmi_records.resource_list_member_id;
                   RETURN;
       	       End if;

            end loop;

        End If;

 -- 4b. If grouping by expenditure_category but no resources..

        If l_expenditure_category is not null                              and
           nvl(x_group_resource_type_name,'NONE') = 'EXPENDITURE_CATEGORY' and
           l_parent_rlmi is not null
        then

            for rlmi_records in get_rlmis_class('EXPENDITURE_CATEGORY',l_expenditure_category)
            loop

               If rlmi_records.resource_list_member_id = l_parent_rlmi
               then
                   x_resource_list_member_id :=  rlmi_records.resource_list_member_id;
                   RETURN;
               End if;

            end loop;

        End If;

 -- 4c. If grouping by revenue_category but no resources..

        If l_revenue_category is not null                             and
           nvl(x_group_resource_type_name,'NONE') = 'REVENUE_CATEGORY' and
           l_parent_rlmi is not null
        then

            for rlmi_records in get_rlmis_class('REVENUE_CATEGORY',l_revenue_category)
            loop

               If rlmi_records.resource_list_member_id = l_parent_rlmi
               then
                   x_resource_list_member_id :=  rlmi_records.resource_list_member_id;
                   RETURN;
               End if;

            end loop;

        End If;


 -- 5. RLMI COULD NOT BE DERIVED:

   If (x_resource_list_member_id is NULL) then

       X_Error_Code := 1;
       X_Error_Buff := l_stage || 'RLMI Could not be Derived';

       RETURN;

   End if;

ElsIf nvl(l_parent_rlmi,0) = -1 then

        l_stage := 'Deriving RLMI:UNCLASSIFIED GRP - EXP';

         -- ## Get unclassified Resource Group

            get_grp_unclassified(x_resource_list_id,
                                 x_resource_list_member_id,
                                 x_error_code,
                                 x_error_buff);

          RETURN;

 End if; --If nvl(l_parent_rlmi,0) <> -1 then

End if ; -- ## If categorization_code = 'R' then ...

Exception

   When no_data_found then

       X_Error_Code := 2;
       X_Error_Buff := l_stage || ' :: ' || substrb(sqlerrm,1,200);
       RETURN;

    When others then

       X_Error_Code := 3;
       X_Error_Buff := l_stage || ' :: ' || substrb(sqlerrm,1,200);
       RETURN;

End map_resources;

/*  ----------------------------------------------------------------------
||  ************** NEW CODE FOR RESOURCE MAPPING ENDS HERE **************
    ---------------------------------------------------------------------- */

/*  ---------------------------------------------------------------------------
||  ************** NEW CODE FOR RESOURCE GROUP MAPPING ENDS HERE **************
    --------------------------------------------------------------------------- */


/* -----------------------------------------------------------------------------------
||  Procedure "MAP_RESOURCES_GROUP" is the main API to derive RLMI
||  Parameters:
||  A. IN Parameters:
||     ==============
||  1.  x_document_type - Document Type : EXP,ENC,AP,PO,REQ,EVT(Event), MANDATORY VALUE
||  2.  x_expenditure_type - Expenditure Type
||  3.  x_expenditure_org_id - Organization Id
||  4.  x_person_id - Person Id (Only for Expenditures and Manual Encumbrances)
||  5.  x_job_id - Job Id (Only for Expenditures and Manual Encumbrances)
||  6.  x_vendor_id - Vendor Id (Only for AP/PO/REQ)
||  7.  x_expenditure_category - Expenditure Category of the Expenditure Type
||  8.  x_revenue_category - Revenue Category of the Expenditure Type
||  9.  x_categorization_code - Categorization Code : Values 'R' or 'N'
||  10. x_resource_list_id - Resource List Id
||  11. x_event_type - Event Type
||
||  B. IN OUT NOCOPY Parameters:
||  =====================
||  These IN/OUT parameters are helpful in batch mode(i.e. when Resource mapping API
||  is being called in a loop. API passes the next four values. For the subsequent
||  transactions, API will check if  x_prev_list_processed (resource list for previous
||  transaction) same as for current, if so it does not derive the next 3 IN/OUT parameter
||  values.
|| %%% WARNING %%% :
|| =================
||  Programmers using this API should not initialize the values of these
||  IN/OUT parameters within the loop.
||  1. x_prev_list_processed - Resource List Id of the previous transaction
||  2. x_group_resource_type_id - Group Resource Id for the resource list
||     This has a value of zero, if resource list not grouped.
||  3. x_group_resource_type_name - Group Resource name for the resource list
||  4. resource_type_tab - This pl/sql table stores the different resource types
||     in a resource list. Define plsql table resource_type_tab of type
||     "gms_res_map.resource_type_table"
||  C. OUT NOCOPY Parameters:
||  ==================
||  1. x_resource_list_member_id - Derived RLMI
||  2. x_error_code - Has a value other than zero in case of exception
||  3. x_error_buff - Has a value  in case of exception
||
||  K.Biju .. Dated 15-NOV-2001
   ----------------------------------------------------------------------------------- */


Procedure map_resources_group(x_document_type         IN varchar2,
                        x_expenditure_type           IN varchar2 default NULL,
                        x_expenditure_org_id         IN number default NULL,
                        x_person_id                  IN number  default NULL,
                        x_job_id                     IN number  default NULL,
                        x_vendor_id                  IN number  default NULL,
                        x_expenditure_category       IN varchar2 default NULL,
                        x_revenue_category           IN varchar2 default NULL,
                        x_categorization_code        IN varchar2 default NULL,
                        x_resource_list_id           IN number default NULL,
                        x_event_type                 IN varchar2 default NULL,
                        x_prev_list_processed        IN OUT NOCOPY number,
                        x_group_resource_type_id     IN OUT NOCOPY number,
                        x_group_resource_type_name   IN OUT NOCOPY varchar2,
                        resource_type_tab            IN OUT NOCOPY gms_res_map.resource_type_table,
                        x_resource_list_member_id    OUT NOCOPY number,
                        x_error_code                 OUT NOCOPY number,
                        x_error_buff                 OUT NOCOPY varchar2)
IS

l_stage                     varchar2(50);
l_count                     number(2) := 0;
l_rowcount                  number(2) := 0;
--l_vendor_id                 number(30);
l_resource_type             varchar2(100);
l_expenditure_type          varchar2(100);
l_expenditure_category_tmp  varchar2(100);
l_revenue_category_tmp      varchar2(100);
l_expenditure_category      varchar2(100);
l_revenue_category          varchar2(100);
--l_organization_name         varchar2(100);
-- The width of the variable is changed for UTF8 changes for HRMSschema. Refer bug 2302839.
l_organization_name   HR_ALL_ORGANIZATION_UNITS_TL.NAME%TYPE;


l_person_name               varchar2(100);
l_job_title                 varchar2(100);
-- The length of varaible l_vendor_name has been changed for utf8 changes for AP schema. refer bug 2614745.
--l_vendor_name               varchar2(100);
l_vendor_name   PO_VENDORS.VENDOR_NAME%TYPE;
l_event_type                varchar2(100);
l_parent_rlmi               number(30);

-- ## Following Cursor pulls up all the resource types for that resource list
-- This cursor has been modified as part of Bug reference : 3631208

Cursor get_resource_types is
select distinct c.resource_type_code resource_type_code
from  pa_resource_list_members c
where  c.resource_list_id = x_resource_list_id
and    ((x_group_resource_type_id <> 0 and c.parent_member_id is not null)
        or
        (x_group_resource_type_id = 0 and c.parent_member_id is null)
      )
and    c.enabled_flag='Y'
and    c.resource_type_code <> 'UNCLASSIFIED'
and    NVL(c.migration_code,'M') ='M';

/* ------------------------------------------------ Bug reference : 3631208 -----------+
-- Cursor modified as above ..
select distinct a.resource_type_code resource_type_code
from   pa_resource_types a,
       pa_resources b,
       pa_resource_list_members c
where  c.resource_list_id = x_resource_list_id
and    b.resource_id = c.resource_id
and    a.resource_type_id = b.resource_type_id
and    ((x_group_resource_type_id <> 0 and c.parent_member_id is not null)
        or
        (x_group_resource_type_id = 0 and c.parent_member_id is null)
       )
and    c.enabled_flag='Y'
and    a.resource_type_code <> 'UNCLASSIFIED'
and    NVL(c.migration_code,'M') ='M'; -- Bug 3626671

-- ## Following Cursor pulls up all resource list members, records are sorted
-- ##  so that we get RLMI for the most granular resource

Cursor get_rlmis_unclass is
select c.resource_list_member_id,
       b.name,
       a.resource_type_code,
       b.resource_type_id,
       c.parent_member_id
from   pa_resource_types a,
       pa_resources b,
       pa_resource_list_members c
where  c.resource_list_id = x_resource_list_id
and    b.resource_id = c.resource_id
and    a.resource_type_id = b.resource_type_id
and    c.enabled_flag='Y'
and    a.resource_type_code='UNCLASSIFIED'
and    NVL(c.migration_code,'M') ='M'; -- Bug 3626671
*/

Cursor get_rlmis_class(p_resource_type_code in varchar2, p_name in varchar2) is
select c.resource_list_member_id,
       b.name,
       a.resource_type_code,
       b.resource_type_id,
       c.parent_member_id
from   pa_resource_types a,
       pa_resources b,
       pa_resource_list_members c
where  c.resource_list_id = x_resource_list_id
and    b.resource_id = c.resource_id
and    a.resource_type_id = b.resource_type_id
and    c.enabled_flag='Y'
and    a.resource_type_code=p_resource_type_code
and    b.name = p_name
and    NVL(c.migration_code,'M') ='M'; -- Bug 3626671

TYPE rlmi_record is RECORD(resource_list_member_id NUMBER(15),
                           name                    VARCHAR2(100),
                           resource_type_code      VARCHAR2(30),
                           resource_type_id        NUMBER(15),
                           parent_member_id        NUMBER(15));

TYPE rlmi_table is TABLE of rlmi_record index by binary_integer;

rlmi_tab rlmi_table;

Begin
x_error_code := 0;
l_stage := 'Starting Resource mapping';

-- dbms_output.put_line('In Mapping');
-- ## DO NOT DELETE THE dbms_output lines from the code
-- ## This has been introduced for debugging purpose only
-- ## The checked in version of the file should have all dbms lines commented..

If x_categorization_code <> 'R' then

   l_stage := 'Deriving Uncategorized RLMI';
   -- dbms_output.put_line('In Mapping UnCategorized');

   select resource_list_member_id
   into   x_resource_list_member_id
   from   pa_resource_list_members
   where  resource_list_id = x_resource_list_id
   and    NVL(migration_code,'M') ='M'; -- Bug 3626671

   x_prev_list_processed := x_resource_list_id;
   RETURN;

 Else -- For Budget by resources

   l_stage := 'Deriving Categorized RLMI';
   --dbms_output.put_line('In Mapping Categorized');

   If (nvl(x_prev_list_processed,-1) <>  x_resource_list_id) then

   --dbms_output.put_line('In Mapping Categorized-New');

         l_stage := 'Delete resource type Table';

      -- ##Clean up resource type table, initialize variables
      resource_type_tab.delete;
      x_group_resource_type_id := null;
      x_group_resource_type_name := null;

      l_stage := 'Get Grouping Info';

      -- # Check whether resource list is grouped
      -- # if list not grouped then Zero (0) is the value for group_resource_type_id
       select prl.group_resource_type_id
         into x_group_resource_type_id
         from pa_resource_lists prl
        where prl.resource_list_id = x_resource_list_id;

       If x_group_resource_type_id <> 0 then

         select prt.resource_type_code
           into x_group_resource_type_name
           from pa_resource_types prt
          where prt.resource_type_id = x_group_resource_type_id;

       End if;

      -- ## Recreate resource type table with resource types for resource list being processed

      l_stage := 'Recreate resource type Table';

      for records in get_resource_types
      loop

            l_count := l_count + 1;
            resource_type_tab(l_count) := records.resource_type_code;

      end loop;


      x_prev_list_processed :=  x_resource_list_id ;

   End if; -- If x_prev_list_processed <>  x_resource_list_id


/* --------------------------------------------------------------------------
|| Following piece of code derives all the values necessary for
|| carrying out NOCOPY resource mapping
   -------------------------------------------------------------------------- */

       l_stage := 'Deriving values';

       l_rowcount := resource_type_tab.COUNT;

       --dbms_output.put_line('l_rowcount:'||l_rowcount);

       for i in 1..l_rowcount
       loop

           l_resource_type := resource_type_tab(i);

           if  (l_resource_type = 'EXPENDITURE_TYPE')  then

                l_stage := 'Deriving values : EXP TYPE';

                l_expenditure_type := x_expenditure_type;

           elsif  (l_resource_type = 'EXPENDITURE_CATEGORY' or l_resource_type = 'REVENUE_CATEGORY') then

                   l_stage := 'Deriving values : EXP/REV CAT';

                   -- ## NOTE: exp category and rev cateogry are being derived at one shot
                   -- ## so that we do not have query pa_expenditure_types again

                   If  x_expenditure_type is not null then

                       l_expenditure_category := x_expenditure_category;
                       l_revenue_category     := x_revenue_category;

                    End if;

           elsif  (l_resource_type = 'ORGANIZATION') then

                   l_stage := 'Deriving values : ORG';
		-- -----------
		-- BUG 1773952
		-- -----------
		BEGIN

                   Select  name
                   into    l_organization_name
                   from    hr_organization_units
                   where   organization_id = x_expenditure_org_id;
		EXCEPTION
			WHEN NO_DATA_FOUND THEN
				NULL;
		END;

           elsif  (l_resource_type = 'EMPLOYEE') then

                   If x_document_type in ('EXP','ENC') then

                       l_stage := 'Deriving values : PERSON FOR '||x_document_type;

			BEGIN

                            select substrb(papf.full_name,1,100)
                       		into   l_person_name
                       		from   per_all_people_f papf,
                                   pa_resources pr,
                                   pa_resource_types prt
                       		where  papf.person_id = x_person_id
                            and    papf.full_name = pr.name
                            and    prt.resource_type_id = pr.resource_type_id
                            and    prt.resource_type_code = 'EMPLOYEE'
                            and    rownum=1 ;

   			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;
			END;

            End If;

           elsif  (l_resource_type = 'JOB') then

                   If x_document_type in( 'EXP', 'ENC') then

                       l_stage := 'Deriving values : JOB FOR '||x_document_type;

			BEGIN

                       		select substrb(pj.name,1,100)
                       		into   l_job_title
                       		from   per_jobs pj
                       		where  pj.job_id = x_job_id;
			EXCEPTION
				WHEN NO_DATA_FOUND THEN
					NULL;
			END;
                   End if;

           elsif  (l_resource_type = 'VENDOR') then

                   If x_vendor_id is not null then

                    l_stage := 'Deriving values : VENDOR' ;

                   --Select substrb(vendor_name,1,100)
                   -- The select statement has been changed for utf8 changes for AP schema. refer bug 2614745.
                     Select vendor_name
                     into l_vendor_name
                     from po_vendors
                    where vendor_id = x_vendor_id;

                  End if;

           elsif  l_resource_type = 'EVENT_TYPE'  then

                  l_stage := 'Deriving values : EVENT';

                  l_event_type := x_event_type;

                  -- ## Event Type also has a revenue_category
                  -- ## In gms, we associate event with expenditure_type
                  -- ## If expenditure_type null, then we calc. revenue_category here

                  If x_expenditure_type is null and x_event_type is not null then

                     l_stage := 'Deriving values : EVENT REV CAT.';

                     Select revenue_category_code
                       into l_revenue_category
                       from pa_event_types
                      where event_type = x_event_type;

                  End if;

           end if; -- if  l_resource_type = .....

          --dbms_output.put_line('l_resource_type:'||l_resource_type);

       end loop; -- for 1..l_rowcount

/* --------------------------------------------------------------------------
|| Following piece of code derives Resource List Member Id (RLMI)
   -------------------------------------------------------------------------- */
l_stage := 'Deriving RLMI';
l_count := 0;


-- 1. get parent_member_id:

If  nvl(x_group_resource_type_name,'NONE') = 'NONE' then

    l_parent_rlmi := null;

ElsIf  nvl(x_group_resource_type_name,'NONE') = 'EXPENDITURE_CATEGORY' then

    If l_expenditure_category is null and x_expenditure_type is not null then

       l_expenditure_category := x_expenditure_category;
       l_revenue_category     := x_revenue_category;

     End if;

     get_parent_rlmi(x_group_resource_type_id,
                     l_expenditure_category,
                     x_resource_list_id,
                     l_parent_rlmi,
                     x_error_code,
                     x_error_buff);

ElsIf  nvl(x_group_resource_type_name,'NONE') = 'REVENUE_CATEGORY' then

    If l_revenue_category is null then

       If x_expenditure_type is not null then

           l_stage := 'Deriving RLMI:UNCLASSIFIED RES - REV - FOR EXP';

                       l_expenditure_category := x_expenditure_category;
                       l_revenue_category     := x_revenue_category;

       Elsif (x_expenditure_type is null and x_event_type is not null) then

            l_stage := 'Deriving RLMI:UNCLASSIFIED RES - REV - FOR EVT';

            l_revenue_category     := x_revenue_category;

       End if;

     End if;

     get_parent_rlmi(x_group_resource_type_id,
                     l_revenue_category,
                     x_resource_list_id,
                     l_parent_rlmi,
                     x_error_code,
                     x_error_buff);

ElsIf  nvl(x_group_resource_type_name,'NONE') = 'ORGANIZATION' then

                    If l_organization_name is null then

                       Select  name
                         into  l_organization_name
                         from  hr_organization_units
                        where  organization_id = x_expenditure_org_id;

                    End If;

     get_parent_rlmi(x_group_resource_type_id,
                     l_organization_name,
                     x_resource_list_id,
                     l_parent_rlmi,
                     x_error_code,
                     x_error_buff);

End if;

If nvl(l_parent_rlmi,0) <> -1 then

-- l_parent_rlmi is -1 when the parent group for the resource does not exist
-- This can happen only for resource list that are grouped..
-- In this case we need to get the Unclassified RLMI at the resource group level
-- For all other combination, RLMI derivation logic continues in this if part...

-- 2. get RLMI for classified:

--2a. If resource group has employee resource_type ...

If l_person_name is not null then

    for rlmi_records in get_rlmis_class('EMPLOYEE',l_person_name)
    loop

        If l_parent_rlmi is null  then

           -- ## RLMI has been derived
           x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

           RETURN;

        ElsIf l_parent_rlmi is not null  then

           If l_parent_rlmi = rlmi_records.parent_member_id then

               -- ## RLMI has been derived
               x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

               RETURN;

           End if;
        End if;-- l_parent_rlmi is not null  then

    end loop;

End If;

--2b. If resource group has job resource_type and RLMI still underived...

If l_job_title is not null then

    for rlmi_records in get_rlmis_class('JOB',l_job_title)
    loop

        If l_parent_rlmi is null  then

           -- ## RLMI has been derived
           x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

           RETURN;

        ElsIf l_parent_rlmi is not null  then

           If l_parent_rlmi = rlmi_records.parent_member_id then

               -- ## RLMI has been derived
               x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

               RETURN;

           End if;
        End if;-- l_parent_rlmi is not null  then

    end loop;

End If;

--2c. If resource group has organization resource_type and RLMI still underived...

If l_organization_name is not null then

    for rlmi_records in get_rlmis_class('ORGANIZATION',l_organization_name)
    loop

        If l_parent_rlmi is null  then

           -- ## RLMI has been derived
           x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

           RETURN;

        ElsIf l_parent_rlmi is not null  then

           If l_parent_rlmi = rlmi_records.parent_member_id then

               -- ## RLMI has been derived
               x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

               RETURN;

           End if;
        End if;-- l_parent_rlmi is not null  then

    end loop;

End If;

--2d. If resource group has vendor resource_type and RLMI still underived...

If l_vendor_name is not null then

    for rlmi_records in get_rlmis_class('VENDOR',l_vendor_name)
    loop

        If l_parent_rlmi is null  then

           -- ## RLMI has been derived
           x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

           RETURN;

        ElsIf l_parent_rlmi is not null  then

           If l_parent_rlmi = rlmi_records.parent_member_id then

               -- ## RLMI has been derived
               x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

               RETURN;

           End if;
        End if;-- l_parent_rlmi is not null  then

    end loop;

End If;

--2e. If resource group has expenditure_type resource_type and RLMI still underived...

If l_expenditure_type is not null then

    for rlmi_records in get_rlmis_class('EXPENDITURE_TYPE',l_expenditure_type)
    loop

        If l_parent_rlmi is null  then

            -- ## RLMI has been derived
           x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

           RETURN;

        ElsIf l_parent_rlmi is not null  then

           If l_parent_rlmi = rlmi_records.parent_member_id then

               -- ## RLMI has been derived
               x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

               RETURN;

           End if;
        End if;-- l_parent_rlmi is not null  then

    end loop;

End If;

--2f. If resource group has event_type resource_type and RLMI still underived...

If l_event_type is not null then

    for rlmi_records in get_rlmis_class('EVENT_TYPE',l_event_type)
    loop

        If l_parent_rlmi is null  then

            -- ## RLMI has been derived
           x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

           RETURN;

        ElsIf l_parent_rlmi is not null  then

           If l_parent_rlmi = rlmi_records.parent_member_id then

               -- ## RLMI has been derived
               x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

               RETURN;

           End if;
        End if;-- l_parent_rlmi is not null  then

    end loop;

End If;

--2g. If resource group has expenditure_category resource_type and RLMI still underived...

If l_expenditure_category is not null then

    for rlmi_records in get_rlmis_class('EXPENDITURE_CATEGORY',l_expenditure_category)
    loop

        If l_parent_rlmi is null  then

            -- ## RLMI has been derived
           x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

           RETURN;

        ElsIf l_parent_rlmi is not null  then

           If l_parent_rlmi = rlmi_records.parent_member_id then

               -- ## RLMI has been derived
               x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

               RETURN;

           End if;
        End if;-- l_parent_rlmi is not null  then

    end loop;

End If;

 --2h. If resource group has revenue_category resource_type and RLMI still underived...

If l_revenue_category is not null then

    for rlmi_records in get_rlmis_class('REVENUE_CATEGORY',l_revenue_category)
    loop

        If l_parent_rlmi is null  then

            -- ## RLMI has been derived
           x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

           RETURN;

        ElsIf l_parent_rlmi is not null  then

           If l_parent_rlmi = rlmi_records.parent_member_id then

               -- ## RLMI has been derived
               x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

               RETURN;

           End if;
        End if;-- l_parent_rlmi is not null  then

    end loop;

End If;

-- If RLMI sill underived, then derive unclassified RLMI
-- 3. get RLMI for unclassified:
   -- New code to derive unclassified start .. Bug reference 3631208
   Begin

      If  l_parent_rlmi is null then

           -- ## Resource list not grouped
           -- ## RLMI has been derived for Ungrouped Resource List
           -- ## RLMI is RLMI for Unclassified resource

           select c.resource_list_member_id
           into   x_resource_list_member_id
           from   pa_resource_list_members c
           where  c.resource_list_id = x_resource_list_id
           and    c.enabled_flag     = 'Y'
           and    c.alias            = 'Unclassified'
           and    c.parent_member_id is NULL
           and    NVL(c.migration_code,'M') ='M'; -- Bug 3626671;

      Else
           -- ## Resource list grouped
           select c.resource_list_member_id
           into   x_resource_list_member_id
           from   pa_resource_list_members c
           where  c.resource_list_id = x_resource_list_id
           and    c.enabled_flag     = 'Y'
           and    c.alias            = 'Unclassified'
           and    c.parent_member_id = l_parent_rlmi
           and    NVL(c.migration_code,'M') ='M'; -- Bug 3626671;

      End If;
           RETURN;
   Exception
      When no_data_found then
           NULL;
   End;
   -- New code to derive unclassified end .. Bug reference 3631208

/*  ---------------------------------------------------------------------------------

    for rlmi_records in get_rlmis_unclass
    loop

       --dbms_output.put_line('UNCLASSIFIED ');

       If  l_parent_rlmi is null then

           -- ## Resource list not grouped
           -- ## RLMI has been derived for Ungrouped Resource List
           -- ## RLMI is RLMI for Unclassified resource
           x_resource_list_member_id := rlmi_records.resource_list_member_id;
           RETURN;

      Else

           -- ## Resource list grouped
           If l_parent_rlmi = rlmi_records.parent_member_id then

               x_resource_list_member_id :=  rlmi_records.resource_list_member_id;

               RETURN;

           End if;

     End if;-- l_parent_rlmi is not null  then

    end loop;
 -------------------------------------------------------------------------------------- */

 -- 4. If Resource List by Resource Group, but no resources...

 -- 4a. If grouping by organization but no resources..

	If l_organization_name is not null 			   and
   	   nvl(x_group_resource_type_name,'NONE') = 'ORGANIZATION' and
           l_parent_rlmi is not null
        then

            for rlmi_records in get_rlmis_class('ORGANIZATION',l_organization_name)
    	    loop

               If rlmi_records.resource_list_member_id = l_parent_rlmi
               then
                   x_resource_list_member_id :=  rlmi_records.resource_list_member_id;
                   RETURN;
       	       End if;

            end loop;

        End If;

 -- 4b. If grouping by expenditure_category but no resources..

        If l_expenditure_category is not null                              and
           nvl(x_group_resource_type_name,'NONE') = 'EXPENDITURE_CATEGORY' and
           l_parent_rlmi is not null
        then

            for rlmi_records in get_rlmis_class('EXPENDITURE_CATEGORY',l_expenditure_category)
            loop

               If rlmi_records.resource_list_member_id = l_parent_rlmi
               then
                   x_resource_list_member_id :=  rlmi_records.resource_list_member_id;
                   RETURN;
               End if;

            end loop;

        End If;

 -- 4c. If grouping by revenue_category but no resources..

        If l_revenue_category is not null                             and
           nvl(x_group_resource_type_name,'NONE') = 'REVENUE_CATEGORY' and
           l_parent_rlmi is not null
        then

            for rlmi_records in get_rlmis_class('REVENUE_CATEGORY',l_revenue_category)
            loop

               If rlmi_records.resource_list_member_id = l_parent_rlmi
               then
                   x_resource_list_member_id :=  rlmi_records.resource_list_member_id;
                   RETURN;
               End if;

            end loop;

        End If;


 -- 5. RLMI COULD NOT BE DERIVED:

   If (x_resource_list_member_id is NULL) then

       X_Error_Code := 1;
       X_Error_Buff := l_stage || 'RLMI Could not be Derived';

       RETURN;

   End if;

ElsIf nvl(l_parent_rlmi,0) = -1 then

        l_stage := 'Deriving RLMI:UNCLASSIFIED GRP - EXP';

         -- ## Get unclassified Resource Group

            get_grp_unclassified(x_resource_list_id,
                                 x_resource_list_member_id,
                                 x_error_code,
                                 x_error_buff);

          RETURN;

 End if; --If nvl(l_parent_rlmi,0) <> -1 then

End if ; -- ## If categorization_code = 'R' then ...

Exception

   When no_data_found then

       X_Error_Code := 2;
       X_Error_Buff := l_stage || ' :: ' || substr(sqlerrm,1,200);
       RETURN;

    When others then

       X_Error_Code := 3;
       X_Error_Buff := l_stage || ' :: ' || substr(sqlerrm,1,200);
       RETURN;

End map_resources_group;

/*  ---------------------------------------------------------------------------
||  ************** NEW CODE FOR RESOURCE GROUP MAPPING ENDS HERE **************
    --------------------------------------------------------------------------- */



   -- Initialize function

   FUNCTION initialize RETURN NUMBER IS
      x_err_code NUMBER:=0;
   BEGIN

     RETURN 0;
   EXCEPTION
    WHEN  OTHERS  THEN
      x_err_code := SQLCODE;
      RETURN x_err_code;
   END initialize;

 -- ----------------------------------------------------------------------------
  -- This procedure gets the resouce list member id and for the same combinations
  -- by pass map trans. To increase the performance . 21-SEP-2000
  -- ----------------------------------------------------------------------------
  Procedure get_rlmi
                           	(	x_project_id in number,
            				x_res_list_id in number,
            				x_organization_id in number,
            				x_vendor_id in number,
            				x_expenditure_type in varchar2,
            				x_non_labor_resource in varchar2,
            				x_expenditure_category in varchar2,
            				x_revenue_category in varchar2,
            				x_non_labor_resource_org_id in number,
            				x_system_linkage in varchar2,
					x_job_id in number,
					x_person_id in number,
            				x_resource_list_member_id out NOCOPY number) is

  Begin

        select prm.resource_list_member_id
        into   x_resource_list_member_id
        from   pa_resource_maps prm,
               pa_resource_list_assignments prla
        where  prla.resource_list_assignment_id = prm.resource_list_assignment_id
        and    prla.project_id =  x_project_id
        and    prm.resource_list_id = x_res_list_id
        and    prm.organization_id = x_organization_id
        and    prm.expenditure_category = x_expenditure_category
        and    prm.system_linkage_function = x_system_linkage
	and    nvl(prm.job_id,-1) = nvl(x_job_id,-1)
	and    nvl(prm.person_id,-1) = nvl(x_person_id,-1)
        and    nvl(prm.vendor_id,-1) = nvl(x_vendor_id ,-1)
        and    nvl(prm.expenditure_type,'X') = nvl(x_expenditure_type,'X')
        and    nvl(prm.non_labor_resource,'X') = nvl(x_non_labor_resource,'X')
        and    nvl(prm.revenue_category,'X') = nvl(x_revenue_category,'X')
        and    nvl(prm.non_labor_resource_org_id,-1) = nvl(x_non_labor_resource_org_id,-1)
        and    rownum = 1;
  Exception
  when others then
          x_resource_list_member_id := null;
  End get_rlmi;

   PROCEDURE get_resource_map
	   (x_resource_list_id             IN NUMBER,
	    x_resource_list_assignment_id  IN NUMBER,
	    x_person_id                    IN NUMBER,
	    x_job_id                       IN NUMBER,
	    x_organization_id              IN NUMBER,
	    x_vendor_id                    IN NUMBER,
	    x_expenditure_type             IN VARCHAR2,
	    x_event_type                   IN VARCHAR2,
	    x_non_labor_resource           IN VARCHAR2,
	    x_expenditure_category         IN VARCHAR2,
	    x_revenue_category             IN VARCHAR2,
	    x_non_labor_resource_org_id    IN NUMBER,
	    x_event_type_classification    IN VARCHAR2,
	    x_system_linkage_function      IN VARCHAR2,
	    x_resource_list_member_id   IN OUT NOCOPY NUMBER,
	    x_resource_id               IN OUT NOCOPY NUMBER,
	    x_resource_map_found        IN OUT NOCOPY BOOLEAN,
            x_err_stage                 IN OUT NOCOPY VARCHAR2,
            x_err_code                  IN OUT NOCOPY NUMBER)
   IS
   BEGIN

     x_err_code := 0;
    -- x_err_stage := 'Getting the resource map';
     x_resource_map_found := TRUE;
     x_resource_list_member_id := NULL;
     x_resource_id := NULL;

    -- pa_debug.debug(x_err_stage);

     /* Seperating Map Check for Expenditures based/Event based Txns */

     IF (x_expenditure_type IS NOT NULL) THEN

        -- Process records differently based on the person_id is null/not null
        -- to take advantage of the index on person_id column

        IF ( x_person_id IS NOT NULL ) THEN
           -- person_id is not null
           SELECT
               resource_list_member_id,
	       resource_id
           INTO
               x_resource_list_member_id,
	       x_resource_id
           FROM
               pa_resource_maps prm
           WHERE
               prm.resource_list_assignment_id = x_resource_list_assignment_id
           AND prm.resource_list_id  = x_resource_list_id
           AND prm.expenditure_type  = x_expenditure_type
           AND prm.organization_id   = x_organization_id
           AND prm.person_id = x_person_id
           AND NVL(prm.job_id,-1)    = NVL(x_job_id,-1)
           AND NVL(prm.vendor_id,-1)        = NVL(x_vendor_id,-1)
           AND NVL(prm.non_labor_resource,'X')   = NVL(x_non_labor_resource,'X')
           AND NVL(prm.expenditure_category,'X') = NVL(x_expenditure_category,'X')
           AND NVL(prm.revenue_category,'X')     = NVL(x_revenue_category,'X')
           AND NVL(prm.non_labor_resource_org_id,-1) = NVL(x_non_labor_resource_org_id,-1)
           AND NVL(prm.system_linkage_function,'X')   = NVL(x_system_linkage_function,'X');
        ELSE
           -- person_id is null
           SELECT
               resource_list_member_id,
	       resource_id
           INTO
               x_resource_list_member_id,
	       x_resource_id
           FROM
               pa_resource_maps prm
           WHERE
               prm.resource_list_assignment_id = x_resource_list_assignment_id
           AND prm.resource_list_id  = x_resource_list_id
           AND prm.expenditure_type  = x_expenditure_type
           AND prm.organization_id   = x_organization_id
           AND prm.person_id IS NULL
           AND NVL(prm.job_id,-1)    = NVL(x_job_id,-1)
           AND NVL(prm.vendor_id,-1)        = NVL(x_vendor_id,-1)
           AND NVL(prm.non_labor_resource,'X')   = NVL(x_non_labor_resource,'X')
           AND NVL(prm.expenditure_category,'X') = NVL(x_expenditure_category,'X')
           AND NVL(prm.revenue_category,'X')     = NVL(x_revenue_category,'X')
           AND NVL(prm.non_labor_resource_org_id,-1) = NVL(x_non_labor_resource_org_id,-1)
           AND NVL(prm.system_linkage_function,'X')   = NVL(x_system_linkage_function,'X');
        END IF; -- IF ( x_person_id IS NOT NULL )
     ELSE
        /* Events */
        SELECT
            resource_list_member_id,
	    resource_id
        INTO
            x_resource_list_member_id,
	    x_resource_id
        FROM
            pa_resource_maps prm
        WHERE
            prm.resource_list_assignment_id = x_resource_list_assignment_id
        AND prm.resource_list_id  = x_resource_list_id
        AND prm.event_type        = x_event_type
        AND prm.organization_id   = x_organization_id
        AND prm.revenue_category  = x_revenue_category
        AND prm.event_type_classification = x_event_type_classification;

     END IF; --IF (x_expenditure_type IS NOT NULL)

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       x_resource_map_found := FALSE;
     WHEN OTHERS THEN
       x_err_code := SQLCODE;
       RAISE;
   END get_resource_map;

   -- deleting the resource maps for the given resource list assignment id

   PROCEDURE delete_res_maps_on_asgn_id
	   (x_resource_list_assignment_id  IN NUMBER,
            x_err_stage                 IN OUT NOCOPY VARCHAR2,
            x_err_code                  IN OUT NOCOPY NUMBER)
   IS
   BEGIN

     x_err_code  := 0;
  --   x_err_stage := 'Deleting the resource map for given resource list assignment id';

  --   pa_debug.debug(x_err_stage);
     IF (x_resource_list_assignment_id is null) THEN
       DELETE
           pa_resource_maps;
     ELSE
       DELETE
         pa_resource_maps prm
       WHERE
         prm.resource_list_assignment_id = x_resource_list_assignment_id;
     END IF;

     pa_debug.debug('Numbers of Records Deleted = ' || TO_CHAR(SQL%ROWCOUNT));

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       x_err_code := SQLCODE;
       RAISE;
   END delete_res_maps_on_asgn_id;

   -- deleting the resource maps for the given project_id and
   -- resource_list_id

   PROCEDURE delete_res_maps_on_prj_id
	   (x_project_id                   IN NUMBER,
	    x_resource_list_id             IN NUMBER,
            x_err_stage                 IN OUT NOCOPY VARCHAR2,
            x_err_code                  IN OUT NOCOPY NUMBER)
   IS
   BEGIN

     x_err_code  := 0;
  --   x_err_stage := 'Deleting the resource map for given project Id';

  --   pa_debug.debug(x_err_stage);

     DELETE
         pa_resource_maps prm
     WHERE
         prm.resource_list_assignment_id IN
	 ( SELECT
		resource_list_assignment_id
	   FROM
		pa_resource_list_assignments
	   WHERE project_id = x_project_id
	   AND   resource_list_id = NVL(x_resource_list_id,resource_list_id)
	  );

     pa_debug.debug('Numbers of Records Deleted = ' || TO_CHAR(SQL%ROWCOUNT));

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       x_err_code := SQLCODE;
       RAISE;
   END delete_res_maps_on_prj_id;

   -- the function given below creates a resource map

   PROCEDURE create_resource_map
	   (x_resource_list_id            IN NUMBER,
	    x_resource_list_assignment_id IN NUMBER,
	    x_resource_list_member_id     IN NUMBER,
	    x_resource_id                 IN NUMBER,
	    x_person_id                   IN NUMBER,
	    x_job_id                      IN NUMBER,
	    x_organization_id             IN NUMBER,
	    x_vendor_id                   IN NUMBER,
	    x_expenditure_type            IN VARCHAR2,
	    x_event_type                  IN VARCHAR2,
	    x_non_labor_resource          IN VARCHAR2,
	    x_expenditure_category        IN VARCHAR2,
	    x_revenue_category            IN VARCHAR2,
	    x_non_labor_resource_org_id   IN NUMBER,
	    x_event_type_classification   IN VARCHAR2,
	    x_system_linkage_function     IN VARCHAR2,
            x_err_stage                   IN OUT NOCOPY VARCHAR2,
            x_err_code                    IN OUT NOCOPY NUMBER)
   IS
   BEGIN

     x_err_code  :=0;
     --x_err_stage := 'Creating resource map';

    -- pa_debug.debug(x_err_stage);

     INSERT INTO pa_resource_maps
	   (resource_list_id,
	    resource_list_assignment_id,
	    resource_list_member_id,
	    resource_id,
	    person_id,
	    job_id,
	    organization_id,
	    vendor_id,
	    expenditure_type,
	    event_type,
	    non_labor_resource,
	    expenditure_category,
	    revenue_category,
	    non_labor_resource_org_id,
	    event_type_classification,
	    system_linkage_function,
            creation_date,
            created_by,
	    last_updated_by,
	    last_update_date,
	    last_update_login,
            request_id,
            program_application_id,
            program_id)
     VALUES
	   (x_resource_list_id,
	    x_resource_list_assignment_id,
	    x_resource_list_member_id,
	    x_resource_id,
	    x_person_id,
	    x_job_id,
	    x_organization_id,
	    x_vendor_id,
	    x_expenditure_type,
	    x_event_type,
	    x_non_labor_resource,
	    x_expenditure_category,
	    x_revenue_category,
	    x_non_labor_resource_org_id,
	    x_event_type_classification,
	    x_system_linkage_function,
            SYSDATE,
            x_created_by,
	    x_last_updated_by,
	    SYSDATE,
	    x_last_update_login,
            x_request_id,
            x_program_application_id,
            x_program_id);

   EXCEPTION
     WHEN OTHERS THEN
       x_err_code := SQLCODE;
       RAISE;
   END create_resource_map;

   -- change resource list assignment

   PROCEDURE change_resource_list_status
          (x_resource_list_assignment_id IN NUMBER,
           x_err_stage                   IN OUT NOCOPY VARCHAR2,
           x_err_code                    IN OUT NOCOPY NUMBER)
   IS
   BEGIN

     x_err_code := 0;
   --  x_err_stage := 'Updating resource list assignment status';

  --   pa_debug.debug(x_err_stage);

     UPDATE
          pa_resource_list_assignments
     SET
          resource_list_changed_flag ='N'
     WHERE
         resource_list_assignment_id = x_resource_list_assignment_id;

   EXCEPTION
     WHEN OTHERS THEN
       x_err_code := SQLCODE;
       RAISE;
   END change_resource_list_status;

   FUNCTION get_resource_list_status
       (x_resource_list_assignment_id IN NUMBER)
       RETURN VARCHAR2
   IS
     x_resource_list_changed_flag   VARCHAR2(1);
   BEGIN

     pa_debug.debug('Getting Resource List Status');

     SELECT
          NVL(resource_list_changed_flag,'N')
     INTO
          x_resource_list_changed_flag
     FROM
          pa_resource_list_assignments
     WHERE
         resource_list_assignment_id = x_resource_list_assignment_id;

     RETURN x_resource_list_changed_flag;

   EXCEPTION
     WHEN OTHERS THEN
       RETURN NULL;
   END get_resource_list_status;

   -- Get the resource Rank


   -- If we donot find a rank for a given format and class code then
   -- no resource mapping will be done against that resource

   FUNCTION get_resource_rank
       (x_resource_format_id IN NUMBER,
	x_txn_class_code     IN VARCHAR2)
       RETURN NUMBER
   IS
     x_rank   NUMBER;
   BEGIN

     pa_debug.debug('Getting Resource Rank');

     SELECT
          rank
     INTO
          x_rank
     FROM
          pa_resource_format_ranks
     WHERE
         resource_format_id = x_resource_format_id
     AND txn_class_code = x_txn_class_code;

     RETURN x_rank;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       RETURN NULL;
     WHEN OTHERS THEN
       RETURN NULL;
   END get_resource_rank;

   -- This function returns the group resource_type_code for the given resoure list
   -- In case of 'None' Group Resource type, the table pa_resource_lists
   -- will not join to the pa_resource_types table

   FUNCTION get_group_resource_type_code
       (x_resource_list_id IN NUMBER)
       RETURN VARCHAR2
   IS
     x_group_resource_type_code  VARCHAR2(20);
   BEGIN

     pa_debug.debug('Getting Resource Type Code');

     SELECT
          rt.resource_type_code
     INTO
          x_group_resource_type_code
     FROM
          pa_resource_types rt,
          pa_resource_lists rl
     WHERE
         rl.resource_list_id = x_resource_list_id
     AND rl.group_resource_type_id = rt.resource_type_id;

     RETURN x_group_resource_type_code;

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       x_group_resource_type_code := 'NONE';
       RETURN x_group_resource_type_code;
     WHEN OTHERS THEN
       RETURN NULL;
   END get_group_resource_type_code;

   -- This procedure created resource accum details
   -- We will not allow to have multiple PA_RESOURCE_ACCUM_DETAILS
   -- for the same TXN_ACCUM_ID and different resource_id and
   -- pa_resource_list_member_id

   PROCEDURE create_resource_accum_details
	   (x_resource_list_id            IN NUMBER,
	    x_resource_list_assignment_id IN NUMBER,
	    x_resource_list_member_id     IN NUMBER,
	    x_resource_id                 IN NUMBER,
	    x_txn_accum_id                IN NUMBER,
	    x_project_id                  IN NUMBER,
	    x_task_id                     IN NUMBER,
            x_err_stage                   IN OUT NOCOPY VARCHAR2,
            x_err_code                    IN OUT NOCOPY NUMBER)
   IS
   BEGIN

     x_err_code  :=0;
    -- x_err_stage := 'Creating resource accum details';

    -- pa_debug.debug(x_err_stage);

     INSERT INTO pa_resource_accum_details
	   (resource_list_id,
	    resource_list_assignment_id,
	    resource_list_member_id,
	    resource_id,
	    txn_accum_id,
	    project_id,
	    task_id,
            creation_date,
            created_by,
	    last_updated_by,
	    last_update_date,
	    last_update_login,
            request_id,
            program_application_id,
            program_id)
     SELECT
	    x_resource_list_id,
	    x_resource_list_assignment_id,
	    x_resource_list_member_id,
	    x_resource_id,
	    x_txn_accum_id,
	    x_project_id,
	    x_task_id,
            SYSDATE,
            x_created_by,
	    x_last_updated_by,
	    SYSDATE,
	    x_last_update_login,
            x_request_id,
            x_program_application_id,
            x_program_id
    FROM
	    dual
    WHERE NOT EXISTS
	  (SELECT
		 'Yes'
	   FROM
		 pa_resource_accum_details rad
	   WHERE
		 resource_list_id = x_resource_list_id
	   AND   resource_list_assignment_id = x_resource_list_assignment_id
/*
	   AND   resource_list_member_id = x_resource_list_member_id
	   AND   resource_id = x_resource_id
*/
	   AND   txn_accum_id = x_txn_accum_id
	   AND   project_id = x_project_id
	   AND   task_id = x_task_id
	   );

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
	NULL;
     WHEN OTHERS THEN
       x_err_code := SQLCODE;
       RAISE;
   END create_resource_accum_details;

   -- This procedure deleted resource accum details

   PROCEDURE delete_resource_accum_details
	   (x_resource_list_assignment_id IN NUMBER,
	    x_resource_list_id            IN NUMBER,
	    x_project_id                  IN NUMBER,
            x_err_stage                   IN OUT NOCOPY VARCHAR2,
            x_err_code                    IN OUT NOCOPY NUMBER)
   IS
   BEGIN

     x_err_code  :=0;
   --  x_err_stage := 'Deleting resource accum details';

   --  pa_debug.debug(x_err_stage);

     IF (x_resource_list_id IS NULL) THEN

       DELETE
	  pa_resource_accum_details
       WHERE
          resource_list_assignment_id =
	      NVL(x_resource_list_assignment_id,resource_list_assignment_id)
       AND  project_id = x_project_id;
     ELSE

       DELETE
	  pa_resource_accum_details
       WHERE
          resource_list_assignment_id =
	      NVL(x_resource_list_assignment_id,resource_list_assignment_id)
       AND  resource_list_id = x_resource_list_id
       AND  project_id = x_project_id;

     END IF;

     pa_debug.debug('Numbers of Records Deleted = ' || TO_CHAR(SQL%ROWCOUNT));

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
	NULL;
     WHEN OTHERS THEN
       x_err_code := SQLCODE;
       RAISE;
   END delete_resource_accum_details;

   -- This procedure will return the resource and its attributes for the
   -- given project_id. It will return the group level resource for
   -- the resources for which no child resource exists and for the
   -- group if child exists then it will return only the childs
   -- please note that outer join is done for pa_resources to pa_resource_txn_attributes
   -- because some of the resource may not have attributes

   PROCEDURE get_mappable_resources
          ( x_project_id                     IN  NUMBER,
	    x_res_list_id                    IN  NUMBER,
	    x_resource_list_id            IN OUT NOCOPY resource_list_id_tabtype,
	    x_resource_list_assignment_id IN OUT NOCOPY resource_list_asgn_id_tabtype,
	    x_resource_list_member_id     IN OUT NOCOPY member_id_tabtype,
	    x_resource_id                 IN OUT NOCOPY resource_id_tabtype,
	    x_member_level                IN OUT NOCOPY member_level_tabtype,
	    x_person_id                   IN OUT NOCOPY person_id_tabtype,
	    x_job_id                      IN OUT NOCOPY job_id_tabtype,
	    x_organization_id             IN OUT NOCOPY organization_id_tabtype,
	    x_vendor_id                   IN OUT NOCOPY vendor_id_tabtype,
	    x_expenditure_type            IN OUT NOCOPY expenditure_type_tabtype,
	    x_event_type                  IN OUT NOCOPY event_type_tabtype,
	    x_non_labor_resource          IN OUT NOCOPY non_labor_resource_tabtype,
	    x_expenditure_category        IN OUT NOCOPY expenditure_category_tabtype,
	    x_revenue_category            IN OUT NOCOPY revenue_category_tabtype,
	    x_non_labor_resource_org_id   IN OUT NOCOPY nlr_org_id_tabtype,
	    x_event_type_classification   IN OUT NOCOPY event_type_class_tabtype,
	    x_system_linkage_function     IN OUT NOCOPY system_linkage_tabtype,
	    x_resource_format_id          IN OUT NOCOPY resource_format_id_tabtype,
	    x_resource_type_code          IN OUT NOCOPY resource_type_code_tabtype,
	    x_no_of_resources             IN OUT NOCOPY BINARY_INTEGER,
            x_err_stage                   IN OUT NOCOPY VARCHAR2,
            x_err_code                    IN OUT NOCOPY NUMBER,
            x_exp_type                    IN VARCHAR2 DEFAULT NULL)
   IS

     -- Cursor for getting mappable resources for the given resource list

     CURSOR selmembers IS
     SELECT
         rla.resource_list_assignment_id,
         rl.resource_list_id,
         rlm.resource_list_member_id,
         rlm.resource_id,
         rlm.member_level,
         rta.person_id,
         rta.job_id,
         rta.organization_id,
         rta.vendor_id,
         rta.expenditure_type,
         rta.event_type,
         rta.non_labor_resource,
         rta.expenditure_category,
         rta.revenue_category,
         rta.non_labor_resource_org_id,
         rta.event_type_classification,
         rta.system_linkage_function,
         rta.resource_format_id,
         rt.resource_type_code
     FROM
         pa_resource_lists rl,
         pa_resource_list_members rlm,
         pa_resource_txn_attributes rta,
         pa_resources r,
         pa_resource_types rt,
         pa_resource_list_assignments rla
     WHERE
         rlm.resource_list_id = rl.resource_list_id
     AND rl.resource_list_id = NVL(x_res_list_id,rl.resource_list_id)
     AND NVL(rlm.parent_member_id,0) = 0
     --AND rlm.enabled_flag = 'Y'							Bug Fix 1370475
     AND rlm.resource_id = rta.resource_id(+)  --- rta may not available for resource
     AND r.resource_id = rlm.resource_id
     AND rt.resource_type_id = r.resource_type_id
     AND rla.resource_list_id = rl.resource_list_id
     AND rla.project_id = x_project_id
     AND nvl(rta.expenditure_type,0)=nvl(x_exp_type,nvl(rta.expenditure_type,0))
     AND NOT EXISTS
         ( SELECT
	     'Yes'
           FROM
	     pa_resource_list_members rlmc
           WHERE
             rlmc.parent_member_id = rlm.resource_list_member_id
            AND  NVL(rlmc.migration_code,'M') ='M' -- Bug 3626671
           --AND rlmc.enabled_flag = 'Y'				Bug Fix 1370475
         )
     AND  NVL(rl.migration_code,'M') ='M' -- Bug 3626671
     AND  NVL(rlm.migration_code,'M') ='M' -- Bug 3626671
     UNION
     SELECT
         rla.resource_list_assignment_id,
         rl.resource_list_id,
         rlmc.resource_list_member_id,
         rlmc.resource_id,
         rlmc.member_level,
         NVL(rtac.person_id,rtap.person_id),
         NVL(rtac.job_id,rtap.job_id),
         NVL(rtac.organization_id,rtap.organization_id),
         NVL(rtac.vendor_id,rtap.vendor_id),
         NVL(rtac.expenditure_type,rtap.expenditure_type),
         NVL(rtac.event_type,rtap.event_type),
         NVL(rtac.non_labor_resource,rtap.non_labor_resource),
         NVL(rtac.expenditure_category,rtap.expenditure_category),
         NVL(rtac.revenue_category,rtap.revenue_category),
         NVL(rtac.non_labor_resource_org_id,rtap.non_labor_resource_org_id),
         NVL(rtac.event_type_classification,rtap.event_type_classification),
         NVL(rtac.system_linkage_function,rtap.system_linkage_function),
         rtac.resource_format_id,
         rtc.resource_type_code
     FROM
         pa_resource_lists rl,
         pa_resource_list_members rlmc,
         pa_resource_list_members rlmp,
         pa_resource_txn_attributes rtac,
         pa_resource_txn_attributes rtap,
         pa_resources rc,
         pa_resource_types rtc,
         pa_resource_list_assignments rla
     WHERE
         rlmc.resource_list_id = rl.resource_list_id
     AND rl.resource_list_id = NVL(x_res_list_id,rl.resource_list_id)
     --AND rlmc.enabled_flag = 'Y'								--Bug Fix 1370475
     AND rlmc.resource_id = rtac.resource_id(+)  --- rta may not available for resource
     AND rlmc.parent_member_id  = rlmp.resource_list_member_id
     --AND rlmp.enabled_flag = 'Y'								--Bug Fix 1370475
     AND rlmp.resource_id = rtap.resource_id(+)  --- rta may not available for resource
     AND rc.resource_id = rlmc.resource_id
     AND rtc.resource_type_id = rc.resource_type_id
     AND rla.resource_list_id = rl.resource_list_id
     AND rla.project_id = x_project_id
     AND nvl(rtac.expenditure_type,0)=nvl(x_exp_type,nvl(rtac.expenditure_type,0))
     AND  NVL(rl.migration_code,'M') ='M' -- Bug 3626671
     AND  NVL(rlmc.migration_code,'M') ='M' -- Bug 3626671
     AND  NVL(rlmp.migration_code,'M') ='M' -- Bug 3626671
     /* The next order by is very important.
     Ordering the resource by resource_list_assignment_id, resource_list_id */
     ORDER BY 1,2;

     memberrec          selmembers%ROWTYPE;

   BEGIN

     x_err_code        := 0;
     x_no_of_resources := 0;
   --  x_err_stage       := 'Getting Mappable Resources';


     --pa_debug.debug(x_err_stage);

     -- get the resource list assignments and process them one by one

     FOR memberrec IN selmembers LOOP

       x_no_of_resources := x_no_of_resources + 1;

       -- Get the mappable resource for this project

       x_resource_list_assignment_id (x_no_of_resources) :=
					memberrec.resource_list_assignment_id;
       x_resource_list_id (x_no_of_resources) :=
					memberrec.resource_list_id;
       x_resource_list_member_id (x_no_of_resources) :=
					memberrec.resource_list_member_id;
       x_resource_list_member_id (x_no_of_resources) :=
					memberrec.resource_list_member_id;
       x_resource_id (x_no_of_resources)  := memberrec.resource_id;
       x_member_level (x_no_of_resources) := memberrec.member_level;
       x_person_id (x_no_of_resources)    := memberrec.person_id;
       x_job_id (x_no_of_resources)       := memberrec.job_id;
       x_organization_id (x_no_of_resources)     := memberrec.organization_id;
       x_vendor_id (x_no_of_resources)           := memberrec.vendor_id;
       x_expenditure_type (x_no_of_resources)    := memberrec.expenditure_type;
       x_event_type (x_no_of_resources)          := memberrec.event_type;
       x_non_labor_resource (x_no_of_resources)  := memberrec.non_labor_resource;
       x_expenditure_category (x_no_of_resources):= memberrec.expenditure_category;
       x_revenue_category (x_no_of_resources)    := memberrec.revenue_category;
       x_non_labor_resource_org_id (x_no_of_resources) :=
					       memberrec.non_labor_resource_org_id;
       x_event_type_classification (x_no_of_resources) :=
					       memberrec.event_type_classification;
       x_system_linkage_function (x_no_of_resources) :=
					       memberrec.system_linkage_function;
       x_resource_format_id (x_no_of_resources) := memberrec.resource_format_id;
       x_resource_type_code (x_no_of_resources) := memberrec.resource_type_code;

     END LOOP;

   --  pa_debug.debug('Number of resources found = ' || TO_CHAR(x_no_of_resources));

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         NULL;
     WHEN OTHERS THEN
       x_err_code := SQLCODE;
       RAISE;
   END get_mappable_resources;

/* ----------------------------------------------------------------------------------------------------------------------------- */
PROCEDURE map_trans
          ( x_project_id              		IN  NUMBER,
            x_res_list_id             		IN  NUMBER,
            x_person_id 			IN  NUMBER,
            x_job_id 				IN  NUMBER,
            x_organization_id 			IN  NUMBER,
            x_vendor_id				IN  NUMBER,
            x_expenditure_type 			IN  VARCHAR2,
            x_event_type 			IN  VARCHAR2,
            x_non_labor_resource 		IN  VARCHAR2,
            x_expenditure_category 		IN  VARCHAR2,
            x_revenue_category		 	IN  VARCHAR2,
            x_non_labor_resource_org_id	 	IN  NUMBER,
            x_event_type_classification 	IN  VARCHAR2,
            x_system_linkage_function 		IN  VARCHAR2 ,
            x_exptype                           IN VARCHAR2 DEFAULT NULL,
            x_resource_list_member_id		IN OUT NOCOPY NUMBER,
            x_err_stage            		IN OUT NOCOPY VARCHAR2,
            x_err_code             		IN OUT NOCOPY NUMBER
            ) -- bug 1111920 , add
   IS


     p_resource_list_assignment_id  resource_list_asgn_id_tabtype;
     p_resource_list_id             resource_list_id_tabtype;
     p_resource_list_member_id      member_id_tabtype;
     p_resource_id                  resource_id_tabtype;
     p_member_level                 member_level_tabtype;
     p_person_id                    person_id_tabtype;
     p_job_id                       job_id_tabtype;
     p_organization_id              organization_id_tabtype;
     p_vendor_id                    vendor_id_tabtype;
     p_expenditure_type             expenditure_type_tabtype;
     p_event_type                   event_type_tabtype;
     p_non_labor_resource           non_labor_resource_tabtype;
     p_expenditure_category         expenditure_category_tabtype;
     p_revenue_category             revenue_category_tabtype;
     p_non_labor_resource_org_id    nlr_org_id_tabtype;
     p_event_type_classification    event_type_class_tabtype;
     p_system_linkage_function      system_linkage_tabtype;
     p_resource_format_id           resource_format_id_tabtype;
     p_resource_type_code           resource_type_code_tabtype;
     x_no_of_resources              BINARY_INTEGER;
     res_count                      BINARY_INTEGER;

     -- Variable to store the attributes of the resource list

     current_rl_assignment_id       NUMBER;      -- Current resource list assignment id
     current_rl_id                  NUMBER;      -- Current resource list id
     current_rl_changed_flag        VARCHAR2(1); -- was this resource list changed?
     mapping_done                   BOOLEAN;     -- is mapping done for current resource list
     current_rl_type_code           VARCHAR2(20);-- current resource list type code

     current_rl_member_id           NUMBER;
     current_resource_id            NUMBER;
     current_resource_rank          NUMBER;
     current_member_level           NUMBER;
     group_category_found           BOOLEAN;
     attr_match_found               BOOLEAN;
     new_resource_rank              NUMBER;

     old_resource_id                NUMBER;
     old_rl_member_id               NUMBER;

     resource_map_found             BOOLEAN;

     -- member id for unclassified resources

     uncl_group_member_id           NUMBER;
     uncl_child_member_id           NUMBER;
     uncl_resource_id               NUMBER;  -- assuming one resource_id for unclassfied

   BEGIN
     x_err_code  :=0;

	-- ----------------------------------------------------------------
	-- To increase the resource map performance.
	-- ---------------------------------------------------------------
 										--21-SEP-2000
		/*get_rlmi (	x_project_id ,
       				x_res_list_id ,
       				x_organization_id ,
       				x_vendor_id ,
       				x_expenditure_type ,
       				x_non_labor_resource ,
       				x_expenditure_category ,
       				x_revenue_category ,
       				x_non_labor_resource_org_id ,
       				x_system_linkage_function,
				x_job_id,
				x_person_id,
                      		x_resource_list_member_id );*/

     --if x_resource_list_member_id is null then          -- Performance Improvement

     -- Get the mappable resource for this project
     get_mappable_resources
          ( x_project_id,
	    x_res_list_id,
            p_resource_list_id,
            p_resource_list_assignment_id,
	    p_resource_list_member_id,
	    p_resource_id,
	    p_member_level,
	    p_person_id,
	    p_job_id,
	    p_organization_id,
	    p_vendor_id,
	    p_expenditure_type,
	    p_event_type,
	    p_non_labor_resource,
	    p_expenditure_category,
	    p_revenue_category,
	    p_non_labor_resource_org_id,
	    p_event_type_classification,
	    p_system_linkage_function,
	    p_resource_format_id,
	    p_resource_type_code,
	    x_no_of_resources,
            x_err_stage,
            x_err_code,
            x_exptype);

     -- Now process  the  transaction

     -- Get the txns for which mapping is to be done


       -- Map this txn to all the resoure lists for this project

       mapping_done := TRUE;
       current_rl_assignment_id :=0;

       FOR res_count IN 1..x_no_of_resources LOOP

       IF (current_rl_assignment_id <> p_resource_list_assignment_id(res_count)) THEN

       -- Mapping to the next resource list
       -- Check if resource mapping was done for last resource_list_assigment_id or not

         IF ( NOT mapping_done ) THEN

	    IF ( current_resource_id IS NULL ) THEN -- The last txn_accum could not be mapped

	     -- Map to unclassified Resource
	     -- also if the group_category_found flag is true than map to unclassfied
	     -- category within the group

             current_resource_id      := uncl_resource_id;

	     IF (group_category_found AND uncl_child_member_id <> 0) THEN
                 current_rl_member_id := uncl_child_member_id;
	     ELSE
                 current_rl_member_id := uncl_group_member_id;
	     END IF;

	    END IF; --- IF ( current_resource_id IS NULL )


	    -- Create a map now
           create_resource_map
	      (current_rl_id,
	       current_rl_assignment_id,
	       current_rl_member_id,
	       current_resource_id,
	       x_person_id,
	       x_job_id,
	       x_organization_id,
	       x_vendor_id,
	       x_expenditure_type,
	       x_event_type,
	       x_non_labor_resource,
	       x_expenditure_category,
	       x_revenue_category,
	       x_non_labor_resource_org_id,
	       x_event_type_classification,
	       x_system_linkage_function,
               x_err_stage,
               x_err_code);


         END IF;  -- IF ( NOT mapping_done )


         --- Proceed to the next resource list now

         current_rl_assignment_id   := p_resource_list_assignment_id(res_count);
         current_rl_id              := p_resource_list_id(res_count);
         current_rl_changed_flag    := get_resource_list_status(current_rl_assignment_id);
         current_rl_type_code       := get_group_resource_type_code(current_rl_id);
         mapping_done               := FALSE;

         -- This variables will store the information for best match for the resource
         current_rl_member_id       := NULL;
         current_resource_id        := NULL;
         current_resource_rank      := NULL;
         current_member_level       := NULL;
         group_category_found       := FALSE;
         uncl_group_member_id       := 0;
         uncl_child_member_id       := 0;
         uncl_resource_id           := 0;

         IF ( current_rl_changed_flag = 'Y' ) THEN -- This resource list assignmnet
						   -- has been changed
	    -- delete all the old maps for this resource list assignments
	    -- for all the transactions

	    delete_res_maps_on_asgn_id(current_rl_assignment_id,x_err_stage,x_err_code);
	    change_resource_list_status(current_rl_assignment_id,x_err_stage,x_err_code);

         ELSIF ( current_rl_changed_flag = 'N' ) THEN
            -- Get the resource map status



            get_resource_map
	       (current_rl_id,
	        current_rl_assignment_id,
	        x_person_id,
	        x_job_id,
	        x_organization_id,
	        x_vendor_id,
	        x_expenditure_type,
	        x_event_type,
	        x_non_labor_resource,
	        x_expenditure_category,
	        x_revenue_category,
	        x_non_labor_resource_org_id,
	        x_event_type_classification,
	        x_system_linkage_function,
		old_rl_member_id,
		old_resource_id,
		resource_map_found,
		x_err_stage,
		x_err_code);

            -- check if a map exist for the given attributes in the map table
	    IF (resource_map_found) THEN
	   	   mapping_done := TRUE;
		   x_resource_list_member_id := old_rl_member_id;
		   return;
	    END IF;  -- IF (resource_map_found)

            if(resource_map_found) THEN
	      pa_debug.debug('an old MAP IS FOUND');
            else
	      pa_debug.debug('old MAP IS not FOUND');
	    end if;
	  END IF;

       END IF; -- IF (current_rl_assignment_id <> p_resource_list_assignment_id ....

       IF ( NOT mapping_done ) THEN

	   -- Mapping still need to be done
	   attr_match_found     := TRUE;

	   IF ((p_resource_type_code(res_count) = 'UNCLASSIFIED' OR
		p_resource_type_code(res_count) = 'UNCATEGORIZED') AND
	        p_member_level(res_count) = 1 ) THEN
	          attr_match_found := FALSE;
                  uncl_resource_id := p_resource_id(res_count);
                  uncl_group_member_id  := p_resource_list_member_id(res_count);
	   END IF;

	   IF ( current_rl_type_code = 'EXPENDITURE_CATEGORY') THEN

	    -- The resource list is based on the expenditure category

	    IF ( p_expenditure_category(res_count) = x_expenditure_category) THEN
	      group_category_found := TRUE;
	    ELSE
	      attr_match_found := FALSE;
	    END IF; --IF ( p_expenditure_category(res_count).....

	   ELSIF ( current_rl_type_code = 'REVENUE_CATEGORY' ) THEN

	    -- The resource list is based on the revenue category

	    IF (p_revenue_category(res_count) = x_revenue_category) THEN
	      group_category_found := TRUE;
	    ELSE
	      attr_match_found := FALSE;
	    END IF; -- IF (p_revenue_category(res_count) ....

	   ELSIF ( current_rl_type_code = 'ORGANIZATION' ) THEN

	    -- The resource list is based on the organization

	    IF (p_organization_id(res_count) = x_organization_id) THEN
	      group_category_found := TRUE;
	    ELSE
	      attr_match_found := FALSE;
	    END IF; -- IF (p_organization_id(res_count)

	   END IF; -- IF ( current_rl_type_code = 'EXPENDITURE_CATEGORY'...

	   IF ( current_rl_type_code = 'NONE' OR attr_match_found ) THEN

	    -- The resource list is based on the none category

	    -- Now compare the txn attributes with resource attributes

	    -- The table given below determines if the resource is eligible
	    -- for accumulation or not

	    --  TXN ATTRIBUTE       RESOURCE ATTRIBUTE  ELIGIBLE
	    --     NULL                   NULL            YES
	    --     NULL                 NOT NULL           NO
	    --   NOT NULL                 NULL            YES
	    --   NOT NULL               NOT NULL          YES/NO depending on value

	    -- Do not match the attributes for an unclassified resource

	    IF (p_resource_type_code(res_count) = 'UNCLASSIFIED' ) THEN
	        attr_match_found := FALSE;
                uncl_resource_id := p_resource_id(res_count);
		IF ( p_member_level(res_count) = 1 ) THEN -- group level unclassified
                    uncl_group_member_id  := p_resource_list_member_id(res_count);
		ELSE
                    uncl_child_member_id  := p_resource_list_member_id(res_count);
		END IF;
	    END IF;

	    IF (NOT (attr_match_found AND
	        (NVL(p_person_id(res_count),NVL(x_person_id,-1)) =
		NVL(x_person_id, -1)))) THEN
		attr_match_found := FALSE;
	    END IF;
	    IF (NOT (attr_match_found AND
		(NVL(p_job_id(res_count),NVL(x_job_id,-1)) =
		NVL(x_job_id, -1)))) THEN
		attr_match_found := FALSE;
	    END IF;
	    IF (NOT (attr_match_found AND
		(NVL(p_organization_id(res_count),NVL(x_organization_id,-1)) =
		NVL(x_organization_id, -1)))) THEN
		attr_match_found := FALSE;
	    END IF;
	    IF (NOT (attr_match_found AND
		(NVL(p_vendor_id(res_count),NVL(x_vendor_id,-1)) =
		NVL(x_vendor_id, -1)))) THEN
		attr_match_found := FALSE;
	    END IF;
	    IF (NOT (attr_match_found AND
		(NVL(p_expenditure_type(res_count),NVL(x_expenditure_type,'X')) =
		NVL(x_expenditure_type, 'X')))) THEN
		attr_match_found := FALSE;
	    END IF;
	    IF (NOT (attr_match_found AND
		(NVL(p_event_type(res_count),NVL(x_event_type,'X')) =
		NVL(x_event_type, 'X')))) THEN
		attr_match_found := FALSE;
	    END IF;
	    IF (NOT (attr_match_found AND
	        (NVL(p_non_labor_resource(res_count),NVL(x_non_labor_resource,'X')) =
		NVL(x_non_labor_resource, 'X')))) THEN
		attr_match_found := FALSE;
	    END IF;
	    IF (NOT (attr_match_found AND
		(NVL(p_expenditure_category(res_count),NVL(x_expenditure_category,'X')) =
		NVL(x_expenditure_category, 'X')))) THEN
		attr_match_found := FALSE;
	    END IF;
	    IF (NOT (attr_match_found AND
		(NVL(p_revenue_category(res_count),NVL(x_revenue_category,'X')) =
		NVL(x_revenue_category,'X')))) THEN
		attr_match_found := FALSE;
	    END IF;
	    IF (NOT (attr_match_found AND
		(NVL(p_non_labor_resource_org_id(res_count),NVL(x_non_labor_resource_org_id,-1)) =
		NVL(x_non_labor_resource_org_id,-1)))) THEN
		attr_match_found := FALSE;
	    END IF;
	    IF (NOT (attr_match_found AND
		(NVL(p_event_type_classification(res_count),NVL(x_event_type_classification,'X')) =
		NVL(x_event_type_classification,'X')))) THEN
		attr_match_found := FALSE;
	    END IF;
	    IF (NOT (attr_match_found AND
		(NVL(p_system_linkage_function(res_count),NVL(x_system_linkage_function,'X')) =
		NVL(x_system_linkage_function,'X')))) THEN
		attr_match_found := FALSE;
	    END IF;

	   END IF; --IF ( current_rl_type_code = 'NONE'......
	   IF (attr_match_found) THEN

	      -- Get the resource rank now

	      IF ( x_event_type_classification IS NOT NULL ) THEN

		 -- determine the rank based on event_type_classification
                 new_resource_rank   := get_resource_rank(
					    p_resource_format_id(res_count),
					    x_event_type_classification);
	      ELSE
		 -- determine the rank based on system_linkage_function
                 new_resource_rank   := get_resource_rank(
					    p_resource_format_id(res_count),
					    x_system_linkage_function);
	      END IF; -- IF ( x_event_type_classification IS NOT NULL )

	      IF (  NVL(new_resource_rank,99) < NVL(current_resource_rank,99) ) THEN

		current_resource_rank := new_resource_rank;
                current_rl_member_id  := p_resource_list_member_id(res_count);
                current_resource_id   := p_resource_id(res_count);
                current_member_level  := p_member_level(res_count);

	      END IF;
	    END IF; -- IF (attr_match_found)

       END IF;  -- IF ( NOT mapping_done ) THEN

      END LOOP;

      -- Now create the map for the last resoure list assignment
      IF ( NOT mapping_done ) THEN

	IF ( current_resource_id IS NULL ) THEN -- The last txn_accum could not be mapped

	   -- Map to unclassified Resource
	   -- also if the group_category_found flag is true than map to unclassfied
	   -- category within the group

           current_resource_id      := uncl_resource_id;

	   IF (group_category_found AND uncl_child_member_id <> 0) THEN
               current_rl_member_id := uncl_child_member_id;
	   ELSE
               current_rl_member_id := uncl_group_member_id;
	   END IF;

	END IF; --- IF ( current_resource_id IS NULL )
	-- Create a map now
        create_resource_map
	      (current_rl_id,
	       current_rl_assignment_id,
	       current_rl_member_id,
	       current_resource_id,
	       x_person_id,
	       x_job_id,
	       x_organization_id,
	       x_vendor_id,
	       x_expenditure_type,
	       x_event_type,
	       null,--x_non_labor_resource,
	       x_expenditure_category,
	       x_revenue_category,
	       x_non_labor_resource_org_id,
	       x_event_type_classification,
	       x_system_linkage_function,
               x_err_stage,
               x_err_code);

       END IF;
x_resource_list_member_id := current_rl_member_id;
return;


	--END IF; --Performance Improvement
  EXCEPTION
     -- Return if either no resource list are assigned to the project and/or
     -- no records in pa_txn_accum table need to be rolled up

     WHEN NO_DATA_FOUND THEN
        NULL;
    WHEN OTHERS THEN
      x_err_code := SQLCODE;
      RAISE;
  END map_trans;

END GMS_RES_MAP;

/
