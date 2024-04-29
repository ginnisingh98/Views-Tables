--------------------------------------------------------
--  DDL for Package PJI_MT_MEASURES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJI_MT_MEASURES_PKG" AUTHID CURRENT_USER as
/* $Header: PJIMTMDS.pls 120.1 2005/05/31 08:01:18 appldev  $ */


-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------

procedure LOCK_ROW (
	p_measure_id		IN	pji_mt_measures_b.measure_id%TYPE,
	p_OBJECT_VERSION_NUMBER IN	pji_mt_measures_b.OBJECT_VERSION_NUMBER%TYPE
 );


-- -----------------------------------------------------------------------

procedure DELETE_ROW (
	p_measure_id		IN	pji_mt_measures_b.measure_id%TYPE
);


-- -----------------------------------------------------------------------

procedure INSERT_ROW (

	X_rowid		 IN OUT NOCOPY  rowid,

	X_measure_id		IN	pji_mt_measures_b.measure_id%type,

	X_measure_set_code	IN	pji_mt_measures_b.measure_set_code%type,
	X_measure_code		IN	pji_mt_measures_b.measure_code%type,
	X_xtd_type		IN	pji_mt_measures_b.xtd_type%type,
	X_pl_sql_api		IN	pji_mt_measures_b.pl_sql_api%type,
	X_object_version_number	IN	pji_mt_measures_b.object_version_number%type,

	X_name			IN	pji_mt_measures_tl.name%type,
	X_description		IN	pji_mt_measures_tl.description%type,

	X_last_update_date	IN      pji_mt_measures_b.last_update_date%Type,
	X_last_updated_by	IN	pji_mt_measures_b.last_updated_by%Type,
	X_creation_date		IN 	pji_mt_measures_b.creation_date%Type,
	X_created_by		IN	pji_mt_measures_b.created_by%Type,
	X_last_update_login	IN	pji_mt_measures_b.last_update_login%Type,

	X_return_status	 OUT NOCOPY  VARCHAR2,
	X_msg_data	 OUT NOCOPY  VARCHAR2,
	X_msg_count	 OUT NOCOPY  NUMBER
);


-- -----------------------------------------------------------------------

procedure UPDATE_ROW (

	X_measure_id		IN	pji_mt_measures_b.measure_id%type,

	X_measure_set_code	IN	pji_mt_measures_b.measure_set_code%type,
	X_measure_code		IN	pji_mt_measures_b.measure_code%type,
	X_xtd_type		IN	pji_mt_measures_b.xtd_type%type,
	X_pl_sql_api		IN	pji_mt_measures_b.pl_sql_api%type,
	X_object_version_number	IN	pji_mt_measures_b.object_version_number%type,

	X_name			IN	pji_mt_measures_tl.name%type,
	X_description		IN	pji_mt_measures_tl.description%type,

	X_last_update_date	IN      pji_mt_measures_b.last_update_date%Type,
	X_last_updated_by	IN	pji_mt_measures_b.last_updated_by%Type,
	X_last_update_login	IN	pji_mt_measures_b.last_update_login%Type,
	X_return_status	 OUT NOCOPY  VARCHAR2,
	X_msg_data	 OUT NOCOPY  VARCHAR2,
	X_msg_count	 OUT NOCOPY  NUMBER
);


-- -----------------------------------------------------------------------

procedure LOAD_ROW (

	X_measure_id		IN	pji_mt_measures_b.measure_id%type,
	X_measure_set_code	IN	pji_mt_measures_b.measure_set_code%type,
	X_measure_code		IN	pji_mt_measures_b.measure_code%type,
	X_xtd_type		IN	pji_mt_measures_b.xtd_type%type,
	X_pl_sql_api		IN	pji_mt_measures_b.pl_sql_api%type,
	X_object_version_number	IN	pji_mt_measures_b.object_version_number%type,

	X_name			IN	pji_mt_measures_tl.name%type,
	X_description		IN	pji_mt_measures_tl.description%type,

	X_owner			IN	VARCHAR2
);


-- -----------------------------------------------------------------------

procedure ADD_LANGUAGE;


-- -----------------------------------------------------------------------

procedure TRANSLATE_ROW (

	X_measure_id		IN	pji_mt_measures_b.measure_id%type,

	X_name			IN	pji_mt_measures_tl.name%type,
	X_description		IN	pji_mt_measures_tl.description%type,

	X_owner			IN	VARCHAR2
 );

-- -----------------------------------------------------------------------

end PJI_MT_MEASURES_PKG;

 

/
