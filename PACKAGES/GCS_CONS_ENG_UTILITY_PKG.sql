--------------------------------------------------------
--  DDL for Package GCS_CONS_ENG_UTILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_CONS_ENG_UTILITY_PKG" AUTHID CURRENT_USER as
/* $Header: gcs_eng_utils.pls 120.5 2007/08/31 16:30:44 hakumar noship $ */

  TYPE r_cons_entity_wf_info IS RECORD
                                (consolidation_hierarchy                        NUMBER(15),
                                 consolidation_entity                           NUMBER(15),
                                 run_identifier                                 VARCHAR2(80),
                                 cal_period_id                                  NUMBER,
                                 cal_period_end_date                            DATE,
                                 balance_type_code                              VARCHAR2(30),
                                 run_detail_id                                  NUMBER(15),
                                 process_method                                 VARCHAR2(30),
                                 num_of_categories                              NUMBER(15),
                                 curr_category_num                              NUMBER(15),
                                 cons_relationship_id                           NUMBER(15),
                                 prior_run_identifier                           VARCHAR2(80),
                                 xlate_entry_id                                 NUMBER(15),
                                 request_id                                     NUMBER(15),
                                 --Bugfix 5017120: Added support for data types
                                 source_dataset_code                            NUMBER,
                                 hierarchy_dataset_code                         NUMBER,
                                 -- Bugfix 5569522: Added for business process kick-off support
                                 analysis_cycle_id                              NUMBER);



   TYPE r_oper_entity_wf_info IS RECORD
                                 (parent_workflow_key                           VARCHAR2(400),
                                 operating_entity                               NUMBER(15),
                                 cons_relationship_id                           NUMBER(15),
                                 run_detail_id                                  NUMBER(15),
                                 translation_required                           VARCHAR2(1),
                                 xlate_entry_id                                 NUMBER(15));


   TYPE r_module_parameters IS RECORD
                                 (errbuf                                        VARCHAR2(2000),
                                 retcode                                        VARCHAR2(2000),
                                 cal_period_id                                  NUMBER,
                                 run_name                                       VARCHAR2(240),
                                 category_code                                  VARCHAR2(30),
                                 hierarchy_id                                   NUMBER(15),
                                 balance_type_code                              VARCHAR2(30),
                                 entry_id                                       NUMBER(15),
                                 xlate_entry_id                                 NUMBER(15),
                                 xlate_mode                                     VARCHAR2(30),
                                 run_detail_id                                  NUMBER(15),
                                 cons_entity_id                                 NUMBER(15),
                                 child_entity_id                                NUMBER(15),
                                 cons_relationship_id                           NUMBER(15),
                                 period_end_date                                DATE,
                                 stat_required                                  VARCHAR2(1),
                                 bp_undo_prior                                  VARCHAR2(1),
                                 intercompany_mode                              VARCHAR2(2),
                                 bp_post_xlate                                  VARCHAR2(1),
                                 elim_rule_id                                   NUMBER(15),
                                 rp_parameters                                  gcs_rules_processor.contextRecord,
                                 rp_rule_data                                   gcs_rules_processor.ruleDataRecord,
                                 currency_code                                  VARCHAR2(30),
                                 bp_mode                                        VARCHAR2(1),
                                 -- Bugfix 3818829 : Added Two additional modules parameters
                                 undo_entity_type                               VARCHAR2(30),
                                 undo_entity_id                                 NUMBER(15),
                                 -- Bugfix 5017120 : Added Support for data types
                                 source_dataset_code                            NUMBER,
                                 hierarchy_dataset_code                         NUMBER);

  --
  -- Procedure
  --   execute_module()
  -- Purpose
  --   Wrapper around the individual engines to execute them in autonomous transactions
  -- Arguments
  --   module_code		VARCHAR2 (i.e. DATAPREPARATION, INTERCOMPANY, etc)
  --   p_parameter_list		Parameters required for the module
  --   p_item_key		Item Key of the Workflow Process
  -- Notes
  --
   PROCEDURE execute_module (module_code			IN VARCHAR2,
   			     p_parameter_list			IN OUT NOCOPY gcs_cons_eng_utility_pkg.r_module_parameters,
   			     p_item_key				IN VARCHAR2);

  --
  -- Procedure
  --   get_cons_entity_wf_info()
  -- Purpose
  --   Retrieves all the item type attributes for a Consolidation Entity Process
  -- Arguments
  --   item_type                type of the current item
  --   item_key                 key of the current item
  --   cons_entity_wf_info	Record of Item Type Attributes
  -- Notes
  --
   PROCEDURE get_cons_entity_wf_info (itemtype			IN VARCHAR2,
   				      itemkey			IN VARCHAR2,
   				      cons_entity_wf_info	IN OUT NOCOPY r_cons_entity_wf_info);

  --
  -- Procedure
  --   get_oper_entity_wf_info()
  -- Purpose
  --   Retrieves all the item type attributes for an Operating Entity Process
  -- Arguments
  --   item_type                type of the current item
  --   item_key                 key of the current item
  --   cons_entity_wf_info	Record of Consolidation Entity Level Attributes
  --   oper_entity_wf_info	Record of Operating Entity Level Attributes
  -- Notes
  --
   PROCEDURE get_oper_entity_wf_info (itemtype			IN VARCHAR2,
   				      itemkey			IN VARCHAR2,
   				      cons_entity_wf_info	IN OUT NOCOPY r_cons_entity_wf_info,
   				      oper_entity_wf_info	IN OUT NOCOPY r_oper_entity_wf_info);

  --
  -- Procedure
  --   balances_processor()
  -- Purpose
  --   Executes the balances processor
  -- Arguments
  --   item_type                type of the current item
  --   item_key                 key of the current item
  --   actid                    process activity instance id
  --   funcmode                 function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
  --   result
  --       COMPLETE[]
  -- Notes
  --

   PROCEDURE balances_processor	(	itemtype		IN VARCHAR2,
  					itemkey			IN VARCHAR2,
  					actid			IN NUMBER,
  					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2);

  --
  -- Procedure
  --   check_adj_required()
  -- Purpose
  --   Check if any adjustment categories exist, or if an adjustment is required
  -- Arguments
  --   item_type                type of the current item
  --   item_key                 key of the current item
  --   actid                    process activity instance id
  --   funcmode                 function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
  --   result
  --       COMPLETE[:T or :F]
  -- Notes
  --
   PROCEDURE check_adj_required	(	itemtype		IN VARCHAR2,
  					itemkey			IN VARCHAR2,
  					actid			IN NUMBER,
  					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2);

  --
  -- Procedure
  --   extract_manual_adj()
  -- Purpose
  --   Extract Manual Adjustments to be Applied
  -- Arguments
  --   item_type                type of the current item
  --   item_key                 key of the current item
  --   actid                    process activity instance id
  --   funcmode                 function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
  --   result
  --       COMPLETE[]
  -- Notes
  --
   PROCEDURE extract_manual_adj(	itemtype		IN VARCHAR2,
  					itemkey			IN VARCHAR2,
  					actid			IN NUMBER,
  					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2);

  --
  -- Procedure
  --   check_translation_required()
  -- Purpose
  --   Check if Translation is Required
  -- Arguments
  --   item_type                type of the current item
  --   item_key                 key of the current item
  --   actid                    process activity instance id
  --   funcmode                 function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
  --   result
  --       COMPLETE[:T or :F]
  -- Notes
  --
   PROCEDURE check_translation_required(	itemtype		IN VARCHAR2,
  					itemkey			IN VARCHAR2,
  					actid			IN NUMBER,
  					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2);
  --
  -- Procedure
  --   update_process_status()
  -- Purpose
  --   Update the process status based on dependencies
  -- Arguments
  --   item_type                type of the current item
  --   item_key                 key of the current item
  --   actid                    process activity instance id
  --   funcmode                 function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
  --   result
  --       COMPLETE[]
  -- Notes
  --
   PROCEDURE update_process_status(	itemtype		IN VARCHAR2,
  					itemkey			IN VARCHAR2,
  					actid			IN NUMBER,
					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2);

  --
  -- Procedure
  --   execute_translation()
  -- Purpose
  --   Wrapper around the Translation Engine
  -- Arguments
  --   item_type                type of the current item
  --   item_key                 key of the current item
  --   actid                    process activity instance id
  --   funcmode                 function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
  --   result
  --       COMPLETE[]
  -- Notes
  --

   PROCEDURE execute_translation(	itemtype		IN VARCHAR2,
  					itemkey			IN VARCHAR2,
  					actid			IN NUMBER,
  					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2);

  --
  -- Procedure
  --   eliminations_processor()
  -- Purpose
  --   Wrapper around the rules processor / intercompany engine
  -- Arguments
  --   item_type                type of the current item
  --   item_key                 key of the current item
  --   actid                    process activity instance id
  --   funcmode                 function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
  --   result
  --       COMPLETE[]
  -- Notes
  --

   PROCEDURE eliminations_processor(	itemtype		IN VARCHAR2,
  				        itemkey			IN VARCHAR2,
  				        actid			IN NUMBER,
					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2);

  --
  -- Procedure
  --   category_exists()
  -- Purpose
  --   Checks if additional categories exist
  -- Arguments
  --   item_type                type of the current item
  --   item_key                 key of the current item
  --   actid                    process activity instance id
  --   funcmode                 function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
  --   result
  --       COMPLETE[:F or :T]
  -- Notes
  --

   PROCEDURE category_exists(		itemtype		IN VARCHAR2,
  					itemkey			IN VARCHAR2,
  					actid			IN NUMBER,
  					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2);

  --
  -- Procedure
  --   check_max_category()
  -- Purpose
  --   Checks if the max category has been reached
  -- Arguments
  --   item_type                type of the current item
  --   item_key                 key of the current item
  --   actid                    process activity instance id
  --   funcmode                 function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
  --   result
  --       COMPLETE[:T or :F]
  -- Notes
  --
   PROCEDURE check_max_category(	itemtype		IN VARCHAR2,
  					itemkey			IN VARCHAR2,
  					actid			IN NUMBER,
  					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2);

  --
  -- Procedure
  --   create_initializing_journal()
  -- Purpose
  --   Creates the initializing journal
  -- Arguments
  --   item_type                type of the current item
  --   item_key                 key of the current item
  --   actid                    process activity instance id
  --   funcmode                 function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
  --   result
  --       COMPLETE[]
  -- Notes
  --
   PROCEDURE create_initializing_journal(	itemtype		IN VARCHAR2,
  						itemkey			IN VARCHAR2,
  						actid			IN NUMBER,
  						funcmode		IN varchar2,
  						result			IN OUT NOCOPY varchar2);
  --
  -- Procedure
  --   submit_xml_ntf_program
  -- Purpose
  --   Submits the XML and Notification Concurrent Program Utility
  -- Arguments
  --   p_run_name	 	Process Identifier
  --   p_cons_entity_id		Consolidation Entity
  --   p_category_code		Category Code
  --   p_child_entity_id	Child Entity
  --   p_run_detail_id		Run Detail

   PROCEDURE submit_xml_ntf_program(p_run_name                    IN VARCHAR2,
                                    p_cons_entity_id              IN NUMBER,
                                    p_category_code               IN VARCHAR2,
                                    p_child_entity_id             IN NUMBER     DEFAULT NULL,
                                    p_run_detail_id               IN NUMBER     DEFAULT NULL);


END GCS_CONS_ENG_UTILITY_PKG;


/
