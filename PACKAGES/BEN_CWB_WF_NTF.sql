--------------------------------------------------------
--  DDL for Package BEN_CWB_WF_NTF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_WF_NTF" AUTHID CURRENT_USER AS
/* $Header: bencwbfy.pkh 120.0 2005/05/28 03:59:05 appldev noship $ */
  PROCEDURE cwb_fyi_ntf_api (
    p_transaction_id        IN   NUMBER
  , p_message_type          IN   VARCHAR2
  , p_rcvr_person_id        IN   NUMBER
  , p_from_person_id        IN   NUMBER
  , p_group_per_in_ler_id   IN   NUMBER
  );

  PROCEDURE which_message (
    itemtype   IN              VARCHAR2
  , itemkey    IN              VARCHAR2
  , actid      IN              NUMBER
  , funcmode   IN              VARCHAR2
  , RESULT     OUT NOCOPY      VARCHAR2
  );

  PROCEDURE is_notification_sent (
    itemtype   IN              VARCHAR2
  , itemkey    IN              VARCHAR2
  , actid      IN              NUMBER
  , funcmode   IN              VARCHAR2
  , RESULT     OUT NOCOPY      VARCHAR2
  );

  PROCEDURE cwb_plan_comp_ntf_api (
    p_transaction_id        IN   NUMBER
  , p_message_type          IN   VARCHAR2
  , p_from_person_id        IN   NUMBER
  , p_group_per_in_ler_id   IN   NUMBER
  );

  FUNCTION get_ntf_conf_value (p_message_type IN VARCHAR2)
    RETURN VARCHAR2;
END;

 

/
