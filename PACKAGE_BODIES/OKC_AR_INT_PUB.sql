--------------------------------------------------------
--  DDL for Package Body OKC_AR_INT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_AR_INT_PUB" AS
/* $Header: OKCPARXB.pls 120.0 2005/05/25 22:34:26 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
--
g_package  varchar2(30) := '  okc_ar_int_pub.';  -- Global package name
--

---------------------------------------------------------------------------
-- PROCEDURE get_contract_contingencies
---------------------------------------------------------------------------
PROCEDURE get_contract_contingencies
( p_api_version                     IN NUMBER,
  p_init_msg_list                   IN VARCHAR2 ,
  p_contract_id                     IN NUMBER,
  p_contract_line_id                IN NUMBER,
  x_contract_contingencies_tbl      OUT NOCOPY contract_contingency_tbl_type,
  x_return_status                   OUT NOCOPY VARCHAR2,
  x_msg_count                       OUT NOCOPY NUMBER,
  x_msg_data                        OUT NOCOPY VARCHAR2
) IS
/*
*/
-- local variables and cursors

l_proc                       varchar2(72) := g_package||'get_contract_contingencies';

-- list of Rules in seeded Rule Group
CURSOR csr_seeded_rules IS
SELECT lookup_code
FROM fnd_lookups
WHERE lookup_type = 'OKC_CONTINGENCY_RULES';

-- rule at line level
CURSOR csr_line_rules(p_rule_code IN VARCHAR2, p_cle_id IN NUMBER, p_chr_id IN NUMBER) IS
SELECT rule_information1, rule_information2,
       rule_information3, rule_information4
FROM  okc_rule_groups_b rgb,
      okc_rules_b rul
WHERE rgb.id = rul.rgp_id
  AND rgb.rgd_code = 'REVENUE_CONTINGENCY_RULES'
  AND rgb.dnz_chr_id = p_chr_id
  AND rgb.cle_id = p_cle_id
  AND rul.rule_information_category = p_rule_code;

-- rule at header level
CURSOR csr_header_rules(p_rule_code IN VARCHAR2, p_chr_id IN NUMBER) IS
SELECT rule_information1, rule_information2,
       rule_information3, rule_information4
FROM  okc_rule_groups_b rgb,
      okc_rules_b rul
WHERE rgb.id = rul.rgp_id
  AND rgb.rgd_code = 'REVENUE_CONTINGENCY_RULES'
  AND rgb.chr_id = p_chr_id
  AND rul.rule_information_category = p_rule_code;


l_rule_code          fnd_lookups.lookup_code%TYPE;
l_rule_information1  okc_rules_b.rule_information1%TYPE;
l_rule_information2  okc_rules_b.rule_information2%TYPE;
l_rule_information3  okc_rules_b.rule_information3%TYPE;
l_rule_information4  okc_rules_b.rule_information4%TYPE;
i                    BINARY_INTEGER :=1;

BEGIN
  IF (l_debug = 'Y') THEN
     okc_debug.Set_Indentation(l_proc);
     okc_debug.Log('10:  Entering ',2);
     okc_debug.Log('50:  Contract Id : '||p_contract_id,2);
     okc_debug.Log('100: Line Id     : '||p_contract_line_id,2);
  END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  OPEN csr_seeded_rules;
    LOOP

      FETCH csr_seeded_rules INTO l_rule_code;
      EXIT WHEN csr_seeded_rules%NOTFOUND;

      -- check if this rule exists at line level
         OPEN csr_line_rules(p_rule_code => l_rule_code,
                             p_cle_id    => p_contract_line_id,
                             p_chr_id    =>  p_contract_id );
          FETCH csr_line_rules INTO l_rule_information1, l_rule_information2,
                l_rule_information3, l_rule_information4;
          -- check if record found
           IF csr_line_rules%FOUND THEN
             -- populate OUT RECORD
               x_contract_contingencies_tbl(i).CONTINGENCY_TYPE := l_rule_code;
               x_contract_contingencies_tbl(i).CONTINGENCY_PRESENT_YN := 'Y';
               x_contract_contingencies_tbl(i).EXPIRATION_DATE := to_date(l_rule_information1,'YYYY/MM/DD');
               x_contract_contingencies_tbl(i).EXPIRATION_START_EVENT := l_rule_information2;
               x_contract_contingencies_tbl(i).EXPIRATION_DURATION := l_rule_information3;
               x_contract_contingencies_tbl(i).DURATION_UOM := l_rule_information4;
               i := i + 1;
           ELSE
             -- check at header level
             OPEN csr_header_rules(p_rule_code => l_rule_code,
                                   p_chr_id    =>  p_contract_id );
               FETCH csr_header_rules INTO l_rule_information1, l_rule_information2,
                   l_rule_information3, l_rule_information4;

               -- check if record found
                IF csr_header_rules%FOUND THEN
                   -- populate OUT RECORD
                      x_contract_contingencies_tbl(i).CONTINGENCY_TYPE := l_rule_code;
                      x_contract_contingencies_tbl(i).CONTINGENCY_PRESENT_YN := 'Y';
                      x_contract_contingencies_tbl(i).EXPIRATION_DATE := to_date(l_rule_information1,'YYYY/MM/DD');
                      x_contract_contingencies_tbl(i).EXPIRATION_START_EVENT := l_rule_information2;
                      x_contract_contingencies_tbl(i).EXPIRATION_DURATION := l_rule_information3;
                      x_contract_contingencies_tbl(i).DURATION_UOM := l_rule_information4;
                      i := i + 1;
                END IF; -- csr_header_rules%FOUND

             CLOSE csr_header_rules;

           END IF; -- csr_line_rules%FOUND

         CLOSE csr_line_rules;



    END LOOP; -- csr_seeded_rules
  CLOSE csr_seeded_rules;


  IF (l_debug = 'Y') THEN
     okc_debug.Log('x_return_status : '||x_return_status,2);
     okc_debug.Log('1000: Leaving ',2);
     okc_debug.Reset_Indentation;
  END IF;

EXCEPTION
      WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      IF (l_debug = 'Y') THEN
         okc_debug.Log('x_return_status : '||x_return_status,2);
      END IF;
END get_contract_contingencies;



END okc_ar_int_pub;

/
