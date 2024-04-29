--------------------------------------------------------
--  DDL for Package Body ZX_TRN_VALIDATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TRN_VALIDATION_PKG" AS
/* $Header: zxctaxregnb.pls 120.32.12010000.28 2020/03/05 07:50:16 sperivel ship $ */

  -- Logging Infra
  G_CURRENT_RUNTIME_LEVEL      NUMBER;
  G_LEVEL_UNEXPECTED  CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR       CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION   CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT       CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE   CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT   CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME       CONSTANT VARCHAR2(50) := 'ZX.PLSQL.ZX_TRN_VALIDATION_PKG.';
  G_INVALID_PTP_ID    CONSTANT NUMBER(3)    := -1;
  G_MISS_CHAR         CONSTANT VARCHAR2(1) := FND_API.G_MISS_CHAR;
  g_country_code               VARCHAR2(50);
  g_ptp_id                     ZX_PARTY_TAX_PROFILE.PARTY_TAX_PROFILE_ID%TYPE;
  g_trn                        VARCHAR2(50);
  l_allow_regn_num_flag        VARCHAR2(1);
  -- Logging Infra

--
-- private function
--
FUNCTION ora_error_number (p_error_string  IN   VARCHAR2) RETURN NUMBER IS
BEGIN
  IF INSTR(p_error_string,'ORA-06502:') > 0 THEN
    RETURN 6502;
  ELSE
    RETURN 0;
  END IF;
END ora_error_number;
/****************  end of FUNCTION ora_error_number  *******************/

--
-- public function
--
FUNCTION COMMON_CHECK_NUMERIC(p_check_value IN VARCHAR2,
                              p_from        IN NUMBER,
                              p_for         IN NUMBER)   RETURN VARCHAR2
IS
  num_check VARCHAR2(40);

BEGIN
  num_check := '1';
  num_check := nvl( rtrim(
                       translate( substr(p_check_value,p_from,p_for),
                                  '1234567890',
                                  '          ' ) ), '0' );

  RETURN(num_check);
END COMMON_CHECK_NUMERIC;

/****************  end of FUNCTION common_check_numeric  *******************/

--
-- public function
--
FUNCTION COMMON_CHECK_LENGTH(p_country_code  IN VARCHAR2,
                             p_num_digits    IN NUMBER,
                             p_trn           IN VARCHAR2) RETURN VARCHAR2 IS

l_max_digits  NUMBER(3);

BEGIN

  l_max_digits:=lengthb(p_trn);
  IF (p_country_code = 'AR' AND (l_max_digits = p_num_digits)) THEN
    RETURN('TRUE');
  ELSIF (p_country_code='CL' AND (l_max_digits <= p_num_digits)) THEN
    RETURN('TRUE');
  ELSIF (p_country_code='CO' AND (l_max_digits <= p_num_digits)) THEN
    RETURN('TRUE');
  ELSIF (p_country_code='TW' AND (l_max_digits = p_num_digits)) THEN
    RETURN('TRUE');
  ELSE
    RETURN ('FALSE');
  END IF;

END COMMON_CHECK_LENGTH;

/****************  end of FUNCTION common_check_length  *******************/

PROCEDURE VALIDATE_TRN(p_country_code            IN  VARCHAR2,
                       p_tax_reg_num             IN  VARCHAR2,
                       p_tax_regime_code         IN  VARCHAR2,
                       p_tax                     IN  VARCHAR2,
                       p_tax_jurisdiction_code   IN  VARCHAR2,
                       p_ptp_id                  IN  NUMBER,
                       p_party_type_code         IN  VARCHAR2,
                       p_trn_type                IN  VARCHAR2,
                       p_error_buffer            OUT NOCOPY VARCHAR2,
                       p_return_status           OUT NOCOPY VARCHAR2,
                       x_party_type_token        OUT NOCOPY VARCHAR2,
                       x_party_name_token        OUT NOCOPY VARCHAR2,
                       x_party_site_name_token   OUT NOCOPY VARCHAR2  )
                       AS

l_registration_id       NUMBER;
l_ptp_id                NUMBER;
l_party_type_code       VARCHAR2(30);
l_pass_unique_check     VARCHAR2(1);
l_country_code          VARCHAR2(4);
l_trn                   VARCHAR2(50);
l_trn_type              VARCHAR2(30);
l_tax                   VARCHAR2(30);
l_tax_regime_code       VARCHAR2(30);
l_tax_jurisdiction_code VARCHAR2(30);
l_header_reg_num        VARCHAR2(50);
l_result_message        VARCHAR2(40);
l_header_check          VARCHAR2(1);
to_be_chached_ptp_id    NUMBER;

l_party_id              NUMBER;
l_party_type            VARCHAR2(1000);
l_party_name            VARCHAR2(5000);
l_party_site_name       VARCHAR2(5000);
l_party_site_number     VARCHAR2(5000);
l_custom                NUMBER;
l_total_count           NUMBER;
l_specific_count        NUMBER;

l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN';
l_log_msg        FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;


CURSOR tax_reg_num_csr(c_registration_number varchar2,
                       c_party_type_code varchar2,
                       c_tax_regime_code varchar2,
                       c_tax varchar2,
                       c_tax_jurisdiction_code varchar2,
                       c_ptp_id  NUMBER) IS
  SELECT distinct ptp.party_id
  FROM   zx_registrations  reg,
         zx_party_tax_profile ptp
  WHERE  ptp.party_tax_profile_id = reg.party_tax_profile_id
    AND  reg.registration_number = c_registration_number
    AND  sysdate >= reg.effective_from
    AND  (sysdate <= reg.effective_to OR reg.effective_to IS NULL)
    AND  ptp.party_type_code = c_party_type_code
    AND  ptp.party_tax_profile_id <> NVL(c_ptp_id, G_INVALID_PTP_ID)
    AND  ((c_tax_regime_code IS NULL)
           OR
          (reg.tax_regime_code IS NULL)
           OR
          (c_tax_regime_code IS NOT NULL AND  reg.tax_regime_code = c_tax_regime_code)
         )
    AND  ((c_tax IS NULL)
           OR
          (reg.tax IS NULL)
           OR
          (c_tax IS NOT NULL AND  reg.tax = c_tax)
         )
    AND  ((c_tax_jurisdiction_code IS NULL)
           OR
          (reg.tax_jurisdiction_code IS NULL)
           OR
          (c_tax_jurisdiction_code IS NOT NULL AND reg.tax_jurisdiction_code = c_tax_jurisdiction_code)
         );


CURSOR ptp_type_csr(c_ptp_id  number) IS
  SELECT party_type_code
    FROM zx_party_tax_profile
   WHERE party_tax_profile_id = c_ptp_id;

CURSOR c_AllowDupRegnNum IS
  SELECT allow_dup_regn_num_flag
    FROM zx_taxes_b
   WHERE tax_regime_code = p_tax_regime_code
     AND tax = p_tax
   order by DECODE(allow_dup_regn_num_flag,'Y','1','2');

CURSOR c_third_party_reg_num (c_ptp_id  number, c_tax_reg_num  varchar2) IS
  SELECT registration_number
    FROM zx_registrations
   WHERE party_tax_profile_id = (SELECT s.party_tax_profile_id
                                   FROM zx_party_tax_profile s,
                                        zx_party_tax_profile ptp,
                                        hz_party_sites hzps
                                  where ptp.party_tax_profile_id = c_ptp_id
                                    and ptp.party_id = hzps.party_site_id
                                    and hzps.party_id = s.party_id
                                    AND s.merged_to_ptp_id IS NULL
                                    and s.party_type_code = 'THIRD_PARTY')
     and registration_number = c_tax_reg_num;

CURSOR c_establishment_reg_num (c_ptp_id  number, c_tax_reg_num  varchar2) IS
  SELECT regt.registration_number
    FROM zx_registrations regt
   where  regt.party_tax_profile_id = (SELECT ptpp.party_tax_profile_id
                                         FROM xle_fp_establishment_v est,
                                              xle_fp_establishment_v estp,
                                              zx_party_tax_profile ptp,
                                              zx_party_tax_profile ptpp
                                        where estp.party_id = ptpp.party_id
                                          and estp.legal_entity_id = est.legal_entity_id
                                          and est.party_id = ptp.party_id
                                          and ptp.party_tax_profile_id = c_ptp_id
                                          and estp.main_establishment_flag = 'Y'
                                          AND ptpp.merged_to_ptp_id IS NULL
                                          and ptpp.party_type_code = 'LEGAL_ESTABLISHMENT')
     and regt.registration_number = c_tax_reg_num;

CURSOR c_get_lookup_meaning (cp_lookup_type  IN  VARCHAR2
                            ,cp_lookup_code  IN  VARCHAR2) IS
  SELECT meaning
    FROM fnd_lookups
   WHERE lookup_type = cp_lookup_type
     AND lookup_code = cp_lookup_code;

CURSOR c_get_party_name (cp_party_id  IN  NUMBER) IS
  SELECT party_name
    FROM hz_parties
   WHERE party_id = cp_party_id;

CURSOR c_get_party_site_details (cp_party_site_id  IN  NUMBER) IS
  SELECT p.party_name, ps.party_site_name, ps.party_site_number
    FROM hz_parties p, hz_party_sites ps
   WHERE p.party_id = ps.party_id
     AND ps.party_site_id = cp_party_site_id;


                           /**************************/
                           /* SuB-Procedures Section */
                           /**************************/

  ----------------------------------------------------------------
  PROCEDURE unique_trn(p_tax_reg_num             IN  VARCHAR2,
                       p_party_type_code         IN  VARCHAR2,
                       p_tax_regime_code         IN  VARCHAR2,
                       p_tax                     IN  VARCHAR2,
                       p_tax_jurisdiction_code   IN  VARCHAR2,
                       p_ptp_id                  IN  NUMBER,
                       x_trn_unique_result       OUT NOCOPY VARCHAR2) IS
  ----------------------------------------------------------------
  l_dummy varchar2(1);
  BEGIN

    OPEN tax_reg_num_csr(p_tax_reg_num, p_party_type_code, p_tax_regime_code, p_tax, p_tax_jurisdiction_code
                        ,p_ptp_id
                        );
    LOOP
    FETCH tax_reg_num_csr into l_party_id ;

      IF tax_reg_num_csr%NOTFOUND THEN
        -- No data found. Therfore, new tax registration number will be unique.
        x_trn_unique_result := FND_API.G_RET_STS_SUCCESS;
        close tax_reg_num_csr;
        EXIT;
      ELSE
        -- Data found. Therfore, new tax registration number will NOT be unique.
        x_trn_unique_result := FND_API.G_RET_STS_ERROR;
        close tax_reg_num_csr;
        EXIT;
      END IF;

    END LOOP;

  END unique_trn;

  --------------------------------------------------------------------------
  PROCEDURE set_msg_details (p_tax_reg_num           IN  VARCHAR2,
                             p_party_type_code       IN  VARCHAR2,
                             p_tax_regime_code       IN  VARCHAR2,
                             p_tax                   IN  VARCHAR2,
                             p_tax_jurisdiction_code IN  VARCHAR2,
                             x_party_type_token      OUT NOCOPY VARCHAR2,
                             x_party_name_token      OUT NOCOPY VARCHAR2,
                             x_party_site_name_token OUT NOCOPY VARCHAR2,
                             x_party_site_num_token  OUT NOCOPY VARCHAR2,
                             x_error_buffer          OUT NOCOPY VARCHAR2,
                             x_return_status         OUT NOCOPY VARCHAR2) IS
  --------------------------------------------------------------------------
  l_procedure_name  CONSTANT  VARCHAR2(30) := 'set_msg_details';
  l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

  l_party_name         VARCHAR2(5000) := NULL;
  l_party_site_name    VARCHAR2(5000) := NULL;
  l_party_site_number  VARCHAR2(5000) := NULL;

  BEGIN

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := l_procedure_name||'(+)';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Parameters ';
      l_log_msg :=  l_log_msg||'P_tax_erg_num: '||p_tax_reg_num;
      l_log_msg :=  l_log_msg||'P_party_type_code: '||p_party_type_code;
      l_log_msg :=  l_log_msg||'P_tax_regime_code: '||p_tax_regime_code;
      l_log_msg :=  l_log_msg||'P_tax: '||p_tax;
      l_log_msg :=  l_log_msg||'P_tax_jurisdiction_code: '||p_tax_jurisdiction_code;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;

    OPEN c_get_lookup_meaning (cp_lookup_type => 'ZX_PTP_PARTY_TYPE'
                              ,cp_lookup_code => p_party_type_code);
    FETCH c_get_lookup_meaning INTO x_party_type_token;
    CLOSE c_get_lookup_meaning;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    OPEN tax_reg_num_csr(p_tax_reg_num, p_party_type_code, p_tax_regime_code,
                         p_tax, p_tax_jurisdiction_code, NULL);
    LOOP
      FETCH tax_reg_num_csr into l_party_id ;

      -- Exit loop when there are no more rows to fetch
      EXIT WHEN tax_reg_num_csr%NOTFOUND;

      IF p_party_type_code = 'THIRD_PARTY' THEN

        OPEN c_get_party_name (cp_party_id => l_party_id);
        FETCH c_get_party_name INTO l_party_name;
        CLOSE c_get_party_name;

        if x_party_name_token is null then
          x_party_name_token := l_party_name;
        else
          x_party_name_token := x_party_name_token ||'; '|| l_party_name;
        end if;
        x_error_buffer := 'ZX_REG_NUM_DUPLICATE';
        x_return_status := FND_API.G_RET_STS_ERROR;

      ELSIF p_party_type_code = 'THIRD_PARTY_SITE' THEN

        OPEN c_get_party_site_details (cp_party_site_id => l_party_id);
        FETCH c_get_party_site_details INTO l_party_name, l_party_site_name, l_party_site_number;
        CLOSE c_get_party_site_details;

        if x_party_name_token is null then
          x_party_name_token := l_party_name;
        else
          x_party_name_token := x_party_name_token ||'; '|| l_party_name;
        end if;
        if x_party_site_name_token is null then
          x_party_site_name_token := l_party_site_name;
        else
          x_party_site_name_token := x_party_site_name_token ||'; '|| l_party_site_name;
        end if;
        if x_party_site_num_token is null then
          x_party_site_num_token := l_party_site_number;
        else
          x_party_site_num_token := x_party_site_num_token ||'; '|| l_party_site_number;
        end if;
        IF l_party_site_name IS NOT NULL THEN
          x_error_buffer := 'ZX_REG_NUM_SITE_DUPLICATE';
        ELSE
          x_error_buffer := 'ZX_REG_NUM_SITE_NUMBER_DUP';
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;

      ELSIF p_party_type_code = 'LEGAL_ESTABLISHMENT' THEN

        SELECT distinct establishment_name
          INTO l_party_name
          FROM xle_fp_establishment_v
         WHERE party_id = l_party_id;

        if x_party_name_token is null then
          x_party_name_token := l_party_name;
        else
          x_party_name_token := x_party_name_token ||'; '|| l_party_name;
        end if;
        x_error_buffer := 'ZX_REG_NUM_DUPLICATE';
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

    END LOOP;
    CLOSE tax_reg_num_csr;

  EXCEPTION
    WHEN INVALID_CURSOR THEN
      if tax_reg_num_csr%isopen then close tax_reg_num_csr; end if;
      IF c_get_lookup_meaning%ISOPEN THEN
        CLOSE c_get_lookup_meaning;
      END IF;
      IF c_get_party_name%ISOPEN THEN
        CLOSE c_get_party_name;
      END IF;
      IF c_get_party_site_details%ISOPEN THEN
        CLOSE c_get_party_site_details;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_error_buffer := SQLERRM;
      IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_EXCEPTION,
                      G_MODULE_NAME || l_procedure_name,
                      SQLCODE || ': ' || SQLERRM);
      END IF;

    WHEN OTHERS THEN
      if tax_reg_num_csr%isopen then close tax_reg_num_csr; end if;
      IF c_get_lookup_meaning%ISOPEN THEN
        CLOSE c_get_lookup_meaning;
      END IF;
      IF c_get_party_name%ISOPEN THEN
        CLOSE c_get_party_name;
      END IF;
      IF c_get_party_site_details%ISOPEN THEN
        CLOSE c_get_party_site_details;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_error_buffer := SQLERRM;
      IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING(G_LEVEL_EXCEPTION,
                      G_MODULE_NAME || l_procedure_name,
                      SQLCODE || ': ' || SQLERRM);
      END IF;

  END set_msg_details;

  -- Bug 6774002
  --------------------------------------------------------------------------
  PROCEDURE set_cross_msg_details (p_tax_reg_num           IN  VARCHAR2,
                                   p_party_type_code       IN  VARCHAR2,
                                   p_ptp_id                IN  NUMBER,
                                   p_tax_regime_code       IN  VARCHAR2,
                                   p_tax                   IN  VARCHAR2,
                                   p_tax_jurisdiction_code IN  VARCHAR2,
                                   x_party_type_token      OUT NOCOPY VARCHAR2,
                                   x_party_name_token      OUT NOCOPY VARCHAR2,
                                   x_party_site_name_token OUT NOCOPY VARCHAR2,
                                   x_party_site_num_token  OUT NOCOPY VARCHAR2,
                                   x_error_buffer          OUT NOCOPY VARCHAR2,
                                   x_return_status         OUT NOCOPY VARCHAR2) IS
  --------------------------------------------------------------------------
  l_procedure_name  CONSTANT  VARCHAR2(30) := 'set_cross_msg_details';
  l_log_msg            FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
  l_party_name         VARCHAR2(5000) := NULL;
  l_party_site_name    VARCHAR2(5000) := NULL;
  l_party_site_number  VARCHAR2(5000) := NULL;

  BEGIN

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := l_procedure_name||'(+)';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Parameters ';
      l_log_msg :=  l_log_msg||'P_tax_erg_num: '||p_tax_reg_num;
      l_log_msg :=  l_log_msg||'p_ptp_id: '||p_ptp_id;
      l_log_msg :=  l_log_msg||'P_party_type_code: '||p_party_type_code;
      l_log_msg :=  l_log_msg||'P_tax_regime_code: '||p_tax_regime_code;
      l_log_msg :=  l_log_msg||'P_tax: '||p_tax;
      l_log_msg :=  l_log_msg||'P_tax_jurisdiction_code: '||p_tax_jurisdiction_code;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;

    IF p_party_type_code = 'THIRD_PARTY' THEN
      OPEN c_get_lookup_meaning (cp_lookup_type => 'ZX_PTP_PARTY_TYPE'
                                ,cp_lookup_code => 'THIRD_PARTY_SITE');
      FETCH c_get_lookup_meaning INTO x_party_type_token;
      CLOSE c_get_lookup_meaning;

      SELECT HZP.PARTY_NAME,
             HZS.PARTY_SITE_NAME,
             HZS.PARTY_SITE_NUMBER
        INTO l_party_name, l_party_site_name, l_party_site_number
        FROM ZX_REGISTRATIONS REG,
             HZ_PARTY_SITES HZS,
             HZ_PARTIES HZP,
             ZX_PARTY_TAX_PROFILE ZXP
       WHERE HZP.PARTY_ID = HZS.PARTY_ID
         AND HZS.PARTY_SITE_ID = ZXP.PARTY_ID
         AND ZXP.PARTY_TAX_PROFILE_ID = REG.PARTY_TAX_PROFILE_ID
         AND ZXP.PARTY_TYPE_CODE = 'THIRD_PARTY_SITE'
         AND REG.PARTY_TAX_PROFILE_ID NOT IN (SELECT S.PARTY_TAX_PROFILE_ID
                                                FROM ZX_PARTY_TAX_PROFILE S,
                                                     ZX_PARTY_TAX_PROFILE PTP,
                                                     HZ_PARTY_SITES HZPS
                                               WHERE PTP.PARTY_TAX_PROFILE_ID = p_ptp_id
                                                 AND PTP.PARTY_ID = HZPS.PARTY_ID
                                                 AND HZPS.PARTY_SITE_ID = S.PARTY_ID
                                                 AND S.PARTY_TYPE_CODE = 'THIRD_PARTY_SITE')
         AND REG.REGISTRATION_NUMBER = p_tax_reg_num
         AND SYSDATE >= REG.EFFECTIVE_FROM
         AND (SYSDATE <= REG.EFFECTIVE_TO OR REG.EFFECTIVE_TO IS NULL)
         AND ((p_tax_regime_code IS NULL) OR (REG.TAX_REGIME_CODE IS NULL)
              OR (p_tax_regime_code IS NOT NULL AND  REG.TAX_REGIME_CODE = p_tax_regime_code))
         AND ((p_tax IS NULL) OR (REG.TAX IS NULL)
              OR (p_tax IS NOT NULL AND  REG.TAX = p_tax))
         AND ((p_tax_jurisdiction_code IS NULL) OR (REG.TAX_JURISDICTION_CODE IS NULL)
              OR (p_tax_jurisdiction_code IS NOT NULL AND  REG.TAX_JURISDICTION_CODE = p_tax_jurisdiction_code))
         AND ROWNUM = 1;

      if x_party_name_token is null then
         x_party_name_token := l_party_name;
      else
         x_party_name_token := x_party_name_token ||'; '|| l_party_name;
      end if;
      if x_party_site_name_token is null then
         x_party_site_name_token := l_party_site_name;
      else
         x_party_site_name_token := x_party_site_name_token ||'; '|| l_party_site_name;
      end if;
      if x_party_site_num_token is null then
        x_party_site_num_token := l_party_site_number;
      else
        x_party_site_num_token := x_party_site_num_token ||'; '|| l_party_site_number;
      end if;
      IF l_party_site_name IS NOT NULL THEN
        x_error_buffer := 'ZX_REG_NUM_SITE_DUPLICATE';
      ELSE
        x_error_buffer := 'ZX_REG_NUM_SITE_NUMBER_DUP';
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;

    ELSIF p_party_type_code = 'THIRD_PARTY_SITE' THEN
      OPEN c_get_lookup_meaning (cp_lookup_type => 'ZX_PTP_PARTY_TYPE'
                                ,cp_lookup_code => 'THIRD_PARTY');
      FETCH c_get_lookup_meaning INTO x_party_type_token;
      CLOSE c_get_lookup_meaning;

      SELECT HZP.PARTY_NAME
        INTO l_party_name
        FROM ZX_REGISTRATIONS REG,
             HZ_PARTIES HZP,
             ZX_PARTY_TAX_PROFILE ZXP
       WHERE HZP.PARTY_ID = ZXP.PARTY_ID
         AND ZXP.PARTY_TAX_PROFILE_ID = REG.PARTY_TAX_PROFILE_ID
         AND ZXP.PARTY_TYPE_CODE = 'THIRD_PARTY'
         AND REG.PARTY_TAX_PROFILE_ID NOT IN
                          (SELECT S.PARTY_TAX_PROFILE_ID
                           FROM ZX_PARTY_TAX_PROFILE S,
                                ZX_PARTY_TAX_PROFILE PTP,
                                HZ_PARTY_SITES HZPS
                           WHERE PTP.PARTY_TAX_PROFILE_ID = p_ptp_id
                             AND PTP.PARTY_ID = HZPS.PARTY_SITE_ID
                             AND HZPS.PARTY_ID = S.PARTY_ID
                             AND S.PARTY_TYPE_CODE = 'THIRD_PARTY')
         AND REG.REGISTRATION_NUMBER = p_tax_reg_num
         AND SYSDATE >= REG.EFFECTIVE_FROM
         AND (SYSDATE <= REG.EFFECTIVE_TO OR REG.EFFECTIVE_TO IS NULL)
         AND ((p_tax_regime_code IS NULL) OR (REG.TAX_REGIME_CODE IS NULL)
              OR (p_tax_regime_code IS NOT NULL AND  REG.TAX_REGIME_CODE = p_tax_regime_code))
         AND ((p_tax IS NULL) OR (REG.TAX IS NULL)
              OR (p_tax IS NOT NULL AND  REG.TAX = p_tax))
         AND ((p_tax_jurisdiction_code IS NULL) OR (REG.TAX_JURISDICTION_CODE IS NULL)
              OR (p_tax_jurisdiction_code IS NOT NULL AND  REG.TAX_JURISDICTION_CODE = p_tax_jurisdiction_code))
         AND ROWNUM = 1;

      if x_party_name_token is null then
         x_party_name_token := l_party_name;
      else
         x_party_name_token := x_party_name_token ||'; '|| l_party_name;
      end if;
      x_error_buffer := 'ZX_REG_NUM_DUPLICATE';
      x_return_status := FND_API.G_RET_STS_ERROR;
--      x_party_site_name_token := NULL;

    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    WHEN OTHERS THEN
      IF c_get_lookup_meaning%ISOPEN THEN
        CLOSE c_get_lookup_meaning;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_error_buffer := SQLERRM;
      IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_EXCEPTION,
                       G_MODULE_NAME || l_procedure_name,
                       SQLCODE || ': ' || SQLERRM);
      END IF;
  END set_cross_msg_details;
  -- Bug 6774002

  -- Bug 3650600
  --------------------------------------------------------------------------
  PROCEDURE validate_header_trn(p_party_type_code IN  VARCHAR2,
                                p_ptp_id          IN  NUMBER,
                                p_tax_reg_num     IN  VARCHAR2,
                                x_return_status   OUT NOCOPY VARCHAR2) IS
  --------------------------------------------------------------------------

  l_procedure_name  CONSTANT  VARCHAR2(30) := 'validate_header_trn';
  l_log_msg         FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

  BEGIN

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := l_procedure_name||'(+)';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
    END IF;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Parameters ';
      l_log_msg :=  l_log_msg||'P_Party_Type_Code: '||p_party_type_code;
      l_log_msg :=  l_log_msg||'P_ptp_id: '||to_char(p_ptp_id);
      l_log_msg :=  l_log_msg||'P_Tax_Reg_Num: '||p_tax_reg_num;
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;

    -- Third party changes
    IF p_party_type_code = 'THIRD_PARTY_SITE' THEN

      OPEN c_third_party_reg_num(p_ptp_id, p_tax_reg_num);
      LOOP
        FETCH c_third_party_reg_num INTO l_header_reg_num;

        IF c_third_party_reg_num%NOTFOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          CLOSE c_third_party_reg_num;
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg := 'The Tax Registration Number does not exist in header level as Third Party.';
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;
          EXIT;
        ELSE
          x_return_status := FND_API.G_RET_STS_SUCCESS;
          CLOSE c_third_party_reg_num;
          EXIT;
        END IF;
      END LOOP;
      -- Third Party Changes
    ELSIF p_party_type_code = 'LEGAL_ESTABLISHMENT' THEN

      OPEN c_establishment_reg_num(p_ptp_id, p_tax_reg_num);
      LOOP
        FETCH c_establishment_reg_num INTO l_header_reg_num;

        IF c_establishment_reg_num%NOTFOUND THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          CLOSE c_establishment_reg_num;
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg := 'The Tax Registration Number does not exist in header level as 1st Establishment.';
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;
          EXIT;
        ELSE
          x_return_status := FND_API.G_RET_STS_SUCCESS;
          CLOSE c_establishment_reg_num;
          EXIT;
        END IF;
      END LOOP;

    ELSE
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := l_procedure_name||'(-)';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
    END IF;

  END validate_header_trn;

  -- Bug 3650600
  ----------------------------------------------------------------
  PROCEDURE chk_dup_trn_with_no_tax_reg(p_ptp_id                IN  NUMBER,
                                        p_tax_reg_num           IN  VARCHAR2,
                                        p_party_type_code       IN  VARCHAR2,
                                        x_party_type_token      OUT NOCOPY VARCHAR2,
                                        x_party_name_token      OUT NOCOPY VARCHAR2,
                                        x_party_site_name_token OUT NOCOPY VARCHAR2,
                                        x_party_site_num_token  OUT NOCOPY VARCHAR2,
                                        x_error_buffer          OUT NOCOPY VARCHAR2,
                                        x_return_status         OUT NOCOPY VARCHAR2) IS
  ----------------------------------------------------------------

  CURSOR trn_with_no_reg_common_cur(c_ptp_id number, c_registration_number varchar2, c_party_type_code varchar2) IS
    SELECT distinct ptp.party_id,ptp.party_tax_profile_id
    FROM zx_party_tax_profile ptp
    WHERE ptp.rep_registration_number = c_registration_number
      AND ptp.merged_to_ptp_id IS NULL
      AND ptp.party_type_code = c_party_type_code
      AND ptp.party_tax_profile_id <> c_ptp_id;

  CURSOR trn_exists_in_reg_tbl(c_ptp_id number,c_registration_number varchar2) IS
    SELECT party_tax_profile_id
    FROM zx_registrations
    WHERE party_tax_profile_id = c_ptp_id
      AND registration_number = c_registration_number
      AND TRUNC(sysdate) between effective_from and NVL(effective_to,sysdate+1);

  l_party_id    NUMBER;
  l_ptp_id      NUMBER;
  l_total_count NUMBER;
  l_specific_count NUMBER;

  l_party_name              VARCHAR2(5000);
  l_party_site_name         VARCHAR2(5000);
  l_party_site_number       VARCHAR2(5000);
  l_allow_dup_regn_num_flag VARCHAR2(1);

  l_procedure_name  CONSTANT  VARCHAR2(30) := 'chk_dup_trn_with_no_tax_reg';
  l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

  BEGIN
    -- Initialize
    p_return_status := FND_API.G_RET_STS_SUCCESS;
    p_error_buffer := NULL;

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       l_log_msg := 'Parameters ';
       l_log_msg :=  l_log_msg||'P_tax_reg_num: '||p_tax_reg_num;
       l_log_msg :=  l_log_msg||'p_ptp_id: '||p_ptp_id;
       l_log_msg :=  l_log_msg||'party_type_code: '||p_party_type_code;
       l_log_msg :=  l_log_msg||'x_party_type_token: '||x_party_type_token;
       l_log_msg :=  l_log_msg||'x_party_name_token: '||x_party_name_token;
       l_log_msg :=  l_log_msg||'x_party_site_name_token: '||x_party_site_name_token;
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;
    OPEN trn_with_no_reg_common_cur(p_ptp_id,p_tax_reg_num, p_party_type_code);
    FETCH trn_with_no_reg_common_cur INTO l_party_id,l_ptp_id;

    IF trn_with_no_reg_common_cur%FOUND THEN
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name,
                        'Duplicate Exists at same party level');
      END IF;
      IF p_ptp_id <> G_INVALID_PTP_ID THEN
        --
        -- we are creating a new record and the registration number
        -- must not exist any where
        --
        OPEN trn_exists_in_reg_tbl(l_ptp_id,p_tax_reg_num);
        FETCH trn_exists_in_reg_tbl INTO l_ptp_id;
        IF trn_exists_in_reg_tbl%NOTFOUND THEN
          CLOSE trn_exists_in_reg_tbl;
        ELSE
          CLOSE trn_exists_in_reg_tbl;
          return;
        END IF;
      END IF;

      OPEN c_get_lookup_meaning (cp_lookup_type => 'ZX_PTP_PARTY_TYPE'
                                ,cp_lookup_code => p_party_type_code);
      FETCH c_get_lookup_meaning INTO x_party_type_token;
      CLOSE c_get_lookup_meaning;

      IF p_party_type_code = 'THIRD_PARTY' THEN

        OPEN c_get_party_name (cp_party_id => l_party_id);
        FETCH c_get_party_name INTO l_party_name;
        CLOSE c_get_party_name;

        if x_party_name_token is null then
          x_party_name_token := l_party_name;
        else
          x_party_name_token := x_party_name_token ||'; '|| l_party_name;
        end if;
        x_party_site_name_token := NULL;
        p_error_buffer := 'ZX_REG_NUM_DUPLICATE';
        p_return_status := FND_API.G_RET_STS_ERROR;

      ELSIF p_party_type_code = 'THIRD_PARTY_SITE' THEN
        BEGIN
          SELECT distinct ptp.party_id, ptp.party_tax_profile_id
          into l_party_id, l_ptp_id
          FROM zx_party_tax_profile ptp
          where ptp.rep_registration_number = p_tax_reg_num
          and ptp.party_type_code = p_party_type_code
          and ptp.party_tax_profile_id <> p_ptp_id
          AND ptp.merged_to_ptp_id IS NULL
          and not exists (SELECT 1
                          FROM zx_party_tax_profile reg,
                               hz_party_sites hzs,
                               hz_party_sites hzr
                         where reg.party_tax_profile_id = p_ptp_id
                           and ptp.party_id = hzs.party_site_id
                           and reg.party_id = hzr.party_site_id
                           AND reg.merged_to_ptp_id IS NULL
                           and hzs.party_id = hzr.party_id
                         )
          AND ROWNUM = 1;
        EXCEPTION
          WHEN OTHERS THEN
            l_party_id := NULL;
            l_ptp_id := NULL;
        END;

        IF l_party_id IS NOT NULL THEN
          OPEN trn_exists_in_reg_tbl(l_ptp_id,p_tax_reg_num);
          FETCH trn_exists_in_reg_tbl INTO l_ptp_id;
          IF trn_exists_in_reg_tbl%NOTFOUND THEN
            CLOSE trn_exists_in_reg_tbl;
          ELSE
            CLOSE trn_exists_in_reg_tbl;
            return;
          END IF;

          OPEN c_get_party_site_details (cp_party_site_id => l_party_id);
          FETCH c_get_party_site_details INTO l_party_name, l_party_site_name, l_party_site_number;
          CLOSE c_get_party_site_details;

          if x_party_name_token is null then
            x_party_name_token := l_party_name;
          else
            x_party_name_token := x_party_name_token ||'; '|| l_party_name;
          end if;
          if x_party_site_name_token is null then
            x_party_site_name_token := l_party_site_name;
          else
            x_party_site_name_token := x_party_site_name_token ||'; '|| l_party_site_name;
          end if;

          if x_party_site_num_token IS NULL THEN
            x_party_site_num_token := l_party_site_number;
          else
            x_party_site_num_token := x_party_site_num_token ||'; '|| l_party_site_number;
          end if;

          IF l_party_site_name IS NOT NULL THEN
            p_error_buffer := 'ZX_REG_NUM_SITE_DUPLICATE';
          ELSE
            p_error_buffer := 'ZX_REG_NUM_SITE_NUMBER_DUP';
          END IF;
          p_return_status := FND_API.G_RET_STS_ERROR;

        END IF;
      ELSIF p_party_type_code = 'LEGAL_ESTABLISHMENT' THEN
        BEGIN
          SELECT distinct ptp.party_id,ptp.party_tax_profile_id
          into l_party_id,l_ptp_id
          FROM zx_party_tax_profile ptp
          where ptp.rep_registration_number = p_tax_reg_num
          and ptp.party_type_code = p_party_type_code
          and ptp.party_tax_profile_id <> p_ptp_id
          and not exists (SELECT 1
                          FROM xle_fp_establishment_v est,
                               xle_fp_establishment_v estp,
                               zx_party_tax_profile   ptpp
                          where ptpp.party_tax_profile_id = p_ptp_id
                          and ptpp.merged_to_ptp_id IS NULL
                          and estp.party_id = ptpp.party_id
                          and estp.legal_entity_id = est.legal_entity_id
                          and est.party_id = ptp.party_id);
        EXCEPTION
          WHEN OTHERS THEN
            l_party_id := NULL;
            l_ptp_id := NULL;
        END;

        IF l_party_id IS NOT NULL THEN
          OPEN trn_exists_in_reg_tbl(l_ptp_id,p_tax_reg_num);
          FETCH trn_exists_in_reg_tbl INTO l_ptp_id;
          IF trn_exists_in_reg_tbl%NOTFOUND THEN
            CLOSE trn_exists_in_reg_tbl;
          ELSE
            CLOSE trn_exists_in_reg_tbl;
            return;
          END IF;

          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_DUPLICATE';

          SELECT distinct establishment_name
          INTO l_party_name
          FROM xle_fp_establishment_v
          WHERE party_id = l_party_id;

          if x_party_name_token is null then
            x_party_name_token := l_party_name;
          else
            x_party_name_token := x_party_name_token ||'; '|| l_party_name;
          end if;
--          x_party_site_name_token := NULL;
        END IF;
      ELSE
        p_return_status := FND_API.G_RET_STS_SUCCESS;
        x_party_name_token := NULL;
        x_party_site_name_token := NULL;
      END IF; -- Party Type code
    ELSE -- Cross Validation trn_with_no_reg_common_cur%NOTFOUND
      BEGIN
        SELECT COUNT(PTP.rep_registration_number)
        INTO l_total_count
        FROM ZX_PARTY_TAX_PROFILE PTP
        WHERE PTP.rep_registration_number = p_tax_reg_num
        AND ptp.merged_to_ptp_id IS NULL
        AND ptp.party_tax_profile_id <> p_ptp_id;
      EXCEPTION
        WHEN OTHERS THEN
          l_total_count := 0;
      END;

      IF l_total_count > 0 THEN
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name,
                          'Duplicate exists at Other Party Level');
        END IF;

        IF p_party_type_code = 'THIRD_PARTY' THEN
          BEGIN
            SELECT count(S.PARTY_TAX_PROFILE_ID)
            INTO l_specific_count
            FROM ZX_PARTY_TAX_PROFILE S,
                 ZX_PARTY_TAX_PROFILE PTP,
                 HZ_PARTY_SITES HZPS
            WHERE PTP.PARTY_TAX_PROFILE_ID = P_PTP_ID
            AND PTP.PARTY_ID = HZPS.PARTY_ID
            AND HZPS.PARTY_SITE_ID = S.PARTY_ID
            AND S.REP_REGISTRATION_NUMBER = P_TAX_REG_NUM
            AND s.merged_to_ptp_id IS NULL
            AND S.PARTY_TYPE_CODE = 'THIRD_PARTY_SITE';
          EXCEPTION
            WHEN OTHERS THEN
              l_specific_count := 0;
          END;
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name,'Count: '||l_specific_count);
          END IF;
          IF l_total_count <> l_specific_count THEN

            OPEN c_get_lookup_meaning (cp_lookup_type => 'ZX_PTP_PARTY_TYPE'
                                      ,cp_lookup_code => 'THIRD_PARTY_SITE');
            FETCH c_get_lookup_meaning INTO x_party_type_token;
            CLOSE c_get_lookup_meaning;

            SELECT ZXP.PARTY_TAX_PROFILE_ID,HZP.PARTY_NAME,
                    HZS.PARTY_SITE_NAME,
                    HZS.PARTY_SITE_NUMBER
            INTO l_ptp_id,l_party_name, l_party_site_name, l_party_site_number
            FROM HZ_PARTY_SITES HZS,
                 HZ_PARTIES HZP,
                 ZX_PARTY_TAX_PROFILE ZXP
            WHERE HZP.PARTY_ID = HZS.PARTY_ID
            AND HZS.PARTY_SITE_ID = ZXP.PARTY_ID
            AND ZXP.PARTY_TYPE_CODE = 'THIRD_PARTY_SITE'
            AND NOT EXISTS (SELECT PTP.PARTY_TAX_PROFILE_ID
                            FROM ZX_PARTY_TAX_PROFILE PTP,
                                 HZ_PARTY_SITES HZPS
                            WHERE PTP.PARTY_TAX_PROFILE_ID = p_ptp_id
                            AND ptp.merged_to_ptp_id IS NULL
                            AND PTP.PARTY_ID = HZPS.PARTY_ID(+)
                            AND (HZPS.PARTY_SITE_ID IS NULL
                                    OR HZPS.PARTY_SITE_ID = ZXP.PARTY_ID))
            AND ZXP.REP_REGISTRATION_NUMBER = p_tax_reg_num
            AND ROWNUM = 1;

            IF p_ptp_id <> G_INVALID_PTP_ID THEN
              --
              -- we are creating a new record and the registration number
              -- must not exist any where
              --
              OPEN trn_exists_in_reg_tbl(l_ptp_id,p_tax_reg_num);
              FETCH trn_exists_in_reg_tbl INTO l_ptp_id;
              IF trn_exists_in_reg_tbl%NOTFOUND THEN
                CLOSE trn_exists_in_reg_tbl;
              ELSE
                CLOSE trn_exists_in_reg_tbl;
                return;
              END IF;
            END IF;

            if x_party_name_token is null then
              x_party_name_token := l_party_name;
            else
              x_party_name_token := x_party_name_token ||'; '|| l_party_name;
            end if;
            if x_party_site_name_token is null then
              x_party_site_name_token := l_party_site_name;
            else
              x_party_site_name_token := x_party_site_name_token ||'; '|| l_party_site_name;
            end if;

            if x_party_site_num_token IS NULL THEN
              x_party_site_num_token := l_party_site_number;
            else
              x_party_site_num_token := x_party_site_num_token ||'; '|| l_party_site_number;
            end if;

            IF l_party_site_name IS NOT NULL THEN
              p_error_buffer := 'ZX_REG_NUM_SITE_DUPLICATE';
            ELSE
              p_error_buffer := 'ZX_REG_NUM_SITE_NUMBER_DUP';
            END IF;

            p_return_status := FND_API.G_RET_STS_ERROR;
            p_error_buffer := 'ZX_REG_NUM_DUPLICATE';
          END IF;
        ELSIF p_party_type_code = 'THIRD_PARTY_SITE' THEN
          BEGIN
            SELECT count(s.party_tax_profile_id)
            into l_specific_count
            FROM zx_party_tax_profile s,
                 zx_party_tax_profile ptp,
                 hz_party_sites hzps
            where ptp.party_tax_profile_id = p_ptp_id
            and ptp.party_id = hzps.party_site_id
            and hzps.party_id = s.party_id
            and ptp.rep_registration_number = p_tax_reg_num
            AND s.merged_to_ptp_id IS NULL
            and s.party_type_code = 'THIRD_PARTY';
          EXCEPTION
            WHEN OTHERS THEN
              l_specific_count := 0;
          END;
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name,'Count: '||l_specific_count);
          END IF;
          IF l_total_count <> l_specific_count THEN

            OPEN c_get_lookup_meaning (cp_lookup_type => 'ZX_PTP_PARTY_TYPE'
                                      ,cp_lookup_code => 'THIRD_PARTY');
            FETCH c_get_lookup_meaning INTO x_party_type_token;
            CLOSE c_get_lookup_meaning;

            SELECT ZXP.PARTY_TAX_PROFILE_ID,HZP.PARTY_NAME
            INTO l_ptp_id,l_party_name
            FROM HZ_PARTIES HZP,
                 ZX_PARTY_TAX_PROFILE ZXP
            WHERE HZP.PARTY_ID = ZXP.PARTY_ID
            AND ZXP.PARTY_TYPE_CODE = 'THIRD_PARTY'
            AND NOT EXISTS (SELECT S.PARTY_TAX_PROFILE_ID
                            FROM ZX_PARTY_TAX_PROFILE S,
                                 ZX_PARTY_TAX_PROFILE PTP,
                                 HZ_PARTY_SITES HZPS
                            WHERE PTP.PARTY_TAX_PROFILE_ID = p_ptp_id
                            AND PTP.PARTY_ID = HZPS.PARTY_SITE_ID
                            AND HZPS.PARTY_ID = S.PARTY_ID
                            AND S.merged_to_ptp_id IS NULL
                            AND S.PARTY_TYPE_CODE = 'THIRD_PARTY'
                            AND S.PARTY_TAX_PROFILE_ID = ZXP.PARTY_TAX_PROFILE_ID)
            AND ZXP.REP_REGISTRATION_NUMBER = p_tax_reg_num
            AND ROWNUM = 1;

            IF p_ptp_id <> G_INVALID_PTP_ID THEN
              --
              -- we are creating a new record and the registration number
              -- must not exist any where
              --
              OPEN trn_exists_in_reg_tbl(l_ptp_id,p_tax_reg_num);
              FETCH trn_exists_in_reg_tbl INTO l_ptp_id;
              IF trn_exists_in_reg_tbl%NOTFOUND THEN
                CLOSE trn_exists_in_reg_tbl;
              ELSE
                CLOSE trn_exists_in_reg_tbl;
                return;
              END IF;
            END IF;

            if x_party_name_token is null then
              x_party_name_token := l_party_name;
            else
              x_party_name_token := x_party_name_token ||'; '|| l_party_name;
            end if;
            x_party_site_name_token := NULL;

            p_return_status := FND_API.G_RET_STS_ERROR;
            p_error_buffer := 'ZX_REG_NUM_DUPLICATE';
          END IF;
        END IF; -- Party Type Code
      END IF; -- Total Count
    END IF;
    CLOSE trn_with_no_reg_common_cur;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_get_lookup_meaning%ISOPEN THEN
        CLOSE c_get_lookup_meaning;
      END IF;
      IF c_get_party_name%ISOPEN THEN
        CLOSE c_get_party_name;
      END IF;
      IF c_get_party_site_details%ISOPEN THEN
        CLOSE c_get_party_site_details;
      END IF;
      IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_EXCEPTION,
                      G_MODULE_NAME || l_procedure_name,
                      SQLCODE || ': ' || SQLERRM);

        x_party_type_token      := NULL;
        x_party_name_token      := NULL;
        x_party_site_name_token := NULL;
        p_error_buffer          := SQLCODE || ': ' || SQLERRM;
        p_return_status         := FND_API.G_RET_STS_UNEXP_ERROR;
      END IF;
  END chk_dup_trn_with_no_tax_reg;


                      /*********************************/
                      /* Main Section for VALIDATE_TRN */
                      /*********************************/

BEGIN

  G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_msg := l_procedure_name||'(+)';
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin main', l_log_msg);
  END IF;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_msg := 'Parameters';
    l_log_msg :=  l_log_msg||' p_country_code: '||p_country_code;
    l_log_msg :=  l_log_msg||' p_tax_reg_num: '||p_tax_reg_num;
    l_log_msg :=  l_log_msg||' p_tax_regime_code: '||p_tax_regime_code;
    l_log_msg :=  l_log_msg||' p_tax: '||p_tax;
    l_log_msg :=  l_log_msg||' p_ptp_id: '||p_ptp_id;
    l_log_msg :=  l_log_msg||' p_trn_type: '||p_trn_type;
    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME || l_procedure_name, l_log_msg);
    FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME || l_procedure_name,
         'Cached values PTP :'||g_ptp_id||': TRN :'||g_trn||': Country: '||g_country_code);
  END IF;

  /***** Tax Registration Number Validation ******/

  l_trn := p_tax_reg_num;
  l_tax_regime_code := p_tax_regime_code;
  l_tax := p_tax;
  l_trn_type := p_trn_type;
  l_party_type_code := p_party_type_code;
  l_tax_regime_code := p_tax_regime_code;
  l_tax := p_tax;
  l_tax_jurisdiction_code := p_tax_jurisdiction_code;
  l_country_code := p_country_code;

  -- donot use NVL for p_ptp_id here
  IF (     p_ptp_id = g_ptp_id
       AND l_trn = g_trn
       AND NVL(l_country_code, G_MISS_CHAR) = NVL(g_country_code, G_MISS_CHAR)
       AND p_tax is NULL
       AND p_tax_regime_code is NULL ) THEN
    p_return_status := FND_API.G_RET_STS_SUCCESS;
    p_error_buffer := NULL;
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name,'TRN is already validated in earlier call, skipping all other validations');
    END IF;
    RETURN;
  ELSE
    -- 10402027
    -- Since we have common validation for both supplier and customer in R12,
    -- the records created in 11i failing with unique check validation.
    --
    -- Rep Registration Number will not be populated in party tax profile unless
    -- the validation is completed eventhough we are updating one of the upgraded
    -- party tax profile. So the below query fails and go for normal validation.
    BEGIN
      SELECT rep_registration_number
      INTO l_trn
      FROM zx_party_tax_profile
      WHERE party_tax_profile_id = p_ptp_id
      AND rep_registration_number = p_tax_reg_num
      AND NVL(country_code,G_MISS_CHAR) = NVL(l_country_code,G_MISS_CHAR)
      AND merged_to_ptp_id IS NULL
      AND record_type_code = 'MIGRATED'
      AND NOT EXISTS(SELECT 1 FROM zx_registrations reg
                      WHERE reg.party_tax_profile_id = p_ptp_id
                        AND reg.registration_number = p_tax_reg_num);
      p_return_status := FND_API.G_RET_STS_SUCCESS;
      p_error_buffer := NULL;
      IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME || l_procedure_name,'TRN is created in 11i or validated already');
      END IF;
      return;
    EXCEPTION
      WHEN OTHERS THEN
        IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
          FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME || l_procedure_name,
            'TRN is entered newly OR existing R12 record being modified OR migrated data''s registration number being modified');
        END IF;
        l_trn := p_tax_reg_num;
    END;
    -- 10402027
  END IF;

  IF NVL(p_ptp_id,G_INVALID_PTP_ID) <> g_ptp_id OR p_tax_regime_code is NOT NULL THEN
    IF p_tax_regime_code IS NULL THEN
      BEGIN
        SELECT allow_dup_regn_num_flag
        INTO l_allow_regn_num_flag
        FROM zx_registrations reg, zx_taxes_b t
        WHERE reg.party_tax_profile_id = NVL(p_ptp_id,G_INVALID_PTP_ID)
        AND reg.registration_number = p_tax_reg_num
        AND TRUNC(sysdate) between reg.effective_from and NVL(reg.effective_to,sysdate+1)
        AND t.tax_regime_code = reg.tax_regime_code
        AND t.tax = reg.tax
        AND ROWNUM = 1;

        IF NVL(l_allow_regn_num_flag,'N') = 'Y' THEN
          p_return_status := FND_API.G_RET_STS_SUCCESS;
          p_error_buffer := NULL;
          IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME || l_procedure_name,
              'Duplicate registration number allowed as the PTP registration is associated with tax that allows duplicate registration numbers');
          END IF;
          RETURN;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

      BEGIN
        SELECT t.allow_dup_regn_num_flag
        INTO l_allow_regn_num_flag
        FROM zx_registrations reg,zx_taxes_b t,zx_party_tax_profile ptp
        WHERE ptp.party_tax_profile_id = NVL(p_ptp_id,G_INVALID_PTP_ID)
        AND ptp.rep_registration_number = p_tax_reg_num
        AND ptp.merged_to_ptp_id IS NULL
        AND reg.registration_number = p_tax_reg_num
        AND reg.party_tax_profile_id <> p_ptp_id
        AND TRUNC(sysdate) between reg.effective_from and NVL(reg.effective_to,sysdate+1)
        AND t.tax_regime_code = reg.tax_regime_code
        AND t.tax = reg.tax
        AND ROWNUM = 1;

        IF NVL(l_allow_regn_num_flag,'N') = 'Y' THEN
          p_return_status := FND_API.G_RET_STS_SUCCESS;
          p_error_buffer := NULL;
          IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
            FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME || l_procedure_name,
              'Duplicate registration number allowed as another REG was associated with tax regime that allows duplicate registration numbers');
          END IF;
          RETURN;
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
    END IF;
    l_allow_regn_num_flag := NULL;
  END IF;

  IF l_trn is NULL THEN -- l_trn is NULL

     IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       l_log_msg := 'The Tax Registration Number is not passed.  No need of any validation.';
       FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME || l_procedure_name, l_log_msg);
     END IF;
     p_return_status := FND_API.G_RET_STS_SUCCESS;
     p_error_buffer := NULL;

  ELSE -- l_trn is NULL

    to_be_chached_ptp_id := NVL(p_ptp_id,G_INVALID_PTP_ID);

    IF p_tax IS NOT NULL THEN
      OPEN c_AllowDupRegnNum;
      FETCH c_AllowDupRegnNum INTO l_allow_regn_num_flag;
      CLOSE c_AllowDupRegnNum;

      IF l_allow_regn_num_flag = 'Y' THEN
        l_pass_unique_check := FND_API.G_RET_STS_SUCCESS;
      ELSE
        unique_trn(l_trn, l_party_type_code, l_tax_regime_code,
                   l_tax, l_tax_jurisdiction_code, to_be_chached_ptp_id,
                   l_pass_unique_check
                   );
      END IF;
    ELSE
      unique_trn(l_trn, l_party_type_code, l_tax_regime_code,
                 l_tax, l_tax_jurisdiction_code, to_be_chached_ptp_id,
                 l_pass_unique_check);
    END IF;

    IF l_pass_unique_check = 'E' THEN -- l_pass_unique_check = 'E'

      IF l_party_type_code = 'THIRD_PARTY' THEN -- l_party_type_code if clause

        p_return_status := FND_API.G_RET_STS_ERROR;
        set_msg_details (p_tax_reg_num           => l_trn,
                         p_party_type_code       => 'THIRD_PARTY',
                         p_tax_regime_code       => l_tax_regime_code,
                         p_tax                   => l_tax,
                         p_tax_jurisdiction_code => l_tax_jurisdiction_code,
                         x_party_type_token      => l_party_type,
                         x_party_name_token      => l_party_name,
                         x_party_site_name_token => l_party_site_name,
                         x_party_site_num_token  => l_party_site_number,
                         x_error_buffer          => p_error_buffer,
                         x_return_status         => p_return_status);
        x_party_type_token := l_party_type;
        x_party_name_token := l_party_name;
        x_party_site_name_token := NULL;
        -- Bug 3650600

      ELSIF l_party_type_code = 'THIRD_PARTY_SITE' THEN -- l_party_type_code if clause

        validate_header_trn('THIRD_PARTY_SITE', to_be_chached_ptp_id, p_tax_reg_num, l_header_check);

        IF l_header_check = 'E' THEN
          set_msg_details (p_tax_reg_num           => l_trn,
                           p_party_type_code       => 'THIRD_PARTY_SITE',
                           p_tax_regime_code       => l_tax_regime_code,
                           p_tax                   => l_tax,
                           p_tax_jurisdiction_code => l_tax_jurisdiction_code,
                           x_party_type_token      => l_party_type,
                           x_party_name_token      => l_party_name,
                           x_party_site_name_token => l_party_site_name,
                           x_party_site_num_token  => l_party_site_number,
                           x_error_buffer          => p_error_buffer,
                           x_return_status         => p_return_status);

          x_party_type_token := l_party_type;
          x_party_name_token := l_party_name;
          IF p_error_buffer = 'ZX_REG_NUM_SITE_NUMBER_DUP' THEN
            x_party_site_name_token := l_party_site_number;
          ELSE
            x_party_site_name_token := l_party_site_name;
          END IF;
        ELSE
          p_return_status := FND_API.G_RET_STS_SUCCESS;
        END IF;

      ELSIF l_party_type_code = 'LEGAL_ESTABLISHMENT' THEN -- l_party_type_code if clause

        validate_header_trn('LEGAL_ESTABLISHMENT',to_be_chached_ptp_id, p_tax_reg_num, l_header_check);

        IF l_header_check = 'E' THEN
          set_msg_details (p_tax_reg_num           => l_trn,
                           p_party_type_code       => 'LEGAL_ESTABLISHMENT',
                           p_tax_regime_code       => l_tax_regime_code,
                           p_tax                   => l_tax,
                           p_tax_jurisdiction_code => l_tax_jurisdiction_code,
                           x_party_type_token      => l_party_type,
                           x_party_name_token      => l_party_name,
                           x_party_site_name_token => l_party_site_name,
                           x_party_site_num_token  => l_party_site_number,
                           x_error_buffer          => p_error_buffer,
                           x_return_status         => p_return_status);
          x_party_type_token := l_party_type;
          x_party_name_token := l_party_name;
          x_party_site_name_token := NULL;
        ELSE
          p_return_status := FND_API.G_RET_STS_SUCCESS;
        END IF;

        -- Bug 3650600

      ELSE -- l_party_type_code if clause

        p_return_status := FND_API.G_RET_STS_ERROR;
        p_error_buffer := 'ZX_REG_NUM_INVALID';
      END IF; -- l_party_type_code if clause

    ELSE -- l_pass_unique_check = 'E'

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'Before the Call to Cross Registration number validation ';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      -- Added for Cross Registration number validation (6774002)
      BEGIN
        SELECT COUNT(REG.REGISTRATION_NUMBER)
           INTO l_total_count
           FROM ZX_REGISTRATIONS REG,
                ZX_PARTY_TAX_PROFILE PTP
          WHERE PTP.PARTY_TAX_PROFILE_ID = REG.PARTY_TAX_PROFILE_ID
            AND REG.REGISTRATION_NUMBER = l_trn
            AND ptp.merged_to_ptp_id IS NULL
            AND PTP.PARTY_TAX_PROFILE_ID <> to_be_chached_ptp_id
            AND SYSDATE >= REG.EFFECTIVE_FROM
            AND (SYSDATE <= REG.EFFECTIVE_TO OR REG.EFFECTIVE_TO IS NULL)
            AND ((l_tax_regime_code IS NULL) OR (REG.TAX_REGIME_CODE IS NULL)
                    OR (l_tax_regime_code IS NOT NULL AND  REG.TAX_REGIME_CODE = l_tax_regime_code))
            AND ((l_tax IS NULL) OR (REG.TAX IS NULL)
                    OR (l_tax IS NOT NULL AND  REG.TAX = l_tax))
            AND ((l_tax_jurisdiction_code IS NULL) OR (REG.TAX_JURISDICTION_CODE IS NULL)
                    OR (l_tax_jurisdiction_code IS NOT NULL AND  REG.TAX_JURISDICTION_CODE = l_tax_jurisdiction_code));
      EXCEPTION
        WHEN OTHERS THEN
          l_total_count := 0;
      END;

      IF l_total_count > 0 THEN  -- Cross Validation if clause
        IF ( p_tax IS NULL OR nvl(l_allow_regn_num_flag,'N') <> 'Y' ) THEN
          IF L_PARTY_TYPE_CODE = 'THIRD_PARTY' THEN
            BEGIN
              SELECT COUNT(REGISTRATION_NUMBER)
                INTO l_specific_count
                FROM ZX_REGISTRATIONS REG
               WHERE REG.PARTY_TAX_PROFILE_ID IN
                          (SELECT S.PARTY_TAX_PROFILE_ID
                           FROM ZX_PARTY_TAX_PROFILE S,
                                ZX_PARTY_TAX_PROFILE PTP,
                                HZ_PARTY_SITES HZPS
                           WHERE PTP.PARTY_TAX_PROFILE_ID = to_be_chached_ptp_id
                             AND PTP.PARTY_ID = HZPS.PARTY_ID
                             AND HZPS.PARTY_SITE_ID = S.PARTY_ID
                             AND s.merged_to_ptp_id IS NULL
                             AND S.PARTY_TYPE_CODE = 'THIRD_PARTY_SITE')
                AND REG.REGISTRATION_NUMBER = l_trn
                AND SYSDATE >= REG.EFFECTIVE_FROM
                AND (SYSDATE <= REG.EFFECTIVE_TO OR REG.EFFECTIVE_TO IS NULL)
                AND ((l_tax_regime_code IS NULL) OR (REG.TAX_REGIME_CODE IS NULL)
                        OR (l_tax_regime_code IS NOT NULL AND  REG.TAX_REGIME_CODE = l_tax_regime_code))
                AND ((l_tax IS NULL) OR (REG.TAX IS NULL)
                        OR (l_tax IS NOT NULL AND  REG.TAX = l_tax))
                AND ((l_tax_jurisdiction_code IS NULL) OR (REG.TAX_JURISDICTION_CODE IS NULL)
                        OR (l_tax_jurisdiction_code IS NOT NULL AND  REG.TAX_JURISDICTION_CODE = l_tax_jurisdiction_code));
            EXCEPTION
              WHEN OTHERS THEN
                l_specific_count := 0;
            END;
            IF l_total_count <> l_specific_count THEN
              set_cross_msg_details (p_tax_reg_num           => l_trn,
                                     p_party_type_code       => 'THIRD_PARTY',
                                     p_ptp_id                => to_be_chached_ptp_id,
                                     p_tax_regime_code       => l_tax_regime_code,
                                     p_tax                   => l_tax,
                                     p_tax_jurisdiction_code => l_tax_jurisdiction_code,
                                     x_party_type_token      => l_party_type,
                                     x_party_name_token      => l_party_name,
                                     x_party_site_name_token => l_party_site_name,
                                     x_party_site_num_token  => l_party_site_number,
                                     x_error_buffer          => p_error_buffer,
                                     x_return_status         => p_return_status);
              x_party_type_token := l_party_type;
              x_party_name_token := l_party_name;
              IF p_error_buffer = 'ZX_REG_NUM_SITE_NUMBER_DUP' THEN
                x_party_site_name_token := l_party_site_number;
              ELSE
                x_party_site_name_token := l_party_site_name;
              END IF;
            ELSE
              p_return_status := FND_API.G_RET_STS_SUCCESS;
              p_error_buffer := NULL;
            END IF;
          ELSIF L_PARTY_TYPE_CODE = 'THIRD_PARTY_SITE' THEN
            validate_header_trn('THIRD_PARTY_SITE', to_be_chached_ptp_id, p_tax_reg_num, l_header_check);
            IF l_header_check = 'E' THEN
              set_cross_msg_details (p_tax_reg_num           => l_trn,
                                     p_party_type_code       => 'THIRD_PARTY_SITE',
                                     p_ptp_id                => to_be_chached_ptp_id,
                                     p_tax_regime_code       => l_tax_regime_code,
                                     p_tax                   => l_tax,
                                     p_tax_jurisdiction_code => l_tax_jurisdiction_code,
                                     x_party_type_token      => l_party_type,
                                     x_party_name_token      => l_party_name,
                                     x_party_site_name_token => l_party_site_name,
                                     x_party_site_num_token  => l_party_site_number,
                                     x_error_buffer          => p_error_buffer,
                                     x_return_status         => p_return_status);
              x_party_type_token := l_party_type;
              x_party_name_token := l_party_name;
              IF p_error_buffer = 'ZX_REG_NUM_SITE_NUMBER_DUP' THEN
                x_party_site_name_token := l_party_site_number;
              ELSE
                x_party_site_name_token := l_party_site_name;
              END IF;
            ELSE
              p_return_status := FND_API.G_RET_STS_SUCCESS;
              p_error_buffer := NULL;
            END IF;
          END IF;
        ELSE
          p_return_status := FND_API.G_RET_STS_SUCCESS;
          p_error_buffer := NULL;
        END IF;

      ELSE -- Cross Validation returned 0 rows

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'Cross Validation returned 0 rows. Now Calling chk_dup_trn_with_no_tax_reg';
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
        END IF;
        --Added For Bug 7552460
        IF (p_tax IS NULL OR nvl(l_allow_regn_num_flag,'N') <> 'Y') THEN
          chk_dup_trn_with_no_tax_reg(p_ptp_id  => to_be_chached_ptp_id,
                                      p_tax_reg_num => l_trn,
                                      p_party_type_code => l_party_type_code,
                                      x_party_type_token => x_party_type_token,
                                      x_party_name_token => x_party_name_token,
                                      x_party_site_name_token => x_party_site_name_token,
                                      x_party_site_num_token => l_party_site_number,
                                      x_error_buffer => p_error_buffer,
                                      x_return_status => p_return_status);
            IF p_error_buffer = 'ZX_REG_NUM_SITE_NUMBER_DUP' THEN
              x_party_site_name_token := l_party_site_number;
            END IF;
            IF p_return_status = 'E' THEN
              RETURN;
            END IF;
        END IF;
        -----------------------------------------------------------------
        -- Note to developers
        -----------------------------------------------------------------
        --
        -- Custom hook validation existing code START
        -- this code needs to be tested when completing enh 4658881
        -- a. handle any exceptions returned from the custom package
        -- b. make sure that the return status is documented in the custom
        --    package ZX_TRN_CUSTOM_VAL_PKG.VALIDATE_TRN_CUSTOM
        --       return status 0 -> valid
        --       return status 1 -> invalid
        -- c. What is the significance of p_return_status in conjunction with
        --    function return status
        -- d. custom hook must be called mandatorily.   Check if this can be
        --    moved to the fag end of the VALIDATE_TRN routine
        -- e. overall code return status must be success only if
        --    the standard code is successful AND
        --    custom code is also successful
        -- f. Similar changes needs to be done in package ZX_PTP_IMPORT
        --
        -----------------------------------------------------------------
        l_custom := 0;

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'Before calling VALIDATE_TRN_CUSTOM '||l_custom;
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME || l_procedure_name, l_log_msg);
        END IF;
        -- Custom Validation.
        l_custom := ZX_TRN_CUSTOM_VAL_PKG.VALIDATE_TRN_CUSTOM(l_trn,
                       l_trn_type,
                       l_pass_unique_check,
                       p_country_code,
                       p_return_status,
                       p_error_buffer);

        IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'After Call to VALIDATE_TRN_CUSTOM  '||l_custom;
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME || l_procedure_name, l_log_msg);
          FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME || l_procedure_name,
           ' p_return_status:'||p_return_status||' p_error_buffer:'||p_error_buffer);
        END IF;

        IF l_custom = 1 THEN
          -- custom validation has failed with error
          IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'Custom rountine to validate tax registration number returned error';
            FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;
          RETURN;
        END IF;
        -----------------------------------------------------------------
        -- Custom hook validation existing code END
        -----------------------------------------------------------------

        --
        IF (l_country_code = 'AT') THEN -- l_country_code if clause
        -- if the country name is Austria check the Tax Registration Number
        --
          ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_AT(l_trn,
                l_trn_type,
                l_pass_unique_check,
                p_return_status,
                p_error_buffer);
        --
        ELSIF (l_country_code = 'BE') THEN
        -- if the country name is Belgium check the Tax Registration Number
        --
          ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_BE(l_trn,
                l_trn_type,
                l_pass_unique_check,
                p_return_status,
                p_error_buffer);
        --
        ELSIF (l_country_code= 'DK') THEN
        -- if the country name is Denmark check the Tax Registration Number
        --
          ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_DK(l_trn,
                l_trn_type,
                l_pass_unique_check,
                p_return_status,
                p_error_buffer);
        --
        ELSIF (l_country_code = 'EE') THEN
        -- if the country name is Estonia check the Tax Registration Number
        --
          ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_EE(l_trn,
                l_trn_type,
                l_pass_unique_check,
                p_return_status,
                p_error_buffer);
        --
        ELSIF (l_country_code = 'FI') THEN
        -- if the country name is Finland check the Tax Registration Number
        --
          ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_FI(l_trn,
                l_trn_type,
                l_pass_unique_check,
                p_return_status,
                p_error_buffer);
        --
        ELSIF (l_country_code = 'FR') THEN
        -- if the country name is France check the Tax Registration Number
        --
          ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_FR(l_trn,
                l_trn_type,
                l_pass_unique_check,
                p_return_status,
                p_error_buffer);
        --
        ELSIF (l_country_code = 'DE') THEN
        -- if the country name is Germany check the Tax Registration Number
        --
          ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_DE(l_trn,
                l_trn_type,
                l_pass_unique_check,
                p_return_status,
                p_error_buffer);
        --
       ELSIF (l_country_code = 'GR') THEN
        -- if the country name is GREECE check the Tax Registration Number
        --
          ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_GR(l_trn,
                l_trn_type,
                l_pass_unique_check,
                p_return_status,
                p_error_buffer);
        --
        ELSIF (l_country_code = 'IE') THEN
        -- if the country name is IRELAND check the Tax Registration Number
        --
          ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_IE(l_trn,
                l_trn_type,
                l_pass_unique_check,
                p_return_status,
                p_error_buffer);
        --
        ELSIF (l_country_code = 'IT') THEN
        -- if the country name is Italy check the Tax Registration Number
        --
          ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_IT(l_trn,
                l_trn_type,
                l_pass_unique_check,
                p_return_status,
                p_error_buffer);
        --
        ELSIF (l_country_code = 'LU') THEN
        -- if the country name is Luxembourg check the Tax Registration Number
        --
          ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_LU(l_trn,
                l_trn_type,
                l_pass_unique_check,
                p_return_status,
                p_error_buffer);
        --
        ELSIF (l_country_code = 'NL') THEN
        -- if the country name is Netherlands check the Tax Registration Number
        --
          ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_NL(l_trn,
                l_trn_type,
                l_pass_unique_check,
                p_return_status,
                p_error_buffer);
        --
        ELSIF (l_country_code = 'PL') THEN
        -- if the country name is Poland check the Tax Registration Number
        --
          ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_PL(l_trn,
                l_trn_type,
                l_pass_unique_check,
                p_return_status,
                p_error_buffer);
        --
        ELSIF (l_country_code = 'PT') THEN
        -- if the country name is Portugal check the Tax Registration Number
        --
          ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_PT(l_trn,
                l_trn_type,
                l_pass_unique_check,
                p_return_status,
                p_error_buffer);
        --
        ELSIF (l_country_code = 'SK') THEN
        -- if the country name is Slovakia check the Tax Registration Number
        --
          ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_SK(l_trn,
                l_trn_type,
                l_pass_unique_check,
                p_return_status,
                p_error_buffer);
        --
        ELSIF (l_country_code = 'ES')  THEN
        -- if the country name is Spain check the Tax Registration Number
        --
          ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_ES(l_trn,
                l_trn_type,
                l_pass_unique_check,
                p_return_status,
                p_error_buffer);
        --
        ELSIF (l_country_code = 'SE') THEN
        -- if the country name is Sweden check the Tax Registration Number
        --
          ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_SE(l_trn,
                l_trn_type,
                l_pass_unique_check,
                p_return_status,
                p_error_buffer);
        --
        ELSIF (l_country_code = 'CH') THEN
        -- if the country name is Swizerland check the Tax Registration Number
        --
          ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_CH(l_trn,
                l_trn_type,
                l_pass_unique_check,
                p_return_status,
                p_error_buffer);
        --
        ELSIF (l_country_code = 'GB') THEN
        -- if the country name is United Kingdom check the Tax Registration Number
        --
          ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_GB(l_trn,
                l_trn_type,
                l_pass_unique_check,
                p_return_status,
                p_error_buffer);
        --
        ELSIF (l_country_code = 'RU') THEN
        -- if the country name is Russia check the Tax Registration Number
        --
          ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_RU(l_trn,
                l_trn_type,
                l_pass_unique_check,
                p_return_status,
                p_error_buffer);
        --
        ELSIF (l_country_code = 'HU') THEN
        -- if the country name is Hungary check the Tax Registration Number
        --
          ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_HU(l_trn,
                l_trn_type,
                l_pass_unique_check,
                p_return_status,
                p_error_buffer);
        --
        ELSIF (l_country_code = 'AR') THEN
        -- if the country name is Argentina check the Tax Registration Number
        --
          ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_AR(l_trn,
                l_trn_type,
                p_return_status,
                p_error_buffer);
        --
        ELSIF (l_country_code = 'CL') THEN
        -- if the country name is Chile check the Tax Registration Number
        --
          ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_CL(l_trn,
                p_return_status,
                p_error_buffer);
        --
        ELSIF (l_country_code = 'CO') THEN
        -- if the country name is Colombia check the Tax Registration Number
        --
          ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_CO(l_trn,
                p_return_status,
                p_error_buffer);
        --
        ELSIF (l_country_code = 'TW') THEN
        -- if the country name is Taiwan check the Tax Registration Number
        --
          ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_TW(l_trn,
                p_return_status,
                p_error_buffer);
        --
        ELSIF (l_country_code = 'BR') THEN
        -- if the country name is Brazil check the Tax Registration Number
        --
          ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_BR(l_trn,
                l_trn_type,
                p_return_status,
                p_error_buffer);
        --
        ELSIF (l_country_code = 'MT') THEN
        -- if the country name is Malta check the Tax Registration Number
        --
          ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_MT(l_trn,
                l_trn_type,
                l_pass_unique_check,
                p_return_status,
                p_error_buffer);
        --
        ELSIF (l_country_code = 'CY') THEN
        -- if the country name is Cyprus check the Tax Registration Number
        --
          ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_CY(l_trn,
                l_trn_type,
                l_pass_unique_check,
                p_return_status,
                p_error_buffer);
        --
        ELSIF (l_country_code = 'LV') THEN
        -- if the country name is Latvia check the Tax Registration Number
        --
          ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_LV(l_trn,
                l_trn_type,
                l_pass_unique_check,
                p_return_status,
                p_error_buffer);
        --
        ELSIF (l_country_code = 'LT') THEN
        -- if the country name is Lithuania check the Tax Registration Number
        --
          ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_LT(l_trn,
                l_trn_type,
                l_pass_unique_check,
                p_return_status,
                p_error_buffer);
        --
        ELSIF (l_country_code = 'SI') THEN
        -- if the country name is Slovenia check the Tax Registration Number
        --
          ZX_TRN_VALIDATION_PKG.VALIDATE_TRN_SI(l_trn,
                l_trn_type,
                l_pass_unique_check,
                p_return_status,
                p_error_buffer);
        --
        ELSE
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg := 'There is no validation rule of this country';
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;
          p_return_status := FND_API.G_RET_STS_SUCCESS;
          p_error_buffer := NULL;
        --
        END IF;   -- l_country_code if clause
      END IF;  -- Cross Validation if clause
    END IF; -- l_pass_unique_check = 'E'

  END IF;  -- l_trn is NULL

  IF p_return_status = 'E' THEN
    g_trn := NULL;
    g_country_code := NULL;
    g_ptp_id := NULL;
  ELSE
    g_trn := l_trn;
    g_country_code := NVL(p_country_code,G_MISS_CHAR);
    g_ptp_id := to_be_chached_ptp_id;
  END IF;

  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_msg := l_procedure_name||'(-)';
    FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.end', l_log_msg);
  END IF;

EXCEPTION
  WHEN INVALID_CURSOR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    -- bug 20032400
    g_trn := NULL;
    g_country_code := NULL;
    p_error_buffer := SQLERRM;
    IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_EXCEPTION,
                    G_MODULE_NAME || l_procedure_name,
                    SQLCODE || ': ' || SQLERRM);
    END IF;

  WHEN OTHERS THEN
    -- bug 20032400
    g_trn := NULL;
    g_country_code := NULL;
    IF ora_error_number(p_error_string => SQLERRM) = 6502 THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      p_error_buffer := 'ZX_REG_NUM_INVALID';
    ELSE
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      p_error_buffer := SQLERRM;
    END IF;
    IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_EXCEPTION,
                    G_MODULE_NAME || l_procedure_name,
                    SQLCODE || ': ' || SQLERRM);
    END IF;

END VALIDATE_TRN;

/****************  End of PROCEDURE validate_trn ***********/


PROCEDURE VALIDATE_TRN_AT (p_trn               IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2)
                              AS

trn_value       VARCHAR2(50);
at_prefix       VARCHAR2(3);
check_digit     VARCHAR2(1);
position_5      VARCHAR2(2);
position_7      VARCHAR2(2);
position_9      VARCHAR2(2);
sum_579         VARCHAR2(2);
sum_46810       VARCHAR2(2);
result_sum      VARCHAR2(2);
calc_ckd        VARCHAR2(1);
check_result_AT VARCHAR2(1);
l_trn_type      VARCHAR2(30);

l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN_AT';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

  procedure fail_uniqueness is
  begin

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'The Tax Registration Number is already used.';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;

    p_return_status := FND_API.G_RET_STS_ERROR;
    p_error_buffer := 'ZX_REG_NUM_INVALID';

  end fail_uniqueness;

  procedure fail_check is
  begin

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       l_log_msg := 'Failed the validation of the Tax Registration Number.';
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;

    p_return_status := FND_API.G_RET_STS_ERROR;
    p_error_buffer := 'ZX_REG_NUM_INVALID';
  end fail_check;

  procedure pass_check is
  begin

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       l_log_msg := 'The Tax Registration Number is valid.';
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;

    p_return_status := FND_API.G_RET_STS_SUCCESS;
    p_error_buffer := NULL;
  end pass_check;

  procedure check_numeric_AT (check_numeric_result OUT NOCOPY VARCHAR2) is
    num_check VARCHAR2(40);
  begin
    num_check := '';
    num_check := nvl(
                    rtrim(
                  translate(substr(trn_value,4,8),
                            '1234567890',
                            '          ')
                                           ), '0'
                                                       );
    IF num_check <> '0' THEN
      check_numeric_result := FND_API.G_RET_STS_ERROR;
    ELSE
      check_numeric_result := FND_API.G_RET_STS_SUCCESS;
    END IF;
  end check_numeric_AT;


                           /****************/
                           /* MAIN SECTION */
                           /****************/

BEGIN

trn_value := upper(p_trn);
AT_PREFIX := substr(trn_value,1,3);
check_digit := substr(trn_value,11,1);
trn_value := replace(trn_value,' ','');

G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := l_procedure_name||'(+)';
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
END IF;

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := 'Parameters ';
  l_log_msg :=  l_log_msg||'p_trn: '||p_trn;
  l_log_msg :=  l_log_msg||' p_trn_type: '||p_trn_type;
  l_log_msg :=  l_log_msg||' p_check_unique_flag: '||p_check_unique_flag;
  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
END IF;

IF p_check_unique_flag = 'E' THEN
    fail_uniqueness;

ELSIF p_check_unique_flag = 'S' THEN

 --IF p_trn_type = 'VAT' THEN

   check_numeric_AT(check_result_AT);

   IF check_result_AT = 'S' then -- IF1
      position_5 := substr(trn_value,5,1)*2;
      position_7 := substr(trn_value,7,1)*2;
      position_9 := substr(trn_value,9,1)*2;

      IF length(trn_value) = 11 THEN -- if2

        IF AT_PREFIX = 'ATU' THEN -- if3

            /* Calculate Check Digit for Austria  */

          sum_579 := substr(position_5,1,1) + nvl(substr(position_5,2,1),0) +
                     substr(position_7,1,1) + nvl(substr(position_7,2,1),0) +
                     substr(position_9,1,1) + nvl(substr(position_9,2,1),0);

          sum_46810 := substr(trn_value,4,1) + substr(trn_value,6,1) +
                       substr(trn_value,8,1) + substr(trn_value,10,1);

          result_sum := (100-(sum_579+sum_46810+4));

          calc_ckd := substr(result_sum,length(result_sum),1);

          IF calc_ckd = check_digit THEN
             pass_check;
          ELSE
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               l_log_msg := 'Check digit is incorrect.';
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
            END IF;
            p_return_status := FND_API.G_RET_STS_ERROR;
            p_error_buffer := 'ZX_REG_NUM_INVALID';
          END IF;

        ELSE -- if3
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg := 'The prefix of Tax Registration Number is incorrect.';
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;
          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_INVALID';
       END IF; -- if3

     ELSE  -- if2

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'The Tax Registration Number is too short.';
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
        END IF;
        IF length(trn_value) > 11 THEN
           p_return_status := FND_API.G_RET_STS_ERROR;
           p_error_buffer  := 'ZX_REG_NUM_TOO_BIG';
        ELSE
           p_return_status := FND_API.G_RET_STS_ERROR;
           p_error_buffer  := 'ZX_REG_NUM_INVALID';
        END IF;

     END IF; -- if2

    ELSE -- if1

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'The Tax Registration Number contains an alphanumeric character where a numeric character is expected.';
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;
       p_return_status := FND_API.G_RET_STS_ERROR;
       p_error_buffer := 'ZX_REG_NUM_INVALID_ALPHA';

   END IF; -- if1

END IF;

END VALIDATE_TRN_AT;

/* ***********    End VALIDATE_TRN_AT       ****************** */


PROCEDURE VALIDATE_TRN_BE (p_trn               IN  VARCHAR2,
                           p_trn_type          IN  VARCHAR2,
                           p_check_unique_flag IN  VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2)
                           AS

trn_value       VARCHAR2(50);
BE_PREFIX       VARCHAR2(3);
check_digit     VARCHAR2(2);
check_digit_1   VARCHAR2(2);
check_digit_2   VARCHAR2(2);
numeric_result  VARCHAR2(40);
l_trn_type      VARCHAR2(30);

l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN_BE';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

  procedure fail_uniqueness is
  begin

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'The Tax Registration Number is already used.';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;

    p_return_status := FND_API.G_RET_STS_ERROR;
    p_error_buffer := 'ZX_REG_NUM_INVALID';

  end fail_uniqueness;

  procedure fail_check is
  begin

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       l_log_msg := 'Failed the validation of the tax registration number.';
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;

    p_return_status := FND_API.G_RET_STS_ERROR;
    p_error_buffer := 'ZX_REG_NUM_INVALID';
  end fail_check;

  procedure pass_check is
  begin

    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       l_log_msg := 'The Tax Registration Number is valid.';
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;

    p_return_status := FND_API.G_RET_STS_SUCCESS;
    p_error_buffer := NULL;
  end pass_check;

                     /************************************/
                     /* MAIN SECTION for VALIDATE_TRN_BE */
                     /************************************/

BEGIN

G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := l_procedure_name||'(+)';
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
END IF;

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := 'Parameters ';
  l_log_msg :=  l_log_msg||'p_trn: '||p_trn;
  l_log_msg :=  l_log_msg||' p_trn_type: '||p_trn_type;
  l_log_msg :=  l_log_msg||' p_check_unique_flag: '||p_check_unique_flag;
  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
END IF;

trn_value := upper(p_trn);
BE_PREFIX := substr(trn_value,1,2);
check_digit := substr(trn_value,10,2);
check_digit_1 := substr(trn_value,11,2);
check_digit_2 := substr(trn_value,9,2);

trn_value := replace(trn_value,' ','');

IF p_check_unique_flag = 'E' THEN
  fail_uniqueness;

ELSIF p_check_unique_flag = 'S' THEN

  --IF p_trn_type = 'VAT' THEN

  IF BE_PREFIX = 'BE' THEN

    numeric_result := common_check_numeric(trn_value,3,length(trn_value));

    IF numeric_result = '0' then
      /* its numeric so continue  */
      IF length(trn_value) = 11
        then
        IF check_digit = 97-mod(substr(trn_value,3,7),97) then
          pass_check;
        ELSE
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg := 'Check digit is not match.';
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;
          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer  := 'ZX_REG_NUM_INVALID';

        END IF;

      ELSIF length(trn_value) = 12 THEN
        IF substr(trn_value,3,1) = 0 OR substr(trn_value,3,1) = 1
          then
          IF check_digit_1 = 97-mod(substr(trn_value,4,7),97) then
            pass_check;
          ELSE

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'Check digit is not match.';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
            END IF;
            p_return_status := FND_API.G_RET_STS_ERROR;
            p_error_buffer  := 'ZX_REG_NUM_INVALID';

          END IF;

        ELSE

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'The 3rd character should be 0 or 1.';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_INVALID';

        END IF;

      ELSE

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'The length of the Tax Registration Number is not correct.';
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
        END IF;

        IF length(trn_value) > 12 THEN
          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer  := 'ZX_REG_NUM_TOO_BIG';
        ELSIF length(trn_value) < 8 THEN
          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer  := 'ZX_REG_NUM_INVALID';
        END IF;

      END IF;

    ELSE

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'The Tax Registration Number contains an alphanumeric character where a numeric character is expected.';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      p_return_status := FND_API.G_RET_STS_ERROR;
      p_error_buffer := 'ZX_REG_NUM_INVALID_ALPHA';

    END IF;

  ELSE

    numeric_result := common_check_numeric(trn_value,1,length(trn_value));

    IF numeric_result = '0'
      then
      /* its numeric so continue  */
      IF substr(trn_value,1,1) = 0 OR substr(trn_value,1,1) = 1
        then
        IF length(trn_value) = 10
          then
          IF check_digit_2 = 97-mod(substr(trn_value,2,7),97) then
            pass_check;
          ELSE

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               l_log_msg := 'Check digit is not match.';
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
            END IF;

            p_return_status := FND_API.G_RET_STS_ERROR;
            p_error_buffer := 'ZX_REG_NUM_INVALID';

          END IF;
        ELSE

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'The length of the Tax Registration Number is not correct.';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;
          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer  := 'ZX_REG_NUM_INVALID';

        END IF;

      ELSE
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'The first number of the Tax Registration Number is not 0 or 1.';
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
        END IF;

        p_return_status := FND_API.G_RET_STS_ERROR;
        p_error_buffer := 'ZX_REG_NUM_INVALID';
      END IF;

    ELSE

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'The Tax Registration Number contains an alphanumeric character where a numeric character is expected.';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      p_return_status := FND_API.G_RET_STS_ERROR;
      p_error_buffer := 'ZX_REG_NUM_INVALID_ALPHA';

    END IF;

  END IF;

END IF;

END VALIDATE_TRN_BE;


/* ***********    End VALIDATE_TRN_BE       ****************** */


PROCEDURE VALIDATE_TRN_DK (p_trn_value         IN  VARCHAR2,
                           p_trn_type          IN  VARCHAR2,
                           p_check_unique_flag IN  VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2)
                           AS

-- Logging Infra
l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN_DK';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := l_procedure_name||'(+)';
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
END IF;

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := 'Parameters ';
  l_log_msg :=  l_log_msg||'p_trn_value: '||p_trn_value;
  l_log_msg :=  l_log_msg||' p_trn_type: '||p_trn_type;
  l_log_msg :=  l_log_msg||' p_check_unique_flag: '||p_check_unique_flag;
  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
END IF;

IF p_check_unique_flag = 'E' THEN

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'The Tax Registration Number is already used.';
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

   p_return_status := FND_API.G_RET_STS_ERROR;
   p_error_buffer := 'ZX_REG_NUM_INVALID';

ELSIF p_check_unique_flag = 'S' THEN

 --IF p_trn_type = 'VAT' THEN

    /*  check length = 10, prefix = 'DK' and the last eight digits are numeric     */
   IF length(p_trn_value) = 10 and substr(p_trn_value,1,2) = 'DK' and
      common_check_numeric(p_trn_value,3,length(p_trn_value)) = '0' THEN
   --

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'Passed Validation: Length is 10, prefix is DK, and last eight digits are numeric.';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      p_return_status := FND_API.G_RET_STS_SUCCESS;
      p_error_buffer := NULL;
   ELSE

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'Failed Validation: Length is 10, prefix is DK, and last eight digits are numeric.';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      p_return_status := FND_API.G_RET_STS_ERROR;
      p_error_buffer := 'ZX_REG_NUM_INVALID';
   --
   END IF;

END IF;

END VALIDATE_TRN_DK;

/* ***********    End VALIDATE_TRN_DK       ****************** */


PROCEDURE VALIDATE_TRN_EE (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2)
                           AS

l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN_EE';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := l_procedure_name||'(+)';
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
END IF;

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := 'Parameters ';
  l_log_msg :=  l_log_msg||'p_trn_value: '||p_trn_value;
  l_log_msg :=  l_log_msg||' p_trn_type: '||p_trn_type;
  l_log_msg :=  l_log_msg||' p_check_unique_flag: '||p_check_unique_flag;
  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
END IF;

IF p_check_unique_flag = 'E' THEN

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'The Tax Registration Number is already used.';
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

   p_return_status := FND_API.G_RET_STS_ERROR;
   p_error_buffer := 'ZX_REG_NUM_INVALID';

ELSIF p_check_unique_flag = 'S' THEN

 --IF p_trn_type = 'VAT' THEN

    /*  check length = 11, prefix = 'EE' and the last nine digits are numeric     */
   IF length(p_trn_value) = 11 and substr(p_trn_value,1,2) = 'EE' AND
      common_check_numeric(p_trn_value,3,length(p_trn_value)) = '0' THEN

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'Passed Validation: Length is 11, prefix is EE, and last nine digits are numeric.';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

         p_return_status := FND_API.G_RET_STS_SUCCESS;
          p_error_buffer := NULL;
   ELSE

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'Failed Validation: Length is 11, prefix is EE, and last nine digits are numeric.';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      p_return_status := FND_API.G_RET_STS_ERROR;
      p_error_buffer := 'ZX_REG_NUM_INVALID';
--
   END IF;

END IF;

END VALIDATE_TRN_EE;

/* ***********    End VALIDATE_TRN_EE       ****************** */

PROCEDURE VALIDATE_TRN_FI (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2)
                           AS

l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN_FI';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := l_procedure_name||'(+)';
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
END IF;

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := 'Parameters ';
  l_log_msg :=  l_log_msg||'p_trn_value: '||p_trn_value;
  l_log_msg :=  l_log_msg||' p_trn_type: '||p_trn_type;
  l_log_msg :=  l_log_msg||' p_check_unique_flag: '||p_check_unique_flag;
  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
END IF;

IF p_check_unique_flag = 'E' THEN

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'The Tax Registration Number is already used.';
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

   p_return_status := FND_API.G_RET_STS_ERROR;
   p_error_buffer := 'ZX_REG_NUM_INVALID';

ELSIF p_check_unique_flag = 'S' THEN

 --IF p_trn_type = 'VAT' THEN

    /*  check length = 10, prefix = 'FI' and the last eight digits are numeric  */

   IF length(p_trn_value) = 10 and substr(p_trn_value,1,2) = 'FI' and
      common_check_numeric(p_trn_value,3,length(p_trn_value)) = '0' THEN

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'Passed Validation: Length is 10, prefix is FI, and last eight digits are numeric.';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      p_return_status := FND_API.G_RET_STS_SUCCESS;
      p_error_buffer := NULL;
   ELSE

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'Failed Validation: Length is 10, prefix is FI, and last eight digits are numeric.';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

       p_return_status := FND_API.G_RET_STS_ERROR;
       p_error_buffer := 'ZX_REG_NUM_INVALID';

   END IF;

END IF;

END VALIDATE_TRN_FI;

/* ***********    End VALIDATE_TRN_FI       ****************** */

PROCEDURE VALIDATE_TRN_FR (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2)
                           AS

l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN_FR';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

function check_letter(check_value VARCHAR2,
                                    pos NUMBER)
                                    RETURN VARCHAR2
IS
   letter_check VARCHAR2(2);

BEGIN

     IF substr(check_value,pos,1) between 'A' and 'Z' and
        substr(check_value,pos,1) not in ('I','O')  THEN
     --
  letter_check := '0';
     ELSE
  letter_check := '1';
     --
     END IF;

RETURN(letter_check);
END check_letter;
--
BEGIN

G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := l_procedure_name||'(+)';
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
END IF;

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := 'Parameters ';
  l_log_msg :=  l_log_msg||'p_trn_value: '||p_trn_value;
  l_log_msg :=  l_log_msg||' p_trn_type: '||p_trn_type;
  l_log_msg :=  l_log_msg||' p_check_unique_flag: '||p_check_unique_flag;
  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
END IF;

IF p_check_unique_flag = 'E' THEN

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'The Tax Registration Number is already used.';
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

   p_return_status := FND_API.G_RET_STS_ERROR;
   p_error_buffer := 'ZX_REG_NUM_INVALID';

ELSIF p_check_unique_flag = 'S' THEN

 --IF p_trn_type = 'VAT' THEN

    /*  check length = 13, prefix = 'FR' and the last nine digits are numeric     */
   IF length(p_trn_value) = 13 and substr(p_trn_value,1,2) = 'FR' and
      common_check_numeric(p_trn_value,5,length(p_trn_value)) = '0' THEN
   --
      IF (check_letter(p_trn_value,3) = '0' or common_check_numeric(p_trn_value,3,1) = '0') and
         (check_letter(p_trn_value,4) = '0' or common_check_numeric(p_trn_value,4,1) = '0') THEN
      --

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg := 'Passed Validation: Length is 13, prefix is FR, and last nine digits are numeric.';
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

          p_return_status := FND_API.G_RET_STS_SUCCESS;
          p_error_buffer := NULL;
      ELSE

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg := 'Failed Validation: Length is 13, prefix is FR, and last nine digits are numeric.';
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_INVALID';
      --
      END IF;
   ELSE

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'Failed Validation: Length is 13, prefix is FR, and last nine digits are numeric.';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      p_return_status := FND_API.G_RET_STS_ERROR;
      p_error_buffer := 'ZX_REG_NUM_INVALID';

   --
   END IF;

END IF;

END VALIDATE_TRN_FR;

/* ***********    End VALIDATE_TRN_FR      ****************** */


PROCEDURE VALIDATE_TRN_DE (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2)
                           AS
l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN_DE';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := l_procedure_name||'(+)';
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
END IF;

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := 'Parameters ';
  l_log_msg :=  l_log_msg||'p_trn_value: '||p_trn_value;
  l_log_msg :=  l_log_msg||' p_trn_type: '||p_trn_type;
  l_log_msg :=  l_log_msg||' p_check_unique_flag: '||p_check_unique_flag;
  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
END IF;

IF p_check_unique_flag = 'E' THEN

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'The Tax Registration Number is already used.';
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

   p_return_status := FND_API.G_RET_STS_ERROR;
   p_error_buffer := 'ZX_REG_NUM_INVALID';

ELSIF p_check_unique_flag = 'S' THEN

 --IF p_trn_type = 'VAT' THEN
   /*  check length = 11, prefix = 'DE' and the last nine digits are numeric     */
   IF length(p_trn_value) = 11 and substr(p_trn_value,1,2) = 'DE' and
      common_check_numeric(p_trn_value,3,length(p_trn_value)) = '0' THEN

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       l_log_msg := 'Passed Validation: Length is 11, prefix is DE, and last nine digits are numeric.';
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
     END IF;

     p_return_status := FND_API.G_RET_STS_SUCCESS;
     p_error_buffer := NULL;
   ELSE

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       l_log_msg := 'Failed Validation: Length is 11, prefix is DE, and last nine digits are numeric.';
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
     END IF;

     p_return_status := FND_API.G_RET_STS_ERROR;
     p_error_buffer := 'ZX_REG_NUM_INVALID';

   END IF;

END IF;

END VALIDATE_TRN_DE;

/* ***********    End VALIDATE_TRN_DE       ****************** */

PROCEDURE VALIDATE_TRN_GR (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2)
                           AS

trn_string     VARCHAR2(50);
position_i     number(2);
integer_value     number(1);
multiplied_number  number(38);
multiplied_sum     number(38) := 0;
check_digit    number(3);

l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN_GR';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := l_procedure_name||'(+)';
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
END IF;

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := 'Parameters ';
  l_log_msg :=  l_log_msg||'p_trn_value: '||p_trn_value;
  l_log_msg :=  l_log_msg||' p_trn_type: '||p_trn_type;
  l_log_msg :=  l_log_msg||' p_check_unique_flag: '||p_check_unique_flag;
  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
END IF;

trn_string := substr(p_trn_value,3,length(p_trn_value));

IF p_check_unique_flag = 'E' THEN

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'The Tax Registration Number is already used.';
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

   p_return_status := FND_API.G_RET_STS_ERROR;
   p_error_buffer := 'ZX_REG_NUM_INVALID';

ELSIF p_check_unique_flag = 'S' THEN

 --IF p_trn_type = 'VAT' THEN

   /*   check length = 11, prefix = 'GR' or 'EL' and the last nine digits are numeric */

   IF length(p_trn_value) = 11 and
      (substr(p_trn_value,1,2) = 'GR' OR substr(p_trn_value,1,2) = 'EL') and
      common_check_numeric(trn_string,1,9) = '0' THEN
   --
             FOR position_i IN 1..8 loop
       --
               integer_value := substr(trn_string,position_i,1);
               multiplied_number := integer_value * power(2,(9-position_i));
               multiplied_sum := multiplied_sum + multiplied_number;
       --
             END LOOP;
             check_digit := mod(multiplied_sum,11);

             IF check_digit = 10 then
       --
                check_digit := 0;
       --
             END IF;
             IF check_digit = substr(TRN_STRING,9,1) then
       --

               IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  l_log_msg := 'Passed Validation: Length is 11, prefix is GR, and last nine digits are numeric.';
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
               END IF;

               p_return_status := FND_API.G_RET_STS_SUCCESS;
               p_error_buffer := NULL;
             ELSE

               IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  l_log_msg := 'Failed Validation: Length is 11, prefix is GR, and last nine digits are numeric.';
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
               END IF;

               p_return_status := FND_API.G_RET_STS_ERROR;
               p_error_buffer := 'ZX_REG_NUM_INVALID';
       --
             END IF;
   ELSE

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg := 'Failed Validation: Length is 11, prefix is GR, and last nine digits are numeric.';
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_INVALID';
   --
   END IF;

END IF;

END VALIDATE_TRN_GR;

/* ***********    End VALIDATE_TRN_GR       ****************** */

PROCEDURE VALIDATE_TRN_IE (p_trn_value         IN  VARCHAR2,
                           p_trn_type          IN  VARCHAR2,
                           p_check_unique_flag IN  VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2)
                           AS

l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN_IE';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

function check_letter(check_value VARCHAR2,
                      pos         NUMBER)
                      RETURN VARCHAR2
IS
   letter_check VARCHAR2(2);

BEGIN

     IF substr(check_value,pos,1) between 'A' and 'Z' THEN
--
  letter_check := '0';
     ELSE
  letter_check := '1';
--
     END IF;

RETURN(letter_check);
END check_letter;
--
/****************  end of FUNCTION check_letter *******************/

BEGIN

G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := l_procedure_name||'(+)';
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
END IF;

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := 'Parameters ';
  l_log_msg :=  l_log_msg||'p_trn_value: '||p_trn_value;
  l_log_msg :=  l_log_msg||' p_trn_type: '||p_trn_type;
  l_log_msg :=  l_log_msg||' p_check_unique_flag: '||p_check_unique_flag;
  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
END IF;

IF p_check_unique_flag = 'E' THEN

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'The Tax Registration Number is already used.';
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

   p_return_status := FND_API.G_RET_STS_ERROR;
   p_error_buffer := 'ZX_REG_NUM_INVALID';

ELSIF p_check_unique_flag = 'S' THEN

  IF length(p_trn_value) = 10 and substr(p_trn_value,1,2) = 'IE' and check_letter(p_trn_value,length(p_trn_value)) = '0' THEN

      IF common_check_numeric(p_trn_value,3,length(p_trn_value)-4) = '0' THEN
          --
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'Passed Validation: Length is 10, prefix is IE, and last eight digits are numeric.';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

          p_return_status := FND_API.G_RET_STS_SUCCESS;
          p_error_buffer := NULL;
      ELSIF common_check_numeric(p_trn_value,4,length(p_trn_value)-5) = '0' and check_letter(p_trn_value,1) = '0' THEN
          --
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg := 'Passed Validation: Length is 10, prefix is IE, and last eight digits are numeric.';
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

          p_return_status := FND_API.G_RET_STS_SUCCESS;
          p_error_buffer := NULL;

      ELSIF common_check_numeric(p_trn_value,5,length(p_trn_value)-5) = '0' and check_letter(p_trn_value,1) = '0' THEN
          --
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg := 'Passed Validation: Length is 10, prefix is IE, and last five digits are numeric.';
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

          p_return_status := FND_API.G_RET_STS_SUCCESS;
          p_error_buffer := NULL;

      ELSE
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg := 'Failed Validation: Length is 10, prefix is IE, and last eight digits are numeric.';
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_INVALID';
          --
      END IF;

  ELSIF length(p_trn_value) = 11 and substr(p_trn_value,1,2) = 'IE' THEN

     IF check_letter(p_trn_value,length(p_trn_value)-1) = '0'
       AND substr(p_trn_value,length(p_trn_value),1) in ('A','H')
       AND common_check_numeric(p_trn_value,3,length(p_trn_value)-4) = '0' THEN
          --
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'Passed Validation: Length is 11, prefix is IE, and next 7 digits are numeric, next 2 digist are alpha where last Char is A/H';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;

       p_return_status := FND_API.G_RET_STS_SUCCESS;
       p_error_buffer := NULL;

     ELSE
       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'Failed Validation Check for : Length 11, prefix IE, next 7 digits numeric, next 2 digits  alpha where last Char is A/H';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         l_log_msg := 'Failed Old Validation as well : Length is 10, prefix is IE, and last eight digits are numeric.';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;

        p_return_status := FND_API.G_RET_STS_ERROR;
        p_error_buffer := 'ZX_REG_NUM_INVALID';
     END IF;

  ELSE
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Failed Validation: Length is 10, prefix is IE, and last eight digits are numeric.';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;

    p_return_status := FND_API.G_RET_STS_ERROR;
    p_error_buffer := 'ZX_REG_NUM_INVALID';

  END IF;

END IF;

END VALIDATE_TRN_IE;

/* ***********    End VALIDATE_TRN_IE       ****************** */

PROCEDURE VALIDATE_TRN_IT (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2)
                           AS

trn_string       VARCHAR2(50);
tr_num               VARCHAR2(50);
check_digit          NUMBER(1);
position_i           NUMBER(2);
integer_value        NUMBER(1);
calc_check           NUMBER(2);
calc_cd              VARCHAR2(1);
indicator            VARCHAR2(1);
even_value           NUMBER(2);
even_sub_tot         NUMBER(4);
even_tot             NUMBER(5);
odd_tot              NUMBER(5);
check_tot            NUMBER(6);

l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN_IT';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

procedure fail_uniqueness is
begin

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_msg := 'The Tax Registration Number is already used.';
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;

  p_return_status := FND_API.G_RET_STS_ERROR;
  p_error_buffer := 'ZX_REG_NUM_INVALID';
end fail_uniqueness;

procedure fail_check is
begin

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_msg := 'Failed the validation of the tax registration number.';
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;

  p_return_status := FND_API.G_RET_STS_ERROR;
  p_error_buffer := 'ZX_REG_NUM_INVALID';
end fail_check;

PROCEDURE pass_check IS
BEGIN

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_msg := 'The Tax Registration Number is valid.';
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;

  p_return_status :=  FND_API.G_RET_STS_SUCCESS;
  p_error_buffer := NULL;
END pass_check;

/** procedure to check that the chars sent are numeric only **/
/** if ok, then sends back the output as a number **/

PROCEDURE check_numeric(input_string IN VARCHAR2,
                        output_val   OUT NOCOPY VARCHAR2,
                        flag1        OUT NOCOPY VARCHAR2) IS

num_check VARCHAR2(50);
var1      VARCHAR2(50);

begin
   num_check := '';
   var1 := input_string;
   num_check := nvl(rtrim( translate(var1, '1234567890',
                                            '          ')
                         ), '0'
                    );

   IF num_check <> '0' THEN
        flag1 := FND_API.G_RET_STS_ERROR;
        output_val  := '0';
   ELSE
        flag1 := FND_API.G_RET_STS_SUCCESS;
        output_val  := var1;
   END IF;

END check_numeric;

                            /****************/
                            /* MAIN SECTION */
                            /****************/

BEGIN
indicator := '';
odd_tot := 0;
even_tot := 0;

G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := l_procedure_name||'(+)';
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
END IF;

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := 'Parameters ';
  l_log_msg :=  l_log_msg||'p_trn_value: '||p_trn_value;
  l_log_msg :=  l_log_msg||' p_trn_type: '||p_trn_type;
  l_log_msg :=  l_log_msg||' p_check_unique_flag: '||p_check_unique_flag;
  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
END IF;

IF common_check_numeric(p_trn_value,1,2) <> '0' THEN
--
   IF substr(p_trn_value,1,2) <> 'IT' THEN
   --
  p_return_status := FND_API.G_RET_STS_ERROR;
  p_error_buffer := 'ZX_REG_NUM_INVALID';
   ELSE
   --
  trn_string := substr(p_trn_value,3, length(p_trn_value));
   --
   END IF;
ELSE
--
  trn_string := p_trn_value;
--
END IF;

/** ensure that p_trn_value passed in is only numeric **/
check_numeric(trn_string, TR_NUM, indicator);
check_digit := substr(TR_NUM, (length(TR_NUM)));

IF p_check_unique_flag = 'E' THEN

    fail_uniqueness;

ELSIF p_check_unique_flag = 'S' THEN

 --IF p_trn_type = 'VAT' THEN

  /**  make sure that TR Num code is only 11 chars - including Check digit **/
  IF (length(TR_NUM) = 11) AND (indicator = 'S')
    then

       FOR position_i IN 1..10 LOOP

   /** moves along length of Tax Registration Num and assigns weightings  **/
   /** to each of the digits upto and including the 10th position         **/
   /** all odd positioned integers are added together. All evenly         **/
   /** postitioned integers are multiplied by 2, if greater than          **/
   /** 10, the digits are added together. The last digit of the           **/
   /** sum totals when added together is subtracted from 10 - unless      **/
   /** already zero. This becomes the TR Num check digit                  **/

            integer_value := substr(TR_NUM,position_i,1);

            IF position_i in (2,4,6,8,10)
              then
                even_value := integer_value * 2;
                IF even_value > 9
                  then
                    even_sub_tot := substr(even_value,1,1) +
                                    substr(even_value,2,1);
                ELSE
                    even_sub_tot := even_value;
                END IF;
                even_tot := even_tot + even_sub_tot;
            ELSE
                odd_tot := odd_tot + integer_value;
            END IF;

       END LOOP;   /** of the counter position_i **/

       check_tot := odd_tot + even_tot;

       IF substr(check_tot,length(check_tot),1) = 0
          then
             calc_cd := 0;
       ELSE
             calc_cd := 10 - substr(check_tot, length(check_tot),1);
       END IF;

       /*** After having calculated what should be the Italian Tax Num ***/
       /*** Check digit compare to the actual and fail if not the same ***/

       IF calc_cd <> check_digit THEN
         fail_check;
       ELSE
         pass_check;
       END IF;

  ELSE
    fail_check; /** Tax registration number is incorrect length or is not numeric**/
  END IF;

ELSE
   pass_check;

END IF;  /** of fail uniqueness check **/

END VALIDATE_TRN_IT;

/* ***********    End of VALIDATE_TRN_IT   ****************** */

--
PROCEDURE VALIDATE_TRN_LU (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2)
                           AS

l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN_LU';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := l_procedure_name||'(+)';
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
END IF;

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := 'Parameters ';
  l_log_msg :=  l_log_msg||'p_trn_value: '||p_trn_value;
  l_log_msg :=  l_log_msg||'p_trn_type: '||p_trn_type;
  l_log_msg :=  l_log_msg||' p_check_unique_flag: '||p_check_unique_flag;
  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
END IF;

IF p_check_unique_flag = 'E' THEN

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'The Tax Registration Number is already used.';
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

   p_return_status := FND_API.G_RET_STS_ERROR;
   p_error_buffer := 'ZX_REG_NUM_INVALID';

ELSIF p_check_unique_flag = 'S' THEN

 --IF p_trn_type = 'VAT' THEN

   /*  check length = 10, prefix = 'LU' and the last eight digits are numeric     */

   IF length(p_trn_value) = 10 and substr(p_trn_value,1,2) = 'LU' and
      common_check_numeric(p_trn_value,3,length(p_trn_value)) = '0' THEN
--

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       l_log_msg := 'Passed Validation: Length is 10, prefix is LU, and last eight digits are numeric.';
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
     END IF;

     p_return_status := FND_API.G_RET_STS_SUCCESS;
     p_error_buffer := NULL;
   ELSE

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       l_log_msg := 'Failed Validation: Length is 10, prefix is LU, and last eight digits are numeric.';
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
     END IF;

     p_return_status := FND_API.G_RET_STS_ERROR;
     p_error_buffer := 'ZX_REG_NUM_INVALID';
--
   END IF;

END IF;

END VALIDATE_TRN_LU;

/* ***********    End VALIDATE_TRN_LU       ****************** */

PROCEDURE VALIDATE_TRN_SK (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2)
                           AS

l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN_SK';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
trn_value VARCHAR2(50);

BEGIN

G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := l_procedure_name||'(+)';
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
END IF;

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := 'Parameters ';
  l_log_msg :=  l_log_msg||'p_trn_value: '||p_trn_value;
  l_log_msg :=  l_log_msg||' p_trn_type: '||p_trn_type;
  l_log_msg :=  l_log_msg||' p_check_unique_flag: '||p_check_unique_flag;
  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
END IF;

IF p_check_unique_flag = FND_API.G_RET_STS_ERROR THEN

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_msg := 'The Tax Registration Number is already used.';
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;

   p_return_status := FND_API.G_RET_STS_ERROR;
   p_error_buffer := 'ZX_REG_NUM_INVALID';

ELSIF p_check_unique_flag = 'S' THEN

   trn_value := upper(p_trn_value);

 --IF p_trn_type = 'VAT' THEN

    /*  check length = 12 and they are numeric     */
   IF (length(p_trn_value) = 12 and common_check_numeric(p_trn_value,1,12) = '0') OR
      (length(p_trn_value) = 9  and common_check_numeric(p_trn_value,1,9) = '0' ) OR
      (length(p_trn_value) = 10 and common_check_numeric(p_trn_value,1,10) = '0') THEN
--

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       l_log_msg := 'Passed Validation: Length is 12, and they are numeric.';
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
     END IF;

     p_return_status := FND_API.G_RET_STS_SUCCESS;
     p_error_buffer := NULL;

   ELSIF (substr(trn_value,1,2) = 'SK') and
         (common_check_numeric(p_trn_value,3,length(p_trn_value)) = '0') THEN

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       l_log_msg := 'The Tax Registration Number is numeric.';
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
     END IF;

     p_return_status := FND_API.G_RET_STS_SUCCESS;
     p_error_buffer := NULL;

   ELSE

     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
       l_log_msg := 'Passed Validation: Length is 12, and they are numeric.';
       FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
     END IF;

     p_return_status := FND_API.G_RET_STS_ERROR;
     p_error_buffer := 'ZX_REG_NUM_INVALID';
--
   END IF;

END IF;

END VALIDATE_TRN_SK;

/* ***********    End VALIDATE_TRN_SK       ****************** */

PROCEDURE VALIDATE_TRN_NL (p_trn               IN  VARCHAR2,
                           p_trn_type          IN  VARCHAR2,
                           p_check_unique_flag IN  VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2)
                           AS

p_trn_value       VARCHAR2(50);
NL_PREFIX         VARCHAR2(2);
SUFFIX_VALUE      VARCHAR2(2);
check_digit       VARCHAR2(1);
B_value           VARCHAR2(1);
position_i        NUMBER(2);
integer_value     NUMBER(2);
multiplied_number NUMBER(2);
multiplied_sum    NUMBER(3);
check_result      VARCHAR2(1);

l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN_NL';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

--Added for Bug 30723441

l_alpha_start number:=10;
l_num_check VARCHAR2(10);
TYPE number_table_type IS TABLE OF number INDEX BY varchar2(1);
l_alphabet_convert number_table_type;
l_char_value        VARCHAR2(1);
l_check_num_var         VARCHAR2(100);
l_check_num         NUMBER;
l_validate_soletrader varchar2(1) := 'Y';
l_validate_org varchar2(1) := 'Y';
l_validation_check boolean :=TRUE;

--Added for Bug 30723441
                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

  procedure fail_uniqueness is
  begin

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'The Tax Registration Number is already used.';
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
        END IF;

        p_return_status := FND_API.G_RET_STS_ERROR;
        p_error_buffer := 'ZX_REG_NUM_INVALID';
  end fail_uniqueness;

  procedure fail_check is
  begin

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'Failed the validation of the tax registration number.';
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
        END IF;

        p_return_status := FND_API.G_RET_STS_ERROR;
        p_error_buffer := 'ZX_REG_NUM_INVALID';
  end fail_check;

  procedure pass_check is
  begin

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'The Tax Registration Number is valid.';
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
        END IF;


        p_return_status := FND_API.G_RET_STS_SUCCESS;
        p_error_buffer := NULL;
  end pass_check;

  procedure check_numeric (check_numeric_result OUT NOCOPY VARCHAR2) is
  num_check VARCHAR2(50);
  begin
      num_check := '';
       num_check := nvl(
                       rtrim(
                     translate(substr(p_trn_value,3,9),
                               '1234567890',
                               '          ')
                                              ), '0'
                                                          );

         IF num_check <> '0' THEN

           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              l_log_msg := 'The Tax Registration Number without prefix and suffix must be numeric.';
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;

           check_numeric_result := FND_API.G_RET_STS_ERROR;
           p_error_buffer := 'ZX_REG_NUM_INVALID';
         ELSE

           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              l_log_msg := 'The Tax Registration Number is valid.';
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;

           check_numeric_result := FND_API.G_RET_STS_SUCCESS;
           p_error_buffer := NULL;
         END IF;
  end check_numeric;


                           /****************/
                           /* MAIN SECTION */
                           /****************/

BEGIN

G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := l_procedure_name||'(+)';
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
END IF;

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := 'Parameters ';
  l_log_msg :=  l_log_msg||'p_trn_value: '||p_trn_value;
  l_log_msg :=  l_log_msg||' p_trn_type: '||p_trn_type;
  l_log_msg :=  l_log_msg||' p_check_unique_flag: '||p_check_unique_flag;
  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
END IF;

p_trn_value := upper(p_trn);
NL_PREFIX := substr(p_trn_value,1,2);
SUFFIX_VALUE := substr(p_trn_value,13,2);
check_digit := substr(p_trn_value,11,1);
B_value := substr(p_trn_value,12,1);
multiplied_number := 0;
multiplied_sum := 0;

--Added for Bug 30723441
begin

select 'N' into
l_validate_soletrader
from zx_reporting_types_b
where
reporting_type_code ='ZX_NL_REG_NUM_SOLETRADER'
and trunc(sysdate) between trunc(nvl(EFFECTIVE_FROM,sysdate)) and trunc(nvl(EFFECTIVE_TO ,sysdate));

exception
when others then
l_validate_soletrader:='Y';
end;

begin

select 'N' into
l_validate_org
from zx_reporting_types_b
where
reporting_type_code ='ZX_NL_REG_NUM_ORGANIZATION'
and trunc(sysdate) between trunc(nvl(EFFECTIVE_FROM,sysdate)) and trunc(nvl(EFFECTIVE_TO ,sysdate));

exception
when others then
l_validate_org:='Y';
end;


for i in ascii('A')..ascii('Z')
loop

l_alphabet_convert(fnd_global.local_chr(i)):=l_alpha_start;

l_alpha_start:=l_alpha_start+1;

end loop;

l_alphabet_convert('+'):=36;
l_alphabet_convert('*'):=37;

--Added for Bug 30723441

IF p_check_unique_flag = 'E'
  then
    fail_uniqueness;

ELSIF p_check_unique_flag = 'S' THEN

 --IF p_trn_type = 'VAT' THEN

    check_numeric(check_result);
    IF check_result = 'S'
       then
    IF length(p_trn_value) = 14
       then
       IF NL_PREFIX = 'NL'
          then
          IF B_VALUE = 'B'
             then
             IF (substr(SUFFIX_VALUE,1,1)
                    in ('0','1','2','3','4','5','6','7','8','9'))
                 and (substr(SUFFIX_VALUE,2,1)
                    in ('0','1','2','3','4','5','6','7','8','9'))
                then

					---added for the bug 30723441
						/* Executing the sole trader logic by default in case customer disables both the validations */

						if l_validate_soletrader = 'N' and l_validate_org ='N'
						then

							l_validate_soletrader := 'Y';

						end if;

						/* Executing the sole trader logic by default in case customer disables both the validations */

						IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
							l_log_msg := 'The value of l_validate_soletrader is '||l_validate_soletrader ||' and the value of l_validate_org is '||l_validate_org;
							FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
						END IF;


						if l_validate_soletrader = 'Y' then


							IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
								l_log_msg := 'Performing soletrader specific validation check for Registration number'||p_trn_value;
								FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
							END IF;

							FOR position_i IN 1..14 LOOP

								l_char_value := substr(p_trn_value,position_i,1);

								l_num_check:= nvl(rtrim(translate(l_char_value,'1234567890','          ')), '0');

								IF l_num_check <> '0' THEN

									integer_value:=	l_alphabet_convert(l_char_value);

								else

									integer_value:=l_char_value;

								end if;

								l_check_num_var := l_check_num_var||integer_value;

								IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
									l_log_msg := 'l_check_num_var is'||l_check_num_var;
									FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
								END IF;

							END LOOP;

							l_check_num:=to_number(l_check_num_var);

							IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
								l_log_msg := 'l_check_num is'||l_check_num;
								FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
							END IF;


							IF to_number(SUFFIX_VALUE) between 2 and 98
							then

								IF mod(l_check_num,97) = 1   then

									l_validation_check := FALSE;

									IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
										l_log_msg := 'REGISTRATION_NUMBER is a of a valid sole trader ';
										FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
									END IF;

									pass_check;

								end if;

							else


								IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
									l_log_msg := 'Suffix value is incorrect for sole trader ';
									FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
								END IF;

							end if;

						end if;
				        --added for the Bug 30723441

					/* Will verify the organization validation only if sole trader validation is disabled / Failed */

                       IF l_validation_check then

						IF l_validate_org ='Y' then


							IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
								l_log_msg := 'Sole Trader Validation Failed l_check_num is '||l_check_num||'SUFFIX_VALUE is '
								||SUFFIX_VALUE||' , checking if the registration number is valid for an Organization';
								FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
							END IF;
							integer_value:=0;

							/* Calculate Check Digit for Netherlands  */
							FOR position_i IN 3..10 LOOP

               integer_value := substr(p_trn_value,position_i,1);

               multiplied_number := integer_value * (12-position_i);
               multiplied_sum := multiplied_sum + multiplied_number;


             END LOOP;

                IF mod(multiplied_sum,11) = check_digit then
                   pass_check;
                ELSE

                   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                      l_log_msg := 'Check digit is incorrect.';
                      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
                   END IF;

								p_return_status := FND_API.G_RET_STS_ERROR;
								p_error_buffer := 'ZX_REG_NUM_INVALID';
							END IF;

						else

							IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
								l_log_msg := 'ORGANIZATION validation is disabled and hence this format may be invalid';
								FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
							END IF;

							p_return_status := FND_API.G_RET_STS_ERROR;
							p_error_buffer := 'ZX_REG_NUM_INVALID';


						END if;	--added for the Bug 30723441

					   END IF;

             ELSE

                IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                   l_log_msg := 'The prefix of the Tax Registration Number must be alphabetic character.';
                   FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
                END IF;

                p_return_status := FND_API.G_RET_STS_ERROR;
                p_error_buffer := 'ZX_REG_NUM_INVALID';
             END IF;

          ELSE

             IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                l_log_msg := 'The Tax Registration Number does not have required character B in the suffix.';
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
             END IF;

             p_return_status := FND_API.G_RET_STS_ERROR;
             p_error_buffer := 'ZX_REG_NUM_INVALID';
          END IF;

       ELSE

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg := 'The prefix of the Tax Registration Number is incorrect.';
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_INVALID';
       END IF;

    ELSE

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'The length of the Tax Registration Number is not 14.';
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;

        IF length(p_trn_value) > 14 THEN
           p_return_status := FND_API.G_RET_STS_ERROR;
           p_error_buffer  := 'ZX_REG_NUM_TOO_BIG';
        ELSE
           p_return_status := FND_API.G_RET_STS_ERROR;
           p_error_buffer  := 'ZX_REG_NUM_INVALID';
        END IF;
     END IF;

   ELSE

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'The Tax Registration Number contains an alphanumeric character where a numeric character is expected.';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      p_return_status := FND_API.G_RET_STS_ERROR;
      p_error_buffer := 'ZX_REG_NUM_INVALID_ALPHA';
   END IF;

END IF;

END VALIDATE_TRN_NL;


/* ***********    End VALIDATE_TRN_NL       ****************** */


PROCEDURE VALIDATE_TRN_PL (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2)
                           AS
num_check  VARCHAR2(2);
len    number;

l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN_PL';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
trn_value       VARCHAR2(50);

BEGIN

G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := l_procedure_name||'(+)';
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
END IF;

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := 'Parameters ';
  l_log_msg :=  l_log_msg||'p_trn_value: '||p_trn_value;
  l_log_msg :=  l_log_msg||' p_trn_type: '||p_trn_type;
  l_log_msg :=  l_log_msg||' p_check_unique_flag: '||p_check_unique_flag;
  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
END IF;

len := length(p_trn_value);
trn_value := upper(p_trn_value);

IF p_check_unique_flag = 'E' THEN

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'The Tax Registration Number is already used.';
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

   p_return_status := FND_API.G_RET_STS_ERROR;
   p_error_buffer := 'ZX_REG_NUM_INVALID';

ELSIF p_check_unique_flag = 'S' THEN

 --IF p_trn_type = 'VAT' THEN

    /*  check length = 13 or 15 */
   IF len = 10 or len = 13 or len = 15 THEN
--
      num_check := '1';
      num_check := nvl( rtrim(
                       translate( substr(p_trn_value,1,len),
                                  '1234567890-',
                                  '           ' ) ), '0' );
      IF num_check = '0' THEN
--
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg := 'The length of the Tax Registration Number is 13 or 15, and it is numeric.';
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

          p_return_status := FND_API.G_RET_STS_SUCCESS;
          p_error_buffer := NULL;
      ELSE

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg := 'Neither the length of the Tax Registration Number is 13 or 15  nor it is numeric.';
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_INVALID';
--
      END IF;
   ELSIF (substr(trn_value,1,2) = 'PL') and
         (common_check_numeric(p_trn_value,3,length(p_trn_value)) = '0') THEN

             IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                  l_log_msg := 'The Tax Registration Number is numeric.';
                  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
             END IF;

             p_return_status := FND_API.G_RET_STS_SUCCESS;
             p_error_buffer := NULL;

    ELSE

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'The length of the Tax Registration Number is not 10 or 13 or 15.';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      p_return_status := FND_API.G_RET_STS_ERROR;
      p_error_buffer := 'ZX_REG_NUM_INVALID';
--
   END IF;

END IF;

END VALIDATE_TRN_PL;

/* ***********    End VALIDATE_TRN_PL       ****************** */


PROCEDURE VALIDATE_TRN_PT (p_trn_value         IN  VARCHAR2,
                           p_trn_type          IN  VARCHAR2,
                           p_check_unique_flag IN  VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2)
                           AS

check_digit          VARCHAR2(2);
position_i           number(2);
integer_value        number(1);
mod11          number(8);
multiplied_number    number(38);
multiplied_sum       number(38) := 0;
cal_cd          number(2);
TRN_STRING       VARCHAR2(50);

l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN_PT';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := l_procedure_name||'(+)';
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
END IF;

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := 'Parameters ';
  l_log_msg :=  l_log_msg||'p_trn_value: '||p_trn_value;
  l_log_msg :=  l_log_msg||' p_trn_type: '||p_trn_type;
  l_log_msg :=  l_log_msg||' p_check_unique_flag: '||p_check_unique_flag;
  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
END IF;

check_digit := substr(p_trn_value, length(p_trn_value));
TRN_STRING := substr(p_trn_value,3,length(p_trn_value));

IF p_check_unique_flag = FND_API.G_RET_STS_ERROR THEN
--

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'The Tax Registration Number is already used.';
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

   p_return_status := FND_API.G_RET_STS_ERROR;
   p_error_buffer := 'ZX_REG_NUM_INVALID';

ELSIF p_check_unique_flag = 'S' THEN
--

 --IF p_trn_type = 'VAT' THEN

   /*  check length = 11, prefix = 'PT' and the last nine digits are numeric     */

   IF length(p_trn_value) = 11 and substr(p_trn_value,1,2) = 'PT' and
  common_check_numeric(TRN_STRING,1,length(TRN_STRING)) = '0' THEN
   --
     FOR position_i IN 1..8 LOOP
     --
          integer_value := substr(TRN_STRING,position_i,1);

          multiplied_number := integer_value * (10-position_i);
          multiplied_sum := multiplied_sum + multiplied_number;
     --
     END LOOP;
         p_error_buffer := 'multiplied_sum '||to_char(multiplied_sum);

     mod11 := (floor(multiplied_sum/11)+1)*11;
         p_error_buffer := 'mod11 '||to_char(mod11);

     cal_cd := mod11-multiplied_sum;
         p_error_buffer := 'cal_cd '||to_char(cal_cd);

     IF (mod(multiplied_sum,11) = 0) OR (cal_cd > 9) THEN
     --
         cal_cd := 0;
         p_error_buffer := 'cal_cd '||to_char(cal_cd);
     --
     END IF;

         p_error_buffer := 'check_digit '||check_digit;

     IF cal_cd = check_digit THEN
     --
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg := 'The Tax Registration Number is valid.';
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

         p_return_status := FND_API.G_RET_STS_SUCCESS;
         p_error_buffer := NULL;
     ELSE

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg := 'The Tax Registration Number is invalid.';
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

         p_return_status := FND_API.G_RET_STS_ERROR;
         p_error_buffer := 'ZX_REG_NUM_INVALID';
     --
     END IF;
  --
  ELSE
  --
     IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'The Tax Registration Number is invalid.';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
     END IF;

     p_return_status := FND_API.G_RET_STS_ERROR;
     p_error_buffer := 'ZX_REG_NUM_INVALID';
  --
  END IF;


END IF;
--
END VALIDATE_TRN_PT;

/**********   End of VALIDATE_TRN_PT  **************************/

PROCEDURE VALIDATE_TRN_ES (p_trn               IN  VARCHAR2,
                           p_trn_type          IN  VARCHAR2,
                           p_check_unique_flag IN  VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2)
                           AS

trn_value       VARCHAR2(50);
work_trn        VARCHAR2(50);
check_digit     VARCHAR2(1);
numeric_result  VARCHAR2(50);
work_trn_d      NUMBER(20);
trn_prefix      VARCHAR2(2);
x_trn_number    VARCHAR2(50);
whole_value     VARCHAR2(50);

l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN_ES';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
N_Check_Digit varchar2(26) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
N_Check_Flag number := 0 ;

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

  procedure fail_uniqueness is
  begin

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'The Tax Registration Number is already used.';
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
        END IF;

        p_return_status := FND_API.G_RET_STS_ERROR;
        p_error_buffer := 'ZX_REG_NUM_INVALID';
  end fail_uniqueness;

  procedure fail_check is
  begin

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'The Tax Registration Number is invalid.';
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
        END IF;

        p_return_status := FND_API.G_RET_STS_ERROR;
        p_error_buffer := 'ZX_REG_NUM_INVALID';
  end fail_check;

  procedure pass_check is
  begin

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'The Tax Registration Number is valid.';
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
        END IF;

        p_return_status := FND_API.G_RET_STS_SUCCESS;
        p_error_buffer := NULL;
  end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/

BEGIN

G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

WHOLE_VALUE := upper(p_trn);
trn_value := upper(p_trn);
check_digit := substr(trn_value, length(trn_value));

trn_value := substr(WHOLE_VALUE,3);
trn_prefix := substr(WHOLE_VALUE,1,2);

IF p_check_unique_flag = 'E' THEN
    fail_uniqueness;
ELSIF p_check_unique_flag = 'S' THEN

 --IF p_trn_type = 'VAT' THEN

  IF instr(trn_value,' ') = 0 THEN
     IF TRN_PREFIX = 'ES' THEN
      /**  make sure that Fiscal Code is greater than 1 char **/
      IF length(trn_value) > 1
        then

      /** make sure that Fiscal Code starts with one of the following characters **/
      /* Added TRN_VALUE 'Y','Z','J','U','V','R','W' as part of 7533946 */
           IF upper(substr(trn_value,1,1))
              in ('A','B','C','D','E','F','G','T','P','Q','S','H','J','U','V','R','W',
                    'X','Y','Z','K','L','M','N','0','1','2','3','4','5','6','7','8','9')
              then

                /** If the Fiscal Code starts with a T, then no futher **/
                /** validation is required                             **/
                IF substr(trn_value,1,1) = 'T' then
                  pass_check;

                /** Fiscal Code does not start with 'T' **/
                /* Added the validation for Code starting with N.
                Forward porting was missing in earlier enhancement (Bug 2996623).
                Added the validation as part of 7533946*/
                ELSIF substr(trn_value,1,1) = 'N'
                  then
                    numeric_result :=
                          common_check_numeric(trn_value,2,length(trn_value)-2);
                     IF numeric_result = '0'
                        then
                              /* its numeric so continue  */
                          SELECT instr(N_Check_Digit,check_digit)
                          INTO N_Check_Flag
                          FROM DUAL;
                          If N_Check_Flag > 0
                            then pass_check;
                            else fail_check;
                          end if;
                     ELSE
                       fail_check;
                     END IF;
                --end of 2996623
                /** IF the Fiscal Code begins with the following     **/
                /** It's a physical person. The TRN has to end in a  **/
                /** specific letter. Eg Valids = X1596399S,2601871L  **/
                ELSIF substr(trn_value,1,1) in
                       ('X','K','L','M','Y','Z','0','1','2','3','4','5','6','7','8','9')
                   then
                      IF substr(trn_value,1,1) in ('X','K','L','M','Y','Z')
                        then
                        numeric_result
                           := common_check_numeric(trn_value,2,length(trn_value)-2);
                           IF numeric_result = '0'
                              then
                                  /* its numeric so continue  */
                              IF substr(trn_value,1,1) in ('Y','Z')
                              then
                                SELECT Decode(SubStr(trn_value,1,1),'Y',1,2)
                                       ||SubStr(trn_value,2,length(trn_value)-2)
                                  INTO work_trn
                                  FROM DUAL;
                              ELSE
                                work_trn := substr(trn_value,2,length(trn_value)-2);
                              END IF;
                              IF substr('TRWAGMYFPDXBNJZSQVHLCKE',mod
                                  (to_number(work_trn) ,23) + 1,1) = check_digit
                                 then
                                 pass_check;
                              ELSE
                                 fail_check;
                              END IF;
                           ELSE

                              IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                                 l_log_msg := 'The Tax Registration Number contains an alphanumeric character where a numeric character is expected.';
                                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
                              END IF;

                              p_return_status := FND_API.G_RET_STS_ERROR;
                              p_error_buffer := 'ZX_REG_NUM_INVALID_ALPHA';
                           END IF; /* end of numeric check  */

                      ELSE
                        numeric_result
                           := common_check_numeric(trn_value,1,length(trn_value)-1);
                           IF numeric_result = '0'
                              then
                                  /* its numeric so continue  */

                              work_trn := substr(trn_value,1,length(trn_value)-1);
                              IF substr('TRWAGMYFPDXBNJZSQVHLCKE',mod
                                  (to_number(work_trn) ,23) + 1,1) = check_digit
                                 then
                                 pass_check;
                              ELSE
                                 fail_check;
                              END IF;
                           ELSE

                              IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                                 l_log_msg := 'The Tax Registration Number contains an alphanumeric character where a numeric character is expected.';
                                 FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
                              END IF;

                              p_return_status := FND_API.G_RET_STS_ERROR;
                              p_error_buffer := 'ZX_REG_NUM_INVALID_ALPHA';
                           END IF; /* end of numeric check  */

                      END IF;

                ELSIF substr(trn_value,1,1) in
                       ('A','B','C','D','E','F','G','H','P','Q','S','J','U','V','R','W')
                   then
                /** It's a company. Examples of valid company TRN is      **/
                /** A78361482 A78211646 F2831001I Q0467001D P0801500J     **/
                   numeric_result
                           := common_check_numeric(trn_value,2,length(trn_value)-2);
                   IF numeric_result = '0'
                      then
                      /* its numeric so continue  */
                      work_trn := substr(trn_value,2,length(trn_value)-2);
                      work_trn_d := to_number(substr(work_trn,2,1)) +
                                    to_number(substr(work_trn,4,1)) +
                                    to_number(substr(work_trn,6,1)) +
          to_number(substr(to_char(to_number(substr(work_trn,1,1)) * 2),1,1)) +
          to_number(nvl(substr(to_char(to_number(substr(work_trn,1,1))
                    * 2),2,1),'0')) +
          to_number(substr(to_char(to_number(substr(work_trn,3,1)) * 2),1,1)) +
          to_number(nvl(substr(to_char(to_number(substr(work_trn,3,1))
                    * 2),2,1),'0')) +
          to_number(substr(to_char(to_number(substr(work_trn,5,1)) * 2),1,1)) +
          to_number(nvl(substr(to_char(to_number(substr(work_trn,5,1))
                    * 2),2,1),'0')) +
          to_number(substr(to_char(to_number(substr(work_trn,7,1)) * 2),1,1)) +
          to_number(nvl(substr(to_char(to_number(substr(work_trn,7,1))
                    * 2),2,1),'0'))
          + nvl(to_number(substr(work_trn,8,1)),0)
          + nvl(to_number(substr(to_char(to_number(substr(work_trn,9,1)) * 2),1,1)),0) +
          to_number(nvl(substr(to_char(to_number(substr(work_trn,9,1))
                    * 2),2,1),'0'));

                        IF check_digit in ('A','B','C','D','E','F','G','H','I','J')
                           then
                           IF substr('JABCDEFGHI',((ceil(work_trn_d/10) * 10)
                                             - work_trn_d) + 1, 1) = check_digit
                              then
                                pass_check;
                           ELSE
                                fail_check;
                           END IF;
                        ELSIF check_digit
                                 = to_char((ceil(work_trn_d/10) *10) - work_trn_d)
                           then
                             pass_check;
                        ELSE
                             fail_check;
                        END IF;

                   ELSE

                      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                         l_log_msg := 'The Tax Registration Number contains an alphanumeric character where a numeric character is expected.';
                         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
                      END IF;

                      p_return_status := FND_API.G_RET_STS_ERROR;
                      p_error_buffer := 'ZX_REG_NUM_INVALID_ALPHA';
                   END IF; /* end of numeric check */
                ELSE
                    fail_check;
                END IF; /* End of person or company check */

           ELSE
              fail_check;
           END IF;  /* does not start with a valid character */
       ELSE

           IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              l_log_msg := 'The length of the Tax Registration Number is not correct.';
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;

           p_return_status := FND_API.G_RET_STS_ERROR;
           p_error_buffer := 'ZX_REG_NUM_TOO_BIG';
       END IF;  /* end of length check */

     ELSE
           fail_check; /* Not a Fiscal or a TAX code */
     END IF;

    ELSE
          fail_check; /* Its got a space in it */
    END IF;

ELSE
  pass_check;

END IF; /** of fail uniqueness check **/

END VALIDATE_TRN_ES;


/* ***********    End VALIDATE_TRN_ES       ****************** */

PROCEDURE VALIDATE_TRN_SE (p_trn_value         IN  VARCHAR2,
                           p_trn_type          IN  VARCHAR2,
                           p_check_unique_flag IN  VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2)
                           AS

l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN_SE';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := l_procedure_name||'(+)';
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
END IF;

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := 'Parameters ';
  l_log_msg :=  l_log_msg||'p_trn_value: '||p_trn_value;
  l_log_msg :=  l_log_msg||' p_trn_type: '||p_trn_type;
  l_log_msg :=  l_log_msg||' p_check_unique_flag: '||p_check_unique_flag;
  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
END IF;

IF p_check_unique_flag = 'E' THEN
--

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'The Tax Registration Number is already used.';
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

   p_return_status := FND_API.G_RET_STS_ERROR;
   p_error_buffer := 'ZX_REG_NUM_INVALID';

ELSIF p_check_unique_flag = 'S' THEN
--

 --IF p_trn_type = 'VAT' THEN

   /*  check length = 14, prefix = 'SE', the last twelve digits are numeric and
  the last two digits = '01'     */

   IF length(p_trn_value) = 14 and substr(p_trn_value,1,2) = 'SE' and
      common_check_numeric(p_trn_value,3,length(p_trn_value)) = '0' and
      substr(p_trn_value,length(p_trn_value)-1,2) = '01' THEN
--
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg := 'Length is 14, Prefix is SE, and last 12 digits are numeric.';
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

          p_return_status := FND_API.G_RET_STS_SUCCESS;
          p_error_buffer := NULL;
   ELSE

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg := 'One of the following condition is incorrect.: Length is 14, Prefix is SE, or last 12 digits are numeric.';
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

       p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_INVALID';
--
   END IF;
--

END IF;

END VALIDATE_TRN_SE;

/* ***********    End VALIDATE_TRN_SE       ****************** */

PROCEDURE VALIDATE_TRN_GB (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2)
                           AS

TRN_STRING       VARCHAR2(50);
check_digit      VARCHAR2(2);
check_total      NUMBER;
check_total_55   NUMBER;  -- 9109873
integer_value    number(2);
position_i       integer;

l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN_GB';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := l_procedure_name||'(+)';
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
END IF;

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := 'Parameters ';
  l_log_msg :=  l_log_msg||'p_trn_value: '||p_trn_value;
  l_log_msg :=  l_log_msg||' p_trn_type: '||p_trn_type;
  l_log_msg :=  l_log_msg||' p_check_unique_flag: '||p_check_unique_flag;
  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
END IF;

TRN_STRING  := substr(p_trn_value,3,length(p_trn_value));
check_digit := substr(TRN_STRING,8,2);  /* The last two digits are the 'check digits' */

IF p_check_unique_flag = 'E' THEN
--
  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_msg := 'The Tax Registration Number is already used.';
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;

  p_return_status := FND_API.G_RET_STS_ERROR;
  p_error_buffer := 'ZX_REG_NUM_INVALID';

ELSIF p_check_unique_flag = 'S' THEN
--
--IF p_trn_type = 'VAT' THEN

  /*  check length = 5, 9 , 12, prefix = 'GB' and the last digits are numeric     */
  IF substr(p_trn_value,1,2) = 'GB' and length(TRN_STRING) in (5, 9, 12) and
        (common_check_numeric(TRN_STRING,1,length(TRN_STRING)) = '0' or
          length(TRN_STRING) = 5) THEN
  --
    IF length(TRN_STRING) IN (9,12) THEN
    --
      check_total := 0;
      FOR position_i IN 1..7 LOOP
      --
        integer_value := substr(TRN_STRING,position_i,1);
        check_total := check_total + integer_value * ( 9 - position_i );
      --
      END LOOP;
      WHILE check_total > 0 LOOP
      /* until we get a 2-digit negative number */
        check_total := check_total - 97;
      END LOOP;

      IF check_digit + check_total = 0 THEN
      --
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'The Tax Registration Number is valid.';
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
        END IF;

        p_return_status := FND_API.G_RET_STS_SUCCESS;
        p_error_buffer := NULL;
      ELSE
        check_total_55 := check_total + 55;
        IF check_total_55 > 0 THEN
          check_total_55 := check_total_55 - 97;
        END IF;
        IF check_digit + check_total_55 = 0 THEN
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'The Tax Registration Number is valid.';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;
          p_return_status := FND_API.G_RET_STS_SUCCESS;
          p_error_buffer := NULL;
        ELSE
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'The Tax Registration Number is invalid.';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;
          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_INVALID';
        END IF;
        --
      END IF;
    ELSE
      p_return_status := FND_API.G_RET_STS_SUCCESS;
      p_error_buffer := NULL;
      l_log_msg := 'The Tax Registration Number is valid.';
      --
      IF length(TRN_STRING) = 5 AND substr(TRN_STRING,1,2) = 'GD' THEN
        IF common_check_numeric(TRN_STRING,3,length(TRN_STRING)) <> '0' OR
           to_number(substr(TRN_STRING,3)) > 499 THEN
          l_log_msg := 'The Tax Registration Number is invalid.';
          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_INVALID';
        END IF;
      ELSIF length(TRN_STRING) = 5 AND substr(TRN_STRING,1,2) = 'HA' THEN
        IF common_check_numeric(TRN_STRING,3,length(TRN_STRING)) <> '0' OR
           to_number(substr(TRN_STRING,3)) not between 500 and 999 THEN
          l_log_msg := 'The Tax Registration Number is invalid.';
          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_INVALID';
        END IF;
      ELSIF common_check_numeric(TRN_STRING,1,length(TRN_STRING)) <> '0' THEN
          l_log_msg := 'The Tax Registration Number is invalid.';
          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_INVALID';
      END IF;
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
    END IF;
  ELSE
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'Please enter a valid Tax Registration Number.';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;
    p_return_status := FND_API.G_RET_STS_ERROR;
    p_error_buffer := 'ZX_REG_NUM_INVALID';
    --
  END IF;
END IF;

END VALIDATE_TRN_GB;

/* ***********    End VALIDATE_TRN_GB       ****************** */

PROCEDURE VALIDATE_TRN_CH (p_trn_value         IN  VARCHAR2,
                           p_trn_type          IN  VARCHAR2,
                           p_check_unique_flag IN  VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2)
                           AS

l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN_CH';
l_log_msg     FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
l_result      VARCHAR2(20);    -- bug 14677337

BEGIN

G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := l_procedure_name||'(+)';
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
END IF;

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := 'Parameters ';
  l_log_msg :=  l_log_msg||'p_trn_value: '||p_trn_value;
  l_log_msg :=  l_log_msg||' p_trn_type: '||p_trn_type;
  l_log_msg :=  l_log_msg||' p_check_unique_flag: '||p_check_unique_flag;
  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
END IF;

IF p_check_unique_flag = 'E' THEN

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'The Tax Registration Number is already used.';
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;

  p_return_status := FND_API.G_RET_STS_ERROR;
  p_error_buffer := 'ZX_REG_NUM_INVALID';

ELSIF p_check_unique_flag = 'S' THEN

  --IF p_trn_type = 'VAT' THEN
  IF (SYSDATE < TO_DATE('01-01-2014','dd-mm-yyyy') ) THEN
    /*  check length = 8, prefix = 'CH' and the last six digits are numeric     */

    IF length(p_trn_value) = 8 and substr(p_trn_value,1,2) = 'CH' and
      common_check_numeric(p_trn_value,3,length(p_trn_value)) = '0' THEN
      --
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'Length is 8, and prefix is CH, and other digits are numeric.';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
      p_return_status := FND_API.G_RET_STS_SUCCESS;
      p_error_buffer := NULL;
      RETURN;
    ELSE
      -- we need to check other condition as well
      -- cannot decide that the reg number is valid
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'One of the following condition is incorrect: Length is 8, and prefix is CH, and other digits are numeric.  Checking alternate validations';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
    END IF;
  END IF;

  -- adding logic for Swiss Registration Number validation
  -- incorporated through bug 14677337

  IF (REGEXP_SUBSTR(p_trn_value,'^(CHE-[0-9]{3}\.[0-9]{3}\.[0-9]{3}) (MWST|TVA|IVA)$')=p_trn_value) THEN

    SELECT  DECODE(ceil(((REGEXP_SUBSTR(num,'[0-9]',1,1))*5+
                         (REGEXP_SUBSTR(num,'[0-9]',1,2))*4+
                         (REGEXP_SUBSTR(num,'[0-9]',1,3))*3+
                         (REGEXP_SUBSTR(num,'[0-9]',1,4))*2+
                         (REGEXP_SUBSTR(num,'[0-9]',1,5))*7+
                         (REGEXP_SUBSTR(num,'[0-9]',1,6))*6+
                         (REGEXP_SUBSTR(num,'[0-9]',1,7))*5+
                         (REGEXP_SUBSTR(num,'[0-9]',1,8))*4
                        )/11) * 11 -
                   ((REGEXP_SUBSTR(num,'[0-9]',1,1))*5+
                    (REGEXP_SUBSTR(num,'[0-9]',1,2))*4+
                    (REGEXP_SUBSTR(num,'[0-9]',1,3))*3+
                    (REGEXP_SUBSTR(num,'[0-9]',1,4))*2+
                    (REGEXP_SUBSTR(num,'[0-9]',1,5))*7+
                    (REGEXP_SUBSTR(num,'[0-9]',1,6))*6+
                    (REGEXP_SUBSTR(num,'[0-9]',1,7))*5+
                    (REGEXP_SUBSTR(num,'[0-9]',1,8))*4),
                   10,'INVALID',
                   (REGEXP_SUBSTR(num,'[0-9]',1,9)),'VALID',
                   'INVALID') FINAL_RESULT
    INTO l_result
    FROM (SELECT
            REGEXP_SUBSTR(REPLACE(REGEXP_SUBSTR(p_trn_value,'^(CHE-[0-9]{3}\.[0-9]{3}\.[0-9]{3}) (MWST|TVA|IVA)$'),'.',''),'[0-9]+') NUM
          FROM DUAL
         );

    IF (l_result = 'VALID') THEN

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'Length is 17 to 18, prefix is CHE, and suffix is MWST or TVA or IVA other digits are numeric.';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      p_return_status := FND_API.G_RET_STS_SUCCESS;
      p_error_buffer := NULL;

    ELSE

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'One of the following condition is incorrect: Length is between 17 to 18, and prefix is CHE, and other digits are numeric.';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      p_return_status := FND_API.G_RET_STS_ERROR;
      p_error_buffer := 'ZX_REG_NUM_INVALID';
    END IF;

  ELSE
    IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'The registration number is not as per new regulations';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;
    p_return_status := FND_API.G_RET_STS_ERROR;
    p_error_buffer := 'ZX_REG_NUM_INVALID';
  END IF;

END IF;

IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := l_procedure_name||'(-) with return status '|| p_return_status;
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.end', l_log_msg);
END IF;

EXCEPTION
WHEN NO_DATA_FOUND THEN
  IF (G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := 'One of the following condition is incorrect: Length is between 17 to 18, and prefix is CHE, and other digits are numeric.';
     FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;

  p_return_status := FND_API.G_RET_STS_ERROR;
  p_error_buffer := 'ZX_REG_NUM_INVALID';

END VALIDATE_TRN_CH;

/* ***********    End VALIDATE_TRN_CH       ****************** */


PROCEDURE VALIDATE_TRN_RU (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2)
                           AS

l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN_RU';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := l_procedure_name||'(+)';
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
END IF;

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := 'Parameters ';
  l_log_msg :=  l_log_msg||'p_trn_value: '||p_trn_value;
  l_log_msg :=  l_log_msg||' p_trn_type: '||p_trn_type;
  l_log_msg :=  l_log_msg||' p_check_unique_flag: '||p_check_unique_flag;
  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
END IF;

IF p_check_unique_flag = 'E' THEN

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'The Tax Registration Number is already used.';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

   p_return_status := FND_API.G_RET_STS_ERROR;
   p_error_buffer := 'ZX_REG_NUM_INVALID';

ELSIF p_check_unique_flag = 'S' THEN

 --IF p_trn_type = 'VAT' THEN

    /*   check length = 10 or 12 or 9  */

   IF length(p_trn_value) = 10 OR
      length(p_trn_value) = 12 OR
      length(p_trn_value) = 9 THEN
 --
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg := 'The length of the Tax Registration Number is ' || length(p_trn_value);
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

          p_return_status := FND_API.G_RET_STS_SUCCESS;
          p_error_buffer := NULL;
   ELSE

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg := 'The length of the Tax Registration Number is ' || length(p_trn_value);
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_INVALID';
--
   END IF;

END IF;

END VALIDATE_TRN_RU;

/* ***********    End VALIDATE_TRN_RU       ****************** */

procedure VALIDATE_TRN_HU (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2)
                           AS

 l_control_digit   NUMBER;
 l_trn_value       VARCHAR2(50);

 l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN_HU';
 l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := l_procedure_name||'(+)';
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
END IF;

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := 'Parameters ';
  l_log_msg :=  l_log_msg||'p_trn_value: '||p_trn_value;
  l_log_msg :=  l_log_msg||' p_check_unique_flag: '||p_check_unique_flag;
  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
END IF;

l_trn_value := substr(p_trn_value,3,8);

IF p_check_unique_flag = 'E' THEN

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'The Tax Registration Number is already used.';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

   p_return_status := FND_API.G_RET_STS_ERROR;
   p_error_buffer := 'ZX_REG_NUM_INVALID';

ELSIF p_check_unique_flag = 'S' THEN

 --IF p_trn_type = 'VAT' THEN

   l_control_digit := mod(
        (to_number(substr(l_trn_value,8,1)) * 1   +
        to_number(substr(l_trn_value,7,1)) * 3   +
        to_number(substr(l_trn_value,6,1)) * 7   +
        to_number(substr(l_trn_value,5,1)) * 9   +
        to_number(substr(l_trn_value,4,1)) * 1   +
        to_number(substr(l_trn_value,3,1)) * 3   +
        to_number(substr(l_trn_value,2,1)) * 7   +
        to_number(substr(l_trn_value,1,1)) * 9),10);

   IF l_control_digit = 0 THEN

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg := 'The Tax Registration Number is valid.';
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

          p_return_status := FND_API.G_RET_STS_SUCCESS;
          p_error_buffer := NULL;
   ELSE

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg := 'The Tax Registration Number is invalid.';
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_INVALID';
   END IF;

END IF;

END VALIDATE_TRN_HU;

/* ***********    End VALIDATE_TRN_HU       ****************** */


/*----------------------------------------------------------------------------*
 | PROCEDURE                                                                  |
 |    VALIDATE_TRN_BR                                                      |
 |                                                                            |
 | DESCRIPTION                                                                |
 |     Validatition of Brazil Tax Registration Number                         |
 |                                                                            |
 | PARAMETERS                                                                 |
 |   INPUT                                                                    |
 |      p_trn_type      VARCHAR2   -- Tax Registration Type: CPF              |
 |                                                           CNPJ             |
 |                                                           OTHERS           |
 |      p_trn           VARCHAR2   -- Tax Registration Number +               |
 |                                        Tax Registration Branch             |
 *----------------------------------------------------------------------------*/
PROCEDURE VALIDATE_TRN_BR (p_trn               IN     VARCHAR2,
                           p_trn_type          IN     VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2) IS

l_trn_branch       VARCHAR2(4);
l_trn_digit        VARCHAR2(2);
l_control_digit_1  NUMBER;
l_control_digit_2  NUMBER;
l_control_digit_XX VARCHAR2(2);
l_trn   VARCHAR2(20);

l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN_BR';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := l_procedure_name||'(+)';
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
END IF;

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := 'Parameters ';
  l_log_msg :=  l_log_msg||'p_trn: '||p_trn;
  l_log_msg :=  l_log_msg||' p_trn_type: '||p_trn_type;
  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
END IF;

 /* Tax Registration Branch */
-- l_trn_branch := substr(p_trn,10,4);
-- l_trn_digit := substr(p_trn,14,2);

IF p_trn_type = 'CPF'
THEN

  IF length(p_trn) = 11 THEN
    l_trn_digit := substr(p_trn,10,2);
    l_trn_branch := '0000';
   ELSE
     l_trn_branch := substr(p_trn,10,4);
     l_trn_digit := substr(p_trn,14,2);
   END IF;

   /* Validate CPF */
  IF nvl(l_trn_branch,'0000') <> '0000'
  THEN
      /* Tax Registration Number branch for CPF type should be NULL or zero */
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'CPF Tax Registration Number branch is not valid.';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      p_return_status := FND_API.G_RET_STS_ERROR;
      p_error_buffer := 'ZX_REG_NUM_INVALID';
  ELSE
     /* Calculate two digit controls of tax registration number CPF type */

     l_control_digit_1 := (11 - mod(
       (to_number(substr(p_trn,9,1)) * 2   +
        to_number(substr(p_trn,8,1)) * 3   +
        to_number(substr(p_trn,7,1)) * 4   +
        to_number(substr(p_trn,6,1)) * 5   +
        to_number(substr(p_trn,5,1)) * 6   +
        to_number(substr(p_trn,4,1)) * 7   +
        to_number(substr(p_trn,3,1)) * 8   +
        to_number(substr(p_trn,2,1)) * 9   +
        to_number(substr(p_trn,1,1)) * 10),11));

    IF l_control_digit_1 in ('11','10')
    THEN
            l_control_digit_1 := 0;
    END IF;

    l_control_digit_2 := (11 - mod((l_control_digit_1 * 2   +
        to_number(substr(p_trn,9,1)) * 3   +
        to_number(substr(p_trn,8,1)) * 4   +
        to_number(substr(p_trn,7,1)) * 5   +
        to_number(substr(p_trn,6,1)) * 6   +
        to_number(substr(p_trn,5,1)) * 7   +
        to_number(substr(p_trn,4,1)) * 8   +
        to_number(substr(p_trn,3,1)) * 9   +
        to_number(substr(p_trn,2,1)) * 10  +
        to_number(substr(p_trn,1,1)) * 11),11));

    IF l_control_digit_2 in ('11','10')
    THEN
            l_control_digit_2 := 0;
    END IF;

    l_control_digit_XX := substr(to_char(l_control_digit_1),1,1) ||
                  substr(to_char(l_control_digit_2),1,1);

    IF l_control_digit_XX <> l_trn_digit
    THEN

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'The CPF Inscription number is not valid.';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      /* Digit controls do not match */
      p_return_status:= FND_API.G_RET_STS_ERROR;
      p_error_buffer := 'ZX_REG_NUM_INVALID';
    ELSE

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'The Tax Registration Number is valid.';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      p_return_status:= FND_API.G_RET_STS_SUCCESS;
      p_error_buffer := NULL;
    END IF;
  END IF;

ELSIF p_trn_type = 'OTHERS'
THEN

  IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
    l_log_msg := 'The Tax Registration Number is valid.';
    FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
  END IF;

  p_return_status:= FND_API.G_RET_STS_SUCCESS;
  p_error_buffer := NULL;

 --ELSIF p_trn_type = 'CNPJ'
 --THEN
ELSE -- Bug 4299188 CNPJ validation is now default validation and would be used even when trn type is null etc

  /* Calculate two digit controls of tax registration number CNPJ type */
   IF length(p_trn) = 14 THEN
     l_trn := '0'||p_trn;
   ELSE
     l_trn := p_trn;
   END IF;

   l_trn_branch := substr(l_trn,10,4);
   l_trn_digit := substr(l_trn,14,2);


   l_control_digit_1 := (11 - mod(
     (to_number(substr(l_trn_branch,4,1)) * 2 +
      to_number(substr(l_trn_branch,3,1)) * 3 +
      to_number(substr(l_trn_branch,2,1)) * 4 +
      to_number(substr(l_trn_branch,1,1)) * 5 +
      to_number(substr(l_trn,9,1)) * 6 +
      to_number(substr(l_trn,8,1)) * 7 +
      to_number(substr(l_trn,7,1)) * 8 +
      to_number(substr(l_trn,6,1)) * 9 +
      to_number(substr(l_trn,5,1)) * 2 +
      to_number(substr(l_trn,4,1)) * 3 +
      to_number(substr(l_trn,3,1)) * 4 +
      to_number(substr(l_trn,2,1))* 5),11));

  IF l_control_digit_1 in ('11','10')
  THEN
      l_control_digit_1 := 0;
  END IF;

  l_control_digit_2 := (11 - mod(
      ( (l_control_digit_1 * 2)   +
      to_number(substr(l_trn_branch,4,1)) * 3   +
      to_number(substr(l_trn_branch,3,1)) * 4   +
      to_number(substr(l_trn_branch,2,1)) * 5   +
      to_number(substr(l_trn_branch,1,1)) * 6   +
      to_number(substr(l_trn,9,1)) * 7   +
      to_number(substr(l_trn,8,1)) * 8   +
      to_number(substr(l_trn,7,1)) * 9   +
      to_number(substr(l_trn,6,1)) * 2   +
      to_number(substr(l_trn,5,1)) * 3   +
      to_number(substr(l_trn,4,1)) * 4   +
      to_number(substr(l_trn,3,1)) * 5   +
      to_number(substr(l_trn,2,1)) * 6),11));

  IF l_control_digit_2 in ('11','10')
  THEN
      l_control_digit_2 := 0;
  END IF;

  l_control_digit_XX := substr(to_char(l_control_digit_1),1,1) ||
            substr(to_char(l_control_digit_2),1,1);

  IF l_trn_digit <> l_control_digit_XX
  THEN
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'The CGC Tax Registration Number is not valid.';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
      p_return_status:= FND_API.G_RET_STS_ERROR;
      p_error_buffer := 'ZX_REG_NUM_INVALID';
  ELSE
      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'The Tax Registration Number is valid.';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
      p_return_status:= FND_API.G_RET_STS_SUCCESS;
      p_error_buffer := NULL;
  END IF;
 END IF;

END VALIDATE_TRN_BR;

/* ***********    End VALIDATE_TRN_BR       ****************** */

PROCEDURE VALIDATE_TRN_AR (p_trn               IN         VARCHAR2,
                           p_trn_type          IN         VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2 ) AS

trn_value          VARCHAR2(50);
l_length_result    VARCHAR2(10);
l_numeric_result   VARCHAR2(10);
l_val_digit        VARCHAR2(2);
l_trn_digit        VARCHAR2(1);

l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN_AR';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := l_procedure_name||'(+)';
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
END IF;

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := 'Parameters ';
  l_log_msg :=  l_log_msg||'p_trn: '||p_trn;
  l_log_msg :=  l_log_msg||' p_trn_type: '||p_trn_type;
  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
END IF;

trn_value := upper(p_trn);
trn_value := replace(p_trn,' ','');

/* *** Check Length of Tax Registration Number *** */

IF p_trn_type = 'CUIL' THEN
   l_length_result := common_check_length('AR',11,trn_value);
   l_trn_digit := substr(trn_value,11,1);
   trn_value := substr(trn_value,1,10);
ELSIF p_trn_type = 'DNI' THEN
   l_length_result := common_check_length('AR',9,trn_value);
   l_trn_digit := substr(trn_value,9,1);
   trn_value := substr(trn_value,1,8);
ELSE -- Bug 4299188 CUIT logic is default logic now and will work when type is CUIT or Null or any other type (other than CUIL, DNI)
   l_length_result := common_check_length('AR',11,trn_value);
   l_trn_digit := substr(trn_value,11,1);
   trn_value := substr(trn_value,1,10);
END IF;

IF l_length_result = 'TRUE' THEN

   /* *** Check Numeric of Tax Registration Number *** */

   l_numeric_result := common_check_numeric(trn_value,1,length(trn_value));

   IF l_numeric_result = '0' THEN

      /* *** Check Numeric of Tax Registration Number *** */

       l_val_digit:=(11-MOD(((TO_NUMBER(SUBSTR(trn_value,10,1))) *2 +
                             (TO_NUMBER(SUBSTR(trn_value,9,1)))  *3 +
                             (TO_NUMBER(SUBSTR(trn_value,8,1)))  *4 +
                             (TO_NUMBER(SUBSTR(trn_value,7,1)))  *5 +
                             (TO_NUMBER(SUBSTR(trn_value,6,1)))  *6 +
                             (TO_NUMBER(SUBSTR(trn_value,5,1)))  *7 +
                             (TO_NUMBER(SUBSTR(trn_value,4,1)))  *2 +
                             (TO_NUMBER(SUBSTR(trn_value,3,1)))  *3 +
                             (TO_NUMBER(SUBSTR(trn_value,2,1)))  *4 +
                             (TO_NUMBER(SUBSTR(trn_value,1,1)))  *5),11));

       IF l_val_digit ='10' THEN
          l_val_digit:='9';
       ELSIF l_val_digit='11' THEN
          l_val_digit:='0';
       END IF;

       IF l_val_digit <> l_trn_digit THEN

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg := 'The Tax Registration Number is invalid.';
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_INVALID';
       ELSE

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg := 'The Tax Registration Number is valid.';
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

          p_return_status := FND_API.G_RET_STS_SUCCESS;
          p_error_buffer := NULL;
       END IF;

   ELSE

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'The Tax Registration Number must be numeric.';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      p_return_status := FND_API.G_RET_STS_ERROR;
      p_error_buffer := 'ZX_REG_NUM_MUST_BE_NUMERIC';
   END IF;

ELSE

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'The length of the Tax Registration Number is not correct.';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

   IF length(trn_value) > 11 THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      p_error_buffer  := 'ZX_REG_NUM_TOO_BIG';
   ELSE
      p_return_status := FND_API.G_RET_STS_ERROR;
      p_error_buffer  := 'ZX_REG_NUM_INVALID';
   END IF;
END IF;

END VALIDATE_TRN_AR;

/* ***********    End VALIDATE_TRN_AR       ****************** */

PROCEDURE VALIDATE_TRN_CL (p_trn               IN         VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2 ) AS

trn_value          VARCHAR2(50);
l_length_result    VARCHAR2(10);
l_numeric_result   VARCHAR2(12);
l_var1             VARCHAR2(50);
l_val_digit        VARCHAR2(2);
l_trn_digit        VARCHAR2(1);

l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN_CL';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := l_procedure_name||'(+)';
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
END IF;

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := 'Parameters ';
  l_log_msg :=  l_log_msg||'p_trn: '||p_trn;
  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
END IF;

trn_value := upper(p_trn);
trn_value := replace(p_trn,' ','');

/* *** Check Length of Tax Registration Number *** */

l_length_result := common_check_length('CL',13,trn_value);   /* Bug 3192083 */

IF l_length_result = 'TRUE' THEN

  /* *** Check Numeric of Tax Registration Number *** */

  IF length(trn_value) < 13 THEN
     trn_value := LPAD(trn_value,13,'0');
     l_trn_digit := substr(trn_value,13,1);
  ELSE
     l_trn_digit := substr(trn_value,13,1);
  END IF;

  trn_value := substr(trn_value,1,12);
  l_numeric_result := common_check_numeric(trn_value,1,length(trn_value));

  IF l_numeric_result = '0' THEN

     /* *** Check Algorithm of Tax Registration Number *** */

     l_var1 := trn_value;
     l_val_digit:=(11-MOD(((TO_NUMBER(SUBSTR(l_var1,12,1))) *2 +
                           (TO_NUMBER(SUBSTR(l_var1,11,1))) *3 +
                           (TO_NUMBER(SUBSTR(l_var1,10,1))) *4 +
                           (TO_NUMBER(SUBSTR(l_var1,9,1)))  *5 +
                           (TO_NUMBER(SUBSTR(l_var1,8,1)))  *6 +
                           (TO_NUMBER(SUBSTR(l_var1,7,1)))  *7 +
                           (TO_NUMBER(SUBSTR(l_var1,6,1)))  *2 +
                           (TO_NUMBER(SUBSTR(l_var1,5,1)))  *3 +
                           (TO_NUMBER(SUBSTR(l_var1,4,1)))  *4 +
                           (TO_NUMBER(SUBSTR(l_var1,3,1)))  *5 +
                           (TO_NUMBER(SUBSTR(l_var1,2,1)))  *6 +
                           (TO_NUMBER(SUBSTR(l_var1,1,1)))  *7),11));

     IF l_val_digit = '10'THEN
        l_val_digit := 'K';
     ELSIF l_val_digit = '11' THEN
         l_val_digit := '0';
     END IF;

     IF l_val_digit <> l_trn_digit THEN

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'The validation digit and Tax Registration Number digit is different.';
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
        END IF;

        p_return_status := FND_API.G_RET_STS_ERROR;
        p_error_buffer := 'ZX_REG_NUM_INVALID';
     ELSE

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'The Tax Registration Number is valid.';
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
        END IF;

        p_return_status := FND_API.G_RET_STS_SUCCESS;
        p_error_buffer := NULL;
     END IF;

    ELSE

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'The Tax Registration Number must be numeric.';
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;

       p_return_status := FND_API.G_RET_STS_ERROR;
       p_error_buffer := 'ZX_REG_NUM_MUST_BE_NUMERIC';
    END IF;

ELSE

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'The length of the Tax Registration Number is not correct.';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

   IF length(trn_value) > 11 THEN
       p_return_status := FND_API.G_RET_STS_ERROR;
       p_error_buffer  := 'ZX_REG_NUM_TOO_BIG';
   ELSE
       p_return_status := FND_API.G_RET_STS_ERROR;
       p_error_buffer  := 'ZX_REG_NUM_INVALID';
    END IF;
END IF;


END VALIDATE_TRN_CL;

/* ***********    End VALIDATE_TRN_CL       ****************** */

PROCEDURE VALIDATE_TRN_CO (p_trn               IN         VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2 ) AS

trn_value          VARCHAR2(50);
l_length_result    VARCHAR2(10);
l_numeric_result   VARCHAR2(15);
l_var1             VARCHAR2(50);
l_val_digit        VARCHAR2(2);
l_trn_digit        VARCHAR2(1);
l_mod_value        NUMBER(2);

l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN_CO';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := l_procedure_name||'(+)';
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
END IF;

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := 'Parameters ';
  l_log_msg :=  l_log_msg||'p_trn: '||p_trn;
  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
END IF;

trn_value := upper(p_trn);
trn_value := replace(p_trn,' ','');

/* *** Check Length of Tax Registration Number *** */

l_length_result := common_check_length('CO',16,trn_value);

IF l_length_result = 'TRUE' THEN

   /* *** Check Numeric of Tax Registration Number *** */

  IF length(trn_value) < 16 THEN
     trn_value := LPAD(trn_value,16,'0');
     l_trn_digit := substr(trn_value,16,1);
  ELSE
     l_trn_digit := substr(trn_value,16,1);
  END IF;

   trn_value := substr(trn_value,1,15);
   l_numeric_result := common_check_numeric(trn_value,1,length(trn_value));

   IF l_numeric_result = '0' THEN

      /* *** Check Algorithm of Tax Registration Number *** */

       l_var1:=trn_value;
       l_mod_value:=(MOD(((TO_NUMBER(SUBSTR(l_var1,15,1))) *3  +
                          (TO_NUMBER(SUBSTR(l_var1,14,1))) *7  +
                          (TO_NUMBER(SUBSTR(l_var1,13,1))) *13 +
                          (TO_NUMBER(SUBSTR(l_var1,12,1))) *17 +
                          (TO_NUMBER(SUBSTR(l_var1,11,1))) *19 +
                          (TO_NUMBER(SUBSTR(l_var1,10,1))) *23 +
                          (TO_NUMBER(SUBSTR(l_var1,9,1)))  *29 +
                          (TO_NUMBER(SUBSTR(l_var1,8,1)))  *37 +
                          (TO_NUMBER(SUBSTR(l_var1,7,1)))  *41 +
                          (TO_NUMBER(SUBSTR(l_var1,6,1)))  *43 +
                          (TO_NUMBER(SUBSTR(l_var1,5,1)))  *47 +
                          (TO_NUMBER(SUBSTR(l_var1,4,1)))  *53 +
                          (TO_NUMBER(SUBSTR(l_var1,3,1)))  *59 +
                          (TO_NUMBER(SUBSTR(l_var1,2,1)))  *67 +
                          (TO_NUMBER(SUBSTR(l_var1,1,1)))  *71),11));

       IF (l_mod_value IN (1,0)) THEN
          l_val_digit:=l_mod_value;
       ELSE
          l_val_digit:=11-l_mod_value;
       END IF;

       IF l_val_digit <> l_trn_digit THEN

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg := 'The Tax Registration Number is invalid.';
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_INVALID';
       ELSE

          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg := 'The Tax Registration Number is valid.';
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;

          p_return_status := FND_API.G_RET_STS_SUCCESS;
          p_error_buffer := NULL;
       END IF;

   ELSE

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'The Tax Registration Number must be numeric.';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      IF length(trn_value) > 16 THEN
         p_return_status := FND_API.G_RET_STS_ERROR;
         p_error_buffer  := 'ZX_REG_NUM_TOO_BIG';
      ELSE
         p_return_status := FND_API.G_RET_STS_ERROR;
         p_error_buffer  := 'ZX_REG_NUM_INVALID';
      END IF;

END IF;

ELSE

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'The length of the Tax Registration Number is not correct.';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

   p_return_status := FND_API.G_RET_STS_ERROR;
   p_error_buffer := 'ZX_REG_NUM_TOO_BIG';

END IF;


END VALIDATE_TRN_CO;

/* ***********    End VALIDATE_TRN_CO       ****************** */

PROCEDURE VALIDATE_TRN_TW (p_trn               IN  VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2) AS

trn_value          VARCHAR2(50);
l_length_result    VARCHAR2(10);
l_numeric_result   VARCHAR2(10);

l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN_TW';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := l_procedure_name||'(+)';
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
END IF;

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := 'Parameters ';
  l_log_msg :=  l_log_msg||'p_trn: '||p_trn;
  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
END IF;

trn_value := upper(p_trn);
trn_value := replace(p_trn,' ','');

/* *** Check Length of Tax Registration Number *** */

l_length_result := common_check_length('TW',9,trn_value);

IF l_length_result = 'TRUE' THEN

   /* *** Check Numeric of Tax Registration Number *** */

   l_numeric_result := common_check_numeric(trn_value,1,length(trn_value));

   IF l_numeric_result = '0' THEN

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'The Tax Registration Number is 9 and it is numeric only.';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      p_return_status := FND_API.G_RET_STS_SUCCESS;
      p_error_buffer := NULL;
   ELSE

      IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'The length of Tax Registration Number is 9, but it is not Numeric.';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;

      p_return_status := FND_API.G_RET_STS_ERROR;
      p_error_buffer := 'ZX_REG_NUM_MUST_BE_NUMERIC';
   END IF;

ELSE

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'The length of the Tax Registration Number is not 9.';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

   IF length(trn_value) > 10 THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      p_error_buffer  := 'ZX_REG_NUM_TOO_BIG';
   ELSE
      p_return_status := FND_API.G_RET_STS_ERROR;
      p_error_buffer  := 'ZX_REG_NUM_INVALID';
   END IF;
END IF;


END VALIDATE_TRN_TW;

/* ***********    End VALIDATE_TRN_TW       ****************** */


PROCEDURE VALIDATE_TRN_MT (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2)
                           AS

l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN_MT';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

trn_value       VARCHAR2(50);
mt_prefix       VARCHAR2(2);

BEGIN

trn_value := upper(p_trn_value);
mt_prefix := substr(trn_value,1,2);

G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := l_procedure_name||'(+)';
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
END IF;

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := 'Parameters ';
  l_log_msg :=  l_log_msg||'p_trn_value: '||p_trn_value;
  l_log_msg :=  l_log_msg||' p_trn_type: '||p_trn_type;
  l_log_msg :=  l_log_msg||' p_check_unique_flag: '||p_check_unique_flag;
  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
END IF;

IF p_check_unique_flag = 'E' THEN

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'The Tax Registration Number is already used.';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

   p_return_status := FND_API.G_RET_STS_ERROR;
   p_error_buffer := 'ZX_REG_NUM_INVALID';

ELSIF p_check_unique_flag = 'S' THEN

 --IF p_trn_type = 'VAT' THEN

   IF mt_prefix = 'MT' THEN

     /*   check length = 10  */
     IF length(trn_value) = 10 THEN

       /*  Check eight digits are numeric  */
       IF common_check_numeric(trn_value,3,length(trn_value)) = '0'  THEN

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'The Tax Registration Number is numeric.';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;

         p_return_status := FND_API.G_RET_STS_SUCCESS;
         p_error_buffer := NULL;
       ELSE

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'The Tax Registration Number must be numeric.';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;

         p_return_status := FND_API.G_RET_STS_ERROR;
         p_error_buffer := 'ZX_REG_NUM_MUST_BE_NUMERIC';

       END IF;

     ELSE

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'The length of the Tax Registration Number is not 10.';
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;

       IF length(trn_value) > 10 THEN
          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_TOO_BIG';
       ELSE
          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_INVALID';
       END IF;

     END IF;

   ELSE

     /*   check length = 8  */
     IF length(trn_value) = 8 THEN

       /*  Check eight digits are numeric  */
       IF common_check_numeric(trn_value,1,length(trn_value)) = '0'  THEN

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'The Tax Registration Number is numeric.';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;
         -- Logging Infra

         p_return_status := FND_API.G_RET_STS_SUCCESS;
         p_error_buffer := NULL;
       ELSE

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'The Tax Registration Number must be numeric.';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;

         p_return_status := FND_API.G_RET_STS_ERROR;
         p_error_buffer := 'ZX_REG_NUM_MUST_BE_NUMERIC';

       END IF;

     ELSE

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'The length of the Tax Registration Number is not 8.';
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;

       IF length(trn_value) > 8 THEN
          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_TOO_BIG';
       ELSE
          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_INVALID';
       END IF;

     END IF;

   END IF;

END IF;

END VALIDATE_TRN_MT;

/* ***********    End VALIDATE_TRN_MT       ****************** */


PROCEDURE VALIDATE_TRN_LV (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2)
                           AS

l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN_LV';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

trn_value       VARCHAR2(50);
lv_prefix       VARCHAR2(2);

BEGIN

trn_value := upper(p_trn_value);
lv_prefix := substr(trn_value,1,2);

G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := l_procedure_name||'(+)';
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
END IF;

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := 'Parameters ';
  l_log_msg :=  l_log_msg||'p_trn_value: '||p_trn_value;
  l_log_msg :=  l_log_msg||' p_trn_type: '||p_trn_type;
  l_log_msg :=  l_log_msg||' p_check_unique_flag: '||p_check_unique_flag;
  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
END IF;

IF p_check_unique_flag = 'E' THEN

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'The Tax Registration Number is already used.';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

   p_return_status := FND_API.G_RET_STS_ERROR;
   p_error_buffer := 'ZX_REG_NUM_INVALID';

ELSIF p_check_unique_flag = 'S' THEN

 --IF p_trn_type = 'VAT' THEN

   IF lv_prefix = 'LV' THEN

     /*   check length = 13  */
     IF length(trn_value) = 13 THEN

       /*  Check eight digits are numeric  */
       IF common_check_numeric(trn_value,3,length(trn_value)) = '0'  THEN

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'The Tax Registration Number is numeric.';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;

         p_return_status := FND_API.G_RET_STS_SUCCESS;
         p_error_buffer := NULL;
       ELSE

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'The Tax Registration Number must be numeric.';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;

         p_return_status := FND_API.G_RET_STS_ERROR;
         p_error_buffer := 'ZX_REG_NUM_MUST_BE_NUMERIC';

       END IF;

     ELSE

        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'The length of the Tax Registration Number is not 13.';
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
        END IF;

        IF length(trn_value) > 13 THEN
           p_return_status := FND_API.G_RET_STS_ERROR;
           p_error_buffer := 'ZX_REG_NUM_TOO_BIG';
        ELSE
           p_return_status := FND_API.G_RET_STS_ERROR;
           p_error_buffer := 'ZX_REG_NUM_INVALID';
        END IF;

     END IF;

   ELSE

     /*   check length = 11  */
     IF length(trn_value) = 11 THEN

       /*  Check eight digits are numeric  */
       IF common_check_numeric(trn_value,1,length(trn_value)) = '0'  THEN

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'The Tax Registration Number is numeric.';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;

         p_return_status := FND_API.G_RET_STS_SUCCESS;
         p_error_buffer := NULL;
       ELSE

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'The Tax Registration Number must be numeric.';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;

         p_return_status := FND_API.G_RET_STS_ERROR;
         p_error_buffer := 'ZX_REG_NUM_MUST_BE_NUMERIC';

       END IF;

     ELSE
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'The length of the Tax Registration Number is not 11.';
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
        END IF;

        IF length(trn_value) > 11 THEN
           p_return_status := FND_API.G_RET_STS_ERROR;
           p_error_buffer := 'ZX_REG_NUM_TOO_BIG';
        ELSE
           p_return_status := FND_API.G_RET_STS_ERROR;
           p_error_buffer := 'ZX_REG_NUM_INVALID';
        END IF;


     END IF;

   END IF;

END IF;

END VALIDATE_TRN_LV;

/* ***********    End VALIDATE_TRN_LV     ****************** */


PROCEDURE VALIDATE_TRN_SI (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2)
                           AS

l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN_MT';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

trn_value       VARCHAR2(50);
si_prefix       VARCHAR2(2);

BEGIN

trn_value := upper(p_trn_value);
si_prefix := substr(trn_value,1,2);

G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := l_procedure_name||'(+)';
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
END IF;

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := 'Parameters ';
  l_log_msg :=  l_log_msg||'p_trn_value: '||p_trn_value;
  l_log_msg :=  l_log_msg||' p_trn_type: '||p_trn_type;
  l_log_msg :=  l_log_msg||' p_check_unique_flag: '||p_check_unique_flag;
  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
END IF;

IF p_check_unique_flag = 'E' THEN

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'The Tax Registration Number is already used.';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

   p_return_status := FND_API.G_RET_STS_ERROR;
   p_error_buffer := 'ZX_REG_NUM_INVALID';

ELSIF p_check_unique_flag = 'S' THEN

 --IF p_trn_type = 'VAT' THEN

   IF si_prefix = 'SI' THEN

     /*   check length = 10  */
     IF length(trn_value) = 10 THEN

       /*  Check eight digits are numeric  */
       IF common_check_numeric(trn_value,3,length(trn_value)) = '0'  THEN

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'The Tax Registration Number is numeric.';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;

         p_return_status := FND_API.G_RET_STS_SUCCESS;
         p_error_buffer := NULL;
       ELSE

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'The Tax Registration Number must be numeric.';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;

         p_return_status := FND_API.G_RET_STS_ERROR;
         p_error_buffer := 'ZX_REG_NUM_MUST_BE_NUMERIC';

       END IF;

     ELSE

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'The length of the Tax Registration Number is not 10.';
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;

       IF length(trn_value) > 10 THEN
          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_TOO_BIG';
       ELSE
          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_INVALID';
       END IF;

     END IF;

   ELSE

     /*   check length = 8  */
     IF length(trn_value) = 8 THEN

       /*  Check eight digits are numeric  */
       IF common_check_numeric(trn_value,1,length(trn_value)) = '0'  THEN

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'The Tax Registration Number is numeric.';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;

         p_return_status := FND_API.G_RET_STS_SUCCESS;
         p_error_buffer := NULL;
       ELSE

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'The Tax Registration Number must be numeric.';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;

         p_return_status := FND_API.G_RET_STS_ERROR;
         p_error_buffer := 'ZX_REG_NUM_MUST_BE_NUMERIC';

       END IF;

     ELSE

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'The length of the Tax Registration Number is not 8.';
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;

       IF length(trn_value) > 8 THEN
          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_TOO_BIG';
       ELSE
          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_INVALID';
       END IF;

     END IF;

   END IF;

END IF;

END VALIDATE_TRN_SI;

/* ***********    End VALIDATE_TRN_SI       ****************** */

PROCEDURE VALIDATE_TRN_LT (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2)
                           AS

l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN_LT';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

trn_value       VARCHAR2(50);
lt_prefix       VARCHAR2(2);

BEGIN

trn_value := upper(p_trn_value);
lt_prefix := substr(trn_value,1,2);

G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := l_procedure_name||'(+)';
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
END IF;

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := 'Parameters ';
  l_log_msg :=  l_log_msg||'p_trn_value: '||p_trn_value;
  l_log_msg :=  l_log_msg||' p_trn_type: '||p_trn_type;
  l_log_msg :=  l_log_msg||' p_check_unique_flag: '||p_check_unique_flag;
  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
END IF;

IF p_check_unique_flag = 'E' THEN

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'The Tax Registration Number is already used.';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

   p_return_status := FND_API.G_RET_STS_ERROR;
   p_error_buffer := 'ZX_REG_NUM_INVALID';

ELSIF p_check_unique_flag = 'S' THEN

 --IF p_trn_type = 'VAT' THEN

   IF lt_prefix = 'LT' THEN

      /*  check length = 11 or 14  */
     IF length(p_trn_value) = 11 OR length(p_trn_value) = 14 THEN

         /*  Check digits are numeric  */
       IF common_check_numeric(p_trn_value,3,length(p_trn_value)) = '0'  THEN

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'The Tax Registration Number is numeric.';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;

         p_return_status := FND_API.G_RET_STS_SUCCESS;
         p_error_buffer := NULL;
       ELSE

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'The Tax Registration Number must be numeric.';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;

         p_return_status := FND_API.G_RET_STS_ERROR;
         p_error_buffer := 'ZX_REG_NUM_MUST_BE_NUMERIC';

       END IF;

     ELSE

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'The length of the Tax Registration Number is not 9 or 12.';
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;

       IF length(trn_value) > 11 AND length(trn_value) < 14 THEN
          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_TOO_BIG';
       ELSIF length(trn_value) > 14 THEN
          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_TOO_BIG';
       ELSE
          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_INVALID';
       END IF;


     END IF;

   ELSE

     /*   check length = 9  or 12  */
     IF length(p_trn_value) = 9 OR length(p_trn_value) = 12 THEN

       /*  Check digits are numeric  */
       IF common_check_numeric(p_trn_value,1,length(p_trn_value)) = '0'  THEN

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               l_log_msg := 'The Tax Registration Number is numeric.';
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
            END IF;

            p_return_status := FND_API.G_RET_STS_SUCCESS;
            p_error_buffer := NULL;
       ELSE

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'The Tax Registration Number must be numeric.';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;

         p_return_status := FND_API.G_RET_STS_ERROR;
         p_error_buffer := 'ZX_REG_NUM_MUST_BE_NUMERIC';

       END IF;

     ELSE

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'The length of the Tax Registration Number is not 9 or 12.';
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;

       IF length(trn_value) > 9 AND length(trn_value) < 12 THEN
          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_TOO_BIG';
       ELSIF length(trn_value) > 12 THEN
          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_TOO_BIG';
       ELSE
          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_INVALID';
       END IF;

     END IF;

   END IF;

END IF;

END VALIDATE_TRN_LT;

/* ***********    End VALIDATE_TRN_LT       ****************** */


PROCEDURE VALIDATE_TRN_CY (p_trn_value         IN VARCHAR2,
                           p_trn_type          IN VARCHAR2,
                           p_check_unique_flag IN VARCHAR2,
                           p_return_status     OUT NOCOPY VARCHAR2,
                           p_error_buffer      OUT NOCOPY VARCHAR2)
                           AS

l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN_CY';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;


trn_value       VARCHAR2(50);
cy_prefix       VARCHAR2(2);

BEGIN

trn_value := upper(p_trn_value);
cy_prefix := substr(trn_value,1,2);

G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := l_procedure_name||'(+)';
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
END IF;

IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := 'Parameters ';
  l_log_msg :=  l_log_msg||'p_trn_value: '||p_trn_value;
  l_log_msg :=  l_log_msg||' p_trn_type: '||p_trn_type;
  l_log_msg :=  l_log_msg||' p_check_unique_flag: '||p_check_unique_flag;
  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
END IF;

IF p_check_unique_flag = 'E' THEN

   IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := 'The Tax Registration Number is already used.';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;

   p_return_status := FND_API.G_RET_STS_ERROR;
   p_error_buffer := 'ZX_REG_NUM_INVALID';

ELSIF p_check_unique_flag = 'S' THEN

 --IF p_trn_type = 'VAT' THEN

   IF substr(trn_value,1,2) = 'CY' THEN

      /*   check length = 11   */
     IF length(trn_value) = 11 THEN

       /*  Check first eight digits are numeric  */
       IF common_check_numeric(trn_value,3,8) = '0'  THEN

         IF substr(trn_value,11,1) between 'A' and 'Z' THEN

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               l_log_msg := 'The Tax Registration Number is numeric.';
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
            END IF;

            p_return_status := FND_API.G_RET_STS_SUCCESS;
            p_error_buffer := NULL;

         ELSE

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               l_log_msg := 'The last character must be a letter.';
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
            END IF;

            p_return_status := FND_API.G_RET_STS_ERROR;
            p_error_buffer := 'ZX_REG_NUM_INVALID';

         END IF;
       ELSE

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'The Tax Registration Number must be numeric.';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;

         p_return_status := FND_API.G_RET_STS_ERROR;
         p_error_buffer := 'ZX_REG_NUM_MUST_BE_NUMERIC';

       END IF;

     ELSE

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'The length of the Tax Registration Number is not 11.';
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;

       IF length(trn_value) > 11 THEN
          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_TOO_BIG';
       ELSE
          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_INVALID';
       END IF;
     END IF;

   ELSE

     /*   check length = 9   */
     IF length(trn_value) = 9 THEN

       /*  Check first eight digits are numeric  */
       IF common_check_numeric(trn_value,1,8) = '0'  THEN

         IF substr(trn_value,9,1) between 'A' and 'Z' THEN

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               l_log_msg := 'The Tax Registration Number is numeric.';
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
            END IF;

            p_return_status := FND_API.G_RET_STS_SUCCESS;
            p_error_buffer := NULL;

         ELSE

            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               l_log_msg := 'The last character must be a letter.';
               FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
            END IF;

            p_return_status := FND_API.G_RET_STS_ERROR;
            p_error_buffer := 'ZX_REG_NUM_INVALID';

         END IF;
       ELSE

         IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'The Tax Registration Number must be numeric.';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;

         p_return_status := FND_API.G_RET_STS_ERROR;
         p_error_buffer := 'ZX_REG_NUM_MUST_BE_NUMERIC';

       END IF;

     ELSE

       IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'The length of the Tax Registration Number is not 9.';
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;

       IF length(trn_value) > 9 THEN
          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_TOO_BIG';
       ELSE
          p_return_status := FND_API.G_RET_STS_ERROR;
          p_error_buffer := 'ZX_REG_NUM_INVALID';
       END IF;

     END IF;

   END IF;

END IF;

END VALIDATE_TRN_CY;

/* ***********    End VALIDATE_TRN_CY     ****************** */

END ZX_TRN_VALIDATION_PKG;

/
