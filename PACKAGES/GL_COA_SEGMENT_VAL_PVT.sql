--------------------------------------------------------
--  DDL for Package GL_COA_SEGMENT_VAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_COA_SEGMENT_VAL_PVT" AUTHID CURRENT_USER AS
/* $Header: GLSVIPVS.pls 120.0.12010000.1 2009/12/16 11:54:30 sommukhe noship $ */

/***********************************************************************************************
Created By:         Somnath Mukherjee
Date Created By:    01-AUG-2008
Purpose:            A private API to import data from external system to GL is declared along with
                    several PL-SQL table types to be used in the API.
Known limitations,enhancements,remarks:

Change History

Who         When           What
***********************************************************************************************/


PROCEDURE coa_segment_val_imp (
p_api_version			      IN           NUMBER,
p_init_msg_list			      IN           VARCHAR2 DEFAULT FND_API.G_FALSE,
p_commit			      IN           VARCHAR2 DEFAULT FND_API.G_FALSE,
p_validation_level		      IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
x_return_status		              OUT NOCOPY   VARCHAR2,
x_msg_count			      OUT NOCOPY   NUMBER,
x_msg_data			      OUT NOCOPY   VARCHAR2,
p_gl_flex_values_tbl		      IN OUT NOCOPY gl_coa_seg_val_imp_pub.gl_flex_values_tbl_type,
p_gl_flex_values_nh_tbl		      IN OUT NOCOPY gl_coa_seg_val_imp_pub.gl_flex_values_nh_tbl_type,
p_gl_flex_values_status		      OUT NOCOPY VARCHAR2,
p_gl_flex_values_nh_status	      OUT NOCOPY VARCHAR2

 ) ;


END gl_coa_segment_val_pvt;

/
