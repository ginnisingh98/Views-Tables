--------------------------------------------------------
--  DDL for Package FEM_TABLE_PUBLISH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_TABLE_PUBLISH_PKG" AUTHID CURRENT_USER AS
/* $Header: FEMVDIPUBS.pls 120.1 2007/07/27 10:36:34 gdonthir noship $ */



  --------------------------------------------------------------------------------
                           -- Declare all global variables --
  --------------------------------------------------------------------------------

     g_log_level_1                CONSTANT  NUMBER      := fnd_log.level_statement;
     g_log_level_2                CONSTANT  NUMBER      := fnd_log.level_procedure;
     g_log_level_3                CONSTANT  NUMBER      := fnd_log.level_event;
     g_log_level_4                CONSTANT  NUMBER      := fnd_log.level_exception;
     g_log_level_5                CONSTANT  NUMBER      := fnd_log.level_error;
     g_log_level_6                CONSTANT  NUMBER      := fnd_log.level_unexpected;

     g_block                      CONSTANT VARCHAR2(30) := 'FEM_TABLE_PUBLISH_PKG';


PROCEDURE Generate_XML_CP(
  x_retcode        OUT NOCOPY NUMBER,
  x_errbuff        OUT NOCOPY VARCHAR2,
  p_diObjDefId IN NUMBER,
  p_view IN VARCHAR2,
  p_comp_totals IN VARCHAR2
 );

PROCEDURE Generate_XML(
  x_retcode        OUT NOCOPY NUMBER,
  x_errbuff        OUT NOCOPY VARCHAR2,
  p_diObjDefId IN NUMBER,
  x_xml_result OUT NOCOPY CLOB,
  p_mode IN VARCHAR2,
  p_view IN VARCHAR2,
  p_comp_totals IN VARCHAR2);

PROCEDURE Run_Report(
 x_req_id OUT NOCOPY NUMBER,
 x_retcode OUT NOCOPY NUMBER,
 x_errbuff OUT NOCOPY VARCHAR2,
 x_xml_result OUT NOCOPY CLOB,
 p_diObjDefId IN NUMBER,
 p_gen_mode IN VARCHAR2,
 p_gen_format IN VARCHAR2,
 p_gen_template IN VARCHAR2,
 p_view IN VARCHAR2,
 p_comp_totals IN VARCHAR2,
 p_diQuery IN VARCHAR2
);

PROCEDURE Generate_Cust_XML_CP
(
 x_retcode OUT NOCOPY NUMBER,
 x_errbuff OUT NOCOPY VARCHAR2,
 p_diObjDefId IN NUMBER,
 p_diQuery IN VARCHAR2,
 p_view IN VARCHAR2
);

--Bug#6174477: Add view option parameter
PROCEDURE Generate_Cust_XML
(
 p_diObjDefId IN NUMBER,
 p_diQuery IN VARCHAR2,
 p_mode IN VARCHAR2,
 p_view IN VARCHAR2,
 x_xml_result OUT NOCOPY CLOB
);


PROCEDURE getConditionPredicate(
p_condObjId IN NUMBER,
p_tableName IN VARCHAR2,
p_whereClause OUT NOCOPY CLOB);

END FEM_TABLE_PUBLISH_PKG;

/
