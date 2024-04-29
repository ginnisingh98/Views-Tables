--------------------------------------------------------
--  DDL for Package GR_ATTACH_DOCUMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GR_ATTACH_DOCUMENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: GRATTCHS.pls 115.3 2003/08/07 21:01:56 mgrosser noship $ */


G_YES constant varchar2(25) := 'COMPLETE:Y';
G_NO constant varchar2(25) := 'COMPLETE:N';

   /* This procedure is used to attach a document to an object - Regulatory Item,
      Linked Inventory Item, Sales Order, etc. It is meant to be called from the
      ERES Document Management Approval workflow.  For the moment, it only works for
      Regulatory Items.
   */
   PROCEDURE attach_to_entity (p_itemtype VARCHAR2,
                               p_itemkey VARCHAR2,
                               p_actid NUMBER,
                               p_funcmode VARCHAR2,
                               p_resultout OUT NOCOPY VARCHAR2);

END GR_ATTACH_DOCUMENTS_PKG;


 

/
