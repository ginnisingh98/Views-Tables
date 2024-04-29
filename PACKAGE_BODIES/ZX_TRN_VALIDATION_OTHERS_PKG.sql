--------------------------------------------------------
--  DDL for Package Body ZX_TRN_VALIDATION_OTHERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TRN_VALIDATION_OTHERS_PKG" AS
 /* $Header: zxctrndb.pls 120.1 2004/12/02 17:56:06 thwon noship $  */

  -- Logging Infra
  G_CURRENT_RUNTIME_LEVEL      NUMBER;
  G_LEVEL_UNEXPECTED           CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR                CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION            CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT                CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE            CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME                CONSTANT VARCHAR2(50) := 'ZX.PLSQL.ZX_TRN_VALIDATION_NEW_PKG.';
  -- Logging Infra


procedure VALIDATE_TRN (p_country_code      IN VARCHAR2,
                        p_trn_value         IN VARCHAR2,
                        p_trn_type          IN VARCHAR2,
                        p_check_unique_flag IN VARCHAR2,
                        x_return_status     OUT NOCOPY VARCHAR2,
                        x_error_buffer      OUT NOCOPY VARCHAR2)
                        AS

-- Logging Infra
l_procedure_name CONSTANT VARCHAR2(30) := 'VALIDATE_TRN';
l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

                           /**************************/
                           /* SUB-PROCEDURES SECTION */
                           /**************************/

FUNCTION check_numeric(p_check_value IN VARCHAR2,
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
END check_numeric;

procedure fail_uniqueness is
begin

      -- Logging Infra: Statement level
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
        l_log_msg := 'The Tax Registration Number is already used.';
        FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
      -- Logging Infra

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_buffer := 'ZX_REG_NUM_INVALID';

end fail_uniqueness;

procedure fail_check is
begin

      -- Logging Infra: Statement level
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'Failed the validation of the Tax Registration Number.';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
      -- Logging Infra

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_buffer := 'ZX_REG_NUM_INVALID';
end fail_check;

procedure pass_check is
begin

      -- Logging Infra: Statement level
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'The Tax Registration Number is valid.';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
      -- Logging Infra

      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_error_buffer := NULL;
end pass_check;

                           /****************/
                           /* MAIN SECTION */
                           /****************/

BEGIN

-- Logging Infra: Setting up runtime level
G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

-- Logging Infra: Procedure level
IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
  l_log_msg := l_procedure_name||'(+)';
  FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
END IF;
-- Logging Infra

-- Logging Infra: Statement level
IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
  l_log_msg := 'Parameters ';
  l_log_msg :=  l_log_msg||'p_country_code: '||p_country_code;
  l_log_msg :=  l_log_msg||' p_trn_value: '||p_trn_value;
  l_log_msg :=  l_log_msg||' p_trn_type: '||p_trn_type;
  l_log_msg :=  l_log_msg||' p_check_unique_flag: '||p_check_unique_flag;
  FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
END IF;
-- Logging Infra

IF p_check_unique_flag = 'E' THEN

    fail_uniqueness;

ELSE

    /* Add the country specific validation code to here */

    pass_check;

END IF;

END VALIDATE_TRN;

/* ***********    End VALIDATE_TRN       ****************** */

END ZX_TRN_VALIDATION_OTHERS_PKG;

/
