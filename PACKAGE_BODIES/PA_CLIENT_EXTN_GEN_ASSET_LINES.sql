--------------------------------------------------------
--  DDL for Package Body PA_CLIENT_EXTN_GEN_ASSET_LINES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CLIENT_EXTN_GEN_ASSET_LINES" AS
-- $Header: PAPGALCB.pls 120.3.12010000.2 2009/06/09 09:04:59 abjacob ship $

PROCEDURE CLIENT_ASSET_ASSIGNMENT(p_project_id 	              IN NUMBER,
				  p_task_id                   IN NUMBER,
                                  p_expnd_item_id             IN NUMBER,
                                  p_expnd_id                  IN NUMBER,
                                  p_expnd_type                IN VARCHAR2,
                                  p_expnd_category            IN VARCHAR2,
                                  p_expnd_type_class          IN VARCHAR2,
                                  p_non_labor_org_id          IN NUMBER,
                                  p_non_labor_resource        IN VARCHAR2,
				  p_invoice_id                IN NUMBER,
                                  p_inv_dist_line_number      IN NUMBER,
                                  p_vendor_id                 IN NUMBER,
                                  p_employee_id               IN NUMBER,
                                  p_attribute1                IN VARCHAR2,
                                  p_attribute2                IN VARCHAR2,
                                  p_attribute3                IN VARCHAR2,
                                  p_attribute4                IN VARCHAR2,
                                  p_attribute5                IN VARCHAR2,
                                  p_attribute6                IN VARCHAR2,
                                  p_attribute7                IN VARCHAR2,
                                  p_attribute8                IN VARCHAR2,
                                  p_attribute9                IN VARCHAR2,
                                  p_attribute10               IN VARCHAR2,
                                  p_attribute_category        IN VARCHAR2,
                                  p_in_service_through_date   IN DATE,
                                  x_asset_id                  IN OUT NOCOPY NUMBER) IS

   nl_installed VARCHAR2(1);  -- bug  7524772

/*  Bug 7524772: Broke this cursor into two cursors based on the condition IPA_ASSET_MECH_APIS_PKG.g_nl_installed to facilitate proper index to be picked up*/
/*   cursor get_project_asset_id is
   select project_asset_id
   from   pa_project_asset_assignments ppaa
   where ppaa.task_id = p_task_id
   and   ppaa.project_id = p_project_id
   and   nvl(ppaa.attribute8,'~!@#')  = nvl(p_attribute8,'~!@#')
   and   nvl(ppaa.attribute9,'~!@#')  = nvl(p_attribute9,'~!@#')
   and   nvl(ppaa.attribute10,'~!@#')  = nvl(p_attribute10,'~!@#')
   /* Start Bug fix:2956569 : attribute6,7 Should be used only when the nl_installed flag = Y
   AND  ( (NVL(IPA_ASSET_MECH_APIS_PKG.g_nl_installed,'N') = 'Y'
           AND   nvl(ppaa.attribute6,'~!@#') = nvl(p_attribute6, '~!@#') --crl_inventory
           AND   nvl(ppaa.attribute7,'~!@#') = nvl(p_attribute7, '~!@#') --serial_number
          )
         OR
          NVL(IPA_ASSET_MECH_APIS_PKG.g_nl_installed,'N') = 'N'
        );
    End Bug fix:2956569 */

cursor get_project_asset_id_nl_ins is
select project_asset_id
   from   pa_project_asset_assignments ppaa
   where ppaa.task_id = p_task_id
   and   ppaa.project_id = p_project_id
   AND   nvl(ppaa.attribute6,'~!@#') = nvl(p_attribute6, '~!@#') --crl_inventory
   AND   nvl(ppaa.attribute7,'~!@#') = nvl(p_attribute7, '~!@#') --serial_number
   and   nvl(ppaa.attribute8,'~!@#')  = nvl(p_attribute8,'~!@#')
   and   nvl(ppaa.attribute9,'~!@#')  = nvl(p_attribute9,'~!@#')
   and   nvl(ppaa.attribute10,'~!@#')  = nvl(p_attribute10,'~!@#')
   ;

cursor get_project_asset_id_no_ins is
select project_asset_id
   from   pa_project_asset_assignments ppaa
   where ppaa.task_id = p_task_id
   and   ppaa.project_id = p_project_id
   and   nvl(ppaa.attribute8,'~!@#')  = nvl(p_attribute8,'~!@#')
   and   nvl(ppaa.attribute9,'~!@#')  = nvl(p_attribute9,'~!@#')
   and   nvl(ppaa.attribute10,'~!@#')  = nvl(p_attribute10,'~!@#')
   ;

/*  Bug 7524772  end*/



  /* Adding cursor  for IPA for bug 5637615 */
   CURSOR get_crl_instal_rec is
       SELECT asset_name_id
       FROM ipa_asset_naming_conventions ;

	dummy   number ;
	v_project_asset_id number;
        l_crl_rec  ipa_asset_naming_convents_all.asset_name_id%TYPE;
BEGIN

   nl_installed:= NVL(IPA_ASSET_MECH_APIS_PKG.g_nl_installed,'N');

  /* Adding another check for IPA for bug 5637615 */
   OPEN get_crl_instal_rec;
   FETCH get_crl_instal_rec into l_crl_rec;
   IF get_crl_instal_rec%notfound then
          l_crl_rec :=NULL;
    END IF;
    CLOSE get_crl_instal_rec;


 /* This is the default code for CRL Auto Asset line assognment and this
    portion of the code needs to be un commented if CRL is installed  */
    IF (PA_INSTALL.is_product_installed('IPA')) AND (l_crl_rec IS NOT NULL) THEN
            Select 1 into dummy
            from pa_project_types ppt,
                 pa_tasks pt,
                 pa_tasks pt2,
                 pa_projects_all ppr -- Changed to _ALL as part of MOAC changes
            where p_task_id = pt.task_id and
            p_project_id = pt.project_id and
            pt.project_id = ppr.project_id and
            ppr.template_flag <> 'Y' and
            ppr.project_status_code <> 'CLOSED' and
            ppr.project_type = ppt.project_type and
            ppt.cip_grouping_method_code = 'CIPGCE' and
	    --nvl(ppt.attribute10,'N') = 'Y' and
            ppt.project_type_class_code = 'CAPITAL' and
            pt2.task_id = pt.top_task_id and
            nvl(ppr.attribute10,'Y') ='Y' and
            nvl(pt2.attribute9,'Y') ='Y' and
            ppt.interface_asset_cost_code = 'F';

	   if (sql%found) then
           if (nl_installed = 'Y') then  -- Bug 7524772
              open get_project_asset_id_nl_ins;  -- Bug 7524772
              fetch get_project_asset_id_nl_ins into v_project_asset_id;
              if get_project_asset_id_nl_ins%notfound then
                 v_project_asset_id :=0;
              end if;
              close get_project_asset_id_nl_ins;
           else
              open get_project_asset_id_no_ins;  -- Bug 7524772
              fetch get_project_asset_id_no_ins into v_project_asset_id;
              if get_project_asset_id_no_ins%notfound then
                 v_project_asset_id :=0;
              end if;
              close get_project_asset_id_no_ins;
           end if;
       end if;
       x_asset_id := v_project_asset_id;
   ELSE
     null;
   END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_asset_id := 0;
     --null;
END;
END;

/
