--------------------------------------------------------
--  DDL for Package GMP_DESPATCH_LOAD_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMP_DESPATCH_LOAD_RPT_PKG" AUTHID CURRENT_USER AS
/* $Header: GMPRDESS.pls 120.1 2005/07/29 04:42:56 sowsubra noship $ */

PROCEDURE print_res_desp
                        (	errbuf              OUT NOCOPY VARCHAR2,
 				retcode             OUT NOCOPY VARCHAR2,
                                V_forg              IN NUMBER,
                                V_torg              IN NUMBER,
                                V_fres              IN VARCHAR2,
                                V_tores             IN VARCHAR2,
                                V_fres_instance     IN NUMBER,
                                V_tores_instance    IN NUMBER,
                                V_start_date        IN VARCHAR2,
                                V_to_date           IN VARCHAR2,
                                V_template          IN VARCHAR2,
                                V_template_locale   IN VARCHAR2
 			      );
PROCEDURE gme_res_generate_xml;

FUNCTION get_orgn_code( p_orgn_id  IN NUMBER) RETURN VARCHAR2 ;

PROCEDURE resdl_generate_output ( p_sequence_num IN NUMBER);

PROCEDURE rd_xml_transfer (     errbuf              OUT NOCOPY VARCHAR2,
                                retcode             OUT NOCOPY VARCHAR2,
                                p_sequence_num      IN  NUMBER
                          );

PROCEDURE print_res_load
                        (	errbuf              OUT NOCOPY VARCHAR2,
 				retcode             OUT NOCOPY VARCHAR2,
                                V_inst_id           IN NUMBER,
                                V_orgid             IN NUMBER,
                                V_plan_id           IN NUMBER,
                                V_forg              IN NUMBER,
                                V_torg              IN NUMBER,
                                V_fres              IN NUMBER,
                                V_tores             IN NUMBER,
                                V_fres_instance     IN NUMBER,
                                V_tores_instance    IN NUMBER,
                                V_start_date        IN VARCHAR2,
                                V_to_date           IN VARCHAR2,
                                V_template          IN VARCHAR2,
                                V_template_locale   IN VARCHAR2
 			      );

PROCEDURE aps_res_generate_xml;

FUNCTION get_inst_code( p_inst_id IN NUMBER) RETURN VARCHAR2 ;

FUNCTION get_plan_code( p_plan_id IN NUMBER) RETURN VARCHAR2 ;

FUNCTION get_resource_desc( p_resource_id IN NUMBER) RETURN VARCHAR2 ;

END GMP_DESPATCH_LOAD_RPT_PKG;

 

/
