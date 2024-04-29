--------------------------------------------------------
--  DDL for Package Body OKL_REQ_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_REQ_WF" AS
/* $Header: OKLRRQWB.pls 120.2 2006/07/11 09:57:10 dkagrawa noship $ */

  --------------------------------------------------------------------------
  ---- Concurrent API to invoke the workflow for requesting approval of a Cure
  ---- Currently not used as a concurrent process
  ---- Instead The call is made through the OKL_VENDOR_REFUND_PVT.REFUND API
  ---  which also calls another Cure and Repurchase workflow
  ---------------------------------------------------------------------------

   PROCEDURE invoke_workflow(
     errbuf                     OUT NOCOPY VARCHAR2,
     retcode                    OUT NOCOPY NUMBER)

    AS

     lx_msg_count               NUMBER ;
     lx_msg_data                VARCHAR2(2000);
     l_init_msg_list            VARCHAR2(1) := Okc_Api.G_FALSE ;
     l_api_version              CONSTANT NUMBER := 1;
     l_return_status            VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;


    -- Get Report data
    CURSOR get_request_csr
    IS
      SELECT cure_report_id
      FROM   OKL_CURE_REPORTS
      WHERE approval_status='COMPLETE';


    BEGIN
    /*    Processing Starts     */

    FOR i IN get_request_csr LOOP
    	raise_request_business_event(i.cure_report_id);
    END LOOP;

    /*    Processing Ends       */

    EXCEPTION
      WHEN OTHERS THEN
        errbuf   := substr(SQLERRM, 1, 200);
        retcode  := 1;
        Fnd_File.PUT_LINE(Fnd_File.OUTPUT, 'SQL ERROR : SQLCODE = ' || SQLCODE);
        Fnd_File.PUT_LINE(Fnd_File.OUTPUT, '            MESSAGE = ' || SQLERRM);
        ROLLBACK;
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END invoke_workflow;

  -------------------------------------------------------------------------
  -- PROCEDURE raise_request_business_event
  ---------------------------------------------------------------------------
  PROCEDURE raise_request_business_event (p_trans_id   IN NUMBER)
  AS
    l_parameter_list        wf_parameter_list_t;
    l_key                   varchar2(240);
    l_event_name            varchar2(240) := 'oracle.apps.OKL.requestapproval';
    l_seq                   NUMBER;

	CURSOR OKL_key_csr IS
	SELECT OKL_CURE_WF_S.nextval
	FROM  dual;

    BEGIN
      SAVEPOINT raise_request_business_event;

      OPEN OKL_key_csr;
	  FETCH OKL_key_csr INTO l_seq;
      CLOSE OKL_key_csr;

      l_key := l_event_name ||l_seq ;

      --'TRANS_ID' is the internal name of the attribute passed to WF
      wf_event.AddParameterToList('TRANS_ID', p_trans_id,l_parameter_list);

      -- Raise Event
      wf_event.raise(p_event_name => l_event_name
                    ,p_event_key   => l_key
                    ,p_parameters  => l_parameter_list);

      l_parameter_list.DELETE;

    EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('OKL', 'OKL_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
      ROLLBACK TO raise_request_business_event;
    END raise_request_business_event;


  -------------------------------------------------------------------------
  -- PROCEDURE populate_notif_attributes
  ---------------------------------------------------------------------------
  PROCEDURE populate_notif_attributes(itemtype        in varchar2,
                              itemkey         in varchar2,
                              actid           in number,
                              funcmode        in varchar2,
                              resultout       out nocopy varchar2) AS

    l_dummy           varchar(1) ;
    l_trans_id    	  NUMBER  ;
    l_return_status	  VARCHAR2(100);
    l_api_version	  NUMBER	:= 1.0;
    l_msg_count		  NUMBER;
    l_msg_data		  VARCHAR2(2000);
    l_obj_version     NUMBER ;
    l_report_number         VARCHAR2(150) ;
    l_vendor_id       NUMBER;
    l_report_date          DATE;
    l_vendor_contact_id   NUMBER;
    l_vendor_site_id      NUMBER;
    l_created_by          VARCHAR2(80);
    l_name              VARCHAR2(80);
    l_address           VARCHAR2(2000);
    l_contact           VARCHAR2(20);

    CURSOR report_dtls_csr (a_trans_id NUMBER)
    IS
	SELECT REPORT_NUMBER,REPORT_DATE,VENDOR_ID,VENDOR_CONTACT_ID,VENDOR_SITE_ID,CREATED_BY
	FROM OKL_CURE_REPORTS
	WHERE CURE_REPORT_ID=  a_trans_id;

    CURSOR vendor_csr (a_vendor_id NUMBER)
    IS
	SELECT VENDOR_NAME
	FROM PO_VENDORS
	WHERE VENDOR_ID = a_vendor_id;

    CURSOR location_csr (a_vendor_id NUMBER, a_vendor_site_id NUMBER)
    IS
	SELECT ADDRESS_LINE1 || ' '||
               ADDRESS_LINE2 || ' '||
               ADDRESS_LINE3 || ' '||
               CITY          || ' '||
               STATE         || ' '||
               ZIP           || ' '||
               PROVINCE      || ' '||
               COUNTRY AS Address
	FROM PO_VENDOR_SITES_ALL
	WHERE VENDOR_ID = a_vendor_id
	AND VENDOR_SITE_ID = a_vendor_site_id;

    CURSOR contact_csr (a_vendor_contact_id NUMBER)
    IS
	SELECT PREFIX     || ' '||
	       FIRST_NAME || ' '||
	       LAST_NAME AS VENDOR_CONTACT
	FROM PO_VENDOR_CONTACTS
	WHERE  VENDOR_CONTACT_ID = a_vendor_contact_id;

    CURSOR notif_mgr_csr(a_trans_id NUMBER)
    IS
         SELECT b.user_name
         FROM JTF_RS_RESOURCE_EXTNS a,
              JTF_RS_RESOURCE_EXTNS b
         WHERE b.source_id = a.source_mgr_id
         AND   a.user_id
         IN
           (SELECT created_by
    	    FROM OKL_CURE_REPORTS
	        WHERE CURE_REPORT_ID = a_trans_id);

  BEGIN
    	IF (funcmode = 'RUN') then
            l_trans_id := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                       	            itemkey	=> itemkey,
                                                   aname  	=>'TRANS_ID');


	        OPEN report_dtls_csr(l_trans_id);
        	FETCH report_dtls_csr INTO l_report_number,l_report_date,l_vendor_id,l_vendor_contact_id,l_vendor_site_id,l_created_by;
        	CLOSE report_dtls_csr;

    		OPEN vendor_csr(l_vendor_id);
	    	FETCH vendor_csr INTO l_name;
    		CLOSE vendor_csr;

        	OPEN location_csr(l_vendor_id,l_vendor_site_id);
	        FETCH location_csr INTO l_address;
  	        CLOSE location_csr;


        	OPEN contact_csr(l_vendor_contact_id);
            FETCH contact_csr INTO l_contact;
            CLOSE contact_csr;

    		OPEN notif_mgr_csr(l_trans_id);
	        FETCH notif_mgr_csr INTO l_created_by;
            CLOSE notif_mgr_csr;


        	IF(l_return_status <> Fnd_Api.G_RET_STS_SUCCESS) THEN
                raise G_EXCEPTION_HALT_VALIDATION;
                END IF;

            wf_engine.SetItemAttrDate (itemtype=> itemtype,
			                           itemkey => itemkey,
                        			     aname   => 'REPORT_DATE',
                        			     avalue  => l_report_date);

            wf_engine.SetItemAttrText (itemtype=> itemtype,
			                             itemkey => itemkey,
                        			     aname   => 'REPORT_NUMBER',
                        			     avalue  => l_report_number);

            wf_engine.SetItemAttrText (itemtype=> itemtype,
                			     itemkey => itemkey,
			                     aname   => 'VENDOR_NAME',
                			     avalue  => l_name);

            wf_engine.SetItemAttrText (itemtype=> itemtype,
                    			         itemkey => itemkey,
			                             aname   => 'VENDOR_LOCATION',
                        			     avalue  => l_address);

            wf_engine.SetItemAttrText (itemtype=> itemtype,
			                             itemkey => itemkey,
                       			         aname   => 'VENDOR_CONTACT',
                        			     avalue  => l_contact);

            wf_engine.SetItemAttrText(itemtype  => itemtype,
                                     itemkey   => itemkey,
                                     aname     => 'NOTIFICATION_MGRNAME',
                                     avalue    =>  l_created_by );


	    resultout := 'COMPLETE:YES';
         	RETURN;
    	END IF;
        --
        -- CANCEL mode
        --
        if (funcmode = 'CANCEL') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;
        --
        -- TIMEOUT mode
        --
        if (funcmode = 'TIMEOUT') then
                --
                resultout := 'COMPLETE:';
                return;
                --
        end if;

  EXCEPTION
    when others then
       --resultout := wf_engine.eng_completed ||':'||wf_no;
       wf_core.context('OKL_CO_WF','populate_notif_attributes',itemtype,
                   itemkey,to_char(actid),funcmode);
       raise;
  END populate_notif_attributes;

---------------------------------------------------------------------------
  -- PROCEDURE Request_Rejected
---------------------------------------------------------------------------

  PROCEDURE Request_Rejected(itemtype	in varchar2,
              				itemkey  	in varchar2,
		            		actid		in number,
				            funcmode	in varchar2,
				            resultout out nocopy varchar2)
  IS
    l_dummy           varchar(1) ;
    l_trans_id    	  NUMBER  ;
    l_return_status	  VARCHAR2(100);
    l_api_version	  NUMBER	:= 1.0;
    l_msg_count		  NUMBER;
    l_msg_data		  VARCHAR2(2000);
    l_obj_version     NUMBER ;
    l_report         VARCHAR2(150) ;
    l_vendor_id       NUMBER;
    l_date          DATE;


    --A PL/SQl table type
    l_crtv_rec  OKL_crt_pvt.crtv_rec_type;
    lx_crtv_rec OKL_crt_pvt.crtv_rec_type;


    CURSOR approval_csr (a_trans_id NUMBER)
    IS
	SELECT REPORT_NUMBER,REPORT_DATE,VENDOR_ID,OBJECT_VERSION_NUMBER
	FROM OKL_CURE_REPORTS
	WHERE CURE_REPORT_ID=  a_trans_id;


    BEGIN

      IF (funcmode = 'RUN') then
      l_trans_id := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                       	      itemkey	=> itemkey,
                                             aname  	=>'TRANS_ID');

      OPEN approval_csr(l_trans_id);
      FETCH approval_csr INTO l_report,l_date,l_vendor_id,l_obj_version;
      CLOSE approval_csr;

      -- This will set the status
      l_crtv_rec.APPROVAL_STATUS := 'REJECTED';
      l_crtv_rec.CURE_REPORT_ID := l_trans_id;
      l_crtv_rec.OBJECT_VERSION_NUMBER  := l_obj_version;
      l_crtv_rec.REPORT_NUMBER        := l_report ;
      l_crtv_rec.VENDOR_ID        := l_vendor_id ;
      l_crtv_rec.REPORT_DATE        := l_date ;

      --Now inserting the populated table of records above
       OKL_cure_reports_pub.update_cure_reports(
                             p_api_version => l_api_version
                            ,p_init_msg_list => fnd_api.g_false
                            ,x_return_status => l_return_status
                            ,x_msg_count => l_msg_count
                            ,x_msg_data => l_msg_data
                            ,p_crtv_rec => l_crtv_rec
                            ,x_crtv_rec => lx_crtv_rec);



        resultout := 'COMPLETE:YES';
        RETURN;
      END IF;

      IF (funcmode = 'CANCEL') then
        resultout := 'COMPLETE:NO';
      END IF;

      -- TIMEOUT mode
      IF (funcmode = 'TIMEOUT') then
        resultout := 'COMPLETE:YES';
        return ;
      END IF;

      EXCEPTION
	    when others then
	      wf_core.context('OKL_REQ_WF',' Request_Rejected ',
                        itemtype,
		                itemkey,
		                to_char(actid),
		                funcmode);
	    RAISE;
  END Request_Rejected;

---------------------------------------------------------------------------
  -- PROCEDURE Request_Approved
---------------------------------------------------------------------------

  PROCEDURE Request_Approved(itemtype	in varchar2,
              		         itemkey  	in varchar2,
		                     actid		in number,
			                 funcmode	in varchar2,
			                 resultout out nocopy varchar2)
  IS
    l_dummy           varchar(1) ;
    l_trans_id    	  NUMBER ;
    l_return_status	  VARCHAR2(100);
    l_api_version	  NUMBER	:= 1.0;
    l_msg_count		  NUMBER;
    l_msg_data		  VARCHAR2(2000);
    l_obj_version     NUMBER ;
    l_report         VARCHAR2(150) ;
    l_vendor_id       NUMBER;
    l_date          DATE;


    --A PL/SQl table type
    l_crtv_rec  OKL_crt_pvt.crtv_rec_type;
    lx_crtv_rec OKL_crt_pvt.crtv_rec_type;


    CURSOR approval_csr (a_trans_id NUMBER)
    IS
	SELECT REPORT_NUMBER,REPORT_DATE,VENDOR_ID,OBJECT_VERSION_NUMBER
	FROM OKL_CURE_REPORTS
	WHERE CURE_REPORT_ID=  a_trans_id;


    BEGIN
      IF (funcmode = 'RUN') then
      l_trans_id := wf_engine.GetItemAttrText(itemtype  => itemtype,
                                       	      itemkey	=> itemkey,
                                              aname  	=>'TRANS_ID');

      OPEN approval_csr(l_trans_id);
      FETCH approval_csr INTO l_report,l_date,l_vendor_id,l_obj_version;
      CLOSE approval_csr;

      -- This will set the status
      l_crtv_rec.APPROVAL_STATUS := 'APPROVED';
      l_crtv_rec.CURE_REPORT_ID := l_trans_id;
      l_crtv_rec.OBJECT_VERSION_NUMBER  := l_obj_version;
      l_crtv_rec.REPORT_NUMBER        := l_report ;
      l_crtv_rec.VENDOR_ID        := l_vendor_id ;
      l_crtv_rec.REPORT_DATE        := l_date ;


      --Now inserting the populated table of records above
       OKL_cure_reports_pub.update_cure_reports(
                             p_api_version => l_api_version
                            ,p_init_msg_list => fnd_api.g_false
                            ,x_return_status => l_return_status
                            ,x_msg_count => l_msg_count
                            ,x_msg_data => l_msg_data
                            ,p_crtv_rec => l_crtv_rec
                            ,x_crtv_rec => lx_crtv_rec);

        resultout := 'COMPLETE:YES';
        RETURN;
      END IF;

      IF (funcmode = 'CANCEL') then
        resultout := 'COMPLETE:NO';
      END IF;

      -- TIMEOUT mode
      IF (funcmode = 'TIMEOUT') then
        resultout := 'COMPLETE:YES';
        return ;
      END IF;

      EXCEPTION
	    when others then
	      wf_core.context('OKL_REQ_WF',' Request_Approved ',
                        itemtype,
		                itemkey,
		                to_char(actid),
		                funcmode);
	    RAISE;
  END Request_Approved;

END OKL_REQ_WF;


/
