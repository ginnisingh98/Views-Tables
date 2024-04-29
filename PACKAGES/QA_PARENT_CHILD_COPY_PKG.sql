--------------------------------------------------------
--  DDL for Package QA_PARENT_CHILD_COPY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_PARENT_CHILD_COPY_PKG" AUTHID CURRENT_USER as
/* $Header: qapccps.pls 120.0 2005/05/24 18:24:59 appldev noship $ */

   --this record type is used as the value in the plan_htable below for
   --tracking characteristics related to a copied plan
   TYPE plan_info IS RECORD (src_name   qa_plans.name%TYPE,
                             dest_name  qa_plans.name%TYPE,
                             dest_id    NUMBER);

   --this htable is used to keep track of the information parsed by setup_plans
   --from the flatstring passed to it
   TYPE plan_htable IS TABLE OF plan_info INDEX BY BINARY_INTEGER;
   TYPE id_htable IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   --special processing constants that should be the same in the Java that calls SETUP_PLANS
   SP_NCM CONSTANT VARCHAR2(3) := 'NCM';

   --record used by NCM special processing to store search text and replacment text
   TYPE ncm_repl_info IS RECORD (search_str1 VARCHAR2(30),
                                 repl_str1   VARCHAR2(30),
                                 search_str2 VARCHAR2(30),
                                 repl_str2   VARCHAR2(30),
                                 search_str3 VARCHAR2(30),
                                 repl_str3   VARCHAR2(30));
   TYPE ncm_repl_htable IS TABLE OF ncm_repl_info INDEX BY BINARY_INTEGER;

   --constants for NCM special processing, string to look for during action text replacement
   SP_NCM_COMMENT_CHAR CONSTANT VARCHAR2(1) := '/';
   SP_NCM_DELIM_CHAR1 CONSTANT VARCHAR2(1) := '''';
   SP_NCM_DELIM_CHAR2 CONSTANT VARCHAR2(1) := '"';
   SP_NCM_PLAN_NAME_SUFFIX CONSTANT VARCHAR2(30) := SP_NCM_COMMENT_CHAR||'*ORA$QA_PLAN_NAME*'||SP_NCM_COMMENT_CHAR;
   SP_NCM_VIEW_NAME_SUFFIX CONSTANT VARCHAR2(30) := SP_NCM_COMMENT_CHAR||'*ORA$QA_VIEW_NAME*'||SP_NCM_COMMENT_CHAR;
   SP_NCM_IMPORT_NAME_SUFFIX CONSTANT VARCHAR2(30) := SP_NCM_COMMENT_CHAR||'*ORA$QA_IMPORT_NAME*'||SP_NCM_COMMENT_CHAR;
   TYPE ncm_suffix_list_t IS TABLE OF VARCHAR(30);

   --this function copies the plan relationships, element relationships and criteria
   --associated with the source parent/child to the target parent/child tables
   --p_call_mapping is either fnd_api.g_true or fnd_api.g_false, it g_true then it calls the UI mapping code for
   --the new parent plan and new child plan
   --returns fnd_api.g_true on success, fnd_api.g_false on failure
   PROCEDURE COPY_ALL(p_source_parent_plan_id   IN  NUMBER,
                      p_source_child_plan_id    IN  NUMBER,
                      p_target_parent_plan_id   IN  NUMBER,
                      p_target_child_plan_id    IN  NUMBER,
                      p_call_mapping            IN  VARCHAR2,
                      x_return_status           OUT NOCOPY VARCHAR2);





   -- Bug 3926150. Performance: searching on softcoded element improved by functional indexes.
   -- Added new OUT parameter x_index_drop_list, which is a comma seperated list of collection
   -- element names whose functional index must be dropped/regenerated.
   -- Please see bugdb/design document for more details.
   -- srhariha. Tue Nov 30 11:59:20 PST 2004

   --This function is used by the self-service schema copy application to
   --perform the actual copy operations.
   --PARAMETERS:
   -- p_src_org_id         => source orgnization_id
   -- p_dest_org_code      => destination organization_code(code instead of name to match copy plan api)
   -- p_plans_flatstring   => an encoded string of the form:
   --                         <SrcPlanId1>=<SrcPlanName1>,<DestPlanName1>@<SrcPlanId2>=
   --                         <SrcPlanName2>,<DestPlanName2>@etc..
   -- p_root_plan_src_id   => plan_id of the root source plan
   -- x_root_plan_dest_id  => plan_id of the newly created destination root plan
   -- p_special_proc_field => string of the form <SpecialProc1>@<SpecialProc2>... containing special
   --                         processing identifiers that need to be applied to the duplicate schema
   -- p_disable_plans      => values: Y/N, if Y then set the 'Effective To' on all new plans to the past
   -- x_return_msg         => return message text that's useful when the function returns -1
   -- x_index_drop_list    => return comma sepearated list of collection element names whose
   --                         functional index must be dropped/regenerated.

   -- returns 0 on success, -1 on error
   FUNCTION SETUP_PLANS(p_src_org_id            IN  VARCHAR2,
                        p_dest_org_code         IN  VARCHAR2,
                        p_plans_flatstring      IN  VARCHAR2,
                        p_root_plan_src_id      IN  VARCHAR2,
                        x_root_plan_dest_id     OUT NOCOPY NUMBER,
                        p_special_proc_field    IN  VARCHAR2,
                        p_disable_plans         IN  VARCHAR2 DEFAULT NULL,
                        x_return_msg            OUT NOCOPY VARCHAR2,
                        x_index_drop_list       OUT NOCOPY VARCHAR2)
                        RETURN INTEGER;

END QA_PARENT_CHILD_COPY_PKG;

 

/
