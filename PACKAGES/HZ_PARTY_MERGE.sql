--------------------------------------------------------
--  DDL for Package HZ_PARTY_MERGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_PARTY_MERGE" AUTHID CURRENT_USER AS
/* $Header: ARHPMERS.pls 120.3 2005/06/16 21:14:25 jhuang noship $ */

PROCEDURE batch_merge(
        errbuf                  OUT     NOCOPY VARCHAR2,
        retcode                 OUT     NOCOPY VARCHAR2,
        p_batch_id              IN      VARCHAR2,
        p_preview              IN      VARCHAR2
);

PROCEDURE veto_delete;

PROCEDURE get_merge_to_record_id
(
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2:=FND_API.G_FALSE,
        p_record_id                     IN      NUMBER,
        p_entity_name                   IN      VARCHAR2,
        x_is_merged                     OUT     NOCOPY VARCHAR2,
        x_merge_to_record_id            OUT     NOCOPY NUMBER,
        x_merge_to_record_desc          OUT     NOCOPY VARCHAR2,
        x_return_status                 OUT     NOCOPY VARCHAR2,
        x_msg_count                     OUT     NOCOPY NUMBER,
        x_msg_data                      OUT     NOCOPY VARCHAR2
);

PROCEDURE check_party_in_merge_batch
(
        p_api_version                   IN      NUMBER,
        p_init_msg_list                 IN      VARCHAR2:=FND_API.G_FALSE,
	p_party_id 			IN	NUMBER,
	x_in_merge			OUT	NOCOPY VARCHAR2,
	x_batch_id			OUT	NOCOPY NUMBER,
	x_batch_name			OUT	NOCOPY VARCHAR2,
	x_batch_created_by		OUT	NOCOPY VARCHAR2,
	x_batch_creation_date		OUT	NOCOPY DATE,
        x_return_status                 OUT     NOCOPY VARCHAR2,
        x_msg_count                     OUT     NOCOPY NUMBER,
        x_msg_data                      OUT     NOCOPY VARCHAR2
);

PROCEDURE store_merge_history(
        p_batch_party_id        IN      HZ_MERGE_PARTIES.BATCH_PARTY_ID%TYPE,
        p_from_id               IN      HZ_MERGE_PARTIES.FROM_PARTY_ID%TYPE,
        p_to_id                 IN      HZ_MERGE_PARTIES.TO_PARTY_ID%TYPE,
        p_from_fk_id            IN      HZ_MERGE_PARTIES.TO_PARTY_ID%TYPE,
        p_to_fk_id              IN      HZ_MERGE_PARTIES.TO_PARTY_ID%TYPE,
        p_from_desc             IN      HZ_MERGE_PARTY_HISTORY.FROM_ENTITY_DESC%TYPE,
        p_to_desc               IN      HZ_MERGE_PARTY_HISTORY.TO_ENTITY_DESC%TYPE,
        p_merge_dict_id         IN      HZ_MERGE_DICTIONARY.MERGE_DICT_ID%TYPE,
        p_op_type               IN      HZ_MERGE_PARTY_HISTORY.OPERATION_TYPE%TYPE,
        p_flush                 IN      VARCHAR2 := 'N');

PROCEDURE store_merge_log(
        p_batch_party_id        IN      HZ_MERGE_PARTIES.BATCH_PARTY_ID%TYPE,
        p_from_id               IN      HZ_MERGE_PARTIES.FROM_PARTY_ID%TYPE,
        p_to_id                 IN      HZ_MERGE_PARTIES.TO_PARTY_ID%TYPE,
        p_from_fk_id            IN      HZ_MERGE_PARTIES.TO_PARTY_ID%TYPE,
        p_to_fk_id              IN      HZ_MERGE_PARTIES.TO_PARTY_ID%TYPE,
        p_from_desc             IN      HZ_MERGE_PARTY_HISTORY.FROM_ENTITY_DESC%TYPE,
        p_to_desc               IN      HZ_MERGE_PARTY_HISTORY.TO_ENTITY_DESC%TYPE,
        p_merge_dict_id         IN      HZ_MERGE_DICTIONARY.MERGE_DICT_ID%TYPE,
        p_op_type               IN      HZ_MERGE_PARTY_LOG.OPERATION_TYPE%TYPE,
        p_error                 IN      HZ_MERGE_PARTY_LOG.ERROR_MESSAGES%TYPE
                                DEFAULT NULL,
        p_flush                 IN      VARCHAR2 := 'N');

FUNCTION get_col_type(
        p_table         VARCHAR2,
        p_column        VARCHAR2,
        p_app_name      VARCHAR2)
  RETURN VARCHAR2;

END HZ_PARTY_MERGE;

 

/
