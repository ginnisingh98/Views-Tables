--------------------------------------------------------
--  DDL for Package Body PV_REFERRAL_DQM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_REFERRAL_DQM_PUB" as
/* $Header: pvxvdqmb.pls 115.0 2003/12/12 01:51:17 amaram noship $*/

/*************************************************************************************/
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*                    Global Variable Declaration                                    */
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*************************************************************************************/
g_log_to_file        VARCHAR2(5)  := 'N';
g_pkg_name           VARCHAR2(30) := 'PV_REFERRAL_DQM_PUB';
g_api_name           VARCHAR2(30);
g_RETCODE            VARCHAR2(10) := '0';
g_module_name        VARCHAR2(48);


PV_DEBUG_HIGH_ON boolean :=
   FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON boolean :=
   FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON boolean :=
   FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
PV_DEBUG_ERROR_ON boolean :=
   FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_ERROR);



/*************************************************************************************/
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*                    private procedure declaration                                  */
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/*************************************************************************************/
PROCEDURE Debug(
   p_msg_string      IN VARCHAR2,
   p_msg_type        IN VARCHAR2 := 'PV_DEBUG_MESSAGE',
   p_token_type      IN VARCHAR2 := 'TEXT',
   p_statement_level IN NUMBER   := FND_LOG.LEVEL_PROCEDURE
);

PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2 := NULL,
    p_token1_value  IN      VARCHAR2 := NULL,
    p_token2        IN      VARCHAR2 := NULL ,
    p_token2_value  IN      VARCHAR2 := NULL,
    p_token3        IN      VARCHAR2 := NULL,
    p_token3_value  IN      VARCHAR2 := NULL
);



--=============================================================================+
--| Public Procedure                                                           |
--|    Create_Lead_Opportunity                                                 |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Create_Lead_Opportunity (
   p_api_version               IN  NUMBER,
   p_init_msg_list             IN  VARCHAR2  := FND_API.g_false,
   p_commit                    IN  VARCHAR2  := FND_API.g_false,
   p_validation_level          IN  NUMBER    := FND_API.g_valid_level_full,
   p_referral_id               IN  NUMBER,
   p_customer_party_id         IN  NUMBER  := NULL,
   p_customer_party_site_id    IN  NUMBER  := NULL,
   p_customer_org_contact_id   IN  NUMBER  := NULL,
   p_customer_contact_party_id IN  NUMBER  := NULL,
   p_get_from_db_flag          IN  VARCHAR2 := 'Y',
   x_entity_type               OUT NOCOPY VARCHAR2,
   x_entity_id                 OUT NOCOPY NUMBER,
   x_return_status             OUT NOCOPY VARCHAR2,
   x_msg_count                 OUT NOCOPY NUMBER,
   x_msg_data                  OUT NOCOPY VARCHAR2
)
IS
   l_api_version               NUMBER       := 1;
   l_benefit_type              VARCHAR2(30);
   l_sales_transaction_type    VARCHAR2(30);



BEGIN
   g_api_name := 'Create_Lead_Opportunity';

   -------------------- initialize -------------------------
   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         g_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;



   Debug('user_id     : ' || fnd_global.user_id());
   Debug('resp_id     : ' || fnd_global.resp_id());
   Debug('appl_id     : ' || fnd_global.resp_appl_id());


      Debug('Return Status: ' || x_return_status);

      IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
         RAISE FND_API.G_EXC_ERROR;

      ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;



   -------------------- Exception --------------------------
   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
         ROLLBACK;
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MSG_PUB.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                    p_count     =>  x_msg_count,
                                    p_data      =>  x_msg_data);

      WHEN FND_API.g_exc_unexpected_error THEN
         ROLLBACK;
         x_return_status := FND_API.g_ret_sts_unexp_error;
         FND_MSG_PUB.count_and_get(
               p_encoded => FND_API.g_false,
               p_count   => x_msg_count,
               p_data    => x_msg_data
         );

      WHEN OTHERS THEN
        ROLLBACK;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
           FND_MSG_PUB.add_exc_msg(g_pkg_name, g_api_name);
        END IF;

        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.count_and_get(
              p_encoded => FND_API.g_false,
              p_count   => x_msg_count,
              p_data    => x_msg_data
        );

END;
-- ======================End of Create_Lead_Opportunity==========================


--=============================================================================+
--|  Private Procedure                                                         |
--|                                                                            |
--|    Debug                                                                   |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Debug(
   p_msg_string      IN VARCHAR2,
   p_msg_type        IN VARCHAR2 := 'PV_DEBUG_MESSAGE',
   p_token_type      IN VARCHAR2 := 'TEXT',
   p_statement_level IN NUMBER   := FND_LOG.LEVEL_PROCEDURE
)
IS
BEGIN
   IF (PV_DEBUG_LOW_ON) THEN
      FND_MESSAGE.Set_Name('PV', p_msg_type);
      FND_MESSAGE.Set_Token(p_token_type, p_msg_string);

      IF (g_log_to_file = 'N') THEN
         FND_MSG_PUB.Add;

      ELSIF (g_log_to_file = 'Y') THEN
         FND_FILE.PUT_LINE( FND_FILE.LOG,  fnd_message.get );
      END IF;
   END IF;

   IF (p_statement_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(p_statement_level,
         'pv.plsql.' || g_pkg_name || '.' || g_api_name,
         p_msg_string
      );
   END IF;
END Debug;
-- =================================End of Debug================================


--=============================================================================+
--|  Public Procedure                                                          |
--|                                                                            |
--|    Set_Message                                                             |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2 := NULL,
    p_token1_value  IN      VARCHAR2 := NULL,
    p_token2        IN      VARCHAR2 := NULL ,
    p_token2_value  IN      VARCHAR2 := NULL,
    p_token3        IN      VARCHAR2 := NULL,
    p_token3_value  IN      VARCHAR2 := NULL
)
IS
BEGIN
   -- --------------------------------------------------------------------------
   -- 11.5.10 debug - messages logged to fnd_log_messages table.
   -- --------------------------------------------------------------------------
   IF (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_MESSAGE.Set_Name('PV', p_msg_name);

      IF (p_token1 IS NOT NULL) THEN
         FND_MESSAGE.Set_Token(p_token1, p_token1_value);
      END IF;

      IF (p_token2 IS NOT NULL) THEN
         FND_MESSAGE.Set_Token(p_token2, p_token2_value);
      END IF;

      IF (p_token3 IS NOT NULL) THEN
         FND_MESSAGE.Set_Token(p_token3, p_token3_value);
      END IF;


      FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
         'pv.plsql.' || g_pkg_name || '.' || g_api_name,
         FALSE
      );
   END IF;

   -- --------------------------------------------------------------------------
   -- Pre-11.5.10 debug message
   -- --------------------------------------------------------------------------
   FND_MESSAGE.Set_Name('PV', p_msg_name);

   IF (p_token1 IS NOT NULL) THEN
      FND_MESSAGE.Set_Token(p_token1, p_token1_value);
   END IF;

   IF (p_token2 IS NOT NULL) THEN
      FND_MESSAGE.Set_Token(p_token2, p_token2_value);
   END IF;

   IF (p_token3 IS NOT NULL) THEN
      FND_MESSAGE.Set_Token(p_token3, p_token3_value);
   END IF;

   FND_MSG_PUB.Add;
END Set_Message;
-- ==============================End of Set_Message==============================


END PV_REFERRAL_DQM_PUB;

/
