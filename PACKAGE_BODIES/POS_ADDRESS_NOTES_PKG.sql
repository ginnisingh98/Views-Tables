--------------------------------------------------------
--  DDL for Package Body POS_ADDRESS_NOTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_ADDRESS_NOTES_PKG" as
/* $Header: POSANOTB.pls 120.1 2005/07/28 18:03:22 bitang noship $ */

procedure insert_note(
    p_party_site_id                 IN NUMBER,
    p_note                          IN VARCHAR2,
    x_status                        OUT NOCOPY VARCHAR2,
    x_exception_msg                 OUT NOCOPY VARCHAR2)
IS
BEGIN
    INSERT INTO pos_address_notes(
        party_site_id,
        notes,
        created_by,
        creation_date,
        last_update_date,
        last_updated_by,
        last_update_login
    )VALUES(
        p_party_site_id,
        p_note,
        fnd_global.user_id,
        SYSDATE,
        SYSDATE,
        fnd_global.user_id,
        fnd_global.login_id
    );

    x_status := 'S';

END insert_note;

procedure update_note(
    p_party_site_id                 IN NUMBER,
    p_note                          IN VARCHAR2,
    x_status                        OUT NOCOPY VARCHAR2,
    x_exception_msg                 OUT NOCOPY VARCHAR2)
IS
    l_count_dup     NUMBER;
BEGIN
    SELECT count(*)
    INTO l_count_dup
    FROM pos_address_notes
    WHERE party_site_id = p_party_site_id
      AND ROWNUM < 2;

    IF (l_count_dup = 0) THEN
        insert_note(p_party_site_id, p_note, x_status, x_exception_msg);
        RETURN;
    END IF;

    UPDATE pos_address_notes
    SET notes               = p_note,
        last_updated_by     = fnd_global.user_id,
        last_update_date    = SYSDATE,
        last_update_login   = fnd_global.login_id
    WHERE party_site_id = p_party_site_id;

    x_status := 'S';

END update_note;


procedure delete_note(
    p_party_site_id                 IN NUMBER,
    x_status                        OUT NOCOPY VARCHAR2,
    x_exception_msg                 OUT NOCOPY VARCHAR2)
IS
BEGIN
    DELETE FROM pos_address_notes
    WHERE party_site_id = p_party_site_id;

    x_status := 'S';

END delete_note;

END POS_ADDRESS_NOTES_PKG;

/
