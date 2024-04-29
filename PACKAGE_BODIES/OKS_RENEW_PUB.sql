--------------------------------------------------------
--  DDL for Package Body OKS_RENEW_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_RENEW_PUB" AS
/* $Header: OKSPRENB.pls 120.4 2005/08/11 09:58:22 skekkar noship $ */

Procedure Renew
(
    p_api_version		IN   NUMBER,
    p_init_msg_list	IN   VARCHAR2	DEFAULT OKC_API.G_FALSE,
    x_return_status	OUT NOCOPY	VARCHAR2,
    x_msg_count		OUT NOCOPY	NUMBER,
    x_msg_data		OUT NOCOPY	VARCHAR2,
    x_contract_id       OUT NOCOPY      NUMBER,
    p_do_commit         IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_renewal_called_from_ui IN VARCHAR2 DEFAULT 'Y'
)
Is

    l_api_name              CONSTANT VARCHAR2(30) := 'renew';
    l_api_version           CONSTANT NUMBER       := 1.0;
    l_return_status                  VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

Begin

l_return_status := OKC_API.START_ACTIVITY(
				        p_api_name => l_api_name,
                        p_pkg_name => G_PKG_NAME,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version => l_api_version,
                        p_api_version => p_api_version,
                        p_api_type => '_PUB',
                        x_return_status => x_return_status
                     );

If l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
          Raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
ElsIf l_return_status = OKC_API.G_RET_STS_ERROR Then
          Raise OKC_API.G_EXCEPTION_ERROR;
End If;
If OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_contract_id = OKC_API.G_MISS_NUM Then
       OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_contract_id := Null;
End If;
If OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_contract_number = OKC_API.G_MISS_CHAR Then
       OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_contract_number := Null;
End If;
If OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_contract_version = OKC_API.G_MISS_CHAR Then
       OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_contract_version := Null;
End If;
If OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_contract_modifier = OKC_API.G_MISS_CHAR Then
       OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_contract_modifier := Null;
End If;
If OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_object_version_number =  OKC_API.G_MISS_NUM Then
       OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_object_version_number := Null;
End If;
If OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_new_contract_modifier =  OKC_API.G_MISS_CHAR Then
       OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_new_contract_modifier := Null;
End If;
If OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_start_date = OKC_API.G_MISS_DATE Then
       OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_start_date := Null;
End If;
If OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_end_date = OKC_API.G_MISS_DATE Then
       OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_end_date := Null;
End If;
If OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_orig_start_date = OKC_API.G_MISS_DATE Then
       OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_orig_start_date := Null;
End If;
If OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_orig_end_date = OKC_API.G_MISS_DATE Then
       OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_orig_end_date := Null;
End If;
If OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_uom_code = OKC_API.G_MISS_CHAR Then
       OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_uom_code := Null;
End If;
If OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_duration = OKC_API.G_MISS_NUM Then
       OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_duration := Null;
End If;

/*
For R12 moved to the new Rnewals API
OKS_RENEW_PVT.Renew
(
	p_api_version			=> 1.0,
	p_init_msg_list			=> OKC_API.G_FALSE,
	p_contract_id			=> OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_contract_id,
	p_contract_number	            => OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_contract_number,
	p_contract_version		=> OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_contract_version,
	p_contract_modifier		=> OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_contract_modifier,
	p_object_version_number		=> OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_object_version_number,
	p_new_contract_number		=> OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_new_contract_number,
	p_new_contract_modifier		=> OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_new_contract_modifier,
	p_start_date			=> OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_start_date,
	p_end_date				=> OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_end_date,
	p_orig_start_date			=> OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_orig_start_date,
	p_orig_end_date			=> OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_orig_end_date,
	p_uom_code				=> OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_uom_code,
	p_duration				=> OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_duration,
	p_Renewal_Type			=> NULL,
	p_Renewal_Pricing_Type		=> NULL,
	p_Markup_Percent			=> NULL,
	p_Price_List_Id1			=> NULL,
	p_Price_List_Id2			=> NULL,
	p_PDF_ID				=> NULL,
	p_QCL_ID				=> NULL,
	p_CGP_NEW_ID			=> NULL,
	p_CGP_RENEW_ID			=> NULL,
	p_PO_REQUIRED_YN			=> NULL,
	p_RLE_CODE				=> NULL,
	p_Function_Name			=> NULL,
      x_new_chr_id                  => x_contract_id,
	x_msg_count				=> x_msg_count,
	x_msg_data				=> x_msg_data,
	x_return_status			=> x_return_status
);
*/

    OKS_RENEW_CONTRACT_PVT.renew_contract(
     p_api_version => 1,
     p_init_msg_list => FND_API.G_FALSE,
     p_commit  => FND_API.G_FALSE,
     p_chr_id => OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_contract_id,
     p_new_contract_number => OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_new_contract_number,
     p_new_contract_modifier => OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_new_contract_modifier,
     p_new_start_date => OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_start_date,
     p_new_end_date => OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_end_date,
     p_new_duration => OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_duration,
     p_new_uom_code => OKC_RENEW_PUB.g_prerenew_in_parameters_rec.p_uom_code,
     p_renewal_called_from_ui => p_renewal_called_from_ui,
     x_chr_id => x_contract_id,
     x_msg_count => x_msg_count,
     x_msg_data => x_msg_data,
     x_return_status => x_return_status
     ) ;

If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
  	  raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
  	  raise OKC_API.G_EXCEPTION_ERROR;
End If;

--standard check of p_commit
IF FND_API.to_boolean( p_do_commit ) THEN
    COMMIT;
END IF;

OKC_API.END_ACTIVITY
(
	x_msg_count	=> x_msg_count,
	x_msg_data	=> x_msg_data
);

Exception

When OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

When OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

When OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

End;

END OKS_RENEW_PUB;

/
