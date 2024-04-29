--------------------------------------------------------
--  DDL for Package IGF_AP_LOADER_LAUNCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_LOADER_LAUNCH_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAP49S.pls 120.1 2006/04/18 05:52:44 hkodali noship $ */


FUNCTION get_message_class (p_file_name VARCHAR2)
RETURN VARCHAR2;

FUNCTION get_parameter_filename
RETURN VARCHAR2 ;

PROCEDURE main_process ( errbuf            OUT NOCOPY VARCHAR2,
                         retcode           OUT NOCOPY NUMBER,
                         p_org_id          IN         NUMBER,
                         p_file_path       IN         VARCHAR2,
                         p_file_list       IN         VARCHAR2
                       );

END igf_ap_loader_launch_pkg;


 

/
