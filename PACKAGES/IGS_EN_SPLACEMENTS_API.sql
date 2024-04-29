--------------------------------------------------------
--  DDL for Package IGS_EN_SPLACEMENTS_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_SPLACEMENTS_API" AUTHID CURRENT_USER AS
 /* $Header: IGSENB0S.pls 115.2 2003/12/01 06:25:26 ssaleem noship $ */

FUNCTION create_plcmnt_sup (
p_person_id IN NUMBER,
p_last_name IN VARCHAR2,
p_first_name IN VARCHAR2,
p_title IN VARCHAR2,
p_employment_history_id IN OUT NOCOPY NUMBER,
p_email_address IN VARCHAR2,
p_email_id IN NUMBER,
p_email_ovn IN NUMBER,
p_phone IN VARCHAR2,
p_phone_id IN NUMBER,
p_phone_ovn IN NUMBER,
p_ignore_duplicate IN VARCHAR2 DEFAULT 'N',
p_party_number IN OUT NOCOPY VARCHAR2,
p_empl_ovn IN OUT NOCOPY HZ_EMPLOYMENT_HISTORY.OBJECT_VERSION_NUMBER%TYPE) RETURN NUMBER;

FUNCTION get_splacement_id RETURN NUMBER;

PROCEDURE delete_supervisor_info(p_splacement_id IN NUMBER, p_supervisor_id IN NUMBER);

FUNCTION process_supervisor_info(p_splacement_id IN NUMBER,
p_person_id IN NUMBER,
p_last_name IN VARCHAR2,
p_first_name IN VARCHAR2,
p_title IN VARCHAR2,
p_employment_history_id IN OUT NOCOPY NUMBER,
p_email_address IN VARCHAR2,
p_email_id IN NUMBER,
p_email_ovn IN NUMBER,
p_phone IN VARCHAR2,
p_phone_id IN NUMBER,
p_phone_ovn IN NUMBER,
p_ignore_duplicate IN VARCHAR2,
p_party_number IN OUT NOCOPY VARCHAR2,
p_object_version_number IN OUT NOCOPY HZ_EMPLOYMENT_HISTORY.OBJECT_VERSION_NUMBER%TYPE) RETURN NUMBER;

END igs_en_splacements_api;

 

/
