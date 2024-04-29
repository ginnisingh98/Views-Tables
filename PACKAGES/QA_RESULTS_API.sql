--------------------------------------------------------
--  DDL for Package QA_RESULTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_RESULTS_API" AUTHID CURRENT_USER AS
/* $Header: qltrsiub.pls 120.2.12010000.1 2008/07/25 09:22:16 appldev ship $ */


PROCEDURE commit_qa_results( p_collection_id  IN NUMBER);


PROCEDURE enable_and_fire_action( p_collection_id IN NUMBER);

--
-- 12.1 QWB Usability Improvements
-- added a new parameter, p_ssqr_opperation to ensure
-- that the validation is not done again at the time of
-- inserting rows through QWB
--
FUNCTION insert_row( p_plan_id                 IN  NUMBER,
                     p_spec_id                 IN  NUMBER DEFAULT NULL,
                     p_org_id                  IN  NUMBER,
                     p_transaction_number      IN  NUMBER DEFAULT NULL,
                     p_transaction_id          IN  NUMBER DEFAULT 0,
                     p_collection_id           IN  OUT NOCOPY NUMBER,
                     p_who_last_updated_by     IN  NUMBER := fnd_global.user_id,
                     p_who_created_by          IN  NUMBER := fnd_global.user_id,
                     p_who_last_update_login   IN  NUMBER := fnd_global.user_id,
                     p_enabled_flag            IN  NUMBER,
                     p_commit_flag             IN  BOOLEAN DEFAULT FALSE,
                     p_error_found             OUT NOCOPY BOOLEAN,
                     p_occurrence              IN OUT NOCOPY NUMBER,
                     p_do_action_return        OUT NOCOPY BOOLEAN,
                     p_message_array           OUT NOCOPY qa_validation_api.MessageArray,
                     p_row_elements            IN  OUT NOCOPY qa_validation_api.ElementsArray,
                     p_txn_header_id           IN  NUMBER DEFAULT NULL,
                     p_ssqr_operation          IN  NUMBER DEFAULT NULL,
                     p_last_update_date        IN  DATE DEFAULT SYSDATE)

    RETURN qa_validation_api.ErrorArray;

--
-- 12.1 QWB Usability Improvements
-- added a new parameter, p_ssqr_opperation to ensure
-- that the validation is not done again at the time of
-- updting rows through QWB
--
FUNCTION update_row( p_plan_id                 IN  NUMBER,
                     p_spec_id                 IN  NUMBER,
                     p_org_id                  IN  NUMBER,
                     p_transaction_number      IN  NUMBER  DEFAULT NULL,
                     p_transaction_id          IN  NUMBER  DEFAULT NULL,
                     p_collection_id           IN  NUMBER,
                     p_who_last_updated_by     IN  NUMBER  := fnd_global.user_id,
                     p_who_created_by          IN  NUMBER  := fnd_global.user_id,
                     p_who_last_update_login   IN  NUMBER  := fnd_global.user_id,
                     p_enabled_flag            IN  NUMBER,
                     p_commit_flag             IN  BOOLEAN DEFAULT FALSE,
                     p_error_found             OUT NOCOPY BOOLEAN,
                     p_occurrence              IN  NUMBER,
                     p_do_action_return        OUT NOCOPY BOOLEAN,
                     p_message_array           OUT NOCOPY qa_validation_api.MessageArray,
                     p_row_elements            IN  OUT NOCOPY qa_validation_api.ElementsArray,
                     p_txn_header_id           IN  NUMBER DEFAULT NULL,
                     p_ssqr_operation          IN  NUMBER DEFAULT NULL,
                     p_last_update_date        IN  DATE DEFAULT SYSDATE)
    RETURN qa_validation_api.ErrorArray;

/* akbhatia- Bug 3345279 : Added a new procedure enable.*/

PROCEDURE enable( p_collection_id IN NUMBER);

END qa_results_api;


/
