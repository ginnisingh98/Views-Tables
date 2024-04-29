--------------------------------------------------------
--  DDL for Package Body EDR_FILE_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDR_FILE_UTIL_PUB" AS
/*  $Header: EDRFUTLB.pls 120.0.12000000.1 2007/01/18 05:53:05 appldev ship $    */

PROCEDURE GET_FILE_NAME(p_file_id IN NUMBER,
				x_file_name OUT NOCOPY VARCHAR2)
AS
BEGIN
	select file_name into x_file_name
	from edr_files_b
	where file_id = p_file_id;
EXCEPTION WHEN NO_DATA_FOUND then
	x_file_name := null;
END GET_FILE_NAME;

PROCEDURE GET_VERSION_LABEL(p_file_id IN NUMBER,
				x_version_label OUT NOCOPY VARCHAR2)
AS
BEGIN
	select version_label into x_version_label
	from edr_files_b
	where file_id = p_file_id;
EXCEPTION WHEN NO_DATA_FOUND then
	x_version_label := null;
END GET_VERSION_LABEL;

PROCEDURE GET_CATEGORY_NAME(p_file_id IN NUMBER,
				x_category_name OUT NOCOPY VARCHAR2)
AS
BEGIN
	select attribute_category into x_category_name
	from edr_files_b
	where file_id = p_file_id;
EXCEPTION WHEN NO_DATA_FOUND then
	x_category_name := null;
END GET_CATEGORY_NAME;

PROCEDURE GET_AUTHOR_NAME(p_file_id IN NUMBER,
				x_author_name OUT NOCOPY VARCHAR2)
AS
BEGIN
	SELECT A.USER_NAME into x_author_name
	FROM FND_USER A, EDR_FILES_B B
	WHERE A.USER_ID = B.CREATED_BY
	AND B.FILE_ID = p_file_id;
EXCEPTION WHEN NO_DATA_FOUND then
	x_author_name := null;
END GET_AUTHOR_NAME;

PROCEDURE GET_ATTRIBUTE(p_file_id IN NUMBER,
				p_attribute_col IN VARCHAR2,
				x_attribute_value OUT NOCOPY VARCHAR2)
AS
	l_str varchar2(150);
BEGIN
	l_str := 'select ' || p_attribute_col || ' from edr_files_b where file_id = ' || p_file_id;
      execute immediate l_str into x_attribute_value;
EXCEPTION WHEN NO_DATA_FOUND then
	x_attribute_value := null;
END GET_ATTRIBUTE;

PROCEDURE GET_FILE_DATA(p_file_id NUMBER,
				x_file_data OUT NOCOPY BLOB)
AS
BEGIN
	select a.file_data into x_file_data
	from 	fnd_lobs a,
		fnd_documents_vl b,
		edr_files_vl c
	where a.file_id = b.media_id
	and b.document_id = c.fnd_document_id
	and c.file_id = p_file_id;

EXCEPTION WHEN NO_DATA_FOUND then
	x_file_data := null;
END GET_FILE_DATA;


END EDR_FILE_UTIL_PUB;

/
