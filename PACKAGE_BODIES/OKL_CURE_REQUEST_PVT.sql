--------------------------------------------------------
--  DDL for Package Body OKL_CURE_REQUEST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CURE_REQUEST_PVT" AS
/* $Header: OKLRREQB.pls 115.7 2003/10/10 19:00:27 jsanju noship $ */

  PROCEDURE SEND_CURE_REQUEST
  (
     errbuf               OUT NOCOPY VARCHAR2,
     retcode              OUT NOCOPY NUMBER,
     p_vendor_number      IN  NUMBER ,
     p_report_number      IN  VARCHAR2 ,
     p_report_date        IN  DATE
  )
  AS
    l_msg_count           NUMBER ;
    l_msg_data            VARCHAR2(2000);
    l_message             VARCHAR2(2000);
    l_api_version         CONSTANT NUMBER := 1;
    l_return_status       VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name            CONSTANT VARCHAR2(30) := 'Vendor Cure Request';

    l_rows_processed      NUMBER := 0;
    l_rows_failed         NUMBER := 0;
    l_vendor_notified     NUMBER := 0;
    l_vendor_not_notified NUMBER := 0;

    l_bind_var            JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
    l_bind_val            JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;
    l_bind_var_type       JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;

    l_vendor_id           HZ_PARTIES.PARTY_ID%TYPE;
    l_email               HZ_CONTACT_POINTS.EMAIL_ADDRESS%TYPE;
    l_subject             VARCHAR2(2000);
    l_content_id          JTF_AMV_ITEMS_B.ITEM_ID%TYPE;
    l_from                VARCHAR2(2000);
    l_agent_id            NUMBER;
    l_request_id          NUMBER;
    l_request_date        okl_cure_reports.report_date%TYPE := TRUNC(SYSDATE);
    l_request_number      okl_cure_reports.report_number%TYPE;

    l_organization_passed VARCHAR2(1) := OKL_API.G_TRUE;
    l_set_of_books_passed VARCHAR2(1) := OKL_API.G_TRUE;
    l_vendor_passed       VARCHAR2(1) := OKL_API.G_TRUE;
    l_contract_passed     VARCHAR2(1) := OKL_API.G_TRUE;

    l_current_date        DATE;
    l_msg_index_out       NUMBER :=0;

    subtype crtv_rec_type is OKL_cure_reports_pub.crtv_rec_type;
    l_crtv_rec   crtv_rec_type;
    lx_crtv_rec   crtv_rec_type;

    -- Get Report Data for Fulfilment
    CURSOR report_csr( l_report_date IN DATE
                      ,l_request_number IN VARCHAR2
                      ,l_vendor_id IN NUMBER)
    IS
      SELECT  crt.vendor_id
             ,crt.report_date
             ,pvs.email_address
             ,crt.report_number
             ,crt.cure_report_id
             ,crt.object_version_number
             ,crt.report_type
      FROM   OKL_cure_reports crt
            ,po_vendor_sites_all pvs
      WHERE  trunc(crt.report_date) = NVL(l_report_date , trunc(crt.report_date))
      AND    crt.report_number = NVL(l_request_number, crt.report_number)
      AND    crt.vendor_id = NVL(l_vendor_id,crt.vendor_id)
      AND    crt.vendor_site_id = pvs.vendor_site_id
      AND    crt.approval_status = 'APPROVED';

     Cursor c_get_content_id ( p_process_code IN VARCHAR2) IS
      SELECT jtf_amv_item_id, email_subject_line
      FROM okl_cs_process_tmplts_uv
      WHERE PTM_CODE=p_process_code;

 l_ptm_code VARCHAR2(100);

  BEGIN

         Fnd_File.PUT_LINE(Fnd_File.LOG,
                                 'Start of process');

        l_current_date := p_report_date;
        l_request_number := p_report_number;
        l_vendor_id := p_vendor_number;

        /*  l_subject := fnd_profile.value('OKL_CURE_REQUEST_SUBJECT');
	        l_content_id := to_number(fnd_profile.value('OKL_CURE_REQUEST_TEMPLATE'));
         */


         l_agent_id:= to_number(fnd_profile.value('OKL_FULFILLMENT_USER'));
         l_from := fnd_profile.value('OKL_EMAIL_IDENTITY');

         Fnd_File.PUT_LINE(Fnd_File.LOG,l_current_date|| 'Request ' ||
                                     l_request_number|| 'Vendor '||
                                     l_vendor_id );

         -- open cursor for requests to be processed
         FOR i IN report_csr(l_current_date, l_request_number, l_vendor_id)
         LOOP
              l_email := i.email_address;
         	  IF (l_email = OKL_API.G_MISS_CHAR OR l_email IS NULL) THEN
    	         RAISE G_MISSING_EMAIL_ID;
              END IF;
              Fnd_File.PUT_LINE(Fnd_File.LOG,'Email is '||l_email);

              IF l_return_status = OKL_API.G_RET_STS_SUCCESS THEN
                  l_bind_var(1) := 'p_report_id';
                  l_bind_val(1) := i.cure_report_id;
                  l_bind_var_type(1) := 'NUMBER';


               --10/07/03 jsanju
                -- if cure only, ptm_code ='COCURE'
                -- else if repurchase only ptm_code ='COCURP'
                --else if both cure and repurchase then ptm_code = 'COCARP'

                IF   i.report_type ='BOTH' THEN
                      l_ptm_code :='COCARP';
                ELSIF i.report_type ='CURE' THEN
                      l_ptm_code :='COCURE';
                ELSE l_ptm_code :=  'COCURP';

                END IF;

              OPEN  c_get_content_id  (l_ptm_code);
              FETCH c_get_content_id INTO l_content_id ,l_subject;
              CLOSE c_get_content_id;

              Fnd_File.PUT_LINE(Fnd_File.LOG,'Process Code '
                  ||l_ptm_code ||' content_id '|| l_content_id);

              IF l_content_id is Null THEN
       	            RAISE G_MISSING_TEMPLATE;
              END IF;

                  --call fulfillment
                 OKL_FULFILLMENT_PUB.create_fulfillment
                            (
                              p_api_version   => l_api_version,
                              p_init_msg_list => okl_api.G_TRUE,
                              p_agent_id      => l_agent_id,
                              p_content_id    => l_content_id,
                              p_from          => l_from,
                              p_subject       => l_subject,
                              p_email         => l_email,
                              p_bind_var      => l_bind_var,
                              p_bind_val      => l_bind_val,
                              p_bind_var_type => l_bind_var_type,
                              x_request_id    => l_request_id,
                              x_return_status => l_return_status,
                              x_msg_count     => l_msg_count,
                              x_msg_data      => l_msg_data
                            );
            -- If the return status is error write to log and proceed
            -- with the rest of the requests
            IF (l_return_status <> okl_api.G_RET_STS_SUCCESS) THEN
                 Fnd_File.PUT_LINE(Fnd_File.OUTPUT,
                    'Cure Request could not be sent for request = '
                      || i.report_number);
  	  	        IF l_msg_count IS NULL THEN
                    l_msg_count := 2;
               END IF;

               FOR i in 1..l_msg_count LOOP
                   fnd_msg_pub.get (
                             p_encoded => 'F',
                             p_data => l_msg_data,
                             p_msg_index_out => l_msg_index_out);
                 Fnd_File.PUT_LINE(Fnd_File.OUTPUT, l_msg_data);
        	   END LOOP;
 		  END IF;

          Fnd_File.PUT_LINE(Fnd_File.LOG,
                    'After calling okl_fulfill api and return status is'
                    || l_return_status);


            -- Return = SUCCESS - update report status to
            -- SENT_TO_VENDOR
            IF (l_return_status = okl_api.G_RET_STS_SUCCESS) THEN

              l_crtv_rec.approval_status :='SENT_TO_VENDOR';
              l_crtv_rec.cure_report_id  :=i.cure_report_id;
              l_crtv_rec.object_version_number := i.object_version_number;

		       OKL_cure_reports_pub.update_cure_reports(
                   p_api_version   => l_api_version
                  ,p_init_msg_list => okl_api.G_TRUE
                  ,x_return_status => l_return_status
                  ,x_msg_count     => l_msg_count
                  ,x_msg_data      => l_msg_data
                  ,p_crtv_rec      => l_crtv_rec
                  ,x_crtv_rec      => lx_crtv_rec);
            -- If the return status is error write to log and proceed
            -- with the rest of the requests
              IF (l_return_status <> okl_api.G_RET_STS_SUCCESS) THEN
                   Fnd_File.PUT_LINE(Fnd_File.OUTPUT,
                    'Cure Request Status could not be updated for request = '
                    || i.report_number);
                IF l_msg_count IS NULL THEN
                    l_msg_count := 2;
                END IF;
                FOR i in 1..l_msg_count LOOP
                  fnd_msg_pub.get (
                             p_encoded => 'F',
                             p_data => l_msg_data,
                             p_msg_index_out => l_msg_index_out);
                 Fnd_File.PUT_LINE(Fnd_File.OUTPUT, l_msg_data);
                END LOOP;
              END IF; --return_status of update cure reports
              Fnd_File.PUT_LINE(Fnd_File.LOG,
                   'After calling update cure reports and return status is'
                   || l_return_status);

            END IF;   --return of fulfil api
      END IF; --return of bind variable

      Fnd_File.PUT_LINE(Fnd_File.OUTPUT, 'Cure Request            = ' || i.report_number);
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT, 'Request sent for Vendor = ' || to_char(l_vendor_id));
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT, 'Request sent on Date    = ' || SYSDATE);
      l_return_status :=OKL_API.G_RET_STS_SUCCESS;

    END LOOP;

    retcode := 0;

  EXCEPTION
    WHEN G_MISSING_EMAIL_ID THEN
      IF report_csr%ISOPEN THEN
        CLOSE report_csr;
      END IF;

      errbuf   := 'G_MISSING_EMAIL_ID';
      retcode  := 1;
      FND_MESSAGE.SET_NAME('OKL', 'OKL_CO_MISSING_EMAIL_ID');
      --dbms_output.put_line(FND_MESSAGE.GET);
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT, FND_MESSAGE.GET );

    WHEN G_MISSING_TEMPLATE THEN
      IF report_csr%ISOPEN THEN
        CLOSE report_csr;
      END IF;

      errbuf   := 'G_MISSING_TEMPLATE';
      retcode  := 1;
      FND_MESSAGE.SET_NAME('OKL', 'OKL_CO_MISSING_FUL_TEMPLATE');
      --dbms_output.put_line(FND_MESSAGE.GET);
      Fnd_File.PUT_LINE(Fnd_File.OUTPUT, FND_MESSAGE.GET );

   WHEN OTHERS THEN
      IF report_csr%ISOPEN THEN
        CLOSE report_csr;
      END IF;

        FND_FILE.PUT_LINE (FND_FILE.OUTPUT, 'Error (OTHERS)IN SEND_CURE_REQUEST => '||SQLERRM);
        retcode :=2;
        errbuf :=SQLERRM;

  END SEND_CURE_REQUEST;

END OKL_CURE_REQUEST_PVT;


/
