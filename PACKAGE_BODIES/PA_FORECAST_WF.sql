--------------------------------------------------------
--  DDL for Package Body PA_FORECAST_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FORECAST_WF" AS
/* $Header: PAWFGFCB.pls 120.2 2006/03/22 20:39:09 nkumbi noship $*/

-- forward declarations ------------------------------------------------

PROCEDURE Set_Nf_Error_Msg_Attr (p_item_type IN VARCHAR2,
			         p_item_key  IN VARCHAR2,
				 p_msg_count IN NUMBER,
				 p_msg_data IN VARCHAR2
                                 ) ;

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------



--Name:               start_forecast_workflow
--Type:               Procedure
--Description:        This procedure intiates the forecast generation workflow
--
--Called subprograms: Various workflow procedures
--
--History:
--    26-MAR-01		jwhite		Created
--    23-Mar-06     nkumbi      Stubbed out the procedure as PAWFGPF workflow is obsolete in R12

PROCEDURE start_forecast_workflow(p_project_id		 IN      NUMBER
                                  , x_msg_count	         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 			          , x_msg_data	         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			          , x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                  )
IS

BEGIN

null;


END start_forecast_workflow;


--Name:               process_forecast
--Type:               Procedure
--Description:        This procedure calls a forecasting procedure to actually
--                    generate the project forecast.
--
--                    If the generate_forecast procedure is successful, the
--                    Resultout = 'T'. Other notification text varies,
--                    accordingly.
--
--                    Otherwise, the Resultout = 'F' and one or more
--                    error messages, up to five messages, is displayed on the
--                    notification. Other notification text varies,
--                    accordingly.
--
--                    The process_forecast procedure is called from the
--                    forecast generation workflow.
--
--Called subprograms:
--
--History:
--    26-MAR-01		jwhite		Created
--
PROCEDURE process_forecast(itemtype   IN  VARCHAR2
                          , itemkey   IN  VARCHAR2
                          , actid     IN  NUMBER
                          , funcmode  IN  VARCHAR2
                          , resultout OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                          )
IS

l_return_status           VARCHAR2(1)    :=NULL;
l_msg_count	          NUMBER         :=NULL;
l_msg_data	          VARCHAR2(2000) :=NULL;
l_msg_index_out           NUMBER         :=NULL;

l_project_id	          NUMBER         := NULL;
l_wf_started_by_username  VARCHAR2(100)   := NULL; /* Modified length from 30 to 100 for bug 3148857 */


l_msg_subj_text    VARCHAR2(2000) :=NULL;
l_msg_desc_text    VARCHAR2(2000) :=NULL;
/* Added */
l_wf_started_by_id NUMBER;
l_wf_started_by_resp_id NUMBER;
l_wf_started_by_appl_id NUMBER;
l_plan_processing_code PA_BUDGET_VERSIONS.PLAN_PROCESSING_CODE%TYPE;
l_fcst_err_url     VARCHAR2(600);
l_msg_err_text     VARCHAR2(100);



BEGIN

          -- Return if WF Not Running
  	   IF (funcmode <> wf_engine.eng_run) THEN
    	       resultout := wf_engine.eng_null;
    	       RETURN;
  	   END IF;


           -- Assume WF Success
           resultout := wf_engine.eng_completed||':'||'G';


           -- Get Required Runtime Parmeters from WF
           l_project_id := wf_engine.GetItemAttrNumber
			   (  itemtype => itemtype
                           ,  itemkey =>  itemkey
                           ,  aname => 'PROJECT_ID'
                           );
/* Added for the deferred process */

           l_wf_started_by_id := wf_engine.GetItemAttrNumber
			   (  itemtype => itemtype
                           ,  itemkey =>  itemkey
                           ,  aname => 'WORKFLOW_STARTED_BY_UID'
                           );

           l_wf_started_by_resp_id := wf_engine.GetItemAttrNumber
			   (  itemtype => itemtype
                           ,  itemkey =>  itemkey
                           ,  aname => 'WORKFLOW_STARTED_BY_RESP_ID'
                           );

           l_wf_started_by_appl_id := wf_engine.GetItemAttrNumber
			   (  itemtype => itemtype
                           ,  itemkey =>  itemkey
                           ,  aname => 'WORKFLOW_STARTED_BY_APPL_ID'
                           );

        FND_GLOBAL.Apps_Initialize ( user_id       => l_wf_started_by_id
                                    , resp_id      => l_wf_started_by_resp_id
                                    , resp_appl_id => l_wf_started_by_appl_id
                                    );
/* Added for the deferred process */

           --dbms_output.put_line ('call Generate Forecast------------------');

           -- Generate Project Forecast!!!--------------------------------
           PA_GENERATE_FORECAST_PUB.generate_forecast
                                    (p_project_id     => l_project_id
                                    , x_return_status => l_return_status
                                    , x_msg_count     => l_msg_count
                                    , x_msg_data      => l_msg_data
                                    );
           -- -------------------------------------------------------------

           --dbms_output.put_line ('-------l_return_status: '||l_return_status);
           --dbms_output.put_line ('-------l_msg_count:     '||to_char(l_msg_count));
           --dbms_output.put_line ('-------l_msg_data:      '||l_msg_data);

          /* The following code is added to set the subject and header as error
             if the PLAN_PROCESSING_CODE in budget version is set to E */
          -- Conditionally Populate NF MSG and Error Display Fields
           BEGIN
             SELECT PLAN_PROCESSING_CODE INTO l_plan_processing_code FROM
                  PA_BUDGET_VERSIONS
             WHERE
                  PROJECT_ID = l_project_id AND
                  BUDGET_TYPE_CODE = 'FORECASTING_BUDGET_TYPE';
           EXCEPTION
           WHEN NO_DATA_FOUND THEN
             l_plan_processing_code := 'G';
           WHEN OTHERS THEN
             l_plan_processing_code := 'G';
           END;
/*
           status G - success  and also set up level error ex. profile value missing
                  L - Line level error
                  U - Work flow error
*/
           IF l_return_status = FND_API.G_RET_STS_SUCCESS AND l_plan_processing_code = 'E' THEN
             resultout := wf_engine.eng_completed||':'||'L';
           ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
             resultout := wf_engine.eng_completed||':'||'G';
           END IF;


           IF (l_return_status = FND_API.G_RET_STS_SUCCESS) AND
                 l_plan_processing_code = 'G'
              THEN
              -- Success!

               FND_MESSAGE.SET_NAME ('PA','PA_NFSUBJ_FORECAST_SUCCESS');
	       l_msg_subj_text := FND_MESSAGE.GET;

	       FND_MESSAGE.SET_NAME ('PA','PA_NFDESC_FORECAST_SUCCESS');
	       l_msg_desc_text := FND_MESSAGE.GET;

              wf_engine.SetItemAttrText
			       ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname =>    'MSG_SUBJECT_FYI'
                               , avalue =>   l_msg_subj_text
                               );

              wf_engine.SetItemAttrText
			       ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname =>    'MSG_DESCRIPTION_FYI'
                               , avalue =>   l_msg_desc_text
                               );

           ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS AND
                 l_plan_processing_code = 'E'
             THEN
               FND_MESSAGE.SET_NAME ('PA','PA_NFSUBJ_FORECAST_FAILURE');
               l_msg_subj_text := FND_MESSAGE.GET;

               FND_MESSAGE.SET_NAME ('PA','PA_NFSUBJ_FCST_LINE_FAILURE');
               l_msg_desc_text := FND_MESSAGE.GET;

           -- Errors! Note that the WF only marked as failure if ORA error

              wf_engine.SetItemAttrText
			       ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname =>    'MSG_SUBJECT_FYI'
                               , avalue =>   l_msg_subj_text
                               );

              wf_engine.SetItemAttrText
			       ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname =>    'MSG_DESCRIPTION_FYI'
                               , avalue =>   l_msg_desc_text
                               );

             l_fcst_err_url :=
 'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=275&akRegionCode=PA_FCST_ERROR_LAYOUT&paProjectId='||l_project_id||'&paCallingFrom="Notification"';
/* Added for bug       to show the text ERRORS only if the process status is failure.  */

             wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey  => itemkey
                               , aname => 'FCST_ERROR_URL_INFO'
                               , avalue => l_fcst_err_url
                               );

              -- Conditionally Populate Error Messages and Related NF Display Fields


              -- Application errors. WF SUCCESS! Send Notification to Default WF User.

                    set_nf_error_msg_attr (p_item_type => itemtype,
			                  p_item_key  => itemkey,
				          p_msg_count => l_msg_count,
				          p_msg_data  => l_msg_data
                                          );

           ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN

              FND_MESSAGE.SET_NAME ('PA','PA_NFSUBJ_FORECAST_FAILURE');
	      l_msg_subj_text := FND_MESSAGE.GET;

	      FND_MESSAGE.SET_NAME ('PA','PA_NFDESC_FORECAST_FAILURE');
	      l_msg_desc_text := FND_MESSAGE.GET;

              wf_engine.SetItemAttrText
			       ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname =>    'MSG_SUBJECT_FYI'
                               , avalue =>   l_msg_subj_text
                               );

              wf_engine.SetItemAttrText
			       ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname =>    'MSG_DESCRIPTION_FYI'
                               , avalue =>   l_msg_desc_text
                               );


              -- Hard ORA error. WF FAILURE! Send Notification to Projects Sys Admin.

                   -- Populate ORA Message Text
                      set_nf_error_msg_attr (p_item_type => itemtype,
			                     p_item_key  => itemkey,
				             p_msg_count => l_msg_count,
				             p_msg_data  => l_msg_data
                                             );

                   -- Set WF Status for Failure. Route to Sys Admin
                   resultout := wf_engine.eng_completed||':'||'U';

           ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN

              FND_MESSAGE.SET_NAME ('PA','PA_NFSUBJ_FORECAST_FAILURE');
	      l_msg_subj_text := FND_MESSAGE.GET;

	      FND_MESSAGE.SET_NAME ('PA','PA_NFDESC_FORECAST_FAILURE');
	      l_msg_desc_text := FND_MESSAGE.GET;

              wf_engine.SetItemAttrText
			       ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname =>    'MSG_SUBJECT_FYI'
                               , avalue =>   l_msg_subj_text
                               );

              wf_engine.SetItemAttrText
			       ( itemtype => itemtype
                               , itemkey =>  itemkey
                               , aname =>    'MSG_DESCRIPTION_FYI'
                               , avalue =>   l_msg_desc_text
                               );

              FND_MESSAGE.SET_NAME ('PA','PA_NFERR_FCST');
              l_msg_err_text  := FND_MESSAGE.GET;

              wf_engine.SetItemAttrText
                              ( itemtype => itemtype
                               , itemkey => itemkey
                               , aname   => 'ERROR_COMMENTS'
                               , avalue  => l_msg_err_text
                               );

/*             wf_engine.SetItemAttrText
                               ( itemtype => itemtype
                               , itemkey  => itemkey
                               , aname => 'FCST_ERROR_URL_INFO'
                               , avalue => NULL
                               );  */

                    set_nf_error_msg_attr (p_item_type => itemtype,
			                  p_item_key  => itemkey,
				          p_msg_count => l_msg_count,
				          p_msg_data  => l_msg_data
                                          );
           END IF; --Conditionally Populate NF MSG and Errors





EXCEPTION
 WHEN OTHERS THEN
      WF_CORE.CONTEXT
		('PA_GENERATE_FORECAST_MP',
		 'Process_Forecast',
		  itemtype,
		  itemkey,
		  to_char(actid),
		  funcmode);
	 RAISE;

END process_forecast;



--Name:               set_nf_error_msg_attr
--Type:               Procedure
--Description:        This procedure populates the notificatin error message fields.
--
--Called subprograms: None.
--
--History:
--    26-MAR-01		jwhite		Cloned from PA_ASGMT_WFSTD package
--


PROCEDURE set_nf_error_msg_attr (p_item_type IN VARCHAR2,
			         p_item_key  IN VARCHAR2,
				 p_msg_count IN NUMBER,
				 p_msg_data IN VARCHAR2 ) IS

l_project_id       NUMBER := NULL;
l_msg_index_out	   NUMBER ;
l_msg_data	   VARCHAR2(2000);
l_data	           VARCHAR2(2000);
l_item_attr_name   VARCHAR2(30);
l_msg_err_text     VARCHAR2(100);
BEGIN
          IF p_msg_count = 0 THEN
	       RETURN;
          END IF;

	  IF p_msg_count = 1 THEN
	     IF p_msg_data IS NOT NULL THEN
                FND_MESSAGE.SET_ENCODED (p_msg_data);
                l_data := FND_MESSAGE.GET;
                wf_engine.SetItemAttrText
			       ( itemtype => p_item_type
                               , itemkey =>  p_item_key
                               , aname => 'ERROR_COMMENTS_1'
                               , avalue => l_data
                               );
	     END IF;
             RETURN ;
          END IF;

     	  IF p_msg_count > 1 THEN
              FOR i in 1..p_msg_count
	    LOOP
	      IF i > 5 THEN
	  	 EXIT;
	      END IF;
	      pa_interface_utils_pub.get_messages
		(p_encoded        => FND_API.G_FALSE,
 		 p_msg_index      => i,
                 p_msg_count      => p_msg_count ,
                 p_msg_data       => p_msg_data ,
                 p_data           => l_data,
                 p_msg_index_out  => l_msg_index_out );
                 l_item_attr_name := 'ERROR_COMMENTS_'||i;
                   wf_engine.SetItemAttrText
			       ( itemtype => p_item_type
                               , itemkey =>  p_item_key
                               , aname => l_item_attr_name
                               , avalue => l_data
                               );
            END LOOP;
	  END IF;
EXCEPTION
	WHEN OTHERS THEN RAISE;
END set_nf_error_msg_attr;



END pa_forecast_wf;

/
