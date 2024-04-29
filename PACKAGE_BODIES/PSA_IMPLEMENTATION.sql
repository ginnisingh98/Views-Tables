--------------------------------------------------------
--  DDL for Package Body PSA_IMPLEMENTATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSA_IMPLEMENTATION" AS
/* $Header: PSAMFIMB.pls 120.5 2006/09/13 13:11:04 agovil ship $ */

   --===========================FND_LOG.START=====================================
   g_state_level NUMBER	:=	FND_LOG.LEVEL_STATEMENT;
   g_proc_level  NUMBER	:=	FND_LOG.LEVEL_PROCEDURE;
   g_event_level NUMBER	:=	FND_LOG.LEVEL_EVENT;
   g_excep_level NUMBER	:=	FND_LOG.LEVEL_EXCEPTION;
   g_error_level NUMBER	:=	FND_LOG.LEVEL_ERROR;
   g_unexp_level NUMBER	:=	FND_LOG.LEVEL_UNEXPECTED;
   g_path        VARCHAR2(50)  := 'PSA.PLSQL.PSAMFIMB.PSA_IMPLEMENTATION.';
   --===========================FND_LOG.END=======================================
 --
  FUNCTION get 	(p_org_id       IN  INTEGER,
                 p_psa_feature  IN  VARCHAR2,
                 p_enabled_flag OUT NOCOPY VARCHAR2)
  RETURN boolean IS
  BEGIN
   if g_org_id is null then
     g_org_id :=  p_org_id;
    elsif g_org_id <> p_org_id then
     g_org_id := p_org_id;
     g_mfar_enabled := NULL;
   end if;

--        p_enabled_flag := 'N';
        --
     if g_mfar_enabled is null THEN
        SELECT status
        INTO p_enabled_flag
        FROM psa_implementation_all
        WHERE org_id    = p_org_id
        AND psa_feature = p_psa_feature;
        g_mfar_enabled :=  p_enabled_flag;
        --
    else
      p_enabled_flag := g_mfar_enabled;
   end if;

  return TRUE;
   --
  EXCEPTION WHEN no_data_found THEN
        g_mfar_enabled := 'N';
        RETURN(FALSE);
   END;
   --
   PROCEDURE enable_mfar(p_org_id       IN  INTEGER,
                         p_psa_feature  IN  VARCHAR2)
   IS
   l_enabled_flag varchar2(1);
   BEGIN
        SELECT status
        INTO l_enabled_flag
        FROM psa_implementation_all
        WHERE org_id = p_org_id
        AND psa_feature = p_psa_feature;
        --
        IF l_enabled_flag = 'Y' THEN
            NULL;
        ELSIF l_enabled_flag = 'N' THEN
            UPDATE psa_implementation_all
            SET status      = 'Y'
            WHERE org_id    = p_org_id
            AND psa_feature = p_psa_feature;
        END IF;
        --
        EXCEPTION WHEN no_data_found THEN
            INSERT INTO psa_implementation_all(psa_feature
                                              ,status
                                              ,org_id)
            VALUES (p_psa_feature
                   ,'Y'
                   ,p_org_id);
    END;
    --
    PROCEDURE disable_mfar(p_org_id       IN  INTEGER,
                           p_psa_feature  IN  VARCHAR2)
    IS
    l_enabled_flag varchar2(1);
    -- ========================= FND LOG ===========================
    l_full_path VARCHAR2(100) := g_path || 'disable_mfar';
    -- ========================= FND LOG ===========================
    BEGIN
        SELECT status
        INTO l_enabled_flag
        FROM psa_implementation_all
        WHERE org_id    = p_org_id
        AND psa_feature = p_psa_feature;
        --
        IF l_enabled_flag = 'N' THEN
            NULL;
        ELSIF l_enabled_flag = 'Y' THEN
            UPDATE psa_implementation_all
            SET status      = 'N'
            WHERE org_id    = p_org_id
            AND psa_feature = p_psa_feature;
        END IF;
     --
     EXCEPTION
     WHEN no_data_found THEN
            INSERT INTO psa_implementation_all(psa_feature
                                              ,status
                                              ,org_id)
            VALUES (p_psa_feature
                   ,'N'
                   ,p_org_id);
     WHEN others THEN
          FND_MESSAGE.SET_NAME ('AR', 'GENERIC_MESSAGE');
          FND_MESSAGE.SET_TOKEN('GENERIC_TEXT', 'Error Package - psa_implementation'||sqlerrm);
          -- ========================= FND LOG ===========================
          psa_utils.debug_other_msg(g_unexp_level,l_full_path,FALSE);
          -- ========================= FND LOG ===========================
          APP_EXCEPTION.RAISE_EXCEPTION;
     END;
     --
     END PSA_IMPLEMENTATION;

/
