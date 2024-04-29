--------------------------------------------------------
--  DDL for Package Body XLE_REGISTRATIONS_VAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLE_REGISTRATIONS_VAL_PVT" AS
/* $Header: xleregvb.pls 120.1.12010000.6 2009/08/21 18:36:45 ychandra ship $ */
G_PKG_NAME     VARCHAR2(30) := 'XLE_REGISTRATIONS_VAL_PVT';
-- Logging Infra
G_CURRENT_RUNTIME_LEVEL      NUMBER;
G_LEVEL_UNEXPECTED           CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR                CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION            CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT                CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE            CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME                CONSTANT VARCHAR2(50) := 'XLE.PLSQL.XLE_REGISTRATIONS_VAL_PVT';
g_log_msg                    VARCHAR2(2000);
-- Logging Infra
/*-----------------------------------------------------------
This procedure is called from the Creae LE page, Create
Registration for LE page and from Create Registration for
Establishment page.
This procedure validates the Registration Number as per the
validation rules known for a few of the countries.
viz - Argentina, Brazil, Colombia, Chile, Spain,
      Italy, Portugal
------------------------------------------------------------*/
PROCEDURE Validate_Reg_Number(
  p_jurisdiction_id       IN     NUMBER,
  p_registration_id       IN     NUMBER,
  p_registration_number   IN     VARCHAR2,
  p_entity_type           IN     VARCHAR2,
  p_init_msg_list         IN     VARCHAR2,
  x_return_status         IN OUT NOCOPY VARCHAR2,
  x_msg_count             IN OUT NOCOPY NUMBER   ,
  x_msg_data              IN OUT NOCOPY VARCHAR2)
IS
CURSOR c_jur_dtls (p_jurisdiction_id NUMBER,
                   p_entity_type     VARCHAR2)
IS
   SELECT jur.legislative_cat_code,
          DECODE(p_entity_type, 'LE' , jur.registration_code_le,
                                'ETB', jur.registration_code_etb) registration_code,
          DECODE(p_entity_type, 'LE' , jur.required_le_flag,
                                'ETB', jur.required_etb_flag) required_flag,
          geo.geography_code country_code
   FROM   xle_jurisdictions_b jur,
          hz_geographies      geo
   WHERE  jur.geography_id    = geo.geography_id
   AND    jur.jurisdiction_id = p_jurisdiction_id
   AND    TRUNC(SYSDATE) BETWEEN TRUNC(Nvl(jur.effective_from, SYSDATE))
                            AND TRUNC(Nvl(jur.effective_from, SYSDATE))
   AND    TRUNC(SYSDATE) BETWEEN TRUNC(Nvl(geo.start_date, SYSDATE))
                            AND TRUNC(Nvl(geo.end_date, SYSDATE));
CURSOR c_check_unique (p_source_table          VARCHAR2,
                       p_jurisdiction_id       NUMBER,
                       p_registration_number   VARCHAR2)
IS
SELECT registration_id
FROM   xle_registrations
WHERE  source_table    = p_source_table
AND    jurisdiction_id = p_jurisdiction_id
AND    registration_number = p_registration_number
AND    (effective_to is null or effective_to >= sysdate);
l_legislative_cat_code        xle_jurisdictions_b.legislative_cat_code%TYPE;
l_registration_code           xle_jurisdictions_b.registration_code_le%TYPE;
l_required_flag               xle_jurisdictions_b.required_le_flag%TYPE;
l_country_code                hz_geographies.geography_code%TYPE;
l_api_name                    VARCHAR2(50) := 'Validate_Reg_Number';
l_source_table                VARCHAR2(30);
l_registration_id             NUMBER;
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
   IF FND_API.to_boolean(p_init_msg_list)
   THEN
       FND_MSG_PUB.Initialize;
   END IF;
   IF p_jurisdiction_id IS NULL
   THEN
       -- this is  a development error
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_msg_data      := 'Mandatory parameter jurisdiction_id is not passed';
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
       THEN
           g_log_msg :=  'Mandatory parameter jurisdiction_id is not passed';
           FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_api_name, g_log_msg);
        END IF;
   END IF;
   IF x_return_status =  FND_API.G_RET_STS_SUCCESS
   THEN
       -- Check unique
       IF p_entity_type = 'ETB'
       THEN
           l_source_table := 'XLE_ETB_PROFILES';
       ELSE
           l_source_table := 'XLE_ENTITY_PROFILES';
       END IF;
       OPEN c_check_unique (l_source_table,
                            p_jurisdiction_id,
                            p_registration_number);
       FETCH c_check_unique INTO l_registration_id;
       CLOSE c_check_unique;
       IF l_registration_id IS NOT NULL
       THEN
           IF Nvl( p_registration_id, -99) <> l_registration_id
           THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               FND_MESSAGE.SET_NAME('XLE', 'XLE_REG_NUM_DUPLICATE_WARN');
               FND_MSG_PUB.Add;
               IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
               THEN
                   g_log_msg :=  'RegNumber is not unique ' || p_registration_number;
                   FND_LOG.STRING(G_LEVEL_STATEMENT,
                                  G_MODULE_NAME || l_api_name, g_log_msg);
                END IF;
           END IF;
       END IF;
   END IF;
   IF x_return_status =  FND_API.G_RET_STS_SUCCESS
   THEN
       OPEN c_jur_dtls (p_jurisdiction_id,
                        p_entity_type);
       FETCH c_jur_dtls INTO l_legislative_cat_code,
                             l_registration_code,
                             l_required_flag,
                             l_country_code;
       CLOSE c_jur_dtls;
       IF l_country_code IS NULL
       THEN
           -- this is  a development error
           x_return_status := FND_API.G_RET_STS_ERROR;
           x_msg_data      := 'Invalid jurisdiction_id passed';
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
           THEN
               g_log_msg :=  'Invalid jurisdiction_id passed';
               FND_LOG.STRING(G_LEVEL_STATEMENT,
                              G_MODULE_NAME || l_api_name, g_log_msg);
            END IF;
       END IF ;
   END IF ;
   IF   p_registration_number IS NOT NULL
   AND  l_registration_code IS NOT NULL
   AND  x_return_status = FND_API.G_RET_STS_SUCCESS
   THEN
       IF l_country_code = 'AR'
       THEN
           -- Validations for Argentina
           do_ar_regnum_validations(l_legislative_cat_code,
                                    l_required_flag,
                                    l_registration_code,
                                    p_registration_number,
                                    x_return_status,
                                    x_msg_data,
                                    x_msg_count);
       ELSIF l_country_code = 'BR'
       THEN
           -- Validations for Brazil
           do_br_regnum_validations(l_legislative_cat_code,
                                    l_required_flag,
                                    l_registration_code,
                                    p_registration_number,
                                    x_return_status,
                                    x_msg_data,
                                    x_msg_count);
       ELSIF l_country_code = 'CL'
       THEN
           -- Validations for Chile
           do_cl_regnum_validations(l_legislative_cat_code,
                                    l_required_flag,
                                    l_registration_code,
                                    p_registration_number,
                                    x_return_status,
                                    x_msg_data,
                                    x_msg_count);
       ELSIF l_country_code = 'CO'
       THEN
           -- Validations for Colombia
           do_co_regnum_validations(l_legislative_cat_code,
                                    l_required_flag,
                                    l_registration_code,
                                    p_registration_number,
                                    x_return_status,
                                    x_msg_data,
                                    x_msg_count);
       ELSIF l_country_code = 'IT'
       THEN
           -- Validations for Italy
           do_it_regnum_validations(l_legislative_cat_code,
                                    l_required_flag,
                                    l_registration_code,
                                    p_registration_number,
                                    x_return_status,
                                    x_msg_data,
                                    x_msg_count);
       ELSIF l_country_code = 'PT'
       THEN
           -- Validations for Portugal
           do_pt_regnum_validations(l_legislative_cat_code,
                                    l_required_flag,
                                    l_registration_code,
                                    p_registration_number,
                                    x_return_status,
                                    x_msg_data,
                                    x_msg_count);
       ELSIF l_country_code = 'ES'
       THEN
           -- Validations for Spain
           do_es_regnum_validations(l_legislative_cat_code,
                                    l_required_flag,
                                    l_registration_code,
                                    p_registration_number,
                                    x_return_status,
                                    x_msg_data,
                                    x_msg_count);
       END IF; -- Check country code
   END IF; -- Reg Code and Number provided
   FND_MSG_PUB.Count_And_Get
     (p_count         	=>      x_msg_count,
      p_data          	=>      x_msg_data);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
        THEN
            g_log_msg := SQLERRM;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_api_name, g_log_msg);
        END IF;
	x_return_status := FND_API.G_RET_STS_ERROR ;
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data
    	);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
        THEN
            g_log_msg := SQLERRM;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_api_name, g_log_msg);
        END IF;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count,
                p_data          	=>      x_msg_data
    	);
    WHEN OTHERS THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
        THEN
            g_log_msg := SQLERRM;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_api_name, g_log_msg);
        END IF;
    	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  	IF 	FND_MSG_PUB.Check_Msg_Level
		(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
        	FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                         l_api_name);
	END IF;
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data
    	);
END Validate_Reg_Number;
-- Check if a given pattern has only numbers
FUNCTION check_numeric(check_value VARCHAR2,
                       pos_from    NUMBER,
                       pos_for     NUMBER)
RETURN VARCHAR2
IS
   num_check VARCHAR2(40);
BEGIN
   num_check := '1';
   num_check := nvl(
                   rtrim(
                         translate(substr(check_value,pos_from,pos_for),
                             '1234567890',
                             '          ')
                                            ), '0'
                                                        );
   RETURN(num_check);
END check_numeric;
-- Check if a given pattern has only numbers
-- For the Latin American codes, the reg number can also have
-- '-', '.', '/'
FUNCTION check_numeric_latin(check_value VARCHAR2)
RETURN VARCHAR2
IS
   num_check VARCHAR2(40);
BEGIN
   num_check := '1';
   num_check := nvl(
                   rtrim(
                         translate(check_value,
                             '1234567890/-.',
                             '          ')
                                            ), '0'
                                                        );
   RETURN(num_check);
END check_numeric_latin;
-- Perform Spanish registration number validations
PROCEDURE do_es_regnum_validations(
  p_legislative_cat_code      IN VARCHAR2,
  p_required_flag             IN VARCHAR2,
  p_registration_code         IN VARCHAR2,
  p_registration_number       IN VARCHAR2,
  x_return_status             IN OUT NOCOPY VARCHAR2 ,
  x_msg_data                  IN OUT NOCOPY VARCHAR2 ,
  x_msg_count                 IN OUT NOCOPY NUMBER )
IS
l_nif_value          xle_registrations.registration_number%TYPE;
l_check_digit        VARCHAR2(2);
l_work_nif           VARCHAR2(20);
l_numeric_result     VARCHAR2(40);
l_work_nif_d         NUMBER(20);
l_api_name           VARCHAR2(50) := 'do_es_regnum_validations';
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF p_registration_code NOT IN ('NIF', 'CIF')
   THEN
       RETURN;
   END IF;
   l_nif_value     := p_registration_number;
   l_check_digit   := substr(l_nif_value, length(l_nif_value));
   IF length(l_nif_value) > 1
   THEN
      /** make sure that Fiscal Code starts with one of the following characters **/
      IF upper(substr(l_nif_value,1,1))
          IN  ('A','B','C','D','E','F','G','H','T','P','Q','S',
               'X','K','L','M','N','Y','Z','J','R','U','V','W',
			   '0','1','2','3','4','5','6','7','8','9')
      THEN
          /** If the Fiscal Code starts with a T, then no futher **/
          /** validation is required                             **/
          IF substr(l_nif_value,1,1) = 'T'
          THEN
              x_return_status := FND_API.G_RET_STS_SUCCESS;
		  /* Bug: 7609077 Added the logic for taxpayer id starting with 'N' */
		  ELSIF substr(l_nif_value,1,1) = 'N'
		  THEN
		    l_numeric_result := check_numeric(l_nif_value,2,length(l_nif_value)-2);
			IF l_numeric_result = '0'
			THEN
			  /* It's Numeric Continue, Check if the last digit is a character */
			  IF (instr('ABCDEFGHIJKLMNOPQRSTUVWXYZ', l_check_digit) > 0)
			  THEN
			    x_return_status := FND_API.G_RET_STS_SUCCESS;
			  ELSE
			    x_return_status := FND_API.G_RET_STS_ERROR;
                IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
                THEN
                  g_log_msg := 'Check Algorithm failed for ' ||
                                p_registration_number;
                  FND_LOG.STRING(G_LEVEL_STATEMENT,
                                 G_MODULE_NAME || l_api_name, g_log_msg);
                END IF;
              END IF;
			ELSE
              x_return_status := FND_API.G_RET_STS_ERROR;
              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
              THEN
                g_log_msg := 'Non numeric characters found in ' ||
                              p_registration_number;
                FND_LOG.STRING(G_LEVEL_STATEMENT,
                               G_MODULE_NAME || l_api_name, g_log_msg);
              END IF;
            END IF;
		  /* Bug: 7609077 added the logic for taxpayer id starting with 'Y', 'Z' */
          ELSIF substr(l_nif_value,1,1) in
                   ('X','K','L','M','Y','Z','0','1','2','3','4','5','6','7','8','9')
          THEN
              /** Fiscal Code does not start with 'T' **/
              /** IF the Fiscal Code begins with the following  **/
              /** It's a physical person. The NIF has to end in a       **/
              /** specific letter. Eg VAlids = X1596399S,2601871L       **/
              IF substr(l_nif_value,1,1) in ('X','K','L','M','Y','Z')
              THEN
                  l_numeric_result := check_numeric(l_nif_value,2,length(l_nif_value)-2);
                  IF l_numeric_result = '0'
                  THEN
                      /* its numeric so continue  */
					  IF(substr(l_nif_value,1,1) = 'Y')
					  THEN
					    l_work_nif := '1' || substr(l_nif_value,2,length(l_nif_value)-2);
					  ELSIF(substr(l_nif_value,1,1) = 'Z')
					  THEN
					    l_work_nif := '2' || substr(l_nif_value,2,length(l_nif_value)-2);
					  ELSE
                        l_work_nif := substr(l_nif_value,2,length(l_nif_value)-2);
					  END IF;
                      IF substr('TRWAGMYFPDXBNJZSQVHLCKE',mod
                              (to_number(l_work_nif) ,23) + 1,1) = l_check_digit
                      THEN
                          x_return_status := FND_API.G_RET_STS_SUCCESS;
                      ELSE
                          x_return_status := FND_API.G_RET_STS_ERROR;
                          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
                          THEN
                              g_log_msg := 'Check Algorithm failed for ' ||
                                            p_registration_number;
                              FND_LOG.STRING(G_LEVEL_STATEMENT,
                                            G_MODULE_NAME || l_api_name, g_log_msg);
                          END IF;
                      END IF;
                   ELSE
                      x_return_status := FND_API.G_RET_STS_ERROR;
                      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
                      THEN
                          g_log_msg := 'Non numeric characters found in ' ||
                                        p_registration_number;
                          FND_LOG.STRING(G_LEVEL_STATEMENT,
                                        G_MODULE_NAME || l_api_name, g_log_msg);
                      END IF;
                   END IF; /* end of numeric check  */
             ELSE
                 l_numeric_result := check_numeric(l_nif_value,1,length(l_nif_value)-1);
                 IF l_numeric_result = '0'
                 THEN
                     /* its numeric so continue  */
                     l_work_nif := substr(l_nif_value,1,length(l_nif_value)-1);
                     IF substr('TRWAGMYFPDXBNJZSQVHLCKE',mod
                              (to_number(l_work_nif) ,23) + 1,1) = l_check_digit
                     THEN
                          x_return_status := FND_API.G_RET_STS_SUCCESS;
                     ELSE
                          x_return_status := FND_API.G_RET_STS_ERROR;
                          IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
                          THEN
                              g_log_msg := 'Check Algorithm failed for ' ||
                                            p_registration_number;
                              FND_LOG.STRING(G_LEVEL_STATEMENT,
                                            G_MODULE_NAME || l_api_name, g_log_msg);
                          END IF;
                     END IF;
                  ELSE
                      x_return_status := FND_API.G_RET_STS_ERROR;
                      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
                      THEN
                          g_log_msg := 'Non numeric characters found in ' ||
                                        p_registration_number;
                          FND_LOG.STRING(G_LEVEL_STATEMENT,
                                        G_MODULE_NAME || l_api_name, g_log_msg);
                      END IF;
                  END IF; /* end of numeric check  */
             END IF;
			/* Bug: 7609077 added the logic for taxpayer id starting with 'J','R','U','V','W' */
            ELSIF substr(l_nif_value,1,1) in
                   ('A','B','C','D','E','F','G','H','P','Q','S','J','R','U','V','W')
          THEN
              /** It's a company. Examples of valid company NIFs are    **/
              /** A78361482 A78211646 F2831001I Q0467001D P0801500J     **/
              l_numeric_result := check_numeric(l_nif_value,2,length(l_nif_value)-2);
              IF l_numeric_result = '0'
              THEN
                  /* its numeric so continue  */
                  l_work_nif := substr(l_nif_value,2,length(l_nif_value)-2);
                  l_work_nif_d := to_number(substr(l_work_nif,2,1)) +
                                to_number(substr(l_work_nif,4,1)) +
                                to_number(substr(l_work_nif,6,1)) +
                                to_number(substr(to_char(to_number(substr(l_work_nif,1,1)) * 2),1,1)) +
                                to_number(nvl(substr(to_char(to_number(substr(l_work_nif,1,1))
                                          * 2),2,1),'0')) +
                                to_number(substr(to_char(to_number(substr(l_work_nif,3,1)) * 2),1,1)) +
                                to_number(nvl(substr(to_char(to_number(substr(l_work_nif,3,1))
                                          * 2),2,1),'0')) +
                                to_number(substr(to_char(to_number(substr(l_work_nif,5,1)) * 2),1,1)) +
                                to_number(nvl(substr(to_char(to_number(substr(l_work_nif,5,1))
                                          * 2),2,1),'0')) +
                                to_number(substr(to_char(to_number(substr(l_work_nif,7,1)) * 2),1,1)) +
                                to_number(nvl(substr(to_char(to_number(substr(l_work_nif,7,1))
                                          * 2),2,1),'0'))
                                     + nvl(to_number(substr(l_work_nif,8,1)),0)
                                     + nvl(to_number(substr(to_char(to_number(substr(l_work_nif,9,1)) * 2),1,1)),0) +
                                to_number(nvl(substr(to_char(to_number(substr(l_work_nif,9,1))
                                          * 2),2,1),'0'));
                   IF l_check_digit in ('A','B','C','D','E','F','G','H','I','J')
                   THEN
                       IF substr('JABCDEFGHI',((ceil(l_work_nif_d/10) * 10)
                                         - l_work_nif_d) + 1, 1) = l_check_digit
                       THEN
                           x_return_status := FND_API.G_RET_STS_SUCCESS;
                       ELSE
                           x_return_status := FND_API.G_RET_STS_ERROR;
                           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
                           THEN
                               g_log_msg := 'Check Algorithm failed for ' ||
                                            p_registration_number;
                               FND_LOG.STRING(G_LEVEL_STATEMENT,
                                            G_MODULE_NAME || l_api_name, g_log_msg);
                           END IF;
                       END IF;
                     ELSIF l_check_digit = to_char((ceil(l_work_nif_d/10) *10) - l_work_nif_d)
                   THEN
                       x_return_status := FND_API.G_RET_STS_SUCCESS;
                   ELSE
                       x_return_status := FND_API.G_RET_STS_ERROR;
                       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
                       THEN
                           g_log_msg := 'Check Algorithm failed for ' ||
                                        p_registration_number;
                           FND_LOG.STRING(G_LEVEL_STATEMENT,
                                        G_MODULE_NAME || l_api_name, g_log_msg);
                       END IF;
                   END IF;
               ELSE
                   x_return_status := FND_API.G_RET_STS_ERROR;
                   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
                   THEN
                       g_log_msg := 'Non numeric characters found in ' ||
                                     p_registration_number;
                       FND_LOG.STRING(G_LEVEL_STATEMENT,
                                        G_MODULE_NAME || l_api_name, g_log_msg);
                   END IF;
               END IF; /* end of numeric check  */
           ELSE
               IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
               THEN
                   g_log_msg := 'Reg number is not person and not a company '||
                                 p_registration_number;
                   FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_api_name, g_log_msg);
               END IF;
               x_return_status := FND_API.G_RET_STS_ERROR;
           END IF; /* End of person or company check */
       ELSE
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
           THEN
               g_log_msg := 'Reg Num does not start with a valid character '||
                             p_registration_number;
               FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_api_name, g_log_msg);
           END IF;
           x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;  /* does not start with a valid character  */
   ELSE
       x_return_status := FND_API.G_RET_STS_ERROR;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
       THEN
           g_log_msg := 'Reg Num failed length check '||
                         p_registration_number;
           FND_LOG.STRING(G_LEVEL_STATEMENT,
                         G_MODULE_NAME || l_api_name, g_log_msg);
       END IF;
   END IF;  /* end of length check */
   IF x_return_status = FND_API.G_RET_STS_ERROR
   THEN
       FND_MESSAGE.SET_NAME('XLE', 'XLE_INVALID_REG_NUM_ERR');
       FND_MESSAGE.SET_TOKEN('REG_CODE', p_registration_code);
       FND_MESSAGE.SET_TOKEN('REG_NUM', p_registration_number);
       FND_MSG_PUB.Add;
   END IF;
   FND_MSG_PUB.Count_And_Get
     (p_count         	=>      x_msg_count,
      p_data          	=>      x_msg_data);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
        THEN
            g_log_msg := SQLERRM;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_api_name, g_log_msg);
        END IF;
	x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                 l_api_name);
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data
    	);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
        THEN
            g_log_msg := SQLERRM;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_api_name, g_log_msg);
        END IF;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                 l_api_name);
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count,
                p_data          	=>      x_msg_data
    	);
    WHEN OTHERS THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
        THEN
            g_log_msg := SQLERRM;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_api_name, g_log_msg);
        END IF;
    	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                 l_api_name);
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data
    	);
END do_es_regnum_validations;


procedure PO_VALIDATE_VAT_IT(VAT_VALUE    IN  varchar2,           -- Bug No : 6884561 Start
                                      Xi_UNIQUE_FLAG IN varchar2,
                                      RET_VAR      OUT NOCOPY varchar2,
                                      RET_MESSAGE  OUT NOCOPY varchar2)
                                      AS
VAT_NUM              varchar2(30);
check_digit          number(1);
position_i           number(2);
integer_value        number(1);
calc_check           number(2);
calc_cd              varchar2(1);
indicator            varchar2(1);
even_value           number(2);
even_sub_tot         number(4);
even_tot             number(5);
odd_tot              number(5);
check_tot            number(6);
                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/
procedure fail_uniqueness is
begin
      RET_VAR := 'F';
      RET_MESSAGE := 'PO_VAT_DUPLICATE_VAT_NUM';
end fail_uniqueness;
procedure fail_check is
begin
      RET_VAR := 'F';
      RET_MESSAGE := 'PO_VAT_INVALID_VAT_NUM';
end fail_check;
procedure system_failure is
begin
     RAISE_APPLICATION_ERROR(-20000, 'PROCEDURE PO_VALIDATE_VAT_IT');
end system_failure;
procedure pass_check is
begin
      RET_VAR := 'P';
      RET_MESSAGE := '';
end pass_check;
/** procedure to check that the chars sent are numeric only **/
/** if ok, then sends back the output as a number **/
procedure check_numeric(input_string IN varchar2,
                        output_val OUT NOCOPY varchar2,
                        flag1 OUT NOCOPY varchar2) is
num_check varchar2(30);
var1      varchar2(30);
begin
   num_check := '';
   var1 := input_string;
   num_check := nvl(rtrim( translate(var1, '1234567890',
                                            '          ')
                         ), '0'
                    );
   IF num_check <> '0'
      then
        flag1 := 'F';
        output_val  := '0';
   ELSE
        flag1 := 'P';
        output_val  := var1;
   END IF;
end check_numeric;
                            /****************/
                            /* MAIN SECTION */
                            /****************/
BEGIN
indicator := '';
odd_tot := 0;
even_tot := 0;
/** ensure that VAT_VALUE passed in is only numeric **/
check_numeric(VAT_VALUE, VAT_NUM, indicator);
check_digit := substr(VAT_NUM, (length(VAT_NUM)));

IF Xi_UNIQUE_FLAG = 'N'
  then
    fail_uniqueness;
ELSIF Xi_UNIQUE_FLAG = 'Y'
  then
  /**  make sure that VAT Num code is only 11chars - including Check digit **/
  IF (length(VAT_NUM) = 11) AND (indicator = 'P')
    then
       FOR position_i IN 1..10 LOOP
   /** moves along length of VAT Num Code and assigns weightings  **/
   /** to each of the digits upto and including the 10th position **/
   /** all odd positioned integers are added together. All evenly **/
   /** postitioned integers are multiplied by 2, if greater than  **/
   /** 10, the digits are added together. The last digit of the   **/
   /** sum totals when added together is subtracted from 10 - unless **/
   /** already zero. This becomes the VAT Num check digit         **/
            integer_value := substr(VAT_NUM,position_i,1);
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
       /*** After having calculated what should be the ITALIAN VAT Num ***/
       /*** Check digit compare to the actual and fail if not the same ***/
       IF calc_cd <> check_digit
           then
             fail_check;
       ELSE
             pass_check;
       END IF;
  ELSE
    fail_check; /** VAT Num is incorrect length or is not numeric**/
  END IF;
ELSE
   pass_check;
END IF;  /** of fail uniqueness check **/
END PO_VALIDATE_VAT_IT;                     -- Bug No : 6884561 End

/**********   End of PO_VALIDATE_VAT_IT  **************************/

-- Perform Portugeese registration number validations
--Ex valid number is - 502186771
PROCEDURE do_pt_regnum_validations(
  p_legislative_cat_code      IN VARCHAR2,
  p_required_flag             IN VARCHAR2,
  p_registration_code         IN VARCHAR2,
  p_registration_number       IN VARCHAR2,
  x_return_status             IN OUT NOCOPY VARCHAR2 ,
  x_msg_data                  IN OUT NOCOPY VARCHAR2 ,
  x_msg_count                 IN OUT NOCOPY NUMBER )
IS
l_nif_value          xle_registrations.registration_number%TYPE;
l_check_digit        VARCHAR2(2);
l_work_nif           VARCHAR2(20);
l_numeric_result     VARCHAR2(40);
l_work_nif_d         NUMBER(20);
l_position_i         NUMBER(2);
l_integer_value      NUMBER(1);
l_multiplied_number  NUMBER(2);
l_multiplied_sum     NUMBER(3);
l_check_result       VARCHAR2(1);
l_mod11              NUMBER(8);
l_cal_cd             NUMBER(2);
l_api_name           VARCHAR2(50) := 'do_pt_regnum_validations';
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF p_registration_code <> 'NIPC'
   THEN
       RETURN;
   END IF;
   l_nif_value     := p_registration_number;
   l_check_digit   := substr(l_nif_value, length(l_nif_value));
   l_multiplied_number := 0;
   l_multiplied_sum    := 0;
   IF length(l_nif_value) = 9
   THEN
       l_numeric_result := check_numeric(l_nif_value,1,length(l_nif_value));
       IF l_numeric_result = '0'
       THEN
           /* its numeric so continue  */
           FOR l_position_i IN 2..length(l_nif_value)
           LOOP
               l_integer_value := substr(l_nif_value,length(l_nif_value)-(l_position_i-1),1);
               l_multiplied_number := l_integer_value * l_position_i;
               l_multiplied_sum := l_multiplied_sum + l_multiplied_number;
           END LOOP;
           l_mod11 := (floor(l_multiplied_sum/11)+1)*11;
           l_cal_cd := l_mod11 - l_multiplied_sum;
           IF (mod(l_multiplied_sum,11) = 0) OR (l_cal_cd > 9)
           THEN
               l_cal_cd := 0;
           END IF;
           IF l_cal_cd = l_check_digit
           THEN
               x_return_status := FND_API.G_RET_STS_SUCCESS;
           ELSE
               x_return_status := FND_API.G_RET_STS_ERROR;
               IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
               THEN
                   g_log_msg := ' Check algorithm not successfull for '||
                                  p_registration_number;
                   FND_LOG.STRING(G_LEVEL_STATEMENT,
                                 G_MODULE_NAME || l_api_name, g_log_msg);
               END IF;
           END IF;
       ELSE
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
           THEN
               g_log_msg := 'Non numeric characters found ' ||
                             p_registration_number;
               FND_LOG.STRING(G_LEVEL_STATEMENT,
                             G_MODULE_NAME || l_api_name, g_log_msg);
           END IF;
       END IF;
   ELSE
       x_return_status := FND_API.G_RET_STS_ERROR;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
       THEN
           g_log_msg := 'Reg Num failed length check '||
                         p_registration_number;
           FND_LOG.STRING(G_LEVEL_STATEMENT,
                         G_MODULE_NAME || l_api_name, g_log_msg);
       END IF;
   END IF; /* of fail length check */
   IF x_return_status = FND_API.G_RET_STS_ERROR
   THEN
       FND_MESSAGE.SET_NAME('XLE', 'XLE_INVALID_REG_NUM_ERR');
       FND_MESSAGE.SET_TOKEN('REG_CODE', p_registration_code);
       FND_MESSAGE.SET_TOKEN('REG_NUM', p_registration_number);
       FND_MSG_PUB.Add;
   END IF;
   FND_MSG_PUB.Count_And_Get
     (p_count         	=>      x_msg_count,
      p_data          	=>      x_msg_data);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
        THEN
            g_log_msg := SQLERRM;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_api_name, g_log_msg);
        END IF;
	x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                 l_api_name);
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data
    	);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
        THEN
            g_log_msg := SQLERRM;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_api_name, g_log_msg);
        END IF;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                 l_api_name);
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count,
                p_data          	=>      x_msg_data
    	);
    WHEN OTHERS THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
        THEN
            g_log_msg := SQLERRM;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_api_name, g_log_msg);
        END IF;
    	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                 l_api_name);
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data
    	);
END do_pt_regnum_validations;
-- Perform Italian registration number validations
-- Eg of a valid number is 100000000000000H
PROCEDURE do_it_regnum_validations(
  p_legislative_cat_code      IN VARCHAR2,
  p_required_flag             IN VARCHAR2,
  p_registration_code         IN VARCHAR2,
  p_registration_number       IN VARCHAR2,
  x_return_status             IN OUT NOCOPY VARCHAR2 ,
  x_msg_data                  IN OUT NOCOPY VARCHAR2 ,
  x_msg_count                 IN OUT NOCOPY NUMBER )
IS
l_nif_value          xle_registrations.registration_number%TYPE;
l_check_digit        VARCHAR2(2);
l_position_i         NUMBER(2);
l_position_weight    NUMBER(2);
l_total_weighting    NUMBER(3);
l_char_value         VARCHAR2(1);
l_calc_check         NUMBER(2);
l_calc_cd            VARCHAR2(1);
vat_ret_code         varchar2(1);
vat_ret_message      varchar2(60);
l_api_name           VARCHAR2(50) := 'do_it_regnum_validations';

procedure fail_uniqueness is
begin
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'PO_NIF_DUPLICATE_NIF_NUM';
end fail_uniqueness;

/**     FUNCTION returns the calculated check digit  **/
FUNCTION find_check_digit(l_remainder NUMBER)
RETURN VARCHAR2 IS
l_cd_result varchar2(1);
BEGIN
    IF l_remainder = 0
    THEN
        l_cd_result := 'A';
    ELSIF l_remainder = 1
    THEN
        l_cd_result := 'B';
    ELSIF l_remainder = 2
    THEN
        l_cd_result := 'C';
    ELSIF l_remainder = 3
    THEN
        l_cd_result := 'D';
    ELSIF l_remainder = 4
    THEN
        l_cd_result := 'E';
    ELSIF l_remainder = 5
    THEN
        l_cd_result := 'F';
    ELSIF l_remainder = 6
    THEN
        l_cd_result := 'G';
    ELSIF l_remainder = 7
    THEN
        l_cd_result := 'H';
    ELSIF l_remainder = 8
    THEN
        l_cd_result := 'I';
    ELSIF l_remainder = 9
    THEN
        l_cd_result := 'J';
    ELSIF l_remainder = 10
    THEN
        l_cd_result := 'K';
    ELSIF l_remainder = 11
    THEN
        l_cd_result := 'L';
    ELSIF l_remainder = 12
    THEN
        l_cd_result := 'M';
    ELSIF l_remainder = 13
    THEN
        l_cd_result := 'N';
    ELSIF l_remainder = 14
    THEN
        l_cd_result := 'O';
    ELSIF l_remainder = 15
    THEN
        l_cd_result := 'P';
    ELSIF l_remainder = 16
    THEN
        l_cd_result := 'Q';
    ELSIF l_remainder = 17
    THEN
        l_cd_result := 'R';
    ELSIF l_remainder = 18
    THEN
        l_cd_result := 'S';
    ELSIF l_remainder = 19
    THEN
        l_cd_result := 'T';
    ELSIF l_remainder = 20
    THEN
        l_cd_result := 'U';
    ELSIF l_remainder = 21
    THEN
        l_cd_result := 'V';
    ELSIF l_remainder = 22
    THEN
        l_cd_result := 'W';
    ELSIF l_remainder = 23
    THEN
        l_cd_result := 'X';
    ELSIF l_remainder = 24
    THEN
        l_cd_result := 'Y';
    ELSIF l_remainder = 25
    THEN
        l_cd_result := 'Z';
    ELSE
        l_cd_result := 'Error';
    END IF;
    RETURN l_cd_result;
end find_check_digit;
/**     returns the weighting of the even-postitioned figures. **/
FUNCTION func_even_weighting(l_in_value VARCHAR2) RETURN NUMBER IS
l_even_result number(2);
BEGIN
    IF l_in_value in ('A','0')
    THEN
        l_even_result := 0;
    ELSIF l_in_value in ('B','1')
    THEN
        l_even_result := 1;
    ELSIF l_in_value in ('C','2')
    THEN
        l_even_result := 2;
    ELSIF l_in_value in ('D','3')
    THEN
        l_even_result := 3;
    ELSIF l_in_value in ('E','4')
    THEN
        l_even_result := 4;
    ELSIF l_in_value in ('F','5')
    THEN
        l_even_result := 5;
    ELSIF l_in_value in ('G','6')
    THEN
        l_even_result := 6;
    ELSIF l_in_value in ('H','7')
    THEN
        l_even_result := 7;
    ELSIF l_in_value in ('I','8')
    THEN
        l_even_result := 8;
    ELSIF l_in_value in ('J','9')
    THEN
        l_even_result := 9;
    ELSIF l_in_value = 'K'
    THEN
        l_even_result := 10;
    ELSIF l_in_value = 'L'
    THEN
        l_even_result := 11;
    ELSIF l_in_value = 'M'
    THEN
        l_even_result := 12;
    ELSIF l_in_value = 'N'
    THEN
        l_even_result := 13;
    ELSIF l_in_value = 'O'
    THEN
        l_even_result := 14;
    ELSIF l_in_value = 'P'
    THEN
        l_even_result := 15;
    ELSIF l_in_value = 'Q'
    THEN
        l_even_result := 16;
    ELSIF l_in_value = 'R'
    THEN
        l_even_result := 17;
    ELSIF l_in_value = 'S'
    THEN
        l_even_result := 18;
    ELSIF l_in_value = 'T'
    THEN
        l_even_result := 19;
    ELSIF l_in_value = 'U'
    THEN
        l_even_result := 20;
    ELSIF l_in_value = 'V'
    THEN
        l_even_result := 21;
    ELSIF l_in_value = 'W'
    THEN
        l_even_result := 22;
    ELSIF l_in_value = 'X'
    THEN
        l_even_result := 23;
    ELSIF l_in_value = 'Y'
    THEN
        l_even_result := 24;
    ELSIF l_in_value = 'Z'
    THEN
        l_even_result := 25;
    END IF;
    RETURN l_even_result;
END func_even_weighting;

/**     returns the weighting of the odd-postitioned figures.  **/
FUNCTION func_odd_weighting(l_odd_value VARCHAR2) RETURN NUMBER IS
l_odd_result number(2);
BEGIN
    IF l_odd_value in ('A','0')
    THEN
        l_odd_result := 1;
    ELSIF l_odd_value in ('B','1')
    THEN
        l_odd_result := 0;
    ELSIF l_odd_value in ('C','2')
    THEN
        l_odd_result := 5;
    ELSIF l_odd_value in ('D','3')
    THEN
        l_odd_result := 7;
    ELSIF l_odd_value in ('E','4')
    THEN
        l_odd_result := 9;
    ELSIF l_odd_value in ('F','5')
    THEN
        l_odd_result := 13;
    ELSIF l_odd_value in ('G','6')
    THEN
        l_odd_result := 15;
    ELSIF l_odd_value in ('H','7')
    THEN
        l_odd_result := 17;
    ELSIF l_odd_value in ('I','8')
    THEN
        l_odd_result := 19;
    ELSIF l_odd_value in ('J','9')
    THEN
        l_odd_result := 21;
    ELSIF l_odd_value = 'K'
    THEN
        l_odd_result := 2;
    ELSIF l_odd_value = 'L'
    THEN
        l_odd_result := 4;
    ELSIF l_odd_value = 'M'
    THEN
        l_odd_result := 18;
    ELSIF l_odd_value = 'N'
    THEN
        l_odd_result := 20;
    ELSIF l_odd_value = 'O'
    THEN
        l_odd_result := 11;
    ELSIF l_odd_value = 'P'
    THEN
        l_odd_result := 3;
    ELSIF l_odd_value = 'Q'
    THEN
        l_odd_result := 6;
    ELSIF l_odd_value = 'R'
    THEN
        l_odd_result := 8;
    ELSIF l_odd_value = 'S'
    THEN
        l_odd_result := 12;
    ELSIF l_odd_value = 'T'
    THEN
        l_odd_result := 14;
    ELSIF l_odd_value = 'U'
    THEN
        l_odd_result := 16;
    ELSIF l_odd_value = 'V'
    THEN
        l_odd_result := 10;
    ELSIF l_odd_value = 'W'
    THEN
        l_odd_result := 22;
    ELSIF l_odd_value = 'X'
    THEN
        l_odd_result := 25;
    ELSIF l_odd_value = 'Y'
    THEN
        l_odd_result := 24;
    ELSIF l_odd_value = 'Z'
    THEN
        l_odd_result := 23;
    END IF;
    RETURN l_odd_result;
END func_odd_weighting;
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF p_registration_code <> 'FCIT'
   THEN
       RETURN;
   END IF;
   l_nif_value     := p_registration_number;
   l_check_digit   := substr(l_nif_value, length(l_nif_value));
   l_total_weighting := 0;
   l_position_weight := 0;

   /**  make sure that Fiscal code is only 16 chars - including Check digit **/
   IF length(l_nif_value) = 16
   THEN
       FOR l_position_i IN 1..15 LOOP
           /** moves along length of Fiscal Code and assigns weightings  **/
           /** to each of the codes characters upto and including  the 15th char **/
           /** on each loop the total of weightings is totalled            **/
           l_char_value := substr(l_nif_value,l_position_i,1);
           IF l_position_i in (2,4,6,8,10,12,14)
           THEN
               l_position_weight := func_even_weighting(l_char_value);
           ELSE
               l_position_weight := func_odd_weighting(l_char_value);
           END IF;
           l_total_weighting := l_total_weighting + l_position_weight;
       END LOOP;   /** of the counter position_i **/
       /** Divide the total by 23 and store the remainder into cal_check **/
       l_calc_check :=  MOD(l_total_weighting, 26);
       l_calc_cd := find_check_digit(l_calc_check);
       /*** After having calculated what should be the ITALIAN Fiscal  ***/
       /*** Check digit compare to the actual and fail if not the same ***/
       IF l_calc_cd <> l_check_digit
       THEN
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
           THEN
               g_log_msg := 'Check Algorithm failed for '||
                             p_registration_number;
               FND_LOG.STRING(G_LEVEL_STATEMENT,
                             G_MODULE_NAME || l_api_name, g_log_msg);
           END IF;
       ELSE
           x_return_status := FND_API.G_RET_STS_SUCCESS;
       END IF;
 ELSIF length(l_nif_value) = 11      -- Bug No : 6884561 Start
    then
      /** Additional requirement of Italy  BUG NO : 6884561             **/
      /** This is a new requirement. Italian Fiscal Codes may either be **/
      /** 16 OR 11 chars - if 11 then must pass the VAT Code validation **/
      /** routine - if 16 must be Fiscal Code for an individual which   **/
      /** has this procedure to validate it                             **/
                PO_VALIDATE_VAT_IT(l_nif_value,
                      p_required_flag,
                      vat_ret_code,
                      vat_ret_message);
                IF vat_ret_code = 'F'
                  then
                    x_return_status := FND_API.G_RET_STS_ERROR;
                ELSE
                     x_return_status := FND_API.G_RET_STS_SUCCESS;
		     x_msg_data := '';
                END IF;
   ELSE      -- Bug No : 6884561 End

       /** Fiscal code is incorrect length **/
       x_return_status := FND_API.G_RET_STS_ERROR;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
       THEN
           g_log_msg := 'Registration number is of incorrect length '||
                         p_registration_number;
           FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_api_name, g_log_msg);
       END IF;
   END IF;

   IF x_return_status = FND_API.G_RET_STS_ERROR
   THEN
       FND_MESSAGE.SET_NAME('XLE', 'XLE_INVALID_REG_NUM_ERR');
       FND_MESSAGE.SET_TOKEN('REG_CODE', p_registration_code);
       FND_MESSAGE.SET_TOKEN('REG_NUM', p_registration_number);
       FND_MSG_PUB.Add;
   END IF;
   FND_MSG_PUB.Count_And_Get
     (p_count         	=>      x_msg_count,
      p_data          	=>      x_msg_data);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
        THEN
            g_log_msg := SQLERRM;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_api_name, g_log_msg);
        END IF;
	x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                 l_api_name);
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data
    	);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
        THEN
            g_log_msg := SQLERRM;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_api_name, g_log_msg);
        END IF;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                 l_api_name);
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count,
                p_data          	=>      x_msg_data
    	);
    WHEN OTHERS THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
        THEN
            g_log_msg := SQLERRM;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_api_name, g_log_msg);
        END IF;
    	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                 l_api_name);
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data
    	);
END do_it_regnum_validations;
-- Perform Argentinian registration number validations
-- Format usually is 99-99999999-9
-- Ex valid number is - 10-00000000-6
PROCEDURE do_ar_regnum_validations(
  p_legislative_cat_code      IN VARCHAR2,
  p_required_flag             IN VARCHAR2,
  p_registration_code         IN VARCHAR2,
  p_registration_number       IN VARCHAR2,
  x_return_status             IN OUT NOCOPY VARCHAR2 ,
  x_msg_data                  IN OUT NOCOPY VARCHAR2 ,
  x_msg_count                 IN OUT NOCOPY NUMBER )
IS
l_nif_value          xle_registrations.registration_number%TYPE;
l_nif_num            xle_registrations.registration_number%TYPE;
l_check_digit        VARCHAR2(2);
l_val_digit          VARCHAR2(2);
l_api_name           VARCHAR2(50) := 'do_ar_regnum_validations';
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF p_registration_code <> 'CUIT'
   THEN
       RETURN;
   END IF;
   l_nif_value     := substr(p_registration_number, 1,
                             (length(p_registration_number)-1));
   l_check_digit   := substr(p_registration_number,
                             length(p_registration_number));
   IF check_numeric_latin(l_nif_value) = '0'
   THEN
       -- Get only the digits, remove '/ ', '.' and  '-'
       l_nif_num := TRANSLATE(l_nif_value, '0123456789/-.', '0123456789') ;
       IF LENGTH(l_nif_num) = 10 -- does not include check digit
       THEN
           l_val_digit:=(11-MOD(((TO_NUMBER(SUBSTR(l_nif_num,10,1))) *2 +
                             (TO_NUMBER(SUBSTR(l_nif_num,9,1)))  *3 +
                             (TO_NUMBER(SUBSTR(l_nif_num,8,1)))  *4 +
                             (TO_NUMBER(SUBSTR(l_nif_num,7,1)))  *5 +
                             (TO_NUMBER(SUBSTR(l_nif_num,6,1)))  *6 +
                             (TO_NUMBER(SUBSTR(l_nif_num,5,1)))  *7 +
                             (TO_NUMBER(SUBSTR(l_nif_num,4,1)))  *2 +
                             (TO_NUMBER(SUBSTR(l_nif_num,3,1)))  *3 +
                             (TO_NUMBER(SUBSTR(l_nif_num,2,1)))  *4 +
                             (TO_NUMBER(SUBSTR(l_nif_num,1,1)))  *5),11));
           IF l_val_digit ='10'
           THEN
              l_val_digit:='9';
           ELSIF l_val_digit = '11'
           THEN
              l_val_digit:='0';
           END IF;
           IF l_val_digit <> l_check_digit
           THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
               THEN
                   g_log_msg := 'Check Algorithm failed for '||
                                 p_registration_number;
                   FND_LOG.STRING(G_LEVEL_STATEMENT,
                                 G_MODULE_NAME || l_api_name, g_log_msg);
               END IF;
           ELSE
               x_return_status := FND_API.G_RET_STS_SUCCESS;
           END IF;
       ELSE
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
           THEN
               g_log_msg := 'Incorrect length for reg number ' ||
                             p_registration_number;
               FND_LOG.STRING(G_LEVEL_STATEMENT,
                             G_MODULE_NAME || l_api_name, g_log_msg);
           END IF;
       END IF; -- Check length
   ELSE
       x_return_status := FND_API.G_RET_STS_ERROR;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
       THEN
           g_log_msg := 'Non numeric characters found in reg num '||
                         p_registration_number;
           FND_LOG.STRING(G_LEVEL_STATEMENT,
                         G_MODULE_NAME || l_api_name, g_log_msg);
       END IF;
   END IF ; -- Numeric Value check
   IF x_return_status = FND_API.G_RET_STS_ERROR
   THEN
       FND_MESSAGE.SET_NAME('XLE', 'XLE_INVALID_REG_NUM_ERR');
       FND_MESSAGE.SET_TOKEN('REG_CODE', p_registration_code);
       FND_MESSAGE.SET_TOKEN('REG_NUM', p_registration_number);
       FND_MSG_PUB.Add;
   END IF;
   FND_MSG_PUB.Count_And_Get
     (p_count         	=>      x_msg_count,
      p_data          	=>      x_msg_data);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
        THEN
            g_log_msg := SQLERRM;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_api_name, g_log_msg);
        END IF;
	x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                 l_api_name);
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data
    	);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
        THEN
            g_log_msg := SQLERRM;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_api_name, g_log_msg);
        END IF;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                 l_api_name);
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count,
                p_data          	=>      x_msg_data
    	);
    WHEN OTHERS THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
        THEN
            g_log_msg := SQLERRM;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_api_name, g_log_msg);
        END IF;
    	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                 l_api_name);
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data
    	);
END do_ar_regnum_validations;
-- Perform Chilean registration number validations
-- Format usually is 99.999.999-X
-- Eg valid number is - 000.000.000.001-9
PROCEDURE do_cl_regnum_validations(
  p_legislative_cat_code      IN VARCHAR2,
  p_required_flag             IN VARCHAR2,
  p_registration_code         IN VARCHAR2,
  p_registration_number       IN VARCHAR2,
  x_return_status             IN OUT NOCOPY VARCHAR2 ,
  x_msg_data                  IN OUT NOCOPY VARCHAR2 ,
  x_msg_count                 IN OUT NOCOPY NUMBER )
IS
l_nif_value          xle_registrations.registration_number%TYPE;
l_check_digit        VARCHAR2(2);
l_var1               xle_registrations.registration_number%TYPE;
l_nif_num            xle_registrations.registration_number%TYPE;
l_val_digit          VARCHAR2(2);
l_api_name           VARCHAR2(50) := 'do_cl_regnum_validations';
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF p_registration_code <> 'RUT'
   THEN
       RETURN;
   END IF;
   -- The last check digit for Chilean Reg Number can be 0-9 and K
   l_nif_value     := substr(p_registration_number, 1,
                             (length(p_registration_number)-1));
   l_check_digit   := substr(p_registration_number,
                             length(p_registration_number));
   IF check_numeric_latin(l_nif_value) = '0'
   THEN
       -- Get only the digits, remove '/ ', '.' and  '-'
       l_nif_num := TRANSLATE(l_nif_value, '0123456789/-.', '0123456789') ;
       -- Number of digits should be <= 12
       IF LENGTH(l_nif_num) <= 12 -- l_nif_num does not include check digit
       THEN
           l_var1:=LPAD(l_nif_num,12,'0');
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
           IF l_val_digit = '10'
           THEN
              l_val_digit := 'K';
           ELSIF l_val_digit = '11'
           THEN
              l_val_digit := '0';
           END IF;
           IF l_val_digit <> l_check_digit
           THEN
               x_return_status := FND_API.G_RET_STS_ERROR;
               IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
               THEN
                   g_log_msg := 'Check Algorithm failed for '||
                                 p_registration_number;
                   FND_LOG.STRING(G_LEVEL_STATEMENT,
                                 G_MODULE_NAME || l_api_name, g_log_msg);
               END IF;
           ELSE
               x_return_status := FND_API.G_RET_STS_SUCCESS;
           END IF;
       ELSE
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
           THEN
               g_log_msg := 'Check length failed for '||
                             p_registration_number;
               FND_LOG.STRING(G_LEVEL_STATEMENT,
                             G_MODULE_NAME || l_api_name, g_log_msg);
           END IF;
       END IF; -- Check length
   ELSE
       x_return_status := FND_API.G_RET_STS_ERROR;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
       THEN
           g_log_msg := 'Non numeric characters found in '||
                         p_registration_number;
           FND_LOG.STRING(G_LEVEL_STATEMENT,
                         G_MODULE_NAME || l_api_name, g_log_msg);
       END IF;
   END IF ; -- Numeric Value check
   IF x_return_status = FND_API.G_RET_STS_ERROR
   THEN
       FND_MESSAGE.SET_NAME('XLE', 'XLE_INVALID_REG_NUM_ERR');
       FND_MESSAGE.SET_TOKEN('REG_CODE', p_registration_code);
       FND_MESSAGE.SET_TOKEN('REG_NUM', p_registration_number);
       FND_MSG_PUB.Add;
   END IF;
   FND_MSG_PUB.Count_And_Get
     (p_count         	=>      x_msg_count,
      p_data          	=>      x_msg_data);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
        THEN
            g_log_msg := SQLERRM;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_api_name, g_log_msg);
        END IF;
	x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                 l_api_name);
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data
    	);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
        THEN
            g_log_msg := SQLERRM;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_api_name, g_log_msg);
        END IF;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                 l_api_name);
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count,
                p_data          	=>      x_msg_data
    	);
    WHEN OTHERS THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
        THEN
            g_log_msg := SQLERRM;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_api_name, g_log_msg);
        END IF;
    	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                 l_api_name);
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data
    	);
END do_cl_regnum_validations;
-- Perform Colombian registration number validations
-- Format usually is 99999999999999-9
-- Eg valid number is - 0000000000001-8
PROCEDURE do_co_regnum_validations(
  p_legislative_cat_code      IN VARCHAR2,
  p_required_flag             IN VARCHAR2,
  p_registration_code         IN VARCHAR2,
  p_registration_number       IN VARCHAR2,
  x_return_status             IN OUT NOCOPY VARCHAR2 ,
  x_msg_data                  IN OUT NOCOPY VARCHAR2 ,
  x_msg_count                 IN OUT NOCOPY NUMBER )
IS
l_nif_value          xle_registrations.registration_number%TYPE;
l_check_digit        VARCHAR2(2);
l_var1               xle_registrations.registration_number%TYPE;
l_nif_num            xle_registrations.registration_number%TYPE;
l_val_digit          VARCHAR2(2);
l_mod_value          NUMBER(2);
l_api_name           VARCHAR2(50) := 'do_co_regnum_validations';
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- The last check digit for Colombian Reg Number can be 0-9
   l_nif_value     := substr(p_registration_number, 1,
                             (length(p_registration_number)-1));
   l_check_digit   := substr(p_registration_number,
                             length(p_registration_number));
   IF check_numeric_latin(l_nif_value) = '0'
   THEN
       -- Get only the digits, remove '/ ', '.' and  '-'
       l_nif_num := TRANSLATE(l_nif_value, '0123456789/-.', '0123456789') ;
       -- Number of digits should be <= 14
       IF LENGTH(l_nif_num) <= 14 -- l_nif_num does not include check digit
       THEN
           l_var1 := LPAD(l_nif_num,15,'0');
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
          IF (l_mod_value IN (1,0))
          THEN
              l_val_digit:=l_mod_value;
          ELSE
              l_val_digit:=11-l_mod_value;
          END IF;
          IF l_check_digit <> l_val_digit
          THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
              THEN
                  g_log_msg := 'Check Algorithm failed for '||
                                 p_registration_number;
                  FND_LOG.STRING(G_LEVEL_STATEMENT,
                                G_MODULE_NAME || l_api_name, g_log_msg);
              END IF;
          ELSE
              x_return_status := FND_API.G_RET_STS_SUCCESS;
          END IF;
       ELSE
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
           THEN
               g_log_msg := 'Check length failed for '||
                             p_registration_number;
               FND_LOG.STRING(G_LEVEL_STATEMENT,
                             G_MODULE_NAME || l_api_name, g_log_msg);
           END IF;
       END IF; -- Check length
   ELSE
       x_return_status := FND_API.G_RET_STS_ERROR;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
       THEN
           g_log_msg := 'Non numeric characters found in ' ||
                        p_registration_number;
           FND_LOG.STRING(G_LEVEL_STATEMENT,
                         G_MODULE_NAME || l_api_name, g_log_msg);
       END IF;
   END IF;
   IF x_return_status = FND_API.G_RET_STS_ERROR
   THEN
       FND_MESSAGE.SET_NAME('XLE', 'XLE_INVALID_REG_NUM_ERR');
       FND_MESSAGE.SET_TOKEN('REG_CODE', p_registration_code);
       FND_MESSAGE.SET_TOKEN('REG_NUM', p_registration_number);
       FND_MSG_PUB.Add;
   END IF;
   FND_MSG_PUB.Count_And_Get
     (p_count         	=>      x_msg_count,
      p_data          	=>      x_msg_data);
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
        THEN
            g_log_msg := SQLERRM;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_api_name, g_log_msg);
        END IF;
	x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                 l_api_name);
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data
    	);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
        THEN
            g_log_msg := SQLERRM;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_api_name, g_log_msg);
        END IF;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                 l_api_name);
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count,
                p_data          	=>      x_msg_data
    	);
    WHEN OTHERS THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
        THEN
            g_log_msg := SQLERRM;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_api_name, g_log_msg);
        END IF;
    	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                 l_api_name);
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data
    	);
END do_co_regnum_validations;
-- Perform Brazilian registration number validations
-- Example format is - 999.999.999/9999-99
-- Eg valid number is - 000.000.001/0001-36
PROCEDURE do_br_regnum_validations(
  p_legislative_cat_code      IN VARCHAR2,
  p_required_flag             IN VARCHAR2,
  p_registration_code         IN VARCHAR2,
  p_registration_number       IN VARCHAR2,
  x_return_status             IN OUT NOCOPY VARCHAR2 ,
  x_msg_data                  IN OUT NOCOPY VARCHAR2 ,
  x_msg_count                 IN OUT NOCOPY NUMBER )
IS
l_trn_branch       VARCHAR2(4);
l_trn_digit        VARCHAR2(2);
l_control_digit_1  NUMBER;
l_control_digit_2  NUMBER;
l_control_digit_XX VARCHAR2(2);
l_trn              xle_registrations.registration_number%TYPE;
l_api_name         VARCHAR2(50) := 'do_br_regnum_validations';
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
IF  p_registration_code IN ('CPF','CNPJ') THEN
   l_trn := TRANSLATE(p_registration_number, '0123456789/-.', '0123456789') ;
   IF  p_registration_code = 'CPF' THEN
      l_trn := lpad(l_trn,11,0);
      l_trn_digit := substr(l_trn,10,2);
   ELSIF  p_registration_code = 'CNPJ' THEN
      l_trn := lpad(l_trn,15,0);
      /* Tax Registration Branch */
      l_trn_branch := substr(l_trn,10,4);
      l_trn_digit := substr(l_trn,14,2);
   END IF;
   IF  check_numeric(l_trn,1,length(l_trn)) <> '0' THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
       THEN
           g_log_msg := 'Failed length check or non numeric ' ||
                        ' characters found ' ||
                         p_registration_number;
           FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_api_name, g_log_msg);
       END IF;
   ELSIF p_registration_code = 'CPF'
   THEN
       /* Validate CPF */
          --Calculate two digit controls of tax registration number CPF type
          l_control_digit_1 := (11 - mod(
                                     (to_number(substr(l_trn,9,1)) * 2   +
                                      to_number(substr(l_trn,8,1)) * 3   +
                                      to_number(substr(l_trn,7,1)) * 4   +
                                      to_number(substr(l_trn,6,1)) * 5   +
                                      to_number(substr(l_trn,5,1)) * 6   +
                                      to_number(substr(l_trn,4,1)) * 7   +
                                      to_number(substr(l_trn,3,1)) * 8   +
                                      to_number(substr(l_trn,2,1)) * 9   +
                                      to_number(substr(l_trn,1,1)) * 10),11));
          IF l_control_digit_1 in ('11','10')
          THEN
              l_control_digit_1 := 0;
          END IF;
          l_control_digit_2 := (11 - mod((l_control_digit_1 * 2   +
                                     to_number(substr(l_trn,9,1)) * 3   +
                                     to_number(substr(l_trn,8,1)) * 4   +
                                     to_number(substr(l_trn,7,1)) * 5   +
                                     to_number(substr(l_trn,6,1)) * 6   +
                                     to_number(substr(l_trn,5,1)) * 7   +
                                     to_number(substr(l_trn,4,1)) * 8   +
                                     to_number(substr(l_trn,3,1)) * 9   +
                                     to_number(substr(l_trn,2,1)) * 10  +
                                     to_number(substr(l_trn,1,1)) * 11),11));
          IF l_control_digit_2 in ('11','10')
          THEN
              l_control_digit_2 := 0;
          END IF;
          l_control_digit_XX := substr(to_char(l_control_digit_1),1,1) ||
          		      substr(to_char(l_control_digit_2),1,1);
          IF l_control_digit_XX <> l_trn_digit
          THEN
              /* Digit controls do not match */
              x_return_status:= FND_API.G_RET_STS_ERROR;
              IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
              THEN
                   g_log_msg := 'Check Algorithm failed for '||
                                  p_registration_number;
                   FND_LOG.STRING(G_LEVEL_STATEMENT,
                                 G_MODULE_NAME || l_api_name, g_log_msg);
              END IF;
          ELSE
              x_return_status:= FND_API.G_RET_STS_SUCCESS;
          END IF;
   ELSIF p_registration_code = 'CNPJ' THEN
	/* Calculate two digit controls of registration number CNPJ type */
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
	    x_return_status:= FND_API.G_RET_STS_ERROR;
            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
            THEN
                g_log_msg := 'Check Algorithm failed for '||
                             p_registration_number;
                FND_LOG.STRING(G_LEVEL_STATEMENT,
                                 G_MODULE_NAME || l_api_name, g_log_msg);
            END IF;
	ELSE
 	    x_return_status:= FND_API.G_RET_STS_SUCCESS;
 	END IF;
   END IF;
   IF x_return_status = FND_API.G_RET_STS_ERROR
   THEN
       FND_MESSAGE.SET_NAME('XLE', 'XLE_INVALID_REG_NUM_ERR');
       FND_MESSAGE.SET_TOKEN('REG_CODE', p_registration_code);
       FND_MESSAGE.SET_TOKEN('REG_NUM', p_registration_number);
       FND_MSG_PUB.Add;
   END IF;
   FND_MSG_PUB.Count_And_Get
     (p_count         	=>      x_msg_count,
      p_data          	=>      x_msg_data);
 END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
        THEN
            g_log_msg := SQLERRM;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_api_name, g_log_msg);
        END IF;
	x_return_status := FND_API.G_RET_STS_ERROR ;
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                 l_api_name);
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data
    	);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
        THEN
            g_log_msg := SQLERRM;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_api_name, g_log_msg);
        END IF;
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                 l_api_name);
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count,
                p_data          	=>      x_msg_data
    	);
    WHEN OTHERS THEN
        IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL)
        THEN
            g_log_msg := SQLERRM;
            FND_LOG.STRING(G_LEVEL_STATEMENT,
                          G_MODULE_NAME || l_api_name, g_log_msg);
        END IF;
    	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        FND_MSG_PUB.Add_Exc_Msg (G_PKG_NAME,
                                 l_api_name);
	FND_MSG_PUB.Count_And_Get
    	(  	p_count         	=>      x_msg_count,
        	p_data          	=>      x_msg_data
    	);
END do_br_regnum_validations;
END XLE_REGISTRATIONS_VAL_PVT;

/
