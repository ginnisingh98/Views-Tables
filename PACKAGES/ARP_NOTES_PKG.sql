--------------------------------------------------------
--  DDL for Package ARP_NOTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_NOTES_PKG" AUTHID CURRENT_USER AS
/* $Header: ARTINOTS.pls 120.4 2005/10/30 04:27:25 appldev ship $ */

FUNCTION get_number_dummy(p_null IN NUMBER DEFAULT null) RETURN number;

PROCEDURE set_to_dummy( p_notes_rec OUT NOCOPY ar_notes%rowtype);

PROCEDURE lock_f_ct_id( p_customer_trx_id  IN ar_notes.customer_trx_id%type );

PROCEDURE lock_fetch_p( p_notes_rec         IN OUT NOCOPY ar_notes%rowtype,
                        p_note_id           IN     ar_notes.note_id%type);

PROCEDURE lock_compare_p( p_notes_rec          IN ar_notes%rowtype,
                          p_note_id      IN ar_notes.note_id%type);

PROCEDURE fetch_p( p_notes_rec  OUT NOCOPY ar_notes%rowtype,
                   p_note_id    IN  ar_notes.note_id%type);

procedure delete_f_ct_id( p_customer_trx_id  IN ar_notes.customer_trx_id%type);

PROCEDURE update_p( p_notes_rec IN OUT NOCOPY ar_notes%rowtype,
                    p_note_id   IN     ar_notes.note_id%type);

PROCEDURE insert_p(
                    p_notes_rec          IN OUT NOCOPY ar_notes%rowtype
                  );

PROCEDURE display_note_p( p_note_id  IN ar_notes.note_id%type );

PROCEDURE display_note_rec ( p_notes_rec IN ar_notes%rowtype );

PROCEDURE lock_compare_cover(
            p_note_id                  IN ar_notes.note_id%type,
            p_last_updated_by          IN ar_notes.last_updated_by%type,
            p_last_update_date         IN ar_notes.last_update_date%type,
            p_last_update_login        IN ar_notes.last_update_login%type,
            p_created_by               IN ar_notes.created_by%type,
            p_creation_date            IN ar_notes.creation_date%type,
            p_note_type                IN ar_notes.note_type%type,
            p_text                     IN ar_notes.text%type,
            p_customer_call_id         IN ar_notes.customer_call_id%type,
            p_customer_call_topic_id   IN ar_notes.customer_call_topic_id%type,
            p_call_action_id           IN ar_notes.call_action_id%type,
            p_customer_trx_id          IN ar_notes.customer_trx_id%type );

PROCEDURE insert_cover(
            p_note_type                IN ar_notes.note_type%type,
            p_text                     IN ar_notes.text%type,
            p_customer_call_id         IN ar_notes.customer_call_id%type,
            p_customer_call_topic_id   IN ar_notes.customer_call_topic_id%type,
            p_call_action_id           IN ar_notes.call_action_id%type,
            p_customer_trx_id          IN ar_notes.customer_trx_id%type,
            p_note_id                 OUT NOCOPY ar_notes.note_id%type,
            p_last_updated_by      IN OUT NOCOPY ar_notes.last_updated_by%type,
            p_last_update_date     IN OUT NOCOPY ar_notes.last_update_date%type,
            p_last_update_login    IN OUT NOCOPY ar_notes.last_update_login%type,
            p_created_by           IN OUT NOCOPY ar_notes.created_by%type,
            p_creation_date        IN OUT NOCOPY ar_notes.creation_date%type );

PROCEDURE update_cover(
            p_note_id                  IN ar_notes.note_id%type,
            p_created_by               IN ar_notes.created_by%type,
            p_creation_date            IN ar_notes.creation_date%type,
            p_note_type                IN ar_notes.note_type%type,
            p_text                     IN ar_notes.text%type,
            p_customer_call_id         IN ar_notes.customer_call_id%type,
            p_customer_call_topic_id   IN ar_notes.customer_call_topic_id%type,
            p_call_action_id           IN ar_notes.call_action_id%type,
            p_customer_trx_id          IN ar_notes.customer_trx_id%type,
            p_last_updated_by      IN OUT NOCOPY ar_notes.last_updated_by%type,
            p_last_update_date     IN OUT NOCOPY ar_notes.last_update_date%type,
            p_last_update_login    IN OUT NOCOPY ar_notes.last_update_login%type );


END ARP_NOTES_PKG;

 

/
