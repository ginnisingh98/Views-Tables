--------------------------------------------------------
--  DDL for Package M4U_XML_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."M4U_XML_EXTN" AUTHID CURRENT_USER AS
/* $Header: M4UGENXS.pls 120.0 2006/05/25 12:52:10 bsaratna noship $ */

        -- Generate XML fragment for given extn, tp_id combination
        -- global variables for xml generation can be passed in a_param_lst
        -- generated XML is copied back to x_xml
        -- if a_tp_dflt = true then M4U_DEFAULT_TP is used TP if no mapping is specified for
        -- a_tp_id
        -- Return success and XML
        -- or failure and failure message
        PROCEDURE generate_xml_fragment
        (
                a_extn_name             IN              VARCHAR2,
                a_tp_id                 IN              VARCHAR2,
                a_tp_dflt               IN              BOOLEAN,
                a_param_lst             IN              wf_parameter_list_t,
                a_log_lvl               IN              NUMBER,
                a_remove_empty_elmt     IN              BOOLEAN,
                a_remove_empty_attr     IN              BOOLEAN,
                x_ret_sts               OUT NOCOPY      VARCHAR2,
                x_ret_msg               OUT NOCOPY      VARCHAR2,
                x_xml                   OUT NOCOPY      VARCHAR2
        );
END m4u_xml_extn;

 

/
