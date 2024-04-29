--------------------------------------------------------
--  DDL for Package Body IGC_CC_ACCGNWF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_CC_ACCGNWF_PKG" AS
/* $Header: IGCCAGNB.pls 120.9.12000000.2 2007/10/18 15:46:49 vumaasha ship $ */


  G_PKG_NAME 	CONSTANT VARCHAR2(30) := 'IGC_CC_ACCGNWF_PKG';
  g_profile_name  VARCHAR2(255);


--g_debug_mode VARCHAR2(1) := NVL(FND_PROFILE.VALUE('IGC_DEBUG_ENABLED'),'N');
  g_debug_mode        VARCHAR2(1);

--Variables for ATG Central logging
  g_debug_level       NUMBER;
  g_state_level       NUMBER;
  g_proc_level        NUMBER;
  g_event_level       NUMBER;
  g_excep_level       NUMBER;
  g_error_level       NUMBER;
  g_unexp_level       NUMBER;
  g_path              VARCHAR2(255);



PROCEDURE Put_Debug_Msg (
   p_path      IN VARCHAR2,
   p_debug_msg IN VARCHAR2
);


---------------------------------------------
-- These are private procedures that support workflow API's
--------------------------------------------

PROCEDURE Call_WF_API_to_set_Att (l_itemtype varchar2, l_itemkey varchar2,
                                  aname varchar2, avalue varchar2);
PROCEDURE Call_WF_API_to_set_no_Att (l_itemtype varchar2, l_itemkey varchar2,
                                  aname varchar2, avalue number);
PROCEDURE Call_WF_API_to_set_date_Att (l_itemtype varchar2, l_itemkey varchar2,
                                  aname varchar2, avalue date);
--------------------------------------------

PROCEDURE message_token(
   tokname IN VARCHAR2,
   tokval  IN VARCHAR2
) ;

/****************************************************************************/

-- Sets the Message Stack

PROCEDURE add_message(
   appname IN VARCHAR2,
   msgname IN VARCHAR2
) ;

PROCEDURE Generate_Message;

--------------------------------------------
-- The followings are global API's
--------------------------------------------


-- Generate Accounts

/*===========================================================================+
 |                      PROCEDURE Generate_Account                           |
 +===========================================================================*/
PROCEDURE Generate_Account
(
  p_project_id                     IN  igc_cc_acct_lines.project_id%TYPE       ,
  p_task_id                        IN  igc_cc_acct_lines.task_id%TYPE          ,
  p_expenditure_type               IN  igc_cc_acct_lines.expenditure_type%TYPE ,
  p_expenditure_organization_id    IN  igc_cc_acct_lines.expenditure_org_id%TYPE ,
  p_expenditure_item_date          IN  igc_cc_acct_lines.expenditure_item_date%TYPE,
  p_vendor_id                      IN  NUMBER,
  p_chart_of_accounts_id           IN  NUMBER,
  p_gen_budget_account             IN  VARCHAR2,  /* 'Y' or 'N' */
  p_cc_acct_line_id                IN  igc_cc_acct_lines.cc_acct_line_id%TYPE ,
  p_cc_header_id                   IN  igc_cc_acct_lines.cc_header_id%TYPE ,
  p_cc_charge_ccid                 IN  igc_cc_acct_lines.cc_charge_code_combination_id%TYPE ,
  p_cc_budget_ccid                 IN  igc_cc_acct_lines.cc_budget_code_combination_id%TYPE ,
  p_cc_acct_desc                   IN  igc_cc_acct_lines.cc_acct_desc%TYPE ,
  p_cc_acct_taxable_flag           IN  igc_cc_acct_lines.cc_acct_taxable_flag%TYPE ,
  p_tax_name                       IN  igc_cc_acct_lines.tax_classif_code%TYPE , /* bug -6472296 Modified tax_id to tax_name for Ebtax uptake*/
  p_context                        IN  igc_cc_acct_lines.context%TYPE ,
  p_attribute1                     IN  igc_cc_acct_lines.attribute1%TYPE ,
  p_attribute2                     IN  igc_cc_acct_lines.attribute2%TYPE ,
  p_attribute3                     IN  igc_cc_acct_lines.attribute3%TYPE ,
  p_attribute4                     IN  igc_cc_acct_lines.attribute4%TYPE ,
  p_attribute5                     IN  igc_cc_acct_lines.attribute5%TYPE ,
  p_attribute6                     IN  igc_cc_acct_lines.attribute6%TYPE ,
  p_attribute7                     IN  igc_cc_acct_lines.attribute7%TYPE ,
  p_attribute8                     IN  igc_cc_acct_lines.attribute8%TYPE ,
  p_attribute9                     IN  igc_cc_acct_lines.attribute9%TYPE ,
  p_attribute10                    IN  igc_cc_acct_lines.attribute10%TYPE ,
  p_attribute11                    IN  igc_cc_acct_lines.attribute11%TYPE ,
  p_attribute12                    IN  igc_cc_acct_lines.attribute12%TYPE ,
  p_attribute13                    IN  igc_cc_acct_lines.attribute13%TYPE ,
  p_attribute14                    IN  igc_cc_acct_lines.attribute14%TYPE ,
  p_attribute15                    IN  igc_cc_acct_lines.attribute15%TYPE ,

  x_out_charge_ccid                OUT NOCOPY igc_cc_acct_lines.cc_charge_code_combination_id%TYPE ,
  x_out_budget_ccid                OUT NOCOPY igc_cc_acct_lines.cc_budget_code_combination_id%TYPE ,
  x_out_charge_account_flex        OUT NOCOPY VARCHAR2,
  x_out_budget_account_flex        OUT NOCOPY VARCHAR2,
  x_out_charge_account_desc        OUT NOCOPY VARCHAR2,
  x_out_budget_account_desc        OUT NOCOPY VARCHAR2,

  x_return_status                  OUT NOCOPY     VARCHAR2,
  x_msg_count                      OUT NOCOPY     NUMBER  ,
  x_msg_data                       OUT NOCOPY     VARCHAR2
)
IS

  l_itemtype                    VARCHAR2(30);
  l_itemkey                     VARCHAR2(30);
  l_api_name                    VARCHAR2(20);

  l_new_ccid_generated	        BOOLEAN := FALSE;
  l_result                      BOOLEAN := FALSE;
  l_insert_if_new	            BOOLEAN := TRUE; --If the dynamic insert in ON

  l_concat_segs                 VARCHAR2(200);
  l_concat_ids                  VARCHAR2(200);
  l_concat_descrs               VARCHAR2(500);

  l_error_msg                   VARCHAR2(200); --modified to fix bug3793841
  l_return_ccid                 gl_code_combinations.code_combination_id%TYPE;

  l_new_combination             BOOLEAN := FALSE; -- To verify if this is a new ccid


  l_class_code                  pa_class_codes.class_code%TYPE;
  l_direct_flag                 pa_project_types_all.direct_flag%TYPE;
  l_expenditure_category        pa_expenditure_categories.expenditure_category%TYPE;
  l_expenditure_org_name        hr_organization_units.name%TYPE;
  l_project_number              pa_projects_all.segment1%TYPE;
  l_project_organization_name   hr_organization_units.name%TYPE;
  l_project_organization_id     hr_organization_units.organization_id %TYPE;
  l_project_type                pa_project_types_all.project_type%TYPE;

  l_public_sector_flag          pa_projects_all.public_sector_flag%TYPE;
  l_revenue_category            pa_expenditure_types.revenue_category_code%TYPE;
  l_task_number                 pa_tasks.task_number%TYPE;
  l_task_organization_name      hr_organization_units.name%TYPE;
  l_task_organization_id        hr_organization_units.organization_id %TYPE;
  l_task_service_type           pa_tasks.service_type_code%TYPE;
  l_top_task_id                 pa_tasks.task_id%TYPE;
  l_top_task_number             pa_tasks.task_number%TYPE;
  l_vendor_employee_id          per_people_f.person_id%TYPE;
  l_vendor_employee_number      per_people_f.employee_number%TYPE;
  l_vendor_type                 po_vendors.vendor_type_lookup_code%TYPE;

  l_full_path         VARCHAR2(255);

BEGIN


  l_itemtype  := 'CCACCGEN';
  l_api_name  :='Generate_Account';
  l_full_path := g_path || 'Generate_Account';

  x_return_status := FND_API.G_RET_STS_SUCCESS;

--  IF (upper(fnd_profile.value('IGC_DEBUG_ENABLED')) ='Y') THEN
--     IGC_MSGS_PKG.g_debug_mode := TRUE;
--  ELSE
--     IGC_MSGS_PKG.g_debug_mode := FALSE;
--  END IF;

  IF (g_debug_mode = 'Y') THEN
    Put_Debug_Msg(l_full_path, '**************************************************************************');
    Put_Debug_Msg(l_full_path, 'CC Account generator is being called , Date '||to_char(sysdate,'DD-MON-YY MI:SS'));
    Put_Debug_Msg(l_full_path, '**************************************************************************');
  END IF;

  fnd_profile.put('ACCOUNT_GENERATOR:DEBUG_MODE','Y');

  IF ( p_project_id IS NOT NULL ) Then

    IF (g_debug_mode = 'Y') THEN
       Put_Debug_Msg(l_full_path, 'Obtaining project info');
    END IF;

    pa_acc_gen_wf_pkg.wf_acc_derive_params ( p_project_id => p_project_id,
					    p_task_id    => p_task_id,
					    p_expenditure_type => p_expenditure_type,
					    p_vendor_id  => p_vendor_id,
				 	    p_expenditure_organization_id => p_expenditure_organization_id,
					    p_expenditure_item_date => p_expenditure_item_date,
					    x_class_code  => l_class_code,
					    x_direct_flag => l_direct_flag,
					    x_expenditure_category  => l_expenditure_category,
					    x_expenditure_org_name  => l_expenditure_org_name,
					    x_project_number  => l_project_number,
					    x_project_organization_name => l_project_organization_name,
					    x_project_organization_id => l_project_organization_id,
					    x_project_type => l_project_type,
					    x_public_sector_flag => l_public_sector_flag,
					    x_revenue_category => l_revenue_category,
					    x_task_number => l_task_number,
					    x_task_organization_name => l_task_organization_name,
					    x_task_organization_id => l_task_organization_id,
					    x_task_service_type => l_task_service_type,
					    x_top_task_id => l_top_task_id,
					    x_top_task_number => l_top_task_number,
					    x_vendor_employee_id => l_vendor_employee_id,
					    x_vendor_employee_number => l_vendor_employee_number,
					    x_vendor_type => l_vendor_type);



     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg(l_full_path, 'Done');
     END IF;

  END IF;


  l_itemtype:= '';

  LOOP

     --This loop is executed once or twice, depending on if we need to generate budget acct or not.

     IF l_itemtype IS NULL THEN

        l_itemtype:= 'IGCACGNC';  -- Name of charge acc gen

     ELSIF  l_itemtype= 'IGCACGNC'  AND p_gen_budget_account = 'Y' THEN

        l_itemtype:= 'IGCACGNB'; -- Name of budget acc gen

     ELSE

        EXIT;  -- Exiting loop;

     END IF;

     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg(l_full_path, 'Initalizing WF for '||l_itemtype);
     END IF;

     l_itemkey := fnd_flex_workflow.initialize
               (
                 appl_short_name => 'SQLGL',
                 code            => 'GL#',
                 num             => p_chart_of_accounts_id,
                 itemtype        => l_itemtype
               );


     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg(l_full_path, 'Itemkey received:  '||l_itemkey);
     END IF;

     IF l_Itemkey IS NULL THEN
        --Erroring out.
        IF (g_debug_mode = 'Y') THEN
           Put_Debug_Msg(l_full_path, 'Itemkey is invalid, raising an exception');
        END IF;

        RAISE FND_API.G_EXC_ERROR;

     END IF;

     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg(l_full_path, 'Initialize the workflow item attributes');
     END IF;

     -----------------------------------------------------------
     -- Initialize the workflow item attributes
     ----------------------------------------------------------


     Call_WF_API_to_set_Att (l_itemtype, l_itemkey, 'CLASS_CODE', l_class_code);
     Call_WF_API_to_set_Att (l_itemtype, l_itemkey, 'DIRECT_FLAG', l_direct_flag);
     Call_WF_API_to_set_Att (l_itemtype, l_itemkey, 'EXPENDITURE_CATEGORY', l_expenditure_category);
     Call_WF_API_to_set_Att (l_itemtype, l_itemkey, 'EXPENDITURE_ORG_NAME', l_expenditure_org_name);
     Call_WF_API_to_set_Att (l_itemtype, l_itemkey, 'PROJECT_NUMBER', l_project_number);
     Call_WF_API_to_set_Att (l_itemtype, l_itemkey, 'PROJECT_ORGANIZATION_NAME', l_project_organization_name);
     Call_WF_API_to_set_no_Att (l_itemtype, l_itemkey, 'PROJECT_ORGANIZATION_ID', l_project_organization_id);
     Call_WF_API_to_set_Att (l_itemtype, l_itemkey, 'PROJECT_TYPE', l_project_type);
     Call_WF_API_to_set_Att (l_itemtype, l_itemkey, 'PUBLIC_SECTOR_FLAG', l_public_sector_flag);
     Call_WF_API_to_set_Att (l_itemtype, l_itemkey, 'REVENUE_CATEGORY', l_revenue_category);
     Call_WF_API_to_set_Att (l_itemtype, l_itemkey, 'TASK_NUMBER', l_task_number);
     Call_WF_API_to_set_Att (l_itemtype, l_itemkey, 'TASK_ORGANIZATION_NAME', l_task_organization_name);
     Call_WF_API_to_set_no_Att (l_itemtype, l_itemkey, 'TASK_ORGANIZATION_ID', l_task_organization_id);
     Call_WF_API_to_set_Att (l_itemtype, l_itemkey, 'TASK_SERVICE_TYPE', l_task_service_type);
     Call_WF_API_to_set_no_Att (l_itemtype, l_itemkey, 'TOP_TASK_ID', l_top_task_id);
     Call_WF_API_to_set_Att (l_itemtype, l_itemkey, 'TOP_TASK_NUMBER', l_top_task_number);
     Call_WF_API_to_set_no_Att (l_itemtype, l_itemkey, 'VENDOR_EMPLOYEE_ID', l_vendor_employee_id);
     Call_WF_API_to_set_Att (l_itemtype, l_itemkey, 'VENDOR_EMPLOYEE_NUMBER', l_vendor_employee_number);
     Call_WF_API_to_set_Att (l_itemtype, l_itemkey, 'VENDOR_TYPE', l_vendor_type);

     wf_engine.SetItemAttrNumber ( itemtype   => l_itemtype,
                                itemkey    => l_itemkey,
                                aname      => 'PROJECT_ID',
                                avalue     => p_project_id);

     wf_engine.SetItemAttrNumber ( itemtype   => l_itemtype,
                                itemkey    => l_itemkey,
                                aname      => 'TASK_ID',
                                avalue     => p_task_id);

     wf_engine.SetItemAttrText   ( itemtype   => l_itemtype,
                                itemkey    => l_itemkey,
                                aname      => 'EXPENDITURE_TYPE',
                                avalue     => p_expenditure_type);

     wf_engine.SetItemAttrNumber ( itemtype   => l_itemtype,
                                itemkey    => l_itemkey,
                                aname      => 'EXPENDITURE_ORG_ID',
                                avalue     => p_expenditure_organization_id);

     wf_engine.SetItemAttrDate   (  itemtype   =>  l_itemtype,
                                 itemkey    =>  l_itemkey,
                                 aname      =>  'EXPENDITURE_ITEM_DATE',
                                 avalue     =>  p_expenditure_item_date );

     wf_engine.SetItemAttrNumber( itemtype   => l_itemtype,
                               itemkey    => l_itemkey,
                               aname      => 'CHART_OF_ACCOUNTS_ID',
                               avalue     => p_chart_of_accounts_id);

     wf_engine.SetItemAttrNumber( itemtype   => l_itemtype,
                               itemkey    => l_itemkey,
                               aname      => 'CC_ACCT_LINE_ID',
                               avalue     => p_cc_acct_line_id);

     wf_engine.SetItemAttrNumber( itemtype   => l_itemtype,
                               itemkey    => l_itemkey,
                               aname      => 'CC_HEADER_ID',
                               avalue     => p_cc_header_id);

     wf_engine.SetItemAttrNumber( itemtype   => l_itemtype,
                               itemkey    => l_itemkey,
                               aname      => 'CC_BUDGET_CCID',
                               avalue     => p_cc_budget_ccid);

     wf_engine.SetItemAttrNumber( itemtype   => l_itemtype,
                               itemkey    => l_itemkey,
                               aname      => 'CC_CHARGE_CCID',
                               avalue     => NVL(l_return_ccid,p_cc_charge_ccid));

     wf_engine.SetItemAttrText   ( itemtype   => l_itemtype,
                                itemkey    => l_itemkey,
                                aname      => 'CC_ACCT_DESC',
                                avalue     => p_cc_acct_desc);

     wf_engine.SetItemAttrText   ( itemtype   => l_itemtype,
                                itemkey    => l_itemkey,
                                aname      => 'CC_ACCT_TAXABLE_FLAG',
                                avalue     => p_cc_acct_taxable_flag);

     wf_engine.SetItemAttrText( itemtype   => l_itemtype,
                               itemkey    => l_itemkey,
                               aname      => 'TAX_NAME',
                               avalue     => p_tax_name);
			       /* bug -6472296 Modified tax_id to tax_name for Ebtax uptake*/

     wf_engine.SetItemAttrText   ( itemtype   => l_itemtype,
                                itemkey    => l_itemkey,
                                aname      => 'CONTEXT',
                                avalue     => p_context);

     wf_engine.SetItemAttrText   ( itemtype   => l_itemtype,
                                itemkey    => l_itemkey,
                                aname      => 'ATTRIBUTE1',
                                avalue     => p_attribute1);

     wf_engine.SetItemAttrText   ( itemtype   => l_itemtype,
                                itemkey    => l_itemkey,
                                aname      => 'ATTRIBUTE2',
                                avalue     => p_attribute2);

     wf_engine.SetItemAttrText   ( itemtype   => l_itemtype,
                                itemkey    => l_itemkey,
                                aname      => 'ATTRIBUTE3',
                                avalue     => p_attribute3);

     wf_engine.SetItemAttrText   ( itemtype   => l_itemtype,
                                itemkey    => l_itemkey,
                                aname      => 'ATTRIBUTE4',
                                avalue     => p_attribute4);

     wf_engine.SetItemAttrText   ( itemtype   => l_itemtype,
                                itemkey    => l_itemkey,
                                aname      => 'ATTRIBUTE5',
                                avalue     => p_attribute5);

     wf_engine.SetItemAttrText   ( itemtype   => l_itemtype,
                                itemkey    => l_itemkey,
                                aname      => 'ATTRIBUTE6',
                                avalue     => p_attribute6);

     wf_engine.SetItemAttrText   ( itemtype   => l_itemtype,
                                itemkey    => l_itemkey,
                                aname      => 'ATTRIBUTE7',
                                avalue     => p_attribute7);

     wf_engine.SetItemAttrText   ( itemtype   => l_itemtype,
                                itemkey    => l_itemkey,
                                aname      => 'ATTRIBUTE8',
                                avalue     => p_attribute8);

     wf_engine.SetItemAttrText   ( itemtype   => l_itemtype,
                                itemkey    => l_itemkey,
                                aname      => 'ATTRIBUTE9',
                                avalue     => p_attribute9);

     wf_engine.SetItemAttrText   ( itemtype   => l_itemtype,
                                itemkey    => l_itemkey,
                                aname      => 'ATTRIBUTE10',
                                avalue     => p_attribute10);

     wf_engine.SetItemAttrText   ( itemtype   => l_itemtype,
                                itemkey    => l_itemkey,
                                aname      => 'ATTRIBUTE11',
                                avalue     => p_attribute11);

     wf_engine.SetItemAttrText   ( itemtype   => l_itemtype,
                                itemkey    => l_itemkey,
                                aname      => 'ATTRIBUTE12',
                                avalue     => p_attribute12);

     wf_engine.SetItemAttrText   ( itemtype   => l_itemtype,
                                itemkey    => l_itemkey,
                                aname      => 'ATTRIBUTE13',
                                avalue     => p_attribute13);

     wf_engine.SetItemAttrText   ( itemtype   => l_itemtype,
                                itemkey    => l_itemkey,
                                aname      => 'ATTRIBUTE14',
                                avalue     => p_attribute14);

     wf_engine.SetItemAttrText   ( itemtype   => l_itemtype,
                                itemkey    => l_itemkey,
                                aname      => 'ATTRIBUTE15',
                                avalue     => p_attribute15);

     -----------------------------------------------------------
     -- Call the workflow Generate function to trigger off the
     -- workflow account generation
     -----------------------------------------------------------

     l_error_msg       := NULL;
     l_concat_segs     := NULL;
     l_concat_ids      := NULL;
     l_concat_descrs   := NULL;
     l_return_ccid     := NULL;

     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg(l_full_path, 'Submiting the AccGen WF ');
     END IF;

     l_result := fnd_flex_workflow.generate
              (
                itemtype        => l_itemtype        ,
                itemkey         => l_itemkey         ,
                insert_if_new   => l_insert_if_new   ,
                ccid            => l_return_ccid     ,
                concat_segs     => l_concat_segs     ,
                concat_ids      => l_concat_ids      ,
                concat_descrs   => l_concat_descrs   ,
                error_message   => l_error_msg       ,
                new_combination => l_new_combination
              );

     IF NOT l_result THEN
         --Errorout error.

        IF (g_debug_mode = 'Y') THEN
           Put_Debug_Msg(l_full_path, 'Result is invalid, error text: '||l_error_msg);
        END IF;

        message_token ('ITEM_KEY', l_itemkey);
        message_token ('ERR_TEXT', l_error_msg);

        IF l_itemtype = 'IGCACGNC' THEN
           add_message ('IGC', 'IGC_CC_CGEN_WF_ERR');
        ELSE
           add_message ('IGC', 'IGC_CC_BGEN_WF_ERR');
        END IF;


        RAISE FND_API.G_EXC_ERROR;

     END IF;

     IF (g_debug_mode = 'Y') THEN
        Put_Debug_Msg(l_full_path, 'Result is ccid: '||l_return_ccid);
     END IF;

     IF l_itemtype = 'IGCACGNC' THEN
        x_out_charge_ccid         := l_return_ccid ;
        x_out_charge_account_flex := l_concat_segs ;
        x_out_charge_account_desc := l_concat_descrs ;
     ELSE
        x_out_budget_ccid         := l_return_ccid ;
        x_out_budget_account_flex := l_concat_segs ;
        x_out_budget_account_desc := l_concat_descrs ;
     END IF;

  END LOOP;


  FND_MSG_PUB.Count_And_Get
  (       p_count  => x_msg_count ,
          p_data   => x_msg_data
  );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN

     x_return_status := FND_API.G_RET_STS_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                p_data  => x_msg_data);
    IF (g_excep_level >=  g_debug_level ) THEN
       FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_ERROR Exception Raised');
    END IF;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                p_data  => x_msg_data);
    IF (g_excep_level >=  g_debug_level ) THEN
       FND_LOG.STRING (g_excep_level,l_full_path,'FND_API.G_EXC_UNEXPECTED_ERROR Exception Raised');
    END IF;
   WHEN OTHERS THEN

     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                l_api_name);
     END IF;
     FND_MSG_PUB.Count_And_Get (p_count => x_msg_count,
                                p_data  => x_msg_data);
     IF ( g_unexp_level >= g_debug_level ) THEN
       FND_MESSAGE.SET_NAME('IGC','IGC_LOGGING_UNEXP_ERROR');
       FND_MESSAGE.SET_TOKEN('CODE',SQLCODE);
       FND_MESSAGE.SET_TOKEN('MSG',  SQLERRM);
       FND_LOG.MESSAGE ( g_unexp_level,l_full_path, TRUE);
     END IF;


END Generate_Account ;


--
-- Private Procedures
--
PROCEDURE Call_WF_API_to_set_Att (l_itemtype varchar2, l_itemkey varchar2, aname varchar2,
                                  avalue varchar2)
IS
BEGIN

        If avalue IS NOT NULL then
          wf_engine.SetItemAttrText (  itemtype   =>  l_itemtype,
                                       itemkey    =>  l_itemkey,
                                       aname      =>  aname,
                                       avalue     =>  avalue );
        end if;
END Call_WF_API_to_set_Att;
--
--
PROCEDURE Call_WF_API_to_set_no_Att (l_itemtype varchar2, l_itemkey varchar2, aname varchar2,
                                  avalue number)
IS
BEGIN

        If avalue IS NOT NULL then
          wf_engine.SetItemAttrNumber (  itemtype   =>  l_itemtype,
                                         itemkey    =>  l_itemkey,
                                         aname      =>  aname,
                                         avalue     =>  avalue );
        end if;
END Call_WF_API_to_set_no_Att;
--
--
PROCEDURE Call_WF_API_to_set_date_Att (l_itemtype varchar2, l_itemkey varchar2, aname varchar2,
                                  avalue date)
IS
BEGIN
        If avalue IS NOT NULL then
          wf_engine.SetItemAttrDate (  itemtype   =>  l_itemtype,
                                       itemkey    =>  l_itemkey,
                                       aname      =>  aname,
                                       avalue     =>  avalue );
        end if;
END Call_WF_API_to_set_date_Att;
--

PROCEDURE message_token(
   tokname IN VARCHAR2,
   tokval  IN VARCHAR2
) IS

BEGIN

  IGC_MSGS_PKG.message_token (p_tokname => tokname,
                              p_tokval  => tokval);

END message_token;


/****************************************************************************/

-- Sets the Message Stack
PROCEDURE Put_Debug_Msg (
   p_path      IN VARCHAR2,
   p_debug_msg IN VARCHAR2
) IS

-- Constants :

   /*l_return_status    VARCHAR2(1);*/
   l_api_name         CONSTANT VARCHAR2(30) := 'Put_Debug_Msg';

BEGIN


--   IF (IGC_MSGS_PKG.g_debug_mode) THEN
      /*IGC_MSGS_PKG.Put_Debug_Msg (l_full_path, p_debug_message    => p_debug_msg,
                                  p_profile_log_name => g_profile_name,
                                  p_prod             => 'IGC',
                                  p_sub_comp         => 'CC_ACCGEN',
                                  p_filename_val     => NULL,
                                  x_Return_Status    => l_return_status
                                 );
      IF (l_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
         raise FND_API.G_EXC_ERROR;
      END IF;*/
   IF(g_state_level >= g_debug_level) THEN
        FND_LOG.STRING(g_state_level, p_path, p_debug_msg);
   END IF;
--   END IF;

-- --------------------------------------------------------------------
-- Exception handler section for the Put_Debug_Msg procedure.
-- --------------------------------------------------------------------
EXCEPTION

   /*WHEN FND_API.G_EXC_ERROR THEN
       RETURN;*/

   WHEN OTHERS THEN
       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME, l_api_name);
       END IF;
	   NULL;
       RETURN;

END Put_Debug_Msg;


PROCEDURE add_message(
   appname IN VARCHAR2,
   msgname IN VARCHAR2
) IS

i  BINARY_INTEGER;
l_full_path         VARCHAR2(255);

BEGIN

   l_full_path := g_path || 'add_message';

   IGC_MSGS_PKG.add_message (p_appname => appname,
                             p_msgname => msgname);

   IF (g_debug_mode = 'Y') THEN
      Put_Debug_Msg(l_full_path, 'Raising an execution exception: '||fnd_msg_pub.get(1,FND_API.G_FALSE));
   END IF;

END add_message;

PROCEDURE Generate_Message
IS
l_cur                     NUMBER;
l_msg_count               NUMBER ;
l_msg_data                VARCHAR2(32000) ;
l_full_path               VARCHAR2(255);

BEGIN

  l_full_path := g_path || 'Generate_Message';

  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg(l_full_path, 'Error during the execution ');
  END IF;

  FND_MSG_PUB.Count_And_Get ( p_count => l_msg_count,
                              p_data  => l_msg_data );

  IF l_msg_count >0 THEN
     l_msg_data :='';

     FOR l_cur IN 1..l_msg_count LOOP
        --l_msg_data :=l_msg_data||' Mes No'||l_cur||' '||FND_MSG_PUB.GET(l_cur,FND_API.G_FALSE);
	l_msg_data :=l_msg_data||' '||l_cur||' '||FND_MSG_PUB.GET(l_cur,FND_API.G_FALSE);
	IF(g_error_level >= g_debug_level) THEN
           FND_LOG.STRING(g_error_level, l_full_path, l_msg_data);
	END IF;
     END LOOP;
  ELSE
     l_msg_data :='Error stack has no data';
       IF(g_error_level >= g_debug_level) THEN
           FND_LOG.STRING(g_error_level, l_full_path, l_msg_data);
       END IF;
  END IF;

  IF (g_debug_mode = 'Y') THEN
     Put_Debug_Msg(l_full_path, 'Error text is '||l_msg_data);
  END IF;

END Generate_Message;

BEGIN

  g_profile_name    := 'IGC_DEBUG_LOG_DIRECTORY';
  g_debug_mode    := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

--Variables for ATG Central logging
  g_debug_level  :=	FND_LOG.G_CURRENT_RUNTIME_LEVEL;
  g_state_level  :=	FND_LOG.LEVEL_STATEMENT;
  g_proc_level   :=	FND_LOG.LEVEL_PROCEDURE;
  g_event_level  :=	FND_LOG.LEVEL_EVENT;
  g_excep_level  :=	FND_LOG.LEVEL_EXCEPTION;
  g_error_level  :=	FND_LOG.LEVEL_ERROR;
  g_unexp_level  :=	FND_LOG.LEVEL_UNEXPECTED;
  g_path         := 'IGC.PLSQL.IGCCAGNB.IGC_CC_ACCGNWF_PKG.';

END IGC_CC_ACCGNWF_PKG;

/
