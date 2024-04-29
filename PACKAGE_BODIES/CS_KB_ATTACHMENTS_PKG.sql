--------------------------------------------------------
--  DDL for Package Body CS_KB_ATTACHMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_ATTACHMENTS_PKG" AS
/* $Header: cskbattb.pls 115.2 2003/11/12 23:05:10 mkettle noship $ */


PROCEDURE Clone_Attachment_Links (
    p_set_source_id IN NUMBER,
    p_set_target_id IN NUMBER) IS

 l_current_user NUMBER := FND_GLOBAL.user_id;
 l_current_login NUMBER := FND_GLOBAL.login_id;

BEGIN

  IF p_set_source_id IS NOT NULL AND p_set_target_id IS NOT NULL THEN

    FND_ATTACHED_DOCUMENTS2_PKG.copy_attachments(
              X_from_entity_name => 'CS_KB_SETS_B',
		      X_from_pk1_value   => to_char(p_set_source_id),
			  X_to_entity_name   => 'CS_KB_SETS_B',
			  X_to_pk1_value     => to_char(p_set_target_id),
			  X_created_by       => l_current_user,
              X_last_update_login => l_current_login);




  ELSE
    -- Insufficient parameters passed in
    RAISE INSUFFICIENT_PARAMS;
  END IF;
EXCEPTION
 WHEN INSUFFICIENT_PARAMS THEN
   IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'csk.plsql.CS_KB_ATTACHMENTS_PKG.clone',
                   'Insufficient parameters passed: - '||p_set_source_id||' + '||p_set_target_id );
   END IF;
   FND_MSG_PUB.initialize;
   FND_MESSAGE.set_name('CS', 'CS_KB_C_MISS_PARAM');
   FND_MSG_PUB.ADD;
   RAISE;
END Clone_Attachment_Links;


END CS_KB_ATTACHMENTS_PKG;

/
