--------------------------------------------------------
--  DDL for Package GCS_WF_NTF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GCS_WF_NTF_PKG" AUTHID CURRENT_USER AS
/* $Header: gcswfntfs.pls 120.2 2005/12/07 02:26:21 skamdar noship $ */
   --
   -- Procedure
   --   riase_notification
   -- Purpose
   --   An API to raise workflow notifications
   -- Arguments
   -- Notes
   --
  PROCEDURE raise_status_notification (       p_cons_detail_id              IN NUMBER);

  PROCEDURE raise_impact_notification (       p_run_name              IN VARCHAR2,
                p_cons_entity_id        IN NUMBER,
                p_entry_id      IN NUMBER DEFAULT 0,
                p_load_id      IN NUMBER DEFAULT 0);

  PROCEDURE raise_lock_notification (       p_run_name              IN VARCHAR2,
                p_cons_entity_id        IN NUMBER);

  PROCEDURE check_attachment_required(	p_itemtype		IN VARCHAR2,
  					p_itemkey		IN VARCHAR2,
  					p_actid			IN NUMBER,
  					p_funcmode		IN VARCHAR2,
  					p_result		IN OUT NOCOPY VARCHAR2);

  PROCEDURE check_impacted      (	p_itemtype		IN VARCHAR2,
  					p_itemkey		IN VARCHAR2,
  					p_actid			IN NUMBER,
  					p_funcmode		IN VARCHAR2,
  					p_result		IN OUT NOCOPY VARCHAR2);
  PROCEDURE update_consolidation(	p_itemtype		IN VARCHAR2,
  					p_itemkey		IN VARCHAR2,
  					p_actid			IN NUMBER,
  					p_funcmode		IN VARCHAR2,
  					p_result		IN OUT NOCOPY VARCHAR2);
END GCS_WF_NTF_PKG;


 

/
