--------------------------------------------------------
--  DDL for Package IEX_SCORE_COMPONENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_SCORE_COMPONENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: iextscps.pls 120.0 2004/01/24 03:22:49 appldev noship $ */

/* Insert_Row procedure */
PROCEDURE Insert_Row(x_rowid	IN OUT NOCOPY VARCHAR2
	,p_SCORE_COMPONENT_ID		NUMBER
	,p_SCORE_COMP_WEIGHT		NUMBER	DEFAULT NULL
	,p_SCORE_ID		NUMBER	DEFAULT NULL
	,p_ENABLED_FLAG		VARCHAR2	DEFAULT NULL
	,p_LAST_UPDATE_DATE		DATE
	,p_LAST_UPDATED_BY		NUMBER
	,p_CREATION_DATE		DATE
	,p_CREATED_BY		NUMBER
	,p_LAST_UPDATE_LOGIN		NUMBER
	,p_REQUEST_ID		NUMBER	DEFAULT NULL
	,p_PROGRAM_APPLICATION_ID		NUMBER	DEFAULT NULL
	,p_PROGRAM_ID		NUMBER	DEFAULT NULL
	,p_PROGRAM_UPDATE_DATE		DATE	DEFAULT NULL
	,p_SCORE_COMP_TYPE_ID		NUMBER
);

/* Update_Row procedure */
PROCEDURE Update_Row(x_rowid	VARCHAR2
	,p_SCORE_COMPONENT_ID		NUMBER
	,p_SCORE_COMP_WEIGHT		NUMBER	DEFAULT NULL
	,p_SCORE_ID		NUMBER	DEFAULT NULL
	,p_ENABLED_FLAG		VARCHAR2	DEFAULT NULL
	,p_LAST_UPDATE_DATE		DATE
	,p_LAST_UPDATED_BY		NUMBER
	,p_CREATION_DATE		DATE
	,p_CREATED_BY		NUMBER
	,p_LAST_UPDATE_LOGIN		NUMBER
	,p_REQUEST_ID		NUMBER	DEFAULT NULL
	,p_PROGRAM_APPLICATION_ID		NUMBER	DEFAULT NULL
	,p_PROGRAM_ID		NUMBER	DEFAULT NULL
	,p_PROGRAM_UPDATE_DATE		DATE	DEFAULT NULL
	,p_SCORE_COMP_TYPE_ID		NUMBER
);

/* Delete_Row procedure */
PROCEDURE Delete_Row(x_rowid	VARCHAR2);

/* Lock_Row procedure */
PROCEDURE Lock_Row(x_rowid	VARCHAR2
	,p_SCORE_COMPONENT_ID		NUMBER
	,p_SCORE_COMP_WEIGHT		NUMBER	DEFAULT NULL
	,p_SCORE_ID		NUMBER	DEFAULT NULL
	,p_ENABLED_FLAG		VARCHAR2	DEFAULT NULL
	,p_LAST_UPDATE_DATE		DATE
	,p_LAST_UPDATED_BY		NUMBER
	,p_CREATION_DATE		DATE
	,p_CREATED_BY		NUMBER
	,p_LAST_UPDATE_LOGIN		NUMBER
	,p_REQUEST_ID		NUMBER	DEFAULT NULL
	,p_PROGRAM_APPLICATION_ID		NUMBER	DEFAULT NULL
	,p_PROGRAM_ID		NUMBER	DEFAULT NULL
	,p_PROGRAM_UPDATE_DATE		DATE	DEFAULT NULL
	,p_SCORE_COMP_TYPE_ID		NUMBER
);
END;


 

/