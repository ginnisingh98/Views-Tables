--------------------------------------------------------
--  DDL for Package OKC_K_ENTITY_LOCKS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_K_ENTITY_LOCKS_GRP" 
/* $Header: OKCGELKS.pls 120.0.12010000.1 2011/12/09 11:57:26 serukull noship $ */
AUTHID CURRENT_USER AS

---------------------------------------------------------------------
G_SECTION_ENTITY VARCHAR2(240) := 'SECTION';
G_CLAUSE_ENTITY VARCHAR2(240) := 'CLAUSE';
G_XPRT_ENTITY VARCHAR2(240) := 'XPRT';
---------------------------------------------------------------------
PROCEDURE lock_entity( P_API_VERSION     IN NUMBER,
                       P_INIT_MSG_LIST   IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                       P_COMMIT         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                       -----------------
                       P_ENTITY_NAME IN VARCHAR2,
                       P_ENTITY_PK1 IN VARCHAR2,
                       P_ENTITY_PK2 IN VARCHAR2 DEFAULT NULL,
                       P_ENTITY_PK3 IN VARCHAR2 DEFAULT NULL,
                       P_ENTITY_PK4 IN VARCHAR2 DEFAULT NULL,
                       P_ENTITY_PK5 IN VARCHAR2 DEFAULT NULL,
                       P_LOCK_BY_ENTITY_ID IN NUMBER DEFAULT NULL,
                       P_LOCK_BY_DOCUMENT_TYPE IN VARCHAR2,
                       P_LOCK_BY_DOCUMENT_ID IN NUMBER,
                       ---------------------
                       X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                       X_MSG_COUNT OUT NOCOPY NUMBER,
                       X_MSG_DATA OUT NOCOPY VARCHAR2
                      );

PROCEDURE rebuild_locks( p_api_version     IN NUMBER,
                         p_init_msg_list   IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                         p_commit         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                         p_update_from_doc_type  IN VARCHAR2,
                         p_update_from_doc_id  IN NUMBER,
                         p_update_to_doc_type  IN VARCHAR2,
                         p_update_to_doc_id   IN NUMBER,
                         X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                         X_MSG_COUNT OUT NOCOPY NUMBER,
                         X_MSG_DATA OUT NOCOPY VARCHAR2
                        );

PROCEDURE release_locks (p_api_version     IN NUMBER,
                         p_init_msg_list   IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                         p_commit         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                         p_doc_type  IN VARCHAR2,
                         p_doc_id  IN NUMBER,
                         X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                         X_MSG_COUNT OUT NOCOPY NUMBER,
                         X_MSG_DATA OUT NOCOPY VARCHAR2
                         );

 PROCEDURE unlock_entity (
      p_api_version             IN              NUMBER,
      p_init_msg_list           IN              VARCHAR2
            DEFAULT fnd_api.g_false,
      p_commit                  IN              VARCHAR2
            DEFAULT fnd_api.g_false,
      p_entity_name             IN              VARCHAR2,
      p_entity_pk1              IN              VARCHAR2,
      p_entity_pk2              IN              VARCHAR2 DEFAULT NULL,
      p_entity_pk3              IN              VARCHAR2 DEFAULT NULL,
      p_entity_pk4              IN              VARCHAR2 DEFAULT NULL,
      p_entity_pk5              IN              VARCHAR2 DEFAULT NULL,
      p_lock_by_entity_id       IN              NUMBER DEFAULT NULL,
      p_lock_by_document_type   IN              VARCHAR2,
      p_lock_by_document_id     IN              NUMBER,
      x_return_status           OUT NOCOPY      VARCHAR2,
      x_msg_count               OUT NOCOPY      NUMBER,
      x_msg_data                OUT NOCOPY      VARCHAR2
   );

PROCEDURE revert_changes( p_api_version     IN NUMBER,
                          p_init_msg_list   IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                          p_commit         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                          p_K_ENTITY_LOCK_ID IN NUMBER,
                          P_ENTITY_NAME  IN VARCHAR2,
                          P_ENTITY_PK1   IN VARCHAR2,
                          P_ENTITY_PK2   IN VARCHAR2 DEFAULT NULL,
                          P_ENTITY_PK3   IN VARCHAR2 DEFAULT NULL,
                          P_ENTITY_PK4   IN VARCHAR2 DEFAULT NULL,
                          P_ENTITY_PK5   IN VARCHAR2 DEFAULT NULL,
                          p_lock_by_entity_id   IN NUMBER DEFAULT NULL,
                          p_LOCK_BY_DOCUMENT_TYPE IN VARCHAR2,
                          p_LOCK_BY_DOCUMENT_ID IN NUMBER,
                          X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                          X_MSG_COUNT OUT NOCOPY NUMBER,
                          X_MSG_DATA OUT NOCOPY VARCHAR2
                         );


PROCEDURE revert_entity ( p_api_version     IN NUMBER,
                          p_init_msg_list   IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                          p_commit         IN VARCHAR2 DEFAULT FND_API.G_FALSE,
                          p_k_entity_lock_id IN NUMBER,
                          X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                          X_MSG_COUNT OUT NOCOPY NUMBER,
                          X_MSG_DATA OUT NOCOPY VARCHAR2
                         );



PROCEDURE CheckBaseRecExists(X_REC_EXISTS   OUT NOCOPY VARCHAR2,
                          P_ENTITY_NAME  IN VARCHAR2,
                          P_ENTITY_PK1   IN VARCHAR2,
                          P_ENTITY_PK2   IN VARCHAR2 DEFAULT NULL,
                          p_entity_pk3   IN VARCHAR2 DEFAULT NULL,
                          p_entity_pk4   IN VARCHAR2 DEFAULT NULL,
                          p_entity_pk5   IN VARCHAR2 DEFAULT NULL,
                          X_RETURN_STATUS OUT NOCOPY VARCHAR2
                        ) ;

FUNCTION isLockExists    (
                          P_ENTITY_NAME  IN VARCHAR2,
                          p_LOCK_BY_DOCUMENT_TYPE  IN VARCHAR2,
                          p_LOCK_BY_DOCUMENT_ID  IN NUMBER)
                         RETURN VARCHAR2 ;


FUNCTION get_document_number(p_document_type IN VARCHAR2, p_document_id IN number)
RETURN VARCHAR2;

FUNCTION get_entity_title (p_entity_name IN VARCHAR2, p_entity_pk1 IN VARCHAR2 , p_entity_pk2 IN VARCHAR2) RETURN VARCHAR2;



PROCEDURE get_src_doc_details ( p_doc_type IN VARCHAR2,
                                p_doc_id   IN NUMBER,
                                x_src_doc_type  OUT NOCOPY VARCHAR2,
                                x_src_doc_id OUT NOCOPY VARCHAR2,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_data  OUT NOCOPY VARCHAR2,
                                x_msg_count OUT NOCOPY NUMBER
                              );




/*
   All section operations should be locked recursively to clauses.
   update, delete, move.

 */

 FUNCTION  isclauseLockedbyOtherDoc (p_src_kart_id IN NUMBER,p_tgt_document_type IN VARCHAR2,p_tgt_document_id IN NUMBER)
 RETURN VARCHAR2;

 FUNCTION isSectionLockedbyOtherDoc (p_src_ksec_id IN NUMBER,p_tgt_document_type IN VARCHAR2,p_tgt_document_id IN NUMBER)
RETURN VARCHAR2;

 FUNCTION isXprtLockedbyOtherDoc (p_tgt_document_type IN VARCHAR2,p_tgt_document_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION isEntityLockedbyOtherDoc (p_entity_name IN VARCHAR2,p_src_entity_id IN NUMBER,p_tgt_document_type IN VARCHAR2,p_tgt_document_id IN NUMBER)
RETURN VARCHAR2;

FUNCTION isAnyClauseLockedByOtherDoc(p_variable_code IN VARCHAR2, p_tgt_document_type IN VARCHAR2, p_tgt_document_id IN NUMBER)
RETURN VARCHAR2;

PROCEDURE isAnyEntityLockedbyOtherDoc( p_doc_type IN VARCHAR2,
                             p_doc_id   IN NUMBER,
                             x_entity_locked OUT NOCOPY VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_data  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY NUMBER
                           );

PROCEDURE start_notify_workflow(

                             p_document_type IN VARCHAR2,
                             p_document_id   IN NUMBER,
	                           p_requestor_id   IN NUMBER,
	                           p_actioner_id   IN NUMBER,
	                           p_action_requested   IN VARCHAR2,
	                           p_action_req_details IN VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_data  OUT NOCOPY VARCHAR2,
                             x_msg_count OUT NOCOPY NUMBER,
                             p_init_msg_list   IN VARCHAR2 DEFAULT FND_API.G_TRUE
                                );

END okc_k_entity_locks_grp;

/
