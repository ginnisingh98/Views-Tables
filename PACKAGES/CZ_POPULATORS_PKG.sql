--------------------------------------------------------
--  DDL for Package CZ_POPULATORS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CZ_POPULATORS_PKG" AUTHID CURRENT_USER AS
/*	$Header: czpops.pls 120.0 2005/05/25 05:40:56 appldev noship $		*/

mDEBUG_MODE          BOOLEAN:=FALSE;
mUSE_IMPORT          VARCHAR2(10):='N';
mCREATE_DEBUG_VIEWS  VARCHAR2(10):='N';
mUSE_VIEWS           VARCHAR2(10):='N';
mXFR_PROJECT_GROUP   VARCHAR2(255):='POPULATORS';

PROCEDURE Regenerate
(p_populator_id   IN     INTEGER,
 p_view_name      IN OUT NOCOPY VARCHAR2,
 p_sql_query      IN OUT NOCOPY VARCHAR2,
 p_err            OUT NOCOPY    INTEGER,
 p_init_fnd_stack IN VARCHAR2 DEFAULT NULL);

PROCEDURE Preview
(p_populator_id   IN  INTEGER,
 p_run_id         OUT NOCOPY INTEGER,
 p_err            OUT NOCOPY INTEGER,
 p_init_fnd_stack IN VARCHAR2 DEFAULT NULL);

PROCEDURE Execute
(p_populator_id   IN     INTEGER,
 p_run_id         IN OUT NOCOPY INTEGER,
 p_err            OUT NOCOPY    INTEGER,
 p_init_fnd_stack IN VARCHAR2 DEFAULT NULL);

PROCEDURE Repopulate
(p_model_id       IN  INTEGER,
 p_regenerate_all IN  VARCHAR2,
 p_handle_invalid IN  VARCHAR2,
 p_handle_broken  IN  VARCHAR2,
 p_err            OUT NOCOPY INTEGER,
 p_init_fnd_stack IN  VARCHAR2 DEFAULT NULL);

END CZ_POPULATORS_PKG;

 

/
