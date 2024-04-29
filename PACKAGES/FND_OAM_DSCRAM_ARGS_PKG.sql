--------------------------------------------------------
--  DDL for Package FND_OAM_DSCRAM_ARGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_DSCRAM_ARGS_PKG" AUTHID CURRENT_USER as
/* $Header: AFOAMDSARGS.pls 120.3 2005/11/07 19:45 ilawler noship $ */

   -------------------
   -- Types/Constants
   -------------------

   -- entity representing an arg in an arg context or arg list
   TYPE arg IS RECORD (arg_id                   NUMBER,
                       arg_name                 VARCHAR2(60),
                       init_locally             BOOLEAN,        --indicator of whether the arg cache entity has been initialized
                       initialized_success_flag VARCHAR2(3),
                       allow_override_source    BOOLEAN,
                       binding_enabled          BOOLEAN,        --whether an arg corresponds to a bind variable
                       permissions              VARCHAR2(30),
                       write_policy             VARCHAR2(30),
                       datatype                 VARCHAR2(30),
                       valid_value_flag         VARCHAR2(3),    --need NULL for unknown, T=yes, F=value invalid, don't re-source
                       canonical_value          VARCHAR2(4000), --caches value for args with write_policy of ONCE or PER_WORKER
                       rowid_lbound             ROWID,
                       rowid_ubound             ROWID,
                       is_constant              BOOLEAN,        --derived, whether the arg is a constant and therefore requires special handling
                       source_cursor_id         INTEGER,
                       source_sql_bind_rowids   BOOLEAN,        --derived, whether cursor requires rowids to be bound
                       source_state_key         VARCHAR2(60),   --derived, the state key used for sourcing when source_type=state
                       source_use_exec_cursor   BOOLEAN         --derived, set when a writable arg has source_type=execution_cursor
                       );

   --arg context is a hash table of args keyed by name, passed from parent objects to supply dynamic
   --values for arguments
   TYPE arg_context IS TABLE OF arg INDEX BY VARCHAR2(60);

   --arg list is an unordered list of arguments used by leaf consumers (dml, plsql) to provide the
   --values needed for execution and reporting
   TYPE arg_list IS TABLE OF arg;

   ---------------------------------
   -- Public Procedures/Functions --
   ---------------------------------

   --Tests the permissions attribute to see if it's readable
   FUNCTION IS_READABLE(p_arg   IN arg)
      RETURN BOOLEAN;

   --Tests the permissions attribute to see if it's writable
   FUNCTION IS_WRITABLE(p_arg   IN arg)
      RETURN BOOLEAN;

   -- Debug method to print out an arg context.
   PROCEDURE PRINT_ARG_CONTEXT(px_arg_context           IN OUT NOCOPY arg_context);

   -- Pulls global and run scoped arguments and puts them into a context.  Does no init or get.
   PROCEDURE FETCH_RUN_ARG_CONTEXT(p_run_id             IN NUMBER,
                                   x_arg_context        OUT NOCOPY arg_context,
                                   x_return_status      OUT NOCOPY VARCHAR2,
                                   x_return_msg         OUT NOCOPY VARCHAR2);

   -- Getter for an arg's value as type VARCHAR2
   PROCEDURE GET_ARG_VALUE(px_arg                       IN OUT NOCOPY arg,
                           px_arg_context               IN OUT NOCOPY arg_context,
                           p_using_splitting            IN BOOLEAN DEFAULT FALSE,
                           p_rowid_lbound               IN ROWID DEFAULT NULL,
                           p_rowid_ubound               IN ROWID DEFAULT NULL,
                           p_execution_cursor_id        IN INTEGER DEFAULT NULL,
                           x_value                      OUT NOCOPY VARCHAR2,
                           x_return_status              OUT NOCOPY VARCHAR2,
                           x_return_msg                 OUT NOCOPY VARCHAR2);


   --Getter for an arg's value as type NUMBER
   PROCEDURE GET_ARG_VALUE(px_arg                       IN OUT NOCOPY arg,
                           px_arg_context               IN OUT NOCOPY arg_context,
                           p_using_splitting            IN BOOLEAN DEFAULT FALSE,
                           p_rowid_lbound               IN ROWID DEFAULT NULL,
                           p_rowid_ubound               IN ROWID DEFAULT NULL,
                           p_execution_cursor_id        IN INTEGER DEFAULT NULL,
                           x_value                      OUT NOCOPY NUMBER,
                           x_return_status              OUT NOCOPY VARCHAR2,
                           x_return_msg                 OUT NOCOPY VARCHAR2);

   --Getter for an arg's value as type DATE
   PROCEDURE GET_ARG_VALUE(px_arg                       IN OUT NOCOPY arg,
                           px_arg_context               IN OUT NOCOPY arg_context,
                           p_using_splitting            IN BOOLEAN DEFAULT FALSE,
                           p_rowid_lbound               IN ROWID DEFAULT NULL,
                           p_rowid_ubound               IN ROWID DEFAULT NULL,
                           p_execution_cursor_id        IN INTEGER DEFAULT NULL,
                           x_value                      OUT NOCOPY DATE,
                           x_return_status              OUT NOCOPY VARCHAR2,
                           x_return_msg                 OUT NOCOPY VARCHAR2);

   --Getter for an arg's value as type ROWID, needs different name since rowid/varchar2 interchangeable
   PROCEDURE GET_ARG_VALUE_ROWID(px_arg                 IN OUT NOCOPY arg,
                                 px_arg_context         IN OUT NOCOPY arg_context,
                                 p_using_splitting      IN BOOLEAN DEFAULT FALSE,
                                 p_rowid_lbound         IN ROWID DEFAULT NULL,
                                 p_rowid_ubound         IN ROWID DEFAULT NULL,
                                 p_execution_cursor_id  IN INTEGER DEFAULT NULL,
                                 x_value                OUT NOCOPY ROWID,
                                 x_return_status        OUT NOCOPY VARCHAR2,
                                 x_return_msg           OUT NOCOPY VARCHAR2);

   -- For DMLs/PLSQLs and any other consumer of arguments, we need a procedure to
   -- produce a list of arguments needed for dbms_sql binding.  This is done by fetching
   -- the argument list from the _ARGS_B table.  The arguments are wrapped up and returned with no processing.
   PROCEDURE FETCH_ARG_LIST(p_parent_type       IN VARCHAR2,
                            p_parent_id         IN NUMBER,
                            x_arg_list          OUT NOCOPY arg_list,
                            x_has_writable      OUT NOCOPY BOOLEAN,
                            x_return_status     OUT NOCOPY VARCHAR2,
                            x_return_msg        OUT NOCOPY VARCHAR2);

   -- Traverses the provided arg list and binds all readable/bindable args to the cursor using the arg_name field.
   PROCEDURE BIND_ARG_LIST_TO_CURSOR(p_arg_list         IN OUT NOCOPY arg_list,
                                     px_arg_context     IN OUT NOCOPY arg_context,
                                     p_cursor_id        IN INTEGER,
                                     p_using_splitting  IN BOOLEAN DEFAULT FALSE,
                                     p_rowid_lbound     IN ROWID DEFAULT NULL,
                                     p_rowid_ubound     IN ROWID DEFAULT NULL,
                                     x_return_status    OUT NOCOPY VARCHAR2,
                                     x_return_msg       OUT NOCOPY VARCHAR2);

   -- After an object has been executed, we should get values for all writable args - used for reporting purposes
   -- but also possible to collect data which is pushed to the context for use as a source by another unit. The
   -- p_entity_finished boolean allows us to collect ranged writable args at the end of each range and defer
   -- collecting write_once args till the entire work item is done.  The execution_cursor_id is provided to
   -- allow for sourcing from that object.
   PROCEDURE UPDATE_WRITABLE_ARG_VALUES(px_arg_list             IN OUT NOCOPY arg_list,
                                        px_arg_context          IN OUT NOCOPY arg_context,
                                        p_entity_finished       IN BOOLEAN DEFAULT FALSE,
                                        p_using_splitting       IN BOOLEAN DEFAULT FALSE,
                                        p_rowid_lbound          IN ROWID DEFAULT NULL,
                                        p_rowid_ubound          IN ROWID DEFAULT NULL,
                                        p_execution_cursor_id   IN INTEGER DEFAULT NULL,
                                        x_return_status         OUT NOCOPY VARCHAR2,
                                        x_return_msg            OUT NOCOPY VARCHAR2);

   -- Used by the work item destroy procedures to default values into the context from values in the arg list.  Only performs
   -- the update when the context has no value set and the arg list does and we allow overriding among other tests.
   PROCEDURE UPDATE_CONTEXT_USING_ARG_LIST(px_arg_context       IN OUT NOCOPY arg_context,
                                           p_arg_list           IN arg_list,
                                           p_using_splitting    IN BOOLEAN DEFAULT FALSE);

   --Used by consumers of arg lists to de-allocate the args in the list when finished.  Does not try to push
   --values to the arg list since this may be called purely as a cleanup procedure.
   PROCEDURE DESTROY_ARG_LIST(px_arg_list               IN OUT NOCOPY arg_list,
                              x_return_status           OUT NOCOPY VARCHAR2,
                              x_return_msg              OUT NOCOPY VARCHAR2);

   --Called whenever a context goes out of scope.  Before de-allocating, it combs the context
   --attemps to update any untouched, writable args.
   PROCEDURE DESTROY_ARG_CONTEXT(px_arg_context         IN OUT NOCOPY arg_context,
                                 x_return_status        OUT NOCOPY VARCHAR2,
                                 x_return_msg           OUT NOCOPY VARCHAR2);

   /*
   -- Pulls task-scoped args and overlays them on top of the run context
   -- V2: add a task and unit level context check to allow sharing args at this level,
   --       v1 just supports global/run
   FUNCTION FETCH_TASK_ARG_CONTEXT(p_unit_id    IN NUMBER)
      RETURN arg_context;
   -- Needed to push changed arguments from one context up to its parent context if
   -- a parent context arg exists with the same name and has a type that allows writing.
   FUNCTION ROLLUP_ARG_CTXT_INTO_PARENT_CTXT()
   */

   -- Bug #47007636 - ilawler - Mon Nov  7 15:03:41 2005
   -- Table handler required for translated entities to populate the _TL table when
   -- a new language is added to an environment.
   -- Invariants:
   --   None
   -- Parameters:
   --   None
   PROCEDURE ADD_LANGUAGE;

END FND_OAM_DSCRAM_ARGS_PKG;

 

/
