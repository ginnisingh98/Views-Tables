--------------------------------------------------------
--  DDL for Package Body OKL_CURE_VNDR_RFND_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CURE_VNDR_RFND_PVT" AS
/* $Header: OKLRRFSB.pls 115.1 2003/04/25 14:28:24 jsanju noship $ */

PROCEDURE create_cure_refund(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_cure_rfnd_tbl          IN  cure_rfnd_tbl_type,
            x_cure_rfnd_tbl          OUT NOCOPY cure_rfnd_tbl_type
) IS

    l_api_name	       VARCHAR2(30) := 'create_cure_refund';
    l_api_version      CONSTANT NUMBER	  := 1.0;
    i				NUMBER;

    l_tot_received_amount okl_cure_refunds.received_amount%type := 0;
    l_tot_offset_amount okl_cure_refunds.offset_amount%type := 0;
    l_tot_disbursement_amount okl_cure_refunds.disbursement_amount%type := 0;

    lp_chdv_rec  OKL_cure_rfnd_hdr_pub.chdv_rec_type;
    lx_chdv_rec  OKL_cure_rfnd_hdr_pub.chdv_rec_type;

    lp_crfv_tbl  OKL_cure_refunds_pub.crfv_tbl_type;
    lx_crfv_tbl  OKL_cure_refunds_pub.crfv_tbl_type;

    lp_crsv_tbl  OKL_cure_rfnd_stage_pub.crsv_tbl_type;
    lx_crsv_tbl  OKL_cure_rfnd_stage_pub.crsv_tbl_type;

    l_obj_vers_no		NUMBER;

    Cursor get_obj_vers_no(l_cure_refund_header_id NUMBER) is
     select object_version_number
     from OKL_CURE_REFUND_HEADERS_B
     where cure_refund_header_id = l_cure_refund_header_id;

    Cursor get_hdr_amounts_csr(l_cure_refund_header_id NUMBER) is
     select sum(received_amount),sum(offset_amount), sum(disbursement_amount)
     from OKL_CURE_REFUNDS
     where cure_refund_header_id = l_cure_refund_header_id;

  BEGIN

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

    If (p_cure_rfnd_tbl.COUNT > 0) Then
        	 i := p_cure_rfnd_tbl.FIRST;
             -- refund header info
    		lp_chdv_rec.cure_refund_header_id := p_cure_rfnd_tbl(i).cure_refund_header_id;
             -- lp_chdv_rec.object_version_number := p_cure_rfnd_tbl(i).rh_object_version_number;

           LOOP

             -- lines info
                lp_crfv_tbl(i).cure_refund_id := p_cure_rfnd_tbl(i).cure_refund_line_id;
                lp_crfv_tbl(i).cure_refund_header_id := p_cure_rfnd_tbl(i).cure_refund_header_id;
                lp_crfv_tbl(i).cure_refund_stage_id := p_cure_rfnd_tbl(i).cure_refund_stage_id;
                lp_crfv_tbl(i).object_version_number := p_cure_rfnd_tbl(i).rl_object_version_number;
                lp_crfv_tbl(i).chr_id := p_cure_rfnd_tbl(i).chr_id;
                lp_crfv_tbl(i).received_amount := p_cure_rfnd_tbl(i).received_amount;
                lp_crfv_tbl(i).offset_contract := p_cure_rfnd_tbl(i).offset_contract_id;
                lp_crfv_tbl(i).offset_amount := p_cure_rfnd_tbl(i).offset_amount;

                lp_crfv_tbl(i).disbursement_amount := p_cure_rfnd_tbl(i).received_amount - nvl(p_cure_rfnd_tbl(i).offset_amount,0);

                   If (nvl(p_cure_rfnd_tbl(i).offset_amount,0) > p_cure_rfnd_tbl(i).received_amount) Then
	                x_return_status := OKC_API.g_ret_sts_error;
	                OKC_API.SET_MESSAGE( p_app_name => g_app_name
	  				     , p_msg_name => 'OKL_CURE_RFND_OFST_CHK'
	  			   );
			raise OKC_API.G_EXCEPTION_ERROR;
                   End If;

             -- refund stage info
    		lp_crsv_tbl(i).cure_refund_stage_id := p_cure_rfnd_tbl(i).cure_refund_stage_id;
                lp_crsv_tbl(i).object_version_number := p_cure_rfnd_tbl(i).rs_object_version_number;
                lp_crsv_tbl(i).status := 'SELECTED';

               EXIT WHEN (i = p_cure_rfnd_tbl.LAST);
       		i := p_cure_rfnd_tbl.NEXT(i);
       	   END LOOP;

    	   -- refund lines info

           OKL_cure_refunds_pub.insert_cure_refunds(
	        p_api_version    	=> p_api_version,
	        p_init_msg_list  	=> p_init_msg_list,
	        x_return_status  	=> x_return_status,
	        x_msg_count      	=> x_msg_count,
	        x_msg_data       	=> x_msg_data,
	        p_crfv_tbl	        => lp_crfv_tbl,
	   	x_crfv_tbl		=> lx_crfv_tbl
		);

    	      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
    	         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
    	         raise OKC_API.G_EXCEPTION_ERROR;
    	      End If;

    	    -- refund header info

            l_obj_vers_no := null;
	    open get_obj_vers_no(lp_chdv_rec.cure_refund_header_id);
	    fetch get_obj_vers_no into l_obj_vers_no;
	    close get_obj_vers_no;

	    if(l_obj_vers_no is not null) Then
	      lp_chdv_rec.object_version_number :=   l_obj_vers_no;
	    End If;

	    open get_hdr_amounts_csr(lp_chdv_rec.cure_refund_header_id);
	    fetch get_hdr_amounts_csr into l_tot_received_amount, l_tot_offset_amount, l_tot_disbursement_amount;
	    close get_hdr_amounts_csr;

	    lp_chdv_rec.received_amount := l_tot_received_amount;
	    lp_chdv_rec.offset_amount := l_tot_offset_amount;
	    lp_chdv_rec.disbursement_amount := l_tot_disbursement_amount;

            OKL_cure_rfnd_hdr_pub.update_cure_rfnd_hdr(
	        p_api_version    	=> p_api_version,
	        p_init_msg_list  	=> p_init_msg_list,
	        x_return_status  	=> x_return_status,
	        x_msg_count      	=> x_msg_count,
	        x_msg_data       	=> x_msg_data,
	        p_chdv_rec	        => lp_chdv_rec,
	   	x_chdv_rec		=> lx_chdv_rec
		);

	      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
		         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
		         raise OKC_API.G_EXCEPTION_ERROR;
	      End If;

    	   -- refund stage info

            OKL_cure_rfnd_stage_pub.update_cure_refunds(
	        p_api_version    	=> p_api_version,
	        p_init_msg_list  	=> p_init_msg_list,
	        x_return_status  	=> x_return_status,
	        x_msg_count      	=> x_msg_count,
	        x_msg_data       	=> x_msg_data,
	        p_crsv_tbl	        => lp_crsv_tbl,
	   	x_crsv_tbl		=> lx_crsv_tbl
		);

	      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
		         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
		         raise OKC_API.G_EXCEPTION_ERROR;
	      End If;

    End If;


  OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,	 x_msg_data	=> x_msg_data);

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

PROCEDURE update_cure_refund(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_cure_rfnd_tbl          IN  cure_rfnd_tbl_type,
            x_cure_rfnd_tbl          OUT NOCOPY cure_rfnd_tbl_type
) IS

    l_api_name	       VARCHAR2(30) := 'update_cure_refund';
    l_api_version      CONSTANT NUMBER	  := 1.0;
    i				NUMBER;

    lp_chdv_rec  OKL_cure_rfnd_hdr_pub.chdv_rec_type;
    lx_chdv_rec  OKL_cure_rfnd_hdr_pub.chdv_rec_type;

    lp_crfv_tbl  OKL_cure_refunds_pub.crfv_tbl_type;
    lx_crfv_tbl  OKL_cure_refunds_pub.crfv_tbl_type;

    lp_crsv_tbl  OKL_cure_rfnd_stage_pub.crsv_tbl_type;
    lx_crsv_tbl  OKL_cure_rfnd_stage_pub.crsv_tbl_type;

    l_obj_vers_no		NUMBER;

    l_tot_received_amount okl_cure_refunds.received_amount%type := 0;
    l_tot_offset_amount okl_cure_refunds.offset_amount%type := 0;
    l_tot_disbursement_amount okl_cure_refunds.disbursement_amount%type := 0;

    Cursor get_obj_vers_no(l_cure_refund_header_id NUMBER) is
     select object_version_number
     from OKL_CURE_REFUND_HEADERS_B
     where cure_refund_header_id = l_cure_refund_header_id;

    Cursor get_hdr_amounts_csr(l_cure_refund_header_id NUMBER) is
     select sum(received_amount),sum(offset_amount), sum(disbursement_amount)
     from OKL_CURE_REFUNDS
     where cure_refund_header_id = l_cure_refund_header_id;

  BEGIN

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


    If (p_cure_rfnd_tbl.COUNT > 0) Then
        	 i := p_cure_rfnd_tbl.FIRST;
             -- refund header info
    		lp_chdv_rec.cure_refund_header_id := p_cure_rfnd_tbl(i).cure_refund_header_id;
             -- lp_chdv_rec.object_version_number := p_cure_rfnd_tbl(i).rh_object_version_number;

           LOOP

             -- lines info
                lp_crfv_tbl(i).cure_refund_id := p_cure_rfnd_tbl(i).cure_refund_line_id;
                lp_crfv_tbl(i).cure_refund_header_id := p_cure_rfnd_tbl(i).cure_refund_header_id;
                lp_crfv_tbl(i).cure_refund_stage_id := p_cure_rfnd_tbl(i).cure_refund_stage_id;
                lp_crfv_tbl(i).object_version_number := p_cure_rfnd_tbl(i).rl_object_version_number;
                lp_crfv_tbl(i).chr_id := p_cure_rfnd_tbl(i).chr_id;
                lp_crfv_tbl(i).received_amount := p_cure_rfnd_tbl(i).received_amount;
                lp_crfv_tbl(i).offset_contract := p_cure_rfnd_tbl(i).offset_contract_id;
                lp_crfv_tbl(i).offset_amount := p_cure_rfnd_tbl(i).offset_amount;

                lp_crfv_tbl(i).disbursement_amount := p_cure_rfnd_tbl(i).received_amount - nvl(p_cure_rfnd_tbl(i).offset_amount,0);

                   If (nvl(p_cure_rfnd_tbl(i).offset_amount,0) > p_cure_rfnd_tbl(i).received_amount) Then
	                x_return_status := OKC_API.g_ret_sts_error;
	                OKC_API.SET_MESSAGE( p_app_name => g_app_name
	  				     , p_msg_name => 'OKL_CURE_RFND_OFST_CHK'
	  			   );
			raise OKC_API.G_EXCEPTION_ERROR;
                   End If;

             -- refund stage info
    		lp_crsv_tbl(i).cure_refund_stage_id := p_cure_rfnd_tbl(i).cure_refund_stage_id;
                lp_crsv_tbl(i).object_version_number := p_cure_rfnd_tbl(i).rs_object_version_number;
                lp_crsv_tbl(i).status := 'SELECTED';

               EXIT WHEN (i = p_cure_rfnd_tbl.LAST);
       		i := p_cure_rfnd_tbl.NEXT(i);
       	   END LOOP;

    	   -- refund lines info

           OKL_cure_refunds_pub.update_cure_refunds(
	        p_api_version    	=> p_api_version,
	        p_init_msg_list  	=> p_init_msg_list,
	        x_return_status  	=> x_return_status,
	        x_msg_count      	=> x_msg_count,
	        x_msg_data       	=> x_msg_data,
	        p_crfv_tbl	        => lp_crfv_tbl,
	   	x_crfv_tbl		=> lx_crfv_tbl
		);

    	      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
    	         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
    	         raise OKC_API.G_EXCEPTION_ERROR;
    	      End If;

    	    -- refund header info

            l_obj_vers_no := null;
	    open get_obj_vers_no(lp_chdv_rec.cure_refund_header_id);
	    fetch get_obj_vers_no into l_obj_vers_no;
	    close get_obj_vers_no;

	    if(l_obj_vers_no is not null) Then
	      lp_chdv_rec.object_version_number :=   l_obj_vers_no;
	    End If;

	    open get_hdr_amounts_csr(lp_chdv_rec.cure_refund_header_id);
	    fetch get_hdr_amounts_csr into l_tot_received_amount, l_tot_offset_amount, l_tot_disbursement_amount;
	    close get_hdr_amounts_csr;

	    lp_chdv_rec.received_amount := l_tot_received_amount;
	    lp_chdv_rec.offset_amount := l_tot_offset_amount;
	    lp_chdv_rec.disbursement_amount := l_tot_disbursement_amount;

            OKL_cure_rfnd_hdr_pub.update_cure_rfnd_hdr(
	        p_api_version    	=> p_api_version,
	        p_init_msg_list  	=> p_init_msg_list,
	        x_return_status  	=> x_return_status,
	        x_msg_count      	=> x_msg_count,
	        x_msg_data       	=> x_msg_data,
	        p_chdv_rec	        => lp_chdv_rec,
	   	x_chdv_rec		=> lx_chdv_rec
		);

	      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
		         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
		         raise OKC_API.G_EXCEPTION_ERROR;
	      End If;

    	   -- refund stage info

            OKL_cure_rfnd_stage_pub.update_cure_refunds(
	        p_api_version    	=> p_api_version,
	        p_init_msg_list  	=> p_init_msg_list,
	        x_return_status  	=> x_return_status,
	        x_msg_count      	=> x_msg_count,
	        x_msg_data       	=> x_msg_data,
	        p_crsv_tbl	        => lp_crsv_tbl,
	   	x_crsv_tbl		=> lx_crsv_tbl
		);

	      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
		         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
		         raise OKC_API.G_EXCEPTION_ERROR;
	      End If;

    End If;

  OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,	 x_msg_data	=> x_msg_data);

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

PROCEDURE delete_cure_refund(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 ,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_cure_rfnd_tbl         IN  cure_rfnd_tbl_type
) IS

    l_api_name	       VARCHAR2(30) := 'delete_cure_refund';
    l_api_version      CONSTANT NUMBER	  := 1.0;
    i				NUMBER;

    l_received_amount okl_cure_refunds.received_amount%type := 0;
    l_offset_amount okl_cure_refunds.offset_amount%type := 0;

    l_tot_received_amount okl_cure_refunds.received_amount%type := 0;
    l_tot_offset_amount okl_cure_refunds.offset_amount%type := 0;

    lp_chdv_rec  OKL_cure_rfnd_hdr_pub.chdv_rec_type;
    lx_chdv_rec  OKL_cure_rfnd_hdr_pub.chdv_rec_type;

    lp_crfv_tbl  OKL_cure_refunds_pub.crfv_tbl_type;
    lx_crfv_tbl  OKL_cure_refunds_pub.crfv_tbl_type;

    lp_crsv_tbl  OKL_cure_rfnd_stage_pub.crsv_tbl_type;
    lx_crsv_tbl  OKL_cure_rfnd_stage_pub.crsv_tbl_type;

    l_obj_vers_no		NUMBER;

    Cursor get_obj_vers_no(l_cure_refund_header_id NUMBER) is
     select object_version_number
     from OKL_CURE_REFUND_HEADERS_B
     where cure_refund_header_id = l_cure_refund_header_id;

    Cursor get_hdr_amounts_csr(l_cure_refund_header_id NUMBER) is
     select sum(received_amount),sum(offset_amount)
     from OKL_CURE_REFUNDS
     where cure_refund_header_id = l_cure_refund_header_id;

  BEGIN

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

    If (p_cure_rfnd_tbl.COUNT > 0) Then
        	 i := p_cure_rfnd_tbl.FIRST;
             -- refund header info
    		lp_chdv_rec.cure_refund_header_id := p_cure_rfnd_tbl(i).cure_refund_header_id;
             -- lp_chdv_rec.object_version_number := p_cure_rfnd_tbl(i).rh_object_version_number;

           LOOP

             -- lines info
                lp_crfv_tbl(i).cure_refund_id := p_cure_rfnd_tbl(i).cure_refund_line_id;
                lp_crfv_tbl(i).cure_refund_header_id := p_cure_rfnd_tbl(i).cure_refund_header_id;
                lp_crfv_tbl(i).cure_refund_stage_id := p_cure_rfnd_tbl(i).cure_refund_stage_id;
                lp_crfv_tbl(i).object_version_number := p_cure_rfnd_tbl(i).rl_object_version_number;
                lp_crfv_tbl(i).chr_id := p_cure_rfnd_tbl(i).chr_id;
                lp_crfv_tbl(i).received_amount := p_cure_rfnd_tbl(i).received_amount;
                lp_crfv_tbl(i).offset_contract := p_cure_rfnd_tbl(i).offset_contract_id;
                lp_crfv_tbl(i).offset_amount := p_cure_rfnd_tbl(i).offset_amount;

    		lp_crsv_tbl(i).cure_refund_stage_id := p_cure_rfnd_tbl(i).cure_refund_stage_id;
                lp_crsv_tbl(i).object_version_number := p_cure_rfnd_tbl(i).rs_object_version_number;
                lp_crsv_tbl(i).status := 'ENTERED';

           EXIT WHEN (i = p_cure_rfnd_tbl.LAST);
       		i := p_cure_rfnd_tbl.NEXT(i);

       	   END LOOP;

    	   -- refund lines info

           OKL_cure_refunds_pub.delete_cure_refunds(
	        p_api_version    	=> p_api_version,
	        p_init_msg_list  	=> p_init_msg_list,
	        x_return_status  	=> x_return_status,
	        x_msg_count      	=> x_msg_count,
	        x_msg_data       	=> x_msg_data,
	        p_crfv_tbl	        => lp_crfv_tbl
		);

    	      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
    	         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
    	         raise OKC_API.G_EXCEPTION_ERROR;
    	      End If;

    	    -- refund header info

            l_obj_vers_no := null;
	    open get_obj_vers_no(lp_chdv_rec.cure_refund_header_id);
	    fetch get_obj_vers_no into l_obj_vers_no;
	    close get_obj_vers_no;

	    if(l_obj_vers_no is not null) Then
	      lp_chdv_rec.object_version_number :=   l_obj_vers_no;
	    End If;

	    open get_hdr_amounts_csr(lp_chdv_rec.cure_refund_header_id);
	    fetch get_hdr_amounts_csr into l_tot_received_amount, l_tot_offset_amount;
	    close get_hdr_amounts_csr;

	    lp_chdv_rec.received_amount := l_tot_received_amount;
	    lp_chdv_rec.offset_amount := l_tot_offset_amount;

            OKL_cure_rfnd_hdr_pub.update_cure_rfnd_hdr(
	        p_api_version    	=> p_api_version,
	        p_init_msg_list  	=> p_init_msg_list,
	        x_return_status  	=> x_return_status,
	        x_msg_count      	=> x_msg_count,
	        x_msg_data       	=> x_msg_data,
	        p_chdv_rec	        => lp_chdv_rec,
	   	x_chdv_rec		=> lx_chdv_rec
		);

	      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
		         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
		         raise OKC_API.G_EXCEPTION_ERROR;
	      End If;

    	   -- refund stage info

            OKL_cure_rfnd_stage_pub.update_cure_refunds(
	        p_api_version    	=> p_api_version,
	        p_init_msg_list  	=> p_init_msg_list,
	        x_return_status  	=> x_return_status,
	        x_msg_count      	=> x_msg_count,
	        x_msg_data       	=> x_msg_data,
	        p_crsv_tbl	        => lp_crsv_tbl,
	   	x_crsv_tbl		=> lx_crsv_tbl
		);

	      If (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
		         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	      Elsif (x_return_status = OKC_API.G_RET_STS_ERROR) then
		         raise OKC_API.G_EXCEPTION_ERROR;
	      End If;

    End If;


  OKC_API.END_ACTIVITY(x_msg_count	=> x_msg_count,	 x_msg_data	=> x_msg_data);

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

END OKL_CURE_VNDR_RFND_PVT;

/
