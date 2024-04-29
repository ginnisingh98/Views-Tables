--------------------------------------------------------
--  DDL for Package GCS_CONS_ENGINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_CONS_ENGINE_PKG" AUTHID CURRENT_USER as
/* $Header: gcs_eng_wfs.pls 120.1 2005/06/07 21:50:53 skamdar noship $ */

  --
  -- Procedure
  --   prepare_immediate_children()
  -- Purpose
  --   Prepares Immediate Children (Operating and Consolidation Entities)
  -- Arguments
  --   item_type                type of the current item
  --   item_key                 key of the current item
  --   actid                    process activity instance id
  --   funcmode                 function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
  --   result
  --       COMPLETE
  -- Notes
  --

  PROCEDURE prepare_immediate_children(	itemtype		IN VARCHAR2,
  					itemkey			IN VARCHAR2,
  					actid			IN NUMBER,
  					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2);

  --
  -- Procedure
  --   spawn_oper_entity_process()
  -- Purpose
  --   Spawns the operating entity process for all immediate children of the Consolidation Entity
  -- Arguments
  --   item_type                type of the current item
  --   item_key                 key of the current item
  --   actid                    process activity instance id
  --   funcmode                 function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
  --   result
  --       COMPLETE[:T or :F]
  -- Notes
  --

  PROCEDURE spawn_oper_entity_process(	itemtype		IN VARCHAR2,
  					itemkey			IN VARCHAR2,
  					actid			IN NUMBER,
					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2);


  --
  -- Procedure
  --   execute_data_preparation()
  -- Purpose
  --   Execute Data Preparation for a specific entity
  -- Arguments
  --   item_type                type of the current item
  --   item_key                 key of the current item
  --   actid                    process activity instance id
  --   funcmode                 function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
  --   result
  --       COMPLETE[:T or :F]
  -- Notes
  --

  PROCEDURE execute_data_preparation(	itemtype		IN VARCHAR2,
  					itemkey			IN VARCHAR2,
  					actid			IN NUMBER,
  					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2);


  --
  -- Procedure
  --   check_aggregation_required()
  -- Purpose
  --   Checks if Aggregation is Required
  -- Arguments
  --   item_type                type of the current item
  --   item_key                 key of the current item
  --   actid                    process activity instance id
  --   funcmode                 function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
  --   result
  --       COMPLETE[:T or :F]
  -- Notes
  --
  PROCEDURE check_aggregation_required(	itemtype		IN VARCHAR2,
  					itemkey			IN VARCHAR2,
  					actid			IN NUMBER,
  					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2);

  --
  -- Procedure
  --   execute_aggregation()
  -- Purpose
  --   Executes Aggregation for a Consolidation Entity
  -- Arguments
  --   item_type                type of the current item
  --   item_key                 key of the current item
  --   actid                    process activity instance id
  --   funcmode                 function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
  --   result
  --       COMPLETE
  --       WAITING
  --       DEFERRED
  --       NOTIFIED
  --       ERROR
  -- Notes
  --

  PROCEDURE execute_aggregation(	itemtype		IN VARCHAR2,
  					itemkey			IN VARCHAR2,
  					actid			IN NUMBER,
  					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2);

  --
  -- Procedure
  --   raise_completion_event()
  -- Purpose
  --   Raises Completion Event for a Consolidation
  -- Arguments
  --   item_type                type of the current item
  --   item_key                 key of the current item
  --   actid                    process activity instance id
  --   funcmode                 function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
  --   result
  --       COMPLETE
  -- Notes
  --
  PROCEDURE raise_completion_event(		itemtype		IN VARCHAR2,
  						itemkey			IN VARCHAR2,
  						actid			IN NUMBER,
  						funcmode		IN varchar2,
  						result			IN OUT NOCOPY varchar2);

  --
  -- Procedure
  --   spawn_cons_entity_process()
  -- Purpose
  --   Spawns consolidation entity process for all immediate children of the Consolidation Entity
  -- Arguments
  --   item_type                type of the current item
  --   item_key                 key of the current item
  --   actid                    process activity instance id
  --   funcmode                 function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
  --   result
  --       COMPLETE[:T or :F]
  -- Notes
  --

  PROCEDURE spawn_cons_entity_process(	itemtype		IN VARCHAR2,
  					itemkey			IN VARCHAR2,
  					actid			IN NUMBER,
					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2);

  --
  -- Procedure
  --   init_oper_entity_process()
  -- Purpose
  --   Checks which mode of data prep needs to be executed
  -- Arguments
  --   item_type                type of the current item
  --   item_key                 key of the current item
  --   actid                    process activity instance id
  --   funcmode                 function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
  --   result
  --       COMPLETE[:FULL or :INCREMENTAL]
  --       WAITING
  --       DEFERRED
  --       NOTIFIED
  --       ERROR
  -- Notes
  --
  PROCEDURE init_oper_entity_process(	itemtype		IN VARCHAR2,
  					itemkey			IN VARCHAR2,
  					actid			IN NUMBER,
  					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2);

  --
  -- Procedure
  --   initialize_cons_process()
  -- Purpose
  --   Inserts all Categories into RUN_DETAILS for a Consolidation Entity
  -- Arguments
  --   item_type                type of the current item
  --   item_key                 key of the current item
  --   actid                    process activity instance id
  --   funcmode                 function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
  --   result
  --       COMPLETE[]
  -- Notes
  --
  PROCEDURE initialize_cons_process(	itemtype		IN VARCHAR2,
  					itemkey			IN VARCHAR2,
  					actid			IN NUMBER,
					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2);

  --
  -- Procedure
  --   check_cons_entity_status()
  -- Purpose
  --   Checks if a Consolidation Entity requires a rerun
  -- Arguments
  --   item_type                type of the current item
  --   item_key                 key of the current item
  --   actid                    process activity instance id
  --   funcmode                 function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
  --   result
  --       COMPLETE[:T or :F]
  -- Notes
  --
  PROCEDURE check_cons_entity_status(	itemtype		IN VARCHAR2,
  					itemkey			IN VARCHAR2,
  					actid			IN NUMBER,
					funcmode		IN varchar2,
  					result			IN OUT NOCOPY varchar2);

  --
  -- Procedure
  --   retrieve_prior_runs()
  -- Purpose
  --   Copies data for a prior run
  -- Arguments
  --   item_type                type of the current item
  --   item_key                 key of the current item
  --   actid                    process activity instance id
  --   funcmode                 function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
  --   result
  --       COMPLETE[]
  -- Notes
  --
  PROCEDURE retrieve_prior_runs(   	itemtype                IN VARCHAR2,
                                        itemkey                 IN VARCHAR2,
                                        actid                   IN NUMBER,
                                        funcmode                IN varchar2,
                                        result                  IN OUT NOCOPY varchar2);

END GCS_CONS_ENGINE_PKG;

 

/
