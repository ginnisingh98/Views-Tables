--------------------------------------------------------
--  DDL for Package Body RG_DSS_REQUESTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RG_DSS_REQUESTS_PKG" as
/* $Header: rgidreqb.pls 120.2 2003/04/29 00:47:27 djogg ship $ */

PROCEDURE Lock_Row(X_request_id                           NUMBER,
                   X_status_flag                          VARCHAR2) IS
  CURSOR C IS
      SELECT *
      FROM   rg_dss_requests
      WHERE  request_id = X_request_id
      FOR UPDATE of status_flag  NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
  CLOSE C;

  IF (Recinfo.status_flag <> X_status_flag) THEN
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  ELSE
     RETURN;
  END IF;
END Lock_Row;


PROCEDURE Update_Row(X_request_id                           NUMBER,
                     X_status_flag                          VARCHAR2,
                     X_file_spec                            VARCHAR2,
		     X_last_update_date			    DATE,
		     X_last_updated_by			    NUMBER,
		     X_last_update_login		    NUMBER) IS
BEGIN

  UPDATE rg_dss_requests
  SET
    request_id                               =    X_request_id,
    status_flag                              =    X_status_flag,
    file_spec                                =    X_file_spec,
    last_update_date                         =    X_Last_Update_Date,
    last_updated_by                          =    X_Last_Updated_By,
    last_update_login                        =    X_Last_Update_Login
  WHERE request_id = X_request_id;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;

END Update_Row;


PROCEDURE Submit_Budget_Load(X_ledger_id                       VARCHAR2,
                             X_coa_id                       VARCHAR2,
                             X_budget_name                  VARCHAR2,
                             X_budget_version               VARCHAR2,
                             X_org_name                     VARCHAR2,
                             X_org_id                       VARCHAR2) IS
    dummy_id      NUMBER;
BEGIN
	dummy_id :=  FND_REQUEST.SUBMIT_REQUEST(
  		'SQLGL',
    		'GLBBSU',
    		'',
    		'',
    		FALSE,
    		X_ledger_id,
    		X_coa_id,
		X_budget_name,
                X_budget_version,
		X_org_name,
		X_org_id,
		chr(0),
    		'','','','','','','','','','','','','','','',
    		'','','','','','','','','','','','','','','',
    		'','','','','','','','','','','','','','','',
    		'','','','','','','','','','','','','','','',
    		'','','','','','','','','','','','','','','',
    		'','','','','','','','','','','','','','','',
    		'','','');
	COMMIT;

END Submit_Budget_Load;


END RG_DSS_REQUESTS_PKG;

/
