--------------------------------------------------------
--  DDL for Package PER_DRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_DRT_PKG" AUTHID CURRENT_USER AS
/* $Header: pedrtpkg.pkh 120.0.12010000.6 2019/10/11 07:32:26 ktithy noship $ */

  TYPE process_record_type IS RECORD (person_id    number(15)
                                     ,entity_type  varchar2(3)
                                     ,status       varchar2(1)
                                     ,msgcode      varchar2(30)
                                     ,msgaplid     number(15));

  TYPE result_tbl_type IS TABLE OF process_record_type INDEX BY binary_integer;

	TYPE process_tbl_type IS TABLE OF process_record_type INDEX BY binary_integer;

  g_process_tbl result_tbl_type;

  PROCEDURE write_log
    (message IN varchar2
    ,stage   IN varchar2);

  PROCEDURE add_to_results
    (person_id   IN            number
    ,entity_type IN            varchar2
    ,status      IN            varchar2
    ,msgcode     IN            varchar2
    ,msgaplid    IN            number
    ,result_tbl  IN OUT NOCOPY per_drt_pkg.result_tbl_type);

  PROCEDURE per_hr_drc
    (person_id  IN         number
    ,result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type);

  PROCEDURE per_tca_drc
    (person_id  IN         number
    ,result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type);

  PROCEDURE per_fnd_drc
    (person_id  IN         number
    ,result_tbl OUT NOCOPY per_drt_pkg.result_tbl_type);

  FUNCTION overwrite_derived_names
    (rid         IN rowid
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,person_id   IN number) RETURN varchar2;

  FUNCTION overwrite_gender
    (rid         IN rowid
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,person_id   IN number) RETURN varchar2;

  FUNCTION overwrite_nationality
    (rid         IN rowid
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,person_id   IN number) RETURN varchar2;

  FUNCTION overwrite_date
    (rid         IN rowid
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,person_id   IN number) RETURN DATE;

  FUNCTION check_tables_uniqueness
    (p_table_name        IN varchar2
    ,p_table_phase       IN number
    ,p_record_identifier IN varchar2) RETURN varchar2;

  FUNCTION check_columns_uniqueness
    (p_table_id       IN number
    ,p_column_name    IN varchar2) RETURN varchar2;

  FUNCTION check_contexts_uniqueness
    (p_column_id      IN number
    ,p_flexfield_name IN varchar2
    ,p_context_name   IN varchar2) RETURN varchar2;

  FUNCTION overwrite_title
    (rid         IN rowid
    ,table_name  IN varchar2
    ,column_name IN varchar2
    ,p_person_id IN number) RETURN varchar2;

	PROCEDURE per_hr_post
	  (person_id IN number);

	PROCEDURE handle_attachments_prc
	  (p_in_person_id IN  number
	  ,status         OUT NOCOPY varchar2);

	PROCEDURE delete_attachments
	  (p_in_entity_name IN varchar2
	  ,p_in_pk1_value   IN varchar2
	  ,p_in_pk2_value   IN varchar2 DEFAULT NULL
	  ,p_in_pk3_value   IN varchar2 DEFAULT NULL
	  ,p_in_pk4_value   IN varchar2 DEFAULT NULL
	  ,p_in_pk5_value   IN varchar2 DEFAULT NULL);

   PROCEDURE handle_role_data( p_in_person_id in number,p_in_orig_system in varchar2);

END PER_DRT_PKG;

/
