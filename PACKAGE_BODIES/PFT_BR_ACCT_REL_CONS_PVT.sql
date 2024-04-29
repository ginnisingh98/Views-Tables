--------------------------------------------------------
--  DDL for Package Body PFT_BR_ACCT_REL_CONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PFT_BR_ACCT_REL_CONS_PVT" AS
/* $Header: PFTVACCB.pls 120.0 2005/06/06 18:59:47 appldev noship $ */

--------------------------------------------------------------------------------
-- PRIVATE CONSTANTS
--------------------------------------------------------------------------------

G_PKG_NAME CONSTANT VARCHAR2(30) := 'PFT_BR_ACCT_REL_CONS_PVT;';

--------------------------------------------------------------------------------
-- PRIVATE SPECIFICATIONS
--------------------------------------------------------------------------------

PROCEDURE CopyAcctRelConsRec(
   p_source_obj_def_id   IN         NUMBER
  ,p_target_obj_def_id   IN         NUMBER
  ,p_created_by          IN         NUMBER
  ,p_creation_date       IN         DATE
);

PROCEDURE DeleteAcctRelConsRec(
  p_obj_def_id          IN          NUMBER
);

--------------------------------------------------------------------------------
-- PUBLIC BODIES
--------------------------------------------------------------------------------


--
-- PROCEDURE
--	 CopyObjectDefinition
--
-- DESCRIPTION
--   Creates all the detail records of a new Account Relationship Consolidation Rule Definition (target)
--   by copying the detail records of another Account Relationship Consolidation Rule Definition (source).
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyObjectDefinition(
   p_source_obj_def_id   IN         NUMBER
  ,p_target_obj_def_id   IN         NUMBER
  ,p_created_by          IN         NUMBER
  ,p_creation_date       IN         DATE
)
--------------------------------------------------------------------------------
IS

  G_API_NAME    CONSTANT VARCHAR2(30)   := 'CopyObjectDefinition';

BEGIN


  CopyAcctRelConsRec(
     p_source_obj_def_id  => p_source_obj_def_id
    ,p_target_obj_def_id  => p_target_obj_def_id
    ,p_created_by         => p_created_by
    ,p_creation_date      => p_creation_date
  );


EXCEPTION

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, G_API_NAME);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

END CopyObjectDefinition;


--
-- PROCEDURE
--	 DeleteObjectDefinition
--
-- DESCRIPTION
--   Deletes all the details records of a Account Relationship Consolidation Rule Definition.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteObjectDefinition(
  p_obj_def_id          IN          NUMBER
)
--------------------------------------------------------------------------------
IS

  G_API_NAME    CONSTANT VARCHAR2(30)   := 'DeleteObjectDefinition';

BEGIN

  DeleteAcctRelConsRec(
    p_obj_def_id  =>  p_obj_def_id
  );

EXCEPTION

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, G_API_NAME);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

END DeleteObjectDefinition;



--------------------------------------------------------------------------------
-- PRIVATE BODIES
--------------------------------------------------------------------------------



--
-- PROCEDURE
--	 CopyAcctRelConsRec
--
-- DESCRIPTION
--   Creates a new Account Relationship Consolidation Rule Definition Formula by copying records in the
--   PFT_ACCT_REL_CONS_RULES table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyAcctRelConsRec(
  p_source_obj_def_id   IN          NUMBER
  ,p_target_obj_def_id  IN          NUMBER
  ,p_created_by         IN          NUMBER
  ,p_creation_date      IN          DATE
)
--------------------------------------------------------------------------------
IS
BEGIN

  INSERT INTO PFT_ACCT_REL_CONS_RULES (
     acct_rel_cons_obj_def_id
    ,processing_table
    ,condition_obj_id
    ,load_secondary_rel_flag
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,object_version_number
    ,col_tmplt_obj_id
  ) SELECT
    p_target_obj_def_id
    ,processing_table
    ,condition_obj_id
    ,load_secondary_rel_flag
    ,NVL(p_created_by,created_by)
    ,NVL(p_creation_date,creation_date)
    ,FND_GLOBAL.user_id
    ,SYSDATE
    ,FND_GLOBAL.login_id
    ,object_version_number
    ,col_tmplt_obj_id
  FROM pft_acct_rel_cons_rules
  WHERE acct_rel_cons_obj_def_id = p_source_obj_def_id;

END CopyAcctRelConsRec;

--
-- PROCEDURE
--	 DeletAcctRelConsRec
--
-- DESCRIPTION
--   Deletes a Account Relationship Consolidation Rule Definition by performing deletes on records
--   in the PFT_ACCT_REL_CONS_RULES table.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteAcctRelConsRec(
  p_obj_def_id IN NUMBER
)
--------------------------------------------------------------------------------
IS
BEGIN

  DELETE FROM pft_acct_rel_cons_rules
  WHERE acct_rel_cons_obj_def_id = p_obj_def_id;

END DeleteAcctRelConsRec;


END PFT_BR_ACCT_REL_CONS_PVT;

/
