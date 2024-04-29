--------------------------------------------------------
--  DDL for Package OKC_K_ENTITY_LOCKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_K_ENTITY_LOCKS_PKG" 
/* $Header: OKCVELKS.pls 120.1.12010000.1 2011/12/09 13:12:12 serukull noship $ */
AUTHID CURRENT_USER AS
PROCEDURE insert_row ( p_entity_name IN VARCHAR2,
                       p_entity_pk1 IN VARCHAR2,
                       p_entity_pk2 IN VARCHAR2,
                       p_entity_pk3 IN VARCHAR2,
                       p_entity_pk4 IN VARCHAR2,
                       p_entity_pk5 IN VARCHAR2,
                       P_LOCK_BY_ENTITY_ID IN NUMBER,
                       P_LOCK_by_document_type IN VARCHAR2,
                       p_LOCK_by_document_id IN NUMBER,
                       P_OBJECT_VERSION_NUMBER IN NUMBER,
                       P_CREATED_BY  IN NUMBER,
                       P_CREATION_DATE  IN  DATE,
                       P_LAST_UPDATED_BY  IN NUMBER,
                       P_LAST_UPDATE_DATE  IN DATE,
                       P_LAST_UPDATE_LOGIN  IN NUMBER,
                       x_k_entity_lock_id OUT NOCOPY NUMBER,
                       X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                       X_MSG_COUNT OUT NOCOPY NUMBER,
                       X_MSG_DATA OUT NOCOPY VARCHAR2
                      );

PROCEDURE delete_row (P_ENTITY_NAME IN VARCHAR2,
                      P_ENTITY_PK1 IN VARCHAR2,
                      P_ENTITY_PK2 IN VARCHAR2,
                      P_ENTITY_PK3 IN VARCHAR2,
                      P_ENTITY_PK4 IN VARCHAR2,
                      P_ENTITY_PK5 IN VARCHAR2,
                      P_LOCK_BY_ENTITY_ID IN NUMBER,
                      P_LOCK_by_document_type IN VARCHAR2,
                      p_LOCK_by_document_id IN NUMBER,
                      X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                      X_MSG_COUNT OUT NOCOPY NUMBER,
                      X_MSG_DATA OUT NOCOPY VARCHAR2
                     );
END okc_k_entity_locks_pkg;

/
