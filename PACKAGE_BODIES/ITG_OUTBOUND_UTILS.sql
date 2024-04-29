--------------------------------------------------------
--  DDL for Package Body ITG_OUTBOUND_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ITG_OUTBOUND_UTILS" AS
/* ARCS: $Header: itgoutub.pls 120.1 2005/12/22 04:14:35 bsaratna noship $
 * CVS:  itgoutub.pls,v 1.29 2003/05/29 22:22:44 klai Exp
 */
  l_debug_level NUMBER := to_number(nvl(fnd_profile.value('CLN_DEBUG_LEVEL'), '5'));

  c_off_ttype  CONSTANT BINARY_INTEGER :=  1;
  c_off_tsub   CONSTANT BINARY_INTEGER :=  2;
  c_off_id     CONSTANT BINARY_INTEGER :=  3;
  c_off_org    CONSTANT BINARY_INTEGER :=  4;
  c_off_doctyp CONSTANT BINARY_INTEGER :=  5;
  c_off_clntyp CONSTANT BINARY_INTEGER :=  6;
  c_off_doc    CONSTANT BINARY_INTEGER :=  7;
  c_off_rel    CONSTANT BINARY_INTEGER :=  8;
  c_off_pid    CONSTANT BINARY_INTEGER :=  9;
  c_off_psite  CONSTANT BINARY_INTEGER := 10;
  c_off_param1 CONSTANT BINARY_INTEGER := 11;
  c_off_param2 CONSTANT BINARY_INTEGER := 12;
  c_off_param3 CONSTANT BINARY_INTEGER := 13;
  c_off_param4 CONSTANT BINARY_INTEGER := 14;
  c_off_param5 CONSTANT BINARY_INTEGER := 15;

  FUNCTION get_parameter_list(
        p_bsr    IN            VARCHAR2,
        p_id     IN            NUMBER,
        p_org    IN            NUMBER,
        p_doctyp IN            VARCHAR2,
        p_clntyp IN            VARCHAR2,
        p_doc    IN            VARCHAR2 := NULL,
        p_rel    IN            VARCHAR2 := NULL,
        p_param1 IN            VARCHAR2 := NULL,
        p_param2 IN            VARCHAR2 := NULL,
        p_param3 IN            VARCHAR2 := NULL,
        p_param4 IN            VARCHAR2 := NULL
  ) RETURN wf_parameter_list_t AS
  BEGIN
        IF (l_Debug_Level <= 2) THEN
              itg_debug_pub.Add('ENTERING get_parameter_list',2);
        END IF;

        return wf_parameter_list_t
        ( wf_parameter_t('ECX_TRANSACTION_TYPE',    itg_x_utils.c_app_short_name)
        , wf_parameter_t('ECX_TRANSACTION_SUBTYPE', p_bsr)
        , wf_parameter_t('ECX_DOCUMENT_ID',         to_char(p_id))
        , wf_parameter_t('CLN_ORGANIZATION_ID',     p_org)
        , wf_parameter_t('CLN_DOC_TYPE',            p_doctyp)
        , wf_parameter_t('CLN_TYPE',                p_clntyp)
        , wf_parameter_t('CLN_DOC_NUM',             p_doc)
        , wf_parameter_t('CLN_REL_NUM',             p_rel)
        , wf_parameter_t('ECX_PARTY_ID',            itg_x_utils.g_party_id)
        , wf_parameter_t('ECX_PARTY_SITE_ID',       itg_x_utils.g_party_site_id)
        , wf_parameter_t('ECX_PARAMETER1',          p_param1)
        , wf_parameter_t('ECX_PARAMETER2',          p_param2)
        , wf_parameter_t('ECX_PARAMETER3',          p_param3)
        , wf_parameter_t('ECX_PARAMETER4',          p_param4)
        , wf_parameter_t('ECX_PARAMETER5',          NULL)
        );
        /* 'CLN_ID' is added by the WF function create_outbound_collaboration() */

        IF (l_Debug_Level <= 2) THEN
              itg_debug_pub.Add('EXITING get_parameter_list',2);
        END IF;
  END get_parameter_list;

  PROCEDURE change_parameter_list(
        p_list   IN OUT NOCOPY wf_parameter_list_t,
        p_bsr    IN            VARCHAR2 := NULL,
        p_id     IN            NUMBER   := NULL,
        p_org    IN            NUMBER   := NULL,
        p_doctyp IN            VARCHAR2 := NULL,
        p_clntyp IN            VARCHAR2 := NULL,
        p_doc    IN            VARCHAR2 := NULL,
        p_rel    IN            VARCHAR2 := NULL,
        p_param1 IN            VARCHAR2 := NULL,
        p_param2 IN            VARCHAR2 := NULL,
        p_param3 IN            VARCHAR2 := NULL,
        p_param4 IN            VARCHAR2 := NULL
  ) IS
  BEGIN
        IF p_bsr    IS NOT NULL THEN
                IF p_bsr    = FND_API.G_MISS_CHAR THEN
                     p_list(c_off_tsub).setValue(NULL);
                ELSE
                     p_list(c_off_tsub).setValue(p_bsr);
                END IF;
        END IF;

        IF p_id     IS NOT NULL THEN
                IF p_id     = FND_API.G_MISS_NUM  THEN
                     p_list(c_off_id).setValue(NULL);
                ELSE
                     p_list(c_off_id).setValue(to_char(p_id));
                END IF;
        END IF;

        IF p_org    IS NOT NULL THEN
                IF p_org    = FND_API.G_MISS_NUM  THEN
                     p_list(c_off_org).setValue(NULL);
                ELSE
                     p_list(c_off_org).setValue(p_org);
                END IF;
        END IF;

        IF p_doctyp IS NOT NULL THEN
                IF p_doctyp = FND_API.G_MISS_CHAR THEN
                     p_list(c_off_doctyp).setValue(NULL);
                ELSE
                     p_list(c_off_doctyp).setValue(p_doctyp);
                END IF;
        END IF;

        IF p_clntyp IS NOT NULL THEN
                IF p_clntyp = FND_API.G_MISS_CHAR THEN
                     p_list(c_off_clntyp).setValue(NULL);
                ELSE
                     p_list(c_off_clntyp).setValue(p_clntyp);
                END IF;
        END IF;

        IF p_doc    IS NOT NULL THEN
                IF p_doc    = FND_API.G_MISS_CHAR THEN
                     p_list(c_off_doc).setValue(NULL);
                ELSE
                     p_list(c_off_doc).setValue(p_doc);
                END IF;
        END IF;

        IF p_rel    IS NOT NULL THEN
                IF p_rel    = FND_API.G_MISS_CHAR THEN
                     p_list(c_off_rel).setValue(NULL);
                ELSE
                     p_list(c_off_rel).setValue(p_rel);
                END IF;
        END IF;

        IF p_param1 IS NOT NULL THEN
                IF p_param1 = FND_API.G_MISS_CHAR THEN
                     p_list(c_off_param1).setValue(NULL);
                ELSE
                     p_list(c_off_param1).setValue(p_param1);
                END IF;
        END IF;

        IF p_param2 IS NOT NULL THEN
                  IF p_param2 = FND_API.G_MISS_CHAR THEN
                       p_list(c_off_param2).setValue(NULL);
                  ELSE
                       p_list(c_off_param2).setValue(p_param2);
                  END IF;
        END IF;

        IF p_param3 IS NOT NULL THEN
                IF p_param3 = FND_API.G_MISS_CHAR THEN
                     p_list(c_off_param3).setValue(NULL);
                ELSE
                     p_list(c_off_param3).setValue(p_param3);
                END IF;
        END IF;

        IF p_param4 IS NOT NULL THEN
                IF p_param4 = FND_API.G_MISS_CHAR THEN
                      p_list(c_off_param4).setValue(NULL);
                ELSE
                      p_list(c_off_param4).setValue(p_param4);
                END IF;
        END IF;
  END change_parameter_list;


  PROCEDURE raise_wf_event_params(
        p_params        IN     wf_parameter_list_t
  ) AS
        l_params               wf_parameter_list_t;
        l_event                wf_event_t;
        l_to_agent             wf_agent_t;
        l_event_key            VARCHAR2(60);

  BEGIN
          IF (l_Debug_Level <= 2) THEN
                  itg_debug_pub.Add('ENTERING raise_wf_event_params',2);
          END IF;

          IF (l_Debug_Level <= 1) THEN
                itg_debug_pub.Add('Top of raise_wf_event_params' ,1);
                itg_debug_pub.Add('ttype  '||p_params(c_off_ttype).getValue  ,1);
                itg_debug_pub.Add('tsub   '||p_params(c_off_tsub).getValue   ,1);
                itg_debug_pub.Add('id     '||p_params(c_off_id).getValue     ,1);
                itg_debug_pub.Add('org    '||p_params(c_off_org).getValue    ,1);
                itg_debug_pub.Add('doctyp '||p_params(c_off_doctyp).getValue ,1);
                itg_debug_pub.Add('clntyp '||p_params(c_off_clntyp).getValue ,1);
                itg_debug_pub.Add('doc    '||p_params(c_off_doc).getValue    ,1);
                itg_debug_pub.Add('rel    '||p_params(c_off_rel).getValue    ,1);
                itg_debug_pub.Add('pid    '||p_params(c_off_pid).getValue    ,1);
                itg_debug_pub.Add('psite  '||p_params(c_off_psite).getValue  ,1);
                itg_debug_pub.Add('param1 '||p_params(c_off_param1).getValue ,1);
                itg_debug_pub.Add('param2 '||p_params(c_off_param2).getValue ,1);
                itg_debug_pub.Add('param3 '||p_params(c_off_param3).getValue ,1);
                itg_debug_pub.Add('param4 '||p_params(c_off_param4).getValue ,1);
          END IF;

          IF NOT itg_x_utils.g_initialized THEN
                /* 4169685: REMOVE INSTALL DATA INSERTION FROM HR_LOCATIONS TABLE */
                IF (l_Debug_Level <= 1) THEN
                        itg_debug_pub.Add('Missing Trading Partner setup and/or Connector uninitialized' ,1);
                END IF;

                RETURN;
          END IF;

    IF NOT ITG_OrgEff_PVT.Check_Effective(
             p_organization_id => p_params(c_off_org).getValue,
             p_cln_doc_type    => p_params(c_off_doctyp).getValue,
             p_doc_direction   => 'P') THEN

                IF (l_Debug_Level <= 1) THEN
                      itg_debug_pub.Add('Triggered event is not effective.' ,1);
                END IF;
                RETURN;
    END IF;

    l_to_agent := wf_agent_t('WF_IN', itg_x_utils.g_local_system);
    SELECT itg_x_utils.g_event_key_pfx ||
           to_char(itg_outbound_seq.nextval, 'FM09999999')
    INTO   l_event_key
    FROM   dual;

    IF (l_Debug_Level <= 1) THEN
        itg_debug_pub.Add('l_event_key '||l_event_key ,1);
    END IF;

    l_params := p_params;

    l_params(c_off_param5).setValue(l_event_key);
/*
    wf_event_t.initialize(l_event);
    l_event.setParameterList(l_params);
    l_event.setEventName(itg_x_utils.c_event_name);
    l_event.setEventKey(l_event_key);
    l_event.setToAgent(l_to_agent);
    l_event.setCorrelationID(itg_x_utils.c_correlation_id);
    wf_event.Send(l_event);
*/
/* Changed Send to a Raise, inorder to prevent Agent error while capturing
   event message in workflow, More Details refer to Bug no: 3896966*/
    wf_event.raise(
                       p_event_name => itg_x_utils.c_event_name,
                       p_event_key  => l_event_key,
                       p_parameters => l_params
                  );

    IF (l_Debug_Level <= 2) THEN
          itg_debug_pub.Add('Message sent ', 2);
          itg_debug_pub.Add('EXITING raise_wf_event_params ', 2);
    END IF;

  END raise_wf_event_params;



  PROCEDURE raise_wf_event(
        p_bsr           IN   VARCHAR2,
        p_id            IN   NUMBER,
        p_org           IN   NUMBER,
        p_doctyp        IN   VARCHAR2,
        p_clntyp        IN   VARCHAR2,
        p_doc           IN   VARCHAR2 := NULL,
        p_rel           IN   VARCHAR2 := NULL,
        p_param1        IN   VARCHAR2 := NULL,
        p_param2        IN   VARCHAR2 := NULL,
        p_param3        IN   VARCHAR2 := NULL,
        p_param4        IN   VARCHAR2 := NULL
  ) AS
  BEGIN
        IF (l_Debug_Level <= 2) THEN
                itg_debug_pub.Add('ENTERING raise_wf_event',2);
        END IF;

        raise_wf_event_params(
                  get_parameter_list(
                            p_bsr, p_id, p_org, p_doctyp, p_clntyp, p_doc, p_rel,
                            p_param1, p_param2, p_param3, p_param4
                  )
        );

        IF (l_Debug_Level <= 2) THEN
                itg_debug_pub.Add('EXITING raise_wf_event',2);
        END IF;
  END raise_wf_event;

END itg_outbound_utils;

/
