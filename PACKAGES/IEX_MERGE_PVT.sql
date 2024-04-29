--------------------------------------------------------
--  DDL for Package IEX_MERGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_MERGE_PVT" AUTHID CURRENT_USER as
/* $Header: iexvmrgs.pls 120.0 2004/01/24 03:27:17 appldev noship $ */

PROCEDURE SCORE_HISTORY_MERGE (req_id       NUMBER,
                               set_num      NUMBER,
                               process_mode VARCHAR2);

PROCEDURE DUNNING_MERGE (req_id       NUMBER,
                         set_num      NUMBER,
                         process_mode VARCHAR2);

PROCEDURE STRATEGY_MERGE (req_id       NUMBER,
                          set_num      NUMBER,
                          process_mode VARCHAR2);

PROCEDURE PROMISE_MERGE(Req_id       NUMBER,
                        Set_Num      NUMBER,
                        Process_MODE VARCHAR2);

PROCEDURE DELINQUENCY_MERGE(Req_id       NUMBER,
                            Set_Num      NUMBER,
                            Process_MODE VARCHAR2);

PROCEDURE MERGE_DELINQUENCY_PARTIES(p_entity_name    IN VARCHAR2,
                                    p_from_id        IN NUMBER,
                                    p_to_id          IN OUT NOCOPY NUMBER,
                                    p_from_fk_id     IN NUMBER,
                                    p_to_fk_id       IN NUMBER,
                                    p_parent_entity  IN VARCHAR2,
                                    p_batch_id       IN NUMBER,
                                    p_batch_party_id IN NUMBER,
                                    x_return_status  OUT NOCOPY VARCHAR2);

PROCEDURE CASE_CONTACT_MERGE(p_entity_name           IN       VARCHAR2
                             ,p_from_id              IN       NUMBER
                             ,p_to_id                IN OUT NOCOPY   NUMBER
                             ,p_from_fk_id           IN       NUMBER
                             ,p_to_fk_id             IN       NUMBER
                             ,p_parent_entity_name   IN       VARCHAR2
                             ,p_batch_id             IN       NUMBER
                             ,p_batch_party_id       IN       NUMBER
                             ,x_return_status        IN OUT NOCOPY   VARCHAR2);


END;

 

/
