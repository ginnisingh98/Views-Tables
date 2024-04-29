--------------------------------------------------------
--  DDL for Package Body OKL_TERMS_AND_CONDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TERMS_AND_CONDS_PVT" as
/* $Header: OKLRSZTB.pls 115.4 2003/06/25 01:30:56 ashariff noship $ */
/* ***********************************************  */
--G_SQLERRM_TOKEN        CONSTANT       VARCHAR2(200) := 'SQLerrm';
--G_SQLCODE_TOKEN        CONSTANT       VARCHAR2(200) := 'SQLcode';
G_EXCEPTION_HALT_PROCESSING    exception;
G_EXCEPTION_STOP_VALIDATION    exception;


G_PKG_NAME    CONSTANT VARCHAR2(200) := 'OKL_TERMS_AND_CONDS_PVT';
G_APP_NAME    CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
G_API_TYPE    CONSTANT VARCHAR2(4)   := '_PVT';
l_api_name    VARCHAR2(35)    := 'TERMS_AND_CONDS';


PROCEDURE get_sec_terms_conditions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    x_trm_tbl                      OUT NOCOPY trm_tbl_type) IS

CURSOR TERMS_CONDS_CSR
--(P_TYPE IN VARCHAR2)
is
SELECT
1 SEQ_NO,
FND.MEANING GROUP_TITLE,
FND.DESCRIPTION DESCRIPTION,
--'LASEBB|LASERE|LASEAD|LASEAM|LASEIN|LASEEX' RULE_GROUP,
--'LASEBB-LASEFM|LASERE-LASEPR|LASEAD-LASEPR|LASEAM-LASEPR|LASEIN-LASEPR|LASEEX-LASEPR' RULE_SEQUENCE,
'LASEBB' RULE_GROUP,
'LASEBB-LASEFM' RULE_SEQUENCE,
'GROUP' TITLE_STYLE,
'OKL_TERMS_CONDS' PAGETITLE,
'OKL_LA_SEC_TC' REGION,
'NO' CURRENCY ,
'NO' DISABLED ,
'OKLLASECLASEPR' TOKEN ,
'oklLaSecRules.jsp' JSP
FROM FND_LOOKUPS FND
WHERE LOOKUP_TYPE = 'OKL_LA_SEC_LINKS' AND LOOKUP_CODE = 'OKLLASECLASEPR'
UNION
SELECT 2 SEQ_NO,
FND.MEANING GROUP_TITLE,
FND.DESCRIPTION DESCRIPTION,
'LASEIR' RULE_GROUP,
--'LASEIR-LASEIR|LASEIR-LAIVAR|LASEIR-LAICLC|LASEIR-LAFORM' RULE_SEQUENCE,
'LASEIR-LASEIR' RULE_SEQUENCE,
'RULE' TITLE_STYLE,
'OKL_TERMS_CONDS' PAGETITLE,
'OKL_LA_SEC_TC' REGION,
'NO' CURRENCY,
'NO' DISABLED,
'OKLLASECLASEIR' TOKEN ,
'oklLaSecRules.jsp' JSP
FROM FND_LOOKUPS FND
WHERE LOOKUP_TYPE = 'OKL_LA_SEC_LINKS' AND LOOKUP_CODE = 'OKLLASECLASEIR'
UNION
SELECT 2 SEQ_NO,
FND.MEANING GROUP_TITLE,
FND.DESCRIPTION DESCRIPTION,
'LASEAC' RULE_GROUP,
'LASEAC-LASEAC' RULE_SEQUENCE,
'RULE' TITLE_STYLE,
'OKL_TERMS_CONDS' PAGETITLE,
'OKL_LA_SEC_TC' REGION,
'NO' CURRENCY,
'NO' DISABLED,
'OKLLASECLASEAC' TOKEN ,
'oklLaSecRules.jsp' JSP
FROM FND_LOOKUPS FND
WHERE LOOKUP_TYPE = 'OKL_LA_SEC_LINKS' AND LOOKUP_CODE = 'OKLLASECLASEAC'

ORDER BY 1;

  l_trm_rec TERMS_CONDS_CSR%RowType;

  l_trm_tbl    trm_tbl_type;

  l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_api_name               CONSTANT VARCHAR2(30) := 'GET_SEC_TERMS_CONDITIONS';
  l_api_version            CONSTANT NUMBER    := 1.0;

  i NUMBER := 0;

  begin
     l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
                                                     G_PKG_NAME,
                                                     p_init_msg_list,
                                                     l_api_version,
                                                     p_api_version,
                                                     G_API_TYPE,
                                                     x_return_status);

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    x_return_status := l_return_status;
   Open TERMS_CONDS_CSR;
   Loop
       Fetch TERMS_CONDS_CSR into l_trm_rec;
       If TERMS_CONDS_CSR%NotFound Then
          --dbms_output.put_line('No Rule Found in Rule Group "'||p_rgd_code||'"');
          Exit;
       Else
           i := i + 1;
           l_trm_tbl(i).id                          := l_trm_rec.seq_no;
           l_trm_tbl(i).group_title                 := l_trm_rec.group_title;
           l_trm_tbl(i).description                 := l_trm_rec.description;
           l_trm_tbl(i).rule_group                  := l_trm_rec.rule_group;
           l_trm_tbl(i).rule_sequence               := l_trm_rec.rule_sequence;
           l_trm_tbl(i).title_style                 := l_trm_rec.title_style;
           l_trm_tbl(i).pagetitle                   := l_trm_rec.pagetitle;
           l_trm_tbl(i).region                      := l_trm_rec.region;
           l_trm_tbl(i).currency                    := l_trm_rec.currency;
           l_trm_tbl(i).disabled                    := l_trm_rec.disabled;
           l_trm_tbl(i).jsp                         := l_trm_rec.jsp;
        End If;
  End Loop;
    x_return_status := l_return_status;

Close TERMS_CONDS_CSR;
x_trm_tbl := l_trm_tbl;
 --Call End Activity
        OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                 x_msg_data     => x_msg_data);


  EXCEPTION
      when OKC_API.G_EXCEPTION_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

END get_sec_terms_conditions;



PROCEDURE get_lease_terms_conditions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    x_trm_tbl                      OUT NOCOPY trm_tbl_type) IS

CURSOR TERMS_CONDS_CSR
--(P_TYPE IN VARCHAR2)
is
SELECT
1 SEQ_NO,
FND.MEANING GROUP_TITLE,
FND.DESCRIPTION DESCRIPTION,
'LABILL' RULE_GROUP,
'LABILL-BTO|LABILL-LAPMTH|LABILL-LABACC|LABILL-LAINVD|LABILL-LAINPR' RULE_SEQUENCE,
'SINGLE' TITLE_STYLE,
'OKL_TERMS_CONDS' PAGETITLE,
'OKL_TC_ATTRIBUTES' REGION,
'NO' CURRENCY ,
'NO' DISABLED ,
'OKLLABILLINGSETUPLABILL' TOKEN ,
'oklLaBillingSetup.jsp' JSP
FROM FND_LOOKUPS FND
WHERE LOOKUP_TYPE = 'OKL_TC_LINKS' AND LOOKUP_CODE = 'OKLLABILLINGSETUPLABILL'
UNION
SELECT
2 SEQ_NO,
FND.MEANING GROUP_TITLE,
FND.DESCRIPTION DESCRIPTION,
'LALCGR|LALIGR' RULE_GROUP,
Null RULE_SEQUENCE,
'GROUP' TITLE_STYLE,
'OKL_TERMS_CONDS' PAGETITLE,
'OKL_TC_ATTRIBUTES' REGION,
'NO' CURRENCY , 'NO' DISABLED ,
'OKLLARULEGROUPSLALCGR' TOKEN ,
'oklLaRuleGroups.jsp' JSP
FROM FND_LOOKUPS FND
WHERE LOOKUP_TYPE = 'OKL_TC_LINKS' AND LOOKUP_CODE = 'OKLLARULEGROUPSLALCGR'
UNION
SELECT 3 SEQ_NO,
FND.MEANING GROUP_TITLE,
FND.DESCRIPTION DESCRIPTION,
'LARNOP' RULE_GROUP,
NULL RULE_SEQUENCE,
'GROUP' TITLE_STYLE,
'OKL_TERMS_CONDS' PAGETITLE,
'OKL_TC_ATTRIBUTES' REGION,
'YES' CURRENCY,
'NO' DISABLED,
'OKLLARULEGROUPSLARNOP' TOKEN ,
'oklLaRuleGroups.jsp' JSP
FROM FND_LOOKUPS FND
WHERE LOOKUP_TYPE = 'OKL_TC_LINKS' AND LOOKUP_CODE = 'OKLLARULEGROUPSLARNOP'
UNION
SELECT 4 SEQ_NO,
FND.MEANING GROUP_TITLE,
FND.DESCRIPTION DESCRIPTION,
'LAIIND' RULE_GROUP,
'LAIIND-LAINTP|LAIIND-LAICON|LAIIND-LAIVAR|LAIIND-LAICLC|LAIIND-LAFORM' RULE_SEQUENCE,
'RULE' TITLE_STYLE,
'OKL_TERMS_CONDS' PAGETITLE,
'OKL_TC_ATTRIBUTES' REGION,
'NO' CURRENCY,
'NO' DISABLED,
'OKLLARULESLAIIND' TOKEN ,
'oklLaRules.jsp' JSP
FROM FND_LOOKUPS FND
WHERE LOOKUP_TYPE = 'OKL_TC_LINKS' AND LOOKUP_CODE = 'OKLLARULESLAIIND'
UNION
SELECT
5 SEQ_NO,
FND.MEANING GROUP_TITLE,
FND.DESCRIPTION DESCRIPTION,
'LASDEP|LAFCTG|LAEVEL' RULE_GROUP,
NULL RULE_SEQUENCE,
'GROUP' TITLE_STYLE,
'OKL_TERMS_CONDS' PAGETITLE,
'OKL_TC_ATTRIBUTES' REGION,
'NO' CURRENCY,
'NO' DISABLED,
'OKLLARULESLASDEP' TOKEN ,
'oklLaRuleGroups.jsp' JSP
FROM FND_LOOKUPS FND
WHERE LOOKUP_TYPE = 'OKL_TC_LINKS' AND LOOKUP_CODE = 'OKLLARULESLASDEP'
UNION
SELECT
6 SEQ_NO,
FND.MEANING GROUP_TITLE,
FND.DESCRIPTION DESCRIPTION,
'LARVIN' RULE_GROUP,
'LARVIN-LARVAU|LARVIN-LARVAM' RULE_SEQUENCE,
'GROUP' TITLE_STYLE,
'OKL_TERMS_CONDS' PAGETITLE,
'OKL_TC_ATTRIBUTES' REGION,
'NO' CURRENCY,
'NO' DISABLED,
'OKLLARULESLARVIN' TOKEN ,
'oklLaRules.jsp' JSP
FROM FND_LOOKUPS FND
WHERE LOOKUP_TYPE = 'OKL_TC_LINKS' AND LOOKUP_CODE = 'OKLLARULESLARVIN'
UNION
SELECT
7 SEQ_NO,
FND.MEANING GROUP_TITLE,
FND.DESCRIPTION DESCRIPTION,
'LAFLLG' RULE_GROUP,
'LAAFLG-LAFLLN|LAAFLG-LAFLTL' RULE_SEQUENCE,
'RULE' TITLE_STYLE,
'OKL_TERMS_CONDS' PAGETITLE,
'OKL_TC_ATTRIBUTES' REGION,
'NO' CURRENCY,
'NO' DISABLED,
'OKLLARULESLAFLLG' TOKEN ,
'oklLaRules.jsp' JSP
FROM FND_LOOKUPS FND
WHERE LOOKUP_TYPE = 'OKL_TC_LINKS' AND LOOKUP_CODE = 'OKLLARULESLAFLLG'
UNION
SELECT
8 SEQ_NO,
FND.MEANING GROUP_TITLE,
FND.DESCRIPTION DESCRIPTION,
'AMLARL|AMREPQ' RULE_GROUP,
'DEFAULT' RULE_SEQUENCE,
'GROUP' TITLE_STYLE,
'OKL_TERMS_CONDS' PAGETITLE,
'OKL_TC_ATTRIBUTES' REGION,
'YES' CURRENCY,
'NO' DISABLED,
'OKLLARULESAMLARL' TOKEN ,
'oklLaRules.jsp' JSP
FROM FND_LOOKUPS FND
WHERE LOOKUP_TYPE = 'OKL_TC_LINKS' AND LOOKUP_CODE = 'OKLLARULESAMLARL'
UNION
SELECT
9 SEQ_NO,
FND.MEANING GROUP_TITLE,
FND.DESCRIPTION DESCRIPTION,
'AMTEOC|AMTFOC' RULE_GROUP,
'DEFAULT' RULE_SEQUENCE,
'GROUP' TITLE_STYLE,
'OKL_TERMS_CONDS' PAGETITLE,
'OKL_TC_ATTRIBUTES' REGION,
'YES' CURRENCY,
'NO' DISABLED,
'OKLLARULESAMTEOC' TOKEN ,
'oklLaRules.jsp' JSP
FROM FND_LOOKUPS FND
WHERE LOOKUP_TYPE = 'OKL_TC_LINKS' AND LOOKUP_CODE = 'OKLLARULESAMTEOC'
UNION
SELECT
10 SEQ_NO,
FND.MEANING GROUP_TITLE,
FND.DESCRIPTION DESCRIPTION,
'AMTQPR|AMTPAR|AMTGAL|AMQR1R|AMQR5A|AMQR9F' RULE_GROUP,
'DEFAULT' RULE_SEQUENCE,
'GROUP' TITLE_STYLE,
'OKL_TERMS_CONDS' PAGETITLE,
'OKL_TC_ATTRIBUTES' REGION,
'YES' CURRENCY,
'NO' DISABLED,
'OKLLARULESAMTQPR' TOKEN ,
'oklLaRules.jsp' JSP
FROM FND_LOOKUPS FND
WHERE LOOKUP_TYPE = 'OKL_TC_LINKS' AND LOOKUP_CODE = 'OKLLARULESAMTQPR'
UNION
SELECT
11 SEQ_NO,
FND.MEANING GROUP_TITLE,
FND.DESCRIPTION DESCRIPTION,
'AMTEWC' RULE_GROUP,
'DEFAULT' RULE_SEQUENCE,
'GROUP-RULE' TITLE_STYLE,
'OKL_TERMS_CONDS' PAGETITLE,
'OKL_TC_ATTRIBUTES' REGION,
'YES' CURRENCY,
'NO' DISABLED,
'OKLLARULESAMTEWC' TOKEN ,
'oklLaRules.jsp' JSP
FROM FND_LOOKUPS FND
WHERE LOOKUP_TYPE = 'OKL_TC_LINKS' AND LOOKUP_CODE = 'OKLLARULESAMTEWC'
UNION
SELECT
12 SEQ_NO,
 FND.MEANING GROUP_TITLE,
 FND.DESCRIPTION DESCRIPTION,
 'AMTFWC' RULE_GROUP,
 'DEFAULT' RULE_SEQUENCE,
 'GROUP-RULE' TITLE_STYLE,
 'OKL_TERMS_CONDS' PAGETITLE,
 'OKL_TC_ATTRIBUTES' REGION,
 'YES' CURRENCY,
 'NO' DISABLED,
 'OKLLARULESAMTFWC' TOKEN ,
 'oklLaRules.jsp' JSP
 FROM FND_LOOKUPS FND
 WHERE LOOKUP_TYPE = 'OKL_TC_LINKS' AND LOOKUP_CODE = 'OKLLARULESAMTFWC'
 UNION
 SELECT
 13 SEQ_NO,
 FND.MEANING GROUP_TITLE,
  FND.DESCRIPTION DESCRIPTION,
  'AMCOPO' RULE_GROUP,
  'DEFAULT' RULE_SEQUENCE,
  'GROUP' TITLE_STYLE, 'OKL_TERMS_CONDS'
  PAGETITLE, 'OKL_TC_ATTRIBUTES' REGION,
  'YES' CURRENCY,
  'NO' DISABLED,
  'OKLLARULESAMCOPO' TOKEN ,
  'oklLaRules.jsp' JSP
  FROM FND_LOOKUPS FND
  WHERE LOOKUP_TYPE = 'OKL_TC_LINKS' AND LOOKUP_CODE = 'OKLLARULESAMCOPO'
  UNION
  SELECT
  14 SEQ_NO,
  FND.MEANING GROUP_TITLE,
  FND.DESCRIPTION DESCRIPTION,
  'SUMMARY' RULE_GROUP,
  'DEFAULT' RULE_SEQUENCE,
  'NO' TITLE_STYLE,
  'NO' PAGETITLE,
  'NO' REGION,
  'NO' CURRENCY,
  'NO' DISABLED,
  'VENDOR-PROGRAMS' TOKEN ,
  'oklLaRules.jsp' JSP
  FROM FND_LOOKUPS FND
  WHERE LOOKUP_TYPE = 'OKL_TC_LINKS' AND LOOKUP_CODE = 'VENDOR-PROGRAMS'
  UNION
  SELECT
  15 SEQ_NO,
  FND.MEANING GROUP_TITLE,
  FND.DESCRIPTION DESCRIPTION,
  'LAHDTX' RULE_GROUP,
  'LAHDTX-LAPRTX|LAHDTX-LAMETX|LAHDTX-LAAUTX' RULE_SEQUENCE,
  'RULE' TITLE_STYLE,
  'OKL_TERMS_CONDS' PAGETITLE,
  'OKL_TC_ATTRIBUTES' REGION,
  'NO' CURRENCY,
  'NO' DISABLED,
  'OKLLARULESLAHDTX' TOKEN ,
  'oklLaRules.jsp' JSP
  FROM FND_LOOKUPS FND
  WHERE LOOKUP_TYPE = 'OKL_TC_LINKS' AND LOOKUP_CODE = 'OKLLARULESLAHDTX' ORDER BY 1;

  l_trm_rec TERMS_CONDS_CSR%RowType;

  l_trm_tbl    trm_tbl_type;

  l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_api_name               CONSTANT VARCHAR2(30) := 'GET_LEASE_TERMS_CONDITIONS';
  l_api_version            CONSTANT NUMBER    := 1.0;

  i NUMBER := 0;

  begin
     l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
                                                     G_PKG_NAME,
                                                     p_init_msg_list,
                                                     l_api_version,
                                                     p_api_version,
                                                     G_API_TYPE,
                                                     x_return_status);

      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    x_return_status := l_return_status;
   Open TERMS_CONDS_CSR;
   Loop
       Fetch TERMS_CONDS_CSR into l_trm_rec;
       If TERMS_CONDS_CSR%NotFound Then
          --dbms_output.put_line('No Rule Found in Rule Group "'||p_rgd_code||'"');
          Exit;
       Else
           i := i + 1;
           l_trm_tbl(i).id                          := l_trm_rec.seq_no;
           l_trm_tbl(i).group_title                 := l_trm_rec.group_title;
           l_trm_tbl(i).description                 := l_trm_rec.description;
           l_trm_tbl(i).rule_group                  := l_trm_rec.rule_group;
           l_trm_tbl(i).rule_sequence               := l_trm_rec.rule_sequence;
           l_trm_tbl(i).title_style                 := l_trm_rec.title_style;
           l_trm_tbl(i).pagetitle                   := l_trm_rec.pagetitle;
           l_trm_tbl(i).region                      := l_trm_rec.region;
           l_trm_tbl(i).currency                    := l_trm_rec.currency;
           l_trm_tbl(i).disabled                    := l_trm_rec.disabled;
           l_trm_tbl(i).jsp                         := l_trm_rec.jsp;
        End If;
  End Loop;
    x_return_status := l_return_status;

Close TERMS_CONDS_CSR;
x_trm_tbl := l_trm_tbl;
 --Call End Activity
        OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                 x_msg_data     => x_msg_data);


  EXCEPTION
      when OKC_API.G_EXCEPTION_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);


END get_lease_terms_conditions;



PROCEDURE get_terms_conditions(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_type                         IN  VARCHAR2,
    x_trm_tbl                      OUT NOCOPY trm_tbl_type) IS


  l_trm_tbl    trm_tbl_type;

  l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_api_name               CONSTANT VARCHAR2(30) := 'GET_TERMS_CONDITIONS';
  l_api_version            CONSTANT NUMBER    := 1.0;

  i NUMBER := 0;

  begin
  --dbms_output.put_line('p_type: '||p_type);
    if(p_type = 'LEASE') then
    --dbms_output.put_line('lease ');
        get_lease_terms_conditions(
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => l_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            x_trm_tbl        => x_trm_tbl);
    elsif(p_type = 'INVESTOR_AGREEMENT') then
     --dbms_output.put_line('investor ');
        get_sec_terms_conditions(
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => l_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            x_trm_tbl        => x_trm_tbl);
    end if;

      x_return_status := l_return_status;

   IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

 --Call End Activity
        OKL_API.END_ACTIVITY(x_msg_count    => x_msg_count,
                 x_msg_data     => x_msg_data);


  EXCEPTION
      when OKC_API.G_EXCEPTION_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OKC_API.G_EXCEPTION_UNEXPECTED_ERROR then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);

      when OTHERS then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
            p_api_name  => l_api_name,
            p_pkg_name  => G_PKG_NAME,
            p_exc_name  => 'OTHERS',
            x_msg_count => x_msg_count,
            x_msg_data  => x_msg_data,
            p_api_type  => G_API_TYPE);


END get_terms_conditions;


END OKL_TERMS_AND_CONDS_PVT;

/
