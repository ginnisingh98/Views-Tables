--------------------------------------------------------
--  DDL for Package IGR_IN_JTF_INTERACTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGR_IN_JTF_INTERACTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSRT05S.pls 120.0 2005/06/01 17:49:26 appldev noship $ */

   /* This package contains global variables and common procedures pertaining to CRM Interaction History Population */
   -- the api version
   g_api_version   CONSTANT         NUMBER := 1.0;

   -- fnd_api.g_ret_sts_success
   g_ret_sts_success CONSTANT  VARCHAR2(1) :=  FND_API.G_RET_STS_SUCCESS;       -- 'S'

   -- fnd_api.g_ret_sts_error
   g_ret_sts_error CONSTANT    VARCHAR2(1) :=  FND_API.G_RET_STS_ERROR;         -- 'E'

   --  global constants representing TRUE and FALSE.
   g_true      CONSTANT    VARCHAR2(1) := FND_API.G_TRUE;       -- 'T'
   g_false     CONSTANT    VARCHAR2(1) := FND_API.G_FALSE;      -- 'F'

   g_user_id                        NUMBER;
   g_resource_id                    NUMBER;
   g_login_id                       NUMBER;
   g_resp_appl_id                   NUMBER;
   g_resp_id                        NUMBER;
   g_def_outcome_id                 jtf_ih_outcomes_vl.outcome_id%TYPE;
   g_def_outcome                    jtf_ih_outcomes_vl.short_description%TYPE;
   g_def_result_id                  jtf_ih_results_vl.result_id%TYPE;
   g_def_result                     jtf_ih_results_vl.short_description%TYPE;
   g_def_reason_id                  jtf_ih_reasons_vl.reason_id%TYPE;
   g_def_reason                     jtf_ih_reasons_vl.short_description%TYPE;
   g_int_id                         NUMBER      := NULL; -- Variable to store interaction id

PROCEDURE get_profile_values;
PROCEDURE start_interaction (p_person_id IN igs_pe_person_base_v.person_id%TYPE,
                             p_ret_status OUT NOCOPY VARCHAR2,
                             p_msg_data  OUT NOCOPY VARCHAR2,
                             p_msg_count OUT NOCOPY NUMBER ,
			     p_int_id    OUT NOCOPY NUMBER);
PROCEDURE start_int_and_act (
                        p_doc_ref	 IN VARCHAR2,
                        p_person_id      IN igs_pe_person_base_v.person_id%TYPE,
			p_sales_lead_id  IN as_sales_leads.sales_lead_id%TYPE DEFAULT NULL,
                        p_item_id	 IN igr_i_a_pkgitm.package_item_id%TYPE DEFAULT NULL,
			p_doc_id         IN NUMBER,
                        p_action         IN jtf_ih_actions_vl.action%TYPE DEFAULT NULL,
                        p_action_id      IN jtf_ih_actions_vl.action_id%TYPE DEFAULT NULL,
                        p_action_item    IN jtf_ih_action_items_vl.action_item%TYPE DEFAULT NULL,
                        p_action_item_id IN jtf_ih_action_items_vl.action_item_id%TYPE DEFAULT NULL,
                        p_ret_status     OUT NOCOPY VARCHAR2,
                        p_msg_data       OUT NOCOPY VARCHAR2,
                        p_msg_count      OUT NOCOPY NUMBER );

PROCEDURE add_activity(p_action                 IN VARCHAR2 DEFAULT NULL,
                       p_action_id              IN NUMBER DEFAULT NULL,
                       p_Action_item            IN VARCHAR2 DEFAULT NULL,
                       p_Action_item_id         IN NUMBER DEFAULT NULL,
                       p_doc_source_object_name IN VARCHAR2 DEFAULT NULL,
                       p_doc_id                 IN NUMBER DEFAULT NULL,
		       p_doc_ref                IN VARCHAR2 DEFAULT NULL,
                       p_outcome_id             IN NUMBER DEFAULT NULL,
                       p_result_id              IN NUMBER DEFAULT NULL,
                       p_reason_id              IN NUMBER DEFAULT NULL,
                       p_cust_account_id        IN NUMBER DEFAULT NULL,
		       p_int_id                 IN NUMBER DEFAULT NULL,
                       p_ret_status             OUT NOCOPY VARCHAR2,
                       p_msg_data               OUT NOCOPY VARCHAR2,
                       p_msg_count              OUT NOCOPY NUMBER );

PROCEDURE update_activity(p_activity_id         IN NUMBER,
                       p_action_id              IN VARCHAR2,
                       p_Action_item_id         IN VARCHAR2,
                       p_doc_source_object_name IN VARCHAR2,
                       p_outcome_id             IN NUMBER,
                       p_result_id              IN NUMBER,
                       p_reason_id              IN NUMBER,
                       p_ret_status             OUT NOCOPY VARCHAR2,
                       p_msg_data               OUT NOCOPY VARCHAR2,
                       p_msg_count              OUT NOCOPY NUMBER );

PROCEDURE end_interaction (p_ret_status OUT NOCOPY VARCHAR2,
                       p_msg_data  OUT NOCOPY VARCHAR2,
                       p_msg_count OUT NOCOPY NUMBER );

END Igr_in_jtf_interactions_pkg;

 

/
