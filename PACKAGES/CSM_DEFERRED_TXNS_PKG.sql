--------------------------------------------------------
--  DDL for Package CSM_DEFERRED_TXNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_DEFERRED_TXNS_PKG" AUTHID CURRENT_USER AS
/*$Header: csmdftxs.pls 120.0.12010000.2 2009/08/07 08:22:39 saradhak noship $*/
   PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         );

		   -- Set transaction status to discarded
  PROCEDURE discard_transaction(p_user_name IN VARCHAR2,
                                p_tranid   IN NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2);

  -- Discard the specified deferred row
  PROCEDURE discard_transaction(p_user_name IN VARCHAR2,
                                p_tranid   IN NUMBER,
                                p_pubitem  IN VARCHAR2,
                                p_sequence  IN NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2,
                                p_commit_flag IN BOOLEAN DEFAULT TRUE);

END CSM_DEFERRED_TXNS_PKG;

/
