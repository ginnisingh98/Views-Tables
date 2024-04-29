--------------------------------------------------------
--  DDL for Package Body OKL_IN_TPP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_IN_TPP_PVT" AS
/* $Header: OKLRTPPB.pls 115.3 2002/12/18 12:51:41 kjinger noship $ */
 FUNCTION agency_address(    p_isu_id     IN  NUMBER,
                             p_agency_site_id IN NUMBER,
                                   x_agency_name   	 OUT NOCOPY VARCHAR2,
                                   x_agency_addrss1	 OUT NOCOPY VARCHAR2,
                                   x_agency_addrss2	 OUT NOCOPY VARCHAR2,
                                   x_agency_addrss3	 OUT NOCOPY VARCHAR2,
                                   x_agency_addrss4	 OUT NOCOPY VARCHAR2,
                                   x_agency_city		 OUT NOCOPY VARCHAR2,
                                   x_agency_county	 OUT NOCOPY VARCHAR2,
                                   x_agency_province	 OUT NOCOPY VARCHAR2,
                                   x_agency_state		 OUT NOCOPY VARCHAR2,
                                   x_agency_postalcode	 OUT NOCOPY VARCHAR2,
                                   x_agency_country	 OUT NOCOPY VARCHAR2
        		    	 ) RETURN VARCHAR2 IS
cursor agency_addrss is
 SELECT  prt.PARTY_NAME,
 prt.ADDRESS1,
 prt.ADDRESS2,
 prt.ADDRESS3,
 prt.ADDRESS4,
 prt.CITY,
 prt.COUNTY,
 prt.PROVINCE,
 prt.STATE,
 prt.POSTAL_CODE,
 prt.COUNTRY
 FROM HZ_PARTIES prt ,HZ_PARTY_SITES hps
 WHERE prt.CATEGORY_CODE = 'INSURER' AND
       prt.PARTY_ID = hps.PARTY_ID AND
       --prt.THIRD_PARTY_FLAG ='Y' AND
       prt.PARTY_ID = p_isu_id AND
       hps.party_site_id = p_agency_site_id;
       l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
 BEGIN
  open agency_addrss;
  fetch agency_addrss into  x_agency_name,x_agency_addrss1,x_agency_addrss2,x_agency_addrss3,
  			    x_agency_addrss4,x_agency_city,x_agency_county,x_agency_province,
  			    x_agency_state,x_agency_postalcode,x_agency_country;
  close agency_addrss;
  return (l_return_status);
      EXCEPTION
      WHEN OTHERS THEN
        OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                            ,p_msg_name     => G_UNEXPECTED_ERROR
                            ,p_token1       => G_SQLCODE_TOKEN
                            ,p_token1_value => SQLCODE
                            ,p_token2       => G_SQLERRM_TOKEN
                            ,p_token2_value => SQLERRM);
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      return (l_return_status);
END agency_address;
FUNCTION agent_address(p_int_id     IN  NUMBER,
                          p_agent_site_id IN NUMBER,
                          x_agent_name   	 OUT NOCOPY VARCHAR2,
                          x_agent_addrss1	 OUT NOCOPY VARCHAR2,
                          x_agent_addrss2	 OUT NOCOPY VARCHAR2,
                          x_agent_addrss3	 OUT NOCOPY VARCHAR2,
                          x_agent_addrss4	 OUT NOCOPY VARCHAR2,
                          x_agent_city	 OUT NOCOPY VARCHAR2,
                          x_agent_county	 OUT NOCOPY VARCHAR2,
                          x_agent_province OUT NOCOPY VARCHAR2,
                          x_agent_state	 OUT NOCOPY VARCHAR2,
                          x_agent_postalcode OUT NOCOPY VARCHAR2,
                          x_agent_country	   OUT NOCOPY VARCHAR2
        		) RETURN VARCHAR2 IS
cursor agent_addrss is
 SELECT prt.PARTY_NAME,
 prt.ADDRESS1,
 prt.ADDRESS2,
 prt.ADDRESS3,
 prt.ADDRESS4,
 prt.CITY,
 prt.COUNTY,
 prt.PROVINCE,
 prt.STATE,
 prt.POSTAL_CODE,
 prt.COUNTRY
 FROM HZ_PARTIES prt ,HZ_PARTY_SITES hps
 WHERE prt.CATEGORY_CODE = 'INSURANCE_AGENT' AND
       prt.PARTY_ID = hps.PARTY_ID AND
       --prt.THIRD_PARTY_FLAG ='Y' AND
       prt.PARTY_ID = p_int_id AND
       hps.party_site_id = p_agent_site_id;
       l_return_status         VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
 BEGIN
  open agent_addrss;
  fetch agent_addrss into  x_agent_name,x_agent_addrss1,x_agent_addrss2,x_agent_addrss3,
  			    x_agent_addrss4,x_agent_city,x_agent_county,x_agent_province,
  			    x_agent_state,x_agent_postalcode,x_agent_country;
  close agent_addrss;
  return (l_return_status);
  EXCEPTION
        WHEN OTHERS THEN
          OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                              ,p_msg_name     => G_UNEXPECTED_ERROR
                              ,p_token1       => G_SQLCODE_TOKEN
                              ,p_token1_value => SQLCODE
                              ,p_token2       => G_SQLERRM_TOKEN
                              ,p_token2_value => SQLERRM);
          l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      return (l_return_status);
END agent_address;
END OKL_IN_TPP_PVT;

/
