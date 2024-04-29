--------------------------------------------------------
--  DDL for Package Body OKL_BP_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BP_RULES" AS
/* $Header: OKLRBPRB.pls 115.1 2002/03/21 19:04:41 pkm ship        $ */

PROCEDURE extract_rules(
       p_api_version                  IN NUMBER,
   	   p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
	   p_khr_id						  IN NUMBER,
	   p_kle_id						  IN NUMBER,
	   p_rgd_code					  IN VARCHAR2,
	   p_rdf_code					  IN VARCHAR2,
   	   x_return_status                OUT NOCOPY VARCHAR2,
   	   x_msg_count                    OUT NOCOPY NUMBER,
   	   x_msg_data                     OUT NOCOPY VARCHAR2,
	   x_rulv_rec				  	  OUT NOCOPY rulv_rec_type)
IS


l_api_version 		NUMBER := 1;
l_init_msg_list 	VARCHAR2(1) ;
l_msg_count 		NUMBER ;
l_msg_data 			VARCHAR2(2000);
l_rg_count			NUMBER;
l_rule_count		NUMBER;

l_khr_id			NUMBER;
l_kle_id			NUMBER;


i					NUMBER;

cntrct_rg_excp		EXCEPTION;

l_api_name          CONSTANT VARCHAR2(30) := 'OKL_CONS_BILL';
l_return_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;

BEGIN
	l_khr_id := p_khr_id;
	l_kle_id := p_kle_id;



	--Get all rules for a Contract and Rule group
	Okl_Rule_Apis_Pvt.GET_CONTRACT_RGS(
					  l_api_version,
					  l_init_msg_list,
					  l_khr_id,
					  l_kle_id,
					  p_rgd_code,	  --'LABILL'
					  x_return_status,
					  l_msg_count,
					  l_msg_data,
					  l_rgpv_tbl,
					  l_rg_count);

	--dbms_output.put_line(l_rgpv_tbl.COUNT);

    IF (l_rgpv_tbl.COUNT = 1) THEN
	    l_rgpv_rec := l_rgpv_tbl(1);
    ELSIF (l_rgpv_tbl.COUNT > 1) THEN
      	RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSE
		NULL;
	END IF;

	Okl_Rule_Apis_Pvt.GET_CONTRACT_RULES(
					  l_api_version,
                      l_init_msg_list,
                      l_rgpv_rec,
                      p_rdf_code,
                      x_return_status,
                      l_msg_count,
                      l_msg_data,
                      l_rulv_tbl,
                      l_rule_count);

	--dbms_output.put_line('# 2 '||l_rulv_tbl.COUNT);
    FOR i IN  1..l_rulv_tbl.COUNT LOOP
          NULL;
		--dbms_output.put_line('# 21 '||l_rulv_tbl(i).rule_information_category||'--'||l_rulv_tbl(i).rule_information1);
	END LOOP;

    IF (l_rulv_tbl.COUNT = 1) THEN
	    x_rulv_rec := l_rulv_tbl(1);
    ELSIF (l_rulv_tbl.COUNT > 1) THEN
      	RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSE
		NULL;
	END IF;

/*
  	This section needed only to view the details of a rule evaluation SQL
	BPD does not need this yet...
	Okl_Rule_Apis_Pvt.GET_RULE_DISP_VALUE(
					  l_api_version,
                      l_init_msg_list,
                      l_rulv_rec,
                      l_return_status,
                      l_msg_count,
                      l_msg_data,
                      x_rulv_disp_rec);
*/

EXCEPTION
    WHEN Okc_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okc_Api.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'Okc_Api.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
    WHEN OTHERS THEN
      x_return_status :=Okc_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
END extract_rules;


END Okl_Bp_Rules;

/
