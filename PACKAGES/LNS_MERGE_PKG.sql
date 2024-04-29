--------------------------------------------------------
--  DDL for Package LNS_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_MERGE_PKG" AUTHID CURRENT_USER as
/* $Header: LNS_MERGE_S.pls 120.0 2005/05/31 18:11:21 appldev noship $ */


PROCEDURE MERGE_LOAN_HEADERS(p_entity_name    IN VARCHAR2,
                            p_from_id        IN NUMBER,
                            p_to_id          IN OUT NOCOPY NUMBER,
                            p_from_fk_id     IN NUMBER,
                            p_to_fk_id       IN NUMBER,
                            p_parent_entity  IN VARCHAR2,
                            p_batch_id       IN NUMBER,
                            p_batch_party_id IN NUMBER,
                            x_return_status  OUT NOCOPY VARCHAR2);


PROCEDURE MERGE_PARTICIPANTS(p_entity_name    IN VARCHAR2,
                            p_from_id        IN NUMBER,
                            p_to_id          IN OUT NOCOPY NUMBER,
                            p_from_fk_id     IN NUMBER,
                            p_to_fk_id       IN NUMBER,
                            p_parent_entity  IN VARCHAR2,
                            p_batch_id       IN NUMBER,
                            p_batch_party_id IN NUMBER,
                            x_return_status  OUT NOCOPY VARCHAR2);


PROCEDURE MERGE_LOAN_HEADERS_ACC (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);


PROCEDURE MERGE_PARTICIPANTS_ACC (
        req_id                       NUMBER,
        set_num                      NUMBER,
        process_mode                 VARCHAR2);


END LNS_MERGE_PKG;

 

/
