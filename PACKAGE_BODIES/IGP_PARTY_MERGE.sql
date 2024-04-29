--------------------------------------------------------
--  DDL for Package Body IGP_PARTY_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGP_PARTY_MERGE" AS
/* $Header: IGSPADDB.pls 120.0 2005/06/01 17:15:38 appldev noship $ */

  PROCEDURE merge_party (
    p_entity_name        IN VARCHAR2,
    p_from_id            IN NUMBER,
    p_to_id              IN OUT NOCOPY  NUMBER,
    p_from_fk_id         IN NUMBER,
    p_to_fk_id           IN NUMBER,
    p_parent_entity_name IN VARCHAR2,
    p_batch_id           IN NUMBER,
    p_batch_party_id     IN NUMBER,
    x_return_status      IN OUT NOCOPY  VARCHAR2 ) AS

  BEGIN

    IF p_from_fk_id = p_to_fk_id THEN
      p_to_id := p_from_id;
      RETURN;

    ELSE
      hz_party_merge.veto_delete;
      fnd_message.set_name('IGS','IGP_GE_CANT_PARTY_MERGE');
      fnd_message.set_token('P_FROM_ID',p_from_id);
      fnd_file.put_line(FND_FILE.LOG,FND_MESSAGE.GET);
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

  END  merge_party;

END igp_party_merge;

/
