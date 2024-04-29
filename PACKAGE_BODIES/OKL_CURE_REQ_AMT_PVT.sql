--------------------------------------------------------
--  DDL for Package Body OKL_CURE_REQ_AMT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CURE_REQ_AMT_PVT" AS
/* $Header: OKLRCRKB.pls 120.3 2007/06/18 19:42:13 pdevaraj ship $ */


PROCEDURE update_cure_request(
            p_api_version    	    IN  NUMBER,
            p_init_msg_list         IN  VARCHAR2 ,
            x_return_status         OUT NOCOPY VARCHAR2,
            x_msg_count             OUT NOCOPY NUMBER,
            x_msg_data              OUT NOCOPY VARCHAR2,
            p_cure_req_tbl          IN         cure_req_tbl_type,
            x_cure_req_tbl          OUT NOCOPY cure_req_tbl_type) IS

    l_api_name	       VARCHAR2(30) := 'update_cure_request';
    l_api_version      CONSTANT NUMBER	  := 1.0;
    i				NUMBER;
    l_obj_vers_no		NUMBER;
    l_selected_on_request okl_cure_amounts.selected_on_request%type := null;
    lp_camv_tbl  okl_cure_amounts_pub.camv_tbl_type;
    lx_camv_tbl  okl_cure_amounts_pub.camv_tbl_type;

   Cursor get_obj_vers_no(l_cure_amount_id NUMBER) is
   select object_version_number, selected_on_request
   from okl_cure_amounts
   where cure_amount_id = l_cure_amount_id;


  BEGIN

    okl_debug_pub.logmessage('OKL_CURE_REQ_AMT_PVT: update_cure_request : START');

    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;


        If (p_cure_req_tbl.COUNT > 0) Then
    	 i := p_cure_req_tbl.FIRST;

    	   LOOP

            lp_camv_tbl(i).cure_amount_id := p_cure_req_tbl(i).cure_amount_id;
            lp_camv_tbl(i).crt_id := p_cure_req_tbl(i).CURE_REPORT_ID;
            lp_camv_tbl(i).object_version_number := null;


            l_obj_vers_no := null;
            l_selected_on_request := null;
	    open get_obj_vers_no(lp_camv_tbl(i).cure_amount_id);
	    fetch get_obj_vers_no into l_obj_vers_no, l_selected_on_request;
	    close get_obj_vers_no;

	    If ( p_cure_req_tbl(i).CURE_REPORT_ID is null ) Then
	    	lp_camv_tbl(i).selected_on_request := 'N';
	    Elsif (  p_cure_req_tbl(i).CURE_REPORT_ID is not null ) Then
	        lp_camv_tbl(i).selected_on_request := 'Y';
            End If;

	    if(l_obj_vers_no is not null) Then
	      lp_camv_tbl(i).object_version_number :=   l_obj_vers_no;
	    End If;

            If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
             raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
             raise OKC_API.G_EXCEPTION_ERROR;
            End If;

           EXIT WHEN (i = p_cure_req_tbl.LAST);
    		i := p_cure_req_tbl.NEXT(i);
    	   END LOOP;

	      okl_cure_amounts_pub.update_cure_amounts(
	        p_api_version    	=> p_api_version,
	        p_init_msg_list  	=> p_init_msg_list,
	        x_return_status  	=> x_return_status,
	        x_msg_count      	=> x_msg_count,
	        x_msg_data       	=> x_msg_data,
	        p_camv_tbl	        => lp_camv_tbl,
	   	x_camv_tbl		=> lx_camv_tbl
		);

    okl_debug_pub.logmessage('OKL_CURE_REQ_AMT_PVT: update_cure_request : okl_cure_amounts_pub.update_cure_amounts : '||x_return_status);

	      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
	         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
	         raise OKC_API.G_EXCEPTION_ERROR;
	      End If;

	End If;

  OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,	 x_msg_data	=> x_msg_data);

    okl_debug_pub.logmessage('OKL_CURE_REQ_AMT_PVT: update_cure_request : END');

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END;

PROCEDURE update_cure_request(
            p_api_version    	    IN  NUMBER,
            p_init_msg_list         IN  VARCHAR2 ,
            x_return_status         OUT NOCOPY VARCHAR2,
            x_msg_count             OUT NOCOPY NUMBER,
            x_msg_data              OUT NOCOPY VARCHAR2,
            p_vendor_id             IN  NUMBER,
            p_cure_report_id        IN  NUMBER) IS

    l_api_name	       VARCHAR2(30) := 'update_cure_request';
    l_api_version      CONSTANT NUMBER	  := 1.0;
    i				NUMBER := 0;
    l_cure_amt_id		NUMBER;
    l_obj_vers_no		NUMBER;

    lp_crtv_rec  okl_cure_reports_pub.crtv_rec_type;
    lx_crtv_rec  okl_cure_reports_pub.crtv_rec_type;

   Cursor upd_cure_amts_csr is
   select cure_amount_id
   from okl_cure_amounts ca, okl_cure_reports cr
   where ca.show_on_request = 'Y'
   and ca.status = 'CURESINPROGRESS'
   and cr.vendor_id = p_vendor_id
   and ca.selected_on_request = 'Y'
   and cr.cure_report_id = ca.crt_id;

   p_cure_req_tbl cure_req_tbl_type;

   Cursor get_obj_vers_no is
   select object_version_number
   from okl_cure_reports
   where cure_report_id = p_cure_report_id;

   --dkagrawa added following cursor for OA Migration
   CURSOR c_get_contract_count(c_cure_report_id IN NUMBER) IS
   SELECT COUNT(chr_id)
   FROM okl_cure_amounts
   WHERE crt_id = c_cure_report_id;

   l_count NUMBER;

  BEGIN

    okl_debug_pub.logmessage('OKL_CURE_REQ_AMT_PVT: update_cure_request : START');
    okl_debug_pub.logmessage('OKL_CURE_REQ_AMT_PVT: update_cure_request : p_vendor_id : '|| p_vendor_id);
    okl_debug_pub.logmessage('OKL_CURE_REQ_AMT_PVT: update_cure_request : p_cure_report_id : '|| p_cure_report_id);

    x_return_status := OKC_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => g_api_type,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
       raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
       raise OKC_API.G_EXCEPTION_ERROR;
    End If;
    --dkagrawa added the following start
    OPEN c_get_contract_count(p_cure_report_id);
    FETCH c_get_contract_count INTO l_count;
    CLOSE c_get_contract_count;
    IF (l_count = 0) THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => 'OKL_CURE_REQ_CONTRACTS');
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --dkagrawa end
/*
   lp_crtv_rec.cure_report_id := p_cure_report_id;
   lp_crtv_rec.approval_status := 'SUBMITTED';

   l_obj_vers_no := null;
   open get_obj_vers_no;
   fetch get_obj_vers_no into l_obj_vers_no;
   close get_obj_vers_no;

  lp_crtv_rec.object_version_number := l_obj_vers_no;

   okl_cure_reports_pub.update_cure_reports(
	        p_api_version    	=> p_api_version,
	        p_init_msg_list  	=> p_init_msg_list,
	        x_return_status  	=> x_return_status,
	        x_msg_count      	=> x_msg_count,
	        x_msg_data       	=> x_msg_data,
	        p_crtv_rec	        => lp_crtv_rec,
	   	x_crtv_rec		=> lx_crtv_rec
		);
    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
	         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
	         raise OKC_API.G_EXCEPTION_ERROR;
    End If;
*/
    okl_cure_wf.approve_cure_reports
             (  p_api_version          => p_api_version
               ,p_init_msg_list        => OKC_API.G_TRUE
               ,p_commit               => OKC_API.G_FALSE
               ,p_report_id            => p_cure_report_id
               ,x_return_status        => x_return_status
               ,x_msg_count            => x_msg_count
               ,x_msg_data             =>  x_msg_data );

    okl_debug_pub.logmessage('OKL_CURE_REQ_AMT_PVT: update_cure_request : okl_cure_wf.approve_cure_reports : '|| x_return_status);

    If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
	         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
	         raise OKC_API.G_EXCEPTION_ERROR;
    End If;

  OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,	 x_msg_data	=> x_msg_data);

    okl_debug_pub.logmessage('OKL_CURE_REQ_AMT_PVT: update_cure_request : END');

  EXCEPTION
    when OKC_API.G_EXCEPTION_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    when OTHERS then
      x_return_status := OKC_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END;

END OKL_CURE_REQ_AMT_PVT;

/
