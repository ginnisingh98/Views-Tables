--------------------------------------------------------
--  DDL for Package Body FUN_INTERCO_CUSTOM_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_INTERCO_CUSTOM_WF" AS
/* $Header: fun_interco_wfb.pls 120.0.12010000.1 2010/03/17 06:22:54 csutaria noship $ */

PROCEDURE timeout_validate(
    itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2)
IS
    l_trx_id        number;
    l_batch_id      number;
BEGIN

    resultout := wf_engine.eng_completed||':T';
    RETURN;

END timeout_validate;
END FUN_INTERCO_CUSTOM_WF;

/
