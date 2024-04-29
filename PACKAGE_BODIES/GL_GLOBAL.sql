--------------------------------------------------------
--  DDL for Package Body GL_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLOBAL" as
/* $Header: glustglb.pls 120.5 2005/11/22 19:34:47 spala ship $ */

  --
  -- PRIVATE VARIABLES
  --

  -- Current ledger id
     current_ledger_id  NUMBER;

  --
  -- PUBLIC FUNCTIONS
  --

  PROCEDURE  set_aff_validation (context_type VARCHAR2,
                                 context_id   NUMBER)
                                IS
   l_profile_increment  NUMBER;
   l_old_prof_val      	NUMBER;


  BEGIN


     IF (Context_Type = 'LG') THEN

          current_ledger_id := Context_Id;

       ELSIF (Context_Type = 'OU') THEN

           SELECT set_of_books_id INTO current_ledger_id
           FROM   HR_OPERATING_UNITS
           WHERE  organization_id = Context_Id;

       ELSIF(Context_Type = 'LE') THEN

           SELECT prilgr.ledger_id
           INTO   current_ledger_id
           FROM   GL_LEDGER_CONFIG_DETAILS cfgDet,
                  GL_LEDGER_CONFIGURATIONS cfg,
                  GL_LEDGERS Prilgr
           WHERE  cfgDet.object_id = Context_Id
           AND    cfgDet.object_type_code  = 'LEGAL_ENTITY'
           AND    cfgDet.configuration_id  = cfg.configuration_id
           AND    cfg.configuration_id = prilgr.configuration_id
           AND    prilgr.ledger_category_code = 'PRIMARY';

      ELSIF(Context_Type = 'XX') THEN

       current_ledger_id := NULL;

      ELSE

            RAISE NO_DATA_FOUND;

      END IF;

     EXCEPTION
         WHEN NO_DATA_FOUND THEN

          IF ( context_type = 'OU') THEN
            FND_MESSAGE.Set_Name('SQLGL', 'GL_GLOBAL_INVALID_OU');
            -- Operating unit _OP_UNIT does not exist in the target database.
            FND_MESSAGE.Set_Token('OP_UNIT',TO_CHAR(Context_Id));
            APP_EXCEPTION.Raise_Exception;
          ELSIF ( context_type = 'LE') THEN
            FND_MESSAGE.Set_Name('SQLGL', 'GL_GLOBAL_INVALID_LE');
            -- Legal entity  _LE does not exist in the target database.
            FND_MESSAGE.Set_Token('LE',TO_CHAR(Context_Id));
            APP_EXCEPTION.Raise_Exception;
          ELSIF ((context_type <> 'LG') OR (context_type <> 'XX')) THEN
            APP_EXCEPTION.Raise_Exception;
          END IF;

        WHEN OTHERS THEN
           APP_EXCEPTION.Raise_Exception;

   END set_aff_validation;

  --
  -- Function
  --   Context_Ledger_Id
  -- Purpose
  --   Returns set context ledger_id
  --
  --
  -- History
  --   02-AUG-05  Srini Pala   Created
  --
  --
  -- Arguments
  --
  --
  -- Example
  --   gl_global.Context_Ledger_Id;
  -- Notes
  --

  Function Context_Ledger_Id Return NUMBER IS
   BEGIN
      Return current_ledger_id;
   EXCEPTION
     WHEN OTHERS THEN
      APP_EXCEPTION.raise_exception;
  END Context_Ledger_Id;

END GL_GLOBAL;

/
