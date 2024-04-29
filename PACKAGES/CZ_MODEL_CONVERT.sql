--------------------------------------------------------
--  DDL for Package CZ_MODEL_CONVERT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_MODEL_CONVERT" AUTHID CURRENT_USER AS
/* $Header: czmdlcons.pls 120.0 2007/04/14 06:29:11 jhanda ship $ */

CONVERT_MODEL BOOLEAN :=FALSE;
---------------------------------------------------------------------------------------
/*
 * Public API for Model Conversion.
 * @param p_model_conversion_set_id
 *		       This is the CZ_MODEL_PUBLICATIONS, MIGRATION_GROUP_ID of the conversion request.
 *                     Conversion request is created by Developer and contains the list of all models selected
 *                     for Conversion from the source's Configurator Repository
 */

PROCEDURE convertModels( p_model_conversion_set_id IN NUMBER);
---------------------------------------------------------------------------------------

Procedure  Model_Convert_CP(errbuf out nocopy varchar2,
	Retcode out nocopy number,
	P_request_id in number default null);

FUNCTION GET_UI_PATH(inParent_id IN NUMBER) RETURN VARCHAR2;
FUNCTION GET_UI_ELEMENT_ID(inPageElemID IN VARCHAR2) RETURN NUMBER ;

END;

/
