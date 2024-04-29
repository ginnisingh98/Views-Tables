--------------------------------------------------------
--  DDL for Package EDW_DIM_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_DIM_SV" AUTHID DEFINER AS
/* $Header: EDWVDIMS.pls 115.9 2003/02/25 23:36:30 arsantha ship $ */

g_log boolean := false;

Procedure getViewnameForFlexdim(dim_name in varchar2) ;
FUNCTION getIndepVSClause( p_dim_name in VARCHAR2,  p_level IN VARCHAR2) RETURN VARCHAR2;
Function getTableValClause(dim_name in varchar2) return varchar2;
Function getNoneVSClause(p_dim_name in varchar2) return varchar2;
FUNCTION getDepVSClause(p_dim_name in varchar2) return VARCHAR2;

PROCEDURE getViewnamesForStdDim(dim_name in varchar2, level IN VARCHAR2) ;
PROCEDURE generateStdDimension(dim_name IN VARCHAR2);
FUNCTION getGeneratedViewnameForStdDim(dim_name IN VARCHAR2, level IN VARCHAR2) RETURN VARCHAR2;

Procedure generateViewForDimension(dim_name in varchar2);

END EDW_DIM_SV;

 

/
