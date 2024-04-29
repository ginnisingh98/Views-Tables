--------------------------------------------------------
--  DDL for Package FUN_INTERCO_CUSTOM_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_INTERCO_CUSTOM_WF" AUTHID CURRENT_USER AS
/* $Header: fun_interco_wfs.pls 120.0.12010000.2 2010/03/17 07:09:04 ychandra noship $ */

PROCEDURE timeout_validate(
   itemtype    IN varchar2,
    itemkey     IN varchar2,
    actid       IN number,
    funcmode    IN varchar2,
    resultout   IN OUT NOCOPY varchar2);

END FUN_INTERCO_CUSTOM_WF;

/
