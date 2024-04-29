--------------------------------------------------------
--  DDL for Package Body ZX_TCM_PTP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_TCM_PTP_PKG" AS
/* $Header: zxcptpb.pls 120.41.12010000.2 2008/11/12 12:21:19 spasala ship $ */

  -- Logging Infra
  G_PKG_NAME                   CONSTANT VARCHAR2(30) := 'ZX_TCM_PTP_PKG';
  G_CURRENT_RUNTIME_LEVEL      NUMBER;
  G_LEVEL_UNEXPECTED           CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
  G_LEVEL_ERROR                CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
  G_LEVEL_EXCEPTION            CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
  G_LEVEL_EVENT                CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
  G_LEVEL_PROCEDURE            CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
  G_LEVEL_STATEMENT            CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
  G_MODULE_NAME                CONSTANT VARCHAR2(30) := 'ZX.PLSQL.ZX_TCM_PTP_PKG';

  TYPE l_ptp_id_rec_type IS RECORD(
     le_id                     NUMBER,
     party_type_code           VARCHAR2(240),
     ptp_id                    NUMBER
  );

  TYPE l_ptp_id_tbl_type IS TABLE OF l_ptp_id_rec_type INDEX BY BINARY_INTEGER;
  l_ptp_id_tbl l_ptp_id_tbl_type;

/* ========================================================================
   Procedure: GET_PTP
   Objective: Retrieve the Party Tax Profile for a given Party
              There is an special treatment for Establishments.
              Establishments need to be mapped thru the Legal Associations
              model, following this logic:
              1. First Try to get the information from the Location + LE
              2. Next try Location + Party_ID + LE
              -- Legal Entity has not provided support for case2 yet
              3. Next try OU/Inv Org + LE
              For First Party Legal Entity, since Party Tax Profile
              stores the Party_ID  and the parameter brings the legal
              entity id it is necessary to get the Party_ID from xle
              entity profiles.
              For all other parties the procedure will retrieve the
              PTP Id directly from Party Tax Profiles.
   Assumption: Legal Entity will be always not null
   In Parameters: p_le_id - Legal Entity ID
                  p_party_id - Party ID
                  p_party_type_code - Party Type
                  p_inventory_loc  - Location ID
   OUTPUT Parameters: p_ptp_id - Party Tax Profile ID
                      p_return_status - Success is p_ptp_id is not null
   ======================================================================== */

PROCEDURE GET_PTP(
            p_party_id          IN  NUMBER,
            p_Party_Type_Code   IN  VARCHAR2,
            p_le_id             IN  NUMBER,
            p_inventory_loc     IN  NUMBER,
            p_ptp_id            OUT NOCOPY NUMBER,
            p_return_status     OUT NOCOPY VARCHAR2)
IS
   CURSOR c_get_ptp_id
   IS
      SELECT party_tax_profile_id
        FROM zx_party_tax_profile
       WHERE party_id          = p_party_id
         AND Party_Type_Code   = p_party_type_code;

   CURSOR c_get_ptp_ou (Biz_Entity Number, p_construct VARCHAR2, p_type VARCHAR2, p_context VARCHAR2) IS
     SELECT ptp.party_tax_profile_id ptp_id
       INTO p_ptp_id
       FROM  xle_tax_associations  rel
            ,zx_party_tax_profile ptp
            ,xle_etb_profiles etb
      WHERE rel.legal_construct_id = etb.establishment_id
        AND   etb.party_id   = ptp.party_id
        /* added the below condition for Bug 4878175 */
        AND   ptp.party_type_code = p_party_type_code
        AND   rel.entity_id  =  Biz_Entity
        AND   rel.legal_parent_id   = p_le_id
        AND   rel.LEGAL_CONSTRUCT   = p_construct
        AND   rel.entity_type       = p_type
        AND   rel.context           = p_context
        AND   rel.effective_from <= sysdate
        AND   nvl(rel.effective_to,sysdate+1) >= sysdate;

   CURSOR c_get_ptp_inv_org (Biz_Entity Number, p_construct VARCHAR2, p_type VARCHAR2, p_context VARCHAR2) IS
     SELECT ptp.party_tax_profile_id ptp_id
       INTO p_ptp_id
       FROM  xle_tax_associations  rel
            ,zx_party_tax_profile ptp
            ,xle_etb_profiles etb
      WHERE rel.legal_construct_id = etb.establishment_id
        AND   etb.party_id   = ptp.party_id
       /* added the below condition for Bug 4878175 */
        AND   ptp.party_type_code = p_party_type_code
        AND   rel.entity_id  =  Biz_Entity
        AND   rel.legal_parent_id   = p_le_id
        AND   rel.LEGAL_CONSTRUCT   = p_construct
        AND   rel.entity_type       = p_type
        AND   rel.context           = p_context
        AND   rel.effective_from <= sysdate
        AND   nvl(rel.effective_to,sysdate+1) >= sysdate;

   CURSOR c_get_ptp_stl (p_construct VARCHAR2, p_type VARCHAR2, p_context VARCHAR2) IS
     SELECT ptp.party_tax_profile_id ptp_id
       INTO p_ptp_id
       FROM  xle_tax_associations  rel
            ,zx_party_tax_profile ptp
            ,xle_etb_profiles etb
      WHERE rel.legal_construct_id = etb.establishment_id
        AND   etb.party_id   = ptp.party_id
       /* added the below condition for Bug 4878175 */
        AND   ptp.party_type_code = p_party_type_code
        AND   rel.entity_id  =  p_inventory_loc
        AND   rel.legal_parent_id   = p_le_id
        AND   rel.LEGAL_CONSTRUCT   = p_construct
        AND   rel.entity_type       in (p_type)
        AND   rel.context           = p_context
        AND   rel.effective_from <= sysdate
        AND   nvl(rel.effective_to,sysdate+1) >= sysdate;

   CURSOR c_get_ptp_invloc (p_construct VARCHAR2, p_type VARCHAR2, p_context VARCHAR2) IS
     SELECT ptp.party_tax_profile_id ptp_id
       INTO p_ptp_id
       FROM  xle_tax_associations  rel
            ,zx_party_tax_profile ptp
            ,xle_etb_profiles etb
      WHERE rel.legal_construct_id = etb.establishment_id
        AND   etb.party_id   = ptp.party_id
       /* added the below condition for Bug 4878175 */
        AND   ptp.party_type_code = p_party_type_code
        AND   rel.entity_id  =  p_inventory_loc
        AND   rel.legal_parent_id   = p_le_id
        AND   rel.LEGAL_CONSTRUCT   = p_construct
        AND   rel.entity_type       in (p_type)
        AND   rel.context           = p_context
        AND   rel.effective_from <= sysdate
        AND   nvl(rel.effective_to,sysdate+1) >= sysdate;

   l_Unique     Integer;
   l_tbl_index  binary_integer;

    -- Logging Infra
    l_procedure_name CONSTANT VARCHAR2(30) := '.GET_PTP ';
    l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN
   --------------------------------------------------------------------------------------
    -- Logging Infra: Setting up runtime level
    G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    -- Logging Infra: Statement level
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := l_procedure_name||' (+) ';
      l_log_msg := l_log_msg ||'
                     Parameters '||
                   ' p_party_id: '||to_char(p_party_id)||
                   ' p_Party_Type_Code: '||p_Party_Type_Code||
                   ' p_le_id: '||to_char(p_le_id)||
                   ' p_inventory_loc: '||to_char(p_inventory_loc)||' ';
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;
    -- Logging Infra: Statement level
   --------------------------------------------------------------------------------------

    -- Checking parameters are not null
    IF (p_party_type_code is null) THEN
        p_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('ZX','ZX_GENERIC_MESSAGE');
        RETURN;
    END IF; -- Null parameters

   -- Initialize P_Ptp_ID
   p_ptp_id := null;

   IF P_Party_Type_Code = 'LEGAL_ESTABLISHMENT' Then -- If0

     -- First Try to get the information from the Location + LE
     -- Location id is comming in the parameter p_inventory_loc
     IF p_inventory_loc IS NOT NULL THEN --If1
       l_unique := 0;
       For etb in c_get_ptp_stl ('ESTABLISHMENT', 'SHIP_TO_LOCATION', 'TAX_CALCULATION')LOOP
           p_ptp_id := etb.ptp_id;
           l_unique := l_unique + 1;
       End Loop;

       IF (p_ptp_id IS NOT NULL) THEN
        IF l_unique = 1 THEN
          ----------------------------------------------------------------------------------
          -- Logging Infra: Statement level
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              l_log_msg := 'Getting PTP from Location and LE.PTP_ID: '||to_char(p_ptp_id)||' ';
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;
          -- Logging Infra: Statement level
          ----------------------------------------------------------------------------------

          p_return_status := FND_API.G_RET_STS_SUCCESS;
          RETURN;
         ELSE
           /*Reinitialize p_ptp_id */
           p_ptp_id := NULL;
         END IF; -- l_unique check
       END IF; -- p_ptp_id IS NOT NULL
     END IF; --If1
     -- Next Try to get the information from the InvLoc + LE
     -- Location id is comming in the parameter p_inventory_loc
     IF p_inventory_loc IS NOT NULL THEN --If2
       l_unique := 0;
       For etb in c_get_ptp_invloc ('ESTABLISHMENT', 'INVENTORY_LOCATION', 'TAX_CALCULATION') LOOP
           p_ptp_id := etb.ptp_id;
           l_unique := l_unique + 1;
       End Loop;

       IF (p_ptp_id IS NOT NULL) THEN
        IF l_unique = 1 THEN
       ---------------------------------------------------------------------------------
       -- Logging Infra: Statement level
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              l_log_msg := 'Getting PTP from Location and LE.PTP_ID: '||to_char(p_ptp_id)||' ';
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
          END IF;
          -- Logging Infra: Statement level
       ---------------------------------------------------------------------------------

          p_return_status := FND_API.G_RET_STS_SUCCESS;
          RETURN;
         ELSE
           /*Reinitialize p_ptp_id */
           p_ptp_id := NULL;
         END IF; -- l_unique check
       END IF; -- p_ptp_id IS NOT NULL
     END IF; --If2
      --
      -- Next try to get the establishment from the LE + INV Org
     IF (p_party_id is not null) THEN -- If3
         l_unique := 0;
         For etb in c_get_ptp_inv_org (p_party_id, 'ESTABLISHMENT', 'INVENTORY_ORGANIZATION', 'TAX_CALCULATION') LOOP
             p_ptp_id := etb.ptp_id;
             l_unique := l_unique + 1;
         End Loop;

         IF (p_ptp_id IS NOT NULL) THEN
           IF l_unique = 1 THEN
            ---------------------------------------------------------------------------------
            -- Logging Infra: Statement level
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                l_log_msg := 'Getting PTP from Inv Organization and LE.PTP_ID: '||to_char(p_ptp_id)||' ';
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
            END IF;
            -- Logging Infra: Statement level
            ---------------------------------------------------------------------------------

            p_return_status := FND_API.G_RET_STS_SUCCESS;
            RETURN;
           ELSE
              /*Reinitialize p_ptp_id */
              p_ptp_id := NULL;
           END IF; -- l_unique check
         END IF; -- p_ptp_id IS NOT NULL
     END IF; -- If3

     -- Next try to get the establishment from the LE + OU
     IF (p_party_id is not null) THEN -- If4
         l_unique := 0;
         For etb in c_get_ptp_ou (p_party_id, 'ESTABLISHMENT', 'OPERATING_UNIT', 'TAX_CALCULATION') LOOP
             p_ptp_id := etb.ptp_id;
             l_unique := l_unique + 1;
         End Loop;

         IF (p_ptp_id IS NOT NULL) THEN
           IF(l_unique = 1) THEN
            ---------------------------------------------------------------------------------
            -- Logging Infra: Statement level
            IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
                l_log_msg := 'Getting PTP from Operating Unit and LE.PTP_ID: '||to_char(p_ptp_id)||' ';
                FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
            END IF;
            -- Logging Infra: Statement level
            ---------------------------------------------------------------------------------

            p_return_status := FND_API.G_RET_STS_SUCCESS;
            RETURN;
           ELSE
            /*Reinitialize p_ptp_id */
              p_ptp_id := NULL;
           END IF; -- l_unique check
         END IF; -- p_ptp_id IS NOT NULL
      END IF; -- If4

      IF (p_ptp_id IS NULL) THEN -- If5
        ---------------------------------------------------------------------------------
        -- Logging Infra: Statement level
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'There is not an establishment associated. Returning without error.';
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
        END IF;
        ---------------------------------------------------------------------------------
        p_return_status := FND_API.G_RET_STS_SUCCESS;
      END IF; -- If5
   -- END  P_Party_Type_Code = 'LEGAL_ESTABLISHMENT'

   -- Checking First Party
   ELSIF P_Party_Type_Code = 'FIRST_PARTY' Then
     -- Getting first party PTP
     SELECT ptp.party_tax_profile_id
       INTO p_ptp_id
       FROM zx_party_tax_profile ptp, xle_entity_profiles xle
      WHERE xle.legal_entity_id = p_le_id
        AND ptp.party_id        = xle.party_id
        AND ptp.Party_Type_Code = p_party_type_code;

      -- Set Status Parameter to Success
      p_return_status := FND_API.G_RET_STS_SUCCESS;

       ---------------------------------------------------------------------------------
       -- Logging Infra: Statement level
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'Getting PTP First Party: '||to_char(p_ptp_id)||' ';
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;
       -- Logging Infra: Statement level
       ---------------------------------------------------------------------------------

   -- Other Party Types
   ELSE

      GET_PARTY_TAX_PROF_INFO(
            P_PARTY_ID 		=> p_party_id,
            P_PARTY_TYPE_CODE   => p_party_type_code,
            X_TBL_INDEX         => l_tbl_index,
            X_RETURN_STATUS  	=> p_return_status);

     IF l_tbl_index is NULL THEN

        -- Bug 4939819 - Return without error if party tax profile setup is not found for
        --               party of type 'THIRD_PARTY' as it is not mandatory to have PTP setup
        --               for THIRD_PARTY party type. Return ptp id as NULL.

        IF (P_Party_Type_Code = 'THIRD_PARTY') OR (P_Party_Type_Code = 'THIRD_PARTY_SITE') Then
          ---------------------------------------------------------------------------------
           -- Logging Infra: Statement level
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'Get PTP is not able to return a row for the given party and party type code.
                          Returning with success. Party_id: '
                         ||p_party_type_code||', '||to_char(p_party_id)||' ';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_procedure_name, l_log_msg);
          END IF;
          ---------------------------------------------------------------------------------
           p_ptp_id := NULL;
           p_return_status := FND_API.G_RET_STS_SUCCESS;
        ELSE
          ---------------------------------------------------------------------------------
           -- Logging Infra: Statement level
          IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
            l_log_msg := 'Get PTP is not able to return a row for the given party and party type code.
                          Returning with error. Party_id: '
                         ||p_party_type_code||', '||to_char(p_party_id)||' ';
            FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_procedure_name, l_log_msg);
          END IF;
          ---------------------------------------------------------------------------------
        -- Bug 4512462
           FND_MESSAGE.SET_NAME('ZX', 'ZX_PARTY_NOT_EXISTS');
           p_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
        --close c_get_ptp_id;
     ELSE

        p_ptp_id := ZX_GLOBAL_STRUCTURES_PKG.g_party_tax_prof_id_info_tbl(l_tbl_index).party_tax_profile_id;

        -- Logging Infra: Statement level
        ---------------------------------------------------------------------------------
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'Getting PTP For Other Party Types: '||p_party_type_code||', '||to_char(p_ptp_id)||' ';
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
        END IF;
        -- Logging Infra: Statement level
        ---------------------------------------------------------------------------------
          p_return_status := FND_API.G_RET_STS_SUCCESS;
          --close c_get_ptp_id;
       END IF;
     END IF;  -- End IF for Party Types
   ---------------------------------------------------------------------------------
    -- Logging Infra: Procedure level
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
     l_log_msg := l_procedure_name||' (-) ';
     FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.END ', l_log_msg);
   END IF;
   ---------------------------------------------------------------------------------

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        -- Logging Infra: Statement level
        IF (G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg := 'Get PTP is not able to return a row for the given party. Returning with error. Party_id: '
                       ||p_party_type_code||', '||to_char(p_party_id)||' ';
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME||l_procedure_name, l_log_msg);
        END IF;
        -- Bug 4512462
        FND_MESSAGE.SET_NAME('ZX', 'ZX_PARTY_NOT_EXISTS');
        p_return_status := FND_API.G_RET_STS_ERROR;
   WHEN INVALID_CURSOR THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name ('ZX','ZX_GENERIC_MESSAGE');
      FND_MESSAGE.Set_Token('GENERIC_TEXT', SQLERRM);
   WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name ('ZX','ZX_GENERIC_MESSAGE');
      FND_MESSAGE.Set_Token('GENERIC_TEXT', SQLERRM);

       -- Logging Infra: Statement level
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'Error Message: '||SQLERRM;
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;
       -- Logging Infra: Statement level

END GET_PTP;

/* ======================================================================
   Procedure: GET_PTP_HQ
   Objective: Retrieve the Party Tax Profile for the HQ Establishment
              of a given Legal Entity.
   Assumption: Any Legal Entity will have only one HQ Establishment
   In Parameters: p_le_id - Legal Entity ID
   OUTPUT Parameters: p_ptp_id - Party Tax Profile ID
                      p_return_status - Success is p_ptp_id is not null
   ====================================================================== */
PROCEDURE GET_PTP_HQ(
            p_le_id             IN  xle_entity_profiles.legal_entity_id%TYPE,
            p_ptp_id            OUT NOCOPY zx_party_tax_profile.party_tax_profile_id%TYPE,
            p_return_status     OUT NOCOPY VARCHAR2)
IS
   CURSOR c_get_ptp_id_hq
   IS
      SELECT party_tax_profile_id
        FROM zx_party_tax_profile ptp,
             xle_etb_profiles xlep
       WHERE ptp.party_id         = xlep.party_id
         AND ptp.party_type_code  = 'LEGAL_ESTABLISHMENT'
         AND xlep.legal_entity_id = p_le_id
         AND xlep.main_establishment_flag = 'Y';

    -- Logging Infra
    l_procedure_name CONSTANT VARCHAR2(30) := '.GET_PTP_HQ';
    l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

    l_ptp_id_indx  BINARY_INTEGER;

BEGIN
    ---------------------------------------------------------------------------------
    -- Logging Infra: Setting up runtime level
    G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    -- Logging Infra: Statement level
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := l_procedure_name||'(+)';
      l_log_msg := l_log_msg||'
                    Parameters: ';
      l_log_msg :=  l_log_msg||'p_le_id: '||to_char(p_le_id);
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;
    -- Logging Infra: Statement level
    ---------------------------------------------------------------------------------
    l_ptp_id_indx := dbms_utility.get_hash_value('LEGAL_ESTABLISHMENT'||to_char(p_le_id), 1, 8192);

     IF l_ptp_id_tbl.EXISTS(l_ptp_id_indx) AND l_ptp_id_tbl(l_ptp_id_indx).le_id = p_le_id
        AND l_ptp_id_tbl(l_ptp_id_indx).party_type_code = 'LEGAL_ESTABLISHMENT' THEN
          p_ptp_id := l_ptp_id_tbl(l_ptp_id_indx).ptp_id;
     ELSE
       For myrec IN c_get_ptp_id_hq Loop
           p_ptp_id := myrec.party_tax_profile_id;
       End Loop;

       l_ptp_id_tbl(l_ptp_id_indx).le_id := p_le_id;
       l_ptp_id_tbl(l_ptp_id_indx).party_type_code := 'LEGAL_ESTABLISHMENT';
       l_ptp_id_tbl(l_ptp_id_indx).ptp_id := p_ptp_id;
     END IF;

       IF P_PTP_ID is null Then
        p_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('ZX', 'ZX_PARTY_NOT_EXISTS');
       ELSE
         p_return_status := FND_API.G_RET_STS_SUCCESS;
       END IF;

       ---------------------------------------------------------------------------------
       -- Logging Infra: Statement level
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
           l_log_msg :=  'PTP for HQ Establlishment: '||to_char(p_ptp_id);
           l_log_msg :=  l_log_msg||'
           '||l_procedure_name||'(-)';
           FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;
       -- Logging Infra: Statement level
      ---------------------------------------------------------------------------------
EXCEPTION
   WHEN INVALID_CURSOR THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name ('ZX','ZX_GENERIC_MESSAGE');
      FND_MESSAGE.Set_Token('GENERIC_TEXT', SQLERRM);
   WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name ('ZX','ZX_GENERIC_MESSAGE');
      FND_MESSAGE.Set_Token('GENERIC_TEXT', SQLERRM);

       -- Logging Infra: Statement level
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'Error Message: '||SQLERRM;
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;
       -- Logging Infra: Statement level

END GET_PTP_HQ;



PROCEDURE GET_TAX_SUBSCRIBER(
            p_le_id             IN  NUMBER,
            p_org_id            IN  NUMBER,
            p_ptp_id            OUT NOCOPY NUMBER,
            p_return_status     OUT NOCOPY VARCHAR2)
IS
   l_chk_le_flg           VARCHAR2(1);

   CURSOR c_get_ptp IS
   SELECT Use_Le_As_Subscriber_Flag, party_tax_profile_id
   FROM zx_party_tax_profile
   WHERE party_id = p_org_id
   AND Party_Type_Code = 'OU';

   CURSOR c_ptp_of_le IS
   SELECT ptp.party_tax_profile_id
   FROM   zx_party_tax_profile ptp,
          xle_entity_profiles xle
   WHERE  xle.legal_entity_id = p_le_id
   AND    ptp.party_id        = xle.party_id
   AND    ptp.Party_Type_Code = 'FIRST_PARTY';

   -- Logging Infra
   l_procedure_name CONSTANT VARCHAR2(30) := '.GET_TAX_SUBSCRIBER';
   l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
   l_tbl_index BINARY_INTEGER;

BEGIN
    ---------------------------------------------------------------------------------
    -- Logging Infra: Setting up runtime level
    G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    -- Logging Infra: Statement level
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := l_procedure_name||'(+)';
      l_log_msg := l_log_msg|| '
                   Parameters:
                   p_le_id: '||to_char(p_le_id)||' '
                   ||'p_org_id: '||to_char(p_org_id);
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;
    -- Logging Infra: Statement level
    ---------------------------------------------------------------------------------

  --
  -- Always LE_ID parameter can not be NULL
  --
  IF p_le_id IS NULL THEN
     p_ptp_id := NULL;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('ZX', 'ZX_PARTY_NOT_EXISTS');
  --
  -- Case: Get parameter LE_ID (Return PTP ID of LE)
  --
  ELSIF p_le_id IS NOT NULL AND p_org_id IS NULL THEN

     Open c_ptp_of_le;
     Fetch c_ptp_of_le into p_ptp_id;

     IF c_ptp_of_le%NOTFOUND THEN
       p_ptp_id := NULL;
       p_return_status := FND_API.G_RET_STS_ERROR;
       FND_MESSAGE.SET_NAME('ZX', 'ZX_PARTY_NOT_EXISTS');
       close c_ptp_of_le;
     ELSE
       p_return_status := FND_API.G_RET_STS_SUCCESS;
     END IF;

  --
  -- Case: Both parameter P_LE_ID and P_ORG_ID are not NULL
  --
  ELSIF p_le_id IS NOT NULL AND p_org_id IS NOT NULL THEN

    --
    -- Check the existence of 'Use LE as Subscriber Flag'
    --

    --Open c_get_ptp;
    --fetch c_get_ptp into l_chk_le_flg, p_ptp_id;

    GET_PARTY_TAX_PROF_INFO(
     P_PARTY_ID         => p_org_id,
     P_PARTY_TYPE_CODE 	=> 'OU',
     X_TBL_INDEX        => l_tbl_index,
     X_RETURN_STATUS    => p_return_status);

    IF l_tbl_index is NOT NULL then
          p_ptp_id  := ZX_GLOBAL_STRUCTURES_PKG.g_party_tax_prof_id_info_tbl(l_tbl_index).party_tax_profile_id;

          IF NOT ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL.exists(p_ptp_id) THEN

             GET_PARTY_TAX_PROF_INFO(
                        P_PARTY_TAX_PROFILE_ID => p_ptp_id,
                        X_TBL_INDEX        => l_tbl_index,
                        X_RETURN_STATUS    => p_return_status);
          END IF;
          l_chk_le_flg := ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(p_ptp_id).use_le_as_subscriber_flag;

    END IF;

    IF l_tbl_index is NOT NULL THEN
       --
       -- When 'Use LE as Susriber Flag' is 'N' OR NULL
       --

       IF l_chk_le_flg = 'N' OR l_chk_le_flg IS NULL THEN

          IF p_ptp_id IS NOT NULL THEN
            p_return_status := FND_API.G_RET_STS_SUCCESS;
            --close c_get_ptp;
          ELSE
            p_ptp_id := NULL;
            p_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.SET_NAME('ZX', 'ZX_PARTY_NOT_EXISTS');
            --close c_get_ptp;
          END IF;

      --
      -- Return PTP_ID of LE when 'Use LE as Susriber Flag'  is 'Y'
      --
       ELSIF l_chk_le_flg = 'Y' THEN

           Open c_ptp_of_le;
           Fetch c_ptp_of_le into p_ptp_id;

           IF c_ptp_of_le%NOTFOUND THEN
              p_ptp_id := NULL;
              p_return_status := FND_API.G_RET_STS_ERROR;
              FND_MESSAGE.SET_NAME('ZX', 'ZX_PARTY_NOT_EXISTS');
              close c_ptp_of_le;
           ELSE
              p_return_status := FND_API.G_RET_STS_SUCCESS;
              close c_ptp_of_le;
           END IF;

           ---------------------------------------------------------------------------------
           -- Logging Infra: Statement level
           IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
              l_log_msg := 'Getting PTP from LE_ID: '||to_char(p_ptp_id)||' ';
              l_log_msg := l_log_msg||' l_chk_le_flg = Y';
              FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
           END IF;
           -- Logging Infra: Statement level
           ---------------------------------------------------------------------------------

       ELSE
          p_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.SET_NAME('ZX', 'ZX_PARTY_NOT_EXISTS');
       END IF;

   ELSE
     Open c_ptp_of_le;
     Fetch c_ptp_of_le into p_ptp_id;

     IF c_ptp_of_le%NOTFOUND THEN
        p_ptp_id := NULL;
        p_return_status := FND_API.G_RET_STS_ERROR;
        FND_MESSAGE.SET_NAME('ZX', 'ZX_PARTY_NOT_EXISTS');
        close c_ptp_of_le;
     ELSE
        p_return_status := FND_API.G_RET_STS_SUCCESS;
        close c_ptp_of_le;
     END IF;

       ---------------------------------------------------------------------------------
       -- Logging Infra: Statement level
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'Getting PTP from LE_ID: '||to_char(p_ptp_id)||' ';
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;
       -- Logging Infra: Statement level
       ---------------------------------------------------------------------------------

   END IF;
  ELSE
     p_ptp_id := NULL;
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('ZX', 'ZX_PARTY_NOT_EXISTS');
  END IF;
  ---------------------------------------------------------------------------------
  -- Logging Infra: Procedure level
  IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := l_procedure_name||'(-)';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
  END IF;
  ---------------------------------------------------------------------------------

EXCEPTION
   WHEN INVALID_CURSOR THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME ('ZX','ZX_GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', SQLERRM);
   WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME ('ZX','ZX_GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', SQLERRM);

      -- Logging Infra: Statement level
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'Error Message: '||SQLERRM;
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
      -- Logging Infra: Statement level

END GET_TAX_SUBSCRIBER;

/* ======================================================================
   Procedure: GET_LOCATION_ID
   Objective: Retrieve the location_id associated to a given
              organization.
   Assumption:Not all Organizations have a location attached.
   In Parameters: p_org_id - organization ID
   OUTPUT Parameters: p_location_id
                      p_return_status - Success is p_ptp_id is not null
   ====================================================================== */
PROCEDURE GET_LOCATION_ID(
            p_org_id            IN  NUMBER,
            p_location_id       OUT NOCOPY NUMBER,
            p_return_status     OUT NOCOPY VARCHAR2)
IS
   CURSOR c_get_location_id IS
   SELECT location_id
   FROM   hr_all_organization_units
   WHERE  organization_id = p_org_id;

   -- Logging Infra
   l_procedure_name CONSTANT VARCHAR2(30) := '.GET_LOCATION_ID';
   l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN
  --
  -- Get the location_id of internal_organization_id
  --
    --------------------------------------------------------------------------------
    -- Logging Infra: Setting up runtime level
    G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    -- Logging Infra: Statement level
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := l_procedure_name||'(+)';
      l_log_msg := l_log_msg||
                   'Parameters: ';
      l_log_msg :=  l_log_msg||'p_org_id: '||to_char(p_org_id);
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;
    -- Logging Infra: Statement level
    --------------------------------------------------------------------------------

   open c_get_location_id;
   fetch c_get_location_id into p_location_id;

   IF c_get_location_id%NOTFOUND THEN
      --------------------------------------------------------------------------------
      -- Logging Infra: Statement level
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'No data found - The organization has not been defined ';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
      -- Logging Infra: Statement level
      --------------------------------------------------------------------------------
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('ZX', 'ZX_LOCATION_NOT_EXIST');
     close c_get_location_id;
   ELSIF p_location_id IS NULL THEN
      --------------------------------------------------------------------------------
      -- Logging Infra: Statement level
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'There is not location associated to the Organization ID ';
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
      -- Logging Infra: Statement level
      --------------------------------------------------------------------------------
     p_return_status := FND_API.G_RET_STS_ERROR;
     FND_MESSAGE.SET_NAME('ZX', 'ZX_LOCATION_NOT_EXIST');
     close c_get_location_id;
   ELSE
     p_return_status := FND_API.G_RET_STS_SUCCESS;
     close c_get_location_id;

      --------------------------------------------------------------------------------
       -- Logging Infra: Statement level
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'Getting Location Id for the OU: '||to_char(p_location_id);
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;
       -- Logging Infra: Statement level
      --------------------------------------------------------------------------------

   END IF;
    --------------------------------------------------------------------------------
    -- Logging Infra: Procedure level
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL ) THEN
      l_log_msg := l_procedure_name||'(-)';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
    END IF;
    --------------------------------------------------------------------------------

EXCEPTION
   WHEN INVALID_CURSOR THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME ('ZX','ZX_GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', SQLERRM);
   WHEN OTHERS THEN
      p_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME ('ZX','ZX_GENERIC_MESSAGE');
      FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', SQLERRM);

      -----------------------------------------------------------------------------
       -- Logging Infra: Statement level
       IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
          l_log_msg := 'Error Message: '||SQLERRM;
          FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
       END IF;
       -- Logging Infra: Statement level
      -----------------------------------------------------------------------------

END GET_LOCATION_ID;

/* =============================================================================
   Procedure: CHECK_TAX_REGISTRATIONS
   Objective: Retrieve the Tax Registrations for a given Legal Registrations ID
   Assumption: Check the existence of the tax registration which is from legal registration.
   In Parameters:    p_api_version   - Standard required IN parameter.
                     p_le_reg_id - Legal Registrations ID
   ============================================================================= */

Procedure CHECK_TAX_REGISTRATIONS(
                   p_api_version       IN  NUMBER,
                   p_le_reg_id         IN  NUMBER,
                   x_return_status     OUT NOCOPY  VARCHAR2)
IS

   l_api_name          CONSTANT  VARCHAR2(30) := 'CHECK_TAX_REGISTRATIONS';
   l_api_version       CONSTANT  NUMBER := 1.0;

   l_tax_registration_id    ZX_REGISTRATIONS.REGISTRATION_ID%TYPE;

   -- Logging Infra
   l_procedure_name CONSTANT VARCHAR2(30) := '.CHECK_TAX_REGISTRATIONS';
   l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

   CURSOR c_get_reg_id
   IS
      SELECT registration_id
        FROM zx_registrations
       WHERE legal_registration_id = p_le_reg_id;

BEGIN

    -- Logging Infra: Setting up runtime level
    G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

    -- Logging Infra: Statement level
    IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := l_procedure_name||'(+)';
      l_log_msg := l_log_msg||
                    'Parameters: ';
      l_log_msg :=  l_log_msg||'p_le_reg_id: '||to_char(p_le_reg_id);
      FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
    END IF;
    -- Logging Infra: Statement level


    /*--------------------------------------------------+
    |   Standard start of API savepoint                 |
    +--------------------------------------------------*/
    SAVEPOINT Check_Tax_Registrations_PVT;

    /*--------------------------------------------------+
    |   Standard call to check for call compatibility   |
    +--------------------------------------------------*/

    IF NOT FND_API.Compatible_API_Call(
                                       l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       )  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /*-----------------------------------------+
    |   Initialize return status to SUCCESS   |
    +-----------------------------------------*/

     x_return_status := FND_API.G_RET_STS_SUCCESS;


       Open c_get_reg_id;
       Fetch c_get_reg_id into l_tax_registration_id;

       IF c_get_reg_id%NOTFOUND THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('ZX','ZX_GENERIC_MESSAGE');
         close c_get_reg_id;

         -- Logging Infra: Statement level
         IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
             l_log_msg :=  'There is no tax registrations which is from legal registrations.';
             FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
         END IF;
         -- Logging Infra: Statement level

       ELSE
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         close c_get_reg_id;
       END IF;

    -- Logging Infra: Procedure level
    IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
       l_log_msg := l_procedure_name||'-)';
       FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
    END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Check_Tax_Registrations_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR ;

       IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
       END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Check_Tax_Registrations_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,'');
      END IF;

   WHEN INVALID_CURSOR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('ZX','ZX_GENERIC_MESSAGE');

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('ZX','ZX_GENERIC_MESSAGE');

      -- Logging Infra: Statement level
      IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
         l_log_msg := 'Error Message: '||SQLERRM;
         FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
      END IF;
      -- Logging Infra: Statement level

END CHECK_TAX_REGISTRATIONS;

/* =============================================================================
   Procedure: SYNC_TAX_REGISTRATIONS
   Objective: Syncronize Tax Registrations after update the Legal Registrations.
   Assumption:
      Case 1: Legal Registrations number and validation digit have updated.
              Update existing tax registrations with end date and create new row.
      Case 2: Legal Registrations has updated with end date and created new one.
              Update existing tax registrations with end date and create new row.
   In Parameters: p_api_version   : Required standard IN parameter
                  p_le_old_reg_id : Prior Legal Registrations ID = Legal Registrations
                                    ID in Tax Registrations.
                  p_le_old_date   : NULL (Case 1)
                                    NOT NULL (Case 2)
                  p_le_new_erg_id : NULL (Case 1)
                                    NOT NULL (Case 2)
                  p_le_new_reg_num: New Legal Registration Number

   ============================================================================= */

Procedure SYNC_TAX_REGISTRATIONS(
                   p_api_version       IN  NUMBER,
                   p_le_old_reg_id     IN  NUMBER,
                   p_le_old_end_date   IN  DATE,
                   p_le_new_reg_id     IN  NUMBER,
                   p_le_new_reg_num    IN  VARCHAR2,
                   x_return_status     OUT NOCOPY  VARCHAR2)
IS

   l_api_name          CONSTANT  VARCHAR2(30) := 'SYNC_TAX_REGISTRATIONS';
   l_api_version       CONSTANT  NUMBER := 1.0;

   l_tax_registrations_rec             ZX_REGISTRATIONS%ROWTYPE;

   -- Find a tax registration which is from Legal Registrations

   CURSOR c_find_reg_num
   IS
      SELECT
        registration_id,
        registration_type_code,
        registration_number,
        validation_rule,
        tax_authority_id,
        rep_tax_authority_id,
        coll_Tax_authority_id,
        rounding_rule_code,
        tax_jurisdiction_code,
        self_assess_flag,
        registration_status_code,
        registration_source_code,
        registration_reason_code,
        party_tax_profile_id,
        tax,
        tax_regime_code,
        inclusive_tax_flag,
        has_tax_exemptions_flag,
        effective_from,
        effective_to,
        rep_party_tax_name,
        legal_registration_id,
        default_registration_flag,
        bank_id,
        bank_branch_id,
        bank_account_num,
        legal_location_id,
        record_type_code,
        request_id,
        program_application_id,
        program_id,
        program_login_id,
        account_id,
        account_site_id,
        --site_use_id,
        --geo_type_classification_code,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9 ,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        attribute_category
      FROM zx_registrations
      WHERE legal_registration_id = p_le_old_reg_id;

   -- Logging Infra
   l_procedure_name CONSTANT VARCHAR2(30) := 'SYNC_TAX_REGISTRATIONS';
   l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

   -- Logging Infra: Setting up runtime level
   G_CURRENT_RUNTIME_LEVEL := FND_LOG.G_CURRENT_RUNTIME_LEVEL;

   -- Logging Infra: Statement level
   IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
     l_log_msg := l_procedure_name||'(+)';
     l_log_msg := l_log_msg||
                  ' Parameters '||
                  'p_le_old_reg_id: '||to_char(p_le_old_reg_id)||
                  'p_le_new_reg_id: '||to_char(p_le_new_reg_id)||
                  'p_le_new_reg_num: '||p_le_new_reg_num;
     FND_LOG.STRING(G_LEVEL_STATEMENT,G_MODULE_NAME || l_procedure_name, l_log_msg);
   END IF;
   -- Logging Infra: Statement level

   /*--------------------------------------------------+
    |   Standard start of API savepoint                 |
    +--------------------------------------------------*/
    SAVEPOINT Sync_Tax_Registrations_PVT;

    /*--------------------------------------------------+
    |   Standard call to check for call compatibility   |
    +--------------------------------------------------*/

    IF NOT FND_API.Compatible_API_Call(
                                       l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       )  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    /*-----------------------------------------+
    |   Initialize return status to SUCCESS   |
    +-----------------------------------------*/

     x_return_status := FND_API.G_RET_STS_SUCCESS;


   OPEN c_find_reg_num;
   LOOP

   FETCH c_find_reg_num INTO
             l_tax_registrations_rec.registration_id,
             l_tax_registrations_rec.registration_type_code,
             l_tax_registrations_rec.registration_number,
             l_tax_registrations_rec.validation_rule,
             l_tax_registrations_rec.tax_authority_id,
             l_tax_registrations_rec.rep_tax_authority_id,
             l_tax_registrations_rec.coll_Tax_authority_id,
             l_tax_registrations_rec.rounding_rule_code,
             l_tax_registrations_rec.tax_jurisdiction_code,
             l_tax_registrations_rec.self_assess_flag,
             l_tax_registrations_rec.registration_status_code,
             l_tax_registrations_rec.registration_source_code,
             l_tax_registrations_rec.registration_reason_code,
             l_tax_registrations_rec.party_tax_profile_id,
             l_tax_registrations_rec.tax,
             l_tax_registrations_rec.tax_regime_code,
             l_tax_registrations_rec.inclusive_tax_flag,
             l_tax_registrations_rec.has_tax_exemptions_flag,
             l_tax_registrations_rec.effective_from,
             l_tax_registrations_rec.effective_to,
             l_tax_registrations_rec.rep_party_tax_name,
             l_tax_registrations_rec.legal_registration_id,
             l_tax_registrations_rec.default_registration_flag,
             l_tax_registrations_rec.bank_id,
             l_tax_registrations_rec.bank_branch_id,
             l_tax_registrations_rec.bank_account_num,
             l_tax_registrations_rec.legal_location_id,
             l_tax_registrations_rec.record_type_code,
             l_tax_registrations_rec.request_id,
             l_tax_registrations_rec.program_application_id,
             l_tax_registrations_rec.program_id,
             l_tax_registrations_rec.program_login_id,
             l_tax_registrations_rec.account_id,
             l_tax_registrations_rec.account_site_id,
             --l_tax_registrations_rec.site_use_id,
             --l_tax_registrations_rec.geo_type_classification_code,
             l_tax_registrations_rec.attribute1,
             l_tax_registrations_rec.attribute2,
             l_tax_registrations_rec.attribute3,
             l_tax_registrations_rec.attribute4,
             l_tax_registrations_rec.attribute5,
             l_tax_registrations_rec.attribute6,
             l_tax_registrations_rec.attribute7,
             l_tax_registrations_rec.attribute8,
             l_tax_registrations_rec.attribute9 ,
             l_tax_registrations_rec.attribute10,
             l_tax_registrations_rec.attribute11,
             l_tax_registrations_rec.attribute12,
             l_tax_registrations_rec.attribute13,
             l_tax_registrations_rec.attribute14,
             l_tax_registrations_rec.attribute15,
             l_tax_registrations_rec.attribute_category;

  EXIT WHEN c_find_reg_num%NOTFOUND;

  IF c_find_reg_num%ROWCOUNT = 0 Then
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('ZX','ZX_GENERIC_MESSAGE');

      EXIT;
      CLOSE c_find_reg_num;

  ELSE
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF p_le_new_reg_id IS NULL and p_le_old_end_date IS NULL THEN
       update ZX_REGISTRATIONS set
              effective_to = SYSDATE
       where registration_id = l_tax_registrations_rec.registration_id;

       insert into ZX_REGISTRATIONS (
             registration_id,
             registration_type_code,
             registration_number,
             validation_rule,
             tax_authority_id,
             rep_tax_authority_id,
             coll_Tax_authority_id,
             rounding_rule_code,
             tax_jurisdiction_code,
             self_assess_flag,
             registration_status_code,
             registration_source_code,
             registration_reason_code,
             party_tax_profile_id,
             tax,
             tax_regime_code,
             inclusive_tax_flag,
             has_tax_exemptions_flag,
             effective_from,
             effective_to,
             rep_party_tax_name,
             legal_registration_id,
             default_registration_flag,
             bank_id,
             bank_branch_id,
             bank_account_num,
             legal_location_id,
             record_type_code,
             request_id,
             program_application_id,
             program_id,
             program_login_id,
             account_id,
             account_site_id,
             --site_use_id,
             --geo_type_classification_code,
             attribute1,
             attribute2,
             attribute3,
             attribute4,
             attribute5,
             attribute6,
             attribute7,
             attribute8,
             attribute9 ,
             attribute10,
             attribute11,
             attribute12,
             attribute13,
             attribute14,
             attribute15,
             attribute_category,
             creation_date,
             created_by,
             last_update_date,
             last_updated_by,
             last_update_login
            ) values (
             Zx_Registrations_S.nextval,
             l_tax_registrations_rec.registration_type_code,
             p_le_new_reg_num,
             l_tax_registrations_rec.validation_rule,
             l_tax_registrations_rec.tax_authority_id,
             l_tax_registrations_rec.rep_tax_authority_id,
             l_tax_registrations_rec.coll_Tax_authority_id,
             l_tax_registrations_rec.rounding_rule_code,
             l_tax_registrations_rec.tax_jurisdiction_code,
             l_tax_registrations_rec.self_assess_flag,
             l_tax_registrations_rec.registration_status_code,
             l_tax_registrations_rec.registration_source_code,
             l_tax_registrations_rec.registration_reason_code,
             l_tax_registrations_rec.party_tax_profile_id,
             l_tax_registrations_rec.tax,
             l_tax_registrations_rec.tax_regime_code,
             l_tax_registrations_rec.inclusive_tax_flag,
             l_tax_registrations_rec.has_tax_exemptions_flag,
             SYSDATE + 1,
             NULL,
             l_tax_registrations_rec.rep_party_tax_name,
             l_tax_registrations_rec.legal_registration_id,
             l_tax_registrations_rec.default_registration_flag,
             l_tax_registrations_rec.bank_id,
             l_tax_registrations_rec.bank_branch_id,
             l_tax_registrations_rec.bank_account_num,
             l_tax_registrations_rec.legal_location_id,
             l_tax_registrations_rec.record_type_code,
             fnd_global.conc_request_id,
             fnd_global.prog_appl_id,
             fnd_global.conc_program_id,
             fnd_global.conc_login_id,
             l_tax_registrations_rec.account_id,
             l_tax_registrations_rec.account_site_id,
             --l_tax_registrations_rec.site_use_id,
             --l_tax_registrations_rec.geo_type_classification_code,
             l_tax_registrations_rec.attribute1,
             l_tax_registrations_rec.attribute2,
             l_tax_registrations_rec.attribute3,
             l_tax_registrations_rec.attribute4,
             l_tax_registrations_rec.attribute5,
             l_tax_registrations_rec.attribute6,
             l_tax_registrations_rec.attribute7,
             l_tax_registrations_rec.attribute8,
             l_tax_registrations_rec.attribute9 ,
             l_tax_registrations_rec.attribute10,
             l_tax_registrations_rec.attribute11,
             l_tax_registrations_rec.attribute12,
             l_tax_registrations_rec.attribute13,
             l_tax_registrations_rec.attribute14,
             l_tax_registrations_rec.attribute15,
             l_tax_registrations_rec.attribute_category,
             SYSDATE + 1,
             fnd_global.user_id,
             SYSDATE + 1,
             fnd_global.user_id,
             fnd_global.conc_login_id);

     ELSE

       update ZX_REGISTRATIONS set
              effective_to = p_le_old_end_date
       where registration_id = l_tax_registrations_rec.registration_id;

       insert into ZX_REGISTRATIONS (
             registration_id,
             registration_type_code,
             registration_number,
             validation_rule,
             tax_authority_id,
             rep_tax_authority_id,
             coll_Tax_authority_id,
             rounding_rule_code,
             tax_jurisdiction_code,
             self_assess_flag,
             registration_status_code,
             registration_source_code,
             registration_reason_code,
             party_tax_profile_id,
             tax,
             tax_regime_code,
             inclusive_tax_flag,
             has_tax_exemptions_flag,
             effective_from,
             effective_to,
             rep_party_tax_name,
             legal_registration_id,
             default_registration_flag,
             bank_id,
             bank_branch_id,
             bank_account_num,
             legal_location_id,
             record_type_code,
             request_id,
             program_application_id,
             program_id,
             program_login_id,
             account_id,
             account_site_id,
             --site_use_id,
             --geo_type_classification_code,
             attribute1,
             attribute2,
             attribute3,
             attribute4,
             attribute5,
             attribute6,
             attribute7,
             attribute8,
             attribute9 ,
             attribute10,
             attribute11,
             attribute12,
             attribute13,
             attribute14,
             attribute15,
             attribute_category,
             creation_date,
             created_by,
             last_update_date,
             last_updated_by,
             last_update_login
            ) values (
             Zx_Registrations_S.nextval,
             l_tax_registrations_rec.registration_type_code,
             p_le_new_reg_num,
             l_tax_registrations_rec.validation_rule,
             l_tax_registrations_rec.tax_authority_id,
             l_tax_registrations_rec.rep_tax_authority_id,
             l_tax_registrations_rec.coll_Tax_authority_id,
             l_tax_registrations_rec.rounding_rule_code,
             l_tax_registrations_rec.tax_jurisdiction_code,
             l_tax_registrations_rec.self_assess_flag,
             l_tax_registrations_rec.registration_status_code,
             l_tax_registrations_rec.registration_source_code,
             l_tax_registrations_rec.registration_reason_code,
             l_tax_registrations_rec.party_tax_profile_id,
             l_tax_registrations_rec.tax,
             l_tax_registrations_rec.tax_regime_code,
             l_tax_registrations_rec.inclusive_tax_flag,
             l_tax_registrations_rec.has_tax_exemptions_flag,
             p_le_old_end_date + 1,
             NULL,
             l_tax_registrations_rec.rep_party_tax_name,
             p_le_new_reg_id,
             l_tax_registrations_rec.default_registration_flag,
             l_tax_registrations_rec.bank_id,
             l_tax_registrations_rec.bank_branch_id,
             l_tax_registrations_rec.bank_account_num,
             l_tax_registrations_rec.legal_location_id,
             l_tax_registrations_rec.record_type_code,
             fnd_global.conc_request_id,
             fnd_global.prog_appl_id,
             fnd_global.conc_program_id,
             fnd_global.conc_login_id,
             l_tax_registrations_rec.account_id,
             l_tax_registrations_rec.account_site_id,
             --l_tax_registrations_rec.site_use_id,
             --l_tax_registrations_rec.geo_type_classification_code,
             l_tax_registrations_rec.attribute1,
             l_tax_registrations_rec.attribute2,
             l_tax_registrations_rec.attribute3,
             l_tax_registrations_rec.attribute4,
             l_tax_registrations_rec.attribute5,
             l_tax_registrations_rec.attribute6,
             l_tax_registrations_rec.attribute7,
             l_tax_registrations_rec.attribute8,
             l_tax_registrations_rec.attribute9 ,
             l_tax_registrations_rec.attribute10,
             l_tax_registrations_rec.attribute11,
             l_tax_registrations_rec.attribute12,
             l_tax_registrations_rec.attribute13,
             l_tax_registrations_rec.attribute14,
             l_tax_registrations_rec.attribute15,
             l_tax_registrations_rec.attribute_category,
             p_le_old_end_date + 1,
             fnd_global.user_id,
             p_le_old_end_date + 1,
             fnd_global.user_id,
             fnd_global.conc_login_id);
    END IF;

  END IF;

  END LOOP;

  CLOSE c_find_reg_num;

   -- Logging Infra: Procedure level
   IF (G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      l_log_msg := l_procedure_name||'(-)';
      FND_LOG.STRING(G_LEVEL_PROCEDURE, G_MODULE_NAME||l_procedure_name||'.begin', l_log_msg);
   END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Sync_Tax_Registrations_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR ;

       IF ( G_LEVEL_ERROR >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_ERROR,G_MODULE_NAME||l_api_name,'');
       END IF;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Sync_Tax_Registrations_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

      IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(G_LEVEL_UNEXPECTED,G_MODULE_NAME||l_api_name,'');
      END IF;

   WHEN INVALID_CURSOR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('ZX','ZX_GENERIC_MESSAGE');

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.SET_NAME('ZX','ZX_GENERIC_MESSAGE');

END SYNC_TAX_REGISTRATIONS;

Procedure GET_PARTY_TAX_PROF_INFO(
     P_PARTY_ID 		IN NUMBER,
     P_PARTY_TYPE_CODE 		IN ZX_PARTY_TAX_PROFILE.PARTY_TYPE_CODE%TYPE,
     X_TBL_INDEX                OUT NOCOPY BINARY_INTEGER,
     X_RETURN_STATUS  		OUT NOCOPY VARCHAR2)
IS

  CURSOR c_party_tax_prof_info
  IS
  SELECT
         ptp.party_tax_profile_id,
         ptp.party_id,
         ptp.party_type_code,
         ptp.supplier_flag,
         ptp.customer_flag,
         ptp.site_flag,
         ptp.process_for_applicability_flag,
         ptp.rounding_level_code,
         ptp.withholding_start_date,
         ptp.allow_awt_flag,
         ptp.use_le_as_subscriber_flag,
         ptp.legal_establishment_flag,
         ptp.first_party_le_flag,
         ptp.reporting_authority_flag,
         ptp.collecting_authority_flag,
         ptp.provider_type_code,
         ptp.create_awt_dists_type_code,
         ptp.create_awt_invoices_type_code,
         ptp.allow_offset_tax_flag,
         ptp.effective_from_use_le,
         ptp.rep_registration_number,
         ptp.rounding_rule_code
    FROM zx_party_tax_profile  ptp
   WHERE ptp.party_id = p_party_id
    AND  ptp.party_type_code = p_party_type_code;

   l_tbl_index  binary_integer;
   l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_tbl_index :=  dbms_utility.get_hash_value(p_party_type_code||'$'||to_char(p_party_id), 1, 8192);

   IF (ZX_GLOBAL_STRUCTURES_PKG.g_party_tax_prof_id_info_tbl.exists(l_tbl_index)
        AND ZX_GLOBAL_STRUCTURES_PKG.g_party_tax_prof_id_info_tbl(l_tbl_index).party_type_code = p_party_type_code
	AND ZX_GLOBAL_STRUCTURES_PKG.g_party_tax_prof_id_info_tbl(l_tbl_index).party_id = p_party_id)

   THEN

            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               l_log_msg := 'Party Tax Profile Id info for party_id: '||to_char(p_party_id)||' and party_type_code '
                           ||p_party_type_code||'  found in cache at index: '||to_char(l_tbl_index);
               FND_LOG.STRING(G_LEVEL_STATEMENT,'ZX_TCM_PTP_PKG.GET_PARTY_TAX_PROF_INFO', l_log_msg);
            END IF;

            X_TBL_INDEX := l_tbl_index;
            RETURN;
   ELSE

     For ptp IN c_party_tax_prof_info Loop

       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).party_tax_profile_id            := ptp.party_tax_profile_id;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).party_id                        := ptp.party_id;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).party_type_code                 := ptp.party_type_code;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).supplier_flag                   := ptp.supplier_flag;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).customer_flag                   := ptp.customer_flag;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).site_flag                       := ptp.site_flag;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).process_for_applicability_flag  := ptp.process_for_applicability_flag;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).rounding_level_code             := ptp.rounding_level_code;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).withholding_start_date          := ptp.withholding_start_date;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).allow_awt_flag                  := ptp.allow_awt_flag;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).use_le_as_subscriber_flag       := ptp.use_le_as_subscriber_flag;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).legal_establishment_flag        := ptp.legal_establishment_flag;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).first_party_le_flag             := ptp.first_party_le_flag;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).reporting_authority_flag        := ptp.reporting_authority_flag;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).collecting_authority_flag       := ptp.collecting_authority_flag;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).provider_type_code              := ptp.provider_type_code;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).create_awt_dists_type_code      := ptp.create_awt_dists_type_code;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).create_awt_invoices_type_code   := ptp.create_awt_invoices_type_code;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).allow_offset_tax_flag           := ptp.allow_offset_tax_flag;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).effective_from_use_le           := ptp.effective_from_use_le;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).rep_registration_number         := ptp.rep_registration_number;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).rounding_rule_code              := ptp.rounding_rule_code;


       ZX_GLOBAL_STRUCTURES_PKG.g_party_tax_prof_id_info_tbl(l_tbl_index).party_id := ptp.party_id;
       ZX_GLOBAL_STRUCTURES_PKG.g_party_tax_prof_id_info_tbl(l_tbl_index).party_type_code := ptp.party_type_code;
       ZX_GLOBAL_STRUCTURES_PKG.g_party_tax_prof_id_info_tbl(l_tbl_index).party_tax_profile_id := ptp.party_tax_profile_id;

       X_TBL_INDEX := l_tbl_index;
       exit;
    END LOOP;
   END IF;


EXCEPTION
  WHEN no_data_found then
            IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
               l_log_msg := 'No Data found in ZX_TCM_PTP_PKG.GET_PARTY_TAX_PROF_INFO. Still returning with success';
               FND_LOG.STRING(G_LEVEL_PROCEDURE,'ZX_TCM_PTP_PKG.GET_PARTY_TAX_PROF_INFO', l_log_msg);
            END IF;
            X_TBL_INDEX := NULL;
  WHEN others then
         IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
               l_log_msg := 'Unexpected error in ZX_TCM_PTP_PKG.GET_PARTY_TAX_PROF_INFO: '||SQLCODE||' ; '||SQLERRM;
               FND_LOG.STRING(G_LEVEL_UNEXPECTED,'ZX_TCM_PTP_PKG.GET_PARTY_TAX_PROF_INFO', l_log_msg);
            END IF;

END GET_PARTY_TAX_PROF_INFO;


Procedure GET_PARTY_TAX_PROF_INFO(
     P_PARTY_TAX_PROFILE_ID 	IN NUMBER,
     X_TBL_INDEX                OUT NOCOPY BINARY_INTEGER,
     X_RETURN_STATUS  		OUT NOCOPY VARCHAR2)
IS

  CURSOR c_party_tax_prof_info
  IS
  SELECT
         ptp.party_tax_profile_id,
         ptp.party_id,
         ptp.party_type_code,
         ptp.supplier_flag,
         ptp.customer_flag,
         ptp.site_flag,
         ptp.process_for_applicability_flag,
         ptp.rounding_level_code,
         ptp.withholding_start_date,
         ptp.allow_awt_flag,
         ptp.use_le_as_subscriber_flag,
         ptp.legal_establishment_flag,
         ptp.first_party_le_flag,
         ptp.reporting_authority_flag,
         ptp.collecting_authority_flag,
         ptp.provider_type_code,
         ptp.create_awt_dists_type_code,
         ptp.create_awt_invoices_type_code,
         ptp.allow_offset_tax_flag,
         ptp.effective_from_use_le,
         ptp.rep_registration_number,
         ptp.rounding_rule_code
    FROM zx_party_tax_profile  ptp
   WHERE party_tax_profile_id = p_party_tax_profile_id;

   l_log_msg   FND_LOG_MESSAGES.MESSAGE_TEXT%TYPE;
   l_tbl_index  binary_integer;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL.exists(p_party_tax_profile_id)
   THEN

            IF ( G_LEVEL_STATEMENT >= G_CURRENT_RUNTIME_LEVEL) THEN
               l_log_msg := 'Party Tax Profile Id info found in cache ';
               FND_LOG.STRING(G_LEVEL_STATEMENT,'ZX_TCM_PTP_PKG.GET_PARTY_TAX_PROF_INFO', l_log_msg);
            END IF;

            X_TBL_INDEX := p_party_tax_profile_id;
            RETURN;
   ELSE

     For ptp IN c_party_tax_prof_info Loop

       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).party_tax_profile_id            := ptp.party_tax_profile_id;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).party_id                        := ptp.party_id;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).party_type_code                 := ptp.party_type_code;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).supplier_flag                   := ptp.supplier_flag;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).customer_flag                   := ptp.customer_flag;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).site_flag                       := ptp.site_flag;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).process_for_applicability_flag  := ptp.process_for_applicability_flag;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).rounding_level_code             := ptp.rounding_level_code;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).withholding_start_date          := ptp.withholding_start_date;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).allow_awt_flag                  := ptp.allow_awt_flag;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).use_le_as_subscriber_flag       := ptp.use_le_as_subscriber_flag;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).legal_establishment_flag        := ptp.legal_establishment_flag;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).first_party_le_flag             := ptp.first_party_le_flag;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).reporting_authority_flag        := ptp.reporting_authority_flag;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).collecting_authority_flag       := ptp.collecting_authority_flag;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).provider_type_code              := ptp.provider_type_code;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).create_awt_dists_type_code      := ptp.create_awt_dists_type_code;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).create_awt_invoices_type_code   := ptp.create_awt_invoices_type_code;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).allow_offset_tax_flag           := ptp.allow_offset_tax_flag;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).effective_from_use_le           := ptp.effective_from_use_le;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).rep_registration_number         := ptp.rep_registration_number;
       ZX_GLOBAL_STRUCTURES_PKG.G_PARTY_TAX_PROF_INFO_TBL(ptp.party_tax_profile_id).rounding_rule_code              := ptp.rounding_rule_code;

       l_tbl_index :=  dbms_utility.get_hash_value(ptp.party_type_code||'$'||to_char(ptp.party_id), 1, 8192);

       ZX_GLOBAL_STRUCTURES_PKG.g_party_tax_prof_id_info_tbl(l_tbl_index).party_id := ptp.party_id;
       ZX_GLOBAL_STRUCTURES_PKG.g_party_tax_prof_id_info_tbl(l_tbl_index).party_type_code := ptp.party_type_code;
       ZX_GLOBAL_STRUCTURES_PKG.g_party_tax_prof_id_info_tbl(l_tbl_index).party_tax_profile_id := ptp.party_tax_profile_id;

       X_TBL_INDEX := ptp.party_tax_profile_id;
       exit;
    END LOOP;
   END IF;


EXCEPTION

  WHEN no_data_found then
            IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
               l_log_msg := 'No Data found in ZX_TCM_PTP_PKG.GET_PARTY_TAX_PROF_INFO. Still returning with success';
               FND_LOG.STRING(G_LEVEL_PROCEDURE,'ZX_TCM_PTP_PKG.GET_PARTY_TAX_PROF_INFO', l_log_msg);
            END IF;
            X_TBL_INDEX := NULL;

  WHEN others then
         IF ( G_LEVEL_UNEXPECTED >= G_CURRENT_RUNTIME_LEVEL) THEN
               l_log_msg := 'Unexpected error in ZX_TCM_PTP_PKG.GET_PARTY_TAX_PROF_INFO: '||SQLCODE||' ; '||SQLERRM;
               FND_LOG.STRING(G_LEVEL_UNEXPECTED,'ZX_TCM_PTP_PKG.GET_PARTY_TAX_PROF_INFO', l_log_msg);
            END IF;

END GET_PARTY_TAX_PROF_INFO;


END ZX_TCM_PTP_PKG;

/
