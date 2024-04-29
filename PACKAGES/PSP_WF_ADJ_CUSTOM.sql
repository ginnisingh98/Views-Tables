--------------------------------------------------------
--  DDL for Package PSP_WF_ADJ_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_WF_ADJ_CUSTOM" AUTHID CURRENT_USER AS
/* $Header: PSPWFACS.pls 120.1 2006/01/23 19:22:06 vdharmap noship $ */

/*************************************************************************
** Procedure select_approver_custom  returns the approver_id            **
** for the given employee. It is called from                             **
** PSP_WF_ADJ_PKG.SELECT_APPROVER.                                      **
**************************************************************************/
PROCEDURE SELECT_APPROVER_CUSTOM
                        (itemtype               IN      VARCHAR2,
                          itemkey               IN      VARCHAR2,
                          actid                 IN      VARCHAR2,
                          funcmode              IN      VARCHAR2,
                          p_person_id           IN      NUMBER,
                          p_assignment_number   IN      VARCHAR2,
                          p_approver_id         OUT NOCOPY     NUMBER);

/*************************************************************************
** Procedure omit_approval_custom  returns 'Y' or 'N'                   **
** It is called from PSP_WF_ADJ_PKG.OMIT_APPROVAL.
**************************************************************************/
PROCEDURE OMIT_APPROVAL_CUSTOM
                        (itemtype               IN      VARCHAR2,
                          itemkey               IN      VARCHAR2,
                          actid                 IN      VARCHAR2,
                          funcmode              IN      VARCHAR2,
                          p_omit_approval       OUT NOCOPY     VARCHAR2);

/*************************************************************************
** Procedure record_creator_custom  returns approver id                 **
** It is called from PSP_WF_ADJ_PKG.record_creator
**************************************************************************/
PROCEDURE RECORD_CREATOR_CUSTOM
                        (itemtype               IN      VARCHAR2,
                          itemkey               IN      VARCHAR2,
                          actid                 IN      VARCHAR2,
                          funcmode              IN      VARCHAR2,
                          p_custom_approver_id  OUT NOCOPY     VARCHAR2);

--- added following 2 user hooks for 4992668

procedure prorate_dff_hook(p_batch_name in varchar2,
                           p_business_group_id in integer,
                           p_set_of_books_id in integer);

procedure dff_for_approver(p_batch_name in varchar2,
                           p_run_id in integer,
                           p_business_group_id in integer,
                           p_set_of_books_id in integer);
END psp_wf_adj_custom;

 

/
