--------------------------------------------------------
--  DDL for Package IGS_AV_VAL_ASULEB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AV_VAL_ASULEB" AUTHID CURRENT_USER AS
/* $Header: IGSAV07S.pls 115.6 2003/12/09 10:41:06 nalkumar ship $ */

  -- To validate the basis year advanced standing units or levels.
  FUNCTION advp_val_basis_year(
  p_basis_year IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN;

  --
  -- To validate the Advanced Standing records when a new Transcript is submitted.
  -- Added as part of RECR50; Bug# 3270446
  --
  PROCEDURE validate_transcript(
    p_person_id     IN NUMBER,
    p_education_id  IN NUMBER,
    p_transcript_id IN NUMBER);

  --
  -- To set the Advanced Standing Work Flow Role.
  -- Added as part of RECR50; Bug# 3270446
  --
  PROCEDURE wf_set_role(
    itemtype  IN  VARCHAR2,
    itemkey   IN  VARCHAR2,
    actid     IN  NUMBER  ,
    funcmode  IN  VARCHAR2,
    resultout OUT NOCOPY VARCHAR2);

  --
  -- To launch the Advanced Standing Workflow
  -- Added as part of RECR50; Bug# 3270446
  --
  PROCEDURE create_transcript(
    document_id   IN      VARCHAR2,
    display_type  IN      VARCHAR2,
    document      IN OUT NOCOPY CLOB,
    document_type IN OUT NOCOPY VARCHAR2);

  --
  -- To set Atteribute values of the Advanced Standing Notifications.
  -- Added as part of RECR50; Bug# 3270446
  --
  PROCEDURE get_transcript_data(
    p_itemtype      IN VARCHAR2,
    p_itemkey       IN VARCHAR2,
    p_person_id     IN NUMBER,
    p_education_id  IN NUMBER,
    p_transcript_id IN NUMBER);

END igs_av_val_asuleb;

 

/
