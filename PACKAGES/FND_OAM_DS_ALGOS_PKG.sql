--------------------------------------------------------
--  DDL for Package FND_OAM_DS_ALGOS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_DS_ALGOS_PKG" AUTHID CURRENT_USER as
/* $Header: AFOAMDSALGOS.pls 120.3 2006/01/17 11:40 ilawler noship $ */

   ---------------
   -- Constants --
   ---------------

   ---------------------------------
   -- Public Procedures/Functions --
   ---------------------------------

   -- This function converts an algorithm name into its corresponding ID. This method does not
   -- traverse the use_algo_id.
   -- Invariants:
   --   None.
   -- Parameter(s):
   --   p_display_name          Algorithm Display Name to lookup
   -- Returns:
   --   Corresponding algo_id for the name.
   -- Exception(s):
   --   NO_DATA_FOUND           Thrown when the algo_name is null or not found.
   FUNCTION GET_ALGO_ID(p_display_name  IN VARCHAR2)
      RETURN NUMBER;

   -- This API is used to resolve an algorithm ID into value text that can be directly inserted into a SQL statement.
   -- Invariants:
   --   None.
   -- Parameter(s):
   --   p_algo_id               Algorithm ID to resolve
   --   p_table_owner           Used for algorithm token substitution, represents the owner of the target table.
   --   p_table_name            Used for algorithm token substitution, represents the target table.
   --   p_column_name           Used for algorithm token substitution, represents the target column in the target table.
   --   x_new_column_value      SQL Text that can be inserted directly into a SQL statement.
   -- Exception(s):
   --   NO_DATA_FOUND           Thrown when the algo_id is invalid.
   --   VALUE_ERROR             When the resolved algo text is beyond the max length.
   PROCEDURE RESOLVE_ALGO_ID(p_algo_id                  IN NUMBER,
                             p_table_owner              IN VARCHAR2 DEFAULT NULL,
                             p_table_name               IN VARCHAR2 DEFAULT NULL,
                             p_column_name              IN VARCHAR2 DEFAULT NULL,
                             x_new_column_value         OUT NOCOPY VARCHAR2,
                             x_weight_modifier          OUT NOCOPY NUMBER);

   -- This API is used to lookup the default algorithm for a given datatype.  Uses the DEFAULT_FOR_DATATYPE_FLAG in
   -- the DS_ALGOS_B table.
   -- Invariants:
   --   None.  Low enough level that there's no safety harness to higher state.
   -- Parameter(s):
   --   p_datatype              Datatype from DSCFG_API_PKG.G_DATATYPE_*
   --
   --   x_algo_id               Found default algorithm ID.
   -- Exception(s):
   --   NO_DATA_FOUND           Thrown when no default is flagged
   --   TOO_MANY_ROWS           Thrown when more than one algorithm is marked as the default
   PROCEDURE GET_DEFAULT_ALGO_FOR_DATATYPE(p_datatype   IN VARCHAR2,
                                           x_algo_id    OUT NOCOPY NUMBER);


   --procedures required by FNDLOADER

  procedure LOAD_ROW (
      X_ALGO_ID             in NUMBER,
      X_START_DATE          IN DATE,
      X_END_DATE            IN DATE,
      X_USE_ALGO_ID         IN NUMBER,
      X_DEFAULT_FOR_DATATYPE_FLAG IN VARCHAR2,
      X_DATATYPE            IN VARCHAR2,
      X_ALGO_TEXT           IN VARCHAR2,
      X_WEIGHT_MODIFIER     IN NUMBER,
      X_OWNER               in VARCHAR2,
        X_DISPLAY_NAME        IN VARCHAR2,
      X_DESCRIPTION         IN VARCHAR2,
      x_custom_mode         in varchar2,
      x_last_update_date    in varchar2);

 procedure LOAD_ROW (
      X_ALGO_ID             in NUMBER,
      X_START_DATE          IN DATE,
      X_END_DATE            IN DATE,
      X_USE_ALGO_ID         IN NUMBER,
      X_DEFAULT_FOR_DATATYPE_FLAG IN VARCHAR2,
      X_DATATYPE            IN VARCHAR2,
      X_ALGO_TEXT           IN VARCHAR2,
      X_WEIGHT_MODIFIER     IN NUMBER,
      X_OWNER               in VARCHAR2,
        X_DISPLAY_NAME        IN VARCHAR2,
      X_DESCRIPTION         IN VARCHAR2);


   procedure TRANSLATE_ROW (
      X_ALGO_ID             in NUMBER,
        X_DISPLAY_NAME        IN VARCHAR2,
      X_DESCRIPTION         IN VARCHAR2,
      X_OWNER               in  VARCHAR2,
      X_CUSTOM_MODE                   in        VARCHAR2,
      X_LAST_UPDATE_DATE          in    VARCHAR2);

   procedure TRANSLATE_ROW (
      X_ALGO_ID             in NUMBER,
        X_DISPLAY_NAME        IN VARCHAR2,
      X_DESCRIPTION         IN VARCHAR2,
      X_OWNER               in  VARCHAR2);

  procedure INSERT_ROW (
      X_ROWID               in out nocopy VARCHAR2,
      X_ALGO_ID             in NUMBER,
        X_DISPLAY_NAME        IN VARCHAR2,
      X_DESCRIPTION         IN VARCHAR2,
      X_START_DATE          IN DATE,
      X_END_DATE            IN DATE,
      X_USE_ALGO_ID         IN NUMBER,
      X_DEFAULT_FOR_DATATYPE_FLAG IN VARCHAR2,
      X_DATATYPE            IN VARCHAR2,
      X_ALGO_TEXT           IN VARCHAR2,
      X_WEIGHT_MODIFIER     IN NUMBER,
      X_CREATED_BY          in NUMBER,
      X_CREATION_DATE       in DATE,
      X_LAST_UPDATED_BY     in NUMBER,
      X_LAST_UPDATE_DATE    in DATE,
      X_LAST_UPDATE_LOGIN   in NUMBER);

  procedure LOCK_ROW (
      X_ROWID               in out nocopy VARCHAR2,
      X_ALGO_ID             in NUMBER,
        X_DISPLAY_NAME        IN VARCHAR2,
      X_DESCRIPTION         IN VARCHAR2,
      X_START_DATE          IN DATE,
      X_END_DATE            IN DATE,
      X_USE_ALGO_ID         IN NUMBER,
      X_DEFAULT_FOR_DATATYPE_FLAG IN VARCHAR2,
      X_DATATYPE            IN VARCHAR2,
      X_ALGO_TEXT           IN VARCHAR2,
      X_WEIGHT_MODIFIER     IN NUMBER,
      X_CREATED_BY          in NUMBER,
      X_CREATION_DATE       in DATE,
      X_LAST_UPDATED_BY     in NUMBER,
      X_LAST_UPDATE_DATE    in DATE,
      X_LAST_UPDATE_LOGIN   in NUMBER);

  procedure UPDATE_ROW (
      X_ALGO_ID             in NUMBER,
        X_DISPLAY_NAME        IN VARCHAR2,
      X_DESCRIPTION         IN VARCHAR2,
      X_START_DATE          IN DATE,
      X_END_DATE            IN DATE,
      X_USE_ALGO_ID         IN NUMBER,
      X_DEFAULT_FOR_DATATYPE_FLAG IN VARCHAR2,
      X_DATATYPE            IN VARCHAR2,
      X_ALGO_TEXT           IN VARCHAR2,
      X_WEIGHT_MODIFIER     IN NUMBER,
      X_LAST_UPDATED_BY     in NUMBER,
      X_LAST_UPDATE_DATE    in DATE,
      X_LAST_UPDATE_LOGIN   in NUMBER);


  procedure DELETE_ROW (
      X_ALGO_ID           in NUMBER);

  procedure ADD_LANGUAGE;

  procedure TRANSLATE_ROW
  (
      x_ALGO_ID             in NUMBER,
      x_DISPLAY_NAME        in varchar2,
      X_LAST_UPDATED_BY     in NUMBER,
      X_LAST_UPDATE_DATE    in DATE,
      X_LAST_UPDATE_LOGIN   in NUMBER);

END FND_OAM_DS_ALGOS_PKG;

 

/
