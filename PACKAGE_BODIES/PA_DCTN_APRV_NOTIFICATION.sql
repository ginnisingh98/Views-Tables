--------------------------------------------------------
--  DDL for Package Body PA_DCTN_APRV_NOTIFICATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_DCTN_APRV_NOTIFICATION" as
/* $Header: PADTNWFB.pls 120.1.12010000.1 2009/07/21 10:59:39 sosharma noship $ */

  p_debug_mode    VARCHAR2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
  g_error_message VARCHAR2(1000) :='';
  g_error_stack   VARCHAR2(500) :='';
  g_error_stage   VARCHAR2(100) :='';

  PROCEDURE Start_Dctn_Aprv_Wf( p_dctn_req_id IN NUMBER
                               ,x_err_stack IN OUT NOCOPY VARCHAR2
                               ,x_err_stage IN OUT NOCOPY VARCHAR2
                               ,x_err_code OUT NOCOPY NUMBER
                              ) IS

    CURSOR c_starter_name(l_starter_user_id NUMBER) IS
      SELECT  user_name
        FROM  FND_USER
        WHERE user_id = l_starter_user_id;

    CURSOR c_starter_full_name(l_starter_user_id NUMBER) IS
      SELECT  e.first_name||' '||e.last_name
        FROM  FND_USER f, PER_ALL_PEOPLE_F e
        WHERE f.user_id = l_starter_user_id
        AND   f.employee_id = e.person_id
        AND   e.effective_end_date = ( SELECT MAX(papf.effective_end_date)
                                       FROM per_all_people_f papf
                                       WHERE papf.person_id = e.person_id);
    CURSOR c_wf_started_date IS
      SELECT SYSDATE FROM SYS.DUAL;

    CURSOR c_vendor_info (c_vendor_id NUMBER) IS
         SELECT pov.vendor_name Vendor_Name
         FROM   PO_VENDORS pov
	     WHERE  pov.vendor_id = c_vendor_id;

    l_proj_info_rec                 c_proj_info%ROWTYPE;

    itemkey                         VARCHAR2(30);
    l_wf_started_date               DATE;
    l_workflow_started_by_id        NUMBER;
    l_user_full_name                VARCHAR(400);
    l_user_name                     VARCHAR(240);
    l_resp_id                       NUMBER;
    l_err_code                      NUMBER := 0;
    l_err_stack                     VARCHAR2(2000);
    l_err_stage                     VARCHAR2(2000);
    l_content_id                    NUMBER;
    l_vendor_name                   PO_VENDORS.vendor_name%TYPE;

    itemtype         CONSTANT        VARCHAR2(15) := 'PADCTNWF';
    l_process        CONSTANT        VARCHAR2(20) := 'DEDUCTION_REQ_NTFY';

    c_dctn_hdr_rec c_dctn_hdr%ROWTYPE;

  BEGIN

    l_content_id := 0;

    -- Fetch Receipt id and invoice_id
    OPEN c_dctn_hdr(p_dctn_req_id);
    FETCH c_dctn_hdr INTO c_dctn_hdr_rec;
    IF c_dctn_hdr%NOTFOUND THEN
        x_err_code  := 100;
        x_err_stage := 10;
        x_err_stack := 'PA_DCTN_HDR_NOT_EXISTS';
        CLOSE c_dctn_hdr;
        return;
    END IF;
    CLOSE c_dctn_hdr;

    OPEN c_vendor_info(c_dctn_hdr_rec.vendor_id);
    FETCH c_vendor_info INTO l_vendor_name;
    CLOSE c_vendor_info;

    x_err_code := 0;

    --get the unique identifier for this specific workflow
    SELECT pa_workflow_itemkey_s.nextval
    INTO   itemkey
    FROM   DUAL;

    -- Need this to populate the attribute information in Workflow
    l_workflow_started_by_id := FND_GLOBAL.user_id;
    l_resp_id := FND_GLOBAL.resp_id;

    -- Create a new Wf process
    WF_ENGINE.CreateProcess( itemtype => itemtype,
                             itemkey  => itemkey,
                             process  => l_process);


    -- Fetch all required info to populate Wf Attributes
    OPEN  c_starter_name(l_workflow_started_by_id );
    FETCH c_starter_name INTO l_user_name;
    IF c_starter_name%NOTFOUND THEN
          x_err_code  := 100;
          x_err_stage := 20;
    END IF;
    CLOSE c_starter_name;

    OPEN  c_starter_full_name(l_workflow_started_by_id );
    FETCH c_starter_full_name INTO l_user_full_name;
    IF c_starter_full_name%NOTFOUND THEN
         x_err_code := 100;
         x_err_stage:= 30;
    END IF;
    CLOSE c_starter_full_name;

    OPEN c_wf_started_date;
    FETCH c_wf_started_date INTO l_wf_started_date;
    CLOSE c_wf_started_date;

    OPEN  c_proj_info( c_dctn_hdr_rec.project_id);
    FETCH c_proj_info INTO l_proj_info_rec;
    IF c_proj_info%NOTFOUND THEN
        x_err_code := 100;
        x_err_stage:= 40;
    END IF;
    CLOSE c_proj_info;

    IF x_err_code = 0 THEN
        Generate_Dctn_Aprv_Notify(p_item_type     => itemtype
                                 ,p_item_key      => itemkey
                                 ,p_dctn_hdr_rec  => c_dctn_hdr_rec
                                 ,p_proj_info_rec => l_proj_info_rec
                                 ,x_content_id    => l_content_id
                                );
    END IF;

    IF l_proj_info_rec.project_id IS NOT NULL THEN
         WF_ENGINE.SetItemAttrNumber (itemtype   => itemtype
                                     ,itemkey    => itemkey
                                     ,aname      => 'PROJECT_ID'
                                     ,avalue     => l_proj_info_rec.project_id
                                     );
    END IF;

    IF l_proj_info_rec.project_number IS NOT NULL THEN
         WF_ENGINE.SetItemAttrText (itemtype   => itemtype
                                   ,itemkey    => itemkey
                                   ,aname      => 'PROJECT_NUMBER'
                                   ,avalue     => l_proj_info_rec.project_number
                                   );
    END IF;

    IF l_proj_info_rec.project_name IS NOT NULL THEN
         WF_ENGINE.SetItemAttrText (itemtype   => itemtype
                                   ,itemkey    => itemkey
                                   ,aname      => 'PROJECT_NAME'
                                   ,avalue     => l_proj_info_rec.project_name
                                    );
    END IF;

    IF c_dctn_hdr_rec.deduction_req_num IS NOT NULL THEN
         WF_ENGINE.SetItemAttrText (itemtype   => itemtype
                                   ,itemkey    => itemkey
                                   ,aname      => 'DEDUCTION_REQ_NUM'
                                   ,avalue     => c_dctn_hdr_rec.deduction_req_num
                                    );
    END IF;

    IF c_dctn_hdr_rec.currency_code IS NOT NULL THEN
         WF_ENGINE.SetItemAttrText (itemtype   => itemtype
                                   ,itemkey    => itemkey
                                   ,aname      => 'CURRENCY_CODE'
                                   ,avalue     => c_dctn_hdr_rec.currency_code
                                    );
    END IF;

    IF c_dctn_hdr_rec.total_amount IS NOT NULL THEN
         WF_ENGINE.SetItemAttrNumber (itemtype   => itemtype
                                     ,itemkey    => itemkey
                                     ,aname      => 'APPLIED_AMOUNT'
                                     ,avalue     => c_dctn_hdr_rec.total_amount
                                    );
    END IF;

    IF c_dctn_hdr_rec.debit_memo_num IS NOT NULL THEN
         WF_ENGINE.SetItemAttrText (itemtype     => itemtype
                                   ,itemkey      => itemkey
                                   ,aname        => 'DEBIT_MEMO_NUM'
                                   ,avalue       => c_dctn_hdr_rec.debit_memo_num
                                   );
    END IF;

    IF c_dctn_hdr_rec.vendor_id IS NOT NULL THEN

         WF_ENGINE.SetItemAttrNumber (itemtype   => itemtype
                                     ,itemkey    => itemkey
                                     ,aname      => 'VENDOR_ID'
                                     ,avalue     => c_dctn_hdr_rec.vendor_id
                                     );

         WF_ENGINE.SetItemAttrText  (itemtype     => itemtype
                                     ,itemkey      => itemkey
                                     ,aname        => 'VENDOR_NAME'
                                     ,avalue       => l_vendor_name
                                      );
    END IF;


    IF l_content_id IS NOT NULL THEN
         WF_ENGINE.SetItemAttrNumber (itemtype     => itemtype
                                     ,itemkey      => itemkey
                                     ,aname        => 'CONTENT_ID'
                                     ,avalue       => l_content_id
                                      );
    END IF;

    IF l_workflow_started_by_id IS NOT NULL THEN
         WF_ENGINE.SetItemAttrNumber (itemtype   => itemtype
                                     ,itemkey    => itemkey
                                     ,aname      => 'WORKFLOW_STARTED_BY_ID'
                                     ,avalue     => l_workflow_started_by_id
                                      );
    END IF;

    IF l_user_name IS NOT NULL THEN
         WF_ENGINE.SetItemAttrText (itemtype     => itemtype
                                   ,itemkey      => itemkey
                                   ,aname        => 'WORKFLOW_STARTED_BY_NAME'
                                   ,avalue       => l_user_name
                                   );
    END IF;

    IF l_user_full_name IS NOT NULL THEN
         WF_ENGINE.SetItemAttrText (itemtype     => itemtype
                                   ,itemkey      => itemkey
                                   ,aname        => 'WORKFLOW_STARTED_BY_FULL_NAME'
                                   ,avalue       => l_user_full_name
                                    );
    END IF;

    IF l_resp_id IS NOT NULL THEN
         WF_ENGINE.SetItemAttrNumber (itemtype   => itemtype
                                     ,itemkey    => itemkey
                                     ,aname      => 'RESPONSIBILITY_ID'
                                     ,avalue     => l_resp_id
                                      );
    END IF;

    IF l_wf_started_date IS NOT NULL THEN
         WF_ENGINE.SetItemAttrText (itemtype     => itemtype
                                   ,itemkey      => itemkey
                                   ,aname        => 'WF_STARTED_DATE'
                                   ,avalue       => l_wf_started_date
            );
    END IF;

    WF_ENGINE.StartProcess (itemtype        => itemtype
                           ,itemkey         => itemkey
                            );


    IF x_err_code = 0 THEN
        PA_WORKFLOW_UTILS.Insert_WF_Processes (p_wf_type_code  => 'PADCTNWF'
                                              ,p_item_type     => ItemType
                                              ,p_item_key      => ItemKey
                                              ,p_entity_key1   => c_dctn_hdr_rec.deduction_req_id
                                              ,p_description   => c_dctn_hdr_rec.description
                                              ,p_err_code      => l_err_code
                                              ,p_err_stage     => l_err_stage
                                              ,p_err_stack     => l_err_stack
                                              );
    END IF;

    IF l_err_code <> 0 THEN
       x_err_code := l_err_code;
       x_err_stage := l_err_stage;
       x_err_stack := l_err_stack;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        WF_CORE.CONTEXT('PA_DCTN_APRV_NOTIFICATION ','Start_Dctn_Aprv_Wf');
        RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_err_code := SQLCODE;
        WF_CORE.CONTEXT('PA_DCTN_APRV_NOTIFICATION','Start_Dctn_Aprv_Wf');
        RAISE;
    WHEN OTHERS THEN
        x_err_code := SQLCODE;
        WF_CORE.CONTEXT('PA_DCTN_APRV_NOTIFICATION','Start_Dctn_Aprv_Wf');
        RAISE;
  END Start_Dctn_Aprv_Wf;

  PROCEDURE Generate_Dctn_Aprv_Notify (p_item_type IN VARCHAR2
                                     ,p_item_key IN VARCHAR2
                                     ,p_dctn_hdr_rec IN c_dctn_hdr%ROWTYPE
                                     ,p_proj_info_rec IN c_proj_info%ROWTYPE
                                     ,x_content_id OUT NOCOPY NUMBER) IS

    CURSOR c_orgz_info (p_carrying_out_organization_id NUMBER) IS
      SELECT  name organization_name
        FROM  HR_ORGANIZATION_UNITS
        WHERE organization_id = p_carrying_out_organization_id;

    CURSOR c_vendor_info (c_vendor_id NUMBER, c_vendor_site_id NUMBER) IS
         SELECT pov.vendor_name Vendor_Name,
                povs.vendor_site_code Vendor_Site
         FROM   PO_VENDORS pov,
                PO_VENDOR_SITES_ALL povs
	     WHERE  pov.vendor_id = povs.vendor_id
		 AND    pov.vendor_id = c_vendor_id
		 AND    povs.vendor_site_id = c_vendor_site_id;

    CURSOR c_ci_info IS
        SELECT description
        FROM   PA_CONTROL_ITEMS
        WHERE  ci_id = p_dctn_hdr_rec.ci_id;

    l_vend_info_rec         c_vendor_info%ROWTYPE;
    l_orgz_info_rec         c_orgz_info%ROWTYPE;
    l_proj_manager_rec      c_proj_manager%ROWTYPE;
    l_manager_rec           c_manager%ROWTYPE;

    l_clob                  CLOB;
    l_text                  VARCHAR2(32767);
    l_index                 NUMBER;
    x_return_status         VARCHAR2(1);
    x_msg_count             NUMBER;
    x_msg_data              VARCHAR2(250);
    l_err_code              NUMBER := 0;
    l_err_stack             VARCHAR2(630);
    l_err_stage             VARCHAR2(80);
    l_page_content_id       NUMBER :=0;
    l_ci_type_class_code    VARCHAR2(15);
    l_ci_description        PA_CONTROL_ITEMS.description%TYPE;

    PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN

    OPEN c_orgz_info(p_proj_info_rec.organization_id);
    FETCH c_orgz_info INTO l_orgz_info_rec;
    CLOSE c_orgz_info;

    OPEN c_proj_manager(p_proj_info_rec.project_id);
    FETCH c_proj_manager INTO l_proj_manager_rec;
    IF (c_proj_manager%FOUND) THEN
        OPEN c_manager(l_proj_manager_rec.manager_employee_id);
        FETCH c_manager INTO l_manager_rec;
        IF c_manager%ISOPEN THEN
           CLOSE c_manager;
        END IF;
    END IF;
    CLOSE c_proj_manager;

    OPEN c_vendor_info(p_dctn_hdr_rec.vendor_id, p_dctn_hdr_rec.vendor_site_id);
    FETCH c_vendor_info INTO l_vend_info_rec;
    CLOSE c_vendor_info;

    x_content_id := 0;

    PA_PAGE_CONTENTS_PUB.Create_Page_Contents(p_init_msg_list   => fnd_api.g_false
                                             ,p_validate_only   => fnd_api.g_false
                                             ,p_object_type     => 'PA_DCTN_APRV_NOTIFY'
                                             ,p_pk1_value       => p_dctn_hdr_rec.deduction_req_id
                                             ,p_pk2_value       => NULL
                                             ,x_page_content_id => l_page_content_id
                                             ,x_return_status   => x_return_status
                                             ,x_msg_count       => x_msg_count
                                             ,x_msg_data        => x_msg_data);
    x_content_id := l_page_content_id;

    BEGIN
        SELECT  page_content
          INTO  l_clob
          FROM  PA_PAGE_CONTENTS
          WHERE page_content_id = l_page_content_id FOR UPDATE NOWAIT;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
          RAISE;
    END;

    l_text := '';

    --Starting the page content
    l_text :=  '<table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    -- START : Project Information Section
    l_text :=  '<table cellpadding="0" cellspacing="0" border= "0" width="100%"><tr><td><img src="/OA_HTML/cabo/images/swan/t.gif" /></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Heading
    l_text :=  '<tr><td height="12"><table cellpadding="0" cellspacing="0" border="0" width="100%" style="background-image:url(/OA_HTML/cabo/images/swan/headingBarBg.gif);">';
    l_text := l_text || '<tr><td width="100%"><h2 valign="middle" marginheight="0" style="padding:0px 0px 0px 8px;margin:5px 0px 0px 0px;margin-top:1px;margin-bottom:0px;border-bottom:1px ';
    l_text := l_text || 'solid #aabed5"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#3C3C3C" size="2"><b>Project Information</b></font></h2></td></tr></table></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    l_text :=  '<tr><td height="8" bgcolor="#EAEFF5"></td></tr><tr><td><table cellpadding="0" cellspacing="0" border="0" width="100%"><tr><td bgcolor="#EAEFF5">';
    l_text := l_text || '<table border="0" cellspacing="0" cellpadding="0"><tr><td width="5%"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top">';
    l_text := l_text || '<table border="0" cellspacing="0" cellpadding="0">';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Project name
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Project Name</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || p_proj_info_rec.project_name || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" /></font></td>';
    l_text := l_text || '</tr><tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Project Number
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Project Number</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || p_proj_info_rec.project_number || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" />';
    l_text := l_text || '</font></td></tr><tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Organization
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Organization</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || l_orgz_info_rec.organization_name || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" />';
    l_text := l_text || '</font></td></tr><tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --project type
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Project Type</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || p_proj_info_rec.project_type || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" /></font></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    l_text :=  '</table></td><td width="5%"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><table border="0" cellspacing="0" cellpadding="0">';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Project Manager
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Project Manager';
    l_text := l_text || '</font></td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || l_manager_rec.full_name || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="5" /></font></td></tr><tr><td height="3">';
    l_text := l_text || '</td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --project start date
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Start Date</font></td>';
    l_text := l_text || '<td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || p_proj_info_rec.start_date || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" />';
    l_text := l_text || '</font></td></tr><tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Project finish date
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Finish Date</font></td>';
    l_text := l_text || '<td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" ';
    l_text := l_text || 'size="2"><b>' || p_proj_info_rec.end_date || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" /></font></td></tr><tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    -- project status
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Status</font></td>';
    l_text := l_text || '<td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || p_proj_info_rec.project_status || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" /></font></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    l_text :=  '</table></td></tr></table></td></tr></table></td></tr><tr><td height="8" bgcolor="#EAEFF5"></td></tr></table>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    -- END : Project Information Section

    l_text :=  '<table cellpadding="0" cellspacing="0" border= "0" width="100%"><tr><td height="10"><img src="/OA_HTML/cabo/images/swan/t.gif" /></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Heading
    l_text :=  '<tr><td><table cellpadding="0" cellspacing="0" border="0" width="100%" style="background-image:url(/OA_HTML/cabo/images/swan/headingBarBg.gif);"><tr>';
    l_text := l_text || '<td width="100%"><h2 valign="middle" marginheight="0" style="padding:0px 0px 0px 8px;margin:5px 0px 0px 0px;margin-top:1px;margin-bottom:0px;border-bottom:1px solid #aabed5">';
    l_text := l_text || '<font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#3C3C3C" size="2"><b>Deduction Request Information</b></font></h2></td></tr></table></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    l_text :=  '<tr><td height="8"  bgcolor="#EAEFF5"></td></tr><tr><td><table cellpadding="0" cellspacing="0" border="0" width="100%"><tr><td bgcolor="#EAEFF5">';
    l_text := l_text || '<table border="0" cellspacing="0" cellpadding="0"><tr><td width="5%"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top">';
    l_text := l_text || '<table border="0" cellspacing="0" cellpadding="0">';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Deduction Request num
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Deduction Request Number</font></td>';
    l_text := l_text || '<td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" ';
    l_text := l_text || 'size="2"><b>' || p_dctn_hdr_rec.deduction_req_num || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" /></font></td></tr><tr><td height="3">';
    l_text := l_text || '</td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Deduction Request date
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Deduction Request Date</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" ';
    l_text := l_text || 'size="2"><b>' || p_dctn_hdr_rec.deduction_req_date || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" /></font></td></tr><tr><td height="3">';
    l_text := l_text || '</td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    -- Supplier
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Supplier</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" ';
    l_text := l_text || 'size="2"><b>' || l_vend_info_rec.Vendor_Name || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" /></font></td></tr>';
    l_text := l_text || '<tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Supplier Site
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Supplier Site</font></td>';
    l_text := l_text || '<td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" ';
    l_text := l_text || 'size="2"><b>' || l_vend_info_rec.Vendor_Site || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" /></font></td></tr><tr>';
    l_text := l_text || '<td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --PO Number
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">PO Number</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || p_dctn_hdr_rec.po_number || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" />';
    l_text := l_text || '</font></td></tr><tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    IF p_dctn_hdr_rec.document_type = 'C' THEN
    -- Deduction Request Description
    l_text := '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Description</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || p_dctn_hdr_rec.description || '</b></font></td></tr><tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);
    END IF;

    l_text :=  '</table></td><td width="5%"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><table border="0" cellspacing="0" cellpadding="0">';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Debit memo number
    l_text := '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Debit Memo Number</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || p_dctn_hdr_rec.Debit_memo_num || '</b></font></td></tr><tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Debit Memo Date
    l_text := '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Debit Memo Date</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || p_dctn_hdr_rec.debit_memo_date || '</b></font></td></tr><tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Debit Memo amt
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Debit Memo Amount</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || p_dctn_hdr_rec.total_amount || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" />';
    l_text := l_text || '</font></td></tr><tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Debit Memo Currency
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Debit Memo Currency</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" ';
    l_text := l_text || 'size="2"><b>' || p_dctn_hdr_rec.currency_code || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" /></font></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    IF p_dctn_hdr_rec.document_type = 'C' THEN

    OPEN c_ci_info;
    FETCH c_ci_info INTO l_ci_description;
    CLOSE c_ci_info;

    --Change Doc Number
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Change Document Number</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || p_dctn_hdr_rec.change_doc_num || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" /></font></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Change Doc Type
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Change Document Type</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || p_dctn_hdr_rec.change_doc_type || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" /></font></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Description
    l_text :=  '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Change Document Description</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || l_ci_description || '</b><img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="15" /></font></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    ELSE
    -- Deduction Request Description
    l_text := '<tr><td align="right" valign="top" nowrap="nowrap"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">Description</font>';
    l_text := l_text || '</td><td width="12"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" ';
    l_text := l_text || 'color="#000000" size="2"><b>' || p_dctn_hdr_rec.description || '</b></font></td></tr><tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);
    END IF;

    --This cell is Empty
    l_text :=  '<tr><td height="3"></td><td></td><td></td></tr><tr><td height="3"></td><td></td><td></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    l_text :=  '</table></td></tr></table></td></tr></table></td></tr><tr><td height="8" bgcolor="#EAEFF5"></td></tr></table>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --START : References Section
    l_text := '<table cellpadding="0" cellspacing="0" border= "0" width="100%"><tr><td height="10"><img src="/OA_HTML/cabo/images/swan/t.gif" /></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --Header
    l_text := '<tr><td><table cellpadding="0" cellspacing="0" border="0" width="100%" style="background-image:url(/OA_HTML/cabo/images/swan/headingBarBg.gif);">';
    l_text := l_text || '<tr><td width="100%"><h2 valign="middle" marginheight="0" style="padding:0px 0px 0px 8px;margin:5px 0px 0px 0px;margin-top:1px;margin-bottom:0px;border-bottom:1px ';
    l_text := l_text || 'solid #aabed5"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#3C3C3C" size="2"><b>Refrences</b></font></h2></td></tr></table></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    --URL Section to view deduction request
    l_text := '<tr><td height="8"  bgcolor="#EAEFF5"></td></tr><tr><td> <div><div><table cellpadding="0" cellspacing="0" border="0" width="100%"><tr>';
    l_text := l_text || '<td bgcolor="#EAEFF5"><table border="0" cellspacing="0" cellpadding="0"><tr><td width="5%"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td>';
    l_text := l_text || '<td valign="top"><table border="0" cellspacing="0" cellpadding="0"><tr><td align="right" valign="top" nowrap="nowrap"><span align="right">';
    l_text := l_text || '<img src="/OA_MEDIA/fwkhp_formsfunc.gif" alt="Deduction Request" width="16" height="16" border="0"></span></td><td width="12">';
    l_text := l_text || '<img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">';
    l_text := l_text || '<a href="OA.jsp?page=/oracle/apps/pa/subcontractor/webui/PaViewDeductionsPG&_ri=275&addBreadCrumb=RS&DED_REQ_NUM='||p_dctn_hdr_rec.deduction_req_num||'&DED_REQ_ID='||p_dctn_hdr_rec.deduction_req_id||'">Deduction Request </a>';
    l_text := l_text || '<img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="5" /></font></td></tr><tr>';
    l_text := l_text || '<td height="3"></td><td></td><td></td></tr></table></tr></table></td></tr></table></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    IF p_dctn_hdr_rec.document_type = 'C' THEN
       IF nvl(p_dctn_hdr_rec.change_doc_type,'Change Order') = 'Change Order' THEN
            l_ci_type_class_code := 'CHANGE_ORDER';
       ELSE
            l_ci_type_class_code := 'CHANGE_REQUEST';
       END IF;

    --URL Section to view change order request
    l_text := '<tr><td height="8"  bgcolor="#EAEFF5"></td></tr><tr><td> <div><div><table cellpadding="0" cellspacing="0" border="0" width="100%"><tr>';
    l_text := l_text || '<td bgcolor="#EAEFF5"><table border="0" cellspacing="0" cellpadding="0"><tr><td width="5%"><img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td>';
    l_text := l_text || '<td valign="top"><table border="0" cellspacing="0" cellpadding="0"><tr><td align="right" valign="top" nowrap="nowrap"><span align="right">';
    l_text := l_text || '<img src="/OA_MEDIA/fwkhp_formsfunc.gif" alt="Change Document" width="16" height="16" border="0"></span></td><td width="12">';
    l_text := l_text || '<img src="/OA_HTML/cabo/images/swan/t.gif" width="12" /></td><td valign="top"><font face="Tahoma,Arial,Helvetica,Geneva,sans-serif" color="#000000" size="2">';
    l_text := l_text || '<a href="OA.jsp?_rc=PA_CI_CI_REVIEW_LAYOUT&addBreadCrumb=RP&_ri=275&paProjectId=' || p_dctn_hdr_rec.project_id || '&paCiId=' ||p_dctn_hdr_rec.ci_id|| '&paCITypeClassCode='||l_ci_type_class_code||'">Change Document </a>';
    l_text := l_text || '<img src="/OA_HTML/cabo/images/swan/t.gif" alt="" width="5" /></font></td></tr><tr>';
    l_text := l_text || '<td height="3"></td><td></td><td></td></tr></table></tr></table></td></tr></table></td></tr>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    END IF;

    l_text := '<tr><td height="8" bgcolor="#EAEFF5"></td></tr></table>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);
    --END : References Section

    --Closing the page content
    l_text :=  '</td></tr></table>';
    APPEND_VARCHAR_TO_CLOB(l_text, l_clob);

    COMMIT;
    l_text := '';

  EXCEPTION
    WHEN OTHERS THEN
    RAISE;
  END Generate_Dctn_Aprv_Notify;

  PROCEDURE Select_Project_Manager (itemtype    IN VARCHAR2
                                   ,itemkey     IN VARCHAR2
                                   ,actid       IN NUMBER
                                   ,funcmode    IN VARCHAR2
                                   ,resultout   OUT NOCOPY VARCHAR2)
  IS

  l_err_code                  NUMBER := 0;
  l_resp_id                   NUMBER;
  l_project_id                NUMBER;
  l_workflow_started_by_id    NUMBER;
  l_manager_employee_id       NUMBER;
  l_manager_user_id           NUMBER;
  l_manager_user_name         VARCHAR2(240);
  l_manager_full_name         VARCHAR2(400);
  l_return_status             NUMBER := 0;
  l_project_manager_id        NUMBER := 0;

  BEGIN
      --
      -- Return if WF Not Running
      --
      IF (funcmode <> wf_engine.eng_run) THEN
          resultout := wf_engine.eng_null;
          RETURN;
      END IF;

      l_resp_id  := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                               ,itemkey  => itemkey
                                               ,aname    => 'RESPONSIBILITY_ID');

      l_project_id  := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'PROJECT_ID');

      l_workflow_started_by_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                             ,itemkey  => itemkey
                                                             ,aname    => 'WORKFLOW_STARTED_BY_ID');

      -- Based on the Responsibility, Intialize the Application
      PA_WORKFLOW_UTILS.Set_Global_Attr (p_item_type => itemtype
                                        ,p_item_key  => itemkey
                                        ,p_err_code  => l_err_code);


      PA_CE_AR_NOTIFY_WF.Select_Project_Manager (p_project_id               => l_project_id
                                                ,p_project_manager_id       => l_manager_employee_id
                                                ,p_return_status            => l_return_status);

      IF ( l_return_status = 0 ) THEN
          OPEN  c_proj_manager(l_project_id);
          FETCH c_proj_manager INTO l_manager_employee_id;
          IF c_proj_manager%ISOPEN THEN
              CLOSE c_proj_manager;
          END IF;
      END IF;


      IF (l_manager_employee_id IS NOT NULL )    THEN

          OPEN c_manager( l_manager_employee_id );
          FETCH c_manager INTO l_manager_user_id
                              ,l_manager_user_name
                              ,l_manager_full_name;

          IF (c_manager%FOUND) THEN
              IF c_manager%ISOPEN THEN
                  CLOSE c_manager;
              END IF;
              WF_ENGINE.SetItemAttrNumber (itemtype => itemtype
                                          ,itemkey  => itemkey
                                          ,aname    => 'PROJECT_MANAGER_ID'
                                          ,avalue   => l_manager_user_id );
              WF_ENGINE.SetItemAttrText  (itemtype  => itemtype
                                         ,itemkey   => itemkey
                                         ,aname     => 'PROJECT_MANAGER_NAME'
                                         ,avalue    =>  l_manager_user_name);
              WF_ENGINE.SetItemAttrText  (itemtype  => itemtype
                                         ,itemkey   => itemkey
                                         ,aname     => 'PROJECT_MANAGER_FULL_NAME'
                                         ,avalue    =>  l_manager_full_name);

              resultout := WF_ENGINE.eng_completed||':'||'T';
          ELSE
              IF c_manager%ISOPEN THEN
                  CLOSE c_manager;
              END IF;
              resultout := WF_ENGINE.eng_completed||':'||'F';
          END IF;
      ELSE
          resultout := WF_ENGINE.eng_completed||':'||'F';
      END IF;

  EXCEPTION
      WHEN FND_API.G_EXC_ERROR  THEN
          WF_CORE.CONTEXT('PA_PWP_NOTIFICATION','SELECT_PROJECT_MANAGER',itemtype, itemkey, to_char(actid), funcmode);
          RAISE;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          WF_CORE.CONTEXT('PA_PWP_NOTIFICATION','SELECT_PROJECT_MANAGER',itemtype, itemkey, to_char(actid), funcmode);
          RAISE;

      WHEN OTHERS THEN
          WF_CORE.CONTEXT('PA_PWP_NOTIFICATION','SELECT_PROJECT_MANAGER',itemtype, itemkey, to_char(actid), funcmode);
          RAISE;
  END Select_Project_Manager;


  PROCEDURE SHOW_PWP_NOTIFY_PREVIEW(document_id      IN VARCHAR2
                                   ,display_type     IN VARCHAR2
                                   ,document         IN OUT NOCOPY CLOB
                                   ,document_type    IN OUT NOCOPY VARCHAR2) IS

  l_content CLOB;

  CURSOR c_pwp_preview_info IS
   SELECT  page_content
     FROM  PA_PAGE_CONTENTS
     WHERE page_content_id = document_id
     AND   object_type = 'PA_DCTN_APRV_NOTIFY'
     AND   pk2_value IS NULL;

  l_size             number;
  l_chunk_size      PLS_INTEGER:=10000;
  l_copy_size     INT;
  l_pos             INT := 0;
  l_line             VARCHAR2(30000) := '';
  l_return_status VARCHAR2(1);
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(2000);


  BEGIN

  OPEN c_pwp_preview_info;
  FETCH c_pwp_preview_info INTO l_content;
  IF (c_pwp_preview_info%FOUND) THEN
      IF c_pwp_preview_info%ISOPEN THEN
          CLOSE c_pwp_preview_info;
      END IF;
      l_size := dbms_lob.getlength(l_content);
      l_pos := 1;
      l_copy_size := 0;
      WHILE (l_copy_size < l_size) LOOP
          DBMS_LOB.READ(l_content,l_chunk_size,l_pos,l_line);
          DBMS_LOB.WRITE(document,l_chunk_size,l_pos,l_line);
          l_copy_size := l_copy_size + l_chunk_size;
          l_pos := l_pos + l_chunk_size;
      END LOOP;

      PA_WORKFLOW_UTILS.modify_wf_clob_content(p_document       =>  document
                                              ,x_return_status  =>  l_return_status
                                              ,x_msg_count      =>  l_msg_count
                                              ,x_msg_data       =>  l_msg_data);

      IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
          WF_NOTIFICATION.WriteToClob(document, 'Content Generation failed');
          DBMS_LOB.writeappend(document, 255, SUBSTR(SQLERRM, 255));
      END IF;
  ELSE
      IF c_pwp_preview_info%ISOPEN THEN
          CLOSE c_pwp_preview_info;
      END IF;
  END IF;

  document_type := 'text/html';

  EXCEPTION
      WHEN OTHERS THEN
        WF_NOTIFICATION.WriteToClob(document, 'Content Generation failed');
        dbms_lob.writeappend(document, 255, substrb(Sqlerrm, 255));
      NULL;
  END SHOW_PWP_NOTIFY_PREVIEW;


  PROCEDURE APPEND_VARCHAR_TO_CLOB(p_varchar IN varchar2
                                  ,p_clob    IN OUT NOCOPY CLOB) IS

  l_chunkSize   INTEGER;
  v_offset      INTEGER := 0;
  l_clob        clob;
  l_length      INTEGER;

  v_size        NUMBER;
  v_text        VARCHAR2(3000);

  BEGIN

  l_chunksize := length(p_varchar);
  l_length := dbms_lob.getlength(p_clob);

  DBMS_LOB.write(p_clob
                ,l_chunksize
                ,l_length+1
                ,p_varchar);
  v_size := 1000;
  DBMS_LOB.read(p_clob, v_size, 1, v_text);

  END APPEND_VARCHAR_TO_CLOB;

  PROCEDURE Submit (itemtype IN VARCHAR2
                   ,itemkey IN VARCHAR2
                   ,actid IN NUMBER
                   ,funcmode IN VARCHAR2
                   ,resultout OUT NOCOPY VARCHAR2) IS

    l_deduction_req_num PA_DEDUCTIONS_ALL.deduction_req_num%TYPE;
    l_dctn_rec_info PA_DEDUCTIONS.cur_dctn_hdr_info%ROWTYPE;

    CURSOR C1(c_dctn_req_num  PA_DEDUCTIONS_ALL.deduction_req_num%TYPE) IS
       SELECT * FROM PA_DEDUCTIONS_ALL WHERE deduction_req_num = c_dctn_req_num;

    l_msg_count        NUMBER;
    l_msg_data         VARCHAR2(4000);
    l_return_status    VARCHAR2(4000);
  BEGIN
       resultout := 'COMPLETE : SUCCESS';
       l_deduction_req_num:=
          WF_ENGINE.GetItemAttrText
                        (itemtype   => itemtype
                        ,itemkey    => itemkey
                        ,aname      => 'DEDUCTION_REQ_NUM' );

       OPEN C1(l_deduction_req_num);
       FETCH C1 INTO l_dctn_rec_info;
       CLOSE C1;

       PA_DEDUCTIONS.Submit_For_DebitMemo
                            (l_dctn_rec_info
                            ,l_msg_count
                            ,l_msg_data
                            ,l_return_status);
       IF l_return_status <> 'S' THEN
          resultout := 'COMPLETE : FAILURE'||'Test';
       END IF;
  EXCEPTION
      WHEN OTHERS THEN
          resultout := 'COMPLETE : FAILURE'||SQLCODE;
  END;

  FUNCTION show_error(p_error_stack   IN VARCHAR2,
                      p_error_stage   IN VARCHAR2,
                      p_error_message IN VARCHAR2,
                      p_arg1          IN VARCHAR2 DEFAULT null,
                      p_arg2          IN VARCHAR2 DEFAULT null) RETURN VARCHAR2 IS

  l_result FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;

  BEGIN
     g_error_message := nvl(p_error_message,SUBSTRB(SQLERRM,1,1000));

     fnd_message.set_name('PA','PA_WF_FATAL_ERROR');
     fnd_message.set_token('ERROR_STACK',p_error_stack);
     fnd_message.set_token('ERROR_STAGE',p_error_stage);
     fnd_message.set_token('ERROR_MESSAGE',g_error_message);
     fnd_message.set_token('ERROR_ARG1',p_arg1);
     fnd_message.set_token('ERROR_ARG2',p_arg2);

     l_result  := fnd_message.get_encoded;

     g_error_message := NULL;

     RETURN l_result;
  EXCEPTION WHEN OTHERS
  THEN
     raise;
  END show_error;

END PA_DCTN_APRV_NOTIFICATION;

/
