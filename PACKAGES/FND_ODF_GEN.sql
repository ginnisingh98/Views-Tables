--------------------------------------------------------
--  DDL for Package FND_ODF_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_ODF_GEN" AUTHID CURRENT_USER  AS
/* $Header: fndpodfs.pls 120.4 2006/02/15 01:54 vkhatri noship $ */


PROCEDURE odfgen_xml (p_objType         IN VARCHAR2,
                      p_objName         IN VARCHAR2,
                      p_schemaName      IN VARCHAR2,
                      p_concatVar       IN VARCHAR2,
                      p_appshortName    IN VARCHAR2,
                      p_objMode         IN VARCHAR2,
                      p_includeTrigger  IN VARCHAR2,
                      p_includeSequence IN VARCHAR2,
                      p_includePolicy   IN VARCHAR2,
                      p_objInfo        OUT NOCOPY VARCHAR2,
                      p_policyCtr      OUT NOCOPY NUMBER,
                      p_triggerCtr     OUT NOCOPY NUMBER,
                      p_sequenceCtr    OUT NOCOPY NUMBER,
                      p_sysName        OUT NOCOPY NUMBER,
                      p_retXML         OUT NOCOPY CLOB);



PROCEDURE get_fnd_table_metadata(p_tableName      IN  VARCHAR2,
                                 p_owner          IN  VARCHAR2,
                                 p_ASNAME         IN  VARCHAR2,
                                 p_retXml         OUT NOCOPY CLOB);

PROCEDURE get_fnd_view_metadata(p_viewName      IN  VARCHAR2,
                                 p_owner          IN  VARCHAR2,
                                 p_ASNAME         IN  VARCHAR2,
                                 p_retXml         OUT NOCOPY CLOB);

PROCEDURE get_fnd_mview_metadata(p_mviewName      IN  VARCHAR2,
                                 p_owner          IN  VARCHAR2,
                                 p_ASNAME         IN  VARCHAR2,
                                 p_retXml         OUT NOCOPY CLOB);

PROCEDURE get_xml_sequence(p_seqNameList        IN VARCHAR2,
                           p_schemaName         IN VARCHAR2,
                           p_seqCount        OUT NOCOPY NUMBER,
                           p_SeqListing      OUT NOCOPY VARCHAR2,
                           p_retVal          OUT NOCOPY CLOB);

PROCEDURE get_xml_policy(p_tableName            IN  VARCHAR2,
                           p_schemaName         IN  VARCHAR2,
                           p_includePolicy      IN  VARCHAR2,
                           p_policyCount        OUT NOCOPY NUMBER,
                           p_PolicyListing      OUT NOCOPY VARCHAR2,
                           p_retVal             OUT NOCOPY CLOB);

PROCEDURE is_temp_iot (   p_object_name        IN VARCHAR2,
                          p_schemaName         IN VARCHAR2,
                          p_type               OUT NOCOPY VARCHAR2);

PROCEDURE get_ddl_comment(p_objName            IN  VARCHAR2,
                           p_schemaName       IN  VARCHAR2,
                           p_retVal           OUT NOCOPY CLOB);

PROCEDURE get_fnd_tab_col_metadata(p_objName      IN  VARCHAR2,
                                 p_owner          IN  VARCHAR2,
                                 p_ASNAME         IN  VARCHAR2,
                                 p_retXml         OUT NOCOPY CLOB);

PROCEDURE get_fnd_primary_key_metadata(p_objName      IN  VARCHAR2,
                                 p_owner          IN  VARCHAR2,
                                 p_ASNAME         IN  VARCHAR2,
                                 p_retXml         OUT NOCOPY CLOB);

PROCEDURE get_fnd_foreign_key_metadata(p_objName      IN  VARCHAR2,
                                 p_owner          IN  VARCHAR2,
                                 p_ASNAME         IN  VARCHAR2,
                                 p_retXml         OUT NOCOPY CLOB);

PROCEDURE get_fnd_histogram_metadata(p_objName      IN  VARCHAR2,
                                 p_owner          IN  VARCHAR2,
                                 p_ASNAME         IN  VARCHAR2,
                                 p_retXml         OUT NOCOPY CLOB);

PROCEDURE get_fnd_tablespace_metadata(p_objName      IN  VARCHAR2,
                                 p_owner          IN  VARCHAR2,
                                 p_ASNAME         IN  VARCHAR2,
                                 p_retXml         OUT NOCOPY CLOB);

PROCEDURE get_type_attr(p_typeName      IN  VARCHAR2,
                        p_owner          IN  VARCHAR2,
                        p_ASNAME         IN  VARCHAR2,
                        p_retXml         OUT NOCOPY CLOB);

PROCEDURE get_type_method(p_typeName      IN  VARCHAR2,
                        p_owner          IN  VARCHAR2,
                        p_ASNAME         IN  VARCHAR2,
                        p_retXml         OUT NOCOPY CLOB);

PROCEDURE get_type_method_params_results(p_typeName      IN  VARCHAR2,
                        p_owner          IN  VARCHAR2,
                        p_ASNAME         IN  VARCHAR2,
                        p_retXml         OUT NOCOPY CLOB);


END fnd_odf_gen;





 

/
