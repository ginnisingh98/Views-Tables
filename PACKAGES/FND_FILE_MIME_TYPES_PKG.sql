--------------------------------------------------------
--  DDL for Package FND_FILE_MIME_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FILE_MIME_TYPES_PKG" AUTHID CURRENT_USER as
/* $Header: AFATFMTS.pls 120.0.12010000.3 2013/09/25 21:08:21 ctilley noship $ */

null_char varchar2(8) := '*NULL*';
null_date date := to_date('2', 'J');
null_number number := -999;

-------------------------------------------------------------------------------------
--
-- INSERT_ROW (PUBLIC)
--   Insert new user MIME_TYPE into FND_MIME_TYPES table only.
--   If the mime_type and file_ext already exists, an exception with the error message
--   Already exists will be returned.
--   There are two input arguments that must be provided. All the other columns
--   in FND_MIME_TYPE table can take the default value.
--
--   *** NOTE: This version accepts the last_update columns but these are overridden
--   with the same values as the creation_date and created_by columns.  This exists for
--   backward compatibility.
--
--   If FILE_EXT is null then the ALLOW_FILE_UPLOAD will be set to null regardless of
--   what is passed.
--
-- Input (Mandatory)
--  x_rowid:            Variable to return newly created rowid
--  x_mime_type:        New mime_type to create
--
-- Returns
--   row_id of created mime_type
--
PROCEDURE INSERT_ROW (X_ROWID in out nocopy VARCHAR2,
                      X_MIME_TYPE in VARCHAR2,
                      X_CP_FORMAT_CODE in VARCHAR2 DEFAULT NULL,
                      X_CTX_FORMAT_CODE in VARCHAR2 DEFAULT 'IGNORE',
                      X_CREATION_DATE in DATE DEFAULT SYSDATE,
                      X_CREATED_BY in NUMBER DEFAULT NULL,
                      X_LAST_UPDATE_DATE in DATE DEFAULT SYSDATE,
                      X_LAST_UPDATED_BY in NUMBER DEFAULT NULL,
                      X_LAST_UPDATE_LOGIN in NUMBER DEFAULT NULL,
                      X_FILE_EXT in VARCHAR2 DEFAULT NULL,
                      X_ALLOW_FILE_UPLOAD in VARCHAR2 DEFAULT NULL);


-------------------------------------------------------------------------------------
--
-- INSERT_ROW (PUBLIC)
--   Insert new user MIME_TYPE into FND_MIME_TYPES table only.
--   If the mime_type and file_ext already exists, an exception with the error message
--   Already exists will be returned.
--   There are two input arguments that must be provided. All the other columns
--   in FND_MIME_TYPE table can take the default value.
--
--   *** NOTE: This version accepts the last_update columns but these are overridden
--   with the same values as the creation_date and created_by columns
--
--   If FILE_EXT is null then the ALLOW_FILE_UPLOAD will be set to null regardless of
--   what is passed.
--
-- Input (Mandatory)
--  x_rowid:            Variable to return newly created rowid
--  x_mime_type:        New mime_type to create
--
-- Returns
--   row_id of created mime_type
--

PROCEDURE INSERT_ROW (X_ROWID in out nocopy VARCHAR2,
                      X_MIME_TYPE in VARCHAR2,
                      X_CP_FORMAT_CODE in VARCHAR2 DEFAULT NULL,
                      X_CTX_FORMAT_CODE in VARCHAR2 DEFAULT 'IGNORE',
                      X_CREATION_DATE in DATE DEFAULT SYSDATE,
                      X_CREATED_BY in NUMBER DEFAULT NULL,
                      X_FILE_EXT in VARCHAR2 DEFAULT NULL,
                      X_ALLOW_FILE_UPLOAD in VARCHAR2 DEFAULT NULL);


-------------------------------------------------------------------------------------
--
-- UPDATE_ROW (PUBLIC)
--   update the data for the MIME_TYPE_ID provided in FND_MIME_TYPES table only.
--   If the mime_type and file_ext already exists, an exception with the error message
--   Already exists will be returned.
--   There is one input argument that must be provided. All the other columns
--   in FND_MIME_TYPE table can take the default value.
--
--   ** NOTE **
--   If FILE_EXT is null then the ALLOW_FILE_UPLOAD will be set to null regardless of
--   what is passed.
--
-- Input (Mandatory)
--  x_mime_type_id:     Mime_type_id of the record to be updated
--
--
PROCEDURE UPDATE_ROW (X_MIME_TYPE_ID in NUMBER,
                      X_MIME_TYPE in VARCHAR2 DEFAULT NULL,
                      X_CP_FORMAT_CODE in VARCHAR2 DEFAULT NULL,
                      X_CTX_FORMAT_CODE in VARCHAR2 DEFAULT NULL,
                      X_LAST_UPDATE_DATE in DATE DEFAULT SYSDATE,
                      X_LAST_UPDATED_BY in NUMBER DEFAULT NULL,
                      X_FILE_EXT in VARCHAR2 DEFAULT NULL,
                      X_ALLOW_FILE_UPLOAD in VARCHAR2 DEFAULT NULL);


-------------------------------------------------------------------------------------
--
-- DELETE_ROW (PUBLIC)
--   Deletes an existing MIME_TYPE/FILE_EXT combination.
--   If the mime_type and file_ext does not exist, an exception with the error message
--   No data found be returned.
--
--   There are two  input arguments must be provided.
--
-- Input (Mandatory)
--  x_mime_type:     Mime_type of the record to be deleted
--  x_file_ext:      File_ext of the record to be deleted
--

PROCEDURE DELETE_ROW (X_MIME_TYPE in VARCHAR2,
                      X_FILE_EXT in VARCHAR2);


-------------------------------------------------------------------------------------
--
--  SET_FILE_EXT (PUBLIC)
--   Sets the file_ext for an existing mime_type that currently has a null file extension.
--   The mime_type must exist without a current file_ext else an exception with the error message
--   No data found is returned.
--
--   If the mime_type exists with a current file_ext then either insert a new record or
--   use update_row to change the current file_ext to the new file_ext.
--
--   There are two  input arguments must be provided.
--
-- Input (Mandatory)
--  x_mime_type:     Mime_type of the record to be updated
--  x_file_ext:      File_ext to set for this mime_type
--

PROCEDURE SET_FILE_EXT (X_MIME_TYPE IN VARCHAR2,
				                X_FILE_EXT IN VARCHAR2,
				                X_LAST_UPDATE_DATE in DATE DEFAULT SYSDATE,
                        X_LAST_UPDATED_BY in NUMBER DEFAULT NULL);

-------------------------------------------------------------------------------------
--
--  SET_ALLOW_UPLOAD (PUBLIC)
--   Sets the allow_file_upload for an existing mime_type and file_ext combination that
--   currently has a null file extension.
--   The mime_type and file_ext must exist, else an exception with the error message
--   No data found is returned.
--
--   There are three input arguments must be provided.
--
-- Input (Mandatory)
--  x_mime_type:     			Mime_type of the record to be updated
--  x_file_ext:      			File_ext for this mime_type
--  x_allow_file_upload		'Y' or 'N'
--
PROCEDURE SET_ALLOW_UPLOAD (X_FILE_EXT IN VARCHAR2,
                            X_MIME_TYPE IN VARCHAR2,
                            X_ALLOW_FILE_UPLOAD IN VARCHAR2,
                            X_LAST_UPDATE_DATE in DATE DEFAULT SYSDATE,
                            X_LAST_UPDATED_BY in NUMBER DEFAULT NULL);


END FND_FILE_MIME_TYPES_PKG;

/
