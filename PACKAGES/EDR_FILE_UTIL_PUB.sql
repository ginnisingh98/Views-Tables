--------------------------------------------------------
--  DDL for Package EDR_FILE_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_FILE_UTIL_PUB" AUTHID CURRENT_USER AS
/* $Header: EDRFUTLS.pls 120.0.12000000.1 2007/01/18 05:53:07 appldev ship $ */

G_API_VERSION NUMBER := 1.0;

PROCEDURE GET_FILE_NAME(p_file_id IN NUMBER,
				x_file_name OUT NOCOPY VARCHAR2);

PROCEDURE GET_VERSION_LABEL(p_file_id IN NUMBER,
				x_version_label OUT NOCOPY VARCHAR2);

PROCEDURE GET_CATEGORY_NAME(p_file_id IN NUMBER,
				x_category_name OUT NOCOPY VARCHAR2);

PROCEDURE GET_AUTHOR_NAME(p_file_id IN NUMBER,
 			x_author_name OUT NOCOPY VARCHAR2);

PROCEDURE GET_ATTRIBUTE(p_file_id IN NUMBER,
				p_attribute_col IN VARCHAR2,
				x_attribute_value OUT NOCOPY VARCHAR2);

PROCEDURE GET_FILE_DATA(p_file_id NUMBER,
                                x_file_data OUT NOCOPY BLOB);

END EDR_FILE_UTIL_PUB;

 

/
