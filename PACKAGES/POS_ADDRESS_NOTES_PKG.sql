--------------------------------------------------------
--  DDL for Package POS_ADDRESS_NOTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_ADDRESS_NOTES_PKG" AUTHID CURRENT_USER as
/* $Header: POSANOTS.pls 115.0 2002/11/14 01:56:34 bfreeman noship $ */

procedure insert_note(
    p_party_site_id                 IN NUMBER,
    p_note                          IN VARCHAR2,
    x_status                        OUT NOCOPY VARCHAR2,
    x_exception_msg                 OUT NOCOPY VARCHAR2);

procedure update_note(
    p_party_site_id                 IN NUMBER,
    p_note                          IN VARCHAR2,
    x_status                        OUT NOCOPY VARCHAR2,
    x_exception_msg                 OUT NOCOPY VARCHAR2);

procedure delete_note(
    p_party_site_id                 IN NUMBER,
    x_status                        OUT NOCOPY VARCHAR2,
    x_exception_msg                 OUT NOCOPY VARCHAR2);

END POS_ADDRESS_NOTES_PKG;

 

/
