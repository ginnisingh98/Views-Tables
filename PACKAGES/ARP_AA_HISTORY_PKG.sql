--------------------------------------------------------
--  DDL for Package ARP_AA_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_AA_HISTORY_PKG" AUTHID CURRENT_USER AS
/* $Header: ARCIAAHS.pls 120.4 2005/10/30 04:14:18 appldev ship $*/
--
PROCEDURE insert_p( p_aah_rec    IN ar_approval_action_history%ROWTYPE,
  p_aah_id OUT NOCOPY ar_approval_action_history.approval_action_history_id%TYPE );
--
PROCEDURE update_p( p_aah_rec    IN ar_approval_action_history%ROWTYPE );
--
PROCEDURE delete_p(
   p_aah_id IN ar_approval_action_history.approval_action_history_id%TYPE );
--
PROCEDURE lock_p(
    p_aah_id IN ar_approval_action_history.approval_action_history_id%TYPE );
--
PROCEDURE fetch_p(
   p_aah_id IN ar_approval_action_history.approval_action_history_id%TYPE,
   p_aah_rec OUT NOCOPY ar_approval_action_history%ROWTYPE );
--
END  ARP_AA_HISTORY_PKG;
--

 

/
