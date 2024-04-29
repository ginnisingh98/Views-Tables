--------------------------------------------------------
--  DDL for Package IGS_EN_IVR_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_IVR_PUB" AUTHID CURRENT_USER AS
/* $Header: IGSEN95S.pls 120.0 2005/06/01 22:21:04 appldev noship $ */
/*
  ||==============================================================================||
  ||  Created By : Nalin Kumar                                                    ||
  ||  Created On : 16-Jan-2003                                                    ||
  ||  Purpose    : Created this object as per IVR Build. Bug# 2745985             ||
  ||  Known limitations, enhancements or remarks :                                ||
  ||  Change History :                                                            ||
  ||  Who             When            What                                        ||
  ||  sarakshi        13-Apr-2004     Bug#3555871,changed call_number declaration ||
  ||                                  from NUMBER(10) to NUMBER                   ||
  ||  (reverse chronological order - newest change first)                         ||
  ||==============================================================================||
*/
  --
  --Term PL/SQL Table
  --
  TYPE term_rec_type IS RECORD(p_term_alt_code VARCHAR2 (10));
  TYPE term_tbl_type IS TABLE OF term_rec_type INDEX BY BINARY_INTEGER;

  --
  --Career/Program PL/SQL Table
  --
  TYPE career_rec_type IS RECORD (
  p_career         VARCHAR2(10),
  p_program_code   VARCHAR2(6),
  p_version_number NUMBER(3));
  TYPE career_tbl_type IS TABLE OF career_rec_type INDEX BY BINARY_INTEGER;

  --
  -- Schedule PL/SQL Table
  -- This is the declaration of ref cursor which will be returned from the list_schedule procedure
  --
  TYPE schedule_rec_type IS RECORD(
    p_unit_code                VARCHAR2(10),
    p_unit_class               VARCHAR2(10),
    p_unit_version             NUMBER(3),
    p_teach_alternate_code     VARCHAR2(10),
    p_call_Number              NUMBER,
    p_grading_Schema           VARCHAR2(10), -- Computed value
    p_credit_points            NUMBER(10),   -- Computed value
    p_unit_attempt_status      VARCHAR2(30),
    p_uas_meaning              VARCHAR2(80),
    p_uoo_id                   NUMBER(7),    -- To enable to join to other  views to get data if required.
    p_administrative_priority  NUMBER        -- Waitlist Position
  );
  TYPE schedule_tbl_type IS TABLE OF schedule_rec_type INDEX BY BINARY_INTEGER;

  --
  --Call Number  Pl/SQL Table
  -- This is the declaration of ref cursor which will be returned from the list_section_in_cart procedure
  --
  TYPE call_number_rec_type IS RECORD(p_call_number NUMBER);
  TYPE call_number_tbl_type IS TABLE OF call_number_rec_type INDEX BY BINARY_INTEGER;

  --
  -- End of declaration for PL?SQL Tables
  --

  PROCEDURE add_to_cart (
    p_api_version      IN         NUMBER  ,
    p_init_msg_list    IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit           IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_person_number    IN         VARCHAR2,
    p_career           IN         VARCHAR2,
    p_program_code     IN         VARCHAR2,
    p_term_alt_code    IN         VARCHAR2,
    p_call_number      IN         NUMBER  ,
    p_audit_ind        IN         VARCHAR2,
    p_waitlist_ind     OUT NOCOPY VARCHAR2,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE enroll_cart(
    p_api_version      IN         NUMBER  ,
    p_init_msg_list    IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit           IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_person_number    IN         VARCHAR2,
    p_career           IN         VARCHAR2,
    p_program_code     IN         VARCHAR2,
    p_term_alt_code    IN         VARCHAR2,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE clean_up_cart(
    p_api_version      IN         NUMBER  ,
    p_init_msg_list    IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit           IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_person_number    IN         VARCHAR2,
    p_career           IN         VARCHAR2,
    p_program_code     IN         VARCHAR2,
    p_term_alt_code    IN         VARCHAR2,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE drop_all_section(
    p_api_version    IN         NUMBER  ,
    p_init_msg_list  IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit         IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_person_number  IN         VARCHAR2,
    p_career         IN         VARCHAR2,
    p_program_code   IN         VARCHAR2,
    p_term_alt_code  IN         VARCHAR2,
    x_return_status  OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE drop_section_by_call_number(
    p_api_version      IN         NUMBER  ,
    p_init_msg_list    IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit           IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_person_number    IN         VARCHAR2,
    p_career           IN         VARCHAR2,
    p_program_code     IN         VARCHAR2,
    p_term_alt_code    IN         VARCHAR2,
    p_call_number      IN         NUMBER  ,
    p_drop_reason      IN         VARCHAR2,
    p_adm_status       IN         VARCHAR2,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE evaluate_person_steps(
    p_api_version   IN         NUMBER  ,
    p_init_msg_list IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit           IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_person_number IN         VARCHAR2,
    p_career        IN         VARCHAR2,
    p_program_code  IN         VARCHAR2,
    p_term_alt_code IN         VARCHAR2,
    x_return_status OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE list_schedule(
    p_api_version       IN         NUMBER  ,
    p_init_msg_list     IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit            IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
    P_person_number     IN         VARCHAR2,
    P_career            IN         VARCHAR2,
    P_program_code      IN         VARCHAR2,
    P_term_alt_code     IN         VARCHAR2,
    x_schedule_tbl      OUT NOCOPY schedule_tbl_type,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE list_section_in_cart(
    p_api_version      IN         NUMBER  ,
    p_init_msg_list    IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit           IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_person_number    IN         VARCHAR2,
    p_career           IN         VARCHAR2,
    p_program_code     IN         VARCHAR2,
    p_term_alt_code    IN         VARCHAR2,
    x_call_number_tbl  OUT NOCOPY call_number_tbl_type,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE remove_from_cart(
    p_api_version      IN         NUMBER  ,
    p_init_msg_list    IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit           IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_person_number    IN         VARCHAR2,
    p_career           IN         VARCHAR2,
    p_program_code     IN         VARCHAR2,
    p_term_alt_code    IN         VARCHAR2,
    p_call_number      IN         NUMBER  ,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE update_enroll_stats(
    p_api_version      IN         NUMBER  ,
    p_init_msg_list    IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit           IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_person_number    IN         VARCHAR2,
    p_career           IN         VARCHAR2,
    p_program_code     IN         VARCHAR2,
    p_term_alt_code    IN         VARCHAR2,
    p_call_number      IN         NUMBER  ,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE validate_career_program(
    p_api_version     IN         NUMBER  ,
    p_init_msg_list   IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit          IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_person_number   IN         VARCHAR2,
    p_career          IN         VARCHAR2,
    p_program_code    IN         VARCHAR2,
    x_primary_code    OUT NOCOPY VARCHAR2,
    x_primary_version OUT NOCOPY NUMBER  ,
    x_return_status   OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE validate_person_details(
    p_api_version             IN         NUMBER,
    p_init_msg_list           IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit                  IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_person_number           IN         VARCHAR2,
    x_default_term_alt_code   OUT NOCOPY VARCHAR2,
    x_career_tbl              OUT NOCOPY career_tbl_type,
    x_term_tbl                OUT NOCOPY term_tbl_type,
    x_multiple_career_program OUT NOCOPY VARCHAR2,
    x_return_status           OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE validate_term(
    p_api_version     IN         NUMBER  ,
    p_init_msg_list   IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit           IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_term_alt_code   IN         VARCHAR2,
    x_return_status   OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2);

  PROCEDURE waitlist(
    p_api_version        IN         NUMBER  ,
    p_init_msg_list      IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_commit             IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_person_number      IN         VARCHAR2,
    p_career             IN         VARCHAR2,
    p_program_code       IN         VARCHAR2,
    p_term_alt_code      IN         VARCHAR2,
    p_call_number        IN         NUMBER  ,
    p_audit_ind          IN         VARCHAR2,
    p_waitlist           IN         VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count               OUT NOCOPY NUMBER,
    x_msg_data                OUT NOCOPY VARCHAR2);

END igs_en_ivr_pub;

 

/
