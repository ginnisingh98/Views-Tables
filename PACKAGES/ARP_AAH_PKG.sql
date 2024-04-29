--------------------------------------------------------
--  DDL for Package ARP_AAH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_AAH_PKG" AUTHID CURRENT_USER AS
/* $Header: ARTIAAHS.pls 120.4 2005/10/30 04:27:16 appldev ship $ */

PROCEDURE set_to_dummy( p_aah_rec OUT NOCOPY ar_approval_action_history%rowtype);

PROCEDURE lock_p( p_approval_action_history_id
                  IN ar_approval_action_history.approval_action_history_id%type
                );

PROCEDURE lock_f_adj_id( p_adjustment_id
                           IN ar_adjustments.adjustment_id%type );

PROCEDURE lock_fetch_p( p_aah_rec IN OUT NOCOPY ar_approval_action_history%rowtype,
                        p_approval_action_history_id IN
		ar_approval_action_history.approval_action_history_id%type);

PROCEDURE lock_compare_p( p_approval_action_history_id IN
                 ar_approval_action_history.approval_action_history_id%type,
                          p_aah_rec IN ar_approval_action_history%rowtype);

PROCEDURE fetch_p( p_aah_rec         OUT NOCOPY ar_approval_action_history%rowtype,
                 p_approval_action_history_id IN
                   ar_approval_action_history.approval_action_history_id%type);

procedure delete_p( p_approval_action_history_id
                IN ar_approval_action_history.approval_action_history_id%type);

procedure delete_f_adj_id( p_adjustment_id
                         IN ar_adjustments.adjustment_id%type);

PROCEDURE update_p( p_aah_rec IN ar_approval_action_history%rowtype,
                    p_approval_action_history_id  IN
                  ar_approval_action_history.approval_action_history_id%type);

PROCEDURE update_f_adj_id( p_aah_rec     IN ar_approval_action_history%rowtype,
                         p_adjustment_id IN ar_adjustments.adjustment_id%type);

PROCEDURE insert_p(
             p_aah_rec          IN ar_approval_action_history%rowtype,
             p_approval_action_history_id
                 OUT NOCOPY ar_approval_action_history.approval_action_history_id%type
                  );

PROCEDURE display_aah_rec(
            p_aah_rec IN ar_approval_action_history%rowtype);

PROCEDURE display_aah_p(
            p_approval_action_history_id IN
              ar_approval_action_history.approval_action_history_id%type);

PROCEDURE display_aah_f_adj_id(  p_adjustment_id IN
                                        ar_adjustments.adjustment_id%type );

END ARP_AAH_PKG;

 

/
