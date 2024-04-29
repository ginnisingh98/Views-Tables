--------------------------------------------------------
--  DDL for Package Body OKS_EVTREN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_EVTREN_PUB" AS
/* $Header: OKSPERWB.pls 120.3 2005/11/23 16:25:20 skekkar noship $*/

    PROCEDURE renew
    (
     p_api_version IN NUMBER,
     p_init_msg_list IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
     p_contract_id IN NUMBER,
     p_contract_number IN okc_k_headers_v.contract_number%TYPE DEFAULT NULL,
     p_contract_version IN VARCHAR2 DEFAULT NULL,
     p_contract_modifier IN okc_k_headers_v.contract_number_modifier%TYPE DEFAULT NULL,
     p_object_version_number IN NUMBER DEFAULT NULL,
     p_new_contract_number IN okc_k_headers_v.contract_number%TYPE DEFAULT NULL,
     p_new_contract_modifier IN okc_k_headers_v.contract_number_modifier%TYPE DEFAULT NULL,
     p_start_date IN DATE DEFAULT NULL,
     p_end_date IN DATE DEFAULT NULL,
     p_orig_start_date IN DATE DEFAULT NULL,
     p_orig_end_date IN DATE DEFAULT NULL,
     p_uom_code IN okx_units_of_measure_v.uom_code%TYPE DEFAULT NULL,
     p_duration IN NUMBER DEFAULT NULL,
     p_Renewal_Type IN VARCHAR2 DEFAULT NULL,
     p_Renewal_Pricing_Type IN VARCHAR2 DEFAULT NULL,
     p_Markup_Percent IN NUMBER DEFAULT NULL,
     p_Price_List_Id1 IN VARCHAR2 DEFAULT NULL,
     p_Price_List_Id2 IN VARCHAR2 DEFAULT NULL,
     p_PDF_ID IN NUMBER DEFAULT NULL,
     p_QCL_ID IN NUMBER DEFAULT NULL,
     p_CGP_NEW_ID IN NUMBER DEFAULT NULL,
     p_CGP_RENEW_ID IN NUMBER DEFAULT NULL,
     p_PO_REQUIRED_YN IN VARCHAR2 DEFAULT NULL,
     p_RLE_CODE IN VARCHAR2 DEFAULT NULL,
     p_Function_Name IN VARCHAR2 DEFAULT NULL,
     x_msg_count OUT NOCOPY NUMBER,
     x_msg_data OUT NOCOPY VARCHAR2,
     x_return_status OUT NOCOPY VARCHAR2
     )
    IS

    l_api_name CONSTANT VARCHAR2(30) := 'renew';
    l_api_version CONSTANT NUMBER := 1.0;
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_new_chr_id NUMBER;

    l_contract_id NUMBER;
    l_contract_number okc_k_headers_v.contract_number%TYPE;
    l_contract_version VARCHAR2(9);
    l_contract_modifier okc_k_headers_v.contract_number_modifier%TYPE;
    l_object_version_number NUMBER;
    l_new_contract_number okc_k_headers_v.contract_number%TYPE;
    l_new_contract_modifier okc_k_headers_v.contract_number_modifier%TYPE;
    l_start_date DATE;
    l_end_date DATE;
    l_orig_start_date DATE;
    l_orig_end_date DATE;
    l_uom_code okx_units_of_measure_v.uom_code%TYPE;
    l_duration NUMBER;
    l_Renewal_Type VARCHAR2(200);
    l_Renewal_Pricing_Type VARCHAR2(200);
    l_Markup_Percent NUMBER;
    l_Price_List_Id1 VARCHAR2(200);
    l_Price_List_Id2 VARCHAR2(200);
    l_PDF_ID NUMBER;
    l_QCL_ID NUMBER;
    l_CGP_NEW_ID NUMBER;
    l_CGP_RENEW_ID NUMBER;
    l_PO_REQUIRED_YN VARCHAR2(200);
    l_RLE_CODE VARCHAR2(200);
    l_Function_Name VARCHAR2(200);
    l_contract_number_str VARCHAR2(250);

    CURSOR get_contr(l_chr_id NUMBER) IS
        SELECT contract_number, contract_number_modifier
        FROM okc_k_headers_all_b
        WHERE id = l_chr_id;


    BEGIN

        l_return_status := OKC_API.START_ACTIVITY(
                                                  p_api_name => l_api_name,
                                                  p_pkg_name => G_PKG_NAME,
                                                  p_init_msg_list => p_init_msg_list,
                                                  l_api_version => l_api_version,
                                                  p_api_version => p_api_version,
                                                  p_api_type => '_PUB',
                                                  x_return_status => x_return_status
                                                  );

        IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;


        IF p_contract_id = OKC_API.G_MISS_NUM THEN
            l_contract_id := NULL;
        ELSE
            l_contract_id := p_contract_id;
        END IF;
        IF p_contract_number = OKC_API.G_MISS_CHAR THEN
            l_contract_number := NULL;
        ELSE
            l_contract_number := p_contract_number;
        END IF;
        IF p_contract_version = OKC_API.G_MISS_CHAR THEN
            l_contract_version := NULL;
        ELSE
            l_contract_version := p_contract_version;
        END IF;
        IF p_contract_modifier = OKC_API.G_MISS_CHAR THEN
            l_contract_modifier := NULL;
        ELSE
            l_contract_modifier := p_contract_modifier;
        END IF;
        IF p_object_version_number = OKC_API.G_MISS_NUM THEN
            l_object_version_number := NULL;
        ELSE
            l_object_version_number := p_object_version_number;
        END IF;
        IF p_new_contract_number = OKC_API.G_MISS_CHAR THEN
            l_new_contract_number := NULL;
        ELSE
            l_new_contract_number := p_new_contract_number;
        END IF;
        IF p_new_contract_modifier = OKC_API.G_MISS_CHAR THEN
            l_new_contract_modifier := NULL;
        ELSE
            l_new_contract_modifier := p_new_contract_modifier;
        END IF;
        IF p_start_date = OKC_API.G_MISS_DATE THEN
            l_start_date := NULL;
        ELSE
            l_start_date := p_start_date;
        END IF;
        IF p_end_date = OKC_API.G_MISS_DATE THEN
            l_end_date := NULL;
        ELSE
            l_end_date := p_end_date;
        END IF;
        IF p_orig_start_date = OKC_API.G_MISS_DATE THEN
            l_orig_start_date := NULL;
        ELSE
            l_orig_start_date := p_orig_start_date;
        END IF;
        IF p_orig_end_date = OKC_API.G_MISS_DATE THEN
            l_orig_end_date := NULL;
        ELSE
            l_orig_end_date := p_orig_end_date;
        END IF;
        IF p_uom_code = OKC_API.G_MISS_CHAR THEN
            l_uom_code := NULL;
        ELSE
            l_uom_code := p_uom_code;
        END IF;
        IF p_duration = OKC_API.G_MISS_NUM THEN
            l_duration := NULL;
        ELSE
            l_duration := p_duration;
        END IF;

        IF p_renewal_type = OKC_API.G_MISS_CHAR THEN
            l_renewal_type := NULL;
        ELSE
            l_renewal_type := p_renewal_type;
        END IF;

        IF p_renewal_pricing_type = OKC_API.G_MISS_CHAR THEN
            l_renewal_pricing_type := NULL;
        ELSE
            l_renewal_pricing_type := p_renewal_pricing_type;
        END IF;

        IF p_markup_percent = OKC_API.G_MISS_NUM THEN
            l_markup_percent := NULL;
        ELSE
            l_markup_percent := p_markup_percent;
        END IF;
        IF p_price_list_id1 = OKC_API.G_MISS_CHAR THEN
            l_price_list_id1 := NULL;
        ELSE
            l_price_list_id1 := p_price_list_id1;
        END IF;
        IF p_price_list_id2 = OKC_API.G_MISS_CHAR THEN
            l_price_list_id2 := NULL;
        ELSE
            l_price_list_id2 := p_price_list_id2;
        END IF;
        IF p_pdf_id = OKC_API.G_MISS_NUM THEN
            l_pdf_id := NULL;
        ELSE
            l_pdf_id := p_pdf_id;
        END IF;
        IF p_qcl_id = OKC_API.G_MISS_NUM THEN
            l_qcl_id := NULL;
        ELSE
            l_qcl_id := p_qcl_id;
        END IF;
        IF p_cgp_new_id = OKC_API.G_MISS_NUM THEN
            l_cgp_new_id := NULL;
        ELSE
            l_cgp_new_id := p_cgp_new_id;
        END IF;
        IF p_cgp_renew_id = OKC_API.G_MISS_NUM THEN
            l_cgp_renew_id := NULL;
        ELSE
            l_cgp_renew_id := p_cgp_renew_id;
        END IF;
        IF p_po_required_yn = OKC_API.G_MISS_CHAR THEN
            l_po_required_yn := NULL;
        ELSE
            l_po_required_yn := p_po_required_yn;
        END IF;
        IF p_rle_code = OKC_API.G_MISS_CHAR THEN
            l_rle_code := NULL;
        ELSE
            l_rle_code := p_rle_code;
        END IF;
        IF p_function_name = OKC_API.G_MISS_CHAR THEN
            l_function_name := NULL;
        ELSE
            l_function_name := p_function_name;
        END IF;

        IF l_contract_number IS NULL THEN
            OPEN get_contr(l_contract_id);
            FETCH get_contr INTO l_contract_number, l_contract_modifier;
            CLOSE get_contr;
        END IF;
/*
For R12 moved to the new Rnewals API
OKS_RENEW_PVT.Renew
(
	p_api_version			=> 1.0,
	p_init_msg_list			=> OKC_API.G_FALSE,
	p_contract_id			=> l_contract_id,
	p_contract_number		=> l_contract_number,
	p_contract_version		=> l_contract_version,
	p_contract_modifier		=> l_contract_modifier,
	p_object_version_number	=> l_object_version_number,
	p_new_contract_number	=> l_new_contract_number,
	p_new_contract_modifier	=> l_new_contract_modifier,
	p_start_date			=> l_start_date,
	p_end_date			=> l_end_date,
	p_orig_start_date		=> l_orig_start_date,
	p_orig_end_date		=> l_orig_end_date,
	p_uom_code			=> l_uom_code,
	p_duration			=> l_duration,
	p_Renewal_Type			=> l_renewal_type,
	p_Renewal_Pricing_Type	=> l_renewal_pricing_type,
	p_Markup_Percent		=> l_markup_percent,
	p_Price_List_Id1		=> l_price_list_id1,
	p_Price_List_Id2		=> l_price_list_id2,
	p_PDF_ID			     => l_pdf_id,
	p_QCL_ID			     => l_qcl_id,
	p_CGP_NEW_ID			=> l_cgp_new_id,
	p_CGP_RENEW_ID			=> l_cgp_renew_id,
	p_PO_REQUIRED_YN		=> l_po_required_yn,
	p_RLE_CODE			=> l_rle_code,
	p_Function_Name		=> l_function_name,
	p_renewal_called_from_ui	=> 'N',
  x_new_chr_id             => l_new_chr_id,
	x_msg_count			=> x_msg_count,
	x_msg_data			=> x_msg_data,
	x_return_status	     => x_return_status
);
*/

        OKS_RENEW_CONTRACT_PVT.renew_contract(
                                              p_api_version => 1,
                                              p_init_msg_list => FND_API.G_FALSE,
                                              p_commit => FND_API.G_FALSE,
                                              p_chr_id => l_contract_id,
                                              p_new_contract_number => l_new_contract_number,
                                              p_new_contract_modifier => l_new_contract_modifier,
                                              p_new_start_date => l_start_date,
                                              p_new_end_date => l_end_date,
                                              p_new_duration => l_duration,
                                              p_new_uom_code => l_uom_code,
                                              p_renewal_called_from_ui => 'N',
                                              x_chr_id => l_new_chr_id,
                                              x_msg_count => x_msg_count,
                                              x_msg_data => x_msg_data,
                                              x_return_status => x_return_status
                                              ) ;

        IF l_contract_modifier IS NOT NULL THEN
            l_contract_number_str := l_contract_number || '-' || l_contract_modifier;
        ELSE
            l_contract_number_str := l_contract_number;
        END IF;

        IF x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF x_return_status = OKC_API.G_RET_STS_ERROR THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        x_return_status := 'S';

        OKC_API.set_message
        (p_app_name => 'OKS',
         p_msg_name => 'OKS_AUTO_RENEW_SUCCESS',
         p_token1 => 'CONTRACTNUMBER',
         p_token1_value => l_contract_number_str
         );

        OKC_API.END_ACTIVITY
        (
         x_msg_count => x_msg_count,
         x_msg_data => x_msg_data
         );

    EXCEPTION
        WHEN OKC_API.G_EXCEPTION_ERROR THEN

            OKC_API.set_message
            (p_app_name => 'OKS',
             p_msg_name => 'OKS_AUTO_RENEW_FAIL',
             p_token1 => 'CONTRACTNUMBER',
             p_token1_value => l_contract_number_str
             );

            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_ERROR',
             x_msg_count,
             x_msg_data,
             '_PUB'
             );

        WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

            OKC_API.set_message
            (p_app_name => 'OKS',
             p_msg_name => 'OKS_AUTO_RENEW_FAIL',
             p_token1 => 'CONTRACTNUMBER',
             p_token1_value => l_contract_number_str
             );

            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OKC_API.G_RET_STS_UNEXP_ERROR',
             x_msg_count,
             x_msg_data,
             '_PUB'
             );

        WHEN OTHERS THEN

            OKC_API.set_message
            (p_app_name => 'OKS',
             p_msg_name => 'OKS_AUTO_RENEW_FAIL',
             p_token1 => 'CONTRACTNUMBER',
             p_token1_value => l_contract_number_str
             );

            x_return_status := OKC_API.HANDLE_EXCEPTIONS
            (
             l_api_name,
             G_PKG_NAME,
             'OTHERS',
             x_msg_count,
             x_msg_data,
             '_PUB'
             );

    END;

END OKS_EVTREN_PUB;

/
