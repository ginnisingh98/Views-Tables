--------------------------------------------------------
--  DDL for Package POS_HZ_RELATIONSHIPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_HZ_RELATIONSHIPS_PKG" AUTHID CURRENT_USER AS
/*$Header: POSHZPRS.pls 115.4 2002/11/16 01:07:39 jpasala ship $ */


procedure pos_hz_create_relationship(
                           p_subject_id IN NUMBER,
                           p_object_id  IN NUMBER,
                           p_relationship_type IN VARCHAR2,
                           p_relationship_code IN VARCHAR2,
                           p_party_object_type IN VARCHAR2,
                           p_party_subject_type IN VARCHAR2,
                           p_subject_table_name IN VARCHAR2,
                           p_object_table_name  IN VARCHAR2,
                           p_relationship_status IN VARCHAR2 :=null, -- can be null
                           p_relationship_start_date IN DATE := null, -- can be null
                           p_relationship_end_date IN DATE := null,   -- can be null

                           x_party_relationship_id OUT NOCOPY NUMBER,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_exception_msg OUT NOCOPY VARCHAR2
                           );

procedure pos_create_relationship(
                            p_subject_id IN NUMBER,
                            p_object_id  IN NUMBER,
                            p_relationship_type IN VARCHAR2,
                            p_relationship_code IN VARCHAR2,
                           x_party_relationship_id OUT NOCOPY NUMBER,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_exception_msg OUT NOCOPY VARCHAR2);

procedure pos_hz_update_relationship(p_subject_id IN NUMBER,
                           p_object_id  IN NUMBER,
                           p_relationship_type IN VARCHAR2,
                           p_relationship_code IN VARCHAR2,
                           p_party_object_type IN VARCHAR2,
                           p_party_subject_type IN VARCHAR2,
                           p_subject_table_name IN VARCHAR2,
                           p_object_table_name  IN VARCHAR2,
                          -- p_relationship_status IN VARCHAR2, -- should not be updated
                           p_relationship_start_date IN DATE, -- can be null
                           p_relationship_end_date IN DATE,   -- can be null

                           p_relationship_id IN NUMBER,
                           p_object_version_number in number,

                           p_rel_last_update_date IN OUT NOCOPY DATE,
                           p_party_last_update_date IN OUT NOCOPY  DATE,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_exception_msg OUT NOCOPY VARCHAR2);

procedure pos_outdate_relationship(
                            p_subject_id IN NUMBER,
                            p_object_id  IN NUMBER,
                            p_relationship_type IN VARCHAR2,
                            p_relationship_code IN VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_exception_msg OUT NOCOPY VARCHAR2);

procedure pos_outdate_relationship(
        p_relationship_id IN NUMBER,
        p_object_version_num IN NUMBER,
        x_return_status OUT NOCOPY VARCHAR2,
        x_exception_msg OUT NOCOPY VARCHAR2);

procedure GET_RELATING_PARTY_ID(p_subject_id IN NUMBER,
                                p_relationship_type IN VARCHAR2,
                                p_relationship_code IN VARCHAR2,
                                x_object_id  OUT NOCOPY NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_exception_msg OUT NOCOPY VARCHAR2);

END POS_HZ_RELATIONSHIPS_PKG;

 

/
